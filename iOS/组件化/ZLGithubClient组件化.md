# ZLGithubClient 组件化

近期为ZLGithubClient添加了小组件功能，遇到了一些问题。

小组件作为 App 的扩展，虽然依附于 App 存在，但是事实上是一个相对独立的 target。它没有办法复用 app 中的代码和功能。例如我希望小组件查询今天的趋势仓库，虽然 app 代码中有这样的功能和接口，但是除非将这块代码(包括服务层，网络层，以及这两块代码依赖其他代码)添加到小组件的target中，否则无法使用。

基于上面的问题，这边想要对 ZLGithubClient 工程按照 **Base模块**， **Service模块** ，**UI模块** 三块切割出来。

- **Base模块** 

   这块代码和 ZLGithubClient 的业务逻辑没有关系，是工程架构，基础UI以及一些工具类等代码的集合

- **Service模块** 

   这块代码处理整个 ZLGithubClient 的业务逻辑，包括网络交互，数据持久化


- **UI模块**

   这块主要是 UI 模块


首先以原本 ZLGithubClient 工程作为壳工程，包含 **UI模块** 代码；创建 Framework 
