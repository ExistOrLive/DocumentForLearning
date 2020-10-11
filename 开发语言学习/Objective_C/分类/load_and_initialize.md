
## `+(void)load `


> 在iOS系统中，应用程序在启动时会加载所有的类以及分类，这个时候回去调用类及分类的 `+ (void) load` 方法。

> 子类的 +load 方法会在它所有父类的 +load 方法之后执行，而分类的 +load 方法会在它的主类的 +load 方法之后执行。但不同的类之间的 +load 方法的调用顺序是不确定的

> 如果一个类的多个分类都实现了load方法，这些load方法都会执行，但是执行的顺序不能确定。

#### Tip：

> 由于不同的类之间的 +load 方法的调用顺序是不确定的，即执行 +load 方法的过程中，有的类被加载进运行时，有的类没有被加载，这些都是无法确定的，所以这个时候runtime处于一个脆弱状态，绝对不能够在load方法中调用其他类的方法或属性

> +load 方法不遵循继承规则，每个超类，子类，分类中的+load 方法都是独立的，没有任何的继承关系。一个类中如果没有实现+load 方法，是不会去调用+load 方法的，即便它的超类实现了+load 方法，也不会调用

> 在应用程序执行+load 方法时，整个程序都会被阻塞。因此不要在+load 方法执行耗时操作，加锁

## `+(void) initialize`

> +initialize 方法在类或者子类接收到第一条消息的时候被调用。因此+initialize 方法是惰性调用的，没有用到这个类是不会调用的

> 调用子类的+initialize 方法之前会调用父类的+initialize 方法。


> 在执行+initialize 方法的过程中，可以安全地调用任意类的方法。而且运行期系统也能确保+initialize 方法一定会在“`线程安全的环境`”中执行，这就是说，只有执行+initialize的那个线程可以操作类或类实例，其他线程都要阻塞等着+initialize执行完。

> +initialize 遵循继承规则，子类中没有实现+initialize，会去调用父类的+initialize

## 要点

- load 和 initialize 方法都应该实现的精简一些，有助于保持应用的响应能力，能够减少引入依赖环的几率

- 无法在编译期设定的全局变量，静态变量，可以在initialize中初始化

```
@interface Test:NSObject

@end

// 可以在编译期初始化
static int a = 1;

// 无法在编译期初始化
static NSMutableArray * array; 

@implementation Test

+ (void) initialize
{
    // 保证仅在Test而不是Test子类初始化时，执行方法
    if(self == [Test class]) 
    {
        array = [NSMutableArray new];
    }
}

@end

```







