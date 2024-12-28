#import "../template.typ": parec, ez_caption

== A Simple Path Tracer
<a-simple-path-tracer>


#parec[
  The path tracing estimator in @eqt:path-incremental-sample-result-weights makes it possible to apply the BSDF and light sampling techniques that were respectively defined in @reflection-models and @light-sources to rendering. As shown in @fig:randomwalk-vs-simplepath-integrators , more effective importance sampling approaches than the uniform sampling in the `RandomWalkIntegrator` significantly reduce error. Although the `SimplePathIntegrator` takes longer to render an image at equal sample counts, most of that increase is because paths often terminate early with the `RandomWalkIntegrator`; because it samples outgoing directions at intersections uniformly over the sphere, half of the sampled directions lead to path termination at non-transmissive surfaces. The overall improvement in Monte Carlo efficiency from the `SimplePathIntegrator` is $12.8 times$.
][
  @eqt:path-incremental-sample-result-weights 中的路径追踪估计器使得可以将 @reflection-models 和@light-sources 中分别定义的 BSDF 和光采样技术应用于渲染。 如@fig:randomwalk-vs-simplepath-integrators 所示，比 `RandomWalkIntegrator` 中的均匀采样更有效的重要性采样方法显著减少了误差。 尽管 `SimplePathIntegrator` 在相同的样本数量下渲染图像所需时间更长，但大部分增加是因为路径在 `RandomWalkIntegrator` 中经常提前终止；因为它在交点处均匀地在球面上采样出射方向，采样方向的一半导致在非透射表面上路径终止。 `SimplePathIntegrator` 提高的蒙特卡罗效率的总体提高是 12.8 倍。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f06.svg"),
  caption: [
    #ez_caption[
      Comparison of the `RandomWalkIntegrator` and the
      `SimplePathIntegrator`. (a) Scene rendered with 64 pixel samples using the `RandomWalkIntegrator`.
      (b) Rendered with 64 pixel samples and the `SimplePathIntegrator`. The `SimplePathIntegrator` gives an image that is visibly much
      improved, thanks to using more effective BSDF and light sampling
      techniques.
      Here, mean squared error (MSE) is reduced by a factor of 101.
      Even though rendering time was (7.8) times longer, the overall
      improvement in Monte Carlo efficiency was still (12.8) times.
      #emph[Scene courtesy of Angelo Ferretti.]
    ][
      `RandomWalkIntegrator` 和 `SimplePathIntegrator` 的比较。使用 `RandomWalkIntegrator` 渲染的场景，64 个像素样本。 使用 `SimplePathIntegrator` 渲染的场景，64 个像素样本。 `SimplePathIntegrator` 通过使用更有效的 BSDF
      和光采样技术，生成了明显改进的图像。
      这里，均方误差 (MSE) 减少了 101 倍。
      即使渲染时间增加了 (7.8) 倍，蒙特卡罗效率的总体提高仍然是 (12.8) 倍。#emph[场景由 Angelo Ferretti 提供。]
    ]
  ],
)<randomwalk-vs-simplepath-integrators>


#parec[
  The "simple" in the name of this integrator is meaningful: `PathIntegrator`, which will be introduced shortly, adds a number of additional sampling improvements and should be used in preference to `SimplePathIntegrator` if rendering efficiency is important. This integrator is still useful beyond pedagogy, however; it is also useful for debugging and for validating the implementation of sampling algorithms. For example, it can be configured to use BSDFs' sampling methods or to use uniform directional sampling; given a sufficient number of samples, both approaches should converge to the same result (assuming that the BSDF is not perfect specular). If they do not, the error is presumably in the BSDF sampling code. Light sampling techniques can be tested in a similar fashion.
][
  这个积分器名称中的“简单”是有意义的：即将介绍的 `PathIntegrator` 增加了许多额外的采样改进，如果渲染效率很重要，应该优先使用 `PathIntegrator` 而不是 `SimplePathIntegrator`。 然而，这个积分器在教学之外仍然有用；它也适用于调试和验证采样算法的实现。 例如，它可以配置为使用 BSDF 的采样方法或使用均匀方向采样；在给定足够数量的样本的情况下，两种方法都应收敛到相同的结果（假设 BSDF 不是完美镜面反射）。 如果不是，则错误可能在于 BSDF 采样代码。 光采样技术可以以类似的方式进行测试。
]

