#import "../template.typ": parec, ez_caption, translator, fake-par

== Radiometry
<Radiometry>
#parec[
  Radiometry provides a set of ideas and mathematical tools to describe light propagation and reflection.
  It forms the basis of the derivation of the rendering algorithms that will be used throughout the rest of this book.
  Interestingly enough, radiometry was not originally derived from first principles using the physics of light but was built on an abstraction of light based on particles flowing through space.
  As such, effects like polarization of light do not naturally fit into this framework, although connections have since been made between radiometry and Maxwell's equations, giving radiometry a solid basis in physics.
][
  辐射度量学（Radiometry）提供了一套用于描述光传播与反射的概念和数学工具。
  它构成了本书中渲染算法推导的基础。
  有趣的是，辐射度量学最初并不是基于光的物理学基本原理推导出来的，而是建立在一种将光抽象为在空间中流动的粒子的模型之上。
  因此，诸如光的偏振效应等现象并不自然地适应这一框架。
  不过，辐射度量学与麦克斯韦方程组（Maxwell's Equations）之间后来被建立起了联系，从而赋予了辐射度量学坚实的物理学基础。
]

#parec[
  #emph[Radiative transfer] is the phenomenological study of the transfer of radiant energy.
  It is based on radiometric principles and operates at the #emph[geometric optics] level, where macroscopic properties of light suffice to describe how light interacts with objects much larger than the light's wavelength.
  It is not uncommon to incorporate phenomena from wave optics models of light, but these results need to be expressed in the language of radiative transfer's basic abstractions.
][
  #emph[辐射传输（Radiative transfer））];是研究辐射能量传输的现象学理论。
  它基于辐射度量学的原理，并在几何光学的层面进行处理，这时，光的宏观特性足以描述光如何与比光波长大得多的物体相互作用。
  在一些情况下，也会引入源自波动光学（Wave Optics）的光学现象，但这些结果需要用辐射传输的基本抽象语言进行表述，以保持一致性。
]

#parec[
  In this manner, it is possible to describe interactions of light with objects of approximately the same size as the wavelength of the light, and thereby model effects like dispersion and interference.
  At an even finer level of detail, quantum mechanics is needed to describe light's interaction with atoms.
  Fortunately, direct simulation of quantum mechanical principles is unnecessary for solving rendering problems in computer graphics, so the intractability of such an approach is avoided.
][
  通过这种方式，可以描述光与尺寸大致与光波长相同的物体之间的相互作用，从而能够模拟诸如色散（Dispersion）和干涉（Interference）等现象。
  在更细致的层面上，需要量子力学来描述光与原子的相互作用。
  幸运的是，计算机图形学中的渲染问题并不需要直接模拟量子力学的原理，从而避免这种方法所带来的计算不可行性。
]

#parec[
  In `pbrt`, we will assume that geometric optics is an adequate model for the description of light and light scattering.
  This leads to a few basic assumptions about the behavior of light that will be used implicitly throughout the system:
][
  在 `pbrt` 中，我们将假设几何光学是足够用来描述光与光散射的模型。
  这引出了一些关于光行为的基本假设，这些假设将在整个系统中默认存在：
]

#parec[
  - #emph[Linearity:] The combined effect of two inputs to an optical system is always equal to the sum of the effects of each of the inputs individually. Nonlinear scattering behavior is only observed in physical experiments involving extremely high energies, so this is generally a reasonable assumption.
][
  - #emph[线性（Linearity）：];光学系统中两个输入的组合效果，总是等于各个输入单独作用时的效果之和。非线性散射行为仅在涉及极高能量的物理实验中观察到，因此这一假设通常是合理的
]

#parec[
  - #emph[Energy conservation:] When light scatters from a surface or from participating media, the scattering events can never produce more energy than they started with.
][
  - #emph[能量守恒（Energy Conservation）：];当光在表面或参与介质（Participating Media）中发生散射时，散射事件所产生的能量永远不会超过初始入射光的能量。
]

