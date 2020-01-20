# Overview

## ViewController自定义转场动画
 
 - `UIViewControllerTransitioningDelegate`自定义模态转场动画时使用
 - `UINavigationControllerDelegate` 自定义navigation转场动画时使用。
 - `UITabBarControllerDelegate`  自定义tab转场动画时使用。


## UIViewControllerTransitioningDelegate

> `UIViewControllerTransitioningDelegate` 用于modal显示VC的自定义转场动画时需要的 `Animator Object`,`Interactive Animator Object` 和 `Presentation controller`。 



```objc
@protocol UIViewControllerTransitioningDelegate <NSObject>

@optional

// 动画转场
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source;

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed;

// 交互性转场
- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator;

- (nullable id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator;

// 新VC的展示style
- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source API_AVAILABLE(ios(8.0));

@end
```

- `Animator Object`实现了`UIViewControllerAnimatedTransitioning`协议，在显示和隐藏view时创建动画。

- `Interactive animator objects`实现了`UIViewControllerInteractiveTransitioning`协议，通过点击事件或者手势驱动一个定时的动画

- `Presentation controller`


## The Custom Animation Sequence

> 当modal显示一个VC且VC的`transitionDelegate`是有效的。UIKit就会开始使用`transitionDelegate`提供的自定义动画展示VC。


1. 首先调用` animationControllerForPresentedController:presentingController:sourceController:`方法，获取`animatot object`对象，该对象定义了一个定时的转场动画。 如果该对象为nil，则不会使用自定义转场动画，而会使用`modalTransitionStyle`指定的系统转场动画

2. 接着调用`interactionControllerForPresentation: `方法，获得`Interactive animator objects`对象。如果该对象不为空，则自定义的转场动画就可以通过手势或者触摸事件来控制

3. 调用`Animator Object`的`transitionDuration:`方法，获取动画的时长

4. 对于非交互性动画，UIKit调用`Animator Object`的`animateTransition: `方法
 
   对于交互性动画，UIKit调用`Interactive Animator Object`的`startInteractiveTransition:`方法

5. 当动画完成后，调用`UIViewControllerContextTransitioning`的`completeTransition`方法。这个步骤是必须的，只有调用的该方法，UIKit才会结束转场的过程


[Presenting a View Controller][1]

[Customizing the Transition Animations][2]



## UINavigationControllerDelegate





## 定义动画内容

 `UIViewControllerAnimatedTransitioning`             动画转场
 
 `UIViewControllerInteractiveTransitioning`          交互性转场


## 表示动画上下文

 `UIViewControllerContextTransitioning`             





[Customizing the Transition Animations][2]



 [1]: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/PresentingaViewController.html#//apple_ref/doc/uid/TP40007457-CH14-SW1

 [2]: https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/CustomizingtheTransitionAnimations.html#//apple_ref/doc/uid/TP40007457-CH16-SW1