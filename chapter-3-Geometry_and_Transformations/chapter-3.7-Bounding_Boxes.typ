#import "../template.typ": parec, ez_caption, translator

== #ez_caption[Bounding Boxes][包围盒]
#parec[
  Many parts of the system operate on axis-aligned regions of space. For example, multi-threading in `pbrt` is implemented by subdividing the image into 2D rectangular tiles that can be processed independently, and the bounding volume hierarchy in @bounding-volume-hierarchies uses 3D boxes to bound geometric primitives in the scene. The #link(<Bounds2>)[`Bounds2`] and #link(<Bounds3>)[`Bounds3`] template classes are used to represent the extent of these sorts of regions. Both are parameterized by a type `T` that is used to represent the coordinates of their extents. As with the earlier vector math types, we will focus here on the 3D variant, #link(<Bounds3>)[`Bounds3`], since #link(<Bounds2>)[`Bounds2`] is effectively a subset of it.
][
  系统的许多部分需要处理轴对齐的空间区域。例如，`pbrt` 将图像划分为可独立处理的二维矩形图块来实现多线程；@bounding-volume-hierarchies 中的包围体层次结构则用三维盒子包围场景中的几何图元。`Bounds2` 和 `Bounds3` 模板类表示这类区域的范围。二者均以用于存储边界坐标的类型 `T` 为模板参数。与前面的向量数学类型一样，这里重点介绍三维版本 `Bounds3`，因为 `Bounds2` 基本上是它的一个子集。
]


#block(sticky: true)[#raw("<<Bounds2 Definition>>=")] <fragment-Bounds2Definition-0>
```cpp
template <typename T>
class Bounds2 {
  public:
    <<Bounds2 Public Methods>>
    <<Bounds2 Public Members>>
};
``` <Bounds2>


#block(sticky: true)[#raw("<<Bounds3 Definition>>=")] <fragment-Bounds3Definition-0>
```cpp
template <typename T>
class Bounds3 {
  public:
    <<Bounds3 Public Methods>>
    <<Bounds3 Public Members>>
};
``` <Bounds3>

#parec[
  We use the same shorthand as before to define names for commonly used bounding types.
][
  和前面一样，我们为常用的包围范围类型定义简短的别名。
]

#block(sticky: true)[#raw("<<Bounds[23][fi] Definitions>>=")] <fragment-Bounds23fiDefinitions-0>
```cpp
using Bounds2f = Bounds2<Float>;
using Bounds2i = Bounds2<int>;
using Bounds3f = Bounds3<Float>;
using Bounds3i = Bounds3<int>;
```

#parec[
  There are a few possible representations for these sorts of bounding boxes; `pbrt` uses #emph[axis-aligned bounding boxes] (AABBs), where the box edges are mutually perpendicular and aligned with the coordinate system axes. Another possible choice is #emph[oriented bounding boxes] (OBBs), where the box edges on different sides are still perpendicular to each other but not necessarily coordinate-system aligned. A 3D AABB can be described by one of its vertices and three lengths, each representing the distance spanned along the $x$, $y$, and $z$ coordinate axes. Alternatively, two opposite vertices of the box can describe it. We chose the two-point representation for `pbrt`'s #link(<Bounds2>)[`Bounds2`] and #link(<Bounds3>)[`Bounds3`] classes; they store the positions of the vertex with minimum coordinate values and of the one with maximum coordinate values. A 2D illustration of a bounding box and its representation is shown in @fig:bboxexample .
][
  包围盒有几种可能的表示方式。`pbrt` 使用#emph[轴对齐包围盒]（AABB），其各方向的边相互垂直，并与坐标轴对齐。另一种选择是#emph[有向包围盒]（OBB），各方向的边仍相互垂直，但不一定与坐标轴对齐。三维 AABB 可以用一个顶点及三个长度表示，这三个长度分别是在 $x$、$y$、$z$ 轴上跨越的距离；也可以用盒子的两个相对顶点表示。`pbrt` 的 `Bounds2` 和 `Bounds3` 采用两点表示法，存储各坐标均最小的顶点和各坐标均最大的顶点的位置。@fig:bboxexample 给出了二维示例。
]


