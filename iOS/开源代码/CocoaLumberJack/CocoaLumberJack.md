# CocoaLumberJack 

## CocoaLumberJack 框架结构

![CocoaLumberjack框架结构][1]

## 引入CocoaLumberKJack

> 在Cocoapods中引入CocoaLumberKJack

![在cocoapods中引入日志模块][2]

> 在代码中使用 `#import <CocoaLumberjack/CocoaLumberjack.h>`

## 初始化日志模块

```
/**
 * DDTTYLogger 用于在终端和XCode控制台输出日志
 * 
 **/
[DDLog addLogger:[DDTTYLogger sharedInstance]];

/**
 * DDAbstractLogger 用于苹果系统日志中输出日志
 * 
 **/
[DDLog addLogger:[DDAbstractLogger sharedInstance]];

/**
 * DDFileLogger 用于在日志文件中输出日志
 * 
 **/  

DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
fileLogger.rollingFrequency = 24 * 60 * 60;
fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
fileLogger.maximumFileSize = 1024 * 1024 * 5;  
[DDLog addLogger:fileLogger];

```

> 我们这里主要关心`DDFileLogger`,用于在日志文件中输出日志，可以设置文件的回滚周期，最多日志文件数，日志最大容量等

> `DDLogMessage` 封装一行日志内容的OC对象

> `DDLogFormatter`可以设置输出日志的格式，将`DDLogMessage`对象转换为字符串

## 设置当前的日志flag

> DDLog 中定义了宏LOG_LEVEL_DEF,用于设置当前需要输出哪些级别的日志

```
#ifndef LOG_LEVEL_DEF
    #define LOG_LEVEL_DEF ddLogLevel
#endif
```
> `ddLogLevel`是一个需要使用者手动定义的变量，保存当前的flag

```

#ifdef DEBUG

static const DDLogLevel ddLogLevel = DDLogLevelDebug;

#else

static const DDLogLevel ddLogLevel = DDLogLevelInfo;

#endif

```


## 输出日志

```
/**
 *
 * DDLog 定义了以下的宏定义，用于便捷的写日志；同时区分了日志的等级
 **/

#define DDLogError(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_ERROR,   LOG_LEVEL_DEF, LOG_FLAG_ERROR,   0, frmt, ##__VA_ARGS__)
#define DDLogWarn(frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_WARN,    LOG_LEVEL_DEF, LOG_FLAG_WARN,    0, frmt, ##__VA_ARGS__)
#define DDLogInfo(frmt, ...)    LOG_OBJC_MAYBE(LOG_ASYNC_INFO,    LOG_LEVEL_DEF, LOG_FLAG_INFO,    0, frmt, ##__VA_ARGS__)
#define DDLogDebug(frmt, ...)   LOG_OBJC_MAYBE(LOG_ASYNC_DEBUG,   LOG_LEVEL_DEF, LOG_FLAG_DEBUG,   0, frmt, ##__VA_ARGS__)
#define DDLogVerbose(frmt, ...) LOG_OBJC_MAYBE(LOG_ASYNC_VERBOSE, LOG_LEVEL_DEF, LOG_FLAG_VERBOSE, 0, frmt, ##__VA_ARGS__)

```


## DDLog 输出日志的实现细节

- 在`DDLog`的`+initialize`中

创建一个串行队列 `_loggingQueue`,保证多线程日志(在处理器只有一个的情况下)的同步打印；

创建了一个信号量`_queueSemaphore`，传参1000，避免向队列中抛过多的打印任务(在多处理器的情况下，打印的过程是异步执行)。

```
+ (void)initialize {
    static dispatch_once_t DDLogOnceToken;
    
    dispatch_once(&DDLogOnceToken, ^{
        NSLogDebug(@"DDLog: Using grand central dispatch");
        
        _loggingQueue = dispatch_queue_create("cocoa.lumberjack", NULL);
        _loggingGroup = dispatch_group_create();
        
        void *nonNullValue = GlobalLoggingQueueIdentityKey; // Whatever, just not null
        dispatch_queue_set_specific(_loggingQueue, GlobalLoggingQueueIdentityKey, nonNullValue, NULL);
        
        _queueSemaphore = dispatch_semaphore_create(DDLOG_MAX_QUEUE_SIZE);
        
        // Figure out how many processors are available.
        // This may be used later for an optimization on uniprocessor machines.
        
        _numProcessors = MAX([NSProcessInfo processInfo].processorCount, (NSUInteger) 1);
        
        NSLogDebug(@"DDLog: numProcessors = %@", @(_numProcessors));
    });
}
```


- 调用宏定义`DDLogInfo`
   
```
/**
 *  在宏定义中过滤了等级低于ddLogLevel的日志打印
 *  然后调用 `[DDLog log: ]`
 **／ 
#define LOG_MAYBE(async, lvl, flg, ctx, fnct, frmt, ...)                       \
        do { if(lvl & flg) LOG_MACRO(async, lvl, flg, ctx, nil, fnct, frmt, ##__VA_ARGS__); } while(0)

```
- 调用`[DDLog log: ]`
  
  1、首先将日志的内容，level，flag，调用的哪个函数，哪个文件封装在`DDLogMessage`中

  2、将`DDLogMessage`
   





[1]: pic/CocoaLumberjackClassDiagram.png
[2]: pic/引入日志模块.png