#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#fragbit-985")[`fragbit-985`]]
#block(breakable: false)[
```cpp
BVHAggregate(std::vector<Primitive> p, int maxPrimsInNode = 1,
         SplitMethod splitMethod = SplitMethod::SAH);

static BVHAggregate *Create(std::vector<Primitive> prims,
                        const ParameterDictionary &parameters);

Bounds3f Bounds() const;
pstd::optional<ShapeIntersection> Intersect(const Ray &ray, Float tMax) const;
bool IntersectP(const Ray &ray, Float tMax) const;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#fragbit-986")[`fragbit-986`]]
#block(breakable: false)[
```cpp
BVHBuildNode *buildRecursive(ThreadLocal<Allocator> &threadAllocators,
                             pstd::span<BVHPrimitive> bvhPrimitives,
                             std::atomic<int> *totalNodes,
                             std::atomic<int> *orderedPrimsOffset,
                             std::vector<Primitive> &orderedPrims);
BVHBuildNode *buildHLBVH(Allocator alloc,
                         const std::vector<BVHPrimitive> &primitiveInfo,
                         std::atomic<int> *totalNodes,
                         std::vector<Primitive> &orderedPrims);
BVHBuildNode *emitLBVH(BVHBuildNode *&buildNodes,
                       const std::vector<BVHPrimitive> &primitiveInfo,
                       MortonPrimitive *mortonPrims, int nPrimitives, int *totalNodes,
                       std::vector<Primitive> &orderedPrims,
                       std::atomic<int> *orderedPrimsOffset, int bitIndex);
BVHBuildNode *buildUpperSAH(Allocator alloc,
                            std::vector<BVHBuildNode *> &treeletRoots, int start,
                            int end, std::atomic<int> *totalNodes) const;
int flattenBVH(BVHBuildNode *node, int *offset);
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#fragbit-1009")[`fragbit-1009`]]
#block(breakable: false)[
```cpp
switch (splitMethod) {
case SplitMethod::Middle: {
    <<Partition primitives through node’s midpoint>>
}
case SplitMethod::EqualCounts: {
    <<Partition primitives into equally sized subsets>>
    break;
}
case SplitMethod::SAH:
default: {
    <<Partition primitives using approximate SAH>>
    break;
}
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#fragbit-1026")[`fragbit-1026`]]
#block(breakable: false)[
```cpp
children[0] =
    buildRecursive(threadAllocators, bvhPrimitives.subspan(0, mid),
                   totalNodes, orderedPrimsOffset, orderedPrims);
children[1] =
    buildRecursive(threadAllocators, bvhPrimitives.subspan(mid),
                   totalNodes, orderedPrimsOffset, orderedPrims);
```
]
