# 文件IO

## 引言
> **不带缓存的I/O（Unbuffered I/O）**:
主要有 ： open、read 、write 、lseek 、 close 五个函数
是posix.1 定义的接口

## 文件描述符
> 对于内核而言，所有的打开的文件都通过文件描述符引用，文件描述符是一个非负整数，范围是0～OPEN_MAX-1

```
// MacOS 中 进程可以打开的最多文件数为 OPEN_MAX 10240 
#include <limits.h>

#define	OPEN_MAX		10240	/* max open files per process - todo, make a config option? */

```

> 0 标准输入 STDIN_FILENO
  1 标准输出 STDOUT_FILENO
  2 标准错误 STDERR_FILENO
  
```
#define	 STDIN_FILENO	0	/* standard input file descriptor */
#define	STDOUT_FILENO	1	/* standard output file descriptor */
#define	STDERR_FILENO	2	/* standard error file descriptor */

```

## open 函数

```
#include <fcntl.h> // 文件控制头文件

int	open(const char * path , int flag , ...) __DARWIN_ALIAS_C(open);

int	openat(int fd, const char * path, int flag, ...) __DARWIN_NOCANCEL(openat) 
#endif
```
> **open函数** 第一个参数path 为文件的绝对路径
               第二个参数flag 为文件的打开选项
               第三个参数为动态可变参数，当创建文件是才会使用
              
flag ：
```
#define	O_RDONLY	0x0000		/* open for reading only */
#define	O_WRONLY	0x0001		/* open for writing only */
#define	O_RDWR		0x0002		/* open for reading and writing */
#define	O_EXEC	    // MacOS 不支持
#define O_SEARCH    // MacOS 不支持

以上五个选项，必须指定一个且只能指定一个

其他选项是可选的

#define	O_NONBLOCK	0x0004		/* no delay */
#define	O_APPEND	0x0008		/* set append mode */
#define	O_SHLOCK	0x0010		/* open with shared file lock */
#define	O_EXLOCK	0x0020		/* open with exclusive file lock */
#define	O_ASYNC		0x0040		/* signal pgrp when data ready */
#define	O_FSYNC		O_SYNC		/* source compatibility: do not use */
#define O_NOFOLLOW  0x0100      /* don't follow symlinks */
#endif /* (_POSIX_C_SOURCE && !_DARWIN_C_SOURCE) */
#define	O_CREAT		0x0200		/* create if nonexistant */
#define	O_TRUNC		0x0400		/* truncate to zero length */
#define	O_EXCL		0x0800		/* error if already exists */

... 


```

#### Tip:
- 可以用 flag O_CREAT|O_EXCL 来检查文件是否存在 ，文件存在会报错
- open函数返回的文件描述符，一定是未用的最小描述符数值

> ** openat函数 **  第一个参数：是一个文件描述符；
  有三种可能性：
  - path 为绝对路径，fd 被忽略 
  - path 为相对路径，fd指出了相对路径在文件系统中的开始地址
  - path 为相对路径，fd为AT_FDCWD，起始地址为当前工作路径(不是用户主目录)
  
```
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>

//定义flags:只写，文件不存在那么就创建，文件长度戳为0
#define FLAGS O_RDWR|O_CREAT|O_EXCL
//创建文件的权限，用户读、写、执行、组读、执行、其他用户读、执行

int main(int argc, const char * argv[])
{
    int dirFd = open("/Users/zhumeng/Desktop/", 0); // 相对路径所在目录
    
    int fd = openat(dirFd,"ApacheInstallation.txt",FLAGS);
    
    if(fd < 0)
    {
        printf("errorno:[%d][%s]",errno,strerror(errno));
        return -1;
    }
    
    char buffer[1024];
    ssize_t n = 0;
    while ((n = read(fd, buffer, 1024)) > 0)
    {
        printf("%s",buffer);
    }
    close(fd);       // 使用完，一定要关闭文件
    fd = 0;
    return 0;
}
```
## 文件名或路径名截断

> `NAME_MAX` 和 `PATH_MAX`定义了操作系统中文件名和路径名的最大长度

```
// MacOS系统
#define	NAME_MAX		  255	/* max bytes in a file name */

#define	PATH_MAX		 1024	/* max bytes in pathname */
```

> 当文件名超出最大长度，一般有两种操作：1、截断  2、 报错
这个取决于常量：`_POSIX_NO_TRUNC`

```
#include <unistd.h>
#define	_POSIX_NO_TRUNC			200112L
```



