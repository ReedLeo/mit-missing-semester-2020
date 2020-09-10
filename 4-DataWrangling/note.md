## Data Wrangling
### 引言
* `journalctl`: 可用于查看当前系统日志
* `ssh {server_addr} journalctl | grep sshd` 通过ssh来运行远程服务器上的`journalctl`，并将其输出结果由管道传给**本地的**grep。
* 上述方法还可以用单引号将复杂命令包裹起来，从而能在远程主机上运行更长的命令：
  * `ssh myserver 'journalctl | grep sshd | grep "Disconnected from"' > ssh.log`
* **sed**: stream editor. 数据流编辑器，只操作数据流，不改变原始文件。
  * 命令`s`: substitution, 替换
    * 语法：`s/REGEX/SUBSTITUTION`
  * `-E`: 让seq支持现代正则表达式语法。因为sed默认支持其古老的正则语法，很多字符需要用`\`转义。  
  ```
  // 不加-E, 无法替换ab
  $ echo 'abdfsdfac' | sed 's/(ab)*//g'  
  abdfsdfac

  // 加-E才能成功替换
  $ echo 'abcabcba' | sed -E 's/(ab)*//g'
  ccba
  ```

### Regular Expression
#### 通用匹配模式：
正则表达式的实现多样，特殊匹配字符在不同方言中含义可能不同。以下是一些各家比较通用的匹配字符（正则里的普通话?)：
* `.`: "任意一个字符"，除了换行
* `*`: 匹配**零个**或多个前缀
* `+`: 匹配**一个**或多个前缀
* `?`: 匹配**零个**或**一个**前缀
* `[abc]`: 含有`[]`集合中的**任意一个**。本例中则为'a'或'b'或'c'
* `[^abc]`: 不包含`[^]`中的任意一个字符。本例中则不包含'a','b','c'
* `(RX1 | RX2)`: 匹配表达式`RX1`或`RX2`。
  * 每个`()`视为一个**group**, 按出现顺序排序，从`1`开始编号， 用`\1`,`\2`等方式引用匹配项。
* `^` 行首
* `$` 行尾

PS: 通配符`*`和`+`通常采取**贪心策略**————尽可能匹配多的文本。可以在这两个通配符后跟`?`来显示指定**非贪心**匹配。然而`sed`不支持非贪心匹配。
```
$ echo 'abcabbc' | perl -pe 's/.*?ab//'
cabbc

$ echo 'abcabbc' | sed -E 's/.*?ab//' 
bc
```

### Back to data wrangling
* `sort`: 对其输入进行排序，然后输出
  * `-n`, **--numeric-sort**: compare human readable numbers (e.g., 2K 1G)
  * `-k1,1`: 只按首个被空白字符分隔的列排序。
    * `,n`: 排序只参该列的第`n`个域为止，默认到行尾。
  * `-r`: 逆序
* `uniq`: 输出或忽略重复行
  * `-c`: **--count**。 在行首添加出现次数

### awk - another editor
* `{print $2}`: 表示答应每行的第2个域。
  * `$0`: 表示整个行。
  * `$1`~`$n`: 表示从每行的第`n`个域。