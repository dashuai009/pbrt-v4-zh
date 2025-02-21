#import "../template.typ": parec, ez_caption

== The Equation of Transfer
<the-equation-of-transfer>


#parec[
  The equation of transfer is the fundamental equation that governs the behavior of light in a medium that absorbs, emits, and scatters radiation. It accounts for all the volume scattering processes described in @volume-scattering —absorption, emission, in scattering, and out scattering—to give an equation that describes the equilibrium distribution of radiance. The light transport equation is in fact a special case of it, simplified by the lack of participating media and specialized for scattering from surfaces. (We will equivalently refer to the equation of transfer as the _volumetric light transport equation_.)
][
  传输方程是描述光在吸收、发射和散射辐射的介质中行为的基本方程。它考虑了@volume-scattering 中描述的所有体积散射过程——吸收、发射、入射散射和出射散射——以给出描述辐亮度平衡分布的方程。光传输方程实际上是传输方程的一个特例，通过缺少参与介质并专门用于表面散射而简化。（我们将等效地将传输方程称为_体积光传输方程_。）
]

#parec[
  In its most basic form, the equation of transfer is an integro-differential equation that describes how the radiance along a beam changes at a point in space. It can be derived by subtracting the effects of the scattering processes that reduce energy along a beam (absorption and out scattering) from the processes that increase energy along it (emission and in scattering).
][
  在其最基本的形式中，传输方程是一个积分-微分方程，描述了沿光束的辐亮度在空间中某一点如何变化。它可以通过将减少光束能量的散射过程（吸收和出射散射）与增加光束能量的过程（发射和入射散射）相减来推导。
]

#parec[
  To start, recall the source function $L_s$ from @in-scattering: it gives the change in radiance at a point $p$ in a direction $omega$ due to emission and in-scattered light from other points in the medium:
][
  首先，回忆@in-scattering 中的源函数 $L_s$ ：它给出了由于介质中其他点的发射和入射散射光导致在方向 $omega$ 上点 $p$ 的辐亮度变化：
]

$
  L_s (p , h e t a) = frac(sigma_a (p , omega), sigma_t (p , omega)) L_e ( p , omega ) + frac(sigma_s (p , omega), sigma_t (p , omega)) integral_(S^2) p (p , omega_i , omega) L_i ( p , omega_i ) thin d omega_i .
$


#parec[
  The source function accounts for all the processes that add radiance to a ray.
][
  源函数考虑了所有增加光线辐亮度的过程。
]

#parec[
  The attenuation coefficient, $sigma_t (p , omega)$, accounts for all processes that reduce radiance at a point: absorption and out scattering. The differential equation that describes its effect, @eqt:volume-attenuation-differential, is
][
  衰减系数 $sigma_t (p , omega)$ 考虑了在某一点减少辐亮度的所有过程：吸收和出射散射。描述其效应的微分方程是@eqt:volume-attenuation-differential：
]

$ d L_o (p , omega) = - sigma_t (p , omega) L_i (p , - omega) thin d t . $

#parec[
  The overall differential change in radiance at a point $p prime = p + t omega$ along a ray is found by adding these two effects together to get the integro-differential form of the equation of transfer:#footnote[It is an integro-differential
equation due to the integral over the sphere in the source function.]
][
  沿光线在点 $p prime = p + t omega$ 处的辐亮度总微分变化是通过将这两种效应相加得到传输方程的积分-微分形式：#footnote[It is an integro-differential
equation due to the integral over the sphere in the source function.]
]

$
  frac(partial, partial t) L_o (p prime , omega) = - sigma_t (p prime , omega) L_i (p prime , - omega) + sigma_t ( p prime , omega ) L_s (p prime , omega) .
$<eot-differential>

#parec[
  (The $sigma_t$ modulation of the source function accounts for the medium's density at the point.)
][
  （源函数的 $sigma_t$ 调制考虑了该点的介质密度。）
]

#parec[
  With suitable boundary conditions, this equation can be transformed to a pure integral equation that describes the effect of participating media from the infinite number of points along a ray. For example, if we assume that there are no surfaces in the scene so that the rays are never blocked and have an infinite length, the integral equation of transfer is
][
  在适当的边界条件下，该方程可以转化为一个纯积分方程，描述沿光线无限多个点的参与介质的效应。例如，如果我们假设场景中没有表面，因此光线永远不会被阻挡并具有无限长度，则传输的积分方程为
]

$
  L_i (p , omega) = integral_0^oo T_r (p prime arrow.r p) sigma_t (p prime , omega) L_s (p prime , - omega) thin d t .
$

#parec[
  (See @fig:eot-infinite.) The meaning of this equation is reasonably intuitive: it just says that the radiance arriving at a point from a given direction is determined by accumulating the radiance added at all points along the ray. The amount of added radiance at each point along the ray that reaches the ray's origin is reduced by the beam transmittance to the point.
][
  （见@fig:eot-infinite。）这个方程的意义是相当直观的：它只是说，从给定方向到达某一点的辐亮度是通过累积沿光线所有点增加的辐亮度来确定的。沿光线每一点增加的辐亮度在到达光线起点时被光束透过率减弱。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f01.svg"),
  caption: [
    #ez_caption[
      The equation of transfer gives the incident radiance at point $L_i (p, omega)$ accounting for the effect of participating media. At each point $p'$ along the ray, the source function $L_s (p', -omega)$ gives the differential radiance added at the point due to scattering and emission. This radiance is then attenuated by the beam transmittance $T_r (p' -> p)$ from the point $p'$ to the ray’s origin.
    ][
      转移方程描述了考虑参与介质影响下某点的入射辐射度 $L_i (p, omega)$。沿射线上的每个点 $p'$，源函数 $L_s (p', -omega)$ 表示由于散射和发射在该点增加的微分辐射度。然后，这种辐射度通过从点 $p'$ 到射线起点的光束透过率 $T_r (p' -> p)$ 进行衰减。
    ]
  ],
)<eot-infinite>

#parec[
  More generally, if there are reflecting or emitting surfaces in the scene, rays do not necessarily have infinite length and the first surface that a ray hits affects its radiance, adding outgoing radiance from the surface at the point and preventing radiance from points along the ray beyond the intersection point from contributing to radiance at the ray's origin. If a ray $(p , omega)$ intersects a surface at some point $p_s$ at a parametric distance $t$ along the ray, then the integral equation of transfer is
][
  更一般地，如果场景中有反射或发射表面，光线不一定具有无限长度，光线碰到的第一个表面会影响其辐亮度，从而在该点增加来自表面的出射辐亮度，并防止光线交点之外的点对光线起点的辐亮度贡献。如果光线 $(p , omega)$ 在沿光线的参数距离 $t$ 处与表面相交于点 $p_s$，则传输的积分方程为
]


$
  L_i (p , omega) = T_r (p_s arrow.r p) L_o (p_s , - omega) + integral_0^t T_r (p prime arrow.r p) sigma_t ( p prime , omega ) L_s (p prime , - omega) thin d t prime ,
$<eot-general>

#parec[
  where $p prime = p + t prime omega$ are points along the ray (@fig:eot-finite).
][
  其中 $p prime = p + t prime omega$ 是沿射线的点（@fig:eot-finite）。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f02.svg"),
  caption: [
    #ez_caption[
      For a finite ray that intersects a surface, the incident radiance, $L_i (p, omega)$, is equal to the outgoing radiance from the surface, $L_o (p_s, -omega)$, times the beam transmittance to the surface plus the added radiance from all points along the ray from $p$ to $p_s$.
    ][
      对于与表面相交的有限射线，入射辐射度 $L_i (p, omega)$ 等于来自表面的出射辐射度 $L_o (p_s, -omega)$ 乘以到达表面的光束透过率，再加上从点 $p$ 到点 $p_s$ 沿射线上的所有点增加的辐射度。
    ]
  ],
)<eot-finite>

#parec[
  This equation describes the two effects that contribute to radiance along the ray. First, reflected radiance back along the ray from the surface is given by the $L_o$ term, which gives the emitted and reflected radiance from the surface. This radiance may be attenuated by the participating media; the beam transmittance from the ray origin to the point $p_s$ accounts for this. The second term accounts for the added radiance along the ray due to volumetric scattering and emission up to the point where the ray intersects the surface; points beyond that one do not affect the radiance along the ray.
][
  该方程描述了沿射线对辐射度贡献的两个效应。首先，从表面反射回射线的辐射度由 $L_o$ 项给出，它表示从表面发出的和反射的辐射度。这种辐射度可能会被介质衰减；从射线起点到点 $p_s$ 的光束透射率考虑了这一点。第二项考虑了由于体积散射和发射而沿射线增加的辐射度，直到射线与表面相交的点；超过该点的点不影响沿射线的辐射度。
]

=== Null-Scattering Extension

#parec[
  In @null-scattering we saw the value of null scattering, which made it possible to sample from a modified transmittance equation and to compute unbiased estimates of the transmittance between two points using algorithms like delta tracking and ratio tracking. Null scattering can be applied in a similar way to the equation of transfer, giving similar benefits.
][
  在@null-scattering 中，我们看到了零散射的价值，它使得可以从修改后的透射方程中采样，并使用如 delta 跟踪和比率跟踪等算法计算两点之间透射率的无偏估计。零散射可以以类似的方式应用于传输方程，带来类似的好处。
]

