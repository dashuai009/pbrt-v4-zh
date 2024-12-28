#import "../template.typ": parec, ez_caption



== Basic Shape Interface
<basic-shape-interface>
#parec[
  The interface for `Shape`s is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/shape.h")[base/shape.h];, and the shape implementations can be found in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[shapes.h] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[shapes.cpp];. The `Shape` class defines the general shape interface.
][
  `Shape`的接口定义在文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/shape.h")[base/shape.h];中，形状的实现可以在#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[shapes.h];和#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[shapes.cpp];中找到。`Shape`类定义了一般的形状接口。
]

```cpp
class Shape : public TaggedPointer<Sphere, Cylinder, Disk, Triangle,
                                   BilinearPatch, Curve> {
public:
  using TaggedPointer::TaggedPointer;

      static pstd::vector<Shape> Create(const std::string &name,
                                              const Transform *renderFromObject,
                                              const Transform *objectFromRender,
                                              bool reverseOrientation,
                                              const ParameterDictionary &parameters,
                                              const std::map<std::string, FloatTexture> &floatTextures,
                                              const FileLoc *loc, Allocator alloc);
      std::string ToString() const;
      Bounds3f Bounds() const;
      DirectionCone NormalBounds() const;
      pstd::optional<ShapeIntersection> Intersect(const Ray &ray,
                                                  Float tMax = Infinity) const;
      bool IntersectP(const Ray &ray, Float tMax = Infinity) const;
      Float Area() const;
      pstd::optional<ShapeSample> Sample(Point2f u) const;
      Float PDF(const Interaction &) const;
      pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx,
                                        Point2f u) const;
      Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const;
};
```

=== Bounding
<bounding>

#parec[
  The scenes that `pbrt` renders often contain objects that are computationally expensive to process. For many operations, it is useful to have a 3D #emph[bounding volume] that encloses an object. For example, if a ray does not pass through a particular bounding volume, `pbrt` can avoid processing all the objects inside of it for that ray.
][
  `pbrt`渲染的场景中一些对象的计算成本通常比较高。对于许多操作来说，一个可以囊括对象的三维#emph[包围体积];是有用的。例如，如果一条光线没有穿过特定的包围体积，`pbrt`可以避免处理包围体积内的所有对象。
]

#parec[
  Axis-aligned bounding boxes are a convenient bounding volume, as they require only six floating-point values to store. They fit many shapes well and it is fairly inexpensive to test for the intersection of a ray with an axis-aligned bounding box. Each `Shape` implementation must therefore be capable of bounding itself with an axis-aligned bounding box represented by a #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`];. The returned bounding box should be in the rendering coordinate system (recall the discussion of coordinate systems in @camera-coordinate-spaces).
][
  轴对齐的包围盒（AABB）是一种方便的包围体积，因为它们只需要六个浮点值来存储。它们适合许多形状，并且测试光线与轴对齐包围盒的相交消耗较低。因此，每个`Shape`的实现必须能够用一个由#link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`];表示的轴对齐包围盒来包围自身。返回的包围盒应在渲染坐标系中（回忆在@camera-coordinate-spaces 中的坐标系讨论）。
]

```cpp
// <<Shape Interface>>=
Bounds3f Bounds() const;
```


#parec[
  In addition to bounding their spatial extent, shapes must also be able to bound their range of surface normals. The `NormalBounds()` method should return such a bound using a #link("../Geometry_and_Transformations/Spherical_Geometry.html#DirectionCone")[`DirectionCone`];, which was defined in @bounding-directions . Normal bounds are specifically useful in lighting calculations: when a shape is emissive, they sometimes make it possible to efficiently determine that the shape does not illuminate a particular point in the scene.
][
  除了限制其空间范围外，几何形状还必须能够限制其表面法线的范围。在@bounding-directions 中定义的#link("../Geometry_and_Transformations/Spherical_Geometry.html#DirectionCone")[`DirectionCone`];，`NormalBounds()`方法返回了这样的法线范围。法线范围在光照计算中特别有用：当一个形状是发光的时，它们有时可以有效地确定该形状不会照亮场景中的特定点。
]

```cpp
// <<Shape Interface>>=
DirectionCone NormalBounds() const;
```


=== Ray-Bounds Intersections
<raybounds-intersections>

#parec[
  Given the use of #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] instances to bound shapes, we will add a #link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3")[`Bounds3`] method, #link("<Bounds3::IntersectP>")[`Bounds3::IntersectP()`];, that checks for a ray-box intersection and returns the two parametric $t$ values of the intersection, if any.
][
  鉴于使用#link("../Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] 的实例来限制形状，我们给`Bound3`添加了一个#link("<Bounds3::IntersectP>")[`Bounds3::IntersectP()`];方法，用于计算光线与包围盒的交点，返回交点处的两个参数 $t$ 值（如果有的话）。
]

