# GCD底层实现之队列的创建

GCD由库[**libdispatch**](https://opensource.apple.com/tarballs/libdispatch/)实现，本文中所参考源码为**libdispatch-1008.270.1**

```objc
struct dispatch_queue_static_s {
	struct dispatch_lane_s _as_dl[0]; \
	DISPATCH_LANE_CLASS_HEADER(lane);
} DISPATCH_CACHELINE_ALIGN;

#define DISPATCH_LANE_CLASS_HEADER(x) \
	struct dispatch_queue_s _as_dq[0]; \
	DISPATCH_QUEUE_CLASS_HEADER(x, \
			struct dispatch_object_s *volatile dq_items_tail); \
	dispatch_unfair_lock_s dq_sidelock; \
	struct dispatch_object_s *volatile dq_items_head; \
	uint32_t dq_side_suspend_cnt
```

展开所有宏定义,最终得到

```objc
struct dispatch_queue_static_s {

    const struct dispatch_lane_vtable_s *do_vtable;      // isa 
	int volatile do_ref_cnt;                             // ref count ?
	int volatile do_xref_cnt;                            // 

	struct dispatch_lane_s *volatile do_next;
	struct dispatch_queue_s *do_targetq;
	void *do_ctxt;
	void *do_finalizer;

	struct dispatch_object_s *volatile dq_items_tail; 
	DISPATCH_UNION_LE(uint64_t volatile dq_state, 
			dispatch_lock dq_state_lock, 
			uint32_t dq_state_bits 
	)

    unsigned long dq_serialnum;
	const char *dq_label;
	DISPATCH_UNION_LE(uint32_t volatile dq_atomic_flags, 
		const uint16_t dq_width,
		const uint16_t __dq_opaque2
	);
	dispatch_priority_t dq_priority; 
	union { 
		struct dispatch_queue_specific_head_s *dq_specific_head; 
		struct dispatch_source_refs_s *ds_refs; 
		struct dispatch_timer_source_refs_s *ds_timer_refs; 
		struct dispatch_mach_recv_refs_s *dm_recv_refs; 
	}; 
	int volatile dq_sref_cnt;
	
	dispatch_unfair_lock_s dq_sidelock; 
	struct dispatch_object_s *volatile dq_items_head; 
	uint32_t dq_side_suspend_cnt
} DISPATCH_CACHELINE_ALIGN;

```

## libdispatch_init

在之前类的加载中，我们了解到动态库中首先初始化的是**libsystem**库，会调用到`libSystem_initializer`函数，在该函数中会调用到`libdispatch_init`函数，即是**libdispatch**库的初始化函数。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-05-28%20%E4%B8%8A%E5%8D%883.55.31.png)

