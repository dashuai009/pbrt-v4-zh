#import "../template.typ": parec, ez_caption

== Radiometry
<Radiometry>
#parec[
  Radiometry provides a set of ideas and mathematical tools to describe light propagation and reflection. It forms the basis of the derivation of the rendering algorithms that will be used throughout the rest of this book. Interestingly enough, radiometry was not originally derived from first principles using the physics of light but was built on an abstraction of light based on particles flowing through space. As such, effects like polarization of light do not naturally fit into this framework, although connections have since been made between radiometry and Maxwell's equations, giving radiometry a solid basis in physics.
][
  辐射度量学提供了一套思想和数学工具来描述光的传播和反射。它构成了本书后续渲染算法的推导基础。有趣的是，辐射度量学最初并不是基于光的物理学基本原理推导出来的，而是基于光在空间中流动的粒子抽象构建的。因此，像光的偏振这样的效应并不契合这个框架，尽管后来辐射度量学和麦克斯韦方程建立了联系，使得辐射度量学在物理学中有了坚实的基础。
]

#parec[
  #emph[Radiative transfer] is the phenomenological study of the transfer of radiant energy. It is based on radiometric principles and operates at the #emph[geometric optics] level, where macroscopic properties of light suffice to describe how light interacts with objects much larger than the light's wavelength. It is not uncommon to incorporate phenomena from wave optics models of light, but these results need to be expressed in the language of radiative transfer's basic abstractions.
][
  #emph[辐射传输];是对辐射能量传输的现象研究。它基于辐射度量学的原理，并在几何光学的层面进行处理，这时，光的宏观特性足以描述光如何与比光波长大得多的物体相互作用。将光的波动光学模型中的现象纳入其中并不罕见，但这些结果需要用辐射传输基本术语来表达。
]

#parec[
  In this manner, it is possible to describe interactions of light with objects of approximately the same size as the wavelength of the light, and thereby model effects like dispersion and interference. At an even finer level of detail, quantum mechanics is needed to describe light's interaction with atoms. Fortunately, direct simulation of quantum mechanical principles is unnecessary for solving rendering problems in computer graphics, so the intractability of such an approach is avoided.
][
  通过这种方式，可以描述光与与光波长大致相同大小的物体的相互作用，从而模拟诸如色散和干涉等效应。在更细致的层面上，需要量子力学来描述光与原子的相互作用。幸运的是，直接模拟量子力学原理对于解决计算机图形学中的渲染问题是没有必要的，因此避免了这些处理的困难性。
]

#parec[
  In `pbrt`, we will assume that geometric optics is an adequate model for the description of light and light scattering. This leads to a few basic assumptions about the behavior of light that will be used implicitly throughout the system:
][
  在`pbrt`中，我们将假设几何光学是足够描述光和光散射的模型。这引出了一些关于光行为的基本假设，这些假设将在整个系统中默认存在：
]

#parec[
  - #emph[Linearity:] The combined effect of two inputs to an optical system is always equal to the sum of the effects of each of the inputs individually. Nonlinear scattering behavior is only observed in physical experiments involving extremely high energies, so this is generally a reasonable assumption.
][
  - #emph[线性:] 光学系统中两个输入的组合效应总是等于每个输入单独效应的总和。非线性散射行为仅在涉及极高能量的物理实验中观察到，因此这通常是一个合理的假设。
]

#parec[
  - #emph[Energy conservation:] When light scatters from a surface or from participating media, the scattering events can never produce more energy than they started with.
][
  - #emph[能量守恒:] 当光从表面或参与介质散射时，散射之后不会产生比开始时更多的能量。
]

