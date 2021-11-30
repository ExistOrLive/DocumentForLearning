# Homebrew

> Homebrew是一款Mac OS平台下的软件包管理工具，拥有安装、卸载、更新、查看、搜索等很多实用的功能。简单的一条指令，就可以实现包管理，而不用你关心各种依赖和文件路径的情况，十分方便快捷。

### Homebrew 安装

- 安装 Xcode 命令行工具

```shell

xcode-select --install

```
- 安装homebrew

```shell

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

```

[Homebrew介绍和使用][1]

[Mac上Homebrew的使用][2]


# Homebrew Cask

>  Homebrew Cask 是 Homebrew 的扩展，借助它可以方便地在 macOS 上安装图形界面程序，即我们常用的各类应用。

### Homebrew Cask 安装

- 首先安装 homebrew

- 安装cask

``` shell
brew tap homebrew/cask
```

[1]:https://www.jianshu.com/p/de6f1d2d37bf

[2]:https://blog.csdn.net/delphiwcdj/article/details/19679891