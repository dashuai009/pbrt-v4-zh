#import "../template.typ": parec, ez_caption

== Bounding_Volume_Hierarchies
<bounding-volume-hierarchies>
#parec[
  Bounding volume hierarchies (BVHs) are an approach for ray intersection acceleration based on primitive subdivision, where the primitives are partitioned into a hierarchy of disjoint sets. (In contrast, spatial subdivision generally partitions space into a hierarchy of disjoint sets.) Figure 7.3 shows a bounding volume hierarchy for a simple scene. Primitives are stored in the leaves, and each node stores a bounding box of the primitives in the nodes beneath it. Thus, as a ray traverses through the tree, any time it does not intersect a node's bounds, the subtree beneath that node can be skipped.
][
  包围体层次结构（BVH）是一种基于图元细分的光线相交加速方法，其中图元被划分为不相交集合的层次结构。（相比之下，空间细分通常将空间划分为不相交集合的层次结构。）@fig:bvh-concept 显示了一个简单场景的包围体层次结构。图元被存储在叶子节点中，每个节点存储其下方节点中图元的包围盒。因此，当光线穿过树时，任何时候它不与节点的边界相交；该节点下方的子树都可以被跳过。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f03.svg"),
  caption: [
    #ez_caption[
      *Bounding Volume Hierarchy for a Simple Scene.* (a) A small collection of primitives, with bounding boxes shown by dashed lines. The primitives are aggregated based on proximity; here, the sphere and the equilateral triangle are bounded by another bounding box before being bounded by a bounding box that encompasses the entire scene (both shown in solid lines). (b) The corresponding bounding volume hierarchy. The root node holds the bounds of the entire scene. Here, it has two children, one storing a bounding box that encompasses the sphere and equilateral triangle (that in turn has those primitives as its children) and the other storing the bounding box that holds the skinny triangle.
    ][
      *简单场景的包围体层次结构。*(a) 一个由少量图元组成的集合，虚线框表示这些图元的包围盒。图元根据接近程度被聚合；在这里，球体和等边三角形被另一个包围盒包围，然后再被一个包围整个场景的包围盒包围（两者都用实线框表示）。(b) 对应的包围体层次结构。根节点保存整个场景的边界。在这里，它有两个子节点，一个子节点保存包围球体和等边三角形的包围盒（它的子节点是这些图元），另一个子节点保存包围细长三角形的包围盒。
    ]
  ],
)<bvh-concept>

#parec[
  One property of primitive subdivision is that each primitive appears in the hierarchy only once. In contrast, a primitive may overlap multiple spatial regions with spatial subdivision and thus may be tested for intersection multiple times as the ray passes through them. Another implication of this property is that the amount of memory needed to represent the primitive subdivision hierarchy is bounded. For a binary BVH that stores a single primitive in each leaf, the total number of nodes is 2n - 1, where n is the number of primitives. (There are n leaf nodes and n - 1 interior nodes.) If leaves store multiple primitives, fewer nodes are needed.
][
  图元划分之后的一个特性是每个图元在层次结构中只出现一次。相比之下，图元可能与空间划分出的多个空间区域重叠，因此在光线穿过它们时可能会多次测试相交。 这个特性的另一个含义是表示图元细分层次结构所需的内存量是有界的。对于在每个叶子节点中存储单个图元的二叉 BVH，总节点数为 2n - 1，其中 n 是图元的数量。（有 n 个叶子节点和 n - 1 个内部节点。）如果叶子节点存储多个图元，则需要更少的节点。
]

#parec[
  BVHs are more efficient to build than kd-trees, and are generally more numerically robust and less prone to missed intersections due to round-off errors than kd-trees are. The BVH aggregate, BVHAggregate, is therefore the default acceleration structure in pbrt.
][
  BVH 比 kd 树更易于构建，并且通常在数值上更稳健，不易因舍入误差而错过相交。因此，BVH 聚合 `BVHAggregate` 是 `pbrt` 中的默认加速结构。
]

```cpp
<<BVHAggregate Definition>>=
class BVHAggregate {
  public:
    <<BVHAggregate Public Types>>
    <<BVHAggregate Public Methods>>
  private:
    <<BVHAggregate Private Methods>>
    <<BVHAggregate Private Members>>
};
```

#parec[
  Its constructor takes an enumerator value that describes which of four algorithms to use when partitioning primitives to build the tree. The default, SAH, indicates that an algorithm based on the "surface area heuristic," discussed in Section 7.3.2, should be used. An alternative, HLBVH, which is discussed in Section 7.3.3, can be constructed more efficiently (and more easily parallelized), but it does not build trees that are as effective as SAH. The remaining two approaches use even less computation but create fairly low-quality trees. They are mostly useful for illuminating the superiority of the first two approaches.
][
  其构造函数接受一个枚举值，用于描述在构建树时划分图元的四种算法之一。默认值 SAH 表示应使用基于“表面积启发式”的算法，该算法在 7.3.2 节中讨论。另一种替代方法 HLBVH 在 7.3.3 节中讨论，可以更高效地构建（并且更易于并行化），但它构建的树不如 SAH 有效。剩下的两种方法使用更少的计算，但创建的树质量较低。它们主要用于说明前两种方法的优越性。
]
```cpp
<<BVHAggregate Public Types>>=
enum class SplitMethod { SAH, HLBVH, Middle, EqualCounts };
```

#parec[
  In addition to the enumerator, the constructor takes the primitives themselves and the maximum number of primitives that can be in any leaf node.
][
  除了枚举值，构造函数还接受图元本身和任何叶子节点中可以包含的最大图元数量。
]

```cpp
<<BVHAggregate Method Definitions>>=
BVHAggregate::BVHAggregate(std::vector<Primitive> prims,
        int maxPrimsInNode, SplitMethod splitMethod)
    : maxPrimsInNode(std::min(255, maxPrimsInNode)),
      primitives(std::move(prims)), splitMethod(splitMethod) {
    <<Build BVH from primitives>>
}
```

```cpp
<<BVHAggregate Private Members>>=
int maxPrimsInNode;
std::vector<Primitive> primitives;
SplitMethod splitMethod;
```

=== BVH Construction
#parec[
  There are three stages to BVH construction in the implementation here. First, bounding information about each primitive is computed and stored in an array that will be used during tree construction. Next, the tree is built using the algorithm choice encoded in `splitMethod`. The result is a binary tree where each interior node holds pointers to its children and each leaf node holds references to one or more primitives. Finally, this tree is converted to a more compact (and thus more efficient) pointerless representation for use during rendering. (The implementation is easier with this approach, versus computing the pointerless representation directly during tree construction, which is also possible.)
][
  在此实现中，BVH 构建过程分为三个阶段。首先，计算每个图元的完整边界信息并存储在一个数组中，该数组将在树构建期间使用。 接下来，使用在 `splitMethod` 中编码的算法选择来构建树。结果是一个二叉树，其中每个内部节点保存指向其子节点的指针，每个叶节点保存一个或多个图元的引用。 最后，这棵树被转换为一种更紧凑（因此更高效）的无指针化表示形式，以便在渲染期间使用。（使用这种方法实现更容易，而不是在树构建期间直接计算无指针化表示形式，虽然也能做到。）
]

```cpp
<<Build BVH from primitives>>=
<<Initialize bvhPrimitives array for primitives>>
<<Build BVH for primitives using bvhPrimitives>>
<<Convert BVH into compact representation in nodes array>>
```

#parec[
  For each primitive to be stored in the BVH, an instance of the `BVHPrimitive` structure stores its complete bounding box and its index in the `primitives` array.
][
  对于每个要存储在 BVH 中的图元，`BVHPrimitive` 结构的一个实例存储其完整的边界框及其在 `primitives` 数组中的索引。
]

```cpp
<<Initialize bvhPrimitives array for primitives>>=
std::vector<BVHPrimitive> bvhPrimitives(primitives.size());
for (size_t i = 0; i < primitives.size(); ++i)
    bvhPrimitives[i] = BVHPrimitive(i, primitives[i].Bounds());
```

```cpp
<<BVHPrimitive Definition>>=
struct BVHPrimitive {
    BVHPrimitive(size_t primitiveIndex, const Bounds3f &bounds)
        : primitiveIndex(primitiveIndex), bounds(bounds) {}
    size_t primitiveIndex;
    Bounds3f bounds;
    <<BVHPrimitive Public Methods>>
};
```


#parec[
  A simple method makes the centroid of the bounding box available.
][
  还有一个简单的方法用于获取边界框的质心。
]

```cpp
<<BVHPrimitive Public Methods>>=
Point3f Centroid() const { return .5f * bounds.pMin + .5f * bounds.pMax; }
```

#parec[
  Hierarchy construction can now begin. In addition to initializing the pointer to the root node of the BVH, `root`, an important side effect of the tree construction process is that a new array of `Primitive` is stored in `orderedPrims`; this array stores the primitives ordered so that the primitives in each leaf node occupy a contiguous range in the array. It is swapped with the original `primitives` array after tree construction.
][
  现在可以开始构建层次结构。除了初始化指向 BVH 根节点的指针 `root` 外，树构建过程的一个重要结果是一个存储在 `orderedPrims` 中的新的 `Primitive` 数组；该数组存储的图元是有序的，以便每个叶节点中的图元在数组中占据连续的范围。 它在树构建后替换了原始的 `primitives` 数组 。
]

```cpp
<<Build BVH for primitives using bvhPrimitives>>=
<<Declare Allocators used for BVH construction>>
std::vector<Primitive> orderedPrims(primitives.size());
BVHBuildNode *root;
<<Build BVH according to selected splitMethod>>
```

#parec[
  Memory for the initial BVH is allocated using the following `Allocators`. Note that all are based on the C++ standard library's `pmr::monotonic_buffer_resource`, which efficiently allocates memory from larger buffers. This approach is not only more computationally efficient than using a general-purpose allocator, but also uses less memory in total due to keeping less bookkeeping information with each allocation.We have found that using the default memory allocation algorithms in the place of these uses approximately 10% more memory and takes approximately 10% longer for complex scenes.
][
  初始 BVH（包围体层次结构）的内存使用以下 `Allocators` 分配。请注意，它们都基于 C++ 标准库的 `pmr::monotonic_buffer_resource`，该资源通过更大的缓冲区高效地分配内存。这种方法不仅比使用通用分配器在计算上更高效，而且由于每次分配时记录的管理信息更少，整体上使用的内存也更少。我们发现，使用默认的内存分配算法比我们用的方案，大约会多使用 10% 的内存，并且处理复杂场景时大约需要多花费 10% 的时间。
]

#parec[
  Because the `pmr::monotonic_buffer_resource` class cannot be used concurrently by multiple threads without mutual exclusion, in the parts of BVH construction that execute in parallel each thread uses per-thread allocation of them with help from the `ThreadLocal` class. Non-parallel code can use `alloc` directly.
][
  由于 `pmr::monotonic_buffer_resource` 类无法在没有互斥的情况下被多个线程并发使用，因此在 BVH 构建过程中需要并行执行的部分中，每个线程使用 `ThreadLocal` 类的帮助进行分配。 非并行执行的代码可以直接使用 `alloc`。
]

```cpp
<<Declare Allocators used for BVH construction>>=
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

#parec[
  If the HLBVH construction algorithm has been selected, `buildHLBVH()` is called to build the tree. The other three construction algorithms are all handled by `buildRecursive()`. The initial calls to these functions are passed all the primitives to be stored. Each returns a pointer to the root of a BVH for the primitives they are given, which is represented with the `BVHBuildNode` structure and the total number of nodes created, which is stored in `totalNodes`. This value is represented by a `std::atomic` variable so that it can be modified correctly by multiple threads executing in parallel.
][
  如果选择 HLBVH 作为构建算法，则调用 `buildHLBVH()` 来构建树。其他三种构建算法都由 `buildRecursive()` 处理。初始调用这些函数时，需传递要存储的所有图元。每个函数返回一个指向其给定图元的 BVH 根节点的指针，该节点由 `BVHBuildNode` 结构表示，并且创建的节点总数存储在 `totalNodes` 中。 由于它是一个 `std::atomic` 变量，因此可以由多个并行执行的线程正确修改。
]

```cpp
<<Build BVH according to selected splitMethod>>=
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


