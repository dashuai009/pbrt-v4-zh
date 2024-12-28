#import "../template.typ": parec

#parec[
  Purcell et al.~(#link("<cite:Purcell:2002:RTO>")[2002];, #link("<cite:Purcell:2003:PMO>")[2003];) and Carr, Hall, and Hart (#link("<cite:Carr2002>")[2002];) were the first to map general-purpose ray tracers to graphics processors.
][
  Purcell 等人（#link("<cite:Purcell:2002:RTO>")[2002];，#link("<cite:Purcell:2003:PMO>")[2003];）和 Carr、Hall 及 Hart（#link("<cite:Carr2002>")[2002];）是最早将通用光线追踪器映射到图形处理器上的研究者。
]

#parec[
  A classic paper by Aila and Laine (#link("<cite:Aila09>")[2009];) carefully analyzed the performance of ray tracing on contemporary GPUs and developed improved traversal algorithms based on their insights.
][
  Aila 和 Laine 的经典论文（#link("<cite:Aila09>")[2009];）仔细分析了当代 GPU 上光线追踪的性能，并基于他们的见解开发了改进的遍历算法。
]

#parec[
  Follow-on work by Laine et al.~(#link("<cite:Laine2013>")[2013];) discussed the benefits of the wavefront architecture for rendering systems that support a wide variety of materials, textures, and lights.
][
  Laine 等人的后续工作（#link("<cite:Laine2013>")[2013];）讨论了波前架构在支持多种材质、纹理和光源的渲染系统中的优势。
]

#parec[
  (The use of a wavefront approach for the path tracer described in this chapter is motivated by Laine et al.'s insights.)
][
  （本章所述路径追踪器使用波前方法的动机来源于 Laine 等人的见解。）
]

#parec[
  Most work in performance optimization for GPU ray tracers analyzes the balance between improving thread execution and memory convergence versus the cost of reordering work to do so.
][
  大多数关于 GPU 光线追踪器性能优化的研究都分析了如何在改善线程执行和内存收敛与重新排序工作成本之间取得平衡。†
]

#parec[
  Influential early work includes Hoberock et al.~(#link("<cite:Hoberock09>")[2009];), who re-sorted a large number of intersection points to create coherent collections of work before executing their surface shaders.
][
  具有影响力的早期工作包括 Hoberock 等人（#link("<cite:Hoberock09>")[2009];），他们在执行表面着色器之前重新排序了大量交点以创建一致的工作集合。
]

#parec[
  Novák et al.~(#link("<cite:Novak2010>")[2010];) introduced #emph[path
regeneration] to start tracing new ray paths in threads that are otherwise idle due to ray termination.
][
  Novák 等人（#link("<cite:Novak2010>")[2010];）引入了#emph[路径再生];，以在由于光线终止而空闲的线程中开始追踪新的光线路径。
]

#parec[
  Wald (#link("<cite:Wald2011>")[2011];) and van Antwerpen (#link("<cite:vanAntwerpen2011>")[2011];) both applied compaction, densely packing the active threads in thread groups.
][
  Wald（#link("<cite:Wald2011>")[2011];）和 van Antwerpen（#link("<cite:vanAntwerpen2011>")[2011];）都应用了压缩技术，将活动线程密集地打包在线程组中。
]

#parec[
  Lier et al.~(#link("<cite:Lier2018:simd>")[2018b];) considered the unconventional approach of distributing the work for a single ray across multiple GPU threads and showed performance benefits for incoherent rays.
][
  Lier 等人（#link("<cite:Lier2018:simd>")[2018b];）考虑了一种非常规的方法，即将单个光线的工作分配到多个 GPU 线程中，并展示了对不一致光线的性能优势。
]

#parec[
  (This approach parallels how computation is often mapped to CPU SIMD units for high-performance ray tracing.)
][
  （这种方法类似于如何将计算映射到 CPU SIMD 单元以实现高性能光线追踪。）
]

#parec[
  Reordering the rays to be traced can also improve performance by improving the coherence of memory accesses performed during intersection tests.
][
  重新排序要追踪的光线还可以通过提高交点测试期间内存访问的连贯性来提高性能。
]

