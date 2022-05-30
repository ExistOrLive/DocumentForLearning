# CALayer

>  一个管理基于图像内容并允许你在内容上执行动画的对象(An object that manages image-based content and allows you to perform animations on that content)
----

## Overview

> `CALayer` 经常作为视图`UIView`的后备存储（the backing store），同时也可以单独用于显示内容。`CALayer`的主要工作是管理你提供的画面，也有一些画面相关的属性可以设置，例如background color，border和shadow。为了管理画面，`CALayer`维护了一些内容的几何信息（position，size和transform）。修改`CALayer`的属性就是启动一个基于内容和几何信息的动画。`CALayer`通过继承`CAMediaTiming`协议封装（encapsulates）动画的持续时间和节奏。

> 如果一个`CALayer`对象是通过`UIView`创建的，这个View自动作为`CALayer`的`delegate`，且不可以修改这种关系。对于你自己创建的`CALayer`对象，你需要为它分配一个`delegate`对象，来为`CALayer`提供图层的内容和执行其他任务。一个`CALayer`对象还需要有一个`layoutManager`对象来管理子图层的布局。

## CALayerDelegate

```

@protocol CALayerDelegate <NSObject>
@optional

/* If defined, called by the default implementation of the -display
 * method, in which case it should implement the entire display
 * process (typically by setting the `contents' property). */

- (void)displayLayer:(CALayer *)layer;

/* If defined, called by the default implementation of -drawInContext: */

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx;

/* If defined, called by the default implementation of the -display method.
 * Allows the delegate to configure any layer state affecting contents prior
 * to -drawLayer:InContext: such as `contentsFormat' and `opaque'. It will not
 * be called if the delegate implements -displayLayer. */

- (void)layerWillDraw:(CALayer *)layer
  CA_AVAILABLE_STARTING (10.12, 10.0, 10.0, 3.0);

/* Called by the default -layoutSublayers implementation before the layout
 * manager is checked. Note that if the delegate method is invoked, the
 * layout manager will be ignored. */

- (void)layoutSublayersOfLayer:(CALayer *)layer;

/* If defined, called by the default implementation of the
 * -actionForKey: method. Should return an object implementating the
 * CAAction protocol. May return 'nil' if the delegate doesn't specify
 * a behavior for the current event. Returning the null object (i.e.
 * '[NSNull null]') explicitly forces no further search. (I.e. the
 * +defaultActionForKey: method will not be called.) */

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event;

@end

```