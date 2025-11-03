#import "../template.typ": ez_caption, parec

== Scattering from Hair
<scattering-from-hair>


#parec[
  Human hair and animal fur can be modeled with a rough dielectric interface surrounding a pigmented translucent core. Reflectance at the interface is generally the same for all wavelengths and it is therefore wavelength-variation in the amount of light that is absorbed inside the hair that determines its color. While these scattering effects could be modeled using a combination of the #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`] and the volumetric scattering models from Chapters #link("../Volume_Scattering.html#chap:volume-scattering")[11] and #link("../Light_Transport_II_Volume_Rendering.html#chap:volume-integration")[14];, not only would doing so be computationally expensive, requiring ray tracing within the hair geometry, but importance sampling the resulting model would be difficult. Therefore, this section introduces a specialized BSDF for hair and fur that encapsulates these lower-level scattering processes into a model that can be efficiently evaluated and sampled.
][
  人类的头发和动物的毛皮可建模为围绕着有色半透明核心的粗糙介电界面。界面反射率在各波长范围内通常一致，因此，头发的颜色由光在头发内部被吸收的量的波长变化决定。尽管这些散射效应可通过结合#link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`]和第#link("../Volume_Scattering.html#chap:volume-scattering")[11]章、第#link("../Light_Transport_II_Volume_Rendering.html#chap:volume-integration")[14]章中的体积散射模型来实现，但这不仅计算成本高，需在头发几何体内进行光线追踪，而且对结果模型进行重要性采样亦十分困难。因此，本节引入一种专用于头发和毛皮的BSDF，该模型将这些底层散射过程封装成可高效评估和采样的结构。
]

#parec[
  See @fig:hair-vs-coated-diffuse for an example of the visual complexity of scattering in hair and a comparison to rendering using a conventional BRDF model with hair geometry.
][
  请参见@fig:hair-vs-coated-diffuse;，了解头发散射的视觉复杂性示例，以及使用常规BRDF模型与头发几何体渲染的比较。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f39.svg"),
  caption: [
    #ez_caption[
      Comparison of a BSDF that Models Hair to a Coated Diffuse BSDF. (a) Geometric model of hair rendered using a BSDF based on a diffuse base layer with a rough dielectric interface above it (Section #link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#sec:coated-bxdf-specializations")[14.3.3];). (b) Model rendered using the #link("<HairBxDF>")[`HairBxDF`] from this
      section. Because the #link("<HairBxDF>")[`HairBxDF`] is based on an accurate model of the hair microgeometry and also models light transmission through hair, it gives a much more realistic appearance. #emph[Hair geometry courtesy of Cem Yuksel.]
    ][
      模拟头发的BSDF与涂层漫反射BSDF的比较。(a)
      使用基于漫反射底层和其上粗糙介电界面的BSDF渲染的头发几何模型（第#link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#sec:coated-bxdf-specializations")[14.3.3];节）。(b) 使用本节中的#link("<HairBxDF>")[`HairBxDF`];渲染的模型。由于#link("<HairBxDF>")[`HairBxDF`];基于头发微观几何的准确模型，并且还模拟了光线通过头发的传输，因此它呈现出更为真实的外观。#emph[头发几何体由Cem
        Yuksel提供。

      ]
    ]
  ],
)<hair-vs-coated-diffuse>


=== 9.9.1 Geometry
<geometry>

#parec[
  Before discussing the mechanisms of light scattering from hair, we will start by defining a few ways of measuring incident and outgoing directions at ray intersection points on hair. In doing so, we will assume that the hair BSDF is used with the #link("../Shapes/Curves.html#Curve")[`Curve`] shape from Section #link("../Shapes/Curves.html#sec:curves")[6.7];, which allows us to make assumptions about the parameterization of the hair geometry. For the geometric discussion in this section, we will assume that the `Curve` variant corresponding to a flat ribbon that is always facing the incident ray is being used. However, in the BSDF model, we will interpret intersection points as if they were on the surface of the corresponding swept cylinder. If there is no interpenetration between hairs and if the hair's width is not much larger than a pixel's width, there is no harm in switching between these interpretations.
][
  在讨论头发的光散射机制之前，我们将首先定义几种在头发上的光线交点处测量入射和出射方向的方法。在此过程中，我们假设头发BSDF与第#link("../Shapes/Curves.html#sec:curves")[6.7];节中的#link("../Shapes/Curves.html#Curve")[`Curve`];形状一起使用，这使我们可以对头发几何的参数化做出假设。在本节的几何讨论中，我们将假设使用了始终面向入射光线的平带状`Curve`变体。然而，在BSDF模型中，我们将交点解释为位于相应扫掠圆柱体的表面上。如果头发之间没有相互穿透，并且头发的宽度不比像素宽度大得多，那么在这些解释之间切换是没有问题的。
]

#parec[
  Throughout the implementation of this scattering model, we will find it useful to separately consider scattering in the longitudinal plane, effectively using a side view of the curve, and scattering in the azimuthal plane, considering the curve head-on at a particular point along it. To understand these parameterizations, first recall that `Curve`s are parameterized such that the $u$ direction is along the length of the curve and $v$ spans its width. At a given $u$, all the possible surface normals of the curve are given by the surface normals of the circular cross-section at that point. All of these normals lie in a plane that is called the #emph[normal plane] (@fig:normal-plane;).
][
  在实现这个散射模型的过程中，我们会发现分别考虑纵向平面上的散射（有效地使用曲线的侧视图）和方位角平面上的散射（在曲线的特定点正视它）是有用的。为了理解这些参数化，首先回忆一下`Curve`的参数化方式是 $u$ 方向沿着曲线的长度， $v$ 跨越其宽度。在给定的 $u$ 处，曲线的所有可能的表面法线由该点的圆形截面的表面法线给出。所有这些法线都位于一个称为_法线平面_的平面内（@fig:normal-plane;）。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f40.svg"),
  caption: [
    #ez_caption[
      At any parametric point along a `Curve` shape, the cross-section of the curve is defined by a circle. All of the circle's surface normals (arrows) lie in a plane (dashed lines), dubbed the "normal plane."
    ][
      图9.40：在`Curve`形状的任何参数点上，曲线的截面由一个圆定义。所有圆的表面法线（箭头）都位于一个平面（虚线）内，称为“法线平面”。
    ]
  ],
)<normal-plane>


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f41.svg"),
  caption: [
    #ez_caption[ (a) Given a direction $omega$ at a point on a curve, the longitudinal angle $omega$ is defined by the angle between $omega$ and the normal plane at the point (thick line). The curve's tangent vector at the point is aligned with the $x$ axis in the BSDF coordinate system. (b) For a direction $omega$, the azimuthal angle $phi.alt$ is found by projecting the direction into the normal plane and computing its angle with the $y$ axis, which corresponds to the curve's $partial upright(p)\/partial v$ in the BSDF coordinate
      system.
    ][
      (a) 对于曲线上某一点给定的方向 $omega$，纵向角（longitudinal angle）$omega$ 定义为该方向与该点处法平面（normal plane）之间的夹角（图中粗线所示）。在 BSDF 坐标系中，曲线在该点的切向量与 $x$ 轴对齐。 (b) 对于一个方向 $omega$，方位角（azimuthal angle） $phi.alt$ 的求法是：先将该方向投影到法平面上，再计算该投影与 $y$ 轴之间的夹角；这里的 $y$ 轴对应于 BSDF 坐标系中曲线的 $partial upright(p)\/partial v$ 方向。
    ]
  ],
)<curve-parameterization>


#parec[
  We will find it useful to represent directions at a ray-curve intersection point with respect to coordinates $(theta, phi.alt)$ that are defined with respect to the normal plane at the $u$ position where the ray intersected the curve. The angle $theta$ is the #emph[longitudinal angle];, which is the offset of the ray with respect to the normal plane (@fig:curve-parameterization;(a)); $theta$ ranges from $- pi \/ 2$ to $pi \/ 2$, where $pi \/ 2$ corresponds to a direction aligned with $partial upright(p)\/partial u$ and $- pi \/ 2$ corresponds to $- partial upright(p) \/ partial u$. As explained in Section #link("../Reflection_Models/BSDF_Representation.html#sec:bsdf-geom-and-conventions")[9.1.1];, in `pbrt`'s regular BSDF coordinate system, $partial upright(p)\/partial u$ is aligned with the $x$ axis, so given a direction in the BSDF coordinate system, we have $sin (theta) = omega_x$, since the normal plane is perpendicular to$partial upright(p)\/partial u$.
][
  我们将发现，用坐标$(theta, phi.alt)$ 来表示射线与曲线相交点处的方向是很有用的。该坐标系是相对于射线与曲线相交处的 $u$ 位置对应的法平面（normal plane）定义的。
  角度 $theta$ 是纵向角（longitudinal angle），它表示射线相对于法平面的偏离程度（见图 @fig:curve-parameterization;(a)）。 $theta$的取值范围为$- pi \/ 2$ 到 $pi \/ 2$，其中$pi \/ 2$ 表示方向与 $partial upright(p)\/partial u$ 对齐，而 $- pi \/ 2$ 表示方向与 $- partial upright(p)\/partial u$对齐。
  如第9.1.1 节 所述，在 `pbrt` 的标准 BSDF 坐标系中，$partial upright(p)\/partial u$ 与 (x) 轴对齐，因此，对于给定的 BSDF 坐标系中的方向，有： $sin (theta) = omega_x$
  因为法平面与 $partial upright(p)\/partial u$ 垂直。

]

#parec[
  In the BSDF coordinate system, the normal plane is spanned by the $y$ and $z$ coordinate axes. ( $y$ corresponds to $partial upright(p)\/partial v$ for curves, which is always perpendicular to the curve's $partial upright(p)\/partial u$, and $z$ is aligned with the ribbon normal.) The #emph[azimuthal angle] $theta$ is found by projecting a direction $theta$ into the normal plane and computing its angle with the $y$ axis. It thus ranges from $0$ to $2 pi$ (@fig:curve-parameterization;(b)).
][
  在BSDF坐标系中，法线平面由 $y$ 和 $z$ 坐标轴张成。（ $y$ 对应于曲线的$partial upright(p)\/partial u$， 它始终垂直于曲线的$partial upright(p)\/partial u$， 而$z$与带状法线对齐。）#emph[方位角] $phi.alt$ 通过将方向 $omega$ 投影到法线平面并计算其与$y$轴的角度来找到。它的范围是从 $0$ 到 $2 pi$ （@fig:curve-parameterization;(b)）。
]

#parec[
  One more measurement with respect to the curve will be useful in the following. Consider incident rays with some direction $omega$: at any given parametric $u$ value, all such rays that intersect the curve can only possibly intersect one half of the circle swept along the curve (@fig:curve-h-gamma). We will parameterize the circle's diameter with the variable $h$, where $h = plus.minus 1$ corresponds to the ray grazing the edge of the circle, and $h = 0$ corresponds to hitting it edge-on. Because `pbrt` parameterizes curves with $v in [0 , 1]$ across the curve, we can compute $h = - 1 + 2 v$.
][
  在接下来的内容中，我们还需要引入一个与曲线相关的额外测度。考虑具有某个方向 $omega$ 的入射光线：在任意给定的参数 $u$ 处，所有与曲线相交的此类光线，只可能与沿曲线扫掠出的圆的一半相交（见图 @fig:curve-h-gamma）。我们用变量 $h$ 来参数化该圆的直径，其中，当 $h = plus.minus 1$ 时，表示光线掠过圆的边缘；而当 $h = 0$ 时，表示光线正好从圆的中部（即侧面）穿过。  由于 `pbrt` 在曲线宽度方向上使用 $v in [0, 1]$ 进行参数化，因此我们可以计算  $h = -1 + 2v$。
]

