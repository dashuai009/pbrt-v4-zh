#import "../template.typ": parec, ez_caption

== 14.2 Volume Scattering Integrators
<volume-scattering-integrators>
#parec[
  The path space expression of the null-scattering equation of transfer allows a variety of sampling techniques to be applied to the light transport problem. This section defines two integrators that are based on path tracing starting from the camera.
][
  无散射传输方程的路径空间表达允许将多种采样技术应用于光传输问题。本节定义了两个基于从相机开始的路径追踪的积分器。
]

#parec[
  First is the `SimpleVolPathIntegrator`, which uses simple sampling techniques, giving an implementation that is short and easily verified. This integrator is particularly useful for computing ground-truth results when debugging more sophisticated volumetric sampling and integration algorithms.
][
  首先是`SimpleVolPathIntegrator`，它使用简单的采样技术，提供了一个简短且易于验证的实现。当调试更复杂的体积采样和积分算法时，该积分器特别有用于计算真实结果。
]

#parec[
  The #link("<VolPathIntegrator>")[`VolPathIntegrator`] is defined next. This integrator is fairly complex, but it applies state-of-the-art sampling techniques to volume light transport while handling surface scattering similarly to the #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`];. It is `pbrt`'s default integrator and is also the template for the wavefront integrator in @wavefront-rendering-on-gpus.
][
  接下来定义#link("<VolPathIntegrator>")[`VolPathIntegrator`];。这个积分器相当复杂，但它在处理表面散射时应用了当前最先进的采样技术来进行体积光传输，与#link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`];类似。它是`pbrt`的默认积分器，也是@wavefront-rendering-on-gpus 中波前积分器的模板。
]

=== A Simple Volumetric Integrator
<a-simple-volumetric-integrator>
#parec[
  The `SimpleVolPathIntegrator` implements a basic volumetric path tracer, following the sampling approach described in @evaluating-the-equation-of-transfer. Its `Li()` method is under 100 lines of code, none of them too tricky. However, with this simplicity comes a number of limitations. First, like the #link("../Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`];, it does not perform any explicit light sampling, so it requires that rays are able to randomly intersect the lights in the scene. Second, it does not handle scattering from surfaces. An error message is therefore issued if it is used with a scene that contains delta distribution light sources or has surfaces with nonzero-valued BSDFs. (These defects are all addressed in the #link("<VolPathIntegrator>")[`VolPathIntegrator`] discussed in @improving-the-sampling-techniques.) Nevertheless, this integrator is capable of rendering complex volumetric effects; see Figure #link("<fig:explosion-simplevolpath>")[14.6];.
][
  `SimpleVolPathIntegrator`实现了一个基本的体积路径追踪器，遵循@evaluating-the-equation-of-transfer 中描述的采样方法。其`Li()`方法不到100行代码，没有太多复杂之处。然而，这种简单性带来了一些限制。 首先，像#link("../Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`];一样，它不执行任何显式光采样，因此需要射线能够随机与场景中的光源相交。其次，它不处理来自表面的散射。因此，如果它用于包含δ分布光源或具有非零BSDF的表面的场景，则会发出错误信息。 （这些缺陷在@improving-the-sampling-techniques 讨论的#link("<VolPathIntegrator>")[`VolPathIntegrator`];中得到解决。）尽管如此，该积分器能够渲染复杂的体积效果；参见图#link("<fig:explosion-simplevolpath>")[14.6];。
]


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f06.svg"),
  caption: [
    #ez_caption[
      Explosion Rendered Using the SimpleVolPathIntegrator. With 256 samples per pixel, this integrator gives a reasonably accurate rendering of the volumetric model, though there are variance spikes in some pixels (especially visible toward the bottom of the volume) due to error from the integrator not directly sampling the scene’s light sources. The VolPathIntegrator, which uses more sophisticated sampling strategies, renders this scene with 1,288 times lower MSE; it is discussed in @improving-the-sampling-techniques. (Scene courtesy of Jim Price.)
    ][
      使用 `SimpleVolPathIntegrator` 渲染的爆炸效果图。在每像素 256 个样本的设置下，该积分器能够对体积模型进行较为准确的渲染，但由于积分器未直接对场景光源进行采样，一些像素（特别是在体积下部区域）出现了方差尖峰。 `VolPathIntegrator` 使用了更复杂的采样策略，可以将该场景的均方误差（MSE）降低 1,288 倍；相关内容详见@improving-the-sampling-techniques。（场景由 Jim Price 提供。）
    ]
  ],
)<explosion-simplevolpath>

```cpp
class SimpleVolPathIntegrator : public RayIntegrator {
public:
    SimpleVolPathIntegrator(int maxDepth, Camera camera, Sampler sampler,
                            Primitive aggregate, std::vector<Light> lights);

    SampledSpectrum Li(RayDifferential ray, SampledWavelengths &lambda,
                       Sampler sampler, ScratchBuffer &scratchBuffer,
                       VisibleSurface *visibleSurface) const;

    static std::unique_ptr<SimpleVolPathIntegrator> Create(
        const ParameterDictionary &parameters, Camera camera, Sampler sampler,
        Primitive aggregate, std::vector<Light> lights, const FileLoc *loc);

    std::string ToString() const;
private:
    int maxDepth;
};
```
#parec[
  This integrator's only parameter is the maximum path length, which is set via a value passed to the constructor (not included here).
][
  该积分器的唯一参数是最大路径长度，通过传递给构造函数的值设置（此处未包括）。
]

```cpp
<<SimpleVolPathIntegrator Private Members>>=
int maxDepth;
```

#parec[
  The general form of the `Li()` method follows that of the `PathIntegrator`.
][
  The general form of the `Li()` method follows that of the `PathIntegrator`.
]

```cpp
SampledSpectrum SimpleVolPathIntegrator::Li(RayDifferential ray,
        SampledWavelengths &lambda, Sampler sampler, ScratchBuffer &buf,
        VisibleSurface *) const {
    SampledSpectrum L(0.f);
    Float beta = 1.f;
    int depth = 0;
    lambda.TerminateSecondary();
    while (true) {
        pstd::optional<ShapeIntersection> si = Intersect(ray);
        bool scattered = false, terminated = false;
        if (ray.medium) {
            uint64_t hash0 = Hash(sampler.Get1D());
            uint64_t hash1 = Hash(sampler.Get1D());
            RNG rng(hash0, hash1);
            Float tMax = si ? si->tHit : Infinity;
            Float u = sampler.Get1D();
            Float uMode = sampler.Get1D();
            SampleT_maj(ray, tMax, u, rng, lambda,
                [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
                    SampledSpectrum T_maj) {
                        Float pAbsorb = mp.sigma_a[0] / sigma_maj[0];
                        Float pScatter = mp.sigma_s[0] / sigma_maj[0];
                        Float pNull = std::max<Float>(0, 1 - pAbsorb - pScatter);
                        int mode = SampleDiscrete({pAbsorb, pScatter, pNull}, uMode);
                        if (mode == 0) {
                            L += beta * mp.Le;
                            terminated = true;
                            return false;
                        } else if (mode == 1) {
                            if (depth++ >= maxDepth) {
                                terminated = true;
                                return false;
                            }
                            Point2f u{rng.Uniform<Float>(), rng.Uniform<Float>()};
                            pstd::optional<PhaseFunctionSample> ps = mp.phase.Sample_p(-ray.d, u);
                            if (!ps) {
                                terminated = true;
                                return false;
                            }
                            beta *= ps->p / ps->pdf;
                            ray.o = p;
                            ray.d = ps->wi;
                            scattered = true;
                            return false;
                        } else {
                            uMode = rng.Uniform<Float>();
                            return true;
                        }
                });
        }
        if (terminated) return L;
        if (scattered) continue;
        if (si)
            L += beta * si->intr.Le(-ray.d, lambda);
        else {
            for (const auto &light : infiniteLights)
                L += beta * light.Le(ray, lambda);
            return L;
        }
        BSDF bsdf = si->intr.GetBSDF(ray, lambda, camera, buf, sampler);
        if (!bsdf)
            si->intr.SkipIntersection(&ray, si->tHit);
        else {
            Float uc = sampler.Get1D();
            Point2f u = sampler.Get2D();
            if (bsdf.Sample_f(-ray.d, uc, u))
                ErrorExit("SimpleVolPathIntegrator doesn't support surface scattering.");
            else
                break;
        }
    }
    return L;
}
```


#parec[
  A few familiar variables track the path state, including `L` to accumulate the radiance estimate for the path. For this integrator, `beta`, which tracks the path throughput weight, is just a single `Float` value, since the product of ratios of phase function values and sampling PDFs from @eqt:delta-tracking-path-estimator is a scalar value.
][
  一些熟悉的变量跟踪路径状态，包括用于累积路径辐射估计的`L`。对于这个积分器，跟踪路径传输权重的`beta`只是一个单一的`Float`值，因为相位函数值和采样PDF比率的乘积（@eqt:delta-tracking-path-estimator）是一个标量值。
]

```cpp
SampledSpectrum L(0.f);
Float beta = 1.f;
int depth = 0;
```

#parec[
  Media with scattering properties that vary according to wavelength introduce a number of complexities in sampling and evaluating Monte Carlo estimators. We will defer addressing them until we cover the `VolPathIntegrator`. The `SimpleVolPathIntegrator` instead estimates radiance at a single wavelength by terminating all but the first wavelength sample.
][
  具有根据波长变化的散射特性的介质在采样和评估蒙特卡罗估计器时引入了一些复杂性。我们将推迟到`VolPathIntegrator`中解决这些问题。`SimpleVolPathIntegrator`则通过终止除第一个波长样本外的所有波长来估计单个波长的辐射。
]

#parec[
  Here is a case where we have chosen simplicity over efficiency for this integrator's implementation: we might instead have accounted for all wavelengths until the point that spectrally varying scattering properties were encountered, enjoying the variance reduction benefits of estimating all of them for scenes where doing so is possible. However, doing this would have led to a more complex integrator implementation.
][
  这里是我们为该积分器的实现选择简单而非效率的一个例子：我们可能会考虑所有波长，直到遇到光谱变化的散射特性，在可能的场景中享受估计所有波长的方差减少的好处。然而，这样做会导致更复杂的积分器实现。
]

```cpp
lambda.TerminateSecondary();
```
#parec[
  The first step in the loop is to find the ray's intersection with the scene geometry, if any. This gives the parametric distance $t$ beyond which no samples should be taken for the current ray, as the intersection either represents a transition to a different medium or a surface that occludes farther-away points.
][
  循环的第一步是找到射线与场景几何体的交点（如果有）。这给出了当前射线不应取样的参数距离 $t$，因为交点要么表示不同介质的过渡，要么表示遮挡更远点的表面。
]

#parec[
  The `scattered` and `terminated` variables declared here will allow the lambda function that is passed to `SampleT_maj()` to report back the state of the path after sampling terminates.
][
  此处声明的`scattered`和`terminated`变量将允许传递给`SampleT_maj()`的lambda函数报告采样终止后的路径状态。
]

```cpp
pstd::optional<ShapeIntersection> si = Intersect(ray);
bool scattered = false, terminated = false;
if (ray.medium) {
    uint64_t hash0 = Hash(sampler.Get1D());
    uint64_t hash1 = Hash(sampler.Get1D());
    RNG rng(hash0, hash1);
    Float tMax = si ? si->tHit : Infinity;
    Float u = sampler.Get1D();
    Float uMode = sampler.Get1D();
    SampleT_maj(ray, tMax, u, rng, lambda,
        [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
            SampledSpectrum T_maj) {
            Float pAbsorb = mp.sigma_a[0] / sigma_maj[0];
            Float pScatter = mp.sigma_s[0] / sigma_maj[0];
            Float pNull = std::max<Float>(0, 1 - pAbsorb - pScatter);
            int mode = SampleDiscrete({pAbsorb, pScatter, pNull}, uMode);
            if (mode == 0) {
                L += beta * mp.Le;
                terminated = true;
                return false;
            } else if (mode == 1) {
                if (depth++ >= maxDepth) {
                    terminated = true;
                    return false;
                }
                Point2f u{rng.Uniform<Float>(), rng.Uniform<Float>()};
                pstd::optional<PhaseFunctionSample> ps = mp.phase.Sample_p(-ray.d, u);
                if (!ps) {
                    terminated = true;
                    return false;
                }
                beta *= ps->p / ps->pdf;
                ray.o = p;
                ray.d = ps->wi;
                scattered = true;
                return false;
            } else {
                uMode = rng.Uniform<Float>();
                return true;
            }
        });
}
```

#parec[
  An `RNG` is required for the call to the `SampleT_maj()` function. We derive seeds for it based on two random values from the sampler, hashing them to convert `Float`s into integers.
][
  调用`SampleT_maj()`函数需要一个`RNG`。我们基于采样器的两个随机值派生种子，将它们散列以将`Float`转换为整数。
]

```cpp
uint64_t hash0 = Hash(sampler.Get1D());
uint64_t hash1 = Hash(sampler.Get1D());
RNG rng(hash0, hash1);
```
#parec[
  With that, a call to `SampleT_maj()` starts the generation of samples according to $sigma_(m a j) T_(m a j)$. The `Sampler` is used to generate the first uniform sample `u` that is passed to the method; recall from @sampling-the-majorant-transmittance that subsequent ones will be generated using the provided `RNG`. In a similar fashion, the `Sampler` is used for the initial value of `uMode` here. It will be used to choose among the three types of scattering event at the first sampled point. For `uMode` as well, the `RNG` will provide subsequent values.
][
  这样，调用`SampleT_maj()`开始根据 $sigma_(m a j) T_(m a j)$ 生成样本。`Sampler`用于生成传递给方法的第一个均匀样本`u`；回忆@sampling-the-majorant-transmittance，后续样本将使用提供的`RNG`生成。同样，`Sampler`用于此处`uMode`的初始值。它将用于在第一个采样点选择三种散射事件中的一种。对于`uMode`，`RNG`也将提供后续值。
]

#parec[
  In this case, the transmittance that `SampleT_maj()` returns for the final segment is unneeded, so it is ignored.
][
  在这种情况下，`SampleT_maj()`返回的最终段的透射率是不需要的，因此被忽略。
]

