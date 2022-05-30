# 加载xib文件

> xib文件是xcode中描述`UIViewController`和`UIView`布局的文件。xib文件的创建有两种方式，一种是随着UIViewController文件一起创建，这样xib文件会自动关联到UIViewController；另一种是手动创建xib文件，同时需要手动去关联相应的`UIView`或者`UIViewController`

## UIViewController 创建 xib

- 首先创建一个TestViewController，同时创建xib文件

![创建xib][1]

- 可以看到xib的`file owner`是`TestViewControllr` ， `view`的类型为默认类型`UIView`，对应着`TestViewController`的`view`属性。这是xib文件和`TestViewController`自动关联

![xib2][2]

![xib3][3]

- 接着在xib上创建一个`UIButton`，然后hook到`TestViewController`的button1属性上,可以看到button是关联到file owner上

![xib4][4]

- 最后，使用`TestViewController`

```
/**
 * initWithNibName 创建 TestViewController ；
 * 然后读取 xib文件中的布局信息，修改 
 * TestViewController的View的布局；
 * 最后 通过KVC将hook的视图注入相应的属性中
 **/ 
TestViewController * controller = [[TestViewController alloc] initWithNibName:@"TestViewController" bundle:nil];

```

## 手动创建一个xib

- 创建一个xib 

![xib5][5]

- 手动创建xib文件的`file‘s owner `和`View`的类型都是默认值，当关联至一个`UIViewController`的子类时，需要修改`file's owner`的类型，而`View`保持默认值。当关联到一个`UIView`的子类时，修改`View`的类型而`file's owner`的类型保持默认值。

![xib6][6]

- 接着在xib上创建一个`UIButton`，然后hook到`TestView`的button1属性上,可以看到button是关联到TestView上


## Tip

将xib文件上的视图hook到源文件时，一定要注意是hook到的`file’s owner` 还是 `View`, 因为这些视图是通过KVC注入相应的`file’s owner`实例 和 `View`实例的，如果实例没有相应的属性，会闪退的

例如：
将 `file’s owner` 还是 `View` 都设置为 `TestView`。hook视图时，会hook到`file’s owner`上。而`file’s owner`是在调用`loadNibNamed:owner:options:`方法时传入的，可以是任意类型的对象。当`file’s owner`不是`TestView`时，可能会闪退




[1]: pic/xib1.png
[2]: pic/xib2.png
[3]: pic/xib3.png
[4]: pic/xib4.png
[5]: pic/xib5.png
[6]: pic/xib6.png