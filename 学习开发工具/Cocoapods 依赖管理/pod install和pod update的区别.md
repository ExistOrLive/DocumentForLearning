# pod install 和 pod update 的 区别

- `pod install`

    `pod install` 用于在工程中安装pod库；

    当在 `podfile` 文件中添加，删除或者修改 pod，也是使用  `pod intall` 应用更新 


    第一次执行 `pod install` 时，会下载每一个最新的pod库(如果在podfile中对pod版本作出限制，会符合相应的需求)，并生成 `podfile.lock`,持续跟踪当前下载的pod库版本

    之后执行`pod install` , 如果 pod库 在`podfile.lock`中，则下载`podfile.lock` 中指定的版本；否则会下载最新的版本(仍然会符合版本限制)

- `pod update`
   
    只有在需要将pod库更新到最新时，才使用`pod update`

    当执行 `pod update [PODNAME]`时，会忽略`podfile.lock`的限制，下载指定pod库的最新版本。(如果限制了版本，仍然会符合版本限制)

- `pod outdated`

    `pod outdated` 会列出最新版本高于`podfile.lock`中版本的pod库


## 场景示例

某个工程依赖`AFNetworking`,`YYKit`,`TestPod`三个库，最新版本分别为`4.0.1`,`1.0.9`,`0.1.0`

```ruby
  #podfile
  
  pod 'AFNetworking', '3.1.0'    # AFNtworking 限制为 3.1.0

  pod 'Aspect'

  pod 'TestPod', :git => 'https://github.com/ExistOrLive/TestPod.git'
```

### 1. 用户A首次pod install

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%885.40.57.png)

可以看到 AFNetworking 被限制在 3.1.0

### 2. 用户B同步代码后，pod install

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%885.41.02.png)

用户B按照 podfile.lock 中限制的版本下载pod

### 3. 在 TestPod 最新版本升级到 0.1.1，用户A执行pod update 

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%885.41.09.png)

执行 pod update， 所有的pod库都会试图更新至最新版本，TestPod更新到0.1.1，YYKit 已经是最新，AFNetworking 仍被限制在 3.1.0

### 4. 用户A执行pod update后,用户B执行pod install同步pod 版本

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%885.41.14.png)


### 5. 用户B 删除 Aspect , 指向pod install

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%885.43.51.png)


### 6. 用户A 限制 AFNetworking ，执行 pod install

![](https://github.com/existorlive/existorlivepic/raw/master/%E6%88%AA%E5%B1%8F2021-02-02%20%E4%B8%8B%E5%8D%885.46.40.png)

## 总结

1. 无论在podfile中，增加，删除还是修改pod，都是执行 pod install
     
        pod install 首先确认当前是否已经下载了对应的库，库是否满足podfile中对版本的限制。如果满足则不再下载。

2. 只有在需要将某个pod更新至满足podfile中版本限制的最新版本时，才执行 pod update

## 参考文档

[pod install vs. pod update](https://guides.cocoapods.org/using/pod-install-vs-update.html)


