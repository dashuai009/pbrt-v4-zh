#import "../template.typ": parec, ez_caption, fake-par

== #ez_caption[pbrt: System Overview][pbrt：系统概述]
<pbrt-system-overview>

#parec[
  `pbrt` is structured using standard object-oriented techniques: for each of a number of fundamental types, the system specifies an interface that implementations of that type must fulfill. For example, `pbrt` requires the implementation of a particular shape that represents geometry in a scene to provide a set of methods including one that returns the shape's bounding box, and another that tests for intersection with a given ray. In turn, the majority of the system can be implemented purely in terms of those interfaces; for example, the code that checks for occluding objects between a light source and a point being shaded calls the shape intersection methods without needing to consider which particular types of shapes are present in the scene.
][
  `pbrt` 采用标准的面向对象技术组织：对于若干基本类型，系统分别规定其实现必须满足的接口。例如，表示场景几何体的形状实现必须提供一组方法，包括返回形状包围盒的方法，以及测试形状与给定射线是否相交的方法。这样，系统的大部分功能就能完全基于这些接口实现。例如，检查光源与待着色点之间有无遮挡物的代码，只需调用形状求交方法，而不必考虑场景中具体有哪些形状类型。
]

#block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (22%, 58%, 20%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          table.header([#ez_caption[Base type][基本类型]], [#ez_caption[Source Files][源文件]], [#ez_caption[Section][章节]]),
          table.hline(stroke: .5pt),
          [#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/spectrum.h")[`base/spectrum.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.h")[`util/spectrum.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.cpp")[`util/spectrum.cpp`]], [#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#sec:spectrum")[4.5]],
          [#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/camera.h")[`base/camera.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cameras.h")[`cameras.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cameras.cpp")[`cameras.cpp`]], [#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#sec:camera-model")[5.1]],
          [#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/shape.h")[`base/shape.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[`shapes.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[`shapes.cpp`]], [#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#sec:shape-interface")[6.1]],
          [#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[`Primitive`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.h")[`cpu/primitive.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.cpp")[`cpu/primitive.cpp`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/accelerators.h")[`cpu/accelerators.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/accelerators.cpp")[`cpu/accelerators.cpp`]], [#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#sec:primitives")[7.1]],
          [#link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/sampler.h")[`base/sampler.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/samplers.h")[`samplers.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/samplers.cpp")[`samplers.cpp`]], [#link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#sec:sampling-interface")[8.3]],
          [#link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Image_Reconstruction.html#Filter")[`Filter`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/filter.h")[`base/filter.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/filters.h")[`filters.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/filters.cpp")[`filters.cpp`]], [#link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Image_Reconstruction.html#sec:filter-interface")[8.8.1]],
          [#link("https://pbr-book.org/4ed/Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/bxdf.h")[`base/bxdf.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/bxdfs.h")[`bxdfs.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/bxdfs.cpp")[`bxdfs.cpp`]], [#link("https://pbr-book.org/4ed/Reflection_Models/BSDF_Representation.html#sec:bxdf-interface")[9.1.2]],
          [#link("https://pbr-book.org/4ed/Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[`Material`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/material.h")[`base/material.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.h")[`materials.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.cpp")[`materials.cpp`]], [#link("https://pbr-book.org/4ed/Textures_and_Materials/Material_Interface_and_Implementations.html#sec:material-interface")[10.5]],
          [#link("https://pbr-book.org/4ed/Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[`FloatTexture`]], [], [],
          [#link("https://pbr-book.org/4ed/Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[`SpectrumTexture`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[`base/texture.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.h")[`textures.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.cpp")[`textures.cpp`]], [#link("https://pbr-book.org/4ed/Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#sec:texture-interface")[10.3]],
          [#link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#Medium")[`Medium`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/medium.h")[`base/medium.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.h")[`media.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.cpp")[`media.cpp`]], [#link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#sec:media")[11.4]],
          [#link("https://pbr-book.org/4ed/Light_Sources/Light_Interface.html#Light")[`Light`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/light.h")[`base/light.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.h")[`lights.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.cpp")[`lights.cpp`]], [#link("https://pbr-book.org/4ed/Light_Sources/Light_Interface.html#sec:light")[12.1]],
          [#link("https://pbr-book.org/4ed/Light_Sources/Light_Sampling.html#LightSampler")[`LightSampler`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/lightsampler.h")[`base/lightsampler.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.h")[`lightsamplers.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.cpp")[`lightsamplers.cpp`]], [#link("https://pbr-book.org/4ed/Light_Sources/Light_Sampling.html#sec:light-sampling")[12.6]],
          [#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Integrator")[`Integrator`]], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrators.h")[`cpu/integrators.h`],
            #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrators.cpp")[`cpu/integrators.cpp`]], [#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#sec:integrator-intro")[1.3.3]],
          table.hline(stroke: 0pt),
        )],
      kind: table,
      caption: [
        #ez_caption[Main Interface Types. Most of `pbrt` is implemented in terms of 14 key base types, listed here. Implementations of each of these can easily be added to the system to extend its functionality.][主要接口类型。`pbrt` 的大部分功能基于此处列出的 14 种关键基本类型实现。为任意一种类型添加新的实现，都能方便地扩展系统功能。]
      ],
    )<plug-in-types>
  ]

#fake-par

#parec[
  There are a total of 14 of these key base types, summarized in @tbl:plug-in-types . Adding a new implementation of one of these types to the system is straightforward; the implementation must provide the required methods, it must be compiled and linked into the executable, and the scene object creation routines must be modified to create instances of the object as needed as the scene description file is parsed. Section #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[C.4] discusses extending the system in more detail.
][
  这些关键基本类型共有 14 种，汇总于 @tbl:plug-in-types。向系统加入某种类型的新实现很直接：提供所需方法，将实现编译并链接到可执行文件中，再修改场景对象的创建过程，使其在解析场景描述文件时按需创建该对象的实例。#link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[第 C.4 节] 将详细讨论如何扩展系统。
]

#parec[
  Conventional practice in C++ would be to specify the interfaces for each of these types using abstract base classes that define pure virtual functions and to have implementations inherit from those base classes and implement the required virtual functions. In turn, the compiler would take care of generating the code that calls the appropriate method, given a pointer to any object of the base class type. That approach was used in the three previous versions of `pbrt`, but the addition of support for rendering on graphics processing units (GPUs) in this version motivated a more portable approach based on #emph[tag-based dispatch], where each specific type implementation is assigned a unique integer that determines its type at runtime.(See @dynamic-dispatch for more information about this topic.) The polymorphic types that are implemented in this way in `pbrt` are all defined in header files in the #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/")[`base/`] directory.
][
  C++ 的常规做法，是用声明纯虚函数的抽象基类规定各类型的接口，让具体实现继承这些基类并实现所需虚函数。给定指向任意派生对象的基类指针，编译器会负责生成调用适当方法的代码。`pbrt` 的前三版采用了这种方式；本版增加 GPU 渲染支持后，转而采用可移植性更好的_基于标签的分派_：为每种具体类型的实现分配唯一整数，用于在运行时确定类型。（详见 @dynamic-dispatch。）`pbrt` 中以这种方式实现的多态类型，都定义在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/")[`base/`] 目录的头文件中。
]

#parec[
  This version of `pbrt` is capable of running on GPUs that support C++17 and provide APIs for ray intersection tests. #footnote[At the time of writing, these capabilities are only available on NVIDIA hardware, but it would not be too difficult to port `pbrt` to other architectures that provide them in the future.] We have carefully designed the system so that almost all of `pbrt`'s implementation runs on both CPUs and GPUs, just as it is presented in @monte-carlo-integration through @light-sources. We will therefore generally say little about the CPU versus the GPU in most of the following.
][
  这一版 `pbrt` 能在支持 C++17 并提供射线求交 API 的 GPU 上运行。#footnote[本书撰写时，只有 NVIDIA 硬件具备这些能力；但未来若其他架构也提供这些能力，将 `pbrt` 移植过去并不会太困难。] 我们精心设计了系统，使 @monte-carlo-integration 至 @light-sources 所介绍的几乎全部实现都能在 CPU 和 GPU 上运行。因此，后续大部分内容通常不会特意讨论 CPU 与 GPU 的差异。
]



#parec[
  The main differences between the CPU and GPU rendering paths in `pbrt` are in their data flow and how they are parallelized—effectively, how the pieces are connected together. Both the basic rendering algorithm described later in this chapter and the light transport algorithms described in @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering are only available on the CPU. The GPU rendering pipeline is discussed in @wavefront-rendering-on-gpus, though it, too, is also capable of running on the CPU (not as efficiently as the CPU-targeted light transport algorithms, however).
][
  `pbrt` 的 CPU 与 GPU 渲染路径主要在数据流和并行化方式上不同，也就是各个部分如何衔接。本章稍后介绍的基本渲染算法，以及 @light-transport-i-surface-reflection 和 @light-transport-ii-volume-rendering 中的光传输算法，都只能在 CPU 上运行。@wavefront-rendering-on-gpus 将讨论 GPU 渲染流水线；它也能在 CPU 上运行，不过效率不及专为 CPU 设计的光传输算法。
]

#parec[
  While `pbrt` can render many scenes well with its current implementation, it has frequently been extended by students, researchers, and developers. Throughout this section are a number of notable images from those efforts. @fig:competition-snow, @fig:ice-cave, and @fig:cotton-candy were each created by students in a rendering course where the final class project was to extend `pbrt` with new functionality in order to render an image that it could not have rendered before. These images are among the best from that course.
][
  虽然 `pbrt` 的现有实现已能很好地渲染许多场景，学生、研究人员和开发者仍经常对其加以扩展。本节展示了这些工作产生的多幅出色图像。@fig:competition-snow、@fig:ice-cave 和 @fig:cotton-candy 都出自一门渲染课程的学生之手。该课程的期末项目要求为 `pbrt` 增添新功能，渲染它此前无法生成的图像；这些图像是其中的优秀作品。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/nightsnow.png"),
  caption: [
    #ez_caption[
      Guillaume Poncin and Pramod Sharma extended `pbrt` in numerous ways, implementing a number of complex rendering algorithms, to make this prize-winning image for Stanford's CS348b rendering competition. The trees are modeled procedurally with L-systems, a glow image processing filter increases the apparent realism of the lights on the tree, snow was modeled procedurally with metaballs, and a subsurface scattering algorithm gave the snow its realistic appearance by accounting for the effect of light that travels beneath the snow for some distance before leaving it.
    ][
      Guillaume Poncin 和 Pramod Sharma 多方扩展 `pbrt`，实现多种复杂渲染算法，创作了这幅在斯坦福大学 CS348b 渲染比赛中获奖的图像。树木用 L 系统程序化建模，光晕图像滤镜使树上的灯光显得更真实，积雪用元球程序化建模；次表面散射算法考虑了光在雪下传播一段距离再离开的效果，使雪的外观逼真。
    ]
  ],
) <competition-snow>

#figure(
  image("../pbr-book-website/4ed/Introduction/icecave.png"),
  caption: [
    #ez_caption[
      Abe Davis, David Jacobs, and Jongmin Baek rendered this amazing image of an ice cave to take the grand prize in the 2009 Stanford CS348b rendering competition. They first implemented a
      simulation of the physical process of glaciation, the process where snow falls, melts, and refreezes over the course of many years, forming stratified layers of ice. They then simulated erosion of the ice due to melted water runoff before generating a geometric model of the ice. Scattering of light inside the volume was simulated with volumetric photon mapping; the blue color of the ice is entirely due to modeling the wavelength-dependent absorption of light in the ice volume.
    ][
      Abe Davis、David Jacobs 和 Jongmin Baek 渲染了这张令人惊叹的冰洞图像，并获得了 2009 年斯坦福大学 CS348b 渲染比赛的大奖。他们首先实现了冰川形成的物理过程模拟，即多年间雪的降落、融化和再冻结过程，形成了分层的冰层。随后，他们模拟了融化的水流对冰的侵蚀，生成了冰的几何模型。通过体积光子映射模拟了光线在冰体内部的散射效果；冰的蓝色完全是由于对光在冰体内部随波长变化的吸收进行建模而得出的。
    ]
  ],
) <ice-cave>

#figure(
  image("../pbr-book-website/4ed/Introduction/cotton_candy.png"),
  caption: [
    #ez_caption[
      Chenlin Meng, Hubert Teo, and Jiren Zhu rendered this tasty-looking image of cotton candy in a teacup to win the grand prize in the 2018 Stanford CS348b rendering competition. They modeled the cotton candy with multiple layers of curves and then filled the center with a participating medium to efficiently model scattering in its interior.
    ][
      Chenlin Meng、Hubert Teo 和 Jiren Zhu 渲染了这幅茶杯中盛着诱人棉花糖的图像，赢得 2018 年斯坦福大学 CS348b 渲染比赛大奖。他们用多层曲线为棉花糖建模，再在中心填入参与介质，高效模拟内部散射。
    ]
  ],
) <cotton-candy>

