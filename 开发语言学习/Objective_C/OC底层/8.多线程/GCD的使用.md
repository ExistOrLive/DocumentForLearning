# GCD的使用

## 1. `dispatch_queue_t`

`dispatch_queue` 是由苹果提出的并发技术。在线程之上，提出**队列**和**任务**的概念。对于开发者而言，不需要管理线程的生命周期，不需要管理线程的同步和通信。这一切都被隐藏于**队列**之下，**队列**分为并发队列和串行队列，开发者的工作就是按需要创建队列，向队列中添加任务代码块，并指定异步执行，还是同步执行。

- 相对于直接使用thread开发，使用GCD更加的方便

- 开发者不需要关注线程的创建和销毁，这一切由系统管理，会更加的高效

### 1.1 串行队列 和 并发队列

**队列** 是先入先出的数据结构，先入队的任务会先被执行。 **队列** 又分为 **串行队列** 和 **并发队列**。

**串行队列** : 任务按照入队的顺序逐个调用，但同一段时间内只有一个任务在执行

**并发队列** : 任务按照入队的顺序逐个调用，同一段时间内可以并发执行多个任务

**主队列** : 主队列是特殊的全局唯一的串行队列，与主线程绑定，与main runloop 协同工作

```objc
// 系统提供四个全局的并发队列，这四个队列仅优先级不同
// 这四个队列的生命周期将由系统来管理
/** 获取全局的并发队列
 *  DISPATCH_QUEUE_PRIORITY_HIGH:         QOS_CLASS_USER_INITIATED
 *  DISPATCH_QUEUE_PRIORITY_DEFAULT:      QOS_CLASS_DEFAULT
 *  DISPATCH_QUEUE_PRIORITY_LOW
 *  DISPATCH_QUEUE_PRIORITY_BACKGROUND:   QOS_CLASS_BACKGROUND
 */
dispatch_queue_global_t
dispatch_get_global_queue(intptr_t identifier, uintptr_t flags);


/* 创建新的队列而非从获取全局共享的队列
 * @param label  队列的名字
 * @param attr   DISPATCH_QUEUE_SERIAL/DISPATCH_QUEUE_CONCURRENT
 **/ 

dispatch_queue_t
dispatch_queue_create(const char *_Nullable label,
		dispatch_queue_attr_t _Nullable attr);

/**
 *  返回当前任务执行的队列
 **/
dispatch_queue_t
dispatch_get_current_queue(void);

/**
 * 获取主队列
 **/
dispatch_queue_main_t
dispatch_get_main_queue(void)
```

### 1.2 操作队列和任务

```objc

void
dispatch_async(dispatch_queue_t queue, dispatch_block_t block);

void
dispatch_sync(dispatch_queue_t queue, DISPATCH_NOESCAPE dispatch_block_t block);


void
dispatch_resume(dispatch_object_t object);

void
dispatch_suspend(dispatch_object_t object);
```

### 1.3 使用串行队列实现互斥

不同与基于线程的并发编程，GCD的中互斥使用串行队列实现。串行队列可以保证加入队列的任务可以互斥访问共享资源。

基于互斥锁的实现，不论是在有竞争还是没有竞争的场景，都会陷入内核；而串行队列主要工作在应用层，只有在必要的时候才发出系统调用。

```objc
        dispatch_queue_t serialQueue = dispatch_queue_create("serialQueue", DISPATCH_QUEUE_SERIAL);
        
        dispatch_block_t block = ^{
          // 访问共享资源
        };
    
        dispatch_async(serialQueue,block);
        dispatch_async(serialQueue,block);
        dispatch_async(serialQueue,block);
```

## 2. 任务Block

- 任务Block并不是在加入队列中时候调用，因此要注意block捕获变量和对象的生命周期。捕获的标量或结构体类型将直接拷贝（不要捕获大结构体类型）；如果捕获指针，记得持有捕获指针指向的对象(OC/C++)

- 任务Block 在加入队列时会被拷贝，执行结束后将被释放



## 3. `dispatch_group_t` 调度组

