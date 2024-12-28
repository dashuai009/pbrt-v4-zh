#import "../template.typ": parec

== Further_Reading

#parec[
  The cone-tracing method of Amanatides (1984) was one of the first techniques for automatically estimating filter footprints for ray tracing. The beam-tracing algorithm of Heckbert and Hanrahan (1984) was another early extension of ray tracing to incorporate an area associated with each image sample rather than just an infinitesimal ray. The pencil-tracing method of Shinya et al.~(1987) is another approach to this problem.
][
  Amanatides（1984）的圆锥追踪方法是自动估计光线追踪滤波足迹的最早技术之一。Heckbert和Hanrahan（1984）的光束追踪算法是光线追踪的另一个早期扩展，它结合了与每个图像样本相关的区域，而不仅仅是一个微小的光线。Shinya等人（1987）的铅笔光线追踪方法是解决该问题的另一种方法。
]

#parec[
  Other related work on the topic of associating areas or footprints with rays includes Mitchell and Hanrahan's paper (1992) on rendering caustics and Turkowski's technical report (1993).
][
  其他与将区域或足迹与光线关联的相关工作包括Mitchell和Hanrahan（1992）关于焦散渲染的论文以及Turkowski（1993）的技术报告。
]

#parec[
  Collins (1994) estimated the ray footprint by keeping a tree of all rays traced from a given camera ray, examining corresponding rays at the same level and position. The ray differentials used in pbrt are based on Igehy's (1999) formulation, which was extended by Suykens and Willems (2001) to handle glossy reflection in addition to perfect specular reflection.
][
  Collins（1994）通过保留从给定相机光线追踪的所有光线的树来估计光线足迹，检查相同级别和位置的相应光线。`pbrt`中使用的光线微分基于Igehy（1999）的公式，Suykens和Willems（2001）将其扩展以处理光泽反射以及完美镜面反射。
]

#parec[
  Belcour et al.~(2017) applied Fourier analysis to the light transport equation in order to accurately and efficiently track ray footprints after scattering.
][
  Belcour等人（2017）应用傅里叶分析到光传输方程，以便在散射后准确高效地跟踪光线足迹。
]

#parec[
  Twelve floating-point values are required to store ray differentials, and Belcour et al.'s approach has similar storage requirements. This poses no challenge in a CPU ray tracer that only operates on one or a few rays at a time, but can add up to a considerable amount of storage (and consequently, bandwidth consumption) on the GPU.
][
  存储光线微分需要十二个浮点值，Belcour等人的方法具有类似的存储要求。这在仅对一个或几个光线同时操作的CPU光线追踪器中不构成挑战，但在GPU上可能会增加相当大的存储量（因此带宽消耗）。
]

#parec[
  To address this issue, Akenine-Möller et al.~(2019) developed a number of more space-efficient alternatives and showed their effectiveness for antialiasing that was further improved in subsequent work (Akenine-Möller et al.~2021; Boksansky et al.~2021).
][
  为了解决这个问题，Akenine-Möller等人（2019）开发了一些更节省空间的替代方案，并展示了它们在后续工作中进一步改进的抗锯齿（Akenine-Möller等人2021；Boksansky等人2021）。
]

#parec[
  The approach we have implemented in CameraBase::Approximate\_dp\_dxy() was described by Li (2018).
][
  我们在#link("../Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#CameraBase::Approximate_dp_dxy")[CameraBase::Approximate\_dp\_dxy()];中实现的方法由Li（2018）描述。
]

#parec[
  Worley's chapter in Texturing and Modeling (Ebert et al.~2003) on computing differentials for filter regions presents an approach similar to ours.
][
  Worley在#emph[Texturing and
Modeling];（Ebert等人2003）中关于计算滤波区域微分的章节提出了一种与我们类似的方法。
]

