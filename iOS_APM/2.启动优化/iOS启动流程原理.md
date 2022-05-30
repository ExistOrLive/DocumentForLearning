## 1. iOS启动pipeline
![截屏2021-12-22 11.03.20.png](https://cdn.nlark.com/yuque/0/2021/png/22724999/1640142302231-d8473108-4d7f-48d7-9d20-299e613cd5b7.png#clientId=uef326a78-c090-4&from=drop&id=uec44f5c8&margin=%5Bobject%20Object%5D&name=%E6%88%AA%E5%B1%8F2021-12-22%2011.03.20.png&originHeight=476&originWidth=1570&originalType=binary&ratio=1&size=169821&status=done&style=none&taskId=u5b59f0f5-0d34-485b-ad9f-35c847f9a30)


## 2. dyld的版本区别


dyld2 共享缓存(shared cache)
​

dyld3 创建启动闭包 
​

闭包是一个缓存，用来提升启动速度的。既然是缓存，那么必然不是每次启动都创建的，只有在重启手机或者更新/下载 App 的第一次启动才会创建。**闭包存储在沙盒的 tmp/com.apple.dyld 目录，清理缓存的时候切记不要清理这个目录**
​

[抖音品质建设 - iOS启动优化《原理篇》](https://juejin.cn/post/6887741815529832456)​
​

​

