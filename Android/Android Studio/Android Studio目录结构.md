
## 1. Android Project 结构

![](https://pic.existorlive.cn//202501090212090.png)

- . gradle和.idea
 > 这两个目录下放置的都是Android Studio自动生成的一些文件，
-  app
> 项目中的代码、资源等内容都是放置在这个目录下的，

- gradle
> 这个目录下包含了gradle wrapper的配置文件，使用gradle wrapper的方式不需要提前将gradle下载好，而是会自动根据本地的缓存情况决定是否需要联网下载gradle。Android Studio默认就是启用gradle wrapper方式的
> 
- build.gradle.kts 
> 这是项目全局的gradle构建脚本，通常这个文件中的内容是不需要修改的。
> 
- gradle.properties
> 这个文件是全局的gradle配置文件，在这里配置的属性将会影响到项目中所有的gradle编译脚本。

- gradlew和gradlew.bat
> 这两个文件是用来在命令行界面中执行gradle命令的，其中gradlew是在Linux或Mac系统中使用的，gradlew.bat是在Windows系统中使用的。

- local.properties
> 这个文件用于指定本机中的Android SDK路径，通常内容是自动生成的，我们并不需要修改。除非你本机中的Android SDK位置发生了变化，那么就将这个文件中的路径改成新的位置即可。

- settings.gradle.kts
> 这个文件用于指定项目中所有引入的模块。由于HelloWorld项目中只有一个app模块，因此该文件中也就只引入了app这一个模块。通常情况下，模块的引入是自动完成的，需要我们手动修改这个文件的场景可能比较少。

## 2. App 目录结构

![](https://pic.existorlive.cn//202501090231260.png)

- lib 
> 如果你的项目中使用到了第三方jar包，就需要把这些jar包都放在libs目录下，放在这个目录下的jar包会被自动添加到项目的构建路径里。
- androidTest 
> 此处是用来编写Android Test测试用例的，可以对项目进行一些自动化测试

- java
> java目录是放置我们所有Java代码的地方（Kotlin代码也放在这里），展开该目录，你将看到系统帮我们自动生成了一个MainActivity文件。

- res
> 在项目中使用到的所有图片、布局、字符串等资源都要存放在这个目录下

- AndroidManifest.xml
> 这是整个Android项目的配置文件，你在程序中定义的所有四大组件都需要在这个文件里注册，另外还可以在这个文件中给应用程序添加权限声明。
- test
> 此处是用来编写Unit Test测试用例的
- build.gradle.kts
> 这是app模块的gradle构建脚本
- proguard-rules.pro 
> 这个文件用于指定项目代码的混淆规则，


## 3.  Java 目录

## 4. res 目录 

res目录下存放所有图片、布局、字符串等资源
![](https://pic.existorlive.cn//202501100113185.png)

- drawable： 存放图片资源 
- layout： 存放布局文件
- mipmap： 存放各种尺寸的icon
- values： 存放字符串，色值

在代码中引用资源：

```kt
R.string.app_name     // 字符串

R.color.black         // 颜色

R.layout.activity_main // 布局 

R.drawable.ic_launcher_background // 图片
```

在 xml 中引用资源

```xml 
@string/app_name

@color/black 

@drawable/ic_launcher_background 
```