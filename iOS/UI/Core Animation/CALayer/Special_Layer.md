# 专用图层

## CAShapeLayer

`CAShapeLayer`是一个通过矢量图形而不是bitmap来绘制的图层子类。矢量图形不同于bitmap记录每一个像素的颜色，透明度信息；记录的是图像中线和点的几何信息。因为矢量图是根据几何特性来绘制图形，所以一般占用内存小（内存与图像复杂程度有关，而与图像大小无关），放大不会像素化和失真。

`CAShapeLayer`的优点：

- 渲染快速。`CAShapeLayer`使用了硬件加速，绘制同一图形会比用`Core Graphics`快。

- 高效使用内存。 一个`CAShapeLayer`不需要像普通`CALayer`一样创建一个寄宿图，无论有多大，都不会占用太多内存。

- 不会被图层边界裁剪掉

- 不会出现像素化。 当对`CAShapeLayer`做3D变换，它不像一个有寄宿图的普通图层一样变得像素化。

