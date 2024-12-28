#import "../template.typ": parec


== Further_Reading

#parec[
  The stochastic alpha test implemented in Section #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#sec:gprim")[7.1.1] builds on ideas introduced in Enderton et al.'s stochastic approach for transparency (#link("<cite:Enderton2010>")[2010];) and Wyman and McGuire's hashed alpha testing algorithm (#link("<cite:Wyman2017>")[2017];), both of which were focused on rasterization-based rendering.
][
  第 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#sec:gprim")[7.1.1] 节实现的随机透明度测试基于 Enderton 等人提出的用于透明度的随机方法 (#link("<cite:Enderton2010>")[2010];) 和 Wyman 与 McGuire 的哈希 alpha 测试算法 (#link("<cite:Wyman2017>")[2017];) 中介绍的思想，这两者都专注于基于光栅化的渲染。
]

#parec[
  After the introduction of the ray-tracing algorithm, an enormous amount of research was done to try to find effective ways to speed it up, primarily by developing improved ray-tracing acceleration structures. Arvo and Kirk's chapter in #emph[An Introduction to Ray Tracing] (Glassner #link("<cite:Glassner:IntroRayTracing>")[1989a];) summarizes the state of the art as of 1989 and still provides an excellent taxonomy for categorizing different approaches to ray intersection acceleration.
][
  在光线追踪算法引入后，进行了大量研究以寻找加速其过程的有效方法，主要是通过开发改进的光线追踪加速结构。 Arvo 和 Kirk 在 #emph[An Introduction to Ray Tracing] (Glassner #link("<cite:Glassner:IntroRayTracing>")[1989a];) 中的章节总结了截至 1989 年的最新技术，并仍然为光线相交加速的不同方法提供了一个优秀的分类法。
]

