# fastlane

## 1. fastlane 的安装

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


## 2. 初始化fastlane

- 在项目目录下执行，并按照提示选择所需功能，输入应用信息以及Apple开发信息

```sh
fastlane init 
```

- 执行完成后，在项目目录下生成fastlane文件夹，文件夹中生成两个文件

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.05.49.png)
   

- Appfile 中包含该应用的基本信息,(app id,开发者账号信息)

 ```ruby
 app_identifier("com.zm.OCTest") # The bundle identifier of your app
apple_id("18351927991@163.com") # Your Apple email address

itc_team_id("121050685") # App Store Connect Team ID
team_id("24LG5QVBPR") # Developer Portal Team ID

# For more information about the Appfile, see:
#     https://docs.fastlane.tools/advanced/#appfile
 ```
  
- Fastfile 中 包含持续集成的步骤配置

```ruby
default_platform(:ios)

platform :ios do
  desc "Push a new release build to the App Store"
  lane :release do
    build_app(scheme: "OCTest")
    upload_to_app_store(skip_metadata: true, skip_screenshots: true)
  end
end

# 一个lane代表一个CI的配置，可以看到release中包括两个步骤build_app，upload_to_app_store。

# build_app，upload_to_app_store 这俩个步骤是fastlane中已经定义好的action工具

```

接下来，我们会使用`match`，`gym`，`pilot`等`fastlane`中已经定义好的`action`。查看某个action具体参数，请使用命令

```sh
fastlane action actionName
```




## 3. 使用match管理证书

> match(sync_code_signing) 在github仓库中加密保存证书和描述配置文件，用于开发成员之间共享

1. 在github上创建一个仓库用于保存证书

2. 在项目目录下执行`fastlane match init`,输入仓库地址；在fastlane目录下会生成`Matchfile`文件，包含match的配置信息

![][5]

3. 执行这些命令`fastlane match development`, `fastlane match adhoc`, `fastlane match enterprise`，`fastlane match appstore`，首次执行自动在`apple store connect`中创建provisioning file，证书并下载加密保存在git仓库，并上传.

2. 其他开发者就可以使用`fastlane match`命令共享github中的证书和配置文件。

![][6]


### 在CI中使用match

在一次CI中首先就是要同步证书和描述配置文件

```ruby
    
# match 中需要配置参数
# 证书类型   appstore ， adhoc 还是 development
# app id
# kaychain 证书保存的keychain
# git_url  证书保存的github远端库
lane :github_action_testFlight do

match(type: "appstore",       
      readonly: true,
      app_identifier: "com.zm.ZLGitHubClient",
      keychain_name: ENV['MATCH_KEYCHAIN_NAME'],
      keychain_password: ENV['MATCH_PASSWORD'],
      git_url: ENV['MATCH_GITHUB_URL'])

end

# ENV['MATCH_GITHUB_URL'] 是加密保存的参数
```

## 4. 使用gym打包，签名

`gym`是`fastlane`提供的用于打包，签名的`action`，是`build_app`的别名。

```ruby
# 使用gym的参数
# 打包的工程
# 打包的方式 app-store，adhoc还是development
# 打包文件的目录

lane :github_action_testFlight do

    gym(workspace: "ZLGitHubClient.xcworkspace",
        scheme: "ZLGitHubClient",
        clean: true,
        include_symbols: true,
        include_bitcode: true,
        skip_build_archive: true,
        archive_path: "./fastlane/archive/ZLGitHubClient.xcarchive",
        output_directory: "./fastlane/ipa/TestFlight",
        output_name: "ZLGitHubClient.ipa",
        export_options: {
          method: "app-store",
          provisioningProfiles: {
            "com.zm.ZLGitHubClient" => "*** AppStore com.zm.ZLGitHubClient"
            }
            })
end
```

## 5. 使用上传testfight

```ruby

# pilot 需要提供apple开发者账号信息，以及上传文件目录

lane :github_action_testFlight do
    pilot(
      username: "18351927991@163.com",
      app_identifier: "com.zm.ZLGitHubClient",
      changelog: "release to TestFlight",
      ipa: "./fastlane/ipa/TestFlight/ZLGitHubClient.ipa"
    )
end

```

