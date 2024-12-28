#import "../template.typ": parec, ez_caption

== Path Tracing

#parec[
  Now that we have derived the path integral form of the light transport equation, we will show how it can be used to derive the #emph[path-tracing] light transport algorithm and will present a path-tracing integrator. @fig:path-tracing-example compares images of a scene rendered with different numbers of pixel samples using the path-tracing integrator. In general, hundreds or thousands of samples per pixel may be necessary for high-quality results.
][
  现在我们已经推导出了光传输方程的路径积分形式，我们将展示如何使用它来推导路径追踪光传输算法，并介绍一个路径追踪积分器。 @fig:path-tracing-example 比较了使用路径追踪积分器渲染的场景图像，采用不同数量的像素样本。一般来说，为了获得高质量的结果，每个像素可能需要数百或数千个样本。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f04.svg"),
  caption: [
    #ez_caption[
      Kroken Scene Rendered with Path Tracing. (a) Rendered with path tracing with 8192 samples per pixel. (b) Rendered with just 8 samples per pixel, giving the characteristic grainy noise that is the hallmark of variance. Although the second image appears darker, the average pixel values of both are actually the same; very large values in some of its pixels cannot be displayed in print. (Scene courtesy of Angelo Ferretti.)
    ][
      使用路径追踪渲染的Kroken场景。(a) 使用路径追踪渲染，每个像素有8192个采样点。(b) 仅使用8个采样点渲染，产生了典型的颗粒状噪声，这是方差的标志。尽管第二张图看起来较暗，但两张图的平均像素值实际上是相同的；其中一些像素的非常大值无法在印刷中显示出来。(场景由 Angelo Ferretti 提供。)
    ]
  ],
)<path-tracing-example>

#parec[
  Path tracing was the first general-purpose unbiased Monte Carlo light transport algorithm used in graphics. Kajiya (1986) introduced it in the same paper that first described the light transport equation. Path tracing incrementally generates paths of scattering events starting at the camera and ending at light sources in the scene.
][
  路径追踪是图形学中使用的第一个通用无偏蒙特卡罗光传输算法。Kajiya在1986年首次描述光传输方程的同一篇论文中引入了它。路径追踪逐步生成从摄像机开始到场景中光源结束的散射事件路径。
]

#parec[
  Although it is slightly easier to derive path tracing directly from the basic light transport equation, we will instead approach it from the path integral form, which helps build understanding of the path integral equation and makes the generalization to bidirectional path sampling algorithms easier to understand.
][
  尽管直接从基本光传输方程推导路径追踪稍微容易一些，但我们将从路径积分形式入手，这有助于理解路径积分方程，并使得广义到双向路径采样算法更易于理解。
]

=== Overview
<path-tracing-overview>

#parec[
  Given the path integral form of the LTE, we would like to estimate the value of the exitant radiance from the camera ray's intersection point $p_1$,
][
  给定LTE的路径积分形式，我们希望估计从摄像机射线的交点 $p_1$ 发出的辐射亮度的值，
]

$ L (p_1 arrow.r p_0) = sum_(i = 1)^oo P (macron(upright(p))_i) , $

#parec[
  for a given camera ray from $p_0$ that first intersects the scene at $p_1$. We have two problems that must be solved in order to compute this estimate:
][
  对于从 $p_0$ 出发的给定摄像机射线，首先与场景在 $p_1$ 相交。我们必须解决两个问题才能计算出这个估计值：
]

#parec[
  + How do we estimate the value of the sum of the infinite number of
    $P (macron(upright(p))_i)$ terms with a finite amount of computation?
][
  #block[
    #set enum(numbering: "1.", start: 1)
    + 如何在有限的计算量下估计无限数量的$P (macron(upright(p))_i)$项的和的值？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + Given a particular $P (macron(upright(p))_i)$ term, how do we generate one or more
      paths $macron(upright(p))$ in order to compute a Monte Carlo estimate of its
      multidimensional integral?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + 给定一个特定的$P (macron(upright(p))_i)$项，如何生成一个或多个路径$macron(upright(p))$以计算其多维积分的蒙特卡罗估计？
  ]
]

