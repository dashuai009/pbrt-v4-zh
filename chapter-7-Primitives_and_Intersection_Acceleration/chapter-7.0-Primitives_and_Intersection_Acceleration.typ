#import "../template.typ": parec, ez_caption


= #ez_caption[Primitives and Intersection Acceleration][图元与求交加速]
<primitives-and-intersection-acceleration>
#parec[
  The classes described in the last chapter focus exclusively on representing geometric properties of 3D objects. Although the `Shape` interface provides a convenient abstraction for geometric operations such as intersection and bounding, it is not sufficiently expressive to fully describe an object in a scene. For example, it is necessary to bind material properties to each shape in order to specify its appearance.
][
  上一章的类只表示三维对象的几何属性。`Shape` 接口为求交、计算包围范围等几何操作提供了便利的抽象，但还不足以完整描述场景中的对象。例如，还需要为每个形状关联材质属性，以指定它的外观。
]

#parec[
  `pbrt`'s CPU and GPU rendering paths diverge in how they address this issue. The classes in this chapter implement the approach used on the CPU. On the GPU, some of the details of how properties such as materials are associated with shapes are handled by the GPU's ray-tracing APIs and so a different representation is used there; the equivalents for the GPU are discussed in Section #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#sec:gpu-intersection-testing")[15.3.6].
][
  `pbrt` 的 CPU 与 GPU 渲染路径以不同方式处理这一问题。本章的类实现 CPU 上的方法。在 GPU 上，材质等属性与形状之间的一些关联细节由 GPU 的光线追踪 API 处理，因此采用另一种表示。GPU 上的相应实现见 #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#sec:gpu-intersection-testing")[15.3.6 节]。
]

#parec[
  For the CPU, this chapter introduces the `Primitive` interface and provides a number of implementations that allow various properties of primitives to be specified. It then presents two additional `Primitive` implementations that act as aggregates—containers that can hold many primitives. These allow us to implement #emph[acceleration structures]—data structures that help reduce the otherwise $O(n)$ complexity of testing a ray for intersection with all $n$ objects in a scene.
][
  针对 CPU，本章介绍 `Primitive` 接口及其若干实现，用来指定图元的各种属性。随后介绍另外两种充当聚合体的 `Primitive` 实现，即能够容纳多个图元的容器。利用它们可以实现#emph[加速结构]：如果逐个测试射线与场景中全部 $n$ 个对象的相交情况，复杂度为 $O(n)$；加速结构有助于降低这一求交开销。
]

#parec[
  The acceleration structure, #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[`BVHAggregate`], is based on building a hierarchy of bounding boxes around objects in the scene. The online edition of this book also includes the implementation of a second acceleration structure, #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[`KdTreeAggregate`], which is based on adaptive recursive spatial subdivision. While many other acceleration structures have been proposed, almost all ray tracers today use one of these two. The "Further Reading" section at the end of this chapter has extensive references to other possibilities. Because construction and use of intersection acceleration structures is an integral part of GPU ray-tracing APIs, the acceleration structures in this chapter are only used on the CPU.
][
  加速结构 #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[`BVHAggregate`] 为场景对象构建包围盒层次结构。本书在线版还提供第二种加速结构 #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[`KdTreeAggregate`]，它采用自适应递归空间划分。虽然研究者还提出过许多其他加速结构，但原书所述的几乎所有光线追踪器都采用这两类之一。章末“延伸阅读”列出了其他方法的丰富参考资料。由于 GPU 光线追踪 API 已集成求交加速结构的构建与使用，本章的加速结构只用于 CPU。
]

