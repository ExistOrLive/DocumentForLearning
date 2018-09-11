
# UIView 

> An object that manages the content for a rectangular area on the screen.
> 管理屏幕上的一个矩形区域内容的对象

> **UIView** 是一个具体（concrete）的类，可以用于创建实例，用于显示固定的背景颜色；也可以派生它绘制更复杂（sophisticated）的内容。

## UIView 的主要功能

- **绘制和动画(*Drawing and animation*)** 

  使用UIKit和Core Graphics在矩形区域中绘制内容*（Views draw content in their rectangular area using UIKit or Core Graphics.）*

  一些View属性可以以动画形式更新 *(Some view properties can be animated to new values.)*

- **布局和子视图管理*（Layout and subview management）***

  视图可能会包含0个或多个子视图*（Views may contain zero or more subviews.）*

  视图可以调节尺寸和安置它们的子视图 *（Views can adjust the size and position of their subviews.）*

  使用Auto Layout来定义调整视图大小和重新定位视图的规则，以响应视图层次结构中的更改 *（Use Auto Layout to define the rules for resizing and repositioning your views in response to changes in the view hierarchy.）*

- **事件处理*（Event handling）***

  UIView 是 UIResponder 的子类，能够响应触摸和其他事件 *（A view is a subclass of UIResponder and can respond to touches and other types of events.）*

  UIView能够安装手势识别来处理一些通用的手势*（Views can install gesture recognizers to handle common gestures.）*


