# 推送后台更新到app

> 发送通知去唤醒app并且在后台更新


## Overview

> 如果您的应用程序基于服务器的内容不经常或不定期地发生变化，您可以使用后台通知在新内容可用时通知您的应用程序。后台通知是一种远程通知，不显示提醒、播放声音或标记应用程序图标。它会在后台唤醒您的应用程序，并给它时间从您的服务器启动下载并更新其内容。

### Tip

> 该系统将后台通知视为低优先级:您可以使用它们来刷新应用程序的内容，但系统不保证它们的传递。此外，如果总数过多，系统可能会限制后台通知的传递。系统允许的后台通知数量取决于当前条件，但不要试图每小时发送两到三个以上的通知。

## 打开后台远程通知能力

![][2]

## 创建并发送一个后台通知

> 远程通知实际上是由app服务器向apns服务器发送的一个post请求，携带一个json格式的payload。后台通知需要在aps字典中配置`["content-available":1]`,并且在请求的header中设置`apns-push-type=backgroud`,`apns-priority=5`。苹果推荐在所有的远程通知请求中都添加`apns-push-type`.

```json

{
   "aps" : {
      "content-available" : 1
   },
   "acme1" : "bar",
   "acme2" : 42
}

```

## 接受并处理后台通知

> 当设备收到后台通知，系统会接受并延迟通知的发送，因此可能会出现以下的情况：

- 当系统收到新的后台通知时，它会丢弃旧的通知，只保留最新的通知。

- 如果某个东西强制退出或终止应用程序，系统会丢弃保留的通知。

- 如果用户启动应用程序，系统会立即发送保留的通知。



```objc
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler API_AVAILABLE(ios(7.0));

```


[Pushing Background Updates to Your App][1]




[1]: https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/pushing_background_updates_to_your_app?language=objc

[2]: pic/BackgroudMode_RemoteNotification.png