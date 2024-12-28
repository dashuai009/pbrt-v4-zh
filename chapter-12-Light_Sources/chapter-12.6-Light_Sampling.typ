#import "../template.typ": parec, ez_caption

== Light Sampling
<light-sampling>
#parec[
  Due to the linearity assumption in radiometry, illumination at a point in a scene with multiple light sources can be computed by summing the independent contributions of each light. As we have seen before, however, correctness alone is not always sufficient—if it were, we might have sampled `ImageInfiniteLight`s uniformly with the suggestion that one take thousands of samples per pixel until error has been reduced sufficiently. Especially in scenes with thousands or more independent light sources, considering all of them carries too much of a performance cost.
][
  由于辐射度学中的线性假设，场景中某一点的光照可以通过对每个光源的独立贡献进行求和来计算。然而，正如我们之前所见，仅仅追求正确性是不够的——如果仅仅如此，我们可能会建议对 `ImageInfiniteLight` 进行均匀采样，并建议每像素取数千个样本直到误差足够小。尤其是在具有成千上万个独立光源的场景中，考虑所有光源的性能成本过高。
]

#parec[
  Fortunately, here, too, is a setting where stochastic sampling can be applied. An unbiased estimator for a sum of terms $f_i$ is given by
][
  幸运的是，这里也是一个可以应用随机采样的场景。对于一组项 $f_i$ 的和，一个无偏估计器为
]
$ sum_i^n f_i approx frac(f_j, p (j)) , $ <mc-sampled-sum>

#parec[
  where the probability mass function (PMF) $p (j) > 0$ for any term where $f_j$ is nonzero and where $tilde(p)$. This is the discrete analog to the integral Monte Carlo estimator, @eqt:MC-estimator. Therefore, we can replace any sum over all the scene's light sources with a sum over just one or a few of them, where the contributions are weighted by one over the probability of sampling the ones selected.
][
  其中概率质量函数 (PMF) $p (j) > 0$ 适用于任何 $f_j$ 非零的项。这是积分蒙特卡罗估计器（@eqt:MC-estimator）的离散类比。因此，我们可以将场景中所有光源的和替换为其中一个或几个光源的和，其中的贡献按所选光源的采样概率的倒数加权。
]

#parec[
  @fig:many-lights-scene is a rendered image of a scene with 8,878 light sources. A few observations motivate some of the light sampling algorithms to come. At any given point in the scene, some lights are facing away and others are occluded. Ideally, such lights would be given a zero sampling probability. Furthermore, often many lights are both far away from a given point and have relatively low power; such lights should have a low probability of being sampled. (Consider, for example, the small yellow lights inset in the machinery.) Of course, even a small and dim light is important to points close to it. Therefore, the most effective light sampling probabilities will vary across the scene depending on position, surface normal, the BSDF, and so forth.
][
  @fig:many-lights-scene 展示了一个包含 8,878 个光源的场景的渲染图。几个观察结果激发了一些即将到来的光源采样算法。在场景中的任何给定点，一些光源可能背对着，而另一些可能被遮挡。理想情况下，这些光源的采样概率应为零。此外，通常许多光源距离给定点较远且功率相对较低；这些光源的采样概率应较低。（例如，考虑嵌入在机器中的小黄灯。）当然，即使是小而暗的光源对于靠近它的点也是重要的。因此，最有效的光源采样概率将根据位置、表面法线、BSDF（双向散射分布函数）等在整个场景中变化。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f23.svg"),
  caption: [
    #ez_caption[
      Zero Day Scene, with 8,878 Light Sources. It is infeasible to consider every light when computing reflected radiance at a point on a surface, and therefore light sampling methods from this section are necessary to render this scene efficiently. (Scene courtesy of Beeple.)
    ][
      《零日场景》，包含 8,878 个光源。在计算表面上某一点的反射辐射度时，考虑每个光源是不可行的，因此本节中的光源采样方法是高效渲染此场景所必需的。 （场景由 Beeple 提供。）
    ]
  ],
)<many-lights-scene>

#parec[
  The `LightSampler` class defines the `LightSampler` interface for sampling light sources. It is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/lightsampler.h")[base/lightsampler.h];. `LightSampler` implementations can be found in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.h")[lightsamplers.h] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.cpp")[lightsamplers.cpp];.
][
  `LightSampler` 类定义了用于采样光源的 `LightSampler` 接口。它在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/lightsampler.h")[base/lightsampler.h] 中定义。`LightSampler` 的实现可以在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.h")[lightsamplers.h] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lightsamplers.cpp")[lightsamplers.cpp] 中找到。
]

```cpp
class LightSampler : public TaggedPointer<UniformLightSampler, PowerLightSampler, BVHLightSampler> {
  public:
    using TaggedPointer::TaggedPointer;

    static LightSampler Create(const std::string &name, pstd::span<const Light> lights, Allocator alloc);

    std::string ToString() const;
    pstd::optional<SampledLight> Sample(const LightSampleContext &ctx, Float u) const;
    Float PMF(const LightSampleContext &ctx, Light light) const;
    pstd::optional<SampledLight> Sample(Float u) const;
    Float PMF(Light light) const;
};
```

#parec[
  The key `LightSampler` method is `Sample()`, which takes a uniform 1D sample and information about a reference point in the form of a `LightSampleContext`. When sampling is successful, a `SampledLight` is returned. Otherwise, the optional value is left unset, as may happen if the light sampler is able to determine that no lights illuminate the provided point.
][
  关键的 `LightSampler` 方法是 `Sample()`，它接受一个均匀的 1D 样本和一个参考点的信息，以 `LightSampleContext` 的形式。当采样成功时，返回一个 `SampledLight` 对象。否则，如果光源采样器能够确定没有光源照亮提供的点，则可选值保持未设置。
]


```
pstd::optional<SampledLight> Sample(const LightSampleContext &ctx, Float u) const;
```

#parec[
  `SampledLight` just wraps up a light and the discrete probability for it having been sampled.
][
  `SampledLight` 只是包装了一个光源及其被采样的离散概率。
]

```
struct SampledLight {
    Light light;
    Float p = 0;
};
```

#parec[
  In order to compute the MIS weighting term when a ray happens to hit a light source, it is necessary to be able to find the value of the probability mass function for sampling a particular light. This task is handled by `PMF()` method implementations.
][
  为了在光线碰到光源时计算 MIS（多重重要性采样）加权项，必须能够找到采样特定光源的概率质量函数的值。这个任务由 `PMF()` 方法实现来处理。
]

```
Float PMF(const LightSampleContext &ctx, Light light) const;
```

#parec[
  `LightSampler`s must also provide methods to sample a light and return the corresponding probability independent of a specific point being illuminated. These methods are useful for light transport algorithms like bidirectional path tracing that start paths at the light sources.
][
  `LightSampler` 还必须提供方法来采样光源并返回与特定被照亮点无关的相应概率。这些方法对于从光源开始路径的光传输算法（例如双向路径追踪）非常有用。
]

```
pstd::optional<SampledLight> Sample(Float u) const;
Float PMF(Light light) const;
```

=== Uniform Light Sampling
<uniform-light-sampling>
#parec[
  `UniformLightSampler` is the simplest possible light sampler: it samples all lights with uniform probability. In practice, more sophisticated sampling algorithms are usually much more effective, but this one is easy to implement and provides a useful baseline for comparing light sampling techniques.
][
  `UniformLightSampler` 是最简单的光源采样器：它以均匀概率采样所有光源。在实际中，更复杂的采样算法通常更有效，但这个算法易于实现，并为比较光源采样技术提供了一个有用的基线。
]


```cpp
class UniformLightSampler {
  public:
    UniformLightSampler(pstd::span<const Light> lights, Allocator alloc)
           : lights(lights.begin(), lights.end(), alloc) {}
       pstd::optional<SampledLight> Sample(Float u) const {
           if (lights.empty()) return {};
           int lightIndex = std::min<int>(u * lights.size(), lights.size() - 1);
           return SampledLight{lights[lightIndex], 1.f / lights.size()};
       }
       Float PMF(Light light) const {
           if (lights.empty()) return 0;
           return 1.f / lights.size();
       }
       PBRT_CPU_GPU
       pstd::optional<SampledLight> Sample(const LightSampleContext &ctx, Float u) const {
           return Sample(u);
       }
       PBRT_CPU_GPU
       Float PMF(const LightSampleContext &ctx, Light light) const { return PMF(light); }
       std::string ToString() const { return "UniformLightSampler"; }
  private:
    pstd::vector<Light> lights;
};
```

#parec[
  As with all light samplers, an array of all the lights in the scene is provided to the constructor; `UniformLightSampler` makes a copy of them in a member variable.
][
  与所有光源采样器一样，场景中所有光源的数组被提供给构造函数；`UniformLightSampler` 将它们复制到一个成员变量中。
]


```cpp
UniformLightSampler(pstd::span<const Light> lights, Allocator alloc)
    : lights(lights.begin(), lights.end(), alloc) {}
```

#parec[
  Since the light sampling probabilities do not depend on the lookup point, we will only include the variants of `Sample()` and `PMF()` that do not take a `LightSampleContext` here. The versions of these methods that do take a context just call these variants. For sampling, a light is chosen by scaling the provided uniform sample by the array size and returning the corresponding light.
][
  由于光源采样概率不依赖于查找点，我们这里只包括不带 `LightSampleContext` 的 `Sample()` 和 `PMF()` 变体。带有上下文的这些方法版本只是调用这些变体。对于采样，通过将提供的均匀样本按数组大小缩放并返回相应的光源来选择光源。
]


```
pstd::optional<SampledLight> Sample(Float u) const {
    if (lights.empty()) return {};
    int lightIndex = std::min<int>(u * lights.size(), lights.size() - 1);
    return SampledLight{lights[lightIndex], 1.f / lights.size()};
}
```

#parec[
  Given uniform sampling probabilities, the value of the PMF is always one over the number of lights.
][
  给定均匀采样概率，PMF 的值始终为光源数量的倒数。
]

```
Float PMF(Light light) const {
    if (lights.empty()) return 0;
    return 1.f / lights.size();
}
```


=== Power Light Sampler
<power-light-sampler>


#parec[
  `PowerLightSampler` sets the probability for sampling each light according to its power. Doing so generally gives better results than sampling uniformly, but the lack of spatial variation in sampling probabilities limits its effectiveness. (We will return to this topic at the end of this section where some comparisons between the two techniques are presented.)
][
  `PowerLightSampler` 根据每个光源的功率设置其采样概率。这样做通常比均匀采样能得到更好的结果，但由于采样概率在空间上的变化缺乏，限制了其有效性。（我们将在本节末尾回到这个主题，并展示两种技术之间的一些比较。）
]



```cpp
class PowerLightSampler {
  public:
    <<PowerLightSampler Public Methods>>       PowerLightSampler(pstd::span<const Light> lights, Allocator alloc);
       pstd::optional<SampledLight> Sample(Float u) const {
           if (!aliasTable.size()) return {};
           Float pmf;
           int lightIndex = aliasTable.Sample(u, &pmf);
           return SampledLight{lights[lightIndex], pmf};
       }
       Float PMF(Light light) const {
           if (!aliasTable.size()) return 0;
           return aliasTable.PMF(lightToIndex[light]);
       }
       PBRT_CPU_GPU
       pstd::optional<SampledLight> Sample(const LightSampleContext &ctx, Float u) const {
           return Sample(u);
       }
       PBRT_CPU_GPU
       Float PMF(const LightSampleContext &ctx, Light light) const { return PMF(light); }

       std::string ToString() const;
  private:
    <<PowerLightSampler Private Members>>       pstd::vector<Light> lights;
       HashMap<Light, size_t> lightToIndex;
       AliasTable aliasTable;
};
```



#parec[
  Its constructor also makes a copy of the provided lights but initializes some additional data structures as well.
][
  其构造函数还会复制提供的光源，并初始化一些额外的数据结构。
]

```cpp
PowerLightSampler::PowerLightSampler(pstd::span<const Light> lights,
                                     Allocator alloc)
    : lights(lights.begin(), lights.end(), alloc), lightToIndex(alloc),
      aliasTable(alloc) {
    if (lights.empty()) return;
    // <<Initialize lightToIndex hash table>>
    for (size_t i = 0; i < lights.size(); ++i)
           lightToIndex.Insert(lights[i], i);
    // <<Compute lights' power and initialize alias table>>
    pstd::vector<Float> lightPower;
       SampledWavelengths lambda = SampledWavelengths::SampleVisible(0.5f);
       for (const auto &light : lights) {
           SampledSpectrum phi = SafeDiv(light.Phi(lambda), lambda.PDF());
           lightPower.push_back(phi.Average());
       }
       aliasTable = AliasTable(lightPower, alloc);
}

<<PowerLightSampler Private Members>>=
pstd::vector<Light> lights;
```



#parec[
  To efficiently return the value of the PMF for a given light, it is necessary to be able to find the index in the `lights` array of a given light. Therefore, the constructor also initializes a hash table that maps from #link("../Light_Sources/Light_Interface.html#Light")[Light];s to indices.
][
  为了高效地返回给定光源的 PMF 值，必须能够在 `lights` 数组中找到给定光源的索引。因此，构造函数还初始化了一个从 #link("../Light_Sources/Light_Interface.html#Light")[Light] 到索引的哈希表。
]



