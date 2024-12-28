#import "../template.typ": parec, ez_caption

== Point Lights
#parec[
  A number of interesting lights can be described in terms of emission from a single point in space with some possibly angularly varying distribution of outgoing light. This section describes the implementation of a number of them, starting with #link("<PointLight>")[PointLight];, which represents an isotropic point light source that emits the same amount of light in all directions. @fig:light-pointlight shows a scene rendered with a point light source.) Building on this base, a number of more complex lights based on point sources will then be introduced, including spotlights and a light that projects an image into the scene.
][
  一些有趣的光源可以用从空间中单一点发射的光来描述，这些光可能具有某种角度变化的光分布。本节描述了其中一些的实现，首先是#link("<PointLight>")[PointLight];，它代表一个各向同性的点光灯，在所有方向上发出相同量的光。 （@fig:light-pointlight 展示了一个使用点光灯渲染的场景。）在此基础上，将介绍一些基于点光灯的更复杂的光源，包括聚光灯和将图像投射到场景中的光源。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f03.svg"),
  caption: [
    #ez_caption[
      Scene Rendered with a Point Light Source. Notice the hard shadow boundaries from this type of light. (Dragon model courtesy of the Stanford Computer Graphics Laboratory.)
    ][
      使用点光源渲染的场景。请注意这种光源类型产生的硬阴影边界。（龙模型由斯坦福计算机图形实验室提供。）
    ]
  ],
)<light-pointlight>


```cpp
<<PointLight Definition>>=
class PointLight : public LightBase {
  public:
    <<PointLight Public Methods>>
  private:
    <<PointLight Private Members>>
};
```

#parec[
  Point lights are positioned at the origin in the light coordinate system. To place them elsewhere, the rendering-from-light transformation should be set accordingly. In addition to passing the common light parameters to #link("../Light_Sources/Light_Interface.html#LightBase")[LightBase];, the constructor supplies #link("../Light_Sources/Light_Interface.html#LightType::DeltaPosition")[LightType::DeltaPosition] for its light type, since point lights represent singularities that only emit light from a single position. The constructor also stores the light's intensity (@basic-quantities).
][
  点光灯在光坐标系中定位于原点。要将它们放置在其他位置，应相应地设置从光源到渲染的变换。 除了将常见的光源参数传递给#link("../Light_Sources/Light_Interface.html#LightBase")[LightBase];外，构造函数还为其光源类型提供#link("../Light_Sources/Light_Interface.html#LightType::DeltaPosition")[LightType::DeltaPosition];，因为点光灯表示仅从单个位置发光的奇点。 构造函数还存储光源的强度（@basic-quantities）。
]

```cpp
<<PointLight Public Methods>>=
PointLight(Transform renderFromLight, MediumInterface mediumInterface,
           Spectrum I, Float scale)
    : LightBase(LightType::DeltaPosition, renderFromLight, mediumInterface),
      I(LookupSpectrum(I)), scale(scale) {}
```

#parec[
  As #link("../Volume_Scattering/Media.html#HomogeneousMedium")[HomogeneousMedium] and `GridMedium` did with spectral scattering coefficients, `PointLight` uses a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[DenselySampledSpectrum] rather than a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[Spectrum] for the spectral intensity, trading off storage for more efficient spectral sampling operations.
][
  正如#link("../Volume_Scattering/Media.html#HomogeneousMedium")[HomogeneousMedium];和`GridMedium`使用光谱散射系数一样，`PointLight`使用#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[密集采样光谱];而不是#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[Spectrum];来表示光谱强度，以存储换取更高效的光谱采样操作。
]

```cpp
<<PointLight Private Members>>=
const DenselySampledSpectrum *I;
Float scale;
```

#parec[
  Strictly speaking, it is incorrect to describe the light arriving at a point due to a point light source using units of radiance. Radiant intensity is instead the proper unit for describing emission from a point light source, as explained in @Radiometry . In the light source interfaces here, however, we will abuse terminology and use `SampleLi()` methods to report the illumination arriving at a point for all types of light sources, dividing radiant intensity by the squared distance to the point $p$ to convert units. In the end, the correctness of the computation does not suffer from this fudge, and it makes the implementation of light transport algorithms more straightforward by not requiring them to use different interfaces for different types of lights.
][
  严格来说，用辐射亮度来描述由于点光源到达某一点的光是不正确的。 辐射强度才是描述点光源发射的正确单位，如@Radiometry 所述。 然而，在这里的光源接口中，我们将滥用术语，使用`SampleLi()`方法来报告到达某点的所有类型光源的照明，通过将辐射强度除以到点 $p$ 的平方距离来转换单位。 最终，这种处理并不会影响计算的正确性，并且通过不要求光传输算法为不同类型的光源使用不同的接口，使其实现更加简单。
]