#parec[
  - #emph[No polarization:] Electromagnetic radiation including visible light is #emph[polarized];. A good mental analogy of polarization is a vibration propagating along a taut string. Shaking one end of the string will produce perpendicular waves that travel toward the other end. However, besides a simple linear motion, the taut string can also conduct other kinds of oscillations: the motion could, for example, be clockwise or counter-clockwise and in a circular or elliptical shape. All of these possibilities exist analogously in the case of light. Curiously, this additional polarization state of light is essentially imperceptible to humans without additional aids like specialized cameras or polarizing sunglasses. In `pbrt`, we will therefore make the common assumption that light is unpolarized—that is, a superposition of waves with many different polarizations so that only their average behavior is perceived. Therefore, the only relevant property of light is its distribution by wavelength (or, equivalently, frequency).
][
  - #emph[无偏振:] 电磁辐射，包括可见光，是存在偏振的。偏振可类比作沿着拉紧的绳子传播的振动。摇动绳子的一端会产生垂直的波，向另一端传播。然而，除了简单的线性运动，拉紧的绳子还可以传导其他类型的振荡：例如，运动可以是顺时针或逆时针的，呈圆形或椭圆形。光也存在类似的可能情况。 有趣的是，光的这种额外偏振状态对人类来说基本上是不可察觉的，除非有额外的辅助设备，如专业相机或偏振太阳镜。因此，在`pbrt`中，我们将做出常见的假设，即光是非偏振的——即许多不同偏振的波的叠加，以至于只有它们的平均行为被感知。因此，光的唯一相关性质是其按波长（或等效地，频率）分布。
]

#parec[
  - #emph[No fluorescence or phosphorescence:] The behavior of light at one wavelength is completely independent of light's behavior at other wavelengths or times. As with polarization, it is not too difficult to include these effects if they are required.
][
  - #emph[无荧光或磷光:] 光在一个波长下的行为完全独立于光在其他波长或时间的行为。与偏振一样，如果需要，包含这些效应并不太困难。
]

#parec[
  - #emph[Steady state:] Light in the environment is assumed to have
    reached equilibrium, so its radiance distribution is not changing over
    time. This happens nearly instantaneously with light in realistic
    scenes, so it is not a limitation in practice. Note that
    phosphorescence also violates the steady-state assumption.
][
  - #emph[稳态:] 假设环境中的光已经达到平衡，因此其辐射分布不会随时间变化。在现实场景中，光几乎瞬间达到这种状态，因此在实践中这不是一个限制。注意，磷光也违反了稳态假设。
]

#parec[
  The most significant loss from adopting a geometric optics model is the incompatibility with diffraction and interference effects. Even though this incompatibility can be circumvented—for example, by replacing radiance with the concept of a #emph[Wigner distribution function] (@oh2010 , @Cuypers2012)—such extensions are beyond the scope of this book.
][
  采用几何光学模型的最大损失是与衍射和干涉效应的不兼容性。即使这种不兼容性可以被规避——例如，通过用#emph[维格纳分布函数];的概念替代辐射度量学（@oh2010，@Cuypers2012）——这样的扩展超出了本书的范围。
]

=== Basic Quantities
<basic-quantities>
#parec[
  There are four radiometric quantities that are central to rendering: flux, irradiance / radiant exitance, intensity, and radiance. They can each be derived from energy by successively taking limits over time, area, and directions. All of these radiometric quantities are in general wavelength dependent, though we will defer that topic until @radiometric-spectral-distributions.
][
  有四个辐射度量学量是渲染的核心：通量、辐照度/辐射出射度、强度和辐射度。它们可以通过对能量在时间、面积和方向上逐次取极限来推导。所有这些辐射度量学量通常都依赖于波长，但我们将把这个话题推迟到@radiometric-spectral-distributions。
]

==== Energy
<energy>
#parec[
  Our starting point is energy, which is measured in joules (`J`). Sources of illumination emit photons, each of which is at a particular wavelength and carries a particular amount of energy. All the basic radiometric quantities are effectively different ways of measuring photons. A photon at wavelength $lambda$ carries energy

  $ Q= (h c) / lambda , $ 

  where $c$ is the speed of light, $299,472,458 m \/ s$, and $h$ is Planck's constant, $h approx 6 . 626 times 10^(-34) thin("m")^2 thin "kg/s"$.
][
  我们的起点是能量，单位是焦耳（J）。光源发射光子，每个光子具有特定的波长并携带特定的能量。所有基本的辐射度量学的量实际上是测量光子的不同方式。波长为 $lambda$ 的光子携带的能量为

  $ Q= (h c) / lambda , $ 

  其中 $c$ 是光速， $299,472,458 m \/ s$， $h$ 是普朗克常数， $h approx 6 . 626 times 10^(-34) thin("m")^2 thin "kg/s"$。
]