```cpp
<<Initialize lightToIndex hash table>>=
for (size_t i = 0; i < lights.size(); ++i)
    lightToIndex.Insert(lights[i], i);

<<PowerLightSampler Private Members>>+=
HashMap<Light, size_t> lightToIndex;
```

#parec[
  The `PowerLightSampler` uses an #link("../Sampling_Algorithms/The_Alias_Method.html#AliasTable")[AliasTable] for sampling. It is initialized here with weights based on the emitted power returned by each light's `Phi()` method. Note that if the light's emission distribution is spiky (e.g., as with many fluorescent lights), there is a risk of underestimating its power if a spike is missed. We have not found this to be a problem in practice, however.
][
  `PowerLightSampler` 使用 #link("../Sampling_Algorithms/The_Alias_Method.html#AliasTable")[AliasTable] 进行采样。它在此处用每个光源的 `Phi()` 方法返回的发射功率的权重进行初始化。注意，如果光源的发射分布是尖峰状的（例如，许多荧光灯），如果错过了一个尖峰，则可能低估其功率。然而，我们在实践中没有发现这是一个问题。
]



```cpp
pstd::vector<Float> lightPower;
SampledWavelengths lambda = SampledWavelengths::SampleVisible(0.5f);
for (const auto &light : lights) {
    SampledSpectrum phi = SafeDiv(light.Phi(lambda), lambda.PDF());
    lightPower.push_back(phi.Average());
}
aliasTable = AliasTable(lightPower, alloc);
```


#parec[
  Given the alias table, sampling is easy.
][
  给定别名表，采样很简单。
]


```cpp
pstd::optional<SampledLight> Sample(Float u) const {
    if (!aliasTable.size()) return {};
    Float pmf;
    int lightIndex = aliasTable.Sample(u, &pmf);
    return SampledLight{lights[lightIndex], pmf};
}
```

#parec[
  To evaluate the PMF, the hash table gives the mapping to an index in the array of lights. In turn, the PMF returned by the alias table for the corresponding entry is the probability of sampling the light.
][
  为了评估 PMF，哈希表提供了到光源数组中索引的映射。反过来，别名表为相应条目返回的 PMF 是采样该光源的概率。
]


```cpp
Float PMF(Light light) const {
    if (!aliasTable.size()) return 0;
    return aliasTable.PMF(lightToIndex[light]);
}
```

#parec[
  As with the `UniformLightSampler`, the `Sample()` and `PMF()` methods that do take a #link("../Light_Sources/Light_Interface.html#LightSampleContext")[LightSampleContext] just call the corresponding methods that do not take one.
][
  与 `UniformLightSampler` 一样，接受 #link("../Light_Sources/Light_Interface.html#LightSampleContext")[LightSampleContext] 的 `Sample()` 和 `PMF()` 方法只是调用不接受该参数的相应方法。
]

#parec[
  Sampling lights based on their power usually works well. @fig:sample-lights-uniform-vs-power compares both sampling methods using the #emph[Zero Day] scene. For this scene, noise is visibly reduced when sampling according to power, and mean squared error (MSE) is improved by a factor of 12.4.
][
  基于功率采样光源通常效果很好。图 12.24 使用 #emph[Zero Day] 场景比较了两种采样方法。对于这个场景，根据功率采样时噪声明显减少，均方误差（MSE）提高了 12.4 倍。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f24.svg"),
  caption: [
    #ez_caption[
      Sampling Lights Uniformly versus by Emitted Power with
      the #emph[Zero Day] Scene. (a) Rendered with uniform light sampling.
      (b) Rendered with lights sampled according to power. Both images are
      rendered with 16 samples per pixel and rendering time is nearly the
      same. Sampling lights according to power reduces MSE by a factor of
      12.4 for this scene. (Scene courtesy of Beeple.)
    ][
      在 #emph[Zero Day] 场景中，均匀采样与按发射功率采样光源的对比。(a) 使用均匀光采样渲染。(b) 根据功率采样光源渲染。两幅图像均以每像素 16 个样本渲染，渲染时间几乎相同。根据功率采样光源使该场景的 MSE 减少了 12.4 倍。（场景由 Beeple 提供。）

    ]
  ],
)<sample-lights-uniform-vs-power>


#parec[
  Although sampling according to power generally works well, it is not optimal. Like uniform sampling, it is hindered by not taking the geometry of emitters and the relationship between emitters and the receiving point into account. Relatively dim light sources may make the greatest visual contribution in a scene, especially if the bright ones are far away, mostly occluded, or not visible at all.
][
  尽管根据功率采样通常效果很好，但它并不是最优的。与均匀采样一样，它受到没有考虑发射器的几何形状和发射器与接收点之间关系的阻碍。在场景中，相对较暗的光源可能会产生最大的视觉贡献，尤其是当明亮的光源距离较远、主要被遮挡或根本不可见时。
]

#parec[
  As an extreme example of this problem with sampling according to power, consider a large triangular light source that emits a small amount of radiance. The triangle's emitted power can be made arbitrarily large by scaling it to increase its total area. However, at any point in the scene, the triangle can do no more than subtend a hemisphere, which limits its effect on the total incident radiance at a point. Sampling by power can devote far too many samples to such lights.
][
  作为根据功率采样问题的一个极端例子，考虑一个发射少量辐射的大型三角形光源。通过缩放以增加其总面积，可以使三角形的发射功率任意大。然而，在场景中的任何一点，三角形最多只能覆盖一个半球，这限制了它对某一点总入射辐射的影响。按功率采样可能会为这样的光源分配过多的样本。
]


=== BVH Light Sampling
<bvh-light-sampling>


#parec[
  Varying the light sampling probabilities based on the point being shaded can be an effective light sampling strategy, though if there are more than a handful of lights, some sort of data structure is necessary to do this without having to consider every light at each point being shaded. One widely used approach is to construct a hierarchy over the light sources with the effect of multiple lights aggregated into the higher nodes of the hierarchy. This representation makes it possible to traverse the hierarchy to find the important lights near a given point.
][
  根据被着色点的不同调整光采样概率是一种有效的策略，不过如果光源数量超过少数几个，就需要某种数据结构来避免在每个被着色点都考虑每个光源。 一种广泛使用的方法是对光源构建一个层次结构，将多个光源的效果聚合到层次结构的更高节点中。这种表示方式使得可以遍历层次结构以找到给定点附近的重要光源。
]

#parec[
  Given a good light hierarchy, it is possible to render scenes with hundreds of thousands or even millions of light sources nearly as efficiently as a scene with just one light. In this section, we will describe the implementation of the `BVHLightSampler`, which applies bounding volume hierarchies to this task.
][
  给定一个良好的光层次结构，可以几乎同样高效地渲染具有数十万甚至数百万光源的场景。 在本节中，我们将描述 `BVHLightSampler` 的实现，它将包围体层次结构应用于此任务。
]

==== Bounding Lights
<bounding-lights>

#parec[
  When bounding volume hierarchies (BVHs) were used for intersection acceleration structures in @bounding-volume-hierarchies, it was necessary to abstract away the details of the various types of primitives and underlying shapes that they stored so that the `BVHAggregate` did not have to be explicitly aware of each of them. There, the primitives' rendering-space bounding boxes were used for building the hierarchy. Although there were cases where the quality of the acceleration structure might have been improved using shape-specific information (e.g., if the acceleration structure was aware of skinny diagonal triangles with large bounding boxes with respect to the triangle's area), the `BVHAggregate`'s implementation was substantially simplified with that approach.
][
  在@bounding-volume-hierarchies 中，包围体层次结构（BVHs）用于加速结构的相交操作时，需要抽象掉它们存储的各种类型的图元和底层形状的细节，以便 `BVHAggregate` 不必显式地了解每一个。 在那里，使用图元的渲染空间包围盒来构建层次结构。尽管在某些情况下，使用特定形状的信息可能显著提高加速结构的质量（例如，如果加速结构知道相对于三角形面积具有大包围盒的细长对角三角形），但这种方法大大简化了 `BVHAggregate` 的实现。
]

#parec[
  We would like to have a similar decoupling for the `BVHLightSampler`, though it is less obvious what the right abstraction should be. For example, we might want to know that a spotlight only emits light in a particular cone, so that the sampler does not choose it for points outside the cone. Similarly, we might want to know that a one-sided area light only shines light on one side of a particular plane. For all sorts of lights, knowing their total power would be helpful so that brighter lights can be sampled preferentially to dimmer ones. Of course, power does not tell the whole story, as the light's spatial extent and relationship to a receiving point affect how much power is potentially received at that point.
][
  我们希望对 `BVHLightSampler` 进行类似的抽象，尽管不太明显应该是什么样的抽象。 例如，我们可能想知道聚光灯只在特定锥体内发光，以便采样器不会选择锥体外的点。 同样，我们可能想知道单面区域光只在特定平面的一侧发光。 对于各种光源，知道它们的总功率会很有帮助，以便可以优先采样更亮的光源。 当然，功率并不能完全反映光源的影响，因为光源的空间范围及其与接收点的关系会影响在该点可能接收到的功率。
]

#parec[
  The `LightBounds` structure provides the abstraction used by `pbrt` for these purposes. It stores a variety of values that make it possible to represent the emission distribution of a variety of types of light.
][
  `LightBounds` 结构提供了 `pbrt` 用于这些目的的抽象。 它存储了多种值，使得可以表示各种类型光源的发射分布。
]

```cpp
<<LightBounds Definition>>=
class LightBounds {
public:
    <<LightBounds Public Methods>>
    <<LightBounds Public Members>>
};
```


#parec[
  It is evident that the spatial bounds of the light and its emitted power will be useful quantities, so those are included in `LightBounds`. However, this representation excludes light sources at infinity such as the `DistantLight` and the various infinite lights. That limitation is fine, however, since it is unclear how such light sources would be stored in a BVH anyway. (The `BVHLightSampler` therefore handles these types of lights separately.)
][
  显然，光源的空间边界和其发射功率是有用的量，因此它们被包含在 `LightBounds` 中。然而，这种表示方法排除了诸如 `DistantLight` 和各种无限光源的光源。这种限制是可以接受的，因为无论如何，如何在 BVH 中存储这些光源尚不清楚。（因此，`BVHLightSampler` 会单独处理这些类型的光源。）
]

```cpp
<<LightBounds Public Members>>=
Bounds3f bounds;
Float phi = 0;
```


#parec[
  As suggested earlier, bounding a light's directional emission distribution is important for sampling lights effectively. The representation used here is based on a unit vector $omega$ that specifies a principal direction for the emitter's surface normal and two angles that specify its variation. First, $theta_o$ specifies the maximum deviation of the emitter's surface normal from the principal normal direction $omega$. Second, $theta_e$ specifies the angle beyond $theta_o$ up to which there may be emission (@fig:light-potential-emission-directions). Thus, directions that make an angle up to $theta_o + theta_e$ with $omega$ may receive illumination from a light and those that make a greater angle certainly do not.
][
  如前所述，界定光源的方向性发射分布对于有效采样光源非常重要。这里使用的表示方法基于一个单位向量 $omega$，它指定了发射体表面法线的主方向，以及两个角度，分别指定其变化范围。首先， $theta_o$ 指定了发射体表面法线相对于主法线方向 $omega$ 的最大偏差。其次， $theta_e$ 指定了超过 $theta_o$ 的角度范围，在该范围内可能存在发射(@fig:light-potential-emission-directions)。因此，所有与 $omega$ 形成不超过 $theta_o + theta_e$ 角度的方向可能会受到光源的照射，而形成更大角度的方向则肯定不会。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f25.svg"),
  caption: [
    #ez_caption[
      Specification of Potential Emission Directions for a Light. Lights specify a principal direction of their distribution of surface normals $omega$ as well as two angles, $theta_o$ and $theta_e$. The first angle bounds the variation in surface normals from $omega$ and the second gives the additional angle beyond which emission is possible.
    ][
      光源的潜在发射方向的指定。光源指定其表面法线分布的主方向 $omega$，以及两个角度，$theta_o$ 和 $theta_e$。第一个角度界定了表面法线从 $omega$ 的变化范围，第二个角度则指定了超出该角度的发射可能性。
    ]
  ],
)<light-potential-emission-directions>


#parec[
  While this representation may seem overly specialized for emissive shapes alone, it works well for all of `pbrt`'s (noninfinite) light types. For example, a point light can be represented with an arbitrary average normal $omega$ and an angle of $pi$ for $theta_o$. A spotlight can use the direction it is facing for $omega$, its central cone angle for $theta_o$, and the angular width of its falloff region for $theta_e$.
][
  虽然这种表示方法似乎过于专门化，仅适用于发射形状，但它对于 `pbrt` 的所有（非无限）光源类型都有效。例如，一个点光源可以用任意的平均法线 $omega$ 和角度 $pi$ 的 $theta_o$ 来表示。一个聚光灯可以使用其朝向的方向作为 $omega$，用其中心锥角度表示 $theta_o$，并用其衰减区域的角宽度表示 $theta_e$。
]

