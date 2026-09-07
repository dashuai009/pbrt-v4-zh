#import "../template.typ": parec, ez_caption

== #ez_caption[Disks][圆盘]
<disks>
#parec[
  The disk is an interesting quadric since it has a particularly straightforward intersection routine that avoids solving the quadratic equation. In `pbrt`, a #link(<Disk>)[`Disk`] is a circular disk of radius $r$ at height $h$ along the $z$ axis.
][
  圆盘是一种有趣的二次曲面，因为它有一个特别简单的交点计算方法，可以避免求解二次方程。在 `pbrt` 中，#link(<Disk>)[`Disk`] 是一个位于 $z$ 轴上高度 $h$ 处半径为 $r$ 的圆形圆盘。
]

#parec[
  To describe partial disks, the user may specify a maximum $phi.alt$ value beyond which the disk is cut off (@fig:disk-setting ). The disk can also be generalized to an annulus by specifying an inner radius, $r_i$. In parametric form, it is described by
][
  为了描述部分圆盘，用户可以指定一个最大 $phi.alt$ 值，超过该值的圆盘部分将被截去（@fig:disk-setting）。通过指定一个内半径 $r_(upright("i"))$，圆盘可以被扩展为一个环形。在参数方程中，它被描述为
]

$
  phi.alt & = u phi.alt_(upright("max"))\
  x & = ((1 - v) r + v r_(upright("i"))) cos phi.alt\
  y & = ((1 - v) r + v r_(upright("i"))) sin phi.alt\
  z & = h .
$

#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f09.svg"),
  caption: [#ez_caption[
      Basic Setting for the Disk Shape. The disk has radius
      $r$ and is located at height $h$ along the $z$ axis. A partial disk
      may be swept by specifying a maximum $phi.alt$ value and an inner
      radius $r_(upright("i")) .$
    ][
      圆盘形状的基本设置。圆盘的半径为 $r$，位于 $z$ 轴上的高度 $h$
      处。通过指定一个最大 $phi.alt$ 值和一个内半径
      $r_(upright("i"))$，可以扫出一个部分圆盘。
    ]],
) <disk-setting>


#parec[
  @fig:disk-rendered is a rendered image of two disks.
][
  @fig:disk-rendered 是两个圆盘的渲染图像。
]

#figure(
  image("../pbr-book-website/4ed/Shapes/disks.png"),
  caption: [#ez_caption[
      *Two Disks.* A partial disk is on the left, and a
      complete disk is on the right.
    ][
      *两个圆盘。*左边是一个部分圆盘，右边是一个完整圆盘。
    ]],
)<disk-rendered>

#block(sticky: true)[#raw("<<Disk Definition>>=")] <fragment-DiskDefinition-0>
```cpp
class Disk {
  public:
    <<Disk Public Methods>>
  private:
    <<Disk Private Members>>
};
``` <Disk>

#parec[
  The `Disk` constructor directly initializes its various member variables from the values passed to it. We have omitted it here because it is trivial.
][
  `Disk` 构造函数直接从传递给它的值初始化其各种成员变量。我们在这里省略了它，因为它的实现很直接。
]

#block(sticky: true)[#raw("<<Disk Private Members>>=")] <fragment-DiskPrivateMembers-0>
```cpp
const Transform *renderFromObject, *objectFromRender;
bool reverseOrientation, transformSwapsHandedness;
Float height, radius, innerRadius, phiMax;
```


=== #ez_caption[Area and Bounding][面积与包围范围]


#parec[
  Disks have easily computed surface area, since they are just portions of an annulus:
][
  圆盘的表面积很容易计算，因为它们只是圆环的一部分：
]

$ A = phi.alt_(upright("max")) / 2 (r^2 - r_i^2) . $

#block(sticky: true)[#raw("<<Disk Public Methods>>=")] <fragment-DiskPublicMethods-0>
```cpp
Float Area() const {
    return phiMax * 0.5f * (Sqr(radius) - Sqr(innerRadius));
}
```

#parec[
  The bounding method is also quite straightforward; it computes a bounding box centered at the height of the disk along $z$, with an extent of `radius` in both the $x$ and $y$ directions.
][
  包围盒的计算也很直接：它在 $z$ 方向位于圆盘的高度处，在 $x$ 和 $y$ 方向分别从中心向两侧延伸 `radius`。
]

#block(sticky: true)[#raw("<<Disk Method Definitions>>=")] <fragment-DiskMethodDefinitions-0>
```cpp
Bounds3f Disk::Bounds() const {
    return (*renderFromObject)(
        Bounds3f(Point3f(-radius, -radius, height),
                 Point3f( radius,  radius, height)));
}
```

