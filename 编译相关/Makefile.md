# Makefile
#Makefile
#编译

**Makefile** 文件是用于大型项目中指导编译器如何去编译源码，Makefile 解释项目中不同的源文件是怎样组织的，源文件之间依赖关系 以及 编译的步骤 等等。

## 1. Makefile的语法和结构

```Makefile
targets: prerequisites 
	command 
	command 
	command
```

- targets :  指一个源文件，或者是一个标签，指代一组命令
- prerequisites： 指 生成 target目标文件依赖的目标文件；或者 执行标签命令之前需要执行的其他标签
- command： 生成 target目标文件需要执行的命令 

### 示例

**edit** 依赖  **main.o kbd.o command.o display.o insert.o search.o files.o utils.o** 等目标文件；

**main.o** 依赖 **main.c defs.h** 等文件，执行`cc -c main.c ` 命令生成 **main.o** 目标文件

**edit** 执行 `cc -o edit main.o kbd.o command.o display.o insert.o search.o files.o utils.o` 命令生成可执行文件 **edit** 

```sh
edit : main.o kbd.o command.o display.o /  
insert.o search.o files.o utils.o  
cc -o edit main.o kbd.o command.o display.o /  
insert.o search.o files.o utils.o  
  
main.o : main.c defs.h  
cc -c main.c  
kbd.o : kbd.c defs.h command.h  
cc -c kbd.c  
command.o : command.c defs.h command.h  
cc -c command.c  
display.o : display.c defs.h buffer.h  
cc -c display.c  
insert.o : insert.c defs.h buffer.h  
cc -c insert.c  
search.o : search.c defs.h buffer.h  
cc -c search.c  
files.o : files.c defs.h buffer.h command.h  
cc -c files.c  
utils.o : utils.c defs.h  
cc -c utils.c  
clean :  
rm edit main.o kbd.o command.o display.o /  
insert.o search.o files.o utils.o
```

Makefile 也可以是 标签代表的一组命令，以 [swiftlint](https://github.com/realm/SwiftLint/blob/master/Makefile)

截取以下一段为例，执行`Make`命令时，首先执行 `all` , 而 `all` 依赖 `build` , `build` 又以来 `clean build_x86_64 build_arm64`

这些 target 是一组标签，指代一组命令 

```sh

all: build
 
clean:

rm -f "$(OUTPUT_PACKAGE)"

rm -rf "$(TEMPORARY_FOLDER)"

rm -f "./*.zip"

swift package clean

clean_xcode:

$(BUILD_TOOL) $(XCODEFLAGS) -configuration Test clean

build_x86_64:

swift build $(SWIFT_BUILD_FLAGS) --arch x86_64

build_arm64:

swift build $(SWIFT_BUILD_FLAGS) --arch arm64

build: clean build_x86_64 build_arm64

# Need to build for each arch independently to work around https://bugs.swift.org/browse/SR-15802

mkdir -p $(SWIFTLINT_EXECUTABLE_PARENT)

lipo -create -output \

"$(SWIFTLINT_EXECUTABLE)" \

"$(SWIFTLINT_EXECUTABLE_X86)" \

"$(SWIFTLINT_EXECUTABLE_ARM64)"

strip -rSTX "$(SWIFTLINT_EXECUTABLE)"

```

更多语法请参考 [Makefile 教程](https://makefiletutorial.com/#getting-started)

## 2. make 命令
在默认情况下，只需要输入`make`命令，源码将会自动编译起来

1. 首先 `make` 会在当前目录中查询 **makefile** 或 **Makefile** 文件
2. 在 **Makefile** 中寻找第一个 **target**  作为执行的对象
3. 确定 **first target** 依赖的其他 **target**, 按顺序去执行，生成对应的目标文件
4. 最终执行 **first target** 的指令生成最后的产物

当再次执行 `make` 命令，如果某个target产物已存在，且该 target 以及其依赖的 target的源码没有修改，那么将会直接使用 target的产物

以上面的Makefile为例：

如果 main.o 已经存在，且它依赖的 main.c defs.h  都没有修改过，将会直接使用 main.o 


## 参考文档
[Makefile 教程](https://makefiletutorial.com/#getting-started)
[Linux makefile 教程 非常详细，且易懂](https://blog.csdn.net/liang13664759/article/details/1771246)