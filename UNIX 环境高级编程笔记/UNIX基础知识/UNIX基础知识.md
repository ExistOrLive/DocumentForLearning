
# UNIX基础知识
---
## UNIX体系结构
> 严格意义上，操作系统是一种软件，它控制着计算机的硬件资源，提供程序运行环境。通常称为内核(**kernel**)

> 广义上说，操作系统包括了内核和一些其他软件，包括系统实用程序，应用程序，shell以及公用函数库。

![UNIX structure](UNIX_Structure.jpeg)

> 内核的接口被称为**系统调用(System Call)**
> **公用函数库(Library Routines)** 构建在系统调用的接口之上；
> **应用程序(Applications)** 既可以使用公共函数库，也可以使用系统调用。
> **shell** 是一种特殊的应用程序，为运行其他应用程序提供了一个接口

---

## 登陆

登录名： /etc/passwd 保存着登陆项

```
sar:x:205:105:Stephon:/home/sar:/bin/bash
登录名：加密口令：数字用户ID：数字组ID：注释字段：起始目录：shell

```

---

## 文件和目录

 1. 文件系统
    UNIX文件系统是目录和文件的一种层次结构
    一个文件包含文件名和文件属性    

    -rw-r--r--  1 zhumeng  staff   47  7 29 23:35 README.md    

 2.  文件名
 3.  路径名

**Code:** 列出所有文件的名字  
```
#include <dirent.h>         // 目录操作相关的头文件 

#include <stdio.h>
#include <string.h>
#include <errno.h>


int main(int argc, const char * argv[])
{
    DIR * dp;
    struct dirent * dirp;
    
    if((dp = opendir("/we"))== NULL)
    {
        printf("errorno:%d errorStr:%s\n",errno,strerror(errno));
    }
    else
    {
        while((dirp = readdir(dp)) != NULL)
        {
            printf("%s\n",dirp->d_name);
        }
    }
    
    if(dp)
    {
          closedir(dp);
    }
    
    return 0;
}
```

Tip：
```
#include <dirent.h>

/* 描述一个打开的目录的结构体 structure describing an open directory. */
typedef struct {
	int	__dd_fd;	/* file descriptor associated with directory */
	long	__dd_loc;	/* offset in current buffer */
	long	__dd_size;	/* amount of data returned */
	char	*__dd_buf;	/* data buffer */
	int	__dd_len;	/* size of data buffer */
	long	__dd_seek;	/* magic cookie returned */
	__unused long	__padding; /* (__dd_rewind space left for bincompat) */
	int	__dd_flags;	/* flags for readdir */
	__darwin_pthread_mutex_t __dd_lock; /* for thread locking */
	struct _telldir *__dd_td; /* telldir position recording */
} DIR;



／* 读取目录下的文件信息*／
#define __DARWIN_STRUCT_DIRENTRY { \
	__uint64_t  d_ino;      /* file number of entry */ \
	__uint64_t  d_seekoff;  /* seek offset (optional, used by servers) */ \
	__uint16_t  d_reclen;   /* length of this record */ \
	__uint16_t  d_namlen;   /* length of string in d_name */ \
	__uint8_t   d_type;     /* file type, see below */ \
	char      d_name[__DARWIN_MAXPATHLEN]; /* entry name (up to MAXPATHLEN bytes) */ \
}

#if __DARWIN_64_BIT_INO_T
struct dirent __DARWIN_STRUCT_DIRENTRY;
#endif /* __DARWIN_64_BIT_INO_T */

```

## 输入输出

**文件描述符**
 > **文件描述符（File Descriptor）**通常是一个非负整数,内核用于标识一个特定进程正在访问的文件；
 > 当内核打开或创建一个新文件是，都会返回一个文件描述符。
 > 通过文件描述符实现对文件的读写

 **标准输入输出**
 > 每当运行程序，所有的shell都会打开3个文件描述符，**标准输入（standard input）**，**标准输出（standard output）**，**标准错误（standard error）**，一般这三个文件描述符都指向终端
```
#include <uinstd.h>
#define	 STDIN_FILENO	0	/* standard input file descriptor */
#define	STDOUT_FILENO	1	/* standard output file descriptor */
#define	STDERR_FILENO	2	/* standard error file descriptor */
```

