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


## 





[1]:pic/test.png
[2]:pic/result.png


