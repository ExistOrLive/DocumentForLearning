# GCD底层之同步调用

```objc

void
dispatch_sync(dispatch_queue_t dq, dispatch_block_t work)
{
	uintptr_t dc_flags = DC_FLAG_BLOCK;
	if (unlikely(_dispatch_block_has_private_data(work))) {
		return _dispatch_sync_block_with_privdata(dq, work, dc_flags);
	}
	_dispatch_sync_f(dq, work, _dispatch_Block_invoke(work), dc_flags);
}


static void
_dispatch_sync_f(dispatch_queue_t dq, void *ctxt, dispatch_function_t func,
		uintptr_t dc_flags)
{
	_dispatch_sync_f_inline(dq, ctxt, func, dc_flags);
}

static inline void
_dispatch_sync_f_inline(dispatch_queue_t dq, void *ctxt,
		dispatch_function_t func, uintptr_t dc_flags)
{
	if (likely(dq->dq_width == 1)) {
		return _dispatch_barrier_sync_f(dq, ctxt, func, dc_flags);
	}

	if (unlikely(dx_metatype(dq) != _DISPATCH_LANE_TYPE)) {
		DISPATCH_CLIENT_CRASH(0, "Queue type doesn't support dispatch_sync");
	}

	dispatch_lane_t dl = upcast(dq)._dl;
	// Global concurrent queues and queues bound to non-dispatch threads
	// always fall into the slow case, see DISPATCH_ROOT_QUEUE_STATE_INIT_VALUE
	if (unlikely(!_dispatch_queue_try_reserve_sync_width(dl))) {
		return _dispatch_sync_f_slow(dl, ctxt, func, 0, dl, dc_flags);
	}

	if (unlikely(dq->do_targetq->do_targetq)) {
		return _dispatch_sync_recurse(dl, ctxt, func, dc_flags);
	}
	_dispatch_introspection_sync_begin(dl);
	_dispatch_sync_invoke_and_complete(dl, ctxt, func DISPATCH_TRACE_ARG(
			_dispatch_trace_item_sync_push_pop(dq, ctxt, func, dc_flags)));
}

```

## 1. 串行队列

```objc
static inline void
_dispatch_sync_f_inline(dispatch_queue_t dq, void *ctxt,
		dispatch_function_t func, uintptr_t dc_flags)
{
	if (likely(dq->dq_width == 1)) {
		return _dispatch_barrier_sync_f(dq, ctxt, func, dc_flags);
	}

    ......
}
```

在`_dispatch_sync_f_inline`函数，首先会判断并发数，如果并发数为1，即为串行队列，将调用`_dispatch_barrier_sync_f`并返回。

```objc
static void
_dispatch_barrier_sync_f(dispatch_queue_t dq, void *ctxt,
		dispatch_function_t func, uintptr_t dc_flags)
{
	_dispatch_barrier_sync_f_inline(dq, ctxt, func, dc_flags);
}

static inline void
_dispatch_barrier_sync_f_inline(dispatch_queue_t dq, void *ctxt,
		dispatch_function_t func, uintptr_t dc_flags)
{
	dispatch_tid tid = _dispatch_tid_self();

	if (unlikely(dx_metatype(dq) != _DISPATCH_LANE_TYPE)) {
		DISPATCH_CLIENT_CRASH(0, "Queue type doesn't support dispatch_sync");
	}

	dispatch_lane_t dl = upcast(dq)._dl;
	// The more correct thing to do would be to merge the qos of the thread
	// that just acquired the barrier lock into the queue state.
	//
	// However this is too expensive for the fast path, so skip doing it.
	// The chosen tradeoff is that if an enqueue on a lower priority thread
	// contends with this fast path, this thread may receive a useless override.
	//
	// Global concurrent queues and queues bound to non-dispatch threads
	// always fall into the slow case, see DISPATCH_ROOT_QUEUE_STATE_INIT_VALUE

    // 
	if (unlikely(!_dispatch_queue_try_acquire_barrier_sync(dl, tid))) {
		return _dispatch_sync_f_slow(dl, ctxt, func, DC_FLAG_BARRIER, dl,
				DC_FLAG_BARRIER | dc_flags);
	}

	if (unlikely(dl->do_targetq->do_targetq)) {
		return _dispatch_sync_recurse(dl, ctxt, func,
				DC_FLAG_BARRIER | dc_flags);
	}
	_dispatch_introspection_sync_begin(dl);
	_dispatch_lane_barrier_sync_invoke_and_complete(dl, ctxt, func
			DISPATCH_TRACE_ARG(_dispatch_trace_item_sync_push_pop(
					dq, ctxt, func, dc_flags | DC_FLAG_BARRIER)));
}
```