#figure(
  image("../pbr-book-website/4ed/Introduction/crown.png"),
  caption: [
    #ez_caption[
      Martin Lubich modeled this scene of the Austrian Imperial Crown using Blender; it was originally rendered using LuxRender, which started out as a fork of the `pbrt-v1` codebase. The crown consists of approximately 3.5 million triangles that are illuminated by six area light sources with emission spectra based on measured data from a real-world light source. It was originally rendered with 1280 samples per pixel in 73 hours of computation on a quad-core CPU. On a modern GPU, `pbrt` renders this scene at the same sampling rate in 184 seconds.
    ][
      Martin Lubich 用 Blender 为奥地利帝国皇冠场景建模，最初用 LuxRender 渲染；该渲染器起源于 `pbrt-v1` 代码库的一个分支。皇冠由约 350 万个三角形组成，由六个面光源照明，其发射光谱基于真实光源的实测数据。最初在四核 CPU 上以每像素 1280 个样本渲染，耗时 73 小时；在现代 GPU 上，`pbrt` 以相同采样率渲染只需 184 秒。
    ]
  ],
) <crown>

=== #ez_caption[Phases of Execution][执行阶段]
<phases-of-execution>

#parec[
  `pbrt` can be conceptually divided into three phases of execution. First, it parses the scene description file provided by the user. The scene description is a text file that specifies the geometric shapes that make up the scene, their material properties, the lights that illuminate them, where the virtual camera is positioned in the scene, and parameters to all the individual algorithms used throughout the system. The scene file format is documented on the `pbrt` website, #link("https://pbrt.org")[pbrt.org].
][
  从概念上看，`pbrt` 的执行分为三个阶段。首先，解析用户提供的场景描述文件。这是一份文本文件，指定构成场景的几何形状、材质属性、照明光源、虚拟相机的位置，以及系统各算法的参数。场景文件格式的文档见 `pbrt` 网站 #link("https://pbrt.org")[pbrt.org]。
]

#parec[
  The result of the parsing phase is an instance of the #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] class, which stores the scene specification, but not in a form yet suitable for rendering. In the second phase of execution, `pbrt` creates specific objects corresponding to the scene; for example, if a perspective projection has been specified, it is in this phase that a #link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#PerspectiveCamera")[`PerspectiveCamera`] object corresponding to the specified viewing parameters is created. Previous versions of `pbrt` intermixed these first two phases, but for this version we have separated them because the CPU and GPU rendering paths differ in some of the ways that they represent the scene in memory.
][
  解析阶段产生一个 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] 实例，用来存储场景的定义，但其形式尚不适合渲染。第二阶段中，`pbrt` 创建场景对应的具体对象。例如，如果指定了透视投影，就在此时按给定观察参数创建 #link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#PerspectiveCamera")[`PerspectiveCamera`] 对象。以往版本将这两个阶段交织在一起；本版将它们分开，是因为 CPU 与 GPU 渲染路径在场景的内存表示上有所不同。
]

#parec[
  In the third phase, the main rendering loop executes. This phase is where `pbrt` usually spends the majority of its running time, and most of this book is devoted to code that executes during this phase. To orchestrate the rendering, `pbrt` implements an #emph[integrator], so-named because its main task is to evaluate the integral in @eqt:rendering-equation.
][
  第三阶段执行主渲染循环。`pbrt` 通常将大部分运行时间花在这里，本书的大部分篇幅也用于介绍此阶段执行的代码。为组织渲染，`pbrt` 实现了_积分器_，得名于其主要任务：计算 @eqt:rendering-equation 中的积分。
]


=== #ez_caption[pbrt's main() Function][pbrt 的 main() 函数]


#parec[
  The `main()` function for the `pbrt` executable is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cmd/pbrt.cpp")[`cmd/pbrt.cpp`] in the directory that holds the `pbrt` source code, `src/pbrt` in the `pbrt` distribution. It is only a hundred and fifty or so lines of code, much of it devoted to processing command-line arguments and related bookkeeping.
][
  `pbrt` 可执行程序的 `main()` 函数定义在源代码目录中的 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cmd/pbrt.cpp")[`cmd/pbrt.cpp`] 文件里；该目录位于发行版的 `src/pbrt`。函数只有约 150 行代码，大部分用于处理命令行参数及相关管理工作。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-mainprogram-0")[#raw("<<main program>>=")]]
#block(breakable: false)[
```cpp
int main(int argc, char *argv[]) {
    <<Convert command-line arguments to vector of strings>>
    <<Declare variables for parsed command line>>
    <<Process command-line arguments>>
    <<Initialize pbrt>>
    <<Parse provided scene description files>>
    <<Render the scene>>
    <<Clean up after rendering the scene>>
}
```
]

#parec[
  Rather than operate on the `argv` values provided to the `main()` function directly, `pbrt` converts the provided arguments to a vector of `std::string`s. It does so not only for the greater convenience of the `string` class, but also to support non-ASCII character sets. Section #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#sec:character-encoding")[B.3.2] has more information about character encodings and how they are handled in `pbrt`.
][
  `pbrt` 不直接操作传给 `main()` 的 `argv`，而是将参数转换为存储 `std::string` 的向量。这既是为了利用字符串类的便利，也为了支持非 ASCII 字符集。关于字符编码及 `pbrt` 的处理方式，详见 #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#sec:character-encoding")[第 B.3.2 节]。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Convertcommand-lineargumentstovectorofstrings-0")[#raw("<<Convert command-line arguments to vector of strings>>=")]]
#block(breakable: false)[
```cpp
std::vector<std::string> args = GetCommandLineArguments(argv);
```
]

#parec[
  We will only include the definitions of some of the main function's fragments in the book text here. Some, such as the one that handles parsing command-line arguments provided by the user, are both simple enough and long enough that they are not worth the few pages that they would add to the book's length. However, we will include the fragment that declares the variables in which the option values are stored.
][
  这里仅列出 `main()` 部分代码片段的定义。有些片段，例如解析用户命令行参数的部分，内容简单却篇幅较长，不值得为此增加数页正文。不过，我们会列出声明选项值存储变量的代码片段。
]
#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Declarevariablesforparsedcommandline-0")[#raw("<<Declare variables for parsed command line>>=")]]
#block(breakable: false)[
```cpp
PBRTOptions options;
std::vector<std::string> filenames;
```
]

#parec[
  The #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#GetCommandLineArguments")[`GetCommandLineArguments()`] function and #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] type appear in a #emph[mini-index] in the page margin, along with the number of the page where they are defined. The `mini-indices` have pointers to the definitions of almost all the functions, classes, methods, and member variables used or referred to on each page.(In the interests of brevity, we will omit very widely used classes such as `Ray` from the mini-indices, as well as types or methods that were just introduced in the preceding few pages.)
][
  #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#GetCommandLineArguments")[`GetCommandLineArguments()`] 函数和 #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] 类型出现在页边的_小索引_中，并附有其定义所在页码。小索引指向每页使用或提及的几乎所有函数、类、方法和成员变量的定义。（为简洁起见，会省略 `Ray` 等使用极为广泛的类，以及前几页刚刚介绍过的类型或方法。）
]

#parec[
  The #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] class stores various rendering options that are generally more suited to be specified on the command line rather than in scene description files—for example, how chatty `pbrt` should be about its progress during rendering. It is passed to the #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`] function, which aggregates the various system-wide initialization tasks that must be performed before any other work is done. For example, it initializes the logging system and launches a group of threads that are used for the parallelization of `pbrt`.
][
  #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] 存储各种通常更适合通过命令行而非场景文件指定的渲染选项，例如 `pbrt` 在渲染过程中应报告多详细的进度信息。它被传给 #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`]，后者汇集了开始其他工作前必须完成的系统初始化任务，例如初始化日志系统，启动用于并行执行的一组线程。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Initializepbrt-0")[#raw("<<Initialize pbrt>>=")]]
#block(breakable: false)[
```cpp
InitPBRT(options);
```
]


#parec[
  After the arguments have been parsed and validated, the #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParseFiles")[`ParseFiles()`] function takes over to handle the first of the three phases of execution described earlier. With the assistance of two classes, #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Managing_the_Scene_Description.html#BasicSceneBuilder")[`BasicSceneBuilder`] and #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`], which are respectively described in Sections #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Managing_the_Scene_Description.html#sec:basic-scene-builder")[C.2] and #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#sec:basic-scene")[C.3], it loops over the provided filenames, parsing each file in turn. If `pbrt` is run with no filenames provided, it looks for the scene description from standard input. The mechanics of tokenizing and parsing scene description files will not be described in this book, but the parser implementation can be found in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[`parser.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[`parser.cpp`] in the `src/pbrt` directory.
][
  命令行参数解析并验证后，#link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParseFiles")[`ParseFiles()`] 接手执行前述三个阶段中的第一阶段。在 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Managing_the_Scene_Description.html#BasicSceneBuilder")[`BasicSceneBuilder`] 和 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] 的协助下，它遍历给定文件名，依次解析各文件；这两个类分别在 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Managing_the_Scene_Description.html#sec:basic-scene-builder")[第 C.2 节] 和 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#sec:basic-scene")[第 C.3 节] 介绍。如果运行 `pbrt` 时未提供文件名，就从标准输入读取场景描述。本书不介绍场景文件的词法分析与解析机制，解析器实现可在 `src/pbrt` 目录下的 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[`parser.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[`parser.cpp`] 中找到。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Parseprovidedscenedescriptionfiles-0")[#raw("<<Parse provided scene description files>>=")]]
#block(breakable: false)[
```cpp
BasicScene scene;
BasicSceneBuilder builder(&scene);
ParseFiles(&builder, filenames);
```
]


#parec[
  After the scene description has been parsed, one of two functions is called to render the scene. #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`] supports both the CPU and GPU rendering paths, processing a million or so image samples in parallel. It is the topic of @wavefront-rendering-on-gpus . `RenderCPU()` renders the scene using an #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Integrator")[`Integrator`] implementation and is only available when running on the CPU. It uses much less parallelism than #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`], rendering only as many image samples as there are CPU threads in parallel.
][
  场景描述解析完毕后，将调用两个函数之一进行渲染。#link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`] 同时支持 CPU 和 GPU 渲染路径，可并行处理约一百万个图像样本；@wavefront-rendering-on-gpus 将介绍它。`RenderCPU()` 则利用 #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Integrator")[`Integrator`] 的实现渲染场景，只能在 CPU 上运行。其并行程度远低于 #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`]：同时处理的图像样本数只与 CPU 线程数相同。
]

