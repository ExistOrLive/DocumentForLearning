## 1. `git merge`

`git merge`命令的作用是将两个或者多个分支的开发历史合并起来。

如下有主干分支**master**，和分支**topic**。**topic**在**Commit E** 从分支**master**上创建。

**topic**分支推进到 **Commit C**，**master**分支推进到 **Commit G**。

```
     A---B---C topic
    /
D---E---F---G master

```

当前分支为 **master**。执行命令 `git merge topic`。

`git merge`命令会将 **topic** 分支上从 **Commit E** 的每次提交在 **master** 分支上重演一遍，并创建新的 **Commit H** 记录这次合并。

```
     A---B---C topic
    /         \
D---E---F---G---H master
```

从`git log`中可以很清晰的看到，**Commit A B C** 是从 **topic** 分支合并到 **master** 分支上的。

## 2. `git merge --abort`

`git merge --abort` 命令仅在合并分支时发生冲突的情况下，用于恢复到合并之前的状态。

#### Tip

如果使用`git merge`之前，有未提交的修改，`git merge --abort`并不能够恢复这些未提交的修改。

因此不建议在未提交修改时，使用`git merge`

## 3. `git merge --continue`

`git merge --continue` 用于在解决完合并冲突后继续合并进程。
