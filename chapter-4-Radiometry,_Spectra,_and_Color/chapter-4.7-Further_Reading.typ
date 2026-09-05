#import "../template.typ": parec, ez_caption, source-cite

== #ez_caption[Further Reading][延伸阅读]
<radiometry-further-reading>

#parec[
  McCluney's book on radiometry is an excellent introduction to the topic (McCluney #source-cite("McCluney94")). Preisendorfer (#source-cite("Preisendorfer65")) also covered radiometry in an accessible manner and delved into the relationship between radiometry and the physics of light. Nicodemus et al. (#source-cite("Nicodemus77")) carefully defined the BRDF, BSSRDF, and various quantities that can be derived from them.
][
  McCluney 的辐射度量学著作是这一主题的优秀入门读物（McCluney #source-cite("McCluney94")）。Preisendorfer（#source-cite("Preisendorfer65")）也以易于理解的方式介绍了辐射度量学，并深入讨论了它与光的物理学之间的关系。Nicodemus 等人（#source-cite("Nicodemus77")）严格定义了 BRDF、BSSRDF 及由它们导出的各种量。
]

#parec[
  Books by Moon and Spencer (#source-cite("Moon36"), #source-cite("Moon48")) and Gershun (#source-cite("Gershun39")) are classic early introductions to radiometry. Lambert's seminal early writings about photometry from the mid-18th century have been translated into English by DiLaura (Lambert #source-cite("Lambert1760")).
][
  Moon 和 Spencer（#source-cite("Moon36")、#source-cite("Moon48")）以及 Gershun（#source-cite("Gershun39")）的著作是辐射度量学的早期经典入门读物。Lambert 在 18 世纪中叶撰写的开创性光度学著作已由 DiLaura 译为英文（Lambert #source-cite("Lambert1760")）。
]

#parec[
  Preisendorfer (#source-cite("Preisendorfer65")) has connected radiative transfer theory to Maxwell's classical equations describing electromagnetic fields, and further work was done in this area by Fante (#source-cite("Fante81")). Going well beyond earlier work that represented radiance with Wigner distribution functions to model wave effects (Oh #source-cite("Oh2010"), Cuypers et al. #source-cite("Cuypers2012")), Steinberg and Yan (#source-cite("Steinberg2021")) have recently introduced a comprehensive model of light transport based on a wave model, including a generalization of the light transport equation.
][
  Preisendorfer（#source-cite("Preisendorfer65")）将辐射传输理论与描述电磁场的经典 Maxwell 方程联系起来，Fante（#source-cite("Fante81")）在这一方向作了进一步研究。早期工作用 Wigner 分布函数表示辐亮度，以模拟波动效应（Oh #source-cite("Oh2010")；Cuypers 等人 #source-cite("Cuypers2012")）。Steinberg 和 Yan（#source-cite("Steinberg2021")）在此基础上大幅推进，提出了基于波动模型的完整光传输模型，其中包括光传输方程的推广。
]

#parec[
  Correctly implementing radiometric computations can be tricky: one missed cosine factor and one is computing a completely different quantity than expected. Debugging these sorts of issues can be quite time-consuming. Ou and Pellacini (#source-cite("Ou2010")) showed how to use C++'s type system to associate units with each term of these sorts of computations so that, for example, trying to add a radiance value to another value that represents irradiance would trigger a compile time error.
][
  正确实现辐射度量学计算并不容易：只要漏掉一个余弦因子，计算的就可能是与预期完全不同的物理量。排查这类问题往往很耗时。Ou 和 Pellacini（#source-cite("Ou2010")）展示了如何利用 C++ 类型系统，为这类计算中的各项关联单位。例如，试图把辐亮度值与辐照度值相加时，就会触发编译错误。
]

