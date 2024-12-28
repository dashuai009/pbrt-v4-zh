#import "../template.typ": parec, ez_caption

== Infinite Area Lights
<infinite-area-lights>


#parec[
  Another useful kind of light is an infinitely far-away area light source that surrounds the entire scene. One way to visualize this type of light is as an enormous sphere that casts light into the scene from every direction. One important use of infinite area lights is for #emph[environment lighting];, where an image of the illumination in an environment is used to illuminate synthetic objects as if they were in that environment. @fig:tt-area-vs-morning compares illuminating a car model with standard area lights to illuminating it with two environment maps that simulate illumination from the sky at different times of day. The increase in realism is striking.
][
  另一种有用的光源是一个无限远的面积光源，它包围整个场景。可以将这种光源想象成一个巨大的球体，从各个方向向场景投射光线。无限远面积光源的一个重要用途是#emph[环境光照明];，其中使用环境光照的图像来照亮合成对象，就像它们在该环境中一样。 @fig:tt-area-vs-morning 比较了用标准面积光照亮汽车模型与用两个环境光贴图模拟不同时间天空照明的效果。真实感的提升是显著的。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f16.svg"),
  caption: [
    #ez_caption[
      Car model (a) illuminated with a few area lights, (b) illuminated with midday skylight from an environment map, (c) using a sunset environment map. (Model courtesy of Yasutoshi Mori.)
    ][
      汽车模型：(a) 使用少量区域光照明；(b) 使用环境贴图中的正午天空光照明；(c) 使用环境贴图中的日落光照明。（模型由 Yasutoshi Mori 提供。）
    ]
  ],
)<tt-area-vs-morning>

#parec[
  `pbrt` provides three implementations of infinite area lights of progressive complexity. The first describes an infinite light with uniform emitted radiance; the second instead takes an image that represents the directional distribution of emitted radiance, and the third adds capabilities for culling parts of such images that are occluded at the reference point, which can substantially improve sampling efficiency.
][
  `pbrt` 提供了三种复杂度递进的无限远面积光源实现。第一种描述了一个具有均匀辐射亮度的无限光源；第二种则使用一幅图像来表示发射辐射亮度的方向分布，第三种增加了剔除在参考点被遮挡的图像部分的功能，这可以显著提高采样效率。
]

=== Uniform Infinite Lights
<uniform-infinite-lights>


#parec[
  A uniform infinite light source is fairly easy to implement; some of the details will be helpful for understanding the infinite light variants to follow.
][
  实现一个均匀无限光源相对简单；其中的一些细节有助于理解后续的无限光源变体。
]

```cpp
class UniformInfiniteLight : public LightBase {
  public:
    UniformInfiniteLight(const Transform &renderFromLight, Spectrum Lemit,
                         Float scale);

    void Preprocess(const Bounds3f &sceneBounds) {
        sceneBounds.BoundingSphere(&sceneCenter, &sceneRadius);
    }

    SampledSpectrum Phi(SampledWavelengths lambda) const;

    PBRT_CPU_GPU
    SampledSpectrum Le(const Ray &ray, const SampledWavelengths &lambda) const;
    PBRT_CPU_GPU
    pstd::optional<LightLiSample> SampleLi(LightSampleContext ctx, Point2f u,
                                            SampledWavelengths lambda, bool allowIncompletePDF) const;
    PBRT_CPU_GPU
    Float PDF_Li(LightSampleContext, Vector3f, bool allowIncompletePDF) const;

    PBRT_CPU_GPU
    pstd::optional<LightLeSample> SampleLe(Point2f u1, Point2f u2,
                                            SampledWavelengths &lambda,
                                            Float time) const;
    PBRT_CPU_GPU
    void PDF_Le(const Ray &, Float *pdfPos, Float *pdfDir) const;

    PBRT_CPU_GPU
    void PDF_Le(const Interaction &, Vector3f w, Float *pdfPos, Float *pdfDir) const {
        LOG_FATAL("Shouldn't be called for non-area lights");
    }

    pstd::optional<LightBounds> Bounds() const { return {}; }

    std::string ToString() const;
  private:
    const DenselySampledSpectrum *Lemit;
    Float scale;
    Point3f sceneCenter;
    Float sceneRadius;
};
```

#parec[
  Emitted radiance is specified as usual by both a spectrum and a separate scale. (The straightforward constructor that initializes these is not included in the text.)
][
  发射辐射亮度通常由光谱和一个单独的比例指定。（初始化这些的简单构造函数未包含在文本中。）
]

```cpp
<<UniformInfiniteLight Private Members>>=
const DenselySampledSpectrum *Lemit;
Float scale;
```

#parec[
  All the infinite light sources, including #link("<UniformInfiniteLight>")[UniformInfiniteLight];, store a bounding sphere of the scene that they use when computing their total power and for sampling rays leaving the light.
][
  所有无限光源，包括 #link("<UniformInfiniteLight>")[UniformInfiniteLight];，都存储了场景的一个包围球体，用于计算其总功率和采样从光源发出的光线。
]

```cpp
<<UniformInfiniteLight Private Members>>+=
Point3f sceneCenter;
Float sceneRadius;
```

#parec[
  Infinite lights must implement the following `Le()` method to return their emitted radiance for a given ray. Since the #link("<UniformInfiniteLight>")[UniformInfiniteLight] emits the same amount for all rays, the implementation is trivial.
][
  无限光源必须实现以下 `Le()` 方法，以返回给定光线的发射辐射亮度。由于 #link("<UniformInfiniteLight>")[UniformInfiniteLight] 对所有光线发射相同的量，因此实现非常简单。
]

```cpp
SampledSpectrum
UniformInfiniteLight::Le(const Ray &ray,
                         const SampledWavelengths &lambda) const {
    return scale * Lemit->Sample(lambda);
}
```


#parec[
  We can see the use of the `allowIncompletePDF` parameter for the first time in the `SampleLi()` method. If it is `true`, then #link("<UniformInfiniteLight>")[UniformInfiniteLight] immediately returns an unset sample. (And its `PDF_Li()` method, described a bit later, will return a PDF of zero for all directions.) To understand why it is implemented in this way, consider the direct lighting integral
][
  我们可以在 `SampleLi()` 方法中首次看到 `allowIncompletePDF` 参数的使用。如果它为 `true`，那么 #link("<UniformInfiniteLight>")[UniformInfiniteLight] 立即返回一个未设置的样本。（稍后描述的其 `PDF_Li()` 方法将为所有方向返回零的PDF。） 要理解为什么这样实现，请考虑直接光照积分
]

$ integral_(cal(S)^2) f_B (p , omega_o , omega_i) L_i (p , omega_i) lr(|cos theta_i|) d omega_i . $


#parec[
  For a uniform infinite light, the incident radiance function is a constant times the visibility term; the constant can be pulled out of the integral, leaving
][
  对于均匀无限光源，入射辐射亮度函数是一个常数乘以可见性项；常数可以从积分中提取出来，剩下
]

$ c integral_(cal(S)^2) f (p , omega_o , omega_i) lr(|cos theta_i|) d omega_i . $


