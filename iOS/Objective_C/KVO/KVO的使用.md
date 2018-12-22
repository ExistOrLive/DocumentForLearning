# KVO

> KVO 是一种方法回调机制，在某个对象注册观察者后，在被观察对象发生变化时，对象会发出一个通知给观察者，以便观察者回调方法。

## KVO 的回调

```
#import <Foundation/NSKeyValueObserving.h>

/**
 *  KVO 的回调
 *  
 *
 **/
@interface NSObject(NSKeyValueObserving)

- (void)observeValueForKeyPath:(nullable NSString *)keyPath 
                      ofObject:(nullable id)object 
                        change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change 
                       context:(nullable void *)context;

@end


```

## KVO的注册和注销

```
/**
 * 
 * 对于发非NSArray，NSSet，NSOrderedSet
 **/

@interface NSObject(NSKeyValueObserverRegistration)

- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
```

