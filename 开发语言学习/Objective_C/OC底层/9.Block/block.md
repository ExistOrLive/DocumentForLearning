# Block

## 1. Block的类型以及内存管理

> 在 OC中，总共由三种block类型：

1. _NSGlobalBlock,全局的静态block，不捕获变量，它的生命周期是全局的。

2. _NSStackBlock,保存在栈上的block，当定义block的代码块结束，就会被销毁

3. _NSMallocBlock,保存在堆上的block，当引用计数为0时，会被销毁。

### _NSGlobalBlock

> 不自动捕获变量的Block是_NSGlobalBlock类型，且类型不会改变。

### _NSStackBlock

> 访问自动变量的block在定义时默认是_NSStackBlock类型，只有调用了copy方法，才会变成_NSMallocBlock类型。_NSStackBlock是一种临时的状态，只要被任意的变量持有就会变为_NSMallocBlock。如果不被任何变量持有，一直保持_NSStackBlock状态，将随时被销毁。

### _NSMallocBlock

> 在ARC中，当Block被定义后，传给一个OC变量，会自动调用Block的copy方法，这个时候Block就会变为_NSMallocBlock类型。在MRC，则需要手动调用Copy

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-07-12%20%E4%B8%8B%E5%8D%887.59.58.png)

## 2. 避免循环引用

Block在自动捕获变量时，比较容易造成循环引用。

Block事实上是一个OC对象，访问的自动变量会作为Block对象的成员变量被保存下来。 如果变量也是一个OC对象，且是强引用，则Block持有了该对象。如果该对象也持有了Block就会造成循环引用。

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2020-10-12%20%E4%B8%8A%E5%8D%884.43.27.png)

对于这个问题，需要将引用的一方变为weak，避免循环引用。

```objc
__weak __typeof__(self) weakSelf = self;    // 将引用一方变为weak

NSBlockOperation *op = [[NSBlockOperation alloc] init];
[ op addExecutionBlock:^ {

    __strong __typeof__(self) strongSelf = weakSelf;
    // 在这里强引用一下weakself，避免在block执行过程中，weakself被销毁
    [strongSelf doSomething];
    [strongSelf doMoreThing];
} ];
[someOperationQueue addOperation:op];

```

在 Block 执行完毕后，处理循环引用。

```objc
__block __typeof__(self) blockSelf = self;    // 将引用一方变为weak

NSBlockOperation *op = [[NSBlockOperation alloc] init];
[ op addExecutionBlock:^ {

    [blockSelf doSomething];
    [blockSelf doMoreThing];
     
    // 使用__block变量，在代码执行完毕后，赋值为nil
    blockSelf = nil;
} ];
[someOperationQueue addOperation:op];

```



## 3. block的本质

### 3.1 global block

```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        void(^a)() = ^{
            NSLog(@"Hello World");
        };
        
        a();
    }
    return 0;
}
```

通过`clang --rewrite-objc`工具将以上代码改写为C语言

```c
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 
        void(*a)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0, &__main_block_desc_0_DATA));

        ((void (*)(__block_impl *))((__block_impl *)a)->FuncPtr)((__block_impl *)a);
    }
    return 0;
}
```

Block 的定义改写为如下的结构体`__main_block_impl_0`的初始化：

- `__main_block_impl_0` 包含`__block_impl`和`__main_block_desc_0`两个实例变量
- `__block_impl` 包含`isa`(block类型),`FuncPtr`(函数指针), `isa`默认赋值为`_NSConcreteStackBlock`
- `__main_block_desc_0`包含`Block_size`(block占用内存大小)
- Block的函数体定义为静态函数，包含一个固定的参数`__cself`

```objc
struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;
  __main_block_impl_0(void *fp, struct __main_block_desc_0 *desc, int flags=0) {
    // isa 默认初始化为 _NSConcreteStackBlock
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    // 函数指针
    impl.FuncPtr = fp;
    Desc = desc;
  }
};

static void __main_block_func_0(struct __main_block_impl_0 *__cself) {
    NSLog((NSString *)&__NSConstantStringImpl__var_folders_34_yg5lfpys2l1ghsm4rjr974qh0000gn_T_main_f4c154_mii_0);
}

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0)};
```

### 3.2 malloc block

定义如下的block，该block将自动捕获局部变量，包括**标量类型**，**引用类型**，**强引用**，**弱引用** 以及 **__block**

```objc
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        int num = 11;
        NSString *str = @"dasda";
        NSDate *date = [NSDate date];
        __weak NSDate *weakdate = date;
        __block int num1 = 0;
        
        void(^a)() = ^{
            NSLog(@"%d,%@,%@",num,str,weakdate);
            num1 = num;
        };
        
        a();
    }
    return 0;
}
```
通过`clang --rewrite-objc`工具将以上代码改写为C语言

