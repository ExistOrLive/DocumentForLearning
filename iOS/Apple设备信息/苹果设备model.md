# 苹果设备 model

苹果设备的 model 信息是苹果内存的设备码，用于区分不同的设备。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-10-28%20%E4%B8%8A%E5%8D%881.21.19.png)


```objc
// 获取设备model，并返回对应的设备名
#import <sys/utsname.h>

+ (NSString *) getDeviceModel{
    
    /**
     *  ref : https://github.com/pluwen/Apple-Device-Model-list
     * */
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    ..........
    if ([platform isEqualToString:@"iPhone12,1"]) return @"iPhone 11";
    if ([platform isEqualToString:@"iPhone12,3"]) return @"iPhone 11 Pro";
    if ([platform isEqualToString:@"iPhone12,5"]) return @"iPhone 11 Pro Max";
    if ([platform isEqualToString:@"iPhone12,8"]) return @"iPhone SE 2";
    if ([platform isEqualToString:@"iPhone13,1"]) return @"iPhone 12 mini";
    if ([platform isEqualToString:@"iPhone13,2"]) return @"iPhone 12";
    if ([platform isEqualToString:@"iPhone13,3"]) return @"iPhone 12 Pro";
    if ([platform isEqualToString:@"iPhone13,4"]) return @"iPhone 12 Pro Max";
    
    // iPad
    .......
    if ([platform isEqualToString:@"iPad7,12"]) return @"iPad 7";
    if ([platform isEqualToString:@"iPad11,6"]) return @"iPad 8";
    if ([platform isEqualToString:@"iPad11,7"]) return @"iPad 8";
    
   
    // Simulator
    if ([platform isEqualToString:@"i386"]) return @"Simulator";
    if ([platform isEqualToString:@"x86_64"]) return @"Simulator";
  
    return platform;
}

```

## 参考

[pluwen/apple-device-model-list](https://github.com/pluwen/apple-device-model-list)

[Models - The iPhone Wiki](https://www.theiphonewiki.com/wiki/Models)

[Everyi.com](https://everymac.com/systems/apple/iphone/index-iphone-specs.html?__cf_chl_captcha_tk__=pmd_30AqhY2D2RdzpuKI68PW.M9muvIaFwhrk5es553VHtA-1635355641-0-gqNtZGzNAyWjcnBszQr9)
