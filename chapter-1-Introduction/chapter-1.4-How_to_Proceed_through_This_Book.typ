#import "../template.typ": parec, ez_caption

== #ez_caption[How to Proceed through This Book][如何阅读本书]
<how-to-proceed-through-this-book>

#parec[
  We have written this book assuming it will be read in roughly front-to-back order. We have tried to minimize the number of forward references to ideas and interfaces that have not yet been introduced, but we do assume that the reader is acquainted with the previous content at any particular point in the text. Some sections go into depth about advanced topics that some readers may wish to skip over, particularly on first reading; each advanced section is identified by an asterisk in its title.
][
  编写本书时，我们假定读者大致按从前到后的顺序阅读。我们尽量少提前引用尚未介绍的概念和接口，但也假定读者在阅读任意位置时，已经熟悉此前的内容。一些小节深入讨论高级主题，读者可能希望跳过，尤其是初次阅读时；这类小节的标题都带有星号。
]


#parec[
  Because of the modular nature of the system, the main requirements are that the reader be familiar with the low-level classes like #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`],#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`], and #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`]; the interfaces defined by the abstract base classes listed in @tbl:plug-in-types; and the rendering loop that culminates in calls to integrators' #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#RayIntegrator::Li")[`RayIntegrator::Li()`] methods. Given that knowledge, for example, the reader who does not care about precisely how a camera model based on a perspective projection matrix maps #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`]s to rays can skip over the implementation of that camera and can just remember that the #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#Camera::GenerateRayDifferential")[`Camera::GenerateRayDifferential()`] method somehow turns a #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`] into a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#RayDifferential")[`RayDifferential`].
][
  由于系统具有模块化结构，读者主要需要熟悉 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`]、#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`]、#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] 等底层类，@tbl:plug-in-types 所列抽象基类定义的接口，以及最终调用积分器 #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#RayIntegrator::Li")[`RayIntegrator::Li()`] 方法的渲染循环。有了这些知识，如果不关心基于透视投影矩阵的相机模型具体如何将 #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`] 映射为射线，就可以跳过该相机的实现，只需记住 #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#Camera::GenerateRayDifferential")[`Camera::GenerateRayDifferential()`] 会以某种方式将 #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`] 转换为 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#RayDifferential")[`RayDifferential`]。
]

#parec[
  The remainder of this book is divided into four main parts of a few chapters each. First, @monte-carlo-integration through @Radiometry_Spectra_and_Color introduce the foundations of the system. A brief introduction to the key ideas underlying Monte Carlo integration is provided in @monte-carlo-integration, and @geometry-and-transformations then describes widely used geometric classes like #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`],#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`], and #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`]. @Radiometry_Spectra_and_Color introduces the physical units used to measure light and the #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] class that `pbrt` uses to represent spectral distributions. It also discusses color, the human perception of spectra, which affects how input is provided to the renderer and how it generates output.
][
  本书其余内容分为四大部分，每部分包含数章。首先，@monte-carlo-integration 至 @Radiometry_Spectra_and_Color 介绍系统基础。@monte-carlo-integration 简要介绍蒙特卡洛积分的关键思想；@geometry-and-transformations 接着介绍 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`]、#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`] 和 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] 等常用几何类。@Radiometry_Spectra_and_Color 介绍光的度量所用的物理单位，以及 `pbrt` 表示光谱分布的 #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] 类。该章还讨论颜色，即人类对光谱的感知，它影响如何向渲染器提供输入，以及渲染器如何生成输出。
]

#parec[
  The second part of the book covers image formation and how the scene geometry is represented. @cameras-and-film defines the #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`] interface and a few different camera implementations before discussing the overall process of turning spectral radiance arriving at the film into images.@Shapes then introduces the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] interface and gives implementations of a number of shapes, including showing how to perform ray intersection tests with them.@primitives-and-intersection-acceleration describes the implementations of the acceleration structures that make ray tracing more efficient by skipping tests with primitives that a ray can be shown to definitely not intersect. Finally, @sampling-and-reconstruction's topic is the #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] classes that place samples on the image plane and provide random samples for Monte Carlo integration.
][
  第二部分介绍图像形成与场景几何表示。@cameras-and-film 定义 #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`] 接口及数种相机实现，再讨论如何将到达胶片的光谱辐亮度转换为图像。@Shapes 介绍 #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 接口和多种形状的实现，包括如何进行射线求交测试。@primitives-and-intersection-acceleration 介绍加速结构的实现，通过跳过那些可以确定不会与射线相交的图元，提高光线追踪效率。最后，@sampling-and-reconstruction 介绍 #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 类，它在图像平面上布置样本，并为蒙特卡洛积分提供随机样本。
]

