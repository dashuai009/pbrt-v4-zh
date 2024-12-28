#import "../template.typ": parec


== Further_Reading

#parec[
  Hall's (#link("<cite:Hall89>")[1989];) book collected and described the state of the art in physically based surface reflection models for graphics; it remains a seminal reference. It discusses the physics of surface reflection in detail, with many pointers to the original literature.
][
  Hall 的书（#link("<cite:Hall89>")[1989];）收集并描述了图形学中基于物理的表面反射模型的最先进的状态；它仍然是一个奠基性的参考文献。书中详细讨论了表面反射的物理学，并提供了许多原始文献的指引。
]

#parec[
  Phong (#link("<cite:Phong75>")[1975];) developed an early empirical reflection model for glossy surfaces in computer graphics. Although neither reciprocal nor energy conserving, it was a cornerstone of the first synthetic images of non-Lambertian objects. The Torrance–Sparrow microfacet model was described by Torrance and Sparrow (#link("<cite:Torrance67>")[1967];); it was first introduced to graphics by Blinn (#link("<cite:Blinn:1977:MOL>")[1977];), and a variant of it was used by Cook and Torrance (#link("<cite:Cook81>")[1981];, #link("<cite:Cook82>")[1982];).
][
  Phong (#link("<cite:Phong75>")[1975];) 开发了一个用于计算机图形中光泽表面的早期经验反射模型。虽然它既不具有互易性也不能量守恒，但它是非朗伯物体的第一个合成图像的奠基石。Torrance 和 Sparrow (#link("<cite:Torrance67>")[1967];) 描述了 Torrance–Sparrow 微面模型；它首次由 Blinn (#link("<cite:Blinn:1977:MOL>")[1977];) 引入图形学，Cook 和 Torrance (#link("<cite:Cook81>")[1981];, #link("<cite:Cook82>")[1982];) 使用了它的一个变体。
]

#parec[
  The papers by Beckmann and Spizzichino (#link("<cite:Beckmann63>")[1963];) and Trowbridge and Reitz (#link("<cite:Trowbridge1975>")[1975];) introduced two widely used microfacet distribution functions. Kurt et al.~(#link("<cite:Kurt2010>")[2010];) introduced an anisotropic variant of the Beckmann–Spizzichino distribution function; see Heitz (#link("<cite:Heitz2014a>")[2014];) for anisotropic variants of many other microfacet distribution functions. (Early anisotropic BRDF models for computer graphics were developed by Kajiya (#link("<cite:Kajiya85>")[1985];) and Poulin and Fournier (#link("<cite:Poulin90>")[1990];).) Ribardiére et al.~(#link("<cite:Ribardiere2017>")[2017];) applied Student's t-distribution to model microfacet distributions; it provides an additional degree of freedom, which they showed allows a better fit to measured data while subsuming both the Beckmann–Spizzichino and Trowbridge–Reitz distributions.
][
  Beckmann 和 Spizzichino (#link("<cite:Beckmann63>")[1963];) 以及 Trowbridge 和 Reitz (#link("<cite:Trowbridge1975>")[1975];) 的论文介绍了两个广泛使用的微面分布函数。Kurt 等人 (#link("<cite:Kurt2010>")[2010];) 引入了 Beckmann–Spizzichino 分布函数的各向异性版本；参见 Heitz (#link("<cite:Heitz2014a>")[2014];) 了解许多其他微面分布函数的各向异性版本。（计算机图形学的早期各向异性 BRDF 模型由 Kajiya (#link("<cite:Kajiya85>")[1985];) 和 Poulin 和 Fournier (#link("<cite:Poulin90>")[1990];) 开发。）Ribardiére 等人 (#link("<cite:Ribardiere2017>")[2017];) 应用学生 t-分布来建模微面分布；它提供了一个额外的自由度，他们展示了如何更好地拟合测量数据，同时包含 Beckmann–Spizzichino 和 Trowbridge–Reitz 分布。
]

#parec[
  The microfacet masking-shadowing function was introduced by Smith (#link("<cite:Smith1967>")[1967];), building on the assumption that heights of nearby points on the microfacet surface are uncorrelated. Smith also first derived the normalization constraint in Equation (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#eq:microfacet-g1-condition")[9.17];). Heitz's paper on microfacet masking-shadowing functions (#link("<cite:Heitz2014a>")[2014];) provides a very well-written introduction to microfacet BSDF models in general, with many useful figures and explanations about details of the topic.
][
  微面遮蔽-阴影函数由 Smith (#link("<cite:Smith1967>")[1967];) 引入，基于微面表面附近点的高度不相关的假设。Smith 还首次推导了方程 (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#eq:microfacet-g1-condition")[9.17];) 中的归一化约束。Heitz 关于微面遮蔽-阴影函数的论文 (#link("<cite:Heitz2014a>")[2014];) 提供了一个关于微面 BSDF 模型的非常好的介绍，包含许多有用的图示和关于该主题细节的解释。
]

#parec[
  The more accurate $ G (omega_n^i , omega_n^o) $ function for Gaussian microfacet surfaces that better accounts for the effects of correlation between the two directions that we have implemented is due to Ross et al.~(#link("<cite:Ross05>")[2005];). Our derivation of the $ Lambda (omega) $ function, Equation (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#eq:microfacet-lambda")[9.19];), follows Heitz (#link("<cite:Heitz2015>")[2015];).
][
  我们实现的更准确的高斯微面表面的 $ G (omega_n^i , omega_n^o) $ 函数更好地考虑了两个方向之间相关性的影响，来源于 Ross 等人 (#link("<cite:Ross05>")[2005];)。我们对 $ Lambda (omega) $ 函数的推导，方程 (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#eq:microfacet-lambda")[9.19];)，遵循 Heitz (#link("<cite:Heitz2015>")[2015];)。
]

#parec[
  For many decades, Monte Carlo rendering of microfacet models involved generating samples proportional to the microfacet distribution $ D (omega_h) $. Heitz and d'Eon (#link("<cite:Heitz2014>")[2014];) were the first to demonstrate that it was possible to reduce variance by restricting this sampling process to only consider visible microfacets. Our microfacet sampling implementation in Section (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#sec:microfacet")[9.6];) follows Heitz's improved approach (#link("<cite:Heitz2018:ggx-sample>")[2018];), which showed that sampling the visible area of the Trowbridge–Reitz microfacet distribution corresponds to sampling the projection of a truncated ellipsoid, which in turn can be performed using an approach developed by Walter et al.~(#link("<cite:Walter2015>")[2015];).
][
  几十年来，微面模型的蒙特卡罗渲染方法涉及生成与微面分布 $ D (omega_h) $ 成比例的样本。Heitz 和 d'Eon (#link("<cite:Heitz2014>")[2014];) 首次展示了通过限制此采样过程仅考虑可见的微面可以减少方差。我们在第 (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#sec:microfacet")[9.6];) 节中的微面采样实现遵循 Heitz 的改进方法 (#link("<cite:Heitz2018:ggx-sample>")[2018];)，展示了采样 Trowbridge–Reitz 微面分布的可见区域对应于采样截头椭球的投影，这可以使用 Walter 等人 (#link("<cite:Walter2015>")[2015];) 开发的方法来实现。
]

#parec[
  When dealing with refraction through rough dielectrics, a modified change of variables term is needed to account for the mapping from half vectors to outgoing direction. A model based on this approach was originally developed by Stam (#link("<cite:Stam:2001:AIM>")[2001];); Walter et al.~(#link("<cite:Walter07>")[2007];) proposed improvements and provided an elegant geometric justification of the half vector mapping of Equation (#link("../Reflection_Models/Rough_Dielectric_BSDF.html#eq:mf-transmission-change-of-vars")[9.36];). The generalized half-direction vector for refraction used in these models and in Equation (#link("../Reflection_Models/Rough_Dielectric_BSDF.html#eq:wm-microfacet-transmission")[9.34];) is due to Sommerfeld and Runge (#link("<cite:Sommerfeld1911>")[1911];).
][
  在处理粗糙介电材料的折射时，需要修改变量变化项以考虑从半向量到出射方向的映射。基于此方法的模型最初由 Stam (#link("<cite:Stam:2001:AIM>")[2001];) 开发；Walter 等人 (#link("<cite:Walter07>")[2007];) 提出了改进并提供了半向量映射方程 (#link("../Reflection_Models/Rough_Dielectric_BSDF.html#eq:mf-transmission-change-of-vars")[9.36];) 的优雅几何解释。这些模型中使用的用于折射的广义半方向向量以及方程 (#link("../Reflection_Models/Rough_Dielectric_BSDF.html#eq:wm-microfacet-transmission")[9.34];) 中的广义半方向向量来源于 Sommerfeld 和 Runge (#link("<cite:Sommerfeld1911>")[1911];)。
]

#parec[
  One issue with the specular term of the Torrance–Sparrow BRDF presented in Section (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#sec:torrance-sparrow")[9.6.5];) is that it only models a single scattering interaction with the microfacet surface, causing a growing portion of the energy to be lost as the roughness increases. In scenes where many subsequent interactions are crucial (e.g., a complex 3D object made from a translucent rough dielectric material), this energy loss can become so conspicuous that standard microfacet models become effectively unusable.
][
  在第 (#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#sec:torrance-sparrow")[9.6.5];) 节中提出的 Torrance–Sparrow BRDF 的镜面项的一个问题是它仅模拟与微面表面的单次散射相互作用，随着粗糙度的增加，能量损失的部分会增加。在许多后续相互作用至关重要的场景中（例如，由半透明粗糙介电材料制成的复杂 3D 对象），这种能量损失可能变得如此明显，以至于标准微面模型实际上无法使用。
]

#parec[
  The original model by Torrance and Sparrow (#link("<cite:Torrance67>")[1967];) included a diffuse component to simulate light having scattered multiple times. However, a simple diffuse correction is generally unsatisfactory, since the precise amount of energy loss will depend both on the surface roughness and the angle of incidence. Kelemen and Szirmay-Kalos (#link("<cite:Kelemen2001:brdf>")[2001];) proposed an improved diffuse-like term that accounts for this dependence. Jakob et al.~(#link("<cite:Jakob2014a>")[2014a];) generalized their approach to rough dielectric boundaries in the context of layered structures, where energy losses can be particularly undesirable.
][
  Torrance 和 Sparrow (#link("<cite:Torrance67>")[1967];) 的原始模型包括一个漫反射部分来模拟多次散射的光。然而，简单的漫反射校正通常是不令人满意的，因为能量损失的确切量将取决于表面粗糙度和入射角。Kelemen 和 Szirmay-Kalos (#link("<cite:Kelemen2001:brdf>")[2001];) 提出了一个改进的类似漫反射的项来考虑这种依赖性。Jakob 等人 (#link("<cite:Jakob2014a>")[2014a];) 在分层结构的背景下将他们的方法推广到粗糙介电边界，在这种情况下，能量损失可能特别不受欢迎。
]

#parec[
  In all of these cases, light is treated as essentially diffuse following scattering by multiple facets. Building on Smith's uncorrelated height assumption, Heitz et al.~(#link("<cite:Heitz2016:smith-multi>")[2016b];) cast a microfacet BRDF model into a volumetric analogue composed of microflakes—that is, a distribution of mirror facets suspended in a 3D space. With this new interpretation, they are able to simulate an arbitrary number of volumetric scattering interactions to evaluate an effective BRDF that is free of energy loss and arguably closer to physical reality.
][
  在所有这些情况下，光在多个微面散射后被视为基本上是漫反射的。基于 Smith 的不相关高度假设，Heitz 等人 (#link("<cite:Heitz2016:smith-multi>")[2016b];) 将微面 BRDF 模型转化为由微片组成的体积类比——即悬浮在 3D 空间中的镜面分布。通过这种新的解释，他们能够模拟任意数量的体积散射相互作用，以评估一个无能量损失且更接近物理现实的有效 BRDF。
]

#parec[
  Analytic solutions may sometimes obviate the need for a stochastic simulation of interreflection. For example, Lee et al.~(#link("<cite:Lee2018>")[2018];) and Xie and Hanrahan (#link("<cite:Xie2018>")[2018];) both derived analytic models for multiple scattering under the assumption of microfacets with a v-groove shape. Efficient approximate models for multiple scattering among microfacets were presented by Kulla and Conty Estevez (#link("<cite:Kulla2017>")[2017];) and by Turquin (#link("<cite:Turquin2019>")[2019];).
][
  解析方案有时可以避免对相互反射进行随机模拟。例如，Lee 等人 (#link("<cite:Lee2018>")[2018];) 和 Xie 和 Hanrahan (#link("<cite:Xie2018>")[2018];) 都在假设微面具有 v 型槽形状的情况下推导了多次散射的解析模型。Kulla 和 Conty Estevez (#link("<cite:Kulla2017>")[2017];) 以及 Turquin (#link("<cite:Turquin2019>")[2019];) 提出了微面之间多次散射的高效近似模型。
]

#parec[
  Microfacet models have provided a foundation for a variety of additional reflection models. Simonot (#link("<cite:Simonot2009>")[2009];) has developed a model that spans Oren–Nayar's diffuse microfacet model (#link("<cite:Oren94>")[1994];) and Torrance–Sparrow: microfacets are modeled as Lambertian reflectors with a layer above them that ranges from perfectly transmissive to a perfect specular reflector. Conty Estevez and Kulla (#link("<cite:Conty2017>")[2017];) have developed a model for cloth. The halo of a softer and wider secondary highlight is often visible with rough surfaces. Barla et al.~(#link("<cite:Barla2018>")[2018];) described a model for such surfaces with a focus on perceptually meaningful parameters for it.
][
  微面模型为各种附加反射模型提供了基础。Simonot (#link("<cite:Simonot2009>")[2009];) 开发了一个模型，跨越 Oren–Nayar 的漫反射微面模型 (#link("<cite:Oren94>")[1994];) 和 Torrance–Sparrow：微面被建模为朗伯反射体，其上方有一层从完全透射到完全镜面反射的层。Conty Estevez 和 Kulla (#link("<cite:Conty2017>")[2017];) 开发了一个用于布料的模型。粗糙表面通常可以看到更柔和和更宽的次要高光的光晕。Barla 等人 (#link("<cite:Barla2018>")[2018];) 描述了一个针对这种表面的模型，重点是其感知上重要的参数。
]

#parec[
  Weyrich et al.~(#link("<cite:Weyrich09>")[2009];) have developed methods to infer a microfacet distribution that matches a measured or desired reflection distribution. Remarkably, they showed that it is possible to manufacture actual physical surfaces that match a desired reflection distribution fairly accurately.
][
  Weyrich 等人 (#link("<cite:Weyrich09>")[2009];) 开发了推断与测量或期望反射分布匹配的微面分布的方法。值得注意的是，他们展示了可以制造出与期望反射分布相当匹配的真实的物理表面。
]


=== Layered Materials
<layered-materials>
#parec[
  Many materials are naturally composed of multiple layers—for example, a metal base surface tarnished with patina, or wood with a varnish coating. Using a specialized BRDF to represent such structures can be vastly more efficient than resolving internal reflections using standard light transport methods.
][
  许多材料天然由多层组成——例如，带有铜绿的金属基面，或涂有清漆的木材。使用专门的双向反射分布函数（BRDF）来表示这些结构可以比使用标准光传输方法解决内部反射更为高效。
]

#parec[
  Hanrahan and Krueger (1993) modeled the layers of skin, accounting for just a single scattering event in each layer, and Dorsey and Hanrahan (1996) rendered layered materials using the Kubelka–Munk theory, which accounts for multiple scattering within layers but assumes that radiance distribution does not vary as a function of direction.
][
  Hanrahan和Krueger（1993）对皮肤的层进行了建模，仅考虑每层中的单次散射事件，而Dorsey和Hanrahan（1996）使用Kubelka–Munk理论渲染分层材料，该理论考虑了层内的多次散射，但假设辐射分布不随方向变化。
]

#parec[
  Pharr and Hanrahan (2000) showed that Monte Carlo integration could be used to solve the #emph[adding equations] to efficiently compute BSDFs for layered materials without needing either of these simplifications. The adding equations are integral equations that accurately describe the effect of multiple scattering in layered media; they were derived by van de Hulst (1980) and Twomey et al.~(1966).
][
  Pharr和Hanrahan（2000）展示了蒙特卡罗积分（Monte Carlo Integration）可以用于解决“加法方程”（adding equations），以高效计算分层材料的BSDF，而无需这些简化。加法方程是准确描述分层介质中多次散射效应的积分方程；它们由van de Hulst（1980）和Twomey等人（1966）推导出。
]

#parec[
  Weidlich and Wilkie (2007) rendered layered materials more efficiently by making a number of simplifying assumptions. Guo et al.~(2018) showed that both unidirectional and bidirectional Monte Carlo random walks through layers led to efficient algorithms for evaluation, sampling, and PDF evaluation. (Their unidirectional approach is implemented in `pbrt`'s #link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#LayeredBxDF")[LayeredBxDF] in Section #link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#sec:scattering-layered")[14.3];.) Xia et al.~(2020a) described an improved importance sampling for this approach and Gamboa et al.~(2020) showed that bidirectional sampling was unnecessary and described a more efficient approach for multiple layers.
][
  Weidlich和Wilkie（2007）通过做出一些简化假设更高效地渲染了分层材料。Guo等人（2018）展示了通过层的单向和双向蒙特卡罗随机游走都能导致高效的评估、采样和PDF评估算法。（他们的单向方法在`pbrt`的#link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#LayeredBxDF")[LayeredBxDF];中实现，详见#link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#sec:scattering-layered")[14.3节];。）Xia等人（2020a）描述了该方法的改进重要性采样，Gamboa等人（2020）则表明双向采样是不必要的，并描述了一种更高效的多层方法。
]

#parec[
  Another approach for layered materials is to represent the aggregate scattering behavior of a layered surface using a parametric representation. Examples include Jakob et al.~(2014a) and Zeltner and Jakob (2018), who applied the adding equations to discretized scattering matrices describing volumetric layers and rough interfaces. Guo et al.~(2017) modeled coated surfaces using a modified microfacet scattering model.
][
  另一种处理分层材料的方法是使用参数化表示来表示分层表面的聚合散射行为。示例包括Jakob等人（2014a）和Zeltner和Jakob（2018），他们将加法方程应用于描述体积层和粗糙界面的离散散射矩阵。Guo等人（2017）使用修改后的微面散射模型对涂层表面进行了建模。
]

#parec[
  Belcour (2018) characterized individual layers' scattering statistically, computed aggregate scattering using the adding equations, and then mapped the result to sums of lobes based on the Trowbridge–Reitz microfacet distribution function. Weier and Belcour (2020) generalized this approach to handle anisotropic reflection from the layer interfaces and Randrianandrasana et al.~(2021) further generalized the model to improve accuracy and ensure energy conservation.
][
  Belcour（2018）对单个层的散射进行了统计特征化，使用加法方程计算聚合散射，然后根据Trowbridge–Reitz微面分布函数将结果映射到多个lobes的和。Weier和Belcour（2020）将该方法推广以处理层界面的各向异性反射，并且Randrianandrasana等人（2021）进一步推广了该模型以提高准确性并确保能量守恒。
]

#parec[
  It is possible to apply similar approaches to aggregate scattering at other scales. For example, Blumer et al.~precomputed the effect of multiple scattering in complex geometry like trees and stored the result in a form that allows for efficient evaluation and sampling (Blumer et al.~2016).
][
  可以将类似的方法应用于其他尺度的聚合散射。例如，Blumer等人预先计算了复杂几何（如树木）中多次散射的效果，并将结果存储为一种允许高效评估和采样的形式（Blumer等人2016）。
]

=== BSDF (Re-)Parameterization and Acquisition
<bsdf-re-parameterization-and-acquisition>
#parec[
  Improvements in data-acquisition technology have led to increasing amounts of detailed real-world BRDF data, even including BRDFs that are spatially varying (sometimes called "bidirectional texture functions," BTFs) (Dana et al.~1999). See Müller et al.~(2005) for a survey of work in BRDF measurement until the year 2005 and Guarnera et al.~(2016) for a survey through the following decade.
][
  数据采集技术的进步导致了越来越多的详细真实世界BRDF数据，甚至包括空间变化的BRDF（有时称为“双向纹理函数”，BTF）（Dana等人1999）。有关2005年前BRDF测量工作的综述，请参见Müller等人（2005），有关随后的十年综述，请参见Guarnera等人（2016）。
]

#parec[
  Fitting measured BRDF data to parametric reflection models is a difficult problem. Rusinkiewicz (1998) made the influential observation that reparameterizing the measured data can make it substantially easier to compress or fit to models. The topic of BRDF parameterizations has also been investigated by Stark et al.~(2005) and in Marschner's Ph.D.~dissertation (1998).
][
  将测量的BRDF数据拟合到参数化反射模型是一个困难的问题。Rusinkiewicz（1998）提出了一个有影响力的观察，即重新参数化测量数据可以使其更容易压缩或拟合到模型中。Stark等人（2005）和Marschner的博士论文（1998）也研究了BRDF参数化的主题。
]

#parec[
  Building on Rusinkiewicz's parameterization, Matusik et al.~(2003a, 2003b) designed a BRDF representation and an efficient measurement device that repeatedly photographs a spherical sample to simultaneously acquire BRDF evaluations for many directions. They used this device to assemble a collection of isotropic material measurements that is now known as the MERL BRDF database.
][
  在Rusinkiewicz的参数化基础上，Matusik等人（2003a，2003b）设计了一种BRDF表示和一种高效的测量设备，该设备反复拍摄球形样本以同时获取多个方向的BRDF评估。他们使用该设备组装了一个现在称为MERL BRDF数据库的各向同性材料测量集合。
]

#parec[
  Baek et al.~(2020) extended this approach with additional optics to capture polarimetric BRDFs, whose evaluation yields $ 4 times 4 $ Mueller matrices that characterize how reflection changes the polarization state of light. Nielsen et al.~(2015) analyzed the manifold of MERL BRDFs to show that as few as 10–20 carefully chosen measurements can produce high-quality BRDF approximations.
][
  Baek等人（2020）通过附加光学器件扩展了这种方法以捕获偏振BRDF，其评估产生 $ 4 times 4 $ Mueller矩阵，描述了反射如何改变光的偏振状态。Nielsen等人（2015）分析了MERL BRDF的流形，表明只需10-20个精心选择的测量就可以产生高质量的BRDF近似。
]