#parec[
  - #emph[No polarization:] Electromagnetic radiation including visible light is #emph[polarized];. A good mental analogy of polarization is a vibration propagating along a taut string. Shaking one end of the string will produce perpendicular waves that travel toward the other end. However, besides a simple linear motion, the taut string can also conduct other kinds of oscillations: the motion could, for example, be clockwise or counter-clockwise and in a circular or elliptical shape. All of these possibilities exist analogously in the case of light. Curiously, this additional polarization state of light is essentially imperceptible to humans without additional aids like specialized cameras or polarizing sunglasses. In `pbrt`, we will therefore make the common assumption that light is unpolarized—that is, a superposition of waves with many different polarizations so that only their average behavior is perceived. Therefore, the only relevant property of light is its distribution by wavelength (or, equivalently, frequency).
][
  - #emph[无偏振（No Polatization）：];包括可见光在内的电磁辐射是#emph[偏振];的。一个形象的类比是沿着拉紧的琴弦传播的振动。晃动琴弦一端会产生垂直方向的波动向另一端传播。然而，除了简单的线性振动外，琴弦还能够传导其他形式的振动，如顺时针或逆时针的圆形或椭圆形振动。光的偏振行为也存在类似的情况。然而，人类在没有辅助工具（如偏振滤镜或偏振墨镜）的情况下，基本无法直接感知这种额外的偏振状态。因此，在 `pbrt` 中，我们采用一种常见的假设，即光是非偏振光，即由多种偏振方向的波叠加而成，人眼仅能感知其平均行为。因此，光的唯一相关属性是其波长分布（或等效的频率分布）。
]

#parec[
  - #emph[No fluorescence or phosphorescence:] The behavior of light at one wavelength is completely independent of light's behavior at other wavelengths or times. As with polarization, it is not too difficult to include these effects if they are required.
][
  - #emph[无荧光与磷光（No Fluorescence or Phosphorescence）：]某一波长下的光行为完全独立于其他波长或时间上的光行为。与偏振现象类似，如果需要，也并不难在渲染中引入这些效应。
]

#parec[
  - #emph[Steady state:] Light in the environment is assumed to have
    reached equilibrium, so its radiance distribution is not changing over
    time. This happens nearly instantaneously with light in realistic
    scenes, so it is not a limitation in practice. Note that
    phosphorescence also violates the steady-state assumption.
][
  - #emph[稳态（Steady State）：]假设环境中的光已经达到平衡状态，其辐射亮度分布随时间不再变化。在现实场景中，光传播到平衡状态几乎是瞬间完成的，因此这一假设在实践中不构成限制。不过需要注意，磷光现象也违反了稳态假设。#translator[荧光进入稳态的时间非常短，一般在纳秒级（$10^"-9"$秒），光源移除后几乎立即停止发光；而磷光进入稳态的时间较长，可能持续从几秒到数小时甚至更久，因为电子处于亚稳态（三重态），回到基态的速率较慢，导致光的释放延迟。]
]

#parec[
  The most significant loss from adopting a geometric optics model is the incompatibility with diffraction and interference effects. Even though this incompatibility can be circumvented—for example, by replacing radiance with the concept of a #emph[Wigner distribution function] (@oh2010 , @Cuypers2012)—such extensions are beyond the scope of this book.
][
  采用几何光学模型（Geometric Optics Model）带来的最显著限制是其与衍射（Diffraction）和干涉（Interference）效应的不兼容性。即使这种不兼容性可以被规避——例如，通过用#emph[维格纳分布函数（Wigner Distribution Function）];（@oh2010，@Cuypers2012）替代辐射亮度，但此类扩展超出了本书的讨论范围。
]

=== Basic Quantities
<basic-quantities>
#parec[
  There are four radiometric quantities that are central to rendering: flux, irradiance / radiant exitance, intensity, and radiance. They can each be derived from energy by successively taking limits over time, area, and directions. All of these radiometric quantities are in general wavelength dependent, though we will defer that topic until @radiometric-spectral-distributions.
][
  有四个辐射度量学量是渲染的核心：通量（Flux）、辐照度/辐射出射度（Irradiance / Radiant Exitance）、强度（Intensity）和辐射亮度（Radiance）。
  它们可以通过依次对时间、面积和方向取极限，从能量中推导出来。
  所有这些辐射度量学量通常都依赖于波长，尽管我们会将这一话题推迟到 @radiometric-spectral-distributions 部分讨论。#translator[依据中国国家标准 GB3102.6-93 ，这些量的名称大都可以省略“射”字，例如“辐射出射度”也可以称作“辐射出度”、“辐出射度”或“辐出度”，以此类推。后续译文将视情况使用全称或简称。]
]