#parec[
  One way to think of bounding boxes is as the intersection of three slabs, where a slab is the region of space between two parallel planes. To intersect a ray with a box, we intersect the ray with each of the box's three slabs in turn. Because the slabs are aligned with the three coordinate axes, a number of optimizations can be made in the ray-slab tests.
][
  可以将包围盒视为三对板块的交集，其中一对板块是两个平行平面之间的空间区域。要与一个盒子相交光线，我们依次与盒子的每个板块对相交。因为板块对与三个坐标轴对齐，所以在光线-板块测试中可以进行许多优化。
]

#parec[
  The basic ray-bounding box intersection algorithm works as follows: we start with a parametric interval that covers the range of positions $t$ along the ray where we are interested in finding intersections; typically, this is $(0 , oo)$. We will then successively compute the two parametric $t$ positions where the ray intersects each axis-aligned slab. We compute the set intersection of the per-slab intersection interval with the current intersection interval, returning failure if we find that the resulting interval is degenerate. If, after checking all three slabs, the interval is nondegenerate, we have the parametric range of the ray that is inside the box. @fig:ray-box illustrates this process, and @fig:ray-slabs shows the basic geometry of a ray intersecting a slab.
][
  基本的光线-包围盒相交算法如下：我们从一个参数区间开始，该区间覆盖了沿光线寻找相交的位置 $t$ 的范围；通常是 $(0 , oo)$。然后我们将依次计算光线与每个轴对齐板块相交的两个参数 $t$ 位置。我们计算每个板块相交区间与当前相交区间的集合交集，如果发现结果区间是退化的，则返回失败。如果在检查完所有三个板块后，区间是非退化的，我们就得到了光线在盒子内的参数范围。 @fig:ray-box 展示了这个过程，@fig:ray-slabs 展示了光线与板块相交的基本几何。
]

#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f01.svg"),
  caption: [
    #ez_caption[
      *Intersecting a Ray with an Axis-Aligned Bounding Box.* We compute intersection points with each slab in turn, progressively narrowing the parametric interval. Here, in 2D, the intersection of the $x$ and $y$ extents along the ray (thick segment) gives the extent where the ray is inside the box.
    ][
      *光线与轴对齐包围盒相交。*我们依次计算与每个板块的相交点，逐步缩小参数区间。这里，在2D中，沿光线的$x$和$y$范围的相交（粗线段）给出了光线在盒子内的范围。
    ]
  ],
) <ray-box>



#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f02.svg"),
  caption: [
    #ez_caption[
      *Intersecting a Ray with an Axis-Aligned Slab.* The two planes shown here are described by $x = c$ for constant values $c$. The normal of each plane is $(1 , 0 , 0)$. Unless the ray is parallel to the planes, it will intersect the slab twice, at parametric positions $t_(upright("near"))$ and $t_(upright("far")) .$
    ][
      *光线与轴对齐板块相交。*这里显示的两个平面由$x = c$描述，其中$c$为常量。每个平面的法线是$(1 , 0 , 0)$。除非光线与平面平行，否则它将两次与板块相交，在参数位置$t_(upright("near"))$和$t_(upright("far"))$。
    ]
  ],
) <ray-slabs>



#parec[
  If the #link("<Bounds3::IntersectP>")[`Bounds3::IntersectP()`] method returns `true`, the intersection's parametric range is returned in the optional arguments `hitt0` and `hitt1`. Intersections outside of the $(0 , "tMax")$ range of the ray are ignored. If the ray's origin is inside the box, $0$ is returned for `hitt0`.
][
  如果#link("<Bounds3::IntersectP>")[`Bounds3::IntersectP()`];方法返回`true`，相交的参数范围将在可选参数`hitt0`和`hitt1`中返回。超出光线的 $(0 , "tMax")$ 范围的相交将被忽略。如果光线的起点在盒子内，则返回`hitt0`为 $0$。
]

```cpp
template <typename T>
bool Bounds3<T>::IntersectP(Point3f o, Vector3f d, Float tMax,
                            Float *hitt0, Float *hitt1) const {
    Float t0 = 0, t1 = tMax;
    for (int i = 0; i < 3; ++i) {
        // <<Update interval for ith bounding box slab>>
        Float invRayDir = 1 / d[i];
        Float tNear = (pMin[i] - o[i]) * invRayDir;
        Float tFar  = (pMax[i] - o[i]) * invRayDir;
        // Update parametric interval from slab intersection  values
        if (tNear > tFar) pstd::swap(tNear, tFar);
        // Update tFar to ensure robust ray–bounds intersection
        tFar *= 1 + 2 * gamma(3);
        t0 = tNear > t0 ? tNear : t0;
        t1 = tFar  < t1 ? tFar  : t1;
        if (t0 > t1) return false;
    }
    if (hitt0) *hitt0 = t0;
    if (hitt1) *hitt1 = t1;
    return true;
}
```


