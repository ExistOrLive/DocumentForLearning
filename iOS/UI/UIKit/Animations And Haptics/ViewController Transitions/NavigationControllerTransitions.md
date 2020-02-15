# NavigationControllerTransitions

## 默认的转场动画

> `UINavagationController`默认的转场动画是右进右出，在push和pop时设置动画的开启和关闭

## 右滑手势

> `UINavagationController`提供了`interactivePopGestureRecognizer`实现右滑手势。但是当时用了自定义的返回按钮，这个手势将会失效。

> 创建新的右滑手势`UIScreenEdgePanGestureRecognizer`

```objc
    UIScreenEdgePanGestureRecognizer * recognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.interactivePopGestureRecognizer.delegate action:@selector(handleNavigationTransition:)];
    recognizer.edges = UIRectEdgeLeft;
    recognizer.delegate = self.interactivePopGestureRecognizer.delegate;
    [self.view addGestureRecognizer:recognizer];
    [[super interactivePopGestureRecognizer] setEnabled:NO];

```




## 自定义转场动画

> 可以通过提供`UIViewControllerInteractiveTransitioning`和`UIViewControllerAnimatedTransitioning`实现自定义的转场动画

```objc

@protocol UINavigationControllerDelegate <NSObject>

- (nullable id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController API_AVAILABLE(ios(7.0));

- (nullable id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC  API_AVAILABLE(ios(7.0));


@end

```