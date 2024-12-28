#import "../template.typ": parec


= Radiometry, Spectra, and Color
<Radiometry_Spectra_and_Color>


#figure(image("../pbr-book-website/4ed/openers/transparent-machines-812.jpg"))

#parec[
  To precisely describe how light is represented and sampled to compute images, we must first establish some background in #emph[radiometry];—the study of the propagation of electromagnetic radiation in an environment. In this chapter, we will first introduce four key quantities that describe electromagnetic radiation: flux, intensity, irradiance, and radiance.
][
  为了精确描述光如何被表示和采样以计算图像，我们首先必须建立一些关于#emph[辐射度量学];的背景知识——即研究电磁辐射在环境中传播的学科。在本章中，我们将首先介绍描述电磁辐射的四个关键量：通量、辐射强度、辐照度和辐射亮度。
]

#parec[
  These radiometric quantities generally vary as a function of wavelength. The variation of each is described by its #emph[spectral distribution];—a distribution function that gives the amount of light at each wavelength. (We will interchangeably use #emph[spectrum] to describe spectral distributions, and #emph[spectra] for a plurality of them.) Of particular interest in rendering are the wavelengths ($lambda$) of electromagnetic radiation between approximately 380 nm and 780 nm, which account for light visible to humans.#footnote[The full range of perceptible wavelengths
slightly extends beyond this interval, though the eye's sensitivity at
these wavelengths is lower by many orders of magnitude.  The range
360-830 nm is often used as a conservative bound when tabulating spectral
curves.] A variety of classes that are used to represent spectral distributions in `pbrt` are defined in @representing-spectral-distributions.
][
  这些辐射度的量通常是波长的函数。每个量的变化由其#emph[光谱分布];描述——一个分布函数，给出每个波长的光的量。（我们将使用#emph[光谱];来描述光谱分布，使用#emph[光谱集];来表示其复数形式。）在渲染中特别感兴趣的是大约在380nm到780nm之间的电磁辐射的波长（$lambda$)，这些波长构成了人类可见光。 在`pbrt`中用于表示光谱分布的各种类@representing-spectral-distributions 中定义。
]


#parec[
  While spectral distributions are a purely physical concept, color is related to how humans perceive spectra. The lower wavelengths of light ($lambda approx 400 "nm"$) are said to be bluish colors, the middle wavelengths ($lambda approx 550 "nm"$) greens, and the upper wavelengths ($lambda approx 650 "nm"$) reds. It is important to have accurate models of color for two reasons: first, display devices like monitors expect colors rather than spectra to describe pixel values, so accurately converting spectra to appropriate colors is important for displaying rendered images. Second, emission and reflection properties of objects in scenes are often specified using colors; these colors must be converted into spectra for use in rendering. @color, at the end of this chapter, describes the properties of color in more detail and includes implementations of `pbrt`'s color-related functionality.
][
  虽然光谱分布是一个纯粹的物理概念，但颜色与人类如何感知光谱有关。较短波长的光（$lambda approx 400 "nm"$）被认为是蓝色，中间波长（$lambda approx 550 "nm"$）是绿色，而较长波长（$lambda approx 650 "nm"$）是红色。 准确的颜色模型至关重要，原因有二：首先，显示设备（如显示器）需要用颜色而非光谱来描述像素值，因此准确地将光谱转换为适当的颜色对于显示渲染图像很重要。其次，场景中物体的辐射和反射特性通常使用颜色指定；这些颜色需要转换为光谱以便渲染。 本章末尾的@color 更详细地描述了颜色的属性，并包括`pbrt`的颜色相关功能的实现。
]


