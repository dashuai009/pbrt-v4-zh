#import "../template.typ": parec, ez_caption

== Transmittance
<Transmittance>

#parec[
  The scattering processes in @volume-scattering-processes are all specified in terms of their local effect at points in space. However, in rendering, we are usually interested in their aggregate effects on radiance along a ray, which usually requires transforming the differential equations to integral equations that can be solved using Monte Carlo. The reduction in radiance between two points on a ray due to extinction is a quantity that will often be useful; for example, we will need to estimate this value to compute the attenuated radiance from a light source that is incident at a point on a surface in scenes with participating media.
][
  @volume-scattering-processes 中的散射过程都是根据它们在空间点上的局部效应来指定的。然而，在渲染中，我们通常对它们沿着光线对辐射亮度的整体效应感兴趣，这通常需要将微分方程转换为可以使用蒙特卡罗方法求解的积分方程。 由于消光导致的光线在两点之间辐射亮度的减少是一个常用的量；例如，我们需要估计这个值来计算在有参与介质的场景中从光源到达表面某一点的衰减辐射亮度。
]

#parec[
  Given the attenuation coefficient $sigma_t$, the differential equation that describes extinction,
][
  给定衰减系数 $sigma_t$，描述消光的微分方程为
]

$
  frac(d L_o (p comma omega), d t) = - sigma_t (p, omega) L_i (p, - omega),
$<volume-attenuation-differential>
#parec[
  can be solved to find the _beam transmittance_ $T_r$, which gives the fraction of radiance that is transmitted between two points:
][
  可以求解得到_光束透射率_ $T_r$，它给出了在两点之间传输的辐射亮度的比例：
]

$
  T_r (p arrow.r p') = e^(-integral_0^d sigma_t (p + t omega, omega) thin d t),
$<beam-transmittance>

#parec[
  where $d = norm(p - p prime)$ is the distance between $p$ and $p prime$, and $omega$ is the normalized direction vector between them. Note that the transmittance is always between 0 and 1. Thus, if exitant radiance from a point $upright(p)$ on a surface in a given direction $omega$ is given by $L_o (p, omega)$, then after accounting for extinction the incident radiance at another point $p prime$ in direction $- omega$ is
][
  其中 $d = norm(p - p prime)$ 是 $p$ 和 $p prime$ 之间的距离， $omega$ 是它们之间的归一化方向向量。注意，透射率总是在0和1之间。因此，如果在给定方向 $omega$ 上从表面某一点 $upright(p)$ 发出的辐射亮度为 $L_o (p, omega)$，那么考虑消光效应后，另一个点 $p prime$ 在方向 $- omega$ 上的入射辐射亮度为
]

$
  T_r (p -> p') L_o (p, omega) .
$
#parec[
  This idea is illustrated in @fig:fig-beam-transmittance.
][
  这一概念在@fig:fig-beam-transmittance 中有所展示。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f09.svg"),
  caption: [
    #ez_caption[
      The beam transmittance $T_r (upright(p) -> upright(p) prime)$ gives the fraction of light transmitted from one point to another, accounting for absorption and out scattering, but ignoring emission and in scattering. Given exitant radiance at a point $upright(p)$ in direction $omega$ (e.g., reflected radiance from a surface), the radiance visible at another point $p prime$ along the ray is $T_r (upright(p) -> upright(p) prime) L_o (upright(p), omega)$ .
    ][
      The beam transmittance gives the fraction of light transmitted from one point to another, accounting for absorption and out scattering, but ignoring emission and in scattering. Given exitant radiance at a point in direction (e.g., reflected radiance from a surface), the radiance visible at another point along the ray is .
    ]
  ],
)<fig-beam-transmittance>

#parec[
  Not only is transmittance useful for modeling the attenuation of light within participating media, but accounting for transmittance along shadow rays makes it possible to accurately model shadowing on surfaces due to the effect of media; see Figure 11.10.
][
  透射率不仅对模拟参与介质中的光衰减有用，而且在阴影光线中考虑透射率可以准确模拟由于介质效应导致的表面阴影；见图11.10。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f10.svg"),
  caption: [
    #ez_caption[
      Shadow-Casting Volumetric Bunny. The bunny, which is modeled entirely with participating media, casts a shadow on the ground plane because it attenuates light from the sun (which is to the left) on its way to the ground. (Bunny courtesy of the Stanford Computer Graphics Laboratory; volumetric enhancement courtesy of the OpenVDB sample model repository.)
    ][
      Shadow-Casting Volumetric Bunny. The bunny, which is modeled entirely with participating media, casts a shadow on the ground plane because it attenuates light from the sun (which is to the left) on its way to the ground. (Bunny courtesy of the Stanford Computer Graphics Laboratory; volumetric enhancement courtesy of the OpenVDB sample model repository.)
    ]
  ],
)

