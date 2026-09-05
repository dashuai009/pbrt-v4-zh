# 2.3 与 2.4 原文对照精校

状态：awaiting_review；待另一 agent 独立重读原文复核。2.4 原书存在条件表述问题，见未决项，不作技术问题全部解决声明。

独占文件：`chapter-2-Monte_Carlo_Integration/chapter-2.3-Sampling_Using_the_Inversion_Method.typ`、`chapter-2.4-Transforming_between_Distributions.typ`。

固定依据：子模块 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c` 的 `4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html` 和 `Transforming_between_Distributions.html`。直接阅读完整 HTML 正文、全部 MathJax title、脚注 tooltip、代码块与片段导航。相邻背景为 2.2 估计量和 2.5 延伸阅读方向；未使用旧 Scripts 或其结论。

## 逐单元覆盖

| 源锚点/范围 | 审阅类别与范围 | 状态 |
|---|---|---|
| Sampling_Using_the_Inversion_Method 起始段 | 逆CDF方法、分布良好样本、BSDF等分布来源 | awaiting_review |
| DiscreteCase 全部正文 | 四事件例子、CDF堆叠、逆CDF条件、权重缩放、SampleDiscrete完整文学代码与逐片段解释、随机样本重映射 | awaiting_review |
| fig:discrete-pdf / discrete-cdf / discrete-inversion | 三个SVG资源、完整双语图注、图间引用；xi希腊符号、标准均匀随机变量与概率条件 | awaiting_review |
| eq:discrete-sample-cdf / discrete-sample-cdf-weights | 原书2.19、2.20全部关系及文字引用 | awaiting_review |
| sec:inversion-method-continuous / ContinuousCase | 极限解释、全部三步骤、积分下限脚注、A.4引用 | awaiting_review |
| x2-SamplingaLinearFunction | 全部正文及积分/PDF/CDF/两种逆公式，a,b非负与a=b未定式，Lerp/LinearPDF/SampleLinear/InvertLinearSample全部代码 | awaiting_review |
| Transforming_between_Distributions 起始至多维小节 | 全部一维变换段落、CDF事件等式及链式求导、sin变换例子、CDF复合公式 | awaiting_review；上游条件问题 |
| sec:mc-transform-multiple-dimensions | 全部正文，雅可比定义与两个矩阵、极/球坐标PDF关系，原书2.21–2.23 | awaiting_review |
| sec:mc-multidimensional-sampling | 全部边缘/条件分布推导、维度递减递归解释、式2.24 | awaiting_review |
| x2-SamplingtheBilinearFunction | 双线性四角值与2.25、PDF、边缘/条件线性函数、全部代码及逆变换、A.5引用 | awaiting_review |

原书2.3有10个可见文学代码块，2.4有5个；全部逐项覆盖。2.3唯一脚注已补回，2.4无脚注。2.4无图片；两节无数据表、习题正文、独立参考文献或索引正文。引用到习题/附录不等于已审校对应目标。

## 确定的转换与结构修复

1. 2.3 补原书 (2.19)/(2.20) 标签；错误 `sum_(w_i)`（把w_i放在求和号下）恢复 `sum w_i`。数字硬编码图/公式引用替换为已存在对应标签。
2. 2.3 连续逆变换遗漏脚注补回：积分下限一般应为负无穷，只有 x<0 时密度为0，所列下限0才等价。保留全部条件。
3. 2.3 xi_i及反斜线xi错误恢复原文xi；去除图2.5图注正文中的重复“Figure 2.5”编号；图注改用公共双语函数。
4. Sampling a Linear Function 原为无编号h4，恢复正确标题层级，避免多出2.3.3。
5. 2.3 SampleDiscrete原先把完整代码展平，仅剩空缺的逐段讲解。恢复原书函数的具名片段骨架，以及后文全部5个逐段代码块，语句/标识符/运算不变。其余4代码块保留，补全部原片段标题与导航。
6. 2.4 删除标题中硬编码2.4，并双语化所有标题。
7. 原书 (2.21) 下定义被转录为“J_T是雅可比矩阵”，恢复“|J_T|为雅可比矩阵行列式绝对值”；矩阵偏导用partial排版。
8. 补回遗漏的整个二维雅可比矩阵：J_T = [[∂x/∂r,∂x/∂θ],[∂y/∂r,∂y/∂θ]] = [[cosθ,-r sinθ],[sinθ,r cosθ]]。
9. 球坐标关系补回原书 (2.23) 标签；删除高维采样段英文末尾误重复的条件密度公式。
10. 2.4 文学片段标题移出可复制C++代码；SampleBilinear恢复原文片段骨架，保留后文两片段语句，补原书全部片段目标及互链。

片段链 SamplingInlineFunctions-2 至 -8 均使用本地已恢复真实目标，前接2.2中的-1。MathInlineFunctions-0后继及SamplingInlineFunctions-8后继位于不属本任务的章节，采用原书完整链接，未虚构本地目标；待公共网站映射统一。代码占位片段为原书文学编程语法，不宣称其单独就是可编译C++。

## 中文修正

逐段修正：不一定归一化不等于非归一化；分布良好不泛化为高质量；从BSDF等所定义的分布采样，不是对“定义”采样；标准均匀随机变量；权重数组偏移量指代；逆CDF求解与未定式；PDF/CDF属于同一分布，不是“从PDF和CDF抽取”；矩阵与行列式区分；随机变量独立；四角的值而非“顶点w_i”；边缘分布积分消元、条件分布、按逆序求逆，以及单位球面不是球体。英文保留且修改限于固定原文支持的转录恢复。

## 未决上游条件问题

TRANSFORM-UPSTREAM-01：2.4起始段原书声称一对一变换必然导数处处严格正/负，且在包含递减情况的叙述后写 Pr(Y≤f(x))=Pr(X≤x)；还将多对一映射描述为无法明确给出y的密度。这些不是一般情况下都成立的结论。原文和公式忠实保留，在中文译注中明确条件问题，待主 agent 统一裁决。不自行改公式，不将原书问题默默写成正确。

## 验证

使用 Typst 0.13.1，公共 pbrt 模板加字体路径，临时入口引入2.2–2.4并屏蔽外部ref显示：中文、英文、双语编译通过，输出 `/tmp/audit-inversion-syntax-zh.pdf`、`/tmp/audit-inversion-syntax-en.pdf`、`/tmp/audit-inversion-syntax-bi.pdf`。

另用公共模板引入2.0–2.4，从第2章计数起，实际查询i-figured输出：新恢复的 `eqt:discrete-sample-cdf` 至 `eqt:bilinear-interp` 依次为19、20、21、22、23、24、25；对应章/节计数分别是[2,3,1]、[2,4,1]、[2,4,2]，与原书2.19–2.25一致。此为真实计数查询，不是凭标签名猜编号。

`git diff --check`通过。临时入口已删除。上述检查不验证最终PDF视觉或网页手机阅读，跨节引用展示仍需全书集成验收。
