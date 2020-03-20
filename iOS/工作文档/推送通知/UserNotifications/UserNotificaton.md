# UserNotification



##  请求使用通知的权限

> 本地和远程通知通过显示提醒、播放声音或标记应用程序图标来吸引用户的注意力。这些互动发生在你的应用程序没有运行或处于后台的时候。他们让用户知道你的应用程序有相关信息供他们查看。因为用户可能认为基于通知的交互是破坏性的，所以您必须获得使用它们的许可。

![][2]


需要在代码中明确的请求通知的权限，通过`UNUserNotificationCenter`的`requestAuthorizationWithOptions:completionHandler:`方法


```objc

 [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
    }];

```

[Asking Permission to Use Notifications][1]




[1]: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc

[2]: pic/Notification_Permission.png