#parec[
  There is no reason for the light to participate in sampling this integral, since BSDF sampling accounts for the remaining factors well. Furthermore, recall from @multiple-importance-sampling that multiple importance sampling (MIS) can increase variance when one of the sampling techniques is much more effective than the others. This is such a case, so as long as calling code is sampling the BSDF and using MIS, samples should not be generated here. (This is an application of MIS compensation, which was introduced in @multiple-importance-sampling.)
][
  没有理由让光源参与采样这个积分，因为BSDF采样很好地考虑了剩余因素。此外，回忆@multiple-importance-sampling 中提到的多重重要性采样（MIS），当一种采样技术比其他技术更有效时，MIS可能会增加方差。 这就是这种情况，因此只要调用代码正在采样BSDF并使用MIS，就不应在此生成样本。（这是多重重要性采样补偿的应用，已在@multiple-importance-sampling 中介绍。）
]

```cpp
pstd::optional<LightLiSample>
UniformInfiniteLight::SampleLi(LightSampleContext ctx, Point2f u,
        SampledWavelengths lambda, bool allowIncompletePDF) const {
    if (allowIncompletePDF) return {};
    Vector3f wi = SampleUniformSphere(u);
    Float pdf = UniformSpherePDF();
    return LightLiSample(scale * Lemit->Sample(lambda), wi, pdf,
           Interaction(ctx.p() + wi * (2 * sceneRadius), &mediumInterface));
}
```

#parec[
  If sampling is to be performed, the light generates a sample so that valid Monte Carlo estimates can still be computed. This task is easy—all directions are sampled with uniform probability. Note that the endpoint of the shadow ray is set in the same way as it was by the #link("../Light_Sources/Distant_Lights.html#DistantLight")[`DistantLight`];: by computing a point that is certainly outside of the scene's bounds.
][
  如果要进行采样，光源会生成一个样本，以便仍然可以计算有效的蒙特卡罗估计（蒙特卡罗估计是一种统计估计方法）。这项任务很简单——所有方向都以均匀概率进行采样。 注意，阴影射线的终点设置方式与 #link("../Light_Sources/Distant_Lights.html#DistantLight")[`DistantLight`];（远光源）相同：通过计算一个肯定在场景边界之外的点。
]

```cpp
<<Return uniform spherical sample for uniform infinite light>>=
Vector3f wi = SampleUniformSphere(u);
Float pdf = UniformSpherePDF();
return LightLiSample(scale * Lemit->Sample(lambda), wi, pdf,
    Interaction(ctx.p() + wi * (2 * sceneRadius), &mediumInterface));
```


#parec[
  The `PDF_Li()` method must account for the value of `allowIncompletePDF` so that the PDF values it returns are consistent with its sampling method.
][
  `PDF_Li()` 方法必须考虑 `allowIncompletePDF` 的值，以便其返回的PDF值与其采样方法一致。
]

```cpp
Float UniformInfiniteLight::PDF_Li(LightSampleContext ctx, Vector3f w,
                                   bool allowIncompletePDF) const {
    if (allowIncompletePDF) return 0;
    return UniformSpherePDF();
}
```


#parec[
  The total power from an infinite light can be found by taking the product of the integral of the incident radiance over all directions times an integral over the area of the disk, along the lines of #link("../Light_Sources/Distant_Lights.html#DistantLight::Phi")[`DistantLight::Phi()`];.
][
  可以通过将入射辐射亮度在所有方向上的积分乘以圆盘表面积上的积分来找到无限光源的总功率（光源的总能量），类似于 #link("../Light_Sources/Distant_Lights.html#DistantLight::Phi")[`DistantLight::Phi()`];。
]

```cpp
<<UniformInfiniteLight Method Definitions>>+=
SampledSpectrum
UniformInfiniteLight::Phi(SampledWavelengths lambda) const {
    return 4 * Pi * Pi * Sqr(sceneRadius) * scale * Lemit->Sample(lambda);
}
```


=== Image Infinite Lights
<image-infinite-lights>
#parec[
  ImageInfiniteLight is a useful infinite light variation that uses an Image to define the directional distribution of emitted radiance. Given an image that represents the distribution of incident radiance in a real-world environment (sometimes called an environment map), this light can be used to render objects under the same illumination, which is particularly useful for applications like visual effects for movies, where it is often necessary to composite rendered objects with film footage. (See the "Further Reading" section for information about techniques for capturing this lighting data from real-world environments.)
][
  `ImageInfiniteLight` 是一种有用的无限光源变体，它使用 #link("../Utilities/Images.html#Image")[`Image`] 来定义发射辐射亮度的方向分布。 给定一个表示真实世界环境中入射辐射分布的图像（有时称为#emph[环境贴图];），这种光源可以用于在相同的照明下渲染物体，这对于电影视觉效果等应用特别有用，因为通常需要将渲染的物体与电影画面合成。 （有关从真实世界环境中捕获此照明数据的技术信息，请参见“进一步阅读”部分。）
]

#parec[
  Figure 12.17 shows the image radiance maps used in Figure 12.16.
][
  图 #link("<fig:tt-skylights>")[12.17] 显示了图 #link("<fig:tt-area-vs-morning>")[12.16] 中使用的图像辐射贴图。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f17.svg"),
  caption: [
    #ez_caption[
      Environment Maps Used for Illumination in Figure 12.16. All use the octahedral mapping and equal-area parameterization of the sphere from Section 3.8.3. (a) Midday and (b) sunset sky. (Midday environment map courtesy of Sergej Majboroda, sunset environment map courtesy of Greg Zaal, both via Poly Haven.)
    ][
      图 12.16 中用于照明的环境贴图。所有贴图均采用第 3.8.3 节中介绍的八面体映射和等面积球体参数化。(a) 正午天空，(b) 日落天空。（正午环境贴图由 Sergej Majboroda 提供，日落环境贴图由 Greg Zaal 提供，均来自 Poly Haven。）
    ]
  ],
)<tt-skylights>

```cpp
<<ImageInfiniteLight Definition>>=
class ImageInfiniteLight : public LightBase {
  public:
    <<ImageInfiniteLight Public Methods>>
  private:
    <<ImageInfiniteLight Private Methods>>
    <<ImageInfiniteLight Private Members>>
};
```

#parec[
  The image that specifies the emission distribution should use the equal-area octahedral parameterization of directions that was defined in @spherical-parameterizations . The `LightBase::renderFromLight` transformation can be used to orient the environment map.
][
  指定发射分布的图像应使用@spherical-parameterizations 中定义的方向的等面积八面体参数化。 可以使用 #link("../Light_Sources/Light_Interface.html#LightBase::renderFromLight")[`LightBase::renderFromLight`] 变换来定向环境贴图。
]

```cpp
<<ImageInfiniteLight Private Members>>=
Image image;
const RGBColorSpace *imageColorSpace;
Float scale;
```

#parec[
  Like `UniformInfiniteLight`s, ImageInfiniteLights also need the scene bounds; here again, the `Preprocess()` method (this one not included in the text) stores the scene's bounding sphere after all the scene geometry has been created.
][
  与 #link("<UniformInfiniteLight>")[`UniformInfiniteLight`] 类似，`ImageInfiniteLight` 也需要场景边界；这里同样，`Preprocess()` 方法（本文中未包含）在创建所有场景几何体后存储场景的包围球。
]

```cpp
<<ImageInfiniteLight Private Members>>+=
Point3f sceneCenter;
Float sceneRadius;
```

