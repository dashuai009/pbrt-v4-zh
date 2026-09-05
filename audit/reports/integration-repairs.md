# 公共集成修复

尚待独立复核，不属于全章精校。

- bibliography.bib：根据固定上游 References.html:2724/2729/2735/1376/4016 及初校、独立复核报告，补 Knuth1984 重印说明；恢复 Knuth1986/Fraser95 出版地 Reading, Massachusetts；恢复 Knuth1993b 联合出版社 ACM Press and Addison-Wesley；恢复 Reinhard2010 作者顺序。
- 8.7 Sobol_Samplers.typ:546：HTML 编译拒绝 U+0008 控制字符。对照固定上游 Sobol_Samplers.html:2959 的 MathJax SVG title，恢复该中文段中 C[d_i(a)]^T 与 C 的数学排版。只修复该公式转录，不宣称本节精校。
- shiroa CLI 0.3.0 默认生成模板的数学 show 规则错误地返回函数对象，实际网页显示 div-frame 而非公式；改为应用函数。行内 html.frame 必须置于 span 中，否则实际导出割裂段落。两项均经真实浏览器发现。
- content.typ 抽出同份正文包含清单，main.typ 保留 PDF 外层；原 about_me 的旧审校结论不再作为本书状态展示，改为明确的进行中校订说明。
- 附录编号模式从 A. 改为 A.1，避免 A.A/B.H 字母化子节；仍须核对缺失标题造成的计数偏移。

后续公共修复：Knuth1986、Fraser95 出版社也恢复为固定原文 Addison-Wesley；需与前次出版地修复一起复核。新增 Hart2020 与 Owen2019 的作者/题名/年份等字段已获原文对照复核；Owen 固定原书 href 含错误的 &nbsp;，本地 ~owen 为候选修复，当前网络未验证可达性，不能宣称已验证链接。

Pages 配置已按任务授权创建：GitHub API 返回201，build_type=workflow，html_url=https://dashuai009.github.io/pbrt-v4-zh/，无自定义域名。配置创建不等于网页部署或线上验收。

结构修复（待独立复核）：固定原文 The_Future.html:74、Conclusion.html:74 均有 h2（16.4/16.5），本地缺失；恢复双语二级标题。固定原文 Managing_the_Scene_Description.html:74 有 h2 C.2 与 sec:basic-scene-builder，本地仅普通双语段落；恢复二级标题及原标签，防止后续C.3/C.4计数错位。

真实缺失（2026-09-06确认，不能再称仅待复核）：16.6 Further_Reading、A.6 Further_Reading、A.7 Exercises、B.8 Further_Reading、B.9 Exercises 五个文件均为0字节。须按固定原文补译并独立复核。

完整书后内容承载候选：backmatter/References.typ 包含固定原书全部1355条文献，Index_of_Fragments.typ 包含1696条索引，Index_of_Identifiers.typ 包含2382条索引；保留所有作者、题名、标识符和原数学SVG。4083个原站目标已逐一在固定HTML验证存在。这里的提取/结构检查不授予独立复核通过状态；还须另一agent对照每条原文。

原 bibliography.bib 的规范化引文列表与新导入的原书完整书目暂并存；这是一项明确的已知重复，尚未完成引用层合并，不得宣称“无重复”。

编号边界按固定目录显式建立：content.typ 每个已对应原书的章/节入口设置其预期heading计数，附录采用A.1；序言、延伸阅读与习题无编号，和固定HTML标题一致。此措施不把节内标题层级/图公式的遗漏宣称已修复，内部结构仍逐节复核。Web无原书数字的入口同样不自行编号。

实际PDF/HTML渲染缺陷：原生HTML中原书SVG插图被忽略而只剩图注（3.3 Vectors实测），现Web显式用html.frame承载SVG，必须复看实际图形。Backmatter的内联image位于par内导致PDF忽略数学，独立复核agent已用box修复250处，待整体验收。PDF标题若包含context语言选择导致书签为空；公共函数改为PDF静态选择语言、仅Web使用context，保留三种输出语义，待书签和实际页面重验。

Backmatter原数学helper现增加HTML分支，用源height-ex与vertical-align的CSS ex值直接继承网页实际字体度量；PDF分支保持独立复核过的x-height/box基线公式。需在全书HTML重新检查LP_τ等混合普通文字/数学图片案例，不能仅据PDF正确推断Web正确。

作者附页的来源边界：旧about_the_authors.typ于2024-12-29入库，固定子模块全部HTML未找到其三段职业简介的对应原文；不把旧稿职位当当前事实或固定原书内容。旧文件和英文全文保留不删，暂不纳入阅读输出。新authors.typ仅使用固定root index.html:32明确列出的三位作者署名与原书书名；这不是删除原书正文。旧简介待另寻来源核验。