#parec[
  For each pair of planes, this routine needs to compute two ray-plane intersections. For example, the slab described by two planes perpendicular to the $x$ axis can be described by planes through points $(x_0 , 0 , 0)$ and $(x_1 , 0 , 0)$, each with normal $(1 , 0 , 0)$. Consider the first $t$ value for a plane intersection, $t_0$. The parametric $t$ value for the intersection between a ray with origin $upright(bold(o))$ and direction $upright(bold(d))$ and a plane $a x + b y + c z + d = 0$ can be found by substituting the ray equation into the plane equation:
][
  对于每对平面，这个例程需要计算两个光线与平面相交。例如，由两个垂直于 $x$ 轴的平面描述的板块可以由通过点 $(x_0 , 0 , 0)$ 和 $(x_1 , 0 , 0)$ 的平面描述，每个平面的法线为 $(1 , 0 , 0)$。考虑第一个平面相交的 $t$ 值， $t_0$。光线与起点 $upright(bold(o))$ 和方向 $upright(bold(d))$ 与平面 $a x + b y + c z + d = 0$ 的相交的参数 $t$ 值可以通过将光线方程代入平面方程来找到：
]

$
  o &= a (o_x + t upright(bold(d))_x) + b (o_y + t upright(bold(d))_y) + c (o_z + t upright(bold(d))_z) \
  &= (a, b, c) dot o + t (a, b, c) dot upright(bold(d))+ d
$

#parec[
  Solving for $t$ gives
][
  求解 $t$ 得到
]

$
  t= (-d - ((a,b,c) dot o)) / ((a,b,c) dot upright(bold(d))) .
$

#parec[
  Because the $y$ and $z$ components of the plane's normal are zero, $b$ and $c$ are zero, and $a$ is one. The plane's $d$ coefficient is $- x_0$. We can use this information and the definition of the dot product to simplify the calculation substantially:
][
  由于平面的法向量的 $y$ 和 $z$ 分量为零，所以 $b$ 和 $c$ 为零，而 $a$ 为一。平面的 $d$ 系数为 $- x_0$。我们可以利用这些信息和点积的定义来大大简化计算：
]

$ t_0 = (x_o - o_x) / upright(bold(d))_x $
#parec[
  The code to compute the $t$ values of the slab intersections starts by computing the reciprocal of the corresponding component of the ray direction so that it can multiply by this factor instead of performing multiple divisions. Note that, although it divides by this component, it is not necessary to verify that it is nonzero. If it is zero, then `invRayDir` will hold an infinite value, either $- oo$ or $oo$, and the rest of the algorithm still works correctly.
][
  计算平板交点的 $t$ 值的代码首先通过计算光线方向相应分量的倒数来开始，这样它可以乘以这个因子而不是执行多次除法。注意，虽然它除以这个分量，但没有必要验证它是否为零。如果它为零，那么 `invRayDir` 将持有一个无穷大值，可能是 $- oo$ 或 $oo$， 并且算法的其余部分仍然可以正确工作。
]

```cpp
// <<Update interval for ith bounding box slab>>=
Float invRayDir = 1 / d[i];
Float tNear = (pMin[i] - o[i]) * invRayDir;
Float tFar  = (pMax[i] - o[i]) * invRayDir;
// Update parametric interval from slab intersection  values
if (tNear > tFar) pstd::swap(tNear, tFar);
// Update tFar to ensure robust ray–bounds intersection
tFar *= 1 + 2 * gamma(3);
t0 = tNear > t0 ? tNear : t0;
t1 = tFar  < t1 ? tFar  : t1;
if (t0 > t1) return false;
```

#parec[
  The two distances are reordered so that `tNear` holds the closer intersection and `tFar` the farther one. This gives a parametric range $[t_(N e a r) , t_(F a r)]$, which is used to compute the set intersection with the current range $[t_0 , t_1]$ to compute a new range. If this new range is empty (i.e., $t_0 > t_1$ ), then the code can immediately return failure.
][
  两个距离被重新排序，使得 `tNear` 保存较近的交点，`tFar` 保存较远的交点。这给出了一个参数范围 $[t_(N e a r) , t_(F a r)]$，用于计算与当前范围 $[t_0 , t_1]$ 的集合交集以计算新范围。如果这个新范围为空（即 $t_0 > t_1$ ），那么代码可以立即返回失败。
]