#parec[
  Point lights are described by a delta distribution such that they only illuminate a receiving point from a single direction. Thus, the sampling problem is deterministic and makes no use of the random sample `u`. We find the light's position `p` in the rendering coordinate system and sample its spectral emission at the provided wavelengths. Note that a PDF value of 1 is returned in the #link("../Light_Sources/Light_Interface.html#LightLiSample")[LightLiSample];: there is implicitly a Dirac delta distribution in both the radiance and the PDF that cancels when the Monte Carlo estimator is evaluated.
][
  点光灯由一个δ分布描述，因此它们仅从一个方向照亮接收点。 因此，采样问题是确定性的，并且不使用随机样本`u`。我们在渲染坐标系中找到光源的位置`p`，并在提供的波长处采样其光谱发射。 注意，在#link("../Light_Sources/Light_Interface.html#LightLiSample")[LightLiSample];中返回的PDF值为1：在辐射亮度和PDF中隐含有一个狄拉克δ分布，在评估蒙特卡罗估计器时会相互抵消。
]

```cpp
<<PointLight Public Methods>>+=
pstd::optional<LightLiSample>
SampleLi(LightSampleContext ctx, Point2f u, SampledWavelengths lambda,
         bool allowIncompletePDF) const {
    Point3f p = renderFromLight(Point3f(0, 0, 0));
    Vector3f wi = Normalize(p - ctx.p());
    SampledSpectrum Li = scale * I->Sample(lambda) /
                         DistanceSquared(p, ctx.p());
    return LightLiSample(Li, wi, 1, Interaction(p, &mediumInterface));
}
```

#parec[
  Due to the delta distribution, the `PointLight::PDF_Li()` method returns 0. This value reflects the fact that there is no chance for some other sampling process to randomly generate a direction that would intersect an infinitesimal light source.
][
  由于δ分布，`PointLight::PDF_Li()`方法返回0。 这个值反映了没有机会通过其他采样过程随机生成一个方向来与一个无限小的光源相交。
]

```cpp
<<PointLight Public Methods>>+=
Float PDF_Li(LightSampleContext, Vector3f, bool allowIncompletePDF) const {
    return 0;
}
```

#parec[
  The total power emitted by the light source can be found by integrating the intensity over the entire sphere of directions:
][
  光源发出的总功率可以通过在整个方向球面上积分强度来找到：
]

$ Phi = integral_(S^2) I thin d omega = I integral_(S^2) d omega = 4 pi I . $

#parec[
  Radiant power is returned by the `Phi()` method and not the luminous power that may have been used to specify the light source.
][
  辐射功率由`Phi()`方法返回，而不是可能用于指定光源的发光功率。
]

```cpp
SampledSpectrum PointLight::Phi(SampledWavelengths lambda) const {
    return 4 * Pi * scale * I->Sample(lambda);
}
```

=== Spotlights

#parec[
  Spotlights are a handy variation on point lights; rather than shining illumination in all directions, they emit light in a cone of directions from their position. For simplicity, we will define the spotlight in the light coordinate system to always be at position $(0 , 0 , 0)$ and pointing down the $+ z$ axis. To place or orient it elsewhere in the scene, the rendering-from-light transformation should be set accordingly. Figure #link("<fig:light-spotlight>")[12.4] shows a rendering of the same scene as @fig:light-pointlight , illuminated with a spotlight instead of a point light.
][
  聚光灯是点光源的一种方便变体；它们不是向所有方向发光，而是从其位置向一个锥形区域发光。为了简单起见，我们将在光坐标系中将聚光灯定义为始终位于位置 $(0 , 0 , 0)$ 并指向 $+ z$ 轴。要将其放置或定向到场景中的其他位置，应相应设置从光源到渲染的转换。图 #link("<fig:light-spotlight>")[12.4] 显示了用聚光灯而不是点光源照亮的与图 #link("<fig:light-pointlight>")[12.3] 相同的场景渲染.
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/dragon-spot-light.png"),
  caption: [
    #parec[Scene Rendered with a Spotlight. The spotlight cone smoothly cuts off illumination past a user-specified angle from the light’s central axis. #emph[(Dragon model courtesy of the Stanford Computer Graphics Laboratory.)]
    ][
      用聚光灯渲染的场景。聚光灯锥体在超过用户指定的与光的中心轴的角度后，光照会逐渐减弱直至截止。 #emph[(龙模型由斯坦福计算机图形实验室提供。)]
    ]
  ],
)<light-spotlight>


