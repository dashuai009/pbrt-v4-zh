#import "../template.typ": parec

== How to Proceed through This Book
<how-to-proceed-through-this-book>

#parec[
  We have written this book assuming it will be read in roughly front-to-back order. We have tried to minimize the number of forward references to ideas and interfaces that have not yet been introduced,but we do assume that the reader is acquainted with the previous content at any particular point in the text. Some sections go into depth about advanced topics that some readers may wish to skip over, particularly on first reading; each advanced section is identified by an asterisk in its title.
][
  我们编写本书时假设读者将大致按从前到后的顺序阅读。我们尽量减少对尚未介绍的思想和接口的前向引用，但我们假设读者在文本的某一点对先前的内容有所了解。一些部分深入探讨一些高级主题，某些读者可能希望跳过，尤其是在首次阅读时；每个高级部分在其标题中都有一个星号。
]


#parec[
  Because of the modular nature of the system, the main requirements are that the reader be familiar with the low-level classes like #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`];,#link("../Geometry_and_Transformations/Rays.html#Ray")[`Ray`];, and #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];; the interfaces defined by the abstract base classes listed in @tbl:plug-in-types; and the rendering loop that culminates in calls to integrators' #link("../Introduction/pbrt_System_Overview.html#RayIntegrator::Li")[`RayIntegrator::Li()`] methods. Given that knowledge, for example, the reader who does not care about precisely how a camera model based on a perspective projection matrix maps #link("../Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`];s to rays can skip over the implementation of that camera and can just remember that the #link("../Cameras_and_Film/Camera_Interface.html#Camera::GenerateRayDifferential")[`Camera::GenerateRayDifferential()`] method somehow turns a #link("../Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`] into a #link("../Geometry_and_Transformations/Rays.html#RayDifferential")[`RayDifferential`];.
][
  由于系统的模块化特性，主要要求是读者熟悉低级类，如#link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`];,#link("../Geometry_and_Transformations/Rays.html#Ray")[`Ray`];,和#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];；熟悉@tbl:plug-in-types-zh 中列出的抽象基类定义的接口；以及以对积分器的#link("../Introduction/pbrt_System_Overview.html#RayIntegrator::Li")[`RayIntegrator::Li()`];方法的调用为高潮的渲染循环。有鉴于此，例如，对于不关心基于透视投影矩阵的相机模型如何将#link("../Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`];映射到光线的读者来说，可以跳过该相机的实现，仅需记住#link("../Cameras_and_Film/Camera_Interface.html#Camera::GenerateRayDifferential")[`Camera::GenerateRayDifferential()`];方法以某种方式将#link("../Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`];转换为#link("../Geometry_and_Transformations/Rays.html#RayDifferential")[`RayDifferential`];。
]

#parec[
  The remainder of this book is divided into four main parts of a few chapters each. First,@monte-carlo-integration through @Radiometry_Spectra_and_Color introduce the foundations of the system. A brief introduction to the key ideas underlying Monte Carlo integration is provided in @monte-carlo-integration, and @geometry-and-transformations then describes widely used geometric classes like #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`];,#link("../Geometry_and_Transformations/Rays.html#Ray")[`Ray`];, and #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`];.@Radiometry_Spectra_and_Color introduces the physical units used to measure light and the #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] class that `pbrt` uses to represent spectral distributions. It also discusses color, the human perception of spectra, which affects how input is provided to the renderer and how it generates output.
][
  这本书的其余部分分为四个主要部分，每个部分包含几章。首先，@monte-carlo-integration 到@Radiometry_Spectra_and_Color 介绍系统的基础。@monte-carlo-integration 简要介绍了蒙特卡洛积分的关键思想，然后@geometry-and-transformations 描述了诸如#link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`];,#link("../Geometry_and_Transformations/Rays.html#Ray")[`Ray`];,和#link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`];等广泛使用的几何类。@Radiometry_Spectra_and_Color 介绍了用于测量光的物理单位以及`pbrt`用于表示光谱分布的#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];类。它还讨论了颜色，人类对光谱的感知，这会影响如何向渲染器提供输入以及它如何生成输出。
]

#parec[
  The second part of the book covers image formation and how the scene geometry is represented.@cameras-and-film defines the #link("../Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`] interface and a few different camera implementations before discussing the overall process of turning spectral radiance arriving at the film into images.@Shapes then introduces the #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] interface and gives implementations of a number of shapes, including showing how to perform ray intersection tests with them.@primitives-and-intersection-acceleration describes the implementations of the acceleration structures that make ray tracing more efficient by skipping tests with primitives that a ray can be shown to definitely not intersect. Finally, Chapter 8's topic is the #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] classes that place samples on the image plane and provide random samples for Monte Carlo integration.
][
  本书的第二部分涵盖图像形成以及场景几何的表示。@cameras-and-film 定义了#link("../Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`];接口以及几种不同的相机实现，然后讨论将到达胶卷的光谱辐射转化为图像的总体过程。@Shapes 接着介绍了#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];接口，并提供多个形状的实现，包括如何对它们执行光线相交测试。@primitives-and-intersection-acceleration 描述了加速结构的实现，这些结构通过跳过与可以证明绝对不相交的原始体的测试使光线追踪更加高效。最后，@sampling-and-reconstruction 的主题是将样本放置在图像平面上的#link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`];类，并为蒙特卡洛积分提供随机样本。
]