#parec[
  Two useful properties of beam transmittance are that transmittance from a point to itself is $T_r(p-> p) = 1$, and in a vacuum $sigma_t = 0$ and so $T_r(p -> p prime) = 1$ for all $p prime$. Furthermore, if the attenuation coefficient satisfies the directional symmetry $sigma_t(omega) = sigma_t(-omega)$ or does not vary with direction $omega$ and only varies as a function of position, then the transmittance between two points is the same in both directions:
][
  光束透射率有两个有用的性质：从一个点到自身的透射率为 $T_r(p-> p) = 1$ ；在真空中， $sigma_t = 0$，因此对于所有 $p prime$， $T_r(p -> p prime) = 1$。 此外，如果衰减系数满足方向对称性 $sigma_t(omega) = sigma_t(-omega)$ 或者不随方向 $omega$ 变化而仅随位置变化，那么两点之间的透射率在两个方向上是相同的：
]


$
  T_r(p -> p prime) =T_r (p prime -> p)
$
#parec[
  This property follows directly from @eqt:beam-transmittance.
][
  这个性质直接从@eqt:beam-transmittance 中得出。
]


#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f11.svg"),
  caption: [
    A useful property of beam transmittance is that it is multiplicative: the transmittance between points $p$ and $p ''$ on a ray like the one shown here is equal to the transmittance from $p$ to $p '$ times the transmittance from $p '$ to $p ''$ for all points $p'$ between $p$ and $p''$.
  ],
)<mult-beam-transmittance>


#parec[
  Another important property, true in all media, is that transmittance is multiplicative along points on a ray:
][
  在所有介质中，透射率沿光线上的点具有乘法性质，这是一项重要的性质：
]


$
  T_r (p arrow.r p prime.double) = T_r (p arrow.r p prime) T_r (p prime arrow.r p prime.double) ,
$<beam-transmittance-mult>


#parec[
  for all points $p prime$ between $p$ and $p prime.double$ (@fig:mult-beam-transmittance). This property is useful for volume scattering implementations, since it makes it possible to incrementally compute transmittance at multiple points along a ray: transmittance from the origin to a point $T_r (o arrow.r p)$ can be computed by taking the product of transmittance to a previous point $T_r (o arrow.r p prime)$ and the transmittance of the segment between the previous and the current point $T_r (p prime arrow.r p)$.
][
  对于所有在 $p$ 和 $p prime.double$ 之间的点 $p prime$ （@fig:mult-beam-transmittance）。这个性质在实现体积散射时非常有用，因为它允许沿光线在多个点上逐步计算透射率：从起点到某一点的透射率 $T_r (o arrow.r p)$ 可以通过将到前一个点的透射率 $T_r (o arrow.r p prime)$ 和前一个点与当前点之间段的透射率 $T_r (p prime arrow.r p)$ 相乘来计算。
]

#parec[
  The negated exponent in the definition of $T_r$ in @eqt:beam-transmittance is called the optical thickness between the two points. It is denoted by the symbol $tau$ :
][
  在@eqt:beam-transmittance 中 $T_r$ 的定义中，负指数被称为两点之间的_光学厚度_。它用符号 $tau$ 表示：
]

$ tau (p arrow.r p prime) = integral_0^d sigma_t (p + t omega , omega) thin d t . $

#parec[
  In a homogeneous medium, $sigma_t$ is a constant, so the integral that defines $tau$ is trivially evaluated, giving _Beer's law_:
][
  在均匀介质中， $sigma_t$ 是一个常数。因此，定义 $tau$ 的积分可以简单地计算，得到_比尔定律_：
]

$ T_r (p arrow.r p prime) = e^(- sigma_t d) . $ <beer>

