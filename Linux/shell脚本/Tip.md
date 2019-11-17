## 空格问题
> 使用赋值运算符，左值，右值和赋值运算符之间不能有空格 

```shell

arg1=1     # it is ok
arg2 = 1   # it is not ok, 这里会将arg2作为命令来处理

```

## 算数运算必须使用expr，否则会被当做字符串拼接

```shell
result1=12+12                 # result1 值为 12+12
result2=`expr 12 + 12`        # result2 值为 24
```

## 条件判断

> 条件表达式要放在方括号之间，并且要有空格，例如: [$a==$b] 是错误的，必须写成 [ $a == $b ]。

```shell
if [ -n $result ]     # [-n $result]是错误的
then
    echo $result
else
    echo "result is nil"
fi
```