```cpp
<<SpotLight Definition>>=
class SpotLight : public LightBase {
  public:
    <<SpotLight Public Methods>>
  private:
    <<SpotLight Private Members>>
};
```

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f05.svg"),
  caption: [
    #ez_caption[
      Spotlights are defined by two angles, falloffStart and totalWidth, that are measured with respect to the $z$ axis in light space. Objects inside the inner cone of angles, up to falloffStart, are fully illuminated by the light. The directions between falloffStart and totalWidth are a transition zone that ramps down from full illumination to no illumination, such that points outside the totalWidth cone are not illuminated at all. The cosine of the angle $theta$ between the vector to a point $upright(p)$ and the spotlight axis can easily be computed with a dot product.
    ][
      聚光灯由两个角度定义：`falloffStart` 和 `totalWidth`，它们相对于光空间中的 $z$ 轴测量。处于内锥角（小于或等于 `falloffStart`）内的物体会被完全照亮。从 `falloffStart` 到 `totalWidth` 之间的区域是一个过渡区，照明从完全亮度逐渐递减到无照明。而在 `totalWidth` 锥体之外的点完全不会被照亮。点 $p$ 的向量 $upright(p)$ 与聚光灯轴之间的角度 $\\theta$ 的余弦值可以通过点积轻松计算得出。

    ]
  ],
)<spotlight>


#parec[
  There is not anything interesting in the `SpotLight` constructor, so it is not included here. It is given angles that set the extent of the `SpotLight's` cone—the overall angular width of the cone and the angle at which falloff starts (@fig:spotlight)—but it stores the cosines of these angles, which are more useful to have at hand in the `SpotLight`'s methods.
][
  `SpotLight` 构造函数中没有特别值得注意的内容，因此这里未包含。它接受一些用于设置聚光灯锥体范围的角度参数——锥体的整体角宽度以及衰减开始的角度（见 @fig:spotlight）。不过，它会存储这些角度的余弦值，因为在 SpotLight 的方法中，这些余弦值更为实用。
]



```cpp
<<SpotLight Private Members>>=
const DenselySampledSpectrum *Iemit;
Float scale, cosFalloffStart, cosFalloffEnd;
```


#parec[
  The `SpotLight::SampleLi()` method is of similar form to that of `PointLight::SampleLi()`, though an unset sample is returned if the receiving point is outside of the spotlight's outer cone and thus receives zero radiance.
][
  `SpotLight::SampleLi()` 方法的形式与 `PointLight::SampleLi()` 类似，但如果接收点位于聚光灯外锥之外（因此接收的辐射亮度为零），则会返回一个未设置的样本。
]


```cpp
<<SpotLight Public Methods>>=
pstd::optional<LightLiSample>
SampleLi(LightSampleContext ctx, Point2f u, SampledWavelengths lambda,
         bool allowIncompletePDF) const {
    Point3f p = renderFromLight(Point3f(0, 0, 0));
    Vector3f wi = Normalize(p - ctx.p());
    <<Compute incident radiance Li for SpotLight>>
    if (!Li) return {};
    return LightLiSample(Li, wi, 1, Interaction(p, &mediumInterface));
}
```

#parec[
  The `I()` method computes the distribution of light accounting for the spotlight cone. This computation is encapsulated in a separate method since other SpotLight methods will need to perform it as well.
][

]

```cpp
<<Compute incident radiance Li for SpotLight>>=
Vector3f wLight = Normalize(renderFromLight.ApplyInverse(-wi));
SampledSpectrum Li = I(wLight, lambda) / DistanceSquared(p, ctx.p());
```


#parec[
  As with point lights, the SpotLight's `PDF_Li()` method always returns zero. It is not included here.
][

]

#parec[
  To compute the spotlight's strength for a direction leaving the light, the first step is to compute the cosine of the angle between that direction and the vector along the center of the spotlight's cone. Because the spotlight is oriented to point down the axis $+z$, the `CosTheta()` function can be used to do so.
][

]


#parec[
  The `SmoothStep()` function is then used to modulate the emission according to the cosine of the angle: it returns 0 if the provided value is below `cosFalloffEnd`, 1 if it is above `cosFalloffStart`, and it interpolates between 0 and 1 for intermediate values using a cubic curve. (To understand its usage, keep in mind that for $theta in [0, pi]$, as is the case here, if $theta > theta'$, then $cos theta < cos theta'$.)
][

]


