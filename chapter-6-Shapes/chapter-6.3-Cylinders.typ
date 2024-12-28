#import "../template.typ": parec, ez_caption

== Cylinders
<cylinders>
#parec[
  Another useful quadric is the cylinder; `pbrt` provides a cylinder #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] that is centered around the $z$ axis. The user can supply a minimum and maximum $z$ value for the cylinder, as well as a radius and maximum $phi$ sweep value (@fig:cylinder-setting).
][
  另一个有用的二次曲面是圆柱体；`pbrt` 提供了一个以 $z$ 轴为中心的圆柱体#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];。用户可以为圆柱体提供最小和最大 $z$ 值，以及半径和最大 $phi$ 扫掠角度（@fig:cylinder-setting）。
]

#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f07.svg"),
  caption: [
    #ez_caption[The cylinder has a radius of~$r$ and covers a range along the $z$
      axis. A~partial cylinder may be swept by specifying a maximum $phi$
      value.][圆柱体的半径为 $r$，覆盖 $z$ 轴上的一个范围。可以通过指定最大 $phi$ 值来扫掠部分圆柱体。]
  ],
)<cylinder-setting>

```cpp
<<Cylinder Definition>>=
class Cylinder {
  public:
    <<Cylinder Public Methods>>
  private:
    <<Cylinder Private Members>>
};
```

#parec[
  In parametric form, a cylinder is described by the following equations:
][
  圆柱体的参数化方程为：
]
$
  phi.alt & = u phi.alt_(upright("max"))\
  x & = r cos phi.alt\
  y & = r sin phi.alt\
  z & = z_(upright("min")) + v (z_(upright("max")) - z_(upright("min")))
$

#parec[
  @fig:cylinder-rendered shows a rendered image of two cylinders. Like the sphere image, the right cylinder is a complete cylinder, while the left one is a partial cylinder because it has a $phi.alt_"max"$ value less than $2 pi$.
][
  @fig:cylinder-rendered 显示了两个圆柱体的渲染图像。与球体图像类似，右侧的圆柱体是完整的，而左侧的是部分圆柱体，因为它的 $phi.alt_"max"$ 值小于 $2 pi$。
]


#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f09.svg"),
  caption: [
    #parec[ Two Cylinders. A partial cylinder is on the
      left, and a complete cylinder is on the right.
    ][
      两个圆柱体。 左边是部分圆柱体，右边是完整圆柱体。
    ]
  ],
)<cylinder-rendered>


#parec[
  Similar to the #link("../Shapes/Spheres.html#Sphere")[`Sphere`] constructor, the #link("<Cylinder>")[`Cylinder`] constructor takes transformations that define its object space and the parameters that define the cylinder itself. Its constructor just initializes the corresponding member variables, so we will not include it here.
][
  与 #link("../Shapes/Spheres.html#Sphere")[`Sphere`] 构造函数类似，#link("<Cylinder>")[`Cylinder`] 构造函数接受定义其对象空间的转换和定义圆柱体本身的参数。其构造函数只是初始化相应的成员变量，因此我们在此不包括它。
]

```cpp
// <<Cylinder Public Methods>>=
Cylinder(const Transform *renderFromObj, const Transform *objFromRender,
    bool reverseOrientation, Float radius, Float zMin, Float zMax,
    Float phiMax);
```

```cpp
// <<Cylinder Private Members>>=
const Transform *renderFromObject, *objectFromRender;
bool reverseOrientation, transformSwapsHandedness;
Float radius, zMin, zMax, phiMax;
```

=== Area and Bounding
#parec[
  A cylinder is a rolled-up rectangle. If you unroll the rectangle, its height is $z_"max" - z_"min"$, and its width is $r phi.alt_"max"$ :
][
  圆柱体是一个卷成的矩形。如果展开矩形，它的高度是 $z_"max" - z_"min"$，宽度是 $r phi.alt_"max"$
]

```cpp
// <<Cylinder Public Methods>>+=
Float Area() const { return (zMax - zMin) * radius * phiMax; }
```

#parec[
  As was done with the sphere, the cylinder's spatial bounding method computes a conservative bounding box using the $z$ range but does not take into account the maximum $phi.alt$.
][
  与球体一样，圆柱体的空间边界方法使用 $z$ 范围计算保守的边界框，但不考虑 $phi.alt$。
]

