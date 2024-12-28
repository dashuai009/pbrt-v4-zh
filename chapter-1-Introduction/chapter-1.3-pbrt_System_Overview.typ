#import "../template.typ": parec, ez_caption

== pbrt: System Overview
<pbrt-system-overview>

#parec[
  pbrt is structured using standard object-oriented techniques: for each of a number of fundamental types, the system specifies an interface that implementations of that type must fulfill. For example,`pbrt` requires the implementation of a particular shape that represents geometry in a scene to provide a set of methods including one that returns the shape's bounding box, and another that tests for intersection with a given ray.In turn, the majority of the system can be implemented purely in terms of those interfaces; for example, the code that checks for occluding objects between a light source and a point being shaded calls the shape intersection methods without needing to consider which particular types of shapes are present in the scene.
][
  pbrt 使用标准的面向对象技术来构建：对于多种基本类型，系统指定了实现该类型必须满足的接口。例如，pbrt要求实现一个特定的形状来表示场景中的几何体，提供一组方法，包括返回形状的边界框的方法，以及测试与给定射线的交集的方法。反过来，系统的大部分可以纯粹以这些接口的形式实现；例如，检查光源与被着色点之间是否有遮挡物的代码调用形状交集方法，而不需要考虑场景中存在哪些特定类型的形状。
]


#figure(
  align(center)[#table(
      columns: (20%, 65%, 15%),
      align: (auto, auto, auto),
      table.header([Base type], [Source Files], [Section]),
      table.hline(),
      [#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/spectrum.h")[`base/spectrum.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.h")[`util/spectrum.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.cpp")[`util/spectrum.cpp`];], [#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#sec:spectrum")[4.5];],
      [#link("../Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/camera.h")[`base/camera.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cameras.h")[`cameras.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cameras.cpp")[`cameras.cpp`];], [#link("../Cameras_and_Film/Camera_Interface.html#sec:camera-model")[5.1];],
      [#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/shape.h")[`base/shape.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[`shapes.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[`shapes.cpp`];], [#link("../Shapes/Basic_Shape_Interface.html#sec:shape-interface")[6.1];],
      [#link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[`Primitive`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.h")[`cpu/primitive.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.cpp")[`cpu/primitive.cpp`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/accelerators.h")[`cpu/accelerators.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/accelerators.cpp")[`cpu/accelerators.cpp`];], [#link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#sec:primitives")[7.1];],
      [#link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/sampler.h")[`base/sampler.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/samplers.h")[`samplers.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/samplers.cpp")[`samplers.cpp`];], [#link("../Sampling_and_Reconstruction/Sampling_Interface.html#sec:sampling-interface")[8.3];],
      [#link("../Sampling_and_Reconstruction/Image_Reconstruction.html#Filter")[`Filter`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/filter.h")[`base/filter.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/filters.h")[`filters.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/filters.cpp")[`filters.cpp`];], [#link("../Sampling_and_Reconstruction/Image_Reconstruction.html#sec:filter-interface")[8.8.1];],
      [#link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/bxdf.h")[`base/bxdf.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/bxdfs.h")[`bxdfs.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/bxdfs.cpp")[`bxdfs.cpp`];], [#link("../Reflection_Models/BSDF_Representation.html#sec:bxdf-interface")[9.1.2];],
      [#link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[`Material`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/material.h")[`base/material.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.h")[`materials.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.cpp")[`materials.cpp`];], [#link("../Textures_and_Materials/Material_Interface_and_Implementations.html#sec:material-interface")[10.5];],
      [#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[`FloatTexture`];], [], [],
      [#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[`SpectrumTexture`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[`base/texture.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.h")[`textures.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.cpp")[`textures.cpp`];], [#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#sec:texture-interface")[10.3];],
      [#link("../Volume_Scattering/Media.html#Medium")[`Medium`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/medium.h")[`base/medium.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.h")[`media.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.cpp")[`media.cpp`];], [#link("../Volume_Scattering/Media.html#sec:media")[11.4];],
      [#link("../Light_Sources/Light_Interface.html#Light")[`Light`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/light.h")[`base/light.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.h")[`lights.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.cpp")[`lights.cpp`];], [#link("../Light_Sources/Light_Interface.html#sec:light")[12.1];],
      [#link("../Light_Sources/Light_Sampling.html#LightSampler")[`LightSampler`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/lightsampler.h")[`base/lightsampler.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.h")[`lightsamplers.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.cpp")[`lightsamplers.cpp`];], [#link("../Light_Sources/Light_Sampling.html#sec:light-sampling")[12.6];],
      [#link("<Integrator>")[`Integrator`];], [#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrators.h")[`cpu/integrators.h`];,
        #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrators.cpp")[`cpu/integrators.cpp`];], [#link("<sec:integrator-intro>")[1.3.3];],
    )],
  kind: table,
  caption: [#ez_caption[Main Interface Types. Most of pbrt is implemented in terms of 14 key base types, listed here. Implementations of each of these can easily be added to the system to extend its functionality.][
      主要的接口类型。大多数pbrt都是根据14种关键基类型实现的，如下所示。这些实现中的每一个都可以很容易地添加到系统中以扩展其功能。
    ]
  ],
)<plug-in-types>

#parec[
  There are a total of 14 of these key base types, summarized in @tbl:plug-in-types . Adding a new implementation of one of these types to the system is straightforward; the implementation must provide the required methods, it must be compiled and linked into the executable, and the scene object creation routines must be modified to create instances of the object as needed as the scene description file is parsed. Section #link("../Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[C.4] discusses extending the system in more detail.
][
  这些关键基本类型共有 14 种，总结在@tbl:plug-in-types 中。向系统添加这些类型的新实现是简单直接的；实现必须提供所需的方法，必须编译并链接到可执行文件中，场景对象创建例程必须修改以在解析场景描述文件时根据需要创建对象实例。第C.4节更详细地讨论了系统的扩展。
]

#parec[
  Conventional practice in C++ would be to specify the interfaces for each of these types using abstract base classes that define pure virtual functions and to have implementations inherit from those base classes and implement the required virtual functions. In turn, the compiler would take care of generating the code that calls the appropriate method, given a pointer to any object of the base class type. That approach was used in the three previous versions of `pbrt`, but the addition of support for rendering on graphics processing units (GPUs) in this version motivated a more portable approach based on #emph[tag-based dispatch];, where each specific type implementation is assigned a unique integer that determines its type at runtime.(See @dynamic-dispatch for more information about this topic.) The polymorphic types that are implemented in this way in `pbrt` are all defined in header files in the #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/")[`base/`] directory.
][
  在 C++ 中的常规做法是使用定义纯虚函数的抽象基类来指定每种类型的接口，并让实现从这些基类继承并实现所需的虚函数。反过来，编译器会负责生成调用基类类型的任何对象指针的适当方法的代码。这种方法在之前的三个版本的 `pbrt` 中被使用，但本版本中添加了对图形处理单元（GPU）渲染的支持，激发了一种基于 #emph[标签调度] 的更可移植的方法，其中每种特定类型的实现都被分配一个唯一的整数，以在运行时确定其类型。（有关此主题的更多信息，请参见@dynamic-dispatch）。以这种方式实现的多态类型在 `pbrt` 中都定义在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/")[`base/`] 目录的头文件中。
]

#parec[
  This version of `pbrt` is capable of running on GPUs that support C++17 and provide APIs for ray intersection tests.#footnote[At the time of writing, these capabilities are only available on NVIDIA hardware, but it would not be too difficult to port `pbrt` to other architectures that provide them in the future.] We have carefully designed the system so that almost all of `pbrt`'s implementation runs on both CPUs and GPUs, just as it is presented in @monte-carlo-integration through @light-sources. We will therefore generally say little about the CPU versus the GPU in most of the following.
][
  这个版本的 `pbrt` 能够在支持 C++17 并提供射线交叉测试 API 的 GPU 上运行。#footnote[在撰写本文时，这些功能仅在NVIDIA硬件上可用，但在未来，并不难将`pbrt`移植到提供这些接口的其他架构。] 我们已经仔细设计了这个系统，以确保 `pbrt` 的几乎所有实现都能在 CPU 和 GPU上运行，正如@monte-carlo-integration 到@light-sources 中所介绍的。因此，在接下来的大部分内容中，我们通常不会过多讨论 CPU 与 GPU 的区别。
]



#parec[
  The main differences between the CPU and GPU rendering paths in `pbrt` are in their data flow and how they are parallelized—effectively, how the pieces are connected together. Both the basic rendering algorithm described later in this chapter and the light transport algorithms described in @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering are only available on the CPU. The GPU rendering pipeline is discussed in @wavefront-rendering-on-gpus,though it, too, is also capable of running on the CPU (not as efficiently as the CPU-targeted light transport algorithms, however).
][
  `pbrt` 中 CPU 和 GPU 渲染路径的主要差异在于它们的数据流和并行化方式——实际上是各部分如何连接在一起的。本章稍后描述的基本渲染算法以及@light-transport-i-surface-reflection 和第@light-transport-ii-volume-rendering 中描述的光传输算法仅在 CPU 上可用。GPU 渲染管线在@wavefront-rendering-on-gpus 中讨论，尽管它也能在 CPU 上运行（但效率不及针对 CPU 的光传输算法）。
]

#parec[
  While `pbrt` can render many scenes well with its current implementation, it has frequently been extended by students,researchers, and developers. Throughout this section are a number of notable images from those efforts.@fig:competition-snow,@fig:ice-cave, and @fig:cotton-candy were each created by students in a rendering course where the final class project was to extend `pbrt` with new functionality in order to render an image that it could not have rendered before. These images are among the best from that course.
][
  虽然 `pbrt` 可以通过其当前实现很好地渲染许多场景，但它经常被学生、研究人员和开发者扩展。在这一部分中，有许多来自这些努力的值得注意的图像。@fig:competition-snow,@fig:ice-cave, and @fig:cotton-candy 都是由参加渲染课程的学生创建的，最后的课程项目是为 `pbrt` 添加新功能，以渲染它之前无法渲染的图像。这些图像是该课程中的佼佼者。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/nightsnow.png"),
  caption: [
    #ez_caption[
      Guillaume Poncin and Pramod Sharma extended `pbrt` in numerous ways, implementing a number of complex rendering algorithms, to make this prize-winning image for Stanford's CS348b rendering competition. The trees are modeled procedurally with L-systems, a glow image processing filter increases the apparent realism of the lights on the tree, snow was modeled procedurally with metaballs, and a subsurface scattering algorithm gave the snow its realistic appearance by accounting for the effect of light that travels beneath the snow for some distance before leaving it.
    ][
      Guillaume Poncin 和 Pramod Sharma 通过多种方式扩展了 `pbrt`，实现了许多复杂的渲染算法，制作了这张为斯坦福大学 CS348b 渲染比赛获奖的图像。树木是通过L-systems 程序化建模的，光晕图像处理滤镜增强了树上灯光的真实感，雪通过元球程序化建模，并通过次表面散射算法模拟光线在雪下传播一定距离后离开时的效果，使雪呈现出逼真的外观。
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
      Chenlin Meng、Hubert Teo 和 Jiren Zhu 渲染了这张看起来美味的棉花糖在茶杯中的图像，并赢得了 2018 年斯坦福大学 CS348b 渲染比赛的大奖。他们用多层曲线对棉花糖进行建模，然后在中心填充参与介质，以有效模拟其内部的散射效果。
    ]
  ],
) <cotton-candy>

#figure(
  image("../pbr-book-website/4ed/Introduction/crown.png"),
  caption: [
    #ez_caption[
      Martin Lubich modeled this scene of the Austrian Imperial Crown using Blender; it was originally rendered using LuxRender, which started out as a fork of the `pbrt-v1` codebase. The crown consists of approximately 3.5 million triangles that are illuminated by six area light sources with emission spectra based on measured data from a real-world light source. It was originally rendered with 1280 samples per pixel in 73 hours of computation on a quad-core CPU. On a modern GPU, `pbrt` renders this scene at the same sampling rate in 184 seconds.
    ][
      图 1.16：Martin Lubich 使用 Blender 建模了这幅奥地利帝国皇冠的场景；最初渲染是使用 LuxRender，这个渲染器最初是 pbrt-v1 代码库的一个分支。皇冠由大约 350 万个三角形组成，由六个基于真实光源测量数据的面光源照明。最初在四核 CPU 上以每像素 1280 个采样进行渲染，耗时 73 小时。而在现代 GPU 上，pbrt 以相同的采样率渲染该场景只需 184 秒。
    ]
  ],
) <crown>

=== Phases of Execution
<phases-of-execution>

#parec[
  `pbrt` can be conceptually divided into three phases of execution.First, it parses the scene description file provided by the user. The scene description is a text file that specifies the geometric shapes that make up the scene, their material properties, the lights that illuminate them, where the virtual camera is positioned in the scene,and parameters to all the individual algorithms used throughout the system. The scene file format is documented on the `pbrt` website,#link("https://pbrt.org")[pbrt.org];.
][
  `pbrt` 可以在概念上分为三个执行过程。首先，它解析用户提供的场景描述文件。场景描述是一个文本文件，指定构成场景的几何形状、它们的材质属性、照亮它们的光源、虚拟相机在场景中的位置，以及系统中使用的所有单独算法的参数。场景文件格式在 `pbrt` 网站 #link("https://pbrt.org")[pbrt.org] 上有文档说明。
]

#parec[
  The result of the parsing phase is an instance of the #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] class, which stores the scene specification, but not in a form yet suitable for rendering. In the second phase of execution,`pbrt` creates specific objects corresponding to the scene; for example, if a perspective projection has been specified, it is in this phase that a #link("../Cameras_and_Film/Projective_Camera_Models.html#PerspectiveCamera")[`PerspectiveCamera`] object corresponding to the specified viewing parameters is created.Previous versions of `pbrt` intermixed these first two phases, but for this version we have separated them because the CPU and GPU rendering paths differ in some of the ways that they represent the scene in memory.
][
  解析阶段的结果是一个 #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] 类的实例，它存储场景规范，但尚未转换为适合渲染的形式。在执行的第二阶段，`pbrt` 创建与场景对应的特定对象；例如，如果指定了透视投影，则在此阶段创建与指定视图参数对应的 #link("../Cameras_and_Film/Projective_Camera_Models.html#PerspectiveCamera")[`PerspectiveCamera`] 对象。以前版本的 `pbrt` 将这前两个阶段混合在一起，但在这个版本中我们将它们分开，因为 CPU 和 GPU 渲染路径在某些方面以不同的方式表示内存中的场景。
]

#parec[
  In the third phase, the main rendering loop executes. This phase is where `pbrt` usually spends the majority of its running time, and most of this book is devoted to code that executes during this phase. To orchestrate the rendering,`pbrt` implements an #emph[integrator];,so-named because its main task is to evaluate the integral in @eqt:rendering-equation.
][
  在第三阶段，主渲染循环执行。在这个阶段，`pbrt` 通常花费其大部分运行时间，本书的大部分内容都致力于在此阶段执行的代码。为了组织渲染，`pbrt` 实现了一个 #emph[integrator];，其名称来源于其主要任务是评估@eqt:rendering-equation 中的积分。
]