#parec[
  A disk has a single surface normal.
][
  圆盘有一个唯一的表面法向量。
]

#block(sticky: true)[#raw("<<Disk Method Definitions>>+=")] <fragment-DiskMethodDefinitions-1>
```cpp
DirectionCone Disk::NormalBounds() const {
    Normal3f n = (*renderFromObject)(Normal3f(0, 0, 1));
    if (reverseOrientation) n = -n;
    return DirectionCone(Vector3f(n));
}
```

=== #ez_caption[Intersection Tests][求交测试]
#parec[
  The `Disk` intersection test methods follow the same form as the earlier quadrics.We omit `Intersect()`, as it is exactly the same as `Sphere::Intersect()` and `Cylinder::Intersect()`, with calls to `BasicIntersect()` and then `InteractionFromIntersection()`.
][
  `Disk`相交测试方法与前面二次曲面的求交方法相同。我们省略了 `Intersect()`，因为它与 `Sphere::Intersect()` 和 `Cylinder::Intersect()` 完全相同，包括调用 `BasicIntersect()` 然后是 `InteractionFromIntersection()`。
]

#parec[
  The basic intersection test for a ray with a disk is easy. The intersection of the ray with the $z=h$ plane that the disk lies in is found and then the intersection point is checked to see if it lies inside the disk.
][
  射线与圆盘的基本相交测试很简单。首先找到射线与圆盘所在的 $z=h$ 平面的交点，然后检查该交点是否位于圆盘内部。
]

#block(sticky: true)[#raw("<<Disk Public Methods>>+=")] <fragment-DiskPublicMethods-1>
```cpp
pstd::optional<QuadricIntersection> BasicIntersect(const Ray &r,
                                                   Float tMax) const {
    <<Transform Ray origin and direction to object space>>
    <<Compute plane intersection for disk>>
    <<See if hit point is inside disk radii and phi_max >>
    <<Return QuadricIntersection for disk intersection>>
}
```

#parec[
  The first step is to compute the parametric $t$ value where the ray intersects the plane that the disk lies in. We want to find $t$ such that the $z$ component of the ray's position is equal to the height of the disk. Thus,
][
  第一步是计算射线与圆盘所在平面相交处的参数 $t$ 值。我们需要找到一个 $t$，使得射线位置的 $z$ 分量等于圆盘的高度。因此，
]

$
  h = o_z + t upright(bold(d))_z
$

#parec[
  and so
][
  所以
]

$
  t = (h-o_z) / upright(bold(d))_z
$


#parec[
  The intersection method computes a $t$ value and checks to see if it is inside the range of values $(0, "tMax")$. If not, the routine can report that there is no intersection.
][
  求交方法计算一个 $t$ 值，并检查它是否在范围 $(0, "tMax")$ 内。如果不在这个范围内，程序可以报告没有交点。
]

#block(sticky: true)[#raw("<<Compute plane intersection for disk>>=")] <fragment-Computeplaneintersectionfordisk-0>
```cpp
<<Reject disk intersections for rays parallel to the disk’s plane>>
Float tShapeHit = (height - Float(oi.z)) / Float(di.z);
if (tShapeHit <= 0 || tShapeHit >= tMax)
    return {};
```


#parec[
  If the ray is parallel to the disk's plane (i.e., the $z$ component of its direction is zero), no intersection is reported.The case where a ray is both parallel to the disk's plane and lies within the plane is somewhat ambiguous, but it is most reasonable to define intersecting a disk edge-on as “no intersection.” This case must be handled explicitly so that not-a-number floating-point values are not generated by the following code.
][
  如果射线与圆盘平面平行（即射线方向的 $z$ 分量为零），则不报告交点。射线既平行于圆盘平面又位于平面内的情况有些模棱两可，但最合理的定义是将沿圆盘平面方向的相交定义为“无交点”。必须明确处理这种情况，以避免接下来的代码产生非数值（NaN）的浮点值。
]

#block(sticky: true)[#raw("<<Reject disk intersections for rays parallel to the disk’s plane>>=")] <fragment-Rejectdiskintersectionsforraysparalleltothedisksplane-0>
```cpp
if (Float(di.z) == 0)
    return {};
```

