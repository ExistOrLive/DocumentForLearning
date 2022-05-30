# CGContectRef

> CGContectRef 代表视图绘制的上下文，存储了一次图层绘制的信息（颜色，字体，文字大小，路径等等）

## UIGraphicsGetCurrentContext()

> `UIGraphicsGetCurrentContext()` 获取当前的图形绘制上下文，用于在`drawRect:`中绘制图形


## UIGraphicsBeginImageContextWithOptions()

> `UIGraphicsBeginImageContextWithOptions()` 获取图片的context，实现图片的水印，裁剪，截屏，擦除 以及 压缩;


```

// The following methods will only return a 8-bit per channel context in the DeviceRGB color space.
// Any new bitmap drawing code is encouraged to use UIGraphicsImageRenderer in leiu of this API.
UIKIT_EXTERN void     UIGraphicsBeginImageContext(CGSize size);
UIKIT_EXTERN void     UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale) NS_AVAILABLE_IOS(4_0);
UIKIT_EXTERN UIImage* __nullable UIGraphicsGetImageFromCurrentImageContext(void);
UIKIT_EXTERN void     UIGraphicsEndImageContext(void); 

```

### 裁剪图片示例

```
+ (nullable UIImage *)pq_ClipCircleImageWithImage:(nullable UIImage *)image circleRect:(CGRect)rect borderWidth:(CGFloat)borderW borderColor:(nullable UIColor *)borderColor{
    //1、开启上下文
    UIGraphicsBeginImageContext(image.size);
    
    //2、设置裁剪区域
    UIBezierPath * clipPath = [UIBezierPath bezierPathWithOvalInRect:rect];
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

### 压缩图片示例

```
/**
 *
 * 将图片压缩指定的宽高
 **/
- (UIImage *)imageCompressWithImage:(UIImage *)sourceImage targetHeight:(CGFloat)targetHeight targetWidth:(CGFloat)targetWidth
{
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));

    [sourceImage drawInRect:CGRectMake(0,0,targetWidth, targetHeight)];

    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage;
}

```


[UIGraphicsBeginImageContextWithOptions][1]

## CGBitmapContextCreateWithData

> `CGBitmapContextCreateWithData` 可用于图片的解码（将jpg，png等压缩格式的图片转化为bitmap的位图);

> 图片解码后的数据描述了图片每个像素的`RGBA`值，所以一个像素占据4个字节；因此可以通过`width * height * 4` 计算出图片解码后的大小。

> 一般来说，图片解码的时机在CPU将计算好的内容提交给GPU之前，由CPU去解码。当一个界面有很多图片需要展示的时候，CPU无法在一帧的时间内，完成这么多图片的解码，因此可能会有卡顿；同时，还会带来内存的峰值，可能造成堆栈溢出而闪退。

> 我们可以通过一下代码手动去解码;

### 图片解码示例

```

- (UIImage *) decodeImage:(UIImage *) sourceImage
{
  
  CGFloat width = sourceImage.size.width;
  CGFloat height = sourceImage.size.height;
  char * bytes = (char *)malloc(width * height * 4);

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef newContext = CGBitmapContextCreate(bytes,
                                                  width,
                                                  height,
                                                  8,
                                                  width * 4,
                                                  colorSpace,
                                                  kCGBitmapByteOrder32Little|
                                                  kCGImageAlphaNoneSkipFirst);
  
 
  /**
   *
   *  在CGBitmapContext 绘制图片
   **/
  CGContextDrawImage(newContext,sourceImage.CGImage);
  
  /**
   *
   *  获取解码后图片
   **/
  CGImageRef resultRef = CGBitmapContextCreateImage(newContext);
  UIImage * result = [UImage imageWithCGImage:resultRef];

  /**
   *
   *  释放资源，避免内存泄漏（Core Foundation 没有ARC，必须手动释放）
   **/
  CGContextRelease(newContext);
  CGImageRelease(resultRef);
  CGColorSpaceRelease(colorSpace);
  free(bytes);
  bytes = NULL:

  return result;

}

```

> `CGBitmapContextGetData`可以将图片解码后的数据转换为字节数组，这样就可以直接操作图片每一个像素的颜色(RGB)和不透明度(A)

### 图片马赛克化示例

```
/**转换成马赛克,level代表一个点转为多少level*level的正方形*/
+ (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef = orginImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  kBitsPerComponent,        //每个颜色值8bit
                                                  width*kPixelChannelCount, //每一行的像素点占用的字节数，每个像素点的ARGB四个通道各占8个bit
                                                  colorSpace,
                                                  kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData (context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount] = {0};
    NSUInteger index,preIndex;
    for (NSUInteger i = 0; i < height - 1 ; i++) {
        for (NSUInteger j = 0; j < width - 1; j++) {
            index = i * width + j;
            if (i % level == 0) {
                if (j % level == 0) {
                    memcpy(pixel, bitmapData + kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData + kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            } else {
                preIndex = (i-1)*width +j;
                memcpy(bitmapData + kPixelChannelCount*index, bitmapData + kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength = width*height* kPixelChannelCount;
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height,
                                              kBitsPerComponent,
                                              kBitsPerPixel,
                                              width*kPixelChannelCount ,
                                              colorSpace,
                                              (CGBitmapInfo)kCGImageAlphaPremultipliedLast,
                                              provider,
                                              NULL, NO,
                                              kCGRenderingIntentDefault);
    CGContextRef outputContext = CGBitmapContextCreate(nil,
                                                       width,
                                                       height,
                                                       kBitsPerComponent,
                                                       width*kPixelChannelCount,
                                                       colorSpace,
                                                       kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(outputContext, CGRectMake(0.0f, 0.0f, width, height), mosaicImageRef);
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage = [UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    } else {
        resultImage = [UIImage imageWithCGImage:resultImageRef];
    }
    //释放
    if(resultImageRef){
        CFRelease(resultImageRef);
    }
    if(mosaicImageRef){
        CFRelease(mosaicImageRef);
    }
    if(colorSpace){
        CGColorSpaceRelease(colorSpace);
    }
    if(provider){
        CGDataProviderRelease(provider);
    }
    if(context){
        CGContextRelease(context);
    }
    if(outputContext){
        CGContextRelease(outputContext);
    }
    
    return resultImage;
    //return [[resultImage retain] autorelease];
    
}
```

[iOS中的CGBitmapContext][2]

[iOS开发 - 图片的解压缩到渲染过程][3]


[1]: https://www.jianshu.com/p/4e22c6ac114d
[2]: https://www.jianshu.com/p/84addd11e679
[3]: https://www.jianshu.com/p/3bf46ca95bfb