#parec[
  The third part of the book is about light and how it scatters from surfaces and participating media. @reflection-models includes a collection of classes that define a variety of types of reflection from surfaces. Materials, described in @textures-and-materials, use these reflection functions to implement a number of different surface types, such as plastic, glass, and metal. Spatial variation in material properties (color, roughness, etc.) is modeled by textures, which are also described in @textures-and-materials. @volume-scattering introduces the abstractions that describe how light is scattered and absorbed in participating media, and @light-sources then describes the interface for light sources and a variety of light source implementations.
][
  第三部分讨论光及其在表面和参与介质中的散射。@reflection-models 介绍一组定义各种表面反射类型的类。@textures-and-materials 中的材质利用这些反射函数，实现塑料、玻璃、金属等不同表面类型。颜色、粗糙度等材质属性在空间中的变化由纹理建模，该章也会介绍纹理。@volume-scattering 介绍描述光在参与介质中散射与吸收的抽象；@light-sources 随后介绍光源接口及各种实现。
]

#parec[
  The last part brings all the ideas from the rest of the book together to implement a number of interesting light transport algorithms. The integrators in @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering represent a variety of different applications of Monte Carlo integration to compute more accurate approximations of the light transport equation than the #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`]. @wavefront-rendering-on-gpus then describes the implementation of a high-performance integrator that runs on the GPU, based on all the same classes that are used in the implementations of the CPU-based integrators.
][
  最后一部分将此前的思想结合起来，实现多种有趣的光传输算法。@light-transport-i-surface-reflection 和 @light-transport-ii-volume-rendering 中的积分器，以不同方式运用蒙特卡洛积分，得到比 #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`] 更准确的光传输方程近似解。@wavefront-rendering-on-gpus 再介绍运行于 GPU 的高性能积分器，它使用的类与 CPU 积分器实现所用的类相同。
]

#parec[
  @retrospective-and-the-future, the last chapter of the book, provides a brief retrospective and discussion of system design decisions along with a number of suggestions for more far-reaching projects than those in the exercises. Appendices contain more Monte Carlo sampling algorithms, describe utility functions, and explain details of how the scene description is created as the input file is parsed.
][
  最后一章 @retrospective-and-the-future 简要回顾系统、讨论设计决策，并提出一些比习题项目更具延展性的项目建议。附录补充更多蒙特卡洛采样算法，介绍辅助函数，并说明解析输入文件时如何创建场景描述。
]

=== #ez_caption[The Exercises][习题]
<the-exercises>


#parec[
  At the end of each chapter you will find exercises related to the material covered in that chapter. Each exercise is marked as one of three levels of difficulty:
][
  每章末尾都有与该章内容相关的习题，并按以下三个难度等级之一标记：
]

#parec[
  - *①* An exercise that should take only an hour or two
  - *②* A reading and/or implementation task that would be suitable for a course assignment and should take between 10 and 20 hours of work
  - *③* A suggested final project for a course that will likely take 40 hours or more to complete
][
  - *①* 预计只需一两个小时的习题。
  - *②* 适合作为课程作业的阅读或实现任务，或兼有两者，预计需要 10 至 20 小时。
  - *③* 建议作为课程期末项目的任务，可能需要 40 小时或更久。
]

=== #ez_caption[Viewing the Images][查看图像]

#parec[
  Figures throughout the book compare the results of rendering the same scene using different algorithms. As with previous editions of the book, we have done our best to ensure that these differences are evident on the printed page, though even high quality printing cannot match modern display technology, especially now with the widespread availability of high dynamic range displays.
][
  书中许多插图比较了不同算法渲染同一场景的结果。与前几版一样，我们尽力让这些差异在印刷页上清楚可见；但即使高质量印刷也比不上现代显示技术，尤其是在高动态范围显示器已广泛普及的今天。
]

#parec[
  We have therefore made all of the rendered images that are used in figures available online. For example, the first image shown in this chapter as @fig:pbrt-kroken-view is available at the URL `pbr-book.org/4ed/fig/1.1`. All of the others follow the same naming scheme.
][
  因此，我们已在线提供插图中使用的所有渲染图像。例如，本章的第一幅图像（@fig:pbrt-kroken-view） 可通过 #link("https://pbr-book.org/4ed/fig/1.1")[pbr-book.org/4ed/fig/1.1] 访问，其他图像也采用同样的地址命名规则。
]
=== #ez_caption[The Online Edition][在线版]
#parec[
  Starting on November 1, 2023, the full contents of this book will be freely available online at #link("https://pbr-book.org/4ed")[pbr-book.org/4ed]. (The previous edition of the book is already available at that website.)
][
  从 2023 年 11 月 1 日起，本书全部内容将在 #link("https://pbr-book.org/4ed")[pbr-book.org/4ed] 免费在线提供。（上一版已经在该网站上线。）
]

#parec[
  The online edition includes additional content that could not be included in the printed book due to page constraints. All of that material is supplementary to the contents of this book. For example, it includes the implementation of an additional camera model, a kd-tree acceleration structure, and a full chapter on bidirectional light transport algorithms. (Almost all of the additional material appeared in the previous edition of the book.)
][
  在线版还包含因篇幅限制无法收录于印刷版的额外内容，均为本书正文的补充。例如，额外一种相机模型的实现、kd 树加速结构，以及一整章双向光传输算法。（这些补充材料几乎都曾出现在上一版中。）
]