#parec[
  It may appear that a straightforward application of Monte Carlo could be used to compute the beam transmittance in inhomogeneous media. @eqt:beam-transmittance consists of a 1D integral over a ray's parametric $t$ position that is then exponentiated; given a method to sample distances along the ray $t prime$ according to some distribution $p$, one could evaluate the estimator:
][
  看似可以直接应用蒙特卡罗方法来计算非均匀介质中的光束透射率。@eqt:beam-transmittance 包含一个光线参数化 $t$ 位置上的一维积分，然后进行指数运算；给定一种方法根据某种分布 $p$ 采样沿光线的距离 $t prime$，可以评估估计器：
]

$
  e^(-integral_0^d sigma_t (p + t omega, omega) thin d t) approx e^(-[ frac(sigma_t (p + t' omega comma omega), p(t')) ]) .
$<biased-beam-transmittance>


#parec[
  However, even if the estimator in square brackets is an unbiased estimator of the optical thickness along the ray, the estimate of transmittance is not unbiased and will actually underestimate its value: $E [e^(- X)] eq.not e^(- E [X])$ (This state of affairs is explained by _Jensen's inequality_ and the fact that $e^(- x)$ is a convex function.)
][
  然而，即使方括号中的估计器是光线沿途光学厚度的无偏估计，透射率的估计不是无偏的，实际上会低估其值： $E [e^(- X)] eq.not e^(- E [X])$ （这种情况由_詹森不等式_解释，并且 $e^(- x)$ 是一个凸函数。）
]

#parec[
  The error introduced by estimators of the form of @eqt:biased-beam-transmittance decreases as error in the estimate of the beam transmittance decreases. For many applications, this error may be acceptable—it is still widespread practice in graphics to estimate $tau$ in some manner, e.g., via a Riemann sum, and then to compute the transmittance that way. However, it is possible to derive an alternative equation for transmittance that allows unbiased estimation; that is the approach used in `pbrt`.
][
  @eqt:biased-beam-transmittance 形式的估计器引入的误差随着光束透射率估计误差的减少而减少。对于许多应用，这种误差可能是可以接受的——在图形学中仍然广泛采用某种方式估计 $tau$，例如通过黎曼和，然后以这种方式计算透射率。然而，可以推导出一个允许无偏估计的透射率替代方程；这就是`pbrt`中使用的方法。
]

#parec[
  First, we will consider the change in radiance between two points $p$ and $p prime$ along the ray. Integrating @eqt:volume-attenuation-differential and dropping the directional dependence of $sigma_t$ for notational simplicity, we can find that
][
  首先，我们将考虑沿光线在两个点 $p$ 和 $p prime$ 之间的辐射度变化。通过积分方程@eqt:volume-attenuation-differential 并为了简化记号省略 $sigma_t$ 的方向依赖性，我们可以发现
]

$
  integral_0^d frac(d L (p + t omega), d t) thin d t = L (p prime) - L (p) = integral_0^d - sigma_t (p + t omega) L ( p + t omega ) thin d t ,
$<volterra-transmittance-radiance>


#parec[
  where, as before, $d$ is the distance between $p$ and $p prime$ and $omega$ is the normalized vector from $p$ to $p prime$.
][
  其中，如前所述， $d$ 是 $p$ 和 $p prime$ 之间的距离， $omega$ 是从 $p$ 到 $p prime$ 的单位向量。
]

#parec[
  The transmittance is the fraction of the original radiance, and so $T_r (p arrow.r p prime) = frac(L (p prime), L (p))$ . Thus, if we divide @eqt:volterra-transmittance-radiance by $L (p)$ and rearrange terms, we can find that
][
  透射率是原始辐射度的分数，因此 $T_r (p arrow.r p prime) = frac(L (p prime), L (p))$ 。因此，如果我们将@eqt:volterra-transmittance-radiance 除以 $L (p)$ 并重新排列项，我们可以发现
]


$
  T_r (p arrow.r p prime) = 1 - integral_0^d sigma_t (p + t omega) T_r (p + t omega arrow.r p prime) d t .
$<volterra-Transmittance>


