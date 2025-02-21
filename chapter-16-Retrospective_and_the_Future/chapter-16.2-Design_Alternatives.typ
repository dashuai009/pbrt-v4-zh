#import "../template.typ": parec

== Design Alternatives

#parec[
  `pbrt` represents a single point in the space of rendering system designs. The basic decisions we made early on—that ray tracing would be the geometric visibility algorithm used, that physical correctness would be a cornerstone of the system, that Monte Carlo would be the main approach used for numerical integration—all had pervasive implications for the system's design.
][
  `pbrt` 代表了渲染系统设计空间中的一个点。我们早期做出的基本决策——使用光线追踪作为几何可见性算法、物理正确性作为系统的基石、蒙特卡罗方法作为数值积分的主要方法——都对系统的设计产生了深远的影响。
]

#parec[
  There are many ways to write a renderer, and the best approach depends on many factors: is portability important, or can the system target a single type of computer system? Is interaction a requirement, or is the renderer a batch-mode system? Is time a constraint (e.g., a requirement to maintain a fixed frame rate), or must rendering continue until a particular quality level is reached? Must the system be able to render any scene no matter how complex, or can it impose limitations on the input?
][
  编写渲染器有很多种方法，最佳方法取决于许多因素：可移植性是否重要，还是系统可以针对单一类型的计算机系统？交互性是否是一个要求，还是渲染器是一个批处理模式系统？时间是否是一个限制（例如，需要保持固定的帧率），还是渲染必须持续到达到特定的质量水平？系统是否必须能够渲染任何场景，无论其多么复杂，还是可以对输入施加限制？
]

#parec[
  Throughout the book, we have tried to always add an exercise at the end of the chapter when we have known that there was an important design alternative or where we made an implementation trade-off that would likely be made differently in a rendering system with different goals than `pbrt`. It is therefore worth reading the exercises even if you do not plan to do them. Going beyond the exercises, we will discuss a number of more radical design alternatives for path tracing–based rendering systems that are good to be aware of if you are designing a renderer yourself.
][
  在整本书中，我们尝试在每章末尾添加一个练习，当我们知道有一个重要的设计替代方案或我们做出了一个实现上的权衡，而在具有不同目标的渲染系统中可能会做出不同的选择时。因此，即使您不打算做，也值得阅读这些练习。 超越练习，我们将讨论一些基于路径追踪的渲染系统的更激进的设计替代方案，如果您自己在设计渲染器，这些方案值得了解。
]

=== Out-of-Core Rendering

#parec[
  Given well-built acceleration structures, a strength of ray tracing is that the time spent on ray–primitive intersections grows slowly with added scene complexity. As such, the maximum complexity that a ray tracer can handle may be limited more by memory than by computation. Because rays may pass through many different regions of the scene over a short period of time, virtual memory often performs poorly when ray tracing complex scenes due to the resulting incoherent memory access patterns.
][
  在构建良好的加速结构的情况下，光线追踪的一个优势是随着场景复杂度的增加，光线与图元的交叉时间增长缓慢。因此，光线追踪器可以处理的最大复杂度可能更多地受到内存而非计算的限制。 因为光线可能在短时间内穿过场景的许多不同区域，虚拟内存在光线追踪复杂场景时通常表现不佳，因为由此产生的不连贯的内存访问模式。
]

#parec[
  One way to increase the potential complexity that a renderer is capable of handling is to reduce the memory used to store the scene. For example, `pbrt` currently uses approximately 3.3 GB of memory to store the 24 million triangles and the BVHs in the landscape scene in Figure 7.2. This works out to an average of 148 bytes per triangle. We have previously written ray tracers that managed an average of 40 bytes per triangle for scenes like these, which represents a $3.7$ times reduction. Reducing memory overhead requires careful attention to memory use throughout the system. For example, in the aforementioned system, we had three different `Triangle` implementations, one using 8-bit `uint8_t`s to store vertex indices, one using 16-bit `uint16_t`s, and one using 32-bit `uint32_t`s. The smallest index size that was sufficient for the range of vertex indices in the mesh was chosen at run time. Deering's paper on geometry compression (Deering 1995) and Ward's packed color format (Ward 1992) are both good inspirations for thinking along these lines. See the "Further Reading" section in @primitives-and-intersection-acceleration for information about more memory-efficient representations of acceleration structures.
][
  增加渲染器能够处理的潜在复杂度的一种方法是减少存储场景所需的内存。例如，`pbrt` 目前使用大约 3.3 GB 的内存来存储图 7.2 中的 2400 万个三角形和包围体层次结构。 这相当于平均每个三角形需要 148 字节。我们之前编写的光线追踪器在类似场景中每个三角形平均管理 40 字节，代表了 3.7 倍的减少。 减少内存开销需要在整个系统中仔细关注内存使用。例如，在上述系统中，我们有三种不同的 `Triangle` 实现，一种使用 8 位 `uint8_t` 存储顶点索引，一种使用 16 位 `uint16_t`，一种使用 32 位 `uint32_t`。 在运行时选择足以覆盖网格中顶点索引范围的最小索引大小。Deering 关于几何压缩的论文（Deering 1995）和 Ward 的打包颜色格式（Ward 1992）都是沿着这些思路思考的良好灵感。 有关加速结构的更高效内存表示的信息，请参阅@primitives-and-intersection-acceleration 的“进一步阅读”部分。
]

