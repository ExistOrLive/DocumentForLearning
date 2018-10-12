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






