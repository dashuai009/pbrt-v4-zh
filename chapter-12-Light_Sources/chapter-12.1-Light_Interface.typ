#import "../template.typ": parec, ez_caption

== Light Interface
<light-interface>
#parec[
  The #link("<Light>")[`Light`] class defines the interface that light sources must implement. It is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/light.h")[`base/light.h`] and all the light implementations in the following sections are in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.h")[`lights.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.cpp")[`lights.cpp`];.
][
  #link("<Light>")[`Light`] 类定义了光源必须实现的接口，位于文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/light.h")[`base/light.h`] 中。本章所有光源的实现都在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.h")[`lights.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/lights.cpp")[`lights.cpp`] 中。
]

```cpp
<<Light Definition>>=
class Light : public TaggedPointer<<<Light Source Types>> > {
  public:
    <<Light Interface>>
};
```

#parec[
  This chapter will describe all 9 of the following types of light source.
][
  本章将描述以下 9 种类型的光源。
]

```cpp
<<Light Source Types>>=
PointLight, DistantLight, ProjectionLight, GoniometricLight, SpotLight,
DiffuseAreaLight, UniformInfiniteLight, ImageInfiniteLight,
PortalImageInfiniteLight
```

#parec[
  All lights must be able to return their total emitted power, $Phi$. Among other things, this makes it possible to sample lights according to their relative power in the forthcoming #link("../Light_Sources/Light_Sampling.html#PowerLightSampler")[`PowerLightSampler`];. Devoting more samples to the lights that make the largest contribution can significantly improve rendering efficiency.
][
  所有光源都必须能够返回其总发射功率 $Phi$。这样一来，就可以在后续的 #link("../Light_Sources/Light_Sampling.html#PowerLightSampler")[`PowerLightSampler`] 中根据光源的相对功率进行采样。将更多的样本分配给对渲染贡献最大的光源，可以显著提高渲染效率。
]

```cpp
SampledSpectrum Phi(SampledWavelengths lambda) const;
```


#parec[
  The `Light` interface does not completely abstract away all the differences among different types of light source. While doing so would be desirable in principle, in practice `pbrt`'s integrators sometimes need to handle different types of light source differently, both for efficiency and for correctness. We have already seen an example of this issue in the #link("../Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`] in @random-walk-integrator . There, "infinite" lights received special handling since they must be considered for rays that escape the scene without hitting any geometry.
][
  `Light` 接口并未完全屏蔽不同类型光源之间的差异。尽管理论上这样做是理想的，但在实践中，`pbrt` 的积分器有时需要以不同的方式处理不同类型的光源，以兼顾效率和正确性。我们已经在@random-walk-integrator 的 #link("../Introduction/pbrt_System_Overview.html#RandomWalkIntegrator")[`RandomWalkIntegrator`] 中看到了一个相关示例。在那里，“无限远光源”被特殊处理，因为它必须考虑那些逃出场景、不碰撞任何几何体的光线。
]

#parec[
  Another example is that the Monte Carlo algorithms that sample illumination from light sources need to be aware of which lights are described by delta distributions, since this affects some of their computations. Lights therefore categorize themselves into one of a few different types; the `Type()` method returns which one a light is.
][
  另一个例子是，在对光源采样时，蒙特卡罗算法需要知道哪些光源由 delta 分布描述，因为这会影响它们的一些计算。因此，需要将光源分类为几种不同的类型；`Type()` 方法返回光源的类型。
]

```cpp
<<Light Interface>>+=
LightType Type() const;
```

#parec[
  There are four different light categories:
][
  有四种不同的光源类别：
]

#parec[
  - `DeltaPosition`: lights that emit solely from a single point in space. ("Delta" refers to the fact that such lights can be described by Dirac delta distributions.)
][
  - `DeltaPosition`：仅从空间中的单一点发射光的光源。（"Delta"指的是这种光源可以用 delta 分布描述。）
]

#parec[
  - `DeltaDirection`: lights that emit radiance along a single direction.
][
  - `DeltaDirection`：沿单一方向发射辐射的光源。
]
#parec[
  - `Area`: lights that emit radiance from the surface of a geometric shape.
][
  - `Area`：从几何形状的表面发射辐射的光源。
]

#parec[
  - `Infinite`: lights "at infinity" that do not have geometry associated with them but provide radiance to rays that escape the scene.
][
  - `Infinite`：位于“无限远”的光源，没有与之关联的几何体，但为逸出场景的光线提供辐射。
]