==== Flux
<sec:flux>
#parec[
  Energy measures work over some period of time, though under the steady-state assumption generally used in rendering, we are mostly interested in measuring light at an instant. #emph[Radiant flux];, also known as #emph[power];, is the total amount of energy passing through a surface or region of space per unit time. Radiant flux can be found by taking the limit of differential energy per differential time:
][
  能量的测量需要一段时间来进行，尽管在渲染中通常使用的稳态假设下，我们主要对瞬间的光测量感兴趣。#emph[辐射通量];，也称为#emph[功率];，是每单位时间通过一个表面或空间区域的总能量。辐射通量可以通过对微分能量与微分时间的极限求得：
]

$
  Phi = lim_(Delta t arrow.r 0) frac(Delta Q, Delta t) = frac(d Q, d t) .
$
#parec[
  Its units are joules/second (J/s), or more commonly, watts (W).
][
  其单位是焦耳/秒（J/s），更常见的是瓦特（W）。
]

#parec[
  For example, given a light that emitted $Q = 200,000 J$ over the course of an hour, if the same amount of energy was emitted at all times over the hour, we can find that the light source's flux was
][
  例如，给定一个在一小时内发射了 $Q = 200,000 J$ 的光，如果在这一小时内始终发射相同数量的能量，我们可以发现光源的通量是
]

$
  Phi = frac(200 comma 000 thin "J", 3600 thin "s") approx 55 . 6 thin "W".
$
#parec[
  Conversely, given flux as a function of time, we can integrate over a range of times to compute the total energy:
][
  反之，给定通量作为时间的函数，我们可以在一段时间范围内积分以计算总能量：
]

$
  Q = integral_(t_0)^(t_1) Phi(t) d t
$

#parec[
  Note that our notation here is slightly informal: among other issues, because photons are discrete quanta, it is not meaningful to take limits that go to zero for differential time. For the purposes of rendering, where the number of photons is enormous with respect to the measurements we are interested in, this detail is not problematic.
][
  请注意，我们这里的符号稍微有些不正式：其中一个问题是，由于光子是离散的量子，对于微分时间取趋于零的极限是没有意义的。在渲染的情况下，光子的数量相对于我们感兴趣的测量是巨大的，这个细节并不成问题。
]

#parec[
  Total emission from light sources is generally described in terms of flux. @fig:flux shows flux from a point light source measured by the total amount of energy passing through imaginary spheres around the light. Note that the total amount of flux measured on either of the two spheres in @fig:flux is the same—although less energy is passing through any local part of the large sphere than the small sphere, the greater area of the large sphere means that the total flux is the same.
][
  光源的总发射量通常用通量来描述。 @fig:flux 显示了从点光源测量的通量，通过穿过光周围的假想球体的总能量来测量。请注意，@fig:flux 中两个球体上测量的总通量是相同的——尽管较大的球体上任何局部区域通过的能量少于较小的球体，但较大球体的面积更大，因此总通量是相同的。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f01.svg"),
  caption: [#ez_caption[Radiant flux, $Phi$ , measures energy passing through a surface or region of space. Here, flux from a point light source is measured at spheres that surround the light.][辐射通量 $Phi$ 用来测量通过一个表面或空间区域的能量。在这里，通量是在围绕点光源的球体上测量的。]
  ],
) <flux>

==== Irradiance and Radiant Exitance

#parec[
  Any measurement of flux requires an area over which photons per time is being measured. Given a finite area $A$, we can define the average density of power over the area by $E = Phi \/ A$ This quantity is either #emph[irradiance] (E), the area density of flux arriving at a surface, or #emph[radiant exitance] (M), the area density of flux leaving a surface. These measurements have units of W/m $""^2$. (The term #emph[irradiance] is sometimes also used to refer to flux leaving a surface, but for clarity we will use different terms for the two cases.)
][
  任何通量的测量都需要一个测量光子每单位时间通过的面积。给定一个有限面积 $A$，我们可以定义该面积上的平均功率密度为 $E = Phi \/ A$ 这个量要么是#emph[辐照度] (E)，即到达表面的通量的面积密度，要么是#emph[辐射出射度] (M)，即离开表面的通量的面积密度。这些测量的单位是 W/m $""^2$。（术语#emph[辐照度];有时也用于指离开表面的通量，但为了清晰起见，我们将在两种情况下使用不同的术语。）
]

