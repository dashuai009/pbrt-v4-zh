#import "../template.typ": parec, ez_caption

== Area lights
<area-lights>

#parec[
  Area lights are defined by the combination of a #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] and a directional distribution of radiance at each point on its surface. In general, computing radiometric quantities related to area lights requires computing integrals over the surface of the light that often cannot be computed in closed form, though they are well suited to Monte Carlo integration. The reward for this complexity (and computational expense) is soft shadows and more realistic lighting effects, rather than the hard shadows and stark lighting that come from point lights. (See @fig:light-arealight-scene, which shows the effect of varying the size of an area light source used to illuminate the dragon; compare its soft look to illumination from a point light in @fig:light-pointlight .)
][
  区域光源由#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];和其表面每个点的辐射方向分布的组合定义。通常，计算与区域光源相关的辐射量需要对光源表面进行积分，这些积分通常不能以封闭形式计算，尽管它们非常适合蒙特卡罗积分。计算这种复杂性（和计算成本）的回报是柔和的阴影和更逼真的光照效果，而非点光源产生的硬阴影和生硬光照。（@fig:light-arealight-scene，展示了用于照亮龙的区域光源大小变化的效果；将其柔和的外观与@fig:light-pointlight 中的点光源照明进行比较。）
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f15.svg"),
  caption: [
    #ez_caption[
      Dragon Model Illuminated by Disk Area Lights. (a) The disk’s radius is relatively small; the shadow has soft penumbrae, but otherwise the image looks similar to the one with a point light. (b) The effect of using a much larger disk: not only have the penumbrae become much larger, to the point of nearly eliminating the shadow of the tail, for example, but note also how the shading on the body is smoother, with the specular highlights less visible due to illumination coming from a wider range of directions. (Dragon model courtesy of the Stanford Computer Graphics Laboratory.)
    ][
      用圆盘区域光照亮的龙模型。（a）圆盘的半径相对较小；阴影具有柔和的半影，但整体图像看起来与使用点光源的效果相似。（b）使用更大圆盘的效果：不仅半影变得更大，例如几乎完全消除了尾巴的阴影，还可以注意到身体上的阴影更加平滑，镜面高光由于光从更广的方向范围照射而变得不那么明显。（龙模型由斯坦福计算机图形实验室提供。）
    ]
  ],
)<light-arealight-scene>

#parec[
  The `DiffuseAreaLight` class defines an area light where emission at each point on the surface has a uniform directional distribution.
][
  `DiffuseAreaLight`类定义了一个区域光源，其表面每个点的发射具有均匀的方向分布。
]

```cpp
<<DiffuseAreaLight Definition>>=
class DiffuseAreaLight : public LightBase {
  public:
    <<DiffuseAreaLight Public Methods>>
  private:
    <<DiffuseAreaLight Private Members>>
    <<DiffuseAreaLight Private Methods>>
};
```


#parec[
  Its constructor, not included here, sets the following member variables from the parameters provided to it. If an `alpha` texture has been associated with the shape to cut away parts of its surface, it is used here so that there is no illumination from those parts of the shape. #footnote[As a special case, `pbrt` also (reluctantly) supports the trick of creating an
invisible light source by specifying a light with a zero-valued alpha
texture.  Though non-physical, such lights can be useful for artistic
purposes.  In code not included in the text here, the
`DiffuseAreaLight` constructor characterizes them as being of
`LightType::DeltaPosition`, which leads to their being handled
correctly in the lighting integration routines even though rays can never
intersect them.] (Recall that alpha masking was introduced in @geometric-primitives.) The area of the emissive #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] is needed in a number of the following methods and so is cached in a member variable.
][
  其构造函数未在此处包含，从提供的参数中设置以下成员变量。如果形状与alpha纹理相关联以切割其表面的部分，则在此使用它，以便这些形状部分不发光。#footnote[作为一个特殊情况，`pbrt` 还（不情愿地）支持通过指定具有零值 alpha 纹理的光源来创建不可见光源的技巧。尽管这种光源不符合物理原理，但在艺术创作中可能非常有用。在本文未包含的代码中，`DiffuseAreaLight` 构造函数将它们定义为 `LightType::DeltaPosition` 类型，这使得即使光线永远无法与其相交，也可以在光照积分过程中正确处理这些光源。
  ]（回想一下，在@geometric-primitives 中介绍的alpha遮罩。）发光#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];的面积在以下方法中需要，因此缓存为一个成员变量。
]