#parec[
  The books by McCluney (#source-cite("McCluney94")) and Malacara (#source-cite("Malacara02")) discuss blackbody emitters and the standard illuminants in detail. The Standard Illuminants are defined in a CIE Technical Report (#source-cite("Report2004")); Judd et al. (#source-cite("Judd1964")) developed the approach that was used to define the D Standard Illuminant.
][
  McCluney（#source-cite("McCluney94")）和 Malacara（#source-cite("Malacara02")）的著作详细讨论了黑体发射体和标准照明体。标准照明体由 CIE 技术报告（#source-cite("Report2004")）定义；定义 D 标准照明体所用的方法由 Judd 等人（#source-cite("Judd1964")）提出。
]

#parec[
  Wilkie and Weidlich (#source-cite("Wilkie2011")) noted that common practice in rendering has been to use the blackbody distribution of @eqt:plancks-law to model light emission for rendering, while Kirchhoff's law, @eqt:kirchoffs-law, would be more accurate. They also pointed out that as objects become hot, their BRDFs often change, which makes Kirchhoff's law more difficult to adopt, especially in that models that account for the effect of temperature variation on BRDFs generally are not available.
][
  Wilkie 和 Weidlich（#source-cite("Wilkie2011")）指出，渲染中通常用 @eqt:plancks-law 的黑体分布模拟光发射，而使用 Kirchhoff 定律（@eqt:kirchoffs-law）会更加准确。他们还指出，物体受热后 BRDF 往往会改变，使得采用 Kirchhoff 定律更加困难；尤其是，通常缺少描述温度变化如何影响 BRDF 的模型。
]

#heading(level: 3, numbering: none)[#ez_caption[Spectral Representations][光谱表示]]

#parec[
  Meyer was one of the first researchers to closely investigate spectral representations in graphics (Meyer and Greenberg #source-cite("Meyer80"); Meyer et al. #source-cite("Meyer86")). Hall (#source-cite("Hall89")) summarized the state of the art in spectral representations through 1989, and Glassner's #emph[Principles of Digital Image Synthesis] (#source-cite("Glassner:PODIS")) covers the topic through the mid-1990s. Survey articles by Hall (#source-cite("Hall:1999:CSC")), Johnson and Fairchild (#source-cite("Johnson1999")), and Devlin et al. (#source-cite("Devlin02")) are good resources on early work on this topic.
][
  Meyer 是最早深入研究图形学中光谱表示的研究者之一（Meyer 和 Greenberg #source-cite("Meyer80")；Meyer 等人 #source-cite("Meyer86")）。Hall（#source-cite("Hall89")）总结了截至 1989 年的光谱表示研究进展；Glassner 的《Principles of Digital Image Synthesis》（#source-cite("Glassner:PODIS")）则覆盖到 20 世纪 90 年代中期。Hall（#source-cite("Hall:1999:CSC")）、Johnson 和 Fairchild（#source-cite("Johnson1999")）以及 Devlin 等人（#source-cite("Devlin02")）的综述，是了解这一主题早期工作的良好资料。
]

#parec[
  Borges (#source-cite("Borges1991")) analyzed the error introduced from the tristimulus representation when used for spectral computation. A variety of approaches based on representing spectra using basis functions have been developed, including Peercy (#source-cite("Peercy93")), who developed a technique based on choosing basis functions in a scene-dependent manner by considering the spectral distributions of the lights and reflecting objects in the scene. Rougeron and Péroche (#source-cite("Rougeron97")) projected all spectra in the scene onto a hierarchical basis (the Haar wavelets), and showed that this adaptive representation can be used to stay within a desired error bound. Ward and Eydelberg-Vileshin (#source-cite("Ward02")) developed a method for improving the spectral fidelity of regular RGB-only rendering systems by carefully adjusting the color values provided to the system before rendering.
][
  Borges（#source-cite("Borges1991")）分析了将三刺激表示用于光谱计算时引入的误差。研究者提出了多种用基函数表示光谱的方法。例如，Peercy（#source-cite("Peercy93")）根据场景中光源和反射物体的光谱分布，选择与场景相关的基函数。Rougeron 和 Péroche（#source-cite("Rougeron97")）把场景中的全部光谱投影到层次基（Haar 小波）上，并证明这种自适应表示可以将误差控制在指定界限内。Ward 和 Eydelberg-Vileshin（#source-cite("Ward02")）则在渲染前仔细调整输入颜色值，以提高仅使用 RGB 的常规渲染系统的光谱保真度。
]

