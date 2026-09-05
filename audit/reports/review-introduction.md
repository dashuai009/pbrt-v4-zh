# 1.0–1.1 独立复核

状态：verified（仅此两文件的原文对照与中文内容复核）；PDF 视觉及网页交互验收仍待集成。

复核者与修改者不同。本次先重新读取完整本地双语文本，再重新读取固定上游全文、脚注及片段 HTML，未以修改摘要或编译结果替代语义审查。

## 依据与范围

上游 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`：

- `4ed/Introduction.html`：`chap:overview`，全部 3 段正文，章首 `openers/nightsnow.jpg`，`fig:pbrt-kroken-view` 图片与完整图注，正文全部日期与外链。
- `4ed/Introduction/Literate_Programming.html`：`sec:litprog` 至末段“rearranging program source code”，全部 15 段正文，唯一脚注，6 个可见代码块，`fragment-FunctionDefinitions-0/1` 和 `fragment-InitializeGlobalVariables-0/1` 四个片段位置及其上下三角互链；核查 `fragbit-0` 隐藏展开内容及 `fragbit-1`–`fragbit-4` 空面板。
- 阅读本地下一节开头作为衔接上下文。

两页没有公式、表格、习题、独立延伸阅读或索引正文。章首图无图注；Kroken 图注及 Angelo Ferretti 署名完整。脚注的示例代码非 pbrt 限定完整。首段 Knuth 引语与书籍包含完整实现的限定完整。代码逐块核对数值、变量、分号、参数类型、片段名称和顺序。

## 发现、修复与重新检查

1. **实际编号引用问题**：初次修改把 `@fig:pbrt-kroken-view` 改为 `@pbrt-kroken-view`。重新查公共模板及真实 Typst 查询发现：原始 figure 和 i-figured 输出 figure 同时存在，编号应指向后者 `<fig:pbrt-kroken-view>`。本次恢复两处 `@fig:pbrt-kroken-view`。修复后通过公共 pbrt 模板三语编译；查询确认目标 `kind=i-figured-image`、图计数 `[1]`、章计数 `[1]`，对应 1.1。初次 edit-introduction.md 关于该引用“修复”的结论应以本复核报告为准。
2. **代码排版一致性**：将抽取后完整 InitGlobals 代码块的裸代码围栏明确为 cpp，不更改代码内容。重新与原文 208 行附近完整输出核对无变化。
3. **三角语义**：原书 `fa-caret-down` 与 `fa-caret-up` 分别对应本地 ▼/▲；四个本地目标均存在且方向正确。正文中的“继续添加”“上一次添加”与实际目标一致，无需修改。

中文逐段复核未发现剩余技术误译或缺段。literate programming、weaver、tangler、fragment 按主 agent 统一术语；抽取与就地展开语义准确。英文内容完整，未以中文替换英文。

## 检查与限制

- 修复后三语使用公共 pbrt 模板编译通过，输出 `/tmp/audit-intro-review-zh.pdf`、`/tmp/audit-intro-review-en.pdf`、`/tmp/audit-intro-review-bilingual.pdf`。
- `git diff --check` 通过。临时入口已删除。
- 未进行视觉验收；本报告不宣称分页、中文字体或手机网页已验收。
- 本地未实现原站加号展开，已有译者注明确其指英文原站；完整展开代码已在后文出现，内容无遗漏。这项交互差异由公共网站层继续处理。
- 全书公共图注语言仍须统一检查；本次确认的是图注内容与真实编号目标，不宣称模板中文 supplement 已完善。

## 补充：1.1 片段标题外框排版修复

主 agent 在网页实际检查中发现四个代码片段标题的裸 `[#raw(...)]` 会显示额外方括号。本次仅将这四个外框换为 `#block(sticky: true)[...]`，保留内部箭头、链接、标签和全部代码不变。需主 agent 刷新网页输入 hash 后复看；原文语义复核状态不因这一排版修复扩大。
