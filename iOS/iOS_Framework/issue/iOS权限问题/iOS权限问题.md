# iOS权限问题

> 首先需要在工程的`info.plist` 注册相关的权限和提示语

```
<!-- 相册 --> 
<key>NSPhotoLibraryUsageDescription</key>
<string>需要您的同意,APP才能访问相册</string> 

<!-- 相机 --> 
<key>NSCameraUsageDescription</key> 
<string>需要您的同意,APP才能访问相机</string>

<!-- 麦克风 --> 
<key>NSMicrophoneUsageDescription</key> 
<string>需要您的同意,APP才能访问麦克风</string> 

<!-- 位置 --> 
<key>NSLocationUsageDescription</key> 
<string>需要您的同意, APP才能访问位置</string> 

<!-- 在使用期间访问位置 --> 
<key>NSLocationWhenInUseUsageDescription</key> 
<string>App需要您的同意, APP才能在使用期间访问位置</string> 

<!-- 始终访问位置 --> 
<key>NSLocationAlwaysUsageDescription</key> 
<string>App需要您的同意, APP才能始终访问位置</string> 

<!-- 日历 --> 
<key>NSCalendarsUsageDescription</key> 
<string>App需要您的同意, APP才能访问日历</string> 

<!-- 提醒事项 --> 
<key>NSRemindersUsageDescription</key> 
<string>需要您的同意, APP才能访问提醒事项</string> 

<!-- 运动与健身 --> 
<key>NSMotionUsageDescription</key> 
<string>需要您的同意, APP才能访问运动与健身</string> 

<!-- 健康更新 --> 
<key>NSHealthUpdateUsageDescription</key> 
<string>需要您的同意, APP才能访问健康更新 </string> 

<!-- 健康分享 --> 
<key>NSHealthShareUsageDescription</key> 
<string>需要您的同意, APP才能访问健康分享</string> 

<!-- 蓝牙 --> 
<key>NSBluetoothPeripheralUsageDescription</key> 
<string>需要您的同意, APP才能访问蓝牙</string> 

<!-- 媒体资料库 --> 
<key>NSAppleMusicUsageDescription</key> 
<string>需要您的同意, APP才能访问媒体资料库</string>

```
![pic1][1]

> 然后在使用相应功能前需要编码申请相应的权限

**申请访问麦克风的权限**
```
/**
 * 调用AVAudioSession的requestRecordPermission:可以申请麦克风的权限
 **/
AVAudioSession *session = [AVAudioSession sharedInstance];
__block BOOL bCanRecord = NO;
if ([session respondsToSelector:@selector(requestRecordPermission:)]) 
{
    [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted)
    {
            if (granted)
            {
                //可以录音
                bCanRecord = YES;
            } 
            else 
            {
                bCanRecord = NO;
            }
     }];
}
```

**申请访问相册的权限**

```
   
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted 
     || author ==ALAuthorizationStatusDenied)
    {
        // 已经拒绝授予权限
        return;
    }
    else
    {
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll
        usingBlock:^(ALAssetsGroup *group, BOOL *stop)
        {
           //   申请权限成功
        }
        failureBlock:^(NSError *error) 
        {
           // 申请失败
        }
    }
 

```
> 被授予权限后，才可以执行相应功能的代码，否则会闪退

   


[1]: pic1.png