#parec[
  In order to simplify notation in the following, we will assume that the various scattering coefficients $sigma$ do not vary as a function of direction. As before, we will also assume that the null-scattering coefficient $sigma_n$ is nonnegative and has been set to homogenize the medium's density to a fixed majorant $sigma_(upright("maj")) = sigma_n + sigma_t$. Neither of these simplifications affect the course of the following derivations; both generalizations could be easily reintroduced.
][
  为了简化以下的符号，我们将假设各种散射系数 $sigma$ 不随方向变化。和以前一样，我们还将假设零散射系数 $sigma_n$ 是非负的，并已设置为将介质的密度均匀化为固定的主要量 $sigma_(upright("maj")) = sigma_n + sigma_t$。这些简化都不影响以下推导的过程，可以很容易地重新引入这两种推广。
]

#parec[
  A null-scattering generalization of the equation of transfer can be found using the relationship $sigma_t = sigma_(upright("maj")) - sigma_n$ from @eqt:sigman-from-sigmamaj. If that substitution is made in the integro-differential equation of transfer, @eqt:eot-differential, and the boundary condition of a surface at distance $t$ along the ray is applied, then the result can be transformed into the pure integral equation
][
  可以使用关系 $sigma_t = sigma_(upright("maj")) - sigma_n$ 从@eqt:sigman-from-sigmamaj 中找到传输方程的零散射推广。如果在传输的积分-微分方程中进行这种替换，@eqt:eot-differential，并应用沿射线距离为 $t$ 的表面的边界条件，则结果可以转化为纯积分方程
]

$
  L_i (p, omega) = & T_"maj" (p_s arrow.r p) L_o (p_s, - omega) + \
  & sigma_"maj" integral_0^t T_"maj" (p' arrow.r p) L_n (p', - omega) thin d t',
$<eot-null>

#parec[
  where $p prime = p + t prime omega$, as before, and we have introduced $T_(upright("maj"))$ to denote the #emph[majorant transmittance] that accounts for both regular attenuation and null scattering. Using the same convention as before that $d = parallel p - p prime parallel$ is the distance between points $p$ and $p prime$, it is
][
  其中 $p prime = p + t prime omega$，如前所述，我们引入 $T_(upright("maj"))$ 来表示#emph[主要透射率];，它考虑了常规衰减和零散射。使用与之前相同的约定，即 $d = parallel p - p prime parallel$ 是点 $p$ 和 $p prime$ 之间的距离，它是
]

$
  T_(upright("maj")) (p prime arrow.r p) = e^(integral_0^d - ( sigma_t (p + t omega) + sigma_n (p + t omega) ) thin d t) = e^(- sigma_(upright("maj")) d) .
$<majorant-transmittance>


#parec[
  The null-scattering source function $L_n$ is the source function $L_s$ from @eqt:volumetric-source-function plus a new third term:
][
  零散射源函数 $L_n$ 是@eqt:volumetric-source-function 中的源函数 $L_s$ 加上一个新的第三项：
]

$
  L_n (p, omega) = & frac(sigma_a (p), sigma_"maj") L_e (p, omega) + frac(sigma_s (p), sigma_"maj") integral_(S^2) p(p, omega_i, omega) L_i (p, omega_i) thin d omega_i \
  & + frac(sigma_n (p), sigma_"maj") L_i (p, omega) .
$<eot-lmaj>


#parec[
  Because it includes attenuation due to null scattering, $T_(upright("maj"))$ is always less than or equal to the actual transmittance. Thus, the product $T_(upright("maj")) L_o$ in @eqt:eot-null may be less than the actual contribution of radiance leaving the surface, $T_r L_o$. However, any such deficiency is made up for by the last term of @eqt:eot-lmaj.
][
  由于考虑了虚散射引起的衰减， $T_(upright("maj"))$ 总是小于或等于实际透射率。因此，在 @eqt:eot-null 中，乘积 $T_(upright("maj")) L_o$ 可能小于离开表面的辐射亮度的实际贡献 $T_r L_o$。然而，任何此类不足都由@eqt:eot-lmaj 的最后一项进行补偿。
]

=== Evaluating the Equation of Transfer
<evaluating-the-equation-of-transfer>
#parec[
  The $T_(upright("maj"))$ factor in the null-scattering equation of transfer gives a convenient distribution for sampling distances $t$ along the ray in the medium that leads to the volumetric path-tracing algorithm, which we will now describe. (The algorithm we will arrive at is sometimes described as using delta tracking to solve the equation of transfer, since that is the sampling technique it uses for finding the locations of absorption and scattering events.)
][
  虚散射传输方程中的 $T_(upright("maj"))$ 因子提供了一种便于在介质中沿射线采样距离 $t$ 的分布，这导致了体积路径追踪算法，我们现在将描述该算法。（我们将得到的算法有时被描述为使用 δ-追踪来解决传输方程，因为这是它用于寻找吸收和散射事件位置的采样技术。）
]

#parec[
  If we assume for now that there is no geometry in the scene, then the null-scattering equation of transfer, @eqt:eot-null, simplifies to
][
  如果我们暂时假设场景中没有几何体，那么虚散射传输方程，即@eqt:eot-null，简化为
]

$
  L_i (p , omega) = sigma_(upright("maj")) integral_0^oo T_(upright("maj")) (p prime arrow.r p) L_n ( p prime , - omega ) thin d t prime
$


#parec[
  Thanks to null scattering having made the majorant medium homogeneous, $sigma_(upright("maj")) T_(upright("maj"))$ can be sampled exactly. The first step in the path-tracing algorithm is to sample a point $p prime$ from its distribution, giving the estimator
][
  由于虚散射使得主要介质变得均匀， $sigma_(upright("maj")) T_(upright("maj"))$ 可以被精确采样。路径追踪算法的第一步是从其分布中采样一个点 $p prime$，给出估计器
]

$
  L_i ( p , omega ) approx frac(sigma_(upright("maj")) T_(upright("maj")) (p prime arrow.r p) L_n (p prime , - omega), p (p prime))
$


#parec[
  From Section A.4.2, we know that the probability density function (PDF) for sampling a distance $t$ from the exponential distribution $e^(- sigma_(upright("maj")) t)$ is $p (t) = sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$, and so the estimator simplifies to
][
  从附录A.4.2中，我们知道从指数分布 $e^(- sigma_(upright("maj")) t)$ 中采样距离 $t$ 的概率密度函数（PDF）为 $p (t) = sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$，因此估计器简化为
]

$ L_i (p , omega) approx L_n (p prime , - omega) . $<eot-estimator-after-t-sample>


#parec[
  What is left is to evaluate $L_n$.
][
  剩下的就是评估 $L_n$。
]

#parec[
  Because $sigma_(upright("maj")) = sigma_a + sigma_s + sigma_n$, the initial $sigma$ factors in each term of @eqt:eot-lmaj can be considered to be three probabilities that sum to 1. If one of the three terms is randomly selected according to its probability and the rest of the term is evaluated without that factor, the expected value of the result is equal to $L_n$. Considering how to evaluate each of the terms:
][
  因为 $sigma_(upright("maj")) = sigma_a + sigma_s + sigma_n$， @eqt:eot-lmaj 中每项的初始 $sigma$ 因子可以被视为三个概率之和为1。如果根据其概率随机选择其中一项并在没有该因子的情况下评估其余部分，结果的期望值等于 $L_n$。考虑如何评估每一项：
]

#parec[
  - If the $sigma_a$ term is chosen, then the emission at $L_e (p prime , omega)$ is returned and sampling terminates.
][
  - 如果选择 $sigma_a$ 项，则返回 $L_e (p prime , omega)$ 的发射并终止采样。
]

#parec[
  - For the $sigma_s$ term, the integral over the sphere of directions must be estimated. A direction $omega prime$ is sampled from some distribution and recursive evaluation of $L_i (p prime , omega prime)$ then proceeds, weighted by the ratio of the phase function and the probability of sampling the direction $omega prime$.
][
  - 对于 $sigma_s$ 项，必须估计方向球面上的积分。从某个分布中采样一个方向 $omega prime$，然后递归地评估 $L_i (p prime , omega prime)$，并按相函数与采样方向 $omega prime$ 的概率之比加权。
]

#parec[
  - If the null-scattering term is selected, $L_i (p prime , omega)$ is to be evaluated, which can be handled recursively as well.
][
  - 如果选择虚散射项，则评估 $L_i (p prime , omega)$，这也可以递归处理。
]

#parec[
  For the full equation of transfer that includes scattering from surfaces, both the surface-scattering term and the integral over the ray's extent lead to recursive evaluation of the equation of transfer. In the context of path tracing, however, we would like to only evaluate one of the terms in order to avoid an exponential increase in work. We will therefore start by defining a probability $q$ of estimating the surface-scattering term; volumetric scattering is evaluated otherwise. Given such a $q$, the Monte Carlo estimator
][
  对于包含表面散射的完整传输方程，表面散射项和射线范围上的积分都导致传输方程的递归评估。然而，在路径追踪的背景下，我们希望只评估其中一项以避免工作量的指数增长。因此，我们将首先定义一个估计表面散射项的概率 $q$ ；否则评估体积散射。给定这样的 $q$，蒙特卡罗估计器
]

$
  L_i ( p , omega ) approx cases(delim: "{",
   frac(T_(upright("maj")) (p_s arrow.r p) L_o (p_s , - omega), q) comma
     "with probability " q ,
      frac(sigma_(upright("maj")) integral_0^t T_(upright("maj")) (p prime arrow.r p) L_n (p prime , - omega) thin d t prime, 1 - q) comma
      "otherwise")
$


#parec[
  gives $L_i (p , omega)$ in expectation.
][
  给出 $L_i (p , omega)$ 的期望值。
]

