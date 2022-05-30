# 锁的底层实现之NSLock/NSCondition/NSConditionLock

 有如下的示例代码，在100个并发中修改共享变量`array`，发生`EXC_BAD_ACCESS`错误。

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-12%20%E4%B8%8B%E5%8D%886.50.07.png)

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-12%20%E4%B8%8B%E5%8D%886.49.30.png)

在OC/Swift代码中,简单的赋值操作其实并不是单纯的赋值，涉及到ARC的内存管理。

```objc
// ARC
self.array = [NSMutableArray alloc] init];

// MRC
[self.array release];
self.array = [NSMutableArray alloc] init];

```

示例中显然是因为再次释放了已经销毁的内存，这是多个并发间没有保证共享资源的互斥访问引起的,最简单的就是通过同步锁保证同步即可

## 1. NSLock

```objc
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    self.lock = [[NSLock alloc] init];
    
    for(int i = 0; i < 100; i++){
        dispatch_async(queue, ^{
            for(int j = 0; j < 10 ; j++){
                [self.lock lock];
                self.array = [[NSMutableArray alloc] init];
                [self.lock unlock];
                NSLog(@"dsa");
            }
        });
    }
```

我们通过符号断点监听了`-[NSLock lock]`和`-[NSLock unlock]`方法。

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-12%20%E4%B8%8B%E5%8D%887.01.53.png)

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-12%20%E4%B8%8B%E5%8D%887.07.44.png)

可以看到`pthread_mutex_t`相关的符号，因此可以确定`NSLock`底层就是利用`pthread_mutex_t`实现的。

