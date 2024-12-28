#import "../template.typ": parec

== Curves
<curves>
#parec[
  While triangles or bilinear patches can be used to represent thin shapes for modeling fine geometry like hair, fur, or fields of grass, it is worthwhile to have a specialized `Shape` in order to more efficiently render these sorts of objects, since many individual instances of them are often present.
][
  虽然三角形或双线性补丁可以用来表示细长的形状，以建模如头发、毛皮或草地等精细几何体，但为了更高效地渲染这些对象，使用专门的 `Shape` 是值得的，因为它们通常有许多单独的实例。
]

#parec[
  The #link("<Curve>")[`Curve`] shape, introduced in this section, represents thin geometry modeled with cubic Bézier curves, which are defined by four control points, $p_0$, $p_1$, $p_2$, and $p_3$. The Bézier spline passes through the first and last control points. Points along it are given by the polynomial

  $ p_B (u) = (1 - u)^3 p_0 + 3 (1 - u)^2 u p_1 + 3 (1 - u) u^2 p_2 + u^3 p_3 . $ 

  (See Figure 6.29.) Curves specified using another basis (e.g., Hermite splines or b-splines) must therefore be converted to the Bézier basis to be used with this `Shape`.
][
  本节介绍的 #link("<Curve>")[`Curve`] 形状，表示用三次贝塞尔样条曲线建模的细长几何体，该曲线由四个控制点 $p_0$ 、 $p_1$ 、 $p_2$ 和 $p_3$ 定义。贝塞尔样条通过第一个和最后一个控制点。曲线上各点由多项式表示

  $ p_B (u) = (1 - u)^3 p_0 + 3 (1 - u)^2 u p_1 + 3 (1 - u) u^2 p_2 + u^3 p_3 . $ 

  （见图 6.29。）使用其他基底（例如，Hermite 样条或 b 样条）指定的曲线必须转换为贝塞尔基底以用于此 `Shape`。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f29.svg"),
    caption: [
      Figure 6.29: A cubic Bézier curve is defined by four control points,
      $p_i$. The curve $p_B (u)$, defined in Equation (6.16), passes
      through the first and last control points at $u = 0$ and $u = 1$,
      respectively.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f29.svg"),
    caption: [
      图 6.29: 三次贝塞尔曲线由四个控制点 $p_i$ 定义。曲线
      $p_B (u)$，在方程 (6.16) 中定义，通过 $u = 0$ 和 $u = 1$
      处的第一个和最后一个控制点。
    ],
  )
]


=== Bounding Curves
<bounding-curves>
#parec[
  The object-space bound of a curve can be found by first bounding the spline along the center of the curve and then expanding that bound by half the maximum width the curve takes on over its extent. The `Bounds()` method then transforms that bound to rendering space before returning it.
][
  曲线的物体空间边界可以通过首先在曲线中心沿样条曲线进行边界，然后将该边界扩展为曲线在其范围内最大宽度的一半来找到。`Bounds()` 方法然后将该边界转换为渲染空间并返回。
]

#parec[
  ```cpp
  Bounds3f Curve::Bounds() const {
      pstd::span<const Point3f> cpSpan(common->cpObj);
      Bounds3f objBounds = BoundCubicBezier(cpSpan, uMin, uMax);
      // Expand objBounds by maximum curve width over u range
      Float width[2] = {Lerp(uMin, common->width[0], common->width[1]),
                        Lerp(uMax, common->width[0], common->width[1])};
      objBounds = Expand(objBounds, std::max(width[0], width[1]) * 0.5f);
      return (*common->renderFromObject)(objBounds);
  }
  ```
][
  ```cpp
  Bounds3f Curve::Bounds() const {
      pstd::span<const Point3f> cpSpan(common->cpObj);
      Bounds3f objBounds = BoundCubicBezier(cpSpan, uMin, uMax);
      // 在 u 范围内通过最大曲线宽度的一半扩展 objBounds
      Float width[2] = {Lerp(uMin, common->width[0], common->width[1]),
                        Lerp(uMax, common->width[0], common->width[1])};
      objBounds = Expand(objBounds, std::max(width[0], width[1]) * 0.5f);
      return (*common->renderFromObject)(objBounds);
  }
  ```
]

#parec[
  Expand `objBounds` by maximum curve width over $u$ range:
][
  在 $u$ 范围内通过最大曲线宽度的一半扩展 `objBounds`：
]

