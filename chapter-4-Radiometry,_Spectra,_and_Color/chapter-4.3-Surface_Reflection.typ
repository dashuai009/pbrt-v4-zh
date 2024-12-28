#import "../template.typ": parec, ez_caption, ez_caption

== Surface Reflection
<surface-reflection>
#parec[
  When light is incident on a surface, the surface scatters the light, reflecting some of it back into the environment. There are two main effects that need to be described to model this reflection: the spectral distribution of the reflected light and its directional distribution. For example, the skin of a lemon mostly absorbs light in the blue wavelengths but reflects most of the light in the red and green wavelengths. Therefore, when it is illuminated with white light, its color is yellow. It has much the same color no matter what direction it is being observed from, although for some directions a highlight—a brighter area that is more white than yellow—is visible. In contrast, the light reflected from a point in a mirror depends almost entirely on the viewing direction. At a fixed point on the mirror, as the viewing angle changes, the object that is reflected in the mirror changes accordingly.
][
  当光照射到一个表面时，表面会散射和反射光线，将部分光线反射回环境中。为了模拟这种反射，需要描述两个主要效果：反射光的光谱分布和方向分布。例如，柠檬的表皮主要吸收蓝色波长的光，但反射大部分红色和绿色波长的光。因此，当它被白光照射时，其颜色为黄色。无论从哪个方向观察，它的颜色几乎相同，尽管从某些方向看，会看到一个高光区域——一个比黄色更白的亮区。相比之下，从镜子中的一点反射的光几乎完全取决于观察方向。在镜子上的一个固定点，当观察角度改变时，镜子中反射的物体也会相应改变。
]

#parec[
  Reflection from translucent surfaces is more complex; a variety of materials ranging from skin and leaves to wax and liquids exhibit #emph[subsurface light transport];, where light that enters the surface at one point exits it some distance away. (Consider, for example, how shining a flashlight in one's mouth makes one's cheeks light up, as light that enters the inside of the cheeks passes through the skin and exits the face.)
][
  从半透明表面反射的光更为复杂；从皮肤和树叶到蜡和液体，各种材料表现出#emph[次表面光传导];，即光在一个点进入表面后在一定距离外离开。（例如，考虑用手电筒照射嘴巴时，脸颊会发光，因为进入脸颊内部的光穿过皮肤并从脸上出来。）
]

#parec[
  There are two abstractions for describing these mechanisms for light reflection: the BRDF and the BSSRDF, described in @the-brdf-and-the-btdf and @the-bssrdf , respectively. The BRDF describes surface reflection at a point neglecting the effect of subsurface light transport. For materials where this transport mechanism does not have a significant effect, this simplification introduces little error and makes the implementation of rendering algorithms much more efficient. The BSSRDF generalizes the BRDF and describes the more general setting of light reflection from translucent materials.
][
  描述这些光反射机制有两种抽象概念：BRDF和BSSRDF，分别在@the-brdf-and-the-btdf 和@the-bssrdf 中描述。BRDF描述了忽略次表面光传导效应的点表面反射。对于这种传导机制影响不显著的材料，这种简化引入的误差很小，并使计算机图形学渲染算法的实现更加高效。BSSRDF则是BRDF的推广，描述了从半透明材料反射光的更一般情况。
]

=== The BRDF and the BTDF
<the-brdf-and-the-btdf>
#parec[
  The #emph[bidirectional reflectance distribution function] (BRDF) gives a formalism for describing reflection from a surface. Consider the setting in @fig:brdf-setting: we would like to know how much radiance is leaving the surface in the direction $omega_(o)$ toward the viewer, $L_(o) (p , omega_(o))$, as a result of incident radiance along the direction $omega_(i) , L_(i) (p , omega_(i))$. (When considering light scattering at a surface location, #emph[pbrt] uses the convention that $omega_(i)$ refers to the direction from which the quantity of interest (radiance in this case) arrives, rather than the direction from which the #emph[Integrator] reached the surface.)
][
  #emph[双向反射分布函数]（BRDF）提供了一种描述表面反射的形式。考虑@fig:brdf-setting 中的情境：我们希望知道在 $omega_(o)$ 方向上离开表面的辐射度 $L_(o) (p , omega_(o))$ 是多少，这是由于沿 $omega_(i)$ 方向入射的辐射度 $L_(i) (p , omega_(i))$ 造成的。（在考虑表面位置的光散射时，#emph[pbrt] 采用的惯例是 $omega_(i)$ 指的是感兴趣的量（在这种情况下是辐射度）到达的方向，而不是 #emph[Integrator] 到达表面的方向。）
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f10.svg"),
  caption: [
    #ez_caption[ *The BRDF.* The bidirectional reflectance distribution
      function is a 4D function over pairs of directions $omega_i$ and
      $omega_o$ that describes how much incident light along $omega_i$ is scattered from the surface in the direction $omega_o$.
    ][ *BRDF:*双向反射分布函数是一个关于方向对$omega_i$和$omega_o$的4D函数，描述了沿$omega_i$方向的入射光在$omega_o$方向从表面散射的量。

    ]
  ],
) <brdf-setting>