```cpp
<<LightType Definition>>=
enum class LightType { DeltaPosition, DeltaDirection, Area, Infinite };
```

#parec[
  A helper function checks if a light is defined using a Dirac delta distribution.
][
  一个辅助函数检查光源是否使用狄拉克 delta 分布定义。
]

```cpp
<<Light Inline Functions>>=
bool IsDeltaLight(LightType type) {
    return (type == LightType::DeltaPosition ||
            type == LightType::DeltaDirection);
}
```


#parec[
  Being able to sample directions at a point where illumination may be incident is an important sampling operation for rendering. Consider a diffuse surface illuminated by a small spherical area light source (@fig:mc-small-sphere-light): sampling directions using the BSDF's sampling distribution is likely to be very inefficient because the light is only visible within a small cone of directions from the point. A much better approach is to instead use a sampling distribution that is based on the light source. In this case, the sampling routine should choose from among only those directions where the sphere is potentially visible.
][
  能够在可能接收到照明的点上采样方向，是渲染的重要采样操作。考虑一个由小球形区域光源照亮的漫反射表面（@fig:mc-small-sphere-light）：使用 BSDF 的采样分布采样方向可能非常低效，因为光源仅在从该点的一个小锥体方向内可见。一个更好的方法是使用基于光源本身的采样分布。在这种情况下，采样过程应仅从可能可以看见球体的那些方向中选择。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f01.png"),
  caption: [
    #ez_caption[
      An effective sampling strategy for choosing an incident direction from a point for direct lighting computations is to allow the light source to define a distribution of directions with respect to solid angle at the point. Here, a small spherical light source is illuminating the point. The cone of directions that the sphere subtends is a much better sampling distribution to use than a uniform distribution over the hemisphere, for example.
    ][
      在直接光照计算中为某个点选择入射方向时，一种有效的采样策略是让光源在该点处相对于立体角定义一个方向分布。在这个例子中，一个小球形光源正在照亮该点。相比于在半球上均匀分布，球体所覆盖的方向锥体提供了一个更优的采样分布。
    ]
  ],
)<mc-small-sphere-light>



#parec[
  This important task is the responsibility of implementations of the `SampleLi()` method. Its caller passes a #link("<LightSampleContext>")[`LightSampleContext`] that provides information about a reference point in the scene, and the light optionally returns a #link("<LightLiSample>")[`LightLiSample`] that encapsulates incident radiance, information about where it is being emitted from, and the value of the probability density function (PDF) for the sampled point. If it is impossible for light to reach the reference point or if there is no valid light sample associated with `u`, an invalid sample can be returned. Finally, `allowIncompletePDF` indicates whether the sampling routine may skip generating samples for directions where the light's contribution is small. This capability is used by integrators that apply MIS compensation (@multiple-importance-sampling).
][
  `SampleLi()` 方法负责实现该任务。其调用者须传递一个 #link("<LightSampleContext>")[`LightSampleContext`];，提供参考点处的场景信息。光源可选择返回一个 #link("<LightLiSample>")[`LightLiSample`];，该样本封装了入射辐射、发射点的信息以及采样点的概率密度函数（PDF）的值。如果光无法到达参考点，或者与 `u` 没有有效的光样本关联，则可以返回无效样本。最后，`allowIncompletePDF` 指示采样例程是否允许跳过生成那些光贡献较小方向的样本。此功能由应用多重重要性采样（MIS）补偿的积分器使用（@multiple-importance-sampling）。
]

```cpp
<<Light Interface>>+=
pstd::optional<LightLiSample>
SampleLi(LightSampleContext ctx, Point2f u, SampledWavelengths lambda,
         bool allowIncompletePDF = false) const;
```

#parec[
  The `LightSampleContext` takes the usual role of encapsulating just as much information about the point receiving illumination as the various sampling routines need.
][
  `LightSampleContext` 封装了接收照明的点所需信息。
]

```cpp
<<LightSampleContext Definition>>=
class LightSampleContext {
public:
  <<LightSampleContext Public Methods>>
    LightSampleContext(const SurfaceInteraction &si)
           : pi(si.pi), n(si.n), ns(si.shading.n) {}
    LightSampleContext(const Interaction &intr) : pi(intr.pi) {}
    LightSampleContext(Point3fi pi, Normal3f n, Normal3f ns)
           : pi(pi), n(n), ns(ns) {}
    Point3f p() const { return Point3f(pi); }
 <<LightSampleContext Public Members>>
    Point3fi pi;
    Normal3f n, ns;
};
```


