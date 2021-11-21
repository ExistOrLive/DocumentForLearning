# UIImage 

```objc
@interface UIImage : NSObject <NSSecureCoding>

@property(nonatomic,readonly) CGSize size; 

@property(nullable, nonatomic,readonly) CGImageRef CGImage; 

#if __has_include(<CoreImage/CoreImage.h>)
@property(nullable,nonatomic,readonly) CIImage *CIImage API_AVAILABLE(ios(5.0)); 
#endif

@property(nonatomic,readonly) UIImageOrientation imageOrientation; 

@property(nonatomic,readonly) CGFloat scale;
@end
```


## CGImage / CIImage 

`CGImage` 和 `CIImage` 是底层的图片数据，其中只有一个有数据。

`CGImage` 是 `CGImageRef` 类型，是 **Core Graphics** 库使用的数据类型，保存着从图片文件中读取的数据或者运行时绘制的图片数据。

`CIImage` 是 **Core Image** 库使用的数据类型，一般用于图片特效

## scale 和 size

`size`描述的图片的大小，但是是以 **逻辑像素** 为单位，`size`的`width` 和 `height` 是 物理像素 除以 `scale` 的结果

## imageOrientation

```objc
typedef NS_ENUM(NSInteger, UIImageOrientation) {
    UIImageOrientationUp,            // default orientation
    UIImageOrientationDown,          // 180 deg rotation
    UIImageOrientationLeft,          // 90 deg CCW
    UIImageOrientationRight,         // 90 deg CW
    UIImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
    UIImageOrientationDownMirrored,  // horizontal flip
    UIImageOrientationLeftMirrored,  // vertical flip
    UIImageOrientationRightMirrored, // vertical flip
};
```







