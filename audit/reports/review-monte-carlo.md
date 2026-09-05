# 2.0／2.1 独立复核

复核者：edit_introduction（不同于初校 agent）。状态：原文与译文逐段复核后修改完成；正文覆盖可记 verified，但以下源文技术局限和全书构建阻碍必须另行保留，不能据此宣布全书或排版验收通过。

独占文件：chapter-2-Monte_Carlo_Integration/chapter-2.0-Monte_Carlo_Integration.typ、chapter-2-Monte_Carlo_Integration/chapter-2.1-Monte_Carlo_Basics.typ。

## 重新阅读证据与范围

没有先读初校报告。直接完整阅读上述两份双语文件，随后完整阅读固定子模块的 4ed/Monte_Carlo_Integration.html 和 4ed/Monte_Carlo_Integration/Monte_Carlo_Basics.html（HEAD f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c）。临时 Ruby 去标签仅用于显示原文，MathJax SVG title 全部保留；另外直接读取 3 条 2.1 脚注和 2.0 脚注的原始 tooltip HTML，避免去标签遗漏。

上下文：读取本地 2.2 开头分层采样段、附录 B.2.11 开头并定位第 13 章标题，以验证邻节与引用目标。

覆盖：2.0 全部 4 段、章标题、开篇图片和 1 条脚注；2.1 全部 56 段、节标题和 4 子标题、全部 30 个显示公式（其中 11 个原书编号公式）、全部行内公式和 3 条脚注。2.1 无图片、图注、代码或表格；两页无习题和延伸阅读。原网页公共导航/版权层由主 agent 处理。

原文锚点：sec:mc-basics、BackgroundandProbabilityReview、ExpectedValues、TheMonteCarloEstimator、ErrorinMonteCarloEstimators；编号公式 eq:conditional-2d-density 至 eq:sample-variance-basic 全部逐式检查。

## 独立复核发现并修复

- 误差段仍写“随样本数量减少”，逆转了关系；明确改成随样本数增加，以 O(n^(-1/2)) 速率减小。重读源文及后段渐进渲染论证确认。
- 大量“抽样”改为规范“采样”；修复 BVHLightSampler 是先选择用于采样的光源，而非直接从已选光源采样的动作表达。
- CDF 改为“随机变量取值小于或等于 x 的概率”，明确事件，避免说成分布本身小于 x。
- 清晰区分有偏估计量、估计值、方差阶；稀有事件示例明确十个随机样本“恰好”都为 1，避免暗示主动只选取值为 1 的样本。
- 2.0 采样函数不是采样方法；保留 on average 的强调。
- 把原文已有但本地硬编码的第 13 章、公式 2.4／2.5、B.2.11 转为实际存在的引用；数学关系没有改变。

上述修改后再次逐项对照原文检查。初校修复的下列关键内容通过复核：PDF 为 [0,1) 半开区间；离散采样不等式左右端点；一般估计量 f(X_i)/p(X_i)；|f(x)|>0 处 p(x) 必须非零；独立条件下方差相加；一般估计量的积分推导；样本方差 n-1；MSE=方差+偏差平方；相合性与无限方差脚注；Kalos/Whitlock 页码 36–37。没有凭数学常识替换原书公式。

## 固定上游技术局限（保留原文，不擅自改公式）

- 连续随机变量例子和 PDF 解释使用“取某一特定值的概率”这种口语说法。严格区分时应使用概率密度或小邻域概率；当前中译忠实于固定原文。全书术语/技术注释统一处理时应考虑说明，不能据此把点概率与密度混为一谈。
- 正文的“方差随样本数线性减小”措辞实际上由公式和上下文表达为与 n 成反比；中文已按明确数学关系表达，英文保留原书措辞。
- 末尾 MSE 经验公式直接使用 f(X_i)，原文没有在此重新交代该项与一般积分估计量样本的关系。本轮按源文保留，不能推广宣称对任意 f/p 估计器都直接适用。
- 原文将任意三个区间的笛卡尔积称作 cube；本轮未把原文立方体自行改写为长方体。

## 构建证据与限制

使用主 agent 指定 Typst 0.13.1（8ace67d9）：
`/tmp/pbrt-tools/typst-aarch64-apple-darwin/typst compile --font-path fonts --input LANG_OUT=zh main.typ /tmp/review-mc-full-zh.pdf`

正式全书入口编译失败，仅报告 template.typ:169 中 numbering(el.numbering) 的 el.numbering 为 none，已通知主 agent。这可能与其他在并行集成中的直接公式标签引用有关；不是以临时禁用引用得出的“通过”。本轮没有成功 PDF，不声称视觉验收通过。git diff --check 通过。
