# OC 内存管理

> OC 的内存管理是通过引用计数的机制实现。每一个OC对象都有一个`retainCount`的无符号整数属性，当对象被创建时，`retainCount`为1；当对象被变量持有时，`retainCount`加1；当变量不再持有对象时，`retainCount`减1；在`retainCount`为0时，对象被销毁。


## MRC

  > 手动管理引用计数和内存,需要手动在代码的相应地方添加内存管理的代码。

  ![MRC_Mehod][1]
   

  手动内存管理的原则 ：
 
    1、自己生成的对象，自己持有
    2、不是自己生成的对象也可以持有
    3、不需要自己持有的对象时，释放
    4、不是自己持有的对象，不可以释放
 
 ![MRC_Rule][2]

## ARC
   
 > ARC 是苹果引入的一种自动内存管理机制，会根据引用计数自动监视对象的生存周期，实现方式是在编译时期自动在已有代码中插入合适的内存管理代码以及在 Runtime 做一些优化

 > 在ARC环境下，一切内存管理代码都不可见，release，ratain，autorelease。retainCount都不可用（编译的时候会报错）,@autoreleasepool 在代码中可以使用.

 > 我们只需要关心，是否有循环引用带来的内存泄露 及 autorelease带来的 内存峰值

```

 for(int i = 0;i < 1000000; i++)
 {
      NSMutableString * str = [NSMutableString stringWithFormat:@"Hello world"];   
    /* *  str 指向的对象不是自己生成的，该对象在生成时，会自动插入autorelease
                                          *  的内存管理代码; 返回时，引用计数为 1，在被str持有后引用计数 为2
      *  当一次循环闭包结束,str的声明周期结束，自动插入release代码来释放对象
     *   此时引用计数为 1 ,对象不会被销毁，内存泄露 ， 只有当autoreleasepool 调用 drain方法，同时为对象的引用计数减 1                                                                                       *  
  }

  解决方法 ：
  for(int i = 0; i <　1000000; i++)
  {
        @autoreleasepool
        {
             NSMutableString * str = [NSMutableString stringWithFormat:@"Hello world"];    
        }
  }



  for(int i = 0;i < 1000000; i++)
  {
      NSMutableString * str = [[NSMutableString alloc] initWithFormat:@"asdasdasda"];
      /** 
        * 这里不会有内存泄露的问题，对象由str生成并持有 ，引用计数为 1
        * 当一次循环结束，str声明周期结束，自动插入release代码，引用计数减 1 
        * 此时对象引用计数为0，对象销毁  
        **/
  }

```


### 变量标识符：
                
       __strong                是默认使用的标识符。只有还有一个强指针指向某个对象，这个对象就会一直存活。

       __weak                  声明这个引用不会保持被引用对象的存活，如果对象没有强引用了，弱引用会被置为 nil

       __unsafe_unretained     声明这个引用不会保持被引用对象的存活，如果对象没有强引用了，它不会被置为 nil。如果它引用的对象被回收掉了，该指针就变成了野指针。

       __autoreleasing         用于标示使用引用传值的参数（id *），在函数返回时会被自动释放掉。

  

  ### 属性标识符：

   assign 表明 setter 仅仅是一个简单的赋值操作，通常用于基本的数值类型，例如CGFloat和NSInteger。
              
      strong 表明属性定义一个拥有者关系。当给属性设定一个新值的时候，首先这个值进行 retain ，旧值进行 release ，然后进行赋值操作。
              
      weak 表明属性定义了一个非拥有者关系。当给属性设定一个新值的时候，这个值不会进行 retain，旧值也不会进行 release， 而是进行类似 assign 的操作。不过当属性指向的对象被销毁时，该属性会被置为nil。
            
      unsafe_unretained 的语义和 assign 类似，不过是用于对象类型的，表示一个非拥有(unretained)的，同时也不会在对象被销毁时置为nil的(unsafe)关系。

      copy 类似于 strong，不过在赋值时进行 copy 操作而不是 retain 操作。通常在需要保留某个不可变对象（NSString最常见），并且防止它被意外改变时使用。



 ## 自动释放池：

 > Autorelase Pool 提供了一种可以允许你向一个对象延迟发送release消息的机制。当你想放弃一个对象的所有权，同时又不希望这个对象立即被释放掉（例如在一个方法中返回一个对象时），Autorelease Pool 的作用就显现出来了

 ###  使用方式：

   - 由RunLoop在每次事件循环开启前创建

   - NSAutoreleasePool

   - @autoreleasepool 

    

        
 ### 自动释放池 释放的契机：   
 > 系统在 runloop 中创建的 autoreleaspool 会在 runloop 一个 event 结束时进行释放操作。我们手动创建的 autoreleasepool 会在 block 执行完成之后进行 drain 操作


 ### 自动释放池和返回值:

> 如果一个函数的返回值是指向一个对象的指针，那么这个对象肯定不能在函数返回之前进行 release，这样调用者在调用这个函数时得到的就是野指针了，在函数返回之后也不能立刻就 release，因为我们不知道调用者是不是 retain 了这个对象，如果我们直接 release 了，可能导致后面在使用这个对象时它已经成为 nil 了。
 
> 为了解决这个纠结的问题， Objective-C 中对对象指针的返回值进行了区分，一种叫做 retained return value，另一种叫做 unretained return value。前者表示调用者拥有这个返回值，后者表示调用者不拥有这个返回值，按照“谁拥有谁释放”的原则，对于前者调用者是要负责释放的，对于后者就不需要了。
     
> 按照苹果的命名 convention，以 alloc, copy, init, mutableCopy 和 new 这些方法打头的方法，返回的都是 retained return value，例如 [[NSString alloc] initWithFormat:]，而其他的则是 unretained return value，例如 [NSString stringWithFormat:]。我们在编写代码时也应该遵守这个 convention

 MRC中：

```

retained return value:
                            
 // 调用者生成并持有，负责对象的释放                
- (MyCustomCalss *) initWIthName:(NSString *) name     {
    return [ [MyCustomClass alloc] init];      
}
                
 unretained return value：

// 对象不是由调用者生成，不负责对象的释放，由autoreleasepool负责                      
+ (MyCustomClass * )  myCustomClassWithName:(NSString *) name           
{                                                     
    //  添加autorelease ，是为了管理 对象生成时，引用计数的 加一
    return  [ [ [MyCustomClass alloc] init] autorelease];          
}

```

ARC中：

对于这两种方法，在ARC不需要过多关注他们的区别，ARC会自动为我们插入相应的内存管理代码，但还是要了解相应的原理

retained return value：

![retained return value][3]
                
对于retained return value 方法 ， ARC 会在离开方法闭包的范围前，返回值赋值的时候，持有这个对象。当从方法中接收到返回值时，ARC会释放这个对象

unretained return value：

![unretained return value][4]

ARC会在返回 返回值的时候，持有这个对象，然后离开局部闭包，之后当对象离开调用者生命周期的时候，释放；最坏的情况，会调用autorelease，但是调用者不能确定这个对象是否调用了autorelease
ARC虽然会做一些工作来缩短返回值的生命时间，但不会在强制调用者做额外的工作

    

## alloc/retain/release/dealloc的实现

   > 苹果是以散列表的方式保存对象的引用计数，散列表的key为对象内存块地址的散列值，value为对象的引用计数

## autoreleasepool的实现

   > 在苹果的实现中，`NSAutoreleasePool`是保存在堆栈中的；当某个对象调用autorelease，是将该对象添加到栈顶的`NSAutoreleasePool`


## 参考文档

[Java内存管理原理及内存区域详解][5]

[Objective-C 内存管理——你需要知道的一切][6]


[1]:pic/MRC_Method.png
[2]:pic/MRC_Rule.png
[3]:pic/retained_return_value.png
[4]:pic/unretained_return_value.png
[5]:http://www.importnew.com/16433.html
[6]:https://segmentfault.com/a/1190000004943276#articaleHeader6