#parec[
  Each `BVHBuildNode` represents a node of the BVH. All nodes store a `Bounds3f` that represents the bounds of all the children beneath the node. Each interior node stores pointers to its two children in `children`. Interior nodes also record the coordinate axis along which primitives were partitioned for distribution to their two children; this information is used to improve the performance of the traversal algorithm. Leaf nodes record which primitive or primitives are stored in them; the elements of the `BVHAggregate::primitives` array from the offset `firstPrimOffset` up to but not including `firstPrimOffset + nPrimitives` are the primitives in the leaf.(This is why the primitives array needs to be reordered—so that this representation can be used, rather than, for example, storing a variable-sized array of primitive indices at each leaf node.)
][
  每个 `BVHBuildNode` 表示 BVH 的一个节点。所有节点存储一个 `Bounds3f`，表示节点下方所有子节点的包围盒。 每个内部节点（非叶子节点）在 `children` 中存储指向其两个子节点的指针。内部节点还记录划分两个子节点时是沿哪个坐标轴；此信息用于提高遍历算法的性能。 叶节点记录存储在其中的哪个或哪些图元；叶子节点的图元存储在`BVHAggregate::primitives` 数组的从偏移量 `firstPrimOffset` 到 `firstPrimOffset + nPrimitives`（不包括）里。（这就是为什么需要重新排序图元数组——以便可以使用这种表示，而不是例如在每个叶节点存储一个可变大小的图元索引数组。）
]

```cpp
<<BVHBuildNode Definition>>=
struct BVHBuildNode {
    <<BVHBuildNode Public Methods>>
    Bounds3f bounds;
    BVHBuildNode *children[2];
    int splitAxis, firstPrimOffset, nPrimitives;
};
```


#parec[
  We will distinguish between leaf and interior nodes by whether their child pointers have the value `nullptr` or not, respectively.
][
  我们通过检查其子指针是否为 `nullptr` 来区分叶节点和内部节点。
]

```cpp
<<BVHBuildNode Public Methods>>=
void InitLeaf(int first, int n, const Bounds3f &b) {
    firstPrimOffset = first;
    nPrimitives = n;
    bounds = b;
    children[0] = children[1] = nullptr;
}
```

#parec[
  The `InitInterior()` method requires that the two child nodes already have been created, so that their pointers can be passed in. This requirement makes it easy to compute the bounds of the interior node, since the children bounds are immediately available.
][
  `InitInterior()` 方法要求两个子节点已经被创建，以便可以传递它们的指针。这个要求使得计算内部节点的边界变得容易，因为子节点的边界立即可用。
]


```cpp
<<BVHBuildNode Public Methods>>+=
void InitInterior(int axis, BVHBuildNode *c0, BVHBuildNode *c1) {
    children[0] = c0;
    children[1] = c1;
    bounds = Union(c0->bounds, c1->bounds);
    splitAxis = axis;
    nPrimitives = 0;
}
```

#parec[
  In addition to the allocators used for BVH nodes and the array of `BVHPrimitive` structures, `buildRecursive()` takes a pointer `totalNodes` that is used to track the total number of BVH nodes that have been created; this value makes it possible to allocate exactly the right number of the more compact `LinearBVHNode`s later.
][
  除了用于 BVH 节点和 `BVHPrimitive` 结构数组的分配器外，`buildRecursive()` 还接受一个指针 `totalNodes`，用于跟踪已创建的 BVH 节点总数；此值使得稍后可以准确地分配所需更紧凑的 `LinearBVHNode` 的数量。
]

#parec[
  The `orderedPrims` array is used to store primitive references as primitives are stored in leaf nodes of the tree. It is initially allocated with enough entries to store all the primitives, though all entries are `nullptr`. When a leaf node is created, `buildRecursive()` claims enough entries in the array for its primitives; `orderedPrimsOffset` starts at 0 and keeps track of where the next free entry is. It, too, is an atomic variable so that multiple threads can allocate space from the array concurrently. Recall that when tree construction is finished, `BVHAggregate::primitives` is replaced with the ordered primitives array created here.
][
  `orderedPrims` 数组用于在树的叶节点中存储图元引用。它最初分配了足够的条目以存储所有图元，尽管所有条目都是 `nullptr`。 当创建叶节点时，`buildRecursive()` 声明数组中足够的条目用于其图元；`orderedPrimsOffset` 从 0 开始并跟踪下一个空闲条目的位置。 它也是一个原子变量，因此多个线程可以同时从数组中分配空间。 请记住，当树构建完成时，`BVHAggregate::primitives` 将被此处创建的有序图元数组替换。
]


```cpp
<<BVHAggregate Method Definitions>>+=
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


#parec[
  If `bvhPrimitives` has only a single primitive, then the recursion has bottomed out and a leaf node is created. Otherwise, this method partitions its elements using one of the partitioning algorithms and reorders the array elements so that they represent the partitioned subsets. If the partitioning is successful, these two primitive sets are in turn passed to recursive calls that will themselves return pointers to nodes for the two children of the current node.
][
  如果 `bvhPrimitives` 中只有一个图元，则递归结束，并创建一个叶节点。否则，此方法将使用某一种划分算法对其元素进行分区，并重新排列数组元素，使其表示划分后的子集。 如果划分成功，这两个图元集依次传递给递归调用，这些调用将返回当前节点的两个子节点的指针。
]

```cpp
<<Initialize BVHBuildNode for primitive range>>=
++*totalNodes;
<<Compute bounds of all primitives in BVH node>>
if (bounds.SurfaceArea() == 0 || bvhPrimitives.size() == 1) {
    <<Create leaf BVHBuildNode>>
} else {
    <<Compute bound of primitive centroids and choose split dimension dim>>
    <<Partition primitives into two sets and build children>>
}
```

#parec[
  The primitive bounds will be needed regardless of whether an interior or leaf node is created, so they are computed before that determination is made.
][
  无论是创建内部节点还是叶节点，都需要有图元（集）的基本，因此在做出（划分的）决定之前计算它们。
]

```cpp
<<Compute bounds of all primitives in BVH node>>=
Bounds3f bounds;
for (const auto &prim : bvhPrimitives)
    bounds = Union(bounds, prim.bounds);
```
#parec[
  At leaf nodes, the primitives overlapping the leaf are appended to the `orderedPrims` array and a leaf node object is initialized. Because `orderedPrimsOffset` is a `std::atomic` variable and `fetch_add()` is an atomic operation, multiple threads can safely perform this operation concurrently without further synchronization: each one is able to allocate its own span of the `orderedPrimitives` array that it can then safely write to.
][
  在叶节点中，与叶节点重叠的图元被附加到 `orderedPrims` 数组中，并初始化一个叶节点对象。 由于 `orderedPrimsOffset` 是一个 `std::atomic` 变量，并且 `fetch_add()` 是一个原子操作，因此多个线程可以安全地同时执行此操作而无需进一步的同步：每个线程都能够分配自己的 `orderedPrimitives` 数组范围，然后可以安全地写入。
]

```cpp
<<Create leaf BVHBuildNode>>=
int firstPrimOffset = orderedPrimsOffset->fetch_add(bvhPrimitives.size());
for (size_t i = 0; i < bvhPrimitives.size(); ++i) {
    int index = bvhPrimitives[i].primitiveIndex;
    orderedPrims[firstPrimOffset + i] = primitives[index];
}
node->InitLeaf(firstPrimOffset, bvhPrimitives.size(), bounds);
return node;
```

#parec[
  For interior nodes, the collection of primitives must be partitioned between the two children's subtrees. Given $n$ primitives, there are in general $2^(n - 1) - 2$ possible ways to partition them into two non-empty groups. In practice when building BVHs, one generally considers partitions along a coordinate axis, meaning that there are about $3 n$ candidate partitions. (Along each axis, each primitive may be put into the first partition or the second partition.)
][
  对于内部节点，必须在两个子树之间划分图元集合。给定 $n$ 个图元，通常有 $2^(n - 1) - 2$ 种可能的方法将它们划分为两个非空组。 在构建 BVH 时，通常考虑沿坐标轴的分区，这意味着大约有 $3 n$ 个候选分区。（沿每个轴，每个图元可以放入第一个分区或第二个分区。）
]

#parec[
  Here, we choose just one of the three coordinate axes to use in partitioning the primitives. We select the axis with the largest extent of bounding box centroids for the primitives in `bvhPrimitives`. An alternative would be to try partitioning the primitives along all three axes and select the one that gave the best result, but in practice this approach works well. This approach gives good partitions in many scenes; @fig:bvh-centroid-axis illustrates the strategy.
][
  在这里，我们选择一个坐标轴用于分割图元。我们选择 `bvhPrimitives` 中图元边界框质心的最大范围的轴。 另一种方法是尝试沿所有三个轴分割图元，并选择结果最好的一个，但实际上这种方法效果很好。 这种方法在许多场景中提供了良好的分区；@fig:bvh-centroid-axis 说明了这一策略。
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
  通常的目标是选择一个图元分区，使得两个结果图元集合的边界框没有太多重叠——如果有大量重叠，那么在遍历树时更频繁地需要遍历两个子树，就需要比能够更有效地修剪掉图元集合更多的计算。 这个寻找有效图元分区的想法将在不久后的讨论中，通过表面积启发式方法进行更严格的讨论。
]

```cpp
<<Compute bound of primitive centroids and choose split dimension dim>>=
Bounds3f centroidBounds;
for (const auto &prim : bvhPrimitives)
    centroidBounds = Union(centroidBounds, prim.Centroid());
int dim = centroidBounds.MaxDimension();
```


#parec[
  If all the centroid points are at the same position (i.e., the centroid bounds have zero volume), then recursion stops and a leaf node is created with the primitives; none of the splitting methods here is effective in that (unusual) case. The primitives are otherwise partitioned using the chosen method and passed to two recursive calls to buildRecursive().
][
  如果所有质心点都位于同一位置（即质心的边界体积为零），则递归停止，并为这些图元创建一个叶节点；在这种（不常见的）情况下，任何分割方法都不起作用。否则，图元将使用所选的方法进行划分，并传递给两个递归调用来执行 `buildRecursive()`。
]


```cpp
<<Partition primitives into two sets and build children>>=
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

#parec[
  The two recursive calls access independent data, other than when they allocate space in the `orderedPrims` array by incrementing `orderedPrimsOffset`, which we already have seen is thread safe. Therefore, when there are a reasonably large number of active primitives, those calls can be performed in parallel, which improves the performance of BVH construction.
][
  两个递归调用访问独立的数据，除了当它们通过增加 `orderedPrimsOffset` 在 `orderedPrims` 数组中分配空间时，这已经被证明是线程安全的。因此，当有相当多的活动基本体时，这些调用可以并行执行，从而提高 BVH 构建的性能。
]


```cpp
<<Recursively build BVHs for children>>=
if (bvhPrimitives.size() > 128 * 1024) {
    <<Recursively build child BVHs in parallel>>
} else {
    <<Recursively build child BVHs sequentially>>
}
```

