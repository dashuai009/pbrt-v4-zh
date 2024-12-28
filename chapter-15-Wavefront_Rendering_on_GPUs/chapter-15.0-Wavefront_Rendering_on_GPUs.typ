#import "../template.typ": parec, ez_caption

= Wavefront Rendering on GPUs #emoji.warning
<wavefront-rendering-on-gpus>

#parec[
  One of the major changes in `pbrt` for this edition of the book is the addition of support for rendering on GPUs as well as on CPUs. Between the substantial computational capabilities that GPUs offer and the recent availability of custom hardware units for efficient ray intersection calculations, the GPU is a compelling target for ray tracing. For example, the image in @fig:cpu-gpu-example-scene takes 318.6 seconds to render with `pbrt` on a 2020-era high-end GPU at $1500 times 1500$ resolution with 2048 samples per pixel. On an 8-core CPU, it takes 11,983 seconds to render with the same settings—over 37 times longer. Even on a high-end 32-core CPU, it takes 2,669 seconds to render (still over 8 times longer).#footnote[For these measurements, the GPU was an NVIDIARTX 3090.  The 8-core CPU was a 3.6GHz Intel Core i9, and the 32-core CPU was a 3.7GHz AMD Ryzen Threadripper 3970X.]
][
  本书这一版中`pbrt`的一个重大变化是增加了对在GPU和CPU上渲染的支持。鉴于GPU提供的强大计算能力以及最近出现的用于高效光线相交计算的专用硬件单元，GPU是光线追踪的理想选择。 例如，图15.1中的图像在2020年代的高端GPU上以 $1500 times 1500$ 分辨率和每像素2048个样本的设置下，用`pbrt`渲染需要318.6秒。而在8核CPU上，用相同的设置渲染需要11,983秒——长了37倍以上。即使在高端32核CPU上，渲染也需要2,669秒（仍然长了8倍以上）。#footnote[在这些测试中，GPU 使用的是 NVIDIA RTX 3090。8 核 CPU 为 3.6GHz 的 Intel Core i9，32 核 CPU 为 3.7GHz 的 AMD Ryzen Threadripper 3970X。]
]

#figure(
  image("../pbr-book-website/4ed/Wavefront_Rendering_on_GPUs/pha15f01.svg"),
  caption: [
    #ez_caption[
      Scene Used for CPU versus GPU Ray Tracing Performance Comparison. (Scene courtesy of Angelo Ferretti.)
    ][
      Scene Used for CPU versus GPU Ray Tracing Performance Comparison. (Scene courtesy of Angelo Ferretti.)
    ]
  ],
)<cpu-gpu-example-scene>

#parec[
  `pbrt`'s GPU rendering path offers only a single integration algorithm: volumetric path tracing, following the algorithms used in the CPU-based #link("Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`] described in @improved-volumetric-integrator. It otherwise supports all of `pbrt`'s functionality, using the same classes and functions that have been presented in the preceding 14 chapters. This chapter will therefore not introduce any new rendering algorithms but instead will focus on topics like parallelism and data layout in memory that are necessary to achieve good performance on GPUs.
][
  `pbrt`的GPU渲染路径仅提供单一的积分算法：体积光线追踪，遵循@improved-volumetric-integrator 中描述的基于CPU的#link("Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`];中使用的算法。 除此之外，它支持`pbrt`的所有功能，使用前14章中介绍的相同类和函数。因此，本章不会介绍任何新的渲染算法，而是将重点放在并行性和内存中的数据布局等主题上，这些对于在GPU上实现良好性能是必要的。
]

#parec[
  The integrator described in this chapter, #link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];, is structured using a #emph[wavefront] architecture—effectively, many rays are processed simultaneously, with rendering work organized in queues that collect related tasks to be processed together.
][
  本章中描述的积分器#link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];采用了_波前_架构——实际上，许多光线同时被处理，渲染工作被组织在队列中，收集相关任务以便一起处理。
]