**不带缓冲的I/O**

 > `fcntl.h` `unistd.h`文件中的提供访问文件的系统调用，open、read、write、lseek以及close，这些系统调用都不带缓冲区，通过文件描述符来访问文件
```
#include <fcntl.h>
int	open(const char *, int, ...) __DARWIN_ALIAS_C(open);
```
```
#include <unistd.h>
ssize_t	 read(int, void *, size_t) __DARWIN_ALIAS_C(read);

ssize_t	 write(int __fd, const void * __buf, size_t __nbyte) __DARWIN_ALIAS_C(write);

off_t	 lseek(int, off_t, int);

int	 close(int) __DARWIN_ALIAS_C(close);
```

```
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>

//定义flags:只写，文件不存在那么就创建，文件长度戳为0
#define FLAGS O_RDWR
//创建文件的权限，用户读、写、执行、组读、执行、其他用户读、执行

int main(int argc, const char * argv[])
{
    int fd = open("/Users/zhumeng/Desktop/ApacheInstallation.txt",FLAGS);
    
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


 **标准IO**
 
> 在ISO C 中提供了另一套访问文件的方法，fopen，fread，fwrite，fclose，fseek，fgets，fputs，支持缓存区，但是仅能用于读写普通文件，不能读写设备文件和套接字

```
#include <stdio.h>
#include <string.h>
#include <errno.h>

int main(int argc, const char * argv[])
{
    FILE * file = fopen("/Users/zhumeng/Desktop/tmp.json","rt+");

    if(NULL == file)
    {
        printf("errorno:[%d][%s]",errno,strerror(errno));
        perror("/Users/zhumeng/Desktop/ApacheInstallation.txt ");
        return -1;
    }

    char  buffer[1024];
    ssize_t n = 0;
    while((n = fread(buffer,1,1024,file)) > 0)
    {
        printf("%s",buffer);
    }
    
    if(file)
    {
        fclose(file);     // 使用完一定要关闭资源
        file = NULL;
    }
    
    return 0;

}
```
 
## 程序和进程
 **程序**
 > **程序（program）** 是一个存储在磁盘上的某个目录的可执行文件。内核使用exec函数，将程序读入内存，并执行程序
 
 **进程**
 > **进程（process）** 是指程序的执行实例。UNIX系统确保每个进程都有一个唯一的数字标识符，称为**进程ID（processID）**，进程ID总是一个非负整数
 
```
#include <stdio.h>
#include <unistd.h>
int main(int argc, const char * argv[])
{
    pid_t pid = getpid();   // pid_t 一般是32位整形

    printf("the pid = %d\n",pid);
    
    return 0;
    
}
```
**进程控制**
> 进程控制主要3个函数：fork ，exec ， waitpid 
```
#include<unistd.h>

// exec函数有7种变体
int	 execl(const char * __path, const char * __arg0, ...) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
int	 execle(const char * __path, const char * __arg0, ...) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
int	 execlp(const char * __file, const char * __arg0, ...) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
int	 execv(const char * __path, char * const * __argv) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
int	 execve(const char * __file, char * const * __argv, char * const * __envp) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
int	 execvp(const char * __file, char * const * __argv) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;
int	 execvP(const char * __file, const char * __searchpath, char * const * __argv)  __WATCHOS_PROHIBITED __TVOS_PROHIBITED;

// fork新进程
pid_t	 fork(void) __WATCHOS_PROHIBITED __TVOS_PROHIBITED;

#include<wait.h>
// 进程同步
pid_t	waitpid(pid_t, int *, int) __DARWIN_ALIAS_C(waitpid);

```

```
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

int main(int argc, const char * argv[])
{
    char buf[1024];
    pid_t pid;
    int status;
    
    while(fgets(buf,1024,stdin) != NULL)  // 读取命令
    {
        if(buf[strlen(buf) - 1] == '\n')
        {
            buf[strlen(buf) - 1] = '\0';
        }  
        
        if((pid = fork()) < 0)      // fork 失败
        {
            printf("fork process error [%d] : [%s]\n",errno,strerror(errno));
        }
        else if(pid == 0)   // 子进程完全复制父进程堆栈，执行命令
        {
            execlp(buf,buf,(char *)0);
            printf("exec error [%d] : [%s]\n",errno,strerror(errno));
            printf("cound't exec %s\n",buf);
            exit(127);
        }
        
        // 父进程等待子进程执行完毕
        if((pid = waitpid(pid,&status,0)) < 0 )
        {
           printf("waitpid error [%d] : [%s]\n",errno,strerror(errno));
        }
    }
    exit(0);
}

