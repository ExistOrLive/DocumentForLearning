# Dispatch_once

**Dispatch_once** 是 GCD 提供的一种实现单例模式的手段，保存代码块即使在多线程的场景全局仅执行一次。

```objc

void
dispatch_once(dispatch_once_t *val, dispatch_block_t block)
{
	dispatch_once_f(val, block, _dispatch_Block_invoke(block));
}


void
dispatch_once_f(dispatch_once_t *val, void *ctxt, dispatch_function_t func)
{
	dispatch_once_gate_t l = (dispatch_once_gate_t)val;

#if !DISPATCH_ONCE_INLINE_FASTPATH || DISPATCH_ONCE_USE_QUIESCENT_COUNTER
	uintptr_t v = os_atomic_load(&l->dgo_once, acquire);
	if (likely(v == DLOCK_ONCE_DONE)) {
		return;
	}
#if DISPATCH_ONCE_USE_QUIESCENT_COUNTER
	if (likely(DISPATCH_ONCE_IS_GEN(v))) {
		return _dispatch_once_mark_done_if_quiesced(l, v);
	}
#endif
#endif
	if (_dispatch_once_gate_tryenter(l)) {
		return _dispatch_once_callout(l, ctxt, func);
	}
	return _dispatch_once_wait(l);
}


```

1. 首先通过系统提供的原子操作`os_atomic_load`读取flag`l->dgo_once`,如果`flag`为 `DLOCK_ONCE_DONE`, 则直接 return 。（短路原则，绝大部分调用在此返回）

```objc
	uintptr_t v = os_atomic_load(&l->dgo_once, acquire);
	if (likely(v == DLOCK_ONCE_DONE)) {
		return;
	}
```

2. `_dispatch_once_gate_tryenter` 执行原子操作`os_atomic_cmpxchg`。如果 `l->dgo_once` 等于 `DLOCK_ONCE_UNLOCKED`, 则将`_dispatch_lock_value_for_self()`赋值给`l->dgo_once`。

```objc
static inline bool
_dispatch_once_gate_tryenter(dispatch_once_gate_t l)
{ 
    // cmpxchg 比较并交换操作数  l->dgo_once 不等于 DLOCK_ONCE_UNLOCKED ，就交换
	return os_atomic_cmpxchg(&l->dgo_once, DLOCK_ONCE_UNLOCKED,
			(uintptr_t)_dispatch_lock_value_for_self(), relaxed);
}
```
3. `_dispatch_once_callout` 调用`_dispatch_client_callout`执行代码块，`_dispatch_once_gate_broadcast`将`l->dgo_once`设置为`DLOCK_ONCE_DONE`

```objc
static void
_dispatch_once_callout(dispatch_once_gate_t l, void *ctxt,
		dispatch_function_t func)
{
    // 指定代码块
	_dispatch_client_callout(ctxt, func);

    // 设置flag
	_dispatch_once_gate_broadcast(l);
}

static inline void
_dispatch_once_gate_broadcast(dispatch_once_gate_t l)
{
	dispatch_lock value_self = _dispatch_lock_value_for_self();
	uintptr_t v;
#if DISPATCH_ONCE_USE_QUIESCENT_COUNTER
	v = _dispatch_once_mark_quiescing(l);
#else
	v = _dispatch_once_mark_done(l);
#endif
	if (likely((dispatch_lock)v == value_self)) return;
	_dispatch_gate_broadcast_slow(&l->dgo_gate, (dispatch_lock)v);
}

// 交换
static inline uintptr_t
_dispatch_once_mark_done(dispatch_once_gate_t dgo)
{
	return os_atomic_xchg(&dgo->dgo_once, DLOCK_ONCE_DONE, release);
}
```
`os_atomic_xchg(&dgo->dgo_once, DLOCK_ONCE_DONE, release)` 交换 `dgo->dgo_once`和`DLOCK_ONCE_DONE`，并返回 `dgo->dgo_once`的旧值。

4. `_dispatch_once_wait` 等待状态，调用`os_atomic_rmw_loop`一直询问`dgo->dgo_once`的值，当`oldValue`等于`DLOCK_ONCE_DONE`,则调用`os_atomic_rmw_loop_give_up(return)`返回。（确保代码块已经执行完毕，才能够返回）

```objc
void
_dispatch_once_wait(dispatch_once_gate_t dgo)
{
	dispatch_lock self = _dispatch_lock_value_for_self();
	uintptr_t old_v, new_v;
	dispatch_lock *lock = &dgo->dgo_gate.dgl_lock;
	uint32_t timeout = 1;

	for (;;) {
		os_atomic_rmw_loop(&dgo->dgo_once, old_v, new_v, relaxed, {
			if (likely(old_v == DLOCK_ONCE_DONE)) {
				os_atomic_rmw_loop_give_up(return);
			}
#if DISPATCH_ONCE_USE_QUIESCENT_COUNTER
			if (DISPATCH_ONCE_IS_GEN(old_v)) {
				os_atomic_rmw_loop_give_up({
					os_atomic_thread_fence(acquire);
					return _dispatch_once_mark_done_if_quiesced(dgo, old_v);
				});
			}
#endif
			new_v = old_v | (uintptr_t)DLOCK_WAITERS_BIT;
			if (new_v == old_v) os_atomic_rmw_loop_give_up(break);
		});
		if (unlikely(_dispatch_lock_is_locked_by((dispatch_lock)old_v, self))) {
			DISPATCH_CLIENT_CRASH(0, "trying to lock recursively");
		}
#if HAVE_UL_UNFAIR_LOCK
		_dispatch_unfair_lock_wait(lock, (dispatch_lock)new_v, 0,
				DLOCK_LOCK_NONE);
#elif HAVE_FUTEX
		_dispatch_futex_wait(lock, (dispatch_lock)new_v, NULL,
				FUTEX_PRIVATE_FLAG);
#else
		_dispatch_thread_switch(new_v, flags, timeout++);
#endif
		(void)timeout;
	}
}
```

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/Dispatch_once.png)


## 注意点

```objc
@implementation SingletonA

+ (instancetype)sharedInstance {
    static SingletonA *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SingletonA alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [SingletonB sharedInstance];
    }
    return self;
}

@end

@implementation SingletonB

+ (instancetype)sharedInstance {
    static SingletonB *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SingletonB alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [SingletonA sharedInstance];
    }
    return self;
}

@end
```
以上的代码互相需要对方的单例，会导致一种情况，`SingletonA`的单例方法又调用了`SingletonA`的单例方法。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-06-30%20%E4%B8%8A%E5%8D%888.38.47.png)

报错对应到`_dispatch_once_wait`中

```objc
if (unlikely(_dispatch_lock_is_locked_by((dispatch_lock)old_v, self))) {
	DISPATCH_CLIENT_CRASH(0, "trying to lock recursively");
}
```


## 总结

`dispatch_once`的底层实现，简单来说就是通过**原子操作**访问唯一的`flag`变量。

进入 `dispatch_once` 流程有三种情况：

- `flag` == `DLOCK_ONCE_DONE` , 说明已经执行过，则直接返回

- `flag` == `DLOCK_ONCE_UNLOCK`, 说明未执行过，执行前将`flag`设置为**lock**变量,指定后将`flag`设置为`DLOCK_ONCE_DONE`

- `flag` != `DLOCK_ONCE_DONE` && `flag` != `DLOCK_ONCE_UNLOCK`, 说明此刻正有其他某个线程在执行，但未执行完。所有需要等待代码块执行，才能够返回。（如果不等待，就返回，那么返回的单例将是不安全的状态）

