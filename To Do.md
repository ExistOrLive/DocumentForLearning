# To Do

## iOS  UI
- 转场动画学习 


## iOS 工程架构 
- Xcode 的基本概念 workspace， project，target 等
- module map 


## 算法与数据结构


## Ruby 语言学习


## Swift 语言高级特性
- 集合类型的继承关系及实现 

## Swift语言底层实现学习 

## iOS技术方向 

#### 界面逻辑
- 最基础的界面开发，各种UI组件的使用。如何实现微信的主要界面，实现微博的主要界面。
UITableView的使用、UICollectionView的使用。IGListKit的使用，ComponentKit的使用和原理。
- 异步UI渲染。Texture、YYLabel的原理。
- 动态化：如何实现微博的feed流，如何实现美团首页的feed流。这些feed流通常是一个一个卡片组成，卡片是通过json等格式数据动态生成的界面。动态化如何结合异步UI渲染，提升加载性能等。
- SwiftUI开发界面。跨苹果平台的界面开发。如何与UIKit和AppKit交互。
- 多线程开发
#### 动画
- 基础的动画实现。
- CoreAnimation的使用。
- 转场动画，常用哪些，有什么坑。这里写不好，会造成比较奇怪的crash等。
- SwiftUI的动画。

#### 架构
- 组件化
- 具体业务场景的架构
- CocoaPods的使用和原理
- 动态库的使用
- DI框架

#### 音视频
- 音视频开发
- AVFoundation
- opengl/metal

#### 偏底层
- 书 http://newosxbook.com/index.php 的 Volume I
- OC Runtime：如何调试oc runtime
- Swizzle、Aspect
- fishhook
- libffi
- JSPatch原理，WasmPatch原理
- Swift与Runtime相关的部分
- dyld
- MachO
- 代码覆盖率
- MainThreadChecker的实现
- 调试：lldb

#### 性能和稳定性
- 启动耗时：如何监控，如何优化。网上有大量的文章。
- 卡顿：如何监控，如何优化。
- FPS：如何监控，如何优化。
- 存储：如何监控，如何优化。
- 磁盘：如何监控，如何优化。
- 耗电：如何监控，如何优化。
- GPU：如何监控，如何优化。
- Crash：Crash原理，学习KSCrash源码。
- WatchDog：如何监控，如何优化。
- OOM（Abort）：如何监控。如何优化。
- Instruments工具使用：TimeProfiler的使用，Allocations等工具的使用。

#### 逆向工程
基础的逆向流程熟悉。
怎么砸壳，砸壳原理。frida-ios-dump的使用，bagbak的使用。
汇编：主要是arm64
工具：IDA和Hopper的使用
工具：frida的使用，Grapefruit的使用
工具：Messier的使用。
怎么破解一个iOS/macOS App
编译
Xcode编译过程，ipa产生过程
MonkeyDev原理
clang
lldb
ld64 链接器理解
LLVM 理解
LLVM Pass的开发
LLVM 插桩
LLVM bitcode的理解

#### DevOps
前端开发：vue和react的基础使用，前端UI库的基础使用
ruby/python/node/shell的脚步基础使用
某种faas系统的使用

#### 数据
埋点的完整实现
AB测试、AA测试
如何评价性能好坏
最基础的分位数的概念

#### 越狱

如何越狱，书 http://newosxbook.com/index.php 的 Volume III

#### 端智能
CoreML
MNN
TF Lite