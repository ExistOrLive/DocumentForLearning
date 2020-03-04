# OCLint

> 在ios开发过程中，我们使用Clang这个前端编译工具，将OC代码输出为抽象语法树，然后编译成LLVM的bitcode，最后再编译成machine code。OCLint就是基于Clang实现的通过检查C,C++和Objective-C代码来提高代码质量、降低错误率的静态代码分析工具，代码通过OCLint检测后，可以发现一些潜在的问题。OCLint检测依赖源代码的抽象语法树来保证精准度和效率，尽可能减少误报，同时动态加载规则到系统中进行检测


## OCLint 安装

```
brew install oclint
```

## OCLint 使用 

[OCLint的基础使用][1]

[OCLint官方文档][2]

[1]: https://www.jianshu.com/p/6868363b6072

[2]: http://oclint.org/