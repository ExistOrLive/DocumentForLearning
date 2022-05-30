# WKUserContentController

**WKUserContentController** 是一个管理js代码和WKWebView交互和过滤web内容的对象。

**WKUserContentController** 为app和webview中执行的JS代码之间提供了一个桥接。 

- 为网页注入js代码

- 注册自定义JS函数，用于JS回调给app原生代码

- 指定自定义过滤器去限制某些内容的展示

创建一个**WKUserContentController** 对象传递给 **WKWebViewConfiguration**，用于创建一个 **WKWebView** 

