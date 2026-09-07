#import "../template.typ": parec, ez_caption

== #ez_caption[Bounding Volume Hierarchies][包围体层次结构]
<bounding-volume-hierarchies>
#parec[
  Bounding volume hierarchies (BVHs) are an approach for ray intersection acceleration based on primitive subdivision, where the primitives are partitioned into a hierarchy of disjoint sets. (In contrast, spatial subdivision generally partitions space into a hierarchy of disjoint sets.) Figure 7.3 shows a bounding volume hierarchy for a simple scene. Primitives are stored in the leaves, and each node stores a bounding box of the primitives in the nodes beneath it. Thus, as a ray traverses through the tree, any time it does not intersect a node's bounds, the subtree beneath that node can be skipped.
][
  包围体层次结构（BVH）是一种基于图元划分的射线求交加速方法：将图元组织为由互不相交的集合构成的层次结构。（空间划分则通常将空间划分为互不相交的区域，并组织成层次结构。）@fig:bvh-concept 展示了一个简单场景的 BVH。图元存储在叶节点中，每个节点保存其下方全部图元的包围盒。遍历时，若射线不与某节点的包围盒相交，就可跳过整棵子树。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f03.svg"),
  caption: [
    #ez_caption[
      *Bounding Volume Hierarchy for a Simple Scene.* (a) A small collection of primitives, with bounding boxes shown by dashed lines. The primitives are aggregated based on proximity; here, the sphere and the equilateral triangle are bounded by another bounding box before being bounded by a bounding box that encompasses the entire scene (both shown in solid lines). (b) The corresponding bounding volume hierarchy. The root node holds the bounds of the entire scene. Here, it has two children, one storing a bounding box that encompasses the sphere and equilateral triangle (that in turn has those primitives as its children) and the other storing the bounding box that holds the skinny triangle.
    ][
      *简单场景的包围体层次结构。*(a) 一个由少量图元组成的集合，虚线框表示这些图元的包围盒。图元根据接近程度被聚合；在这里，球体和等边三角形被另一个包围盒包围，然后再被一个包围整个场景的包围盒包围（两者都用实线框表示）。(b) 对应的包围体层次结构。根节点保存整个场景的包围范围。在这里，它有两个子节点，一个子节点保存包围球体和等边三角形的包围盒（它的子节点是这些图元），另一个子节点保存包围细长三角形的包围盒。
    ]
  ],
)<bvh-concept>

#parec[
  One property of primitive subdivision is that each primitive appears in the hierarchy only once. In contrast, a primitive may overlap multiple spatial regions with spatial subdivision and thus may be tested for intersection multiple times as the ray passes through them.#footnote[The _mailboxing_ technique can be used to avoid these multiple intersections for accelerators that use spatial subdivision, though its implementation can be tricky in the presence of multi-threading. More information on mailboxing is available in the “Further Reading” section.] Another implication of this property is that the amount of memory needed to represent the primitive subdivision hierarchy is bounded. For a binary BVH that stores a single primitive in each leaf, the total number of nodes is $2 n - 1$, where $n$ is the number of primitives. (There are $n$ leaf nodes and $n - 1$ interior nodes.) If leaves store multiple primitives, fewer nodes are needed.
][
  图元划分的一个特点是，每个图元只在层次结构中出现一次。空间划分则可能让一个图元与多个区域重叠，射线经过这些区域时，可能重复测试同一图元。#footnote[空间划分加速结构可用 _mailboxing_ 技术避免重复求交，但多线程实现可能较为棘手。“延伸阅读”提供了更多相关资料。]这也使图元划分层次结构所需的内存有明确上界。对于每个叶节点保存一个图元的二叉 BVH，若有 $n$ 个图元，总节点数为 $2 n-1$：包括 $n$ 个叶节点与 $n-1$ 个内部节点。若每个叶节点保存多个图元，节点总数还会更少。
]

#parec[
  BVHs are more efficient to build than kd-trees, and are generally more numerically robust and less prone to missed intersections due to round-off errors than kd-trees are. The BVH aggregate, BVHAggregate, is therefore the default acceleration structure in pbrt.
][
  BVH 比 kd 树构建得更快，通常也更稳健，更不易因舍入误差而漏掉交点。因此，`pbrt` 默认采用 BVH 聚合体 `BVHAggregate`。
]

#block(sticky: true)[#raw("<<BVHAggregate Definition>>=")] <fragment-BVHAggregateDefinition-0>
#block(breakable: false)[
```cpp
class BVHAggregate {
  public:
    <<BVHAggregate Public Types>>
    <<BVHAggregate Public Methods>>
  private:
    <<BVHAggregate Private Methods>>
    <<BVHAggregate Private Members>>
};
```
] <BVHAggregate>

#parec[
  Its constructor takes an enumerator value that describes which of four algorithms to use when partitioning primitives to build the tree. The default, SAH, indicates that an algorithm based on the "surface area heuristic," discussed in Section 7.3.2, should be used. An alternative, HLBVH, which is discussed in Section 7.3.3, can be constructed more efficiently (and more easily parallelized), but it does not build trees that are as effective as SAH. The remaining two approaches use even less computation but create fairly low-quality trees. They are mostly useful for illuminating the superiority of the first two approaches.
][
  构造函数接受一个枚举值，从四种图元划分算法中选择建树方式。默认的 `SAH` 使用@the-surface-area-heuristic 介绍的表面积启发式。另一种方式 `HLBVH` 见@linear-bounding-volume-hierarchies，构建更快、也更容易并行化，但生成的树不如 SAH 高效。其余两种算法计算更少，树的质量也较低，主要用来说明前两种方法的优势。
]
#block(sticky: true)[#raw("<<BVHAggregate Public Types>>=")] <fragment-BVHAggregatePublicTypes-0>
#block(breakable: false)[
```cpp
enum class SplitMethod { SAH, HLBVH, Middle, EqualCounts };
```
]

#parec[
  In addition to the enumerator, the constructor takes the primitives themselves and the maximum number of primitives that can be in any leaf node.
][
  除了枚举值，构造函数还接受图元本身和任何叶子节点中可以包含的最大图元数量。
]

#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>=")] <fragment-BVHAggregateMethodDefinitions-0>
#block(breakable: false)[
```cpp
BVHAggregate::BVHAggregate(std::vector<Primitive> prims,
        int maxPrimsInNode, SplitMethod splitMethod)
    : maxPrimsInNode(std::min(255, maxPrimsInNode)),
      primitives(std::move(prims)), splitMethod(splitMethod) {
    <<Build BVH from primitives>>
}
```
]

#block(sticky: true)[#raw("<<BVHAggregate Private Members>>=")] <fragment-BVHAggregatePrivateMembers-0>
#block(breakable: false)[
```cpp
int maxPrimsInNode;
std::vector<Primitive> primitives;
SplitMethod splitMethod;
```
]

=== #ez_caption[BVH Construction][BVH 构建]
<bvh-construction>
#parec[
  There are three stages to BVH construction in the implementation here. First, bounding information about each primitive is computed and stored in an array that will be used during tree construction. Next, the tree is built using the algorithm choice encoded in `splitMethod`. The result is a binary tree where each interior node holds pointers to its children and each leaf node holds references to one or more primitives. Finally, this tree is converted to a more compact (and thus more efficient) pointerless representation for use during rendering. (The implementation is easier with this approach, versus computing the pointerless representation directly during tree construction, which is also possible.)
][
  这里的 BVH 构建分三步。首先计算各图元的包围信息，存入供建树使用的数组。接着按 `splitMethod` 选择算法建树，得到一棵二叉树：内部节点保存子节点指针，叶节点引用一个或多个图元。最后，将树转换为更紧凑、因而更高效的无指针表示，供渲染时使用。（也可以在建树时直接生成无指针表示，但分步实现更简单。）
]

#block(sticky: true)[#raw("<<Build BVH from primitives>>=")] <fragment-BuildBVHfrommonoprimitives-0>
#block(breakable: false)[
```cpp
<<Initialize bvhPrimitives array for primitives>>
<<Build BVH for primitives using bvhPrimitives>>
<<Convert BVH into compact representation in nodes array>>
```
]

#parec[
  For each primitive to be stored in the BVH, an instance of the `BVHPrimitive` structure stores its complete bounding box and its index in the `primitives` array.
][
  对于每个要存储在 BVH 中的图元，`BVHPrimitive` 结构的一个实例存储其完整的包围盒及其在 `primitives` 数组中的索引。
]

#block(sticky: true)[#raw("<<Initialize bvhPrimitives array for primitives>>=")] <fragment-InitializemonobvhPrimitivesarrayforprimitives-0>
#block(breakable: false)[
```cpp
std::vector<BVHPrimitive> bvhPrimitives(primitives.size());
for (size_t i = 0; i < primitives.size(); ++i)
    bvhPrimitives[i] = BVHPrimitive(i, primitives[i].Bounds());
```
]

#block(sticky: true)[#raw("<<BVHPrimitive Definition>>=")] <fragment-BVHPrimitiveDefinition-0>
#block(breakable: false)[
```cpp
struct BVHPrimitive {
    BVHPrimitive(size_t primitiveIndex, const Bounds3f &bounds)
        : primitiveIndex(primitiveIndex), bounds(bounds) {}
    size_t primitiveIndex;
    Bounds3f bounds;
    <<BVHPrimitive Public Methods>>
};
```
] <BVHPrimitive>


#parec[
  A simple method makes the centroid of the bounding box available.
][
  还有一个简单的方法用于获取包围盒的质心。
]

#block(sticky: true)[#raw("<<BVHPrimitive Public Methods>>=")] <fragment-BVHPrimitivePublicMethods-0>
#block(breakable: false)[
```cpp
Point3f Centroid() const { return .5f * bounds.pMin + .5f * bounds.pMax; }
```
]

#parec[
  Hierarchy construction can now begin. In addition to initializing the pointer to the root node of the BVH, `root`, an important side effect of the tree construction process is that a new array of `Primitive` is stored in `orderedPrims`; this array stores the primitives ordered so that the primitives in each leaf node occupy a contiguous range in the array. It is swapped with the original `primitives` array after tree construction.
][
  现在可以开始构建层次结构了。建树除了设置根节点指针 `root`，还会生成新的图元数组 `orderedPrims`。其中的排列保证每个叶节点的图元占据连续区间。建树完成后，它与原 `primitives` 数组交换。
]

#block(sticky: true)[#raw("<<Build BVH for primitives using bvhPrimitives>>=")] <fragment-BuildBVHforprimitivesusingmonobvhPrimitives-0>
#block(breakable: false)[
```cpp
<<Declare Allocators used for BVH construction>>
std::vector<Primitive> orderedPrims(primitives.size());
BVHBuildNode *root;
<<Build BVH according to selected splitMethod>>
```
]

#parec[
  Memory for the initial BVH is allocated using the following `Allocators`. Note that all are based on the C++ standard library's `pmr::monotonic_buffer_resource`, which efficiently allocates memory from larger buffers. This approach is not only more computationally efficient than using a general-purpose allocator, but also uses less memory in total due to keeping less bookkeeping information with each allocation.We have found that using the default memory allocation algorithms in the place of these uses approximately 10% more memory and takes approximately 10% longer for complex scenes.
][
  初始 BVH（包围体层次结构）的内存使用以下 `Allocators` 分配。请注意，它们都基于 C++ 标准库的 `pmr::monotonic_buffer_resource`，该资源通过更大的缓冲区高效地分配内存。这种方法不仅比使用通用分配器在计算上更高效，而且由于每次分配时记录的管理信息更少，整体上使用的内存也更少。我们发现，使用默认的内存分配算法比我们用的方案，大约会多使用 10% 的内存，并且处理复杂场景时大约需要多花费 10% 的时间。
]

#parec[
  Because the `pmr::monotonic_buffer_resource` class cannot be used concurrently by multiple threads without mutual exclusion, in the parts of BVH construction that execute in parallel each thread uses per-thread allocation of them with help from the `ThreadLocal` class. Non-parallel code can use `alloc` directly.
][
  `pmr::monotonic_buffer_resource` 若不加互斥保护，就不能由多个线程并发使用。因此，在并行建树的部分，各线程借助 `ThreadLocal` 使用各自的分配器；串行代码则可直接使用 `alloc`。
]

#block(sticky: true)[#raw("<<Declare Allocators used for BVH construction>>=")] <fragment-DeclaremonoAllocatorsusedforBVHconstruction-0>
#block(breakable: false)[
```cpp
pstd::pmr::monotonic_buffer_resource resource;
Allocator alloc(&resource);
using Resource = pstd::pmr::monotonic_buffer_resource;
std::vector<std::unique_ptr<Resource>> threadBufferResources;
ThreadLocal<Allocator> threadAllocators([&threadBufferResources]() {
    threadBufferResources.push_back(std::make_unique<Resource>());
    auto ptr = threadBufferResources.back().get();
    return Allocator(ptr);
});
```
]

#parec[
  If the HLBVH construction algorithm has been selected, `buildHLBVH()` is called to build the tree. The other three construction algorithms are all handled by `buildRecursive()`. The initial calls to these functions are passed all the primitives to be stored. Each returns a pointer to the root of a BVH for the primitives they are given, which is represented with the `BVHBuildNode` structure and the total number of nodes created, which is stored in `totalNodes`. This value is represented by a `std::atomic` variable so that it can be modified correctly by multiple threads executing in parallel.
][
  如果选择 HLBVH 作为构建算法，则调用 `buildHLBVH()` 来构建树。其他三种构建算法都由 `buildRecursive()` 处理。初始调用这些函数时，需传递要存储的所有图元。每个函数返回一个指向其给定图元的 BVH 根节点的指针，该节点由 `BVHBuildNode` 结构表示，并且创建的节点总数存储在 `totalNodes` 中。 由于它是一个 `std::atomic` 变量，因此可以由多个并行执行的线程正确修改。
]

#block(sticky: true)[#raw("<<Build BVH according to selected splitMethod>>=")] <fragment-BuildBVHaccordingtoselectedmonosplitMethod-0>
#block(breakable: false)[
```cpp
std::atomic<int> totalNodes{0};
if (splitMethod == SplitMethod::HLBVH) {
    root = buildHLBVH(alloc, bvhPrimitives, &totalNodes, orderedPrims);
} else {
    std::atomic<int> orderedPrimsOffset{0};
    root = buildRecursive(threadAllocators,
                          pstd::span<BVHPrimitive>(bvhPrimitives),
                          &totalNodes, &orderedPrimsOffset, orderedPrims);
}
primitives.swap(orderedPrims);
```
]