#parec[
  For the point light source example in Figure @fig:flux, irradiance at a point on the outer sphere is less than the irradiance at a point on the inner sphere, since the surface area of the outer sphere is larger. In particular, if the point source is emitting the same amount of illumination in all directions, then for a sphere in this configuration that has radius $r$,
][
  对于图 @fig:flux 中的点光源示例，外球面上的一点的辐照度小于内球面上的一点的辐照度，因为外球面的表面积更大。特别是，如果点光源在所有方向上发出相同量的光照，那么对于这种配置下半径为 $r$ 的球体，
]

$ E = frac(Phi, 4 pi r^2) $

#parec[
  This fact explains why the amount of energy received from a light at a point falls off with the squared distance from the light.
][
  这一事实解释了为什么从光源接收到的能量随着距离平方的增加而减少。
]

#parec[
  More generally, we can define irradiance and radiant exitance by taking the limit of differential power per differential area at a point $p$ :
][
  更一般地，我们可以通过在点 $p$ 处取微分功率与微分面积的极限来定义辐照度和辐射出射度：
]

$ E (p) = lim_(Delta A arrow.r 0) frac(Delta Phi (p), Delta A) = frac(d Phi (p), d A) $

#parec[
  We can also integrate irradiance over an area to find power:
][
  我们还可以在一个面积上积分辐照度以找到功率：
]


$ Phi = integral_A E (p) thin d A $ <irradiance-to-power>


#parec[
  The irradiance equation can also help us understand the origin of #emph[Lambert's law];, which says that the amount of light energy arriving at a surface is proportional to the cosine of the angle between the light direction and the surface normal @fig:irradiance . Consider a light source with area $A$ and flux $Phi$ that is illuminating a surface. If the light is shining directly down on the surface (as on the left side of the figure), then the area on the surface receiving light $A_1$ is equal to $A$. Irradiance at any point inside $A_1$ is then
][
  辐照度方程还可以帮助我们理解#emph[朗伯定律];的起源，该定律指出到达表面的光能量与光的入射方向和表面法线之间角度的余弦成正比（@fig:irradiance ）。考虑一个面积为 $A$ 的光源和通量 $Phi$ 照射在一个表面上。如果光直接照射在表面上（如图左侧所示），那么接收光的表面面积 $A_1$ 等于 $A$。在 $A_1$ 内的任何点的辐照度为
]

$ E_1 = Phi / A $

#parec[
  However, if the light is at an angle to the surface, the area on the surface receiving light is larger. If $A$ is small, then the area receiving flux, $A_2$, is roughly $A \/ cos theta$. For points inside $A_2$, the irradiance is therefore
][
  然而，如果光与表面成角度，接收光的表面面积更大。如果 $A$ 很小，那么接收通量的面积 $A_2$ 大约为 $A \/ cos theta$。对于 $A_2$ 内的点，辐照度因此为
]
$ E_2 = frac(Phi cos theta, A) $

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f02.svg"),
  caption: [#ez_caption[*Lambert's Law*. Irradiance arriving at a surface varies according to the cosine of the angle of incidence of illumination, since illumination is over a larger area at larger incident angles.][*朗伯定律*。到达表面的辐照度根据入射光的角度的余弦变化，因为在较大的入射角度下，光照分布在更大的面积上。]
  ],
) <irradiance>


==== Intensity
<intensity>

#parec[
  Consider now an infinitesimal light source emitting photons. If we center this light source within the unit sphere, we can compute the angular density of emitted power. #emph[Intensity];, denoted by $I$, is this quantity; it has units $W \/ s r$. Over the entire sphere of directions, we have
][
  现在考虑一个发射光子的微小光源。如果我们将这个光源放置在单位球体的中心，我们可以计算发射功率的角密度。#emph[强度];，用 $I$ 表示，就是这个量；其单位为 $W \/ s r$。在整个方向球上，我们有
]

$ I = Phi / (4 pi) $