#parec[
  Kirk and Arvo (#link("<cite:Kirk88>")[1988];) introduced the unifying principle of #emph[meta-hierarchies.] They showed that by implementing acceleration data structures to conform to the same interface as is used for primitives in the scene, it is easy to mix and match different intersection acceleration schemes. `pbrt` follows this model.
][
  Kirk 和 Arvo (#link("<cite:Kirk88>")[1988];) 引入了 #emph[元层次结构] 的统一原则。他们展示了通过实现符合场景中原语接口的加速数据结构，可以轻松混合和匹配不同的相交加速方案。 `pbrt` 遵循了这一模型。
]


=== Grids


#parec[
  Fujimoto, Tanaka, and Iwata (#link("<cite:Fujimoto86>")[1986];) introduced uniform grids, a spatial subdivision approach where the scene bounds are decomposed into equally sized grid cells. More efficient grid-traversal methods were described by Amanatides and Woo (#link("<cite:Amanatides87>")[1987];) and Cleary and Wyvill (#link("<cite:Cleary:1988:AOA>")[1988];). Snyder and Barr (#link("<cite:Snyder87>")[1987];) described a number of key improvements to this approach and showed the use of grids for rendering extremely complex scenes. Snyder 和 Barr (#link("<cite:Snyder87>")[1987];) Hierarchical grids, where grid cells with many primitives in them are themselves refined into grids, were introduced by Jevans and Wyvill (#link("<cite:Jevans89>")[1989];). More sophisticated techniques for hierarchical grids were developed by Cazals, Drettakis, and Puech (#link("<cite:Cazals95>")[1995];) and Klimaszewski and Sederberg (#link("<cite:Klimaszewski97>")[1997];).
][
  Fujimoto、Tanaka 和 Iwata (#link("<cite:Fujimoto86>")[1986];) 引入了均匀网格，这是一种空间细分方法，其中场景边界被分解为大小相等的网格单元。 Amanatides 和 Woo (#link("<cite:Amanatides87>")[1987];) 以及 Cleary 和 Wyvill (#link("<cite:Cleary:1988:AOA>")[1988];) 描述了更高效的网格遍历方法。 描述了该方法的一些关键改进，并展示了网格在渲染极其复杂场景中的应用。 Jevans 和 Wyvill (#link("<cite:Jevans89>")[1989];) 引入了分层网格，其中包含许多原语的网格单元本身被细化为网格。 Cazals、Drettakis 和 Puech (#link("<cite:Cazals95>")[1995];) 以及 Klimaszewski 和 Sederberg (#link("<cite:Klimaszewski97>")[1997];) 开发了更复杂的分层网格技术。
]

#parec[
  Ize et al.~(#link("<cite:Ize2006>")[2006];) developed an efficient algorithm for parallel construction of grids. One of their interesting findings was that grid construction performance quickly became limited by memory bandwidth as the number of cores used increased.
][
  Ize 等人 (#link("<cite:Ize2006>")[2006];) 开发了一种用于并行构建网格的高效算法。 他们的一个有趣发现是，随着使用的核心数量增加，网格构建性能很快受限于内存带宽。
]

#parec[
  Choosing an optimal grid resolution is important for getting good performance from grids. A good paper on this topic is by Ize et al.~(#link("<cite:Ize07>")[2007];), who provided a solid foundation for automatically selecting the resolution and for deciding when to refine into subgrids when using hierarchical grids. They derived theoretical results using a number of simplifying assumptions and then showed the applicability of the results to rendering real-world scenes. Their paper also includes a good selection of pointers to previous work in this area.
][
  选择最佳的网格分辨率对于获得良好的性能至关重要。 Ize 等人 (#link("<cite:Ize07>")[2007];) 的一篇优秀论文为自动选择分辨率以及在使用分层网格时何时细化为子网格提供了坚实的基础。 他们在一些简化假设下推导出了理论结果，然后展示了这些结果在渲染现实世界场景中的适用性。 他们的论文还包括了该领域先前工作的良好指引。
]

#parec[
  Lagae and Dutré (#link("<cite:Lagae08a>")[2008a];) described an innovative representation for uniform grids based on hashing that has the desirable properties that not only does each primitive have a single index into a grid cell, but also each cell has only a single primitive index. They showed that this representation has very low memory usage and is still quite efficient.
][
  Lagae 和 Dutré (#link("<cite:Lagae08a>")[2008a];) 描述了一种基于哈希的创新均匀网格表示，该表示具有理想的特性，不仅每个原语都有一个网格单元的索引，而且每个单元只有一个原语索引。 他们展示了这种表示具有非常低的内存使用量且仍然相当高效。
]

#parec[
  Hunt and Mark (#link("<cite:Hunt08a>")[2008a];) showed that building grids in perspective space, where the center of projection is the camera or a light source, can make tracing rays from the camera or light substantially more efficient. Although this approach requires multiple acceleration structures, the performance benefits from multiple specialized structures for different classes of rays can be substantial. Their approach is also notable in that it is in some ways a middle ground between rasterization and ray tracing.
][
  Hunt 和 Mark (#link("<cite:Hunt08a>")[2008a];) 展示了在透视空间中构建网格（其中投影中心是相机或光源）可以使从相机或光源追踪光线的效率显著提高。 尽管这种方法需要多个加速结构，但针对不同类别光线的多个专用结构带来的性能收益可能是显著的。 他们的方法值得注意，因为在某些方面它介于光栅化和光线追踪之间。
]


=== Bounding Volume Hierarchies


#parec[
  Clark (#link("<cite:Clark76>")[1976];) first suggested using bounding volumes to cull collections of objects for standard visible-surface determination algorithms. Building on this work, Rubin and Whitted (#link("<cite:Rubin80>")[1980];) developed the first hierarchical data structures for scene representation for fast ray tracing, although their method depended on the user to define the hierarchy. Kay and Kajiya (#link("<cite:Kay86>")[1986];) implemented one of the first practical object subdivision approaches based on bounding objects with collections of slabs.
][
  Clark（#link("<cite:Clark76>")[1976];）首次建议使用包围体来剔除对象集合以用于标准的可见面判断算法。 在此基础上，Rubin 和 Whitted（#link("<cite:Rubin80>")[1980];）开发了用于场景表示的第一个分层数据结构，以实现快速光线追踪，虽然他们的方法依赖于用户自行定义层次结构。 Kay 和 Kajiya（#link("<cite:Kay86>")[1986];）实现了基于包围物体的集合的第一个实用对象细分方法之一。
]

#parec[
  Goldsmith and Salmon (#link("<cite:Goldsmith87>")[1987];) described the first algorithm for automatically computing bounding volume hierarchies. Although their algorithm was based on estimating the probability of a ray intersecting a bounding volume using the volume's surface area, it was much less effective than modern SAH BVH approaches. The first use of the SAH for BVH construction was described by Müller and Fellner (#link("<cite:Muller1999>")[1999];); another early application is due to Massó and López (#link("<cite:Masso2003>")[2003];).
][
  Goldsmith 和 Salmon（#link("<cite:Goldsmith87>")[1987];）描述了第一个自动计算包围体层次结构的算法。 尽管他们的算法基于通过体积的表面积估计光线与包围体相交的概率，但其效果远不如现代的表面积启发式 BVH 方法。 Müller 和 Fellner（#link("<cite:Muller1999>")[1999];）首次描述了用于 BVH 构建的 SAH 的使用；另一个早期应用是 Massó 和 López（#link("<cite:Masso2003>")[2003];）。
]

#parec[
  The BVHAggregate implementation in this chapter is based on the construction algorithm described by Wald (#link("<cite:Wald07>")[2007];) and Günther et al.~(#link("<cite:Gunther2007>")[2007];). The bounding box test is the one introduced by Williams et al.~(#link("<cite:Williams05>")[2005];). An even more efficient bounding box test that does additional precomputation in exchange for higher performance when the same ray is tested for intersection against many bounding boxes was developed by Eisemann et al.~(#link("<cite:Eisemann2007>")[2007];); we leave implementing their method for an exercise. Ize's robust ray–bounding box intersection algorithm ensures that the BVH is #emph[watertight] and that valid intersections are not missed due to numeric error (#link("<cite:Ize2013>")[Ize 2013];).
][
  本章中的 #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate] 实现基于 Wald（#link("<cite:Wald07>")[2007];）和 Günther 等人（#link("<cite:Gunther2007>")[2007];）描述的构建算法。 包围盒相交测试是由 Williams 等人（#link("<cite:Williams05>")[2005];）引入的。 Eisemann 等人（#link("<cite:Eisemann2007>")[2007];）开发了一种更高效的包围盒相交测试，通过额外的预计算换取在相同光线对多个包围盒进行相交测试时的更高性能；我们将实现他们的方法作为练习。 Ize 的稳健光线-包围盒相交算法确保 BVH 是#emph[密封的];，并且不会因数值误差而错过有效的相交（#link("<cite:Ize2013>")[Ize 2013];）。
]

#parec[
  The BVH traversal algorithm used in pbrt was concurrently developed by a number of researchers; see the notes by Boulos and Haines (#link("<cite:Boulos2006>")[2006];) for more details and background. Another option for tree traversal is that of Kay and Kajiya (#link("<cite:Kay86>")[1986];); they maintained a heap of nodes ordered by ray distance. On GPUs, which have relatively limited amounts of on-chip memory, maintaining a stack of to-be-visited nodes for each ray may have a prohibitive memory cost. Foley and Sugerman (#link("<cite:Foley2005>")[2005];) introduced a "stackless" kd-tree traversal algorithm that periodically backtracks and searches starting from the tree root to find the next node to visit, rather than storing all nodes to visit explicitly. Laine (#link("<cite:Laine2010>")[2010];) made a number of improvements to this approach, reducing the frequency of re-traversals from the tree root and applying the approach to BVHs. See also Binder and Keller (#link("<cite:Binder2016>")[2016];), who applied perfect hashing to finding subsequent nodes to visit with the stackless approach.
][
  `pbrt` 中使用的 BVH 遍历算法是由多位研究人员同时开发的；有关更多详细信息和背景，请参阅 Boulos 和 Haines（#link("<cite:Boulos2006>")[2006];）的注释。 Kay 和 Kajiya（#link("<cite:Kay86>")[1986];）的另一种树遍历选项是维护一个按光线距离排序的节点堆。 在 GPU 上，由于片上内存相对较少，为每条光线维护一个待访问节点的堆栈可能会导致内存成本过高。 Foley 和 Sugerman（#link("<cite:Foley2005>")[2005];）引入了一种“无堆栈” kd-tree 遍历算法，该算法定期回溯并从树根开始搜索以找到下一个要访问的节点，而不是显式存储所有要访问的节点。 Laine（#link("<cite:Laine2010>")[2010];）对这种方法进行了多项改进，减少了从树根重新遍历的频率，并将该方法应用于 BVH。 另请参阅 Binder 和 Keller（#link("<cite:Binder2016>")[2016];），他们将完美哈希应用于使用无堆栈方法找到后续要访问的节点。
]

#parec[
  An innovative approach to BVH traversal is described by Hendrich et al.~(#link("<cite:Hendrich2019>")[2019];), who created a spatio-directional 5D data structure that records a set of BVH nodes that are used to seed the traversal stack for sets of rays. Given a particular ray, traversal starts immediately with an appropriate stack, which in turn improves performance by entirely skipping processing of BVH nodes that are either certain to be intersected or certain not to be intersected for rays in a particular set.
][
  Hendrich 等人（#link("<cite:Hendrich2019>")[2019];）描述了一种创新的 BVH 遍历方法，他们创建了一个空间方向 5D 数据结构，该结构记录了一组 BVH 节点，用于为一组光线的遍历堆栈提供种子。 给定一条特定的光线，遍历立即从一个适当的堆栈开始，从而通过完全跳过对特定光线集合中一定会相交或一定不会相交的 BVH 节点的处理来提高性能。
]

#parec[
  A number of researchers have developed techniques for improving the quality of BVHs after construction. Yoon et al.~(#link("<cite:Yoon2007>")[2007];) and Kensler (#link("<cite:Kensler08>")[2008];) presented algorithms that make local adjustments to the BVH. See also Bittner et al.~(#link("<cite:Bittner2013>")[2013];, #link("<cite:Bittner2014>")[2014];), Karras and Aila (#link("<cite:Karras2013>")[2013];), and Meister and Bittner (#link("<cite:Meister2018a>")[2018a];) for further work in this area. An interesting approach was described by Gu et al.~(#link("<cite:Gu2015>")[2015];), who constructed a BVH, traced a relatively small number of representative rays, and gathered statistics about how frequently each bounding box was intersected, and then tuned the BVH to be more efficient for rays with similar statistics.
][
  许多研究人员开发了在构建后提高 BVH 质量的技术。 Yoon 等人（#link("<cite:Yoon2007>")[2007];）和 Kensler（#link("<cite:Kensler08>")[2008];）提出了对 BVH 进行局部调整的算法。 另请参阅 Bittner 等人（#link("<cite:Bittner2013>")[2013];, #link("<cite:Bittner2014>")[2014];）、Karras 和 Aila（#link("<cite:Karras2013>")[2013];）以及 Meister 和 Bittner（#link("<cite:Meister2018a>")[2018a];）在该领域的进一步工作。 Gu 等人（#link("<cite:Gu2015>")[2015];）描述了一种有趣的方法，他们构建了一个 BVH，追踪了相对较少的代表性光线，并收集了有关每个包围盒被相交频率的统计数据，然后调整 BVH 以提高对具有类似统计数据的光线的效率。
]

#parec[
  Most current methods for building BVHs are based on top-down construction of the tree, first creating the root node and then partitioning the primitives into children and continuing recursively. An alternative approach was demonstrated by Walter et al.~(#link("<cite:Walter08>")[2008];), who showed that bottom-up construction, where the leaves are created first and then agglomerated into parent nodes, is a viable option. Gu et al.~(#link("<cite:Gu2013b>")[2013b];) developed a much more efficient implementation of this approach and showed its suitability for parallel implementation, and Meister and Bittner (#link("<cite:Meister2018b>")[2018b];) described a bottom-up approach that is suitable for GPU implementation.
][
  大多数当前构建 BVH 的方法基于树的自顶向下构建，首先创建根节点，然后将基本体划分为子节点并递归继续。 Walter 等人（#link("<cite:Walter08>")[2008];）展示了一种替代方法，即自底向上构建，其中首先创建叶子节点，然后将其聚合到父节点中，是一种可行的选择。 Gu 等人（#link("<cite:Gu2013b>")[2013b];）开发了这种方法的更高效实现，并展示了其适合并行实现，Meister 和 Bittner（#link("<cite:Meister2018b>")[2018b];）描述了一种适合 GPU 实现的自底向上方法。
]

#parec[
  One shortcoming of BVHs is that even a small number of relatively large primitives that have overlapping bounding boxes can substantially reduce the efficiency of the BVH: many of the nodes of the tree will be overlapping, solely due to the overlapping bounding boxes of geometry down at the leaves. Ernst and Greiner (#link("<cite:Ernst2007>")[2007];) proposed "split clipping" as a solution; the restriction that each primitive only appears once in the tree is lifted, and the bounding boxes of large input primitives are subdivided into a set of tighter subbounds that are then used for tree construction.
][
  BVH 的一个缺点是，即使是少量相对较大的基本体具有重叠的包围盒，也会显著降低 BVH 的效率：许多树节点将会重叠，仅仅是因为叶子节点几何体的包围盒重叠。 Ernst 和 Greiner（#link("<cite:Ernst2007>")[2007];）提出了“分割剪裁”作为解决方案；取消了每个基本体在树中只出现一次的限制，并将大的输入基本体的包围盒细分为一组更紧的子界限，然后用于树的构建。
]

#parec[
  Dammertz and Keller (#link("<cite:Dammertz2008a>")[2008a];) observed that the problematic primitives are the ones with a large amount of empty space in their bounding box relative to their surface area, so they subdivided the most egregious triangles and reported substantial performance improvements. Stich et al.~(#link("<cite:Stich2009>")[2009];) developed an approach that splits primitives during BVH construction, making it possible to only split primitives when an SAH cost reduction was found. See also Popov et al.'s paper (#link("<cite:Popov2009>")[2009];) on a theoretically optimal BVH partitioning algorithm and its relationship to previous approaches, and Karras and Aila (#link("<cite:Karras2013>")[2013];) for improved criteria for deciding when to split triangles. Woop et al.~(#link("<cite:Woop2014>")[2014];) developed an approach to building BVHs for long, thin geometry like hair and fur; because this sort of geometry is quite thin with respect to the volume of its bounding boxes, it normally has poor performance with most acceleration structures. Ganestam and Doggett (#link("<cite:Ganestam2016>")[2016];) have proposed a splitting approach that has benefits to both BVH construction and traversal efficiency.
][
  Dammertz 和 Keller（#link("<cite:Dammertz2008a>")[2008a];）观察到问题出在那些相对于其表面积在包围盒中有大量空白空间的基本体，因此他们细分了最严重的三角形，并报告了显著的性能提升。 Stich 等人（#link("<cite:Stich2009>")[2009];）开发了一种在 BVH 构建过程中分割基本体的方法，使得仅在发现 SAH 成本减少时才分割基本体成为可能。 另请参阅 Popov 等人（#link("<cite:Popov2009>")[2009];）关于理论上最优 BVH 分区算法及其与先前方法关系的论文，以及 Karras 和 Aila（#link("<cite:Karras2013>")[2013];）关于改进三角形分割决策标准的研究。 Woop 等人（#link("<cite:Woop2014>")[2014];）开发了一种为长而细的几何体（如头发和毛皮）构建 BVH 的方法；由于这种几何体相对于其包围盒的体积非常细，因此在大多数加速结构中通常表现不佳。 Ganestam 和 Doggett（#link("<cite:Ganestam2016>")[2016];）提出了一种分割方法，对 BVH 的构建和遍历效率都有好处。
]

#parec[
  The memory requirements for BVHs can be significant. In our implementation, each node is 32 bytes. With up to 2 BVH nodes needed per primitive in the scene, the total overhead may be as high as 64 bytes per primitive. Cline et al.~(#link("<cite:Cline2006>")[2006];) suggested a more compact representation for BVH nodes, at some expense of efficiency. First, they quantized the bounding box stored in each node using 8 or 16 bytes to encode its position with respect to the node's parent's bounding box. Second, they used implicit indexing, where the node i's children are at positions 2i and 2i + 1 in the node array (assuming a 2 times branching factor). They showed substantial memory savings, with moderate performance impact. Bauszat et al.~(#link("<cite:Bauszat2010>")[2010];) developed another space-efficient BVH representation. See also Segovia and Ernst (#link("<cite:Segovia2010>")[2010];), who developed compact representations of both BVH nodes and triangle meshes. A BVH specialized for space-efficient storage of parametric surfaces was described by Selgrad et al.~(#link("<cite:Selgrad2017>")[2017];) and an adoption of this approach for displaced subdivision surfaces was presented by Lier et al.~(#link("<cite:Lier2018>")[2018a];).
][
  BVH 的内存需求可能很大。 在我们的实现中，每个节点占用 32 字节。 由于场景中每个基本体最多需要 2 个 BVH 节点，总开销可能高达每个基本体 64 字节。 Cline 等人（#link("<cite:Cline2006>")[2006];）提出了一种更紧凑的 BVH 节点表示，尽管效率有所降低。 首先，他们对每个节点中的包围盒进行量化，使用 8 或 16 字节编码其相对于节点父包围盒的位置。 其次，他们使用#emph[隐式索引];，其中节点 i 的子节点位于节点数组中的位置 2i 和 2i + 1（假设分支因子为 2）。 他们展示了显著的内存节省，同时性能影响适中。 Bauszat 等人（#link("<cite:Bauszat2010>")[2010];）开发了另一种空间高效的 BVH 表示。 另请参阅 Segovia 和 Ernst（#link("<cite:Segovia2010>")[2010];），他们开发了 BVH 节点和三角网格的紧凑表示。 Selgrad 等人（#link("<cite:Selgrad2017>")[2017];）描述了一种专门用于参数曲面空间高效存储的 BVH，Lier 等人（#link("<cite:Lier2018>")[2018a];）提出了这种方法在位移细分曲面上的应用。
]

#parec[
  Other work in the area of space-efficient BVHs includes that of Vaidyanathan et al.~(#link("<cite:Vaidyanathan2016>")[2016];), who introduced a reduced-precision representation of the BVH that still guarantees conservative intersection tests with respect to the original BVH. Liktor and Vaidyanathan (#link("<cite:Liktor2016>")[2016];) introduced a BVH node representation based on clustering nodes that improves cache performance and reduces storage requirements for child node pointers. Ylitie et al.~(#link("<cite:Ylitie2017>")[2017];) showed how to optimally convert binary BVHs into wider BVHs with more children at each node, from which they derived a compressed BVH representation that shows a substantial bandwidth reduction with incoherent rays. Vaidyanathan et al.~(#link("<cite:Vaidyanathan2019>")[2019];) developed an algorithm for efficiently traversing such wide BVHs using a small stack. Benthin et al.~(#link("<cite:Benthin2018>")[2018];) focused on compressing sets of adjacent leaf nodes of BVHs under the principle that most of the memory is used at the leaves, and Lin et al.~(#link("<cite:Lin2019>")[2019];) described an approach that saves both computation and storage by taking advantage of shared planes among the bounds of the children of a BVH node.
][
  在空间高效 BVH 领域的其他工作包括 Vaidyanathan 等人（#link("<cite:Vaidyanathan2016>")[2016];），他们引入了一种降低精度的 BVH 表示，仍然保证相对于原始 BVH 的保守相交测试。 Liktor 和 Vaidyanathan（#link("<cite:Liktor2016>")[2016];）引入了一种基于节点聚类的 BVH 节点表示，改善了缓存性能并减少了子节点指针的存储需求。 Ylitie 等人（#link("<cite:Ylitie2017>")[2017];）展示了如何将二进制 BVH 最优地转换为具有更多子节点的更宽 BVH，从中他们推导出一种压缩 BVH 表示，在不连贯光线条件下显示出显著的带宽减少。 Vaidyanathan 等人（#link("<cite:Vaidyanathan2019>")[2019];）开发了一种算法，用于高效遍历这种宽 BVH，使用一个小堆栈。 Benthin 等人（#link("<cite:Benthin2018>")[2018];）专注于压缩 BVH 的相邻叶节点集，基于大部分内存用于叶节点的原则，Lin 等人（#link("<cite:Lin2019>")[2019];）描述了一种通过利用 BVH 节点子节点之间共享平面的优势来节省计算和存储的方法。
]

#parec[
  Yoon and Manocha (#link("<cite:Yoon06b>")[2006];) described algorithms for cache-efficient layout of BVHs and kd-trees and demonstrated performance improvements from using them. See also Ericson's book (#link("<cite:Ericson04>")[2004];) for extensive discussion of this topic.
][
  Yoon 和 Manocha（#link("<cite:Yoon06b>")[2006];）描述了 BVH 和 kd-tree 的缓存高效布局算法，并展示了使用这些算法的性能改进。 另请参阅 Ericson 的书（#link("<cite:Ericson04>")[2004];），其中对该主题进行了广泛讨论。
]

#parec[
  The linear BVH was introduced by Lauterbach et al.~(#link("<cite:Lauterbach09>")[2009];); Morton codes were first described in a report by Morton (#link("<cite:Morton1966>")[1966];). Pantaleoni and Luebke (#link("<cite:Pantaleoni2010a>")[2010];) developed the HLBVH generalization, using the SAH at the upper levels of the tree. They also noted that the upper bits of the Morton-coded values can be used to efficiently find clusters of primitives—both of these ideas are used in our HLBVH implementation. Garanzha et al.~(#link("<cite:Garanzha2011>")[2011];) introduced further improvements to the HLBVH, most of them targeting GPU implementations. Vinkler et al.~(#link("<cite:Vinkler2017>")[2017];) described improved techniques for mapping values to the Morton index coordinates that lead to higher-quality BVHs, especially for scenes with a range of primitive sizes.
][
  线性 BVH 是由 Lauterbach 等人（#link("<cite:Lauterbach09>")[2009];）引入的；Morton 码首次在 Morton 的一份报告中描述（#link("<cite:Morton1966>")[1966];）。 Pantaleoni 和 Luebke（#link("<cite:Pantaleoni2010a>")[2010];）开发了 HLBVH 泛化，在树的上层使用 SAH。 他们还指出，Morton 编码值的高位可以用于高效地找到基本体的聚类——这两个想法都在我们的 HLBVH 实现中使用。 Garanzha 等人（#link("<cite:Garanzha2011>")[2011];）引入了对 HLBVH 的进一步改进，其中大多数针对 GPU 实现。 Vinkler 等人（#link("<cite:Vinkler2017>")[2017];）描述了将值映射到 Morton 索引坐标的改进技术，这些技术导致了更高质量的 BVH，特别是对于具有不同基本体尺寸的场景。
]

#parec[
  Wald (#link("<cite:Wald2012>")[2012];) described an approach for high-performance parallel BVH construction on CPUs that uses the SAH throughout. More recently, Benthin et al.~(#link("<cite:Benthin2017>")[2017];) have described a two-level BVH construction technique based on building high-quality second-level BVHs for collections of objects in a scene, collecting them into a single BVH, and then iteratively refining the overall tree, including moving subtrees from one of the initial BVHs to another. Hendrich et al.~(#link("<cite:Hendrich2017>")[2017];) described a related technique, quickly building an initial LBVH and then progressively building a higher-quality BVH based on it.
][
  Wald（#link("<cite:Wald2012>")[2012];）描述了一种在 CPU 上进行高性能并行 BVH 构建的方法，该方法在整个过程中使用 SAH。 最近，Benthin 等人（#link("<cite:Benthin2017>")[2017];）描述了一种基于为场景中的对象集合构建高质量二级 BVH 的两级 BVH 构建技术，将它们收集到一个 BVH 中，然后迭代地优化整个树，包括将子树从一个初始 BVH 移动到另一个。 Hendrich 等人（#link("<cite:Hendrich2017>")[2017];）描述了一种相关技术，快速构建初始 LBVH，然后基于它逐步构建更高质量的 BVH。
]

#parec[
  A comprehensive survey of work in bounding volume hierarchies, spanning construction, representation, traversal, and hardware acceleration, was recently published by Meister et al.~(#link("<cite:Meister2021>")[2021];).
][
  Meister 等人（#link("<cite:Meister2021>")[2021];）最近发表了一篇关于包围体层次结构的全面调查，涵盖了构建、表示、遍历和硬件加速等方面的工作。
]

=== kd-trees

#parec[
  Glassner (1984) introduced the use of octrees for ray intersection acceleration. Use of the kd-tree for ray tracing was first described by Kaplan (1985). Kaplan's tree construction algorithm always split nodes down their middle; MacDonald and Booth (1990) introduced the SAH approach, estimating ray–node traversal probabilities using relative surface areas. Naylor (1993) has also written on general issues of constructing good kd-trees. Havran and Bittner (2002) revisited many of these issues and introduced useful improvements. Adding a bonus factor to the SAH for tree nodes that are completely empty was suggested by Hurley et al.~(2002). See Havran's Ph.D.~thesis (2000) for an excellent overview of high-performance kd-construction and traversal algorithms.
][
  Glassner（1984）引入了使用八叉树来加速光线相交。Kaplan（1985）首次描述了在光线追踪中使用kd树。Kaplan的树构建算法总是从中间分割节点；MacDonald和Booth（1990）引入了表面积启发式（SAH）方法，利用相对表面积估计光线-节点遍历概率。 Naylor（1993）也撰写了关于构建优良kd树的一般问题。Havran和Bittner（2002）重新审视了许多这些问题并引入了有用的改进。Hurley等人（2002）建议为完全空的树节点在SAH中添加一个奖励因子。有关高性能kd构建和遍历算法的优秀概述，请参见Havran的博士论文（2000）。
]

#parec[
  Jansen (1986) first developed the efficient ray-traversal algorithm for kd-trees. Arvo (1988) also investigated this problem and discussed it in a note in Ray Tracing News. Sung and Shirley (1992) described a ray-traversal algorithm's implementation for a BSP-tree accelerator; our KdTreeAggregate traversal code (included in the online edition) is loosely based on theirs.
][
  Jansen（1986）首次开发了kd树的高效光线遍历算法。Arvo（1988）也研究了这个问题，并在《光线追踪新闻》中进行了讨论。Sung和Shirley（1992）描述了一种用于BSP树加速器的光线遍历算法的实现；我们的`KdTreeAggregate`遍历代码（包含在在线版本中）大致基于他们的实现。
]

#parec[
  The asymptotic complexity of the kd-tree construction algorithm in pbrt is O(n log^2 n). Wald and Havran (2006) showed that it is possible to build kd-trees in O(n log n) time with some additional implementation complexity; they reported a 2 to 3 times speedup in construction time for typical scenes.
][
  `pbrt`中kd树构建算法的渐近复杂度是 $O (n log^2 n)$。Wald和Havran（2006）展示了在增加一些实现上的复杂度的情况下，可以在 $O (n log n)$ 时间内构建kd树；他们报告说对于典型场景，构建时间加速了2到3倍。
]

#parec[
  The best kd-trees for ray tracing are built using "perfect splits," where the primitive being inserted into the tree is clipped to the bounds of the current node at each step. This eliminates the issue that, for example, an object's bounding box may intersect a node's bounding box and thus be stored in it, even though the object itself does not intersect the node's bounding box. This approach was introduced by Havran and Bittner (2002) and discussed further by Hurley et al.~(2002), Wald and Havran (2006), and Soupikov et al.~(2008). Even with perfect splits, large primitives may still be stored in many kd-tree leaves; Choi et al.~(2013) suggested storing some primitives in interior nodes to address this issue.
][
  用于光线追踪的最佳kd树是使用“完美分割”构建的，其中插入树中的原始体在每一步都被裁剪到当前节点的边界。这消除了例如一个对象的边界框可能与节点的边界框相交并因此被存储在其中的问题，即使对象本身并不与节点的边界框相交。 这种方法由Havran和Bittner（2002）引入，并由Hurley等人（2002）、Wald和Havran（2006）以及Soupikov等人（2008）进一步讨论。即便使用完美分割，大型原始体仍可能存储在多个kd树叶子中；Choi等人（2013）建议将一些原始体存储在内部节点中以解决此问题。
]

#parec[
  kd-tree construction tends to be much slower than BVH construction (especially if "perfect splits" are used), so parallel construction algorithms are of particular interest. Work in this area includes that of Shevtsov et al.~(2007b) and Choi et al.~(2010), who presented efficient parallel kd-tree construction algorithms with good scalability to multiple processors.
][
  kd树构建往往比BVH构建慢得多（尤其是使用“完美分割”时），因此并行构建算法特别受关注。该领域的工作包括Shevtsov等人（2007b）和Choi等人（2010），他们提出了具有良好多处理器可扩展性的高效并行kd树构建算法。
]

=== The Surface Area Heuristic

#parec[
  A number of researchers have investigated improvements to the SAH since its introduction to ray tracing by MacDonald and Booth (1990). Fabianowski et al.~(2009) derived a version that replaces the assumption that rays are uniformly distributed throughout space with the assumption that ray origins are uniformly distributed inside the scene's bounding box. Hunt and Mark (2008b) introduced a modified SAH that accounts for the fact that rays generally are not uniformly distributed but rather that many of them originate from a single point or a set of nearby points (cameras and light sources, respectively). Hunt (2008) showed how the SAH should be modified when the "mailboxing" optimization is being used, and Vinkler et al.~(2012) used assumptions about the visibility of primitives to adjust their SAH cost. Ize and Hansen (2011) derived a "ray termination surface area heuristic" (RTSAH), which they used to adjust BVH traversal order for shadow rays in order to more quickly find intersections with occluders. See also Moulin et al.~(2015), who adapted the SAH to account for shadow rays being occluded during kd-tree traversal.
][
  自从MacDonald和Booth（1990）将表面积启发式引入光线追踪以来，许多研究人员研究了对其的改进。Fabianowski等人（2009）推导出一个版本，将光线在空间中均匀分布的假设替换为光线起点在场景的边界框内均匀分布的假设。 Hunt和Mark（2008b）引入了一个修改的表面积启发式，考虑到光线通常并不是均匀分布的，而是许多光线起源于一个点或一组附近的点（分别是相机和光源）。Hunt（2008）展示了在使用“邮箱”优化时如何修改表面积启发式，Vinkler等人（2012）利用对原始体可见性的假设来调整其表面积启发式成本。 Ize和Hansen（2011）推导出一种“光线终止表面积启发式”（RTSAH），他们用它来调整BVH遍历顺序以更快地找到遮挡物的相交。另请参见Moulin等人（2015），他们调整了表面积启发式以考虑在kd树遍历过程中被遮挡的阴影光线。
]