#parec[
  A good choice for $q$ is that it be equal to $T_(upright("maj")) (p_s arrow.r p)$. Surface scattering is then evaluated with a probability proportional to the transmittance to the surface and the ratio $T_(upright("maj")) \/ q$ is equal to 1, leaving just the $L_o$ factor. Furthermore, a sampling trick can be used to choose between the two terms: if a sample $t prime in \[ 0 , oo \)$ is taken from $sigma_(upright("maj")) T_(upright("maj"))$ 's distribution, then the probability that $t prime > t$ is equal to $T_(upright("maj")) (p_s arrow.r p)$. (This can be shown by integrating $T_(upright("maj"))$ 's PDF to find its cumulative distribution function (CDF) and then considering the value of its CDF at $t$.) Using this technique and then making the same simplifications that brought us to @eqt:eot-estimator-after-t-sample, we arrive at the estimator
][
  一个好的 $q$ 选择是使其等于 $T_(upright("maj")) (p_s arrow.r p)$。然后以与到表面的透射率成比例的概率评估表面散射，并且比率 $T_(upright("maj")) \/ q$ 等于1，仅剩下 $L_o$ 因子。此外，可以使用采样技巧在两个项之间进行选择：如果从 $sigma_(upright("maj")) T_(upright("maj"))$ 的分布中取一个样本 $t prime in \[ 0 , oo \)$，则 $t prime > t$ 的概率等于 $T_(upright("maj")) (p_s arrow.r p)$。（这可以通过对 $T_(upright("maj"))$ 的概率密度函数（PDF）进行积分来获得其累积分布函数（CDF），然后考虑其 CDF 在 $t$ 处的值来证明。）使用这种技术，然后进行与@eqt:eot-estimator-after-t-sample 相同的简化，我们得出估计器
]


$
  L_i ( p , omega ) approx cases(delim: "{", L_o (p_s , omega) comma  upright("    if ") t prime > t, L_n (p prime , - omega)  comma  upright("  otherwise."))
$<volpath-surf-vol-simple-estimator>


#parec[
  From this point, outgoing radiance from a surface can be estimated using techniques that were introduced in @light-transport-i-surface-reflection, and $L_n$ can be estimated as described earlier.
][
  从这一点开始，可以使用@light-transport-i-surface-reflection 介绍的技术来估计从表面发出的辐射亮度，并且可以按照前面描述的方法估计 $L_n$。
]

=== Sampling the Majorant Transmittance
<sampling-the-majorant-transmittance>

#parec[
  We have so far presented volumetric path tracing with the assumption that $sigma_(upright("maj"))$ is constant along the ray and thus that $T_(upright("maj"))$ is a single exponential function. However, those assumptions are not compatible with the segments of piecewise-constant majorants that `Medium` implementations provide with their `RayMajorantIterator`s. We will now resolve this incompatibility.
][
  到目前为止，我们在假设 $sigma_(upright("maj"))$ 沿射线是常数的情况下介绍了体积路径追踪，因此 $T_(upright("maj"))$ 是一个单一的指数函数。然而，这些假设与`Medium`实现提供的分段常数主导值的`RayMajorantIterator`不兼容。我们现在将解决这种不兼容性。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f03.svg"),
  caption: [
    #ez_caption[
      (a) Given piecewise-constant majorants defined over segments along a ray, the corresponding optical thickness $tau$ is a piecewise-linear function. (b) Exponentiating the negative optical thickness gives the transmittance at each point along the ray. The transmittance function is continuous and decreasing, but has a first derivative discontinuity at transitions between segments.
    ][
      (a) 对于沿射线定义的分段常数主界值，对应的光学厚度 $tau$ 是分段线性函数。
      (b) 通过对负光学厚度进行指数运算，可以得到射线沿途每一点的透射率。透射率函数是连续且递减的，但在段与段的过渡点处其一阶导数存在不连续性。
    ]
  ],
)<tmaj-from-segments>

#parec[
  @fig:tmaj-from-segments shows example majorants along a ray, the optical thickness that they integrate to, and the resulting majorant transmittance function. The transmittance function is continuous and strictly decreasing, though at a rate that depends on the majorant at each point along the ray. If integration starts from $t = 0$, and we denote the $i$ th segment's majorant as $sigma_(upright("maj"))^i$ and its endpoint as $p_i$, the transmittance can be written as
][
  @fig:tmaj-from-segments 显示了沿射线的示例主导值、它们积分到的光学厚度以及由此产生的主导透射率函数。透射率函数是连续且严格递减的，但其速率取决于射线每一点的主导值。如果积分从 $t = 0$ 开始，并且我们将第 $i$ 段的主导值表示为 $sigma_(upright("maj"))^i$，其端点为 $p_i$，则透射率可以写为
]

$
  T_(upright("maj")) (p arrow.r p prime) = T_(upright("maj"))^1 (p arrow.r p_1) T_(upright("maj"))^2 ( p_1 arrow.r p_2 ) dots.h.c T_(upright("maj"))^n (p_(n - 1) arrow.r p prime)
$


#parec[
  where $T_(upright("maj"))^i$ is the transmittance function for the $i$ th segment and the point $p prime$ is the endpoint of the $n$ th segment. (This relationship uses the multiplicative property of transmittance from @eqt:beam-transmittance-mult.)
][
  其中 $T_(upright("maj"))^i$ 是第 $i$ 段的透射率函数，点 $p prime$ 是第 $n$ 段的端点。（这种关系使用了@eqt:beam-transmittance-mult 中的透射率乘法性质。）
]

#parec[
  Given the general task of estimating an integral of the form
][
  给定估计以下形式积分的一般任务
]

$
  integral_0^t sigma_(upright("maj")) (p prime) T_(upright("maj")) (p arrow.r p prime) f ( p prime ) thin upright("d") t prime
$



#parec[
  with $p prime = p + t prime omega$ and $omega = hat(p prime) - hat(p)$, it is useful to rewrite the integral to be over the individual majorant segments, which gives
][
  其中 $p prime = p + t prime omega$， $omega = hat(p prime) - hat(p)$，将积分重写为单个主导段上的积分是有用的，这给出
]

$
  sigma_(upright("maj"))^1 & integral_0^(t_1) T_(upright("maj"))^1 (p arrow.r p prime) f ( p prime ) thin upright("d") t prime\
  & + sigma_(upright("maj"))^1 T_(upright("maj"))^1 ( p arrow.r p_1 ) sigma_(upright("maj"))^2 integral_(t_1)^(t_2) T_(upright("maj"))^2 (p_1 arrow.r p prime) f ( p prime ) thin upright("d") t prime\
  & + sigma_(upright("maj"))^1 T_(upright("maj"))^1 (p arrow.r p_1) sigma_(upright("maj"))^2 T_(upright("maj"))^2 ( p_1 arrow.r p_2 ) integral_(t_2)^(t_3) T_(upright("maj"))^3 (p_2 arrow.r p prime) f (p prime) thin upright("d") t prime + dots.h.c .
$<tmaj-over-segments>


#parec[
  Note that each term's contribution is modulated by the transmittances and majorants from the previous segments.
][
  注意，每项的贡献都受到前一段的透射率和主导值的调制。
]

#parec[
  The form of @eqt:tmaj-over-segments hints at a sampling strategy: we start by sampling a value $t prime_1$ from $T_(upright("maj"))^1$ 's distribution $p_1$ ; if $t prime_1$ is less than $t_1$, then we evaluate the estimator at the sampled point $p prime$ :
][
  @eqt:tmaj-over-segments 的形式暗示了一种采样策略：我们首先从 $T_(upright("maj"))^1$ 的分布 $p_1$ 中采样一个值 $t prime_1$ ；如果 $t prime_1$ 小于 $t_1$，则在采样点 $p prime$ 处评估估计器：
]


$
  frac(sigma_(upright("maj"))^1 T_(upright("maj"))^1 (p arrow.r p prime) f (p prime), p_1 (t_1 prime)) = f (p prime) .
$
#parec[
  Applying the same ideas that led to @eqt:volpath-surf-vol-simple-estimator, we otherwise continue and consider the second term, drawing a sample $t_2 prime$ from $T_(upright("maj"))^2$ 's distribution, starting at $t_1$. If the sampled point is before the segment's endpoint, $t_2 prime < t_2$, then we have the estimator
][
  应用与@eqt:volpath-surf-vol-simple-estimator 相同的思路，我们继续考虑第二项，从 $T_(upright("maj"))^2$ 的分布中抽取一个样本 $t_2 prime$，从 $t_1$ 开始。如果抽样点在段的终点之前，即 $t_2 prime < t_2$，那么我们有估计器
]

$
  frac(sigma_(upright("maj"))^1 T_(upright("maj"))^1 (p arrow.r p_1) sigma_(upright("maj"))^2 T_(upright("maj"))^2 (p_1 arrow.r p prime) f (p prime), upright("Pr") { t_1 prime > t } p_2 (t_2 prime)) .
$
#parec[
  Because the probability that $t_1 prime > t$ is equal to $sigma_(upright("maj"))^1 T_(upright("maj"))^1 (p arrow.r p_1)$, the estimator for the second term again simplifies to $f (p prime)$. Otherwise, following this sampling strategy for subsequent segments similarly leads to the same simplified estimator in the end. It can furthermore be shown that the probability that no sample is generated in any of the segments is equal to the full majorant transmittance from 0 to $t$, which is exactly the probability required for the surface/volume estimator of @eqt:volpath-surf-vol-simple-estimator.
][
  因为概率 $t_1 prime > t$ 等于 $sigma_(upright("maj"))^1 T_(upright("maj"))^1 (p arrow.r p_1)$，第二项的估计器再次简化为 $f (p prime)$。否则，遵循这种抽样策略对后续段进行抽样，最终也会得到相同的简化估计器。此外，可以证明，在任何段中未生成样本的概率等于从 0 到 $t$ 的完整主导透射率，这正是@eqt:volpath-surf-vol-simple-estimator 的表面/体积估计器所需的概率。
]