#parec[
  Early work in this area was done by Garanzha and Loop (#link("<cite:Garanzha2010>")[2010];) and Costa et al.~(#link("<cite:Costa2015>")[2015];).
][
  该领域的早期工作由 Garanzha 和 Loop（#link("<cite:Garanzha2010>")[2010];）以及 Costa 等人（#link("<cite:Costa2015>")[2015];）完成。
]

#parec[
  Meister et al.~(#link("<cite:Meister2020>")[2020];) have recently examined ray reordering in the context of a GPU with hardware-accelerated intersection testing and found benefits from using it.
][
  Meister 等人（#link("<cite:Meister2020>")[2020];）最近在具有硬件加速交点测试的 GPU 上研究了光线重新排序，并发现使用它的好处。
]

#parec[
  An alternative to taking an arbitrary set of rays and finding structure in them is to generate rays that are inherently coherent in the first place.
][
  与其对任意一组光线进行结构化，不如直接生成具有连贯性的光线。
]

#parec[
  Examples include the algorithms of Szirmay-Kalos and Purgathofer (#link("<cite:SzirmayKalos1998>")[1998];) and Hachisuka (#link("<cite:Hachisuka05>")[2005];), which select a single direction for all indirect rays at each level, allowing the use of a rasterizer with parallel projection to trace them.
][
  示例包括 Szirmay-Kalos 和 Purgathofer（#link("<cite:SzirmayKalos1998>")[1998];）以及 Hachisuka（#link("<cite:Hachisuka05>")[2005];）的算法，它们在每个级别为所有间接光线选择一个方向，允许使用具有平行投影的光栅化器来追踪它们。
]

#parec[
  More generally, adding structure to the sample values used for importance sampling can lead to coherence in the rays that are traced.
][
  更一般地说，为重要性采样使用的样本值添加结构可以导致追踪光线的连贯性。
]

#parec[
  Keller and Heidrich (#link("<cite:Keller2001:interleaved>")[2001];) developed interleaved sampling patterns that reuse sample values at separated pixels in order to trade off sample coherence and variation,
][
  Keller 和 Heidrich（#link("<cite:Keller2001:interleaved>")[2001];）开发了交错采样模式，在分隔的像素处重用样本值，以权衡样本连贯性和变化，
]

#parec[
  and Sadeghi et al.~(#link("<cite:Sadeghi2009>")[2009];) investigated the combination of interleaved sampling and using the same pseudo-random sequence at nearby pixels to increase ray coherence.
][
  Sadeghi 等人（#link("<cite:Sadeghi2009>")[2009];）研究了交错采样与在附近像素使用相同伪随机序列的结合，以增加光线连贯性。
]

#parec[
  Dufay et al.~(#link("<cite:Dufay2016>")[2016];) randomized samples using small random offsets so that nearby pixels still have similar sample values.
][
  Dufay 等人（#link("<cite:Dufay2016>")[2016];）使用小随机偏移随机化样本，以便附近像素仍具有相似的样本值。
]

#parec[
  Efficient GPU-based construction of acceleration structures is challenging due to the degree of parallelism required; there has been much research on this topic.
][
  由于所需的并行度，基于 GPU 的加速结构的高效构建具有挑战性；在这个主题上有很多研究。
]

#parec[
  See Zhou et al.~(#link("<cite:Zhou08>")[2008];), Lauterbach et al.~(#link("<cite:Lauterbach09>")[2009];), Pantaleoni and Luebke (#link("<cite:Pantaleoni2010a>")[2010];), Garanzha et al.~(#link("<cite:Garanzha2011>")[2011];), Karras and Aila (#link("<cite:Karras2013>")[2013];), Domingues and Pedrini (#link("<cite:Domingues2015>")[2015];), and Vinkler et al.~(#link("<cite:Vinkler2016>")[2016];) for techniques for building kd-trees and BVHs on GPUs.
][
  请参阅 Zhou 等人（#link("<cite:Zhou08>")[2008];）、Lauterbach 等人（#link("<cite:Lauterbach09>")[2009];）、Pantaleoni 和 Luebke（#link("<cite:Pantaleoni2010a>")[2010];）、Garanzha 等人（#link("<cite:Garanzha2011>")[2011];）、Karras 和 Aila（#link("<cite:Karras2013>")[2013];）、Domingues 和 Pedrini（#link("<cite:Domingues2015>")[2015];）以及 Vinkler 等人（#link("<cite:Vinkler2016>")[2016];）关于在 GPU 上构建 kd 树和 BVH 的技术。
]

