#import "../template.typ": parec, ez_caption

== A Better Path Tracer
<a-better-path-tracer>


#parec[
  The `PathIntegrator` is based on the same path tracing approach as the `SimplePathIntegrator` but incorporates a number of improvements. They include these:
][
  `PathIntegrator` 基于与 `SimplePathIntegrator` 相同的路径追踪方法，但进行了多项改进。包括以下几点：
]

#parec[
  - The direct lighting calculation is performed by sampling both the BSDF and the sampled light source and weighting both samples using multiple importance sampling. This approach can substantially reduce variance compared to sampling the light alone.
][
  - 直接光照计算通过对 BSDF 和采样的光源进行采样，并使用多重重要性采样对两个样本进行加权。这种方法与仅对光源进行采样相比，可以显著减少方差。
]

#parec[
  - Any `LightSampler` can be used, which makes it possible to use effective light sampling algorithms like the one implemented in `BVHLightSampler` to choose lights.
][
  - 可以使用任何 `LightSampler`，这使得可以使用有效的光采样算法，例如在 `BVHLightSampler` 中实现的算法来选择光源。
]

#parec[
  - It initializes the `VisibleSurface` when it is provided, giving geometric information about the first intersection point to `Film` implementations like `GBufferFilm`.
][
  - 当提供 `VisibleSurface` 时进行初始化，向 `Film` 实现如 `GBufferFilm` 提供第一个交点的几何信息。
]

#parec[
  - Russian roulette is used to terminate paths, which can significantly boost the integrator's efficiency.
][
  - 使用俄罗斯轮盘赌来终止路径，这可以显著提高积分器的效率。（俄罗斯轮盘赌是一种随机终止路径的技术）
]

#parec[
  - A technique known as #emph[path regularization] can be applied in order to reduce variance from difficult-to-sample paths.
][
  - 可以应用一种称为_路径正则化_的技术，以减少难以采样路径的方差。
]

#parec[
  While these additions make its implementation more complex, they also substantially improve efficiency; see @fig:simplepath-vs-path-integrators for a comparison of the two.
][
  尽管这些新增功能使实现更加复杂，但它们显著提高了效率；参见@fig:simplepath-vs-path-integrators 以比较两者。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f07.svg"),
  caption: [
    #ez_caption[
      Comparison of the SimplePathIntegrator and the PathIntegrator. (a) Rendered using the SimplePathIntegrator with 64 samples per pixel. (b) The PathIntegrator, also with 64 samples per pixel. Once again, improving the underlying sampling algorithms leads to a substantial reduction in error. Not only is MSE improved by a factor of $1.97$, but execution time is $4.44 times$ faster, giving an overall efficiency improvement of $8.75 times$. (Scene courtesy of Guillermo M. Leal Llaguno.)
    ][
      简单路径积分器（SimplePathIntegrator）与路径积分器（PathIntegrator）的对比。(a) 使用简单路径积分器渲染，采样率为每像素64次。(b) 使用路径积分器渲染，采样率同样为每像素64次。再次证明了优化底层采样算法能够显著减少误差。不仅均方误差（MSE）降低了 1.97倍 ，而且执行时间加快了 4.44倍 ，从而实现了8.75倍的整体效率提升。（场景由 Guillermo M. Leal Llaguno 提供。）
    ]
  ],
)<simplepath-vs-path-integrators>

#parec[
  The most important of these differences is how the direct lighting calculation is performed. In the `SimplePathIntegrator`, a light was chosen with uniform probability and then that light sampled a direction; the corresponding estimator was given by @eqt:simple-pt-pathcontrib. More generally, the path contribution estimator can be expressed in terms of an arbitrary directional probability distribution $p$, which gives
][
  这些差异中最重要的是直接光照计算的执行方式。在 `SimplePathIntegrator` 中，光源是以均匀概率选择的，然后该光源采样一个方向；相应的估计器由@eqt:simple-pt-pathcontrib 给出。更一般地，路径贡献估计器可以用任意方向概率分布 $p$ 表示，其公式为
]

$
  P ( overline(p)_i ) approx frac(L_e (p_i arrow.r p_(i - 1)) f (p_i arrow.r p_(i - 1) arrow.r p_(i - 2)) lr(|cos theta_i|) V (p_i arrow.l.r p_(i - 1)), p (omega_i)) beta .
$


#parec[
  It may seem that using only a sampling PDF that matches the $L_e$ factor to sample these directions, as done by the `SimplePathIntegrator`, would be a good strategy; after all, the radiance $L_e$ can then be expected to be nonzero for the sampled direction. If we instead drew samples using the BSDF's sampling distribution, we might choose directions that did not intersect a light source at all, finding no emitted radiance after incurring the expense of tracing a ray in the hope of intersecting a light.
][
  似乎仅使用与 $L_e$ 因子匹配的采样 PDF 来采样这些方向，如 `SimplePathIntegrator` 所做的那样，是一个不错的策略；毕竟，可以预期辐射度 $L_e$ 在采样方向上为非零。 如果我们改为使用 BSDF 的采样分布来绘制样本，我们可能会选择根本不与光源相交的方向，在希望与光相交时，追踪光线的开销可能会导致没有发射辐射的结果。
]

#parec[
  However, there are cases where sampling the BSDF can be the more effective strategy. For a very smooth surface, the BSDF is nonzero for a small set of directions. Sampling the light source will be unlikely to find directions that have a significant effect on scattering from the surface, especially if the light source is large and close by. Even worse, when such a light sample happens to lie in the BSDF lobe, an estimate with large magnitude will be the result due to the combination of a high contribution from the numerator and a small value for the PDF in the denominator. The estimator has high variance.
][
  然而，在某些情况下，采样 BSDF 可能是更有效的策略。对于非常光滑的表面，BSDF 在一小组方向上为非零。 采样光源不太可能找到对表面散射有显著影响的方向，尤其是当光源很大且靠近时。 更糟糕的是，当这样的光样本恰好位于 BSDF 叶片中时，由于分子贡献高和分母中 PDF 值小的组合，结果将是一个大幅度的估计器。估计器具有高方差。
]

