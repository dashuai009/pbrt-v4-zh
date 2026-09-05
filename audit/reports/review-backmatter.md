# 完整书目与双索引：独立转录复核

状态：**固定原文到本地的逐条转录核验通过；不是1355篇文献的事实核验，也不是数千个名称的中文语义精校。** 名称、代码标识符和书目题名按要求保留原文。

复核者 edit_introduction，与导入生成器作者不同。复核前未读取该生成器；使用独立的 Python 标准库 HTMLParser 事件解析器、Typst 内容读取器和 XML 结构比较器，不调用旧翻译/转换/润色脚本，不调用任何模型批处理。

## 可重放的逐项证据

- `audit/reports/backmatter_checker.py`：独立审核程序，仅读取原书/正文，写入审核数据，不生成或翻译正文。
- `audit/reports/backmatter-mapping-evidence.jsonl`：5433条逐项证据，分别记录固定源HTML/起始行/组/源列表深度、本地文件/行、原文与本地完整文字—链接—SVG事件序列、两侧摘要、每条原书目标的文件与锚点存在性、数学资源路径/alt/高度/基线参数及匹配结果。
- `audit/reports/backmatter-audit-summary.json`：汇总结果。未匹配行、未知目标语法、组差异、链接缺失或数学元数据差异会让检查器失败，不能只靠数量相等通过。

基线：pbr-book-website@f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c，4ed/References.html、Index_of_Fragments.html、Index_of_Identifiers.html。

1355条书目、1696条片段、2382条标识符逐序比较通过；全部实际字母组（包括片段的反斜线组、小写m组，以及标识符末尾小写组）次序一致。Source first/last：Adams→Zwicker；Account for cosθ_i in importance at surfaces→main program；AbsCosTheta()→util/colorspace.h。没有把原书不存在的字母组补入。

所有文字、标点及数学资源在比较中保留。允许HTML空白归一化（含nbsp等），但不消除非空白字符差异。102个独立SVG、250次引用均以XML元素、全部属性、路径数据、标题和子树顺序对照；不是仅比文件名。最终250次alt和源ex尺寸/基线参数也全部匹配。

## 11处HTML/URL等价转换的明确记录

5433条中5422条原始事件序列直接一致。余下11条不是漏项，逐条检查如下：

- References序号419、540、553、970、973、1117：裸域名URL被标准URL序列化补根路径`/`。可见文字完全未变，包括IESNA源域名末尾的点。
- Fragments序号230、355、432、488、842：源HTML在外层a里非法嵌套另一个a。HTML解析会在内层a开始前关闭外层链接，导入结果为相邻链接与后续文本。两条链接目标及可见文字顺序均保留。源码不是可合法保留的嵌套超链接结构，因此按HTML锚点修复语义比较；证据同时保留原始序列和`exact_events_match=false`，没有悄悄当作字节完全相同。

## 独立目标检查

4083次原书目标引用、4078个唯一目标，独立读取相应固定HTML文件并用HTML解析器查找id/name：文件和锚点全部存在。**这是固定检出版本中的源目标有效性，不是互联网HTTP可达性，也不是本地Web站点映射已完成。**

另外存在47个不同的外站URL；本轮不声称全部在线有效。其中8个源URL包含空白/NBSP：ccrma.stanford.edu的jos、graphics.stanford.edu的seander、cs.cmu.edu的ph、plunk.org的hatch、roylongbottom.org.uk的linpack results.htm、statweb.stanford.edu的owen、archive.org内的arvo、mitsuba-renderer.org的wenzel。原样保留，后续纠错需独立来源，不能猜测后标通过。

## 排版发现、修复与生成器同步要求

1. 条目正文用`#text(size:9pt)[...]`，不降低标题字号。文件设置`par(spacing:.2em, leading:.4em, first-line-indent:0pt)`。
2. 标识符源HTML有1748条处于二级ul，原导入全部压平。本次恢复1em左缩进：`block(inset:(left:1em), above:.4em, below:.4em)`。实测above/below为0会使独立块重叠，不能重用0pt版本。
3. 裸image在paragraph中被Typst忽略；仅编译成功并不能证明数学保留。先用box承载使图形出现，随后实际查看发现固定height:1.15em及默认box基线会把LP的下标τ排成上标，并使cosθ整体浮高。
4. 最终新增`backmatter/math/inline.typ`的`original-math(path,height-ex,depth-ex,alt)`。从当前字体的x-height换算源SVG的ex单位；height-ex取根SVG height，depth-ex取负的CSS vertical-align；使用`box(baseline:depth-ex*x-height, image(height:height-ex*x-height,...))`。原始SVG文件本身未改。alt取原MathJax title。
5. 生成器须导入此helper，并发出`#original-math(...)`，不能再次回退到固定高度裸image。保留所有记录、分组、原链接及嵌套锚点的HTML修复行为。

参考实现依据Typst官方的[box基线规则](https://typst.app/docs/reference/layout/box/)和[text的x-height边界](https://typst.app/docs/reference/text/text/)，并实测Typst0.13.1支持。不是只依赖当前文档推断旧版本可用。

## 实际构建与视觉验收

三文件用公共PDF模板的真实专用入口合并编译，无虚构引用/删记录；最新为94页（包括模板封面），无`block may not occur inside paragraph`警告。首／中／尾页实际查看：书目2、18、36；片段37、48、58；标识符59、76、94。修复后重看了LP_τ与cosθ_i所在页，确认数学确实出现、下标在正确基线位置，标识符嵌套成员不再重叠。反斜线组和所有小写尾组实际可见。

另用正式main.typ、Typst0.13.1、--font-path fonts，中文／英文／对照全书均成功退出0：
`/tmp/review-backmatter-full-zh.pdf`、`/tmp/review-backmatter-full-en.pdf`、`/tmp/review-backmatter-full-bilingual.pdf`。

正式中文全书1230页与1265页再次渲染，确认LP_τ和cosθ_i在整书上下文中也出现且位置正确。英语/对照完成构建，没有宣称它们每页均视觉验收。临时专用入口已删除。

本报告仅确认这些backmatter内容的原文转录、目标与代表性PDF布局。全站移动端、在线链接可达性、全部外部书目URL、原规范化bibliography与完整源书目的重复协调，仍由主agent统一验收。