```cpp
class SimplePathIntegrator : public RayIntegrator {
  public:
    SimplePathIntegrator(int maxDepth, bool sampleLights, bool sampleBSDF,
                            Camera camera, Sampler sampler,
                            Primitive aggregate, std::vector<Light> lights);

       SampledSpectrum Li(RayDifferential ray, SampledWavelengths &lambda,
                          Sampler sampler, ScratchBuffer &scratchBuffer,
                          VisibleSurface *visibleSurface) const;

       static std::unique_ptr<SimplePathIntegrator> Create(
           const ParameterDictionary &parameters, Camera camera, Sampler sampler,
           Primitive aggregate, std::vector<Light> lights, const FileLoc *loc);

       std::string ToString() const;
  private:
    int maxDepth;
    bool sampleLights, sampleBSDF;
    UniformLightSampler lightSampler;
};
```

#parec[
  The constructor sets the following member variables from provided parameters, so it is not included here. Similar to the `RandomWalkIntegrator`, `maxDepth` caps the maximum path length. #footnote[“Depth” is something of a misnomer in that this
integrator constructs the path iteratively rather than recursively as the `RandomWalkIntegrator`  did.  Nevertheless, here and in the following integrators, we will continue to describe the path length in this way.]
][
  构造函数根据提供的参数设置以下成员变量，因此不在此列出。 与 `RandomWalkIntegrator` 类似，`maxDepth` 限制了最大路径长度。 #footnote[
“深度”（Depth）这个术语有些用词不当，因为这个积分器是以迭代的方式而非像  `RandomWalkIntegrator` 那样以递归方式构造路径。然而，在这里以及接下来的积分器中，我们仍然会以这种方式描述路径的长度。
  ]
]

#parec[
  The `sampleLights` member variable determines whether lights' `SampleLi()` methods should be used to sample direct illumination or whether illumination should only be found by rays randomly intersecting emissive surfaces, as was done in the `RandomWalkIntegrator`. In a similar fashion, `sampleBSDF` determines whether BSDFs' `Sample_f()` methods should be used to sample directions or whether uniform directional sampling should be used. Both are `true` by default. A `UniformLightSampler` is always used for sampling a light; this, too, is an instance where this integrator opts for simplicity and a lower likelihood of bugs in exchange for lower efficiency.
][
  `sampleLights` 成员变量决定是否应使用光的 `SampleLi()` 方法来采样直接照明，或者照明是否仅通过射线随机与发光表面相交来发现，如在 `RandomWalkIntegrator` 中所做的那样。 类似地，`sampleBSDF` 决定是否应使用 BSDF 的 `Sample_f()` 方法来采样方向，或者是否应使用均匀方向采样。 两者默认都为 `true`。 `UniformLightSampler` 始终用于采样光；这也是这个积分器选择简单性和较低错误可能性以换取较低效率的一个实例。
]

```cpp
int maxDepth;
bool sampleLights, sampleBSDF;
UniformLightSampler lightSampler;
```


#parec[
  As a `RayIntegrator`, this integrator provides a `Li()` method that returns an estimate of the radiance along the provided ray. It does not provide the capability of initializing a `VisibleSurface` at the first intersection point, so the corresponding parameter is ignored.
][
  作为一个 `RayIntegrator`，这个积分器提供了一个 `Li()` 方法，该方法返回沿提供的射线的辐射估计值。 它不提供在第一个交点处初始化 `VisibleSurface` 的能力，因此相应的参数被忽略。
]