#parec[
  The `SampleT_maj()` function implements this sampling strategy, handling the details of iterating over `RayMajorantSegment`s and sampling them. Its functionality will be used repeatedly in the following volumetric integrators.
][
  `SampleT_maj()` 函数实现了这种抽样策略，处理迭代 `RayMajorantSegment` 并对其进行抽样的细节。其功能将在接下来的体积积分器中反复使用。
]

```cpp
template <typename F>
SampledSpectrum SampleT_maj(Ray ray, Float tMax, Float u,
    RNG &rng, const SampledWavelengths &lambda, F callback);
```
#parec[
  In addition to a ray and an endpoint along it specified by `tMax`, `SampleT_maj()` takes a single uniform sample and an `RNG` to use for generating any necessary additional samples. This allows it to use a well-distributed value from a `Sampler` for the first sampling decision along the ray while it avoids consuming a variable and unbounded number of sample dimensions if more are needed. (recall the discussion of the importance of consistency in sample dimension consumption in @sampling-interface)
][
  除了沿着光线指定的终点 `tMax`，`SampleT_maj()` 还接受一个单一的均匀样本和一个 `RNG` 用于生成任何必要的额外样本。这允许它使用 `Sampler` 提供的一个分布良好的值进行光线上的首次抽样决策，同时避免在需要更多样本时消耗可变和无限数量的样本维度。(recall the discussion of the importance of consistency in sample dimension consumption in @sampling-interface)
]

#parec[
  The provided `SampledWavelengths` play their usual role, though the first of them has additional meaning: for media with scattering properties that vary with wavelength, the majorant at the first wavelength is used for sampling. The alternative would be to sample each wavelength independently, though that would cause an explosion in samples to be evaluated in the context of algorithms like path tracing.
][
  提供的 `SampledWavelengths` 扮演其通常的角色，尽管其中的第一个具有额外的意义：对于散射特性随波长变化的介质，使用第一个波长的主导进行抽样。另一种选择是独立地抽样每个波长，尽管这会导致在路径追踪等算法的上下文中需要评估的样本数量爆炸。
]

#parec[
  Sampling a single wavelength can work well for evaluating all wavelengths' contributions if multiple importance sampling (MIS) is used; this topic is discussed further in @improving-the-sampling-techniques .
][
  如果使用多重重要性抽样（MIS），单一波长的抽样可以很好地评估所有波长的贡献；这一主题将在@improving-the-sampling-techniques 进一步讨论。
]

#parec[
  A callback function is the last parameter passed to `SampleT_maj()`. This is a significant difference from `pbrt`'s other sampling methods, which all generate a single sample (or sometimes, no sample) each time they are called. When sampling media that has null scattering, however, often a succession of samples are needed along the same ray. (Delta tracking, described in @null-scattering, is an example of such an algorithm.) The provided callback function is therefore invoked by `SampleT_maj()` each time a sample is taken. After the callback processes the sample, it should return a Boolean value that indicates whether sampling should recommence starting from the provided sample. With this implementation approach, `SampleT_maj()` can maintain state like the `RayMajorantIterator` between samples along a ray, which improves efficiency.
][
  回调函数是传递给 `SampleT_maj()` 的最后一个参数。 这与 `pbrt` 的其他采样方法有显著区别，后者每次调用时仅生成一个样本（有时甚至不生成样本）。 然而，当采样具有空散射的介质时，通常需要沿同一条射线进行一系列连续的采样（@null-scattering 中描述的 Delta 跟踪算法是这种算法的一个例子）。 因此，每次采样时，`SampleT_maj()` 都会调用提供的回调函数。回调函数处理完样本后，应返回一个布尔值，用于指示是否应从当前样本位置重新开始采样。 通过这种实现方式，`SampleT_maj()` 可以在射线上的连续采样之间维护状态（如 `RayMajorantIterator`），从而提高效率。
]

#parec[
  The signature of the callback function should be the following:
][
  回调函数的签名应为如下所示：
]

```cpp
bool callback(Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
              SampledSpectrum T_maj)
```


#parec[
  Each invocation of the callback is passed a sampled point along the ray, the associated `MediumProperties` and $sigma_(upright("maj"))$ for the medium at that point, and the majorant transmittance $T_(upright("maj"))$. The first time `callback` is invoked, the majorant transmittance will be from the ray origin to the sample; any subsequent invocations give the transmittance from the previous sample to the current one.
][
  每次调用回调时，会传递沿光线的一个采样点、该点的相关 `MediumProperties` 和介质在该点的 $sigma_(upright("maj"))$，以及主导透射率 $T_(upright("maj"))$。第一次调用 `callback` 时，主导透射率将是从光线起点到样本的；任何后续调用则提供从前一个样本到当前样本的透射率。
]

#parec[
  After sampling concludes, `SampleT_maj()` returns the majorant transmittance $T_(upright("maj"))$ from the last sampled point in the medium (or the ray origin, if no samples were generated) to the ray's endpoint. (see @fig:sampletmaj-callback-points-and-final-transmittance)
][
  抽样结束后，`SampleT_maj()` 返回从介质中最后一个采样点（如果没有生成样本，则为光线起点）到光线终点的主导透射率 $T_(upright("maj"))$。（见@fig:sampletmaj-callback-points-and-final-transmittance）
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f04.svg"),
  caption: [
    #ez_caption[
      In addition to calling a provided callback
      function at sampled points in the medium, shown here as filled circles,
      the `SampleT_maj()` function returns the majorant transmittance
      $T_(upright("maj"))$ from the last sampled point to the provided
      $t_(upright("max"))$ value.
    ][
      除了在介质中调用提供的回调函数于采样点（如图中填充的圆点所示），`SampleT_maj()`
      函数还返回从最后一个采样点到提供的 $t_(upright("max"))$ 值的主导透射率
      $T_(upright("maj"))$。
    ]
  ],
)<sampletmaj-callback-points-and-final-transmittance>



#parec[
  As if all of this was not sufficiently complex, the implementation of `SampleT_maj()` starts out with some tricky C++ code. There is a second variant of `SampleT_maj()` we will introduce shortly that is templated based on the concrete type of `Medium` being sampled. In order to call the appropriate template specialization, we must determine which type of `Medium` the ray is passing through. Conceptually, we would like to do something like the following, using the `TaggedPointer::Is()` method:
][
  仿佛这一切还不够复杂，`SampleT_maj()` 的实现以一些棘手的 C++ 代码开始。 我们将很快介绍 `SampleT_maj()` 的第二个变体，它是基于被采样的 `Medium` 的具体类型进行模板化的。 为了调用适当的模板特化，我们必须确定光线穿过的 `Medium` 的类型。 概念上，我们希望像下面这样做，使用 `TaggedPointer::Is()` 方法：
]

```cpp
if (ray.medium.Is<HomogeneousMedium>())
   SampleT_maj<HomogeneousMedium>(ray, tMax, u,rng, lambda, func);
else if (ray.medium.Is<UniformGridMedium>())
   //  …
```

#parec[
  However, enumerating all the media that are implemented in `pbrt` in the `SampleT_maj()` function is undesirable: that would add an unexpected and puzzling additional step for users who wanted to extend the system with a new `Medium`. Therefore, the first `SampleT_maj()` function uses the dynamic dispatch capability of the `Medium`'s `TaggedPointer` along with a generic lambda function, `sample`, to determine the `Medium`'s type. `TaggedPointer::Dispatch()` ends up passing the `Medium` pointer back to `sample`; because the parameter is declared as `auto`, it then takes on the actual type of the medium when it is invoked. Thus, the following function has equivalent functionality to the code above but naturally handles all the media that are listed in the `Medium` class declaration without further modification.
][
  然而，在 `SampleT_maj()` 函数中枚举所有在 `pbrt` 中实现的介质是不可取的：这会为想要用新的 `Medium` 扩展系统的用户增加一个意想不到且令人困惑的额外步骤。 因此，第一个 `SampleT_maj()` 函数使用 `Medium` 的 `TaggedPointer` 的动态调度能力以及一个通用的 lambda 函数 `sample` 来确定 `Medium` 的类型。 `TaggedPointer::Dispatch()` 最终将 `Medium` 指针传回给 `sample`；因为参数被声明为 `auto`，所以在调用时它会采用介质的实际类型。 因此，以下函数具有与上述代码等效的功能，但自然地处理在 `Medium` 类声明中列出的所有介质而无需进一步修改。
]

```cpp
template <typename F>
SampledSpectrum SampleT_maj(Ray ray, Float tMax, Float u, RNG &rng,
                            const SampledWavelengths &lambda, F callback) {
    auto sample = [&](auto medium) {
        using M = typename std::remove_reference_t<decltype(*medium)>;
        return SampleT_maj<M>(ray, tMax, u, rng, lambda, callback);
    };
    return ray.medium.Dispatch(sample);
}
```


#parec[
  With the concrete type of the medium available, we can proceed with the second instance of `SampleTmaj()`, which can now be specialized based on that type.
][
  有了介质的具体类型，我们可以继续进行 `SampleTmaj()` 的第二个实例，它现在可以基于该类型进行特化。
]