#parec[
  Dupuy et al.~(2015) developed a simple iterative procedure for fitting standard microfacet distributions to measured BRDFs. Dupuy and Jakob (2018) generalized this procedure to arbitrary data-driven microfacet distributions and used the resulting approximation to perform a measurement in reparameterized coordinates, which is the approach underlying the #link("../Reflection_Models/Measured_BSDFs.html#MeasuredBxDF")[MeasuredBxDF];.
][
  Dupuy等人（2015）开发了一种简单的迭代程序，用于将标准微面分布拟合到测量的BRDF。Dupuy和Jakob（2018）将此程序推广到任意数据驱动的微面分布，并使用所得的近似在重新参数化坐标中进行测量，这是#link("../Reflection_Models/Measured_BSDFs.html#MeasuredBxDF")[MeasuredBxDF];的基础方法。
]

#parec[
  They then used a motorized goniophotometer to spectroscopically acquire a collection of isotropic and anisotropic material samples that can be loaded into `pbrt`.
][
  然后，他们使用一个电动测角光度计光谱地获取了一组可以加载到`pbrt`中的各向同性和各向异性材料样本。
]

#parec[
  While the high-dimensional nature of reflectance functions can pose a serious impediment in any acquisition procedure, the resulting data can often be approximated much more compactly. Bagher et al.~(2016) decomposed the MERL database into a set of 1D factors requiring 3.2 KiB per material. Vávra and Filip (2016) showed how lower-dimensional slices can inform a sparse measurement procedure for anisotropic materials.
][
  尽管反射函数的高维性质可能在任何采集过程中构成严重障碍，但所得数据通常可以更紧凑地近似。Bagher等人（2016）将MERL数据库分解为一组每种材料需要3.2 KiB的1D因子。Vávra和Filip（2016）展示了如何利用低维切片来指导各向异性材料的稀疏测量程序。
]