#parec[
  While the SAH has led to very effective kd-trees and BVHs, a number of researchers have noted that it is not unusual to encounter cases where a kd-tree or BVH with a higher SAH-estimated cost gives better performance than one with lower estimated cost. Aila et al.~(2013) surveyed some of these results and proposed two additional heuristics that help address them; one accounts for the fact that most rays start on surfaces—ray origins are not actually randomly distributed throughout the scene—and another accounts for SIMD divergence when multiple rays traverse the hierarchy together. While these new heuristics are effective at explaining why a given tree delivers the performance that it does, it is not yet clear how to incorporate them into tree construction algorithms.
][
  虽然表面积启发式导致了非常有效的kd树和BVH，但许多研究人员注意到，遇到表面积启发式估计成本较高的kd树或BVH性能优于估计成本较低的情况并不罕见。 Aila等人（2013）调查了一些这些结果并提出了两个额外的启发式来帮助解决这些问题；一个考虑到大多数光线从表面开始——光线起点实际上并不是在整个场景中随机分布的——另一个考虑到当多条光线一起遍历层次结构时的SIMD分歧。 虽然这些新启发式在解释给定树的性能方面非常有效，但尚不清楚如何将它们整合到树构建算法中。
]

#parec[
  Evaluating the SAH can be costly, particularly when many different splits or primitive partitions are being considered. One solution to this problem is to only compute it at a subset of the candidate points—for example, along the lines of the bucketing approach used in the BVHAggregate in pbrt. Hurley et al.~(2002) suggested this approach for building kd-trees, and Popov et al.~(2006) discussed it in detail. Shevtsov et al.~(2007b) introduced the improvement of binning the full extents of triangles, not just their centroids.
][
  评估表面积启发式可能代价高昂，尤其是在考虑多种不同分割或原始体分区时。解决此问题的一个方法是仅在候选点的一个子集上计算它——例如，沿着`pbrt`中`BVHAggregate`使用的分桶方法。 Hurley等人（2002）建议这种方法用于构建kd树，Popov等人（2006）详细讨论了这一点。Shevtsov等人（2007b）引入了对三角形的完整范围进行分箱的改进，而不仅仅是它们的质心。
]