#parec[
  ```cpp
  Float width[2] = {Lerp(uMin, common->width[0], common->width[1]),
                    Lerp(uMax, common->width[0], common->width[1])};
  objBounds = Expand(objBounds, std::max(width[0], width[1]) * 0.5f);
  ```
][
  ```cpp
  Float width[2] = {Lerp(uMin, common->width[0], common->width[1]),
                    Lerp(uMax, common->width[0], common->width[1])};
  objBounds = Expand(objBounds, std::max(width[0], width[1]) * 0.5f);
  ```
]

#parec[
  The `Curve` shape cannot be used as an area light, as it does not provide implementations of the required sampling methods. It does provide a `NormalBounds()` method that returns a conservative bound.
][
  `Curve` 形状不能用作面积光，因为它没有提供所需采样方法的实现。它确实提供了一个 `NormalBounds()` 方法，该方法返回一个保守的边界。
]

#parec[
  ```cpp
  DirectionCone NormalBounds() const { return DirectionCone::EntireSphere(); }
  ```
][
  ```cpp
  DirectionCone NormalBounds() const { return DirectionCone::EntireSphere(); }
  ```
]

=== Intersection Tests
<intersection-tests>
#parec[
  Both of the intersection methods required by the `Shape` interface are implemented via another `Curve` method, `IntersectRay()`. Rather than returning an optional #link("../Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`];, it takes a pointer to one.
][
  `Shape` 接口所需的两个相交方法都是通过另一个 `Curve` 方法 `IntersectRay()` 实现的。它不是返回一个可选的 #link("../Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`];，而是接受一个指向它的指针。
]

#parec[
  ```cpp
  pstd::optional<ShapeIntersection>
  Curve::Intersect(const Ray &ray, Float tMax) const {
      pstd::optional<ShapeIntersection> si;
      IntersectRay(ray, tMax, &si);
      return si;
  }
  ```
][
  ```cpp
  pstd::optional<ShapeIntersection>
  Curve::Intersect(const Ray &ray, Float tMax) const {
      pstd::optional<ShapeIntersection> si;
      IntersectRay(ray, tMax, &si);
      return si;
  }
  ```
]

#parec[
  `IntersectP()` passes `nullptr` to `IntersectRay()`, which indicates that it can return immediately if an intersection is found.
][
  `IntersectP()` 将 `nullptr` 传递给 `IntersectRay()`，这表明如果找到交点，它可以立即返回。
]

#parec[
  ```cpp
  bool Curve::IntersectP(const Ray &ray, Float tMax) const {
      return IntersectRay(ray, tMax, nullptr);
  }
  ```
][
  ```cpp
  bool Curve::IntersectP(const Ray &ray, Float tMax) const {
      return IntersectRay(ray, tMax, nullptr);
  }
  ```
]

#parec[
  The `Curve` intersection algorithm is based on discarding curve segments as soon as it can be determined that the ray definitely does not intersect them and otherwise recursively splitting the curve in half to create two smaller segments that are then tested. Eventually, the curve is linearly approximated for an efficient intersection test. That process starts after some initial preparation and early culling tests in `IntersectRay()`.
][
  `Curve` 相交算法基于一旦可以确定光线肯定不与它们相交就舍弃曲线段，否则递归地将曲线分成两半以创建两个较小的段，然后进行测试。最终，曲线被线性逼近以进行高效的相交测试。该过程在 `IntersectRay()` 中的一些初步准备和早期裁剪测试之后开始。
]

