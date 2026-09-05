# 第一批：1.0 与 1.1 对照修改

状态：awaiting_review，尚未独立复核，不得标记已精校。

固定原书 HEAD 实测：f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c。

独占文件：
- chapter-1-Introduction/chapter-1.0-Introduction.typ
- chapter-1-Introduction/chapter-1.1-Literate_Programming.typ

## 实际阅读与覆盖

直接读取并逐段对照固定原书：
- 4ed/Introduction.html，chap:overview 至正文末尾及 fig:pbrt-kroken-view。覆盖全部 3 段正文、章标题、开篇 nightsnow.jpg、Kroken 图片和完整图注。
- 4ed/Introduction/Literate_Programming.html，sec:litprog 至正文末尾。覆盖全部 15 段正文、节标题、唯一脚注、6 个可见代码块以及 fragment-FunctionDefinitions-0/1、fragment-InitializeGlobalVariables-0/1。展开副本中的 shoeSize/dielectric 与后文完整代码相同；保留一次完整输出示例。其余展开面板为空。
- 阅读本地 1.2 前部作为衔接上下文。
- 两页无数学公式、表格、独立延伸阅读、习题或索引条目。原站全局导航/版权页脚不是本节正文；全站版权与导航由公共网站层负责。

## 修正

- 1.1 首段原中文漏掉“完整实现，而非仅高层描述”；补全。
- 1.0 图注原中文句子断裂、缺“下载”；完整恢复，保留场景署名。
- 两个标题改用语言选择函数；所有中文逐段修正指代、限定和语序。
- 遵从主 agent 统一：文学编程、代码抽取器、代码片段。
- 1.0 英文错误的 pbr-book.org 网站地址依据上游末段改为 pbrt.org；中译同步。
- 1.0 引用 @fig:pbrt-kroken-view 与既有标签不符，改为实际标签 @pbrt-kroken-view。
- 1.1 原转换丢掉上下三角符号；恢复 ▼/▲ 与本地片段互链。错误混入代码的片段标题移出代码块，原代码语句与标识符不变。
- 英文恢复 TeX 下标、重要术语强调、脚注误加引号与代码分号位置。
- 关于原站加号展开的说明保留原文，并用译者注明确指英文原书网站功能；本地版本尚未实现此交互，不声称已有。

## 验证及遗留

- git diff --check 通过。
- 临时入口引用公共 pbrt 模板与两节，以 --font-path fonts 分别编译 LANG_OUT=zh、LANG_OUT=en、不设 LANG_OUT：均退出 0。
- 输出 /tmp/audit-introduction-zh.pdf、/tmp/audit-introduction-en.pdf、/tmp/audit-introduction-bilingual.pdf；临时入口已删除。
- 尚未做视觉验收；未以编译成功证明排版已验证。
- 网页代码片段展开功能待公共站点层实现；已保留语义与说明。
- 无未决翻译技术问题；需要另一 agent 重新阅读原书及全部修改文本作独立复核。