#parec[
  Wodniok and Goesele constructed BVHs where the SAH cost estimate is not based on primitive counts and primitive bounds but is instead found by actually building BVHs for various partitions and computing their SAH cost (Wodniok and Goesele 2016). They showed a meaningful improvement in ray intersection performance, though at a cost of impractically long BVH construction times.
][
  Wodniok和Goesele构建了BVH，其中表面积启发式成本估计不是基于原始体计数和原始体边界，而是通过实际构建各种分区的BVH并计算其表面积启发式成本来找到的（Wodniok和Goesele 2016）。他们展示了光线相交性能的显著改进，尽管代价是BVH构建时间过长而不切实际。
]

#parec[
  Hunt et al.~(2006) noted that if you only have to evaluate the SAH at one point, for example, you do not need to sort the primitives but only need to do a linear scan over them to compute primitive counts and bounding boxes at the point. pbrt's implementation follows that approach. They also showed that approximating the SAH with a piecewise quadratic based on evaluating it at a number of individual positions, and using that to choose a good split, leads to effective trees. A similar approximation was used by Popov et al.~(2006).
][
  Hunt等人（2006）指出，如果只需在一个点上评估表面积启发式，例如，您不需要对原始体进行排序，只需对它们进行线性扫描以计算该点的原始体计数和边界框。`pbrt`的实现遵循了这种方法。 他们还展示了通过在多个单独位置评估表面积启发式并使用分段二次近似来选择一个好的分割，能够生成高效的树。Popov等人（2006）使用了类似的近似方法。
]

