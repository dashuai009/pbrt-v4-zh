#import "../template.typ": parec, ez_caption, translator

== #ez_caption[Curves][曲线]
<curves>
#parec[This section contains advanced content and may be skipped on a first reading.][本节包含进阶内容，初次阅读时可以跳过。]

#parec[
  While triangles or bilinear patches can be used to represent thin shapes for modeling fine geometry like hair, fur, or fields of grass, it is worthwhile to have a specialized `Shape` in order to more efficiently render these sorts of objects, since many individual instances of them are often present. The `Curve` shape, introduced in this section, represents thin geometry modeled with cubic Bézier curves, which are defined by four control points, $p_0$, $p_1$, $p_2$, and $p_3$. The Bézier spline passes through the first and last control points. Points along it are given by the polynomial
][
  虽然三角形或双线性面片可以表示头发、毛皮、草地等精细几何中的细长形状，但这类对象往往包含大量独立实例，因此采用专门的 `Shape` 能提高渲染效率。本节介绍的 `Curve` 用三次贝塞尔曲线表示细长几何。曲线由四个控制点 $p_0$、$p_1$、$p_2$、$p_3$ 定义，经过首尾控制点，其上各点由以下多项式给出：
]

$ p(u)=(1-u)^3 p_0+3(1-u)^2 u p_1+3(1-u)u^2 p_2+u^3 p_3 . $ <bezier-basic>

#parec[
  (See @fig:bezier-curve.) Curves specified using another basis (e.g., Hermite splines or b-splines) must therefore be converted to the Bézier basis to be used with this `Shape`.
][
  参见 @fig:bezier-curve。以其他基（例如 Hermite 样条或 B 样条）指定的曲线，必须先转换到贝塞尔基才能用于此 `Shape`。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f29.svg"), caption:[#ez_caption[A cubic Bézier curve is defined by four control points, $p_i$. The curve $p(u)$, defined in (@eqt:bezier-basic), passes through the first and last control points at $u=0$ and $u=1$, respectively.][三次贝塞尔曲线由四个控制点 $p_i$ 定义。@eqt:bezier-basic 的曲线 $p(u)$ 在 $u=0$ 和 $u=1$ 时分别经过首尾控制点。]]) <bezier-curve>

#parec[
  The `Curve` shape is defined by a 1D Bézier curve along with a width that is linearly interpolated from starting and ending widths along its extent. Together, these define a flat 2D surface (@fig:curve-and-width).#footnote[Note the abuse of terminology: while a curve is a 1D mathematical entity, a Curve shape represents a 2D surface. In the following, we will generally refer to the Shape as a curve. The 1D entity will be distinguished by the name “Bézier curve” when the distinction would not otherwise be clear.] It is possible to directly intersect rays with this representation without tessellating it, which in turn makes it possible to efficiently render smooth curves without using too much storage.
][
  `Curve` 由一维贝塞尔曲线及宽度共同定义；宽度沿曲线在起始宽度与终止宽度之间线性插值。二者定义一个平坦的二维表面（@fig:curve-and-width）。#footnote[注意这里对术语的宽泛使用：数学上的曲线是一维对象，而 `Curve` 形状表示二维表面。下文通常将这一 `Shape` 称为曲线；如果可能产生混淆，则用“贝塞尔曲线”专指一维对象。] 可以直接计算射线与这种表示的交点，无需先进行曲面剖分，因此既能高效渲染光滑曲线，又不必占用过多存储空间。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f30.svg"), caption:[#ez_caption[Basic Geometry of the `Curve` Shape. A 1D Bézier curve is offset by half of the specified width in both the directions orthogonal to the curve at each point along it. The resulting area represents the curve’s surface.][Curve 形状的基本几何。在一维贝塞尔曲线各点处，沿垂直于曲线的两个相反方向分别偏移指定宽度的一半，所围出的区域就是曲线表面。]]) <curve-and-width>

#parec[
  @fig:furry-bunny shows a bunny model with fur modeled with over one million `Curve`s.
][
  @fig:furry-bunny 展示了一只兔子模型，其毛皮由超过一百万条 `Curve` 建模。
]

#figure(image("../pbr-book-website/4ed/Shapes/bunny-fur.png"), caption:[#ez_caption[Furry Bunny. Bunny model with over one million `Curve` shapes used to model fur. Here, we have used unrealistically long curves to better show off the `Curve`’s capabilities, giving an unrealistically shaggy bunny. #emph[(Underlying bunny mesh courtesy of the Stanford Computer Graphics Laboratory.)]][毛茸茸的兔子。超过一百万个 `Curve` 形状用于表示兔子毛皮。为突出 `Curve` 的能力，这里使用了不合实际的长曲线，使兔子的毛发显得异常蓬乱。（基础兔子网格由斯坦福大学计算机图形学实验室提供。）]]) <furry-bunny>

#metadata(none) <Curve>
#block(sticky: true)[#raw("<<Curve Definition>>=")] <fragment-CurveDefinition-0>
```cpp
class Curve {
  public:
    <<Curve Public Methods>> 
  private:
    <<Curve Private Methods>> 
    <<Curve Private Members>> 
};
```

#parec[
  There are three types of curves that the `Curve` shape can represent, shown in @fig:curve-types.
][
  `Curve` 可以表示三种曲线，如 @fig:curve-types 所示。
]

#parec[
- #emph[Flat]: Curves with this representation are always oriented to face the ray being intersected with them; they are useful for modeling fine swept cylindrical shapes like hair or fur.
- #emph[Cylinder]: For curves that span a few pixels on the screen (like spaghetti seen from not too far away), the `Curve` shape can compute a shading normal that makes the curve appear to actually be a cylinder.
- #emph[Ribbon]: This variant is useful for modeling shapes that do not actually have a cylindrical cross section (such as a blade of grass).
][
- 平坦（Flat）：此类型总是面向与之求交的射线，适合表示头发、毛皮等细小的扫掠圆柱形状。
- 圆柱（Cylinder）：对于在屏幕上占几个像素的曲线（例如从不太远处看到的意大利面），`Curve` 可以设置着色法向量，使曲线看起来像真正的圆柱。
- 带状（Ribbon）：适合表示截面并非圆形的形状，例如草叶。
]

#figure(image("../pbr-book-website/4ed/Shapes/threecurves.png"), caption:[#ez_caption[The Three Types of Curves That the `Curve` Shape Can Represent. On the top is a flat curve that is always oriented to be perpendicular to a ray approaching it. The middle is a variant of this curve where the shading normal is set so that the curve appears to be cylindrical. On the bottom is a ribbon, which has a fixed orientation at its starting and ending points; intermediate orientations are smoothly interpolated between them.][Curve 可表示的三种曲线。上：始终垂直于入射射线的平坦曲线。中：设置着色法向量，使其看起来呈圆柱形的变体。下：带状曲线，在首尾端点具有固定朝向，中间朝向通过平滑插值得到。]]) <curve-types>

#parec[
  The `CurveType` enumerator records which of them a given `Curve` instance models.
][
  `CurveType` 枚举记录一个 `Curve` 实例属于哪种类型。
]

#parec[
  The flat and cylinder curve variants are intended to be used as convenient approximations of deformed cylinders. It should be noted that intersections found with respect to them do not correspond to a physically realizable 3D shape, which can potentially lead to minor inconsistencies when taking a scene with true cylinders as a reference.
][
  平坦曲线和圆柱曲线旨在方便地近似变形后的圆柱。需要注意，它们返回的交点并不对应于某个物理上可实现的三维形状；因此，以真实圆柱组成的场景为参照时，可能出现轻微不一致。
]

#block(sticky: true)[#raw("<<CurveType Definition>>=")] <fragment-CurveTypeDefinition-0>
```cpp
enum class CurveType { Flat, Cylinder, Ribbon };
```

#parec[
  Given a curve specified in a `pbrt` scene description file, it can be worthwhile to split it into a few segments, each covering part of the $u$ parametric range of the curve. (One reason for doing so is that axis-aligned bounding boxes do not tightly bound wiggly curves, but subdividing Bézier curves makes them less wiggly—the #emph[variation diminishing property] of polynomials.) Therefore, the `Curve` constructor takes a parametric range of $u$ values, $[u_(min),u_(max)]$, as well as a pointer to a `CurveCommon` structure, which stores the control points and other information about the curve that is shared across curve segments. In this way, the memory footprint for individual curve segments is reduced, which makes it easier to keep many of them in memory.
][
  对于场景描述文件指定的曲线，将其分成若干段、每段覆盖部分 $u$ 参数范围，往往是有益的。一方面，轴对齐包围盒无法紧密包围蜿蜒曲线；另一方面，细分贝塞尔曲线会使各段更平直，这体现了多项式的变差缩减性质。因此，`Curve` 构造函数接受参数范围 $[u_(min),u_(max)]$，以及指向 `CurveCommon` 结构的指针。该结构保存控制点等各曲线段共享的信息，以减小每段的内存占用，便于同时保存大量曲线段。
]

#block(sticky: true)[#raw("<<Curve Public Methods>>=")] <fragment-CurvePublicMethods-0>
```cpp
Curve(const CurveCommon *common, Float uMin, Float uMax)
    : common(common), uMin(uMin), uMax(uMax) {}
```

#block(sticky: true)[#raw("<<Curve Private Members>>=")] <fragment-CurvePrivateMembers-0>
```cpp
const CurveCommon *common;
Float uMin, uMax;
```

#parec[
  The `CurveCommon` constructor initializes member variables with values passed into it for the control points, the curve width, etc. The control points provided to it should be in the curve’s object space.
][
  `CurveCommon` 构造函数用传入的控制点、曲线宽度等值初始化成员变量。控制点应位于曲线的对象空间。
]

#parec[
  For `Ribbon` curves, `CurveCommon` stores a surface normal to orient the curve at each endpoint. The constructor precomputes the angle between the two normal vectors and one over the sine of this angle; these values will be useful when computing the orientation of the curve at arbitrary points along its extent.
][
  对于 `Ribbon` 曲线，`CurveCommon` 在每个端点保存一个表面法向量，用于确定曲线朝向。构造函数预先计算两个法向量之间的夹角及该夹角正弦的倒数，供随后计算曲线上任意位置的朝向使用。
]

#metadata(none) <CurveCommon>
#block(sticky: true)[#raw("<<CurveCommon Definition>>=")] <fragment-CurveCommonDefinition-0>
```cpp
struct CurveCommon {
    <<CurveCommon Public Methods>> 
    <<CurveCommon Public Members>> 
};
```

#block(sticky: true)[#raw("<<CurveCommon Public Members>>=")] <fragment-CurveCommonPublicMembers-0>
```cpp
CurveType type;
Point3f cpObj[4];
Float width[2];
Normal3f n[2];
Float normalAngle, invSinNormalAngle;
const Transform *renderFromObject, *objectFromRender;
bool reverseOrientation, transformSwapsHandedness;
```

=== #ez_caption[Bounding Curves][曲线包围范围]
<bounding-curves>

#parec[
  The object-space bound of a curve can be found by first bounding the spline along the center of the curve and then expanding that bound by half the maximum width the curve takes on over its extent. The `Bounds()` method then transforms that bound to rendering space before returning it.
][
  先计算曲线中心样条的包围范围，再向外扩张曲线全范围内最大宽度的一半，即可得到曲线在对象空间中的包围盒。`Bounds()` 将其变换到渲染空间后返回。
]

#block(sticky: true)[#raw("<<Curve Method Definitions>>=")] <fragment-CurveMethodDefinitions-0>
```cpp
Bounds3f Curve::Bounds() const {
    pstd::span<const Point3f> cpSpan(common->cpObj);
    Bounds3f objBounds = BoundCubicBezier(cpSpan, uMin, uMax);
    <<Expand objBounds by maximum curve width over u range>> 
    return (*common->renderFromObject)(objBounds);
}
```

#block(sticky: true)[#raw("<<Expand objBounds by maximum curve width over u range>>=")] <fragment-ExpandmonoobjBoundsbymaximumcurvewidthoverurange-0>
```cpp
Float width[2] = {Lerp(uMin, common->width[0], common->width[1]),
                  Lerp(uMax, common->width[0], common->width[1])};
objBounds = Expand(objBounds, std::max(width[0], width[1]) * 0.5f);
```

#parec[
  The `Curve` shape cannot be used as an area light, as it does not provide implementations of the required sampling methods. It does provide a `NormalBounds()` method that returns a conservative bound.
][
  `Curve` 未实现所需的采样方法，因此不能用作面光源。它仍提供 `NormalBounds()`，返回保守的法向量方向范围。
]