#parec[
  On-demand loading of geometry and textures can also reduce memory requirements if some parts of the scene are never needed when rendering from a particular viewpoint. An additional advantage of this approach is that rendering can often start more quickly than it would otherwise. Taking that a step further, one might cache textures (Peachey 1990) or geometry (Pharr and Hanrahan 1996), holding a fixed amount of it in memory and discarding that which has not been accessed recently when the cache is full. This approach is especially useful for scenes with much tessellated geometry, where a compact higher-level shape representation like a subdivision surface can explode into a large number of triangles: when available memory is low, some of this geometry can be discarded and regenerated later if needed. With the advent of economical flash memory storage offering gigabytes per second of read bandwidth, this approach is even more attractive.
][
  如果从特定视点渲染时场景的某些部分从未需要，按需加载几何和纹理也可以减少内存需求。 这种方法的另一个优势是渲染通常可以比其他情况下更快地开始。 更进一步，可以缓存纹理（Peachey 1990）或几何（Pharr 和 Hanrahan 1996），在内存中保持固定数量的缓存，并在缓存已满时丢弃最近未访问的内容。 这种方法对于具有大量细分几何的场景特别有用，其中像细分曲面这样的紧凑高级形状表示可以爆炸成大量三角形：当可用内存较低时，可以丢弃一些几何，并在需要时稍后重新生成。 随着提供每秒数千兆字节读取带宽的经济型闪存存储的出现，这种方法更具吸引力。
]

#parec[
  The performance of such caches can be substantially improved by reordering the rays that are traced in order to improve their spatial and thus memory coherence (Pharr et al.~1997). An easier-to-implement and more effective approach to improving the cache's behavior was described by Christensen et al.~(2003), who wrote a ray tracer that uses simplified representations of the scene geometry in a geometry cache. More recently, Yoon et al.~(2006), Budge et al.~(2009), Moon et al.~(2010), and Hanika et al.~(2010) have developed improved approaches to this problem. See Rushmeier, Patterson, and Veerasamy (1993) for an early example of how to use simplified scene representations when computing indirect illumination.
][
  通过重新排序追踪的光线以提高其空间和内存一致性，可以显著提高此类缓存的性能（Pharr 等人，1997）。 Christensen 等人（2003）描述了一种更易于实现且更有效的方法来改善缓存行为，他们编写了一个光线追踪器，使用简化的场景几何表示在几何缓存中。 最近，Yoon 等人（2006）、Budge 等人（2009）、Moon 等人（2010）和 Hanika 等人（2010）开发了改进的方法。 有关在计算间接照明时如何使用简化场景表示的早期示例，请参阅 Rushmeier、Patterson 和 Veerasamy（1993）。
]

#parec[
  Disney's #emph[Hyperion] renderer is an example of a renderer for feature films that maintains a large collection of active rays and then sorts them in order to improve the coherence of geometry and texture cache access. See the papers by Eisenacher et al.~(2013) and Burley et al.~(2018) for details of its implementation.
][
  迪士尼的 #emph[Hyperion] 渲染器是一个用于故事片的渲染器示例，它维护大量活动光线，然后对其进行排序以改善几何和纹理缓存访问的一致性。 有关其实现的详细信息，请参阅 Eisenacher 等人（2013）和 Burley 等人（2018）的论文。
]

=== Preshaded Micropolygon Grids


