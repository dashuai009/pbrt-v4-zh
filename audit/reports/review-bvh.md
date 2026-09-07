# 第7.3节BVH独立复核

固定源f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c的Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html。独占正文及supplements/7.3-expanded.typ。实际重新完整读取1757行本地中英（修改前）、74行supplement及固定原HTML，不依赖初校结论，未使用旧Scripts。

## 语义独立复核通过

覆盖引言和5子节：BVH Construction、Surface Area Heuristic、Linear Bounding Volume Hierarchies、Compact BVH for Traversal、Bounding and Intersection Tests直到IntersectP说明。全部72个可见代码、148fold逐体阅读；临时解析把完全相同直接体分为59组，每组实际读代码并保留全部面板ID，不凭数量通过。985/986额外接口声明、1009含fallthrough的完整splitMethod分派、1026串行子树构建均与supplement一致；其余正文复用/嵌套展开均核对。没有漏补新代码或猜补buildUpperSAH：固定页本就只展示其声明/调用与省略说明。

11图7.3–7.13及子图/全部图注、编号式7.1、所有无编号式/复杂度/位编码/区间、3条脚注均重读；无表格、书目或习题。脚注为mailboxing多线程、前版本二次扫描成本/约2倍提升、Morton纹理存储缓存收益。

重点核查：对象划分各图元只出现一次与2n−1界、凸包围体包含关系/均匀随机射线的条件概率、SAH相对成本1与1/2、成本和求交/遍历权衡、12桶及11候选、前后扫描、并行128×1024阈值/原子预留不重叠区间；Morton每维10位/总30位/每轮6位5轮/高12位4096格/低位17继续分裂、原子节点计数每小树更新一次；32字节对齐、深度优先布局、节点标志uint16/uint8、64项栈实践限制、近优先为启发式、即使命中仍查可能更近节点及tMax缩小均保留。

## 修正

英文`Primitive;s`和`Morton codes;,`属于转录残留，已对照固定源的Primitives及Morton codes后逗号恢复；嵌套反引号的Create leaf BVHBuildNode片段名改明确括号及代码标识符。

中文图7.6明确“已知射线穿过A”的条件概率，不让B/C的“分别”被误读为联合概率；图7.7重写重复投影病句，保留按包围盒质心分桶和最小成本平面。包围范围不再误称边界/边界层次；排序pass不再误“传递”；32字节对齐解释、缓存访问效率、Moana地被植被等语序/术语修复。未改任何C++标识符、字面值、条件分支或算法。

源问题的已有双语校注独立重核并保留：2^(n−1)−2与无序两组正确计数2^(n−1)−1；零体积不等于全部质心重合；8位Morton代码的高位范围却写成[8,15]/[8,11]。这些源问题未因译文审校通过而被标为算法已修正。

## 验证与公共编号阻碍

先使用真实source-file状态与章计数7尝试0.13.1+fonts三语局部编译，新公共缺编号断言正确阻断两处：
- bvh-midpoint应映射原bvh-split-middle，图7.5，固定图pha07f05.svg。
- lbvh-treelets应映射原lbvh-clusters，图7.10，固定图pha07f10.svg。

已向主agent提交这两个经完整原图/图注独立核实的别名；不在本agent范围内修改公共映射。

随后另作不设source-file的局部语法检查，三语均无警告，`/tmp/review-bvh-{zh,en,bi}.pdf`，未伪造引用（节内引用真实存在）。实际查看双语16页分割三子图及图注、18页SAH与条件概率、30页完整基数排序代码，无裁切。图号在该局部模式来自局部计数，因此明确不能当正式原编号验收。预览`/tmp/review-bvh-{16,18,30}.png`。

语义独立复核通过，7.3与supplement释放。公共别名修复后还需重新执行带source-file的编号验证，未在此声明正式全书PDF或网站通过。

### 公共别名修复后的复验

主agent补齐上述两条别名后，重新使用真实source-file和章/节计数执行三语局部编译，全部通过且无警告：`/tmp/review-bvh-numbered-{zh,en,bi}.pdf`。再次查看双语16页`/tmp/review-bvh-numbered-16.png`，原来局部错号的分割图现在正确为图7.5。缺映射断言未被禁用。7.3局部原编号集成阻碍已解除并最终释放；仍不是正式全书/全站验收。