#parec[
  but more generally we are interested in taking the limit of a differential cone of directions:
][
  但更一般地，我们感兴趣的是取方向微分锥角的极限：
]

$ I = lim_(Delta omega arrow.r 0) frac(Delta Phi, Delta omega) = frac(d Phi, d omega) . $

#parec[
  As usual, we can go back to power by integrating intensity: given intensity as a function of direction $I(omega)$, we can integrate over a finite set of directions $Omega$ to recover the power:
][
  像往常一样，我们可以通过对强度进行积分来回到功率：给定强度作为方向的函数 $I(omega)$，我们可以在一个有限的方向集 $Omega$ 上进行积分以求得功率：
]

$
  Phi = integral_Omega I(omega) d omega .
$ <power-from-radiant-intensity>

#parec[
  Intensity describes the directional distribution of light, but it is only meaningful for point light sources.
][
  强度描述了光的方向分布，但它仅对点光源有意义。
]

==== Radiance

#parec[
  The final, and most important, radiometric quantity is #emph[radiance];, L. Irradiance and radiant exitance give us differential power per differential area at a point p, but they do not distinguish the directional distribution of power. Radiance takes this last step and measures irradiance or radiant exitance with respect to solid angles. It is defined by
][
  最后也是最重要的辐射量是#emph[辐亮度] L。辐照度/辐射出射度给出在点 p 的微分面积上的微分功率，但它们不区分功率的方向分布。辐亮度采取了这最后一步，并根据立体角测量辐照度/辐射出射度。它的定义是
]

$
  L(p, omega) = lim_(Delta omega arrow.r 0) frac(Delta E_omega (p), Delta omega) = frac(d E_omega (p), d omega),
$

#parec[
  where we have used $E_(omega)$ to denote irradiance at the surface that is perpendicular to the direction . In other words, radiance is not measured with respect to the irradiance incident at the surface p lies on. In effect, this change of measurement area serves to eliminate the $cos theta$ factor from Lambert's law in the definition of radiance.
][
  这里我们使用 $E_(omega)$ 来表示垂直于该方向的表面上的辐照度。换句话说，辐射度不是相对于表面 p 上的入射辐照度来测量的。实际上，这种测量面积的变化消除了辐射度定义中朗伯定律的 $cos theta$ 因子。
]

#parec[
  Radiance is the flux density per unit area, per unit solid angle. In terms of flux, it is defined by
][
  辐亮度是每单位面积和每单位立体角的通量密度。就通量而言，它的定义是
]

$
  L = frac(d^2 Phi, d omega thin d A^perp),
$ <eqt-radiance>

#parec[
  where $d A^(perp)$ is the projected area of $d A$ on a hypothetical surface perpendicular to $omega$ (Figure 4.3). Thus, it is the limit of the measurement of incident light at the surface as a cone of incident directions of interest $d omega$ becomes very small and as the local area of interest on the surface $d A$ also becomes very small.
][
  这里 $d A^(perp)$ 是 $d A$ 在假设的垂直于方向 $omega$ 的表面上的投影面积（见图 4.3）。因此，它是对表面上入射光的测量极限，当感兴趣的入射方向锥 $d omega$ 变得非常小时，以及表面上感兴趣的局部区域 $d A$ 也变得非常小时。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f03.svg"),
  caption: [
    #ez_caption[Radiance $L$ is defined as flux per unit solid angle $d omega$ per unit projected area $d A^(perp)$.][辐亮度L是每单位面积$d omega$和每单位立体角$d A^(perp)$的通量密度。]
  ],
)

#parec[
  Of all of these radiometric quantities, radiance will be the one used most frequently throughout the rest of the book. An intuitive reason for this is that in some sense it is the most fundamental of all the radiometric quantities; if radiance is given, then all the other values can be computed in terms of integrals of radiance over areas and directions. Another nice property of radiance is that it remains constant along rays through empty space. It is thus a natural quantity to compute with ray tracing.
][
  在所有这些辐射量中，辐亮度将在本书的其余部分中最常使用。一个直观的原因是，在某种意义上，它是所有辐射量中最基本的；如果给定辐亮度，则所有其他值都可以通过辐亮度在面积和方向上的积分来计算。辐亮度的另一个优良特性是它在空旷空间中沿光线保持不变。因此，它是用光线追踪计算的自然量。
]

