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
* `nohup`: 启动一个程序，使程序不响应`SIGHUP`信号，使该命令运行的进程不因当前终端的关闭而退出。
* `disown`: 另一个已经启动的程序（进程）不响应`SIGHUP`。