```cpp
Float tMax = si ? si->tHit : Infinity;
Float u = sampler.Get1D();
Float uMode = sampler.Get1D();
SampleT_maj(ray, tMax, u, rng, lambda,
    [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
        SampledSpectrum T_maj) {
        Float pAbsorb = mp.sigma_a[0] / sigma_maj[0];
        Float pScatter = mp.sigma_s[0] / sigma_maj[0];
        Float pNull = std::max<Float>(0, 1 - pAbsorb - pScatter);
        int mode = SampleDiscrete({pAbsorb, pScatter, pNull}, uMode);
        if (mode == 0) {
            L += beta * mp.Le;
            terminated = true;
            return false;
        } else if (mode == 1) {
            if (depth++ >= maxDepth) {
                terminated = true;
                return false;
            }
            Point2f u{rng.Uniform<Float>(), rng.Uniform<Float>()};
            pstd::optional<PhaseFunctionSample> ps = mp.phase.Sample_p(-ray.d, u);
            if (!ps) {
                terminated = true;
                return false;
            }
            beta *= ps->p / ps->pdf;
            ray.o = p;
            ray.d = ps->wi;
            scattered = true;
            return false;
        } else {
            uMode = rng.Uniform<Float>();
            return true;
        }
    });
```


#parec[
  For each sample returned by `SampleT_maj()`, it is necessary to select which type of scattering it represents. The first step is to compute the probability of each possibility. Because we have specified $sigma_n$ such that it is nonnegative and $sigma_a + sigma_s + sigma_n = sigma_(m a j)$, the null-scattering probability can be found as one minus the other two probabilities. A call to `std::max()` ensures that any slightly negative values due to floating-point round-off error are clamped at zero.
][
  对于`SampleT_maj()`返回的每个样本，有必要选择它代表的散射类型。第一步是计算每种可能性的概率。因为我们指定了 $sigma_n$ 使其非负且 $sigma_a + sigma_s + sigma_n = sigma_(m a j)$，所以可以通过一减去其他两个概率来找到零散射概率。调用`std::max()`确保由于浮点舍入误差导致的任何稍微负值被夹在零。
]

```cpp
Float pAbsorb = mp.sigma_a[0] / sigma_maj[0];
Float pScatter = mp.sigma_s[0] / sigma_maj[0];
Float pNull = std::max<Float>(0, 1 - pAbsorb - pScatter);
```
#parec[
  A call to `SampleDiscrete()` then selects one of the three terms of $L_n$ using the specified probabilities.
][
  调用`SampleDiscrete()`然后使用指定的概率选择 $L_n$ 的三个项之一。
]

```cpp
int mode = SampleDiscrete({pAbsorb, pScatter, pNull}, uMode);
if (mode == 0) {
    L += beta * mp.Le;
    terminated = true;
    return false;
} else if (mode == 1) {
    if (depth++ >= maxDepth) {
        terminated = true;
        return false;
    }
    Point2f u{rng.Uniform<Float>(), rng.Uniform<Float>()};
    pstd::optional<PhaseFunctionSample> ps = mp.phase.Sample_p(-ray.d, u);
    if (!ps) {
        terminated = true;
        return false;
    }
    beta *= ps->p / ps->pdf;
    ray.o = p;
    ray.d = ps->wi;
    scattered = true;
    return false;
} else {
    uMode = rng.Uniform<Float>();
    return true;
}
```


#parec[
  If absorption is chosen, the path terminates. Any emission is added to the radiance estimate, and evaluation of Equation (14.19) is complete. The fragment therefore sets `terminated` to indicate that the path is finished and returns `false` from the lambda function so that no further samples are generated along the ray.
][
  如果选择了吸收，路径终止。任何发射都被添加到辐射估计中，并且方程(14.19)的评估完成。因此，该片段设置`terminated`以指示路径已完成，并从lambda函数返回`false`，以便沿射线不再生成样本。
]

```cpp
L += beta * mp.Le;
terminated = true;
return false;
```

#parec[
  For a scattering event, `beta` is updated according to the ratio of phase function and its directional sampling probability from @eqt:delta-tracking-path-estimator.
][
  对于散射事件，根据@eqt:delta-tracking-path-estimator 中的相位函数和其方向采样概率的比率更新`beta`。
]

```cpp
if (depth++ >= maxDepth) {
    terminated = true;
    return false;
}
Point2f u{rng.Uniform<Float>(), rng.Uniform<Float>()};
pstd::optional<PhaseFunctionSample> ps = mp.phase.Sample_p(-ray.d, u);
if (!ps) {
    terminated = true;
    return false;
}
beta *= ps->p / ps->pdf;
ray.o = p;
ray.d = ps->wi;
scattered = true;
return false;
```

#parec[
  The counter for the number of scattering events is only incremented for real-scattering events; we do not want the number of null-scattering events to affect path termination. If this scattering event causes the limit to be reached, the path is terminated.
][
  散射事件的计数器仅在真实散射事件时增加；我们不希望零散射事件的数量影响路径终止。如果此散射事件导致达到限制，则路径终止。
]

```cpp
<<Stop path sampling if maximum depth has been reached>>=
if (depth++ >= maxDepth) {
    terminated = true;
    return false;
}
```

#parec[
  If the path is not terminated, then a new direction is sampled from the phase function's distribution.
][
  如果路径未终止，则从相位函数的分布中采样一个新方向。
]



```cpp
<<Sample phase function for medium scattering event>>=
Point2f u{rng.Uniform<Float>(), rng.Uniform<Float>()};
pstd::optional<PhaseFunctionSample> ps = mp.phase.Sample_p(-ray.d, u);
if (!ps) {
    terminated = true;
    return false;
}
```

#parec[
  Given a sampled direction, the `beta` factor must be updated. Volumetric path-tracing implementations often assume that the phase function sampling distribution matches the phase function's actual distribution and dispense with `beta` entirely since it is always equal to 1. This variation is worth pausing to consider: in that case, emitted radiance at the end of the path is always returned, unscaled. All of the effect of transmittance, phase functions, and so forth is entirely encapsulated in the distribution of how often various terms are evaluated and in the distribution of scattered ray directions. `pbrt` does not impose the requirement on phase functions that their importance sampling technique be perfect, though this is the case for the Henyey–Greenstein phase function in `pbrt`.
][
  给定一个采样方向，需要更新 `beta` 因子。体积路径追踪的实现通常假设相函数的采样分布与相函数的实际分布一致，因此完全忽略 `beta`，因为它始终等于 1。这种变化值得仔细考虑：在这种情况下，路径末端的发射辐射总是以未缩放的形式返回。透射率、相函数等所有效果都完全被封装在各种项的评估频率分布和散射光线方向分布中。`pbrt` 并不要求相函数的重点采样技术必须是完美的，尽管在 `pbrt` 中，Heney–Greenstein 相函数的采样技术确实满足这一条件。
]

#parec[
  Be it with `beta` or without, there is no need to do any further work along the current ray after a scattering event, so after the following code updates the path state to account for scattering, it too returns `false` to direct that no further samples should be taken along the ray.
][
  无论是否使用 `beta`，在发生散射事件后，无需再沿当前光线进行进一步的计算。因此，在以下代码更新路径状态以考虑散射之后，也返回 `false`，以指示无需对当前光线进行进一步采样。
]
```cpp
beta *= ps->p / ps->pdf;
ray.o = p;
ray.d = ps->wi;
scattered = true;
return false;
```


#parec[
  Null-scattering events are ignored, so there is nothing to do but to return `true` to indicate that additional samples along the current ray should be taken. Similar to the real-scattering case, this can be interpreted as starting a recursive evaluation of @eqt:eot-null from the current sampled position without incurring the overhead of actually doing so. Since this is the only case that may lead to another invocation of the lambda function, `uMode` must be refreshed with a new uniform sample value in case another sample is generated.
][
  空散射事件被忽略，因此只需返回 `true`，表示应继续对当前光线进行额外的采样。与真实散射情况类似，这可以解释为从当前采样位置开始递归评估@eqt:eot-null，而无需实际执行这样的操作开销。由于这是可能导致 lambda 函数再次调用的唯一情况，因此在生成新样本时，`uMode` 必须用新的均匀样本值刷新。
]

```cpp
uMode = rng.Uniform<Float>();
return true;
```


#parec[
  If the path was terminated due to absorption, then there is no more work to do in the `Li()` method; the final radiance value can be returned. Further, if the ray was scattered, then there is nothing more to do but to restart the `while` loop and start sampling the scattered ray. Otherwise, the ray either underwent no scattering events or only underwent null scattering.
][
  如果路径因吸收而终止，则在 `Li()` 方法中无需再进行其他操作，可以返回最终的辐射值。此外，如果光线发生了散射，则只需重新启动 `while` 循环并开始对散射光线进行采样。否则，光线要么没有发生散射事件，要么只发生了空散射。
]

```cpp
<<Handle terminated and unscattered rays after medium sampling>>=
if (terminated) return L;
if (scattered) continue;
<<Add emission to surviving ray>>
<<Handle surface intersection along ray path>>
```


#parec[
  If the ray is unscattered and unabsorbed, then any emitters it interacts with contribute radiance to the path. Either surface emission or emission from infinite light sources is accounted for, depending on whether an intersection with a surface was found. Further, if the ray did not intersect a surface, then the path is finished and the radiance estimate can be returned.
][
  如果光线未发生散射且未被吸收，则其与发射体的交互将为路径贡献辐射值。根据光线是否与表面相交，分别考虑表面发射或来自无限光源的发射。此外，如果光线未与表面相交，则路径结束，可以返回辐射估计值。
]



```cpp
if (si)
    L += beta * si->intr.Le(-ray.d, lambda);
else {
    for (const auto &light : infiniteLights)
        L += beta * light.Le(ray, lambda);
    return L;
}
```

#parec[
  It is still necessary to consider surface intersections, even if scattering from them is not handled by this integrator. There are three cases to consider:
][
  即使该积分器不处理来自表面的散射，仍然需要考虑表面交点。有三种情况需要考虑：
]

#parec[
  - If the surface has no BSDF, it represents a transition between
    different types of participating media. A call to `SkipIntersection()` moves the ray past the intersection and updates its medium
    appropriately.
][
  - 如果表面没有BSDF，它表示不同类型参与介质之间的过渡。调用`SkipIntersection()`将射线移过交点并适当地更新其介质。
]

#parec[
  - If there is a valid `BSDF` and that `BDSF` also returns a valid sample
    from `Sample_f()`, then we have a BSDF that scatters; an error is
    issued and rendering stops.
][
  - 如果有一个有效的`BSDF`，并且该`BSDF`也从`Sample_f()`返回一个有效的样本，那么我们有一个散射的BSDF；发出错误并停止渲染。
]

#parec[
  - A valid but zero-valued BSDF is allowed; such a BSDF should be
    assigned to area light sources in scenes to be rendered using this
    integrator.
][
  - 允许有效但零值的BSDF；这样的BSDF应分配给使用此积分器渲染的场景中的区域光源。
]

```cpp
BSDF bsdf = si->intr.GetBSDF(ray, lambda, camera, buf, sampler);
if (!bsdf)
    si->intr.SkipIntersection(&ray, si->tHit);
else {
    Float uc = sampler.Get1D();
    Point2f u = sampler.Get2D();
    if (bsdf.Sample_f(-ray.d, uc, u))
        ErrorExit("SimpleVolPathIntegrator doesn't support surface scattering.");
    else
        break;
}
```



=== Improving the Sampling Techniques #emoji.warning
<improving-the-sampling-techniques>

#parec[
  The `VolPathIntegrator` adds three significant improvements to the approach implemented in #link("<SimpleVolPathIntegrator>")[`SimpleVolPathIntegrator`];: it supports scattering from surfaces as well as from volumes; it handles spectrally varying medium scattering properties without falling back to sampling a single wavelength; and it samples lights directly, using multiple importance sampling to reduce variance when doing so. The first improvement—​including surface scattering—​is mostly a matter of applying the ideas of @eqt:volpath-surf-vol-simple-estimator, sampling distances in volumes but then choosing surface scattering if the sampled distance is past the closest intersection. For the other two, we will here discuss the underlying foundations before turning to their implementation.
][
  `VolPathIntegrator` 在 #link("<SimpleVolPathIntegrator>")[`SimpleVolPathIntegrator`] 实现的方法上增加了三个显著的改进：它支持来自表面和体积的散射；它处理光谱变化的介质散射特性，而不退回到仅采样单一波长；并且它直接采样光源，使用多重重要性采样来减少方差。 第一个改进——包括表面散射——主要是应用@eqt:volpath-surf-vol-simple-estimator 的思想，在体积中采样距离，但如果采样距离超过最近的交点，则选择表面散射。 对于其他两个改进，我们将在这里讨论其基础原理，然后再转向其实现。
]

==== Chromatic Media
<chromatic-media>

#parec[
  We have thus far glossed over some of the implications of spectrally varying medium properties. Because `pbrt` uses point-sampled spectra, they introduce no complications in terms of evaluating things like the modified path throughput $hat(T)(overline(p)_n)$ or the path throughput weight $beta(overline(p)_n)$ : given a set of path vertices, such quantities can be evaluated for all the wavelength samples simultaneously using the #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] class.
][
  到目前为止，我们略过了光谱变化的介质特性在采样时会引发问题。由于 `pbrt` 使用点采样的光谱，它们在评估诸如修改后的路径通量 $hat(T)(overline(p)_n)$ 或路径通量权重 $beta(overline(p)_n)$ 之类的东西时不会引入复杂性：给定一组路径顶点，可以使用 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] 类同时评估所有波长样本的这些量。
]

#parec[
  The problem with spectrally varying medium properties comes from sampling. Consider a wavelength-dependent function $f_lambda(x)$ that we would like to integrate at $n$ wavelengths $lambda_i$. If we draw samples $x tilde.op p_(lambda_1)$ from a wavelength-dependent PDF based on the first wavelength and then evaluate $f$ at all the wavelengths, we have the estimators
][
  光谱变化的介质特性的问题来自于采样。考虑一个波长相关的函数 $f_lambda(x)$ ，我们希望在 $n$ 个波长 $lambda_i$ 上进行积分。如果我们从基于第一个波长的波长相关概率密度函数中抽取样本 $x tilde.op p_(lambda_1)$，然后在所有波长上评估 $f$，我们有估计器
]

$
  frac([ f_(lambda_1)(x) comma f_(lambda_2)(x) comma dots.h comma f_(lambda_n)(x) ], p_(lambda_1)(x)) .
$

#parec[
  Even if the PDF $p_(lambda_1)$ that was used for sampling matches $f_(lambda_1)$ well, it may be a poor match for $f$ at the other wavelengths. It may not even be a valid PDF for them, if it is zero-valued where the function is nonzero. However, falling back to integrating a single wavelength at a time would be unfortunately inefficient, as shown in @sampled-spectral-distributions.
][
  即使用于采样的 PDF $p_(lambda_1)$ 与 $f_(lambda_1)$ 匹配良好，它可能与其他波长的 $f$ 不匹配。如果在函数非零的地方它为零，它甚至可能不是一个有效的 PDF。 然而，如@sampled-spectral-distributions 所示，退回到每次仅对一个波长进行积分是非常低效的。
]