#parec[
  Some of the code discussed in this chapter makes more extensive use of advanced C++ features than we have generally used in previous chapters. While we have tried not to use such features unnecessarily, we will see that in some cases they make it possible to generate highly specialized code that runs much more efficiently than if their capabilities are not used. We had previously sidestepped many low-level optimizations due to their comparatively small impact on CPUs. Such implementation-level decisions can, however, change rendering performance by orders of magnitude when targeting GPUs.
][
  本章讨论的一些代码比我们在前几章中通常使用的更广泛地使用了高级C++特性。虽然我们尽量不必要地使用这些特性，但我们会看到在某些情况下，它们使得生成高度优化的代码成为可能，这些代码运行效率远高于不使用这些特性的情况。 我们之前回避了许多低级优化，因为它们对CPU的影响相对较小。然而，当目标是GPU时，这种实现级别的决策可以显著改变渲染性能。
]

#parec[
  The #link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`] imposes three requirements on a GPU platform:
][
  #link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];对GPU平台提出了三个要求：
]

#parec[
  + It must support a #emph[unified address space];, where the CPU and GPU
    can both access the GPU's memory, using pointers that are consistent
    on both types of processor. This capability is integral to being able
    to parse the scene description and initialize the scene representation
    on the CPU, including initializing pointer-based data structures
    there, before the same data structures are then used in code that runs
    on the GPU.
][
  + 它必须支持统一地址空间，CPU和GPU都可以访问GPU的内存，使用在两种处理器上都一致的指针。这种能力对于能够解析场景描述并在CPU上初始化场景表示是不可或缺的，包括在那里初始化基于指针的数据结构，然后在GPU上运行的代码中使用相同的数据结构。
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + The GPU compilation infrastructure must be compatible with C++17, the language that the rest of `pbrt` is implemented in. This makes it possible to use the same class and function implementations on both types of processors.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + GPU编译基础设施必须兼容C++17，这是`pbrt`的其余部分所实现的语言。这使得在两种处理器上使用相同的类和函数实现成为可能。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + The GPU must have support for ray tracing, either in hardware or in vendor-supplied software. (`pbrt`'s existing acceleration structures would not be efficient on the GPU in their present form.)
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + GPU必须支持光线追踪，无论是在硬件中还是在厂商提供的软件中。（`pbrt`现有的加速结构在其当前形式下在GPU上效率不高。）
  ]
]

#parec[
  The attentive reader will note that CPUs themselves fulfill all of those requirements, the third potentially via `pbrt`'s acceleration structures from @primitives-and-intersection-acceleration. Therefore, `pbrt` makes it possible to execute the #link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`] on CPUs as well; it is used if the `–wavefront` command-line option is provided. However, the wavefront organization is usually not a good fit for CPUs and performance is almost always worse than if the #link("Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`] is used instead. Nonetheless, the CPU wavefront path is useful for debugging and testing the #link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`] implementation on systems that do not have suitable GPUs.
][
  细心的读者会注意到，CPU本身满足所有这些要求，第三个要求可能通过@primitives-and-intersection-acceleration 中的`pbrt`加速结构实现。 因此，`pbrt`也可以在CPU上执行#link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];；如果提供了`–wavefront`命令行选项，则使用它。 然而，波前组织通常不适合CPU，性能几乎总是比使用#link("Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`];差。 不过，CPU波前路径对于在没有合适GPU的系统上调试和测试#link("Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];实现是有用的。
]

#parec[
  At this writing, the only GPUs that provide all three of these capabilities are based on NVIDIA's CUDA platform, so NVIDIA's GPUs are the only ones that `pbrt` currently supports. We hope that it will be possible to support others in the future. Around two thousand lines of platform-specific code are required to handle low-level details like allocating unified memory, launching work on the GPU, and performing ray intersections on the GPU. As usual, we will not include platform-specific code in the book, but see the #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/gpu/")[`gpu/`] directory in the `pbrt` source code distribution for its implementation.
][
  在撰写本文时，唯一提供所有这三种能力的GPU是基于NVIDIA的CUDA平台，因此NVIDIA的GPU是`pbrt`目前唯一支持的。 我们希望将来能够支持其他平台。大约需要两千行平台特定代码来处理低级细节，如分配统一内存、在GPU上执行任务以及在GPU上执行光线相交。 像往常一样，我们不会在书中包含平台特定代码，但请参见`pbrt`源代码分发中的#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/gpu/")[`gpu/`];目录以获取其实现。
]
