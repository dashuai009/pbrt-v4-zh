#import "../template.typ": parec

= Cameras and Film
<cameras-and-film>

#figure(image("../pbr-book-website/4ed/openers/landscape-dof.jpg"))

#parec[
  In @introduction, we described the pinhole camera model that is commonly used in computer graphics. This model is easy to describe and simulate, but it neglects important effects that physical lenses have on light passing through them. For example, everything rendered with a pinhole camera is in sharp focus—a state of affairs not possible with real lens systems. Such images often look computer generated for their perfection. More generally, the distribution of radiance leaving a lens system is quite different from the distribution entering it; modeling this effect of lenses is important for accurately simulating the radiometry of image formation.
][
  在@introduction 中，我们描述了计算机图形学中常用的针孔相机模型。这个模型易于描述和模拟，但它忽略了物理镜头对通过的光的影响。 例如，用针孔相机渲染的所有东西都是清晰对焦的状态——这在真实镜头系统中是无法实现的。由于其完美性，这样的图像常常看起来是计算机生成的。 普遍来说，镜头系统中离开的光的辐射分布与进入的分布截然不同；模拟镜头的这种效果对于准确模拟图像形成的辐射度至关重要。
]


#parec[
  Camera lens systems introduce various aberrations that affect the images that they form; for example, #emph[vignetting] causes a darkening toward the edges of images due to less light making it through to the edges of the film or sensor than to the center. Lenses can also cause #emph[pincushion] or #emph[barrel] distortion, which causes straight lines to be imaged as curves. Although lens designers work to minimize aberrations in their designs, they can still have a meaningful effect on images.
][
  相机镜头系统引入了各种影响图像生成的像差；例如，#emph[渐晕效应];由于光线到达胶片或传感器边缘的量少于中心，导致图像边缘变暗。 镜头还可能导致#emph[枕形];或#emph[桶形];畸变，使直线被成像为曲线。尽管镜头设计师努力在设计中尽量减少像差，但它们仍然会对图像产生有意义的影响。
]

#parec[
  This chapter starts with a description of the `Camera` interface, after which we present a few implementations, starting with ideal pinhole models.
][
  本章从描述`Camera`接口开始，然后我们介绍一些实现，从理想的针孔模型开始。
]

#parec[
  After light has been captured by a camera, it is measured by a sensor. While traditional film uses a chemical process to measure light, most modern cameras use solid-state sensors that are divided into pixels, each of which counts the number of photons that arrive over a period of time for some range of wavelengths. Accurately modeling the radiometry of how sensors measure light is an important part of simulating the process of image formation.
][
  当光被相机捕获后，由传感器进行测量。传统胶片使用化学过程来测量光，而大多数现代相机使用固态传感器，这些传感器被划分为像素，每个像素计算在一段时间内某个波长范围内到达的光子数量。 准确模拟传感器如何测量光的辐射度是模拟图像形成过程的重要部分。
]

#parec[
  To that end, all of `pbrt`'s camera models use an instance of the #link("Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] class, which defines the basic interface for the classes that represent images captured by cameras. We describe two film implementations in this chapter, both of which use the #link("Cameras_and_Film/Film_and_Imaging.html#PixelSensor")[`PixelSensor`] class to model the spectral response of a particular image sensor, be it film or digital. The film and sensor classes are described in the final section of this chapter.
][
  为此，所有`pbrt`的相机模型都用到了类#link("Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`];，该类定义了表示相机捕获图像的基本接口。 本章描述了两种胶片实现，它们都使用#link("Cameras_and_Film/Film_and_Imaging.html#PixelSensor")[`PixelSensor`];类来模拟特定图像传感器（无论是胶片还是数字）的光谱响应。 胶片和传感器类在本章的最后一节中描述。
]
