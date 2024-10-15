# layoutMargin 


## layoutMargins 和  safeAreaInsets

```objc

@interface UIView(UIViewHierarchy)

@property (nonatomic) UIEdgeInsets layoutMargins API_AVAILABLE(ios(8.0));      // 表示布局内容的默认边距 

@property (nonatomic) NSDirectionalEdgeInsets directionalLayoutMargins API_AVAILABLE(ios(11.0),tvos(11.0));

@property (nonatomic) BOOL preservesSuperviewLayoutMargins API_AVAILABLE(ios(8.0));  // default is NO - 从父视图集成layoutMargin

- (void)layoutMarginsDidChange API_AVAILABLE(ios(8.0));

@property (nonatomic,readonly) UIEdgeInsets safeAreaInsets API_AVAILABLE(ios(11.0),tvos(11.0));

- (void)safeAreaInsetsDidChange API_AVAILABLE(ios(11.0),tvos(11.0));

@end

```

[Positioning Content Within Layout Margins][1]


> `-layoutMargins`  返回一组距离view边界的insets，表示布局内容的默认边距。 默认值为{8，8，8，8}。

> 当`preservesSuperviewLayoutMargins`设置为YES，会继承父视图的layoutMargins。 

> 当`layoutMargins`修改时，可以通过重写`-layoutMarginsDidChange`来刷新视图。

>  在iOS11和之后 ，为了支持多个方向的界面布局，提供新属性`directionalLayoutMargins`。当方向为LTR，layoutMagins.left 取 directionalLayoutMargins.leading的值；当方向为RTL，layoutMargins.left 取 directionalLayoutMargins.trailing 的值

> `insetsLayoutMarginsFromSafeArea`, 默认YES， 会根据SafeArea自动增加layoutMargin的值

> `safeAreaInsets` 代表安全区域中的insets，它会随着view的位置的变化，而变化

## Example

![][2]

![][3]


> 如上图所示，绿色方块在红色方块顶部，`safeAreaInsets`为{44，0，0，0}，`layoutMargins`为{52，8，8，8}。在向下移动的过程中，`safeAreaInsets`和`layoutMargins`不停的在变化，离开顶部的iphonex的危险区域后，变为{0，0，0，0}和{8，8，8，8}；进入底部的危险区域后，逐渐变为{8，8，42，8}和{0，0，34，0}


## UILayoutGuide

```objc

/* The edges of this guide are constrained to equal the edges of the view inset by the layoutMargins
 */
@property(readonly,strong) UILayoutGuide *layoutMarginsGuide API_AVAILABLE(ios(9.0));

/// This content guide provides a layout area that you can use to place text and related content whose width should generally be constrained to a size that is easy for the user to read. This guide provides a centered region that you can place content within to get this behavior for this view.
@property (nonatomic, readonly, strong) UILayoutGuide *readableContentGuide  API_AVAILABLE(ios(9.0));

/* The top of the safeAreaLayoutGuide indicates the unobscured top edge of the view (e.g, not behind
 the status bar or navigation bar, if present). Similarly for the other edges.
 */
@property(nonatomic,readonly,strong) UILayoutGuide *safeAreaLayoutGuide API_AVAILABLE(ios(11.0),tvos(11.0));

```

> `UILayoutGuide` 是被设计用来执行之前由虚拟视图执行的任务。它仅仅表示坐标系中的一块矩形区域，它不会存在图层中，不会被渲染，不会存在于事件的响应链中，相较于UIView有着更低的开销，而且可以用于AutoLayout

[UILayoutGuide][4]

> `layoutMarginsGuide` 与 `layoutMargins`表示的矩形区域一致。 `safeAreaLayoutGuide`与 `safeAreaInsets` 表示的矩形区域一致


![][5]





[1]: https://developer.apple.com/documentation/uikit/uiview/positioning_content_within_layout_margins?language=objc

[2]: pic/safeAreaInsetsTest.jpeg

[3]: pic/safeAreaInsets.png

[4]: https://developer.apple.com/documentation/uikit/uilayoutguide?language=objc

[5]: pic/safeAreaLayoutGuide.png
