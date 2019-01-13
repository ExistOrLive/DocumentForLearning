# OC工程引入Swift代码

## OC工程通过Cocoapods引入Swift库

- Swift pod库只能够作为framework被引入工程，因此需要在Podfile文件中添加*use_frameworks!* 选项

- 如果编译报如下的错误

  *The “Swift Language Version” (SWIFT_VERSION) build setting must be set to a supported value for targets which use Swift. This setting can be set in the build settings editor.*

  需要设置pod库的**Build Setting**中的**Swift Language Version**选项

----

## OC工程添加Swift代码配置

- 建立桥接文件 工程名-Bridging-Header.h
  
  在OC工程中创建Swift文件，会弹出提示框，要求创建桥接文件

  ![桥接文件1][3]

  生成桥接文件`ZLGithubClient-Bridging-Header.h`如下

  ![桥接文件2][4]

- Build Settings 配置

  设置Define Module为YES

  ![Define Module][5]

  设置Product Module Name 为当前工程名

  ![product_module_name][6]

  设置完之后，系统会为工程自动创建一个`工程名-Swift.h`的头文件(该文件在bundle中不可见)；
  
  在需要调用Swift代码的文件中引入该头文件。

----

## 参考文档

[Podfile中的use_frameworks!][1]

[在OC项目中引入Swift的方法][2]

[OC 调用 Swift 方法][7]

[Swift与OC混编][8]

[OC调用Swift4.0的各种坑][9]



[1]: https://www.jianshu.com/p/c8dadf10ec98
[2]: https://www.jianshu.com/p/a342fba7f418
[3]: pic/桥接文件1.jpg
[4]: pic/桥接文件2.png
[5]: pic/define_module.png
[6]: pic/product_module_name.png
[7]:https://blog.csdn.net/qin_shi/article/details/82458916
[8]: https://www.jianshu.com/p/69ba19692bae
[9]: https://blog.csdn.net/u012338816/article/details/83176751
