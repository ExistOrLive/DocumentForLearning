# UITableView的加载过程

> `UITableView`有一个UITableViewDelegate对象和UITableViewDataSource对象，我们通过研究这两个对象的方法的调用过程来研究UITableView的加载过程

- **首次加载和调用reloadData**

> `UITableView`的首次加载，其实就是`UITableView`调用`reloadData`之后的结果。

 1. 首先会调用`numberOfSectionsInTableView:`获取section的数量
 2. 然后调用`tableView:numberOfRowsInSection:`获取section中row的数量
 3. 接着加载cell视图，`tableView:cellForRowAtIndexPath:`获取cell，`tableView:heightForRowAtIndexPath:`获取cell的高度。（这里仅加载需要显示的cell）
 4. 最后加载section的header view和 footer view。先获取高度，`tableView: heightForHeaderInSection:`,再获取视图,`tableView:viewForHeaderInSection:`

----

- **滑动UITableView**
> 滑动`UITableView`的过程其实就是将不可见的cell加载出来的过程。因此在这个过程中，仅会与cell和header view ，footer view加载的方法。
`tableView:cellForRowAtIndexPath:`
`tableView:heightForRowAtIndexPath:`
`tableView: heightForHeaderInSection:`
`tableView:viewForHeaderInSection:`

----

- **插入和删除cell**

>