```cpp
// <<Cylinder Method Definitions>>=
Bounds3f Cylinder::Bounds() const {
    return (*renderFromObject)(Bounds3f({-radius, -radius, zMin},
                                        { radius,  radius, zMax}));
}
```

#parec[
  Its surface normal bounding function is conservative in two ways: not only does it not account for $phi.alt_"max" < 2 pi$, but the actual set of normals of a cylinder can be described by a circle on the sphere of all directions. However, #link("../Geometry_and_Transformations/Spherical_Geometry.html#DirectionCone")[DirectionCone];'s representation is not able to bound such a distribution more tightly than with the entire sphere of directions, and so that is the bound that is returned.
][
  其表面法线边界函数在两个方面保持保守：不仅不考虑 $phi.alt_"max" < 2 pi$，而且圆柱体的实际法线集合可以用一个方向球上的圆来描述。 然而，#link("../Geometry_and_Transformations/Spherical_Geometry.html#DirectionCone")[`DirectionCone`] 这种表示方法无法比整个方向球更紧密地界定圆柱上的法线分布，因此直接返回整个方向球。
]


```cpp
// <<Cylinder Public Methods>>+=
DirectionCone NormalBounds() const { return DirectionCone::EntireSphere(); }
```

=== Intersection Tests

#parec[
  Also similar to the sphere (and for similar reasons), `Cylinder` provides a `BasicIntersect()` method that returns a #link("../Shapes/Spheres.html#QuadricIntersection")[`QuadricIntersection`] as well as an `InteractionFromIntersection()` method that converts that to a full #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];. Given these, the `Intersect()` method is again a simple composition of them. (If `pbrt` used virtual functions, a design alternative would be to have a `QuadricShape` class that provided a default `Intersect()` method and left `BasicIntersect()` and `InteractionFromIntersection()` as pure virtual functions for subclasses to implement.)
][
  同样类似于球体（出于类似的原因），`Cylinder` 提供了一个 `BasicIntersect()` 方法，该方法返回一个 #link("../Shapes/Spheres.html#QuadricIntersection")[`QuadricIntersection`];，以及一个 `InteractionFromIntersection()` 方法，将其转换为一个完整的 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];。 鉴于此，`Intersect()` 方法再次是它们的简单组合。（如果 `pbrt` 使用虚函数，另一种设计选择是有一个 `QuadricShape` 类，提供默认的 `Intersect()` 方法，并将 `BasicIntersect()` 和 `InteractionFromIntersection()` 作为纯虚函数供子类实现。）
]

```cpp
<<Cylinder Public Methods>>+=
pstd::optional<ShapeIntersection> Intersect(const Ray &ray,
                                            Float tMax = Infinity) const {
    pstd::optional<QuadricIntersection> isect = BasicIntersect(ray, tMax);
    if (!isect) return {};
    SurfaceInteraction intr =
        InteractionFromIntersection(*isect, -ray.d, ray.time);
    return ShapeIntersection{intr, isect->tHit};
}
```

#parec[
  The form of the `BasicIntersect()` method also parallels the sphere's, computing appropriate quadratic coefficients, solving the quadratic equation, and then handling the various cases for partial cylinders. A number of fragments can be reused from the #link("../Shapes/Spheres.html#Sphere")[`Sphere`];'s implementation.
][
  `BasicIntersect()` 方法的形式也与球体的类似，计算适当的二次系数，解二次方程，然后处理部分圆柱体的各种情况。 许多代码片段可以从 #link("../Shapes/Spheres.html#Sphere")[`Sphere`] 的实现中复用。
]

```cpp
<<Cylinder Public Methods>>+=
pstd::optional<QuadricIntersection> BasicIntersect(const Ray &r,
                                                   Float tMax) const {
    Float phi;
    Point3f pHit;
    <<Transform Ray origin and direction to object space>>
    <<Solve quadratic equation to find cylinder t0 and t1 values>>
    <<Check quadric shape t0 and t1 for nearest intersection>>
    <<Compute cylinder hit point and >>
    <<Test cylinder intersection against clipping parameters>>
    <<Return QuadricIntersection for cylinder intersection>>
}
```

#parec[
  As before, the fragment that computes the quadratic discriminant, #link("Managing_Rounding_Error.html#fragment-Computecylinderquadraticdiscriminantmonodiscrim-0")[`Compute cylinder quadratic discriminant`] discrim is defined in @accurate-quadratic-discriminants after topics related to floating-point accuracy have been discussed.
][
  如前所述，计算二次判别式的部分，\<\<#link("Managing_Rounding_Error.html#fragment-Computecylinderquadraticdiscriminantmonodiscrim-0")[Compute cylinder quadratic discriminant];discrim\>\> 在@accurate-quadratic-discriminants 节中定义，讨论了与浮点精度相关的主题。
]

