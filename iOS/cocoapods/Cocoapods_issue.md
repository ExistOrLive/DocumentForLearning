# Cocoapods issues

## 引入swift编写的库的问题

![Cocoapods_issues_1_1][1]

> 如上图所示*Pods written in Swift can only be integrated as frameworks;add use_frameworks! to your Podfile or target to opt into using it*；因此需要在podfile文件中添加use_frameworks!，使得pod库作为framework引入

![Cocoapods_issues_1_2][2]

----


[1]: pic/Cocoapods_issue_1_1.png
[2]: pic/Cocoapods_issue_1_2.png