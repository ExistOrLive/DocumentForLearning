# Core Text

> **Core Text**是用于处理文本和字体的底层技术，和**Core Graphics**直接交互。`UITextView`，`UILabel`，`UIWebView`底层都是使用CoreText实现的。

> **Core Text**和基于`UIWebView`都可以实现复杂的文字排版效果，但是各有优劣

- Core Text是底层API，占用内存少，渲染速度快;UIWebView 占用内存多，渲染速度慢
- Core Text在渲染界面之前就可以获得显示的内容高度(通过CTFrameRef获取)，UIWebView需要渲染后才能获取内容的高度
- Core Text的CTFrame可以在后台渲染，UIWebView只能在主线程渲染
- Core Text渲染出的内容不能像UIWebView一样支持复制
- 基于Core Text来排版需要自己处理许多复杂的逻辑，如图片和文字混排，支持链接点击等