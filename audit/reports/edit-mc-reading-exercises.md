# 第2章延伸阅读与习题精校

状态：awaiting_review；待另一 agent 重新对照固定原书独立复核。

独占文件：`chapter-2-Monte_Carlo_Integration/chapter-2.5-Further_Reading.typ`、`chapter-2.6-Exercises.typ`。固定原书：`f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c` 的 `4ed/Monte_Carlo_Integration/Further_Reading.html`、`Exercises.html`。已直接阅读全文、MathJax公式、HTML题目列表与难度码；未使用旧 Scripts。

## 逐段覆盖

Further Reading 全部10段：

1. Ulam/von Neumann、Fermi、Metropolis历史起源。
2. 经典及较新蒙特卡洛著作、Owen在写书稿、随机算法著作。
3. 负值函数重要性采样、绝对值密度与Owen/Zhou。
4. MIS起源、自适应策略分配、方差权重、补偿。
5. Sbert方差/开销分配、负权重、连续采样技术族、相关样本。
6. 不可逆CDF下的Heitz方法、第二随机变量与Aether语言。
7. SampleLinear的Muller方法应用，提出应用者Heitz与原方法作者区分。
8. 乘积被积函数、重要性重采样、Hart均匀样本变换、章13/14关联。
9. 蒙特卡洛调试的期望意义与统计检验。
10. 附录A延伸阅读关联。

References 的33条源记录已逐条读取，并检查本地引文对应；包含2.1/2.2引用的Ross2002与Owen1998。公共书目由主 agent维护，不在本agent修改范围。主要缺失Hart/Owen两记录已由主agent补入并经本agent对固定References.html:1947/3614核对作者、年份、题名、Hart卷期页码。

Exercises 完整3题：原HTML `<ol>` 中第1题难度②、第2题①、第3题②。逐句核对全部前提、误差/方差要求及函数符号；无额外题目、解答或脚注。两页无图、图注、数据表或代码块，行内代码名原样保留。

## 修正

- 两标题双语化；补此前缺失的习题标题，恢复1/2/3编号和②/①/②难度。
- 历史段误把Ulam/von Neumann称为数字计算机发明者，改回“数字计算机问世后由两人提出蒙特卡洛方法”。Metropolis不再译作“大都会”。
- 全文“蒙特卡罗/抽样”等统一；重要性重采样不再误作“重要性回归”；product不再误译“产品”。
- 自适应选择匹配的采样策略，不是选择匹配的样本；continuum明确为采样技术的连续族。
- Muller方法的归属与Heitz应用区分；tricky采样技术为难以处理的技术，并非“巧妙”。
- 重写调试段失去句法的译文，恢复“期望行为决定正确性，单个样本难判断”完整逻辑。
- 移除旧Owen译注中“链接能打开”的未经本次核实审校结论；补真引文 `@owen2019monte`。
- Hart等人误引Heitz论文，改为 `@hart2020practical`；英文Sobol原书撇号恢复。
- 第3题英文漏掉f、a、b，依据源SVG恢复；中文保留f非负前提、全负和异号过零两种推广情形，不增减题目要求。

## 未决/公共来源差异

- MC-EX-UPSTREAM-01：第2题固定原书写“variance decreases at a rate of O(n)”。正文方差关系为随n反比下降，此处降低速率措辞易与方差自身渐近阶混淆。保留原题公式、增加明确译注，未猜改为O(1/n)。
- MC-REF-UPSTREAM-01：Owen2019固定原书href实际含 `&nbsp;owen`，链接损坏；主agent新增URL用`~owen`，是合理修复候选，但不是源逐字值。已反馈，待统一记录依据。作者/题名/年一致。
- MC-REF-UPSTREAM-02：Subr2007源书目写Pacific Graphics '97，本地为'07。原书疑有年份笔误；未为逐字一致改坏本地，已告知主agent。
- Sbert2018原书以15标示刊物编号，本地按volume=2018、number=15表示，关联同一文章；不是缺文献。

## 验证

Typst 0.13.1公共模板、字体路径、公共bibliography，屏蔽跨节ref显示的独立入口：三语编译通过，输出 `/tmp/audit-mc-reading-zh.pdf`、`/tmp/audit-mc-reading-en.pdf`、`/tmp/audit-mc-reading-bi.pdf`。仅对两独占文件执行 `git diff --check` 通过（全工作区另agent的空行警告不归本任务修改）。

另生成仅习题的中文PNG并实际查看 `/tmp/audit-mc-exercises.png`：确认题号1/2/3及难度②/①/②可见且对应正确，三题和译注无裁切。该隔离预览采用系统回退字体、替代ref占位，不能据此宣称最终PDF字体、实际引用或全书排版通过。`typst query enum`提示enum不可定位，因此未将其当编号证据，改用实际图像核查。

临时入口已删除。仍需独立内容复核及全书真实引用/视觉验收。