#parec[
  A parallel `for` loop over two items is sufficient to expose the available parallelism. With `pbrt`'s implementation of `ParallelFor()`, the current thread will end up handling the first recursive call, while another thread, if available, can take the second. `ParallelFor()` does not return until all the loop iterations have completed, so we can safely proceed, knowing that both `children` are fully initialized when it does.
][
  一个并行 `for` 循环遍历两个项目足以暴露可用的并行性。使用 `pbrt` 的 `ParallelFor()` 实现，当前线程将处理第一个递归调用，而另一个线程（如果可用）可以处理第二个。`ParallelFor()` 在所有循环迭代完成之前不会返回，因此我们可以安全地继续，知道当它完成时，两个 `children` 都已完全初始化。
]

```cpp
// **<<Recursively build child BVHs in parallel>>**=
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

#parec[
  The code for the non-parallel case, `<<Recursively build child BVHs sequentially>>`, is equivalent, just without the parallel `for` loop. We have therefore not included it here.
][
  非并行情况下的代码 `<<Recursively build child BVHs sequentially>>` 是等效的，只是没有并行 `for` 循环。因此，我们在此不包括它。
]

#parec[
  We also will not include the code fragment `<<Partition primitives based on splitMethod>>` here; it just uses the value of `BVHAggregate::splitMethod` to determine which primitive partitioning scheme to use. These three schemes will be described in the following few pages.
][
  我们也不会在此处包括代码片段 `<<Partition primitives based on splitMethod>>`；它只是使用 `BVHAggregate::splitMethod` 的值来确定使用哪个基本体分区方案。接下来的几页将描述这三种方案。
]

#parec[
  A simple `splitMethod` is `Middle`, which first computes the midpoint of the primitives' centroids along the splitting axis. This method is implemented in the fragment `<<Partition primitives through node's midpoint>>`. The primitives are classified into the two sets, depending on whether their centroids are above or below the midpoint. This partitioning is easily done with the `std::partition()` C++ standard library function, which takes a range of elements in an array and a comparison function and orders the elements in the array so that all the elements that return `true` for the given predicate function appear in the range before those that return `false` for it. `std::partition()` returns a pointer to the first element that had a `false` value for the predicate. Figure 7.5 illustrates this approach, including cases where it does and does not work well.
][
  一个简单的 `splitMethod` 是 `Middle`，它首先计算沿分割轴的基本体质心的中点。此方法在代码片段 `<<通过节点的中点分割基本体>>` 中实现。基本体根据其质心是否高于或低于中点被分类为两组。使用 C++ 标准库函数 `std::partition()` 可以轻松完成这种分区，该函数接受数组中元素的范围和比较函数，并对数组中的元素进行排序，以便所有对给定谓词函数返回 `true` 的元素出现在对其返回 `false` 的元素之前的范围内。`std::partition()` 返回指向第一个对谓词返回 `false` 的元素的指针。图 7.5 说明了这种方法，包括它在某些情况下是否有效。
]

#parec[
  If the primitives all have large overlapping bounding boxes, this splitting method may fail to separate the primitives into two groups. In that case, execution falls through to the `SplitMethod::EqualCounts` approach to try again.
][
  如果所有基本体都有大的重叠边界框，则此分割方法可能无法将基本体分为两组。在这种情况下，执行将通过到 `SplitMethod::EqualCounts` 方法再次尝试。
]


```cpp
// <<Partition primitives through node’s midpoint>>
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

#parec[
  When `splitMethod` is `SplitMethod::EqualCounts`, the `<<Partition primitives into equally sized subsets>>` fragment runs. It partitions the primitives into two equal-sized subsets such that the first half of the $n$ of them are the $n \/ 2$ with smallest centroid coordinate values along the chosen axis, and the second half are the ones with the largest centroid coordinate values. While this approach can sometimes work well, the case in Figure 7.5(b) is one where this method also fares poorly.
][
  当 `splitMethod` 为 `SplitMethod::EqualCounts` 时，运行代码片段 `<<Partition primitives into equally sized subsets>>` 。它将基本体分为两个等大小的子集，使得前 $n$ 个中的一半是质心坐标值沿选定轴最小的 $n \/ 2$ 个，后半部分是质心坐标值最大的那些。虽然这种方法有时效果很好，但图 7.5(b) 是这种方法表现不佳的一个例子。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f05.svg"),
  caption: [#ez_caption[
      *Splitting Primitives Based on the Midpoint of Centroids on an Axis.*(a) For some distributions of primitives, such as the one shown here, splitting based on the midpoint of the centroids along the chosen axis (thick vertical line) works well. (The bounding boxes of the two resulting primitive groups are shown with dashed lines.) (b) For distributions like this one, the midpoint is a suboptimal choice; the two resulting bounding boxes overlap substantially. (c) If the same group of primitives from (b) is instead split along the line shown here, the resulting bounding boxes are smaller and do not overlap at all, leading to better performance when rendering.
    ][
      *基于轴上质心中点分割基本体。* (a) 对于某些基本体分布，如图所示，基于沿选定轴的质心中点（粗垂直线）进行分割效果很好。（两个结果基本体组的边界框用虚线表示。）(b) 对于像这样的分布，中点是一个次优选择；两个结果边界框大幅重叠。(c) 如果从 (b) 的相同基本体组改为沿图示线分割，结果边界框更小且完全不重叠，从而在渲染时提高性能。
    ]],
)

#parec[
  This scheme is also easily implemented with a standard library call, `std::nth_element()`. It takes a start, middle, and ending iterator as well as a comparison function. It orders the array so that the element at the middle iterator is the one that would be there if the array was fully sorted, and such that all the elements before the middle one compare to less than the middle element and all the elements after it compare to greater than it. This ordering can be done in $O(n)$ time, with $n$ the number of elements, which is more efficient than the $O(n log n)$ cost of completely sorting the array.
][
  这种方案也可以通过调用标准库中的 `std::nth_element()` 轻松实现。它接受一个开始、中间和结束迭代器以及一个比较函数。它对数组进行排序，使得中间迭代器处的元素是如果数组完全排序时会在那里的元素，并且使得所有在中间元素之前的元素与中间元素比较小，所有在中间元素之后的元素与中间元素比较大。这种排序可以在 $O(n)$ 时间内完成，其中 $n$ 是元素数量，比完全排序数组的 $O(n log n)$ 成本更高效。
]


```cpp
// <<Partition primitives into equally sized subsets>>
mid = bvhPrimitives.size() / 2;
std::nth_element(bvhPrimitives.begin(), bvhPrimitives.begin() + mid,
                 bvhPrimitives.end(),
    [dim](const BVHPrimitive &a, const BVHPrimitive &b) {
        return a.Centroid()[dim] < b.Centroid()[dim];
    });
```


=== The Surface Area Heuristic
<the-surface-area-heuristic>


#parec[
  The two primitive partitioning approaches described so far can work well for some distributions of primitives, but they often choose partitions that perform poorly in practice, leading to more nodes of the tree being visited by rays and hence unnecessarily inefficient ray–primitive intersection computations at rendering time. Most of the best current algorithms for building acceleration structures for ray tracing are based on the "surface area heuristic" (SAH), which provides a well-grounded cost model for answering questions like "which of a number of partitions of primitives will lead to a better BVH for ray–primitive intersection tests?" or "which of a number of possible positions to split space in a spatial subdivision scheme will lead to a better acceleration structure?"
][
  到目前为止描述的两种原始分区方法对于某些图元的分布可能效果很好，但它们通常选择的分区在实践中表现不佳，导致更多的树节点被光线访问，从而在渲染时导致光线-图元相交计算效率低下。 目前大多数用于构建光线追踪加速结构的最佳算法都基于“表面积启发式”（SAH），它提供了一个有理论依据的成本模型，用于回答诸如“哪种图元分区将导致更好的 BVH 进行光线-图元相交测试？”或“在空间细分方案中，哪种可能的位置分割空间将导致更好的加速结构？”等问题。
]

#parec[
  The SAH model estimates the computational expense of performing ray intersection tests, including the time spent traversing nodes of the tree and the time spent on ray–primitive intersection tests for a particular partitioning of primitives. Algorithms for building acceleration structures can then follow the goal of minimizing total cost. Typically, a greedy algorithm is used that minimizes the cost for each single node of the hierarchy being built individually.
][
  SAH 模型估算了执行光线相交测试的计算开销，包括遍历树节点的时间和针对特定图元分区的光线-图元相交测试的时间。 构建加速结构的算法可以遵循最小化总成本的目标。通常，使用贪心算法来分别最小化每个构建中的层次节点的成本。
]

#parec[
  The ideas behind the SAH cost model are straightforward: at any point in building an adaptive acceleration structure (primitive subdivision or spatial subdivision), we could just create a leaf node for the current region and geometry. In that case, any ray that passes through this region will be tested against all the overlapping primitives and will incur a cost of
][
  SAH 成本模型背后的思想很简单：在构建自适应加速结构（图元细分或空间细分）的任何时候，我们可以为当前区域和几何体创建一个终端节点。 在这种情况下，任何通过该区域的光线都将与所有重叠的图元进行测试，并将产生一个成本
]
$ sum_(i = 1)^n t_"isect" (i) $
#parec[
  where $n$ is the number of primitives and $t_"isect" (i)$ is the time to compute a ray–object intersection with the $i$ th primitive.
][
  其中 $n$ 是图元的数量， $t_"isect"(i)$ 是计算光线与第 $i$ 个图元相交的时间。
]

#parec[
  The other option is to split the region. In that case, rays will incur the cost
][
  另一种选择是分割区域。在这种情况下，光线将产生成本
]
$
  c (A , B) = t_"trav" + p_A sum_(i = 1)^(n_A) t_"isect"(a_i) + p_B sum_(i = 1)^(n_B) t_"isect"(b_i)
$<sah>

#parec[
  where $t_"trav"$ is the time it takes to traverse the interior node and determine which of the children the ray passes through, $p_A$ and $p_B$ are the probabilities that the ray passes through each of the child nodes (assuming binary subdivision), $a_i$ and $b_i$ are the indices of primitives in the two child nodes, and $n_A$ and $n_B$ are the number of primitives that overlap the regions of the two child nodes, respectively. The choice of how primitives are partitioned affects the values of the two probabilities as well as the set of primitives on each side of the split.
][
  其中 $t_"trav"$ 是遍历内部节点并确定光线通过哪个子节点所需的时间， $p_A$ 和 $p_B$ 是光线通过每个子节点的概率（假设二进制细分）， $a_i$ 和 $b_i$ 是两个子节点中图元的索引， $n_A$ 和 $n_B$ 分别是与两个子节点区域重叠的图元数量。 图元如何分区的选择会影响两个概率的值以及分割后每侧的图元集合。
]

#parec[
  In `pbrt`, we will make the simplifying assumption that $t_(i s e c t) (i)$ is the same for all the primitives; this assumption is probably not too far from reality, and any error that it introduces does not seem to affect the performance of accelerators very much. Another possibility would be to add a method to `Primitive` that returned an estimate of the number of processing cycles that its intersection test requires.
][
  在 `pbrt` 中，我们假设所有图元的 $t_(i s e c t) (i)$ 是相同的；这个假设可能与现实相差不大，并且其引入的误差似乎对加速器性能影响不大。 另一种可能性是为 `Primitive` 添加一种方法，该方法返回其相交测试所需的处理周期数的估计值。
]

#parec[
  The probabilities $p_A$ and $p_B$ can be computed using ideas from geometric probability. It can be shown that for a convex volume $A$ contained in another convex volume $B$, the conditional probability that a uniformly distributed random ray passing through $B$ will also pass through $A$ is the ratio of their surface areas, $s_A$ and $s_B$ :
][
  概率 $p_A$ 和 $p_B$ 可以使用几何概率的思想来计算。 可以证明，对于一个凸体 $A$ 包含在另一个凸体 $B$ 中，均匀分布的随机光线通过 $B$ 也通过 $A$ 的条件概率等于它们表面积的比率，即 $s_A$ 和 $s_B$。
]


$ p (A divides B) = s_B / s_A upright(".") $


#parec[
  Because we are interested in the cost for rays passing through the node, we can use this result directly. Thus, if we are considering refining a region of space $A$ such that there are two new subregions with bounds $B$ and $C$ (@fig:bvh-abc-probabilities), the probability that a ray passing through $A$ will also pass through either of the subregions is easily computed.
][
  因为我们对穿过节点的光线的成本感兴趣，所以可以直接使用这个结果。因此，如果我们考虑细化空间区域 $A$，使得有两个新的子区域，其边界为 $B$ 和 $C$ （@fig:bvh-abc-probabilities），那么光线穿过 $A$ 也会穿过任一子区域的概率很容易计算。
]

#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f06.svg"),
  caption: [
    #ez_caption[If a node of the bounding hierarchy with surface area
      $s_A$ is split into two children with surface areas $s_B$ and $s_C$,
      the probabilities that a ray passing through $A$ also passes through
      $B$ and $C$ are given by $s_B \/ s_A$ and $s_C \/ s_A$, respectively.][如果一个表面面积为 $s_A$
      的边界层次节点被分割成两个子节点，其表面面积为 $s_B$ 和
      $s_C$，那么光线穿过 $A$ 也穿过 $B$ 和 $C$ 的概率分别为 $s_B \/ s_A$
      和 $s_C \/ s_A$。]
  ],
)<bvh-abc-probabilities>
#parec[
  When `splitMethod` has the value `SplitMethod::SAH`, the SAH is used for building the BVH; a partition of the primitives along the chosen axis that gives a minimal SAH cost estimate is found by considering a number of candidate partitions. (This is the default `SplitMethod`, and it creates the most efficient hierarchies of the partitioning options.) However, once it has refined down to two primitives, the implementation switches over to directly partitioning them in half. The incremental computational cost for applying the SAH at that point is not beneficial.
][
  当 `splitMethod` 的值为 `SplitMethod::SAH` 时，表面积启发式 (SAH) 用于构建 BVH；通过考虑多个候选分区，沿选择的轴找到一个给出最小 SAH 成本估计的原始分区。（这是默认的 `SplitMethod`，它创建了最有效的分区层次结构选项。）然而，一旦细化到两个原始体，实施就会切换到直接将它们分成两半。在那时应用 SAH 的增量计算成本并不有利。
]

```cpp
<<Partition primitives using approximate SAH>>=
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


