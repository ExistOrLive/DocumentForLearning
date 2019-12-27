# layoutMargin 


```objc

@interface UIView(UIViewHierarchy)

@property (nonatomic) UIEdgeInsets layoutMargins API_AVAILABLE(ios(8.0));      // 表示布局内容的默认边距 

@property (nonatomic) BOOL preservesSuperviewLayoutMargins API_AVAILABLE(ios(8.0));  // default is NO - 从父视图集成layoutMargin


@property (nonatomic) NSDirectionalEdgeInsets directionalLayoutMargins API_AVAILABLE(ios(11.0),tvos(11.0));

@end

```


> `-layoutMargins`  返回一组距离view边界的insets，表示布局内容的默认边距。 默认值为{8，8，8，8}。

> 当`preservesSuperviewLayoutMargins`设置为YES，会继承父视图的layoutMargins。 

> 当`layoutMargins`修改时，可以通过重写`-layoutMarginsDidChange`来刷新视图。

>  在iOS11和之后 ，为了支持多个方向的界面布局，提供新属性`directionalLayoutMargins`。当方向为LTR，layoutMagins.left 取 directionalLayoutMargins.leading的值；当方向为RTL，layoutMargins.left 取 directionalLayoutMargins.trailing 的值

> `insetsLayoutMarginsFromSafeArea`, 默认YES， 会根据SafeArea自动增加layoutMargin的值




[Positioning Content Within Layout Margins][1]


[1]: https://developer.apple.com/documentation/uikit/uiview/positioning_content_within_layout_margins?language=objc








```
  
    CustomView * view1 = [CustomView new];
    view1.directionalLayoutMargins = NSDirectionalEdgeInsetsMake(20, 30, 40, 10);
    view1.preservesSuperviewLayoutMargins = YES;
    view1.insetsLayoutMarginsFromSafeArea = YES;
    [self.view addSubview:view1];
    view1.backgroundColor = [UIColor redColor];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.view1 = view1;
    
    CustomView * view2 = [CustomView new];
    view2.backgroundColor = [UIColor greenColor];
    [view1 addSubview:view2];
    
    NSLog(@"%lf %lf %lf %lf",view1.layoutMargins.top,view1.layoutMargins.left,view1.layoutMargins.bottom,view1.layoutMargins.right);
    NSLog(@"%lf %lf %lf %lf",view1.safeAreaInsets.top,view1.safeAreaInsets.left,view1.safeAreaInsets.bottom,view1.safeAreaInsets.right);


    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view1.mas_topMargin);
        make.left.equalTo(view1.mas_leftMargin);
        make.right.equalTo(view1.mas_rightMargin);
        make.bottom.equalTo(view1.mas_bottomMargin);
    }];

```