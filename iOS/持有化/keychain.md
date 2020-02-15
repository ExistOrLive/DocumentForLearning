# KeyChain

> KeyChain Service 是iOS和MacOS都提供的一种安全存储敏感信息的工具。 例如： 网站密码，应用程序密码或者数据库密码；也可以保存认证用的证书，秘钥和身份信息。

下图所示为mac的keychain(钥匙串)，这里保存了密码，证书以及秘钥等敏感信息

![][1]


## KeyChain的API

> `Security.framework`提供了访问keychain的API

```objc


OSStatus SecItemCopyMatching(CFDictionaryRef query, CFTypeRef * __nullable CF_RETURNS_RETAINED result)
    API_AVAILABLE(macos(10.6), ios(2.0));

OSStatus SecItemAdd(CFDictionaryRef attributes, CFTypeRef * __nullable CF_RETURNS_RETAINED result)
    API_AVAILABLE(macos(10.6), ios(2.0));

OSStatus SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate)
    API_AVAILABLE(macos(10.6), ios(2.0));

OSStatus SecItemDelete(CFDictionaryRef query)
    API_AVAILABLE(macos(10.6), ios(2.0));


```







[1]:pic/Mac_keychain.png