# DocC的安装和使用
#DocC 
#文档生成工具 

## 1.  源码安装
[DocC](https://github.com/apple/swift-docc) 是一个Swift包，可以通过 [Swift_Package_Manager](../../../开发环境搭建/Swift开发环境/Swift_Package_Manager/Swift_Package_Manager.md) 构建生成 DocC 可执行文件。

下载 DocC源码
```sh
git clone https://github.com/apple/swift-docc.git
```

### 1.1 执行swift build 构建

1. 编译DocC源码

```sh
cd swift-docc

# 构建 x86_64 的docc可执行文件
swift build --arch x86_64 --configuration release --product docc

# 构建 arm64 的docc可执行文件
swift build --arch arm64 --configuration release --product docc

# 合并可执行文件
lipo -create -output .build/artifacts/docc `swift build --arch x86_64 --configuration release --product docc --show-bin-path`/docc  `swift build --arch arm64 --configuration release --product docc --show-bin-path`/docc 

```

2. 在 `swift-docc/.build/artifacts` 下找到docc可执行文件

![](http://pic.existorlive.cn//202206152135110.png)

3. 将可执行文件复制到安装目录下，并配置 path 环境变量

### 1.2 调用build-script-helper.py构建
swift-docc 提供了 build-script-helper.py 构建脚本，利用脚本我们可以快速生成可执行文件
![](http://pic.existorlive.cn//202206152153264.png)

```sh
python3 build-script-helper.py --toolchain /usr --no-local-deps --install-dir .build/artifacts  install
```

- toolchain :            swift tool 的安装目录 `/usr/bin/swift`
- no-local-deps :    不使用本地的依赖，下载远端的依赖
- install-dir：           可执行文件的安装目录

## 2. 设置DOCC_HTML_DIR环境变量
`DOCC_HTML_DIR`环境变量需要设置为 [swift-docc-render](https://github.com/apple/swift-docc-render) 的安装路径,   [swift-docc-render](https://github.com/apple/swift-docc-render) 是一个基于 Vue.js 的 web页面应用，将用于生成和预览DocC文档

### 2.1 Xcode13 或者更新的Xcode
如果已经安装了Xcode13或者更新的版本，在Xcode中已经自动安装了 Swift-DocC-Render；只需要设置 `DOCC_HTML_DIR` 环境变量即可。

```sh
export DOCC_HTML_DIR="$(dirname $(xcrun --find docc))/../share/docc/render"
```

### 2.2 下载 swift-docc-render-artifact
下载 swift-docc-render-artifact 仓库，并设置  `DOCC_HTML_DIR`  环境变量
```sh
git clone https://github.com/apple/swift-docc-render-artifact.git

export DOCC_HTML_DIR="/path/to/swift-docc-render-artifact/dist"
```

## 3. 编译源码生成symbol graph文件
**Symbol Graph** 文件以 `.symbols.json` 作为扩展名，是面向机器的模块API，包括文档注释和与其他模块的关系。

**Symbol Graph** 文件由 `swift build` 源码生成，`-emit-symbol-graph` 选项告诉swift编译器生成 **Symbol Graph** 文件。

以 [DeckOfPlayingCards](https://github.com/apple/example-package-deckofplayingcards.git) 为例：

```sh
# 编译 DeckOfPlayingCards target，并在.build文件夹下生成Symbol Graph文件

swift build --target DeckOfPlayingCards -Xswiftc -emit-symbol-graph -Xswiftc -emit-symbol-graph-dir -Xswiftc .build
```

![](http://pic.existorlive.cn//202206152304092.png)

## 4. 生成文档并启动web应用
`docc convert` 会读取 **Symbol Graph** 文件，并转换为 html 文档;
`docc preview`  则会启动一个web应用，展示生成的html文档

```sh 
docc preview DeckOfPlayingCards.docc  # 文档和附件目录；以及生成的html文档保存目录
--fallback-display-name DeckOfPlayingCards    
--fallback-bundle-identifier com.example.DeckOfPlayingCards1
--fallback-bundle-version 1 
--additional-symbol-graph-dir .build # symbol graph 文档目录
```
![](http://pic.existorlive.cn//202206152325537.png)

执行以上命令，生成的html文档保存在`DeckOfPlayingCards.docc/.docc-build`

![](http://pic.existorlive.cn//202206152325320.png)

在本地启动一个web应用，托管html文档；在浏览器打开输出的url： `http://localhost:8000/documentation/deckofplayingcards`

![](http://pic.existorlive.cn//202206152331306.png)


## 参考文档
[github swift-docc](https://github.com/apple/swift-docc)

[swift.org docc](https://www.swift.org/documentation/docc/)

