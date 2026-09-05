# 1.5–1.8 对照精校与补译

状态：awaiting_review。四个正文文件已释放，等待其他 agent 独立对照复核。

独占：
- chapter-1-Introduction/chapter-1.5-Using_and_Understanding_the_Code.typ
- chapter-1-Introduction/chapter-1.6-A_Brief_History_of_Physically_Based_Rendering.typ
- chapter-1-Introduction/chapter-1.7-Further_Reading.typ
- chapter-1-Introduction/chapter-1.8-Exercises.typ

## 基线与实际范围

固定上游 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c 的 4ed/Introduction 下 Using_and_Understanding_the_Code.html、A_Brief_History_of_Physically_Based_Rendering.html、Further_Reading.html、Exercises.html。四份原文完整重新读取并与完整本地中英文本对照；数学 SVG title 保留用于阅读，1.5 两条脚注另查原始 tooltip。未用旧 Scripts 或批量模型调用。

1.5：51 个本地双语块，全部 12 个子节（Source Code Organization 到 Bugs）、6 个目录项、4 步错误报告列表、2 个代码块、Allocator 片段标题、2 条脚注和全部行内数学/标识符。无图片、显示公式、数据表。
1.6：31 个双语正文/列表块，Research、Production 两部分，3 项制作优势、2 图及完整版权/署名图注、全部历史日期/成本/计算量/行内公式。无代码、脚注或数据表。
1.7：13 个原文段落及完整 References 的 61 条原书书目，未漏掉正文后的文献清单。条目按原书拼写、年份、出版物、页码保留英文 bibliographic 信息，不翻译书目题名。参考文献标题为双语选择，并不额外编号。
1.8：固定原书只有 1 道习题，全部逐句对照；恢复难度图标 ①，保留枚举编号，radiance 统一“辐亮度”。没有臆加其他习题。

## 缺漏与关键修正

- 1.7 原本全部英文裸排后附中文，中文只到 Vision；漏掉后 5 段。现补译娱乐渲染器、OptiX、较新生产渲染器、2018 年五篇系统论文、Mitsuba 2 全部内容，并全部组织成共用正文的 parec，中英文单语不再混排。
- 1.7 原书 References 61 条整段未转录，现全部补回各自 cite: 锚点；1.6 的所有文献链接转到这些本地条目，检查目标集合无缺项。
- 1.6 原来两图指向 pha01f21/22.svg，固定上游实际为 gravity.png、alita.png，现使用正确电影图片，保留署名和完整版权声明。
- 1.6 补回中文遗漏的 Radiance、Vision、RenderMan 名称；修复 bridge the gap 整句误译、计算量与计算能力混淆、着色误译为阴影、离焦/光泽/面光源术语、内存容纳与流程等表达。
- 1.6 英文残存 LaTeX 的 256×256 改为实际 Typst 数学。数值 7 小时、280,000 美元等保持原书。蒙特卡洛、基于物理、延伸阅读、光栅化统一。
- 1.5 补回 Allocator 传入对象创建方法这一遗漏；补回 pstd 的“相同类型”；修复动态分派段合句破损、线程安全前提、图元/材质术语、并行脚注英文 ndconstruction 缺字。
- 1.5 调试参数根据固定源文由 -debugstart 修为 --debugstart；中文保留实际英文诊断消息，便于与运行输出对照。
- 移除各处 ] 后错误残留分号及相连标点；实际代码中的分号未改。
- 1.5 Allocator 代码片段标题移出 C++ 代码块，使用 sticky block；实际 using 和三个声明原样保留。
- 四节及所有子标题支持中英文选择；1.5 的 @tbl:plug-in-types 保持主 agent 的统一映射。

## 引用策略与未决问题

- 1.5 原有指向其他节接口标识符的相对 HTML URL 会在 PDF/新网站中失效，改为固定原书路径对应的 pbr-book.org/4ed 绝对链接。它们是可用的原文跳转，尚未全部改为本地书内代码锚点；需公共 Web 映射层继续完成本地跳转。
- 1.7 的第 16.3.1 节暂用原书绝对链接，当前本地未发现可用目标标签，不伪造标签。
- 固定上游 1.5 自称 allocate_object 会默认构造对象；这与该标准库方法通常的原始存储语义可能不符。本轮忠实保留原文，需技术复核结合具体 pstd 实现决定是否加译注。
- 固定上游断言段写“检查不应为真的条件、为真时报错”，可能是在描述失败条件而非断言宏实参；本轮未偷偷反转原文，独立复核须注意这一语境。
- 原书 Exercise 中 nthreads 前是 en dash，现有转录使用单 ASCII 横线，本轮不推断它应有几条横线；需以接口版本核实命令行规范后决定统一排版。

## 验证

Typst 0.13.1 (8ace67d9)，main.typ 正式全书入口、--font-path fonts，分别 --input LANG_OUT=zh、--input LANG_OUT=en、不设输入：全部退出 0。
输出：/tmp/edit-code-history-zh.pdf、/tmp/edit-code-history-en.pdf、/tmp/edit-code-history-bilingual.pdf。

git diff --check 通过；1.6 引用的 cite 锚点全部存在于补回的 1.7 条目。

使用 PDF 技能和 pdftoppm，检查中文正式全书第 74、82、83、85 页：Allocator 代码与标题、两个正确电影画面及图注、漏译后五段与文献列表开始部分均实际可见，无裁切/重叠。此为代表性检查，尚非四节每页及三语言最终视觉验收，需独立复核及主 agent 全书验收。