#parec[
  Each `BVHBuildNode` represents a node of the BVH. All nodes store a `Bounds3f` that represents the bounds of all the children beneath the node. Each interior node stores pointers to its two children in `children`. Interior nodes also record the coordinate axis along which primitives were partitioned for distribution to their two children; this information is used to improve the performance of the traversal algorithm. Leaf nodes record which primitive or primitives are stored in them; the elements of the `BVHAggregate::primitives` array from the offset `firstPrimOffset` up to but not including `firstPrimOffset + nPrimitives` are the primitives in the leaf.(This is why the primitives array needs to be reordered—so that this representation can be used, rather than, for example, storing a variable-sized array of primitive indices at each leaf node.)
][
  每个 `BVHBuildNode` 表示一个节点，保存覆盖其下方所有图元的 `Bounds3f`。内部节点的 `children` 保存两个子节点指针，并记录将图元分给两子树时使用的坐标轴，以改进后续遍历性能。叶节点则通过 `BVHAggregate::primitives` 中从 `firstPrimOffset` 到 `firstPrimOffset + nPrimitives` 的半开区间表示所含图元。为此需要重排图元数组；否则，例如就得在每个叶节点中另存一个长度可变的图元索引数组。
]

#block(sticky: true)[#raw("<<BVHBuildNode Definition>>=")] <fragment-BVHBuildNodeDefinition-0>
#block(breakable: false)[
```cpp
struct BVHBuildNode {
    <<BVHBuildNode Public Methods>>
    Bounds3f bounds;
    BVHBuildNode *children[2];
    int splitAxis, firstPrimOffset, nPrimitives;
};
```
] <BVHBuildNode>


#parec[
  We will distinguish between leaf and interior nodes by whether their child pointers have the value `nullptr` or not, respectively.
][
  叶节点的子指针为 `nullptr`，内部节点的子指针则不是；据此区分两类节点。
]

#block(sticky: true)[#raw("<<BVHBuildNode Public Methods>>=")] <fragment-BVHBuildNodePublicMethods-0>
#block(breakable: false)[
```cpp
void InitLeaf(int first, int n, const Bounds3f &b) {
    firstPrimOffset = first;
    nPrimitives = n;
    bounds = b;
    children[0] = children[1] = nullptr;
}
```
]

#parec[
  The `InitInterior()` method requires that the two child nodes already have been created, so that their pointers can be passed in. This requirement makes it easy to compute the bounds of the interior node, since the children bounds are immediately available.
][
  `InitInterior()` 方法要求两个子节点已经被创建，以便可以传递它们的指针。由于子节点的包围范围已知，便可直接计算内部节点的包围范围。
]


#block(sticky: true)[#raw("<<BVHBuildNode Public Methods>>+=")] <fragment-BVHBuildNodePublicMethods-1>
#block(breakable: false)[
```cpp
void InitInterior(int axis, BVHBuildNode *c0, BVHBuildNode *c1) {
    children[0] = c0;
    children[1] = c1;
    bounds = Union(c0->bounds, c1->bounds);
    splitAxis = axis;
    nPrimitives = 0;
}
```
]

#parec[
  In addition to the allocators used for BVH nodes and the array of `BVHPrimitive` structures, `buildRecursive()` takes a pointer `totalNodes` that is used to track the total number of BVH nodes that have been created; this value makes it possible to allocate exactly the right number of the more compact `LinearBVHNode`s later.
][
  除 BVH 节点所用的分配器和 `BVHPrimitive` 数组外，`buildRecursive()` 还接受指针 `totalNodes`，用于记录已创建的 BVH 节点总数。之后分配紧凑的 `LinearBVHNode` 数组时，就能恰好分配所需数量。
]

#parec[
  The `orderedPrims` array is used to store primitive references as primitives are stored in leaf nodes of the tree. It is initially allocated with enough entries to store all the primitives, though all entries are `nullptr`. When a leaf node is created, `buildRecursive()` claims enough entries in the array for its primitives; `orderedPrimsOffset` starts at 0 and keeps track of where the next free entry is. It, too, is an atomic variable so that multiple threads can allocate space from the array concurrently. Recall that when tree construction is finished, `BVHAggregate::primitives` is replaced with the ordered primitives array created here.
][
  `orderedPrims` 在创建叶节点时保存相应图元引用。它预先分配足以容纳全部图元的空间，初始条目均为空。创建叶节点时，`buildRecursive()` 为其中的图元预留一段空间；从 0 开始的 `orderedPrimsOffset` 记录下一个空闲位置。该偏移量也使用原子变量，使多个线程能够并发预留区间。树建成后，`BVHAggregate::primitives` 会被这里的有序图元数组替换。
]


#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>+=")] <fragment-BVHAggregateMethodDefinitions-1>
#block(breakable: false)[
```cpp
BVHBuildNode *BVHAggregate::buildRecursive(
        ThreadLocal<Allocator> &threadAllocators,
        pstd::span<BVHPrimitive> bvhPrimitives,
        std::atomic<int> *totalNodes, std::atomic<int> *orderedPrimsOffset,
        std::vector<Primitive> &orderedPrims) {
    Allocator alloc = threadAllocators.Get();
    BVHBuildNode *node = alloc.new_object<BVHBuildNode>();
    <<Initialize BVHBuildNode for primitive range>>
    return node;
}
```
]


#parec[
  If `bvhPrimitives` has only a single primitive, then the recursion has bottomed out and a leaf node is created. Otherwise, this method partitions its elements using one of the partitioning algorithms and reorders the array elements so that they represent the partitioned subsets. If the partitioning is successful, these two primitive sets are in turn passed to recursive calls that will themselves return pointers to nodes for the two children of the current node.
][
  若 `bvhPrimitives` 只有一个图元，递归到达终点，创建叶节点。否则，用某种划分算法对元素分组，并重排数组，使各段对应划分后的子集。划分成功后，将两个图元集合分别传给递归调用，获得当前节点的两个子节点。
]

#block(sticky: true)[#raw("<<Initialize BVHBuildNode for primitive range>>=")] <fragment-InitializemonoBVHBuildNodeforprimitiverange-0>
#block(breakable: false)[
```cpp
++*totalNodes;
<<Compute bounds of all primitives in BVH node>>
if (bounds.SurfaceArea() == 0 || bvhPrimitives.size() == 1) {
    <<Create leaf BVHBuildNode>>
} else {
    <<Compute bound of primitive centroids and choose split dimension dim>>
    <<Partition primitives into two sets and build children>>
}
```
]

#parec[
  The primitive bounds will be needed regardless of whether an interior or leaf node is created, so they are computed before that determination is made.
][
  无论最终创建内部节点还是叶节点，都需要图元的包围范围，因此在做出选择前先计算它。
]

#block(sticky: true)[#raw("<<Compute bounds of all primitives in BVH node>>=")] <fragment-ComputeboundsofallprimitivesinBVHnode-0>
#block(breakable: false)[
```cpp
Bounds3f bounds;
for (const auto &prim : bvhPrimitives)
    bounds = Union(bounds, prim.bounds);
```
]
#parec[
  At leaf nodes, the primitives overlapping the leaf are appended to the `orderedPrims` array and a leaf node object is initialized. Because `orderedPrimsOffset` is a `std::atomic` variable and `fetch_add()` is an atomic operation, multiple threads can safely perform this operation concurrently without further synchronization: each one is able to allocate its own span of the `orderedPrimitives` array that it can then safely write to.
][
  创建叶节点时，将其中图元写入 `orderedPrims`，再初始化节点。`orderedPrimsOffset` 是原子变量，`fetch_add()` 是原子操作，因此多个线程无需额外同步即可并发预留各自的数组区间，并安全地写入。
]

#block(sticky: true)[#raw("<<Create leaf BVHBuildNode>>=")] <fragment-CreateleafmonoBVHBuildNode-0>
#block(breakable: false)[
```cpp
int firstPrimOffset = orderedPrimsOffset->fetch_add(bvhPrimitives.size());
for (size_t i = 0; i < bvhPrimitives.size(); ++i) {
    int index = bvhPrimitives[i].primitiveIndex;
    orderedPrims[firstPrimOffset + i] = primitives[index];
}
node->InitLeaf(firstPrimOffset, bvhPrimitives.size(), bounds);
return node;
```
]

#parec[
  For interior nodes, the collection of primitives must be partitioned between the two children's subtrees. Given $n$ primitives, there are in general $2^(n - 1) - 2$ possible ways to partition them into two non-empty groups. In practice when building BVHs, one generally considers partitions along a coordinate axis, meaning that there are about $3 n$ candidate partitions. (Along each axis, each primitive may be put into the first partition or the second partition.)
][
  对内部节点，需要将图元集合分给两个子树。给定 $n$ 个图元，原文给出的非空两组划分方式数为 $2^(n-1)-2$。实际构建 BVH 时，通常只考虑沿坐标轴划分，因而约有 $3 n$ 个候选划分。（沿每根轴，各图元可被分到第一组或第二组。）
]

#parec[
  Here, we choose just one of the three coordinate axes to use in partitioning the primitives. We select the axis with the largest extent of bounding box centroids for the primitives in `bvhPrimitives`. An alternative would be to try partitioning the primitives along all three axes and select the one that gave the best result, but in practice this approach works well. This approach gives good partitions in many scenes; @fig:bvh-centroid-axis illustrates the strategy.
][
  这里仅选取三个坐标轴中的一个进行划分：计算 `bvhPrimitives` 内各图元包围盒的质心，选择这些质心分布跨度最大的轴。（也可以尝试三根轴并选最佳结果，但这里的做法在实践中已经有效。）它在许多场景中都能给出良好划分，见@fig:bvh-centroid-axis。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f04.svg"),
  caption: [
    #ez_caption[
      *Choosing the Axis along which to Partition Primitives.* The `BVHAggregate` chooses an axis along which to partition the primitives based on which axis has the largest range of the centroids of the primitives' bounding boxes. Here, in two dimensions, their extent is largest along the $y$ axis (filled points on the axes), so the primitives will be partitioned in $y$.
    ][
      *选择沿哪个轴对图元进行划分。*`BVHAggregate` 会根据图元包围盒的质心在哪个轴上的范围最大来选择划分图元的轴。在这里，在二维空间中，它们在 $y$ 轴上的范围最大（轴上填充的点表示范围），因此图元将沿 $y$ 轴进行划分。
    ]
  ],
)<bvh-centroid-axis>


#parec[
  The general goal is to select a partition of primitives that does not have too much overlap of the bounding boxes of the two resulting primitive sets—if there is substantial overlap, then it will more frequently be necessary to traverse both children's subtrees when traversing the tree, requiring more computation than if it had been possible to more effectively prune away collections of primitives. This idea of finding effective primitive partitions will be made more rigorous shortly, in the discussion of the surface area heuristic.
][
  总体目标是让划分后两组图元的包围盒尽量少重叠。重叠越大，遍历时越可能需要访问两棵子树，无法有效排除整组图元，从而增加计算。稍后讨论表面积启发式时，会更严格地表述这一目标。
]

#block(sticky: true)[#raw("<<Compute bound of primitive centroids and choose split dimension dim>>=")] <fragment-Computeboundofprimitivecentroidsandchoosesplitdimensionmonodim-0>
#block(breakable: false)[
```cpp
Bounds3f centroidBounds;
for (const auto &prim : bvhPrimitives)
    centroidBounds = Union(centroidBounds, prim.Centroid());
int dim = centroidBounds.MaxDimension();
```
]


#parec[
  If all the centroid points are at the same position (i.e., the centroid bounds have zero volume), then recursion stops and a leaf node is created with the primitives; none of the splitting methods here is effective in that (unusual) case. The primitives are otherwise partitioned using the chosen method and passed to two recursive calls to buildRecursive().
][
  若所有质心都在同一位置（原文括注为质心包围范围体积为零），递归就停止，将这些图元组成叶节点；这里的划分方法在这种少见情况下都无效。否则，按选定方法划分，再分别递归调用 `buildRecursive()`。
]


#block(sticky: true)[#raw("<<Partition primitives into two sets and build children>>=")] <fragment-Partitionprimitivesintotwosetsandbuildchildren-0>
#block(breakable: false)[
```cpp
if (centroidBounds.pMax[dim] == centroidBounds.pMin[dim]) {
    <<Create leaf BVHBuildNode>>
} else {
    int mid = bvhPrimitives.size() / 2;
    <<Partition primitives based on splitMethod>>
    BVHBuildNode *children[2];
    <<Recursively build BVHs for children>>
    node->InitInterior(dim, children[0], children[1]);
}
```
]

#parec[
  The two recursive calls access independent data, other than when they allocate space in the `orderedPrims` array by incrementing `orderedPrimsOffset`, which we already have seen is thread safe. Therefore, when there are a reasonably large number of active primitives, those calls can be performed in parallel, which improves the performance of BVH construction.
][
  两次递归调用操作的数据彼此独立，只有通过增加 `orderedPrimsOffset` 预留数组区间时共享该原子变量，而这一操作已保证线程安全。因此，待处理图元足够多时，可以并行构建两棵子树，提高建树性能。
]


#block(sticky: true)[#raw("<<Recursively build BVHs for children>>=")] <fragment-RecursivelybuildBVHsformonochildren-0>
#block(breakable: false)[
```cpp
if (bvhPrimitives.size() > 128 * 1024) {
    <<Recursively build child BVHs in parallel>>
} else {
    <<Recursively build child BVHs sequentially>>
}
```
]

#parec[
  A parallel `for` loop over two items is sufficient to expose the available parallelism. With `pbrt`'s implementation of `ParallelFor()`, the current thread will end up handling the first recursive call, while another thread, if available, can take the second. `ParallelFor()` does not return until all the loop iterations have completed, so we can safely proceed, knowing that both `children` are fully initialized when it does.
][
  一个只有两次迭代的并行 `for` 循环就足以利用这里的并行性。`pbrt` 的 `ParallelFor()` 会让当前线程处理第一次递归调用，另一线程若可用，则处理第二次。它会等待所有迭代结束再返回，因此返回时两个 `children` 均已完整初始化，可以安全继续。
]