```cpp
SampledSpectrum SimplePathIntegrator::Li(RayDifferential ray,
        SampledWavelengths &lambda, Sampler sampler,
        ScratchBuffer &scratchBuffer, VisibleSurface *) const {
    SampledSpectrum L(0.f), beta(1.f);
    bool specularBounce = true;
    int depth = 0;
    while (beta) {
        // Intersect ray with scene
        pstd::optional<ShapeIntersection> si = Intersect(ray);
        // Account for infinite lights if ray has no intersection
        if (!si) {
            if (!sampleLights || specularBounce)
                for (const auto &light : infiniteLights)
                    L += beta * light.Le(ray, lambda);
            break;
        }
        // Account for emissive surface if light was not sampled
        SurfaceInteraction &isect = si->intr;
        if (!sampleLights || specularBounce)
            L += beta * isect.Le(-ray.d, lambda);

        // End path if maximum depth reached
        if (depth++ == maxDepth)
            break;

        // Get BSDF and skip over medium boundaries
        BSDF bsdf = isect.GetBSDF(ray, lambda, camera, scratchBuffer, sampler);
        if (!bsdf) {
            isect.SkipIntersection(&ray, si->tHit);
            continue;
        }

        // Sample direct illumination if sampleLights is true
        Vector3f wo = -ray.d;
        if (sampleLights) {
            pstd::optional<SampledLight> sampledLight =
                lightSampler.Sample(sampler.Get1D());
            if (sampledLight) {
                // Sample point on sampledLight to estimate direct illumination
                Point2f uLight = sampler.Get2D();
                pstd::optional<LightLiSample> ls =
                    sampledLight->light.SampleLi(isect, uLight, lambda);
                if (ls && ls->L && ls->pdf > 0) {
                    // Evaluate BSDF for light and possibly add scattered radiance
                    Vector3f wi = ls->wi;
                    SampledSpectrum f = bsdf.f(wo, wi) * AbsDot(wi, isect.shading.n);
                    if (f && Unoccluded(isect, ls->pLight))
                        L += beta * f * ls->L / (sampledLight->p * ls->pdf);
                }
            }
        }

        // Sample outgoing direction at intersection to continue path
        if (sampleBSDF) {
            // Sample BSDF for new path direction
            Float u = sampler.Get1D();
            pstd::optional<BSDFSample> bs = bsdf.Sample_f(wo, u, sampler.Get2D());
            if (!bs)
                break;
            beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
            specularBounce = bs->IsSpecular();
            ray = isect.SpawnRay(bs->wi);
        } else {
            // Uniformly sample sphere or hemisphere to get new path direction
            Float pdf;
            Vector3f wi;
            BxDFFlags flags = bsdf.Flags();
            if (IsReflective(flags) && IsTransmissive(flags)) {
                wi = SampleUniformSphere(sampler.Get2D());
                pdf = UniformSpherePDF();
            } else {
                wi = SampleUniformHemisphere(sampler.Get2D());
                pdf = UniformHemispherePDF();
                if (IsReflective(flags) && Dot(wo, isect.n) * Dot(wi, isect.n) < 0)
                    wi = -wi;
                else if (IsTransmissive(flags) &&
                         Dot(wo, isect.n) * Dot(wi, isect.n) > 0)
                    wi = -wi;
            }
            beta *= bsdf.f(wo, wi) * AbsDot(wi, isect.shading.n) / pdf;
            specularBounce = false;
            ray = isect.SpawnRay(wi);
        }
    }
    return L;
}
```


#parec[
  A number of variables record the current state of the path. `L` is the current estimated scattered radiance from the running total of $sum(P(macron(upright(p))_i))$ and `ray` is updated after each surface intersection to be the next ray to be traced. `specularBounce` records if the last outgoing path direction sampled was due to specular reflection; the need to track this will be explained shortly.
][
  多个变量记录路径的当前状态。 `L` 是从 $sum(P(macron(upright(p))_i))$ 的运行总和中当前估计的散射辐射，`ray` 在每个表面交点后更新为要追踪的下一个射线。 `specularBounce` 记录最后一个采样的出射路径方向是否是由于镜面反射；需要跟踪这一点的原因将很快解释。
]

#parec[
  The `beta` variable holds the #emph[path throughput weight];, which is defined as the factors of the throughput function $T(macron(upright(p))_(i-1))$ —that is, the product of the BSDF values and cosine terms for the vertices generated so far, divided by their respective sampling PDFs:
][
  `beta` 变量保存路径通量权重，它被定义为通量函数 $T(macron(upright(p))_(i-1))$ 的因子，即到目前为止生成的顶点的 BSDF 值和余弦项的乘积，除以各自的采样 PDF：
]


$
  beta = product_(j = 1)^(i - 2) frac(f (p_(j + 1) arrow.r p_j arrow.r p_(j - 1)) lr(|cos theta_j|), p_(omega_omega) (omega_j)) .
