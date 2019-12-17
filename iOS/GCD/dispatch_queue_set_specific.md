/*!
 * @functiongroup Dispatch queue-specific contexts
 * This API allows different subsystems to associate context to a shared queue
 * without risk of collision and to retrieve that context from blocks executing
 * on that queue or any of its child queues in the target queue hierarchy.
 */



# dispatch_queue_set_specific

```objc
/**
 * @abstract
 * Associates a subsystem-specific context with a dispatch queue, for a key
 * unique to the subsystem.
 **/ 

void
dispatch_queue_set_specific(dispatch_queue_t queue, const void *key,
		void *_Nullable context, dispatch_function_t _Nullable destructor);

queue: 

key : 通常是子系统静态变量的指针， 键只作为指针进行比较，并且从不取消引用。不建议直接传递字符串常量。 当设置为nil时，设置context会被忽略

context : 

destructor :  当同一个key设置了新的context或者queue被释放时，在默认优先级的并发队列中调用

```




# dispatch_get_specific


```objc

void *_Nullable
dispatch_queue_get_specific(dispatch_queue_t queue, const void *key);


/**
 * 返回当前queue中key对应的context或者当前queue的target queue中key对应的context， 如果当前queue是globel concurrent queue 将返回nil
 **/ 
void *_Nullable
dispatch_get_specific(const void *key);

```

## 应用 

用于标记某个串行队列，规避同步调用串行队列带来的死锁问题：

```objc
    
    IsOnSocketQueueOrTargetQueueKey = &IsOnSocketQueueOrTargetQueueKey;
		
	void *nonNullUnusedPointer = (__bridge void *)self;
	dispatch_queue_set_specific(socketQueue, IsOnSocketQueueOrTargetQueueKey, nonNullUnusedPointer, NULL);


    // 判断当前queue 
	if (dispatch_get_specific(IsOnSocketQueueOrTargetQueueKey))
	{
		[self closeWithError:nil];
	}
	else
	{
		dispatch_sync(socketQueue, ^{
			[self closeWithError:nil];
		});
	}
	

```



[DDLog][1]
[GCDAsyncSocketManager][2]


[1]: https://github.com/CocoaLumberjack/CocoaLumberjack/blob/master/Sources/CocoaLumberjack/DDLog.m

[2]: https://github.com/Yuzeyang/GCDAsyncSocketManager/blob/master/Pods/CocoaAsyncSocket/GCD/GCDAsyncSocket.m