#block(sticky: true)[#raw("<<Recursively build child BVHs in parallel>>=")] <fragment-RecursivelybuildchildBVHsinparallel-0>
#block(breakable: false)[
```cpp
ParallelFor(0, 2, [&](int i) {
    if (i == 0)
        children[0] =
            buildRecursive(threadAllocators, bvhPrimitives.subspan(0, mid),
                           totalNodes, orderedPrimsOffset, orderedPrims);
    else
        children[1] =
            buildRecursive(threadAllocators, bvhPrimitives.subspan(mid),
                           totalNodes, orderedPrimsOffset, orderedPrims);
});
```
]

#parec[
  The code for the non-parallel case, `<<Recursively build child BVHs sequentially>>`, is equivalent, just without the parallel `for` loop. We have therefore not included it here.
][
  非并行情况下的代码 `<<Recursively build child BVHs sequentially>>` 是等效的，只是没有并行 `for` 循环。因此，我们在此不包括它。
]

#parec[
  We also will not include the code fragment `<<Partition primitives based on splitMethod>>` here; it just uses the value of `BVHAggregate::splitMethod` to determine which primitive partitioning scheme to use. These three schemes will be described in the following few pages.
][
  我们也不会在此处包括代码片段 `<<Partition primitives based on splitMethod>>`；它只是使用 `BVHAggregate::splitMethod` 的值来确定使用哪个图元分区方案。接下来的几页将描述这三种方案。
]

#parec[
  A simple `splitMethod` is `Middle`, which first computes the midpoint of the primitives' centroids along the splitting axis. This method is implemented in the fragment `<<Partition primitives through node's midpoint>>`. The primitives are classified into the two sets, depending on whether their centroids are above or below the midpoint. This partitioning is easily done with the `std::partition()` C++ standard library function, which takes a range of elements in an array and a comparison function and orders the elements in the array so that all the elements that return `true` for the given predicate function appear in the range before those that return `false` for it. `std::partition()` returns a pointer to the first element that had a `false` value for the predicate. Figure 7.5 illustrates this approach, including cases where it does and does not work well.
][
  简单的 `Middle` 划分先求各图元包围盒质心沿划分轴分布范围的中点，由片段 ⟨Partition primitives through node’s midpoint⟩ 实现。然后根据质心位于中点哪一侧，将图元分为两组。标准库函数 `std::partition()` 接受数组区间与谓词，重排元素，使谓词为 `true` 的元素位于为 `false` 的元素之前，并返回第一个为 `false` 的元素位置。@fig:bvh-midpoint 展示了这种方法表现好与不好的例子。
]

#parec[
  If the primitives all have large overlapping bounding boxes, this splitting method may fail to separate the primitives into two groups. In that case, execution falls through to the `SplitMethod::EqualCounts` approach to try again.
][
  若图元的包围盒很大且互相重叠，这种方法可能无法分成两个组。此时控制流会贯穿到 `SplitMethod::EqualCounts` 分支，再尝试一次。
]


#block(sticky: true)[#raw("<<Partition primitives through node’s midpoint>>=")] <fragment-Partitionprimitivesthroughnodesmidpoint-0>
#block(breakable: false)[
```cpp
Float pmid = (centroidBounds.pMin[dim] + centroidBounds.pMax[dim]) / 2;
auto midIter =
    std::partition(bvhPrimitives.begin(), bvhPrimitives.end(),
        [dim, pmid](const BVHPrimitive &pi) {
            return pi.Centroid()[dim] < pmid;
        });
mid = midIter - bvhPrimitives.begin();
if (midIter != bvhPrimitives.begin() && midIter != bvhPrimitives.end())
    break;
```
]

#parec[
  When `splitMethod` is `SplitMethod::EqualCounts`, the `<<Partition primitives into equally sized subsets>>` fragment runs. It partitions the primitives into two equal-sized subsets such that the first half of the $n$ of them are the $n \/ 2$ with smallest centroid coordinate values along the chosen axis, and the second half are the ones with the largest centroid coordinate values. While this approach can sometimes work well, the case in Figure 7.5(b) is one where this method also fares poorly.
][
  `SplitMethod::EqualCounts` 执行 ⟨Partition primitives into equally sized subsets⟩。它将图元分成数量相等的两组：前一半是沿选定轴质心坐标较小的 $n/2$ 个，后一半是坐标较大的那些。这种方法有时有效，但在@fig:bvh-midpoint(b) 的情形下同样表现不佳。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f05.svg"),
  caption: [#ez_caption[
      *Splitting Primitives Based on the Midpoint of Centroids on an Axis.*(a) For some distributions of primitives, such as the one shown here, splitting based on the midpoint of the centroids along the chosen axis (thick vertical line) works well. (The bounding boxes of the two resulting primitive groups are shown with dashed lines.) (b) For distributions like this one, the midpoint is a suboptimal choice; the two resulting bounding boxes overlap substantially. (c) If the same group of primitives from (b) is instead split along the line shown here, the resulting bounding boxes are smaller and do not overlap at all, leading to better performance when rendering.
    ][
      *基于轴上质心中点分割图元。* (a) 对于某些图元分布，如图所示，基于沿选定轴的质心中点（粗垂直线）进行分割效果很好。（两个结果图元组的包围盒用虚线表示。）(b) 对于像这样的分布，中点是一个次优选择；两个结果包围盒大幅重叠。(c) 如果从 (b) 的相同图元组改为沿图示线分割，结果包围盒更小且完全不重叠，从而在渲染时提高性能。
    ]],
)<bvh-midpoint>

#parec[
  This scheme is also easily implemented with a standard library call, `std::nth_element()`. It takes a start, middle, and ending iterator as well as a comparison function. It orders the array so that the element at the middle iterator is the one that would be there if the array was fully sorted, and such that all the elements before the middle one compare to less than the middle element and all the elements after it compare to greater than it. This ordering can be done in $O(n)$ time, with $n$ the number of elements, which is more efficient than the $O(n log n)$ cost of completely sorting the array.
][
  这一方案可用标准库函数 `std::nth_element()` 实现。它接受起始、中间和结束迭代器，以及比较函数，重排数组，使中间位置的元素与完全排序后的该位置相同，前后两段分别位于比较次序的较小侧和较大侧。对于 $n$ 个元素，这只需 $O(n)$ 时间，比完全排序的 $O(n log n)$ 更高效。
]


#block(sticky: true)[#raw("<<Partition primitives into equally sized subsets>>=")] <fragment-Partitionprimitivesintoequallysizedsubsets-0>
#block(breakable: false)[
```cpp
mid = bvhPrimitives.size() / 2;
std::nth_element(bvhPrimitives.begin(), bvhPrimitives.begin() + mid,
                 bvhPrimitives.end(),
    [dim](const BVHPrimitive &a, const BVHPrimitive &b) {
        return a.Centroid()[dim] < b.Centroid()[dim];
    });