```cpp
template <typename ConcreteMedium, typename F>
SampledSpectrum SampleT_maj(Ray ray, Float tMax, Float u, RNG &rng,
                            const SampledWavelengths &lambda, F callback) {
    <<Normalize ray direction and update tMax accordingly>>
    tMax *= Length(ray.d);
    ray.d = Normalize(ray.d);
    <<Initialize MajorantIterator for ray majorant sampling>>
    ConcreteMedium *medium = ray.medium.Cast<ConcreteMedium>();
    typename ConcreteMedium::MajorantIterator iter =
        medium->SampleRay(ray, tMax, lambda);
    <<Generate ray majorant samples until termination>>
    SampledSpectrum T_maj(1.f);
    bool done = false;
    while (!done) {
        <<Get next majorant segment from iterator and sample it>>
        pstd::optional<RayMajorantSegment> seg = iter.Next();
        if (!seg)
            return T_maj;
        <<Handle zero-valued majorant for current segment>>
        if (seg->sigma_maj[0] == 0) {
            Float dt = seg->tMax - seg->tMin;
            <<Handle infinite dt for ray majorant segment>>
            if (IsInf(dt)) dt = std::numeric_limits<Float>::max();
            T_maj *= FastExp(-dt * seg->sigma_maj);
            continue;
        }
        <<Generate samples along current majorant segment>>
        Float tMin = seg->tMin;
        while (true) {
            <<Try to generate sample along current majorant segment>>
            Float t = tMin + SampleExponential(u, seg->sigma_maj[0]);
            u = rng.Uniform<Float>();
            if (t < seg->tMax) {
                <<Call callback function for sample within segment>>
                T_maj *= FastExp(-(t - tMin) * seg->sigma_maj);
                MediumProperties mp = medium->SamplePoint(ray(t), lambda);
                if (!callback(ray(t), mp, seg->sigma_maj, T_maj)) {
                    done = true;
                    break;
                }
                T_maj = SampledSpectrum(1.f);
                tMin = t;
            } else {
                <<Handle sample past end of majorant segment>>
                Float dt = seg->tMax - tMin;
                T_maj *= FastExp(-dt * seg->sigma_maj);
                break;
            }
        }
    }
    return SampledSpectrum(1.f);
}
```


#parec[
  The function starts by normalizing the ray's direction so that parametric distance along the ray directly corresponds to distance from the ray's origin. This simplifies subsequent transmittance computations in the remainder of the function. Since normalization scales the direction's length, the `tMax` endpoint must also be updated so that it corresponds to the same point along the ray.
][
  该函数首先规范化光线的方向，使得沿光线的参数距离直接对应于从光线起点的距离。这简化了函数其余部分的透射率计算。 由于规范化会缩放方向的长度，因此 `tMax` 终点也必须更新，以确保它仍然对应光线上的同一点。
]

```cpp
tMax *= Length(ray.d);
ray.d = Normalize(ray.d);
```

#parec[
  Since the actual type of the medium is known and because all `Medium` implementations must define a `MajorantIterator` type (recall @medium-interface), the medium's iterator type can be directly declared as a stack-allocated variable. This gives a number of benefits: not only is the expense of dynamic allocation avoided, but subsequent calls to the iterator's `Next()` method in this function are regular method calls that can even be expanded inline by the compiler; no dynamic dispatch is necessary for them. An additional benefit of knowing the medium's type is that the appropriate `SampleRay()` method can be called directly without incurring the cost of dynamic dispatch here.
][
  由于介质的实际类型已知，并且所有 `Medium` 实现都必须定义一个 `MajorantIterator` 类型（回想@medium-interface），因此可以直接将介质的迭代器类型声明为一个栈分配的变量。 这带来了许多好处：不仅避免了动态分配的开销，而且在此函数中对迭代器的 `Next()` 方法的后续调用是常规方法调用，甚至可以由编译器内联展开；不需要为它们进行动态调度。 知道介质的类型的另一个好处是可以直接调用适当的 `SampleRay()` 方法，而不会在此处产生动态调度的成本。
]


```cpp
ConcreteMedium *medium = ray.medium.Cast<ConcreteMedium>();
typename ConcreteMedium::MajorantIterator iter =
    medium->SampleRay(ray, tMax, lambda);
```


#parec[
  With an iterator initialized, sampling along the ray can proceed. The `T_maj` variable declared here tracks the accumulated majorant transmittance from the ray origin or the previous sample along the ray (depending on whether a sample has yet been generated).
][
  一旦迭代器初始化完成，就可以沿着光线进行抽样。这里声明的 `T_maj` 变量跟踪从光线起点或沿光线的前一个样本（取决于是否已经生成样本）的累积主导透射率。
]

```cpp
SampledSpectrum T_maj(1.f);
bool done = false;
while (!done) {
    <<Get next majorant segment from iterator and sample it>>
    pstd::optional<RayMajorantSegment> seg = iter.Next();
    if (!seg)
        return T_maj;
    <<Handle zero-valued majorant for current segment>>
    if (seg->sigma_maj[0] == 0) {
        Float dt = seg->tMax - seg->tMin;
        <<Handle infinite dt for ray majorant segment>>
        if (IsInf(dt)) dt = std::numeric_limits<Float>::max();
        T_maj *= FastExp(-dt * seg->sigma_maj);
        continue;
    }
    <<Generate samples along current majorant segment>>
    Float tMin = seg->tMin;
    while (true) {
        <<Try to generate sample along current majorant segment>>
        Float t = tMin + SampleExponential(u, seg->sigma_maj[0]);
        u = rng.Uniform<Float>();
        if (t < seg->tMax) {
            <<Call callback function for sample within segment>>
            T_maj *= FastExp(-(t - tMin) * seg->sigma_maj);
            MediumProperties mp = medium->SamplePoint(ray(t), lambda);
            if (!callback(ray(t), mp, seg->sigma_maj, T_maj)) {
                done = true;
                break;
            }
            T_maj = SampledSpectrum(1.f);
            tMin = t;
        } else {
            <<Handle sample past end of majorant segment>>
            Float dt = seg->tMax - tMin;
            T_maj *= FastExp(-dt * seg->sigma_maj);
            break;
        }
    }
}
return SampledSpectrum(1.f);
```

#parec[
  If the iterator has no further majorant segments to provide, then sampling is complete. In this case, it is important to return any majorant transmittance that has accumulated in `T_maj`; that represents the remaining transmittance to the ray's endpoint. Otherwise, a few details are attended to before sampling proceeds along the segment.
][
  如果迭代器没有更多的主导段可提供，则抽样完成。在这种情况下，重要的是返回在 `T_maj` 中累积的任何主导透射率；这表示到光线终点的剩余透射率。 否则，在沿段进行抽样之前，需要处理一些细节。
]


```cpp
pstd::optional<RayMajorantSegment> seg = iter.Next();
if (!seg)
    return T_maj;
<<Handle zero-valued majorant for current segment>>
if (seg->sigma_maj[0] == 0) {
    Float dt = seg->tMax - seg->tMin;
    <<Handle infinite dt for ray majorant segment>>
    if (IsInf(dt))
        dt = std::numeric_limits<Float>::max();
    T_maj *= FastExp(-dt * seg->sigma_maj);
    continue;
}
<<Generate samples along current majorant segment>>
Float tMin = seg->tMin;
while (true) {
    <<Try to generate sample along current majorant segment>>
    Float t = tMin + SampleExponential(u, seg->sigma_maj[0]);
    u = rng.Uniform<Float>();
    if (t < seg->tMax) {
        <<Call callback function for sample within segment>>
        T_maj *= FastExp(-(t - tMin) * seg->sigma_maj);
        MediumProperties mp = medium->SamplePoint(ray(t), lambda);
        if (!callback(ray(t), mp, seg->sigma_maj, T_maj)) {
            done = true;
            break;
        }
        T_maj = SampledSpectrum(1.f);
        tMin = t;
    } else {
        <<Handle sample past end of majorant segment>>
        Float dt = seg->tMax - tMin;
        T_maj *= FastExp(-dt * seg->sigma_maj);
        break;
    }
}
```

#parec[
  If the majorant has the value 0 in the first wavelength, then there is nothing to sample along the segment. It is important to handle this case, since otherwise the subsequent call to `SampleExponential()` in this function would return an infinite value that would subsequently lead to not-a-number values. Because the other wavelengths may not themselves have zero-valued majorants, we must still update `T_maj` for the segment's majorant transmittance even though the transmittance for the first wavelength is unchanged.
][
  如果主导在第一个波长中具有值 0，则在该段上没有任何东西可供抽样。重要的是要处理这种情况，因为否则此函数中对 `SampleExponential()` 的后续调用将返回一个无限值，随后会导致非数字值。 由于其他波长可能本身没有零值主导，因此即使第一个波长的透射率保持不变，我们仍然必须更新该段的主导透射率中的 `T_maj`。
]

```cpp
if (seg->sigma_maj[0] == 0) {
    Float dt = seg->tMax - seg->tMin;
    <<Handle infinite dt for ray majorant segment>>
    if (IsInf(dt))
        dt = std::numeric_limits<Float>::max();
    T_maj *= FastExp(-dt * seg->sigma_maj);
    continue;
}
```


#parec[
  One edge case must be attended to before the exponential function is called. If `tMax` holds the IEEE floating-point infinity value, then `dt` will as well; it then must be bumped down to the largest finite `Float`. This is necessary because with floating-point arithmetic, zero times infinity gives a not-a-number value (whereas any nonzero value times infinity gives infinity). Otherwise, for any wavelengths with zero-valued `sigma_maj`, not-a-number values would be passed to `FastExp()`.
][
  在调用指数函数之前，必须处理一个边缘情况。如果 `tMax` 持有 IEEE 浮点数的无穷大值，则 `dt` 也将如此；然后必须将其降低到最大的有限 `Float`。 这是必要的，因为在浮点运算中，零乘以无穷大会给出非数字值（而任何非零值乘以无穷大会给出无穷大）。 否则，对于任何具有零值 `sigma_maj` 的波长，将会向 `FastExp()` 传递非数字值。
]