#parec[
  The ImageInfiniteLight constructor contains a fair amount of boilerplate code that we will skip past. (For example, it verifies that the provided image has channels named "R," "G," and "B" and issues an error if it does not.) The interesting parts of it are gathered in the following fragment.
][
  `ImageInfiniteLight` 构造函数包含大量样板代码，我们将跳过。 （例如，它验证提供的图像是否具有名为“R”、"G"和“B”的通道，如果没有，则发出错误。） 其有趣的部分如下所示。
]
```cpp
<<ImageInfiniteLight constructor implementation>>=
<<Initialize sampling PDFs for image infinite area light>>
<<Initialize compensated PDF for image infinite area light>>
```

#parec[
  The image maps used with `ImageInfiniteLight`s often have substantial variation along different directions: consider, for example, an environment map of the sky during daytime, where the relatively small number of directions that the sun subtends are thousands of times brighter than the rest of the directions. Therefore, implementing a sampling method for `ImageInfiniteLight`s that matches the illumination distribution can significantly reduce variance in rendered images compared to sampling directions uniformly. To this end, the constructor initializes a `PiecewiseConstant2D` distribution that is proportional to the image pixel values.
][
  用于 `ImageInfiniteLight` 的图像贴图通常在不同方向上有显著的变化：例如，考虑白天天空的环境贴图，其中太阳所覆盖的相对较少的方向比其他方向亮数千倍。 因此，实现一种与照明分布相匹配的 #link("<ImageInfiniteLight>")[`ImageInfiniteLight`] 采样方法可以显著减少渲染图像中的方差，相比于均匀采样方向。 为此，构造函数初始化了一个 #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`] 分布，该分布与图像像素值成比例。
]


```cpp
<<Initialize sampling PDFs for image infinite area light>>=
Array2D<Float> d = image.GetSamplingDistribution();
Bounds2f domain = Bounds2f(Point2f(0, 0), Point2f(1, 1));
distribution = PiecewiseConstant2D(d, domain, alloc);

<<ImageInfiniteLight Private Members>>+=
PiecewiseConstant2D distribution;
```

#parec[
  A second sampling distribution is computed based on a thresholded version of the image where the average pixel value is subtracted from each pixel's sampling weight. The use of both of these sampling distributions will be discussed in more detail shortly, with the implementation of the `SampleLi()` method.
][
  基于图像的阈值版本计算第二个采样分布，其中从每个像素的采样权重中减去平均像素值。 稍后将在 `SampleLi()` 方法的实现中更详细地讨论这两个采样分布的使用。
]


```cpp
<<Initialize compensated PDF for image infinite area light>>=
Float average = std::accumulate(d.begin(), d.end(), 0.) / d.size();
for (Float &v : d)
    v = std::max<Float>(v - average, 0);
compensatedDistribution = PiecewiseConstant2D(d, domain, alloc);

<<ImageInfiniteLight Private Members>>+=
PiecewiseConstant2D compensatedDistribution;
```

#parec[
  Before we get to the sampling methods, we will provide an implementation of the `Le()` method that is required by the Light interface for infinite lights. After computing the 2D coordinates of the provided ray's direction in image coordinates, it defers to the `ImageLe()` method.
][
  在我们进入采样方法之前，我们将提供 `Le()` 方法的实现，该方法是 #link("../Light_Sources/Light_Interface.html#Light")[`Light`] 接口对无限光源的要求。 在计算提供的光线方向在图像坐标中的二维坐标后，它委托给 `ImageLe()` 方法。
]

```cpp
<<ImageInfiniteLight Public Methods>>=
SampledSpectrum Le(const Ray &ray, const SampledWavelengths &lambda) const {
    Vector3f wLight = Normalize(renderFromLight.ApplyInverse(ray.d));
    Point2f uv = EqualAreaSphereToSquare(wLight);
    return ImageLe(uv, lambda);
}
```

#parec[
  `ImageLe()` returns the emitted radiance for a given point in the image.
][
  `ImageLe()` 返回图像中给定点的发射辐射。
]

```cpp
SampledSpectrum ImageLe(Point2f uv,
                        const SampledWavelengths &lambda) const {
    RGB rgb;
    for (int c = 0; c < 3; ++c)
        rgb[c] = image.LookupNearestChannel(uv, c,
                                            WrapMode::OctahedralSphere);
    RGBIlluminantSpectrum spec(*imageColorSpace, ClampZero(rgb));
    return scale * spec.Sample(lambda);
}
```

#parec[
  There is a bit more work to do for sampling an incident direction at a reference point according to the light's emitted radiance.
][
  对于根据光源的发射辐射在参考点采样入射方向，还有一些工作要做。
]
```cpp
<<ImageInfiniteLight Public Methods>>+=
pstd::optional<LightLiSample>
SampleLi(LightSampleContext ctx, Point2f u, SampledWavelengths lambda,
         bool allowIncompletePDF) const {
    <<Find  sample coordinates in infinite light texture>>
    <<Convert infinite light sample point to direction>>
    <<Compute PDF for sampled infinite light direction>>
    <<Return radiance value for infinite light direction>>
}
```

#parec[
  The first step is to generate an image sample with probability proportional to the image pixel values, which is a task that is handled by the `PiecewiseConstant2D` `Sample()` method. If `SampleLi()` is called with allowIncompletePDF being true, then the second sampling distribution that was based on the thresholded image is used. The motivation for doing so is the same as when `UniformInfiniteLight::SampleLi()` does not generate samples at all in that case: here, there is no reason to spend samples in parts of the image that have a relatively low contribution. It is better to let other sampling techniques (e.g., BSDF sampling) generate samples in those directions when they are actually important for the full function being integrated. Light samples are then allocated to the bright parts of the image, where they are more useful.
][
  第一步是生成一个图像样本，其概率与图像像素值成正比，这个任务由 #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`] 的 `Sample()` 方法处理。 如果 `SampleLi()` 被调用时 `allowIncompletePDF` 为 `true`，则使用基于阈值图像的第二个采样分布。 这样做的动机与 #link("<UniformInfiniteLight::SampleLi>")[`UniformInfiniteLight::SampleLi()`] 在这种情况下不生成样本的原因相同：在这种情况下，没有必要在对图像贡献较低的部分上浪费样本。 更好的是让其他采样技术（例如，BSDF 采样）在这些方向上实际重要时生成样本。 然后将光样本分配到图像的亮部，在那里它们更有用。
]

```cpp
<<Find  sample coordinates in infinite light texture>>=
Float mapPDF = 0;
Point2f uv;
if (allowIncompletePDF)
    uv = compensatedDistribution.Sample(u, &mapPDF);
else
    uv = distribution.Sample(u, &mapPDF);
if (mapPDF == 0)
    return {};
```

#parec[
  It is a simple matter to convert from image coordinates to a rendering space direction wi.
][
  从图像坐标转换到渲染空间方向 `wi` 是一件简单的事情。
]

```cpp
<<Convert infinite light sample point to direction>>=
Vector3f wLight = EqualAreaSquareToSphere(uv);
Vector3f wi = renderFromLight(wLight);
```

#parec[
  The PDF returned by `PiecewiseConstant2D::Sample()` is with respect to the image's $[0, 1\]^2$ domain. To find the corresponding PDF with respect to direction, the change of variables factor for going from the unit square to the unit sphere $1\/(4pi)$ must be applied.
][
  #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D::Sample")[`PiecewiseConstant2D::Sample()`] 返回的 PDF 是关于图像的 $[0, 1\]^2$ 域的。 为了将图像坐标的 PDF 转换为方向的 PDF，必须应用从单位方到单位球的变化因子 $1\/(4pi)$。
]


