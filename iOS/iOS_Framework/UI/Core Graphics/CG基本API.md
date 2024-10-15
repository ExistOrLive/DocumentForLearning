# Core Graphics 基本API

## 文本的绘制

> 在`<UIKit/NSStringDrawing.h>`扩展了`NSString`，提供了方法可以直接在`drawRect:`中会绘制文本

```
#import <UIKit/NSStringDrawing.h>

@interface NSString(NSStringDrawing)
- (CGSize)sizeWithAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;
- (void)drawAtPoint:(CGPoint)point withAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;
- (void)drawInRect:(CGRect)rect withAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs;
@end

......

```

### Example

![文本绘制][1]

---

## 绘制图像

> 在`<UIKit/UIImage.h>`扩展了`UIImage`,提供了方法可以在`drawRect:`中绘制图片

```
#import <UIKit/UIImage.h>

- (void)drawAtPoint:(CGPoint)point;                                                        // mode = kCGBlendModeNormal, alpha = 1.0
- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (void)drawInRect:(CGRect)rect;                                                           // mode = kCGBlendModeNormal, alpha = 1.0
- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
```
### Example

![图片绘制][2]

---

## 线条绘制

### CGContextRef

> `CGContextRef` 保存了绘制过程中的上下文环境，包括描边颜色，填充颜色，线条宽度等等,可以通过`UIGraphicsGetCurrentContext()`当前绘制的上下文

```
// 获取当前绘制上下文
CGContextRef UIGraphicsGetCurrentContext(void);

#import <CoreGraphics/CGContext.h>

/* Set the line width in the current graphics state to `width'. */

void CGContextSetLineWidth(CGContextRef cg_nullable c, CGFloat width);

/* Set the line join in the current graphics state to `join'. */

void CGContextSetLineJoin(CGContextRef cg_nullable c, CGLineJoin join);

/* Start a new subpath at point `(x, y)' in the context's path. */

void CGContextMoveToPoint(CGContextRef cg_nullable c,
    CGFloat x, CGFloat y);

/* Append a straight line segment from the current point to `(x, y)'. */

void CGContextAddLineToPoint(CGContextRef cg_nullable c,
    CGFloat x, CGFloat y);

/* 添加弧线*/
void CGContextAddArc(CGContextRef cg_nullable c, CGFloat x, CGFloat y,
    CGFloat radius, CGFloat startAngle, CGFloat endAngle, int clockwise);

/* Draw the context's path using drawing mode `mode'. */

void CGContextDrawPath(CGContextRef cg_nullable c,
    CGPathDrawingMode mode);

```
### example

![绘制线条][3] 


[1]: pic/example1.png
[2]: pic/example2.png
[3]: pic/example3.png