```cpp
if (IsInf(dt))
    dt = std::numeric_limits<Float>::max();
```


#parec[
  The implementation otherwise tries to generate a sample along the current segment. This work is inside a `while` loop so that multiple samples may be generated along the segment.
][
  实现尝试在当前段上生成一个样本。这个工作在一个 `while` 循环中进行，以便可以在段上生成多个样本。
]


```cpp
Float tMin = seg->tMin;
while (true) {
    <<Try to generate sample along current majorant segment>>
    Float t = tMin + SampleExponential(u, seg->sigma_maj[0]);
    u = rng.Uniform<Float>();
    if (t < seg->tMax) {
        <<Call callback function for sample within segment>>
        T_maj *= FastExp(-(t - tMin) * seg->sigma_maj);
        MediumProperties mp = medium->SamplePoint(ray(t), lambda);
        if (!callback(ray(t), mp, seg->sigma_maj, T_maj)) {
            done = true;
            break;
        }
        T_maj = SampledSpectrum(1.f);
        tMin = t;
    } else {
        <<Handle sample past end of majorant segment>>
        Float dt = seg->tMax - tMin;
        T_maj *= FastExp(-dt * seg->sigma_maj);
        break;
    }
}
```

#parec[
  In the usual case, a distance is sampled according to the PDF $sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$. Separate cases handle a sample that is within the current majorant segment and one that is past it.
][
  在通常情况下，根据 PDF $sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$ 采样一个距离。分别处理一个在当前主导段内的样本和一个超出它的样本。
]

#parec[
  One detail to note in this fragment is that as soon as the uniform sample `u` has been used, a replacement is immediately generated using the provided `RNG`. In this way, the method maintains the invariant that `u` is always a valid independent sample value. While this can lead to a single excess call to `RNG::Uniform()` each time `SampleT_maj()` is called, it ensures the initial `u` value provided to the method is used only once.
][
  这个片段中需要注意的一个细节是，一旦使用了均匀样本 `u`，就会立即使用提供的 `RNG` 生成一个替换样本。 通过这种方式，该方法保持 `u` 始终是一个有效的独立样本值的不变性。 虽然这可能导致每次调用 `SampleT_maj()` 时对 `RNG::Uniform()` 的单次多余调用，但它确保提供给方法的初始 `u` 值仅使用一次。
]



```cpp
Float t = tMin + SampleExponential(u, seg->sigma_maj[0]);
u = rng.Uniform<Float>();
if (t < seg->tMax) {
    <<Call callback function for sample within segment>>
    T_maj *= FastExp(-(t - tMin) * seg->sigma_maj);
    MediumProperties mp = medium->SamplePoint(ray(t), lambda);
    if (!callback(ray(t), mp, seg->sigma_maj, T_maj)) {
        done = true;
        break;
    }
    T_maj = SampledSpectrum(1.f);
    tMin = t;
} else {
    <<Handle sample past end of majorant segment>>
    Float dt = seg->tMax - tMin;
    T_maj *= FastExp(-dt * seg->sigma_maj);
    break;
}
```


#parec[
  For a sample within the segment's extent, the final majorant transmittance to be passed to the callback is found by accumulating the transmittance from `tMin` to the sample point. The rest of the necessary medium properties can be found using `SamplePoint()`. If the callback function returns `false` to indicate that sampling should conclude, then we have a doubly nested `while` loop to break out of; a `break` statement takes care of the inner one, and setting `done` to `true` causes the outer one to terminate.
][
  对于段内的样本，传递给回调的最终主导透射率是通过累积从 `tMin` 到样本点的透射率来找到的。 其余的必要介质属性可以使用 `SamplePoint()` 找到。如果回调函数返回 `false` 表示抽样应结束，那么我们有一个双重嵌套的 `while` 循环要跳出；一个 `break` 语句处理内部循环，并将 `done` 设置为 `true` 使外部循环终止。
]

#parec[
  If `true` is returned by the callback, indicating that sampling should restart at the sample that was just generated, then the accumulated transmittance is reset to 1 and `tMin` is updated to be at the just-taken sample's position.
][
  如果回调返回 `true`，表示抽样应从刚生成的样本重新开始，则累积的透射率重置为 1，并将 `tMin` 更新为刚刚采样的位置。
]


```cpp
T_maj *= FastExp(-(t - tMin) * seg->sigma_maj);
MediumProperties mp = medium->SamplePoint(ray(t), lambda);
if (!callback(ray(t), mp, seg->sigma_maj, T_maj)) {
    done = true;
    break;
}
T_maj = SampledSpectrum(1.f);
tMin = t;
```


#parec[
  If the sampled distance $t$ is past the end of the segment, then there is no medium interaction along it and it is on to the next segment, if any.
][
  如果采样距离 $t$ 超过了段的末端，则在其上没有介质交互，并且进入下一个段（如果有）。
]

#parec[
  In this case, majorant transmittance up to the end of the segment must be accumulated into `T_maj` so that the complete majorant transmittance along the ray is provided with the next valid sample (if any).
][
  在这种情况下，必须将段末端的主导透射率累积到 `T_maj` 中，以便在下一个有效样本（如果有）时提供沿光线的完整主导透射率。
]


```cpp
Float dt = seg->tMax - tMin;
T_maj *= FastExp(-dt * seg->sigma_maj);
break;
```


=== Generalized Path Space #emoji.warning
<generalized-path-space>

#parec[
  Just as it was helpful to express the light transport equation (LTE) as a sum over paths of scattering events, it is also helpful to express the null-scattering integral equation of transfer in this form. Doing so makes it possible to apply variance reduction techniques like multiple importance sampling and is a prerequisite for constructing participating medium-aware bidirectional integrators.
][
  正如将光传输方程（LTE）表示为散射事件路径的总和是有帮助的，将虚散射传输积分方程表示为这种形式也是有帮助的。这样做可以应用方差减小技术，如多重重要性采样，并且是构建参与介质敏感的双向积分器的前提。
]

#parec[
  Recall how, in @integral-over-paths, the surface form of the LTE was repeatedly substituted into itself to derive the path space contribution function for a path of length $n$
][
  回忆一下，在@integral-over-paths 中，LTE 的表面形式被反复代入自身，以推导出长度为 $n$ 的路径的路径空间贡献函数
]

$
  P(macron(p)_n) = underbrace(integral_A integral_A dots.c integral_A, n - 1) L_e (p_n arrow.r p_(n - 1)) T(macron(p)_n) thin d A(p_2) dots.c d A(p_n),
$

#parec[
  where the throughput $T (macron(upright(p))_n)$ was defined as
][
  其中通量 $T (macron(upright(p))_n)$ 被定义为
]

$
  T (macron(upright(p))_n) = product_(i = 1)^(n - 1) f (p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) G (p_(i + 1) arrow.l.r p_i) .
$

#parec[
  This previous definition only works for surfaces, but using a similar approach of substituting the integral equation of transfer, a medium-aware path integral can be derived. The derivation is laborious and we will just present the final result here. (The "Further Reading" section has a pointer to the full derivation.)
][
  之前的定义仅适用于表面，但使用类似的方法代入传输积分方程，可以推导出一个介质感知的路径积分。推导过程繁琐，我们将在这里仅展示最终结果。（"进一步阅读"部分有完整推导的指引。）
]

#parec[
  Previously, integration occurred over a Cartesian product of surface locations $A^n$. Now, we will need a formal way of writing down an integral over an arbitrary sequence of each of 2D surface locations $A$, 3D positions in a participating medium $V$ where actual scattering occurs, and 3D positions in a participating medium $V_nothing$ where null scattering occurs. (The two media $V$ and $V_nothing$ represent the same volume of space with the same scattering properties, but we will find it handy to distinguish between them in the following.)
][
  以前，积分是在表面位置的笛卡尔积 $A^n$ 上进行的。现在，我们需要一种正式的方法来书写在每个二维表面位置 $A$ 、实际散射发生的参与介质中的三维位置 $V$ 和虚散射发生的参与介质中的三维位置 $V_nothing$ 的任意序列上的积分。 （两个介质 $V$ 和 $V_nothing$ 代表具有相同散射特性的相同空间体积，但在接下来的讨论中区分它们将会更加方便。）
]

#parec[
  First, we will focus only on a specific arrangement of $n$ surface and medium vertices encoded in a configuration vector $upright(bold(c))$. The associated set of paths is given by a Cartesian product of surface locations and medium locations,
][
  首先，我们将仅关注在配置向量 $upright(bold(c))$ 中编码的 $n$ 个表面和介质顶点的特定排列。相关的路径集由表面位置和介质位置的笛卡尔积给出，
]

$
  bold(upright(P))_n^(upright(bold(c))) = times_(i = 1)^n cases(delim: "{", A comma & upright("   if ") upright(bold(c))_i = 0, V comma & upright("   if ") upright(bold(c))_i = 1, V_nothing comma & upright("   if ") upright(bold(c))_i = 2) .
$


#parec[
  The set of all paths of length $n$ is the union of the above sets over all possible configuration vectors:
][
  长度为 $n$ 的所有路径的集合是上述集合在所有可能的配置向量上的并集：
]

$ bold(upright(P))_n = union.big_(upright(bold(c)) in {0 , 1 , 2}^n) bold(upright(P))_n^(upright(bold(c))) . $