#parec[
  See Elek et al.~(2014) for an extension of ray differentials to include wavelength, which can improve results with spectral rendering.
][
  有关将光线微分扩展到包括波长的扩展，请参见Elek等人（2014），这可以改善光谱渲染的结果。
]

#parec[
  Two-dimensional texture mapping with images was first introduced to graphics by Blinn and Newell (1976). Ever since Crow (1977) identified aliasing as the source of many errors in images in graphics, much work has been done to find efficient and effective ways of antialiasing image maps.
][
  二维纹理映射首次由Blinn和Newell（1976）引入到图形中。自Crow（1977）识别出混叠是图形图像中许多错误的来源以来，已经进行了大量工作以寻找高效有效的纹理映射抗锯齿方法。
]

#parec[
  Dungan, Stenger, and Sutty (1978) were the first to suggest creating a pyramid of prefiltered texture images; they used the nearest texture sample at the appropriate level when looking up texture values, using supersampling in screen space to antialias the result.
][
  Dungan、Stenger和Sutty（1978）首次建议创建预滤波纹理图像的金字塔；他们在查找纹理值时使用适当级别的最近纹理样本，并在屏幕空间中使用超采样来抗锯齿结果。
]

#parec[
  Feibush, Levoy, and Cook (1980) investigated a spatially varying filter function, rather than a simple box filter.
][
  Feibush、Levoy和Cook（1980）研究了一种空间变化的滤波函数，而不是简单的盒式滤波器。
]

#parec[
  (Blinn and Newell were aware of Crow's results and used a box filter for their textures.)
][
  （Blinn和Newell知道Crow的结果，并为他们的纹理使用了盒式滤波器。）
]

#parec[
  Williams (1983) used a MIP map image pyramid for texture filtering with trilinear interpolation. Shortly thereafter, Crow (1984) introduced summed area tables, which make it possible to efficiently filter over axis-aligned rectangular regions of texture space.
][
  Williams（1983）使用MIP映射金字塔进行纹理滤波，并进行了三线性插值。不久之后，Crow（1984）引入了累加区域表，使得可以高效地在纹理空间的轴对齐矩形区域上进行滤波。
]

#parec[
  Summed area tables handle anisotropy better than Williams's method, although only for primarily axis-aligned filter regions.
][
  累加区域表比Williams的方法更好地处理各向异性，尽管仅适用于主要轴对齐的滤波区域。
]

#parec[
  Heckbert (1986) wrote a good survey of early texture mapping algorithms.
][
  Heckbert（1986）撰写了一篇关于早期纹理映射算法的良好调查。
]

#parec[
  Greene and Heckbert (1986) originally developed the elliptically weighted average technique, and Heckbert's master's thesis (1989b) put the method on a solid theoretical footing.
][
  Greene和Heckbert（1986）最初开发了椭圆加权平均技术，Heckbert的硕士论文（1989b）为该方法奠定了坚实的理论基础。
]

#parec[
  Fournier and Fiume (1988) developed an even higher-quality texture filtering method that focuses on using a bounded amount of computation per lookup.
][
  Fournier和Fiume（1988）开发了一种更高质量的纹理滤波方法，专注于在每次查找时使用有限的计算量。
]

#parec[
  Nonetheless, their method appears to be less efficient than EWA overall.
][
  然而，他们的方法似乎整体上不如EWA高效。
]

#parec[
  Lansdale's master's thesis (1991) has an extensive description of EWA and Fournier and Fiume's method, including implementation details.
][
  Lansdale的硕士论文（1991）详细描述了EWA和Fournier和Fiume的方法，包括实现细节。
]

#parec[
  A number of researchers have investigated generalizing Williams's original method using a series of trilinear MIP map samples in an effort to increase quality without having to pay the price for the general EWA algorithm.
][
  许多研究人员研究了使用一系列三线性MIP映射样本来推广Williams的原始方法，以提高质量而不必为通用EWA算法付出代价。
]

