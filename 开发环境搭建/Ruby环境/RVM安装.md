# RVM (Ruby version Manager)

> MacOS系统一般自带ruby，可执行文件路径在`/usr/bin/ruby`。但是系统自带的ruby往往无法正常升级。

> RVM用于管理和切换ruby的版本。


## 安装RVM

1.使用gpg命令安装RVM服务器的公钥

```bash
 gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

```

2. 下载并安装RVM

```bash

\curl -sSL https://get.rvm.io | bash -s stable

```

3. 设置环境变量


```bash
source /Users/[user]/.rvm/scripts/rvm
```



## 使用RVM

[Ruby Version Manager (RVM)][1]

[1]:http://rvm.io/