#block(sticky: true)[#raw("<<Bounds3 Public Members>>=")] <fragment-Bounds3PublicMembers-0>
```cpp
Point3<T> pMin, pMax;
```

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f09.svg"),
  caption: [
    #ez_caption[An Axis-Aligned Bounding Box. The `Bounds2` and `Bounds3` classes store only the coordinates of the minimum and maximum points of the box; the other box corners are implicit in this representation.][轴对齐包围盒。`Bounds2` 和 `Bounds3` 只存储盒子最小角点与最大角点的坐标，其他角点隐含在这一表示中。]
  ],
)<bboxexample>

#parec[
  The default constructors create an empty box by setting the extent to an invalid configuration, which violates the invariant that `pMin.x <= pMax.x` (and similarly for the other dimensions). By initializing two corner points with the largest and smallest representable number, any operations involving an empty box (e.g., `Union()`) will yield the correct result.
][
  默认构造函数通过设置无效范围来创建空包围盒，使其不满足 `pMin.x <= pMax.x` 这一不变条件，其他维度同理。用最大和最小可表示数初始化这两个角点，可以使涉及空包围盒的操作（如 `Union()`）得到正确结果。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>=") #link(<fragment-Bounds3PublicMethods-1>)[▼]] <fragment-Bounds3PublicMethods-0>
```cpp
Bounds3() {
    T minNum = std::numeric_limits<T>::lowest();
    T maxNum = std::numeric_limits<T>::max();
    pMin = Point3<T>(maxNum, maxNum, maxNum);
    pMax = Point3<T>(minNum, minNum, minNum);
}
```

#parec[
  It is also useful to be able to initialize bounds that enclose just a single point:
][
  初始化只包围一个点的范围也很有用：
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-0>)[▲] #link(<fragment-Bounds3PublicMethods-2>)[▼]] <fragment-Bounds3PublicMethods-1>
```cpp
explicit Bounds3(Point3<T> p) : pMin(p), pMax(p) {}
```

#parec[
  If the caller passes two corner points (p1 and p2) to define the box, the constructor needs to find their component-wise minimum and maximum values since it is not necessarily the case that p1.x <= p2.x, and so on.
][
  如果调用者传入两个角点 `p1` 和 `p2` 来定义盒子，构造函数需要逐分量求最小值和最大值，因为 `p1.x <= p2.x` 等关系不一定成立。
]
#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-1>)[▲] #link(<fragment-Bounds3PublicMethods-3>)[▼]] <fragment-Bounds3PublicMethods-2>
```cpp
Bounds3(Point3<T> p1, Point3<T> p2)
    : pMin(Min(p1, p2)), pMax(Max(p1, p2)) {}
```

#parec[
  It can be useful to use array indexing to select between the two points at the corners of the box. Assertions in the debug build, not shown here, check that the provided index is either 0 or 1.
][
  用数组索引选择两个角点之一会很方便。调试版本中的断言（此处未列出）会检查索引只能为 0 或 1。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-2>)[▲] #link(<fragment-Bounds3PublicMethods-4>)[▼]] <fragment-Bounds3PublicMethods-3>
```cpp
Point3<T> operator[](int i) const { return (i == 0) ? pMin : pMax; }
Point3<T> &operator[](int i) { return (i == 0) ? pMin : pMax; }
```

#parec[
  The `Corner()` method returns the coordinates of one of the eight corners of the bounding box. Its logic calls the `operator[]` method with a zero or one value for each dimension that is based on one of the low three bits of corner and then extracts the corresponding component. It is worthwhile to verify that this method returns the positions of all eight corners when passed values from 0 to 7 if that is not immediately evident.
][
  `Corner()` 返回包围盒八个角点之一的坐标。对于每个维度，它根据 `corner` 的低三位之一，向 `operator[]` 传入 0 或 1，再提取相应分量。如果这段逻辑不够直观，可以验证：传入 0 到 7 的所有值，是否恰好得到八个角点的位置。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-3>)[▲] #link(<fragment-Bounds3PublicMethods-5>)[▼]] <fragment-Bounds3PublicMethods-4>
```cpp
Point3<T> Corner(int corner) const {
    return Point3<T>((*this)[(corner & 1)].x,
                     (*this)[(corner & 2) ? 1 : 0].y,
                     (*this)[(corner & 4) ? 1 : 0].z);
}
```

