# UIResponder

> 一个相应和处理事件的抽象接口 (An abstract interface for responding to and handling events. )

## Overview

> `UIResponder`组成了UIkit app 事件处理的中枢。 许多类包括`UIApplication`，`UIViewController`以及`UIView`都是`UIResponder`的子类。当事件发生，UIKit会将事件派发到`UIResponder`处理。

> 现在有以下几种事件，`touch event`,`motion event`,`press event`以及`remote-control event`。 为了处理特定的事件，responder必须实现相应的方法。

> UIResponder也会管理将未处理事件转发到app得其他部分。如果一个给定的UIResponder不会处理某个事件，它将把事件转发到响应链中的下一个Responder。UIKit动态管理着响应链，使用预先定义的规则决定下一个responder。例如，view会将事件转发给superView，图层的root view会将事件转发给它的VC.

> UIResponder 处理 UIEvent对象，也可以透过input view接受自定义输入。系统的键盘就是典型的input view的例子。当用户点击UITextField或者UITextView时，他们首先变为first responder然后展示他们的input view，即系统键盘。同样，您可以创建自定义输入视图，并在其他响应者变为活动状态时显示它们。要将自定义输入视图与响应者相关联，请将该视图分配给响应者的inputView属性。


## Responder Chains

> 未处理的事件在responder_chain中从responder传递到responder，这是应用程序响应器对象的动态配置。图1显示了应用程序中的responder，其界面包含一个UILabel、一个UITextField、一个UIButton和两个背景view。该图还显示了事件如何沿着响应器链从一个响应器移动到下一个响应器。

![][2]


> 如果UITextField不处理事件，UIKit将事件发送到UITextField的父UIView对象，然后是UIWindow的root view。从root view来看，响应器链在将事件指向UIWindow之前转移到owning UIViewController。如果UIWindow不能处理事件，UIKit将事件传递给UIApplication对象，如果UIApplicationDelegate是一个UIResponder对象，但是不是responder_chain的一部分，事件可能也会转发到UIApplicationDelegate。



[Using Responders and the Responder Chain to Handle Events][1]

[1]: https://developer.apple.com/documentation/uikit/touches_presses_and_gestures/using_responders_and_the_responder_chain_to_handle_events?language=objc

[2]:pic/Responder_Chain.png