#parec[
  If the direction $omega_i$ is considered as a differential cone of directions, the differential irradiance at $p$ is:
][
  如果将方向 $omega_i$ 视为一个微分方向锥，则在 $p$ 处的微分辐照度为：
]

$
  d E (p , omega_(i)) = L_(i) (p , omega_(i)) cos theta_(i) thin d omega_(i) .
$<differential-irradiance>

#parec[
  A differential amount of radiance will be reflected in the direction $omega_o$ due to this irradiance. Because of the linearity assumption from geometric optics, the reflected differential radiance is proportional to the irradiance
][
  由于这个辐照度，将会有微分量的辐射在方向 $omega_o$ 上反射。由于在几何光学中的线性假设，反射的微分辐射与辐照度成正比：
]

$
  d L_( o) (p , omega_( o)) prop d E (p , omega_( i)) .
$
#parec[
  The constant of proportionality defines the surface's BRDF $f_r$ for the particular pair of directions $omega_i$ and $omega_o$ :
][
  比例常数定义了特定方向对 $omega_i$ 和 $omega_o$ 的表面BRDF $f_r$ ：
]

$
  f_r (
    upright(bold(p)), omega_o, omega_i
  ) = frac(d L_o (upright(bold(p)) comma omega_o), d E(upright(bold(p)) comma omega_i)) = frac(d L_o (upright(bold(p)) comma omega_o), L_i (upright(bold(p)) comma omega_i) cos theta_i thin d omega_i) .
$ <brdf>
#parec[
  The spectral BRDF is defined by using spectral radiance in place of radiance.
][
  光谱双向反射分布函数通过使用光谱辐射代替辐射来定义。
]

#parec[
  Physically based BRDFs have two important qualities:

  + #emph[Reciprocity:] For all pairs of directions $omega_i$ and $omega_o$, $f_r (upright(bold(p)), omega_i, omega_o) = f_r (upright(bold(p)), omega_o, omega_i)$

  + #emph[Energy conservation:] The total energy of light reflected is less than or equal to the energy of incident light. For all directions $omega_o$, $
    integral_(cal(H)^2 (upright(bold(n)))) f_r (upright(bold(p)), omega_o, omega') cos theta' thin d omega' lt.eq 1 .
  $
][
  基于物理的BRDF有两个重要特性：

  + #emph[互易原理：] 对于所有方向对$omega_i$和$omega_o$，$f_r (upright(bold(p)), omega_i, omega_o) = f_r (upright(bold(p)), omega_o, omega_i)$。

  + #emph[能量守恒原则：]
    反射光的总能量小于或等于入射光的能量。对于所有方向$omega_o$，

  $
    integral_(cal(H)^2 (upright(bold(n)))) f_r (upright(bold(p)), omega_o, omega') cos theta' thin d omega' lt.eq 1 .
  $
]

#parec[
  Note that the value of the BRDF for a pair of directions $omega_i$ and $omega_o$ is #emph[not] necessarily less than 1; it is only its integral that has this normalization constraint.
][
  注意，对于方向对 $omega_i$ 和 $omega_o$，BRDF的值#emph[不];一定小于1；只有其积分具有这种归一化约束。
]

#parec[
  Two quantities that are based on the BRDF will occasionally be useful. First, the #emph[hemispherical-directional reflectance] is a 2D function that gives the total reflection in a given direction due to constant illumination over the hemisphere, or, equivalently, the total reflection over the hemisphere due to light from a given direction.#footnote[The fact that these two quantities are equal is due to the reciprocity of reflection functions.] It is defined as
][
  基于BRDF的两个量偶尔会有用。首先，#emph[半球-方向反射率];是一个2D函数，给出在给定方向上的总反射，由半球上的均匀照明引起，或者等价地，由给定方向的光引起的半球上的总反射。#footnote[这两个量相等的事实是由于反射函数的互易性。] 它被定义为
]