```objc
DISPATCH_EXPORT DISPATCH_NOTHROW
void
libdispatch_init(void)
{
	dispatch_assert(sizeof(struct dispatch_apply_s) <=
			DISPATCH_CONTINUATION_SIZE);

	if (_dispatch_getenv_bool("LIBDISPATCH_STRICT", false)) {
		_dispatch_mode |= DISPATCH_MODE_STRICT;
	}
#if HAVE_OS_FAULT_WITH_PAYLOAD && TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR
	if (_dispatch_getenv_bool("LIBDISPATCH_NO_FAULTS", false)) {
		_dispatch_mode |= DISPATCH_MODE_NO_FAULTS;
	} else if (getpid() == 1 ||
			!os_variant_has_internal_diagnostics("com.apple.libdispatch")) {
		_dispatch_mode |= DISPATCH_MODE_NO_FAULTS;
	}
#endif // HAVE_OS_FAULT_WITH_PAYLOAD && TARGET_OS_IPHONE && !TARGET_OS_SIMULATOR


#if DISPATCH_DEBUG || DISPATCH_PROFILE
#if DISPATCH_USE_KEVENT_WORKQUEUE
	if (getenv("LIBDISPATCH_DISABLE_KEVENT_WQ")) {
		_dispatch_kevent_workqueue_enabled = false;
	}
#endif
#endif

#if HAVE_PTHREAD_WORKQUEUE_QOS
	dispatch_qos_t qos = _dispatch_qos_from_qos_class(qos_class_main());
	_dispatch_main_q.dq_priority = _dispatch_priority_make(qos, 0);
#if DISPATCH_DEBUG
	if (!getenv("LIBDISPATCH_DISABLE_SET_QOS")) {
		_dispatch_set_qos_class_enabled = 1;
	}
#endif
#endif

#if DISPATCH_USE_THREAD_LOCAL_STORAGE
	_dispatch_thread_key_create(&__dispatch_tsd_key, _libdispatch_tsd_cleanup);
#else
	_dispatch_thread_key_create(&dispatch_priority_key, NULL);
	_dispatch_thread_key_create(&dispatch_r2k_key, NULL);
	_dispatch_thread_key_create(&dispatch_queue_key, _dispatch_queue_cleanup);
	_dispatch_thread_key_create(&dispatch_frame_key, _dispatch_frame_cleanup);
	_dispatch_thread_key_create(&dispatch_cache_key, _dispatch_cache_cleanup);
	_dispatch_thread_key_create(&dispatch_context_key, _dispatch_context_cleanup);
	_dispatch_thread_key_create(&dispatch_pthread_root_queue_observer_hooks_key,
			NULL);
	_dispatch_thread_key_create(&dispatch_basepri_key, NULL);
#if DISPATCH_INTROSPECTION
	_dispatch_thread_key_create(&dispatch_introspection_key , NULL);
#elif DISPATCH_PERF_MON
	_dispatch_thread_key_create(&dispatch_bcounter_key, NULL);
#endif
	_dispatch_thread_key_create(&dispatch_wlh_key, _dispatch_wlh_cleanup);
	_dispatch_thread_key_create(&dispatch_voucher_key, _voucher_thread_cleanup);
	_dispatch_thread_key_create(&dispatch_deferred_items_key,
			_dispatch_deferred_items_cleanup);
#endif

#if DISPATCH_USE_RESOLVERS // rdar://problem/8541707
	_dispatch_main_q.do_targetq = _dispatch_get_default_queue(true);
#endif

	_dispatch_queue_set_current(&_dispatch_main_q);
	_dispatch_queue_set_bound_thread(&_dispatch_main_q);

#if DISPATCH_USE_PTHREAD_ATFORK
	(void)dispatch_assume_zero(pthread_atfork(dispatch_atfork_prepare,
			dispatch_atfork_parent, dispatch_atfork_child));
#endif
	_dispatch_hw_config_init();
	_dispatch_time_init();
	_dispatch_vtable_init();
	_os_object_init();
	_voucher_init();
	_dispatch_introspection_init();
}
```

## 主队列的创建

`_dispatch_main_q`是一个结构体，包含了主队列的基本信息，包括主队列的对象`do_targetq`,主队列的名字`dq_label`等等

```objc
struct dispatch_queue_static_s _dispatch_main_q = {
	DISPATCH_GLOBAL_OBJECT_HEADER(queue_main),
#if !DISPATCH_USE_RESOLVERS
	.do_targetq = _dispatch_get_default_queue(true),
#endif
	.dq_state = DISPATCH_QUEUE_STATE_INIT_VALUE(1) |
			DISPATCH_QUEUE_ROLE_BASE_ANON,
	.dq_label = "com.apple.main-thread",
	.dq_atomic_flags = DQF_THREAD_BOUND | DQF_WIDTH(1),
	.dq_serialnum = 1,
};
```

`libdispatch_init`函数中初始化了`_dispatch_main_q`，并绑定了主线程。

```objc
#if DISPATCH_USE_RESOLVERS // rdar://problem/8541707
	_dispatch_main_q.do_targetq = _dispatch_get_default_queue(true);
#endif

	_dispatch_queue_set_current(&_dispatch_main_q);
	_dispatch_queue_set_bound_thread(&_dispatch_main_q);
```

