# KVO的底层实现

 KVO的底层实现原理：
 
1. 利用OC的运行时机制，在运行时为被观察对象的类A创建一个子类`NSKVONotifying_XXX`，

2. 并修改子类`NSKVONotifying_XXX`被观察属性的setter方法实现，设置方法实现为`Foundation`的`_NSSetXXXValueAndNotify`函数。

3. 最后将被观察对象的类即isa指针修改为子类`NSKVONotifying_XXX`

4. 添加观察者后，调用对象的setter方法，实际上调用到`Foundation`的`_NSSetXXXValueAndNotify`函数，在函数中依次调用`willChangeValueForKey` , 父类原来的setter ,`didChangeValueForKey`

![KVO底层实现][1]

### 由上图可知

- 在添加观察者之前test1的实现类为`KVOTest`，`setValue1:`方法的函数指针指向**0x0000000100001370**

- 在添加观察者之后test1的实现类为`NSKVONotifying_KVOTest`，`setValue1:`方法的函数指针指向 **0x00007fff4546543f**

----

## 代码实现KVO

具体代码参考[KVOCode][2]

![Runtime_KVO][3]

- 首先利用运行时的方法`objc_allocateClassPair` 和 `objc_registerClassPair` 创建子类

- 接着为子类添加方法`class_addMethod` 

- 最后修改被观察者的实现类`object_setClass`

----

[1]: pic/KVO底层实现.png
[2]: KVOCode
[3]: pic/Runtime_KVO.png