=== pbrt's main() Function


#parec[
  The `main()` function for the `pbrt` executable is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cmd/pbrt.cpp")[`cmd/pbrt.cpp`] in the directory that holds the `pbrt` source code,`src/pbrt` in the `pbrt` distribution. It is only a hundred and fifty or so lines of code,much of it devoted to processing command-line arguments and related bookkeeping.
][
  `pbrt` 可执行文件的 `main()` 函数定义在 `pbrt` 源代码目录 `src/pbrt` 中的文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cmd/pbrt.cpp")[`cmd/pbrt.cpp`] 中。它只有大约一百五十行代码，其中大部分用于处理命令行参数和相关的簿记。
]

```cpp
// <<main program>>=
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

#parec[
  Rather than operate on the `argv` values provided to the `main()` function directly,`pbrt` converts the provided arguments to a vector of `std::string`s. It does so not only for the greater convenience of the `string` class, but also to support non-ASCII character sets. Section #link("../Utilities/User_Interaction.html#sec:character-encoding")[B.3.2] has more information about character encodings and how they are handled in `pbrt`.
][
  `pbrt` 并不是直接操作提供给 `main()` 函数的 `argv` 值，而是将提供的参数转换为 `std::string` 的`vector`。这样做不仅是为了 `string` 类的更大便利性，也是为了支持非 ASCII 字符集。有关字符编码及其在 `pbrt` 中的处理的更多信息，请参见 #link("../Utilities/User_Interaction.html#sec:character-encoding")[B.3.2] 节。
]

```cpp
// <<Convert command-line arguments to vector of strings>>=
std::vector<std::string> args = GetCommandLineArguments(argv);
```

#parec[
  We will only include the definitions of some of the main function's fragments in the book text here. Some, such as the one that handles parsing command-line arguments provided by the user, are both simple enough and long enough that they are not worth the few pages that they would add to the book's length. However, we will include the fragment that declares the variables in which the option values are stored.
][
  在本书中，我们将仅包括一些主要函数片段的定义。对于某些片段，比如处理用户提供的命令行参数解析的片段，由于其既简单又较长，不值得为此增加几页的篇幅，因此不会包含在内。不过，我们会包括声明存储选项值的变量的片段。
]
```cpp
// <<Declare variables for parsed command line>>=
PBRTOptions options;
std::vector<std::string> filenames;
```

#parec[
  The #link("../Utilities/User_Interaction.html#GetCommandLineArguments")[`GetCommandLineArguments()`] function and #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] type appear in a #emph[mini-index] in the page margin, along with the number of the page where they are defined. The `mini-indices` have pointers to the definitions of almost all the functions, classes,methods, and member variables used or referred to on each page.(In the interests of brevity, we will omit very widely used classes such as `Ray` from the mini-indices, as well as types or methods that were just introduced in the preceding few pages.)
][
  #link("../Utilities/User_Interaction.html#GetCommandLineArguments")[`GetCommandLineArguments()`] 函数和 #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] 类型出现在页面边缘的小索引中，以及定义它们的页面编号。小索引提供了几乎所有在每页上使用或引用的函数、类、方法和成员变量的定义指针。（为了简洁，我们将省略非常广泛使用的类，如 `Ray`，以及在前几页中刚刚介绍的类型或方法。）
]

#parec[
  The #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] class stores various rendering options that are generally more suited to be specified on the command line rather than in scene description files—for example, how chatty `pbrt` should be about its progress during rendering. It is passed to the #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`] function, which aggregates the various system-wide initialization tasks that must be performed before any other work is done. For example, it initializes the logging system and launches a group of threads that are used for the parallelization of `pbrt`.
][
  #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#PBRTOptions")[`PBRTOptions`] 类存储各种渲染选项，这些选项通常更适合在命令行上指定，而不是在场景描述文件中指定——例如，`pbrt` 在渲染过程中应该多么详细地报告其进度。它被传递给 #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`] 函数，该函数汇总了在进行任何其他工作之前必须执行的各种系统级初始化任务。例如，它初始化日志系统并启动一组用于实现 `pbrt` 并行化的线程。
]

```cpp
// <<Initialize pbrt>>=
InitPBRT(options);
```


#parec[
  After the arguments have been parsed and validated, the #link("../Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParseFiles")[`ParseFiles()`] function takes over to handle the first of the three phases of execution described earlier. With the assistance of two classes,#link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#BasicSceneBuilder")[`BasicSceneBuilder`] and #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`];,which are respectively described in Sections #link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#sec:basic-scene-builder")[C.2] and #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#sec:basic-scene")[C.3];,it loops over the provided filenames, parsing each file in turn. If `pbrt` is run with no filenames provided, it looks for the scene description from standard input. The mechanics of tokenizing and parsing scene description files will not be described in this book, but the parser implementation can be found in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[`parser.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[`parser.cpp`] in the `src/pbrt` directory.
][
  在参数解析和验证之后，#link("../Processing_the_Scene_Description/Tokenizing_and_Parsing.html#ParseFiles")[`ParseFiles()`] 函数接管以处理前面描述的三个执行过程中的第一个阶段。在两个类 #link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#BasicSceneBuilder")[`BasicSceneBuilder`] 和 #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] 的帮助下，它遍历提供的文件名，依次解析每个文件。如果 `pbrt` 在没有提供文件名的情况下运行，它将从标准输入中查找场景描述。本书不会描述场景描述文件的词法分析和解析机制，但解析器实现可以在 `src/pbrt` 目录中的文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.h")[`parser.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/parser.cpp")[`parser.cpp`] 中找到。
]

```cpp
// <<Parse provided scene description files>>=
BasicScene scene;
BasicSceneBuilder builder(&scene);
ParseFiles(&builder, filenames);
```