#parec[
  Rather than exhaustively considering all $2^n$ possible partitions along the axis, computing the SAH for each to select the best, the implementation here instead divides the range along the axis into a small number of buckets of equal extent. It then only considers partitions at bucket boundaries. This approach is more efficient than considering all partitions while usually still producing partitions that are nearly as effective. This idea is illustrated in @fig:bvh-sah-buckets .
][
  而不是穷尽地考虑沿轴的所有 $2^n$ 个可能分区，计算每个的 SAH 以选择最佳的，这里的实现将轴上的范围划分为少量等距的桶。然后它只考虑在桶边界处的分区。这种方法比考虑所有分区更有效，同时通常仍然产生几乎同样有效的分区。这个想法在@fig:bvh-sah-buckets 中有所说明。
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
      的分割平面。原始体边界质心的投影范围被投影到所选的分割轴上。每个原始体根据其边界的质心被放置在轴上的一个桶中。然后实现估计使用每个桶边界（实线垂直线）处的平面分割原始体的成本；选择表面积启发式给出最小成本的那个。
    ]
    Figure 7.7:
  ],
)<bvh-sah-buckets>


```cpp
//<<BVHSplitBucket Definition>>=
struct BVHSplitBucket {
    int count = 0;
    Bounds3f bounds;
};
```


#parec[
  We have found that 12 buckets usually work well in practice. An improvement may be to increase this value when there are many primitives and to decrease it when there are few.
][
  我们发现 12 个桶通常在实践中效果很好。一个改进可能是在有很多原始体时增加这个值，而在原始体较少时减少它。
]

```cpp
constexpr int nBuckets = 12;
BVHSplitBucket buckets[nBuckets];
```


#parec[
  For each primitive, the following fragment determines the bucket that its centroid lies in and updates the bucket's bounds to include the primitive's bounds.
][
  对于每个原始体，以下片段确定其质心所在的桶，并更新桶的边界以包含原始体的边界。
]

```cpp
for (const auto &prim : bvhPrimitives) {
    int b = nBuckets * centroidBounds.Offset(prim.Centroid())[dim];
    if (b == nBuckets) b = nBuckets - 1;
    buckets[b].count++;
    buckets[b].bounds = Union(buckets[b].bounds, prim.bounds);
}
```


#parec[
  For each bucket, we now have a count of the number of primitives and the bounds of all of their respective bounding boxes. We want to use the SAH to estimate the cost of splitting at each of the bucket boundaries. The fragment below loops over all the buckets and initializes the `cost[i]` array to store the estimated SAH cost for splitting after the $i$ th bucket. (It does not consider a split after the last bucket, which by definition would not split the primitives.)
][
  对于每个桶，我们现在有了原始体数量的计数和所有相应边界框的边界。我们想使用 SAH 来估计在每个桶边界处分割的成本。下面的片段遍历所有桶并初始化 `cost[i]` 数组以存储在 $i$ 个桶之后分割的估计 SAH 成本。（它不考虑在最后一个桶之后的分割，定义上这不会分割原始体。）
]

#parec[
  We arbitrarily set the estimated intersection cost to 1, and then set the estimated traversal cost to $1 \/ 2$. (One of the two of them can always be set to 1 since it is the relative, rather than absolute, magnitudes of the estimated traversal and intersection costs that determine their effect.) However, not only is the absolute amount of computation necessary for node traversal—a ray–bounding box intersection—much less than the amount of computation needed to intersect a ray with a shape, the full cost of a shape intersection test is even higher. It includes the overhead of at least two instances of dynamic dispatch (one or more via #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive];s and one via a `Shape`), the cost of computing all the geometric information needed to initialize a #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] if an intersection is found, and any resulting costs from possibly applying additional transformations and interpolating animated transformations.
][
  我们任意地将估计的交叉成本设置为 1，然后将估计的遍历成本设置为 $1 \/ 2$。（两者之一总是可以设置为 1，因为是相对而不是绝对的遍历和交叉成本的大小决定了它们的效果。）然而，不仅节点遍历所需的计算量——光线-边界框交叉——远小于与形状交叉所需的计算量，形状交叉测试的完整成本甚至更高。它包括至少两个动态调度实例的开销（一个或多个通过 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive];s 和一个通过 `Shape`），如果找到交叉，则需要初始化 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 的所有几何信息的计算成本，以及可能应用额外变换和插值动画变换的任何结果成本。
]

#parec[
  We have intentionally underestimated the performance ratio between these two costs because the raw amount of computation each performs does not measure their full expense. With a lower traversal cost, the resulting BVHs would be deeper and require more nodes. For complex scenes, this additional memory use may be undesirable. Even for simpler scenes, visiting more nodes when a ray is traced will generally incur the cost of cache misses, which not only may reduce performance for that ray, but may harm future performance from displacing other useful data from the cache. We have found the $2 : 1$ ratio that we have used here to make a reasonable trade-off between all of these issues.
][
  我们故意低估了这两种成本之间的性能比，因为每种执行的计算量并不能衡量其全部开销。使用较低的遍历成本，生成的 BVH 将更深并需要更多节点。对于复杂场景，这种额外的内存使用可能是不可取的。即使对于较简单的场景，当光线被追踪时访问更多节点通常会导致缓存未命中，这不仅可能降低该光线的性能，还可能因从缓存中移除其他有用数据而损害未来的性能。我们发现这里使用的 $2 : 1$ 比例在所有这些问题之间做出了合理的权衡。
]

#parec[
  In order to be able to choose a split in linear time, the implementation first performs a forward scan over the buckets and then a backward scan over the buckets that incrementally compute each bucket's cost.#footnote[Previous versions of <tt>pbrt</tt> instead computed these values
from scratch for each candidate split, which resulted in <i>O</i>(<i>n</i><sup>2</sup>)
performance.  Even with the small <i>n</i> here, we have found that this
implementation speeds up BVH construction by approximately 2×.] There is one fewer candidate split than the number of buckets, since all splits are between pairs of buckets.
][
  为了能够在线性时间内选择一个分割，实施首先对桶进行向前扫描，然后对桶进行向后扫描，逐步计算每个桶的成本。#footnote[以前版本的 <tt>pbrt</tt> 会为每个候选分割从头计算这些值，导致性能为 <i>O</i>(<i>n</i><sup>2</sup>)。即使这里的 <i>n</i> 很小，我们发现这种实现可以将 BVH 构建速度提升约 2 倍。] 候选分割的数量比桶的数量少一个，因为所有分割都在桶对之间。
]


```cpp
<<Compute costs for splitting after each bucket>>=
constexpr int nSplits = nBuckets - 1;
Float costs[nSplits] = {};
<<Partially initialize costs using a forward scan over splits>>
<<Finish initializing costs using a backward scan over splits>>
```

#parec[
  The loop invariant is that `countBelow` stores the number of primitives that are below the corresponding candidate split, and `boundsBelow` stores their bounds. With these values in hand, the value of the first sum in @eqt:sah can be evaluated for each split.
][
  循环不变式是 `countBelow` 存储在相应候选分割下的原始体数量，而 `boundsBelow` 存储它们的边界。手头有这些值后，可以为每个分割评估@eqt:sah 中第一个和的值。
]

```cpp
int countBelow = 0;
Bounds3f boundBelow;
for (int i = 0; i < nSplits; ++i) {
    boundBelow = Union(boundBelow, buckets[i].bounds);
    countBelow += buckets[i].count;
    costs[i] += countBelow * boundBelow.SurfaceArea();
}
```

#parec[
  A similar backward scan over the buckets finishes initializing the `costs` array.
][
  对桶的类似向后扫描完成了 `costs` 数组的初始化。
]

```cpp
int countAbove = 0;
Bounds3f boundAbove;
for (int i = nSplits; i >= 1; --i) {
    boundAbove = Union(boundAbove, buckets[i].bounds);
    countAbove += buckets[i].count;
    costs[i - 1] += countAbove * boundAbove.SurfaceArea();
}
```


#parec[
  Given all the costs, a linear search over the potential splits finds the partition with minimum cost.
][
  给定所有成本，通过潜在分割的线性搜索找到具有最小成本的分区。
]

```cpp
int minCostSplitBucket = -1;
Float minCost = Infinity;
for (int i = 0; i < nSplits; ++i) {
    // Compute cost for candidate split and update minimum if necessary
    if (costs[i] < minCost) {
        minCost = costs[i];
        minCostSplitBucket = i;
    }
}
// Compute leaf cost and SAH split cost for chosen split
Float leafCost = bvhPrimitives.size();
minCost = 1.f / 2.f + minCost / bounds.SurfaceArea();
```

#parec[
  To find the best split, we evaluate a simplified version of Equation (7.1), neglecting the traversal cost and the division by the surface area of the bounding box of all the primitives to compute the probabilities $p_A$ and $p_B$ ; these have no effect on the choice of the best split. That cost is precisely what is stored in `costs`, so the split with minimum cost is easily found.
][
  为了找到最佳分割，我们评估方程 (7.1) 的简化版本，忽略遍历成本和通过所有原始体的边界框表面积计算概率 $p_A$ 和 $p_B$ 的除法；这些对最佳分割的选择没有影响。该成本正是存储在 `costs` 中的，因此很容易找到具有最小成本的分割。
]

```cpp
if (costs[i] < minCost) {
    minCost = costs[i];
    minCostSplitBucket = i;
}
```