`_dispatch_queue_try_acquire_barrier_sync` 判断了当前串行队列的状态，如果不需要等待其他任务完成，则返回`true`。如果需要等待其他任务完成，则会一直忙等待直到其他任务完成，返回`false`。

也就是说任务需要等待的话，调用`_dispatch_sync_f_slow`,不需要等待调用`_dispatch_lane_barrier_sync_invoke_and_complete`

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%882.43.19.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-06-30%20%E4%B8%8A%E5%8D%884.39.27.png)


最终都会调用`_dispatch_client_callout`执行任务block


## 2. `_dispatch_sync_f_slow` 

如果串行队列需要等待或者是全局并发队列，都会调用到`_dispatch_sync_f_slow` 。

`!dq->do_targetq == true` 说明是全局并发队列，将调用`_dispatch_sync_function_invoke`。

而串行队列会先调用`__DISPATCH_WAIT_FOR_QUEUE__`函数，判断是否存在死锁以及请求串行队列的锁。

```objc

static void
_dispatch_sync_f_slow(dispatch_queue_class_t top_dqu, void *ctxt,
		dispatch_function_t func, uintptr_t top_dc_flags,
		dispatch_queue_class_t dqu, uintptr_t dc_flags)
{
	dispatch_queue_t top_dq = top_dqu._dq;
	dispatch_queue_t dq = dqu._dq;

	// dq->do_targetq == NULL 说明是全局并发队列
	if (unlikely(!dq->do_targetq)) {
		return _dispatch_sync_function_invoke(dq, ctxt, func);
	}

	pthread_priority_t pp = _dispatch_get_priority();
	struct dispatch_sync_context_s dsc = {
		.dc_flags    = DC_FLAG_SYNC_WAITER | dc_flags,
		.dc_func     = _dispatch_async_and_wait_invoke,
		.dc_ctxt     = &dsc,
		.dc_other    = top_dq,
		.dc_priority = pp | _PTHREAD_PRIORITY_ENFORCE_FLAG,
		.dc_voucher  = _voucher_get(),
		.dsc_func    = func,
		.dsc_ctxt    = ctxt,
		.dsc_waiter  = _dispatch_tid_self(),
	};

	_dispatch_trace_item_push(top_dq, &dsc);

	// 判断死锁 和 wait 
	__DISPATCH_WAIT_FOR_QUEUE__(&dsc, dq);

	if (dsc.dsc_func == NULL) {
		dispatch_queue_t stop_dq = dsc.dc_other;
		return _dispatch_sync_complete_recurse(top_dq, stop_dq, top_dc_flags);
	}

	_dispatch_introspection_sync_begin(top_dq);
	_dispatch_trace_item_pop(top_dq, &dsc);
	_dispatch_sync_invoke_and_complete_recurse(top_dq, ctxt, func,top_dc_flags
			DISPATCH_TRACE_ARG(&dsc));
}


```

### 2.1 `__DISPATCH_WAIT_FOR_QUEUE__`


