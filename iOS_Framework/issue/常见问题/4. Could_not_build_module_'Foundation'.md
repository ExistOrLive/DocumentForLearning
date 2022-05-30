# iOS Could not build module 'Foundation'

当添加.c 文件时，会出现这种错误。原因是 .pch 文件中import了oc的.h 头文件
而.c 文件无法识别oc的文件。因此会报错。


在.pch文件中添加如下 : `#ifdef __OBJC__  #endif`

```objc
#ifdef __OBJC__
#import "Masonry.h"
#endif

```