```cpp
<<Solve quadratic equation to find cylinder t0 and t1 values>>=
Interval t0, t1;
<<Compute cylinder quadratic coefficients>>
<<Compute cylinder quadratic discriminant discrim>>
<<Compute quadratic  values>>
```


#parec[
  As with spheres, the ray–cylinder intersection formula can be found by substituting the ray equation into the cylinder's implicit equation. The implicit equation for an infinitely long cylinder centered on the $z$ axis with radius $r$ is
][
  与球体一样，光线与圆柱体的相交公式可以通过将光线方程代入圆柱体的隐式方程来找到。以 $z$ 轴为中心，半径为 $r$ 的无限长圆柱体的隐式方程为
]


$ x^2 + y^2 - r^2 = 0 $


#parec[
  Substituting the ray equation, @eqt:ray , we have
][
  将射线方程（@eqt:ray ）代入，我们得到
]

$ (o_x + t upright(bold(d))_x)^2 + (o_y + t upright(bold(d))_y)^2 = r^2 $

#parec[
  When we expand this equation and find the coefficients of the quadratic equation $a t^2 + b t + c = 0$, we have
][
  展开这个方程并找到二次方程的系数时 $a t^2 + b t + c = 0$，我们得到
]

$
  a& = upright(bold(d))_x^2 + upright(bold(d))_y^2 \
  b& = 2(upright(bold(d))_x o_x + upright(bold(d))_y o_y)\
  c& = o_x^2 + o_y^2 - r^2 .
$

```cpp
// <<Compute cylinder quadratic coefficients>>=
Interval a = Sqr(di.x) + Sqr(di.y);
Interval b = 2 * (di.x * oi.x + di.y * oi.y);
Interval c = Sqr(oi.x) + Sqr(oi.y) - Sqr(Interval(radius));

```

#parec[
  As with spheres, the implementation refines the computed intersection point to reduce the rounding error in the point computed by evaluating the ray equation; see @bounding-intersection-point-error. Afterward, we invert the parametric description of the cylinder to compute $phi.alt$ from $x$ and $y$ ; it turns out that the result is the same as for the sphere.
][
  与球体一样，实现时会优化交点计算，以减少通过评估射线方程计算的点的舍入误差；参见@bounding-intersection-point-error。之后，通过反转圆柱的参数描述，从 $x$ 和 $y$ 计算出 $phi.alt$ ；结果与球体相同。
]

```cpp
<<Compute cylinder hit point and >>=
pHit = Point3f(oi) + (Float)tShapeHit * Vector3f(di);
<<Refine cylinder intersection point>>
phi = std::atan2(pHit.y, pHit.x);
if (phi < 0) phi += 2 * Pi;
```


#parec[
  The next step in the intersection method makes sure that the hit is in the specified $z$ range and that the angle $phi.alt$ is acceptable. If not, it rejects the hit and checks $t_1$ if it has not already been considered—these tests resemble the conditional logic in #link("../Shapes/Spheres.html#Sphere::Intersect")[`Sphere::Intersect()`];.
][
  接下来，确保交点命中在指定的 $z$ 范围内并且角度 $phi.alt$ 是可接受的。如果不是，它舍弃命中并检查 $t_1$ 是否尚未被考虑——这些测试类似于#link("../Shapes/Spheres.html#Sphere::Intersect")[`Sphere::Intersect()`];中的条件逻辑。
]

```cpp
<<Test cylinder intersection against clipping parameters>>=
if (pHit.z < zMin || pHit.z > zMax || phi > phiMax) {
    if (tShapeHit == t1)
        return {};
    tShapeHit = t1;
    if (t1.UpperBound() > tMax)
        return {};
    <<Compute cylinder hit point and >>
    if (pHit.z < zMin || pHit.z > zMax || phi > phiMax)
        return {};
}
```

#parec[
  For a successful intersection, the same three values suffice to provide enough information to later compute the corresponding #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];.
][
  对于成功的交点，相同的三个值足以提供足够的信息，以便稍后计算相应的#link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];。
]

```cpp
// <<Return QuadricIntersection for cylinder intersection>>=
return QuadricIntersection{Float(tShapeHit), pHit, phi};
```


