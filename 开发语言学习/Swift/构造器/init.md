# 构造器

## 指定构造器（designated initializer）

> Designated initializers are the primary initializers for a class. A designated initializer fully initializes all properties introduced by that class and calls an appropriate superclass initializer to continue the initialization process up the superclass chain. 


> 指定构造器是类的主要构造器, 要在指定构造器中初始化所有的属性, 并且要在调用父类合适的指定构造器.

## 方便构造器 (convinience initializer)

> 便利构造器是类的次要构造器, 你需要让便利构造器调用同一个类中的指定构造器, 并将这个指定构造器中的参数填上你想要的默认参数.


## Rule

- 指定构造器必须调用它直接父类的指定构造器方法.

- 便利构造器必须调用同一个类中定义的其它初始化方法.
    
- 便利构造器在最后必须调用一个指定构造器.



## 参考文档

[Swift 类构造器的使用][1]

[1]: https://my.oschina.net/hejunbinlan/blog/470123