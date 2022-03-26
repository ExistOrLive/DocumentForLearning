# Block的底层实现

Block的本质是一个结构体，包含`isa`，`FuncPtr`等主要成员变量。如果捕获了变量，会生成对应的成员变量保存变量的值。

其中`isa`默认赋值为`_NSStackBlock`，但是我们使用中的Block 都是`_NSGlobalBlock`或者`_NSMallocBlock`类型。


![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-07-13%20%E4%B8%8A%E5%8D%882.33.42.png)

在Block赋值给某个变量时，变量如果需要持有Block，将会给Block发送`retain`消息，底层则调用到`objc_retainBlock`函数，我们把关注点锁定在`objc_retainBlock`函数上。

```objc
// objc4-818.2
id objc_retainBlock(id x) {
    return (id)_Block_copy(x);
}
```

## 1. `_Block_copy` 

从[Block源码](https://opensource.apple.com/tarballs/libclosure/)中找到`_Block_copy`的实现。

```objc
// libclosure-78

void *_Block_copy(const void *arg) {
    struct Block_layout *aBlock;

    if (!arg) return NULL;
    
    // The following would be better done as a switch statement
    aBlock = (struct Block_layout *)arg;

    /**
     *
     * 1. 如果是block 已经是 malloc block，仅增加引用计数
     **/ 
    if (aBlock->flags & BLOCK_NEEDS_FREE) {
        // latches on high
        latching_incr_int(&aBlock->flags);
        return aBlock;
    }
    /**
     *
     * 2. 如果是global block 直接返回
     **/ 
    else if (aBlock->flags & BLOCK_IS_GLOBAL) {
        return aBlock;
    }
     /**
     *
     * 3. 如果是stack block，则重新拷贝一份
     **/ 
    else {
        // Its a stack block.  Make a copy.
        size_t size = Block_size(aBlock);
         /**
         *
         * 3.1 分配新的内存
         **/ 
        struct Block_layout *result = (struct Block_layout *)malloc(size);
        if (!result) return NULL;
        /**
         *
         * 3.2 浅拷贝
         **/ 
        memmove(result, aBlock, size); // bitcopy first
#if __has_feature(ptrauth_calls)
        // Resign the invoke pointer as it uses address authentication.
        result->invoke = aBlock->invoke;

#if __has_feature(ptrauth_signed_block_descriptors)
        if (aBlock->flags & BLOCK_SMALL_DESCRIPTOR) {
            uintptr_t oldDesc = ptrauth_blend_discriminator(
                    &aBlock->descriptor,
                    _Block_descriptor_ptrauth_discriminator);
            uintptr_t newDesc = ptrauth_blend_discriminator(
                    &result->descriptor,
                    _Block_descriptor_ptrauth_discriminator);

            result->descriptor =
                    ptrauth_auth_and_resign(aBlock->descriptor,
                                            ptrauth_key_asda, oldDesc,
                                            ptrauth_key_asda, newDesc);
        }
#endif
#endif
        /**
         *
         * 3.3 设置flag，包括引用计数
         **/
        // reset refcount
        result->flags &= ~(BLOCK_REFCOUNT_MASK|BLOCK_DEALLOCATING);    // XXX not needed
        result->flags |= BLOCK_NEEDS_FREE | 2;  // logical refcount 1

        /**
         *
         * 3.4 深度拷贝（需要深度拷贝的捕获变量如__block变量）
         **/ 
        _Block_call_copy_helper(result, aBlock);
        // Set isa last so memory analysis tools see a fully-initialized object.
        /**
         *
         * 3.5 设置isa
         **/ 
        result->isa = _NSConcreteMallocBlock;

        return result;
    }
}
```
- 当Block 为 malloc block，则增加引用计数并返回；

- 当Block 为 global block ，则直接返回；

- 当为stack block，则拷贝一份，并设置类型为 malloc block，再返回。

![](https://github.com/existorlive/existorlivepic/raw/master/Block_copy.png)

## 2.`_Block_release`

`_Block_copy`在持有Block时调用，`_Block_release`在释放block时调用。


```objc
// API entry point to release a copied Block
void _Block_release(const void *arg) {
    struct Block_layout *aBlock = (struct Block_layout *)arg;

    if (!aBlock) return;
    // gloabl block 直接返回
    if (aBlock->flags & BLOCK_IS_GLOBAL) return;
    // stack block 返回 
    if (! (aBlock->flags & BLOCK_NEEDS_FREE)) return;
     
     // 减少引用计数
    if (latching_decr_int_should_deallocate(&aBlock->flags)) {
        // 如果需要销毁block(引用计数为0)，则调用释放和销毁的方法
        _Block_call_dispose_helper(aBlock); 
        _Block_destructInstance(aBlock);
        free(aBlock);
    }
}
```

## 3. Block的底层结构

在`_Block_copy`和`_Block_release`方法中，block 作为 `Block_layout`类型使用。

与前文中Block的结构体几乎一致，
- `isa`, block的类型
- `invoke`（函数指针
- `flag` 保存引用计数等信息
- `reserved` 
- `descriptor` 
- 其他成员变量

```objc
struct Block_layout {
    void * __ptrauth_objc_isa_pointer isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    BlockInvokeFunction invoke;
    struct Block_descriptor_1 *descriptor;
    // imported variables
};
```
### 3.1 flag

`flag`是一块4字节的内存，不同的位保存不同的信息。

- BLOCK_REFCOUNT_MASK （0xfffe） 保存了引用计数
- BLOCK_NEEDS_FREE     1 MallocBlock  0 Stack Block
- BLOCK_DEALLOCATING    是否正在销毁
- BLOCK_HAS_COPY_DISPOSE  是否存在拷贝销毁方法(是否存在descriptor2)
- BLOCK_IS_GLOBAL     是否为global block
- BLOCK_HAS_SIGNATURE  是否存在descriptor3
  

```objc
enum {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_INLINE_LAYOUT_STRING = (1 << 21), // compiler

#if BLOCK_SMALL_DESCRIPTOR_SUPPORTED
    BLOCK_SMALL_DESCRIPTOR =  (1 << 22), // compiler
#endif

    BLOCK_IS_NOESCAPE =       (1 << 23), // compiler
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};
```

### 3.2 `Block_descriptor`

Block如果捕获变量，变量将保存在Block结构体中对应的成员变量中，因此Block结构体的大小不是固定的；同时Block还有按需增加`descriptor`

已知三种`descriptor`:

- `Block_descriptor_1`: 必要的，保存了block的大小
- `Block_descriptor_2`: 要求BLOCK_HAS_COPY_DISPOSE，保存block拷贝和释放需要调用的方法,即上文中的`_Block_call_copy_helper`和`_Block_call_dispose_helper`
- `Block_descriptor_3`: 要求BLOCK_HAS_SIGNATURE，

```objc
#define BLOCK_DESCRIPTOR_1 1
struct Block_descriptor_1 {
    uintptr_t reserved;
    uintptr_t size;
};

#define BLOCK_DESCRIPTOR_2 1
struct Block_descriptor_2 {
    // requires BLOCK_HAS_COPY_DISPOSE
    BlockCopyFunction copy;
    BlockDisposeFunction dispose;
};

#define BLOCK_DESCRIPTOR_3 1
struct Block_descriptor_3 {
    // requires BLOCK_HAS_SIGNATURE
    const char *signature;
    const char *layout;     // contents depend on BLOCK_HAS_EXTENDED_LAYOUT
};
```

### 3.3 Example 

```objc
  int num = 11;
  NSString *str = @"dasda";
  NSDate *date = [NSDate date];
  __weak NSDate *weakdate = date;
  __block int num1 = 0;
  __block NSTimer * timer = nil;

  void(^a)() = ^{
      NSLog(@"%d,%@,%@",num,str,weakdate);
      num1 = num;
      timer = nil;
  };
```
`clang -rewrite-objc -fobjc-arc -fobjc-runtime=ios-14.5.0 -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator.sdk`将以上OC代码改写为C语言，Block改写为对应的结构体实现

```c
// 对应 Block_layout
struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  int num;
  NSString *__strong str;
  NSDate *__weak weakdate;
  __Block_byref_num1_0 *num1; // by ref
  __Block_byref_timer_1 *timer; // by ref


  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int _num, NSString *__strong _str, NSDate *__weak _weakdate, __Block_byref_num1_0 *_num1, __Block_byref_timer_1 *_timer, int flags=0) : num(_num), str(_str), weakdate(_weakdate), num1(_num1->__forwarding), timer(_timer->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

// 函数体
static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
  __Block_byref_num1_0 *num1 = __cself->num1; // bound by ref
  __Block_byref_timer_1 *timer = __cself->timer; // bound by ref
  int num = __cself->num; // bound by copy
  NSString *__strong str = __cself->str; // bound by copy
  NSDate *__weak weakdate = __cself->weakdate; // bound by copy

  NSLog((NSString *)&__NSConstantStringImpl__var_folders_34_yg5lfpys2l1ghsm4rjr974qh0000gn_T_main_53f4b3_mii_1,num,str,weakdate);
  (num1->__forwarding->num1) = num;
  (timer->__forwarding->timer) = __null;
}


// copy dispose 方法 用于深度拷贝捕获的变量(引用类型，__block类型)
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
  
  _Block_object_assign((void*)&dst->str, (void*)src->str, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_assign((void*)&dst->weakdate, (void*)src->weakdate, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_assign((void*)&dst->num1, (void*)src->num1, 8/*BLOCK_FIELD_IS_BYREF*/);
  _Block_object_assign((void*)&dst->timer, (void*)src->timer, 8/*BLOCK_FIELD_IS_BYREF*/);

}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {

  _Block_object_dispose((void*)src->str, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_dispose((void*)src->weakdate, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_dispose((void*)src->num1, 8/*BLOCK_FIELD_IS_BYREF*/);
  _Block_object_dispose((void*)src->timer, 8/*BLOCK_FIELD_IS_BYREF*/);

}


// 对应 Block_descriptor_1 Block_descriptor_2
static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, 
                               sizeof(struct __main_block_impl_0), 
                               __main_block_copy_0, 
                               __main_block_dispose_0};

```

`__main_block_impl_0`对应底层的`Block_Layout`; 

`__block_impl`对应底层`Block_Layout`的`isa`,`flag`,`reserved`，`invoke`

`__main_block_desc_0` 对应底层`Block_descriptor_1`和`Block_descriptor_2`,包含了 Block大小，和 `copy` 和 `dispose`

`copy` 和 `dispose` 函数是用于Block 拷贝和销毁的时候，深度拷贝和销毁Block捕获的变量。

```c
static void __main_block_copy_0(struct __main_block_impl_0*dst, struct __main_block_impl_0*src) {
  
  _Block_object_assign((void*)&dst->str, (void*)src->str, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_assign((void*)&dst->weakdate, (void*)src->weakdate, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_assign((void*)&dst->num1, (void*)src->num1, 8/*BLOCK_FIELD_IS_BYREF*/);
  _Block_object_assign((void*)&dst->timer, (void*)src->timer, 8/*BLOCK_FIELD_IS_BYREF*/);

}

static void __main_block_dispose_0(struct __main_block_impl_0*src) {

  _Block_object_dispose((void*)src->str, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_dispose((void*)src->weakdate, 3/*BLOCK_FIELD_IS_OBJECT*/);
  _Block_object_dispose((void*)src->num1, 8/*BLOCK_FIELD_IS_BYREF*/);
  _Block_object_dispose((void*)src->timer, 8/*BLOCK_FIELD_IS_BYREF*/);

}
```

由函数实现可见，`copy`和`dispose`函数是调用`_Block_object_assign`和`_Block_object_dispose`处理捕获变量。

## 4. 拷贝捕获的变量 `_Block_object_assign`,`_Block_object_dispose`

- 捕获变量为Block或者对象类型，先持有，再赋值
- 捕获变量为__block变量，调用`_Block_byref_copy`
- 其他的直接赋值

```objc
void _Block_object_assign(void *destArg, const void *object, const int flags) {
    const void **dest = (const void **)destArg;
    switch (os_assumes(flags & BLOCK_ALL_COPY_DISPOSE_FLAGS)) {
      case BLOCK_FIELD_IS_OBJECT:
        /*******
        id object = ...;
        [^{ object; } copy];
        ********/
        
        // 事实上，什么都没有做
        _Block_retain_object(object);
        *dest = object;
        break;

      case BLOCK_FIELD_IS_BLOCK:
        /*******
        void (^object)(void) = ...;
        [^{ object; } copy];
        ********/
        
        *dest = _Block_copy(object);
        break;
    
      case BLOCK_FIELD_IS_BYREF | BLOCK_FIELD_IS_WEAK:
      case BLOCK_FIELD_IS_BYREF:
        /*******
         // copy the onstack __block container to the heap
         // Note this __weak is old GC-weak/MRC-unretained.
         // ARC-style __weak is handled by the copy helper directly.
         __block ... x;
         __weak __block ... x;
         [^{ x; } copy];
         ********/

        *dest = _Block_byref_copy(object);
        break;
        
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_OBJECT:
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_BLOCK:
        /*******
         // copy the actual field held in the __block container
         // Note this is MRC unretained __block only. 
         // ARC retained __block is handled by the copy helper directly.
         __block id object;
         __block void (^object)(void);
         [^{ object; } copy];
         ********/

        *dest = object;
        break;

      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_OBJECT | BLOCK_FIELD_IS_WEAK:
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_BLOCK  | BLOCK_FIELD_IS_WEAK:
        /*******
         // copy the actual field held in the __block container
         // Note this __weak is old GC-weak/MRC-unretained.
         // ARC-style __weak is handled by the copy helper directly.
         __weak __block id object;
         __weak __block void (^object)(void);
         [^{ object; } copy];
         ********/

        *dest = object;
        break;

      default:
        break;
    }
}

```

```objc
void _Block_object_dispose(const void *object, const int flags) {
    switch (os_assumes(flags & BLOCK_ALL_COPY_DISPOSE_FLAGS)) {
      case BLOCK_FIELD_IS_BYREF | BLOCK_FIELD_IS_WEAK:
      case BLOCK_FIELD_IS_BYREF:
        // get rid of the __block data structure held in a Block
        _Block_byref_release(object);
        break;
      case BLOCK_FIELD_IS_BLOCK:
        _Block_release(object);
        break;
      case BLOCK_FIELD_IS_OBJECT:
        _Block_release_object(object);
        break;
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_OBJECT:
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_BLOCK:
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_OBJECT | BLOCK_FIELD_IS_WEAK:
      case BLOCK_BYREF_CALLER | BLOCK_FIELD_IS_BLOCK  | BLOCK_FIELD_IS_WEAK:
        break;
      default:
        break;
    }
}
```

## 5. __block变量和`Block_byref`

在底层**libclosure**的 **__block** 变量使用`Block_byref` 结构体表示：

- isa          表示类型
- forwarding   指向原始Block_byref的指针，通过该指针修改捕获的变量的值
- flags        引用计数以及一些状态
- size         Block_byref 的大小

```c
// libclosure-78
struct Block_byref {
    void * __ptrauth_objc_isa_pointer isa;
    struct Block_byref *forwarding;
    volatile int32_t flags; // contains ref count
    uint32_t size;
};

struct Block_byref_2 {
    // requires BLOCK_BYREF_HAS_COPY_DISPOSE
    BlockByrefKeepFunction byref_keep;
    BlockByrefDestroyFunction byref_destroy;
};

struct Block_byref_3 {
    // requires BLOCK_BYREF_LAYOUT_EXTENDED
    const char *layout;
};
```

当Block被拷贝或者释放时，捕获的__block变量(即Block_byref)也要拷贝`_Block_byref_copy`和释放`_Block_byref_release`

### 5.1  `_Block_byref_copy`

```c
static struct Block_byref *_Block_byref_copy(const void *arg) {
    struct Block_byref *src = (struct Block_byref *)arg;

    if ((src->forwarding->flags & BLOCK_REFCOUNT_MASK) == 0) {
        // src points to stack
        struct Block_byref *copy = (struct Block_byref *)malloc(src->size);
        copy->isa = NULL;
        // byref value 4 is logical refcount of 2: one for caller, one for stack
        copy->flags = src->flags | BLOCK_BYREF_NEEDS_FREE | 4;
        copy->forwarding = copy; // patch heap copy to point to itself
        src->forwarding = copy;  // patch stack to point to heap copy
        copy->size = src->size;

        if (src->flags & BLOCK_BYREF_HAS_COPY_DISPOSE) {
            // Trust copy helper to copy everything of interest
            // If more than one field shows up in a byref block this is wrong XXX
            struct Block_byref_2 *src2 = (struct Block_byref_2 *)(src+1);
            struct Block_byref_2 *copy2 = (struct Block_byref_2 *)(copy+1);
            copy2->byref_keep = src2->byref_keep;
            copy2->byref_destroy = src2->byref_destroy;
            
            // 如果需要深度拷贝
            if (src->flags & BLOCK_BYREF_LAYOUT_EXTENDED) {
                struct Block_byref_3 *src3 = (struct Block_byref_3 *)(src2+1);
                struct Block_byref_3 *copy3 = (struct Block_byref_3*)(copy2+1);
                copy3->layout = src3->layout;
            }

            (*src2->byref_keep)(copy, src);
        }
        else {
            // 不需要深度拷贝 
            // Bitwise copy.
            // This copy includes Block_byref_3, if any.
            memmove(copy+1, src+1, src->size - sizeof(*src));
        }
    }
    // Block_byref已经在堆上，只需要操作引用计数
    // already copied to heap
    else if ((src->forwarding->flags & BLOCK_BYREF_NEEDS_FREE) == BLOCK_BYREF_NEEDS_FREE) {
        latching_incr_int(&src->forwarding->flags);
    }
    
    return src->forwarding;
}
```

`Block_byref_copy`主要作用：

- 如果`Block_byref`存储在栈上，那么需要拷贝到堆上
    
    在堆上拷贝新的`Block_byref`，原本的`Block_byref`的`forwarding`需要指向新的`Block_byref`。这样__block变量的值由新的`Block_byref`在堆上维护，不会因为栈内存的释放而被销毁。

- 如果`Block_byref`已经存储在堆上，只需要操作引用计数+1

![](https://github.com/existorlive/existorlivepic/raw/master/Block_byref_copy.png)

### 5.1  `_Block_byref_release`

```objc
static void _Block_byref_release(const void *arg) {

    struct Block_byref *byref = (struct Block_byref *)arg;

    // dereference the forwarding pointer since the compiler isn't doing this anymore (ever?)
    byref = byref->forwarding;
    
    if (byref->flags & BLOCK_BYREF_NEEDS_FREE) {
        int32_t refcount = byref->flags & BLOCK_REFCOUNT_MASK;
        os_assert(refcount);
        // 引用计数减1
        if (latching_decr_int_should_deallocate(&byref->flags)) {
            if (byref->flags & BLOCK_BYREF_HAS_COPY_DISPOSE) {
                struct Block_byref_2 *byref2 = (struct Block_byref_2 *)(byref+1);
                (*byref2->byref_destroy)(byref);
            }
            // 销毁byref
            free(byref);
        }
    }
}
```


## 6. 总结

- Block 分为 `NSGlobalBlock`，`NSStackBlock`，
  `NSMallocBlock`. 
  
     - `NSGlobalBlock`的生命周期是全局的，不需要内存管理。
     - `NSStackBlock` 只是一个初始的临时状态
     - `NSMallocBlock` 使用引用计数来管理

- `Block_Copy` 主要两个功能：
  
     - 对`NSMallocBlock` ，引用计数 + 1
     - 将 `NSStackBlock` 拷贝为 `NSMallocBlock`

- `Block_Release` 作用是引用计数减1，当引用计数为0时，销毁Block


- Block 在底层使用`Block_layout`表示，捕获的变量将作为`Block_layout`的成员变量存储。在拷贝或者销毁Block时，也需要拷贝和释放捕获的变量

- 有一些捕获的变量在拷贝或者释放时需要进一步操作，如retain，或者深度拷贝(引用类型，__block)。`Block_descriptor_2`中保存着相关的copy和dispose方法

- **__Block**变量在底层的实现为`Block_byref`。 一般 `Block_byref`变量定义在栈上，在将Block拷贝为`NSMallocBlock`时，`Block_byref` 也会拷贝到堆上，相关方法`Block_byref_copy`和`Block_byref_release`.


## 7. Example

```objc
  int num = 11;
  NSString *str = @"dasda";
  NSDate *date = [NSDate date];
  __weak NSDate *weakdate = date;
  __block int num1 = 0;
  __block NSTimer * timer = nil;

  void(^a)() = ^{
      NSLog(@"%d,%@,%@",num,str,weakdate);
      num1 = num;
      timer = nil;
  };

  a();
        
  NSLog(@"%d",num1);
```

如上的代码改写为C语言，[main.cpp](../9.Block/main.cpp)

![](https://github.com/existorlive/existorlivepic/raw/master/Block_layout1.png)