# 3.0–3.2 独立复核

复核者 edit_introduction，非初校 agent。正文及额外代码原文对照完成；最新全书构建/视觉因其他范围并行集成暂未完成。文件已释放。

范围：chapter-3.0-Geometry_and_Transformations.typ、chapter-3.1-Coordinate_Systems.typ、chapter-3.2-n-Tuple_Base_Classes.typ，以及 chapter-3-Geometry_and_Transformations/supplements/3.2-expanded.typ。

## 独立阅读

完整读取固定 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c 的 4ed/Geometry_and_Transformations.html、Coordinate_Systems.html、n-Tuple_Base_Classes.html，包括所有折叠面板。完整重新读取本地双语和补充代码，不以初校报告或计数为证据。

3.0：1段、章标题、开篇图片。3.1：6段、2图及图注、2个显示式、全部行内数学、左右手子节。3.2：26个双语块（包括补充说明）、9个正文代码块、11项能力列表、1条CRTP脚注以及Tuple2/Tuple3全部额外实现。

核对重点：原点和线性无关基向量、点与向量不可自由互换、世界空间标准基、pbrt左手系与z轴内/外方向；Child<T>/Child<U>的类族与分量类型区别、返回类型decltype(T{}+U{})、索引const值与非const引用、所有列表函数返回值的区别。

## 额外99／82行真实性

直接从固定HTML提取 fragbit-73 的 fragmentcode，去HTML标签并解码实体，再与补充Tuple2代码逐token比较（仅忽略空白），99行完全一致。

对 fragbit-75，前部依次是正文已有的构造函数、HasNaN、两个索引运算符、operator+；从 `static const int nDimensions = 3;` 起的余下82行与补充Tuple3代码逐token完全一致。

同时人工完整重读双方代码，确认PBRT_CPU_GPU、PBRT_DEBUG_BUILD、断言、返回引用的static_cast、各算术/比较/索引运算符和ToString未遗漏或改写。Tuple3默认构造函数在固定面板本来没有，不臆加一条让代码看起来完整。两组补充不包含前部正文重复项。

## 独立修复

- 3.0几何数学对象ray统一为“射线”。
- 3.1英文基向量的bold(v_i)改为bold(v)_i，使粗体只作用于向量符号，按原数学SVG保留下标样式。
- 3.2九个裸代码片段框改为sticky block，去除额外印出的方括号；全部短代码块保持整体不跨页。Tuple2/Tuple3标签仍附在原代码块，其他片段/工具方法标签未改。

## 源文/导航限制

- 固定原文将 `T x{}` 等称为“default initialized”；中文按源文用“默认初始化”，数值结果0与代码一致，但若按C++精确术语区分初始化形式，应在统一技术审校中说明，不能把这句话推广到未显式初始化的数值变量。
- 源文github路径确为 `/src/util/vecmath.h` 和 `.cpp`，本地沿用。它与1.5介绍的src/pbrt源目录组织可能不一致；本轮未验证目标的在线可达性，也未擅改到猜测路径。
- 正文中的工具函数列表不是这些函数完整实现；固定本节只列接口用途，未把其他章节的实现误计为本节漏译。

## 验证

`git diff --check`通过。正式main.typ，Typst0.13.1，三语言构建均未在本范围报错，但受并行范围缺项阻断：3.8的concentric-hemi-mapping引用吞入后接中文，A.7的taila-cite:Lawrence05和B.9的tailb-cite:Guthe05缺失。已通知主agent，未改其他agent文件。

主agent说明A引用已补齐，B引用仍在写入，要求不重复构建动中快照。本报告据此明确：最新三语言正式构建/视觉未验收，不能用其他批次旧PDF冒充本次最终结果。文字和代码来源复核完成，与构建/版式状态分开记录。