#parec[
  @fig:sample-bsdf-light shows a variety of cases where each of these sampling methods is much better than the other. In this scene, four rectangular surfaces ranging from very smooth (top) to very rough (bottom) are illuminated by spherical light sources of decreasing size. @fig:sample-bsdf-light(a) and (b) show the BSDF and light sampling strategies on their own. As the example illustrates, sampling the BSDF is much more effective when it takes on large values on a narrow set of directions that is much smaller than the set of directions that would be obtained by sampling the light sources. This case is most visible in the top left reflection of a large light source in a low-roughness surface. On the other hand, sampling the light sources can be considerably more effective in the opposite case—when the light source is small and the BSDF lobe is less concentrated (this case is most visible in the bottom right reflection).
][
  @fig:sample-bsdf-light 显示了各种情况下这些采样方法中的每一种都比其他方法更好的情况。 在这个场景中，四个矩形表面从非常光滑（顶部）到非常粗糙（底部）被大小递减的球形光源照亮。 @fig:sample-bsdf-light(a) 和 (b) 分别显示了 BSDF 和光采样策略。 正如示例所示，当 BSDF 在比通过采样光源获得的方向集合小得多的狭窄方向集合上取大值时，采样 BSDF 更为有效。 这种情况在低粗糙度表面上大光源的左上方反射中最为明显。 另一方面，当光源很小且 BSDF 叶片不太集中的情况下（这种情况在右下反射中最为明显），采样光源可能会更加有效。
]
#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f08.svg"),
  caption: [
    #ez_caption[
      Four surfaces ranging from very smooth (top) to very rough (bottom) illuminated by spherical light sources of decreasing size and rendered with different sampling techniques (modeled after a scene by Eric Veach). (a) BSDF sampling, (b) light sampling, and (c) both techniques combined using MIS. Sampling the BSDF is generally more effective for highly specular materials and large light sources, as illumination is coming from many directions, but the BSDF’s value is large for only a few of them (top left reflection). The converse is true for small sources and rough materials (bottom right reflection), where sampling the light source is more effective.
    ][
      四种表面，从非常光滑（顶部）到非常粗糙（底部），由逐渐减小的球形光源照明，并使用不同的采样技术进行渲染（场景参考 Eric Veach 的作品）。(a) BSDF 采样，(b) 光源采样，(c) 使用 MIS 结合两种技术。对于高镜面反射材料和较大的光源来说，采样 BSDF 通常更为有效，因为光照来自多个方向，而 BSDF 的值仅在少数方向上较大（左上方的反射）。相反，对于小光源和粗糙材料（右下方的反射），光源采样则更加有效。
    ]
  ],
)<sample-bsdf-light>
#parec[
  Taking a single sample with each sampling technique and averaging the estimators would be of limited benefit. The resulting estimator would still have high variance in cases where one of the sampling strategies was ineffective and that strategy happened to sample a direction with nonzero contribution.
][
  仅使用每种采样技术的一个样本并平均估计器的好处有限。 在一种采样策略无效且该策略恰好采样到具有非零贡献的方向的情况下，结果估计器仍然具有高方差。
]

#parec[
  This situation is therefore a natural for the application of multiple importance sampling—we have multiple sampling techniques, each of which is sometimes effective and sometimes not. That approach is used in the `PathIntegrator` with one light sample $omega_l tilde.op p_l$ and one BSDF sample $omega_b tilde.op p_b$, giving the estimator
][
  因此，这种情况非常适合应用多重重要性采样——我们有多种采样技术，每种技术有时有效，有时无效。 在 `PathIntegrator` 中使用这种方法，使用一个光样本 $omega_l tilde.op p_l$ 和一个 BSDF 样本 $omega_b tilde.op p_b$，得到估计器。
]

$
  P(macron(p)_i) approx & w_l (omega_l) frac(L_e (p_l arrow.r p_(i - 1)) f(p_l arrow.r p_(i - 1) arrow.r p_(i - 2))|cos theta_l|V(p_l arrow.l.r p_(i - 1)), p_l (omega_l)) beta + \ & w_b (omega_b) frac(L_e (p_b arrow.r p_(i - 1)) f(p_b arrow.r p_(i - 1) arrow.r p_(i - 2))|cos theta_b|V(p_b arrow.l.r p_(i - 1)), p_b (omega_b)) beta,
$<mis-direct-lighting-estimator>

#parec[
  where the surface intersection points corresponding to the two sampled directions are respectively denoted $p_l$ and $p_b$ and each term includes a corresponding multiple importance sampling (MIS) weight $w_l$ or $w_b$ that can be computed, for example, using the balance heuristic from @eqt:balance-heuristic or the power heuristic from @eqt:mis-power-heuristic . @fig:sample-bsdf-light(c) shows the effectiveness of combining these two sampling techniques with multiple importance sampling.
][
  其中，两个采样方向对应的表面交点分别记为 $p_l$ 和 $p_b$，每一项都包含一个相应的多重重要性采样（MIS）权重 $w_l$ 或 $w_b$，可以使用例如平衡启发式（来自@eqt:balance-heuristic）或幂启发式（来自@eqt:mis-power-heuristic）进行计算。@fig:sample-bsdf-light(c) 显示了将这两种采样技术与多重重要性采样结合的效果。
]

#parec[
  With that context established, we can start the implementation of the `PathIntegrator`. It is another #link("../Introduction/pbrt_System_Overview.html#RayIntegrator")[`RayIntegrator`];.
][
  在建立了这个背景之后，我们可以开始实现 `PathIntegrator`。它是另一个 #link("../Introduction/pbrt_System_Overview.html#RayIntegrator")[`RayIntegrator`];。
]

```cpp
<<PathIntegrator Definition>>=
class PathIntegrator : public RayIntegrator {
  public:
    <<PathIntegrator Public Methods>>
  private:
    <<PathIntegrator Private Methods>>
    <<PathIntegrator Private Members>>
};
```

#parec[
  Three member variables affect the `PathIntegrator`'s operation: a maximum path depth; the `lightSampler` used to sample a light source; and `regularize`, which controls whether path regularization is used.
][
  三个成员变量影响 `PathIntegrator` 的操作：最大路径深度；用于采样光源的 `lightSampler`；以及控制是否使用路径正则化的 `regularize`。
]
```cpp
<<PathIntegrator Private Members>>=
int maxDepth;
LightSampler lightSampler;
bool regularize;
```

#parec[
  The form of the `Li()` method is similar to `SimplePathIntegrator::Li()`.
][
  函数`Li()`的形式类似于`SimplePathIntegrator::Li()`
]

```cpp
<<PathIntegrator Method Definitions>>=
SampledSpectrum PathIntegrator::Li(RayDifferential ray,
        SampledWavelengths &lambda, Sampler sampler,
        ScratchBuffer &scratchBuffer, VisibleSurface *visibleSurf) const {
    <<Declare local variables for PathIntegrator::Li()>>
    <<Sample path from camera and accumulate radiance estimate>>
}
```

#parec[
  The `L`, `beta`, and `depth` variables play the same role as the corresponding variables did in the #link("../Light_Transport_I_Surface_Reflection/A_Simple_Path_Tracer.html#SimplePathIntegrator")[`SimplePathIntegrator`];.
][
  `L`、`beta` 和 `depth` 变量与 #link("../Light_Transport_I_Surface_Reflection/A_Simple_Path_Tracer.html#SimplePathIntegrator")[`SimplePathIntegrator`] 中的相应变量的作用相同。
]

```cpp
<<Declare local variables for PathIntegrator::Li()>>=
SampledSpectrum L(0.f), beta(1.f);
int depth = 0;
```

#parec[
  Also similarly, each iteration of the `while` loop traces a ray to find its closest intersection and its BSDF. Note that a number of code fragments from the #link("../Light_Transport_I_Surface_Reflection/A_Simple_Path_Tracer.html#SimplePathIntegrator")[`SimplePathIntegrator`] are reused here and in what follows to define the body of the `while` loop. The loop continues until either the maximum path length is reached or the path is terminated via Russian roulette.
][
  同样地，`while` 循环的每次迭代都会追踪一条光线以找到其最近的交点及其 BSDF。注意，这里和接下来的 `while` 循环体定义中重用了 #link("../Light_Transport_I_Surface_Reflection/A_Simple_Path_Tracer.html#SimplePathIntegrator")[`SimplePathIntegrator`] 的一些代码片段。循环继续，直到达到最大路径长度或通过俄罗斯轮盘赌终止路径。
]
```cpp
<<Sample path from camera and accumulate radiance estimate>>=
while (true) {
    <<Trace ray and find closest path vertex and its BSDF>>
    <<End path if maximum depth reached>>
    <<Sample direct illumination from the light sources>>
    <<Sample BSDF to get new path direction>>
    <<Possibly terminate the path with Russian roulette>>
}
return L;
```