#block(sticky: true)[#raw("<<Curve Public Methods>>+=")] <fragment-CurvePublicMethods-1>
```cpp
DirectionCone NormalBounds() const { return DirectionCone::EntireSphere(); }
```

=== #ez_caption[Intersection Tests][求交测试]
<curve-intersection-tests>

#parec[
  Both of the intersection methods required by the `Shape` interface are implemented via another `Curve` method, `IntersectRay()`. Rather than returning an optional #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`], it takes a pointer to one.
][
  `Shape` 接口要求的两个求交方法都通过 `Curve` 的 `IntersectRay()` 实现。该方法不返回可选的 `ShapeIntersection`，而是接收指向这一可选值的指针。
]

#block(sticky: true)[#raw("<<Curve Method Definitions>>+=")] <fragment-CurveMethodDefinitions-1>
```cpp
pstd::optional<ShapeIntersection>
Curve::Intersect(const Ray &ray, Float tMax) const {
    pstd::optional<ShapeIntersection> si;
    IntersectRay(ray, tMax, &si);
    return si;
}
```

#parec[
  `IntersectP()` passes `nullptr` to `IntersectRay()`, which indicates that it can return immediately if an intersection is found.
][
  `IntersectP()` 向 `IntersectRay()` 传入 `nullptr`，表示一旦发现交点即可立即返回。
]

#block(sticky: true)[#raw("<<Curve Method Definitions>>+=")] <fragment-CurveMethodDefinitions-2>
```cpp
bool Curve::IntersectP(const Ray &ray, Float tMax) const {
    return IntersectRay(ray, tMax, nullptr);
}
```

#parec[
  The `Curve` intersection algorithm is based on discarding curve segments as soon as it can be determined that the ray definitely does not intersect them and otherwise recursively splitting the curve in half to create two smaller segments that are then tested. Eventually, the curve is linearly approximated for an efficient intersection test. That process starts after some initial preparation and early culling tests in `IntersectRay()`.
][
  `Curve` 求交算法一旦能确定射线不可能与某段曲线相交，就将该段剔除；否则递归地将其分为两半，再测试两个子段。最终用线性近似进行高效求交。`IntersectRay()` 先完成准备工作和初步剔除，再进入这一过程。
]

#block(sticky: true)[#raw("<<Curve Method Definitions>>+=")] <fragment-CurveMethodDefinitions-3>
```cpp
bool Curve::IntersectRay(const Ray &r, Float tMax,
                         pstd::optional<ShapeIntersection> *si) const {
    <<Transform Ray to curve’s object space>> 
    <<Get object-space control points for curve segment, cpObj>> 
    <<Project curve control points to plane perpendicular to ray>> 
    <<Test ray against bound of projected control points>> 
    <<Compute refinement depth for curve, maxDepth>> 
    <<Recursively test for ray–curve intersection>> 
}
```

#block(sticky: true)[#raw("<<Transform Ray to curve’s object space>>=")] <fragment-TransformmonoRaytocurvesobjectspace-0>
```cpp
Ray ray = (*common->objectFromRender)(r);
```

#parec[
  The `CurveCommon` class stores the control points for the full curve, but a `Curve` instance generally needs the four control points that represent the Bézier curve for its $u$ extent. The #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#CubicBezierControlPoints")[`CubicBezierControlPoints()`] utility function performs this computation.
][
  `CurveCommon` 保存完整曲线的控制点，而一个 `Curve` 实例通常需要的是表示其自身 $u$ 范围的四个贝塞尔控制点。辅助函数 `CubicBezierControlPoints()` 完成这一计算。
]

#block(sticky: true)[#raw("<<Get object-space control points for curve segment, cpObj>>=")] <fragment-Getobject-spacecontrolpointsforcurvesegmentmonocpObj-0>
```cpp
pstd::array<Point3f, 4> cpObj =
    CubicBezierControlPoints(pstd::span<const Point3f>(common->cpObj),
                             uMin, uMax);
```

#parec[
  Like the ray–triangle intersection algorithm from Section #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#sec:ray-triangle")[6.5.3], the ray–curve intersection test is based on transforming the curve to a coordinate system with the ray’s origin at the origin of the coordinate system and the ray’s direction aligned to be along the $+z$ axis. Performing this transformation at the start greatly reduces the number of operations that must be performed for intersection tests.
][
  与第 6.5.3 节的射线与三角形求交算法一样，射线与曲线求交先将曲线变换到射线起点位于原点、射线方向沿 $+z$ 轴的坐标系。预先完成这一变换能大幅减少求交所需的运算。
]

#parec[
  For the `Curve` shape, we will need an explicit representation of the transformation, so the `LookAt()` function is used to generate it here. The origin is the ray’s origin and the “look at” point is a point offset from the origin along the ray’s direction. The “up” direction is set to be perpendicular to both the ray’s direction and the vector from the first to the last control point. Doing so helps orient the curve to be roughly parallel to the $x$ axis in the ray coordinate system, which in turn leads to tighter bounds in $y$ (see @fig:bezier-2d-bboxes). This improvement in the fit of the bounds often makes it possible to terminate the recursive intersection tests earlier than would be possible otherwise.
][
  `Curve` 需要显式保存该变换，因此使用 `LookAt()` 构造它。坐标原点取射线起点，观察目标为沿射线方向偏移得到的点。“向上”方向同时垂直于射线方向以及首尾控制点之间的向量。这样，曲线在射线坐标系中大致平行于 $x$ 轴，得到更紧的 $y$ 范围（@fig:bezier-2d-bboxes）。包围盒更贴合曲线，往往能更早终止递归求交。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f33.svg"), caption:[#ez_caption[2D Bounding Boxes of a Bézier Curve. (a) Bounding box computed using the curve’s control points as given. (b) The effect of rotating the curve so that the vector from its first to last control point is aligned with the $x$ axis before computing bounds. The resulting bounding box is a much tighter fit.][贝塞尔曲线的二维包围盒。（a）直接由给定控制点计算包围盒。（b）先旋转曲线，使首尾控制点之间的向量平行于 $x$ 轴，再计算包围盒，所得包围盒更加紧致。]]) <bezier-2d-bboxes>

#parec[
  If the ray and the vector between the first and last control points are parallel, `dx` will be degenerate. In that case we find an arbitrary “up” vector direction so that intersection tests can proceed in this unusual case.
][
  如果射线方向与首尾控制点之间的向量平行，`dx` 就会退化。此时选择任意可用的“向上”方向，使求交能在这一特殊情况下继续进行。
]

#block(sticky: true)[#raw("<<Project curve control points to plane perpendicular to ray>>=")] <fragment-Projectcurvecontrolpointstoplaneperpendiculartoray-0>
```cpp
Vector3f dx = Cross(ray.d, cpObj[3] - cpObj[0]);
if (LengthSquared(dx) == 0) {
    Vector3f dy;
    CoordinateSystem(ray.d, &dx, &dy);
}
Transform rayFromObject = LookAt(ray.o, ray.o + ray.d, dx);
pstd::array<Point3f, 4> cp = {
    rayFromObject(cpObj[0]), rayFromObject(cpObj[1]),
    rayFromObject(cpObj[2]), rayFromObject(cpObj[3]) };
```

#parec[
  Along the lines of the implementation in `Curve::Bounds()`, a conservative bounding box for a curve segment can be found by taking the bounds of the curve’s control points and expanding by half of the maximum width of the curve over the $u$ range being considered.
][
  与 `Curve::Bounds()` 的做法相同，先包围曲线控制点，再向外扩张所考虑 $u$ 范围内最大曲线宽度的一半，即可得到该曲线段的保守包围盒。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f34.svg"), caption:[#ez_caption[Ray–Curve Bounds Test. In the ray coordinate system, the ray’s origin is at $(0,0,0)$ and its direction is aligned with the $+z$ axis. Therefore, if the 2D point $(x,y)=(0,0)$ is outside the $x y$ bounding box of the curve segment, then it is impossible that the ray intersects the curve.][射线与曲线包围范围测试。在射线坐标系中，射线起点为 $(0,0,0)$，方向沿 $+z$ 轴。如果二维点 $(x,y)=(0,0)$ 位于曲线段的 $x y$ 包围盒之外，射线就不可能与曲线相交。]]) <curve-bounds-check>

#parec[
  Because the ray’s origin is at $(0,0,0)$ and its direction is aligned with the $+z$ axis in the intersection space, its bounding box only includes the origin in $x$ and $y$ (@fig:curve-bounds-check); its $z$ extent is given by the $z$ range that its parametric extent covers. Before proceeding with the recursive intersection testing algorithm, the ray’s bounding box is tested for intersection with the curve’s bounding box. The method can return immediately if they do not intersect.
][
  在求交坐标系中，射线起点是 $(0,0,0)$，方向沿 $+z$ 轴，因此其包围盒在 $x$、$y$ 方向仅包含原点（@fig:curve-bounds-check）；$z$ 范围由射线参数范围对应的 $z$ 区间给出。进入递归求交之前，先测试射线包围盒与曲线包围盒是否相交；若不相交即可立即返回。
]

#block(sticky: true)[#raw("<<Test ray against bound of projected control points>>=")] <fragment-Testrayagainstboundofprojectedcontrolpoints-0>
```cpp
Float maxWidth = std::max(Lerp(uMin, common->width[0], common->width[1]),
                          Lerp(uMax, common->width[0], common->width[1]));
Bounds3f curveBounds = Union(Bounds3f(cp[0], cp[1]), Bounds3f(cp[2], cp[3]));
curveBounds = Expand(curveBounds, 0.5f * maxWidth);
Bounds3f rayBounds(Point3f(0, 0, 0), Point3f(0, 0, Length(ray.d) * tMax));
if (!Overlaps(rayBounds, curveBounds))
    return false;
```

#parec[
  The maximum number of times to subdivide the curve is computed so that the maximum distance from the eventual linearized curve at the finest refinement level is bounded to be less than a small fixed distance. We will not go into the details of this computation, which is implemented in the fragment 〈Compute refinement depth for curve, `maxDepth`〉. With the culling tests passed and that value in hand, the recursive intersection tests begin.
][
  最大细分次数的选择应使最深层线性近似与原曲线之间的最大距离小于某个固定的小距离。这里不展开推导；计算实现在〈Compute refinement depth for curve, maxDepth〉片段中。通过剔除测试并求得这一深度后，即开始递归求交。
]

#block(sticky: true)[#raw("<<Recursively test for ray–curve intersection>>=")] <fragment-Recursivelytestforray--curveintersection-0>
```cpp
pstd::span<const Point3f> cpSpan(cp);
return RecursiveIntersect(ray, tMax, cpSpan, Inverse(rayFromObject),
                          uMin, uMax, maxDepth, si);
```

#parec[
  The `RecursiveIntersect()` method then tests whether the given ray intersects the given curve segment over the given parametric range $[u_0,u_1]$. It assumes that the ray has already been tested against the curve’s bounding box and found to intersect it.
][
  `RecursiveIntersect()` 测试给定射线是否与参数范围 `[u0,u1]` 内的曲线段相交。它假设此前已经确认射线与该段的包围盒相交。
]

#block(sticky: true)[#raw("<<Curve Method Definitions>>+=")] <fragment-CurveMethodDefinitions-4>
```cpp
bool Curve::RecursiveIntersect(
        const Ray &ray, Float tMax, pstd::span<const Point3f> cp,
        const Transform &objectFromRay, Float u0, Float u1,
        int depth, pstd::optional<ShapeIntersection> *si) const {
    Float rayLength = Length(ray.d);
    if (depth > 0) {
        <<Split curve segment into subsegments and test for intersection>> 
    } else {
        <<Intersect ray with curve segment>> 
    }
}
```

#parec[
  If the maximum depth has not been reached, a call to #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#SubdivideCubicBezier")[`SubdivideCubicBezier()`] gives the control points for the two Bézier curves that result in splitting the Bézier curve given by `cp` in half. The last control point of the first curve is the same as the first control point of the second, so 7 values are returned for the total of 8 control points. The `u` array is then initialized so that it holds the parametric range of the two curves before each one is processed in turn.
][
  若尚未达到最大深度，就调用 `SubdivideCubicBezier()`，求出将 `cp` 所给贝塞尔曲线分成两半后的两组控制点。第一段的末控制点与第二段的首控制点重合，因此八个控制点只需返回七个值。随后用 `u` 数组记录两个子段的参数范围，并依次处理它们。
]

#block(sticky: true)[#raw("<<Split curve segment into subsegments and test for intersection>>=")] <fragment-Splitcurvesegmentintosubsegmentsandtestforintersection-0>
```cpp
pstd::array<Point3f, 7> cpSplit = SubdivideCubicBezier(cp);
Float u[3] = {u0, (u0 + u1) / 2, u1};
for (int seg = 0; seg < 2; ++seg) {
    <<Check ray against curve segment’s bounding box>> 
    <<Recursively test ray-segment intersection>> 
}
return si ? si->has_value() : false;
```

#parec[
  The bounding box test in the 〈Check ray against curve segment’s bounding box〉 fragment is essentially the same as the one in 〈Test ray against bound of projected control points〉 except that it takes $u$ values from the `u` array when computing the curve’s maximum width over the $u$ range and it uses control points from `cpSplit`. Therefore, it is not included here.
][
  〈Check ray against curve segment’s bounding box〉中的包围盒测试与〈Test ray against bound of projected control points〉基本相同；区别在于计算最大宽度时从 `u` 数组读取范围端点，并使用 `cpSplit` 中的控制点，因此正文不再列出。
]

#parec[
  If the ray does intersect the bounding box, the corresponding segment is given to a recursive call of `RecursiveIntersect()`. If an intersection is found and the ray is a shadow ray, `si` will be `nullptr` and an intersection can immediately be reported. For non-shadow rays, even if an intersection has been found, it may not be the closest intersection, so the other segment still must be considered.
][
  如果射线与包围盒相交，就把相应子段交给 `RecursiveIntersect()` 递归处理。若找到交点且射线是阴影射线，`si` 为 `nullptr`，可立即报告相交。对于非阴影射线，已找到的交点未必最近，因此还必须考虑另一个子段。
]

#block(sticky: true)[#raw("<<Recursively test ray-segment intersection>>=")] <fragment-Recursivelytestray-segmentintersection-0>
```cpp
bool hit = RecursiveIntersect(ray, tMax, cps, objectFromRay, u[seg],
                              u[seg + 1], depth - 1, si);
if (hit && !si)
    return true;
```

#parec[
  The intersection test is made more efficient by using a linear approximation of the curve; the variation diminishing property allows us to make this approximation without introducing too much error.
][
  用曲线的线性近似可以提高求交效率；变差缩减性质使这一近似不致引入过大误差。
]

#block(sticky: true)[#raw("<<Intersect ray with curve segment>>=")] <fragment-Intersectraywithcurvesegment-0>
```cpp
<<Test ray against segment endpoint boundaries>> 
<<Find line w that gives minimum distance to sample point>> 
<<Compute u coordinate of curve intersection point and hitWidth>> 
<<Test intersection point against curve width>> 
if (si) {
    <<Initialize ShapeIntersection for curve intersection>> 
}
return true;
```

#figure(image("../pbr-book-website/4ed/Shapes/pha06f35.svg"), caption:[#ez_caption[Curve Segment Boundaries. The intersection test for a segment of a larger curve computes edge functions for the lines that are perpendicular to the segment endpoints (dashed lines). If a potential intersection point (solid dot) is on the other side of the edge than the segment, it is rejected; another curve segment (if present on that side) should account for this intersection instead.][曲线段边界。对较长曲线的一个子段求交时，为经过子段端点且垂直于对应切线的直线（虚线）计算边函数。如果候选交点（实心点）位于边的另一侧，与子段分居两侧，就拒绝该点；若那一侧还有曲线子段，应由它处理这一交点。]]) <curve-segment-boundaries>

#parec[
  It is important that the intersection test only accepts intersections that are on the `Curve`’s surface for the $u$ segment currently under consideration. Therefore, the first step of the intersection test is to compute edge functions for lines perpendicular to the curve starting point and ending point and to classify the potential intersection point against them (@fig:curve-segment-boundaries).
][
  求交测试只能接受当前 $u$ 子段对应的 `Curve` 表面上的交点。因此，首先为通过曲线首尾端点且垂直于对应切线的直线建立边函数，以判定候选交点位于哪一侧（@fig:curve-segment-boundaries）。
]

#block(sticky: true)[#raw("<<Test ray against segment endpoint boundaries>>=")] <fragment-Testrayagainstsegmentendpointboundaries-0>
```cpp
<<Test sample point against tangent perpendicular at curve start>> 
<<Test sample point against tangent perpendicular at curve end>>
```

#parec[
  Projecting the curve control points into the ray coordinate system makes this test more efficient for two reasons. First, because the ray’s direction is oriented with the $+z$ axis, the problem is reduced to a 2D test in $x$ and $y$. Second, because the ray origin is at the origin of the coordinate system, the point we need to classify is $(0,0)$, which simplifies evaluating the edge function, just like the ray–triangle intersection test.
][
  将控制点变换到射线坐标系有两项好处：射线沿 $+z$ 轴，问题因而化为 $x$、$y$ 平面上的二维测试；射线起点又位于坐标原点，待分类点就是 $(0,0)$，与三角形求交时一样，边函数计算因此得到简化。
]

#parec[
  Edge functions were introduced for ray–triangle intersection tests in Equation (#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#eq:edge-function")[6.5]); see also Figure #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fig:tri-edge-function")[6.14]. To define the edge function here, we need any two points on the line perpendicular to the curve going through the starting point. The first control point, $p_0$, is a fine choice for the first. For the second, we will compute the vector perpendicular to the curve’s tangent and add that offset to the control point.
][
  式（6.5）在射线与三角形求交中引入了边函数，另参见图 6.14。这里需要找出通过曲线起点且垂直于曲线切线的直线上的任意两点。第一点可取首控制点 $p_0$；第二点则由 $p_0$ 加上垂直于曲线切线的向量得到。
]

#parec[
  Differentiation of (@eqt:bezier-basic) shows that the tangent to the curve at the first control point $p_0$ is $3(p_1-p_0)$. The scaling factor does not matter here, so we will use $bold(t)=p_1-p_0$ here. Computing the vector perpendicular to the tangent is easy in 2D: it is just necessary to swap the $x$ and $y$ coordinates and negate one of them. (To see why this works, consider the dot product $(x,y) dot.op (y,-x)=x y-y x=0$. Because the cosine of the angle between the two vectors is zero, they must be perpendicular.) Thus, the second point on the edge is
][
  对 @eqt:bezier-basic 求导可知，曲线在首控制点 $p_0$ 处的切向量为 $3(p_1-p_0)$。比例因子在这里无关紧要，因此使用 $bold(t)=p_1-p_0$。二维中只需交换 $x$、$y$ 分量并将其中一个取反，就得到垂直向量：因为 $(x,y) dot.op (y,-x)=x y-y x=0$，两向量夹角的余弦为零，所以相互垂直。因此边上的第二点为：
]

