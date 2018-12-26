# Runtime

> OC语言是一门动态语言，会将程序的一些决定工作从编译期推迟到运行期。

----

## Runtime的使用

> Runtime是一个共享动态库，其目录位于/usr/include/objc，是一系列的c函数和结构体构成。Runtime的API主要有几处：

- `NSObject`类的方法：
  `NSObject` 提供了一些简单接口，用于runtime的交互

```

#import <objc/NSObject>

- (BOOL)isKindOfClass:(Class)aClass;      // 是否为class类型
- (BOOL)isMemberOfClass:(Class)aClass;    // 是否为class类型或子类类型
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;
- (BOOL)respondsToSelector:(SEL)aSelector;
+ (BOOL)instancesRespondToSelector:(SEL)aSelector;
+ (BOOL)conformsToProtocol:(Protocol *)protocol;
- (IMP)methodForSelector:(SEL)aSelector;
+ (IMP)instanceMethodForSelector:(SEL)aSelector;
- (void)doesNotRecognizeSelector:(SEL)aSelector; // 主要抛出异常 unrecognized selector sent to instance

.........

```

- `NSObjCRuntime.h`

`Foundation/NSObjCRuntime.h` 中提供了一些SEL，Class，Protocol之间转换的方法

```

#import <Foundation/NSObjCRuntime.h>

NSString *NSStringFromSelector(SEL aSelector);
SEL NSSelectorFromString(NSString *aSelectorName);

NSString *NSStringFromClass(Class aClass);
Class _Nullable NSClassFromString(NSString *aClassName);

NSString *NSStringFromProtocol(Protocol *proto);
Protocol * _Nullable NSProtocolFromString(NSString *namestr);

```

- `<objc/Runtime.h> <objc/message.h>`

  这里提供了一套c语言的结构体和函数，用于Runtime的交互。