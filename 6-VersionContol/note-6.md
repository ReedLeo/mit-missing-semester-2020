# Lecture 6: Version Control(Git)

版本控制系统：
 * 不仅用于跟踪源码变化，也能追踪其他文件和目录的版本迭代。
 * 维护历史变更记录，记录快照（snapshot）创建者和快照关联信息等元数据。
 * 亦可作为协作工具，解决如下一些问题：
    1. 谁写了这个模块？
    2. 何时、何人、为何添加/修改了某一行代码？、
    3. 在最近的1000个修订中，特定的单元测试什么时候/为什么停止工作？

## Git的数据模型
### 快照（snapshot）
* 快照：顶级目录中文件和文件夹的集合的历史记录。
* blob：文件称为“ blob”，它只是一堆字节。 
* tree：目录称为“树”，它将名称映射到Blob或树（因此目录可以包含其他目录）。
例子：
```
<root> (tree)
|
+- foo (tree)
|  |
|  + bar.txt (blob, contents = "hello world")
|
+- baz.txt (blob, contents = "git is wonderful")
``` 

### 建模历史：关联快照
Git的历史记录由快照作为节点的有向无环图构成。每个节点都可能由多个父节点，也同时可以被继承。多个父节点是由于多条分支合并。
所谓”快照”就是Git中的“commit“（提交）。
一个常见的提交历史记录长这样：
```
o <-- o <-- o <-- o
            ^
             \
              --- o <-- o
```
后续开发，合并后长这样：
```
o <-- o <-- o <-- o <---- o
            ^            /
             \          v
              --- o <-- o
```

### 数据模型（伪码描述）
以下伪码描述了Git的数据模型：
```
// a file is a bunch of bytes
type blob = array<byte>

// a directory contains named files and directories
type tree = map<string, tree | blob>

// a commit has parents, metadata, and the top-level tree
type commit = struct {
    parent: array<commit>
    author: string
    message: string
    snapshot: tree
}
```

### 对象及内容寻址
Object可以是blob, tree 或 commit:
```
type object = blob | tree | commit
```  

Git 在储存数据时，所有的对象都会基于它们的SHA-1 hash进行寻址。
```
objects = map<string, object>

def store(object):
    id = sha1(object)
    objects[id] = object

def load(id):
    return objects[id]
```

### 引用（Reference）
虽然所有的快照都可以由其SHA-1哈希值定位，但40位的16进制数显然难以记忆。

所以，Git使用人类阅读友好的方式给SHA-1哈希值命名，这些名字即为”引用（reference）”。
引用可以修改，从指向A对象变为指向B对象。
```
references = map<string, string>

def update_reference(name, id):
    references[name] = id

def read_reference(name):
    return references[name]

def load_reference(name_or_id):
    if name_or_id in references:
        return load(references[name_or_id])
    else:
        return load(name_or_id)
```
如“HEAD“，”master”等都是引用（HEAD: 指向当前快照的特殊引用）。

### 仓库
粗略的说，Git仓库(Repository)即数据`对象`和`引用`。

## Staging area
Git并不直接基于当前状态创建快照。而是将当前改动保存在Stagin area（可理解为”暂存区”）中，依照我们的选择是否将暂存区中的改动过放入新快照中。

## Git 命令行接口
只记录还不怎么熟悉的命令。
### Basic
* `git log`: 显示详细历史日志。
* `git log --all --graph --decorate`： 以DAG形式展示详细日志

### 分支与合并
* `git branch <name>`： 创建一个分支
* `git checkout -b <name>`: 创建一个分支并切换到该分支
* `git merge <revision>`: 将当前分支合并到指定分支
* `git mergetool`: 使用工具简化合并时的冲突处理
* `git rebase`: 将一个分支合并到另一个分支中，效果与merge类似

### 远端
* `git remote`: 列出远端仓库
* `git remote add <name> <url>`：添加一个远程仓库
* `git push <remote> <local branch>:<remote branch>`: 发送对象给远端仓库，并更新远端引用
* `git fetch`: 从远端获取对象/引用
* `git pull`: 等价于`git fetch; git merge`

### 撤销
* `git commit --amend`: 一次提交的内容或信息(message)
* `git reset HEAD <file>`: unstage a file
* `git checkout -- <file>`: 放弃更改

## 进阶Git
* `git config`: Git可以高度定制化，[参考此链接](https://git-scm.com/docs/git-config)
* `git clone --depth=1`: 浅拷贝：不复制完整的版本历史
* `git add -p`: 交互式暂存
* `git rebase -i`: 交互式重定位
* `git blame`: 显示最后修改者
* `git stash`: 暂时从工作目录中移除更改
* `git bisect`: 二分查找的方式搜索历史记录
* `.gitignore`: 指定忽略项。这个[Github项目](https://github.com/github/gitignore)记录了许多常用的`.gitignore`配置，可以参考。

## 杂项
* 工作流：以下三篇文章介绍了几种工程实践中git的建议工作流
    1. https://nvie.com/posts/a-successful-git-branching-model/
    2. https://www.endoflineblog.com/gitflow-considered-harmful
    3. https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

## Learn git branching
* 相对commit: `git checkout main^` 表示切换到main的父节点，同理`main^^`表示main的祖父节点。
* `~`操作符：`^`只向上移动一次，`~`可以指定移动次数。如`git checkout HEAD~4`移动到HEAD前4个节点。
    * `git branch -f main HEAD~3`: 将main移动到HEAD之前3个节点处。
* `git reset`: 将当前分支的引用往回移动指定个节点。
* `git revert`: 当使用**远程仓库**时，`git reset`就不适合了，因为别人可以还在"当前节点"上进行开发。我们需要使用`git revert`，它以原节点作为父节点，创建一个新的节点，这样其他人就可以看到我们的修改。
* `git cherry-pick`: 选择几个节点（可来自不同分支）作为当前分支新节点(commit)的祖先节点，祖先顺序与选择顺序相同。例：`git cherry-pick c3 c1 c2`后， `c3 <- c1 <- c2 <- HEAD`
* `git rebase -i`: Interactive rebase.
* `git tag`: 可以作为开发时的”里程碑”，tag不会随分支更改而移动，而是固定与某一次commit绑定。
    * `git tag v1 C1`: 将C1打一个名为v1的tag。
    * `git checkout v1`：可以将`HEAD`切到C1。
* `git describe <ref>`: `<ref>`是git可以解析到一次commit的任意符号（hash, tag）。该命令返回结果形如`<tag>_<numCommits>_g<hash>`：
    * `<tag>`: 距`<ref>`最近的tag名称
    * `<numCommits>`: `<ref>`与`<tag>`相距的commit次数
    * `<hash>`： `<ref>`自身的hash