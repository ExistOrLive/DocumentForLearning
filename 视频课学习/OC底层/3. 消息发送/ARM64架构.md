# ARM64架构CPU的寄存器和常用指令集

`ARM` 是 使用精简指令集的CPU架构。相对于 `x86` 的复杂指令集架构，在效率和功耗方面有着优势。因此绝大部分移动和嵌入式设备都是使用`ARM`机构的CPU。

在现在的主流机型`iphone`都是使用`ARM64`架构的CPU，即64位的 ARM CPU。 在近期发布的 MAC 机器，也开始使用 ARM CPU。

## ARM64的寄存器

ARM64处理器共有 33 个寄存器，包括通用寄存器 `X0`～`X30`, `SP(x31)` 和 `PC`. 其中`W0`~`W31`分别是`X0`~`X31`的低32位.


![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-05-07%20%E4%B8%8B%E5%8D%887.01.20.png)


- X0~X7：用于传递子程序参数和结果，使用时不需要保存，多余参数采用堆栈传递，64位返回结果采用X0表示，128位返回结果采用X1:X0表示。
- X8：用于保存子程序返回地址， 尽量不要使用 。
- X9~X15：临时寄存器，使用时不需要保存。
- X16~X17：子程序内部调用寄存器，使用时不需要保存，尽量不要使用。
- X18：平台寄存器，它的使用与平台相关，尽量不要使用。
- X19~X28：临时寄存器，使用时必须保存。
- X29：帧指针寄存器，用于连接栈帧，使用时需要保存。
- X30：链接寄存器LR
- X31：堆栈指针寄存器SP或零寄存器ZXR

## ARM64常用指令集

### 1. 加载/存储指令 ldr/str  ldp/stp

```armasm
// 将数据加载到 Xd
ldr Xd, #immediate
ldr Xd, literal
ldr Xd, Rs

// 将Xd中的数据保存到内存中
str Xd, #immediate
str Xd, Xs

ldr xd, [Xs, #offset]
// 此汇编指令的含义为：讲Xs寄存器的值加上offset之后的值作为内存地址，讲该内存地址的数据取出，放入寄存器Xd中。

```

## 2. 比较指令 cmp


## 3. 跳转指令

```asm
// 跳转到LGetIsaDone 
b	LGetIsaDone

// p9 != p1 , 跳转到 3
cmp	p9, p1			
b.ne	3f

// 
cmp	p13, p10			// } while (bucket >= buckets)
b.hs	1b
```