$ p_0+(p_(1,y)-p_(0,y),-(p_(1,x)-p_(0,x)))=p_0+(p_(1,y)-p_(0,y),p_(0,x)-p_(1,x)) . $

#parec[
  Substituting these two points into the definition of the edge function, Equation (#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#eq:edge-function")[6.5]), and simplifying gives
][
  将这两点代入式（6.5）的边函数定义并化简，得到：
]

$ e(p)=(p_(1,y)-p_(0,y))(p_y-p_(0,y))-(p_x-p_(0,x))(p_(0,x)-p_(1,x)) . $

#parec[
  Finally, substituting $p=(0,0)$ gives the final expression to test:
][
  最后代入 $p=(0,0)$，得到实际测试的表达式：
]

$ e((0,0))=(p_(1,y)-p_(0,y))(-p_(0,y))+p_(0,x)(p_(0,x)-p_(1,x)) . $

#block(sticky: true)[#raw("<<Test sample point against tangent perpendicular at curve start>>=")] <fragment-Testsamplepointagainsttangentperpendicularatcurvestart-0>
```cpp
Float edge = (cp[1].y - cp[0].y) * -cp[0].y +
             cp[0].x * (cp[0].x - cp[1].x);
if (edge < 0)
    return false;
```

#parec[
  The 〈Test sample point against tangent perpendicular at curve end〉 fragment, not included here, does the corresponding test at the end of the curve.
][
  未在正文列出的〈Test sample point against tangent perpendicular at curve end〉在曲线末端执行相应测试。
]

#parec[
  The next part of the test is to determine the $u$ value along the curve segment where the point $(0,0)$ is closest to the curve. This will be the intersection point, if it is no farther than the curve’s width away from the center at that point. Determining this distance for a cubic Bézier curve requires a significant amount of computation, so instead the implementation here approximates the curve with a linear segment to compute this $u$ value.
][
  接下来求曲线上距离 $(0,0)$ 最近的位置对应的 $u$。若该点距曲线中心不超过该处宽度，就将得到交点。直接求三次贝塞尔曲线上的最近距离需要大量计算，因此这里先用线段近似曲线，再求 $u$。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f36.svg"), caption:[#ez_caption[Approximation of a Cubic Bézier Curve with a Linear Segment. For this part of the ray–curve intersection test, we approximate the Bézier with a linear segment (dashed line) passing through its starting and ending points. (In practice, after being subdivided, the curve will be already nearly linear, so the error is less than this figure suggests.)][用线段近似三次贝塞尔曲线。在此步骤中，用经过曲线首尾端点的线段（虚线）近似贝塞尔曲线。实际细分后的曲线已经接近线性，误差因而小于图示。]]) <bezier-linear-approximate>

#parec[
  We linearly approximate the Bézier curve with a line segment from its starting point $p_0$ to its endpoint $p_3$ that is parameterized by $w$. In this case, the position is $p_0$ at $w=0$ and $p_3$ at $w=1$ (@fig:bezier-linear-approximate). Our task is to compute the value of $w$ along the line corresponding to the point on the line $p'$ that is closest to the point $p$. The key insight to apply is that at $p'$, the vector from the corresponding point on the line to $p$ will be perpendicular to the line (@fig:point-line-compute-w(a)).
][
  用从起点 $p_0$ 到终点 $p_3$ 的线段近似贝塞尔曲线，并用 $w$ 参数化：$w=0$ 对应 $p_0$，$w=1$ 对应 $p_3$（@fig:bezier-linear-approximate）。任务是求直线上距离点 $p$ 最近的点 $p'$ 对应的 $w$。关键在于从 $p'$ 指向 $p$ 的向量必与直线垂直（@fig:point-line-compute-w (a)）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f37.svg"), caption:[#ez_caption[(a) Given an infinite line and a point $p$, the vector from the point to the closest point on the line, $p'$, is then perpendicular to the line. (b) Because this vector is perpendicular, we can compute the distance from the first point of the line to the point of closest approach, $p'$, as $d=norm(p-p_0) cos theta$.][（a）给定无限直线和点 $p$，从该点到直线上最近点 $p'$ 的向量与直线垂直。（b）利用垂直关系，可以求得从直线上第一点到最近点 $p'$ 的距离 $d=norm(p-p_0) cos theta$。]]) <point-line-compute-w>

#parec[
  Equation (#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#eq:dot-cos")[3.1]) gives us a relationship between the dot product of two vectors, their lengths, and the cosine of the angle between them. In particular, it shows us how to compute the cosine of the angle between the vector from $p_0$ to $p$ and the vector from $p_0$ to $p_3$:
][
  式（3.1）给出了两向量的点积、长度与夹角余弦之间的关系。由此，从 $p_0$ 指向 $p$ 的向量与从 $p_0$ 指向 $p_3$ 的向量之间的夹角余弦为：
]

$ cos theta=frac((p-p_0) dot.op (p_3-p_0),norm(p-p_0) norm(p_3-p_0)) . $

#parec[
  Because the vector from $p'$ to $p$ is perpendicular to the line (@fig:point-line-compute-w(b)), we can compute the distance along the line from $p_0$ to $p'$ as
][
  由于从 $p'$ 指向 $p$ 的向量与直线垂直（@fig:point-line-compute-w (b)），从 $p_0$ 沿直线到 $p'$ 的距离为：
]

$ d=norm(p-p_0) cos theta=frac((p-p_0) dot.op (p_3-p_0),norm(p_3-p_0)) . $

#parec[
  Finally, the parametric offset $w$ along the line is the ratio of $d$ to the line’s length,
][
  最后，参数偏移 $w$ 是距离 $d$ 与线段长度之比：
]

$ w=frac(d,norm(p_3-p_0))=frac((p-p_0) dot.op (p_3-p_0),norm(p_3-p_0)^2) . $

#parec[
  The computation of the value of $w$ is in turn slightly simplified from the fact that $p=(0,0)$ in the intersection coordinate system.
][
  由于求交坐标系中 $p=(0,0)$，$w$ 的计算还可进一步简化。
]