#parec[
  After the scene description has been parsed, one of two functions is called to render the scene.#link("../Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`] supports both the CPU and GPU rendering paths, processing a million or so image samples in parallel. It is the topic of @wavefront-rendering-on-gpus .`RenderCPU()` renders the scene using an #link("<Integrator>")[`Integrator`] implementation and is only available when running on the CPU. It uses much less parallelism than #link("../Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`];,rendering only as many image samples as there are CPU threads in parallel.
][
  在场景描述被解析后，调用两个函数之一来渲染场景。#link("../Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`] 支持 CPU 和 GPU 的路径追踪渲染，并行处理大约一百万个图像样本。它是@wavefront-rendering-on-gpus 的主题。`RenderCPU()` 使用 #link("<Integrator>")[`Integrator`] 实现渲染场景，仅在 CPU 上运行时可用。它使用的并行性比 #link("../Wavefront_Rendering_on_GPUs/Mapping_Path_Tracing_to_the_GPU.html#RenderWavefront")[`RenderWavefront()`] 少得多，仅并行渲染与 CPU 线程数相同的图像样本。
]

#parec[
  Both of these functions start by converting the #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] into a form suitable for efficient rendering and then pass control to a processor-specific integrator.(More information about this process is available in Section #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#sec:basic-scene")[C.3];.) We will for now gloss past the details of this transformation in order to focus on the main rendering loop in `RenderCPU()`, which is much more interesting. For that, we will take the efficient scene representation as a given.
][
  这两个函数首先将 [`BasicScene`] 转换成适合高效渲染的形式，然后将控制权传递给特定处理器的积分器。（关于这个过程的更多信息可以在第 [C.3] 节找到；）现在，我们将略过这种转换的细节，以便专注于 `RenderCPU()` 中的主渲染循环，这更有趣。为此，我们将把高效的场景表示视为既定事实。
]

```cpp
// <<Render the scene>>=
if (Options->useGPU || Options->wavefront)
    RenderWavefront(scene);
else
    RenderCPU(scene);
```


#parec[
  After the image has been rendered,#link("../Utilities/System_Startup,_Cleanup,_and_Options.html#CleanupPBRT")[`CleanupPBRT()`] takes care of shutting the system down gracefully, including, for example, terminating the threads launched by #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`];.
][
  在图像渲染完成后，#link("../Utilities/System_Startup,_Cleanup,_and_Options.html#CleanupPBRT")[`CleanupPBRT()`] 负责平稳地关闭系统，例如结束由 #link("../Utilities/System_Startup,_Cleanup,_and_Options.html#InitPBRT")[`InitPBRT()`] 启动的线程。
]


=== Integrator Interface
<integrator-interface>
#parec[
  In the `RenderCPU()` rendering path, an instance of a class that implements the `Integrator` interface is responsible for rendering.Because `Integrator` implementations only run on the CPU, we will define `Integrator` as a standard base class with pure virtual methods.`Integrator` and the various implementations are each defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.h")[`cpu/integrator.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`];.
][
  在 `RenderCPU()`（CPU 渲染函数）渲染路径中，实现 `Integrator` 接口的类的实例负责渲染。由于 `Integrator` 的实现仅在 CPU 上运行，我们将 `Integrator` 定义为一个标准基类，并包含纯虚方法。`Integrator` 和各种实现分别定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.h")[`cpu/integrator.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`] 中。
]

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
  基类 `Integrator` 构造函数接受一个表示场景中所有几何对象的 `Primitive` 以及一个包含场景中所有灯光的单一数组。
]

```cpp
// <<Integrator Protected Methods>>=
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


#parec[
  Each geometric object in the scene is represented by a `Primitive`,which is primarily responsible for combining a `Shape` that specifies its geometry and a `Material` that describes its appearance (e.g., the object's color, or whether it has a dull or glossy finish). In turn, all the geometric primitives in a scene are collected into a single aggregate primitive that is stored in the `Integrator::aggregate` member variable.This aggregate is a special kind of primitive that itself holds references to many other primitives. The aggregate implementation stores all the scene's primitives in an acceleration data structure that reduces the number of unnecessary ray intersection tests with primitives that are far away from a given ray.Because it implements the `Primitive` interface, it appears no different from a single primitive to the rest of the system.
][
  场景中的每个几何对象由一个 `Primitive` 表示，主要负责组合指定几何形状的 `Shape` 和描述其外观的 `Material`（例如，物体的颜色，或是否具有哑光或光泽的表面）。反过来，场景中的所有几何基元被收集到一个单一的聚合体中，该聚合体存储在 `Integrator::aggregate` 成员变量中。 这个聚合体是一种特殊的基元类型，本身持有对许多其他基元的引用。聚合实现将场景的所有基元存储在一个加速数据结构中，以减少与给定光线相距较远的基元的不必要的光线相交测试次数。 因为它实现了 `Primitive` 接口，所以对系统的其他部分来说，它看起来与单个基元没有区别。
]

```cpp
// <<Integrator Public Members>>=
Primitive aggregate;
std::vector<Light> lights;
```


#parec[
  Each light source in the scene is represented by an object that implements the `Light` interface, which allows the light to specify its shape and the distribution of energy that it emits.Some lights need to know the bounding box of the entire scene, which is unavailable when they are first created. Therefore, the `Integrator` constructor calls their `Preprocess()` methods, providing those bounds.At this point any "infinite" lights are also stored in a separate array.This sort of light, which will be introduced in Section 12.5, models infinitely far away sources of light, which is a reasonable model for skylight as received on Earth's surface, for example.Sometimes it will be necessary to loop over just those lights, and for scenes with thousands of light sources it would be inefficient to loop over all of them just to find those.
][
  场景中的每个光源由一个实现 `Light` 接口的对象表示，该接口允许光源指定其形状和发出的能量分布。 有些灯光需要知道整个场景的边界框，而在它们首次创建时是不可用的。因此，`Integrator` 构造函数调用它们的 `Preprocess()` 方法，提供这些边界。 在此时，任何“无限光源”也被存储在一个单独的数组中。这种灯光模拟无限远的光源，例如地球表面接收到的天光。 有时需要仅遍历这些灯光（无限远光源），对于有成千上万个光源的场景，遍历所有灯光以找到这些灯光（无限远光源）是低效的。
]

```cpp
// <<Integrator constructor implementation>>=
Bounds3f sceneBounds = aggregate ? aggregate.Bounds() : Bounds3f();
for (auto &light : lights) {
    light.Preprocess(sceneBounds);
    if (light.Type() == LightType::Infinite)
        infiniteLights.push_back(light);
}
```

```cpp
std::vector<Light> infiniteLights;
```


#parec[
  `Integrator`s must provide an implementation of the `Render()` method,which takes no further arguments. This method is called by the `RenderCPU()` function once the scene representation has been initialized.The task of integrators is to render the scene as specified by the aggregate and the lights. Beyond that, it is up to the specific integrator to define what it means to render the scene, using whichever other classes that it needs to do so (e.g., a camera model).This interface is intentionally very general to permit a wide range of implementations—for example, one could implement an `Integrator` that measures light only at a sparse set of points distributed through the scene rather than generating a regular 2D image.
][
  `Integrator` 必须提供 `Render()` 方法的实现，该方法不需要进一步的参数。一旦场景表示被初始化，`RenderCPU()` 函数就会调用此方法。 积分器的任务是根据聚合体和灯光渲染场景。除此之外，具体的积分器可以使用它需要的其他类来定义渲染场景的含义（例如，使用相机模型）。 这个接口故意非常通用，以允许广泛的实现范围——例如，可以实现一个 `Integrator`，它只在场景中分布的稀疏点集上测量光线，而不是生成常规的二维图像。
]

```cpp
// <<Integrator Public Methods>>=
virtual void Render() = 0;
```

#parec[
  The `Integrator` class provides two methods related to ray–primitive intersection for use of its subclasses.`Intersect()` takes a ray and a maximum parametric distance `tMax`, traces the given ray into the scene,and returns a `ShapeIntersection` object corresponding to the closest primitive that the ray hit, if there is an intersection along the ray before `tMax`.(The `ShapeIntersection` structure is defined in @intersection-tests_chapter_6_1 .) One thing to note is that this method uses the type `pstd::optional` for the return value rather than `std::optional` from the C++ standard library; we have reimplemented parts of the standard library in the `pstd` namespace for reasons that are discussed in @pstd.
][
  `Integrator` 类提供了两个与光线-基元相交相关的方法供其子类使用。`Intersect()` 接受一条光线和一个最大参数距离 `tMax`，将给定的光线追踪到场景中，并返回一个与光线相交的最近基元对应的 `ShapeIntersection`（形状相交）对象（如果在 `tMax` 之前沿光线有相交）。（`ShapeIntersection` 结构在@intersection-tests_chapter_6_1 中定义。）需要注意的是，此方法使用类型 `pstd::optional` 作为返回值，而不是 C++ 标准库中的 `std::optional`；我们在 `pstd` 命名空间中重新实现了标准库的部分内容，原因将@pstd 中讨论。
]

```cpp
// <<Integrator Method Definitions>>=
pstd::optional<ShapeIntersection> Integrator::Intersect(const Ray &ray, Float tMax) const {
    if (aggregate) return aggregate.Intersect(ray, tMax);
    else           return {};
}
```


#parec[
  Also note the capitalized floating-point type `Float` in `Intersect()`'s signature: almost all floating-point values in `pbrt` are declared as `Float`s.(The only exceptions are a few cases where a 32-bit `float` or a 64-bit `double` is specifically needed (e.g., when saving binary values to files).) Depending on the compilation flags of `pbrt`,`Float` is an alias for either `float` or `double`, though single precision `float` is almost always sufficient in practice.The definition of `Float` is in the #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] header file, which is included by all other source files in `pbrt`.
][
  还要注意 `Intersect()` 签名中的大写浮点类型 `Float`：`pbrt` 中几乎所有的浮点值都声明为 `Float`。（唯一的例外是某些情况下需要特定的 32 位 `float` 或 64 位 `double`（例如，当将二进制值保存到文件时）。）根据 `pbrt` 的编译标志，`Float` 是 `float` 或 `double` 的别名，尽管单精度 `float` 在实践中几乎总是足够的。`Float` 的定义在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] 头文件中，该文件被 `pbrt` 中的所有其他源文件包含。
]
```cpp
// <<Float Type Definitions>>=
#ifdef PBRT_FLOAT_AS_DOUBLE
    using Float = double;
#else
    using Float = float;
