
# fatslane 证书管理
#fastlane
#证书管理
## 1. 证书同步

`fastlane match <type>  --readonly` 从仓库中同步对应的证书

```sh
fastlane match development --readonly
```


## 2. 添加新设备


## 3. 证书过期

苹果证书的有效期只有一年，因此需要每年续费开发者账号并刷新证书。 当证书过期后，会自动从苹果开发者网站上移除；但是使用fastlane同步证书时，却不清楚是否时被某人移除，证书过期还是发生了错误，match会提示以下的错误，而不是执行任何对用户及其证书危险的操作。

> [!] Your certificate 'XXXXXXXXXX.cer' is not valid, please check end date and renew it if necessary

![](https://pic.existorlive.cn/202202220123931.png)

在证书过期后，首先要删除仓库中的证书，有两种方式来处理：

- `fastlane match nuke` 自动删除证书

- 手动删除仓库中的证书

接着使用 fastlane match 创建新的证书

### 3.1  fastlane match nuke 自动删除证书

```sh 
fastlane match nuke development
fastlane match nuke distribution
fastlane match nuke enterprise
```

`fastlane match nuke` 将会删除指定类型的所有证书

```sh 
fastlane match appstore
fastlane match development
```

接着使用 `fastlane match` 创建指定类型的证书

### 3.2 手动删除仓库的证书

1. 在远程仓库中移除需要清除的证书

```sh
certs/distribution/XXXXXXXXXX.cer
certs/distribution/XXXXXXXXXX.p12

certs/development/XXXXXXXXXX.cer
certs/development/XXXXXXXXXX.p12
```

![](https://pic.existorlive.cn/202202220132059.png)

![](https://pic.existorlive.cn/202202220132048.png)

2. 在苹果开发者网站中删除对应的provision文件 

![](https://pic.existorlive.cn/202202220135273.png)

3.  使用 `fastlane match` 创建指定类型的证书




[证书管理](https://juejin.cn/post/6844903663949840392)

[How to renew an expired certificate with Fastlane Match](https://sarunw.com/posts/how-to-renew-expired-certificate-with-fastlane-match/)