#block(sticky: true)[#raw("<<Find line w that gives minimum distance to sample point>>=")] <fragment-Findlinewthatgivesminimumdistancetosamplepoint-0>
```cpp
Vector2f segmentDir = Point2f(cp[3].x, cp[3].y) - Point2f(cp[0].x, cp[0].y);
Float denom = LengthSquared(segmentDir);
if (denom == 0)
    return false;
Float w = Dot(-Vector2f(cp[0].x, cp[0].y), segmentDir) / denom;
```

#parec[
  The parametric $u$ coordinate of the (presumed) closest point on the Bézier curve to the candidate intersection point is computed by linearly interpolating along the $u$ range of the segment. Given this $u$ value, the width of the curve at that point can be computed.
][
  沿该段的 $u$ 范围线性插值，得到贝塞尔曲线上假定距离候选交点最近的位置对应的 $u$。据此即可计算该处曲线宽度。
]

#block(sticky: true)[#raw("<<Compute u coordinate of curve intersection point and hitWidth>>=")] <fragment-ComputeucoordinateofcurveintersectionpointandmonohitWidth-0>
```cpp
Float u = Clamp(Lerp(w, u0, u1), u0, u1);
Float hitWidth = Lerp(u, common->width[0], common->width[1]);
Normal3f nHit;
if (common->type == CurveType::Ribbon) {
    <<Scale hitWidth based on ribbon orientation>> 
}
```

#parec[
  For `Ribbon` curves, the curve is not always oriented to face the ray. Rather, its orientation is interpolated between two surface normals given at each endpoint. Here, spherical linear interpolation is used to interpolate the normal at $u$. The curve’s width is then scaled by the cosine of the angle between the normalized ray direction and the ribbon’s orientation so that it corresponds to the visible width of the curve from the given direction.
][
  `Ribbon` 曲线并不总朝向射线，而是在两端给定的表面法向量之间插值得到朝向。这里用球面线性插值求出 $u$ 处的法向量，再按归一化射线方向与带状曲线朝向夹角的余弦缩放宽度，使其对应于从这一方向看到的曲线宽度。
]

#block(sticky: true)[#raw("<<Scale hitWidth based on ribbon orientation>>=")] <fragment-ScalemonohitWidthbasedonribbonorientation-0>
```cpp
if (common->normalAngle == 0)
    nHit = common->n[0];
else {
    Float sin0 = std::sin((1 - u) * common->normalAngle) *
        common->invSinNormalAngle;
    Float sin1 = std::sin(u * common->normalAngle) *
        common->invSinNormalAngle;
    nHit = sin0 * common->n[0] + sin1 * common->n[1];
}
hitWidth *= AbsDot(nHit, ray.d) / rayLength;
```

#parec[
  To finally classify the potential intersection as a hit or miss, the Bézier curve must still be evaluated at $u$. (Because the control points `cp` represent the curve segment currently under consideration, it is important to use $w$ rather than $u$ in the function call, however, since $w$ is in the range $[0,1]$.) The derivative of the curve at this point will be useful shortly, so it is recorded now.
][
  最终判定是否命中时，仍需计算贝塞尔曲线上对应 $u$ 的位置。但 `cp` 表示当前子段，因此调用函数时必须使用范围为 $[0,1]$ 的局部参数 $w$，不能使用全曲线参数 $u$。这里也保存该点的曲线导数，供后续使用。
]

#parec[
  We would like to test whether the distance from $p$ to this point on the curve `pc` is less than half the curve’s width. Because $p=(0,0)$, we can equivalently test whether the distance from `pc` to the origin is less than half the width or whether the squared distance is less than one quarter the width squared. If this test passes, the last thing to check is if the intersection point is in the ray’s parametric $t$ range.
][
  需要测试 $p$ 到曲线上点 `pc` 的距离是否小于宽度的一半。因为 $p=(0,0)$，这等价于测试 `pc` 到原点的距离，或测试距离平方是否小于宽度平方的四分之一。通过之后，最后还要确认交点位于射线的 $t$ 参数范围内。
]

#block(sticky: true)[#raw("<<Test intersection point against curve width>>=")] <fragment-Testintersectionpointagainstcurvewidth-0>
```cpp
Vector3f dpcdw;
Point3f pc = EvaluateCubicBezier(pstd::span<const Point3f>(cp),
                                 Clamp(w, 0, 1), &dpcdw);
Float ptCurveDist2 = Sqr(pc.x) + Sqr(pc.y);
if (ptCurveDist2 > Sqr(hitWidth) * 0.25f)
    return false;
if (pc.z < 0 || pc.z > rayLength * tMax)
    return false;
```

#parec[
  For non-shadow rays, the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] for the intersection can finally be initialized. Doing so requires computing the ray $t$ value for the intersection as well as its #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`].
][
  对于非阴影射线，现在可以初始化交点的 `ShapeIntersection`。这需要求出射线参数 $t$ 和交点的 `SurfaceInteraction`。
]

#block(sticky: true)[#raw("<<Initialize ShapeIntersection for curve intersection>>=")] <fragment-InitializemonoShapeIntersectionforcurveintersection-0>
```cpp
<<Compute tHit for curve intersection>> 
<<Initialize SurfaceInteraction intr for curve intersection>> 
*si = ShapeIntersection{intr, tHit};
```

#parec[
  After the `tHit` value has been computed, it is compared against the `tHit` of a previously found ray–curve intersection, if there is one. This check ensures that the closest intersection is returned.
][
  求出 `tHit` 后，若此前已找到射线与曲线的交点，就将它与此前的 `tHit` 比较，以确保返回最近交点。
]

#block(sticky: true)[#raw("<<Compute tHit for curve intersection>>=")] <fragment-ComputemonotHitforcurveintersection-0>
```cpp
Float tHit = pc.z / rayLength;
if (si->has_value() && tHit > si->value().tHit)
    return false;
```

#parec[
  A variety of additional quantities need to be computed in order to be able to initialize the intersection’s `SurfaceInteraction`.
][
  要初始化交点的 `SurfaceInteraction`，还需计算若干量。
]

