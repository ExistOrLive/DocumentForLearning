# podfile
#cocoapods
#依赖管理 
#podfile

## 1. source 


`source`指令指定索引库(specs)的地址
```ruby
source "https://github.com/aliyun/aliyun-specs.git"
source "https://github.com/CocoaPods/Specs.git"
```
使用source指定索引库，顺序很重要。Cocoapods 会使用第一个source中最高版本的pod，不论后面的source是否包含更高的版本。
​

官方的source是隐式指定的。当你指定其他source时，需要显式制定官方source。
​

## 2. Dependencies


### 2.1 pod 
​

`pod` 用于指定project或者target依赖的pod库。
​

`pod` 后面跟随pod库的名字以及可选的版本要求。
​

```ruby
pod 'Objection', '0.9'
```
#### 2.1.1 版本控制


- '= 0.1',                   指定版本为 0.1.
- '> 0.1',                   指定版本高于 0.1
- '>= 0.1',                 指定版本高于或等于 0.1
- '~> 0.1.2'                指定版本高于或等于 0.1.2 ，且小于 0.2.0
- '~> 0'                    指定版本高于等于0，小于 1
- '~> 0.1.3-beat.0'     指定版本高于等于0.1.3 小于0.2

​

  `~>` 表示高于等于指定版本，但小于下一个版本。 下一个版本基于最后一个子版本号。如 '0.1.2'下一个版本为'0.2.0'，'1.3.4.5'下一个版本为'1.3.5.0' , '0' 下一个版本为 '1' ;   带 '-' 的版本号之后的部分会被忽略，'0.1.3-beat.0' 下一个版本为 '0.2.0'
​

#### 2.1.2 pod库source配置

- 不指定pod库的地址，将从索引库中查找对应的.podspec文件，从.podspec文件中读取库地址
```ruby
pod 'QueryKit/Attribute'
```

- 指定source
```ruby
pod 'PonyDebugger', :source => 'https://github.com/CocoaPods/Specs.git'
```

- 指定git地址, 不指定 branch，tag，commit时，默认为master分支最新的commit
```ruby
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git'
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :branch => 'dev'
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :tag => '0.7.0'
pod 'AFNetworking', :git => 'https://github.com/gowalla/AFNetworking.git', :commit => '082f8319af'
```

- 直接指定路径，developerment pod
```ruby
pod 'AFNetworking', :path => '~/Documents/AFNetworking'
```

- 通过 subspecs 安装指定的子库
```ruby
# 安装 QueryKit 的 Attribute 和 QuerySet 子库
pod 'QueryKit', :subspecs => ['Attribute', 'QuerySet']
```

- 如果某个库中没有.podspec文件，可以使用podspec指定库外的.podsepc文件
```ruby
pod 'JSONKit', :podspec => 'https://example.com/JSONKit.podspec'
```

- 通过 testspecs 可以指定测试库
```ruby
pod 'AFNetworking', :testspecs => ['UnitTests', 'SomeOtherTests']
```

- build configuration 默认情况下，pod 库将会安装在所有的build configuration下，也可以显示指定在某几个build configuration下
```ruby
pod 'PonyDebugger', :configurations => ['Debug', 'Beta']
```
### 
### 2.2 target 和 abstract target
target 与 xcode 工程中的 target 对应，在 target 闭包中声明的 pod 库即对应 xcode 工程中的实际 target 所依赖的 pod库。
target 定义了 pod 库的作用范围。
target 之中可以包含 target，target 可以继承父 target 的pod库和其他配置
```ruby
target 'ZipApp' do
  pod 'SSZipArchive'
end
```
abstract_target 是一个虚拟的target，不与 xcode 工程中的实际 target 对应。abstract_target主要是 pod 库和其他一些配置的继承
```ruby
abstract_target 'Networking' do
  pod 'AlamoFire'

  # Networking App 1 , Networking App 2 继承 Networking 的 AlamoFire 库声明
  target 'Networking App 1'
  target 'Networking App 2'
end
```
在 Podfile 文件中，隐式声明了一个最外层的 abstract target
```ruby
# 最外层的隐式 abstract target 

platform :ios, '9.0'
use_modular_headers!

pod "ZMToolBase"

target 'ZMTool' do
  # 继承隐式abstract target 的 ZMToolBase
  pod "Alamofire"
end

target 'ZMTool_extension' do
  pod "CTMediator"
end
```
`inherit!` 可以指定继承的模式

