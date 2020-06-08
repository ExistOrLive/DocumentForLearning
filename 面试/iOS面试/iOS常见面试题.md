# 常见面试题

## 对于OC 属性的理解

[属性][1]




## 对于内存管理(ARC/MRC)的理解

 [内存管理][2]


 ## KVO 

 **1、iOS用什么方式实现对一个对象的KVO？(KVO的本质是什么？)**
- 1、利用RuntimeAPI动态生成一个子类`NSKVONotifying_XXX`，并且让instance对象的isa指向这个全新的子类`NSKVONotifying_XXX`
- 2、当修改对象的属性时，会在子类`NSKVONotifying_XXX`调用Foundation的`_NSSetXXXValueAndNotify`函数
- 3、在`_NSSetXXXValueAndNotify`函数中依次调用
        - 1、willChangeValueForKey
        - 2、父类原来的setter
        - 3、didChangeValueForKey，didChangeValueForKey:内部会触发监听器（Oberser）的监听方法( observeValueForKeyPath:ofObject:change:context:）
 
 
**2、如何手动触发KVO方法**
手动调用`willChangeValueForKey`和`didChangeValueForKey`方法

键值观察通知依赖于 NSObject 的两个方法: `willChangeValueForKey:` 和 `didChangeValueForKey`。在一个被观察属性发生改变之前， `willChangeValueForKey:` 一定会被调用，这就
会记录旧的值。而当改变发生后， `didChangeValueForKey` 会被调用，继而 `observeValueForKey:ofObject:change:context: `也会被调用。如果可以手动实现这些调用，就可以实现“手动触发”了

 有人可能会问只调用`didChangeValueForKey`方法可以触发KVO方法，其实是不能的，因为`willChangeValueForKey:` 记录旧的值，如果不记录旧的值，那就没有改变一说了


**3、直接修改成员变量会触发KVO吗**
不会触发KVO，因为`KVO的本质就是监听对象有没有调用被监听属性对应的setter方法`，直接修改成员变量，是在内存中修改的，不走`set`方法




**4、不移除KVO监听，会发生什么**
- 不移除会造成内存泄漏
- 但是多次重复移除会崩溃。系统为了实现KVO，为NSObject添加了一个名为NSKeyValueObserverRegistration的Category，KVO的add和remove的实现都在里面。在移除的时候，系统会判断当前KVO的key是否已经被移除，如果已经被移除，则主动抛出一个NSException的异常

     
[1]:../../iOS/Objective_C/属性/属性.md
[2]:../../iOS/Objective_C/内存管理/OC内存管理.md

## Block