#parec[
  Given a bounding box and a point, the Union() function returns a new bounding box that encompasses that point as well as the original bounds.
][
  给定一个包围盒和一个点，`Union()` 返回同时包围该点及原包围盒的新包围盒。
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>=") #link(<fragment-Bounds3InlineFunctions-1>)[▼]] <fragment-Bounds3InlineFunctions-0>
```cpp
template <typename T>
Bounds3<T> Union(const Bounds3<T> &b, Point3<T> p) {
    Bounds3<T> ret;
    ret.pMin = Min(b.pMin, p);
    ret.pMax = Max(b.pMax, p);
    return ret;
}
```

#parec[
  One subtlety that applies to this and some of the following functions is that it is important that the pMin and pMax members of ret be set directly here, rather than passing the values returned by Min() and Max() to the Bounds3 constructor. The detail stems from the fact that if the provided bounds are both degenerate, the returned bounds should be degenerate as well. If a degenerate extent is passed to the constructor, then it will sort the coordinate values, which in turn leads to what is essentially an infinite bound.
][
  这里及后面一些函数有一处需要注意：应直接设置 `ret` 的 `pMin` 和 `pMax`，而不是把 `Min()`、`Max()` 的结果传给 `Bounds3` 构造函数。原因是，当输入的两个包围范围都退化时，输出也应该退化。如果把退化范围传给构造函数，它会重新排序坐标值，反而得到一个实质上无限大的包围范围。
]
#parec[
  It is similarly possible to construct a new box that bounds the space encompassed by two other bounding boxes. The definition of this function is similar to the earlier Union() method that takes a Point3f; the difference is that the pMin and pMax of the second box are used for the Min() and Max() tests, respectively.
][
  同样，也可以构造一个包围另外两个包围盒所覆盖空间的新盒子。此函数与前面接受 `Point3f` 的 `Union()` 类似，区别在于分别使用第二个盒子的 `pMin` 和 `pMax` 参与 `Min()` 和 `Max()` 比较。
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-0>)[▲] #link(<fragment-Bounds3InlineFunctions-2>)[▼]] <fragment-Bounds3InlineFunctions-1>
```cpp
template <typename T>
Bounds3<T> Union(const Bounds3<T> &b1, const Bounds3<T> &b2) {
    Bounds3<T> ret;
    ret.pMin = Min(b1.pMin, b2.pMin);
    ret.pMax = Max(b1.pMax, b2.pMax);
    return ret;
}
```


#parec[
  The intersection of two bounding boxes can be found by computing the maximum of their two respective minimum coordinates and the minimum of their maximum coordinates. (See @fig:bbox-intersection )
][
  对两个包围盒各自的最小坐标逐分量取最大值，对它们的最大坐标逐分量取最小值，就能得到二者的交集。（见 @fig:bbox-intersection。）
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f10.svg"),
  caption: [
    #ez_caption[_Intersection of Two Bounding Boxes._ Given two bounding boxes with pMin and pMax points denoted by open circles, the bounding box of their area of intersection (shaded region) has a minimum point (lower left filled circle) with coordinates given by the maximum of the coordinates of the minimum points of the two boxes in each dimension. Similarly, its maximum point (upper right filled circle) is given by the minimums of the boxes’ maximum coordinates.][_两个包围盒的交集。_图中以空心圆表示两个包围盒的 `pMin` 和 `pMax`。交集区域（阴影）的最小角点是左下实心圆，其每个坐标等于两个盒子最小坐标的较大值；最大角点是右上实心圆，其每个坐标等于两个盒子最大坐标的较小值。]
  ],
)<bbox-intersection>

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-1>)[▲] #link(<fragment-Bounds3InlineFunctions-3>)[▼]] <fragment-Bounds3InlineFunctions-2>
```cpp
template <typename T>
Bounds3<T> Intersect(const Bounds3<T> &b1, const Bounds3<T> &b2) {
    Bounds3<T> b;
    b.pMin = Max(b1.pMin, b2.pMin);
    b.pMax = Min(b1.pMax, b2.pMax);
    return b;
}
```