```
]


=== #ez_caption[The Surface Area Heuristic][表面积启发式]
<the-surface-area-heuristic>


#parec[
  The two primitive partitioning approaches described so far can work well for some distributions of primitives, but they often choose partitions that perform poorly in practice, leading to more nodes of the tree being visited by rays and hence unnecessarily inefficient ray–primitive intersection computations at rendering time. Most of the best current algorithms for building acceleration structures for ray tracing are based on the "surface area heuristic" (SAH), which provides a well-grounded cost model for answering questions like "which of a number of partitions of primitives will lead to a better BVH for ray–primitive intersection tests?" or "which of a number of possible positions to split space in a spatial subdivision scheme will lead to a better acceleration structure?"
][
  前两种图元划分方法在某些分布下有效，但实际中往往选出较差的划分，使射线访问更多节点，增加不必要的求交开销。优秀的加速结构构建算法大多以表面积启发式（SAH）为基础。它提供有依据的成本模型，用来判断哪种图元划分能生成求交效率更高的 BVH，或空间划分中的哪个分割位置能得到更好的加速结构。
]

#parec[
  The SAH model estimates the computational expense of performing ray intersection tests, including the time spent traversing nodes of the tree and the time spent on ray–primitive intersection tests for a particular partitioning of primitives. Algorithms for building acceleration structures can then follow the goal of minimizing total cost. Typically, a greedy algorithm is used that minimizes the cost for each single node of the hierarchy being built individually.
][
  SAH 模型估计特定划分下的求交计算成本，包括遍历树节点和射线与图元求交的时间。构建算法据此以最小化总成本为目标。通常采用贪心策略，对当前构建的每个节点分别最小化成本。
]

#parec[
  The ideas behind the SAH cost model are straightforward: at any point in building an adaptive acceleration structure (primitive subdivision or spatial subdivision), we could just create a leaf node for the current region and geometry. In that case, any ray that passes through this region will be tested against all the overlapping primitives and will incur a cost of
][
  SAH 成本模型的思路很直接：构建自适应加速结构时，无论采用图元划分还是空间划分，都可以随时把当前区域及几何体做成叶节点。此时，经过该区域的射线需要测试所有与区域重叠的图元，成本为
]
$ sum_(i = 1)^n t_("isect") (i) $
#parec[
  where $n$ is the number of primitives and $t_("isect") (i)$ is the time to compute a ray–object intersection with the $i$ th primitive.
][
  其中 $n$ 是图元的数量， $t_("isect")(i)$ 是计算光线与第 $i$ 个图元相交的时间。
]

#parec[
  The other option is to split the region. In that case, rays will incur the cost
][
  另一种选择是分割区域。在这种情况下，光线将产生成本
]
$
  c (A , B) = t_("trav") + p_A sum_(i = 1)^(n_A) t_("isect")(a_i) + p_B sum_(i = 1)^(n_B) t_("isect")(b_i)
$<sah>

#parec[
  where $t_("trav")$ is the time it takes to traverse the interior node and determine which of the children the ray passes through, $p_A$ and $p_B$ are the probabilities that the ray passes through each of the child nodes (assuming binary subdivision), $a_i$ and $b_i$ are the indices of primitives in the two child nodes, and $n_A$ and $n_B$ are the number of primitives that overlap the regions of the two child nodes, respectively. The choice of how primitives are partitioned affects the values of the two probabilities as well as the set of primitives on each side of the split.
][
  其中，$t_("trav")$ 是遍历内部节点并确定射线经过哪些子节点的时间；$p_A$、$p_B$ 是经过各子节点的概率（假设每次分为两个子节点）；$a_i$、$b_i$ 是两子节点中图元的索引，$n_A$、$n_B$ 分别为与两区域重叠的图元数。划分方式既影响这两个概率，也影响两侧图元集合。
]

#parec[
  In `pbrt`, we will make the simplifying assumption that $t_("isect") (i)$ is the same for all the primitives; this assumption is probably not too far from reality, and any error that it introduces does not seem to affect the performance of accelerators very much. Another possibility would be to add a method to `Primitive` that returned an estimate of the number of processing cycles that its intersection test requires.
][
  在 `pbrt` 中，我们假设所有图元的 $t_("isect") (i)$ 是相同的；这个假设可能与现实相差不大，并且其引入的误差似乎对加速器性能影响不大。 另一种可能性是为 `Primitive` 添加一种方法，该方法返回其相交测试所需的处理周期数的估计值。
]

#parec[
  The probabilities $p_A$ and $p_B$ can be computed using ideas from geometric probability. It can be shown that for a convex volume $A$ contained in another convex volume $B$, the conditional probability that a uniformly distributed random ray passing through $B$ will also pass through $A$ is the ratio of their surface areas, $s_A$ and $s_B$ :
][
  概率 $p_A$、$p_B$ 可用几何概率求得。对于包含在凸体 $B$ 中的凸体 $A$，已知均匀分布的随机射线经过 $B$，它也经过 $A$ 的条件概率，等于两者表面积 $s_A$ 与 $s_B$ 的比值：
]


$ p (A divides B) = s_A / s_B upright(".") $


#parec[
  Because we are interested in the cost for rays passing through the node, we can use this result directly. Thus, if we are considering refining a region of space $A$ such that there are two new subregions with bounds $B$ and $C$ (@fig:bvh-abc-probabilities), the probability that a ray passing through $A$ will also pass through either of the subregions is easily computed.
][
  我们关心的正是已穿过当前节点的射线的成本，因此可以直接使用这一结果。例如，将区域 $A$ 细分为包围范围为 $B$、$C$ 的两个子区域（@fig:bvh-abc-probabilities）后，射线从 $A$ 穿过各子区域的概率就容易计算。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f06.svg"),
  caption: [
    #ez_caption[If a node of the bounding hierarchy with surface area
      $s_A$ is split into two children with surface areas $s_B$ and $s_C$,
      the probabilities that a ray passing through $A$ also passes through
      $B$ and $C$ are given by $s_B \/ s_A$ and $s_C \/ s_A$, respectively.][如果一个表面面积为 $s_A$
      的包围体层次结构节点被划分成两个子节点，其表面面积为 $s_B$ 和
      $s_C$，那么已知射线穿过 $A$，它分别穿过 $B$、$C$ 的条件概率为 $s_B \/ s_A$
      和 $s_C \/ s_A$。]
  ],
)<bvh-abc-probabilities>
#parec[
  When `splitMethod` has the value `SplitMethod::SAH`, the SAH is used for building the BVH; a partition of the primitives along the chosen axis that gives a minimal SAH cost estimate is found by considering a number of candidate partitions. (This is the default `SplitMethod`, and it creates the most efficient hierarchies of the partitioning options.) However, once it has refined down to two primitives, the implementation switches over to directly partitioning them in half. The incremental computational cost for applying the SAH at that point is not beneficial.
][
  当 `splitMethod` 为 `SplitMethod::SAH` 时，沿选定轴考察若干候选划分，选择 SAH 估计成本最小者。这是默认方法，也是这里几种选项中能生成最高效层次结构的方法。不过，当只剩两个图元时，直接将它们各分到一侧；此时再计算 SAH 的额外成本已不值得。
]

#block(sticky: true)[#raw("<<Partition primitives using approximate SAH>>=")] <fragment-PartitionprimitivesusingapproximateSAH-0>
#block(breakable: false)[
```cpp
if (bvhPrimitives.size() <= 2) {
    <<Partition primitives into equally sized subsets>>
} else {
    <<Allocate BVHSplitBucket for SAH partition buckets>>
    <<Initialize BVHSplitBucket for SAH partition buckets>>
    <<Compute costs for splitting after each bucket>>
    <<Find bucket to split at that minimizes SAH metric>>
    <<Either create leaf or split primitives at selected SAH bucket>>
}
```
]


#parec[
  Rather than exhaustively considering all $2 n$ possible partitions along the axis, computing the SAH for each to select the best, the implementation here instead divides the range along the axis into a small number of buckets of equal extent. It then only considers partitions at bucket boundaries. This approach is more efficient than considering all partitions while usually still producing partitions that are nearly as effective. This idea is illustrated in @fig:bvh-sah-buckets .
][
  这里不逐一考察轴上所有 $2 n$ 个候选划分并计算 SAH，而是将该轴的范围分为少量等宽的桶，只考虑桶之间的边界。这更高效，通常又能得到几乎同样好的划分，见@fig:bvh-sah-buckets。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f07.svg"),
  caption: [
    #ez_caption[
      Choosing a Splitting Plane with the Surface Area
      Heuristic for BVHs. The projected extent of primitive bounds
      centroids is projected onto the chosen split axis. Each primitive is
      placed in a bucket along the axis based on the centroid of its
      bounds. The implementation then estimates the cost for splitting the
      primitives using the planes at each of the bucket boundaries (solid
      vertical lines); whichever one gives the minimum cost per the
      surface area heuristic is selected.
    ][
      使用表面积启发式选择 BVH
      的分割平面。将各图元包围盒的质心投影到所选的划分轴上，并根据投影位置分入各桶。然后估计在各桶边界（实线竖线）处划分图元的成本，选择 SAH 成本最小的平面。
    ]
  ],
)<bvh-sah-buckets>


#block(sticky: true)[#raw("<<BVHSplitBucket Definition>>=")] <fragment-BVHSplitBucketDefinition-0>
#block(breakable: false)[
```cpp
struct BVHSplitBucket {
    int count = 0;
    Bounds3f bounds;
};
```
] <BVHSplitBucket>


#parec[
  We have found that 12 buckets usually work well in practice. An improvement may be to increase this value when there are many primitives and to decrease it when there are few.
][
  我们发现 12 个桶通常在实践中效果很好。一个改进可能是在有很多图元时增加这个值，而在图元较少时减少它。
]

#block(sticky: true)[#raw("<<Allocate BVHSplitBucket for SAH partition buckets>>=")] <fragment-AllocatemonoBVHSplitBucketforSAHpartitionbuckets-0>
#block(breakable: false)[
```cpp
constexpr int nBuckets = 12;
BVHSplitBucket buckets[nBuckets];
```
]


#parec[
  For each primitive, the following fragment determines the bucket that its centroid lies in and updates the bucket's bounds to include the primitive's bounds.
][
  对于每个图元，以下片段确定其质心所在的桶，并扩展桶的包围盒，使其包含该图元的包围盒。
]

#block(sticky: true)[#raw("<<Initialize BVHSplitBucket for SAH partition buckets>>=")] <fragment-InitializemonoBVHSplitBucketforSAHpartitionbuckets-0>
#block(breakable: false)[
```cpp
for (const auto &prim : bvhPrimitives) {
    int b = nBuckets * centroidBounds.Offset(prim.Centroid())[dim];
    if (b == nBuckets) b = nBuckets - 1;
    buckets[b].count++;
    buckets[b].bounds = Union(buckets[b].bounds, prim.bounds);
}
```
]


#parec[
  For each bucket, we now have a count of the number of primitives and the bounds of all of their respective bounding boxes. We want to use the SAH to estimate the cost of splitting at each of the bucket boundaries. The fragment below loops over all the buckets and initializes the `cost[i]` array to store the estimated SAH cost for splitting after the $i$ th bucket. (It does not consider a split after the last bucket, which by definition would not split the primitives.)
][
  现在，每个桶都有图元数量及这些图元的包围范围。接下来用 SAH 估计在各桶边界处划分的成本，并将第 $i$ 个桶后方的划分成本存入数组。（最后一个桶之后不作为候选，因为那样无法分开图元。）
]

#parec[
  We arbitrarily set the estimated intersection cost to 1, and then set the estimated traversal cost to $1 \/ 2$. (One of the two of them can always be set to 1 since it is the relative, rather than absolute, magnitudes of the estimated traversal and intersection costs that determine their effect.) However, not only is the absolute amount of computation necessary for node traversal—a ray–bounding box intersection—much less than the amount of computation needed to intersect a ray with a shape, the full cost of a shape intersection test is even higher. It includes the overhead of at least two instances of dynamic dispatch (one or more via #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive]s and one via a `Shape`), the cost of computing all the geometric information needed to initialize a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] if an intersection is found, and any resulting costs from possibly applying additional transformations and interpolating animated transformations.
][
  先任意将求交成本定为 1，再将遍历成本定为 $1/2$。二者总有一个可归一化为 1，因为决定效果的是相对大小。节点遍历所需的射线—包围盒测试，其计算量本就远少于射线—形状求交；完整的形状求交还包括至少两次动态分派（通过 `Primitive` 一次或多次，再通过 `Shape` 一次）、命中后初始化 `SurfaceInteraction` 所需的几何计算，以及可能的额外变换和动画变换插值。
]

#parec[
  We have intentionally underestimated the performance ratio between these two costs because the raw amount of computation each performs does not measure their full expense. With a lower traversal cost, the resulting BVHs would be deeper and require more nodes. For complex scenes, this additional memory use may be undesirable. Even for simpler scenes, visiting more nodes when a ray is traced will generally incur the cost of cache misses, which not only may reduce performance for that ray, but may harm future performance from displacing other useful data from the cache. We have found the $2 : 1$ ratio that we have used here to make a reasonable trade-off between all of these issues.
][
  这里有意低估两者的成本比，因为单看算术计算量不足以反映完整开销。遍历成本设得更低，会生成更深、节点更多的 BVH，增加复杂场景的内存开销。即使场景简单，访问更多节点也往往引发缓存未命中；这不仅拖慢当前射线，还可能挤出其他有用数据，影响后续计算。实践表明，求交与遍历成本取 $2:1$ 是较合理的权衡。
]

#block(breakable: false)[
#parec[
  In order to be able to choose a split in linear time, the implementation first performs a forward scan over the buckets and then a backward scan over the buckets that incrementally compute each bucket's cost.#footnote[Previous versions of `pbrt` instead computed these values from scratch for each candidate split, which resulted in $O(n^2)$ performance. Even with the small $n$ here, we have found that this implementation speeds up BVH construction by approximately 2×.] There is one fewer candidate split than the number of buckets, since all splits are between pairs of buckets.
][
  为在线性时间内选出划分，先从前向后扫描各桶，再从后向前扫描，增量计算成本。#footnote[上一版 `pbrt` 为每个候选划分从头计算这些量，复杂度为 $O(n^2)$。即使这里的 $n$ 很小，新实现也使 BVH 构建速度提高约 2 倍。]划分位置位于相邻桶之间，因此候选划分比桶数少一个。
]
]


#block(sticky: true)[#raw("<<Compute costs for splitting after each bucket>>=")] <fragment-Computecostsforsplittingaftereachbucket-0>
#block(breakable: false)[
```cpp
constexpr int nSplits = nBuckets - 1;
Float costs[nSplits] = {};
<<Partially initialize costs using a forward scan over splits>>
<<Finish initializing costs using a backward scan over splits>>
```
]

#parec[
  The loop invariant is that `countBelow` stores the number of primitives that are below the corresponding candidate split, and `boundsBelow` stores their bounds. With these values in hand, the value of the first sum in @eqt:sah can be evaluated for each split.
][
  循环不变式是：`countBelow` 保存候选划分较小一侧的图元数，包围范围变量保存这些图元的包围盒。有了它们，就可以计算@eqt:sah 中与第一组对应的求和项。
]

#block(sticky: true)[#raw("<<Partially initialize costs using a forward scan over splits>>=")] <fragment-Partiallyinitializemonocostsusingaforwardscanoversplits-0>
#block(breakable: false)[
```cpp
int countBelow = 0;
Bounds3f boundBelow;
for (int i = 0; i < nSplits; ++i) {
    boundBelow = Union(boundBelow, buckets[i].bounds);
    countBelow += buckets[i].count;
    costs[i] += countBelow * boundBelow.SurfaceArea();
}
```
]

#parec[
  A similar backward scan over the buckets finishes initializing the `costs` array.
][
  对桶的类似向后扫描完成了 `costs` 数组的初始化。
]

#block(sticky: true)[#raw("<<Finish initializing costs using a backward scan over splits>>=")] <fragment-Finishinitializingmonocostsusingabackwardscanoversplits-0>
#block(breakable: false)[
```cpp
int countAbove = 0;
Bounds3f boundAbove;
for (int i = nSplits; i >= 1; --i) {
    boundAbove = Union(boundAbove, buckets[i].bounds);
    countAbove += buckets[i].count;
    costs[i - 1] += countAbove * boundAbove.SurfaceArea();
}
```
]


#parec[
  Given all the costs, a linear search over the potential splits finds the partition with minimum cost.
][
  给定所有成本，通过潜在分割的线性搜索找到具有最小成本的分区。
]

#block(sticky: true)[#raw("<<Find bucket to split at that minimizes SAH metric>>=")] <fragment-FindbuckettosplitatthatminimizesSAHmetric-0>
#block(breakable: false)[
```cpp
int minCostSplitBucket = -1;
Float minCost = Infinity;
for (int i = 0; i < nSplits; ++i) {
    <<Compute cost for candidate split and update minimum if necessary>>
}
<<Compute leaf cost and SAH split cost for chosen split>>
```
]

#parec[
  To find the best split, we evaluate a simplified version of @eqt:sah, neglecting the traversal cost and the division by the surface area of the bounding box of all the primitives to compute the probabilities $p_A$ and $p_B$ ; these have no effect on the choice of the best split. That cost is precisely what is stored in `costs`, so the split with minimum cost is easily found.
][
  寻找最佳划分时，可以简化@eqt:sah：暂时忽略共同的遍历成本，以及将两项除以整体包围盒表面积以得到概率 $p_A$、$p_B$ 的步骤。这些不影响哪个划分最优。`costs` 中保存的正是这种简化成本，只需找出最小值。
]

#block(sticky: true)[#raw("<<Compute cost for candidate split and update minimum if necessary>>=")] <fragment-Computecostforcandidatesplitandupdateminimumifnecessary-0>
#block(breakable: false)[
```cpp
if (costs[i] < minCost) {
    minCost = costs[i];
    minCostSplitBucket = i;
}
```
]

#parec[
  To compute the final SAH cost for a split, we need to divide by the surface area of the overall bounding box to compute the probabilities $p_A$ and $p_B$ before adding the estimated traversal cost, $1\/2$. Because we set the estimated intersection cost to 1 previously, the estimated cost for just creating a leaf node is equal to the number of primitives.
][
  计算最终 SAH 成本时，要除以整体包围盒的表面积，将两项转成概率权重，再加上估计的遍历成本 $1/2$。因为求交成本已设为 1，直接创建叶节点的估计成本就是图元数。
]

#block(sticky: true)[#raw("<<Compute leaf cost and SAH split cost for chosen split>>=")] <fragment-ComputeleafcostandSAHsplitcostforchosensplit-0>
#block(breakable: false)[
```cpp
Float leafCost = bvhPrimitives.size();
minCost = 1.f / 2.f + minCost / bounds.SurfaceArea();
```
]


#parec[
  If the chosen bucket boundary for partitioning has a lower estimated cost than building a node with the existing primitives or if more than the maximum number of primitives allowed in a node is present, the `std::partition()` function is used to do the work of reordering nodes in the `bvhPrimitives` array. Recall from its use earlier that it ensures that all elements of the array that return `true` from the given predicate appear before those that return `false` and that it returns a pointer to the first element where the predicate returns `false`.
][
  若所选桶边界的估计成本小于把全部现有图元做成叶节点的成本，或图元数量超过节点上限，就用 `std::partition()` 重排 `bvhPrimitives`。它保证谓词为 `true` 的元素排在为 `false` 的元素前，并返回第一个为 `false` 的元素位置。
]

#block(sticky: true)[#raw("<<Either create leaf or split primitives at selected SAH bucket>>=")] <fragment-EithercreateleaforsplitprimitivesatselectedSAHbucket-0>
#block(breakable: false)[
```cpp
if (bvhPrimitives.size() > maxPrimsInNode || minCost < leafCost) {
    auto midIter = std::partition(bvhPrimitives.begin(),
        bvhPrimitives.end(),
        [=](const BVHPrimitive &bp) {
            int b = nBuckets * centroidBounds.Offset(bp.Centroid())[dim];
            if (b == nBuckets) b = nBuckets - 1;
            return b <= minCostSplitBucket;
        });
    mid = midIter - bvhPrimitives.begin();
} else {
    <<Create leaf BVHBuildNode>>
}
```
]



=== #ez_caption[Linear Bounding Volume Hierarchies][线性包围体层次结构]
<linear-bounding-volume-hierarchies>
#parec[
  While building bounding volume hierarchies using the surface area heuristic gives very good results, that approach does have two disadvantages: first, many passes are taken over the scene primitives to compute the SAH costs at all the levels of the tree. Second, top-down BVH construction is difficult to parallelize well: the approach used in `buildRecursive()`—performing parallel construction of independent subtrees—suffers from limited independent work until the top few levels of the tree have been built, which in turn inhibits parallel scalability. (This second issue is particularly an issue on GPUs, which perform poorly if massive parallelism is not available.)
][
  虽然使用表面积启发式构建包围体层次结构可以得到非常好的结果，但这种方法有两个缺点：首先，需要多次遍历场景中的图元来计算树中所有层次的SAH成本。其次，自顶向下的BVH构建难以很好地并行化：在`buildRecursive()`中使用的方法——并行构建独立的子树——在树的前几层构建完成之前，独立工作的数量有限，从而抑制了并行扩展性。（第二个问题在GPU上尤其明显，如果没有大规模的并行性，GPU的性能会很差。）
]

#parec[
  #emph[Linear bounding volume hierarchies] (LBVHs) were developed to address these issues. With LBVHs, the tree is built with a small number of lightweight passes over the primitives; tree construction time is linear in the number of primitives. Further, the algorithm quickly partitions the primitives into clusters that can be processed independently. This processing can be fairly easily parallelized and is well suited to GPU implementation.
][
  #emph[线性包围体层次结构 ]（LBVH）是为了解决这些问题而开发的。使用LBVH，树的构建只需对图元进行少量的轻量级遍历；树的构建时间与图元的数量成线性关系。此外，该算法快速地将图元划分为可以独立处理的簇。这种处理可以相对容易地并行化，并且非常适合GPU实现。
]

#parec[
  The key idea behind LBVHs is to turn BVH construction into a sorting problem. Because there is no single ordering function for sorting multidimensional data, LBVHs are based on #emph[Morton codes], which map nearby points in $n$ dimensions to nearby points along the 1D line, where there is an obvious ordering function. After the primitives have been sorted, spatially nearby clusters of primitives are in contiguous segments of the sorted array.
][
  LBVH 的核心思路是把建树转化为排序。多维数据没有天然的单一排序方式，因此采用 Morton 编码，将 $n$ 维空间中相近的点映射到一维线上相近的位置；一维位置有明确次序。排序后，空间中相近的图元簇便处在数组的连续区间内。
]

#parec[
  Morton codes are based on a simple transformation: given $n$ -dimensional integer coordinate values, their Morton-coded representation is found by interleaving the bits of the coordinates in base 2. For example, consider a 2D coordinate $(x , y)$ where the bits of $x$ and $y$ are denoted by $x_i$ and $y_i$. The corresponding Morton-coded value is
][
  Morton 编码通过交错各坐标的二进制位，将 $n$ 维整数坐标编码。例如，二维坐标 $(x,y)$ 的各位分别记为 $x_i$、$y_i$，相应 Morton 编码为
]

$ dots.h.c y_3 x_3 y_2 x_2 y_1 x_1 y_0 x_0 . $

#parec[
  @fig:morton-curve-basics shows a plot of the 2D points in Morton order—note that they are visited along a path that follows a reversed "z" shape. (The Morton path is sometimes called "z-order" for this reason.) We can see that points with coordinates that are close together in 2D are generally close together along the Morton curve.#footnote[Many GPUs store texture images in memory using a Morton layout. One advantage of doing so is that when performing bilinear interpolation between four texel values, the values are much more likely to be close together in memory than if the texture is laid out in scanline order. In turn, texture cache performance benefits.]
][
  @fig:morton-curve-basics 按 Morton 顺序连接二维点。路径呈反向的“z”形，因此 Morton 次序也称 Z 序。二维坐标相近的点，在 Morton 曲线上通常也相近。#footnote[许多 GPU 用 Morton 布局存储纹理图像。对四个纹素做双线性插值时，它们在内存中彼此接近的概率比扫描线布局更高，因而有利于纹理缓存性能。]
]


#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f08.svg"),
  caption: [
    #ez_caption[
      The Order That Points Are Visited along the Morton Curve. Coordinate values along the $x$ and $y$ axes are shown in binary. If we connect the integer coordinate points in the order of their Morton indices, we see that the Morton curve visits the points along a hierarchical “z”-shaped path.
    ][
      Morton 曲线访问点的顺序。$x$ 和 $y$ 轴上的坐标值以二进制形式表示。如果按照点的 Morton 索引顺序连接整数坐标点，可以看到 Morton 曲线沿着层次化的“Z”形路径访问这些点。
    ]
  ],
)<morton-curve-basics>
#parec[
  A Morton-encoded value also encodes useful information about the position of the point that it represents. Consider the case of 4-bit coordinate values in 2D: the $x$ and $y$ coordinates are integers in $[0 , 15]$ and the Morton code has 8 bits: $y_3 x_3 y_2 x_2 y_1 x_1 y_0 x_0$. Many interesting properties follow from the encoding; a few examples include:
][
  Morton编码值还包含了关于其所代表点位置的有用信息。考虑2D中4位坐标值的情况： $x$ 和 $y$ 坐标是 $[0 , 15]$ 范围内的整数，Morton编码有8位： $y_3 x_3 y_2 x_2 y_1 x_1 y_0 x_0$。从编码中可以得出许多有趣的性质；以下是一些例子：
]

#parec[
  - For a Morton-encoded 8-bit value where the high bit $y_3$ is set, we
    then know that the high bit of its underlying $y$ coordinate is set
    and thus $y gt.eq 8$ (Figure 7.9(a)).
  - The next bit value, $x_3$, splits the $x$ axis in the middle (Figure
    7.9(b)). If $y_3$ is set and $x_3$ is off, for example, then the
    corresponding point must lie in the shaded area of Figure 7.9(c). In
    general, points with a number of matching high bits lie in a
    power-of-two sized and axis-aligned region of space determined by the
    matching bit values.
  - The value of $y_2$ splits the $y$ axis into four regions (Figure
    7.9(d)).
][
  - 对于 8 位 Morton 编码，若最高位 $y_3$ 为 1，就知道原 $y$ 坐标最高位为 1，因此 $y gt.eq 8$（@fig:morton-bit-implications(a)）。
  - 下一位 $x_3$ 将 $x$ 轴范围从中间分开（@fig:morton-bit-implications(b)）。例如，$y_3=1$ 且 $x_3=0$ 时，点必在图 (c) 的阴影区域内。一般而言，高位相同的点落在由这些位确定的轴对齐区域内，其尺寸为 2 的幂。
  - $y_2$ 将 $y$ 轴分成四个区域（@fig:morton-bit-implications(d)）。
]


#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f09.svg"),
  caption: [
    #ez_caption[
      Implications of the Morton Encoding. The values of various bits in the Morton value indicate the region of space that the corresponding coordinate lies in. (a) In 2D, the high bit of the Morton-coded value of a point’s coordinates defines a splitting plane along the middle of the $y$ axis. If the high bit is set, the point is above the plane. (b) Similarly, the second-highest bit of the Morton value splits the $x$ axis in the middle. (c) If the high $y$ bit is 1 and the high $x$ bit is 0, then the point must lie in the shaded region. (d) The second-from-highest $y$ bit splits the $y$ axis into four regions.
    ][
      Morton 编码的影响。Morton 值中不同位的值表示对应坐标所在的空间区域。(a) 在二维中，点坐标的 Morton 编码值的最高位定义了沿 $y$ 轴中间的分割平面。如果最高位为 1，则该点位于平面上方。(b) 类似地，Morton 值的次高位将 $x$ 轴在中间分割。(c) 如果 $y$ 轴的最高位为 1 而 $x$ 轴的最高位为 0，则该点必须位于阴影区域内。(d) 次高的 $y$ 位将 $y$ 轴分割成四个区域。
    ]
  ],
)<morton-bit-implications>

#parec[
  Another way to interpret these bit-based properties is in terms of Morton-coded values. For example, @fig:morton-bit-implications(a) corresponds to the index being in the range $[8 , 15]$, and @fig:morton-bit-implications(c) corresponds to $[8 , 11]$. Thus, given a set of sorted Morton indices, we could find the range of points corresponding to an area like @fig:morton-bit-implications(c) by performing a binary search to find each endpoint in the array.
][
  另一种解释这些基于位的性质的方法是通过Morton编码值。例如，@fig:morton-bit-implications(a)对应于索引在 $[8 , 15]$ 范围内，而@fig:morton-bit-implications(c)对应于 $[8 , 11]$。因此，给定一组排序的Morton索引，我们可以通过执行二分搜索来找到数组中每个端点，以找到对应于@fig:morton-bit-implications(c)区域的点范围。
]

#parec[
  LBVHs are BVHs built by partitioning primitives using splitting planes that are at the midpoint of each region of space (i.e., equivalent to the `SplitMethod::Middle` path defined earlier). Partitioning is extremely efficient, as it takes advantage of properties of the Morton encoding described above.
][
  LBVH是通过使用位于空间每个区域中点的分割平面来划分图元构建的BVH（即，相当于先前定义的`SplitMethod::Middle`路径）。分区非常高效，因为它利用了上述Morton编码的性质。
]

#parec[
  Just reimplementing `Middle` in a different manner is not particularly interesting, so in the implementation here, we will build a #emph[hierarchical linear bounding volume hierarchy] (HLBVH). With this approach, Morton-curve-based clustering is used to first build trees for the lower levels of the hierarchy (referred to as "treelets" in the following), and the top levels of the tree are then created using the surface area heuristic. The `buildHLBVH()` method implements this approach and returns the root node of the resulting tree.
][
  仅换种方式实现 `Middle` 意义有限，因此这里采用#emph[分层线性包围体层次结构]（HLBVH）：先用 Morton 曲线聚类构建下层的小树（下文称 treelet），再用表面积启发式将它们连接成上层树。`buildHLBVH()` 实现该过程，返回根节点。
]


#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>+=")] <fragment-BVHAggregateMethodDefinitions-2>
#block(breakable: false)[
```cpp
BVHBuildNode *BVHAggregate::buildHLBVH(
        Allocator alloc, const std::vector<BVHPrimitive> &bvhPrimitives,
        std::atomic<int> *totalNodes,
        std::vector<Primitive> &orderedPrims) {
    <<Compute bounding box of all primitive centroids>>
    <<Compute Morton indices of primitives>>
    <<Radix sort primitive Morton indices>>
    <<Create LBVH treelets at bottom of BVH>>
    <<Create and return SAH BVH from LBVH treelets>>
}
```
]

#parec[
  The BVH is built using only the centroids of primitive bounding boxes to sort them—it does not account for the actual spatial extent of each primitive. This simplification is critical to the performance that HLBVHs offer, but it also means that for scenes with primitives that span a wide range of sizes, the tree that is built will not account for this variation as an SAH-based tree would.
][
  这里仅依据图元包围盒的质心排序，不考虑各图元实际占据的空间范围。这一简化是 HLBVH 高性能的关键；代价是图元大小差异很大的场景中，它不像 SAH 建树那样考虑这些差异。
]

#parec[
  Because the Morton encoding operates on integer coordinates, we first need to bound the centroids of all the primitives so that we can quantize centroid positions with respect to the overall bounds.
][
  Morton 编码处理整数坐标，因此先计算所有图元包围盒质心的整体包围范围，再以此量化质心位置。
]
#block(sticky: true)[#raw("<<Compute bounding box of all primitive centroids>>=")] <fragment-Computeboundingboxofallprimitivecentroids-0>
#block(breakable: false)[
```cpp
Bounds3f bounds;
for (const BVHPrimitive &prim : bvhPrimitives)
    bounds = Union(bounds, prim.Centroid());