=== Other Topics in Acceleration Structures

#parec[
  Weghorst, Hooper, and Greenberg (1984) discussed the trade-offs of using various shapes for bounding volumes and suggested projecting objects to the screen and using a $z$ -buffer rendering to accelerate finding intersections for camera rays.
][
  Weghorst、Hooper 和 Greenberg（1984）讨论了使用各种形状作为包围体的权衡，并建议将对象投影到屏幕上并使用 z 缓冲区渲染来加速相机光线的交点查找。
]

#parec[
  A number of researchers have investigated the applicability of general BSP trees, where the splitting planes are not necessarily axis aligned, as they are with kd-trees. Kammaje and Mora (2007) built BSP trees using a preselected set of candidate splitting planes. Budge et al.~(2008) developed a number of improvements to their approach, though their results only approached kd-tree performance in practice due to a slower construction stage and slower traversal than kd-trees. Ize et al.~(2008) showed a BSP implementation that renders scenes faster than kd-trees but at the cost of extremely long construction times.
][
  许多研究人员研究了通用 BSP 树（分割平面树）的适用性，其中分割平面不一定是轴对齐的，就像 kd 树一样。Kammaje 和 Mora（2007）使用预选的候选分割平面集构建了 BSP 树。 Budge 等人（2008）对他们的方法进行了多项改进，尽管由于构建阶段较慢和遍历速度较慢，他们的结果在实践中仅接近 kd 树的性能。 Ize 等人（2008）展示了一种 BSP 实现，其渲染场景的速度比 kd 树快，但代价是极长的构建时间。
]