#parec[
  As with the sphere, IntersectP()'s implementation is a simple wrapper around BasicIntersect().
][
  与球体一样，IntersectP()的实现是BasicIntersect()的简单包装。
]

```cpp
// <<Cylinder Public Methods>>+=
bool IntersectP(const Ray &r, Float tMax = Infinity) const {
    return BasicIntersect(r, tMax).has_value();
}
```

#parec[
  InteractionFromIntersection() computes all the quantities needed to initialize a #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] from a cylinder's #link("../Shapes/Spheres.html#QuadricIntersection")[QuadricIntersection];.
][
  InteractionFromIntersection()计算初始化圆柱的#link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];所需的所有量#link("../Shapes/Spheres.html#QuadricIntersection")[QuadricIntersection];。
]

```cpp
<<Cylinder Public Methods>>+=
SurfaceInteraction InteractionFromIntersection(
        const QuadricIntersection &isect, Vector3f wo, Float time) const {
    Point3f pHit = isect.pObj;
    Float phi = isect.phi;
    <<Find parametric representation of cylinder hit>>
    <<Compute error bounds for cylinder intersection>>
    <<Return SurfaceInteraction for quadric intersection>>
}
```

#parec[
  Again the parametric $u$ value is computed by scaling $phi.alt$ to lie between 0 and 1. Inversion of the parametric equation for the cylinder's $z$ value gives the $v$ parametric coordinate.
][
  再次通过将 $phi.alt$ 缩放到0到1之间来计算参数 $u$ 值。反转圆柱的参数方程的 $z$ 值给出 $v$ 参数坐标。
]

```cpp
// <Find parametric representation of cylinder hit>>=
Float u = phi / phiMax;
Float v = (pHit.z - zMin) / (zMax - zMin);
// <<Compute cylinder partial-differential normal p slash partial-differential u and partial-differential normal p slash partial-differential v>>
Vector3f dpdu(-phiMax * pHit.y, phiMax * pHit.x, 0);
   Vector3f dpdv(0, 0, zMax - zMin);
// <<Compute cylinder partial-differential bold n Subscript slash partial-differential u and partial-differential bold n Subscript slash partial-differential v>>
Vector3f d2Pduu = -phiMax * phiMax * Vector3f(pHit.x, pHit.y, 0);
   Vector3f d2Pduv(0, 0, 0), d2Pdvv(0, 0, 0);
// <<Compute coefficients for fundamental forms>>
Float E = Dot(dpdu, dpdu), F = Dot(dpdu, dpdv), G = Dot(dpdv, dpdv);
   Vector3f n = Normalize(Cross(dpdu, dpdv));
   Float e = Dot(n, d2Pduu), f = Dot(n, d2Pduv), g = Dot(n, d2Pdvv);
// <<Compute partial-differential bold n Subscript slash partial-differential u and partial-differential bold n Subscript slash partial-differential v from fundamental form coefficients>>
Float EGF2 = DifferenceOfProducts(E, G, F, F);
   Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2;
   Normal3f dndu = Normal3f((f * F - e * G) * invEGF2 * dpdu +
                            (e * F - f * E) * invEGF2 * dpdv);
   Normal3f dndv = Normal3f((g * F - f * G) * invEGF2 * dpdu +
                            (f * F - g * E) * invEGF2 * dpdv);
```

#parec[
  The partial derivatives for a cylinder are easy to derive:
][
  圆柱的偏导数很容易推导：
]



$
  frac(diff upright(bold(p)), diff u)& =(-phi.alt_("max") y comma thin phi.alt_("max") x comma thin 0) \
  frac(diff upright(bold(p)), diff v)& =(0 comma thin 0 comma thin z_("max") - z_("min")) .
$

```cpp
<<Compute cylinder  and >>=
Vector3f dpdu(-phiMax * pHit.y, phiMax * pHit.x, 0);
Vector3f dpdv(0, 0, zMax - zMin);
```

#parec[
  We again use the Weingarten equations to compute the parametric partial derivatives of the cylinder normal. The relevant partial derivatives are
][
  我们再次使用魏因加藤方程来计算圆柱法线的参数偏导数。相关的偏导数为
]

$
  frac(diff^2 upright(bold(p)), diff u^2)& = - phi.alt_("max")^2 (x comma y comma 0) \
  frac(diff^2 upright(bold(p)), diff u diff v)& =(0 comma 0 comma 0)\
  frac(diff^2 upright(bold(p)), diff v^2)& =(0 comma 0 comma 0) .
