# 序言与延伸阅读独立复核

正文及中文对照：独立复核通过。全范围状态暂为 awaiting_review：公共参考文献有下列待主 agent 修复的信息缺项；两处固定上游未解析章号保持未决，不标记为已解决。

本复核者与原修改者不同，重新读取两份完整本地中英文本及固定原书 HTML 全文，包含全部长名单和许可段，未以修改摘要或编译通过替代复核。

依据：`f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`，`4ed/Preface.html` 和 `4ed/Preface/Further_Reading.html`。这两页大部分小标题没有原书锚点，下表使用原标题及 HTML 起始行定位，避免虚构锚点。

## 实际范围

| 原书位置 | 覆盖 |
|---|---|
| Preface.html:71 至 Audience | Erik Naggum 完整题辞及署名、全部导言段落；原文限定、现实感定义与跨学科列举 |
| Audience:177 | 三类读者三段，课程前置知识、源码规模、研究与工业用途 |
| Overview and Goals:231 | 从 ray tracing 起至网站反馈段末，完整性/阐释性/物理依据/效率权衡、唯一脚注及 authors@pbrt.org |
| Changes Between The First and Second Editions:371 | 引导段与4条项目：插件、图像流水线、并行、production；Reinhard引文 |
| Changes Between The Second and Third Editions:453 | 引导段与7条项目、结尾段；全部算法名、限定条件 |
| Changes Between The Third and Fourth Editions:544 | 全部引导段、5条项目及末段；2019、10–100倍、GPU章引用 |
| Acknowledgments:624 | 完整作者、学生、教师、审稿人、算法专家、实现贡献者、错误报告者、LuxRender及影片致谢名单，无省略 |
| Production | 第一至第四版四段制作人员、机构与职责 |
| The Online Edition | 2023-11-01、开源项目/字体作者、Patreon完整名单与关闭说明、全部版权和两项CC许可 |
| Scenes, Models, and Data | 所有场景、模型、扫描、环境图及光谱/相机数据贡献者；许可声明和原文两处未解析章号 |
| About The Cover:1138 | Watercolor署名；2 GiB/836 MiB/15 GiB、超过3300万三角形、412贴图全部核对 |
| Preface/Further_Reading.html:79–105 | 完整两段及全部11个文学编程引用关联、网站 |
| 同页 References | 12条参考文献逐项与公共 bibliography 读取比较，包括被序言主体引用的Reinhard |

原书两页没有公式、可见代码块、插图/图注、数据表或习题。场景图片均为文字致谢，不把致谢误计为图片缺失。全局网站版权页脚由公共网站层负责。

## 修复与复查

- 延伸阅读两种语言中的 TeX 恢复原 HTML 的 E 下标（`T#sub[E]X`），改后重新与 HTML 82 行对照。
- 版权英文准确为 `© Copyright 2004–2023 Matt Pharr, Wenzel Jakob, and Greg Humphreys`；没有 copyright 拼写错误。正文 `CC BY-NC-ND 4.0`、插图 `CC BY-NC-SA 4.0` 的文字、用途及链接与固定原书一致，无需改动。
- 正文中文未发现剩余误译、漏段、名单漏项或数值错误。保留时期语境，不将各旧版变更描述误当当前版本承诺。
- `chap:bidir-methods` 两处确实出现在固定上游正文，现有中文译注如实揭示未解析标识；没有猜测目标，仍为待核实项。

## 公共参考文献问题（已交主 agent；本 agent 未修改公共文件）

所有12个引用键均存在，主要作者、年份、书名对应正确。但内容完整性仍有以下问题：

1. `Knuth1984` 缺原书重印信息：Reprinted in D. E. Knuth, Literate Programming, Stanford Center for the Study of Language and Information, 1992。
2. `Knuth1986` 的原书出版地 Reading, Massachusetts 被本地泛化为 USA。
3. `Knuth1993b` 原书出版者 ACM Press and Addison-Wesley，本地只有 Association for Computing Machinery。
4. `Fraser95` 原书出版地 Reading, Massachusetts，本地 USA；出版者原书 Addison-Wesley，本地变成 Longman Publishing Co., Inc.。
5. `reinhard2010high` 作者顺序原书 Reinhard, Ward, Debevec, Pattanaik, Heidrich, Myszkowski；本地将 Heidrich 前置。应按固定源顺序整理。

映射：Knuth84→Knuth1984；Knuth:1986:MP→Knuth1986；Knuth93→Knuth1993a；Knuth93b→Knuth1993b；Knuth1994→Knuth1994；Knuth1999→Knuth1999；Fraser95→Fraser95；Hanson1996→Hanson96；Melhorn1999→Mehlhorn99；Valiente2002→Valiente02；Ruckert05→Ruckert05；Reinhard10→reinhard2010high。

## 验证及边界

Typst `0.13.1 (8ace67d9)`，路径 `/tmp/pbrt-tools/typst-aarch64-apple-darwin/typst`。临时入口引入公共 pbrt 模板、两序言文件及公共 bibliography，但屏蔽 ref 显示以隔离跨章依赖。三语编译通过：`/tmp/audit-preface-review-zh.pdf`、`/tmp/audit-preface-review-en.pdf`、`/tmp/audit-preface-review-bilingual.pdf`。临时入口已删除，`git diff --check` 通过。

此检查仅验证语法与基本构建，不证明跨章链接/引用显示正确，也没有进行视觉验收。需主 agent 修复上述公共书目后，保留原书章号未决状态，才能完成对应书目内容单元的验收。
