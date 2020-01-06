# UIGestureRecognizer

## Overview
> `UIGestureRecognizer`是最简单的方式处理touch和press事件。`UIGestureRecognizer`封装了所有需要处理的逻辑，拦截事件并与已知的模式匹配。

> `UIGestureRecognizer`有两种类型，discrete（离散的） 和 continuous（连续的）。

- `discrete gesture recognizer` 在手势识别后，仅会调用一次action方法。例如 `UITapGestureRecognizer`
- `continuous gesture recoginzer` 会调用action方法多次，每当手势事件的信息发生改变都会触发。 例如 `UIPanGestureRecognizer`每当触摸位置发生改变时触发action方法。

## config a gesture recognizer


## responding to gestures

```objc

@property(nonatomic,readonly) UIGestureRecognizerState state;  // the current state of the gesture recognizer

```

> `UIGestureRecognizer`的`state`属性表明了当前的状态。每次调用action方法时，都需要检查state的状态，作出相应的调整。



[handle UIKit Gestures][1]






[1]: https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures