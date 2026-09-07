#import "../template.typ": parec, ez_caption, source-cite

== #ez_caption[Spheres][球体]
<spheres>

#parec[
  Spheres are a special case of a general type of surface called #emph[quadrics]—surfaces described by quadratic polynomials in $x$, $y$, and $z$. They offer a good starting point for introducing ray intersection algorithms. In conjunction with a transformation matrix, `pbrt`'s `Sphere` shape can also take the form of an ellipsoid. `pbrt` supports two other basic types of quadrics: cylinders and disks. Other quadrics such as the cone, hyperboloid, and paraboloid are less useful for most rendering applications, and so are not included in the system.
][
  球体是称为#emph[二次曲面]的一般类型表面的特殊情况——这些表面由 $x$ 、 $y$ 和 $z$ 的二次多项式描述。它们是介绍光线相交算法的良好起点。通过结合变换矩阵，`pbrt` 的 `Sphere` 形状也可以变为椭球体的形式。`pbrt` 支持另外两种基本类型的二次曲面：圆柱和圆盘。其他二次曲面如圆锥、双曲面和抛物面对于大多数渲染应用不太有用，因此不包括在系统中。
]

#parec[
  Many surfaces can be described in one of two main ways: in #emph[implicit form] and in #emph[parametric form]. An implicit function describes a 3D surface as
][
  许多表面可以用两种主要方式之一来描述：#emph[隐式形式]和#emph[参数形式]。隐函数将三维表面描述为
] $ f (x , y , z) = 0 . $

#parec[
  The set of all points $(x , y , z)$ that fulfill this condition defines the surface. For a unit sphere at the origin, the familiar implicit equation is $x^2 + y^2 + z^2 - 1 = 0 .$ Only the set of points one unit from the origin satisfies this constraint, giving the unit sphere's surface.
][
  满足此条件的所有点 $(x , y , z)$ 的集合定义了该表面。对于位于原点的单位球体，常见的隐式方程为 $ x^2 + y^2 + z^2 - 1 = 0 . $ 只有距离原点一个单位的点集满足此约束，形成单位球体的表面。
]

#parec[
  Many surfaces can also be described parametrically using a function to map 2D points to 3D points on the surface. For example, a sphere of radius $r$ can be described as a function of 2D spherical coordinates $(theta , phi.alt)$, where $theta$ ranges from $0$ to $pi$ and $phi.alt$ ranges from $0$ to $2 pi$ (@fig:sphere-setting):
][
  许多表面也可以通过函数将二维点映射到表面上的三维点来进行参数化描述。例如，半径为 $r$ 的球体可以用二维球面坐标 $(theta , phi.alt)$ 描述，其中 $theta$ 范围从 $0$ 到 $pi$， $phi.alt$ 范围从 $0$ 到 $2 pi$ （@fig:sphere-setting）：
]
$
  x & = r sin theta cos phi.alt \
  y & = r sin theta sin phi.alt \
  z & = r cos theta .
$<sphere-theta-phi>

#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f03.svg"),
  caption: [#ez_caption[Basic Setting for the Sphere Shape. It has a radius of $r$ and is centered at the object space origin. A partial sphere may be described by specifying a maximum $phi.alt$ value.][球体形状的基本设置。它的半径为$r$，中心位于对象空间原点。可以通过指定最大值$phi.alt$来描述部分球体。 ]
  ],
) <sphere-setting>

#parec[
  We can transform this function $f (theta , phi.alt)$ into a function $f (u , v)$ over $[0 , 1]^2$ and generalize it slightly to allow partial spheres that only sweep out $theta in [theta_(upright("min")) , theta_(upright("max"))]$ and $phi.alt in [0 , phi.alt_(upright("max"))]$ with the substitution
][
  我们可以将函数 $f (theta , phi.alt)$ 转换为定义在 $[0 , 1]^2$ 上的函数 $f (u , v)$，并稍微泛化以允许仅在 $theta in [theta_(upright("min")) , theta_(upright("max"))]$ 和 $phi.alt in [0 , phi.alt_(upright("max"))]$ 范围内扫过的局部球体，通过以下替换：
]


$
  phi.alt & = u phi.alt_(upright("max"))\
  theta & = theta_(upright("min")) + v (theta_(upright("max")) - theta_(upright("min"))) .
$ <sphere-uv>


#parec[
  This form is particularly useful for texture mapping, where it can be directly used to map a texture defined over $[0 , 1]^2$ to the sphere. @fig:sphere-rendered shows an image of two spheres; a grid image map has been used to show the $(u , v)$ parameterization.
][
  这种形式对于纹理映射特别有用，可以直接用于将定义在 $[0 , 1]^2$ 上的纹理映射到球体上。@fig:sphere-rendered 展示了两个球体的图像；使用了网格图像映射来展示 $(u , v)$ 参数化的效果。
]

#figure(
  image("../pbr-book-website/4ed/Shapes/spheres.png"),
  caption: [#ez_caption[
      Two Spheres. On the left is a partial sphere (with $z_("max") < r$and $phi.alt_("max") < 2pi$ ) and on the right is a complete sphere. Note that the texture image used shows the $(u,v)$ parameterization of the shape; the singularity at one of the poles is visible in the complete sphere.
    ][
      两个球体。左边是部分球体（其中 $z_("max") < r$ 且 $phi.alt_("max") < 2pi$），右边是完整球体。请注意，所使用的纹理图像显示了形状的 $(u,v)$ 参数化；完整球体在其中一个极点处的奇异性是可见的。
    ]
  ],
) <sphere-rendered>

#parec[
  As we describe the implementation of the sphere shape, we will make use of both the implicit and parametric descriptions of the shape, depending on which is a more natural way to approach the particular problem we are facing.
][
  在描述球体形状的实现过程中，我们会根据具体问题选择该形状的隐式或参数化描述。
]

#parec[
  The `Sphere` class represents a sphere that is centered at the origin. As with all the other shapes, its implementation is in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[shapes.h] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[shapes.cpp].
][
  `Sphere` 类用于表示一个中心位于原点的球体。与所有其他形状一样，其实现位于文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[shapes.h] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[shapes.cpp] 中。
]

#block(sticky: true)[#raw("<<Sphere Definition>>=")] <fragment-SphereDefinition-0>
```cpp
class Sphere {
  public:
    <<Sphere Public Methods>>
  private:
    <<Sphere Private Members>>
};
``` <Sphere>


#parec[
  As mentioned earlier, spheres in `pbrt` are defined in a coordinate system where the center of the sphere is at the origin. The sphere constructor is provided transformations that map between the sphere's object space and rendering space.
][
  如前所述，`pbrt` 中的球体是在一个球心位于原点的坐标系中定义的。调用者向球体构造函数传入对象空间与渲染空间之间的变换。
]

#parec[
  Although `pbrt` supports animated transformation matrices, the transformations here are not `AnimatedTransform`s. (Such is also the case for all the shapes defined in this chapter.) Animated shape transformations are instead handled by using a #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive] to represent the shape in the scene.Doing so allows us to centralize some of the tricky details related to animated transformations in a single place, rather than requiring all Shapes to handle this case.
][
  虽然 `pbrt` 支持动画变换矩阵，但这里的变换不是 `AnimatedTransform`。在本章定义的所有形状中也是如此。动画形状变换通过使用#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive]来表示场景中的形状来处理。这样做可以让我们将与动画变换相关的一些棘手细节集中在一个地方，而不是要求每种形状分别处理这种情况。
]

#parec[
  The radius of the sphere can have an arbitrary positive value, and the sphere's extent can be truncated in two different ways. First, minimum and maximum $z$ values may be set; the parts of the sphere below and above these planes, respectively, are cut off. Second, considering the parameterization of the sphere in spherical coordinates, a maximum $phi$ value can be set. The sphere sweeps out $phi$ values from 0 to the given $phi_("max")$ such that the section of the sphere with spherical $phi$ values above $phi_("max")$ is also removed.
][
  球体的半径可以是任意正值，并且球体的范围可以通过两种方式进行截断。首先，可以设置 $z$ 的最小和最大 值；分别在这些平面以下和以上的球体部分被切掉。其次，根据球坐标下的参数化，可以设置最大 $phi$ 值。球体从0扫描到给定的 $phi_("max")$ 值，使得球体中球面 $phi$ 值大于 $phi_("max")$ 的部分也被移除。
]

#parec[
  Finally, the `Sphere` constructor also takes a Boolean parameter, `reverseOrientation`, that indicates whether their surface normal directions should be reversed from the default (which is pointing outside the sphere). This capability is useful because the orientation of the surface normal is used to determine which side of a shape is "outside." For example, shapes that emit illumination are by default emissive only on the side the surface normal lies on. The value of this parameter is managed via the `ReverseOrientation` statement in `pbrt` scene description files.
][
  最后，`Sphere` 构造函数还接受一个布尔参数`reverseOrientation`，指示是否应将表面法向量方向从默认的指向球体外部反转。这种能力很有用，因为表面法向量的方向用于确定形状的哪一侧是“外部”。例如，发光形状默认只在表面法向量指向的一侧发光。该参数的值通过 `pbrt` 场景描述文件中的 `ReverseOrientation` 语句进行管理。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>=")] <fragment-SpherePublicMethods-0>
```cpp
Sphere(const Transform *renderFromObject, const Transform *objectFromRender,
       bool reverseOrientation, Float radius, Float zMin, Float zMax,
       Float phiMax)
    : renderFromObject(renderFromObject), objectFromRender(objectFromRender),
      reverseOrientation(reverseOrientation),
      transformSwapsHandedness(renderFromObject->SwapsHandedness()),
      radius(radius),
      zMin(Clamp(std::min(zMin, zMax), -radius, radius)),
      zMax(Clamp(std::max(zMin, zMax), -radius, radius)),
      thetaZMin(std::acos(Clamp(std::min(zMin, zMax) / radius, -1, 1))),
      thetaZMax(std::acos(Clamp(std::max(zMin, zMax) / radius, -1, 1))),
      phiMax(Radians(Clamp(phiMax, 0, 360))) {}
```

#block(sticky: true)[#raw("<<Sphere Private Members>>=")] <fragment-SpherePrivateMembers-0>
```cpp
Float radius;
Float zMin, zMax;
Float thetaZMin, thetaZMax, phiMax;
const Transform *renderFromObject, *objectFromRender;
bool reverseOrientation, transformSwapsHandedness;
```
=== #ez_caption[Bounding][包围范围]
<sphere-bounding>
#parec[
  Computing an object-space bounding box for a sphere is straightforward. The implementation here uses the values of $z_(upright("min"))$ and $z_(upright("max"))$ provided by the user to tighten up the bound when less than an entire sphere is being rendered. However, it does not do the extra work to compute a tighter bounding box when $phi.alt_(upright("max"))$ is less than $3 pi \/ 2$. This improvement is left as an exercise. This object-space bounding box is transformed to rendering space before being returned.
][
  计算球体的对象空间包围盒是相对简单的。这里的实现使用用户提供的 $z_(upright("min"))$ 和 $z_(upright("max"))$ 值在渲染不完整球体时收紧包围盒。然而，当 $phi.alt_(upright("max"))$ 小于 $3 pi \/ 2$ 时，它并没有进行额外的计算来得到更紧的包围盒。这一改进留作练习。这个对象空间包围盒在返回之前会被转换到渲染空间。
]

#block(sticky: true)[#raw("<<Sphere Method Definitions>>=")] <fragment-SphereMethodDefinitions-0>
```cpp
Bounds3f Sphere::Bounds() const {
    return (*renderFromObject)(
        Bounds3f(Point3f(-radius, -radius, zMin),
                 Point3f( radius,  radius, zMax)));
}
```


#parec[
  The `Sphere`'s `NormalBounds()` method does not consider any form of partial spheres but always returns the bounds for an entire sphere, which is all possible directions.
][
  `Sphere` 的 `NormalBounds()` 方法不考虑任何形式的部分球体，而总是返回整个球体的法向量方向包围范围，即所有可能的方向。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-1>
```cpp
DirectionCone NormalBounds() const { return DirectionCone::EntireSphere(); }
```

=== #ez_caption[Intersection Tests][求交测试]
<intersection-tests>
#parec[
  The ray intersection test is broken into two stages. First, `BasicIntersect()` does the basic ray-sphere intersection test and returns a small structure, `QuadricIntersection`, if an intersection is found. A subsequent call to the `InteractionFromIntersection()` method transforms the `QuadricIntersection` into a full-blown `SurfaceInteraction`, which can be returned from the `Intersection()` method.
][
  射线相交测试分为两个阶段。首先，调用 `BasicIntersect()` 进行基本的射线-球体相交测试，如果找到相交点，则返回一个结构体 `QuadricIntersection`。随后调用 `InteractionFromIntersection()` 方法将 `QuadricIntersection` 转换为完整的 `SurfaceInteraction`，这被 `Intersection()` 方法返回。
]

#parec[
  There are two motivations for separating the intersection test into two stages like this. One is that doing so allows the `IntersectP()` method to be implemented as a trivial wrapper around `BasicIntersect()`. The second is that `pbrt`'s GPU rendering path is organized such that the closest intersection among all shapes is found before the full `SurfaceInteraction` is constructed; this decomposition fits that directly.
][
  将相交测试分为两个阶段有两个动机。其一是这样做允许 `IntersectP()` 方法简单包装一下 `BasicIntersect()` 来实现。其二是 `pbrt` 的 GPU 渲染路径被组织成在构建完整的 `SurfaceInteraction` 之前找到所有形状中最近的相交点；这种分解直接适合这种结构。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-2>
```cpp
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
  `QuadricIntersection` stores the parametric $t$ along the ray where the intersection occurred, the object-space intersection point, and the sphere's $phi.alt$ value there. As its name suggests, this structure will be used by the other quadrics in the same way it is here.
][
  `QuadricIntersection` 存储了射线相交时的参数 $t$，对象空间的相交点，以及球体在该点的 $phi.alt$ 值。正如其名称所示，这个结构将在其他二次曲面中以相同的方式使用。
]

#block(sticky: true)[#raw("<<QuadricIntersection Definition>>=")] <fragment-QuadricIntersectionDefinition-0>
```cpp
struct QuadricIntersection {
    Float tHit;
    Point3f pObj;
    Float phi;
};
``` <QuadricIntersection>
#parec[
  The basic intersection test transforms the provided rendering-space ray to object space and intersects it with the complete sphere. If a partial sphere has been specified, some additional tests reject intersections with portions of the sphere that have been removed.
][
  基础相交测试将提供的渲染空间射线转换为对象空间，并与完整的球体相交。如果给定的是部分球体，则一些额外的测试会拒绝与被扣掉部分球体的相交。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-3>
```cpp
pstd::optional<QuadricIntersection> BasicIntersect(const Ray &r,
                                                   Float tMax) const {
    Float phi;
    Point3f pHit;
    <<Transform Ray origin and direction to object space>>
    <<Solve quadratic equation to compute sphere t0 and t1>>
    <<Check quadric shape t0 and t1 for nearest intersection>>
    <<Compute sphere hit position and phi >>
    <<Test sphere intersection against clipping parameters>>
    <<Return QuadricIntersection for sphere intersection>>
}
``` <Sphere::BasicIntersect>


#parec[
  The transformed ray origin and direction are respectively stored using #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] and #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Vector3fi")[`Vector3fi`] classes rather than the usual #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] and #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] classes. These classes represent those quantities as small intervals in each dimension that bound the floating-point round-off error that was introduced by applying the transformation. Later, we will see that these error bounds will be useful for improving the geometric accuracy of the intersection computation. For the most part, these classes can respectively be used just like #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] and #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`].
][
  变换后的射线原点和方向分别使用 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] 和 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Vector3fi")[`Vector3fi`] 类存储，而不是通常的 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 和 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] 类。这些类将这些量的每个维度表示为一个小区间，以界定应用变换时引入的浮点舍入误差。稍后，我们将看到这些误差界限对于提高相交计算的几何精度是有用的。在大多数情况下，这些类可以像 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 和 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] 一样使用。
]

#block(sticky: true)[#raw("<<Transform Ray origin and direction to object space>>=")] <fragment-TransformmonoRayoriginanddirectiontoobjectspace-0>
```cpp
Point3fi oi = (*objectFromRender)(Point3fi(r.o));
Vector3fi di = (*objectFromRender)(Vector3fi(r.d));
```


#parec[
  If a sphere is centered at the origin with radius $r$, its implicit representation is
][
  如果一个球体以原点为中心，半径为 $r$，其隐式表示为
]


$ x^2 + y^2 + z^2 - r^2 = 0 . $

#parec[
  By substituting the parametric representation of the ray from @eqt:ray into the implicit sphere equation, we have
][
  通过将光线的参数表示从@eqt:ray 代入隐式球体方程，我们得到
]

$ (o_x + t upright(bold(d))_x)^2 + (o_y + t upright(bold(d))_y)^2 + (o_z + t upright(bold(d))_z)^2 = r^2 . $

#parec[
  Note that all elements of this equation besides $t$ are known values. The $t$ values where the equation holds give the parametric positions along the ray where the implicit sphere equation is satisfied and thus the points along the ray where it intersects the sphere. We can expand this equation and gather the coefficients for a general quadratic equation in $t$,
][
  注意，除了 $t$ 之外，该方程的所有元素都是已知值。方程成立的 $t$ 值给出了光线沿着满足隐式球体方程的参数位置，因此光线与球体相交的点。我们可以展开这个方程，并提取出 $t$ 的一般二次方程的系数，
]

$ a t^2 + b t + c = 0 , $

#parec[
  where #footnote[Some ray tracers require that the direction vector of a ray be normalized, meaning `a=1`. This can lead to subtle errors, however, if the caller forgets to normalize the ray direction.  Of course, these errors can be avoided by normalizing the direction in the ray constructor, but this wastes effort when the provided direction is _already_ normalized.  To avoid this needless complexity, `pbrt` never insists on vector normalization in intersection routines.  This is particularly helpful since it reduces the amount of computation needed to transform rays to object space, because no normalization is necessary there.]
][
  其中 #footnote[一些光线追踪器要求光线的方向向量必须归一化，即`a=1`。然而，如果调用方忘记归一化光线方向，可能会导致微妙的错误。当然，这些错误可以通过在光线构造函数中对方向进行归一化来避免，但当提供的方向已经归一化时，这样做会浪费计算资源。为了避免这种不必要的复杂性，`pbrt`在求交例程过程中从不强制要求向量归一化。这尤其有帮助，因为这减少了将光线转换为对象空间所需的计算量，因为在那里不需要进行归一化处理。]
]

$
  a & = upright(bold(d))_x^2 + upright(bold(d))_y^2 + upright(bold(d))_z^2 \
  b & = 2(upright(bold(d))_x o_x + upright(bold(d))_y o_y + upright(bold(d))_z o_z) \
  c & = o_x^2 + o_y^2 + o_z^2 - r^2 .
$ <sphere-isect-coeffs>

#parec[
  The `Interval` class stores a small range of floating-point values to maintain bounds on floating-point rounding error. It is defined in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:interval-arithmetic")[B.2.15] and is analogous to `Float` in the way that `Point3fi` is to `Point3f`, for example.
][
  `Interval` 类存储了一小范围的浮点值，以维持浮点舍入误差的界限。它在 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:interval-arithmetic")[B.2.15] 中定义，类似于 `Float`，就像 `Point3fi` 类似于 `Point3f` 一样。
]

#block(sticky: true)[#raw("<<Solve quadratic equation to compute sphere t0 and t1>>=")] <fragment-Solvequadraticequationtocomputespheremonot0andmonot1-0>
```cpp
Interval t0, t1;
<<Compute sphere quadratic coefficients>>
<<Compute sphere quadratic discriminant discrim>>
<<Compute quadratic t values>>
```

#parec[
  Given Interval, @eqt:sphere-isect-coeffs directly translates to the following fragment of source code.
][
  有了 `Interval`，@eqt:sphere-isect-coeffs 就可以直接转写为以下源代码片段。
]

#block(sticky: true)[#raw("<<Compute sphere quadratic coefficients>>=")] <fragment-Computespherequadraticcoefficients-0>
```cpp
Interval a = Sqr(di.x) + Sqr(di.y) + Sqr(di.z);
Interval b = 2 * (di.x * oi.x + di.y * oi.y + di.z * oi.z);
Interval c = Sqr(oi.x) + Sqr(oi.y) + Sqr(oi.z) - Sqr(Interval(radius));
```

#parec[
  The fragment ⟨Compute sphere quadratic discriminant discrim⟩ computes the discriminant $b^2 - 4 a c$ in a way that maintains numerical accuracy in tricky cases. It is defined later, in @accurate-quadratic-discriminants, after related topics about floating-point arithmetic have been introduced. Proceeding here with its value in discrim, the quadratic equation can be applied. Here we use a variant of the traditional $(- b plus.minus sqrt(b^2 - 4 a c)) \/ (2 a)$ approach that gives more accuracy; it is described in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:math-finding-zeros")[B.2.10].
][
  代码片段 ⟨Compute sphere quadratic discriminant discrim⟩ 计算判别式 $b^2 - 4 a c$， 在棘手情况下仍能保持数值准确性。它在 @accurate-quadratic-discriminants 中定义，在介绍与浮点算术相关的主题之后。继续使用其在 discrim 中的值，可以应用二次方程。这里我们使用传统的 $(- b plus.minus sqrt(b^2 - 4 a c)) \/ (2 a)$ 方法的变体以获得更高的准确性；它在 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:math-finding-zeros")[B.2.10] 中描述。
]

#block(sticky: true)[#raw("<<Compute quadratic t values>>=")] <fragment-Computequadratictvalues-0>
```cpp
Interval rootDiscrim = Sqrt(discrim);
Interval q;
if ((Float)b < 0) q = -.5f * (b - rootDiscrim);
else              q = -.5f * (b + rootDiscrim);
t0 = q / a;
t1 = c / q;
<<Swap quadratic t values so that t0 is the lesser>>
```
#parec[
  Because `t0` and `t1` represent intervals of floating-point values, it may be ambiguous which of them is less than the other. We use their lower bound for this test, so that in ambiguous cases, at least we do not risk returning a hit that is potentially farther away than an actual closer hit.
][
  因为 `t0` 和 `t1` 表示浮点值的区间，可能不清楚哪个更小。我们使用它们的下界进行测试，因此在不明确的情况下，至少不会因这种歧义，返回一个可能位于实际较近交点之后的交点。
]

#block(sticky: true)[#raw("<<Swap quadratic t values so that t0 is the lesser>>=")] <fragment-Swapquadratictvaluessothatmonot0isthelesser-0>
```cpp
if (t0.LowerBound() > t1.LowerBound())
    pstd::swap(t0, t1);
```
#parec[
  A similar ambiguity must be accounted for when testing the `t` values against the acceptable range. In ambiguous cases, we err on the side of returning no intersection rather than an invalid one. The closest valid `t` is then stored in `tShapeHit`.
][
  在测试 `t` 值与可接受范围时，必须考虑类似的模糊性。在不明确的情况下，我们宁愿返回没有交点而不是无效的交点。最近的有效 `t` 然后存储在 `tShapeHit` 中。
]

#block(sticky: true)[#raw("<<Check quadric shape t0 and t1 for nearest intersection>>=")] <fragment-Checkquadricshapemonot0andmonot1fornearestintersection-0>
```cpp
if (t0.UpperBound() > tMax || t1.LowerBound() <= 0)
    return {};
Interval tShapeHit = t0;
if (tShapeHit.LowerBound() <= 0) {
    tShapeHit = t1;
    if (tShapeHit.UpperBound() > tMax)
        return {};
}
```

#parec[
  Given the parametric distance along the ray to the intersection with a full sphere, the intersection point pHit can be computed as that offset along the ray. In its initializer, all the respective interval types are cast back to their non-interval equivalents, which gives their midpoint. (The remainder of the intersection test no longer needs the information provided by the intervals.) Due to floating-point precision limitations, this computed intersection point pHit may lie a bit to one side of the actual sphere surface; the ⟨Refine sphere intersection point⟩ fragment, which is defined in @bounding-intersection-point-error, improves the accuracy of this value.
][
  给定光线与完整球体相交的参数距离，可沿射线按该参数距离求得交点 `pHit`。在其初始化器中，所有相应的区间类型都被转换回对应的非区间类型，取值为区间中点。（交点测试的其余部分不再需要区间提供的信息。）由于浮点精度限制，这个计算出的交点 pHit 可能位于实际球体表面的一侧； 片段⟨Refine sphere intersection point⟩，在 @bounding-intersection-point-error 中定义，提高了这个值的准确性。
]

#parec[
  It is next necessary to handle partial spheres with clipped $z$ or $phi.alt$ ranges—intersections that are in clipped areas must be ignored. The implementation starts by computing the $phi.alt$ value for the hit point. Using the parametric representation of the sphere,
][
  接下来需要处理具有被裁剪的 $z$ 或 $phi.alt$ 范围的部分球体——在裁剪区域的交点必须被忽略。实现从计算命中点的 $phi.alt$ 值开始。使用球体的参数表示，
]


$ y / x = frac(r sin theta sin phi.alt, r sin theta cos phi.alt) = tan phi.alt $
#parec[
  so $phi.alt = arctan (y \/ x)$. It is necessary to remap the result of the standard library's `std::atan()` function to a value between $0$ and $2 pi$, to match the sphere's original definition.
][
  所以 $phi.alt = arctan (y \/ x)$。有必要将标准库的 `std::atan()`函数的结果重新映射到 $0$ 和 $2 pi$ 之间的值，以匹配球体的原始定义。
]

#block(sticky: true)[#raw("<<Compute sphere hit position and phi >>=")] <fragment-Computespherehitpositionandphi-0>
```cpp
pHit = Point3f(oi) + (Float)tShapeHit * Vector3f(di);
<<Refine sphere intersection point>>
if (pHit.x == 0 && pHit.y == 0) pHit.x = 1e-5f * radius;
phi = std::atan2(pHit.y, pHit.x);
if (phi < 0) phi += 2 * Pi;
```

#parec[
  The hit point can now be tested against the specified minima and maxima for $z$ and $phi.alt$. One subtlety is that it is important to skip the $z$ tests if the $z$ range includes the entire sphere; the computed `pHit.z` value may be slightly out of the $z$ range due to floating-point round-off, so we should only perform this test when the user expects the sphere to be partially incomplete. If the $t_0$ intersection is not valid, the routine tries again with $t_1$.
][
  现在可以根据 $z$ 和 $phi.alt$ 的指定最小值和最大值测试击中点。需要注意的是，如果 $z$ 范围涵盖完整球体，则应跳过 $z$ 测试；由于浮点舍入误差，计算出的 `pHit.z` 值可能略微超出 $z$ 范围，因此我们应该仅在球体不完整时执行此测试。如果 $t_0$ 交点无效，则会尝试使用 $t_1$。
]
#block(sticky: true)[#raw("<<Test sphere intersection against clipping parameters>>=")] <fragment-Testsphereintersectionagainstclippingparameters-0>
```cpp
if ((zMin > -radius && pHit.z < zMin) ||
    (zMax < radius && pHit.z > zMax) || phi > phiMax) {
    if (tShapeHit == t1) return {};
    if (t1.UpperBound() > tMax) return {};
    tShapeHit = t1;
    <<Compute sphere hit position and phi >>
    if ((zMin > -radius && pHit.z < zMin) ||
        (zMax < radius && pHit.z > zMax) || phi > phiMax)
        return {};
}
```
#parec[
  At this point in the routine, it is certain that the ray hits the sphere. A `QuadricIntersection` is returned that encapsulates sufficient information about it to determine the rest of the geometric information at the intersection point. Recall from @interaction-coordinate-spaces that even though `tShapeHit` was computed in object space, it is also the correct $t$ value in rendering space. Therefore, it can be returned directly.
][
  这时，可以确定光线击中了球体。返回一个 `QuadricIntersection`，它封装了足够的信息来确定交点处的其余几何信息。回忆@interaction-coordinate-spaces，尽管 `tShapeHit` 是在对象空间中计算的，但它也是渲染空间中的正确 $t$ 值。因此，它可以直接返回。
]

#block(sticky: true)[#raw("<<Return QuadricIntersection for sphere intersection>>=")] <fragment-ReturnmonoQuadricIntersectionforsphereintersection-0>
```cpp
return QuadricIntersection{Float(tShapeHit), pHit, phi};
```

#parec[
  With `BasicIntersect()` implemented, `Sphere::IntersectP()` is easily taken care of.
][
  实现 `BasicIntersect()` 后，`Sphere::IntersectP()` 很容易处理。
]
#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-4>
```cpp
bool IntersectP(const Ray &r, Float tMax = Infinity) const {
    return BasicIntersect(r, tMax).has_value();
}
```
#parec[
  A `QuadricIntersection` can be upgraded to a `SurfaceInteraction` with a call to `InteractionFromIntersection()`.
][
  通过调用 `InteractionFromIntersection()`，可以将 `QuadricIntersection` 升级为 `SurfaceInteraction`。
]
#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-5>
```cpp
SurfaceInteraction InteractionFromIntersection(
        const QuadricIntersection &isect, Vector3f wo, Float time) const {
    Point3f pHit = isect.pObj;
    Float phi = isect.phi;
    <<Find parametric representation of sphere hit>>
    <<Compute error bounds for sphere intersection>>
    <<Return SurfaceInteraction for quadric intersection>>
}
``` <Sphere::InteractionFromIntersection>

#parec[
  The method first computes $u$ and $v$ values by scaling the previously computed $phi$ value for the hit to lie between $0$ and $1$ and by computing a $theta$ value between $0$ and $1$ for the hit point based on the range of $theta$ values for the given sphere. Then it finds the parametric partial derivatives of the position $∂ p \/ ∂ u$ and $∂ p \/ ∂ v$ and surface normal $ ∂ upright(bold(n)) \/∂ u$ and $∂ upright(bold(n)) \/ ∂ v$.
][
  该方法首先通过缩放先前计算的击中点的 $phi$ 值使其位于 $0$ 和 $1$ 之间，并根据给定球体的 $theta$ 值范围计算击中点的 $theta$ 值，使其位于 $0$ 和 $1$ 之间，然后找到位置 $∂ p \/ ∂ u$ 和 $∂ p \/ ∂ v$ 以及表面法向量 $∂ upright(bold(n)) \/∂ u$ 和 $∂ upright(bold(n)) \/ ∂ v$ 的参数偏导数。
]
#block(sticky: true)[#raw("<<Find parametric representation of sphere hit>>=")] <fragment-Findparametricrepresentationofspherehit-0>
```cpp
Float u = phi / phiMax;
Float cosTheta = pHit.z / radius;
Float theta = SafeACos(cosTheta);
Float v = (theta - thetaZMin) / (thetaZMax - thetaZMin);
<<Compute sphere ∂p/∂u and ∂p/∂v >>
<<Compute sphere ∂n/∂u and ∂n/∂v >>
```


#parec[
  Computing the partial derivatives of a point on the sphere is a short exercise in algebra. Here we will show how the $x$ component of $∂ upright(bold(p)) \/ ∂ u$, $∂ upright(bold(p))_x \/ ∂ u$, is calculated; the other components are found similarly. Using the parametric definition of the sphere, we have
][
  计算球体上某一点的偏导数是一个简短的代数练习。这里我们将展示如何计算 $∂ upright(bold(p)) \/ ∂ u$ 的 $x$ 分量 $∂ upright(bold(p))_x \/ ∂ u$ ，其他分量的求法类似。根据球体的参数化定义，有
]

$
  x & = r sin theta cos phi.alt\
  frac(diff upright(bold(p))_x, diff u)& = frac(diff, diff u)(r sin theta cos phi.alt) \
  & = r sin theta frac(diff, diff u)(cos phi.alt)\
  & = r sin theta(-phi.alt_("max") sin phi.alt) .
$

#parec[
  Using a substitution based on the parametric definition of the sphere's $y$ coordinate, this simplifies to
][
  使用基于球体 $y$ 坐标的参数定义的代换，这可以简化为
]

$ frac(∂ upright(bold(p))_x, ∂ u) = - phi.alt_"max" y $

#parec[
  Similarly,
][
  类似地，
]

$ frac(∂ upright(bold(p))_y, ∂ u) = phi.alt_"max" x , $
#parec[
  and
][
  以及
]

$ frac(∂ upright(bold(p))_z, ∂ u) = 0 . $


#parec[
  A similar process gives $∂ upright(bold(p)) \/ ∂ v$. The complete result is
][
  类似的过程给出了 $∂ upright(bold(p)) \/ ∂ v$。完整结果是
]

$
  frac(diff upright(bold(p)), diff u) & =(-phi.alt_("max") y comma thin phi.alt_("max") x comma thin 0) \
  frac(diff upright(bold(p)), diff v) & =(theta_("max") - theta_("min"))(
    z cos phi.alt comma thin z sin phi.alt comma thin - r sin theta
  ),
$

#parec[
  and the implementation follows directly.
][
  实现可以直接进行。
]

#block(sticky: true)[#raw("<<Compute sphere ∂p/∂u and ∂p/∂v >>=")] <fragment-Computespheredpduanddpdv-0>
```cpp
Float zRadius = std::sqrt(Sqr(pHit.x) + Sqr(pHit.y));
Float cosPhi = pHit.x / zRadius, sinPhi = pHit.y / zRadius;
Vector3f dpdu(-phiMax * pHit.y, phiMax * pHit.x, 0);
Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
Vector3f dpdv = (thetaZMax - thetaZMin) *
    Vector3f(pHit.z * cosPhi, pHit.z * sinPhi, -radius * sinTheta);
```
#parec[
  It is also useful to determine how the normal changes as we move along the surface in the $u$ and $v$ directions. (For example, the antialiasing techniques in @textures-and-materials use this information to antialias textures on objects that are seen reflected in curved surfaces.) The differential changes in normal $∂ upright(bold(n)) \/ ∂ u$ and $∂ upright(bold(n)) \/ ∂ v$ are given by the Weingarten equations from differential geometry:
][
  确定法向量如何随着我们沿着 $u$ 和 $v$ 方向移动而变化也是有用的。（例如，@textures-and-materials 中的抗锯齿技术使用此信息来对在曲面上反射的物体上的纹理进行抗锯齿。）法向量的微分变化 $∂ upright(bold(n)) \/ ∂ u$ 和 $∂ upright(bold(n)) \/ ∂ v$ 由微分几何中的 #emph[Weingarten 方程] 给出：
]

$
  frac(diff upright(bold(n)), diff u) & = frac(f F - e G, E G - F^2) frac(diff upright(bold(p)), diff u) + frac(e F - f E, E G - F^2) frac(diff upright(bold(p)), diff v) \
  frac(diff upright(bold(n)), diff v) & = frac(g F - f G, E G - F^2) frac(diff upright(bold(p)), diff u) + frac(f F - g E, E G - F^2) frac(diff upright(bold(p)), diff v) .
$

#parec[
  where $E$, $F$, and $G$ are coefficients of the first fundamental form and are given by
][
  其中 $E$ 、 $F$ 和 $G$ 是第一基本形式的系数，其表达式为
]

$
  E & = lr(|frac(diff upright(bold(p)), diff u)|)^2 \
  F & =(frac(diff upright(bold(p)), diff u) dot.op frac(diff upright(bold(p)), diff v)) \
  G & = lr(|frac(diff upright(bold(p)), diff v)|)^2 .
$

#parec[
  These are easily computed with the $∂ upright(bold(p)) \/ ∂ u$ and $∂ upright(bold(p)) \/ ∂ v$ values found earlier. The $e$, $f$, and $g$ are coefficients of _the second fundamental form_,
][
  利用前面求得的 $frac(∂ upright(bold(p)), ∂ u)$ 与 $frac(∂ upright(bold(p)), ∂ v)$，可以直接计算这些系数。$e$、$f$、$g$ 则是_第二基本形式_的系数：
]

$
  e & = (upright(bold(n)) dot (∂^2 p) / (∂ u^2))\
  f & = (upright(bold(n)) dot (∂^2 p) / (∂ u ∂ v))\
  g & = (upright(bold(n)) dot (∂^2 p) / (∂ v^2)).
$

#parec[
  The two fundamental forms capture elementary metric properties of a surface, including notions of distance, angle, and curvature; see a differential geometry textbook such as Gray (#source-cite("Gray93")) for details. To find $e$, $f$ and $g$, it is necessary to compute the second-order partial derivatives $∂^2 p \/ ∂ u^2$ and so on.
][
  两个基本形式捕捉了表面的基本度量属性，包括距离、角度和曲率的概念；详情请参阅 Gray (#source-cite("Gray93")) 等微分几何教材。为了找到 $e$ 、 $f$ 和 $g$，需要计算二阶偏导数 $∂^2 p \/ ∂ u^2$ 等。
]

#parec[
  For spheres, a little more algebra gives the second derivatives:
][
  对于球体，进行一些代数运算后可以得到二阶导数：
]
$
  frac(diff^2 upright(bold(p)), diff u^2) & = - phi.alt_("max")^2 (x comma y comma 0) \
  frac(diff^2 upright(bold(p)), diff u diff v) & =(theta_("max") - theta_("min")) z phi.alt_("max")(
    -sin phi.alt comma cos phi.alt comma 0
  ) \
  frac(diff^2 upright(bold(p)), diff v^2) & = -(theta_("max") - theta_("min"))^2 (x comma y comma z) .
$

#parec[
  The translation into code is straightforward.
][
  可以直接转成代码：
]

#block(sticky: true)[#raw("<<Compute sphere ∂n/∂u and ∂n/∂v >>=")] <fragment-Computespherednduanddndv-0>
```cpp
Vector3f d2Pduu = -phiMax * phiMax * Vector3f(pHit.x, pHit.y, 0);
Vector3f d2Pduv = (thetaZMax - thetaZMin) * pHit.z * phiMax *
    Vector3f(-sinPhi, cosPhi, 0.);
Vector3f d2Pdvv = -Sqr(thetaZMax - thetaZMin) * Vector3f(pHit.x,pHit.y,pHit.z);
<<Compute coefficients for fundamental forms>>
<<Compute ∂n/∂u and ∂n/∂v from fundamental form coefficients>>
```



#parec[
  Given all the partial derivatives, it is also easy to compute the coefficients of the fundamental forms.
][
  给定所有的偏导数，计算基本形式的系数也很容易。
]

#block(sticky: true)[#raw("<<Compute coefficients for fundamental forms>>=")] <fragment-Computecoefficientsforfundamentalforms-0>
```cpp
Float E = Dot(dpdu, dpdu), F = Dot(dpdu, dpdv), G = Dot(dpdv, dpdv);
Vector3f n = Normalize(Cross(dpdu, dpdv));
Float e = Dot(n, d2Pduu), f = Dot(n, d2Pduv), g = Dot(n, d2Pdvv);
```


#parec[
  We now have all the values necessary to apply the Weingarten equations. For this computation, we have found it worthwhile to use `DifferenceOfProducts()` to compute $E G - F^2$ for the greater numerical accuracy it provides than the direct expression of that computation. Note also that we must be careful to avoid dividing by 0 if that expression is zero-valued so that `dndu` and `dndv` do not take on not-a-number values in that case.
][
  我们现在拥有应用 Weingarten 方程所需的所有值。对于这个计算，我们发现使用`DifferenceOfProducts()` 来计算 $E G - F^2$ 是值得的，因为它提供了比直接表达式更高的数值精度。还要注意，我们必须小心避免在该表达式为零时进行除以0的操作，以免`dndu` 和 `dndv` 在这种情况下取非数值。
]

#block(sticky: true)[#raw("<<Compute ∂n/∂u and ∂n/∂v from fundamental form coefficients>>=")] <fragment-Computednduanddndvfromfundamentalformcoefficients-0>
```cpp
Float EGF2 = DifferenceOfProducts(E, G, F, F);
Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2;
Normal3f dndu = Normal3f((f * F - e * G) * invEGF2 * dpdu +
                         (e * F - f * E) * invEGF2 * dpdv);
Normal3f dndv = Normal3f((g * F - f * G) * invEGF2 * dpdu +
                         (f * F - g * E) * invEGF2 * dpdv);
```

#parec[
  Having computed the surface parameterization and all the relevant partial derivatives, a `SurfaceInteraction` structure that contains all the necessary geometric information for this intersection can be returned. There are three things to note in the parameter values passed to the `SurfaceInteraction` constructor.
][
  计算了表面参数化和所有相关的偏导数后，可以返回一个包含该交点所有必要几何信息的 `SurfaceInteraction` 结构。 在传递给 `SurfaceInteraction` 构造函数的参数值中有三点需要注意。
]

#parec[
  1. The intersection point is provided as a Point3i that takes the pHit point computed earlier and an error bound pError that is initialized in the fragment ⟨Compute error bounds for sphere intersection⟩, which is defined later, in @bounding-intersection-point-error.

  2. The SurfaceInteraction is initialized with object-space geometric quantities (pHit, dpdu, etc.) and is then transformed to rendering space when it is returned. However, one of the parameters is the outgoing direction, $omega_o$. This is passed in to `InteractionFromIntersection()`, but must be transformed to object space before being passed to the constructor so that the returned `Interaction::wo` value is in rendering space again.

  3. The flipNormal parameter indicates whether the surface normal should be flipped after it is initially computed with the cross product of dpdu and dpdv. This should be done either if the ReverseOrientation directive has been enabled or if the object-to-rendering-space transform swaps coordinate system handedness (but not if both of these are the case). (The need for the latter condition was discussed in @surface-interaction .)
][
  1. 交点作为 `Point3i` 提供，它采用先前计算的 pHit 点和一个误差范围 pError，该误差范围在片段 ⟨Compute error bounds for sphere intersection⟩ 中初始化，稍后在@bounding-intersection-point-error 中定义。

  2. `SurfaceInteraction` 使用对象空间的几何量（pHit、dpdu 等）初始化，然后在返回时转换为渲染空间。然而，其中一个参数是出射方向，$omega_o$。这被传递给 `InteractionFromIntersection()`，但必须在传递给构造函数之前转换为对象空间，以便返回的 `Interaction::wo` 值再次处于渲染空间。

  3. `flipNormal` 参数指示在最初用 `dpdu` 和 `dpdv` 的叉积计算表面法向量后是否应该翻转法向量。这应该在启用了 `ReverseOrientation` 指令或对象到渲染空间的变换交换了坐标系的手性时进行（但如果两者都是这种情况则不进行）。这种情况的必要性在@surface-interaction 中讨论过。
]

#block(sticky: true)[#raw("<<Return SurfaceInteraction for quadric intersection>>=")] <fragment-ReturnmonoSurfaceInteractionforquadricintersection-0>
```cpp
bool flipNormal = reverseOrientation ^ transformSwapsHandedness;
Vector3f woObject = (*objectFromRender)(wo);
return (*renderFromObject)(
    SurfaceInteraction(Point3fi(pHit, pError), Point2f(u, v), woObject,
                       dpdu, dpdv, dndu, dndv, time, flipNormal));
```

=== #ez_caption[Surface Area][表面积]
<surface-area>
#parec[
  To compute the surface area of quadrics, we use a standard formula from integral calculus. If a curve $y = f (x)$ from $x = a$ to $x = b$ is revolved around the $x$ axis, the surface area of the resulting swept surface is
][
  为了计算二次曲面的表面积，我们使用积分学中的标准公式。如果将曲线 $y = f (x)$ 从 $x = a$ 到 $x = b$ 绕 $x$ 轴旋转，所得到的扫掠曲面的表面积为
]
$ 2 pi integral_a^b f (x) sqrt(1 + (f prime (x))^2) thin d x , $
#parec[
  where $f prime (x)$ denotes the derivative $frac(d f, d x)$. Since most of our surfaces of revolution are only partially swept around the axis, we will instead use the formula
][
  其中 $f prime (x)$ 表示导数 $frac(d f, d x)$。由于我们的大多数旋转曲面仅部分绕轴旋转，因此我们将使用公式
]



$ phi.alt_("max") integral_a^b f (x) sqrt(1 + (f prime (x))^2) thin d x . $
#parec[
  The sphere is a surface of revolution of a circular arc. The function that defines the profile curve along the $z$ axis of the sphere is
][
  球体是圆弧的旋转曲面。定义球体沿 $z$ 轴的轮廓曲线的函数是
]

$ f (z) = sqrt(r^2 - z^2) , $

#parec[
  and its derivative is
][
  其导数为
]
$ f prime (z) = - z / sqrt(r^2 - z^2) . $

#parec[
  Recall that the sphere is clipped at $z_("min")$ and $z_("max")$. The surface area is therefore
][
  回忆一下，球体在 $z_("min")$ 和 $z_("max")$ 处被截断。因此表面积为
]

$
  A & = phi.alt_("max") integral_(z_("min"))^(z_("max")) sqrt(r^2 - z^2) sqrt(1 + frac(z^2, r^2 - z^2)) thin d z\
  & = phi.alt_("max") integral_(z_("min"))^(z_("max")) sqrt(r^2 - z^2 + z^2) thin d z\
  & = phi.alt_("max") integral_(z_("min"))^(z_("max")) r thin d z\
  & = phi.alt_("max") thin r (z_("max") - z_("min")) .
$
#parec[
  For the full sphere, $phi.alt_("max") = 2 pi$, $z_("min") = - r$, and $z_("max") = r$, so we have the standard formula $A = 4 pi r^2 ,$ confirming that the formula makes sense.
][
  对于完整的球体， $phi.alt_("max") = 2 pi$， $z_("min") = - r$， $z_("max") = r$，所以我们有标准公式 $A = 4 pi r^2 ,$ 这验证了公式的合理性。
]
#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-6>
```cpp
Float Area() const { return phiMax * radius * (zMax - zMin); }
```



=== #ez_caption[Sampling][采样]
<sphere-sampling>
#parec[
  Uniformly sampling a point on the sphere's area is easy: `Sphere::Sample()` generates a point on the unit sphere using #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformSphere")[`SampleUniformSphere()`] and then scales the point by the sphere's radius. A bound on the numeric error in this value is found in a fragment that will be defined later.
][
  在球体表面均匀采样一个点很简单：`Sphere::Sample()` 使用 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformSphere")[`SampleUniformSphere()`] 在单位球上生成一个点，然后通过球体的半径缩放该点。该值的数值误差界限将在后续定义的片段中给出。
]

#block(sticky: true)[#raw("<<Sphere Method Definitions>>+=")] <fragment-SphereMethodDefinitions-1>
```cpp
pstd::optional<ShapeSample> Sphere::Sample(Point2f u) const {
    Point3f pObj = Point3f(0, 0, 0) + radius * SampleUniformSphere(u);
    <<Reproject pObj to sphere surface and compute pObjError>>
    <<Compute surface normal for sphere sample and return ShapeSample>>
}
```


#parec[
  Because the object-space sphere is at the origin, the object-space surface normal is easily found by converting the object-space point to a normal vector and then normalizing it. A #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] for the sample point can be initialized from `pObj` and its error bounds. The final sample is returned in rendering space with a PDF equal to one over the surface area, since this `Sample()` method samples uniformly by surface area.
][
  由于对象空间的球体位于原点，表面法向量可以通过将对象空间的点转换为法向量并归一化来轻松获得。可以从 `pObj` 及其误差界限初始化#link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`]以表示样本点。最终的样本在渲染空间中返回，其概率密度函数（PDF）等于表面积的倒数，因为这个 `Sample()` 方法是按表面积均匀采样的。
]

#block(sticky: true)[#raw("<<Compute surface normal for sphere sample and return ShapeSample>>=")] <fragment-ComputesurfacenormalforspheresampleandreturnmonoShapeSample-0>
```cpp
Normal3f nObj(pObj.x, pObj.y, pObj.z);
Normal3f n = Normalize((*renderFromObject)(nObj));
if (reverseOrientation)
    n *= -1;
<<Compute (u, v) coordinates for sphere sample>>
Point3fi pi = (*renderFromObject)(Point3fi(pObj, pObjError));
return ShapeSample{Interaction(pi, n, uv), 1 / Area()};
```


#parec[
  The $(u , v)$ parametric coordinates for the point are given by inverting @eqt:sphere-theta-phi and @eqt:sphere-uv.
][
  点的 $(u , v)$ 参数坐标可通过反解@eqt:sphere-theta-phi 和 @eqt:sphere-uv 给出。
]

#block(sticky: true)[#raw("<<Compute (u, v) coordinates for sphere sample>>=")] <fragment-Computeuvcoordinatesforspheresample-0>
```cpp
Float theta = SafeACos(pObj.z / radius);
Float phi = std::atan2(pObj.y, pObj.x);
if (phi < 0) phi += 2 * Pi;
Point2f uv(phi / phiMax, (theta - thetaZMin) / (thetaZMax - thetaZMin));
```


#parec[
  The associated `PDF()` method returns the same PDF.
][
  相应的 `PDF()` 方法返回相同的概率密度值。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-7>
```cpp
Float PDF(const Interaction &) const { return 1 / Area(); }
```


#parec[
  For the sphere sampling method that is given a point being illuminated, we can do much better than sampling over the sphere's entire area. While uniform sampling over its surface would be perfectly correct, a better approach is not to sample points on the sphere that are definitely not visible (such as those on the back side of the sphere as seen from the point). The sampling routine here instead uniformly samples directions over the solid angle subtended by the sphere from the reference point and then computes the point on the sphere corresponding to the sampled direction.
][
  对于给定的被照亮点，球体采样方法可以比在整个球体表面均匀采样更为有效。虽然在其表面上均匀采样是完全正确的，但更好的方法是不采样那些肯定不可见的点（例如从该点看去球体背面的点）。这里的采样程序改为在从参考点看去的球体所覆盖的立体角上均匀采样，然后计算与采样方向对应的球体上的点。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-8>
```cpp
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx,
                                   Point2f u) const {
    <<Sample uniformly on sphere if p is inside it>>
    <<Sample sphere uniformly inside subtended cone>>
    <<Return ShapeSample for sampled point on sphere>>
}
```

#parec[
  For points that lie inside the sphere, the entire sphere should be sampled, since the whole sphere is visible from inside it. Note that the reference point used in this determination, `pOrigin`, is computed using the `OffsetRayOrigin()` function. Doing so ensures that if the reference point came from a ray intersecting the sphere, the point tested does not lie on the wrong side of the sphere due to rounding error.
][
  对于位于球体内部的点，应对整个球体进行采样，因为从内部可以看到整个球体。请注意，用于此判断的参考点 `pOrigin` 是通过 `OffsetRayOrigin()` 函数计算的。这样做可以确保如果参考点来自与球体相交的光线，测试点也不会因舍入误差而落在球体的错误一侧。
]

#block(sticky: true)[#raw("<<Sample uniformly on sphere if p is inside it>>=")] <fragment-Sampleuniformlyonsphereifptisinsideit-0>
```cpp
Point3f pCenter = (*renderFromObject)(Point3f(0, 0, 0));
Point3f pOrigin = ctx.OffsetRayOrigin(pCenter);
if (DistanceSquared(pOrigin, pCenter) <= Sqr(radius)) {
    <<Sample shape by area and compute incident direction wi>>
    <<Convert area sampling PDF in ss to solid angle measure>>
    return ss;
}
```

#parec[
  A call to the first `Sample()` method gives an initial ShapeSample for a point on the sphere. The direction vector from the reference point to the sampled point `wi` is computed and then normalized, so long as it is non-degenerate.
][
  调用第一个 `Sample()` 方法会为球体上的一个点提供初始的 `ShapeSample`。然后，从参考点到采样点的方向向量 `wi` 被计算出来，并在其非退化的情况下进行归一化。
]


#block(sticky: true)[#raw("<<Sample shape by area and compute incident direction wi>>=")] <fragment-Sampleshapebyareaandcomputeincidentdirectionmonowi-0>
```cpp
pstd::optional<ShapeSample> ss = Sample(u);
ss->intr.time = ctx.time;
Vector3f wi = ss->intr.p() - ctx.p();
if (LengthSquared(wi) == 0) return {};
wi = Normalize(wi);
```


#parec[
  To compute the value of the PDF, the method converts the value of the PDF with respect to surface area from the call to `Sample()` to a PDF with respect to solid angle from the reference point. Doing so requires division by the factor
][
  为了计算 PDF 的值，该方法将 `Sample()` 返回的相对于表面积的 PDF 值转换为参考点处相对于立体角的 PDF 值。这样做需要除以因子
]

$
  frac(d omega_i, d A) = frac(cos theta_o, r^2),
$

#parec[
  where $theta_o$ is the angle between the direction of the ray from the point on the light to the reference point and the light's surface normal, and $r^2$ is the distance between the point on the light and the point being shaded (recall the discussion about transforming between area and directional integration domains in @integrals-over-area).
][
  其中 $theta_o$ 是从光源上的点到参考点的光线方向与光源表面法向量之间的角度， $r^2$ 是光源上的点与着色点之间的距离（回忆@integrals-over-area 中关于在面积和方向积分域之间转换的讨论）。
]

#parec[
  In the rare case that the surface normal and `wi` are perpendicular, this results in an infinite value, in which case no valid sample is returned.
][
  在少数情况下，表面法向量和 `wi` 垂直，这将导致一个无限值，此时不返回有效样本。
]

#block(sticky: true)[#raw("<<Convert area sampling PDF in ss to solid angle measure>>=")] <fragment-ConvertareasamplingPDFinmonosstosolidanglemeasure-0>
```cpp
ss->pdf /= AbsDot(ss->intr.n, -wi) /
           DistanceSquared(ctx.p(), ss->intr.p());
if (IsInf(ss->pdf))
    return {};
```

#parec[
  For the more common case of a point outside the sphere, sampling within the cone proceeds.
][
  对于更常见的球体外部点的情况，继续在圆锥内进行采样。
]

#block(sticky: true)[#raw("<<Sample sphere uniformly inside subtended cone>>=")] <fragment-Samplesphereuniformlyinsidesubtendedcone-0>
```cpp
<<Compute quantities related to the theta_max for cone>>
<<Compute theta and phi values for sample in cone>>
<<Compute angle alpha from center of sphere to sampled point on surface>>
<<Compute surface normal and sampled point on sphere>>
```


#parec[
  If the reference point is outside the sphere, then as seen from the reference point $p$ the sphere subtends an angle
][
  如果参考点在球体之外，那么从参考点 $p$ 看去，球体的张角为
]
$
  theta_("max") = arcsin(frac(r,|upright(bold(p)) - upright(bold(p))_c|)) = arccos(sqrt(1 -(frac(r,|upright(bold(p)) - upright(bold(p))_c|))^2)),
$ <sphere-sample-eqt>

#parec[
  where $r$ is the radius of the sphere and $p_c$ is its center (@fig:sphere-sample-fig ). The sampling method here computes the cosine of the subtended angle $theta_("max")$ using @eqt:sphere-sample-eqt and then uniformly samples directions inside this cone of directions using an approach that is derived for the `SampleUniformCone()` function in Section A.5.4, sampling an offset $theta$ from the center vector $omega_c$ and then uniformly sampling a rotation angle $phi.alt$ around the vector. That function is not used here, however, as we will need some of the intermediate values in the following fragments.
][
  其中 $r$ 是球体的半径， $p_c$ 是其中心（@fig:sphere-sample-fig ）。这里的采样方法使用@eqt:sphere-sample-eqt 计算张角 $theta_("max")$ 的余弦值，然后使用在第 A.5.4 节中为 `SampleUniformCone()`函数推导的方法，在该方向圆锥内均匀采样方向，采样从中心向量 $omega_c$ 的偏移 $theta$ ，然后均匀采样绕该向量的旋转角度 $phi.alt$。然而，这里不使用该函数，因为我们将在接下来的片段中需要一些中间值。
]


#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f05.svg"),
  caption: [#ez_caption[
      To sample points on a spherical light source, we can
      uniformly sample within the cone of directions around a central vector $omega_c$ with an angular spread of up to $theta_("max")$. Trigonometry can be used to derive the value of $sin theta_("max") = r \/ lr(| p_c - p|)$.
    ][
      为了在球形光源上采样点，我们可以在围绕中心向量 $omega_c$
      的方向圆锥内均匀采样，角度扩展最大到
      $theta_("max")$。可以使用三角学推导出
      $sin theta_("max") = r \/ lr(| p_c -   p|)$
      的值。
    ]
  ],
)<sphere-sample-fig>

#block(sticky: true)[#raw("<<Compute quantities related to the theta_max for cone>>=")] <fragment-Computequantitiesrelatedtothetheta_romanmaxforcone-0>
```cpp
Float sinThetaMax = radius / Distance(ctx.p(), pCenter);
Float sin2ThetaMax = Sqr(sinThetaMax);
Float cosThetaMax = SafeSqrt(1 - sin2ThetaMax);
Float oneMinusCosThetaMax = 1 - cosThetaMax;
```

#parec[
  As shown in Section A.5.4, uniform sampling of $cos theta$ between $cos theta_("max")$ and 1 gives the cosine of a uniformly sampled direction in the cone.
][
  如第 A.5.4 节所示，在 $cos theta_("max")$ 和 1 之间均匀采样 $cos theta$ 给出圆锥内均匀采样方向的余弦。
]


#block(sticky: true)[#raw("<<Compute theta and phi values for sample in cone>>=")] <fragment-Computethetaandphivaluesforsampleincone-0>
```cpp
Float cosTheta = (cosThetaMax - 1) * u[0] + 1;
Float sin2Theta = 1 - Sqr(cosTheta);
if (sin2ThetaMax < 0.00068523f /* sin^2(1.5 deg) */) {
    <<Compute cone sample via Taylor series expansion for small angles>>
}
```

#parec[
  For very small $theta_("max")$ angles, $cos^2 theta_("max")$ is close to one. Computing $sin^2 theta$ by subtracting this value from 1 gives a value close to 0, but with very little accuracy, since there is much less floating-point precision close to 1 than there is by 0. Therefore, in this case, we use single-term Taylor expansions near 0 to compute $sin^2 theta$ and related terms, which gives much better accuracy.
][
  对于非常小的 $theta_("max")$ 角度， $cos^2 theta_("max")$ 接近于 1。通过从1减去该值计算 $sin^2 theta$ 会得到一个接近 0 的值，但精度很低，因为在接近 1 时浮点精度远低于接近 0。因此，在这种情况下，我们使用接近 0 的单项泰勒展开来计算 $sin^2 theta$ 和相关项，这提供了更好的精度。
]
#block(sticky: true)[#raw("<<Compute cone sample via Taylor series expansion for small angles>>=")] <fragment-ComputeconesampleviaTaylorseriesexpansionforsmallangles-0>
```cpp
sin2Theta = sin2ThetaMax * u[0];
cosTheta = std::sqrt(1 - sin2Theta);
oneMinusCosThetaMax = sin2ThetaMax / 2;
```

#parec[
  Given a sample angle $(theta , phi.alt)$ with respect to the sampling coordinate system computed earlier, we can directly compute the corresponding point on the sphere. The first step is to find the angle $gamma$ between the vector from the reference point $ p_r$ to the sampled point on the sphere $ p_s$ and the vector from the center of the sphere $ p_c$ to $ p_s$. The basic setting is shown in @fig:sphere-sample-point-geometry.
][
  给定相对于先前计算的采样坐标系的样本角度 $(theta , phi.alt)$，我们可以直接计算球体上的相应点。第一步是找到从参考点 $ p_r$ 到球体上采样点 $ p_s$ 的向量与从球体中心 $ p_c$ 到 $ p_s$ 的向量之间的角度 $gamma$。基本设置如@fig:sphere-sample-point-geometry 所示。
]
#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f06.svg"),
  caption: [#ez_caption[
      *Geometric Setting for Computing the Sampled Point on the Sphere Corresponding to a Sampled Angle $theta$.* Consider the
      triangle shown here. The lengths of two sides are known: one is the
      radius of the sphere $r$ and the other is $d_c$, the distance from
      the reference point to the center of the sphere. We also know one
      angle, $theta$. Given these, we first solve for the angle
      $gamma$ before finding $cos alpha$.
    ][
      *计算与样本角度 $theta$ 对应的球体上采样点的几何示例。*考虑这里显示的三角形。已知两边的长度：一个是球体的半径 $r$，另一个是从参考点到球体中心的距离 $d_c$。我们也知道一个角度 $theta$。给定这些，我们首先求解角度 $gamma$，然后找到 $cos alpha$。
    ]
  ],
) <sphere-sample-point-geometry>

#parec[
  We denote the distance from the reference point to the center of the sphere by $d_c$. Applying the law of sines, we can find that
][
  我们用 $d_c$ 表示从参考点到球体中心的距离。应用正弦定律，我们可以发现
]

$
  sin gamma = d_c / r sin theta
$

#parec[
  Because $gamma$ is an obtuse angle, $gamma = pi - arcsin (d_c / r sin theta)$. Given two of the three angles of the triangle, it follows that
][
  因为 $gamma$ 是一个钝角， $gamma = pi - arcsin (d_c / r sin theta)$。给定三角形的三个角中的两个，可以得出
]

$ alpha = pi - gamma - theta = arcsin( d_c/ r sin theta) - theta $
#parec[
  We can avoid expensive inverse trigonometric functions by taking advantage of the fact that we only need the sine and cosine of $alpha$. If we take the cosine of both sides of this equation, apply the cosine angle addition formula, and then use the two relationships $sin theta_(upright("max")) = r / d_c$ and $cos (arcsin x) = sqrt(1 - x^2)$, we can find
][
  我们可以通过只需要 $alpha$ 的正弦和余弦这一事实，来避免使用昂贵的反三角函数。如果我们对这个方程两边的取余弦，应用余弦角加法公式，然后使用两个关系 $sin theta_(upright("max")) = r / d_c$ 和 $cos (arcsin x) = sqrt(1 - x^2)$，我们可以找到
]

$
  cos alpha = frac(sin^2 theta, sin theta_(upright("max"))) + cos theta sqrt(1 - frac(sin^2 theta, sin^2 theta_(upright("max")))) .
$
#parec[
  The value of $sin alpha$ follows from the identity $sin alpha = sqrt(1 - cos^2 alpha) .$
][
  $sin alpha$ 的值来自于恒等式 $sin alpha = sqrt(1 - cos^2 alpha) .$
]