#parec[
  There are many techniques for traversing a collection of rays through the acceleration structure together, rather than just one at a time. This approach ("packet tracing") is an important component of many high-performance ray tracing approaches; it is discussed in more detail in Section 16.2.3.
][
  有许多技术可以同时遍历加速结构中的光线集合，而不是逐个遍历。这种方法（"包光线追踪"）是许多高性能光线追踪方法的重要组成部分；在第 16.2.3 节中对此进行了更详细的讨论。
]

#parec[
  Animated primitives present two challenges to ray tracers: first, renderers that try to reuse acceleration structures over multiple frames of an animation must update the acceleration structures if objects are moving. Lauterbach et al.~(2006) and Wald et al.~(2007a) showed how to incrementally update BVHs in this case, and Kopta et al.~(2012) reused BVHs over multiple frames of an animation, maintaining their quality by updating the parts that bound moving objects. Garanzha (2009) suggested creating clusters of nearby primitives and then building BVHs of those clusters (thus lightening the load on the BVH construction algorithm).
][
  动画原语对光线追踪器提出了两个挑战：首先，尝试在动画的多个帧中重用加速结构的渲染器必须在对象移动时更新加速结构。 Lauterbach 等人（2006）和 Wald 等人（2007a）展示了如何在这种情况下增量更新包围体层次结构 (BVH)，而 Kopta 等人（2012）在动画的多个帧中重用了 BVH，通过更新绑定移动对象的部分来保持其质量。 Garanzha（2009）建议创建附近原语的集群，然后构建这些集群的 BVH（从而减轻 BVH 构建算法的负担）。
]

