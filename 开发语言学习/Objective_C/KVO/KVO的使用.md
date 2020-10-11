# KVO

> KVO 是一种方法回调机制，在某个对象注册观察者后，在被观察对象发生变化时，对象会发出一个通知给观察者，以便观察者回调方法。

## KVO的注册和注销

> 观察者的注册调用`addObserver:forKeyPath:options:context:`方法，其中option有4个选项：
- **NSKeyValueObservingOptionNew**
  在通知的change字典中包含key： new ，表示变更后的值

  ![NSKeyValueObservingOptionNew_code][1]

  ![NSKeyValueObservingOptionNew][2]

- **NSKeyValueObservingOptionOld**
  在通知的change字典中包含key： old ，表示变更前的值

  ![NSKeyValueObservingOptionOld_code][3]

  ![NSKeyValueObservingOptionOld][4]

- **NSKeyValueObservingOptionInitial**
  在注册观察者时发出一个通知，表示被观察的值value的注册时的初始值

  ![NSKeyValueObservingOptionInitial_code][5]

  ![NSKeyValueObservingOptionInitial][6]

- **NSKeyValueObservingOptionPrior**
  在被观察的值value改变前增加一次通知，在通知的change字典中包含key： notificationIsPrior 

  ![NSKeyValueObservingOptionPrior_code][7]

  ![NSKeyValueObservingOptionPrior][8]

```
/**
 * 
 * 对于发非NSArray，NSSet，NSOrderedSet
 **/

@interface NSObject(NSKeyValueObserverRegistration)

/**
 *  为对象添加观察者
 *  
 *
 **/
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(nullable void *)context;


- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context API_AVAILABLE(macos(10.7), ios(5.0), watchos(2.0), tvos(9.0));


- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
```

----

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

> 对于KVO的回调，我们主要关注`change`参数，这是一个字典，key为`NSKeyValueChangeKey`类型，主要有以下几种：

- **NSKeyValueChangeKindKey**
  
  对应value为NSKeyValueChange类型， 一般为NSKeyValueChangeSettig
- **NSKeyValueChangeNewKey**

- **NSKeyValueChangeOldKey**

- **NSKeyValueChangeIndexesKey**

- **NSKeyValueChangeNotificationIsPriorKey**

----

## NSArray，NSOrderedSet，NSSet的KVO

> NSArrays,NSSets and NSOrderedSets are not observable, so these methods raise exceptions when invoked on them. Instead of observing an array, observe the ordered to-many relationship for which the array is the collection of related objects.

**`NSArray`,`NSOrderSet`,`NSSet` 是不可以被观察的，直接添加会报以下错误：**

![NSArray_AddObserver][9]

![Exception][10]

**`NSArray`,`NSOrderSet`,`NSSet` 不可以直接被观察，但是可以通过KVC间接观察**

如下图所示，通过KVC的`mutableArrayValueForKey:`获取数组，实际获取出的类型为`NSKeyValueNotifyingMutableArray`，在这个数组添加删除元素就可以正常地观察了。

![NSKeyValueNotifyingMutableArray][11]

**但是`NSArray`可以观察它的元素**

```
- (void)addObserver:(NSObject *)observer 
 toObjectsAtIndexes:(NSIndexSet *)indexes 
         forKeyPath:(NSString *)keyPath 
            options:(NSKeyValueObservingOptions)options
            context:(nullable void *)context;

- (void)removeObserver:(NSObject *)observer 
  fromObjectsAtIndexes:(NSIndexSet *)indexes 
            forKeyPath:(NSString *)keyPath 
               context:(nullable void *)context;

- (void)removeObserver:(NSObject *)observer 
  fromObjectsAtIndexes:(NSIndexSet *)indexes 
            forKeyPath:(NSString *)keyPath;

```

----

## KVO的通知 

> KVO 可以不自动发通知，而可以通过编程发出通知

```
@interface NSObject(NSKeyValueObservingCustomization)

/**
 * 通过重写，可以修改观察者实际观察的keypath
 * 
 **/
+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key;

/**
  *
  * 通过重写，可以关闭kvo自动发出的通知
  **/
+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key;


@property (nullable) void *observationInfo NS_RETURNS_INNER_POINTER;

@end

```

```
/**
 * 通过以下方法可以手动发出KVO通知
 * 
 **/
@interface NSObject(NSKeyValueObserverNotification)

- (void)willChangeValueForKey:(NSString *)key;
- (void)didChangeValueForKey:(NSString *)key;

- (void)willChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;
- (void)didChange:(NSKeyValueChange)changeKind valuesAtIndexes:(NSIndexSet *)indexes forKey:(NSString *)key;

- (void)willChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;
- (void)didChangeValueForKey:(NSString *)key withSetMutation:(NSKeyValueSetMutationKind)mutationKind usingObjects:(NSSet *)objects;

@end

```




[1]: pic/NSKeyValueObservingOptionNew_Code.png
[2]: pic/NSKeyValueObservingOptionNew_Result.png
[3]: pic/NSKeyValueObservingOptionOld_Code.png
[4]: pic/NSKeyValueObservingOptionOld_Result.png
[5]: pic/NSKeyValueObservingOptionInitial_Code.png
[6]: pic/NSKeyValueObservingOptionInitial_Result.png
[7]: pic/NSKeyValueObservingOptionPrior_Code.png
[8]: pic/NSKeyValueObservingOptionPrior_Result.png
[9]: pic/NSArray_AddObserver.png
[10]: pic/exception1.png
[11]: pic/NSKeyValueNotifyingMutableArray.png