#parec[
  Both of these functions start by converting the #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] into a form suitable for efficient rendering and then pass control to a processor-specific integrator.(More information about this process is available in Section #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#sec:basic-scene")[C.3].) We will for now gloss past the details of this transformation in order to focus on the main rendering loop in `RenderCPU()`, which is much more interesting. For that, we will take the efficient scene representation as a given.
][
  这两个函数都先将 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] 转换为适合高效渲染的形式，再把控制权交给针对相应处理器的积分器。（详见 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#sec:basic-scene")[第 C.3 节]。）这里暂且略过转换细节，专注于更有趣的 `RenderCPU()` 主渲染循环；为此，假定已经获得高效的场景表示。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Renderthescene-0")[#raw("<<Render the scene>>=")]]
#block(breakable: false)[
```cpp
if (Options->useGPU || Options->wavefront)
    RenderWavefront(scene);
else
    RenderCPU(scene);
```
]


#parec[
  After the image has been rendered, #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#CleanupPBRT")[`CleanupPBRT()`] takes care of shutting the system down gracefully, including, for example, terminating the threads launched by #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`].
][
  图像渲染完成后，#link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#CleanupPBRT")[`CleanupPBRT()`] 负责有序关闭系统，例如终止 #link("https://pbr-book.org/4ed/Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`] 启动的线程。
]


#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Cleanupafterrenderingthescene-0")[#raw("<<Clean up after rendering the scene>>=")]]
#block(breakable: false)[
```cpp
CleanupPBRT();
```
]

=== #ez_caption[Integrator Interface][积分器接口]
<integrator-interface>
#parec[
  In the `RenderCPU()` rendering path, an instance of a class that implements the `Integrator` interface is responsible for rendering. Because `Integrator` implementations only run on the CPU, we will define `Integrator` as a standard base class with pure virtual methods. `Integrator` and the various implementations are each defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.h")[`cpu/integrator.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`].
][
  在 `RenderCPU()` 渲染路径中，实现 `Integrator` 接口的类实例负责渲染。由于这些实现只在 CPU 上运行，我们将 `Integrator` 定义为带纯虚方法的标准基类。`Integrator` 及其各种实现定义在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.h")[`cpu/integrator.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`] 中。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorDefinition-0")[#raw("<<Integrator Definition>>=")]]
```cpp
class Integrator {
  public:
    // Integrator Public Methods
    virtual ~Integrator();

    static std::unique_ptr<Integrator> Create(const std::string &name,
                                              const ParameterDictionary &parameters,
                                              Camera camera, Sampler sampler,
                                              Primitive aggregate,
                                              std::vector<Light> lights,
                                              const RGBColorSpace *colorSpace,
                                              const FileLoc *loc);

    virtual std::string ToString() const = 0;
    virtual void Render() = 0;
    pstd::optional<ShapeIntersection> Intersect(const Ray &ray,
                                                Float tMax = Infinity) const;
    bool IntersectP(const Ray &ray, Float tMax = Infinity) const;
    bool Unoccluded(const Interaction &p0, const Interaction &p1) const {
        return !IntersectP(p0.SpawnRayTo(p1), 1 - ShadowEpsilon);
    }
    SampledSpectrum Tr(const Interaction &p0, const Interaction &p1,
                       const SampledWavelengths &lambda) const;

    // Integrator Public Members
    Primitive aggregate;
    std::vector<Light> lights;
    std::vector<Light> infiniteLights;

  protected:
    // Integrator Protected Methods
    Integrator(Primitive aggregate, std::vector<Light> lights)
        : aggregate(aggregate), lights(lights) {
        // Integrator constructor implementation
        Bounds3f sceneBounds = aggregate ? aggregate.Bounds() : Bounds3f();
        for (auto &light : lights) {
            light.Preprocess(sceneBounds);
            if (light.Type() == LightType::Infinite)
                infiniteLights.push_back(light);
        }
    }
};
```

#parec[
  The base `Integrator` constructor takes a single `Primitive` that represents all the geometric objects in the scene as well as an array that holds all the lights in the scene.
][
  `Integrator` 基类的构造函数接收一个表示场景全部几何物体的 `Primitive`，以及一个包含全部光源的数组。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorProtectedMethods-0")[#raw("<<Integrator Protected Methods>>=")]]
#block(breakable: false)[
```cpp
Integrator(Primitive aggregate, std::vector<Light> lights)
    : aggregate(aggregate), lights(lights) {
    // <<Integrator constructor implementation>>
    Bounds3f sceneBounds = aggregate ? aggregate.Bounds() : Bounds3f();
    for (auto &light : lights) {
        light.Preprocess(sceneBounds);
        if (light.Type() == LightType::Infinite)
            infiniteLights.push_back(light);
    }
}
```
]


#parec[
  Each geometric object in the scene is represented by a `Primitive`, which is primarily responsible for combining a `Shape` that specifies its geometry and a `Material` that describes its appearance (e.g., the object's color, or whether it has a dull or glossy finish). In turn, all the geometric primitives in a scene are collected into a single aggregate primitive that is stored in the `Integrator::aggregate` member variable. This aggregate is a special kind of primitive that itself holds references to many other primitives. The aggregate implementation stores all the scene's primitives in an acceleration data structure that reduces the number of unnecessary ray intersection tests with primitives that are far away from a given ray. Because it implements the `Primitive` interface, it appears no different from a single primitive to the rest of the system.
][
  场景中的每个几何物体由一个 `Primitive` 表示，其主要职责是将指定几何形状的 `Shape` 与描述外观的 `Material` 组合起来，例如物体的颜色，以及表面是哑光还是光泽的。场景中的全部几何图元又汇集为一个聚合图元，存储在 `Integrator::aggregate` 中。这是一种持有其他许多图元引用的特殊图元。其实现用加速数据结构存储场景图元，减少对远离给定射线的图元所做的不必要求交测试。由于聚合图元也实现了 `Primitive` 接口，对系统其余部分而言，它与单个图元没有区别。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorPublicMembers-0")[#raw("<<Integrator Public Members>>=")]]
#block(breakable: false)[
```cpp
Primitive aggregate;
std::vector<Light> lights;
```
]


#parec[
  Each light source in the scene is represented by an object that implements the `Light` interface, which allows the light to specify its shape and the distribution of energy that it emits. Some lights need to know the bounding box of the entire scene, which is unavailable when they are first created. Therefore, the `Integrator` constructor calls their `Preprocess()` methods, providing those bounds. At this point any "infinite" lights are also stored in a separate array. This sort of light, which will be introduced in Section 12.5, models infinitely far away sources of light, which is a reasonable model for skylight as received on Earth's surface, for example. Sometimes it will be necessary to loop over just those lights, and for scenes with thousands of light sources it would be inefficient to loop over all of them just to find those.
][
  每个光源都由实现 `Light` 接口的对象表示，以指定形状及所发出能量的分布。一些光源需要整个场景的包围盒，但创建光源时这一信息尚不可得。因此，`Integrator` 构造函数会调用它们的 `Preprocess()` 方法并传入包围盒。此时还会将所有“无限光源”存入单独数组。这类光源将在 #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#sec:infinite-area-lights")[第 12.5 节] 介绍，用于模拟无限远处的光源，例如地表接收到的天光就可合理地用它建模。有时需要只遍历这些光源；对于有数千个光源的场景，为寻找它们而遍历所有光源会很低效。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Integratorconstructorimplementation-0")[#raw("<<Integrator constructor implementation>>=")]]
#block(breakable: false)[
```cpp
Bounds3f sceneBounds = aggregate ? aggregate.Bounds() : Bounds3f();
for (auto &light : lights) {
    light.Preprocess(sceneBounds);
    if (light.Type() == LightType::Infinite)
        infiniteLights.push_back(light);
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorPublicMembers-1")[#raw("<<Integrator Public Members>>+=")]]
#block(breakable: false)[
```cpp
std::vector<Light> infiniteLights;
```
]


#parec[
  `Integrator`s must provide an implementation of the `Render()` method, which takes no further arguments. This method is called by the `RenderCPU()` function once the scene representation has been initialized. The task of integrators is to render the scene as specified by the aggregate and the lights. Beyond that, it is up to the specific integrator to define what it means to render the scene, using whichever other classes that it needs to do so (e.g., a camera model). This interface is intentionally very general to permit a wide range of implementations—for example, one could implement an `Integrator` that measures light only at a sparse set of points distributed through the scene rather than generating a regular 2D image.
][
  `Integrator` 必须实现无需额外参数的 `Render()` 方法。场景表示初始化后，`RenderCPU()` 就会调用它。积分器的任务，是渲染由聚合图元和光源所描述的场景。除此以外，“渲染场景”具体意味着什么，由各积分器自行决定，并可按需使用其他类，例如相机模型。这个接口有意设计得十分通用，以容纳广泛的实现。例如，可以实现一个仅在场景内稀疏分布的一组点上测量光的积分器，而不生成规则的二维图像。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorPublicMethods-0")[#raw("<<Integrator Public Methods>>=")]]
#block(breakable: false)[
```cpp
virtual void Render() = 0;
```
]

#parec[
  The `Integrator` class provides two methods related to ray–primitive intersection for use of its subclasses. `Intersect()` takes a ray and a maximum parametric distance `tMax`, traces the given ray into the scene, and returns a `ShapeIntersection` object corresponding to the closest primitive that the ray hit, if there is an intersection along the ray before `tMax`.(The `ShapeIntersection` structure is defined in @intersection-tests_chapter_6_1 .) One thing to note is that this method uses the type `pstd::optional` for the return value rather than `std::optional` from the C++ standard library; we have reimplemented parts of the standard library in the `pstd` namespace for reasons that are discussed in @pstd.
][
  `Integrator` 提供两种射线与图元求交方法供子类使用。`Intersect()` 接收射线及最大参数距离 `tMax`，在场景中追踪射线；若在 `tMax` 之前存在交点，则返回最近命中图元对应的 `ShapeIntersection` 对象。（该结构定义见 @intersection-tests_chapter_6_1。）注意，返回类型使用 `pstd::optional`，而非 C++ 标准库的 `std::optional`。我们在 `pstd` 命名空间中重新实现了部分标准库，原因见 @pstd。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorMethodDefinitions-0")[#raw("<<Integrator Method Definitions>>=")]]
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection> Integrator::Intersect(const Ray &ray, Float tMax) const {
    if (aggregate) return aggregate.Intersect(ray, tMax);
    else           return {};
}
```
]


#parec[
  Also note the capitalized floating-point type `Float` in `Intersect()`'s signature: almost all floating-point values in `pbrt` are declared as `Float`s.(The only exceptions are a few cases where a 32-bit `float` or a 64-bit `double` is specifically needed (e.g., when saving binary values to files).) Depending on the compilation flags of `pbrt`, `Float` is an alias for either `float` or `double`, though single precision `float` is almost always sufficient in practice. The definition of `Float` is in the #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] header file, which is included by all other source files in `pbrt`.
][
  还要注意 `Intersect()` 签名中首字母大写的浮点类型 `Float`：`pbrt` 几乎所有浮点值都声明为 `Float`。唯一的例外，是明确需要 32 位 `float` 或 64 位 `double` 的少数场合，例如将二进制值写入文件。根据编译选项，`Float` 可以是 `float` 或 `double` 的别名，不过实践中单精度 `float` 几乎总是足够的。`Float` 定义在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] 头文件中，其他所有源文件都会包含它。
]
#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-FloatTypeDefinitions-0")[#raw("<<Float Type Definitions>>=")]]
#block(breakable: false)[
```cpp
#ifdef PBRT_FLOAT_AS_DOUBLE
    using Float = double;
#else
    using Float = float;
#endif
```
]


