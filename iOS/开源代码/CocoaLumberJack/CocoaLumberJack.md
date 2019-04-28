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








[1]: pic/CocoaLumberjackClassDiagram.png
[2]: pic/引入日志模块.png