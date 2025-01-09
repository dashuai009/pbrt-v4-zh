#import "../template.typ": parec

// 2025.1.10 已整理

// TODO.翻译斟酌：
// Second, emission and reflection properties of objects
// -> 物体的辐射与反射属性 vs. 物体的发射与反射属性

= Radiometry, Spectra, and Color
<Radiometry_Spectra_and_Color>

#figure(image("../pbr-book-website/4ed/openers/transparent-machines-812.jpg"))

#parec[
  To precisely describe how light is represented and sampled to compute images, we must first establish some background in #emph[radiometry];—the study of the propagation of electromagnetic radiation in an environment. In this chapter, we will first introduce four key quantities that describe electromagnetic radiation: flux, intensity, irradiance, and radiance.
][
  为了精确描述光在图像计算中的表示与采样方式，我们必须首先建立一些 #emph[辐射度量学]（Radiometry）的背景知识——这是研究电磁辐射在环境中传播的学科。
  在本章中，我们将首先介绍描述电磁辐射的四个关键量：通量（Flux）、辐射强度（Intensity）、辐照度（Irradiance）和辐射亮度（Radiance）。
]

#parec[
  These radiometric quantities generally vary as a function of wavelength.
  The variation of each is described by its #emph[spectral distribution];—a distribution function that gives the amount of light at each wavelength.
  (We will interchangeably use #emph[spectrum] to describe spectral distributions, and #emph[spectra] for a plurality of them.)
  Of particular interest in rendering are the wavelengths ($lambda$) of electromagnetic radiation between approximately 380 nm and 780 nm, which account for light visible to humans.
  #footnote[The full range of perceptible wavelengths slightly extends beyond this interval, though the eye's sensitivity at these wavelengths is lower by many orders of magnitude. The range 360-830 nm is often used as a conservative bound when tabulating spectral curves.]
  A variety of classes that are used to represent spectral distributions in `pbrt` are defined in @representing-spectral-distributions.
][
  这些辐射度的量通常是波长的函数。
  每个量的变化由其 #emph[光谱分布（Spectral Distribution）]; 描述——一种在每个波长上给出光强度的分布函数。
  （我们会将 #emph[光谱（Spectrum）]; 作为光谱分布的同义词使用，并使用 #emph[光谱集（Spectra）]; 表示多个光谱分布。）
  在渲染领域，特别关注波长（wavelength）（ $lambda$ ）大约在 380 纳米至 780 纳米之间的电磁辐射，这一范围对应人类可见光。
  #footnote[可感知的完整波长范围略微超出了这个区间，尽管在这些波长下人眼的感光能力要低许多个数量级。在列举光谱曲线时，通常使用 360-830 纳米（nm）的范围作为保守界限。]
  在 `pbrt` 中，用于表示光谱分布的多种类在 @representing-spectral-distributions 部分有详细定义。
]

#parec[
  While spectral distributions are a purely physical concept, color is related to how humans perceive spectra.
  The lower wavelengths of light ($lambda approx 400 "nm"$) are said to be bluish colors, the middle wavelengths ($lambda approx 550 "nm"$) greens, and the upper wavelengths ($lambda approx 650 "nm"$) reds.
  It is important to have accurate models of color for two reasons:
  first, display devices like monitors expect colors rather than spectra to describe pixel values, so accurately converting spectra to appropriate colors is important for displaying rendered images.
  Second, emission and reflection properties of objects in scenes are often specified using colors; these colors must be converted into spectra for use in rendering.
  @color, at the end of this chapter, describes the properties of color in more detail and includes implementations of `pbrt`'s color-related functionality.
][
  虽然光谱分布是一个纯粹的物理概念，但颜色则与人类感知光谱的方式密切相关。
  较短波长的光（$lambda approx 400 "nm"$）通常被感知为蓝色，中间波长（$lambda approx 550 "nm"$）被感知为绿色，而较长波长（$lambda approx 650 "nm"$）则被感知为红色。
  准确建模颜色在渲染中有两个重要原因：
  首先，显示设备（如显示器）需要用颜色而非光谱来描述像素值，因此准确地将光谱转换为适当的颜色对于显示渲染图像很重要。
  其次，场景中物体的辐射与反射属性通常以颜色的形式进行定义，而在渲染计算中，需要将这些颜色转换为对应的光谱分布才能进行物理上准确的计算。
  本章末尾的 @color 更详细地描述了颜色的属性，并包含了 `pbrt` 中与颜色相关功能的具体实现。
]
