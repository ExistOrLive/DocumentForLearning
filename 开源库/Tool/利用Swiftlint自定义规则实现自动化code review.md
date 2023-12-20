#swiftlint 
#Swift 
#开源库 
SwiftLint 是一个用于检测 Swift 代码风格和一致性的开源工具。它能够自动化实现代码规范、保证代码风格的统一性，避免因为代码风格不同带来的维护问题，同时也能够提供一些代码质量上的反馈，帮助程序员编写更加规范、优雅的 Swift 代码。本文参考 [Release 0.52.4: Lid Switch · realm/SwiftLint ](https://github.com/realm/SwiftLint/releases/tag/0.52.4)

![](https://pic.existorlive.cn//202309070112391.png)

## 1. Swiftlint Lint的流程

```sh
swiftlint lint 
```

![](https://pic.existorlive.cn//202309070114495.jpg)

## 2. 2. SwiftLint Lint  规则

#### 2.1 规则类型
- **SourceKitFreeRule** ： 不需要AST抽象语法树，直接通过文本查询或正则匹配实现的Rule
       以 [LeadingWhitespaceRule](https://realm.github.io/SwiftLint/leading_whitespace.html) 为例：
- **ASTRule**： 需要抽象语法树配合的Rule, 抽象语法树通过sourcekit来获取
       以 [IdentifierNameRule](https://realm.github.io/SwiftLint/identifier_name.html) 为例
- **SwiftSyntaxRule**： 基于swift-syntax分析Swift源码的规则 
       以 [ArrayInitRule](https://realm.github.io/SwiftLint/array_init.html) 为例：
- **AnalyzerRule**： 需要抽象语法树和编译日志配合的Rule, 抽象语法树通过sourcekit来获取
      以 [UnusedImportRule](https://realm.github.io/SwiftLint/unused_import.html) 为例：
![](https://pic.existorlive.cn//202309070117944.jpg)

#### 2.2  SwiftSyntaxRule
**SwiftSyntaxRule** 继承于 Rule 协议，在扩展中实现了` func validate(file:)` 方法，执行了对语法树的遍历，在遍历过程中调用了 SwiftSyntaxRule 声明的三个方法 

```swift
/// A SwiftLint Rule backed by SwiftSyntax that does not use SourceKit requests.
public protocol SwiftSyntaxRule: SourceKitFreeRule {
    /// 返回语法遍历器
    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor

    /// 创建违规对象
    func makeViolation(file: SwiftLintFile, violation: ReasonedRuleViolation) -> StyleViolation

    /// 预处理语法树 
    func preprocess(file: SwiftLintFile) -> SourceFileSyntax?
}

public extension SwiftSyntaxRule {
  func validate(file: SwiftLintFile) -> [StyleViolation] {
        guard let syntaxTree = preprocess(file: file) else {
            return []
        }

        return makeVisitor(file: file)
            .walk(tree: syntaxTree, handler: \.violations)
            .sorted()
            .map { makeViolation(file: file, violation: $0) }
   }
}
```


**ViolationsSyntaxVisitor** 是语法树遍历器，每当访问某个语法节点时，都会调用**ViolationsSyntaxVisitor**的访问方法；不同的规则会定义不同的语法树遍历器，在语法树遍历器中实现对规则的检查； 以 **ArrayInitRule** 为例，派生 **ViolationsSyntaxVisitor** 重写 `func visitPost(_:)` 方法实现了规则检查的逻辑； 

```swift
extension ArrayInitRule {
    private final class Visitor: ViolationsSyntaxVisitor {
        override func visitPost(_ node: FunctionCallExprSyntax) {
            guard let memberAccess = node.calledExpression.as(MemberAccessExprSyntax.self),
                  memberAccess.name.text == "map",
                  let (closureParam, closureStatement) = node.singleClosure(),
                  closureStatement.returnsInput(closureParam)
            else {
                return
            }

            violations.append(memberAccess.name.positionAfterSkippingLeadingTrivia)
        }
    }
}
```

#### 2.3 ViolationsSyntaxVisitor /  SyntaxVisitor
```swift
/// A SwiftSyntax `SyntaxVisitor` that produces absolute positions where violations should be reported.
open class ViolationsSyntaxVisitor: SyntaxVisitor {
    /// 收集的违规对象
    public var violations: [ReasonedRuleViolation] = []
    /// 需要跳过的声明语法节点
    open var skippableDeclarations: [DeclSyntaxProtocol.Type] { [] }
    /// 执行语法树遍历，并返回违规对象 
    func walk<T, SyntaxType: SyntaxProtocol>(tree: SyntaxType, handler: (Self) -> T) -> T 
}

/// Swift-Syntax 中定义的语法树遍历器 
open class SyntaxVisitor {

  public let viewMode: SyntaxTreeViewMode
     
  /// 执行对传入语法树的遍历
  public func walk<SyntaxType: SyntaxProtocol>(_ node: SyntaxType)
 
  /// 访问某个语法节点前调用
  open func visit(_ node: T) -> SyntaxVisitorContinueKind 
  
  /// 访问语法节点之后调用 
  open func visitPost(_ node: T) 
}
```

实现一个基于 Swift-Syntax  的自定义规则，最主要的工作就是重写 `SyntaxVisitor 的 visit(_:)` 和 `visitPost(_ :)` 方法，通过传入的语法节点对象（`Syntax`）获取需要的信息，执行规则检查； 

在正式编写自定义规则之前，还需要了解 Swift-Syntax 中定义的各种语法节点类型。

## 3. Swift-Syntax 

 [swift-syntax](https://github.com/apple/swift-syntax) 是苹果官方提供的，用于 解析、检查、生成和转换 Swift 源代码的Swift库。本文参考 [GitHub - apple/swift-syntax at swift-DEVELOPMENT-SNAPSHOT-2023-07-04-a](https://github.com/apple/swift-syntax/tree/swift-DEVELOPMENT-SNAPSHOT-2023-07-04-a)
 
#### 3.1 Swift-Syntax 语法节点类图

![](https://pic.existorlive.cn//202309070124842.jpg)

#### 3.2 Syntax

**Syntax** 表示一个通用的语法节点，也就是访问方法 `visit` 的入参。
**Syntax** 提供了语法节点的通用操作，如获取子节点，父节点；查询节点类型等 

```swift
/// A Syntax node represents a tree of nodes with tokens at the leaves.
/// Each node has accessors for its known children, and allows efficient
/// iteration over the children through its `children` property.
public struct Syntax: SyntaxProtocol, SyntaxHashable {
  let data: SyntaxData
  
   public var _syntaxNode: Syntax {
    return self
  }
  
  /// 节点类型 
  public var kind: SyntaxKind {
    return raw.kind
  }
  
  /// 字节点 
  func children(viewMode: SyntaxTreeViewMode) -> SyntaxChildren {
    return SyntaxChildren(_syntaxNode, viewMode: viewMode)
  }
  
  /// 父节点 
 var parent: Syntax? {
    return data.parent.map(Syntax.init(_:))
  }
}
```


#### 3.3 节点类型

**SyntaxKind** 中定义了 274 种语法节点类型，并为不同语法节点类型定义了类，如 `VariableDeclSyntax` , `ArrayElementSyntax`，类中定义了特定语法节点的特有方法。

```swift
/// 语法节点类型
public enum SyntaxKind {
  case token
  case accessPathComponent
  case accessPath
  case accessesEffect
  case accessorBlock
  case accessorDecl
  case accessorEffectSpecifiers
  case accessorInitEffects
  case accessorList
  case accessorParameter
  case actorDecl
  case arrayElementList
  case arrayElement
  case arrayExpr
  case arrayType
  case arrowExpr
  case asExpr
  case assignmentExpr
  case associatedtypeDecl
  case attributeList
  case attribute
  case attributedType
  case availabilityArgument
  case availabilityCondition
  ......
}
```

```swift
/// 变量声明 语法 
public struct VariableDeclSyntax: DeclSyntaxProtocol, SyntaxHashable { 

/// 获取 属性 @objc
public var attributes: AttributeListSyntax? 

/// 获取修饰符 public lazy 等 
public var modifiers: ModifierListSyntax?

.... 
}
```

#### 3.4 Swift AST Explorer 
在 [Swift AST Explorer](https://swift-ast-explorer.com/) 工具中，可以直观地看到源码的语法树，辅助我们开发自定义的Swiftlint 规则

![](https://pic.existorlive.cn//202309070128442.png)

## 4. 编写自定义规则
以代码中经常使用的数组下标访问代码为例，在我司推荐使用安全访问方法 `array[safe: index]`，这个方法可以规避数组越界导致的闪退问题 ; 针对这种情况，我们定义规则如下：
在未使用数组的安全下标访问方法将会告警；

```swift
import SwiftSyntax

struct DuSafeSubscriptRule:ConfigurationProviderRule, SwiftSyntaxRule {

    var configuration = SeverityConfiguration<Self>(.warning)

    static let description = RuleDescription(
        identifier: "Du_Safe_Subscript_Rule",
        name: "Safe Subscript Rule",
        description: "Swift中通过subscript访问数组元素，都要使用[safe:]",
        kind: .lint,
        nonTriggeringExamples: [
            Example("array[safe:1]")
        ],
        triggeringExamples: [
            Example("array[1]\n")
        ]
    )

    func makeVisitor(file: SwiftLintFile) -> ViolationsSyntaxVisitor {
        Visitor(viewMode: .sourceAccurate)
    }
}
```

通过 [Swift AST Explorer](https://swift-ast-explorer.com/)  工具，可以看到数组下标访问的节点类型为 **SubscriptExpr**，这样我们就需要重写 **SubscriptExprSyntax** 相关的 `visit` 方法。
![](https://pic.existorlive.cn//202309070203992.png)

在 `func visitPost(_ node: SubscriptExprSyntax)` 方法中，获取下标表达式的参数列表，如果参数中不包含 **safe:** 则不符合规则

```swift
final class Visitor: ViolationsSyntaxVisitor { 
   
override func visit(_ node: SubscriptExprSyntax) -> SyntaxVisitorContinueKind {
   return .visitChildren
}


override func visitPost(_ node: SubscriptExprSyntax) {
     var hasSafe = false
           
     if node.argumentList.count > 1 || node.argumentList.isEmpty {
         return
     } else if let firstArgument = node.argumentList.first {
         if firstArgument.label?.text == "safe" && firstArgument.colon?.text == ":" {
             /// 使用了safe
             hasSafe = true
         }
     }
     
     if !hasSafe {
     /// 未使用 safe， 则添加违规信息
         violations.append(node.position)
     }
}
  
}
```

在Xcode中集成后： 

![](https://pic.existorlive.cn//202309070133156.png)

## 5. 自动化Code Review 

1. 根据质量左移原则，在代码编译阶段的就进行代码扫描，尽早发现代码问题是最好的方式；在Xcode中集成Swiftlint检查工具，在开发阶段做检查和修改
2. 开发Swiftlint自定义规则，对开发中常用的CR规则做检查
3. 开发阶段做弱规则检查
4. 在发起PR后触发CI构建，构建过程中做强规则检查，避免不符合规则的代码被提交
![](https://pic.existorlive.cn//202309070136437.jpg)

## 参考文档

[Swiftlint源码学习](Swiftlint源码学习.md)

[GitHub - realm/SwiftLint: A tool to enforce Swift style and conventions.](https://github.com/realm/SwiftLint)

[GitHub - apple/swift-syntax: A set of Swift libraries for parsing, inspecting, generating, and trans](https://github.com/apple/swift-syntax)
