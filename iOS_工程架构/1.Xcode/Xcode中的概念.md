# Xcode中的概念
#xcode 

## 1. Xcode 中的常见概念

- Workspace
- Project
- Target
- Scheme
- Build Setting (Xcconfig)
- Configuration
- Product 

## 2. Product 
**Product** 即 编译产物， Xcode 工程最终生成的东西； 按照 Mach- O Type 分为：

文件类型|描述
-|-
Executable|可执行文件
Dynamic Library|动态库
Bundle|非独立二进制文件, 需要在代码中dlopen显示加载
Static Library|静态库
Relocatable Object File|可重定位的目标文件，即.o目标文件

在**Building Setting** -> **Mach-O Type** 中，可以选择`Mach-O`类型

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-05-24%20%E4%B8%8A%E5%8D%883.43.23.png)

## 3.  Target 
**Target** 描述的是 Xcode 中的编译单元，编译对象； 一个 **Target** 对应 一个 **Product**， 生成一个 **Product** 需要指定 源码文件，以及 一系列 处理源码的配置，这些都将在 **Target** 中指定。

**Target** 的配置主要包含以下七个部分：

![](http://pic.existorlive.cn/202205090112392.png)


## 4. Build Settings

## 5. Configuration

## 6. Project

## 7. Scheme

## 8. WorkSpace







## 参考文档

[Xcode Concepts](https://mp.weixin.qq.com/s/PKAVxOIU-ACoZhM49KbVWQ)

[Apple Documents: Xcode Concepts](https://developer.apple.com/library/archive/featuredarticles/XcodeConcepts/Concept-Targets.html)