#parec[
  Our implementation stores the cosine of these angles rather than the angles themselves; this representation will make it possible to avoid the expense of evaluating a number of trigonometric functions in the following.
][
  我们的实现存储这些角度的余弦值，而不是角度本身；这种表示方法使得在后续过程中可以避免计算许多三角函数的开销。
]

```cpp
<<LightBounds Public Members>>+=
Vector3f w;
Float cosTheta_o, cosTheta_e;
```


#parec[
  The last part of the emission bounds for a light is a `twoSided` flag, which indicates whether the direction $omega$ should be negated to specify a second cone that uses the same pair of angles.
][
  光源发射范围的最后一部分是一个 `twoSided` 标志，它表示是否应否定方向 $omega$，以指定使用相同角度对的第二个锥体。
]

```cpp
<<LightBounds Public Members>>+=
bool twoSided;
```


#parec[
  The `LightBounds` constructor takes corresponding parameters and initializes the member variables. The implementation is straightforward, and so is not included here.
][
  `LightBounds` 构造函数接受相应的参数并初始化成员变量。实现是直接的，因此这里不再包含。
]


```cpp
<<LightBounds Public Methods>>=
LightBounds(const Bounds3f &b, Vector3f w, Float phi, Float cosTheta_o,
            Float cosTheta_e, bool twoSided);
```


#parec[
  To cluster lights into a hierarchy, we will need to be able to find the bounds that encompass two specified `LightBounds` objects. This capability is provided by the `Union()` function.
][
  为了将光源聚集到一个层次结构中，我们需要能够找到包含两个指定的 `LightBounds` 对象的边界。这个功能由 `Union()` 函数提供。
]

```cpp
<<LightBounds Inline Methods>>=
LightBounds Union(const LightBounds &a, const LightBounds &b) {
    <<If one LightBounds has zero power, return the other>>
    <<Find average direction and updated angles for LightBounds>>
    <<Return final LightBounds union>>
}
```

#parec[
  It is worthwhile to start out by checking for the easy case of one or the other specified `LightBounds` having zero power. In this case, the other can be returned immediately.

  ```cpp
  if (a.phi == 0) return b;
  if (b.phi == 0) return a;
  ```

  Otherwise, a new average normal direction and updated angles $theta_o$ and $theta_e$ must be computed. Most of the work involved is handled by the `DirectionCone`'s `Union()` method, which takes a pair of cones of directions and returns one that bounds the two of them. The cosine of the new angle $theta_o$ is then given by the cosine of the spread angle of that cone.

  The value of $theta_e$ should be the maximum of the $theta_e$ values for the two cones. However, because `LightBounds` stores the cosines of the angles and because the cosine function is monotonically decreasing over the range of possible $theta$ values, $[0, pi]$, we take the minimum cosine of the two angles.

  ```cpp
  DirectionCone cone = Union(DirectionCone(a.w, a.cosTheta_o),
                             DirectionCone(b.w, b.cosTheta_o));
  Float cosTheta_o = cone.cosTheta;
  Float cosTheta_e = std::min(a.cosTheta_e, b.cosTheta_e);
  ```

  The remainder of the parameter values for the `LightBounds` constructor are easily computed from the two `LightBounds` that were provided.

  ```cpp
  return LightBounds(Union(a.bounds, b.bounds), cone.w, a.phi + b.phi,
                     cosTheta_o, cosTheta_e, a.twoSided | b.twoSided);
  ```

  A utility method returns the centroid of the spatial bounds; this value will be handy when building the light BVH.

  ```cpp
  Point3f Centroid() const { return (bounds.pMin + bounds.pMax) / 2; }
  ```

  The `Importance()` method provides the key `LightBounds` functionality: it returns a scalar value that estimates the contribution of the light or lights represented in the `LightBounds` at a given point. If the provided normal is nondegenerate, it is assumed to be the surface normal at the receiving point. Scattering points in participating media pass a zero-valued `Normal3f`.
][
  值得先检查一下一个简单的情况，即指定的 `LightBounds` 中有一个光源的功率为零。在这种情况下，可以立即返回另一个光源。

  ```cpp
  if (a.phi == 0) return b;
  if (b.phi == 0) return a;
  ```

  否则，需要计算新的平均法线方向和更新的角度 $theta_o$ 和 $theta_e$。大部分工作由 `DirectionCone` 的 `Union()` 方法处理，该方法接受一对方向锥并返回一个包含这两个锥的新的锥体。然后，新的角度 $theta_o$ 的余弦值由该锥体的扩展角度的余弦值给出。

  $theta_e$ 的值应该是两个锥体的 $theta_e$ 值中的最大值。然而，由于 `LightBounds` 存储的是角度的余弦值，并且余弦函数在可能的 $theta$ 值范围 $[0, pi]$ 上是单调递减的，我们取两个角度余弦值中的最小值。

  ```cpp
  DirectionCone cone = Union(DirectionCone(a.w, a.cosTheta_o),
                             DirectionCone(b.w, b.cosTheta_o));
  Float cosTheta_o = cone.cosTheta;
  Float cosTheta_e = std::min(a.cosTheta_e, b.cosTheta_e);
  ```

  `LightBounds` 构造函数的其余参数值可以轻松地从提供的两个 `LightBounds` 计算得到。

  ```cpp
  return LightBounds(Union(a.bounds, b.bounds), cone.w, a.phi + b.phi,
                     cosTheta_o, cosTheta_e, a.twoSided | b.twoSided);
  ```

  一个工具方法返回空间边界的质心；这个值在构建光源 BVH 时非常有用。

  ```cpp
  Point3f Centroid() const { return (bounds.pMin + bounds.pMax) / 2; }
  ```

  `Importance()` 方法提供了关键的 `LightBounds` 功能：它返回一个标量值，估计给定点处光源或光源群体的贡献。如果提供的法线是非退化的，则假设它是接收点处的表面法线。参与介质中的散射点传递一个零值的 `Normal3f`。
]

```cpp
<<LightBounds Method Definitions>>=
Float LightBounds::Importance(Point3f p, Normal3f n) const {
    <<Return importance for light bounds at reference point>>
}
```

#parec[
  It is necessary to make a number of assumptions in order to estimate the amount of light arriving at a point given a `LightBounds`. While it will be possible to make use of principles such as the received power falling off with the squared distance from the emitter or the incident irradiance at a surface varying according to Lambert's law, some approximations are inevitable, given the loss of specifics that comes with adopting the `LightBounds` representation.
][
  为了估算给定 `LightBounds` 时某一点到达的光量，需要做出一些假设。虽然可以利用一些原理，例如接收的功率随发射体的平方距离衰减，或者表面上的入射辐照度根据兰伯特定律变化，但由于采用 `LightBounds` 表示法时丧失了具体细节，一些近似是不可避免的。
]

```cpp
<<Return importance for light bounds at reference point>>=
<<Compute clamped squared distance to reference point>>
<<Define cosine and sine clamped subtraction lambdas>>
<<Compute sine and cosine of angle to vector w, >>
<<Compute  for reference point>>
<<Compute  and test against >>
<<Return final importance at reference point>>
```


#parec[
  Even computing the squared distance for the falloff of received power is challenging if `bounds` is not degenerate: to which point in `bounds` should the distance be computed? It may seem that finding the minimum distance from the point `p` to the bounds would be a safe choice, though this would imply a very small distance for a point close to the bounds and a zero distance for a point inside it. Either of these would lead to a very large $1 \/ r^2$ factor and potentially high error due to giving too much preference to such a `LightBounds`. Further, choosing between the two child `LightBounds` of a node when a point is inside both would be impossible, given infinite weights for each.
][
  即使计算接收到的功率的平方距离也是具有挑战性的，如果 `bounds` 不是退化的：应该计算到 `bounds` 中哪个点的距离？看起来计算点 `p` 到 `bounds` 的最小距离似乎是一个安全的选择，尽管这意味着如果点接近 `bounds`，距离会非常小，而如果点位于其中，则距离为零。这两种情况都会导致非常大的 $1 \/ r^2$ 因子，并可能由于过度偏向这种 `LightBounds` 而产生较大的误差。此外，在一个点同时位于两个子 `LightBounds` 内时，选择哪一个会变得不可能，因为每个都有无限大的权重。
]

#parec[
  Therefore, our first fudge is to compute the distance from the center of the bounding box but further to ensure that the squared distance is not too small with respect to the length of the diagonal of the bounding box. Thus, for larger bounding boxes with corresponding uncertainty about what the actual spatial distribution of emission is, the inverse squared distance factor cannot become too large.
][
  因此，我们的第一个修正是计算从包围盒中心到点的距离，但进一步确保平方距离不会相对于包围盒对角线的长度过小。因此，对于较大的包围盒，由于对实际发射分布的不确定性，平方反比距离因子不会变得过大。
]


```cpp
Point3f pc = (bounds.pMin + bounds.pMax) / 2;
Float d2 = DistanceSquared(p, pc);
d2 = std::max(d2, Length(bounds.Diagonal()) / 2);
```

#parec[
  In the following computations, we will need to produce a series of values of the form $cos(max(0, theta_a - theta_b))$ and $sin(max(0, theta_a - theta_b))$. Given the sine and cosine of $theta_a$ and $theta_b$, it is possible to do so without evaluating any trigonometric functions. To see how, consider the cosine: $theta_a - theta_b < 0$ implies that $theta_a < theta_b$ and that therefore $cos theta_a > cos theta_b$. We thus start by checking that case and returning $cos 0 = 1$ if it is true. We are otherwise left with $cos(theta_a - theta_b)$, which can be expressed in terms of the sines and cosines of the two angles using a trigonometric identity, $cos theta_a cos theta_b + sin theta_a sin theta_b$. The case for sine follows analogously.
][
  在接下来的计算中，我们需要生成一系列形如 $cos(max(0, theta_a - theta_b))$ 和 $sin(max(0, theta_a - theta_b))$ 的值。给定 $theta_a$ 和 $theta_b$ 的正弦和余弦，可以在不求解三角函数的情况下完成此操作。为了说明这一点，考虑余弦： $theta_a - theta_b < 0$ 表明 $theta_a < theta_b$，因此 $cos theta_a > cos theta_b$。因此，我们首先检查这种情况，并且如果成立，返回 $cos 0 = 1$。否则，我们得到 $cos(theta_a - theta_b)$，可以使用三角恒等式 $cos theta_a cos theta_b + sin theta_a sin theta_b$ 来表示。正弦的情况类似。
]

#parec[
  Two simple lambda functions provide these capabilities. (Only the one for cosine is included in the text, as `sinSubClamped` follows a similar form.)
][
  两个简单的 lambda 函数提供了这些功能。（仅包含余弦的一个，因为 `sinSubClamped` 具有类似的形式。）
]


#parec[
  There are a number of angles involved in the importance computation. In addition to the ones that specify the directional emission bounds, $theta_o$ and $theta_e$, we will start by computing the sine and cosine of $theta_w$, the angle between the principal normal direction and the vector from the center of the light bounds to the reference point.(see @fig:light-bounds-thetaw-thetab(a))
][
  在重要性计算中涉及多个角度。除了指定方向发射边界的 $theta_o$ 和 $theta_e$，我们还将首先计算 $theta_w$ 的正弦和余弦， $theta_w$ 是发射体法线的主方向与从光源边界中心到参考点的向量之间的夹角。（@fig:light-bounds-thetaw-thetab(a)）
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f26.svg"),
  caption: [
    #ez_caption[
      (a) $theta_w$ measures the angle between the principal normal direction $omega$ and the vector from the center of the bounding box to the reference point. (b) $theta_b$ is the angle that the `LightBounds`'s bounding box, `bounds`, subtends with respect to the reference point.
    ][
      (a) $theta_w$ 测量主法线方向 $omega$ 与从包围盒中心到参考点的向量之间的夹角。(b) $theta_b$ 是 `LightBounds` 包围盒相对于参考点的角度。
    ]
  ],
)<light-bounds-thetaw-thetab>

```cpp
Vector3f wi = Normalize(p - pc);
Float cosTheta_w = Dot(Vector3f(w), wi);
if (twoSided)
    cosTheta_w = std::abs(cosTheta_w);
Float sinTheta_w = SafeSqrt(1 - Sqr(cosTheta_w));
```
#parec[
  To bound the variation of various angles across the extent of the bounding box, we will also make use of the angle that the bounding box subtends with respect to the reference point. We will denote this angle $theta_b$. The preexisting `DirectionCone::BoundSubtendedDirections()` function takes care of computing its cosine. Its sine follows directly.
][
  为了限制包围盒范围内各种角度的变化，我们还将利用包围盒相对于参考点的角度。我们将这个角度记作 $theta_b$。现有的 `DirectionCone::BoundSubtendedDirections()` 函数负责计算其余弦。正弦可以直接得到。
]

```cpp
Float cosTheta_b = BoundSubtendedDirections(bounds, p).cosTheta;
Float sinTheta_b = SafeSqrt(1 - Sqr(cosTheta_b));
```
#parec[
  The last angle we will use is the minimum angle between the emitter's normal and the vector to the reference point. We will denote it by $theta'$, and it is given by
][
  我们将使用的最后一个角度是发射体法线和到参考点的向量之间的最小角度。我们将其记作 $theta'$，它由以下公式给出：
]