=== Incident and Exitant Radiance Functions
#parec[
  When light interacts with surfaces in the scene, the radiance function L is generally not continuous across the surface boundaries. In the most extreme case of a fully opaque surface (e.g., a mirror), the radiance function slightly above and slightly below a surface could be completely unrelated.
][
  当光与场景中的表面交互时，辐亮度函数 L 通常在表面边界上不连续。在最极端的情况下，如完全不透明的表面（例如镜子），表面上方和下方的辐亮度函数可能完全没有关联。
]

#parec[
  It therefore makes sense to take one-sided limits at the discontinuity to distinguish between the radiance function just above and below
][
  因此，在不连续处取单侧极限以区分表面上方和下方的辐亮度函数是合理的
]

$
  L^+ (p, omega) & = lim_(t arrow.r 0^+) L(p + t n_p, omega),\
  L^- (p, omega) & = lim_(t arrow.r 0^-) L(p + t n_p, omega) .
$ <radiance-limits-onesided>
#parec[
  where $bold(n)_p$ is the surface normal at $p$. However, keeping track of one-sided limits throughout the text is unnecessarily cumbersome.
][
  其中 $bold(n)_p$ 是点 $p$ 处的表面法线。然而，在本书中不需要繁琐的计算单侧极限。
]

#parec[
  We prefer to solve this ambiguity by making a distinction between radiance arriving at the point (e.g., due to illumination from a light source) and radiance leaving that point (e.g., due to reflection from a surface).
][
  我们更倾向于通过区分到达该点的辐射亮度（例如，由于光源的照射）和从该点离开的辐射亮度（例如，由于表面的反射）来解决这一模糊性。
]

#parec[
  Consider a point $p$ on the surface of an object. There is some distribution of radiance arriving at the point that can be described mathematically by a function of position and direction. This function is denoted by $L_(i)(p, omega)$ (@radiance-incident-exitant). The function that describes the outgoing reflected radiance from the surface at that point is denoted by $L_(o)(p, omega)$. Note that in both cases the direction vector $omega$ is oriented to point away from $p$, but be aware that some authors use a notation where $omega$ is reversed for $L_(i)$ terms so that it points toward $p$.
][
  考虑物体表面上的一个点 $p$。到达该点的辐射度分布可以通过一个位置和方向的函数来描述。这个函数表示为 $L_(i)(p, omega)$ （见@radiance-incident-exitant）。描述该点处表面反射的出射辐射度的函数表示为 $L_(o)(p, omega)$。请注意，在这两种情况下，方向向量 $omega$ 都指向远离 $p$，但需要注意的是，一些作者使用的符号中， $L_(i)$ 项中的 $omega$ 是反向的，因此它指向 $p$。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f04.svg"),
  caption: [#ez_caption[(a) The incident radiance function $L_(i)(p,  omega)$ describes the distribution of radiance arriving at a point as a function of position and direction. (b) The exitant radiance function $L_(o)(p,  omega)$ gives the distribution of radiance leaving the point. Note that for both functions, $omega$ is oriented to point away from the surface, and thus, for example, $L_(i)(p, -omega)$ gives the radiance arriving on the other side of the surface than the one where $omega$ lies.][(a) 入射辐射度函数 $L_(i)(p, omega)$ 描述了到达某点的辐射度分布，作为位置和方向的函数。 (b) 出射辐射度函数 $L_(o)(p, omega)$ 给出了离开该点的辐射度分布。请注意，对于这两个函数，$omega$ 的方向都指向远离表面，因此，例如，$L_(i)(p, -omega)$ 表示到达表面另一侧的辐射度，即 $omega$ 所在的一侧的对面。]],
) <radiance-incident-exitant>

#parec[
  There is a simple relation between these more intuitive incident and exitant radiance functions and the one-sided limits from @eqt:radiance-limits-onesided:
][
  这些更直观的入射和出射辐射亮度函数与@eqt:radiance-limits-onesided 中的单侧极限之间有一个简单的关系：
]