```cpp
bool Curve::IntersectRay(const Ray &r, Float tMax, pstd::optional<ShapeIntersection> *si) const {
    // Transform Ray to curve’s object space
    Ray ray = (*common->objectFromRender)(r);
    // Get object-space control points for curve segment, cpObj
    pstd::array<Point3f, 4> cpObj =
        CubicBezierControlPoints(pstd::span<const Point3f>(common->cpObj), uMin, uMax);
    // Project curve control points to plane perpendicular to ray
    Vector3f dx = Cross(ray.d, cpObj[3] - cpObj[0]);
    if (LengthSquared(dx) == 0) {
        Vector3f dy;
        CoordinateSystem(ray.d, &dx, &dy);
    }
    Transform rayFromObject = LookAt(ray.o, ray.o + ray.d, dx);
    pstd::array<Point3f, 4> cp = {
        rayFromObject(cpObj[0]), rayFromObject(cpObj[1]),
        rayFromObject(cpObj[2]), rayFromObject(cpObj[3]) };

    // Test ray against bound of projected control points
    Float maxWidth = std::max(Lerp(uMin, common->width[0], common->width[1]),
                               Lerp(uMax, common->width[0], common->width[1]));
    Bounds3f curveBounds = Union(Bounds3f(cp[0], cp[1]), Bounds3f(cp[2], cp[3]));
    curveBounds = Expand(curveBounds, 0.5f * maxWidth);
    Bounds3f rayBounds(Point3f(0, 0, 0), Point3f(0, 0, Length(ray.d) * tMax));
    if (!Overlaps(rayBounds, curveBounds))
        return false;

    // Compute refinement depth for curve, maxDepth
    Float L0 = 0;
    for (int i = 0; i < 2; ++i)
        L0 = std::max(
            L0, std::max(std::max(std::abs(cp[i].x - 2 * cp[i + 1].x + cp[i + 2].x),
                                  std::abs(cp[i].y - 2 * cp[i + 1].y + cp[i + 2].y)),
                         std::abs(cp[i].z - 2 * cp[i + 1].z + cp[i + 2].z)));

    int maxDepth = 0;
    if (L0 > 0) {
        Float eps = std::max(common->width[0], common->width[1]) * .05f;  // width / 20
        // Compute log base 4 by dividing log2 in half.
        int r0 = Log2Int(1.41421356237f * 6.f * L0 / (8.f * eps)) / 2;
        maxDepth = Clamp(r0, 0, 10);
    }

    // Recursively test for ray—curve intersection
    pstd::span<const Point3f> cpSpan(cp);
    return RecursiveIntersect(ray, tMax, cpSpan, Inverse(rayFromObject),
                             uMin, uMax, maxDepth, si);
}
```


#parec[
  Transform `Ray` to curve's object space:
][
  将 `Ray` 转换到曲线的物体空间：
]

#parec[
  ```cpp
  Ray ray = (*common->objectFromRender)(r);
  ```
][
  ```cpp
  Ray ray = (*common->objectFromRender)(r);
  ```
]

#parec[
  The #link("<CurveCommon>")[`CurveCommon`] class stores the control points for the full curve, but a #link("<Curve>")[`Curve`] instance generally needs the four control points that represent the Bézier curve for its $u$ extent. The #link("../Utilities/Mathematical_Infrastructure.html#CubicBezierControlPoints")[`CubicBezierControlPoints()`] utility function performs this computation.
][
  #link("<CurveCommon>")[`CurveCommon`] 类存储了完整曲线的控制点，但 #link("<Curve>")[`Curve`] 实例通常需要表示其 $u$ 范围的 Bézier 曲线的四个控制点。#link("../Utilities/Mathematical_Infrastructure.html#CubicBezierControlPoints")[`CubicBezierControlPoints()`] 实用函数执行此计算。
]

#parec[
  Get object-space control points for curve segment, `cpObj`:
][
  获取曲线段的对象空间控制点坐标，`cpObj`：
]

#parec[
  ```cpp
  pstd::array<Point3f, 4> cpObj =
      CubicBezierControlPoints(pstd::span<const Point3f>(common->cpObj), uMin, uMax);
  ```
][
  ```cpp
  pstd::array<Point3f, 4> cpObj =
      CubicBezierControlPoints(pstd::span<const Point3f>(common->cpObj), uMin, uMax);
  ```
]

#parec[
  Like the ray—triangle intersection algorithm from Section #link("../Shapes/Triangle_Meshes.html#sec:ray-triangle")[6.5.3];, the ray—curve intersection test is based on transforming the curve to a coordinate system with the ray's origin at the origin of the coordinate system and the ray's direction aligned to be along the $+$ z axis. Performing this transformation at the start greatly reduces the number of operations that must be performed for intersection tests.
][
  像第 #link("../Shapes/Triangle_Meshes.html#sec:ray-triangle")[6.5.3] 节中的光线—三角形相交算法一样，光线—曲线相交测试基于将曲线转换为具有光线原点在坐标系原点且光线方向对齐为 $+$ z 轴的坐标系。执行此转换在开始时大大减少了相交测试所需执行的操作数量。
]

