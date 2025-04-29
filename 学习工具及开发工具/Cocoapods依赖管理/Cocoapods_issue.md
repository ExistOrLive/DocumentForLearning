# Cocoapods issues

## 引入swift编写的库的问题

![](https://pic.existorlive.cn/Cocoapods_issue_1_1.png)

> 如上图所示*Pods written in Swift can only be integrated as frameworks;add use_frameworks! to your Podfile or target to opt into using it*；因此需要在podfile文件中添加use_frameworks!，使得pod库作为framework引入

![](https://pic.existorlive.cn/Cocoapods_issue_1_2.png)

----

## 修改Cocoapods Spec镜像

[CocoaPods 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/CocoaPods/)


[1]: pic/Cocoapods_issue_1_1.png
[2]: pic/Cocoapods_issue_1_2.png

## podspec文件 dependency 问题

以下为某个podspec文件：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-09-13%20%E4%B8%8B%E5%8D%881.30.14.png)

执行`pod install`后得到报错：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2021-09-13%20%E4%B8%8B%E5%8D%881.29.59.png)

原因： 在 **podspec** 文件中设置 **dependency**时，只能简单设置pod库名字和版本号

```ruby
spec.dependency 'AFNetworking', '~> 1.0'
spec.dependency 'AFNetworking', '~> 1.0', :configurations => ['Debug']
```

## podspec 


