# 五份零字节缺失文件补全

状态：五份文件均为 `awaiting_review`。本 agent 已直接逐段阅读固定原文并人工录入、翻译和自检，尚未经过另一 agent 独立复核；不能标为已精校。

固定上游：`f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`。
未运行、调用或依赖旧翻译/转换/润色脚本；未使用模型批处理。所有英文和中文正文、书目均人工录入；临时只读结构工具用于阅读源文、枚举锚点和逐条比较，不生成译文。随后按固定源文为已录入的代码名连接原文定义。

## 逐文件覆盖与完成顺序

1. `Appendix-A-Sampling_Algorithms/A.7-Exercises.typ` ← `4ed/Sampling_Algorithms/Exercises.html`。
   - 全部3道习题，难度依次①②②，题号1–3。
   - 英中逐句对应，保留WeightedReservoirSampler合并概率、近似CDF无瑕疵前提、PortalImageInfiniteLight性能测试要求、条件CDF `P(y | x)`。
   - 无原书脚注、显示公式、图像或数据表；不虚增内容。
2. `Appendix-B-Utilities/B.9-Exercises.typ` ← `4ed/Utilities/Exercises.html`。
   - 全部4道习题，难度依次②②②③，题号1–4。
   - 保留非二的幂分辨率、513×513到1024×1024及最坏四倍内存、Lanczos/盒式滤波比较、原子/互斥统计方案、GPU统计对照实验。
   - 图10.16与第B.7节均保留为对应原书目标链接；没有将引用图错当成本页图片。
3. `Appendix-A-Sampling_Algorithms/A.6-Further_Reading.typ` ← `4ed/Sampling_Algorithms/Further_Reading.html`。
   - 源文9个叙述段全部补录，本地10个双语块（源文关于CDF搜索及GPU算法的一个长段拆为两块）。
   - 包含拒绝采样、别名法、蓄水池采样、圆盘映射、累积面积表、Hilbert/四叉树采样、自适应CDF、引导表、GPU/硬件光追/高斯混合，以及算术编码/Huffman树的全部论述。
   - 24条References全部按源文顺序、作者、年份、题名、刊物、页码补回。保留行内ξ和[0,1)条件。
4. `Appendix-B-Utilities/B.8-Further_Reading.typ` ← `4ed/Utilities/Further_Reading.html`。
   - 13个源文叙述段全部补录双语；34条References全部补回。
   - 包括位运算、哈希、补偿算术、方差、数值分析、样条、PCG、Unicode、伽马校正、并行编程/编译器内存语义、OpenMP及工作窃取。
   - 书目中的2×2行列式保留数学，原书没有其他显示公式或图像；新增一条明确标记的Hatch网址校订注，不冒充原文。
5. `chapter-16-Retrospective_and_the_Future/chapter-16.6-Further_Reading.typ` ← `4ed/Retrospective_and_the_Future/Further_Reading.html`。
   - **固定原文没有叙述段，标题后直接是References**。因此只补双语标题与全部114条书目，不编造中文叙述。
   - 114条全部人工录入，原顺序、作者、年份、题名、刊物、页码、arXiv编号及外链保留。没有新增虚构摘要。

三份References总计172条。书目题名作为原文文献元数据保留英文，标题提供中英文选择；此策略与已处理的1.7一致。

## 引用与排版约定

为避免与其他章同名书目锚点冲突，原文 `cite:<key>` 映射为：
- 第16章：`tail16-cite:<key>`。
- 附录A：`taila-cite:<key>`。
- 附录B：`tailb-cite:<key>`。

所有原书key保持不变，只增加上述命名空间。A/B正文与习题使用对应本地书目链接。原文代码定义、节和图的链接保留固定原书路径；它们不是伪造的本地页面。共有172个本地书目锚点，各自一对一映射原书条目。

标题采用公共ez_caption；习题用显式enum起始序号保持三种语言模式题号一致；References标题设为sticky，避免单独滞留页尾。代码标识符没有翻译，数学关系没有改写。

## 已识别源文问题

- **TAIL-URL-01**：B.8 Anderson2004书目把网址的~写成不换行空格，而同页首段给出正确 `http://graphics.stanford.edu/~seander/bithacks.html`。依同一固定源文首段修复书目href及显示文字；用text保留字面~，避免Typst将其当不换行空格。
- **TAIL-URL-02**：B.8 Hatch2003书目网址同样含不换行空格，但固定范围内无正确地址依据。保留原始网址文字，英中明确标记编辑说明，不生成明知残损的链接；目标尚未核实。
- A.6原文拼写 `rectangluar` 原样保留英文，中文按明确语义译为矩形。
- B.8源文1987/1989条分别写Ramshaw L./R.，第16章部分元数据亦有可疑原样值（如Chen2017的`arXiv:1707:09405`）。未凭记忆改写作者或编号，不将其标为外部文献真实性已核实。

## 自检证据

- 172条本地书目key与三个固定原文References集合一一相同，无缺项或额外条目。
- 人工复读后做逐条文本比较：去除排版、空白和直/弯引号差异后，114条、24条全部一致；34条仅Anderson已说明的URL修复一处有差异。Jeannerod条的SVG数学按原文2×2比较。
- A/B英文全文对照：B的13段一致；A为源文一个长段拆成两块，内容连缀后对应完整，不能把块数差异当作遗漏。
- 所有本地书目引用目标均已定义；原书页面/锚点链接自检无缺页/缺锚点（最终代码名链接补齐后复查见补记）。
- `git diff --check`通过。
- 正式全书入口main.typ，Typst0.13.1，`--root . --font-path fonts`，分别LANG_OUT=zh、en、不设置：首轮及代码链接修复轮均退出0。
- 构建有范围外公共backmatter告警：`block may not occur inside of a paragraph and was ignored`，涉及References/索引中的数学image，已报主agent；不能把退出0当作这些数学内容正常显示。
- PDF书签中公共ez_caption/context标题出现空字符串，正文标题可见；已报主agent，不以此宣称目录/书签验收完成。
- 已实际查看中文页1063、1095、1098、1199、1202，覆盖三份延伸阅读入口、114书目开头、A/B全部习题及数学；无裁切/重叠。发现A的References标题孤悬后加sticky，并发现显示URL中~须用text，已修正。最终复建结果补记于下。

下一步：另一agent应重新完整读取五份固定原文和全部双语、172条书目，独立复核，不只相信上述计数或构建。当前五文件属于已补录、待独立复核范围，不代表附录或全书其他内容已精校。

最终补记：A.6将References标题与首条书目组成不可拆块后，正式全书三语全部退出0；最终日志均为0警告、0错误（主agent已修复先前公共backmatter告警）。复看最终中文第1095页（公共布局更新后页码改变），标题与首条书目在同页，孤悬已消除；Anderson网址~也已实际显示正确。PDF书签问题仍由公共模板验收跟进。五文件已释放给另一agent独立复核。
