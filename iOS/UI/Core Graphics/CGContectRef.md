# CGContectRef

> CGContectRef 代表视图绘制的上下文，存储了一次图层绘制的信息（颜色，字体，文字大小，路径等等）

## UIGraphicsGetCurrentContext()

> `UIGraphicsGetCurrentContext()` 获取当前的图形绘制上下文，用于在`drawRect:`中绘制图形


## UIGraphicsBeginImageContextWithOptions()

> `UIGraphicsBeginImageContextWithOptions()` 获取图片的context，实现图片的水印，裁剪，截屏，擦除

```

// The following methods will only return a 8-bit per channel context in the DeviceRGB color space.
// Any new bitmap drawing code is encouraged to use UIGraphicsImageRenderer in leiu of this API.
UIKIT_EXTERN void     UIGraphicsBeginImageContext(CGSize size);
UIKIT_EXTERN void     UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) NS_AVAILABLE_IOS(4_0);
UIKIT_EXTERN UIImage* __nullable UIGraphicsGetImageFromCurrentImageContext(void);
UIKIT_EXTERN void     UIGraphicsEndImageContext(void); 

```

```

+ (nullable UIImage *)pq_ClipCircleImageWithImage:(nullable UIImage *)image circleRect:(CGRect)rect borderWidth:(CGFloat)borderW borderColor:(nullable UIColor *)borderColor{
    //1、开启上下文
    UIGraphicsBeginImageContext(image.size);
    
    //2、设置边框
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [borderColor setFill];
    [path fill];
    
    //3、设置裁剪区域
    UIBezierPath * clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(rect.origin.x + borderW , rect.origin.x + borderW , rect.size.width - borderW * 2, rect.size.height - borderW *2)];
    [clipPath addClip];
    
    //3、绘制图片
    [image drawAtPoint:CGPointZero];
    
    //4、获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5、关闭上下文
    UIGraphicsEndImageContext();
    //6、返回新图片
    return newImage;
}

```

[UIGraphicsBeginImageContextWithOptions][1]

## CGBitmapContextCreateWithData

> `CGBitmapContextCreateWithData` 可用于图片的解码（将jpg，png等压缩格式的图片转化为bitmap的位图）

```
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef newContext = CGBitmapContextCreate(bytes,
                                                  width,
                                                  height,
                                                  8,
                                                  newBytesPerRow,
                                                  colorSpace,
                                                  kCGBitmapByteOrder32Little|
                                                  kCGImageAlphaNoneSkipFirst);
  CGColorSpaceRelease(colorSpace);

  CGImageRef result = CGBitmapContextCreateImage(newContext);

  CGContextRelease(newContext);
```


[1]: https://www.jianshu.com/p/4e22c6ac114d