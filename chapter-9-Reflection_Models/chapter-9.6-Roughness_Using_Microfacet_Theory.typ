#import "../template.typ": ez_caption, parec

== Roughness Using Microfacet Theory
<roughness-using-microfacet-theory>

#parec[
  The preceding discussion of the #link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[`ConductorBxDF`] and #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`] only considered the perfect specular case, where the interface between materials was assumed to be ideally smooth and devoid of any roughness or other surface imperfections. However, many real-world materials are rough at a microscopic scale, which affects the way in which they reflect or transmit light.
][
  前面的#link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[`导体BxDF`(`ConductorBxDF`)];和#link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`];讨论仅考虑了完美镜面情况，其中假设材料之间的界面是理想光滑的，没有任何粗糙度或其他表面缺陷。然而，许多现实世界的材料在微观尺度上存在粗糙度，这会影响它们的光反射或传输方式。
]

#parec[
  We will now turn to a generalization of these `BxDF`s using #emph[microfacet theory];, which models rough surfaces as a collection of small surface patches denoted as #emph[microfacets];. These microfacets are assumed to be individually very small so that they cannot be resolved by the camera. Yet, despite their small size, they can have a profound impact on the angular distribution of scattered light. @fig:microfacet shows cross sections of a relatively rough surface and a much smoother microfacet surface. We will use the term #emph[macrosurface] to describe the original coarse surface (e.g., as represented by a `Shape`) and #emph[microsurface] to describe the fine-scale geometry based on microfacets.
][
  我们现在将转向使用#emph[微面理论];对这些`BxDF`进行概括，该理论将粗糙表面建模为一组称为#emph[微面(microfacet)];的小表面片段。这些微面被假设为单独非常小，以至于相机无法分辨。然而，尽管它们很小，它们可以对散射光的角度分布产生深远影响。 @fig:microfacet;展示了一个相对粗糙的表面和一个更光滑的微面截面。我们将使用#emph[宏面];来描述原始粗糙表面（例如，由`Shape`表示）和#emph[微面(microfacet)];来描述基于微面的细尺度几何。
]


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f20.svg"),
  caption: [
    #ez_caption[
      Microfacet surface models are often described by a function that gives the distribution of microfacet normals $omega_m$ with respect to the surface normal $upright(bold(n))$. (a) The greater the variation of microfacet normals, the rougher the surface is. (b) Smooth surfaces have relatively little variation of microfacet normals.
    ][
      微表面模型通常用一个函数来描述微表面法线 $omega_m$ 相对于表面法线 $upright(bold(n))$ 的分布情况。(a) 微表面法线的变化越大，表面越粗糙。(b) 平滑的表面则具有相对较小的微表面法线变化。
    ]
  ],
)<microfacet>
#parec[
  It is worth noting that `pbrt` can in principle already render rough surfaces without resorting to microfacet theory: users could simply create extremely high-resolution triangular meshes containing such micro-scale surface variations and render them using perfect specular `BxDF`s. There are two fundamental problems with such an approach:
][
  值得注意的是，`pbrt`原则上已经可以渲染粗糙表面而无需借助微面理论：用户可以简单地创建包含这种微尺度表面变化的极高分辨率三角网格，并使用完美镜面`BxDF`进行渲染。 这种方法有两个基本问题：
]

#parec[
  - #emph[Storage and ray tracing efficiency:] Representing micro-scale
    roughness using triangular geometry would require staggeringly large
    triangle budgets. The overheads to store and ray trace such large
    scenes are prohibitive.
][
  - #emph[存储和光线追踪效率：]
    使用三角几何表示微尺度粗糙度将需要极其庞大的三角预算。存储和光线追踪如此大场景的开销是难以承受的。
]

#parec[
  - #emph[Monte Carlo sampling efficiency:] A fundamental issue with perfect specular scattering distributions is that they contain Dirac delta terms, which preclude BSDF evaluation (their `f()` method returns zero, making BSDF sampling the only supported operation). This aspect disables #emph[light sampling] strategies~(@light-interface), which are crucial for efficiency in Monte Carlo rendering.
][
  - #emph[蒙特卡罗的采样效率：]完美镜面散射分布的一个基本问题是它们包含狄拉克δ项，这排除了BSDF评估（它们的`f()`方法返回零，使得BSDF采样成为唯一支持的操作）。这一方面禁用了#emph[光采样];策略（@light-interface），这些策略对于蒙特卡罗渲染的效率至关重要。
]

#parec[
  A key insight of microfacet theory is that large numbers of microfacets can be efficiently modeled statistically, since it is only their aggregate behavior that determines the observed scattering. (A similar statistical physics approach is used to avoid the costly storage of vast numbers of small particles comprising participating media in @volume-scattering.) This approach addresses both of the above issues: BSDF models based on microfacet theory do not require explicit storage of the microgeometry, and they replace the infinitely peaked Dirac delta terms with smooth distributions that enable more efficient Monte Carlo sampling.
][
  微面理论的一个关键见解是可以通过统计方法有效地建模大量微面，因为只有它们的总体行为决定了观察到的散射。 （类似的统计物理方法用于避免在@volume-scattering 中存储大量小粒子组成的参与介质的高昂成本。）这种方法解决了上述两个问题：基于微面理论的BSDF模型不需要显式存储微观几何，并且它们用平滑分布替代了无限尖锐的狄拉克δ项，从而实现更高效的蒙特卡罗采样。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f21.svg"),
  caption: [
    #ez_caption[
      Three Important Geometric Effects to Consider with Microfacet Reflection Models. (a) Masking: the microfacet of interest is not visible to the viewer due to occlusion by another microfacet. (b) Shadowing: analogously, light does not reach the microfacet. (c) Interreflection: light bounces among the microfacets before reaching the viewer.
    ][
      微表面反射模型中需要考虑的三个重要几何效应。(a) 遮挡效应：由于被其他微表面遮挡，目标微表面对观察者不可见。(b) 阴影效应：类似地，光线无法照射到该微表面。(c) 互反射效应：光线在到达观察者之前在多个微表面之间反弹。
    ]
  ],
)<mf-effects>
#parec[
  Several factors related to the geometry of the microfacets affect how they scatter light (@fig:mf-effects): for example, a microfacet may be occluded ("masked") or lie in the shadow of a neighboring microfacet, and incident light may interreflect among microfacets. Widely used microfacet BSDFs ignore interreflection and model the remaining masking and shadowing effects using statistical approximations with efficient evaluation procedures.
][
  与微面几何相关的几个因素会影响它们如何散射光（@fig:mf-effects）：例如，一个微面可能被遮挡（"遮蔽"）或位于相邻微面的阴影中，入射光可能在微面之间互相反射。 广泛使用的微面BSDF忽略互反射，并使用统计近似和高效评估程序建模剩余的遮蔽和阴影效应。
]

#parec[
  The two main components of microfacet models are a representation of the statistical distribution of facets and a BSDF that describes how light scatters from an individual microfacet. For the latter part, `pbrt` supports perfect specular conductors and dielectrics, though other choices are in principle also possible. Given these two ingredients, the aggregate BSDF arising from the microsurface can be determined.
][
  微面模型的两个主要组成部分是微面的统计分布和光如何从单个微面散射的BSDF。 对于后者，`pbrt`支持完美镜面导体和介电体，尽管原则上也可以选择其他选项。给定这两个成分，可以由微面得到总体BSDF。
]