#parec[
  For path tracing, we can take advantage of the fact that for physically valid scenes, paths with more vertices scatter less light than paths with fewer vertices overall (this is not necessarily true for any particular pair of paths, just in the aggregate). This is a natural consequence of conservation of energy in BSDFs. Therefore, we will always estimate the first few terms $P (macron(upright(p))_i)$ and will then start to apply Russian roulette to stop sampling after a finite number of terms without introducing bias. (Recall that @russian-roulette showed how to use Russian roulette to probabilistically stop computing terms in a sum as long as the terms that are not skipped are reweighted appropriately.) For example, if we always computed estimates of $P (macron(upright(p))_1)$, $P (macron(upright(p))_2)$, and $P (macron(upright(p))_3)$ but stopped without computing more terms with probability $q$, then an unbiased estimate of the sum would be
][
  对于路径追踪，我们可以利用这样一个事实：对于物理上有效的场景，具有更多顶点的路径比具有更少顶点的路径整体上散射的光更少（这对于任何特定的路径对不一定成立，只是在总体上）。 这是BSDF中能量守恒的自然结果。因此，我们将始终估计前几个项 $P (macron(upright(p))_i)$，然后开始应用俄罗斯轮盘赌，在有限数量的项后停止采样而不引入偏差。 （回想一下，@russian-roulette 展示了如何使用俄罗斯轮盘赌以概率方式停止计算和中的项，只要未跳过的项被适当地重新加权。） 例如，如果我们总是计算 $P (macron(upright(p))_1)$， $P (macron(upright(p))_2)$ 和 $P (macron(upright(p))_3)$ 的估计值，但以概率 $q$ 停止而不计算更多项，那么和的无偏估计将是
]

$
  P (macron(upright(p))_1) + P (macron(upright(p))_2) + P (macron(upright(p))_3) + frac(1, 1 - q) sum_(i = 4)^oo P (macron(upright(p))_i) .
$

#parec[
  Using Russian roulette in this way does not solve the problem of needing to evaluate an infinite sum but has pushed it a bit farther out.
][
  以这种方式使用俄罗斯轮盘赌并没有解决需要评估无限和的问题，但将其推得更远了一些。
]

#parec[
  If we take this idea a step further and instead randomly consider terminating evaluation of the sum at each term with probability $q_i$,
][
  如果我们更进一步，随机考虑在每个项处以概率 $q_i$ 终止和的评估，
]

$
  frac(1, 1 - q_1) (P (macron(upright(p))_1) + frac(1, 1 - q_2) (P (macron(upright(p))_2) + frac(1, 1 - q_3) (P (macron(upright(p))_3) + dots.h.c))) ,
$

#parec[
  we will eventually stop continued evaluation of the sum. Yet, because for any particular value of $i$ there is greater than zero probability of evaluating the term $P (macron(upright(p))_i)$ and because it will be weighted appropriately if we do evaluate it, the final result is an unbiased estimate of the sum.
][
  我们最终将停止这个和式的持续评估。然而，因为对于任何特定的 $i$ 值，评估项 $P (macron(upright(p))_i)$ 的概率大于零，并且如果我们评估它，它将被适当地加权，最终结果是和的无偏估计。
]

=== Path Sampling

#parec[
  Given this method for evaluating only a finite number of terms of the infinite sum, we also need a way to estimate the contribution of a particular term $P (macron(upright(p))_i)$. We need $i + 1$ vertices to specify the path, where the last vertex $p_i$ is on a light source and the first vertex $p_0$ is a point on the camera film or lens (@fig:path-vertices). Looking at the form of $P (macron(upright(p))_i)$, a multiple integral over surface area of objects in the scene, the most natural thing to do is to sample vertices $p_i$ according to the surface area of objects in the scene, such that all points on surfaces in the scene are sampled with equal probability. (We do not actually use this approach in the integrator implementations in this chapter for reasons that will be described later, but this sampling technique could possibly be used to improve the efficiency of our basic implementation and helps to clarify the meaning of the path integral LTE.)
][
  给定这种仅评估无限和的有限数量项的方法，我们还需要一种方法来估计特定项 $P (macron(upright(p))_i)$ 的贡献。 我们需要 $i + 1$ 个顶点来指定路径，其中最后一个顶点 $p_i$ 位于光源上，第一个顶点 $p_0$ 是摄像机胶片或镜头上的一个点（@fig:path-vertices）。 观察 $P (macron(upright(p))_i)$ 的形式，这是一个关于场景中物体表面积的多重积分，最自然的做法是根据场景中物体的表面积来采样顶点 $p_i$ ，使得场景中表面上的所有点都以相等的概率被采样。 （由于将在后面描述的原因，我们实际上并未在本章的积分器实现中使用这种方法，但这种采样技术可能用于提高我们基本实现的效率，并有助于阐明路径积分LTE的意义。）
]