#endif
```


#parec[
  `Integrator::IntersectP()` is closely related to the `Intersect()` method. It checks for the existence of intersections along the ray but only returns a Boolean indicating whether an intersection was found.(The "P" in its name indicates that it is a function that evaluates a predicate, using a common naming convention from the `Lisp` programming language.) Because it does not need to search for the closest intersection or return additional geometric information about intersections,`IntersectP()` is generally more efficient than `Integrator::Intersect()`.This routine is used for shadow rays.
][
  `Integrator::IntersectP()` 与 `Intersect()` 方法密切相关。它检查沿光线是否存在相交，但仅返回一个布尔值，指示是否找到了相交。（其名称中的“P”表示它是一个评估谓词的函数，使用了 `Lisp` 编程语言中的常见命名约定。）因为它不需要搜索最近的相交或返回有关相交的附加几何信息，`IntersectP()` 通常比 `Integrator::Intersect()` 更有效。 此例程通常用于计算阴影光线的相交情况。
]

```cpp
// <<Integrator Method Definitions>>+=
bool Integrator::IntersectP(const Ray &ray, Float tMax) const {
    if (aggregate) return aggregate.IntersectP(ray, tMax);
    else           return false;
}
```



=== ImageTileIntegrator and the Main Rendering Loop
<imagetileintegrator-and-the-main-rendering-loop>

#parec[
  Before implementing a basic integrator that simulates light transport to render an image, we will define two `Integrator` subclasses that provide additional common functionality used by that integrator as well as many of the integrator implementations to come. We start with `ImageTileIntegrator`, which inherits from `Integrator`. The next section defines `RayIntegrator`, which inherits from `ImageTileIntegrator`.
][
  在实现一个用于模拟光传输以渲染图像的基本积分器之前，我们将定义两个 `Integrator` 子类，这些子类提供了该积分器以及许多即将实现的积分器所使用的额外通用功能。我们从继承自 `Integrator` 的 `ImageTileIntegrator` 开始。下一节将定义 `RayIntegrator`，它继承自 `ImageTileIntegrator`。
]

#parec[
  All of `pbrt`'s CPU-based integrators render images using a camera model to define the viewing parameters, and all parallelize rendering by splitting the image into tiles and having different processors work on different tiles. Therefore,`pbrt` includes an `ImageTileIntegrator` that provides common functionality for those tasks.
][
  所有 `pbrt` 的基于 CPU 的积分器都使用相机模型来定义视图参数，并通过将图像分割成瓦片以并行化渲染。因此，`pbrt` 包含一个 `ImageTileIntegrator`，为这些分割和并行化任务提供通用功能。
]

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
  In addition to the aggregate and the lights, the `ImageTileIntegrator` constructor takes a Camera that specifies the viewing and lens parameters such as position, orientation, focus, and field of view.`Film` stored by the camera handles image storage. The `Camera` classes are the subject of most of @cameras-and-film , and `Film` is described in Section 5.4. The Film is responsible for writing the final image to a file.
][
  除了聚合体和灯光，`ImageTileIntegrator` 的构造函数还接收一个 Camera，它指定了视角和镜头参数，例如位置、方向、焦点和视场。相机存储的 `Film` 处理图像存储。`Camera`类将在@cameras-and-film 的主要部分中讨论，`Film` 则在@film-and-imaging 中进行描述。Film 负责将最终图像写入文件。
]

#parec[
  The constructor also takes a `Sampler`; its role is more subtle, but its implementation can substantially affect the quality of the images that the system generates. First, the sampler is responsible for choosing the points on the image plane that determine which rays are initially traced into the scene. Second, it is responsible for supplying random sample values that are used by integrators for estimating the value of the light transport integral,@eqt:rendering-equation. For example, some integrators need to choose random points on light sources to compute illumination from area lights. Generating a good distribution of these samples is an important part of the rendering process that can substantially affect overall efficiency. this topic is the main focus of @sampling-and-reconstruction.
][
  构造函数还接受一个 `Sampler`，其作用更为微妙，但其实现可以显著影响系统生成图像的质量。首先，采样器负责选择图像平面上的点，这些点决定了哪些光线最初被追踪到场景中。其次，它负责提供随机样本值，这些值由积分器用于估计光传输积分的值，@eqt:rendering-equation。例如，一些积分器需要选择光源上的随机点来计算区域光的照明。生成这些样本的良好分布是渲染过程中一个重要的部分，可以显著影响整体效率。@sampling-and-reconstruction 主要关注这个主题。
]

```cpp
<<ImageTileIntegrator Public Methods>>=
ImageTileIntegrator(Camera camera, Sampler sampler,
        Primitive aggregate, std::vector<Light> lights)
    : Integrator(aggregate, lights), camera(camera),
      samplerPrototype(sampler) {}
<<ImageTileIntegrator Protected Members>>=
Camera camera;
Sampler samplerPrototype;
```

#parec[
  For all of `pbrt`'s integrators, the final color computed at each pixel is based on random sampling algorithms. If each pixel's final value is computed as the average of multiple samples, then the quality of the image improves. At low numbers of samples, sampling error manifests itself as grainy high-frequency noise in images, though error goes down at a predictable rate as the number of samples increases.(This topic is discussed in more depth in @error-in-monte-carlo-estimators.) `ImageTileIntegrator::Render()` therefore renders the image in waves of a few samples per pixel. For the first two waves, only a single sample is taken in each pixel. In the next wave, two samples are taken, with the number of samples doubling after each wave up to a limit. While it makes no difference to the final image if the image was rendered in waves or with all the samples being taken in a pixel before moving on to the next one, this organization of the computation means that it is possible to see previews of the final image during rendering where all pixels have some samples, rather than a few pixels having many samples and the rest having none.
][
  对于所有的 `pbrt` 集成器，每个像素的最终颜色计算都是基于随机采样算法的。如果每个像素的最终值是多个样本的平均值，那么图像质量会有所提升。在低样本数量时，采样误差表现为图像中的颗粒状高频噪声，但随着样本数量的增加，误差会以可预测的速率下降。（这个主题将在@error-in-monte-carlo-estimators 中进行更深入的讨论。）因此，`ImageTileIntegrator::Render()` 以每像素少量样本的方式分批次渲染图像。在前两批次中，每个像素只进行一次采样。在接下来的批次中，每个像素进行两次采样，之后每个批次的样本数量翻倍，直到达到一个上限。虽然无论图像是以分批次方式渲染还是在移动到下一个像素之前对每个像素进行所有采样，最终图像没有区别，但这种计算组织方式意味着在渲染过程中可以看到最终图像的预览，其中所有像素都有一些样本，而不是少数像素有很多样本而其他像素没有任何样本。
]


#parec[
  Because `pbrt` is parallelized to run using multiple threads, there is a balance to be struck with this approach. There is a cost for threads to acquire work for a new image tile, and some threads end up idle at the end of each wave once there is no more work for them to do but other threads are still working on the tiles they have been assigned. These considerations motivated the capped doubling approach.
][
  由于 `pbrt` 是并行化运行的，可以使用多个线程，因此这种方法需要在平衡上做出权衡。线程获取新图像块工作的成本是存在的，在每个批次结束时，一些线程可能会因为没有更多的工作可做而处于空闲状态，而其他线程仍在处理它们分配到的图像块。这些考虑促使了限制性样本翻倍方法的使用。
]

```cpp
<<ImageTileIntegrator Method Definitions>>=
void ImageTileIntegrator::Render() {
    <<Declare common variables for rendering image in tiles>>
    <<Render image in waves>>
}
```


#parec[
  Before rendering begins, a few additional variables are required.First, the integrator implementations will need to allocate small amounts of temporary memory to store surface scattering properties in the course of computing each ray's contribution. The large number of resulting allocations could easily overwhelm the system's regular memory allocation routines (e.g.,`new`), which must coordinate multi-threaded maintenance of elaborate data structures to track free memory. A naive implementation could potentially spend a fairly large fraction of its computation time in the memory allocator.
][
  在渲染开始之前，需要一些额外的变量。首先，积分器实现需要分配少量的临时内存，用于在计算每条光线的贡献时存储表面散射属性。由此产生的大量内存分配可能会轻易压垮系统的常规内存分配程序（例如，`new`操作），因为这些程序必须协调多线程的数据结构维护，以追踪空闲内存。一个简单的实现可能会在内存分配器上花费相当大比例的计算时间。
]


#parec[
  To address this issue, pbrt provides a ScratchBuffer class that manages a small preallocated buffer of memory. ScratchBuffer allocations are very efficient, just requiring the increment of an offset. The ScratchBuffer does not allow independently freeing allocations; instead, all must be freed at once, but doing so only requires resetting that offset.
][
  为了解决这个问题，pbrt 提供了一个 `ScratchBuffer` 类，它管理一个预先分配的小内存缓冲区。`ScratchBuffer` 的内存分配非常高效，只需增加一个偏移量即可。`ScratchBuffer` 不允许独立地释放内存分配，而是必须一次性释放所有内存，但这只需重置该偏移量。
]

#parec[
  Because ScratchBuffers are not safe for use by multiple threads at the same time, an individual one is created for each thread using the ThreadLocal template class. Its constructor takes a lambda function that returns a fresh instance of the object of the type it manages; here, calling the default ScratchBuffer constructor is sufficient. ThreadLocal then handles the details of maintaining distinct copies of the object for each thread, allocating them on demand.
][
  由于 `ScratchBuffers` 不适合多线程同时使用，因此使用 `ThreadLocal` 模板类为每个线程创建一个独立的 `ScratchBuffer`。它的构造函数接受一个 lambda 函数，该函数返回该类型对象的新实例；在这里，调用默认的 `ScratchBuffer` 构造函数就足够了。`ThreadLocal` 然后处理为每个线程维护独立的对象副本的细节，并在需要时分配它们。
]
```
<<Declare common variables for rendering image in tiles>>=
ThreadLocal<ScratchBuffer> scratchBuffers(
    []() { return ScratchBuffer(); } );

```

#parec[
  Most Sampler implementations find it useful to maintain some state, such as the coordinates of the current pixel. This means that multiple threads cannot use a single Sampler concurrently and ThreadLocal is also used for Sampler management. Samplers provide a Clone() method that creates a new instance of their sampler type. The Sampler first provided to the ImageTileIntegrator constructor, samplerPrototype, provides those copies here.
][
  大多数 `Sampler` 实现会维护一些状态，例如当前像素的坐标。这意味着多个线程不能同时使用单个 `Sampler`，因此 `ThreadLocal` 也用于 `Sampler` 的管理。`Sampler` 提供一个 `Clone()` 方法，用于创建其类型的新实例。首先提供给 `ImageTileIntegrator` 构造函数的 `samplerPrototype` 会在这里提供这些副本。
]

```cpp
<<Declare common variables for rendering image in tiles>>+=
ThreadLocal<Sampler> samplers(
    [this]() { return samplerPrototype.Clone(); });