=== Hair, Fur, and Fibers
<hair-fur-and-fibers>
#parec[
  Kajiya and Kay (1989) were the first to develop a reflectance model for hair fibers, observing the characteristic behavior of the underlying cylindrical reflectance geometry. For example, a thin and ideally specular cylinder under parallel illumination will reflect light into a 1D cone of angles.
][
  Kajiya和Kay（1989）首次开发了头发纤维的反射模型，观察到底层圆柱形反射几何的特征行为。例如，在平行光照下，薄且理想的镜面圆柱体会将光反射到一个1D角锥中。
]

#parec[
  Reflection from a rough cylinder tends to concentrate around the specular 1D cone and decay with increasing angular distance. Kajiya and Kay proposed a phenomenological model combining diffuse and specular terms sharing these properties.
][
  从粗糙圆柱体的反射倾向于集中在镜面1D角锥周围，并随着角度距离的增加而衰减。Kajiya和Kay提出了一个结合了这些特性的漫反射和镜面反射项的现象学模型。
]

#parec[
  For related work, see also the paper by Banks (1994), which discusses basic shading models for 1D primitives like hair. Goldman (1997) developed a probabilistic shading model that models reflection from collections of short hairs. Ward et al.'s survey (2007) has extensive coverage of early research in modeling, animating, and rendering hair.
][
  有关相关工作，还可以参见Banks（1994）的论文，该论文讨论了1D原语（如头发）的基本着色模型。Goldman（1997）开发了一个概率着色模型，用于模拟短发集合的反射。Ward等人的综述（2007）对头发建模、动画和渲染的早期研究进行了广泛的覆盖。
]

