# SDP协议

> SDP(Session Description Protocol) 是一种描述流媒体通信参数的协议。SDP用于描述流媒体通信会话，以达到会话通告，会话邀请以及参数协商的目的。SDP自己不会传输任何媒体但是会用于终端见媒体类型，格式和所有相关的参数的协商。

## Session Description

> 一个会话信息被描述为一组字段，一行一个。每个字段都遵循以下格式：

```
<character>=<value>
```

> <character> 是一个独立的大小写敏感的字符，<value>是结构化的文本。'='的两边都不允许出现空白。

> SDP消息主要分为三个部分，session，timing和media。

```
Session description
    v=  (protocol version number, currently only 0)
    o=  (originator and session identifier : username, id, version number, network address)
    s=  (session name : mandatory with at least one UTF-8-encoded character)
    i=* (session title or short information)
    u=* (URI of description)
    e=* (zero or more email address with optional name of contacts)
    p=* (zero or more phone number with optional name of contacts)
    c=* (connection information—not required if included in all media)
    b=* (zero or more bandwidth information lines)
    One or more Time descriptions ("t=" and "r=" lines; see below)
    z=* (time zone adjustments)
    k=* (encryption key)
    a=* (zero or more session attribute lines)
    Zero or more Media descriptions (each one starting by an "m=" line; see below)

Time description (mandatory)
    t=  (time the session is active)
    r=* (zero or more repeat times)

Media description (if present)
    m=  (media name and transport address)
    i=* (media title or information field)
    c=* (connection information — optional if included at session level)
    b=* (zero or more bandwidth information lines)
    k=* (encryption key)
    a=* (zero or more media attribute lines — overriding the Session attribute lines)
```

> `=*`代表可选字段，每个字段都必须按照以上的顺序出现


## SDP Sample

```
    v=0
    o=jdoe 2890844526 2890842807 IN IP4 10.47.16.5
    s=SDP Seminar
    i=A Seminar on the session description protocol
    u=http://www.example.com/seminars/sdp.pdf
    e=j.doe@example.com (Jane Doe)
    c=IN IP4 224.2.17.12/127
    t=2873397496 2873404696
    a=recvonly
    m=audio 49170 RTP/AVP 0
    m=video 51372 RTP/AVP 99
    a=rtpmap:99 h263-1998/90000
```