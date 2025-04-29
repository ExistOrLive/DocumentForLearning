#cocoapods
#依赖管理 
#podspec

# 创建pod库

这里以[SYDCentralPivot](https://github.com/ExistOrLive/SYDCentralPivot) 为例，阐述pod库从创建到发布的过程。

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-07-27%20%E4%B8%8B%E5%8D%8810.21.48.png)

## 1. pod lib

`pod lib`命令是用来创建 develop pod 库：

- `pod lib create` : 创建一个pod库

- `pod lib lint` : 验证一个pod库

## 2. 创建一个pod库

首先在项目目录下执行命令：

```ruby
pod lib create [podname]
```
![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8A%E5%8D%8810.00.18.png)

经过一系列的配置(平台，开发语言，测试框架，是否创建Demo),就完成了pod库的创建。

在项目目录下，生成了Demo,源码目录以及配置文件：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-03%20%E4%B8%8A%E5%8D%889.20.23.png)

- *.podspec
   
       podspec是当前pod库的描述文件
   
- Example 

       Demo 工程 

-  pod库目录 (SYDCentralPivot)

       pod库源码目录


- LICENSE
   
       开源许可证


- README.md

## 3. 打开Demo 工程

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8A%E5%8D%8810.50.20.png)

在`podfile`中可以看到Demo工程以相对路径的方式引入了`SYDCentralPivot`库。此时，`SYDCentralPivot`属于 `Development Pod`,在 `Development Pods`目录下，而不是在`Pods` 目录下。

### `Development Pod` 和 `普通 Pod` 的 区别

`Development Pod` 可以直接修改源文件，并在主工程中编译运行。而 `普通 Pod` 是不可以的

## 4. 在pod库中添加或者修改源码

直接将需要的源文件拖到 `SYDCentralPivot/Class`文件夹下； 在 `podspec`文件的配置中，源文件都在该目录下

```ruby
s.source_files = 'SYDCentralPivot/Classes/**/*'
```

执行`pod install`后，源文件就会出现在 `Development Pods`目录下：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8A%E5%8D%8811.04.55.png)


在 Demo 工程中，调用pod库的代码

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8A%E5%8D%8811.08.47.png)

## 5. podspec文件

`podspec` 文件是对pod库命名，地址，版本，源文件，资源文件以及依赖的具体描述。

- version 
  
       pod库通过tag控制版本，
       当前 `podspec`文件中的version应该与最新的tag保持一致 

- summary，description

        pod 库的描述



- homepage 

        远端库主页地址

- source 
 
        远端仓库地址


- source_files
  
         源文件路径

- resource_bundles 

         资源文件路径

- public_header_files 

         公共头文件路径

- dependency

          对于其他pod库的依赖

- frameworks 
          
          依赖的系统框架

- vendored_frameworks
 
           依赖的非系统框架

- libraries 

           依赖的系统库

- vendored_libraries

           依赖的非系统的静态库
        


```ruby
Pod::Spec.new do |s|

  s.name             = 'SYDCentralPivot'
  s.version          = '1.1.0'
  s.summary          = 'A Simple Factory and Router for UIViewController,ServiceModel and some other object'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Factory and Router'

  s.homepage         = 'https://github.com/ExistOrLive/SYDCentralPivot'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ExistOrLive' => '2068531506@qq.com' }
  s.source           = { :git => 'https://github.com/ExistOrLive/SYDCentralPivot.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'SYDCentralPivot/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SYDCentralPivot' => ['SYDCentralPivot/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

```

在修改了`podspec`文件后，记得使用`pod lib lint` 和 `pod spec lint`验证修改是否有效。 

## 6. 添加资源文件

如果希望在Pod库中添加资源文件(图片，音频以及其他一些配置文件等)，就需要用到配置`resource_bundles`

```ruby
s.resource_bundles = {
    'SYDCentralPivot' => ['SYDCentralPivot/Assets/*.png']
}
```

而在代码中，并不能够通过**MainBundle**访问这些资源文件，因为这些文件并不在主工程下，而是在主工程依赖的库中。

```swift 
// 通过pod库中定义的类获取pod库对应的bundle
let bundle = Bundle(for: ZLServiceManager.self)

// 在通过bundle获取文件内容或者路径
let configPath = bundle.path(forResource: "ZLServiceConfig", ofType: "plist")
```



## 5. 将pod库推送到远程

这里推送到Github，首先在Github上创建一个仓库，将仓库克隆到本地，将pod库复制到本地的仓库中。

- 修改 `podspec`文件，
    
        homepage 应该设置为远端库主页地址
        source 设置为远端库地址
        version 与 tag 保持一致

- 提交到远端库

    ```sh
    git add .
    git commit -m “xxx”
    git remote add origin 远程代码仓库地址
    git push origin master 或者 git push -u origin master（一般第一次提交用）
    git tag 版本号/git tag -a 版本号 -m “version 版本号”（注：这里的版本号必须和podspec里写的版本号一致）
    git tag 查看版本号是否提交成功
    git push - -tags
    ```

- 可以直接使用地址依赖pod库

   ```ruby
  pod 'SYDCentralPivot', :git => 'https://github.com/ExistOrLive/SYDCentralPivot.git'
   ```

## 6. 将podspec推送公共pod repo 或者 私有pod repo中

当把`podspec`文件推送到公共pod repo后，你就可以通过 `pod search` 搜索该pod以及直接使用名字安装pod库


### 6.1 推送到公共pod repo

`pod trunk [COMMAND]` 是用来和 `Cocoapods API` 交互的命令.

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%883.13.00.png)

- 首次推送pod，需要注册账号

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%883.16.43.png)

- `pod trunk push [PATH]`

  `pod trunk push` 将本地开发的pod库的`podspec`文件推送公共Cocoapods库中，即[Cocoapods Specs](https://github.com/CocoaPods/Specs)

  在推送之前，pod 还会验证 `podspec` 文件是够有效。如果不通过的话，就无法推送上去

  ![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%883.27.39.png)

  因此在推送之前必须使用 `pod lib lint` 或则 `pod spec lint` 去验证 `podspec` 文件 

  后期pod库更新版本后，同样使用  `pod trunk push` 推送。

### 6.2 推送到私有pod repo
  

## 7. 创建 subspec

`subspec` 需要指定子库的源文件和头文件

```ruby
 s.subspec 'Core' do |core| 
    core.ios.deployment_target = '9.0'
    core.source_files = 'SYDCentralPivot/Classes/Core/*'
    core.public_header_files = 'SYDCentralPivot/Classes/Core/*.h'
  end
```

## 参考文档

[podspec 语法](https://guides.cocoapods.org/syntax/podspec.html)

[制作Cocoapods库](https://www.cnblogs.com/strengthen/p/10639115.html)

[使用pod lib创建pod库](https://www.cnblogs.com/strengthen/p/10639183.html)

[iOS组建化—私有库](https://blog.csdn.net/sacrifice123/article/details/83958405)