#parec[
  We will defer discussing the implementation of the first fragment used below, `<<Add emitted light at intersection point or from the environment>>`, until later in this section after more details of the implementation of the MIS direct lighting calculation have been introduced.
][
  我们将推迟讨论下面使用的第一个片段的实现，`<<Add emitted light at intersection point or from the environment>>`，直到本节稍后引入 MIS 直接照明计算的更多细节。
]

```cpp
<<Trace ray and find closest path vertex and its BSDF>>=
pstd::optional<ShapeIntersection> si = Intersect(ray);
<<Add emitted light at intersection point or from the environment>>
SurfaceInteraction &isect = si->intr;
<<Get BSDF and skip over medium boundaries>>
<<Initialize visibleSurf at first intersection>>
<<Possibly regularize the BSDF>>
```

#parec[
  If the `Film` being used takes a `VisibleSurface` , then a non-`nullptr` `VisibleSurface *` is passed to the `Li()` method. It is initialized at the first intersection.
][
  如果使用的 `Film` 采用 `VisibleSurface` ，那么一个非 `nullptr` 的 `VisibleSurface *` 会传递给 `Li()` 方法。它在第一次相交时被初始化。
]


```cpp
if (depth == 0 && visibleSurf) {
    constexpr int nRhoSamples = 16;
    const Float ucRho[nRhoSamples] = { 0.75741637, 0.37870818, 0.7083487, 0.18935409, 0.9149363, 0.35417435, 0.5990858, 0.09467703, 0.8578725, 0.45746812, 0.686759, 0.17708716, 0.9674518, 0.2995429, 0.5083201, 0.047338516 };
    const Point2f uRho[nRhoSamples] = { Point2f(0.855985, 0.570367), Point2f(0.381823, 0.851844), Point2f(0.285328, 0.764262), Point2f(0.733380, 0.114073), Point2f(0.542663, 0.344465), Point2f(0.127274, 0.414848), Point2f(0.964700, 0.947162), Point2f(0.594089, 0.643463), Point2f(0.095109, 0.170369), Point2f(0.825444, 0.263359), Point2f(0.429467, 0.454469), Point2f(0.244460, 0.816459), Point2f(0.756135, 0.731258), Point2f(0.516165, 0.152852), Point2f(0.180888, 0.214174), Point2f(0.898579, 0.503897) };
    SampledSpectrum albedo = bsdf.rho(isect.wo, ucRho, uRho);
    *visibleSurf = VisibleSurface(isect, albedo, lambda);
}
```

#parec[
  The only quantity that is not immediately available from the `SurfaceInteraction` is the albedo of the surface, which is computed here as the hemispherical-directional reflectance, @eqt:rho-hd. Recall that the `BSDF::rho()` method estimates this value using Monte Carlo integration. Here, a set of 16 precomputed Owen-scrambled Halton points in arrays `ucRho` and `uRho`, not included in the text, are used for the estimate.
][
  `SurfaceInteraction` 中唯一无法立即获得的量是表面的反照率（albedo），它在这里被计算为半球方向反射率，见@eqt:rho-hd。回想一下， `BSDF::rho()` 方法使用蒙特卡罗积分估计这个值。在这里，使用了数组 `ucRho` 和 `uRho` 中预先计算的 16 个 Owen-打乱的 Halton 点（文本中未包含）来进行估计。
]

#parec[
  The use of Monte Carlo with this many samples is somewhat unsatisfying. The computed albedo is most commonly used for image-space denoising algorithms after rendering; most of these start by dividing the final color at each pixel by the first visible surface's albedo in order to approximate the incident illumination alone. It is therefore important that the albedo value itself not have very much error.
][
  使用如此多样本的蒙特卡罗方法有些不令人满意。计算出的反照率通常用于渲染后的图像空间去噪算法；这些算法大多数从将每个像素的最终颜色除以第一个可见表面的反照率开始，以仅近似入射光照。因此，反照率值本身不应有太大的误差。
]

#parec[
  However, the albedo can be computed analytically for some BSDFs (e.g., the ideal Lambertian BRDF). In those cases, executing both the BSDF sampling and evaluation algorithms repeatedly is wasteful. An exercise at the end of the chapter discusses this matter further.
][
  然而，对于某些 BSDF（例如理想 Lambertian BRDF），反照率可以解析计算。在这些情况下，重复执行 BSDF 采样和评估算法是浪费的。本章末尾的练习进一步讨论了这个问题。
]
```cpp
constexpr int nRhoSamples = 16;
const Float ucRho[nRhoSamples] = { 0.75741637, 0.37870818, 0.7083487, 0.18935409, 0.9149363, 0.35417435, 0.5990858, 0.09467703, 0.8578725, 0.45746812, 0.686759, 0.17708716, 0.9674518, 0.2995429, 0.5083201, 0.047338516 };
const Point2f uRho[nRhoSamples] = { Point2f(0.855985, 0.570367), Point2f(0.381823, 0.851844), Point2f(0.285328, 0.764262), Point2f(0.733380, 0.114073), Point2f(0.542663, 0.344465), Point2f(0.127274, 0.414848), Point2f(0.964700, 0.947162), Point2f(0.594089, 0.643463), Point2f(0.095109, 0.170369), Point2f(0.825444, 0.263359), Point2f(0.429467, 0.454469), Point2f(0.244460, 0.816459), Point2f(0.756135, 0.731258), Point2f(0.516165, 0.152852), Point2f(0.180888, 0.214174), Point2f(0.898579, 0.503897) };
SampledSpectrum albedo = bsdf.rho(isect.wo, ucRho, uRho);
```

#parec[
  The next task is to sample a light source to find a direction $omega_i$ to use to estimate the first term of @eqt:mis-direct-lighting-estimator). However, if the BSDF is purely specular, there is no reason to do this work, since the value of the BSDF for a sampled point on a light will certainly be zero.
][
  下一个任务是对光源进行采样，以找到一个方向 $omega_i$ 用于估计@eqt:mis-direct-lighting-estimator) 的第一项。然而，如果 BSDF 完全是镜面反射，那么没有理由进行这项工作，因为在光源上采样点的 BSDF 值肯定为零。
]
```cpp
if (IsNonSpecular(bsdf.Flags())) {
    SampledSpectrum Ld = SampleLd(isect, &bsdf, lambda, sampler);
    L += beta * Ld;
}
```

