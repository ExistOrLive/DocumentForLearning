### iOS Json解析

> 在iOS中，可以使用`NSJsonSerialization`工具类实现对json的读写


----------
NSJSONSerialization 提供了以下几个方法：

```
/**
 * 检查传入的OC对象是否能够转换为Json
 * 一般符合以下几个条件的才能转换为Json
 * （1） 顶级对象是NSDictionary 或 NSArray
 * （2） 所有value 必须是 NSString，NSNumber，NSArray，NSDictionary，NSNull
 * （3）NSNumber不可以是NAN 或者无穷大
 **/
 
+ (BOOL) isValidJSONObject:(id)obj ;
```

```
/**
 * 将合格的NSArray，NSDictionary 转换为Json的NSData
 * options 设置为 NSJSONWritingPrettyPrinted，可读性更高
 **/
 
+ (nullable NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError **)error;
```

```
/**
 * 将合格的NSData 转换为 NSArray，或者 NSDictionary
 **/
 
+ (nullable id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;
```


----------

>1、 `NSJSONSerialization` 实现了符合`json`格式的 `NSDictionary`，`NSArray` 和 `NSData`之间转换，而`NSData`可以直接转化为`NSString` 或者 从文件中读写


>  2、在选择持久化方案时，系统提供的`NSJSONSerialization`比`NSKeyedArchiver`更优

