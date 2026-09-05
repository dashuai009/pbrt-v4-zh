# 3.0–3.2 几何基础精校

状态：awaiting_review。需另一 agent 对正文及补充代码独立复核。

独占：chapter-3-Geometry_and_Transformations 下 `chapter-3.0-Geometry_and_Transformations.typ`、`chapter-3.1-Coordinate_Systems.typ`、`chapter-3.2-n-Tuple_Base_Classes.typ`，另按主 agent 要求新增 `supplements/3.2-expanded.typ`，由3.2末尾无编号补充部分include。公共模板未修改。

依据：固定子模块 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c` 的 `4ed/Geometry_and_Transformations.html`、`Geometry_and_Transformations/Coordinate_Systems.html`、`n-Tuple_Base_Classes.html`。全文直接读取，公式读取SVG title，折叠面板逐段读取，另读本地3.3向量类开头理解Child用法。

## 正文覆盖

- 3.0：整段导言、章标题、killeroo-control.jpg章首图，图元类属于第6章的限定。原图无图注。
- 3.1：全部6段正文；坐标系、标架、仿射空间、向量/点表示、标准标架、左右手系；全部2条无编号公式；图3.1及3.2的2个SVG和完整双语图注；Handedness小标题。
- 3.2：全部14段说明和11项功能清单；CRTP唯一脚注；全部9个可见文学代码块（Tuple2定义/成员，Tuple3定义/构造/成员/HasNaN/两个索引运算符/加法运算符）；完整参数、const/引用返回、decltype类型提升、NaN检查与优化模式限定。
- 三页无数据表、习题正文、延伸阅读正文、参考文献列表或索引正文。3.2原文功能列表省略的通用实用函数实现本来未展示，不凭函数名声称审校了其实现。

## 折叠内容逐项处理

原书 `n-Tuple_Base_Classes.html` 中全部4面板：

| 面板 | 内容 | 本地承载 |
|---|---|---|
| fragbit-73 | Tuple2 Public Methods 全部方法，未在本节可见正文列出 | supplements/3.2-expanded.typ 第一个代码块，99源行；完整保留包括预处理条件、CPU/GPU宏、检查与注释 |
| fragbit-74 | `T x{}, y{};` | 已有 fragment-Tuple2PublicMembers-0，组合重复不再插入 |
| fragbit-75 开头 | Tuple3构造、HasNaN、const索引、可写索引、operator+ | 已有 fragment-Tuple3PublicMethods-0至4；逐项一致，组合重复不再次插入 |
| fragbit-75 其余 | 从 nDimensions=3 开始的额外方法 | supplements/3.2-expanded.typ 第二个代码块，82源行；包括调试复制/赋值、+=、减法、比较、标量乘除、取负、ToString |
| fragbit-76 | `T x{}, y{}, z{};` | 已有 fragment-Tuple3PublicMembers-0，组合重复不再插入 |

补充代码逐项与固定HTML核对，转换只移除HTML标签、统一外层缩进，没有改变量名、算法或条件。尤其Tuple2与Tuple3的除零/NaN检查并不相同，原样保留，未擅自“统一”。英文代码注释保留原文，补充标题与说明双语。正文和补充共用同份Typst，不为网页另写代码内容。

## 修正

- 3.0 nontrivial不再译“非平常”；几何数学基础类与实际场景几何类的指代厘清；标题双语化。
- 3.1中文漏掉向量v的“表示”对象，且把空间任意向量误写成基向量v_i，已依据原文修正。两条公式省略号改为原文居中省略号、vn下标排版统一；图3.1末句恢复原文点p标识。残留英文and、异常分号及断裂图注修复。
- frame暂用“标架”、coordinate system“坐标系”、handedness“手性”，已交主 agent统一术语；linear independence用“线性无关”。
- 3.2全面修正“语言角落”“同情封装”“如果一个添加”等翻译腔；分量与组件区分、读取/修改函数、同一派生类不同分量类型、按分量最小值与所有分量最小值等含义明确。
- Tuple2/Tuple3原有假URL改为真实本地类标签，两类代码块上恢复 `<Tuple2>`、`<Tuple3>`。片段标题从伪代码注释移出，恢复原片段0–4导航。列表原有 `Tuple3::Abs` 等假相对URL改为源原本的代码名，并建立真实同名标签，避免把锚点误作URL。
- DCHECK跨页链接改为原书完整URL；原书源码GitHub路径仍按固定源保留，它指向master且未在此任务验证外部实时可用性，需全站外链检查处理。
- 无数学算法改写；代码骨架保留原文学片段占位符，不宣称单个骨架可直接作为C++编译。

## 验证与实际渲染

使用 Typst 0.13.1、公共template导出pbrt、fonts，屏蔽外部ref的三文件+补充独立入口，三语编译通过：`/tmp/audit-geometry-zh.pdf`、`/tmp/audit-geometry-en.pdf`、`/tmp/audit-geometry-bi.pdf`。

实际渲染并查看补充代码中文第8、9、10页，PNG位于 `/tmp/audit-geometry-page8.png`、`page9.png`、`page10.png`（后两者同audit-geometry前缀）。发现Tuple3补充小标题孤悬前一页页底，已将两个补充小标题设为sticky block；重新渲染9/10页确认标题与后续代码同页。长代码跨页连续，行49接续行48；所查页面未裁切，长行在单元格内折行。

仅检查了补充代码代表页，不宣称正文图片、全部PDF或网站手机布局已视觉验收。三语编译在sticky修复前通过，sticky修复后中文重新编译/渲染通过；其余语言后续由集成构建覆盖。临时入口已删除，独占文件git diff --check通过。

无未决中文技术含义问题；术语需主agent最终统一，外部源码URL实时状态未验证。正文与补充均待独立审校。
