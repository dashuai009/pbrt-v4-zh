#import "../template.typ": parec

== Exercises

#parec[
  + #emoji.cat.face.laugh Similarly What kinds of scenes are worst-case scenarios for the two acceleration
    structures in `pbrt`? (Consider specific geometric configurations that
    the approaches will respectively be unable to handle well.) Construct
    scenes with these characteristics, and measure the performance of
    `pbrt` as you add more primitives. How does the worst case for one
    behave when rendered with the other?
][
  + #emoji.cat.face.laugh Similarly 对于 `pbrt`
    中的两种加速结构，哪些场景是最坏情况？（考虑具体的几何配置，这些方法分别无法很好地处理。）构建具有这些特征的场景，并在添加更多图元时测量
    `pbrt`
    的性能。当用另一种加速结构渲染时，一个加速结构在最坏情况下的表现如何？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + #emoji.cat.face.laugh Similarly Implement a hierarchical grid accelerator where cells that have an
      excessive number of primitives overlapping them are refined to instead
      hold a finer subgrid to store its geometry. (See, for example, Jevans
      and Wyvill (1989) for one approach to this problem and Ize et
      al.~(2007) for effective methods for deciding when refinement is
      worthwhile.) Compare both accelerator construction performance and
      rendering performance to a non-hierarchical grid as well as to
      `pbrt`'s built-in accelerators.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + #emoji.cat.face.laugh Similarly 实现一个分层网格加速器，其中包含过多重叠图元的单元被细化为更细的子网格以存储其几何体。（例如，参见
      Jevans 和 Wyvill (1989) 关于此问题的一种方法，以及 Ize 等 (2007)
      关于何时值得细化的有效方法。）将加速器的构建性能和渲染性能与非分层网格以及
      `pbrt` 的内置加速器进行比较。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + #emoji.cat.face.laugh Similarly #emph[Smarter overlap tests for building aggregates];: using objects' bounding boxes to determine which sides of a kd-tree split they overlap can hurt performance by causing unnecessary intersection tests. Therefore, add a `bool Overlaps(const Bounds3f &) const` method to the #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface that takes a rendering space bounding box and determines if the shape truly overlaps the given bound. A default implementation could get the rendering space bound from the shape and use that for the test, and specialized versions could be written for frequently used shapes. Implement this method for `Sphere`s and `Triangle`s, and modify #link("../Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[KdTreeAggregate] to call it. You may find it helpful to read Akenine-Möller's paper (2001) on fast triangle-box overlap testing. Measure the change in `pbrt`'s overall performance caused by this change, separately accounting for increased time spent building the acceleration structure and reduction in ray–object intersection time due to fewer intersections. For a variety of scenes, determine how many fewer intersection tests are performed thanks to this improvement.

  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + #emoji.cat.face.laugh Similarly #emph[更智能的重叠测试以构建聚合体];：使用对象的边界框来确定它们与 kd-tree 分割的哪一侧重叠可能会导致不必要的相交测试，从而影响性能。因此，向
    #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape]
    接口添加一个 `bool Overlaps(const Bounds3f &) const`
    方法，该方法接受一个渲染空间边界框并确定形状是否真正与给定边界重叠。
    默认实现可以从形状中获取渲染空间边界并使用它进行测试，并可以为常用形状编写特定版本。为
    `Sphere` 和 `Triangle` 实现此方法，并修改
    #link("../Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[KdTreeAggregate]
    以调用它。阅读 Akenine-Möller (2001)
    关于快速三角形-盒重叠测试的论文可能会有所帮助。测量此更改对 `pbrt`
    整体性能的影响，分别考虑构建加速结构所花费的时间增加和由于减少相交而导致的射线-对象相交时间减少。对于各种场景，确定由于此改进而执行的相交测试减少了多少。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 4)
    + #emoji.cat.face.laugh Similarly Implement "split clipping" in `pbrt`'s BVH implementation. Read one or
      more papers on this topic, including ones by Ernst and Greiner (2007),
      Dammertz and Keller (2008a), Stich et al.~(2009), Karras and Aila
      (2013), and Ganestam and Doggett (2016), and implement one of their
      approaches to subdivide primitives with large bounding boxes relative
      to their surface area into multiple subprimitives for tree
      construction. (Doing so will probably require modification to the
      #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface;
      you will probably want to design a new interface that allows some
      shapes to indicate that they are unable to subdivide themselves, so
      that you only need to implement this method for triangles, for
      example.)
    Measure the improvement for rendering actual scenes; a compelling way to
    gather this data is to do the experiment that Dammertz and Keller did,
    where a scene is rotated around an axis over progressive frames of an
    animation. Typically, many triangles that are originally axis aligned
    will have very loose bounding boxes as they rotate more, leading to a
    substantial performance degradation if split clipping is not used.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 4)
    + #emoji.cat.face.laugh Similarly 在 `pbrt` 的 BVH
      实现中实现“分割剪裁”。阅读一篇或多篇关于此主题的论文，包括 Ernst 和
      Greiner (2007)、Dammertz 和 Keller (2008a)、Stich 等 (2009)、Karras 和
      Aila (2013) 以及 Ganestam 和 Doggett (2016)
      的论文，并实现他们的一种方法，将边界框相对于其表面积较大的图元细分为多个子图元以进行树构建。（这样做可能需要修改
      #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape]
      接口；您可能需要设计一个新接口，允许某些形状指示它们无法自行细分，因此您只需为三角形实现此方法即可。）
    测量渲染实际场景的改进；收集此数据的一种引人注目的方法是进行 Dammertz 和
    Keller
    所做的实验，其中一个场景围绕动画的轴旋转。通常，许多最初与轴对齐的三角形在旋转更多时会有非常松散的边界框，如果不使用分割剪裁，将导致性能大幅下降。
  ]
]


