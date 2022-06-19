# DocC 和 Cocoapods
有很多swift开源库或者私有库并没有使用 Swift Package Manager 去组织代码，更多的使用 Cocoapods 这样的更流行的依赖管理工具。那么 DocC 是否能够支持 Cocoapods呢？

事实上，DocC 处理的是 **Symbol Graph** 文件，这是在Swift源文件编译期间产生的。
需要给swift编译器传递`-emit-symbol-graph` 选项

```sh
swift build --target DeckOfPlayingCards -Xswiftc -emit-symbol-graph -Xswiftc -emit-symbol-graph-dir -Xswiftc .build
```

因此我们只需要在生成pod库工程文件 build setting  -> swift compiler -custom flags -> other swift flags 中添加这几个选项即可；这个可以在podfile中实现