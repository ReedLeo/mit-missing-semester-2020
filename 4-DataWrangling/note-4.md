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
  * `\d`：不支持，请用`[0-9]`
  * 使用`\1`,`\2`等来索引group，但如果没有匹配上，则会输出整行。
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
* `^`: 行首
* `$`: 行尾
* `\s`: 空白字符，包括空格` `, 制表符`\t`, 换行符`\r`, 回车`\r`
* `\S`: 非空白字符。
* `\d`: 数字，等价于`[0-9]`
* `\D`: 非数字
* `\w`: 字母，不含符号,如：`.`,`\`等需要另外匹配。
* `\W`: 非字母。
* `{m}`:重复m次，
  * `{m, n}`: 重复次数范围[m, n]
  

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
* `{print $2}`: 表示打印每行的第2个域。
  * `$0`: 表示整个行。
  * `$1`~`$n`: 表示每行的第`n`个域。
* `-F`: 指定域分隔符，默认是空白字符(whitespace， 包括`\t`?)

### Analyzing data
* `bc`: 计算器
* `R`: 统计语言
* `gnuplot`: 制图

### Exercise
1. [regex tutorial](https://regexone.com/lesson/introduction_abcs)
2. 单词计数。数据来源`/usr/share/dict/words`，要求: 有至少3个`a`，(未必连续)，不以`'s`结尾。
   1.  Find the number of words (in /usr/share/dict/words) that contain at least three as and don’t have a 's ending. 
   * My solution:``
   2.  What are the three most common last two letters of those words?
   * My solution: `cat /usr/share/dict/words| awk "/(.*?[aA].*?){3,}([^'][^s])?$/" | awk '{print substr($0, length()-1)}' | uniq -c | sort -rnk1,2 | head -n3`
   1. How many of those two-letter combinations are there?
   * My Solution: `cat /usr/share/dict/words| awk "/(.*?[aA].*?){3,}([^'][^s])?$/" | awk '{print substr($0, length()-1)}' | uniq -c | wc -l`

* tips:
  * awk的正则表达式中使用单引号`'`: 
    * 使用`""`来包裹命令，在命令中直接使用`'`
    * 用`\47`代替(`\47 = 047 = 39 = '\''`)。因为awk本身使用了单引号作来包裹命令，因此需要转义。
  * awk产生子字符串`substr(str, start, end)`, start_min = 1, end_max = len(str)
  * sed正则中使用单引号
3. To do in-place substitution it is quite tempting to do something like sed s/REGEX/SUBSTITUTION/ input.txt > input.txt. However this is a bad idea, why? Is this particular to sed? Use man sed to find out how to accomplish this.
* My Solution: `sed -i 's/find/replace/g' filename`
  * `-i`: --in-place. edit files in place.

4. Find your average, median, and max system boot time over the last ten boots. Use journalctl on Linux and log show on macOS, and look for log timestamps near the beginning and end of each boot. 
* My Solution: `journalctl | grep -E "systemd\[[0-9]\]: Startup finished in" | tail -n10 | sed -r "s/.* = (.*)s./\1/" | awk '/([0-9](+min ))?(.*)/ { sub(/min /, "*60 + ", $0); print $0}' | bc | R --slave -e 'x <- scan(file="stdin", quiet=TRUE); summary(x)'`
  * `awk '/([0-9](+min ))?(.*)/ { sub(/min /, "*60 + ", $0); print $0}'`中，`sub(regexp, replacement [, target])`是字符串替换函数，用法参见[手册](https://www.gnu.org/software/gawk/manual/gawk.html)。因为我本地机器输出的时间存在如`1min 4.321s.`的数据，故需要进行转化。
### 学习资源
* [awk手册](https://www.gnu.org/software/gawk/manual/gawk.html)