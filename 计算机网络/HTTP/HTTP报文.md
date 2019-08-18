# HTTP 报文

> 用于HTTP协议交互的信息被称为HTTP报文，HTTP报文本身就是由多行(用CR+LF作换行符)数据构成的字符串文本。

如下图所示，是两个HTTP请求和响应的报文

![][1]

![][2]

## HTTP报文结构

> HTTP报文由`报文首部`和`报文主体`组成,报文首部由请求行和首部字段组成

![][3]

## HTTP请求行

```
GET /success.txt HTTP/1.1
```

> 请求行包含`请求的方法`，`请求URI`和`HTTP版本`。HTTP可以通过请求方法通知服务端对于指定请求的资源产生某种行为。

 HTTP/1.0和HTTP/1.1支持的方法

 ![][4]







[1]: resource/HTTP请求报文1.png
[2]: resource/HTTP请求报文2.png
[3]: resource/HTTP报文结构.png
[4]: resource/HTTP_Method.png