$ theta prime = max (0 , theta_w - theta_o - theta_b) ; $


#parec[
  see @fig:light-bounds-theta-prime . As with the other angles, we only need its sine and cosine, which can be computed one subtraction at a time.
][
  见@fig:light-bounds-theta-prime。与其他角度一样，我们只需要它的正弦和余弦，这可以通过一次减法计算。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f27.svg"),
  caption: [
    #ez_caption[
      $theta'$ is the minimum angle between the emitter and the vector to the reference point.
    ][
      $theta'$ 是发射体法线与指向参考点的向量之间的最小角度。
    ]
  ],
)<light-bounds-theta-prime>

#parec[
  If this angle is greater than $theta_e$ (or, here, if its cosine is less than $cos theta_e$ ), then it is certain that the lights represented by the bounds do not illuminate the reference point and an importance value of~0 can be returned immediately.
][
  如果这个角度大于 $theta_e$ （或者，这里，如果它的余弦小于 $cos theta_e$ ），那么可以确定由边界表示的光不会照亮参考点，并且可以立即返回重要性值为0。
]

```cpp
Float sinTheta_o = SafeSqrt(1 - Sqr(cosTheta_o)); Float cosTheta_x = cosSubClamped(sinTheta_w, cosTheta_w, sinTheta_o, cosTheta_o); Float sinTheta_x = sinSubClamped(sinTheta_w, cosTheta_w, sinTheta_o, cosTheta_o); Float cosThetap = cosSubClamped(sinTheta_x, cosTheta_x, sinTheta_b, cosTheta_b); if (cosThetap <= cosTheta_e) return 0;
```

#parec[
  The importance value can now be computed. It starts with the product of the power of the lights, the $cos theta'$ factor that accounts for the cosine at the emitter, and the inverse squared distance.
][
  现在可以计算重要性值。它从光源功率、考虑发射器余弦的 $cos theta'$ 因子和反平方距离的乘积开始。
]


```cpp
<<Return final importance at reference point>>=
Float importance = phi * cosThetap / d2;
<<Account for  in importance at surfaces>>
   if (n != Normal3f(0, 0, 0)) {
       Float cosTheta_i = AbsDot(wi, n);
       Float sinTheta_i = SafeSqrt(1 - Sqr(cosTheta_i));
       Float cosThetap_i = cosSubClamped(sinTheta_i, cosTheta_i,
                                         sinTheta_b, cosTheta_b);
       importance *= cosThetap_i;
   }

return importance;
```

#parec[
  At a surface, the importance also accounts for a conservative estimate of the incident cosine factor there. We have `wi`, the unit vector from the reference point to the center of the #link("<LightBounds>")[LightBounds];, but would like to conservatively set the importance based on the maximum value of the incident cosine over the entire bounding box. The corresponding minimum angle with the surface normal is given by $max (0 , theta_i - theta_b)$ (see @fig:light-sample-thetai-prime ).
][
  在表面上，重要性还考虑了那里的入射余弦因子的保守估计。我们有 `wi`，从参考点到 #link("<LightBounds>")[LightBounds] 中心的单位向量，但希望根据整个边界框上入射余弦的最大值保守地设置重要性。与表面法线的相应最小角度由 $max (0 , theta_i - theta_b)$ 给出（见@fig:light-sample-thetai-prime ）。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f28.svg"),
  caption: [
    #ez_caption[
      An angle $theta'_i$ that gives a lower bound on the angle between the incident lighting direction and the surface normal can be found by subtracting $theta_b$, the angle that the bounding box subtends with respect to the reference point $p$, from $theta_i$, the angle between the surface normal and the vector to the center of the box.
    ][
      一个角度 $theta'_i$ 可以通过从 $theta_i$（表面法线与指向盒子中心的向量之间的角度）中减去 $theta_b$（边界框相对于参考点 $p$ 所形成的角度）来得到，它提供了入射光照方向与表面法线之间的角度下界。
    ]
  ],
)<light-sample-thetai-prime>

#parec[
  Our implementation of this computation uses the `cosSubClamped()` lambda function introduced earlier to compute the cosine of the angle $theta'_i$ directly using the sines and cosines of the two contributing angles.
][
  我们对这一计算的实现使用了之前介绍的 `cosSubClamped()` lambda 函数，直接使用两个贡献角的正弦和余弦来计算角度 $theta'_i$ 的余弦。
]


```cpp
if (n != Normal3f(0, 0, 0)) {
    Float cosTheta_i = AbsDot(wi, n);
    Float sinTheta_i = SafeSqrt(1 - Sqr(cosTheta_i));
    Float cosThetap_i = cosSubClamped(sinTheta_i, cosTheta_i, sinTheta_b, cosTheta_b);
    importance *= cosThetap_i;
}
```


==== Bounds for Light Implementations
<bounds-for-light-implementations>
#parec[
  Given the definition of `LightBounds`, we will add another method to the `Light` interface to allow lights to return bounds on their emission.
][
  根据 `LightBounds` 的定义，我们将在 `Light` 接口中添加另一种方法，以允许灯光返回其发射的界限。
]

```cpp
<<Light Interface>>+=
pstd::optional<LightBounds> Bounds() const;
```


#parec[
  Lights at infinity return an unset `optional` value. Here, for example, is the implementation of this method for `ImageInfiniteLight`. The other infinite lights and the `DistantLight` do likewise.
][
  无穷远光源返回一个未设置的 `optional` 值。以下是 `ImageInfiniteLight` 的此方法的实现。其他无穷远灯光和 `DistantLight` 也同样处理。
]

```cpp
pstd::optional<LightBounds> Bounds() const { return {}; }
```

#parec[
  The `PointLight`'s implementation is just a few lines of code, as befitting the simplicity of that type of light source. The spatial bounds are given by the light's rendering space position and the total emitted power is easily computed following the approach in `PointLight::Phi()`. Because this light shines in all directions, the average normal direction is arbitrary and $theta_(upright(o)) = pi$, corresponding to the full sphere of directions.
][
  `PointLight` 的实现代码非常简短，符合这种光源类型的简单性。空间界限由灯光的渲染空间位置给出，总发射功率可以按照 `PointLight::Phi()` 中的方法轻松计算。由于这种灯光向所有方向照射，平均法线方向是随意的，并且 $theta_(upright(o)) = pi$，对应于整个球体的方向。
]

```cpp
pstd::optional<LightBounds> PointLight::Bounds() const {
    Point3f p = renderFromLight(Point3f(0, 0, 0));
    Float phi = 4 * Pi * scale * I->MaxValue();
    return LightBounds(Bounds3f(p, p), Vector3f(0, 0, 1), phi, std::cos(Pi),
                       std::cos(Pi / 2), false);
}
```

#parec[
  The `SpotLight`'s bounding method is a bit more interesting: now the average normal vector is relevant; it is set here to be the light's direction. The $theta_(upright(o))$ range is set to be the angular width of the inner cone of the light and $theta_(upright(e))$ corresponds to the width of its falloff at the edges. While this falloff does not exactly match the cosine-weighted falloff used in the `LightBounds::Importance()` method, it is close enough for these purposes.
][
  `SpotLight` 的界限方法更复杂：现在平均法向量是相关的；这里将其设置为灯光的方向。 $theta_(upright(o))$ 范围设置为灯光内锥的角宽度， $theta_(upright(e))$ 对应于其边缘的衰减宽度。虽然这种衰减与 `LightBounds::Importance()` 方法中使用的余弦加权衰减不完全匹配，但对于这些目的已经足够接近。
]

#parec[
  There is a subtlety in the computation of `phi` for this light: it is computed as if the light source was an isotropic point source and is not affected by the spotlight's cone angle, like the computation in `SpotLight::Phi()` is. To understand the reason for this, consider two spotlights with the same radiant intensity, one with a very narrow cone and one with a wide cone, both illuminating some point in the scene. The total power emitted by the former is much less than the latter, though for a point inside both of their cones, both should be sampled with equal probability—effectively, the cone is accounted for in the light importance function and so should not be included in the `phi` value supplied here.
][
  计算这种灯光的 `phi` 有一个微妙之处：它是按照光源是各向同性点光源来计算的，不受聚光灯锥角的影响，就像在 `SpotLight::Phi()` 中的计算一样。要理解这一点，考虑两个具有相同辐射强度的聚光灯，一个锥角非常窄，一个锥角很宽，两者都照亮场景中的某个点。 前者发射的总功率远小于后者，但对于两者锥体内的某个点，两者都应以相同的概率进行采样——实际上，锥体在灯光重要性函数中已被考虑，因此不应包括在这里提供的 `phi` 值中。
]


```cpp
pstd::optional<LightBounds> SpotLight::Bounds() const {
    Point3f p = renderFromLight(Point3f(0, 0, 0));
    Vector3f w = Normalize(renderFromLight(Vector3f(0, 0, 1)));
    Float phi = scale * Iemit->MaxValue() * 4 * Pi;
    Float cosTheta_e = std::cos(std::acos(cosFalloffEnd) -
                                std::acos(cosFalloffStart));
    return LightBounds(Bounds3f(p, p), w, phi, cosFalloffStart,
                       cosTheta_e, false);
}
```

#parec[
  We will skip past the implementations of the `ProjectionLight` and `GoniometricLight` `Bounds()` methods, which are along similar lines.
][
  我们将跳过 `ProjectionLight` 和 `GoniometricLight` 的 `Bounds()` 方法的实现，它们的实现方式类似。
]

#parec[
  The `DiffuseAreaLight`'s `Bounds()` implementation is different than the previous ones. The utility of the `Shape::NormalBounds()` method may now be better appreciated; the cone of directions that it returns gives the average normal direction $omega$ and its spread angle $theta_(upright(o))$. For area lights, $theta_(upright(e)) = pi / 2$, since illumination is emitted in the entire hemisphere around each surface normal.
][
  `DiffuseAreaLight` 的 `Bounds()` 实现与之前的不同。现在可能更能理解 `Shape::NormalBounds()` 方法的实用性；它返回的方向锥给出了平均法线方向 $omega$ 及其扩展角度 $theta_(upright(o))$。 对于面积灯光， $theta_(upright(e)) = pi / 2$，因为照明在每个表面法线周围的整个半球内发射。
]


```cpp
pstd::optional<LightBounds> DiffuseAreaLight::Bounds() const {
    // 计算漫射面积灯光界限的 phi
    Float phi = 0;
    if (image) {
        // 计算平均 DiffuseAreaLight 图像通道值
        for (int y = 0; y < image.Resolution().y; ++y)
            for (int x = 0; x < image.Resolution().x; ++x)
                for (int c = 0; c < 3; ++c)
                    phi += image.GetChannel({x, y}, c);
        phi /= 3 * image.Resolution().x * image.Resolution().y;
    } else
        phi = Lemit->MaxValue();
    phi *= scale * area * Pi;
    DirectionCone nb = shape.NormalBounds();
    return LightBounds(shape.Bounds(), nb.w, phi, nb.cosTheta,
                       std::cos(Pi / 2), twoSided);
}
```

#parec[
  The `phi` value is found by integrating over the light's area. For lights that use an `Image` for spatially varying emission, the `Compute average DiffuseAreaLight image channel value` fragment, not included here, computes its average value. Because `LightBounds` accounts for whether the emitter is one- or two-sided, it is important not to double the shape's area if it is two-sided; that factor is already included in the importance computation. (This subtlety is similar to the one for the `SpotLight`'s `phi` value.) See @fig:one-two-sided-lights for an illustration of how this detail makes a difference.
][
  `phi` 值是通过对灯光面积进行积分来得到的。对于使用 `Image` 进行空间变化发射的灯光，未在此处包含的 `计算平均 DiffuseAreaLight 图像通道值` 片段计算其平均值。 因为 `LightBounds` 已经考虑了发射器是单面还是双面，所以如果是双面，则重要的是不要将形状的面积加倍；该因素已包含在重要性计算中。 （这种细微之处类似于 `SpotLight` 的 `phi` 值的情况。）参见@fig:one-two-sided-lights 以观察此细节的影响。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f29.svg"),
  caption: [
    #ez_caption[
      Simple Scene with Two Area Lights. The quadrilateral
      on the right emits light from both sides, while the one on the left
      only emits from the front side. (a) If the
      `DiffuseAreaLight::Bounds()` method includes an additional factor of
      2 for the two-sided light’s importance, then it receives more
      samples than it should. (b) Without this factor, the light
      importance values are more accurate, which in turn gives a visible
      reduction in error. The MSE improvement is a factor of 1.42.
    ][
      两个面积灯光的简单场景。右侧的四边形从两侧发光，而左侧的仅从前侧发光。(a)
      如果 `DiffuseAreaLight::Bounds()`
      方法为双面灯光的重要性包含一个额外的因子
      2，那么它将获得比应有的更多的采样。(b)
      没有这个因子，灯光重要性值更准确，从而显著减少误差。MSE 改进因子为
      1.42。
    ]
  ],
)<one-two-sided-lights>

