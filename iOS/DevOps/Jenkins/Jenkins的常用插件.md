# Jenkins的常用插件

## 用户权限管理 （Role Strategy Plugin）

1. 下载插件 `Role-based Authorization Strategy`

     ![](pic/plugin-userpersmissionmanager-2.png)

2. 在`Configure Global Security`的授权策略中打开`Role-Based Strategy`

     ![](pic/plugin-userpersmissionmanager-1.png)

3. 设置中出现Manage and Assign Roles ， 进入后可以创建角色，设置角色的权限并给用户分配角色

     ![](pic/plugin-userpersmissionmanager-3.png)

     ![](pic/plugin-userpersmissionmanager-4.png)

4. 在Manage Roles中可以创建全局角色，job角色和node角色，可以为不同角色分配权限。在Assign Roles可以为用户分配角色

     ![](pic/plugin-userpersmissionmanager-5.png)