#parec[
  By taking multiple samples from the MIP map, anisotropy is handled well while preserving the computational efficiency.
][
  通过从MIP映射中获取多个样本，可以很好地处理各向异性，同时保持计算效率。
]

#parec[
  Examples include Barkans's (1997) description of texture filtering in the Talisman architecture, McCormack et al.'s (1999) Feline method, and Cant and Shrubsole's (2000) technique.
][
  示例包括Barkans（1997）对Talisman架构中纹理滤波的描述，McCormack等人（1999）的Feline方法，以及Cant和Shrubsole（2000）的技术。
]

#parec[
  Manson and Schaefer (2013, 2014) have shown how to accurately approximate a variety of filter functions with a fixed small number of bilinearly interpolated sample values.
][
  Manson和Schaefer（2013，2014）展示了如何使用固定数量的双线性插值样本值准确逼近各种滤波函数。
]

#parec[
  An algorithm to convert an arbitrary filter into a set of bilinear lookups over multiple passes subject to a specified performance target was given by Schuster et al.~(2020).
][
  Schuster等人（2020）给出了一种算法，将任意滤波器转换为在多个通道上进行双线性查找的集合，并符合指定的性能目标。
]

#parec[
  These sorts of approaches are particularly useful on GPUs, where hardware-accelerated bilinear interpolation is available.
][
  这些方法在GPU上特别有用，因为硬件加速的双线性插值是可用的。
]

#parec[
  For scenes with many image textures where reading them all into memory simultaneously has a prohibitive memory cost, an effective approach can be to allocate a fixed amount of memory for image maps (a texture cache), load textures into that memory on demand, and discard the image maps that have not been accessed recently when the memory fills up (Peachey 1990).
][
  对于具有许多图像纹理的场景，其中同时将它们全部读入内存具有高昂的内存成本，有效的方法可以是为图像映射分配固定数量的内存（#emph[纹理缓存];），根据需要将纹理加载到该内存中，并在内存填满时丢弃最近未访问的图像映射（Peachey 1990）。
]

#parec[
  To enable good performance with small texture caches, image maps should be stored in a tiled format that makes it possible to load in small square regions of the texture independently of each other.
][
  为了在小纹理缓存中实现良好的性能，图像映射应以#emph[平铺格式];存储，使得可以独立于彼此加载纹理的小方形区域。
]

#parec[
  Tiling techniques like these are used in graphics hardware to improve the performance of their texture memory caches (Hakura and Gupta 1997; Igehy et al.~1998, 1999).
][
  像这样的平铺技术在图形硬件中用于提高其纹理内存缓存的性能（Hakura和Gupta 1997；Igehy等人1998，1999）。
]

#parec[
  High-performance texture caching with parallel execution can be challenging because the cache contents may be frequently updated; it is desirable to minimize mutual exclusion in the cache implementation so that threads do not stall while others are updating the cache.
][
  高性能纹理缓存与并行执行可能具有挑战性，因为缓存内容可能会频繁更新；希望在缓存实现中最小化互斥，以便线程在其他线程更新缓存时不会停顿。
]

#parec[
  For an effective approach to this problem, see Pharr (2017), who applied the read-copy update technique (McKenney and Slingwine 1998) to accomplish this.
][
  有关此问题的有效方法，请参见Pharr（2017），他应用#emph[读-复制更新];技术（McKenney和Slingwine 1998）来实现这一点。
]

#parec[
  Smith's (2002) website and document on audio resampling gives a good overview of resampling signals in one dimension.
][
  Smith（2002）关于音频重采样的网站和文档很好地概述了一维信号的重采样。
]

#parec[
  Heckbert's (1989a) zoom source code is the canonical reference for image resampling. His implementation carefully avoids feedback without using auxiliary storage.
][
  Heckbert（1989a）的`zoom`源代码是图像重采样的经典参考。他的实现仔细避免了反馈，而不使用辅助存储。
]

