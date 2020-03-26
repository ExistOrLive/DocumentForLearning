# UserNotification


## 申请通知提示，提示音，角标修改的权限

> UserNotification的通知通过显示提醒、播放声音或修改应用角标的方式来吸引用户的注意力。用户可能认为基于通知的交互具有破坏性，您必须获得使用它们的许可。


需要在代码中明确的请求通知的权限，通过`UNUserNotificationCenter`的`requestAuthorizationWithOptions:completionHandler:`方法


```objc

 [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge|
                                 UNAuthorizationOptionSound|
                                 UNAuthorizationOptionAlert 
               completionHandler:^(BOOL granted, NSError * _Nullable error) {
        
    }];

```


[Asking Permission to Use Notifications][1]


[1]: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc

[2]: pic/Notification_Permission.png

