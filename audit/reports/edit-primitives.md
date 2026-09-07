# 第七章初校记录

固定原书：f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c，4ed/Primitives_and_Intersection_Acceleration.html及其目录。工作范围独占7.0–7.5、相应supplements及本报告；公共模板/术语/书目不改。未调用旧Scripts或模型批处理。已阅读EDITORIAL与6.8的射线偏移/舍入误差相关语境；以固定HTML为真值，不以旧英文为完整依据。

## 第一批7.0、7.1、7.2及supplements/7.1-expanded.typ

状态：awaiting_review，2026-09-08已释放，待另agent独立复核；不是已精校。

7.0：完整4原段对照，CPU/GPU不同路径、Primitive外观属性与聚合体、O(n)条件、BVH/kd两类加速及本章只用于CPU的实现界限均保留。章标题双语；修英文和中文转录残留分号，数学O(n)/n及相对原书链接恢复。固定源本章没有正文图/章首图。

7.1：完整原文全文及26可见代码、19折叠面板读完。现有本地英文在TransformedPrimitive类定义后整段截断：补齐其构造/成员/包围盒、变换射线和返回交点信息的全部英文正文与代码，并人工补译；补全整个AnimatedPrimitive正文、类/成员/MotionBounds以及696/128字节历史上下文。补回SimplePrimitive段最后关于解析场景转渲染场景时选择轻量类的一句。图7.2和完整图注、上一版pbrt用7GB的脚注均原先缺失，现据固定源恢复。图7.1此前双语各造一幅导致重复编号，改共享图体+双语图注并用真实fig别名引用。

关键中文：图元不混基本体/原始体；shading旧译阴影改着色；明确SurfaceInteraction位于返回ShapeIntersection内部，不能说相关属性直接存在外层结构；alpha texture统一alpha纹理、0/1存在性和随机中间值不等同透射率；HashFloat保持多运行确定性且不同射线不同数值；继续同一球面求交、tMax减去已行进段/tHit加回该段；Primitive持有空间与真正渲染空间区分，from/to逐项核实；实例化数据23,241/31/3.1billion/24million/各内存分项完整保留。

代码：按原26可见文学片段恢复代码骨架，去除旧转录把折叠展开/翻译注释混入代码的重复，不改源标识符和算法。edit-7.1-code-evidence.json保存固定原片段及面板；新正文26/26忽略空白逐片段一致。补充965继承构造、966介质分支、967 Geometric额外声明、976 Simple额外声明、978 Transformed额外声明、982 Animated额外声明；其他面板对应正文已有子片段/完整函数。不同类的相同求交签名分别保留，不能跨类去重。没有编号公式、表或习题。

源问题：AnimatedPrimitive正文固定HTML直接显示未解析的Figure fig:spinning-spheres，且本页无对应图像；保留原文并加双语源疑点说明，没有虚构本地图号。6.1.4引用核为原锚点sec:isect-coordinate-spaces，链接已恢复。

7.2：完整7原段（本地拆成10双语段）逐句检查，空间划分与对象划分、ray远离绝大多数图元、近交点更可能先找到而远交点可能免测等条件保留，避免把可能性写成必然；聚合体不覆盖实际图元设置的材质/面光源/介质信息。无图/式/代码/脚注/表/习题。

验证：固定Typst0.13.1正式main.typ三语编译全部通过，/tmp/edit-primitives-first-{zh,en,bilingual}.pdf。中文535–547共13页逐页视觉查看，实际检查新增图7.2及图注、内存脚注、完整Animated代码与补充，未见裁切或图号重复。初校的全书编译不替代独立内容复核或全站验收。

## 第二批7.3

状态：awaiting_review，2026-09-08已释放，待独立复核。

完整固定Bounding_Volume_Hierarchies.html正文、5个小节、112个本地双语块（含原列表/原图误作块）逐段读完，全部11图7.3–7.13及子图/图注、编号式7.1及所有行内/无编号式对照。全部72可见代码及148折叠面板对照，其中大量为相同子片段的嵌套复用。新鲜edit-7.3-code-evidence.json列出每个面板的显示片段对应、复合对应或补充对应，没有未映射面板。可见代码72/72忽略空白逐片段一致，保留字面值、标识符、分支条件、顺序；新增原漏展示的Check for intersection with primitive in BVH node片段，不依赖之前展开在父块中的重复代码。文学片段标题从代码体分离，所有类/关键定义加真实标签。

原文→本地英文转换修复：条件概率p(A|B)原书s_A/s_B被转反，已依据原SVG修正；沿轴候选数原书2n被错转为2^n，恢复2n；Morton位交错式原只出现中文并丢失前导省略号，恢复共享式；图7.10原是无法渲染的Markdown字面串，恢复真实SVG和图注；图7.5补稳定标签、图7.7删重复Figure7.7字样、图7.9标题补漏字I；两条原脚注（mailboxing、GPU纹理Morton布局）补回，原线性扫描脚注的HTML标签全部转为可渲染正文。2^{10}等转录LaTeX花括号修复，公式t_isect参数显式分组。