获取主队列`dispatch_get_main_queue`

```objc
// 从_dispatch_main_q 中获取主队列对象
dispatch_queue_main_t
dispatch_get_main_queue(void)
{
	return DISPATCH_GLOBAL_OBJECT(dispatch_queue_main_t, _dispatch_main_q);
}
```


## 队列的创建 `dispatch_queue_create`

`dispatch_queue_create` 创建的队列可以称为**私有队列**。**主队列** 或者 **dispatch_global_queue** 获取的队列是全局共享的，生命周期由系统维护。**私有队列**由开发者去维护队列的生命周期。

`dispatch_queue_create` 可以创建串行队列和并发队列。

```objc
/**
 * label 
 * attr 队列的类型 DISPATCH_QUEUE_SERIAL/DISPATCH_QUEUE_CONCUREENT
 **/
dispatch_queue_t
dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)
{
	return _dispatch_lane_create_with_target(label, attr,
			DISPATCH_TARGET_QUEUE_DEFAULT, true);
}
```

`_dispatch_lane_create_with_target` 方法是队列创建的具体实现。

```objc

DISPATCH_NOINLINE
static dispatch_queue_t
_dispatch_lane_create_with_target(const char *label, dispatch_queue_attr_t dqa,
		dispatch_queue_t tq, bool legacy)
{
	dispatch_queue_attr_info_t dqai = _dispatch_queue_attr_to_info(dqa);

	//
	// Step 1: Normalize arguments (qos, overcommit, tq)
    // 为相关参数赋值 qos，overcommit，tq
	//

	dispatch_qos_t qos = dqai.dqai_qos;
#if !HAVE_PTHREAD_WORKQUEUE_QOS
	if (qos == DISPATCH_QOS_USER_INTERACTIVE) {
		dqai.dqai_qos = qos = DISPATCH_QOS_USER_INITIATED;
	}
	if (qos == DISPATCH_QOS_MAINTENANCE) {
		dqai.dqai_qos = qos = DISPATCH_QOS_BACKGROUND;
	}
#endif // !HAVE_PTHREAD_WORKQUEUE_QOS

	_dispatch_queue_attr_overcommit_t overcommit = dqai.dqai_overcommit;
	if (overcommit != _dispatch_queue_attr_overcommit_unspecified && tq) {
		if (tq->do_targetq) {
			DISPATCH_CLIENT_CRASH(tq, "Cannot specify both overcommit and "
					"a non-global target queue");
		}
	}

	if (tq && dx_type(tq) == DISPATCH_QUEUE_GLOBAL_ROOT_TYPE) {
		// Handle discrepancies between attr and target queue, attributes win
		if (overcommit == _dispatch_queue_attr_overcommit_unspecified) {
			if (tq->dq_priority & DISPATCH_PRIORITY_FLAG_OVERCOMMIT) {
				overcommit = _dispatch_queue_attr_overcommit_enabled;
			} else {
				overcommit = _dispatch_queue_attr_overcommit_disabled;
			}
		}
		if (qos == DISPATCH_QOS_UNSPECIFIED) {
			qos = _dispatch_priority_qos(tq->dq_priority);
		}
		tq = NULL;
	} else if (tq && !tq->do_targetq) {
		// target is a pthread or runloop root queue, setting QoS or overcommit
		// is disallowed
		if (overcommit != _dispatch_queue_attr_overcommit_unspecified) {
			DISPATCH_CLIENT_CRASH(tq, "Cannot specify an overcommit attribute "
					"and use this kind of target queue");
		}
	} else {
		if (overcommit == _dispatch_queue_attr_overcommit_unspecified) {
			// Serial queues default to overcommit!
			overcommit = dqai.dqai_concurrent ?
					_dispatch_queue_attr_overcommit_disabled :
					_dispatch_queue_attr_overcommit_enabled;
		}
	}
	if (!tq) {
		tq = _dispatch_get_root_queue(
				qos == DISPATCH_QOS_UNSPECIFIED ? DISPATCH_QOS_DEFAULT : qos,
				overcommit == _dispatch_queue_attr_overcommit_enabled)->_as_dq;
		if (unlikely(!tq)) {
			DISPATCH_CLIENT_CRASH(qos, "Invalid queue attribute");
		}
	}

	//
	// Step 2: Initialize the queue
    // 初始化队列
	//

	if (legacy) {
		// if any of these attributes is specified, use non legacy classes
		if (dqai.dqai_inactive || dqai.dqai_autorelease_frequency) {
			legacy = false;
		}
	}

	const void *vtable;
	dispatch_queue_flags_t dqf = legacy ? DQF_MUTABLE : 0;
	if (dqai.dqai_concurrent) {
		vtable = DISPATCH_VTABLE(queue_concurrent);
	} else {
		vtable = DISPATCH_VTABLE(queue_serial);
	}
	switch (dqai.dqai_autorelease_frequency) {
	case DISPATCH_AUTORELEASE_FREQUENCY_NEVER:
		dqf |= DQF_AUTORELEASE_NEVER;
		break;
	case DISPATCH_AUTORELEASE_FREQUENCY_WORK_ITEM:
		dqf |= DQF_AUTORELEASE_ALWAYS;
		break;
	}
	if (label) {
		const char *tmp = _dispatch_strdup_if_mutable(label);
		if (tmp != label) {
			dqf |= DQF_LABEL_NEEDS_FREE;
			label = tmp;
		}
	}

	dispatch_lane_t dq = _dispatch_object_alloc(vtable,
			sizeof(struct dispatch_lane_s));
	_dispatch_queue_init(dq, dqf, dqai.dqai_concurrent ?
			DISPATCH_QUEUE_WIDTH_MAX : 1, DISPATCH_QUEUE_ROLE_INNER |
			(dqai.dqai_inactive ? DISPATCH_QUEUE_INACTIVE : 0));

	dq->dq_label = label;
	dq->dq_priority = _dispatch_priority_make((dispatch_qos_t)dqai.dqai_qos,
			dqai.dqai_relpri);
	if (overcommit == _dispatch_queue_attr_overcommit_enabled) {
		dq->dq_priority |= DISPATCH_PRIORITY_FLAG_OVERCOMMIT;
	}
	if (!dqai.dqai_inactive) {
		_dispatch_queue_priority_inherit_from_target(dq, tq);
		_dispatch_lane_inherit_wlh_from_target(dq, tq);
	}
	_dispatch_retain(tq);
	dq->do_targetq = tq;
	_dispatch_object_debug(dq, "%s", __func__);
	return _dispatch_trace_queue_create(dq)._dq;
}

```

