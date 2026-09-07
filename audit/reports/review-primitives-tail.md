# 第七章7.4/7.5独立复核

固定原书子模块f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c。独占chapter-7.4-Further_Reading.typ和chapter-7.5-Exercises.typ，不改公共词表或书目。重新完整读取固定Primitives_and_Intersection_Acceleration/Further_Reading.html、Exercises.html，以及两文件全部英文和中文；初校报告不作为完整性证明。未使用旧Scripts。

## 已核范围

7.4完整导言、Grids、Bounding Volume Hierarchies、kd-trees、The Surface Area Heuristic、Other Topics in Acceleration Structures，直到两种多线程mailboxing方案。没有隐藏fold、代码体、图片、脚注、表格或编号公式；非编号复杂度O(n log²n)/O(n log n)、节点索引i→2i/2i+1、32/64/8/16字节等逐项核对。

120条固定原章节书目完整阅读，随后用源bibitem ID关联本地统一References的实际文字：119条忽略空白后相同；Wald06含O(n log n)数学SVG，正文周边文字对应，进一步对章节源SVG和本地SVG做XML完整树/属性/路径/标题比较，结果一致。未修改或重新生成书目，不把参考文献名称保留英文误标为中文漏译，也不声称120篇论文本身已事实核查。

7.5全部13题、②/③难度、题内全部限制/实验设计/性能与内存比较/追问完整复核。特别保持30位Morton→每维2¹⁰=1024、64位整数保存63位编码、Shape Overlaps的渲染空间参数、不能自细分形状的明确接口、相机与目标无相对运动及近似相同运动扩展、阴影近似可见性概率而非二元结果等。没有新增题目、代码体、图表或脚注。

## 修复与术语

- 与主agent协商并获统一决议：watertight＝水密（7.4首次附英文），packet tracing＝射线包追踪，incoherent rays＝非相干射线；这里的相干性是遍历/数据访问相干性，不是波动光学。7.5“错切”统一为本书已有“剪切”。
- 7.4补回均匀网格属于空间划分的明确分类；Rubin/Whitted“first hierarchical data structures”恢复“第一个”，未任意弱化为“早期”。
- Goldsmith/Salmon的volume’s surface area误成“体积的表面积”，改为“包围体的表面积”。Lin共享平面明确属于子节点包围盒。Kopta bound moving objects误为绑定，改为包围。
- perfect splits统一“完美划分”；源“best kd-trees”不再译成弱化的“高效kd树常…”。mailboxing补回“虽然有效”让步条件，最近n记录明确指求交涉及的图元。
- 其余修正涉及综述/作者说明文章、SAH估计与分桶及BVH布局句子的中文语序，不改作者年份/算法归属，不消除源文的性能代价或未知条件。

固定源Cline2006在紧凑BVH节点段的引用，确实链接到Two stage importance sampling for direct lighting；原章节书目及统一书目都是该题名。已有双语源问题注保留，没有凭主题猜换另篇文献。这一未决源问题不因本批翻译复核通过而变成已解决。

## 验证与释放

Typst0.13.1+fonts局部三语编译无警告，`/tmp/review-primitives-tail-{zh,en,bi}.pdf`，包含真实References；外节ref占位，仅局部语法。实际查看双语13页多篇文献段、15页习题1–3及跨页习题4起始，正文/作者年份/代码签名/编号和难度均清楚无裁切。预览`/tmp/review-primitives-tail-{13,15}.png`。diff检查通过。

7.4/7.5独立原文复核通过并释放。正式全书编号、引用和三语PDF/网页全部页面验收仍单列；本报告不覆盖尚未交由本agent的7.3。