#parec[
  We can also determine if two bounding boxes overlap by seeing if their extents overlap in all of $x$, $y$ , and $z$ :
][
  检查两个包围盒在 $x$、$y$、$z$ 三个方向上的范围是否都重叠，就能判断它们是否重叠：
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-2>)[▲] #link(<fragment-Bounds3InlineFunctions-4>)[▼]] <fragment-Bounds3InlineFunctions-3>
```cpp
template <typename T>
bool Overlaps(const Bounds3<T> &b1, const Bounds3<T> &b2) {
    bool x = (b1.pMax.x >= b2.pMin.x) && (b1.pMin.x <= b2.pMax.x);
    bool y = (b1.pMax.y >= b2.pMin.y) && (b1.pMin.y <= b2.pMax.y);
    bool z = (b1.pMax.z >= b2.pMin.z) && (b1.pMin.z <= b2.pMax.z);
    return (x && y && z);
}
```

#parec[
  Three 1D containment tests determine if a given point is inside a bounding box.
][
  通过三个一维包含测试，可以判断给定点是否位于包围盒内。
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-3>)[▲] #link(<fragment-Bounds3InlineFunctions-5>)[▼]] <fragment-Bounds3InlineFunctions-4>
```cpp
template <typename T>
bool Inside(Point3<T> p, const Bounds3<T> &b) {
    return (p.x >= b.pMin.x && p.x <= b.pMax.x &&
            p.y >= b.pMin.y && p.y <= b.pMax.y &&
            p.z >= b.pMin.z && p.z <= b.pMax.z);
}
```

#parec[
  The `InsideExclusive()` variant of `Inside()` does not consider points on the upper boundary to be inside the bounds. It is mostly useful with integer-typed bounds.
][
  `Inside()` 的变体 `InsideExclusive()` 不将位于最大边界上的点视为范围内部。它主要用于整数类型的包围范围。
]
#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-4>)[▲] #link(<fragment-Bounds3InlineFunctions-6>)[▼]] <fragment-Bounds3InlineFunctions-5>
```cpp
template <typename T>
bool InsideExclusive(Point3<T> p, const Bounds3<T> &b) {
    return (p.x >= b.pMin.x && p.x < b.pMax.x &&
            p.y >= b.pMin.y && p.y < b.pMax.y &&
            p.z >= b.pMin.z && p.z < b.pMax.z);
}
```

#parec[
  `DistanceSquared()` returns the squared distance from a point to a bounding box or zero if the point is inside it. The geometric setting of the computation is shown in @fig:point-aabb-distance. After the distance from the point to the box is computed in each dimension, the squared distance is found by summing the squares of each of the 1D distances.
][
  `DistanceSquared()` 返回点到包围盒的距离平方；若点在盒内，则返回零。@fig:point-aabb-distance 展示了这一计算的几何关系。先求出每个维度上点到盒子的距离，再将这些一维距离的平方相加，即得到距离平方。
]
#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f11.svg"),
  caption: [
    #ez_caption[Computing the Squared Distance from a Point to an Axis-Aligned Bounding Box. We first find the distance from the point to the box in each dimension. Here, the point represented by an empty circle on the upper left is above to the left of the box, so its $x$ and $y$ distances are respectively `pMin.x - p.x` and `pMin.y - p.y`. The other point represented by an empty circle is to the right of the box but overlaps its extent in the $y$ dimension, giving it respective distances of `p.x - pMax.x` and zero. The logic in `Bounds3::DistanceSquared()` computes these distances by finding the maximum of zero and the distances to the minimum and maximum points in each dimension.][计算点到轴对齐包围盒的距离平方。首先计算每个维度上点到盒子的距离。左上方空心圆所表示的点在盒子的左上侧，因此其 $x$、$y$ 方向距离分别为 `pMin.x - p.x` 和 `pMin.y - p.y`。另一个空心圆所表示的点位于盒子右侧，但在 $y$ 方向落在盒子的范围内，因此两个方向的距离分别为 `p.x - pMax.x` 和零。`Bounds3::DistanceSquared()` 在每个维度上取零、到最小角点的差值和到最大角点的差值三者的最大值，以算出这些距离。]
  ],
)<point-aabb-distance>
#parec[][
  #translator[固定原书图注将左上方点的 y 方向距离写成 pMin.y - p.y；图中 pMin 在左下、pMax 在右上，因而此处图示与该差值不一致。保留原图注，待统一核实；随后代码按三者最大值计算，未改动。]
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-5>)[▲] #link(<fragment-Bounds3InlineFunctions-7>)[▼]] <fragment-Bounds3InlineFunctions-6>
```cpp
template <typename T, typename U>
auto DistanceSquared(Point3<T> p, const Bounds3<U> &b) {
    using TDist = decltype(T{} - U{});
    TDist dx = std::max<TDist>({0, b.pMin.x - p.x, p.x - b.pMax.x});
    TDist dy = std::max<TDist>({0, b.pMin.y - p.y, p.y - b.pMax.y});
    TDist dz = std::max<TDist>({0, b.pMin.z - p.z, p.z - b.pMax.z});
    return Sqr(dx) + Sqr(dy) + Sqr(dz);
}
```

