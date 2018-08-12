
## UNIX基础知识
---
#### UNIX体系结构
> 严格意义上，操作系统是一种软件，它控制着计算机的硬件资源，提供程序运行环境。通常称为内核(**kernel**)

> 广义上说，操作系统包括了内核和一些其他软件，包括系统实用程序，应用程序，shell以及公用函数库。

![UNIX structure](UNIX_Structure.jpeg)

> 内核的接口被称为**系统调用(System Call)**
> **公用函数库(Library Routines)** 构建在系统调用的接口之上；
> **应用程序(Applications)** 既可以使用公共函数库，也可以使用系统调用。
> **shell** 是一种特殊的应用程序，为运行其他应用程序提供了一个接口

---

#### 登陆

登录名： /etc/passwd 保存着登陆项

```
sar:x:205:105:Stephon:/home/sar:/bin/bash
登录名：加密口令：数字用户ID：数字组ID：注释字段：起始目录：shell

```

---

#### 文件和目录

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

 






















  