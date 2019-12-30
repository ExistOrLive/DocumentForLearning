# UIScrollView和AutoLayout

> 通常来说，Auto Layout 认为 view的上下左右边界为视图的可视边界。也就是说，如果将视图固定在其父视图的左边缘，则实际上是将其固定在父视图范围的最小x值。修改父视图的原点并不会改变视图的位置。

> UISCrollView 通过修改ContentView的原点，来实现content的滚动。在Auto Layout中，`ScrollView的边界意味着contentView的边界`.

> UIScrollView 子视图上的约束一定会导致一个需要填充的范围，这个范围会被解释为UIScrollView的ContentSize。想要通过AutoLayout约束UIScrollView的frame，关于UIScrollView高度和宽度的约束必须明确，或者UIScrollView的边界必须绑定到UIScrollView子视图树之外的视图。


> 我们可以通过创建UIScrollView子视图和UIScrollView图层树外的视图的约束，让该子视图漂浮在UIScrollView
滚动内容上面。


## 自动生成ContentSize

> 通常情况下，我们在UIScrollView添加了子视图,还需要手动设置contentSize。 但是现在可以通过auto layout，自动将contentSize 撑开

```objc

UIView * view = [UIView new];
[scrollView addSubView:view];
[view mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edge.equalTo(scrollView);       // 通过view撑开contentView
    make.size.mas_equalTo(CGSizeMake(100, 100)); // 设置view的约束
}];

```

[UIScrollView And AutoLayout][1]

[UIScrollview 与 Autolayout 的那点事][2]

[1]: https://developer.apple.com/library/archive/technotes/tn2154/_index.html

[2]: https://juejin.im/entry/57abf8a7128fe100559c6fa4