```
]

#parec[
  Given the overall bounds, we can now compute the Morton code for each primitive. This is a fairly lightweight calculation, but given that there may be millions of primitives, it is worth parallelizing.
][
  在得到总体边界后，我们现在可以为每个图元计算Morton 码。这是一个相对轻量级的计算，但考虑到可能有数百万个图元，值得并行化。
]

#block(sticky: true)[#raw("<<Compute Morton indices of primitives>>=")] <fragment-ComputeMortonindicesofprimitives-0>
#block(breakable: false)[
```cpp
std::vector<MortonPrimitive> mortonPrims(bvhPrimitives.size());
ParallelFor(0, bvhPrimitives.size(), [&](int64_t i) {
    <<Initialize mortonPrims[i] for ith primitive>>
});
```
]

#parec[
  A `MortonPrimitive` instance is created for each primitive; it stores the index of the primitive, as well as its Morton code, in the `bvhPrimitives` array.
][
  为每个图元创建一个 `MortonPrimitive`，保存该图元在 `bvhPrimitives` 数组中的索引，以及它的 Morton 编码。
]

#block(sticky: true)[#raw("<<MortonPrimitive Definition>>=")] <fragment-MortonPrimitiveDefinition-0>
#block(breakable: false)[
```cpp
struct MortonPrimitive {
    int primitiveIndex;
    uint32_t mortonCode;
};
```
] <MortonPrimitive>
#parec[
  We use 10 bits for each of the $x$, $y$, and $z$ dimensions, giving a total of 30 bits for the Morton code. This granularity allows the values to fit into a single 32-bit variable. Floating-point centroid offsets inside the bounding box are in $[0, 1]$, so we scale them by $2^10$ to get integer coordinates that fit in 10 bits. The #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#EncodeMorton3")[EncodeMorton3()] function, which is defined with other bitwise utility functions in Section #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:bit-ops")[B.2.7], returns the 3D Morton code for the given integer values.
][
  我们为 $x$ 、 $y$ 和 $z$ 维度的每一个使用 10 位，总共 30 位用于Morton 码。这种粒度允许值适合于一个 32 位的变量。包围盒内的浮点中心点偏移在 $[0, 1]$ 范围内，因此我们通过 $2^10$ 来缩放它们，以获得适合于 10 位的整数坐标。EncodeMorton3() 函数，这个函数和其他位运算工具函数一起定义在章节 B.2.7，返回给定整数值的 3D Morton 码。
]


#block(sticky: true)[#raw("<<Initialize mortonPrims[i] for ith primitive>>=")] <fragment-InitializemonomortonPrimsiformonoithprimitive-0>
#block(breakable: false)[
```cpp
constexpr int mortonBits = 10;
constexpr int mortonScale = 1 << mortonBits;
mortonPrims[i].primitiveIndex = bvhPrimitives[i].primitiveIndex;
Vector3f centroidOffset = bounds.Offset(bvhPrimitives[i].Centroid());
Vector3f offset = centroidOffset * mortonScale;
mortonPrims[i].mortonCode = EncodeMorton3(offset.x, offset.y, offset.z);
```
]

#parec[
  Once the Morton indices have been computed, we will sort the `mortonPrims` by Morton index value using a radix sort. We have found that for BVH construction, our radix sort implementation is noticeably faster than using `std::sort()` from our system's standard library (which is a mixture of a quicksort and an insertion sort).
][
  一旦计算出Morton 索引，我们将使用基数排序对 mortonPrims 按Morton 索引值进行排序。我们发现，在构建 BVH 时，我们的基数排序实现明显快于使用系统标准库中的 `std::sort()`（这是快速排序和插入排序的混合体）。
]

#block(sticky: true)[#raw("<<Radix sort primitive Morton indices>>=")] <fragment-RadixsortprimitiveMortonindices-0>
#block(breakable: false)[
```cpp
RadixSort(&mortonPrims);
```
]


#parec[
  Recall that a radix sort differs from most sorting algorithms in that it is not based on comparing pairs of values but rather is based on bucketing items based on some key. Radix sort can be used to sort integer values by sorting them one digit at a time, going from the rightmost digit to the leftmost. Especially with binary values, it is worth sorting multiple digits at a time; doing so reduces the total number of passes taken over the data. In the implementation here, bitsPerPass sets the number of bits processed per pass; with the value 6, we have 5 passes to sort the 30 bits.
][
  基数排序不比较成对的值，而是根据关键字分桶。对整数可以从最低位到最高位逐位排序；二进制情况下，一次处理多个位能减少遍历数据的次数。这里 `bitsPerPass` 为 6，因此 30 位共需 5 轮排序。
]

#block(sticky: true)[#raw("<<BVHAggregate Utility Functions>>=")] <fragment-BVHAggregateUtilityFunctions-0>
#block(breakable: false)[
```cpp
static void RadixSort(std::vector<MortonPrimitive> *v) {
    std::vector<MortonPrimitive> tempVector(v->size());
    constexpr int bitsPerPass = 6;
    constexpr int nBits = 30;
    constexpr int nPasses = nBits / bitsPerPass;
    for (int pass = 0; pass < nPasses; ++pass) {
        <<Perform one pass of radix sort, sorting bitsPerPass bits>>
    }
    <<Copy final result from tempVector, if needed>>
}
```
]

#parec[
  Each pass sorts `bitsPerPass` bits, starting at lowBit.
][
  每轮从 `lowBit` 开始，对 `bitsPerPass` 个二进制位排序。
]

#block(sticky: true)[#raw("<<Perform one pass of radix sort, sorting bitsPerPass bits>>=")] <fragment-PerformonepassofradixsortsortingmonobitsPerPassbits-0>
#block(breakable: false)[
```cpp
int lowBit = pass * bitsPerPass;
<<Set in and out vector references for radix sort pass>>
<<Count number of zero bits in array for current radix sort bit>>
<<Compute starting index in output array for each bucket>>
<<Store sorted values in output array>>
```
]

#parec[
  The `in` and `out` references correspond to the vector to be sorted and the vector to store the sorted values in, respectively. Each pass through the loop alternates between the input vector `*v` and the temporary vector for each of them.
][
  `in` 引用本轮待排序的数组，`out` 引用存放结果的数组。每轮交换输入数组 `*v` 和临时数组的角色。
]


#block(sticky: true)[#raw("<<Set in and out vector references for radix sort pass>>=")] <fragment-Setinandoutvectorreferencesforradixsortpass-0>
#block(breakable: false)[
```cpp
std::vector<MortonPrimitive> &in = (pass & 1) ? tempVector : *v;
std::vector<MortonPrimitive> &out = (pass & 1) ? *v : tempVector;
```
]


#parec[
  If we are sorting `n` bits per pass, then there are `2^n` buckets that each value may land in. We first count how many values will land in each bucket; this will let us determine where to store sorted values in the output array. To compute the bucket index for the current value, the implementation shifts the index so that the bit at index `lowBit` is at bit 0 and then masks off the low `bitsPerPass` bits.
][
  若每轮处理 $n$ 位，就有 $2^n$ 个桶。先统计各桶的元素数，以确定输出位置。计算桶索引时，将 Morton 编码右移，使原 `lowBit` 位移至最低位，再用掩码取出低 `bitsPerPass` 位。
]

#block(sticky: true)[#raw("<<Count number of zero bits in array for current radix sort bit>>=")] <fragment-Countnumberofzerobitsinarrayforcurrentradixsortbit-0>
#block(breakable: false)[
```cpp
constexpr int nBuckets = 1 << bitsPerPass;
int bucketCount[nBuckets] = { 0 };
constexpr int bitMask = (1 << bitsPerPass) - 1;
for (const MortonPrimitive &mp : in) {
    int bucket = (mp.mortonCode >> lowBit) & bitMask;
    ++bucketCount[bucket];
}
```
]

#parec[
  Given the count of how many values land in each bucket, we can compute the offset in the output array where each bucket's values start; this is just the sum of how many values land in the preceding buckets.
][
  根据每个桶中有多少值，我们可以计算输出数组中每个桶的值开始的位置偏移量；这只是前面各桶中值的总和。
]

#block(sticky: true)[#raw("<<Compute starting index in output array for each bucket>>=")] <fragment-Computestartingindexinoutputarrayforeachbucket-0>
#block(breakable: false)[
```cpp
int outIndex[nBuckets];
outIndex[0] = 0;
for (int i = 1; i < nBuckets; ++i)
    outIndex[i] = outIndex[i - 1] + bucketCount[i - 1];
