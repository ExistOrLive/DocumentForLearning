## 1. echo


`echo` 输出变量，并自动换行
## 2. printf
格式化输出`printf  format-string  [arguments...]`
​

```shell
 
printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876

:<<'
姓名     性别   体重kg
郭靖     男      66.12
杨过     男      48.65
郭芙     女      47.99
'
```


## 3. read
```shell
# 从标准输入读取，赋值给name
read name 
```