- 初始化必要的参数
    
      qos 队列的优先级
      overcommit 
      tq
      vtable 创建的队列的类型 OS_dispatch_queue_concurrent_class/OS_dispatch_queue_serial_class

- 为队列对象分配内存

   ```objc
   // vtable 队列的类型
   dispatch_lane_t dq = _dispatch_object_alloc(vtable,
			sizeof(struct dispatch_lane_s));

    void * _dispatch_object_alloc(const void *vtable, size_t size) {
        #if OS_OBJECT_HAVE_OBJC1
	    const struct dispatch_object_vtable_s *_vtable = vtable;
	    dispatch_object_t dou;
	    dou._os_obj = _os_object_alloc_realized(_vtable->_os_obj_objc_isa, size);
	    dou._do->do_vtable = vtable;
	    return dou._do;
        #else
	    return _os_object_alloc_realized(vtable, size);
        #endif
    }

    inline _os_object_t _os_object_alloc_realized(const void *cls, size_t size)
    {
        _os_object_t obj;
	    dispatch_assert(size >= sizeof(struct _os_object_s));
	    while (unlikely(!(obj = calloc(1u, size)))) {
		    _dispatch_temporary_resource_shortage();
	    }
        // 设置isa OS_dispatch_queue_concurrent_class/ OS_dispatch_queue_serial_class
	    obj->os_obj_isa = cls;
	    return obj;
    }
   ```