$<beta-path-throughput-weight>
#parec[
  Thus, the product of `beta` with scattered light from direct lighting from the final vertex of the path gives the contribution for a path. (This quantity will reoccur many times in the following few chapters, and we will consistently refer to it as `beta`.) Because the effect of earlier path vertices is aggregated in this way, there is no need to store the positions and BSDFs of all the vertices of the path—only the last one.
][
  因此，路径最终顶点的散射光与 `beta` 相乘，得到路径的贡献。（这个量将在接下来的几章中多次出现，我们将始终称之为 `beta`。）由于路径早期顶点的影响以这种方式被聚合，因此只需存储路径最后一个顶点的位置和BSDF，而无需存储所有顶点。
]

```cpp
SampledSpectrum L(0.f), beta(1.f);
bool specularBounce = true;
int depth = 0;
while (beta) {
    <<Find next SimplePathIntegrator vertex and accumulate contribution>>
    <<Intersect ray with scene>>
    pstd::optional<ShapeIntersection> si = Intersect(ray);
    <<Account for infinite lights if ray has no intersection>>
    if (!si) {
        if (!sampleLights || specularBounce)
            for (const auto &light : infiniteLights)
                L += beta * light.Le(ray, lambda);
        break;
    }
    <<Account for emissive surface if light was not sampled>>
    SurfaceInteraction &isect = si->intr;
    if (!sampleLights || specularBounce)
        L += beta * isect.Le(-ray.d, lambda);
    <<End path if maximum depth reached>>
    if (depth++ == maxDepth)
        break;
    <<Get BSDF and skip over medium boundaries>>
    BSDF bsdf = isect.GetBSDF(ray, lambda, camera, scratchBuffer, sampler);
    if (!bsdf) {
        isect.SkipIntersection(&ray, si->tHit);
        continue;
    }
    <<Sample direct illumination if sampleLights is true>>
    Vector3f wo = -ray.d;
    if (sampleLights) {
        pstd::optional<SampledLight> sampledLight =
            lightSampler.Sample(sampler.Get1D());
        if (sampledLight) {
            <<Sample point on sampledLight to estimate direct illumination>>
            Point2f uLight = sampler.Get2D();
            pstd::optional<LightLiSample> ls =
                sampledLight->light.SampleLi(isect, uLight, lambda);
            if (ls && ls->L && ls->pdf > 0) {
                <<Evaluate BSDF for light and possibly add scattered radiance>>
                Vector3f wi = ls->wi;
                SampledSpectrum f = bsdf.f(wo, wi) * AbsDot(wi, isect.shading.n);
                if (f && Unoccluded(isect, ls->pLight))
                    L += beta * f * ls->L / (sampledLight->p * ls->pdf);
            }
        }
    }
    <<Sample outgoing direction at intersection to continue path>>
    if (sampleBSDF) {
        <<Sample BSDF for new path direction>>
        Float u = sampler.Get1D();
        pstd::optional<BSDFSample> bs = bsdf.Sample_f(wo, u, sampler.Get2D());
        if (!bs)
            break;
        beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
        specularBounce = bs->IsSpecular();
        ray = isect.SpawnRay(bs->wi);
    } else {
        <<Uniformly sample sphere or hemisphere to get new path direction>>
        Float pdf;
        Vector3f wi;
        BxDFFlags flags = bsdf.Flags();
        if (IsReflective(flags) && IsTransmissive(flags)) {
            wi = SampleUniformSphere(sampler.Get2D());
            pdf = UniformSpherePDF();
        } else {
            wi = SampleUniformHemisphere(sampler.Get2D());
            pdf = UniformHemispherePDF();
            if (IsReflective(flags) && Dot(wo, isect.n) * Dot(wi, isect.n) < 0)
                wi = -wi;
            else if (IsTransmissive(flags) &&
                     Dot(wo, isect.n) * Dot(wi, isect.n) > 0)
                wi = -wi;
        }
        beta *= bsdf.f(wo, wi) * AbsDot(wi, isect.shading.n) / pdf;
        specularBounce = false;
        ray = isect.SpawnRay(wi);
    }
}
return L;
```

