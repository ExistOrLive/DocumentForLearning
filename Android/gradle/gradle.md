Android Studio 采用 Gradle 构建项目。 Gradle是一个非常先进的项目构建工具，它使用了一种基于**Groovy**的领域特定语言（DSL）来进行项目设置，摒弃了传统基于XML（如Ant和Maven）的各种烦琐配置。

Gradle 支持使用 **Kotlin** 作为构建脚本语言。相比传统的 Groovy 脚本，Kotlin 代码有着更强的类型安全性。

## gradle  wrapper 

gradle wrapper 是 Gradle 提供的一个重要特性，主要用途如下：

- **版本管理一致性**：在一个团队开发项目时，不同成员电脑上安装的 Gradle 版本可能不同，这容易导致构建出现兼容性问题。gradle wrapper 会在项目中生成一组脚本，使得项目能自带特定版本的 Gradle 运行时，无论开发人员本机有没有安装 Gradle，或者安装的是哪个版本，只要执行 gradlew （在 Linux 或 MacOS 上） 或 gradlew.bat （在 Windows 上）脚本，就会下载并使用项目指定的 Gradle 版本来构建项目，保障了整个团队构建环境的一致性。
- **易于部署**：对于持续集成（CI）环境，gradle wrapper 也非常友好。CI 服务器无需提前全局安装特定版本的 Gradle，只要项目中有 wrapper 相关脚本，CI 系统就能自动下载匹配的 Gradle 版本来执行构建任务，简化了 CI 流程的配置，降低了环境部署的复杂度。