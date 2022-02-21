## 1. 安装及使用


### 1.1 安装


- homebrew

     -   不侵入原工程
     -   安装方便
     -   不便于版本控制
​

```shell
# 安装当前最新版本的swiftlint
brew install swiftlint
```
​


- cocoapods

     
     - 通过 podfile.lock 可以控制版本
     - 修改podfile， 侵入原工程


```shell
# podfile

pod 'swiftlint'

# 执行命令
pod install 
```


```shell
# path 检查的路径
# reporter 输出报告的格式 xcode, json, csv, checkstyle, codeclimate, junit, html, emoji, sonarqube, markdown, github-actions-logging
swiftlint lint --path <path> --reporter <reporter> 
```
​

[GitHub-SwiftLint](https://github.com/realm/SwiftLint)
​

## 2. 配置文件 .swiftlint.yml


- `disabled_rules`: 关闭某些默认开启的规则。
- `opt_in_rules`: 一些规则是可选的。
- `only_rules`: 不可以和 `disabled_rules` 或者 `opt_in_rules` 并列。类似一个白名单，只有在这个列表中的规则才是开启的。



```yaml
disabled_rules: # 执行时排除掉的规则
  - colon
  - comma
  - control_statement
opt_in_rules: # 一些规则仅仅是可选的
  - empty_count
  - missing_docs
  # 可以通过执行如下指令来查找所有可用的规则:
  # swiftlint rules
included: # 执行 linting 时包含的路径。如果出现这个 `--path` 会被忽略。
  - Source
excluded: # 执行 linting 时忽略的路径。 优先级比 `included` 更高。
  - Carthage
  - Pods
  - Source/ExcludedFolder
  - Source/ExcludedFile.swift

# 可配置的规则可以通过这个配置文件来自定义
# 二进制规则可以设置他们的严格程度
force_cast: warning # 隐式
force_try:
  severity: warning # 显式
# 同时有警告和错误等级的规则，可以只设置它的警告等级
# 隐式
line_length: 110
# 可以通过一个数组同时进行隐式设置
type_body_length:
  - 300 # warning
  - 400 # error
# 或者也可以同时进行显式设置
file_length:
  warning: 500
  error: 1200
# 命名规则可以设置最小长度和最大程度的警告/错误
# 此外它们也可以设置排除在外的名字
type_name:
  min_length: 4 # 只是警告
  max_length: # 警告和错误
    warning: 40
    error: 50
  excluded: iPhone # 排除某个名字
identifier_name:
  min_length: # 只有最小长度
    error: 4 # 只有错误
  excluded: # 排除某些名字
    - id
    - URL
    - GlobalAPIKey
reporter: "xcode" # 报告类型 (xcode, json, csv, checkstyle, codeclimate, junit, html, emoji, sonarqube, markdown, github-actions-logging)
```


## 3. 集成方式


![截屏2022-01-14 17.16.45.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642151820546-636a7fc8-0c22-4497-993b-5b2c8b6487f5.png#clientId=u0978084c-3fd9-4&from=drop&id=u01a52711&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-14%2017.16.45.png&originHeight=492&originWidth=1922&originalType=binary&ratio=1&size=316887&status=done&style=none&taskId=ue43cd458-186c-4392-8524-3400bb78cf1)


### 3.1 集成至Xcode中


在build phrases中创建 run script中，执行 swiftlint 
​


- 每次编译时执行
- 直接在代码出显示warning或error
- 一般开发直接忽略warning ！
```shell
# Type a script or drag a script file from your workspace to insert its path.
echo "开始检查swiftlint安装"
if ! [ -e `which swiftlint` ] 
then 
    echo "swiftlint未安装，开始安装swiftlint"
    brew intall swiftlint
fi 

changeFilesArray=(`git diff --name-only head | grep '.swift$'`)

echo "一共修改了${#changeFilesArray[*]}文件"
echo ${changeFilesArray[*]}

swiftlint lint --path ${changeFilesArray[*]}

```
![截屏2022-01-14 16.37.32.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642149466291-6c7d4487-caa5-4b2c-90eb-f05ecdd166f2.png#clientId=u0978084c-3fd9-4&from=drop&id=ue0c7b0d0&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-14%2016.37.32.png&originHeight=771&originWidth=1364&originalType=binary&ratio=1&size=124768&status=done&style=none&taskId=ub367e967-2b2a-4005-8453-efae5b3bd1f)


### 3.2 githook在pre-commit 


[Git官方文档-githooks](https://git-scm.com/docs/githooks)
​

[pre-commi(A framework for managing and maintaining multi-language pre-commit hooks)](https://pre-commit.com/)​








## 4. 参考文档


1. [GitHub-SwiftLint](https://github.com/realm/SwiftLint)
1. [Continuous code inspection with SwiftLint for iOS Apps](https://blogs.halodoc.io/continuous-code-inspection-ios/)
1. [Git官方文档-githooks](https://git-scm.com/docs/githooks)
1. [pre-commi(A framework for managing and maintaining multi-language pre-commit hooks)](https://pre-commit.com/)
1. [聊聊SwiftLint在团队的实践](https://www.jianshu.com/p/5aef8fc7e37b)​