=== The Microfacet Distribution
<the-microfacet-distribution>


#parec[
  Microgeometry principally affects scattering via variation of the surface normal, which is a consequence of the central role of the surface normal in Snell's law and the law of specular reflection. Under the assumption that the light source and observer are distant with respect to the scale of the microfacets, the precise surface profile has a lesser effect on masking and shadowing that we will study in @the-masking-function. For now, our focus is on the #emph[microfacet distribution];, which represents roughness in terms of its effect on the surface normal.
][
  微观几何主要通过表面法线的变化影响散射，这是由于表面法线在斯涅尔定律和镜面反射定律中的核心作用。 假设光源和观察者相对于微面的尺度是远的，精确的表面轮廓对我们将在@the-masking-function;中研究的遮蔽和阴影的影响较小。 目前，我们的重点是#emph[微面分布];，它以其对表面法线的影响来表示粗糙度。
]

#parec[
  Let us denote a small region of a macrosurface as $upright(d) A$. The corresponding microsurface $upright(d) A_mu$ is obtained by displacing the macrosurface along its normal $upright(bold(n))$, which means that the perpendicular projection of the microsurface exactly covers the macrosurface:
][
  让我们将宏面的一个小区域表示为 $upright(d) A$。相应的微面 $upright(d) A_mu$ 是通过沿其法线 $upright(bold(n))$ 置换（displacing）宏面获得的，这意味着微面的垂直投影正好覆盖宏面：
]

$
  integral_(d A_mu) (omega_(upright(m)) (p) dot.op upright(bold(n))) upright(d) p = integral_(d A) upright(d) p ,
$<ufacet-normalization-p>
#parec[
  where $omega_(upright(m)) (p)$ specifies the microfacet normal at $p$. However, tracking the orientation of vast numbers of microfacets would be impractical as previously discussed.
][
  其中 $omega_(upright(m)) (p)$ 指定了 $p$ 处的微面法线。然而，如前所述，跟踪大量微面的方向是不切实际的。
]

#parec[
  We therefore turn to a statistical approach: the #emph[microfacet distribution function] $D(omega_m)$ gives the relative differential area of microfacets with the surface normal $omega_m$. For example, a perfectly smooth surface has a Dirac delta peak in the direction of the original surface normal—that is, $D(omega_m) = delta(omega_m - upright(bold(n)))$. The function is generally expressed in the standard reflection coordinate system with $upright(bold(n))= (0, 0, 1)$.
][
  因此，我们转向统计方法：#emph[微面分布函数] $D(omega_m)$给出了具有表面法线 $omega_m$ 的微面的相对微分面积。 例如，完美光滑的表面在原始表面法线方向上具有狄拉克$delta$峰值，即 $D(omega_m) = delta(omega_m - upright(bold(n)))$。 该函数通常在标准反射坐标系中表示，其中 $upright(bold(n))= (0, 0, 1)$。
]

#parec[
  Cast into the directional domain, @eqt:ufacet-normalization-p provides a useful normalization condition ensuring that a particular microfacet distribution is physically plausible, as illustrated in @fig:microfacet-projected-area.
][
  转换到方向域，@eqt:ufacet-normalization-p 提供了一个有用的归一化条件，确保特定的微面分布在物理上是合理的，如@fig:microfacet-projected-area;所示。
]


$
  integral_(cal(H)^2 (upright(bold(n)))) D(omega_m)(omega_m dot.op upright(bold(n))) dif omega_m = integral_(cal(H)^2 (upright(bold(n)))) D(omega_m) cos theta_m dif omega_m = 1 .
$<ufacet-normalization-wm>


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f22.svg"),
  caption: [
    #ez_caption[
      Given a differential area on a surface $upright(d)A$, the microfacet normal distribution function $D(omega_m)$ must be normalized such that the projected surface area of the microfacets above the area is equal to $upright(d)A$.
    ][
      考虑到表面上的一个微分面积 $upright(d)A$，微面元法线分布函数 $D(omega_m)$ 必须被归一化，使得位于该面积上方的微面元的投影表面积等于 $upright(d)A$。
    ]
  ],
)<microfacet-projected-area>



#parec[
  The most common type of microfacet distribution is #emph[isotropic];, which also leads to an isotropic aggregate BSDF. Recall that the local scattering behavior of an isotropic BSDF does not change when the surface is rotated about the macroscopic surface normal. In the isotropic case, a spherical coordinate parameterization $omega_m = (theta_m , phi.alt_m)$ yields a distribution that only depends on the elevation angle $theta_m$.
][
  最常见的微表面分布类型是#emph[各向同性];，这也导致各向同性的聚合BSDF。回忆一下，各向同性BSDF的局部散射行为在表面绕宏观表面法线旋转时不会改变。在各向同性情况下，球坐标参数化 $omega_m = (theta_m , phi.alt_m)$ 产生的分布仅依赖于仰角 $theta_m$。
]

#parec[
  In contrast, an anisotropic microfacet distribution also depends on the azimuth $phi.alt_m$ to capture directional variation in the surface roughness. Many real-world materials are anisotropic: for example, rolled or milled steel surfaces feature grooves that are aligned with the direction of extrusion. Rotating a flat sheet of such material about the surface normal results in noticeable variation—for example, in the reflection profile of indirectly observed light sources. Brushed metal is an extreme case: its microfacet distribution varies from almost a single direction to almost uniform over the hemisphere.
][
  相比之下，各向异性微表面分布还依赖于方位角 $phi.alt_m$，以捕捉表面粗糙度的方向变化。许多现实世界的材料是各向异性的：例如，轧制或铣削的钢材表面具有与挤出方向对齐的槽纹。将这种材料的平板绕表面法线旋转会导致明显的变化，例如间接观察到的光源的反射轮廓。刷纹金属属于极端情况：其微表面分布从近乎单一方向到半球面近乎均匀分布不等。
]

#parec[
  Many functional representations of microfacet distributions have been proposed over the years. Geometric analysis of a truncated ellipsoid leads to one of the most widely used distributions proposed by Trowbridge and Reitz (1975), in which the conceptual microsurface is composed of vast numbers of ellipsoidal bumps. (2007) who is dubbed it "GGX". Scaled along its different semi-axes, an ellipsoid can take on a variety of configurations including sphere-, pancake-, and cigar-shaped surfaces. It is enough to study the density of surface normals on a single representative ellipsoid, which has an analytic solution:
][
  多年来，已经提出了许多微表面分布的功能表示。截断椭球体的几何分析导致了Trowbridge和Reitz提出的最广泛使用的分布之一（1975），其中概念上的微表面由大量椭球形隆起组成。
]

$
  D(omega_m) = 1/(pi alpha_x alpha_y cos^4 theta_m (1 + tan^2 theta_m ((cos^2 phi.alt_m)/(alpha_x^2) + (sin^2 phi.alt_m)/(alpha_y^2)))^2)
$<tr-d-function>