#parec[
  A variety of texture synthesis algorithms have been developed that take an example texture image and then synthesize larger texture images that appear similar to the original texture while not being exactly the same.
][
  已经开发了各种#emph[纹理合成];算法，这些算法采用示例纹理图像，然后合成看起来与原始纹理相似而不完全相同的更大纹理图像。
]

#parec[
  Survey articles by Wei et al.~(2009) and Barnes and Zhang (2017) summarize work in this area.
][
  Wei等人（2009）和Barnes和Zhang（2017）的调查文章总结了该领域的工作。
]

#parec[
  Convolutional neural networks have been applied to this task (Gatys et al.~2015; Sendik and Cohen-Or 2017), giving impressive results, and Frühstück et al.~(2019) have showed the effectiveness of generative adversarial networks for this problem.
][
  卷积神经网络已应用于此任务（Gatys等人2015；Sendik和Cohen-Or 2017），并取得了令人印象深刻的结果，Frühstück等人（2019）展示了生成对抗网络在该问题上的有效性。
]


#parec[
  Three-dimensional solid texturing was originally developed by Gardner (1984, 1985), Perlin (1985a), and Peachey (1985). Norton, Rockwood, and Skolmoski (1982) developed the #emph[clamping] method that is widely used for antialiasing textures based on solid texturing.
][
  三维实体纹理最初由 Gardner（1984, 1985）、Perlin（1985a）和 Peachey（1985）开发。Norton、Rockwood 和 Skolmoski（1982）开发了广泛用于基于实体纹理的抗锯齿纹理的#emph[钳制];方法。
]

#parec[
  The general idea of procedural texturing, where texture is generated via computation rather than via looking up values from images, was introduced by Cook (1984), Perlin (1985a), and Peachey (1985).
][
  程序化纹理的总体概念，即通过计算生成纹理，而不是从图像中查找值，由 Cook（1984）、Perlin（1985a）和 Peachey（1985）引入。
]

#parec[
  #emph[Noise functions];, which randomly vary while still having limited frequency content, have been a key ingredient for many procedural texturing techniques. Perlin (1985a) introduced the first such noise function, and later revised it to correct a number of subtle shortcomings (Perlin 2002). (See also Kensler et al.~(2008) for further improvements.) Many more noise functions have been developed; see Lagae et al.~(2010) for a survey of work up to that year.
][
  #emph[噪声函数];在随机变化的同时仍具有有限的频率内容，是许多程序化纹理技术的关键成分。Perlin（1985a）引入了第一个这样的噪声函数，后来对其进行了修订以纠正一些微妙的缺陷（Perlin 2002）。(参见 Kensler 等（2008）以获取进一步的改进。)开发了更多的噪声函数；参见 Lagae 等（2010）对截至那一年的工作的调查。
]

#parec[
  Tricard et al.~(2019) recently introduced a noise function ("phasor noise") that can be filtered anisotropically and allows control of the orientation, frequency, and contrast of the noise function. Their paper also includes citations to other recent work on this topic.
][
  Tricard 等（2019）最近引入了一种噪声函数（"相量噪声"），可以各向异性地过滤，并允许控制噪声函数的方向、频率和对比度。他们的论文还包括对该主题其他近期工作的引用。
]

#parec[
  In recent years, the #emph[Shadertoy] website, #link("http://shadertoy.com")[shadertoy.com];, has become a hub of creative application of procedural modeling and texturing, all of it running interactively in web browsers. #emph[Shadertoy] was developed by Quilez and Jeremias (2021).
][
  近年来，#emph[Shadertoy] 网站，#link("http://shadertoy.com")[shadertoy.com];，已成为程序化建模和纹理创意应用的中心，所有这些都在网络浏览器中交互运行。#emph[Shadertoy] 由 Quilez 和 Jeremias（2021）开发。
]

