# HTTP请求方法

![][1]



## 以下为对于同一URI使用不同方法时的抓包

## GET : 获取资源

 ![][2]

 > 可以看到GET请求报文只有报文首部(请求行和首部字段)，没有HTTP报文主体；而响应报文包括报文首部(状态行和请求字段)和报文主体


## HEAD 获得报文首部

> HEAD方法和GET方法一样，只是不返回报文的主体部分。用于确认URI的有效性以及资源更新的日期时间。

![][3]

> 可以看到，和GET方法相同的URI，HEAD方法却没有响应报文的主体

## POST 传输实体主体

> POST方法用来传输实体的主体，因此使用POST方法时，请求的参数通常放在报文的主体中。虽然POST的功能和GET很相似，但是POST的主要目的并不是获取响应的主体内容。

![][7]

> 可以看到POST请求是可以包含HTTP报文主体

## PUT

> PUT方法用来传输文件。就像FTP协议一样，要求在请求报文主体中包含文件内容，然后保存到请求URI指定的位置

> 但是鉴于HTTP/1.1的PUT方法本身不带验证机制，任何人都可以上传文件，存在安全性问题，因此一般的Web网站不使用该方法。若配合Web应用程序的验证机制，或架构设计采用REST(REpresentational State Transfer，表征状态转移)标准的同类网站，就可能会开放使用PUT方法

![][8]

> 这里PUT请求，我试了几个网站应该都被禁止了，所以没有抓包结果

## DELETE

> DELETE方法用来删除URI指定的资源

> 但是鉴于HTTP/1.1的DELETE方法本身不带验证机制，任何人都可以上传文件，存在安全性问题，因此一般的Web网站不使用该方法。若配合Web应用程序的验证机制，或架构设计采用REST(REpresentational State Transfer，表征状态转移)标准的同类网站，就可能会开放使用DELETE方法

![][9]

## OPTIONS

> OPTIONS 方法用来查询针对请求URI指定资源支持的方法

![][10]

## TRACE

> TRACE方法是让web服务器将之前的请求通信环回给客户端的方法。发送请求是，在Max-Forwards首部字段中填入数值，没经过一个服务器端就将改数值减1，当数值刚好减到0时，就停止继续传输，最后接受到请求的服务器端则返回状态码200 OK的响应。

> 客户端通过TRACE方法可以查询发送出去的请求是怎么被加工修改的。这是因为，请求想要连接到源目标服务器可能回通过代理中转，TRACE方法就是用来确认连接过程中发生的一系列操作

> 但是TRACE方法容易引起XST(Cross-Site Tracing,跨站追踪)攻击，通常不会用到

![][6]

> 可以看到该URI的TRACE请求被禁止了（405 Not Allowed）

![][11]

## CONNECT

> CONNECT 方法要求在与代理服务器通信时建立隧道，实现用隧道协议进行TCP通信。主要使用SSL和TLS协议将通信内容加密经网络隧道传输

如下图，是移动端访问`https://gihub.com`,经过Charle代理。移动端首先会和代理建立隧道，然后是TLS的握手和秘钥协商过程，最后数据在TLS加密下传输

![][4]

![][5]


## GET 与 POST的区别

1. GET方法用于获取资源，POST方法用于传输数据实体

2. GET请求的数据附加在URI之后；POST请求的数据存放在HTTP报文的包体中。
   
3. HTTP请求的URI一般会有1024字节的限制（这是有浏览器或服务器限制的），所以GET请求的参数长度也有限制；POST请求参数在包体中，长度理论上没有限制，但是由于性能或处理能力的考量，开发者都会限制长度


## 条件GET 

> GET 请求用于获取资源，是安全且幂等的

- 这里的安全是指GET请求只会获取信息而不会修改信息

- 幂等只对于同一URI的多个请求应该返回相同的结果

> 客户端向服务器发送一个包询问是否在上一次访问网站的时间后是否更改了页面，如果服务器没有更新，显然不需要把整个网页传给客户端，客户端只要使用本地缓存即可，如果服务器对照客户端给出的时间已经更新了客户端请求的网页，则发送这个更新了的网页给用户。

```
 GET / HTTP/1.1  
 Host: www.sina.com.cn:80  
 If-Modified-Since:Thu, 4 Feb 2010 20:39:13 GMT  
 Connection: Close  
```
> 第一次请求时，服务器端返回请求数据，之后的请求，服务器根据请求中的 If-Modified-Since 字段判断响应文件没有更新，如果没有更新，服务器返回一个 304 Not Modified响应，告诉浏览器请求的资源在浏览器上没有更新，可以使用已缓存的上次获取的文件。


```
 HTTP/1.0 304 Not Modified  
 Date: Thu, 04 Feb 2010 12:38:41 GMT  
 Content-Type: text/html  
 Expires: Thu, 04 Feb 2010 12:39:41 GMT  
 Last-Modified: Thu, 04 Feb 2010 12:29:04 GMT  
 Age: 28  
 X-Cache: HIT from sy32-21.sina.com.cn  
 Connection: close 
```

## POST请求分两次发送

> 相比于GET请求，POST需要发送HTTP报文的包体。POST请求会分两次发送，第一次发送请求行和请求首部，服务器响应100 Continue；之后才会发送HTTP报文的包体。







[1]: resource/HTTP_Method.png
[2]: resource/HTTPHead/GET.png
[3]: resource/HTTPHead/HEAD.png
[4]: resource/HTTPHead/CONNECT1.png
[5]: resource/HTTPHead/CONNECT2.png
[6]: resource/HTTPHead/TRACE.png
[7]: resource/HTTPHead/POST.png
[8]: resource/HTTPHead/PUT.png
[9]: resource/HTTPHead/DELETE.png
[10]: resource/HTTPHead/OPTIONS.png
[11]: resource/HTTPHead/TRACE2.png