#parec[
  There is another floating-point-related subtlety here: in the case where the ray origin is in the plane of one of the bounding box slabs and the ray lies in the plane of the slab, it is possible that `tNear` or `tFar` will be computed by an expression of the form $0 \/ 0$, which results in a floating-point "not a number" (NaN) value. Like infinity values, NaNs have well-specified semantics: for example, any logical comparison involving a NaN always evaluates to false. Therefore, the code that updates the values of `t0` and `t1` is carefully written so that if `tNear` or `tFar` is NaN, then `t0` or `t1` will not ever take on a NaN value but will always remain unchanged.
][
  这里还有另一个与浮点相关的微妙之处：在光线起点位于一个包围盒平板的平面上并且光线位于平板的平面上的情况下，可能会通过 $0 \/ 0$ 形式的表达式计算出 `tNear` 或 `tFar`，这会导致浮点“非数字”（NaN）值。 像无穷大值一样，NaN 有明确的语义：例如，任何涉及 NaN 的逻辑比较总是评估为假。 因此，更新 `t0` 和 `t1` 值的代码被仔细编写，以确保如果 `tNear` 或 `tFar` 是 NaN，那么 `t0` 或 `t1` 永远不会取 NaN 值，而总是保持不变。
]

```cpp
// Update parametric interval from slab intersection  values
if (tNear > tFar) pstd::swap(tNear, tFar);
// Update tFar to ensure robust ray–bounds intersection
tFar *= 1 + 2 * gamma(3);
t0 = tNear > t0 ? tNear : t0;
t1 = tFar  < t1 ? tFar  : t1;
if (t0 > t1) return false;
```
#parec[
  `Bounds3` also provides a specialized `IntersectP()` method that takes the reciprocal of the ray's direction as an additional parameter, so that the three reciprocals do not need to be computed each time `IntersectP()` is called.
][
  `Bounds3` 还提供了一个专门的 `IntersectP()` 方法，该方法将光线方向的倒数作为额外参数，因此每次调用 `IntersectP()` 时不需要计算三个倒数。
]

#parec[
  This version of the method also takes precomputed values that indicate whether each direction component is negative, which makes it possible to eliminate the comparisons of the computed `tNear` and `tFar` values in the original routine and to directly compute the respective near and far values. Because the comparisons that order these values from low to high in the original code are dependent on computed values, they can be inefficient for processors to execute, since the computation of their values must be finished before the comparison can be made. Because many ray-bounds intersection tests may be performed during rendering, this small optimization is worth using.
][
  这个版本的方法还接受预先计算的值，这些值指示每个方向分量是否为负，这使得可以消除原始例程中计算的 `tNear` 和 `tFar` 值的比较，并直接计算相应的近和远值。 因为原始代码中从低到高排序这些值的比较依赖于计算值，所以它们对于处理器执行可能效率不高，因为必须在进行比较之前完成其值的计算。 因为在渲染过程中可能会执行许多光线与边界的交集测试，所以这个小优化值得使用。
]

#parec[
  This routine returns true if the ray segment is entirely inside the bounding box, even if the intersections are not within the ray's `(0 , tMax)` range.
][
  如果光线段完全在包围盒内，即使交点不在光线的 `(0 , tMax)` 范围内，此例程也返回 `true`。
]

```cpp
// <<Bounds3 Inline Functions>>+=
template <typename T>
bool Bounds3<T>::IntersectP(Point3f o, Vector3f d, Float raytMax,
                            Vector3f invDir, const int dirIsNeg[3]) const {
    const Bounds3f &bounds = *this;
    // <<Check for ray intersection against x and y slabs>>
    Float tMin =  (bounds[  dirIsNeg[0]].x - o.x) * invDir.x;
    Float tMax =  (bounds[1-dirIsNeg[0]].x - o.x) * invDir.x;
    Float tyMin = (bounds[  dirIsNeg[1]].y - o.y) * invDir.y;
    Float tyMax = (bounds[1-dirIsNeg[1]].y - o.y) * invDir.y;
    // <<Update tMax and tyMax to ensure robust bounds intersection>>
    if (tMin > tyMax || tyMin > tMax)
        return false;
    if (tyMin > tMin) tMin = tyMin;
    if (tyMax < tMax) tMax = tyMax;

    // <<Check for ray intersection against  slab>>
    Float tzMin = (bounds[  dirIsNeg[2]].z - o.z) * invDir.z;
    Float tzMax = (bounds[1-dirIsNeg[2]].z - o.z) * invDir.z;
    // <<Update tzMax to ensure robust bounds intersection>>
    if (tMin > tzMax || tzMin > tMax)
        return false;
    if (tzMin > tMin)
        tMin = tzMin;
    if (tzMax < tMax)
        tMax = tzMax;

    return (tMin < raytMax) && (tMax > 0);
}

```


#parec[
  If the ray direction vector is negative, the "near" parametric intersection will be found with the slab with the larger of the two bounding values, and the far intersection will be found with the slab with the smaller of them. The implementation can use this observation to compute the near and far parametric values in each direction directly.
][
  如果光线方向向量为负，则“近”参数交点将与具有较大两个边界值的平板相交，远交点将与具有较小两个边界值的平板相交。 实现可以利用这一观察来直接计算每个方向的近和远参数值。
]