```cpp
<<Compute PDF for sampled infinite light direction>>=
Float pdf = mapPDF / (4 * Pi);
```

#parec[
  Finally, as with the `DistantLight` and `UniformInfiniteLight`, the second point for the shadow ray is found by offsetting along the `wi` direction far enough until that resulting point is certainly outside of the scene's bounds.
][
  最后，与 #link("../Light_Sources/Distant_Lights.html#DistantLight")[`DistantLight`] 和 #link("<UniformInfiniteLight>")[`UniformInfiniteLight`] 一样，通过沿 `wi` 方向偏移找到阴影光线的第二个点，直到该结果点肯定在场景边界之外。
]

```cpp
<<Return radiance value for infinite light direction>>=
return LightLiSample(ImageLe(uv, lambda), wi, pdf,
    Interaction(ctx.p() + wi * (2 * sceneRadius), &mediumInterface));
```

#parec[
  Figure 12.18 illustrates how much error is reduced by sampling image infinite lights well. It compares three images of a dragon model illuminated by the morning skylight environment map from Figure 12.17. The first image was rendered using a simple uniform spherical sampling distribution for selecting incident illumination directions, the second used the full image-based sampling distribution, and the third used the compensated distribution—all rendered with 32 samples per pixel. For the same number of samples taken and with negligible additional computational cost, both importance sampling methods give a much better result with much lower variance.
][
  图 #link("<fig:tt-env-light-comparison>")[12.18] 说明了通过良好采样图像无限光源可以减少多少误差。 它比较了三幅由图 #link("<fig:tt-skylights>")[12.17] 中的晨光环境贴图照明的龙模型图像。 第一幅图像使用简单的均匀球面采样分布选择入射照明方向渲染，第二幅使用完整的基于图像的采样分布，第三幅使用补偿分布——所有图像均以每像素 32 个样本渲染。 在相同数量的样本下，几乎没有额外的计算成本，两个重要性采样方法都提供了更好的结果，且方差更低。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f18.svg"),
  caption: [
    #ez_caption[
      Dragon Model Illuminated by the Morning Skylight Environment Map. All images were rendered with 32 samples per pixel. (a) Rendered using a uniform sampling distribution. (b) Rendered with samples distributed according to environment map image pixels. (c) Rendered using the compensated distribution that skips sampling unimportant parts of the image. All images took essentially the same amount of time to render, though (b) has over 38,000 times lower MSE than (a), and (c) further improves MSE by a factor of 1.52. (Dragon model courtesy of the Stanford Computer Graphics Laboratory.)
    ][
      龙模型在晨间天光环境贴图照明下的渲染效果。所有图像均使用每像素 32 个样本进行渲染。(a) 使用均匀采样分布渲染。(b) 使用基于环境贴图像素分布的采样渲染。(c) 使用补偿分布渲染，该分布跳过对图像中不重要部分的采样。尽管所有图像的渲染时间基本相同，但 (b) 的均方误差（MSE）比 (a) 低 38,000 倍以上，而 (c) 的均方误差进一步改善了 1.52 倍。（龙模型由斯坦福计算机图形实验室提供。）
    ]
  ],
)<tt-env-light-comparison>


#parec[
  Most of the work to compute the PDF for a provided direction is handled by the PiecewiseConstant2D distribution. Here as well, the PDF value it returns is divided by 4 to account for the area of the unit sphere.
][
  计算给定方向的 PDF 的大部分工作由 #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`] 分布处理。 在这里，PDF 值也除以 4 以考虑单位球的面积。
]

```cpp
<<ImageInfiniteLight Method Definitions>>=
Float ImageInfiniteLight::PDF_Li(LightSampleContext ctx, Vector3f w,
                                 bool allowIncompletePDF) const {
    Vector3f wLight = renderFromLight.ApplyInverse(w);
    Point2f uv = EqualAreaSphereToSquare(wLight);
    Float pdf = 0;
    if (allowIncompletePDF)
        pdf = compensatedDistribution.PDF(uv);
    else
        pdf = distribution.PDF(uv);
    return pdf / (4 * Pi);
}
```


#parec[
  The `ImageInfiniteLight::Phi()` method, not included here, integrates incident radiance over the sphere by looping over all the image pixels and summing them before multiplying by a factor of $4pi$ to account for the area of the unit sphere as well as by the area of a disk of radius sceneRadius.
][
  `ImageInfiniteLight::Phi()` 方法（此处未包括）通过遍历所有图像像素并求和以积分球面上的入射辐射度，然后乘以一个系数 $4pi$，该系数用于考虑单位球的面积以及半径为 `sceneRadius` 的圆盘的面积。
]


=== Portal Image Infinite Lights


#parec[
  `ImageInfiniteLight`s provide a handy sort of light source, though one shortcoming of that class's implementation is that it does not account for visibility in its sampling routines. Samples that it generates that turn out to be occluded are much less useful than those that do carry illumination to the reference point. While the expense of ray tracing is necessary to fully account for visibility, accounting for even some visibility effects in light sampling can significantly reduce error.
][
  `ImageInfiniteLight`s 提供了一种便捷的光源类型，但该类实现方法的一个缺点是它在采样过程中没有考虑可见性。 生成的样本如果被遮挡，其效用远不如那些能够将光照传递到参考点的样本。 完全考虑可见性需要光线追踪的开销，但在光采样中考虑一些可见性效果可以显著减少误差。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f19.svg"),
  caption: [
    #ez_caption[
      Watercolor Scene Illuminated by a Daytime Sky Environment Map. This is a challenging scene to render since the direct lighting calculation only finds illumination when it samples a ray that passes through the window. (a) When rendered with the ImageInfiniteLight and 16 samples per pixel, error is high because the environment map includes a bright sun, though it does not illuminate all parts of the room. For such points, none of the many samples taken toward the sun has any contribution. (b) When rendered using the PortalImageInfiniteLight, results are much better with the same number of samples because the light is able to sample just the part of the environment map that is visible through the window. In this case, MSE is reduced by a factor of 2.82. (Scene courtesy of Angelo Ferretti.)
    ][
      水彩场景在白天天空环境贴图的照明下的渲染效果。这是一个具有挑战性的渲染场景，因为直接光照计算只有在采样的光线穿过窗户时才能捕捉到照明。(a) 使用 `ImageInfiniteLight` 和每像素 16 个样本进行渲染时，由于环境贴图包含一个明亮的太阳，而太阳光并未照亮房间的所有部分，因此误差很大。对于这些未被太阳光直接照亮的点，面向太阳方向的许多采样均无贡献。(b) 使用 `PortalImageInfiniteLight` 渲染时，在相同数量的样本下，结果显著改善，因为光源能够仅对通过窗户可见的环境贴图部分进行采样。在这种情况下，均方误差（MSE）减少了 2.82 倍。（场景由 Angelo Ferretti 提供。）
    ]
  ],
)<watercolor-sky-env-map>