$ rho_(h d) (omega_o) = integral_(H^2 (upright(bold(n)))) f_r (p , omega_o , omega_i) lr(|cos theta_i|) d omega_i . $
<rho-hd>

#parec[
  The #emph[hemispherical-hemispherical reflectance] of a BRDF, denoted by $rho_(h h)$, gives the fraction of incident light reflected by a surface when the incident light is the same from all directions. It is
][
  BRDF的#emph[半球-半球反射率];，记作 $rho_(h h)$，表示当入射光均匀地从所有方向入射时，表面反射的入射光的比例。它是
]

$
  rho_(h h) = 1 / pi integral_(H^2 (upright(bold(n)))) integral_(H^2 (upright(bold(n)))) f_r (
    p , omega_o , omega_i
  ) lr(|cos theta_o cos theta_i|) d omega_o d omega_i .
$
<rho-hh>

#parec[
  A surface's #emph[bidirectional transmittance distribution function] (BTDF), which describes the distribution of transmitted light, can be defined in a manner similar to that for the BRDF. The BTDF is generally denoted by $f_t (p , omega_o , omega_i)$, where $omega_i$ and $omega_o $ are in opposite hemispheres around $p$. Remarkably, the BTDF does not obey reciprocity as defined above; we will discuss this issue in detail in @non-symmetric-scattering-and-refraction.
][
  表面的#emph[双向透射分布函数];（BTDF）描述透射光的分布，可以类似于BRDF来定义。BTDF通常表示为 $f_t (p , omega_o , omega_i)$，其中 $omega_i$ 和 $omega_o$ 位于 $p$ 周围的相对半球中。值得注意的是，BTDF不符合上述定义的互易性；我们将在@non-symmetric-scattering-and-refraction 中详细讨论这个问题。
]

#parec[
  For convenience in equations, we will denote the BRDF and BTDF when considered together as $f (p , omega_o , omega_i) $ ; we will call this the #emph[bidirectional scattering distribution function] (BSDF).@reflection-models is entirely devoted to describing a variety of BSDFs that are useful for rendering.
][
  为了方便方程表示，我们将BRDF和BTDF一起表示为 $f (p , omega_o , omega_i) $ ；我们称之为#emph[双向散射分布函数];（BSDF）。@reflection-models 完全致力于描述各种对渲染有用的BSDF。
]

#parec[
  Using the definition of the BSDF, we have
][
  使用BSDF的定义，我们有
]

$ d L_o (p , omega_o) = f (p , omega_o , omega_i) L_i (p , omega_i) lr(|cos theta_i|) d omega_i . $


#parec[
  Here an absolute value has been added to the $cos theta_i$ factor. This is done because surface normals in #emph[pbrt] are not reoriented to lie on the same side of the surface as $omega_i$ (many other rendering systems do this, although we find it more useful to leave them in their natural orientation as given by the #link("../Shapes/Basic_Shape_Interface.html#Shape")[#emph[Shape];] interface). Doing so makes it easier to consistently apply conventions like "the surface normal is assumed to point outside the surface" elsewhere in the system. Thus, applying the absolute value to $cos theta$ factors like these ensures that the desired quantity is calculated.
][
  这里在 $cos theta_i$ 因子上添加了绝对值。这是因为在#emph[pbrt];中，表面法线不会重新定向到与 $omega_i$ 同侧（虽然许多其他渲染系统会这样做，但我们发现保持它们在#link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape];接口给定的自然方向更有用）。这样做使得在系统中其他地方更容易一致地应用“假设表面法线指向表面外部”等惯例。因此，对这些 $cos theta$ 因子应用绝对值确保计算出所需的量。
]

#parec[
  We can integrate this equation over the sphere of incident directions around $p$ to compute the outgoing radiance in direction $omega_o$ due to the incident illumination at $p$ from all directions:
][
  我们可以在 $p$ 周围的入射方向球面上积分这个方程，以计算由于从所有方向入射的光照在 $p$ 处产生的朝 $omega_o$ 方向的出射辐射度：
]

