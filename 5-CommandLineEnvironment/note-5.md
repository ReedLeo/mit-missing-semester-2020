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
* 常见程序的配置文件所在位置：
  - `bash`: `~/.bashrc`, 或`~/.bash_profile`
  - `zsh`: `~/.zshrc`
  - `git`: `~/.gitconfig`
  - `vim`: `~/.vimrc`
  - `ssh`: `~/.ssh/config`
  - `tmux`: `~/.tmux.conf`
* 管理自己的dotfiles:
  * 将自己常用的dotfiles纳入版本管理中，建一个专门的文件夹存放。
  * 再用`ln -s`命令将它们链接到相关配置的默认路径。
* 学习资源：
  * github搜索dotfiles
  * [dotfiles](https://dotfiles.github.io/)

### Portability
为了提高各类dotfiles的可以移植性，可以在在dotfile中写一些条件判断语句（类似C的条件编译)。例如，可以在shell中写如下语句（可以放在`.bashrc`, `.zshrc`中）
```bash
if [[ "$(uname)" == "Linux" ]]; then {do_something}; fi

# Check before using shell-specific features
if [[ "$SHELL" == "zsh" ]]; then {do_something}; fi

# You can also make it machine-specific
if [[ "$(hostname)" == "myServer" ]]; then {do_something}; fi
```

或者，某些类型的dotfile可以进行文件包含，那么就可以将非通用的配置写在单独的文件中，然后在通用的dotfile中包含之。例如，`~/.gitconfig`
```
[include]
  path = ~/.gitconfig_local
```

这种思想同样适用于不同程序的共享配置中，假如`bash`和`zsh`同时使用`.aliases`文件来配置别名，那么可以使用如下配置：
```bash
# Test if ~/.aliases exists and source it
if [[ -f ~/.aliases ]]; then
  source ~/.aliases
fi
```

## Remote Machines
* `ssh`: 不仅可以用ip登录也可以用域名（如果有的话）。如`ssh foo@bar.mit.edu`
* 在远程主机上执行命令，如: `ssh foobar@server ls`
### SSH Keys
* 生成密钥对（公私密钥）：`ssh-keygen`
  * 注意，在生成时要给私钥设置一个口令，避免私钥泄露后被人直接利用。
* 基于密钥的身份认证：
  * `cat .ssh/id_ed25519.pub | ssh foobar@remote 'cat >> ~/.ssh/authorized_keys'
` 拷贝本机公钥到远程主机，以后就可以直接使用ssh登录而不用输入口令了。
  * 或者这样拷贝： `ssh-copy-id -i .ssh/id_ed25519.pub foobar@remote`

### Copying files over SSH
* `ssh+tee`： `tee`用于复制程序的标准入内容到指定文件或标准输出。
  * e.g. `echo "Hello remote host! I'm from $(whoami)" | ssh leo@192.168.37.129 tee serverfile` 远程主机将会在其家目录下生成一个`serverfile`文件，其中包含"Hello remote host! I'm from {your_local_user_name}"
* `scp`: 方便拷贝大量文件夹/文件。
  * `scp path/to/file remote_host:path/to/remote_file`
* `rsync`: 相比`scp`，使用了增量复制。避免了重复，提高效率。语法类似`scp`

