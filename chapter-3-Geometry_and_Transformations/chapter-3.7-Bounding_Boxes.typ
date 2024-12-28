#import "../template.typ": parec, ez_caption

== Bounding Boxes
#parec[
  Many parts of the system operate on axis-aligned regions of space. For example, multi-threading in `pbrt` is implemented by subdividing the image into 2D rectangular tiles that can be processed independently, and the bounding volume hierarchy in @bounding-volume-hierarchies uses 3D boxes to bound geometric primitives in the scene. The #link("<Bounds2>")[Bounds2] and #link("<Bounds3>")[Bounds3] template classes are used to represent the extent of these sorts of regions. Both are parameterized by a type `T` that is used to represent the coordinates of their extents. As with the earlier vector math types, we will focus here on the 3D variant, #link("<Bounds3>")[Bounds3];, since #link("<Bounds2>")[Bounds2] is effectively a subset of it.
][
  系统的许多部分在轴对齐的空间区域中运行。例如，`pbrt`中的多线程通过将图像划分为可以独立处理的二维矩形块来实现，@bounding-volume-hierarchies 中的包围体层次结构使用三维框来限制场景中的几何原语。 #link("<Bounds2>")[Bounds2];和#link("<Bounds3>")[Bounds3];模板类用于表示这些区域的范围。两者都由一个类型`T`参数化，该类型用于表示其范围的坐标。与之前的向量数学类型一样，在这里，我们将重点关注三维变体#link("<Bounds3>")[Bounds3];，因为#link("<Bounds2>")[Bounds2];实际上是它的一个子集。
]


```cpp
template <typename T>
class Bounds2 {
  public:
    **<<Bounds2 Public Methods>>**       PBRT_CPU_GPU
       Bounds2() {
           T minNum = std::numeric_limits<T>::lowest();
           T maxNum = std::numeric_limits<T>::max();
           pMin = Point2<T>(maxNum, maxNum);
           pMax = Point2<T>(minNum, minNum);
       }
       PBRT_CPU_GPU
       explicit Bounds2(Point2<T> p) : pMin(p), pMax(p) {}
       PBRT_CPU_GPU
       Bounds2(Point2<T> p1, Point2<T> p2)
           : pMin(Min(p1, p2)), pMax(Max(p1, p2)) {}
       template <typename U>
       PBRT_CPU_GPU explicit Bounds2(const Bounds2<U> &b) {
           if (b.IsEmpty())
               // Be careful about overflowing float->int conversions and the
               // like.
               *this = Bounds2<T>();
           else {
               pMin = Point2<T>(b.pMin);
               pMax = Point2<T>(b.pMax);
           }
       }
       PBRT_CPU_GPU
       Vector2<T> Diagonal() const { return pMax - pMin; }
       PBRT_CPU_GPU
       T Area() const {
           Vector2<T> d = pMax - pMin;
           return d.x * d.y;
       }
       PBRT_CPU_GPU
       bool IsEmpty() const { return pMin.x >= pMax.x || pMin.y >= pMax.y; }
       PBRT_CPU_GPU
       bool IsDegenerate() const { return pMin.x > pMax.x || pMin.y > pMax.y; }
       PBRT_CPU_GPU
       int MaxDimension() const {
           Vector2<T> diag = Diagonal();
           if (diag.x > diag.y)
               return 0;
           else
               return 1;
       }
       PBRT_CPU_GPU
       Point2<T> operator[](int i) const {
           DCHECK(i == 0 || i == 1);
           return (i == 0) ? pMin : pMax;
       }
       PBRT_CPU_GPU
       Point2<T> &operator[](int i) {
           DCHECK(i == 0 || i == 1);
           return (i == 0) ? pMin : pMax;
       }
       PBRT_CPU_GPU
       bool operator==(const Bounds2<T> &b) const {
           return b.pMin == pMin && b.pMax == pMax;
       }
       PBRT_CPU_GPU
       bool operator!=(const Bounds2<T> &b) const {
           return b.pMin != pMin || b.pMax != pMax;
       }
       PBRT_CPU_GPU
       Point2<T> Corner(int corner) const {
           DCHECK(corner >= 0 && corner < 4);
           return Point2<T>((*this)[(corner & 1)].x, (*this)[(corner & 2) ? 1 : 0].y);
       }
       PBRT_CPU_GPU
       Point2<T> Lerp(Point2f t) const {
           return Point2<T>(pbrt::Lerp(t.x, pMin.x, pMax.x),
                            pbrt::Lerp(t.y, pMin.y, pMax.y));
       }
       PBRT_CPU_GPU
       Vector2<T> Offset(Point2<T> p) const {
           Vector2<T> o = p - pMin;
           if (pMax.x > pMin.x)
               o.x /= pMax.x - pMin.x;
           if (pMax.y > pMin.y)
               o.y /= pMax.y - pMin.y;
           return o;
       }
       PBRT_CPU_GPU
       void BoundingSphere(Point2<T> *c, Float *rad) const {
           *c = (pMin + pMax) / 2;
           *rad = Inside(*c, *this) ? Distance(*c, pMax) : 0;
       }
       std::string ToString() const { return StringPrintf("[ %s - %s ]", pMin, pMax); }
    **<<Bounds2 Public Members>>**       Point2<T> pMin, pMax;
};
```