```

#parec[
  It is helpful to provide the user with an indication of how much of the rendering work is done and an estimate of how much longer it will take. This task is handled by the ProgressReporter class, which takes as its first parameter the total number of items of work. Here, the total amount of work is the number of samples taken in each pixel times the total number of pixels. It is important to use 64-bit precision to compute this value, since a 32-bit int may be insufficient for high-resolution images with many samples per pixel.
][
  为用户提供渲染工作完成程度的指示和估计剩余时间是有帮助的。这项任务由 `ProgressReporter` 类处理，它的第一个参数是总的工作项数。这里，总的工作量是每个像素的采样数乘以像素总数。使用 64 位精度来计算这个值是很重要的，因为对于具有多个像素样本的高分辨率图像，32 位整数可能不足够。
]

```cpp
<<Declare common variables for rendering image in tiles>>+=
Bounds2i pixelBounds = camera.GetFilm().PixelBounds();
int spp = samplerPrototype.SamplesPerPixel();
ProgressReporter progress(int64_t(spp) * pixelBounds.Area(), "Rendering",
                          Options->quiet);
```

#parec[
  In the following, the range of samples to be taken in the current wave is given by waveStart and waveEnd; nextWaveSize gives the number of samples to be taken in the next wave.
][
  在接下来的代码中，当前波次的采样范围由 `waveStart` 和 `waveEnd` 给出；`nextWaveSize` 给出了下一波次要采样的数量。
]

```
<<Declare common variables for rendering image in tiles>>+=
int waveStart = 0, waveEnd = 1, nextWaveSize = 1;
```

#parec[
  With these variables in hand, rendering proceeds until the required number of samples have been taken in all pixels.
][
  有了这些变量，渲染将继续，直到所有像素都达到所需的采样数量。
]

```cpp
<<Render image in waves>>=
while (waveStart < spp) {
    <<Render current wave's image tiles in parallel>>
    <<Update start and end wave>>
    <<Optionally write current image to disk>>
}
```

#parec[
  The `ParallelFor2D()` function loops over image tiles, running multiple loop iterations concurrently; it is part of the parallelism-related utility functions that are introduced in Section B.6. A C++ lambda expression provides the loop body.`ParallelFor2D()` automatically chooses a tile size to balance two concerns: on one hand, we would like to have significantly more tiles than there are processors in the system. It is likely that some of the tiles will take less processing time than others, so if there was for example a 1:1 mapping between processors and tiles, then some processors will be idle after finishing their work while others continue to work on their region of the image.(Figure 1.17 graphs the distribution of time taken to render tiles of an example image, illustrating this concern.) On the other hand, having too many tiles also hurts efficiency. There is a small fixed overhead for a thread to acquire more work in the parallel for loop and the more tiles there are, the more times this overhead must be paid.`ParallelFor2D()` therefore chooses a tile size that accounts for both the extent of the region to be processed and the number of processors in the system.
][
  `ParallelFor2D()` 函数遍历图像瓦片，同时运行多个循环迭代；它是并行相关的实用函数之一，介绍见 B.6 节。C++ lambda 表达式提供了循环体。`ParallelFor2D()` 自动选择瓦片大小，以平衡两个因素：一方面，我们希望瓦片数量远超过系统中的处理器数量。由于某些瓦片的处理时间可能少于其他瓦片，因此如果处理器和瓦片之间是 1:1 的映射，那么在完成工作后，一些处理器会闲置，而其他处理器则继续处理其图像区域。（图 1.17 描绘了渲染示例图像瓦片的时间分布，说明了这一问题。）另一方面，瓦片太多也会影响效率。并行 for 循环中线程获取更多工作时存在一个小的固定开销，瓦片越多，这种开销就需要付出更多次。因此，`ParallelFor2D()` 选择的瓦片大小既考虑了处理区域的范围，也考虑了系统中的处理器数量。
]

```cpp
<<Render current wave's image tiles in parallel>>=
ParallelFor2D(pixelBounds, [&](Bounds2i tileBounds) {
    <<Render image tile given by tileBounds>>
});
```

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f17.svg"),
  caption: [
    #ez_caption[*Histogram of Time Spent Rendering Each Tile for the Scene in @fig:intro-raytracing-example.* The horizontal axis measures time in seconds. Note the wide variation in execution time, illustrating that different parts of the image required substantially different amounts of computation. ][*为@fig:intro-raytracing-example 场景渲染每个瓦片所花费时间的直方图。*横轴测量时间（以秒为单位）。注意执行时间的广泛变化，这表明图像的不同部分需要相当不同的计算量。 ]
  ],
)<task-time-distribution>


#parec[
  Given a tile to render, the implementation starts by acquiring the ScratchBuffer and Sampler for the currently executing thread. As described earlier, the ThreadLocal::Get() method takes care of the details of allocating and returning individual ones of them for each thread.
][
  给定一个要渲染的瓦片，实现首先获取当前线程的 `ScratchBuffer` 和 `Sampler`。如前所述，`ThreadLocal::Get()` 方法处理了为每个线程分配并返回单独对象的细节。
]

#parec[
  With those in hand, the implementation loops over all the pixels in the tile using a range-based for loop that uses iterators provided by the Bounds2 class before informing the ProgressReporter about how much work has been completed.
][
  有了这些对象，代码使用基于范围的 for 循环遍历瓦片中的所有像素，该循环使用 `Bounds2` 类提供的迭代器，并在完成工作后通知 `ProgressReporter`。
]

```cpp
<<Render image tile given by tileBounds>>=
ScratchBuffer &scratchBuffer = scratchBuffers.Get();
Sampler &sampler = samplers.Get();
for (Point2i pPixel : tileBounds) {
    <<Render samples in pixel pPixel>>
}
progress.Update((waveEnd - waveStart) * tileBounds.Area());
```

#parec[
  Given a pixel to take one or more samples in, the thread's Sampler is notified that it should start generating samples for the current pixel via StartPixelSample(), which allows it to set up any internal state that depends on which pixel is currently being processed. The integrator's EvaluatePixelSample() method is then responsible for determining the specified sample's value, after which any temporary memory it may have allocated in the ScratchBuffer is freed with a call to ScratchBuffer::Reset().
][
  给定一个要采样的像素，线程的 `Sampler` 被通知开始为当前像素生成样本，通过 `StartPixelSample()` 方法，这使得它可以设置依赖于当前处理的像素的任何内部状态。积分器的 `EvaluatePixelSample()` 方法负责确定指定样本的值，之后它可以通过调用 `ScratchBuffer::Reset()` 来释放所有可能在 `ScratchBuffer` 中分配的临时内存。
]

```cpp
<<Render samples in pixel pPixel>>=
for (int sampleIndex = waveStart; sampleIndex < waveEnd; ++sampleIndex) {
    sampler.StartPixelSample(pPixel, sampleIndex);
    EvaluatePixelSample(pPixel, sampleIndex, sampler, scratchBuffer);
    scratchBuffer.Reset();
}
```

#parec[
  Having provided an implementation of the pure virtual `Integrator::Render()` method, ImageTileIntegrator now imposes the requirement on its subclasses that they implement the following `EvaluatePixelSample()` method.
][
  在提供了纯虚拟的 `Integrator::Render()` 方法的实现后，`ImageTileIntegrator`要求其子类实现如下 `EvaluatePixelSample()` 方法。
]
```cpp
<<ImageTileIntegrator Public Methods>>+=
virtual void EvaluatePixelSample(Point2i pPixel, int sampleIndex,
    Sampler sampler, ScratchBuffer &scratchBuffer) = 0;
```

#parec[
  After the parallel for loop for the current wave completes, the range of sample indices to be processed in the next wave is computed.
][
  当前波次的并行 for 循环完成后，计算下一个波次要处理的样本索引范围。
]

```cpp
<<Update start and end wave>>=
waveStart = waveEnd;
waveEnd = std::min(spp, waveEnd + nextWaveSize);
nextWaveSize = std::min(2 * nextWaveSize, 64);
```

#parec[
  If the user has provided the –write-partial-images command-line option, the in-progress image is written to disk before the next wave of samples is processed. We will not include here the fragment that takes care of this,
][
  如果用户提供了 `--write-partial-images` 命令行选项，则在处理下一个波次的样本之前，将进度中的图像写入磁盘。我们不会在此包含处理此操作的代码片段，即 `<<Optionally write current image to disk>>.`。
]



=== 1.3.5 RayIntegrator Implementation
<rayintegrator-implementation>
#parec[
  Just as the `ImageTileIntegrator` centralizes functionality related to integrators that decompose the image into tiles,`RayIntegrator` provides commonly used functionality to integrators that trace ray paths starting from the camera. All of the integrators implemented in @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering inherit from `RayIntegrator`.
][
  正如 `ImageTileIntegrator` 集中处理与将图像分解为瓦片相关的积分器功能一样，`RayIntegrator` 为从相机出发追踪光线路径的积分器提供了常用功能。在@light-transport-i-surface-reflection 和 @light-transport-ii-volume-rendering 中实现的所有积分器都继承自 `RayIntegrator`。
]

```cpp
 class RayIntegrator : public ImageTileIntegrator {
   public:
     <<RayIntegrator Public Methods>>
     RayIntegrator(Camera camera, Sampler sampler, Primitive aggregate, std::vector<Light> lights)
            : ImageTileIntegrator(camera, sampler, aggregate, lights) {}
        void EvaluatePixelSample(Point2i pPixel, int sampleIndex,
                                 Sampler sampler, ScratchBuffer &scratchBuffer) final;
        virtual SampledSpectrum Li(
            RayDifferential ray, SampledWavelengths &lambda, Sampler sampler,
            ScratchBuffer &scratchBuffer, VisibleSurface *visibleSurface) const = 0;
 };
```

#parec[
  Its constructor does nothing more than pass along the provided objects to the `ImageTileIntegrator` constructor.
][
  其构造函数只是将提供的对象传递给 `ImageTileIntegrator` 的构造函数。
]

```cpp
RayIntegrator(Camera camera, Sampler sampler, Primitive aggregate,
              std::vector<Light> lights)
    : ImageTileIntegrator(camera, sampler, aggregate, lights) {}