#parec[
  This problem of a single sampling PDF possibly mismatched with a wavelength-dependent function comes up repeatedly in volumetric path tracing. For example, sampling the majorant transmittance at one wavelength may be a poor approach for sampling it at others. That could be handled by selecting a majorant that bounds all wavelengths' extinction coefficients, but such a majorant would lead to many null-scattering events at wavelengths that could have used a much lower majorant, which would harm performance.
][
  在体积路径追踪中，这种单一采样 PDF 可能与波长相关函数不匹配的问题反复出现。 例如，在一个波长上采样主要界限透射率可能是其他波长上采样它的一个不佳方法。 这可以通过选择一个界定所有波长的消光系数的主要值来处理，但这样的主要值会导致在可以使用更低主要值的波长上出现许多空散射事件，这会损害性能。
]

#parec[
  The path tracer's choice among absorption, real scattering, and null scattering at a sampled point cannot be sidestepped in a similar way: different wavelengths may have quite different probabilities for each of these types of medium interaction, yet with path tracing the integrator must choose only one of them. Splitting up the computation to let each wavelength choose individually would be nearly as inefficient as only considering a single wavelength at a time.
][
  路径追踪器在采样点之间选择吸收、真实散射和空散射的过程不能以类似方式回避：不同波长可能对每种介质相互作用类型有相当不同的概率，但在路径追踪中，积分器必须仅选择其中之一。 将计算分开，让每个波长单独选择几乎和仅考虑一个波长一样低效。
]

#parec[
  However, if a single type of interaction is chosen based on a single wavelength and we evaluate the modified path contribution function $hat(P)$ for all wavelengths, we could have arbitrarily high variance in the other wavelengths. To see why, note how all the $sigma_({s, n})$ factors that came from the $p_e (p_i)$ factors in @eqt:delta-tracking-wip2 canceled out to give the delta-tracking estimator, @eqt:delta-tracking-path-estimator. In the spectral case, if, for example, real scattering is chosen based on a wavelength $lambda$ 's scattering coefficient $sigma_s$ and if a wavelength $lambda'$ has scattering coefficient $sigma'_s$, then the final estimator for $lambda'$ will include a factor of $sigma'_s /  sigma_s$ that can be arbitrarily large.
][
  然而，如果基于单一波长选择一种相互作用类型并评估所有波长的修改路径贡献函数 $hat(P)$，我们可能在其他波长上有任意高的方差。 要理解原因，请注意所有来自@eqt:delta-tracking-wip2 中 $p_e (p_i)$ 因子的 $sigma_({s, n})$ 因子如何相互抵消以给出 delta-追踪估计器，@eqt:delta-tracking-path-estimator。 在光谱情况下，例如，如果基于波长 $lambda$ 的散射系数 $sigma_s$ 选择真实散射，并且波长 $lambda'$ 有散射系数 $sigma'_s$，则 $lambda'$ 的最终估计器将包括一个可以任意大的因子 $sigma'_s / sigma_s$。
]

#parec[
  The fact that #link("../Light_Transport_II_Volume_Rendering/The_Equation_of_Transfer.html#SampleT_maj")[`SampleT_maj()`] nevertheless samples according to a single wavelength's majorant transmittance suggests that there is a solution to this problem. That solution, yet again, is multiple importance sampling. In this case, we are using a single sampling technique rather than MIS-weighting multiple techniques, so we use the single-sample MIS estimator from @eqt:mis-single-sample-estimator, which here gives
][
  尽管如此，#link("../Light_Transport_II_Volume_Rendering/The_Equation_of_Transfer.html#SampleT_maj")[`SampleT_maj()`] 仍然根据单一波长的主要透射率进行采样，这表明对此问题存在解决方案。 这个解决方案，再次，是多重重要性采样。 在这种情况下，我们使用单一采样技术，而不是对多种技术进行 MIS 加权，因此我们使用@eqt:mis-single-sample-estimator 中的单样本 MIS 估计器，这里给出
]

$
  frac(w_(lambda_1)(x), q) frac([ f_(lambda_1)(x) comma f_(lambda_2)(x) comma dots.h comma f_(lambda_n)(x) ], p_(lambda_1)(x)),
$
#parec[
  where $q$ is the discrete probability of sampling using the wavelength $lambda_1$, here uniform at $1 \/ n$ with $n$ the number of spectral samples.
][
  其中 $q$ 是使用波长 $lambda_1$ 采样的离散概率，这里均匀为 $1 \/ n$， $n$ 为光谱样本的数量。
]

#parec[
  The balance heuristic is optimal for single-sample MIS. It gives the MIS weight
][
  对于单样本 MIS，平衡启发式是最优的。 它给出 MIS 权重
]

$
  w_(lambda_1)(x) = frac(p_(lambda_1)(x), sum_(i = 1)^n p_(lambda_i)(x)),
$

#parec[
  which gives the estimator
][
  这给出估计器
]

$
  frac(p_(lambda_1)(x), frac(1, n) sum_(i = 1)^n p_(lambda_i)(x)) frac([ f_(lambda_1)(x) comma f_(lambda_2)(x) comma dots.h comma f_(lambda_n)(x) ], p_(lambda_1)(x)) = frac([ f_(lambda_1)(x) comma f_(lambda_2)(x) comma dots.h comma f_(lambda_n)(x) ], frac(1, n) sum_(i = 1)^n p_(lambda_i)(x)) .
$


#parec[
  See Figure 14.7 for an example that shows the benefits of MIS for chromatic media.
][
  请参见图 14.7，了解一个展示 MIS 对于色彩体积媒体的好处的例子。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f07.svg"),
  caption: [
    #ez_caption[
      Chromatic Volumetric Media. (a) When rendered without spectral MIS, variance is high. (b) Results are much better with spectral MIS, as implemented in the VolPathIntegrator. For this scene, MSE is reduced by a factor of 149. (Scene courtesty of Jim Price.)
    ][
      Chromatic Volumetric Media. (a) 在没有光谱 MIS 的情况下渲染，渲染质量的方差很高。(b) 使用光谱 MIS 后，结果要好得多，如 `VolPathIntegrator` 中实现的那样。在这个场景中，MSE 减少了 149 倍。（场景由 Jim Price 提供。）
    ]
  ],
)<volumetric-chromatic>


==== Direct Lighting

#parec[
  Multiple importance sampling is also at the heart of how the `VolPathIntegrator` samples direct illumination. As with the `PathIntegrator`, we would like to combine the strategies of sampling the light sources with sampling the BSDF or phase function to find light-carrying paths and then to weight the contributions of each sampling technique using MIS. Doing so is more complex than it is in the absence of volumetric scattering, however, because not only does the sampling distribution used at the last path vertex differ (as before) but the `VolPathIntegrator` also uses ratio tracking to estimate the transmittance along the shadow ray. That is a different distance sampling technique than the delta-tracking approach used when sampling ray paths, and so it leads to a different path PDF.
][
  多重重要性采样（MIS）也是 `VolPathIntegrator` 进行直接光照采样的核心机制。与 `PathIntegrator` 类似，我们希望将采样光源和采样 BSDF 或相函数的策略结合起来，以找到携带光线的路径，并使用 MIS 来加权每种采样技术的贡献。然而，与没有体积散射的情况相比，这样做会更加复杂，因为不仅最后路径顶点的采样分布不同（这一点与之前相同）， `VolPathIntegrator` 还使用比例跟踪（ratio tracking）来估计阴影光线上的透射率。这种方法与在采样光线路径时采用的 delta 跟踪方法不同，因此会导致不同的路径概率密度函数（PDF）。
]

#parec[
  In the following, we will say that the two path-sampling techniques used in the `VolPathIntegrator` are #emph[unidirectional path sampling] and #emph[light path sampling];; we will write their respective path PDFs as $p_u$ and $p_l$. The first corresponds to the sampling approach from @evaluating-the-volumetric-path-integral, with delta tracking used to find real-scattering vertices and with the phase function or BSDF sampled to find the new direction at each vertex. Light path sampling follows the same approach up to the last real-scattering vertex before the light vertex; there, the light selects the direction and then ratio tracking gives the transmittance along the last path segment. (See @fig:volpath-directlighting-mis-context.)
][
  在下文中，我们将说 `VolPathIntegrator` 中使用的两种路径采样技术是#emph[单向路径采样];和#emph[光路径采样];；我们将分别将它们的路径 PDF 写为 $p_u$ 和 $p_l$。 第一种对应于@evaluating-the-volumetric-path-integral 中的采样方法，使用 δ 跟踪法找到真实散射顶点，并使用相位函数或 BSDF 在每个顶点采样新方向。 光路径采样遵循相同的方法，直到光顶点之前的最后一个真实散射顶点；在那里，光选择方向，然后比率跟踪给出沿最后路径段的透射率。(See @fig:volpath-directlighting-mis-context.)
]

#parec[
  Given a path $hat(p)_(n-1)$, both approaches share the same path throughput weight $beta$ up to the vertex $p_(n - 1)$ and the same path PDF up to that vertex, $p_u(overline(p_(n-1)))$ .
][
  给定路径 $hat(p)_(n-1)$，两种方法在顶点 $p_(n - 1)$ 之前共享相同的路径传输权重 $beta$ 和相同的路径 PDF， $p_u(overline(p_(n-1)))$。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f08.svg"),
  caption: [
    #ez_caption[
      In the direct lighting calculation, at each path vertex a point is
      sampled on a light source and a shadow ray (dotted line) is traced.
      The `VolPathIntegrator` uses ratio tracking to compute the transmittance
      along the ray by accumulating the product
      $sigma_n \/ sigma_"maj"$ at sampled points along the ray (open
      circles).
      For the MIS weight, it is necessary to be able not only to compute the
      PDF for sampling the corresponding direction at the last path vertex but
      also to compute the probability of generating these samples using delta
      tracking, since that is how the path would be sampled with
      unidirectional path sampling.
    ][
      在直接照明计算中，在每个路径顶点上对光源进行采样，并追踪一条阴影射线（虚线）。 `VolPathIntegrator` 使用比率跟踪通过在射线上的采样点（空心圆）累积
      $sigma_n \/ sigma_"maj"$ 的乘积来计算沿射线的透射率。 对于 MIS 权重，不仅需要能够计算在最后一个路径顶点采样相应方向的
      PDF，还需要计算使用 δ
      跟踪法生成这些样本的概率，因为这就是使用单向路径采样时路径将被采样的方式。
    ]
  ],
)<volpath-directlighting-mis-context>



#parec[
  For the full PDF for unidirectional path sampling, at the last scattering vertex we have the probability of scattering, $sigma_S (p_(n-1)) \/ sigma_"maj"$ times the directional probability for sampling the new direction $p_(omega) (omega_n)$, which is given by the sampling strategy used for the BSDF or phase function. Then, for the path to find an emitter at the vertex $p_n$, it must have only sampled null-scattering vertices between $p_(n - 1)$ and $p_n$ ; absorption or a real-scattering vertex preclude making it to $p_n$.
][
  对于单向路径采样的完整 PDF，在最后的散射顶点，我们有散射的概率， $sigma_S (p_(n-1)) \/ sigma_"maj"$ 乘以用于采样新方向的方向概率 $p_(omega) (omega_n)$，这由用于 BSDF 或相位函数的采样策略给出。 然后，对于在顶点 $p_n$ 找到发射器的路径，它必须只在 $p_(n - 1)$ 和 $p_n$ 之间采样到无散射顶点；吸收或真实散射顶点会阻止到达 $p_n$。
]

#parec[
  Using the results from @evaluating-the-volumetric-path-integral, we can find that the path PDF between two points $p_i$ and $p_j$ with $m$ intermediate null-scattering vertices indexed by $k$ is given by the product of
][
  使用@evaluating-the-volumetric-path-integral 的结果，我们可以发现两个点 $p_i$ 和 $p_j$ 之间的路径 PDF，其中 $m$ 个中间无散射顶点由 $k$ 索引，由以下乘积给出
]

$
  p_e (p_(i + k)) = (sigma_n (p_(i + k))) / sigma_"maj" "and" \ p_"maj" (p_(i + k)) = sigma_"maj" T_"maj" (p_(i + k - 1) arrow.r p_(i + k))
$


#parec[
  for all null-scattering vertices. The $sigma_"maj"$ factors cancel and the null-scattering path probability is
][
  对于所有无散射顶点。 $sigma_"maj"$ 因子相互抵消，无散射路径概率为
]

$
  p_"null" (p_i, p_j) =(product_(k = 1)^m sigma_n (p_(i + k)) T_"maj" (p_(i + k - 1) arrow.r p_(i + k))) T_"maj" (p_(i + m) arrow.r p_j) .
$
#parec[
  The full unidirectional path probability is then given by … (content follows)
][
  完整的单向路径概率则由以下给出 …（内容继续）
]


$
  p_(upright("u")) (overline(p)_n) = p_(upright("u")) ( overline(p)_(n - 1) ) frac(sigma_(upright("s")) (p_(n - 1)), sigma_(upright("maj"))) p_omega (omega_n) p_(upright("null")) ( p_(n - 1) , p_n ) .
$<volpath-unidir-path-probability>


#parec[
  For light sampling, we again have the discrete probability $sigma_(upright("s")) (p_(n - 1)) \/ sigma_(upright("maj"))$ for scattering at $p_(n - 1)$ but the directional PDF at the vertex is determined by the light's sampling distribution, which we will denote by $p_(l , omega) (omega_n)$. The only missing piece is the PDF of the last segment (the shadow ray), where ratio tracking is used. In that case, points are sampled according to the majorant transmittance and so the PDF for a path sampled between points $p_i$ and $p_j$ with $m$ intermediate vertices is
][
  对于光采样，我们再次得到在 $p_(n - 1)$ 处散射的离散概率 $sigma_(upright("s")) (p_(n - 1)) \/ sigma_(upright("maj"))$，但顶点处的方向概率密度函数（PDF）由光的采样分布决定，我们将其表示为 $p_(l , omega) (omega_n)$。唯一缺失的部分是最后一段（阴影光线）的概率密度函数，这里使用了一种称为比率跟踪的方法。在这种情况下，点是根据主要透射率采样的，因此在点 $p_i$ 和 $p_j$ 之间采样路径的概率密度函数，具有 $m$ 个中间顶点为
]

$
  p_(upright("ratio")) (p_i , p_j) = ( product_(k = 1)^m T_(upright("maj")) (p_(i + k - 1) arrow.r p_(i + k)) sigma_(upright("maj")) ) , T_(upright("maj")) (p_(i + m) arrow.r p_j) ,