#parec[
  To compute the final SAH cost for a split, we need to divide by the surface area of the overall bounding box to compute the probabilities $p_A$ and $p_B$ before adding the estimated traversal cost, $1\/2$. Because we set the estimated intersection cost to 1 previously, the estimated cost for just creating a leaf node is equal to the number of primitives.
][
  为了计算分割的最终 SAH 成本，我们需要通过整体边界框的表面积来计算概率 $p_A$ 和 $p_B$，然后添加估计的遍历成本 $1\/2$。因为我们之前将估计的交叉成本设置为 1，所以仅创建叶节点的估计成本等于原始体的数量。
]

```cpp
Float leafCost = bvhPrimitives.size();
minCost = 1.f / 2.f + minCost / bounds.SurfaceArea();
```


#parec[
  If the chosen bucket boundary for partitioning has a lower estimated cost than building a node with the existing primitives or if more than the maximum number of primitives allowed in a node is present, the `std::partition()` function is used to do the work of reordering nodes in the `bvhPrimitives` array. Recall from its use earlier that it ensures that all elements of the array that return `true` from the given predicate appear before those that return `false` and that it returns a pointer to the first element where the predicate returns `false`.
][
  如果用于分区的所选桶边界的估计成本低于使用现有原始体构建节点的成本，或者节点中存在的原始体数量超过允许的最大数量，则使用 `std::partition()` 函数来重新排序 `bvhPrimitives` 数组中的节点。回想一下它之前的使用，它确保数组中所有从给定谓词返回 `true` 的元素出现在返回 `false` 的元素之前，并且返回指向谓词返回 `false` 的第一个元素的指针。
]

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
    // Create leaf BVHBuildNode
    int firstPrimOffset = orderedPrimsOffset->fetch_add(bvhPrimitives.size());
    for (size_t i = 0; i < bvhPrimitives.size(); ++i) {
        int index = bvhPrimitives[i].primitiveIndex;
        orderedPrims[firstPrimOffset + i] = primitives[index];
    }
    node->InitLeaf(firstPrimOffset, bvhPrimitives.size(), bounds);
    return node;
}
```



=== Linear Bounding Volume Hierarchies
<linear-bounding-volume-hierarchies>
#parec[
  While building bounding volume hierarchies using the surface area heuristic gives very good results, that approach does have two disadvantages: first, many passes are taken over the scene primitives to compute the SAH costs at all the levels of the tree. Second, top-down BVH construction is difficult to parallelize well: the approach used in `buildRecursive()`—performing parallel construction of independent subtrees—suffers from limited independent work until the top few levels of the tree have been built, which in turn inhibits parallel scalability. (This second issue is particularly an issue on GPUs, which perform poorly if massive parallelism is not available.)
][
  虽然使用表面积启发式构建包围体层次结构可以得到非常好的结果，但这种方法有两个缺点：首先，需要多次遍历场景中的基本图元来计算树中所有层次的SAH成本。其次，自顶向下的BVH构建难以很好地并行化：在`buildRecursive()`中使用的方法——并行构建独立的子树——在树的前几层构建完成之前，独立工作的数量有限，从而抑制了并行扩展性。（第二个问题在GPU上尤其明显，如果没有大规模的并行性，GPU的性能会很差。）
]

#parec[
  #emph[Linear bounding volume hierarchies] (LBVHs) were developed to address these issues. With LBVHs, the tree is built with a small number of lightweight passes over the primitives; tree construction time is linear in the number of primitives. Further, the algorithm quickly partitions the primitives into clusters that can be processed independently. This processing can be fairly easily parallelized and is well suited to GPU implementation.
][
  #emph[线性包围体层次结构];（LBVH）是为了解决这些问题而开发的。使用LBVH，树的构建只需对基本图元进行少量的轻量级遍历；树的构建时间与基本图元的数量成线性关系。此外，该算法快速地将基本图元划分为可以独立处理的簇。这种处理可以相对容易地并行化，并且非常适合GPU实现。
]

#parec[
  The key idea behind LBVHs is to turn BVH construction into a sorting problem. Because there is no single ordering function for sorting multidimensional data, LBVHs are based on #emph[Morton codes];, which map nearby points in $n$ dimensions to nearby points along the 1D line, where there is an obvious ordering function. After the primitives have been sorted, spatially nearby clusters of primitives are in contiguous segments of the sorted array.
][
  LBVH背后的关键思想是将BVH构建转化为排序问题。由于没有单一的排序函数可以对多维数据进行排序，LBVH基于#emph[Morton编码];，它将 $n$ 维空间中的相邻点映射到1D线上的相邻点，在这里有一个明确的排序函数。在基本图元排序后，空间上相邻的基本图元群位于排序数组的连续段中。
]

#parec[
  Morton codes are based on a simple transformation: given $n$ -dimensional integer coordinate values, their Morton-coded representation is found by interleaving the bits of the coordinates in base 2. For example, consider a 2D coordinate $(x , y)$ where the bits of $x$ and $y$ are denoted by $x_i$ and $y_i$. The corresponding Morton-coded value is
][
  Morton编码基于一个简单的变换：给定 $n$ 维整数坐标值，其Morton编码表示通过在基2中交错坐标的位来获得。例如，考虑一个2D坐标 $(x , y)$，其中 $x$ 和 $y$ 的位分别用 $x_i$ 和 $y_i$ 表示。对应的Morton编码值为

  $ y_3 x_3 y_2 x_2 y_1 x_1 y_0 x_0 . $
]

#parec[
  @fig:morton-curve-basics shows a plot of the 2D points in Morton order—note that they are visited along a path that follows a reversed "z" shape. (The Morton path is sometimes called "z-order" for this reason.) We can see that points with coordinates that are close together in 2D are generally close together along the Morton curve.
][
  @fig:morton-curve-basics 展示了Morton顺序的2D点的图——注意它们沿着一个反向“z”形路径被访问。（由于这个原因，Morton路径有时被称为“z-order”。）我们可以看到，在2D中坐标接近的点沿Morton曲线通常也接近。
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
    and thus $y gt.eq 8$ (Figure 7.9(a)). - The next bit value, $x_3$, splits the $x$ axis in the middle (Figure
    7.9(b)). If $y_3$ is set and $x_3$ is off, for example, then the
    corresponding point must lie in the shaded area of Figure 7.9(c). In
    general, points with a number of matching high bits lie in a
    power-of-two sized and axis-aligned region of space determined by the
    matching bit values. - The value of $y_2$ splits the $y$ axis into four regions (Figure
    7.9(d)).
][
  - 对于一个Morton编码的8位值，如果高位$y_3$被设置，我们就知道其底层$y$坐标的高位被设置，因此$y gt.eq 8$（图7.9(a)）。 - 下一个位值$x_3$将$x$轴分成中间的部分（图7.9(b)）。例如，如果$y_3$被设置而$x_3$未设置，则对应的点必须位于图7.9(c)的阴影区域中。一般来说，具有若干匹配高位的点位于由匹配位值确定的空间的2的幂大小和轴对齐的区域中。 - $y_2$的值将$y$轴分成四个区域（图7.9(d)）。
]


#figure(
  image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f09.svg"),
  caption: [
    #ez_caption[
      mplications of the Morton Encoding. The values of various bits in the Morton value indicate the region of space that the corresponding coordinate lies in. (a) In 2D, the high bit of the Morton-coded value of a point’s coordinates defines a splitting plane along the middle of the $y$ axis. If the high bit is set, the point is above the plane. (b) Similarly, the second-highest bit of the Morton value splits the $x$ axis in the middle. (c) If the high $y$ bit is 1 and the high $x$ bit is 0, then the point must lie in the shaded region. (d) The second-from-highest $y$ bit splits the $y$axis into four regions.
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
  LBVH是通过使用位于空间每个区域中点的分割平面来划分基本图元构建的BVH（即，相当于先前定义的`SplitMethod::Middle`路径）。分区非常高效，因为它利用了上述Morton编码的性质。
]

#parec[
  Just reimplementing `Middle` in a different manner is not particularly interesting, so in the implementation here, we will build a #emph[hierarchical linear bounding volume hierarchy] (HLBVH). With this approach, Morton-curve-based clustering is used to first build trees for the lower levels of the hierarchy (referred to as "treelets" in the following), and the top levels of the tree are then created using the surface area heuristic. The `buildHLBVH()` method implements this approach and returns the root node of the resulting tree.
][
  仅仅以不同方式重新实现`Middle`并没有太大意义，因此在这里的实现中，我们将构建一个#emph[分层线性包围体树];（HLBVH）。通过这种方法，首先使用Morton曲线聚类来构建层次结构的较低层次的“小树”，然后使用表面积启发式创建树的顶层。`buildHLBVH()`方法实现了这种方法，并返回结果树的根节点。
]


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

#parec[
  The BVH is built using only the centroids of primitive bounding boxes to sort them—it does not account for the actual spatial extent of each primitive. This simplification is critical to the performance that HLBVHs offer, but it also means that for scenes with primitives that span a wide range of sizes, the tree that is built will not account for this variation as an SAH-based tree would.
][
  BVH 是仅使用原始边界框的中心点来对它们进行排序来构建的，它没有考虑每个原始物体的实际空间范围。这种简化对于 HLBVH 提供的性能至关重要，但这也意味着对于具有各种大小的原始物体的场景，所构建的树不会像基于 SAH 的树那样考虑这种变化。
]

#parec[
  Because the Morton encoding operates on integer coordinates, we first need to bound the centroids of all the primitives so that we can quantize centroid positions with respect to the overall bounds.
][
  由于莫顿编码在整数坐标上操作，我们首先需要界定所有图元的中心点，以便我们可以根据总体边界对中心点位置进行量化。
]
```cpp
Bounds3f bounds;
for (const BVHPrimitive &prim : bvhPrimitives)
    bounds = Union(bounds, prim.Centroid());