#parec[
  We have found ourselves with transmittance defined recursively in terms of an integral that includes transmittance in the integrand; although this may seem to be making the problem more complex than it was before, this definition makes it possible to apply Monte Carlo to the integral and to compute unbiased estimates of transmittance. However, it is difficult to sample this integrand well; in practice, estimates of it will have high variance. Therefore, the following section will introduce an alternative formulation of it that is amenable to sampling and makes a number of efficient solution techniques possible.
][
  我们发现透射率以递归的方式定义为一个包含透射率的积分。这虽然看起来使问题比以前更复杂，但这种定义使得可以对积分应用蒙特卡罗方法并计算透射率的无偏估计。 然而，很难对这个被积函数进行良好的采样；在实践中，对它的估计将具有高方差。因此，接下来的部分将介绍一种替代的公式，它更易于采样，并使多种高效的解决技术成为可能。
]

=== Null scattering
<null-scattering>

#parec[
  The key idea that makes it possible to derive a more easily sampled transmittance integral is an approach known as _null scattering_. Null scattering is a mathematical formalism that can be interpreted as introducing an additional type of scattering that does not correspond to any type of physical scattering process but is specified so that it has no effect on the distribution of light. In doing so, null scattering makes it possible to treat inhomogeneous media as if they were homogeneous, which makes it easier to apply sampling algorithms to inhomogeneous media.(In Chapter 14, we will see that it is a key foundation for volumetric light transport algorithms beyond transmittance estimation.)
][
  使透射率积分更易于采样的关键思想是一种称为_虚散射_的方法。 虚散射是一种数学形式，可以解释为引入一种额外的散射类型，这种散射不对应于任何物理散射过程，但被指定为对光的分布没有影响。 通过这样做，虚散射使得可以将非均匀介质视为均匀介质，从而更容易在非均匀介质中应用采样算法。(In Chapter 14, we will see that it is a key foundation for volumetric light transport algorithms beyond transmittance estimation.)
]
#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f12.svg"),
  caption: [
    #ez_caption[
      If the null-scattering coefficient is defined using a majorant $sigma_("maj")$ as in @eqt:sigman-from-sigmamaj, then it can be interpreted as taking (a) an inhomogeneous medium (dark circles) and (b) filling it with fictitious particles (light circles) until it reaches a uniform density.
    ][
      If the null-scattering coefficient is defined using a majorant $sigma_("maj")$ as in @eqt:sigman-from-sigmamaj, then it can be interpreted as taking (a) an inhomogeneous medium (dark circles) and (b) filling it with fictitious particles (light circles) until it reaches a uniform density.

    ]
  ],
)
#parec[
  We will start by defining the null-scattering coefficient $sigma_n$. Similar to the other scattering coefficients, it gives the probability of a null-scattering event per unit distance traveled in the medium. Here, we will define $sigma_n (p)$ via a constant majorant $sigma_(m a j)$ that is greater than or equal to $sigma_a + sigma_s$ at all points in the medium:#footnote[The attentive reader will note that for some of the following Monte Carlo estimators based on null scattering, there is no
mathematical requirement that $sigma_upright(n)$ must be positive and that thus, the so-called majorant is not necessarily greater than or equal to σ<sub>a</sub>+σ<sub>s</sub>. It turns out that Monte Carlo estimators that include negative σ<sub>n</sub>
values tend to have high variance, so in practice actual majorants are used.]
][
  我们将从定义虚散射系数 $sigma_n$ 开始。 与其他散射系数类似，它给出了在介质中每单位距离发生虚散射事件的概率。 在这里，我们将通过一个常数上界 $sigma_(m a j)$ 来定义 $sigma_n (p)$，该常数在介质中的所有点上都大于或等于 $sigma_a + sigma_s$ ： #footnote[The attentive reader will note that for some of the
following Monte Carlo estimators based on null scattering, there is no
mathematical requirement that σ<sub>n</sub> must be positive and that thus, the so-called
majorant is not necessarily greater than or equal to σ<sub>a</sub>+σ<sub>s</sub>.
It turns out that Monte Carlo estimators that include negative σ<sub>n</sub>
values tend to have high variance, so in practice actual majorants are used.]
]


$
  sigma_(upright(n))(upright(p), omega) =sigma_"maj"- sigma_t (upright(p), omega)