#parec[
  Another approach to spectral representation was investigated by Sun et al. (#source-cite("Sun01")), who partitioned spectral distributions into a smooth base distribution and a set of spikes. Each part was represented differently, using basis functions that worked well for each of these parts of the distribution. Drew and Finlayson (#source-cite("Drew2003")) applied a “sharp” basis, which is adaptive but has the property that computing the product of two functions in the basis does not require a full matrix multiplication as many other basis representations do.
][
  Sun 等人（#source-cite("Sun01")）研究了另一种光谱表示方法，将光谱分布分解为平滑的基础分布与一组尖峰，再为这两部分分别采用适合的基函数表示。Drew 和 Finlayson（#source-cite("Drew2003")）采用了自适应的“尖锐”基；这种基的一个特点是，计算两个函数的乘积时，不必像许多其他基表示那样进行完整的矩阵乘法。
]

#parec[
  Both Walter et al. (#source-cite("Walter:1997:GIU")) and Morley et al. (#source-cite("Morley2006")) described light transport algorithms based on associating a single wavelength with each light path. Evans and McCool (#source-cite("Evans1999")) generalized these techniques with stratified wavelength clusters, which are effectively the approach implemented in `SampledSpectrum` and `SampledWavelengths`.
][
  Walter 等人（#source-cite("Walter:1997:GIU")）和 Morley 等人（#source-cite("Morley2006")）都介绍了为每条光路关联单一波长的光传输算法。Evans 和 McCool（#source-cite("Evans1999")）用分层波长簇推广了这些技术，`SampledSpectrum` 和 `SampledWavelengths` 实现的基本就是这种方法。
]

#parec[
  Radziszewski et al. (#source-cite("Radziszewski2009")) noted that it is not necessary to terminate all secondary spectral wavelengths when effects like dispersion happen at non-specular interfaces; they showed that it is possible to compute all wavelengths' contributions for a single path, weighting the results using multiple importance sampling. Wilkie et al. (#source-cite("Wilkie2014")) used equally spaced point samples in the wavelength domain and showed how this approach can also be used for photon mapping and rendering of participating media.
][
  Radziszewski 等人（#source-cite("Radziszewski2009")）指出，当色散等效应发生在非镜面界面时，不必终止所有次级波长；可以在同一条路径上计算所有波长的贡献，并用多重重要性采样加权结果。Wilkie 等人（#source-cite("Wilkie2014")）在波长域中采用等间距点样本，并展示了如何将这一方法用于光子映射及参与介质的渲染。
]

#heading(level: 3, numbering: none)[#ez_caption[Color][颜色]]

#parec[
  For background information on properties of the human visual system, Wandell's book on vision is an excellent starting point (Wandell #source-cite("Wandell95")). Ferwerda (#source-cite("Ferwerda01")) presented an overview of the human visual system for applications in graphics, and Malacara (#source-cite("Malacara02")) gave a concise overview of color theory and basic properties of how the human visual system processes color. Ciechanowski (#source-cite("Ciechanowski2019")) presented an excellent interactive introduction to color spaces; his treatment has influenced our presentation of the XYZ color space and chromaticity.
][
  关于人类视觉系统的背景知识，Wandell 的视觉学著作是很好的起点（Wandell #source-cite("Wandell95")）。Ferwerda（#source-cite("Ferwerda01")）面向图形学应用概述了人类视觉系统，Malacara（#source-cite("Malacara02")）则简要介绍了颜色理论以及视觉系统处理颜色的基本特性。Ciechanowski（#source-cite("Ciechanowski2019")）提供了优秀的交互式颜色空间入门介绍，本书对 XYZ 颜色空间和色度的讲解也受到了他的影响。
]

