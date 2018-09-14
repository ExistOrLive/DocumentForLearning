
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

> UIView 可以嵌入（nested）其他UIView中创建视图层级（hierarchies）；父视图（superView）可以包含多个子视图（subView），但是子视图只能有一个父视图 ；默认情况下，当子视图的可见区域超过父视图的范围，不会裁剪子视图的内容

```
// 可以修改clipsToBounds 来修改默认选项
@interface UIView(UIViewRendering)
@property(nonatomic) BOOL clipsToBounds; // When YES, content and subviews are clipped to the bounds of the view. Default is NO.
@end
```
> 每个视图的几何结构（geometry）都是通过`frame`和`bounds`属性来定义的。
`frame` 定义了视图在父视图坐标系（coordinate）中的原点（origin）和大小（dimensions）。
`bounds`属性 用于定义视图的内部维度（internal demensions）,并且经常用于自定义的绘制代码（used exclusively in custom draw code）
`center` 属性 提供了一个更加方便的方法重新定位视图而不用直接修改frame和bounds

```
@interface UIView(UIViewGeometry)

// animatable. do not use frame if view is transformed since it will not correctly reflect the actual location of the view. use bounds + center instead.
@property(nonatomic) CGRect            frame;

// use bounds/center and not frame if non-identity transform. if bounds dimension is odd, center may be have fractional part
@property(nonatomic) CGRect            bounds;      // default bounds is zero origin, frame size. animatable
@property(nonatomic) CGPoint           center;      // center is center of frame. animatable

@end
```

