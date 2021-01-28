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