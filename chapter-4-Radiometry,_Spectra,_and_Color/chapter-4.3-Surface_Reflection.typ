#import "../template.typ": parec, ez_caption

== #ez_caption[Surface Reflection][表面反射]
<surface-reflection>
#parec[
  When light is incident on a surface, the surface scatters the light, reflecting some of it back into the environment. There are two main effects that need to be described to model this reflection: the spectral distribution of the reflected light and its directional distribution. For example, the skin of a lemon mostly absorbs light in the blue wavelengths but reflects most of the light in the red and green wavelengths. Therefore, when it is illuminated with white light, its color is yellow. It has much the same color no matter what direction it is being observed from, although for some directions a highlight—a brighter area that is more white than yellow—is visible. In contrast, the light reflected from a point in a mirror depends almost entirely on the viewing direction. At a fixed point on the mirror, as the viewing angle changes, the object that is reflected in the mirror changes accordingly.
][
  当光照射到一个表面时，表面会散射入射光，将部分光线反射回环境中。为了模拟这种反射，需要描述两个主要效果：反射光的光谱分布和方向分布。例如，柠檬的表皮主要吸收蓝色波长的光，但反射大部分红色和绿色波长的光。因此，当它被白光照射时，其颜色为黄色。无论从哪个方向观察，它的颜色几乎相同，尽管从某些方向看，会看到一个高光区域——一个更明亮、颜色更偏白而非偏黄的区域。相比之下，从镜子中的一点反射的光几乎完全取决于观察方向。在镜子上的一个固定点，当观察角度改变时，镜子中反射的物体也会相应改变。
]

#parec[
  Reflection from translucent surfaces is more complex; a variety of materials ranging from skin and leaves to wax and liquids exhibit #emph[subsurface light transport], where light that enters the surface at one point exits it some distance away. (Consider, for example, how shining a flashlight in one's mouth makes one's cheeks light up, as light that enters the inside of the cheeks passes through the skin and exits the face.)
][
  从半透明表面反射的光更为复杂；从皮肤和树叶到蜡和液体，各种材料表现出#emph[次表面光传输]，即光在一个点进入表面后在一定距离外离开。（例如，考虑用手电筒照射嘴巴时，脸颊会发光，因为进入脸颊内部的光穿过皮肤并从脸上出来。）
]

#parec[
  There are two abstractions for describing these mechanisms for light reflection: the BRDF and the BSSRDF, described in @the-brdf-and-the-btdf and @the-bssrdf , respectively. The BRDF describes surface reflection at a point neglecting the effect of subsurface light transport. For materials where this transport mechanism does not have a significant effect, this simplification introduces little error and makes the implementation of rendering algorithms much more efficient. The BSSRDF generalizes the BRDF and describes the more general setting of light reflection from translucent materials.
][
  描述这些光反射机制有两种抽象概念：BRDF 和 BSSRDF，分别在@the-brdf-and-the-btdf 和@the-bssrdf 中描述。BRDF 描述了忽略次表面光传输效应的某一点处的表面反射。对于这种传输机制影响不显著的材料，这种简化引入的误差很小，并使渲染算法的实现更加高效。BSSRDF 则是 BRDF 的推广，描述了从半透明材料反射光的更一般情况。
]

=== #ez_caption[The BRDF and the BTDF][BRDF 与 BTDF]
<the-brdf-and-the-btdf>
#parec[
  The #emph[bidirectional reflectance distribution function] (BRDF) gives a formalism for describing reflection from a surface. Consider the setting in @fig:brdf-setting: we would like to know how much radiance is leaving the surface in the direction $omega_(o)$ toward the viewer, $L_(o) (p , omega_(o))$, as a result of incident radiance along the direction $omega_(i) , L_(i) (p , omega_(i))$. (When considering light scattering at a surface location, `pbrt` uses the convention that $omega_(i)$ refers to the direction from which the quantity of interest (radiance in this case) arrives, rather than the direction from which the `Integrator` reached the surface.)
][
  #emph[双向反射分布函数]（BRDF）提供了一种描述表面反射的形式。考虑@fig:brdf-setting 中的情境：我们希望知道沿 $omega_(o)$ 方向离开表面、朝向观察者的辐亮度 $L_(o) (p , omega_(o))$ 是多少，这是由于沿 $omega_(i)$ 方向入射的辐亮度 $L_(i) (p , omega_(i))$ 造成的。（在考虑表面位置的光散射时，`pbrt` 采用的惯例是 $omega_(i)$ 指的是感兴趣的量（在这种情况下是辐亮度）到达的方向，而不是 `Integrator` 到达表面的方向。）
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f10.svg"),
  caption: [
    #ez_caption[ *The BRDF.* The bidirectional reflectance distribution
      function is a 4D function over pairs of directions $omega_(i)$ and
      $omega_(o)$ that describes how much incident light along $omega_(i)$ is scattered from the surface in the direction $omega_(o)$.
    ][ *BRDF。*双向反射分布函数是一个关于方向对 $omega_(i)$ 和 $omega_(o)$的四维函数，描述了沿 $omega_(i)$ 方向的入射光在 $omega_(o)$ 方向从表面散射的量。

    ]
  ],
) <brdf-setting>

#parec[
  If the direction $omega_(i)$ is considered as a differential cone of directions, the differential irradiance at $p$ is:
][
  如果将方向 $omega_(i)$ 视为一个微分方向锥，则在 $p$ 处的微分辐照度为：
]

$
  d E (p , omega_(i)) = L_(i) (p , omega_(i)) cos theta_(i) thin d omega_(i) .
$<differential-irradiance>

#parec[
  A differential amount of radiance will be reflected in the direction $omega_(o)$ due to this irradiance. Because of the linearity assumption from geometric optics, the reflected differential radiance is proportional to the irradiance
][
  由于这个辐照度，将会有微分量的辐亮度在方向 $omega_(o)$ 上反射。由于在几何光学中的线性假设，反射的微分辐亮度与辐照度成正比：
]

$
  d L_(o) (p , omega_(o)) prop d E (p , omega_(i)) .
$
#parec[
  The constant of proportionality defines the surface's BRDF $f_(r)$ for the particular pair of directions $omega_(i)$ and $omega_(o)$ :
][
  这一比例常数定义了特定方向对 $omega_(i)$ 和 $omega_(o)$ 的表面 BRDF $f_(r)$ ：
]

$
  f_(r) (
    upright(p), omega_(o), omega_(i)
  ) = frac(d L_(o) (upright(p) comma omega_(o)), d E(upright(p) comma omega_(i))) = frac(d L_(o) (upright(p) comma omega_(o)), L_(i) (upright(p) comma omega_(i)) cos theta_i thin d omega_(i)) .
$ <brdf>
#parec[
  The spectral BRDF is defined by using spectral radiance in place of radiance.
][
  光谱双向反射分布函数通过使用光谱辐亮度代替辐亮度来定义。
]

#parec[
  Physically based BRDFs have two important qualities:

  + #emph[Reciprocity:] For all pairs of directions $omega_(i)$ and $omega_(o)$, $f_(r) (upright(p), omega_(i), omega_(o)) = f_(r) (upright(p), omega_(o), omega_(i))$

  + #emph[Energy conservation:] The total energy of light reflected is less than or equal to the energy of incident light. For all directions $omega_(o)$, $
    integral_(cal(H)^2 (upright(bold(n)))) f_(r) (upright(p), omega_(o), omega') cos theta' thin d omega' lt.eq 1 .
  $
][
  基于物理的 BRDF 有两个重要特性：

  + #emph[互易原理：] 对于所有方向对 $omega_(i)$ 和 $omega_(o)$，$f_(r) (upright(p), omega_(i), omega_(o)) = f_(r) (upright(p), omega_(o), omega_(i))$。

  + #emph[能量守恒原则：]
    反射光的总能量小于或等于入射光的能量。对于所有方向$omega_(o)$，

  $
    integral_(cal(H)^2 (upright(bold(n)))) f_(r) (upright(p), omega_(o), omega') cos theta' thin d omega' lt.eq 1 .
  $
]

#parec[
  Note that the value of the BRDF for a pair of directions $omega_(i)$ and $omega_(o)$ is #emph[not] necessarily less than 1; it is only its integral that has this normalization constraint.
][
  注意，对于方向对 $omega_(i)$ 和 $omega_(o)$，BRDF 的值#emph[不]一定小于 1；只有其积分具有这种归一化约束。
]

#parec[
  Two quantities that are based on the BRDF will occasionally be useful. First, the #emph[hemispherical-directional reflectance] is a 2D function that gives the total reflection in a given direction due to constant illumination over the hemisphere, or, equivalently, the total reflection over the hemisphere due to light from a given direction.#footnote[The fact that these two quantities are equal is due to the reciprocity of reflection functions.] It is defined as
][
  基于 BRDF 的两个量偶尔会有用。首先，#emph[半球-方向反射率]是一个二维函数，给出在给定方向上的总反射，其入射照明在整个半球上恒定，或者等价地，由给定方向的光引起的半球上的总反射。#footnote[这两个量相等的事实是由于反射函数的互易性。] 它被定义为
]


$ rho_("hd") (omega_(o)) = integral_(cal(H)^2 (upright(bold(n)))) f_(r) (p , omega_(o) , omega_(i)) lr(|cos theta_i|) d omega_(i) . $
<rho-hd>

#parec[
  The #emph[hemispherical-hemispherical reflectance] of a BRDF, denoted by $rho_("hh")$, gives the fraction of incident light reflected by a surface when the incident light is the same from all directions. It is
][
  BRDF 的#emph[半球-半球反射率]，记作 $rho_("hh")$，表示当入射光均匀地从所有方向入射时，表面反射的入射光的比例。它是
]

$
  rho_("hh") = 1 / pi integral_(cal(H)^2 (upright(bold(n)))) integral_(cal(H)^2 (upright(bold(n)))) f_(r) (
    p , omega_(o) , omega_(i)
  ) lr(|cos theta_o cos theta_i|) d omega_(o) d omega_(i) .
$
<rho-hh>

#parec[
  A surface's #emph[bidirectional transmittance distribution function] (BTDF), which describes the distribution of transmitted light, can be defined in a manner similar to that for the BRDF. The BTDF is generally denoted by $f_(t) (p , omega_(o) , omega_(i))$, where $omega_(i)$ and $omega_(o) $ are in opposite hemispheres around $p$. Remarkably, the BTDF does not obey reciprocity as defined above; we will discuss this issue in detail in @non-symmetric-scattering-and-refraction.
][
  表面的#emph[双向透射分布函数]（BTDF）描述透射光的分布，可以类似于 BRDF 来定义。BTDF 通常表示为 $f_(t) (p , omega_(o) , omega_(i))$，其中 $omega_(i)$ 和 $omega_(o)$ 位于 $p$ 周围的相对半球中。值得注意的是，BTDF 不符合上述定义的互易性；我们将在@non-symmetric-scattering-and-refraction 中详细讨论这个问题。
]

#parec[
  For convenience in equations, we will denote the BRDF and BTDF when considered together as $f (p , omega_(o) , omega_(i)) $ ; we will call this the #emph[bidirectional scattering distribution function] (BSDF). @reflection-models is entirely devoted to describing a variety of BSDFs that are useful for rendering.
][
  为了方便方程表示，我们将 BRDF 和 BTDF 一起表示为 $f (p , omega_(o) , omega_(i)) $ ；我们称之为#emph[双向散射分布函数]（BSDF）。@reflection-models 完全致力于描述各种对渲染有用的 BSDF。
]

#parec[
  Using the definition of the BSDF, we have
][
  使用 BSDF 的定义，我们有
]

$ d L_(o) (p , omega_(o)) = f (p , omega_(o) , omega_(i)) L_(i) (p , omega_(i)) lr(|cos theta_i|) d omega_(i) . $


#parec[
  Here an absolute value has been added to the $cos theta_i$ factor. This is done because surface normals in `pbrt` are not reoriented to lie on the same side of the surface as $omega_(i)$ (many other rendering systems do this, although we find it more useful to leave them in their natural orientation as given by the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`]). Doing so makes it easier to consistently apply conventions like "the surface normal is assumed to point outside the surface" elsewhere in the system. Thus, applying the absolute value to $cos theta$ factors like these ensures that the desired quantity is calculated.
][
  这里在 $cos theta_i$ 因子上添加了绝对值。这是因为在 `pbrt` 中，表面法向量不会重新定向到与 $omega_(i)$ 同侧（虽然许多其他渲染系统会这样做，但我们发现保持它们在#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 给定的自然方向更有用）。这样做使得在系统中其他地方更容易一致地应用“假设表面法向量指向表面外部”等惯例。因此，对这些 $cos theta$ 因子应用绝对值确保计算出所需的量。
]

#parec[
  We can integrate this equation over the sphere of incident directions around $p$ to compute the outgoing radiance in direction $omega_(o)$ due to the incident illumination at $p$ from all directions:
][
  我们可以在 $p$ 周围的入射方向球面上积分这个方程，以计算由于从所有方向入射的光照在 $p$ 处产生的朝 $omega_(o)$ 方向的出射辐亮度：
]

$ L_(o) (p , omega_(o)) = integral_(cal(S)^2) f (p , omega_(o) , omega_(i)) L_(i) (p , omega_(i)) lr(|cos theta_i|) d omega_(i) . $
<scattering-equation>
#parec[
  This is a fundamental equation in rendering; it describes how an incident distribution of light at a point is transformed into an outgoing distribution, based on the scattering properties of the surface. It is often called the #emph[scattering equation] when the sphere $cal(S)^2 $ is the domain (as it is here), or the #emph[reflection
equation] when just the upper hemisphere $cal(H)^2 (upright(bold(n))) $ is being integrated over. One of the key tasks of the integration routines in Chapters #link("https://pbr-book.org/4ed/Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13] through #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs.html#chap:gpu")[15] is to evaluate this integral at points on surfaces in the scene.
][
  这是渲染中的一个基本方程；它描述了一个点的入射光分布如何根据表面的散射特性转化为出射光分布。当球面 $cal(S)^2 $ 是定义域时（如这里），它通常被称为#emph[散射方程]，或者当仅对上半球 $cal(H)^2 (upright(bold(n))) $ 进行积分时称为#emph[反射方程]。第 #link("https://pbr-book.org/4ed/Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13章]到第 #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs.html#chap:gpu")[15章]中的积分程序的关键任务之一是在场景中的表面点处计算这个积分。
]

=== #ez_caption[The BSSRDF][BSSRDF]
<the-bssrdf>

#parec[
  The #emph[bidirectional scattering surface reflectance distribution
function] (BSSRDF) is the formalism that describes scattering from materials that exhibit subsurface light transport. It is a distribution function $S (p_o , omega_(o) , p_i , omega_(i))$ that describes the ratio of exitant differential radiance at point $p_o$ in direction $omega_(o)$ to the incident differential flux at $p_i$ from direction $omega_(i)$ (@fig:bssrdf-setting):
][
  #emph[双向散射表面反射分布函数]（BSSRDF）是描述具有次表面光传输材料散射的数学表述。它是一个分布函数 $S (p_o , omega_(o) , p_i , omega_(i))$，描述了在点 $p_o$ 处沿方向 $omega_(o)$ 的出射微分辐亮度与从方向 $omega_(i)$ 在点 $p_i$ 处的入射微分辐射通量的比率（@fig:bssrdf-setting）：
]

$ S (p_o , omega_(o) , p_i , omega_(i)) = frac(d L_(o) (p_o , omega_(o)), d Phi (p_i , omega_(i))) . $ <bssrdf>


#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f11.svg"),
  caption: [#ez_caption[The bidirectional scattering surface reflectance distribution function generalizes the BSDF to account for light that exits the surface at a point other than where it enters. It is often more difficult to evaluate than the BSDF, although subsurface light transport makes a substantial contribution to the appearance of many real-world objects.][双向散射表面反射分布函数（BSSRDF）将 BSDF 推广到考虑光线从进入表面之外的另一点出射的情况。虽然比 BSDF 更难计算，但次表面光传输对许多现实世界物体的外观有重要贡献。]
  ],
)<bssrdf-setting>
#parec[
  The generalization of the scattering equation for the BSSRDF requires integration over surface area #emph[and] incoming direction, turning the 2D scattering @eqt:scattering-equation into a 4D integral.
][
  BSSRDF 的散射方程的推广需要对表面积#emph[和]入射方向进行积分，将二维散射方程 @eqt:scattering-equation 转化为四维积分。
]

$
  L_(o) (p_o , omega_(o)) = integral_A integral_(cal(H)^2 (upright(bold(n)))) S (p_o , omega_(o) , p_i , omega_(i)) L_(i) (
    p_i , omega_(i)
  ) lr(|cos theta_i|) d omega_(i) d A .
$ <subsurface-scattering-equation>


#parec[
  With two more dimensions to integrate over, it is more complex to account for in rendering algorithms than @eqt:scattering-equation is. However, as the distance between points $p_i$ and $p_o$ increases, the value of $S$ generally diminishes. This fact can be a substantial help in implementations of subsurface scattering algorithms.
][
  由于需要对两个额外维度进行积分，这比@eqt:scattering-equation 在渲染算法中更复杂。然而，随着点 $p_i$ 和 $p_o$ 之间距离的增加， $S$ 的值通常会减小。这一事实在次表面散射算法的实现中可以提供很大帮助。
]

#parec[
  Light transport beneath a surface is described by the same principles as volume light transport in participating media and is described by the equation of transfer, which is introduced in @the-equation-of-transfer . Subsurface scattering is thus based on the same effects as light scattering in clouds and smoke—just at a smaller scale.
][
  表面下的光传输由与参与介质中的体积光传输相同的原理描述，并由传输方程描述，该方程在@the-equation-of-transfer 中介绍。因此，次表面散射基于与云和烟雾中的光散射相同的效应，只是尺度更小。
]