#parec[
  The first languages and systems that supported the idea of user-supplied procedural shaders were developed by Cook (1984) and Perlin (1985a). (The texture composition model in this chapter is similar to Cook's shade trees.) The #emph[RenderMan] shading language, described in a paper by Hanrahan and Lawson (1990), remains the classic shading language in graphics, though a more modern shading language is available in #emph[Open Shading Language] (OSL) (Gritz et al.~2010), which is open source and increasingly used for production rendering.
][
  支持用户提供的程序着色器概念的第一批语言和系统由 Cook（1984）和 Perlin（1985a）开发。（本章中的纹理组合模型类似于 Cook 的着色树。）#emph[RenderMan] 着色语言，由 Hanrahan 和 Lawson（1990）在一篇论文中描述，仍然是图形学中的经典着色语言，尽管在 #emph[Open Shading Language];（OSL）（Gritz 等，2010）中有一种更现代的着色语言，它是开源的，并且越来越多地用于生产渲染。
]

#parec[
  It follows `pbrt`'s model of the shader returning a representation of the material rather than a final color value. See also Karrenberg et al.~(2010), who introduced the #emph[AnySL] shading language, which was designed for high performance as well as portability across multiple rendering systems (including `pbrt`).
][
  它遵循 `pbrt` 的着色器模型，返回材料的表示而不是最终的颜色值。另见 Karrenberg 等（2010），他们介绍了 #emph[AnySL] 着色语言，该语言旨在实现高性能以及跨多个渲染系统（包括 `pbrt`）的可移植性。
]

#parec[
  See Ebert et al.~(2003) and Apodaca and Gritz (2000) for techniques for writing procedural shaders; both of those have excellent discussions of issues related to antialiasing in procedural shaders.
][
  参见 Ebert 等（2003）和 Apodaca 和 Gritz（2000）以获取编写程序着色器的技术；这两者都对程序着色器中与抗锯齿相关的问题进行了出色的讨论。
]

#parec[
  Blinn (1978) invented the bump-mapping technique. Kajiya (1985) generalized the idea of bump mapping the normal to #emph[frame mapping];, which also perturbs the surface's primary tangent vector and is useful for controlling the appearance of anisotropic reflection models.
][
  Blinn（1978）发明了凹凸贴图技术。Kajiya（1985）将凹凸贴图法线的概念推广到#emph[框架映射];，这也扰动了表面的主要切线向量，对于控制各向异性反射模型的外观非常有用。
]

#parec[
  Normal mapping was introduced by Cohen et al.~(1998). Mikkelsen's thesis (2008) carefully investigates a number of the assumptions underlying bump mapping and normal mapping, proposes generalizations, and addresses a number of subtleties with respect to its application to real-time rendering.
][
  法线贴图由 Cohen 等（1998）引入。Mikkelsen 的论文（2008）仔细研究了凹凸贴图和法线贴图的一些基本假设，提出了推广，并解决了其在实时渲染应用中的一些细微问题。
]

#parec[
  One visual shortcoming of normal and bump mapping is that those techniques do not naturally account for self-shadowing, where bumps cast shadows on the surface and prevent light from reaching nearby points. These shadows can have a significant impact on the appearance of rough surfaces.
][
  法线和凹凸贴图的一个视觉缺陷是这些技术自然不能考虑自阴影，即凸起在表面上投下阴影并阻止光线到达附近的点。这些阴影对粗糙表面的外观有显著影响。
]

#parec[
  Max (1988) developed the #emph[horizon mapping] technique, which efficiently accounts for this effect through precomputed information about each bump map. More recently, Conty Estevez et al.~and Chiang et al.~have introduced techniques based on microfacet shadowing functions to improve the visual fidelity of bump-mapped surfaces at shadow terminators (Conty Estevez et al.~2019, Chiang et al.~2019).
][
  Max（1988）开发了#emph[地平线映射];技术，通过预先计算每个凹凸贴图的信息来有效地考虑这一效果。最近，Conty Estevez 等人和 Chiang 等人引入了基于微面阴影函数的技术，以提高凹凸贴图表面在阴影终止点的视觉保真度（Conty Estevez 等，2019，Chiang 等，2019）。
]