```cpp
template <typename T>
class Bounds3 {
  public:
    **<<Bounds3 Public Methods>>**       Bounds3() {
           T minNum = std::numeric_limits<T>::lowest();
           T maxNum = std::numeric_limits<T>::max();
           pMin = Point3<T>(maxNum, maxNum, maxNum);
           pMax = Point3<T>(minNum, minNum, minNum);
       }
       explicit Bounds3(Point3<T> p) : pMin(p), pMax(p) {}
       Bounds3(Point3<T> p1, Point3<T> p2)
           : pMin(Min(p1, p2)), pMax(Max(p1, p2)) {}
       Point3<T> operator[](int i) const { return (i == 0) ? pMin : pMax; }
       Point3<T> &operator[](int i) { return (i == 0) ? pMin : pMax; }
       Point3<T> Corner(int corner) const {
           return Point3<T>((*this)[(corner & 1)].x,
                            (*this)[(corner & 2) ? 1 : 0].y,
                            (*this)[(corner & 4) ? 1 : 0].z);
       }
       Vector3<T> Diagonal() const { return pMax - pMin; }
       T SurfaceArea() const {
           Vector3<T> d = Diagonal();
           return 2 * (d.x * d.y + d.x * d.z + d.y * d.z);
       }
       T Volume() const {
           Vector3<T> d = Diagonal();
           return d.x * d.y * d.z;
       }
       int MaxDimension() const {
           Vector3<T> d = Diagonal();
           if (d.x > d.y && d.x > d.z) return 0;
           else if (d.y > d.z) return 1;
           else return 2;
       }
       Point3f Lerp(Point3f t) const {
           return Point3f(pbrt::Lerp(t.x, pMin.x, pMax.x),
                          pbrt::Lerp(t.y, pMin.y, pMax.y),
                          pbrt::Lerp(t.z, pMin.z, pMax.z));
       }
       Vector3f Offset(Point3f p) const {
           Vector3f o = p - pMin;
           if (pMax.x > pMin.x) o.x /= pMax.x - pMin.x;
           if (pMax.y > pMin.y) o.y /= pMax.y - pMin.y;
           if (pMax.z > pMin.z) o.z /= pMax.z - pMin.z;
           return o;
       }
       void BoundingSphere(Point3<T> *center, Float *radius) const {
           *center = (pMin + pMax) / 2;
           *radius = Inside(*center, *this) ? Distance(*center, pMax) : 0;
       }
       bool IsEmpty() const {
           return pMin.x >= pMax.x || pMin.y >= pMax.y || pMin.z >= pMax.z;
       }
       bool IsDegenerate() const {
           return pMin.x > pMax.x || pMin.y > pMax.y || pMin.z > pMax.z;
       }
       template <typename U>
       PBRT_CPU_GPU explicit Bounds3(const Bounds3<U> &b) {
           if (b.IsEmpty())
               // Be careful about overflowing float->int conversions and the
               // like.
               *this = Bounds3<T>();
           else {
               pMin = Point3<T>(b.pMin);
               pMax = Point3<T>(b.pMax);
           }
       }
       PBRT_CPU_GPU
       bool operator==(const Bounds3<T> &b) const {
           return b.pMin == pMin && b.pMax == pMax;
       }
       PBRT_CPU_GPU
       bool operator!=(const Bounds3<T> &b) const {
           return b.pMin != pMin || b.pMax != pMax;
       }
       PBRT_CPU_GPU
       bool IntersectP(Point3f o, Vector3f d, Float tMax = Infinity,
                       Float *hitt0 = nullptr, Float *hitt1 = nullptr) const;
       PBRT_CPU_GPU
       bool IntersectP(Point3f o, Vector3f d, Float tMax, Vector3f invDir, const int dirIsNeg[3]) const;
       std::string ToString() const { return StringPrintf("[ %s - %s ]", pMin, pMax); }
    **<<Bounds3 Public Members>>**       Point3<T> pMin, pMax;
};
```