#parec[
  Another form of complexity that is required for feature film production is in the form of surface shading; in contrast to `pbrt`'s fairly simple texture blending capabilities, production renderers typically provide procedural shading languages that make it possible to compute material parameters by combining multiple image maps and procedural patterns such as those generated by noise functions in user-provided shader programs. Evaluating these shaders can be a major component of rendering cost.
][
  故事片制作所需的另一种复杂性形式是表面着色；与 `pbrt` 相对简单的纹理混合功能相比，制作渲染器通常提供程序化着色语言，使得可以通过组合多个图像贴图和程序化模式（如用户提供的着色器程序中生成的噪声函数）来计算材质参数。 评估这些着色器可能是渲染成本的主要组成部分。
]

#parec[
  An innovative solution to this challenge has been implemented in Weta Digital's #emph[Manuka] renderer, which is described in a paper by Fascione et al.~(2018).
][
  Weta Digital 的 #emph[Manuka] 渲染器实现了这一挑战的创新解决方案，该解决方案在 Fascione 等人（2018）的论文中有所描述。
]

#parec[
  In a first rendering phase, #emph[Manuka] tessellates all the scene geometry into grids of #emph[micropolygons];, subpixel-sized triangles. (This approach is inspired by the Reyes rendering algorithm (Cook et al.~1987).)
][
  在第一渲染阶段，#emph[Manuka] 将所有场景几何细分为微多边形网格，即亚像素大小的三角形。（这种方法受 Reyes 渲染算法（Cook 等人，1987）的启发。）
]

#parec[
  Procedural shaders are then evaluated at the polygon vertices and the resulting material parameters are stored.
][
  然后在多边形顶点处评估程序化着色器，并存储生成的材质参数。
]

#parec[
  Path tracing then proceeds using these micropolygons. At each intersection point, no shader evaluation is necessary and the material parameters are interpolated from nearby vertices in order to instantiate a BSDF.
][
  然后使用这些微多边形进行路径追踪。在每个交点处，不需要进行着色器评估，而是从附近顶点插值材质参数以实例化 BSDF。
]

#parec[
  Because micropolygons are subpixel sized, there is no visible error from not evaluating the surface shader at the actual intersection point.
][
  因为微多边形是亚像素大小的，所以在实际交点处不评估表面着色器不会产生可见误差。
]

#parec[
  If the total number of ray intersections to be shaded during rendering is larger than the number of micropolygons, this approach is generally beneficial.
][
  如果渲染期间需要着色的光线交点总数大于微多边形的数量，这种方法通常是有益的。
]

#parec[
  It offers additional benefits from exhibiting coherent texture image map accesses and from simultaneous evaluation of shaders at many vertices during the first phase, which makes the workload amenable to SIMD processing.
][
  它还提供了额外的好处，即在第一阶段可以同时在许多顶点上评估着色器，从而使工作负载适合单指令多数据处理。
]

#parec[
  Downsides of this approach include the issue that if a substantial amount of the scene's geometry is occluded and never accessed during rendering, then the work to generate those micropolygon grids will have been wasted.
][
  此方法的缺点包括如果场景几何的大量部分被遮挡并且在渲染期间从未访问过，则生成这些微多边形网格的工作将被浪费。
]

#parec[
  It also causes startup time to increase due to the first phase of computation and thus a longer wait before initial pixel values can be displayed.
][
  它还会导致启动时间增加，因为第一阶段的计算需要更长的等待时间才能显示初始像素值。
]

#parec[
  Caching preshaded micropolygon grids can help.
][
  缓存预着色微多边形网格可以有所帮助。
]

#parec[
  A related approach is described by Munkberg et al.~(2016), who cache shaded results in surface textures during rendering.
][
  Munkberg 等人（2016）描述了一种相关方法，他们在渲染期间将着色结果缓存到表面纹理中。
]

#parec[
  These cached values can then be reused over multiple frames of an animation and used to accelerate rendering effects like depth of field.
][
  这些缓存值可以在动画的多个帧中重复使用，并用于加速渲染效果如景深。
]


=== Packet Tracing
<packet-tracing>