#block(sticky: true)[#raw("<<Initialize SurfaceInteraction intr for curve intersection>>=")] <fragment-InitializemonoSurfaceInteractionmonointrforcurveintersection-0>
```cpp
<<Compute v coordinate of curve intersection point>> 
<<Compute ∂p/∂u and ∂p/∂v for curve intersection>> 
<<Compute error bounds for curve intersection>> 
bool flipNormal = common->reverseOrientation ^
                  common->transformSwapsHandedness;
Point3fi pi(ray(tHit), pError);
SurfaceInteraction intr(pi, {u, v}, -ray.d, dpdu, dpdv, Normal3f(),
                        Normal3f(), ray.time, flipNormal);
intr = (*common->renderFromObject)(intr);
```

#parec[
  We have gotten this far without computing the $v$ coordinate of the intersection point, which is now needed. The curve’s $v$ coordinate ranges from 0 to 1, taking on the value $0.5$ at the center of the curve; here, we classify the intersection point, $(0,0)$, with respect to an edge function going through the point on the curve `pc` and a point along its derivative to determine which side of the center the intersection point is on and in turn how to compute $v$.
][
  此前尚未计算交点的 $v$ 坐标，现在需要补上。曲线的 $v$ 范围为 0 到 1，中心处为 $0.5$。用经过曲线上 `pc` 及沿其导数方向一点的边函数，对交点 $(0,0)$ 分类，即可确定它位于中心的哪一侧，进而计算 $v$。
]

#block(sticky: true)[#raw("<<Compute v coordinate of curve intersection point>>=")] <fragment-Computevcoordinateofcurveintersectionpoint-0>
```cpp
Float ptCurveDist = std::sqrt(ptCurveDist2);
Float edgeFunc = dpcdw.x * -pc.y + pc.x * dpcdw.y;
Float v = (edgeFunc > 0) ? 0.5f + ptCurveDist / hitWidth :
                           0.5f - ptCurveDist / hitWidth;
```

#parec[
  The partial derivative $frac(∂p,∂u)$ comes directly from the derivative of the underlying Bézier curve. The second partial derivative, $frac(∂p,∂v)$, is computed in different ways based on the type of the curve. For ribbons, we have $frac(∂p,∂u)$ and the surface normal, and so $frac(∂p,∂v)$ must be the vector such that $frac(∂p,∂u) times frac(∂p,∂v)=bold(n)$ and has length equal to the curve’s width.
][
  偏导数 $frac(∂p,∂u)$ 直接来自贝塞尔曲线导数；另一个偏导数 $frac(∂p,∂v)$ 按曲线类型计算。对于带状曲线，已知 $frac(∂p,∂u)$ 和表面法向量，因此 $frac(∂p,∂v)$ 应满足 $frac(∂p,∂u) times frac(∂p,∂v)=bold(n)$，长度等于曲线宽度。
]

#block(sticky: true)[#raw("<<Compute ∂p/∂u and ∂p/∂v for curve intersection>>=")] <fragment-Computedpduanddpdvforcurveintersection-0>
```cpp
Vector3f dpdu, dpdv;
EvaluateCubicBezier(pstd::MakeConstSpan(common->cpObj), u, &dpdu);
if (common->type == CurveType::Ribbon)
    dpdv = Normalize(Cross(nHit, dpdu)) * hitWidth;
else {
    <<Compute curve ∂p/∂v for flat and cylinder curves>> 
}
```

#parec[
  For flat and cylinder curves, we transform $frac(∂p,∂u)$ to the intersection coordinate system. For flat curves, we know that $frac(∂p,∂v)$ lies in the $x y$ plane, is perpendicular to $frac(∂p,∂u)$, and has length equal to `hitWidth`. We can find the 2D perpendicular vector using the same approach as was used earlier for the perpendicular curve segment boundary edges.
][
  对于平坦曲线和圆柱曲线，先将 $frac(∂p,∂u)$ 变换到求交坐标系。平坦曲线的 $frac(∂p,∂v)$ 位于 $x y$ 平面，垂直于 $frac(∂p,∂u)$，长度为 `hitWidth`。可以沿用先前求曲线段边界垂直向量的方法求出它。
]

#block(sticky: true)[#raw("<<Compute curve ∂p/∂v for flat and cylinder curves>>=")] <fragment-Computecurvedpdvforflatandcylindercurves-0>
```cpp
Vector3f dpduPlane = objectFromRay.ApplyInverse(dpdu);
Vector3f dpdvPlane = Normalize(Vector3f(-dpduPlane.y, dpduPlane.x, 0)) *
                     hitWidth;
if (common->type == CurveType::Cylinder) {
    <<Rotate dpdvPlane to give cylindrical appearance>> 
}
dpdv = objectFromRay(dpdvPlane);
```

#parec[
  The $frac(∂p,∂v)$ vector for cylinder curves is rotated around the `dpduPlane` axis so that its appearance resembles a cylindrical cross-section.
][
  圆柱曲线的 $frac(∂p,∂v)$ 绕 `dpduPlane` 轴旋转，使外观看起来具有圆柱截面。
]

#block(sticky: true)[#raw("<<Rotate dpdvPlane to give cylindrical appearance>>=")] <fragment-RotatemonodpdvPlanetogivecylindricalappearance-0>
```cpp
Float theta = Lerp(v, -90, 90);
Transform rot = Rotate(-theta, dpduPlane);
dpdvPlane = rot(dpdvPlane);
```

#translator([原文最近点说明先写“不超过曲线宽度”，后文明确采用半宽，代码测试距离平方不超过宽度平方的四分之一。这里保留两处原文，不将前一句误读为最终判交阈值。], en: [The source first describes a distance no greater than the curve width; later it explicitly uses half the width, and the code compares squared distance with one quarter of the squared width. Both source statements are retained; the earlier wording does not state the final acceptance threshold.])
#translator([原文把带状曲线两偏导数的叉积写成等于法向量。代码以归一化叉积乘 `hitWidth` 构造 `dpdv`；一般只能据此确定叉积方向，不能保证其长度为 1。另，正文称按夹角余弦缩放宽度，实际 `AbsDot` 使用余弦的绝对值。原句和代码均保留，未猜改算法。], en: [The source equates the cross product of the ribbon’s two position derivatives to the normal. The code constructs `dpdv` by scaling a normalized cross product by `hitWidth`, which generally fixes the cross product’s direction rather than making its length one. The prose also says cosine when the width scaling uses its absolute value through `AbsDot`. The original statements and code are retained.])
#include "supplements/6.7-expanded.typ"