#parec[
  We use the same shorthand as before to define names for commonly used bounding types.
][
  我们使用与之前相同的简写来定义常用边界类型的名称。
]

```cpp
using Bounds2f = Bounds2<Float>;
using Bounds2i = Bounds2<int>;
using Bounds3f = Bounds3<Float>;
using Bounds3i = Bounds3<int>;
```

#parec[
  There are a few possible representations for these sorts of bounding boxes; `pbrt` uses #emph[axis-aligned bounding boxes] (AABBs), where the box edges are mutually perpendicular and aligned with the coordinate system axes. Another possible choice is #emph[oriented bounding boxes] (OBBs), where the box edges on different sides are still perpendicular to each other but not necessarily coordinate-system aligned. A 3D AABB can be described by one of its vertices and three lengths, each representing the distance spanned along the $x$, $y$, and $z$ coordinate axes. Alternatively, two opposite vertices of the box can describe it. We chose the two-point representation for `pbrt`'s #link("<Bounds2>")[Bounds2] and #link("<Bounds3>")[Bounds3] classes; they store the positions of the vertex with minimum coordinate values and of the one with maximum coordinate values. A 2D illustration of a bounding box and its representation is shown in @fig:bboxexample .
][
  这些边界框有几种可能的表示方法；`pbrt`使用#emph[轴对齐边界框];（AABB），其中框的边缘相互垂直并与坐标系轴对齐。 另一种可能的选择是#emph[定向边界框];（OBB），其中框的不同边仍然彼此垂直，但不一定与坐标系对齐。 一个三维AABB可以通过其一个顶点和三个长度来 我们为`pbrt`的#link("<Bounds2>")[Bounds2];和#link("<Bounds3>")[Bounds3];类选择了两点表示法；它们存储具有最小坐标值的顶点和具有最大坐标值的顶点的位置。 @fig:bboxexample 展示了边界框及其表示的二维插图。
]


```cpp
Point3<T> pMin, pMax;
```

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f09.svg"),
  caption: [
    #ez_caption[An Axis-Aligned Bounding Box.][轴对齐边界框。]
  ],
)<bboxexample>

#parec[
  The default constructors create an empty box by setting the extent to an invalid configuration, which violates the invariant that `pMin.x <= pMax.x` (and similarly for the other dimensions). By initializing two corner points with the largest and smallest representable number, any operations involving an empty box (e.g., `Union()`) will yield the correct result.
][
  默认构造函数通过将范围设置为无效配置来创建一个空的box，这违反了以下条件： `pMin.x <= pMax.x` （对于其他维度也类似）。通过用最大和最小可表示数初始化两个角点，任何涉及空框的操作（例如， `Union()` ）将产生正确的结果。
]

```cpp
// <<Bounds3 Public Methods>>=
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
  能够初始化仅包含单个点的边界也很有用：
]

```cpp
// <<Bounds3 Public Methods>>+=
explicit Bounds3(Point3<T> p) : pMin(p), pMax(p) {}
```

#parec[
  If the caller passes two corner points (p1 and p2) to define the box, the constructor needs to find their component-wise minimum and maximum values since it is not necessarily the case that p1.x <= p2.x, and so on.
][
  如果调用者经过两个角点（ p1 和 p2 ）为了定义盒子，构造函数需要找到它们的组件方面的最小值和最大值，因为不一定是这样的情况 `p1.x <= p2.x` ， 等等。
]
```cpp
<<Bounds3 Public Methods>>+=
Bounds3(Point3<T> p1, Point3<T> p2)
    : pMin(Min(p1, p2)), pMax(Max(p1, p2)) {}
