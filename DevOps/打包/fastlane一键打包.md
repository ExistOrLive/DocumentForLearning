# fastlane

## fastlane 的安装

###  使用ruby的包管理工具 `sudo gem install fastlane -NV`


#### issue

1. ERROR:  Error installing fastlane:
   ERROR: Failed to build gem native extension.

![][3]

解决办法： 升级ruby，重新安装


### 使用Homebrew安装 brew install fastlane


1. 使用  brew install fastlane 安装；安装位置在 `/usr/local/Cellar`
   
![][4]

 
2. 在环境变量中设置fastlane , 在`～/.bash_profile`中添加

```bash
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
PATH="/usr/local/Cellar/fastlane/2.141.0/bin:${PATH}"       # 增加fastlane路径
PATH="/usr/local/opt/openssl@1.1/bin:${PATH}"
export PATH 
export LC_ALL=en_US.UTF-8     # 设置fastlane本地化字符编码  
export LANG=en_US.UTF-8
```

[Getting started with fastlane for iOS][1]


## fastlane 使用

### iOS Beta deployment using fastlane

#### fastlane init 

> 

#### 使用match管理证书

> match(sync_code_signing) 在github仓库中加密保存证书和描述配置文件，用于开发成员之间共享

1. 在github上创建一个仓库用于保存证书

2. 在项目目录下执行`fastlane match init`,输入仓库地址

![][5]

3. 执行这些命令`fastlane match development`, `fastlane match adhoc`, `fastlane match enterprise`，`fastlane match appstore`，首次执行自动在`apple store connect`中创建provisioning file，证书并下载加密保存在git仓库，并上传.

4. 其他开发者就可以使用`fastlane match`命令共享github中的证书和配置文件。

![][6]

#### 使用gym打包

> gym(build_app) 编译，打包，签名。


#### 




[iOS使用fastlane一键打包审核][1]




[1]: https://docs.fastlane.tools/getting-started/ios/setup/

[2]: https://note.youdao.com/ynoteshare1/index.html?id=467b57ae4e6f4f744948e531f54a42c3&type=note


[3]: pic/fastlane_install_issue1.png

[4]: pic/fastlane_install_Step1.png

[5]: pic/fastlane_match_init.png

[6]: pic/fastlane_match_github.png