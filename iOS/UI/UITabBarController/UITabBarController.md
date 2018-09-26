# UITabBarController

> A specialized view controller that manages a radio-style selection interface.
一个专门的view controller，管理一个单选界面。

## Overview

- tab bar 显示在window的底部，在不同的模式之间选择可以显示不同模式的视图。这个类通常直接使用，也可以被派生。

- UITabBarController 的每一个标签（tab）都与一个自定义的UIViewController相关联。 因为选择一个标签会替换UI的内容，每个标签管理的界面类型没必要在任何方面都是相似的。事实上，UITabBarViewController通常被用于显示不同类型的信息或者用不同的界面显示同一种信息。图一 展示了时钟界面的UITabViewController，每一个标签显示时间的不同类型

![图一][1]

- 你不应该直接访问UITabBarViewController的view。为了管理UITabBarViewController的标签，你需要为`viewControllers`属性赋值，值为一个viewController数组为每一个标签提供了根视图。你指定的`viewControllers`属性的顺序决定了它们在tab bar中显示的顺序。当设置了`viewControllers`属性，也应该为`seletedViewController`赋值用于指定UITabBarViewController的初始选择哪个viewController，也可以为为`selectedIndex`属性赋值。

```
// 当View Controller的个数超过了tab bar 显示的个数（通常是5个），moreNavigationController将会创建并显示。

@property(nullable, nonatomic,copy) NSArray<__kindof UIViewController *> *viewControllers;
// If the number of view controllers is greater than the number displayable by a tab bar, a "More" navigation controller will automatically be shown.
// The "More" navigation controller will not be returned by -viewControllers, but it may be returned by -selectedViewController.


// 当选择了moreNavigationController，就会返回moreNavigationController
@property(nullable, nonatomic, assign) __kindof UIViewController *selectedViewController; // This may return the "More" navigation controller if it exists.
@property(nonatomic) NSUInteger selectedIndex;

@property(nonatomic, readonly) UINavigationController *moreNavigationController __TVOS_PROHIBITED; // Returns the "More" navigation controller, creating it if it does not already exist.

@property(nullable, nonatomic, copy) NSArray<__kindof UIViewController *> *customizableViewControllers __TVOS_PROHIBITED; // If non-nil, then the "More" view will include an "Edit" button that displays customization UI for the specified controllers. By default, all view controllers are customizable.

```

- Tab Bar Item 是通过相应的View Controller设置。为了将一个tab bar item关联到一个view controller，需要创建一个`UITabBarItem`实例，为相应的View Controller配置，并将它赋给View Controller的`tabBarItem`属性.如果不设置这个值，View Controller会创建一个默认的`UITabBarItem`实例，`image`属性为空,`title`属性来自View Controller的`title`属性。

- 


  [1]: pic1.png