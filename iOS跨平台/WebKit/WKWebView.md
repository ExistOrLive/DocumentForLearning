# WKWebView 

**WKWebView** 是一个展示交互式web内容的对象，例如一个应用内浏览器。

**WKWebView**是平台原生view用来无缝地组合web内容到你的app UI中。**WKWebView** 支持一个完整的web浏览器体验，在app原生view旁边展示HTML，CSS和JavaScript内容。 你可以在web技术比原生view更加满足应用布局和风格要求时，使用**WKWebView**。例如，你会在应用内容刷新频繁时使用它。

## **delegate** 

**WKWebView**通过 **delegate** 对象来提供导航和用户体验上的控制。 

当用户点击web内容中的链接或者与web内容交互影响导航时，你可以使用 **navigationDelegate** 来响应。 例如，你可以阻止webview跳转到新的页面除非满足某个条件。

**uiDelegate** 用于展示原生视图与web内容交互，例如 alert 或者 contextual menus。

## **WKWebViewConfiguration**

如果需要更多的自定义扩展，你可以使用 **WKWebViewConfiguration** 创建一个 **WKWebView**。例如，为自定义 URL scheme 指定处理handler，管理cookie，以及更多web选项.

**WKWebView** 可以将电话号码自动转换为链接。当用户点击链接后，会自动唤起电话并拨打号码。可以使用 **WKWebViewConfiguration** 修改这种默认的行为。


```swift
import UIKit
import WebKit
class ViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myURL = URL(string:"https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
    }
}
```

## 管理web内容的跳转

**WKWebView** 提供了完整的浏览器体验，例如网页间的跳转，前进和后退按钮以及更多。 

当用户点击链接，**WKWebView**会像浏览器一样跳转并展示链接的内容。使用**navigationDelegate**可以修改web挑战行为，或者追踪新内容的加载进度。

你可以使用**WKWebView**方法来切换web的内容或者由app界面的其他部分触发web页面跳转。例如，UI界面上有前进和后退按钮，你可以将按钮连接到**WKWebView**的`goForward(_:)`和`goBack(_:)`方法来触发对应的web内容跳转。使用`canGoBack()` 和 `canGoForward()`来决定何时去启用和禁用按钮。

## **scale**

你可以使用`setMagnification(_:centeredAt:) ` 来设置web内容首次展示的比例。之后用户可以通过手势修改比例







## 参考文档

[WKWebView](https://developer.apple.com/documentation/webkit/wkwebview)