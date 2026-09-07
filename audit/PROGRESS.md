# 续接记录

## 基线
- 初始主仓库：9e0ba8bd373932cd5fbab2d4ad9b13b1788b2d4e；工作区干净；未发现适用 AGENTS.md。
- 原书固定子模块：f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c；初始化进行中。
- 本地 Typst：0.15.1；shiroa 发布 CLI：0.3.0，macOS arm64 压缩包 SHA256 a960e4a3ca1add1b6cbd89a71290895e5968c76d2c138768d9947a4efeae1c42。尚非兼容性验收通过。
- 当前 shiroa 官网示例有 0.4.0 包，而 0.3.0 CLI init 生成 0.2.0 包，必须以实际实验记录为准。

## 文件锁（同一文件只允许一个写入者）
| 任务 | 独占范围 | 状态 |
|---|---|---|
| edit_preface | chapter-0-Preface/*.typ；自己的报告 | 精校中 |
| edit_introduction | chapter-1.0、1.1；自己的报告 | 精校中 |
| edit_monte_carlo | chapter-2.0、2.1；自己的报告 | 精校中 |
| 主 agent | 公共模板、术语、全书清单、工具、站点、CI | 进行中 |

完成后轮换独立复核，重新读原文。没有任何范围可以仅凭当前初读标记已精校。

## 已发现的待核问题
- 本地两种正文并不能证明原文完整，已有一般 MC 估计量疑似上限损坏、方差公式丢失、英文截断，待固定原文验证。
- main.typ 的 References、Index of Fragments、Index of Identifiers 正文入口被注释，文献仅使用现有 bibliography.bib，须核对四版原书。
- 大量标题仍为英文。公共模板 figure 引用统一按 image 计数，表格和附录引用有风险，需实际全书编号检查。
- GitHub Pages 未认证 GET /repos/dashuai009/pbrt-v4-zh/pages 返回 404，此结果不能判定权限或站点是否存在。尚未发布。

## 验收
全书内容、独立复核、三种 PDF、全书站点、跨页编号、桌面/手机、线上发布均未验收。保留此记录直到真实完成，禁止用试点替代全书。

## 2026-09-06 当前续接点（覆盖上面的初始快照）

- 原书子模块已完整检出，HEAD与固定提交一致，无修改。
- 全书结构候选：166目录页面+2辅助页面，163本地正文候选，References/两个Index仍缺完整本地承载；inventory.json的结构状态不代表语义审校。
- 已有独立复核报告：序言、1.0/1.1、1.2、2.0/2.1、2.2。精确已复核内容指纹保存于 review-status.json；源文自身疑点见报告，不能标成已解决。
- 正在初校：1.3/1.4（edit_preface）、3.0/3.1/3.2及其supplements（edit_monte_carlo）。正在独立复核2.3–2.6（edit_introduction）。1.5–1.8已初校待另一agent复核。
- PDF工具固定 .tools/bin/typst 0.13.1；系统0.15.1报diff不可用。多次全书三语编译通过；并发编辑中有临时缺引用快照，须以最终静止快照重建验收。
- 公共API template.typ，正文公共函数 styles/common.typ，PDF样式 styles/pdf.typ，正文清单 content.typ，网站入口 book.typ，薄页面由 tooling/web-entries.mjs 生成到 web/generated（不保存第二份正文）。
- shiroa0.3.0/package0.2.0的 static-html 与 dyn-paged 试点均构建过。static 实际出现公式函数名、行内公式断段、脚注/文献丢失，已逐项做输出修复。仍需最终全站视觉与链接验收。
- 已完成一次全163页×两语言static站点构建，首次链接检测30510处失败（含6主题重复），主要是旧源站相对链接；新增 source-links.mjs 按固定原文目标映射，原站保留链接明确带“原”，8项未确定引用显示待校标记并列 source-link-issues.json。尚未通过最终链接检查。
- 全站原始输出约1.2GiB；同一HTML内去重完全相同的SVG字形定义节省约400MB，仍须渲染验证等价。
- Pages已创建（201），正式地址 https://dashuai009.github.io/pbrt-v4-zh/，workflow方式，当前尚未推送/部署/线上验证。用户已授权，不需再问。
- 新工具均为确定性的结构/构建/验证程序，没有调用模型。旧Scripts从未运行或依赖。
- 本轮整个任务尚未完成，不可把初始两章、试点或构建成功作为全书完成。

## 03:40之后续接重点
- 第一章1.0–1.8与第二章2.0–2.6均有独立复核；1.1裸片段框和1.2 DisneyMoana源书目失效链接已按后续独立反馈修复并刷新指纹。1.3新增supplements/1.3-expanded.typ含86+9行额外在线代码；审校指纹包含其依赖文件。
- 第三章3.0–3.2（含181行额外在线代码）已独立内容复核，最新视觉仍待稳定全书构建。3.3–3.7已初校释放；edit_monte_carlo继续3.8–3.13。
- edit_preface正在补五个空文件；A.7/B.9习题和A.6延伸阅读已落盘，仍待独立复核；B.8/16.6继续。
- edit_introduction正在独立逐条复核新backmatter三文件及数学SVG。主agent生成候选1355/1696/2382条并验证4083个原站目标存在；不能以这些计数代替审校。
- backmatter三文件已纳入content.typ；原规范化bibliography与完整原文参考文献暂并存，明确已知重复待统一。
- 新source-links把确定原站代码链接显式标“原”；无法确认8项显示“引用待校”且保存问题记录。原始图/公式label已在Web映射为真正i-figured编号目标。最近全站链接错误已从30510降为102，最后一批已定位：未canonicalize的原始figure标签及换行#link调用，已修待新全站复测。
- 原生HTML默认shiroa搜索不仅中文失配且每页截512字符。新增tooling/search-index.mjs索引完整实际渲染文本，替换searcher.js；手机实际中文搜索“蒙特卡洛”成功命中8试点页面，能命中段尾内容。全书还须验收。
- static试点代码复制反馈“已复制”；工具剪贴板API未返回文本，不能称字节级剪贴板验证。四个三角本地跳转目标实测存在。加入移动CSS和完整脚注/文献输出。
- 正在运行dyn-paged六个复杂试点比较，输出output/pilot-paged。静态服务4173=pilot-static、4174=site、4175=pilot-paged，均为本任务node tooling/serve.mjs。
- 公共样式已分离，已修caption语言/表格kind与双语分隔；此前出现的[ / ]语法错误已改text(" / ")。Typst0.13.1保持固定。
- 后续必须重新node tooling/inventory.mjs、bash tooling/build.sh（脚本空数组兼容已修），检查全新静止快照而非动中旧输出。生成器最后必须恢复全书book.typ，避免停留--pilot范围。

## 04:50之后续接重点
- 第三章全部3.0–3.13（及全部附加代码）已独立复核，最后三语与复杂数学/四题视觉通过；须刷新3.8–3.13指纹。
- 第四章初校全完成，edit_preface正独立复核4.0–4.8；4.5补充SampleVisible和固定5.4可见代码重复，复核时须映射去重。
- edit_monte_carlo正在第五章；5.0–5.3及三份补充已释放待独立复核，5.4–5.6继续。
- edit_introduction正在附录A；A.0–A.3及补充已释放待独立复核，A.4/A.5大范围缺代码/数学/旧提示词残留正依据固定原文重建，复杂式用固定SVG放入math.equation保真，仍须独立复核。
- 五原空文件与backmatter已独立复核通过。backmatter生成器已同步精确ex高度/基线、9pt正文、1748层级缩进；独立checker再跑5433项全通过。helper另增HTML原ex CSS基线，Web仍需实际复验。
- 中文PDF书签已实测586项无空标题；去掉重复规范化bibliography后数量会变化，需最终验证。PDF短代码<=12行不拆分、代码9pt/1fr列，Point3::operator+=已由复核确认整块同页。
- 原生HTML不仅SVG，PNG/JPG也曾被忽略只剩图注：现在所有image显式frame，新增check-rendered-content实测全书761 figure/16105 inline-math无空主体。图3.3/3.4已手机实看，图形确实显示。
- 完整图片加入后输出约6.5GB；compact-html按精确字节将内嵌PNG/JPEG/SVG等提为去重共享资产，保留同文档相同SVG字形去重，输出已约811MB。原check-links保留全量DOM/data URI曾OOM，已改两遍逐文件，仍检查本地SVG glyph，不靠加内存/忽略目标过关。
- 最近1272链接错误主要是跨节#link(<cite:...>)错误按当前页定位。新增export-link-targets.typ以真实全书query取得唯一所有者；prepare-link-labels目前1249个目标，web生成按owner发锚点，SourceLinks也优先本地精确目标。须新全站再检，不能复用旧结果。
- 公共引用层已取消重复打印旧规范化bib：styles/references.typ保留CSL格式但跳完整原书References；唯一标题complete-references，1355行各有original-reference-N（独立checker再跑不改变原内容）。旧键仅在精确标题/年/首作者唯一匹配时直达条目，否则跳完整书目入口，仍记录未匹配143键。明确别说全部精确匹配。
- 新source-cite公共API从template导出：以固定原li cite:ID整条文字精确匹配完整书目，1249原ID、0未匹配。直接保留源年份含a/b，无需不断手写旧bib缺项。新第五章将采用。旧year型cite匹配时也采用源年份；TURKOWSKI1990539明确alias→Turkowski90应显示1990b，尚需最终视觉。
- 旧作者简介未在固定HTML找到，对应旧文件英文完整保留但不纳入PDF；新authors.typ仅承载固定root index作者署名，不发布旧职业信息为当前事实。
- 仍未git提交、推送或线上部署。Pages配置201已成功，repo管理员权限可用，站点目标https://dashuai009.github.io/pbrt-v4-zh/。当前主分支工作区全为任务修改（初始干净）。

## 2026-09-08 续接检查点（取代上述过时状态）

- 当前分支 codex/book-audit-shiroa，已保存本地提交78bba09；尚未推送或部署。固定原书f6d66f0仍一致。续接发现未跟踪Scripts/Cargo.lock，来源未确认，保留但不运行、不纳入任务提交。
- 序言、1–4章、附录A、五个原空文件及书后三项的既有独立复核报告已保留。5.0/5.1、6.0/6.1已记录当前复核哈希；5.2–5.6、6.2–6.6正在独立复核，6.7/6.8继续初校，6.9/6.10初校完成待独立复核。7–16其余部分和B/C正文仍未完成。
- 新review-state统一检查正文、已记录包含文件、源HTML及两份报告。正文不变但补充代码/图片变化也使“已复核”失效；回归测试通过。当前54条记录匹配，书后三条因后续引用/内联数学公共渲染改动待复查，不直接刷新指纹掩盖变化。源单元映射21993项仍保留独立的待确认状态。
- 本轮全书构建日志output/resume-build.log：三PDF与全166页×2语言网站成功；809图主体、17210行内数学检查无空输出；1999HTML、159248链接/资源检查、721278SVG字形检查，零错误。此为构建时快照，后续agent修改须再集成，非最终全书精校完成。
- 最新源链接待校为4处出现（12.6两个目标），不输出猜测链接；旧“8处”记录过时。规范化重复参考文献已取消，1249原文书目ID精确映射，旧键未精确匹配仍明确保留限制。

### 后续同日进展
- 第五章5.0–5.6现全部独立复核完成；新增修复图5.22额外计算开销、Pixel数组、LMS逐分量除法、习题6因果方向，以及原无编号小标题/式5.9分页。复核者已继续第七章初校。
- 第六章6.0–6.6全独立复核并记录依赖指纹；6.9/6.10正在独立复核，6.7初校释放待独立复核；6.8按8子节内部检查点初校，不能算已精校。
- 12.6四次错误引用逐个对照固定HTML修正，源链接解析现零待定；新增构建门禁防止重新引入未解析源地址。仅该引用修复，不标12.6整节精校。
- 真机浏览器尺寸测试发现百分比图像零尺寸，旧检查176项诊断（SVG和image重复计）；公共Web图像添加具体排版容器，新全书820图/17395行内数学及零尺寸检查零错误。全站压缩、链接与修复后实际视觉仍在执行；不得用旧“节点存在”证据替代修后视觉。
