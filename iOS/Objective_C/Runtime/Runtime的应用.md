# Runtime的应用

## 置换方法的具体实现

> 系统的API和静态库的方法已经编译完成，我们一般无法修改。但是通过Runtime可以系统的方法实现，达到修改系统方法的效果。置换方法的实现一般有以下几种应用：

- 在已有代码或系统API中埋点（打印日志，或添加数据采集），这样可以观察代码运行的耗时，和系统API的调用过程

  [参考demo][1]

- 异常保护

  重写NSObject的forwardInvocation:方法，避免unrecognized selector sent to instance 异常。

  重写NSArray的objectAtIndex方法，必须数组越界的异常

  [参考demo][2]

### 主要方法

```
+ (void) load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        /**
         * class_getInstanceMethod
         * 获取的方法的Method实例
         **/
        Method sourceViewDidload = class_getInstanceMethod([self class], @selector(viewDidLoad));

        Method dstViewDidload = class_getInstanceMethod([self class], @selector(watermark_viewDidLoad));

        /**
         * method_exchangeImplementations
         * 置换方法实现
         **/
         method_exchangeImplementations(sourceViewDidload, dstViewDidload);
    });
}


```

### Tip

- 方法实现的置换必须在类的`load`方法中实现；而且必须全局仅执行一次，所以要使用`dispatch_once`

- 要注意需要置换的方法，是否已经在工程中有过其他代码的置换，特别是在引入的开源代码和静态库中；如果多次置换，最后实际的方法实现将不可知。

----

## 反射

> 反射在代码解耦合和组件化中应用很多。我的理解是反射其实就是字符串与OC类实例，字符串与OC方法实例，字符串与OC属性实例之间的转换，达到动态的方法调用和属性注入的效果，这样就将耦合转移到配置文件中

[参考demo][3]

### 主要方法

> 在<Foundation/NSObjCRuntime.h>提供了简易的方法，调用Runtime接口实现反射，实现字符串与OC类实例，字符串与OC方法实例之间的转换

```
#import <Foundation/NSObjCRuntime.h>

FOUNDATION_EXPORT NSString *NSStringFromSelector(SEL aSelector);
FOUNDATION_EXPORT SEL NSSelectorFromString(NSString *aSelectorName);

FOUNDATION_EXPORT NSString *NSStringFromClass(Class aClass);
FOUNDATION_EXPORT Class _Nullable NSClassFromString(NSString *aClassName);

FOUNDATION_EXPORT NSString *NSStringFromProtocol(Protocol *proto) API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT Protocol * _Nullable NSProtocolFromString(NSString *namestr) API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));

```

> 在<objc/runtime.h>中提供runtime的c语言接口

```

Class _Nullable objc_getClass(const char * _Nonnull name);



```

----

## KVO动态去创建子类

```
/**
 *
 *  创建一个类
 **/
Class _Nullable objc_allocateClassPair(Class _Nullable superclass, const char * _Nonnull name, 
                       size_t extraBytes);


/**
 *
 *  注册后类才可以使用
 **/
void objc_registerClassPair(Class _Nonnull cls);
                    

```








[1]: Demo/SwizzedMethod/TestApp
[2]: Demo/SwizzedMethod/Crash
[3]: Demo/反射/ZMPermissionManager