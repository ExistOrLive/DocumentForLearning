# AVAudioSession

> 音频硬件资源对于一台iOS系统设备来说时唯一的，`AVAudioSession`就是用来管理多个APP之间对音频资源的使用。

    `AVAudioSession`可以管理许多音频相关的配置
    
     (1) 配置session的category和mode来告诉系统你希望在App中怎么使用音频
     (2) 激活session使category和mode生效
     (3) 申请录制音频的权限
     (4) 订阅和处理音频相关的通知
     (5) 操作高级音频配置，如采样频率，I/O缓冲时间，通道的数量


```
/**
 * 获取单例
 **/
+ (AVAudioSession *)sharedInstance;
```


## 1. AVAudioSession 激活

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

## 2. Category

> `AVAudioSession`默认设置为`AVAudioSessionCatetorySoloAmbient`

1. 允许播放音频，但是不允许录制音频
2. 当设置为静音模式，正在播放的音频会被关闭
3. 当设备被锁，音频会被关闭
4. 当音频播放时，其他音频会被关闭

```
/**
 *
 * 可以设置的Category
 **/
@property (readonly) NSArray<NSString *> *availableCategories;

/**
 *
 * 当前设置的Category
 **/
@property (readonly) NSString *category;

/**
 *
 * 设置Category
 **/
- (BOOL)setCategory:(NSString *)category error:(NSError **)outError;

```

### Tips
> Category 只有在`AVAudioSession`激活后才会生效

![AVAudioSessionCategory][1]

- `AVAudioSessionCategoryAmbient`
   
   仅支持音频播放；可以和后台音频混音；


- `AVAudioSessionCategorySoloAmbient`
   
   仅支持音频播放；会关闭后台音频 (适用于游戏这样不需要和其他App混音，且仅支持前台播放的场景)

- `AVAudioSessionCategoryPlayBack`
   
   仅支持音频播放；进入后台，静音，锁屏不会关闭音频（适用于音乐播放的场景）
   在后台播放，还需要设置Background Modes 

   ![Background Mode][2]


- `AVAudioSessionCategoryPlayAndRecord`
   
    支持音频播放和录制，适用于VOIP这样的场景

- `AVAudioSessionCategoryRecord`
   
   仅支持音频的录制

- `AVAudioSessionCategoryAudioProcessing`
 
   仅支持音频处理，不支持播放
   
- `AVAudioSessionCategoryMutiRoute`
   
   支持音频播放和录制。允许多条音频流的同步输入和输出

## 3. AVAudioSession Mode & options

> category 定义了七种主要的场景，还可以通过Mode 和 options微调

## AVAudioSessionCategoryOptions

```
/**
 *
 * 当前设置的options
 **/
@property (readonly) AVAudioSessionCategoryOptions categoryOptions NS_AVAILABLE_IOS(6_0);

/**
 *
 * 设置options
 **/
- (BOOL)setCategory:(NSString *)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError **)outError NS_AVAILABLE_IOS(6_0);
```

![AVAudioSessionOption][3]

## AVAudioSessionMode

```
/**
 *
 * 可以支持的Mode
 **/
@property (readonly) NSArray<NSString *> *availableModes NS_AVAILABLE_IOS(9_0);

/**
 *
 * 当前设置的mode
 **/
@property (readonly) NSString *mode NS_AVAILABLE_IOS(5_0); /* get session mode */

/**
 *
 * 设置mode
 **/
- (BOOL)setMode:(NSString *)mode error:(NSError **)outError NS_AVAILABLE_IOS(5_0); /* set session mode */
```

![AVAudioSessionMode][4]






## 4. 通知的监听和处理(中断，通道变更)

### AVAudioSessionInterruptionNotification

> `AVAudioSessionInterruptionNotification`用于监听音频的中断(闹钟，来电，其他App占用了AVAudioSession)
   
   `AVAudioSessionInterruptionTypeKey`键有两个值：
    
    - AVAudioSessionInterruptionTypeBegan表示中断开始
    - AVAudioSessionInterruptionTypeEnded表示中断结束
    
中断开始：我们需要做的是保存好播放状态，上下文，更新用户界面等

中断结束：我们要做的是恢复好状态和上下文，更新用户界面，根据需求准备好之后选择是否激活我们session。

> 选择不同的音频播放技术，处理中断方式也有差别，具体如下:

System Sound Services：使用 System Sound Services 播发音频，系统会自动处理，不受APP控制，当中断发生时，音频播放会静音，当中断结束后，音频播放会恢复。

AV Foundation framework：AVAudioPlayer 类和 AVAudioRecorder 类提供了中断开始和结束的 Delegate 回调方法来处理中断。中断发生，系统会自动停止播放，需要做的是记录播放时间等状态，更新用户界面，等中断结束后，再次调用播放方法，系统会自动激活session。

Audio Queue Services, I/O audio unit：使用aduio unit这些技术需要处理中断，需要做的是记录播放或者录制的位置，中断结束后自己恢复audio session。

OpenAL：使用 OpenAL 播放时，同样需要自己监听中断。管理 OpenAL上下文，用户中断结束后恢复audio session。

### Tip:

1. 中断开始不一定有中断结束
2. 音频资源竞争上，一定是电话优先


### AVAudioSessionRouteChangeNotification

> `AVAudioSessionRouteChangeNotification` 用于监听新设备的接入和移除(如耳机)，categary的改变等

userInfo包含一个键：`AVAudioSessionRouteChangeReasonKey`

![AVAudioSessionRouteChangeReason][5]


### 5、录音权限

```

- (AVAudioSessionRecordPermission)recordPermission __TVOS_PROHIBITED API_AVAILABLE(ios(8.0), watchos(4.0));

typedef void (^PermissionBlock)(BOOL granted);

- (void)requestRecordPermission:(PermissionBlock)response __TVOS_PROHIBITED API_AVAILABLE(ios(7.0), watchos(4.0));
```

### 6、音频设备高级配置


### [Demo][6]


[1]: pic/AVAudioSessionCategory.png
[2]: pic/Background_Mode.png
[3]: pic/AVAudioSessionCategoryOption.png
[4]: pic/Mode.png
[5]: pic/AVAudioSessionRouteChangeReason.png
[6]: https://github.com/ExistOrLive/DemoForLearning/tree/master/AVAudioTest