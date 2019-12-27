# 视图的层次结构（UIViewHierarchy）
> 创建一个UIView，需要指定它的初始大小和相对于父视图的位置

```
CGRect  viewRect = CGRectMake(10, 10, 100, 100);
UIView* myView = [[UIView alloc] initWithFrame:viewRect];
```

> 通过`addSubView:` 方法可以向父视图中添加子视图，且添加在其他兄弟视图（siblings）的最上面


##  以下方法用于添加和移除子视图，修改视图的图层堆栈中的深度

```objc
@interface UIView(UIViewHierarchy)  // 视图的层次机构

- (void)removeFromSuperview;
- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index;
- (void)exchangeSubviewAtIndex:(NSInteger)index1 withSubviewAtIndex:(NSInteger)index2;

- (void)addSubview:(UIView *)view;
- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview;
- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview;

- (void)bringSubviewToFront:(UIView *)view;
- (void)sendSubviewToBack:(UIView *)view;


- (BOOL)isDescendantOfView:(UIView *)view;  // 是否是view的后代视图， 当view是self时，返回YES

@end

```


## 当添加，移除子视图或者添加到父视图或者从父视图中移除时会调用以下方法

```objc

- (void)didAddSubview:(UIView *)subview;
- (void)willRemoveSubview:(UIView *)subview;

- (void)willMoveToSuperview:(nullable UIView *)newSuperview;     // 当从父视图中移除时。newSuperview为nil
- (void)didMoveToSuperview;

- (void)willMoveToWindow:(nullable UIWindow *)newWindow; // 当从父视图中移除时，newWindow为nil
- (void)didMoveToWindow;

```

## layoutSubviews


``` objc

// Allows you to perform layout before the drawing cycle happens. -layoutIfNeeded forces layout early

- (void)setNeedsLayout;      // layoutSubviews在下一次绘制循环时执行
- (void)layoutIfNeeded;      // layoutSubviews在下一次绘制循环之前更早的时机执行

- (void)layoutSubviews;

```






