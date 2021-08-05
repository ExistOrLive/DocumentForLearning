# Runloop的使用

## 1. Runloop对象

每一个线程都有一个与之绑定的**Runloop**对象。在**Foundation**使用`NSRunloop`类表示；在**Core Foundaiton**中使用`CFRunloopRef`表示。

**获取当前线程的Runloop对象**

```objc
// 获取当前线程的Runloop

NSRunLoop *currentRunloop = [NSRunLoop currentRunLoop];

CFRunLoopRef currentRunloopRef = CFRunLoopGetCurrent();

// 获取主线程的Runloop
NSRunLoop *mainRunloop = [NSRunLoop mainRunLoop];
CFRunLoopRef mainRunloopRef = CFRunLoopGetMain();

```

### 1.1 配置Runloop

在启动**Runloop**之前，需要给**Runloop**添加其需要监控的**Source**（包括**Timer Source**或者**Input Source**）。 

如果**Runloop**在启动之前没有添加任何的**Source**，启动后会立即结束。

**Runloop**还可以添加**Observer**,来监控其状态。

```objc
// 添加Timer Source
NSTimer *timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            NSLog(@"Hello World");
        }];
[currentRunloop addTimer:timer forMode:NSDefaultRunLoopMode];
        
CFRunLoopAddTimer([currentRunloop getCFRunLoop], (__bridge_retained CFRunLoopTimerRef)timer, kCFRunLoopDefaultMode);

// 添加port source

NSPort *port = [NSPort port];
[currentRunloop addPort:port forMode:NSDefaultRunLoopMode];


CFMessagePortContext context = {0, NULL, NULL, NULL, NULL};
Boolean shouldFreeInfo;
        
CFStringRef myPortName = CFStringCreateWithFormat(NULL, NULL, CFSTR("com.myapp.MainThread"));
        
CFMessagePortRef   myPort = CFMessagePortCreateLocal(NULL,
                       myPortName,
                       &MainThreadResponseHandler,
                       &context,
                       &shouldFreeInfo);
        
CFRunLoopSourceRef rlSource = CFMessagePortCreateRunLoopSource(NULL, myPort, 0);
        
CFRunLoopAddSource(CFRunLoopGetCurrent(), rlSource, kCFRunLoopDefaultMode);

// 添加observer
CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, true, 0, &CFRunLoopObserverCallBac, NULL);
CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
```


### 1.2 启动Runloop

对于交互式应用(iOS应用或者MacOS应用)，主线程绑定的Runloop是默认启动的，主Runloop需要处理鼠标键盘事件以及触摸事件以保证用户交互。

对于非交互式应用(命令行程序)，主Runloop将不会默认启动。

对于非主线程绑定的Runloop也不会默认启动，需要开发者显式调用代码来启动。

```objc
// 启动Runloop，可以指定Runloop的mode以及超时事件 

// 无限循环的Runloop， mode为 NSDefaultRunLoopMode
[currentRunloop run];

[currentRunloop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        
[currentRunloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];


// Core Foundation
// 设置mode 和 超时事件
SInt32    result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
```

### 1.3 退出Runloop

**Runloop** 退出循环，有两种情况：

- Runloop自动退出
   
    - Runloop启动时设置超时时间；
    - Runloop移除所有的Source会退出(主Runloop会监控系统的Source，对于开发者不可见，这些Source是无法移除的)


- 调用`RunloopStop`手动退出Runloop

### 1.4 唤醒runloop

当Runloop处理完事件时，会自动进入休眠状态。以下几种情况会唤醒Runloop

- 收到了来自**Port Input Source**的事件
- 收到了来自**Timer Source**的事件
- Runloop超时时间到了，需要唤醒Runloop，最终退出
- 显式调用`CFRunLoopWake`唤醒


## 2.线程安全和Runloop对象

`CFRunLoopRef`是线程安全，可以在某个线程中操作其他线程绑定的`CFRunLoopRef`

`NSRunLoop`不是线程安全，不可以在某个线程中操作其他线程绑定的`NSRunLoop`。

尽管`CFRunLoopRef`是线程安全的，仍然不建议在其他的线程中操作`CFRunLoopRef`


[Runloop](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html#//apple_ref/doc/uid/10000057i-CH16-SW22)