#parec[
  It is easy to compute the distance from a point to a bounding box, though some indirection is needed to be able to determine the correct return type using TupleLength.
][
  求点到包围盒的距离也很简单，但要稍作间接处理，才能通过 `TupleLength` 确定合适的返回类型。
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-6>)[▲] #link(<fragment-Bounds3InlineFunctions-8>)[▼]] <fragment-Bounds3InlineFunctions-7>
```cpp
template <typename T, typename U>
auto Distance(Point3<T> p, const Bounds3<U> &b) {
    auto dist2 = DistanceSquared(p, b);
    using TDist = typename TupleLength<decltype(dist2)>::type;
    return std::sqrt(TDist(dist2));
}
```

#parec[
  The Expand() function pads the bounding box by a constant factor in all dimensions.
][
  `Expand()` 在每个维度上用同一常量扩展包围盒。
]

#block(sticky: true)[#raw("<<Bounds3 Inline Functions>>+=") #link(<fragment-Bounds3InlineFunctions-7>)[▲] #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#fragment-Bounds3InlineFunctions-9")[▼]] <fragment-Bounds3InlineFunctions-8>
```cpp
template <typename T, typename U>
Bounds3<T> Expand(const Bounds3<T> &b, U delta) {
    Bounds3<T> ret;
    ret.pMin = b.pMin - Vector3<T>(delta, delta, delta);
    ret.pMax = b.pMax + Vector3<T>(delta, delta, delta);
    return ret;
}
```

#parec[
  Diagonal() returns the vector along the box diagonal from the minimum point to the maximum point.
][
  `Diagonal()` 返回从最小角点沿盒子对角线指向最大角点的向量。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-4>)[▲] #link(<fragment-Bounds3PublicMethods-6>)[▼]] <fragment-Bounds3PublicMethods-5>
```cpp
Vector3<T> Diagonal() const { return pMax - pMin; }
```

#parec[
  Methods for computing the surface area of the six faces of the box and the volume inside of it are also useful. (This is a place where Bounds2 and Bounds3 diverge: these methods are not available in Bounds2, though it does have an Area() method.)
][
  计算盒子六个面的总表面积以及内部体积也很有用。（这里体现了 `Bounds2` 与 `Bounds3` 的区别：`Bounds2` 没有这两个方法，但提供了 `Area()` 方法。）
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-5>)[▲] #link(<fragment-Bounds3PublicMethods-7>)[▼]] <fragment-Bounds3PublicMethods-6>
```cpp
T SurfaceArea() const {
    Vector3<T> d = Diagonal();
    return 2 * (d.x * d.y + d.x * d.z + d.y * d.z);
}
```

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-6>)[▲] #link(<fragment-Bounds3PublicMethods-8>)[▼]] <fragment-Bounds3PublicMethods-7>
```cpp
T Volume() const {
    Vector3<T> d = Diagonal();
    return d.x * d.y * d.z;
}
```

#parec[
  The Bounds3::MaxDimension() method returns the index of which of the three axes is longest. This is useful, for example, when deciding which axis to subdivide when building some of the ray-intersection acceleration structures.
][
  `Bounds3::MaxDimension()` 返回盒子沿三个轴延伸最长的那个轴的索引。例如，构建某些射线求交加速结构时，可以用它决定沿哪个轴细分。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-7>)[▲] #link(<fragment-Bounds3PublicMethods-9>)[▼]] <fragment-Bounds3PublicMethods-8>
```cpp
int MaxDimension() const {
    Vector3<T> d = Diagonal();
    if (d.x > d.y && d.x > d.z) return 0;
    else if (d.y > d.z)         return 1;
    else                        return 2;
}
```

#parec[
  Lerp() linearly interpolates between the corners of the box by the given amount in each dimension.
][
  `Lerp()` 按每个维度给定的比例，在盒子的角点之间进行线性插值。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-8>)[▲] #link(<fragment-Bounds3PublicMethods-10>)[▼]] <fragment-Bounds3PublicMethods-9>
