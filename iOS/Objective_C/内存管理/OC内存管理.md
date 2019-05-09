# OC 内存管理

> OC 的内存管理是通过引用计数的机制实现。每一个OC对象都有一个`retainCount`的无符号整数属性，当对象被创建时，`retainCount`为1；当对象被变量持有时，`retainCount`加1；当变量不再持有对象时，`retainCount`减一；在`retainCount`为0时，对象被销毁。

## MRC

## ARC

## 属性标识符 & 变量标识符

## 自动释放池（autoreleasepool）

## alloc/retain/release/dealloc的实现

   > 苹果是以散列表的方式保存对象的引用计数，散列表的key为对象内存块地址的散列值，value为对象的引用计数

## autoreleasepool的实现

   > 在苹果的实现中，`NSAutoreleasePool`是保存在堆栈中的；当某个对象调用autorelease，是将该对象添加到栈顶的`NSAutoreleasePool`