#parec[
  Although `SampleLd()` is only called once and thus could be expanded inline in the `Li()` method, there are multiple points along the way where it may return early. We therefore prefer a function here, as it avoids deeply nested `if` statements that would be needed otherwise.
][
  虽然 `SampleLd()` 只被调用一次，因此可以在 `Li()` 方法中内联展开，但在此过程中有多个点可能会提前返回。因此，我们在这里更倾向于使用函数，因为这样可以避免需要深层嵌套的 `if` 语句。
]
```cpp
SampledSpectrum PathIntegrator::SampleLd(
        const SurfaceInteraction &intr, const BSDF *bsdf,
        SampledWavelengths &lambda, Sampler sampler) const {
    LightSampleContext ctx(intr);
    BxDFFlags flags = bsdf->Flags();
    if (IsReflective(flags) && !IsTransmissive(flags))
        ctx.pi = intr.OffsetRayOrigin(intr.wo);
    else if (IsTransmissive(flags) && !IsReflective(flags))
        ctx.pi = intr.OffsetRayOrigin(-intr.wo);
    Float u = sampler.Get1D();
    pstd::optional<SampledLight> sampledLight = lightSampler.Sample(ctx, u);
    Point2f uLight = sampler.Get2D();
    if (!sampledLight) return {};
    Light light = sampledLight->light;
    pstd::optional<LightLiSample> ls = light.SampleLi(ctx, uLight, lambda, true);
    if (!ls || !ls->L || ls->pdf == 0)
        return {};
    Vector3f wo = intr.wo, wi = ls->wi;
    SampledSpectrum f = bsdf->f(wo, wi) * AbsDot(wi, intr.shading.n);
    if (!f || !Unoccluded(intr, ls->pLight))
        return {};
    Float p_l = sampledLight->p * ls->pdf;
    if (IsDeltaLight(light.Type()))
        return ls->L * f / p_l;
    else {
        Float p_b = bsdf->PDF(wo, wi);
        Float w_l = PowerHeuristic(1, p_l, 1, p_b);
        return w_l * ls->L * f  / p_l;
    }
}
```

#parec[
  A `LightSampleContext` is necessary both for choosing a specific light source and for sampling a point on it. One is initialized using the constructor that takes a `SurfaceInteraction`.
][
  `LightSampleContext` 对于选择特定的光源和在其上采样一个点都是必要的。一个 `SurfaceInteraction` 构造函数用于初始化它。
]

```cpp
LightSampleContext ctx(intr);
BxDFFlags flags = bsdf->Flags();
if (IsReflective(flags) && !IsTransmissive(flags))
    ctx.pi = intr.OffsetRayOrigin(intr.wo);
else if (IsTransmissive(flags) && !IsReflective(flags))
    ctx.pi = intr.OffsetRayOrigin(-intr.wo);
```

#parec[
  If the surface is purely reflective or purely transmissive, then the reference point used for sampling `pi` is shifted slightly so that it lies on the side of the surface from which the outgoing ray will leave the intersection point toward the light. Doing so helps avoid a subtle error that is the result of the combination of floating-point round-off error in the computed intersection point and a ray that intersects an emitter that does not have a completely absorbing BSDF.
][
  如果表面是纯反射性或纯透射性的，那么用于采样 `pi` 的参考点会略微偏移，使其位于表面的一侧，从该侧出发的外向射线将从相交点指向光源。这样做有助于避免由于计算的相交点中的浮点舍入误差和射线相交一个不完全吸收的 BSDF 的发光器而导致的微妙错误。
]



#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f09.svg"),
  caption: [
    #ez_caption[
      The `LightSampleContext` stores the error bounds around the computed intersection point `pi`. Typically, the center of these bounds (filled circle) is used as the reference point for sampling a point on the light source. If a ray intersects the non-emissive side of a one-sided light, the light’s BSDF is nonzero, and if the center of the `pi` bounds is on the emissive side of the light, then it may seem that the intersection point is illuminated by the light. The result is an occasional bright pixel on the back side of light sources. Offsetting the reference point to the side of the surface from which the outgoing ray will leave (open circle) works around this problem.
    ][
      `LightSampleContext` 存储了计算的相交点 `pi` 周围的误差范围。通常，这些范围的中心（实心圆）被用作在光源上采样点的参考点。如果射线与单面光源的非发光侧相交，且光源的 BSDF 非零，并且 `pi` 范围的中心位于光源的发光侧，那么看起来相交点似乎被光源照亮。结果是在光源背面的像素偶尔会出现明亮的像素。将参考点偏移到射线将离开发射面的一侧（空心圆）可以解决这个问题。
    ]
  ],
)<shift-origin-for-light-intersections>

```cpp
BxDFFlags flags = bsdf->Flags();
if (IsReflective(flags) && !IsTransmissive(flags))
    ctx.pi = intr.OffsetRayOrigin(intr.wo);
else if (IsTransmissive(flags) && !IsReflective(flags))
    ctx.pi = intr.OffsetRayOrigin(-intr.wo);
```

#parec[
  Next, the `LightSampler` selects a light. One thing to note in the implementation here is that two more dimensions are consumed from the `Sampler` even if the `LightSampler` does not return a valid light. This is done in order to keep the allocation of `Sampler` dimensions consistent across all the pixel samples.
][
  接下来， `LightSampler` 选择一个光源。这里实现的一个值得注意的地方是，即使 `LightSampler` 不返回有效光源，也会从 `Sampler` 中消耗另外两个维度。这是为了保持所有像素样本中 `Sampler` 维度的分配一致。
]
```cpp
Float u = sampler.Get1D();
pstd::optional<SampledLight> sampledLight = lightSampler.Sample(ctx, u);
Point2f uLight = sampler.Get2D();
if (!sampledLight) return {};
```

#parec[
  Sampling a direction with the light proceeds using `Light::SampleLi()` , though here a `true` value is passed for its `allowIncompletePDF` parameter. Because we will use a second sampling technique, BSDF sampling, for the estimator in @eqt:mis-direct-lighting-estimator, and that technique has nonzero probability of sampling all directions $omega_i$ where the integrand is nonzero, the light sampling distribution may not include directions where the light's emission is relatively low.
][
  使用光源进行方向采样的过程是通过 `Light::SampleLi()` 完成的，尽管这里为其 `allowIncompletePDF` 参数传递了 `true` 值。因为我们将使用第二种采样技术，即 BSDF 采样，用于@eqt:mis-direct-lighting-estimator 中的估计器，并且该技术具有以非零概率采样所有积分项为非零的方向 $omega_i$，所以光采样分布可能不包括光发射较低的方向。
]

#parec[
  Given a light sample, it is worth checking for various cases that require no further processing here. As an example, consider a spotlight where the intersection point is outside of its emission cone; the `LightLiSample` will have a zero radiance value in that case. It is worthwhile to find that there is no incident radiance before incurring the cost of evaluating the BSDF.
][
  给定一个光样本，值得检查各种需要在此处无需进一步处理的情况。例如，考虑一个聚光灯，其相交点位于其发射锥体之外；在这种情况下， `LightLiSample` 将具有零辐射值。在评估 BSDF 的成本之前，发现没有入射辐射是值得的。
]


```cpp
Light light = sampledLight->light;
pstd::optional<LightLiSample> ls = light.SampleLi(ctx, uLight, lambda, true);
if (!ls || !ls->L || ls->pdf == 0)
    return {};
```

