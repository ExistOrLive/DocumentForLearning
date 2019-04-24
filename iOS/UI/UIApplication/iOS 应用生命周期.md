# iOS应用生命周期

## app的五种状态

- NO Running  程序没有启动

- Inactive    应用处于前台，但没有处理事件

- Active      应用处于前台，正在接收和处理事件

- Background  应用处于后台， 可以执行代码

- Suspend     应用处于后台， 不可以执行代码

下图为iOS应用状态的切换：

![App State][1]

> 在AppDelegate对象中有一些方法来响应应用状态的变化

```

// 启动时第一次有机会来执行代码
application:willFinishLaunchingWithOptions:

// 显示app给用户之前执行最后的初始化操作
application:didFinishLaunchingWithOptions:

// app已经切换到active状态后需要执行的操作
applicationDidBecomeActive:

// app将要从前台切换到后台时需要执行的操作
applicationWillResignActive:

//app已经进入后台后需要执行的操作
applicationDidEnterBackground:

//app将要从后台切换到前台需要执行的操作，但app还不是active状态
applicationWillEnterForeground:

//app将要结束时需要执行的操作
applicationWillTerminate:

```

- 手动点击应用启动到关闭时的状态变化 

  `NO Running -> Inactive -> active->Background->Suspend`

  ![launchApp][2]

- APNS后台唤醒应用，再点击进入前台
  
   `NO Running -> Background -> Inactive -> active`

   ![APNS Notify][5]

- 切换应用时的状态变化
  
  `active-> Inactive -> Background -> Inactive -> active`

  ![switchApp][3]

- 应用程序的终止

  系统常常是为其他app启动时由于内存不足而回收内存最后需要终止应用程序，但有时也会是由于app很长时间才响应而终止。如果app当时运行在后台并且没有暂停，系统会在应用程序终止之前调用`applicationWillTerminate:`来保存用户的一些重要数据以便下次启动时恢复到app原来的状态。

## 参考文档

[iOS应用程序的生命周期][4]

[1]: pic/Application_State.png
[2]: pic/launchAndShutDownApp.png
[3]: pic/switchApp.png
[4]: https://www.jianshu.com/p/aa50e5350852
[5]: pic/APNS_NOTIFY.png