#parec[
  For the `Curve` shape, we will need an explicit representation of the transformation, so the `LookAt()` function is used to generate it here. The origin is the ray's origin and the "look at" point is a point offset from the origin along the ray's direction. The "up" direction is set to be perpendicular to both the ray's direction and the vector from the first to the last control point. Doing so helps orient the curve to be roughly parallel to the $x$ axis in the ray coordinate system, which in turn leads to tighter bounds in $y$ (see Figure #link("<fig:bezier-2d-bboxes>")[6.33];). This improvement in the fit of the bounds often makes it possible to terminate the recursive intersection tests earlier than would be possible otherwise.
][
  对于 `Curve` 形状，我们将需要变换的显式表示，因此这里使用 `LookAt()` 函数生成它。原点是光线的原点，"观察点"是沿光线方向从原点偏移的点。"上"方向设置为同时垂直于光线方向和从第一个控制点到最后一个控制点的向量。这样有助于将曲线定向为在光线坐标系中大致平行于 $x$ 轴，这反过来又导致 $y$ 中的边界更紧密（见图 #link("<fig:bezier-2d-bboxes>")[6.33];）。这种边界拟合的改进通常使得可以比否则更早地终止递归相交测试。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f33.svg"),
    caption: [
      Figure 6.33: 2D Bounding Boxes of a Bézier Curve. (a) Bounding box
      computed using the curve's control points as given. (b) The effect
      of rotating the curve so that the vector from its first to last
      control point is aligned with the $x$ axis before computing bounds.
      The resulting bounding box is a much tighter fit.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f33.svg"),
    caption: [
      图 6.33: Bézier 曲线的二维边界框。(a)
      使用给定的曲线控制点计算的边界框。(b)
      在计算边界之前旋转曲线，使其从第一个控制点到最后一个控制点的向量与
      $x$ 轴对齐的效果。结果边界框更紧密。
    ],
  )
]

#parec[
  If the ray and the vector between the first and last control points are parallel, `dx` will be degenerate. In that case we find an arbitrary "up" vector direction so that intersection tests can proceed in this unusual case.
][
  如果光线和第一个控制点与最后一个控制点之间的向量平行，则 `dx` 将退化。在这种情况下，我们找到一个任意的“上”向量方向，以便在这种不寻常的情况下可以继续进行相交测试。
]

#parec[
  Project curve control points to plane perpendicular to ray:
][
  将曲线控制点投影到垂直于光线的平面上：
]

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
  Along the lines of the implementation in #link("<Curve::Bounds>")[`Curve::Bounds`];, a conservative bounding box for a curve segment can be found by taking the bounds of the curve's control points and expanding by half of the maximum width of the curve over the $u$ range being considered.
][
  沿着 #link("<Curve::Bounds>")[`Curve::Bounds`] 中的实现思路，可以通过获取曲线控制点的边界并通过曲线在考虑的 $u$ 范围内最大宽度的一半进行扩展来找到曲线段的保守边界框。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f34.svg"),
    caption: [
      Figure 6.34: Ray—Curve Bounds Test. In the ray coordinate system,
      the ray's origin is at $(0 , 0 , 0)$ and its direction is aligned
      with the $+$z axis. Therefore, if the 2D point $(x , y) = (0 , 0)$
      is outside the $x y$ bounding box of the curve segment, then it is
      impossible that the ray intersects the curve.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f34.svg"),
    caption: [
      图 6.34: 光线—曲线边界测试。在光线坐标系中，光线的原点位于
      $(0 , 0 , 0)$，其方向与 $+$z 轴对齐。因此，如果二维点
      $(x , y) = (0 , 0)$ 在曲线段的 $x y$
      边界框之外，则不可能光线与曲线相交。
    ],
  )
]

#parec[
  Because the ray's origin is at $(0 , 0 , 0)$ and its direction is aligned with the $+$ z axis in the intersection space, its bounding box only includes the origin in $x$ and $y$ (Figure #link("<fig:curve-bounds-check>")[6.34];); its $z$ extent is given by the $z$ range that its parametric extent covers. Before proceeding with the recursive intersection testing algorithm, the ray's bounding box is tested for intersection with the curve's bounding box. The method can return immediately if they do not intersect.
][
  由于光线的原点位于 $(0 , 0 , 0)$，其方向在相交空间中与 $+$ z 轴对齐，其边界框仅在 $x$ 和 $y$ 中包含原点（图 #link("<fig:curve-bounds-check>")[6.34];）；其 $z$ 范围由其参数范围覆盖的 $z$ 范围给出。在继续递归相交测试算法之前，光线的边界框被测试与曲线的边界框的相交。如果它们不相交，该方法可以立即返回。
]

