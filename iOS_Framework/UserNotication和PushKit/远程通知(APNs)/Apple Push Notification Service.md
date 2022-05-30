# Apple Push Notification Service

## Overview
> **APNs (Apple Push Notification service)** 服务是远程通知的核心。该服务健全、安全、高效，开发者可以方便的向 iOS tvOS macOS 终端设备推送通知。

用户设备会和苹果的APNS服务器之间建立一条安全的数据交互链接，APNs服务器通过该链路下发通知。

同时App的服务器同APNS服务器之间也会建立链接，需要在你的开发者帐户中用苹果提供的加密证书配置。APP服务器提供通知内容传递给APNs服务器，由APNs服务器推送通知。

![APP，device，APP服务器，APNs服务器之间的链接][1]
 
![多个APP服务器,APNS服务器，多台设备][2]

---
 
## App服务器的职责 

App服务器在跟 APNs服务器 沟通连接的时候具有以下责任：

- 通过 APNs服务器 接收关于你的app的全球唯一的设备验证码，及其它一些数据

- 根据app功能的需要，决定通知推送的时间

- 建立通知请求，并发送通知请求到 APNs服务器， APNs 再将通知递送到相应的设备

发送通知请求时，服务器需要做的：

- 组建一个 JSON 数据，其中包含通知的信息 

- 添加 device token和通知信息到一个 HTTP2.0 请求中。

- 通过一个永久安全的线路 (Security Architecture)，发送包含证书的 HTTP2.0 请求到 APNs

## APNS服务器

APNs服务器的服务质量组件可以实现存储然后发送的功能以及联合发送的功能。

**存储并发送**

  - 当 APNs 发送通知到一个离线设备时，APNs 会把通知存储起来（一定的时间内），当设备上线时再递送给设备
  - 这个存储功能只存储一个设备的一个app的最近的通知。如果设备离线中，发送一个到该设备的通知会消除前面存储的通知。
  - 如果设备处于离线太久，所有存储的发往该设备的通知都将被消除。

**联合发送**
 当发送通知的时候在头部添加合并id，可以使发送的通知合并起来。当 `apns-collapse-id` 添加到你发送的 HTTP2.0 通知请求中时，APNs 合并`apns-collapse-id`值相同的通知。

---

## 安全结构
 
> APNs 采用双层的信任机制：连接信任 和 device token 信任

### 连接信任工作在服务器与 APNs 之间 | APNs 与设备之间

服务器与 APNs 通信的时候，必须实现 验证证书（基于token的验证）或者 SSL 证书（基于证书的验证）。你在[开发者帐户]中需要实现这两种验证方式的任意一种
[服务器和APNs服务器之间的连接信任][3]

####  基于 Token 的服务器与 APNs 之间的信任

> 工作流程如下
 1. 服务器向 APNs 请求基于 TLS(transport layer security)的安全连接请求
 2. APNs 向服务器发送认证证书，到这里，服务器与 APNs 之间的连接已经建立，此时可以发送推送请求
 3. 服务器需要发送的每个推送请求必须包含 JWT 认证 token
 4. APNs 向服务器发送 HTTP/2 回执
 
 ![用 HTTP/2 在服务器与 APNs 之间建立信任连接，用 JWT token 向 APNs 发送推送请求][4]

#### 基于证书的服务器与 APNs 之间的信任


 
### device token 信任

--- 

   
 
 
 
 
 
## 参考文档 

[苹果APNs远程推送详解][5] 
 


  [1]: pic_1.png
  [2]: pic_2.png
  [3]: https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW4
  [4]: pic_3.png
  [5]: https://segmentfault.com/a/1190000012019282#articleHeader6