```cpp
<<SpotLight Method Definitions>>=
SampledSpectrum SpotLight::I(Vector3f w, SampledWavelengths lambda) const {
    return SmoothStep(CosTheta(w), cosFalloffEnd, cosFalloffStart) *
           scale * Iemit->Sample(lambda);
}
```

#parec[
  To compute the power emitted by a spotlight, it is necessary to integrate the falloff function over the sphere. In spherical coordinates, $theta$ and $phi.alt$ are separable, so we just need to integrate over $theta$ and scale the result by $2pi$. For the part that lies inside the inner cone of full power, we have
][

]
$ integral_0^(theta_(upright("start"))) sin theta thin d theta = 1 - cos theta_(upright("start")) $

#parec[
  The falloff region works out simply, thanks in part to #link("../Utilities/Mathematical_Infrastructure.html#SmoothStep")[SmoothStep()] being a polynomial.
][
  衰减区域的计算很简单，部分归功于 #link("../Utilities/Mathematical_Infrastructure.html#SmoothStep")[SmoothStep()] 是一个多项式。
]

$
  integral_(theta_(upright("start")))^(theta_(upright("end"))) upright("smt") ( cos theta , theta_(upright("end")) , theta_(upright("start")) ) sin theta thin d theta = frac(cos theta_(upright("start")) - cos theta_(upright("end")), 2)
$

```cpp
<<SpotLight Method Definitions>>+=
SampledSpectrum SpotLight::Phi(SampledWavelengths lambda) const {
    return scale * Iemit->Sample(lambda) * 2 * Pi *
           ((1 - cosFalloffStart) + (cosFalloffStart - cosFalloffEnd) / 2);
}
```

=== Texture Projection Lights
<texture-projection-lights>

#parec[
  Another useful light source acts like a slide projector; it takes an image map and projects its image out into the scene. The #link("<ProjectionLight>")[`ProjectionLight`] class uses a projective transformation to project points in the scene onto the light's projection plane based on the field of view angle given to the constructor (@fig:projlight).
][
  另一种有用的光源类似于幻灯片投影机；它获取图像地图并将其投影到场景中。 #link("<ProjectionLight>")[`ProjectionLight`] 类使用投影变换将场景中的点投影到光的投影平面上，基于构造函数给定的视场角（@fig:projlight）。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f07.svg"),
  caption: [
    #ez_caption[
      The Basic Setting for Projection Light Sources. A point $p$
      in the light’s coordinate system is projected onto the plane of the
      image using the light’s projection matrix.
    ][
      投影光源的基本设置。 在光的坐标系中的点 $p$
      被投影到图像的平面上，使用光的投影矩阵。
    ]
  ],
)<projlight>


#parec[
  The use of this light in the lighting example scene is shown in @fig:light-projection.
][
  在照明示例场景中使用此光的情况如@fig:light-projection 所示。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f06.svg"),
  caption: [
    #ez_caption[
      Scene Rendered with a Projection Light Using a Grid Image.
      The projection light acts like a slide projector, projecting an image
      onto objects in the scene. (Dragon model courtesy of the Stanford
      Computer Graphics Laboratory.)
    ][
      使用网格图像进行投影光渲染的场景。
      投影光像幻灯片投影机一样，将图像投射到场景中的物体上。（龙模型由斯坦福计算机图形实验室提供。）
    ]
  ],
)<light-projection>

```cpp
<<ProjectionLight Definition>>=
class ProjectionLight : public LightBase {
  public:
    <<ProjectionLight Public Methods>>
  private:
    <<ProjectionLight Private Members>>
};
```


#parec[
  This light could use a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[`Texture`] to represent the light projection distribution so that procedural projection patterns could be used. However, having a tabularized representation of the projection function makes it easier to sample with probability proportional to the projection function. Therefore, the #link("../Utilities/Images.html#Image")[`Image`] class is used to specify the projection pattern.
][
  此光可以使用 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[`Texture`] 来表示光投影分布，以便可以使用程序投影模式。 然而，具有投影函数的表格化表示使得更容易以与投影函数成比例的概率进行采样。 因此，使用 #link("../Utilities/Images.html#Image")[`Image`] 类来指定投影模式。
]

```cpp
<<ProjectionLight Method Definitions>>=
ProjectionLight::ProjectionLight(
        Transform renderFromLight, MediumInterface mediumInterface,
        Image im, const RGBColorSpace *imageColorSpace, Float scale,
        Float fov, Allocator alloc)
    : LightBase(LightType::DeltaPosition, renderFromLight, mediumInterface),
      image(std::move(im)), imageColorSpace(imageColorSpace), scale(scale),
      distrib(alloc) {
    <<ProjectionLight constructor implementation>>
}
```