#parec[
  Early work on parallel tracing focused on multiprocessors (Cleary et al.~#link("Further_Reading.html#cite:Cleary:1983:DAA")[1983];; #link("Further_Reading.html#cite:Green:1989:ECF")[Green and Paddon 1989];; #link("Further_Reading.html#cite:Badouel:1989:AEP")[Badouel and Priol 1989];) and clusters of computers (Parker et al.~#link("Further_Reading.html#cite:Parker:1999:IRT")[1999];; Wald et al.~#link("Further_Reading.html#cite:Wald01a")[2001a];, #link("Further_Reading.html#cite:Wald01b")[2001b];, #link("Further_Reading.html#cite:Wald02")[2002];, #link("Further_Reading.html#cite:Wald03")[2003];).
][
  早期关于并行追踪的工作集中在多处理器（Cleary 等人 #link("Further_Reading.html#cite:Cleary:1983:DAA")[1983];; #link("Further_Reading.html#cite:Green:1989:ECF")[Green 和 Paddon 1989];; #link("Further_Reading.html#cite:Badouel:1989:AEP")[Badouel 和 Priol 1989];）和计算机集群（Parker 等人 #link("Further_Reading.html#cite:Parker:1999:IRT")[1999];; Wald 等人 #link("Further_Reading.html#cite:Wald01a")[2001a];, #link("Further_Reading.html#cite:Wald01b")[2001b];, #link("Further_Reading.html#cite:Wald02")[2002];, #link("Further_Reading.html#cite:Wald03")[2003];）上。
]

#parec[
  More recently, as multi-core CPUs have become the norm and as CPUs have added computational capability through wider SIMD vector units, high-performance CPU ray-tracing research has focused on effectively using both multi-core and SIMD vector parallelism. Parallelizing ray tracing over multiple CPU cores in a single computer is not too difficult; the screen-space decomposition that `pbrt` uses is a common approach. Making good use of SIMD units is trickier; this is something that `pbrt` does not try to do in the interests of avoiding the corresponding code complexity.
][
  最近，随着多核 CPU 成为常态，并且 CPU 通过更宽的 SIMD 向量单元增加了计算能力，高性能 CPU 光线追踪研究集中在有效利用多核和 SIMD 向量并行性。在单台计算机上通过多个 CPU 核心实现光线追踪的并行化并不困难；`pbrt` 使用的屏幕空间分解是一种常见的方法。充分利用 SIMD 单元则更为棘手；`pbrt` 为了避免相应的代码复杂性，并没有尝试这样做。
]

#parec[
  SIMD widths of 8 to 16 32-bit `float`s are typical on current CPUs. Achieving the full potential performance of CPUs therefore requires using SIMD effectively. Achieving excellent utilization of SIMD vector units generally requires that the entire computation be expressed in a #emph[data parallel] manner, where the same computation is performed on many data elements simultaneously. A natural way to extract data parallelism in a ray tracer is to have each processing core responsible for tracing n rays at a time, where n is at least the SIMD width.
][
  当前 CPU 上典型的 SIMD 宽度为 8 到 16 个 32 位浮点数。因此，要实现 CPU 的全部潜在性能，就需要有效地使用 SIMD。要实现对 SIMD 向量单元的优秀利用，通常需要将整个计算表达为一种#emph[数据并行];的方式，即在许多数据元素上同时执行相同的计算。在光线追踪器中，自然提取数据并行性的方法是让每个处理核心负责一次追踪 n 条光线，其中 n 至少为 SIMD 宽度。
]

#parec[
  Each SIMD vector lane is then responsible for just a single ray, and each vector instruction performs a single scalar computation for each of the rays it is responsible for. Thus, high SIMD utilization comes naturally, at least until some rays require different computations than others.
][
  每个 SIMD 向量通道仅负责一条光线，每个矢量指令为其负责的每条光线执行单一标量计算。因此，高 SIMD 利用率自然地实现，至少在某些光线需要不同计算之前是如此。
]

#parec[
  This approach, #emph[packet tracing];, was first introduced by Wald et al.~(#link("Further_Reading.html#cite:Wald01a")[2001a];). It has since seen wide adoption. In a packet tracer, acceleration structure traversal algorithms are implemented so that they visit a node if #emph[any] of the rays in the packet passes through it; primitives in the leaves are tested for intersection with all the rays in the packet, and so forth.
][
  这种方法，即#emph[包追踪];，最早由 Wald 等人引入（#link("Further_Reading.html#cite:Wald01a")[2001a];）。此后，它被广泛采用。在包追踪器中，加速结构遍历算法被实现为只要包中的#emph[任何];光线通过节点就访问该节点；叶子中的原语被测试与包中的所有光线的交集，等等。
]

#parec[
  Reshetov et al.~(#link("Further_Reading.html#cite:mlrt05")[2005];) generalized packet tracing, showing that gathering up many rays from a single origin into a frustum and then using the frustum for acceleration structure traversal could lead to very high-performance ray tracing; they refined the frusta into subfrusta and eventually the individual rays as they reached lower levels of the tree.
][
  Reshetov 等人（#link("Further_Reading.html#cite:mlrt05")[2005];）对包追踪进行了推广，展示了从单一原点收集多条光线到一个视锥体中，然后使用该视锥体进行加速结构遍历可以导致非常高性能的光线追踪；他们将视锥体细化为子视锥体，并最终在到达树的较低层次时细化为单个光线。
]