#block(sticky: true)[#raw("<<Compute angle alpha from center of sphere to sampled point on surface>>=")] <fragment-Computeanglealphafromcenterofspheretosampledpointonsurface-0>
```cpp
Float cosAlpha = sin2Theta / sinThetaMax +
                 cosTheta * SafeSqrt(1 - sin2Theta / Sqr(sinThetaMax));
Float sinAlpha = SafeSqrt(1 - Sqr(cosAlpha));
```

#parec[
  The angle $alpha$ and $phi.alt$ give the spherical coordinates for the sampled direction with respect to a coordinate system with $z$ axis centered around the vector from the reference point to the sphere center. We can use an instance of the `Frame` class to transform the direction from that coordinate system to rendering space. The surface normal on the sphere can then be computed as the negation of that vector and the point on the sphere can be found by scaling by the radius and translating by the sphere's center point.
][
  角度 $alpha$ 和 $phi.alt$ 给出了采样方向的球面坐标；所用坐标系的 $z$ 轴沿从参考点指向球心的向量。我们可以使用 `Frame` 类的一个实例将方向从该坐标系转换到渲染空间。然后可以通过取该向量的负值来计算球面上的法向量。通过按半径缩放并通过球心点平移，可以找到球面上的点。
]

#block(sticky: true)[#raw("<<Compute surface normal and sampled point on sphere>>=")] <fragment-Computesurfacenormalandsampledpointonsphere-0>
```cpp
Float phi = u[1] * 2 * Pi;
Vector3f w = SphericalDirection(sinAlpha, cosAlpha, phi);
Frame samplingFrame = Frame::FromZ(Normalize(pCenter - ctx.p()));
Normal3f n(samplingFrame.FromLocal(-w));
Point3f p = pCenter + radius * Point3f(n.x, n.y, n.z);
if (reverseOrientation)
    n *= -1;
```

#parec[
  The ⟨Compute $(u , v)$ coordinates for sampled point on sphere⟩ fragment applies the same mapping using the object space sampled point as is done in the `Intersect()` method, and so it is elided. The PDF for uniform sampling in a cone is $1 / (2 pi (1 - cos theta_(upright("max"))))$. (A derivation is in Section A.5.4.)
][
  ⟨Compute $(u , v)$ coordinates for sampled point on sphere⟩片段使用与 `Intersect()` 方法中相同的映射应用于对象空间采样点，因此被省略。圆锥内均匀采样的概率密度函数（PDF）为 $1 \/ (2 pi (1 - cos theta_(upright("max"))))$。（推导在附录 A.5.4 节中。）
]

#block(sticky: true)[#raw("<<Return ShapeSample for sampled point on sphere>>=")] <fragment-ReturnmonoShapeSampleforsampledpointonsphere-0>
```cpp
<<Compute pError for sampled point on sphere>>
<<Compute (u, v) coordinates for sampled point on sphere>>
return ShapeSample{Interaction(Point3fi(p, pError), n, ctx.time, uv),
                   1 / (2 * Pi * oneMinusCosThetaMax)};
```


#parec[
  The method that computes the PDF for sampling a direction toward a sphere from a reference point also differs depending on which of the two sampling strategies would be used for the point.
][
  计算从参考点到球体方向的采样 PDF 的方法也会因使用哪种采样策略而有所不同。
]

#block(sticky: true)[#raw("<<Sphere Public Methods>>+=")] <fragment-SpherePublicMethods-9>
```cpp
Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const {
    Point3f pCenter = (*renderFromObject)(Point3f(0, 0, 0));
    Point3f pOrigin = ctx.OffsetRayOrigin(pCenter);
    if (DistanceSquared(pOrigin, pCenter) <= Sqr(radius)) {
        <<Return solid angle PDF for point inside sphere>>
    }
    <<Compute general solid angle sphere PDF>>
}
```

#parec[
  If the reference point is inside the sphere, a uniform area sampling strategy would have been used.
][
  如果参考点位于球体内部，则会采用均匀面积采样策略。
]

#block(sticky: true)[#raw("<<Return solid angle PDF for point inside sphere>>=")] <fragment-ReturnsolidanglePDFforpointinsidesphere-0>
```cpp
<<Intersect sample ray with shape geometry>>
<<Compute PDF in solid angle measure from shape intersection point>>
return pdf;
```
#parec[
  First, the corresponding point on the sphere is found by intersecting a ray leaving the reference point in direction `wi` with the sphere. Note that this is a fairly efficient computation since it is only intersecting the ray with a single sphere and not the entire scene.
][
  首先，通过将从参考点出发的`wi`方向的射线与球体相交来找到球体上的对应点。注意这是一个相当高效的计算，因为它只与一个球体相交，而不是整个场景。
]

#block(sticky: true)[#raw("<<Intersect sample ray with shape geometry>>=")] <fragment-Intersectsampleraywithshapegeometry-0>
```cpp
Ray ray = ctx.SpawnRay(wi);
pstd::optional<ShapeIntersection> isect = Intersect(ray);
if (!isect) return 0;
```


#parec[
  In turn, the uniform area density of one over the surface area is converted to a solid angle density following the same approach as was used in the previous `Sample()` method.
][
  接着，沿用前一个 `Sample()` 方法中的转换方式，将值为表面积倒数的均匀面积概率密度转换为立体角概率密度。
]

#block(sticky: true)[#raw("<<Compute PDF in solid angle measure from shape intersection point>>=")] <fragment-ComputePDFinsolidanglemeasurefromshapeintersectionpoint-0>
```cpp
Float pdf = (1 / Area()) / (AbsDot(isect->intr.n, -wi) /
                            DistanceSquared(ctx.p(), isect->intr.p()));
if (IsInf(pdf)) pdf = 0;
```


#parec[
  The value of the PDF is easily computed using the same trigonometric identities as were used in the sampling routine.
][
  PDF 的值可以很容易地使用与采样例程中相同的三角恒等式计算。
]

#block(sticky: true)[#raw("<<Compute general solid angle sphere PDF>>=")] <fragment-ComputegeneralsolidanglespherePDF-0>
```cpp
Float sin2ThetaMax = radius * radius / DistanceSquared(ctx.p(), pCenter);
Float cosThetaMax = SafeSqrt(1 - sin2ThetaMax);
Float oneMinusCosThetaMax = 1 - cosThetaMax;
<<Compute more accurate oneMinusCosThetaMax for small solid angle>>
return 1 / (2 * Pi * oneMinusCosThetaMax);
```


#parec[
  Here it is also worth considering numerical accuracy when the sphere subtends a small solid angle from the reference point. In that case, `cosThetaMax ` will be close to 1 and the value of `oneMinusCosThetaMax ` will be relatively inaccurate; we then switch to the one-term Taylor approximation of $1 - cos theta approx 1 / 2 sin^2 theta$, which is more accurate near zero.
][
  这里也值得考虑当球体从参考点看去的立体角很小时的数值精度。在这种情况下，`cosThetaMax ` 将接近于 1，而 `oneMinusCosThetaMax ` 的值将相对不准确；然后我们切换到 $1 - cos theta approx 1 / 2 sin^2 theta$ 的一项泰勒近似，它在接近零时更准确。
]

#block(sticky: true)[#raw("<<Compute more accurate oneMinusCosThetaMax for small solid angle>>=")] <fragment-ComputemoreaccuratemonooneMinusCosThetaMaxforsmallsolidangle-0>
```cpp
if (sin2ThetaMax < 0.00068523f /* sin^2(1.5 deg) */)
    oneMinusCosThetaMax = sin2ThetaMax / 2;
```



#parec[Source notes: the prose says `Intersection()`, `Point3i`, and `std::atan()`, while the accompanying code uses `Intersect()`, `Point3fi`, and `std::atan2()`. It also describes $theta$ as normalized to $[0,1]$ where the code actually normalizes $v$, and calls $r^2$ a distance where the conversion formula and `DistanceSquared()` require a squared distance. These source wordings are preserved above.][原文校注：文字写作 `Intersection()`、`Point3i`、`std::atan()`，对应代码则使用 `Intersect()`、`Point3fi`、`std::atan2()`。文字还称 $theta$ 归一化到 $[0,1]$，代码实际归一化的是 $v$；面积与立体角转换段将 $r^2$ 称为距离，而公式和 `DistanceSquared()` 使用的是距离平方。上文保留原文措辞，特此说明。]

#parec[Implementation scope note: the source code above samples the complete object-space sphere with `SampleUniformSphere()` and does not apply the clipping parameters in that sampling step. Its `Area()` and cone sampling calculations also use the object-space `radius`, without accounting for area changes under a general object-to-rendering transformation. Thus, the support for partial spheres and ellipsoids described for geometric representation and intersection must not be read as a guarantee that these sampling routines cover those cases. The source code is retained unchanged.][实现范围校注：上述原书代码用 `SampleUniformSphere()` 对对象空间中的完整球面采样，未在该采样步骤中应用裁剪参数。`Area()` 及圆锥采样计算也直接使用对象空间的 `radius`，没有计入一般对象到渲染空间变换引起的面积变化。因此，前文在几何表示与求交方面支持部分球体及椭球体，不应被理解为这些采样例程也已覆盖相应情况。原书代码保持不变。]

#include "supplements/6.2-expanded.typ"