#parec[
  A second challenge from animated primitives is that for primitives that are moving quickly, the bounding boxes of their full motion over the frame time may be quite large, leading to many unnecessary ray–primitive intersection tests. Notable work on this issue includes Glassner (1988), who generalized ray tracing (and an octree for acceleration) to four dimensions, adding time. More recently, Grünschloß et al.~(2011) developed improvements to BVHs for moving primitives. See also Wald et al.'s (2007b) survey paper on ray tracing animated scenes. Woop et al.~(2017) described a generalization of BVHs that also allows nodes to split in time, with child nodes of such a split accounting for different time ranges.
][
  动画原语带来的第二个挑战是，对于快速移动的原语，其在帧时间内的完整运动的边界框可能相当大，导致许多不必要的光线-原语交点测试。 关于这个问题的显著工作包括 Glassner（1988），他将光线追踪（和用于加速的八叉树）推广到四维，增加了时间。 最近，Grünschloß 等人（2011）开发了针对移动原语的 BVH 改进。 另请参阅 Wald 等人（2007b）关于光线追踪动画场景的调查论文。Woop 等人（2017）描述了一种 BVH 的推广，它还允许节点在时间上分裂，这种分裂的子节点考虑了不同的时间范围。
]

#parec[
  An innovative approach to acceleration structures was suggested by Arvo and Kirk (1987), who introduced a 5D data structure that subdivided based on both 3D spatial and 2D ray directions. Another interesting approach for scenes described with triangle meshes was developed by Lagae and Dutrè (2008b): they computed a constrained tetrahedralization, where all triangle faces of the model are represented in the tetrahedralization. Rays are then stepped through tetrahedra until they intersect a triangle from the scene description. This approach is still a few times slower than the state of the art in kd-trees and BVHs but is an interesting new way to think about the problem.
][
  Arvo 和 Kirk（1987）提出了一种创新的加速结构方法，他们引入了一种 5D 数据结构，该结构基于 3D 空间和 2D 光线方向进行细分。 Lagae 和 Dutrè（2008b）为用三角网格描述的场景开发了另一种有趣的方法：他们计算了一个受约束的四面体化，其中模型的所有三角面都在四面体化中表示。 然后光线穿过四面体，直到它们与场景描述中的三角形相交。这种方法仍比 kd 树和 BVH 的最新技术慢几倍，但它提供了一种思考问题的新颖有趣的方式。
]