#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f05.svg"),
  caption: [
    #ez_caption[
      A path $hat(p)_i$ of $i + 1$ vertices from the camera at $p$, intersecting a series of positions on surfaces in the scene, to a point on the light $p_i$. Scattering according to the BSDF occurs at each path vertex from $p_1$ to $p_(i-1)$ such that the radiance estimate at the camera due to this path is given by the product of the path throughput $T(macron(p)_i)$ and the emitted radiance from the light divided by the path sampling weights.
    ][
      一条包含 $i + 1$ 个顶点的路径 $macron(p)_i$，从相机位置 $p$ 出发，经过场景中一系列表面位置，最终到达光源上的某一点 $p_i$。在路径上的每个顶点，从 $p_1$ 到 $p_(i-1)$，根据 BSDF 进行散射。这条路径对相机处辐射亮度的估计，由路径吞吐量 $T(macron(p)_i)$ 与光源出射辐射亮度之积，再除以路径采样权重给出。
    ]
  ],
)<path-vertices>


#parec[
  With this sampling approach, we might define a discrete probability over the $n$ objects in the scene. If each has surface area $A_i$, then the probability of sampling a path vertex on the surface of the $i$ th object should be
][
  通过这种采样方法，我们可以在场景中的 $n$ 个物体上定义一个离散概率。 如果每个物体的表面积为 $A_i$，那么在第 $i$ 个物体表面上采样路径顶点的概率应为
]


$ p_i = frac(A_i, sum_j A_j) . $

#parec[
  Then, given a method to sample a point on the $i$ th object with uniform probability, the probability density function (PDF) for sampling any particular point on object $i$ is $1 \/ A_i$. Thus, the overall probability density for sampling the point is
][
  然后，给定一种方法以均匀概率在第 $i$ 个物体上采样一个点，则在物体 $i$ 上采样任何特定点的概率密度函数（PDF）为 $1 \/ A_i$。因此，采样该点的总体概率密度为
]

$ frac(A_i, sum_j A_j) 1 / A_i . $

#parec[
  and all samples $p_i$ have the same PDF value:
][
  所有样本 $p_i$ 的 PDF 值相同：
]

$ p_A (p_i) = frac(1, sum_j A_j) . $


#parec[
  It is reassuring that they all have the same weight, since our intent was to choose among all points on surfaces in the scene with equal probability.
][
  令人欣慰的是，它们都具有相同的权重，因为我们的目的是以相等的概率从场景中的所有表面点中进行选择。
]

#parec[
  Given the set of vertices $p_0 , p_1 , dots.h , p_(i - 1)$ sampled in this manner, we can then sample the last vertex $p_i$ on a light source in the scene, defining its PDF in the same way. Although we could use the same technique used for sampling path vertices to sample points on lights, this would usually lead to high variance, since for all the paths where $p_i$ was not on the surface of an emitter, the path would have zero value. The expected value would still be the correct value of the integral, but convergence would be extremely slow. A better approach is to sample over the areas of only the emitting objects with probabilities updated accordingly. Given a complete path, we have all the information we need to compute the estimate of $P (upright(bold(p))_i)$ ; it is just a matter of evaluating each of the terms.
][
  给定以这种方式采样的顶点集 $p_0 , p_1 , dots.h , p_(i - 1)$，我们可以在场景中的光源上采样最后一个顶点 $p_i$，以相同的方式定义其 PDF。 尽管我们可以使用用于采样路径顶点的相同技术来采样光源上的点，但这通常会导致高方差，因为对于所有 $p_i$ 不在发射器表面的路径，该路径的值将为零。 期望值仍然是积分的正确值，但收敛将非常缓慢。 更好的方法是仅在发射物体的区域上进行采样，并相应地更新概率。 给定完整路径，我们拥有计算 $P (upright(bold(p))_i)$ 估计所需的所有信息；这只是评估每个项的问题。
]

#parec[
  It is easy to be more creative about how we set the sampling probabilities with this general approach. For example, if we knew that indirect illumination from a few objects contributed to most of the lighting in the scene, we could assign a higher probability to generating path vertices $p_i$ on those objects, updating the sample weights appropriately.
][
  在这种通用方法下，设置采样概率时更具创造性是很容易的。 例如，如果我们知道场景中少数物体的间接照明贡献了大部分光照，我们可以为在这些物体上生成路径顶点 $p_i$ 分配更高的概率，并适当地更新样本权重。
]

