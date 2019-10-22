# Ivar

## Ivar的定义及结构

> <objc/runtime.h>中有Ivar的定义，一个代表实例变量的不透明类型。

```objc
#import <objc/runtime.h>

/// An opaque type that represents an instance variable.
typedef struct objc_ivar *Ivar;

```

> 在objc1中`objc_ivar`定义如下，只包含了实例变量定义的名字，类型以及偏移量的信息，不包含实例变量的具体值。

```c

struct objc_ivar {
    char * _Nullable ivar_name                                OBJC2_UNAVAILABLE;         // 变量名
    char * _Nullable ivar_type                               OBJC2_UNAVAILABLE;          // 变量类型
    int ivar_offset                                          OBJC2_UNAVAILABLE;          // 变量的偏移量
#ifdef __LP64__
    int space                                                OBJC2_UNAVAILABLE;
#endif
} 

```

> runtime也提供了方法，去获取这三个值

```c
OBJC_EXPORT const char * _Nullable
ivar_getName(Ivar _Nonnull v) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);


OBJC_EXPORT const char * _Nullable
ivar_getTypeEncoding(Ivar _Nonnull v) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

OBJC_EXPORT ptrdiff_t
ivar_getOffset(Ivar _Nonnull v) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);


// 获取类的实力变量列表
OBJC_EXPORT Ivar _Nonnull * _Nullable
class_copyIvarList(Class _Nullable cls, unsigned int * _Nullable outCount) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);
```


## Ivar的使用


### 获取Ivar

```objc

// 获取实例或者类变量的Ivar

OBJC_EXPORT Ivar _Nullable
class_getInstanceVariable(Class _Nullable cls, const char * _Nonnull name)
    OBJC_AVAILABLE(10.0, 2.0, 9.0, 1.0, 2.0);

OBJC_EXPORT Ivar _Nullable
class_getClassVariable(Class _Nullable cls, const char * _Nonnull name) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

// 获取实例变量Ivar的列表
OBJC_EXPORT Ivar _Nonnull * _Nullable
class_copyIvarList(Class _Nullable cls, unsigned int * _Nullable outCount) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

```

### 通过Ivar修改变量的值

> 可以通过Ivar获取或修改某个对象的实例变量的值

```objc
OBJC_EXPORT id _Nullable
object_getIvar(id _Nullable obj, Ivar _Nonnull ivar) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);


OBJC_EXPORT void
object_setIvar(id _Nullable obj, Ivar _Nonnull ivar, id _Nullable value) 
    OBJC_AVAILABLE(10.5, 2.0, 9.0, 1.0, 2.0);

```


## 应用

> 利用Ivar遍历对象的变量列表，实现NSCopying，NSCoding的基类


```objc

//序列化
-(void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *ivar_name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

//反序列化
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            const char *ivar_name = ivar_getName(ivars[i]);
            NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
            [self setValue:[coder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    id model = [[[self class] allocWithZone:zone] init];
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *ivar_name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
        [model setValue:[self valueForKey:key] forKey:key];
    }
    
    return model;
}

```




