# Fastlane 的安装

##  1. 使用ruby的包管理工具Gem 安装

**Fastlane** 是基于 **Ruby** 开发的工具，因此可以使用**Gem** 来安装

```sh
sudo gem install fastlane -NV
```

#### issue

1. ERROR:  Error installing fastlane:
   ERROR: Failed to build gem native extension.

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/fastlane_install_issue1.png)

解决办法： 升级ruby，重新安装


## 2. 使用Homebrew安装 

```sh
brew install fastlane
```

1. 使用  brew install fastlane 安装；安装位置在 `/usr/local/Cellar`
   
![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/fastlane_install_Step1.png)

 
2. 在环境变量中设置fastlane , 在`～/.bash_profile`中添加

```bash
PATH="/Library/Frameworks/Python.framework/Versions/3.7/bin:${PATH}"
PATH="/usr/local/Cellar/fastlane/2.141.0/bin:${PATH}"       # 增加fastlane路径
PATH="/usr/local/opt/openssl@1.1/bin:${PATH}"
export PATH 
export LC_ALL=en_US.UTF-8     # 设置fastlane本地化字符编码  
export LANG=en_US.UTF-8
```

[Getting started with fastlane for iOS](https://docs.fastlane.tools/getting-started/ios/setup/)