# CALayerDelegate And UIView

> `CALayer` 有一个delegate属性，需要分配一个继承`CALayerDelegate`协议的实例。而在`UIView`中`CALayer`的`delegate`就是`UIView`本身。 

我们就来看看`CALayer`和`UIView`之间是怎么交互的。 [实验代码](TestApp)

我们在代码中利用Runtime，为`UIView`的部分方法添加了日志打印。我们主要观察自定义视图`DrawRectTestView`的方法调用。

###  `DrawRectTestView` 没有实现`DrawRect`

![DrawRectTestView_NODrawRect_Log](pic/DrawRectTestView_NODrawRect_Log)

有日志可知




![DrawRectTestView_DrawRect_Log](pic/DrawRectTestView_DrawRect_Log)

