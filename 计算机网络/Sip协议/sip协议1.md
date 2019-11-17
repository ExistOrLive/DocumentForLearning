# sip 协议 

> SIP（Session Initiation Protocol，会话初始协议）是由IETF（Internet Engineering Task Force，因特网工程任务组）制定的多媒体通信协议。它是一个基于文本的应用层控制协议，用于创建、修改和释放一个或多个参与者的会话。它是一种应用层协议，与其他应用层协议（如SDP，RTP）协同工作，通过Internet控制多媒体通信会话。它在在[RFC 3261][1]中定义。

## Sip Functionality

- 用户定位(User Location)： 确定用于通信的终端系统

- 用户可用性(User Availiability)： 确定被叫方是否愿意加入通信

- 用户能力(User Capabilities): 确定将要使用的媒体和媒体参数

- 会话建立(session setup): "振铃"，在主叫方和被叫方建立会话参数

- 会话管理(Session Management): 包括会话的转移和终止；修改会话参数以及调用服务

> Sip协议不是一个垂直的集成通信系统。Sip是一个组件，可以和其他IETF协议一起构建完整的多媒体网络架构。通常会包括：

- [RTP (Realtime Transport Protocol)][2]
  
      传送实时数据以及提供质量服务(Qos)

- [RTSP (Real-time streaming protocol][3]

      控制媒体流的传输，通常用于直播

- [MEGACO(Media Gateway Control Protocol)][4]

      控制连接到公共交换电话网络(PSTN)

- [SDP(Sesson Description Protocol)][5]

      描述多媒体会话,通常作为sip协议的负载

> Sip协议的基本功能和操作是不依赖以上的协议的

> Sip本身不提供任何服务，只提供用于实现服务的基本元（primitive）。例如，sip可以定位一位用户，并向他发送一个不透明的数据包。这个数据包可以是会话描述信息，也可以是用户的图片。所以，一个独立的基本元会用于提供几种不同的服务。

> Sip协议不会提供会议控制服务；sip协议不能也不会提供任何的网络资源保存服务

> Sip提供了一套安全服务套件，包括防止拒绝服务，认证服务，完整性保护（integrity protection），以及加密和隐私服务

> 有一些实体帮助SIP创建其网络。在SIP中，每个网元由SIP URI（统一资源标识符）来标识，它像一个地址。以下是网络元素 -

- 用户代理
- 代理服务器
- 注册服务器
- 重定向服务器
- 位置服务器

## 网络元素

### 用户代理(User Agent)

> 它是终端和SIP网络中最重要的网络元件中的一个，可以启动，修改或终止会话。用户代理是SIP网络的智能设备或网络元件。它可能是一个软件电话，移动电话或平板电脑。

用户代理在逻辑上分成两部分：

- 用户代理客户端（UAC） - 发送请求和接收响应的实体。

- 用户代理服务器（UAS）- 接收一个请求，并发送应答的实体。

> SIP是基于客户端 - 服务器架构，其中来电者的电话作为其发起呼叫的客户端，被叫方的电话作为其响应呼叫的服务器

### 代理服务器(Proxy Server)

>  代理服务器是一个网络服务器，作为中间实体代表其他网络元素操作请求。

- 代理服务器的主要工作是路由，将请求发送到距离目标用户更近的网络实体。

- 代理服务器也可以用于执行策略，例如决定一个用户是否被允许创建通话

- 如果有必要，也可以重写请求的一部分

> 可以将消息路由到多个目的地的代理服务称作`fork proxies`。SIP请求的fork意味着可以从一个请求建立多个会话。SIP fork是指将单个SIP调用“分叉”到多个SIP端点的过程，这样一次call可以呼叫多个终端。

### 重定向服务器（Redirect server）

> 重定向服务器是创建`3xx(redirection)`响应的服务器，将客户端重定向到其他的URI。重定向服务器允许代理服务器将Sip Session Invitations转发到外部域。

### 注册服务器(Registar)

> 注册服务器是提供定位服务的sip终端，接受Register请求，记录用户代理的位置(IP Address)和其他信息。

> 对于接下来的请求，它提供方法定位通话对端可能的位置。定位服务关联一个或多个IP地址到Sip URI。

> 如果多个用户代理注册到同一个Sip URI，当这个Sip URI被呼叫时，所有注册的用户代理都会受到呼叫


![][6]


### SBC （Session Border Controller）

> SBC在用户代理和SIP服务器之间，用于各种类型的功能，包括网络拓扑隐藏和NAT遍历的辅助。

### 网关（GateWay）

> 网关可用于将SIP网络互连到其他网络，如使用不同协议或技术的公共交换电话网(pstn)



## SIP Message

![][7]


## transaction


## Entryption 

> Sips 的加密是逐跳的，不是端到端的，因此每个独立的中间代理都需要被信任








## 参考文档

[RFC3261(sip)][1]

[RFC1889(rtp)][2]

[RFC2326(RTSP)][3]

[RFC3015(MEGACO)][4]

[RFC2327(SDP)][5]

[1]: https://tools.ietf.org/html/rfc3261
[2]: https://tools.ietf.org/html/rfc1889
[3]: https://tools.ietf.org/html/rfc2326
[4]: https://tools.ietf.org/html/rfc3015
[5]: https://tools.ietf.org/html/rfc2327
[6]: pic/Registar.png
[7]: pic/invite.PNG