#parec[
  The context just stores a point in the scene, a surface normal, and a shading normal. The point is provided as a `Point3fi` that makes it possible to include error bounds around the computed ray intersection point. Some of the following sampling routines will need this information as part of their sampling process. If the point is in a scattering medium and not on a surface, the two normals are left at their default $(0 , 0 , 0)$ values.
][
  该上下文仅存储场景中的一个点、一个表面法线和一个着色法线。点以 `Point3fi` 的形式提供，交点附带一个误差范围。后续的一些采样过程将需要此信息作为其采样过程的一部分。如果该点位于散射介质中而不在表面上，则两个法线保持其默认值 $(0 , 0 , 0)$。
]

#parec[
  Note that the context does not include a time—`pbrt`'s light sources do not support animated transformations. An exercise at the end of the chapter discusses issues related to extending them to do so.
][
  请注意，上下文不包括时间，因为 `pbrt` 的光源不支持动画变换。本章末尾的练习讨论了扩展它们以支持动画变换的相关问题。
]

```cpp
<<LightSampleContext Public Members>>=
Point3fi pi;
Normal3f n, ns;
```

#parec[
  As with the other `Context` classes, a variety of constructors make it easy to create a `LightSampleContext`.
][
  与其他 `Context` 类一样，提供了各种构造函数，以便创建 `LightSampleContext`。
]

```cpp
<<LightSampleContext Public Methods>>=
LightSampleContext(const SurfaceInteraction &si)
    : pi(si.pi), n(si.n), ns(si.shading.n) {}
LightSampleContext(const Interaction &intr) : pi(intr.pi) {}
LightSampleContext(Point3fi pi, Normal3f n, Normal3f ns)
    : pi(pi), n(n), ns(ns) {}
```


#parec[
  A convenience method provides the point as a regular `Point3f` for the routines that would prefer to access it as such.
][
  一个便捷方法返回了常规 `Point3f` 类型的点，供那些希望以这种方式访问它的程序使用。
]

```cpp
<<LightSampleContext Public Methods>>+=
Point3f p() const { return Point3f(pi); }
```


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f02.png"),
  caption: [
    #ez_caption[
      The `Light::SampleLi()` method returns incident radiance from the light at a point and also returns the direction vector $omega_i$ that gives the direction from which radiance is arriving.
    ][
      `Light::SampleLi()` 方法返回光源在某一点的入射辐射，并返回方向向量 $omega_i$，该向量指示辐射到达的方向。]
  ],
)<light-sample-l>

#parec[
  Light samples are bundled up into instances of the `LightLiSample` structure. The radiance `L` is the amount of radiance leaving the light toward the receiving point; it does not include the effect of extinction due to participating media or occlusion, if there is an object between the light and the receiver. `wi` gives the direction along which light arrives at the point that was specified via the #link("<LightSampleContext>")[`LightSampleContext`] (see @fig:light-sample-l) and the point from which light is being emitted is provided by `pLight`. Finally, the PDF value for the light sample is returned in `pdf`. This PDF should be measured with respect to solid angle at the receiving point.
][
  光样本被封装在 `LightLiSample` 结构中。辐射量 `L` 表示从光源出发、指向接收点的辐射强度；如果光源和接收点之间存在物体，则该值不包含由参与介质或遮挡造成的消光效应。`wi` 表示光线从光源到达接收点的方向（见 @fig:light-sample-l），而光线的发出点由 `pLight` 提供。最后，`pdf` 返回该光样本的概率密度函数值。该 PDF 应相对于接收点处的立体角来进行度量。
]

```cpp
<<LightLiSample Definition>>=
struct LightLiSample {
  <<LightLiSample Public Methods>>
    LightLiSample() = default;
    PBRT_CPU_GPU
    LightLiSample(const SampledSpectrum &L, Vector3f wi, Float pdf, const Interaction &pLight)
        : L(L), wi(wi), pdf(pdf), pLight(pLight) {}
    std::string ToString() const;

  SampledSpectrum L;
  Vector3f wi;
  Float pdf;
  Interaction pLight;
};
```