- 初始化队列对象
   
   ```objc
   // 初始化 设置并发数
   _dispatch_queue_init(dq, dqf, dqai.dqai_concurrent ?
			DISPATCH_QUEUE_WIDTH_MAX : 1, DISPATCH_QUEUE_ROLE_INNER |
			(dqai.dqai_inactive ? DISPATCH_QUEUE_INACTIVE : 0));
    
    // 设置label，优先级
    dq->dq_label = label;
	dq->dq_priority = _dispatch_priority_make((dispatch_qos_t)dqai.dqai_qos,
			dqai.dqai_relpri);
	if (overcommit == _dispatch_queue_attr_overcommit_enabled) {
		dq->dq_priority |= DISPATCH_PRIORITY_FLAG_OVERCOMMIT;
	}
	if (!dqai.dqai_inactive) {
		_dispatch_queue_priority_inherit_from_target(dq, tq);
		_dispatch_lane_inherit_wlh_from_target(dq, tq);
	}

    _dispatch_retain(tq);
	dq->do_targetq = tq;
   ```

- 返回队列实例

   ```objc

   // 这里可以简单理解为 return dq;
   return _dispatch_trace_queue_create(dq)._dq;

   ```

## 获取全局并发队列

`dispatch_get_global_queue`用于获取**全局并发队列**，**全局并发队列**根据优先级分为四种`dispatch_queue_priority_t`：

```c
#define DISPATCH_QUEUE_PRIORITY_HIGH 2
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
```
在底层优先级会转为不同的QOS：

```objc
static inline dispatch_qos_t
_dispatch_qos_from_queue_priority(long priority)
{
	switch (priority) {
	case DISPATCH_QUEUE_PRIORITY_BACKGROUND:      return DISPATCH_QOS_BACKGROUND;
	case DISPATCH_QUEUE_PRIORITY_NON_INTERACTIVE: return DISPATCH_QOS_UTILITY;
	case DISPATCH_QUEUE_PRIORITY_LOW:             return DISPATCH_QOS_UTILITY;
	case DISPATCH_QUEUE_PRIORITY_DEFAULT:         return DISPATCH_QOS_DEFAULT;
	case DISPATCH_QUEUE_PRIORITY_HIGH:            return DISPATCH_QOS_USER_INITIATED;
	default: return _dispatch_qos_from_qos_class((qos_class_t)priority);
	}
}
```

`dispatch_qos_t` 宏定义如下：

```c
#define DISPATCH_QOS_UNSPECIFIED        ((dispatch_qos_t)0)
#define DISPATCH_QOS_MAINTENANCE        ((dispatch_qos_t)1)
#define DISPATCH_QOS_BACKGROUND         ((dispatch_qos_t)2)
#define DISPATCH_QOS_UTILITY            ((dispatch_qos_t)3)
#define DISPATCH_QOS_DEFAULT            ((dispatch_qos_t)4)
#define DISPATCH_QOS_USER_INITIATED     ((dispatch_qos_t)5)
#define DISPATCH_QOS_USER_INTERACTIVE   ((dispatch_qos_t)6)
#define DISPATCH_QOS_MIN                DISPATCH_QOS_MAINTENANCE
#define DISPATCH_QOS_MAX                DISPATCH_QOS_USER_INTERACTIVE
#define DISPATCH_QOS_SATURATED          ((dispatch_qos_t)15)
```