$<sigman-from-sigmamaj>
#parec[
  Thus, the total scattering coefficient $sigma_a + sigma_s + sigma_n = sigma_(m a j)$ is uniform throughout the medium.(This idea is illustrated in Figure 11.12.)
][
  因此，总散射系数 $sigma_a + sigma_s + sigma_n = sigma_(m a j)$ 在整个介质中是均匀的。(This idea is illustrated in Figure 11.12.)
]

#parec[
  With this definition of $sigma_n$, we can rewrite Equation 11.4 in terms of the majorant and the null-scattering coefficient:
][
  通过这个 $sigma_n$ 的定义，我们可以将方程 11.4 重写为上界和虚散射系数的形式：
]

$
  frac(d L_o (p , omega), d t) = - (sigma_(m a j) - sigma_n (p , omega)) L_i (p , - omega) .
$ <volume-null-attenuation-differential>

#parec[
  We will not include the full derivation here, but just as with @eqt:volterra-Transmittance, this equation can be integrated over the segment of a ray and divided by the initial radiance $L (p)$ to find an equation for the transmittance. The result is:
][
  我们在此不包括完整的推导过程，但就像@eqt:volterra-Transmittance 一样，这个方程可以在光线段上积分并除以初始辐射率 $L (p)$ 以找到透射率的方程。 结果是：
]


$
  T_r (p arrow.r p prime) = e^(- sigma_(m a j) d) + integral_0^d e^(- sigma_(m a j) t) sigma_n (p + t omega) T_r ( p + t omega arrow.r p prime ) d t .
$<volterra-null-transmittance>



#parec[
  Note that with this expression of transmittance and a homogeneous medium, $sigma_n = 0$ and the integral disappears. The first term then corresponds to Beer's law. For inhomogeneous media, the first term can be seen as computing an underestimate of the true transmittance, where the integral then accounts for the rest of it.
][
  请注意，对于这种透射率表达式和均匀介质， $sigma_n = 0$，积分项消失。此时，第一项对应于比尔定律。对于非均匀介质，第一项可以看作是对真实透射率的低估，其中积分项则补偿其余部分。
]

#parec[
  To compute Monte Carlo estimates of @eqt:volterra-null-transmittance, we would like to sample a distance $t prime$ from some distribution that is proportional to the integrand and then apply the regular Monte Carlo estimator. A convenient sampling distribution is the probability density function (PDF) of the exponential distribution that is derived in Section~#link("../Sampling_Algorithms/Sampling_1D_Functions.html#sec:exponential-sampling")[A.4.2];. In this case, the PDF associated with $e^(- sigma_"maj" t)$ is
][
  要计算@eqt:volterra-null-transmittance 的蒙特卡罗估计，我们希望从某个与被积函数成比例的分布中采样一个距离 $t prime$，然后应用常规的蒙特卡罗估计器。一种方便的采样分布是指数分布的概率密度函数（PDF），该分布在第#link("../Sampling_Algorithms/Sampling_1D_Functions.html#sec:exponential-sampling")[A.4.2];节中推导出。在这种情况下，与 $e^(- sigma_"maj" t)$ 相关的PDF是
]

$ p_("maj") (t) = sigma_("maj") e^(- sigma_"maj" t) . $


#parec[
  and a corresponding sampling recipe is available via the #link("../Sampling_Algorithms/Sampling_1D_Functions.html#SampleExponential")[`SampleExponential()`] function.
][
  并且可以通过#link("../Sampling_Algorithms/Sampling_1D_Functions.html#SampleExponential")[`SampleExponential()`];函数获得相应的采样方案.
]

#parec[
  Because $p_("maj")$ is nonzero over the range $\[ 0 , oo \)$, the sampling algorithm will sometimes generate samples $t prime > d$, which may seem to be undesirable. However, although we could define a PDF for the exponential function limited to $[0 , d]$, sampling from $p_"maj"$ leads to a simple way to terminate the recursive evaluation of transmittance. To see why, consider rewriting the second term of Equation~#link("<eq:volterra-null-transmittance>")[11.13] as the sum of two integrals that cover the range $\[ 0 , oo \)$ :
][
  由于 $p_("maj")$ 在 $\[ 0 , oo \)$ 范围内非零，采样算法有时会生成 $t prime > d$ 的样本，这似乎不理想。然而，尽管我们可以为限制在 $[0 , d]$ 的指数函数定义一个PDF，但从 $p_"maj"$ 采样提供了一种简单的方法来终止透射率的递归评估。为了理解原因，可以将@eqt:volterra-null-transmittance 的第二项重写为覆盖范围 $\[ 0 , oo \)$ 的两个积分之和：
]

