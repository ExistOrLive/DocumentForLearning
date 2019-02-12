
# UIView 

> An object that manages the content for a rectangular area on the screen.
> 管理屏幕上的一个矩形区域内容的对象

> **UIView** 是一个具体（concrete）的类，可以用于创建实例，用于显示固定的背景颜色；也可以派生它绘制更复杂（sophisticated）的内容。

## UIView 的主要功能

- **绘制和动画(*Drawing and animation*)** 

  使用UIKit和Core Graphics在矩形区域中绘制内容*（Views draw content in their rectangular area using UIKit or Core Graphics.）*

  一些View属性可以以动画形式更新 *(Some view properties can be animated to new values.)*

- **布局和子视图管理*（Layout and subview management）**

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
## 视图的几何机构（UIViewGeometry）

> 每个视图的几何结构（geometry）都是通过`frame`和`bounds`属性来定义的。
`frame` 定义了视图在父视图坐标系（coordinate）中的原点（origin）和大小（dimensions）。
`bounds`属性 用于定义视图的内部维度（internal demensions）,并且经常用于自定义的绘制代码（used exclusively in custom draw code）
`center` 属性 提供了一个更加方便的方法重新定位视图而不用直接修改frame和bounds

```
@interface UIView(UIViewGeometry) // 管理视图的大小和位置即视图的几何图形

// animatable. do not use frame if view is transformed since it will not correctly reflect the actual location of the view. use bounds + center instead.
@property(nonatomic) CGRect            frame;

// use bounds/center and not frame if non-identity transform. if bounds dimension is odd, center may be have fractional part
@property(nonatomic) CGRect            bounds;      // default bounds is zero origin, frame size. animatable
@property(nonatomic) CGPoint           center;      // center is center of frame. animatable

@end
```
## 视图的层次结构（UIViewHierarchy）
> 创建一个UIView，需要指定它的初始大小和相对于父视图的位置

```
CGRect  viewRect = CGRectMake(10, 10, 100, 100);
UIView* myView = [[UIView alloc] initWithFrame:viewRect];
```

> 通过`addSubView:` 方法可以向父视图中添加子视图，且添加在其他兄弟视图（siblings）的最上面

```
@interface UIView(UIViewHierarchy)  // 视图的层次机构

- (void)removeFromSuperview;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2;

- (void)addSubview:(UIView *)view;
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview;
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview;

@end

```

> 创建了视图之后，可以通过设置视图的***Auto Layout***规则来控制视图是如何响应其他相关层次结构的变化

## 视图的绘制周期
> 当视图第一次显示或者视图的部分内容变得可见时，系统会要求视图绘制它的内容。

> 对于包含`UIKit`和`Core Graphics`内容的视图，系统会调用视图的`drawRect:`方法
> 当视图的内容发生变化时，你有责任去通知系统，视图需要重新绘制。
需要调用`setNeedsDisplay`或者`setNeedDiaplayInRect:`。这两个方法会通知系统在下一个绘制周期中更新视图。

#### tips
> 如果使用OpenGL ES去绘制视图，就需要使用`GLKView`类替代`UIView`

## 视图的运行时交互模型（The Runtime Interaction Model For Views）

 1. 用户触摸屏幕
 2. 硬件将触摸事件（touch event）报告给UIKit framework
 3. UIKit Framework 将触摸事件打包成一个UIEvent对象，派发给合适的UIView
 4. 事件处理代码会相应这次事件，你的代码一般会
     - 改变视图的属性 （frame，bounds，alpha等）
     - 调用`setNeedsLayout`方法标记视图需要布局更新（layout update）
     - 调用`setNeedDiaplay`或者`setNeedDisplayInRect:`方法标记视图需要重新绘制
     - 通知UIViewVController更新数据源
 5. 如果视图的几何结构发生变化，UIKit会遵循以下几个方法去重新绘制视图
     - 如果你配置了AutoResizing规则，UIKit会根据这些规则区调整视图
     - 如果重写了`layoutSubView`，UIKit会调用它
 6.  如果视图的任何部分被标记需要重新绘制，UIKit会调用drawRect:
 7.  更新的视图会被发送到图形硬件显示
 8.  图形硬件将内容先是在屏幕上
![The Runtime Interaction Model For Views][1]


  [1]:UIView的运行时交互模型.png
