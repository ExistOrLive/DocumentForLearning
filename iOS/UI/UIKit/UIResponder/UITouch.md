# UITouch

`UITouch` 是一个描述点击屏幕的位置，范围，移动距离以及压力的对象。


你可以通过`UIEvent`类的一下几个方法获取`UITouch`对象：

```objc

@interface UIEvent

@property(nonatomic, readonly, nullable) NSSet <UITouch *> *allTouches;
- (nullable NSSet <UITouch *> *)touchesForWindow:(UIWindow *)window;
- (nullable NSSet <UITouch *> *)touchesForView:(UIView *)view;
- (nullable NSSet <UITouch *> *)touchesForGestureRecognizer:(UIGestureRecognizer *)gesture

@end

```

而通过`UITouch`对象可以访问：

- Touch发生的View或者Window

- Touch在View或者Window中的位置

- Touch的近似半径

- Touch的压力值




[UITouch][1]

[1]: https://developer.apple.com/documentation/uikit/uitouch?language=objc