#parec[
  A color space for the image is stored so that it is possible to convert image RGB values to spectra.
][
  图像的颜色空间被存储，以便可以将图像的 RGB 值转换为光谱。
]


```cpp
<<ProjectionLight Private Members>>=
Image image;
const RGBColorSpace *imageColorSpace;
Float scale;
```

#parec[
  The constructor has more work to do than the ones we have seen so far, including initializing a projection matrix and computing the area of the projected image on the projection plane.
][
  构造函数比我们迄今为止看到的构造函数有更多的工作要做，包括初始化投影矩阵和计算投影平面上投影图像的面积。
]

```cpp
<<ProjectionLight constructor implementation>>=
<<Initialize ProjectionLight projection matrix>>
<<Compute projection image area A>>
<<Compute sampling distribution for ProjectionLight>>
```

#parec[
  First, similar to the `PerspectiveCamera` , the `ProjectionLight` constructor computes a projection matrix and the screen space extent of the projection on the $z = 1$ plane.
][
  首先，类似于 `PerspectiveCamera` ， `ProjectionLight` 构造函数计算投影矩阵和 $z = 1$ 平面上的投影的屏幕空间范围。
]

```cpp
<<Initialize ProjectionLight projection matrix>>=
Float aspect = Float(image.Resolution().x) / Float(image.Resolution().y);
if (aspect > 1)
    screenBounds = Bounds2f(Point2f(-aspect, -1), Point2f(aspect, 1));
else
    screenBounds = Bounds2f(Point2f(-1, -1/aspect), Point2f(1, 1/aspect));
screenFromLight = Perspective(fov, hither, 1e30f /* yon */);
lightFromScreen = Inverse(screenFromLight);
```

#parec[
  Since there is no particular need to keep `ProjectionLight`s compact, both of the screen–light transformations are stored explicitly, which makes code in the following that uses them more succinct.
][
  由于没有特别需要保持 <tt>`ProjectionLight` 紧凑，因此屏幕-光变换都被显式存储，这使得后续使用它们的代码更加简洁。
]
```cpp
<<ProjectionLight Private Members>>+=
Bounds2f screenBounds;
Float hither = 1e-3f;
Transform screenFromLight, lightFromScreen;
```

#parec[
  For a number of the following methods, we will need the light-space area of the image on the $z = 1$ plane. One way to find this is to compute half of one of the two rectangle edge lengths using the projection's field of view and to use the fact that the plane is a distance of 1 from the camera's position. Doubling that gives one edge length and the other can be found using a factor based on the aspect ratio; see @fig:light-space-image-area-z1.
][
  对于接下来的许多方法，我们需要在 $z = 1$ 平面上图像的光空间面积。找到这个面积的一种方法是使用投影的视场角计算两个矩形边长之一的一半，并使用基于纵横比的因子；参见@fig:light-space-image-area-z1。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f08.svg"),
  caption: [
    #ez_caption[
      The first step of computing the light-space area of the image on the $z=1$ projection plane is to compute the length opposite illustrated here. It is easily found using basic trigonometry.
    ][

    ]
  ],
)<light-space-image-area-z1>

```cpp
<<Compute projection image area A>>=
Float opposite = std::tan(Radians(fov) / 2);
A = 4 * Sqr(opposite) * (aspect > 1 ? aspect : (1 / aspect));
```


```cpp
<<ProjectionLight Private Members>>+=
Float A;
```

#parec[
  The `ProjectionLight::SampleLi()` follows the same form as `SpotLight::SampleLi()` except that it uses the following `I()` method to compute the spectral intensity of the projected image. We will therefore skip over its implementation here. We will also not include the `PDF_Li()` method's implementation, as it, too, returns 0.
][
  `ProjectionLight::SampleLi()` 遵循与 `SpotLight::SampleLi()` 相同的形式，只是它使用以下 `I()` 方法来计算投影图像的光谱强度。因此，我们将在此跳过其实现。我们也不会包括 `PDF_Li()` 方法的实现，因为它也返回 0。
]

#parec[
  The direction passed to the `I()` method should be normalized and already transformed into the light's coordinate system.
][
  传递给 `I()` 方法的方向应该是归一化的，并且已经转换到光的坐标系中。
]


```cpp
<<ProjectionLight Method Definitions>>+=
SampledSpectrum ProjectionLight::I(Vector3f w,
        const SampledWavelengths &lambda) const {
    <<Discard directions behind projection light>>
    <<Project point onto projection plane and compute RGB>>
    <<Return scaled wavelength samples corresponding to RGB>>
}
```