```cpp
<<DiffuseAreaLight Private Members>>=
Shape shape;
FloatTexture alpha;
Float area;
```

#parec[
  A number of parameters specify emission from `DiffuseAreaLight`s. By default, emission is only on one side of the surface, where the surface normal is outward-facing. A scaling transform that flips the normal or the `ReverseOrientation` directive in the scene description file can be used to cause emission to be on the other side of the surface. If `twoSided` is true, then the light emits on both sides.
][
  许多参数指定了`DiffuseAreaLight`的发射。默认情况下，发射仅在表面的一侧，表面法线朝外。可以通过翻转法线的缩放变换或在场景描述文件中使用`ReverseOrientation`指令来使光源在表面的另一侧发射。如果`twoSided`为真，则光源在两侧发射。
]

#parec[
  Emission that varies over the surface can be defined using an Image; if one is provided to the constructor, the surface will have spatially varying emission defined by its color values. Otherwise, spatially uniform emitted spectral radiance is given by a provided Lemit spectrum. For both methods of specifying emission, an additional scale factor in scale is applied to the returned radiance.
][
  可以使用图像定义在表面上变化的发射光。如果在构造函数中提供了图像，表面的发射光将由图像的颜色值定义，并具有空间变化性。否则，将通过提供的 `Lemit` 光谱定义空间均匀的发射光谱辐射亮度。无论使用哪种方法定义发射光，返回的辐射亮度都会额外乘以一个由 `scale` 提供的缩放因子。
]

```cpp
<<DiffuseAreaLight Private Members>>+=
bool twoSided;
const DenselySampledSpectrum *Lemit;
Float scale;
Image image;
const RGBColorSpace *imageColorSpace;
```

#parec[
  Recall from Section #link("../Light_Sources/Light_Interface.html#sec:light")[12.1] that the #link("../Light_Sources/Light_Interface.html#Light")[`Light`] interface includes an `L()` method that area lights must implement to provide the emitted radiance at a specified point on their surface. This method is called if a ray happens to intersect an emissive surface, for example. `DiffuseAreaLight`'s implementation starts by checking a few cases in which there is no emitted radiance before calculating emission using the #link("../Utilities/Images.html#Image")[`Image`];, if provided, and otherwise the specified constant radiance.
][
  回想一下，第#link("../Light_Sources/Light_Interface.html#sec:light")[12.1];节中#link("../Light_Sources/Light_Interface.html#Light")[`Light`];接口包含一个`L()`方法，区域光源必须实现该方法以提供其表面指定点的发射辐射。例如，如果光线碰巧与发光表面相交，则调用此方法。`DiffuseAreaLight`的实现首先检查几个没有发射辐射的情况，然后使用#link("../Utilities/Images.html#Image")[`Image`];（如果提供）计算发射，否则计算指定的常量辐射。
]

```cpp
<<DiffuseAreaLight Public Methods>>=
SampledSpectrum L(Point3f p, Normal3f n, Point2f uv, Vector3f w,
                  const SampledWavelengths &lambda) const {
    <<Check for zero emitted radiance from point on area light>>
    if (image) {
        <<Return DiffuseAreaLight emission using image>>
    } else
        return scale * Lemit->Sample(lambda);
}
```

#parec[
  Two cases allow immediately returning no emitted radiance: the first is if the light is one-sided and the outgoing direction $omega$ faces away from the surface normal and the second is if the point on the light's surface has been cut away by an alpha texture.
][
  两种情况允许立即返回没有发射辐射：第一种情况是光源为单面且出射方向 $omega$ 背向表面法线，第二种情况是光源表面上的点被alpha纹理切割掉。
]

```cpp
<<Check for zero emitted radiance from point on area light>>=
if (!twoSided && Dot(n, w) < 0)
    return SampledSpectrum(0.f);
if (AlphaMasked(Interaction(p, uv)))
    return SampledSpectrum(0.f);
```