#parec[
  This equation assumes that the semi-axes of the ellipsoid are aligned with the shading frame, and the reciprocals of the two variables $1 \/ alpha_x , 1 \/ alpha_y > 0$ encode a scale transformation applied along the two tangential axes. When $alpha_x , alpha_y approx 0$, the ellipsoid has been stretched to such a degree that it essentially collapses into a flat surface, and the aggregate BSDF approximates a perfect specular material. For larger values (e.g., $alpha_x , alpha_y approx 0.3$ ), the ellipsoidal bumps introduce significant normal variation that blurs the directional distribution of reflected and transmitted light.
][
  该方程假设椭球体的半轴与阴影框架对齐，两个变量 $1 \/ alpha_x , 1 \/ alpha_y > 0$ 的倒数编码了沿两个切向轴应用的缩放变换。当 $alpha_x , alpha_y approx 0$ 时，椭球体被拉伸到几乎坍塌成一个平面，聚合BSDF近似为完美的镜面材料。对于较大的值（例如， $alpha_x , alpha_y approx 0.3$ ），椭球形隆起引入显著的法线变化，模糊了反射和透射光的方向分布。
]

#parec[
  A characteristic feature of the Trowbridge-Reitz model compared to other microfacet distributions is its long tails: the density of microfacets decays comparably slowly as $omega_m$ approaches grazing configurations ( $theta_m arrow.r 90^circle.stroked.tiny$ ). This matches the properties of many real-world surfaces well.See @fig:d-plot-comparison for a graph of it and another commonly used microfacet distribution function.
][
  Trowbridge-Reitz模型与其他微表面分布相比的一个特征是其长尾：当 $omega_m$ 接近掠射配置时（ $theta_m arrow.r 90^circle.stroked.tiny$ ），微表面密度衰减得相对缓慢。这很好地匹配了许多现实世界表面的特性。 参见@fig:d-plot-comparison，其中展示了该函数与另一个常用的微表面分布函数的图表。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f23.svg"),
  caption: [
    #ez_caption[
      Graphs of isotropic Beckmann-Spizzichino and Trowbridge-Reitz microfacet distribution functions as a function of $theta$ for $alpha = 0.5$. Note that Trowbridge-Reitz has higher tails at larger values of $theta$.
    ][
      各向同性Beckmann-Spizzichino和Trowbridge-Reitz微面分布函数随$theta$变化的曲线图（$alpha = 0.5$）。需注意的是，Trowbridge-Reitz函数在$theta$较大时具有更高的尾部。
    ]
  ],
)<d-plot-comparison>


#parec[
  The `TrowbridgeReitzDistribution` class encapsulates the state and functionality needed to use this microfacet distribution in a Monte Carlo renderer.
][
  `TrowbridgeReitzDistribution` 类封装了在蒙特卡罗渲染器中使用这种微表面分布所需的状态和功能。
]

```cpp
<<TrowbridgeReitzDistribution Definition>>=
class TrowbridgeReitzDistribution {
  public:
    <<TrowbridgeReitzDistribution Public Methods>>
  private:
    <<TrowbridgeReitzDistribution Private Members>>
};
```


```cpp
<<TrowbridgeReitzDistribution Public Methods>>=
TrowbridgeReitzDistribution(Float alpha_x, Float alpha_y)
    : alpha_x(alpha_x), alpha_y(alpha_y) {}

<<TrowbridgeReitzDistribution Private Members>>=
Float alpha_x, alpha_y;
```

#parec[
  The `D()` method is a fairly direct transcription of @eqt:tr-d-function with some additional handling of numerical edge cases.
][
  `D()` 方法是 @eqt:tr-d-function 的一个相当直接的转录，并对数值边界情况进行了一些额外处理。
]

#parec[
  Even with those precautions, numerical issues involving infinite or not-a-number values tend to arise at very low roughnesses. It is better to treat such surfaces as perfectly smooth and fall back to the previously discussed specialized implementations.
  The `EffectivelySmooth()` method tests the $alpha$ values for this case.
][
  即使有这些预防措施，在非常低的粗糙度下，涉及无穷大或非数字值的数值问题往往会出现。最好将此类表面视为完全光滑，并回退到之前讨论的专用实现。 `EffectivelySmooth()` 方法测试这种情况下的 $alpha$ 值。
]


=== The Masking Function
<the-masking-function>


#parec[
  A microfacet distribution alone is not enough to construct a valid energy-conserving BSDF. Observed from a specific direction, only a subset of microfacets is visible, which must be considered to avoid non-physical energy gains. In particular, microfacets may be #emph[masked] because they are backfacing, or due to occlusion by other microfacets. Our approach is once more to capture this effect in a statistically averaged manner instead of tracking the properties of an actual microsurface.
][
  仅仅依靠微面分布是不足以构建一个有效的能量守恒双向散射分布函数（BSDF）的。从特定方向观察时，只有部分微面可见，这一点必须考虑以避免非物理的能量增益。特别是，微面可能因为背向或被其他微面遮挡而被“遮蔽”。我们再次通过统计平均的方法来捕捉这一效果，而不是追踪实际微面的属性。
]

#parec[
  Recall Equation (9.15), which stated that the micro- and macrosurfaces occupy the same area under perpendicular projection along the surface normal $upright(bold(n))$. The #emph[masking function] $G_1 (omega , omega_m)$ enables a generalization of this statement to other projection directions $omega$. We will shortly discuss how $G_1$ is derived and simply postulate its existence for now. The function specifies the fraction of microfacets with normal $omega_m$ that are visible from direction $omega$, and it therefore satisfies $ 0 lt.eq G_1 (omega , omega_m) lt.eq 1 $ for all arguments.
][
  回忆方程(9.15)，它指出微面和宏表面在沿表面法线 $upright(bold(n))$ 的垂直投影下占据相同的面积。#emph[遮蔽函数] $G_1 (omega , omega_m)$ 使这一陈述可以推广到其他投影方向 $omega$。我们将很快讨论 $G_1$ 的推导，并暂时假设它的存在。该函数指定了从方向 $omega$ 观察时法线为 $omega_m$ 的微面可见的比例，因此满足 $ 0 lt.eq G_1 (omega , omega_m) lt.eq 1 $ 对于所有参数。
]

#parec[
  #box(image("../pbr-book-website/4ed/Reflection_Models/pha09f24.svg")) #emph[Figure 9.24: As seen from a viewer or
    a light source, a differential area on the surface has area
    $d A cos theta$, where $cos theta$ is the angle of the incident
    direction with the surface normal. The projected surface area of visible
    microfacets (thick lines) must be equal to $d A cos theta$ as well; the
    masking function $G_1$ gives the fraction of the total microfacet area
    over $d A$ that is visible in the given direction.]
][
  #box(
    image("../pbr-book-website/4ed/Reflection_Models/pha09f24.svg"),
  ) #emph[图9.24：从观察者或光源的角度看，表面上的微分面积为$d A cos theta$，其中$cos theta$是入射方向与表面法线的夹角。可见微面的投影面积（粗线）也必须等于$d A cos theta$；遮蔽函数$G_1$给出了在给定方向上总微面面积相对于$d A$的可见比例。]
]

#parec[
  Figure 9.24 illustrates the oblique generalization of Equation (9.15), whose left hand side integrates over microfacets and computes the area of their perpendicular projection along $omega$. A maximum is taken to ignore backfacing microfacets, and $G_1$ accounts for masking by other facets. The right hand side captures the relative size of the macrosurface, which shrinks by a factor of $cos theta$.
][
  图9.24说明了方程(9.15)的斜投影推广，其左侧对微面进行积分并计算它们沿 $omega$ 的垂直投影面积。取最大值以忽略背向的微面，而 $G_1$ 则考虑了其他面的遮蔽。右侧捕捉了宏表面的相对大小，其因子为 $cos theta$ 缩小。
]

