#import "../template.typ": parec, ez_caption, source-cite

#heading(level: 2, numbering: none)[#ez_caption[Exercises][习题]]
<primitives-exercises>

#parec[
  1. ② What kinds of scenes are worst-case scenarios for the two acceleration structures in `pbrt`? (Consider specific geometric configurations that the approaches will respectively be unable to handle well.) Construct scenes with these characteristics, and measure the performance of `pbrt` as you add more primitives. How does the worst case for one behave when rendered with the other?
][
  1. ② 哪些场景分别是 `pbrt` 两种加速结构的最坏情况？考虑各自难以处理的具体几何配置，构建具有这些特征的场景，逐步增加图元并测量性能。一种结构的最坏情况，在另一种结构下表现如何？
]

#parec[
  2. ② Implement a hierarchical grid accelerator where cells that have an excessive number of primitives overlapping them are refined to instead hold a finer subgrid to store its geometry. (See, for example, Jevans and Wyvill (#source-cite("Jevans89")) for one approach to this problem and Ize et al.~(#source-cite("Ize07")) for effective methods for deciding when refinement is worthwhile.) Compare both accelerator construction performance and rendering performance to a non-hierarchical grid as well as to `pbrt`'s built-in accelerators.
][
  2. ② 实现分层网格加速器：若一个单元与过多图元重叠，就细化为更密的子网格来存放几何体。可参阅 Jevans 和 Wyvill（#source-cite("Jevans89")）的一种实现，以及 Ize 等人（#source-cite("Ize07")）对何时值得细化的研究。分别比较其构建和渲染性能，与普通网格以及 `pbrt` 内置加速结构对照。
]

#parec[
  3. ② #emph[Smarter overlap tests for building aggregates]: using objects' bounding boxes to determine which sides of a kd-tree split they overlap can hurt performance by causing unnecessary intersection tests. Therefore, add a `bool Overlaps(const Bounds3f &) const` method to the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface that takes a rendering space bounding box and determines if the shape truly overlaps the given bound. A default implementation could get the rendering space bound from the shape and use that for the test, and specialized versions could be written for frequently used shapes. Implement this method for `Sphere`s and `Triangle`s, and modify #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[KdTreeAggregate] to call it. You may find it helpful to read Akenine-Möller's paper (#source-cite("Moller01")) on fast triangle-box overlap testing. Measure the change in `pbrt`'s overall performance caused by this change, separately accounting for increased time spent building the acceleration structure and reduction in ray–object intersection time due to fewer intersections. For a variety of scenes, determine how many fewer intersection tests are performed thanks to this improvement.
][
  3. ② #emph[更准确的聚合体构建重叠测试]：仅凭对象包围盒判断图元与 kd 树划分哪一侧重叠，可能引入多余求交测试。为 `Shape` 增加 `bool Overlaps(const Bounds3f &) const`，接收渲染空间包围盒，判断形状本身是否真正重叠。默认实现可以用形状的渲染空间包围盒测试，常用形状则提供专门实现。为 `Sphere` 和 `Triangle` 实现它，并修改 `KdTreeAggregate` 调用该方法。可参考 Akenine-Möller（#source-cite("Moller01")）的快速三角形—包围盒重叠测试。测量整体性能变化，分别统计增加的建树时间与减少求交次数后节省的射线—对象求交时间。对多种场景，统计少做了多少次测试。
]

#parec[
  4. ② Implement "split clipping" in `pbrt`'s BVH implementation. Read one or more papers on this topic, including ones by Ernst and Greiner (#source-cite("Ernst2007")), Dammertz and Keller (#source-cite("Dammertz2008a")), Stich et al.~(#source-cite("Stich2009")), Karras and Aila (#source-cite("Karras2013")), and Ganestam and Doggett (#source-cite("Ganestam2016")), and implement one of their approaches to subdivide primitives with large bounding boxes relative to their surface area into multiple subprimitives for tree construction. (Doing so will probably require modification to the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface; you will probably want to design a new interface that allows some shapes to indicate that they are unable to subdivide themselves, so that you only need to implement this method for triangles, for example.) Measure the improvement for rendering actual scenes; a compelling way to gather this data is to do the experiment that Dammertz and Keller did, where a scene is rotated around an axis over progressive frames of an animation. Typically, many triangles that are originally axis aligned will have very loose bounding boxes as they rotate more, leading to a substantial performance degradation if split clipping is not used.
][
  4. ② 在 `pbrt` 的 BVH 中实现“分割裁剪”。阅读 Ernst 和 Greiner（#source-cite("Ernst2007")）、Dammertz 和 Keller（#source-cite("Dammertz2008a")）、Stich 等人（#source-cite("Stich2009")）、Karras 和 Aila（#source-cite("Karras2013")）、Ganestam 和 Doggett（#source-cite("Ganestam2016")）的一篇或多篇论文，实现其中一种方法：将相对于表面积而言包围盒过大的图元分成多个子图元，用于建树。可能需要修改 `Shape` 接口，让不支持自划分的形状能够明确表示这一点，从而例如只需为三角形实现划分。测量实际场景的性能提升。可以复现 Dammertz 和 Keller 的实验，让场景在连续动画帧中绕一根轴旋转；许多初始与轴对齐的三角形旋转后，包围盒会变得很松，不做分割裁剪时往往会明显降低性能。
]