#parec[
  #block[
    #set enum(numbering: "1.", start: 5)
    + #emoji.cat.face.laugh The 30-bit Morton codes used for the HLBVH construction algorithm in
      the
      #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate]
      may be insufficient for scenes with large spatial extents because they
      can only represent $2^10 = 1024$ steps in each dimension. Modify the
      #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate]
      to use 64-bit integers with 63-bit Morton codes for HLBVHs. Compare
      the performance of your approach to the original one with a variety of
      scenes. Are there scenes where performance is substantially improved?
      Are there any where there is a loss of performance?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 5)
    + #emoji.cat.face.laugh 用于
      #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate]
      中 HLBVH 构建算法的 30 位 Morton
      码可能不足以处理具有大空间范围的场景，因为它们只能在每个维度上表示
      $2^10 = 1024$ 步。修改
      #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate]
      以使用 64 位整数和 63 位 Morton 码用于
      HLBVH。将您的方法与原始方法在各种场景中的性能进行比较。是否有场景性能显著提高？是否有性能下降的场景？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 6)
    + #emoji.cat.face.laugh Investigate alternative SAH cost functions for building BVHs or
      kd-trees. How much can a poor cost function hurt its performance? How
      much improvement can be had compared to the current one? (See the
      discussion in the "Further Reading" section for ideas about how the
      SAH may be improved.)
  ]
][
  #block[
    #set enum(numbering: "1.", start: 6)
    + #emoji.cat.face.laugh 调查用于构建 BVH 或 kd-tree 的替代 SAH
      成本函数。一个不良的成本函数会对性能造成多大影响？与当前的相比，可以获得多少改进？（参见“进一步阅读”部分的讨论，了解如何改进
      SAH 的想法。）
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 7)
    + #emoji.cat.face.shock The idea of using spatial data structures for ray intersection
      acceleration can be generalized to include spatial data structures
      that themselves hold other spatial data structures rather than just
      primitives. Not only could we have a grid that has subgrids inside the
      grid cells that have many primitives in them, but we could also have
      the scene organized into a hierarchical bounding volume where the leaf
      nodes are grids that hold smaller collections of spatially nearby
      primitives. Such hybrid techniques can bring the best of a variety of
      spatial data structure–based ray intersection acceleration methods. In
      `pbrt`, because both geometric primitives and intersection
      accelerators implement the
      #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive]
      interface and thus provide the same interface, it is easy to mix and
      match in this way.
    Modify `pbrt` to build hybrid acceleration structures—for example, using
    a BVH to coarsely partition the scene geometry and then uniform grids at
    the leaves of the tree to manage dense, spatially local collections of
    geometry. Measure the running time and memory use for rendering scenes
    with this method compared to the current aggregates.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 7)
    + #emoji.cat.face.shock 使用空间数据结构进行射线相交加速的想法可以推广到包括不仅仅持有图元的空间数据结构，还持有其他空间数据结构。不仅可以有一个网格，其中包含许多图元的单元内有子网格，还可以将场景组织成一个分层边界体，其中叶节点是持有较小空间附近图元集合的网格。这种混合技术可以带来基于各种空间数据结构的射线相交加速方法的最佳效果。在
      `pbrt` 中，因为几何图元和相交加速器都实现了
      #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive]
      接口，因此提供相同的接口，可以轻松地以这种方式混合和匹配。
    修改 `pbrt` 以构建混合加速结构——例如，使用 BVH
    粗略地划分场景几何，然后在树的叶子上使用均匀网格来管理密集的、空间局部的几何集合。测量使用此方法渲染场景的运行时间和内存使用情况，并与当前聚合进行比较。
  ]
]


