# 仿射变换（Affine  Transform）

> iOS中有两种变形：仿射和3D，UIView只能处理仿射变形，仿射变形以矩阵运算实现旋转，缩放，剪切，平移

## 仿射变换可以看作是一次线性变化加上一次平移

```


#include <CGAffineTransform.h>

CGAffineTransform CGAffineTransformMake(CGFloat a,CGFloat b,CGFloat c,CGFloat d,CGFloat tx, CGFloat ty); 

```

使用矩阵运算将图形上任意一点（x,y）做变换