$
  integral_0^d e^(- sigma_m t) sigma_n (p + t omega) T_r (p + t omega arrow.r p prime) d t + integral_d^oo 0 thin d t .
$


#parec[
  If the Monte Carlo estimator is applied to this sum, we can see that the value of $t prime$ with respect to $d$ determines which integrand is evaluated and thus that sampling $t prime > d$ can be conveniently interpreted as a condition for ending the recursive estimation of @eqt:volterra-null-transmittance .
][
  如果将蒙特卡罗估计器应用于这个和，我们可以看到 $t prime$ 相对于 $d$ 的值决定了哪个被积函数被评估，因此采样 $t prime > d$ 可以方便地解释为结束@eqt:volterra-null-transmittance 递归估计的条件。
]

#parec[
  Given the decision to sample from $p_( m a j)$, perhaps the most obvious approach for estimating the value of @eqt:volterra-null-transmittance is to sample $t prime$ in this way and to directly apply the Monte Carlo estimator, which gives
][
  鉴于决定从 $p_(  m a j)$ 采样，估计@eqt:volterra-null-transmittance 值的最明显方法可能是以这种方式采样 $t prime$ 并直接应用蒙特卡罗估计器，这给出
]

$
  T_r ( p arrow.r p prime ) approx e^(- sigma_"maj" d) + cases(delim: "{", frac(sigma_n (p + t prime omega), sigma_"maj") T_r (p + t prime omega arrow.r p prime) & t prime < d, 0 & upright("otherwise") .)
$ <transmittance-next-flight>

#parec[
  This estimator is known as the #emph[next-flight estimator];. It has the advantage that it has zero variance for homogeneous media, although interestingly it is often not as efficient as other estimators for inhomogeneous media.
][
  这种估计器被称为#emph[下次飞行估计器];。它的优点是对均匀介质具有零方差，尽管有趣的是，对于非均匀介质，它通常不如其他估计器高效。
]

#parec[
  Other estimators randomly choose between the two terms of @eqt:volterra-null-transmittance and only evaluate one of them. If we define $p_e$ as the discrete probability of evaluating the first term, transmittance can be estimated by
][
  其他估计器在@eqt:volterra-null-transmittance 的两个项之间随机选择并仅评估其中一个。如果我们将 $p_e$ 定义为评估第一项的概率，则透射率可以通过以下方式估计：
]

$
  T_r ( p arrow.r p prime ) approx cases(e^(- sigma_"maj" d) / p_e & upright("with probability ") p_e, frac(1, 1 - p_e) integral_0^d e^(- sigma_m t) sigma_n (
    p + t omega
  ) T_r (p + t omega arrow.r p prime) d t & upright("otherwise") ) .
$<transmittance-choose-one>


#parec[
  The #emph[ratio tracking] estimator is the result from setting $p_e = e^(- sigma_"maj" d)$. Then, the first case of Equation~#link("<eq:transmittance-choose-one>")[11.16] yields a value of~1. We can further combine the choice between the two cases with sampling $t prime$ using the fact that the probability that $t prime > d$ is equal to $e^(- sigma_"maj" d)$. (This can be seen using $p_( m a j)$ 's cumulative distribution function (CDF), Equation~#link("../Sampling_Algorithms/Sampling_1D_Functions.html#eq:exponential-cdf")[A.17];.) After simplifying, the resulting estimator works out to be:
][
  #emph[比率跟踪];估计器是通过设置 $p_e = e^(- sigma_"maj" d)$ 得到的。然后，方程#link("<eq:transmittance-choose-one>")[11.16];的第一种情况产生的值为1。我们可以进一步结合两种情况之间的选择与采样 $t prime$，利用 $t prime > d$ 的概率等于 $e^(- sigma_"maj" d)$ 这一事实。（这可以通过 $p_( m a j)$ 的累积分布函数（CDF），方程#link("../Sampling_Algorithms/Sampling_1D_Functions.html#eq:exponential-cdf")[A.17];来看到。）简化后，得到的估计器为：
]


