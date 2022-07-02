# WKWebView 处理打开一个新窗口

如以下前端代码， `target="_blank"` 将会打开一个新的窗口
```js
<a href="https://web.qianguyihao.com" target="_blank" rel="noopener noreferrer">
https://web.qianguyihao.com
</a>
```

这种情况下，会调用 `WKUIDelegate` 的 `func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView` 方法

如果没有实现这个方法，WKWebView 将会默认取消这次请求。


## 1. 在当前 WKWebView 处理请求

一般会阻止创建一个新的WKWebView，而是在当前webview中处理改请求

```swift
func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
	// WkWebView 处理 window.open()
	if !(navigationAction.targetFrame?.isMainFrame ?? false) {
		webView.load(navigationAction.request)
	}
	return nil
}
    
```

[Returned WKWebView was not created with the given configuration问题修复](https://juejin.cn/post/6844904159271976973)

[Why is WKWebView not opening links with target="_blank"?](https://stackoverflow.com/questions/25713069/why-is-wkwebview-not-opening-links-with-target-blank)