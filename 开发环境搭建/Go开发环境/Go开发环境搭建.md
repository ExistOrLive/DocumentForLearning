# Go开发环境搭建
## 1. 安装go
Go官网下载地址：[https://golang.org/dl/](https://golang.org/dl/)
Go官方镜像站（推荐）：[https://golang.google.cn/dl/](https://golang.google.cn/dl/)

```shell
go version

## go version go1.17.3 darwin/amd64
```


## 2. 设置go env
```shell
go env
```

- GOROOT : 安装go开发包的路径
- GOPROXY:  go 模块代理,  用于下载依赖的go包
```shell
# 修改为国内的代理
go env -w GOPROXY=https://goproxy.cn,direct
```

- GOPATH :   项目代码，编译产物将放在GOPATH目录下；GOPATH目录默认为当前用户主目录的go文件夹![截屏2022-07-13 10.16.07.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1657678575874-d9abe109-2091-4eb2-b2c4-55a681ffbf71.png#clientId=u6eea168a-0184-4&crop=0&crop=0&crop=1&crop=1&from=drop&height=52&id=u8afe1169&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-07-13%2010.16.07.png&originHeight=90&originWidth=1086&originalType=binary&ratio=1&rotation=0&showTitle=false&size=40752&status=done&style=none&taskId=ub3ba1856-5ce9-4078-ab5e-a9009ee36c6&title=&width=625)

    GOPATH下一般创建三个文件夹：
        - bin：存放编译后的二进制文件
        - pkg：存放编译后的库文件 
        - src： 源码文件
	Go语言中也是通过包来组织代码文件，我们可以引用别人的包也可以发布自己的包，但是为了防止不同包的项目名冲突，我们通常使用顶级域名来作为包名的前缀，这样就不担心项目名冲突的问题了。
	因为不是每个个人开发者都拥有自己的顶级域名，所以目前流行的方式是使用个人的github用户名来区分不同的包。      
	
![截屏2022-07-13 10.26.08.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1657679178326-aec7b4be-db59-4c12-9ce8-c0609d4e1b02.png#clientId=u6eea168a-0184-4&crop=0&crop=0&crop=1&crop=1&from=drop&id=u7aea6c26&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-07-13%2010.26.08.png&originHeight=389&originWidth=1364&originalType=binary&ratio=1&rotation=0&showTitle=false&size=53020&status=done&style=none&taskId=u705735df-fbf3-4b59-822a-c9f43a6bcc4&title=)

- GOBIN： 存放二进制文件的目录，一般为 GOPATH/bin ，将GOBIN设置在PATH中之后就可以直接在命令行中运行 编译后的二进制产物

         
## 3. go命令行工具
go 提供了一套编译，运行go程序；安装管理go包；go模块管理，依赖管理的工具链
![](http://pic.existorlive.cn//202207141647072.png)

### 3. 1 go build/go run
go build 命令用于编译go源码

go run 命令用于编译go源码，执行二进制产物

### 3.2 go install
go install 用于 下载，编译，安装指定版本的go包，安装目录一般在 GOBIN

```shell
# 下载最新版本的bee包，编译后的可执行文件安装在 GOBIN 目录下
go install github.com/beego/bee@latest
```

GOBIN目录一般会配置在shell的PATH环境变量中，这样就可以在shell中执行安装的go工具

https://pkg.go.dev/ 

### 3.3 go get

go get 用于在go包中下载，更新，移除go包的依赖，go get 会修改go包的go.mod 文件

```shell
# 更新 go.mod 中 pkg 依赖版本为最新，并下载对应的依赖包到当前包的cache目录中
go get example.com/pkg

# 更新 go.mod 中 pkg 依赖版本为v1.2.3，并下载对应的依赖包到当前包的cache目录中
go get example.com/pkg@v1.2.3

# 移除 mod 依赖
go get example.com/mod@none
```

### 3.4 go mod
go mod 用于创建和维护一个go模块

```shell
# 创建一个go项目
go mod init Hello
```

生成 go.mod

![](http://pic.existorlive.cn//202207141710598.png)

```shell
# 下载依赖的包到缓存目录中
go mod download

# 下载依赖的包，移除不再依赖的包
go mod tidy

```

下载的依赖包会放置于 GOPATH/pkg 文件夹下 

[安装Go语言及搭建Go语言开发环境](https://www.liwenzhou.com/posts/Go/install_go_dev/)

[go教程](https://www.topgoer.com/)
