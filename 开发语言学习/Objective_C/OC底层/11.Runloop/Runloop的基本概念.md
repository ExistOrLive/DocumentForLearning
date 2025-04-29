# Runloop

**Runloop**是线程相关的基础设备的一部分。**Runloop**是一个用于调度工作和协调事件回执的事件处理循环。**Runloop**的目的的用于保证线程有工作时被唤醒去处理，没有工作时进入睡眠状态。

![](https://pic.existorlive.cn/runloop.jpeg)

## 1. Runloop Source

**Runloop**是一个循环。线程在进入该循环后，会不断收到事件，然后调用事件处理函数去响应事件。

**Runloop**接受的事件都来自两种类型的事件源，**Input Source** 和 **Timer Sources**。

- **Input Sources** 传递的是异步事件，一般来自另外的线程或者另一个应用程序。

- **Timer Sources** 传递的是同步事件，来自定时器，在预定的时间或者周期性发出


### 1.1 Input Sources

**Input Sources** 分为两种类型：

- 基于 Port 的 **Input Sources** 会监控应用的 Mach Port， 由内核自动发出
- 自定义的 **Input Sources** 监控自定义的事件源，由另一个线程手动发出

**Perform Seletor Source**就是一种自定义的 **Input Sources**，允许你在任意线程上执行Seletor。当在目标线程上执行 Seletor时，必须要确认目标线程有一个活跃的**Runloop**。

### 1.2 Timer Sources

**Timer Sources**在预定的时间或者周期性的同步发送事件。

**Timer Sources**尽管是基于时间的时间，但是并不是一种实时的机制。**Timer Sources** 和 **Input Sources** 一样，会加入到某个 **Mode** 中。如果 **RunLoop** 当前的 Mode 并不匹配，**Timer Sources** 的事件则会一直保持到 **Runloop**切换到对应 **Mode** 时才处理。

**Timer Sources**可以是只发送一次，也可以是周期性。如上文所说，**Timer Sources** 的事件并不会实时的处理，可能会被推迟。如果推迟了多个周期时间，**Timer Sources** 的事件也只会被处理一次。

## 3. Runloop Mode

**Runloop Mode** 是 一组特定**Sources** 和 一组 特定**Observer** 的集合。

**Runloop**的每次运行都需要指定一个的**Mode**(显式地或者隐式地指定)。只有在该**Mode**中包含的 **Sources** 发出的事件才会被处理，**Observers** 才会被通知。 其他的 **Source**会等待**Runloop**切换到对应的**Mode**时，才会发出事件。

**Runloop Mode** 可以用于在某个阶段过滤不希望被处理的 **Source**。大部分时间，**Runloop**运行在系统定义的默认**Mode**，`NSDefaultRunloopMode`。当用户滑动界面时，为保证滑动的流畅，**Runloop**会切换到`NSEventTrackingRunloopMode`,会过滤掉大部分的事件。

**Foundation**和**Core Foundation**预定义了一些**Mode**：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-07-24%20%E4%B8%8A%E5%8D%8811.26.20.png)

- **NSDefaultRunloopMode**

    默认情况下和大部分时间中，**Runloop**都运行在该**Mode**中

- **NSRunLoopCommonModes**
      
    **CommonModes** 是一组可配置的通用**Mode**。为**CommonModes**添加一个**Source**，那么**CommonModes**中的每一个**Mode**都会添加这个**Source**。 对于**Foudation**, **CommonModes**包含**Default Mode**，**Panel Mode**，**Event Track Mode**


## 4. Runloop Observers

**Runloop** 在循环的特定阶段会发出通知，通过注册 **Runloop Observers**可以监听到这些通知。

- 进入**Runloop**循环时
- 准备好要处理**timer source**的事件时
- 准备好要处理**input source**的事件时
- 将要进入休眠时
- 当被唤醒，但是还没有处理唤醒线程的事件
- 从**Runloop**循环中退出时

**Runloop Observers**和**Timers**相似，可以接受一次通知或者重复接受通知。这个设置可以在创建**Runloop Observers**时指定。

[Runloop 官方文档 ](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Multithreading/RunLoopManagement/RunLoopManagement.html)
      