```
 **线程和线程ID**
 > **线程（thread）** 某一时刻执行的机器指令
 
 > 一个进程内所有线程共享同一地址空间，文件描述符，栈以及进程相关的属性。因为它们能够访问同一存储区，所以各线程在访问共享数据时需要采用同步措施保证数据的一致性
 
 > 线程ID只在所属的进程中有用
 
## 出错处理
> 当UNIX系统函数出错时，通常会返回一个负值，而全局变量**errno**会被设置为具有特定信息的值。
> 为了支持多线程，每个线程都应该有自己的errno，避免影响其他线程。errno被定义为以下结构

```
#include <sys/errno.h>
extern int * __error(void);
#define errno (*__error())
```
tip:

 - 如果没有发生错误，其值不会被例程清除。因此，只有在出错后才可以检验其值
 
 - 任何函数都不会将errno设置为0
 
 > 在`sys/errno.h`定义出错的常量

```
#include<sys>

#define	EPERM		1		/* Operation not permitted */
#define	ENOENT		2		/* No such file or directory */
#define	ESRCH		3		/* No such process */
#define	EINTR		4		/* Interrupted system call */
#define	EIO		5		/* Input/output error */
#define	ENXIO		6		/* Device not configured */
#define	E2BIG		7		/* Argument list too long */
#define	ENOEXEC		8		/* Exec format error */
#define	EBADF		9		/* Bad file descriptor */
#define	ECHILD		10		/* No child processes */
#define	EDEADLK		11		/* Resource deadlock avoided */
					/* 11 was EAGAIN */
...
```

> **ISO C** 中定义了函数用于打印`errno`的描述信息
```
#include <string.h>
// 返回errno相应的描述信息
char * strerror(int errnum);

#include <stdio.h>
// 在标准输出中输出当前errno的描述信息
void perror(const char * msg)

```

### 出错恢复
> `errno.h`定义的各种错误分为两类：致命性和非致命性的
> 非致命性错误一般与资源短缺有关，通常的处理方式是延迟一段时间后，重试。

## 用户标识
### 用户ID
> /etc/passwd
### 组ID
> /etc/group
```
#include <stdio.h>
#include <unistd.h>


int main(int argc, const char * argv[])
{
    uid_t uid = getuid();
    
    gid_t gid = getgid();
}
```
### 附属组ID

## 信号（signal）

> **信号（signal）** 用于通知进程发生了某些情况。 
> 进程有以下3种处理信号的方式：

 - 忽略信号
 - 按默认方式处理即退出
 - 提供一个函数，信号发生时调用该函数，称为捕捉该信号
 
 ### 发出信号的方法
 - 键盘上的中断键（ctrl+C）和 退出键 (ctrl+\),用于终止当前运行的线程
 - kill 函数；向向一个进程发送信号时，我们必须是进程的所有者或者超级用户
 ```
 #include <sys/signal.h>
 // 处理指定的信号
 void	(*signal(int, void (*)(int)))(int);
 
 // 向某个进程发出信号
 int	kill(pid_t, int) __DARWIN_ALIAS(kill);
 ```
 
 ## 时间值
 
 > UNIX 有两种时间值：
 - **日历时间**：即UTC时间1970.1.1 00:00:00 到现在的累计秒数
 
 ```
 #include <time.h>
 typedef __darwin_time_t		time_t; 
 
 time_t time(time_t *);
 ```
 
 - **进程时间**：CPU时间，用以度量进程使用的中央处理器资源
 ```
 #include <time.h>
 typedef __darwin_clock_t        clock_t;
 
 clock_t clock(void) __DARWIN_ALIAS(clock);
 ```
## 系统函数和库函数

 
 
 
 






















  