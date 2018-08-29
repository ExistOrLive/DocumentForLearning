# UIWindow

> UIWindow并不包含任何默认的内容, 但是它被当作UIView的容器，用于放置应用中的所有的UIView。

### 主要作用
 - 作为UIView的最顶层的容器,包含应用显示所需要的所有的UIView
 - 传递触摸消息和键盘事件给UIView
 
### iOS应用的默认顶层容器UIWindow

```
#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
```
在`AppDelegate`中的属性`@property (strong, nonatomic) UIWindow *window;`是应用默认的顶层容器

一般我们会在 `- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`中生成它

```
/**
 * 生成UIWindow的同时需要设置RootViewController
 **/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [_window setBackgroundColor:[UIColor whiteColor]];
    ViewController * controller = [[ViewController alloc] init];
    [_window setRootViewController:controller];
    [window makeKeyAndVisible];
    
    
    return YES;
}

```
#### Tip：
在`- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions`执行过程中创建的UIWindow都必须设置RootViewController，否则会以下报错

![Application windows are expected to have a root view controller at the end of application launch][1]

在设置为RootViewController 的` -(void) viewDidLoad;`创建的UIWindow也必须设置RootViewController

### 为UIWindow添加UIView

 - 使用`addSubView`方法来添加子视图
 
 - 使用添加RootViewController,UIWindow会自动将其view添加到当前window中,同时负责维护ViewController和view的生命周期


### windowLevel

```
UIKIT_EXTERN const UIWindowLevel UIWindowLevelNormal;    // 0.0
UIKIT_EXTERN const UIWindowLevel UIWindowLevelAlert;     // 2000.0
UIKIT_EXTERN const UIWindowLevel UIWindowLevelStatusBar;  // 1000.0 
```

### keyWindow and windows

```
// UIApplication 有这样两个属性

@property(nullable, nonatomic,readonly) UIWindow *keyWindow;
@property(nonatomic,readonly) NSArray<__kindof UIWindow *>  *windows;
```
> keyWindow是系统设置来用于接受键盘和其他非触摸事件的UIWindow

可以通过`makeKeyWindow`和`resignKeyWindow`将自己创建的UIWindow设置keywindow

> windows 以弱引用的方式，保存了应用中所有的UIWindow

##### Tip

> 自定义的UIWindow通过用作在任何界面之上弹出的一个界面和弹框,常用于手势密码,voip通话界面,应用的启动页,弹框广告

> 不能够滥用UIWindow,当某个弹出框明显属于某个界面，不应该用UIWindw; 通常做法会将UIWindow设置为单例,当UIWindow过多时,占用大量内存,且多个UIWindow之间层级关系会很复杂


参考文档： 

 1. iOS开发进阶 唐巧


 
  [1]: error1.png