#parec[
  Consider the scene shown in @fig:watercolor-sky-env-map, where all the illumination is coming from a skylight environment map that is visible only through the windows. Part of the scene is directly illuminated by the sun, but much of it is not. Those other parts are still illuminated, but by much less bright regions of blue sky. Yet because the sun is so bright, the `ImageInfiniteLight` ends up taking many samples in its direction, though all the ones where the sun is not visible through the window will be wasted. In those regions of the scene, light sampling will occasionally choose a part of the sky that is visible through the window and occasionally BSDF sampling will find a path to the light through the window, so that the result is still correct in expectation, but many samples may be necessary to achieve a high-quality result.
][
  请参考@fig:watercolor-sky-env-map 所示场景，其中所有光照均来自一个只能通过窗户看到的天光环境贴图。场景的一部分受到太阳的直接照射，但大部分区域未被直接照亮。这些未被直接照亮的区域仍然受到光照，但主要来源于亮度较低的蓝天区域。然而，由于太阳非常明亮，`ImageInfiniteLight` 会在太阳方向采集许多样本，而所有未通过窗户看到太阳的采样都会被浪费。在场景的这些区域中，光采样偶尔会选择通过窗户可见的天空部分，同时 BSDF 采样也可能偶尔找到穿过窗户到达光源的路径，因此最终的结果在期望上仍然是正确的，但可能需要大量样本才能获得高质量的结果。
]

#parec[
  The `PortalImageInfiniteLight` is designed to handle this situation more effectively. Given a user-specified *portal*, a quadrilateral region through which the environment map is potentially visible, it generates a custom sampling distribution at each point being shaded so that it can draw samples according to the region of the environment map that is visible through the portal. For an equal number of samples, this can be much more effective than the `ImageInfiniteLight`'s approach, as shown in @fig:watercolor-sky-env-map(b).
][
  `PortalImageInfiniteLight` 针对这种情况设计得更为有效。通过用户指定的*门户*（一个可能显示环境贴图的四边形区域），它在每个被着色点生成一个定制的采样分布，以便根据通过门户可见的环境贴图区域进行采样。对于相同数量的样本，这种方法比 `ImageInfiniteLight` 的方式要高效得多，如 @fig:watercolor-sky-env-map(b) 所示。
]

```cpp
<<PortalImageInfiniteLight Definition>>=
class PortalImageInfiniteLight : public LightBase {
  public:
    <<PortalImageInfiniteLight Public Methods>>
  private:
    <<PortalImageInfiniteLight Private Methods>>
    <<PortalImageInfiniteLight Private Members>>
};
```

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f20.svg"),
  caption: [
    #ez_caption[
      Given a scene with a portal (opening in the box), for each point in the scene we can find the set of directions that pass through the portal. To sample illumination efficiently, we would like to only sample from the corresponding visible region of the environment map (thick segment on the sphere).
    ][
      对于一个带有门户（盒子中的开口）的场景，对于场景中的每个点，我们可以找到穿过该门户的方向集合。为了高效地采样光照，我们希望仅从环境贴图中对应的可见区域（球面上的粗线段）进行采样。
    ]
  ],
)<portal-directions-to-map>

#parec[
  Given a portal and a point in the scene, there is a set of directions from that point that pass through the portal. If we can find the corresponding region of the environment map, then our task is to sample from it according to the environment map's emission. This idea is illustrated in @fig:portal-directions-to-map. With the equal-area mapping, the shape of the visible region of the environment map seen from a given point can be complex. The problem is illustrated in @fig:portal-visible-env-map-regions(a), which visualizes the visible regions from two points in the scene from @fig:watercolor-sky-env-map.
][

]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f21.svg"),
  caption: [
    #ez_caption[
      Shapes of Visible Regions of an Environment Map as Seen through a Portal. These images illustrate the visible regions of the environment map as seen through the window for a point on the floor and a point on one of the paintings on the wall for the scene in @fig:watercolor-sky-env-map. (a) The equal-area mapping used by the ImageInfiniteLight is convenient for sampling the entire environment map, but it leads to the portal-visible regions having complex shapes. (b) With the directional parameterization used by the PortalImageInfiniteLight, the visible region is always rectangular, which makes it feasible to sample from just that part of it. (Environment map courtesy of Sergej Majboroda, via Poly Haven.)
    ][
      通过门户看到的环境贴图可见区域的形状。 这些图像展示了@fig:watercolor-sky-env-map 场景中，通过窗户从地板上的一点和墙上某幅画的一点看到的环境贴图可见区域。 1. `ImageInfiniteLight` 使用的等面积映射便于对整个环境贴图进行采样，但由此产生的门户可见区域形状复杂。 2. `PortalImageInfiniteLight` 使用的方向参数化方法使得可见区域始终为矩形，从而可以更方便地仅从该部分区域进行采样。 *(环境贴图由 Sergej Majboroda 提供，来源于 Poly Haven。)*
    ]
  ],
)<portal-visible-env-map-regions>


#parec[
  The `PortalImageInfiniteLight` therefore uses a different parameterization of directions that causes the visible region seen through a portal to always be rectangular. Later in this section, we will see how this property makes efficient sampling possible.
][
  因此，`PortalImageInfiniteLight` 使用了一种不同的方向参数化方法，使得通过门户看到的可见区域始终为矩形。在本节稍后，我们将看到这种特性如何使高效采样成为可能。
]

#parec[
  The directional parameterization used by the `PortalImageInfiniteLight` is based on a coordinate system where the $x$ and $y$ axes are aligned with the edges of the portal. Note that the position of the portal is not used in defining this coordinate system—only the directions of its edges. As a first indication that this idea is getting us somewhere, consider the vectors from a point in the scene to the four corners of the portal, transformed into this coordinate system. It should be evident that in this coordinate system, vectors to adjacent vertices of the portal only differ in one of their $x$ or $y$ coordinate values and that the four directions thus span a rectangular region in $x y$. (If this is not clear, it is a detail worth pausing to work through.) We will term directional representations that have this property as *rectified*.
][
  `PortalImageInfiniteLight` 使用的方向参数化基于一个坐标系，其中 $x$ 和 $y$ 轴与门户的边对齐。需要注意的是，定义该坐标系时并未使用门户的位置，仅使用了其边缘的方向。作为验证这一想法有效的初步依据，考虑从场景中的某一点到门户四个角的向量，并将其变换到此坐标系中。可以看出，在此坐标系中，指向门户相邻顶点的向量仅在 $x$ 或 $y$ 坐标值之一上有所不同，因此这四个方向在 $x y$ 平面上形成一个矩形区域。（如果这一点尚不清楚，值得停下来仔细推导一下。）我们将具有这种特性的方向表示称为*整流化（rectified）*。
]
#parec[
  The $x y$ components of vectors in this coordinate system still span $(-oo, oo)$, so it is necessary to map them to a finite 2D domain if the environment map is to be represented using an image. It is important that this mapping does not interfere with the axis-alignment of the portal edges and that rectification is preserved. This requirement rules out a number of possibilities, including both the equirectangular and equal-area mappings. Even normalizing a vector and taking the $x$ and $y$ coordinates of the resulting unit vector is unsuitable given this requirement.
][
  在此坐标系中，向量的 $x y$ 分量仍然覆盖 $(-oo, oo)$，因此为了使用图像表示环境贴图，必须将其映射到有限的二维域。重要的是，此映射不能破坏门户边缘的轴对齐特性，并且必须保持整流化。这一要求排除了许多可能性，包括等距矩形投影（equirectangular mapping）和等面积映射（equal-area mapping）。甚至将向量归一化并取结果单位向量的 $x$ 和 $y$ 坐标的方式也不符合这一要求。
]