$<ratio-tracking-pdf>

#parec[
  and the full light sampling path PDF is given by
][
  完整的光采样路径概率密度函数为
]

$
  p_(upright("l")) (overline(p)_n) = p_(upright("u")) ( overline(p)_(n - 1) ) frac(sigma_(upright("s")) (p_(n - 1)), sigma_(upright("maj"))) p_(l , omega) (omega_n) p_(upright("ratio")) ( p_(n - 1) , p_n ) .
$<volpath-light-path-probability>


#parec[
  The `VolPathIntegrator` samples both types of paths according to the first wavelength $lambda_1$ but evaluates these PDFs at all wavelengths so that MIS over wavelengths can be used. Given the path $overline(p)_n$ sampled using unidirectional path sampling and then the path $overline(p)'_n$ sampled using light path sampling, the two-sample MIS estimator is
][
  `VolPathIntegrator` 根据第一个波长 $lambda_1$ 采样两种类型的路径，但在所有波长上评估这些概率密度函数，以便可以应用波长上的多重重要性采样 (MIS)。给定使用单向路径采样的路径 $overline(p)_n$，然后使用光路径采样的路径 $overline(p)'_n$，两样本 MIS 估计器为
]

$
  w_(upright("u")) ( overline(p)_n ) frac(hat(T) (overline(p)_n) L_(upright("e")) (p_n arrow.r p_(n - 1)), p_(upright("u") , lambda_1) (overline(p)_n)) + w_(upright("l")) ( overline(p) prime_n ) frac(hat(T) (overline(p) prime_n) L_(upright("e")) (p prime arrow.r p prime_(n - 1)), p_(upright("l") , lambda_1) (overline(p) prime_n)) .
$<volpath-two-sample-mis-estimator>


#parec[
  Note that because the paths share the same vertices for all of $overline(p)_(n - 1)$, not only do the two $hat(T)$ factors share common factors, but $p_(upright("u") , lambda_1) (overline(p)_n)$ and $p_(upright("l") , lambda_1) (overline(p) prime_n)$ do as well, following @eqt:volpath-unidir-path-probability and @eqt:volpath-light-path-probability.
][
  注意，由于这些路径在所有 $overline(p)_(n - 1)$ 上共享相同的顶点，不仅两个 $hat(T)$ 因子共享公共因子，而且 $p_(upright("u") , lambda_1) (overline(p)_n)$ 和 $p_(upright("l") , lambda_1) (overline(p) prime_n)$ 也是如此，遵循@eqt:volpath-unidir-path-probability) 和 @eqt:volpath-light-path-probability。
]

#parec[
  In this case, the MIS weights can account not only for the differences between unidirectional and light path sampling but also for the different per-wavelength probabilities for each sampling strategy. For example, with the balance heuristic, the MIS weight for the unidirectional strategy works out to be
][
  在这种情况下，MIS 权重不仅可以考虑单向和光路径采样之间的差异，还可以考虑每种采样策略的不同波长概率。例如，使用平衡启发式，单向策略的 MIS 权重为
]

$
  w_(upright("u")) ( overline(p)_n ) = frac(p_(upright("u") , lambda_1) (overline(p)_n), 1 / m (sum_i^m p_(upright("u") , lambda_i) (overline(p)_n) + sum_i^m p_(upright("l") , lambda_i) (overline(p)_n))) ,
$<unidir-light-spectral-mis-weight>


#parec[
  with $m$ the number of spectral samples. The MIS weight for light sampling is equivalent, but with the $p_(u , lambda_1)$ function in the numerator replaced with $p_(l , lambda_1)$.
][
  其中 $m$ 是光谱样本数。光采样的MIS权重是等价的，但分子中的 $p_(u , h e t a_1)$ 函数被 $p_(l , h e t a_1)$ 替换。
]

=== Improved Volumetric Integrator #emoji.warning
<improved-volumetric-integrator>


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/volumetric-lightbulbs.png"),
  caption: [
    #ez_caption[
      Volumetric Emission inside Lightbulbs.
      The flames in each lightbulb are modeled with participating media and
      rendered with the `VolPathIntegrator`.
      #emph[(Scene courtesy of Jim Price.)]
    ][
      灯泡内的体积发射。
      每个灯泡中的火焰通过参与介质建模，并使用 `VolPathIntegrator` 渲染。
      #emph[（场景由 Jim Price 提供。）]
    ]
  ],
)


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/volumetric-paint-water.png"),
  caption: [
    #ez_caption[
      Volumetric Scattering in Liquid.
      Scattering in the paint-infused water is modeled with participating
      media and rendered with the `VolPathIntegrator`.
      #emph[(Scene courtesy of Angelo Ferretti.)]
    ][
      图14.10：液体中的体积散射。
      油漆混合水中的散射通过参与介质建模，并使用 `VolPathIntegrator` 渲染。
      #emph[（场景由 Angelo Ferretti 提供。）]
    ]
  ],
)


#parec[
  The `VolPathIntegrator` pulls together all of these ideas to robustly handle both surface and volume transport. See Figures #link("<fig:volumetric-lightbulbs>")[14.9] and #link("<fig:volumetric-paint-water>")[14.10] for images rendered with this integrator that show off the visual complexity that comes from volumetric emission, chromatic media, and multiple scattering in participating media.
][
  `VolPathIntegrator` 将所有这些想法结合起来，以稳健地处理表面和体积传输。参见图 #link("<fig:volumetric-lightbulbs>")[14.9] 和 #link("<fig:volumetric-paint-water>")[14.10] 中使用该积分器渲染的图像，展示了体积发射、色度介质和参与介质中的多重散射带来的视觉复杂性。
]

```cpp
class VolPathIntegrator : public RayIntegrator {
  public:
    <<VolPathIntegrator Public Methods>>
       VolPathIntegrator(int maxDepth, Camera camera, Sampler sampler,
                         Primitive aggregate, std::vector<Light> lights,
                         const std::string &lightSampleStrategy = "bvh",
                         bool regularize = false)
           : RayIntegrator(camera, sampler, aggregate, lights),
             maxDepth(maxDepth),
             lightSampler(
                 LightSampler::Create(lightSampleStrategy, lights, Allocator())),
             regularize(regularize) {}

       SampledSpectrum Li(RayDifferential ray, SampledWavelengths &lambda,
                          Sampler sampler, ScratchBuffer &scratchBuffer,
                          VisibleSurface *visibleSurface) const;

       static std::unique_ptr<VolPathIntegrator> Create(
           const ParameterDictionary &parameters, Camera camera, Sampler sampler,
           Primitive aggregate, std::vector<Light> lights, const FileLoc *loc);

       std::string ToString() const;
  private:
    <<VolPathIntegrator Private Methods>>
       SampledSpectrum SampleLd(const Interaction &intr, const BSDF *bsdf, SampledWavelengths &lambda,
                                Sampler sampler, SampledSpectrum beta,
                                SampledSpectrum inv_w_u) const;
    <<VolPathIntegrator Private Members>>
       int maxDepth;
       LightSampler lightSampler;
       bool regularize;
};
```


#parec[
  As with the other `Integrator` constructors that we have seen so far, the `VolPathIntegrator` constructor does not perform any meaningful computation, but just initializes member variables with provided values. These three are all equivalent to their parallels in the #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`];.
][
  与之前见到的其他 `Integrator` 构造函数一样，`VolPathIntegrator` 构造函数不执行任何有意义的计算，而只是用提供的值初始化成员变量。这三个都与 #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`] 中的对应项等价。
]

```cpp
int maxDepth;
LightSampler lightSampler;
bool regularize;
```


```cpp
<<VolPathIntegrator Method Definitions>>=
SampledSpectrum VolPathIntegrator::Li(RayDifferential ray,
        SampledWavelengths &lambda, Sampler sampler,
        ScratchBuffer &scratchBuffer, VisibleSurface *visibleSurf) const {
    <<Declare state variables for volumetric path sampling>>
    while (true) {
        <<Sample segment of volumetric scattering path>>
    }
    return L;
}
```

#parec[
  There is a common factor of $p_(u,lambda_1) (overline(p)_n)$ in the denominator of the first term of the two-sample MIS estimator, @eqt:volpath-two-sample-mis-estimator, and the numerator of the MIS weights, @eqt:unidir-light-spectral-mis-weight. There is a corresponding $p_(l,lambda_1)$ factor in the second term of the estimator and in the $w_l$ weight. It is tempting to cancel these out; in that case, the path state to be tracked by the integrator would consist of $hat(T) (overline(p)_n)$ and the wavelength-dependent probabilities $p_u(overline(p)_n)$ and $p_l(overline(p)_n)$. Doing so is mathematically valid and would provide all the quantities necessary to evaluate @eqt:volpath-two-sample-mis-estimator)), but suffers from the problem that the quantities involved may overflow or underflow the range of representable floating-point values.
][
  在两样本 MIS 估计器（@eqt:volpath-two-sample-mis-estimator）的第一项分母和 MIS 权重（@eqt:unidir-light-spectral-mis-weight）的分子中，存在一个公共因子 $p_(u,lambda_1) (overline(p)_n)$。在估计器的第二项以及权重 $w_l$ 中，也存在对应的 $p_(l,lambda_1)$ 因子。乍一看，可以尝试将这些因子抵消；在这种情况下，积分器需要跟踪的路径状态将由 $hat(T) (overline(p)_n)$ 以及波长相关的概率 $p_u(overline(p)_n)$ 和 $p_l(overline(p)_n)$ 组成。这样做在数学上是可行的，并且可以提供评估@eqt:volpath-two-sample-mis-estimator 所需的所有量，但存在一个问题：所涉及的数值可能会超出浮点数的可表示范围，从而导致溢出或下溢。
]

#parec[
  To understand the problem, consider a highly specular surface—the BSDF will have a large value for directions around its peak, but the PDF for sampling those directions will also be large. That causes no problems in the `PathIntegrator` , since its `beta` variable tracks their ratio, which ends up being close to 1. However, with $overline(T) (overline(p)_n)$ maintained independently, a series of specular bounces could lead to overflow. (Many null-scattering events along a path can cause similar problems.)
][
  为理解这一问题，考虑一个高度镜面的表面——在接近其峰值方向时，BSDF 会有较大的值，同时采样这些方向的 PDF 也会很大。在 `PathIntegrator` 中，这不会引发问题，因为其 `beta` 变量追踪的是二者的比值，该比值通常接近 1。然而，如果单独维护 $hat(T) (overline(p)_n)$ ，一系列镜面反射可能导致数值溢出。（路径中出现许多空散射事件也可能引发类似问题。）
]

#parec[
  Therefore, the `VolPathIntegrator` tracks the path throughput weight for the sampled path.
][
  因此，`VolPathIntegrator` 选择直接追踪已采样路径的通量权重，以避免这些数值问题。
]

$ beta (overline(p)_n) = frac(hat(T) (overline(p)_n), p_(u , lambda 1) (overline(p)_n)) , $


#parec[
  which is numerically well behaved. Directly tracking the probabilities $p_u (overline(p)_n)$ and $p_l (overline(p)_n)$ would also stress the range of floating-point numbers, so instead it tracks the #emph[rescaled path
probabilities]
][
  其数值性质良好。直接跟踪概率 $p_u (overline(p)_n)$ 和 $p_l (overline(p)_n)$ 也会增加浮点数范围的压力，因此改为跟踪#emph[重缩放路径概率]
]

$
  r_(u , lambda_i) ( overline(p)_n ) = frac(p_(u , lambda_i) (overline(p)_n), p_(upright("path")) (overline(p)_n)) quad upright("and") quad r_(l , lambda_i) ( overline(p)_n ) = frac(p_(l , lambda_i) (overline(p)_n), p_(upright("path")) (overline(p)_n)) ,
$<volpath-rescaled-path-probabilities>


#parec[
  where $p_(upright("path")) (overline(p)_n)$ is the probability for sampling the current path. It is equal to the light path probability $p_(l , lambda 1)$ for paths that end with a shadow ray from light path sampling and the unidirectional path probability otherwise. (Later in the implementation, we will take advantage of the fact that these two probabilities are the same until the last scattering vertex, which in turn implies that whichever of them is chosen for $p_(upright("path"))$ does not affect the values of $r_(u , lambda_i) (overline(p)_(n - 1))$ and $r_(l , lambda_i) (overline(p)_(n - 1))$.)
][
  其中 $p_(upright("path")) (overline(p)_n)$ 是采样当前路径的概率。对于以光路径采样的阴影光线结束的路径，它等于光路径概率 $p_(l , lambda 1)$，否则等于单向路径的概率。 （在后续的实现中，我们将利用这两个概率在最后一个散射顶点之前相同的事实，这反过来意味着无论选择哪个作为 $p_(upright("path"))$ 都不会影响 $r_(u , lambda_i) (overline(p)_(n - 1))$ 和 $r_(l , lambda_i) (overline(p)_(n - 1))$ 的值。）
]

#parec[
  These rescaled path probabilities are all easily incrementally updated during path sampling.
][
  这些重缩放路径概率在路径采样过程中都可以容易地增量更新。
]

#parec[
  If $p_(upright("path")) = p_(u , lambda 1)$, then MIS weights like those in @eqt:unidir-light-spectral-mis-weight can be found with
][
  如果 $p_(upright("path")) = p_(u , lambda 1)$，那么可以通过以下方式计算出类似方@eqt:unidir-light-spectral-mis-weight 中的 MIS 权重
]

$
  w_u (overline(p)_n) = frac(1, 1 / m (sum_i^m r_(u , lambda_i) (overline(p)_n) + sum_i^m r_(l , lambda_i) (overline(p)_n))) ,
$<volpath-wu-from-rescaled-probabilities>


#parec[
  and similarly for $w_l$ when $p_(p a t h) = p_(l , lambda 1)$.
][
  当 $p_(p a t h) = p_(l , lambda 1)$ 时， $w_l$ 的情况也是类似的。
]

#parec[
  The remaining variables in the following fragment have the same function as the variables of the same names in the #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[PathIntegrator];.
][
  以下片段中的其余变量与 #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[PathIntegrator] 中同名变量具有相同的功能。
]

```cpp
<<Declare state variables for volumetric path sampling>>=
SampledSpectrum L(0.f), beta(1.f), r_u(1.f), r_l(1.f);
bool specularBounce = false, anyNonSpecularBounces = false;
int depth = 0;
Float etaScale = 1;
```


