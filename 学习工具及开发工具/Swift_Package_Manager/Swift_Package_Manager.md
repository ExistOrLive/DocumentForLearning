# Swift Package Manager
#Swift
#Swift_Package_Manager
#包管理
#依赖管理

**Swift Package Manager** 提供了一个基于约定的系统，用于构建库和可执行文件，并在不同的包之间共享代码。

**Swift Package Manager** 是一个管理Swift代码分发的工具。和swift构建系统一起实现了下载，编译，链接 依赖包的自动化流程。

## 1. 一些概念

##### 模块(module)
Swift 将代码组织为**模块**。 每个模块指定一个命名空间，并对外部模块能够访问的代码强制实施访问控制。

一个程序可能会在一个模块中包含所有的代码，但是更多的情况会引入其他的模块作为依赖。
除了少部分系统提供的模块，大部分依赖需要下载代码并构建才能够使用。

模块的使用可以方便代码复用以及测试。

##### 包(package)

包由swift源码和一个组织清单文件组成。 组织清单文件也就是`Package.swift`, 定义了包的名字以及包的内容。

一个包有一个或多个 target。 每个target 指定一个 product，还会声明一个或多个依赖。

##### 产品(product)

一个target的构建产物可以是一个库(library) 或者是一个可执行文件 (executable) 。 库包含一个模块，可以被其他swift代码引用。 可执行文件是一个可以在操作系统上执行的程序

##### 依赖(dependencies)
target的依赖就是一个或多个组件，这些组件被包中的代码所需要。一个依赖由一个指向包来源的相对或者绝对的url 和 一系列对包的版本要求 组成。

**Swift Package Manager** 的作用就是通过自动下载和构建依赖包来减少协调成本。这是一个递归的过程，一个依赖也可以有自己的依赖，每个子依赖又会有依赖，这样就构成一个**依赖图**


## 2. Swift Package Manager Tools

- swift package
- swift run
- swift build
- swift test 

#### 2.1 创建package 
```sh
USAGE: swift package init <options>

OPTIONS:
  --type <type>           Package type: empty | library | executable |
                          system-module | manifest (default: library)
  --name <name>           Provide custom package name
  --version               Show the version.
  -help, -h, --help       Show help information.
```

`swift package init --name Hello --type executable` 创建一个可执行 swift package，目录结构如下：

```
├── Package.swift
├── README.md
├── Sources
│   └── Hello
│       └── Hello.swift
└── Tests
    ├── HelloTests
    │   └── HelloTests.swift
    └── LinuxMain.swift
```

#### 2.2 构建 package
```sh
USAGE: swift build <options>

OPTIONS:
  --build-tests           Build both source and test targets
  --show-bin-path         Print the binary output path
  --target <target>       Build the specified target
  --product <product>     Build the specified product
  --version               Show the version.
  -help, -h, --help       Show help information.

```

`swift build` 构建后的产物默认在 `.build` 文件夹下

```sh
-> % swift build
[3/3] Build complete!
```

![](https://raw.githubusercontent.com/ExistOrLive/existorlivepic/master/202204142118833.png)

#### 2.3 运行 test
```sh
USAGE: swift test <options>

OPTIONS:
  --skip-build            Skip building the test target
  --parallel              Run the tests in parallel.
  --num-workers <num-workers>
                          Number of tests to execute in parallel.
  -l, --list-tests        Lists test methods in specifier format
  --show-codecov-path     Print the path of the exported code coverage JSON
                          file
  -s, --specifier <specifier>
  --filter <filter>       Run test cases matching regular expression, Format:
                          <test-target>.<test-case> or
                          <test-target>.<test-case>/<test>
  --skip <skip>           Skip test cases matching regular expression, Example:
                          --skip PerformanceTests
  --xunit-output <xunit-output>
                          Path where the xUnit xml file should be generated.
  --test-product <test-product>
                          Test the specified product.
  --version               Show the version.
  -help, -h, --help       Show help information.
```

```sh
-> % swift test
[3/3] Build complete!
Test Suite 'All tests' started at 2022-04-14 21:20:41.098
Test Suite 'HelloPackageTests.xctest' started at 2022-04-14 21:20:41.099
Test Suite 'HelloTests' started at 2022-04-14 21:20:41.099
Test Case '-[HelloTests.HelloTests testExample]' started.
Test Case '-[HelloTests.HelloTests testExample]' passed (0.338 seconds).
Test Suite 'HelloTests' passed at 2022-04-14 21:20:41.438.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.338 (0.338) seconds
Test Suite 'HelloPackageTests.xctest' passed at 2022-04-14 21:20:41.438.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.338 (0.339) seconds
Test Suite 'All tests' passed at 2022-04-14 21:20:41.438.
	 Executed 1 test, with 0 failures (0 unexpected) in 0.338 (0.340) seconds
```

#### 2.4 运行可执行package
```sh
USAGE: swift run [<options>] [<executable>] [<arguments> ...]

ARGUMENTS:
  <executable>            The executable to run
  <arguments>             The arguments to pass to the executable

OPTIONS:
  --skip-build            Skip building the executable product
  --build-tests           Build both source and test targets
  --repl                  Launch Swift REPL for the package
  --version               Show the version.
  -help, -h, --help       Show help information.
```

```sh
# Hello包下只有一个可执行文件，因此不用指定
-> % swift run
[0/0] Build complete!
Hello, world!

-> % swift run --skip-build
Hello, world!
```

也可以直接执行 `.build` 目录下的可执行文件

```sh
-> % ./Hello
Hello, world!
```

## 3. Package.swift
`Package.swift` 仍然是一个swift文件，遵循swift的语法。文件中需要定义了一个  `Package` 类的对象，该对象的属性也就是 Package 的各种配置

`Package`类的定义在 `PackageDescription` 模块中

```swift
Package(
    name: String,
    defaultLocalization: [LanguageTag]? = nil.
    platforms: [SupportedPlatform]? = nil,
    products: [Product] = [],
    dependencies: [Package.Dependency] = [],
    targets: [Target] = [],
    swiftLanguageVersions: [SwiftVersion]? = nil,
    cLanguageStandard: CLanguageStandard? = nil,
    cxxLanguageStandard: CXXLanguageStandard? = nil
)
```

更多 `Package.swift`的配置，请参考[PackageDescription](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)

#### 示例
```swift 
// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "MyLibrary",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(name: "MyLibrary", targets: ["MyLibrary"]),
    ],
    dependencies: [
        .package(url: "https://url/of/another/package/named/Utility", from: "1.0.0"),
    ],
    targets: [
        .target(name: "MyLibrary", dependencies: ["Utility"]),
        .testTarget(name: "MyLibraryTests", dependencies: ["MyLibrary"]),
    ]
)

```

## 4. 使用Xcode打开Swift Package Manager管理的项目

Xcode 可以直接打开Swift Package Manager 管理的项目, 打开后会自动下载项目的依赖，生成 Xcode 的 target 和 scheme 


## 参考文档

[Using the Package Manager](https://www.swift.org/getting-started/#using-the-package-manager)
[Package Manager](https://www.swift.org/package-manager/)
[PackageDescription](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)
[如何使用Swift Package Manager](https://www.jianshu.com/p/d75c1752955a)
[使用 Swift 编写 CLI 工具的入门教程](https://mp.weixin.qq.com/s/V4IdsYUouKGr68ULyb88Qw)

