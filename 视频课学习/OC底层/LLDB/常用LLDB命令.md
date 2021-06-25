# LLDB命令

## po/p

po 打印一个对象

p 打印值

p/t 以二进制输出

p/x 以16进制输出

## register read/write

`register read` 读取寄存器

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-19%20%E4%B8%8A%E5%8D%8810.22.42.png)

`register write` 修改寄存器

## x 

x 查看某个对象内存, 默认查看4个字节，每个字节按照16进制输出逐个输出。（注意MacOS/iOS都是小端字节序）

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-19%20%E4%B8%8A%E5%8D%8810.27.41.png)

x/4xg  每8个字节输出一次，输出4次

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-19%20%E4%B8%8A%E5%8D%8810.34.12.png)

x/4w  每4个字节输出一次，输出4次

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-19%20%E4%B8%8A%E5%8D%8810.39.53.png)

x/4c x/4cg

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-19%20%E4%B8%8A%E5%8D%8810.41.02.png)

## image 

访问目标模块的信息

image list ： 列出当前可执行文件的依赖的模块镜像

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-04-23%20%E4%B8%8B%E5%8D%884.22.29.png)


## bt 打印堆栈信息



## watchpoint 