#parec[
  However, there are two interrelated problems with sampling paths in this manner. The first can lead to high variance, while the second can lead to incorrect results. The first problem is that many of the paths will have no contribution if they have pairs of adjacent vertices that are not mutually visible. Consider applying this area sampling method in a complex building model: adjacent vertices in the path will almost always have a wall or two between them, giving no contribution for the path and high variance in the estimate.
][
  然而，以这种方式采样路径存在两个相互关联的问题。 第一个问题可能导致高方差，而第二个问题可能导致错误结果。 第一个问题是，如果路径中有成对的相邻顶点不相互可见，则许多路径将没有贡献。 考虑在复杂建筑模型中应用这种区域采样方法：路径中的相邻顶点几乎总是有一两堵墙在它们之间，从而对路径没有贡献，并且估计中方差很高。
]

#parec[
  The second problem is that if the integrand has delta functions in it (e.g., a point light source or a perfect specular BSDF), this sampling technique will never be able to choose path vertices such that the delta distributions are nonzero. Even if there are no delta distributions, as the BSDFs become increasingly glossy almost all the paths will have low contributions since the points in $f (p_(i + 1) arrow.r p_i arrow.r p_(i - 1))$ will cause the BSDF to have a small or zero value, and again we will suffer from high variance.
][
  第二个问题是，如果被积函数中有 δ 函数（例如，点光源或完美镜面 BSDF），这种采样技术将永远无法选择路径顶点使得 δ 分布非零。 即使没有 δ 分布，随着 BSDF 变得越来越光滑，几乎所有路径的贡献都很低，因为 $f (p_(i + 1) arrow.r p_i arrow.r p_(i - 1))$ 中的点将导致 BSDF 值很小或为零，我们将再次遭受高方差。
]

=== Incremental Path Construction
<incremental-path-construction>

#parec[
  A solution that solves both of these problems is to construct the path incrementally, starting from the vertex at the camera $p_0$. At each vertex, the BSDF is sampled to generate a new direction; the next vertex $p_(i + 1)$ is found by tracing a ray from $p_i$ in the sampled direction and finding the closest intersection. We are effectively trying to find a path with a large overall contribution by making a series of choices that find directions with important local contributions. While one can imagine situations where this approach could be ineffective, it is generally a good strategy.
][
  解决这两个问题的一个解决方案是从相机顶点 $p_0$ 开始逐步构建路径。 在每个顶点，采样 BSDF 以生成新方向；通过在采样方向上从 $p_i$ 追踪光线并找到最近的交点来找到下一个顶点 $p_(i + 1)$。 我们实际上是在通过一系列选择来寻找具有重要局部贡献的方向，从而找到具有大总体贡献的路径。 虽然可以想象这种方法可能无效的情况，但通常这是一种好的策略。
]

#parec[
  Because this approach constructs the path by sampling BSDFs according to solid angle, and because the path integral LTE is an integral over surface area in the scene, we need to apply the correction to convert from the probability density according to solid angle $p_omega$ to a density according to area $p_A$ (@working-with-radiometric-integrals). If $omega_(i - 1)$ is the normalized direction sampled at $p_(i - 1)$, it is:
][
  由于这种方法通过根据立体角采样 BSDF 来构建路径，并且因为路径积分 LTE 是场景中表面积的积分，我们需要应用修正以从根据立体角的概率密度 $p_omega$ 转换为根据面积的密度 $p_A$ （@working-with-radiometric-integrals）。 如果 $omega_(i - 1)$ 是在 $p_(i - 1)$ 处采样的归一化方向，则为：
]

$
  p_A (p_i) = p_omega ( omega_(i - 1) ) frac(lr(|cos theta_i|), parallel upright(p)_(i - 1) - upright(p)_i parallel^2) .
$


#parec[
  This correction causes all the factors of the corresponding geometric function $G (p_(i + 1) arrow.l.r p_i)$ to cancel out of $P (upright( p)_i)$ except for the $cos theta_(i + 1)$ term.
][
  这种修正导致对应几何函数 $G (p_(i + 1) arrow.l.r p_i)$ 的所有因子在 $P (upright(p)_i)$ 中相互抵消，除了 $cos theta_(i + 1)$ 项。
]

#parec[
  Furthermore, we already know that $p_(i - 1)$ and $p_i$ must be mutually visible since we traced a ray to find $p_i$, so the visibility term is trivially equal to 1. An alternative way to think about this is that ray tracing provides an operation to importance sample the visibility component of $G$.
][
  此外，我们已经知道 $p_(i - 1)$ 和 $p_i$ 必须相互可见，因为我们追踪了一条光线以找到 $p_i$，因此可见性项显然等于 1。 另一种思考方式是，光线追踪提供了一种操作来重要性采样 $G$ 的可见性组件。
]