```

#parec[
  Given the overall bounds, we can now compute the Morton code for each primitive. This is a fairly lightweight calculation, but given that there may be millions of primitives, it is worth parallelizing.
][
  在得到总体边界后，我们现在可以为每个原始物体计算莫顿码。这是一个相对轻量级的计算，但考虑到可能有数百万个原始物体，值得并行化。
]

```cpp
std::vector<MortonPrimitive> mortonPrims(bvhPrimitives.size());
ParallelFor(0, bvhPrimitives.size(), [&](int64_t i) {
    <<Initialize mortonPrims[i] for ith primitive>>
    constexpr int mortonBits = 10;
    constexpr int mortonScale = 1 << mortonBits;
    mortonPrims[i].primitiveIndex = bvhPrimitives[i].primitiveIndex;
    Vector3f centroidOffset = bounds.Offset(bvhPrimitives[i].Centroid());
    Vector3f offset = centroidOffset * mortonScale;
    mortonPrims[i].mortonCode = EncodeMorton3(offset.x, offset.y, offset.z);
});
```

#parec[
  A `MortonPrimitive` instance is created for each primitive; it stores the index of the primitive, as well as its Morton code, in the `bvhPrimitives` array.
][
  为每个原始物体创建一个 MortonPrimitive 实例；它在 bvhPrimitives 数组中存储原始物体的索引及其莫顿码。
]

```cpp
struct MortonPrimitive {
    int primitiveIndex;
    uint32_t mortonCode;
};
```
#parec[
  We use 10 bits for each of the $x$, $y$, and $z$ dimensions, giving a total of 30 bits for the Morton code. This granularity allows the values to fit into a single 32-bit variable. Floating-point centroid offsets inside the bounding box are in $[0, 1]$, so we scale them by $2^{10}$ to get integer coordinates that fit in 10 bits. The #link("../Utilities/Mathematical_Infrastructure.html#EncodeMorton3")[EncodeMorton3()] function, which is defined with other bitwise utility functions in Section #link("../Utilities/Mathematical_Infrastructure.html#sec:bit-ops")[B.2.7], returns the 3D Morton code for the given integer values.
][
  我们为 $x$ 、 $y$ 和 $z$ 维度的每一个使用 10 位，总共 30 位用于莫顿码。这种粒度允许值适合于一个 32 位的变量。边界框内的浮点中心点偏移在 $[0, 1]$ 范围内，因此我们通过 $2^{10}$ 来缩放它们，以获得适合于 10 位的整数坐标。EncodeMorton3() 函数，这个函数和其他位运算工具函数一起定义在章节 B.2.7，返回给定整数值的 3D 莫顿码。
]


```cpp
constexpr int mortonBits = 10;
constexpr int mortonScale = 1 << mortonBits;
mortonPrims[i].primitiveIndex = bvhPrimitives[i].primitiveIndex;
Vector3f centroidOffset = bounds.Offset(bvhPrimitives[i].Centroid());
Vector3f offset = centroidOffset * mortonScale;
mortonPrims[i].mortonCode = EncodeMorton3(offset.x, offset.y, offset.z);
```

#parec[
  Once the Morton indices have been computed, we will sort the `mortonPrims` by Morton index value using a radix sort. We have found that for BVH construction, our radix sort implementation is noticeably faster than using `std::sort()` from our system's standard library (which is a mixture of a quicksort and an insertion sort).
][
  一旦计算出莫顿索引，我们将使用基数排序对 mortonPrims 按莫顿索引值进行排序。我们发现，在构建 BVH 时，我们的基数排序实现明显快于使用系统标准库中的 `std::sort()`（这是快速排序和插入排序的混合体）。
]

```cpp
<<Radix sort primitive Morton indices>>=
RadixSort(&mortonPrims);
```


#parec[
  Recall that a radix sort differs from most sorting algorithms in that it is not based on comparing pairs of values but rather is based on bucketing items based on some key. Radix sort can be used to sort integer values by sorting them one digit at a time, going from the rightmost digit to the leftmost. Especially with binary values, it is worth sorting multiple digits at a time; doing so reduces the total number of passes taken over the data. In the implementation here, bitsPerPass sets the number of bits processed per pass; with the value 6, we have 5 passes to sort the 30 bits.
][
  回想一下，基数排序与大多数排序算法不同，它不是基于比较值对，而是基于根据某个关键字将项目进行分桶。基数排序可以通过一次对一个数字进行排序，从最右边的数字到最左边的数字，来对整数值进行排序。尤其是对于二进制值，同时对多个位进行排序是有价值的；这样可以减少对数据的总遍历次数。在这里的实现中，bitsPerPass 设置每次处理的位数；当其值为6时，我们需要5次遍历来排序这30位。
]

```cpp
<<BVHAggregate Utility Functions>>=
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

#parec[
  Each pass sorts `bitsPerPass` bits, starting at lowBit.
][
  每次遍历都会从 `lowBit` 开始排序 `bitsPerPass` 位。
]

```cpp
<<Perform one pass of radix sort, sorting bitsPerPass bits>>=
int lowBit = pass * bitsPerPass;
<<Set in and out vector references for radix sort pass>>
<<Count number of zero bits in array for current radix sort bit>>
<<Compute starting index in output array for each bucket>>
<<Store sorted values in output array>>
```

#parec[
  The `in` and `out` references correspond to the vector to be sorted and the vector to store the sorted values in, respectively. Each pass through the loop alternates between the input vector `*v` and the temporary vector for each of them.
][
  `in` 和 `out` 引用分别对应要排序的向量和用于存储排序值的向量。每次通过循环时，都会在输入向量 `*v` 和它们各自的临时向量之间交替。
]


```cpp
std::vector<MortonPrimitive> &in = (pass & 1) ? tempVector : *v;
std::vector<MortonPrimitive> &out = (pass & 1) ? *v : tempVector;
```


#parec[
  If we are sorting `n` bits per pass, then there are `2^n` buckets that each value may land in. We first count how many values will land in each bucket; this will let us determine where to store sorted values in the output array. To compute the bucket index for the current value, the implementation shifts the index so that the bit at index `lowBit` is at bit 0 and then masks off the low `bitsPerPass` bits.
][
  如果我们每次传递排序 `n` 位，那么每个值可能落在 `2^n` 个桶中。我们首先计算每个桶中将有多少值；这将让我们确定在输出数组中存储排序值的位置。为了计算当前值的桶索引，实现在索引 `lowBit` 处的位被移到第 0 位，然后屏蔽掉低 `bitsPerPass` 位。
]

```cpp
constexpr int nBuckets = 1 << bitsPerPass;
int bucketCount[nBuckets] = { 0 };
constexpr int bitMask = (1 << bitsPerPass) - 1;
for (const MortonPrimitive &mp : in) {
    int bucket = (mp.mortonCode >> lowBit) & bitMask;
    ++bucketCount[bucket];
}
```

#parec[
  Given the count of how many values land in each bucket, we can compute the offset in the output array where each bucket's values start; this is just the sum of how many values land in the preceding buckets.
][
  根据每个桶中有多少值，我们可以计算输出数组中每个桶的值开始的位置偏移量；这只是前面各桶中值的总和。
]

```cpp
int outIndex[nBuckets];
outIndex[0] = 0;
for (int i = 1; i < nBuckets; ++i)
    outIndex[i] = outIndex[i - 1] + bucketCount[i - 1];
```


#parec[
  Now that we know where to start storing values for each bucket, we can take another pass over the primitives to recompute the bucket that each one lands in and to store their `MortonPrimitive`s in the output array. This completes the sorting pass for the current group of bits.
][
  现在我们知道了每个桶存储值的起始位置，可以再次遍历基本元素，重新计算每个元素所在的桶，并将它们的 `MortonPrimitive` 存储在输出数组中。这完成了当前位组的排序传递。
]


```cpp
for (const MortonPrimitive &mp : in) {
    int bucket = (mp.mortonCode >> lowBit) & bitMask;
    out[outIndex[bucket]++] = mp;
}
```


#parec[
  When sorting is done, if an odd number of radix sort passes were performed, then the final sorted values need to be copied from the temporary vector to the output vector that was originally passed to `RadixSort()`.
][
  排序完成后，如果执行了奇数次基数排序传递，则需要将最终排序的值从临时向量复制到最初传递给 `RadixSort()` 的输出向量中。
]

```cpp
if (nPasses & 1)
    std::swap(*v, tempVector);
```


#parec[
  Given the sorted array of primitives, we can now find clusters of primitives with nearby centroids and then create an LBVH over the primitives in each cluster. This step is a good one to parallelize as there are generally many clusters and each cluster can be processed independently.
][
  根据排序后的基本元素数组，我们现在可以找到具有相近质心的基本元素簇，然后在每个簇中的基本元素上创建 LBVH。由于通常有许多簇，并且每个簇可以独立处理，因此这一步非常适合并行化。
]

```cpp
<<Create LBVH treelets at bottom of BVH>>=
<<Find intervals of primitives for each treelet>>
<<Create LBVHs for treelets in parallel>>
```

#parec[
  Each primitive cluster is represented by an `LBVHTreelet`. It encodes the index in the `mortonPrims` array of the first primitive in the cluster as well as the number of following primitives. (See Figure 7.10.)
][
  每个基本元素簇由一个 `LBVHTreelet` 表示。它编码了簇中第一个基本元素在 `mortonPrims` 数组中的索引以及后续基本元素的数量。（见图 7.10。）
]

```cpp
struct LBVHTreelet {
   size_t startIndex, nPrimitives;
   BVHBuildNode *buildNodes;
};
```

#parec[
  ![Figure 7.10: Primitive Clusters for LBVH Treelets. Primitive centroids are clustered in a uniform grid over their bounds. An LBVH is created for each cluster of primitives within a cell that are in contiguous sections of the sorted Morton index values.](pha07f10.svg)
][
  ![图 7.10：LBVH Treelets 的基本元素簇。基本元素的质心在其边界上聚类在一个均匀网格中。对于每个在排序后的 Morton 索引值的连续部分内的单元格中的基本元素簇，都会创建一个 LBVH。](pha07f10.svg)
]

#parec[
  Recall from Figure 7.9 that a set of points with Morton codes that match in their high bit values lie in a power-of-two aligned and sized subset of the original volume. Because we have already sorted the `mortonPrims` array by Morton-coded value, primitives with matching high bit values are already together in contiguous sections of the array.
][
  回想图 7.9，具有高位值匹配的 Morton 码的一组点位于原始体积的一个二次方对齐和大小的子集中。因为我们已经按 Morton 编码值对 `mortonPrims` 数组进行了排序，所以具有匹配高位值的基本元素已经在数组的连续部分中聚集在一起。
]

#parec[
  Here we will find sets of primitives that have the same values for the high 12 bits of their 30-bit Morton codes. Clusters are found by taking a linear pass through the `mortonPrims` array and finding the offsets where any of the high 12 bits changes. This corresponds to clustering primitives in a regular grid of \(2^{12} = 4096\) total grid cells with \(2^4 = 16\) cells in each dimension. In practice, many of the grid cells will be empty, though we will still expect to find many independent clusters here.
][
  在这里，我们将找到具有相同30位 Morton 码高12位值的基本元素集合。通过线性遍历 `mortonPrims` 数组并找到任何高12位变化的偏移量来发现簇。这对应于在一个具有 \(2^{12} = 4096\) 个总网格单元且每个维度有 \(2^4 = 16\) 个单元的规则网格中对基本元素进行聚类。在实践中，许多网格单元将是空的，尽管我们仍然预计在这里会发现许多独立的簇。
]

```cpp
std::vector<LBVHTreelet> treeletsToBuild;
for (size_t start = 0, end = 1; end <= mortonPrims.size(); ++end) {
    uint32_t mask = 0b00111111111111000000000000000000;
    if (end == (int)mortonPrims.size() ||
        ((mortonPrims[start].mortonCode & mask) !=
         (mortonPrims[end].mortonCode & mask))) {
        <<Add entry to treeletsToBuild for this treelet>>
        size_t nPrimitives = end - start;
        int maxBVHNodes = 2 * nPrimitives - 1;
        BVHBuildNode *nodes = alloc.allocate_object<BVHBuildNode>(maxBVHNodes);
        treeletsToBuild.push_back({start, nPrimitives, nodes});
        start = end;
    }
}
```


#parec[
  When a cluster of primitives has been found for a treelet, `BVHBuildNode`s are immediately allocated for it. (Recall that the number of nodes in a BVH is bounded by twice the number of leaf nodes, which in turn is bounded by the number of primitives.) It is simpler to preallocate this memory now in a serial phase of execution than during parallel construction of LBVHs.
][
  当为一个 treelet 找到一个基本元素簇时，会立即为其分配 `BVHBuildNode`。 （回想一下，BVH 中节点的数量由叶节点数量的两倍限制，而叶节点数量又由基本元素数量限制。）现在在串行执行阶段预分配这部分内存比在并行构建 LBVH 时更简单。
]

```cpp
<<Add entry to `treeletsToBuild` for this treelet>>
size_t nPrimitives = end - start;
int maxBVHNodes = 2 * nPrimitives - 1;
BVHBuildNode *nodes = alloc.allocate_object<BVHBuildNode>(maxBVHNodes);
treeletsToBuild.push_back({start, nPrimitives, nodes});
```

#parec[
  Once the primitives for each treelet have been identified, we can create LBVHs for them in parallel. When construction is finished, the `buildNodes` pointer for each `LBVHTreelet` will point to the root of the corresponding LBVH.
][
  一旦为每个 treelet 确定了基本元素，我们就可以并行地为它们创建 LBVH。构建完成后，每个 `LBVHTreelet` 的 `buildNodes` 指针将指向相应 LBVH 的根节点。
]

