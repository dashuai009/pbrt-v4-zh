#import "../template.typ": parec


== Aggregates
<aggregates>

#parec[
  Ray intersection acceleration structures are one of the components at the heart of any ray tracer. Without algorithms to reduce the number of unnecessary ray intersection tests, tracing a single ray through a scene would take time linear in the number of primitives in the scene, since the ray would need to be tested against each primitive to find the closest intersection.
][
  光线交叉加速结构是任何光线追踪器核心的组成部分之一。如果没有算法来减少不必要的光线相交测试，在场景中追踪一条光线所需的时间将与场景中图元数量成正比，因为光线需要与每个图元进行测试以找到最近的相交。
]

#parec[
  However, doing so is extremely wasteful in most scenes, since the ray passes nowhere near the vast majority of primitives. The goals of acceleration structures are to allow the quick, simultaneous rejection of groups of primitives and to order the search process so that nearby intersections are likely to be found first and farther away ones can potentially be ignored.
][
  然而，在大多数场景中这样做是极其浪费的，因为光线经过的地方远离绝大多数图元。加速结构的目标是能够快速同时排除一组图元，并对搜索过程进行排序，以便首先找到附近的相交点，而可以忽略更远的相交点。
]

#parec[
  Because ray–object intersections can account for the bulk of execution time in ray tracers, there has been a substantial amount of research into algorithms for ray intersection acceleration. We will not try to explore all of this work here but refer the interested reader to references in the "Further Reading" section at the end of this chapter.
][
  由于光线与物体的相交可能占据光线追踪器执行时间的大部分，因此对光线相交加速算法进行了大量研究。我们不会在这里尝试探讨所有这些工作，但会在本章末尾的“进一步阅读”部分中为感兴趣的读者提供参考。
]

#parec[
  Broadly speaking, there are two main approaches to this problem: spatial subdivision and object subdivision. Spatial subdivision algorithms decompose 3D space into regions (e.g., by superimposing a grid of axis-aligned boxes on the scene) and record which primitives overlap which regions.
][
  广义上讲，这个问题有两种主要的方法：空间细分和物体细分。空间细分算法将三维空间划分为多个区域（例如，通过在场景上叠加一个轴对齐的网格盒）并记录哪些图元与哪些区域重叠。
]

#parec[
  In some algorithms, the regions may also be adaptively subdivided based on the number of primitives that overlap them. When a ray intersection needs to be found, the sequence of these regions that the ray passes through is computed and only the primitives in the overlapping regions are tested for intersection.
][
  在某些算法中，这些区域也可以根据与之重叠的图元数量进行自适应细分。当需要找到光线相交时，计算光线经过的这些区域的序列，并且仅测试重叠区域中的图元是否相交。
]

#parec[
  In contrast, object subdivision is based on progressively breaking the objects in the scene down into smaller groups of nearby objects. For example, a model of a room might be broken down into four walls, a ceiling, and a chair.
][
  相比之下，物体细分是基于逐步将场景中的对象分解为更小的邻近对象组。例如，一个房间的模型可能被分解为四面墙、一个天花板和一把椅子。
]

#parec[
  If a ray does not intersect the room's bounding volume, then all of its primitives can be culled. Otherwise, the ray is tested against each of them. If it hits the chair's bounding volume, for example, then it might be tested against each of its legs, the seat, and the back. Otherwise, the chair is culled.
][
  如果光线没有与房间的包围体积相交，那么它的所有图元都可以被剔除。否则，光线需要与每个图元进行测试。例如，如果光线击中椅子的包围体积，那么它可能会与椅子的每条腿、座位和靠背进行测试。否则，椅子将被剔除。
]

#parec[
  Both of these approaches have been quite successful at solving the general problem of ray intersection computational requirements; there is no fundamental reason to prefer one over the other.
][
  这两种方法在解决光线相交计算需求的普遍问题上都取得了显著的成功；没有根本的理由偏好其中一种方法。
]

#parec[
  The BVHAggregate is based on object subdivision and the KdTreeAggregate (which is described in the online edition of this book) is based on spatial subdivision. Both are defined in the files cpu/aggregates.h and cpu/aggregates.cpp.
][
  #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate] 基于物体细分，而 #link("<KdTreeAggregate>")[KdTreeAggregate];（在本书的在线版中描述）基于空间细分。两者都在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/aggregates.h")[cpu/aggregates.h] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/aggregates.cpp")[cpu/aggregates.cpp] 中定义。
]

#parec[
  As with the TransformedPrimitive and AnimatedPrimitive classes, the intersection methods for aggregates are not responsible for setting the material, area light, and medium information at the intersection point: those are all set by the actually intersected primitive and should be left unchanged by the aggregate.
][
  与 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive] 和 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#AnimatedPrimitive")[AnimatedPrimitive] 类一样，聚合的相交方法不负责在相交点设置材质、面积光和介质信息：这些信息由实际相交的图元设置，聚合不应改变这些信息。
]


