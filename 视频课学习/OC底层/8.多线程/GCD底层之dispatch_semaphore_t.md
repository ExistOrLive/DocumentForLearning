# **dispatch_semaphore_t** 底层

`dispatch_semaphore_t` 相对于传统的`sem_t/semaphore_t` 更加的高效。 只有在需要线程调度的时候，才会陷入内核态。

```objc

struct dispatch_semaphore_s {
	DISPATCH_OBJECT_HEADER(semaphore);
	long volatile dsema_value;       // 当前的信号量值
	long dsema_orig;                 // 初始的信号量值
	_dispatch_sema4_t dsema_sema;
};

```

## 1. 创建信号量 

```objc
dispatch_semaphore_t
dispatch_semaphore_create(long value)
{
	dispatch_semaphore_t dsema;

	// If the internal value is negative, then the absolute of the value is
	// equal to the number of waiting threads. Therefore it is bogus to
	// initialize the semaphore with a negative value.
	if (value < 0) {
		return DISPATCH_BAD_INPUT;
	}

	dsema = _dispatch_object_alloc(DISPATCH_VTABLE(semaphore),
			sizeof(struct dispatch_semaphore_s));
	dsema->do_next = DISPATCH_OBJECT_LISTLESS;
	dsema->do_targetq = _dispatch_get_default_queue(false);
	dsema->dsema_value = value;
	_dispatch_sema4_init(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);
	dsema->dsema_orig = value;
	return dsema;
}
```


## 2. `dispatch_semaphore_wait`

通过原子操作`os_atomic_dec2o`递减`value`以保证线程安全。

当 `value < 0` 时,  `_dispatch_semaphore_wait_slow()`将调用系统调用陷入内核，阻塞线程。  

```objc

long
dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout)
{
	long value = os_atomic_dec2o(dsema, dsema_value, acquire);
	if (likely(value >= 0)) {
		return 0;
	}
	return _dispatch_semaphore_wait_slow(dsema, timeout);
}


DISPATCH_NOINLINE
static long
_dispatch_semaphore_wait_slow(dispatch_semaphore_t dsema,
		dispatch_time_t timeout)
{
	long orig;

	_dispatch_sema4_create(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);
	switch (timeout) {
	default:
		if (!_dispatch_sema4_timedwait(&dsema->dsema_sema, timeout)) {
			break;
		}
		// Fall through and try to undo what the fast path did to
		// dsema->dsema_value
	case DISPATCH_TIME_NOW:
		orig = dsema->dsema_value;
		while (orig < 0) {
			if (os_atomic_cmpxchgvw2o(dsema, dsema_value, orig, orig + 1,
					&orig, relaxed)) {
				return _DSEMA4_TIMEOUT();
			}
		}
		// Another thread called semaphore_signal().
		// Fall through and drain the wakeup.
	case DISPATCH_TIME_FOREVER:
		_dispatch_sema4_wait(&dsema->dsema_sema);
		break;
	}
	return 0;
}
```

## 3. `dispatch_semaphore_signal`

原子操作`os_atomic_inc2o`保证线程安全并递增`dsema_value`。

当 `value <= 0` 时，说明有线程阻塞，`_dispatch_semaphore_signal_slow` 会调用系统调用唤醒线程。

```objc

long
dispatch_semaphore_signal(dispatch_semaphore_t dsema)
{
	long value = os_atomic_inc2o(dsema, dsema_value, release);
	if (likely(value > 0)) {
		return 0;
	}
	if (unlikely(value == LONG_MIN)) {
		DISPATCH_CLIENT_CRASH(value,
				"Unbalanced call to dispatch_semaphore_signal()");
	}
	return _dispatch_semaphore_signal_slow(dsema);
}

DISPATCH_NOINLINE
long
_dispatch_semaphore_signal_slow(dispatch_semaphore_t dsema)
{
	_dispatch_sema4_create(&dsema->dsema_sema, _DSEMA4_POLICY_FIFO);
	_dispatch_sema4_signal(&dsema->dsema_sema, 1);
	return 1;
}

```

### 总结

`dispatch_semaphore_t` 结构体中 `long volatile dsema_value`保存信号量的值。`dsema_value`的递增递减操作由**原子操作**保证线程安全，同时也不会陷入内核态。

`_dispatch_sema4_t dsema_sema`则保存了一个传统的信号量，初始值为`0`。对`dsema_sema`的`wait/signal`的操作，将直接阻塞或唤醒线程。

```objc
typedef semaphore_t _dispatch_sema4_t;
```