==== Energy
<energy>
#parec[
  Our starting point is energy, which is measured in joules (`J`).
  Sources of illumination emit photons, each of which is at a particular wavelength and carries a particular amount of energy.
  All the basic radiometric quantities are effectively different ways of measuring photons.
  A photon at wavelength $lambda$ carries energy

  $ Q= (h c) / lambda , $

  where $c$ is the speed of light, $299,472,458 m \/ s$, and $h$ is Planck's constant, $h approx 6 . 626 times 10^(-34) thin("m")^2 thin "kg/s"$.
][
  我们的出发点是能量（Energy），其单位为焦耳（$J$）。
  光源通过发射光子（Photon）产生照明，每个光子对应一个特定的波长，并携带一定量的能量。
  所有的基本辐射度量学量本质上都是测量光子数量的不同方式。
  波长为 $lambda$ 的一个光子携带能量为

  $ Q= (h c) / lambda , $

  其中 $c$ 是光速， $299,472,458 m \/ s$， $h$ 是普朗克常数（Planck's Constant），其值 $h approx 6 . 626 times 10^(-34) thin("m")^2 thin "kg/s"$ 。
]

==== Flux
<sec:flux>
#parec[
  Energy measures work over some period of time, though under the steady-state assumption generally used in rendering, we are mostly interested in measuring light at an instant. #emph[Radiant flux];, also known as #emph[power];, is the total amount of energy passing through a surface or region of space per unit time. Radiant flux can be found by taking the limit of differential energy per differential time:
][
  能量（Energy）用于测量在一段时间内完成的功，然而在渲染中通常使用的稳态假设（Steady-State Assumption）下，我们主要关注的是某一瞬间的光量测量。
  #emph[辐射通量（Radiant Flux）];，也称为#emph[功率（Power）];，表示单位时间内通过一个表面或空间区域的总能量。
  辐射通量可以通过对微分能量随微分时间的极限求解得到：
]

$
  Phi = lim_(Delta t arrow.r 0) frac(Delta Q, Delta t) = frac(d Q, d t) .
$
#parec[
  Its units are joules/second ($J \/ s$), or more commonly, watts ($W$).
][
  其单位是焦耳/秒（$J \/ s$），更常见的是瓦特（$W$）。
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
  请注意，我们这里的符号稍微有些不正式。其中一个原因是，光子是离散的能量量子，因此在微分时间趋近于零时取极限并不严格符合物理实际。然而，在渲染的情况下，由于我们关注的测量尺度远大于单个光子的数量级，这个细节并不会造成问题。
]

#parec[
  Total emission from light sources is generally described in terms of flux.
  @fig:flux shows flux from a point light source measured by the total amount of energy passing through imaginary spheres around the light.
  Note that the total amount of flux measured on either of the two spheres in @fig:flux is the same—although less energy is passing through any local part of the large sphere than the small sphere, the greater area of the large sphere means that the total flux is the same.
][
  光源的总辐射通常用辐射通量（Flux）来描述。
  @fig:flux 展示了从一个点光源发出的通量，其测量方式是计算通过围绕光源的假想球面的总能量。
  需要注意的是，在 @fig:flux 中，无论是小球面还是大球面，测得的总通量都是相同的——尽管较大的球体上的任意局部区域通过的能量较少，但由于球面的面积更大，总通量依然保持不变。
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
  任何关于通量（Flux）的测量都需要一个用于计算单位时间内光子数量的面积。
  给定一个有限面积 $A$ ，我们可以定义该面积上的平均功率密度为 $E = Phi \/ A$ 。
  这个量要么是 #emph[辐照度（E）]，即到达表面的通量的面积密度，要么是#emph[辐射出射度（M）]，即离开表面的通量的面积密度。
  这些测量的单位是 W/m $""^2$。（术语#emph[辐照度];有时也用于指离开表面的通量，但为了清晰起见，我们将在两种情况下使用不同的术语。）
]