#parec[
  Reshetov (#link("Further_Reading.html#cite:Reshetov07")[2007];) later introduced a technique for efficiently intersecting a collection of rays against a collection of triangles in acceleration structure leaf nodes by generating a frustum around the rays and using it for first-pass culling. See Benthin and Wald (#link("Further_Reading.html#cite:Benthin09")[2009];) for a technique to use ray frusta and packets for efficient shadow rays.
][
  Reshetov（#link("Further_Reading.html#cite:Reshetov07")[2007];）后来引入了一种技术，通过在加速结构叶节点中生成一个包围光线的视锥体并使用它进行第一次剔除，来有效地将一组光线与一组三角形相交。参见 Benthin 和 Wald（#link("Further_Reading.html#cite:Benthin09")[2009];），了解使用光线视锥体和包进行高效阴影光线的技术。
]

#parec[
  While packet tracing is effective for coherent collections of rays that mostly follow the same path through acceleration structures, it is much less effective for incoherent collections of rays, which are common with global illumination algorithms.
][
  虽然包追踪对于大多数沿同一路径通过加速结构的相干光线集合是有效的，但对于不相干光线集合则效果较差，这在全局照明算法中很常见。
]

#parec[
  To address this issue, Christensen et al.~(#link("Further_Reading.html#cite:Christensen2006")[2006];), Ernst and Greiner (#link("Further_Reading.html#cite:Ernst2008")[2008];), Wald et al.~(#link("Further_Reading.html#cite:Wald2008")[2008];), and Dammertz et al.~(#link("Further_Reading.html#cite:Dammertz2008")[2008];) proposed only traversing a single ray through the acceleration structure at once but improving SIMD efficiency by simultaneously testing each ray against a number of bounding boxes at each step in the hierarchy.
][
  为了解决这个问题，Christensen 等人（#link("Further_Reading.html#cite:Christensen2006")[2006];），Ernst 和 Greiner（#link("Further_Reading.html#cite:Ernst2008")[2008];），Wald 等人（#link("Further_Reading.html#cite:Wald2008")[2008];），以及 Dammertz 等人（#link("Further_Reading.html#cite:Dammertz2008")[2008];）建议一次仅通过加速结构遍历一条光线，但通过在层次结构的每一步同时测试每条光线与多个边界框来提高 SIMD 效率。
]

#parec[
  Fuetterling et al.~extended such approaches to the 16-wide SIMD units that are available on some recent CPUs (#link("Further_Reading.html#cite:Fuetterling2017")[Fuetterling et al.~2017];).
][
  Fuetterling 等人将这些方法扩展到一些最新 CPU 上可用的 16 宽 SIMD 单元（#link("Further_Reading.html#cite:Fuetterling2017")[Fuetterling 等人 2017];）。
]

#parec[
  #emph[Embree];, described in a paper by Wald et al.~(#link("Further_Reading.html#cite:Wald2014")[2014];), is a high-performance open source rendering system that supports both packet tracing and highly efficient traversal of single rays on the CPU.
][
  #emph[Embree];，由 Wald 等人（#link("Further_Reading.html#cite:Wald2014")[2014];）在一篇论文中描述，是一个高性能的开源渲染系统，支持包追踪和在 CPU 上对单个光线的高效遍历。
]

#parec[
  See also the paper by Benthin et al.~(#link("Further_Reading.html#cite:Benthin2011")[2011];) on the topic of finding a balance between these two approaches.
][
  另请参见 Benthin 等人（#link("Further_Reading.html#cite:Benthin2011")[2011];）关于在这两种方法之间找到平衡的主题的论文。
]

#parec[
  Another approach to the ray incoherence problem is to reorder small batches of incoherent rays to improve SIMD efficiency; representative work in this area includes papers by Mansson et al.~(#link("Further_Reading.html#cite:Mansson07")[2007];), Boulos et al.~(#link("Further_Reading.html#cite:Boulos08")[2008];), Gribble and Ramani (#link("Further_Reading.html#cite:Gribble08")[2008];), and Tsakok (#link("Further_Reading.html#cite:Tsakok09")[2009];).
][
  解决光线不相干问题的另一种方法是重新排序小批量的不相干光线以提高 SIMD 效率；该领域的代表性工作包括 Mansson 等人（#link("Further_Reading.html#cite:Mansson07")[2007];），Boulos 等人（#link("Further_Reading.html#cite:Boulos08")[2008];），Gribble 和 Ramani（#link("Further_Reading.html#cite:Gribble08")[2008];），以及 Tsakok（#link("Further_Reading.html#cite:Tsakok09")[2009];）的论文。
]

