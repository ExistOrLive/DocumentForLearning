# CADisplayLink 

`CADisplayLink`是一个与显示器刷新频率同步的定时器。

```objc
CADisplayLink *link = [CADisplayLink displayLinkWithTarget:[WeakProxy proxyWithObject:self] selector:@selector(tick:)];
[link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
```

与 `NSTimer` 相似，创建`CADisplayLink`创建时，需要提供`target`，`selector`，注意`target`是被`CADisplayLink`强持有。

`CADisplayLink`需要添加到**RunLoop**中，才可以生效。因此尽管`CADisplayLink`是一个与显示器刷新频率同步的定时器(显示器刷新是固定的，一般为60hz)，但是并不是严格实时的。实际上，`CADisplayLink`是一个与**FPS(帧率)**同步的定时器。

`CADisplayLink`往往会用来监控实时的帧率。

```objc
@interface CADisplayLink : NSObject

// 当前帧的时间戳
@property(readonly, nonatomic) CFTimeInterval timestamp;
// 当前帧的持续时间
@property(readonly, nonatomic) CFTimeInterval duration;

// 下一帧的时间戳
@property(readonly, nonatomic) CFTimeInterval targetTimestamp
    API_AVAILABLE(ios(10.0), watchos(3.0), tvos(10.0));

....

@end


```

可以利用每次回调的`timestamp`来计算帧率。(注意`duration`一般是固定的，与屏幕刷新频率同步)

以**60hz**的刷新率为例，尽管`CADisplayLink`是每秒60次通知**Runloop**处理事件，但是**Runloop**处理事件的时机与当前任务的多少和复杂程度有关。在处理`CADisplayLink`事件时，可以已经收到多次事件通知，但是和`NSTimer`一样仅会处理一次。


## 监控实时帧率


```objc

- (void) setUp{
    self.link = [CADisplayLink displayLinkWithTarget:[WeakProxy proxyWithObject:self] selector:@selector(tick:)];
   [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}


- (void)tick:(CADisplayLink *)link {
    if (_lastTime == 0) {
        _lastTime = link.timestamp;
        return;
    }
    
    _count++;
    // 计算上一帧与当前帧的时间差
    NSTimeInterval delta = link.timestamp - _lastTime;
    if (delta < 1) return;       
    _lastTime = link.timestamp;
    float fps = _count / delta;  // 计算FPS
    _count = 0;
    
    NSLog(@"timestamp: %lf, duration: %lf",link.timestamp,link.duration);
 
    
    CGFloat progress = fps / 60.0;
    UIColor *color = [UIColor colorWithHue:0.27 * (progress - 0.2) saturation:1 brightness:0.9 alpha:1];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d FPS",(int)round(fps)]];
    
    self.attributedText = text;
}

- (void) dealloc{
    [self.link invalidate];
}

```



