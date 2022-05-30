## 1. 在 Widget Extension 中引入 OC 代码

**Widget Extension** 中 UI框架 是 `SwiftUI`, 因此默认开发语言是 Swift。如果引入 OC 代码，则需要添加桥接文件。

如果 Widget 是可配置的，则需要添加 **.intentdefinition** 文件，生成的对应 **custom intent** 类。
如果 **Widget Extension** 是 纯粹 Swift 语言，**custom intent**类则默认是 Swift； 如果包含 OC 语言的代码，**custom intent**类则是 OC的。想要在 Swift 中使用，需要在桥接文件中声明。