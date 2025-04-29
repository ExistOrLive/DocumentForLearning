# App包瘦身

## 苹果的限制

1. App Store 限制 150 MB 以下的包才能够使用 OTA(Over-the-air)下载，否则只能使用wifi下载

2. 如果 App 兼容 iOS7 和 iOS8， 苹果限制主二进制 text段不得超过 60 MB


## 官方 App Thinning

**App Thinning** 是由苹果公司推出的一项可以改善 App 下载进程的新技术，主要是为了解决用户下载 App 耗费过高流量的问题，同时还可以节省用户 iOS 设备的存储空间。

App Thinning 会专门针对不同的设备来选择只适用于当前设备的内容以供下载。比如，iPhone 6 只会下载 2x 分辨率的图片资源，iPhone 6plus 则只会下载 3x 分辨率的图片资源。

使用 App Thinning 后，用户下载时就只会下载一个适合自己设备的芯片指令集架构文件。


App Thinning 有三种方式，包括：**App Slicing**、**Bitcode**、**On-Demand Resources** 。


- **App Slicing**，会在你向 iTunes Connect 上传 App 后，对 App 做切割，创建不同的变体，这样就可以适用到不同的设备。

- **On-Demand Resources**
，主要是为游戏多关卡场景服务的。它会根据用户的关卡进度下载随后几个关卡的资源，并且已经过关的资源也会被删掉，这样就可以减少初装 App 的包大小。

- **Bitcode** ，是针对特定设备进行包大小优化，优化不明显。


## 资源文件瘦身

- 删除无用的图片，音频等资源：
  
  可以使用工具：[LSUnusedResources](https://github.com/tinymind/LSUnusedResources)

  (MitImgChecker)[https://github.com/mitchell-dream/MitImgChecker]


- 压缩图片

   将图片格式转为 [**webp**](https://developers.google.com/speed/webp/)，这是google的一个开源项目

   可以使用google的[cwebp](https://developers.google.com/speed/webp/docs/precompiled)开源压缩工具或者腾讯的[isparta](http://isparta.github.io/)工具将图片格式转为 webp。

   在工程中加载图片时要使用[libwebp](https://github.com/carsonmcdonald/WebP-iOS-example)先做解析，但是这样webp的加载时间就会比png高两倍。

   这样就需要在空间和时间上做取舍，如果图片大小超过了 100KB，你可以考虑使用 WebP；而小于 100KB 时，你可以使用网页工具 [TinyPng](https://tinypng.com/)或者 GUI 工具[ImageOptim](https://imageoptim.com/mac)进行图片压缩


## 代码瘦身

### 查找无用的代码

- 首先，找出方法和类的全集；
- 然后，找到使用过的方法和类；
- 接下来，取二者的差集得到无用代码；
- 最后，由人工确认无用代码可删除后，进行删除即可。


**LinkMap**结合MachO查找无用代码：

1. 获取LinkMap

获取 LinkMap 可以通过将 **Build Setting** 里的 **Write Link Map File** 设置为 Yes，然后指定 **Path to Link Map File** 的路径就可以得到每次编译后的 LinkMap 文件了。

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-08-29%20%E4%B8%8B%E5%8D%884.16.02.png)



2. AppCode


3. hook objc_msgSend initialize方法时候有被调用



[深入探索 iOS 包体积优化](https://juejin.cn/post/6844904169938092045)

[如何让云音乐iOS包体积减少87MB](https://segmentfault.com/a/1190000041505761)

[iOS 包体积优化1 - 总览](https://juejin.cn/post/7185079396678991928/)




