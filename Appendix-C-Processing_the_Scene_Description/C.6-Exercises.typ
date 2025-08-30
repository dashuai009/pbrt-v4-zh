#import "../template.typ": parec, translator


== Exercises
<exercises>

#parec[
  + An advantage of the way that `pbrt` separates parsing, graphics state
    management, and the creation of scene objects is that it is easier to
    replace or extend those components of the system than it might be if
    all those responsibilities were in a single class. Investigate
    `pbrt`’s parsing performance with scenes that have multi-gigabyte
    `*.pbrt` scene description files (Disney’s #emph[Moana Island] scene
    (#link("Further_Reading.html#cite:DisneyMoana")[Walt Disney Animation Studios 2018];)
    is a good choice) and develop a scene description format for `pbrt`
    that is more efficient to parse. You might, for example, consider a
    compact binary format.
][
  + 将 pbrt
    的解析、图形状态管理及场景对象创建分离的一个重要优点是，相较于把所有这些职责放在同一个类中，它更容易替换或扩展系统中的这些组件。研究带有大小达到数十GB级别的
    `*.pbrt` 场景描述文件的 `pbrt` 解析性能（迪士尼的 Moana Island
    场景，Walt Disney Animation Studios 2018；参见
    Further\_Reading.html\#cite:DisneyMoana），并为 `pbrt`
    开发一种更高效的场景描述格式以便解析。你也可以考虑一种紧凑的二进制格式。

]

#parec[
  Take advantage of the
  #link("../Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParserTarget")[ParserTarget interface]
  to write a converter from `pbrt`’s current scene file format to your
  format and then implement new parsing routines that call
  `ParserTarget` interface methods. Use a profiler to measure how much
  time is spent in parsing before and after your changes. What is the
  performance benefit from your representation? How much smaller are
  file sizes?
][

  利用 \[ParserTarget 接口\] 编写一个将 `pbrt`
  当前场景描述文件格式转换为你定义的表示格式（representation
  format）的转换器，然后实现新的解析例程以调用 `ParserTarget`
  接口方法。请使用性能分析器来比较改动前后在解析阶段的耗时，并记录文件大小的变化。你实现的表示格式带来多少性能提升？文件大小缩小了多少？

]

#parec[
  + Generalize `pbrt`’s mechanism for specifying animation; the current
    implementation only allows the user to provide two transformation
    matrices, at the start and end of a fixed time range. For specifying
    more complex motion, a more flexible approach may be useful. One
    improvement is to allow the user to specify an arbitrary number of
    keyframe transformations, each associated with an arbitrary time.
][

  + 将 `pbrt` 指定动画的机制推广到更通用的形式；当前实现仅允许用户在固定时间范围的起点和终点提供两个变换矩阵。为指定更复杂的运动，可能需要一种更灵活的方法。一个改进是允许用户指定任意数量的关键帧变换，每个关键帧都关联一个时间点。

]

#parec[

  More generally, the system could be extended to support
  transformations that are explicit functions of time. For example, a
  rotation could be described with an expression of the form Rotate
  (time \* 2 + 1) 0 0 1 to describe a time-varying rotation about the
  $z$ axis. Extend `pbrt` to support a more general matrix animation
  scheme, and render images showing results that are not possible with
  the current implementation. Is there a performance cost due to your
  changes for scenes with animated objects that do not need the
  generality of your improvements?
][

  更一般地，系统可扩展以支持随时间显式表示为函数的变换，例如绕 z
  轴的旋转可以用 Rotate(time \* 2 + 1) 0 0 1 来描述。扩展 `pbrt`
  以支持更通用的矩阵动画方案，并渲染出当前实现无法实现的结果图像。由于这些改动，带有动画对象的场景是否会产生性能成本？若会，其成本有多大？

]

#parec[

  + Extend `pbrt` to have some retained mode semantics so that animated
    sequences of images can be rendered without needing to respecify the
    entire scene for each frame. Make sure that it is possible to remove
    some objects from the scene, add others, modify objects’ materials and
    transformations from frame to frame, and so on. Measure the
    performance benefit from your approach versus the current
    implementation. How is the benefit affected by how fast rendering is?
][

  + 将 `pbrt` 扩展为具备保留模式（retained
    mode）语义，以便在不需要为每一帧重新指定整个场景的情况下渲染一系列动画图像。确保能够从场景中移除某些对象、添加其他对象、逐帧修改对象的材质与变换等。衡量该方法相对于当前实现的性能提升。该提升如何随渲染速度的变化而变化？（保留模式语义，retained
    mode）

]

#parec[

  + In `pbrt`’s current implementation, a unique `TransformedPrimitive` is
    created for each `Shape` with an animated transformation when the CPU
    is used for rendering. If many shapes have exactly the same animated
    transformation, this turns out to be a poor choice. Consider the
    difference between a million-triangle mesh with an animated
    transformation versus a million independent triangles, all of which
    happen to have the same animated transformation.
][

  + 在 `pbrt` 的当前实现中，对于使用 CPU 渲染且带有动画变换的
    `Shape`，会为其创建一个唯一的
    `TransformedPrimitive`。如果很多形状恰好具有相同的动画变换，这通常并非最佳选择。请比较两种情况：第一种是网格中的所有三角形被存储在一个带有动画变换的
    `TransformedPrimitive` 的单一实例中；第二种是每个三角形都拥有自己的
    `TransformedPrimitive`，且它们恰好具有相同的
    `AnimatedTransform`。

]

#parec[

  In the first case, all the triangles in the mesh are stored in a
  single instance of a `TransformedPrimitive` with an animated
  transformation. If a ray intersects the bounding box that encompasses
  all the object’s motion over the frame time, then it is transformed to
  the mesh’s object space according to the interpolated transformation
  at the ray’s time. At this point, the intersection computation is no
  different from the intersection test with a static primitive; the only
  overhead due to the animation is from the larger bounding box and rays
  that hit the bounding box but not the animated primitive and the extra
  computation for matrix interpolation and transforming each ray once,
  according to its time.
][
  在第一种情况下，网格中的所有三角形都在一个实例中处理；
]

#parec[
  In the second case, each triangle is stored in its own
  `TransformedPrimitive`, all of which happen to have the same
  `AnimatedTransform`. Each instance of `TransformedPrimitive` will have
  a large bounding box to encompass each triangle’s motion, giving the
  acceleration structure a difficult set of inputs to deal with: many
  primitives with substantially overlapping bounding boxes. The impact
  on ray–primitive intersection efficiency will be high: the ray will be
  redundantly transformed many times by what happens to be the same
  recomputed interpolated transformation, and many intersection tests
  will be performed due to the large bounding boxes. Performance will be
  much worse than the first case.
][
  在第二种情况下，边界盒更大、相交测试更多且会对同一插值变换重复计算。性能将如何变化？
]

#parec[

  To address this case, modify the code that creates primitives so that
  if independent shapes are provided with the same animated
  transformation, they are all collected into a single acceleration
  structure with a single animated transformation. What is the
  performance improvement for the worst case outlined above? Are there
  cases where the current implementation is a better choice?
][
  为解决这种情况，请修改创建图元（primitive）的代码：若独立的形状提供了相同的动画变换，它们应被聚合到一个具有单一动画变换的单一加速结构中。
  上述最坏情况的性能改进有多大？是否存在某些情况下当前实现是更好的选择？
]