#parec[
  A shadow ray is only traced if the BSDF for the sampled direction is nonzero. It is not unusual for the BSDF to be zero here: for example, given a surface that is reflective but not transmissive, any sampled direction that is on the other side of the surface than the incident ray will have zero contribution.
][
  只有当采样方向的 BSDF 非零时，才会追踪阴影射线。在这里 BSDF 为零并不罕见：例如，给定一个反射但不透射的表面，任何位于表面另一侧的采样方向的贡献都将为零。
]
```cpp
Vector3f wo = intr.wo, wi = ls->wi;
SampledSpectrum f = bsdf->f(wo, wi) * AbsDot(wi, intr.shading.n);
if (!f || !Unoccluded(intr, ls->pLight))
    return {};
```

#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f10.svg"),
  caption: [
    #ez_caption[
      Comparison of the Balance and Power Heuristics for Direct Lighting. A zoomed-in region of @fig:sample-bsdf-light is shown here. (a) Rendered using the balance heuristic to weight BSDF and light samples in the direct lighting calculation. (b) Rendered using the power heuristic. The pixels behind the light source have a visible reduction in noise.
    ][
      直接光照的平衡和功率启发式比较。这里显示了@fig:sample-bsdf-light 的一个放大区域。(a) 使用平衡启发式对直接光照计算中的 BSDF 和光样本进行加权。(b) 使用功率启发式。光源后面的像素噪声明显减少。

    ]
  ],
)<path-balance-vs-power>


#parec[
  The light sample's contribution can now be computed; recall that the returned value corresponds to the first term of @eqt:mis-direct-lighting-estimator), save for the $beta$ factor. The case of a light that is described by a delta distribution receives special treatment here; recall from @light-interface that in that case there is an implied delta distribution in the emitted radiance value returned from `SampleLi()` as well as the PDF and that they cancel out when the estimator is evaluated. Further, BSDF sampling is unable to generate a light sample and therefore we must not try to apply multiple importance sampling but should evaluate the standard estimator, @eqt:simple-pt-pathcontrib, instead. If we do not have a delta distribution light source, then the value of the BSDF's PDF for sampling the direction $omega_i$ is found by calling `BSDF::PDF()` and the MIS weight is computed using the power heuristic.
][
  光样本的贡献现在可以计算；回想一下，返回的值对应于@eqt:mis-direct-lighting-estimator 的第一项，除了 $beta$ 因子。由 delta 分布描述的光源在这里得到特殊处理；回想@light-interface 中的内容，在这种情况下，从 `SampleLi()` 返回的发射辐射值以及 PDF 存在一个隐含的 delta 分布，当评估估计器时它们会相互抵消。此外，BSDF 采样无法生成光样本，因此我们不应尝试应用多重重要性采样，而应改为评估标准估计器，即@eqt:simple-pt-pathcontrib。如果光源不是 delta 分布光源，那么通过调用 `BSDF::PDF()` 可以找到方向 $omega_i$ 的 BSDF PDF，MIS 权重则使用功率启发式计算。
]
```cpp
Float p_l = sampledLight->p * ls->pdf;
if (IsDeltaLight(light.Type()))
    return ls->L * f / p_l;
else {
    Float p_b = bsdf->PDF(wo, wi);
    Float w_l = PowerHeuristic(1, p_l, 1, p_b);
    return w_l * ls->L * f  / p_l;
}
```

#parec[
  Returning now to the `Li()` method implementation, the next step is to sample the BSDF at the intersection to get an outgoing direction for the next ray to trace. That ray will be used to sample indirect illumination as well as for the BSDF sample for the direct lighting estimator.
][
  现在回到 `Li()` 方法的实现，下一步是对交点处的 BSDF 进行采样，以获取用于追踪下一条射线的外向方向。该射线将用于采样间接照明以及用于直接光照估计器的 BSDF 样本。
]
```cpp
Vector3f wo = -ray.d;
Float u = sampler.Get1D();
pstd::optional<BSDFSample> bs = bsdf.Sample_f(wo, u, sampler.Get2D());
if (!bs)
    break;
beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
p_b = bs->pdfIsProportional ? bsdf.PDF(wo, bs->wi) : bs->pdf;
specularBounce = bs->IsSpecular();
anyNonSpecularBounces |= !bs->IsSpecular();
if (bs->IsTransmission())
    etaScale *= Sqr(bs->eta);
prevIntrCtx = si->intr;
ray = isect.SpawnRay(ray, bsdf, bs->wi, bs->flags, bs->eta);
```
#parec[
  In addition to the path throughput weight `beta`, a number of additional values related to the path are maintained, as follows:
][
  除了路径通量权重 `beta` 之外，还维护了与路径相关的多个附加值，如下所示：
]

#parec[
  - `p_b` is the PDF for sampling the direction `bs->wi`; this value is needed for the MIS-based direct lighting estimate. One nit comes from BSDFs like the `LayeredBxDF` that return a `BSDFSample` where the `f` and `pdf` are only proportional to their true values. In that case, an explicit call to `BSDF::PDF()` is required to get an estimate of the true PDF.
][
  - `p_b` 是用于采样方向 `bs->wi` 的 PDF；这个值对于 MIS 基于直接光照的估计是必要的。一个细节来自于诸如 `LayeredBxDF` 这样的 BSDF，它们返回的 `BSDFSample` 中 `f` 和 `pdf` 仅与其真实值成比例。在这种情况下，需要显式调用 `BSDF::PDF()` 以获得真实 PDF 的估计值。
]

#parec[
  - As in the `SimplePathIntegrator` , `specularBounce` tracks whether the last scattering event was from a perfect specular surface.
][
  - 如同 `SimplePathIntegrator` 中一样，`specularBounce` 跟踪最后一次散射事件是否来自完美镜面反射表面。
]

#parec[
  - `anyNonSpecularBounces` tracks whether any scattering event along the ray's path has been non-perfect specular. This value is used for path regularization if it is enabled.
][
  - `anyNonSpecularBounces` 跟踪路径上的任何散射事件是否为非完美镜面反射。这一值用于启用路径正则化。
]

#parec[
  - `etaScale` is the accumulated product of scaling factors that have been applied to `beta` due to rays being transmitted between media of different indices of refraction—a detail that is discussed in @non-symmetric-scattering-and-refraction. This value will be used in the Russian roulette computation.
][
  - `etaScale` 是由于光线在不同折射率的介质之间传输而应用于 `beta` 的累积缩放因子——这个细节在@non-symmetric-scattering-and-refraction 中讨论。这个值将在俄罗斯轮盘赌计算中使用。
]

#parec[
  - Finally, `prevIntrCtx` stores geometric information about the intersection point from which the sampled ray is leaving. This value is also used in the MIS computation for direct lighting.
][
  - 最后，`prevIntrCtx` 存储了采样射线离开时的交点的几何信息。这个值也在直接光照的 MIS 计算中使用。
]


```cpp
beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
p_b = bs->pdfIsProportional ? bsdf.PDF(wo, bs->wi) : bs->pdf;
specularBounce = bs->IsSpecular();
anyNonSpecularBounces |= !bs->IsSpecular();
if (bs->IsTransmission())
    etaScale *= Sqr(bs->eta);
prevIntrCtx = si->intr;
```

```cpp
Float p_b, etaScale = 1;
bool specularBounce = false, anyNonSpecularBounces = false;
LightSampleContext prevIntrCtx;
```

#parec[
  The new ray will account for indirect illumination at the intersection point in the following execution of the `while` loop.
][
  新射线将在接下来的 `while` 循环执行中处理交点处的间接照明。
]

