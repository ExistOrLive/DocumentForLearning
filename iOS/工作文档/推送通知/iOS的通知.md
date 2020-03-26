# iOS的通知 (iOS 10 +)

> 苹果系统提供了通知机制，既可以让iOS设备从远端的推送服务器接受通知，也可以由设备的app发送本地通知。既可以在设备的通知中心展示通知提示view，发出提示音，修改app icon的角标（给用户显式的提示），也可以静默地唤醒后台的app执行一段时间（约30s）后台任务。

## UserNotification.framework与PushKit.framework

- [UserNotification][1]
  
   > 从服务器向用户设备推送面向用户的通知，或者从您的应用程序本地生成通知。 

   > 不论你的app是否在设备上运行，设备都可以接受推送，并展示通知的提示，播放声音，以及修改角标。

   > app可以创建本地通知，并指定触发条件（时间或者地点的变化）。在条件满足时，显示通知。

   使用该框架：
      
      1. 定义设备支持的通知类型
      2. 定义通知支持的自定义操作
      3. 安排本地通知
      4. 处理已经发送的通知
      5. 响应用户对通知的操作
   
    
    
- [PushKit][2]

   > 响应与WatchOs表盘更新(app’s complications)、文件提供商(file providers)和VoIP服务相关的推送通知。

   > PushKit 提供专有的通知来支持更新watchos的表盘元素，响应文件提供商的修改以及接受Voip呼叫。不同于UserNotification框架，PushKit不会展示通知提示，发出提示音，修改角标等显式操作，而会唤醒应用并给与时间响应。


UserNotification.framework与PushKit.framework的区别：

1. UserNotification 可以提供面向用户的显式通知（提示音，角标等），PushKit没有提供显式的通知。
2. UserNotification 可以发送本地通知，PushKit只能接受apns
3. UserNotification 场景比较通用，但是PushKit只有在WatchOS更新表盘，Voip等场景下才能使用
4. UserNotification也支持后台静默唤醒的推送，但是实时性不高，可靠性不强，优先级很低；PushKit则提供更为实时可靠的通知。





[1]: https://developer.apple.com/documentation/usernotifications?language=objc

[2]: https://developer.apple.com/documentation/pushkit?language=objc

[3]: https://developer.apple.com/documentation/usernotifications/asking_permission_to_use_notifications?language=objc