#parec[
  More recently, Barringer and Akenine-Möller (#link("Further_Reading.html#cite:Barringer2014")[2014];) developed a SIMD ray-traversal algorithm that delivered substantial performance improvements given large numbers of rays.
][
  最近，Barringer 和 Akenine-Möller（#link("Further_Reading.html#cite:Barringer2014")[2014];）开发了一种 SIMD 光线遍历算法，在大量光线的情况下提供了显著的性能提升。
]

#parec[
  Effectively applying SIMD to the rest of the rendering computation often requires sorting work to improve coherence; see for example Áfra et al.'s approach for sorting materials between pipeline stages to improve SIMD utilization (#link("Further_Reading.html#cite:Afra2016")[Áfra et al.~2016];).
][
  为了有效地将 SIMD 应用于渲染计算的其余部分，通常需要对工作进行排序以提高相干性；例如，参见 Áfra 等人通过在管道阶段之间对材质进行排序以提高 SIMD 利用率的方法（#link("Further_Reading.html#cite:Afra2016")[Áfra 等人 2016];）。
]

#parec[
  Many of the same principles used for efficient GPU ray tracing discussed in the "Further Reading" section of Chapter #link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15] also apply.
][
  在第 #link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15] 章的“进一步阅读”部分中讨论的用于高效 GPU 光线追踪的许多相同原则也适用。
]

#parec[
  These algorithms are often implemented with the SIMD vectorization made explicit: intersection functions are written to explicitly take some number of rays as a parameter rather than just a single ray, and so forth.
][
  这些算法通常通过显式的 SIMD 向量化来实现：交集函数被编写为显式地接受一些光线作为参数，而不是仅仅一条光线。
]

#parec[
  In contrast, as we saw in Chapter #link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15];, the parallelism in programs written for GPUs is generally implicit: code is written as if it operates on a single ray at a time, but the underlying hardware actually executes it in parallel.
][
  相反，正如我们在第 #link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15] 章中看到的那样，为 GPU 编写的程序中的并行性通常是隐式的：代码被编写得好像它一次只操作一条光线，但底层硬件实际上是并行执行的。
]

#parec[
  It is possible to use the implicit model on CPUs as well. Parker et al.'s (#link("Further_Reading.html#cite:Parker07")[2007];) ray-tracing shading language is an example of compiling an implicitly data-parallel language to a SIMD instruction set on CPUs.
][
  在 CPU 上也可以使用隐式模型。Parker 等人（#link("Further_Reading.html#cite:Parker07")[2007];）的光线追踪着色语言是将隐式数据并行语言编译为 CPU 上的 SIMD 指令集的一个例子。
]

#parec[
  See also Georgiev and Slusallek's (#link("Further_Reading.html#cite:Georgiev08")[2008];) work, where generic programming techniques are used in C++ to implement a high-performance ray tracer with details like packets well hidden.
][
  另请参见 Georgiev 和 Slusallek（#link("Further_Reading.html#cite:Georgiev08")[2008];）的工作，其中在 C++ 中使用通用编程技术实现了一个高性能光线追踪器，细节如包被很好地隐藏。
]

#parec[
  `ispc`, described in a paper by Pharr and Mark (#link("Further_Reading.html#cite:Pharr2012")[2012];), provides a general-purpose "single program multiple data" (SPMD) language for CPU vector units that also provides this model.
][
  `ispc`，由 Pharr 和 Mark（#link("Further_Reading.html#cite:Pharr2012")[2012];）在一篇论文中描述，提供了一种面向 CPU 向量单元的通用“单程序多数据”（SPMD）语言，也提供了这种模型。
]

#parec[
  The #emph[MoonRay] rendering system, which was developed at DreamWorks, uses `ispc` to target CPU SIMD units. The paper by Lee et al.~(#link("Further_Reading.html#cite:Lee2017")[2017];) describes its implementation and also discusses the important issue of maintaining data parallel computation when evaluating surface shaders.
][
  由梦工厂开发的 #emph[MoonRay] 渲染系统使用 `ispc` 以目标为 CPU SIMD 单元。Lee 等人（#link("Further_Reading.html#cite:Lee2017")[2017];）的论文描述了其实现，并讨论了在评估表面着色器时保持数据并行计算的重要问题。
]

