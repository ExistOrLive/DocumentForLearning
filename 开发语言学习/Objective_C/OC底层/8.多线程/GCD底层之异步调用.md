# 异步调用`dispatch_async`

```objc
void
dispatch_async(dispatch_queue_t dq, dispatch_block_t work)
{
	dispatch_continuation_t dc = _dispatch_continuation_alloc();
	uintptr_t dc_flags = DC_FLAG_CONSUME;
	dispatch_qos_t qos;

	qos = _dispatch_continuation_init(dc, dq, work, 0, dc_flags);
	_dispatch_continuation_async(dq, dc, qos, dc->dc_flags);
}
```

## 1. `dispatch_continuation_t`

首先`dispatch_continuation_t`类将进一步封装`dispatch_block_t`。
在`_dispatch_continuation_init`方法中, 拷贝了block对象，并与`_dispatch_call_block_and_release`函数，一同封装在`dispatch_continuation_t`实例中。

`_dispatch_call_block_and_release`函数将用于执行block和释放block。

```objc
static inline dispatch_qos_t
_dispatch_continuation_init(dispatch_continuation_t dc,
		dispatch_queue_class_t dqu, dispatch_block_t work,
		dispatch_block_flags_t flags, uintptr_t dc_flags)
{
	void *ctxt = _dispatch_Block_copy(work);

	dc_flags |= DC_FLAG_BLOCK | DC_FLAG_ALLOCATED;
	if (unlikely(_dispatch_block_has_private_data(work))) {
		dc->dc_flags = dc_flags;
		dc->dc_ctxt = ctxt;
		// will initialize all fields but requires dc_flags & dc_ctxt to be set
		return _dispatch_continuation_init_slow(dc, dqu, flags);
	}

	dispatch_function_t func = _dispatch_Block_invoke(work);
	if (dc_flags & DC_FLAG_CONSUME) {
		func = _dispatch_call_block_and_release;
	}
	return _dispatch_continuation_init_f(dc, dqu, ctxt, func, flags, dc_flags);
}

static inline dispatch_qos_t
_dispatch_continuation_init_f(dispatch_continuation_t dc,
		dispatch_queue_class_t dqu, void *ctxt, dispatch_function_t f,
		dispatch_block_flags_t flags, uintptr_t dc_flags)
{
	pthread_priority_t pp = 0;
	dc->dc_flags = dc_flags | DC_FLAG_ALLOCATED;
	dc->dc_func = f;
	dc->dc_ctxt = ctxt;
	// in this context DISPATCH_BLOCK_HAS_PRIORITY means that the priority
	// should not be propagated, only taken from the handler if it has one
	if (!(flags & DISPATCH_BLOCK_HAS_PRIORITY)) {
		pp = _dispatch_priority_propagate();
	}
	_dispatch_continuation_voucher_set(dc, flags);
	return _dispatch_continuation_priority_set(dc, dqu, pp, flags);
}
```

## 2. 任务入队 ： dx_push

```objc
static inline void
_dispatch_continuation_async(dispatch_queue_class_t dqu,
		dispatch_continuation_t dc, dispatch_qos_t qos, uintptr_t dc_flags)
{
#if DISPATCH_INTROSPECTION
	if (!(dc_flags & DC_FLAG_NO_INTROSPECTION)) {
		_dispatch_trace_item_push(dqu, dc);
	}
#else
	(void)dc_flags;
#endif
	return dx_push(dqu._dq, dc, qos);
}
```

`dx_push`是一个宏，我们找到了它的宏定义。

```c
#define dx_vtable(x) (&(x)->do_vtable->_os_obj_vtable)

#define dx_push(x, y, z) dx_vtable(x)->dq_push(x, y, z)
```

`do_vtable`其实就是isa，指向的是类对象。`dx_vtable(x)->dq_push(x, y, z)` 其中的`dx_push`其实就是上文**队列的创建**中提到的`_OS_dispatch_queue_****_vtable`中的`dx_push`方法。

```c
DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_serial, lane,
	.do_type        = DISPATCH_QUEUE_SERIAL_TYPE,
	.do_dispose     = _dispatch_lane_dispose,
	.do_debug       = _dispatch_queue_debug,
	.do_invoke      = _dispatch_lane_invoke,

	.dq_activate    = _dispatch_lane_activate,
	.dq_wakeup      = _dispatch_lane_wakeup,
	.dq_push        = _dispatch_lane_push,
);

DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_concurrent, lane,
	.do_type        = DISPATCH_QUEUE_CONCURRENT_TYPE,
	.do_dispose     = _dispatch_lane_dispose,
	.do_debug       = _dispatch_queue_debug,
	.do_invoke      = _dispatch_lane_invoke,

	.dq_activate    = _dispatch_lane_activate,
	.dq_wakeup      = _dispatch_lane_wakeup,
	.dq_push        = _dispatch_lane_concurrent_push,
);

DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_global, lane,
	.do_type        = DISPATCH_QUEUE_GLOBAL_ROOT_TYPE,
	.do_dispose     = _dispatch_object_no_dispose,
	.do_debug       = _dispatch_queue_debug,
	.do_invoke      = _dispatch_object_no_invoke,

	.dq_activate    = _dispatch_queue_no_activate,
	.dq_wakeup      = _dispatch_root_queue_wakeup,
	.dq_push        = _dispatch_root_queue_push,
);

DISPATCH_VTABLE_SUBCLASS_INSTANCE(queue_main, lane,
	.do_type        = DISPATCH_QUEUE_MAIN_TYPE,
	.do_dispose     = _dispatch_lane_dispose,
	.do_debug       = _dispatch_queue_debug,
	.do_invoke      = _dispatch_lane_invoke,

	.dq_activate    = _dispatch_queue_no_activate,
	.dq_wakeup      = _dispatch_main_queue_wakeup,
	.dq_push        = _dispatch_main_queue_push,
);

```


