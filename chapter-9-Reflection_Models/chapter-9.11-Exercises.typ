#import "../template.typ": parec


== Exercises
#parec[
  A consequence of Fermat's principle from optics is that light traveling from a point $p_1$ in a medium with index of refraction $eta_1$ to a point $p_2$ in a medium with index of refraction $eta_2$ will follow a path that minimizes the time to get from the first point to the second point. Snell's law can be shown to follow directly from this fact.
][
  费马原理在光学中的一个结果是，从介质中折射率为 $eta_1$ 的点 $p_1$ 到介质中折射率为 $eta_2$ 的点 $p_2$ 的光线将遵循一条使从第一个点到第二个点的时间最短的路径。可以直接从这个原理推导出斯涅尔定律。
]

#parec[
  Consider light traveling between two points $p_1$ and $p_2$ separated by a planar boundary. The light could potentially pass through the boundary while traveling from $p_1$ to $p_2$ at any point on the boundary (see Figure 9.56, which shows two such possible points $p prime$ and $p prime.double$ ). Recall that the time it takes light to travel between two points in a medium with a constant index of refraction is proportional to the distance between them times the index of refraction in the medium.
][
  考虑光线在平面边界分隔的两个点 $p_1$ 和 $p_2$ 之间传播。光线可能会在从 $p_1$ 到 $p_2$ 的过程中通过边界上的任何一点（参见图 9.56，其中显示了两个可能的点 $p prime$ 和 $p prime.double$ ）。回忆一下，光线在折射率恒定的介质中从一点到另一点所需的时间与两点之间的距离及介质的折射率成正比。
]

#parec[
  Using this fact, show that the point $p prime$ on the boundary that minimizes the total time to travel from $p_1$ to $p_2$ is the point where $eta_1 sin theta_1 = eta_2 sin theta_2$.
][
  利用这一事实，证明在边界上使从 $p_1$ 到 $p_2$ 的总时间最短的点 $p prime$ 是 $eta_1 sin theta_1 = eta_2 sin theta_2$ 的点。
]

#parec[
  Read the recent paper by d'Eon (2021) that describes a BRDF based on a model of the aggregate scattering of large collections of spherical particles that are themselves Lambertian. Implement this approach as a new #strong[BxDF] in #strong[pbrt] and render images comparing its visual appearance to that of the #strong[DiffuseBxDF];.
][
  阅读 d'Eon（2021）的最新论文，该论文描述了一种基于大量球形粒子集合的聚合散射模型的 BRDF。在 #strong[pbrt] 中实现此方法为一个新的 #strong[BxDF];，并渲染图像以比较其与 #strong[DiffuseBxDF] 的视觉效果。
]

#parec[
  Read the paper of Wolff and Kurlander (1990) and the course notes of Wilkie and Weidlich (2012) and apply some of the techniques described to modify #strong[pbrt] to model the effect of light polarization.
][
  阅读 Wolff 和 Kurlander（1990）的论文以及 Wilkie 和 Weidlich（2012）的课程笔记，并应用其中描述的一些技术来修改 #strong[pbrt] 以模拟光的偏振效应。
]

#parec[
  Set up scenes and render images of them that demonstrate a significant difference when polarization is accurately modeled. For this, you will need to implement a polarized version of the Fresnel equations and add BSDFs that model optical elements like linear polarizers and retarders.
][
  设置场景并渲染它们的图像，以显示在准确模拟偏振时的显著差异。为此，您需要实现偏振版的菲涅耳方程，并添加模拟光学元件（如线性偏振器和相位延迟器）的 BSDF。
]

#parec[
  Construct a scene with an actual geometric model of a rough plane with a large number of mirrored microfacets, and illuminate it with an area light source.
][
  构建一个具有大量镜面微面元的粗糙平面的实际几何模型场景，并用一个区域光源照亮它。
]

#parec[
  Place the camera in the scene such that a very large number of microfacets are in each pixel's area, and render images of this scene using hundreds or thousands of pixel samples.
][
  将相机放置在场景中，使每个像素区域内都有大量的微面元，并使用数百或数千个像素样本渲染此场景的图像。
]

#parec[
  Compare the result to using a flat surface with a microfacet-based BRDF model. How well can you get the two approaches to match if you try to tune the microfacet BRDF parameters?
][
  将结果与使用基于微面元的 BRDF 模型的平面进行比较。如果您尝试调整微面元 BRDF 参数，您能否使这两种方法匹配得很好？
]

#parec[
  Can you construct examples where images rendered with the true microfacets are actually visibly more realistic due to better modeling the effects of masking, self-shadowing, and interreflection between microfacets?
][
  您能否构建一些示例，其中使用真实微面元渲染的图像由于更好地模拟了遮蔽、自阴影和微面元之间的相互反射而实际上更加逼真？
]

#parec[
  One shortcoming of the microfacet-based BSDFs in this chapter is that they do not account for multiple scattering among microfacets.
][
  本章中基于微面元的 BSDF 的一个缺点是它们没有考虑微面元之间的多重散射。
]

#parec[
  Investigate previous work in this area, including the stochastic multiple scattering model of Heitz et al.~(2016b) and the analytic models of Lee et al.~(2018) and Xie and Hanrahan (2018), and implement one of these approaches in #strong[pbrt];.
][
  研究该领域的先前工作，包括 Heitz 等人（2016b）的随机多重散射模型以及 Lee 等人（2018）和 Xie 和 Hanrahan（2018）的解析模型，并在 #strong[pbrt] 中实现这些方法之一。
]