```cpp
<<Compute phi for diffuse area light bounds>>=
Float phi = 0;
if (image) {
    <<Compute average DiffuseAreaLight image channel value>>
} else
    phi = Lemit->MaxValue();
phi *= scale * area * Pi;
```


==== Compactly Bounding Lights
<compactly-bounding-lights>
#parec[
  The #link("<LightBounds>")[`LightBounds`] class uses 52 bytes of storage. This is not a problem as far as the total amount of memory consumed for the lights in the scene, but it does affect performance from the amount of space it uses in the cache. For scenes with thousands of lights, multiple instances of the #link("<LightBounds>")[`LightBounds`] will be accessed when traversing the light BVH, and so minimizing its storage requirements improves cache performance and thus overall performance. (This is especially the case on the GPU, since many threads run concurrently on each processor and each will generally follow a different path through the light BVH and thus access different #link("<LightBounds>")[`LightBounds`] instances.)
][
  #link("<LightBounds>")[`LightBounds`] 类使用了52字节的存储空间。就场景中光源所消耗的总内存量而言，这不是一个问题，但它确实会因为在缓存中使用的空间量而影响性能。对于拥有数千个光源的场景，当遍历光源BVH时，会访问多个#link("<LightBounds>")[`LightBounds`];实例，因此，最小化其存储需求可以提高缓存性能，从而提高整体性能。（这在GPU上尤其如此，因为每个处理器上有许多线程同时运行，并且每个线程通常会通过光源BVH的不同路径，从而访问不同的#link("<LightBounds>")[`LightBounds`];实例。）
]

#parec[
  Therefore, we have also implemented a #link("<CompactLightBounds>")[`CompactLightBounds`] class, which applies a number of techniques to reduce storage requirements for the #link("<LightBounds>")[`LightBounds`] information. It uses just 24 bytes of storage. We use both classes in `pbrt`: the uncompressed #link("<LightBounds>")[`LightBounds`] is convenient for lights to return from their `Bounds()` methods and is also a good representation to use when building the light BVH. #link("<CompactLightBounds>")[`CompactLightBounds`] is used solely in the in-memory representation of light BVH nodes, where minimizing size is beneficial to performance.
][
  因此，我们还实现了一个#link("<CompactLightBounds>")[`CompactLightBounds`];类，该类应用了一些技术来减少#link("<LightBounds>")[`LightBounds`];信息的存储需求。它仅使用24字节的存储空间。我们在`pbrt`中使用这两个类：未压缩的#link("<LightBounds>")[`LightBounds`];便于光源从其`Bounds()`方法返回，并且在构建光源BVH时也是一个很好的表示。#link("<CompactLightBounds>")[`CompactLightBounds`];仅用于光源BVH节点的内存表示，其中最小化大小有利于性能。
]

```cpp
class CompactLightBounds {
public:
    // CompactLightBounds Public Methods
    CompactLightBounds() = default;
    CompactLightBounds(const LightBounds &lb, const Bounds3f &allb)
        : w(Normalize(lb.w)), phi(lb.phi),
          qCosTheta_o(QuantizeCos(lb.cosTheta_o)),
          qCosTheta_e(QuantizeCos(lb.cosTheta_e)), twoSided(lb.twoSided) {
        // Quantize bounding box into qb
        for (int c = 0; c < 3; ++c) {
            qb[0][c] = pstd::floor(QuantizeBounds(lb.bounds[0][c],
                                                  allb.pMin[c], allb.pMax[c]));
            qb[1][c] = pstd::ceil(QuantizeBounds(lb.bounds[1][c],
                                                 allb.pMin[c], allb.pMax[c]));
        }
    }
    std::string ToString() const;
    std::string ToString(const Bounds3f &allBounds) const;
    bool TwoSided() const { return twoSided; }
    Float CosTheta_o() const { return 2 * (qCosTheta_o / 32767.f) - 1; }
    Float CosTheta_e() const { return 2 * (qCosTheta_e / 32767.f) - 1; }
    Bounds3f Bounds(const Bounds3f &allb) const {
        return {Point3f(Lerp(qb[0][0] / 65535.f, allb.pMin.x, allb.pMax.x),
                        Lerp(qb[0][1] / 65535.f, allb.pMin.y, allb.pMax.y),
                        Lerp(qb[0][2] / 65535.f, allb.pMin.z, allb.pMax.z)),
                Point3f(Lerp(qb[1][0] / 65535.f, allb.pMin.x, allb.pMax.x),
                        Lerp(qb[1][1] / 65535.f, allb.pMin.y, allb.pMax.y),
                        Lerp(qb[1][2] / 65535.f, allb.pMin.z, allb.pMax.z))};
    }
    Float Importance(Point3f p, Normal3f n, const Bounds3f &allb) const {
        Bounds3f bounds = Bounds(allb);
        Float cosTheta_o = CosTheta_o(), cosTheta_e = CosTheta_e();
        // Return importance for light bounds at reference point
        // Compute clamped squared distance to reference point
        Point3f pc = (bounds.pMin + bounds.pMax) / 2;
        Float d2 = DistanceSquared(p, pc);
        d2 = std::max(d2, Length(bounds.Diagonal()) / 2);
        // Define cosine and sine clamped subtraction lambdas
        auto cosSubClamped = [](Float sinTheta_a, Float cosTheta_a,
                                 Float sinTheta_b, Float cosTheta_b) -> Float {
            if (cosTheta_a > cosTheta_b)
                return 1;
            return cosTheta_a * cosTheta_b + sinTheta_a * sinTheta_b;
        };
        auto sinSubClamped = [](Float sinTheta_a, Float cosTheta_a,
                                 Float sinTheta_b, Float cosTheta_b) -> Float {
            if (cosTheta_a > cosTheta_b)
                return 0;
            return sinTheta_a * cosTheta_b - cosTheta_a * sinTheta_b;
        };
        // Compute sine and cosine of angle to vector w, θ^w
        Vector3f wi = Normalize(p - pc);
        Float cosTheta_w = Dot(Vector3f(w), wi);
        if (twoSided)
            cosTheta_w = std::abs(cosTheta_w);
        Float sinTheta_w = SafeSqrt(1 - Sqr(cosTheta_w));
        // Compute cosine θ^b for reference point
        Float cosTheta_b = BoundSubtendedDirections(bounds, p).cosTheta;
        Float sinTheta_b = SafeSqrt(1 - Sqr(cosTheta_b));
        // Compute cosine θ' and test against cosine θ^e
        Float sinTheta_o = SafeSqrt(1 - Sqr(cosTheta_o));
        Float cosTheta_x =
            cosSubClamped(sinTheta_w, cosTheta_w, sinTheta_o, cosTheta_o);
        Float sinTheta_x =
            sinSubClamped(sinTheta_w, cosTheta_w, sinTheta_o, cosTheta_o);
        Float cosThetap =
            cosSubClamped(sinTheta_x, cosTheta_x, sinTheta_b, cosTheta_b);
        if (cosThetap <= cosTheta_e)
            return 0;
        // Return final importance at reference point
        Float importance = phi * cosThetap / d2;
        // Account for cosine θ^i in importance at surfaces
        if (n != Normal3f(0, 0, 0)) {
            Float cosTheta_i = AbsDot(wi, n);
            Float sinTheta_i = SafeSqrt(1 - Sqr(cosTheta_i));
            Float cosThetap_i = cosSubClamped(sinTheta_i, cosTheta_i,
                                              sinTheta_b, cosTheta_b);
            importance *= cosThetap_i;
        }
        return importance;
    }
private:
    // CompactLightBounds Private Methods
    static unsigned int QuantizeCos(Float c) {
        return pstd::floor(32767.f * ((c + 1) / 2));
    }
    static Float QuantizeBounds(Float c, Float min, Float max) {
        if (min == max) return 0;
        return 65535.f * Clamp((c - min) / (max - min), 0, 1);
    }
    // CompactLightBounds Private Members
    OctahedralVector w;
    Float phi = 0;
    struct {
        unsigned int qCosTheta_o: 15;
        unsigned int qCosTheta_e: 15;
        unsigned int twoSided: 1;
    };
    uint16_t qb[2][3];
};
```



#parec[
  Its constructor takes both a #link("<LightBounds>")[`LightBounds`] instance and a bounding box `allb` that must completely bound #link("<LightBounds::bounds>")[`LightBounds::bounds`];. This bounding box is used to compute quantized bounding box vertex positions to reduce their storage requirements.
][
  其构造函数接受一个#link("<LightBounds>")[`LightBounds`];实例和一个必须完全界定#link("<LightBounds::bounds>")[`LightBounds::bounds`];的边界框`allb`。此边界框用于计算量化的边界框顶点位置以减少其存储需求。
]

```cpp
CompactLightBounds(const LightBounds &lb, const Bounds3f &allb)
    : w(Normalize(lb.w)), phi(lb.phi),
      qCosTheta_o(QuantizeCos(lb.cosTheta_o)),
      qCosTheta_e(QuantizeCos(lb.cosTheta_e)), twoSided(lb.twoSided) {
    // Quantize bounding box into qb
    for (int c = 0; c < 3; ++c) {
        qb[0][c] = pstd::floor(QuantizeBounds(lb.bounds[0][c],
                                              allb.pMin[c], allb.pMax[c]));
        qb[1][c] = pstd::ceil(QuantizeBounds(lb.bounds[1][c],
                                             allb.pMin[c], allb.pMax[c]));
    }
}
```



#parec[
  The #link("../Geometry_and_Transformations/Spherical_Geometry.html#OctahedralVector")[`OctahedralVector`] class from @spherical-parameterizations stores a unit vector in 4 bytes, saving 8 from the #link("../Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`] used in #link("<LightBounds>")[`LightBounds`];. Then, the two cosines and the `twoSided` flag are packed into another 4 bytes using a bitfield, saving another 8. We have left `phi` alone, since the various compactions already implemented are sufficient for `pbrt`'s current requirements.
][
  @spherical-parameterizations 中的#link("../Geometry_and_Transformations/Spherical_Geometry.html#OctahedralVector")[`OctahedralVector`];类以4字节存储一个单位向量，比#link("<LightBounds>")[`LightBounds`];中使用的#link("../Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`];节省了8字节。然后，两个余弦和`twoSided`标志使用位字段打包到另一个4字节中，再节省8字节。我们没有对`phi`进行处理，因为已经实现的各种压缩对于`pbrt`的当前需求已经足够。
]

```cpp
OctahedralVector w;
Float phi = 0;
struct {
    unsigned int qCosTheta_o: 15;
    unsigned int qCosTheta_e: 15;
    unsigned int twoSided: 1;
};
```


#parec[
  `QuantizeCos()` maps the provided value (which is expected to be the cosine of an angle and thus between $- 1$ and $1$ ) to a 15-bit unsigned integer. After being remapped to be in the range $[0 , 1]$, multiplying by the largest representable 15-bit unsigned integer, $2^15 - 1 = 32 , 767$, gives a value that spans the valid range.
][
  `QuantizeCos()`将提供的值（预计是一个角度的余弦，因此在 $- 1$ 到 $1$ 之间）映射到一个15位无符号整数。经过重新映射到 $[0 , 1]$ 范围后，乘以最大可表示的15位无符号整数， $2^15 - 1 = 32 , 767$，得到一个跨越有效范围的值。
]

#parec[
  Note the use of `pstd::floor()` to round the quantized cosine value down before returning it: this is preferable to, say, rounding to the nearest integer, since it ensures that any quantization error serves to slightly increase the corresponding angle rather than decreasing it. (Decreasing it could lead to inadvertently determining that the light did not illuminate a point that it actually did.)
][
  注意使用`pstd::floor()`向下舍入量化的余弦值再返回：这比例如舍入到最接近的整数更好，因为它确保任何量化误差都略微增加相应的角度，而不是减少它。（减少可能导致错误地确定光源没有照亮它实际上照亮的点。）
]

```cpp
static unsigned int QuantizeCos(Float c) {
    return pstd::floor(32767.f * ((c + 1) / 2));
}
```

#parec[
  The bounding box corners are also quantized. Each coordinate of each corner gets 16 bits, all of them stored in the `qb` member variable. This brings the storage for the bounds down to 12 bytes, from 24 before. Here the quantization is also conservative, rounding down at the lower end of the extent and rounding up at the upper end.
][
  边界框的角也被量化。每个角的每个坐标获得16位，所有这些都存储在`qb`成员变量中。这将边界的存储减少到12字节，从之前的24字节。
]

```cpp
for (int c = 0; c < 3; ++c) {
    qb[0][c] = pstd::floor(QuantizeBounds(lb.bounds[0][c],
                                          allb.pMin[c], allb.pMax[c]));
    qb[1][c] = pstd::ceil(QuantizeBounds(lb.bounds[1][c],
                                         allb.pMin[c], allb.pMax[c]));
}
```


#parec[
  `QuantizeBounds()` remaps a coordinate value `c` between `min` and `max` to the range $[0 , 2^16 - 1]$, the range of values that an unsigned 16-bit integer can store.
][
  `QuantizeBounds()`将坐标值`c`在`min`和`max`之间重新映射到 $[0 , 2^16 - 1]$ 范围，即无符号16位整数可以存储的值范围。
]

