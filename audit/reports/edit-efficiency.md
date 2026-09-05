# 2.2 Improving Efficiency 对照精校

状态：awaiting_review；原书存在下列未决数值问题，不能将其标为技术问题全部解决。独占文件 `chapter-2-Monte_Carlo_Integration/chapter-2.2-Improving_Efficiency.typ`。

固定依据：子模块 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`，`4ed/Monte_Carlo_Integration/Improving_Efficiency.html`。本 agent 直接阅读原 HTML 全文，借助 MathJax title 读取所有公式，并单独读取三条脚注 tooltip 内容及图片/代码片段 HTML。未使用 Scripts。另读前节方差内容及后节逆变换采样开头。

## 逐子节覆盖清单

| 原书位置 | 实际逐段范围 | 内容类别 | 状态 |
|---|---|---|---|
| 2.2 标题至 StratifiedSampling 前 | 无偏估计量样本数/误差关系、有限计算预算两段 | 标题、正文 | awaiting_review |
| `sec:stratified-variance-reduction` / `StratifiedSampling` | 从 A classic and effective family 至 Owen 引文段全部正文 | 标题、正文、完整分层公式推导、式2.12、Veach 脚注、图2.1及两图和署名 | awaiting_review |
| `sec:importance-sampling` / `ImportanceSampling` | 从 Importance sampling is a powerful 至 unappealing option 全部正文 | 标题、正文、归一化/零方差/两分段PDF公式、高斯图2.2三图及完整图注、非负函数脚注 | awaiting_review；上游数值争议 |
| `sec:multiple-importance-sampling` / `MultipleImportanceSampling` | 从 We are frequently faced 至 worthwhile 全部正文 | 标题、正文、乘积估计量、MIS无偏条件、式2.13–2.16、函数方差脚注、两完整代码块及片段标题/导航 | awaiting_review |
| `x3-MISCompensation` | 五段（含单句固定 delta） | 标题、正文、归一化锐化PDF公式、12.5节引用 | awaiting_review |
| `sec:russian-roulette` / `RussianRoulette` | 从 Russian roulette is a technique 至末句 skipped 全部正文 | 标题、正文、可见性估计量、终止概率与常数条件、分段估计量及期望证明 | awaiting_review |
| `sec:mc-splitting` / `Splitting` | 从 While Russian roulette 至末句 over them 全部正文 | 标题、正文、式2.17–2.18及分裂估计量、部分求值参数和辐亮度例子 | awaiting_review |

范围内无数据表（排版 table 仅承载图组）、习题、附录正文、独立延伸阅读正文或索引正文；原文三条脚注完整纳入。图组的五个资源均与 HTML 源路径对照。两代码块逐字符语句/标识符检查；未改变算法代码。

## 确定的转换修复

- ImportanceSampling 好的分段 PDF 第三段 `0.2` 改回原文 `0.1`，恢复归一化。
- 图2.2(b) 错用了(c)的带样本图，改为原书 `piecewise-gaussian-pdf.svg`。
- 同图正文引用改用公共 i-figured `@fig:` 目标；图注中文式2.6改为真实公式引用。
- MIS 乘积推导后，英文与中文都误把剩余因子方差写作 f_a，按原文修为 f_b；补回遗漏的“方差定义不排除计算函数本身方差”脚注。
- 两采样分布段的 `X ∝ p_a` / `Y ∝ p_b` 及 splitting 的对应符号，按原文 `~` 修复；这是服从分布而非正比。
- 式2.13后的英文/中文被替换为泛泛贡献解释，恢复原书“选择权重使估计量期望等于积分”的无偏条件。
- 补英文无偏权重条件段末句点/括号、Russian roulette 首段遗漏的 In rendering… 句；修复脚注 f(X)→f(x) 和英文连写。
- splitting 的 `f(X_i)` 恢复为 `f(X_i, dot)`，并恢复 X_i 大写，与原书“先部分计算、复用外层样本”的含义一致。
- 移除未经原文依据的中文额外体积比例公式；原书保留 fractional volume 与 (0,1]。
- 恢复 Sampling Inline Functions 两个片段标题及0/1互链。第二个片段的后继在原书下一节：暂用完整原书链接，待公共映射，不发明本地缺失目标。

## 中文精校

所有正文逐段核对并修正不通顺句子、术语与限定：样本数/估计量区分，充分利用有限样本；分层方差第二个求和项（避免含混“右侧和项”）；相关维度联合分层；方差倍数明确为比例；被积函数而非积分值；BSDF、入射辐亮度；MIS逐点至少一个PDF非零；分裂复用外层计算与反射辐亮度。所有标题与图2.1小图标签双语化，俄罗斯轮盘分段公式 otherwise 双语化。splitting=分裂已获主 agent 统一确认。

## 未决上游数值问题

1. **EFF-UPSTREAM-01**：ImportanceSampling 的高斯公式是 `exp(-1000(x-1/2)^2)`，原文却说 X<0.2 / X>0.3 且峰在1/4。固定 HTML 与本地英文一致，是上游自身冲突。候选解释为正文旧参数残留（中心应1/2、有效区间应随之移动），但无版本证据确定，禁止猜改。本次保留原数值，中文明确译注替代原有随意问号。
2. **EFF-UPSTREAM-02**：坏PDF分段公式中段是0.2，随后正文写该区域 p(x)=0.4。保留两处原书值并加明确译注；候选是正文0.4应0.2，但未擅改。

这些问题仍需主 agent 统一记录/裁决，独立复核应确认“忠实保留并明确揭示”，而非把数值矛盾判作已解决。

## 验证

- `git diff --check` 通过。
- 独立临时入口、屏蔽 ref 显示的三语言语法编译通过：`/tmp/audit-efficiency-syntax.pdf`、`/tmp/audit-efficiency-syntax-zh.pdf`、`/tmp/audit-efficiency-syntax-en.pdf`。临时入口已删除。
- 该编译不验证正式编号、跨页引用或最终排版，尚未做视觉检查。必须交另一 agent 重新读固定原文与完整双语复核。