###  2.1 `_dispatch_lane_push`

对于私有串行队列`OS_dispatch_queue_serial`，`dq_push`的函数实现是`_dispatch_lane_push`。

`_dispatch_lane_push` 将会负责任务的入队，并通过原子操作保证线程安全。

```objc
DISPATCH_NOINLINE
void
_dispatch_lane_push(dispatch_lane_t dq, dispatch_object_t dou,
		dispatch_qos_t qos)
{
	....

	// 任务入队
	prev = os_mpsc_push_update_tail(os_mpsc(dq, dq_items), dou._do, do_next);
	if (unlikely(os_mpsc_push_was_empty(prev))) {
		_dispatch_retain_2_unsafe(dq);
		flags = DISPATCH_WAKEUP_CONSUME_2 | DISPATCH_WAKEUP_MAKE_DIRTY;
	} else if (unlikely(_dispatch_queue_need_override(dq, qos))) {
		// There's a race here, _dispatch_queue_need_override may read a stale
		// dq_state value.
		//
		// If it's a stale load from the same drain streak, given that
		// the max qos is monotonic, too old a read can only cause an
		// unnecessary attempt at overriding which is harmless.
		//
		// We'll assume here that a stale load from an a previous drain streak
		// never happens in practice.
		_dispatch_retain_2_unsafe(dq);
		flags = DISPATCH_WAKEUP_CONSUME_2;
	}
	os_mpsc_push_update_prev(os_mpsc(dq, dq_items), prev, dou._do, do_next);

    // 唤醒一个线程，执行任务
	if (flags) {
		return dx_wakeup(dq, qos, flags);
	}
}
```

将`prev = os_mpsc_push_update_tail(os_mpsc(dq, dq_items), dou._do, do_next);`和`os_mpsc_push_update_prev(os_mpsc(dq, dq_items), prev, dou._do, do_next);`展开得到：

```objc
// 更新队尾，并返回之前队尾的指针
prev = {
	_os_atomic_basetypeof(&(dq)->dq_items_head) _tl = dou._do;
	os_atomic_store2o(_tl,do_next,NULL,relaxed);
	os_atomic_xchg(&(dq)->dq_items_tail,_tl,release);
}


// 将新的队尾插入到之前队尾
{ 
	_os_atomic_basetypeof(&(dq)->dq_items_head) _prev = prev;
	if(likely(_prev)){
		(void)os_atomic_store2o(_prev, do_next, dou._do, relaxed); \
	} else {
		(void)os_atomic_store(&(dq)->dq_items_head, dou._do, relaxed); \
	}
}
```
在上文**队列的创建**中，我们得到了`dispatch_queue_static_s`，其中包含了`dq_items_head`和`dq_items_tail`两个`dispatch_object_s`指针，从这里看来应该是分别用于指向队列的队首和队尾。

```objc
struct dispatch_queue_static_s {
    const struct dispatch_lane_vtable_s *do_vtable;      // isa 
	....
	struct dispatch_lane_s *volatile do_next;
	struct dispatch_queue_s *do_targetq;
	.....

	struct dispatch_object_s *volatile dq_items_tail; 
	.... 
	struct dispatch_object_s *volatile dq_items_head; 
	....
} 

```

`os_mpsc_push_update_tail`和`os_mpsc_push_update_prev`的作用就是将新的任务加到队尾,并保证线程安全。

在函数结束时，调用`dx_wakeup`唤醒一个线程去处理加入队列的任务。


###  2.2 `_dispatch_lane_concurrent_push`

对于私有并发队列`OS_dispatch_queue_concurrent`，`dq_push`的函数实现是`_dispatch_lane_concurrent_push`。

当队列为空以及满足其他一些条件，会调用`_dispatch_continuation_redirect_push`;否则调用`_dispatch_lane_push`,进入与私有串行队列一致的流程。

```objc
void
_dispatch_lane_concurrent_push(dispatch_lane_t dq, dispatch_object_t dou,
		dispatch_qos_t qos)
{   
	// 当队列为空以及其他一些判断，
	if (dq->dq_items_tail == NULL &&
			!_dispatch_object_is_waiter(dou) &&
			!_dispatch_object_is_barrier(dou) &&
			_dispatch_queue_try_acquire_async(dq)) {
		return _dispatch_continuation_redirect_push(dq, dou, qos);
	}
	_dispatch_lane_push(dq, dou, qos);
}
```

`_dispatch_continuation_redirect_push`方法实现如下：