#parec[
  Because the projective transformation has the property that it projects points behind the center of projection to points in front of it, it is important to discard points with a negative $z$ value. Therefore, the projection code immediately returns no illumination for projection points that are behind the hither plane for the projection. If this check were not done, then it would not be possible to know if a projected point was originally behind the light (and therefore not illuminated) or in front of it.
][
  由于投影变换具有将投影中心后面的点投影到其前面的点的特性，因此丢弃 $z$ 值为负的点很重要。因此，投影代码立即返回投影点在投影的 hither 平面后方时没有照明。如果不进行此检查，则无法知道投影点最初是在光的后面（因此未被照亮）还是在其前面。
]

```cpp
<<Discard directions behind projection light>>=
if (w.z < hither)
    return SampledSpectrum(0.f);
```
#parec[
  After being projected to the projection plane, points with coordinate values outside the screen window are discarded. Points that pass this test are transformed to get texture coordinates inside $[0,1]^2$ for the lookup in the image.
][
  在被投影到投影平面后，坐标值在屏幕窗口之外的点将被丢弃。通过此测试的点被转换为在 $[0, 1]^2$ 内的纹理坐标，以便在图像中进行查找。
]
#parec[
  One thing to note is that a “nearest” lookup is used rather than, say, bilinear interpolation of the image samples. Although bilinear interpolation would lead to smoother results, especially for low-resolution image maps, in this way the projection function will exactly match the piecewise-constant distribution that is used for importance sampling in the light emission sampling methods. Further, the code here assumes that the image stores red, green, and blue in its first three channels; the code that creates ProjectionLights ensures that this is so.
][
  需要注意的一点是，使用“最近”查找而不是例如图像样本的双线性插值。虽然双线性插值会导致更平滑的结果，特别是对于低分辨率的图像地图，但这样投影函数将完全匹配用于光发射采样方法中的分段常数分布。 此外，这里的代码假设图像在其前三个通道中存储红、绿和蓝；创建 `ProjectionLight` 的代码确保了这一点。
]

```cpp
<<Project point onto projection plane and compute RGB>>=
Point3f ps = screenFromLight(Point3f(w));
if (!Inside(Point2f(ps.x, ps.y), screenBounds))
    return SampledSpectrum(0.f);
Point2f uv = Point2f(screenBounds.Offset(Point2f(ps.x, ps.y)));
RGB rgb;
for (int c = 0; c < 3; ++c)
    rgb[c] = image.LookupNearestChannel(uv, c);
```

#parec[
  It is important to use an `RGBIlluminantSpectrum` to convert the RGB value to spectral samples rather than, say, an `RGBUnboundedSpectrum`. This ensures that, for example, a $(1, 1, 1)$ RGB value corresponds to the color space's illuminant and not a constant spectral distribution.
][
  使用 `RGBIlluminantSpectrum` 将 RGB 值转换为光谱样本而不是例如 `RGBUnboundedSpectrum` 是很重要的。这确保了，例如， $(1, 1, 1)$ 的 RGB 值对应于颜色空间的光源而不是恒定的光谱分布。
]

```cpp
<<Return scaled wavelength samples corresponding to RGB>>=
RGBIlluminantSpectrum s(*imageColorSpace, ClampZero(rgb));
return scale * s.Sample(lambda);
```

#parec[
  The total emitted power is given by integrating radiant intensity over the sphere of directions (@eqt:power-from-radiant-intensity), though here the projection function is tabularized over a planar 2D area. Power can thus be computed by integrating over the area of the image and applying a change of variables factor $d omega \/ d A$ :
][
  通过在方向球面上积分辐射强度可以得到总发射功率(@eqt:power-from-radiant-intensity)，尽管这里投影函数在平面二维区域上是表格化的。因此，功率可以通过在图像面积上积分并应用变量变化因子 $d omega \/ d A$ 计算得到：
]

$
  Phi = integral_(S^2) I (omega) upright(d) omega = integral_A I (p) frac(upright(d) omega, upright(d) A) upright(d) A .
$

```cpp
<<ProjectionLight Method Definitions>>+=
SampledSpectrum ProjectionLight::Phi(SampledWavelengths lambda) const {
    SampledSpectrum sum(0.f);
    for (int y = 0; y < image.Resolution().y; ++y)
        for (int x = 0; x < image.Resolution().x; ++x) {
            <<Compute change of variables factor dwdA for projection light pixel>>
            <<Update sum for projection light pixel>>
        }
    <<Return final power for projection light>>
}
```