$
  L_i (p comma omega) =
  cases(
   L^+ (p comma - omega) comma "  " omega dot.op upright(bold(n))_p > 0,
   L^- (p comma - omega) comma "  " omega dot.op upright(bold(n))_p < 0
  ) \
  L_o (p comma omega) =
  cases(
    L^+ (p comma omega) comma "   " omega dot.op upright(bold(n))_p > 0,
    L^- (p comma omega) comma "   " omega dot.op upright(bold(n))_p < 0 .
  )
$

#parec[
  Throughout the book, we will use the idea of incident and exitant radiance functions to resolve ambiguity in the radiance function at boundaries.
][
  在整本书中，我们将使用入射和出射辐射亮度函数的概念来解决边界处辐射亮度函数的模糊性。
]

#parec[
  Another property to keep in mind is that at a point in space where there is no surface (i.e., in free space), $L$ is continuous, so $L^+ = L^-$ , which means
][
  另一个需要记住的性质是，在没有表面的空间点（即，自由空间）处， $L$ 是连续的，因此 $L^+ = L^-$ ，这意味着
]

$
  L_o (p, omega) = L_i (p, - omega) = L(p, omega) .
$

#parec[
  In other words, $L_(i)$ and $L_o$ only differ by a direction reversal.
][
  换句话说， $L_(i)$ and $L_o$ 仅在方向上相反。
]

=== Radiometric Spectral Distributions
<radiometric-spectral-distributions>

#parec[
  Thus far, all the radiometric quantities have been defined without considering variation in their distribution over wavelengths. They have therefore effectively been the integrals of wavelength-dependent quantities over an (unspecified) range of wavelengths of interest. Just as we were able to define the various radiometric quantities in terms of limits of other quantities, we can also define their spectral variants by taking their limits over small wavelength ranges.
][
  到目前为止，所有的辐射量都被定义为不考虑其在波长上的分布变化。 因此，它们实际上是波长相关量在一个（未指定）波长范围内的积分。 正如我们能够通过其他量的极限来定义各种辐射量一样，我们也可以通过在小波长范围内取极限来定义它们的光谱变体。
]


#parec[
  For example, we can define #emph[spectral radiance] $L_lambda$ as the limit of radiance over an infinitesimal interval of wavelengths $Delta lambda$,
][
  例如，我们可以定义#emph[光谱辐射亮度] $L_lambda$ 为辐射亮度在一个无限小波长间隔 $Delta lambda$ 上的极限，
]

$
  L_lambda = lim_(Delta lambda arrow.r 0) frac(Delta L, Delta lambda) = frac(d L, d lambda) .
$

#parec[
  In turn, radiance can be found by integrating spectral radiance over a range of wavelengths:
][
  反过来，可以通过在一定波长范围内积分光谱辐射亮度来找到辐射亮度：
]

$
  L = integral_(lambda_0)^(lambda_1) L_lambda (lambda) thin d lambda .
$ <radiance-from-spectral>

#parec[
  Definitions for the other radiometric quantities follow similarly. All of these spectral variants have an additional factor of $1\/m$ in their units.
][
  其他辐射量的定义类似。所有这些光谱变体的单位中都多了一个 $1\/m$ 因子。
]

=== Luminance and Photometry
<luminance-and-photometry>
#parec[
  All the radiometric measurements like flux, radiance, and so forth have corresponding photometric measurements. #emph[Photometry] is the study of visible electromagnetic radiation in terms of its perception by the human visual system. Each spectral radiometric quantity can be converted to its corresponding photometric quantity by integrating against the spectral response curve $V(lambda)$, which describes the relative sensitivity of the human eye to various wavelengths.#footnote[The spectral response curve model is based on experiments done in a normally illuminated indoorenvironment. Because sensitivity to color decreases in dark environments,it does not model the human visual system's response well under all lighting situations.Nonetheless, it forms the basis for the definition of luminance and other related photometric properties.]
][
  所有的辐射测量，如流量、辐射亮度等，都有相应的光度测量。 #emph[光度学];是研究可见电磁辐射在其被人类视觉系统感知方面的学科。 每个光谱辐射量可以通过与光谱响应曲线 $V(lambda)$ 相乘来转换为其对应的光度量，该曲线描述了人眼对各种波长的相对敏感度。#footnote[光谱响应曲线模型基于在正常照明的室内环境中进行的实验。由于在黑暗环境中对颜色的敏感度降低，该模型无法很好地模拟人类视觉系统在所有照明条件下的响应。然而，它构成了亮度和其他相关光度特性的定义基础。]
]


