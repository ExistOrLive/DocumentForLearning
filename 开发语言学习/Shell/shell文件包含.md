## 和其他语言一样，Shell 也可以包含外部脚本。这样可以很方便的封装一些公用的代码作为一个独立的文件。
## 1. source/. 引入其他脚本


```shell
. filename   # 注意点号(.)和文件名中间有一空格

或

source filename
```
## 2. source filename 与 sh filename 及./filename执行脚本的区别

- 当shell脚本具有可执行权限时，用sh filename与./filename执行脚本是没有区别得。./filename是因为当前目录没有在PATH中，所有”.”是用来表示当前目录的。
- sh filename 重新建立一个子shell，在子shell中执行脚本里面的语句，该子shell继承父shell的环境变量，但子shell新建的、改变的变量不会被带回父shell。
- source filename：这个命令其实只是简单地读取脚本里面的语句依次在当前shell里面执行，没有建立新的子shell。那么脚本里面所有新建、改变变量的语句都会保存在当前shell里面。

[

](https://blog.csdn.net/violet_echo_0908/article/details/52056071)
```shell
# test1.sh
#/bin/zsh

hello=11
```
![截屏2022-01-17 15.33.15.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642404809109-10f8ea94-5e08-432f-b130-5104b92c4952.png#clientId=u11dd1342-cc5c-4&from=drop&id=ua97710fc&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-17%2015.33.15.png&originHeight=254&originWidth=1356&originalType=binary&ratio=1&size=159067&status=done&style=none&taskId=u29767955-ff87-4a4a-aed3-542ddcf0968)