#parec[
  If a rendering system can provide many rays for intersection tests at once, a variety of alternatives beyond packet tracing are possible.
][
  如果渲染系统能够同时提供多条光线以进行交集测试，则除了包追踪之外，还可以有多种替代方案。
]

#parec[
  For example, Keller and Wächter (#link("Further_Reading.html#cite:Keller2011")[2011];) and Mora (#link("Further_Reading.html#cite:Mora2011")[2011];) described algorithms for intersecting a large number of rays against the scene geometry where there is no acceleration structure at all.
][
  例如，Keller 和 Wächter（#link("Further_Reading.html#cite:Keller2011")[2011];）以及 Mora（#link("Further_Reading.html#cite:Mora2011")[2011];）描述了在没有加速结构的情况下，描述了将大量光线与场景几何体相交的算法。
]

#parec[
  Instead, primitives and rays are both recursively partitioned until small collections of rays and small collections of primitives remain, at which point intersection tests are performed.
][
  相反，原语和光线都被递归地划分，直到剩下小集合的光线和小集合的原语，此时执行交集测试。
]

#parec[
  Improvements to this approach were described by Áfra (#link("Further_Reading.html#cite:Afra2012")[2012];) and Nabata et al.~(#link("Further_Reading.html#cite:Nabata2013")[2013];).
][
  Áfra（#link("Further_Reading.html#cite:Afra2012")[2012];）和 Nabata 等人（#link("Further_Reading.html#cite:Nabata2013")[2013];）描述了对此方法的改进。
]

=== Interactive and Animation Rendering
<interactive-and-animation-rendering>
#parec[
  `pbrt` is very much a one-frame-at-a-time rendering system. Renderers that specifically target animation or allow the user to interact with the scene being rendered operate under a substantially different set of constraints, which leads to different designs.
][
  `pbrt` 是一个一次渲染一帧的系统。 专门针对动画或允许用户与正在渲染的场景进行交互的渲染器在很大程度上受到不同约束的影响，这导致了不同的设计。
]

#parec[
  Interactive rendering systems have the additional challenge that the scene to be rendered may not be known until shortly before it is time to render it, since the user is able to make changes to it. Fast algorithms for building or refitting acceleration structures are critical, and it may be necessary to limit the number of rays traced in order to reach a desired frame rate. The task, then, is to make the best image possible using a fixed number of rays, which requires the ability to allocate rays from a budget. As current hardware is generally not able to trace enough rays to generate noise-free path-traced images at real-time rates, such systems generally have denoising algorithms deeply integrated into their display pipeline as well.
][
  交互式渲染系统面临的额外挑战是，待渲染的场景可能在渲染前不久才被确定，因为用户可以对其进行更改。 快速构建或调整加速结构的算法至关重要，并且可能需要限制追踪的光线数量以达到预期的帧率。 因此，任务是使用固定数量的光线制作出尽可能好的图像，这需要能够从预算中分配光线。 由于当前硬件通常无法在实时速率下追踪足够的光线以生成无噪声的路径追踪图像，因此此类系统通常将去噪算法深度集成到其显示管道中。
]

#parec[
  A system that renders a sequence of images for an animation has the opportunity to reuse information temporally across frames, ranging from pixel values themselves to data structures that represent the distribution of light in the scene. An early application of this idea was described by Ghosh et al.~(#link("Further_Reading.html#cite:Ghosh2006:smc")[2006];), who applied it to rendering glossy surfaces lit by environment light sources. Scherzer et al.~(#link("Further_Reading.html#cite:Scherzer2011")[2011];) provided a comprehensive survey of work in this area until 2011.
][
  为动画渲染图像序列的系统有机会在帧之间临时重用信息，从像素值本身到表示场景中光分布的数据结构。 这个想法的早期应用由 Ghosh 等人（#link("Further_Reading.html#cite:Ghosh2006:smc")[2006];）描述，他们将其应用于由环境光源照亮的光滑表面的渲染。 Scherzer 等人（#link("Further_Reading.html#cite:Scherzer2011")[2011];）提供了截至 2011 年在该领域工作的综合调查。
]