#parec[
  Given the $h$ for a ray intersection, we can compute the angle between the surface normal of the inferred swept cylinder (which is by definition in the normal plane) and the direction $omega$, which we will denote by $gamma$. (Note: this is unrelated to the $gamma$ notation used for floating-point error bounds in Section #link("../Shapes/Managing_Rounding_Error.html#sec:fp-error")[6.8];.) See @fig:curve-h-gamma, which shows that $sin gamma = h$.
][
  给定射线相交点的 $h$ 值，我们可以计算出推导得到的扫掠圆柱面的法线（该法线按定义位于法平面内）与方向 $omega$ 之间的夹角，我们将其记作 $gamma$。  （注意：这与第 #link("../Shapes/Managing_Rounding_Error.html#sec:fp-error")[6.8] 节中用于浮点误差界限的符号 $gamma_n$ 无关。）参见图 @fig:curve-h-gamma，可知有 $sin gamma = h$。

]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f42.svg"),
  caption: [
    #ez_caption[
      Given an incident direction $omega$ of a ray that
      intersected a #link("../Shapes/Curves.html#Curve")[`Curve`]
      projected to the normal plane, we can parameterize the curve's width
      with $h in [- 1 , 1]$. Given the $h$ for a ray that has
      intersected the curve, trigonometry shows how to compute the angle
      $gamma$ between $omega$ and the surface normal on the curve's
      surface at the intersection point. The two angles $omega$ are
      equal, and because the circle's radius is 1, $sin(gamma) =
      h$.
    ][
      给定一条射线，在法线平面上与 #link("../Shapes/Curves.html#Curve")[`Curve`] 投影相交时的入射方向角 $omega$，我们可以用参数 $h \in [-1, 1]$ 来表示曲线的宽度。当射线与曲线相交时，已知对应的 $h$ 值，利用三角关系可以计算出入射方向 $omega$ 与曲面法线在交点处形成的角度 $gamma$。这两个角度 $omega$ 是相等的，并且由于圆的半径为 1，有 $sin(gamma) = h.$
    ]
  ],
)<curve-h-gamma>

=== Scattering from Hair
<Scattering_from_Hair>

#parec[
  Geometric setting in hand, we will now turn to discuss the general scattering behaviors that give hair its distinctive appearance and some of the assumptions that we will make in the following.
][
  在几何设置确定之后，我们现在将讨论使头发具有独特的外观的一般光散射行为以及我们将在下文中做出的一些假设。
]

#parec[
  Hair and fur have three main components:
][
  头发和毛皮有三个主要组成部分：
]

#parec[
  - #emph[Cuticle:] The outer layer, which forms the boundary with air.
    The cuticle's surface is a nested series of scales at a slight angle
    to the hair surface.
][
  - #emph[毛鳞片：] 外层，与空气形成边界。毛鳞片的表面是一个嵌套的鳞片系列，与头发表面呈轻微角度。
]

#parec[
  - #emph[Cortex:] The next layer inside the cuticle. The cortex generally
    accounts for around 90% of hair's volume but less for fur. It is
    typically colored with pigments that mostly absorb light.
][
  - #emph[头发皮质层：]
    毛鳞片内的下一层。头发皮质层通常占头发体积的约90%，但在毛皮中较少。它通常被色素染色，主要吸收光线。
]

#parec[
  - #emph[Medulla:] The center core at the middle of the cortex. It is
    larger and more significant in thicker hair and fur. The medulla is
    also pigmented. Scattering from the medulla is much more significant
    than scattering from the medium in the cortex.
][
  - #emph[头发髓质：]
    头发皮质层中间的中心核心。在较厚的头发和毛皮中更大且更显著。头发髓质也被色素染色。来自头发髓质的散射比来自头发皮质层中的介质的散射更为显著。
]

#parec[
  For the following scattering model, we will make a few assumptions. (Approaches for relaxing some of them are discussed in the exercises at the end of this chapter.) First, we assume that the cuticle can be modeled as a rough dielectric cylinder with scales that are all angled at the same angle $alpha$ (effectively giving a nested series of cones; see Figure 9.43). We also treat the hair interior as a homogeneous medium that only absorbs light—scattering inside the hair is not modeled directly. (Chapters 11 and 14 have detailed discussion of light transport in participating media.)
][
  对于以下散射模型，我们将做出一些假设。（在本章末的练习中讨论了放宽其中一些假设的方法。）首先，我们假设毛鳞片可以被建模为一个粗糙的介电圆柱，其鳞片都以相同的角度 $alpha$ 倾斜（有效地形成一个嵌套的圆锥系列；见图9.43）。我们还将头发内部视为仅吸收光的均质介质——不直接建模头发内部的散射。（第11章和第14章详细讨论了参与介质中的光传输。）
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f43.svg"),
  caption: [
    #ez_caption[
      The surface of hair is formed by scales that deviate by a small angle  from the ideal cylinder. ($alpha$ is generally around ; the angle shown here is larger for illustrative purposes.)
    ][
      毛发的表面由鳞片状结构组成，这些鳞片相对于理想圆柱表面略微倾斜（$alpha$ 通常很小；此处所示的角度被放大，仅用于说明）。
    ]
  ],
)

#parec[
  We will also make the assumption that scattering can be modeled accurately by a BSDF—we model light as entering and exiting the hair at the same place. (A BSSRDF could certainly be used instead; the “Further Reading” section has pointers to work that has investigated that alternative.) Note that this assumption requires that the hair’s diameter be fairly small with respect to how quickly illumination changes over the surface; this assumption is generally fine in practice at typical viewing distances.
][
  我们还将作出一个假设：认为毛发中的散射可以被准确地用 BSDF 来建模——也就是说，光线在毛发中被视为在同一点进入并离开。（当然，也可以使用 BSSRDF；在“延伸阅读”部分中提供了研究这种替代方法的相关文献。）请注意，这一假设要求毛发的直径相对于光照在其表面上变化的尺度来说必须足够小；在典型的观看距离下，这一假设通常是合理的。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f44.svg"),
  caption: [
    #ez_caption[
      Incident light arriving at a hair can be scattered in a variety of ways.  $p = 0$ corresponds to light reflected from the surface of the cuticle. Light may also be transmitted through the hair and leave the other side: $p=1$. It may be transmitted into the hair and reflected back into it again before being transmitted back out: $p=2$, and so forth.
    ][
      射入毛发的光线可以以多种方式被散射。
      当 $p = 0$ 时，表示光线被毛鳞片表面反射；
      当 $p = 1$ 时，光线穿过毛发并从另一侧射出；
      当 $p = 2$ 时，光线先进入毛发内部，在内部被反射一次后再透射出来；
      依此类推，$p$ 表示光线在毛发内部经历的反射次数。
    ]
  ],
)<hair-r-tt-trt>
#parec[
  Incident light arriving at a hair may be scattered one or more times before leaving the hair; @fig:hair-r-tt-trt shows a few of the possible cases. We will use $p$ to denote the number of path segments it follows inside the hair before being scattered back out to air. We will sometimes refer to terms with a shorthand that describes the corresponding scattering events at the boundary: $p=0$ corresponds to $R$, for reflection, $p=1$ is $TT$, for two transmissions $p=2$ is $"TRT"$, $p=3$ is $"TRRT"$, and so forth.
][
  射入毛发的光线在离开前，可能会在毛发内部发生一次或多次散射；@fig:hair-r-tt-trt 展示了其中几种可能的情况。我们用 $p$ 来表示光线在离开毛发、重新回到空气中之前，在毛发内部经过的路径段数。有时，我们会使用一种简写形式来描述光线在毛发表面发生的散射事件类型： $p = 0$ 表示 $R$（Reflection，反射）；  $p = 1$ 表示 $"TT"$（两次透射）；  $p = 2$ 表示 $"TRT"$；  $p = 3$ 表示 $"TRRT"$；以此类推。
]

#parec[
  In the following, we will find it useful to consider these scattering modes separately and so will write the hair BSDF as a sum over terms $p$:
][
  接下来，我们将分别考虑这些不同的散射模式，因此可以将毛发的 BSDF 表示为对各个 $p$ 项的求和形式：
]

$
  f(omega_upright(o), omega_upright(i)) =sum_(p=0)^(oo) f_p (omega_upright(o),omega_upright(i))
$

#parec[
  To make the scattering model evaluation and sampling easier, many hair scattering models factor $f$ into terms where one depends only on the angles $theta$ and another on $phi.alt$, the difference between $phi.alt_upright(o)$ and $phi.alt_upright(i)$. This semi-separable model is given by:
][
  为了使散射模型的评估和采样更容易，许多头发散射模型将$f$分解为一个仅取决于角度$theta$的项，另一个取决于$phi.alt_upright(o)$和$phi.alt_upright(i)$之间的差值$phi.alt_upright(i)$。该半可分模型由下式给出：
]

$
  f_p (omega_upright(o), omega_upright(i)) =(M_p (theta_o, theta_i) A_p (omega_upright(o) ) N_p (phi.alt)) / (| cos theta_upright(i) |)
$

#parec[
  where we have a #emph[longitudinal scattering function] $M_p$, an #emph[attenuation function] $A_p$, and an #emph[azimuthal scattering
    function] $N_p$. #footnote[Other authors generally include $A_p$ in the
    $N_p$ term, though we find it more clear to keep
    them separate for the following exposition. Here we also use $f$ for the
    BSDF, which most hair scattering papers denote by $S$.] The division by $lr(|cos theta_i|)$ cancels out the corresponding factor in the reflection equation.
][
  在这里，我们有一个#emph[纵向散射函数] $M_p$，一个#emph[衰减函数] $A_p$，以及一个#emph[方位角散射函数] $N_p$。#footnote[Other authors generally include $A_p$ in the
    $N_p$ term, though we find it more clear to keep
    them separate for the following exposition. Here we also use $f$ for the
    BSDF, which most hair scattering papers denote by $S$.] 除以 $lr(|cos theta_i|)$ 抵消了反射方程中的相应因子。
]

#parec[
  In the following implementation, we will evaluate the first few terms of the sum in Equation (9.47) and then represent all higher-order terms with a single one. The `pMax` constant controls how many are evaluated before the switch-over.
][
  在接下来的实现中，我们将评估方程 (9.47) 的前几项，然后用一个单一项表示所有高阶项。`pMax` 常量控制在切换之前评估多少项。
]

```cpp
static constexpr int pMax = 3;
```


#parec[
  The model implemented in the `HairBxDF` is parameterized by six values:
][
  在 `HairBxDF` 中实现的模型由六个值参数化：
]

#parec[
  - `h`: the $[-1,1]$ offset along the curve width where the ray intersected
    the oriented ribbon.
][
  - `h`：沿曲线宽度的 $[-1,1]$ 偏移量，光线在此处与定向带相交。
]

#parec[
  - `eta`: the index of refraction of the interior of the hair (typically,
    1.55).
][
  - `eta`：头发内部的折射率（通常为 1.55）。
]

#parec[
  - `sigma_a`: the absorption coefficient of the hair interior, where
    distance is measured with respect to the hair cylinder's diameter.
    (The absorption coefficient is introduced in Section 11.1.1.)
][
  - `sigma_a`：头发内部的吸收系数，其中距离是相对于头发圆柱体的直径测量的。（吸收系数在第
    11.1.1 节中引入。）
]

