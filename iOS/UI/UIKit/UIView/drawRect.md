# drawRect

> Draws the receiver's image within the passed-in rectangle
  在传入的矩形区域中绘制接收者的图像
  
```
   - (void) drawRect:(CGRect)rect;
```

## Parameters

> **rect** 
The portion of the view’s bounds that needs to be updated. The first time your view is drawn, this rectangle is typically the entire visible bounds of your view. However, during subsequent drawing operations, the rectangle may specify only part of your view.

> 视图边界需要更新的部分。
你的视图第一次绘制的时候，矩形区域特指视图的整个可视区域。
但是当随后的（subsequent）绘制操作，矩形区域只是视图的部分区域。

## Discussion
 - `drawRect:`方法的默认实现什么都不做。使用UIKit 和 CoreGraphics技术的子类需要重写这个方法，并实现相应的绘制代码。但是如果仅仅是想显示特定的背景颜色或者使用底层对象（underlying layer object），没必要重写该方法
 
 -  当这个方法调用的时候，UIKit已经配置好合适的绘制环境，你可以简单的调用任何绘制的方法和函数。尤其是，UIKit创建和配置了一个graphics context 并调整它的形状让它的原点与矩形区域的原点匹配。可以通过调用`UIGraphicsGetCurrentContext`函数获取Graphics context的引用，但是不能够建立强引用，因为它可能在两次的`drawRect:`调用之间发生改变
 
 -  必须把绘制的内容限制在rect指定的矩形区域中

 -  如果直接继承UIView，`drawRect`实现方法不需要调用父类的`drawRect`，因为UIView的`drawRect`什么都没有做；但是间接继承，必须调用父类的`drawRect`
 
 -  在代码中不应该直接调用`drawRect`，而是调用`setNeedDisplay`和`setNeedDisplayAtRect` 去触发重新绘制
 

## Reference

[drawRect 苹果开发者文档][1]

 


  [1]: https://developer.apple.com/documentation/uikit/uiview/1622529-drawrect?language=occ