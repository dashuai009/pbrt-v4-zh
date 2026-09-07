#import "../template.typ": parec, ez_caption, source-cite


#heading(level: 2, numbering: none)[#ez_caption[Further Reading][延伸阅读]]
<primitives-further-reading>

#parec[
  The stochastic alpha test implemented in Section #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#sec:gprim")[7.1.1] builds on ideas introduced in Enderton et al.'s stochastic approach for transparency (#source-cite("Enderton2010")) and Wyman and McGuire's hashed alpha testing algorithm (#source-cite("Wyman2017")), both of which were focused on rasterization-based rendering.
][
  @geometric-primitives 中的随机 alpha 测试借鉴了 Enderton 等人的随机透明度方法（#source-cite("Enderton2010")）和 Wyman、McGuire 的哈希 alpha 测试算法（#source-cite("Wyman2017")）；这两项工作都针对光栅化渲染。
]

#parec[
  After the introduction of the ray-tracing algorithm, an enormous amount of research was done to try to find effective ways to speed it up, primarily by developing improved ray-tracing acceleration structures. Arvo and Kirk's chapter in #emph[An Introduction to Ray Tracing] (Glassner #source-cite("Glassner:IntroRayTracing")) summarizes the state of the art as of 1989 and still provides an excellent taxonomy for categorizing different approaches to ray intersection acceleration.
][
  光线追踪算法提出后，研究者投入了大量工作来寻找有效的加速方法，主要方向是改进加速结构。Arvo 和 Kirk 在 #emph[An Introduction to Ray Tracing] (Glassner #source-cite("Glassner:IntroRayTracing")) 中的章节总结了截至 1989 年的技术进展，其对射线求交加速方法的分类至今仍很有价值。
]

#parec[
  Kirk and Arvo (#source-cite("Kirk88")) introduced the unifying principle of #emph[meta-hierarchies.] They showed that by implementing acceleration data structures to conform to the same interface as is used for primitives in the scene, it is easy to mix and match different intersection acceleration schemes. `pbrt` follows this model.
][
  Kirk 和 Arvo（#source-cite("Kirk88")）提出了#emph[元层次结构]这一统一原则：只要让加速结构实现与场景图元相同的接口，就能方便地组合不同的求交加速方案。`pbrt` 采用了这一模式。
]


#heading(level: 3, numbering: none)[#ez_caption[Grids][网格]]


#parec[
  Fujimoto, Tanaka, and Iwata (#source-cite("Fujimoto86")) introduced uniform grids, a spatial subdivision approach where the scene bounds are decomposed into equally sized grid cells. More efficient grid-traversal methods were described by Amanatides and Woo (#source-cite("Amanatides87")) and Cleary and Wyvill (#source-cite("Cleary:1988:AOA")). Snyder and Barr (#source-cite("Snyder87")) described a number of key improvements to this approach and showed the use of grids for rendering extremely complex scenes. Hierarchical grids, where grid cells with many primitives in them are themselves refined into grids, were introduced by Jevans and Wyvill (#source-cite("Jevans89")). More sophisticated techniques for hierarchical grids were developed by Cazals, Drettakis, and Puech (#source-cite("Cazals95")) and Klimaszewski and Sederberg (#source-cite("Klimaszewski97")).
][
  Fujimoto、Tanaka 和 Iwata（#source-cite("Fujimoto86")）提出均匀网格这一空间划分方法，将场景的包围范围划分为等大的网格单元。Amanatides 和 Woo（#source-cite("Amanatides87")）、Cleary 和 Wyvill（#source-cite("Cleary:1988:AOA")）介绍了更高效的网格遍历方法。Snyder 和 Barr（#source-cite("Snyder87")）给出多项关键改进，并展示了网格在极复杂场景中的应用。Jevans 和 Wyvill（#source-cite("Jevans89")）提出分层网格，将含大量图元的单元继续细化为子网格。Cazals、Drettakis 和 Puech（#source-cite("Cazals95")），以及 Klimaszewski 和 Sederberg（#source-cite("Klimaszewski97")）又发展了更复杂的分层网格技术。
]

