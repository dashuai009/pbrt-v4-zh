# 序言精校交接

状态：`awaiting_review`（已逐段原文对照、手工修改，尚未独立复核；不得据此标记已精校）。

## 独占文件与固定来源

- `chapter-0-Preface/chapter-0.0-Preface.typ`：固定上游 `pbr-book-website/4ed/Preface.html` 正文第 75–1147 行。
- `chapter-0-Preface/chapter-0.1-Further_Reading.typ`：固定上游 `pbr-book-website/4ed/Preface/Further_Reading.html` 的 Further Reading 两段；该页 References 另对照公共 `bibliography.bib`，未修改公共文件。
- 上游提交：`f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`，在主 agent 确认检出后读取实际 HTML。未运行或依赖旧 Scripts，也未调用批量模型脚本。

## 实际覆盖

逐段读完并对照：题辞、序言引介（6 块）、Audience（3 块）、Overview and Goals（10 块）、第一至第二版变化（5 块）、第二至第三版变化（9 块）、第三至第四版变化（8 块）、Acknowledgments（13 块）、Production（4 块）、The Online Edition（4 块）、Scenes, Models, and Data（8 块）、About The Cover（1 块），合计 71 个双语块；延伸阅读 2 块。数目仅作定位，不作为完整性证明。

实际对照对象包括全部文字、列表项、11 个序言标题、延伸阅读标题、物理近似脚注、致谢人名名单、外链、内部引用、版权与许可证文字、封面场景各项数据。此范围无独立公式、代码清单、图表实体、习题或索引；不以不适用项充作已审校项。文中所引用的第 1.2 节、第 9 章、第 15 章、图 16.1 本体不属于本任务覆盖范围。

上游标题多数无可用 id，故以 HTML 路径、标题及段首定位；参考文献有 `cite:*` 锚点。

## 英文转录与结构修复

1. `Preface.html` / Overview and Goals / `The basic foundations…`：原文脚注末尾为 `choices made in <tt>pbrt</tt>.`，本地漏掉 `pbrt` 和句点，现补齐，中译同步补全。
2. `Preface.html` / The Online Edition / `Although the book is posted…`：原文插图许可为 **CC BY-NC-SA 4.0**，原本英中都错误写为 ND，且链接错误。已按原文改为 SA；正文许可仍为 ND。
3. 主标题 `Perface` 改为 `Preface`；The Online Edition 大小写按上游修正。所有标题以 `ez_caption` 提供中文与英文。Production、The Online Edition、Scenes, Models, and Data 在上游是 Acknowledgments 下 h4，故恢复为本地三级标题；About The Cover 仍为二级。
4. 根据 `<tt>` / `<em>` 恢复 `pbrt`、`rayshade`、`web`、`cweb`、`lcc`，以及书名、片名、场景名、photorealistic rendering、algorithmic、many-light sampling 等语义格式。
5. `www.*` 无协议 URL 和带前导空格 URL 改成固定上游的 `http://www.*` 地址；不推测升级协议或目标站行为。
6. 保留固定上游自身两处 `Chapter chap:bidir-methods` 原文，中文分别添加明确译注，未猜测目标章节。

## 中文主要修正

- 逐段重写语病与翻译腔，保留范围、条件、例外及语气。
- 纠正 never be forgotten 被译成“永远被忘掉”的反义错误；恢复师生关系跨越两岸的漏译。
- 纠正 figures→人物/数字、composition→撰写/构图、frame→框架、San Miguel→生力啤酒等错误。
- 将文学编程描述还原为说明文字与源代码结合，而非“记录源代码”；删除无原文依据的“该功能（指说明性）”。
- 修正 MIS 是为路径加权、tight bounds 是紧致误差界、参与介质/非均匀介质/无偏、频域基、实测材质、有色介质、双线性面片、多光源采样等技术含义。
- 统一蒙特卡洛、文学编程；姓名和场景名称保留原文，修复破损混译及姓名串接。
- 保留 10–100 倍、2 GiB、836 MiB、15 GiB、超过 3300 万个三角形、412 张纹理贴图等全部限定与单位。
- 删除“英文 PDF 没有”的旧译者判断，因固定 HTML 在线版就是本次审校依据。

## 待处理问题

- **PREF-UPSTREAM-REF-01**：Scenes, Models, and Data 中 Florent Boyer 的住宅场景与 Simon Wendsche 的玻璃杯两处，上游原文就有未解析的 `chap:bidir-methods`。暂以明确译注保留，不构造失效链接；仍属未决上游引用问题。
- **PREF-BIB-01（公共文件）**：延伸阅读 12 个 References 条目均找到引用键对应，但元数据未完全忠实：`Knuth1984` 缺上游 1992 重印说明；`Knuth1986`、`Fraser95` 地点仅 USA（上游 Reading, Massachusetts）；`Knuth1993b` 缺上游联合出版社 Addison-Wesley；`reinhard2010high` 作者顺序不同（上游 Reinhard, Ward, Debevec, Pattanaik, Heidrich, Myszkowski）。主 agent 统一决定并修改公共 bibliography。对应上游锚点 `cite:Knuth84`, `cite:Knuth:1986:MP`, `cite:Fraser95`, `cite:Knuth93b`, `cite:Reinhard10`。
- 上述 References 本地集中在书后公共 bibliography，而非逐节重复；本任务没有宣称公共文献排版/全书引用完整。
- 桌面/移动端与三语 PDF 的实际排版检查由公共模板集成阶段完成，此任务未宣称视觉验收。

## 验证

- 逐段原文读取和手工对照已完成；独立复核待另一个 agent 重新阅读固定原文及修改后完整文件。
- `git diff --check`：通过。
- `typst compile --root . --input LANG_OUT=zh main.typ /tmp/preface-integration-zh.pdf`：未完成；被本任务范围外 `chapter-2.4-Transforming_between_Distributions.typ:92` 的 `unknown variable: diff` 阻断。不能把这次尝试记作 PDF 构建通过。
- 未修改代码标识符或任何数学公式；所有英文实质修改依据列于上文。
