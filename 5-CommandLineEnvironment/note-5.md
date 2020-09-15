# Lecture 5: Command-line Environment

## Job Contorl
### Killing a process
* `Ctlr + \`: 产生`SIGQUIT`信号。程序默认异常退出，并生成`core dump`文件。
* `Ctlr + c`: 产生`SIGINT`信号。程序默认推出。
* `kill`: 该命令可以发送特定的信号给指定的进程。
* 信号定义及行为详见[BSD手册](https://www.freebsd.org/cgi/man.cgi?query=signal&apropos=0&sektion=0&manpath=FreeBSD+12.1-RELEASE+and+Ports&arch=default&format=html)。（比Linux manual详细）。
  
### Pausing and backgrounding processes
* `Ctlr + z`: 产生`SIGTSTP`信号（Terminal Stop， 终端版本的`SIGSTOP`), 默认暂停(`suspend`)进程执行。等价于`kill -SIGSTOP pid`
* `fg`,`bg`: 分别令程序在前台/后台执行。foreground/backgourn.
* `jobs`: 列出当前终端会话中未完成的任务。
* `$!`: 将最近一个后台运行的程序切换到前台运行。
* `&`后缀: 将命令放到后台执行，但它仍会使用当前Shell的标准输出。
* `nohup`: 启动一个程序，使程序不响应`SIGHUP`信号，使该命令运行的进程不因当前终端的关闭而退出。它关闭了所启动进程的标准输入，重定向标准输出和标准出错到`nohup.out`文件中。
* `disown`: 另一个已经启动的程序（进程）不响应`SIGHUP`。但如果在SSH等远程终端上运行时，关闭终端还是会引起进程的终止，因为进程继承了终端的`stdin`,`stdout`,`stderr`。而当终端退出时，这些文件被关闭，所以`disown`后的进程在尝试使用继承而来的文件描述符后会出错退出。[`nohup`&`disown`区别详见](https://unix.stackexchange.com/questions/3886/difference-between-nohup-disown-and)

## Terminal Mutiplexers
* `tmux`:
  * Sessions: 会话是一个独立的`workspace`，可以容纳一个或多个windows
  * Windows: 相当于浏览器的标签（`tab`）
    * `<C-b> c`: 创建新窗口
    * `<C-b> d`: 关闭窗口
    * `<C-b> N`: 其中`N`指的是具体数字。转到指定编号的窗口
    * `<C-b> n`: 转到下一个窗口
    * `<C-b> p`：转到前一个窗口
    * `<C-b> ,`: 重命名当前窗口
    * `<C-b> w`: 列出当前所有窗口
  * Panes: 类似vim的splits, 可以同时运行多个shellshell。
    * `<C-b> "`: 水平切分当前pane.
    * `<C-b> %`: 垂直切分当前pane.
    * `<C-b> <direction>`: 切换到特定方向的pane, 这里`<direction>`是方向键.
    * `<C-b> z`: 放大/缩小当前pane.
    * `<C-b> <space>`: 切换pane的排列方式（水平，垂直，原始）
  * [tmux快速入门](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/)
  * [tmux详细教程](http://linuxcommand.org/lc3_adv_termmux.php)

PS: `tmux`中`zsh-autosuggestions`提示字符变成白色，而不是浅灰色半透明字体，是因为`tmux`环境变量`TERM=screen`，而`zsh`中的`TERM=xterm-256color`。
* 解决办法： `echo "export TERM=xterm-256color" >> ~/.zshrc` [详情参考这篇文章](https://www.mojidong.com/post/2017-05-14-zsh-autosuggestions/)

### Aliases
形式`alias alias_ame="command_to_alias arg1 arg2"`  
**注意**：`=`等号两边**不能有空格**， 因为`alias`是一个shell命令，只接受一个参数。

直接看例子学习`alias`用法：
```bash
# Make shorthands for command flags
alias ll="ls -lh"

# Save a lot of typing for common commands
alias gs="git status"
alias gc="gc commit"
alias v="vim"

# Save you from mistyping
alias sl=ls

# Overwrite existing commands for better defaults
alias mv="mv -i"  # -i prompts before overwrite
alias mkdir="mkdir -p" # -p make parent dirs as needed
alias df="df -h" # -h prints human readable format

# Alias can be composed
alias la="ls -A"
alias lla="la -l"

# To ignore an alias run it prepended with \
\ls
# Or disable an alias altogether with unalias
unalias la

# To get an alias definition just call it with alias
alias ll
# Will print ll='ls -lh'
```

## Dotfiles
常见程序的配置文件所在位置：
- `bash`: `~/.bashrc`, 或`~/.bash_profile`
- `zsh`: `~/.zshrc`
- `git`: `~/.gitconfig`
- `vim`: `~/.vimrc`
- `ssh`: `~/.ssh/config`
- `tmux`: `~/.tmux.conf`