#parec[
  A number of different approaches have been developed for mapping out-of-gamut colors to ones that can be displayed on a device with particular display primaries. This problem can manifest itself in a few ways: a color's chromaticity may be outside of the displayed range, its chromaticity may be valid but it may be too bright for display, or both may be out of range.
][
  研究者提出了许多方法，将色域外的颜色映射为采用特定显示基色的设备能够显示的颜色。超出显示范围可能有几种情况：颜色的色度位于可显示范围之外；色度有效，但颜色过亮而无法显示；或两者同时超出范围。
]

#parec[
  For the issue of how to handle colors with undisplayable chromaticities, see Rougeron and Péroche's survey article, which includes references to many approaches (Rougeron and Péroche #source-cite("Rougeron98")). This topic was also covered by Hall (#source-cite("Hall89")). Morovi's book (#source-cite("Morovi2008")) covers this topic, and a more recent survey has been written by Faridul et al. (#source-cite("Faridul2016")).
][
  对于无法显示的色度，Rougeron 和 Péroche（#source-cite("Rougeron98")）的综述介绍并引用了许多处理方法。Hall（#source-cite("Hall89")）也讨论了这一问题。Morovi（#source-cite("Morovi2008")）的著作覆盖了这一主题，Faridul 等人（#source-cite("Faridul2016")）则撰写了较新的综述。
]

#parec[
  While high dynamic range displays that can display a wide range of intensities are now starting to become available, most of them are still not able to reproduce the full range of brightness in rendered images. This problem can be addressed with tone reproduction algorithms that use models of human visual response to make the most of displays' available dynamic ranges. This topic became an active area of research starting with the work of Tumblin and Rushmeier (#source-cite("Tumblin93")). The survey article of Devlin et al. (#source-cite("Devlin02")) summarizes most of the work in this area through 2002, giving pointers to the original papers. See Reinhard et al.'s book (#source-cite("Reinhard10")) on high dynamic range imaging, which includes comprehensive coverage of this topic through 2010. More recently, Reinhard et al. (#source-cite("Reinhard2012")) have developed tone reproduction algorithms that consider both accurate brightness and color reproduction together, also accounting for the display and viewing environment, and Eilertsen et al. (#source-cite("Eilertsen2017")) surveyed algorithms for tone mapping of video.
][
  虽然能够显示较大强度范围的高动态范围显示器已开始出现，多数设备仍无法再现渲染图像的完整明亮程度范围。色调再现算法可以借助人类视觉响应模型，充分利用显示器可用的动态范围来处理这个问题。自 Tumblin 和 Rushmeier（#source-cite("Tumblin93")）的工作起，这一主题成为活跃的研究领域。Devlin 等人（#source-cite("Devlin02")）的综述总结了截至 2002 年的大部分相关工作，并给出了原始论文线索。Reinhard 等人（#source-cite("Reinhard10")）关于高动态范围成像的著作全面介绍了截至 2010 年的相关进展。随后，Reinhard 等人（#source-cite("Reinhard2012")）提出了同时考虑准确再现明亮程度与颜色的色调再现算法，并将显示设备及观看环境纳入考虑。Eilertsen 等人（#source-cite("Eilertsen2017")）综述了视频色调映射算法。
]

#heading(level: 3, numbering: none)[#ez_caption[From RGB to Spectra][从 RGB 转换为光谱]]

