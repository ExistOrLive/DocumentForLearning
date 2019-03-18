# transform  变化 

> 我们可以通过对图层或者视图添加变化，使得图层旋转，移动以及变形

## 仿射变换

> 仿射变换 指定是图层中原本平行的两条线变换后依旧平行的二维变换。在`Core Graphics`中提供了仿射变换的类型`CGAffineTransform`以及API。

```

struct CGAffineTransform {
  CGFloat a, b, c, d;
  CGFloat tx, ty;
};

```

> CGAffineTransform 是一个可以和二维空间向量(CGPoint)做乘法的3*2矩阵

![仿射变换][1]

```
/* The identity transform: [ 1 0 0 1 0 0 ]. */

CG_EXTERN const CGAffineTransform CGAffineTransformIdentity
  CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

/* Return the transform [ a b c d tx ty ]. */

CG_EXTERN CGAffineTransform CGAffineTransformMake(CGFloat a, CGFloat b,
  CGFloat c, CGFloat d, CGFloat tx, CGFloat ty)
  CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

/* Return a transform which translates by `(tx, ty)':
     t' = [ 1 0 0 1 tx ty ]  移动图层*/

CG_EXTERN CGAffineTransform CGAffineTransformMakeTranslation(CGFloat tx,
  CGFloat ty) CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

/* Return a transform which scales by `(sx, sy)':
     t' = [ sx 0 0 sy 0 0 ]  拉伸图层*/

CG_EXTERN CGAffineTransform CGAffineTransformMakeScale(CGFloat sx, CGFloat sy)
  CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

/* Return a transform which rotates by `angle' radians:
     t' = [ cos(angle) sin(angle) -sin(angle) cos(angle) 0 0 ]  旋转图层 顺时针angle为正*/

CG_EXTERN CGAffineTransform CGAffineTransformMakeRotation(CGFloat angle)
  CG_AVAILABLE_STARTING(__MAC_10_0, __IPHONE_2_0);

```

> `UIView`的`transform`属性是`CGAffineTransform`类型，对应`CALayer`的`affineTransform`属性;而`CALayer`的`transform`属性是`CATransform3D`类型，是3D变换

---

## 3D变换

> CATransform3D是一个可以在3维空间里做变换的4*4的矩阵

```
struct CATransform3D
{
  CGFloat m11, m12, m13, m14;
  CGFloat m21, m22, m23, m24;
  CGFloat m31, m32, m33, m34;
  CGFloat m41, m42, m43, m44;
};

```

![3D变换][2]

> 以下是旋转，位置，拉伸等变换, 旋转需要指定转轴向量

```
/* Returns a transform that rotates by 'angle' radians about the vector
 * '(x, y, z)'. If the vector has length zero the identity transform is
 * returned. */

CA_EXTERN CATransform3D CATransform3DMakeRotation (CGFloat angle, CGFloat x,
    CGFloat y, CGFloat z)
    CA_AVAILABLE_STARTING (10.5, 2.0, 9.0, 2.0);

/* Translate 't' by '(tx, ty, tz)' and return the result:
 * t' = translate(tx, ty, tz) * t. */

CA_EXTERN CATransform3D CATransform3DTranslate (CATransform3D t, CGFloat tx,
    CGFloat ty, CGFloat tz)
    CA_AVAILABLE_STARTING (10.5, 2.0, 9.0, 2.0);

/* Scale 't' by '(sx, sy, sz)' and return the result:
 * t' = scale(sx, sy, sz) * t. */

CA_EXTERN CATransform3D CATransform3DScale (CATransform3D t, CGFloat sx,
    CGFloat sy, CGFloat sz)
    CA_AVAILABLE_STARTING (10.5, 2.0, 9.0, 2.0);
```

### Example 
```
位移矩阵
{
    1,0,0,0;
    0,1,0,0;
    0,0,1,0;
    2,3,4,1;
}
```


## 透视效果

## 灭点



[1]: pic/仿射变换.png
[2]: pic/3D变换.png