#parec[
  Recall from @integrals-over-area that differential area $d A$ is converted to differential solid angle $d omega$ by multiplying by a $cos theta$ factor and dividing by the squared distance. Because the plane we are integrating over is at $z = 1$, the distance from the origin to a point on the plane is equal to $frac(1, cos theta)$ and thus the aggregate factor is $cos^3 theta$ ; see @fig:projection-light-power.
][
  回忆在@integrals-over-area 中提到，微分面积 $d A$ 通过乘以 $cos theta$ 因子并除以平方距离转换为微分立体角 $d omega$。因为我们积分的平面在 $z = 1$，所以从原点到平面上某点的距离等于 $frac(1, cos theta)$，因此总因子为 $cos^3 theta$ ；参见@fig:projection-light-power。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f09.svg"),
  caption: [
    #ez_caption[
      To find the power of a point light source, we generally integrate radiant intensity over directions around the light. For the `ProjectionLight` , we instead integrate over the plane $z = 1$, in which case we need to account for the change of variables, applying both a $cos theta$ and a $1 / r^2$ factor.

    ][
      为了找到点光源的功率，我们通常在光源周围的方向上积分辐射强度。对于 `ProjectionLight` ，我们改为在平面 $z = 1$ 上积分，在这种情况下，我们需要考虑变量的变化，应用 $cos theta$ 和 $1 / r^2$ 因子。
    ]
  ],
)<projection-light-power>


```cpp
<<Compute change of variables factor dwdA for projection light pixel>>=
Point2f ps = screenBounds.Lerp(Point2f((x + 0.5f) / image.Resolution().x,
                                       (y + 0.5f) / image.Resolution().y));
Vector3f w = Vector3f(lightFromScreen(Point3f(ps.x, ps.y, 0)));
w = Normalize(w);
Float dwdA = Pow<3>(CosTheta(w));
```


#parec[
  For the same reasons as in the `Project()` method, an `RGBIlluminantSpectrum` is used to convert each RGB value to spectral samples.
][
  出于与 `Project()` 方法相同的原因，使用 `RGBIlluminantSpectrum` 将每个 RGB 值转换为光谱样本。
]

```cpp
<<Update sum for projection light pixel>>=
RGB rgb;
for (int c = 0; c < 3; ++c)
    rgb[c] = image.GetChannel({x, y}, c);
RGBIlluminantSpectrum s(*imageColorSpace, ClampZero(rgb));
sum += s.Sample(lambda) * dwdA;
```


#parec[
  The final integrated value includes a factor of the area that was integrated over, $A$, and is divided by the total number of pixels.
][
  最终的积分值包含了被积分的面积因子 A，并除以像素总数。
]

```cpp
<<Return final power for projection light>>=
return scale * A * sum / (image.Resolution().x * image.Resolution().y);
```


=== Goniophotometric Diagram Lights
<goniophotometric-diagram-lights>


#parec[
  A #emph[goniophotometric diagram] describes the angular distribution of luminance from a point light source; it is widely used in illumination engineering to characterize lights. @fig:goniophotometric-diagram shows an example of a goniophotometric diagram in two dimensions. In this section, we will implement a light source that uses goniophotometric diagrams encoded in 2D image maps to describe the emission distribution lights.
][
  #emph[光度分布图] 描述了点光源的亮度角分布；它广泛用于照明工程中以表征灯光。 @fig:goniophotometric-diagram 显示了二维光度分布图的一个示例。在本节中，我们将实现一个使用二维图像地图编码的光度分布图来描述发光分布的光源。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f10.svg"),
  caption: [
    #ez_caption[
      An Example of a Goniophotometric Diagram Specifying an Outgoing Light Distribution from a Point Light Source in 2D. The emitted intensity is defined in a fixed set of directions on the unit sphere, and the intensity for a given outgoing direction $omega$ is found by interpolating the intensities of the adjacent samples.
    ][
      二维中指定点光源出射光分布的光度分布图示例。发射的强度在单位球面上的一组固定方向中定义，对于给定的出射方向 $omega$，其强度通过插值相邻样本的强度来确定。
    ]
  ],
)<goniophotometric-diagram>

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f11.svg"),
  caption: [
    #ez_caption[
      Goniophotometric Diagrams for Real-World Light Sources. These images are encoded using an equal-area parameterization (@spherical-parameterizations).
      (a) A light that mostly illuminates in its up direction, with only a
      small amount of illumination in the down direction. (b) A light that
      mostly illuminates in the down direction. (c) A light that casts
      illumination both above and below.
    ][
      现实世界光源的光度分布图。 这些图像使用等面积参数化编码（@spherical-parameterizations）。(a) 主要向上方向照明的光，只有少量向下照明。(b)
      主要向下方向照明的光。(c) 同时向上和向下投射光的光。
    ]
  ],
)<gonio-images>



