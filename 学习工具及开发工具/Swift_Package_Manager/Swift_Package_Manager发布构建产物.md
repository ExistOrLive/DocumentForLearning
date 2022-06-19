# Swift Package Manager发布构建产物
#Swift
#Swift_Package_Manager 
#构建工具

以 [docc](https://github.com/apple/swift-docc) 为例，首先下载 docc 源码 

```sh
git clone https://github.com/apple/swift-docc.git
```

docc 的目录结构如下： 

![](http://pic.existorlive.cn//202206151758791.png)

从 `Package.swift` 中可以得出: docc 有三个构建产物：
- SwiftDocC                            库    
- SwiftDocCUtilities               库
- docc                                      可执行文件
```swift 
    products: [
        .library(
            name: "SwiftDocC",
            targets: ["SwiftDocC"]
        ),
        .library(
            name: "SwiftDocCUtilities",
            targets: ["SwiftDocCUtilities"]
        ),
        .executable(
            name: "docc",
            targets: ["docc"]
        )
    ],
```

## 1. swift build
`swift build` 是 swift package manager 提供的构建生成二进制产物的命令

直接执行 `swift build` 将会按照默认配置执行依赖下载，构建代码，生成产物的操作;

![](http://pic.existorlive.cn//202206151835047.png)

构建过程中的中间和最终产物默认都在 `.build` 文件夹下

![](http://pic.existorlive.cn//202206151836608.png)

- arm64-apple-macosx :  arm64架构的构建产物，不同的架构将生成不同的文件夹
- artifacts ： 最终产物
- checkouts： 依赖包指定版本或分支的源码
- repositories： 依赖包的仓库信息

默认情况下，`swift build` 仅生成当前系统和架构的，debug环境的二进制产物

### configuration选项
`configuration` 默认为 debug 

```sh
# 指定生成release环境的产物
swift build --configuration release

# 指定生成debug环境的产物
swift build --configuration debug
```

### arch 选项
一般mac支持 `x86_64` 和 `arm64` 两种架构， `arch` 默认为当前机器的架构

```sh 
# 生成x86_64架构产物
swift build --arch x86_64

#  生成arm64架构产物
swift build --arch arm64
```

### product 选项
如果不指定 `product` ，会构建生成swift保中的所有产物

```swift
# 仅生成docc
swift build --product docc
```

### 生成发布环境的，`x86_64` 和 `arm64` 两种架构的docc
```sh
swift build --arch x86_64 --configuration release --product docc

swift build --arch arm64 --configuration release --product docc
```

## 2. 合并可执行文件

利用 lipo 命令合并 x86_64 和 arm64 两种架构的可执行文件

```swift
lipo -create -output .build/artifacts/docc arm64_docc x86_64_docc
```


## 3. 总结

```sh
swift build --arch x86_64 --configuration release --product docc

swift build --arch arm64 --configuration release --product docc

lipo -create -output .build/artifacts/docc `swift build --arch x86_64 --configuration release --product docc --show-bin-path`/docc  `swift build --arch arm64 --configuration release --product docc --show-bin-path`/docc 

```