#parec[
  With path tracing, the last vertex of the path, which is on the surface of a light source, gets special treatment. Rather than being sampled incrementally, it is sampled from a distribution that is just over the surfaces of the lights. (Sampling the last vertex in this way is often referred to as #emph[next
event estimation] (NEE), after a Monte Carlo technique with that name.) For now we will assume there is such a sampling distribution $p_e$ over the emitters, though in @a-better-path-tracer we will see that a more effective estimator can be constructed using multiple importance sampling.
][
  在路径追踪中，路径的最后一个顶点位于光源表面，得到特殊处理。 它不是逐步采样的，而是从仅在光源表面上的分布中采样。 （以这种方式采样最后一个顶点通常被称为 #emph[下一个事件估计];（NEE），以该名称的蒙特卡罗技术命名。） 目前我们假设在发射器上有这样一个采样分布 $p_e$，尽管在@a-better-path-tracer 中我们将看到可以使用多重重要性采样构建更有效的估计器。
]

#parec[
  With this approach, the value of the Monte Carlo estimate for a path is
][
  使用这种方法，路径的蒙特卡罗估计值为
]

$
  P(macron(upright(p))(i)) approx & frac(L_e (upright(p)_i arrow.r upright(p)_(i - 1)) f(upright(p)_i arrow.r upright(p)_(i - 1) arrow.r upright(p)_(i - 2)) G(upright(p)_i arrow.l.r upright(p)_(i - 1)), p_e (p_i)) \
  & times product_(j = 1)^(i - 2) frac(f(upright(p)_(j + 1) arrow.r upright(p)_j arrow.r upright(p)_(j - 1))|cos theta_j|, p_omega (omega_j)) .
$<path-incremental-sample-result-weights>

#parec[
  Because this sampling scheme reuses vertices of the path of length $i-1$ (except the vertex on the emitter) when constructing the path of length $i$, it does introduce correlation among the $P(upright(p)_i)$ terms. This does not affect the unbiasedness of the Monte Carlo estimator, however. In practice this correlation is more than made up for by the improved efficiency from tracing fewer rays than would be necessary to make the $P(upright(p)_i)$ terms independent.
][
  由于这种采样方案在构造长度为 $i$ 的路径时重用了长度为 $i-1$ 的路径的顶点（除了发射体上的顶点外），它确实在 $P(upright(p)_i)$ 项之间引入了相关性。然而，这并不影响蒙特卡罗估计器的无偏性。在实际应用中，这种相关性带来的影响远小于通过减少光线追踪数量所带来的效率提升，因为若要使 $P(upright(p)_i)$ 项独立，需要追踪更多的光线。
]

==== Relationship to the RandomWalkIntegrator

#parec[
  With this derivation of the foundations of path tracing complete, the implementation of the `RandomWalkIntegrator` from Chapter 1 can now be understood more formally: at each path vertex, uniform spherical sampling is used for the distribution $p_omega$ —and hence the division by $1 \/ (4pi)$, corresponding to the uniform spherical PDF. The factor in parentheses in @eqt:path-incremental-sample-result-weights is effectively computed via the product of `beta` values through recursive calls to `RandomWalkIntegrator::LiRandomWalk()`. Emissive surfaces contribute to the radiance estimate whenever a randomly sampled path hits a surface with a nonzero $L_e$ ; because directions are sampled with respect to solid angle, the $p_e(p_i)$ factor in @eqt:path-incremental-sample-result-weights is not over emissive geometry but is the uniform directional probability $p_omega$. Most of the remaining $G$ factor then cancels out due to the change of variables from integrating over area to integrating over solid angle.
][
  通过完成路径追踪基础的推导，现在可以更正式地理解第 1 章中 `RandomWalkIntegrator` 的实现：在每个路径顶点，分布 $p_omega$ 使用均匀球面采样，这对应于均匀球面概率密度函数 $1 \/ (4pi)$ 的除法。@eqt:path-incremental-sample-result-weights 中括号内的因子实际上通过对 `RandomWalkIntegrator::LiRandomWalk()` 的递归调用中 `beta` 值的乘积计算得出。当随机采样路径撞击到具有非零 $L_e$ 的表面时，发光表面会对辐射亮度估计产生贡献；由于采样方向是相对于立体角的，因此方@eqt:path-incremental-sample-result-weights 中的 $p_e(p_i)$ 因子不是针对发光几何体的，而是均匀方向概率 $p_omega$。其余的大部分 $G$ 因子由于从面积积分到立体角积分的变量变化而相互抵消。
]