#parec[
  - `beta_m`: the longitudinal roughness of the hair, mapped to the range
    $[0, 1]$.
][
  - `beta_m`：头发的纵向粗糙度，映射到范围 $[0, 1]$。
]

#parec[
  - `beta_n`: the azimuthal roughness, also mapped to $[0, 1]$.
][
  - `beta_n`：方位角粗糙度，也映射到 $[0, 1]$。
]

#parec[
  - `alpha`: the angle at which the small scales on the surface of hair
    are offset from the base cylinder, expressed in degrees (typically,
    2).
][
  - `alpha`：头发表面小尺度与基圆柱体偏离的角度，以度数表示（通常为 2）。
]

```cpp
<<HairBxDF Definition>>=
class HairBxDF {
  public:
    <<HairBxDF Public Methods>>
  private:
    <<HairBxDF Constants>>
    <<HairBxDF Private Methods>>
    <<HairBxDF Private Members>>
};
```


#parec[
  Beyond initializing corresponding member variables, the `HairBxDF` constructor performs some additional precomputation of values that will be useful for sampling and evaluation of the scattering model. The corresponding code will be added to the `<<HairBxDF constructor implementation>>` fragment in the following, closer to where the corresponding values are defined and used. Note that `alpha` is not stored in a member variable; it is used to compute a few derived quantities that will be, however.
][
  除了初始化相应的成员变量外，`HairBxDF` 构造函数还执行了一些额外的预计算，这些值将对散射模型的采样和评估非常有用。相应的代码将在接下来的 `<<HairBxDF constructor implementation>>` 片段中添加，靠近定义和使用相应值的地方。注意，`alpha` 不存储在成员变量中；它用于计算一些派生量，这些量将被存储。
]

```cpp
Float h, eta;
SampledSpectrum sigma_a;
Float beta_m, beta_n;
```


#parec[
  We will start with the method that evaluates the BSDF.
][
  我们将从评估 BSDF 的方法开始。
]

```cpp
<<HairBxDF Method Definitions>>=
SampledSpectrum HairBxDF::f(Vector3f wo, Vector3f wi,
                            TransportMode mode) const {
    <<Compute hair coordinate system terms related to wo>>
    <<Compute hair coordinate system terms related to wi>>
    <<Compute  for refracted ray>>
    <<Compute  for refracted ray>>
    <<Compute the transmittance T of a single path through the cylinder>>
    <<Evaluate hair BSDF>>
}
```

#parec[
  There are a few quantities related to the directions $omega_upright(o)$ and $omega_upright(i)$ that are needed for evaluating the hair scattering model—specifically, the sine and cosine of the angle $theta$ that each direction makes with the plane perpendicular to the curve, and the angle $phi.alt$ in the azimuthal coordinate system.
][
  有一些与方向 $omega_upright(o)$ 和 $omega_upright(i)$ 相关的量是评估头发散射模型所需的——具体来说，每个方向与垂直于曲线的平面所成角度 $theta$ 的正弦和余弦，以及方位角坐标系中的角度 $phi.alt$。
]

#parec[
  As explained in Section 9.9.1, $sin theta_o$ is given by the $x$ component of $omega_o$ in the BSDF coordinate system. Given $sin theta_o$, because $theta_o in [- pi / 2 , pi / 2]$, we know that $cos theta_o$ must be positive, and so we can compute $cos theta_o$ using the identity $sin^2 theta + cos^2 theta = 1$. The angle $phi.alt_o$ in the perpendicular plane can be computed with `std::atan`.
][
  如第 9.9.1 节所述， $sin theta_o$ 由 BSDF 坐标系中 $omega_o$ 的 $x$ 分量给出。给定 $sin theta_o$，因为 $theta_o in [- pi / 2 , pi / 2]$，我们知道 $cos theta_o$ 必须为正，因此我们可以使用恒等式 $sin^2 theta + cos^2 theta = 1$ 计算 $cos theta_o$。垂直平面中的角度 $phi.alt_o$ 可以用 `std::atan` 计算。
]

```cpp
Float sinTheta_o = wo.x;
Float cosTheta_o = SafeSqrt(1 - Sqr(sinTheta_o));
Float phi_o = std::atan2(wo.z, wo.y);
Float gamma_o = SafeASin(h);
```


#parec[
  Equivalent code computes these values for `wi`.
][
  等效代码计算这些值用于 `wi`。
]

```cpp
Float sinTheta_i = wi.x;
Float cosTheta_i = SafeSqrt(1 - Sqr(sinTheta_i));
Float phi_i = std::atan2(wi.z, wi.y);
```


#parec[
  With these values available, we will consider in turn the factors of the BSDF model— $M_p$, $A_p$, and $N_p$ —before returning to the completion of the `f()` method.
][
  有了这些值，我们将依次考虑 BSDF 模型的因素—— $M_p$， $A_p$ 和 $N_p$ ——然后返回到 `f()` 方法的完成。
]


#parec[
  $M_p$ defines the component of scattering related to the angles $theta$ —longitudinal scattering. Longitudinal scattering is responsible for the specular lobe along the length of hair, and the longitudinal roughness $beta_m$ controls the size of this highlight. Figure 9.45 shows hair geometry rendered with three different longitudinal scattering roughnesses.
][
  $M_p$ 定义了与角度 $theta$ 相关的散射分量——纵向散射。纵向散射决定了沿头发长度的镜面反射瓣的形成，纵向粗糙度 $beta_m$ 控制了镜面反射瓣的大小。图9.45展示了使用三种不同纵向散射粗糙度渲染的头发几何形状。
]

#parec[
  #box(image("../pbr-book-website/4ed/Reflection_Models/hair-betam-0.1.png")) - Hair model illuminated by a skylight environment map rendered with varying longitudinal roughness. 1. With a very low roughness, $beta_m = 0.1$, the hair appears too shiny—almost metallic. 2. With $beta_m = 0.25$, the highlight is similar to typical human hair. 3. At high roughness, $beta_m = 0.7$, the hair is unrealistically flat and diffuse. #emph[(Hair geometry courtesy of Cem
    Yuksel.)]
][
  #box(image("../pbr-book-website/4ed/Reflection_Models/hair-betam-0.1.png")) - 头发模型通过天光环境贴图照亮，渲染时使用不同的纵向粗糙度。 1. 当粗糙度非常低时， $beta_m = 0.1$，头发显得过于光亮——几乎呈现金属质感。 2. 当 $beta_m = 0.25$ 时，高光类似于典型的人类头发。 3. 在高粗糙度下， $beta_m = 0.7$，头发显得不真实地平坦和漫反射。 #emph[(头发几何形状由 Cem Yuksel 提供。)]
]

#parec[
  The mathematical details of the derivation of the scattering model are complex, so we will not include them here; as always, the "Further Reading" section has references to the details. The design goals of the model implemented here were that it be normalized (ensuring both energy conservation and no energy loss) and that it could be sampled directly. Although this model is not directly based on a physical model of how hair scatters light, it matches measured data well and has parametric control of roughness $v^dagger$.
][
  散射模型的推导数学细节较为复杂，因此我们在此不作详细介绍；一如既往，"进一步阅读"部分提供了详细的参考。这里实现的模型设计目标是其归一化（确保能量守恒且无能量损失），并且可以直接采样。虽然该模型并不是直接基于头发如何散射光的物理模型，但它与测量数据高度吻合，并具有粗糙度 $v^dagger$ 的参数控制。
]

#parec[
  The model is:
][
  该模型为：
]

$
  M_p (theta_o , theta_i) = frac(1, 2 v) sinh (1 / v) e^(- frac(sin theta_i sin theta_o, v)) I_0 ( frac(cos theta_o cos theta_i, v) ) ,
$
#parec[
  where $I_0$ is the modified Bessel function of the first kind and $v$ is the roughness variance. Figure 9.46 shows plots of $M_p$.
][
  其中 $I_0$ 是第一类修正贝塞尔函数， $v$ 是粗糙度方差。图9.46展示了 $M_p$ 的图形。
]

#parec[
  #box(image("../pbr-book-website/4ed/Reflection_Models/pha09f46.png")) - The shape of $M_p$ as a function of $theta_i$ for three values of $theta_o$. In all cases, a roughness variance of $v = 0.02$ was used. The peaks are slightly shifted from the perfect specular reflection directions (at $theta_i = 1$, $1.3$, and $1.4$, respectively). #emph[(After d'Eon et al.~(2011), Figure 4.)]
][
  #box(image("../pbr-book-website/4ed/Reflection_Models/pha09f46.png")) - $M_p$ 作为 $theta_i$ 的函数在三种 $theta_o$ 值下的形状。在所有情况下，使用的粗糙度方差为 $v = 0.02$。峰值略微偏离完美镜面反射方向（分别在 $theta_i = 1$ 、 $1.3$ 和 $1.4$ ）。 #emph[(根据 d'Eon 等人 (2011)，图4。)]
]

#parec[
  This model is not numerically stable for low roughness variance values, so our implementation uses a different approach for that case that operates on the logarithm of $I_0$ before taking an exponent at the end. The $v lt.eq 0.1$ test in the implementation below selects between the two formulations.
][
  该模型在低粗糙度方差值时数值不稳定，因此我们的实现对于这种情况采用了不同的方法，在最终取指数之前对 $I_0$ 的对数进行操作。下面的实现中 $v lt.eq 0.1$ 的测试选择了两种公式之间的切换。
]

```cpp
Float Mp(Float cosTheta_i, Float cosTheta_o, Float sinTheta_i,
         Float sinTheta_o, Float v) {
    Float a = cosTheta_i * cosTheta_o / v, b = sinTheta_i * sinTheta_o / v;
    Float mp = (v <= 0.1) ?
               (FastExp(LogI0(a) - b - 1 / v + 0.6931f +
                        std::log(1 / (2 * v)))) :
               (FastExp(-b) * I0(a)) / (std::sinh(1 / v) * 2 * v);
    return mp;
}
```

#parec[
  One challenge with this model is choosing a roughness $v$ to achieve a desired look. Here we have implemented a perceptually uniform mapping from roughness $beta_m in [0 , 1]$ to $v$ where a roughness of 0 is nearly perfectly smooth and 1 is extremely rough. Different roughness values are used for different values of $p$. For $p = 1$, roughness is reduced by an empirical factor that models the focusing of light due to refraction through the circular boundary of the hair. It is then increased for $p = 2$ and subsequent terms, which models the effect of light spreading out after multiple reflections at the rough cylinder boundary in the interior of the hair.
][
  该模型的一个挑战是选择粗糙度 $v$ 以实现所需的外观。这里我们实现了从粗糙度 $beta_m in [0 , 1]$ 到 $v$ 的感知上均匀的映射，其中粗糙度为0几乎完全光滑，1则极其粗糙。对于不同的 $p$ 值，使用不同的粗糙度值。对于 $p = 1$，粗糙度通过一个经验因子减少，该因子模拟了由于光通过头发的圆形边界的折射而产生的聚焦。然后对于 $p = 2$ 和后续项，粗糙度增加，模拟了光在头发内部粗糙圆柱边界经过多次反射后扩散的效果。
]

```cpp
v[0] = Sqr(0.726f * beta_m + 0.812f * Sqr(beta_m) + 3.7f * Pow<20>(beta_m));
v[1] = .25 * v[0];
v[2] = 4 * v[0];
for (int p = 3; p <= pMax; ++p)
    v[p] = v[2];
```


