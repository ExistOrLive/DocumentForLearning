shell脚本在shell中执行时，可以传递0个或多个参数
​

```shell
sh script.sh param1 param2 ...
```

- ​


​

在脚本中，通过 `$n` 的方式获取脚本的参数


```shell
#!/bin/zsh

echo "Shell 传递参数实例！";
echo "执行的文件名：$0";
echo "第一个参数为：$1";
echo "第二个参数为：$2";
echo "第三个参数为：$3";
```
![截屏2022-01-13 18.17.03.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642069039157-782838b1-356e-441a-bc09-e9f3782e7803.png#clientId=uc2a163a2-2560-4&from=drop&id=u602d0c2c&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-13%2018.17.03.png&originHeight=340&originWidth=984&originalType=binary&ratio=1&size=97967&status=done&style=none&taskId=u1d6507d8-13bd-472a-8f08-c3e90808c88)




- ​`$0` : 执行的文件路径
- `$1` ~ `$n` : 脚本的参数 
- `$#` : 参数的数量
- `$$` :   脚本运行的当前进程ID号
- `$!` :  后台运行的最后一个进程的ID号
- `$-` :   显示Shell使用的当前选项
- `$?` ： 上一条命令或脚本的退出状态（0标识没有错误，其他任何值标识有错误）
```shell
# 退出返回1 错误
exit 1
# 退出返回0 没有错误
exit 0
```

- `$*` : 以一个单字符串显示所有向脚本传递的参数。
如"$*"用「"」括起来的情况、以"$1 $2 … $n"的形式输出所有参数。
- `$@` : 与$*相同，但是使用时加引号，并在引号中返回每个参数。
如"$@"用「"」括起来的情况、以"$1" "$2" … "$n" 的形式输出所有参数。