#parec[
  #block[
    #set enum(numbering: "1.", start: 8)
    + Eisemann et al.~(2007) described an even more efficient ray–box
      intersection test than is used in the
      #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate];.
      It does more computation at the start for each ray but makes up for
      this work with fewer computations to do tests for individual bounding
      boxes. Implement their method in `pbrt`, and measure the change in
      rendering time for a variety of scenes. Are there simple scenes where
      the additional upfront work does not pay off? How does the improvement
      for highly complex scenes compare to the improvement for simpler
      scenes?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 8)
    + Eisemann 等 (2007) 描述了一种比
      #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[BVHAggregate]
      中使用的更高效的射线-盒相交测试。它在每条射线开始时进行更多计算，但通过减少对单个边界框的测试计算来弥补这项工作。在
      `pbrt`
      中实现他们的方法，并测量各种场景的渲染时间变化。是否有简单场景中额外的前期工作没有得到回报？对于高度复杂的场景，与较简单场景相比，改进如何？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 9)
    + Although the intersection algorithm implemented in the
      #link("../Shapes/Triangle_Meshes.html#IntersectTriangle")[IntersectTriangle()]
      function is watertight, a source of inaccuracy in ray–triangle
      intersections computed in `pbrt` remains: because the triangle
      intersection algorithm shears the vertices of the triangle, it may no
      longer lie in its original bounding box. In turn, the BVH traversal
      algorithm must be modified to account for this error so that valid
      intersections are not missed. Read the discussion of this issue in
      Woop et al.'s paper (2013) and modify `pbrt` to fix this issue. What
      is the performance impact of your fix? Can you find any scenes where
      the image changes as a result of it?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 9)
    + 尽管
      #link("../Shapes/Triangle_Meshes.html#IntersectTriangle")[IntersectTriangle()]
      函数中实现的相交算法是无缝的，但在 `pbrt`
      中计算的射线-三角形相交仍然存在一个不准确的来源：因为三角形相交算法剪切了三角形的顶点，它可能不再在其原始边界框内。反过来，必须修改
      BVH 遍历算法以考虑此错误，以免错过有效的相交。阅读 Woop 等 (2013)
      的论文中对此问题的讨论，并修改 `pbrt`
      以解决此问题。您的修复对性能的影响是什么？您能找到任何由于此修复而导致图像变化的场景吗？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 10)
    + Read the paper by Segovia and Ernst (2010) on memory-efficient BVHs,
      and implement their approach in `pbrt`. How does memory usage with
      their approach compare to that for the `BVHAggregate`? Compare
      rendering performance with your approach to `pbrt`'s current
      performance. Discuss how your results compare to the results reported
      in their paper.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 10)
    + 阅读 Segovia 和 Ernst (2010) 关于内存高效 BVH 的论文，并在 `pbrt`
      中实现他们的方法。使用他们的方法与 `BVHAggregate`
      的内存使用情况相比如何表现？将您的方法与 `pbrt`
      当前性能进行比较。讨论您的结果与他们论文中报告的结果相比如何。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 11)
    + Modify `pbrt` to use the "mailboxing" optimization in the
      #link("../Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[KdTreeAggregate]
      to avoid repeated intersections with primitives that overlap multiple
      kd-tree nodes. Given that `pbrt` is multi-threaded, you will probably
      do best to consider either the hashed mailboxing approach suggested by
      Benthin (2006) or the inverse mailboxing algorithm of Shevtsov et
      al.~(2007a). Measure the performance change compared to the current
      implementation for a variety of scenes. How does the change in running
      time relate to changes in reported statistics about the number of
      ray–primitive intersection tests?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 11)
    + 修改 `pbrt` 以在
      #link("../Primitives_and_Intersection_Acceleration/Aggregates.html#KdTreeAggregate")[KdTreeAggregate]
      中使用“邮件箱”优化，以避免与多个 kd-tree
      节点重叠的图元进行重复相交。鉴于 `pbrt` 是多线程的，您可能最好考虑
      Benthin (2006) 建议的哈希邮件箱方法或 Shevtsov 等 (2007a)
      的反向邮件箱算法。测量与当前实现相比的性能变化对于各种场景。运行时间的变化与关于射线-图元相交测试次数的报告统计变化有何关系？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 12)
    + Consider a scene with an animated camera that is tracking a moving
      object such that there is no relative motion between the two. For such
      a scene, it may be more efficient to represent it with the camera and
      object being static and with a corresponding relative animated
      transformation applied to the rest of the scene. In this way, ray
      intersections with the tracked object will be more efficient since its
      bounding box is not expanded by its motion.
    Construct such a scene and then measure the performance of rendering it
    with both ways of representing the motion by making corresponding
    changes to the scene description file. How is performance affected by
    the size of the tracked object in the image? Next, modify `pbrt` to
    automatically perform this optimization when this situation occurs. Can
    you find a way to have these benefits when the motion of the camera and
    some objects in the scene are close but not exactly the same?

  ]
][
  #block[
    #set enum(numbering: "1.", start: 12)
    + 考虑一个场景，其中一个动画相机正在跟踪一个移动对象，以至于两者之间没有相对运动。对于这样的场景，可能更有效地表示为相机和对象是静态的，并对场景的其余部分应用相应的相对动画变换。这样，射线与跟踪对象的相交将更有效，因为其边界框不会因其运动而扩展。
    构建这样的场景，然后通过对场景描述文件进行相应的更改来测量以这两种方式表示运动的渲染性能。跟踪对象在图像中的大小如何影响性能？接下来，修改
    `pbrt`
    以在出现这种情况时自动执行此优化。您能否找到一种方法在相机和场景中某些对象的运动接近但不完全相同时获得这些好处？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 13)
    + It is often possible to introduce some approximation into the
      computation of shadows from very complex geometry (consider, e.g., the
      branches and leaves of a tree casting a shadow). Lacewell et
      al.~(2008) suggested augmenting the acceleration structure with a
      prefiltered directionally varying representation of occlusion for
      regions of space. As shadow rays pass through these regions, an
      approximate visibility probability can be returned rather than a
      binary result, and the cost of tree traversal and object intersection
      tests is reduced. Implement such an approach in `pbrt`, and compare
      its performance to the current implementation. Do you see any changes
      in rendered images?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 13)
    + 通常可以在非常复杂的几何体的阴影计算中引入一些近似（例如，考虑树的枝叶投射的阴影）。Lacewell
      等 (2008)
      建议通过预滤波的方向变化遮挡表示来增强加速结构以表示空间区域。当阴影射线穿过这些区域时，可以返回一个近似的可见性概率，而不是一个二进制结果，从而减少树遍历和对象相交测试的成本。在
      `pbrt`
      中实现这种方法，并将其性能与当前实现进行比较。您是否看到渲染图像有任何变化？
  ]
]