#parec[
  The `while` loop for each ray segment starts out similarly to the corresponding loop in the `SimpleVolPathIntegrator`: the integrator traces a ray to find a $t_"max"$ value at the closest surface intersection before sampling the medium, if any, between the ray origin and the intersection point.
][
  对于每条光线段的 `while` 循环，其起始部分与 `SimpleVolPathIntegrator` 中对应的循环类似：积分器会追踪光线以找到最近表面交点处的 $t_"max"$ 值，然后（如果存在）对光线起点和交点之间的介质进行采样。
]

```cpp
<<Sample segment of volumetric scattering path>>=
pstd::optional<ShapeIntersection> si = Intersect(ray);
if (ray.medium) {
    <<Sample the participating medium>>
}
<<Handle surviving unscattered rays>>
```

#parec[
  The form of the fragment for sampling the medium is similar as well: `tMax` is set using the ray intersection $t$, if available, and an `RNG` is prepared before medium sampling proceeds. If the path is terminated or undergoes real scattering in the medium, then no further work is done to sample surface scattering at a ray intersection point.
][
  用于采样介质的代码片段形式也类似：如果存在光线交点，`tMax` 将根据光线交点的 $t$ 值进行设置，并在介质采样之前准备一个 `RNG`。如果路径在介质中终止或发生真实散射，则不会进一步对光线交点处的表面散射进行采样。
]


```cpp
<<Sample the participating medium>>=
bool scattered = false, terminated = false;
Float tMax = si ? si->tHit : Infinity;
<<Initialize RNG for sampling the majorant transmittance>>
SampledSpectrum T_maj = SampleT_maj(ray, tMax, sampler.Get1D(), rng, lambda,
        [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
            SampledSpectrum T_maj) {
            <<Handle medium scattering event for ray>>
        });
<<Handle terminated, scattered, and unscattered medium rays>>
```


#parec[
  Given a sampled point $p'$ in the medium, the lambda function's task is to evaluate the $overline(L)_n$ source function, taking care of the second case of @eqt:volpath-surf-vol-simple-estimator.
][
  给定介质中一个采样点 $p'$，lambda 函数的任务是评估 $overline(L)_n$ 源函数，负责处理@eqt:volpath-surf-vol-simple-estimator 的第二种情况。
]


```cpp
<<Handle medium scattering event for ray>>=
<<Add emission from medium scattering event>>
<<Compute medium event probabilities for interaction>>
<<Sample medium scattering event type and update path>>
```

#parec[
  A small difference from the `SimpleVolPathIntegrator` is that volumetric emission is added at every point that is sampled in the medium rather than only when the absorption case is sampled. There is no reason not to do so, since emission is already available via the `MediumProperties` passed to the lambda function.
][
  与 `SimpleVolPathIntegrator` 略有不同的是，体积发射会在介质中每个被采样的点处添加，而不仅仅是在采样吸收情况时添加。这样做没有理由不妥，因为发射信息已经通过传递给 lambda 函数的 `MediumProperties` 可用。
]

```cpp
<<Add emission from medium scattering event>>=
if (depth < maxDepth && mp.Le) {
    <<Compute  at new path vertex>>
    <<Compute rescaled path probability for absorption at path vertex>>
    <<Update L for medium emission>>
}
```

#parec[
  In the following, we will sometimes use the notation $[overline(p)_n + p']$ to denote the path $overline(p)_n$ with the vertex $p'$ appended to it. Thus, for example, $overline(p)_n = [overline(p)_(n-1) + p_n]$. The estimator that gives the contribution for volumetric emission at $p'$ is then
][
  在接下来的内容中，我们有时会使用符号 $[overline(p)_n + p']$ 来表示在路径 $overline(p)_n$ 的末尾附加一个顶点 $p'$ 后得到的路径。例如， $overline(p)_n = [overline(p)_(n-1) + p_n]$。用于计算在 $p'$ 处体积发射贡献的估计器为：
]

$ beta ([overline(p)_n + p prime]) sigma_a (p prime) L_e (p prime arrow.r p_n) . $<volpath-emission-basic-estimator>

#parec[
  `beta` holds $beta (overline(p)_n)$, so we can incrementally compute $beta ([overline(p)_n + p prime])$ by
][
  `beta` 保存 $beta (overline(p)_n)$，因此我们可以通过以下方式增量计算 $beta ([overline(p)_n + p prime])$
]

$
  beta ( [overline(p)_n + p prime] ) = frac(beta (overline(p)_n) T_(upright("maj")) (p_n arrow.r p prime), p_e (p prime) p_(upright("maj")) (p prime divides p_n , omega)) .
$


#parec[
  From @evaluating-the-volumetric-path-integral, we know that $p_(upright("maj")) (p_(i + 1) divides p_i , omega) = sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$. Because we are always sampling absorption (at least as far as including emission goes), $p_e$ is 1 here.
][
  从@evaluating-the-volumetric-path-integral 中，我们知道 $p_(upright("maj")) (p_(i + 1) divides p_i , omega) = sigma_(upright("maj")) e^(- sigma_(upright("maj")) t)$。因为我们总是在采样吸收（至少在涉及到发射的情况下），所以此处 $p_e$ 为 1。
]

```cpp
<<Compute  at new path vertex>>=
Float pdf = sigma_maj[0] * T_maj[0];
SampledSpectrum betap = beta * T_maj / pdf;
```


#parec[
  Even though this is the only sampling technique for volumetric emission, different wavelengths may sample this vertex with different probabilities, so it is worthwhile to apply MIS over the wavelengths' probabilities. With `r_u` storing the rescaled unidirectional probabilities up to the previous path vertex, the rescaled path probabilities for sampling the emissive vertex, `r_e`, can be found by multiplying `r_u` by the per-wavelength $p_(upright("maj"))$ probabilities and dividing by the probability for the wavelength that was used for sampling $p prime$, which is already available in `pdf`. (Note that in monochromatic media, these ratios are all 1.)
][
  尽管这是唯一的体积发射采样技术，不同波长可能以不同概率采样该顶点，因此在波长概率上应用 MIS 是值得的。`r_u` 存储到前一个路径顶点的重新缩放单向概率，采样发射顶点的重新缩放路径概率 `r_e` 可以通过将 `r_u` 乘以每波长 $p_(upright("maj"))$ 概率并除以用于采样 $p prime$ 的波长概率来找到，这在 `pdf` 中已可用。（注意，在单色介质中，这些比率全为 1。）
]

```cpp
<<Compute rescaled path probability for absorption at path vertex>>=
SampledSpectrum r_e = r_u * sigma_maj * T_maj / pdf;
```

#parec[
  Here we have a single-sample MIS estimator with balance heuristic weights given by
][
  这里我们有一个具有平衡启发式权重的单样本 MIS 估计器。
]

$
  w_e ([overline(p)_n + p prime]) = frac(1, 1 / m sum_i^m r_(e , lambda_i) ([overline(p)_n + p prime])) .
$<volpath-emission-spectral-mis>


#parec[
  The absorption coefficient and emitted radiance for evaluating @eqt:volpath-emission-spectral-mis are available in `MediumProperties` and the `SampledSpectrum::Average()` method conveniently computes the average of rescaled probabilities in the denominator of @eqt:volpath-emission-spectral-mis.
][
  吸收系数和用于评估方@eqt:volpath-emission-spectral-mis 的发射辐射亮度在`MediumProperties`中可用，而`SampledSpectrum::Average()`方法可以方便地计算@eqt:volpath-emission-spectral-mis 分母中重新缩放概率的平均值。
]

```cpp
if (r_e)
    L += betap * mp.sigma_a * mp.Le / r_e.Average();
```

#parec[
  Briefly returning to the initialization of `betap` and `r_e` in the previous fragments: it may seem tempting to cancel out the `T_maj` factors from them, but note how the final estimator does not perform a component-wise division of these two quantities but instead divides by the average of the rescaled probabilities when computing the MIS weight. Thus, performing such cancellations would lead to incorrect results. #footnote[This misconception periodically played a role in our
    initial development of this integrator.]
][
  简要回顾前面片段中`betap`和`r_e`的初始化：可能会有取消它们中的`T_maj`因子的冲动，但请注意，最终估计器并没有对这两个量进行逐分量除法，而是在计算MIS权重时除以重新缩放概率的平均值。因此，进行这样的取消会导致错误的结果。#footnote[This misconception periodically played a role in our
    initial development of this integrator.]
]

#parec[
  After emission is handled, the next step is to determine which term of $L_n$ to evaluate; this follows the same approach as in the `SimpleVolPathIntegrator`.
][
  处理完发射后，下一步是确定要评估的 $L_n$ 的哪个项；这与`SimpleVolPathIntegrator`中的方法相同。
]


```cpp
<<Sample medium scattering event type and update path>>=
Float um = rng.Uniform<Float>();
int mode = SampleDiscrete({pAbsorb, pScatter, pNull}, um);
if (mode == 0) {
    <<Handle absorption along ray path>>
} else if (mode == 1) {
    <<Handle scattering along ray path>>
} else {
    <<Handle null scattering along ray path>>
}
```


#parec[
  As before, the ray path is terminated in the event of absorption. Since any volumetric emission at the sampled point has already been added, there is nothing to do but handle the details associated with ending the path.
][
  与之前一样，当发生吸收时，光线路径会终止。由于采样点处的任何体积发射已被添加，因此只需处理路径终止相关的细节即可，无需进行其他操作。
]

```cpp
<<Handle absorption along ray path>>=
terminated = true;
return false;
```

#parec[
  For a real-scattering event, a shadow ray is traced to a light to sample direct lighting, and the path state is updated to account for the new ray. A false value returned from the lambda function prevents further sample generation along the current ray.
][
  对于真实散射事件，将向光源追踪一条阴影光线以采样直接光照，并更新路径状态以考虑新生成的光线。从 lambda 函数返回的 `false` 值会阻止沿当前光线生成进一步的采样。
]

```cpp
<<Handle scattering along ray path>>=
<<Stop path sampling if maximum depth has been reached>>
<<Update beta and r_u for real-scattering event>>
if (beta && r_u) {
    <<Sample direct lighting at volume-scattering event>>
    <<Sample new direction at real-scattering event>>
}
return false;
```

#parec[
  The PDF for real scattering at this vertex is the product of the PDF for sampling its distance along the ray, $sigma_"maj" e^(-sigma_"maj") t$, and the probability for sampling real scattering, $ sigma_s(p') / sigma_"maj" $. The $sigma_"maj"$ values cancel.
][
  在该顶点发生真实散射的 PDF 是沿光线采样其距离的 PDF $sigma_"maj" e^(-sigma_"maj") t$ 与采样真实散射的概率 $ sigma_s(p') / sigma_"maj" $. The $sigma_"maj"$ 的乘积，其中 $sigma_"maj"$ 的值相互抵消。
]

#parec[
  Given the PDF value, `beta` can be updated to include $T_"maj"$ along the segment up to the new vertex divided by the PDF. The rescaled probabilities are computed in the same way as the path sampling PDF before being divided by it, following @eqt:volpath-rescaled-path-probabilities. The rescaled light path probabilities will be set shortly, after a new ray direction is sampled.
][
  给定 PDF 值后，可以更新 `beta`，以包含到新顶点为止路径段上的 $T_"maj"$ 除以 PDF 的值。重新缩放的概率与路径采样 PDF 的计算方式相同，在被其除之前按照@eqt:volpath-rescaled-path-probabilities 进行。新的光线方向采样完成后，重新缩放的光路径概率将被设置。
]

```cpp
<<Update beta and r_u for real-scattering event>>=
Float pdf = T_maj[0] * mp.sigma_s[0];
beta *= T_maj * mp.sigma_s / pdf;
r_u *= T_maj * mp.sigma_s / pdf;
```


#parec[
  Direct lighting is handled by the `SampleLd()` method, which we will defer until later in this section.
][
  直接光照由 `SampleLd()` 方法处理，我们将在本节稍后详细介绍该方法。
]

```cpp
<<Sample direct lighting at volume-scattering event>>=
MediumInteraction intr(p, -ray.d, ray.time, ray.medium, mp.phase);
L += SampleLd(intr, nullptr, lambda, sampler, beta, r_u);
```

#parec[
  Sampling the phase function gives a new direction at the scattering event.
][
  Sampling the phase function gives a new direction at the scattering event.
]

```cpp
<<Sample new direction at real-scattering event>>=
Point2f u = sampler.Get2D();
pstd::optional<PhaseFunctionSample> ps = intr.phase.Sample_p(-ray.d, u);
if (!ps || ps->pdf == 0)
    terminated = true;
else {
    <<Update ray path state for indirect volume scattering>>
}
```

#parec[
  There is a bit of bookkeeping to take care of after a real-scattering event. We can now incorporate the phase function value into `beta`, which completes the contribution of $hat(f)$ from @eqt:scatfun-generalized . Because both unidirectional path sampling and light path sampling use the same set of sampling operations up to a real-scattering vertex, an initial value for the rescaled light path sampling probabilities `r_l` comes from the value of the rescaled unidirectional probabilities before scattering. It is divided by the directional PDF from $p_(u,lambda_1)$ for this vertex here. The associated directional PDF for light sampling at this vertex will be incorporated into `r_l` later. There is no need to update `r_u` here, since the scattering direction's probability is the same for all wavelengths and so the update factor would always be 1.
][
  在发生真实散射事件后，需要处理一些记录工作。现在可以将相函数的值合并到 `beta` 中，从而完成@eqt:scatfun-generalized 中 $hat(f)$ 的贡献。由于单向路径采样和光路径采样在到达真实散射顶点之前使用的是相同的一组采样操作，重新缩放的光路径采样概率 `r_l` 的初始值来源于散射前重新缩放的单向概率值。在这里，它被当前顶点的方向 PDF $p_(u,lambda_1)$ 所除。与光采样相关的方向 PDF 将稍后整合到 `r_l` 中。
]


#parec[
  At this point, the integrator also updates various variables that record the scattering history and updates the current ray.
][
  此处无需更新 `r_u`，因为散射方向的概率对所有波长都是相同的，因此更新因子始终为 1。
]

```cpp
<<Update ray path state for indirect volume scattering>>=
beta *= ps->p / ps->pdf;
r_l = r_u / ps->pdf;
prevIntrContext = LightSampleContext(intr);
scattered = true;
ray.o = p;
ray.d = ps->wi;
specularBounce = false;
anyNonSpecularBounces = true;
```

#parec[
  If the ray intersects a light source, the `LightSampleContext` from the previous path vertex will be needed to compute MIS weights; `prevIntrContext` is updated to store it after each scattering event, whether in a medium or on a surface.
][
  如果光线与光源相交，则需要上一路径顶点的 `LightSampleContext` 来计算多重重要性采样（MIS）的权重。在每次散射事件后，无论是在介质中还是在表面上，`prevIntrContext` 都会被更新以存储该上下文。
]

