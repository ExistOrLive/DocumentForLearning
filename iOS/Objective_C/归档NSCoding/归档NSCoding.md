# 归档

> iOS系统中数据持久化方式有keychain，NSUserDefaults，沙盒文件以及Sqlite数据库，但是这些方式只能直接保存基本数据类型以及NSString，NSNumber，NSData等特殊类型对象，`对于自定义类型无法却直接持久化`。 

> OC中可以通过归档的方式将自定类型的对象转换为NSData，然后在进行数据的持久化


## NSCoding/NSSecureCoding

> 只有实现了NSCoding或者NSSecureCoding(更加安全)协议的类型，才可以归档。如NSString，NSNumber都实现了NSSecureCoding。


```Objc

@protocol NSCoding

- (void)encodeWithCoder:(NSCoder *)coder;
- (nullable instancetype)initWithCoder:(NSCoder *)coder; // NS_DESIGNATED_INITIALIZER

@end


@protocol NSSecureCoding <NSCoding>
@required
// This property must return YES on all classes that allow secure coding. Subclasses of classes that adopt NSSecureCoding and override initWithCoder: must also override this method and return YES.
// The Secure Coding Guide should be consulted when writing methods that decode data.
@property (class, readonly) BOOL supportsSecureCoding;
@end

```


### Example

```Objc


- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:_bar forKey:kBar];
    [aCoder encodeFloat:_baz forKey:kBaz];
}
 
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    if (self = [super init]) {
        self.bar = [aDecoder decodeObjectForKey:kBar];
        self.baz = [aDecoder decodeFloatForKey:kBaz];
    }
    return self;
}
 
+ (BOOL)supportsSecureCoding
{
    return YES;
}



```


## NSKeyedArchiver/NSKeyedUnArchiver


NSKeyedArchiver 使用这两个方法将对象归档为NSData

```objc
+ (NSData *)archivedDataWithRootObject:(id)rootObject API_DEPRECATED("Use +archivedDataWithRootObject:requiringSecureCoding:error: instead", macosx(10.2,10.14), ios(2.0,12.0), watchos(2.0,5.0), tvos(9.0,12.0));

+ (nullable NSData *)archivedDataWithRootObject:(id)object requiringSecureCoding:(BOOL)requiresSecureCoding error:(NSError **)error API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0));

```

NSKeyedUnArchiver 使用以下方法使用NSData的反序列化

```objc
+ (nullable id)unarchiveObjectWithData:(NSData *)data API_DEPRECATED("Use +unarchivedObjectOfClass:fromData:error: instead", macosx(10.2,10.14), ios(2.0,12.0), watchos(2.0,5.0), tvos(9.0,12.0));

+ (nullable id)unarchivedObjectOfClass:(Class)cls fromData:(NSData *)data error:(NSError **)error API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)) NS_REFINED_FOR_SWIFT;

```


## 使用Runtime实现NSCoding的基类

> 利用`class_copyIvarList`获取

```objc

//序列化
-(void)encodeWithCoder:(NSCoder *)aCoder{
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *ivar_name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

//反序列化
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        unsigned int ivarCount = 0;
        Ivar *ivars = class_copyIvarList([self class], &ivarCount);
        for (unsigned int i = 0; i < ivarCount; i++) {
            const char *ivar_name = ivar_getName(ivars[i]);
            NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
            [self setValue:[coder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    id model = [[[self class] allocWithZone:zone] init];
    
    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList([self class], &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        const char *ivar_name = ivar_getName(ivars[i]);
        NSString *key = [NSString stringWithCString:ivar_name encoding:NSUTF8StringEncoding];
        [model setValue:[self valueForKey:key] forKey:key];
    }
    
    return model;
}


```