#parec[
  Ize et al.~(#source-cite("Ize2006")) developed an efficient algorithm for parallel construction of grids. One of their interesting findings was that grid construction performance quickly became limited by memory bandwidth as the number of cores used increased.
][
  Ize 等人 (#source-cite("Ize2006")) 开发了一种用于并行构建网格的高效算法。 他们的一个有趣发现是，随着使用的核心数量增加，网格构建性能很快受限于内存带宽。
]

#parec[
  Choosing an optimal grid resolution is important for getting good performance from grids. A good paper on this topic is by Ize et al.~(#source-cite("Ize07")), who provided a solid foundation for automatically selecting the resolution and for deciding when to refine into subgrids when using hierarchical grids. They derived theoretical results using a number of simplifying assumptions and then showed the applicability of the results to rendering real-world scenes. Their paper also includes a good selection of pointers to previous work in this area.
][
  选择最佳的网格分辨率对于获得良好的性能至关重要。 Ize 等人 (#source-cite("Ize07")) 的一篇优秀论文为自动选择分辨率以及在使用分层网格时何时细化为子网格提供了坚实的基础。 他们在一些简化假设下推导出了理论结果，然后展示了这些结果在渲染现实世界场景中的适用性。 他们的论文还包括了该领域先前工作的良好指引。
]

#parec[
  Lagae and Dutré (#source-cite("Lagae08a")) described an innovative representation for uniform grids based on hashing that has the desirable properties that not only does each primitive have a single index into a grid cell, but also each cell has only a single primitive index. They showed that this representation has very low memory usage and is still quite efficient.
][
  Lagae 和 Dutré (#source-cite("Lagae08a")) 描述了一种基于哈希的创新均匀网格表示，该表示具有理想的特性，不仅每个图元都有一个网格单元的索引，而且每个单元只有一个图元索引。 他们展示了这种表示具有非常低的内存使用量且仍然相当高效。
]

#parec[
  Hunt and Mark (#source-cite("Hunt08a")) showed that building grids in perspective space, where the center of projection is the camera or a light source, can make tracing rays from the camera or light substantially more efficient. Although this approach requires multiple acceleration structures, the performance benefits from multiple specialized structures for different classes of rays can be substantial. Their approach is also notable in that it is in some ways a middle ground between rasterization and ray tracing.
][
  Hunt 和 Mark (#source-cite("Hunt08a")) 展示了在透视空间中构建网格（其中投影中心是相机或光源）可以使从相机或光源追踪光线的效率显著提高。 尽管这种方法需要多个加速结构，但针对不同类别光线的多个专用结构带来的性能收益可能是显著的。 他们的方法值得注意，因为在某些方面它介于光栅化和光线追踪之间。
]


#heading(level: 3, numbering: none)[#ez_caption[Bounding Volume Hierarchies][包围体层次结构]]


#parec[
  Clark (#source-cite("Clark76")) first suggested using bounding volumes to cull collections of objects for standard visible-surface determination algorithms. Building on this work, Rubin and Whitted (#source-cite("Rubin80")) developed the first hierarchical data structures for scene representation for fast ray tracing, although their method depended on the user to define the hierarchy. Kay and Kajiya (#source-cite("Kay86")) implemented one of the first practical object subdivision approaches based on bounding objects with collections of slabs.
][
  Clark（#source-cite("Clark76")）首先建议在传统可见表面判定算法中用包围体排除整组对象。Rubin 和 Whitted（#source-cite("Rubin80")）在此基础上，为快速光线追踪开发了第一个用于场景表示的层次数据结构，不过需由用户指定层次。Kay 和 Kajiya（#source-cite("Kay86")）则用一组夹层包围对象，实现了最早的一批实用对象划分方法之一。
]

#parec[
  Goldsmith and Salmon (#source-cite("Goldsmith87")) described the first algorithm for automatically computing bounding volume hierarchies. Although their algorithm was based on estimating the probability of a ray intersecting a bounding volume using the volume's surface area, it was much less effective than modern SAH BVH approaches. The first use of the SAH for BVH construction was described by Müller and Fellner (#source-cite("Muller1999")); another early application is due to Massó and López (#source-cite("Masso2003")).
][
  Goldsmith 和 Salmon（#source-cite("Goldsmith87")）描述了第一个自动计算包围体层次结构的算法。 尽管他们的算法基于利用包围体的表面积估计射线与它相交的概率，但其效果远不如现代的表面积启发式 BVH 方法。 Müller 和 Fellner（#source-cite("Muller1999")）首次介绍了将 SAH 用于 BVH 构建的方法；另一个早期应用是 Massó 和 López（#source-cite("Masso2003")）。
]

#parec[
  The BVHAggregate implementation in this chapter is based on the construction algorithm described by Wald (#source-cite("Wald07")) and Günther et al.~(#source-cite("Gunther2007")). The bounding box test is the one introduced by Williams et al.~(#source-cite("Williams05")). An even more efficient bounding box test that does additional precomputation in exchange for higher performance when the same ray is tested for intersection against many bounding boxes was developed by Eisemann et al.~(#source-cite("Eisemann2007")); we leave implementing their method for an exercise. Ize's robust ray–bounding box intersection algorithm ensures that the BVH is #emph[watertight] and that valid intersections are not missed due to numeric error (Ize #source-cite("Ize2013")).
][
  本章的 `BVHAggregate` 以 Wald（#source-cite("Wald07")）和 Günther 等人（#source-cite("Gunther2007")）的构建算法为基础。包围盒测试来自 Williams 等人（#source-cite("Williams05")）。Eisemann 等人（#source-cite("Eisemann2007")）用额外预计算换取同一射线测试许多包围盒时的更高效率，本章习题要求实现该方法。Ize（#source-cite("Ize2013")）的稳健射线—包围盒算法确保 BVH 求交#emph[水密（watertight）]，避免因数值误差漏掉有效交点。
]

#parec[
  The BVH traversal algorithm used in pbrt was concurrently developed by a number of researchers; see the notes by Boulos and Haines (#source-cite("Boulos2006")) for more details and background. Another option for tree traversal is that of Kay and Kajiya (#source-cite("Kay86")); they maintained a heap of nodes ordered by ray distance. On GPUs, which have relatively limited amounts of on-chip memory, maintaining a stack of to-be-visited nodes for each ray may have a prohibitive memory cost. Foley and Sugerman (#source-cite("Foley2005")) introduced a "stackless" kd-tree traversal algorithm that periodically backtracks and searches starting from the tree root to find the next node to visit, rather than storing all nodes to visit explicitly. Laine (#source-cite("Laine2010")) made a number of improvements to this approach, reducing the frequency of re-traversals from the tree root and applying the approach to BVHs. See also Binder and Keller (#source-cite("Binder2016")), who applied perfect hashing to finding subsequent nodes to visit with the stackless approach.
][
  `pbrt` 中使用的 BVH 遍历算法是由多位研究人员同时开发的；有关更多详细信息和背景，请参阅 Boulos 和 Haines（#source-cite("Boulos2006")）的说明文章。Kay 和 Kajiya（#source-cite("Kay86")）的另一种树遍历选项是维护一个按光线距离排序的节点堆。 在 GPU 上，由于片上内存相对较少，为每条光线维护一个待访问节点的堆栈可能会导致内存成本过高。 Foley 和 Sugerman（#source-cite("Foley2005")）引入了一种“无栈” kd 树 遍历算法，该算法定期回溯并从树根开始搜索以找到下一个要访问的节点，而不是显式存储所有要访问的节点。 Laine（#source-cite("Laine2010")）对这种方法进行了多项改进，减少了从树根重新遍历的频率，并将该方法应用于 BVH。 另请参阅 Binder 和 Keller（#source-cite("Binder2016")），他们将完美哈希应用于使用无栈方法找到后续要访问的节点。
]

#parec[
  An innovative approach to BVH traversal is described by Hendrich et al.~(#source-cite("Hendrich2019")), who created a spatio-directional 5D data structure that records a set of BVH nodes that are used to seed the traversal stack for sets of rays. Given a particular ray, traversal starts immediately with an appropriate stack, which in turn improves performance by entirely skipping processing of BVH nodes that are either certain to be intersected or certain not to be intersected for rays in a particular set.
][
  Hendrich 等人（#source-cite("Hendrich2019")）提出了另一种 BVH 遍历方法：用结合空间位置与方向的五维数据结构，为各组射线记录用于初始化遍历栈的一组 BVH 节点。对具体射线，直接从相应的栈开始遍历，就能跳过对该射线组必定命中或必定不命中的节点处理，提高效率。
]

#parec[
  A number of researchers have developed techniques for improving the quality of BVHs after construction. Yoon et al.~(#source-cite("Yoon2007")) and Kensler (#source-cite("Kensler08")) presented algorithms that make local adjustments to the BVH. See also Bittner et al.~(#source-cite("Bittner2013"), #source-cite("Bittner2014")), Karras and Aila (#source-cite("Karras2013")), and Meister and Bittner (#source-cite("Meister2018a")) for further work in this area. An interesting approach was described by Gu et al.~(#source-cite("Gu2015")), who constructed a BVH, traced a relatively small number of representative rays, and gathered statistics about how frequently each bounding box was intersected, and then tuned the BVH to be more efficient for rays with similar statistics.
][
  许多研究人员开发了在构建后提高 BVH 质量的技术。 Yoon 等人（#source-cite("Yoon2007")）和 Kensler（#source-cite("Kensler08")）提出了对 BVH 进行局部调整的算法。 另请参阅 Bittner 等人（#source-cite("Bittner2013"), #source-cite("Bittner2014")）、Karras 和 Aila（#source-cite("Karras2013")）以及 Meister 和 Bittner（#source-cite("Meister2018a")）在该领域的进一步工作。 Gu 等人（#source-cite("Gu2015")）描述了一种有趣的方法，他们构建了一个 BVH，追踪了相对较少的代表性光线，并收集了有关每个包围盒被相交频率的统计数据，然后调整 BVH 以提高对具有类似统计数据的光线的效率。
]

#parec[
  Most current methods for building BVHs are based on top-down construction of the tree, first creating the root node and then partitioning the primitives into children and continuing recursively. An alternative approach was demonstrated by Walter et al.~(#source-cite("Walter08")), who showed that bottom-up construction, where the leaves are created first and then agglomerated into parent nodes, is a viable option. Gu et al.~(#source-cite("Gu2013b")) developed a much more efficient implementation of this approach and showed its suitability for parallel implementation, and Meister and Bittner (#source-cite("Meister2018b")) described a bottom-up approach that is suitable for GPU implementation.
][
  BVH 通常自顶向下构建：先创建根节点，再将图元分给子节点并递归。Walter 等人（#source-cite("Walter08")）展示了另一条可行路线——先创建叶节点，再自底向上聚合为父节点。Gu 等人（#source-cite("Gu2013b")）大幅提高了该方法的效率，并证明它适合并行实现；Meister 和 Bittner（#source-cite("Meister2018b")）则提出适合 GPU 的自底向上算法。
]

#parec[
  One shortcoming of BVHs is that even a small number of relatively large primitives that have overlapping bounding boxes can substantially reduce the efficiency of the BVH: many of the nodes of the tree will be overlapping, solely due to the overlapping bounding boxes of geometry down at the leaves. Ernst and Greiner (#source-cite("Ernst2007")) proposed "split clipping" as a solution; the restriction that each primitive only appears once in the tree is lifted, and the bounding boxes of large input primitives are subdivided into a set of tighter subbounds that are then used for tree construction.
][
  BVH 的一个缺点是，哪怕只有少量较大的图元，只要其包围盒互相重叠，就可能让上层许多节点也重叠，显著降低效率。Ernst 和 Greiner（#source-cite("Ernst2007")）提出“分割裁剪”（split clipping）：不再要求每个图元只在树中出现一次，而将大图元的包围盒细分为更紧的子包围范围，用于建树。
]

#parec[
  Dammertz and Keller (#source-cite("Dammertz2008a")) observed that the problematic primitives are the ones with a large amount of empty space in their bounding box relative to their surface area, so they subdivided the most egregious triangles and reported substantial performance improvements. Stich et al.~(#source-cite("Stich2009")) developed an approach that splits primitives during BVH construction, making it possible to only split primitives when an SAH cost reduction was found. See also Popov et al.'s paper (#source-cite("Popov2009")) on a theoretically optimal BVH partitioning algorithm and its relationship to previous approaches, and Karras and Aila (#source-cite("Karras2013")) for improved criteria for deciding when to split triangles. Woop et al.~(#source-cite("Woop2014")) developed an approach to building BVHs for long, thin geometry like hair and fur; because this sort of geometry is quite thin with respect to the volume of its bounding boxes, it normally has poor performance with most acceleration structures. Ganestam and Doggett (#source-cite("Ganestam2016")) have proposed a splitting approach that has benefits to both BVH construction and traversal efficiency.
][
  Dammertz 和 Keller（#source-cite("Dammertz2008a")）观察到问题出在那些相对于其表面积在包围盒中有大量空白空间的图元，因此他们细分了最严重的三角形，并报告了显著的性能提升。 Stich 等人（#source-cite("Stich2009")）开发了一种在 BVH 构建过程中分割图元的方法，使得仅在发现 SAH 成本减少时才分割图元成为可能。 另请参阅 Popov 等人（#source-cite("Popov2009")）关于理论上最优 BVH 分区算法及其与先前方法关系的论文，以及 Karras 和 Aila（#source-cite("Karras2013")）关于改进三角形分割决策标准的研究。 Woop 等人（#source-cite("Woop2014")）开发了一种为长而细的几何体（如头发和毛皮）构建 BVH 的方法；由于这种几何体相对于其包围盒的体积非常细，因此在大多数加速结构中通常表现不佳。 Ganestam 和 Doggett（#source-cite("Ganestam2016")）提出了一种分割方法，对 BVH 的构建和遍历效率都有好处。
]

#parec[
  The memory requirements for BVHs can be significant. In our implementation, each node is 32 bytes. With up to 2 BVH nodes needed per primitive in the scene, the total overhead may be as high as 64 bytes per primitive. Cline et al.~(#source-cite("Cline2006")) suggested a more compact representation for BVH nodes, at some expense of efficiency. First, they quantized the bounding box stored in each node using 8 or 16 bytes to encode its position with respect to the node's parent's bounding box. Second, they used implicit indexing, where the node $i$’s children are at positions $2 i$ and $2 i+1$ in the node array (assuming a $2 times$ branching factor). They showed substantial memory savings, with moderate performance impact. Bauszat et al.~(#source-cite("Bauszat2010")) developed another space-efficient BVH representation. See also Segovia and Ernst (#source-cite("Segovia2010")), who developed compact representations of both BVH nodes and triangle meshes. A BVH specialized for space-efficient storage of parametric surfaces was described by Selgrad et al.~(#source-cite("Selgrad2017")) and an adoption of this approach for displaced subdivision surfaces was presented by Lier et al.~(#source-cite("Lier2018")).
][
  BVH 的内存需求可能很大。 在我们的实现中，每个节点占用 32 字节。 由于场景中每个图元最多需要 2 个 BVH 节点，总开销可能高达每个图元 64 字节。 Cline 等人（#source-cite("Cline2006")）提出了一种更紧凑的 BVH 节点表示，尽管效率有所降低。 首先，他们对每个节点中的包围盒进行量化，使用 8 或 16 字节编码其相对于节点父包围盒的位置。 其次，他们使用#emph[隐式索引]，其中节点 $i$ 的子节点位于节点数组中的位置 $2 i$ 和 $2 i+1$（假设分支因子为 2）。 他们展示了显著的内存节省，同时性能影响适中。 Bauszat 等人（#source-cite("Bauszat2010")）开发了另一种空间高效的 BVH 表示。 另请参阅 Segovia 和 Ernst（#source-cite("Segovia2010")），他们开发了 BVH 节点和三角网格的紧凑表示。 Selgrad 等人（#source-cite("Selgrad2017")）描述了一种专门用于参数曲面空间高效存储的 BVH，Lier 等人（#source-cite("Lier2018")）提出了这种方法在位移细分曲面上的应用。
]

#parec[
  Other work in the area of space-efficient BVHs includes that of Vaidyanathan et al.~(#source-cite("Vaidyanathan2016")), who introduced a reduced-precision representation of the BVH that still guarantees conservative intersection tests with respect to the original BVH. Liktor and Vaidyanathan (#source-cite("Liktor2016")) introduced a BVH node representation based on clustering nodes that improves cache performance and reduces storage requirements for child node pointers. Ylitie et al.~(#source-cite("Ylitie2017")) showed how to optimally convert binary BVHs into wider BVHs with more children at each node, from which they derived a compressed BVH representation that shows a substantial bandwidth reduction with incoherent rays. Vaidyanathan et al.~(#source-cite("Vaidyanathan2019")) developed an algorithm for efficiently traversing such wide BVHs using a small stack. Benthin et al.~(#source-cite("Benthin2018")) focused on compressing sets of adjacent leaf nodes of BVHs under the principle that most of the memory is used at the leaves, and Lin et al.~(#source-cite("Lin2019")) described an approach that saves both computation and storage by taking advantage of shared planes among the bounds of the children of a BVH node.
][
  在空间高效 BVH 领域的其他工作包括 Vaidyanathan 等人（#source-cite("Vaidyanathan2016")），他们引入了一种降低精度的 BVH 表示，仍然保证相对于原始 BVH 的保守相交测试。 Liktor 和 Vaidyanathan（#source-cite("Liktor2016")）引入了一种基于节点聚类的 BVH 节点表示，改善了缓存性能并减少了子节点指针的存储需求。 Ylitie 等人（#source-cite("Ylitie2017")）展示了如何将二叉 BVH 最优地转换为具有更多子节点的更宽 BVH，从中他们推导出一种压缩 BVH 表示，在非相干射线条件下显示出显著的带宽减少。 Vaidyanathan 等人（#source-cite("Vaidyanathan2019")）开发了一种算法，用于高效遍历这种宽 BVH，使用一个小堆栈。 Benthin 等人（#source-cite("Benthin2018")）专注于压缩 BVH 的相邻叶节点集，基于大部分内存用于叶节点的原则，Lin 等人（#source-cite("Lin2019")）描述了一种利用一个 BVH 节点的各子节点包围盒之间共享的平面，来节省计算和存储的方法。
]

#parec[
  Yoon and Manocha (#source-cite("Yoon06b")) described algorithms for cache-efficient layout of BVHs and kd-trees and demonstrated performance improvements from using them. See also Ericson's book (#source-cite("Ericson04")) for extensive discussion of this topic.
][
  Yoon 和 Manocha（#source-cite("Yoon06b")）描述了 BVH 和 kd 树 的缓存高效布局算法，并展示了使用这些算法的性能改进。 另请参阅 Ericson 的书（#source-cite("Ericson04")），其中对该主题进行了广泛讨论。
]

#parec[
  The linear BVH was introduced by Lauterbach et al.~(#source-cite("Lauterbach09")); Morton codes were first described in a report by Morton (#source-cite("Morton1966")). Pantaleoni and Luebke (#source-cite("Pantaleoni2010a")) developed the HLBVH generalization, using the SAH at the upper levels of the tree. They also noted that the upper bits of the Morton-coded values can be used to efficiently find clusters of primitives—both of these ideas are used in our HLBVH implementation. Garanzha et al.~(#source-cite("Garanzha2011")) introduced further improvements to the HLBVH, most of them targeting GPU implementations. Vinkler et al.~(#source-cite("Vinkler2017")) described improved techniques for mapping values to the Morton index coordinates that lead to higher-quality BVHs, especially for scenes with a range of primitive sizes.
][
  线性 BVH 是由 Lauterbach 等人（#source-cite("Lauterbach09")）引入的；Morton 码首次在 Morton 的一份报告中描述（#source-cite("Morton1966")）。 Pantaleoni 和 Luebke（#source-cite("Pantaleoni2010a")）开发了 HLBVH 泛化，在树的上层使用 SAH。 他们还指出，Morton 编码值的高位可以用于高效地找到图元的聚类——这两个想法都在我们的 HLBVH 实现中使用。 Garanzha 等人（#source-cite("Garanzha2011")）引入了对 HLBVH 的进一步改进，其中大多数针对 GPU 实现。 Vinkler 等人（#source-cite("Vinkler2017")）描述了将值映射到 Morton 索引坐标的改进技术，这些技术导致了更高质量的 BVH，特别是对于具有不同图元尺寸的场景。
]

#parec[
  Wald (#source-cite("Wald2012")) described an approach for high-performance parallel BVH construction on CPUs that uses the SAH throughout. More recently, Benthin et al.~(#source-cite("Benthin2017")) have described a two-level BVH construction technique based on building high-quality second-level BVHs for collections of objects in a scene, collecting them into a single BVH, and then iteratively refining the overall tree, including moving subtrees from one of the initial BVHs to another. Hendrich et al.~(#source-cite("Hendrich2017")) described a related technique, quickly building an initial LBVH and then progressively building a higher-quality BVH based on it.
][
  Wald（#source-cite("Wald2012")）描述了一种在 CPU 上进行高性能并行 BVH 构建的方法，该方法在整个过程中使用 SAH。 最近，Benthin 等人（#source-cite("Benthin2017")）描述了一种基于为场景中的对象集合构建高质量二级 BVH 的两级 BVH 构建技术，将它们收集到一个 BVH 中，然后迭代地优化整个树，包括将子树从一个初始 BVH 移动到另一个。 Hendrich 等人（#source-cite("Hendrich2017")）描述了一种相关技术，快速构建初始 LBVH，然后基于它逐步构建更高质量的 BVH。
]

#parec[
  A comprehensive survey of work in bounding volume hierarchies, spanning construction, representation, traversal, and hardware acceleration, was recently published by Meister et al.~(#source-cite("Meister2021")).
][
  Meister 等人（#source-cite("Meister2021")）最近发表了一篇关于包围体层次结构的全面综述，涵盖了构建、表示、遍历和硬件加速等方面的工作。
]

#heading(level: 3, numbering: none)[#ez_caption[kd-trees][kd 树]]

#parec[
  Glassner (#source-cite("Glassner84")) introduced the use of octrees for ray intersection acceleration. Use of the kd-tree for ray tracing was first described by Kaplan (#source-cite("Kaplan85")). Kaplan's tree construction algorithm always split nodes down their middle; MacDonald and Booth (#source-cite("MacDonald90")) introduced the SAH approach, estimating ray–node traversal probabilities using relative surface areas. Naylor (#source-cite("Naylor93")) has also written on general issues of constructing good kd-trees. Havran and Bittner (#source-cite("Havran02")) revisited many of these issues and introduced useful improvements. Adding a bonus factor to the SAH for tree nodes that are completely empty was suggested by Hurley et al.~(#source-cite("Hurley02")). See Havran's Ph.D.~thesis (#source-cite("Havran2000")) for an excellent overview of high-performance kd-construction and traversal algorithms.
][
  Glassner（#source-cite("Glassner84")）引入了使用八叉树来加速射线求交。Kaplan（#source-cite("Kaplan85")）首次描述了在光线追踪中使用kd 树。Kaplan的树构建算法总是从中间分割节点；MacDonald和Booth（#source-cite("MacDonald90")）引入了表面积启发式（SAH）方法，利用相对表面积估计射线遍历节点的概率。 Naylor（#source-cite("Naylor93")）也撰写了关于构建优良kd 树的一般问题。Havran和Bittner（#source-cite("Havran02")）重新审视了许多这些问题并引入了有用的改进。Hurley等人（#source-cite("Hurley02")）建议为完全空的树节点在SAH中添加一个奖励因子。有关高性能kd构建和遍历算法的优秀概述，请参见Havran的博士论文（#source-cite("Havran2000")）。
]

#parec[
  Jansen (#source-cite("Jansen86")) first developed the efficient ray-traversal algorithm for kd-trees. Arvo (#source-cite("Arvo88")) also investigated this problem and discussed it in a note in Ray Tracing News. Sung and Shirley (#source-cite("Sung92")) described a ray-traversal algorithm's implementation for a BSP-tree accelerator; our KdTreeAggregate traversal code (included in the online edition) is loosely based on theirs.
][
  Jansen（#source-cite("Jansen86")）首次开发了kd 树的高效光线遍历算法。Arvo（#source-cite("Arvo88")）也研究了这个问题，并在《光线追踪新闻》中进行了讨论。Sung和Shirley（#source-cite("Sung92")）描述了一种用于BSP树加速器的光线遍历算法的实现；我们的`KdTreeAggregate`遍历代码（包含在在线版本中）大致基于他们的实现。
]

#parec[
  The asymptotic complexity of the kd-tree construction algorithm in pbrt is $O(n log^2 n)$. Wald and Havran (#source-cite("Wald06")) showed that it is possible to build kd-trees in $O(n log n)$ time with some additional implementation complexity; they reported a 2 to 3 times speedup in construction time for typical scenes.
][
  `pbrt`中kd 树构建算法的渐近复杂度是 $O (n log^2 n)$。Wald和Havran（#source-cite("Wald06")）展示了在增加一些实现上的复杂度的情况下，可以在 $O (n log n)$ 时间内构建kd 树；他们报告说对于典型场景，构建时间加速了2到3倍。
]

#parec[
  The best kd-trees for ray tracing are built using "perfect splits," where the primitive being inserted into the tree is clipped to the bounds of the current node at each step. This eliminates the issue that, for example, an object's bounding box may intersect a node's bounding box and thus be stored in it, even though the object itself does not intersect the node's bounding box. This approach was introduced by Havran and Bittner (#source-cite("Havran02")) and discussed further by Hurley et al.~(#source-cite("Hurley02")), Wald and Havran (#source-cite("Wald06")), and Soupikov et al.~(#source-cite("Soupikov08")). Even with perfect splits, large primitives may still be stored in many kd-tree leaves; Choi et al.~(#source-cite("Choi2013")) suggested storing some primitives in interior nodes to address this issue.
][
  用于光线追踪的最佳 kd 树采用“完美划分”（perfect splits）：每一步都将待插入图元裁剪到当前节点的包围范围。这样可以避免仅因对象包围盒与节点重叠，就把实际上不与节点重叠的对象存入其中。这一方法由 Havran 和 Bittner（#source-cite("Havran02")）提出，Hurley 等人（#source-cite("Hurley02")）、Wald 和 Havran（#source-cite("Wald06")）、Soupikov 等人（#source-cite("Soupikov08")）作了进一步讨论。即便如此，大图元仍可能进入许多叶节点；Choi 等人（#source-cite("Choi2013")）建议把部分图元存于内部节点来解决。
]

#parec[
  kd-tree construction tends to be much slower than BVH construction (especially if "perfect splits" are used), so parallel construction algorithms are of particular interest. Work in this area includes that of Shevtsov et al.~(#source-cite("Shevtsov07b")) and Choi et al.~(#source-cite("Choi2010")), who presented efficient parallel kd-tree construction algorithms with good scalability to multiple processors.
][
  kd 树构建往往比BVH构建慢得多（尤其是使用“完美划分”时），因此并行构建算法特别受关注。该领域的工作包括Shevtsov等人（#source-cite("Shevtsov07b")）和Choi等人（#source-cite("Choi2010")），他们提出了具有良好多处理器可扩展性的高效并行kd 树构建算法。
]

#heading(level: 3, numbering: none)[#ez_caption[The Surface Area Heuristic][表面积启发式]]

#parec[
  A number of researchers have investigated improvements to the SAH since its introduction to ray tracing by MacDonald and Booth (#source-cite("MacDonald90")). Fabianowski et al.~(#source-cite("Fabianowski2009")) derived a version that replaces the assumption that rays are uniformly distributed throughout space with the assumption that ray origins are uniformly distributed inside the scene's bounding box. Hunt and Mark (#source-cite("Hunt08b")) introduced a modified SAH that accounts for the fact that rays generally are not uniformly distributed but rather that many of them originate from a single point or a set of nearby points (cameras and light sources, respectively). Hunt (#source-cite("Hunt2008")) showed how the SAH should be modified when the "mailboxing" optimization is being used, and Vinkler et al.~(#source-cite("Vinkler2012")) used assumptions about the visibility of primitives to adjust their SAH cost. Ize and Hansen (#source-cite("Ize2011")) derived a "ray termination surface area heuristic" (RTSAH), which they used to adjust BVH traversal order for shadow rays in order to more quickly find intersections with occluders. See also Moulin et al.~(#source-cite("Moulin2015")), who adapted the SAH to account for shadow rays being occluded during kd-tree traversal.
][
  MacDonald 和 Booth（#source-cite("MacDonald90")）将 SAH 引入光线追踪后，研究者提出了多种改进。Fabianowski 等人（#source-cite("Fabianowski2009")）将“射线在空间中均匀分布”的假设改为“射线原点在场景包围盒内均匀分布”。Hunt 和 Mark（#source-cite("Hunt08b")）考虑许多射线来自单点或一组邻近点（分别对应相机和光源）的情况。Hunt（#source-cite("Hunt2008")）研究了 mailboxing 优化下如何修改 SAH；Vinkler 等人（#source-cite("Vinkler2012")）利用图元可见性假设调整成本。Ize 和 Hansen（#source-cite("Ize2011")）提出射线终止表面积启发式（RTSAH），据此调整阴影射线的 BVH 遍历顺序，以更快找到遮挡物。Moulin 等人（#source-cite("Moulin2015")）则在 kd 树中将阴影射线会中途被遮挡这一因素计入 SAH。
]

#parec[
  While the SAH has led to very effective kd-trees and BVHs, a number of researchers have noted that it is not unusual to encounter cases where a kd-tree or BVH with a higher SAH-estimated cost gives better performance than one with lower estimated cost. Aila et al.~(#source-cite("Aila2013")) surveyed some of these results and proposed two additional heuristics that help address them; one accounts for the fact that most rays start on surfaces—ray origins are not actually randomly distributed throughout the scene—and another accounts for SIMD divergence when multiple rays traverse the hierarchy together. While these new heuristics are effective at explaining why a given tree delivers the performance that it does, it is not yet clear how to incorporate them into tree construction algorithms.
][
  虽然利用 SAH 构建的 kd 树和 BVH 十分有效，但许多研究人员注意到，遇到表面积启发式估计成本较高的kd 树或BVH性能优于估计成本较低的情况并不罕见。 Aila等人（#source-cite("Aila2013")）综述了其中一些结果，并提出两个额外的启发式来解释这些现象；一个考虑到大多数光线从表面开始——光线起点实际上并不是在整个场景中随机分布的——另一个考虑到当多条光线一起遍历层次结构时的SIMD分歧。 虽然这些新启发式在解释给定树的性能方面非常有效，但尚不清楚如何将它们整合到树构建算法中。
]

#parec[
  Evaluating the SAH can be costly, particularly when many different splits or primitive partitions are being considered. One solution to this problem is to only compute it at a subset of the candidate points—for example, along the lines of the bucketing approach used in the BVHAggregate in pbrt. Hurley et al.~(#source-cite("Hurley02")) suggested this approach for building kd-trees, and Popov et al.~(#source-cite("Popov06")) discussed it in detail. Shevtsov et al.~(#source-cite("Shevtsov07b")) introduced the improvement of binning the full extents of triangles, not just their centroids.
][
  评估表面积启发式可能代价高昂，尤其是在考虑多种不同分割或图元分区时。解决此问题的一个方法是仅在候选点的一个子集上计算它——例如，采用与 `pbrt` 的 `BVHAggregate` 相似的分桶方法。 Hurley等人（#source-cite("Hurley02")）建议这种方法用于构建kd 树，Popov等人（#source-cite("Popov06")）详细讨论了这一点。Shevtsov等人（#source-cite("Shevtsov07b")）引入了对三角形的完整范围进行分箱的改进，而不仅仅是它们的质心。
]

#parec[
  Wodniok and Goesele constructed BVHs where the SAH cost estimate is not based on primitive counts and primitive bounds but is instead found by actually building BVHs for various partitions and computing their SAH cost (Wodniok and Goesele #source-cite("Wodniok2016")). They showed a meaningful improvement in ray intersection performance, though at a cost of impractically long BVH construction times.
][
  Wodniok和Goesele构建了BVH，其中表面积启发式成本估计不是基于图元数量和包围范围，而是通过实际构建各种分区的BVH并计算其表面积启发式成本来找到的（Wodniok和Goesele #source-cite("Wodniok2016")）。他们展示了射线求交性能的显著改进，尽管代价是BVH构建时间过长而不切实际。
]

#parec[
  Hunt et al.~(#source-cite("Hunt2006")) noted that if you only have to evaluate the SAH at one point, for example, you do not need to sort the primitives but only need to do a linear scan over them to compute primitive counts and bounding boxes at the point. pbrt's implementation follows that approach. They also showed that approximating the SAH with a piecewise quadratic based on evaluating it at a number of individual positions, and using that to choose a good split, leads to effective trees. A similar approximation was used by Popov et al.~(#source-cite("Popov06")).
][
  Hunt等人（#source-cite("Hunt2006")）指出，如果只需在一个点上评估表面积启发式，例如，您不需要对图元进行排序，只需对它们进行线性扫描以计算该点的图元计数和包围盒。`pbrt`的实现遵循了这种方法。 他们还展示了通过在多个单独位置评估表面积启发式并使用分段二次近似来选择一个好的分割，能够生成高效的树。Popov等人（#source-cite("Popov06")）使用了类似的近似方法。
]

#heading(level: 3, numbering: none)[#ez_caption[Other Topics in Acceleration Structures][加速结构的其他主题]]

#parec[
  Weghorst, Hooper, and Greenberg (#source-cite("Weghorst84")) discussed the trade-offs of using various shapes for bounding volumes and suggested projecting objects to the screen and using a $z$ -buffer rendering to accelerate finding intersections for camera rays.
][
  Weghorst、Hooper 和 Greenberg（#source-cite("Weghorst84")）讨论了使用各种形状作为包围体的权衡，并建议将对象投影到屏幕上并使用 z 缓冲区渲染来加速相机光线的交点查找。
]

#parec[
  A number of researchers have investigated the applicability of general BSP trees, where the splitting planes are not necessarily axis aligned, as they are with kd-trees. Kammaje and Mora (#source-cite("Kammaje07")) built BSP trees using a preselected set of candidate splitting planes. Budge et al.~(#source-cite("Budge2008")) developed a number of improvements to their approach, though their results only approached kd-tree performance in practice due to a slower construction stage and slower traversal than kd-trees. Ize et al.~(#source-cite("Ize08")) showed a BSP implementation that renders scenes faster than kd-trees but at the cost of extremely long construction times.
][
  研究者还考察了通用 BSP 树，其中划分平面不必像 kd 树那样与坐标轴对齐。Kammaje 和 Mora（#source-cite("Kammaje07")）从预选的一组平面中选择来构建 BSP 树。Budge 等人（#source-cite("Budge2008")）提出若干改进，但由于构建和遍历均较慢，实际性能只接近 kd 树。Ize 等人（#source-cite("Ize08")）实现的 BSP 渲染速度超过 kd 树，代价却是极长的构建时间。
]

#parec[
  There are many techniques for traversing a collection of rays through the acceleration structure together, rather than just one at a time. This approach ("packet tracing") is an important component of many high-performance ray tracing approaches; it is discussed in more detail in Section 16.2.3.
][
  有许多技术可以同时遍历加速结构中的光线集合，而不是逐个遍历。这种方法（“射线包追踪”）是许多高性能光线追踪方法的重要组成部分；在第 16.2.3 节中对此进行了更详细的讨论。
]

#parec[
  Animated primitives present two challenges to ray tracers: first, renderers that try to reuse acceleration structures over multiple frames of an animation must update the acceleration structures if objects are moving. Lauterbach et al.~(#source-cite("Lauterbach2006")) and Wald et al.~(#source-cite("Wald07a")) showed how to incrementally update BVHs in this case, and Kopta et al.~(#source-cite("Kopta2012")) reused BVHs over multiple frames of an animation, maintaining their quality by updating the parts that bound moving objects. Garanzha (#source-cite("Garanzha2009")) suggested creating clusters of nearby primitives and then building BVHs of those clusters (thus lightening the load on the BVH construction algorithm).
][
  动画图元对光线追踪器提出了两个挑战：首先，尝试在动画的多个帧中重用加速结构的渲染器必须在对象移动时更新加速结构。 Lauterbach 等人（#source-cite("Lauterbach2006")）和 Wald 等人（#source-cite("Wald07a")）展示了如何在这种情况下增量更新包围体层次结构 (BVH)，而 Kopta 等人（#source-cite("Kopta2012")）在动画的多个帧中重用了 BVH，通过更新包围运动对象的那些部分来保持其质量。 Garanzha（#source-cite("Garanzha2009")）建议创建附近图元的集群，然后构建这些集群的 BVH（从而减轻 BVH 构建算法的负担）。
]

#parec[
  A second challenge from animated primitives is that for primitives that are moving quickly, the bounding boxes of their full motion over the frame time may be quite large, leading to many unnecessary ray–primitive intersection tests. Notable work on this issue includes Glassner (#source-cite("Glassner1988")), who generalized ray tracing (and an octree for acceleration) to four dimensions, adding time. More recently, Grünschloß et al.~(#source-cite("Grunschloss2011")) developed improvements to BVHs for moving primitives. See also Wald et al.'s (#source-cite("Wald2007b")) survey paper on ray tracing animated scenes. Woop et al.~(#source-cite("Woop2017")) described a generalization of BVHs that also allows nodes to split in time, with child nodes of such a split accounting for different time ranges.
][
  动画图元带来的第二个挑战是，对于快速移动的图元，其在帧时间内的完整运动的包围盒可能相当大，导致许多不必要的射线与图元求交测试。 关于这个问题的显著工作包括 Glassner（#source-cite("Glassner1988")），他将光线追踪（和用于加速的八叉树）推广到四维，增加了时间。 最近，Grünschloß 等人（#source-cite("Grunschloss2011")）开发了针对移动图元的 BVH 改进。 另请参阅 Wald 等人（#source-cite("Wald2007b")）关于光线追踪动画场景的调查论文。Woop 等人（#source-cite("Woop2017")）描述了一种 BVH 的推广，它还允许节点在时间上分裂，这种分裂的子节点考虑了不同的时间范围。
]

#parec[
  An innovative approach to acceleration structures was suggested by Arvo and Kirk (#source-cite("Arvo87")), who introduced a 5D data structure that subdivided based on both 3D spatial and 2D ray directions. Another interesting approach for scenes described with triangle meshes was developed by Lagae and Dutré (#source-cite("Lagae08b")): they computed a constrained tetrahedralization, where all triangle faces of the model are represented in the tetrahedralization. Rays are then stepped through tetrahedra until they intersect a triangle from the scene description. This approach is still a few times slower than the state of the art in kd-trees and BVHs but is an interesting new way to think about the problem.
][
  Arvo 和 Kirk（#source-cite("Arvo87")）提出了一种创新的加速结构方法，他们引入了一种 5D 数据结构，该结构基于 3D 空间和 2D 光线方向进行细分。 Lagae 和 Dutré（#source-cite("Lagae08b")）为用三角网格描述的场景开发了另一种有趣的方法：他们计算了一个受约束的四面体化，其中模型的所有三角面都在四面体化中表示。 然后光线穿过四面体，直到它们与场景描述中的三角形相交。这种方法仍比 kd 树和 BVH 的最新技术慢几倍，但它提供了一种思考问题的新颖有趣的方式。
]

#parec[
  There is a middle ground between kd-trees and BVHs, where the tree node holds a splitting plane for each child rather than just a single splitting plane. This refinement makes it possible to do object subdivision in a kd-tree-like acceleration structure, putting each primitive in just one subtree and allowing the subtrees to overlap, while still preserving many of the benefits of efficient kd-tree traversal. Ooi et al.~(#source-cite("Ooi87")) first introduced this refinement to kd-trees for storing spatial data, naming it the "spatial kd-tree" (skd-tree). Skd-trees have been applied to ray tracing by a number of researchers, including Zachmann (#source-cite("Zachmann02")), Woop et al.~(#source-cite("Woop06")), Wächter and Keller (#source-cite("Wachter2006")), Havran et al.~(#source-cite("Havran06")), and Zuniga and Uhlmann (#source-cite("Zuniga06")).
][
  在 kd 树和 BVH 之间存在一个中间地带，其中树节点为每个子节点保存一个分割平面，而不仅仅是一个分割平面。 这种细化使得在类似 kd 树的加速结构中进行对象划分成为可能，将每个图元放在一个子树中，并允许子树重叠，同时仍然保留高效 kd 树遍历的许多优点。 Ooi 等人（#source-cite("Ooi87")）首次将这种细化引入 kd 树以存储空间数据，称其为“空间 kd 树”（skd 树）。 包括 Zachmann（#source-cite("Zachmann02")）、Woop 等人（#source-cite("Woop06")）、Wächter 和 Keller（#source-cite("Wachter2006")）、Havran 等人（#source-cite("Havran06")）以及 Zuniga 和 Uhlmann（#source-cite("Zuniga06")）在内的许多研究人员将 skd 树应用于光线追踪。
]

#parec[
  When spatial subdivision approaches like grids or kd-trees are used, primitives may overlap multiple nodes of the structure and a ray may be tested for intersection with the same primitive multiple times as it passes through the structure. Arnaldi, Priol, and Bouatouch (#source-cite("Arnaldi87")) and Amanatides and Woo (#source-cite("Amanatides87")) developed the "mailboxing" technique to address this issue: each ray is given a unique integer identifier, and each primitive records the id of the last ray that was tested against it. If the ids match, then the intersection test is unnecessary and can be skipped.
][
  采用网格或 kd 树等空间划分结构时，同一图元可与多个节点重叠，射线穿过这些节点时便可能重复求交。Arnaldi、Priol 和 Bouatouch（#source-cite("Arnaldi87")）以及 Amanatides 和 Woo（#source-cite("Amanatides87")）提出 mailboxing（信箱）技术：给每条射线唯一的整数标识符，让每个图元记录最后一次对其进行求交测试的射线标识符；若二者相同，就可跳过重复测试。
]

#parec[
  While effective, mailboxing does not work well with a multi-threaded ray tracer. To address this issue, Benthin (#source-cite("Benthin2006")) suggested storing a small per-ray hash table to record ids of recently intersected primitives. Shevtsov et al.~(#source-cite("Shevtsov07a")) maintained a small array of the last $n$ intersected primitive ids and searched it linearly before performing intersection tests. Although some primitives may still be checked multiple times with both of these approaches, they usually eliminate most redundant tests.
][
  mailboxing 虽然有效，但在多线程光线追踪器中不易高效使用。Benthin（#source-cite("Benthin2006")）建议为每条射线保存一个小哈希表，记录近期测试过的图元标识符。Shevtsov 等人（#source-cite("Shevtsov07a")）用小数组保存最近 $n$ 次求交所涉及的图元标识符，在求交前线性搜索。两种方法仍可能重复检查部分图元，但通常能消除大多数冗余测试。
]



#parec[Editorial note: the fixed source cites Cline et al. (2006) for compact BVH nodes, but its corresponding bibliographic record is “Two stage importance sampling for direct lighting.” Both the citation and the bibliographic record are preserved; the intended reference requires source-level clarification.][校订说明：固定原文在紧凑 BVH 节点一段引用 Cline 等人（2006），对应书目却是《Two stage importance sampling for direct lighting》。此处保留原引用及书目信息，实际所指文献有待原文层面核实。]
