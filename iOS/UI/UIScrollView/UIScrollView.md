# UIScrollView

> A View that allows the scrolling and zooming of its contained views
  一个视图，允许滚动和缩放其包含的视图
  
## OverView

 - `UIScrollView` 是包含`UITableView`和`UITextView`在内的几个UIKit类的父类.
 
 - **UIScrollView**的中心概念（central notion）是一个视图，它的原点在**Content View**上是可调整（adjustable）的。它截取了**Content View**的在自己**frame**范围中的内容(**frame**通常和应用的main window一致（coincide）)。**UIScrollView**会追踪手指的移动并且调整原点。**Content View**透过**UIScrollView**显示自己的部分内容，但是绘制是由自己完成的。**UIScrollView**除了显示横向（horizontal）和竖向（vertical）的滚动条（scroll indicators），不绘制任何内容。**UIScrollView**必须知道**Content View**的大小，这样才能知道什么时候停止绘制。默认情况下，当滚动超过**Content View**的边界，会弹回来（bounce back）。

![UIScrollView][1]
  
 - 因为**UIScrollView**没有scrollbars，它必须知道一次触摸代表着滚动的意图还是追踪一个子视图的意图（ it must know whether a touch signals an intent to scroll versus an intent to track a subview in the content.）。因此，**UIScrollView**会临时拦截（intercept）点击事件，并启动一个定时器，在定时器触发之前，观察手指是否有移动。如果定时器触发前手指没有什么移动，就会向点击的子视图发送发送追踪事件（tracking event）。如果有移动，就会取消子视图的追踪并滚动**UIScrollView**。

```
// 子类可以重写这两个方法，处理滚动的手势
// override points for subclasses to control delivery of touch events to subviews of the scroll view
// called before touches are delivered to a subview of the scroll view. if it returns NO the touches will not be delivered to the subview
// this has no effect on presses
// default returns YES
- (BOOL)touchesShouldBegin:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event inContentView:(UIView *)view;
// called before scrolling begins if touches have already been delivered to a subview of the scroll view. if it returns NO the touches will continue to be delivered to the subview and scrolling will not occur
// not called if canCancelContentTouches is NO. default returns YES if view isn't a UIControl
// this has no effect on presses
- (BOOL)touchesShouldCancelInContentView:(UIView *)view;
```
- `UIScrollView`也可以处理内容的缩放（zooming）和平移（panning）。当用户做放大（pinch-out）或者缩小（pinch-in）的手势，UIScrollView会调整偏移量和范围。当手势进行中时，不会向子视图发送任何事件通知
- `UIScrollView` 必须有一个实现`UIScrollViewDelegate`的委托。

平移和缩放相关的方法有：

```
- (void)scrollViewDidZoom:(UIScrollView *)scrollView NS_AVAILABLE_IOS(3_2); 
// any zoom scale changes


- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;     
// return a view that will be scaled. if delegate returns nil, nothing happens

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view NS_AVAILABLE_IOS(3_2); 
// called before the scroll view begins zooming its content

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale; 
// scale between minimum and maximum. called after any 'bounce' animations


```

滚动相关的方法有：
```
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;                                               // any offset changes


// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset NS_AVAILABLE_IOS(5_0);
// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView;   // called on finger up as we are moving
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;      // called when scroll view grinds to a halt

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView; // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
```
 
## 状态保护（state preservation）
如果给UIViewController的`restorationIdentifier`属性赋值，系统会保存滚动相关的信息在应用关闭后，然后在应用重启后恢复状态。特别是，`zoomScale`，`contentInset`,`contentOffset`属性的值会被保存。

  [1]: UIScrollView.png