```cpp
Float v[pMax + 1];
```



=== 9.9.4 Absorption in Fibers
<absorption-in-fibers>
#parec[
  The ( A\_p ) factor describes how the incident light is affected by each of the scattering modes ( p ). It incorporates two effects: Fresnel reflection and transmission at the hair-air boundary and absorption of light that passes through the hair (for ( p \> 0 )). Figure #link("<fig:hair-sigma-a>")[9.47] has rendered images of hair with varying absorption coefficients, showing the effect of absorption. The ( A\_p ) function that we have implemented models all reflection and transmission at the hair boundary as perfect specular—a very different assumption than ( M\_p ) and ( N\_p ) (to come), which model glossy reflection and transmission. This assumption simplifies the implementation and gives reasonable results in practice (presumably in that the specular paths are, in a sense, averages over all the possible glossy paths).
][
  ( A\_p ) 因子描述了入射光如何受到每种散射模式 ( p ) 的影响。它包含两个效应：在头发-空气边界的菲涅耳反射和透射，以及通过头发的光的吸收（对于 ( p \> 0 )）。图 #link("<fig:hair-sigma-a>")[9.47] 显示了具有不同吸收系数的头发渲染图像，展示了吸收的效果。我们实现的 ( A\_p ) 函数将头发边界的所有反射和透射建模为完美镜面反射和透射——这与 ( M\_p ) 和 ( N\_p ) （即将介绍）建模的光泽反射和透射有很大不同。这种假设简化了实现，并在实践中产生了合理的结果（大概是因为镜面路径在某种意义上是所有可能的光泽路径的平均）。
]

#parec[
  #strong[Figure 9.47:] Hair Rendered with Various Absorption Coefficients. In all cases, ( #emph[m = 0.25 ) and ( #emph[n = 0.3 ).
      (a) ( ];{normal a} = (3.35, 5.58, 10.96) ) (RGB coefficients): in black
    hair, almost all transmitted light is absorbed. The white specular
    highlight from the ( p = 0 ) term is the main visual feature. (b) (
  ];{normal a} = (0.84, 1.39, 2.74) )，giving brown hair, where the ( p \> 1 ) terms all introduce color to the hair. (c) With a very low absorption coefficient of ( \_{normal a} = (0.06, 0.10, 0.20) )，we have blonde hair. #emph[Hair geometry courtesy of Cem Yuksel.]
][
  #strong[图 9.47：] 使用不同吸收系数渲染的头发。在所有情况下，( #emph[m =
    0.25 ) 和 ( #emph[n = 0.3 )。 (a) ( ];{normal a} = (3.35, 5.58, 10.96) )
    （RGB 系数）：在黑色头发中，几乎所有透射的光都被吸收。来自 ( p = 0 )
    项的白色镜面高光是主要的视觉特征。 (b) ( ];{normal a} = (0.84, 1.39, 2.74) )，呈现棕色头发，其中 ( p \> 1 ) 项都为头发引入了颜色。 (c) 吸收系数非常低的 ( \_{normal a} = (0.06, 0.10, 0.20) )，我们得到金色头发。#emph[头发几何由 Cem Yuksel 提供。]
]

#parec[
  We will start by finding the fraction of incident light that remains after a path of a single transmitted segment through the hair. To do so, we need to find the distance the ray travels until it exits the cylinder; the easiest way to do this is to compute the distances in the longitudinal and azimuthal projections separately.
][
  我们将首先找出经过头发的单个透射段路径后剩余的入射光的比例。为此，我们需要找出光线在离开圆柱体之前行进的距离；最简单的方法是分别计算纵向和方位投影中的距离。
]

#parec[
  To compute these distances, we need the transmitted angles of the ray ( \_o ), in the longitudinal and azimuthal planes, which we will denote by ( \_t ) and ( \_t ), respectively. Application of Snell's law using the hair's index of refraction ( ) allows us to compute ( \_t ) and ( \_t ).
][
  为了计算这些距离，我们需要光线 ( \_o ) 在纵向和平面中的透射角度 ( \_t ) 和 ( \_t )。使用头发的折射率 ( ) 应用斯涅尔定律可以计算 ( \_t ) 和 ( \_t )。
]

#parec[
  \*\*Compute ( \_t ) for refracted ray:\*\*
][
  \*\*计算折射光线的 ( \_t )：\*\*
]

```c
Float sinTheta_t = sinTheta_o / eta;
Float cosTheta_t = SafeSqrt(1 - Sqr(sinTheta_t));
```


#parec[
  For ( \_t ), although we could compute the transmitted direction ( \_t ) from ( \_o ) and then project ( \_t ) into the normal plane, it is possible to compute ( \_t ) directly using a #emph[modified index of
    refraction] that accounts for the effect of the longitudinal angle on the refracted direction in the normal plane. The modified index of refraction is given by
][
  对于 ( \_t )，虽然我们可以从 ( \_o ) 计算透射方向 ( \_t )，然后将 ( \_t ) 投影到法平面，但可以使用修正的折射率直接计算 ( \_t )，该折射率考虑了纵向角度对法平面中折射方向的影响。修正的折射率为
]

$ eta prime = frac(sqrt(eta^2 - sin^2 theta_o), cos theta_o) . $



#parec[
  Given ( ' ), we can compute the refracted direction ( \_t ) directly in the normal plane. Since ( h = \_o ), we can apply Snell's law to compute ( \_t ).
][
  给定 ( ' )，我们可以直接在法平面中计算折射方向 ( \_t )。由于 ( h = \_o )，我们可以应用斯涅尔定律来计算 ( \_t )。
]


```cpp
Float etap = SafeSqrt(Sqr(eta) - Sqr(sinTheta_o)) / cosTheta_o;
Float sinGamma_t = h / etap;
Float cosGamma_t = SafeSqrt(1 - Sqr(sinGamma_t));
Float gamma_t = SafeASin(sinGamma_t);
```


#parec[
  #strong[Figure 9.48:] Computing the Transmitted Segment's Distance. For a transmitted ray with angle ( \_t ) with respect to the circle's surface normal, half of the total distance ( l\_a ) is given by ( ), assuming a unit radius. Because ( \_t ) is the same at both halves of the segment, ( l\_a = 2 \_t ).
][
  #strong[图 9.48：] 计算透射段的距离。对于与圆的表面法线成角度 ( \_t ) 的透射光线，总距离 ( l\_a ) 的一半由 ( ) 给出，假设单位半径。因为 ( \_t ) 在段的两半部分是相同的，所以 ( l\_a = 2 \_t )。
]

#parec[
  If we consider the azimuthal projection of the transmitted ray in the normal plane, we can see that the segment makes the same angle ( \_t ) with the circle normal at both of its endpoints (Figure #link("<fig:circle-la-derive>")[9.48];). If we denote the total length of the segment by ( l\_a ), then basic trigonometry tells us that ( = \_t ), assuming a unit radius circle.
][
  如果我们考虑在法平面中透射光线的方位投影，我们可以看到段在其两个端点与圆法线成相同的角度 ( \_t )（图 #link("<fig:circle-la-derive>")[9.48];）。如果我们将段的总长度表示为 ( l\_a )，那么根据基本的三角学，我们可以得出 ( = \_t )，假设单位半径圆。
]

#parec[
  #strong[Figure 9.49:] The Effect of ( \_t ) on the Transmitted Segment's Length. The length of the transmitted segment through the cylinder is increased by a factor of ( ) versus a direct vertical path.
][
  #strong[图 9.49：] ( \_t ) 对透射段长度的影响。透射段通过圆柱体的长度比直接垂直路径增加了 ( ) 倍。
]

#parec[
  Now considering the longitudinal projection, we can see that the distance that a transmitted ray travels before exiting is scaled by a factor of ( ) as it passes through the cylinder (Figure #link("<fig:cylinder-thetat>")[9.49];). Putting these together, the total segment length in terms of the hair diameter is
][
  现在考虑纵向投影，我们可以看到透射光线在离开之前行进的距离随着它通过圆柱体而被缩放了一个 ( ) 的因子（图 #link("<fig:cylinder-thetat>")[9.49];）。将这些结合起来，总段长度以头发直径表示为
]


#parec[
  Given the segment length and the medium's absorption coefficient, the fraction of light transmitted can be computed using Beer's law, which is introduced in Section #link("../Volume_Scattering/Transmittance.html#sec:transmittance")[11.2];. Because the `HairBxDF` defined $sigma_a$ to be measured with respect to the hair diameter (so that adjusting the hair geometry's width does not completely change its color), we do not consider the hair cylinder diameter when we apply Beer's law, and the fraction of light remaining at the end of the segment is given by
][
  给定段长和介质的吸收系数，可以使用比耳定律计算透射光的比例，该定律在#link("../Volume_Scattering/Transmittance.html#sec:transmittance")[11.2节];中介绍。因为`HairBxDF`定义 $sigma_a$ 是相对于头发直径测量的（这样调整头发几何宽度时不会完全改变其颜色），所以在应用比耳定律时我们不考虑头发圆柱的直径，段末剩余光的比例由下式给出：
]

$ l = frac(2 cos gamma_t, cos theta_t) . $



#parec[
  The transmittance $T_r$ is given by
][
  透射率 $T_r$ 由下式给出：
]

$ T_r = e^(- sigma_a l) . $


#parec[
  Compute the transmittance `T` of a single path through the cylinder:
][
  计算通过圆柱的单路径透射率`T`：
]

```cpp
SampledSpectrum T = Exp(-sigma_a * (2 * cosGamma_t / cosTheta_t));
```


#parec[
  Given a single segment's transmittance, we can now describe the function that evaluates the full $A_p$ function. `Ap()` returns an array with the values of $A_p$ up to $p_(m a x)$ and a final value that is the sum of attenuations for all the higher-order scattering terms.
][
  给定单段的透射率，我们现在可以描述完整 $A_p$ 函数的评估。`Ap()`返回一个数组，其中包含 $A_p$ 的值直到 $p_(m a x)$，以及一个最终值，该值是所有高阶散射项的衰减之和。
]

```cpp
pstd::array<SampledSpectrum, pMax + 1> Ap(Float cosTheta_o, Float eta, Float h, SampledSpectrum T) {
    pstd::array<SampledSpectrum, pMax + 1> ap;
    // Compute p = 0 attenuation at initial cylinder intersection
    Float cosGamma_o = SafeSqrt(1 - Sqr(h));
    Float cosTheta = cosTheta_o * cosGamma_o;
    Float f = FrDielectric(cosTheta, eta);
    ap[0] = SampledSpectrum(f);
    // Compute p = 1 attenuation term
    ap[1] = Sqr(1 - f) * T;
    // Compute attenuation terms up to p = pMax
    for (int p = 2; p < pMax; ++p)
        ap[p] = ap[p - 1] * T * f;
    // Compute attenuation term accounting for remaining orders of scattering
    if (1 - T * f)
        ap[pMax] = ap[pMax - 1] * f * T / (1 - T * f);
    return ap;
}
```


#parec[
  For the $A_0$ term, corresponding to light that reflects at the cuticle, the Fresnel reflectance at the air-hair boundary gives the fraction of light that is reflected. We can find the cosine of the angle between the surface normal and the direction vector with angles $theta_o$ and $gamma_o$ in the hair coordinate system by $cos theta_o cos gamma_o$.
][
  对于 $A_0$ 项，即在角质层反射的光，空气-头发边界处的菲涅耳反射率给出了反射光的比例。我们可以通过头发坐标系中的角度 $theta_o$ 和 $gamma_o$ 找到表面法线与方向向量之间角度的余弦，即 $cos theta_o cos gamma_o$。
]

