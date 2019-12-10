# dispatch_source_t

> GCD 提供了一组API去监控底层系统对象的活动，（例如文件描述符，Mach Ports，信号，VFS node等等）。当某个活动发生时，自动将Event handle block提交到queue中, 即dispatch source api。


```c

/**
 * 创建diapatch_source_t
 * @param type source的类型  例如 DISPATCH_SOURCE_TYPE_TIMER 定时器 DISPATCH_SOURCE_TYPE_WRITE DISPATCH_SOURCE_TYPE_READ 文件读写
 * @param handle 根据不同类型的source不同     DISPATCH_SOURCE_TYPE_WRITE 时 为文件描述符
 * @param mask   根据不同类型的source不同
 * @param queue 当某种类型的source触发时，handler会提交到queue中执行 
 **/ 
dispatch_source_t
dispatch_source_create(dispatch_source_type_t type,
	uintptr_t handle,
	unsigned long mask,
	dispatch_queue_t _Nullable queue);


/**
 * 设置source的处理handler
 * @param source 
 * @param handler source的处理handler
 **/ 
void
dispatch_source_set_event_handler(dispatch_source_t source,
	dispatch_block_t _Nullable handler);

/**
 * 当调用dispatch_source_cancel()后，系统释放了source的底层句柄还有所有的event handler都返回后，cancellation handler会被提交到queue中
 * @param source 
 * @param handler source的处理handler
 * Tip： 对于基于文件描述符和端口的source， cancellation handler是必须的，用于安全关闭文件描述符和端口，在cancellation handler之前关闭文件描述符，会导致一个竞争的情况
 
 * Source cancellation and a cancellation handler are required for file
 * descriptor and mach port based sources in order to safely close the
 * descriptor or destroy the port.
 * Closing the descriptor or port before the cancellation handler is invoked may
 * result in a race condition. If a new descriptor is allocated with the same
 * value as the recently closed descriptor while the source's event handler is
 * still running, the event handler may read/write data to the wrong descriptors
 *
 **/ 
void
dispatch_source_set_cancel_handler(dispatch_source_t source,
	dispatch_block_t _Nullable handler);


void
dispatch_source_cancel(dispatch_source_t source);

uintptr_t
dispatch_source_get_handle(dispatch_source_t source);

unsigned long
dispatch_source_get_mask(dispatch_source_t source);

unsigned long
dispatch_source_get_data(dispatch_source_t source);

```


## DISPATCH_SOURCE_TYPE_TIMER

> `dispatch_source_set_timer`  设置timer的激活时间，时间间隔以及误差


``` C

void
dispatch_source_set_timer(dispatch_source_t source,
	dispatch_time_t start,
	uint64_t interval,
	uint64_t leeway);



        dispatch_queue_t serialQueue = dispatch_queue_create("timeQueue",0);

        dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, serialQueue);

        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0.1 * NSEC_PER_SEC);

        dispatch_source_set_event_handler(timer, ^{
           
        });

        dispatch_resume(timer);          // 激活timer



        dispatch_cancel(timer);
        timer = NULL;

```

[dispatch_source_set_timer][1]




## DISPATCH_SOURCE_TYPE_READ / DISPATCH_SOURCE_TYPE_WRITE


> 



```c

dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, socketFD, 0, socketQueue);
	
// Setup event handlers
dispatch_source_set_event_handler(readSource, ^{ @autoreleasepool {
	
	}});
	
// Setup cancel handlers
dispatch_source_set_cancel_handler(readSource, ^{
		close(socketFD);
	});
	
// 激活source
dispatch_resume(readSource);


```


[1]: https://developer.apple.com/documentation/dispatch/1385606-dispatch_source_set_timer?language=objc