#parec[
  $
    integral_(cal(H)^2 (upright(bold(n)))) D (omega_m) G_1 (omega , omega_m) max ( 0 , omega dot.op omega_m ) d omega_m = omega dot.op upright(bold(n)) = cos theta .
  $
][
  $
    integral_(cal(H)^2 (upright(bold(n)))) D (omega_m) G_1 (omega , omega_m) max ( 0 , omega dot.op omega_m ) d omega_m = omega dot.op upright(bold(n)) = cos theta .
  $
]

#parec[
  We expect that physically plausible combinations of microfacet distribution $D (omega_m)$ (the Trowbridge-Reitz distribution in our case) and masking function $G_1 (omega , omega_m)$ should satisfy this equation. Unfortunately, the microfacet distribution alone does not impose enough conditions to imply a specific $G_1 (omega , omega_m)$ ; an infinite family of functions could fulfill the constraint in Equation (9.17). More information about the specific surface height profile is necessary to narrow down this large set of possibilities.
][
  我们期望微面分布 $D (omega_m)$ （在我们的例子中是Trowbridge-Reitz分布）和遮蔽函数 $G_1 (omega , omega_m)$ 的物理合理组合应满足此方程。不幸的是，仅微面分布不足以施加足够的条件来暗示特定的 $G_1 (omega , omega_m)$ ；可能有无限多的函数族可以满足方程(9.17)中的约束。需要关于特定表面高度轮廓的更多信息来缩小这一庞大的可能性集合。
]

#parec[
  At this point, an approximation is often taken: if the height and normals of different points on the surface are assumed to be #emph[statistically independent];, the material conceptually turns from a connected surface into an opaque soup of little surface fragments that float in space (hence the name "microfacets"). A consequence of this simplification is that masking becomes independent of the microsurface normal $omega_m$, except for the constraint that backfacing facets are ignored ( $omega dot.op omega_m > 0$ ). The masking term can then be moved out of the integral of Equation (9.17):
][
  在这一点上，通常会采取一种近似：如果假设表面上不同点的高度和法线是#emph[统计独立];的，材料在概念上从一个连接的表面变成漂浮在空间中的小表面碎片的不透明汤（因此得名“微面”）。这种简化的结果是遮蔽与微面法线 $omega_m$ 无关，除了忽略背向表面的约束（ $omega dot.op omega_m > 0$ ）。遮蔽项可以从方程(9.17)的积分中移出：
]

#parec[
  $
    G_1 (omega) integral_(cal(H)^2 (upright(bold(n)))) D (omega_m) max ( 0 , omega dot.op omega_m ) d omega_m = cos theta ,
  $
][
  $
    G_1 (omega) integral_(cal(H)^2 (upright(bold(n)))) D (omega_m) max ( 0 , omega dot.op omega_m ) d omega_m = cos theta ,
  $
]

#parec[
  which can be rearranged to solve for $G_1 (omega)$ :
][
  可以重新排列以求解 $G_1 (omega)$ ：
]

#parec[
  $
    G_1 ( omega ) = frac(cos theta, integral_(cal(H)^2 (upright(bold(n)))) D (omega_m) max (0 , omega dot.op omega_m) d omega_m) .
  $
][
  $
    G_1 ( omega ) = frac(cos theta, integral_(cal(H)^2 (upright(bold(n)))) D (omega_m) max (0 , omega dot.op omega_m) d omega_m) .
  $
]

#parec[
  This is #emph[Smith's approximation];. Despite the rather severe simplification, it has been found to be in good agreement with both brute-force simulation of scattering on randomly generated surface microstructures and real-world measurements.
][
  这是#emph[Smith
    近似];。尽管这一简化相当严重，但它已被发现与随机生成的表面微结构散射的蛮力模拟和现实世界测量非常一致。
]

#parec[
  The integral in Equation (9.18) has analytic solutions for various common choices of microfacet distributions $D (omega_m)$, including the Trowbridge-Reitz model. In practice, the masking function is often expressed in terms of an auxiliary function $Lambda (omega)$ that arises naturally when the derivation of masking is conducted in the slope domain. This has some benefits that we shall see shortly, and we therefore adopt the same approach that relates $G_1$ and $Lambda$ as follows:
][
  方程(9.18)中的积分对于各种常见的微面分布 $D (omega_m)$，包括Trowbridge-Reitz模型，都有解析解。在实践中，遮蔽函数通常用一个辅助函数 $Lambda (omega)$ 来表示，该函数在遮蔽的斜率域推导中自然出现。这有一些我们将很快看到的好处，因此我们采用相同的方法，将 $G_1$ 和 $Lambda$ 的关系如下：
]

#parec[
  $ G_1 (omega) = frac(1, 1 + Lambda (omega)) . $
][
  $ G_1 (omega) = frac(1, 1 + Lambda (omega)) . $
]


#parec[
  The `Lambda()` method computes this function.
][
  `Lambda()` 方法计算此函数。
]

#parec[
  Under the uncorrelated height assumption, \$ () \$ has the following analytic solution for the Trowbridge-Reitz distribution:
][
  在不相关高度假设下，\$ () \$ 对于 Trowbridge-Reitz 分布有以下解析解：
]

#parec[
  $ Lambda (omega) = frac(sqrt(1 + alpha^2 tan^2 theta) - 1, 2) , $
][
  $ Lambda (omega) = frac(sqrt(1 + alpha^2 tan^2 theta) - 1, 2) , $
]

#parec[
  where \$ \$ denotes the isotropic surface roughness. An anisotropic generalization follows from the observation that anisotropy implies tangential scaling of the microsurface based on \$ \$ and \$ \$.
][
  其中 \$ \$ 表示各向同性表面粗糙度。各向异性的推广源于观察到它意味着微表面的切向缩放是基于 \$ \$ 和 \$ \$ 的。
]

#parec[
  A 1-dimensional ray \$ \$ that is not aligned with the \$ x \$- or \$ y \$-axis will observe a different scaling amount that lies between these extremes.
][
  一个不与 \$ x \$ 或 \$ y \$ 轴对齐的一维向量 \$ \$ 将观察到介于这些极端之间的不同缩放量。
]

#parec[
  The associated interpolated roughness is given by
][
  相关的插值粗糙度可以通过以下公式计算：
]

#parec[
  $ alpha = sqrt(alpha_x^2 cos^2 phi.alt + alpha_y^2 sin^2 phi.alt) . $
][
  $ alpha = sqrt(alpha_x^2 cos^2 phi.alt + alpha_y^2 sin^2 phi.alt) . $
]

#parec[
  Anisotropic masking reuses the isotropic \$ \$ with this definition of \$ \$.
][
  各向异性遮蔽重用了具有此 \$ \$ 定义的各向同性 \$ \$。
]

#parec[
  The "Further Reading" section at the end of this chapter provides more details on these steps.
][
  本章末尾的“进一步阅读”部分提供了有关这些步骤的更多详细信息。
]

#parec[
  The `Lambda()` function implements Equation (9.20) in the general case.
][
  `Lambda()` 函数在一般情况下实现了方程 (9.20)。
]

#parec[
  Figure 9.25: \*\*Spheres rendered with (left) an anisotropic microfacet distribution and (right) an isotropic distribution.
][
  图 9.25：\*\*使用（左）各向异性微表面分布和（右）各向同性分布渲染的球体。
]

#parec[
  Note the different specular highlight shapes from the anisotropic model.
][
  注意各向异性模型的不同镜面高光形状。
]