#parec[
  @fig:gonio-images shows a few goniophotometric diagrams encoded as image maps and @fig:light-gonio-renderings shows a scene rendered with a light source that uses one of these images to modulate its directional distribution of illumination. The `GoniometricLight` uses the equal-area parameterization of the sphere that was introduced in @spherical-parameterizations, so the center of the image corresponds to the "up" direction.
][
  @fig:gonio-images 显示了一些编码为图像地图的光度分布图，@fig:light-gonio-renderings 显示了一个使用这些图像之一来调节其方向分布的光源的场景渲染。 `GoniometricLight` 使用了在@spherical-parameterizations 中介绍的球体的等面积参数化，因此图像的中心对应于“上”方向。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f12.svg"),
  caption: [
    #ez_caption[
      Scene Rendered Using the Goniophotometric Diagram from @fig:gonio-images(b). Even though a point light source is the basis of this light, including the directional variation of a realistic light improves the visual realism of the rendered image. (Dragon model courtesy of the Stanford Computer Graphics Laboratory.)
    ][
      Scene Rendered Using the Goniophotometric Diagram from @fig:gonio-images(b). 尽管点光源是此光的基础，加入现实光的方向变化提升了渲染图像的视觉真实感。
    ]
  ],
)<light-gonio-renderings>


```cpp
<<GoniometricLight Definition>>=
class GoniometricLight : public LightBase {
  public:
    <<GoniometricLight Public Methods>>
  private:
    <<GoniometricLight Private Members>>
};
```


#parec[
  The `GoniometricLight` constructor takes a base intensity, an image map that scales the intensity based on the angular distribution of light, and the usual transformation and medium interface; these are stored in the following member variables. In the following methods, only the first channel of the image map will be used to scale the light's intensity: the `GoniometricLight` does not support specifying color via the image. It is the responsibility of calling code to convert RGB images to luminance or some other appropriate scalar value before passing the image to the constructor here.
][
  `GoniometricLight` 构造函数接受一个基础强度、一个根据光的角分布缩放强度的图像地图，以及通常的变换和介质接口；这些存储在以下成员变量中。 在以下方法中，图像地图的第一个通道将用于缩放光的强度：`GoniometricLight` 不支持通过图像指定颜色。 调用代码有责任在将图像传递给构造函数之前将 RGB 图像转换为亮度或其他适当的标量值。
]

```cpp
<<GoniometricLight Private Members>>=
const DenselySampledSpectrum *Iemit;
Float scale;
Image image;
```


#parec[
  The `SampleLi()` method follows the same form as that of `SpotLight` and `ProjectionLight`, so it is not included here. It uses the following method to compute the radiant intensity for a given direction.
][
  `SampleLi()` 方法与 `SpotLight` 和 `ProjectionLight` 的形式相同，因此这里不包括。它使用以下方法计算给定方向的辐射强度。
]

```cpp
<<GoniometricLight Public Methods>>=
SampledSpectrum I(Vector3f w, const SampledWavelengths &lambda) const {
    Point2f uv = EqualAreaSphereToSquare(w);
    return scale * Iemit->Sample(lambda) * image.LookupNearestChannel(uv, 0);
}
```

#parec[
  Because it uses an equal-area mapping from the image to the sphere, each pixel in the image subtends an equal solid angle and the change of variables factor for integrating over the sphere of directions is the same for all pixels. Its value is $4 pi$, the ratio of the area of the unit sphere to the unit square.
][
  因为它使用从图像到球体的等面积映射，图像中的每个像素都占据相等的立体角，因此在方向球体上积分的变量变化因子对于所有像素都是相同的。 其值为 $4 pi$，即单位球体与单位正方形的面积比。
]

```cpp
<<GoniometricLight Method Definitions>>=
SampledSpectrum GoniometricLight::Phi(SampledWavelengths lambda) const {
    Float sumY = 0;
    for (int y = 0; y < image.Resolution().y; ++y)
        for (int x = 0; x < image.Resolution().x; ++x)
            sumY += image.GetChannel({x, y}, 0);
    return scale * Iemit->Sample(lambda) * 4 * Pi * sumY /
           (image.Resolution().x * image.Resolution().y);
}
```

