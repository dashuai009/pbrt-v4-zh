# 公共正文、书目引用与编号独立集成复核

只读范围：styles/source-citations.typ、styles/references.typ、styles/common.typ及用于核实调用关系的template.typ、PDF模板相关规则、当前固定源编号/书目映射。未重译已审正文，未修改公共实现。

## 公共依赖漏报：已修复

重跑section→template.typ→styles/source-citations.typ→audit/original-citations.json最小原反例。有效封存时independently_reviewed；把JSON year=1993改为0000后，状态为changed_since_review且明确列出audit/original-citations.json。旧record未收集公共依赖时，明确列出template.typ、styles/source-citations.typ和JSON为unrecorded dependency，不再自动接受。此修复通过。

## 引用规则：有限范围核查通过

- source-cite采用固定源cite ID，未知ID断言失败；已知ID读取明确year和original-reference-N，不使用旧BibTeX猜测。完整原书目条目的文字/链接/SVG及新增1355标签，已有独立backmatter复核和本agent集成报告支持。
- 实际0.13.1+fonts试验：Gray93输出1993并指向original-reference-393；legacy映射504输出1988并指向original-reference-375。对应固定源分别为Gray微分几何书和Glassner Spacetime ray tracing for animation，均与此前逐条原书目审阅一致。PDF真实References包含目标，未用占位标签。
- Web direct source-cite以base-path+reader-language+reference-page拼接目标；本次读到/pbrt-v4-zh/与163-References，两语言生成入口真实存在。此处核查字符串/入口存在，不声称已经点击验证完整站点目标。
- references.typ仅对已找到且form=year的legacy引用使用映射year；其他格式保留CSL呈现并移除其旧内层link，再链接完整书目。当前353映射、143条未匹配问题；未匹配会跳到complete-references总表，不具有逐条文献身份保证。其范围必须继续留在原问题清单，不能由这份公共规则复核标为143条已解决。
- common的parec/ez_caption按PDF静态LANG_OUT或Web reader-language选中文、英文、对照；译注缺英文时纯英文隐藏，双语注在纯英文可显示。这与当前约定相符。

## P1：本地标签别名缺少编号映射，回退会悄悄重新编号（未通过）

common.original-number直接用source-file及标签键查询source-numbers；查不到时show-fig/show-equation回退计数格式，而不是报缺映射。当前已审6.2真实标签存在以下差异：

| 本地标签 | source-numbers实际键 | 固定源编号 |
|---|---|---|
| sphere-sample-eqt | eqt:spheresample | (6.4) |
| sphere-sample-fig | fig:spheresample | 6.5 |
| sphere-sample-point-geometry | fig:sphere-compute-alpha | 6.6 |

真实0.13.1+fonts最小渲染设置source-file为6.2、章计数6，使用本地sphere-sample-eqt和sphere-sample-fig标签及原球形采样图。应为(6.4)/图6.5，实际输出(6.1)/Figure6.1，正文引用同步错误。证据`/tmp/review-shared-content.pdf`第2页、`/tmp/review-shared-content.png`。不是只看源码推测。

正控制将章计数故意设99，使用已正确映射的sphere-theta-phi、sphere-setting和plug-in-types标签；实际仍输出(6.1)、Figure6.3、Table1.1，正文引用也一致，证明有映射时公共编号规则有效。证据`/tmp/review-shared-mapped.pdf`第2页、`/tmp/review-shared-mapped.png`。最小测试内容用于验证映射行为，不作为原章节内容验收。

应补全本地稳定别名到固定原编号的显式对应，并对已指定source-file但找不到映射的应编号图/表/公式明确失败或记录未解决，不能无声回退为另一编号。单纯全书计数偶然相同不能保证分节Web或局部PDF一致。

## 状态

