# 第 2 章引言与 2.1 精校记录

状态：awaiting_review（已逐段原文对照，尚待另一 agent 独立复核；不代表全章或全书已精校）。

## 独占范围与原书依据

- `chapter-2-Monte_Carlo_Integration/chapter-2.0-Monte_Carlo_Integration.typ`：固定上游 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c` 的 `4ed/Monte_Carlo_Integration.html` 全正文、章标题、章首图及脚注。
- `chapter-2-Monte_Carlo_Integration/chapter-2.1-Monte_Carlo_Basics.typ`：同提交 `4ed/Monte_Carlo_Integration/Monte_Carlo_Basics.html` 全节；锚点 `sec:mc-basics`、`BackgroundandProbabilityReview`、`ExpectedValues`、`TheMonteCarloEstimator`、`ErrorinMonteCarloEstimators`；公式锚点 `eq:conditional-2d-density` 至 `eq:sample-variance-basic`。
- 在子模块检出前读取固定提交 raw HTML，随后用 `cmp` 确认两份读取内容与检出文件字节一致。读取 MathJax SVG 的 title 核对数学符号；另读 HTML tooltip title 中的脚注完整内容。相邻 2.2 开头用于理解方差缩减语境。

## 实际覆盖

逐段核对引言全部 4 段及 2.1.1–2.1.4 完整正文，包含离散/连续随机变量、条件概率、CDF/PDF、期望、均匀/一般估计量、方差、偏差、相合性、MSE、样本方差与 imgtool 结尾。

- 标题：章标题、节标题与 4 个小节标题添加双语选择。
- 数学：逐项核对行内公式及所有独立公式；原书编号 (2.1)–(2.11) 对应标签已覆盖。无编号公式同样核对。
- 图片：章首 dragon-blp-twosided-good.jpg 路径与原书对应；原书无该图图注。本节无其他插图。
- 脚注：引言 1 条、基础节 3 条全文核对并修正中文。
- 代码：无代码块；保留 RandomWalkIntegrator、BVHLightSampler、SPPMIntegrator、imgtool、diff 标识符。
- 引文：Ross (2002)、Kalos/Whitlock (1986) 核对；补后者原书页码 36–37。
- 表格、图注、习题、附录正文、延伸阅读正文、索引正文：该分配范围原书不含这些元素；对附录及延伸阅读的正文引用已检查，未对被引用的其他节作审校声明。

## 修复

依据固定原书修复转录：

1. `eq:mc-uniform-estimator`：分母与求和上限错误的大写 N 改回 n。
2. `eq:MC-estimator`：求和上限 b 改回 n。
3. 2.1.1 均匀 PDF：区间 [0,1] 改回 [0,1)，保留 otherwise 语义并双语显示。
4. `eq:variance-initial` 后遗漏的 `V[aF] = a² V[F]` 整条公式补回。
5. `eq:variance`：为原书 (2.9) 补本地 `<variance>` 标签。
6. `eq:expected-value-properties`：两条性质合并回同一个带标签公式块，对应原书 (2.5)。
7. 修复英文 `sample variance i` 截断为 `sample variance is`；修复英文连写、(n) 数学转录以及异常分号；保留英文全文。
8. BVHLightSampler 的旧相对 HTML 路径移除包装，保留紧邻的本书节引用与代码名；该旧路径不是本地站点资源。

中文主要修正：任意点“计算函数值”误译为若干点“估计”；遗漏的 E[F_n]；“不独立”误译为“相关”；“选择 X_i”误译为“构造 X_i”；consistent 统一“相合”；估计器统一“估计量”；“期望积分”改为“所求积分”；定义域内区间不等于整个定义域；标准均匀分布映射、中文残留 xi、方差反比关系、三倍方差缩减、概率而非时间频率表述，以及术语、空格和句法。

## 检查与限制

- `cmp` 两页固定 raw 与检出子模块：通过。
- `git diff --check`：通过。
- 临时独立入口引入两文件，屏蔽 ref 显示，仅做 Typst 语法编译：通过，输出 `/tmp/pbrt-mc-syntax.pdf`；临时入口已删除。此检查不验证跨节引用、正式编号或最终视觉排版。
- 主 agent 说明 `@eqt:foo` → `<foo>` 由 i-figured 正常处理，故保留此公共引用约定。
- 尚待独立复核、三语言正式全书构建及视觉验收，不能将语法通过当作内容或排版验收。
- 原书把连续随机变量的密度直观描述为某值的“概率”，以及无限方差无偏但不相合的脚注，均忠实保留；未擅自改写数学观点。