#parec[
  Just as we saw for perfect specular reflection and transmission with BSDFs, light sources that are defined in terms of delta distributions fit naturally into this sampling framework, although they require care on the part of the routines that call their sampling methods, since there are implicit delta distributions in the radiance and PDF values that they return. For the most part, these delta distributions naturally cancel out when estimators are evaluated, although multiple importance sampling code must be aware of this case, just as with BSDFs. For samples taken from delta distribution lights, the `pdf` value in the returned #link("<LightLiSample>")[`LightLiSample`] should be set to 1.
][
  正如我们在 BSDF 中看到的完美镜面反射和透射一样，以狄拉克 delta 分布定义的光源自然适合这个采样框架，但调用其采样方法的函数需要小心，因为它们返回的辐射和 PDF 值中存在隐式 delta 分布。在大多数情况下，当评估估计器时，这些 delta 分布自然会相互抵消，尽管多重重要性采样代码必须意识到这种情况，就像 BSDF 一样。对于从 delta 分布光源采样的样本，返回的 #link("<LightLiSample>")[`LightLiSample`] 中的 `pdf` 值应设置为 1.
]

#parec[
  Related to this, the `PDF_Li()` method returns the value of the PDF for sampling the given direction `wi` from the point represented by `ctx`. This method is particularly useful in the context of multiple importance sampling (MIS) where, for example, the BSDF may have sampled a direction and we need to compute the PDF for the light's sampling that direction in order to compute the MIS weight. Implementations of this method may assume that a ray from `ctx` in direction `wi` has already been found to intersect the light source, and as with `SampleLi()`, the PDF should be measured with respect to solid angle. Here, the returned PDF value should be 0 if the light is described by a Dirac delta distribution.
][
  与此相关的 `PDF_Li()` 方法返回从 `ctx` 表示的点采样给定方向 `wi` 的概率密度函数（PDF）值。此方法在多重重要性采样（MIS）的上下文中特别有用，例如，BSDF 可能已经采样了一个方向，我们需要计算光源采样该方向的 PDF，以便计算 MIS 权重。此方法的实现可以假设从 `ctx` 沿方向 `wi` 的光线已经被发现与光源相交，并且与 `SampleLi()` 一样，PDF 应该以立体角为单位。在这里，如果光源由狄拉克 delta 分布描述，则返回的 PDF 值应为 0。
]

```cpp
<<Light Interface>>+=
Float PDF_Li(LightSampleContext ctx, Vector3f wi,
             bool allowIncompletePDF = false) const;
```

#parec[
  If a ray happens to intersect an area light source, it is necessary to find the radiance that is emitted back along the ray. This task is handled by the `L()` method, which takes local information about the intersection point and the outgoing direction. This method should never be called for any light that does not have geometry associated with it.
][
  如果一条光线碰巧与区域光源相交，则需要找到沿光线发射回去的辐射。方法 `L()` 处理该任务，该方法获取有关交点和出射方向的局部信息。对于没有几何体关联的光源，永远不应调用此方法。
]

```cpp
<<Light Interface>>+=
SampledSpectrum L(Point3f p, Normal3f n, Point2f uv, Vector3f w,
                  const SampledWavelengths &lambda) const;
```

#parec[
  Another interface method that only applies to some types of lights is `Le()`. It enables infinite area lights to contribute radiance to rays that do not hit any geometry in the scene. This method should only be called for lights that report their type to be #link("<LightType::Infinite>")[`LightType::Infinite`];.
][
  另一个仅适用于某些类型光源的接口方法是 `Le()`。它使得无限区域光源能够为未击中场景中任何几何体的光线贡献辐射。此方法仅应为 #link("<LightType::Infinite>")[`LightType::Infinite`] 类型的光源调用。
]

```cpp
<<Light Interface>>+=
SampledSpectrum Le(const Ray &ray, const SampledWavelengths &lambda) const;
```


#parec[
  Finally, the `Light` interface includes a `Preprocess()` method that is invoked prior to rendering. It takes the rendering space bounds of the scene as an argument. Some light sources need to know these bounds and they are not available when lights are initially created, so this method makes the bounds available to them.
][
  最后，`Light` 接口包括一个 `Preprocess()` 方法，该方法在渲染之前调用。它以场景的渲染空间边界作为参数。一些光源需要知道这些边界，而这些边界在光源最初创建时不可用，因此此方法使得边界可用。
]

```cpp
<<Light Interface>>+=
void Preprocess(const Bounds3f &sceneBounds);
```