#parec[
  There are two places where the worker threads building LBVHs must coordinate with each other. First, the total number of nodes in all the LBVHs needs to be computed and returned via the `totalNodes` pointer passed to `buildHLBVH()`. Second, when leaf nodes are created for the LBVHs, a contiguous segment of the `orderedPrims` array is needed to record the indices of the primitives in the leaf node. Our implementation uses atomic variables for both.
][
  构建 LBVH 的工作线程必须在两个地方相互协调。首先，所有 LBVH 中节点的总数需要计算并通过传递给 `buildHLBVH()` 的 `totalNodes` 指针返回。其次，当为 LBVH 创建叶节点时，需要 `orderedPrims` 数组的一个连续段来记录叶节点中基本元素的索引。我们的实现对这两者都使用原子变量。
]


```cpp
<<Create LBVHs for treelets in parallel>>=
std::atomic<int> orderedPrimsOffset(0);
ParallelFor(0, treeletsToBuild.size(), [&](int i) {
    <<Generate ith LBVH treelet>>
});
```

#parec[
  The work of building the treelet is performed by `emitLBVH()`, which takes primitives with centroids in some region of space and successively partitions them with splitting planes that divide the current region of space into two halves along the center of the region along one of the three axes.
][
  构建 treelet 的工作由 `emitLBVH()` 执行，该函数接受位于空间某一区域内质心的基本元素，并通过分割平面将当前空间区域沿三个轴之一的中心依次分割为两半，从而对它们进行分区。
]

#parec[
  Note that instead of taking a pointer to the atomic variable `totalNodes` to count the number of nodes created, `emitLBVH()` updates a non-atomic local variable. The fragment here then only updates `totalNodes` once per treelet when each treelet is done. This approach gives measurably better performance than the alternative—having the worker threads frequently modify `totalNodes` over the course of their execution. (To understand why this is so, see the discussion of the overhead of multi-core memory coherence models in Appendix B.6.3.)
][
  请注意，`emitLBVH()` 不是通过指针引用原子变量 `totalNodes` 来计数创建的节点数量，而是更新一个非原子的本地变量。然后，这里的片段仅在每个 treelet 完成时更新一次 `totalNodes`。这种方法在性能上明显优于另一种选择——让工作线程在执行过程中频繁修改 `totalNodes`。（要了解原因，请参阅附录 B.6.3 中关于多核内存一致性模型开销的讨论。）
]

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

---

#parec[
  Thanks to the Morton encoding, the current region of space does not need to be explicitly represented in `emitLBVH()`: the sorted `MortonPrim`s passed in have some number of matching high bits, which in turn corresponds to a spatial bound. For each of the remaining bits in the Morton codes, this function tries to split the primitives along the plane corresponding to the `bitIndex` bit (recall Figure 7.9(d)) and then calls itself recursively. The index of the next bit to try splitting with is passed as the last argument to the function: initially it is \(29 - 12\), since 29 is the index of the 30th bit with zero-based indexing, and we previously used the high 12 bits of the Morton-coded value to cluster the primitives; thus, we know that those bits must all match for the cluster.
][
  多亏了 Morton 编码，`emitLBVH()` 中不需要显式表示当前的空间区域：传入的已排序 `MortonPrim` 具有若干匹配的高位，这反过来对应于一个空间边界。对于 Morton 码中的每一个剩余位，该函数尝试沿着与 `bitIndex` 位对应的平面分割基本元素（回想图 7.9(d)），然后递归调用自身。下一个要尝试分割的位索引作为函数的最后一个参数传递：最初是 \(29 - 12\)，因为 29 是第 30 位的索引（从零开始），我们之前使用 Morton 编码值的高 12 位来聚类基本元素；因此，我们知道这些位在簇中必须全部匹配。
]

```cpp
BVHBuildNode *BVHAggregate::emitLBVH(BVHBuildNode *&buildNodes,
        const std::vector<BVHPrimitive> &bvhPrimitives,
        MortonPrimitive *mortonPrims, int nPrimitives, int *totalNodes,
        std::vector<Primitive> &orderedPrims,
        std::atomic<int> *orderedPrimsOffset, int bitIndex) {
    if (bitIndex == -1 || nPrimitives < maxPrimsInNode) {
        <<Create and return leaf node of LBVH treelet>>
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
    } else {
        int mask = 1 << bitIndex;
        <<Advance to next subtree level if there is no LBVH split for this bit>>
        if ((mortonPrims[0].mortonCode & mask) ==
            (mortonPrims[nPrimitives - 1].mortonCode & mask))
            return emitLBVH(buildNodes, bvhPrimitives, mortonPrims, nPrimitives,
                            totalNodes, orderedPrims, orderedPrimsOffset,
                            bitIndex - 1);
        <<Find LBVH split point for this dimension>>
        int splitOffset = FindInterval(nPrimitives, [&](int index) {
            return ((mortonPrims[0].mortonCode & mask) ==
                    (mortonPrims[index].mortonCode & mask));
        });
        ++splitOffset;

        <<Create and return interior LBVH node>>
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
    }
}
```

---

#parec[
  After `emitLBVH()` has partitioned the primitives with the final low bit, no more splitting is possible and a leaf node is created. Alternatively, it also stops and makes a leaf node if it is down to a small number of primitives.
][
  `emitLBVH()` 使用最终的低位对基本元素进行分区后，就无法再进行分割，并创建一个叶节点。或者，如果剩下的基本元素数量较少，它也会停止并创建一个叶节点。
]

#parec[
  Recall that `orderedPrimsOffset` is the offset to the next available element in the `orderedPrims` array. Here, the call to `fetch_add()` atomically adds the value of `nPrimitives` to `orderedPrimsOffset` and returns its old value before the addition. Given space in the array, leaf construction is similar to the approach implemented earlier in `<<Create leaf `BVHBuildNode`>>`.
][
  回想一下，`orderedPrimsOffset` 是 `orderedPrims` 数组中下一个可用元素的偏移量。在这里，调用 `fetch_add()` 原子地将 `nPrimitives` 的值添加到 `orderedPrimsOffset` 并返回添加前的旧值。考虑到数组中有空间，叶节点的构建类似于之前在 `<<创建叶节点 `BVHBuildNode`>>` 中实现的方法。
]


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


#parec[
  It may be the case that all the primitives lie on the same side of the splitting plane; since the primitives are sorted by their Morton index, this case can be efficiently checked by seeing if the first and last primitive in the range both have the same bit value for this plane. In this case, `emitLBVH()` proceeds to the next bit without unnecessarily creating a node.
][
  所有基本元素可能都位于分割平面的一侧；由于基本元素已按 Morton 索引排序，可以通过检查范围内的第一个和最后一个基本元素在该平面的位值是否相同来有效地验证这种情况。在这种情况下，`emitLBVH()` 会继续处理下一个位，而不会不必要地创建节点。
]

```cpp
if ((mortonPrims[0].mortonCode & mask) ==
    (mortonPrims[nPrimitives - 1].mortonCode & mask))
    return emitLBVH(buildNodes, bvhPrimitives, mortonPrims, nPrimitives,
                    totalNodes, orderedPrims, orderedPrimsOffset,
                    bitIndex - 1);
```


#parec[
  If there are primitives on both sides of the splitting plane, then a binary search efficiently finds the dividing point where the `bitIndex`th bit goes from 0 to 1 in the current set of primitives.
][
  如果分割平面两侧都有基本元素，则二分搜索可以有效地找到当前基本元素集中第 `bitIndex` 位从 0 变为 1 的分割点。
]

```cpp
int splitOffset = FindInterval(nPrimitives, [&](int index) {
    return ((mortonPrims[0].mortonCode & mask) ==
            (mortonPrims[index].mortonCode & mask));
});
++splitOffset;
```


#parec[
  Given the split offset, the method can now claim a node to use as an interior node and recursively build LBVHs for both partitioned sets of primitives. Note a further efficiency benefit from Morton encoding: entries in the `mortonPrims` array do not need to be copied or reordered for the partition: because they are all sorted by their Morton code value and because it is processing bits from high to low, the two spans of primitives are already on the correct sides of the partition plane.
][
  有了分割偏移量，该方法现在可以申请一个节点作为内部节点，并递归地为两个分割后的基本元素集构建 LBVH。请注意，Morton 编码带来了进一步的效率优势：`mortonPrims` 数组中的条目无需为分区进行复制或重新排序；因为它们都按 Morton 码值排序，并且处理的是从高位到低位的位，所以两个基本元素的范围已经位于分割平面的正确两侧。
]

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

#parec[
  Once all the LBVH treelets have been created, `buildUpperSAH()` creates a BVH of all the treelets. Since there are generally tens or hundreds of them (and in any case, no more than 4096), this step takes very little time.
][
  一旦所有 LBVH treelet 都被创建，`buildUpperSAH()` 就会为所有 treelet 创建一个 BVH。由于通常有数十个或数百个（无论如何，不超过 4096 个），此步骤所需时间非常少。
]

```cpp
std::vector<BVHBuildNode *> finishedTreelets;
for (LBVHTreelet &treelet : treeletsToBuild)
    finishedTreelets.push_back(treelet.buildNodes);
return buildUpperSAH(alloc, finishedTreelets, 0,
                     finishedTreelets.size(), totalNodes);
```

#parec[
  The implementation of `buildUpperSAH()` is not included here, as it follows the same approach as fully SAH-based BVH construction, just over treelet root nodes rather than scene primitives.
][
  `buildUpperSAH()` 的实现未在此包含，因为它采用与完全基于 SAH 的 BVH 构建相同的方法，只不过是针对 treelet 根节点而不是场景基本元素。
]


=== Compact BVH for Traversal
<compact-bvh-for-traversal>


#parec[
  Once the BVH is built, the last step is to convert it into a compact representation—doing so improves cache, memory, and thus overall system performance. The final BVH is stored in a linear array in memory. The nodes of the original tree are laid out in depth-first order, which means that the first child of each interior node is immediately after the node in memory. In this case, only the offset to the second child of each interior node must be stored explicitly. See Figure 7.11 for an illustration of the relationship between tree topology and node order in memory.
][
  一旦建立了 BVH，最后一步是将其转换为紧凑的表示形式——这样做可以改善缓存、内存，从而整体系统性能。最终的 BVH 被存储在内存中的线性数组中。原始树的节点按照深度优先遍历顺序排列，这意味着每个内部节点的第一个子节点紧跟在内存中的该节点之后。在这种情况下，只需要显式存储每个内部节点的第二个子节点的偏移量。请参见@fig:bvh-linear-layout 以了解树拓扑与内存中节点顺序之间的关系。
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
  `LinearBVHNode` 结构存储了遍历 BVH 所需的信息。除了每个节点的包围盒外，对于叶子节点，它存储节点中原始体的偏移量和原始体数量。对于内部节点，它存储第二个子节点的偏移量以及在构建层次结构时原始体被分割的坐标轴；此信息在下面的遍历例程中用于尝试沿射线以从前到后的顺序访问节点。
]

#parec[
  The structure is declared to require 32-byte alignment in memory. It could otherwise be allocated at an alignment that was sufficient to satisfy the first member variable, which would be 4 bytes for the `Float`-valued `Bounds3f::pMin::x` member variable. Because modern processor caches are organized into cache lines of a size that is a multiple of 32, a more stringent alignment constraint ensures that no `LinearBVHNode` straddles two cache lines. In turn, no more than a single cache miss will be incurred when one is accessed, which improves performance.
][
  该结构被声明为在内存中需要 32 字节对齐。否则，它可以在足以满足第一个成员变量的对齐处分配，该变量对于 `Float` 值的 `Bounds3f::pMin::x` 成员变量将是 4 字节。由于现代处理器缓存被组织成大小为 32 的倍数的缓存行，更严格的内存对齐约束确保没有 `LinearBVHNode` 跨越两个缓存行。反过来，当访问一个节点时，不会产生超过一次缓存未命中（cache miss），从而提高性能。
]

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