```


#parec[
  `RayIntegrator` implements the pure virtual `EvaluatePixelSample()` method from `ImageTileIntegrator`. At the given pixel, it uses its `Camera` and `Sampler` to generate a ray into the scene and then calls the `Li()` method, which is provided by the subclass, to determine the amount of light arriving at the image plane along that ray. As we will see in following chapters, the units of the value returned by this method are related to the incident spectral radiance at the ray origin,which is generally denoted by the symbol $L_i$ in equations—thus, the method name. This value is passed to the `Film`, which records the ray's contribution to the image.
][
  `RayIntegrator` 实现了 `ImageTileIntegrator` 的纯虚方法 `EvaluatePixelSample()`。在给定的像素处，它使用其 `Camera` 和 `Sampler` 生成一条射入场景的光线，然后调用由子类提供的 `Li()` 方法，以确定沿该光线到达图像平面的光量。如后续章节所示，该方法返回值的单位与光线起点的入射光谱辐亮度有关，通常在公式中用符号 $L_i$ 表示——因此得名。此值被传递给 `Film`，以记录光线对图像的贡献。
]

#parec[
  @fig:main-render-loop-classes summarizes the main classes used in this method and the flow of data among them.
][
  @fig:main-render-loop-classes 总结了该方法中的主要类它们中的数据流转。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f18.svg"),
  caption: [
    #ez_caption[*Class Relationships for RayIntegrator::EvaluatePixelSample()'s computation.* The Sampler provides sample values for each image sample to be taken. The Camera turns a sample into a corresponding ray from the film plane, and the Li() method computes the radiance along that ray arriving at the film. The sample and its radiance are passed to the Film, which stores their contribution in an image.][*RayIntegrator::EvaluatePixelSample() 计算的类关系图。*Sampler 为每个图像样本提供采样值。Camera 将一个样本转换为从感光平面发出的相应光线，Li() 方法则计算沿着该光线到达感光平面的辐射亮度。然后，该样本及其辐射亮度被传递给 Film，Film 将它们的贡献存储在图像中。]
  ],
) <main-render-loop-classes>

```cpp
<<RayIntegrator Method Definitions>>=
void RayIntegrator::EvaluatePixelSample(Point2i pPixel, int sampleIndex,
        Sampler sampler, ScratchBuffer &scratchBuffer) {
    <<Sample wavelengths for the ray>>
    <<Initialize CameraSample for current sample>>
    <<Generate camera ray for current sample>>
    <<Trace cameraRay if valid>>
    <<Add camera ray's contribution to image>>
}
```


#parec[
  Each ray carries radiance at a number of discrete wavelengths $lambda$ (four, by default). When computing the color at each pixel,`pbrt` chooses different wavelengths at different pixel samples so that the final result better reflects the correct result over all wavelengths. To choose these wavelengths, a sample value `lu` is first provided by the `Sampler`. This value will be uniformly distributed and in the range $\[ 0 , 1 \)$. The `Film::SampleWavelengths()` method then maps this sample to a set of specific wavelengths, taking into account its model of film sensor response as a function of wavelength. Most `Sampler` implementations ensure that if multiple samples are taken in a pixel, those samples are in the aggregate well distributed over $\[ 0 , 1 \)$. In turn, they ensure that the sampled wavelengths are also well distributed across the range of valid wavelengths, improving image quality.
][
  每条光线在若干个离散波长 $lambda$ （默认四个）上携带辐亮度。在计算每个像素颜色时，`pbrt` 在不同的像素样本上选择不同的波长，以便最终结果更好地反映所有波长的正确结果。为了选择这些波长，首先由 `Sampler` 提供样本值 `lu`。此值将均匀分布在 $\[ 0 , 1 \)$ 范围内。`Film::SampleWavelengths()` 方法然后将此样本映射到一组特定波长，考虑到其对波长的胶片传感器响应模型。大多数 `Sampler` 实现确保如果在一个像素中获取多个样本，这些样本在整体上在 $\[0 , 1\)$ 范围内分布良好。反过来，它们确保采样的波长在有效波长范围内也分布良好，从而提高图像质量。
]

```cpp
Float lu = sampler.Get1D();
SampledWavelengths lambda = camera.GetFilm().SampleWavelengths(lu);
```


#parec[
  The `CameraSample` structure records the position on the film for which the camera should generate a ray. This position is affected by both a sample position provided by the sampler and the reconstruction filter that is used to filter multiple sample values into a single value for the pixel.`GetCameraSample()` handles those calculations.`CameraSample` also stores a time that is associated with the ray as well as a lens position sample, which are used when rendering scenes with moving objects and for camera models that simulate non-pinhole apertures, respectively.
][
  `CameraSample` 结构记录了相机应该为其生成光线的胶片上的位置。此位置受采样器提供的样本位置和用于将多个样本值合并为单一像素值的重建滤波器的影响。`GetCameraSample()` 处理这些计算。`CameraSample` 还存储与光线相关的时间以及镜头位置样本，分别用于渲染带有移动物体的场景和模拟非针孔光圈的相机模型。
]

```cpp
Filter filter = camera.GetFilm().GetFilter();
CameraSample cameraSample = GetCameraSample(sampler, pPixel, filter);
```


#parec[
  The `Camera` interface provides two methods to generate rays: `GenerateRay()`, which returns the ray for a given image sample position, and `GenerateRayDifferential()`, which returns a #emph[ray
differential];, which incorporates information about the rays that the camera would generate for samples that are one pixel away on the image plane in both the $x$ and $y$ directions. Ray differentials are used to get better results from some of the texture functions defined in Chapter~#link("../Textures_and_Materials.html#chap:texture")[10];, by making it possible to compute how quickly a texture varies with respect to the pixel spacing, which is a key component of texture antialiasing.
][
  `Camera` 接口提供了两种生成光线的方法：`GenerateRay()` 返回给定图像样本位置的光线，而 `GenerateRayDifferential()` 返回一个#emph[光线差分];，其中包含相机为图像平面上在 $x$ 和 $y$ 方向上相隔一个像素的样本生成的光线的信息。光线差分用于从第 #link("../Textures_and_Materials.html#chap:texture")[10] 章定义的一些纹理函数中获得更好的结果，使得可以计算纹理相对于像素间距的变化速度，这是纹理抗锯齿的关键组成部分。
]

#parec[
  Some `CameraSample` values may not correspond to valid rays for a given camera.

  Therefore,`pstd::optional` is used for the `CameraRayDifferential` returned by the camera.
][
  某些 `CameraSample` 值可能不对应于给定相机的有效光线。

  因此，`pstd::optional` 用于相机返回的 `CameraRayDifferential`。
]

```cpp
pstd::optional<CameraRayDifferential> cameraRay =
    camera.GenerateRayDifferential(cameraSample, lambda);
```

#parec[
  If the camera ray is valid, it is passed along to the `RayIntegrator` subclass's `Li()` method implementation after some additional preparation. In addition to returning the radiance along the ray `L`,the subclass is also responsible for initializing an instance of the `VisibleSurface` class, which records geometric information about the surface the ray intersects (if any) at each pixel for the use of `Film` implementations like the `GBufferFilm` that store more information than just color at each pixel.
][
  如果相机光线有效，它将在额外准备后传递给 `RayIntegrator` 子类的 `Li()` 方法实现。除了返回沿光线的辐亮度 `L` 外，子类还负责初始化 `VisibleSurface` 类的实例，该实例记录光线在每个像素处与之相交的表面的几何信息（如果有），以供像 `GBufferFilm` 这样的 `Film` 实现使用，这些实现存储的不仅仅是每个像素的颜色。
]

```cpp
SampledSpectrum L(0.);
VisibleSurface visibleSurface;
if (cameraRay) {
    <<Scale camera ray differentials based on image sampling rate>>
    Float rayDiffScale =
           std::max<Float>(.125f, 1 / std::sqrt((Float)sampler.SamplesPerPixel()));
    cameraRay->ray.ScaleDifferentials(rayDiffScale);
    <<Evaluate radiance along camera ray>>
    bool initializeVisibleSurface = camera.GetFilm().UsesVisibleSurface();
    L = cameraRay->weight *
        Li(cameraRay->ray, lambda, sampler, scratchBuffer,
           initializeVisibleSurface ? &visibleSurface : nullptr);
    <<Issue warning if unexpected radiance value is returned>>
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
  在光线传递给 `Li()` 方法之前，`ScaleDifferentials()` 方法缩放差分光线，以考虑在每个像素中获取多个样本时胶片平面上样本之间的实际间距。
]


```cpp
Float rayDiffScale =
    std::max<Float>(.125f, 1 / std::sqrt((Float)sampler.SamplesPerPixel()));
cameraRay->ray.ScaleDifferentials(rayDiffScale);
```


#parec[
  For `Film` implementations that do not store geometric information at each pixel, it is worth saving the work of populating the `VisibleSurface` class. Therefore, a pointer to this class is only passed in the call to the `Li()` method if it is necessary, and a null pointer is passed otherwise. Integrator implementations then should only initialize the `VisibleSurface` if it is non-null.
][
  对于不在每个像素存储几何信息的 `Film` 实现，值得节省填充 `VisibleSurface` 类的工作。因此，只有在调用 `Li()` 方法时才需要时才传递指向该类的指针，否则传递空指针。积分器实现应仅在 `VisibleSurface` 非空时初始化它。
]

#parec[
  `CameraRayDifferential` also carries a weight associated with the ray that is used to scale the returned radiance value. For simple camera models, each ray is weighted equally, but camera models that more accurately simulate the process of image formation by lens systems may generate some rays that contribute more than others. Such a camera model might simulate the effect of less light arriving at the edges of the film plane than at the center, an effect called #emph[vignetting];.
][
  `CameraRayDifferential` 还携带与光线相关的权重，用于缩放返回的辐亮度值。对于简单的相机模型，每条光线的权重是相等的，但更准确地模拟镜头系统成像过程的相机模型可能会生成一些光线比其他光线贡献更多。这样的相机模型可能会模拟到达胶片平面边缘的光线比中心少的效果，这种效果称为#emph[渐晕];。
]

```cpp
bool initializeVisibleSurface = camera.GetFilm().UsesVisibleSurface();
L = cameraRay->weight *
    Li(cameraRay->ray, lambda, sampler, scratchBuffer,
       initializeVisibleSurface ? &visibleSurface : nullptr);
```


#parec[
  `Li()` is a pure virtual method that `RayIntegrator` subclasses must implement. It returns the incident radiance at the origin of a given ray, sampled at the specified wavelengths.
][
  `Li()` 是 `RayIntegrator` 子类必须实现的纯虚方法。它返回给定光线起点处的入射辐亮度，在指定波长处采样。
]

```cpp
virtual SampledSpectrum Li(
    RayDifferential ray, SampledWavelengths &lambda, Sampler sampler,
    ScratchBuffer &scratchBuffer, VisibleSurface *visibleSurface) const = 0;
```