#parec[
  Test ray against bound of projected control points:
][
  测试光线与投影控制点的边界：
]

#parec[
  ```cpp
  Float maxWidth = std::max(Lerp(uMin, common->width[0], common->width[1]),
                            Lerp(uMax, common->width[0], common->width[1]));
  Bounds3f curveBounds = Union(Bounds3f(cp[0], cp[1]), Bounds3f(cp[2], cp[3]));
  curveBounds = Expand(curveBounds, 0.5f * maxWidth);
  Bounds3f rayBounds(Point3f(0, 0, 0), Point3f(0, 0, Length(ray.d) * tMax));
  if (!Overlaps(rayBounds, curveBounds))
      return false;
  ```
][
  ```cpp
  Float maxWidth = std::max(Lerp(uMin, common->width[0], common->width[1]),
                            Lerp(uMax, common->width[0], common->width[1]));
  Bounds3f curveBounds = Union(Bounds3f(cp[0], cp[1]), Bounds3f(cp[2], cp[3]));
  curveBounds = Expand(curveBounds, 0.5f * maxWidth);
  Bounds3f rayBounds(Point3f(0, 0, 0), Point3f(0, 0, Length(ray.d) * tMax));
  if (!Overlaps(rayBounds, curveBounds))
      return false;
  ```
]

#parec[
  The maximum number of times to subdivide the curve is computed so that the maximum distance from the eventual linearized curve at the finest refinement level is bounded to be less than a small fixed distance. We will not go into the details of this computation, which is implemented in the fragment `Compute refinement depth for curve, maxDepth`. With the culling tests passed and that value in hand, the recursive intersection tests begin.
][
  最大细分曲线次数的计算是为了使最终线性化曲线在最精细细化级别的最大距离被限制在小的固定距离以下。我们不会详细介绍此计算，该计算在片段 `计算曲线的细化深度，最大深度 maxDepth` 中实现。通过裁剪测试并且得到该值后，递归相交测试开始。
]

#parec[
  Recursively test for ray—curve intersection:
][
  递归测试光线与曲线的相交：
]

#parec[
  ```cpp
  pstd::span<const Point3f> cpSpan(cp);
  return RecursiveIntersect(ray, tMax, cpSpan, Inverse(rayFromObject),
                            uMin, uMax, maxDepth, si);
  ```
][
  ```cpp
  pstd::span<const Point3f> cpSpan(cp);
  return RecursiveIntersect(ray, tMax, cpSpan, Inverse(rayFromObject),
                            uMin, uMax, maxDepth, si);
  ```
]

#parec[
  The `RecursiveIntersect()` method then tests whether the given ray intersects the given curve segment over the given parametric range $[u_0 , u_1]$. It assumes that the ray has already been tested against the curve's bounding box and found to intersect it.
][
  `RecursiveIntersect()` 方法然后测试给定光线是否与给定曲线段在给定参数范围 $[u_0 , u_1]$ 上相交。它假设光线已经与曲线的边界框测试并发现相交。
]

