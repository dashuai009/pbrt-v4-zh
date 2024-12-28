#import "../template.typ": parec, ez_caption

== Distant_Lights
<Distant_Lights>

#parec[
  Another useful light source type is the #emph[distant light];, also known as a #emph[directional light];. It describes an emitter that deposits illumination from the same direction at every point in space. Such a light is also called a point light "at infinity," since, as a point light becomes progressively farther away, it acts more and more like a directional light. For example, the sun (as considered from Earth) can be thought of as a directional light source. Although it is actually an area light source, the illumination effectively arrives at Earth in nearly parallel beams because it is so far away.
][
  另一种有用的光源类型是#emph[远距离光];，也称为#emph[平行光];。它描述了一种从空间中每个点以相同方向发出照明的发射器。这样的光也被称为“无穷远点光源”，因为当一个点光源逐渐远离时，它的行为越来越像平行光。 例如，太阳（从地球上看）可以被认为是一个方向光源。尽管它实际上是一个区域光源，但由于距离太远，光线实际上以几乎平行的光束到达地球。
]

```cpp
<<DistantLight Definition>>=
class DistantLight : public LightBase {
  public:
    <<DistantLight Public Methods>>
  private:
    <<DistantLight Private Members>>
};
```

#parec[
  The `DistantLight` constructor does not take a `MediumInterface` parameter; the only reasonable medium for a distant light to be in is a vacuum—if it was itself in a medium that absorbed any light at all, then all of its emission would be absorbed, since it is modeled as being infinitely far away.
][
  `DistantLight` 构造函数不接受 `MediumInterface` 参数；远光唯一合理的介质是真空——如果它本身处于吸收任何光的介质中，那么它的所有发射都会被吸收，因为它被建模为无限远。
]

```cpp
<<DistantLight Public Methods>>=
DistantLight(const Transform &renderFromLight, Spectrum Lemit,
             Float scale)
    : LightBase(LightType::DeltaDirection, renderFromLight, {}),
      Lemit(LookupSpectrum(Lemit)), scale(scale) {}


<<DistantLight Private Members>>=
const DenselySampledSpectrum *Lemit;
Float scale;
```

#parec[
  Some of the `DistantLight` methods need to know the bounds of the scene. Because `pbrt` creates lights before the scene geometry, these bounds are not available when the `DistantLight` constructor executes. Therefore, `DistantLight` implements the optional `Preprocess()` method where it converts the scene's #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] to a bounding sphere, which will be an easier representation to work with in the following.
][
  一些 `DistantLight` 方法需要知道场景的边界。由于 `pbrt` 是在场景几何体创建之前就创建光源的，因此在 `DistantLight` 构造函数执行时，这些边界是不可用的。 因此，`DistantLight` 实现了可选的 `Preprocess()` 方法，在其中将场景的 #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] 转换为一个包围球，这将在接下来的处理中更容易处理。
]

```cpp
<<DistantLight Public Methods>>+=
void Preprocess(const Bounds3f &sceneBounds) {
    sceneBounds.BoundingSphere(&sceneCenter, &sceneRadius);
}

<<DistantLight Private Members>>+=
Point3f sceneCenter;
Float sceneRadius;
```


#parec[
  The incident radiance at a point $p$ due to a distant light can be described using a Dirac delta distribution,
][
  由于远光在点 $p$ 处的入射辐射度可以用狄拉克 δ 分布描述，
]
$ L_i (p , omega) = L_e delta (omega - omega_l) , $