这里获取了`dl`的`do_targetq`,并调用`dx_push`。从上文可知，`OS_dispatch_queue_concurrent`实例的`do_targetq`指向的是全局并发队列`OS_dispatch_queue_global`。`_dispatch_continuation_redirect_push` 就可以理解为将消息转发给`do_targetq`，类似于继承体系中的`super`调用。

```objc
static void
_dispatch_continuation_redirect_push(dispatch_lane_t dl,
		dispatch_object_t dou, dispatch_qos_t qos)
{
	if (likely(!_dispatch_object_is_redirection(dou))) {
		dou._dc = _dispatch_async_redirect_wrap(dl, dou);
	} else if (!dou._dc->dc_ctxt) {
		// find first queue in descending target queue order that has
		// an autorelease frequency set, and use that as the frequency for
		// this continuation.
		dou._dc->dc_ctxt = (void *)
		(uintptr_t)_dispatch_queue_autorelease_frequency(dl);
	}

	dispatch_queue_t dq = dl->do_targetq;
	if (!qos) qos = _dispatch_priority_qos(dq->dq_priority);
	dx_push(dq, dou, qos);
}
```

### 2.3 `_dispatch_root_queue_push`

对于全局并发队列`OS_dispatch_queue_global`，`dq_push`的函数实现是`_dispatch_root_queue_push`。

```objc
DISPATCH_NOINLINE
void
_dispatch_root_queue_push(dispatch_queue_global_t rq, dispatch_object_t dou,
		dispatch_qos_t qos)
{
   ......

	_dispatch_root_queue_push_inline(rq, dou, dou, 1);
}

DISPATCH_ALWAYS_INLINE
static inline void
_dispatch_root_queue_push_inline(dispatch_queue_global_t dq,
		dispatch_object_t _head, dispatch_object_t _tail, int n)
{
	struct dispatch_object_s *hd = _head._do, *tl = _tail._do;
	// 任务入队
	if (unlikely(os_mpsc_push_list(os_mpsc(dq, dq_items), hd, tl, do_next))) {
		return _dispatch_root_queue_poke(dq, n, 0);
	}
}

```

`os_mpsc_push_list` 展开具体入队的操作：

```objc
{
    (os_mpsc_push_list(os_mpsc(dq, dq_items), hd, tl, do_next))
    
	// 先更新队尾
	struct dispatch_object_s * _token;
    struct dispatch_object_s * _tl = tl;
	os_atomic_store2o(_tl,do_next,NULL,relaxed);
	_token = os_atomic_xchg(&(dq)->dq_items_tail,_tl,release);
    
	if(likely(_token)){
		(void)os_atomic_store2o(_token, do_next, hd, relaxed);
	} else {
		(void)os_atomic_store(&(dq)->dq_items_head, head, relaxed); 
	}
	
	return _token  == NULL
}
```

当`os_mpsc_push_list`返回`true`，说明插入之前队列是空的，并没有分配线程处理该队列的任务，将调用`_dispatch_root_queue_poke`分配新的线程处理任务; 如果返回`false`，说明插入之前队列非空，将直接返回。

### 2.4 `_dispatch_root_queue_poke` 分配线程

这里简单理解为分配新的进程用于处理任务

```objc
void
_dispatch_root_queue_poke(dispatch_queue_global_t dq, int n, int floor)
{
	if (!_dispatch_queue_class_probe(dq)) {
		return;
	}
#if !DISPATCH_USE_INTERNAL_WORKQUEUE
#if DISPATCH_USE_PTHREAD_POOL
	if (likely(dx_type(dq) == DISPATCH_QUEUE_GLOBAL_ROOT_TYPE))
#endif
	{
		if (unlikely(!os_atomic_cmpxchg2o(dq, dgq_pending, 0, n, relaxed))) {
			_dispatch_root_queue_debug("worker thread request still pending "
					"for global queue: %p", dq);
			return;
		}
	}
#endif // !DISPATCH_USE_INTERNAL_WORKQUEUE
	return _dispatch_root_queue_poke_slow(dq, n, floor);
}
```

`_dispatch_root_queue_poke_slow`