中文重点：全节图元/包围盒/空间划分/对象划分统一（含图注）；先算整体包围范围的句子原把bounds译为“基本”修正；动态分派不误为调度；两种并行资源与原子区间预留分开解释，保留128*1024阈值、2:1成本权衡、12桶/11边界/6位×5轮/高12位/4096簇/29−12等实现条件。掩码取低位原译“屏蔽掉低位”修为取出低位；源MortonPrimitive句的尾部数组归属不再误写“在bvhPrimitives保存Morton码”，明确该数组中的图元索引与独立Morton码两个字段。LBVHTreelet nPrimitives是包含的图元总数，不减去第一项。tMax缩短、近远遍历只是尝试按顺序、命中叶节点后继续找更近命中、IntersectP两项区别均保留。

额外折叠：985完整BVHAggregate额外声明、986全部私有方法声明、1009实际switch及Middle贯穿EqualCounts、1026串行左右递归保存在supplements/7.3-expanded.typ；987私有成员组合、1002两初始化方法组合仅映射显示片段，其余面板也映射相应原子片段。buildUpperSAH在固定HTML仅声明，没有编造实现。

源问题明确保留校注：非空两组划分数2^(n−1)−2不等于无序非空划分通常计数2^(n−1)−1；“零体积”等价于全部质心同点不严谨，代码实际检查最长轴零跨度；8位Morton讨论给[8,15]/[8,11]并非完整8位索引范围。原代码及英文保留，不把源疑点称为已证明正确。正文orderedPrimitives/boundsBelow/MortonPrims命名与实际orderedPrims/boundBelow/MortonPrimitive差异可由代码对照辨明，未擅改英文或代码；中文使用确切对象含义。

验证：首次全书编译时另agent正在改6.8，曾因其临时缺失标签失败，未改动其他章节规避；随后正式main三语通过。最后固定Typst0.13.1三语输出/tmp/edit-bvh-final-{zh,en,bilingual}.pdf均通过。中文551–584共34页逐页视觉查看，涵盖11图、3脚注、式7.1、位图/采样簇图、全部补充；双语789页查看SAH式，794页查看线性扫描与脚注。实际发现线性扫描脚注与引入段分居前后页，将该段保持在不可断块后重新三语编译，放大复看563/564页，脚注标记和正文同页、代码正常。最终diff检查通过。此为初校验证，不能取代另agent独立复核或Web全站验收。


## 第三批7.4–7.5（先于大节7.3释放）

状态：awaiting_review，2026-09-08已释放，待独立复核。

7.4固定Further_Reading.html全部42正文段、5个无编号主题标题与完整120条页末参考文献已重新阅读；覆盖随机alpha、网格、BVH、kd树、SAH、其他加速主题，没有正文图/代码/编号式/脚注。保留O(n log²n)/O(n logn)、32/64字节、8/16字节等数学和量化说明。英文网格段误夹中文Snyder和Barr且重复一个引用，删去污染部分，中文恢复遗漏的Snyder/Barr作者归属。修复原语→图元、binary→二叉、BSP并非“也像kd树一样不轴对齐”的错误、Kay/Kajiya夹层包围方法、RTSAH用于阴影射线的条件、mailboxing记录测试过的射线而非仅成功命中的射线。标题双语化且按原书保持无编号；英文引用残留分号全部清理，后半截纯年份恢复明确source-cite原ID。

全部120书目（作者、年份后缀、标题、卷期/页码）逐条读固定源；新解析的bibitem文本与当前original-citations.json规范空白后120/120相同，7.4与7.5的引用集合也恰好120/120。保存primitives-reference-map.json，未修改公共书目。源Cline2006在BVH压缩段指向“Two stage importance sampling for direct lighting”论文，实际所指需要源层面确认；保留引用/原书目并明确双语说明，不静默换成猜测文献。

7.5固定Exercises.html全部13题重新阅读，中英文完整重整，恢复源难度②②②②②②③②②②②②③，去掉旧emoji及无来源Similarly，补原8–13题丢失难度。逐题覆盖最坏场景、层次网格、Overlaps、split clipping、63位Morton、SAH、混合结构、ray slope预计算、watertight错切与原包围盒误差、压缩BVH、并行mailboxing、相机与对象同速、预滤波可见性概率；所有实验比较/时间内存/失败与收益边界保留，不添加答案。错切不误为裁切，alpha不等同透射率，可见性概率不误为确定可见。没有原图、代码块或脚注；仅一条2^10=1024行内式，保留。

验证：最终固定Typst0.13.1正式main三语编译通过，/tmp/edit-primitives-short-{zh,en,bilingual}.pdf。实际逐页查看中文585–592共8页（并确认593开始第8章），引用年份后缀、5个主题标题及13题完整，无emoji/HTML泄漏、文字重叠或裁切。git diff --check通过。7.3目前仍in_progress，不因这批编译通过而标已初校。