#parec[
  A mapping that does work is based on the angles $alpha$ and $beta$ that the $x$ and $y$ coordinates of the vector respectively make with the $z$ axis, as illustrated in @fig:portal-vector-angles. These angles are given by:
][
  一种可行的映射方法是基于向量的 $x$ 和 $y$ 坐标分别与 $z$ 轴形成的角度 $alpha$ 和 $beta$，如@fig:portal-vector-angles 所示。这些角度由以下公式给出：
]
$ (alpha , beta) = (arctan (x / z) , arctan (y / z)) . $ <portal-alpha-beta>

#parec[
  We can ignore vectors with negative $z$ components in the rectified coordinate system: they face away from the portal and thus do not receive any illumination. Each of $alpha$ and $beta$ then spans the range $[frac(- pi, 2) , pi / 2]$ and the pair of them can be easily mapped to $[0 , 1]^2 med (u , v)$ image coordinates. The environment map resampled into this parameterization is shown in @fig:portal-visible-env-map-regions(b), with the visible regions for the same two points in the scene indicated.
][
  在校正坐标系中，我们可以忽略 $z$ 分量为负的向量，因为它们背对传送门，所以不会接收到任何光照。因此， $alpha$ 和 $beta$ 的范围是 $[frac(- pi, 2) , pi / 2]$，并且它们可以轻松映射到 $[0 , 1]^2 med (u , v)$ 图像坐标中。重新采样到该参数化中的环境图如@fig:portal-visible-env-map-regions(b) 所示，场景中相同两个点的可见区域已标出。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f21.svg"),
  caption: [
    #ez_caption[
      Vectors in the portal’s coordinate system can be represented by a pair
      of angles $(alpha , beta)$ that measure the angle made by the $x$ or $y$
      component, respectively, with the $z$ axis.
    ][
      在传送门的坐标系中，向量可以用一对角度 $(alpha , beta)$ 表示，分别测量
      $x$ 或 $y$ 分量与 $z$ 轴所成的角度。
    ]
  ],
)<portal-vector-angles>


#parec[
  We will start the implementation of the `PortalImageInfiniteLight` with its `ImageFromRender()` method, which applies this mapping to a vector in the rendering coordinate system wRender. (We will come to the initialization of the portalFrame member variable in the `PortalImageInfiniteLight` constructor later in this section.) It uses pstd::optional for the return value in order to be able to return an invalid result in the case that the vector is coplanar with the portal or facing away from it.
][
  我们将从 `PortalImageInfiniteLight` 的 `ImageFromRender()` 方法的实现开始，该方法将此映射应用于渲染坐标系 wRender 中的向量。（我们将在本节后面讨论 `PortalImageInfiniteLight` 构造函数中 portalFrame 成员变量的初始化。）它使用 `pstd::optional` 作为返回值，以便在向量与传送门共面或背向传送门时返回无效结果。
]

```cpp
<<PortalImageInfiniteLight Private Methods>>=
pstd::optional<Point2f> ImageFromRender(Vector3f wRender,
                                        Float *duv_dw = nullptr) const {
    Vector3f w = portalFrame.ToLocal(wRender);
    if (w.z <= 0) return {};
    <<Compute Jacobian determinant of mapping  if needed>>
    Float alpha = std::atan2(w.x, w.z), beta = std::atan2(w.y, w.z);
    return Point2f(Clamp((alpha + Pi / 2) / Pi, 0, 1),
                   Clamp((beta + Pi / 2) / Pi, 0, 1));
}
```

#parec[
  We will find it useful to be able to convert sampling densities from the $(u , v)$ parameterization of the image to be with respect to solid angle on the unit sphere. The appropriate factor can be found following the usual approach of computing the determinant of the Jacobian of the mapping function, which is based on @eqt:portal-alpha-beta, and then rescaling the coordinates to image coordinates in $[0 , 1]^2$. The result is a simple expression when expressed in terms of $omega$ :
][
  我们会发现，将图像的 $(u , v)$ 参数化的采样密度转换为单位球面上的立体角是非常有用的。可以通过计算映射函数的雅可比行列式来找到适当的因子，这基于@eqt:portal-alpha-beta，然后将坐标重新缩放到 $[0 , 1]^2$ 的图像坐标中。结果是一个简单的表达式，当用 $omega$ 表示时：
]


$ frac(d (u , v), d omega_B) = pi^2 frac((1 - omega_(B_x)^2) (1 - omega_(B_y)^2), omega_B z) $


#parec[
  If a non-`nullptr` `duv_dw` parameter is passed to this method, this factor is returned.
][
  如果传递给此方法的参数 `duv_dw` 不是 `nullptr`，则返回此因子。
]
```cpp
<<Compute Jacobian determinant of mapping  if needed>>=
if (duv_dw)
    *duv_dw = Sqr(Pi) * (1 - Sqr(w.x)) * (1 - Sqr(w.y)) / w.z;
```

#parec[
  The inverse transformation can be found by working in reverse. It is implemented in `RenderFromImage()`, which also optionally returns the same change of variables factor.
][
  逆变换可以通过反向操作找到。它在 `RenderFromImage()` 中实现，该方法还可以选择性地返回相同的变量变换因子。
]

```cpp
<<PortalImageInfiniteLight Private Methods>>+=
Vector3f RenderFromImage(Point2f uv, Float *duv_dw = nullptr) const {
    Float alpha = -Pi / 2 + uv[0] * Pi, beta = -Pi / 2 + uv[1] * Pi;
    Float x = std::tan(alpha), y = std::tan(beta);
    Vector3f w = Normalize(Vector3f(x, y, 1));
    <<Compute Jacobian determinant of mapping  if needed>>
    return portalFrame.FromLocal(w);
}
```

#parec[
  Because the mapping is rectified, we can find the image-space bounding box of the visible region of the environment map from a given point using the coordinates of two opposite portal corners. This method also returns an optional value, for the same reasons as for `ImageFromRender()`.
][
  由于该映射是整流化的，我们可以通过给定点的两个对角门户角的坐标，找到环境贴图可见区域在图像空间中的边界框。此方法还返回一个可选值，原因与 `ImageFromRender()` 相同。
]

```cpp
<<PortalImageInfiniteLight Private Methods>>+=
pstd::optional<Bounds2f> ImageBounds(Point3f p) const {
    pstd::optional<Point2f> p0 = ImageFromRender(Normalize(portal[0] - p));
    pstd::optional<Point2f> p1 = ImageFromRender(Normalize(portal[2] - p));
    if (!p0 || !p1) return {};
    return Bounds2f(*p0, *p1);
}
```

#parec[
  Most of the `PortalImageInfiniteLight` constructor consists of straightforward initialization of member variables from provided parameter values, checking that the provided image has RGB channels, and so forth. All of that has not been included in this text. We will, however, discuss the following three fragments, which run at the end of the constructor.
][
  `PortalImageInfiniteLight` 构造函数的大部分内容是从提供的参数值中直接初始化成员变量，检查提供的图像是否具有 RGB 通道等。所有这些内容在本文中未包括。然而，我们将讨论以下三个片段，它们在构造函数的末尾执行。
]


```cpp
<<PortalImageInfiniteLight constructor conclusion>>=
<<Compute frame for portal coordinate system>>
<<Resample environment map into rectified image>>
<<Initialize sampling distribution for portal image infinite light>>
```