#parec[
  There are three additional light interface methods that will be defined later, closer to the code that uses them. #link("../Light_Sources/Light_Sampling.html#Light::Bounds")[`Light::Bounds()`] provides information that bounds the light's spatial and directional emission distribution; one use of it is to build acceleration hierarchies for light sampling, as is done in @bvh-light-sampling. `Light::SampleLe()` and `Light::PDF_Le()` are used to sample rays leaving light sources according to their distribution of emission. They are cornerstones of bidirectional light transport algorithms and are defined in the online edition of the book along with algorithms that use them.
][
  还有三个额外的光源接口方法将在后面定义，在使用它们的代码的附近。#link("../Light_Sources/Light_Sampling.html#Light::Bounds")[`Light::Bounds()`] 提供了限制光源空间和方向发射分布的信息；其一个用途是为光采样构建加速层次结构，在@bvh-light-sampling 中介绍。`Light::SampleLe()` 和 `Light::PDF_Le()` 用于根据光源的发射分布采样离开光源的光线。它们是双向光传输算法的基石，并在本书的在线版中与使用它们的算法一起定义。
]


=== Photometric Light Specification
<photometric-light-specification>
#parec[
  `pbrt` uses radiometry as the basis of its model of light transport. However, light sources are often described using photometric units—a light bulb package might report that it emits 1,000 lumens of light, for example. Beyond their familiarity, one advantage of photometric descriptions of light emission is that they also account for the variation of human visual response with wavelength. It is also more intuitive to describe lights in terms of the visible power that they emit rather than the power they consume in the process of doing so. (Related to this topic, recall the discussion of luminous efficacy in @light-emission.)
][
  `pbrt` 使用辐射测量为基础建立其光传输模型。然而，光源通常使用光度单位来描述——例如，灯泡包装可能会标明它发出 1000 流明的光。除了人们对这些单位更为熟悉之外，使用光度单位描述光的发射还有一个优点，即它考虑了人眼对不同波长光的响应差异。相较于用光源在发光过程中消耗的能量，使用其发出的可见光功率来描述光源也更加直观。（关于这个话题，可以回顾 @light-emission 中对发光效率的讨论。）
]

#parec[
  Therefore, light sources in `pbrt`'s scene description files can be specified in terms of the luminous power that they emit. These specifications are then converted to radiometric quantities in the code that initializes the scene representation. Radiometric values are then passed to the constructors of the #link("<Light>")[Light];`Light` implementations in this chapter, often in the form of a base spectral distribution and a scale factor that is applied to it.
][
  因此，`pbrt` 的场景描述文件允许以光通量（luminous power）来指定光源。这些规格随后在初始化场景表示的代码中转换为辐射量。然后将辐射量传递给本章中 #link("<Light>")[Light];`Light` 的构造函数，通常以基础光谱分布和需要乘上的比例因子的形式。
]

=== The LightBase Class
<the-lightbase-class>
#parec[
  As there was with classes like #link("../Cameras_and_Film/Camera_Interface.html#CameraBase")[CameraBase] and #link("../Cameras_and_Film/Film_and_Imaging.html#FilmBase")[FilmBase] for #link("../Cameras_and_Film/Camera_Interface.html#Camera")[Camera] and #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[Film] implementations, there is a #link("<LightBase>")[LightBase];`LightBase` class that all of `pbrt`'s light sources inherit from. `LightBase` stores a number of values that are common to all of `pbrt`'s lights and is thus able to implement some of the #link("<Light>")[Light];`Light` interface methods. It is not required that a #link("<Light>")[Light];`Light` in `pbrt` inherit from #link("<LightBase>")[LightBase];`LightBase`, but lights must provide implementations of a few more #link("<Light>")[Light];`Light` methods if they do not.
][
  就像 #link("../Cameras_and_Film/Camera_Interface.html#CameraBase")[`CameraBase`] 和 #link("../Cameras_and_Film/Film_and_Imaging.html#FilmBase")[`FilmBase`] 类用于 #link("../Cameras_and_Film/Camera_Interface.html#Camera")[`Camera`] 和 #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] 实现一样，`pbrt` 的所有光源都继承自 #link("<LightBase>")[`LightBase`]; 类。`LightBase` 存储了一些对 `pbrt` 的所有光源通用的值，因此能够实现一些 #link("<Light>")[`Light`]; 接口方法。`pbrt` 中的 #link("<Light>")[`Light`]; 不需要继承自 #link("<LightBase>")[`LightBase`]; ，但如果不继承，则光源必须提供更多 #link("<Light>")[`Light`]; 方法的实现。
]