```cpp
// <<Check for ray intersection against x and y slabs>>=
Float tMin =  (bounds[  dirIsNeg[0]].x - o.x) * invDir.x;
Float tMax =  (bounds[1-dirIsNeg[0]].x - o.x) * invDir.x;
Float tyMin = (bounds[  dirIsNeg[1]].y - o.y) * invDir.y;
Float tyMax = (bounds[1-dirIsNeg[1]].y - o.y) * invDir.y;
// <<Update tMax and tyMax to ensure robust bounds intersection>>
if (tMin > tyMax || tyMin > tMax)
    return false;
if (tyMin > tMin) tMin = tyMin;
if (tyMax < tMax) tMax = tyMax;
```
#parec[
  The fragment `<<Check for ray intersection against x slab>>` is analogous and is not included here.
][
  
]

#parec[
  This intersection test is at the heart of traversing the BVHAggregate acceleration structure, which is introduced in @bounding-volume-hierarchies. Because so many ray-bounding box intersection tests are performed while traversing the BVH tree, we found that this optimized method provided approximately a 15% performance improvement in overall rendering time compared to using the `Bounds3::IntersectP()` variant that did not take the precomputed direction reciprocals and signs.
][
  此交集测试是遍历 BVHAggregate 加速结构的核心，该结构在@bounding-volume-hierarchies 中介绍。 因为在遍历 BVH 树时会执行许多光线与包围盒的交集测试，我们发现这个优化方法比使用没有预先计算方向倒数和符号的 `Bounds3::IntersectP()` 变体提供了大约 15% 的整体渲染时间性能提升。
]

=== Intersection Tests
<intersection-tests_chapter_6_1>

#parec[
  `Shapes` implementations must provide an implementation of two methods that test for ray intersections with their shape. The first, `Intersect()`, returns geometric information about a single ray-shape intersection corresponding to the first intersection, if any, in the $(0 , t M a x)$ parametric range along the given ray.
][
  交点实现必须提供两个方法的实现，用于测试射线与形状的交点。第一个方法 `Intersect()` 返回关于单个射线与形状交点的几何信息，该交点对应于给定射线在 $(0 , t M a x)$ 参数范围内的第一个交点（如果有的话）。
]

```cpp
// <<Shape Interface>>+=
pstd::optional<ShapeIntersection> Intersect(const Ray &ray,
                                            Float tMax = Infinity) const;
```

#parec[
  In the event that an intersection is found, a SurfaceInteraction corresponding to the intersection point and the parametric $t$ distance along the ray where the intersection occurred are returned via a `ShapeIntersection` instance.
][
  如果找到交点，则通过 `ShapeIntersection` 实例返回与交点对应的表面交互信息以及交点发生时沿射线的参数化的 $t$ 距离。
]

#parec[
  There are a few important things to keep in mind when reading (and writing) intersection routines:
][
  在阅读（和编写）交点例程时需要记住一些重要事项：
]

#parec[
  - The provided `tMax` value defines the endpoint of the ray.
    Intersection routines must ignore any intersections that occur after
    this point.
][
  - 提供的 `tMax`
    值定义了射线的终点。交点例程必须忽略在此点之后发生的任何交点。
]

#parec[
  - If there are multiple intersections with a shape along the ray, the
    closest one should be reported.
][
  - 如果沿射线与形状有多个交点，则应报告最近的一个。
]

#parec[
  - The rays passed into intersection routines are in rendering space, so
    shapes are responsible for transforming them to object space if needed
    for intersection tests. The intersection information returned should
    be in rendering space.
][
  - 传递给交点例程的射线是在渲染空间中，因此如果需要进行交点测试，形状负责将其转换为对象空间。但返回的交点信息应在渲染空间中。
]

#parec[
  The second intersection test method, `Shape::IntersectP()`, is a predicate function that determines whether or not an intersection occurs without returning any details about the intersection itself. That test is often more efficient than a full intersection test. This method is used in particular for shadow rays that are testing the visibility of a light source from a point in the scene.
][
  第二个交点测试方法 `Shape::IntersectP()` 是一个谓词函数，用于确定是否发生交点，而不返回关于交点本身的任何细节。 该测试通常比完整的交点测试更高效。此方法特别用于测试从场景中的某一点到光源的可见性的阴影射线。
]

```cpp
// <<Shape Interface>>+=
bool IntersectP(const Ray &ray, Float tMax = Infinity) const;
```

=== Intersection Coordinate Spaces
<interaction-coordinate-spaces>

#parec[
  For some shapes, intersection routines are most naturally expressed in their object space. For example, the following Sphere shape computes the intersection with a sphere of a given radius positioned at the origin. The sphere being at the origin allows various simplifications to the intersection algorithm. Other shapes, like the Triangle, transform their representation to rendering space and perform intersection tests there.
][
  对于某些形状，交点例程最自然地在其对象空间中表达。例如，以下球体形状计算与位于原点的给定半径球体的交点。 球体位于原点允许对交点算法进行各种简化。其他形状，如三角形，将其表示转换为渲染空间并在那里执行交点测试。
]

