# 1.3／1.4 独立复核

复核者 edit_introduction，非初校 agent。状态：正文独立对照完成，补充在线代码已恢复并逐行重新核对；下述 HDR、小索引和本地代码导航限制仍保留。文件现已释放。

## 原文阅读与内容覆盖

直接完整读取固定 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c 的 4ed/Introduction/pbrt_System_Overview.html、How_to_Proceed_through_This_Book.html，包括全部展开面板内容；本地两份双语全文重新阅读。不是只核对初校摘要。

1.3：80 个双语正文块、53 个可见代码块、1 张表（14 类型）、8 幅图（1.13–1.20，其中1.20双图）、2 条脚注、1 个显示公式1.2、全部行内数学、6 个子节。
1.4：13 个双语正文/列表块、3 个子节、三个难度等级①②③及一两小时／10–20小时／40小时以上的对应关系。无公式、代码、图表、脚注。

表1.1逐行核对类型、源文件与节号；FloatTexture/SpectrumTexture共享纹理文件的原书两行组织保留。表只生成一次，双语按公共选择呈现。CleanupPBRT 的正文及代码、BSDF 为零/不透射的条件及同侧半球脚注、可空 VisibleSurface 条件、maxDepth 截止与 Le 返回、球面积 4π 和概率零的局限均已独立确认。

## 非重复折叠内容补齐

按主 agent 指令新增 chapter-1-Introduction/supplements/1.3-expanded.typ，并由1.3末尾 include；补充标题不编号、不进入目录，不改变1.4顺序。附中英文校订说明，明确来自在线展开面板、依赖上下文、不是独立程序。

- 源 HTML fragbit-7（约419行开始）：Process command-line arguments，86行。主文原只留占位，现保留面板全部命令行解析、错误输出与分支。
- fragbit-25（约1032行）和fragbit-30（约1158行）：Optionally write current image to disk，各9行。忽略空白逐字比较两者完全相同，仅保留一次。
- 其他展开面板内容均为本地已有片段重复或已包含在类定义展开中。特别是 Issue warning if unexpected radiance value is returned 已在 Trace cameraRay if valid 内完整存在，不重复追加。

新增代码全部重新与原面板文本核对。只调整嵌套面板带来的缩进、去HTML标记，标识符/字符串/控制流未改。原代码引用format/logLevel/referenceImage等上下文变量，未臆补定义。

## 独立排版修复

- 53个片段标题加sticky block；不超过12行的代码块整体不可分页，长类定义仍可分页。
- 英文效率段的“efficiency. this”依据源文改为分号。
- 图1.19、1.20实际原文分别引用random-walk-insanity.exr、watercolor-randomwalk.exr／watercolor-path.exr；已分别用macOS sips从固定EXR临时解码并与三张本地PNG逐幅查看。视角、对象、噪声分布与a/b次序匹配，不只是凭文件名认可。

## 正式构建与视觉

公共模板修复过程中曾遇 styles/common.typ 的临时语法错误，未动公共文件。主 agent 通知稳定后，Typst 0.13.1 正式 main.typ 中／英／对照三语均退出0：/tmp/review-system-overview-{zh,en,bilingual}.pdf。

中文PDF实际查看47页（完整单表1.1）、66页（图1.19）、71页（图1.20及补充开始）、72–73页（补充全文）。14类型/节号/文件显示完整，正确图像可见且未裁切；补充代码长行由公共样式换行，没有丢字。最后仅规范了新增代码的嵌套面板缩进，未改变token。

## 保留限制

- 三张PNG只是SDR阅读图，不是EXR/HDR像素或原站交互的等价替代；无需重跑渲染器也不能验证HDR展示能力。
- 原文介绍页边mini-index，本地并未实现完整页边小索引；正文及指向定义的原书链接保留，不能将小索引功能标为本地完成。
- 本地53片段标题与类型引用多数仍跳固定原文站点，而非全书本地代码锚点；链接映射属于公共Web后续工作。
- 本轮中文为代表页视觉检查，不扩大为每一页三语言视觉通过。