#parec[
  A common side effect of bugs in the rendering process is that impossible radiance values are computed. For example, division by zero results in radiance values equal to either the IEEE floating-point infinity or a "not a number" value. The renderer looks for these possibilities and prints an error message when it encounters them. Here we will not include the fragment that does this,\<\>. See the implementation in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`] if you are interested in its details.
][
  渲染过程中错误的常见副作用是计算出不可能的辐亮度值。例如，除以零会导致辐亮度值等于 IEEE 浮点无穷大或“非数字”值。渲染器会检查这些可能性，并在遇到时打印错误信息。此处我们不包括执行此操作的片段，\<\>。如果您对其详细信息感兴趣，请参阅 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/integrator.cpp")[`cpu/integrator.cpp`] 中的实现。
]

#parec[
  After the radiance arriving at the ray's origin is known, a call to `Film::AddSample()` updates the corresponding pixel in the image, given the weighted radiance for the sample. The details of how sample values are recorded in the film are explained in @film-and-imaging and~#link("../Sampling_and_Reconstruction/Image_Reconstruction.html#sec:image-reconstruction")[8.8];.
][
  在确定光线起点处的辐亮度后，调用 `Film::AddSample()` 更新图像中对应像素的加权辐亮度。关于样本值如何记录在胶片中的细节在@film-and-imaging 和@image-reconstruction 中有解释。
]

```cpp
camera.GetFilm().AddSample(pPixel, L, lambda, &visibleSurface,
                           cameraSample.filterWeight);
```



=== 1.3.6 Random Walk Integrator
<random-walk-integrator>
#parec[
  Although it has taken a few pages to go through the implementation of the integrator infrastructure that culminated in `RayIntegrator`, we can now turn to implementing light transport integration algorithms in a simpler context than having to start implementing a complete `Integrator::Render()` method. The `RandomWalkIntegrator` that we will describe in this section inherits from `RayIntegrator` and thus all the details of multi-threading, generating the initial ray from the camera and then adding the radiance along that ray to the image, are all taken care of. The integrator operates in a simpler context: a ray has been provided and its task is to compute the radiance arriving at its origin.
][
  虽然我们花了几页的篇幅来介绍以 `RayIntegrator` 为终点的积分器基础设施的实现，但现在我们可以在一个比实现完整的 `Integrator::Render()` 方法更简单的上下文中，着手实现光传输整合算法。我们将在本节中描述的 `RandomWalkIntegrator` 继承自 `RayIntegrator`，因此多线程、从相机生成初始光线以及将沿该光线的辐射添加到图像中的所有细节都已处理。积分器在一个更简单的环境中工作：给定一条光线，其任务是计算到达光线起点的辐射。
]

#parec[
  Recall that in @ray-propagation we mentioned that in the absence of participating media, the light carried by a ray is unchanged as it passes through free space. We will ignore the possibility of participating media in the implementation of this integrator, which allows us to take a first step: given the first intersection of a ray with the geometry in the scene, the radiance arriving at the ray's origin is equal to the radiance leaving the intersection point toward the ray's origin. That outgoing radiance is given by the light transport equation (@eqt:rendering-equation), though it is hopeless to evaluate it in closed form.Numerical approaches are required, and the ones used in `pbrt` are based on Monte Carlo integration, which makes it possible to estimate the values of integrals based on pointwise evaluation of their integrands.@monte-carlo-integration provides an introduction to Monte Carlo integration, and additional Monte Carlo techniques will be introduced as they are used throughout the book.
][
  回想一下，在 @ray-propagation 中我们提到，在没有参与介质的情况下，光线携带的光在通过自由空间时不变。在这个积分器的实现中，我们将忽略参与介质的可能性，这使我们能够迈出第一步：给定光线与场景中几何体的第一次相交，到达光线起点的辐射等于从相交点离开朝向光线起点的辐射。该出射辐射由光传输方程（@eqt:rendering-equation）给出，尽管以解析形式评估它是不可能的。需要数值方法，而 `pbrt` 中使用的方法基于蒙特卡罗积分，这使得可以基于其被积函数的逐点评估来估计积分的值。@monte-carlo-integration 介绍了蒙特卡罗积分，并将在整本书中使用时介绍其他蒙特卡罗技术。
]

#parec[
  In order to compute the outgoing radiance, the `RandomWalkIntegrator` implements a simple Monte Carlo approach that is based on incrementally constructing a #emph[random walk];, where a series of points on scene surfaces are randomly chosen in succession to construct light-carrying paths starting from the camera. This approach effectively models image formation in the real world in reverse, starting from the camera rather than from the light sources. Going backward in this respect is still physically valid because the physical models of light that `pbrt` is based on are time-reversible.
][
  为了计算出射辐射，`RandomWalkIntegrator` 实现了一种简单的蒙特卡罗方法，该方法基于逐步构建一个#emph[随机游走];，其中场景表面上的一系列点被连续随机选择，以从相机开始构建光携带路径。这种方法有效地反向模拟了现实世界中的图像形成，从相机开始而不是从光源开始。以这种方式反向仍然是物理上有效的，因为 `pbrt` 所基于的光的物理模型具有时间可逆性。
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
      使用 `RandomWalkIntegrator` 渲染的#emph[水彩];场景视图。由于
      `RandomWalkIntegrator`
      不处理完全镜面反射的表面，桌子上的两个玻璃杯是黑色的。此外，即使使用每像素8,192个样本来渲染此图像，结果仍然充满了高频噪声。（例如，注意远墙和椅子的底部。）(场景由
      Angelo Ferretti 提供。)
    ]],
) <random-walk-integrator-image>

#parec[
  Although the implementation of the random walk sampling algorithm is in total just over twenty lines of code, it is capable of simulating complex lighting and shading effects; @fig:random-walk-integrator-image shows an image rendered using it.(That image required many hours of computation to achieve that level of quality, however.) For the remainder of this section, we will gloss over a few of the mathematical details of the integrator's implementation and focus on an intuitive understanding of the approach, though subsequent chapters will fill in the gaps and explain this and more sophisticated techniques more rigorously.
][
  尽管随机游走采样算法的实现仅有二十多行代码，但它能够模拟复杂的光照和阴影效果；@fig:random-walk-integrator-image 展示了使用它渲染的图像。（然而，该图像需要许多小时的计算才能达到这种质量水平。）在本节的剩余部分，我们将略去积分器实现中的一些数学细节，专注于对该方法的直观理解，尽管随后的章节将填补空白，并更严格地解释这一点和更复杂的技术。
]

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
                                               depth + 1) / (1 / (4 * \pi));
       }
    int maxDepth;
};
```

#parec[
  This integrator recursively evaluates the random walk. Therefore, its `Li()` method implementation does little more than start the recursion,via a call to the `LiRandomWalk()` method. Most of the parameters to `Li()` are just passed along, though the `VisibleSurface` is ignored for this simple integrator and an additional parameter is added to track the depth of recursion.
][
  这个积分器递归地评估随机游走。因此，其 `Li()` 方法实现几乎只是在通过调用 `LiRandomWalk()` 方法开始递归。大多数传递给 `Li()` 的参数只是被传递过去，尽管对于这个简单的积分器，`VisibleSurface` 被忽略，并且添加了一个额外的参数来跟踪递归的深度。
]

```cpp
<<RandomWalkIntegrator Public Methods>>=
SampledSpectrum Li(RayDifferential ray, SampledWavelengths &lambda,
        Sampler sampler, ScratchBuffer &scratchBuffer,
        VisibleSurface *visibleSurface) const {
    return LiRandomWalk(ray, lambda, sampler, scratchBuffer, 0);
}
<<RandomWalkIntegrator Private Methods>>=
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

#parec[
  The first step is to find the closest intersection of the ray with the shapes in the scene. If no intersection is found, the ray has left the scene. Otherwise, a `SurfaceInteraction` that is returned as part of the `ShapeIntersection` structure provides information about the local geometric properties of the intersection point.
][
  第一步是找到光线与场景中形状的最近相交。如果没有找到相交，光线就离开了场景。否则，作为 `ShapeIntersection` 结构的一部分返回的 `SurfaceInteraction` 提供了关于相交点局部几何属性的信息。
]

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

#parec[
  If no intersection was found, radiance still may be carried along the ray due to light sources such as the `ImageInfiniteLight` that do not have geometry associated with them. The `Light::Le()` method allows such lights to return their radiance for a given ray.
][
  如果没有找到相交，辐射仍可能沿着光线传播，因为像 `ImageInfiniteLight` 这样的光源没有与之相关的几何体。`Light::Le()` 方法允许这样的光源为给定光线返回其辐射。
]

```cpp
SampledSpectrum Le(0.f);
for (Light light : infiniteLights)
    Le += light.Le(ray, lambda);
