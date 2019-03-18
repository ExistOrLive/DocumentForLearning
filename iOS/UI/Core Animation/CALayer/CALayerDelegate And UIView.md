# CALayerDelegate And UIView

> `CALayer` 有一个delegate属性，需要分配一个实现`CALayerDelegate`协议的实例。而在`UIView`中`CALayer`的`delegate`就是`UIView`本身。 

我们就来看看`CALayer`和`UIView`之间是怎么交互的。 [实验代码](TestApp)

我们在代码中利用Runtime，为`UIView`的部分方法添加了日志打印。我们主要观察自定义视图`DrawRectTestView`的方法调用。

###  `DrawRectTestView` 没有实现`DrawRect`

![DrawRectTestView_NODrawRect_Log][1]

> 由日志可知：



###  `DrawRectTestView` 实现`DrawRect`

![DrawRectTestView_DrawRect_Log][2]



[1]: pic/DrawRectTestView_NODrawRect_Log.png
[2]: pic/DrawRectTestView_DrawRect_Log.png