```objc
DISPATCH_NOINLINE
static void
_dispatch_root_queue_poke_slow(dispatch_queue_global_t dq, int n, int floor)
{
	int remaining = n;
	int r = ENOSYS;

	_dispatch_root_queues_init();
	_dispatch_debug_root_queue(dq, __func__);
	_dispatch_trace_runtime_event(worker_request, dq, (uint64_t)n);

#if !DISPATCH_USE_INTERNAL_WORKQUEUE
#if DISPATCH_USE_PTHREAD_ROOT_QUEUES
	if (dx_type(dq) == DISPATCH_QUEUE_GLOBAL_ROOT_TYPE)
#endif
	{
		_dispatch_root_queue_debug("requesting new worker thread for global "
				"queue: %p", dq);
		r = _pthread_workqueue_addthreads(remaining,
				_dispatch_priority_to_pp_prefer_fallback(dq->dq_priority));
		(void)dispatch_assume_zero(r);
		return;
	}
#endif // !DISPATCH_USE_INTERNAL_WORKQUEUE
#if DISPATCH_USE_PTHREAD_POOL
	dispatch_pthread_root_queue_context_t pqc = dq->do_ctxt;
	if (likely(pqc->dpq_thread_mediator.do_vtable)) {
		while (dispatch_semaphore_signal(&pqc->dpq_thread_mediator)) {
			_dispatch_root_queue_debug("signaled sleeping worker for "
					"global queue: %p", dq);
			if (!--remaining) {
				return;
			}
		}
	}

	bool overcommit = dq->dq_priority & DISPATCH_PRIORITY_FLAG_OVERCOMMIT;
	if (overcommit) {
		os_atomic_add2o(dq, dgq_pending, remaining, relaxed);
	} else {
		if (!os_atomic_cmpxchg2o(dq, dgq_pending, 0, remaining, relaxed)) {
			_dispatch_root_queue_debug("worker thread request still pending for "
					"global queue: %p", dq);
			return;
		}
	}

	int can_request, t_count;
	// seq_cst with atomic store to tail <rdar://problem/16932833>
	t_count = os_atomic_load2o(dq, dgq_thread_pool_size, ordered);
	do {
		can_request = t_count < floor ? 0 : t_count - floor;
		if (remaining > can_request) {
			_dispatch_root_queue_debug("pthread pool reducing request from %d to %d",
					remaining, can_request);
			os_atomic_sub2o(dq, dgq_pending, remaining - can_request, relaxed);
			remaining = can_request;
		}
		if (remaining == 0) {
			_dispatch_root_queue_debug("pthread pool is full for root queue: "
					"%p", dq);
			return;
		}
	} while (!os_atomic_cmpxchgvw2o(dq, dgq_thread_pool_size, t_count,
			t_count - remaining, &t_count, acquire));

	pthread_attr_t *attr = &pqc->dpq_thread_attr;
	pthread_t tid, *pthr = &tid;
#if DISPATCH_USE_MGR_THREAD && DISPATCH_USE_PTHREAD_ROOT_QUEUES
	if (unlikely(dq == &_dispatch_mgr_root_queue)) {
		pthr = _dispatch_mgr_root_queue_init();
	}
#endif
	do {
		_dispatch_retain(dq); // released in _dispatch_worker_thread
		while ((r = pthread_create(pthr, attr, _dispatch_worker_thread, dq))) {
			if (r != EAGAIN) {
				(void)dispatch_assume_zero(r);
			}
			_dispatch_temporary_resource_shortage();
		}
	} while (--remaining);
#else
	(void)floor;
#endif // DISPATCH_USE_PTHREAD_POOL
}
```
从代码中可以看出根据宏定义的不同，有两种分配线程的方式：

- `_pthread_workqueue_addthreads`
- `pthread_create`

我们通过符号断点调试程序，可以确定使用的`_pthread_workqueue_addthreads`

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-04%20%E4%B8%8B%E5%8D%887.49.20.png)

## 2.5 `_dispatch_root_queues_init`

`_dispatch_root_queues_init` 用于注册线程的执行函数，通过`dispatch_once_f`保证只执行一次。

```objc
static inline void
_dispatch_root_queues_init(void)
{
	dispatch_once_f(&_dispatch_root_queues_pred, NULL,
			_dispatch_root_queues_init_once);
}

static void
_dispatch_root_queues_init_once(void *context DISPATCH_UNUSED)
{
	_dispatch_fork_becomes_unsafe();
#if DISPATCH_USE_INTERNAL_WORKQUEUE
	size_t i;
	for (i = 0; i < DISPATCH_ROOT_QUEUE_COUNT; i++) {
		_dispatch_root_queue_init_pthread_pool(&_dispatch_root_queues[i], 0,
				_dispatch_root_queues[i].dq_priority);
	}
#else
	int wq_supported = _pthread_workqueue_supported();
	int r = ENOTSUP;

	if (!(wq_supported & WORKQ_FEATURE_MAINTENANCE)) {
		DISPATCH_INTERNAL_CRASH(wq_supported,
				"QoS Maintenance support required");
	}

	if (unlikely(!_dispatch_kevent_workqueue_enabled)) {
		r = _pthread_workqueue_init(_dispatch_worker_thread2,
				offsetof(struct dispatch_queue_s, dq_serialnum), 0);
#if DISPATCH_USE_KEVENT_WORKQUEUE
	} else if (wq_supported & WORKQ_FEATURE_KEVENT) {
		r = _pthread_workqueue_init_with_kevent(_dispatch_worker_thread2,
				(pthread_workqueue_function_kevent_t)
				_dispatch_kevent_worker_thread,
				offsetof(struct dispatch_queue_s, dq_serialnum), 0);
#endif
	} else {
		DISPATCH_INTERNAL_CRASH(wq_supported, "Missing Kevent WORKQ support");
	}

	if (r != 0) {
		DISPATCH_INTERNAL_CRASH((r << 16) | wq_supported,
				"Root queue initialization failed");
	}
#endif // DISPATCH_USE_INTERNAL_WORKQUEUE
}

```

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-05%20%E4%B8%8B%E5%8D%8811.11.38.png)

通过符号断点`_dispatch_root_queues_init_once`调试, 可以看到使用`_dispatch_worker_thread2`和`	pthread_workqueue_function_kevent_t`。因此推断是通过`_pthread_workqueue_init_with_kevent`注册了线程的执行函数。