#parec[
  Glassner (#source-cite("Glassner89rgb")) did early work on converting RGB values to spectral distributions. Smits (#source-cite("Smits:1999:ARC")) optimized discrete reflectance spectra to reproduce primaries (red, green, blue) and combinations of primaries (yellow, cyan, magenta, white) based on the observation that linear interpolation in such an extended space tends to produce smoother reflectance spectra. Mallett and Yuksel (#source-cite("Mallett2019")) presented a surprising result showing that linear interpolation of three carefully chosen spectra can fully cover the sRGB gamut, albeit at some cost in terms of smoothness. Meng et al. (#source-cite("Meng2015")) optimized a highly smooth spectral interpolant based on a dense sampling of the space of $x y$ chromaticities, enabling usage independent of any specific RGB gamut.
][
  Glassner（#source-cite("Glassner89rgb")）较早研究了将 RGB 值转换为光谱分布的问题。Smits（#source-cite("Smits:1999:ARC")）观察到，在扩展颜色空间中进行线性插值往往能得到更平滑的反射率光谱，因此优化了再现基色（红、绿、蓝）及其组合（黄、青、品红、白）的离散反射率光谱。Mallett 和 Yuksel（#source-cite("Mallett2019")）给出了一个出人意料的结果：对三个精心选择的光谱进行线性插值，就能完全覆盖 sRGB 色域，代价是牺牲一些平滑性。Meng 等人（#source-cite("Meng2015")）在 $x y$ 色度空间密集采样，优化得到高度平滑的光谱插值函数，使其使用不依赖于任何特定 RGB 色域。
]

#parec[
  The method described in @from-rgb-to-specturm was developed by Jakob and Hanika (#source-cite("Jakob2019")). Several properties motivated its choice in `pbrt`: the spectral representation is based on a smooth function family with 3 parameters (i.e., the same dimension as an RGB). Conversion can then occur in two steps: a preprocessing step (e.g., per texel) replaces RGB values with polynomial coefficients, while the performance-critical evaluation at render time only requires a few floating-point instructions. Jung et al. (#source-cite("Jung2019")) extended this approach, using fluorescence to permit conversion of highly saturated RGB values that cannot be recreated using reflection alone.
][
  @from-rgb-to-specturm 中的方法由 Jakob 和 Hanika（#source-cite("Jakob2019")）提出。`pbrt` 选择它是因为几个特点：光谱表示采用具有 3 个参数的平滑函数族，与 RGB 的维数相同；转换可分为两步，先在预处理阶段（例如逐纹素）把 RGB 值替换为多项式系数，然后在性能敏感的渲染阶段，只需几条浮点指令即可求值。Jung 等人（#source-cite("Jung2019")）利用荧光扩展了该方法，使其能转换单靠反射无法再现的高饱和度 RGB 值。
]

#parec[
  Peters et al. (#source-cite("Peters2019:moments")) proposed a powerful parameterization of smooth reflectance spectra in terms of Fourier coefficients. Instead of using them in a truncated Fourier series, which would suffer from ringing, they built on the theory of moments to reconstruct smooth and energy-conserving spectra.
][
  Peters 等人（#source-cite("Peters2019:moments")）提出了用傅里叶系数参数化平滑反射率光谱的有力方法。他们没有把系数用于截断傅里叶级数，因为那会产生振铃；而是借助矩理论重建平滑且满足能量守恒的光谱。
]

#parec[
  The previous methods all incorporated smoothness as a central design constraint. While natural spectra indeed often tend to be smooth, maximally smooth spectra are not necessarily the most natural, especially when more information about the underlying type of material is available. Otsu et al. (#source-cite("Otsu2018:rgb")) processed a large database of measured spectra, using principal component analysis to create a data-driven interpolant. Tódová et al. (#source-cite("Todova2021")) built on the moment-based method by Peters et al. (#source-cite("Peters2019:moments")) to precompute an efficient spectral interpolant that is designed to reproduce user-specified spectra for certain RGB inputs.
][
  上述方法都将平滑性作为核心设计约束。尽管自然光谱往往平滑，最平滑的光谱却未必最自然；当已知更多材料类型信息时，尤其如此。Otsu 等人（#source-cite("Otsu2018:rgb")）处理了大型实测光谱数据库，用主成分分析构造数据驱动的插值函数。Tódová 等人（#source-cite("Todova2021")）基于 Peters 等人（#source-cite("Peters2019:moments")）的矩方法，预计算了高效的光谱插值函数，使某些 RGB 输入能够再现用户指定的光谱。
]
