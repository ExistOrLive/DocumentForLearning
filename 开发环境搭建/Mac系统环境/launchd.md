## 1. Launchd
#launchd


**launched** 是一个统一的开源服务管理框架，用于启动，停止和管理守护程序，应用，进程和脚本。
### 1.1 守护进程


**守护程序** 是一个运行于后台不需要用户输入的程序。典型的守护进程可能会执行日常维护任务，或者在连接设备时扫描恶意软件。
​

### 1.2 Daemon 和 Agent 


**launchd** 区分了 **Daemon** 和 **Agent**，主要的区别是 **Agent** 是以登陆用户的身份运行的，而 **Daemon** 则是以 root 用户 或者 通过 `UserName` 指定的用户身份执行的  
​

### 1.3 定义任务 


**Daemon** 和 **Agent **使用plist文件定义，保存在系统的指定目录下。
在 `LaunchAgents` 文件夹下，任务为 **Agent** ； 在 `LaunchDaemons` 文件夹下，任务为 **Daemon** ； 
![截屏2022-01-27 14.57.21.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1643266679178-710f8fbf-6a10-4dad-bfca-39c327015dd9.png#clientId=ud8abcf5e-9592-4&from=drop&id=uc43e7b66&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-27%2014.57.21.png&originHeight=436&originWidth=1700&originalType=binary&ratio=1&size=150267&status=done&style=none&taskId=ufdb691a2-a9ad-4769-89ce-25717af6434)


`/System/Libarary/LaunchAgents` 和 `/System/Library/LaunchDaemons` 两个目录，用于保存操作系统的任务，不应该将自定义的任务plist放在这些目录下。
​

如果任务需要用于所有的用户，将任务plist放在`/Library/LaunchAgents` 和 `/Library/LaunchDaemons` 两个目录下
​

如果任务仅用于某个用户，则将任务plist放在该用户的`~/Libarary/LaunchAgents`目录下 
### 1.4 任务plist的一些关键字段
plist文件使用 XML 语法，有几个字段需要关注：
​


- **Label** ： 任务的唯一id，不同的任务的id必须不一样
- **Program** ： 任务执行的程序 
- **RunAtLoad** ：是否在加载时执行
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.example.app</string>
		<key>Program</key>
		<string>/Users/Me/Scripts/cleanup.sh</string>
		<key>RunAtLoad</key>
		<true/>
	</dict>
</plist>

```
​

### 1.5 自动加载任务


任务的plist文件放在指定的目录下后，会在特定的时机自动加载。


当系统启动 root launchd 程序时，会扫描 `/System/Library/LaunchDaemons` 和 `/Library/LaunchDaemons` 文件夹，并加载其中的任务定义。(如果配置文件中 `Disabled` 字段为 true，任务将不被加载)
​

当某个用户登陆后，该用户会启动一个新的 launchd 程序。这个 launchd 程序会扫描 `/System/Library/LaunchAgents`, `/Library/LaunchAgents` 和 `~/Library/LaunchAgents` ，，并加载其中的任务定义。(如果配置文件中 `Disabled` 字段为 true，任务将不被加载)
### 1.6 任务的加载和启动


加载任务并不一定代表该任务被启动。 任务具体的启动时机由配置文件定义，只有当 `RunAtLoad` 或者 `KeepAlive` 被指定时，任务才会在加载后启动。


## 2. launchctl
​

`launchctl` 是用于管理 **launchd** 的工具。
```shell
## 已经加载 job

launchctl list

## 加载新的job

launchctl load ~/Library/LaunchAgents/com.example.app.plist

# 一般加上 -w 选项
launchctl load -w ~/Library/LaunchAgents/com.example.app.plist


## 取消加载 

launchctl load ~/Library/LaunchAgents/com.example.app.plist

# 一般加上 -w 选项
launchctl load -w ~/Library/LaunchAgents/com.example.app.plist

## 启动任务 

launchctl start com.example.app

## 停止任务 

launchctl stop com.example.app
```


## 3. plist配置文件
​

Launchd 任务的配置文件是一个纯文本的plist文件，以xml语言编写，支持超过36个关键key。 
[LaunchControl](https://www.soma-zone.com/LaunchControl/) 是一个编写 launchd 任务配置文件 和 查看launchd 任务的工具
​

![截屏2022-01-27 18.18.27.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1643278720805-1a07cb95-4797-4adc-801d-d1c903fedfee.png#clientId=ud8abcf5e-9592-4&from=drop&id=u7e6f25ca&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-27%2018.18.27.png&originHeight=1468&originWidth=2518&originalType=binary&ratio=1&size=722276&status=done&style=none&taskId=ud0d314b6-c81f-4f77-9525-9fc7df263e0)
​

### 3.1 Label


**Label** 是任务的名字，也是任务的唯一标识 
​

### 3.2  Program/ProgramArguments


`Program` 是任务执行的程序； `ProgramArguments` 是程序的参数和选项






```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    
    <!-- 任务名 -->
    <key>Label</key>
    <string>com.zm.swiftlintjob</string>
    
    <!-- 是否加载时运行 -->
    <key>RunAtLoad</key>
    <false/>
    <key>KeepAlive</key>
    <false/>

    <!-- 运行的脚本或命令 -->
    <key>ProgramArguments</key>
    <array>
        <string>/bin/zsh</string>
        <string>/Users/admin/Documents/SwiftLint定时任务/script/main.sh</string>
    </array>

    <!-- 命令执行的工作目录 -->
    <key>WorkingDirectory</key>
    <string>/Users/admin/Documents/SwiftLint定时任务</string>

    <!-- 定时执行 -->
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>11</integer>
        <key>Minute</key>
        <string>30</string>
    </dict>
       
    <!-- 定时执行 时间间隔 -->
    <!-- 
    <key>StartInterval</key>
    <integer>3600</integer> 
    -->

     <!-- 标准输入文件 -->
    <key>StandardInPath</key>
    <string>/Users/admin/Documents/SwiftLint定时任务/log/job.log</string>

    <!-- 标准输出文件 -->
    <key>StandardOutPath</key>
      <string>/Users/admin/Documents/SwiftLint定时任务/log/job.log</string>

    <!-- 标准错误输出文件 -->
    <key>StandardErrorPath</key>
      <string>/Users/admin/Documents/SwiftLint定时任务/log/job.log</string>

  </dict>
</plist>

```


## 参考文档


[Mac服务管理 – launchd、launchctl、LaunchAgent、LaunchDaemon、brew services详解](https://www.xiebruce.top/983.html)

[Mac执行定时任务之launchctl](https://www.jianshu.com/p/b65c1d339eec)

[LaunchdInfo](https://www.launchd.info/)

[Apple Document](https://developer.apple.com/library/archive/technotes/tn2083/_index.html#//apple_ref/doc/uid/DTS10003794-CH1-SUBSECTION20)​