#parec[
  See also the "Further Reading" section in Chapter #link("../Primitives_and_Intersection_Acceleration.html#chap:acceleration")[7] for additional discussion of algorithms for constructing and traversing acceleration structures on the GPU.
][
  另请参阅第#link("../Primitives_and_Intersection_Acceleration.html#chap:acceleration")[7];章中的“进一步阅读”部分，以获取有关在 GPU 上构建和遍历加速结构的算法的更多讨论。
]

#parec[
  The relatively limited amount of on-chip memory that GPUs have can make it challenging to efficiently implement light transport algorithms that require more than a small amount of storage for each ray.
][
  GPU 上相对有限的片上内存量可能使高效实现需要为每条光线存储大量数据的光传输算法变得具有挑战性。
]

#parec[
  (For example, even storing all the vertices of a pair of subpaths for a bidirectional path-tracing algorithm is much more than a thread could ask to keep on-chip.)
][
  （例如，即使存储双向路径追踪算法的一对子路径的所有顶点，也远远超过线程可以要求保留在片上的数量。）
]

#parec[
  The paper by Davidović et al.~(#link("<cite:Davidovic2014>")[2014];) gives a thorough overview of these issues and previous work and includes a discussion of implementations of a number of sophisticated light transport algorithms on the GPU.
][
  Davidović 等人（#link("<cite:Davidovic2014>")[2014];）的论文对这些问题和以前的工作进行了全面概述，并讨论了在 GPU 上实现多种复杂光传输算法。
]

#parec[
  Zellmann and Lang used compile time polymorphism in C++ to improve the performance of a GPU ray tracer (#link("<cite:Zellmann2017>")[Zellmann and Lang 2017];); our implementation in this chapter is based on similar ideas.
][
  Zellmann 和 Lang 在 C++ 中使用编译时多态性来提高 GPU 光线追踪器的性能（#link("<cite:Zellmann2017>")[Zellmann 和 Lang 2017];）；我们本章中的实现基于类似的想法。
]

#parec[
  Zhang et al.~(#link("<cite:Zhang2021>")[2021];) compared a number of approaches for dynamic function dispatch on GPUs and evaluated their performance.
][
  Zhang 等人（#link("<cite:Zhang2021>")[2021];）比较了多种 GPU 上动态函数调度的方法并评估了它们的性能。
]

#parec[
  Fewer papers have been written about the design of full ray-tracing–based rendering systems on the GPU than on the CPU.
][
  关于在 GPU 上设计完整光线追踪渲染系统的论文比在 CPU 上的要少。
]

#parec[
  Notable papers in this area include Pantaleoni et al.'s (#link("<cite:Pantaleoni2010>")[2010];) description of #emph[PantaRay];, which was used to compute occlusion and lighting by Weta Digital,
][
  该领域的著名论文包括 Pantaleoni 等人（#link("<cite:Pantaleoni2010>")[2010];）对 #emph[PantaRay] 的描述，该系统被 Weta Digital 用于计算遮挡和照明，
]

#parec[
  and Keller et al.'s (#link("<cite:Keller2017>")[2017];) discussion of the architecture of the #emph[Iray] rendering system.
][
  以及 Keller 等人（#link("<cite:Keller2017>")[2017];）对 #emph[Iray] 渲染系统架构的讨论。
]

#parec[
  Bikker and van Schijndel (#link("<cite:Bikker2013>")[2013];) described #emph[Brigade];, which targets path-traced games, balancing work between the CPU and GPU and adapting the workload to maintain the desired frame rate.
][
  Bikker 和 van Schijndel（#link("<cite:Bikker2013>")[2013];）描述了 #emph[Brigade];，它针对路径追踪游戏，在 CPU 和 GPU 之间平衡工作，并调整工作负载以保持所需的帧率。
]