#parec[
  Shapes like Sphere that operate in object space must transform the specified ray to object space and then transform any intersection results back to rendering space. Most of this is handled easily using associated methods in the Transform class that were introduced in Section 3.10, though a natural question to ask is, "What effect does the object-from-rendering-space transformation have on the correct parametric distance to return?" The intersection method has found a parametric $t$ distance to the intersection for the object-space ray, which may have been translated, rotated, scaled, or worse when it was transformed from rendering space.
][
  像球体这样的形状在对象空间中操作，必须将指定的射线转换为对象空间，然后将任何交点结果转换回渲染空间。 大多数情况下，这可以使用在变换类中引入的相关方法轻松处理，尽管一个自然的问题是，"从渲染空间到对象的变换对返回的正确参数距离有什么影响？" 交点方法已经找到了对象空间射线与交点的参数化 $t$ 距离，当它从渲染空间转换时，可能已经被平移、旋转、缩放或更糟。
]

#parec[
  Using the properties of transformations, it is possible to show that the $t$ distance to the intersection is unaffected by the transformation. Consider a rendering-space ray $r_r$ with associated origin $o_r$ and direction $upright(bold(d))_r$. Given an object-from-rendering-space transformation matrix $upright(bold(M))$, we can then find the object-space ray $r_o$ with origin $upright(bold(M))_(o_r)$ and direction $upright(bold(M))_(upright(bold(d)_o))$.
][
  利用变换的性质，可以证明到交点的 $t$ 距离不受变换的影响。 考虑一个具有相关原点 $o_r$ 和方向 $upright(bold(d))_r$ 的渲染空间射线 $r_r$。 给定一个从渲染空间到对象空间的变换矩阵 $upright(bold(M))$，我们可以找到对象空间射线 $r_o$，其原点为 $upright(bold(M))_(o_r)$ ，方向为 $upright(bold(M))_(upright(bold(d)_o))$。
]

#parec[
  If the ray-shape intersection algorithm finds an object-space intersection at a distance $t$ along the ray, then the object-space intersection point is
][
  如果射线-形状交点算法在射线的距离 $t$ 处找到对象空间交点，则对象空间交点为
]

$
  p_o = o_o + t upright(bold(d))_o .
$

#parec[
  Now consider the rendering-space intersection point $p_r$ that is found by applying $upright(bold(M))$ 's inverse to both sides of that equation:
][
  现在考虑通过对该方程两边应用 $upright(bold(M))$ 的逆 找到的渲染空间交点 $p_r$ ：
]

$
  upright(bold(M))^(-1) p_o & = upright(bold(M))^(-1)(o_o + t upright(bold(d))_o) \
  upright(bold(M))^(-1) p_o & = upright(bold(M))^(-1) o_o + upright(bold(M))^(-1)(t upright(bold(d))_o) \
  upright(bold(M))^(-1) p_o & = upright(bold(M))^(-1) o_o + t upright(bold(M))^(-1)(upright(bold(d))_o)\
  p_r & = o_r + t upright(bold(d))_r .
$
#parec[
  Therefore, the $t$ value that was computed in object space is the correct $t$ value for the intersection point in rendering space as well. Note that if the object-space ray's direction had been normalized after the transformation, then this would no longer be the case and a correction factor related to the unnormalized ray's length would be needed. This is one reason that `pbrt` does not normalize object-space rays' directions after transformation.
][
  因此，在对象空间计算的 $t$ 值也是渲染空间中交点的正确 $t$ 值。 请注意，如果对象空间射线的方向在变换后已经被归一化，则情况不再如此，并且需要一个与未归一化射线长度相关的校正因子。 这也是 `pbrt` 在变换后不归一化对象空间射线方向的原因之一。
]


=== Sidedness

#parec[
  Many rendering systems, particularly those based on scanline or z-buffer algorithms, support the concept of shapes being "one-sided"—the shape is visible if seen from the front but disappears when viewed from behind. In particular, if a geometric object is closed and always viewed from the outside, then the backfacing parts of it can be discarded without changing the resulting image. This optimization can substantially improve the speed of these types of hidden surface removal algorithms. The potential for improved performance is reduced when using this technique with ray tracing, however, since it is often necessary to perform the ray-object intersection before determining the surface normal to do the backfacing test. Furthermore, this feature can lead to a physically inconsistent scene description if one-sided objects are not in fact closed. For example, a surface might block light when a shadow ray is traced from a light source to a point on another surface, but not if the shadow ray is traced in the other direction. For all of these reasons, `pbrt` does not support this feature.
][
  许多渲染系统，特别是那些基于扫描线或 z-buffer算法的系统，支持形状为“单面”的概念——当从正面看到时形状可见，但从背面看时消失。 特别是，如果几何对象是封闭的并且总是从外部查看，则其背面的部分可以被丢弃而不改变生成的图像。 这种优化可以显著提高这些类型的隐藏表面移除算法的速度。 然而，当与光线追踪一起使用时，这种技术的性能提升潜力会降低，因为通常需要在进行背面测试之前执行射线-对象交点。 此外，如果单面对象实际上不是封闭的，这个特性可能导致物理上不一致的场景描述。 例如，当从光源到另一个表面上的某一点跟踪阴影射线时，表面可能会阻挡光线，但如果阴影射线朝另一个方向跟踪，则不会。 出于所有这些原因，`pbrt` 不支持此功能。
]