#parec[
  Marschner et al.~(2003) investigated the processes underlying scattering from hair and performed a variety of measurements of scattering from actual hair. They introduced the longitudinal/azimuthal decomposition and the use of the modified index of refraction to hair rendering.
][
  Marschner等人（2003）研究了头发散射的基本过程，并对实际头发的散射进行了各种测量。他们引入了纵向/方位分解和用于头发渲染的修正折射率。
]

#parec[
  They then developed a scattering model where the longitudinal component was derived by first considering perfect specular paths and then allowing roughness by centering a Gaussian around them, and their azimuthal model assumed perfect specular reflections. They showed that this model agreed reasonably well with their measurements.
][
  然后，他们开发了一个散射模型，其中纵向分量首先通过考虑完美镜面路径得出，然后通过在其周围居中一个高斯分布来允许粗糙度，他们的方位模型假设完美镜面反射。他们表明，该模型与他们的测量结果相当吻合。
]

#parec[
  Hery and Ramamoorthi (2012) showed how to sample the first term of this model and Pekelis et al.~(2015) developed a more efficient approach to sampling all of its terms.
][
  Hery和Ramamoorthi（2012）展示了如何采样该模型的第一项，Pekelis等人（2015）开发了一种更高效的方法来采样其所有项。
]

#parec[
  Zinke and Weber (2007) formalized different ways of modeling scattering from hair and clarified the assumptions underlying each of them. Starting with the #emph[bidirectional fiber scattering distribution