#parec[
  The portal itself is specified by four vertices, given in the rendering coordinate system. Additional code, not shown here, checks to ensure that they describe a planar quadrilateral. A `Frame` for the portal's coordinate system can be found from two normalized adjacent edge vectors of the portal using the `Frame::FromXY()` method.
][
  门户本身由四个顶点指定，这些顶点是在渲染坐标系中给出的。未在此处显示的附加代码检查这些顶点是否描述了一个平面四边形。 可以使用门户的两个标准化相邻边向量，通过 `Frame::FromXY()` 方法来找到门户坐标系的 `Frame` 。
]


```cpp
<<Compute frame for portal coordinate system>>=
Vector3f p01 = Normalize(portal[1] - portal[0]);
Vector3f p03 = Normalize(portal[3] - portal[0]);
portalFrame = Frame::FromXY(p03, p01);

<<PortalImageInfiniteLight Private Members>>=
pstd::array<Point3f, 4> portal;
Frame portalFrame;
```


#parec[
  The constructor also resamples a provided equal-area image into the rectified representation at the same resolution. Because the rectified image depends on the geometry of the portal, it is better to take an equal-area image and resample it in the constructor than to require the user to provide an already-rectified image. In this way, it is easy for the user to change the portal specification just by changing the portal's coordinates in the scene description file.
][
  构造函数还将提供的等面积图像重新采样到整流化表示，并保持相同的分辨率。由于整流化图像依赖于门户的几何形状，因此在构造函数中重新采样一个等面积图像比要求用户提供已整流化的图像更为合适。通过这种方式，用户只需在场景描述文件中更改门户的坐标，就能轻松改变门户的规格。
]


```cpp
<<Resample environment map into rectified image>>=
image = Image(PixelFormat::Float, equalAreaImage.Resolution(),
              {"R", "G", "B"}, equalAreaImage.Encoding(), alloc);
ParallelFor(0, image.Resolution().y, [&](int y) {
    for (int x = 0; x < image.Resolution().x; ++x) {
        <<Resample equalAreaImage to compute rectified image pixel >>
    }
});
```


```cpp
<<PortalImageInfiniteLight Private Members>>+=
Image image;
```

#parec[
  At each rectified image pixel, the implementation first computes the corresponding light-space direction and looks up a bilinearly interpolated value from the equal-area image. No further filtering is performed. A better implementation would use a spatially varying filter here in order to ensure that there was no risk of introducing aliasing due to undersampling the source image.
][
  在每个整流化图像像素处，实现首先计算对应的光空间方向，并从等面积图像中查找一个双线性插值值。此处不执行进一步的滤波。更好的实现应使用空间变化的滤波器，以确保不会由于源图像的欠采样而引入混叠。
]

```cpp
<<Resample equalAreaImage to compute rectified image pixel >>=
<<Find  coordinates in equal-area image for pixel>>
for (int c = 0; c < 3; ++c) {
    Float v = equalAreaImage.BilerpChannel(uvEqui, c,
                                           WrapMode::OctahedralSphere);
    image.SetChannel({x, y}, c, v);
}
```

#parec[
  The image coordinates in the equal-area image can be found by determining the direction vector corresponding to the current pixel in the rectified image and then finding the equal-area image coordinates that this direction maps to.
][
  等面积图像中的图像坐标可以通过确定整流化图像中当前像素对应的方向向量，然后找到该方向映射到的等面积图像坐标来得到。
]

```cpp
<<Find  coordinates in equal-area image for pixel>>=
Point2f uv((x + 0.5f) / image.Resolution().x,
           (y + 0.5f) / image.Resolution().y);
Vector3f w = RenderFromImage(uv);
w = Normalize(renderFromLight.ApplyInverse(w));
Point2f uvEqui = EqualAreaSphereToSquare(w);
```


#parec[
  Given the rectified image, the next step is to initialize an instance of the `WindowedPiecewiseConstant2D` data structure, which performs the sampling operation. (It is defined in Section *A.5.6* .) As its name suggests, it generalizes the functionality of the `PiecewiseConstant2D` class to allow a caller-specified window that limits the sampling region.
][
  给定整流化图像，下一步是初始化一个 `WindowedPiecewiseConstant2D` 数据结构的实例，该结构执行采样操作。（它在 *A.5.6* 中定义。）顾名思义，它将 `PiecewiseConstant2D` 类的功能进行了一般化，允许调用者指定一个窗口来限制采样区域。
]

#parec[
  It is worthwhile to include the change of variables factor $d (u, v) \/ d omega$ at each pixel in the image sampling distribution. Doing so causes the weights associated with image samples to be more uniform, as this factor will nearly cancel the same factor when a sample's PDF is computed. (The cancellation is not exact, as the factor here is computed at the center of each pixel while in the PDF it is computed at the exact sample location.)
][
  在图像采样分布的每个像素中，值得包括变量变换因子 $d (u, v) \/ d omega$ 这样做会使与图像样本相关的权重更加均匀，因为这个因子几乎会与计算样本概率密度函数（PDF）时的相同因子相互抵消。 （这种抵消不是完全精确的，因为这里的因子是在每个像素的中心计算的，而在 PDF 中，它是在精确的样本位置计算的。）
]


```cpp
<<Initialize sampling distribution for portal image infinite light>>=
auto duv_dw = [&](Point2f p) {
    Float duv_dw;
    (void)RenderFromImage(p, &duv_dw);
    return duv_dw;
};
Array2D<Float> d = image.GetSamplingDistribution(duv_dw);
distribution = WindowedPiecewiseConstant2D(d, alloc);

<<PortalImageInfiniteLight Private Members>>+=
WindowedPiecewiseConstant2D distribution;
```

#parec[
  The light's total power can be found by integrating radiance over the hemisphere of directions that can be seen through the portal and then multiplying by the portal's area, since all light that reaches the scene passes through it. The corresponding PortalImageInfiniteLight::Phi() method is not included here, as it boils down to being a matter of looping over the pixels, applying the change of variables factor to account for integration over the unit sphere, and then multiplying the integrated radiance by the portal's area.
][
  光源的总功率可以通过对能量从门户可见的方向半球进行辐射度积分，然后乘以门户的面积来计算，因为所有到达场景的光线都会穿过它。对应的 `PortalImageInfiniteLight::Phi()` 方法在此未包括，因为它归结为循环遍历像素，应用变量变换因子来考虑对单位球面上的积分，然后将积分后的辐射度乘以门户的面积。
]

#parec[
  In order to compute the radiance for a ray that has left the scene, the $(u, v)$ coordinates in the image corresponding to the ray's direction are computed first. The radiance corresponding to those coordinates is returned if they are inside the portal bounds for the ray origin, and a zero-valued spectrum is returned otherwise. (In principle, the Le() method should only be called for rays that have left the scene, so that the portal check should always pass, but it is worth including for the occasional ray that escapes the scene due to a geometric error in the scene model. This way, those end up carrying no radiance rather than causing a light leak.)
][
  为了计算离开场景的光线的辐射度，首先计算与光线方向对应的图像中的 $(u, v)$ 坐标。如果这些坐标位于门户的边界内，则返回对应的辐射度；如果不在边界内，则返回一个零值光谱。（原则上，`Le()` 方法应该只对离开场景的光线调用，因此门户检查应该始终通过，但考虑到场景模型中的几何错误可能导致光线逃离场景，这种情况下仍值得包含这个检查。这样，逃逸的光线最终不会携带辐射度，从而避免光泄漏。）
]