#parec[
  Returning now to the `<<Add emitted light at intersection point or from the environment>>` fragment at the start of the loop, we can see how the ray from the previous iteration of the `while` loop can take care of the BSDF sample in @eqt:mis-direct-lighting-estimator. The ray's direction was chosen by sampling the BSDF, and so if it happens to hit a light source, then we have everything we need to evaluate the second term of the estimate other than the MIS weight $w_b(omega)$. If the ray does not hit a light source, then that term is zero for the BSDF sample and there is no further work to do.
][
  现在回到循环开始处的 `<<Add emitted light at intersection point or from the environment>>` 片段，我们可以看到前一次 `while` 循环迭代中的射线如何处理@eqt:mis-direct-lighting-estimator 中的 BSDF 样本。射线的方向是通过采样 BSDF 选择的，因此如果它碰到一个光源，那么我们已经具备了评估估计第二项所需的一切，除了 MIS 权重 $w_b(omega)$。如果射线没有碰到光源，那么该项对于 BSDF 样本来说为零，不需要进一步的工作。
]

#parec[
  There are two cases to handle: infinite lights for rays that do not intersect any geometry, and surface emission for rays that do. In the first case, the ray path can terminate once lights have been considered.
][
  需要处理两种情况：对于不与任何几何体相交的射线的无限光源，以及与几何体相交的射线的表面发光。在第一种情况下，光线路径在考虑完光源后可以终止。
]
```cpp
if (!si) {
    for (const auto &light : infiniteLights) {
        SampledSpectrum Le = light.Le(ray, lambda);
        if (depth == 0 || specularBounce)
            L += beta * Le;
        else {
            Float p_l = lightSampler.PMF(prevIntrCtx, light) *
                        light.PDF_Li(prevIntrCtx, ray.d, true);
            Float w_b = PowerHeuristic(1, p_b, 1, p_l);
            L += beta * w_b * Le;
        }
    }
    break;
}
SampledSpectrum Le = si->intr.Le(-ray.d, lambda);
if (Le) {
    if (depth == 0 || specularBounce)
        L += beta * Le;
    else {
        Light areaLight(si->intr.areaLight);
        Float lightPDF = lightSampler.PMF(prevIntrCtx, areaLight) *
                         areaLight.PDF_Li(prevIntrCtx, ray.d, true);
        Float w_l = PowerHeuristic(1, bsdfPDF, 1, lightPDF);
        L += beta * w_l * Le;
    }
}
```


#parec[
  For the initial ray from the camera or after a perfect specular scattering event, emitted radiance should be included in the path without any MIS weighting, since light sampling was not performed at the previous vertex of the path. At this point in execution, `beta` already includes the BSDF, cosine factor, and PDF value from the previous scattering event, so multiplying `beta` by the emitted radiance gives the correct contribution.
][
  对于来自相机的初始射线或在完美镜面散射事件后的射线，发射辐射应当在路径中被包含而无需任何 MIS 加权，因为在路径的前一个顶点处未执行光采样。在此执行点，`beta` 已经包括了来自前一个散射事件的 BSDF、余弦因子和 PDF 值，因此将 `beta` 乘以发射辐射给出了正确的贡献。
]
```cpp
for (const auto &light : infiniteLights) {
    SampledSpectrum Le = light.Le(ray, lambda);
    if (depth == 0 || specularBounce)
        L += beta * Le;
    else {
        Float p_l = lightSampler.PMF(prevIntrCtx, light) *
                    light.PDF_Li(prevIntrCtx, ray.d, true);
        Float w_b = PowerHeuristic(1, p_b, 1, p_l);
        L += beta * w_b * Le;
    }
}
```


#parec[
  Otherwise, it is necessary to compute the MIS weight $w_b$. `p_b` gives us the BSDF's PDF from the previous scattering event, so all we need is the PDF for the ray's direction from sampling the light. This value is given by the product of the probability of sampling the light under consideration times the probability the light returns for sampling the direction.
][
  否则，就有必要计算 MIS 权重 $w_b$。`p_b` 给出了前一个散射事件的 BSDF 的 PDF，因此我们只需要通过采样光来获取射线方向的 PDF。这个值由所考虑光源的采样概率乘以光源为采样方向返回的概率组成。
]

#parec[
  Note that the `PDF_Li()` method is passed a `true` value for `allowIncompletePDF` here, again reflecting the fact that because BSDF sampling is capable of sampling all valid directions, it is not required that light sampling do so as well.
][
  注意，这里 `PDF_Li()` 方法被传递了一个 `true` 值给 `allowIncompletePDF`，再次反映了因为 BSDF 采样能够采样所有有效方向，所以光采样不需要也不要求也能包含这些方向。
]


```cpp
Float p_l = lightSampler.PMF(prevIntrCtx, light) *
    light.PDF_Li(prevIntrCtx, ray.d, true);
Float w_b = PowerHeuristic(1, p_b, 1, p_l);
```

#parec[
  The code for the case of a ray hitting an emissive surface is in the fragment `<<Incorporate emission from surface hit by ray>>`. It is almost the same as the infinite light case, so we will not include it here.
][
  射线碰到发光表面的情况的代码位于 `<<Incorporate emission from surface hit by ray>>` 片段中。它与无限光源情况几乎相同，因此这里不再赘述。
]

#parec[
  The final issue is Russian roulette–based path termination. As outlined in @path-tracing-overview, the task is easy: we compute a termination probability $q$ however we like, make a random choice as to whether to terminate the path, and update `beta` if the path is not terminated so that all subsequent $P(overline(upright(p))_i)$ terms will be scaled appropriately.
][
  俄罗斯轮盘赌路径终止的最终问题。正如@path-tracing-overview 所概述的，任务很简单：我们以某种方式计算一个终止概率 $q$，随机决定是否终止路径，并在路径未终止时更新 `beta`，使所有后续的 $P(overline(upright(p))_i)$ 项能够被适当地缩放。
]

#parec[
  However, the details of how $q$ is set can make a big difference. In general, it is a good idea for the termination probability to be based on the path throughput weight; in this way, if the BSDF's value is small, it is more likely that the path will be terminated. Further, if the path is not terminated, then the scaling factor will generally cause `beta` to have a value around 1. Thus, all rays that are traced tend to make the same contribution to the image, which improves efficiency.
][
  然而，如何设置 $q$ 的细节会产生很大差异。通常，终止概率最好基于路径通量权重；这样，如果 BSDF 的值较小，路径更有可能被终止。此外，如果路径未被终止，那么缩放因子通常会导致 `beta` 的值接近 1。因此，所有被追踪的射线倾向于对图像做出相同的贡献，这提高了效率。
]