```
]


#parec[
  Now that we know where to start storing values for each bucket, we can take another pass over the primitives to recompute the bucket that each one lands in and to store their `MortonPrimitive`s in the output array. This completes the sorting pass for the current group of bits.
][
  现在我们知道了每个桶存储值的起始位置，可以再次遍历图元，重新计算每个元素所在的桶，并将它们的 `MortonPrimitive` 存储在输出数组中。这样就完成了针对当前位组的一轮排序。
]


#block(sticky: true)[#raw("<<Store sorted values in output array>>=")] <fragment-Storesortedvaluesinoutputarray-0>
#block(breakable: false)[
```cpp
for (const MortonPrimitive &mp : in) {
    int bucket = (mp.mortonCode >> lowBit) & bitMask;
    out[outIndex[bucket]++] = mp;
}
```
]


#parec[
  When sorting is done, if an odd number of radix sort passes were performed, then the final sorted values need to be copied from the temporary vector to the output vector that was originally passed to `RadixSort()`.
][
  排序完成后，如果执行了奇数轮基数排序，则需要将最终排序的值从临时向量复制到最初传递给 `RadixSort()` 的输出向量中。
]

#block(sticky: true)[#raw("<<Copy final result from tempVector, if needed>>=")] <fragment-CopyfinalresultfrommonotempVectorifneeded-0>
#block(breakable: false)[
```cpp
if (nPasses & 1)
    std::swap(*v, tempVector);
```
]


#parec[
  Given the sorted array of primitives, we can now find clusters of primitives with nearby centroids and then create an LBVH over the primitives in each cluster. This step is a good one to parallelize as there are generally many clusters and each cluster can be processed independently.
][
  根据排序后的图元数组，我们现在可以找到具有相近质心的图元簇，然后在每个簇中的图元上创建 LBVH。由于通常有许多簇，并且每个簇可以独立处理，因此这一步非常适合并行化。
]

#block(sticky: true)[#raw("<<Create LBVH treelets at bottom of BVH>>=")] <fragment-CreateLBVHtreeletsatbottomofBVH-0>
#block(breakable: false)[
```cpp
<<Find intervals of primitives for each treelet>>
<<Create LBVHs for treelets in parallel>>
```
]

#parec[
  Each primitive cluster is represented by an `LBVHTreelet`. It encodes the index in the `mortonPrims` array of the first primitive in the cluster as well as the number of following primitives. (See Figure 7.10.)
][
  每个图元簇用 `LBVHTreelet` 表示，记录它在 `mortonPrims` 中的起始索引及包含的图元数（@fig:lbvh-treelets）。
]

#block(sticky: true)[#raw("<<LBVHTreelet Definition>>=")] <fragment-LBVHTreeletDefinition-0>
#block(breakable: false)[
```cpp
struct LBVHTreelet {
   size_t startIndex, nPrimitives;
   BVHBuildNode *buildNodes;
};
```
] <LBVHTreelet>

#figure(image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f10.svg"), caption: [#ez_caption[Primitive Clusters for LBVH Treelets. Primitive centroids are clustered in a uniform grid over their bounds. An LBVH is created for each cluster of primitives within a cell that are in contiguous sections of the sorted Morton index values.][LBVH 小树的图元簇。在质心包围范围内建立规则网格，将图元按质心聚类。同一网格单元中的图元，在已排序的 Morton 索引数组中占据连续区间；为每个这样的簇创建一棵 LBVH。]]) <lbvh-treelets>

#parec[
  Recall from Figure 7.9 that a set of points with Morton codes that match in their high bit values lie in a power-of-two aligned and sized subset of the original volume. Because we have already sorted the `mortonPrims` array by Morton-coded value, primitives with matching high bit values are already together in contiguous sections of the array.
][
  回顾@fig:morton-bit-implications：Morton 编码的若干高位相同，就意味着点位于原包围体中一个按 2 的幂对齐、尺寸也为 2 的幂的子区域。数组 `mortonPrims` 已按编码排序，因此高位相同的图元已排列在连续区间中。
]

#parec[
  Here we will find sets of primitives that have the same values for the high 12 bits of their 30-bit Morton codes. Clusters are found by taking a linear pass through the `mortonPrims` array and finding the offsets where any of the high 12 bits changes. This corresponds to clustering primitives in a regular grid of $2^12 = 4096$ total grid cells with $2^4 = 16$ cells in each dimension. In practice, many of the grid cells will be empty, though we will still expect to find many independent clusters here.
][
  这里将 30 位 Morton 编码的高 12 位相同的图元归为一簇。线性扫描 `mortonPrims`，找到这 12 位发生变化的位置，即得到各簇。这相当于在每维 $2^4=16$ 格、共 $2^12=4096$ 格的规则网格中聚类。实际中许多格子为空，但通常仍有大量可独立处理的簇。
]

#block(sticky: true)[#raw("<<Find intervals of primitives for each treelet>>=")] <fragment-Findintervalsofprimitivesforeachtreelet-0>
#block(breakable: false)[
```cpp
std::vector<LBVHTreelet> treeletsToBuild;
for (size_t start = 0, end = 1; end <= mortonPrims.size(); ++end) {
    uint32_t mask = 0b00111111111111000000000000000000;
    if (end == (int)mortonPrims.size() ||
        ((mortonPrims[start].mortonCode & mask) !=
         (mortonPrims[end].mortonCode & mask))) {
        <<Add entry to treeletsToBuild for this treelet>>
        start = end;
    }
}
```
]


#parec[
  When a cluster of primitives has been found for a treelet, `BVHBuildNode`s are immediately allocated for it. (Recall that the number of nodes in a BVH is bounded by twice the number of leaf nodes, which in turn is bounded by the number of primitives.) It is simpler to preallocate this memory now in a serial phase of execution than during parallel construction of LBVHs.
][
  当为一个 treelet 找到一个图元簇时，会立即为其分配 `BVHBuildNode`。 （回想一下，BVH 中节点的数量由叶节点数量的两倍限制，而叶节点数量又由图元数量限制。）现在在串行执行阶段预分配这部分内存比在并行构建 LBVH 时更简单。
]

#block(sticky: true)[#raw("<<Add entry to treeletsToBuild for this treelet>>=")] <fragment-AddentrytomonotreeletsToBuildforthistreelet-0>
#block(breakable: false)[
```cpp
size_t nPrimitives = end - start;
int maxBVHNodes = 2 * nPrimitives - 1;
BVHBuildNode *nodes = alloc.allocate_object<BVHBuildNode>(maxBVHNodes);
treeletsToBuild.push_back({start, nPrimitives, nodes});
```
]

#parec[
  Once the primitives for each treelet have been identified, we can create LBVHs for them in parallel. When construction is finished, the `buildNodes` pointer for each `LBVHTreelet` will point to the root of the corresponding LBVH.
][
  一旦为每个 treelet 确定了图元，我们就可以并行地为它们创建 LBVH。构建完成后，每个 `LBVHTreelet` 的 `buildNodes` 指针将指向相应 LBVH 的根节点。
]

#parec[
  There are two places where the worker threads building LBVHs must coordinate with each other. First, the total number of nodes in all the LBVHs needs to be computed and returned via the `totalNodes` pointer passed to `buildHLBVH()`. Second, when leaf nodes are created for the LBVHs, a contiguous segment of the `orderedPrims` array is needed to record the indices of the primitives in the leaf node. Our implementation uses atomic variables for both.
][
  并行构建小树时，有两项共享工作需要协调：一是统计所有 LBVH 的节点总数，通过 `buildHLBVH()` 的 `totalNodes` 指针返回；二是创建叶节点时，从 `orderedPrims` 中预留连续区间记录图元。两者均使用原子变量。
]


#block(sticky: true)[#raw("<<Create LBVHs for treelets in parallel>>=")] <fragment-CreateLBVHsfortreeletsinparallel-0>
#block(breakable: false)[
```cpp
std::atomic<int> orderedPrimsOffset(0);
ParallelFor(0, treeletsToBuild.size(), [&](int i) {
    <<Generate ith LBVH treelet>>
});
```
]

#parec[
  The work of building the treelet is performed by `emitLBVH()`, which takes primitives with centroids in some region of space and successively partitions them with splitting planes that divide the current region of space into two halves along the center of the region along one of the three axes.
][
  `emitLBVH()` 负责构建小树。它接收质心位于某空间区域中的图元，依次沿三根轴之一，用经过当前区域中心的平面将区域分为两半，并据此划分图元。
]

#parec[
  Note that instead of taking a pointer to the atomic variable `totalNodes` to count the number of nodes created, `emitLBVH()` updates a non-atomic local variable. The fragment here then only updates `totalNodes` once per treelet when each treelet is done. This approach gives measurably better performance than the alternative—having the worker threads frequently modify `totalNodes` over the course of their execution. (To understand why this is so, see the discussion of the overhead of multi-core memory coherence models in Appendix B.6.3.)
][
  `emitLBVH()` 不直接修改原子变量 `totalNodes`，而是累加局部非原子计数；每棵小树完成后，再更新一次共享节点总数。与线程在构建过程中频繁修改共享变量相比，这样能获得可测量的性能提升。原因见附录 B.6.3 对多核内存一致性开销的讨论。
]

#block(sticky: true)[#raw("<<Generate ith LBVH treelet>>=")] <fragment-GeneratemonoithLBVHtreelet-0>
#block(breakable: false)[
```cpp
int nodesCreated = 0;
const int firstBitIndex = 29 - 12;
LBVHTreelet &tr = treeletsToBuild[i];
tr.buildNodes =
    emitLBVH(tr.buildNodes, bvhPrimitives, &mortonPrims[tr.startIndex],
             tr.nPrimitives, &nodesCreated, orderedPrims,
             &orderedPrimsOffset, firstBitIndex);
