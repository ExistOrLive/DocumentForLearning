# Overview


## StoreKit

> `StoreKit`是支持应用内购买以及和App Store交互的框架

- `In-App Purchase`

- `Apple Music`

- `Recommenddations and reviews`  : 提供有关第三方内容的建议，并使用户能够对您的应用进行评分和审查。


## In-App Purchase

> In-App Purchase 允许用户购买应用内提供的额外内容以及服务。

- `StoreKit`首先代表您的应用程序连接到App Store，并提供安全的支持流程。

- `StoreKit`在支付后通知app支付结果

- 如果支付成功，app需要在服务端或者本地去验证回执。如果验证成功，则关闭订单


![][2]


## Config products

> 使用内购之前需要在[appstoreconnect][5]中配置商品

![][3]


![][4]



> apple 提供了四种内购的类型


- Consumables(消耗型)   一次性使用并耗尽，可以购买多次
  
      例如 充值点券

- Non-consumables(非消耗型)  一次性购买，不会过期
    
      例如 一次性购买某个功能

- Auto-renewable subscriptions (自动续期订阅) 购买一次并自动续订，直到用户决定取消。

      例如 VIP 自动续期

- Non-renewing subscriptions（非续订订阅） 在有限的时间内提供访问权限，不会自动续订，可以再次购买。

      例如 购买VIP但不自动续期


> 可以使用StoreKit在设备之间同步和还原非消耗性和自动续订的订阅。当用户购买自动续订或非续订的订阅时，您的应用程序有责任使其在所有用户的设备上均可用，并使用户能够恢复过去的购买。



[In-App Purchase][1]




## 代码集成











[1]: https://developer.apple.com/documentation/storekit/in-app_purchase?language=objc

[2]: pic/storekit.png

[3]: pic/config_product_2.png

[4]: pic/config_product_1.png

[5]: https://appstoreconnect.apple.com/

[6]: https://developer.apple.com/documentation/storekit/in-app_purchase/setting_up_the_transaction_observer_and_payment_queue?language=objc

[7]: https://developer.apple.com/documentation/storekit/in-app_purchase/offering_completing_and_restoring_in-app_purchases