# 1.2 原文对照修改

状态：awaiting_review。存在明确上游缺陷，不能无条件标记整节已验证。

独占正文：chapter-1-Introduction/chapter-1.2-Photorealistic_Rendering_and_the_Ray-Tracing_Algorithm.typ。
固定来源：pbr-book-website/4ed/Introduction/Photorealistic_Rendering_and_the_Ray-Tracing_Algorithm.html，HEAD f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c。

## 实际审阅范围

直接读取固定 HTML 全部正文，另用临时 Ruby 去除 HTML 标签、保留 MathJax title 辅助逐段阅读；没有使用旧 Scripts、翻译提示词或批量模型调用。原文数学 SVG 的 title 与上下文均已核对。

覆盖 sec:photorealistic-rendering-context、CamerasandFilm、RayndashObjectIntersections、LightDistribution、Visibility、LightScatteringatSurfaces、sec:indirect-light-transport-basics、sec:intro-ray-propagation 至正文结束。包含 46 个本地正文/列表双语块（7 项列表计入）、1 个节标题、7 个子标题、全部 11 个图注、12 个图片资源（图 1.11 两图）、2 条脚注、5 个显示公式（其中 eq:rendering-equation 编号为 1.1）及全部行内公式。无代码块、数据表、独立习题或延伸阅读。用于两图排列的 table 是布局，不是原书数据表。

图锚点逐一覆盖：fig:pinhole-camera、fig:pinhole-camera-simulation、fig:moana-island-view、fig:point-light-irradiance、fig:point-light-two-spheres、fig:intro-manylights、fig:point-light-shadows、fig:intro-surface-scattering、fig:head-bssrdf-example、fig:intro-raytracing-example、fig:intro-volumetric。

## 关键修正

- 修复“辐射度/出射辐射”对 radiance 的错误翻译，统一辐亮度；恢复 Whitted 积分简化段的方向条件，删除中译无依据的 L_i(p,omega_o)。
- 修复阴影测试中的光源/光线混淆、参数 t 比较语句破损，以及 shaded point 被误译为阴影点/被遮挡点。
- 修复相机与胶片职责的整句错位、半径 r 漏译、微分面积错误译为“差异区域”、参与介质漏词及透射率含义。
- 英文 photon 强调损坏修复；补回原文给定射线 r、参数 t、二次方程变量 t、图注 p/omega_i/omega_o、BRDF 点 p 和方向 omega；修复英文 n 语序及部分空格。
- 单位球面功率 Phi/(4pi) 明确分母括号，依据上游数学 SVG；显示公式的关系未改。
- 所有 @fig:... 与 @eqt:rendering-equation 改为实际已有标签。其余跨章引用保持。
- 图 1.11 原图片顺序与上游 a/b 相反，改为左 Whitted、右 SPPM，加 a/b 标识；移除图注内重复硬编码 Figure 1.11，交由 figure 编号。
- 全部标题、图注、脚注同步精校；图注中的人物/机构署名保留。

## 未决与限制

1. 固定上游约 1491 行，BSSRDF 段的 “The BSSRDF is described in” 后直接接 Figure 1.10，确实缺目标。英文保留，中文显式说明并加译注，未猜章节。
2. 固定上游 fig:intro-raytracing-example 图注重复 “algorithm” 并含未解析的 “Section sec:photon-mapping”。英文保留该文本，中文给出字面内容与译注，不伪造有效链接。
3. 光线与球面求交原文“若有根则最小正根”未覆盖只有负根情况；本轮忠实保留，未擅自改写原书数学条件。
4. 术语“照片级真实感、视域、视点、阴影射线”已获主 agent 同意。

## 验证

- git diff --check 通过。
- 临时入口加载公共 pbrt 模板与本节，调用 typst compile --root . --font-path fonts --input LANG_OUT=zh：失败。预期跨章引用因入口只含本节而缺失；另外公共 template.typ:167 对公式引用调用 numbering(el.numbering) 报 expected string or function, found none，已报主 agent，未改公共文件。
- 不以语法未报错代替构建通过；尚无成功三语言 PDF 或视觉验收。临时入口已删除。
- 需要独立 agent 重读原书和修改后完整正文。此报告不是独立复核。