```cpp
<<LightBase Definition>>=
class LightBase {
  public:
    <<LightBase Public Methods>>
      LightBase(LightType type, const Transform &renderFromLight,
                const MediumInterface &mediumInterface);
      LightType Type() const { return type; }
      SampledSpectrum L(Point3f p, Normal3f n, Point2f uv, Vector3f w,
                        const SampledWavelengths &lambda) const {
          return SampledSpectrum(0.f);
      }
      SampledSpectrum Le(const Ray &, const SampledWavelengths &) const {
          return SampledSpectrum(0.f);
      }
  protected:
    <<LightBase Protected Methods>>
      static const DenselySampledSpectrum *LookupSpectrum(Spectrum s);

    <<LightBase Protected Members>>
      LightType type;
      Transform renderFromLight;
      MediumInterface mediumInterface;
      static InternCache<DenselySampledSpectrum> *spectrumCache;
};
```


#parec[
  The following three values are passed to the #link("<LightBase>")[LightBase];`LightBase` constructor, which stores them in these member variables:
][
  以下三个值被传递给 #link("<LightBase>")[LightBase];`LightBase` 构造函数，并存储在这些成员变量中：
]

#parec[
  - `type` characterizes the light's type.
][
  - `type` 描述了光源的类型。
]

#parec[
  - `renderFromLight` is a transformation that defines the light's coordinate system with respect to rendering space. As with shapes, it is often handy to be able to implement a light assuming a particular coordinate system (e.g., that a spotlight is always located at the origin of its light space, shining down the $+$z axis). The rendering-from-light transformation makes it possible to place such lights at arbitrary positions and orientations in the scene.
][
  - `renderFromLight` 是一个转换，定义了光源相对于渲染空间的坐标系。与形状一样，假设特定坐标系来实现光源通常是很方便的（例如，假设聚光灯总是位于其光空间的原点，沿 $+$z 轴照射）。从光源到渲染空间的转换使得可以在场景中任意位置和方向放置这样的光源。
]
#parec[
  - A #link("../Volume_Scattering/Media.html#MediumInterface")[MediumInterface] describes the participating medium on the inside and the outside of the light source. For lights that do not have "inside" and "outside" (e.g., a point light), the #link("../Volume_Scattering/Media.html#MediumInterface")[MediumInterface] stores the same #link("../Volume_Scattering/Media.html#Medium")[Medium] on both sides.
][
  - #link("../Volume_Scattering/Media.html#MediumInterface")[MediumInterface] 描述了光源内外的参与介质。对于没有“内外”的光源（例如点光源），#link("../Volume_Scattering/Media.html#MediumInterface")[MediumInterface] 在两侧存储相同的 #link("../Volume_Scattering/Media.html#Medium")[Medium];。
]

```cpp
<<LightBase Protected Members>>=
LightType type;
Transform renderFromLight;
MediumInterface mediumInterface;
```

#parec[
  #link("<LightBase>")[`LightBase`] can thus take care of providing an implementation of the `Type()` interface method.
][
  因此，#link("<LightBase>")[`LightBase`] 可以负责提供 `Type()` 接口方法的实现。
]

```cpp
<<LightBase Public Methods>>=
LightType Type() const { return type; }
```

#parec[
  It also provides default implementations of `L()` and `Le()` so that lights that are not respectively area or infinite lights do not need to implement these themselves.
][
  它还提供了 `L()` 和 `Le()` 的默认的实现，以便不是面积光源或无限光源的光源不需要自己实现这些方法。
]

```cpp
<<LightBase Public Methods>>+=
SampledSpectrum L(Point3f p, Normal3f n, Point2f uv, Vector3f w,
                  const SampledWavelengths &lambda) const {
    return SampledSpectrum(0.f);
}
```

```cpp
<<LightBase Public Methods>>+=
SampledSpectrum Le(const Ray &, const SampledWavelengths &) const {
    return SampledSpectrum(0.f);
}
```

#parec[
  Most of the following `Light` implementations take a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] value in their constructor to specify the light's spectral emission but then convert it to a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] to store in a member variable. By doing so, they enjoy the benefits of efficient sampling operations from tabularizing the spectrum and a modest performance benefit from not requiring dynamic dispatch to call #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] methods.
][
  以下大多数 `Light` 实现在其构造函数中采用一个 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] 值来指定其光谱发射，然后将其转换为 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] 以存储在成员变量中。通过这样做，它们享有通过将光谱表格化来进行高效采样操作的好处，并且由于不需要动态调度来调用 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] 方法而获得适度的性能提升。
]

