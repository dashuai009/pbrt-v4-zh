#import "../template.typ": parec

== Rough Dielectric BSDF
<rough-dielectric-BSDF>

#parec[
  We will now extend the microfacet approach from Section 9.6 to the case of rough dielectrics. This involves two notable changes: since dielectrics are characterized by both reflection and transmission, the model must be aware of these two separate components. In the case of transmission, Snell's law will furthermore replace the law of reflection in the computation that determines the incident direction.
][
  我们现在将扩展第9.6节中的微表面方法，应用于粗糙介电体的情况。这涉及两个显著的变化：由于介电体具有反射和透射特性，模型必须考虑这两个独立的组件。在透射的情况下，斯涅尔定律将取代反射定律，用于确定入射方向的计算。
]

#parec[
  Figure 9.32 shows the dragon rendered with the Torrance–Sparrow model and both reflection and transmission.
][
  图9.32展示了使用Torrance–Sparrow模型渲染的龙模型，表现出反射和透射。
]

#parec[
  As before, we will begin by characterizing the probability density of generated samples. The implied BSDF then directly follows from this density and the sequence of events encapsulated by a scattering interaction: visible normal sampling, reflection or refraction, and attenuation by the Fresnel and masking terms.
][
  如前所述，我们将首先描述生成样本的概率密度。隐含的BSDF直接来自于这种密度和散射交互中封装的事件序列：可见法线采样、反射或折射，以及由菲涅耳和遮蔽项引起的衰减。
]

#parec[
  The density evaluation occurs in the following fragment that we previously omitted during the discussion of the smooth dielectric case.
][
  密度评估发生在以下片段中，我们在讨论光滑介电体的情况下曾省略过。
]

#parec[
  We now turn to the generalized half-direction vector, whose discussion requires a closer look at Snell's law (Equation 9.2) relating the elevation and azimuth of the incident and outgoing directions at a refractive interface:
][
  接下来，我们将讨论广义半向量，这需要更仔细地查看斯涅尔定律（方程9.2），它涉及入射和出射方向在折射界面处的仰角和方位角：
]

#parec[
  Since the refraction takes place at the level of the microgeometry, all of these angles are to be understood within a coordinate frame aligned with the microfacet normal ωm. Recall also that the sines in the first equation refer to the length of the tangential component of ωi and ωo perpendicular to ωm.
][
  由于折射发生在微观几何尺度，所有这些角度都应在与微表面法线对齐的坐标系中理解。还要记住，第一个方程中的正弦指的是ωi和ωo垂直于ωm的切向分量的长度。
]

#parec[
  A generalized half-direction vector builds on this observation by scaling and adding these directions to cancel out the tangential components, which yields the surface normal responsible for a particular refraction after normalization. It is defined as
][
  广义半向量基于这一观察，通过缩放和相加这些方向来抵消切向分量，从而在归一化后得到负责特定折射的表面法线。其定义为
]

#parec[
  where η = ηi/ηo is the relative index of refraction toward the sampled direction ωi. The reflective case is trivially subsumed, since ηi = ηo when no refraction takes place. The next fragment implements this computation, including handling of invalid configurations (e.g., perfectly grazing incidence) where both the BSDF and its sampling density evaluate to zero.
][
  其中η = ηi/ηo是朝向采样方向ωi的相对折射率。反射情况可以简单地包含在内，因为当没有折射发生时，ηi \= ηo。下一个片段实现了这个计算，包括处理无效配置（例如，完全掠射入射），在这种情况下，BSDF及其采样密度都评估为零。
]

#parec[
  The last line reflects an important implementation detail: with the previous definition in Equation 9.34, ωm always points toward the denser medium, whereas pbrt uses the convention that micro- and macro-normal are consistently oriented (i.e., ωm · n \> 0). In practice, we therefore compute the following modified half-direction vector, where n = (0, 0, 1) in local coordinates:
][
  最后一行反映了一个重要的实现细节：根据前面的定义在方程9.34中，ωm总是指向较密介质，而pbrt使用的惯例是微观和宏观法线方向一致（即，ωm · n \> 0）。因此，在实践中，我们计算以下修改后的半向量，其中n = (0, 0, 1)在局部坐标中：
]


#parec[
  Next, microfacets that are backfacing with respect to either the incident or outgoing direction do not contribute and must be discarded.
][
  接下来，相对于入射或出射方向背向的微面不贡献并且必须被丢弃。
]