```objc
static void
__DISPATCH_WAIT_FOR_QUEUE__(dispatch_sync_context_t dsc, dispatch_queue_t dq)
{
	uint64_t dq_state = _dispatch_wait_prepare(dq);
	if (unlikely(_dq_state_drain_locked_by(dq_state, dsc->dsc_waiter))) {
		DISPATCH_CLIENT_CRASH((uintptr_t)dq_state,
				"dispatch_sync called on queue "
				"already owned by current thread");
	}

	// Blocks submitted to the main thread MUST run on the main thread, and
	// dispatch_async_and_wait also executes on the remote context rather than
	// the current thread.
	//
	// For both these cases we need to save the frame linkage for the sake of
	// _dispatch_async_and_wait_invoke
	_dispatch_thread_frame_save_state(&dsc->dsc_dtf);

	if (_dq_state_is_suspended(dq_state) ||
			_dq_state_is_base_anon(dq_state)) {
		dsc->dc_data = DISPATCH_WLH_ANON;
	} else if (_dq_state_is_base_wlh(dq_state)) {
		dsc->dc_data = (dispatch_wlh_t)dq;
	} else {
		_dispatch_wait_compute_wlh(upcast(dq)._dl, dsc);
	}

	if (dsc->dc_data == DISPATCH_WLH_ANON) {
		dsc->dsc_override_qos_floor = dsc->dsc_override_qos =
				(uint8_t)_dispatch_get_basepri_override_qos_floor();
		_dispatch_thread_event_init(&dsc->dsc_event);
	}
	dx_push(dq, dsc, _dispatch_qos_from_pp(dsc->dc_priority));
	_dispatch_trace_runtime_event(sync_wait, dq, 0);
	if (dsc->dc_data == DISPATCH_WLH_ANON) {
		_dispatch_thread_event_wait(&dsc->dsc_event); // acquire
	} else {
		_dispatch_event_loop_wait_for_ownership(dsc);
	}
	if (dsc->dc_data == DISPATCH_WLH_ANON) {
		_dispatch_thread_event_destroy(&dsc->dsc_event);
		// If _dispatch_sync_waiter_wake() gave this thread an override,
		// ensure that the root queue sees it.
		if (dsc->dsc_override_qos > dsc->dsc_override_qos_floor) {
			_dispatch_set_basepri_override_qos(dsc->dsc_override_qos);
		}
	}
}

```

`__DISPATCH_WAIT_FOR_QUEUE__`首先调用`_dq_state_drain_locked_by`判断死锁的存在。如果当前线程已经获取了锁，如果再去请求则会发生死锁。此时会报异常`dispatch_sync called on queue already owned by current thread`

```objc
static inline bool
_dq_state_drain_locked_by(uint64_t dq_state, dispatch_tid tid)
{
	return _dispatch_lock_is_locked_by((dispatch_lock)dq_state, tid);
}

static inline bool
_dispatch_lock_is_locked_by(dispatch_lock lock_value, dispatch_tid tid)
{
	// 判断锁的拥有者是否为当前的线程
	// equivalent to _dispatch_lock_owner(lock_value) == tid
	return ((lock_value ^ tid) & DLOCK_OWNER_MASK) == 0;
}
```

#### 死锁Example

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%888.27.09.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%888.25.49.png)



## 并发队列

并发队列中的同步任务不会发生任何等待，而会直接执行。

```objc
static inline void
_dispatch_sync_f_inline(dispatch_queue_t dq, void *ctxt,
		dispatch_function_t func, uintptr_t dc_flags)
{
    // 串行队列
	if (likely(dq->dq_width == 1)) {
		return _dispatch_barrier_sync_f(dq, ctxt, func, dc_flags);
	}

    .....

	dispatch_lane_t dl = upcast(dq)._dl;
	// Global concurrent queues and queues bound to non-dispatch threads
	// always fall into the slow case, see DISPATCH_ROOT_QUEUE_STATE_INIT_VALUE
    // 全局并发队列
	if (unlikely(!_dispatch_queue_try_reserve_sync_width(dl))) {
		return _dispatch_sync_f_slow(dl, ctxt, func, 0, dl, dc_flags);
	}

	if (unlikely(dq->do_targetq->do_targetq)) {
		return _dispatch_sync_recurse(dl, ctxt, func, dc_flags);
	}
	_dispatch_introspection_sync_begin(dl);

    // 私有并发队列
	_dispatch_sync_invoke_and_complete(dl, ctxt, func DISPATCH_TRACE_ARG(
			_dispatch_trace_item_sync_push_pop(dq, ctxt, func, dc_flags)));
}

```

全局并发队列将会调用`_dispatch_sync_f_slow`; 私有并发队列将调用`_dispatch_sync_invoke_and_complete`，最终都会调用`_dispatch_client_callout`执行任务block。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-06-30%20%E4%B8%8A%E5%8D%884.34.09.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-08%20%E4%B8%8B%E5%8D%888.47.05.png)










