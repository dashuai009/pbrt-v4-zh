#import "../template.typ": parec, ez_caption

= #ez_caption[Cameras and Film][相机与胶片]
<cameras-and-film>

#figure(image("../pbr-book-website/4ed/openers/landscape-dof.jpg"))

#parec[
  In @introduction, we described the pinhole camera model that is commonly used in computer graphics. This model is easy to describe and simulate, but it neglects important effects that physical lenses have on light passing through them. For example, everything rendered with a pinhole camera is in sharp focus—a state of affairs not possible with real lens systems. Such images often look computer generated for their perfection. More generally, the distribution of radiance leaving a lens system is quite different from the distribution entering it; modeling this effect of lenses is important for accurately simulating the radiometry of image formation.
][
  在 @introduction 中，我们介绍了计算机图形学中常用的针孔相机模型。这个模型易于描述和模拟，却忽略了真实镜头对透过它的光的重要影响。例如，针孔相机渲染出的所有物体都清晰合焦，而真实镜头系统无法做到这一点。这类图像往往因为过于完美而显露出计算机生成的痕迹。更一般地，离开镜头系统的辐亮度分布与进入时很不相同；对这种镜头效应建模，是准确模拟成像过程辐射度学关系的重要环节。
]


#parec[
  Camera lens systems introduce various aberrations that affect the images that they form; for example, #emph[vignetting] causes a darkening toward the edges of images due to less light making it through to the edges of the film or sensor than to the center. Lenses can also cause #emph[pincushion] or #emph[barrel] distortion, which causes straight lines to be imaged as curves. Although lens designers work to minimize aberrations in their designs, they can still have a meaningful effect on images.
][
  相机镜头系统会引入各种像差，影响所形成的图像。例如，到达胶片或传感器边缘的光比到达中心的少，因此产生使图像边缘变暗的#emph[渐晕]。镜头还可能产生#emph[枕形]或#emph[桶形]畸变，使直线成像为曲线。尽管镜头设计者努力减小像差，它们仍可能对图像产生不可忽略的影响。
]

#parec[
  This chapter starts with a description of the `Camera` interface, after which we present a few implementations, starting with ideal pinhole models.
][
  本章先介绍 `Camera` 接口，再从理想针孔模型开始，介绍几种相机实现。
]

#parec[
  After light has been captured by a camera, it is measured by a sensor. While traditional film uses a chemical process to measure light, most modern cameras use solid-state sensors that are divided into pixels, each of which counts the number of photons that arrive over a period of time for some range of wavelengths. Accurately modeling the radiometry of how sensors measure light is an important part of simulating the process of image formation.
][
  相机捕获的光由传感器测量。传统胶片通过化学过程测量光，而大多数现代相机使用划分为像素的固态传感器；每个像素统计一段时间内、一定波长范围中到达的光子数。准确建立传感器光测量的辐射度学模型，是模拟成像过程的重要部分。
]

#parec[
  To that end, all of `pbrt`'s camera models use an instance of the #link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] class, which defines the basic interface for the classes that represent images captured by cameras. We describe two film implementations in this chapter, both of which use the #link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#PixelSensor")[`PixelSensor`] class to model the spectral response of a particular image sensor, be it film or digital. The film and sensor classes are described in the final section of this chapter.
][
  为此，`pbrt` 的所有相机模型都使用一个 #link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] 实例，该类为表示相机所捕获图像的各种类定义了基本接口。本章介绍两种胶片实现，它们都使用 #link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#PixelSensor")[`PixelSensor`] 类模拟特定图像传感器的光谱响应，无论它使用胶片还是数字传感器。胶片类与传感器类将在本章最后一节介绍。
]