```cpp
LightSampleContext prevIntrContext;
```

#parec[
  If null scattering is selected, the updates to `beta` and the rescaled path sampling probabilities follow the same form as we have seen previously: the former is given by @eqt:throughput-generalized and the latter with a $p_e = sigma_n / sigma_"maj"$ factor where, as with real scattering, the $sigma_"maj"$ cancels with a corresponding factor from the $p_"maj"$ probability (Section 14.1.5).
][
  如果选择了空散射，对 `beta` 和重新缩放路径采样概率的更新形式与之前看到的相同：前者由@eqt:throughput-generalized 给出，后者通过一个 $p_e = sigma_n / sigma_"maj"$ 因子更新，其中与真实散射类似， $sigma_"maj"$ 与 $p_"maj"$ 概率中的对应因子相互抵消（参见第 14.1.5 节）。
]

#parec[
  In this case, we also must update the rescaled path probabilities for sampling this path vertex via light path sampling, which samples path vertices according to $p_"maj"$.
][
  在这种情况下，还必须更新通过光路径采样（根据 $p_"maj"$ 采样路径顶点）采样该路径顶点的重新缩放路径概率。
]

#parec[
  This fragment concludes the implementation of the lambda function that is passed to the `SampleT_maj()` function.
][
  此代码片段完成了传递给 `SampleT_maj()` 函数的 lambda 函数的实现。
]


```cpp
<<Handle null scattering along ray path>>=
SampledSpectrum sigma_n = ClampZero(sigma_maj - mp.sigma_a - mp.sigma_s);
Float pdf = T_maj[0] * sigma_n[0];
beta *= T_maj * sigma_n / pdf;
if (pdf == 0) beta = SampledSpectrum(0.f);
r_u *= T_maj * sigma_n / pdf;
r_l *= T_maj * sigma_maj / pdf;
return beta && r_u;
```


#parec[
  Returning to the `Li()` method immediately after the `SampleT_maj()` call, if the path terminated due to absorption, it is only here that we can break out and return the radiance estimate to the caller of the `Li()` method. Further, it is only here that we can jump back to the start of the `while` loop for rays that were scattered in the medium.
][
  在`SampleT_maj()`调用之后立即返回到`Li()`方法，如果路径因吸收而终止，只有在这里我们才能跳出并将辐射估计返回给`Li()`方法的调用者。此外，只有在这里我们才能跳回到`while`循环的开始，以处理在介质中散射的射线。
]


```cpp
<<Handle terminated, scattered, and unscattered medium rays>>=
if (terminated || !beta || !r_u) return L;
if (scattered) continue;
```

#parec[
  With those cases taken care of, we are left with rays that either underwent no scattering events in the medium or only underwent null scattering. For those cases, both the path throughput weight $beta$ and the rescaled path probabilities must be updated. $beta$ takes a factor of $T_"maj"$ to account for the transmittance from either the last null-scattering event or the ray's origin to the ray's $t_"max"$ position. The rescaled unidirectional and light sampling probabilities also take the same $T_"maj"$, which corresponds to the final factors outside of the parenthesis in the definitions of $p_"null"$ and $p_"ratio"$.
][
  在处理完这些情况后，剩下的光线要么在介质中没有发生散射事件，要么只发生了空散射。对于这些情况，路径的通量权重 $beta$ 和重新缩放的路径概率都需要更新。 $beta$ 乘以一个 $T_"maj"$ 因子，以考虑从上一次空散射事件或光线起点到光线 $t_"max"$ 位置的透射率。重新缩放的单向和光采样概率也乘以相同的 $T_"maj"$，这对应于 $p_"null"$ 和 $p_"ratio"$ 定义中括号外的最终因子。
]


```cpp
beta *= T_maj / T_maj[0];
r_u *= T_maj / T_maj[0];
r_l *= T_maj / T_maj[0];
```

#parec[
  There is much more to do for rays that have either escaped the scene or have intersected a surface without medium scattering or absorption. We will defer discussion of the first following fragment, `<<Add emitted light at volume path vertex or from the environment>>`, until later in the section when we discuss the direct lighting calculation. A few of the others are implemented reusing fragments from earlier integrators.
][
  对于已经逃出场景或与表面相交但没有发生介质散射或吸收的光线，还有更多内容需要处理。我们将推迟对以下代码片段的讨论 `<<Add emitted light at volume path vertex or from the environment>>`，直到本节稍后直接光照计算时再详述。其他一些情况的实现重复使用了早期积分器中的代码片段。
]

```cpp
<<Handle surviving unscattered rays>>=
<<Add emitted light at volume path vertex or from the environment>>
<<Get BSDF and skip over medium boundaries>>
<<Initialize visibleSurf at first intersection>>
<<Terminate path if maximum depth reached>>
<<Possibly regularize the BSDF>>
<<Sample illumination from lights to find attenuated path contribution>>
<<Sample BSDF to get new volumetric path direction>>
<<Account for attenuated subsurface scattering, if applicable>>
<<Possibly terminate volumetric path with Russian roulette>>
```


#parec[
  As with the `PathIntegrator`, path termination due to reaching the maximum depth only occurs after accounting for illumination from any emissive surfaces that are intersected.
][
  与 `PathIntegrator` 类似，由于达到最大深度而终止路径时，仅在考虑了与任何发射表面相交的光照后才会发生。
]


```cpp
if (depth++ >= maxDepth)
    return L;
```
#parec[
  Sampling the light source at a surface intersection is handled by the same `SampleLd()` method that is called for real-scattering vertices in the medium. As with medium scattering, the `LightSampleContext` corresponding to this scattering event is recorded for possible later use in MIS weight calculations.
][
  在表面交点处采样光源由与介质中真实散射顶点调用相同的 `SampleLd()` 方法处理。与介质散射类似，此次散射事件对应的 `LightSampleContext` 被记录下来，以便后续可能用于 MIS 权重计算。
]

```cpp
if (IsNonSpecular(bsdf.Flags()))
    L += SampleLd(isect, &bsdf, lambda, sampler, beta, r_u);
prevIntrContext = LightSampleContext(isect);
```

#parec[
  The logic for sampling scattering at a surface is very similar to the corresponding logic in the `PathIntegrator`.
][
  在表面处采样散射的逻辑与 `PathIntegrator` 中对应的逻辑非常相似。
]


```cpp
Vector3f wo = isect.wo;
Float u = sampler.Get1D();
pstd::optional<BSDFSample> bs = bsdf.Sample_f(wo, u, sampler.Get2D());
if (!bs) break;
<<Update beta and rescaled path probabilities for BSDF scattering>>  beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
   if (bs->pdfIsProportional)
       r_l = r_u / bsdf.PDF(wo, bs->wi);
   else
       r_l = r_u / bs->pdf;
<<Update volumetric integrator path state after surface scattering>>  specularBounce = bs->IsSpecular();
   anyNonSpecularBounces |= !bs->IsSpecular();
   if (bs->IsTransmission())
       etaScale *= Sqr(bs->eta);
   ray = isect.SpawnRay(ray, bsdf, bs->wi, bs->flags, bs->eta);
```

#parec[
  Given a BSDF sample, $beta$ is first multiplied by the value of the BSDF, which takes care of $hat(f)$ from @eqt:scatfun-generalized. This is also a good time to incorporate the cosine factor from the $C_p$ factor of the generalized geometric term, @eqt:g-generalized.
][
  给定一个 BSDF 样本，首先将 $beta$ 乘以 BSDF 的值，从而处理@eqt:scatfun-generalized 中的 $hat(f)$。此时也可将广义几何项 @eqt:g-generalized 中 $C_p$ 因子的余弦项纳入计算。
]


#parec[
  Updates to the rescaled path probabilities follow how they were done for medium scattering: first, there is no need to update `r_u` since the probabilities are the same over all wavelengths. The rescaled light path sampling probabilities are also initialized from `r_u`, here also with only the $1 / p_(u,lambda_1)$ factor included. The other factors in `r_l` will only be computed and included if the ray intersects an emitter; otherwise `r_l` is unused.
][
  重新缩放路径概率的更新与介质散射的方式类似：首先，无需更新 `r_u`，因为概率在所有波长上是相同的。重新缩放的光路径采样概率也从 `r_u` 初始化，这里只包含 $1 / p_(u,lambda_1)$ 因子。如果光线与发射体相交，`r_l` 的其他因子才会被计算并纳入；否则，`r_l` 不会被使用。
]


#parec[
  One nit in updating `r_l` is that the BSDF and PDF value returned in the `BSDFSample` may only be correct up to a (common) scale factor. This case comes up with sampling techniques like the random walk used by the `LayeredBxDF` that is described in @layered-bxdf. In that case, a call to `BSDF::PDF()` gives an independent value for the PDF that can be used.
][
  更新 `r_l` 时需要注意，`BSDFSample` 返回的 BSDF 和 PDF 值可能仅正确到某个（公共）比例因子。这种情况出现在像 `LayeredBxDF` 的随机游走采样技术中（详见@layered-bxdf）。在这种情况下，调用 `BSDF::PDF()` 会返回一个独立的 PDF 值供使用。
]


```cpp
beta *= bs->f * AbsDot(bs->wi, isect.shading.n) / bs->pdf;
if (bs->pdfIsProportional)
    r_l = r_u / bsdf.PDF(wo, bs->wi);
else
    r_l = r_u / bs->pdf;
```

#parec[
  A few additional state variables must be updated after surface scattering, as well.
][
  表面散射后还需要更新一些额外的状态变量。
]


```cpp
specularBounce = bs->IsSpecular();
anyNonSpecularBounces |= !bs->IsSpecular();
if (bs->IsTransmission())
    etaScale *= Sqr(bs->eta);
ray = isect.SpawnRay(ray, bsdf, bs->wi, bs->flags, bs->eta);
```

#parec[
  Russian roulette follows the same general approach as before, though we scale `beta` by the accumulated effect of radiance scaling for transmission that is encoded in `etaScale` and use the balance heuristic over wavelengths. If the Russian roulette test passes, `beta` is updated with a factor that accounts for the survival probability, `1 - q`.
][
  俄罗斯轮盘赌的处理方式与之前的逻辑相似，但这里将 `beta` 乘以存储在 `etaScale` 中的透射辐射缩放累积效应，并在波长上使用平衡启发式（balance heuristic）。如果俄罗斯轮盘赌测试通过，`beta` 会根据存活概率 `1 - q` 进行更新。
]


```cpp
SampledSpectrum rrBeta = beta * etaScale / r_u.Average();
Float uRR = sampler.Get1D();
if (rrBeta.MaxComponentValue() < 1 && depth > 1) {
    Float q = std::max<Float>(0, 1 - rrBeta.MaxComponentValue());
    if (uRR < q) break;
    beta /= 1 - q;
}
```

==== Estimating Direct Illumination
<estimating-direct-illumination>

#parec[
  All that remains in the #link("<VolPathIntegrator>")[`VolPathIntegrator`];'s implementation is direct illumination. We will start with the `SampleLd()` method, which is called to estimate scattered radiance due to direct illumination by sampling a light source, both at scattering points in media and on surfaces. (It is responsible for computing the second term of @eqt:volpath-two-sample-mis-estimator) The purpose of most of its parameters should be evident. The last, `r_p`, gives the rescaled path probabilities up to the vertex `intr`. (A separate variable named `r_u` will be used in the function's implementation, so a new name is needed here.)
][
  在 #link("<VolPathIntegrator>")[`VolPathIntegrator`] 的实现中，剩下的就是直接光照。我们将从 `SampleLd()` 方法开始，该方法通过采样光源来估算由于直接光照引起的散射辐射，既在介质中的散射点也在表面上。（它负责计算@eqt:volpath-two-sample-mis-estimator) 的第二项。）大多数参数的用途应该是显而易见的。最后一个参数 `r_p` 给出了到顶点 `intr` 的重缩放路径概率。由于函数实现中会使用一个名为 `r_u` 的变量，因此这里需要一个新的名称。
]

```cpp
SampledSpectrum VolPathIntegrator::SampleLd(const Interaction &intr,
        const BSDF *bsdf, SampledWavelengths &lambda, Sampler sampler,
        SampledSpectrum beta, SampledSpectrum r_p) const {
    <<Estimate light-sampled direct illumination at intr>>        <<Initialize LightSampleContext for volumetric light sampling>>           LightSampleContext ctx;
          if (bsdf) {
              ctx = LightSampleContext(intr.AsSurface());
              <<Try to nudge the light sampling position to correct side of the surface>>                  BxDFFlags flags = bsdf->Flags();
                 if (IsReflective(flags) && !IsTransmissive(flags))
                     ctx.pi = intr.OffsetRayOrigin(intr.wo);
                 else if (IsTransmissive(flags) && !IsReflective(flags))
                     ctx.pi = intr.OffsetRayOrigin(-intr.wo);
          }
          else ctx = LightSampleContext(intr);
       <<Sample a light source using lightSampler>>           Float u = sampler.Get1D();
          pstd::optional<SampledLight> sampledLight = lightSampler.Sample(ctx, u);
          Point2f uLight = sampler.Get2D();
          if (!sampledLight)
              return SampledSpectrum(0.f);
          Light light = sampledLight->light;

       <<Sample a point on the light source>>           pstd::optional<LightLiSample> ls =
              light.SampleLi(ctx, uLight, lambda, true);
          if (!ls || !ls->L || ls->pdf == 0)
              return SampledSpectrum(0.f);
          Float lightPDF = sampledLight->p * ls->pdf;
       <<Evaluate BSDF or phase function for light sample direction>>           Float scatterPDF;
          SampledSpectrum f_hat;
          Vector3f wo = intr.wo, wi = ls->wi;
          if (bsdf) {
              <<Update f_hat and scatterPDF accounting for the BSDF>>                  f_hat = bsdf->f(wo, wi) * AbsDot(wi, intr.AsSurface().shading.n);
                 scatterPDF = bsdf->PDF(wo, wi);
          } else {
              <<Update f_hat and scatterPDF accounting for the phase function>>                  PhaseFunction phase = intr.AsMedium().phase;
                 f_hat = SampledSpectrum(phase.p(wo, wi));
                 scatterPDF = phase.PDF(wo, wi);
          }
          if (!f_hat) return SampledSpectrum(0.f);
       <<Declare path state variables for ray to light source>>           Ray lightRay = intr.SpawnRayTo(ls->pLight);
          SampledSpectrum T_ray(1.f), r_l(1.f), r_u(1.f);
          RNG rng(Hash(lightRay.o), Hash(lightRay.d));
       while (lightRay.d != Vector3f(0, 0, 0)) {
           <<Trace ray through media to estimate transmittance>>              pstd::optional<ShapeIntersection> si = Intersect(lightRay, 1-ShadowEpsilon);
              <<Handle opaque surface along ray's path>>                 if (si && si->intr.material)
                     return SampledSpectrum(0.f);
              <<Update transmittance for current ray segment>>                 if (lightRay.medium) {
                     Float tMax = si ? si->tHit : (1 - ShadowEpsilon);
                     Float u = rng.Uniform<Float>();
                     SampledSpectrum T_maj = SampleT_maj(lightRay, tMax, u, rng, lambda,
                             [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
                                 SampledSpectrum T_maj) {
                                 <<Update ray transmittance estimate at sampled point>>                                    <<Update T_ray and PDFs using ratio-tracking estimator>>                                       SampledSpectrum sigma_n = ClampZero(sigma_maj - mp.sigma_a - mp.sigma_s);
                                       Float pdf = T_maj[0] * sigma_maj[0];
                                       T_ray *= T_maj * sigma_n / pdf;
                                       r_l *= T_maj * sigma_maj / pdf;
                                       r_u *= T_maj * sigma_n / pdf;
                                    <<Possibly terminate transmittance computation using Russian roulette>>                                       SampledSpectrum Tr = T_ray / (r_l + r_u).Average();
                                       if (Tr.MaxComponentValue() < 0.05f) {
                                           Float q = 0.75f;
                                           if (rng.Uniform<Float>() < q)
                                               T_ray = SampledSpectrum(0.);
                                           else
                                               T_ray /= 1 - q;
                                       }
                                    return true;
                             });
                     <<Update transmittance estimate for final segment>>                        T_ray *= T_maj / T_maj[0];
                        r_l *= T_maj / T_maj[0];
                        r_u *= T_maj / T_maj[0];
                 }
              <<Generate next ray segment or return final transmittance>>                 if (!T_ray) return SampledSpectrum(0.f);
                 if (!si) break;
                 lightRay = si->intr.SpawnRayTo(ls->pLight);
       }
       <<Return path contribution function estimate for direct lighting>>           r_l *= r_p * lightPDF;
          r_u *= r_p * scatterPDF;
          if (IsDeltaLight(light.Type()))
              return beta * f_hat * T_ray * ls->L / r_l.Average();
          else
              return beta * f_hat * T_ray * ls->L / (r_l + r_u).Average();
}
```