#parec[
  We have used spheres here instead of the dragon, since anisotropic models like these depend on a globally consistent set of tangent vectors over the surface to orient the direction of anisotropy in a reasonable way.
][
  我们在这里使用球体而不是龙。因为像这样的各向异性模型依赖于表面上一组全局一致的切向量，以合理的方式定向各向异性的方向。
]

#parec[
  Figure 9.25 compares the appearance of two spheres with an isotropic and an anisotropic microfacet model lit by a light source simulating a distant environment.
][
  图 9.25 比较了两个球体在各向同性和各向异性微表面模型下的外观，这些球体由模拟远距离环境的光源照亮。
]

#parec[
  Figure 9.26 shows a plot of the Trowbridge-Reitz \$ G\_1() \$ function for a few values of \$ \$.
][
  图 9.26 显示了 Trowbridge-Reitz \$ G\_1() \$ 函数在几个 \$ \$ 值下的图表。
]

#parec[
  Observe how the function is close to one over much of the domain but falls to zero at grazing angles, where masking becomes dominant.
][
  观察函数在大部分域上接近于一，但在掠射角处下降到零，此时遮蔽变得占主导地位。
]

#parec[
  Increasing the surface roughness (i.e., higher values of \$ \$) causes the function to fall off more quickly.
][
  增加表面粗糙度（即，较高的 \$ \$ 值）会导致函数更快下降。
]

=== The Masking-Shadowing Function
<the-masking-shadowing-function>

#parec[
  The BSDF is a function of two directional arguments, and each is subject to occlusion effects caused by the surface microstructure.
][
  BSDF 是两个方向参数的函数，每个参数都受到表面微结构引起的遮挡效应的影响。
]

#parec[
  For viewing and lighting directions, these are respectively denoted as #emph[masking] and #emph[shadowing];.
][
  对于观察和照明方向，分别称为#emph[遮蔽];和#emph[阴影];。
]

#parec[
  To handle both cases, the masking function \$ G\_1 \$ must be generalized into a #emph[masking-shadowing function] \$ G \$ that gives the fraction of microfacets in a differential area that are simultaneously visible from both directions \$ \_o \$ and \$ \_i \$.
][
  为了处理这两种情况，遮蔽函数 \$ G\_1 \$ 必须推广为#emph[遮蔽-阴影函数] \$ G \$，它给出在微分面积中同时从两个方向 \$ \_o \$ 和 \$ \_i \$ 可见的微表面比例。
]

#parec[
  We know that \$ G\_1(\_o) \$ gives the fraction of microfacets that are visible from the direction \$ \_o \$, and \$ G\_1(\_i) \$ gives the fraction for \$ \_i \$.
][
  我们知道 \$ G\_1(\_o) \$ 给出了从方向 \$ \_o \$ 可见的微表面比例，而 \$ G\_1(\_i) \$ 给出了 \$ \_i \$ 的比例。
]

#parec[
  If we assume that masking and shadowing are statistically independent events, then these probabilities can simply be multiplied together:
][
  如果我们假设遮蔽和阴影是统计独立事件，那么这些概率则可以简单地相乘：
]

#parec[
  $ G (omega_o , omega_i) = G_1 (omega_o) G_1 (omega_i) . $
][
  $ G (omega_o , omega_i) = G_1 (omega_o) G_1 (omega_i) . $
]

#parec[
  However, this independence assumption is a rather severe approximation that tends to overestimate the amount of shadowing and masking.
][
  然而，这种独立性假设是一个相当严重的近似，往往会高估遮蔽和阴影的量。
]

#parec[
  This can produce undesirable dark regions in rendered images.
][
  这可能会在渲染图像中产生不理想的暗区域。
]

#parec[
  We instead rely on an approximation that accounts for the property that a microfacet with a higher amount of elevation relative to the macrosurface is more likely to be observed from both \$ \_i \$ and \$ \_o \$.
][
  我们依赖于一种近似，该近似考虑到相对于宏观表面具有较高高度的微表面更可能同时从 \$ \_i \$ 和 \$ \_o \$ 被观察到。
]

#parec[
  If the heights of microfacets are normally distributed, a less conservative model for \$ G \$ taking height-based correlation into account can be derived:
][
  如果微表面的高度呈正态分布，则可以推导出一种考虑基于高度相关性的 \$ G \$ 的不太保守的模型：
]


#parec[
  G(\_o, \_i) = .
][
  $ G (omega_o , omega_i) = frac(1, 1 + Lambda (omega_o) + Lambda (omega_i)) . $
]

#parec[
  The bidirectional form of $G$ implements this equation based on the previously defined `Lambda()` function.
][
  双向形式的函数 $G$ 基于先前定义的 `Lambda()` 函数实现了此方程。
]

#parec[
  Float G(Vector3f wo, Vector3f wi) const { return 1 / (1 + Lambda(wo) + Lambda(wi)); }
][
  ```cpp
  Float G(Vector3f wo, Vector3f wi) const {
      return 1 / (1 + Lambda(wo) + Lambda(wi));
  }
  ```
]

=== Sampling the Distribution of Visible Normals
#parec[
  Efficient rendering using microfacet theory hinges on our ability to determine the microfacet encountered by a particular incident ray—in essence, this operation must emulate the process of finding an intersection with the surface microstructure.
][
  使用微面理论进行高效渲染依赖于我们确定特定入射光线遇到的微面的能力——本质上，这个操作必须模拟与表面微结构相交的过程。
]

#parec[
  Thanks to its stochastic definition, an actual ray tracing operation is fortunately not needed: the intersected microfacet follows a known statistical distribution that depends on the roughness and the direction of the incident ray.
][
  由于其随机性定义，幸运的是不需要实际的光线追踪操作：相交的微面遵循已知的统计分布，这取决于粗糙度和入射光线的方向。
]

#parec[
  Recall the normalization criterion from Equation (9.17), which stated that the set of visible microfacets (left hand side) occupy the same area as the underlying macrosurface (right hand side) when observed from given direction $omega$ with elevation angle $theta$ :
][
  回忆方程~(9.17)中的归一化准则，该准则指出当从给定方向 $omega$ 以仰角 $theta$ 观察时，可见微面（左侧）占据的面积与底层宏观表面（右侧）相同：
]

#parec[
  \_{^2} n , D(\_m) , G\_1() (0, \_m) , d\_m = .
][
  $
    integral_(cal(H)^2) n thin D (omega_m) thin G_1 (omega) max (0 , omega dot.op omega_m) thin d omega_m = cos theta .
  $
]

#parec[
  The probability of a ray interacting with a particular microfacet is directly proportional to its visible area; hence this equation can be seen to encapsulate the distribution that should be used.
][
  光线与特定微面交互的概率直接与其可见面积成正比；因此可以认为这个方程封装了应使用的分布。
]

#parec[
  Following division of both sides by $cos theta$, the integral on the left hand side equals one—in other words, it turns into a normalized density $D_omega (omega_m)$ that we shall refer to as the distribution of visible normals:
][
  通过将两边除以 $cos theta$，左侧的积分等于一——换句话说，它变成了一个归一化密度函数 $D_omega (omega_m)$，我们称之为可见法线的分布：
]

#parec[
  D\_{}(\_m) = D(\_m) (0, \_m).
][
  $ D_omega (omega_m) = frac(G_1 (omega), cos theta) D (omega_m) max (0 , omega dot.op omega_m) . $
]