## 6. 使用App Store Connect API 避免双因素认证

在早先，访问App Store Connect信息需要双因素认证。而在持续集成的过程中一般无法人机交互(例如github-action)，导致持续集成无法完成。在`WWDC18`中，苹果提出了App Store Connect API，提供另外的认证方式。`Fastlane`也对App Store Connect API提供了支持，具体查看[Using App Store Connect API Edit on GitHub][7]

### 6.1 使用 App Store Connect  

必须拥有访问权限才能访问 App Store Connect API

1. 申请访问权限

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.53.35.png)

2. 生成API密钥

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.57.12.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.59.03.png)

3. 密钥生成后需要关注`Issuer ID`,`密钥 ID`以及下载密钥文件(.p8); 密钥文件只能下载一次。

### 6.2 在fastlane中使用App store connect中

```ruby
lane :release do
  api_key = app_store_connect_api_key(
    key_id: "D383SF739",
    issuer_id: "6053b7fe-68a8-4acb-89be-165aa6465141",
    key_filepath: "./AuthKey_D383SF739.p8",
    duration: 1200, # optional
    in_house: false, # optional but may be required if using match/sigh
  )

  pilot(api_key: api_key)
end
```

## 7. 完整的CI配置

```ruby
  desc "build one TestFlight release on github action"
  lane :github_action_testFlight do
    
    # 创建 app_store_connect_api_key
    api_key = app_store_connect_api_key(
    key_id: ENV['APPSTOREAPIKEYID'],
    issuer_id: ENV['APPSTOREAPIISSUERID'],
    key_content: "./AuthKey_D383SF739.p8",
    duration: 1200, # optional
    in_house: false, # optional but may be required if using match/sigh
    )
    
    # 创建keychain用于保存证书和描述配置文件
    create_keychain(
      name: ENV['MATCH_KEYCHAIN_NAME'],
      password: ENV['MATCH_PASSWORD'],
      default_keychain: true,
      unlock: true,
      timeout: 3600,
      add_to_search_list: true
    ) 
  
    # 同步证书证书和描述配置文件
    match(type: "appstore",
          readonly: true,
          app_identifier: "com.zm.ZLGitHubClient",
          keychain_name: ENV['MATCH_KEYCHAIN_NAME'],
          keychain_password: ENV['MATCH_PASSWORD'],
          git_url: ENV['MATCH_GITHUB_URL'])
    
    # 编译，打包，签名
    gym(workspace: "ZLGitHubClient.xcworkspace",
        scheme: "ZLGitHubClient",
        clean: true,
        include_symbols: true,
        include_bitcode: true,
        skip_build_archive: true,
        archive_path: "./fastlane/archive/ZLGitHubClient.xcarchive",
        output_directory: "./fastlane/ipa/TestFlight",
        output_name: "ZLGitHubClient.ipa",
        export_options: {
          method: "app-store",
          provisioningProfiles: {
            "com.zm.ZLGitHubClient" => "*** AppStore com.zm.ZLGitHubClient"
            }
            })
    
    # 上传testflight
    pilot(
      api_key: api_key
      app_identifier: "com.zm.ZLGitHubClient",
      changelog: "release to TestFlight",
      ipa: "./fastlane/ipa/TestFlight/ZLGitHubClient.ipa"
    )
    )
  end
```




  











#### 



## 参考文档

[iOS使用fastlane一键打包审核][1]




[1]: https://docs.fastlane.tools/getting-started/ios/setup/

[2]: https://note.youdao.com/ynoteshare1/index.html?id=467b57ae4e6f4f744948e531f54a42c3&type=note


[3]: pic/fastlane_install_issue1.png

[4]: pic/fastlane_install_Step1.png

[5]: pic/fastlane_match_init.png

[6]: pic/fastlane_match_github.png

[7]: https://docs.fastlane.tools/app-store-connect-api/