```cpp
static Float QuantizeBounds(Float c, Float min, Float max) {
    if (min == max) return 0;
    return 65535.f * Clamp((c - min) / (max - min), 0, 1);
}
```


#parec[
  A few convenience methods make the values of various member variables available. For the two quantized cosines, the inverse computation of `QuantizeCos()` is performed.
][
  一些便捷方法使各种成员变量的值可用。对于两个量化的余弦，执行`QuantizeCos()`的逆计算。
]

```cpp
bool TwoSided() const { return twoSided; }
Float CosTheta_o() const { return 2 * (qCosTheta_o / 32767.f) - 1; }
Float CosTheta_e() const { return 2 * (qCosTheta_e / 32767.f) - 1; }
```


#parec[
  The `Bounds()` method returns the `Bounds3f` for the #link("<CompactLightBounds>")[`CompactLightBounds`];. It must be passed the same #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] as was originally passed to its constructor for the correct result to be returned.
][
  `Bounds()`方法返回#link("<CompactLightBounds>")[`CompactLightBounds`];的`Bounds3f`。为了返回正确的结果，必须传递与其构造函数最初传递的相同的#link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`];。
]

```cpp
Bounds3f Bounds(const Bounds3f &allb) const {
    return {Point3f(Lerp(qb[0][0] / 65535.f, allb.pMin.x, allb.pMax.x),
                    Lerp(qb[0][1] / 65535.f, allb.pMin.y, allb.pMax.y),
                    Lerp(qb[0][2] / 65535.f, allb.pMin.z, allb.pMax.z)),
            Point3f(Lerp(qb[1][0] / 65535.f, allb.pMin.x, allb.pMax.x),
                    Lerp(qb[1][1] / 65535.f, allb.pMin.y, allb.pMax.y),
                    Lerp(qb[1][2] / 65535.f, allb.pMin.z, allb.pMax.z))};
}
```


#parec[
  Finally, `CompactLightBounds()` also provides an `Importance()` method. Its implementation also requires that the original #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] be provided so that the `Bounds()` method can be called. Given the unquantized bounds and cosines made available in appropriately named local variables, the remainder of the implementation can share the same fragments as were used in the implementation of #link("LightBounds::Importance()")[`LightBounds::Importance`];.
][
  最后，`CompactLightBounds()`还提供了一个`Importance()`方法。其实现还要求提供原始的#link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`];，以便可以调用`Bounds()`方法。给定未量化的边界和余弦在适当命名的局部变量中可用，剩余的实现可以共享与#link("LightBounds::Importance()")[`LightBounds::Importance`];实现中使用的相同片段。
]

```cpp
Float Importance(Point3f p, Normal3f n, const Bounds3f &allb) const {
    Bounds3f bounds = Bounds(allb);
    Float cosTheta_o = CosTheta_o(), cosTheta_e = CosTheta_e();
    // Return importance for light bounds at reference point
    // Compute clamped squared distance to reference point
    Point3f pc = (bounds.pMin + bounds.pMax) / 2;
    Float d2 = DistanceSquared(p, pc);
    d2 = std::max(d2, Length(bounds.Diagonal()) / 2);
    // Define cosine and sine clamped subtraction lambdas
    auto cosSubClamped = [](Float sinTheta_a, Float cosTheta_a,
                             Float sinTheta_b, Float cosTheta_b) -> Float {
        if (cosTheta_a > cosTheta_b)
            return 1;
        return cosTheta_a * cosTheta_b + sinTheta_a * sinTheta_b;
    };
    auto sinSubClamped = [](Float sinTheta_a, Float cosTheta_a,
                             Float sinTheta_b, Float cosTheta_b) -> Float {
        if (cosTheta_a > cosTheta_b)
            return 0;
        return sinTheta_a * cosTheta_b - cosTheta_a * sinTheta_b;
    };
    // Compute sine and cosine of angle to vector w, θ^w
    Vector3f wi = Normalize(p - pc);
    Float cosTheta_w = Dot(Vector3f(w), wi);
    if (twoSided)
        cosTheta_w = std::abs(cosTheta_w);
    Float sinTheta_w = SafeSqrt(1 - Sqr(cosTheta_w));
    // Compute cosine θ^b for reference point
    Float cosTheta_b = BoundSubtendedDirections(bounds, p).cosTheta;
    Float sinTheta_b = SafeSqrt(1 - Sqr(cosTheta_b));
    // Compute cosine θ' and test against cosine θ^e
    Float sinTheta_o = SafeSqrt(1 - Sqr(cosTheta_o));
    Float cosTheta_x =
        cosSubClamped(sinTheta_w, cosTheta_w, sinTheta_o, cosTheta_o);
    Float sinTheta_x =
        sinSubClamped(sinTheta_w, cosTheta_w, sinTheta_o, cosTheta_o);
    Float cosThetap =
        cosSubClamped(sinTheta_x, cosTheta_x, sinTheta_b, cosTheta_b);
    if (cosThetap <= cosTheta_e)
        return 0;
    // Return final importance at reference point
    Float importance = phi * cosThetap / d2;
    // Account for cosine θ^i in importance at surfaces
    if (n != Normal3f(0, 0, 0)) {
        Float cosTheta_i = AbsDot(wi, n);
        Float sinTheta_i = SafeSqrt(1 - Sqr(cosTheta_i));
        Float cosThetap_i = cosSubClamped(sinTheta_i, cosTheta_i,
                                          sinTheta_b, cosTheta_b);
        importance *= cosThetap_i;
    }
    return importance;
}
```


==== Light Bounding Volume Hierarchies


#parec[
  Given a way of bounding lights as well as a compact representation of these bounds, we can turn to the implementation of the #link("<BVHLightSampler>")[`BVHLightSampler`];. This light sampler is the default for most of the integrators in `pbrt`. Not only is it effective at efficiently sampling among large collections of lights, it even reduces error in simple scenes with just a few lights. @fig:power-vs-light-bvh-simple and @fig:power-vs-light-bvh-complex show two examples.
][
  给定一种包围光源的方法以及这些边界的紧凑表达，我们可以转向#link("<BVHLightSampler>")[`BVHLightSampler`];的实现。这个光采样器是`pbrt`中大多数积分器的默认选择。它不仅在大规模光源集合中高效采样，而且在只有少量光源的简单场景中也能减少误差。 @fig:power-vs-light-bvh-simple 和@fig:power-vs-light-bvh-complex 展示了两个例子。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f30.svg"),
  caption: [
    #ez_caption[
      A Simple Scene with Two Light Sources. (a) Rendered with 1 sample per pixel using the PowerLightSampler. (b) Rendered with 1 sample per pixel using the BVHLightSampler. Even with a small number of lights, error is visibly lower with a sampler that uses spatially varying sampling probabilities due to being able to choose nearby bright lights with higher probability. In this case, MSE is improved by a factor of 2.72.
    ][
      一个简单的场景，包含两个光源。（a）使用 PowerLightSampler 渲染，每像素 1 个样本。（b）使用 BVHLightSampler 渲染，每像素 1 个样本。即使光源数量较少，采用空间变化采样概率的采样器在选择附近的亮光源时能以更高的概率进行采样，从而使误差明显降低。在这种情况下，均方误差（MSE）提高了 2.72 倍。
    ]
  ],
)<power-vs-light-bvh-simple>


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f31.svg"),
  caption: [
    #ez_caption[
      Zero Day Scene, with 8,878 Area Lights. (a) Rendered with the PowerLightSampler. (b) Rendered with the BVHLightSampler. Both images are rendered with 16 samples per pixel. For a scene of this complexity, an effective light sampling algorithm is crucial. The BVHLightSampler gives an MSE improvement of $2.37 times$ with only a 5.8% increase in rendering time. Monte Carlo efficiency is improved by a factor of 2.25. (Scene courtesy of Beeple.)
    ][
      一个简单的场景，包含两个光源。（a）使用 PowerLightSampler 渲染，每像素 1 个样本。（b）使用 BVHLightSampler 渲染，每像素 1 个样本。即使光源数量较少，采用空间变化采样概率的采样器在选择附近的亮光源时能以更高的概率进行采样，从而使误差明显降低。在这种情况下，均方误差（MSE）提高了 2.72 倍。
    ]
  ],
)<power-vs-light-bvh-complex>

```cpp
<<BVHLightSampler Definition>>=
class BVHLightSampler {
  public:
    <<BVHLightSampler Public Methods>>
  private:
    <<BVHLightSampler Private Methods>>
    <<BVHLightSampler Private Members>>
};
```


#parec[
  Its constructor starts by making a copy of the provided array of lights before proceeding to initialize the BVH and additional data structures.
][
  其构造函数首先复制提供的光源数组，然后继续初始化BVH和附加数据结构。
]

```cpp
<<BVHLightSampler Method Definitions>>=
BVHLightSampler::BVHLightSampler(pstd::span<const Light> lights,
                                 Allocator alloc)
    : lights(lights.begin(), lights.end(), alloc), infiniteLights(alloc),
      nodes(alloc), lightToBitTrail(alloc) {
    <<Initialize infiniteLights array and light BVH>>
}

<<BVHLightSampler Private Members>>=
pstd::vector<Light> lights;
```


#parec[
  Because the BVH cannot store lights at infinity, the first step is to partition the lights into those that can be stored in the BVH and those that cannot. This is handled by a loop over all the provided lights after which the BVH is constructed.
][
  由于 BVH 无法存储无限远处的光源，第一步是将光源分为可以存储在 BVH 中的光源和不能存储的光源。这通过对所有提供的光源进行循环处理，之后构建 BVH 来完成。
]

```cpp
<<Initialize infiniteLights array and light BVH>>=
std::vector<std::pair<int, LightBounds>> bvhLights;
for (size_t i = 0; i < lights.size(); ++i) {
   <<Store th light in either infiniteLights or bvhLights>>
}
if (!bvhLights.empty())
    buildBVH(bvhLights, 0, bvhLights.size(), 0, 0);
```


#parec[
  Lights that are not able to provide a `LightBounds` are added to the `infiniteLights` array and are sampled independently of the lights stored in the BVH. As long as they have nonzero emitted power, the rest are added to the `bvhLights` array, which is used during BVH construction. Along the way, a bounding box that encompasses all the BVH lights' bounding boxes is maintained in `allLightBounds`; this is the bounding box that will be passed to the `CompactLightBounds` for quantizing the spatial bounds of individual lights.
][
  无法提供 `LightBounds` 的光源会被添加到 `infiniteLights` 数组，并且它们会独立于存储在 BVH 中的光源进行采样。只要它们的发射功率非零，其余的光源会被添加到 `bvhLights` 数组中，这些光源会在 BVH 构建过程中使用。在此过程中，会维护一个包含所有 BVH 光源的边界框，该边界框存储在 `allLightBounds` 中；这是将传递给 `CompactLightBounds` 用于量化单个光源空间边界的边界框。
]


```cpp
<<Store th light in either infiniteLights or bvhLights>>=
Light light = lights[i];
pstd::optional<LightBounds> lightBounds = light.Bounds();
if (!lightBounds)
    infiniteLights.push_back(light);
else if (lightBounds->phi > 0) {
    bvhLights.push_back(std::make_pair(i, *lightBounds));
    allLightBounds = Union(allLightBounds, lightBounds->bounds);
}

<<BVHLightSampler Private Members>>+=
pstd::vector<Light> infiniteLights;
Bounds3f allLightBounds;
```


#parec[
  The light BVH is represented using an instance of the #link("<LightBVHNode>")[`LightBVHNode`] structure for each tree node, both interior and leaf. It uses a total of 28 bytes of storage, adding just 4 to the 24 used by #link("<CompactLightBounds>")[`CompactLightBounds`];, though its declaration specifies 32-byte alignment, ensuring that 2 of them fit neatly into a typical 64-byte cache line on a CPU, and 4 of them fit into a 128-byte GPU cache line.
][
  光BVH使用#link("<LightBVHNode>")[`LightBVHNode`];结构的实例表示每个树节点，包括内部节点和叶节点。 它使用总共28字节的存储，仅比#link("<CompactLightBounds>")[`CompactLightBounds`];使用的24字节多4字节，尽管其声明指定了32字节对齐，确保2个节点可以整齐地适合典型CPU上的64字节缓存行，而4个节点可以适合128字节的GPU缓存行。
]

```cpp
<<LightBVHNode Definition>>=
struct alignas (32) LightBVHNode {
    <<LightBVHNode Public Methods>>
    <<LightBVHNode Public Members>>
};
```

#parec[
  Naturally, each `LightBVHNode` stores the `CompactLightBounds` for either a single light or a collection of them. Like the `BVHAggregate`'s BVH, the light BVH is laid out in memory so that the first child of each interior node is immediately after it. Therefore, it is only necessary to store information about the second child's location in the `LightBVHNode`. The `BVHLightSampler` stores all nodes in a contiguous array, so an index suffices; a full pointer is unnecessary.
][
  每个 `LightBVHNode` 自然会存储单个光源或一组光源的 `CompactLightBounds`。与 `BVHAggregate` 的 BVH 类似，光源的 BVH 在内存中的布局是这样的：每个内部节点的第一个子节点紧随其后。因此，只有存储第二个子节点位置的信息在 `LightBVHNode` 中是必要的。`BVHLightSampler` 将所有节点存储在一个连续的数组中，因此仅使用索引就足够了，完全不需要指针。
]