#parec[
  For the point light source example in Figure @fig:flux, irradiance at a point on the outer sphere is less than the irradiance at a point on the inner sphere, since the surface area of the outer sphere is larger. In particular, if the point source is emitting the same amount of illumination in all directions, then for a sphere in this configuration that has radius $r$,
][
  对于 @fig:flux 中的点光源示例，外球面上某点的辐照度（Irradiance）小于内球面上对应点的辐照度，这是因为外球面的表面积更大。特别是，如果点光源在所有方向上均匀发光，那么对于半径为 $r$ 的球面，辐照度可以表示为
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
  The irradiance equation can also help us understand the origin of #emph[Lambert's law];, which says that the amount of light energy arriving at a surface is proportional to the cosine of the angle between the light direction and the surface normal @fig:irradiance .
  Consider a light source with area $A$ and flux $Phi$ that is illuminating a surface.
  If the light is shining directly down on the surface (as on the left side of the figure), then the area on the surface receiving light $A_1$ is equal to $A$.
  Irradiance at any point inside $A_1$ is then
][
  辐照度方程还可以帮助我们理解#emph[朗伯定律];的起源。
  该定律指出，到达表面的光能量与光的入射方向和表面法线之间角度的余弦成正比（@fig:irradiance ）。
  考虑一个面积为 $A$ 、通量为 $Phi$ 的光源照射在一个表面上。
  如果光直接照射在表面上（如图左侧所示），那么接收光的表面面积 $A_1$ 等于 $A$ 。在 $A_1$ 内的任何点的辐照度为
]

$ E_1 = Phi / A $

#parec[
  However, if the light is at an angle to the surface, the area on the surface receiving light is larger. If $A$ is small, then the area receiving flux, $A_2$, is roughly $A \/ cos theta$. For points inside $A_2$, the irradiance is therefore
][
  然而，如果光源和表面有倾角，则接收光的表面面积更大。
  如果 $A$ 很小，那么接收通量的面积 $A_2$ 大约为 $A \/ cos theta$ 。
  对于 $A_2$ 内的点，辐照度因此为
]

$ E_2 = frac(Phi cos theta, A) $

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f02.svg"),
  caption: [#ez_caption[*Lambert's Law*. Irradiance arriving at a surface varies according to the cosine of the angle of incidence of illumination, since illumination is over a larger area at larger incident angles.][*朗伯定律*。到达表面的辐照度随着入射光的角度的余弦变化，因为在更大的入射角度有更大的照射区域。]
  ],
) <irradiance>


==== Intensity
<intensity>

#parec[
  Consider now an infinitesimal light source emitting photons. If we center this light source within the unit sphere, we can compute the angular density of emitted power. #emph[Intensity];, denoted by $I$, is this quantity; it has units $W \/ s r$. Over the entire sphere of directions, we have
][
  现在考虑一个无限小的光源，其以各个方向发射光子。
  如果将这个光源放置在单位球体的中心，我们可以计算其辐射功率在角度上的密度。
  这一物理量被称为#emph[强度（Intensity）]，用符号 $I$ 表示，单位为瓦特每立体角（$W \/ "sr"$）。
  对于球面的所有方向，总辐射功率可表示为
]

$ I = Phi / (4 pi) $

#fake-par

#parec[
  but more generally we are interested in taking the limit of a differential cone of directions:
][
  更一般地，如果我们感兴趣的是沿着一个微分立体角（Differential Solid Angle）的辐射功率密度，则可定义强度为：
]

$ I = lim_(Delta omega arrow.r 0) frac(Delta Phi, Delta omega) = frac(d Phi, d omega) . $

#fake-par

#parec[
  As usual, we can go back to power by integrating intensity: given intensity as a function of direction $I(omega)$, we can integrate over a finite set of directions $Omega$ to recover the power:
][
  像往常一样，我们可以通过对强度进行积分来求得辐射通量（功率）。
  已知强度 $I(omega)$ 是方向 $omega$ 的函数，我们可以在一个有限的方向集合 $Omega$ 上进行积分，从而恢复出对应的辐射通量（功率）：
]

$
  Phi = integral_Omega I(omega) d omega .
$ <power-from-radiant-intensity>

#fake-par

#parec[
  Intensity describes the directional distribution of light, but it is only meaningful for point light sources.
][
  强度用于描述光的方向分布，但它仅对点光源有物理意义。
]

==== Radiance