#parec[
  Compute $p = 0$ attenuation at initial cylinder intersection:
][
  计算初始圆柱交点处的 $p = 0$ 的衰减：
]

```cpp
Float cosGamma_o = SafeSqrt(1 - Sqr(h));
Float cosTheta = cosTheta_o * cosGamma_o;
Float f = FrDielectric(cosTheta, eta);
ap[0] = SampledSpectrum(f);
```


#parec[
  For the $T$ term, $p = 1$, we have two $1 - f$ factors, accounting for transmission into and out of the cuticle boundary, and a single $T$ factor for one transmission path through the hair.
][
  对于 $T$ 项， $p = 1$，我们有两个 $1 - f$ 因子，分别对应进入和离开角质层边界的透射，以及一个对应于通过头发的单个透射路径的 $T$ 因子。
]

#parec[
  Compute $p = 1$ attenuation term:
][
  计算 $p = 1$ 衰减项：
]

```cpp
ap[1] = Sqr(1 - f) * T;
```


#parec[
  The $p = 2$ term has one more reflection event, reflecting light back into the hair, and then a second transmission term. Since we assume perfect specular reflection at the cuticle boundary, both segments inside the hair make the same angle $gamma_t$ with the circle's normal (Figure #link("<fig:hair-gammat-same>")[9.50];). From this, we can see that both segments must have the same length (and so forth for subsequent segments). In general, for $p > 0$,
][
  $p = 2$ 项有一个额外的反射事件，将光反射回头发中，然后是第二个透射项。由于我们假设在角质层边界处的完全镜面反射，头发内的两个段与圆的法线形成相同的角度 $gamma_t$ （图#link("<fig:hair-gammat-same>")[9.50];）。由此可见，两个段必须具有相同的长度（后续段也是如此）。一般来说，对于 $p > 0$，
]

$ A_p = A_(p - 1) T f = (1 - f)^2 T^p f^(p - 1) . $


#parec[
  Compute attenuation terms up to $p = p_(m a x)$ :
][
  计算直到 $p = p_(m a x)$ 的衰减项：
]

```cpp
for (int p = 2; p < pMax; ++p)
    ap[p] = ap[p - 1] * T * f;
```


#parec[
  After `pMax`, a final term accounts for all further orders of scattering. The sum of the infinite series of remaining terms can fortunately be found in closed form, since both $T < 1$ and $f < 1$ :
][
  在`pMax`之后，最后一项考虑所有进一步的散射阶数。幸运的是，由于 $T < 1$ 且 $f < 1$，剩余项的无限级数之和可以用封闭形式表示：
]

$ sum_(p = p_(m a x))^oo (1 - f)^2 T^p f^(p - 1) = frac((1 - f)^2 T^(p_(m a x)) f^(p_(m a x) - 1), 1 - T f) . $



#parec[
  Compute attenuation term accounting for remaining orders of scattering:
][
  计算考虑剩余散射阶数的衰减项：
]

```cpp
if (1 - T * f)
    ap[pMax] = ap[pMax - 1] * f * T / (1 - T * f);
```



=== 9.9.5 Azimuthal Scattering
<azimuthal-scattering>

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f51.svg"),
  caption: [
    Figure 9.51
  ],
)


#parec[
  Figure 9.51: For specular reflection, with $p = 0$, the incident and reflected directions make the same angle $gamma_o$ with the surface normal. The net change in angle is thus $- 2 gamma_o$. For $p = 1$, the ray is deflected from $gamma_o$ to $gamma_t$ when it enters the cylinder and then correspondingly on the way out. We can also see that when the ray is transmitted again out of the circle, it makes an angle $gamma_o$ with the surface normal there. Adding up the angles, the net deflection is $2 gamma_t - 2 gamma_o + pi$.
][
  图 9.51：对于镜面反射，当 $p = 0$ 时，入射方向和反射方向与表面法线形成相同的角度 $gamma_o$。角度的净变化因此为 $- 2 gamma_o$。对于 $p = 1$，当光线进入圆柱时，从 $gamma_o$ 偏转到 $gamma_t$，然后在出射时相应偏转。我们还可以看到，当光线再次从圆圈传出时，它与那里的表面法线形成角度 $gamma_o$。将这些角度相加，净偏转为 $2 gamma_t - 2 gamma_o + pi$。
]

#parec[
  Finally, we will model the component of scattering dependent on the angle $phi.alt$. We will do this work entirely in the normal plane. The azimuthal scattering model is based on first computing a new azimuthal direction assuming perfect specular reflection and transmission and then defining a distribution of directions around this central direction, where increasing roughness gives a wider distribution. Therefore, we will first consider how an incident ray is deflected by specular reflection and transmission in the normal plane; Figure 9.51 illustrates the cases for the first two values of $p$.
][
  最后，我们将对依赖于角度 $phi.alt$ 的散射分量进行建模。我们将在法平面内完全进行这项工作。方位散射模型基于首先假设完美镜面反射和镜面透射来计算新的方位方向，然后围绕这个中心方向定义一个方向分布，其中增加的粗糙度导致更宽的分布。因此，我们将首先考虑入射光线在法平面内通过镜面反射和透射如何偏转；图 9.51 展示了前两个 $p$ 值的情况。
]

#parec[
  Following the reasoning from Figure 9.51, we can derive the function $Phi (p , h)$, which gives the net change in azimuthal direction:
][
  根据图 9.51 的推理，我们可以推导出函数 $Phi (p , h)$，它给出了方位方向的净变化：
]

$ Phi (p , h) = 2 p gamma_t - 2 gamma_o + p pi . $


#parec[
  (Recall that $gamma_o$ and $gamma_t$ are derived from $h$.) Figure 9.52 shows a plot of this function for $p = 1$.
][
  （回忆一下， $gamma_o$ 和 $gamma_t$ 是从 $h$ 推导出来的。）图 9.52 显示了该函数在 $p = 1$ 时的图。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f52.svg"),
  caption: [
    Figure 9.52
  ],
)


#parec[
  Figure 9.52: Plot of $Phi (p , h)$ for $p = 1$. As $h$ varies from $- 1$ to $1$, we can see that the range of orientations $phi.alt$ for the specularly transmitted ray varies rapidly. By examining the range of $phi.alt$ values, we can see that the possible transmitted directions cover roughly $2 / 3$ of all possible directions on the circle.
][
  图 9.52：\$ (p, h)\$ 在 $p = 1$ 时的图。随着 $h$ 从 $- 1$ 变化到 $1$，我们可以看到镜面透射光线的方位角范围变化迅速。通过检查 \$ \$ 值的范围，我们可以看到可能的透射方向大约覆盖了圆上所有可能方向的 $2 / 3$。
]

```cpp
Float Phi(int p, Float gamma_o, Float gamma_t) {
    return 2 * p * gamma_t - 2 * gamma_o + p * \pi;
}
```


#parec[
  Now that we know how to compute new angles in the normal plane after specular transmission and reflection, we need a way to represent surface roughness, so that a range of directions centered around the specular direction can contribute to scattering. The #emph[logistic distribution] provides a good option: it is a generally useful one for rendering, since it has a similar shape to the Gaussian, while also being normalized and integrable in closed form (unlike the Gaussian); see Section B.2.5 for more information.
][
  现在我们知道如何在镜面透射和反射后在法平面内计算新角度，我们需要一种方法来表示表面粗糙度，以便围绕镜面方向的方向范围可以贡献于散射。#emph[逻辑斯蒂分布];提供了一个很好的选择：它对于渲染通常是有用的，因为它具有类似于高斯的形状，同时也可以在闭合形式中归一化和积分（不像高斯）；更多信息请参见 B.2.5 节。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f53.svg"),
  caption: [
    Figure 9.53
  ],
)


#parec[
  Figure 9.53: Plots of the Trimmed Logistic Function over $[- pi , pi]$. The curve for $s = 0.5$ (blue line) is broad and flat, while at $s = 0.1$ (red line), the curve is peaked. Because the function is normalized, the peak at 0 generally does not have the value 1, unlike the Gaussian.
][
  图 9.53：截断逻辑斯蒂函数在 $[- pi , pi]$ 上的图。对于 $s = 0.5$ （蓝线），曲线宽而平坦，而在 $s = 0.1$ （红线）时，曲线呈尖峰状。由于该函数是归一化的，因此在 0 处的峰值通常不为 1，这与高斯分布不同。
]

#parec[
  In the following, we will find it useful to define a normalized logistic function over a range $[a , b]$ ; we will call this the #emph[trimmed
    logistic];, $l_t$.
][
  在接下来的内容中，我们将发现定义一个在范围 $[a , b]$ 上的归一化逻辑斯蒂函数是有用的；我们称之为#emph[截断逻辑斯蒂];， $l_t$。
]

$ l_t (x , s , [a , b]) = frac(l (x , s), integral_a^b l (x prime , s) thin d x prime) . $



#parec[
  Figure 9.53 shows plots of the trimmed logistic distribution for a few values of $s$.
][
  图 9.53 显示了几个 $s$ 值的截断逻辑斯蒂分布的图。
]

#parec[
  Now we have the pieces to be able to implement the azimuthal scattering distribution. The `Np()` function computes the $N_p$ term, finding the angular difference between $phi.alt$ and $Phi (p , h)$ and evaluating the azimuthal distribution with that angle.
][
  现在我们有了实现方位散射分布的要素。`Np()` 函数计算 $N_p$ 项，找到 $phi.alt$ 和 $Phi (p , h)$ 之间的角度差，并用该角度评估方位分布。
]

```cpp
Float Np(Float phi, int p, Float s, Float gamma_o, Float gamma_t) {
    Float dphi = phi - Phi(p, gamma_o, gamma_t);
    // Remap dphi to [-\pi, \pi]
    while (dphi > \pi) dphi -= 2 * \pi;
    while (dphi < -\pi) dphi += 2 * \pi;
    return TrimmedLogistic(dphi, s, -\pi, \pi);
}
```


#parec[
  The difference between $phi.alt$ and $Phi (p , h)$ may be outside the range we have defined the logistic over, $[- pi , pi]$, so we rotate around the circle as needed to get the value to the right range. Because `dphi` never gets too far out of range for the small $p$ used here, we use the simple approach of adding or subtracting $2 pi$ as needed.
][
  \$ \$ 和 $Phi (p , h)$ 之间的差异可能超出我们定义逻辑斯蒂的范围 $[- pi , pi]$，因此我们根据需要围绕圆旋转以将值调整到正确范围。由于在这里使用的小 $p$ 时，`dphi` 从未超出范围太远，我们采用简单的方法，根据需要加或减 $2 pi$。
]

```cpp
while (dphi > \pi) dphi -= 2 * \pi;
while (dphi < -\pi) dphi += 2 * \pi;
```

#parec[
  As with the longitudinal roughness, it is helpful to have a roughly perceptually linear mapping from azimuthal roughness $beta_n in [0 , 1]$ to the logistic scale factor $s$.
][
  与纵向粗糙度一样，具有从方位粗糙度 $beta_n in [0 , 1]$ 到逻辑斯蒂比例因子 $s$ 的感知上线性的映射是有帮助的。
]

```cpp
static const Float SqrtPiOver8 = 0.626657069f;
s = SqrtPiOver8 * (0.265f * beta_n + 1.194f * Sqr(beta_n) + 5.372f * Pow<22>(beta_n));
```


```cpp
Float s;
```


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f54.svg"),
  caption: [
    Figure 9.54
  ],
)


#parec[
  Figure 9.54: Polar plots of $N_p$ for $p = 1$, $theta_o$ aligned with the negative $x$ axis, and with a low roughness, $beta_n = 0.1$, for (blue) $h = - 0.5$ and (red) $h = 0.3$. We can see that $N_p$ varies rapidly over the width of the hair.
][
  图 9.54： $N_p$ 的极坐标图， $p = 1$， $theta_o$ 与负 $x$ 轴对齐，低粗糙度 $beta_n = 0.1$，对于（蓝色） $h = - 0.5$ 和（红色） $h = 0.3$。我们可以看到 $N_p$ 在头发宽度上迅速变化。
]

#parec[
  Figure 9.54 shows polar plots of azimuthal scattering for the $T_T$ term, $p = 1$, with a fairly low roughness. The scattering distributions for the two different points on the curve's width are quite different. Because we expect the hair width to be roughly pixel-sized, many rays per pixel are needed to resolve this variation well.
][
  图 9.54 显示了 $T_T$ 项的方位散射的极坐标图， $p = 1$，粗糙度相当低。曲线宽度上两个不同点的散射分布截然不同。由于我们预计头发宽度大致为像素大小，因此每个像素需要许多光线才能很好地解析这种变化。
]


#parec[
  We now have almost all the pieces we need to be able to evaluate the model. The last detail is to account for the effect of scales on the hair surface (recall Figure #link("<fig:hair-scales>")[9.43];). Suitable adjustments to $theta_o$ work well to model this characteristic of hair.
][
  我们现在几乎拥有评估模型所需的所有部分。最后一个细节是考虑鳞片对头发表面的影响（回忆图 #link("<fig:hair-scales>")[9.43];）。对 $theta_o$ 进行适当调整可以有效地模拟头发的这一特性。
]

#parec[
  For the $R$ term, adding the angle $2 alpha$ to $theta_o$ can model the effect of evaluating the hair scattering model with respect to the surface normal of a scale. We can then go ahead and evaluate $M_0$ with this modification to $theta_o$. For $T T$, we have to account for two transmission events through scales. Rotating by $alpha$ in the opposite direction approximately compensates.
][
  对于 $R$ 项，向 $theta_o$ 添加角度 $2 alpha$ 可以模拟相对于鳞片表面法线评估头发散射模型的效果。然后，我们可以继续使用对 $theta_o$ 的这种修改来评估 $M_0$。对于 $T T$，我们必须考虑通过鳞片的两次透射事件。向相反方向旋转 $alpha$ 大致可以补偿。
]

#parec[
  (Because the refraction angle is nonlinear with respect to changes in normal orientation, there is some error in this approximation, though the error is low for the typical case of small values of $alpha$.) $T R T$ has a reflection term inside the hair; a rotation by $- 4 alpha$ compensates for the overall effect.
][
  （因为折射角相对于法线方向变化是非线性的，这种近似存在一些误差，尽管对于 $alpha$ 值较小的典型情况，误差较低。） $T R T$ 在头发内部有一个反射项；旋转 $- 4 alpha$ 可以补偿整体效果。
]

#parec[
  The effects of these shifts are that the primary reflection lobe $R$ is offset to be above the perfect specular direction and the secondary $T R T$ lobe is shifted below it. Together, these lead to two distinct specular highlights of different colors, since $R$ is not affected by the hair's color, while $T R T$ picks up the hair color due to absorption.
][
  这些偏移的效果是主要反射瓣 $R$ 偏移到完美镜面方向之上，而次要的 $T R T$ 瓣则偏移到其下方。两者共同导致了呈现出不同颜色的镜面高光，因为 $R$ 不受头发颜色的影响，而 $T R T$ 由于吸收而拾取头发颜色。
]

#parec[
  This effect can be seen in human hair and is evident in the images in Figure #link("<fig:hair-vary-beta-m>")[9.45];, for example.
][
  这种效果可以在人类头发中看到，并在图 #link("<fig:hair-vary-beta-m>")[9.45] 的图像中显而易见。
]

#parec[
  Because we only need the sine and cosine of the angle $theta_i$ to evaluate $M_p$, we can use the trigonometric identities
][
  因为我们只需要角度 $theta_i$ 的正弦和余弦来评估 $M_p$，所以我们可以使用三角恒等式
]

$
  sin (theta_o plus.minus alpha) & = sin theta_o cos alpha plus.minus cos theta_o sin alpha \
  cos (theta_o plus.minus alpha) & = cos theta_o cos alpha minus.plus sin theta_o sin alpha
$


#parec[
  to efficiently compute the rotated angles without needing to evaluate any additional trigonometric functions. The #link("<HairBxDF>")[HairBxDF] constructor therefore precomputes $sin (2^k alpha)$ and $cos (2^k alpha)$ for $k = 0 , 1 , 2$.
][
  从而在不需要计算额外三角函数的情况下有效地计算旋转角度。因此，#link("<HairBxDF>")[HairBxDF] 构造函数预先计算了 $sin (2^k alpha)$ 和 $cos (2^k alpha)$，其中 $k = 0 , 1 , 2$。
]

#parec[
  These values can be computed particularly efficiently using trigonometric double angle identities: $cos (2 theta) = cos^2 (theta) - sin^2 (theta)$ and $sin (2 theta) = 2 cos (theta) sin (theta)$.
][
  这些值可以特别高效地使用三角双角恒等式计算： $cos (2 theta) = cos^2 (theta) - sin^2 (theta)$ 和 $sin (2 theta) = 2 cos (theta) sin (theta)$。
]

```cpp
sin2kAlpha[0] = std::sin(Radians(alpha));
cos2kAlpha[0] = SafeSqrt(1 - Sqr(sin2kAlpha[0]));
for (int i = 1; i < pMax; ++i) {
    sin2kAlpha[i] = 2 * cos2kAlpha[i - 1] * sin2kAlpha[i - 1];
    cos2kAlpha[i] = Sqr(cos2kAlpha[i - 1]) - Sqr(sin2kAlpha[i - 1]);
}
```


```cpp
Float sin2kAlpha[pMax], cos2kAlpha[pMax];
```

#parec[
  Evaluating the model is now mostly just a matter of calling functions that have already been defined and summing the individual terms $f_p$.
][
  现在评估模型主要只是调用已经定义的函数并对各个项 $f_p$ 求和。
]

```cpp
Float phi = phi_i - phi_o;
pstd::array<SampledSpectrum, pMax + 1> ap = Ap(cosTheta_o, eta, h, T);
SampledSpectrum fsum(0.);
for (int p = 0; p < pMax; ++p) {
    // Compute sine theta_{o} and cosine theta_{o} terms accounting for scales
    Float sinThetap_o, cosThetap_o;
    if (p == 0) {
        sinThetap_o = sinTheta_o * cos2kAlpha[1] - cosTheta_o * sin2kAlpha[1];
        cosThetap_o = cosTheta_o * cos2kAlpha[1] + sinTheta_o * sin2kAlpha[1];
    }
    // Handle remainder of p values for hair scale tilt
    else if (p == 1) {
        sinThetap_o = sinTheta_o * cos2kAlpha[0] + cosTheta_o * sin2kAlpha[0];
        cosThetap_o = cosTheta_o * cos2kAlpha[0] - sinTheta_o * sin2kAlpha[0];
    } else if (p == 2) {
        sinThetap_o = sinTheta_o * cos2kAlpha[2] + cosTheta_o * sin2kAlpha[2];
        cosThetap_o = cosTheta_o * cos2kAlpha[2] - sinTheta_o * sin2kAlpha[2];
    } else {
        sinThetap_o = sinTheta_o;
        cosThetap_o = cosTheta_o;
    }
    // Handle out-of-range cosine theta_{o} from scale adjustment
    cosThetap_o = std::abs(cosThetap_o);
    fsum += Mp(cosTheta_i, cosThetap_o, sinTheta_i, sinThetap_o, v[p]) *
            ap[p] * Np(phi, p, s, gamma_o, gamma_t);
}
// Compute contribution of remaining terms after pMax
fsum += Mp(cosTheta_i, cosTheta_o, sinTheta_i, sinTheta_o, v[pMax]) /
        (2 * Pi);
if (AbsCosTheta(wi) > 0)
    fsum /= AbsCosTheta(wi);
return fsum;
```


#parec[
  The rotations that account for the effect of scales are implemented using the trigonometric identities listed above. Here is the code for the $p = 0$ case, where $theta_o$ is rotated by $2 alpha$. The remaining cases follow the same structure. (The rotation is by $- alpha$ for $p = 1$ and by $- 4 alpha$ for $p = 2$.)
][
  考虑鳞片效果的旋转使用了上面列出的三角恒等式。以下是 $p = 0$ 情况的代码，其中 $theta_o$ 旋转了 $2 alpha$。其余情况遵循相同的结构。（对于 $p = 1$，旋转为 $- alpha$，对于 $p = 2$，旋转为 $- 4 alpha$。）
]

```cpp
// Compute sine theta_{o} and cosine theta_{o} terms accounting for scales
Float sinThetap_o, cosThetap_o;
if (p == 0) {
    sinThetap_o = sinTheta_o * cos2kAlpha[1] - cosTheta_o * sin2kAlpha[1];
    cosThetap_o = cosTheta_o * cos2kAlpha[1] + sinTheta_o * sin2kAlpha[1];
}
// Handle remainder of p values for hair scale tilt
else if (p == 1) {
    sinThetap_o = sinTheta_o * cos2kAlpha[0] + cosTheta_o * sin2kAlpha[0];
    cosThetap_o = cosTheta_o * cos2kAlpha[0] - sinTheta_o * sin2kAlpha[0];
} else if (p == 2) {
    sinThetap_o = sinTheta_o * cos2kAlpha[2] + cosTheta_o * sin2kAlpha[2];
    cosThetap_o = cosTheta_o * cos2kAlpha[2] - sinTheta_o * sin2kAlpha[2];
} else {
    sinThetap_o = sinTheta_o;
    cosThetap_o = cosTheta_o;
}
// Handle out-of-range cosine theta_{o} from scale adjustment
cosThetap_o = std::abs(cosThetap_o);
```



#parec[
  When $omega_i$ is nearly parallel with the hair, the scale adjustment may give a slightly negative value for $cos (theta_i)$ —effectively, in this case, it represents a $theta_i$ that is slightly greater than $pi / 2$, the maximum expected value of $theta$ in the hair coordinate system.
][
  当 $omega_i$ 几乎与头发平行时，鳞片调整可能会给出 $cos (theta_i)$ 的一个略微负值——实际上，在这种情况下，它表示一个略大于 $pi / 2$ 的 $theta_i$，这是头发坐标系中 $theta$ 的最大预期值。
]

#parec[
  This angle is equivalent to $pi - theta_i$, and $cos (pi - theta_i) = lr(|cos (theta_i)|)$, so we can easily handle that here.
][
  这个角度等于 $pi - theta_i$，而 $cos (pi - theta_i) = lr(|cos (theta_i)|)$，所以我们可以在这里轻松处理。
]

#parec[
  \\/\/ Handle out-of-range cosine theta\_{o} from scale adjustment cosThetap\_o = std::abs(cosThetap\_o);
][
  \\/\/ 处理由于鳞片调整导致的超出范围的余弦 theta\_{o} cosThetap\_o = std::abs(cosThetap\_o);
]

#parec[
  A final term accounts for all higher-order scattering inside the hair. We just use a uniform distribution $N (phi.alt) = frac(1, 2 pi)$ for the azimuthal distribution; this is a reasonable choice, as the direction offsets from $Phi (p , h)$ for $p gt.eq p_(m a x)$ generally have wide variation and the final $A_p$ term generally represents less than 15% of the overall scattering, so little error is introduced in the final result.
][
  最后一项考虑了头发内部的所有高阶散射。我们采用均匀分布 $N (phi.alt) = frac(1, 2 pi)$ 作为方位角分布；这是一个合理的选择，因为对于 $p gt.eq p_(m a x)$，从 $Phi (p , h)$ 的方向偏移通常具有较大的变化，并且最终的 $A_p$ 项通常占整体散射的不到 15%，因此在最终结果中引入的误差很小。
]

#parec[
  \\/\/ Compute contribution of remaining terms after pMax fsum += Mp(cosTheta\_i, cosTheta\_o, sinTheta\_i, sinTheta\_o, v\[pMax\]) / (2 \* Pi);
][
  \\/\/ 计算 pMax 之后剩余项的贡献 fsum += Mp(cosTheta\_i, cosTheta\_o, sinTheta\_i, sinTheta\_o, v\[pMax\]) / (2 \* Pi);
]


==== A Note on Reciprocity
<a-note-on-reciprocity>
#parec[
  Although we included reciprocity in the properties of physically valid BRDFs in Section~#link("../Radiometry,_Spectra,_and_Color/Surface_Reflection.html#sec:brdf")[4.3.1];, the model we have implemented in this section is, unfortunately, not reciprocal. An immediate issue is that the rotation for hair scales is applied only to \$ #emph[{ i} \$. However, there are more problems:
    first, all terms \$ p \> 0 \$ that involve transmission are not
    reciprocal since the transmission terms use values based on \$ ];{ t} \$, which itself only depends on \$ #emph[{ o} \$. Thus, if \$ ];{ o} \$ and \$ #emph[{ i} \$ are interchanged, a completely different \$ ];{ t} \$ is computed, which in turn leads to different \$ #emph[{ t} \$ and \$
  ];{ t} \$ values, which in turn give different values from the \$ A\_{p} \$ and \$ N\_{p} \$ functions. In practice, however, we have not observed artifacts in images from these shortcomings.
][
  尽管我们在第#link("../Radiometry,_Spectra,_and_Color/Surface_Reflection.html#sec:brdf")[4.3.1];节中将互惠性包含在物理有效的BRDF属性中，但我们在本节中实现的模型不具备互惠性。一个直接的问题是头发鳞片的旋转仅应用于 \$ #emph[{ i} \$。然而，还有更多问题：首先，所有涉及传输的 \$ p \> 0 \$
    项都不具备互惠性，因为传输项使用基于 \$ ];{ t} \$ 的值，而 \$ #emph[{ t}
    \$ 本身仅依赖于 \$ ];{ o} \$。因此，如果交换 \$ #emph[{ o} \$ 和 \$ ];{ i} \$，则会计算出一个完全不同的 \$ #emph[{ t} \$，这反过来会导致不同的
    \$ ];{ t} \$ 和 \$ #emph[{ t} \$ 值，进而从 \$ A];{p} \$ 和 \$ N\_{p} \$ 函数中得出不同的值。然而，在实践中，我们并未观察到这些缺陷在图像中产生伪影。
]

=== 9.9.7 Sampling
<sampling>
#parec[
  Being able to generate sampled directions and compute the PDF for sampling a given direction according to a distribution that is similar to the overall BSDF is critical for efficient rendering, especially at low roughnesses, where the hair BSDF varies rapidly as a function of direction. In the approach implemented here, samples are generated with a two-step process: first we choose a \$ p \$ term to sample according to a probability based on each term's \$ A\_{p} \$ function value, which gives its contribution to the overall scattering function. Then, we find a direction by sampling the corresponding \$ M\_{p} \$ and \$ N\_{p} \$ terms.
][
  能够生成采样方向并根据与整体BSDF相似的分布计算给定方向的PDF对于高效渲染至关重要，特别是在低粗糙度下，头发BSDF作为方向函数迅速变化。在此实现的方法中，样本通过两步过程生成：首先，我们根据每个项的 \$ A\_{p} \$ 函数值的概率选择一个 \$ p \$ 项进行采样，该值表示其对整体散射函数的贡献。然后，我们通过采样相应的 \$ M\_{p} \$ 和 \$ N\_{p} \$ 项找到一个方向。
]

#parec[
  Fortunately, both the \$ M\_{p} \$ and \$ N\_{p} \$ terms of the hair BSDF can be sampled perfectly, leaving us with a sampling scheme that exactly matches the PDF of the full BSDF.

  We will first define the `ApPDF()` method, which returns a discrete PDF with probabilities for sampling each term \$ A\_{p} \$ according to its contribution relative to all the \$ A\_{p} \$ terms, given \$ \_{ o} \$.
][
  幸运的是，头发BSDF的 \$ M\_{p} \$ 和 \$ N\_{p} \$ 项都可以完美采样，使我们拥有一个与完整BSDF的PDF完全匹配的采样方案。

  我们将首先定义 `ApPDF()` 方法，该方法返回一个离散PDF，其中包含根据所有 \$ A\_{p} \$ 项的相对贡献为每个 \$ A\_{p} \$ 项采样的概率，给定 \$ \_{ o} \$。
]

```cpp
pstd::array<Float, HairBxDF::pMax + 1>
HairBxDF::ApPDF(Float cosTheta_o) const {
    <<Initialize array of A_{p} values for cosTheta_o>>       Float sinTheta_o = SafeSqrt(1 - Sqr(cosTheta_o));
    <<Compute cosine theta_{\text{normal } t} for refracted ray>>          Float sinTheta_t = sinTheta_o / eta;
    Float cosTheta_t = SafeSqrt(1 - Sqr(sinTheta_t));
    <<Compute gamma_{\text{normal } t} for refracted ray>>          Float etap = SafeSqrt(Sqr(eta) - Sqr(sinTheta_o)) / cosTheta_o;
    Float sinGamma_t = h / etap;
    Float cosGamma_t = SafeSqrt(1 - Sqr(sinGamma_t));
    Float gamma_t = SafeASin(sinGamma_t);
    <<Compute the transmittance T of a single path through the cylinder>>          SampledSpectrum T = Exp(-sigma_a * (2 * cosGamma_t / cosTheta_t));
    pstd::array<SampledSpectrum, pMax + 1> ap = Ap(cosTheta_o, eta, h, T);
    <<Compute A_{p} PDF from individual A_{p} terms>>       pstd::array<Float, pMax + 1> apPDF;
    Float sumY = 0;
    for (const SampledSpectrum & as : ap)
        sumY += as.Average();
    for (int i = 0; i <= pMax; ++i)
        apPDF[i] = ap[i].Average() / sumY;
    return apPDF;
}
```


#parec[
  The method starts by computing the values of \$ A\_{p} \$ for `cosTheta_o`. We are able to reuse some previously defined fragments to make this task easier.
][
  该方法首先计算 `cosTheta_o` 的 \$ A\_{p} \$ 值。我们可以重用一些先前定义的片段来简化此任务。
]

```cpp
Float sinTheta_o = SafeSqrt(1 - Sqr(cosTheta_o));
<<Compute cosine theta_{\text{normal } t} for refracted ray>>   Float sinTheta_t = sinTheta_o / eta;
Float cosTheta_t = SafeSqrt(1 - Sqr(sinTheta_t));
<<Compute gamma_{\text{normal } t} for refracted ray>>   Float etap = SafeSqrt(Sqr(eta) - Sqr(sinTheta_o)) / cosTheta_o;
Float sinGamma_t = h / etap;
Float cosGamma_t = SafeSqrt(1 - Sqr(sinGamma_t));
Float gamma_t = SafeASin(sinGamma_t);
<<Compute the transmittance T of a single path through the cylinder>>   SampledSpectrum T = Exp(-sigma_a * (2 * cosGamma_t / cosTheta_t));
pstd::array<SampledSpectrum, pMax + 1> ap = Ap(cosTheta_o, eta, h, T);
```


#parec[
  Next, the spectral \$ A\_{p} \$ values are converted to scalars using their luminance and these values are normalized to make a proper PDF.
][
  接下来，光谱 \$ A\_{p} \$ 值通过其亮度转换为标量，并将这些值归一化以生成一个合适的PDF。
]

```cpp
pstd::array<Float, pMax + 1> apPDF;
Float sumY = 0;
for (const SampledSpectrum & as : ap)
    sumY += as.Average();
for (int i = 0; i <= pMax; ++i)
    apPDF[i] = ap[i].Average() / sumY;
```


#parec[
  With these preliminaries out of the way, we can now implement the `Sample_f()` method.
][
  完成这些准备工作后，我们现在可以实现 `Sample_f()` 方法。
]

