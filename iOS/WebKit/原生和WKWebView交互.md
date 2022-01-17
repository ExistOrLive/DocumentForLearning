# 原生与WKWebView交互

## 1. WKWebContentController

**WKWebContentController** 为原生代码和JS代码之间提供了桥接。

### 1.1 为web页面注入JS代码

```swift

open var userScripts: [WKUserScript] { get }

// 插入脚本  
open func addUserScript(_ userScript: WKUserScript)

// 移除脚本
open func removeAllUserScripts()
```

### 1.2 向web页面注册回调到原生页面的js函数

```swift
    @available(iOS 14.0, *)
    open func add(_ scriptMessageHandler: WKScriptMessageHandler, contentWorld world: WKContentWorld, name: String)

    @available(iOS 14.0, *)
    open func addScriptMessageHandler(_ scriptMessageHandlerWithReply: WKScriptMessageHandlerWithReply, contentWorld: WKContentWorld, name: String)

    open func add(_ scriptMessageHandler: WKScriptMessageHandler, name: String)

    @available(iOS 14.0, *)
    open func removeScriptMessageHandler(forName name: String, contentWorld: WKContentWorld)

    open func removeScriptMessageHandler(forName name: String)

    @available(iOS 14.0, *)
    open func removeAllScriptMessageHandlers(from contentWorld: WKContentWorld)
```

1. 创建类实现协议 `WKScriptMessageHandler`

```swift

class ScriptMessageHandler: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage){
        print(message.body)
    }
}
```

2. `WKUserContentController` 注册 message handler

```swift 
 let configuration = WKWebViewConfiguration()
 let userContentController = WKUserContentController()
 // 注意此处传入self会强引用
 userContentController.add(self,name:"CallBack")
 configuration.userContentController = userContentController
```

3. 创建WKWebView

```swift
WKWebView(frame: CGRect.zero, configuration: configuration)
```

4. 在JS代码中调用回调函数

```javascript
let array = document.getElementsByTagName('html');
window.webkit.messageHandlers.CallBack.postMessage(array[0].offsetHeight)
```



[WKWebView的使用](https://www.jianshu.com/p/5cf0d241ae12)