#parec[
  The final, and most important, radiometric quantity is #emph[radiance];, L. Irradiance and radiant exitance give us differential power per differential area at a point p, but they do not distinguish the directional distribution of power. Radiance takes this last step and measures irradiance or radiant exitance with respect to solid angles. It is defined by
][
  最后也是最重要的辐射量是#emph[辐射亮度（Radiance）];#translator[辐射亮度也成为辐亮度、辐射度。]，用符号 $L$ 表示。
  辐照度（Irradiance）和辐射出射度（Radiant Exitance）描述了点 $p$ 处的单位面积微分功率，但它们并未区分功率的方向分布。
  辐射亮度进一步引入了方向维度，测量了相对于立体角的辐照度或辐射出射度。
  它的定义是
]

$
  L(p, omega) = lim_(Delta omega arrow.r 0) frac(Delta E_omega (p), Delta omega) = frac(d E_omega (p), d omega),
$

#parec[
  where we have used $E_(omega)$ to denote irradiance at the surface that is perpendicular to the direction.
  In other words, radiance is not measured with respect to the irradiance incident at the surface p lies on.
  In effect, this change of measurement area serves to eliminate the $cos theta$ factor from Lambert's law in the definition of radiance.
][
  其中，$E_omega$ 表示在垂直于方向 $omega$ 的表面上的辐照度（Irradiance）。
  换句话说，辐射亮度（Radiance）并不是相对于点 $p$ 所在表面接收到的辐照度进行测量的。
  实际上，这种测量面积的变化消除了辐射度定义中朗伯定律的 $cos theta$ 因子。
]

#parec[
  Radiance is the flux density per unit area, per unit solid angle.
  In terms of flux, it is defined by
][
  辐射亮度（Radiance）是单位面积、单位立体角内的通量密度。
  用通量的角度定义为：
]

$
  L = frac(d^2 Phi, d omega thin d A^perp),
$ <eqt-radiance>

#parec[
  where $d A^(perp)$ is the projected area of $d A$ on a hypothetical surface perpendicular to $omega$ ( @fig:pha04f03 ). Thus, it is the limit of the measurement of incident light at the surface as a cone of incident directions of interest $d omega$ becomes very small and as the local area of interest on the surface $d A$ also becomes very small.
][
  其中，$d A ^ perp$ 表示微分面积 $d A$ 在垂直于方向 $omega$ 的假想表面上的投影面积（见 @fig:pha04f03 ）。
  因此，辐射亮度可以理解为，当感兴趣的入射方向立体角 $d omega$ 变得极小时，以及表面的局部微分面积 $d A$ 也趋于极小时，对表面上入射光的测量极限。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f03.svg"),
  caption: [
    #ez_caption[Radiance $L$ is defined as flux per unit solid angle $d omega$ per unit projected area $d A^(perp)$.][辐亮度L是每单位面积$d omega$和每单位立体角$d A^(perp)$的通量密度。]
  ],
) <pha04f03>

#fake-par

#parec[
  Of all of these radiometric quantities, radiance will be the one used most frequently throughout the rest of the book.
  An intuitive reason for this is that in some sense it is the most fundamental of all the radiometric quantities; if radiance is given, then all the other values can be computed in terms of integrals of radiance over areas and directions.
  Another nice property of radiance is that it remains constant along rays through empty space.
  It is thus a natural quantity to compute with ray tracing.
][
  在所有这些辐射度量量中，辐射亮度（Radiance）将是本书余下部分中使用最频繁的一个。
  这种频繁使用的直观原因在于，辐射亮度在某种意义上是最基本的辐射度量量之一。
  如果已知辐射亮度，则所有其他辐射度量量都可以通过对辐射亮度在面积和方向上的积分计算得到。
  辐射亮度的另一个优良性质是，在真空（空旷空间）中沿光线传播时，它保持不变。
  因此，辐射亮度非常适合用于光线追踪（Ray Tracing）的计算，是描述光传播的自然选择。
]

=== Incident and Exitant Radiance Functions
#parec[
  When light interacts with surfaces in the scene, the radiance function L is generally not continuous across the surface boundaries.
  In the most extreme case of a fully opaque surface (e.g., a mirror), the radiance function slightly above and slightly below a surface could be completely unrelated.
][
  当光与场景中的表面交互时，辐亮度函数 $L$ 通常在表面边界上不连续。
  在最极端的情况下，如完全不透明的表面（例如镜子），表面上方和下方的辐亮度函数可能完全无关。
]