**`dispatch_get_global_queue`实现**
```objc
dispatch_queue_global_t
dispatch_get_global_queue(long priority, unsigned long flags)
{
	dispatch_assert(countof(_dispatch_root_queues) ==
			DISPATCH_ROOT_QUEUE_COUNT);

	if (flags & ~(unsigned long)DISPATCH_QUEUE_OVERCOMMIT) {
		return DISPATCH_BAD_INPUT;
	}
	dispatch_qos_t qos = _dispatch_qos_from_queue_priority(priority);
#if !HAVE_PTHREAD_WORKQUEUE_QOS
	if (qos == QOS_CLASS_MAINTENANCE) {
		qos = DISPATCH_QOS_BACKGROUND;
	} else if (qos == QOS_CLASS_USER_INTERACTIVE) {
		qos = DISPATCH_QOS_USER_INITIATED;
	}
#endif
	if (qos == DISPATCH_QOS_UNSPECIFIED) {
		return DISPATCH_BAD_INPUT;
	}
	return _dispatch_get_root_queue(qos, flags & DISPATCH_QUEUE_OVERCOMMIT);
}

static inline dispatch_queue_global_t
_dispatch_get_root_queue(dispatch_qos_t qos, bool overcommit)
{
	if (unlikely(qos < DISPATCH_QOS_MIN || qos > DISPATCH_QOS_MAX)) {
		DISPATCH_CLIENT_CRASH(qos, "Corrupted priority");
	}
	return &_dispatch_root_queues[2 * (qos - 1) + overcommit];
}
```

`dispatch_get_global_queue`将根据不同的优先级从`_dispatch_root_queues`获取对应的全局并发队列作为结果返回。


## `_dispatch_root_queues` 全局并发队列数组

`_dispatch_root_queues` 是一个全局的队列数组，定义了12个全局队列，对应者不同的`dispatch_qos_t`

```objc
struct dispatch_queue_global_s _dispatch_root_queues[] = {
#define _DISPATCH_ROOT_QUEUE_IDX(n, flags) \
		((flags & DISPATCH_PRIORITY_FLAG_OVERCOMMIT) ? \
		DISPATCH_ROOT_QUEUE_IDX_##n##_QOS_OVERCOMMIT : \
		DISPATCH_ROOT_QUEUE_IDX_##n##_QOS)
#define _DISPATCH_ROOT_QUEUE_ENTRY(n, flags, ...) \
	[_DISPATCH_ROOT_QUEUE_IDX(n, flags)] = { \
		DISPATCH_GLOBAL_OBJECT_HEADER(queue_global), \
		.dq_state = DISPATCH_ROOT_QUEUE_STATE_INIT_VALUE, \
		.do_ctxt = _dispatch_root_queue_ctxt(_DISPATCH_ROOT_QUEUE_IDX(n, flags)), \
		.dq_atomic_flags = DQF_WIDTH(DISPATCH_QUEUE_WIDTH_POOL), \
		.dq_priority = flags | ((flags & DISPATCH_PRIORITY_FLAG_FALLBACK) ? \
				_dispatch_priority_make_fallback(DISPATCH_QOS_##n) : \
				_dispatch_priority_make(DISPATCH_QOS_##n, 0)), \
		__VA_ARGS__ \
	}
	_DISPATCH_ROOT_QUEUE_ENTRY(MAINTENANCE, 0,
		.dq_label = "com.apple.root.maintenance-qos",
		.dq_serialnum = 4,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(MAINTENANCE, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.maintenance-qos.overcommit",
		.dq_serialnum = 5,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(BACKGROUND, 0,
		.dq_label = "com.apple.root.background-qos",
		.dq_serialnum = 6,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(BACKGROUND, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.background-qos.overcommit",
		.dq_serialnum = 7,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(UTILITY, 0,
		.dq_label = "com.apple.root.utility-qos",
		.dq_serialnum = 8,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(UTILITY, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.utility-qos.overcommit",
		.dq_serialnum = 9,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(DEFAULT, DISPATCH_PRIORITY_FLAG_FALLBACK,
		.dq_label = "com.apple.root.default-qos",
		.dq_serialnum = 10,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(DEFAULT,
			DISPATCH_PRIORITY_FLAG_FALLBACK | DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.default-qos.overcommit",
		.dq_serialnum = 11,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INITIATED, 0,
		.dq_label = "com.apple.root.user-initiated-qos",
		.dq_serialnum = 12,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INITIATED, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.user-initiated-qos.overcommit",
		.dq_serialnum = 13,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INTERACTIVE, 0,
		.dq_label = "com.apple.root.user-interactive-qos",
		.dq_serialnum = 14,
	),
	_DISPATCH_ROOT_QUEUE_ENTRY(USER_INTERACTIVE, DISPATCH_PRIORITY_FLAG_OVERCOMMIT,
		.dq_label = "com.apple.root.user-interactive-qos.overcommit",
		.dq_serialnum = 15,
	),
};
```