OC的`Foundation`并没有开源，但是可以通过开源的[Swift Foundation](https://github.com/apple/swift-corelibs-foundation)一探究竟。

```swift
open class NSLock: NSObject, NSLocking {
    internal var mutex = _MutexPointer.allocate(capacity: 1)
#if os(macOS) || os(iOS) || os(Windows)
    private var timeoutCond = _ConditionVariablePointer.allocate(capacity: 1)
    private var timeoutMutex = _MutexPointer.allocate(capacity: 1)
#endif

    public override init() {
#if os(Windows)
        InitializeSRWLock(mutex)
        InitializeConditionVariable(timeoutCond)
        InitializeSRWLock(timeoutMutex)
#else
        pthread_mutex_init(mutex, nil)
#if os(macOS) || os(iOS)
        pthread_cond_init(timeoutCond, nil)
        pthread_mutex_init(timeoutMutex, nil)
#endif
#endif
    }
    
    deinit {
#if os(Windows)
        // SRWLocks do not need to be explicitly destroyed
#else
        pthread_mutex_destroy(mutex)
#endif
        mutex.deinitialize(count: 1)
        mutex.deallocate()
#if os(macOS) || os(iOS) || os(Windows)
        deallocateTimedLockData(cond: timeoutCond, mutex: timeoutMutex)
#endif
    }
    
    open func lock() {
#if os(Windows)
        AcquireSRWLockExclusive(mutex)
#else
        pthread_mutex_lock(mutex)
#endif
    }

    open func unlock() {
#if os(Windows)
        ReleaseSRWLockExclusive(mutex)
        AcquireSRWLockExclusive(timeoutMutex)
        WakeAllConditionVariable(timeoutCond)
        ReleaseSRWLockExclusive(timeoutMutex)
#else
        pthread_mutex_unlock(mutex)
#if os(macOS) || os(iOS)
        // Wakeup any threads waiting in lock(before:)
        pthread_mutex_lock(timeoutMutex)
        pthread_cond_broadcast(timeoutCond)
        pthread_mutex_unlock(timeoutMutex)
#endif
#endif
    }
}
```


## NSConditon

```objc
open class NSCondition: NSObject, NSLocking {
    internal var mutex = _MutexPointer.allocate(capacity: 1)
    internal var cond = _ConditionVariablePointer.allocate(capacity: 1)

    public override init() {
#if os(Windows)
        InitializeSRWLock(mutex)
        InitializeConditionVariable(cond)
#else
        pthread_mutex_init(mutex, nil)
        pthread_cond_init(cond, nil)
#endif
    }
        deinit {
#if os(Windows)
        // SRWLock do not need to be explicitly destroyed
#else
        pthread_mutex_destroy(mutex)
        pthread_cond_destroy(cond)
#endif
        mutex.deinitialize(count: 1)
        cond.deinitialize(count: 1)
        mutex.deallocate()
        cond.deallocate()
    }
    
    open func lock() {
#if os(Windows)
        AcquireSRWLockExclusive(mutex)
#else
        pthread_mutex_lock(mutex)
#endif
    }
    
    open func unlock() {
#if os(Windows)
        ReleaseSRWLockExclusive(mutex)
#else
        pthread_mutex_unlock(mutex)
#endif
    }

        open func wait() {
#if os(Windows)
        SleepConditionVariableSRW(cond, mutex, WinSDK.INFINITE, 0)
#else
        pthread_cond_wait(cond, mutex)
#endif
    }

    open func wait(until limit: Date) -> Bool {
#if os(Windows)
        return SleepConditionVariableSRW(cond, mutex, timeoutFrom(date: limit), 0)
#else
        guard var timeout = timeSpecFrom(date: limit) else {
            return false
        }
        return pthread_cond_timedwait(cond, mutex, &timeout) == 0
#endif
    }
    
    open func signal() {
#if os(Windows)
        WakeConditionVariable(cond)
#else
        pthread_cond_signal(cond)
#endif
    }
    
    open func broadcast() {
#if os(Windows)
        WakeAllConditionVariable(cond)
#else
        pthread_cond_broadcast(cond)
#endif
    }
}
```

## NSConditionLock

```objc
open class NSConditionLock : NSObject, NSLocking {
    internal var _cond = NSCondition()
    internal var _value: Int
    internal var _thread: _swift_CFThreadRef?
    
    public convenience override init() {
        self.init(condition: 0)
    }
    
    public init(condition: Int) {
        _value = condition
    }

    open func lock() {
        let _ = lock(before: Date.distantFuture)
    }

    open func unlock() {
        _cond.lock()
#if os(Windows)
        _thread = INVALID_HANDLE_VALUE
#else
        _thread = nil
#endif
        _cond.broadcast()
        _cond.unlock()
    }
    
    open var condition: Int {
        return _value
    }

    open func lock(whenCondition condition: Int) {
        let _ = lock(whenCondition: condition, before: Date.distantFuture)
    }

    open func `try`() -> Bool {
        return lock(before: Date.distantPast)
    }
    
    open func tryLock(whenCondition condition: Int) -> Bool {
        return lock(whenCondition: condition, before: Date.distantPast)
    }

    open func unlock(withCondition condition: Int) {
        _cond.lock()
#if os(Windows)
        _thread = INVALID_HANDLE_VALUE
#else
        _thread = nil
#endif
        _value = condition
        _cond.broadcast()
        _cond.unlock()
    }

    open func lock(before limit: Date) -> Bool {
        _cond.lock()
        while _thread != nil {
            if !_cond.wait(until: limit) {
                _cond.unlock()
                return false
            }
        }
#if os(Windows)
        _thread = GetCurrentThread()
#else
        _thread = pthread_self()
#endif
        _cond.unlock()
        return true
    }
    
    open func lock(whenCondition condition: Int, before limit: Date) -> Bool {
        _cond.lock()
        while _thread != nil || _value != condition {
            if !_cond.wait(until: limit) {
                _cond.unlock()
                return false
            }
        }
#if os(Windows)
        _thread = GetCurrentThread()
#else
        _thread = pthread_self()
#endif
        _cond.unlock()
        return true
    }
    
    open var name: String?
}
```