$

```cpp
<<Compute cylinder  and >>=
Vector3f d2Pduu = -phiMax * phiMax * Vector3f(pHit.x, pHit.y, 0);
Vector3f d2Pduv(0, 0, 0), d2Pdvv(0, 0, 0);
<<Compute coefficients for fundamental forms>>
<<Compute  and  from fundamental form coefficients>>
```

=== Sampling

#parec[
  Uniformly sampling the surface area of a cylinder is straightforward: uniform sampling of the height and $phi.alt$ give uniform area sampling. Intuitively, it can be understood that this approach works because a cylinder is just a rolled-up rectangle.
][
  均匀采样圆柱表面积是很简单的：对高度和 $phi.alt$ 进行均匀采样即可实现均匀面积采样。直观上，这种方法之所以有效，是因为圆柱体就像一个卷起的矩形。
]
```cpp
<<Cylinder Public Methods>>+=
pstd::optional<ShapeSample> Sample(Point2f u) const {
    Float z = Lerp(u[0], zMin, zMax);
    Float phi = u[1] * phiMax;
    <<Compute cylinder sample position pi and normal n from  and >>
    Point2f uv(phi / phiMax, (pObj.z - zMin) / (zMax - zMin));
    return ShapeSample{Interaction(pi, n, uv), 1 / Area()};
}
```
#parec[
  Given $z$ and $phi.alt$, the corresponding object-space position and normal are easily found.
][
  给定 $z$ 和 $phi.alt$，相应的物体空间位置和法线可以很容易地找到。
]

```cpp
Point3f pObj = Point3f(radius * std::cos(phi), radius * std::sin(phi), z);
<<Reproject $pObj$ to cylinder surface and compute $pObjError$>>&#160;   Float hitRad = std::sqrt(Sqr(pObj.x) + Sqr(pObj.y));
   pObj.x *= radius / hitRad;
   pObj.y *= radius / hitRad;
   Vector3f pObjError = gamma(3) * Abs(Vector3f(pObj.x, pObj.y, 0));
Point3fi pi = (*renderFromObject)(Point3fi(pObj, pObjError));
Normal3f n = Normalize((*renderFromObject)(Normal3f(pObj.x, pObj.y, 0)));
if (reverseOrientation)
    n *= -1;
```


```cpp
Float PDF(const Interaction &) const { return 1 / Area(); }
```

#parec[
  Unlike the `Sphere`, `pbrt`'s `Cylinder` does not have a specialized solid angle sampling method. Instead, it samples a point on the cylinder uniformly by area without making use of the reference point before converting the area density for that point to a solid angle density before returning it. Both the `Sample()` and `PDF()` methods can be implemented using the same fragments that were used for solid angle sampling of reference points inside spheres.
][
  与 `Sphere` 不同，`pbrt` 的 `Cylinder` 没有专门的立体角采样方法。相反，它通过面积均匀地采样圆柱上的一个点，不使用参考点，然后将该点的面积密度转换为立体角密度并返回结果。`Sample()` 和 `PDF()` 方法都可以使用相同的代码片段来实现，这些代码片段曾用于球体内参考点的立体角采样。
]

```cpp
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx,
                                   Point2f u) const {
    <<Sample shape by area and compute incident direction $wi$>>&#160;       pstd::optional<ShapeSample> ss = Sample(u);
       ss->intr.time = ctx.time;
       Vector3f wi = ss->intr.p() - ctx.p();
       if (LengthSquared(wi) == 0) return {};
       wi = Normalize(wi);
    <<Convert area sampling PDF in ss to solid angle measure>>&#160;       ss->pdf /= AbsDot(ss->intr.n, -wi) /
                  DistanceSquared(ctx.p(), ss->intr.p());
       if (IsInf(ss->pdf))
           return {};
    return ss;
}
```


```cpp
Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const {
    // <<Intersect sample ray with shape geometry>>
       Ray ray = ctx.SpawnRay(wi);
       pstd::optional<ShapeIntersection> isect = Intersect(ray);
       if (!isect) return 0;
    // <<Compute PDF in solid angle measure from shape intersection point>>
    Float pdf = (1 / Area()) / (AbsDot(isect->intr.n, -wi) /
                                   DistanceSquared(ctx.p(), isect->intr.p()));
       if (IsInf(pdf)) pdf = 0;
    return pdf;
}
```