#parec[
  Another challenging issue is that antialiasing bump and normal maps that have higher-frequency detail than can be represented in the image is quite difficult. In particular, it is not enough to remove high-frequency detail from the underlying function, but in general, the BSDF needs to be modified to account for this detail.
][
  另一个具有挑战性的问题是抗锯齿凹凸和法线贴图的细节频率高于图像中可以表示的频率是相当困难的。特别是，仅仅去除基础函数的高频细节是不够的，但通常需要修改 BSDF 以考虑这些细节。
]

#parec[
  Fournier (1992) applied normal distribution functions to this problem, where the surface normal was generalized to represent a distribution of normal directions. Becker and Max (1993) developed algorithms for blending between bump maps and BRDFs that represented higher-frequency details.
][
  Fournier（1992）将法线分布函数应用于这个问题，其中表面法线被推广为表示法线方向的分布。Becker 和 Max（1993）开发了在表示高频细节的凹凸贴图和 BRDF 之间进行混合的算法。
]

#parec[
  Schilling (1997, 2001) investigated this issue particularly for application to graphics hardware. Effective approaches to filtering bump maps were developed by Han et al.~(2007) and Olano and Baker (2010).
][
  Schilling（1997, 2001）特别研究了将其应用于图形硬件的问题。Han 等（2007）和 Olano 和 Baker（2010）开发了有效的凹凸贴图过滤方法。
]

#parec[
  Both Dupuy et al.~(2013) and Hery et al.~(2014) developed techniques that convert displacements into anisotropic distributions of Beckmann microfacets. Further improvements to these approaches were introduced by Kaplanyan et al.~(2016), Tokuyoshi and Kaplanyan (2019), and Wu et al.~(2019).
][
  Dupuy 等（2013）和 Hery 等（2014）开发了将位移转换为 Beckmann 微面各向异性分布的技术。Kaplanyan 等（2016）、Tokuyoshi 和 Kaplanyan（2019）以及 Wu 等（2019）引入了对这些方法的进一步改进。
]

#parec[
  A number of researchers have looked at the issue of antialiasing surface reflection functions. Early work in this area was done by Amanatides, who developed an algorithm to detect specular aliasing for a specific BRDF model (Amanatides 1992).
][
  许多研究人员研究了表面反射函数的抗锯齿问题。Amanatides 在该领域的早期工作中开发了一种算法，用于检测特定 BRDF 模型的镜面混叠（Amanatides 1992）。
]

#parec[
  Van Horn and Turk (2008) developed an approach to automatically generate MIP maps of reflection functions that represent the characteristics of shaders over finite areas in order to antialias them. Bruneton and Neyret (2012) surveyed the state of the art in this area, and Jarabo et al.~(2014b) also considered perceptual issues related to filtering inputs to these functions.
][
  Van Horn 和 Turk（2008）开发了一种方法，自动生成反射函数的 MIP 映射，这些映射表示着色器在有限区域内的特性，以便对其进行抗锯齿处理。Bruneton 和 Neyret（2012）调查了该领域的最新技术，Jarabo 等（2014b）也考虑了与这些函数输入过滤相关的感知问题。
]

#parec[
  See also Heitz et al.~(2014) for further work on this topic.
][
  另见 Heitz 等（2014）以获取关于该主题的进一步工作。
]

#parec[
  An alternative to bump mapping is displacement mapping, where the bump function is used to actually modify the surface geometry, rather than just perturbing the normal (Cook 1984; Cook et al.~1987).
][
  凹凸贴图的替代方法是位移映射，其中凹凸函数用于实际修改表面几何形状，而不仅仅是扰动法线（Cook 1984；Cook 等，1987）。
]