```objc
r = _pthread_workqueue_init_with_kevent(_dispatch_worker_thread2,
				(pthread_workqueue_function_kevent_t)
				_dispatch_kevent_worker_thread,
				offsetof(struct dispatch_queue_s, dq_serialnum), 0);
```

[**libpthread**](https://opensource.apple.com/tarballs/libpthread/)提供了苹果的`pthread`实现。

```c
// 源码来自libpthread-416.100.3
int
_pthread_workqueue_init_with_kevent(pthread_workqueue_function2_t queue_func,
		pthread_workqueue_function_kevent_t kevent_func,
		int offset, int flags)
{
	return _pthread_workqueue_init_with_workloop(queue_func, kevent_func, NULL, offset, flags);
}

int
_pthread_workqueue_init_with_workloop(pthread_workqueue_function2_t queue_func,
		pthread_workqueue_function_kevent_t kevent_func,
		pthread_workqueue_function_workloop_t workloop_func,
		int offset, int flags)
{
	.....
	return pthread_workqueue_setup(&cfg, sizeof(cfg));
}

int
pthread_workqueue_setup(struct pthread_workqueue_config *cfg, size_t cfg_size)
{
    ....

	if (__libdispatch_workerfunction == NULL) {
	    
		....

		// Tell the kernel about dispatch internals
		rv = (int) __workq_kernreturn(WQOPS_SETUP_DISPATCH, &wdc_cfg, sizeof(wdc_cfg), 0);

		if (rv == -1) {
			return errno;
		} else {
			__libdispatch_keventfunction = cfg->kevent_cb;
			__libdispatch_workloopfunction = cfg->workloop_cb;
			__libdispatch_workerfunction = cfg->workq_cb;

			// Prepare the kernel for workq action
			(void)__workq_open();
			if (__is_threaded == 0) {
				__is_threaded = 1;
			}
			return 0;
		}
	}

	return rv;
}

```

## 3. `_dispatch_worker_thread2` 回调

在上文`_dispatch_root_queues_init`函数中，注册了`_dispatch_worker_thread2`作为线程的执行函数。

我们通过断点调试也确定并发队列异步执行的堆栈中，调用了`_dispatch_worker_thread2`。（串行队列异步执行的堆栈调用了`_dispatch_workloop_worker_thread`函数，但是我在**libdispatch**源码中没有查询到，这里暂不讨论）

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-06-30%20%E4%B8%8A%E5%8D%884.38.34.png)

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-06-30%20%E4%B8%8A%E5%8D%884.34.54.png)

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-06%20%E4%B8%8B%E5%8D%884.34.23.png)

```objc
static void
_dispatch_worker_thread2(pthread_priority_t pp)
{
    .... 

	// 根据优先级， 获取对应的全局并发队列
	dq = _dispatch_get_root_queue(_dispatch_qos_from_pp(pp), overcommit);

    .... 

	// 从队列中取出任务开始执行
	int pending = os_atomic_dec2o(dq, dgq_pending, relaxed);
	_dispatch_root_queue_drain(dq, dq->dq_priority,
			DISPATCH_INVOKE_WORKER_DRAIN | DISPATCH_INVOKE_REDIRECTING_DRAIN);
	_dispatch_voucher_debug("root queue clear", NULL);
	_dispatch_reset_voucher(NULL, DISPATCH_THREAD_PARK);
	_dispatch_trace_runtime_event(worker_park, NULL, 0);
}
```

### 3.1 `_dispatch_root_queue_drain`

`_dispatch_root_queue_drain` 首先调用`_dispatch_queue_set_current(dq)`将当前队列和线程绑定。

接着不断地调用`_dispatch_root_queue_drain_one`从队列的头部取出任务，并执行`_dispatch_continuation_pop_inline`。

```objc
static void
_dispatch_root_queue_drain(dispatch_queue_global_t dq,
		dispatch_priority_t pri, dispatch_invoke_flags_t flags)
{
    ...

	// 绑定queue和线程
	_dispatch_queue_set_current(dq);
	_dispatch_init_basepri(pri);
	_dispatch_adopt_wlh_anon();

	struct dispatch_object_s *item;
	bool reset = false;
	dispatch_invoke_context_s dic = { };
#if DISPATCH_COCOA_COMPAT
	_dispatch_last_resort_autorelease_pool_push(&dic);
#endif // DISPATCH_COCOA_COMPAT
	_dispatch_queue_drain_init_narrowing_check_deadline(&dic, pri);
	_dispatch_perfmon_start();
	
	while (likely(item = _dispatch_root_queue_drain_one(dq))) {
		if (reset) _dispatch_wqthread_override_reset();
		_dispatch_continuation_pop_inline(item, &dic, flags, dq);
		reset = _dispatch_reset_basepri_override();
		if (unlikely(_dispatch_queue_drain_should_narrow(&dic))) {
			break;
		}
	}

	// overcommit or not. worker thread
	if (pri & DISPATCH_PRIORITY_FLAG_OVERCOMMIT) {
		_dispatch_perfmon_end(perfmon_thread_worker_oc);
	} else {
		_dispatch_perfmon_end(perfmon_thread_worker_non_oc);
	}

#if DISPATCH_COCOA_COMPAT
	_dispatch_last_resort_autorelease_pool_pop(&dic);
#endif // DISPATCH_COCOA_COMPAT
	_dispatch_reset_wlh();
	_dispatch_clear_basepri();
	_dispatch_queue_set_current(NULL);
}

```
### 3.2 `_dispatch_root_queue_drain_one`