#parec[
  5. ② The 30-bit Morton codes used for the HLBVH construction algorithm in the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate] may be insufficient for scenes with large spatial extents because they can only represent $2^10 = 1024$ steps in each dimension. Modify the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate] to use 64-bit integers with 63-bit Morton codes for HLBVHs. Compare the performance of your approach to the original one with a variety of scenes. Are there scenes where performance is substantially improved? Are there any where there is a loss of performance?
][
  5. ② `BVHAggregate` 的 HLBVH 使用 30 位 Morton 编码，每维只能表示 $2^10=1024$ 个步长，对空间范围很大的场景可能不足。修改实现，用 64 位整数保存 63 位 Morton 编码。对多种场景与原实现比较：哪些场景明显改善？是否有场景性能下降？
]

#parec[
  6. ② Investigate alternative SAH cost functions for building BVHs or kd-trees. How much can a poor cost function hurt its performance? How much improvement can be had compared to the current one? (See the discussion in the "Further Reading" section for ideas about how the SAH may be improved.)
][
  6. ② 研究用于 BVH 或 kd 树构建的其他 SAH 成本函数。差的成本函数能使性能恶化多少？相比当前函数又能改善多少？可从“延伸阅读”中的 SAH 改进讨论寻找思路。
]

#parec[
  7. ③ The idea of using spatial data structures for ray intersection acceleration can be generalized to include spatial data structures that themselves hold other spatial data structures rather than just primitives. Not only could we have a grid that has subgrids inside the grid cells that have many primitives in them, but we could also have the scene organized into a hierarchical bounding volume where the leaf nodes are grids that hold smaller collections of spatially nearby primitives. Such hybrid techniques can bring the best of a variety of spatial data structure–based ray intersection acceleration methods. In `pbrt`, because both geometric primitives and intersection accelerators implement the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive] interface and thus provide the same interface, it is easy to mix and match in this way. Modify `pbrt` to build hybrid acceleration structures—for example, using a BVH to coarsely partition the scene geometry and then uniform grids at the leaves of the tree to manage dense, spatially local collections of geometry. Measure the running time and memory use for rendering scenes with this method compared to the current aggregates.
][
  7. ③ 求交加速的空间结构也可以保存其他空间结构。除了在图元很多的网格单元中再建子网格，还可将场景组织为包围体层次结构，在叶节点使用网格管理空间相近的小组图元。这类混合方法有望结合多种结构的优点。`pbrt` 的几何图元和加速器都实现 `Primitive` 接口，因此很容易这样组合。修改 `pbrt` 构建混合结构，例如用 BVH 粗分场景，在叶节点用均匀网格管理局部密集几何。与当前聚合体比较渲染时间和内存开销。
]

#parec[
  8. ② Eisemann et al.~(#source-cite("Eisemann2007")) described an even more efficient ray–box intersection test than is used in the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate]. It does more computation at the start for each ray but makes up for this work with fewer computations to do tests for individual bounding boxes. Implement their method in `pbrt`, and measure the change in rendering time for a variety of scenes. Are there simple scenes where the additional upfront work does not pay off? How does the improvement for highly complex scenes compare to the improvement for simpler scenes?
][
  8. ② Eisemann 等人（#source-cite("Eisemann2007")）提出比 `BVHAggregate` 当前使用的方法更高效的射线—包围盒测试。它为每条射线多做一些预计算，换取每次包围盒测试的计算减少。在 `pbrt` 中实现并测量多种场景的渲染时间变化。是否有简单场景无法抵偿预计算开销？复杂场景和简单场景的提升幅度有何不同？
]

