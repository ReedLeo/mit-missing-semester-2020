# Metaprogramming
## Build systems
解决生成目标的依赖、构建规则等的系统。
`make`是类Unix系统中常见的构建工具。不仅可以用来生成代码，如下的`Makefile`文件可以用来生成图片和pdf：
```makefile
paper.pdf: paper.tex plot-data.png
	pdflatex paper.tex

plot-%.png: %.dat plot.py
	./plot.py -i $*.dat -o $@
```
* 默认以`Makefile`第一条指令为最终目标结果。
* `%`表示左右两边相同的字符串。

## Dependency management
* **semantic versioning(语义版本控制)**,版本编号形式： `major.minor.patch`
    * 新发布版本未改变API， 则增加`patch`编号
    * **增加**了API且向后兼容，增加`minor`编号
    * 修改了API，不向后兼容，增加`major`编号
* **lock file**: 记录当前依赖版本的清单文件

## Continuous integration systems
持续集成(Continous Integration, CI), 是“随代码变化而变化的东西”的总称。
* `Test suite`: 所有测试的统称。
* `Unit test`(单元测试): "微测试"，单独测试一个特定的feature。
* `Integration test`(集成测试): "宏测试"， 对一个或多个模块进行测试，检查模块间不同feature间的协作是否正常。
* `Regression test`(回归测试): 用之前触发bug的场景进行测试，确保修复后bug不再复现。
* `Mocking`: 替换函数、模块或类型，用以模拟真实功能。
