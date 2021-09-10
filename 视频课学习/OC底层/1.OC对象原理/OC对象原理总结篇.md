# OC对象原理总结篇

## objc 源码

苹果在[Apple Open Source](https://opensource.apple.com/)开源了许多重要的库，其中就包括 [objc](https://opensource.apple.com/tarballs/objc4/)

objc源码下载后，无法直接编译通过，需要经过一些步骤调整配置，具体参考[iOS_objc4-756.2 最新源码编译调试](https://juejin.cn/post/6844903959161733133),
或者直接下载[objc4_debug](https://github.com/LGCooci/objc4_debug)

> 以下objc源码均是 [objc4-818.2](https://github.com/ExistOrLive/DemoForLearning/tree/master/StudyDemo/objc4-818.2) 


## 1. NSObject, objc_object，id

OC中的所有对象必然是 `NSObject` 和 `NSProxy` 的直接和间接子类。因此 `NSObject` 的底层实现将体现所有OC对象的性质，创建过程以及内存占用。

`NSObject` 类除了实现 `NSObject`协议之外，只有唯一 `isa` 属性 和 `alloc` `dealloc`等 创建，销毁等方法。

```objc 
@interface NSObject <NSObject> {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-interface-ivars"
    Class isa  OBJC_ISA_AVAILABILITY;
#pragma clang diagnostic pop
}
```

`objc_object` 就是 `NSObject` 在底层的实现, 一个OC对象就是 `objc_object` 对象。

```c++
struct objc_object {
private:
    isa_t isa;
};

typedef struct objc_object* id;
```


在`objc_object` 的 `isa` 属性中，保存着对象的类地址以及对象本身的信息(引用计数，关联对象等等) 

## 2. OC对象的创建 

通过调试 objc4-818.2 源码，我们找到创建OC对象的堆栈信息和基本步骤。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-19%20%E4%B8%8A%E5%8D%888.57.32.png)

经过调试，`alloc` 方法的底层实现及调用堆栈如下：

```objc
_class_createInstanceFromZone(objc_class*,unsigned long,void*,int,bool,unsigned long*)
_objc_rootAllocWithZone
callAlloc(objc_class*,bool,bool)
_objc_rootAlloc
+[NSObject alloc]
callAlloc(objc_class*,bool,bool)
objc_alloc
```

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%9C%AA%E5%91%BD%E5%90%8D%E6%96%87%E4%BB%B6.png)

### 2.1 _class_createInstanceFromZone

创建对象最主要的步骤都集中在`_class_createInstanceFromZone`函数中。

- 获取对象需要内存大小  instanceSize
- 申请内存 calloc
- 初始化isa initInstanceIsa

```c
static ALWAYS_INLINE id
_class_createInstanceFromZone(Class cls, size_t extraBytes, void *zone,
                              int construct_flags = OBJECT_CONSTRUCT_NONE,
                              bool cxxConstruct = true,
                              size_t *outAllocatedSize = nil)
{
    ASSERT(cls->isRealized());

    // Read class's info bits all at once for performance
    bool hasCxxCtor = cxxConstruct && cls->hasCxxCtor();
    bool hasCxxDtor = cls->hasCxxDtor();
    bool fast = cls->canAllocNonpointer();
    size_t size;

    size = cls->instanceSize(extraBytes);
    if (outAllocatedSize) *outAllocatedSize = size;

    id obj;
    if (zone) {
        obj = (id)malloc_zone_calloc((malloc_zone_t *)zone, 1, size);
    } else {
        obj = (id)calloc(1, size);
    }
    if (slowpath(!obj)) {
        if (construct_flags & OBJECT_CONSTRUCT_CALL_BADALLOC) {
            return _objc_callBadAllocHandler(cls);
        }
        return nil;
    }

    if (!zone && fast) {
        obj->initInstanceIsa(cls, hasCxxDtor);
    } else {
        // Use raw pointer isa on the assumption that they might be
        // doing something weird with the zone or RR.
        obj->initIsa(cls);
    }

    if (fastpath(!hasCxxCtor)) {
        return obj;
    }

    construct_flags |= OBJECT_CONSTRUCT_FREE_ONFAILURE;
    return object_cxxConstructFromClass(obj, cls, construct_flags);
}
```

## 3. OC对象的内存大小

一个OC对象内存占用包括 `isa` 属性 以及 其他的自定义存储属性和成员变量。  `isa` 属性 占用8个字节。

```objc
// 定义以下的KCTestObject 
// isa 以及 属性共占用 42 字节
@interface KCTestObject : NSObject

@property(nonatomic,strong) NSString *str1;
@property(nonatomic,assign) int a;
@property(nonatomic,assign) double b;
@property(nonatomic,strong) NSString *str2;
@property(nonatomic,strong) NSNumber *number1;

@end

// 但是事实上 KCTestObject 对象占用 48 字节
```

但是，事实上OC对象占用的内存往往比实际需要的更大。这是因为字节对齐策略优化CPU访问内存的效率。

> 字节对齐 是一种优化CPU访问内存效率的策略。CPU访问内存并不是按字节读取，而是按照字的大小(2,4,8字节)，为了保证读取的效率，一般对象所占内存的大小应是2的倍数，不足的就会补齐。

在加载OC类的时候，就会计算好对象所需的内存并保存`objc_class` 的 `cache`中。保存时使用8位对齐，获取时又进行16位对齐。

因此，最终在分配对象内存时，使用的是16位对齐的结果。

```c++

// struct cache_t 
size_t fastInstanceSize(size_t extra) const{
        ASSERT(hasFastInstanceSize(extra));

        if (__builtin_constant_p(extra) && extra == 0) {
            return _flags & FAST_CACHE_ALLOC_MASK16;
        } else {
            size_t size = _flags & FAST_CACHE_ALLOC_MASK;
            // remove the FAST_CACHE_ALLOC_DELTA16 that was added
            // by setFastInstanceSize
            // 返回的结果将 16 位对齐 
            return align16(size + extra - FAST_CACHE_ALLOC_DELTA16);
        }
}


void setFastInstanceSize(size_t newSize)
    {
        // Set during realization or construction only. No locking needed.
        uint16_t newBits = _flags & ~FAST_CACHE_ALLOC_MASK;
        uint16_t sizeBits;

        // Adding FAST_CACHE_ALLOC_DELTA16 allows for FAST_CACHE_ALLOC_MASK16
        // to yield the proper 16byte aligned allocation size with a single mask
        // 缓存时进行 8 位对齐
        sizeBits = word_align(newSize) + FAST_CACHE_ALLOC_DELTA16;
        sizeBits &= FAST_CACHE_ALLOC_MASK;
        if (newSize <= sizeBits) {
            newBits |= sizeBits;
        }
        _flags = newBits;
}
 
```

## 4. OC对象的内存分布

OC对象前8字节由`isa`属性占用，剩余的内存由其他存储属性或者成员变量占用。

以`KCTestObject`为例创建对象后，通过LLDB命令打印出对象的内存占用。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-22%20%E4%B8%8B%E5%8D%883.55.07.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-23%20%E4%B8%8B%E5%8D%882.16.02.png)


由上面截图可以看出，属性的排列不一定按照定义的顺序经过了重排优化。

## 5. isa_t 

在 objc4-818.2 的实现中，`isa` 属性是 `isa_t` 类型。 `isa_t` 是一个联合体，`bits`和`ISA_BITFIELD` 位域结构体共享一块内存, 在这块内存中保存着类和对象的信息。

```c
union isa_t {

    uintptr_t bits;

private:
    Class cls;

public:
#if defined(ISA_BITFIELD)
    struct {
        ISA_BITFIELD;  // defined in isa.h
    };
#endif
};
```

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/isa64%E6%83%85%E5%86%B5.jpeg)

`isa_t` 中的`shiftcls` 才是实际保存类地址的部分，仅占用`isa`的一部分。其他部分则保存着对象的信息(如`extra_rc` 引用计数)。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-22%20%E4%B8%8B%E5%8D%888.56.49.png)


