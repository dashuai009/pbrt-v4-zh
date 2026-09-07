# 四个公共门禁的独立只读复核

范围仅 `tooling/review-state.mjs`、`record-review.mjs`、`build-snapshot.mjs`、`check-rendered-content.mjs`。已全文阅读，不修改公共程序。用真实四个程序在临时独立仓库/夹具目录运行，小型复现脚本 `/tmp/review-validation-gates-probe.mjs`，结果 `/tmp/review-validation-gates-result.json`；临时仓库每次自动清理，不写主仓库ledger或output。下列结果全部实测，不是推测。

## P1：构建快照漏记实际输入，却报告stable

位置：build-snapshot.mjs:6、12–15。

文件过滤仅含typ/svg/css/js/mjs/sh，排除全部audit及book.typ，也不递归git子模块。实际正文PNG/JPEG、JSON正文/引用映射、book.typ导航、工具TOML配置/字体等均不在快照中。

复现：临时git仓库建立section.typ、photo.png、values.json和book.typ，分别执行start→修改photo.png/values.json/book.typ之一→end。三次end均退出0并写`{"stable":true,"changed":[]}`，stdout还称“unchanged throughout validation”。PNG和JSON可以直接影响正文内容，book.typ影响全站范围，因此这不能证明构建产物来自同一输入版本。

建议：记录明确完整的构建输入集合（包括实际正文资源、映射、配置及子模块提交/内容）；若某些文件由构建生成，应区分源输入和输出，不能仅靠后缀排除实际输入。

## P1：已记录复核的正文数据依赖及报告变化不使状态失效

位置：record-review.mjs:10–15、19；review-state.mjs:17–20。

复现正文：`#let values = json("values.json")`，随后显示`values.at("text")`。正常运行record-review后，included_files为空；将JSON中的text从reviewed改成not reviewed，assessReview仍返回`independently_reviewed`。引用系统也经JSON记录决定作者年份/链接，不能只将typ和图像看作内容依赖。

同时，record-review只要求两个报告存在，两个空报告也能记录成功并由assessReview授予已复核；把独立报告改写为`changes_requested: source comparison is incomplete`，结果仍为已复核。这不要求机器自动理解自然语言审校结论，但至少不能让空的或已经改变的证据继续支撑旧结论。

建议：收集实际数据/引用依赖；存储独立确认的报告快照哈希并检查报告非空。自然语言或多批次报告可保留人工明确确认流程，不建议靠搜索“通过”等词自动推断逐文件成功。

## P1：同一报告经路径别名可充当初校与独立复核

位置：review-state.mjs:20，record-review.mjs:5/19。

以`editor_report:'edit.md'`和`independent_review_report:'./edit.md'`指向同一实际文件，其他快照有效。assessReview仍返回`independently_reviewed`，因为只比较原始路径字符串。不是两个独立报告。

建议：记录与检查阶段都规范化并realpath比较报告路径；拒绝同一文件（包括符号链接别名），再由主agent确保确为另一复核者。

## P1：零尺寸图像与空站点漏报

位置：check-rendered-content.mjs:7–8。

逐个将下面内容存为唯一的`site/case.light.html`，运行真实检查器，全部退出0、errors=0：

- `<figure><svg viewBox="0 0 0 20"></svg></figure>`（宽为零）。
- `<figure><svg viewBox="0 0 20 0"></svg></figure>`（高为零）。
- `<figure><img src="photo.png" width="0" height="0"></figure>`（只检查image，不检查img）。
- `<figure><svg viewBox="0 0 20 20"><image width="0px" height="20px" href="photo.png"/></svg></figure>`（Number('0px')为NaN）。

正控制`viewBox="0 0 0 0"`退出1，说明夹具正确进入了检查器。空目录也退出0，报告figures=math=errors=0。因而“无输出文件”可被误当检查通过。

建议：解析viewBox的四个数并独立检查宽高，支持合法逗号/空白及数字格式；检查img/SVG自身尺寸与带单位零值；至少要求期望的light页面集合完整，而非只要求所见页面无错误。CSS最终尺寸应另由浏览器检查，本程序仅静态检查不能声称实际可见。

## P2：数学class和空SVG被当作有效内容