#parec[
  Each iteration of the `while` loop accounts for an additional segment of a path, corresponding to a term of $P (macron(upright(p))_i)$ 's sum.
][
  `while` 循环的每次迭代都对应于路径的一个附加段，对应于 $P (macron(upright(p))_i)$ 的和中的一项。
]

```cpp
<<Find next SimplePathIntegrator vertex and accumulate contribution>>=
<<Intersect ray with scene>>
<<Account for infinite lights if ray has no intersection>>
<<Account for emissive surface if light was not sampled>>
<<End path if maximum depth reached>>
<<Get BSDF and skip over medium boundaries>>
<<Sample direct illumination if sampleLights is true>>
<<Sample outgoing direction at intersection to continue path>>
```

#parec[
  The first step is to find the intersection of the ray for the current segment with the scene geometry.
][
  第一步是找到当前段的射线与场景几何体的交点.
]

```cpp
<<Intersect ray with scene>>=
pstd::optional<ShapeIntersection> si = Intersect(ray);
```

#parec[
  If there is no intersection, then the ray path comes to an end. Before the accumulated path radiance estimate can be returned, however, in some cases radiance from infinite light sources is added to the path's radiance estimate, with contribution scaled by the accumulated `beta` factor.
][
  如果没有交点，则射线路径结束。然而，在返回累积路径辐射亮度估算之前，在某些情况下会将来自无限光源的辐射亮度添加到路径的辐射亮度估算中，贡献按累积的 `beta` 因子缩放。
]

#parec[
  If `sampleLights` is false, then emission is only found when rays happen to intersect emitters, in which case the contribution of infinite area lights must be added to rays that do not intersect any geometry. If it is true, then the integrator calls the #link("../Light_Sources/Light_Interface.html#Light")[`Light`] `SampleLi()` method to estimate direct illumination at each path vertex. In that case, infinite lights have already been accounted for, except in the case of a specular BSDF at the previous vertex. Then, `SampleLi()` is not useful since only the specular direction scatters light. Therefore, `specularBounce` records whether the last BSDF was perfect specular, in which case infinite area lights must be included here after all.
][
  如果 `sampleLights` 为假，则只有当射线碰巧与光源相交时才会发现发射，在这种情况下，必须将无限面积光的贡献添加到与任何几何体不相交的射线上。如果为真，则积分器调用 #link("../Light_Sources/Light_Interface.html#Light")[`Light`] 的 `SampleLi()` 方法以估算每个路径顶点的直接光照。在这种情况下，除了前一个顶点是镜面BSDF的情况外，无限光已经被考虑在内。然后，`SampleLi()` 没有用，因为只有镜面方向散射光。因此，`specularBounce` 记录上一个BSDF是否为完美镜面，在这种情况下，无限面积光必须在此处包括在内。
]

```cpp
<<Account for infinite lights if ray has no intersection>>=
if (!si) {
    if (!sampleLights || specularBounce)
        for (const auto &light : infiniteLights)
            L += beta * light.Le(ray, lambda);
    break;
}
```

#parec[
  If the ray hits an emissive surface, similar logic governs whether its emission is added to the path's radiance estimate.
][
  如果射线击中发光面，类似的逻辑决定其发射是否添加到路径的辐射亮度估算中。
]

```cpp
<<Account for emissive surface if light was not sampled>>=
SurfaceInteraction &isect = si->intr;
if (!sampleLights || specularBounce)
    L += beta * isect.Le(-ray.d, lambda);
```


#parec[
  The next step is to find the BSDF at the intersection point. A special case arises when an unset `BSDF` is returned by the `SurfaceInteraction`'s `GetBSDF()` method. In that case, the current surface should have no effect on light. `pbrt` uses such surfaces to represent transitions between participating media, whose boundaries are themselves optically inactive (i.e., they have the same index of refraction on both sides). Since the `SimplePathIntegrator` ignores media, it simply skips over such surfaces without counting them as scattering events in the `depth` counter.
][
  下一步是在交点找到BSDF。当 `SurfaceInteraction` 的 `GetBSDF()` 方法返回未设置的 `BSDF` 时，会出现特殊情况。在这种情况下，当前表面对光线没有影响。`pbrt` 使用这种表面表示参与介质之间的过渡，其边界本身在光学上是无效的（即，它们在两侧具有相同的折射率）。由于 `SimplePathIntegrator` 忽略介质，它简单地跳过这些表面，而不将它们计为 `depth` 计数器中的散射事件。
]

