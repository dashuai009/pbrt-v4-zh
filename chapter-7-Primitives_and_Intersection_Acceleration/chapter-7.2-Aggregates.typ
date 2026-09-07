#import "../template.typ": parec, ez_caption


== #ez_caption[Aggregates][聚合体]
<aggregates>

#parec[
  Ray intersection acceleration structures are one of the components at the heart of any ray tracer. Without algorithms to reduce the number of unnecessary ray intersection tests, tracing a single ray through a scene would take time linear in the number of primitives in the scene, since the ray would need to be tested against each primitive to find the closest intersection.
][
  射线求交加速结构是光线追踪器的核心组件之一。如果没有算法减少不必要的求交测试，在场景中追踪一条射线所需的时间就与图元数量成正比，因为必须逐个测试全部图元，才能找到最近的交点。
]

#parec[
  However, doing so is extremely wasteful in most scenes, since the ray passes nowhere near the vast majority of primitives. The goals of acceleration structures are to allow the quick, simultaneous rejection of groups of primitives and to order the search process so that nearby intersections are likely to be found first and farther away ones can potentially be ignored.
][
  然而，对多数场景而言，这样做十分浪费：射线根本不会经过绝大多数图元附近。加速结构的目标是快速同时排除整组图元，并安排搜索顺序，使较近的交点更有可能先被找到，从而有机会忽略较远的交点。
]

#parec[
  Because ray–object intersections can account for the bulk of execution time in ray tracers, there has been a substantial amount of research into algorithms for ray intersection acceleration. We will not try to explore all of this work here but refer the interested reader to references in the "Further Reading" section at the end of this chapter.
][
  射线与对象的求交可能占据光线追踪器运行时间的大部分，因此求交加速算法已得到广泛研究。这里不逐一讨论，感兴趣的读者可参阅章末“延伸阅读”列出的资料。
]

#parec[
  Broadly speaking, there are two main approaches to this problem: spatial subdivision and object subdivision. Spatial subdivision algorithms decompose 3D space into regions (e.g., by superimposing a grid of axis-aligned boxes on the scene) and record which primitives overlap which regions.
][
  总体上，这个问题主要有两类解法：空间划分与对象划分。空间划分算法将三维空间分成若干区域，例如在场景上覆盖一个由轴对齐盒子组成的网格，并记录各图元与哪些区域重叠。
]

#parec[
  In some algorithms, the regions may also be adaptively subdivided based on the number of primitives that overlap them. When a ray intersection needs to be found, the sequence of these regions that the ray passes through is computed and only the primitives in the overlapping regions are tested for intersection.
][
  某些算法还根据与区域重叠的图元数量，自适应地继续划分区域。求交时，先确定射线依次穿过哪些区域，再仅对这些区域中的图元进行求交测试。
]

#parec[
  In contrast, object subdivision is based on progressively breaking the objects in the scene down into smaller groups of nearby objects. For example, a model of a room might be broken down into four walls, a ceiling, and a chair.
][
  对象划分则把场景中的对象逐步分成更小的组，每组包含位置相近的对象。例如，房间模型可以分成四面墙、天花板和一把椅子。
]

#parec[
  If a ray does not intersect the room's bounding volume, then all of its primitives can be culled. Otherwise, the ray is tested against each of them. If it hits the chair's bounding volume, for example, then it might be tested against each of its legs, the seat, and the back. Otherwise, the chair is culled.
][
  如果射线不与房间的包围体相交，就可以排除其中全部图元；否则，继续逐一测试。例如，若射线击中椅子的包围体，就可能继续测试各条椅腿、椅面和椅背；否则，就排除整把椅子。
]

#parec[
  Both of these approaches have been quite successful at solving the general problem of ray intersection computational requirements; there is no fundamental reason to prefer one over the other.
][
  这两类方法都有效地解决了射线求交的计算需求问题，没有根本性理由认定其中一类必然优于另一类。
]

#parec[
  The BVHAggregate is based on object subdivision and the KdTreeAggregate (which is described in the online edition of this book) is based on spatial subdivision. Both are defined in the files cpu/aggregates.h and cpu/aggregates.cpp.
][
  #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[`BVHAggregate`] 采用对象划分，#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[`KdTreeAggregate`]（本书在线版介绍）采用空间划分。二者都定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/aggregates.h")[`cpu/aggregates.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/aggregates.cpp")[`cpu/aggregates.cpp`] 中。
]

#parec[
  As with the TransformedPrimitive and AnimatedPrimitive classes, the intersection methods for aggregates are not responsible for setting the material, area light, and medium information at the intersection point: those are all set by the actually intersected primitive and should be left unchanged by the aggregate.
][
  与 `TransformedPrimitive` 和 `AnimatedPrimitive` 一样，聚合体的求交方法不负责设置交点的材质、面光源和介质信息。这些信息由实际被射线击中的图元设置，聚合体应保持它们不变。
]