#parec[
  Advantages of displacement mapping include geometric detail on object silhouettes and the possibility of accounting for self-shadowing. Patterson and collaborators described an innovative algorithm for displacement mapping with ray tracing where the geometry is unperturbed, but the ray's direction is modified such that the intersections that are found are the same as would be found with the displaced geometry (Patterson et al.~1991; Logie and Patterson 1994).
][
  位移映射的优点包括对象轮廓上的几何细节以及考虑自阴影的可能性。Patterson 和合作者描述了一种创新的光线追踪位移映射算法，其中几何形状不受扰动，但光线的方向被修改，以便找到的交点与位移几何形状相同（Patterson 等，1991；Logie 和 Patterson，1994）。
]

#parec[
  Heidrich and Seidel (1998) developed a technique for computing direct intersections with procedurally defined displacement functions.
][
  Heidrich 和 Seidel（1998）开发了一种计算程序定义的位移函数直接交点的技术。
]

#parec[
  One approach for displacement mapping has been to use an implicit function to define the displaced surface and to then take steps along rays until a zero crossing with the implicit function is found—this point is an intersection.
][
  位移映射的一种方法是使用隐函数来定义位移表面，然后沿光线逐步前进，直到找到与隐函数的零交叉点——该点是一个交点。
]

#parec[
  This approach was first introduced by Hart (1996); see Donnelly (2005) for information about using this approach for displacement mapping on the GPU. (This approach was more recently popularized by Quilez (2015) on the #emph[Shadertoy] website.)
][
  Hart（1996）首次引入了这种方法；有关在 GPU 上使用这种方法进行位移映射的信息，请参见 Donnelly（2005）。(这种方法最近由 Quilez（2015）在 #emph[Shadertoy] 网站上推广。)
]

#parec[
  Another option is to finely tessellate the scene geometry and displace its vertices to define high-resolution meshes. Pharr and Hanrahan (1996) described an approach to this problem based on geometry caching, and Wang et al.~(2000) described an adaptive tessellation algorithm that reduces memory requirements.
][
  另一种方法是精细地镶嵌场景几何形状，并通过位移顶点来定义高分辨率网格。Pharr 和 Hanrahan（1996）描述了一种基于几何缓存的解决该问题的方法，Wang 等（2000）描述了一种自适应镶嵌算法，可以减少内存需求。
]

#parec[
  Smits, Shirley, and Stark (2000) lazily tessellate individual triangles, saving a substantial amount of memory.
][
  Smits、Shirley 和 Stark（2000）懒惰地镶嵌单个三角形，节省了大量内存。
]

#parec[
  Measuring fine-scale surface geometry of real surfaces to acquire bump or displacement maps can be challenging. Johnson et al.~(2011) developed a novel handheld system that can measure detail down to a few microns, which more than suffices for these uses.
][
  测量真实表面的细微几何形状以获取凹凸或位移贴图可能是具有挑战性的任务。Johnson 等（2011）开发了一种新颖的手持系统，可以测量到几个微米的细节，这对于这些用途来说已经足够了。
]


#parec[
  Burley's (#link("<cite:Burley2012>")[2012];) course notes describe a material model developed at Disney for feature films. This write-up includes extensive discussion of features of real-world reflection functions that can be observed in Matusik et al.'s (#link("<cite:Matusik03b>")[2003b];) measurements of one hundred BRDFs and analyzes the ways that existing BRDF models do and do not fit these features well.
][
  Burley 的 (#link("<cite:Burley2012>")[2012];) 课程笔记描述了迪士尼为故事片开发的材料模型。本文广泛讨论了在 Matusik 等人 (#link("<cite:Matusik03b>")[2003b];) 对一百个双向反射分布函数 (BRDF) 的测量中可以观察到的真实世界反射函数的特征，并分析现有 BRDF 模型在多大程度上与这些特征相符。
]

#parec[
  These insights are then used to develop an "artist-friendly" material model that can express a wide range of surface appearances. The model describes reflection with a single color and ten scalar parameters, all of which are in the range $[0 , 1]$ and have fairly predictable effects on the appearance of the resulting material.
][
  然后利用这些见解开发了一种“易于艺术家使用”的材料模型，可以表达广泛的表面外观。该模型通过单一颜色和十个标量参数来描述反射，这些参数都在 $[0 , 1]$ 范围内，并对最终材料的外观有相当可预测的影响。
]