```cpp
<<Get BSDF and skip over medium boundaries>>=
BSDF bsdf = isect.GetBSDF(ray, lambda, camera, scratchBuffer, sampler);
if (!bsdf) {
    isect.SkipIntersection(&ray, si->tHit);
    continue;
}
```


#parec[
  Otherwise we have a valid surface intersection and can go ahead and increment `depth`. The path is then terminated if it has reached the maximum depth.
][
  否则，我们有一个有效的表面交点，可以继续增加 `depth`。如果路径达到最大深度，则终止路径。
]

```cpp
<<End path if maximum depth reached>>=
if (depth++ == maxDepth)
    break;
```

#parec[
  If explicit light sampling is being performed, then the first step is to use the #link("../Light_Sources/Light_Sampling.html#UniformLightSampler")[`UniformLightSampler`] to choose a single light source. (Recall from Section #link("../Light_Sources/Light_Sampling.html#sec:light-sampling")[12.6] that sampling only one of the scene's light sources can still give a valid estimate of the effect of all of them, given suitable weighting.)
][
  如果正在执行显式光采样，则第一步是使用 #link("../Light_Sources/Light_Sampling.html#UniformLightSampler")[`UniformLightSampler`] 选择单个光源。（请参见第 #link("../Light_Sources/Light_Sampling.html#sec:light-sampling")[12.6] 节，采样场景的一个光源仍然可以给出所有光源效果的有效估算，前提是权重合适。）
]

```cpp
<<Sample direct illumination if sampleLights is true>>=
Vector3f wo = -ray.d;
if (sampleLights) {
    pstd::optional<SampledLight> sampledLight =
        lightSampler.Sample(sampler.Get1D());
    if (sampledLight) {
        <<Sample point on sampledLight to estimate direct illumination>>
    }
}
```

#parec[
  Given a light source, a call to `SampleLi()` yields a sample on the light. If the light sample is valid, a direct lighting calculation is performed.
][
  给定一个光源，调用 `SampleLi()` 会产生光上的一个样本。如果光样本有效，则执行估算直接光照的计算。
]

```cpp
<<Sample point on sampledLight to estimate direct illumination>>=
Point2f uLight = sampler.Get2D();
pstd::optional<LightLiSample> ls =
    sampledLight->light.SampleLi(isect, uLight, lambda);
if (ls && ls->L && ls->pdf > 0) {
    <<Evaluate BSDF for light and possibly add scattered radiance>>
}
```


#parec[
  Returning to the path tracing estimator in @eqt:path-incremental-sample-result-weights , we have the path throughput weight in `beta`, which corresponds to the term in parentheses there. A call to `SampleLi()` yields a sample on the light. Because the light sampling methods return samples that are with respect to solid angle and not area, yet another Jacobian correction term is necessary, and the estimator becomes
][
  回到@eqt:path-incremental-sample-result-weights 中的路径追踪估算器，我们有路径通量权重 `beta`，对应于括号中的项。调用 `SampleLi()` 会产生光上的一个样本。由于光采样方法返回的是相对于立体角而不是面积的样本，因此需要另一个雅可比校正项，估算器变为
]


$
  P ( overline(p)_i ) = frac(L_e (p_i arrow.r p_(i - 1)) f (p_i arrow.r p_(i - 1) arrow.r p_(i - 2)) lr(|cos theta_i|) V (p_i arrow.l.r p_(i - 1)), p_l (omega_i) p (l)) beta ,
$<simple-pt-pathcontrib>


#parec[
  where $p_l$ is the solid angle density that the chosen light $l$ would use to sample the direction $omega_i$ and $p (l)$ is the discrete probability of sampling the light $l$ (recall @eqt:mc-sampled-sum). Their product gives the full probability of the light sample.
][
  其中 $p_l$ 是所选光源 $l$ 用于采样方向 $omega_i$ 的立体角密度， $p (l)$ 是采样光源 $l$ 的离散概率（回忆@eqt:mc-sampled-sum）。它们的乘积给出了光源样本的完整概率。
]

