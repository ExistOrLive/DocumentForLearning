


- **IMEI**：iOS 5 之后被禁止。写在主板上，重装APP不会改变。

- **IDFA**：于iOS 6 时面世，可以监控广告效果，同时保证用户设备不被APP追踪的折中方案。可能发生变化，如系统重置、在设置里还原广告标识符。用户可以在设置里打开“限制广告跟踪”。

```objc

[[ASIdentifierManager sharedManager] advertisingIdentifier]

```

- **IDFV(Identity for vender)** :  同一开发商下的不同app信息共享

```objc

[UIDevice currentDevice].identifierForVendor

```

- **mac地址** ：硬件标识符，包括WiFi mac地址和蓝牙mac地址。iOS 7 之后被禁止（同时禁止的还有OpenUDID）。

- **UDID** ：用来标示设备的唯一性 。iOS 6 之后被禁止获取系统原生的UDID，但可以通过uuid，写入到钥匙串中，从而获得自定义的UDID（非系统原生），即使用户重装APP，只要每次都取这个钥匙串返回，就是不变的。

- **UUID** ：APP重装后会改变。


![][3]


[浅谈移动端设备标识码：DeviceID、IMEI、IDFA、UDID和UUID][1]

[什么是IDFA][2]

[1]: https://www.jianshu.com/p/38f4d1a4763b
[2]: https://www.jianshu.com/p/204372f9209d
[3]: DeviceId.png