```cpp
<<LightBVHNode Public Members>>=
CompactLightBounds lightBounds;
struct {
    unsigned int childOrLightIndex:31;
    unsigned int isLeaf:1;
};

<<BVHLightSampler Private Members>>+=
pstd::vector<LightBVHNode> nodes;
```

#parec[
  Two object-creation methods return a LightBVHNode of the specified type.
][
  两个对象创建方法返回指定类型的 `LightBVHNode`。
]

```cpp
<<LightBVHNode Public Methods>>=
static LightBVHNode MakeLeaf(unsigned int lightIndex,
                             const CompactLightBounds &cb) {
    return LightBVHNode{cb, {lightIndex, 1}};
}

<<LightBVHNode Public Methods>>+=
static LightBVHNode MakeInterior(unsigned int child1Index,
                                 const CompactLightBounds &cb) {
    return LightBVHNode{cb, {child1Index, 0}};
}
```


#parec[
  The `buildBVH()` method constructs the BVH by recursively partitioning the lights until it reaches a single light, at which point a leaf node is constructed. Its implementation closely follows the approach implemented in the #link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate::buildRecursive()")[`BVHAggregate::buildRecursive()`] method: along each dimension, the light bounds are assigned to a fixed number of buckets according to their centroids. Next, a cost model is evaluated for splitting the lights at each bucket boundary. The minimum cost split is chosen and the lights are partitioned into two sets, each one passed to a recursive invocation of `buildBVH()`.
][
  `buildBVH()`方法通过递归划分光源来构建BVH，直到达到单个光源，此时构建叶节点。 其实现紧密遵循#link("../Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate::buildRecursive()")[`BVHAggregate::buildRecursive()`];方法中实现的方法：沿每个维度，根据其质心将光边界分配到固定数量的桶中。 接下来，评估在每个桶边界处分割光源的成本模型。选择最低成本的分割，并将光源划分为两组，每组传递给`buildBVH()`的递归调用。
]

#parec[
  Because these two methods are so similar, here we will only include the fragments where the `BVHLightSampler` substantially diverges—in how nodes are initialized and in the cost model used to evaluate candidate splits.
][
  由于这两个方法非常相似，下面我们只会包含 `BVHLightSampler` 在初始化节点和评估候选划分时所显著不同的部分。
]

```cpp
<<BVHLightSampler Private Methods>>=
std::pair<int, LightBounds> buildBVH(
    std::vector<std::pair<int, LightBounds>> &bvhLights, int start, int end,
    uint32_t bitTrail, int depth);
```

#parec[
  When this method is called with a range corresponding to a single light, a leaf node is initialized and the recursion terminates. A `CompactLightBounds` is created using the bounding box of all lights' bounds to initialize its quantized bounding box coordinates and the BVH tree node can be added to the nodes array.
][
  当该方法以对应单个光源的范围被调用时，会初始化一个叶节点并终止递归。一个 `CompactLightBounds` 会使用所有光源边界的包围盒来初始化其量化后的包围盒坐标，然后该 BVH 树节点会被添加到节点数组中。
]


```cpp
<<Initialize leaf node if only a single light remains>>=
if (end - start == 1) {
    int nodeIndex = nodes.size();
    CompactLightBounds cb(bvhLights[start].second, allLightBounds);
    int lightIndex = bvhLights[start].first;
    nodes.push_back(LightBVHNode::MakeLeaf(lightIndex, cb));
    lightToBitTrail.Insert(lights[lightIndex], bitTrail);
    return {nodeIndex, bvhLights[start].second};
}
```


#parec[
  In order to implement the `PMF()` method, it is necessary to follow a path through the BVH from the root down to the leaf node for the given light. We encode these paths using #emph[bit trails];, integers where each bit encodes which of the two child nodes should be visited at each level of the tree in order to reach the light's leaf node. The lowest bit indicates which child should be visited after the root node, and so forth. These values are computed while the BVH is built and stored in a hash table that uses #link("../Light_Sources/Light_Interface.html#Light")[`Light`];s as keys.
][
  为了实现`PMF()`方法，有必要从根节点沿路径到达给定光源的叶节点。 我们使用#emph[位路径];对这些路径进行编码，整数中每个位编码在树的每个级别中应该访问的两个子节点中的哪个。 最低位表示在根节点之后应该访问哪个子节点，依此类推。 这些值在构建BVH时计算，并存储在使用#link("../Light_Sources/Light_Interface.html#Light")[`Light`];作为键的散列表中。
]


```cpp
<<BVHLightSampler Private Members>>+=
HashMap<Light, uint32_t> lightToBitTrail;
```


#parec[
  When there are multiple lights to consider, the `EvaluateCost()` method is called to evaluate the cost model for the two #link("<LightBounds>")[`LightBounds`] for each split candidate. In addition to the `LightBounds` for which to compute the cost, it takes the bounding box of all the lights passed to the current invocation of `buildBVH()` as well as the dimension in which the split is being performed.
][
  当有多个光源需要考虑时，调用`EvaluateCost()`方法以评估每个分割候选的两个#link("<LightBounds>")[`LightBounds`];的成本模型。 除了用于计算成本的`LightBounds`之外，它还需要传递给当前`buildBVH()`调用的所有光源的边界框以及正在执行分割的维度。
]


```cpp
<<BVHLightSampler Private Methods>>+=
Float EvaluateCost(const LightBounds &b, const Bounds3f &bounds,
                   int dim) const {
    <<Evaluate direction bounds measure for LightBounds>>
    <<Return complete cost estimate for LightBounds>>
}
```

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f32.svg"),
  caption: [
    #ez_caption[
      The direction bounds measure is found by integrating to find the solid angle of the center cone up to $theta_(upright(o))$ and then applying a cosine weighting over the additional angle of $theta_(upright(e))$.
    ][
      方向边界的度量是通过积分来找到中心圆锥的固体角度，积分范围是到 $theta_(upright(o))$，然后对额外角度 $theta_(upright(e))$ 应用余弦加权。
    ]
  ],
)<light-bvh-direction-bounds-integrate>

#parec[
  The principal surface normal direction and the angles $theta_(upright(o))$ and $theta_(upright(e))$ that are stored in #link("<LightBounds>")[`LightBounds`] are worthwhile to include in the light BVH cost function. Doing so can encourage partitions of primitives into groups that emit light in different directions, which can be helpful for culling groups of lights that do not illuminate a given receiving point. To compute these costs, `pbrt` uses a weighted measure of the solid angle of directions that the direction bounds subtend. A weight of 1 is used for all directions inside the center cone up to $theta_(upright(o))$ and then the remainder of directions up to $theta_(upright(e))$ are cosine-weighted, following the importance computation earlier. (See @fig:light-bvh-direction-bounds-integrate.) Integrating over the relevant directions gives us the direction bounds measure,
][
  `LightBounds` 中存储的主表面法线方向以及角度 $theta_(upright(o))$ 和 $theta_(upright(e))$ 在光源 BVH 成本函数中是值得包括的。这样做有助于将原始数据划分为不同方向发射光的组，这对于剔除那些不照亮给定接收点的光源组非常有用。 为了计算这些成本，`pbrt` 使用了一个加权的固体角度度量，来衡量方向边界所涵盖的方向。对于所有位于中心圆锥内的方向，直到 $theta_(upright(o))$，权重为 1；然后，对于其余的方向直到 $theta_(upright(e))$，按照之前的光照重要性计算，采用余弦加权（参见@fig:light-bvh-direction-bounds-integrate）。对相关方向进行积分后，得到了方向边界度量，
]


$
  upright(bold(M))_Omega = 2 pi ( integral_0^(theta_o) sin theta prime thin d theta prime + integral_(theta_o)^(min (theta_o + theta_e , pi)) cos ( theta prime - theta_o ) sin theta prime thin d theta prime ) .
$


#parec[
  The first term integrates to $1 - cos theta_o$ and the second has a simple analytic form that is evaluated in the second term of `M_omega`'s initializer below.
][
  第一个项积分结果为 $1 - cos theta_o$，第二个项有一个简单的解析形式，在下面 `M_omega` 初始化器的第二项中计算。
]

```cpp
<<Evaluate direction bounds measure for LightBounds>>=
Float theta_o = std::acos(b.cosTheta_o), theta_e = std::acos(b.cosTheta_e);
Float theta_w = std::min(theta_o + theta_e, Pi);
Float sinTheta_o = SafeSqrt(1 - Sqr(b.cosTheta_o));
Float M_omega = 2 * Pi * (1 - b.cosTheta_o) +
    Pi / 2 * (2 * theta_w * sinTheta_o - std::cos(theta_o - 2 * theta_w) -
              2 * theta_o * sinTheta_o + b.cosTheta_o);
```


#parec[
  Three other factors go into the full cost estimate: - The power estimate phi: in general, the higher the power of the lights in a LightBounds, the more important it is to minimize factors like the spatial and direction bounds. - A regularization factor Kr that discourages long and thin bounding boxes. - The surface area of the LightBounds's bounding box.
][
  完整的成本估计还涉及另外三个因素：

  - 功率估计 `phi `：一般来说， `LightBounds` 中的灯光功率越高，越重要的是要最小化空间和方向界限等因素。 - 一个正则化系数 `Kr `，它不鼓励长而细的边界框。 - `LightBounds` 的边界框的表面积。
]
#parec[
  The use of surface area in the cost metric deserves note: with the `BVHAggregate` , the surface area heuristic was grounded in geometric probability, as the surface area of a convex object is proportional to the probability of a random ray intersecting it. In this case, no rays are being traced. Arguably, minimizing the volume of the bounds would be a more appropriate approach in this case. In practice, the surface area seems to be more effective-one reason is that it penalizes bounding boxes that span a large extent in two dimensions but little or none in the third. Such bounding boxes are undesirable as they may subtend large solid angles, adding more uncertainty to importance estimates.
][
  在成本指标中使用表面积值得关注：在 `BVHAggregate` 中，表面积启发式基于几何概率，因为凸对象的表面积与随机光线与其相交的概率成正比。在这种情况下，没有光线被追踪。可以认为，最小化界限的体积在这种情况下可能是更合适的方法。在实践中，表面积似乎更有效——原因之一是它惩罚在两个维度上跨度大而在第三个维度上跨度小或没有跨度的边界框。这种边界框是不可取的，因为它们可能会覆盖大固角，增加重要性估计的不确定性。
]


```cpp
<<Return complete cost estimate for LightBounds>>=
Float Kr = MaxComponentValue(bounds.Diagonal()) / bounds.Diagonal()[dim];
return b.phi * M_omega * Kr * b.bounds.SurfaceArea();
```

#parec[
  Once the lights have been partitioned, two fragments take care of recursively initializing the child nodes and then initializing the interior node. The first step is to take a spot in the `nodes` array for the interior node; this spot must be claimed before the children are initialized in order to ensure that the first child is the successor of the interior node in the array. Two recursive calls to `buildBVH()` then initialize the children. The main thing to note in them is the maintenance of the `bitTrail` value passed down into each one. For the first child, the corresponding bit should be set to zero. `bitTrail` is zero-initialized in the initial call to `buildBVH() `, so it has this value already and there is nothing to do. For the second call, the bit for the current tree depth is set to 1.
][
  灯光分区后，有两个片段负责递归初始化子节点，然后初始化内部节点。第一步是在 `nodes `数组中为内部节点预留一个位置；这个位置必须在初始化子节点之前确定，以确保第一个子节点在数组中是内部节点的后继。 两次递归调用 `buildBVH() `然后初始化子节点。需要注意的主要事情是维护传递到每个子节点中的 `bitTrail `值。对于第一个子节点，相应的位应设置为零。 `bitTrail `在最初调用 `buildBVH() `时被初始化为零，所以它已经有这个值，不需要做任何事情。对于第二次调用，当前树深度的位设置为 1。
]

```cpp
<<Allocate interior LightBVHNode and recursively initialize children>>=
int nodeIndex = nodes.size();
nodes.push_back(LightBVHNode());
std::pair<int, LightBounds> child0 =
    buildBVH(bvhLights, start, mid, bitTrail, depth + 1);
std::pair<int, LightBounds> child1 =
    buildBVH(bvhLights, mid, end, bitTrail | (1u << depth), depth + 1);

```

#parec[
  The interior node can be initialized after the children have been. Its light bounds are given by the union of its children's, which allows initializing a `CompactLightBounds` and then the `LightBVHNode` itself.
][
  在子节点初始化后可以初始化内部节点。其光界限由其子节点的并集给出，这允许初始化 `CompactLightBounds` ，然后是`LightBVHNode` 本身。
]

```cpp
<<Initialize interior node and return node index and bounds>>=
LightBounds lb = Union(child0.second, child1.second);
CompactLightBounds cb(lb, allLightBounds);
nodes[nodeIndex] = LightBVHNode::MakeInterior(child1.first, cb);
return {nodeIndex, lb};
```

