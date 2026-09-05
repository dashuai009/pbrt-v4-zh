# 五个原空文件补齐后的独立复核

复核者 edit_introduction，非初校 agent。五文件原文对照与本轮修复已完成并释放；Hatch 外部地址仍明确待核实，不能因此宣称全部外部链接有效。

范围：chapter-16.6-Further_Reading.typ、Appendix A 的 A.6/A.7、Appendix B 的 B.8/B.9。固定原书对应 4ed/Retrospective_and_the_Future/Further_Reading.html、Sampling_Algorithms/{Further_Reading,Exercises}.html、Utilities/{Further_Reading,Exercises}.html。

固定完整提交：`f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`。

## 实际完整阅读

先重新完整读取五份本地内容，再完整读取对应原HTML正文和所有书目；未依赖初校摘要。源HTML数学SVG title用于逐式对照，并直接查看原链接属性以核实Hatch/Anderson。

- 16.6：固定原文标题后直接进入References，没有待补译正文。114条书目全部核对，首项Áfra2012，末项Zhu2021，包含作者、题名、年份、出版信息、页码、arXiv及URL。
- A.6：10段完整正文、24条书目；全部技术来源、算法归属、限制与代价条件核对。算术编码段的[0,1)和ξ保留。
- B.8：13段完整正文、34条书目；另有明确区分为校订说明的Hatch地址注记。数值补偿、区间算术、PCG、Unicode、伽马及并行/线程论述均逐段核对。
- A.7：完整3题，难度①②②。B.9：完整4题，难度②②②③。条件CDF的P(y|x)、513×513→1024×1024及最多四倍内存、原子操作/互斥/线程局部存储条件均一致。
- 固定五页没有额外原书脚注、代码块或图片，不能虚计“脚注已处理”；保留了全部行内标识符、数学及引用。

## 逐条书目与链接证据

`audit/reports/missing-tail-reference-evidence.json`包含172条源／本地逐项对照数据：原锚点、源行、完整文字、链接序列及本地行。使用独立HTMLParser解析、并读取Typst可见文字；仅归一化空白与弯/直撇号。不是只比较计数或集合。114/24/34条顺序及id均一致，文字及链接除下面两项明确处理外均相同。

`audit/reports/missing-tail-links.json`记录56次原书代码/章节链接，全部固定目标文件与id存在。116次本地tail引用全部有对应书目锚点。这不代替外站HTTP检查。

## 独立确认的地址处理

- Anderson：Utilities/Further_Reading.html:83正文href和可见文本明确给出`http://graphics.stanford.edu/~seander/bithacks.html`；同页185行书目href却包含`&nbsp;seander`。本地书目修为正文给出的地址，有同一固定页的直接依据，不是猜测。`#text`使可见的波浪号不被Typst解释为空白。
- Hatch：同页约243行href确为`http://www.plunk.org/&nbsp;hatch/rightway.html`。本地保留原文字/NBSP，取消未经验证的超链接，并明确注记。没有足够依据证明应替换成哪个当前地址，本次不猜补。

## 独立修复

1. A第2题中文保留了PiecewiseConstant2D名称，但遗漏其原定义跳转；已补回与英文一致的原书链接。
2. A第1题的“两个蓄水池中全部样本”可能被理解为仅当前存储的两个样本。重新阅读固定Reservoir_Sampling.html约540–556行的Merge说明（all samples seen by the two）及代码后，改成“两个蓄水池各自处理过的全部样本”，保留原权重比例。

修复后重新读对应原文及最终中文。其余正文没有发现需要更改的语义问题；不对原书引文事实进行无依据的更新，例如书目原有年份/作者缩写保留。

## 正式构建与实际页面

Typst0.13.1、正式main.typ、--font-path fonts：中文／英文／对照均退出0，输出`/tmp/review-missing-tail-{zh,en,bilingual}.pdf`。git diff --check通过。

中文正式全书实际查看1062/1068页（16.6书目首尾）、1094页（A.6全部10段）、1097页（A三题）、1199页（B书目开头及Hatch注记/Jeannerod2×2）、1201页（B四题）。书目和题号未重叠或裁切，条件CDF与乘号可见，难度图标及完整最后一题可见。英语/对照仅本轮构建验证，不扩大为全页视觉验收。

这五页源内容已逐项对照；全局bibliography与完整书目去重仍由主agent统一处理。