#parec[
  It describes the projected area of forward-facing normals, where the first term involving the masking function specifies an $omega$ -dependent normalization factor. The method `D()` evaluates this density function.
][
  它描述了前向法线的投影面积，其中涉及遮罩函数的第一项指定了一个与 $omega$ 相关的归一化因子。方法 `D()` 用于评估这个密度函数。
]

#parec[
  `Float D(Vector3f w, Vector3f wm) const {     return G1(w) / AbsCosTheta(w) * D(wm) * AbsDot(w, wm); }`
][
  `Float D(Vector3f w, Vector3f wm) const {     return G1(w) / AbsCosTheta(w) * D(wm) * AbsDot(w, wm); }`
]

#parec[
  Two upcoming microfacet BSDFs will rely on the ability to sample microfacet normals $omega_(upright("normal"))$ according to this density. At this point, one would ordinarily apply the inversion method (Section #link("../Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#sec:inversion-method")[2.3];) to Equation (9.23) to build a sampling algorithm, but this leads to a relatively complex and approximate method: part of the problem is that the central inversion step lacks an analytic solution.
][
  即将推出的两个微面BRDF将依赖于根据这个密度采样微面法线 $omega_(upright("normal"))$ 的能力。在这一点上，通常会应用反演方法（第 #link("../Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#sec:inversion-method")[2.3] 节）到方程 (9.23) 来构建采样算法，但这导致了一个相对复杂和近似的方法：问题的一部分是中心反演步骤缺乏解析数学解。
]

#parec[
  We instead follow a simple geometric approach that exploits the definition of the microsurface in terms of an arrangement of many identical truncated spheres or ellipsoids.
][
  我们改用一种简单的几何方法，该方法利用微表面由许多相同的截断球体或椭球体排列而成的特性。
]

#parec[
  Before implementing the sampling routine, we will quickly take care of the method that returns the associated PDF, which is simply another name for the `D()` method.
][
  在实现采样程序之前，我们将快速处理返回相关概率密度函数的方法，这只是 `D()` 方法的另一个名称。
]

#parec[
  `Float PDF(Vector3f w, Vector3f wm) const { return D(w, wm); }`
][
  `Float PDF(Vector3f w, Vector3f wm) const { return D(w, wm); }`
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Reflection_Models/pha09f27.svg"),
    caption: [
      Figure 9.27
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Reflection_Models/pha09f27.svg"),
    caption: [
      图 9.27
    ],
  )
]


=== The Torrance-Sparrow Model
<the-torrancesparrow-model>

#parec[
  We can finally explain how the #link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[ConductorBxDF] handles rough microstructures via a BRDF model due to Torrance and Sparrow (1967). Instead of directly deriving their approach from first principles, we will instead explain how this model is sampled in `pbrt`, and then reverse-engineer the implied BRDF.
][
  我们终于可以解释#link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[ConductorBxDF];如何通过Torrance和Sparrow（1967）提出的BRDF模型处理粗糙的微观结构。我们将不直接从第一原理推导他们的方法，而是解释该模型在`pbrt`中的采样方式，然后逆向工程推导出隐含的BRDF。
]

#parec[
  Combined with the visible normal sampling approach, the sampling routine of this model consists of three physically intuitive steps:
][
  结合可见法线采样方法，该模型的采样过程由三个直观的物理步骤组成：
]

#parec[
  + Given a viewing ray from direction \$ #emph[{}\$, a microfacet normal
      \$ ];{}\$ is sampled from the visible normal distribution
    $D_(omega_(upright("normal o"))) (omega_(upright("normal m")))$. This
    step encapsulates the process of intersecting the viewing ray with the
    random microstructure.
][
  + 给定来自方向\$ #emph[{}$的 视 线 ， 从 可 见 法 线 分 布$D];{#emph[{}}
      (];{})$中 采 样 一 个 微 面 法 线$
    \_{}\$。这一步包含了视线与随机微观结构相交的过程。
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + Reflection from the sampled microfacet is modeled using the law of
      specular reflection and the Fresnel equations, which yields the
      incident direction \$ \_{}\$ and a reflection coefficient that
      attenuates the light carried by the path.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + 使用镜面反射定律和菲涅尔方程对采样的微面进行反射建模，得到入射方向\$
      \_{}\$和一个反射系数，该系数衰减路径携带的光。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + The scattered light is finally scaled by
      $G_1 (omega_(upright("normal i")))$ to account for the effect of
      masking by other microfacets.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 最后，散射光被$G_1 (omega_(upright("normal i")))$缩放，以考虑其他微面的遮挡效应。
  ]
]

#parec[
  Our goal will be to determine the BRDF that represents this sequence of steps. For this, we must first find the probability density of the sampled incident direction \$ #emph[{}\$. Although visible normal
    sampling was involved, it is important to note that \$ ];{}\$ is #emph[not] distributed according to the visible normal distribution—to find its density, we must consider the sequence of steps that were used to obtain \$ #emph[{}\$ from \$ ];{}\$.
][
  我们的目标是确定代表这一系列步骤的BRDF。为此，我们首先必须找到采样的入射方向\$ #emph[{}$的 概 率 密 度 。 尽 管 涉 及 可 见 法 线 采 样 ， 但 重 要 的 是 要 注 意$
  ];{} $并 不 是 按 照 可 见 法 线 分 布 分 布 的 dash.em dash.em 为 了 找 到 其 密 度 ， 我 们 必 须 考 虑 从$ #emph[{}$获 得$ ];{}\$的步骤序列。
]

#parec[
  Taking stock of the available information, we know that the probability density of \$ #emph[{}\$ is given by
    $D_(omega_(upright("normal o"))) (omega_(upright("normal m")))$, and
    that \$ ];{}\$ is obtained from \$ #emph[{}\$ and \$ ];{}\$ using the law of specular reflection—that is,
][
  根据现有信息，我们知道\$ #emph[{}$的 概 率 密 度 由$D];{#emph[{}}
    (];{}) $给 出 ， 并 且$ #emph[{}$是 通 过 镜 面 反 射 定 律 从$ ];{} $和$ \_{}\$获得的——即，
]

$
  omega_(upright("normal r")) = - omega_(upright("normal o")) + 2 ( omega_(upright("normal m")) dot.op omega_(upright("normal o")) ) omega_(upright("normal m"))
$


#parec[
  This reflection mapping also has an inverse: the normal responsible for a specific reflection can be determined via
][
  这种反射映射也有一个逆变换：可以通过以下公式确定特定反射的法线：
]

$
  omega_(upright("normal m")) = frac(omega_(upright("normal i")) + omega_(upright("normal o")), parallel omega_(upright("normal i")) + omega_(upright("normal o")) parallel)
$


#parec[
  which is known as the #emph[half-angle] or #emph[half-direction] transform, as it gives the unique direction vector that lies halfway between \$ #emph[{}\$ and \$ ];{}\$.
][
  这被称为#emph[半角];或#emph[半方向];变换，因为它给出了位于\$ #emph[{}$和$ ];{}\$之间的唯一方向向量。
]

=== The Half-Direction Transform
<the-half-direction-transform>


#parec[
  Transitioning between half- and incident directions is effectively a change of variables, and the Jacobian determinant \$ \$ of the associated mapping enables the conversion of probability densities between these two spaces. The determinant is simple to find in flatland, as shown in Figure 9.30(a). In the two-dimensional setting, the half-direction mapping simplifies to
][
  在半方向和入射方向之间转换实际上是变量的变化，相关映射的雅可比行列式\$ \$使得概率密度在这两个空间之间的转换成为可能。在平面中，这个行列式很容易找到，如图9.30(a)所示。在二维环境中，半方向映射简化为
]