#parec[
  Then implement an approximate model for multiple scattering, such as the one presented by Kulla and Conty Estevez (2017) or by Turquin (2019).
][
  然后实现一个多重散射的近似模型，例如 Kulla 和 Conty Estevez（2017）或 Turquin（2019）提出的模型。
]

#parec[
  How do rendered images differ from #strong[pbrt];'s current implementation? How closely do the approximate approaches match the more comprehensive ones?
][
  渲染的图像与 #strong[pbrt] 当前实现有何不同？近似方法与更全面的方法有多接近？
]

#parec[
  How does execution time compare?
][
  执行时间如何比较？
]

#parec[
  Review the algorithms for efficiently finding an approximation of a material's normal distribution function and using that to measure BRDFs that are outlined in Section 9.8 and explained in more detail in Dupuy and Jakob (2018).
][
  回顾第 9.8 节中概述的用于有效找到材料法线分布函数的近似并使用其测量 BRDF 的算法，并在 Dupuy 和 Jakob（2018）中更详细地解释。
]

#parec[
  Follow this approach to implement a #emph[virtual gonioreflectometer];, where you provide #strong[pbrt] with a description of the microgeometry of a complex surface (cloth, velvet, etc.) and its low-level reflection properties and then perform virtual measurements of the BSDF by simulating light paths in the microgeometry.
][
  按照这种方法实现一个#emph[虚拟光度计];，其中您为 #strong[pbrt] 提供复杂表面（如布料、天鹅绒等）的微观几何结构及其低级反射特性的描述，然后通过模拟微观几何中的光路径进行 BSDF 的虚拟测量。
]

#parec[
  Store the results of this simulation in the file format used by the #strong[MeasuredBxDFData] and then render images that compare using the tabularized representation to directly rendering the microgeometry.
][
  将此模拟的结果存储在 #strong[MeasuredBxDFData] 使用的文件格式中，然后渲染图像，将使用表格化表示与直接渲染微观几何进行比较。
]

#parec[
  How do the images compare? How much more computationally efficient is using the #strong[MeasuredBxDFData];?
][
  图像如何比较？使用 #strong[MeasuredBxDFData] 在计算效率上有多大提高？
]

#parec[
  Marschner et al.~(2003) note that human hair actually has an elliptical cross section that causes glints in human hair due to caustics; subsequent work by Khungurn and Marschner (2017) proposes a model that accounts for this effect and shows that it matches measurements of scattering from human hair well.
][
  Marschner 等人（2003）指出，人类头发实际上具有椭圆形的横截面，这导致由于焦散而在头发中产生闪光；Khungurn 和 Marschner（2017）的后续工作提出了一种模型，考虑到这种效应，并显示出它与人类头发的散射测量结果非常匹配。
]

#parec[
  Extend the #strong[HairBxDF] implementation here, following their approach.
][
  按照他们的方法扩展此处的 #strong[HairBxDF] 实现。
]

#parec[
  One issue that you will need to address is that the $frac(partial n, partial v)$ returned by #strong[Curve::Intersect()] is always perpendicular to the incident ray, which leads to different orientations of the azimuthal coordinate system.
][
  您需要解决的一个问题是 #strong[Curve::Intersect()] 返回的 $frac(partial n, partial v)$ 总是垂直于入射光线，这导致方位角坐标系的不同方向。
]

#parec[
  This is not an issue for the model we have implemented, since it operates only on the difference between angles $phi.alt$ in the hair coordinate system.
][
  对于我们实现的模型来说，这不是问题，因为它仅在头发坐标系中的角度 $phi.alt$ 之间的差异上起作用。
]

#parec[
  For elliptical hairs, a consistent azimuthal coordinate system is necessary.
][
  对于椭圆形头发，需要一致的方位角坐标系。
]

#parec[
  Read Yan et al.'s paper on fur scattering (2015) and implement their model, which accounts for scattering in the medulla in fur.
][
  阅读 Yan 等人关于毛发散射的论文（2015），并实现他们的模型，该模型考虑了毛发髓质中的散射。
]

#parec[
  Render images that show the difference from accounting for this in comparison to the current implementation.
][
  渲染图像，显示与当前实现相比考虑这一点的差异。
]

#parec[
  You may want to also see Section 4.3 of Chiang et al.~(2016a), which discusses extensions for modeling the undercoat (which is shorter and curlier hair underneath the top level) and a more #emph[ad hoc] approach to account for the influence of scattering from the medulla.
][
  您可能还想查看 Chiang 等人（2016a）的第 4.3 节，其中讨论了用于建模底层毛发（在顶层下方较短且卷曲的毛发）的扩展以及一种更#emph[特定];的方法来考虑髓质散射的影响。
]

#parec[
  Read one or more papers from the "Further Reading" section of this chapter on efficiently rendering glints, which are evident when the surface microstructure is large enough or viewed closely enough that the assumption of a continuous distribution of microfacet orientations is no longer valid.
][
  阅读本章“进一步阅读”部分中的一篇或多篇关于高效渲染闪光的论文，当表面微观结构足够大或观察得足够近时，微面元方向的连续分布假设不再有效。
]

#parec[
  Then, choose one such approach and implement it in #strong[pbrt];. Render images that show off the effects it is capable of producing.
][
  然后，选择一种方法并在 #strong[pbrt] 中实现它。渲染图像，展示它能够产生的效果。
]