#parec[
  `Integrator::IntersectP()` is closely related to the `Intersect()` method. It checks for the existence of intersections along the ray but only returns a Boolean indicating whether an intersection was found.(The "P" in its name indicates that it is a function that evaluates a predicate, using a common naming convention from the `Lisp` programming language.) Because it does not need to search for the closest intersection or return additional geometric information about intersections, `IntersectP()` is generally more efficient than `Integrator::Intersect()`. This routine is used for shadow rays.
][
  `Integrator::IntersectP()` 与 `Intersect()` 密切相关。它检查射线上是否存在交点，但只返回表示是否找到交点的布尔值。名称中的“P”沿用 Lisp 的常见命名约定，表示该函数计算一个谓词。由于无需寻找最近交点，也无需返回交点的附加几何信息，`IntersectP()` 通常比 `Integrator::Intersect()` 更高效。它用于阴影射线。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-IntegratorMethodDefinitions-1")[#raw("<<Integrator Method Definitions>>+=")]]
#block(breakable: false)[
```cpp
bool Integrator::IntersectP(const Ray &ray, Float tMax) const {
    if (aggregate) return aggregate.IntersectP(ray, tMax);
    else           return false;
}
```
]



=== #ez_caption[ImageTileIntegrator and the Main Rendering Loop][ImageTileIntegrator 与主渲染循环]
<imagetileintegrator-and-the-main-rendering-loop>

#parec[
  Before implementing a basic integrator that simulates light transport to render an image, we will define two `Integrator` subclasses that provide additional common functionality used by that integrator as well as many of the integrator implementations to come. We start with `ImageTileIntegrator`, which inherits from `Integrator`. The next section defines `RayIntegrator`, which inherits from `ImageTileIntegrator`.
][
  在实现模拟光传输、生成图像的基本积分器之前，我们先定义两个 `Integrator` 子类，为该积分器及后续许多积分器提供公共功能。首先是继承 `Integrator` 的 `ImageTileIntegrator`，下一小节再定义继承 `ImageTileIntegrator` 的 `RayIntegrator`。
]

#parec[
  All of `pbrt`'s CPU-based integrators render images using a camera model to define the viewing parameters, and all parallelize rendering by splitting the image into tiles and having different processors work on different tiles. Therefore, `pbrt` includes an `ImageTileIntegrator` that provides common functionality for those tasks.
][
  `pbrt` 的所有 CPU 积分器都使用相机模型指定观察参数，并将图像划分为图块，交由不同处理器处理不同图块，以实现并行渲染。因此，`pbrt` 提供 `ImageTileIntegrator`，集中实现这些任务所需的公共功能。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-ImageTileIntegratorDefinition-0")[#raw("<<ImageTileIntegrator Definition>>=")]]
```cpp
class ImageTileIntegrator : public Integrator {
  public:
    ImageTileIntegrator(Camera camera, Sampler sampler,
               Primitive aggregate, std::vector<Light> lights)
           : Integrator(aggregate, lights), camera(camera),
             samplerPrototype(sampler) {}
       void Render();
       virtual void EvaluatePixelSample(Point2i pPixel, int sampleIndex,
           Sampler sampler, ScratchBuffer &scratchBuffer) = 0;
  protected:
    Camera camera;
       Sampler samplerPrototype;
};
```

#parec[
  In addition to the aggregate and the lights, the `ImageTileIntegrator` constructor takes a Camera that specifies the viewing and lens parameters such as position, orientation, focus, and field of view. `Film` stored by the camera handles image storage. The `Camera` classes are the subject of most of @cameras-and-film , and `Film` is described in Section 5.4. The Film is responsible for writing the final image to a file.
][
  除了聚合图元和光源，`ImageTileIntegrator` 的构造函数还接收 `Camera`，用于指定位置、朝向、焦点、视场等观察和透镜参数。相机持有的 `Film` 负责图像存储。@cameras-and-film 的大部分内容介绍 `Camera`，@film-and-imaging 则介绍 `Film`。最终将图像写入文件，也是 `Film` 的职责。
]