#parec[
  Given \$ \_{}^m \$, we can evaluate the Fresnel reflection and transmission terms using the specialized dielectric evaluation of the Fresnel equations.
][
  给定 \$ \_{}^m \$，我们可以使用费涅尔方程的专用介电评估来评估费涅尔反射和透射项。
]

#parec[
  We now have the values necessary to compute the PDF for \$ \_{}^i \$, which depends on whether it reflects or transmits at the surface.
][
  我们现在有了计算 \$ \_{}^i \$ 的概率密度函数 (PDF) 所需的值，这取决于它在表面是反射还是透射。
]

#parec[
  As before, the bijective mapping between \$ #emph[{}^m \$ and \$ ];{}^i \$ provides a change of variables whose Jacobian determinant is crucial so that we can correctly deduce the probability density of sampled directions \$ \_{}^i \$. The derivation is more involved in the refractive case; see the "Further Reading" section for pointers to its derivation. The final determinant is given by
][
  如前所述，\$ #emph[{}^m \$ 和 \$ ];{}^i \$ 之间存在双射映射。这种映射的雅可比行列式是关键，以便我们可以正确推导出采样方向 \$ \_{}^i \$ 的概率密度。在折射情况下的推导更复杂；请参阅“进一步阅读”部分以获取其推导的指引。最终的行列式如下所示
]

#parec[
  Once more, this relationship makes it possible to evaluate the probability per unit solid angle of the sampled incident directions \$ \_{}^i \$ obtained through the combination of visible normal sampling and scattering:
][
  再次，这种关系使我们能够评估通过可见法线采样和散射组合获得的采样入射方向 \$ \_{}^i \$ 的每单位立体角的概率：
]

#parec[
  The following fragment implements this computation, while additionally accounting for the discrete probability `pt / (pr + pt)` of sampling the transmission component.
][
  以下代码片段实现了这一计算，同时还考虑了采样透射分量的离散概率 `pt / (pr + pt)`。
]

#parec[
  Finally, the density of the reflection component agrees with the model used for conductors but for the additional discrete probability `pr / (pr + pt)` of choosing the reflection component.
][
  最后，反射分量的密度与用于导体的模型一致，但增加了选择反射分量的离散概率 `pr / (pr + pt)`。
]

#parec[
  BSDF evaluation is similarly split into reflective and transmissive components.
][
  BSDF 评估同样分为反射和透射分量。
]

#parec[
  The reflection component follows the approach used for conductors in the fragment \<\<#link("Roughness_Using_Microfacet_Theory.html#fragment-EvaluateroughconductorBRDF-0")[Evaluate rough conductor BRDF];\>\>:
][
  反射分量遵循片段 \<\<#link("Roughness_Using_Microfacet_Theory.html#fragment-EvaluateroughconductorBRDF-0")[评估粗糙导体 BRDF];\>\> 中用于导体的方法：
]


#parec[
  Stratified sampling subdivides the integration domain $Lambda$ into $n$ nonoverlapping regions $Lambda_1 , Lambda_2 , dots.h , Lambda_n$. Each region is called a #emph[stratum];, and they must completely cover the original domain:
][
  分层采样将积分域 $Lambda$ 细分为 $n$ 个不重叠的层 $Lambda_1 , Lambda_2 , dots.h , Lambda_n$。每个层称为一个“层”，它们必须完全覆盖原始域：
]

#parec[
  $ union.big_(i = 1)^n Lambda_i = Lambda . $
][
  $ union.big_(i = 1)^n Lambda_i = Lambda . $
]

#parec[
  To draw samples from $Lambda$, we will draw $n_i$ samples from each $Lambda_i$, according to densities $p_i$ inside each stratum. A simple example is supersampling a pixel. With stratified sampling, the area around a pixel is divided into a $k times k$ grid, and a sample is drawn uniformly within each grid cell. This is better than taking $k^2$ random samples, since the sample locations are less likely to clump together. Here we will show why this technique reduces variance.
][
  为了从 $Lambda$ 中抽取样本，我们将从每个 $Lambda_i$ 中抽取 $n_i$ 个样本，根据每个层内的密度 $p_i$。一个简单的例子是像素超采样。使用分层采样，像素周围的区域被划分为一个 $k times k$ 的网格，并在每个网格单元内均匀地抽取一个样本。这比取 $k^2$ 个随机样本要好，因为样本位置不太可能聚集在一起。在这里，我们将解释为什么这种技术能减少方差。
]