#parec[
  The overall structure of this method's implementation is similar to the #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[PathIntegrator];'s `SampleLd()` method: a light source and a point on it are sampled, the vertex's scattering function is evaluated, and then the light's visibility is determined. Here we have the added complexity of needing to compute the transmittance between the scattering point and the point on the light rather than finding a binary visibility factor, as well as the need to compute spectral path sampling weights for MIS.
][
  该方法实现的整体结构类似于路径积分器 #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[PathIntegrator] 的 `SampleLd()` 方法：采样一个光源及其上的一个点，评估顶点的散射函数，然后确定光的可见性。这里增加了复杂性，需要计算散射点和光上的点之间的透射率，而不是找到一个二进制可见性因子，还需要计算用于多重重要性采样 (MIS) 的光谱路径采样权重。
]

```cpp
 <<Estimate light-sampled direct illumination at intr>>=
 <<Initialize LightSampleContext for volumetric light sampling>>   LightSampleContext ctx;
    if (bsdf) {
        ctx = LightSampleContext(intr.AsSurface());
        <<Try to nudge the light sampling position to correct side of the surface>>          BxDFFlags flags = bsdf->Flags();
           if (IsReflective(flags) && !IsTransmissive(flags))
               ctx.pi = intr.OffsetRayOrigin(intr.wo);
           else if (IsTransmissive(flags) && !IsReflective(flags))
               ctx.pi = intr.OffsetRayOrigin(-intr.wo);
    }
    else ctx = LightSampleContext(intr);
 <<Sample a light source using lightSampler>>   Float u = sampler.Get1D();
    pstd::optional<SampledLight> sampledLight = lightSampler.Sample(ctx, u);
    Point2f uLight = sampler.Get2D();
    if (!sampledLight)
        return SampledSpectrum(0.f);
    Light light = sampledLight->light;

 <<Sample a point on the light source>>   pstd::optional<LightLiSample> ls =
        light.SampleLi(ctx, uLight, lambda, true);
    if (!ls || !ls->L || ls->pdf == 0)
        return SampledSpectrum(0.f);
    Float lightPDF = sampledLight->p * ls->pdf;
 <<Evaluate BSDF or phase function for light sample direction>>   Float scatterPDF;
    SampledSpectrum f_hat;
    Vector3f wo = intr.wo, wi = ls->wi;
    if (bsdf) {
        <<Update f_hat and scatterPDF accounting for the BSDF>>          f_hat = bsdf->f(wo, wi) * AbsDot(wi, intr.AsSurface().shading.n);
        scatterPDF = bsdf->PDF(wo, wi);
    } else {
        <<Update f_hat and scatterPDF accounting for the phase function>>          PhaseFunction phase = intr.AsMedium().phase;
        f_hat = SampledSpectrum(phase.p(wo, wi));
        scatterPDF = phase.PDF(wo, wi);
    }
    if (!f_hat) return SampledSpectrum(0.f);
 <<Declare path state variables for ray to light source>>   Ray lightRay = intr.SpawnRayTo(ls->pLight);
    SampledSpectrum T_ray(1.f), r_l(1.f), r_u(1.f);
    RNG rng(Hash(lightRay.o), Hash(lightRay.d));
 while (lightRay.d != Vector3f(0, 0, 0)) {
    <<Trace ray through media to estimate transmittance>>       pstd::optional<ShapeIntersection> si = Intersect(lightRay, 1-ShadowEpsilon);
    <<Handle opaque surface along ray's path>>          if (si && si->intr.material)
        return SampledSpectrum(0.f);
    <<Update transmittance for current ray segment>>       if (lightRay.medium) {
        Float tMax = si ? si->tHit : (1 - ShadowEpsilon);
        Float u = rng.Uniform<Float>();
        SampledSpectrum T_maj = SampleT_maj(lightRay, tMax, u, rng, lambda,
                [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
                    SampledSpectrum T_maj) {
                    <<Update ray transmittance estimate at sampled point>>                      <<Update T_ray and PDFs using ratio-tracking estimator>>                        SampledSpectrum sigma_n = ClampZero(sigma_maj - mp.sigma_a - mp.sigma_s);
                    Float pdf = T_maj[0] * sigma_maj[0];
                    T_ray *= T_maj * sigma_n / pdf;
                    r_l *= T_maj * sigma_maj / pdf;
                    r_u *= T_maj * sigma_n / pdf;
                    <<Possibly terminate transmittance computation using Russian roulette>>                        SampledSpectrum Tr = T_ray / (r_l + r_u).Average();
                    if (Tr.MaxComponentValue() < 0.05f) {
                        Float q = 0.75f;
                        if (rng.Uniform<Float>() < q)
                            T_ray = SampledSpectrum(0.);
                        else
                            T_ray /= 1 - q;
                    }
                    return true;
            });
    <<Update transmittance estimate for final segment>>          T_ray *= T_maj / T_maj[0];
        r_l *= T_maj / T_maj[0];
        r_u *= T_maj / T_maj[0];
    }
    <<Generate next ray segment or return final transmittance>>       if (!T_ray) return SampledSpectrum(0.f);
    if (!si) break;
    lightRay = si->intr.SpawnRayTo(ls->pLight);
 }
 <<Return path contribution function estimate for direct lighting>>       r_l *= r_p * lightPDF;
    r_u *= r_p * scatterPDF;
    if (IsDeltaLight(light.Type()))
        return beta * f_hat * T_ray * ls->L / r_l.Average();
    else
        return beta * f_hat * T_ray * ls->L / (r_l + r_u).Average();
 }
```

#parec[
  Because it is called for both surface and volumetric scattering path vertices, `SampleLd()` takes a plain #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] to represent the scattering point. Some extra care is therefore needed when initializing the #link("../Light_Sources/Light_Interface.html#LightSampleContext")[`LightSampleContext`];: if scattering is from a surface, it is important to interpret that interaction as the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] that it is so that the shading normal is included in the #link("../Light_Sources/Light_Interface.html#LightSampleContext")[`LightSampleContext`];. This case also presents an opportunity, as was done in the #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`];, to shift the light sampling point to avoid incorrectly sampling self-illumination from area lights.
][
  由于它被调用用于表面和体积散射路径顶点，`SampleLd()` 采用一个普通的 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] 来表示散射点。因此，在初始化 #link("../Light_Sources/Light_Interface.html#LightSampleContext")[`LightSampleContext`] 时需要额外注意：如果散射来自表面，重要的是将该交互解释为 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];，以便在 #link("../Light_Sources/Light_Interface.html#LightSampleContext")[`LightSampleContext`] 中包含阴影法线。这个情况也提供了一个机会，如在路径积分器 #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`] 中所做的那样，通过移动光采样点来避免错误地从区域光中采样自发光。
]

```cpp
<<Initialize LightSampleContext for volumetric light sampling>>=
LightSampleContext ctx;
if (bsdf) {
    ctx = LightSampleContext(intr.AsSurface());
    <<Try to nudge the light sampling position to correct side of the surface>>       BxDFFlags flags = bsdf->Flags();
   if (IsReflective(flags) && !IsTransmissive(flags))
       ctx.pi = intr.OffsetRayOrigin(intr.wo);
   else if (IsTransmissive(flags) && !IsReflective(flags))
       ctx.pi = intr.OffsetRayOrigin(-intr.wo);
}
else ctx = LightSampleContext(intr);
```


#parec[
  Sampling a point on the light follows in the usual way. Note that the implementation is careful to consume the two sample dimensions from the `Sampler` regardless of whether sampling a light was successful, in order to keep the association of sampler dimensions with integration dimensions fixed across pixel samples.
][
  以通常的方式在光源上采样一个点。注意，实现时要小心地消耗 `Sampler` 的两个采样维度，无论是否成功采样光源，以便在像素样本之间保持采样器维度与积分维度的关联固定。
]

```cpp
<<Sample a light source using lightSampler>>=
Float u = sampler.Get1D();
pstd::optional<SampledLight> sampledLight = lightSampler.Sample(ctx, u);
Point2f uLight = sampler.Get2D();
if (!sampledLight)
    return SampledSpectrum(0.f);
Light light = sampledLight->light;
```


#parec[
  Sampling a point on the light follows in the usual way. Note that the implementation is careful to consume the two sample dimensions from the `Sampler` regardless of whether sampling a light was successful, in order to keep the association of sampler dimensions with integration dimensions fixed across pixel samples.
][
  在光源上采样一个点的过程与通常的方式相同。需要注意的是，无论是否成功采样到一个光源，实现都会谨慎地从 `Sampler` 中消费两个样本维度，以确保采样器的维度与像素样本的积分维度之间的关联保持一致。
]

```cpp
<<Sample a light source using lightSampler>>=
Float u = sampler.Get1D();
pstd::optional<SampledLight> sampledLight = lightSampler.Sample(ctx, u);
Point2f uLight = sampler.Get2D();
if (!sampledLight)
    return SampledSpectrum(0.f);
Light light = sampledLight->light;
```

#parec[
  The light samples a direction from the reference point in the usual manner. The `true` value passed for the `allowIncompletePDF` parameter of `Light::SampleLi()` indicates the use of MIS here.
][
  光源以通常的方式从参考点采样一个方向。在 `Light::SampleLi()` 中为 `allowIncompletePDF` 参数传递的 `true` 值，表明在此处使用了多重重要性采样（MIS）。
]

```cpp
<<Sample a point on the light source>>=
pstd::optional<LightLiSample> ls =
    light.SampleLi(ctx, uLight, lambda, true);
if (!ls || !ls->L || ls->pdf == 0)
    return SampledSpectrum(0.f);
Float lightPDF = sampledLight->p * ls->pdf;
```

#parec[
  As in `PathIntegrator::SampleLd()` , it is worthwhile to evaluate the BSDF or phase function before tracing the shadow ray: if it turns out to be zero-valued for the direction to the light source, then it is possible to exit early and perform no further work.
][
  正如在 `PathIntegrator::SampleLd()` 中那样，在追踪阴影光线之前，先评估 BSDF 或相函数是值得的：如果它对于指向光源的方向的值为零，则可以提早退出并避免进一步的计算。
]



```cpp
<<Evaluate BSDF or phase function for light sample direction>>=
Float scatterPDF;
SampledSpectrum f_hat;
Vector3f wo = intr.wo, wi = ls->wi;
if (bsdf) {
    <<Update f_hat and scatterPDF accounting for the BSDF>>       f_hat = bsdf->f(wo, wi) * AbsDot(wi, intr.AsSurface().shading.n);
       scatterPDF = bsdf->PDF(wo, wi);
} else {
    <<Update f_hat and scatterPDF accounting for the phase function>>       PhaseFunction phase = intr.AsMedium().phase;
       f_hat = SampledSpectrum(phase.p(wo, wi));
       scatterPDF = phase.PDF(wo, wi);
}
if (!f_hat) return SampledSpectrum(0.f);
```

#parec[
  The `f_hat` variable that holds the value of the scattering function is slightly misnamed: it also includes the cosine factor for scattering from surfaces and does not include the $sigma_s$ for scattering from participating media, as that has already been included in the provided value of `beta`.
][
  `f_hat` 变量用于存储散射函数的值，其命名稍显不准确：它不仅包含了表面散射的余弦因子，还不包括参与介质散射的 $sigma_s$，因为后者已经包含在提供的 `beta` 值中。
]



```cpp
<<Update f_hat and scatterPDF accounting for the BSDF>>=
f_hat = bsdf->f(wo, wi) * AbsDot(wi, intr.AsSurface().shading.n);
scatterPDF = bsdf->PDF(wo, wi);
```

```cpp
<<Update f_hat and scatterPDF accounting for the phase function>>=
PhaseFunction phase = intr.AsMedium().phase;
f_hat = SampledSpectrum(phase.p(wo, wi));
scatterPDF = phase.PDF(wo, wi);
```
#parec[
  A handful of variables keep track of some useful quantities for the ray-tracing and medium sampling operations that are performed to compute transmittance. `T_ray` holds the transmittance along the ray and `r_u` and `r_l` respectively hold the rescaled path probabilities for unidirectional sampling and light sampling, though only along the ray. Maintaining these values independently of the full path contribution and PDFs facilitates the use of Russian roulette in the transmittance computation.
][
  一些变量用于跟踪光线追踪和介质采样操作中的重要量，这些操作旨在计算透射率。`T_ray` 保存沿光线方向的透射率，`r_u` 和 `r_l` 分别保存单向采样和光源采样的重新缩放路径概率，但仅限于沿光线方向。将这些值独立于整个路径的贡献和概率密度函数（PDFs）维护，有助于在透射率计算中使用俄罗斯轮盘赌。
]