#parec[
  The `AlphaMasked()` method performs a stochastic alpha test for a point on the light.
][
  `AlphaMasked()`方法对光源上的点执行随机alpha测试。
]

```cpp
<<DiffuseAreaLight Private Methods>>=
bool AlphaMasked(const Interaction &intr) const {
    if (!alpha) return false;
    Float a = UniversalTextureEvaluator()(alpha, intr);
    if (a >= 1) return false;
    if (a <= 0) return true;
    return HashFloat(intr.p()) > a;
}
```


#parec[
  If an #link("../Utilities/Images.html#Image")[`Image`] has been provided to specify emission, then the emitted radiance is found by looking up an RGB value and converting it to the requested spectral samples. Note that the $v$ coordinate is inverted before being passed to `BilerpChannel()`; in this way, the parameterization matches the image texture coordinate conventions that were described in @image-texture-evaluation . (See @fig:area-sampling-image-emission for a scene with an area light source with emission defined using an image.)
][
  如果提供了#link("../Utilities/Images.html#Image")[`Image`];来指定发射，则通过查找RGB值并将其转换为请求的光谱样本来找到发射辐射。注意，在传递给`BilerpChannel()`之前， $v$ 坐标被反转；这样，参数化匹配了在@image-texture-evaluation 中描述的图像纹理坐标约定。（见@fig:area-sampling-image-emission 中的场景，使用图像定义发射的区域光源。）
]

```cpp
<<Return DiffuseAreaLight emission using image>>=
RGB rgb;
uv[1] = 1 - uv[1];
for (int c = 0; c < 3; ++c)
    rgb[c] = image.BilerpChannel(uv, c);
RGBIlluminantSpectrum spec(*imageColorSpace, ClampZero(rgb));
return scale * spec.Sample(lambda);
```


#parec[
  For convenience, we will add a method to the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] class that makes it easy to compute the emitted radiance at a surface point intersected by a ray.
][
  为了方便起见，我们将在#link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];类中添加一个方法，使其易于计算由光线相交的表面点的发射辐射。
]

```cpp
<<SurfaceInteraction Method Definitions>>+=
SampledSpectrum SurfaceInteraction::Le(Vector3f w,
        const SampledWavelengths &lambda) const {
    return areaLight ? areaLight.L(p(), n, uv, w, lambda)
                     : SampledSpectrum(0.f);
}
```

#parec[
  All the `SampleLi()` methods so far have been deterministic: because all the preceding light models have been defined in terms of Dirac delta distributions of either position or direction, there has only been a single incident direction along which illumination arrives at any point. This is no longer the case with area lights and we will finally make use of the uniform 2D sample $u$.
][
  到目前为止，所有的`SampleLi()`方法都是确定性的：因为所有前面的光模型都是以位置或方向的狄拉克δ分布定义的，因此在任何点上只有一个单一的入射方向沿着光线到达。这在区域光源中不再适用，我们将最终使用均匀的2D样本 $u$。
]

```cpp
<<DiffuseAreaLight Method Definitions>>=
pstd::optional<LightLiSample>
DiffuseAreaLight::SampleLi(LightSampleContext ctx, Point2f u,
         SampledWavelengths lambda, bool allowIncompletePDF) const {
    <<Sample point on shape for DiffuseAreaLight>>
    <<Check sampled point on shape against alpha texture, if present>>
    <<Return LightLiSample for sampled point on shape>>
}
```


#parec[
  The second variant of #link("../Shapes/Basic_Shape_Interface.html#Shape::Sample")[`Shape::Sample`];, which takes a receiving point and returns a point on the shape and PDF expressed with respect to solid angle at the receiving point, is an exact match for the `Light` `SampleLi()` interface. Therefore, the implementation starts by calling that method.
][
  #link("../Shapes/Basic_Shape_Interface.html#Shape::Sample")[`Shape::Sample`];的第二个变体，它接受一个接收点并返回形状上的一个点以及相对于接收点的固体角度表达的PDF，与`Light`的`SampleLi()`接口完全匹配。因此，实施从调用该方法开始。
]