#parec[
  More recent examples of techniques that apply temporal reuse include the SVGF denoising algorithm (#link("Further_Reading.html#cite:Schied2017")[Schied et al.~2017];, #link("Further_Reading.html#cite:Schied2018")[2018];), which reuses reprojected pixel colors across frames when appropriate, and the ReSTIR direct lighting technique (#link("Further_Reading.html#cite:Bitterli2020")[Bitterli et al.~2020];), which reuses light samples across nearby pixels and frames of an animation to substantially improve the quality of direct lighting in scenes with many light sources.
][
  最近应用时间重用的技术示例包括 SVGF 去噪算法（#link("Further_Reading.html#cite:Schied2017")[Schied 等人 2017];, #link("Further_Reading.html#cite:Schied2018")[2018];），在适当时跨帧重用重投影的像素颜色，以及 ReSTIR 直接照明技术（#link("Further_Reading.html#cite:Bitterli2020")[Bitterli 等人 2020];），在动画的相邻像素和帧中重用光样本，以显著提高在有许多光源的场景中直接照明的质量。
]

#parec[
  Other recent work in this area includes Dittebrandt et al.'s temporal sample reuse approach (#link("Further_Reading.html#cite:Dittebrandt2020")[2020];), Hasselgren et al.'s temporal adaptive sampling and denoising algorithm (#link("Further_Reading.html#cite:Hasselgren2020")[2020];), and the extension of ReSTIR to path-traced indirect illumination by Ouyang et al.~(#link("Further_Reading.html#cite:Ouyang2021")[2021];).
][
  该领域的其他近期工作包括 Dittebrandt 等人的时间样本重用方法（#link("Further_Reading.html#cite:Dittebrandt2020")[2020];），Hasselgren 等人的时间自适应采样和去噪算法（#link("Further_Reading.html#cite:Hasselgren2020")[2020];），以及 Ouyang 等人将 ReSTIR 扩展到路径追踪间接照明的工作（#link("Further_Reading.html#cite:Ouyang2021")[2021];）。
]
=== Specialized Compilation
<specialized-compilation>

#parec[
  OptiX, which was described by Parker et al.~(#link("Further_Reading.html#cite:Parker2010")[2010];), has an interesting system structure: it is a combination of built-in functionality (e.g., for building acceleration structures and traversing rays through them) that can be extended by user-supplied code (e.g., for shape intersections and surface shading). Many renderers over the years have allowed user extensibility of this sort, usually through some kind of plug-in architecture. OptiX is distinctive in that it is built using a runtime compilation system that brings all of this code together before optimizing it.
][
  OptiX，由 Parker 等人（#link("Further_Reading.html#cite:Parker2010")[2010];）描述，具有一个有趣的系统结构：它是内置功能（例如，用于构建加速结构和遍历光线）与用户提供的代码（例如，用于形状交集和表面着色）的组合。 多年来，许多渲染器允许用户以这种方式进行扩展，通常通过某种插件架构。 OptiX 的独特之处在于它是使用运行时编译系统构建的，该系统在优化之前将所有这些代码结合在一起。
]

#parec[
  Because the compiler has a view of the entire system when generating the final code, the resulting custom renderer can be automatically specialized in a variety of ways. For example, if the surface-shading code never uses the (u, v) texture coordinates, the code that computes them in the triangle shape intersection test can be optimized out as dead code. Or, if the ray's time field is never accessed, then both the code that sets it and even the structure member itself can be eliminated. This approach allows a degree of specialization (and resulting performance) that would be difficult to achieve manually, at least for more than a single system variant.
][
  由于编译器在生成最终代码时可以查看整个系统，因此生成的自定义渲染器可以自动在多种方式进行专用化。 例如，如果表面着色代码从未使用 (u, v) 纹理坐标，则可以将其在三角形形状交集测试中计算它们的代码优化掉作为无用代码。 或者，如果光线的时间字段从未被访问，则可以消除设置它的代码，甚至是结构成员本身。 这种方法允许实现一种手动难以实现的专用化（以及由此带来的性能），至少对于多个系统变体来说是如此。
]

#parec[
  An even more aggressive specialization approach is implemented in the #emph[Rodent] system, which is described in a paper by Pérard-Gayot et al.~(#link("Further_Reading.html#cite:PerardGayot19")[2019];), who also cover previous work in specialization for graphics computations. #emph[Rodent] specializes the entire renderer based on the provided scene description, eliminating unnecessary logic in order to improve performance.
][
  一种更为激进的专用化方法在 #emph[Rodent] 系统中实现，该系统由 Pérard-Gayot 等人（#link("Further_Reading.html#cite:PerardGayot19")[2019];）在一篇论文中描述，他们还介绍了以前在图形计算专用化方面的工作。 #emph[Rodent] 基于提供的场景描述专用化整个渲染器，消除不必要的逻辑以提高性能。
]


