# Foundation 和 Core Foundation 之间的转换

> Foundation 和 Core Foundation ，C 对象之间的通过Toll_free bridge实现


- __bridge

```objc

// 在转化过程中，对象的引用计数都不曾发生变化

id a = [[NSArray alloc] init];

CFArrayRef cfA = (__bridge CFArrayRef)a;

id b = (__bridge id)cfA; 

```


- __bridge_retained

```objc

// 用于将OC对象转化为CF对象或c语言对象 ， 并引用计数加1

id a = [[NSArray alloc] init];

CFArrayRef cfA = (__bridge CFArrayRef)a;    // 此时对象的引用计数为2


```


- __bridge_transfer 


```
//  用于将CF对象转化为OC对象 ， 并引用计数加1

```