#parec[
  Next, we define a #emph[measure];, which provides an abstract notion of the volume of a subset $D subset.eq bold(upright(P))_n$ that is essential for integration. The measure we will use simply sums up the product of surface area and volume associated with the individual vertices in each of the path spaces of specific configurations.
][
  接下来，我们定义一个#emph[测度];，它为子集 $D subset.eq bold(upright(P))_n$ 的体积提供了一个抽象概念，这对于积分是必不可少的。 我们将使用的测度简单地将与特定配置的每个路径空间中的个体顶点相关联的表面积和体积的乘积相加。
]

$
  mu_n (D) = sum_(upright(bold(c)) in {0 , 1}^n) mu_n^(upright(bold(c))) (D inter bold(upright(P))_n^(upright(bold(c))))
  "where"
  mu_n^(upright(bold(c))) ( D ) = integral_D product_(i = 1)^n cases(delim: "{", d A (p_i) comma & upright(" if ") upright(bold(c))_i = 0, d V (p_i) comma & upright(" if ") upright(bold(c))_i = 1, d V_nothing (p_i) comma & upright(" if ") upright(bold(c))_i = 2) .
$


#parec[
  The measure for null-scattering vertices $d V_nothing$ incorporates a Dirac delta distribution to limit integration to be along the line between successive real-scattering vertices.
][
  虚散射顶点的测度 $d V_nothing$ 包含一个狄拉克δ函数，以限制积分沿着连续真实散射顶点之间的直线进行。
]

#parec[
  The generalized path contribution $hat(P) (macron(upright(p))_n)$ can now be written as
][
  现在可以将广义路径贡献 $hat(P) (macron(upright(p))_n)$ 表示为
]

$
  hat(P) (macron(upright(p))_n) = integral_(bold(upright(P))_(n - 1)) hat(L)_e (p_n arrow.r p_(n - 1)) hat(T) (macron(upright(p))_n) thin d mu_(n - 1) ( p_2 , dots.h , p_n ) ,
$<path-space-contribution-function>


#parec[
  where
][
  其中
]


$
  hat(L)_e ( p_n arrow.r p_(n - 1) ) = cases(delim: "{", L_e (p_n arrow.r p_(n - 1)) & upright("if ") p_n in A ,, sigma_a (p_n) L_e (p_n arrow.r p_(n - 1)) & upright("if ") p_n in V .)
$ <path-space-emission-function>


#parec[
  Due to the measure defined earlier, the generalized path contribution is a sum of many integrals considering all possible sequences of surface, volume, and null-scattering events.
][
  由于之前定义的度量，广义路径贡献是所有可能的表面、体积和空散射事件序列的多个积分之和。
]

#parec[
  The full set of path vertices $p_i$ include both null- and real-scattering events. We will find it useful to use $r_i$ to denote the subset of them that represent real scattering (see @fig:path-space-real-null-scattering). Note a given real-scattering vertex $r_i$ will generally have a different index value in the full path.
][
  完整的路径顶点集 $p_i$ 包括空散射和真实散射事件。我们将发现使用 $r_i$ 来表示它们中代表真实散射的子集是有用的（见@fig:path-space-real-null-scattering）。注意，给定的真实散射顶点 $r_i$ 在完整路径中通常会有不同的索引值。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f05.png"),
  caption: [
    #ez_caption[
      In the path space framework, a path is defined by a set of $n$ vertices $p_i$ that have an emitter at one endpoint and a sensor at the other, where intermediate vertices represent scattering events, including null scattering. The subset of $m$ vertices that represent real scattering events are labeled $r_i$.
    ][
      在路径空间框架中，一条路径由一组 $n$ 个顶点 $p_i$ 定义，其中路径的一端是光源，另一端是传感器，中间的顶点表示散射事件，包括空散射事件。表示实际散射事件的 $m$ 个顶点的子集被标记为 $r_i$。
    ]
  ],
)<path-space-real-null-scattering>

#parec[
  The path throughput function $hat(T)(macron(upright(p))_n)$ can then be defined as:
][
  路径通量函数 $hat(T)(macron(upright(p))_n)$ 可以定义为：
]
$
  hat(T)(macron(p)_n) = &(product_(i = 1)^(n - 1) hat(f)(p_(i + 1) arrow.r p_i arrow.r p_(i - 1)))(product_(i = 0)^(n - 1) T_(m a j)(p_i arrow.r p_(i + 1))) \
  & times(product_(i = 1)^(m - 1) hat(G)(r_i arrow.l.r r_(i + 1)))
$<throughput-generalized>

#parec[
  It now refers to a generalized scattering distribution function $hat(f)$ and generalized geometric term $hat(G)$. The former simply falls back to the BSDF, phase function (multiplied by $sigma_s$ ), or a factor that enforces the ordering of null-scattering vertices, depending on the type of the vertex $p_i$. Note that the first two products in @eqt:throughput-generalized are over all vertices but the third is only over real-scattering vertices.
][
  现在，它指的是广义散射分布函数 $hat(f)$ 和广义几何项 $hat(G)$。 前者根据顶点 $p_i$ 的类型，简单地退化为 BSDF、相函数（乘以 $sigma_s$ ），或用于保证空散射顶点顺序的一个因子。 需要注意的是，@eqt:throughput-generalized 中的前两个乘积是针对所有顶点的，而第三个乘积仅针对实际散射顶点。
]

#parec[
  The scattering distribution function $hat(f)$ is defined by
][
  散射分布函数 $hat(f)$ 定义为：
]
$
  hat(f)(p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) =
  cases(delim: "{", f(p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) comma & "if " p_i in A,
sigma_s (p_i) p(p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) comma & "if " p_i in V,
sigma_n (p_i) H((p_i - p_(i + 1)) dot.op(p_(i - 1) - p_i)) comma & "if " p_i in V_nothing .)
$<scatfun-generalized>

#parec[
  Here, $H$ is the Heaviside function, which is 1 if its parameter is positive and 0 otherwise.
][
  这里， $H$ 是阶跃函数（Heaviside 函数），当其参数为正时取值为 1，否则取值为 0。
]

#parec[
  @eqt:g-definition in @the-surface-form-of-the-lte originally defined the geometric term $G$ as:
][
  @the-surface-form-of-the-lte 中的@eqt:g-definition 最初将几何项 $G$ 定义为：
]

$
  G(p arrow.l.r p') = V(p arrow.l.r p') frac(|cos theta||cos theta'|,|p - p'|) .
$

#parec[
  A generalized form of this geometric term is given by
][
  这一几何项的广义形式定义为：
]

$
  hat(G) (p arrow.l.r p prime) = V ( p arrow.l.r p prime ) frac(C_p (p , p prime) C_(p prime) (p prime , p), parallel p - p prime parallel) ,
$<g-generalized>


#parec[
  where
][
  其中
]

$
  C_p ( p , p prime ) = cases(delim: "{", lr(|upright(bold(n))_p dot.op frac(p - p prime, parallel p - p prime parallel)|) comma & upright("if ") p in A, 1 comma & upright("if ") p in V)
$


#parec[
  incorporates the absolute angle cosine between the connection segment and the normal direction when the underlying vertex $p$ is located on a surface. Note that $C_p$ is only evaluated for real-scattering vertices $r_i$, so the case of $p in V_nothing$ does not need to be considered.
][
  包含连接段与法线方向之间的绝对余弦值，当底层顶点 $p$ 位于表面上时。注意， $C_p$ 仅对真实散射顶点 $r_i$ 计算，因此不需要考虑 $p in V_nothing$ 的情况。
]

#parec[
  Similar to integrating over the path space for surface scattering, the Monte Carlo estimator for the path contribution function $hat(P)$ can be defined for a path $macron(upright(p))_n$ of $n$ path vertices $p_i$. The resulting Monte Carlo estimator is
][
  类似于对表面散射的路径空间进行积分，路径贡献函数 $hat(P)$ 的蒙特卡罗估计器可以为路径 $macron(upright(p))_n$ 的 $n$ 个路径顶点 $p_i$ 定义。蒙特卡罗估计器为
]

$
  hat(P) (macron(upright(p))_n) = frac(hat(T) (macron(upright(p))_n) hat(L)_e (p_n arrow.r p_(n - 1)), p (macron(upright(p))_n)) ,
$<generalized-volpath-estimator>

#parec[
  where $p (macron(upright(p))_n)$ is the probability of sampling the path $macron(upright(p))_n$ with respect to the generalized path space measure.
][
  其中 $p (macron(upright(p))_n)$ 是相对于广义路径空间度量采样路径 $macron(upright(p))_n$ 的概率。
]

#parec[
  Following @eqt:beta-path-throughput-weight, we will also find it useful to define the volumetric path throughput weight
][
  根据方 @eqt:beta-path-throughput-weight，定义体积路径通量权重也将是有用的
]

$ beta (macron(upright(p))_n) = frac(hat(T) (macron(upright(p))_n), p (macron(upright(p))_n)) . $<volpath-beta>


=== Evaluating the Volumetric Path Integral #emoji.warning
<evaluating-the-volumetric-path-integral>


#parec[
  The Monte Carlo estimator of the null-scattering path integral from @eqt:generalized-volpath-estimator allows sampling path vertices in a variety of ways; it is not necessary to sample them incrementally from the camera as in path tracing, for example. We will now reconsider sampling paths via path tracing under the path integral framework to show its use. For simplicity, we will consider scenes that have only volumetric scattering here.
][
  @eqt:generalized-volpath-estimator 中的无散射路径积分的蒙特卡罗估计器允许以多种方式采样路径顶点；例如，不必像路径追踪那样从相机逐步采样它们。 我们现在将在路径积分框架下重新考虑通过路径追踪来采样路径，以展示其用途。 为了简单起见，我们将在这里考虑仅具有体积散射的场景。
]