function] (BFSDF), which describes reflected differential radiance at a point on a hair as a fraction of incident differential power at another, they showed how assuming homogeneous scattering properties and a far-away viewer and illumination made it possible to simplify the eight-dimensional BFSDF to a four-dimensional #emph[bidirectional curve
scattering distribution function] (BCSDF).
][
  Zinke和Weber（2007）正式化了不同的头发散射建模方法，并澄清了每种方法的假设。首先是#emph[双向纤维散射分布函数];（BFSDF），它描述了在头发某一点的反射微分辐射作为在另一点的入射微分功率的分数，他们展示了如何假设均匀的散射特性和远距离的观察者和光照使得可以将八维BFSDF简化为四维#emph[双向曲线散射分布函数];（BCSDF）。
]

#parec[
  (Our implementation of the #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF")[HairBxDF] has glossed over some of these subtleties and opted for the simplicity of considering the scattering model as a BSDF.)
][
  （我们的#link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF")[HairBxDF];实现略过了一些这些细节，选择了将散射模型视为BSDF的简单性。）
]

#parec[
  Sadeghi et al.~(2010) developed a hair scattering model with artist-friendly controls; Ou et al.~(2012) showed how to sample from its distribution. Ogaki et al.~(2010) created a tabularized model by explicitly modeling hair microgeometry and following random walks through it.
][
  Sadeghi等人（2010）开发了一个具有艺术家友好控制的头发散射模型；Ou等人（2012）展示了如何从其分布中采样。Ogaki等人（2010）通过显式建模头发微观几何并通过其进行随机游走创建了一个表格化模型。
]

#parec[
  D'Eon et al.~(2011, 2013) made a number of improvements to Marschner et al.'s model. They showed that their $ M_p $ term was not actually energy conserving and derived a new one that was; this is the model from Equation (9.49) that our implementation uses.
][
  D'Eon等人（2011，2013）对Marschner等人的模型进行了多项改进。他们表明，他们的 $ M_p $ 项实际上不是能量守恒的，并推导出一个新的能量守恒项；这是我们的实现使用的方程（9.49）中的模型。
]

#parec[
  (See also d'Eon (2013) for a more numerically stable formulation of $ M_p $ for low roughness, as well as Jakob (2012) for notes related to sampling their $ M_p $ term in a numerically stable way.)
][
  （有关低粗糙度的 $ M_p $ 的更数值稳定的公式，参见d'Eon（2013），以及Jakob（2012）关于以数值稳定的方式采样其 $ M_p $ 项的注释。）
]

#parec[
  They also introduced a Gaussian to the azimuthal term, allowing for varying azimuthal roughness. A 1D quadrature method was used to integrate the model across the width of the hair $ h $.
][
  他们还在方位项中引入了一个高斯分布，允许方位粗糙度变化。使用了一种1D求积方法来跨头发宽度 $ h $ 积分模型。
]

#parec[
  The RGB values used for the hair pigments in #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF::SigmaAFromConcentration")[HairBxDF::SigmaAFromConcentration()] were computed by d'Eon et al.~(2011), based on a model by Donner and Jensen (2006).
][
  #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF::SigmaAFromConcentration")[HairBxDF::SigmaAFromConcentration()];中用于头发色素的RGB值由d'Eon等人（2011）计算，基于Donner和Jensen（2006）的模型。
]

#parec[
  The function implemented in the #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF::SigmaAFromReflectance")[HairBxDF::SigmaAFromReflectance()] method is due to Chiang et al.~(2016a), who created a cube of hair and rendered it with a variety of absorption coefficients and roughnesses while it was illuminated with a uniform white dome.
][
  #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF::SigmaAFromReflectance")[HairBxDF::SigmaAFromReflectance()];方法中实现的函数归功于Chiang等人（2016a），他们创建了一个头发立方体，并在其被均匀白色穹顶照亮时以各种吸收系数和粗糙度渲染它。
]

#parec[
  They then fit a function that mapped from the hair's azimuthal roughness and average color at the center of the front face of the cube to an absorption coefficient.
][
  然后，他们拟合了一个函数，将头发的方位粗糙度和立方体前面中心的平均颜色映射到吸收系数。
]

#parec[
  D'Eon et al.~(2014) performed extensive Monte Carlo simulations of scattering from dielectric cylinders with explicitly modeled scales and glossy scattering at the boundary based on a Beckmann microfacet distribution.
][
  D'Eon等人（2014）对具有显式建模尺度和基于Beckmann微面分布的边界光泽散射的电介质圆柱体进行了广泛的蒙特卡罗模拟。
]

#parec[
  They showed that separable models did not model all the observed effects and that in particular the specular term modeled by $ M_p $ varies over the surface of the cylinder and also depends on $ phi.alt $.
][
  他们表明，可分离模型并未模拟所有观察到的效果，特别是由 $ M_p $ 建模的镜面项在圆柱体表面上变化，并且还依赖于 $ phi.alt $。
]

#parec[
  They developed a non-separable scattering model, where both $ alpha $ and $ beta_m $ vary as a function of $ h $, and showed that it fit their simulations very accurately.
][
  他们开发了一个不可分离的散射模型，其中 $ alpha $ 和 $ beta_m $ 都作为 $ h $ 的函数变化，并表明它非常准确地拟合了他们的模拟。
]

#parec[
  All the scattering models we have described so far have been BCSDFs—they represent the overall scattering across the entire width of the hair in a single model.
][
  我们迄今描述的所有散射模型都是BCSDF——它们在单个模型中表示整个头发宽度的整体散射。
]

#parec[
  Such "far field" models assume both that the viewer is far away and that incident illumination is uniform across the hair's width. In practice, both of these assumptions are invalid if one is using path tracing to model multiple scattering inside hair.
][
  这种“远场”模型假设观察者远离，并且入射光照在头发宽度上是均匀的。在实践中，如果使用路径追踪来模拟头发内部的多次散射，这两个假设都是无效的。
]

#parec[
  Two recent models have considered scattering at a single point along the hair's width, making them more suitable for accurately modeling "near field" scattering.
][
  最近的两个模型考虑了沿头发宽度单点的散射，使它们更适合于准确建模“近场”散射。
]

#parec[
  Yan et al.~(2015) generalized d'Eon et al.'s model to account for scattering in the medulla, modeling a scattering cylinder in the interior of fur, and validated their model with a variety of measurements of actual animal fur.
][
  Yan等人（2015）推广了d'Eon等人的模型以考虑髓质中的散射，建模了毛发内部的散射圆柱体，并通过对实际动物毛发的各种测量验证了他们的模型。
]

#parec[
  Subsequent work developed an efficient model that allows both near- and far-field evaluation (Yan et al.~2017a).
][
  后续工作开发了一种高效模型，允许进行近场和远场评估（Yan等人2017a）。
]

