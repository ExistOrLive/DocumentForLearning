# Objective_C 反射

> OC语言的对象几乎都继承于`NSObject`类，`NSObject`对象都有一个`Class`类型的实例变量`isa`，`Class`类实质是`objc_class`结构体指针

```
#include "objc.h"
/**
 * Class
 **/
typedef struct objc_class *Class;

struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list * _Nullable * _Nullable methodLists                    OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

}

/**
 * NSObject
 **/
@interface NSObject <NSObject> 
{
    Class isa  OBJC_ISA_AVAILABILITY;
}

/**
 * id 
 **/
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;

/**
 *
 **/
/// An opaque type that represents a method selector.
typedef struct objc_selector *SEL;

```

---

## OC 层

> 在`<Foundation/NSObjCRuntime.h>` 提供了一些函数用于在OC层实现简单的反射

```
/**
 *  这些方法实现了字符串和Class ，SEL ， Protocal 之间的转换
 **/
#import <Foundation/NSObjCRuntime.h>

FOUNDATION_EXPORT NSString *NSStringFromSelector(SEL aSelector);
FOUNDATION_EXPORT SEL NSSelectorFromString(NSString *aSelectorName);

FOUNDATION_EXPORT NSString *NSStringFromClass(Class aClass);
FOUNDATION_EXPORT Class _Nullable NSClassFromString(NSString *aClassName);

FOUNDATION_EXPORT NSString *NSStringFromProtocol(Protocol *proto) API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
FOUNDATION_EXPORT Protocol * _Nullable NSProtocolFromString(NSString *namestr) API_AVAILABLE(macos(10.5), ios(2.0), watchos(2.0), tvos(9.0));
```

> 同时在NSObject类中也提供了方法，用于反射的方式创建实例，调用方法

```
#import "NSObject.h"

/**
 * 检查该实例是否实现了这个方法
 **/ 
- (BOOL)respondsToSelector:(SEL)aSelector;



/**
 * 发送消息 (调用方法)
 **/ 
- (id)performSelector:(SEL)aSelector;
- (id)performSelector:(SEL)aSelector withObject:(id)object;
- (id)performSelector:(SEL)aSelector withObject:(id)object1 withObject:(id)object2;

/**
 * 该实例是否是Class或者Class超类的对象
 **/
- (BOOL)isKindOfClass:(Class)aClass;
/**
 * 该实例是否是Class的对象
 **/
- (BOOL)isMemberOfClass:(Class)aClass;
/**
 * 是否实现了该协议
 **/
- (BOOL)conformsToProtocol:(Protocol *)aProtocol;

/**
 * 获取SEL对应的函数指针(具体实现)
 **/
- (IMP)methodForSelector:(SEL)aSelector;
+ (IMP)instanceMethodForSelector:(SEL)aSelector;

```

### Tip
> 通过反射调用某方法时，应避免使用`- (id)performSelector:(SEL)aSelector;`

- 使用-(id)performSelector:(SEL)aSelector 难以适应多个参数的情况

- 由于SEL的返回值类型不能确定，可能是OC类，可能是基本数据类型，可能是void，而- (id)performSelector:(SEL)aSelector 返回值类型默认为id即OC类，编译器会默认向返回值发送retain或者release消息，当返回值时基本数据类型时，可能会闪退

- 效率相对于直接调用函数指针效率不高

**会有如下的报错：**
![error1][1]

**通过获取SEL的对应的函数指针实现方法的调用**
![error2][2]

[[爆栈热门 iOS 问题] performSelector may cause a leak because its selector is unknown][3]


  [1]: error1.png
  [2]: error2.png
  [3]: https://www.jianshu.com/p/6517ab655be7