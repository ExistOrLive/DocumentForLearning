# 常见面试题

## 对于OC 属性的理解

> `@property` 的本质就是类的`setter`和`getter`方法。
 
    OC的编译器会在编译期为类生成相应的方法。`@property`还会在类中生成相应的实例变量，也可以通过`@synthesize`手动关联实例变量

> `@property`的特质(attributes)有以下四种：

   -  **原子性 (atomic / nonatomic)   atomic默认** 
     
     默认情况下，由编译期合成的方法会通过锁机制确保其原子性，即默认atomic；如果属性具有nonatomic特质，则不会使用同步锁

   - **读写权限 (readonly / readwrite) readwrite默认**
    
    readwrite特质表示属性拥有getter和setter方法；readonly特质表示属性仅拥有getter方法。

   - **内存语意管理(assign/strong/weak/unsafe_unretained/copy)**
      
    assign特质，只适用于基本数据类型和结构体类型等，不适用于OC对象，单纯的赋值操作；
    strong特质，适用于OC对象，表示一种“拥有关系”。设置方法会先保留新值，再释放旧值，再将新值赋给实例变量
    weak特质，适用于OC对象，表示一种“非拥有关系”。设置方法不会释放旧值，也不会保留新值，当对象被销毁时，实例变量会被置为nil
    unsafe_unretained特质，适用于OC对象，表示一种"危险的非拥有关系"。设置方法不会释放旧值，也不会保留新值，当对象被销毁时，实例变量不会被置为nil
    copy特质，适用于OC对象，表示将OC对象拷贝为新的对象，将新的对象保留，释放旧值。

  - **方法名(setter=\<name\>/ getter=\<name\>)**
    

### Tip

1.  `在重写属性的setter和getter方法时，一定要遵守该属性所声明的语义。这一条非常重要`
    
   
2.  `开发过程中，在不考虑多线程同步的问题时，应该使用nonatomic，避免性能问题`

 见Demo[PropertyTestDemo][1]




[1]: https://github.com/ExistOrLive/DemoForLearning/tree/master/PropertyTestDemo

     