#parec[
  Another issue is that it is best if the `beta` value used to compute $q$ does not include radiance scaling due to refraction. Consider a ray that passes through a glass object with a relative index of refraction of 1.5: when it enters the object, `beta` will pick up a factor of $1/1.5^2 approx 0.44$, but when it exits, that factor will cancel and `beta` will be back to 1. For ray paths that would exit, to have terminated them after the first refraction would be the wrong decision. Therefore, `etaScale` tracks those factors in `beta` so that they can be removed. The image in @fig:rr-with-eta-scale shows the increase in noise if this effect is not corrected for.
][
  另一个问题是，最好不要让用于计算 $q$ 的 `beta` 值包括由于折射导致的辐射缩放。考虑一条穿过相对折射率为 1.5 的玻璃物体的射线：当它进入物体时，`beta` 会增加一个因子 $1/1.5^2 approx 0.44$，但当它退出时，这个因子会被抵消，`beta` 将恢复到 1。对于那些会退出的光线路径来说，在第一次折射后终止它们将是错误的决定。因此，`etaScale` 跟踪 `beta` 中这些因子，以便可以将其移除。@fig:rr-with-eta-scale 显示了如果不纠正这个效应，噪声会如何增加。
]


#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f11.svg"),
  caption: [
    #ez_caption[
      The Effect of Including Radiance Scaling Due to Transmission in the Russian Roulette Probability $q$. (a) If `etaScale` is not included in the probability, then some rays that would have passed through the glass object are terminated unnecessarily, leading to noise in the corresponding parts of the image. (b) Including `etaScale` in the computation of $q$ fixes this issue. (Transparent Machines scene courtesy of Beeple.)
    ][
      包含由于透射导致的辐射缩放在俄罗斯轮盘赌概率 $q$ 中的影响。(a) 如果 `etaScale` 不包含在概率中，那么一些会通过玻璃物体的射线会被不必要地终止，导致图像相应部分的噪声增加。(b) 在计算 $q$ 时包含 `etaScale` 修复了这个问题。*透明机器* 场景由 Beeple 提供。
    ]
  ],
)<rr-with-eta-scale>

#parec[
  Finally, note that the termination probability is set according to the maximum component value of `rrBeta` rather than, for example, its average. Doing so gives better results when surface reflectances are highly saturated and some of the wavelength samples have much lower `beta` values than others, since it prevents any of the `beta` components from going above 1 due to Russian roulette.
][
  最后，注意终止概率是根据 `rrBeta` 的最大组件值设置的，而不是例如其平均值。这样做在表面反射率高度饱和且某些波长样本的 `beta` 值远低于其他波长样本时可以获得更好的结果，因为它可以防止由于俄罗斯轮盘赌而导致任何 `beta` 组件超过 1。
]
```cpp
SampledSpectrum rrBeta = beta * etaScale;
if (rrBeta.MaxComponentValue() < 1 && depth > 1) {
    Float q = std::max<Float>(0, 1 - rrBeta.MaxComponentValue());
    if (sampler.Get1D() < q)
        break;
    beta /= 1 - q;
}
```

#parec[
  Recall that Russian roulette only increases variance. Because it terminates some paths, this must be so, as the final image includes less information when it is applied. However, it can improve efficiency by allowing the renderer to focus its efforts on tracing rays that make the greatest contribution to the final image. @tbl:rr-mc-efficiency-en) presents measurements of efficiency improvements from Russian roulette for a number of scenes.
][
  回想一下，俄罗斯轮盘赌只会增加方差。因为它会终止一些路径，当应用它时，最终图像包含的信息会减少，这必须是如此。然而，它可以通过让渲染器专注于追踪对最终图像贡献最大的射线来提高效率。@tbl:rr-mc-efficiency-zh) 提供了使用俄罗斯轮盘赌在多个场景中提高效率的测量结果。
]

#parec[
  #figure(
    align(center)[#table(
        columns: (30%, 20%, 20%, 20%),
        align: (auto, auto, auto, auto),
        table.header([Scene], [MSE], [Time], [Efficiency]),
        table.hline(),
        [#emph[Kroken] (@fig:path-tracing-example)], [$1.31$], [$0.261$], [$2.92$],
        [#emph[Watercolor] (@fig:randomwalk-vs-simplepath-integrators)], [$1.19$], [$0.187$], [$4.51$],
        [#emph[San Miguel] (@fig:simplepath-vs-path-integrators)], [$1.00$], [$0.239$], [$4.17$],
        [BMW M6 (@fig:tricky-indirect-lighting)], [$1.00$], [$0.801$], [$1.25$],
      )],
    caption: [
      Monte Carlo Efficiency Benefits from Russian Roulette.
      Measurements of MSE and rendering time when using Russian roulette. All
      values reported are relative to rendering the same scene without Russian
      roulette. As expected, MSE increases to varying degrees due to ray
      termination, but the performance benefit more than makes up for it,
      leading to an increase in Monte Carlo efficiency.
    ],
    kind: table,
  )<rr-mc-efficiency-en>
][
  #figure(
    align(center)[#table(
        columns: (30%, 20%, 20%, 20%),
        align: (auto, auto, auto, auto),
        table.header([场景], [MSE], [时间], [效率]),
        table.hline(),
        [#emph[Kroken];（@fig:path-tracing-example）], [$1.31$], [$0.261$], [$2.92$],
        [#emph[Watercolor];（@fig:randomwalk-vs-simplepath-integrators）], [$1.19$], [$0.187$], [$4.51$],
        [#emph[San Miguel];（@fig:simplepath-vs-path-integrators）], [$1.00$], [$0.239$], [$4.17$],
        [BMW M6（@fig:tricky-indirect-lighting）], [$1.00$], [$0.801$], [$1.25$],
      )],
    caption: [
      俄罗斯轮盘赌对蒙特卡罗效率的好处。使用俄罗斯轮盘赌时的 MSE
      和渲染时间的测量。所有报告的值都是相对于不使用俄罗斯轮盘赌渲染相同场景的值。如预期的那样，MSE
      由于射线终止而在不同程度上增加，但性能提升完全弥补了这一点，从而提高了蒙特卡罗效率。
    ],
    kind: table,
  )<rr-mc-efficiency-zh>
]



=== Path Regularization
<path-regularization>
#parec[
  Scenes with concentrated indirect lighting can pose a challenge to the path-tracing algorithm: the problem is that if the incident indirect radiance at a point has substantial variation but BSDF sampling is being used to generate the direction of indirect rays, then the sampling distribution may be a poor match for the integrand. Variance spikes then occur when the ratio $f (x) \/ p (x)$ in the Monte Carlo estimator is large.
][
  具有集中特性间接照明的场景可能会对路径追踪算法构成挑战：问题在于，如果一个点的入射间接辐射有显著变化，但使用BSDF采样来生成间接光线的方向，那么采样分布可能与积分函数不匹配。当蒙特卡罗估计器中的比率 $f (x) \/ p (x)$ 很大时，就会出现方差波动。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f12.svg"),
  caption: [
    #ez_caption[
      Image with High Variance Due to Difficult-to-Sample
      Indirect Lighting. \
      The environment map illuminating the scene includes the sun, which is
      not only bright but also subtends a small solid angle. When an indirect
      lighting sample hits a specular surface and reflects to the sun’s
      direction, variance spikes in the image result because its contribution
      is not sampled well. #emph[(Car model courtesy of tyrant monkey, via Blend Swap.)]
    ][
      由于难以采样的间接照明导致高方差的图像。 \
      照亮场景的环境贴图中包括太阳，太阳不仅明亮而且占据很小的立体角。当间接照明样本击中镜面表面并反射到太阳方向时，图像中会出现方差波动，因为其贡献没有被很好地采样。
      #emph[(汽车模型由tyrant monkey提供，通过Blend Swap获得。)]
    ]
  ],
)<tricky-indirect-lighting>