#parec[
  The volumetric path-tracing algorithm from @evaluating-the-equation-of-transfer is based on three sampling operations: sampling a distance along the current ray to a scattering event, choosing which type of interaction happens at that point, and then sampling a new direction from that point if the path has not been terminated. We can write the corresponding Monte Carlo estimator for the generalized path contribution function $hat(P)$ from @eqt:generalized-volpath-estimator with the path probability $p (macron(upright(p))_n)$ expressed as the product of three probabilities:
][
  @evaluating-the-equation-of-transfer 中的体积路径追踪算法基于三个采样操作：沿当前光线采样到达散射事件的距离，选择在该点发生的交互事件类型，然后如果路径尚未终止，则从该点采样一个新方向。 我们可以为广义路径贡献函数 $hat(P)$ 从@eqt:generalized-volpath-estimator 中写出相应的蒙特卡罗估计器，其中路径概率 $p (macron(upright(p))_n)$ 表示为三个概率的乘积：
]

#parec[
  - $p_(upright("maj")) (p_(i + 1) divides p_i , omega_i)$: the probability of sampling the point $p_(i + 1)$ along the direction
    $omega_i$ from the point $p_i$.
][
  - $p_(upright("maj")) (p_(i + 1) divides p_i , omega_i)$：从点 $p_i$ 沿方向 $omega_i$ 采样到点 $p_(i + 1)$ 的概率。
]

#parec[
  - $p_e (p_i)$: the discrete probability of sampling the type of scattering event—absorption, real-, or null-scattering—that was chosen at $p_i$.
][
  - $p_e (p_i)$：在 $p_i$ 处选择的散射事件类型（吸收、真实或无散射）的离散概率。
]

#parec[
  - $p_omega (omega prime divides r_i , omega_i)$: the probability of
    sampling the direction $omega prime$ after a regular scattering event
    at point $r_i$ with incident direction $omega_i$.
][
  - $p_omega (omega prime divides r_i , omega_i)$：在点 $r_i$
    处发生常规散射事件后以入射方向 $omega_i$ 采样方向 $omega prime$
    的概率。
]

#parec[
  For an $n$ vertex path with $m$ real-scattering vertices, the resulting estimator is
][
  对于具有 $m$ 个真实散射顶点的 $n$ 顶点路径，估计器为
]


$
  frac(hat(T) (macron(upright(p))_n) hat(L)_e (upright(p)_n arrow.r upright(p)_(n - 1)), (product_(i = 0)^(n - 1) p_(upright("maj")) (upright(p)_(i + 1) divides upright(p)_i , omega_i)) (product_(i = 1)^n p_e (upright(p)_i)) (product_(i = 1)^(m - 1) p_omega (omega_(i + 1) divides r_i , omega_i) hat(G) (r_i arrow.l.r r_(i + 1)))) ,
$
#parec[
  where $omega_i$ denotes the direction from $upright(p)_i$ to $upright(p)_(i + 1)$ and where the $hat(G)$ factor in the denominator accounts for the change of variables from sampling with respect to solid angle to sampling with respect to the path space measure.
][
  其中 $omega_i$ 表示从 $upright(p)_i$ 到 $upright(p)_(i + 1)$ 的方向，并且分母中的 $hat(G)$ 因子考虑了从相对于立体角采样到相对于路径空间测度采样的变量变化。路径空间测度是指在路径空间中进行积分的度量方式。
]

#parec[
  We consider each of the three sampling operations in turn, starting with distance sampling, which has density $p_(upright("maj"))$. Assuming a single majorant $sigma_(upright("maj"))$, we find that $p_(upright("maj"))$ has density $sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$, and the exponential factors cancel out the $T_(upright("maj"))$ factors in $hat(T)$, each one leaving behind a $1 \/ sigma_(upright("maj"))$ factor. Expanding out $hat(T)$ and simplifying, including eliminating the $hat(G)$ factors, all of which also cancel out, we have the estimator
][
  我们依次考虑每个采样操作，首先是距离采样，其密度为 $p_(upright("maj"))$。假设一个单一的主导项 $sigma_(upright("maj"))$，我们发现 $p_(upright("maj"))$ 的密度为 $sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$，指数因子抵消了 $hat(T)$ 中的主导传输因子 $T_(upright("maj"))$，每一个因子都留下一个 $1 \/ sigma_(upright("maj"))$。展开并简化 $hat(T)$，包括消除所有也被抵消的 $hat(G)$ 因子，我们得到估计量
]

$
  hat(P) ( upright(p)_n ) = frac((product_(i = 1)^(n - 1) hat(f) (upright(p)_(i + 1) arrow.r upright(p)_i arrow.r upright(p)_(i - 1))) hat(L)_e (upright(p)_n arrow.r upright(p)_(n - 1)), (sigma_(upright("maj")))^n (product_(i = 1)^n p_e (upright(p)_i)) (product_(i = 1)^(m - 1) p_omega (omega_(i + 1) divides r_i , omega_i))) .
$<wip-delta-tracking-estimator>


#parec[
  Consider next the discrete choice among the three types of scattering event. The probabilities $p_e$ are all of the form $sigma_({ a , s , n }) \/ sigma_(upright("maj"))$, according to which type of scattering event was chosen at each vertex. The $(sigma_(upright("maj")))^n$ factor in @eqt:wip-delta-tracking-estimator cancels, leaving us with
][
  接下来考虑三种散射事件类型之间的离散选择。概率 $p_e$ 的形式都是 $sigma_({ a , s , n }) \/ sigma_(upright("maj"))$，根据在每个顶点选择的散射事件类型。@eqt:wip-delta-tracking-estimator 中的 $(sigma_(upright("maj")))^n$ 因子被抵消，留下
]

$
  hat(P) ( upright(p)_(n^(‾)) ) = frac((product_(i = 1)^(n - 1) hat(f) (upright(p)_(i + 1) arrow.r upright(p)_i arrow.r upright(p)_(i - 1))) hat(L)_e (upright(p)_n arrow.r upright(p)_(n - 1)), (product_(i = 1)^n sigma_({ a , s , n }_i) (upright(p)_i)) (product_(i = 1)^(m - 1) p_omega (omega_(i + 1) divides r_i , omega_i))) .
$


#parec[
  The first $n - 1$ $sigma_({ a , s , n })$ factors must be either real or null scattering, and the last must be $sigma_a$, given how the path was sampled. Thus, the estimator is equivalent to
][
  前 $n - 1$ 个 $sigma_({ a , s , n })$ 因子必须是实散射或空散射，最后一个必须是 $sigma_a$，根据路径的采样方式。因此，估计量等同于
]

$
  hat(P) ( macron(upright(p))_n ) = frac((product_(i = 1)^(n - 1) hat(f) (upright(p)_(i + 1) arrow.r upright(p)_i arrow.r upright(p)_(i - 1))) hat(L)_e (upright(p)_n arrow.r upright(p)_(n - 1)), (product_(i = 1)^(n - 1) sigma_({ s , n }_i) (upright(p)_i)) sigma_a (upright(p)_n) (product_(i = 1)^(m - 1) p_omega (omega_(i + 1) divides r_i , omega_i))) .
$<delta-tracking-wip2>


#parec[
  Because we are for now neglecting surface scattering, $hat(f)$ represents either regular volumetric scattering or null scattering. Recall from @eqt:scatfun-generalized that $hat(f)$ includes a $sigma_s$ or $sigma_n$ factor in those respective cases, which cancels out all the corresponding factors in the $sigma_({s, n})$ product in the denominator. Further, note that the Heaviside function for null scattering's $hat(f)$ function is always 1 given how vertices are sampled with path tracing, so we can also restrict ourselves to the remaining $m$ real-scattering events in the numerator.
][
  由于我们目前忽略了表面散射， $hat(f)$ 代表常规体积散射或零散射。回忆一下@eqt:scatfun-generalized 中提到的， $hat(f)$ 在这些情况下包含一个 $sigma_s$ 或 $sigma_n$ 因子，从而抵消分母中 $sigma_({ s , n })$ 乘积的所有对应因子。 此外，请注意，由于路径追踪中顶点的采样方式，零散射的 $hat(f)$ 函数的 Heaviside 函数始终为 1，因此我们也可以将自己限制在分子中剩余的 $m$ 个真实散射事件。
]

#parec[
  Our estimator simplifies to
][
  我们的估计器简化为
]

$
  hat(P) (overline(p)_n) = ( product_(i = 1)^(m - 1) frac(p (r_(i - 1) arrow.r r_i arrow.r r_(i + 1)), p_omega (omega_(i + 1) \| r_i , omega_i)) ) frac(hat(L)_e (p_n arrow.r p_(n - 1)), sigma_a (p_n)) .
$<delta-tracking-path-estimator>

#parec[
  The $sigma_a$ factor in the path space emission function, @eqt:path-space-emission-function, cancels the remaining $sigma_a (p_n)$. We are left with the emission $L_e (p_n arrow.r p_(n - 1))$ at the last vertex scaled by the product of ratios of phase function values and sampling probabilities as the estimator's value, just as we saw in @evaluating-the-equation-of-transfer.
][
  路径空间发射函数方程 (#link("<eq:path-space-emission-function>")[14.10];) 中的 $sigma_a$ 因子抵消了剩余的 $sigma_a (p_n)$。 最后一个顶点的发射 $L_e (p_n arrow.r p_(n - 1))$ 被相函数值与采样概率比率的乘积缩放，这与我们在 @evaluating-the-equation-of-transfer 中所见一致。
]