#parec[
  It therefore makes sense to take one-sided limits at the discontinuity to distinguish between the radiance function just above and below
][
  因此，在不连续处取单侧极限以区分表面上方和下方的辐亮度函数是合理的：
]

$
  L^+ (p, omega) & = lim_(t arrow.r 0^+) L(p + t n_p, omega),\
  L^- (p, omega) & = lim_(t arrow.r 0^-) L(p + t n_p, omega) .
$ <radiance-limits-onesided>
#parec[
  where $bold(n)_p$ is the surface normal at $p$. However, keeping track of one-sided limits throughout the text is unnecessarily cumbersome.
][
  其中 $bold(n)_p$ 是点 $p$ 处的表面法线。
  然而，在本书中不需要繁琐的计算单侧极限。
]

#parec[
  We prefer to solve this ambiguity by making a distinction between radiance arriving at the point (e.g., due to illumination from a light source) and radiance leaving that point (e.g., due to reflection from a surface).
][
  我们倾向于通过区分到达该点的辐射亮度（如由光源照射产生的入射光）与从该点离开的辐射亮度（如表面反射产生的出射光）来消除这种歧义。
]

#parec[
  Consider a point $p$ on the surface of an object.
  There is some distribution of radiance arriving at the point that can be described mathematically by a function of position and direction. This function is denoted by $L_(i)(p, omega)$ (@fig:radiance-incident-exitant). The function that describes the outgoing reflected radiance from the surface at that point is denoted by $L_(o)(p, omega)$. Note that in both cases the direction vector $omega$ is oriented to point away from $p$, but be aware that some authors use a notation where $omega$ is reversed for $L_(i)$ terms so that it points toward $p$.
][
  考虑物体表面上的一个点 $p$。
  到达该点的辐射度分布可以通过一个位置和方向的函数来描述。
  这个函数表示为 $L_(i)(p, omega)$ （见 @fig:radiance-incident-exitant ）。
  描述该点处表面反射的出射辐射度的函数表示为 $L_(o)(p, omega)$。请注意，在这两种情况下，方向向量 $omega$ 都指向远离 $p$，但需要注意的是，一些作者使用的符号中， $L_(i)$ 项中的 $omega$ 是反向的，因此它指向 $p$。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f04.svg"),
  caption: [#ez_caption[(a) The incident radiance function $L_(i)(p,  omega)$ describes the distribution of radiance arriving at a point as a function of position and direction. (b) The exitant radiance function $L_(o)(p,  omega)$ gives the distribution of radiance leaving the point. Note that for both functions, $omega$ is oriented to point away from the surface, and thus, for example, $L_(i)(p, -omega)$ gives the radiance arriving on the other side of the surface than the one where $omega$ lies.][(a) 入射辐射亮度函数（Incident Radiance Function） $L_(i)(p, omega)$ 描述了到达某点的辐射度分布，作为位置和方向的函数。 (b) 出射辐射亮度函数（Exitant Radiance Function） $L_(o)(p, omega)$ 给出了离开该点的辐射度分布。请注意，对于这两个函数，方向 $omega$ 都被定义为指向远离表面的方向。因此，例如 $L_(i)(p, -omega)$ 表示的是从与 $omega$ 所在表面相对一侧入射到点 $p$ 的辐射亮度。]],
) <radiance-incident-exitant>

#fake-par

#parec[
  There is a simple relation between these more intuitive incident and exitant radiance functions and the one-sided limits from @eqt:radiance-limits-onesided:
][
  在这些更直观的入射与出射辐射亮度函数之间，存在一个简单的关系，它们可以通过@eqt:radiance-limits-onesided 中的单侧极限描述为：
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

#fake-par

#parec[
  Throughout the book, we will use the idea of incident and exitant radiance functions to resolve ambiguity in the radiance function at boundaries.
][
  在本书中，我们将使用入射与出射辐射亮度函数的概念，以消除在边界处描述辐射亮度时的歧义。
]

#parec[
  Another property to keep in mind is that at a point in space where there is no surface (i.e., in free space), $L$ is continuous, so $L^+ = L^-$ , which means
][
  另一个需要牢记的性质是，在空间中没有表面的点（即自由空间内），辐射亮度 $L$ 是连续的，因此 $L^+ = L^-$ ，这意味着
]