#parec[
  $ theta_(upright("normal m")) = frac(theta_(upright("normal o")) + theta_(upright("normal i")), 2) $
][
  $ theta_(upright("normal m")) = frac(theta_(upright("normal o")) + theta_(upright("normal i")), 2) $
]

#parec[
  A slight perturbation of the incident angle \$ #emph[{}\$ (shaded green
    region) while keeping \$ ];{}\$ fixed requires a corresponding change to the microfacet angle \$ #emph[{}\$ (shaded blue region) to ensure that
    the law of specular reflection continues to hold. However, this
    perturbation to \$ ];{}\$ is smaller—half as small, to be precise—which directly follows from Equation (9.26). Indeed, the derivative of Equation (9.26) yields
][
  在保持\$ #emph[{}$固 定 的 同 时 ， 入 射 角$
  ];{} $的 微 小 扰 动 （ 阴 影 绿 色 区 域 ） 需 要 相 应 地 改 变 微 面 角 度$ #emph[{}$（ 阴 影 蓝 色 区 域 ） ， 以 确 保 镜 面 反 射 定 律 继 续 成 立 。 然 而 ， 这 种 对$
  ];{}\$的扰动较小——确切地说，小一半——这直接从方程(9.26)得出。实际上，方程(9.26)的导数为
]

#parec[
  $ frac(d theta_(upright("normal m")), d theta_(upright("normal i"))) = 1 / 2 $
][
  $ frac(d theta_(upright("normal m")), d theta_(upright("normal i"))) = 1 / 2 $
]

#parec[
  for the 2D case.
][
  对于二维情况。
]

#parec[
  The 3D case initially appears challenging due to the varied behavior shown in Figure 9.30(b-d). Fortunately, working with infinitesimal sets leads to a simple analytic expression that can be derived by expressing differential solid angles around \$ #emph[{}\$ and \$ ];{}\$ using spherical coordinates:
][
  由于图9.30(b-d)中显示的不同行为，三维情况最初看起来具有挑战性。幸运的是，处理无穷小集合可以推导出一个简单的解析表达式，可以通过使用球坐标表达\$ #emph[{}$和$ ];{}\$周围的微分立体角来推导。
]


#parec[
  $
    frac(d omega_m, d omega_i) = frac(sin theta_m thin d theta_m thin d phi.alt_m, sin theta_i thin d theta_i thin d phi.alt_i) .
  $
][
  $
    frac(d omega_m, d omega_i) = frac(sin theta_m thin d theta_m thin d phi.alt_m, sin theta_i thin d theta_i thin d phi.alt_i) .
  $
]

#parec[
  The expression can be simplified by noting that the law of specular reflection implies \$ \_i = 2 \_m \$ and \$ \_i = \_m \$ in a spherical coordinate system oriented around \$ \_o \$:
][
  注意到在围绕 \$ \_o \$ 的球坐标系中，镜面反射定律意味着 \$ \_i = 2 \_m \$ 和 \$ \_i = \_m \$，可以简化该表达式：
]


#parec[
  $ frac(f_r (p , omega_o , omega_i) L_i (p , omega_i) lr(|cos theta_i|), p (omega_i)) $ Modifying above equals $F (omega_o dot.op omega_m) G_1 (omega_i) L_i (p , omega_i)$.
][
  将上式修改为 $F (omega_o dot.op omega_m) G_1 (omega_i) L_i (p , omega_i)$。
]

#parec[
  We will simply solve this equation to obtain $f_r (p , omega_o , omega_i)$. Further substituting the PDF of the Torrance-Sparrow model from Equation~(9.28) yields the BRDF
][
  我们将简单地求解此方程以获得 $f_r (p , omega_o , omega_i)$，进一步从方程(9.28)中替换Torrance-Sparrow模型的PDF得到双向反射分布函数（BRDF）
]

#parec[
  $
    f_r ( p , omega_o , omega_i ) = frac(D_(omega_o) (omega_m) F (omega_o dot.op omega_m) G_1 (omega_i), 4 (omega_o dot.op omega_m) lr(|cos theta_i|))
  $
][
  $
    f_r ( p , omega_o , omega_i ) = frac(D_(omega_o) (omega_m) F (omega_o dot.op omega_m) G_1 (omega_i), 4 (omega_o dot.op omega_m) lr(|cos theta_i|))
  $
]

#parec[
  Inserting the definition of the visible normal distribution from Equation~(9.23) and assuming directions in the positive hemisphere results in the common form of the Torrance-Sparrow BRDF:
][
  插入从方程(9.23)中定义的可见法线分布，并假设方向在正半球中，得到Torrance-Sparrow BRDF的常见形式：
]

#parec[
  $
    f_r ( p , omega_o , omega_i ) = frac(D (omega_m) F (omega_o dot.op omega_m) G_1 (omega_i) G_1 (omega_o), 4 cos theta_i cos theta_o)
  $
][
  $
    f_r ( p , omega_o , omega_i ) = frac(D (omega_m) F (omega_o dot.op omega_m) G_1 (omega_i) G_1 (omega_o), 4 cos theta_i cos theta_o)
  $
]

#parec[
  We will, however, make a small adjustment to the above expression: Section~9.6.3 introduced a more accurate bidirectional masking-shadowing factor $G$ that accounts for height correlations on the microstructure. We use it to replace the product of unidirectional $G_1$ factors:
][
  然而，我们将对上述表达式做一个小调整：第9.6.3节介绍了一种更准确的双向遮蔽-阴影因子 $G$，它考虑了微结构上的高度相关性。我们用它来替换单向 $G_1$ 因子的乘积：
]

#parec[
  $
    f_r ( p , omega_o , omega_i ) = frac(D (omega_m) F (omega_o dot.op omega_m) G (omega_i , omega_o), 4 cos theta_i cos theta_o)
  $
][
  $
    f_r ( p , omega_o , omega_i ) = frac(D (omega_m) F (omega_o dot.op omega_m) G (omega_i , omega_o), 4 cos theta_i cos theta_o)
  $
]

#parec[
  One of the nice things about the Torrance-Sparrow model is that the derivation does not depend on the particular microfacet distribution being used. Furthermore, it does not depend on a particular Fresnel function and can be used for both conductors and dielectrics. However, the relationship between $d omega_m$ and $d omega_o$ used in the derivation does depend on the assumption of specular reflection from microfacets, and the refractive variant of this model will require suitable modifications.
][
  Torrance-Sparrow模型的一个显著优点是其推导不依赖于所使用的特定微面分布。此外，它不依赖于特定的菲涅耳函数，可以用于导体和介电体。然而，推导过程中使用的 $d omega_m$ 和 $d omega_o$ 之间的关系确实依赖于微面镜面反射的假设，并且该模型的折射变体将需要适当的修改。
]

#parec[
  Evaluating the terms of the Torrance-Sparrow BRDF is straightforward.
][
  评估Torrance-Sparrow BRDF的项是直接的。
]