*totalNodes += nodesCreated;
```
]


#parec[
  Thanks to the Morton encoding, the current region of space does not need to be explicitly represented in `emitLBVH()`: the sorted `MortonPrim`s passed in have some number of matching high bits, which in turn corresponds to a spatial bound. For each of the remaining bits in the Morton codes, this function tries to split the primitives along the plane corresponding to the `bitIndex` bit (recall Figure 7.9(d)) and then calls itself recursively. The index of the next bit to try splitting with is passed as the last argument to the function: initially it is $29 - 12$, since 29 is the index of the 30th bit with zero-based indexing, and we previously used the high 12 bits of the Morton-coded value to cluster the primitives; thus, we know that those bits must all match for the cluster.
][
  Morton 编码使 `emitLBVH()` 不必显式保存当前空间区域：传入的已排序 Morton 编码具有若干相同高位，这就确定了包围范围。函数用剩余位中的 `bitIndex` 位对应的平面尝试划分，再递归处理。最后一个参数指定下一位的索引，初值为 $29-12$：30 位编码的最高位索引为 29，高 12 位已用于聚类，簇内这些位必定相同。
]

#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>+=")] <fragment-BVHAggregateMethodDefinitions-3>
#block(breakable: false)[
```cpp
BVHBuildNode *BVHAggregate::emitLBVH(BVHBuildNode *&buildNodes,
        const std::vector<BVHPrimitive> &bvhPrimitives,
        MortonPrimitive *mortonPrims, int nPrimitives, int *totalNodes,
        std::vector<Primitive> &orderedPrims,
        std::atomic<int> *orderedPrimsOffset, int bitIndex) {
    if (bitIndex == -1 || nPrimitives < maxPrimsInNode) {
        <<Create and return leaf node of LBVH treelet>>
    } else {
        int mask = 1 << bitIndex;
        <<Advance to next subtree level if there is no LBVH split for this bit>>
        <<Find LBVH split point for this dimension>>
        <<Create and return interior LBVH node>>
    }
}
```
]


#parec[
  After `emitLBVH()` has partitioned the primitives with the final low bit, no more splitting is possible and a leaf node is created. Alternatively, it also stops and makes a leaf node if it is down to a small number of primitives.
][
  `emitLBVH()` 使用最终的低位对图元进行分区后，就无法再进行分割，并创建一个叶节点。或者，如果剩下的图元数量较少，它也会停止并创建一个叶节点。
]

#parec[
  Recall that `orderedPrimsOffset` is the offset to the next available element in the `orderedPrims` array. Here, the call to `fetch_add()` atomically adds the value of `nPrimitives` to `orderedPrimsOffset` and returns its old value before the addition. Given space in the array, leaf construction is similar to the approach implemented earlier in ⟨Create leaf `BVHBuildNode`⟩.
][
  `orderedPrimsOffset` 指向 `orderedPrims` 中下一个空闲位置。`fetch_add()` 原子地将它增加 `nPrimitives`，并返回增加前的值。预留数组空间后，叶节点的构造与前面的 ⟨Create leaf BVHBuildNode⟩ 相似。
]


#block(sticky: true)[#raw("<<Create and return leaf node of LBVH treelet>>=")] <fragment-CreateandreturnleafnodeofLBVHtreelet-0>
#block(breakable: false)[
```cpp
++*totalNodes;
BVHBuildNode *node = buildNodes++;
Bounds3f bounds;
int firstPrimOffset = orderedPrimsOffset->fetch_add(nPrimitives);
for (int i = 0; i < nPrimitives; ++i) {
    int primitiveIndex = mortonPrims[i].primitiveIndex;
    orderedPrims[firstPrimOffset + i] = primitives[primitiveIndex];
    bounds = Union(bounds, bvhPrimitives[primitiveIndex].bounds);
}
node->InitLeaf(firstPrimOffset, nPrimitives, bounds);
return node;
```
]


#parec[
  It may be the case that all the primitives lie on the same side of the splitting plane; since the primitives are sorted by their Morton index, this case can be efficiently checked by seeing if the first and last primitive in the range both have the same bit value for this plane. In this case, `emitLBVH()` proceeds to the next bit without unnecessarily creating a node.
][
  所有图元可能都位于分割平面的一侧；由于图元已按 Morton 索引排序，可以通过检查范围内的第一个和最后一个图元在该平面的位值是否相同来有效地验证这种情况。在这种情况下，`emitLBVH()` 会继续处理下一个位，而不会不必要地创建节点。
]

#block(sticky: true)[#raw("<<Advance to next subtree level if there is no LBVH split for this bit>>=")] <fragment-AdvancetonextsubtreelevelifthereisnoLBVHsplitforthisbit-0>
#block(breakable: false)[
```cpp
if ((mortonPrims[0].mortonCode & mask) ==
    (mortonPrims[nPrimitives - 1].mortonCode & mask))
    return emitLBVH(buildNodes, bvhPrimitives, mortonPrims, nPrimitives,
                    totalNodes, orderedPrims, orderedPrimsOffset,
                    bitIndex - 1);
```
]


#parec[
  If there are primitives on both sides of the splitting plane, then a binary search efficiently finds the dividing point where the `bitIndex`th bit goes from 0 to 1 in the current set of primitives.
][
  如果分割平面两侧都有图元，则二分搜索可以有效地找到当前图元集中第 `bitIndex` 位从 0 变为 1 的分割点。
]

#block(sticky: true)[#raw("<<Find LBVH split point for this dimension>>=")] <fragment-FindLBVHsplitpointforthisdimension-0>
#block(breakable: false)[
```cpp
int splitOffset = FindInterval(nPrimitives, [&](int index) {
    return ((mortonPrims[0].mortonCode & mask) ==
            (mortonPrims[index].mortonCode & mask));
});
++splitOffset;
```
]


#parec[
  Given the split offset, the method can now claim a node to use as an interior node and recursively build LBVHs for both partitioned sets of primitives. Note a further efficiency benefit from Morton encoding: entries in the `mortonPrims` array do not need to be copied or reordered for the partition: because they are all sorted by their Morton code value and because it is processing bits from high to low, the two spans of primitives are already on the correct sides of the partition plane.
][
  找到划分位置后，分配一个内部节点，递归构建两侧的 LBVH。Morton 编码还有一个好处：不必复制或重排数组条目。因为编码已经排序，而算法从高位向低位处理，两个连续区间天然位于划分平面的两侧。
]

#block(sticky: true)[#raw("<<Create and return interior LBVH node>>=")] <fragment-CreateandreturninteriorLBVHnode-0>
#block(breakable: false)[
```cpp
(*totalNodes)++;
BVHBuildNode *node = buildNodes++;
BVHBuildNode *lbvh[2] = {
    emitLBVH(buildNodes, bvhPrimitives, mortonPrims, splitOffset,
             totalNodes, orderedPrims, orderedPrimsOffset, bitIndex - 1),
    emitLBVH(buildNodes, bvhPrimitives, &mortonPrims[splitOffset],
             nPrimitives - splitOffset, totalNodes, orderedPrims,
             orderedPrimsOffset, bitIndex - 1)
};
int axis = bitIndex % 3;
node->InitInterior(axis, lbvh[0], lbvh[1]);
return node;
```
]

#parec[
  Once all the LBVH treelets have been created, `buildUpperSAH()` creates a BVH of all the treelets. Since there are generally tens or hundreds of them (and in any case, no more than 4096), this step takes very little time.
][
  一旦所有 LBVH treelet 都被创建，`buildUpperSAH()` 就会为所有 treelet 创建一个 BVH。由于通常有数十个或数百个（无论如何，不超过 4096 个），此步骤所需时间非常少。
]

#block(sticky: true)[#raw("<<Create and return SAH BVH from LBVH treelets>>=")] <fragment-CreateandreturnSAHBVHfromLBVHtreelets-0>
#block(breakable: false)[
```cpp
std::vector<BVHBuildNode *> finishedTreelets;
for (LBVHTreelet &treelet : treeletsToBuild)
    finishedTreelets.push_back(treelet.buildNodes);
return buildUpperSAH(alloc, finishedTreelets, 0,
                     finishedTreelets.size(), totalNodes);
```
]

#parec[
  The implementation of `buildUpperSAH()` is not included here, as it follows the same approach as fully SAH-based BVH construction, just over treelet root nodes rather than scene primitives.
][
  `buildUpperSAH()` 的实现未在此包含，因为它采用与完全基于 SAH 的 BVH 构建相同的方法，只不过是针对 treelet 根节点而不是场景图元。
]


=== #ez_caption[Compact BVH for Traversal][用于遍历的紧凑 BVH]
<compact-bvh-for-traversal>


#parec[
  Once the BVH is built, the last step is to convert it into a compact representation—doing so improves cache, memory, and thus overall system performance. The final BVH is stored in a linear array in memory. The nodes of the original tree are laid out in depth-first order, which means that the first child of each interior node is immediately after the node in memory. In this case, only the offset to the second child of each interior node must be stored explicitly. See Figure 7.11 for an illustration of the relationship between tree topology and node order in memory.
][
  一旦建立了 BVH，最后一步是将其转换为紧凑的表示形式——这样可以提高缓存和内存访问效率，进而改善整体性能。最终的 BVH 被存储在内存中的线性数组中。原始树的节点按照深度优先遍历顺序排列，这意味着每个内部节点的第一个子节点紧跟在内存中的该节点之后。在这种情况下，只需要显式存储每个内部节点的第二个子节点的偏移量。请参见@fig:bvh-linear-layout 以了解树拓扑与内存中节点顺序之间的关系。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f11.svg"),
  caption: [
    #ez_caption[
      Linear Layout of a BVH in Memory. The nodes of the BVH
      (left) are stored in memory in depth-first order (right). Therefore,
      for any interior node of the tree (A and B in this example), the
      first child is found immediately after the parent node in memory.
      The second child is found via an offset pointer, represented here by
      lines with arrows. Leaf nodes of the tree (D, E, and C) have no
      children.
    ][
      内存中 BVH 的线性布局。BVH
      的节点（左）以深度优先顺序存储在内存中（右）。因此，对于树的任何内部节点（在此示例中为
      A 和
      B），第一个子节点在内存中紧跟在父节点之后。第二个子节点通过偏移指针找到，这里用带箭头的线表示。树的叶子节点（D、E
      和 C）没有子节点。
    ]
  ],
)<bvh-linear-layout>

#parec[
  The `LinearBVHNode` structure stores the information needed to traverse the BVH. In addition to the bounding box for each node, for leaf nodes it stores the offset and primitive count for the primitives in the node. For interior nodes, it stores the offset to the second child as well as which of the coordinate axes the primitives were partitioned along when the hierarchy was built; this information is used in the traversal routine below to try to visit nodes in front-to-back order along the ray.
][
  `LinearBVHNode` 保存遍历所需的信息。除包围盒外，叶节点保存图元在数组中的偏移量和数量；内部节点保存第二个子节点的偏移量，以及构建时划分图元所用的坐标轴。后者用于在遍历时尝试按沿射线从近到远的顺序访问节点。
]

#parec[
  The structure is declared to require 32-byte alignment in memory. It could otherwise be allocated at an alignment that was sufficient to satisfy the first member variable, which would be 4 bytes for the `Float`-valued `Bounds3f::pMin::x` member variable. Because modern processor caches are organized into cache lines of a size that is a multiple of 32, a more stringent alignment constraint ensures that no `LinearBVHNode` straddles two cache lines. In turn, no more than a single cache miss will be incurred when one is accessed, which improves performance.
][
  该结构被声明为在内存中需要 32 字节对齐。否则，分配时可能只满足第一个成员所需的对齐；对于 `Float` 类型的 `Bounds3f::pMin::x`，这一要求为 4 字节。由于现代处理器缓存被组织成大小为 32 的倍数的缓存行，更严格的内存对齐约束确保没有 `LinearBVHNode` 跨越两个缓存行。这样，当访问一个节点时，不会产生超过一次缓存未命中（cache miss），从而提高性能。
]

#block(sticky: true)[#raw("<<LinearBVHNode Definition>>=")] <fragment-LinearBVHNodeDefinition-0>
#block(breakable: false)[
```cpp
struct alignas(32) LinearBVHNode {
    Bounds3f bounds;
    union {
        int primitivesOffset;    // leaf
        int secondChildOffset;   // interior
    };
    uint16_t nPrimitives;  // 0 -> interior node
    uint8_t axis;          // interior node: xyz
};
```
] <LinearBVHNode>

#parec[
  The built tree is transformed to the `LinearBVHNode` representation by the `flattenBVH()` method, which performs a depth-first traversal and stores the nodes in memory in linear order. It is helpful to release the memory in the `bvhPrimitives` array before doing so, since that may be a significant amount of storage for complex scenes and is no longer needed at this point. This is handled by the `resize(0)` and `shrink_to_fit()` calls.
][
  通过 `flattenBVH()` 方法将构建的树转换为 `LinearBVHNode` 表示，该方法执行深度优先遍历并以线性顺序将节点存储在内存中。最好在此之前释放 `bvhPrimitives` 数组中的内存，因为对于复杂场景，这可能是大量存储，并且此时不再需要。这由 `resize(0)` 和 `shrink_to_fit()` 调用处理。
]

#block(sticky: true)[#raw("<<Convert BVH into compact representation in nodes array>>=")] <fragment-ConvertBVHintocompactrepresentationinmononodesarray-0>
#block(breakable: false)[
```cpp
bvhPrimitives.resize(0);
bvhPrimitives.shrink_to_fit();
nodes = new LinearBVHNode[totalNodes];
int offset = 0;
flattenBVH(root, &offset);
```
]


#parec[
  The pointer to the array of `LinearBVHNode`s is stored as a `BVHAggregate` member variable.
][
  指向 `LinearBVHNode` 数组的指针被存储为 `BVHAggregate` 成员变量。
]

#block(sticky: true)[#raw("<<BVHAggregate Private Members>>+=")] <fragment-BVHAggregatePrivateMembers-1>
#block(breakable: false)[
```cpp
LinearBVHNode *nodes = nullptr;
```
]


#parec[
  Flattening the tree to the linear representation is straightforward; the `*offset` parameter tracks the current offset into the `BVHAggregate::nodes` array. Note that the current node is added to the array before any recursive calls to process its children.
][
  将树压平为线性表示是直接的；`*offset` 参数跟踪当前在 `BVHAggregate::nodes` 数组中的偏移量。请注意，在任何递归调用处理其子节点之前，当前节点已添加到数组中。
]

#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>+=")] <fragment-BVHAggregateMethodDefinitions-4>
#block(breakable: false)[
```cpp
int BVHAggregate::flattenBVH(BVHBuildNode *node, int *offset) {
    LinearBVHNode *linearNode = &nodes[*offset];
    linearNode->bounds = node->bounds;
    int nodeOffset = (*offset)++;
    if (node->nPrimitives > 0) {
        linearNode->primitivesOffset = node->firstPrimOffset;
        linearNode->nPrimitives = node->nPrimitives;
    } else {
        <<Create interior flattened BVH node>>
    }
    return nodeOffset;
}
```
]


#parec[
  At interior nodes, recursive calls are made to flatten the two subtrees. The first one ends up immediately after the current node in the array, as desired, and the offset of the second one, returned by its recursive `flattenBVH()` call, is stored in this node's `secondChildOffset` member.
][
  内部节点递归线性化两棵子树。第一棵子树紧接当前节点；处理第二棵子树的递归 `flattenBVH()` 返回其起始偏移量，将该值存入当前节点的 `secondChildOffset`。
]

#block(sticky: true)[#raw("<<Create interior flattened BVH node>>=")] <fragment-CreateinteriorflattenedBVHnode-0>
#block(breakable: false)[
```cpp
linearNode->axis = node->splitAxis;
linearNode->nPrimitives = 0;
flattenBVH(node->children[0], offset);
linearNode->secondChildOffset = flattenBVH(node->children[1], offset);
```
]


=== #ez_caption[Bounding and Intersection Tests][包围范围与求交测试]
<bounding-and-intersection-tests>
#parec[
  Given a built BVH, the implementation of the `Bounds()` method is easy: by definition, the root node's bounds are the bounds of all the primitives in the tree, so those can be returned directly.
][
  给定一个已构建的 BVH，实现 `Bounds()` 方法很简单：根据定义，根节点的包围范围覆盖树中全部图元，因此直接返回即可。
]

#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>+=")] <fragment-BVHAggregateMethodDefinitions-5>
#block(breakable: false)[
```cpp
Bounds3f BVHAggregate::Bounds() const {
    return nodes[0].bounds;
}
```
]


#parec[
  The BVH traversal code is quite simple—there are no recursive function calls and a small amount of data to maintain about the current state of the traversal. The `Intersect()` method starts by precomputing a few values related to the ray that will be used repeatedly.
][
  BVH 遍历代码相当简单——没有递归函数调用，并且只需维护少量关于当前遍历状态的数据。`Intersect()` 方法首先预计算一些与光线相关的值，这些值将被重复使用。
]

#block(sticky: true)[#raw("<<BVHAggregate Method Definitions>>+=")] <fragment-BVHAggregateMethodDefinitions-6>
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection>
BVHAggregate::Intersect(const Ray &ray, Float tMax) const {
    pstd::optional<ShapeIntersection> si;
    Vector3f invDir(1 / ray.d.x, 1 / ray.d.y, 1 / ray.d.z);
    int dirIsNeg[3] = {int(invDir.x < 0), int(invDir.y < 0),
                       int(invDir.z < 0)};
    <<Follow ray through BVH nodes to find primitive intersections>>
    return si;
}
```
]



