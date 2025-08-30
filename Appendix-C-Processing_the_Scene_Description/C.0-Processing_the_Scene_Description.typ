#import "../template.typ": parec

= Processing the Scene Description

#parec[
  In the discussion of `pbrt`’s `main()` function in Section
  #link("Introduction/pbrt_System_Overview.html#sec:pbrt-main")[1.3.2] at
  the start of the book, we wrote that after the command-line arguments
  are processed, the scene description is parsed and converted into
  corresponding `Shape`s, `Light`s, `Material`s, and so forth. Thereafter,
  as we have discussed the implementations of those classes, we have not
  worried about when they are created or where the parameter values for
  their constructors come from. This appendix fills in that gap and
  explains the path from human-readable scene description files to
  corresponding C++ objects in memory.

][
  在本书开篇对 pbrt 的 `main()`
  函数的讨论中，我们写道，在处理完命令行参数后，场景描述将被解析并转换为相应的
  `Shape`、`Light`、`Material`
  等对象。此后，正如我们已经讨论了这些类的实现，我们并不关心它们何时被创建，或它们的构造函数参数来自何处。本附录填补了这一空白，并解释从可读的场景描述文件到内存中相应的
  C++ 对象的路径。
]

#parec[
  The scene description is processed in three stages, each of which is
  described in successive sections of this appendix:

][
  场景描述的处理分为三个阶段，每个阶段在本附录的连续小节中描述：
]

#parec[
  - The text file format that describes the scene is parsed. Each
    statement in the file causes a corresponding method to be called in a
    `ParserTarget` class implementation.

][
  - 描述场景的文本文件格式用来描述场景；文件中的每条语句都会在一个实现了
    `ParserTarget` 接口的类中调用相应的方法。
]

#parec[
  - An instance of the `BasicSceneBuilder` class, which implements the
    `ParserTarget` interface, tracks graphics state such as the current
    material and transformation matrix as the file is parsed. For each
    entity in the scene (the camera, each light and shape, etc.), it
    produces a single object that represents the entity and its
    parameters.

][
  - 一个实现了 `ParserTarget` 接口的 `BasicSceneBuilder`
    类的实例，在解析文件时会跟踪图形状态，例如当前材质和变换矩阵。对于场景中的每个实体（相机、每个灯和形状等），它会生成一个表示该实体及其参数的对象。
]

#parec[
  - A `BasicScene` instance collects the objects produced by the
    `BasicSceneBuilder` and creates the corresponding object types that
    are used for rendering.

][
  - 一个 `BasicScene` 实例收集 `BasicSceneBuilder`
    产生的对象，并创建用于渲染的相应对象类型。
]

#parec[
  Once the `BasicScene` is complete, it is passed to either the
  `RenderCPU()` or `RenderWavefront()` function, as appropriate. Those
  functions then create the final representation of the scene that they
  will use for rendering. For most types of scene objects (e.g., the
  `Sampler`), both call a `BasicScene` method that returns the object that
  corresponds to what was specified in the scene description. Those two
  functions diverge in how they represent the intersectable scene
  geometry. In
  #link("Introduction/pbrt_System_Overview.html#RenderCPU")[RenderCPU()]
  as well as when the wavefront renderer is running on the CPU, the
  primitives and accelerators defined in Chapter
  #link("Primitives_and_Intersection_Acceleration.html#chap:acceleration")[7]
  are used to represent it. With GPU rendering, shapes are converted to
  the representation expected by the GPU’s ray-tracing API.

][
  一旦完成 `BasicScene`，它将被传递给 `RenderCPU()` 或 `RenderWavefront()`
  函数，视情况而定。随后，这些函数会创建它们将用于渲染的场景的最终表示。对于大多数类型的场景对象（例如
  `Sampler`），两者都会调用 `BasicScene`
  提供的一个方法，该方法返回与场景描述中所指定的对象相对应的对象。这两种函数在表示可相交的场景几何体的方式上有所不同。在
  #link("Introduction/pbrt_System_Overview.html#RenderCPU")[RenderCPU()]
  以及波前渲染器在 CPU 上运行时，章节
  #link("Primitives_and_Intersection_Acceleration.html#chap:acceleration")[7]
  中定义的基元和加速结构被用来表示场景。使用 GPU 渲染时，形状会被转换为
  GPU 光线追踪 API 所期望的表示。
]
