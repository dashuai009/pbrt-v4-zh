# 1.2 独立复核

结论：已重新阅读固定上游全文、数学 SVG 的 title、脚注属性和完整双语本地文件，并修复本轮发现的问题。**可将已对照内容标记为完成独立语义复核，但不能将本节记为无未决问题：下列上游残损、公共排版问题仍未解决。** 不是仅审阅初校摘要或差异。

独占修改：`chapter-1-Introduction/chapter-1.2-Photorealistic_Rendering_and_the_Ray-Tracing_Algorithm.typ`。未修改公共模板、文献库或序言。

## 来源与覆盖

固定提交 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`：

- `4ed/Introduction/Photorealistic_Rendering_and_the_Ray-Tracing_Algorithm.html`：从 `sec:photorealistic-rendering-context` 起至 `sec:intro-ray-propagation` 正文结束。
- 相邻上下文：`4ed/Introduction/Literate_Programming.html` 末段以及 `4ed/Introduction/pbrt_System_Overview.html` 起始接口说明，对照本地对应上下文。
- 逐项核对 46 个双语正文/列表块、7 项模拟任务列表、7 个子节、11 个图注及 12 个图像文件、2 条脚注、5 个显示公式和行内数学。
- 图锚点：`fig:pinhole-camera`、`fig:pinhole-camera-simulation`、`fig:moana-island-view`、`fig:point-light-irradiance`、`fig:point-light-two-spheres`、`fig:intro-manylights`、`fig:point-light-shadows`、`fig:intro-surface-scattering`、`fig:head-bssrdf-example`、`fig:intro-raytracing-example`、`fig:intro-volumetric`。
- 无独立代码清单、数据表或习题；两图用 table 排列，不当作数据表。

## 复核发现、修复及重新检查

1. **引用回归**：初校把 `@fig:…`、`@eqt:rendering-equation` 误改成原始元素标签。重新读取本机 i-figured 0.2.4 的 show-figure/show-equation 实现，确认它生成带前缀的实际编号元素。恢复全部图引用（包括 Moana）和公式引用。修复前 0.13.1 全书构建在 `template.typ:169` 因原始公式 `numbering=none` 失败；修复后三语全部成功，并在 PDF 实际确认图 1.11、公式 (1.1) 及引用编号一致。
2. **数学转换损坏**：实际渲染发现 `L_o (p,…)`、`L_e (p,…)`、`L_i (p,…)`、`f_r (p,…)` 会让 Typst 将函数参数一并置于下标。上游 SVG 明确仅 o/e/i/r 是下标。改为 `L_(o)(…)` 等显式下标分组，正文、图景说明与公式同步修复。重新构建并查看页图，参数回到正确基线。没有改动物理关系。
3. **数学符号样式**：原书数学 SVG 明确写作 script S²，将正文与积分域中的 `S^2` 恢复为 `cal(S)^2`。不改变积分域。
4. **限定条件**：`not a practical way to build a real camera` 原被译作“真实相机无法这样构造”，过强。改为“这种安排并不适合用来构造真实相机”。
5. **文献链接遗漏**：图 1.4 上游有 `Further_Reading.html#cite:DisneyMoana` 链接，本地只剩作者年份纯文本，公共 bib 暂无对应键。两语图注恢复指向该原书条目的外链，未杜撰文献记录。
6. 补英文数学句与括号之间空格，图 1.12 的 `pbrt` 恢复代码格式。

以上修复后重新通读相关段落，确认限定、最小正根原句、三维球面积分范围、绝对余弦、功率单位、1/r² 衰减、BSDF 与 BSSRDF 区分及透射率定义均未被擅自改写。

## 独立确认的上游问题

- **RAY-UPSTREAM-01**：约 1491 行 `The BSSRDF is described in` 后未给出章节，直接接图 1.10 说明。确属固定上游损坏；保持英文，中文明确译注。未猜目标。
- **RAY-UPSTREAM-02**：图 1.11 约 1558 行重复 `algorithm` 并残留 `Section sec:photon-mapping`。原始 JERI 配置明确 (a) spheres-whitted.png，(b) spheres-sppm.png，顺序已确认。残留章节不是有效链接，中文译注继续保留未决。
- **RAY-UPSTREAM-03**：球面求交段原书“if there are roots, the smallest positive one”未说明只有负根的情况。本地忠实保留，不据此宣称原书数学条件完备。
- **RAY-UPSTREAM-04**：复杂度脚注原书前称 Szirmay-Kalos and Márton，括号却写 Kelemen and Szirmay-Kalos 2001。此矛盾也原样存在，不能把它当作已核实的文献归属。

## 构建与视觉证据

使用 `/tmp/pbrt-tools/typst-aarch64-apple-darwin/typst`，版本 0.13.1，根目录、字体和输入如下：

- `compile --root . --font-path fonts --input LANG_OUT=zh main.typ /tmp/review-ray-zh.pdf`：最终修改后退出 0。
- `compile --root . --font-path fonts --input LANG_OUT=en main.typ /tmp/review-ray-en.pdf`：最终修改后退出 0。
- `compile --root . --font-path fonts main.typ /tmp/review-ray-bilingual.pdf`：最终修改后退出 0。
- `git diff --check`（本节）：通过。

按 PDF skill 使用 Poppler 渲染并实际查看中文第 42、45 页、英文第 47 页、中英第 61 页。这些页覆盖点光源衰减公式、图 1.6/1.7、图 1.11 两图、长图注、明确译注、渲染方程及公式引用。图序正确、公式下标修复正确、无裁切与重叠。**这些是本节代表性页，不是全书视觉验收。**

公共排版仍有可见问题：中文图注前缀仍显示 Figure；中英图注在 ez_caption 拼接处没有明确分隔。已通知主 agent，未私改模板。网页、移动端、全书链接与最终发布不在本次独立复核的验证范围。

## 后续交叉复核修正：RAY-UPSTREAM-05

独立复核1.7的完整61条References时，确认固定上游 `Introduction/Further_Reading.html` 没有 `id="cite:DisneyMoana"`。图1.4原文确实引用此不存在的目标。先前本复核恢复外链时仅核对来源href、未验证目标，是复核遗漏。经主 agent 重新授予1.2独占修改后，移除两语图注中的失效锚点链接，保留 `Walt Disney Animation Studios 2018` 字面作者年份，并在中文图注中明确标注上游书目条目缺失。没有猜补文献信息。该项应计作未决上游书目缺失；需要主 agent 刷新1.2内容指纹。
