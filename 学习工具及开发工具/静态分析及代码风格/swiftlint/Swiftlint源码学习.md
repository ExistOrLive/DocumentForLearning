
# Swiftlint源码学习
#swiftlint 
#开源库

[Swiftlint](https://github.com/realm/SwiftLint) 是统一Swift代码风格的工具，本身就是使用Swift语言编写。Swiftlint 使用 [Swift_Package_Manager](../../../开发环境搭建/Swift开发环境/Swift_Package_Manager/Swift_Package_Manager.md)来组织源代码，可以直接用 Xcode打开。

![](https://pic.existorlive.cn//202309070142316.png)

## 1. 项目结构
### 1.1  Package.swift
**产物**

- swiftlint 可执行文件
- SwiftLintFramework 库 

**依赖**

- [swift-argument-parser](https://github.com/apple/swift-argument-parser.git)
      swift命令行的脚手架工具，用于使用swift快速创建命令行工具 
- [SwiftSyntax](https://github.com/apple/swift-syntax.git)
      允许 Swift 工具解析、检查、生成和转换 Swift 源代码。
- [SourceKitten](https://github.com/jpsim/SourceKitten.git)
     用于和SourceKit进行交互的工具
- [Yams](https://github.com/jpsim/Yams.git)
    解析yaml格式的工具
- [SwiftyTextTable](https://github.com/scottrhoyt/SwiftyTextTable.git)
    生成文本格式表格的工具

关于Swift Package Manager 请参考 

[Using the Package Manager](https://www.swift.org/getting-started/#using-the-package-manager)

[Package Manager](https://www.swift.org/package-manager/)

[PackageDescription](https://docs.swift.org/package-manager/PackageDescription/PackageDescription.html)

###  1.2 代码结构

```sh
- swiftlint
   - main 
   - Commands                  // 命令的定义 
   - Extensions
   - Helpers 
      - LintOrAnalyzeCommand   // 对主流程的封装(查找swift文件，读取规则的配置，调用rule的检查方法)

- SwiftLintFramework
   - Rules                     // rule的定义
   - Documentation
   - Reporters                
   - Protocols
   - Models
   - Helpers
   - Extensions
```

## 2. SwiftLint的lint流程

```swift
// 1. 命令的解析 
// 2. 查询出所有的Swift文件，及文件对应的Swiftlint规格及配置
// 3. 利用规则扫描swift文件
// 4. 输出表格 

swiflint lint  

```

1.  命令的解析 

```swift
// ParsableCommand.run()
Lint.Run()
```
      
```swift
struct LintOrAnalyzeOptions {
    let mode: LintOrAnalyzeMode
    let paths: [String]
    let useSTDIN: Bool
    let configurationFiles: [String]
    let strict: Bool
    let lenient: Bool
    let forceExclude: Bool
    let useExcludingByPrefix: Bool
    let useScriptInputFiles: Bool
    let benchmark: Bool
    let reporter: String?
    let quiet: Bool
    let cachePath: String?
    let ignoreCache: Bool
    let enableAllRules: Bool
    let autocorrect: Bool
    let format: Bool
    let compilerLogPath: String?
    let compileCommands: String?
    let inProcessSourcekit: Bool
} 
```
2. 查询出所有的Swift文件，及文件对应的Swiftlint配置及规则， 返回 `[CollectedLinter]`

```swift
LintOrAnalyzeCommand.run(_ options: LintOrAnalyzeOptions)
```

```swift
public struct CollectedLinter {
    /// The file to lint with this linter.
    public let file: SwiftLintFile
    private let rules: [Rule]
    private let cache: LinterCache?
    private let configuration: Configuration
    private let compilerArguments: [String]
}
```

3. 利用规则扫描swift文件, 返回  `[StyleViolation]`

```swift
Rules.validate(file: SwiftLintFile) -> [StyleViolation]
```

```swift
public struct StyleViolation: CustomStringConvertible, Equatable, Codable {
    /// The identifier of the rule that generated this violation.
    public let ruleIdentifier: String

    /// The description of the rule that generated this violation.
    public let ruleDescription: String

    /// The name of the rule that generated this violation.
    public let ruleName: String

    /// The severity of this violation.
    public private(set) var severity: ViolationSeverity

    /// The location of this violation.
    public private(set) var location: Location

    /// The justification for this violation.
    public let reason: String

    /// A printable description for this violation.
    public var description: String {
        return XcodeReporter.generateForSingleViolation(self)
    }
```

4. 按照指定格式输出表格

```swift
Reporter.report(violations: [StyleViolation], realtimeCondition: Bool)
```


## 3. Rule 

```swift 
/// An executable value that can identify issues (violations) in Swift source code.
public protocol Rule {

    static var description: RuleDescription { get }
    
    var configurationDescription: String { get }
    
    init()
    
    init(configuration: Any) throws

    func validate(file: SwiftLintFile, compilerArguments: [String]) -> [StyleViolation]

    func validate(file: SwiftLintFile) -> [StyleViolation]

    func isEqualTo(_ rule: Rule) -> Bool

    func collectInfo(for file: SwiftLintFile, into storage: RuleStorage, compilerArguments: [String])

    /// Executes the rule on a file after collecting file info for all files and returns any violations to the rule's
    /// expectations.
    ///
    /// - note: This function is called by the linter and is always implemented in extensions.
    ///
    /// - parameter file:              The file for which to execute the rule.
    /// - parameter storage:           The storage object containing all collected info.
    /// - parameter compilerArguments: The compiler arguments needed to compile this file.
    ///
    /// - returns: All style violations to the rule's expectations.
    func validate(file: SwiftLintFile, using storage: RuleStorage, compilerArguments: [String]) -> [StyleViolation]
}
```

### 3.1  SourceKitFreeRule
不需要AST抽象语法树，直接通过文本查询或正则匹配实现的Rule 

以 [LeadingWhitespaceRule](https://realm.github.io/SwiftLint/leading_whitespace.html) 为例：
```swift
public struct LeadingWhitespaceRule: CorrectableRule, ConfigurationProviderRule, SourceKitFreeRule {

    public func validate(file: SwiftLintFile) -> [StyleViolation] {
        let countOfLeadingWhitespace = file.contents.countOfLeadingCharacters(in: .whitespacesAndNewlines)
        if countOfLeadingWhitespace == 0 {
            return []
        }

        let reason = "File shouldn't start with whitespace: " +
                     "currently starts with \(countOfLeadingWhitespace) whitespace characters"

        return [StyleViolation(ruleDescription: Self.description,
                               severity: configuration.severity,
                               location: Location(file: file.path, line: 1),
                               reason: reason)]
    }
} 

 // 检查文件开头的空格数量 
    public func countOfLeadingCharacters(in characterSet: CharacterSet) -> Int {
        let characterSet = characterSet.bridge()
        var count = 0
        for char in utf16 {
            if !characterSet.characterIsMember(char) {
                break
            }
            count += 1
        }
        return count
    }
```

###  3.2 ASTRule
需要抽象语法树配合的Rule, 抽象语法树通过sourcekit来获取 

以 [ArrayInitRule](https://realm.github.io/SwiftLint/array_init.html) 为例：

```swift 
import Foundation

let array = [1,2,3]

let array2 = array.map { return $0 }
```

通过 `sourcekitten structure --file main.swift`获取AST

```json
{
  "key.diagnostic_stage" : "source.diagnostic.stage.swift.parse",
  "key.length" : 74,
  "key.offset" : 0,
  "key.substructure" : [
    {
      "key.accessibility" : "source.lang.swift.accessibility.internal",
      "key.kind" : "source.lang.swift.decl.var.global",
      "key.length" : 19,
      "key.name" : "array",
      "key.namelength" : 5,
      "key.nameoffset" : 23,
      "key.offset" : 19
    },
    {
      "key.bodylength" : 5,
      "key.bodyoffset" : 32,
      "key.elements" : [
        {
          "key.kind" : "source.lang.swift.structure.elem.expr",
          "key.length" : 1,
          "key.offset" : 32
        },
        {
          "key.kind" : "source.lang.swift.structure.elem.expr",
          "key.length" : 1,
          "key.offset" : 34
        },
        {
          "key.kind" : "source.lang.swift.structure.elem.expr",
          "key.length" : 1,
          "key.offset" : 36
        }
      ],
      "key.kind" : "source.lang.swift.expr.array",
      "key.length" : 7,
      "key.namelength" : 0,
      "key.nameoffset" : 0,
      "key.offset" : 31
    },
    {
      "key.accessibility" : "source.lang.swift.accessibility.internal",
      "key.kind" : "source.lang.swift.decl.var.global",
      "key.length" : 29,
      "key.name" : "array2",
      "key.namelength" : 6,
      "key.nameoffset" : 44,
      "key.offset" : 40
    },
    {
      "key.bodylength" : 4,
      "key.bodyoffset" : 64,
      "key.kind" : "source.lang.swift.expr.call",
      "key.length" : 16,
      "key.name" : "array.map",
      "key.namelength" : 9,
      "key.nameoffset" : 53,
      "key.offset" : 53,
      "key.substructure" : [
        {
          "key.bodylength" : 4,
          "key.bodyoffset" : 64,
          "key.kind" : "source.lang.swift.expr.closure",
          "key.length" : 6,
          "key.namelength" : 0,
          "key.nameoffset" : 0,
          "key.offset" : 63,
          "key.substructure" : [
            {
              "key.bodylength" : 4,
              "key.bodyoffset" : 64,
              "key.kind" : "source.lang.swift.stmt.brace",
              "key.length" : 6,
              "key.namelength" : 0,
              "key.nameoffset" : 0,
              "key.offset" : 63
            }
          ]
        }
      ]
    }
}
```

通过 `sourcekitten syntax --file main.swift`获取Token list

```json
[
  {
    "length" : 6,
    "offset" : 0,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 10,
    "offset" : 7,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 3,
    "offset" : 19,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 5,
    "offset" : 23,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 1,
    "offset" : 32,
    "type" : "source.lang.swift.syntaxtype.number"
  },
  {
    "length" : 1,
    "offset" : 34,
    "type" : "source.lang.swift.syntaxtype.number"
  },
  {
    "length" : 1,
    "offset" : 36,
    "type" : "source.lang.swift.syntaxtype.number"
  },
  {
    "length" : 3,
    "offset" : 40,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 6,
    "offset" : 44,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 5,
    "offset" : 53,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 3,
    "offset" : 59,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 6,
    "offset" : 65,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 2,
    "offset" : 72,
    "type" : "source.lang.swift.syntaxtype.identifier"
  }
]
```

```swift

   // 结合抽象语法树进行分析 
  public func validate(file: SwiftLintFile, kind: SwiftExpressionKind,
                         dictionary: SourceKittenDictionary) -> [StyleViolation] {

        guard kind == .call, let name = dictionary.name, name.hasSuffix(".map"),
            let bodyOffset = dictionary.bodyOffset,
            let bodyLength = dictionary.bodyLength,
            let bodyRange = dictionary.bodyByteRange,
            let nameOffset = dictionary.nameOffset,
            let nameLength = dictionary.nameLength,
            let offset = dictionary.offset else {
                return []
        }

        let tokens = file.syntaxMap.tokens(inByteRange: bodyRange).filter { token in
            guard let kind = token.kind else {
                return false
            }

            return !SyntaxKind.commentKinds.contains(kind)
        }

        guard let firstToken = tokens.first,
            case let nameEndPosition = nameOffset + nameLength,
            isClosureParameter(firstToken: firstToken, nameEndPosition: nameEndPosition, file: file),
            isShortParameterStyleViolation(file: file, tokens: tokens) ||
            isParameterStyleViolation(file: file, dictionary: dictionary, tokens: tokens),
            let lastToken = tokens.last,
            case let bodyEndPosition = bodyOffset + bodyLength,
            !containsTrailingContent(lastToken: lastToken, bodyEndPosition: bodyEndPosition, file: file),
            !containsLeadingContent(tokens: tokens, bodyStartPosition: bodyOffset, file: file) else {
                return []
        }

        return [
            StyleViolation(ruleDescription: Self.description,
                           severity: configuration.severity,
                           location: Location(file: file, byteOffset: offset))
        ]
    }
```

### 3.3 AnalyzerRule
需要抽象语法树和编译日志配合的Rule, 抽象语法树通过sourcekit来获取 

以 [UnusedImportRule](https://realm.github.io/SwiftLint/unused_import.html) 为例：

```swift
import UIKit
import WebKit

class TestObject: NSObject {
    var a = 11
}
```

```json
[
  {
    "length" : 6,
    "offset" : 0,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 5,
    "offset" : 7,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 6,
    "offset" : 13,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 6,
    "offset" : 20,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 5,
    "offset" : 28,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 10,
    "offset" : 34,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 8,
    "offset" : 46,
    "type" : "source.lang.swift.syntaxtype.typeidentifier"
  },
  {
    "length" : 3,
    "offset" : 61,
    "type" : "source.lang.swift.syntaxtype.keyword"
  },
  {
    "length" : 1,
    "offset" : 65,
    "type" : "source.lang.swift.syntaxtype.identifier"
  },
  {
    "length" : 2,
    "offset" : 69,
    "type" : "source.lang.swift.syntaxtype.number"
  }
]
```


```swift
    func getImportsAndUSRFragments(compilerArguments: [String]) -> (imports: Set<String>, usrFragments: Set<String>) {
        var imports = Set<String>()
        var usrFragments = Set<String>()
        var nextIsModuleImport = false
        for token in syntaxMap.tokens {
            guard let tokenKind = token.kind else {
                continue
            }
            if tokenKind == .keyword, contents(for: token) == "import" {
                nextIsModuleImport = true
                continue
            }
            // 过滤掉没有模块信息的token 
            if SyntaxKind.kindsWithoutModuleInfo.contains(tokenKind) {
                continue
            }
            // 获取当前token对应的抽象语法树 
            let cursorInfoRequest = Request.cursorInfo(file: path!, offset: token.offset,
                                                       arguments: compilerArguments)
            guard let cursorInfo = (try? cursorInfoRequest.sendIfNotDisabled()).map(SourceKittenDictionary.init) else {
                queuedPrintError("Could not get cursor info")
                continue
            }
            if nextIsModuleImport {
                 // 通过语法树并获取当前文件的所有import 
                if let importedModule = cursorInfo.moduleName,
                    cursorInfo.kind == "source.lang.swift.ref.module" {
                    imports.insert(importedModule)
                    nextIsModuleImport = false
                    continue
                } else {
                    nextIsModuleImport = false
                }
            }
            // 获取使用的import 
            appendUsedImports(cursorInfo: cursorInfo, usrFragments: &usrFragments)
        }

        return (imports: imports, usrFragments: usrFragments)
    }


  func appendUsedImports(cursorInfo: SourceKittenDictionary, usrFragments: inout Set<String>) {
        if let rootModuleName = cursorInfo.moduleName?.split(separator: ".").first.map(String.init) {
            usrFragments.insert(rootModuleName)
            if rootModuleName == moduleToLog, let filePath = path, let usr = cursorInfo.value["key.usr"] as? String {
                queuedPrintError(
                    "[SWIFTLINT_LOG_MODULE_USAGE] \(rootModuleName) referenced by USR '\(usr)' in file '\(filePath)'"
                )
            }
        }
    }
```

## 4. SourceKit相关的工具
SourceKit 是一套工具集，使得大多数 Swift 源代码层面的操作特性得以支持，例如Xcode中的源代码解析、语法高亮、排版、自动补全、跨语言头文件生成等等。 [SourceKitten](https://github.com/jpsim/SourceKitten.git) 是与 SourceKit 后台进程进行交互的工具 ，基于 [SourceKitten](https://github.com/jpsim/SourceKitten.git) 还有很多开源工具

* [Jazzy](https://github.com/realm/Jazzy):   为Swift/OC生成文档
* [Sourcery](https://github.com/krzysztofzablocki/Sourcery): 生成模版代码 
* [SwiftyMocky](https://github.com/MakeAWishFoundation/SwiftyMocky): 生成Mock代码的框架
* [SourceKittenDaemon](https://github.com/terhechte/SourceKittenDaemon):  为任何文本编辑器提供swift代码补全
* [SourceDocs](https://github.com/eneko/SourceDocs):  从源码注释中生成Markdown文档的命令行工具
* [Cuckoo](https://github.com/Brightify/Cuckoo): Swift Mock 框架
* [IBAnalyzer](https://github.com/fastred/IBAnalyzer):  无需运行代码或单元测试发现xib或storyboard相关的问题


## 参考文档
[Swiftlint Github](https://github.com/realm/SwiftLint)

[Using the Package Manager](https://www.swift.org/getting-started/#using-the-package-manager)

[SourceKit](https://academy.realm.io/posts/appbuilders-jp-simard-sourcekit/)

