# GCD : (Grand Central Dispatch)

> GCD是异步执行任务的技术之一。一般将应用程序中记述的线程管理用的代码在系统级去实现。开发者只需要将定义好的任务追加到适当的Dispatch Queue中，GCD就能生成必要的线程并计划执行任务

线程管理作为系统的一部分实现，可以统一管理，也可以执行任务，这样就比以前更加有效率

例： 

```
   dispatch_async(queue,^{
   
        /*
           子线程
        */
        
       dispatch_async(dispatch_get_main_queue(),^{
       
       	/*
       	  主线程
        */
        
       });
   
   });
````
   
> NSObject类 提供的` performSelectorInBackground：withObject：`
   `performSelectorOnMainThread：withObject：`
   也可以实现异步
   
   
1个cpu执行的CPU命令队列为一条无分叉的路径

## 多线程常遇到的问题：
  
  - 线程同步 ： 多个线程更新相同的资源导致数据不一致（数据竞争）

  - 死锁    ： 停止等待线程会导致多个线程相互持久等待（死锁）

  - 线程太多会消耗大量内存
  

## GCD的API

### `dispatch_queue_t` 
  
开发者要做的只是定义想要执行的任务并追加到适当的Dispatch Queue
  
Dispatch Queue :

- Serial Dispatch Queue ： 等待现在执行的处理结束        （串行）
- Concurrent Dispatch Queue ： 不等待现在执行中的处理结束 (并行)

> 不同Serial Dispatch Queue 之间是并发的; Concurrent Dispatch Queue 中任务之间是并发的;Concurrent Dispatch Queue 并发执行的处理数量，取决于当前的系统状态;基于Dispatch Queue中的处理数，CPU核数及cpu负荷来决定当前的并行数

#### 创建dispatch queue
 
 1. 通过GCD的API生成
    dispatch_queue_t queue = dispatch_queue_create("com.example.gcd.myserialdispatchqueue",NULL);
    优先级默认
    
    参数1: 指定 dispatch queue 的名称
    参数2: 指定 dispatch queue 的类型  NULL（DISPATCH_QUEUE_SRERIAL）  DISPATCH_QUEUE_CONCURRENT
    
 注意：
    dispatch queue 必须由程序员是负责释放，Dispatch Queue并没有作为OC类来处理的技术(IOS<=6.0)
    dispatch_release(queue);
    dispatch_retain(queue);
    
 2. 获取系统标准提供的Dispatch Queue
    dispatch_get_main_queue() // 主线程 ，serial dispatch queue 
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); // 默认是获取ConCurrent Dispatch Queue
    
    参数1 ： DISPATCH_QUEUE_PRIORITY_HIGH       高优先级
            DISPATCH_QUEUE_PRIORITY_DEFAULT    默认优先级
            DISPATCH_QUEUE_PRIORITY_LOW
            DISPATCH_QUEUE_PRIORITY_BACKGROUND 
    queue的执行优先级将决定相应线程的执行优先级
      
    这两个函数都是获取系统提供的dispatch queue ，不用主动去释放资源
    
 3. 修改执行优先级
    dispatch_set_target_queue()
    
    例：
    dispatch_queue_t myserialdispatchqueue = dispatch_queue_create("com.example.gcd.MySerial",NULL);
    
    dispatch_queue_t globalDispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUNd,0);
       
    dispatch_set_target_queue(myserialdispatchqueue, globaldispatchqueue);
    
    参数1 ：要变更优先级的队列 (不可指定main dispatch queue 和 global dispatch queue,不会报错，但是无效)
    参数2 : 目标优先级的队列
    将队列1优先级改为与队列2一致。 
    
    注意：
    将多个并发执行的dispactch queue指定目标为一个serial dispatch queue，那么原本并发执行的队列及队列中的任务都会在
    目标serial dispatch queue的线程中串行执行。
    
    

## Dispatch 

> Dispatch 是一个简单又有效的API实现并发

> Dispatch 提供了先入先出的队列，用于提交block。提交到队列中的block将会在完全在系统管理的线程池中调用。block具体在哪一个线程中调用是无法确定的。但是提交到队列中的block一定会在某个时刻被调用

> 当多个队列有要处理的块时，`系统可以自由地分配额外的线程`并发地调用这些块。当队列变为空时，这些`线程将被自动释放`。


## dispatch_queue_global_t

> dispatch_queue_global_t 是一个`围绕系统线程池的抽象`，会调用提交到queue中的任务。

> dispatch_queue_global_t在系统管理的线程池之上`提供多个优先级`。

> `系统会根据需求和系统负载决定分配的线程数量`。dispatch_queue_global_t努力维持资源的高质量的并发，当大多数工作线程阻塞时，会创建新的线程。


## dispatch_queue_serial_t


## dispatch_set_target_queue

> 当调度队列在创建时，没有指定Qos和相关的优先级，队列的Qos类型继承于它的target queue。



```c

 /*!
 * @function dispatch_set_target_queue
 *
 * @abstract
 * Sets the target queue for the given object.
 *
 * @discussion
 * An object's target queue is responsible for processing the object.
 *
 * When no quality of service class and relative priority is specified for a
 * dispatch queue at the time of creation, a dispatch queue's quality of service
 * class is inherited from its target queue. The dispatch_get_global_queue()
 * function may be used to obtain a target queue of a specific quality of
 * service class, however the use of dispatch_queue_attr_make_with_qos_class()
 * is recommended instead.
 *
 * Blocks submitted to a serial queue whose target queue is another serial
 * queue will not be invoked concurrently with blocks submitted to the target
 * queue or to any other queue with that same target queue.
 *
 * The result of introducing a cycle into the hierarchy of target queues is
 * undefined.
 *
 * A dispatch source's target queue specifies where its event handler and
 * cancellation handler blocks will be submitted.
 *
 * A dispatch I/O channel's target queue specifies where where its I/O
 * operations are executed. If the channel's target queue's priority is set to
 * DISPATCH_QUEUE_PRIORITY_BACKGROUND, then the I/O operations performed by
 * dispatch_io_read() or dispatch_io_write() on that queue will be
 * throttled when there is I/O contention.
 *
 * For all other dispatch object types, the only function of the target queue
 * is to determine where an object's finalizer function is invoked.
 *
 * In general, changing the target queue of an object is an asynchronous
 * operation that doesn't take effect immediately, and doesn't affect blocks
 * already associated with the specified object.
 *
 * However, if an object is inactive at the time dispatch_set_target_queue() is
 * called, then the target queue change takes effect immediately, and will
 * affect blocks already associated with the specified object. After an
 * initially inactive object has been activated, calling
 * dispatch_set_target_queue() results in an assertion and the process being
 * terminated.
 *
 * If a dispatch queue is active and targeted by other dispatch objects,
 * changing its target queue results in undefined behavior.
 *
 * @param object
 * The object to modify.
 * The result of passing NULL in this parameter is undefined.
 *
 * @param queue
 * The new target queue for the object. The queue is retained, and the
 * previous target queue, if any, is released.
 * If queue is DISPATCH_TARGET_QUEUE_DEFAULT, set the object's target queue
 * to the default target queue for the given object type.
 */

void
dispatch_set_target_queue(dispatch_object_t object,
		dispatch_queue_t _Nullable queue);
```



# Tip

## 避免过多的线程创建

1. `在设计用于并发执行的任务时，请勿调用会阻塞当前执行线程的方法`。当并发队列调度的任务阻塞线程时，系统会创建其他线程来运行其他排队的并发任务。如果有太多任务阻塞，则系统可能会耗尽您应用程序的线程。

2. 应用程序消耗太多线程的另一种方法是创建太多私有并发调度队列。因为每个调度队列都消耗线程资源，所以创建其他并发调度队列会加剧线程使用问题。`代替创建私有并发队列，将任务提交到全局并发调度队列之一`。

3. `对于串行任务，请将串行队列的目标设置为全局并发队列之一`。这样，您可以在最小化创建线程的单独队列数量的同时，维护队列的序列化行为。




