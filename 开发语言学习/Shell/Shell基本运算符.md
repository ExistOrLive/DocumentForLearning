## 1. 算数运算符


原生的shell不支持简单的数学运算，需要通过其他命令来实现。如`awk` 和 `expr` 


```shell
val=`expr 2 + 2`
echo "两数之和为 : $val"
```

- 表达式和运算符之间要有空格，例如 2+2 是不对的，必须写成 2 + 2，这与我们熟悉的大多数编程语言不一样。
- 完整的表达式要被 **` `** 包含，注意这个字符不是常用的单引号，在 Esc 键下边。

![截屏2022-01-13 20.14.56.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642076204396-dec7d478-0baa-4f52-a556-9a7996dcc28e.png#clientId=u1a8f8726-6fd6-4&from=drop&id=u53d2a40f&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-13%2020.14.56.png&originHeight=726&originWidth=1284&originalType=binary&ratio=1&size=121598&status=done&style=none&taskId=u551e4468-8646-4eb2-9010-643c6235b0f)

- 乘号(*) 是shell中的关键字， 前边必须加反斜杠(\)才能实现乘法运算
- `[ ]` 用于bool判断

​

## 2. 数值关系运算符
关系运算符只支持数字，不支持字符串，除非字符串的值是数字
​

![截屏2022-01-13 20.30.11.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642077034657-5f09c3dc-60ac-4022-b392-1b45494e2610.png#clientId=u1a8f8726-6fd6-4&from=drop&id=u6b0ddf58&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-13%2020.30.11.png&originHeight=550&originWidth=1272&originalType=binary&ratio=1&size=124246&status=done&style=none&taskId=u04e9240c-a338-4be0-9cb7-e248e75c076)


```shell
a=1
b=2

if [ $a -eq $b ]
then 
     echo true
else
     echo false 
fi 
```


## 3. Bool运算符


![截屏2022-01-13 20.44.51.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642077920415-2cdc676d-c4ad-4f1b-b043-8cca64efa864.png#clientId=u1a8f8726-6fd6-4&from=drop&id=u534da862&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-13%2020.44.51.png&originHeight=306&originWidth=1272&originalType=binary&ratio=1&size=67006&status=done&style=none&taskId=uc5212d65-94f2-4cf4-b3d3-77e6966f92a)






```shell
a=10
b=20

if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a == $b: a 等于 b"
fi
if [ $a -lt 100 -a $b -gt 15 ]
then
   echo "$a 小于 100 且 $b 大于 15 : 返回 true"
else
   echo "$a 小于 100 且 $b 大于 15 : 返回 false"
fi
if [ $a -lt 100 -o $b -gt 100 ]
then
   echo "$a 小于 100 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 100 或 $b 大于 100 : 返回 false"
fi
if [ $a -lt 5 -o $b -gt 100 ]
then
   echo "$a 小于 5 或 $b 大于 100 : 返回 true"
else
   echo "$a 小于 5 或 $b 大于 100 : 返回 false"
fi


if ! [ a -eq 10 ]
then 
    echo true 
else 
    echo false
fi
```


## 4. 字符串运算符
![截屏2022-01-13 21.12.29.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642079562231-f9623401-4223-403e-bb12-2c487ac95617.png#clientId=u1a8f8726-6fd6-4&from=drop&id=uab73315d&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-13%2021.12.29.png&originHeight=468&originWidth=1272&originalType=binary&ratio=1&size=96510&status=done&style=none&taskId=u0d0eb9fa-1a15-4a84-a38a-a2fa03d96c5)


```shell
a="abc"
b="efg"

if [ $a = $b ]
then
   echo "$a = $b : a 等于 b"
else
   echo "$a = $b: a 不等于 b"
fi
if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a != $b: a 等于 b"
fi
if [ -z $a ]
then
   echo "-z $a : 字符串长度为 0"
else
   echo "-z $a : 字符串长度不为 0"
fi
if [ -n "$a" ]
then
   echo "-n $a : 字符串长度不为 0"
else
   echo "-n $a : 字符串长度为 0"
fi
if [ $a ]
then
   echo "$a : 字符串不为空"
else
   echo "$a : 字符串为空"
fi
```
## 5. 文件运算符


![截屏2022-01-13 21.16.26.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1642079818013-3419affa-618f-4274-bf40-534104ad2660.png#clientId=u1a8f8726-6fd6-4&from=drop&id=uc5c0d6ec&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-13%2021.16.26.png&originHeight=1134&originWidth=1682&originalType=binary&ratio=1&size=275577&status=done&style=none&taskId=ucf8b0ec5-90cc-4f35-a163-286d5a56c76)


```shell
file="/var/www/runoob/test.sh"
if [ -r $file ]
then
   echo "文件可读"
else
   echo "文件不可读"
fi
if [ -w $file ]
then
   echo "文件可写"
else
   echo "文件不可写"
fi
if [ -x $file ]
then
   echo "文件可执行"
else
   echo "文件不可执行"
fi
if [ -f $file ]
then
   echo "文件为普通文件"
else
   echo "文件为特殊文件"
fi
if [ -d $file ]
then
   echo "文件是个目录"
else
   echo "文件不是个目录"
fi
if [ -s $file ]
then
   echo "文件不为空"
else
   echo "文件为空"
fi
if [ -e $file ]
then
   echo "文件存在"
else
   echo "文件不存在"
fi
```
