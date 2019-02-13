# 自定义视图绘制 （custom drawing）

## iOS的绘图系统 

> iOS主要的绘图系统有 `UIKit`，`Core Graphics（Quartz）`，`Core Animation`， `Core Image`，`OpenGL ES`
 
 - UIKit 是最高级的界面，是OC中唯一的界面，可以轻松的访问布局，组成，绘图，字体，图片，动画等，以UI作为前缀。
 - Core Graphics 是UIKit下的主要绘图系统，频繁用于绘制***自定义视图***，与UIKit高度集成，以CG作为前缀。
 - Core Animation 动画服务
 - Core Image 提供了图片处理的方法，如切图，锐化，扭曲以及变形
 - OpenGL ES 用于编写游戏
 
## 视图的绘制周期

- 在runloop的一次事件中，修改的视图会调用相应的setNeedDisplay方法设置为需要重新绘制，于是会在下一次的绘制周期中绘制。
- 绘制周期在主线程中运行，因此不可以在主线程中进行复杂的耗时操作，会阻塞绘制周期
- 不能够主线程之外的主视图上下文中绘制

## 视图绘制和视图布局
仅仅是视图移动，显示，隐藏，旋转，甚至变形和合并，调用`setNeedLayout`而不是`setNeedDisplay`，因为布局的变化比视图绘制成本更低

## 自定义视图绘制 

**tip**: 视图可以通过**子视图**，**图层**，**实现DrawRect:**来表现内容，但是实现了`drawRect:`，就最好不要混用图层和子视图。

**2D绘图一般可以拆分成一下几个操作**

- 线条
- 路径（填充或轮廓形状）
- 文本
- 图片
- 渐变

### 通过UIKit绘图
> 大部分自定义视图只能使用Core Graphics绘制，UIKit 不能绘制任意形状

```
- (void)drawRect:(CGRect)rect
{
[[UIColor redColor] setFill];        // 设置填充颜色
[[UIColor greenColor] setStroke];    // 设置描边颜色

UIRectFill(rect);                // 填充矩形
UIRectFrame(rect);               // 给矩形描边
}


// 在UIGraphics.h 提供了简单方法绘制视图
#include "UIGraphics.h"

UIKIT_EXTERN void UIRectFillUsingBlendMode(CGRect rect, CGBlendMode blendMode);
UIKIT_EXTERN void UIRectFill(CGRect rect);   // 填充矩形区域

UIKIT_EXTERN void UIRectFrameUsingBlendMode(CGRect rect, CGBlendMode blendMode);
UIKIT_EXTERN void UIRectFrame(CGRect rect);   // 给矩形区域描边

UIKIT_EXTERN void UIRectClip(CGRect rect);

```

> 系统会提供一个**图形上下文（Graphics Context）**，这个上下文保存了包括画笔颜色，填充颜色，文本颜色，字体，形状等大量信息。可以通过`UIGraphicsGetCurrentContext()`获取

```
#include "UIGraphics.h"

UIKIT_EXTERN CGContextRef __nullable UIGraphicsGetCurrentContext(void) CF_RETURNS_NOT_RETAINED;
UIKIT_EXTERN void UIGraphicsPushContext(CGContextRef context);
UIKIT_EXTERN void UIGraphicsPopContext(void);
```

## 路径 （UIBezierPath）
> UIBezierPath(贝塞尔曲线) 可以绘制任何曲线和线条
> 并且提供了方法绘制常用的线条，弧线，矩形，圆角矩形，圆，椭圆等

```
#include "UIBezierPath"

- (void)drawRect:(CGRect)rect
{
CGSize size = self.bounds.size;
CGFloat margin  = 10;
CGFloat radius = rintf(MIN(size.height - margin, size.width - margin) / 4);

CGFloat xOffset,yOffSet;

/**
* 使用rintf(四舍五入)可以确保点对其，即像素对齐，可以改善性能并避免边缘模糊
**/
CGFloat tmpOffset = rintf((size.height - size.width) / 2);

if(tmpOffset > 0)
{
xOffset = rintf(margin / 2);
yOffSet = tmpOffset;
}
else
{
xOffset = -tmpOffset;
yOffSet = rintf(margin / 2);
}

[[UIColor redColor] setFill];       // 设置填充颜色
[[UIColor greenColor] setStroke];   // 设置描边颜色

// 绘制路径
UIBezierPath * path = [UIBezierPath bezierPath];

[path addArcWithCenter:CGPointMake(xOffset + radius, yOffSet + 2 * radius)
radius:radius
startAngle: M_PI_2
endAngle: - M_PI_2
clockwise:YES];

[path addArcWithCenter:CGPointMake(xOffset + 2 * radius, yOffSet +  radius)
radius:radius
startAngle: - M_PI
endAngle: 0
clockwise:YES];

[path addArcWithCenter:CGPointMake(xOffset + 3 * radius, yOffSet + 2 * radius)
radius:radius
startAngle:  - M_PI_2
endAngle:  M_PI_2
clockwise:YES];

[path addArcWithCenter:CGPointMake(xOffset + 2 * radius, yOffSet + 3 * radius)
radius:radius
startAngle:0
endAngle:- M_PI
clockwise:YES];

[path closePath];   // 将当前point与起始point连接在一起

[path fill];     // 填充颜色
[path stroke];   // 描边

}

```