#parec[
  The built tree is transformed to the `LinearBVHNode` representation by the `flattenBVH()` method, which performs a depth-first traversal and stores the nodes in memory in linear order. It is helpful to release the memory in the `bvhPrimitives` array before doing so, since that may be a significant amount of storage for complex scenes and is no longer needed at this point. This is handled by the `resize(0)` and `shrink_to_fit()` calls.
][
  通过 `flattenBVH()` 方法将构建的树转换为 `LinearBVHNode` 表示，该方法执行深度优先遍历并以线性顺序将节点存储在内存中。最好在此之前释放 `bvhPrimitives` 数组中的内存，因为对于复杂场景，这可能是大量存储，并且此时不再需要。这由 `resize(0)` 和 `shrink_to_fit()` 调用处理。
]

```cpp
bvhPrimitives.resize(0);
bvhPrimitives.shrink_to_fit();
nodes = new LinearBVHNode[totalNodes];
int offset = 0;
flattenBVH(root, &offset);
```


#parec[
  The pointer to the array of `LinearBVHNode`s is stored as a `BVHAggregate` member variable.
][
  指向 `LinearBVHNode` 数组的指针被存储为 `BVHAggregate` 成员变量。
]

```cpp
LinearBVHNode *nodes = nullptr;
```


#parec[
  Flattening the tree to the linear representation is straightforward; the `*offset` parameter tracks the current offset into the `BVHAggregate::nodes` array. Note that the current node is added to the array before any recursive calls to process its children.
][
  将树压平为线性表示是直接的；`*offset` 参数跟踪当前在 `BVHAggregate::nodes` 数组中的偏移量。请注意，在任何递归调用处理其子节点之前，当前节点已添加到数组中。
]

```cpp
int BVHAggregate::flattenBVH(BVHBuildNode *node, int *offset) {
    LinearBVHNode *linearNode = &nodes[*offset];
    linearNode->bounds = node->bounds;
    int nodeOffset = (*offset)++;
    if (node->nPrimitives > 0) {
        linearNode->primitivesOffset = node->firstPrimOffset;
        linearNode->nPrimitives = node->nPrimitives;
    } else {
        // Create interior flattened BVH node
        linearNode->axis = node->splitAxis;
        linearNode->nPrimitives = 0;
        flattenBVH(node->children[0], offset);
        linearNode->secondChildOffset = flattenBVH(node->children[1], offset);
    }
    return nodeOffset;
}
```


#parec[
  At interior nodes, recursive calls are made to flatten the two subtrees. The first one ends up immediately after the current node in the array, as desired, and the offset of the second one, returned by its recursive `flattenBVH()` call, is stored in this node's `secondChildOffset` member.
][
  在内部节点处，递归调用用于将两个子树线性化。第一个子树最终紧跟在数组中的当前节点之后，并且其递归 `flattenBVH()` 调用返回的第二个子树的偏移量存储在该节点的 `secondChildOffset` 成员变量中。
]

```cpp
linearNode->axis = node->splitAxis;
linearNode->nPrimitives = 0;
flattenBVH(node->children[0], offset);
linearNode->secondChildOffset = flattenBVH(node->children[1], offset);
```


=== Bounding and Intersection Tests
<bounding-and-intersection-tests>
#parec[
  Given a built BVH, the implementation of the `Bounds()` method is easy: by definition, the root node's bounds are the bounds of all the primitives in the tree, so those can be returned directly.
][
  给定一个已构建的 BVH，实现 `Bounds()` 方法很简单：根据定义，根节点的边界是树中所有图元的边界，因此可以直接返回这些边界。
]

```cpp
Bounds3f BVHAggregate::Bounds() const {
    return nodes[0].bounds;
}
```


#parec[
  The BVH traversal code is quite simple—there are no recursive function calls and a small amount of data to maintain about the current state of the traversal. The `Intersect()` method starts by precomputing a few values related to the ray that will be used repeatedly.
][
  BVH 遍历代码相当简单——没有递归函数调用，并且只需维护少量关于当前遍历状态的数据。`Intersect()` 方法首先预计算一些与光线相关的值，这些值将被重复使用。
]

```cpp
<<BVHAggregate Method Definitions>>+=
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



#parec[
  Each time the following `while` loop starts an iteration, `currentNodeIndex` holds the offset into the `nodes` array of the node to be visited. It starts with a value of 0, representing the root of the tree. The nodes that still need to be visited are stored in the `nodesToVisit[]` array, which acts as a stack; `toVisitOffset` holds the offset to the next free element in the stack. With the following traversal algorithm, the number of nodes in the stack is never more than the maximum tree depth. A statically allocated stack of 64 entries is sufficient in practice.
][
  每次以下 `while` 循环开始迭代时，`currentNodeIndex` 持有要访问的节点在 `nodes` 数组中的偏移量。它以 0 开始，表示树的根节点。仍需访问的节点存储在 `nodesToVisit[]` 数组中，该数组充当栈；`toVisitOffset` 持有栈中下一个空闲元素的偏移量。通过以下遍历算法，栈中的节点数从未超过最大树深度。在实践中，静态分配的 64 个条目栈已足够。
]

```cpp
int toVisitOffset = 0, currentNodeIndex = 0;
int nodesToVisit[64];
while (true) {
    const LinearBVHNode *node = &nodes[currentNodeIndex];
 <<Check ray against BVH node>>
}
```

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
      (b) 在每个像素处对相机射线执行的射线-三角形相交测试数量。几何最复杂的树木和海滩上详尽的地面覆盖需要进行最多的相交测试。
      (场景图片由沃尔特迪士尼动画工作室提供。)
    ]
  ],
)<moana-bvh-number-of-nodes-visited>

#parec[
  At each node, the first step is to check if the ray intersects the node's bounding box (or starts inside of it). The node is visited if so, with its primitives tested for intersection if it is a leaf node or its children are visited if it is an interior node. If no intersection is found, then the offset of the next node to be visited is retrieved from `nodesToVisit[]` (or traversal is complete if the stack is empty). See @fig:bvh-number-of-nodes-visited and @fig:moana-bvh-number-of-nodes-visited for visualizations of how many nodes are visited and how many intersection tests are performed at each pixel for two complex scenes.
][
  在每个节点，第一步是检查光线是否与节点的边界框相交（或从内部开始）。如果是，则访问节点。若是叶节点，则测试其图元的相交；若是内部节点，则访问其子节点。如果未找到相交，则从 `nodesToVisit[]` 中检索下一个要访问的节点的偏移量（如果栈为空则遍历完成）。参见@fig:bvh-number-of-nodes-visited 和 @fig:moana-bvh-number-of-nodes-visited，了解在两个复杂场景中每个像素访问的节点数量和执行的相交测试数量的可视化。
]

```cpp
if (node->bounds.IntersectP(ray.o, ray.d, tMax, invDir, dirIsNeg)) {
    if (node->nPrimitives > 0) {
        // Intersect ray with primitives in leaf BVH node
        for (int i = 0; i < node->nPrimitives; ++i) {
            // Check for intersection with primitive in BVH node
            pstd::optional<ShapeIntersection> primSi =
                primitives[node->primitivesOffset + i].Intersect(ray, tMax);
            if (primSi) {
                si = primSi;
                tMax = si->tHit;
            }
        }
        if (toVisitOffset == 0) break;
        currentNodeIndex = nodesToVisit[--toVisitOffset];
    } else {
        // Put far BVH node on nodesToVisit stack, advance to near node
        if (dirIsNeg[node->axis]) {
            nodesToVisit[toVisitOffset++] = currentNodeIndex + 1;
            currentNodeIndex = node->secondChildOffset;
        } else {
            nodesToVisit[toVisitOffset++] = node->secondChildOffset;
            currentNodeIndex = currentNodeIndex + 1;
        }
    }
} else {
    if (toVisitOffset == 0) break;
    currentNodeIndex = nodesToVisit[--toVisitOffset];
}
```



#parec[
  If the current node is a leaf, then the ray must be tested for intersection with the primitives inside it. The next node to visit is then found from the `nodesToVisit` stack; even if an intersection is found in the current node, the remaining nodes must be visited in case one of them yields a closer intersection.
][
  如果当前节点是叶节点，则必须测试光线与其中的图元的相交。然后从 `nodesToVisit` 栈中找到下一个要访问的节点；即使在当前节点中找到相交，仍需访问剩余节点，以防其中一个节点提供更近的相交。
]

```cpp
for (int i = 0; i < node->nPrimitives; ++i) {
    // Check for intersection with primitive in BVH node
    pstd::optional<ShapeIntersection> primSi =
        primitives[node->primitivesOffset + i].Intersect(ray, tMax);
    if (primSi) {
        si = primSi;
        tMax = si->tHit;
    }
}
if (toVisitOffset == 0) break;
currentNodeIndex = nodesToVisit[--toVisitOffset];
```


#parec[
  If an intersection is found, the `tMax` value can be updated to the intersection's parametric distance along the ray; this makes it possible to efficiently discard any remaining nodes that are farther away than the intersection.
][
  如果找到相交，可以将 `tMax` 值更新为相交在光线上的参数距离；这使得可以有效地丢弃任何比相交更远的剩余节点。
]

#parec[
  For an interior node that the ray hits, it is necessary to visit both of its children. As described above, it is desirable to visit the first child that the ray passes through before visiting the second one in case the ray intersects a primitive in the first one. If so, the ray's `tMax` value can be updated, thus reducing the ray's extent and thus the number of node bounding boxes it intersects.
][
  对于光线击中的内部节点，有必要访问其两个子节点。如上所述，最好先访问光线通过的第一个子节点，然后再访问第二个子节点，以防光线在第一个子节点中与图元相交。如果是这样，可以更新光线的 `tMax` 值，从而减少光线的范围以及它与之相交的节点边界框的数量。
]

#parec[
  An efficient way to perform a front-to-back traversal without incurring the expense of intersecting the ray with both child nodes and comparing the distances is to use the sign of the ray's direction vector for the coordinate axis along which primitives were partitioned for the current node: if the sign is negative, we should visit the second child before the first child, since the primitives that went into the second child's subtree were on the upper side of the partition point. (And conversely for a positive-signed direction.) Doing this is straightforward: the offset for the node to be visited first is copied to `currentNodeIndex`, and the offset for the other node is added to the `nodesToVisit` stack. (Recall that the first child is immediately after the current node due to the depth-first layout of nodes in memory.)
][
  一种有效的方式来执行前向遍历，而不需要承担与两个子节点相交光线并比较距离的开销，是使用光线方向向量在当前节点的坐标轴上的符号：如果符号为负，则应在访问第一个子节点之前访问第二个子节点，因为进入第二个子节点子树的图元位于分割点的上侧。（对于正符号方向则相反。）这样做很简单：要访问的第一个节点的偏移量被复制到 `currentNodeIndex`，另一个节点的偏移量被添加到 `nodesToVisit` 栈中。（回想一下，由于内存中节点的深度优先布局，第一个子节点紧跟在当前节点之后。）
]

```cpp
if (dirIsNeg[node->axis]) {
   nodesToVisit[toVisitOffset++] = currentNodeIndex + 1;
   currentNodeIndex = node->secondChildOffset;
} else {
   nodesToVisit[toVisitOffset++] = node->secondChildOffset;
   currentNodeIndex = currentNodeIndex + 1;
}
```



#parec[
  The `BVHAggregate::IntersectP()` method is essentially the same as the regular intersection method, with the two differences that `Primitive`'s `IntersectP()` methods are called rather than `Intersect()`, and traversal stops immediately when any intersection is found. It is thus not included here.
][
  `BVHAggregate::IntersectP()` 方法本质上与常规相交方法相同，唯一区别是调用 `Primitive` 的 `IntersectP()` 方法而不是 `Intersect()`，并且一旦找到任何相交就立即停止遍历。因此这里不包括它。
]