#parec[
  Given the BVH, we can now implement the Sample() method, which samples a light given a reference point in a LightSampleContext.
][
  给定BVH，我们现在可以实现 `Sample() `方法，该方法在 `LightSampleContext` 中给定参考点的情况下采样灯光。
]

```cpp
<<BVHLightSampler Public Methods>>=
pstd::optional<SampledLight>
Sample(const LightSampleContext &ctx, Float u) const {
    <<Compute infinite light sampling probability pInfinite>>
    if (u < pInfinite) {
        <<Sample infinite lights with uniform probability>>
    } else {
        <<Traverse light BVH to sample light>>
    }
}
```

#parec[
  The first choice to make is whether an infinite light should be sampled or whether the light BVH should be used to choose a noninfinite light. The `BVHLightSampler` gives equal probability to sampling each infinite light and to sampling the BVH, from which the probability of sampling an infinite light follows directly.
][
  首先要做的选择是是否应该采样无限灯光，或者是否应该使用灯光 BVH 来选择非无限灯光。 `BVHLightSampler` 为每个无限灯光和采样 BVH 提供相等的概率，从而直接得出采样无限灯光的概率。
]

```cpp
<<Compute infinite light sampling probability pInfinite>>=
Float pInfinite = Float(infiniteLights.size()) /
    Float(infiniteLights.size() + (nodes.empty() ? 0 : 1));
```

#parec[
  If an infinite light is to be sampled, then the random sample `u` is rescaled to provide a new uniform random sample that is used to index into the `infiniteLights` array.
][
  如果要采样无限灯光，则随机样本 `u `被重新缩放以提供一个新的均匀随机样本，该样本用于索引 `infiniteLights `数组。
]

```cpp
<<Sample infinite lights with uniform probability>>=
u /= pInfinite;
int index = std::min<int>(u * infiniteLights.size(),
                          infiniteLights.size() - 1);
Float pmf = pInfinite / infiniteLights.size();
return SampledLight{infiniteLights[index], pmf};
```


#parec[
  Otherwise a light is sampled by traversing the BVH. At each interior node, probabilities are found for sampling each of the two children using importance values returned by the `LightBounds` for the reference point. A child node is then randomly chosen according to these probabilities. In the end, the probability of choosing a leaf node is equal to the product of probabilities along the path from the root to the leaf (see @fig:sampling-light-bvh ). With this traversal scheme, there is no need to maintain a stack of nodes to be processed as the `BVHAggregate` does&#8212;a single path is taken down the tree from the root to a leaf.
][
  否则，通过遍历 BVH 来采样灯光。在每个内部节点，使用参考点返回的 `LightBounds `的重要性值来找到采样两个子节点的概率。然后根据这些概率随机选择一个子节点。最终，选择叶节点的概率等于从根到叶的路径上的概率的乘积（见@fig:sampling-light-bvh ）。 使用这种遍历方案，不需要像 `BVHAggregate` 那样维护要处理的节点堆栈——从根到叶的路径是单一的。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f33.svg"),
  caption: [
    #ez_caption[
      Sampling a Light BVH.
      At each non-leaf node of the tree, we compute discrete probabilities
      $p_i$ and $1 - p_i$ for sampling each child node and then randomly choose a
      child accordingly. The probability of sampling each leaf node is the
      product of probabilities along the path from the root of the tree down to
      it. Here, the nodes that are visited and the associated probabilities for
      sampling the triangular light source are highlighted.
    ][
      采样灯光 BVH。
      在树的每个非叶节点，我们计算离散概率
      $p_i$ 和 $1 - p_i$ 用于采样每个子节点，然后随机选择一个子节点。
      采样每个叶节点的概率是从树的根到它的路径上的概率的乘积。在这里，访问的节点和用于采样三角形光源的相关概率被突出显示。

    ]
  ],
)<sampling-light-bvh>

```cpp
 <<Traverse light BVH to sample light>>=
if (nodes.empty())
    return {};
<<Declare common variables for light BVH traversal>>
while (true) {
    <<Process light BVH node for light sampling>>
}
```




#parec[
  A few values will be handy in the following traversal of the BVH. Among them are the uniform sample `u `, which is remapped to a new uniform random sample in $\[0, 1\)$. `pmf` starts out with the probability of sampling the BVH in the first place; each time a child node of the tree is randomly sampled, it will be multiplied by the discrete probability of that sampling choice so that in the end it stores the complete probability for sampling the light.
][
  在以下对 BVH 的遍历中，一些值将是有用的。其中包括均匀样本 `u `，它被重新映射为 $\[0, 1\)$ 中的新均匀随机样本。 `pmf `从一开始就具有采样 BVH 的概率；每次随机采样树的子节点时，它将乘以该采样选择的离散概率，以便最终它存储采样灯光的完整概率。
]

```cpp
<<Declare common variables for light BVH traversal>>=
Point3f p = ctx.p();
Normal3f n = ctx.ns;
u = std::min<Float>((u - pInfinite) / (1 - pInfinite), OneMinusEpsilon);
int nodeIndex = 0;
Float pmf = 1 - pInfinite;
```

#parec[
  At each interior node, a child node is randomly sampled. Given a leaf node, we have reached the sampled light.
][
  在每个内部节点，随机采样一个子节点。给定一个叶节点，我们已经找到了采样的灯光。
]

```cpp
<<Process light BVH node for light sampling>>=
LightBVHNode node = nodes[nodeIndex];
if (!node.isLeaf) {
    <<Compute light BVH child node importances>>
    <<Randomly sample light BVH child node>>
} else {
    <<Confirm light has nonzero importance before returning light sample>>
}
```


#parec[
  The first step at an interior node is to compute the importance values for the two child nodes. It may be the case that both of them are 0, indicating that neither child illuminates the reference point. That we may end up in this situation may be surprising: in that case, why would we have chosen to visit this node in the first place? This state of affairs is a natural consequence of the accuracy of light bounds improving on the way down the tree, which makes it possible for them to better differentiate regions that their respective subtrees do and do not illuminate.
][
  在内部节点的第一步是计算两个子节点的重要性值。可能的情况是它们的值都是 0，表示两个子节点都没有照亮参考点。我们可能会选择访问这个节点的原因可能会令人惊讶：在这种情况下，为什么我们会选择访问这个节点呢？这种情况是光界限在下降树的过程中精度提高的自然结果，这使得它们能够更好地区分其各自子树照亮和不照亮的区域。
]

```cpp
<<Compute light BVH child node importances>>=
const LightBVHNode *children[2] = {&nodes[nodeIndex + 1],
                                   &nodes[node.childOrLightIndex] };
Float ci[2] = { children[0]->lightBounds.Importance(p, n, allLightBounds),
                children[1]->lightBounds.Importance(p, n, allLightBounds)};
if (ci[0] == 0 && ci[1] == 0)
    return {};
```

#parec[
  Given at least one nonzero importance value, `SampleDiscrete()` takes care of choosing a child node. The sampling PMF it returns is incorporated into the running `pmf` product. We further use its capability for remapping the sample `u` to a new uniform sample in $\[0, 1\)$, which allows the reuse of the `u` variable in subsequent loop iterations.
][
  给定至少一个非零的重要性值， `SampleDiscrete()` 负责选择一个子节点。它返回的采样 PMF 被纳入正在进行的 `pmf `乘积中。我们进一步利用其重新映射样本 `u `为 $\[0, 1\)$ 中的新均匀样本的能力，这允许在后续循环迭代中重用 `u `变量。
]

```cpp
<<Randomly sample light BVH child node>>=
Float nodePMF;
int child = SampleDiscrete(ci, u, &nodePMF, &u);
pmf *= nodePMF;
nodeIndex = (child == 0) ? (nodeIndex + 1) : node.childOrLightIndex;
```

#parec[
  When a leaf node is reached, we have found a light. The light should only be returned if it has a nonzero importance value, however: if the importance is zero, then it is better to return no light than to return one and cause the caller to go through some additional work to sample it before finding that it has no contribution. Most of the time, we have already determined that the node's light bounds have a nonzero importance value by dint of sampling the node while traversing the BVH in the first place. It is thus only in the case of a single-node BVH with a single light stored in it that this test must be performed here.
][
  当到达叶节点时，我们找到了一个灯光。灯光应该只有在具有非零重要性值时才返回， 然而：如果重要性为零，那么最好不返回灯光，而不是返回一个灯光并导致调用者在采样之前进行一些额外的工作，然后发现它没有贡献。大多数时候，我们已经确定节点的光界限通过在遍历 BVH 时采样节点而具有非零重要性值。因此，只有在单节点 BVH 中存储单个灯光的情况下，才必须在此处执行此测试。
]

```cpp
<<Confirm light has nonzero importance before returning light sample>>=
if (nodeIndex > 0 ||
    node.lightBounds.Importance(p, n, allLightBounds) > 0)
    return SampledLight{lights[node.childOrLightIndex], pmf};
return {};
```


#parec[
  Computing the PMF for sampling a specified light follows a set of computations similar to those of the sampling method: if the light is an infinite light, the infinite light sampling probability is returned and otherwise the BVH is traversed to compute the light's sampling probability. In this case, BVH traversal is not stochastic, but is specified by the bit trail for the given light, which encodes the path to the leaf node that stores it.
][
  计算指定灯光的采样 PMF 遵循一组与采样方法类似的计算：如果灯光是无限灯光，则返回无限灯光采样概率，否则遍历 BVH 以计算灯光的采样概率。在这种情况下，BVH 遍历不是随机的，而是由给定灯光的位轨迹指定，该轨迹编码了存储它的叶节点的路径。
]


```cpp
 <<BVHLightSampler Public Methods>>+=
Float PMF(const LightSampleContext &ctx, Light light) const {
    <<Handle infinite light PMF computation>>
    <<Initialize local variables for BVH traversal for PMF computation>>
    <<Compute light’s PMF by walking down tree nodes to the light>>
}
```



#parec[
  If the given light is not in the bit trail hash table, then it is not stored in the BVH and therefore must be an infinite light. The probability of sampling it is one over the total number of infinite lights plus one if there is a light BVH.
][
  如果给定的灯光不在位轨迹哈希表中，则它不存储在 BVH 中，因此必须是无限灯光。采样它的概率是总无限灯光数加上一个（如果有灯光 BVH）分之一。
]

```cpp
<<Handle infinite light PMF computation>>=
if (!lightToBitTrail.HasKey(light))
    return 1.f / (infiniteLights.size() + (nodes.empty() ? 0 : 1));
```


#parec[
  A number of values will be useful as the tree is traversed, including the bit trail that points the way to the correct leaf, the PMF of the path taken so far, and the index of the current node being visited, starting here at the root.
][
  在遍历树时，一些值将是有用的，包括指向正确叶节点的位轨迹、到目前为止所采取路径的 PMF 以及当前访问的节点的索引，从这里开始为根节点。
]

```cpp
<<Initialize local variables for BVH traversal for PMF computation>>=
uint32_t bitTrail = lightToBitTrail[light];
Point3f p = ctx.p();
Normal3f n = ctx.ns;
<<Compute infinite light sampling probability pInfinite>>
Float pmf = 1 - pInfinite;
int nodeIndex = 0;
```


#parec[
  For a light that is stored in the BVH, the probability of sampling it is again computed as the product of each discrete probability of sampling the child node that leads to its leaf node.
][
  对于存储在 BVH 中的灯光，采样它的概率再次计算为每个离散概率的乘积，用于采样导致其叶节点的子节点。
]


#parec[
  The lowest bit of `bitTrail` encodes which of the two children of the node is visited on a path down to the light's leaf node. In turn, it is possible to compute the probability of sampling that node given the two child nodes' importance values.
][
  `bitTrail `的最低位编码了在路径下访问灯光叶节点的两个子节点中的哪个。反过来，可以根据两个子节点的重要性值计算采样该节点的概率。
]

```cpp
<<Compute child importances and update PMF for current node>>=
const LightBVHNode *child0 = &nodes[nodeIndex + 1];
const LightBVHNode *child1 = &nodes[node->childOrLightIndex];
Float ci[2] = { child0->lightBounds.Importance(p, n, allLightBounds),
                child1->lightBounds.Importance(p, n, allLightBounds) };
pmf *= ci[bitTrail & 1] / (ci[0] + ci[1]);
```

#parec[
  The low-order bit of `bitTrail` also points us to which node to visit next on the way down the tree. After `nodeIndex` is updated, `bitTrail` is shifted right by one bit so that the low-order bit encodes the choice to make at the next level of the tree.
][
  `bitTrail `的低位还指向我们在树下访问的下一个节点。更新 `nodeIndex `后， `bitTrail `右移一位，以便低位编码在树的下一级别做出的选择。
]

```cpp
<<Use bitTrail to find next node index and update its value>>=
nodeIndex = (bitTrail & 1) ? node->childOrLightIndex : (nodeIndex + 1);
bitTrail >>= 1;
```

#parec[
  The basic `Sample()` and `PMF()` methods for when a reference point is not specified sample all the lights uniformly and so are not included here, as they parallel the implementations in the `UniformLightSampler` .
][
  当没有指定参考点时， `Sample() `和 `PMF() `方法的基本实现均匀地采样所有灯光，因此不在此处包含，因为它们与 `UniformLightSampler` 中的实现类似。
]