#parec[
  #emph[Luminance] measures how bright a spectral power distribution appears to a human observer. For example, luminance accounts for the fact that a spectral distribution with a particular amount of energy in the green wavelengths will appear brighter to a human than a spectral distribution with the same amount of energy in blue.
][
  #emph[亮度];测量的是光谱功率分布对人类观察者的亮度感知。 例如，亮度考虑到一个特定能量在绿色波长的光谱分布比在蓝色波长的光谱分布对人类来说看起来更亮。
]

#parec[
  We will denote luminance by $Y$ ; it is related to spectral radiance by
][
  我们将用 $Y$ 表示亮度；它与光谱辐射亮度的关系为
]


$ Y = integral_lambda L_lambda (lambda) V (lambda) thin d lambda $<luminance>


#parec[
  Luminance and the spectral response curve $V (lambda)$ are closely related to the XYZ representation of color, which will be introduced in @xyz-color .
][
  光亮度和光谱响应曲线 $V (lambda)$ 与 XYZ 颜色表示密切相关，这将在@xyz-color 介绍。
]

#parec[
  The units of luminance are candelas per meter squared ( $upright("cd/m")^2$ ), where the candela is the photometric equivalent of radiant intensity. Some representative luminance values are given in @tbl:luminance-values.
][
  光亮度的单位是每平方米坎德拉 ( $upright("cd/m")^2$ )，其中坎德拉(光强单位)是辐射强度的光度学等效单位。一些代表性的光亮度值在@tbl:luminance-values 中给出。
]



#figure(
  table(
    columns: 2,
    [Condition], [Luminance ($c d\/m^2$, or nits) ],
    [ Sun at horizon], [600,000 ],
    [ 60-watt lightbulb], [ 120,000 ],
    [ Clear sky], [ 8,000 ],
    [ Typical office], [ 100-1,000 ],
    [ Typical computer display], [ 1-100 ],
    [ Street lighting], [ 1-10 ],
    [ Cloudy moonlight], [ 0.25 ],
  ),
  caption: [
    #ez_caption[Representative Luminance Values for a Number of Lighting Conditions. ][若干照明条件的代表性光亮度值。]
  ],
)<luminance-values>

#parec[
  All the other radiometric quantities that we have introduced in this chapter have photometric equivalents; they are summarized in @tbl:radiometric-photometric.#footnote[The various photometric quantities have fairly unusual names; the somewhat confusing state of affairs was nicely summarized by Jim Kajiya: “Thus one nit is one lux per steradian is one candela per square meter is one lumen per square meter per steradian. Got it?”]
][
  我们在本章中介绍的所有其他辐射测量量都有光度学对应量；它们在@tbl:radiometric-photometric 中总结。#footnote[各种光度量有相当不寻常的名称；吉姆·卡吉亚（Jim Kajiya）很好地总结了这种有点令人困惑的情况：“因此，一尼特是一勒克斯每球面度是一坎德拉每平方米是一流明每球面度。明白了吗？”]
]

#figure(
  align(center)[#table(
      columns: (20%, 17%, 27%, 33.33%),
      align: (auto, auto, auto, auto),
      table.header([Radiometric], [Unit], [Photometric], [Unit]),
      table.hline(),
      [Radiant energy], [joule (J)], [Luminous energy], [talbot (T)],
      [Radiant flux], [watt (W)], [Luminous flux], [lumen (lm)],
      [Intensity], [$W\/s r$], [Luminous intensity], [$"lm"\/s r = "candela" (c d)$],
      [Irradiance], [$W \/ m^2$], [Illuminance], [$"lm"\/m^2 = "lux" ("lx")$],
      [Radiance], [$W\/(m^2 dot s r)$], [Luminance], [$"lm"\/(m^2 dot "sr") = "cd"\/m^2 = "nit"$],
    )],
  kind: table,
  caption: [#ez_caption[Radiometric Measurements and Their Photometric Analogs. ][辐射测量及其光度学对应量。]
  ],
) <radiometric-photometric>