#parec[
  Now the intersection method can compute the point `pHit` where the ray intersects the plane. Once the plane intersection is known, an invalid intersection is returned if the distance from the hit to the center of the disk is more than Disk::radius or less than `Disk::innerRadius`. This check can be optimized by computing the squared distance to the center, taking advantage of the fact that the $x$ and $y$ coordinates of the center point $(0,0, "height")$ are zero, and the $z$ coordinate of pHit is equal to height.
][
  现在，求交方法可以计算出射线与平面相交的点 `pHit`。一旦确定了平面的交点，如果从击中点到圆盘中心的距离超过 `Disk::radius` 或小于 `Disk::innerRadius`，则返回无效交点。这个检查可以通过计算到中心的平方距离来优化，利用中心点 $(0,0, "height")$ 的 $x$ 和 $y$ 坐标为零，以及 pHit 的 $z$ 坐标等于高度的事实。
]

#block(sticky: true)[#raw("<<See if hit point is inside disk radii and phi_max >>=")] <fragment-Seeifhitpointisinsidediskradiiandphimax-0>
```cpp
Point3f pHit = Point3f(oi) + (Float)tShapeHit * Vector3f(di);
Float dist2 = Sqr(pHit.x) + Sqr(pHit.y);
if (dist2 > Sqr(radius) || dist2 < Sqr(innerRadius))
    return {};
<<Test disk phi value against phi_max >>
```


#parec[
  If the distance check passes, a final test makes sure that the $phi.alt$ value of the hit point is between zero and $phi.alt_(upright("max"))$, specified by the caller.Inverting the disk's parameterization gives the same expression for $phi.alt$ as the other quadric shapes. Because a ray can only intersect a disk once, there is no need to consider a second intersection if this test fails, as was the case with the two earlier quadrics.
][
  如果距离检查通过，最后的测试会确保击中点的 $phi.alt$ 值在0和由调用方指定的 $phi.alt_(upright("max"))$ 之间。反解圆盘的参数化方程会给出与其他二次曲面形状相同的 $phi.alt$ 表达式。由于光线只能与圆盘相交一次，如果此测试失败，就不需要像前面两个二次曲面那样考虑第二次相交。
]

#block(sticky: true)[#raw("<<Test disk phi value against phi_max >>=")] <fragment-Testdiskphivalueagainstphimax-0>
```cpp
Float phi = std::atan2(pHit.y, pHit.x);
if (phi < 0) phi += 2 * Pi;
if (phi > phiMax)
    return {};
```

#block(sticky: true)[#raw("<<Return QuadricIntersection for disk intersection>>=")] <fragment-ReturnmonoQuadricIntersectionfordiskintersection-0>
```cpp
return QuadricIntersection{tShapeHit, pHit, phi};
```


#parec[
  Finding the `SurfaceInteraction` corresponding to a disk intersection follows the same process of inverting the parametric representation we have seen before.
][
  与前面一样，反解参数化表示，就能求出圆盘交点对应的 `SurfaceInteraction`。
]

#block(sticky: true)[#raw("<<Disk Public Methods>>+=")] <fragment-DiskPublicMethods-2>
```cpp
SurfaceInteraction InteractionFromIntersection(
        const QuadricIntersection &isect, Vector3f wo, Float time) const {
    Point3f pHit = isect.pObj;
    Float phi = isect.phi;
    <<Find parametric representation of disk hit>>
    <<Refine disk intersection point>>
    <<Compute error bounds for disk intersection>>
    <<Return SurfaceInteraction for quadric intersection>>
}
```

#parec[
  The parameter `u` is first scaled to reflect the partial disk specified by $phi.alt_("max")$, and `v` is computed by inverting the parametric equation. The equations for the partial derivatives at the hit point can be derived with a process similar to that used for the previous quadrics. Because the normal of a disk is the same everywhere, the partial derivatives $frac(∂ upright(bold(n)), ∂ u)$ and $frac(∂ upright(bold(n)), ∂ v)$ are both trivially $(0,0,0)$.
][
  首先根据 $phi.alt_("max")$ 指定的部分圆盘对参数 `u` 缩放，再反解参数方程求出 `v`。交点处偏导数的推导与前面的二次曲面类似。圆盘各处的法向量相同，因此 $frac(∂ upright(bold(n)), ∂ u)$ 与 $frac(∂ upright(bold(n)), ∂ v)$ 都是 $(0,0,0)$。
]



