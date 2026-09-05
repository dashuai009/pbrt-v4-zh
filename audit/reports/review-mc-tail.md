# 2.3–2.6 独立复核

复核者：edit_introduction，非初校 agent。四文件文字、公式、代码已独立对照；仍保留以下源文技术问题、书目差异及网站链接未验证状态。状态不等于全书构建或排版验收完成。

## 实际审阅范围

完整读取固定子模块 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c 的 4ed/Monte_Carlo_Integration 下 Sampling_Using_the_Inversion_Method.html、Transforming_between_Distributions.html、Further_Reading.html、Exercises.html，并重新完整读取四份本地中英文本。提取辅助文本保留每个数学 SVG 的 title；2.3 唯一脚注直接对照原文 tooltip。没有先依赖初校摘要。

- 2.3：29 个双语块，全部 7 个显示公式、10 个 C++ 代码块、3 图和图注、1 条脚注、连续采样三步以及所有片段标题。代码展开副本与后文片段逐项一致；不把相同展开副本重复计为缺失代码。
- 2.4：33 个双语块，20 个显示公式、5 个 C++ 代码块、雅可比矩阵、边缘/条件分布推导和全部行内数学。无图、原书脚注。
- 2.5：全部 10 段及固定原 References 的 33 项；33 项对应的公共 bibliography.bib 条目均已阅读。正文与引用不能仅因文件存在而算完整。
- 2.6：固定原书全部 3 题，难度标记分别 ②、①、②，全部题干及数学条件核对。

## 独立确认与修复

- 2.3 首段的“累积分布函数求逆（CDF）”括号位置错误，改成“累积分布函数（CDF）求逆”。
- 2.4 “若随机变量独立，它们可表示为密度乘积”主语混淆，明确为“联合密度可以表示为一维密度的乘积”。
- 2.4 “选择 x/y 作为边缘分布”改为“对 x/y 求边缘分布”；SampleLinear() 归一化的指代明确，避免误指 p(y)。
- 2.3/2.4 全部代码片段标题由裸 [...] 改 sticky block，防止多印方括号、标题留在前页而代码在后页。
- 小量 PDF 中英文间距修复。所有代码标识符、算法语句与数学关系保持固定原文，不擅改边界。

确认 SampleDiscrete 的空输入路径、sumWeights 缩放、NextFloatDown、while <=、pmf/uRemapped 可选输出及 OneMinusEpsilon；Lerp/LinearPDF/SampleLinear/InvertLinearSample 全部代码一致。确认 Jacobian 绝对值、球坐标 r²sinθ、双线性四角权重、边缘先采 y/条件后采 x、逆操作顺序以及全零 BilinearPDF 代码路径。

## 源文技术条件：独立确认，仍需保留

- 2.4 固定原文确实将一对一直接推成导数处处严格同号，并在允许递减的文字后使用同向事件不等式。初校译注正确指出问题；递减时该事件等式不能照用，多对一也并不意味着无法定义密度。本轮保留原文与公式。
- 2.6 第 2 题确实写 O(n)，不是初校误转录；保留题干及提示，不私改为 O(1/n)。
- 2.3 只明确“非负”权重，没有说明非空全零权重不适用；代码有除以总权重。LinearPDF/SampleLinear 只说 a,b>=0，没有排除 a=b=0 的退化情形。2.4 BilinearPDF 全零返回 1，但 SampleBilinear 仍调用 SampleLinear。不得宣称这些代码覆盖所有退化输入；本轮没有擅自改变上游实现。
- 2.3 寻找 offset 的散文使用 greater than，而代码及前述数学式包含下界相等情形。中文沿用原文解释，精确边界以保留的公式和代码为准；后续统一技术注释应明确这一点。

## 公共书目与原文链接

Hart 2020：六位作者、题名 Practical product sampling by fitting and composing warps、Computer Graphics Forum 39(4)、149–158，与固定原文一致。

Owen 2019：作者 A. B. Owen、题名、年份一致。固定原书 href 和可见文本确实为 `https://statweb.stanford.edu/&nbsp;owen/mc/`。公共条目用 `~owen` 是修复候选，不是固定源原样。本轮独立访问该候选：web 工具拒绝打开，curl -IL 报 TLS SSL_ERROR_SYSCALL，不能标为线上链接已验证。

33 项均在公共 bib 有对应条目，但存在需主 agent 决议的元数据差异：固定源 Subr/Arvo 2007a 的会议信息写 Pacific Graphics ’97，公共条目写 ’07；源 Sbert 2018 用 15 表示刊物编号，公共条目把 volume 设为 2018、number 设为 15。作者全名与源缩写也不是逐字相同。它们可能是合理的正规化或修正，但本轮没有其他固定来源证据，不擅改公共文件，不标书目逐字段完全一致。

## 验证快照

Typst 0.13.1、--font-path fonts、正式 main.typ。中/英/对照三次都被正在并行修改的第 3.2 节 Tuple2/Tuple3 标签缺失阻断（19/21/160/162 行）。已通知主 agent，不重复构建动中快照、不删章或添加假标签，不声称正式通过。git diff --check 通过。最新代表页视觉检查等待集成稳定。

### 集成稳定后的正式验收补充

主 agent 通知 Tuple 标签已修复后，重新用正式 main.typ 构建。三语言均成功退出 0，输出 /tmp/review-mc-tail-zh.pdf、/tmp/review-mc-tail-en.pdf、/tmp/review-mc-tail-bilingual.pdf。

使用 pdftoppm 查看中文 PDF 107–111、113–116 共 9 页，实际覆盖三个分布图、边界公式、全部重要代码、线性逆变换、变换密度、雅可比矩阵、边缘与条件采样。

视觉检查发现并修复两项：
- 2.4 二维雅可比原 `partial x / partial r` 被 Typst 排成 `∂(x/∂)r` 而非 `(∂x)/(∂r)`。四个元素均依据固定原式改为显式 frac(partial x, partial r) 等，未改变数学意义。114 页重新渲染确认。
- 2.3 的 3–4 行小代码块被公共 raw 渲染跨页拆散；2.3/2.4 的 15 个代码块加不可分页 block，保持整体。另去除第 3 图图注外围多余空段，使“图 2.5”与图注同行。110 页重新渲染确认代码和标题完整、图注不再单独留图号。

最新仅中文代表页做了视觉检查；英文与对照完成正式全书构建，未宣称其每页视觉验收。四文件现已释放。以上源文数学条件和 Owen 链接问题仍保持未决，不能被成功编译覆盖。