#parec[
  Chiang et al.~(2016a) showed that eliminating the integral over width from d'Eon et al.'s model works well in practice and that the sampling rates necessary for path tracing also worked well to integrate scattering over the curve width, giving a much more efficient implementation.
][
  Chiang等人（2016a）表明，从d'Eon等人的模型中消除宽度积分在实践中效果良好，并且路径追踪所需的采样率也很好地用于积分曲线宽度上的散射，提供了更高效的实现。
]

#parec[
  They also developed the perceptually uniform parameterization of $ beta_m $ and $ beta_n $ that we have implemented in the #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF")[HairBxDF] as well as the inverse mapping from reflectance to $ sigma_(upright("normal")) $ used in our #link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF::SigmaAFromReflectance")[HairBxDF::SigmaAFromReflectance()] method.
][
  他们还开发了我们在#link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF")[HairBxDF];中实现的 $ beta_m $ 和 $ beta_n $ 的感知均匀参数化，以及在我们的#link("../Reflection_Models/Scattering_from_Hair.html#HairBxDF::SigmaAFromReflectance")[HairBxDF::SigmaAFromReflectance()];方法中使用的从反射率到 $ sigma_(upright("normal")) $ 的逆映射。
]

#parec[
  Further recent advances in hair and fur rendering include work by Khungurn and Marschner (2017), who developed a scattering model from elliptical fibers and showed that modeling fibers as elliptical rather than cylindrical gives a closer match to measured data.
][
  头发和毛皮渲染的进一步最新进展包括Khungurn和Marschner（2017）的工作，他们开发了一个椭圆纤维的散射模型，并展示了将纤维建模为椭圆而非圆柱与测量数据更为吻合。
]

#parec[
  Benamira and Pattanaik (2021) recently proposed a model that accounts for both elliptical fibers and diffraction effects, which are significant at the scale of human hair.
][
  Benamira和Pattanaik（2021）最近提出了一个模型，该模型同时考虑了椭圆纤维和衍射效应，这在人体头发的尺度上是显著的。
]

#parec[
  Modeling and rendering the individual fibers of fabric is closely related to doing so for hair and fur. Recent work includes Zhao et al.~(2016) who fit a procedural yarn model to CT-scanned yarn, and Aliaga et al.~(2017) who demonstrated the complexity of scattering from a variety of cloth fibers and developed tabularized scattering functions for them using a precomputed simulation.
][
  对织物单纤维的建模和渲染与对头发和毛皮的建模和渲染密切相关。最近的工作包括Zhao等人（2016），他们将程序化纱线模型拟合到CT扫描的纱线，以及Aliaga等人（2017），他们展示了各种布料纤维的复杂散射，并使用预计算模拟为其开发了表格化散射函数。
]


=== Glints and Microstructure
<glints-and-microstructure>
#parec[
  The microfacet reflection models in this chapter are all based on the assumption that so many microfacets are visible in a pixel that they can be accurately described by their aggregate statistical behavior. This assumption is not true for many real-world surfaces, where a relatively small number of microfacets may be visible in each pixel; examples of such surfaces include glittery car paint and plastics.
][
  本章中的微表面反射模型都是基于这样一个假设：在一个像素中可见的微表面数量如此之多，以至于可以通过其整体统计行为来准确描述。对于许多现实世界的表面来说，这一假设并不成立，因为在每个像素中可能只有相对较少的微表面可见；此类表面的例子包括闪烁的汽车漆和塑料。
]

#parec[
  Additionally, many types of rough surfaces that aren't considered glittery (e.g., bead-blasted plastic) are characterized by bright high-frequency glints under directionally peaked illumination (e.g., the sun).
][
  此外，许多不被认为是闪烁的粗糙表面（例如，珠光塑料）在具有方向性集中的光源（例如，太阳）的照射下，这些表面会呈现出明亮的高频光斑。
]

#parec[
  A common characteristic of many glint-rendering techniques is that they replace point evaluations of reflectance functions with a directional and/or spatial average covering a small region (e.g., a ray differential). With such an approach, a single sample suffices to find all glints visible within one pixel, which dramatically accelerates the rendering process.
][
  许多闪烁渲染技术的一个共同特点是，它们用覆盖小区域（例如，光线微分）的方向性和/或空间平均值替代反射函数的点评估。通过这种方法，单个样本就能捕捉到一个像素内的所有光斑，从而显著加快渲染速度。
]

#parec[
  One approach to rendering glints was introduced by Jakob et al.~(2014b), who developed a temporally consistent stochastic process that samples glint positions on the fly during evaluation of a spatio-directional average. Wang et al.~(2018) showed that the performance of this method could be improved by a separable approximation of the spatial and directional dimensions.
][
  Jakob等人（2014b）提出了一种渲染闪烁的方法，他们开发了一种时间一致的随机过程，在空间方向平均值评估期间动态采样闪烁位置。Wang等人（2018）表明，通过空间和方向维度的可分近似可以提高该方法的性能。
]

#parec[
  These stochastic methods are compact but also very limited in terms of the glint distributions that can be modeled.
][
  这些随机方法紧凑但在可建模的闪烁分布方面非常有限。
]

#parec[
  In production rendering systems, fine surface details are often modeled using bump- or normal maps. Glinty surface appearance tends to result when such surfaces have high-resolution detail as well as a specular BRDF, and when they are furthermore subject to sharp (e.g., point or directional) illumination.
][
  在生产渲染系统中，细致的表面细节通常使用凹凸贴图或法线贴图进行建模。当这些表面具有高分辨率细节以及镜面反射BRDF，并且受到尖锐（例如，点或方向性）照明时，往往会产生闪烁的表面外观。
]

#parec[
  At the same time, such configurations produce an extremely challenging Monte Carlo integration problem that has motivated numerous specialized methods for rendering normal-mapped specular surfaces.
][
  同时，这种配置带来了极具挑战性的蒙特卡罗积分问题，促使开发了许多专门用于渲染法线贴图镜面表面的方法。
]

#parec[
  Yan et al.~(2014) proposed a method that organizes the normal maps into a 4D spatio-directional data structure that can be queried to find reflecting surface regions. Yan et al.~(2016) drastically reduced the cost of reflectance queries by converting the normal map into a large superposition of 4D Gaussian functions termed a #emph[position-normal
distribution];.
][
  Yan等人（2014）提出了一种方法，将法线贴图组织成一个4D空间方向数据结构，可以查询以找到反射表面区域。Yan等人（2016）通过将法线贴图转换为称为#emph[位置-法线分布];的4D高斯函数的大量叠加，极大地降低了反射查询的成本。
]

#parec[
  Though image fidelity is excellent, the overheads of these methods can be significant: slow rendering in the former case, and lengthy preprocessing and storage requirements in the second case.
][
  尽管图像保真度极佳，但这些方法的开销可能很大：前者的渲染速度较慢，后者则需要较长的预处理和存储要求。
]

