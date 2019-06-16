# Block （代码块）

> **Block**是iOS 4 引入的C语言扩展功能，实质上是带有自动变量(局部变量)的匿名函数。

> 如下，函数的定义是必须有名字的,函数可以通过函数指针来传递和调用;Block的定义不需要名字，但是需要赋给Block变量才可以使用

```
/**
 *
 * 函数的定义必须是有名字的
 **/
int func(int count)
{
    printf("%d",count);
    return count;
}

int (*funcpter)(int) = &func;

(*funcpter)(10);

／**
  *
  * block的定义不需要名字，然后赋给一个block变量
  **／

  int (^testBlock)(int) = ^int(int count){
    printf("%d",count);
    return count;
  }

  testBlock(10);


```

> 我们知道在函数的函数体中可以访问以下的变量：

- 在函数体中定义的局部变量 
- 函数的参数
- 静态变量
- 静态全局变量 
- 全局变量

> 而在Block的闭包中，不仅可以访问以上的变量，还可以访问在定义Block的闭包中可以访问的一切变量（包括self，局部变量，实例变量).这些变量就是Block可以访问的`自动变量`. 

如下图：在block中访问了局部变量，self，实例变量

![][1]

![][2]

> 如上图，打印了block中访问自动变量的地址，只有局部变量的地址是相同的。因此Block访问这些变量是将变量值做了一个浅拷贝，这样就没有办法修改原有的变量了。即`截获自动变量的瞬时值`

## Block的实现

![block_实现1][3]

> 如上图所示，我们在main函数中定义了一个block。接下来，我们用clang编译器命令(`clang -rewrite-objc main.m`)将OC的代码翻译为C语言的实现。

C语言实现如下：

![][4]

### __main_block_impl_0

> `Block`的定义翻译为`__main_block_impl_0`这个结构体变量的定义。`__main_block_impl_0`的结构如下：

![][5]

> 在`__main_block_impl_0`结构体中包括`__block_impl`结构体变量，`__main_block_desc_0`结构体指针，构造函数以及`e`,`str`,`c`等其他变量。

>`__block_impl`中保存的是Block的类型以及具体实现（函数指针）；`__main_block_desc_0`中记录的是block的附加信息；`e`,`str`,`c`等变量保存的是block捕获的自动变量，在ARC中是强引用。

### __block_impl

> `__block_impl`结构体如下：

![][7]

> 可以看到`__block_impl`结构中包含`isa`变量，保存block的类型，所以block是一个OC对象；

>`FuncPtr`是一个函数指针，指向Block的具体实现。可以看到该函数的参数不只有block的参数，还有一个`__main_block_Impl_0`指针，通过这个指针函数可以访问block的自动变量。

![][6]

### __main_block_desc_0

> `__main_block_desc_0`结构如下，主要记录block的附加信息，包括结构体的大小，需要capture和dispose的变量列表

![][8]

### 自动变量

> Block捕获的自动变量，会保存的在`__main_block_impl`结构体中。

- 对于基本数据类型，是将值拷贝到`__main_block_impl`结构体中，所以在Block中就无法访问原来的变量了。

- 在ARC中，捕获的OC对象是通过强引用保存到`__main_block_impl`结构体中，因此需要注意引用循环的问题。

- `__block变量`实质上是一种结构体，结构如下：其中`__forwarding`保存的是`__block变量`的地址，`c`保存的是`__block变量`的值。`__main_block_impl`中会保存该结构体的指针。

   ![][9]


## Block的类型以及内存管理

> 在 OC中，总共由三种block类型：

1. _NSGlobalBlock,全局的静态block，不会访问任何的外部变量，它的生命周期是全局的。

2. _NSStackBlock,保存在栈上的block，当定义block的闭包结束，就会被销毁

3. _NSMallocBlock,保存在堆上的block，当引用计数为0时，会被销毁。

### _NSGlobalBlock

> 不访问任何自动变量的Block都是_NSGlobalBlock类型，且类型不会改变。

### _NSStackBlock

> 访问自动变量的block在定义时默认是_NSStackBlock类型，只有调用了copy类型，才会变成_NSMallocBlock类型。

### _NSMallocBlock

> 在ARC中，当Block被定义后，传给一个OC变量，会自动调用Block的copy方法，这个时候Block就会变为_NSMallocBlock类型。在MRC，则需要手动调用Copy

![][10]

![][11]

## 避免循环引用

> 由于Block在访问自动变量时，比较容易造成循环引用。对于这个问题，需要将引用的一方变为weak，避免循环引用。

```

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







[1]:pic/test.png
[2]:pic/result.png
[3]:pic/block_实现1.png
[4]:pic/block_实现2.png
[5]:pic/block_实现3.png
[6]:pic/block_实现4.png
[7]:pic/block_实现5.png
[8]:pic/block_实现6.png
[9]:pic/block_实现7.png
[10]:pic/Block的类型以及内存管理1.png
[11]:pic/Block的类型以及内存管理2.png

