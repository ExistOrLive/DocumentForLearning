# AVAudioSession

> 音频硬件资源对于一台iOS系统设备来说时唯一的，`AVAudioSession`就是用来管理多个APP之间对音频资源的使用。

    `AVAudioSession`可以管理许多音频相关的配置，例如：
    
     (1) 音频是否会随着进入后台,进入静音模式或者锁屏关闭
     (2) 音频是否可以和其他APP的音频共存
     (3) 指定音频的输入输出设备（扬声器还是听筒）
     (4) 处理其他APP播放音频而发出的中断


```
/**
 * 获取单例
 **/
+ (AVAudioSession *)sharedInstance;
```


## AVAudioSession 激活

> `AVAudioSession`只有在激活后调用相关的方法(修改category，监听中断通知等)才会有效；

### 手动激活

```
- (BOOL)setActive:(BOOL)active error:(NSError **)outError;
- (BOOL)setActive:(BOOL)active withOptions:(AVAudioSessionSetActiveOptions)options error:(NSError **)outError;

// 通过以上两个方法，可以主动激活和解除激活`AVAudioSession`;

```

> 需要注意的是，这两个方法是同步(阻塞)方法，因此不推荐在耗时操作会出问题的线程执行这个方法;

> 因此AVAudioSession会影响其他App的表现，当自己的App的Session被激活，其他的App就会解除激活。可以通过options传入`AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation`,通知其他App当前的App是否激活或者解除激活`AVAudioSession`;其他App需要监听`AVAudioSessionSilenceSecondaryAudioHintNotification`通知。

例如 ： 
音乐APP会监听`AVAudioSessionSilenceSecondaryAudioHintNotification`通知；当类型为`AVAudioSessionSilenceSecondaryAudioHintTypeBegin`时，即其他占用AVAudioSession时，音乐APP保存当前状态，关闭音乐；当类型为`AVAudioSessionSilenceSecondaryAudioHintTypeEnd`时，音乐APP回复之前的状态

### 自动激活

> 当使用`AVAudioPlayer`播放音乐时，会自动激活`AVAudioSession`

## Category

> Category管理当前App的音频是否会随着锁屏，静音模式以及进入后台而关闭；是否和其他App的音频共存



```
/* set session category */
- (BOOL)setCategory:(NSString *)category error:(NSError **)outError;
/* set session category with options */
- (BOOL)setCategory:(NSString *)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError NS_AVAILABLE_IOS(6_0);
/* set session category and mode with options */
- (BOOL)setCategory:(NSString *)category mode:(NSString *)mode options:(AVAudioSessionCategoryOptions)options error:(NSError **)outError API_AVAILABLE(ios(10.0), watchos(3.0), tvos(10.0));

```