$
  T_r ( p arrow.r p prime ) approx cases( 1 & t prime > d, frac(sigma_n (p + t prime omega), sigma_(m a j)) T_r (p + t prime omega arrow.r p prime) & upright("otherwise"))
$<transmittance-ratio-tracking>

#parec[
  If the recursive evaluations are expanded out, ratio tracking leads to an estimator of the form
][
  如果展开递归评估，比率跟踪会导致一个形式为的估计器
]

$ T_r (p arrow.r p prime) approx product_(i = 1)^n frac(sigma_n (p + t_i omega), sigma_(m a j)) , $

#parec[
  where $t_i$ are the series of $t$ values that are sampled from $p_(m a j)$ and where successive $t_i$ values are sampled starting from the previous one until one is sampled past the endpoint. Ratio tracking is the technique that is implemented to compute transmittance in pbrt's light transport routines in Chapter~14.
][
  其中 $t_i$ 是从 $p_(m a j)$ 采样的一系列 $t$ 值，并且连续的 $t_i$ 值从前一个开始采样，直到一个采样超过终点。比率跟踪是实现于 pbrt 的光传输例程中的技术，见第~14章。
]

#parec[
  A disadvantage of ratio tracking is that it continues to sample the medium even after the transmittance has become very small. Russian roulette can be used to terminate recursive evaluation to avoid this problem. If the Russian roulette termination probability at each sampled point is set to be equal to the ratio of $sigma_n$ and $sigma_(m a j)$, then the scaling cancels and the estimator becomes
][
  比率跟踪的一个缺点是，即使透射率已经变得非常小，它仍然继续对介质进行采样。可以使用俄罗斯轮盘赌来终止递归评估以避免这个问题。如果在每个采样点的俄罗斯轮盘赌终止概率设置为 $sigma_n$ 和 $sigma_(m a j)$ 的比率，那么缩放会被抵消，估计器变为
]

$
  T_r ( p arrow.r p prime ) approx cases(delim: "{", 1 & t' > d, T_r (p + t prime omega arrow.r p prime) "  " & t prime <= d "with probability " frac(sigma_n (p + t prime omega), sigma_"maj"), 0 & upright("otherwise ") )
$


#parec[
  Thus, recursive estimation of transmittance continues either until termination due to Russian roulette or until the sampled point is past the endpoint. This approach is the _track-length transmittance estimator_, also known as delta tracking.
][
  因此，透射率的递归估计要么由于俄罗斯轮盘赌终止，要么直到采样点超过终点。该方法是_轨迹长度透射率估计器_，也称为德尔塔跟踪。
]

#parec[
  A physical interpretation of delta tracking is that it randomly decides whether the ray interacts with a true particle or a fictitious particle at each scattering event. Interactions with fictitious particles (corresponding to null scattering) are ignored and the algorithm continues, restarting from the sampled point. Interactions with true particles cause extinction, in which case~0 is returned. If a ray makes it through the medium without extinction, the value~1 is returned.
][
  德尔塔跟踪的物理解释是，它随机决定光线在每个散射事件中是与真实粒子还是假想粒子相互作用。与假想粒子（对应于虚无散射）的相互作用被忽略，算法继续，从采样点重新开始。与真实粒子的相互作用导致消光，在这种情况下返回 0。如果光线通过介质而没有消光，则返回值 1。
]

#parec[
  Delta tracking can also be used to sample positions $t$ along a ray with probability proportional to $sigma_t (t) T_r (t)$. The algorithm is given by the following pseudocode, which assumes that the function `u()` generates a uniform random number between~0 and~1 and where the recursion has been transformed into a loop:
][
  德尔塔跟踪还可以用于以与 $sigma_t (t) T_r (t)$ 成比例的概率沿光线采样位置 $t$。算法由以下伪代码给出，假设函数 `u()` 生成一个介于 0 和 1 之间的均匀随机数，并且递归已被转换为循环：
]

```cpp
optional<Point> DeltaTracking(Point p, Vector w, Float sigma_maj, Float d) {
    Float t = SampleExponential(u(), sigma_maj);
    while (t < d) {
       Float sigma_n = /* evaluate sigma_n at p + t * w */;
       if (u() < sigma_n / sigma_maj)
           t += SampleExponential(u(), sigma_maj);
       else
           return p + t * w;
    }
    return {}; /* no sample before d */
}
```