#parec[
  There is a middle ground between kd-trees and BVHs, where the tree node holds a splitting plane for each child rather than just a single splitting plane. This refinement makes it possible to do object subdivision in a kd-tree-like acceleration structure, putting each primitive in just one subtree and allowing the subtrees to overlap, while still preserving many of the benefits of efficient kd-tree traversal. Ooi et al.~(1987) first introduced this refinement to kd-trees for storing spatial data, naming it the "spatial kd-tree" (skd-tree). Skd-trees have been applied to ray tracing by a number of researchers, including Zachmann (2002), Woop et al.~(2006), Wächter and Keller (2006), Havran et al.~(2006), and Zuniga and Uhlmann (2006).
][
  在 kd 树和 BVH 之间存在一个中间地带，其中树节点为每个子节点保存一个分割平面，而不仅仅是一个分割平面。 这种细化使得在类似 kd 树的加速结构中进行对象细分成为可能，将每个原语放在一个子树中，并允许子树重叠，同时仍然保留高效 kd 树遍历的许多优点。 Ooi 等人（1987）首次将这种细化引入 kd 树以存储空间数据，称其为“空间 kd 树”（skd 树）。 包括 Zachmann（2002）、Woop 等人（2006）、Wächter 和 Keller（2006）、Havran 等人（2006）以及 Zuniga 和 Uhlmann（2006）在内的许多研究人员将 skd 树应用于光线追踪。
]

#parec[
  When spatial subdivision approaches like grids or kd-trees are used, primitives may overlap multiple nodes of the structure and a ray may be tested for intersection with the same primitive multiple times as it passes through the structure. Arnaldi, Priol, and Bouatouch (1987) and Amanatides and Woo (1987) developed the "mailboxing" technique to address this issue: each ray is given a unique integer identifier, and each primitive records the id of the last ray that was tested against it. If the ids match, then the intersection test is unnecessary and can be skipped.
][
  当使用网格或 kd 树等空间细分方法时，原语可能会重叠结构的多个节点，并且光线在穿过结构时可能会多次测试与同一原语的交点。 Arnaldi、Priol 和 Bouatouch（1987）以及 Amanatides 和 Woo（1987）开发了“信箱技术”来解决此问题：每条光线都被赋予一个唯一的整数标识符，每个原语记录最后一次测试其的光线的 id。 如果 id 匹配，则不需要进行交点测试，可以跳过。
]

#parec[
  While effective, mailboxing does not work well with a multi-threaded ray tracer. To address this issue, Benthin (2006) suggested storing a small per-ray hash table to record ids of recently intersected primitives. Shevtsov et al.~(2007a) maintained a small array of the last $n$ intersected primitive ids and searched it linearly before performing intersection tests. Although some primitives may still be checked multiple times with both of these approaches, they usually eliminate most redundant tests.
][
  尽管信箱技术有效，但在多线程光线追踪器中表现不佳。 为了解决这个问题，Benthin（2006）建议存储一个小的每光线哈希表来记录最近相交的原语的 id。 Shevtsov 等人（2007a）维护了一个小数组，记录了最后 $n$ 个相交的原语 id，并在执行交点测试之前线性搜索它。 尽管在这两种方法中一些原语可能仍会被多次检查，但它们通常会消除大多数冗余测试。
]