#parec[
  Before tracing the shadow ray to evaluate the visibility factor $V$, it is worth checking if the BSDF is zero for the sampled direction, in which case that computational expense is unnecessary.
][
  在追踪阴影光线以评估可见性因子 $V$ 之前，值得检查在采样方向上 BSDF（双向散射分布函数）是否为零，在这种情况下，这种计算开销是不必要的。
]

```cpp
Vector3f wi = ls->wi;
SampledSpectrum f = bsdf.f(wo, wi) * AbsDot(wi, isect.shading.n);
if (f && Unoccluded(isect, ls->pLight))
    L += beta * f * ls->L / (sampledLight->p * ls->pdf);
```

#parec[
  `Unoccluded()` is a convenience method provided in the Integrator base class.
][
  `Unoccluded()` 是 Integrator 基类中提供的一个便捷方法，表示“未被遮挡”。
]

```cpp
<<Integrator Public Methods>>+=
bool Unoccluded(const Interaction &p0, const Interaction &p1) const {
    return !IntersectP(p0.SpawnRayTo(p1), 1 - ShadowEpsilon);
}
```

#parec[
  To sample the next path vertex, the direction of the ray leaving the surface is found either by calling the BSDF's sampling method or by sampling uniformly, depending on the sampleBSDF parameter.
][
  为了采样下一个路径顶点，离开表面的光线方向可以通过调用 BSDF 的采样方法或通过均匀采样来确定，这取决于 sampleBSDF 参数（采样BSDF参数）。
]

```cpp
if (sampleBSDF) {
    // Sample BSDF for new path direction
    Float u = sampler.Get1D();
    pstd::optional<BSDFSample> bs = bsdf.Sample_f(wo, u, sampler.Get2D());
    if (!bs)
        break;
    beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
    specularBounce = bs->IsSpecular();
    ray = isect.SpawnRay(bs->wi);
} else {
    // Uniformly sample sphere or hemisphere to get new path direction
    Float pdf;
    Vector3f wi;
    BxDFFlags flags = bsdf.Flags();
    if (IsReflective(flags) && IsTransmissive(flags)) {
        wi = SampleUniformSphere(sampler.Get2D());
        pdf = UniformSpherePDF();
    } else {
        wi = SampleUniformHemisphere(sampler.Get2D());
        pdf = UniformHemispherePDF();
        if (IsReflective(flags) && Dot(wo, isect.n) * Dot(wi, isect.n) < 0)
            wi = -wi;
        else if (IsTransmissive(flags) && Dot(wo, isect.n) * Dot(wi, isect.n) > 0)
            wi = -wi;
    }
    beta *= bsdf.f(wo, wi) * AbsDot(wi, isect.shading.n) / pdf;
    specularBounce = false;
    ray = isect.SpawnRay(wi);
}
```



#parec[
  If BSDF sampling is being used to sample the new direction, the `Sample_f()` method gives a direction and the associated BSDF and PDF values. beta can then be updated according to @eqt:beta-path-throughput-weight .
][
  如果使用 BSDF 采样来采样新方向，`Sample_f()` 方法会给出一个方向以及相关的 BSDF 和 PDF 值。然后可以根据@eqt:beta-path-throughput-weight 更新 beta。
]

```cpp
Float u = sampler.Get1D();
pstd::optional<BSDFSample> bs = bsdf.Sample_f(wo, u, sampler.Get2D());
if (!bs)
    break;
beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
specularBounce = bs->IsSpecular();
ray = isect.SpawnRay(bs->wi);
```


#parec[
  Otherwise, the fragment `<<Uniformly sample sphere or hemisphere to get new path direction>>` uniformly samples a new direction for the ray leaving the surface. It goes through more care than the `RandomWalkIntegrator` did: for example, if the surface is reflective but not transmissive, it makes sure that the sampled direction is in the hemisphere where light is scattered. We will not include that fragment here, as it has to handle a number of such cases, but there is not much that is interesting about how it does so.
][
  否则，片段 `<<Uniformly sample sphere or hemisphere to get new path direction>>` 均匀采样一个新方向以使光线离开表面。它比 `RandomWalkIntegrator`（随机游走积分器）更加小心：例如，如果表面是反射但不透射的，它会确保采样方向在光散射的半球内。我们将在此不包括该片段，因为它必须处理许多此类情况，但其处理方式并没有太多有趣之处。
]
