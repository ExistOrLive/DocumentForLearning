[黑马程序](https://www.bilibili.com/video/BV1Lq4y1J77x?p=3&vd_source=7a1c6e1c5e9de792b9a6e81db79ef82e)
Spring boot 是一个帮助我们快速构建spring工程的一个项目；旨在简化spring工程的配置，快速搭建spring开发环境，提高开发效率。


### spring boot 项目的目录结构


#### 1. 以 maven 作为构建工具
![](https://pic.existorlive.cn//202305110137844.png)

```sh
- src
   - main
      - java
         - com.example.TestMaven    ## 源文件
            - TestMavenApplication.java ## 引导入口类
      - resources
         - application.properties   ##配置文件
   - test 
- pom.xml     # maven配置文件
- mvnw
- mvnw.cmd
- HELP.md
```


#### 2. 以 gradle 作为构建工具
![](https://pic.existorlive.cn//202305110137041.png)


```sh
- src
   - main
      - java
         - com.example.TestMaven    ## 源文件
            - TestMavenApplication.java ## 引导入口类
      - resources
         - application.properties   ##配置文件
   - test 
- build.gradle    # gradle配置文件
- settings.gradle 
- gradle
- gradlew
- gradlew.bat
- HELP.md

```