#parec[
  The constructor also takes a `Sampler`; its role is more subtle, but its implementation can substantially affect the quality of the images that the system generates. First, the sampler is responsible for choosing the points on the image plane that determine which rays are initially traced into the scene. Second, it is responsible for supplying random sample values that are used by integrators for estimating the value of the light transport integral, @eqt:rendering-equation. For example, some integrators need to choose random points on light sources to compute illumination from area lights. Generating a good distribution of these samples is an important part of the rendering process that can substantially affect overall efficiency; this topic is the main focus of @sampling-and-reconstruction.
][
  构造函数还接收 `Sampler`。它的作用更为微妙，却能显著影响生成图像的质量。首先，采样器选择图像平面上的点，决定最初追踪哪些射线进入场景。其次，它向积分器提供随机样本值，用于估计光传输积分 @eqt:rendering-equation。例如，一些积分器需要随机选择面光源上的点，以计算面光源的照明。让样本具有良好分布是渲染的重要环节，能显著影响整体效率；@sampling-and-reconstruction 主要讨论这一主题。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-ImageTileIntegratorPublicMethods-0")[#raw("<<ImageTileIntegrator Public Methods>>=")]]
#block(breakable: false)[
```cpp
ImageTileIntegrator(Camera camera, Sampler sampler,
        Primitive aggregate, std::vector<Light> lights)
    : Integrator(aggregate, lights), camera(camera),
      samplerPrototype(sampler) {}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-ImageTileIntegratorProtectedMembers-0")[#raw("<<ImageTileIntegrator Protected Members>>=")]]
#block(breakable: false)[
```cpp
Camera camera;
Sampler samplerPrototype;
```
]

#parec[
  For all of `pbrt`'s integrators, the final color computed at each pixel is based on random sampling algorithms. If each pixel's final value is computed as the average of multiple samples, then the quality of the image improves. At low numbers of samples, sampling error manifests itself as grainy high-frequency noise in images, though error goes down at a predictable rate as the number of samples increases.(This topic is discussed in more depth in @error-in-monte-carlo-estimators.) `ImageTileIntegrator::Render()` therefore renders the image in waves of a few samples per pixel. For the first two waves, only a single sample is taken in each pixel. In the next wave, two samples are taken, with the number of samples doubling after each wave up to a limit. While it makes no difference to the final image if the image was rendered in waves or with all the samples being taken in a pixel before moving on to the next one, this organization of the computation means that it is possible to see previews of the final image during rendering where all pixels have some samples, rather than a few pixels having many samples and the rest having none.
][
  `pbrt` 的所有积分器都基于随机采样算法计算每个像素的最终颜色。对多个样本求平均可提高图像质量。样本较少时，采样误差表现为颗粒状的高频噪声；随着样本数增加，误差会按可预测的速率减小（详见 @error-in-monte-carlo-estimators）。因此，`ImageTileIntegrator::Render()` 分批渲染，每批在每个像素取少量样本。前两批各取一个样本，第三批取两个，之后每批样本数翻倍，直至达到上限。分批渲染与逐像素完成全部采样后再处理下一像素，所得最终图像并无不同；但分批组织计算可以在渲染过程中提供整幅图像的预览，让所有像素都有一些样本，而非少数像素样本很多、其余像素没有样本。
]


#parec[
  Because `pbrt` is parallelized to run using multiple threads, there is a balance to be struck with this approach. There is a cost for threads to acquire work for a new image tile, and some threads end up idle at the end of each wave once there is no more work for them to do but other threads are still working on the tiles they have been assigned. These considerations motivated the capped doubling approach.
][
  `pbrt` 使用多线程并行执行，因此这种方法需要权衡。线程为新图块领取任务有一定开销；每批临近结束时，一些线程已无任务可领而闲置，另一些线程却仍在处理已分配的图块。因此，我们采用每批样本数翻倍、但设有上限的方案。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-ImageTileIntegratorMethodDefinitions-0")[#raw("<<ImageTileIntegrator Method Definitions>>=")]]
#block(breakable: false)[
```cpp
void ImageTileIntegrator::Render() {
    <<Declare common variables for rendering image in tiles>>
    <<Render image in waves>>
}
```
]


#parec[
  Before rendering begins, a few additional variables are required. First, the integrator implementations will need to allocate small amounts of temporary memory to store surface scattering properties in the course of computing each ray's contribution. The large number of resulting allocations could easily overwhelm the system's regular memory allocation routines (e.g., `new`), which must coordinate multi-threaded maintenance of elaborate data structures to track free memory. A naive implementation could potentially spend a fairly large fraction of its computation time in the memory allocator.
][
  渲染开始前，还需要几个变量。首先，积分器计算每条射线的贡献时，需要分配少量临时内存，存储表面散射属性。大量这样的分配可能使常规内存分配机制（例如 `new`）难以承受，因为它们必须协调多线程对复杂数据结构的维护，以跟踪空闲内存。朴素实现可能将相当大比例的计算时间花在内存分配器中。
]


#parec[
  To address this issue, pbrt provides a `ScratchBuffer` class that manages a small preallocated buffer of memory. `ScratchBuffer` allocations are very efficient, just requiring the increment of an offset. The `ScratchBuffer` does not allow independently freeing allocations; instead, all must be freed at once, but doing so only requires resetting that offset.
][
  为解决这个问题，`pbrt` 提供 `ScratchBuffer`，管理一小块预先分配的内存。它的分配操作只需增加偏移量，因此十分高效。`ScratchBuffer` 不支持单独释放某次分配的内存，而必须一次释放全部分配；不过，这也只需重置偏移量。
]

#parec[
  Because `ScratchBuffer`s are not safe for use by multiple threads at the same time, an individual one is created for each thread using the `ThreadLocal` template class. Its constructor takes a lambda function that returns a fresh instance of the object of the type it manages; here, calling the default `ScratchBuffer` constructor is sufficient. `ThreadLocal` then handles the details of maintaining distinct copies of the object for each thread, allocating them on demand.
][
  同一个 `ScratchBuffer` 不能安全地供多个线程同时使用，因此用 `ThreadLocal` 模板类为每个线程创建独立实例。其构造函数接收一个 lambda，返回所管理类型的新对象；这里调用 `ScratchBuffer` 的默认构造函数即可。随后，`ThreadLocal` 负责为各线程维护独立对象，并按需分配。
]
#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Declarecommonvariablesforrenderingimageintiles-0")[#raw("<<Declare common variables for rendering image in tiles>>=")]]
#block(breakable: false)[
```cpp
ThreadLocal<ScratchBuffer> scratchBuffers(
    []() { return ScratchBuffer(); } );
```
]

#parec[
  Most `Sampler` implementations find it useful to maintain some state, such as the coordinates of the current pixel. This means that multiple threads cannot use a single `Sampler` concurrently and `ThreadLocal` is also used for `Sampler` management. Samplers provide a Clone() method that creates a new instance of their sampler type. The `Sampler` first provided to the `ImageTileIntegrator` constructor, `samplerPrototype`, provides those copies here.
][
  大多数 `Sampler` 实现需要维护当前像素坐标等状态，所以多个线程不能并发使用同一个采样器。为此，采样器也通过 `ThreadLocal` 管理。`Sampler` 的 `Clone()` 方法可创建相同采样器类型的新实例；最初传入 `ImageTileIntegrator` 构造函数的 `samplerPrototype` 在这里提供这些副本。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Declarecommonvariablesforrenderingimageintiles-1")[#raw("<<Declare common variables for rendering image in tiles>>+=")]]
#block(breakable: false)[
```cpp
ThreadLocal<Sampler> samplers(
    [this]() { return samplerPrototype.Clone(); });
```
]

#parec[
  It is helpful to provide the user with an indication of how much of the rendering work is done and an estimate of how much longer it will take. This task is handled by the `ProgressReporter` class, which takes as its first parameter the total number of items of work. Here, the total amount of work is the number of samples taken in each pixel times the total number of pixels. It is important to use 64-bit precision to compute this value, since a 32-bit int may be insufficient for high-resolution images with many samples per pixel.
][
  告知用户已完成多少渲染工作、预计还需多久，会很有帮助。`ProgressReporter` 负责这项任务，第一个参数是工作项总数。这里的总工作量等于每像素样本数乘以像素总数。必须用 64 位整数计算这个值，因为在每像素样本很多的高分辨率图像中，32 位 `int` 可能不够。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Declarecommonvariablesforrenderingimageintiles-2")[#raw("<<Declare common variables for rendering image in tiles>>+=")]]
#block(breakable: false)[
```cpp
Bounds2i pixelBounds = camera.GetFilm().PixelBounds();
int spp = samplerPrototype.SamplesPerPixel();
ProgressReporter progress(int64_t(spp) * pixelBounds.Area(), "Rendering",
                          Options->quiet);
```
]

#parec[
  In the following, the range of samples to be taken in the current wave is given by `waveStart` and `waveEnd`; `nextWaveSize` gives the number of samples to be taken in the next wave.
][
  后续代码中，当前批次的样本范围由 `waveStart` 和 `waveEnd` 给出，`nextWaveSize` 表示下一批次的样本数。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Declarecommonvariablesforrenderingimageintiles-3")[#raw("<<Declare common variables for rendering image in tiles>>+=")]]
#block(breakable: false)[
```cpp
int waveStart = 0, waveEnd = 1, nextWaveSize = 1;
```
]

#parec[
  With these variables in hand, rendering proceeds until the required number of samples have been taken in all pixels.
][
  有了这些变量，就持续渲染，直到所有像素都达到所需样本数。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Renderimageinwaves-0")[#raw("<<Render image in waves>>=")]]
#block(breakable: false)[
```cpp
while (waveStart < spp) {
    <<Render current wave's image tiles in parallel>>
    <<Update start and end wave>>
    <<Optionally write current image to disk>>
}
```
]

#parec[
  The `ParallelFor2D()` function loops over image tiles, running multiple loop iterations concurrently; it is part of the parallelism-related utility functions that are introduced in Section B.6. A C++ lambda expression provides the loop body. `ParallelFor2D()` automatically chooses a tile size to balance two concerns: on one hand, we would like to have significantly more tiles than there are processors in the system. It is likely that some of the tiles will take less processing time than others, so if there was for example a 1:1 mapping between processors and tiles, then some processors will be idle after finishing their work while others continue to work on their region of the image.(@fig:task-time-distribution graphs the distribution of time taken to render tiles of an example image, illustrating this concern.) On the other hand, having too many tiles also hurts efficiency. There is a small fixed overhead for a thread to acquire more work in the parallel for loop and the more tiles there are, the more times this overhead must be paid. `ParallelFor2D()` therefore chooses a tile size that accounts for both the extent of the region to be processed and the number of processors in the system.
][
  `ParallelFor2D()` 遍历图像图块，并发执行多个循环迭代；它属于第 B.6 节介绍的并行辅助函数，循环体由 C++ lambda 表达式提供。该函数自动选择图块大小，兼顾两个因素。一方面，图块数应显著多于处理器数，因为各图块的处理时间可能不同。若处理器与图块一一对应，一些处理器完成工作后就会闲置，其他处理器却仍在处理图像区域。（@fig:task-time-distribution 展示了一个示例图像各图块渲染耗时的分布。）另一方面，图块过多也会降低效率：线程在并行 `for` 循环中领取任务有少量固定开销，图块越多，支付这一开销的次数也越多。因此，`ParallelFor2D()` 同时考虑待处理区域的范围和处理器数来选择图块大小。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Rendercurrentwavesimagetilesinparallel-0")[#raw("<<Render current wave’s image tiles in parallel>>=")]]
#block(breakable: false)[
```cpp
ParallelFor2D(pixelBounds, [&](Bounds2i tileBounds) {
    <<Render image tile given by tileBounds>>
});
```
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f17.svg"),
  caption: [
    #ez_caption[*Histogram of Time Spent Rendering Each Tile for the Scene in @fig:intro-raytracing-example.* The horizontal axis measures time in seconds. Note the wide variation in execution time, illustrating that different parts of the image required substantially different amounts of computation. ][*渲染 @fig:intro-raytracing-example 场景各图块所用时间的直方图。*横轴表示时间，单位为秒。各图块的执行时间差异很大，说明图像不同区域所需的计算量相差显著。 ]
  ],
)<task-time-distribution>


#parec[
  Given a tile to render, the implementation starts by acquiring the `ScratchBuffer` and `Sampler` for the currently executing thread. As described earlier, the `ThreadLocal`::Get() method takes care of the details of allocating and returning individual ones of them for each thread.
][
  拿到待渲染图块后，先获取当前线程的 `ScratchBuffer` 和 `Sampler`。如前所述，`ThreadLocal::Get()` 负责为各线程分配并返回独立对象。
]

#parec[
  With those in hand, the implementation loops over all the pixels in the tile using a range-based for loop that uses iterators provided by the `Bounds2` class before informing the `ProgressReporter` about how much work has been completed.
][
  随后，利用 `Bounds2` 提供的迭代器，通过基于范围的 `for` 循环遍历图块全部像素，最后通知 `ProgressReporter` 已完成的工作量。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RenderimagetilegivenbymonotileBounds-0")[#raw("<<Render image tile given by tileBounds>>=")]]
#block(breakable: false)[
```cpp
ScratchBuffer &scratchBuffer = scratchBuffers.Get();
Sampler &sampler = samplers.Get();
for (Point2i pPixel : tileBounds) {
    <<Render samples in pixel pPixel>>
}
progress.Update((waveEnd - waveStart) * tileBounds.Area());
```
]

#parec[
  Given a pixel to take one or more samples in, the thread's `Sampler` is notified that it should start generating samples for the current pixel via StartPixelSample(), which allows it to set up any internal state that depends on which pixel is currently being processed. The integrator's EvaluatePixelSample() method is then responsible for determining the specified sample's value, after which any temporary memory it may have allocated in the `ScratchBuffer` is freed with a call to `ScratchBuffer`::Reset().
][
  对给定像素取一个或多个样本时，先调用线程采样器的 `StartPixelSample()`，通知它开始生成该像素的样本，让它设置依赖当前像素的内部状态。随后，积分器的 `EvaluatePixelSample()` 计算指定样本的值；完成后调用 `ScratchBuffer::Reset()`，释放可能分配的全部临时内存。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RendersamplesinpixelmonopPixel-0")[#raw("<<Render samples in pixel pPixel>>=")]]
#block(breakable: false)[
```cpp
for (int sampleIndex = waveStart; sampleIndex < waveEnd; ++sampleIndex) {
    sampler.StartPixelSample(pPixel, sampleIndex);
    EvaluatePixelSample(pPixel, sampleIndex, sampler, scratchBuffer);
    scratchBuffer.Reset();
}
```
]

#parec[
  Having provided an implementation of the pure virtual `Integrator::Render()` method, `ImageTileIntegrator` now imposes the requirement on its subclasses that they implement the following `EvaluatePixelSample()` method.
][
  `ImageTileIntegrator` 实现纯虚方法 `Integrator::Render()` 后，进一步要求子类实现下面的 `EvaluatePixelSample()` 方法。
]
#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-ImageTileIntegratorPublicMethods-1")[#raw("<<ImageTileIntegrator Public Methods>>+=")]]
#block(breakable: false)[
```cpp
virtual void EvaluatePixelSample(Point2i pPixel, int sampleIndex,
    Sampler sampler, ScratchBuffer &scratchBuffer) = 0;
```
]

#parec[
  After the parallel for loop for the current wave completes, the range of sample indices to be processed in the next wave is computed.
][
  当前批次的并行 `for` 循环完成后，计算下一批次要处理的样本索引范围。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Updatestartandendwave-0")[#raw("<<Update start and end wave>>=")]]
#block(breakable: false)[
```cpp
waveStart = waveEnd;
waveEnd = std::min(spp, waveEnd + nextWaveSize);
nextWaveSize = std::min(2 * nextWaveSize, 64);
```
]

#parec[
  If the user has provided the –write-partial-images command-line option, the in-progress image is written to disk before the next wave of samples is processed. We will not include here the fragment that takes care of this, `<<Optionally write current image to disk>>`.
][
  如果用户指定了 `--write-partial-images` 命令行选项，就在处理下一批样本前将当前图像写入磁盘。这里不列出负责此操作的代码片段 `<<Optionally write current image to disk>>`。
]



=== #ez_caption[RayIntegrator Implementation][RayIntegrator 的实现]
<rayintegrator-implementation>
#parec[
  Just as the `ImageTileIntegrator` centralizes functionality related to integrators that decompose the image into tiles, `RayIntegrator` provides commonly used functionality to integrators that trace ray paths starting from the camera. All of the integrators implemented in @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering inherit from `RayIntegrator`.
][
  `ImageTileIntegrator` 集中提供按图块渲染所需的功能；类似地，`RayIntegrator` 为从相机出发追踪射线路径的积分器提供常用功能。@light-transport-i-surface-reflection 和 @light-transport-ii-volume-rendering 中实现的所有积分器都继承它。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RayIntegratorDefinition-0")[#raw("<<RayIntegrator Definition>>=")]]
#block(breakable: false)[
```cpp
 class RayIntegrator : public ImageTileIntegrator {
   public:
     // <<RayIntegrator Public Methods>>
     RayIntegrator(Camera camera, Sampler sampler, Primitive aggregate, std::vector<Light> lights)
            : ImageTileIntegrator(camera, sampler, aggregate, lights) {}
        void EvaluatePixelSample(Point2i pPixel, int sampleIndex,
                                 Sampler sampler, ScratchBuffer &scratchBuffer) final;
        virtual SampledSpectrum Li(
            RayDifferential ray, SampledWavelengths &lambda, Sampler sampler,
            ScratchBuffer &scratchBuffer, VisibleSurface *visibleSurface) const = 0;
 };
```
]

#parec[
  Its constructor does nothing more than pass along the provided objects to the `ImageTileIntegrator` constructor.
][
  其构造函数只将传入对象转交给 `ImageTileIntegrator` 的构造函数。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RayIntegratorPublicMethods-0")[#raw("<<RayIntegrator Public Methods>>=")]]
#block(breakable: false)[
```cpp
RayIntegrator(Camera camera, Sampler sampler, Primitive aggregate,
              std::vector<Light> lights)
    : ImageTileIntegrator(camera, sampler, aggregate, lights) {}
```
]


#parec[
  `RayIntegrator` implements the pure virtual `EvaluatePixelSample()` method from `ImageTileIntegrator`. At the given pixel, it uses its `Camera` and `Sampler` to generate a ray into the scene and then calls the `Li()` method, which is provided by the subclass, to determine the amount of light arriving at the image plane along that ray. As we will see in following chapters, the units of the value returned by this method are related to the incident spectral radiance at the ray origin, which is generally denoted by the symbol $L_i$ in equations—thus, the method name. This value is passed to the `Film`, which records the ray's contribution to the image.
][
  `RayIntegrator` 实现了 `ImageTileIntegrator` 的纯虚方法 `EvaluatePixelSample()`。在给定像素处，它用 `Camera` 和 `Sampler` 生成进入场景的射线，再调用子类实现的 `Li()`，计算沿射线到达图像平面的光量。后续章节将说明，该返回值的单位与射线起点的入射光谱辐亮度有关；方程通常用 $L_i$ 表示这一量，这也是方法名称的来源。该值传给 `Film`，由它记录射线对图像的贡献。
]

#parec[
  @fig:main-render-loop-classes summarizes the main classes used in this method and the flow of data among them.
][
  @fig:main-render-loop-classes 汇总了这个方法使用的主要类及其间的数据流。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f18.svg"),
  caption: [
    #ez_caption[*Class Relationships for RayIntegrator::EvaluatePixelSample()'s computation.* The Sampler provides sample values for each image sample to be taken. The Camera turns a sample into a corresponding ray from the film plane, and the Li() method computes the radiance along that ray arriving at the film. The sample and its radiance are passed to the Film, which stores their contribution in an image.][*`RayIntegrator::EvaluatePixelSample()` 计算中的类关系。*`Sampler` 为待取的每个图像样本提供样本值；`Camera` 将样本转换为从胶片平面出发的对应射线；`Li()` 计算沿该射线到达胶片的辐亮度。样本及其辐亮度传给 `Film`，由它将贡献存入图像。]
  ],
) <main-render-loop-classes>

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RayIntegratorMethodDefinitions-0")[#raw("<<RayIntegrator Method Definitions>>=")]]
#block(breakable: false)[
```cpp
void RayIntegrator::EvaluatePixelSample(Point2i pPixel, int sampleIndex,
        Sampler sampler, ScratchBuffer &scratchBuffer) {
    <<Sample wavelengths for the ray>>
    <<Initialize CameraSample for current sample>>
    <<Generate camera ray for current sample>>
    <<Trace cameraRay if valid>>
    <<Add camera ray's contribution to image>>
}
```
]


#parec[
  Each ray carries radiance at a number of discrete wavelengths $lambda$ (four, by default). When computing the color at each pixel, `pbrt` chooses different wavelengths at different pixel samples so that the final result better reflects the correct result over all wavelengths. To choose these wavelengths, a sample value `lu` is first provided by the `Sampler`. This value will be uniformly distributed and in the range $\[ 0 , 1 \)$. The `Film::SampleWavelengths()` method then maps this sample to a set of specific wavelengths, taking into account its model of film sensor response as a function of wavelength. Most `Sampler` implementations ensure that if multiple samples are taken in a pixel, those samples are in the aggregate well distributed over $\[ 0 , 1 \)$. In turn, they ensure that the sampled wavelengths are also well distributed across the range of valid wavelengths, improving image quality.
][
  每条射线携带若干离散波长 $lambda$ 上的辐亮度，默认是四个波长。计算像素颜色时，`pbrt` 为不同像素样本选择不同波长，使最终结果更准确地反映全部波长的贡献。首先，`Sampler` 提供一个在 $[0, 1\)$ 内均匀分布的样本值 `lu`；`Film::SampleWavelengths()` 再根据胶片传感器随波长变化的响应模型，将其映射为一组具体波长。大多数采样器能保证同一像素的多个样本整体上在 $[0, 1\)$ 内分布良好，进而使选取的波长在有效波长范围内也分布良好，提高图像质量。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Samplewavelengthsfortheray-0")[#raw("<<Sample wavelengths for the ray>>=")]]
#block(breakable: false)[
```cpp
Float lu = sampler.Get1D();
SampledWavelengths lambda = camera.GetFilm().SampleWavelengths(lu);
```
]


#parec[
  The `CameraSample` structure records the position on the film for which the camera should generate a ray. This position is affected by both a sample position provided by the sampler and the reconstruction filter that is used to filter multiple sample values into a single value for the pixel. `GetCameraSample()` handles those calculations. `CameraSample` also stores a time that is associated with the ray as well as a lens position sample, which are used when rendering scenes with moving objects and for camera models that simulate non-pinhole apertures, respectively.
][
  `CameraSample` 记录相机应为之生成射线的胶片位置。该位置既受采样器提供的样本位置影响，也受重建滤波器影响；后者将多个样本值滤波为单个像素值。`GetCameraSample()` 负责这些计算。`CameraSample` 还存储射线对应的时间和透镜位置样本，分别用于渲染含运动物体的场景，以及模拟非针孔光圈的相机。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-InitializemonoCameraSampleforcurrentsample-0")[#raw("<<Initialize CameraSample for current sample>>=")]]
#block(breakable: false)[
```cpp
Filter filter = camera.GetFilm().GetFilter();
CameraSample cameraSample = GetCameraSample(sampler, pPixel, filter);
```
]


#parec[
  The `Camera` interface provides two methods to generate rays: `GenerateRay()`, which returns the ray for a given image sample position, and `GenerateRayDifferential()`, which returns a #emph[ray
differential], which incorporates information about the rays that the camera would generate for samples that are one pixel away on the image plane in both the $x$ and $y$ directions. Ray differentials are used to get better results from some of the texture functions defined in Chapter~#link("https://pbr-book.org/4ed/Textures_and_Materials.html#chap:texture")[10], by making it possible to compute how quickly a texture varies with respect to the pixel spacing, which is a key component of texture antialiasing.
][
  `Camera` 接口提供两个射线生成方法：`GenerateRay()` 返回给定图像样本位置对应的射线；`GenerateRayDifferential()` 返回_射线微分_，还包含相机对图像平面上沿 $x$、$y$ 方向各相隔一个像素的样本所生成的射线信息。射线微分使我们能够计算纹理相对于像素间距的变化速率，这是纹理抗锯齿的关键，从而改善 @textures-and-materials 中某些纹理函数的结果。
]

#parec[
  Some `CameraSample` values may not correspond to valid rays for a given camera.

  Therefore, `pstd::optional` is used for the `CameraRayDifferential` returned by the camera.
][
  对于给定相机，某些 `CameraSample` 值可能不对应有效射线，因此相机用 `pstd::optional` 返回 `CameraRayDifferential`。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Generatecamerarayforcurrentsample-0")[#raw("<<Generate camera ray for current sample>>=")]]
#block(breakable: false)[
```cpp
pstd::optional<CameraRayDifferential> cameraRay =
    camera.GenerateRayDifferential(cameraSample, lambda);
```
]

#parec[
  If the camera ray is valid, it is passed along to the `RayIntegrator` subclass's `Li()` method implementation after some additional preparation. In addition to returning the radiance along the ray `L`, the subclass is also responsible for initializing an instance of the `VisibleSurface` class, which records geometric information about the surface the ray intersects (if any) at each pixel for the use of `Film` implementations like the `GBufferFilm` that store more information than just color at each pixel.
][
  若相机射线有效，再做一些准备后，就将它传给 `RayIntegrator` 子类实现的 `Li()`。除了返回沿射线的辐亮度 `L`，子类还负责初始化 `VisibleSurface` 实例，记录每个像素对应射线所交表面的几何信息（若存在交点），供 `GBufferFilm` 等每像素不仅存储颜色的 `Film` 实现使用。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-TracemonocameraRayifvalid-0")[#raw("<<Trace cameraRay if valid>>=")]]
```cpp
SampledSpectrum L(0.);
VisibleSurface visibleSurface;
if (cameraRay) {
    // <<Scale camera ray differentials based on image sampling rate>>
    Float rayDiffScale =
           std::max<Float>(.125f, 1 / std::sqrt((Float)sampler.SamplesPerPixel()));
    cameraRay->ray.ScaleDifferentials(rayDiffScale);
    // <<Evaluate radiance along camera ray>>
    bool initializeVisibleSurface = camera.GetFilm().UsesVisibleSurface();
    L = cameraRay->weight *
        Li(cameraRay->ray, lambda, sampler, scratchBuffer,
           initializeVisibleSurface ? &visibleSurface : nullptr);
    // <<Issue warning if unexpected radiance value is returned>>
    if (L.HasNaNs()) {
        LOG_ERROR("Not-a-number radiance value returned for pixel (%d, "
                  "%d), sample %d. Setting to black.",
                  pPixel.x, pPixel.y, sampleIndex);
        L = SampledSpectrum(0.f);
    } else if (IsInf(L.y(lambda))) {
        LOG_ERROR("Infinite radiance value returned for pixel (%d, %d), "
                  "sample %d. Setting to black.",
                  pPixel.x, pPixel.y, sampleIndex);
        L = SampledSpectrum(0.f);
    }
}
```


#parec[
  Before the ray is passed to the `Li()` method, the `ScaleDifferentials()` method scales the differential rays to account for the actual spacing between samples on the film plane when multiple samples are taken per pixel.
][
  将射线传给 `Li()` 之前，`ScaleDifferentials()` 会缩放微分射线，以反映每像素取多个样本时，胶片平面上样本之间的实际间距。
]


#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Scalecameraraydifferentialsbasedonimagesamplingrate-0")[#raw("<<Scale camera ray differentials based on image sampling rate>>=")]]
#block(breakable: false)[
```cpp
Float rayDiffScale =
    std::max<Float>(.125f, 1 / std::sqrt((Float)sampler.SamplesPerPixel()));
cameraRay->ray.ScaleDifferentials(rayDiffScale);
```
]


#parec[
  For `Film` implementations that do not store geometric information at each pixel, it is worth saving the work of populating the `VisibleSurface` class. Therefore, a pointer to this class is only passed in the call to the `Li()` method if it is necessary, and a null pointer is passed otherwise. Integrator implementations then should only initialize the `VisibleSurface` if it is non-null.
][
  若 `Film` 不为每个像素存储几何信息，就应省去填充 `VisibleSurface` 的工作。因此，只有需要这些信息时，调用 `Li()` 才传入指向该对象的指针；否则传入空指针。积分器实现也只应在该指针非空时初始化 `VisibleSurface`。
]

#parec[
  `CameraRayDifferential` also carries a weight associated with the ray that is used to scale the returned radiance value. For simple camera models, each ray is weighted equally, but camera models that more accurately simulate the process of image formation by lens systems may generate some rays that contribute more than others. Such a camera model might simulate the effect of less light arriving at the edges of the film plane than at the center, an effect called #emph[vignetting].
][
  `CameraRayDifferential` 还携带射线权重，用来缩放返回的辐亮度。简单相机模型对所有射线赋予相同权重；更准确地模拟透镜系统成像的模型，则可能让某些射线比其他射线贡献更大。例如，它们可能模拟胶片边缘接收到的光少于中心的现象，称为_渐晕_。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Evaluateradiancealongcameraray-0")[#raw("<<Evaluate radiance along camera ray>>=")]]
#block(breakable: false)[
```cpp
bool initializeVisibleSurface = camera.GetFilm().UsesVisibleSurface();
L = cameraRay->weight *
    Li(cameraRay->ray, lambda, sampler, scratchBuffer,
       initializeVisibleSurface ? &visibleSurface : nullptr);
```
]


#parec[
  `Li()` is a pure virtual method that `RayIntegrator` subclasses must implement. It returns the incident radiance at the origin of a given ray, sampled at the specified wavelengths.
][
  `Li()` 是 `RayIntegrator` 子类必须实现的纯虚方法。它返回在指定波长上采样的、给定射线起点处的入射辐亮度。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RayIntegratorPublicMethods-1")[#raw("<<RayIntegrator Public Methods>>+=")]]
#block(breakable: false)[
```cpp
virtual SampledSpectrum Li(
    RayDifferential ray, SampledWavelengths &lambda, Sampler sampler,
    ScratchBuffer &scratchBuffer, VisibleSurface *visibleSurface) const = 0;
```
]


#parec[
  A common side effect of bugs in the rendering process is that impossible radiance values are computed. For example, division by zero results in radiance values equal to either the IEEE floating-point infinity or a "not a number" value. The renderer looks for these possibilities and prints an error message when it encounters them. Here we will not include the fragment that does this, `<<Issue warning if unexpected radiance value is returned>>`. See the implementation in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`] if you are interested in its details.
][
  渲染错误的一种常见表现，是算出不可能的辐亮度。例如，除以零可能得到 IEEE 浮点无穷大或“非数”（NaN）。渲染器会检测这些情况，遇到时输出错误信息。这里不列出相应代码片段 `<<Issue warning if unexpected radiance value is returned>>`；具体实现见 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`]。
]

#parec[
  After the radiance arriving at the ray's origin is known, a call to `Film::AddSample()` updates the corresponding pixel in the image, given the weighted radiance for the sample. The details of how sample values are recorded in the film are explained in @film-and-imaging and~#link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Image_Reconstruction.html#sec:image-reconstruction")[8.8].
][
  求得射线起点处的入射辐亮度后，调用 `Film::AddSample()`，利用样本的加权辐亮度更新图像中对应的像素。样本值如何记录到胶片中，详见 @film-and-imaging 和 @image-reconstruction。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Addcamerarayscontributiontoimage-0")[#raw("<<Add camera ray’s contribution to image>>=")]]
#block(breakable: false)[
```cpp
camera.GetFilm().AddSample(pPixel, L, lambda, &visibleSurface,
                           cameraSample.filterWeight);
```
]



=== #ez_caption[Random Walk Integrator][随机游走积分器]
<random-walk-integrator>
#parec[
  Although it has taken a few pages to go through the implementation of the integrator infrastructure that culminated in `RayIntegrator`, we can now turn to implementing light transport integration algorithms in a simpler context than having to start implementing a complete `Integrator::Render()` method. The `RandomWalkIntegrator` that we will describe in this section inherits from `RayIntegrator` and thus all the details of multi-threading, generating the initial ray from the camera and then adding the radiance along that ray to the image, are all taken care of. The integrator operates in a simpler context: a ray has been provided and its task is to compute the radiance arriving at its origin.
][
  虽然我们花了数页介绍以 `RayIntegrator` 为基础的积分器框架，但现在实现光传输积分算法，就不必从完整的 `Integrator::Render()` 开始了。本节介绍的 `RandomWalkIntegrator` 继承 `RayIntegrator`，因此多线程、相机初始射线生成，以及将沿射线的辐亮度加入图像等细节，都已处理完毕。它面对的任务很简单：给定一条射线，计算到达其起点的辐亮度。
]

#parec[
  Recall that in @ray-propagation we mentioned that in the absence of participating media, the light carried by a ray is unchanged as it passes through free space. We will ignore the possibility of participating media in the implementation of this integrator, which allows us to take a first step: given the first intersection of a ray with the geometry in the scene, the radiance arriving at the ray's origin is equal to the radiance leaving the intersection point toward the ray's origin. That outgoing radiance is given by the light transport equation (@eqt:rendering-equation), though it is hopeless to evaluate it in closed form. Numerical approaches are required, and the ones used in `pbrt` are based on Monte Carlo integration, which makes it possible to estimate the values of integrals based on pointwise evaluation of their integrands. @monte-carlo-integration provides an introduction to Monte Carlo integration, and additional Monte Carlo techniques will be introduced as they are used throughout the book.
][
  @ray-propagation 提到，没有参与介质时，射线携带的光在自由空间中传播而不变。本积分器忽略参与介质，因此可以先确定：射线与场景几何体的第一个交点向射线起点发出的辐亮度，等于到达射线起点的辐亮度。该出射辐亮度由光传输方程 @eqt:rendering-equation 给出，但无法指望用闭式表达式求解，必须采用数值方法。`pbrt` 使用蒙特卡洛积分，通过在若干点求被积函数值来估计积分。@monte-carlo-integration 将介绍其基础，其余蒙特卡洛技术则在后续使用时介绍。
]

#parec[
  In order to compute the outgoing radiance, the `RandomWalkIntegrator` implements a simple Monte Carlo approach that is based on incrementally constructing a #emph[random walk], where a series of points on scene surfaces are randomly chosen in succession to construct light-carrying paths starting from the camera. This approach effectively models image formation in the real world in reverse, starting from the camera rather than from the light sources. Going backward in this respect is still physically valid because the physical models of light that `pbrt` is based on are time-reversible.
][
  为计算出射辐亮度，`RandomWalkIntegrator` 采用一种简单的蒙特卡洛方法，逐步构造_随机游走_：依次随机选择场景表面上的点，形成从相机出发、承载光的路径。这实际上是逆向模拟真实世界的成像过程，从相机而非光源开始。这样的逆向过程仍符合物理规律，因为 `pbrt` 所依据的光学模型具有时间可逆性。
]

#figure(
  image("imgs/random-walk-insanity.png"),
  caption: [#ez_caption[
      A View of the #emph[Watercolor] Scene, Rendered with
      the `RandomWalkIntegrator`. Because the `RandomWalkIntegrator` does
      not handle perfectly specular surfaces, the two glasses on the table
      are black. Furthermore, even with the 8,192 samples per pixel used
      to render this image, the result is still peppered with
      high-frequency noise. (Note, for example, the far wall and the base
      of the chair.) (Scene courtesy of Angelo Ferretti.)
    ][
      使用 `RandomWalkIntegrator` 渲染的 _Watercolor_ 场景视图。它无法处理理想镜面表面，因此桌上的两个玻璃杯呈黑色。即使每像素使用 8,192 个样本，图像仍布满高频噪声，例如远处的墙面和椅子底部。（场景由 Angelo Ferretti 提供。）
    ]],
) <random-walk-integrator-image>

#parec[
  Although the implementation of the random walk sampling algorithm is in total just over twenty lines of code, it is capable of simulating complex lighting and shading effects; @fig:random-walk-integrator-image shows an image rendered using it.(That image required many hours of computation to achieve that level of quality, however.) For the remainder of this section, we will gloss over a few of the mathematical details of the integrator's implementation and focus on an intuitive understanding of the approach, though subsequent chapters will fill in the gaps and explain this and more sophisticated techniques more rigorously.
][
  随机游走采样算法总共只有二十多行代码，却能模拟复杂的光照和着色效果；@fig:random-walk-integrator-image 展示了它生成的图像，不过达到这一质量仍需要许多小时计算。本节接下来暂略一些数学细节，着重建立直观理解；后续章节会补全细节，并更严谨地解释这一方法及更复杂的技术。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RandomWalkIntegratorDefinition-0")[#raw("<<RandomWalkIntegrator Definition>>=")]]
```cpp
class RandomWalkIntegrator : public RayIntegrator {
  public:
    RandomWalkIntegrator(int maxDepth, Camera camera, Sampler sampler,
                        Primitive aggregate, std::vector<Light> lights)
           : RayIntegrator(camera, sampler, aggregate, lights), maxDepth(maxDepth) {}

       static std::unique_ptr<RandomWalkIntegrator> Create(
           const ParameterDictionary &parameters, Camera camera, Sampler sampler,
           Primitive aggregate, std::vector<Light> lights, const FileLoc *loc);

       std::string ToString() const;
       SampledSpectrum Li(RayDifferential ray, SampledWavelengths &lambda,
               Sampler sampler, ScratchBuffer &scratchBuffer,
               VisibleSurface *visibleSurface) const {
           return LiRandomWalk(ray, lambda, sampler, scratchBuffer, 0);
       }
  private:
    SampledSpectrum LiRandomWalk(RayDifferential ray,
               SampledWavelengths &lambda, Sampler sampler,
               ScratchBuffer &scratchBuffer, int depth) const {
           pstd::optional<ShapeIntersection> si = Intersect(ray);
              if (!si) {
                     SampledSpectrum Le(0.f);
                     for (Light light : infiniteLights)
                         Le += light.Le(ray, lambda);
                     return Le;
              }
              SurfaceInteraction &isect = si->intr;
              Vector3f wo = -ray.d;
              SampledSpectrum Le = isect.Le(wo, lambda);
              if (depth == maxDepth)
                  return Le;
              BSDF bsdf = isect.GetBSDF(ray, lambda, camera, scratchBuffer, sampler);
              Point2f u = sampler.Get2D();
              Vector3f wp = SampleUniformSphere(u);
              SampledSpectrum fcos = bsdf.f(wo, wp) * AbsDot(wp, isect.shading.n);
              if (!fcos)
                  return Le;
              ray = isect.SpawnRay(wp);
              return Le  + fcos * LiRandomWalk(ray, lambda, sampler, scratchBuffer,
                                               depth + 1) / (1 / (4 * Pi));
       }
    int maxDepth;
};
```

#parec[
  This integrator recursively evaluates the random walk. Therefore, its `Li()` method implementation does little more than start the recursion, via a call to the `LiRandomWalk()` method. Most of the parameters to `Li()` are just passed along, though the `VisibleSurface` is ignored for this simple integrator and an additional parameter is added to track the depth of recursion.
][
  该积分器递归计算随机游走。因此，`Li()` 主要是调用 `LiRandomWalk()` 来启动递归。多数参数直接传递下去；这个简单积分器忽略 `VisibleSurface`，并增加一个参数跟踪递归深度。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RandomWalkIntegratorPublicMethods-0")[#raw("<<RandomWalkIntegrator Public Methods>>=")]]
#block(breakable: false)[
```cpp
SampledSpectrum Li(RayDifferential ray, SampledWavelengths &lambda,
        Sampler sampler, ScratchBuffer &scratchBuffer,
        VisibleSurface *visibleSurface) const {
    return LiRandomWalk(ray, lambda, sampler, scratchBuffer, 0);
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RandomWalkIntegratorPrivateMethods-0")[#raw("<<RandomWalkIntegrator Private Methods>>=")]]
#block(breakable: false)[
```cpp
SampledSpectrum LiRandomWalk(RayDifferential ray,
        SampledWavelengths &lambda, Sampler sampler,
        ScratchBuffer &scratchBuffer, int depth) const {
    <<Intersect ray with scene and return if no intersection>>
    <<Get emitted radiance at surface intersection>>
    <<Terminate random walk if maximum depth has been reached>>
    <<Compute BSDF at random walk intersection point>>
    <<Randomly sample direction leaving surface for random walk>>
    <<Evaluate BSDF at surface for sampled direction>>
    <<Recursively trace ray to estimate incident radiance at surface>>
}
```
]

#parec[
  The first step is to find the closest intersection of the ray with the shapes in the scene. If no intersection is found, the ray has left the scene. Otherwise, a `SurfaceInteraction` that is returned as part of the `ShapeIntersection` structure provides information about the local geometric properties of the intersection point.
][
  第一步是寻找射线与场景形状的最近交点。若未找到，说明射线已离开场景；否则，作为 `ShapeIntersection` 一部分返回的 `SurfaceInteraction` 提供交点的局部几何信息。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Intersectraywithsceneandreturnifnointersection-0")[#raw("<<Intersect ray with scene and return if no intersection>>=")]]
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection> si = Intersect(ray);
if (!si) {
       SampledSpectrum Le(0.f);
       for (Light light : infiniteLights)
           Le += light.Le(ray, lambda);
       return Le;
}
SurfaceInteraction &isect = si->intr;
```
]

#parec[
  If no intersection was found, radiance still may be carried along the ray due to light sources such as the `ImageInfiniteLight` that do not have geometry associated with them. The `Light::Le()` method allows such lights to return their radiance for a given ray.
][
  即使没有交点，射线也可能携带来自 `ImageInfiniteLight` 等不具有对应几何体的光源的辐亮度。这类光源通过 `Light::Le()` 返回给定射线对应的辐亮度。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Returnemittedlightfrominfinitelightsources-0")[#raw("<<Return emitted light from infinite light sources>>=")]]
#block(breakable: false)[
```cpp
SampledSpectrum Le(0.f);
for (Light light : infiniteLights)
    Le += light.Le(ray, lambda);
return Le;
```
]


#parec[
  If a valid intersection has been found, we must evaluate the light transport equation at the intersection point. The first term, $L_(e)(p , omega_o)$, which is the emitted radiance, is easy: emission is part of the scene specification and the emitted radiance is available by calling the `SurfaceInteraction::Le()` method, which takes the outgoing direction of interest. Here, we are interested in radiance emitted back along the ray's direction. If the object is not emissive, that method returns a zero-valued spectral distribution.
][
  若找到有效交点，就要在该点计算光传输方程。第一项 $L_(e)(p, omega_o)$ 是发出的辐亮度，很容易获得：发光属性属于场景定义，调用 `SurfaceInteraction::Le()` 并传入关心的出射方向即可。这里关心的是沿射线反向发回的辐亮度。若物体不发光，该方法返回值全为零的光谱分布。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Getemittedradianceatsurfaceintersection-0")[#raw("<<Get emitted radiance at surface intersection>>=")]]
#block(breakable: false)[
```cpp
Vector3f wo = -ray.d;
SampledSpectrum Le = isect.Le(wo, lambda);
```
]

#parec[
  Evaluating the second term of the light transport equation requires computing an integral over the sphere of directions around the intersection point $p$. Application of the principles of Monte Carlo integration can be used to show that if directions $omega'$ are chosen with equal probability over all possible directions, then an estimate of the integral can be computed as a weighted product of the BSDF $f$, which describes the light scattering properties of the material at $p$, the incident lighting, $L_i$, and a cosine factor:
][
  光传输方程的第二项需要在交点 $p$ 周围的方向球面上积分。根据蒙特卡洛积分原理，如果在所有可能方向上等概率选择方向 $omega'$，就能将积分估计为 BSDF $f$、入射光照 $L_i$ 与余弦因子的加权乘积，其中 $f$ 描述点 $p$ 处材质的散射性质：
]


$
  integral_(cal(S)^2) f (p , omega_o , omega_i) L_(i)( p , omega_i ) lr(|cos theta_i|) thin d omega_i approx frac(f (p , omega_o , omega') L_(i)(p , omega') lr(|cos theta'|), 1 \/ (4 pi)) .
$ <simple-mc-estimator-random-walk>


#parec[
  In other words, given a random direction $omega'$, estimating the value of the integral requires evaluating the terms in the integrand for that direction and then scaling by a factor of $4 pi$.(This factor, which is derived in Section A.5.2, relates to the surface area of a unit sphere.) Since only a single direction is considered, there is almost always error in the Monte Carlo estimate compared to the true value of the integral. However, it can be shown that estimates like this one are correct in expectation: informally, that they give the correct result on average. Averaging multiple independent estimates generally reduces this error—hence, the practice of taking multiple samples per pixel.
][
  也就是说，给定随机方向 $omega'$，只需计算被积函数在该方向上的各项，再乘以 $4 pi$，即可估计积分。（该因子与单位球表面积有关，推导见第 A.5.2 节。）只考虑一个方向时，蒙特卡洛估计值与积分真值几乎总有误差；但可以证明，这种估计在期望意义下是正确的，通俗地说，就是平均而言得到正确结果。对多个独立估计值求平均，通常能减小误差，因此我们会在每个像素取多个样本。
]

#parec[
  The BSDF and the cosine factor of the estimate are easily evaluated, leaving us with $L_i$, the incident radiance, unknown. However, note that we have found ourselves right back where we started with the initial call to `LiRandomWalk()`: we have a ray for which we would like to find the incident radiance at the origin—that, a recursive call to `LiRandomWalk()` will provide.
][
  估计式中的 BSDF 和余弦因子都容易计算，未知的只剩入射辐亮度 $L_i$。这又回到了最初调用 `LiRandomWalk()` 时的情形：给定射线，需要求起点的入射辐亮度；递归调用 `LiRandomWalk()` 即可提供这一量。
]

#parec[
  Before computing the estimate of the integral, we must consider terminating the recursion. The `RandomWalkIntegrator` stops at a predetermined maximum depth, `maxDepth`. Without this termination criterion, the algorithm might never terminate (imagine, e.g., a hall-of-mirrors scene). This member variable is initialized in the constructor based on a parameter that can be set in the scene description file.
][
  计算积分估计值前，必须考虑何时终止递归。`RandomWalkIntegrator` 在预设最大深度 `maxDepth` 处停止。没有这个条件，算法可能永不终止，例如在镜厅场景中。该成员由构造函数初始化，其参数可在场景描述文件中设置。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-RandomWalkIntegratorPrivateMembers-0")[#raw("<<RandomWalkIntegrator Private Members>>=")]]
#block(breakable: false)[
```cpp
int maxDepth;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Terminaterandomwalkifmaximumdepthhasbeenreached-0")[#raw("<<Terminate random walk if maximum depth has been reached>>=")]]
#block(breakable: false)[
```cpp
if (depth == maxDepth)
    return Le;
```
]
#parec[
  If the random walk is not terminated, the `SurfaceInteraction::GetBSDF()` method is called to find the BSDF at the intersection point. It evaluates texture functions to determine surface properties and then initializes a representation of the BSDF. It generally needs to allocate memory for the objects that constitute the BSDF's representation; because this memory only needs to be active when processing the current ray, the `ScratchBuffer` is provided to it to use for its allocations.
][
  若随机游走未终止，就调用 `SurfaceInteraction::GetBSDF()` 获取交点处的 BSDF。它先计算纹理函数来确定表面属性，再初始化 BSDF 表示。组成这一表示的对象通常需要分配内存；这些内存只需在处理当前射线期间有效，因此传入 `ScratchBuffer` 供其分配使用。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-ComputeBSDFatrandomwalkintersectionpoint-0")[#raw("<<Compute BSDF at random walk intersection point>>=")]]
#block(breakable: false)[
```cpp
BSDF bsdf = isect.GetBSDF(ray, lambda, camera, scratchBuffer, sampler);
```
]
#parec[
  Next, we need to sample a random direction $omega'$ to compute the estimate in @eqt:simple-mc-estimator-random-walk . The `SampleUniformSphere()` function returns a uniformly distributed direction on the unit sphere, given two uniform values in $\[ 0 , 1 \)$ that are provided here by the sampler.
][
  接着，需要采样随机方向 $omega'$，以计算 @eqt:simple-mc-estimator-random-walk 的估计值。`SampleUniformSphere()` 根据两个在 $[0, 1\)$ 内均匀分布的值，返回单位球面上的均匀分布方向；这里的两个值由采样器提供。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Randomlysampledirectionleavingsurfaceforrandomwalk-0")[#raw("<<Randomly sample direction leaving surface for random walk>>=")]]
#block(breakable: false)[
```cpp
Point2f u = sampler.Get2D();
Vector3f wp = SampleUniformSphere(u);
```
]