位置：check-rendered-content.mjs:6–7。

`<span class="inline-math extra">x</span>`无SVG，仍退出0且math=0，原因是要求整个class属性恰好等于inline-math；应按class token判断。正常viewBox但无任何绘图子节点的空SVG也让figure通过。这至少说明“包含svg标签”并不等于有实际绘图内容；应核实渲染载荷/资源，而非将标签名直接判为可见。

## P2：included_files可以覆盖正文主哈希

位置：review-state.mjs:14。

对象展开先写`[file]:record.local_sha256`再展开included_files。如果included_files里也有正文路径，它会覆盖主哈希。实测将local_sha256故意设为wrong、included_files中的同一路径设为当前正确哈希，仍授予已复核。常规合法记录不一定触发，但会让本应失效的账本被接受。正文应独立检查，且拒绝依赖表覆盖其主记录。

## 构建快照语义限制：只比较端点，不能证明全过程稳定

位置：build-snapshot.mjs:7、11–15。

实测start→将section.typ改成中间内容→恢复原文→end，仍stable:true。端点哈希本就无法检测A→B→A；这不意味着端点检查无用，但stdout的“throughout validation”和文件注释的immutable acceptance超过了证据。若仍容许实时编辑，就必须从冻结目录/不可变版本构建，或明确把结果命名为“起止快照相同”，不能据此接受混合版本产物。

本轮没有更改这四程序；问题修复后需要重新运行上述夹具和真实完整构建，不将当前门禁标为验收通过。

## 修复后二次独立复核（2026-09-08）

重新全文读四程序及三个新增test文件，并运行 `node --test tooling/review-state.test.mjs tooling/build-snapshot.test.mjs tooling/check-rendered-content.test.mjs`：3/3通过。另将原反例脚本适配新generated阶段/非空有效报告并独立重跑，`/tmp/review-validation-gates-retest.mjs`及`/tmp/review-validation-gates-retest.json`保留实际数据。

已确认修复：
- record-review拒绝空报告；合法非空不同报告仍可记录，未全部误拒绝。
- assessReview拒绝报告内容更改/为空、同文件`./`路径别名、正文哈希被included_files覆盖。
- 正文字面量`json("values.json")`进入依赖表，改变JSON会使复核失效。
- PNG和JSON变化进入source changed；book.typ变化进入changed_generated，均退出1/stable:false。
- 空站点、任一viewBox零边、img零宽高、SVG image的0px、inline-math带额外class均退出1；正常SVG正控制在新增测试中通过。

### 尚存的具体范围缺口：公共引用数据未进入章节复核依赖

`dependencies()`仍直接跳过template.typ与所有styles文件，且不遍历其内容。因此直接字面量JSON反例已修，真实公共引用路径尚未覆盖。

新最小夹具：

- section.typ：`#import "template.typ": source-cite`后调用`#source-cite("key")`。
- template.typ：导出styles/source-citations.typ的source-cite。
- styles/source-citations.typ：读取`/audit/original-citations.json`，返回key.year。
- JSON初始year=1993；在正文/原文/非空报告均正确封存后将year改为0000。

实测dependencies仍为`{}`，assessReview仍为independently_reviewed。此结构与仓库公共source-cite路径相同。若公共模板独立验收状态在另一个层级统一约束章节标签，需明确依赖该状态；否则读者仍会看到未复核的年份/链接变更下的“已复核”章节。建议至少纳入影响可见文献内容/目标的公共JSON，或要求独立封存的公共内容依赖状态有效后才显示该标志；无需把所有PDF外观变更都混为翻译语义变化。

### 明确保留的诊断边界

空SVG `<figure><svg viewBox="0 0 20 20"></svg></figure>`仍退出0；A→B→A端点恢复仍stable:true。新程序头部将渲染检查明确称为structural diagnostics是正确收窄。构建stdout仍写“remained unchanged during validation”，应理解为两阶段边界快照一致，不能据此证明从未发生中间版本写入。若最终验收使用冻结构建输入目录，该限制可以在工作流层消除；若持续读实时工作区，则不能把此门禁作为混合版本问题的完整解决方案。

本轮仍未修改公共程序，仅追加只读复核结果。
