## 1. if 语句 
`if` `then` `elif` `else` `fi` 等关键字构成基本的 if 语句
```shell
if [ condition ]
then 
    # code
elif [ condition ]
then 
    # code
else 
    # code
fi 
```
## 2. for 循环语句
`for` `in` `do` `done` 
```shell
for item in itemArray
do 

    # code
done
```
## 3. while循环


```shell
while [ condition ]
do 

    # code

done
```


**循环读取键盘信息**
**​**

```shell
while read param
do 
    echo "输入的参数为$param"
done
```


## 4. 无限循环
```shell
while :
do 

   #code
done 


while true
do 

   #code
done 


for (( ; ; ))
do
   #code
done
```


## 5. case...esac


`*`相当于 `default` 
```swift
 # 模式
case 值 in
模式1)  #code
;;
模式2)  #code 
;;
模式3｜模式4｜模式5) #code
;;
*)  #code 
;;
esac


# 例子
echo "请输入："
read param

case $param in
1) echo "第一种模式"
;;
2) echo "第二种模式"
;;
3|4|5|6) echo "第3/4/5/6种模式"
;;
*) echo "其他模式"
;;
esac
```
## 6. break/continue
