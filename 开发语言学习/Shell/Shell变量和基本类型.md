## 1. 变量


### 1.1 定义变量
```shell
your_name="Tony"
```
**Tip**: 定义的变量，赋值运算符和值之间不能有空格
​

**变量名命名规则**

- 命名只能使用英文字母，数字和下划线，首个字符不能以数字开头。
- 中间不能有空格，可以使用下划线 **_**。
- 不能使用标点符号。
- 不能使用sh里的关键字（可用help命令查看保留关键字）



### 1.2 使用变量


变量在使用时，需要在变量名之前加上 `$`
```shell
echo  $your_name
echo  ${your_name}
```
### 
#### 只读变量
关键字`readonly` 可以将变量设置为只读
```shell
readonly your_name 

# 报错  your_name: readonly variable
your_name="Stack"
```
![截屏2022-01-12 18.39.46.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1641984005951-bd23dd22-b086-4fe3-90bc-77eb7349cdcc.png#clientId=u14b73753-ecbd-4&from=drop&id=u585aa6bc&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-12%2018.39.46.png&originHeight=210&originWidth=908&originalType=binary&ratio=1&size=21015&status=done&style=none&taskId=uf2214fcd-01aa-49bd-b2c6-79805c71db7)
#### 删除变量


```shell
# 删除变量
unset your_name

echo $your_name
```
### 
### 1.3 变量类型


运行shell时，会同时存在三种变量：

- **1) 局部变量** 局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。
- **2) 环境变量** 所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。
```shell
# env 命令可以打印当前shell的所有环境变量
env 

# 常用环境变量
PATH    # 命令的搜索路径
SHELL   # 当前使用的shell

```
​


- **3) shell变量** shell变量是由shell程序设置的特殊变量。shell变量中有一部分是环境变量，有一部分是局部变量，这些变量保证了shell的正常运行

​

​

## 2. 字符串


shell脚本中的字符串可以用单引号，可以用双引号，也可以不用引号。
​


- 单引号： 单引号之间的字符串都会原样输出，不会发生转义，不能插入变量
- 双引号： 双引号里可以有变量，可以出现转义字符
```shell
a=11
b='1231\"abc$a'

echo $b          # 1231\"abc$a  原样输出

b="1231\"abc$a" 

echo $b          # 1231"abc11   转义和字符

```
![截屏2022-01-12 19.56.33.png](https://cdn.nlark.com/yuque/0/2022/png/22724999/1641988600098-4527b91f-86ba-43f8-8c7d-933186778ac5.png#clientId=u14b73753-ecbd-4&from=drop&id=u56f2156f&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2022-01-12%2019.56.33.png&originHeight=388&originWidth=986&originalType=binary&ratio=1&size=168632&status=done&style=none&taskId=ucafda472-2aff-4e0e-b53f-20fce300daa)


### 拼接字符串


shell中的字符串可以不用任何运算符直接拼接在一起
```shell
your_name="runoob"
# 使用双引号拼接
greeting="hello, "$your_name" !"
greeting_1="hello, ${your_name} !"
echo $greeting  $greeting_1        # hello, runoob ! hello, runoob !

# 使用单引号拼接
greeting_2='hello, '$your_name' !'
greeting_3='hello, ${your_name} !'
echo $greeting_2  $greeting_3      # hello, runoob ! hello, ${your_name} !
```
### 
### 获取字符串长度


```shell
string="abcd"
echo ${#string} #输出 4
```
### 
### 获取字串


```shell
# 从第二个位置截取4个字符
string="runoob is a great site"
echo ${string:1:4} # 输出 unoo
```


## 3. 数组


shell仅支持一维数组，不支持多维数组。 数组通过 **圆括号** 和 **空格** 定义
数组的定义没有类型的限制，不同类型的元素可以定义在同一个数组中
```shell
array=(1 2 3 4 5 6)

array1=(
1
2
3
4)

array2=(1 2 3 "Hello" "world" 15 "15")
```
### 
### 3.1 访问元素


使用下标法访问元素，左边从 1 开始，右边从 -1 开始；
​

```shell
echo ${array[1]}      # 1

echo ${array[-1]}     # 6

echo ${array[100]}    # 越界访问不会报错

echo ${#array}        #  6  获取数组的长度

echo ${array[@]}      # 1 2 3 4 5 6 输出所有元素
```
 