#parec[
  Each time the following `while` loop starts an iteration, `currentNodeIndex` holds the offset into the `nodes` array of the node to be visited. It starts with a value of 0, representing the root of the tree. The nodes that still need to be visited are stored in the `nodesToVisit[]` array, which acts as a stack; `toVisitOffset` holds the offset to the next free element in the stack. With the following traversal algorithm, the number of nodes in the stack is never more than the maximum tree depth. A statically allocated stack of 64 entries is sufficient in practice.
][
  每次以下 `while` 循环开始迭代时，`currentNodeIndex` 持有要访问的节点在 `nodes` 数组中的偏移量。它以 0 开始，表示树的根节点。仍需访问的节点存储在 `nodesToVisit[]` 数组中，该数组充当栈；`toVisitOffset` 持有栈中下一个空闲元素的偏移量。通过以下遍历算法，栈中的节点数从未超过最大树深度。在实践中，静态分配的 64 个条目栈已足够。
]

#block(sticky: true)[#raw("<<Follow ray through BVH nodes to find primitive intersections>>=")] <fragment-FollowraythroughBVHnodestofindprimitiveintersections-0>
#block(breakable: false)[
```cpp
int toVisitOffset = 0, currentNodeIndex = 0;
int nodesToVisit[64];
while (true) {
    const LinearBVHNode *node = &nodes[currentNodeIndex];
    <<Check ray against BVH node>>
}
```
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f12.svg"),
  caption: [
    #ez_caption[
      Visualization of BVH Performance with the Kroken Scene. (a) Number of BVH nodes visited when tracing the camera ray at each pixel for the scene shown in Figure 1.1. Not only are more nodes visited in geometrically complex regions of the scene such as the rug, but objects that are not accurately bounded by axis-aligned bounding boxes such as the support under the bottom shelf lead to many nodes being visited. (b) Number of ray–triangle intersection tests performed for the camera ray at each pixel. The BVH is effective at limiting the number of intersection tests even in highly complex regions of the scene like the rug. However, objects that are poorly fit by axis-aligned bounding boxes lead to many intersection tests for rays in their vicinity. (Kroken scene courtesy of Angelo Ferretti.)
    ][
      使用 Kroken 场景可视化 BVH 性能。
      (a) 在每个像素处跟踪相机射线时访问的 BVH 节点数量，场景如图 1.1 所示。场景中几何复杂的区域（如地毯）访问的节点数量更多，此外，一些由轴对齐包围盒未能准确界定的对象（如底架下的支撑物）也导致了大量节点的访问。
      (b) 在每个像素处对相机射线执行的射线-三角形相交测试数量。即使在场景中如地毯这样高度复杂的区域，BVH 在限制相交测试数量方面仍然有效。然而，由于一些由轴对齐包围盒不适合界定的对象，会导致其附近射线进行大量的相交测试。
      (Kroken 场景图片由 Angelo Ferretti 提供。)
    ]
  ],
)<bvh-number-of-nodes-visited>

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f13.svg"),
  caption: [
    #ez_caption[
      Visualization of BVH Performance with the Moana Island Scene. (a) Number of BVH nodes visited when tracing the camera ray at each pixel for the scene shown in Figure 1.4. As with the Kroken scene, silhouette edges and regions where the ray passes by many objects before finding an intersection see the most nodes visited. (b) Number of ray–triangle intersection tests performed for the camera ray at each pixel. The most geometrically complex trees and the detailed ground cover on the beach require the most intersection tests. (Scene courtesy of Walt Disney Animation Studios.)
    ][
      使用 Moana 岛屿场景可视化 BVH 性能。
      (a) 在每个像素处跟踪相机射线时访问的 BVH 节点数量，场景如图 1.4 所示。与 Kroken 场景一样，轮廓边缘和射线在找到相交前经过许多对象的区域访问的节点数量最多。
      (b) 在每个像素处对相机射线执行的射线-三角形相交测试数量。几何最复杂的树木和海滩上细节丰富的地被植被需要进行最多的相交测试。
      (场景图片由沃尔特迪士尼动画工作室提供。)
    ]
  ],
)<moana-bvh-number-of-nodes-visited>

#parec[
  At each node, the first step is to check if the ray intersects the node's bounding box (or starts inside of it). The node is visited if so, with its primitives tested for intersection if it is a leaf node or its children are visited if it is an interior node. If no intersection is found, then the offset of the next node to be visited is retrieved from `nodesToVisit[]` (or traversal is complete if the stack is empty). See @fig:bvh-number-of-nodes-visited and @fig:moana-bvh-number-of-nodes-visited for visualizations of how many nodes are visited and how many intersection tests are performed at each pixel for two complex scenes.
][
  在每个节点，第一步是检查光线是否与节点的包围盒相交（或从内部开始）。如果是，则访问节点。若是叶节点，则测试其图元的相交；若是内部节点，则访问其子节点。如果未找到相交，则从 `nodesToVisit[]` 中检索下一个要访问的节点的偏移量（如果栈为空则遍历完成）。参见@fig:bvh-number-of-nodes-visited 和 @fig:moana-bvh-number-of-nodes-visited，了解在两个复杂场景中每个像素访问的节点数量和执行的相交测试数量的可视化。
]

#block(sticky: true)[#raw("<<Check ray against BVH node>>=")] <fragment-CheckrayagainstBVHnode-0>
#block(breakable: false)[
```cpp
if (node->bounds.IntersectP(ray.o, ray.d, tMax, invDir, dirIsNeg)) {
    if (node->nPrimitives > 0) {
        <<Intersect ray with primitives in leaf BVH node>>
    } else {
        <<Put far BVH node on nodesToVisit stack, advance to near node>>
    }
} else {
    if (toVisitOffset == 0) break;
    currentNodeIndex = nodesToVisit[--toVisitOffset];
}
```
]



#parec[
  If the current node is a leaf, then the ray must be tested for intersection with the primitives inside it. The next node to visit is then found from the `nodesToVisit` stack; even if an intersection is found in the current node, the remaining nodes must be visited in case one of them yields a closer intersection.
][
  如果当前节点是叶节点，则必须测试光线与其中的图元的相交。然后从 `nodesToVisit` 栈中找到下一个要访问的节点；即使在当前节点中找到相交，仍需访问剩余节点，以防其中一个节点提供更近的相交。
]

#block(sticky: true)[#raw("<<Intersect ray with primitives in leaf BVH node>>=")] <fragment-IntersectraywithprimitivesinleafBVHnode-0>
#block(breakable: false)[
```cpp
for (int i = 0; i < node->nPrimitives; ++i) {
    <<Check for intersection with primitive in BVH node>>
}
if (toVisitOffset == 0) break;
currentNodeIndex = nodesToVisit[--toVisitOffset];
```
]


#parec[
  If an intersection is found, the `tMax` value can be updated to the intersection's parametric distance along the ray; this makes it possible to efficiently discard any remaining nodes that are farther away than the intersection.
][
  如果找到相交，可以将 `tMax` 值更新为相交在光线上的参数距离；这使得可以有效地丢弃任何比相交更远的剩余节点。
]

#block(sticky: true)[#raw("<<Check for intersection with primitive in BVH node>>=")] <fragment-CheckforintersectionwithprimitiveinBVHnode-0>
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection> primSi =
    primitives[node->primitivesOffset + i].Intersect(ray, tMax);
if (primSi) {
    si = primSi;
    tMax = si->tHit;
}
```
]

#parec[
  For an interior node that the ray hits, it is necessary to visit both of its children. As described above, it is desirable to visit the first child that the ray passes through before visiting the second one in case the ray intersects a primitive in the first one. If so, the ray's `tMax` value can be updated, thus reducing the ray's extent and thus the number of node bounding boxes it intersects.
][
  射线击中内部节点时，需要考虑它的两个子节点。应尽量先访问射线先经过的那个；若在那里命中图元，就能缩小 `tMax`，减少之后需要访问的包围盒。
]

#parec[
  An efficient way to perform a front-to-back traversal without incurring the expense of intersecting the ray with both child nodes and comparing the distances is to use the sign of the ray's direction vector for the coordinate axis along which primitives were partitioned for the current node: if the sign is negative, we should visit the second child before the first child, since the primitives that went into the second child's subtree were on the upper side of the partition point. (And conversely for a positive-signed direction.) Doing this is straightforward: the offset for the node to be visited first is copied to `currentNodeIndex`, and the offset for the other node is added to the `nodesToVisit` stack. (Recall that the first child is immediately after the current node due to the depth-first layout of nodes in memory.)
][
  为避免对两个子节点分别求交并比较距离的开销，可以用射线方向在当前划分轴上的符号近似决定访问顺序。负方向时先访问第二个子节点，因为该子树的图元位于划分点坐标较大的一侧；正方向则相反。将先访问的节点偏移量写入 `currentNodeIndex`，另一个压入 `nodesToVisit` 栈即可。深度优先的内存布局保证第一个子节点紧接当前节点。
]

#block(sticky: true)[#raw("<<Put far BVH node on nodesToVisit stack, advance to near node>>=")] <fragment-PutfarBVHnodeonmononodesToVisitstackadvancetonearnode-0>
#block(breakable: false)[
```cpp
if (dirIsNeg[node->axis]) {
   nodesToVisit[toVisitOffset++] = currentNodeIndex + 1;
   currentNodeIndex = node->secondChildOffset;
} else {
   nodesToVisit[toVisitOffset++] = node->secondChildOffset;
   currentNodeIndex = currentNodeIndex + 1;
}
```
]



#parec[
  The `BVHAggregate::IntersectP()` method is essentially the same as the regular intersection method, with the two differences that `Primitive`'s `IntersectP()` methods are called rather than `Intersect()`, and traversal stops immediately when any intersection is found. It is thus not included here.
][
  `BVHAggregate::IntersectP()` 与常规求交方法基本相同，但有两点区别：调用图元的 `IntersectP()` 而非 `Intersect()`，并且找到任意交点就立即停止遍历。因此这里不再列出。
]
#parec[Editorial notes on the fixed source: the count of partitions into two nonempty groups is printed as $2^(n-1)-2$. For $n$ distinct elements with the two groups unordered, the usual count is $(2^n-2)/2=2^(n-1)-1$; the original expression is preserved above. The parenthetical “zero volume” does not by itself imply that all centroids coincide; the code tests zero extent along the longest centroid axis. The Morton discussion assumes 8-bit codes but later gives ranges $[8,15]$ and $[8,11]$, which are not full 8-bit index ranges for those high-bit constraints. These source inconsistencies are retained and require source-level clarification.][固定原文校订说明：非空两组划分数被写作 $2^(n-1)-2$。若 $n$ 个元素互异、两组不区分先后，通常的计数应为 $(2^n-2)/2=2^(n-1)-1$；上文保留原式。另，“零体积”本身不能推出全部质心重合，代码实际检查的是质心包围盒最长轴的跨度为零。Morton 讨论先设为 8 位编码，后给出的 $[8,15]$、$[8,11]$ 却不是相应高位约束下的完整 8 位索引范围。这些原文不一致之处保留，待原文层面澄清。]

#include "supplements/7.3-expanded.typ"
