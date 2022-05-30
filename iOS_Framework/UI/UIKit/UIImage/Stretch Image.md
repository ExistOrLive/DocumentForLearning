# Stretch Image 拉伸图片

## 1. UIView.ContentMode


当工程中的切图不满足代码中使用的尺寸配置，就会自动的调节。具体如何的适应，与`UIView.contentMode`属性有关
​

```swift
// contentMode 属性用于设置 content 在视图或者图层中如何定位，如何拉伸

extension UIView {
    open var contentMode: UIView.ContentMode
}

// UIView.ContentMode 对应到 CALayerContentsGravity

extension CALayer {
    var contentsGravity: CALayerContentsGravity 
}

// 枚举定义
public enum ContentMode : Int {

        case scaleToFill = 0   // 默认

        case scaleAspectFit = 1 // contents scaled to fit with fixed aspect. remainder is transparent

        case scaleAspectFill = 2 // contents scaled to fill with fixed aspect. some portion of content may be clipped.

        case redraw = 3 // redraw on bounds change (calls -setNeedsDisplay)

        case center = 4 // contents remain same size. positioned adjusted.

        case top = 5

        case bottom = 6

        case left = 7

        case right = 8

        case topLeft = 9

        case topRight = 10

        case bottomLeft = 11

        case bottomRight = 12
    }

extension CALayerContentsGravity {

    /** Layer `contentsGravity' values. **/
    @available(iOS 2.0, *)
    public static let center: CALayerContentsGravity
    
    @available(iOS 2.0, *)
    public static let top: CALayerContentsGravity
    
    @available(iOS 2.0, *)
    public static let bottom: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let left: CALayerContentsGravity
    
    @available(iOS 2.0, *)
    public static let right: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let topLeft: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let topRight: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let bottomLeft: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let bottomRight: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let resize: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let resizeAspect: CALayerContentsGravity

    @available(iOS 2.0, *)
    public static let resizeAspectFill: CALayerContentsGravity
}
```






![IMG_0137.PNG](https://cdn.nlark.com/yuque/0/2021/png/22724999/1635391938955-15e79f87-7375-45e2-ad66-1c14ac2bd203.png#clientId=u6e2edbc7-317f-4&from=drop&height=369&id=u2de9d59d&margin=%5Bobject%20Object%5D&name=IMG_0137.PNG&originHeight=1116&originWidth=1164&originalType=binary&ratio=1&size=163251&status=done&style=none&taskId=ub2a23cd2-8479-4194-be39-65ecd5ef30e&width=385)


## 2. ResizeImage


### 2.1 UIImage.resizableImage


有一些场景需要保持图片的部分区域不变动，不拉伸，而其他区域可以拉伸。对于这种场景，UIImage中提供了相应的方法。
​

```swift
open class UIImage : NSObject, NSSecureCoding {
   
    @available(iOS 5.0, *)
    open func resizableImage(withCapInsets capInsets: UIEdgeInsets) -> UIImage

    @available(iOS 6.0, *)
    open func resizableImage(withCapInsets capInsets: UIEdgeInsets, resizingMode: UIImage.ResizingMode) -> UIImage

    @available(iOS 5.0, *)
    open var capInsets: UIEdgeInsets { get }

    @available(iOS 6.0, *)
    open var resizingMode: UIImage.ResizingMode { get }   
}


public enum ResizingMode : Int {
    
    case tile = 0      // 平铺
    
    case stretch = 1   // 拉伸
}

```
​

`capInsets` 将把一张图片划分为 9 块区域，4 个角
​

![截屏2021-10-28 11.51.24.png](https://cdn.nlark.com/yuque/0/2021/png/22724999/1635393113550-be23713c-779d-4d0e-b15c-2e01ae2d95b2.png#clientId=udff39663-ae6f-4&from=drop&id=u2cf915e2&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2021-10-28%2011.51.24.png&originHeight=466&originWidth=1492&originalType=binary&ratio=1&size=78987&status=done&style=none&taskId=u034fa8dd-fe5e-4f53-9dba-340df8c549b)
​

[UIImage Document](https://developer.apple.com/documentation/uikit/uiimage/)​
​

​

### 2.2 Xcode Assets Slices




[Xcode Slicing](https://blog.csdn.net/kmyhy/article/details/79087418)
​

### 2.3 CALayer.contentsCenter