#parec[
  $
    upright("<<Evaluate rough conductor BRDF>>") = upright("<<Compute cosines and ") omega_m upright(" for conductor BRDF>>") quad F l o a t c o s T h e t a_o = A b s C o s T h e t a ( w o ) , c o s T h e t a_i = A b s C o s T h e t a (w i) ; i f ( c o s T h e t a_i = = 0 lr(||) c o s T h e t a_o = = 0 ) r e t u r n ; V e c t o r 3 f w m = w i + w o ; i f ( L e n g t h S q u a r e d (w m) = = 0 ) r e t u r n ; w m = N o r m a l i z e (w m) ;
  $
][
  $
    upright("<<评估粗糙导体BRDF>>") = upright("<<计算余弦和") omega_m upright("用于导体BRDF>>") quad F l o a t c o s T h e t a_o = A b s C o s T h e t a ( w o ) , c o s T h e t a_i = A b s C o s T h e t a (w i) ; i f ( c o s T h e t a_i = = 0 lr(||) c o s T h e t a_o = = 0 ) r e t u r n ; V e c t o r 3 f w m = w i + w o ; i f ( L e n g t h S q u a r e d (w m) = = 0 ) r e t u r n ; w m = N o r m a l i z e (w m) ;
  $
]

#parec[
  Evaluating Fresnel factor $F$ for conductor BRDF: SampledSpectrum \$F = FrComplex(AbsDot(wo, wm), eta, k); return mfDistrib.D(wm) \* F \* mfDistrib.G(wo, wi) / (4 \* cosTheta\_i \* cosTheta\_o);
][
  评估导体BRDF的菲涅耳因子 $F$ ：SampledSpectrum \$F = FrComplex(AbsDot(wo, wm), eta, k); return mfDistrib.D(wm) \* F \* mfDistrib.G(wo, wi) / (4 \* cosTheta\_i \* cosTheta\_o);
]

#parec[
  Incident and outgoing directions at glancing angles need to be handled explicitly to avoid the generation of NaN values:
][
  入射和出射方向在掠射角时需要明确处理，以避免生成NaN值：
]

#parec[
  $
    upright("<<Compute cosines and ") omega_m upright(" for conductor BRDF>>") = upright("<<Compute cosines and ") omega_m upright(" for conductor BRDF>>") quad F l o a t c o s T h e t a_o = A b s C o s T h e t a ( w o ) , c o s T h e t a_i = A b s C o s T h e t a (w i) ; i f ( c o s T h e t a_i = = 0 lr(||) c o s T h e t a_o = = 0 ) r e t u r n ; V e c t o r 3 f w m = w i + w o ; i f ( L e n g t h S q u a r e d (w m) = = 0 ) r e t u r n ; w m = N o r m a l i z e (w m) ;
  $
][
  $
    upright("<<计算余弦和") omega_m upright("用于导体BRDF>>") = upright("<<计算余弦和") omega_m upright("用于导体BRDF>>") quad F l o a t c o s T h e t a_o = A b s C o s T h e t a ( w o ) , c o s T h e t a_i = A b s C o s T h e t a (w i) ; i f ( c o s T h e t a_i = = 0 lr(||) c o s T h e t a_o = = 0 ) r e t u r n ; V e c t o r 3 f w m = w i + w o ; i f ( L e n g t h S q u a r e d (w m) = = 0 ) r e t u r n ; w m = N o r m a l i z e (w m) ;
  $
]

#parec[
  Note that the Fresnel term is based on the angle of incidence relative to the microfacet (i.e., $omega_o dot.op omega_m$ ) rather than the macrosurface.
][
  注意，菲涅耳项是基于相对于微面的入射角（即 $omega_o dot.op omega_m$ ）而不是宏观表面。
]

#parec[
  The sampling procedure follows the sequence of steps outlined at the beginning of this subsection. It first uses $upright("Sample")_w m ()$ to find a microfacet orientation and reflects the outgoing direction about the microfacet's normal to find $omega_i$ before evaluating the BRDF and density function.
][
  采样过程遵循本小节开头概述的步骤顺序。它首先使用 $upright("Sample")_w m ()$ 找到一个微面朝向，并围绕微面的法线反射出射方向以找到 $omega_i$，然后评估BRDF和密度函数。
]

#parec[
  $
    upright("<<Sample rough conductor BRDF>>") = upright("<<Sample microfacet normal ") omega_m upright(" and reflected direction ") omega_i upright(">>") quad V e c t o r 3 f w m = m f D i s t r i b . S a m p l e_w m ( w o , u ) ; V e c t o r 3 f w i = R e f l e c t (w o , w m) ; i f (! S a m e H e m i s p h e r e (w o , w i)) r e t u r n ;
  $
][
  $
    upright("<<采样粗糙导体BRDF>>") = upright("<<采样微面法线") omega_m upright("和反射方向") omega_i upright(">>") quad V e c t o r 3 f w m = m f D i s t r i b . S a m p l e_w m ( w o , u ) ; V e c t o r 3 f w i = R e f l e c t (w o , w m) ; i f (! S a m e H e m i s p h e r e (w o , w i)) r e t u r n ;
  $
]

#parec[
  A curious situation arises when the sampled microfacet normal leads to a computed direction that lies below the macroscopic surface. In a real microstructure, this would mean that light travels deeper into a crevice, to be scattered a second or third time. However, the presented $upright("ConductorBxDF")$ only simulates a single interaction and thus marks such samples as invalid. This reveals one of the main flaws of the presented model: objects with significant roughness may appear too dark due to this lack of multiple scattering. Addressing issues related to energy loss is an active topic of research; see the "Further Reading" section for more information.
][
  当采样的微面法线导致计算出的方向位于宏观表面下方时，会出现一种奇怪的情况。在真实的微结构中，这意味着光线深入到裂缝中，进行第二次或第三次散射。然而，所展示的 $upright("ConductorBxDF")$ 仅模拟单次交互，因此将此类样本标记为无效。这揭示了所展示模型的主要缺陷之一：具有显著粗糙度的物体可能由于缺乏多次散射而显得过暗。解决与能量损失相关的问题是一个活跃的研究课题；有关更多信息，请参见“延伸阅读”部分。
]

#parec[
  Visible normal sampling is still a relatively new development: for several decades, microfacet models relied on sampling $omega_m$ directly proportional to the microfacet distribution, which tends to produce noisier renderings since some terms of the BRDF are not sampled exactly. Figure~9.31 compares this classical approach to what is now implemented in $upright("pbrt")$.
][
  可见法线采样仍然是一个相对较新的发展：几十年来，微面模型依赖于直接按微面分布采样 $omega_m$，这往往会产生更嘈杂的渲染，因为BRDF的某些项没有被精确采样。图9.31将这种经典方法与现在在 $upright("pbrt")$ 中实现的方法进行了比较。
]

#parec[
  Figure 9.31: Comparison of Microfacet Sampling Techniques. The ground plane under the spheres has a metal material modeled using the Torrance-Sparrow BRDF with a roughness of $alpha = 0.01$. Even with this relatively smooth microsurface, (a) sampling the full microfacet distribution $D (omega_m)$ gives visibly higher error from unusable samples taken from backfacing microfacets than (b) directly sampling the visible microfacet distribution $D_(omega_o) (omega_m)$.
][
  图9.31：微面采样技术比较。球体下的地面是使用Torrance-Sparrow BRDF建模的金属材料，粗糙度为 $alpha = 0.01$。即使在这种相对光滑的微表面上，(a) 对完整分布进行采样 $D (omega_m)$ 比(b) 直接采样可见的微面分布 $D_(omega_o) (omega_m)$ 产生的误差更高，因为从背面微面采样得来的样本不可用。
]
