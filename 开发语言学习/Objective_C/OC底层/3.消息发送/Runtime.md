# Runtime 

`Runtime` 也就是 `运行时`。在OC语言中，运行时特性非常的重要，涉及到OC面向对象的封装，继承，多态等特性的实现。

OC中，对象的`方法调用`不同于 C/C++ 中函数的`静态调用`，属于`动态调用`。

- `静态调用` 指在编译时就确定调用函数的入口地址。

- `动态调用` 指在编译时无法确定函数的入口地址，需要在 `运行时` 确定。


OC中，对象的`方法调用`实际上是对 `objc_msgSend` 函数的静态调用, `objc_msgSend`在`运行时`从类中寻找对应的方法实现，并调用。(当然还会涉及消息转发流程，这里暂不赘述)。

也就是说，一个方法的真正实现需要在 `运行时` 去查询。 这就为OC实现面向对象特性提供了基础，也为实现了许多其他的动态特性。

## Objective-C Runtime Programming Guide

苹果官方文档描述：OC语言将许多决策从编译时，链接时推迟到运行时。因此需要一套运行时系统执行代码。

运行时系统主要职责： 加载OC类并创建OC类对象，创建OC对象，消息发送和转发 以及 在运行时获取对象或者类的信息。


[Objective-C Runtime Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40008048)

## 与Runtime交互

与Runtime交互有三种方式：

- 通过OC源码
   
      OC源码中的方法调用都会调用Runtime
    

- NSObject类定义的方法

    ```objc 
    - description
    - isKindOfClass: 
    - isMemberOfClass:
    - respondsToSelector:
    // .....
    ```

- Runtime API 
  
  ```
  #import <objc/runtime.h>
  #import <objc/message.h>
  ```
![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-05-07%20%E4%B8%8B%E5%8D%886.27.31.png)