$
  L_o (p, omega) = L_i (p, - omega) = L(p, omega)
$

#fake-par

#parec[
  In other words, $L_(i)$ and $L_o$ only differ by a direction reversal.
][
  换句话说， $L_(i)$ and $L_o$ 仅在方向上相反。
]

=== Radiometric Spectral Distributions
<radiometric-spectral-distributions>

#parec[
  Thus far, all the radiometric quantities have been defined without considering variation in their distribution over wavelengths.
  They have therefore effectively been the integrals of wavelength-dependent quantities over an (unspecified) range of wavelengths of interest. Just as we were able to define the various radiometric quantities in terms of limits of other quantities, we can also define their spectral variants by taking their limits over small wavelength ranges.
][
  到目前为止，我们定义的所有辐射度量学量都没有考虑它们在波长上的分布变化。
  因此，它们实际上是对某个（未明确说明的）波长范围内的波长依赖量的积分。
  正如我们能够通过其他物理量的极限来定义各种辐射度量学量一样，我们也可以通过对小波长区间的极限处理，定义它们的光谱形式（Spectral Variants）。
  例如，我们可以定义光谱辐射亮度（Spectral Radiance） $L_lambda$ ，其为辐射亮度在一个无限小波长区间 $Delta lambda$ 上的极限表达式。
]

#parec[
  For example, we can define #emph[spectral radiance] $L_lambda$ as the limit of radiance over an infinitesimal interval of wavelengths $Delta lambda$,
][
  例如，我们可以定义#emph[光谱辐射亮度（Spectral Radiance）] $L_lambda$ ，其为辐射亮度在一个无限小波长区间 $Delta lambda$ 上的极限：
]

$
  L_lambda = lim_(Delta lambda arrow.r 0) frac(Delta L, Delta lambda) = frac(d L, d lambda)
$

#fake-par

#parec[
  In turn, radiance can be found by integrating spectral radiance over a range of wavelengths:
][
  进一步地，辐射亮度可以通过对光谱辐射亮度在某个波长范围上的积分来求得：
]

$
  L = integral_(lambda_0)^(lambda_1) L_lambda (lambda) thin d lambda
$ <radiance-from-spectral>

#fake-par

#parec[
  Definitions for the other radiometric quantities follow similarly.
  All of these spectral variants have an additional factor of $1\/m$ in their units.
][
  其他辐射度量学量的光谱形式也可以以类似方式定义。
  所有这些光谱变体的单位中都多了一个 $1\/m$ 因子，以反映波长的依赖性。
]

=== Luminance and Photometry
<luminance-and-photometry>
#parec[
  All the radiometric measurements like flux, radiance, and so forth have corresponding photometric measurements.
  #emph[Photometry] is the study of visible electromagnetic radiation in terms of its perception by the human visual system.
  Each spectral radiometric quantity can be converted to its corresponding photometric quantity by integrating against the spectral response curve $V(lambda)$, which describes the relative sensitivity of the human eye to various wavelengths.
  #footnote[The spectral response curve model is based on experiments done in a normally illuminated indoorenvironment. Because sensitivity to color decreases in dark environments, it does not model the human visual system's response well under all lighting situations. Nonetheless, it forms the basis for the definition of luminance and other related photometric properties.]
][
  所有辐射度量量（如通量、辐射亮度等）都有其对应的光度量（Photometric Measurements）。
  #emph[光度学（Photometry）];是研究可见电磁辐射与人类视觉系统感知之间关系的学科。
  每个光谱辐射度量量都可以通过与光谱响应曲线 $V(lambda)$ 积分转换为对应的光度量，该曲线描述了人眼对不同波长的相对敏感度。
  #footnote[光谱响应曲线模型基于在正常照明的室内环境中进行的实验。由于在黑暗环境下人眼对颜色的敏感度会降低，因此该模型不能很好地描述所有光照条件下的人类视觉响应。然而，它仍然构成了亮度（Luminance）及其他相关光度量定义的基础。]
]

#parec[
  #emph[Luminance] measures how bright a spectral power distribution appears to a human observer. For example, luminance accounts for the fact that a spectral distribution with a particular amount of energy in the green wavelengths will appear brighter to a human than a spectral distribution with the same amount of energy in blue.
][
  #emph[亮度（Luminance）];用于衡量人类观察者感知到的光谱功率分布的明亮程度。
  例如，相同能量下，绿色波段的光在人眼中比蓝色波段更明亮。
]