```

#parec[
  It can be useful to use array indexing to select between the two points at the corners of the box. Assertions in the debug build, not shown here, check that the provided index is either 0 or 1.
][
  使用数组索引在框角的两个点之间进行选择可能很有用。调试版本中的断言（此处未显示）检查提供的索引是否为 0 或 1。
]

```cpp
// <<Bounds3 Public Methods>>+=
Point3<T> operator[](int i) const { return (i == 0) ? pMin : pMax; }
Point3<T> &operator[](int i) { return (i == 0) ? pMin : pMax; }
```

#parec[
  The `Corner()` method returns the coordinates of one of the eight corners of the bounding box. Its logic calls the `operator[]` method with a zero or one value for each dimension that is based on one of the low three bits of corner and then extracts the corresponding component. It is worthwhile to verify that this method returns the positions of all eight corners when passed values from 0 to 7 if that is not immediately evident.
][
  这 `Corner()` 方法返回边界框八个角之一的坐标。其逻辑称为 `operator[]` 方法，每个维度具有零或一个值，该值基于低三位之一 `corner` 然后提取相应的成分。值得验证的是，当传递 0 到 7 之间的值时，此方法是否返回所有八个角的位置（如果这不是立即显而易见的）。
]

```cpp
// <<Bounds3 Public Methods>>+=
Point3<T> Corner(int corner) const {
    return Point3<T>((*this)[(corner & 1)].x,
                     (*this)[(corner & 2) ? 1 : 0].y,
                     (*this)[(corner & 4) ? 1 : 0].z);
}
```

#parec[
  Given a bounding box and a point, the Union() function returns a new bounding box that encompasses that point as well as the original bounds.
][
  给定一个边界框和一个点， Union() 函数返回一个包含该点以及原始边界的新边界框。
]

```cpp
// <<Bounds3 Inline Functions>>=
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
  适用于此功能和以下某些功能的一个微妙之处是，重要的是 pMin 和 pMax 的成员 ret 直接在这里设置，而不是传递返回的值 Min() 和 Max() 到 Bounds3 构造函数。细节源于这样一个事实：如果提供的边界都是退化的，则返回的边界也应该是退化的。如果将退化范围传递给构造函数，那么它将对坐标值进行排序，这反过来又导致本质上是无限界限。
]
#parec[
  It is similarly possible to construct a new box that bounds the space encompassed by two other bounding boxes. The definition of this function is similar to the earlier Union() method that takes a Point3f; the difference is that the pMin and pMax of the second box are used for the Min() and Max() tests, respectively.
][
  同样可以构造一个新的框来限制其他两个边界框所包围的空间。这个函数的定义和前面的类似 Union() 方法需要一个;区别在于 pMin 和 pMax 第二个盒子的用于 Min() 和 Max() 分别进行测试。
]

```cpp
// <<Bounds3 Inline Functions>>+=
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
  两个边界框的交集可以通过计算它们各自的两个最小坐标的最大值和它们的最大坐标的最小值来找到。 （见@fig:bbox-intersection ）
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f10.svg"),
  caption: [
    #ez_caption[_Intersection of Two Bounding Boxes._ Given two bounding boxes with pMin and pMax points denoted by open circles, the bounding box of their area of intersection (shaded region) has a minimum point (lower left filled circle) with coordinates given by the maximum of the coordinates of the minimum points of the two boxes in each dimension. Similarly, its maximum point (upper right filled circle) is given by the minimums of the boxes’ maximum coordinates.][_两个边界框的交集。_给定两个边界框 pMin 和 pMax 由空心圆表示的点，其相交区域（阴影区域）的边界框有一个最小点（左下实心圆），其坐标由每个维度中两个框的最小点的坐标的最大值给出。类似地，它的最大点（右上角的实心圆）由框的最大坐标的最小值给出。]
  ],
)<bbox-intersection>

```cpp
// <<Bounds3 Inline Functions>>+=
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
  我们还可以通过查看两个bouding box的xyz坐标区间是否重叠来确定它们是否重叠：
]

```cpp
// <<Bounds3 Inline Functions>>+=
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
  三个一维包含测试确定给定点是否在边界框内。
]

```cpp
// <<Bounds3 Inline Functions>>+=
template <typename T>
bool Inside(Point3<T> p, const Bounds3<T> &b) {
    return (p.x >= b.pMin.x && p.x <= b.pMax.x &&
            p.y >= b.pMin.y && p.y <= b.pMax.y &&
            p.z >= b.pMin.z && p.z <= b.pMax.z);
}
```

#parec[
  `DistanceSquared()` returns the squared distance from a point to a bounding box or zero if the point is inside it. The geometric setting of the computation is shown in @point-aabb-distance. After the distance from the point to the box is computed in each dimension, the squared distance is found by summing the squares of each of the 1D distances.
][
  `DistanceSquared()` 返回从点到边界框的平方距离；如果该点位于边界框内，则返回零。计算的几​​何设置如@point-aabb-distance 所示。在每个维度上计算出点到框的距离后，通过将每个一维距离的平方相加得出平方距离。
]
#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f10.svg"),
  caption: [
    #ez_caption[Computing the Squared Distance from a Point to an Axis-Aligned Bounding Box. We first find the distance from the point to the box in each dimension. Here, the point represented by an empty circle on the upper left is above to the left of the box, so its and distances are respectively pMin.x - p.x and pMin.y - p.y. The other point represented by an empty circle is to the right of the box but overlaps its extent in the dimension, giving it respective distances of p.x - pMax.x and zero. The logic in Bounds3::DistanceSquared() computes these distances by finding the maximum of zero and the distances to the minimum and maximum points in each dimension.][图 3.11：计算从点到轴对齐边界框的平方距离。我们首先求出每个维度中点到盒子的距离。这里，左上角的空圆圈表示的点位于框的左侧上方，因此它的 和 距离分别为 pMin.x - px 和 pMin.y - py 另一个空圆圈表示的点是到位于框的右侧，但在维度上重叠其范围，使其各自的距离为 px - pMax.x 和零。 Bounds3::DistanceSquared() 中的逻辑通过查找零的最大值以及到每个维度中最小和最大点的距离来计算这些距离。]
  ],
)<point-aabb-distance>
```cpp
<<Bounds3 Inline Functions>>+=
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
  计算从点到边界框的距离很容易，尽管需要一些间接方法才能确定正确的返回类型。
]