#parec[
  where the light's direction is $omega_l$. Given this definition, the implementation of the `SampleLi()` method is straightforward: the incident direction and radiance are always the same. The only interesting bit is the initialization of the #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] that provides the second point for the future shadow ray. It is set along the distant light's incident direction at a distance of twice the radius of the scene's bounding sphere, guaranteeing a second point that is outside of the scene's bounds (@fig:distant-light-shadow-ray).
][
  其中光的方向是 $omega_l$。 鉴于这个定义，`SampleLi()` 方法的实现很简单：入射方向和辐射度总是相同的。唯一有趣的是 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] 的初始化，它提供了未来阴影光线的第二个点。 它沿着远光的入射方向设置在场景包围球半径的两倍处，确保第二个点在场景边界之外（@fig:distant-light-shadow-ray）。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f13.svg"),
  caption: [
    #ez_caption[
      Computing the Second Point for a DistantLight Shadow Ray. Given a sphere that bounds the scene (dashed line) with radius $r$ and given some point in the scene $upright(p)$, if we then move a distance of $2r$ along any vector from $upright(p)$, the resulting point must be outside of the scene’s bound. If a shadow ray to such a point is unoccluded, then we can be certain that the point $upright(p)$ receives illumination from a distant light along the vector’s direction.
    ][
      计算用于 DistantLight 阴影光线的第二个点。给定一个包围场景的球体（虚线）半径为 $r$，以及场景中的某一点 $upright(p)$，如果沿任意从 $upright(p)$ 出发的向量移动 $2r$ 的距离，则所得点必定在场景边界之外。如果指向该点的阴影光线未被遮挡，我们可以确定点 $upright(p)$ 沿该向量方向能够接收到来自远光源的照明。
    ]
  ],
)<distant-light-shadow-ray>



```cpp
<<DistantLight Public Methods>>+=
pstd::optional<LightLiSample>
SampleLi(LightSampleContext ctx, Point2f u, SampledWavelengths lambda,
         bool allowIncompletePDF) const {
    Vector3f wi = Normalize(renderFromLight(Vector3f(0, 0, 1)));
    Point3f pOutside = ctx.p() + wi * (2 * sceneRadius);
    return LightLiSample(scale * Lemit->Sample(lambda), wi, 1,
                         Interaction(pOutside, nullptr));
}
```

#parec[
  The distant light is different than the lights we have seen so far in that the amount of power it emits is related to the spatial extent of the scene. In fact, it is proportional to the area of the scene receiving light. To see why this is so, consider a disk of area $A$ being illuminated by a distant light with emitted radiance $L^e$ where the incident light arrives along the disk's normal direction. The total power reaching the disk is $Phi = A L^e$. As the size of the receiving surface varies, power varies proportionally.
][
  远光与我们之前看到的光源不同，因为它发出的功率与场景的空间范围有关。 事实上，它与接收光的场景面积成正比。要理解为什么会这样，考虑一个面积为 $A$ 的圆盘被远光以发射辐射度 $L^e$ 照亮，其中入射光沿圆盘的法线方向到达。 到达圆盘的总功率是 $Phi = A L^e$。随着接收表面大小的变化，功率也成比例变化。
]

#parec[
  To find the emitted power for a #link("<DistantLight>")[DistantLight];, it is impractical to compute the total surface area of the objects that are visible to the light. Instead, we will approximate this area with a disk inside the scene's bounding sphere oriented in the light's direction (@fig:scene-bbox-facing-disk). This will always overestimate the actual area but is sufficient for the needs of code elsewhere in the system.
][
  要找到 #link("<DistantLight>")[DistantLight] 的发射功率，计算可见光的物体的总表面积是不切实际的。 相反，我们将用一个位于场景包围球内的圆盘来近似这个面积，该圆盘的方向与光的方向一致（@fig:scene-bbox-facing-disk）。 这虽然会高估实际面积，但对于系统中其他代码的需求已经足够。
]


#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f14.svg"),
  caption: [
    #ez_caption[
      An approximation of the power emitted by a distant light into a given scene can be obtained by finding the sphere that bounds the scene, computing the area of an inscribed disk, and computing the power that arrives on the surface of that disk.
    ][
      可以通过以下方法近似计算远光源向给定场景发射的功率：找到包围场景的球体，计算该球体内切圆盘的面积，并计算到达该圆盘表面的功率。
    ]
  ],
)<scene-bbox-facing-disk>


```cpp
<<DistantLight Method Definitions>>=
SampledSpectrum DistantLight::Phi(SampledWavelengths lambda) const {
    return scale * Lemit->Sample(lambda) * Pi * Sqr(sceneRadius);
}
```