公共依赖反例修复通过；已核引用规则的既定行为通过，但legacy143未匹配仍未决；公共编号部分changes_requested。根agent应保持相关集成依赖过期，修复编号问题后再独立复核，不凭本报告将所有共享内容依赖整体标为已验收。

## 编号修复后的独立复验（2026-09-08）

原报告的P1编号缺口现已修复：common在存在source-file但无原编号时断言失败，只有未指定源文件的明确隔离用法仍可使用局部计数。未知图标签`unmapped-integration-probe`实测编译退出1，错误明确指出源文件和缺失fig键，未删除/禁用门禁。

对`audit/source-number-aliases.json`当前41条，逐项重新阅读相应固定源anchor/eqno、图像与完整图注或表标题/内容身份、完整数学关系，以及本地目标。不是只查锚点存在。数学涵盖Gram–Schmidt(3.2)、辐亮度(4.3)、面积→立体角(4.9)、球面张角(6.4)、卷积定理(8.4)、Volterra透射率(11.10)；图片涵盖皇冠、PMF/CDF/逆采样、光谱、球体/三角形/BVH、着色法线、MixMaterial/置换面及透射率；表格涵盖Fourier对、Halton两表、折射率、俄罗斯轮盘效率、CPU/GPU两表及别名法。确认目标身份与原编号一致。

41条另构造明确的编号测试体，故意使用章计数99，真实Typst0.13.1编译后逐目标query其实际numbering函数并求值，41/41返回各自原编号，无错配。此测试只检验公共映射行为，测试体不替代原正文。逐项关系/编号/哈希记录`audit/reports/review-number-alias-evidence.json`。

需要区分的状态：8.1初校期间卷积公式一度误写为`<:eq-fourier-convolution>`，复核指出后已恢复稳定`<eq-fourier-convolution>`，内容与固定源(8.4)一致；`fourier-pairs-zh`目前已被该节单份共享Fourier表替代，是不再使用的旧别名，原对应身份仍正确，不能把它当作当前额外表。此项应在8.1工作收尾时清理。以上均不授予8–15章或附录整节已精校状态。

### 两项限定修复独立复核

9.1：第一次检查发现root的资源替换误改到首图，已要求修复。最终重新读取首图`bsdf-basic-interface`使用pha09f02.svg、第二图`pha09f03`使用pha09f03.svg，对照固定源BSDF_Representation.html相应图9.2/9.3与图注。实际抽取这两个正文图块经公共规则渲染，正确显示图9.2和图9.3，第二图确为几何/着色两个法向量及两个半球，图注n_g/n_s完整可见。`/tmp/review-limited-repairs.pdf`第2页与`/tmp/review-limited-repairs-2.png`为证。原“图9.2缺失”的推断已经撤销；本次不声明9.1其余正文完整。

B.2：固定Mathematical_Infrastructure.html3150–3152的MathJax标题确为b≈±√(b²−4ac)。实际本地英文恢复该关系，中文以“b接近±√(b²−4ac)”表达同一条件；消减导致数值精度损失及后续改写稳定形式的语境均未改变。实际渲染第3页两个语言均有公式，不再是空数学；`/tmp/review-limited-repairs-3.png`。本次仅确认这一限定转换遗漏修复，不涉及B.2整节精校。

11.9编号对应核验补充：固定HTML引用pha11f09.png，本地采用同目录SVG。已实际并排渲染二者，均为p→p′光束穿过介质、L_o(p,ω)的同一示意图，编号11.9身份成立；图注中文等整节问题仍待后续精校，不因映射成立变成内容通过。

### 更新结论

本次明确复核范围内的公共引用/语言选择规则、公共依赖完整性修复和41条编号关系通过，原P1编号changes_requested解除。允许主agent以实际接受的公共依赖哈希更新既有已独立复核范围的集成记录；不扩大任何未审章节的语义状态。legacy143条未匹配引用、旧别名清理及全站实际链接/手机视觉仍保持各自未决或待验状态，不能由本报告整体清零。