#parec[
  Zhu et al.~(2019) addressed both of these issues via clustering and runtime synthesis of normal map detail. Wang et al.~(2020a) substantially reduced the storage requirements by using a semi-procedural model that matches the statistics of an input texture.
][
  Zhu等人（2019）通过聚类和运行时合成法线贴图细节解决了这两个问题。Wang等人（2020a）通过使用一种半程序化模型来匹配输入纹理的统计数据，大大减少了存储需求。
]

#parec[
  Zeltner et al.~(2020) proposed a Newton-like equation-solving iteration that stochastically finds glints within texels of a normal map. Atanasov et al.~(2021) developed a multi-level data structure for finding glints around a given half vector.
][
  Zeltner等人（2020）提出了一种类似牛顿法的方程求解迭代，随机地在法线贴图的纹素中找到闪烁。Atanasov等人（2021）开发了一种多级数据结构，用于在给定的半向量周围找到闪烁。
]

#parec[
  Other work in this area includes Raymond et al.~(2016), who developed methods for rendering scratched surfaces, and Kuznetsov et al., who trained generative adversarial networks to represent microgeometry (Kuznetsov et al.~2019).
][
  该领域的其他工作包括Raymond等人（2016），他们开发了用于渲染划痕表面的方法，以及Kuznetsov等人，他们训练生成对抗网络来表示微观几何（Kuznetsov等人2019）。
]

#parec[
  Chermain et al.~(2019) incorporated the effect of multiple scattering among the microstructure facets in such models, and Chermain et al.~(2021) proposed a visible normal sampling technique for glint NDF. Loubet et al.~recently developed a technique for sampling specular paths that is applicable to rendering caustics as well as rendering glints (2020).
][
  Chermain等人（2019）在此类模型中加入了微结构面之间多重散射的效果，Chermain等人（2021）提出了一种用于闪烁NDF的可见法线采样技术。Loubet等人最近开发了一种采样镜面路径的技术，适用于渲染焦散以及渲染闪烁（2020）。
]

=== Wave Optics
<wave-optics>
#parec[
  Essentially all physically based renderers are based on laws that approximate wave-optical behavior geometrically. At a high level, these approximations are sound given the large scale of depicted objects compared to the wavelength of light.
][
  几乎所有基于物理的渲染器都是基于几何近似波动光学行为的定律。在高层次上，考虑到所描绘对象相对于光波长的巨大尺度，这些近似是合理的。
]

#parec[
  At the same time, wave-optical properties tend to make themselves noticeable whenever geometric features occur at scales resembling the wavelength of light, and such features may indeed be present even on objects that are themselves drastically larger.
][
  同时，波动光学特性往往在几何特征的尺度类似于光波长时变得显著，这种特征甚至可能存在于本身大得多的对象上。
]

#parec[
  For example, consider a thin film of oil on a puddle, a tiny scratch on an otherwise smooth metallic surface, or an object with micron-scale surface microstructure. These cases can feature striking structural coloration caused by the interference of light, which a purely geometric simulation would not be able to reproduce.
][
  例如，考虑水坑上的一层薄油膜、原本光滑的金属表面上的微小划痕，或具有微米级表面微结构的物体。这些情况可能会因光的干涉而呈现出显著的结构色，这在纯几何模拟中是无法再现的。
]

#parec[
  It may be tempting to switch to a full wave-optical simulation of light in such cases, though this line of thought quickly runs into fundamental limits: for example, using the Finite Difference Time Domain (FDTD) method, the simulation domain would need to be discretized at resolutions of $< 100 thin upright("normal") thin n thin upright("normal") thin m$ and simulated using sub-femtosecond timesteps.
][
  在这种情况下，可能会倾向于切换到完整的波动光学光模拟，尽管这种思路很快会遇到基本限制：例如，使用有限差分时域（FDTD）方法，模拟域需要以 $< 100 thin upright("normal") thin n thin upright("normal") thin m$ 的分辨率离散化，并使用亚飞秒时间步长进行模拟。
]

#parec[
  This can still work when studying local behavior at the micron scale, but it is practically infeasible for scenes measured in centimeters or even meters. These challenges have motivated numerous specialized methods that reintroduce such wave-optical effects within an otherwise geometric simulation.
][
  这在研究微米级局部行为时仍然可行，但对于以厘米甚至米为单位的场景来说实际上是不可行的。这些挑战推动了许多专门方法的发展，以在几何模拟中重新引入波动光学效应。
]

#parec[
  Moravec (1981) was the first to apply a wave optics model to computer graphics. Other early work in this area includes Bahar and Chakrabarti (1987) and Stam (1999), who modeled diffraction effects from random and periodic structures.
][
  Moravec（1981）是第一个将波动光学模型应用于计算机图形的人。该领域的其他早期工作包括Bahar和Chakrabarti（1987）以及Stam（1999），他们模拟了随机和周期结构的衍射效应。
]

#parec[
  Cuypers et al.~(2012) modeled multiple diffraction phenomena using signed BSDFs based on Wigner Distribution Functions.
][
  Cuypers等人（2012）使用基于维格纳分布函数的符号BSDFs模拟了多重衍射现象。
]

#parec[
  Musbach et al.~(2013) applied the FDTD to obtain a BRDF of the iridescent microstructure of a Morpho butterfly. Their paper provides extensive references to previous work on this topic.
][
  Musbach等人（2013）应用FDTD获得了Morpho蝴蝶虹彩微结构的BRDF。他们的论文提供了关于该主题的广泛参考文献。
]

#parec[
  Dhillon et al.~(2014) developed a model of diffraction from small-scale biological features such as are present in snake skin. Belcour and Barla (2017) modeled thin film iridescence on a rough microfacet surface and showed the importance of this effect for materials such as leather and how the resulting spectral variation can be efficiently calculated in an RGB-based simulation.
][
  Dhillon等人（2014）开发了一个从小尺度生物特征（例如蛇皮）衍射的模型。Belcour和Barla（2017）在粗糙微面表面上模拟了薄膜虹彩，并展示了这种效应对皮革等材料的重要性，以及如何在基于RGB的模拟中有效计算由此产生的光谱变化。
]

#parec[
  Werner et al.~(2017) developed a model for rendering surfaces with iridescent scratches. Yan et al.~(2018) presented a surface microstructure model that integrates over a coherence area to produce iridescent glints, revealing substantial differences between geometric and wave-based modeling.
][
  Werner等人（2017）开发了一个用于渲染具有虹彩划痕表面的模型。Yan等人（2018）提出了一种表面微结构模型，通过在相干区域上积分来产生虹彩闪烁，揭示了几何和基于波动的建模之间的显著差异。
]

#parec[
  Toisoul and Ghosh (2017) presented a method for capturing and reproducing the appearance of periodic grating-like structures. Xia et al.~(2020b) showed that diffraction and interference are meaningful at the scale of fibers and developed a wave optics-based model for scattering from fibers that they validated with measured data.
][
  Toisoul和Ghosh（2017）提出了一种捕捉和再现周期性光栅状结构外观的方法。Xia等人（2020b）表明，衍射和干涉在纤维尺度上具有意义，并开发了一种基于波动光学的纤维散射模型，并用测量数据验证了该模型。
]