```c
int main(int argc, const char * argv[]) {
    /* @autoreleasepool */ { __AtAutoreleasePool __autoreleasepool; 

        int num = 11;
        NSString *str = (NSString *)&__NSConstantStringImpl__var_folders_34_yg5lfpys2l1ghsm4rjr974qh0000gn_T_main_1e0e44_mii_0;
        NSDate *date = ((NSDate * _Nonnull (*)(id, SEL))(void *)objc_msgSend)((id)objc_getClass("NSDate"), sel_registerName("date"));
        __attribute__((objc_ownership(weak))) NSDate *weakdate = date;
        __attribute__((__blocks__(byref))) __Block_byref_num1_0 num1 = {(void*)0,(__Block_byref_num1_0 *)&num1, 0, sizeof(__Block_byref_num1_0), 0};

        void(*a)() = ((void (*)())&__main_block_impl_0((void *)__main_block_func_0,
                                                       &__main_block_desc_0_DATA,
                                                       num,
                                                       str,
                                                       weakdate,
                                                       (__Block_byref_num1_0 *)&num1,
                                                       570425344));

        ((void (*)(__block_impl *))((__block_impl *)a)->FuncPtr)((__block_impl *)a);
    }
    return 0;
}
```

与**global block** 相似，**malloc block** 的定义仍然改写为如下的结构体`__main_block_impl_0`的初始化，但是`__main_block_impl_0`结构多了一些成员变量用于保存捕获的变量。

- 捕获的**标量类型**会将值拷贝到对应的成员变量中，如 `num`
- 捕获的**引用类型**,如果原本变量持有对象，那么对应的成员变量也会持有；如果原本变量没有持有对象，那么对应的成员变量也不会持有对象。 如 `weakdate`，`str`
- 捕获的 **__block**, **__block**类型的变量将改写为 `__Block_byref`类型，对应的成员变量则是`__Block_byref *`指针类型。 相对于**标量类型** 和 **引用类型** 是值传递，**__block类型** 是引用传递。
```objc

struct __block_impl {
  void *isa;
  int Flags;
  int Reserved;
  void *FuncPtr;
};

static struct __main_block_desc_0 {
  size_t reserved;
  size_t Block_size;
  void (*copy)(struct __main_block_impl_0*, struct __main_block_impl_0*);
  void (*dispose)(struct __main_block_impl_0*);
} __main_block_desc_0_DATA = { 0, sizeof(struct __main_block_impl_0), __main_block_copy_0, __main_block_dispose_0};

struct __Block_byref_num1_0 {
  void *__isa;
  __Block_byref_num1_0 *__forwarding; // 指针
  int __flags;
  int __size;
  int num1;      // 实际保存__block变量的值 
};

struct __main_block_impl_0 {
  struct __block_impl impl;
  struct __main_block_desc_0* Desc;

  int num;
  NSString *__strong str;
  NSDate *__weak weakdate;
  __Block_byref_num1_0 *num1; // by ref

  __main_block_impl_0(void *fp,
                      struct __main_block_desc_0 *desc,
                      int _num,
                      NSString *__strong _str,
                      NSDate *__weak _weakdate,
                      __Block_byref_num1_0 *_num1,
                      int flags=0) : num(_num), str(_str), weakdate(_weakdate), num1(_num1->__forwarding) {
    impl.isa = &_NSConcreteStackBlock;
    impl.Flags = flags;
    impl.FuncPtr = fp;
    Desc = desc;
  }
};
```

### 3.3 __block 变量

`__block int`类型改写为`__Block_byref_num1_0`类型，传入block的是`__Block_byref_num1_0`指针。 最终可以通过`__Block_byref_num1_0`指针修改`num1`的值。



```objc
__block int num1 = 0;

__Block_byref_num1_0 num1 = {(void*)0,
                             (__Block_byref_num1_0 *)&num1, 
                             0, 
                             sizeof(__Block_byref_num1_0), 
                             0};

struct __Block_byref_num1_0 {
  void *__isa;
  __Block_byref_num1_0 *__forwarding; // num1 指针 指向原本的num1的地址
  int __flags;
  int __size;
  int num1;      // 实际保存__block变量的值 
};
```
  
## 总结

- Block的类型分为`_NSGlobalBlock`,`_NSMallocBlock`和`_NSStackBlock`，`_NSStackBlock`是Block定义时的临时类型，只要被变量持有就会变为`_NSMallocBlock` 或者 `_NSGlobalBlock`

- Block的本质是一个结构体，包含`isa`指针,默认初始化为`_NSStackBlock`。 Block的函数体定义为静态方法，静态方法的指针将保存在结构体的`FuncPtr`函数指针中。

- Block的捕获的变量将保存在结构体的成员变量中

- ？ `_NSStackBlock`是Block定义时的临时类型，但是通过改写为C语言，我们并没有发现 isa 修改的相关代码，这里涉及到`block_copy`的底层问题。