- :complete   完全继承父target的所有行为
- :none         不继承
- :search_paths  只继承search_paths
```ruby
target 'App' do
  target 'AppTests' do
    # 只继承search_paths
    inherit! :search_paths
  end
end
```
## 
## 3. target configuration 
以下配置都是 target 闭包( 包括最外层的隐式abstract target )内的配置
### 3.1 platform
platform 指定支持的系统和版本号；如果未指定，则为默认值：iOS 4.3，OS X 10.6，tvOS 9.0，watchOS 2.0
```ruby
platform :ios, '4.0'
platform :ios
```
### 3.2 project
当 Podfile 文件用于多个 project 时，指定 target 所属的 project 
​

当 Podfile 文件只用于一个 project时，不需要显示指定
```ruby
target 'MyGPSApp' do
  project 'FastGPS'
  ...
end

# Same Podfile, multiple Xcodeprojects
target 'MyNotesApp' do
  project 'FastNotes'
  ...
end

project 'TestProject', 'Mac App Store' => :release, 'Test' => :debu
```
### 3.3 inhibit_all_warnings!
屏蔽所有来自pod库的告警
也可以单独关闭或者打开告警屏蔽
```ruby
# 屏蔽 SSZipArchive 的告警
pod 'SSZipArchive', :inhibit_warnings => true

---- 
# 屏蔽所有告警
inhibit_all_warnings!

# 单独放开SSZipArchive 的告警
pod 'SSZipArchive', :inhibit_warnings => false
```
### 3.4 use_frameworks!
pod 将被打包为 framework 而不是 static library。 :linkage 指定打包为静态framewok还是动态framework
```ruby
target 'MyApp' do
  # 动态framewok
  use_frameworks! :linkage => :dynamic
  pod 'AFNetworking', '~> 1.0'
end

target 'ZipApp' do
  # 静态framewok
  use_frameworks! :linkage => :static
  pod 'SSZipArchive'
end
```
### 3.5 use_modular_headers!
默认情况下，pod库会被打包为static library。use_modular_headers!可以为pod库创建modular header，这样pod库就可以作为模块被引入。
​

```ruby
# 可以单独打开或者关闭modular header
pod 'SSZipArchive', :modular_headers => false
pod 'SSZipArchive', :modular_headers => true
```
​

## 4 Workspace


### 4.1 workspace
workspace命令 指定包含所有的project的workspace的名字


如果没有显式指定 workspace，且只有一个 project 在 Podfile 的目录下；project 的名字将作为 workspace 的名字


```ruby
workspace 'MyWorkspace'
```


### 4.2 generate_bridge_support!
??
​

### 4.3 set_arc_compatibility_flag!
set_arc_compatibility_flag! 命令将 -fobjc-arc 添加到 OTHER_LD_FLAGS
​

## 5 Hooks
Podfile 可以为 pod install 过程添加 hook；hook 是全局的，不是针对某个 target 的
### 5.1 plugin
plugin 指定在安装过程中使用的插件和插件的参数
​

```ruby
plugin 'cocoapods-keys', :keyring => 'Eidolon'
plugin 'slather'
```
​

### 5.2 pre_install
pre_install 允许你在pod库下载完成之后，安装之前，执行修改
```ruby
pre_install do |installer|
  # Do something fancy!
end
```
### 5.3 pre_integrate
pre_integrate 允许你在工程写入磁盘之前做修改
​

```ruby
pre_integrate do |installer|
  # perform some changes on dependencies
end
```
### 5.4 post_install
post_install允许你在生成Xcode project写入磁盘之前做最后的修改
​

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['GCC_ENABLE_OBJC_GC'] = 'supported'
    end
  end
end
```
### 5.5 post_integrate
post_integrate 允许你在工程写入磁盘之后，做修改
```ruby
post_integrate do |installer|
  # some change after project write to disk
end
```


[Podfile Syntax Reference ](https://guides.cocoapods.org/syntax/podfile.html#source)
​