`_dispatch_root_queue_drain_one` 主要工作是从队列的头部取出任务并返回。

- 更新队列的头部(`dq_items_head`)和尾部(`dq_items_tail`)指针时，要保证线程安全(原子操作)

- 如果取出头部任务后，队列仍然不为空时，将会调用`_dispatch_root_queue_poke`再分配线程处理其他任务，而当前线程会接着处理当前取出的任务。
 
```objc
static inline struct dispatch_object_s *
_dispatch_root_queue_drain_one(dispatch_queue_global_t dq)
{
	struct dispatch_object_s *head, *next;

start:
	// The MEDIATOR value acts both as a "lock" and a signal
	// 取出队首的任务
	head = os_atomic_xchg2o(dq, dq_items_head,
			DISPATCH_ROOT_QUEUE_MEDIATOR, relaxed);

	if (unlikely(head == NULL)) {
		// The first xchg on the tail will tell the enqueueing thread that it
		// is safe to blindly write out to the head pointer. A cmpxchg honors
		// the algorithm.
		if (unlikely(!os_atomic_cmpxchg2o(dq, dq_items_head,
				DISPATCH_ROOT_QUEUE_MEDIATOR, NULL, relaxed))) {
			goto start;
		}
		if (unlikely(dq->dq_items_tail)) { // <rdar://problem/14416349>
			if (__DISPATCH_ROOT_QUEUE_CONTENDED_WAIT__(dq,
					_dispatch_root_queue_head_tail_quiesced)) {
				goto start;
			}
		}
		_dispatch_root_queue_debug("no work on global queue: %p", dq);
		return NULL;
	}

	if (unlikely(head == DISPATCH_ROOT_QUEUE_MEDIATOR)) {
		// This thread lost the race for ownership of the queue.
		if (likely(__DISPATCH_ROOT_QUEUE_CONTENDED_WAIT__(dq,
				_dispatch_root_queue_mediator_is_gone))) {
			goto start;
		}
		return NULL;
	}

	// Restore the head pointer to a sane value before returning.
	// If 'next' is NULL, then this item _might_ be the last item.
	next = head->do_next;

	if (unlikely(!next)) {
		// 如果接下来没有任务了，更新队尾指针
		os_atomic_store2o(dq, dq_items_head, NULL, relaxed);
		// 22708742: set tail to NULL with release, so that NULL write to head
		//           above doesn't clobber head from concurrent enqueuer
		if (os_atomic_cmpxchg2o(dq, dq_items_tail, head, NULL, release)) {
			// both head and tail are NULL now
			goto out;
		}
		// There must be a next item now.
		next = os_mpsc_get_next(head, do_next);
	}
    
	// 更新队首的指针
	os_atomic_store2o(dq, dq_items_head, next, relaxed);
	// 分配新的线程处理其他任务
	_dispatch_root_queue_poke(dq, 1, 0);
out:
    // 返回当前队首的任务
	return head;
}

```

### 3.3 `_dispatch_continuation_pop_inline` 执行任务

```objc
static inline void
_dispatch_continuation_pop_inline(dispatch_object_t dou,
		dispatch_invoke_context_t dic, dispatch_invoke_flags_t flags,
		dispatch_queue_class_t dqu)
{
	dispatch_pthread_root_queue_observer_hooks_t observer_hooks =
			_dispatch_get_pthread_root_queue_observer_hooks();
	if (observer_hooks) observer_hooks->queue_will_execute(dqu._dq);
	flags &= _DISPATCH_INVOKE_PROPAGATE_MASK;
	if (_dispatch_object_has_vtable(dou)) {
		dx_invoke(dou._dq, dic, flags);
	} else {
		_dispatch_continuation_invoke_inline(dou, flags, dqu);
	}
	if (observer_hooks) observer_hooks->queue_did_execute(dqu._dq);
}
```

`_dispatch_continuation_pop_inline` 调用`dx_invoke`。 和 `dx_push`一样是宏定义，`#define dx_push(x, y, z) dx_vtable(x)->dq_push(x, y, z)`。 

```objc
typedef union {
	struct _os_object_s *_os_obj;
	struct dispatch_object_s *_do;
	struct dispatch_queue_s *_dq;
	struct dispatch_queue_attr_s *_dqa;
	struct dispatch_group_s *_dg;
	struct dispatch_source_s *_ds;
	struct dispatch_mach_s *_dm;
	struct dispatch_mach_msg_s *_dmsg;
	struct dispatch_semaphore_s *_dsema;
	struct dispatch_data_s *_ddata;
	struct dispatch_io_s *_dchannel;
} dispatch_object_t DISPATCH_TRANSPARENT_UNION;
```

`dispatch_object_t`是一个联合体union，`dou._dq`取出一个`dispatch_queue_s *`指针。但是从上文，我们知道入队的对象事实上是一个`dispatch_continuation_t`了类型。那么`dou._dq`得到的实际上是`dispatch_continuation_t`

