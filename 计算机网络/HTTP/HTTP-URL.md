# HTTP URL Percent Encoding and Decoding （RFC 3986）

通用的URL结构：

```
<scheme>://<user>:<password>@<host>:<port>/<path>;<params>?<query>#<frag>
```

一个URL是有以上各个组件以及分隔符组成。

   
| 组件        | 描述    |  默认值  |
| --------   | :-----   | :----: |
| 方案       | 协议    |      |
| 用户        | 用户名     |       |
| 密码        | 密码，中间由冒号分隔      |     |
| 主机       | 资源宿主服务器的主机名或点分IP地址    |      |
| 端口        | 资源宿主服务器正在监听的端口号    |       |
| 路径        | 服务器上资源的本定名，由斜杠将其与前面的URL组件分隔开来。路径组件的语法是与服务器和方案有关。      |     |
| 参数       | 某些方案会用这个组件来指定输入参数。参数为名/值对。URL中可以包含多个参数字段，它们相互之间以与路径的其余部分之间用分号（;）分隔。    |      |
| 查询字符串  | 某些方案会用这个组件传递参数以激活因公程序。查询组件的内容没有通用格式。用字符”?”将其与URL的其余部分分隔开来。    |       |
| 片段   | 	一小片或者一部分资源的名字。引用对象时，不会将frag字段传送给服务器。这个字段是在客户端内部使用的。通过字符”#”将其与URL的其余部分分隔开来。     |     |

### URL 字符序列

URL 在使用的过程中，就是一组字符的序列，由大小写字母，数字以及一些特殊字符组成。

```
ABCDEFGHIJKLMNOPQRSTUVWXYZ
abcdefghijklmnopqrstuvwxyz
0123456789
-_.~!*'();:@&=+$,/?#[] 
```
-  保留字符： `!*'();:@&=+$,/?#[]` 称为保留字符，用于URI各个组件之间的分隔符。

- 非保留字符： 数字，字母以及`-._~`组成URI的各个组件（如协议，主机名等）

### Percent Encoding

当URL的组件中，存在一些字符不在URL允许的字符序列中或者其中一些字符是作为URI的保留字符。 这里就会使用Percent Encoding机制，将这些字符转义为`%16进制数字`的格式。

```
// 这里会对中文字符进行转义

https://www.github.com/听赤岗

https://www.github.com/%E5%90%AC%E8%B5%A4%E5%B2%97


// 对包含保留字符的查询字符串进行转义

https://www.github.com
{param1 : === , param2 : +++dalj}

https://www.github.com?param1=%3D%3D%3D&param2=%2B%2B%2Bdalj

```


### Percent Encoding 和 Decoding的时机

- Percent Encoding

在组件组成一个完整的URL之前，对各个组件进行Percent Encoding ，将URL不支持的字符和保留字符转义

- Percent Decoding

收到一个完整的URL，首先根据保留字符将URL解释为一个个组件，再对每个组件进行 Percent Decoding


Tip：

1. 对于URL的组件，Percent Encoding 和Decoding只能进行一次，否则将URL无法处理













