#import "../template.typ": parec


= Primitives and Intersection Acceleration
<primitives-and-intersection-acceleration>
#parec[
  The classes described in the last chapter focus exclusively on representing geometric properties of 3D objects. Although the `Shape` interface provides a convenient abstraction for geometric operations such as intersection and bounding, it is not sufficiently expressive to fully describe an object in a scene. For example, it is necessary to bind material properties to each shape in order to specify its appearance.
][
  上一章描述的类专注于表示3D对象的几何属性。虽然`Shape`接口为几何操作（如相交和边界）提供了一个方便的抽象，但它不足以完全描述场景中的对象。 例如，有必要将材质属性绑定到每个形状上以指定其外观。
]

#parec[
  `pbrt`'s CPU and GPU rendering paths diverge in how they address this issue. The classes in this chapter implement the approach used on the CPU. On the GPU, some of the details of how properties such as materials are associated with shapes are handled by the GPU's ray-tracing APIs and so a different representation is used there; the equivalents for the GPU are discussed in Section #link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#sec:gpu-intersection-testing")[15.3.6];.
][
  `pbrt`的CPU和GPU渲染路径在处理这个问题上有所不同。本章中的类实现了在CPU上使用的方法。在GPU上，某些属性（如材质）与形状的关联细节由GPU的光线追踪API处理，因此在那里使用了不同的表示；GPU的等价实现将在#link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#sec:gpu-intersection-testing")[15.3.6节];中讨论。
]

#parec[
  For the CPU, this chapter introduces the `Primitive` interface and provides a number of implementations that allow various properties of primitives to be specified. It then presents two additional `Primitive` implementations that act as aggregates—containers that can hold many primitives. These allow us to implement #emph[acceleration structures];—data structures that help reduce the otherwise O(n) complexity of testing a ray for intersection with all n objects in a scene.
][
  对于CPU，本章介绍了`Primitive`接口，并提供了一些实现，允许指定基本体的各种属性。 然后，它介绍了两个额外的`Primitive`实现，它们作为聚合体——可以容纳许多基本体的容器。这些实现允许我们实现#emph[加速数据结构];——一种帮助减少测试光线与场景中所有 $n$ 个对象相交的 $O (n)$ 复杂度的数据结构。
]

#parec[
  The acceleration structure, #link("Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[`BVHAggregate`];, is based on building a hierarchy of bounding boxes around objects in the scene. The online edition of this book also includes the implementation of a second acceleration structure, #link("Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[`KdTreeAggregate`];, which is based on adaptive recursive spatial subdivision. While many other acceleration structures have been proposed, almost all ray tracers today use one of these two. The "Further Reading" section at the end of this chapter has extensive references to other possibilities. Because construction and use of intersection acceleration structures is an integral part of GPU ray-tracing APIs, the acceleration structures in this chapter are only used on the CPU.
][
  加速数据结构，#link("Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[`BVHAggregate`];，基于在场景中的对象周围构建包围盒层次结构。本书的网络版还包括第二种加速数据结构的实现，#link("Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[`KdTreeAggregate`];，它基于自适应递归空间划分。 虽然已经提出了许多其他加速数据结构，但几乎所有现代光线追踪器都使用这两种之一。本章末尾的“延伸阅读”部分有大量关于其他可能性的参考资料。 由于相交加速数据结构的构建和使用是GPU光线追踪API的一个不可或缺的部分，因此本章中的加速数据结构仅用于CPU。
]

