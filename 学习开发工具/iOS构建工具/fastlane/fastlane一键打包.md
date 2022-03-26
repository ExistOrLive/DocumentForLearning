# Fastlane

## 1. 初始化fastlane

在项目目录下执行命令，并按照提示选择所需功能，输入应用信息以及Apple开发账号信息。

```sh
fastlane init 
```

执行完成后，项目目录下会自动生成`fastlane`文件夹，文件夹中生成两个文件`Appfile` 和 `Fastfile` 

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.05.49.png)
   

- **Appfile** 中包含该应用的基本信息(app id,开发者账号信息)

 ```ruby
app_identifier("com.zm.OCTest") # The bundle identifier of your app
apple_id("*********") # Your Apple email address

itc_team_id("*******") # App Store Connect Team ID
team_id("******") # Developer Portal Team ID

# For more information about the Appfile, see:
#     https://docs.fastlane.tools/advanced/#appfile
 ```
  
- **Fastfile** 中包含持续集成的步骤配置

一个命名的`lane`代表一个持续集成的任务，每个任务由多个步骤组成，步骤通常是已经定义好的`action`工具。

执行lane：

```sh
fastlane lanename
```

常用的action工具：

- **match** ： 证书和配置文件的管理
- **gym(build_app)** ： 打包和签名
- **poilt(upload_to_app_store)**：app store 发布

```ruby
default_platform(:ios)

# 以下是FastFile的配置示例

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


## 2. 使用match管理证书

**match(sync_code_signing)** 在github仓库中加密保存证书和描述配置文件，用于开发成员之间共享

[match官方文档](https://docs.fastlane.tools/actions/match/#match)

1. 在github上创建一个仓库用于保存证书

2. 在项目目录下执行`fastlane match init`,输入仓库地址；在fastlane目录下会生成`Matchfile`文件，包含match的配置信息

![](https://github.com/existorlive/existorlivepic/raw/master/fastlane_match_init.png)

3. 执行这些命令`fastlane match development`, `fastlane match adhoc`, `fastlane match enterprise`，`fastlane match appstore`，首次执行自动在`apple store connect`中创建provisioning file，证书并下载加密保存在git仓库，并上传.

4. 其他开发者就可以使用`fastlane match`命令共享github中的证书和配置文件。

![](https://github.com/existorlive/existorlivepic/raw/master/fastlane_match_github.png)

### match的参数 

- `type`: 同步的配置文件类型:  `appstore`,`adhoc`,`development`,`enterprise`,默认 `development`

- `readonly`: 默认false，如果是`true`,不会生成新的证书和描述配置文件

- `app_identifier`: 指定描述配置文件的bundle id；如果不指定则使用 AppFile 中的 app_identifier

- `git_url`: 证书保存的github地址

- `keychain_name` : 保存证书的keychain，默认login.keychain


### 在CI中使用match

在一次CI中首先就是要同步证书和描述配置文件：



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

## 3. 使用gym打包，签名

`gym`是`fastlane`提供的用于构建，打包，签名的`action`，是`build_app`的别名。

[gym官方文档](http://docs.fastlane.tools/actions/gym/#gym)

### gym的参数 

- `workspace`: 如果工程在workspace中需要指定，例如使用cocoapods的工程

- `project`: 如果工程不在workspace中指定工程名字

- `schema`： schema名 

- `clean`: 是否在打包前clean工程

- `export_method`: 指定打包方式： `app-store`, `ad-hoc`, `package`,                          `enterprise`, `development`, `developer-id`

- `export_options`: 可以指定更详细的打包配置，可以是配置文件路径

- `skip_build_archive`: 跳过构建，打包阶段，直接签名；使用`archive_path` 作为输入

- `skip_archive`：仅构建

- `skip_codesigning`: 仅构建，打包，不签名

- `archive_path` : 读取xarchive的路径

- `output_directory`: 保存ipa的目录

- `output_name`: 保存ipa的名字


### 在CI中使用gym


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

## 4. 使用pilot上传testfight

`pilot` 是可以与 `TestFlight` 交互的 `action`， 通过 `piolt` 你可以上传和发布新版本，添加和删除测试员。

[piolt 官方文档](http://docs.fastlane.tools/actions/pilot/#pilot)

`pilot` 在与 App store 交互之前需要双因素认证，这样就没有办法做自动化；不过苹果在 App Store Connect API 中提供Json Web Token的认证方法；具体在下面会介绍。

### pilot参数 

- `api_key_path` :  App Store Connect API Key JSON 文件的路径

- `api_key` : App Store Connect API Key, 通过 `app_store_connect_api_key` action 生成

- `app_identifier` : 上传版本的bundle id

- `ipa`: 上传的ipa文件路径


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

## 5. 使用App Store Connect API 避免双因素认证

在早先，访问App Store Connect信息需要双因素认证。而在持续集成的过程中一般无法人机交互(例如github-action)，导致持续集成无法完成。在`WWDC18`中，苹果提出了App Store Connect API，提供另外的认证方式。`Fastlane`也对App Store Connect API提供了支持，具体查看[Using App Store Connect API](https://docs.fastlane.tools/app-store-connect-api/)

### 5.1 使用 App Store Connect  

必须拥有访问权限才能访问 App Store Connect API

1. 申请访问权限

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.53.35.png)

2. 生成API密钥

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.57.12.png)

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2020-11-17%20%E4%B8%8A%E5%8D%886.59.03.png)

3. 密钥生成后需要关注`Issuer ID`,`密钥 ID`以及下载密钥文件(.p8); 密钥文件只能下载一次。

### 5.2 app_store_connect_api_key

`app_store_connect_api_key` 是用来为其他 `action` 生成 
`App Store Connect API token` 的 `action`; `match`,`pilot`以及 `deliver`等 `action` 都可以使用 `App Store Connect API token`

- `key_id`

- `issuer_id`

- `key_filePath`: p8文件的路径

- `key_content`： p8文件的内容，未编码直接提供需要将回车替换为\n

- `is_key_content_base64`: 是否key的内容经过base64编码

- `in_house`: 是app store还是 enterprise
  
```ruby

