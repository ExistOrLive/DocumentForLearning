
# UIPanGestureRecognizer

> 追踪手指在屏幕上的移动，然后在content中应用该移动。

# Overview

> 当用户在屏幕上移动手指，pan gesture就会发生。`UIPanGestureRecoginzer`用于处理一般的平移手势。`UIScreenEdgePanGestureRecognizer`用于从屏幕边缘开始的平移手势。


> 当必要的初始平移达到后，`UIPanGestureRecognizer`进入`began`状态.
手势开始的时候，`UIPanGestureRecognizer` 会记下手指的初始位置，每当手指位置发生移动，都会调用action方法，此时`UIPanGestureRecognizer`进入`change`状态。可以通过`-translationInView:`方法获取手指相对与初始位置的位置。手指离开屏幕后，此时`UIPanGestureRecognizer`进入`cancel`状态





[handle pan gestures][1]

[1]: https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/handling_uikit_gestures/handling_pan_gestures