$ L_o (p , omega_o) = integral_(S^2) f (p , omega_o , omega_i) L_i (p , omega_i) lr(|cos theta_i|) d omega_i . $
<scattering-equation>
#parec[
  This is a fundamental equation in rendering; it describes how an incident distribution of light at a point is transformed into an outgoing distribution, based on the scattering properties of the surface. It is often called the #emph[scattering equation] when the sphere $S^2 $ is the domain (as it is here), or the #emph[reflection
equation] when just the upper hemisphere $H^2 (upright(bold(n))) $ is being integrated over. One of the key tasks of the integration routines in Chapters #link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13] through #link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15] is to evaluate this integral at points on surfaces in the scene.
][
  这是渲染中的一个基本方程；它描述了一个点的入射光分布如何根据表面的散射特性转化为出射光分布。当球面 $S^2 $ 是定义域时（如这里），它通常被称为#emph[散射方程];，或者当仅对上半球 $H^2 (upright(bold(n))) $ 进行积分时称为#emph[反射方程];。第#link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13章];到第#link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15章];中的积分程序的关键任务之一是在场景中的表面点处评估这个积分。
]

=== The BSSRDF
<the-bssrdf>

#parec[
  The #emph[bidirectional scattering surface reflectance distribution
function] (BSSRDF) is the formalism that describes scattering from materials that exhibit subsurface light transport. It is a distribution function $S (p_o , omega_o , p_i , omega_i)$ that describes the ratio of exitant differential radiance at point $p_o$ in direction $omega_o$ to the incident differential flux at $p_i$ from direction $omega_i$ (@bssrdf-setting):
][
  #emph[双向散射表面反射分布函数];（BSSRDF）是描述具有次表面光传输材料散射的形式。它是一个分布函数 $S (p_o , omega_o , p_i , omega_i)$，描述了在点 $p_o$ 处朝方向 $omega_o$ 的出射微分辐射度与从方向 $omega_i$ 在点 $p_i$ 处的入射微分通量的比率（@bssrdf-setting）：
]

$ S (p_o , omega_o , p_i , omega_i) = frac(d L_o (p_o , omega_o), d Phi (p_i , omega_i)) . $


#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f11.svg"),
  caption: [#ez_caption[The bidirectional scattering surface reflectance distribution function generalizes the BSDF to account for light that exits the surface at a point other than where it enters. It is often more difficult to evaluate than the BSDF, although subsurface light transport makes a substantial contribution to the appearance of many real-world objects.][双向散射表面反射分布函数（BSSRDF）将BSDF推广到考虑光线从进入表面之外的另一点出射的情况。虽然比BSDF更难计算，但次表面光传输对许多现实世界物体的外观有重要贡献。]
  ],
)<bssrdf-setting>
#parec[
  The generalization of the scattering equation for the BSSRDF requires integration over surface area #emph[and] incoming direction, turning the 2D scattering Equation (4.14) into a 4D integral.
][
  BSSRDF的散射方程的推广需要对表面积和入射方向进行积分，将二维散射方程(4.14)转化为四维积分。
]

$
  L_o (p_o , omega_o) = integral_A integral_(H^2 (upright(bold(n)))) S (p_o , omega_o , p_i , omega_i) L_i (
    p_i , omega_i
  ) lr(|cos theta_i|) d omega_i d A .
$


#parec[
  With two more dimensions to integrate over, it is more complex to account for in rendering algorithms than @eqt:scattering-equation is. However, as the distance between points $p_i$ and $p_o$ increases, the value of $S$ generally diminishes. This fact can be a substantial help in implementations of subsurface scattering algorithms.
][
  由于需要对两个额外维度进行积分，这比@eqt:scattering-equation 在渲染算法中更复杂。然而，随着点 $p_i$ 和 $p_o$ 之间距离的增加， $S$ 的值通常会减小。这一事实在次表面散射算法的实现中可以提供很大帮助。
]

#parec[
  Light transport beneath a surface is described by the same principles as volume light transport in participating media and is described by the equation of transfer, which is introduced in @the-equation-of-transfer . Subsurface scattering is thus based on the same effects as light scattering in clouds and smoke—just at a smaller scale.
][
  表面下的光传输由与参与介质中的体积光传输相同的原理描述，并由传输方程描述，该方程在@the-equation-of-transfer 中介绍。因此，次表面散射基于与云和烟雾中的光散射相同的效应，只是规模较小。
]


