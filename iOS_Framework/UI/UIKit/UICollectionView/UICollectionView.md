
# UICollectionView

> 一个管理有序数据集合并且用自定义布局去展示他们的对象（An object that manages an ordered collection of data items and presents them using customizable layouts.）


### 概述

> 当在用户交互界面上添加一个UICollectionView，app的主要工作是管理与UICollectionView相关的数据。UICollectionView从数据源对象获取数据，数据源对象会实现`UICollectionViewDataSource`协议。UICollectionView会将数据组织为一条条记录（individual items），同时这些记录也可以被分组到不同的章节（section）中展示。在界面上一条条记录会用`UICollectionViewCell`去展示。

> 除了cell，UICollectionView也可以用其他类型的View去展示数据。这些额外（supplementary）的view可以是section header 和 footer不同于cell，但是仍然传递着一些信息。这些额外视图是可选的，通过布局对象定义。

> 除了添加UICollectionView，你还需要调用他的方法确保可见的记录和数据源的顺序保持一致。因此无论你什么时候添加，删除，重组数据，需要调用相应的方法去添加，删除，和重组cell。

### 集合对象和布局对象 (Collection Views and Layout Objects)




