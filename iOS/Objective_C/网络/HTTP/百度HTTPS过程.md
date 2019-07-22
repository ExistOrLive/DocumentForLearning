# 百度HTTPS过程

 > 如下图所示，`https://www.baidu.com`请求的抓包

![][1]

> 首先我们看到TCP的三次握手,然后是SSL/TLS的握手流程：

- Client Hello ： 客户端向服务端发起握手

   ![][2]
  
  该报文属于Handshake Protocol的一部分，报文内容包括随机数，客户端支持的加密算法套件，session id以及扩展部分。

  随机数会用于之后对称秘钥的计算，属于混淆的一部分

  session id 用于会话的复用，由服务端生成，首次创建为空

  加密算法套件：服务端会选择其中一个加密算法使用(包括秘钥协商算法，对称加密和hash算法)

- Server Hello : 
  
  ![][4]

  该报文属于Handshake Protocol的一部分,用于回复Client Hello，报文内容包括随机数，选择的加密算法套件，sessionid以及扩展部分

  随机数 ： 与客户端生成的不是同一个，用于之后的密钥生成

  session id 

  加密套件： 服务端选择的加密算法，用于之后交互的加密

- Certificates 

  该报文属于Handshake Protocol的一部分,用于向客户端传递服务端数字证书

  ![][6]

  数字证书： 包含服务端信息和服务端公钥，是由服务端向第三方CA机构申请; 注意证书链的顺序，最下层证书在前（用户证书在前，上级证书在后）。发送的证书是二进制格式，并非base64之后的格式。

- Server Key Exchange 

  ![][9]

  该报文只有秘钥协商选择DHE/ECDHE时，才会发送
  秘钥协商算法选择RSA，不会发送。
  
  具体差异参看 ；[TLS/SSL 协议详解 (30) SSL中的RSA、DHE、ECDHE、ECDH流程与区别][8]

  baidu这里采用的是ECDHE算法，主要包括椭圆曲线类型和公钥，用于主秘钥的计算；这里数字证书中的秘钥就不参与主秘钥的协商了

- Server Hello Done

  ![][11]
  

- Client Key Exchange 

  ![][12]
  
  该报文只有秘钥协商选择DHE/ECDHE时，才会发送
  秘钥协商算法选择RSA，不会发送。

- Change Cipher Spec

  ![][13]

  这是一个无关紧要的数据。在TLS1.3中就被废弃了(可以发送、也可以不发送)。

  需要注意的是，该数据本身不被计算握手摘要，因为它的type不是Handshake。

- Encrypted HandShake Message 

  ![][14]
  
  这个报文的目的就是告诉对端自己在整个握手过程中收到了什么数据，发送了什么数据。来保证中间没人篡改报文。

  其次，这个报文作用就是确认秘钥的正确性。因为Encrypted handshake message是使用对称秘钥进行加密的第一个报文，如果这个报文加解密校验成功，那么就说明对称秘钥是正确的。

- Application Data
   
   ![][16]
   
   该报文就是实际的HTTP报文内容，已经被主秘钥加密；另外可以看到该报文不属于握手协议，而是Application_data_protocol http-over-tls 



## 参考文档

[TLS/SSL 协议详解 (9) Client hello][3]

[TLS/SSL 协议详解(10) server hello][5]

[TLS/SSL 协议详解(11) Server Certificate][7]

[TLS/SSL 协议详解(12) server key exchange][10]

[TLS/SSL 协议详解 (19) Encrypted handshake message][15]






[1]: pic/百度Https抓包.png
[2]: pic/百度Https抓包_ClientHello.png
[3]: https://blog.csdn.net/mrpre/article/details/77867439
[4]: pic/百度Https抓包_ServerClient.png
[5]: https://blog.csdn.net/sosfnima/article/details/84075406
[6]: pic/百度Https抓包_Certificates.png
[7]: https://blog.csdn.net/mrpre/article/details/77867770
[8]: https://blog.csdn.net/mrpre/article/details/78025940
[9]: pic/百度Https抓包_ServerKeyExchange.png
[10]: https://blog.csdn.net/mrpre/article/details/77867831
[11]: pic/百度Https抓包_ServerHelloDone.png
[12]: pic/百度Https抓包_ClientKeyExchange.png
[13]: pic/百度Https抓包_ChangeCipherSpec.png
[14]: pic/百度Https抓包_EncryptedHandShakeMessage.png
[15]: https://blog.csdn.net/mrpre/article/details/77868570
[16]: pic/百度Https抓包_ApplicationData.png