#parec[
  An earlier material model designed to have intuitive parameters for artistic control was developed by Strauss (#link("<cite:Strauss1990>")[1990];).
][
  一个早期的材料模型由 Strauss (#link("<cite:Strauss1990>")[1990];) 设计，旨在为艺术控制提供直观的参数。
]

#parec[
  The #emph[bidirectional texture function] (BTF) is a generalization of the BRDF that was introduced by Dana et al.~(#link("<cite:Dana99>")[1999];). (BTFs are also referred to as spatially varying BRDFs (SVBRDFs).) It is a six-dimensional reflectance function that adds two dimensions to account for spatial variation to the BSDF.
][
  #emph[双向纹理函数] (BTF) 是由 Dana 等人 (#link("<cite:Dana99>")[1999];) 引入的双向反射分布函数 (BRDF) 的推广。(BTF 也称为空间变化双向反射分布函数 (SVBRDF)。) 它是一个六维反射函数，增加了两个维度以考虑到双向散射分布函数 (BSDF) 的空间变化。
]

#parec[
  `pbrt`'s material model can thus be seen as imposing a particular factorization of the BTF where variation due to the spatial dimension is incorporated into textures that in turn provide values for a parametric BSDF that defines the directional distribution.
][
  `pbrt` 的材料模型因此可以看作是对 BTF 施加了一种特定的分解，其中由于空间维度的变化被纳入纹理中，从而为定义方向分布的参数化双向散射分布函数 (BSDF) 提供值。
]

#parec[
  The BTF representation is especially useful for material acquisition, as it does not impose a particular representation or specific factorization of the six dimensions.
][
  BTF 表示在材料获取中特别有用，因为它不对六个维度施加特定的表示或分解。
]

#parec[
  The survey articles on BTF acquisition and representation by Müller et al.~(#link("<cite:Muller05>")[2005];) and Filip and Haindl (#link("<cite:Filip2009>")[2009];) have good coverage of earlier work in this area.
][
  Müller 等人 (#link("<cite:Muller05>")[2005];) 和 Filip 和 Haindl (#link("<cite:Filip2009>")[2009];) 关于 BTF 获取和表示的综述文章很好地涵盖了该领域的早期工作。
]

#parec[
  Rainer et al.~(#link("<cite:Rainer2019>")[2019];) recently trained a neural network to represent a given BTF; network evaluation took the position and lighting directions as parameters and returned the corresponding BTF value.
][
  Rainer 等人 (#link("<cite:Rainer2019>")[2019];) 最近训练了一个神经网络来表示给定的 BTF；网络评估将位置和光照方向作为参数，并返回相应的 BTF 值。
]

#parec[
  This work was subsequently generalized with a technique based on training a single network that provides a parameterization to which given BTFs can easily be mapped (#link("<cite:Rainer2020>")[Rainer et al.~2020];).
][
  随后，这项工作通过一种基于训练单个网络的技术得到了推广，该网络提供了一种参数化，使得给定的 BTF 可以轻松映射 (#link("<cite:Rainer2020>")[Rainer 等人 2020];)。
]

#parec[
  Kuznetsov et al.~(#link("<cite:Kuznetsov2021>")[2021];) also used a neural approach, developing a compact representation that allowed 7D queries of position, two directions, and a filter size.
][
  Kuznetsov 等人 (#link("<cite:Kuznetsov2021>")[2021];) 也使用了一种神经方法，开发了一种紧凑的表示，允许对位置、两个方向和滤波器大小进行 7D 查询。
]