在上文中，**私有并发队列**调用`_dispatch_lane_concurrent_push`函数将任务入队，之后会调用`_dispatch_continuation_redirect_push`或者`_dispatch_lane_push`函数。 

在`_dispatch_continuation_redirect_push`函数中，调用了`_dispatch_async_redirect_wrap`重新封装了任务对象,并设置`dc->do_vtable = DC_VTABLE(ASYNC_REDIRECT);`。

```objc
static void
_dispatch_continuation_redirect_push(dispatch_lane_t dl,
		dispatch_object_t dou, dispatch_qos_t qos)
{  
	....

	dou._dc = _dispatch_async_redirect_wrap(dl, dou);
    
	.....

	dispatch_queue_t dq = dl->do_targetq;
	if (!qos) qos = _dispatch_priority_qos(dq->dq_priority);
	dx_push(dq, dou, qos);
}

static inline dispatch_continuation_t
_dispatch_async_redirect_wrap(dispatch_lane_t dq, dispatch_object_t dou)
{
	dispatch_continuation_t dc = _dispatch_continuation_alloc();

	dou._do->do_next = NULL;
	// 设置do_vtable
	dc->do_vtable = DC_VTABLE(ASYNC_REDIRECT);
	dc->dc_func = NULL;
	dc->dc_ctxt = (void *)(uintptr_t)_dispatch_queue_autorelease_frequency(dq);
	dc->dc_data = dq;
	dc->dc_other = dou._do;
	dc->dc_voucher = DISPATCH_NO_VOUCHER;
	dc->dc_priority = DISPATCH_NO_PRIORITY;
	_dispatch_retain_2(dq); // released in _dispatch_async_redirect_invoke
	return dc;
}
```

而对于**全局并发队列**，调用`_dispatch_root_queue_push`函数，同样在入队之前重现封装了任务对象，`dc->do_vtable = DC_VTABLE(OVERRIDE_OWNING);`

```objc
void
_dispatch_root_queue_push(dispatch_queue_global_t rq, dispatch_object_t dou,
		dispatch_qos_t qos)

	....
	if (_dispatch_root_queue_push_needs_override(rq, qos)) {
		return _dispatch_root_queue_push_override(rq, dou, qos);
	}

	_dispatch_root_queue_push_inline(rq, dou, dou, 1);
}

static void
_dispatch_root_queue_push_override(dispatch_queue_global_t orig_rq,
		dispatch_object_t dou, dispatch_qos_t qos)
{
	bool overcommit = orig_rq->dq_priority & DISPATCH_PRIORITY_FLAG_OVERCOMMIT;
	dispatch_queue_global_t rq = _dispatch_get_root_queue(qos, overcommit);
	dispatch_continuation_t dc = dou._dc;

	if (_dispatch_object_is_redirection(dc)) {
		// no double-wrap is needed, _dispatch_async_redirect_invoke will do
		// the right thing
		dc->dc_func = (void *)orig_rq;
	} else {
		dc = _dispatch_continuation_alloc();
		// 设置 vtable
		dc->do_vtable = DC_VTABLE(OVERRIDE_OWNING);
		dc->dc_ctxt = dc;
		dc->dc_other = orig_rq;
		dc->dc_data = dou._do;
		dc->dc_priority = DISPATCH_NO_PRIORITY;
		dc->dc_voucher = DISPATCH_NO_VOUCHER;
	}
	_dispatch_root_queue_push_inline(rq, dc, dc, 1);
}

```

在任务`dispatch_continuation_t`对象入队之前，都会重现封装任务对象，并设置对象的`do_vtable`。从上文中，我们知道`do_vtable`就是对象的`isa`，而相关的方法列表定义也找到了。

```objc
const struct dispatch_continuation_vtable_s _dispatch_continuation_vtables[] = {
	DC_VTABLE_ENTRY(ASYNC_REDIRECT,
		.do_invoke = _dispatch_async_redirect_invoke),
#if HAVE_MACH
	DC_VTABLE_ENTRY(MACH_SEND_BARRRIER_DRAIN,
		.do_invoke = _dispatch_mach_send_barrier_drain_invoke),
	DC_VTABLE_ENTRY(MACH_SEND_BARRIER,
		.do_invoke = _dispatch_mach_barrier_invoke),
	DC_VTABLE_ENTRY(MACH_RECV_BARRIER,
		.do_invoke = _dispatch_mach_barrier_invoke),
	DC_VTABLE_ENTRY(MACH_ASYNC_REPLY,
		.do_invoke = _dispatch_mach_msg_async_reply_invoke),
#endif
#if HAVE_PTHREAD_WORKQUEUE_QOS
	DC_VTABLE_ENTRY(WORKLOOP_STEALING,
		.do_invoke = _dispatch_workloop_stealer_invoke),
	DC_VTABLE_ENTRY(OVERRIDE_STEALING,
		.do_invoke = _dispatch_queue_override_invoke),
	DC_VTABLE_ENTRY(OVERRIDE_OWNING,
		.do_invoke = _dispatch_queue_override_invoke),
#endif
};

```

