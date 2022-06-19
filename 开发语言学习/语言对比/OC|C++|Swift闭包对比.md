# OC/C++/Swift闭包对比

**闭包** 是能够捕获定义上下文中的变量或常量引用的可调用对象。可以在代码中传递和调用。

不同语言中也有相似的实现：

- Swift闭包表达式
```swift
{ [capture list](parameter list) -> return type in 
    
}


let a = 11
let b = "Hello World"

let block = { () -> String in
    var c = ""
    for _ in 1...11 {
        c += b
    }
    return c
}
```

- OC Block
```objective-c
return type ^(parameter list) {
     body
}

int a = 11;
NSString *b = @"Hello World";

NSString* (^block)(void) = ^{
	NSMutableString *c = [[NSMutableString alloc] init];
	for(int i = 0; i < a; i++) {
		[c appendString:b];
	}
	return c;
};

```

- C++ lambda表达式
```c++
[capture list](parameter list) -> return type {
    body
}


int a = 11;
string b = "Hello World";

auto lambda = [a, &b](const string & c) -> string {
	string result = b;

	for(int i = 0; i < a ; i++){
		result.append(c);
	}

	return result;
};


```


## 1. 使用上的差异

- C++中lambda表达式
    
  - lambda表达式支持值捕获和引用捕获
  
  - 值捕获默认不可以修改，但是将`lambda`声明为`mutable`支持修改；引用捕获能够修改取决于是否为常量
  
  - C++中lambda表达式是值类型
 
  - 底层实现是重载调用运算符的匿名类的匿名对象；捕获的变量是匿名类的数据成员；函数实现就是重载调用运算符函数
   

- OC中的Block

   - Block表达式支持值捕获，和`__block`捕获
   - 值捕获的值不可以修改；`__block`捕获可以修改
   - Block是引用类型
   - 底层实现是匿名OC类的匿名对象，函数实现保存在匿名类中的成员函数指针中；捕获的变量是匿名类的属性

- Swift中的闭包

   -  闭包中都是引用捕获
   -  捕获的值能够修改取决于是否为常量
   -  闭包是引用类型

## 2. 底层实现的差异

C++ : 底层实现是重载调用运算符的匿名类的匿名对象；捕获的变量是匿名类的数据成员；函数实现就是重载调用运算符函数

```c++
class lambda{

private:
    
    int a;
    string &b;        // 捕获变量生成相应的数据成员

public:

    lambda(int a, string &b):a(a),b(b){}  // 生成初始化捕获变量的构造函数

    string operator() (const string &c) const {  // 重载函数调用运算符
        string result = b;

        for(int i = 0; i < a ; i++){
            result.append(c);
        }

        return result;
    }

}

```

OC Block的底层实现为 `Block_layout` 结构体

```C
struct Block_layout {
    void * __ptrauth_objc_isa_pointer isa;
    volatile int32_t flags; // contains ref count
    int32_t reserved;
    // 函数指针
    BlockInvokeFunction invoke;
    struct Block_descriptor_1 *descriptor;
    
    // imported variables
    int a;
    NSString * __strong b;
};

static NSString * BlockInvokeFunction(struct Block_layout * self) {
    int a = self->a;
    NSString * b = self->b;

    NSMutableString *c = [[NSMutableString alloc] init];
	for(int i = 0; i < a; i++) {
		[c appendString:b];
	}