我们在上文**主队列**和**私有队列**的创建过程中，都有相似的一段代码：

```objc
// 主队列

_dispatch_main_q.do_targetq = _dispatch_get_default_queue(true);
#define _dispatch_get_default_queue(overcommit) \
		_dispatch_root_queues[DISPATCH_ROOT_QUEUE_IDX_DEFAULT_QOS + \
				!!(overcommit)]._as_dq

// 私有队列
tq = _dispatch_get_root_queue(
				qos == DISPATCH_QOS_UNSPECIFIED ? DISPATCH_QOS_DEFAULT : qos,
				overcommit == _dispatch_queue_attr_overcommit_enabled)->_as_dq;
....

dq->do_targetq = tq;
```

**主队列**和**私有队列**在初始化过程中，都从`_dispatch_root_queues`中选出一个队列，设置为 `do_targetq`。

我们一般将`dispatch_queue_t`实例认作是一种OC对象，因为`dispatch_queue_t`实例前8字节的确保存队列类型的信息。但是我们在使用`dispatch_queue_t`时，不像是一般OC对象一样**发送消息**，而是C语言一般的**函数调用**。那么`dispatch_queue_t`的继承性和多态性是如何实现的呢？在相同的**函数调用**`dispatch_async/dispatch_sync`下，私有串行队列，私有并发队列，全局并发队列以及主队列的差异又是如何处理的呢？

**主队列**和**私有队列**的`do_targetq`就是用来构建一种类似**继承树**一般的联系。

## 队列的OC类型

- 私有的串行队列 ： `OS_dispatch_queue_serial`类型

- 私有的并发队列 ： `OS_dispatch_queue_concurrent`类型

- 全局并发队列  ： `OS_dispatch_queue_global`类型

- 主队列 ： `OS_dispatch_queue_main` 类型

我们直接通过Xcode看到不同队列的类型：全局并发队列和私有的并发队列事实上也是不同的类型。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-03%20%E4%B8%8B%E5%8D%8810.22.40.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-03%20%E4%B8%8B%E5%8D%8810.23.25.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-03%20%E4%B8%8B%E5%8D%8810.24.43.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-07-03%20%E4%B8%8B%E5%8D%8810.25.12.png)

我们直接在**libdispatch**源码中直接搜索这些类型, 只能搜索到相关符号的存在。

```c
// libdispatch.order

_OBJC_CLASS_$_OS_dispatch_queue_serial
__OS_dispatch_queue_serial_vtable
_OBJC_CLASS_$_OS_dispatch_queue_concurrent
__OS_dispatch_queue_concurrent_vtable
_OBJC_CLASS_$_OS_dispatch_queue_global
__OS_dispatch_queue_global_vtable

_OBJC_METACLASS_$_OS_dispatch_queue_serial
_OBJC_METACLASS_$_OS_dispatch_queue_concurrent
_OBJC_METACLASS_$_OS_dispatch_queue_global

``` 
`_OBJC_CLASS_$_OS_dispatch_queue_serial`和`_OBJC_METACLASS_$_OS_dispatch_queue_serial`显然是对应类和元类的符号。而`__OS_dispatch_queue_serial_vtable` 可以认为方法列表的符号。