```cpp
<<Declare path state variables for ray to light source>>=
Ray lightRay = intr.SpawnRayTo(ls->pLight);
SampledSpectrum T_ray(1.f), r_l(1.f), r_u(1.f);
RNG rng(Hash(lightRay.o), Hash(lightRay.d));
```

#parec[
  `SampleLd()` successively intersects the shadow ray with the scene geometry, returning zero contribution if an opaque surface is found and otherwise sampling the medium to estimate the transmittance up to the intersection. For intersections that represent transitions between different media, this process repeats until the ray reaches the light source.
][
  `SampleLd()` 持续地将阴影光线与场景几何体相交。如果找到不透明表面，则返回零贡献；否则，将对介质进行采样以估计直到交点的透射率。对于表示不同介质之间过渡的交点，此过程会重复，直到光线到达光源。
]

#parec[
  For some scenes, it could be more efficient to instead first check that there are no intersections with opaque surfaces before sampling the media to compute the transmittance. With the current implementation, it is possible to do wasted work estimating transmittance before finding an opaque surface farther along the ray.
][
  在某些场景中，可能更高效的做法是先检查是否没有与不透明表面的交点，然后再采样介质以计算透射率。按照当前实现，在找到光线更远处的不透明表面之前，可能会在估计透射率上进行不必要的工作。
]

```cpp
<<Trace ray through media to estimate transmittance>>=
pstd::optional<ShapeIntersection> si = Intersect(lightRay, 1-ShadowEpsilon);
<<Handle opaque surface along ray’s path>>
<<Update transmittance for current ray segment>>
<<Generate next ray segment or return final transmittance>>
```


#parec[
  If an intersection is found with a surface that has a non-`nullptr` `Material` , the visibility term is zero and the method can return immediately.
][
  如果发现光线与具有非 `nullptr` 的 `Material` 的表面相交，则可见性项为零，方法可以立即返回。
]

```cpp
<<Handle opaque surface along ray's path>>=
if (si && si->intr.material)
    return SampledSpectrum(0.f);
```


#parec[
  Otherwise, if participating media is present, `SampleT_maj()` is called to sample it along the ray up to whichever is closer—the surface intersection or the sampled point on the light.
][
  否则，如果存在参与介质，则会调用 `SampleT_maj()` 来对沿光线的介质进行采样，直至较近者为止——表面交点或光源上的采样点。
]


```cpp
<<Update transmittance for current ray segment>>=
if (lightRay.medium) {
    Float tMax = si ? si->tHit : (1 - ShadowEpsilon);
    Float u = rng.Uniform<Float>();
    SampledSpectrum T_maj = SampleT_maj(lightRay, tMax, u, rng, lambda,
            [&](Point3f p, MediumProperties mp, SampledSpectrum sigma_maj,
                SampledSpectrum T_maj) {
                <<Update ray transmittance estimate at sampled point>>
            });
    <<Update transmittance estimate for final segment>>
}
```

#parec[
  For each sampled point in the medium, the transmittance and rescaled path probabilities are updated before Russian roulette is considered.
][
  For each sampled point in the medium, the transmittance and rescaled path probabilities are updated before Russian roulette is considered.
]


```cpp
<<Update ray transmittance estimate at sampled point>>=
<<Update T_ray and PDFs using ratio-tracking estimator>>
<<Possibly terminate transmittance computation using Russian roulette>>
return true;
```

#parec[
  In the context of the equation of transfer, using ratio tracking to compute transmittance can be seen as sampling distances along the ray according to the majorant transmittance and then only including the null-scattering component of the source function $L_n$ to correct any underestimate of transmittance from $T_"maj"$. Because only null-scattering vertices are sampled along transmittance rays, the logic for updating the transmittance and rescaled path probabilities at each vertex exactly follows that in the `<<Handle null scattering along ray path>>` fragment.
][
  在辐射传输方程的背景下，使用比例跟踪（ratio tracking）计算透射率可以看作是沿着光线根据主导透射率（majorant transmittance）采样距离，并且仅包括源函数 $L_n$ 的零散射（null-scattering）分量，以校正 $T_"maj"$ 可能低估的透射率。由于沿透射光线仅采样零散射顶点，更新每个顶点的透射率和重新缩放路径概率的逻辑完全遵循 `<<Handle null scattering along ray path>>` 片段中的内容。
]


```cpp
<<Update T_ray and PDFs using ratio-tracking estimator>>=
SampledSpectrum sigma_n = ClampZero(sigma_maj - mp.sigma_a - mp.sigma_s);
Float pdf = T_maj[0] * sigma_maj[0];
T_ray *= T_maj * sigma_n / pdf;
r_l *= T_maj * sigma_maj / pdf;
r_u *= T_maj * sigma_n / pdf;
```


#parec[
  Russian roulette is used to randomly terminate rays with low transmittance. A natural choice might seem to be setting the survival probability equal to the transmittance—along the lines of how Russian roulette is used for terminating ray paths from the camera according to $beta$. However, doing so would effectively transform ratio tracking to delta tracking, with the transmittance always equal to zero or one. The implementation therefore applies a less aggressive termination probability, only to highly attenuated rays.
][
  俄罗斯轮盘赌用于随机终止透射率较低的光线。一种自然的选择似乎是将生存概率设置为透射率——类似于如何根据 $beta$ 终止来自相机的光线路径。然而，这样做实际上会将比例跟踪转化为 δ 跟踪，使得透射率总是等于零或一。因此，实现采用了较不激进的终止概率，仅适用于高度衰减的光线。
]

#parec[
  In the computation of the transmittance value used for the Russian roulette test, note that an MIS weight that accounts for both the unidirectional and light sampling strategies is used, along the lines of @eqt:volpath-wu-from-rescaled-probabilities .
][
  在计算用于俄罗斯轮盘赌测试的透射率值时，注意到使用了一个多重重要性采样（MIS）权重，它同时考虑了单向采样和光源采样策略，与@eqt:volpath-wu-from-rescaled-probabilities 的思路类似。
]


```cpp
<<Possibly terminate transmittance computation using Russian roulette>>=
SampledSpectrum Tr = T_ray / (r_l + r_u).Average();
if (Tr.MaxComponentValue() < 0.05f) {
    Float q = 0.75f;
    if (rng.Uniform<Float>() < q)
        T_ray = SampledSpectrum(0.);
    else
        T_ray /= 1 - q;
}
```

#parec[
  After the `SampleT_maj()` call returns, the transmittance and rescaled path probabilities all must be multiplied by the `T_maj` returned from `SampleT_maj()` for the final ray segment. (See the discussion for the earlier `<<Handle terminated, scattered, and unscattered medium rays>>` fragment for why each is updated as it is.)
][
  在 `SampleT_maj()` 调用返回后，透射率和重新缩放的路径概率必须乘以 `SampleT_maj()` 为最终光线段返回的 `T_maj`。（有关为什么以这种方式更新的原因，请参阅前面的 `<<Handle terminated, scattered, and unscattered medium rays>>` 片段的讨论。）
]


```cpp
<<Update transmittance estimate for final segment>>=
T_ray *= T_maj / T_maj[0];
r_l *= T_maj / T_maj[0];
r_u *= T_maj / T_maj[0];
```

#parec[
  If the transmittance is zero (e.g., due to Russian roulette termination), it is possible to return immediately. Furthermore, if there is no surface intersection, then there is no further medium sampling to be done and we can move on to computing the scattered radiance from the light. Alternatively, if there is an intersection, it must be with a surface that represents the boundary between two media; the `SpawnRayTo()` method call returns the continuation ray on the other side of the surface, with its `medium` member variable set appropriately.
][
  如果透射率为零（例如由于俄罗斯轮盘赌终止），可以立即返回。此外，如果没有表面交点，则无需进一步的介质采样，可以继续计算光源的散射辐射。另一方面，如果存在交点，则交点必须是两个介质之间的边界；`SpawnRayTo()` 方法调用返回表面另一侧的继续光线，并适当地设置其 `medium` 成员变量。
]

```cpp
<<Generate next ray segment or return final transmittance>>=
if (!T_ray) return SampledSpectrum(0.f);
if (!si) break;
lightRay = si->intr.SpawnRayTo(ls->pLight);
```

#parec[
  After the `while` loop terminates, we can compute the final rescaled path probabilities, compute MIS weights, and return the final estimate of the path contribution function for the light sample.
][
  在 `while` 循环终止后，可以计算最终的重新缩放路径概率、MIS 权重，并返回光源采样路径贡献函数的最终估计。
]

#parec[
  The `r_p` variable passed in to `SampleLd()` stores the rescaled path probabilities for unidirectional sampling of the path up to the vertex where direct lighting is being computed—though here, `r_u` and `r_l` have been rescaled using the light path sampling probability, since that is how the vertices were sampled along the shadow ray. However, recall from @eqt:volpath-unidir-path-probability and @eqt:volpath-light-path-probability that $p_(u,lambda_1) (overline(p)_n) = p_(l,lambda_1) (overline(p)_n)$ for the path up to the scattering vertex. Thus, `r_p` can be interpreted as being rescaled using $1 \/ p_(l,lambda_1)$. This allows multiplying `r_l` and `r_u` by `r_p` to compute final rescaled path probabilities.
][
  传递给 `SampleLd()` 的 `r_p` 变量存储了单向采样路径的重新缩放路径概率，直到计算直接光照的顶点——不过在这里，`r_u` 和 `r_l` 已根据光路径采样概率重新缩放，因为这就是沿着阴影光线采样顶点的方式。然而，根据 @eqt:volpath-unidir-path-probability 和 @eqt:volpath-light-path-probability，路径到散射顶点的 $p_(u,lambda_1) (overline(p)_n) = p_(l,lambda_1) (overline(p)_n)$。因此，`r_p` 可以被解释为使用 $1 \/ p_(l,lambda_1)$ 重新缩放。这允许将 `r_l` 和 `r_u` 乘以 `r_p` 以计算最终的重新缩放路径概率。
]

#parec[
  If the light source is described by a delta distribution, only the light sampling technique is applicable; there is no chance of intersecting such a light via sampling the BSDF or phase function. In that case, we still apply MIS using all the wavelengths' individual path PDFs in order to reduce variance in chromatic media.
][
  如果光源由一个 δ 分布描述，则仅光源采样技术适用；通过采样 BSDF 或相函数没有可能与这种光源相交。在这种情况下，我们仍然对所有波长的单个路径 PDF 应用 MIS，以减少在色散介质中的方差。
]

#parec[
  For area lights, we are able to use both light source and the scattering function samples, giving two primary sampling strategies, each of which has a separate weight for each wavelength.
][
  对于面积光源，我们能够同时使用光源和散射函数的样本，从而提供两种主要采样策略，每种策略在每个波长上都有单独的权重。
]


```cpp
<<Return path contribution function estimate for direct lighting>>=
r_l *= r_p * lightPDF;
r_u *= r_p * scatterPDF;
if (IsDeltaLight(light.Type()))
    return beta * f_hat * T_ray * ls->L / r_l.Average();
else
    return beta * f_hat * T_ray * ls->L / (r_l + r_u).Average();
```

#parec[
  With `SampleLd()` implemented, we will return to the fragments in the `Li()` method that handle the cases where a ray escapes from the scene and possibly finds illumination from infinite area lights, as well as where a ray intersects an emissive surface. These handle the first term in the direct lighting MIS estimator, @eqt:volpath-two-sample-mis-estimator.
][
  实现了 `SampleLd()` 后，我们将回到 `Li()` 方法中的片段，这些片段处理光线从场景中逸出的情况，可能找到来自无限面积光源的照明，以及光线与发光表面相交的情况。这些片段处理直接光照 MIS 估计器的第一项，即@eqt:volpath-two-sample-mis-estimator。
]


```cpp
<<Add emitted light at volume path vertex or from the environment>>=
if (!si) {
    <<Accumulate contributions from infinite light sources>>
    break;
}
SurfaceInteraction &isect = si->intr;
if (SampledSpectrum Le = isect.Le(-ray.d, lambda); Le) {
    <<Add contribution of emission from intersected surface>>
}
```

#parec[
  As with the `PathIntegrator`, if the previous scattering event was due to a delta-distribution scattering function, then sampling the light is not a useful strategy. In that case, the MIS weight is only based on the per-wavelength PDFs for the unidirectional sampling strategy.
][
  与 `PathIntegrator` 一样，如果前一次散射事件是由于 δ 分布散射函数导致的，那么采样光源就不是一种有效的策略。在这种情况下，多重重要性采样（MIS）权重仅基于单向采样策略的每波长 PDF。
]


```cpp
<<Accumulate contributions from infinite light sources>>=
for (const auto &light : infiniteLights) {
    if (SampledSpectrum Le = light.Le(ray, lambda); Le) {
        if (depth == 0 || specularBounce)
            L += beta * Le / r_u.Average();
        else {
            <<Add infinite light contribution using both PDFs with MIS>>               Float lightPDF = lightSampler.PMF(prevIntrContext, light) *
                                light.PDF_Li(prevIntrContext, ray.d, true);
               r_l *= lightPDF;
               L += beta * Le / (r_u + r_l).Average();
        }
    }
}
```
#parec[
  Otherwise, the MIS weight should account for both sampling techniques. At this point, `r_l` has everything but the probabilities for sampling the light itself. (Recall that we deferred that when initializing `r_l` at the real-scattering vertex earlier.) After incorporating that factor, all that is left is to compute the final weight, accounting for both sampling strategies.
][
  否则，MIS 权重应考虑两种采样技术。此时，`r_l` 已包含除采样光源本身概率以外的所有内容。（回忆一下，我们在之前的真实散射顶点初始化 `r_l` 时推迟了这一部分。）在结合这一因素后，只需计算最终的权重，涵盖两种采样策略即可。
]
```cpp
<<Add infinite light contribution using both PDFs with MIS>>=
Float lightPDF = lightSampler.PMF(prevIntrContext, light) *
                 light.PDF_Li(prevIntrContext, ray.d, true);
r_l *= lightPDF;
L += beta * Le / (r_u + r_l).Average();
```
#parec[
  The work done in the `<<Add contribution of emission from intersected surface>>` fragment is very similar to that done for infinite lights, so it is not included here.
][
  在 `<<Add contribution of emission from intersected surface>>` 片段中完成的工作与无限光源的处理非常相似，因此这里未包含。
]