=== Area
<area>
#parec[
  In `pbrt`, area lights are defined by attaching an emission profile to a `Shape`. To use `Shape`s as area lights, it is necessary that shapes be able to return their surface area of a shape in rendering space.
][
  在 `pbrt` 中，面光源是通过将发射轮廓附加到 `Shape` 来定义的。要将 `Shape` 用作面光源，必须能够在渲染空间中返回形状的表面积。
]

```cpp
Float Area() const;
```


=== Sampling
<sampling>
#parec[
  A few methods are necessary to sample points on the surface of shapes in order to use them as emitters. Additional `Shape` methods make this possible.
][
  为了将几何形状用作光线发射体，需要一些方法来在形状表面上采样点。
]

#parec[
  There are two shape sampling methods, both named `Sample()`. The first chooses points on the surface of the shape using a sampling distribution with respect to surface area and returns the local geometric information about the sampled point in a #link("<ShapeSample>")[ShapeSample];. The provided sample value `u`, a uniform sample in $[0 , 1]^2$, should be used to determine the point on the shape.
][
  有两种形状的采样方法，均命名为 `Sample()`。第一种方法使用与表面积相关的采样分布选择形状表面上的点，并返回关于采样点的局部几何信息，存储在 #link("<ShapeSample>")[`ShapeSample`] 中。提供的采样值 `u` 是 $[0 , 1]^2$ 中的均匀采样，用于定位几何形状上的点。
]

```cpp
pstd::optional<ShapeSample> Sample(Point2f u) const;
```


#parec[
  The `ShapeSample` structure that is returned stores an #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] corresponding to a sampled point on the surface as well as the probability density with respect to surface area on the shape for sampling that point.
][
  返回的 `ShapeSample` 结构存储了对应于表面上采样点的 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] 以及该点相对于形状表面积的采样概率密度。
]

```cpp
struct ShapeSample {
    Interaction intr;
    Float pdf;
};
```


#parec[
  Shapes must also provide an associated `PDF()` method that returns probability density for sampling the specified point on the shape that corresponds to the given #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`];. This method should only be called with interactions that are on the shape's surface. Although `Sample()` already returns the probability density for the point it samples, this method is useful when using multiple importance sampling, in which case it is necessary to compute the probability density for samples generated using other sampling techniques. An important detail is that implementations are allowed to assume that the provided point is on their surface; callers are responsible for ensuring that this is the case.
][
  形状还必须提供一个关联的 `PDF()` 方法，该方法返回与 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] 在几何形状上对应点的采样概率密度。此方法应仅在与几何形状表面相交的场景下调用。尽管 `Sample()` 已经返回了它采样的点的概率密度，但在使用多重重要性采样时，此方法很有用，此时需要计算使用其他采样技术生成的样本的概率密度。一个重要的细节是，允许该方法的实现假设提供的点在它们的表面上；调用者有责任确保这种情况。
]

```cpp
Float PDF(const Interaction &) const;
```


#parec[
  The second shape sampling method takes a reference point from which the shape is being viewed. This method is particularly useful for lighting, since the caller can pass in the point to be lit and allow shape implementations to ensure that they only sample the portion of the shape that is potentially visible from that point.
][
  第二种形状采样方法需要一个参考点，从该点观察形状。此方法对于照明特别有用，因为调用者可以传入要照亮的点，并允许形状实现确保它们仅采样从该点可能可见的形状部分。
]

#parec[
  Unlike the first #link("<Shape>")[`Shape`] sampling method, which generates points on the shape according to a probability density with respect to surface area on the shape, the second one uses a density with respect to solid angle from the reference point. This difference stems from the fact that the area light sampling routines evaluate the direct lighting integral as an integral over directions from the reference point—expressing these sampling densities with respect to solid angle at the point is more convenient.
][
  与第一种 #link("<Shape>")[`Shape`] 采样方法不同，该方法根据形状上的表面积概率密度生成点，第二种方法使用从参考点的立体角密度。这种差异源于这样一个事实，即面积光采样例程将直接照明积分评估为从参考点的方向积分——在该点用立体角表示这些采样密度更为方便。
]

```cpp
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx,
                                   Point2f u) const;
```


