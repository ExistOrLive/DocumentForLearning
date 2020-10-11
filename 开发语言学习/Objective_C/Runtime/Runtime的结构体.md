# Runtime的结构体

> 在<objc/runtime.h> <objc/message.h>中提供了一套c语言的结构体和接口，用于与OC的运行时交互。这里主要阐述一下各个结构体的具体含义和作用。

## `id ，objc_object 和 NSObject`

- `id` 一个指向OC实例的指针

- `objc_object` 一个OC实例

- `NSObject` OC类的基类

```

#import <objc/objc.h>

/// Represents an instance of a class.
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;

#import <objc/NSObject.h>

@interface NSObject <NSObject> {

    Class isa  OBJC_ISA_AVAILABILITY;

}

```

> 由`objc_object`和`NSObject`的定义可知，都包含有一个`Class`的变量，这就是`NSObject *`和 `id`相互转换使用的原因。

## Class 和 objc_class

- Class 代表一个OC的类

- objc_class 代表OC类的结构体

```

/// An opaque type that represents an Objective-C class.
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

} OBJC2_UNAVAILABLE;

```

> 由`objc_class`定义可知，包含一个isa的变量，指向元类(meta_class)对象。所以`Class`对象也是一个OC对象

![Class_MetaClass_Code][1]

![Class_MetaClass][2]

> 由上图代码执行可知:

1. OC实例的isa指针指向对应的类对象。类对象的isa指针指向对象的元类对象。

2. NSObject是顶级父类，NSObject的元类是顶级元类，所有的元类对象的isa指针都指向顶级元类。如图，metaMetaCla(即KVOTest的元类的isa指针)，ObjectMetaClass(NSObject的元类)，ObjectmetaMetalCla(NSObject的元类的元类)的地址是一样的

3. 子类的元类和父类的元类存在派生关系，而顶级元类的父类是NSObject

![instance_class_metaclass][3]

----

## 参考文档

[探秘Runtime - 剖析Runtime结构体][4]


[1]: pic/Class_MetaClass_Code.png
[2]: pic/Class_MetaClass.png
[3]: pic/instance_class_metaclass.jpg
[4]: https://www.jianshu.com/p/5b7e7c8075ef