### Port Forwarding
下图所示为两种风格的端口转发，效果相同，[详见StackOverflow](https://unix.stackexchange.com/questions/115897/whats-ssh-port-forwarding-and-whats-the-difference-between-ssh-local-and-remot)
* 本地端口转发：
![Local Port Forwarding](https://i.stack.imgur.com/a28N8.png%C2%A0)
* 远程端口转发:
![Remote Port Forwarding](https://i.stack.imgur.com/4iK3b.png%C2%A0)

### SSH Configuration
* `~/.ssh/config`的配置例子  
```bash
Host pwn_vm
  User leo
  HostName 192.168.37.129
  Port 2222
  IdentityFile ~/.ssh/id_sha # user private key, so there is no .pub at the end.
  LocalForward 9999 localhost:8888
```  
* 如果配置后，运行`ssh pwn_vm`出现报错"Bad owner or permissions on ~/.ssh/config".解决方式如下：[参考StackExchange](https://serverfault.com/questions/253313/ssh-returns-bad-owner-or-permissions-on-ssh-config/710453)
  * `chmod 600 ~/.ssh/config`
  * `chown $USER ~/.ssh/config`

### Miscellaneous
* `Mosh`: **Mo**bile **sh**ell. 
* `sshfs`: 可以将远程主机的目录挂载到本地。
  

## Exercise

### Job control
1. From what we have seen, we can use some ps aux | grep commands to get our jobs’ pids and then kill them, but there are better ways to do it. Start a sleep 10000 job in a terminal, background it with Ctrl-Z and continue its execution with bg. Now use pgrep to find its pid and pkill to kill it without ever typing the pid itself. (Hint: use the -af flags).
   * Solution:
     * `pgrep -af sleep`
     * `pkill -f sleep`
2. Say you don’t want to start a process until another completes, how you would go about it? In this exercise our limiting process will always be sleep 60 &. One way to achieve this is to use the wait command. Try launching the sleep command and having an ls wait until the background process finishes.  
However, this strategy will fail if we start in a different bash session, since wait only works for child processes. One feature we did not discuss in the notes is that the kill command’s exit status will be zero on success and nonzero otherwise. kill -0 does not send a signal but will give a nonzero exit status if the process does not exist. Write a bash function called pidwait that takes a pid and waits until the given process completes. You should use sleep to avoid wasting CPU unnecessarily.
* Solution:
```bash
#!/usr/bin/env zsh
pidwait() {
  echo "You want to wait for $1"
  while kill -0 $1; do sleep 1; done                               
}
```

### Terminal multiplexer
1. Follow this tmux [tutorial](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/) and then learn how to do some basic customizations following [these steps](https://www.hamvocke.com/blog/a-guide-to-customizing-your-tmux-conf/).

### Alias
1. Create an alias dc that resolves to cd for when you type it wrongly.
   * Solution: `alias dc=cd`
2. Run `history | awk '{$1="";print substr($0,2)}' | sort | uniq -c | sort -n | tail -n 10` to get your top 10 most used commands and consider writing shorter aliases for them. Note: this works for Bash; if you’re using ZSH, use `history 1` instead of just `history`.
  
### Dotfiles
1. 创建一个属于你自己的`dotfiles`目录，并纳入到版本控制中。
2. 收集存放你常用工具的配置文件，保存到上述目录中。
3. 选择一种`dotfiles`安装方式（避免手动安装）。可以编写配置安装脚本，也可以使用[这些工具](https://dotfiles.github.io/utilities/)。
4. 发布到github上。

### Remote Machines
* `ssh-keygen -t ed25519 -a 100`生成公私密钥对（建议给私钥设置口令）。
* 向本地主机`~/.ssh/config`添加如下内容：
```bash
Host ubt20  # my vm is ubuntu20
  User leo
  HostName 192.168.xx.xx
  IdentityFile ~/.ssh/id_ed25519  # no .pub at the end, because we use private key.
  LocalForward 9999 localhost:8888 # we can visit remotehost:8888 form localhost:9999
```
* `ssh-copy-id ubt20` 将`ssh`公钥拷贝到远程主机`ubt20`上。
* 远程主机上运行`python -m http.server 8888`。本地主机使用浏览器访问`http://localhost:9999`即可访问远程主机的web服务。
* 修改`ssh`服务端登录配置：修改`/etc/ssh/ssh_config`文件后，重启`sshd`服务。
  * 禁止`ssh`密码登录: 修改`PasswordAuthentication no`
  * 禁止`root`用户使用`ssh`登录：修改 `PermitRootLogin prohibit-password`

5.(Challenge)安装并使用[Mosh](https://mosh.org/). 
* Solution:
  1. 安装：在我的两台虚拟机上分别安装
     1. Fedora32: `sudo dnf install mosh`
     2. Ubuntu16: `sudo apt install mosh`
  2. 先运行服务端（Fedora32）：`mosh-server`, 然后会返回如下信息：
  ```
    MOSH CONNECT 60001 JHpteM8RR3TfZg5LrmAm7w
  ```
  3. 再在Ubuntu16上运行客户端：`MOSH_KEY= JHpteM8RR3TfZg5LrmAm7w mosh-client 192.168.29.128 60001`
     1. 注意：客户端运行时`MOSH_KEY`一定和`mosh-client`要写在同一行，否则会报`MOSH_KEY environment variable not found.`
  4. 同类替代工具[ET](https://github.com/MisterTea/EternalTerminal)