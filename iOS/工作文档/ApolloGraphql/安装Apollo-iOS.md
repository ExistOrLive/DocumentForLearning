# Apollo-iOS

**Apollo-iOS** 是用 Swift 编写的强类型的，缓存GrapgQL iOS 客户端。

通过 **Apollo-iOS** 可以向 **GraphQL Server** 发送 **Query** 和 **Mutation** 请求，结果会以 Swift 类型返回。 

**Apollo-iOS** 可以通过 Graphql 文件自动生成处理请求和响应需要的 Swift 类型。

**Apollo-iOS** 做的不仅仅处理 **GraphQL Server** 的请求；还会将查询的结果构建为本地的缓存，缓存会随着接下来的  **Query** 和 **Mutation** 一直更新与服务端保持一致。


## 在项目中安装 Apollo-iOS

### 1. 基础环境

- Xcode 12.0

- Swift 5.3

- Apollo iOS SDK 0.34.0

### 2. 安装 Apollo-iOS Framework 

Apollo-iOS Framework 可以通过 **Swift Package**，**Cocoapods** 和 **Carthage** 安装，具体请参考[Installing the Apollo framework](https://www.apollographql.com/docs/ios/installation/)


### 3. 在 项目中添加 Scheme file

在**Scheme file**中，**GraphQL Server** 定义了 **Query** ， **Mutation** 以及 **Subscription**，会用于之后生成代码。

- 一般可以从 **GraphQL Server** 直接下载。

这里以 Github Graphql API 为例，你可以从[Github Public Schema](https://docs.github.com/en/free-pro-team@latest/graphql/overview/public-schema)下载

- 你可以使用[Apollo Cli](https://github.com/apollographql/rover)下载

```sh
apollo schema:download --endpoint=http://localhost:8080/graphql schema.json --header="Authorization: Bearer <token>"
```

### 4. 创建 .graphql 文件

**Apollo iOS** 会从 **.graphql** 文件中定义的 queries 和 mutations 自动生成代码。

#### 4.1 安装 xcode-apollo 插件支持 graphql 语法高亮

请参考[xcode-graphql](https://github.com/apollographql/xcode-graphql#installation)

#### 4.2 创建 .graphql 文件 

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-01-04%20%E4%B8%8A%E5%8D%881.29.49.png)


### 5 生成代码

**Apollo iOS** 通过 **.graphql** 文件自动生成 API 代码来处理 **queries**，**mutations** 和 **subscriptions**请求以及解析和缓存响应数据。

代码生成是Xcode构建过程的一部分，你需要在 **Build Phases** 中，在**Compile Sources**之前添加一个构建步骤执行生成代码的脚本。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-01-04%20%E4%B8%8A%E5%8D%881.38.24.png)

- 在 **Build Phases** 中，点击 **+** 按钮，选择 **New Run Script Phase**

- 修改名字为 **Generate Apollo GraphQL API**，拖拽到 **Compile Sources** 之前

- 添加脚本

以**Cocoapods**方式安装为例，**Swift Package** 和 **Carthage** 安装请参考[Adding a code generation build step](https://www.apollographql.com/docs/ios/installation/#adding-a-code-generation-build-step)

```sh

# 执行脚本 run-bundled-codegen.sh 生成代码
SCRIPT_PATH="${PODS_ROOT}/Apollo/scripts"
cd "${SRCROOT}/${TARGET_NAME}/Class/Network/Graphql"
"${SCRIPT_PATH}"/run-bundled-codegen.sh codegen:generate --target=swift --includes=./*.graphql --localSchemaFile="schema.json" "API.swift.new"
if ! diff -q "API.swift.new" "API.swift"; then
  mv "API.swift.new" "API.swift"
else
  rm "API.swift.new"
fi

```

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-01-04%20%E4%B8%8A%E5%8D%882.23.28.png)

### 6 将 API.swift 加入工程


## 参考文档

[apollographql/apollo-ios](https://github.com/apollographql/apollo-ios)