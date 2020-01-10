
## 1

event在responder chain中传递时，如果某个responder收到event，而且它实现了`touchesBegan:withEvent:`等方法,则代表responder能够处理该event，并拦截该event不再传递。

`UIControl`类就重写了 `touchesBegan:withEvent:`等方法，会拦截event； 而`UIView`，`UIImageView`,`UILabel`没有重写，即便添加了手势，也不会拦截event的传递。


## 2 

 如果touch的位置在一个view范围之外，`hitTest:withEvent:`方法会忽略该view和它的子view。当一个view的`clipsToBounds`属性设置为NO，该view范围之外的子视图也不会被返回。