#parec[
  == Ray-Tracing Hardware <ray-tracing-hardware> While all the stages of ray-tracing calculations—construction of the acceleration hierarchy, traversal of the hierarchy, and ray–primitive intersections, as well as shading, lighting, and integration calculations—can be implemented in software on GPUs, there has long been interest in designing specialized hardware for ray–primitive intersection tests and construction and traversal of the acceleration hierarchy for better performance. Deng et al.'s survey article has thorough coverage of hardware acceleration of ray tracing through 2017 (#link("<cite:Deng2017>")[Deng et al.~2017];); here, we will focus on early work and more recent developments.
][
  == 光线追踪硬件 <光线追踪硬件> 虽然光线追踪计算的所有阶段——加速结构层次的构建、层次结构的遍历、光线与图元的相交，以及着色、照明和集成计算——都可以在GPU上通过软件实现，但长期以来，人们一直对设计专门的硬件以进行光线与图元的相交测试以及加速结构层次的构建和遍历以提高性能感兴趣。Deng等人的综述文章对截至2017年的光线追踪硬件加速进行了全面的覆盖（#link("<cite:Deng2017>")[Deng et al.~2017];）；在这里，我们将重点关注早期工作和最近的发展。
]

#parec[
  Early published work in this area includes a paper by Woop et al.~(#link("<cite:Woop2005>")[2005];), who described the design of a "ray processing unit" (RPU). Aila and Karras (#link("<cite:Aila2010>")[2010];) described general architectural issues related to handling incoherent rays, as are common with global illumination algorithms. More recently, Shkurko et al.~(#link("<cite:Shkurko2017>")[2017];) and Vasiou et al.~(#link("<cite:Vasiou2019>")[2019];) have described a hardware architecture that is based on reordering ray intersection computation so that it exhibits predictable streaming memory accesses.
][
  该领域早期发表的工作包括Woop等人（#link("<cite:Woop2005>")[2005];）的一篇论文，他们描述了一种“光线处理器”（RPU）的设计。Aila和Karras（#link("<cite:Aila2010>")[2010];）描述了与处理不相干光线相关的一般架构问题，这在全局光照算法中很常见。最近，Shkurko等人（#link("<cite:Shkurko2017>")[2017];）和Vasiou等人（#link("<cite:Vasiou2019>")[2019];）描述了一种基于重新排序光线相交计算以实现可预测的流式内存访问的硬件架构。
]

#parec[
  Doyle et al.~(#link("<cite:Doyle2013>")[2013];) did early work on SAH BVH construction using specialized hardware. Viitanen et al.~(#link("<cite:Viitanen2017>")[2017];, #link("<cite:Viitanen2018>")[2018];) have done additional work in this area, designing architectures for efficient HLBVH construction for animated scenes and for high-quality SAH-based BVH construction.
][
  Doyle等人（#link("<cite:Doyle2013>")[2013];）在SAH BVH构建的早期工作中使用了专用硬件。Viitanen等人（#link("<cite:Viitanen2017>")[2017];, #link("<cite:Viitanen2018>")[2018];）在这一领域进行了更多工作，设计了用于动画场景的高效HLBVH构建架构，以及基于SAH的高质量BVH构建架构。
]

#parec[
  Imagination Technologies announced a mobile GPU that would use a ray-tracing architecture from Caustic (McCombe #link("<cite:McCombe2013>")[2013];), though it never shipped in volume. The NVIDIA Turing architecture (#link("<cite:NVIDIA2018>")[NVIDIA 2018];) is the first GPU with hardware-accelerated ray tracing that has seen widespread adoption. The details of its ray-tracing hardware architecture are not publicly documented, though Sanzharov et al.~(#link("<cite:Sanzharov2020>")[2020];) have applied targeted benchmarks to measure its performance characteristics in order to develop hypotheses about its implementation.
][
  Imagination Technologies宣布了一款将使用Caustic公司开发的光线追踪架构的移动GPU（McCombe #link("<cite:McCombe2013>")[2013];），尽管它从未大规模出货。NVIDIA Turing架构（#link("<cite:NVIDIA2018>")[NVIDIA 2018];）是第一个具有硬件加速光线追踪功能并被广泛采用的GPU。其光线追踪硬件架构的细节尚未公开记录，然而Sanzharov等人（#link("<cite:Sanzharov2020>")[2020];）通过应用专门设计的基准测试来测量其性能特征，以便对其实现进行假设。
]