#parec[
  We will denote luminance by $Y$ ; it is related to spectral radiance by
][
  我们将用 $Y$ 表示亮度，其与光谱辐射亮度（Spectral Radiance）的关系为：
]


$ Y = integral_lambda L_lambda (lambda) V (lambda) thin d lambda $ <luminance>

#fake-par

#parec[
  Luminance and the spectral response curve $V (lambda)$ are closely related to the XYZ representation of color, which will be introduced in @xyz-color .
][
  亮度和光谱响应曲线 $V (lambda)$ 密切相关，这也是XYZ颜色表示法的基础，相关内容将在 @xyz-color 介绍。
]

#parec[
  The units of luminance are candelas per meter squared ( $upright("cd/m")^2$ ), where the candela is the photometric equivalent of radiant intensity. Some representative luminance values are given in @tbl:luminance-values.
][
  亮度的单位是坎德拉每平方米（ $upright("cd/m")^2$ ），其中坎德拉（Candela）是辐射强度（Radiant Intensity）的光度学等效单位。一些具有代表性的亮度值将在 @tbl:luminance-values 给出。
]

#figure(
  table(
    stroke: none,
    columns: 2,
    table.hline(),
    [情景], [亮度（Luminance）（$c d\/m^2$ 或 尼特）],
    table.hline(stroke: .5pt),
    [太阳在地平线附近], [600,000 ],
    [60瓦灯泡], [ 120,000 ],
    [晴朗的天空], [ 8,000 ],
    [典型办公室照明], [ 100-1,000 ],
    [典型计算机显示器], [ 1-100 ],
    [街道照明], [ 1-10 ],
    [多云的月光], [ 0.25 ],
    table.hline(),
  ),
  caption: [
    #ez_caption[Representative Luminance Values for a Number of Lighting Conditions. ][多种照明情景的典型亮度值。]
  ],
)<luminance-values>

#parec[
  All the other radiometric quantities that we have introduced in this chapter have photometric equivalents; they are summarized in @tbl:radiometric-photometric.#footnote[The various photometric quantities have fairly unusual names; the somewhat confusing state of affairs was nicely summarized by Jim Kajiya: “Thus one nit is one lux per steradian is one candela per square meter is one lumen per square meter per steradian. Got it?”]
][
  本章介绍的所有其他辐射度量量（Radiometric Quantities）都有其对应的光度量（Photometric Equivalents），它们总结在 @tbl:radiometric-photometric 表格里。#footnote[各类光度量的命名相对不太直观且容易混淆。吉姆·卡吉亚（Jim Kajiya）对此曾有过幽默的总结：“一尼特（nit）是每球面度上的一勒克斯（lux），是每平方米上的一坎德拉（candela per square meter），是每平方米每球面度上的一流明（lumen per square meter per steradian）。明白了吗？”]
]

#figure(
  align(center)[#table(
      stroke: none,
      columns: (20%, 17%, 27%, 33.33%),
      align: (auto, auto, auto, auto),
      table.hline(),
      table.header([辐射度量 (Radiometric)], [单位], [光度量 (Photometric)], [单位]),
      table.hline(stroke: .5pt),
      [辐射能量 (Radiant Energy)], [焦耳 (J)], [光能量 (Luminous Energy)], [塔尔博 (Talbot, T)],
      [辐射通量 (Radiant Flux)], [瓦特 (W)], [光通量 (Luminous Flux)], [流明 (Lumen, lm)],
      [强度 (Intensity)], [$W\/s r$], [光强度 (Luminous Intensity)], [$"lm"\/s r = "candela" (c d)$],
      [辐照度 (Irradiance)], [$W \/ m^2$], [照度 (Illuminance)], [$"lm"\/m^2 = "lux" (l x)$],
      [辐射亮度 (Radiance)], [$W\/(m^2 dot s r)$], [亮度 (Luminance)], [$"lm"\/(m^2 dot "sr") = "cd"\/m^2 = "nit"$],
      table.hline(),
    )],
  kind: table,
  caption: [#ez_caption[Radiometric Measurements and Their Photometric Analogs. ][辐射测量及其光度学对应量。]
  ],
) <radiometric-photometric>