#parec[
  The astute reader will note that if an image is being used to define the light's emission, leaving the sampling task to the shape alone may not be ideal. Yet, extending the Shape's sampling interface to optionally take a reference to an Image or some other representation of spatially varying emission would be a clunky addition. pbrt's solution to this problem is that BilinearPatch shapes (but no others) allow specifying an image to use for sampling. To have to specify this information twice in the scene description is admittedly not ideal, but it suffices to make the common case of a quadrilateral emitter with an image work out.
][
  细心的读者会注意到，如果使用图像来定义光源的发射光，仅由形状负责采样可能并不理想。然而，扩展形状的采样接口以额外接受对图像或其他空间变化发射表示的引用，会显得笨拙。`pbrt` 对此问题的解决方案是，仅允许 `BilinearPatch` 形状（而不是其他形状）指定一个用于采样的图像。在场景描述中必须重复指定这一信息确实不够理想，但对于处理带有图像的四边形发射器这种常见情况来说，这种方法已足够实用。
]

```cpp
<<Sample point on shape for DiffuseAreaLight>>=
ShapeSampleContext shapeCtx(ctx.pi, ctx.n, ctx.ns, 0 /* time */);
pstd::optional<ShapeSample> ss = shape.Sample(shapeCtx, u);
if (!ss || ss->pdf == 0 || LengthSquared(ss->intr.p() - ctx.p()) == 0)
    return {};
ss->intr.mediumInterface = &mediumInterface;
```

#parec[
  If the sampled point has been masked by the alpha texture, an invalid sample is returned.
][
  如果采样点被alpha纹理遮罩，则返回无效样本。
]

```cpp
<<Check sampled point on shape against alpha texture, if present>>=
if (AlphaMasked(ss->intr))
    return {};
```



#parec[
  If the shape has generated a valid sample, the next step is to compute the emitted radiance at the sample point. If that is a zero-valued spectrum, then an unset sample value is returned; calling code can then avoid the expense of tracing an unnecessary shadow ray.
][
  如果形状生成了有效的样本，下一步是计算样本点的发射辐射。如果这是一个零值光谱，则返回未设置的样本值；调用代码可以避免跟踪不必要的阴影光线的开销。
]

#parec[
  The PDF for sampling a given direction from a receiving point is also easily handled, again thanks to #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] providing a corresponding method.
][
  从接收点采样给定方向的PDF也很容易处理，这再次得益于#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];提供的相应方法。
]

```cpp
<<DiffuseAreaLight Method Definitions>>+=
Float DiffuseAreaLight::PDF_Li(LightSampleContext ctx, Vector3f wi,
                               bool allowIncompletePDF) const {
    ShapeSampleContext shapeCtx(ctx.pi, ctx.n, ctx.ns, 0 /* time */);
    return shape.PDF(shapeCtx, wi);
}
```

#parec[
  Emitted power from an area light with uniform emitted radiance over the surface can be computed in closed form: from Equation (@eqt:irradiance-to-power ) it follows that it is $pi$ times the surface area times the emitted radiance. If an image has been specified for the emission, its average value is computed in a fragment that is not included here. That computation neglects the effect of any alpha texture and effectively assumes that there is no distortion in the surface's $(u , v)$ parameterization. If these are not the case, there will be error in the $phi.alt$ value.
][
  具有均匀发射辐射的区域光源的发射功率可以以封闭形式计算：从方程式(@eqt:irradiance-to-power )可以得出，它是表面积乘以发射辐射的 $pi$ 倍。如果指定了用于发射的图像，则在此未包含的片段中计算其平均值。该计算忽略了任何alpha纹理的影响，并有效地假设表面的 $(u , v)$ 参数化没有失真。如果这些情况不成立，则 $phi.alt$ 值会有误差。
]


```cpp
<<DiffuseAreaLight Method Definitions>>+=
SampledSpectrum DiffuseAreaLight::Phi(SampledWavelengths lambda) const {
    SampledSpectrum L(0.f);
    if (image) {
        <<Compute average light image emission>>
    } else
        L = Lemit->Sample(lambda) * scale;
    return Pi * (twoSided ? 2 : 1) * area * L;
}
```
