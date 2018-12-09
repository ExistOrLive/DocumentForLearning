# UITableView

>  在一个纵列中用一行行去显示数据的视图
>  A View that presents data using rows arranged in a single column

## Overview

> `UITableView` 在一个纵列中显示一个列表。`UITableView`是`UIScrollView`的子类，允许用户滑动列表，但是仅允许纵向滑动。列表中包含（comprise）单条记录的视图是`UITableViewCell`对象。Cell有标题，图片等内容；靠近右边也可以有附件视图（accessory view）。附件视图是披露（disclosure）下一层详细信息的指示器或者按钮。附件视图可以是系统提供的视图也可以是自定义视图。`UITableView`可以进入编辑模式,这样就可以插入，删除和重新排序列表中的行。

![UITableViewCell][1]

![UITableViewCell Hierarchy][2]

> 如**图2 UITableViewCell Hierarchy**，一个`UITableView` 可以有  
**backgroundView**（即其中的UIView，backgrondView默认为空，只有设置了`backgroundView`属性才会有），
**contentView**（即`contentView`属性，可以添加自定义视图 ），
**accessory view**（即其中的UIButton），
**separatorView**（分割线默认显示，可以修改`UITableView`的`separatorStyle`隐藏分割线）

----

> `UITableView`由0个或多个章节（section）组成，每个章节由一行行组成。章节由它在`UITableView`中的索引号标示，行由它在章节中的索引号标示。每个章节可以有头部和尾部视图。

----

> `UITableView`有两种风格，`UITableViewStylePlain`和`UITableViewStyleGrouped`。当创建一个`UITableView`时，必须指定一种风格，而且不能够更改。在`UITableViewStylePlain`中，当一个section的rows有一部分可见时，section的header和footer浮动在内容顶部。plain style的tableView可以有一个section索引，作为一个bar在table的右边(例如A ~ Z)。你可以点击一个特定的标签，跳转到目标section。在     `UITableViewStyleGrouped`，所有单元格拥有一个默认的背景颜色和默认背景视图。背景视图为特定section中的所有cell提供可视分组。例如，一个group可以是一个人的名字和标题，另一个group可以是电话,电子邮件帐户等。

----
> `UITableView` 必须有一个数据源对象和一个委托对象。数据源对象必须实现`UITableViewDataSource`协议，委托对象必须实现`UITableViewDelegate`协议。数据源对象提供信息，用于构建列表，并管理当插入，删除，重新排序操作时的数据模型。委托对象管理列表每一行的配置，选择，重排，高亮，附件视图和编辑操作。

----

> 当`UITableView`收到`setEditing:animated:`消息时，进入编辑模式。在这个模式下，每一个可见的行都会显示编辑和重排的视图。当点击这些视图时，数据源对象会收到`tableView:commitEditingStyle:forRowAtIndexPath:`消息，这样就可以修改数据模型，然后调用deleteRowsAtIndexPaths:withRowAnimation: 或者 insertRowsAtIndexPaths:withRowAnimation:提交修改。
在编辑模式中，当`UITableView`的`showReorderControl`属性设置为YES，且数据源对象实现了`tableView:canMoveRowAtIndexPath:`方法，移动cell时，数据源对象就会收到`tableView:moveRowAtIndexPath:toIndexPath:`消息，这样就可以重排消息模型。

----

> `UITableView`缓存了可见行的cell，你可以创建自定义的`UITableViewCell`。
> `UITableView`重写了`layoutSubviews`方法，这样仅当创建一个新的`UITableView`对象或者分配了一个新的数据源对象，都会自动调用`reloadData`方法。`reloadData`会清除当前的状态，包括当前选择的行。但是随后的`layoutSubviews`不会触发reload




#### 参考文档
[iOS UITableView 的 Plain和Grouped样式的区别][3]


  [1]: UITableViewCell.png
  [2]: UITableViewCell.png
  [3]: https://www.jianshu.com/p/764ed5aa46cf