#parec[
  All the factors of the Monte Carlo estimate other than the incident radiance can now be readily evaluated. The `BSDF` class provides an `f()` method that evaluates the BSDF for a pair of specified directions, and the cosine of the angle with the surface normal can be computed using the `AbsDot()` function, which returns the absolute value of the dot product between two vectors. If the vectors are normalized, as both are here, this value is equal to the absolute value of the cosine of the angle between them (@dot-and-cross-product).
][
  现在，除入射辐亮度外，蒙特卡洛估计的所有因子都能计算。`BSDF::f()` 计算给定方向对的 BSDF；方向与表面法线夹角的余弦则可用 `AbsDot()` 求得，它返回两向量点积的绝对值。当两个向量都归一化时，如此处一样，这个值就是夹角余弦的绝对值（@dot-and-cross-product）。
]

#parec[
  It is possible that the BSDF will be zero-valued for the provided directions and thus that `fcos` will be as well—for example, the BSDF is zero if the surface is not transmissive but the two directions are on opposite sides of it. #footnote[It would be easy enough to check if the BSDF was only reflective and to only sample directions on the same side of the surface as the ray, but for this simple integrator we will not bother.] In that case, there is no reason to continue the random walk, since subsequent points will make no contribution to the result.
][
  对于给定方向，BSDF 可能为零，`fcos` 也就为零。例如，表面不透射，而两个方向位于表面两侧时，BSDF 为零。#footnote[检查 BSDF 是否只反射，并仅在与射线同侧的半球采样方向，并不困难；但这个简单积分器不作此处理。] 此时无需继续随机游走，因为后续点不会对结果产生贡献。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-EvaluateBSDFatsurfaceforsampleddirection-0")[#raw("<<Evaluate BSDF at surface for sampled direction>>=")]]
#block(breakable: false)[
```cpp
SampledSpectrum fcos = bsdf.f(wo, wp) * AbsDot(wp, isect.shading.n);
if (!fcos)
    return Le;
```
]
#parec[
  The remaining task is to compute the new ray leaving the surface in the sampled direction $omega'$. This task is handled by the `SpawnRay()` method, which returns a ray leaving an intersection in the provided direction, ensuring that the ray is sufficiently offset from the surface that it does not incorrectly reintersect it due to round-off error. Given the ray, the recursive call to `LiRandomWalk()` can be made to estimate the incident radiance, which completes the estimate of @eqt:simple-mc-estimator-random-walk.
][
  最后，需要计算沿采样方向 $omega'$ 离开表面的新射线。`SpawnRay()` 负责生成这条射线，并将其起点相对表面偏移足够距离，以免舍入误差使射线错误地再次与同一表面相交。然后递归调用 `LiRandomWalk()` 估计入射辐亮度，就完成了 @eqt:simple-mc-estimator-random-walk 的估计。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#fragment-Recursivelytraceraytoestimateincidentradianceatsurface-0")[#raw("<<Recursively trace ray to estimate incident radiance at surface>>=")]]
#block(breakable: false)[
```cpp
ray = isect.SpawnRay(wp);
return Le  + fcos * LiRandomWalk(ray, lambda, sampler, scratchBuffer,
                                 depth + 1) / (1 / (4 * Pi));
```
]
#parec[
  This simple approach has many shortcomings. For example, if the emissive surfaces are small, most ray paths will not find any light and many rays will need to be traced to form an accurate image. In the limit case of a point light source, the image will be black, since there is zero probability of intersecting such a light source. Similar issues apply with BSDF models that scatter light in a concentrated set of directions. In the limiting case of a perfect mirror that scatters incident light along a single direction, the `RandomWalkIntegrator` will never be able to randomly sample that direction.
][
  这种简单方法有许多不足。例如，发光表面很小时，多数射线路径找不到光源，必须追踪大量射线才能得到准确图像。在点光源这一极限情形中，图像会是黑色的，因为射线与这种光源相交的概率为零。将光集中散射到少数方向的 BSDF 也有类似问题。极端情况下，理想镜面只将入射光散射到一个方向，`RandomWalkIntegrator` 永远无法随机采到该方向。
]

