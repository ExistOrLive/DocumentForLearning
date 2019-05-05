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
    
    
     
