# sed 命令 

sed命令可以通过 **脚本** 编辑文本文件

```sh
sed [-hnV][-e<script>][-f<script文件>][文本文件]
```

## 1. 选项

- `-n` : sed默认会输出所有的输入文本，-n选项指定仅输出匹配并处理后的结果

- `-e` : -e 选项后跟脚本内容

- `-f` : -f 选项后跟脚本文件


## 2. 脚本

```sh
<脚本的命令>/<匹配的正则>/<替换字符串>/<脚本的命令>
```

### 2.1 脚本命令 a

**`a` 的后面可以接字串，而这些字串会指定或者匹配的行后添加新的一行**

- 通过正则匹配某一行

```sh 
#匹配包含hello的行，在该行后添加新的一行为newline
sed -e "/hello/a\\newline" testfile
```

testfile 如下
```txt
hello
hahah
world
```
执行命令后，得到如下报错：

![](https://github.com/existorlive/existorlivepic/raw/master/202203181510378.png)

> BSD/MacOS的sed命令要求 a\ 后跟一个真实的换行符

[StackOverflow](https://stackoverflow.com/questions/40843994/extra-characters-after-at-the-end-of-a-command)

因此命令修改为：
```sh
#匹配包含hello的行，在该行后添加新的一行为newline
sed -e "/hello/a\\
newline" testfile
```

![](https://github.com/existorlive/existorlivepic/raw/master/202203181513803.png)


- 指定行号

```sh 
# 第二行后插入新行
sed -e "2a\\
newline" testfile
```

### 2.2 脚本命令 d

**d 用于删除指定或匹配的行**

```sh
# 删除包含hello的行
sed -e '/hello/d' testfile 
# 删除2到3 行
sed -e '2,3d' testfile 
# 删除第二行开始的所有行
sed -e '2,$d' testfile 
```
![](https://github.com/existorlive/existorlivepic/raw/master/202203181532146.png)

![](https://github.com/existorlive/existorlivepic/raw/master/202203181533045.png)


### 2.2 脚本命令 c

**c 用于替换匹配的行**

```sh
# 替换包含hello的行
sed -e '/hello/c\
replace' testfile 
# 2到3行替换为 replace
sed -e '2,3c\
replace' testfile 
# 第二行开始的所有行 替换为 replace
sed -e '2,$c\
replace' testfile 
```

### 2.4 脚本命令 i

**`i` 的后面可以接字串，而这些字串会指定或者匹配的行之前添加新的一行**

```sh 
# 在 hello 行之前添加新行 newline
sed -e "/hello/i\\
newline" testfile

# 在第三行之前添加newline
sed -e "3i\\
newline" testfile
```

![](https://github.com/existorlive/existorlivepic/raw/master/202203181542676.png)

### 2.5 脚本命令s

**s 匹配并替换**

```sh
# 第1到3行所有的o替换为new
sed -e `1,3s/o/new/g` testfile
```

