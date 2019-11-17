# RTP协议

> RTP（Real-time Transport Protocol） 是用于在IP网络上传输音视频媒体的网络协议。RTP经常用于涉及到流媒体的通信和娱乐系统，例如电话，视频会议。 RTP运行在UDP协议之上，和RTCP一起使用。RTP携带流媒体，而RTCP用于监控传输数据，Qos以及媒体流的同步。RTP是voip的技术基础，经常和Sip协议一起使用。

> RTP是为了端到端的，实时的，流媒体传输而设计的。该协议提供了方法处理抖动补偿（Jitter Compensation），丢包检测以及无序的交付（out-of-order deliver）。RTP通过IP多播实现将数据传输到多个目的地。

> 实时的媒体流应用要求及时的信息交付，经常忍受一些丢包达到这个目的。例如，音频应用的丢包也许会导致音频缺失一段，但是可以通过合适的错误隐藏算法，使其不易被发现。TCP更关注可靠性而不是实时性，所以RTP主要使用UDP。

> RTP携带实时的媒体数据，和其他一些信息，包括时间戳（用于同步），序列号（用于丢包和重排检测）以及负载格式（表明数据的编码格式）。RTCP用于Qos反馈和媒体流的同步。通常，RTCP的流量只占RTP的5%左右。


> 通信双方会通过一个信令协议建立RTP会话，例如H.323，Sip协议，RTSP或者XMPP协议。这些协议会使用SDP指定会话的参数。

> 每一个多媒体流都会建立一个RTP 会话。音频和视频也许会使用不同的RTP会话，使用户可以选择性的接收部分媒体流。一个会话包括目标IP地址以及一对RTP/RTCP的端口。


## Profile and payload formats

> RTP协议的设计思想是传输多种媒体格式并且在不修改RTP标准的前提下允许新的格式加入。为了达到这个目的，特定应用需要的信息不会包含在通用的RTP Header中，而是通过不同的RTP profile和相关的payload formats提供。

> profile 定义了用于对负载数据的编码的编解码器。在RTP Header中的Payload Type(PT)字段中关联负载格式。每个profile都对应多个payload format，每个payload format特定编码数据的传输。音频编码格式包括 G.711, G.723, G.726, G.729, GSM, QCELP, MP3, 和DTMF。视频编码格式包括  H.261, H.263, H.264, H.265 和 MPEG-1/MPEG-2

## Packet Header


![RTP Header][1]






[1]: pic/RTP_Header.PNG