```cpp
Point3f Lerp(Point3f t) const {
    return Point3f(pbrt::Lerp(t.x, pMin.x, pMax.x),
                   pbrt::Lerp(t.y, pMin.y, pMax.y),
                   pbrt::Lerp(t.z, pMin.z, pMax.z));
}
```

#parec[
  Offset() is effectively the inverse of Lerp(). It returns the continuous position of a point relative to the corners of the box, where a point at the minimum corner has offset $(0,0,0)$, a point at the maximum corner has offset $(1,1,1)$, and so forth.
][
  `Offset()` 实质上是 `Lerp()` 的逆操作。它返回点相对于盒子角点的连续位置：最小角点处的偏移为 $(0,0,0)$，最大角点处为 $(1,1,1)$，其他位置依此类推。
]

#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-9>)[▲] #link(<fragment-Bounds3PublicMethods-11>)[▼]] <fragment-Bounds3PublicMethods-10>
```cpp
Vector3f Offset(Point3f p) const {
    Vector3f o = p - pMin;
    if (pMax.x > pMin.x) o.x /= pMax.x - pMin.x;
    if (pMax.y > pMin.y) o.y /= pMax.y - pMin.y;
    if (pMax.z > pMin.z) o.z /= pMax.z - pMin.z;
    return o;
}
```

#parec[
  Bounds3 also provides a method that returns the center and radius of a sphere that bounds the bounding box. In general, this may give a far looser fit than a sphere that bounded the original contents of the Bounds3 directly, although for some geometric operations it is easier to work with a sphere than a box, in which case the worse fit may be an acceptable trade-off.
][
  `Bounds3` 还提供了一个方法，返回包围整个盒子的球的球心与半径。这通常比直接包围 `Bounds3` 原始内容的球松得多。不过，对某些几何操作而言，处理球比处理盒子容易，因此接受较松的包围可能是合理的权衡。
]


#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-10>)[▲] #link(<fragment-Bounds3PublicMethods-12>)[▼]] <fragment-Bounds3PublicMethods-11>
```cpp
void BoundingSphere(Point3<T> *center, Float *radius) const {
    *center = (pMin + pMax) / 2;
    *radius = Inside(*center, *this) ? Distance(*center, pMax) : 0;
}
```


#parec[
  Straightforward methods test for empty and degenerate bounding boxes. Note that “empty” means that a bounding box has zero volume but does not necessarily imply that it has zero surface area.
][
  下面两个简单方法分别检查空包围盒和退化包围盒。注意，“空”表示包围盒体积为零，但不一定意味着表面积也为零。
]


#block(sticky: true)[#raw("<<Bounds3 Public Methods>>+=") #link(<fragment-Bounds3PublicMethods-11>)[▲]] <fragment-Bounds3PublicMethods-12>
```cpp
bool IsEmpty() const {
    return pMin.x >= pMax.x || pMin.y >= pMax.y || pMin.z >= pMax.z;
}
bool IsDegenerate() const {
    return pMin.x > pMax.x || pMin.y > pMax.y || pMin.z > pMax.z;
}
```

#parec[
  Finally, for integer bounds, there is an iterator class that fulfills the requirements of a C++ forward iterator (i.e., it can only be advanced). The details are slightly tedious and not particularly interesting, so the code is not included in the book. Having this definition makes it possible to write code using range-based for loops to iterate over integer coordinates in a bounding box:
][
  最后，对于整数包围范围，还提供了满足 C++ 前向迭代器要求的迭代器类，即它只能向前移动。实现细节稍显繁琐，也并不特别有趣，因此原书未列出代码。借助这个定义，可以用基于范围的 `for` 循环遍历包围盒中的整数坐标：
]

```cpp
Bounds2i b = ...;
for (Point2i p : b) {
    //  …
}
```

#parec[
  As implemented, the iteration goes up to but does not visit points equal to the maximum extent in each dimension.
][
  当前实现的迭代不包含各维度上等于最大边界的点。
]

#heading(level: 3, numbering: none)[#ez_caption[Supplement: Additional Code in the Original Collapsed Panels][补充：原网页折叠面板中的额外代码]]
#include "supplements/3.7-expanded.typ"