```cpp
pstd::optional<BSDFSample>
HairBxDF::Sample_f(Vector3f wo, Float uc, Point2f u, TransportMode mode,
                   BxDFReflTransFlags sampleFlags) const {
    <<Compute hair coordinate system terms related to wo>>       Float sinTheta_o = wo.x;
    Float cosTheta_o = SafeSqrt(1 - Sqr(sinTheta_o));
    Float phi_o = std::atan2(wo.z, wo.y);
    Float gamma_o = SafeASin(h);
    <<Determine which term p to sample for hair scattering>>       pstd::array<Float, pMax + 1> apPDF = ApPDF(cosTheta_o);
    int p = SampleDiscrete(apPDF, uc, nullptr, & uc);
    <<Compute sine theta_{\text{normal } o} and cosine theta_{\text{normal } o} terms accounting for scales>>       Float sinThetap_o, cosThetap_o;
    if (p == 0) {
        sinThetap_o = sinTheta_o * cos2kAlpha[1] - cosTheta_o * sin2kAlpha[1];
        cosThetap_o = cosTheta_o * cos2kAlpha[1] + sinTheta_o * sin2kAlpha[1];
    }
    <<Handle remainder of p values for hair scale tilt>>          else if (p == 1) {
        sinThetap_o = sinTheta_o * cos2kAlpha[0] + cosTheta_o * sin2kAlpha[0];
        cosThetap_o = cosTheta_o * cos2kAlpha[0] - sinTheta_o * sin2kAlpha[0];
    } else if (p == 2) {
        sinThetap_o = sinTheta_o * cos2kAlpha[2] + cosTheta_o * sin2kAlpha[2];
        cosThetap_o = cosTheta_o * cos2kAlpha[2] - sinTheta_o * sin2kAlpha[2];
    } else {
        sinThetap_o = sinTheta_o;
        cosThetap_o = cosTheta_o;
    }
    <<Handle out-of-range cosine theta_{\text{normal } o} from scale adjustment>>          cosThetap_o = std::abs(cosThetap_o);
    <<Sample $ M_{p} $ to compute $ \theta_{\text{normal } i} $>>       Float cosTheta = 1 + v[p] * std::log(std::max<Float>(u[0], 1e-5) +
                                            (1 - u[0]) * FastExp(-2 / v[p]));
    Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
    Float cosPhi = std::cos(2 * \pi * u[1]);
    Float sinTheta_i = -cosTheta * sinThetap_o +
                           sinTheta * cosPhi * cosThetap_o;
    Float cosTheta_i = SafeSqrt(1 - Sqr(sinTheta_i));
    <<Sample $ N_{p} $ to compute normal $ \Delta \phi $>>       <<Compute gamma_{\text{normal } t} for refracted ray>>          Float etap = SafeSqrt(Sqr(eta) - Sqr(sinTheta_o)) / cosTheta_o;
    Float sinGamma_t = h / etap;
    Float cosGamma_t = SafeSqrt(1 - Sqr(sinGamma_t));
    Float gamma_t = SafeASin(sinGamma_t);
    Float dphi;
    if (p < pMax)
        dphi = Phi(p, gamma_o, gamma_t) + SampleTrimmedLogistic(uc, s, -\pi, \pi);
    else
        dphi = 2 * \pi * uc;
    <<Compute $ w_{i} $ from sampled hair scattering angles>>       Float phi_i = phi_o + dphi;
    Vector3f wi(sinTheta_i, cosTheta_i * std::cos(phi_i),
                cosTheta_i * std::sin(phi_i));
    <<Compute PDF for sampled hair scattering direction $ w_{i} $>>       Float pdf = 0;
    for (int p = 0; p < pMax; ++p) {
        <<Compute sine theta_{\text{normal } o} and cosine theta_{\text{normal } o} terms accounting for scales>>              Float sinThetap_o, cosThetap_o;
            if (p == 0) {
                sinThetap_o = sinTheta_o * cos2kAlpha[1] - cosTheta_o * sin2kAlpha[1];
                cosThetap_o = cosTheta_o * cos2kAlpha[1] + sinTheta_o * sin2kAlpha[1];
            }
            <<Handle remainder of p values for hair scale tilt>>                 else if (p == 1) {
                sinThetap_o = sinTheta_o * cos2kAlpha[0] + cosTheta_o * sin2kAlpha[0];
                cosThetap_o = cosTheta_o * cos2kAlpha[0] - sinTheta_o * sin2kAlpha[0];
            } else if (p == 2) {
                sinThetap_o = sinTheta_o * cos2kAlpha[2] + cosTheta_o * sin2kAlpha[2];
                cosThetap_o = cosTheta_o * cos2kAlpha[2] - sinTheta_o * sin2kAlpha[2];
            } else {
                sinThetap_o = sinTheta_o;
                cosThetap_o = cosTheta_o;
            }
            <<Handle out-of-range cosine theta_{\text{normal } o} from scale adjustment>>                 cosThetap_o = std::abs(cosThetap_o);
        <<Handle out-of-range cosine theta_{\text{normal } o} from scale adjustment>>              cosThetap_o = std::abs(cosThetap_o);
        pdf += Mp(cosTheta_i, cosThetap_o, sinTheta_i, sinThetap_o, v[p]) *
              apPDF[p] * Np(dphi, p, s, gamma_o, gamma_t);
    }
    pdf += Mp(cosTheta_i, cosTheta_o, sinTheta_i, sinTheta_o, v[pMax]) *
          apPDF[pMax] * (1 / (2 * \pi));
    return BSDFSample(f(wo, wi, mode), wi, pdf, Flags());
}
```


#parec[
  Given the PDF over \$ A\_{p} \$ terms, a call to #link("../Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] takes care of choosing one. Because we only need to generate one sample from the PDF's distribution, the work to compute an explicit CDF array (for example, by using #link("../Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[PiecewiseConstant1D];) is not worthwhile. Note that we take advantage of `SampleDiscrete()`'s optional capability of returning a fresh uniform random sample, overwriting the value in `uc`. This sample value will be used shortly for sampling \$ N\_{p} \$.
][
  给定 \$ A\_{p} \$ 项的PDF，调用 #link("../Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] 负责选择一个。因为我们只需要从PDF的分布中生成一个样本，所以计算显式CDF数组（例如，使用 #link("../Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[PiecewiseConstant1D];）的工作是不值得的。请注意，我们利用 `SampleDiscrete()` 的可选功能返回一个新的均匀随机样本，覆盖 `uc` 中的值。此样本值将很快用于采样 \$ N\_{p} \$。
]

```cpp
pstd::array<Float, pMax + 1> apPDF = ApPDF(cosTheta_o);
int p = SampleDiscrete(apPDF, uc, nullptr, & uc);
```



#parec[
  We can now sample the corresponding \$ M\_{p} \$ term given \$ #emph[{
    o} \$ to find \$ ];{ i} \$. The derivation of this sampling method is fairly involved, so we will include neither the derivation nor the implementation here. This fragment, \<\<Sample \$ M\_{p} \$ to compute \$ \_{ i} \$\>\>, consumes both of the sample values `u[0]` and `u[1]` and initializes variables `sinTheta_i` and `cosTheta_i` according to the sampled direction.
][
  我们现在可以给定 \$ #emph[{ o} \$ 采样相应的 \$ M];{p} \$ 项以找到 \$ #emph[{ i}
    \$。此采样方法的推导相当复杂，因此我们在此不包括推导和实现。此片段
    \<\<采样 \$ M];{p} \$ 以计算 \$ \_{ i} \$\>\>，消耗了两个样本值 `u[0]` 和 `u[1]`，并根据采样方向初始化变量 `sinTheta_i` 和 `cosTheta_i`。
]


```cpp
Float cosTheta = 1 + v[p] * std::log(std::max<Float>(u[0], 1e-5) +
                                     (1 - u[0]) * FastExp(-2 / v[p]));
Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
Float cosPhi = std::cos(2 * \pi * u[1]);
Float sinTheta_i = -cosTheta * sinThetap_o +
                    sinTheta * cosPhi * cosThetap_o;
Float cosTheta_i = SafeSqrt(1 - Sqr(sinTheta_i));
```

#parec[
  Next we will sample the azimuthal distribution \$ N\_{p} \$. For terms up to \$ p\_{} \$, we take a sample from the logistic distribution centered around the exit direction given by \$ (p, h) \$. For the last term, we sample from a uniform distribution.
][
  接下来我们将采样方位分布 \$ N\_{p} \$。对于到 \$ p\_{} \$ 的项，我们从以 \$ (p, h) \$ 给定的出口方向为中心的逻辑分布中采样。对于最后一项，我们从均匀分布中采样。
]

```cpp
<<Compute gamma_{\text{normal } t} for refracted ray>>   Float etap = SafeSqrt(Sqr(eta) - Sqr(sinTheta_o)) / cosTheta_o;
Float sinGamma_t = h / etap;
Float cosGamma_t = SafeSqrt(1 - Sqr(sinGamma_t));
Float gamma_t = SafeASin(sinGamma_t);
Float dphi;
if (p < pMax)
    dphi = Phi(p, gamma_o, gamma_t) + SampleTrimmedLogistic(uc, s, -\pi, \pi);
else
    dphi = 2 * \pi * uc;
```


#parec[
  Given \$ #emph[{ i} \$ and \$ ];{ i} \$, we can compute the sampled direction `wi`. The math is similar to that used in the #link("../Geometry_and_Transformations/Spherical_Geometry.html#SphericalDirection")[SphericalDirection()] function, but with two important differences. First, because here \$ \$ is measured with respect to the plane perpendicular to the cylinder rather than the cylinder axis, we need to compute \$ ( - ) = () \$ for the coordinate with respect to the cylinder axis instead of \$ () \$. Second, because the hair shading coordinate system's \$ (, ) \$ coordinates are oriented with respect to the plus x axis, the order of dimensions passed to the #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f] constructor is adjusted correspondingly, since the direction returned from `Sample_f()` should be in the BSDF coordinate system.
][
  给定 \$ #emph[{ i} \$ 和 \$ ];{ i} \$，我们可以计算采样方向 `wi`。数学与 #link("../Geometry_and_Transformations/Spherical_Geometry.html#SphericalDirection")[SphericalDirection()] 函数中使用的类似，但有两个重要区别。首先，因为这里 \$ \$ 是相对于圆柱体垂直平面测量的，而不是圆柱体轴，因此我们需要计算 \$ ( - ) \= () \$ 作为相对于圆柱体轴的坐标，而不是 \$ () \$。其次，因为头发着色坐标系的 \$ (, ) \$ 坐标是相对于正x轴定向的，所以传递给 #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f] 构造函数的维度顺序相应调整，因为从 `Sample_f()` 返回的方向应在BSDF坐标系中。
]


```cpp
Float phi_i = phi_o + dphi;
Vector3f wi(sinTheta_i, cosTheta_i * std::cos(phi_i),
            cosTheta_i * std::sin(phi_i));
```


#parec[
  Because we could sample directly from the \$ M\_{p} \$ and \$ N\_{p} \$ distributions, the overall PDF is
][
  因为我们可以直接从 \$ M\_{p} \$ 和 \$ N\_{p} \$ 分布中采样，整体PDF为
]


#parec[
  $ sum_(p = 0)^(p_(m a x)) M_p (theta_o , theta_i) tilde(A)_p (omega_o) N_p (phi.alt) , $ where $tilde(A)_p$ are the normalized PDF terms. Note that $theta_o$ must be shifted to account for hair scales when evaluating the PDF; this is done in the same way (and with the same code fragment) as with BSDF evaluation.
][
  $ sum_(p = 0)^(p_(m a x)) M_p (theta_o , theta_i) tilde(A)_p (omega_o) N_p (phi.alt) , $ 其中 $tilde(A)_p$ 是归一化的概率密度函数项。注意，在评估概率密度函数时，必须调整 $theta_o$ 以考虑头发的比例；这与 BSDF 评估的方式相同（并使用相同的代码片段）。
]


```cpp
Float pdf = 0;
for (int p = 0; p < pMax; ++p) {
    <<Compute sine \theta_o and cosine \theta_o terms accounting for scales>>&#160;       Float sinThetap_o, cosThetap_o;
       if (p == 0) {
           sinThetap_o = sinTheta_o * cos2kAlpha[1] - cosTheta_o * sin2kAlpha[1];
           cosThetap_o = cosTheta_o * cos2kAlpha[1] + sinTheta_o * sin2kAlpha[1];
       }
       <<Handle remainder of p values for hair scale tilt>>&#160;          else if (p == 1) {
              sinThetap_o = sinTheta_o * cos2kAlpha[0] + cosTheta_o * sin2kAlpha[0];
              cosThetap_o = cosTheta_o * cos2kAlpha[0] - sinTheta_o * sin2kAlpha[0];
          } else if (p == 2) {
              sinThetap_o = sinTheta_o * cos2kAlpha[2] + cosTheta_o * sin2kAlpha[2];
              cosThetap_o = cosTheta_o * cos2kAlpha[2] - sinTheta_o * sin2kAlpha[2];
          } else {
              sinThetap_o = sinTheta_o;
              cosThetap_o = cosTheta_o;
          }
       <<Handle out-of-range cosine \theta_o from scale adjustment>>&#160;          cosThetap_o = std::abs(cosThetap_o);
    <<Handle out-of-range cosine \theta_o from scale adjustment>>&#160;       cosThetap_o = std::abs(cosThetap_o);
    pdf += Mp(cosTheta_i, cosThetap_o, sinTheta_i, sinThetap_o, v[p]) *
           apPDF[p] * Np(dphi, p, s, gamma_o, gamma_t);
}
pdf += Mp(cosTheta_i, cosTheta_o, sinTheta_i, sinTheta_o, v[pMax]) *
       apPDF[pMax] * \left( \frac{1}{2 \pi} \right);
```


#parec[
  The `<tt>HairBxDF::PDF()</tt>` method performs the same computation and therefore the implementation is not included here.
][
  HairBxDF::PDF() 方法执行相同的计算，因此此处不包括实现。
]


