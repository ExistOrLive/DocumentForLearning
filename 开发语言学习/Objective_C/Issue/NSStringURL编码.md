﻿# NSString + NSURLUtilities

> 在网络编程中，URL仅支持26个英文字母和少量特殊字符（/ ？ ：），而不支持中文字符。因此当URL中含有中文字符时，就需要编码。`NSString + NSURLUtilities`分类就支持对中文的编解码。

```objc
/**
 * 中文字符编码 
 **/
- (nullable NSString *)stringByAddingPercentEscapesUsingEncoding:(NSStringEncoding)enc API_DEPRECATED("Use -stringByAddingPercentEncodingWithAllowedCharacters: instead, which always uses the recommended UTF-8 encoding, and which encodes for a specific URL component or subcomponent since each URL component or subcomponent has different rules for what characters are valid.", macos(10.0,10.11), ios(2.0,9.0), watchos(2.0,2.0), tvos(9.0,9.0));

/**
 * 中文字符解码
 **/
- (nullable NSString *)stringByReplacingPercentEscapesUsingEncoding:(NSStringEncoding)enc API_DEPRECATED("Use -stringByRemovingPercentEncoding instead, which always uses the recommended UTF-8 encoding.", macos(10.0,10.11), ios(2.0,9.0), watchos(2.0,2.0), tvos(9.0,9.0));

```

> 为了自定义规则，进行特殊字符的编解码，以上两个方法就不建议使用了，需要使用一下两个方法，这两个方法默认使用UTF-8编码

```objc
// Returns a new string made from the receiver by replacing all characters not in the allowedCharacters set with percent encoded characters. UTF-8 encoding is used to determine the correct percent encoded characters. Entire URL strings cannot be percent-encoded. This method is intended to percent-encode an URL component or subcomponent string, NOT the entire URL string. Any characters in allowedCharacters outside of the 7-bit ASCII range are ignored.
- (nullable NSString *)stringByAddingPercentEncodingWithAllowedCharacters:(NSCharacterSet *)allowedCharacters API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

// Returns a new string made from the receiver by replacing all percent encoded sequences with the matching UTF-8 characters.
@property (nullable, readonly, copy) NSString *stringByRemovingPercentEncoding API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));
```

`NSCharacterSet + NSURLUtilities` 提供url不同部位需要编码的字符集。

```objc
@interface NSCharacterSet (NSURLUtilities)
// Predefined character sets for the six URL components and subcomponents which allow percent encoding. These character sets are passed to -stringByAddingPercentEncodingWithAllowedCharacters:.

// Returns a character set containing the characters allowed in an URL's user subcomponent.
@property (class, readonly, copy) NSCharacterSet *URLUserAllowedCharacterSet API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

// Returns a character set containing the characters allowed in an URL's password subcomponent.
@property (class, readonly, copy) NSCharacterSet *URLPasswordAllowedCharacterSet API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

// Returns a character set containing the characters allowed in an URL's host subcomponent.
@property (class, readonly, copy) NSCharacterSet *URLHostAllowedCharacterSet API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

// Returns a character set containing the characters allowed in an URL's path component. ';' is a legal path character, but it is recommended that it be percent-encoded for best compatibility with NSURL (-stringByAddingPercentEncodingWithAllowedCharacters: will percent-encode any ';' characters if you pass the URLPathAllowedCharacterSet).
@property (class, readonly, copy) NSCharacterSet *URLPathAllowedCharacterSet API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

// Returns a character set containing the characters allowed in an URL's query component.
@property (class, readonly, copy) NSCharacterSet *URLQueryAllowedCharacterSet API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

// Returns a character set containing the characters allowed in an URL's fragment component.
@property (class, readonly, copy) NSCharacterSet *URLFragmentAllowedCharacterSet API_AVAILABLE(macos(10.9), ios(7.0), watchos(2.0), tvos(9.0));

@end
```

## example

```objc
NSString * pureUrlStr = @"www.baidu.com/百度"
NSString * encodeUrlStr = [pureUrlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];

```