#parec[
  However, a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] that covers the visible wavelengths uses approximately 2 kB of storage; for scenes with millions of light sources, the memory required may be significant. Therefore, #link("<LightBase>")[`LightBase`] provides a `LookupSpectrum()` method that helps reduce memory use by eliminating redundant copies of the same #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[DenselySampledSpectrum];. It uses the #link("../Utilities/Containers_and_Memory_Management.html#InternCache")[InternCache] from Section #link("../Utilities/Containers_and_Memory_Management.html#sec:interned-objects")[B.4.2] to do so, only allocating storage for a single instance of each #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[DenselySampledSpectrum] provided. If many lights have the same spectral emission profile, the memory savings may be significant.
][
  然而，覆盖可见波长的 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] 使用大约 2 kB 的存储空间；对于拥有数百万光源的场景，所需的内存可能相当可观。因此，#link("<LightBase>")[`LightBase`] 提供了一个 `LookupSpectrum()` 方法，通过消除相同 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] 的冗余拷贝来帮助减少内存使用。它使用第 #link("../Utilities/Containers_and_Memory_Management.html#sec:interned-objects")[B.4.2] 节中的 #link("../Utilities/Containers_and_Memory_Management.html#InternCache")[`InternCache`] 来实现这一点，仅为每个提供的 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] 实例分配存储。如果许多光源具有相同的光谱发射特性，则内存节省可能非常显著。
]

```cpp
<<LightBase Method Definitions>>=
const DenselySampledSpectrum *LightBase::LookupSpectrum(Spectrum s) {
  <<Initialize spectrumCache on first call>>
    static std::mutex mutex;
    mutex.lock();
    if (!spectrumCache)
        spectrumCache = new InternCache<DenselySampledSpectrum>(
    #ifdef PBRT_BUILD_GPU_RENDERER
                        Options->useGPU ? Allocator(&CUDATrackedMemoryResource::singleton) :
    #endif
                        Allocator{});
    mutex.unlock();

  <<Return unique DenselySampledSpectrum from intern cache for s>>
    auto create = [](Allocator alloc, const DenselySampledSpectrum &s) {
        return alloc.new_object<DenselySampledSpectrum>(s, alloc);
    };
    return spectrumCache->Lookup(DenselySampledSpectrum(s), create);
}
```

#parec[
  The `<<Initialize spectrumCache on first call>>` fragment, not included here, handles the details of initializing the spectrumCache, including ensuring mutual exclusion if multiple threads have called LookupSpectrum() concurrently and using an appropriate memory allocator—notably, one that allocates memory on the GPU if GPU rendering has been enabled.
][
  `<<Initialize spectrumCache on first call>>` 片段（本文将其展开了）负责处理初始化 `spectrumCache` 的具体细节，包括在多个线程并发调用 `LookupSpectrum()` 时确保互斥，以及使用适当的内存分配器——特别是当启用了 GPU 渲染时，选择一个能够在 GPU 上分配内存的分配器。
]


#parec[
  The `LookupSpectrum()` method then calls the #link("../Utilities/Containers_and_Memory_Management.html#InternCache::Lookup")[`InternCache::Lookup()`] method that takes a callback function to create the object that is stored in the cache. In this way, it is able to pass the provided allocator to the #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] constructor, which in turn ensures that it is used to allocate the storage needed for its spectral samples.
][
  `LookupSpectrum()` 方法然后调用 #link("../Utilities/Containers_and_Memory_Management.html#InternCache::Lookup")[`InternCache::Lookup()`] 方法，该方法接受一个回调函数来创建存储在缓存中的对象。通过这种方式，它能够将提供的分配器传递给 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`] 构造函数，从而确保用于分配光谱样本所需的存储空间。
]

```cpp
<<Return unique DenselySampledSpectrum from intern cache for s>>=
auto create = [](Allocator alloc, const DenselySampledSpectrum &s) {
    return alloc.new_object<DenselySampledSpectrum>(s, alloc);
};
return spectrumCache->Lookup(DenselySampledSpectrum(s), create);
```

```cpp
<<LightBase Protected Members>>+=
static InternCache<DenselySampledSpectrum> *spectrumCache;
```