lane :release do
  api_key = app_store_connect_api_key(
    key_id: "D383SF739",
    issuer_id: "6053b7fe-68a8-4acb-89be-165aa6465141",
    key_filepath: "./AuthKey_D383SF739.p8",
    duration: 1200, # optional
    in_house: false, # optional but may be required if using match/sigh
  )
   
  # 在piolt中使用app_store_connect_api_key
  pilot(api_key: api_key)
end
```
---

## 6. 自动更新build number

如果上传TestFlight的新版本的build number，在TestFlight已经存在了，那么就会上传失败。

Fastlane 也提供了工具去自动更新build number

### 6.1 获取当前TestFlight中最新版本最新build number

`app_store_build_number` 可以返回当前已经发售或者正在测试的版本的最新build number

```ruby
currentBuildNumber = app_store_build_number(
  api_key: api_key,        # 使用app_store_connect_api_key认证
  live: false,             #  live 为 true 查询已发售的版本，false 查询测试的版本
  app_identifier: "com.zm.ZLGithubClient"
)

```

### 6.2 设置项目的build number

`increment_build_number` 可以修改项目的build number


```ruby
increment_build_number(
  build_number: currentBuildNumber + 1
)
```



## 7. 完整的CI配置

以下是使用 Github Action 作自动化打包的配置，一些关键性信息使用 Secret保存，Fastlane 通过环境变量读取.

```ruby

  desc "build one TestFlight release on github action"
  lane :github_action_testFlight do
    
    # 生成 app store connect api key
    api_key = app_store_connect_api_key(
    key_id: ENV['APPSTOREAPIKEYID'],
    issuer_id: ENV['APPSTOREAPIISSUERID'],
    key_content: ENV['APPSTOREAPIKEY'],
    duration: 1200, # optional
    in_house: false, # optional but may be required if using match/sigh
    )

    # 创建 key chain 保存 证书
    create_keychain(
      name: ENV['MATCH_KEYCHAIN_NAME'],
      password: ENV['MATCH_PASSWORD'],
      default_keychain: true,
      unlock: true,
      timeout: 3600,
      add_to_search_list: true
    ) 

    # 同步发布证书
    match(type: "appstore",
          readonly: true,
          app_identifier: "com.zm.*",
          profile_name: "*** AppStore com.zm.*",
          keychain_name: ENV['MATCH_KEYCHAIN_NAME'],
          keychain_password: ENV['MATCH_PASSWORD'],
          git_url: ENV['MATCH_GITHUB_URL'])
    
    # 更新build number
    build_num = app_store_build_number(
      app_identifier: "com.zm.ZLGitHubClient",
      live: false,
      api_key: api_key
    )
      
    increment_build_number(
      build_number: build_num + 1
    )
    
    # 构建，打包，签名
    gym(workspace: "ZLGitHubClient.xcworkspace",
        scheme: "ZLGitHubClient",
        export_method: "app-store",
        clean: true,
        include_symbols: true,
        include_bitcode: true,
        output_directory: "./fastlane/ipa/TestFlight",
        output_name: "ZLGitHubClient.ipa")
    
    # 上传 test
    pilot(
      api_key: api_key,
      app_identifier: "com.zm.ZLGitHubClient",
      changelog: "release to TestFlight",
      ipa: "./fastlane/ipa/TestFlight/ZLGitHubClient.ipa"
      )
```




  



## 参考文档

[iOS使用fastlane一键打包审核](https://note.youdao.com/ynoteshare1/index.html?id=467b57ae4e6f4f744948e531f54a42c3&type=note)