#parec[
  9. ② Although the intersection algorithm implemented in the #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#IntersectTriangle")[IntersectTriangle()] function is watertight, a source of inaccuracy in ray–triangle intersections computed in `pbrt` remains: because the triangle intersection algorithm shears the vertices of the triangle, it may no longer lie in its original bounding box. In turn, the BVH traversal algorithm must be modified to account for this error so that valid intersections are not missed. Read the discussion of this issue in Woop et al.'s paper (#source-cite("Woop2013")) and modify `pbrt` to fix this issue. What is the performance impact of your fix? Can you find any scenes where the image changes as a result of it?
][
  9. ② 虽然 `IntersectTriangle()` 的求交算法是水密的，`pbrt` 仍有一个射线—三角形求交误差来源：算法对三角形顶点进行剪切后，三角形可能不再位于原包围盒中。因此需修改 BVH 遍历来考虑这一误差，避免漏掉有效交点。阅读 Woop 等人（#source-cite("Woop2013")）的相关讨论并修复实现。性能受到什么影响？能否找到渲染图像因此发生变化的场景？
]

#parec[
  10. ② Read the paper by Segovia and Ernst (#source-cite("Segovia2010")) on memory-efficient BVHs, and implement their approach in `pbrt`. How does memory usage with their approach compare to that for the `BVHAggregate`? Compare rendering performance with your approach to `pbrt`'s current performance. Discuss how your results compare to the results reported in their paper.
][
  10. ② 阅读 Segovia 和 Ernst（#source-cite("Segovia2010")）关于节省内存的 BVH 的论文，在 `pbrt` 中实现该方法。其内存占用与 `BVHAggregate` 相比如何？渲染性能与当前实现相比如何？讨论实验结果与论文报告的结果有何异同。
]

#parec[
  11. ② Modify `pbrt` to use the "mailboxing" optimization in the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[KdTreeAggregate] to avoid repeated intersections with primitives that overlap multiple kd-tree nodes. Given that `pbrt` is multi-threaded, you will probably do best to consider either the hashed mailboxing approach suggested by Benthin (#source-cite("Benthin2006")) or the inverse mailboxing algorithm of Shevtsov et al.~(#source-cite("Shevtsov07a")). Measure the performance change compared to the current implementation for a variety of scenes. How does the change in running time relate to changes in reported statistics about the number of ray–primitive intersection tests?
][
  11. ② 修改 `KdTreeAggregate`，使用 mailboxing 优化，避免对跨越多个 kd 树节点的图元重复求交。考虑到 `pbrt` 是多线程程序，可优先考虑 Benthin（#source-cite("Benthin2006")）的哈希 mailboxing，或 Shevtsov 等人（#source-cite("Shevtsov07a")）的逆向 mailboxing。测量多种场景下的性能变化，讨论运行时间变化与报告的射线—图元求交次数变化之间的关系。
]

#parec[
  12. ② Consider a scene with an animated camera that is tracking a moving object such that there is no relative motion between the two. For such a scene, it may be more efficient to represent it with the camera and object being static and with a corresponding relative animated transformation applied to the rest of the scene. In this way, ray intersections with the tracked object will be more efficient since its bounding box is not expanded by its motion. Construct such a scene and then measure the performance of rendering it with both ways of representing the motion by making corresponding changes to the scene description file. How is performance affected by the size of the tracked object in the image? Next, modify `pbrt` to automatically perform this optimization when this situation occurs. Can you find a way to have these benefits when the motion of the camera and some objects in the scene are close but not exactly the same?
][
  12. ② 考虑相机跟随运动对象、二者没有相对运动的场景。将相机与对象表示为静止，给场景其余部分施加相应的相对动画变换，可能更高效：被跟随对象的包围盒不必因运动而扩张，求交因而更快。构造这种场景，通过修改场景描述分别采用两种运动表示并测量性能。对象在画面中的大小如何影响结果？再修改 `pbrt`，使其自动识别并执行这种优化。相机与部分对象运动接近但不完全相同时，能否仍获得这些收益？
]

#parec[
  13. ③ It is often possible to introduce some approximation into the computation of shadows from very complex geometry (consider, e.g., the branches and leaves of a tree casting a shadow). Lacewell et al.~(#source-cite("Lacewell08")) suggested augmenting the acceleration structure with a prefiltered directionally varying representation of occlusion for regions of space. As shadow rays pass through these regions, an approximate visibility probability can be returned rather than a binary result, and the cost of tree traversal and object intersection tests is reduced. Implement such an approach in `pbrt`, and compare its performance to the current implementation. Do you see any changes in rendered images?
][
  13. ③ 对于极复杂几何体的阴影，往往可以引入近似，例如树枝和树叶投下的阴影。Lacewell 等人（#source-cite("Lacewell08")）建议为加速结构增加空间区域的预滤波遮挡表示，并允许它随方向变化。阴影射线经过区域时，返回近似可见性概率，而不是只有遮挡或可见两种结果，从而降低遍历与求交开销。在 `pbrt` 中实现这种方法，与当前实现比较性能。渲染图像是否发生变化？
]