#parec[
  The third part of the book is about light and how it scatters from surfaces and participating media.@reflection-models includes a collection of classes that define a variety of types of reflection from surfaces. Materials, described in @textures-and-materials, use these reflection functions to implement a number of different surface types, such as plastic, glass, and metal. Spatial variation in material properties (color, roughness, etc.) is modeled by textures, which are also described in @textures-and-materials. volume-scattering introduces the abstractions that describe how light is scattered and absorbed in participating media, and @light-sources then describes the interface for light sources and a variety of light source implementations.
][
  本书的第三部分讨论光以及光如何从表面和参与介质中散射。@reflection-models 包含一组定义多种表面反射类型的类。@textures-and-materials 描述的材质使用这些反射函数来实现多种不同的表面类型，例如塑料、玻璃和金属。材质属性的空间变化（颜色、粗糙度等）通过纹理建模，这些纹理在@textures-and-materials 中也有描述。@volume-scattering 介绍了描述光如何在参与介质中散射和吸收的抽象概念，@light-sources 随后描述了光源接口以及各种光源的实现。
]

#parec[
  The last part brings all the ideas from the rest of the book together to implement a number of interesting light transport algorithms. The integrators in @light-transport-i-surface-reflection and 14 represent a variety of different applications of Monte Carlo integration to compute more accurate approximations of the light transport equation than the #link("../Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`];.@wavefront-rendering-on-gpus then describes the implementation of a high-performance integrator that runs on the GPU, based on all the same classes that are used in the implementations of the CPU-based integrators.
][
  最后一部分将书中其余部分的所有思想结合在一起，实现一些有趣的光传输算法。@light-transport-i-surface-reflection 和 @light-transport-ii-volume-rendering 的积分器代表蒙特卡洛积分的多种不同应用，以计算比#link("../Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`];更精确的光传输方程近似值。@wavefront-rendering-on-gpus 接着描述了在GPU上运行的高性能积分器的实现，该积分器基于与CPU基础积分器实现中使用的所有相同类。
]

#parec[
  @retrospective-and-the-future, the last chapter of the book, provides a brief retrospective and discussion of system design decisions along with a number of suggestions for more far-reaching projects than those in the exercises. Appendices contain more Monte Carlo sampling algorithms, describe utility functions, and explain details of how the scene description is created as the input file is parsed.
][
  @retrospective-and-the-future，书的最后一章，提供了一个简要的回顾和系统设计决策的讨论，以及对比练习中的项目更深入的建议。附录包含更多的蒙特卡洛采样算法，描述实用函数，并解释在解析输入文件时如何创建场景描述的细节。
]

=== The Exercises
<the-exercises>


#parec[
  At the end of each chapter you will find exercises related to the material covered in that chapter. Each exercise is marked as one of three levels of difficulty:
][
  在每一章的末尾，您会发现与该章节所涵盖内容相关的练习。每个练习标记为三种难度等级之一：
]

#parec[
  - #strong[\[1\]] An exercise that should take only an hour or two - #strong[\[2\]] A reading and/or implementation task that would be suitable for a course assignment and should take between 10 and 20 hours of work - #strong[\[3\]] A suggested final project for a course that will likely take 40 hours or more to complete
][
  - #strong[\[1\]] 一个应该只需一两个小时的练习 - #strong[\[2\]] 一个适合课程作业的阅读和/或实施任务，应该需要10到20小时的工作 - #strong[\[3\]] 一个建议的课程最终项目， 可能需要 40 小时或更长时间才能完成
]

=== Viewing the images

#parec[
  Figures throughout the book compare the results of rendering the same scene using different algorithms. As with previous editions of the book, we have done our best to ensure that these differences are evident on the printed page, though even high quality printing cannot match modern display technology, especially now with the widespread availability of high dynamic range displays.
][
  书中的图表比较了使用不同算法渲染同一场景的结果。与本书的前几版一样，我们已尽力确保这些差异在印刷页面上显而易见，尽管即使是高质量的印刷也无法与现代显示技术相媲美，尤其是现在高动态范围显示器的广泛使用。
]

#parec[
  We have therefore made all of the rendered images that are used in figures available online. For example, the first image shown in this chapter as @fig:pbrt-kroken-view is available at the URL `pbr-book.org/4ed/fig/1.1`. All of the others follow the same naming scheme.
][
  因此，我们将图中使用的所有渲染图像在线提供。例如，本章中显示的第一张图像（@fig:pbrt-kroken-view）可从 URL `pbr-book.org/4ed/fig/1.1`获取。所有其他都遵循相同的命名方案。
]
=== The Online Edition
#parec[
  Starting on November 1, 2023, the full contents of this book will be freely available online at #link("https://pbr-book.org/4ed")[pbr-book.org/4ed].(The previous edition of the book is already available at that website.)
][
  从2023年11月1日起，这本书的全部内容将在#link("https://pbr-book.org/4ed")[pbr-book.org/4ed]网站上免费提供。（该书的上一版已经在该网站上提供。）
]

#parec[
  The online edition includes additional content that could not be included in the printed book due to page constraints. All of that material is supplementary to the contents of this book. For example, it includes the implementation of an additional camera model, a kd-tree acceleration structure, and a full chapter on bidirectional light transport algorithms.(Almost all of the additional material appeared in the previous edition of the book.)
][
  在线版包含了由于页数限制无法收录在印刷版中的额外内容。所有这些材料都是本书内容的补充。例如，它包括了一个额外的摄像机模型的实现、一个kd-tree加速结构以及一整章关于双向光传输算法的内容。（几乎所有的这些附加材料都出现在该书的上一版中。）
]