```cpp
bool Curve::RecursiveIntersect(
        const Ray &ray, Float tMax, pstd::span<const Point3f> cp,
        const Transform &objectFromRay, Float u0, Float u1,
        int depth, pstd::optional<ShapeIntersection> *si) const {
    Float rayLength = Length(ray.d);
    if (depth > 0) {
        // Split curve segment into subsegments and test for intersection
        pstd::array<Point3f, 7> cpSplit = SubdivideCubicBezier(cp);
        Float u[3] = {u0, (u0 + u1) / 2, u1};
        for (int seg = 0; seg < 2; ++seg) {
            // Check ray against curve segment’s bounding box
            Float maxWidth =
                std::max(Lerp(u[seg], common->width[0], common->width[1]),
                         Lerp(u[seg + 1], common->width[0], common->width[1]));
            pstd::span<const Point3f> cps = pstd::MakeConstSpan(&cpSplit[3 * seg], 4);
            Bounds3f curveBounds = Union(Bounds3f(cps[0], cps[1]), Bounds3f(cps[2], cps[3]));
            curveBounds = Expand(curveBounds, 0.5f * maxWidth);
            Bounds3f rayBounds(Point3f(0, 0, 0), Point3f(0, 0, Length(ray.d) * tMax));
            if (!Overlaps(rayBounds, curveBounds))
                continue;

            // Recursively test ray-segment intersection
            bool hit = RecursiveIntersect(ray, tMax, cps, objectFromRay, u[seg],
                                           u[seg + 1], depth - 1, si);
            if (hit && !si)
                return true;
        }
        return si ? si->has_value() : false;
    } else {
        // Intersect ray with curve segment
        // Test ray against segment endpoint boundaries
        // Test sample point against tangent perpendicular at curve start
        Float edge = (cp[1].y - cp[0].y) * -cp[0].y +
                      cp[0].x * (cp[0].x - cp[1].x);
        if (edge < 0)
            return false;

        // Test sample point against tangent perpendicular at curve end
        edge = (cp[2].y - cp[3].y) * -cp[3].y +
               cp[3].x * (cp[3].x - cp[2].x);
        if (edge < 0)
            return false;

        // Find line w that gives minimum distance to sample point
        Vector2f segmentDir = Point2f(cp[3].x, cp[3].y) - Point2f(cp[0].x, cp[0].y);
        Float denom = LengthSquared(segmentDir);
        if (denom == 0)
            return false;
        Float w = Dot(-Vector2f(cp[0].x, cp[0].y), segmentDir) / denom;

        // Compute u coordinate of curve intersection point and hitWidth
        Float u = Clamp(Lerp(w, u0, u1), u0, u1);
        Float hitWidth = Lerp(u, common->width[0], common->width[1]);
        Normal3f nHit;
        if (common->type == CurveType::Ribbon) {
            // Scale hitWidth based on ribbon orientation
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
        }

        // Test intersection point against curve width
        Vector3f dpcdw;
        Point3f pc = EvaluateCubicBezier(pstd::span<const Point3f>(cp),
                                          Clamp(w, 0, 1), &dpcdw);
        Float ptCurveDist2 = Sqr(pc.x) + Sqr(pc.y);
        if (ptCurveDist2 > Sqr(hitWidth) * 0.25f)
            return false;
        if (pc.z < 0 || pc.z > rayLength * tMax)
            return false;

        if (si) {
            // Initialize ShapeIntersection for curve intersection
            // Compute tHit for curve intersection
            Float tHit = pc.z / rayLength;
            if (si->has_value() && tHit > si->value().tHit)
                return false;

            // Initialize SurfaceInteraction intr for curve intersection
            // Compute v coordinate of curve intersection point
            Float ptCurveDist = std::sqrt(ptCurveDist2);
            Float edgeFunc = dpcdw.x * -pc.y + pc.x * dpcdw.y;
            Float v = (edgeFunc > 0) ? 0.5f + ptCurveDist / hitWidth :
                                        0.5f - ptCurveDist / hitWidth;

            // Compute partial-differential normal p slash partial-differential u and
            // partial-differential normal p slash partial-differential v for curve intersection
            Vector3f dpdu, dpdv;
            EvaluateCubicBezier(pstd::MakeConstSpan(common->cpObj), u, &dpdu);
            if (common->type == CurveType::Ribbon)
                dpdv = Normalize(Cross(nHit, dpdu)) * hitWidth;
            else {
                // Compute curve partial-differential normal p slash partial-differential v for flat and
                // cylinder curves
                Vector3f dpduPlane = objectFromRay.ApplyInverse(dpdu);
                Vector3f dpdvPlane = Normalize(Vector3f(-dpduPlane.y, dpduPlane.x, 0)) *
                                      hitWidth;
                if (common->type == CurveType::Cylinder) {
                    // Rotate dpdvPlane to give cylindrical appearance
                    Float theta = Lerp(v, -90, 90);
                    Transform rot = Rotate(-theta, dpduPlane);
                    dpdvPlane = rot(dpdvPlane);
                }
                dpdv = objectFromRay(dpdvPlane);
            }

            // Compute error bounds for curve intersection
            Vector3f pError(hitWidth, hitWidth, hitWidth);
            bool flipNormal = common->reverseOrientation ^
                              common->transformSwapsHandedness;
            Point3fi pi(ray(tHit), pError);
            SurfaceInteraction intr(pi, {u, v}, -ray.d, dpdu, dpdv, Normal3f(),
                                    Normal3f(), ray.time, flipNormal);
            intr = (*common->renderFromObject)(intr);
            *si = ShapeIntersection{intr, tHit};
        }
        return true;
    }
}
```




