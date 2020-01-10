
# touch事件从始至终

![][1]


> 如图所示，有以上的图层关系。

- 当点击屏幕时，UIkit 会通过 `hitTest:withEvent:`方法遍历图层树，找到最深处（即最上面的）包含指定touch的view。即first responder。 在上图`first responder`为`CustomView2`.

![][2]

- UIKit 直接向 first responder 发送事件. 

- Responder收到event后，试图调用Responder的`touchesBegan:withEvent:`等方法。 如果Responder实现了这些方法，即表示Responder能够处理该事件。

![][3]

- 如果Responder能够处理该事件，则拦截事件，向target object发送action 消息； 如果不能处理，则通过`nextResponder`方法转发到responder chains中的下一个responder。


## Tip

> event在responder chain中传递时，如果某个responder收到event，而且它实现了`touchesBegan:withEvent:`等方法,则代表responder能够处理该event，并拦截该event不再传递。

> `UIControl`类就重写了 `touchesBegan:withEvent:`等方法，会拦截event； 而`UIView`，`UIImageView`,`UILabel`没有重写，即便添加了手势，也不会拦截event的传递。



[1]: pic/touch_test.jpeg

[2]: pic/touch_test_2.png

[3]: pic/touch_test_3.png