从方法列表中可知，**私有并发队列**的任务设置为`DC_VTABLE(ASYNC_REDIRECT)`类型，则`do_invoke`指向的函数实现是`_dispatch_async_redirect_invoke`；**全局并发队列**的任务设置为`DC_VTABLE(OVERRIDE_OWNING)`类型，则`do_invoke`指向的函数实现是`_dispatch_queue_override_invoke`。这个可以通过断点调试验证：

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-06%20%E4%B8%8B%E5%8D%884.34.24.png)

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-06-30%20%E4%B8%8A%E5%8D%884.34.55.png)

## 3.4 `_dispatch_async_redirect_invoke`

`_dispatch_async_redirect_invoke` 将重新回到`_dispatch_continuation_pop`，这时将会调用`_dispatch_continuation_invoke_inline`而不是`dx_invoke`。



```objc

void
_dispatch_async_redirect_invoke(dispatch_continuation_t dc,
		dispatch_invoke_context_t dic, dispatch_invoke_flags_t flags)
{
	.....

	uintptr_t dc_flags = DC_FLAG_CONSUME | DC_FLAG_NO_INTROSPECTION;
	_dispatch_thread_frame_push(&dtf, dq);


	_dispatch_continuation_pop_forwarded(dc, dc_flags, NULL, {
		_dispatch_continuation_pop(other_dc, dic, flags, dq);
	});


	_dispatch_thread_frame_pop(&dtf);
	if (assumed_rq) _dispatch_queue_set_current(old_dq);
	_dispatch_reset_basepri(old_dbp);

	rq = dq->do_targetq;
	while (unlikely(rq->do_targetq && rq != old_dq)) {
		_dispatch_lane_non_barrier_complete(upcast(rq)._dl, 0);
		rq = rq->do_targetq;
	}

	// pairs with _dispatch_async_redirect_wrap
	_dispatch_lane_non_barrier_complete(dq, DISPATCH_WAKEUP_CONSUME_2);
}

static inline void
_dispatch_continuation_invoke_inline(dispatch_object_t dou,
		dispatch_invoke_flags_t flags, dispatch_queue_class_t dqu)
{
	dispatch_continuation_t dc = dou._dc, dc1;
	dispatch_invoke_with_autoreleasepool(flags, {
	     
		....

		if (dc_flags & DC_FLAG_CONSUME) {
			dc1 = _dispatch_continuation_free_cacheonly(dc);
		} else {
			dc1 = NULL;
		}
		if (unlikely(dc_flags & DC_FLAG_GROUP_ASYNC)) {
			_dispatch_continuation_with_group_invoke(dc);
		} else {

			// 将调用任务的block
			_dispatch_client_callout(dc->dc_ctxt, dc->dc_func);
			_dispatch_trace_item_complete(dc);
		}
		if (unlikely(dc1)) {
			_dispatch_continuation_free_to_cache_limit(dc1);
		}
	});
	_dispatch_perfmon_workitem_inc();
}

```


## 3.4 `_dispatch_queue_override_invoke`

`_dispatch_queue_override_invoke` 也会调用`_dispatch_continuation_invoke_inline`。

```objc
static void
_dispatch_queue_override_invoke(dispatch_continuation_t dc,
		dispatch_invoke_context_t dic, dispatch_invoke_flags_t flags)
{
	dispatch_queue_t old_rq = _dispatch_queue_get_current();
	dispatch_queue_global_t assumed_rq = dc->dc_other;
	dispatch_priority_t old_dp;
	dispatch_object_t dou;
	uintptr_t dc_flags = DC_FLAG_CONSUME;

	dou._do = dc->dc_data;
	old_dp = _dispatch_root_queue_identity_assume(assumed_rq);
	if (dc_type(dc) == DISPATCH_CONTINUATION_TYPE(OVERRIDE_STEALING)) {
		flags |= DISPATCH_INVOKE_STEALING;
		dc_flags |= DC_FLAG_NO_INTROSPECTION;
	}
	_dispatch_continuation_pop_forwarded(dc, dc_flags, assumed_rq, {
		if (_dispatch_object_has_vtable(dou._do)) {
			dx_invoke(dou._dq, dic, flags);
		} else {
			_dispatch_continuation_invoke_inline(dou, flags, assumed_rq);
		}
	});
	_dispatch_reset_basepri(old_dp);
	_dispatch_queue_set_current(old_rq);
}
```

最终都会来到`_dispatch_client_callout`

## 4. `_dispatch_client_callout`

```objc
void
_dispatch_client_callout(void *ctxt, dispatch_function_t f)
{
	_dispatch_get_tsd_base();
	void *u = _dispatch_get_unwind_tsd();
	if (likely(!u)) return f(ctxt);
	_dispatch_set_unwind_tsd(NULL);
	f(ctxt);
	_dispatch_free_unwind_tsd();
	_dispatch_set_unwind_tsd(u);
}
```

`ctxt`是我们传入的代码块，`f`是`_dispatch_call_block_and_release`，将会在`ctxt`调用后释放它。

```objc
void
_dispatch_call_block_and_release(void *block)
{
	void (^b)(void) = block;
	b();
	Block_release(b);
}
```

![](https://github.com/existorlive/existorlivepic/raw/master/dispatch_async1.png)