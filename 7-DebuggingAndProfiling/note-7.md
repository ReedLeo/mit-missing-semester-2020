# Lecture-7: Debugging and Profiling

## Debugging
### Printf debugging and Logging
在待调试处插入直接打印语句和日志记录是两种最基本，也最常用的调试手段之一。相较于直接打印，日志记录方式有如下几个优点：
* 日志除了可以输出到stdout，还能输出到文件、socket，甚至远程服务器。
* 日志可以分级，如INFO, DEBUG, WARN, ERROR等。
* 对于新问题，日志可能包含足够信息以反映问题所在。

对于日志，我们可以使用[ANSI转义码](http://ascii-table.com/ansi-escape-sequences.php)来控制输出到终端时的颜色。
可以在将下列代码保存到`.sh`文件中，在terminal中执行可以看到彩色块：
```bash
#!/usr/bin/env bash
for R in $(seq 0 20 255); do
    for G in $(seq 0 20 255); do
        for B in $(seq 0 20 255); do
            printf "\e[38;2;${R};${G};${B}m█\e[0m";
        done
    done
done
```

### Third party logs
绝大多数linux系统都使用`systemd`来记录日志，其日志存放在`/var/log/journal`中，`journalctl`可以显示其中日志。

### Debugger
* `pdb`： 一款python的调试器。
* `ipdb`: 另一款python调试器，使用pip安装。

### Static Analysis
静态分析：
* python代码静态分析工具：`pyflakes`, `mypy`
* shell代码静态分析工具：`shellcheck`

## Profiling
性能分析
### Timing
耗时组成：
使用`time`命令可以查看一个程序的执行时间：
```
$ time curl https://missing.csail.mit.edu &> /dev/null`
real    0m2.561s
user    0m0.015s
sys     0m0.012s
```
1. 实际耗时(`Real`)：从程序开始执行到程序执行完毕经过的时间，包括了I/O等待的时间。
2. 用户态耗时(`User`): CPU执行用户态代码耗时。
3. 系统耗时(`Sys`): CPU执行和心态代码耗时。

### Memory
对于C/C++来说，内存泄露检测工具：
* `Valgrind`:https://valgrind.org

### Event Profiling
* `perf`： 可以用来统计诸如内存缺页次数等系统事件，也是CTF中Reverse题侧信道攻击的工具之一。

### Visualization
可视化
* 火焰图: http://www.brendangregg.com/flamegraphs.html

### Resource Monitoring
* 通用监视工具：
    * `htop`, 基于`top`的任务管理器。`htop`有许多选项，下面是几个例子：
        * `F6`: 按下f6键可以调出排序选项，如按PID排序。
        * `t`: 按下t键，以树形展示进程间的关系。
        * `h`或`F1`: 显示帮助。
        * `H`：显示/隐藏用户态线程。
        * `K`：显示/隐藏内核态线程。
    * `glances`： 类似`htop`。Ubuntu/Kali可以通过apt安装。
    * `dstat`：相较前两者显示更加简洁（少）。Ubuntu/Kali可以通过apt安装。
* IO操作：
    * `iotop`: 显示IO使用率，类似`top`。
* 硬盘使用情况：    
    * `df`:
    * `du`:
    * `ncdu`：交互版的`du`
* 内存使用情况：
    * `free`
* 打开文件情况：
    * `lsof`: list opened files
* 网络连接与配置：（不建议使用`netstat`和`ipconfig`）
    * `ss`: 监测网络数据包的收发统计情况。常用来查找占用特定端口的进程。
    * `ip`: 可用于查看路由、网络设备与接口。
* 网络使用情况：下列两个程序在Kali2020.4 中均需要sudo来执行
    * `nethogs`
    * `iftop`
