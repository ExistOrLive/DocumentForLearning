## iOS Crash 处理

### 1、闪退日志获取

### 2、闪退日志分析

闪退日志样例：[MOA_UCS  2018-7-31 下午7-09.crash](MOA_UCS.crash)

##### crash log header
```
// 记录了应用闪退的上下文环境 设备id,应用等信息
Incident Identifier: 9AEDC563-FD6E-4E46-BE32-30275C55E5B1
CrashReporter Key:   e7f86f9ce6c15762b90c6199465db77ca90d8ee4
Hardware Model:      iPhone9,2
Process:             MOA_UCS [6605]
Path:                /private/var/containers/Bundle/Application/5E9C1672-E5ED-452D-B792-DB4EBA97F2AA/MOA_UCS.app/MOA_UCS
Identifier:          com.zte.test.km.moa
Version:             4.7.1 (4.7.1)
Code Type:           ARM-64 (Native)
Role:                Foreground
Parent Process:      launchd [1]
Coalition:           com.zte.test.km.moa [2800]


Date/Time:           2018-07-31 19:09:54.8117 +0800
Launch Time:         2018-07-31 19:09:31.5804 +0800
OS Version:          iPhone OS 11.1 (15B93)
Baseband Version:    3.21.01
Report Version:      104
```
##### crash reason

```
Exception Type:  EXC_BAD_ACCESS (SIGSEGV)
Exception Subtype: KERN_INVALID_ADDRESS at 0x0000000000000000
VM Region Info: 0 is not in any region.  Bytes before following region: 4305518592
      REGION TYPE                      START - END             [ VSIZE] PRT/MAX SHRMOD  REGION DETAIL
      UNUSED SPACE AT START
--->  
      __TEXT                 0000000100a10000-0000000102dec000 [ 35.9M] r-x/r-x SM=COW  ...S.app/MOA_UCS

Termination Signal: Segmentation fault: 11
Termination Reason: Namespace SIGNAL, Code 0xb
Terminating Process: exc handler [0]
Triggered by Thread:  9

```

 - Exception Type 异常类型
   可以在`<mach/exception_types.h>`中找到异常的描述
   `#define EXC_BAD_ACCESS		1	/* Could not access memory */`
   SIGSEGV 信号中断类型，可以在`<sys/signal.h>`找到描述
   `#define	SIGSEGV	11	/* segmentation violation */`
 
 - Termination Reason :
    提供更详细的信息
 - 
   
##### Thread 线程 和 堆栈

```
Thread 0 name:  Dispatch queue: com.apple.main-thread
Thread 0:
0   libsystem_kernel.dylib        	0x0000000183fae670 0x183fac000 + 9840
1   MOA_UCS                       	0x0000000102251b88 0x100a10000 + 25435016
2   MOA_UCS                       	0x0000000102251ac0 0x100a10000 + 25434816
3   MOA_UCS                       	0x0000000102250008 0x100a10000 + 25427976
4   MOA_UCS                       	0x00000001022401e0 0x100a10000 + 25362912
5   MOA_UCS                       	0x000000010225d69c 0x100a10000 + 25482908
6   MOA_UCS                       	0x000000010225d0ec 0x100a10000 + 25481452
7   MOA_UCS                       	0x000000010225ccc8 0x100a10000 + 25480392
8   MOA_UCS                       	0x0000000102236c1c 0x100a10000 + 25324572
9   MOA_UCS                       	0x0000000102280be0 0x100a10000 + 25627616
10  MOA_UCS                       	0x0000000102279b18 0x100a10000 + 25598744
11  MOA_UCS                       	0x0000000102273820 0x100a10000 + 25573408
```
> 但是其中的堆栈信息都是16进制的地址，需要转换为相应的类和方法，即符号化（symboliate）




[参考文档1 **深入理解iOS Crash Log**][1]


  [1]: https://blog.csdn.net/Hello_Hwc/article/details/80946318