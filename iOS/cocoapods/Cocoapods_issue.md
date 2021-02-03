# Cocoapods issues

## 引入swift编写的库的问题

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/Cocoapods_issue_1_1.png)

> 如上图所示*Pods written in Swift can only be integrated as frameworks;add use_frameworks! to your Podfile or target to opt into using it*；因此需要在podfile文件中添加use_frameworks!，使得pod库作为framework引入

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/Cocoapods_issue_1_2.png)

----

## 修改Cocoapods Spec镜像

[CocoaPods 镜像使用帮助](https://mirrors.tuna.tsinghua.edu.cn/help/CocoaPods/)


[1]: pic/Cocoapods_issue_1_1.png
[2]: pic/Cocoapods_issue_1_2.png