#parec[
  $ p_0 + (p_1^y - p_0^y , - (p_1^x - p_0^x)) = p_0 + (p_1^y - p_0^y , p_0^x - p_1^x) . $ 将这两个点代入边函数的定义（方程~(6.5)），并简化得到
][
  $ e (p) = (p_1^y - p_0^y) (p_y - p_0^y) - (p_x - p_0^x) (p_0^x - p_1^x) . $ 最后，代入 $p = (0 , 0)$ 得到最终的测试表达式：
]

#parec[
  $ e ((0 , 0)) = (p_1^y - p_0^y) (- p_0^y) + p_0^x (p_0^x - p_1^x) . $
][
  \<\> =~

  ```cpp
  Float edge = (cp[1].y - cp[0].y) * -cp[0].y +
               cp[0].x * (cp[0].x - cp[1].x);
  if (edge < 0)
      return false;
  ```

  \<\>片段，此处未包含，执行相应的测试在曲线的末端。
]

#parec[
  The next part of the test is to determine the $u$ value along the curve segment where the point $(0 , 0)$ is closest to the curve. This will be the intersection point, if it is no farther than the curve's width away from the center at that point. Determining this distance for a cubic Bézier curve requires a significant amount of computation, so instead the implementation here approximates the curve with a linear segment to compute this $u$ value.
][
  我们用一条从起始点 $p_0$ 到终点 $p_3$ 的线段线性近似贝塞尔曲线，该线段由 $w$ 参数化。在这种情况下，当 $w = 0$ 时，位置为 $p_0$ ；当 $w = 1$ 时，位置为 $p_3$ （图~6.36）。我们的任务是计算沿线的 $w$ 值，对应于线上的点 $p prime$，该点最接近点 $p$。关键在于，在 $p prime$ 处，从线上的对应点到 $p$ 的向量将垂直于该线（图~6.37(a)）。
]

#parec[
  $ cos theta = frac((p - p_0) dot.op (p_3 - p_0), lr(||) p - p_0 lr(||) thin lr(||) p_3 - p_0 lr(||)) . $
][
  因为从 $p prime$ 到 $p$ 的向量垂直于该线（图~6.37(b)），我们可以计算沿线从 $p_0$ 到 $p prime$ 的距离为
]


#parec[
  $ w = frac(d, parallel p_3 - p_0 parallel) = frac((p_B - p_0) dot.op (p_3 - p_0), parallel p_3 - p_0 parallel^2) . $
][
  $ w = frac(d, parallel p_3 - p_0 parallel) = frac((p_B - p_0) dot.op (p_3 - p_0), parallel p_3 - p_0 parallel^2) . $ 

  由于在交叉坐标系中 $p_B = (0 , 0)$，因此 $w$ 的计算稍微简化了一些。
]

#parec[
  #strong[Find line $w$ that gives minimum distance to sample point];:
][
  #strong[寻找使样本点到线段距离最小的线 $w$];：
]

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
  假定贝塞尔曲线到候选交点的最近点的参数 $u$ 坐标是通过线性插值线段的 $u$ 范围得到的。给定这个 $u$ 值，可以计算该点处曲线的宽度。
]

#parec[
  #strong[Compute $u$ coordinate of curve intersection point and
`hitWidth`];:
][
  #strong[计算曲线交点的 $u$ 坐标和 `hitWidth`];：
]

\`\`\`cpp Float u = Clamp(Lerp(w, u0, u1), u0, u1); Float hitWidth =
Lerp(u, common-\>width\[0\], common-\>width\[1\]); Normal3f nHit; if
(common-\>type == CurveType::Ribbon) { \/\/ Scale hitWidth based on
ribbon orientation if (common-\>normalAngle == 0) nHit =
common-\>n\[0\]; else { Float sin0 = std::sin((1 - u) \*
common-\>normalAngle) #emph[ common-\>invSinNormalAngle; Float sin1 =
std::sin(u ] common-\>normalAngle) #emph[ common-\>invSinNormalAngle;
nHit = sin0 ] common-\>n\[0\] + sin1 \* common-\>n\[1\]; } hitWidth \*=
AbsDot(nHit, ray.d) / rayLength; }


