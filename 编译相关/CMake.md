
# CMake 
#CMake
#编译

CMake(Cross Platform Make),一款跨平台的工程构建工具。

- 开源代码

- 跨平台，支持Linux，Mac和Windows系统

- 编译语言简单，易用，简化比构建过程和编译过程

## 与GCC，Makefile的对比

- GCC是C/C++，Java等语言的编译工具

- Makefile 是 用于指导编译工具(GCC,LLVM)来如何编译的文件，利用Make工具来执行Makefile中的编译指令

- 当程序简单时，可以手写Makefile

- 当程序复杂时，一般利用CMake和autotools来自动生成Makefile

> GCC 是 编译工具， Makefile是说明工程结构，指导编译的文件， CMake是在工程复杂时用于生成Makefile的工具

## CMake 与 Autotools等其他工程构建工具的对比

- Autotools
    
    生成Makefile和config.h 

- CMake 

    读取CMakeList.txt文件的语句，生成Makefile


## 1. CMake安装

CMake 有 GUI版本下载后可以直接使用；如果希望在命令行中使用，需要配置对应的环境变量：

![](https://pic.existorlive.cn/%E6%88%AA%E5%B1%8F2020-11-08%20%E4%B8%8B%E5%8D%886.19.50.png)


[CMake](https://cmake.org/download/) 

## 2. CMake语法的主体框架

```sh
#***********工程配置部分****************#
cmake_minimum_required(VERSION num)     #cmake最低版本要求
project(cur_project_name)   # 项目名
set(CMAKE_CXX_FLAGS "xxx")        # 设置编译器版本，如-std=c++11
set(CMAKE_BUILD_TYPE "xxx")       # 设定编译模式，如Debug/Release

#***********依赖执行部分***************#
find_package()
add_library(<name> [lib_type] source1)              # 生成库类型(动态，静态)
include_directories($(std_lib_name_INCLUDE_DIRS))   # 指定include的路径，放在add_executable之前
add_executable(cur_project_name XXX.cpp)            # 生成可执行文件
target_link_libraries($(std_lib_name_LIBRAIES))     # 指定Libraries的路径，放在add_executable之后

#************其他辅助部分****************#


```