#parec[
  Those issues and more can be addressed through more sophisticated application of Monte Carlo integration techniques. In subsequent chapters, we will introduce a succession of improvements that lead to much more accurate results. The integrators that are defined in @light-transport-i-surface-reflection through @wavefront-rendering-on-gpus are the culmination of those developments. All still build on the same basic ideas used in the `RandomWalkIntegrator`, but are much more efficient and robust than it is. @fig:randomwalk-vs-path-integrator compares the `RandomWalkIntegrator` to one of the improved integrators and gives a sense of how much improvement is possible.
][
  更精巧地应用蒙特卡洛积分技术，就能解决这些以及其他问题。后续章节将逐步介绍改进，以得到准确得多的结果。@light-transport-i-surface-reflection 至 @wavefront-rendering-on-gpus 的积分器汇集了这些成果。它们仍基于 `RandomWalkIntegrator` 的基本思想，但效率和稳健性都高得多。@fig:randomwalk-vs-path-integrator 将它与一种改进后的积分器比较，展示可实现的提升幅度。
]

#figure(
  table(
    columns: 2,
    [(a) #image("imgs/watercolor-randomwalk.png", width: 100%)], [(b) #image("imgs/watercolor-path.png", width: 100%)],
  ),
  caption: [
    #ez_caption[
      *Watercolor Scene Rendered Using 32 Samples per Pixel.* (a) Rendered using the `RandomWalkIntegrator`. (b) Rendered using the
      `PathIntegrator`, which follows the same general approach but uses more
      sophisticated Monte Carlo techniques. The `PathIntegrator` gives a
      substantially better image for roughly the same amount of work, with
      $54.5 times$ reduction in mean squared error.

    ][*以每像素 32 个样本渲染的 Watercolor 场景。*（a）使用 `RandomWalkIntegrator`；（b）使用 `PathIntegrator`。后者沿用相同的基本思路，但采用更精巧的蒙特卡洛技术，在大致相同的工作量下得到显著更好的图像，均方误差降至前者的 $1 / 54.5$。
    ]
  ],
  kind: image,
) <randomwalk-vs-path-integrator>

#include "supplements/1.3-expanded.typ"
