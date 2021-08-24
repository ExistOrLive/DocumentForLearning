# Swift底层结构


```swift
class LGTeacher {
    var name : String = "dasda"
    var age : Int = 11
    var subject : String = "Math"
    var sex : LGSex = .male
}

struct LGStudent{
    var name : String = "dasda"
    var age : Int = 11
    var sex : LGSex = .male
}

enum LGSex{
    case male
    case female
}

enum Result{
    case success(statusCode : Int)
    case fail(statusCode : Int, error : String)
    case unknown
}
```

## 1. 对象的结构

### Class类型对象的结构

Class类型对象在底层的实现为 **HeapObject**

```swift
#define SWIFT_HEAPOBJECT_NON_OBJC_MEMBERS       \
  InlineRefCounts refCounts

struct HeapObject {
  /// This is always a valid pointer to a metadata object.
  HeapMetadata const *metadata;

  SWIFT_HEAPOBJECT_NON_OBJC_MEMBERS;
}
```

包含两个基本的字段：

- **HeapMetadata * metadata** ： 8字节
    
      metadata 指向描述Class类型信息的内存

- **InlineRefCount refCounts** ： 8字节

      保存了引用计数的信息
  
   
### Struct类型对象的结构

不同于**Class**类型的对象，**Struct**类型对象只包含定义的存储属性，不包含`metadata` 或者 `refCounts`。


### Enum类型对象的结构

**Enum**类型对象和**Struct**类型对象一样，不包含`metadata` 或者 `refCounts`。

**Enum**类型不可以定义存储属性，因此**Enum**类型对象会存储**枚举值**以及**关联值**

**枚举值**按照需求占用内存，不超过256个枚举值，则占用1字节;否则占用2字节或者更多

不同的枚举值关联值所需的内存不同，按照最多的来计算

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/Low_Level_Structure_Object.png)

输出以上`LGTeacher`,`LGStudent`,`LGSex`,`Result`的内存占用：

```swift
// 对象的内存占用
print("class LGTeacher : \(class_getInstanceSize(LGTeacher.self))")

print("struct LGStudent Size : \(MemoryLayout<LGStudent>.size)")
print("struct LGStudent Stride : \(MemoryLayout<LGStudent>.stride)")

print("enum LGSex Size : \(MemoryLayout<LGSex>.size)")
print("enum LGSex Stride : \(MemoryLayout<LGSex>.stride)")

print("enum Result Size : \(MemoryLayout<Result>.size)")
print("enum Result Stride : \(MemoryLayout<Result>.stride)")
```

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-08-12%20%E4%B8%8B%E5%8D%888.40.11.png)

```swift
var teacher = LGTeacher()
var student = LGStudent()
var sex = LGSex.female
var result = Result.fail(statusCode: 408, error: "超时")

let teacherPtr = Unmanaged.passUnretained(teacher).toOpaque()
let studentPtr = withUnsafePointer(to: &student) { $0}
let sexPtr = withUnsafePointer(to: &sex) { $0}
let resultPtr = withUnsafePointer(to: &result) { $0}
```
![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-08-12%20%E4%B8%8B%E5%8D%889.12.27.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-08-12%20%E4%B8%8B%E5%8D%889.13.17.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-08-12%20%E4%B8%8B%E5%8D%889.13.46.png)

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-08-12%20%E4%B8%8B%E5%8D%889.15.36.png)

## 2. Metadata的结构

**Metadata**保存了类型的元信息，包括类型名，字段等信息。**Class** 类型的实例的前8字节保存就是的 **Metadata** 的地址。

`type(of:)`可以用于获取某个实例的**Metadata**

`类名.self`可以直接获取某个类型的**Metadata**

**Metadata**的大致结构如下：具体的结构以及继承关系请查看**Swift源码 Metadata.h**

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/MetaData_Structure.png)


###  `ClassMetadata`

**Swift** 为了能够与 **Objetive-C** 混合编程，**ClassMetadata** 是兼容 **objc_class_t** 的。`kind`，`superClass`,`Cachedata`,`Data`等字段与**objc_class_t** 的结构对应。

在 **libObjc** 中，提供了 **swift_class_t** 类型，继承于 **objc_class**。用于在 **Objc Runtime** 中 使用 **Swift**中定义的类型。

```swift
// obj4.818.2
struct swift_class_t : objc_class {
    uint32_t flags;
    uint32_t instanceAddressOffset;
    uint32_t instanceSize;
    uint16_t instanceAlignMask;
    uint16_t reserved;

    uint32_t classSize;
    uint32_t classAddressOffset;
    void *description;
    // ...

    void *baseAddress() {
        return (void *)((uint8_t *)this - classAddressOffset);
    }
};
```

### `kind`和`Description`

所有的`Metadata`结构都包含两个基本的字段：

- `kind` ：`MetadataKind` 保存了基本的类型：**Class**，**Struct**，**Enum**还是其他类型

name|value
-|-
Class|0x0
Struct|0x200
Enum|0x201
Optional|0x202
ForeignClass|0x203
Opaque|0x300
Tuple|0x301
Function|0x302
Existential|0x303
Metatype|0x304
ObjcClassWrapper|0x305
ExistentialMetatype|0x306
HeapLocalvariable|0x400
HeapGenericLoclVariable|0x500
ErrorObject|0x501
LastEnumerated|0x7FF


- `Description` ：保存了类型的具体信息，包括类型名，字段偏移等（`ClassDescriptor`/`StructDescriptor`/`EnumDescriptor`）

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/%E6%88%AA%E5%B1%8F2021-08-22%20%E4%B8%8B%E5%8D%884.17.54.png)



## 3. Description

**Metadata**的 **Description** 字段保存了类型的具体信息。

**ClassMetadata**对应**ClassDescriptor**

**StructMetadata**对应**StructDescriptor**

**EnumMetadata**对应**EnumDescriptor**

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/Descriptor1.png)

- `Name` 保存类型的名字
  
- `Fields` 保存字段的信息： `FieldDescriptor`

- `AccessFuncitonPtr`:

- `NumFields`： 字段的数量

## 4. FieldDescriptor

`FieldDescriptor` 中保存了字段的信息。

每一个字段都有一个`FieldRecord`对应，`FieldRecord`中保存了字段的名字和偏移量。

`FieldRecord`保存在紧接着`FieldDescriptor`的一块连续内存中。

![](https://gitee.com/existorlive/exist-or-live-pic/raw/master/FieldDescriptor.png)