```objc
dispatch_group_t
dispatch_group_create(void);

void
dispatch_group_async(dispatch_group_t group,
	dispatch_queue_t queue,
	dispatch_block_t block);

intptr_t
dispatch_group_wait(dispatch_group_t group, dispatch_time_t timeout);

// 注册block，当group中所有的任务完成回调
// 记住在所有任务都添加到group中才调用
void
dispatch_group_notify(dispatch_group_t group,
	dispatch_queue_t queue,
	dispatch_block_t block);

// dispatch_group_enter 与 dispatch_group_leave 一一对应
void
dispatch_group_enter(dispatch_group_t group);

void
dispatch_group_leave(dispatch_group_t group);
```

`dispatch_group_t`可以监控多个任务的完成。当多个任务完成后，执行一个同步任务。

```objc
dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
dispatch_group_t group = dispatch_group_create();

for(int i = 0; i < 100; i++){
dispatch_group_async(group, queue, ^{
   // Some asynchronous work
});
}


// When you cannot make any more forward progress,
// wait on the group to block the current thread.
// 等待所有任务都完成
dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

```

## 4. `dispatch_semaphore_t`信号量

`dispatch_semaphores_t` 与传统的信号量`sem_t`很相似，但是更加的高效。

`sem_t`原本的设计就是进程间的同步机制，因此`sem_t`的`wait`和`signal`操作不论是否存在竞争，都会陷入内核。

`dispatch_semaphores_t` 是进程内线程间的同步机制。只有在竞争的情况下，才会陷入内核。

### 4.1 利用`dispatch_semaphores_t`信号量实现互斥

```objc
dispatch_semaphore_t lock = dispatch_semaphore_create(1);
        
dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
        
// critical code 
        
dispatch_semaphore_signal(lock);
```

### 4.2 利用`dispatch_semaphores_t`实现thread join

某个任务需要等待另一个任务执行完成

```objc
// 任务1要等待任务2执行完成才继续执行

dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL),^{
    
    // 等待任务2 执行完成
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
            
    // ........ 任务1 执行体
            
    NSLog(@"任务1完成");
}) ;
        
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^{
           
    // ........ 任务2 执行体
            
    NSLog(@"任务2完成");
            
   // 通知任务1 已经执行完成
   dispatch_semaphore_signal(sem);
});
```

### 4.3 利用`dispatch_semaphores_t`管理有限的资源

```objc
// 100个并发任务， 但是只有五个资源

dispatch_semaphore_t fd_sema = dispatch_semaphore_create(5);
        
dispatch_apply(100, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL), ^(size_t index) {
  
  dispatch_semaphore_wait(fd_sema, DISPATCH_TIME_FOREVER);
            
  // 访问资源
            
  dispatch_semaphore_signal(fd_sema);
            
});
```

## 5. `dispatch_source_t` 

`dispatch_source_t`会为特定的系统事件创建通知。你可以使用`dispatch_source_t`监控进程通知，信号量以及描述符事件等。当系统事件发生，`dispatch_source_t`会将你注册的处理代码块异步加入到指定的队列处理。

- Timer dispatch sources ：定时通知

- Signal dispatch sources ： 收到Unix信号

- Descriptor sources ： 通知文件和socket操作

    - 可以读取到数据
    - 可以写数据
    - 文件删除，移动和重命名
    - 文件元信息修改

- Process dispatch sources： 通知进程相关的事件

    - 进程推出
    - 进程调用fork/exec
    - 当信号发送到某个进程

- Mach port dispatch sources： Mach相关事件



## 6. 栅栏函数

`dispatch_barrier_async`和`dispatch_barrier_sync`可以理解为将并发变为串行的函数。 通过栅栏函数添加的任务会等待之前的任务全部完成，之后的任务也会等待栅栏函数添加的任务完成。

栅栏函数只能用于并发队列，并发队列必须是手动创建的，而不是通过`dispatch_get_global_queue`获取的。`dispatch_get_global_queue`获取的队列全局共享，其他无关的线程也会使用。



[Concurrency Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/ConcurrencyProgrammingGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008091-CH1-SW1)

[Threading Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/Introduction/Introduction.html#//apple_ref/doc/uid/10000057i-CH1-SW1)