它们在`init.c`源文件中定义为结构体类型。

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
```

`DISPATCH_VTABLE_SUBCLASS_INSTANCE`是宏定义，以`queue_serial`为例全部展开：

```c
_attribute__((section("__DATA,__objc_data"), used)) 
const struct dispatch_lane_extra_vtable_s
_OS_dispatch_queue_serial_vtable = {
	.do_type        = DISPATCH_QUEUE_SERIAL_TYPE,
	.do_dispose     = _dispatch_lane_dispose,
	.do_debug       = _dispatch_queue_debug,
	.do_invoke      = _dispatch_lane_invoke,

	.dq_activate    = _dispatch_lane_activate,
	.dq_wakeup      = _dispatch_lane_wakeup,
	.dq_push        = _dispatch_lane_push,
}
```

`dq_push(入队)`，`dq_wakeup(唤醒线程)`,`do_invoke(调用block)`,`dq_dispose(释放)`，显然是一个队列在创建，运行以及释放过程中的必要方法。我们可以把它们认为是队列的成员方法。同上文提供`do_targetq`，就构造出不同于继承树的结构：

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/OS_dispatch_queue.png)

这样的结构具体是怎样实现`dispatch_queue_t`的动态性的呢？请看下文。

## 其他

```c

// dispatch_queue_static_s结构展开

struct dispatch_queue_static_s {

    const struct dispatch_lane_vtable_s *do_vtable;      // isa 
	int volatile do_ref_cnt;                             // ref count ?
	int volatile do_xref_cnt;                            // 

	struct dispatch_lane_s *volatile do_next;
	struct dispatch_queue_s *do_targetq;
	void *do_ctxt;
	void *do_finalizer;

	struct dispatch_object_s *volatile dq_items_tail; 
	DISPATCH_UNION_LE(uint64_t volatile dq_state, 
			dispatch_lock dq_state_lock, 
			uint32_t dq_state_bits 
	)

    unsigned long dq_serialnum;
	const char *dq_label;
	DISPATCH_UNION_LE(uint32_t volatile dq_atomic_flags, 
		const uint16_t dq_width,
		const uint16_t __dq_opaque2
	);
	dispatch_priority_t dq_priority; 
	union { 
		struct dispatch_queue_specific_head_s *dq_specific_head; 
		struct dispatch_source_refs_s *ds_refs; 
		struct dispatch_timer_source_refs_s *ds_timer_refs; 
		struct dispatch_mach_recv_refs_s *dm_recv_refs; 
	}; 
	int volatile dq_sref_cnt;
	
	dispatch_unfair_lock_s dq_sidelock; 
	struct dispatch_object_s *volatile dq_items_head; 
	uint32_t dq_side_suspend_cnt
} DISPATCH_CACHELINE_ALIGN;

// dispatch_queue_s结构展开
struct dispatch_queue_s {
	
	const struct dispatch_queue_vtable_s *do_vtable,
	int volatile do_ref_cnt, 
	int volatile do_xref_cnt,
	// 以上 _OS_OBJECT_HEADER OS_OBJECT_STRUCT_HEADER

	struct dispatch_queue_s *volatile do_next; 
	struct dispatch_queue_s *do_targetq; 
	void *do_ctxt; 
	void *do_finalizer;
    // 以上 _DISPATCH_OBJECT_HEADER

	void *__dq_opaque1;
	DISPATCH_UNION_LE(uint64_t volatile dq_state,
			dispatch_lock dq_state_lock,
			uint32_t dq_state_bits
	);
	// _DISPATCH_QUEUE_CLASS_HEADER
    
	unsigned long dq_serialnum; 
	const char *dq_label; 
	DISPATCH_UNION_LE(uint32_t volatile dq_atomic_flags, 
		const uint16_t dq_width, 
		const uint16_t __dq_opaque2 
	); 
	dispatch_priority_t dq_priority; 
	union { 
		struct dispatch_queue_specific_head_s *dq_specific_head; 
		struct dispatch_source_refs_s *ds_refs; 
		struct dispatch_timer_source_refs_s *ds_timer_refs; 
		struct dispatch_mach_recv_refs_s *dm_recv_refs; 
	}; 
	int volatile dq_sref_cnt;

	// DISPATCH_QUEUE_CLASS_HEADER

} 
```


