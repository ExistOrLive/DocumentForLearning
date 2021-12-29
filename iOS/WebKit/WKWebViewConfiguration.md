# WKWebViewConfiguration

**WKWebViewConfiguration** 是一组用于初始化**WKWebView**的属性集合。

你可以指定以下配置：

- web内容可以访问的初始化cookies

- web内容如何处理自定义scheme

- 处理媒体内容的配置

- 怎样管理web内容的选择

- 插入web页面的JS脚本

- 决定怎样去渲染内容的自定义规则

你只可以在创建**WKWebView**的时候设置**WKWebViewConfiguration**，在此之后不可以动态的修改这些设置。