```cpp
<<PortalImageInfiniteLight Method Definitions>>=
SampledSpectrum
PortalImageInfiniteLight::Le(const Ray &ray,
                             const SampledWavelengths &lambda) const {
    pstd::optional<Point2f> uv = ImageFromRender(Normalize(ray.d));
    pstd::optional<Bounds2f> b = ImageBounds(ray.o);
    if (!uv || !b || !Inside(*uv, *b))
        return SampledSpectrum(0.f);
    return ImageLookup(*uv, lambda);
}
```

#parec[
  The `ImageLookup()` method returns the radiance at the given image $(u, v)$ and wavelengths. We encapsulate this functionality in its own method, as it will be useful repeatedly in the remainder of the light's implementation.
][
  `ImageLookup()` 方法返回给定图像 $(u, v)$ 坐标和波长处的辐射度。我们将这一功能封装在它自己的方法中，因为在光源实现的其余部分中，这个功能会被反复使用。
]
```cpp
<<PortalImageInfiniteLight Method Definitions>>+=
SampledSpectrum PortalImageInfiniteLight::ImageLookup(
        Point2f uv, const SampledWavelengths &lambda) const {
    RGB rgb;
    for (int c = 0; c < 3; ++c)
        rgb[c] = image.LookupNearestChannel(uv, c);
    RGBIlluminantSpectrum spec(*imageColorSpace, ClampZero(rgb));
    return scale * spec.Sample(lambda);
}
```

#parec[
  As before, the image's color space must be known in order to convert its RGB values to spectra.
][
  像之前一样，必须知道图像的色彩空间，以便将其 RGB 值转换为光谱。
]

```cpp
<<PortalImageInfiniteLight Private Members>>+=
const RGBColorSpace *imageColorSpace;
Float scale;
```

#parec[
  `SampleLi()` is able to take advantage of the combination of the rectified image representation and the ability of `WindowedPiecewiseConstant2D` to sample a direction from the specified point that passes through the portal, according to the directional distribution of radiance over the portal.
][
  `SampleLi()` 能够利用整流化图像表示和 `WindowedPiecewiseConstant2D` 的能力，从指定点采样一个通过门户的方向，按照门户上辐射度的方向分布进行采样。
]

```cpp
<<PortalImageInfiniteLight Method Definitions>>+=
pstd::optional<LightLiSample>
PortalImageInfiniteLight::SampleLi(LightSampleContext ctx, Point2f u,
        SampledWavelengths lambda, bool allowIncompletePDF) const {
    <<Sample  in potentially visible region of light image>>
    <<Convert portal image sample point to direction and compute PDF>>
    <<Compute radiance for portal light sample and return LightLiSample>>
}
```

#parec[
  `WindowedPiecewiseConstant2D`'s `Sample()` method takes a `Bounds2f` to specify the sampling region. This is easily provided using the `ImageBounds()` method. It may not be able to generate a valid sample—for example, if the point is on the outside of the portal or lies on its plane. In this case, an unset sample is returned.
][
  `WindowedPiecewiseConstant2D` 的 `Sample()` 方法接受一个 `Bounds2f` 来指定采样区域。可以通过 `ImageBounds()` 方法轻松提供这个区域。如果无法生成有效的样本——例如，当点位于门户外部或位于门户的平面上时——则会返回一个未设置的样本。
]

```cpp
<<Sample  in potentially visible region of light image>>=
pstd::optional<Bounds2f> b = ImageBounds(ctx.p());
if (!b) return {};
Float mapPDF;
pstd::optional<Point2f> uv = distribution.Sample(u, *b, &mapPDF);
if (!uv) return {};
```

#parec[
  After image $(u, v)$ coordinates are converted to a direction, the method computes the sampling PDF with respect to solid angle at the reference point represented by `ctx`. Doing so just requires the application of the change of variables factor returned by `RenderFromImage()`.
][
  在将图像 $(u, v)$ 坐标转换为方向后，方法根据参考点 `ctx` 计算相对于固角的采样概率密度函数（PDF）。这样做只需要应用由 `RenderFromImage()` 返回的变量变换因子。
]


```cpp
<<Convert portal image sample point to direction and compute PDF>>=
Float duv_dw;
Vector3f wi = RenderFromImage(*uv, &duv_dw);
if (duv_dw == 0) return {};
Float pdf = mapPDF / duv_dw;
```

#parec[
  The remaining pieces are easy at this point: `ImageLookup()` provides the radiance for the sampled direction and the endpoint of the shadow ray is found in the same way that is done for the other infinite lights.
][
  此时，剩下的部分很简单：`ImageLookup()` 提供了采样方向的辐射度，而阴影光线的终点则按照与其他无限光源相同的方式找到。
]


```cpp
<<Compute radiance for portal light sample and return LightLiSample>>=
SampledSpectrum L = ImageLookup(*uv, lambda);
Point3f pl = ctx.p() + 2 * sceneRadius * wi;
return LightLiSample(L, wi, pdf, Interaction(pl, &mediumInterface));
```


#parec[
  Also as with the other infinite lights, the radius of the scene's bounding sphere is stored when the `Preprocess()` method, not included here, is called.
][
  与其他无限光源一样，当调用 `Preprocess()` 方法时（此处未包含），场景的包围球半径会被存储。
]

```cpp
<<PortalImageInfiniteLight Private Members>>+=
Float sceneRadius;
```

#parec[
  Finding the PDF for a specified direction follows the way in which the PDF was calculated in the sampling method.
][
  Finding the PDF for a specified direction follows the way in which the PDF was calculated in the sampling method.
]

```cpp
<<PortalImageInfiniteLight Method Definitions>>+=
Float PortalImageInfiniteLight::PDF_Li(LightSampleContext ctx, Vector3f w,
                                       bool allowIncompletePDF) const {
    <<Find image  coordinates corresponding to direction w>>
    <<Return PDF for sampling  from reference point>>
}
```


#parec[
  First, `ImageFromRender()` gives the $(u, v)$ coordinates in the portal image for the specified direction.
][
  First, `ImageFromRender()` gives the $(u, v)$ coordinates in the portal image for the specified direction.
]


```cpp
<<Find image  coordinates corresponding to direction w>>=
Float duv_dw;
pstd::optional<Point2f> uv = ImageFromRender(w, &duv_dw);
if (!uv || duv_dw == 0) return 0;
```


#parec[
  Following its `Sample()` method, the `WindowedPiecewiseConstant2D::PDF` method also takes a 2D bounding box to window the function. The PDF value it returns is normalized with respect to those bounds and a value of zero is returned if the given point is outside of them. Application of the change of variables factor gives the final PDF with respect to solid angle.
][
  在其 `Sample()` 方法之后，`WindowedPiecewiseConstant2D::PDF` 方法也接受一个二维边界框来对函数进行窗口化。它返回的 PDF 值是相对于这些边界进行归一化的，如果给定的点位于边界之外，则返回零值。通过应用变量变换因子，得到相对于固角的最终 PDF。
]


```cpp
<<Return PDF for sampling  from reference point>>=
pstd::optional<Bounds2f> b = ImageBounds(ctx.p());
if (!b) return 0;
Float pdf = distribution.PDF(*uv, *b);
return pdf / duv_dw;
```