#parec[
  @fig:tricky-indirect-lighting shows an example of this issue. The car is illuminated by a sky environment map where a bright sun occupies a small number of pixels. Consider sampling indirect lighting at a point on the ground near one of the wheels: the ground material is fairly diffuse, so any direction will be sampled with equal (cosine-weighted) probability. Rarely, a direction will be sampled that both hits the highly specular wheel and then also reflects to a direction where the sun is visible. This is the cause of the bright pixels on the ground. (The lighting in the car interior is similarly difficult to sample, since the glass prevents light source sampling; the variance spikes there follow.)
][
  @fig:tricky-indirect-lighting 展示了这个问题的一个例子。汽车被一个天空环境贴图照亮，其中一个明亮的太阳占据了少量像素。考虑在靠近车轮的地面上采样间接照明：地面材料相当漫反射，因此任何方向都会以相等的（余弦加权）概率被采样。偶尔会采样到一个方向，该方向既击中了高镜面的车轮，又反射到太阳可见的方向。这就是地面上亮点的原因。（车内的照明同样难以采样，因为玻璃阻止了光源采样；那里也会出现方差波动。）
]



#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f13.svg"),
  caption: [
    #ez_caption[
      Scene from Figure 13.12 with Roughened BSDFs. \
      (a) Increasing the roughness of all the BSDFs eliminates the variance
      spikes by allowing the use of MIS at all indirect ray intersection
      points, though this substantially changes the appearance of the scene.
      (Note that the car paint is duller and the window glass and headlight
      covers have the appearance of frosted glass.) \
      (b) Roughening BSDFs only after the first non-specular scattering event
      along the path preserves visual detail while reducing the error from
      difficult light paths. #emph[(Car model courtesy of tyrant monkey, via
Blend Swap.)]
    ][
      图13.12中的场景，使用粗糙化的BSDF。 \
      (a)
      增加所有BSDF的粗糙度，通过允许在所有间接光线交点使用多重重要性采样（MIS）消除了方差波动，尽管这大大改变了场景的外观。（注意车漆变得更暗淡，车窗玻璃和前灯罩看起来像磨砂玻璃。）
      \
      (b)
      仅在路径上的第一次非镜面散射事件后粗糙化BSDF，保留视觉细节同时减少难以处理的光路径带来的误差。
      #emph[(汽车模型由tyrant monkey提供，通过Blend Swap获得。)]
    ]
    Roughened BSDFs
  ],
)<roughened-bsdfs>


#parec[
  Informally, the idea behind path regularization is to blur the function being integrated in the case that it cannot be sampled effectively (or cannot be sampled in the first place). See @fig:roughened-bsdfs, which shows the same scene, but with all the BSDFs made more rough: perfect specular surfaces are glossy specular, and glossy specular surfaces are more diffuse. Although the overall characteristics of the image are quite different, the high variance on the ground has been eliminated: when an indirect lighting ray hits one of the wheels, it is now possible to use a lower variance MIS-based direct lighting calculation in place of following whichever direction is dictated by the law of specular reflection.
][
  非正式地说，路径正则化的想法是在无法有效采样（或根本无法采样）的情况下模糊化被积函数。参见@fig:roughened-bsdfs，显示了相同的场景，但所有BSDF都变得更粗糙：完美镜面表面变为光泽镜面，光泽镜面表面变得更漫反射。尽管图像的整体特性截然不同，但地面上的高方差已被消除：当间接照明光线击中车轮之一时，现在可以使用基于MIS的低方差直接照明计算来替代遵循镜面反射法则指示的方向。
]

#parec[
  Blurring all the BSDFs in this way is an undesirable solution, but there is no need to do so for the camera rays or for rays that have only undergone perfect specular scattering: in those cases, we would like to leave the scene as it was specified. We can consider non-specular scattering itself to be a sort of blurring of the incident light, such that blurring the scene that is encountered after it occurs is less likely to be objectionable—thus the motivation to track this case via the `anyNonSpecularBounces` variable.
][
  以这种方式模糊化所有BSDF是一个不理想的解决方案，但没有必要对相机光线或仅经历了完美镜面散射的光线这样做：在这些情况下，我们希望保持场景如其所指定的那样。我们可以将非镜面散射本身视为对入射光的一种模糊处理，因此在发生后遇到的场景进行模糊处理不太可能引起反感——因此有动机通过`anyNonSpecularBounces`变量跟踪这种情况。
]

```cpp
<<Possibly regularize the BSDF>>=
if (regularize && anyNonSpecularBounces)
    bsdf.Regularize();
```


#parec[
  The `BSDF` class provides a `Regularize()` method that forwards the request on to its `BxDF`.
][
  `BSDF`类提供了一个`Regularize()`方法，该方法将请求转发给其`BxDF`。
]

```cpp
<<BSDF Public Methods>>+=
void Regularize() { bxdf.Regularize(); }
```


#parec[
  The `BxDF` interface in turn requires the implementation of a `Regularize()` method. For `BxDF`s that are already fairly broad (e.g., the #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];), the corresponding method implementation is empty.
][
  `BxDF`接口则要求实现一个`Regularize()`方法。对于已经相当宽泛的`BxDF`（例如，#link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];），相应的方法实现为空。
]

```cpp
<<BxDF Interface>>+=
void Regularize();
```


#parec[
  However, both the #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`] and #link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[`ConductorBxDF`] can be nearly specular or perfect specular, depending on how smooth their microfacet distribution is. Therefore, their `Regularize()` method implementations do adjust their scattering properties, through a call to yet one more method named `Regularize()`, this one implemented by the #link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#TrowbridgeReitzDistribution")[`TrowbridgeReitzDistribution`];.
][
  然而，#link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`];和#link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[`ConductorBxDF`];可以是近乎镜面或完美镜面的，具体取决于其微面分布的光滑程度。因此，它们的`Regularize()`方法实现通过调用另一个名为`Regularize()`的方法来调整其散射特性，该方法由#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#TrowbridgeReitzDistribution")[`TrowbridgeReitzDistribution`];实现。
]

```cpp
<<DielectricBxDF Public Methods>>+=
void Regularize() { mfDistrib.Regularize(); }
```


#parec[
  Unless the surface is already fairly rough, the #link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#TrowbridgeReitzDistribution")[`TrowbridgeReitzDistribution`];'s `Regularize()` method doubles the $alpha$ parameters and then clamps them—to ensure both that perfect specular surfaces with a roughness of zero become non-perfect specular and that surfaces are not excessively roughened.
][
  除非表面已经相当粗糙，否则#link("../Reflection_Models/Roughness_Using_Microfacet_Theory.html#TrowbridgeReitzDistribution")[`TrowbridgeReitzDistribution`];的`Regularize()`方法会将 $alpha$ 参数加倍然后进行钳制——以确保完美镜面表面具有零粗糙度变为非完美镜面，并且表面不会过度粗糙。
]

```cpp
<<TrowbridgeReitzDistribution Public Methods>>+=
void Regularize() {
    if (alpha_x < 0.3f) alpha_x = Clamp(2 * alpha_x, 0.1f, 0.3f);
    if (alpha_y < 0.3f) alpha_y = Clamp(2 * alpha_y, 0.1f, 0.3f);
}
```