return Le;
```


#parec[
  If a valid intersection has been found, we must evaluate the light transport equation at the intersection point. The first term, $L_e (p , omega_o)$, which is the emitted radiance, is easy: emission is part of the scene specification and the emitted radiance is available by calling the `SurfaceInteraction::Le()` method, which takes the outgoing direction of interest. Here, we are interested in radiance emitted back along the ray's direction. If the object is not emissive, that method returns a zero-valued spectral distribution.
][
  如果找到了有效的相交点，我们必须在该点评估光传输方程。第一个项 $L_e (p , omega_o)$，即发射辐射，很简单：发射是场景规范的一部分，发射辐射可以通过调用 `SurfaceInteraction::Le()` 方法获得，该方法需要感兴趣的出射方向。在这里，我们对沿着光线方向返回的辐射感兴趣。如果物体不是发光的，该方法返回一个零值的光谱分布。
]

```cpp
Vector3f wo = -ray.d;
SampledSpectrum Le = isect.Le(wo, lambda);
```

#parec[
  Evaluating the second term of the light transport equation requires computing an integral over the sphere of directions around the intersection point $p$. Application of the principles of Monte Carlo integration can be used to show that if directions $omega prime$ are chosen with equal probability over all possible directions, then an estimate of the integral can be computed as a weighted product of the BSDF $f$, which describes the light scattering properties of the material at $p$, the incident lighting, $L_i$, and a cosine factor:
][
  评估光传输方程的第二项需要计算相交点 $p$ 周围方向球体上的积分。应用蒙特卡罗积分的原理可以表明，如果方向 $omega prime$ 在所有可能方向上以均匀概率选择，则可以将积分的估计值计算为 BSDF $f$ 的加权乘积，BSDF 描述了 $p$ 处材料的光散射特性，入射光 $L_i$ 和一个余弦因子：
]


$
  integral_(S^2) f (p , omega_o , omega_i) L_i ( p , omega_i ) lr(|cos theta_i|) thin d omega_i approx frac(f (p , omega_o , omega prime) L_i (p , omega prime) lr(|cos theta prime|), 1 \/ 4 pi) .
$ <simple-mc-estimator-random-walk>


#parec[
  In other words, given a random direction $omega prime$, estimating the value of the integral requires evaluating the terms in the integrand for that direction and then scaling by a factor of $4 pi$.(This factor,which is derived in Section A.5.2, relates to the surface area of a unit sphere.) Since only a single direction is considered, there is almost always error in the Monte Carlo estimate compared to the true value of the integral. However, it can be shown that estimates like this one are correct in expectation: informally, that they give the correct result on average. Averaging multiple independent estimates generally reduces this error—hence, the practice of taking multiple samples per pixel.
][
  换句话说，给定一个随机方向 $omega prime$，估计积分的值需要评估该方向下被积函数中的各项，然后乘以一个 $4 pi$ 的因子。（这个因子在第 A.5.2 节中推导，与单位球的表面积有关。）由于只考虑一个方向，与积分的真实值相比，蒙特卡罗估计几乎总是存在误差。然而，可以证明这样的估计在期望值上是正确的：非正式地说，它们平均给出正确的结果。平均多个独立估计通常会减少这种误差——因此，每像素取多个样本的做法。
]

#parec[
  The BSDF and the cosine factor of the estimate are easily evaluated,leaving us with $L_i$, the incident radiance, unknown. However, note that we have found ourselves right back where we started with the initial call to `LiRandomWalk()`: we have a ray for which we would like to find the incident radiance at the origin—that, a recursive call to `LiRandomWalk()` will provide.
][
  BSDF 和估计的余弦因子很容易评估，剩下的是 $L_i$，即未知的入射辐射。然而，请注意，我们发现自己回到了最初调用 `LiRandomWalk()` 的地方：我们有一条光线，希望找到在原点的入射辐射——这将由对 `LiRandomWalk()` 的递归调用提供。
]

#parec[
  Before computing the estimate of the integral, we must consider terminating the recursion. The `RandomWalkIntegrator` stops at a predetermined maximum depth,`maxDepth`. Without this termination criterion, the algorithm might never terminate (imagine, e.g., a hall-of-mirrors scene). This member variable is initialized in the constructor based on a parameter that can be set in the scene description file.
][
  在计算积分的估计之前，我们必须考虑终止递归。`RandomWalkIntegrator` 在预定的最大深度 `maxDepth` 停止。如果没有这个终止标准，算法可能会无限循环（例如，想象一个镜厅场景）。这个成员变量在构造函数中根据可以在场景描述文件中设置的参数初始化。
]

```cpp
// <<RandomWalkIntegrator Private Members>>=
int maxDepth;

// <<Terminate random walk if maximum depth has been reached>>=
if (depth == maxDepth)
    return Le;
```
#parec[
  If the random walk is not terminated, the `SurfaceInteraction::GetBSDF()` method is called to find the BSDF at the intersection point. It evaluates texture functions to determine surface properties and then initializes a representation of the BSDF. It generally needs to allocate memory for the objects that constitute the BSDF's representation; because this memory only needs to be active when processing the current ray, the `ScratchBuffer` is provided to it to use for its allocations.
][
  如果随机游走没有终止，则调用 `SurfaceInteraction::GetBSDF()` 方法以找到交点处的 BSDF。它评估纹理函数以确定表面属性，然后初始化 BSDF 的表示。通常需要为构成 BSDF 表示的对象分配内存；因为这些内存只需要在处理当前光线时处于活动状态，所以提供了 `ScratchBuffer` 供其用于分配。
]

```cpp
// <<Compute BSDF at random walk intersection point>>=
BSDF bsdf = isect.GetBSDF(ray, lambda, camera, scratchBuffer, sampler);
```
#parec[
  Next, we need to sample a random direction $omega prime$ to compute the estimate in @eqt:simple-mc-estimator-random-walk . The `SampleUniformSphere()` function returns a uniformly distributed direction on the unit sphere, given two uniform values in $\[ 0 , 1 \)$ that are provided here by the sampler.
][
  接下来，我们需要采样一个随机方向 $omega prime$ 来计算@eqt:simple-mc-estimator-random-walk 中的估计。`SampleUniformSphere()` 函数返回单位球上均匀分布的方向，给定 $\[ 0 , 1 \)$ 中的两个均匀值，这里由采样器提供。
]

```cpp
<<Randomly sample direction leaving surface for random walk>>=
Point2f u = sampler.Get2D();
Vector3f wp = SampleUniformSphere(u);
```

#parec[
  All the factors of the Monte Carlo estimate other than the incident radiance can now be readily evaluated. The `BSDF` class provides an `f()` method that evaluates the BSDF for a pair of specified directions,and the cosine of the angle with the surface normal can be computed using the `AbsDot()` function, which returns the absolute value of the dot product between two vectors. If the vectors are normalized, as both are here, this value is equal to the absolute value of the cosine of the angle between them (@dot-and-cross-product).
][
  现在可以轻松评估蒙特卡罗估计中除入射辐射之外的所有因子。`BSDF` 类提供了一个 `f()` 方法，用于评估指定方向对的 BSDF，表面法线的角度余弦可以使用 `AbsDot()` 函数计算，该函数返回两个向量之间点积的绝对值。如果向量被标准化，如此处的两个向量，则该值等于它们之间角度余弦的绝对值（@dot-and-cross-product）。
]

#parec[
  It is possible that the BSDF will be zero-valued for the provided directions and thus that `fcos` will be as well—for example, the BSDF is zero if the surface is not transmissive but the two directions are on opposite sides of it. In that case, there is no reason to continue the random walk, since subsequent points will make no contribution to the result.
][
  BSDF 可能对于提供的方向为零值，因此 `fcos` 也可能为零——例如，如果表面不透光但两个方向在其相对两侧，则 BSDF 为零。在这种情况下，没有理由继续随机游走，因为后续点不会对结果产生贡献。
]

```cpp
<<Evaluate BSDF at surface for sampled direction>>=
SampledSpectrum fcos = bsdf.f(wo, wp) * AbsDot(wp, isect.shading.n);
if (!fcos)
    return Le;
```
#parec[
  The remaining task is to compute the new ray leaving the surface in the sampled direction $omega prime$. This task is handled by the `SpawnRay()` method, which returns a ray leaving an intersection in the provided direction, ensuring that the ray is sufficiently offset from the surface that it does not incorrectly reintersect it due to round-off error. Given the ray, the recursive call to `LiRandomWalk()` can be made to estimate the incident radiance, which completes the estimate of @eqt:simple-mc-estimator-random-walk.
][
  剩下的任务是计算在采样方向 $omega prime$ 上离开表面的新光线。这个任务由 `SpawnRay()` 方法处理，它返回一个在提供方向上离开交点的光线，确保光线从表面足够偏移，以免由于舍入误差而错误地重新交叉它。给定光线，可以递归调用 `LiRandomWalk()` 来估计入射辐射，从而完成@@eqt:simple-mc-estimator-random-walk 的估计。
]

```cpp
// <<Recursively trace ray to estimate incident radiance at surface>>=
ray = isect.SpawnRay(wp);
return Le  + fcos * LiRandomWalk(ray, lambda, sampler, scratchBuffer,
                                 depth + 1) / (1 / (4 * Pi));
```
#parec[
  This simple approach has many shortcomings. For example, if the emissive surfaces are small, most ray paths will not find any light and many rays will need to be traced to form an accurate image. In the limit case of a point light source, the image will be black, since there is zero probability of intersecting such a light source. Similar issues apply with BSDF models that scatter light in a concentrated set of directions.In the limiting case of a perfect mirror that scatters incident light along a single direction, the `RandomWalkIntegrator` will never be able to randomly sample that direction.
][
  这种简单的方法有许多缺点。例如，如果发光表面很小，大多数光线路径将找不到任何光线，并且需要追踪许多光线以形成准确的图像。在点光源的极限情况下，图像将是黑色的，因为没有交叉这样的光源的概率。类似的问题适用于将光线集中在一组方向上的 BSDF 模型。在将入射光沿单一方向散射的完美镜子的极限情况下，`RandomWalkIntegrator` 将永远无法随机采样该方向。
]

#parec[
  Those issues and more can be addressed through more sophisticated application of Monte Carlo integration techniques. In subsequent chapters, we will introduce a succession of improvements that lead to much more accurate results. The integrators that are defined in @light-transport-i-surface-reflection through @wavefront-rendering-on-gpus are the culmination of those developments. All still build on the same basic ideas used in the `RandomWalkIntegrator`, but are much more efficient and robust than it is.@fig:randomwalk-vs-path-integrator compares the `RandomWalkIntegrator` to one of the improved integrators and gives a sense of how much improvement is possible.
][
  这些问题以及更多问题可以通过更复杂的蒙特卡罗积分技术应用来解决。在后续章节中，我们将介绍一系列改进，导致更准确的结果。在@light-transport-i-surface-reflection 到 @wavefront-rendering-on-gpus 中定义的积分器是这些发展的顶点。所有这些仍然建立在 `RandomWalkIntegrator` 中使用的相同基本思想上，但比它更高效和稳健。@fig:randomwalk-vs-path-integrator 将 `RandomWalkIntegrator` 与其中一个改进的积分器进行了比较，并给出了可能改进的感觉。
]

#figure(
  table(
    columns: 2,
    [#image("imgs/random-walk-insanity.png")], [#image("imgs/watercolor-path.png")],
  ),
  caption: [
    #ez_caption[
      *Watercolor Scene Rendered Using 32 Samples per Pixel.* (a) Rendered using the `RandomWalkIntegrator`. (b) Rendered using the
      `PathIntegrator`, which follows the same general approach but uses more
      sophisticated Monte Carlo techniques. The `PathIntegrator` gives a
      substantially better image for roughly the same amount of work, with
      $54.5 times$ reduction in mean squared error.

    ][*水彩画场景使用每像素 32 个样本渲染。*(a) 使用
      `RandomWalkIntegrator` 渲染。(b) 使用 `PathIntegrator`
      渲染，它遵循相同的总体方法，但使用更复杂的蒙特卡罗技术。`PathIntegrator`
      在大致相同的工作量下提供了明显更好的图像，均方误差减少了 54.5 倍。
    ]
  ],
  kind: image,
) <randomwalk-vs-path-integrator>