#parec[
  Information about the reference point and its geometric and shading normals is provided by the `ShapeSampleContext` structure. The reference point position is specified using the #link("../Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] class, which can represent the numerical uncertainty in a ray intersection point computed using floating-point arithmetic. Discussion of related topics is in @managing-rounding-error . For points in participating media that are not associated with a surface, the normal and shading normal are left with their default values of $(0 , 0 , 0)$.
][
  `ShapeSampleContext` 结构提供了参考点及其几何和着色法线的信息。参考点位置使用 #link("../Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] 类指定，该类可以存储使用浮点运算计算中的数值不确定性。相关主题的讨论在@managing-rounding-error 中。对于不与表面相关联的参与介质中的点，法线和着色法线保持其默认值 $(0 , 0 , 0)$。
]

```cpp
struct ShapeSampleContext {
    //<<ShapeSampleContext Public Methods>>
    ShapeSampleContext(Point3fi pi, Normal3f n, Normal3f ns, Float time)
        : pi(pi), n(n), ns(ns), time(time) {}
    ShapeSampleContext(const SurfaceInteraction &si)
      : pi(si.pi), n(si.n), ns(si.shading.n), time(si.time) {}
    ShapeSampleContext(const MediumInteraction &mi)
      : pi(mi.pi), time(mi.time) {}
    Point3f p() const { return Point3f(pi); }
    Point3f OffsetRayOrigin(Vector3f w) const;
    Point3f OffsetRayOrigin(Point3f pt) const;
    Ray SpawnRay(Vector3f w) const;

    Point3fi pi;
    Normal3f n, ns;
    Float time;
};
```

#parec[
  `ShapeSampleContext` provides a variety of convenience constructors that allow specifying the member variable values directly or from various types of #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`];.
][
  `ShapeSampleContext` 提供了多种便捷构造函数，允许直接或从各种 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] 类型指定成员变量值。
]

```cpp
ShapeSampleContext(Point3fi pi, Normal3f n, Normal3f ns, Float time)
  : pi(pi), n(n), ns(ns), time(time) {}
ShapeSampleContext(const SurfaceInteraction &si)
  : pi(si.pi), n(si.n), ns(si.shading.n), time(si.time) {}
ShapeSampleContext(const MediumInteraction &mi)
  : pi(mi.pi), time(mi.time) {}
```


#parec[
  For code that does not need to be aware of numeric error in the intersection point, a method provides it as a regular #link("../Geometry_and_Transformations/Points.html#Point3")[`Point3`];.
][
  对于不需要了解交点数值误差的代码，提供了一种方法返回常规 #link("../Geometry_and_Transformations/Points.html#Point3")[`Point3`]的坐标。
]

```cpp
Point3f p() const { return Point3f(pi); }
```


#parec[
  A second `PDF()` method comes along with this sampling approach. It returns the shape's probability of sampling a point on the light such that the incident direction $thin omega_(upright("normal") i)$ at the reference point is `wi`. As with the corresponding sampling method, this density should be with respect to solid angle at the reference point. As with the other #link("<Shape>")[`Shape`] `PDF()` method, this should only be called for a direction that is known to intersect the shape from the reference point; as such, implementations are not responsible for checking that case.
][
  这种采样方法还附带了第二个 `PDF()` 方法。它返回形状在光源上采样一个点的概率，在参考点的入射方向 $omega_i$ 为 `wi`。与相应的采样方法一样，此密度应相对于参考点的立体角。与其他 #link("<Shape>")[`Shape`] 中的`PDF()` 方法一样，假设从参考点沿着给定的方向一定与形状相交；因此，实现不负责检查这种情况。
]

```cpp
Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const;
```


#parec[
  Some of the `PDF()` method implementations will need to trace a ray from the reference point in the direction $thin omega_(upright("normal") i)$ to see if it intersects the shape. The following `ShapeSampleContext` methods should be used to find the origin or the ray itself rather than using the point returned by #link("<ShapeSampleContext::p>")[`ShapeSampleContext::p`];. This, too, stems from a subtlety related to handling numeric error in intersection points. The implementation of these methods and discussion of the underlying issues can be found in @robust-spawned-ray-origins .
][
  一些 `PDF()` 方法的实现需要从参考点沿方向 $omega_i$ 跟踪光线以查看它是否与形状相交。以下 `ShapeSampleContext` 的方法应用于查找光线的起点或光线本身，而不是使用 #link("<ShapeSampleContext::p>")[`ShapeSampleContext::p`] 返回的点。这也源于处理交点数值误差的一个微妙之处。这些方法的实现和底层问题的讨论可以在@robust-spawned-ray-origins 中找到。
]

```cpp
Point3f OffsetRayOrigin(Vector3f w) const;
Point3f OffsetRayOrigin(Point3f pt) const;
Ray SpawnRay(Vector3f w) const;
```