#block(sticky: true)[#raw("<<Find parametric representation of disk hit>>=")] <fragment-Findparametricrepresentationofdiskhit-0>
```cpp
Float u = phi / phiMax;
Float rHit = std::sqrt(Sqr(pHit.x) + Sqr(pHit.y));
Float v = (radius - rHit) / (radius - innerRadius);
Vector3f dpdu(-phiMax * pHit.y, phiMax * pHit.x, 0);
Vector3f dpdv = Vector3f(pHit.x, pHit.y, 0) * (innerRadius - radius) / rHit;
Normal3f dndu(0, 0, 0), dndv(0, 0, 0);
```

#parec[
  As usual, the implementation of IntersectP() is straightforward.
][
  一如既往，IntersectP() 的实现很简单。
]

#block(sticky: true)[#raw("<<Disk Public Methods>>+=")] <fragment-DiskPublicMethods-3>
```cpp
bool IntersectP(const Ray &r, Float tMax = Infinity) const {
    return BasicIntersect(r, tMax).has_value();
}
```


=== #ez_caption[Sampling][采样]
<disk-sampling>
#parec[
  The #link(<Disk>)[`Disk`] area sampling method uses a utility routine, #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformDiskConcentric")[`SampleUniformDiskConcentric()`], that uniformly samples a unit disk. (It is defined in Section #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[A.5.1].) The point that it returns is then scaled by the radius and offset in $z$ so that it lies on the disk of a given radius and height. Note that our implementation here does not account for partial disks due to #link("https://pbr-book.org/4ed/Shapes/Disks.html#Disk::innerRadius")[`Disk::innerRadius`] being nonzero or #link("https://pbr-book.org/4ed/Shapes/Disks.html#Disk::phiMax")[`Disk::phiMax`] being less than $2 pi$. Fixing this bug is left for an exercise at the end of the chapter.
][
  #link(<Disk>)[`Disk`] 面积采样方法使用一个实用程序例程 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformDiskConcentric")[`SampleUniformDiskConcentric()`]，它均匀地采样单位圆盘。（定义在章节 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[A.5.1] 中。）返回的点然后根据半径进行缩放，并在 $z$ 方向上偏移，使其位于给定半径和高度的圆盘上。请注意，我们在这里的实现没有考虑由于 #link("https://pbr-book.org/4ed/Shapes/Disks.html#Disk::innerRadius")[`Disk::innerRadius`] 非零或 #link("https://pbr-book.org/4ed/Shapes/Disks.html#Disk::phiMax")[`Disk::phiMax`] 小于 $2 pi$ 而导致的不完整的圆盘。修复此错误留作本章末尾的练习。
]

#block(sticky: true)[#raw("<<Disk Public Methods>>+=")] <fragment-DiskPublicMethods-4>
```cpp
pstd::optional<ShapeSample> Sample(Point2f u) const {
    Point2f pd = SampleUniformDiskConcentric(u);
    Point3f pObj(pd.x * radius, pd.y * radius, height);
    Point3fi pi = (*renderFromObject)(Point3fi(pObj));
    Normal3f n = Normalize((*renderFromObject)(Normal3f(0, 0, 1)));
    if (reverseOrientation)
        n *= -1;
    <<Compute (u, v) for sampled point on disk>>
    return ShapeSample{Interaction(pi, n, uv), 1 / Area()};
}
```
#parec[
  The same computation as in the `Intersect()` method gives the parametric $(u , v)$ for the sampled point.
][
  与 `Intersect()` 方法中的计算相同，为采样点提供参数化的 $(u , v)$。
]

#block(sticky: true)[#raw("<<Compute (u, v) for sampled point on disk>>=")] <fragment-Computeuvforsampledpointondisk-0>
```cpp
Float phi = std::atan2(pd.y, pd.x);
if (phi < 0) phi += 2 * Pi;
Float radiusSample = std::sqrt(Sqr(pObj.x) + Sqr(pObj.y));
Point2f uv(phi / phiMax, (radius - radiusSample) / (radius - innerRadius));
```



#block(sticky: true)[#raw("<<Disk Public Methods>>+=")] <fragment-DiskPublicMethods-5>
```cpp
Float PDF(const Interaction &) const { return 1 / Area(); }
```

#parec[
  We do not provide a specialized solid angle sampling method for disks, but follow the same approach that we did for cylinders, sampling uniformly by area and then computing the probability density to be with respect to solid angle. The implementations of those methods are not included here, as they are the same as they were for cylinders.
][
  我们没有为圆盘提供专门的立体角采样方法，而是遵循与圆柱相同的方法，通过面积均匀采样，然后计算相对于立体角的概率密度。此处不包括这些方法的实现，因为它们与圆柱的方法相同。
]

#include "supplements/6.4-expanded.typ"