```cpp
<<Bounds3 Inline Functions>>+=
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
  这 Expand() 函数在所有维度上按常数因子填充边界框。
]

```cpp
<<Bounds3 Inline Functions>>+=
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
  Diagonal() 返回沿盒子对角线从最小点到最大点的向量。
]

```cpp
<<Bounds3 Public Methods>>+=
Vector3<T> Diagonal() const { return pMax - pMin; }
```

#parec[
  Methods for computing the surface area of the six faces of the box and the volume inside of it are also useful. (This is a place where Bounds2 and Bounds3 diverge: these methods are not available in Bounds2, though it does have an Area() method.)
][
  计算盒子六个面的表面积及其内部体积的方法也很有用。 （这是一个地方 Bounds2 和 Bounds3 分歧：这些方法不适用于 Bounds2 ，虽然它确实有一个 Area() 方法。）
]

```cpp
<<Bounds3 Public Methods>>+=
T SurfaceArea() const {
    Vector3<T> d = Diagonal();
    return 2 * (d.x * d.y + d.x * d.z + d.y * d.z);
}
<<Bounds3 Public Methods>>+=
T Volume() const {
    Vector3<T> d = Diagonal();
    return d.x * d.y * d.z;
}
```

#parec[
  The Bounds3::MaxDimension() method returns the index of which of the three axes is longest. This is useful, for example, when deciding which axis to subdivide when building some of the ray-intersection acceleration structures.
][
  这方法返回三个轴中最长的索引。例如，在构建某些射线相交加速结构时决定细分哪个轴时，这很有用。
]

```cpp
<<Bounds3 Public Methods>>+=
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
  Lerp() 在盒子的角之间按每个维度的给定量进行线性插值。
]

```cpp
<<Bounds3 Public Methods>>+=
Point3f Lerp(Point3f t) const {
    return Point3f(pbrt::Lerp(t.x, pMin.x, pMax.x),
                   pbrt::Lerp(t.y, pMin.y, pMax.y),
                   pbrt::Lerp(t.z, pMin.z, pMax.z));
}
```

#parec[
  Offset() is effectively the inverse of Lerp(). It returns the continuous position of a point relative to the corners of the box, where a point at the minimum corner has offset , a point at the maximum corner has offset , and so forth.
][
  Offset() 实际上是 Lerp() 。它返回点相对于框角的连续位置，其中最小角处的点有偏移 ，最大角点处有偏移 ，等等。
]

```cpp
<<Bounds3 Public Methods>>+=
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
  Bounds3 还提供了返回包围边界框的球体的中心和半径的方法。一般来说，这可能比限制原始内容的球体松散得多。直接，尽管对于某些几何运算，使用球体比使用盒子更容易，在这种情况下，最差的拟合可能是可以接受的权衡。
]


```cpp
<<Bounds3 Public Methods>>+=
void BoundingSphere(Point3<T> *center, Float *radius) const {
    *center = (pMin + pMax) / 2;
    *radius = Inside(*center, *this) ? Distance(*center, pMax) : 0;
}
```


#parec[
  Straightforward methods test for empty and degenerate bounding boxes. Note that “empty” means that a bounding box has zero volume but does not necessarily imply that it has zero surface area.
][
  简单的方法测试空的和简并的边界框。请注意，“空”意味着边界框的体积为零，但不一定意味着它的表面积为零。
]


```cpp
<<Bounds3 Public Methods>>+=
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
  最后，对于整数界限，有一个迭代器类可以满足 C++ 前向迭代器的要求（即，它只能前进）。细节稍显繁琐，也不是特别有趣，所以书中没有包含代码。有了这个定义，就可以使用基于范围的代码编写代码 for 循环迭代边界框中的整数坐标：
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
  在实现时，迭代会达到但不会访问等于每个维度的最大范围的点。
]