#parec[
  In contrast to the above applications that reproduce dramatic goniochromatic effects, several works have studied how wave-based modeling can improve modeling of common materials (e.g., rough plastic or conductive surfaces).
][
  与上述再现角度色变效应的应用相比，一些工作研究了波动建模如何改善普通材料（例如，粗糙塑料或导电表面）的建模。
]

#parec[
  Löw et al.~(2012) proposed and compared geometric and wave-based BRDF models in fits to materials to the MERL database. Dong et al.~(2015) measured the surface microstructure of metal samples using a profilometer and used it to construct geometric and wave-based models that they then compared to goniophotometric measurements.
][
  Löw等人（2012）提出并比较了几何和波动BRDF模型在MERL数据库材料拟合中的表现。Dong等人（2015）使用轮廓仪测量金属样品的表面微结构，并用其构建几何和波动模型，然后将其与测角光度测量进行比较。
]

#parec[
  Holzschuch and Pacanowski (2017) integrated diffraction effects into a microfacet model and showed that this gives a closer fit to measured data.
][
  Holzschuch和Pacanowski（2017）将衍射效应整合到微面模型中，并表明这与测量数据更为贴合。
]


#parec[
  The Lambertian BRDF is an idealized model; as noted earlier, it does not match many real-world BRDFs precisely. Oren and Nayar (1994) proposed an improved model based on Lambertian microfacets that allowed the specification of surface roughness. d'Eon has recently (2021) proposed a model based on scattering Lambertian spheres that matches the appearance of many materials well.
][
  Lambertian BRDF 是一种理想化模型；如前所述，它与许多真实世界的 BRDF 并不完全匹配。Oren 和 Nayar（1994）提出了一种基于 Lambertian 微面的改进模型，该模型允许指定表面粗糙度。d'Eon 最近（2021）提出了一种基于散射 Lambertian 球体的模型，该模型很好地匹配了许多材料的外观。
]

#parec[
  A number of researchers have investigated BRDFs based on modeling the small-scale geometric features of a reflective surface. This work includes the computation of BRDFs from bump maps by Cabral, Max, and Springmeyer (1987); Fournier's normal distribution functions (Fournier 1992); and a technique by Westin, Arvo, and Torrance (1992), who applied Monte Carlo ray tracing to statistically model reflection from microgeometry and represented the resulting BRDFs with spherical harmonics.
][
  许多研究人员研究了基于反射表面微小几何特征的 BRDF 模型。这项工作包括 Cabral、Max 和 Springmeyer（1987）通过凸凹贴图计算 BRDF；Fournier 的法线分布函数（Fournier 1992）；以及 Westin、Arvo 和 Torrance（1992）的一种技术，他们应用蒙特卡罗光线追踪技术来统计建模微几何反射，并用球谐函数表示所得的 BRDF。
]

#parec[
  Wu et al.~(2011) developed a system that made it possible to model microgeometry and specify its underlying BRDF while interactively previewing the resulting macro-scale BRDF, and Falster et al.~(2020) computed BSDFs of microgeometry, accounting for both multiple scattering and diffraction.
][
  吴等人（2011）开发了一个系统，使得能够建模微几何并指定其基础 BRDF，同时交互式预览所得的宏观 BRDF，而 Falster 等人（2020）计算了微几何的 BSDF，考虑了多重散射和衍射。
]

#parec[
  The effect of the polarization of light is not modeled in `pbrt`, although for some scenes it can be an important effect; see, for example, the paper by Tannenbaum, Tannenbaum, and Wozny (1994) for information about how to extend a renderer to account for this effect.
][
  尽管在某些场景中光的偏振效应可能很重要，但 `pbrt` 并未对此进行建模。例如，参见 Tannenbaum、Tannenbaum 和 Wozny（1994）的论文，了解如何扩展渲染器以考虑这一效应。
]

#parec[
  Fluorescence, where light is reflected at different wavelengths than the incident illumination, is also not modeled by `pbrt`; see Glassner (1994) and Wilkie et al.~(2006) for more information on this topic.
][
  荧光，即光以不同于入射光的波长反射，也未在 `pbrt` 中建模；有关此主题的更多信息，请参见 Glassner（1994）和 Wilkie 等人（2006）。
]

#parec[
  Modeling reflection from a variety of specific types of surfaces has received attention from researchers, leading to specialized reflection models. Examples include wood (Marschner et al.~2005), car paint (Ergun et al.~2016), paper (Papas et al.~2014), and pearlescent materials (Guillén et al.~2020).
][
  对各种特定类型表面的反射建模引起了研究人员的关注，导致了专门的反射模型。示例包括木材（Marschner 等人 2005）、汽车漆（Ergun 等人 2016）、纸张（Papas 等人 2014）和珠光材料（Guillén 等人 2020）。
]

#parec[
  Cloth remains a particularly challenging material to render; see the recent survey by Castillo et al.~(2019) for comprehensive coverage of work in this area.
][
  布料仍然是一个特别具有挑战性的渲染材料；请参阅 Castillo 等人（2019）的最新调查，全面涵盖了该领域的工作。
]

#parec[
  Sampling BSDFs well is a key component of efficient image synthesis. Szécsi et al.~(2003) evaluated different approaches for sampling BSDFs that are comprised of multiple lobes.
][
  有效采样 BSDF 是高效图像合成的关键组成部分。Szécsi 等人（2003）评估了不同的 BSDF 采样方法，这些方法由多个 lobes 组成。
]

#parec[
  It is often only possible to sample some factors of a BSDF (e.g., when sampling the Torrance–Sparrow BRDF using the distribution of visible microfacet normals); Herholz et al.~fit parametric sampling distributions to BSDFs in an effort to sample them more effectively (Herholz et al.~2018).
][
  通常只能采样 BSDF 的某些因素（例如，当使用可见微面法线分布采样 Torrance–Sparrow BRDF 时）；Herholz 等人将参数化采样分布拟合到 BSDF，以更有效地采样它们（Herholz 等人 2018）。
]

#parec[
  `pbrt`'s test suite uses statistical hypothesis tests to verify the correctness of its BSDF sampling routines. The idea of verifying such graphics-related Monte Carlo sampling routines using statistical tests was introduced by Subr and Arvo (2007a).
][
  `pbrt` 的测试套件使用统计假设测试来验证其 BSDF 采样程序的正确性。Subr 和 Arvo（2007a）引入了使用统计测试验证此类与图形相关的蒙特卡罗采样程序的想法。
]

#parec[
  The \$\\\\chi^2\$ test variant that is used in `pbrt` was originally developed as part of the #emph[Mitsuba] renderer by Jakob (2010).
][
  `pbrt` 中使用的 $chi^2$ 检验变体最初是由 Jakob（2010）作为 #emph[Mitsuba] 渲染器的一部分开发的。
]


