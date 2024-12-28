#import "../template.typ": parec, ez_caption

== Points

#parec[
  A point is a zero-dimensional location in 2D or 3D space. The `Point2` and #link("<Point3>")[`Point3`] classes in `pbrt` represent points in the obvious way: using $z,y,z$ (in 3D) coordinates with respect to a coordinate system. Although the same representation is used for vectors, the fact that a point represents a position whereas a vector represents a direction leads to a number of important differences in how they are treated. Points are denoted in text by $p$.
][
  一个点是二维或三维空间中的零维位置。在 `pbrt` 中，`Point2` 和 #link("<Point3>")[`Point3`] 类以直观的方式表示点：使用相对于坐标系的 $z,y,z$ （在三维中）坐标。尽管向量使用相同的表示方式，但由于点表示位置而向量表示方向，这导致它们在处理方式上有许多重要的区别。文本中的点用 $p$ 表示。
]

#parec[
  In this section, we will continue the approach of only including implementations of the 3D point methods for the `Point3` class here.
][
  在本节中，我们将继续只在此处展示 `Point3` 类的三维点方法的实现。
]

```cpp
<<Point3 Definition>>=
template <typename T>
class Point3 : public Tuple3<Point3, T> {
  public:
    <<Point3 Public Methods>>
};
```

#parec[
  As with vectors, it is helpful to have shorter type names for commonly used point types.
][
  与向量一样，为常用的点类型使用更短的类型名称是有益的。
]

```
// <<Point3* Definitions>>=
using Point3f = Point3<Float>;
using Point3i = Point3<int>;
```

#parec[
  It is also useful to be able to convert a point with one element type (e.g., a `Point3f`) to a point of another one (e.g., `Point3i`) as well as to be able to convert a point to a vector with a different underlying element type. The following constructor and conversion operator provide these conversions. Both also require an explicit cast, to make it clear in source code when they are being used.
][
  能够将一种元素类型的点（例如，`Point3f`）转换为另一种类型的点（例如，`Point3i`），以及能够将点转换为具有不同底层元素类型的向量也是很有用的。以下构造函数和转换操作符提供了这些转换。两者都需要显式转换，以便在源代码中清楚地表明何时使用它们。
]

```cpp
<<Point3 Public Methods>>=
template <typename U>
explicit Point3(Point3<U> p)
    : Tuple3<pbrt::Point3, T>(T(p.x), T(p.y), T(p.z)) {}
template <typename U>
explicit Point3(Vector3<U> v)
    : Tuple3<pbrt::Point3, T>(T(v.x), T(v.y), T(v.z)) {}
```

#parec[
  There are certain #link("<Point3>")[`Point3`] methods that either return or take a #link("../Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`];. For instance, one can add a vector to a point, offsetting it in the given direction to obtain a new point. Analogous methods, not included in the text, also allow subtracting a vector from a point.
][
  某些 #link("<Point3>")[`Point3`] 方法要么返回要么接受一个 #link("../Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`];。例如，可以将一个向量添加到一个点上，沿给定方向偏移以获得一个新点。类似的方法（未在文本中包含）也允许从一个点中减去一个向量。
]

```cpp
<<Point3 Public Methods>>+=
template <typename U>
auto operator+(Vector3<U> v) const -> Point3<decltype(T{} + U{})> {
    return {x + v.x, y + v.y, z + v.z};
}
template <typename U>
Point3<T> &operator+=(Vector3<U> v) {
    x += v.x;    y += v.y;    z += v.z;
    return *this;
}
```

#parec[
  Alternately, one can subtract one point from another, obtaining the vector between them, as shown in @fig:pointsub .
][
  或者，可以从一个点减去另一个点，得到它们之间的向量，如@fig:pointsub 所示。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f07.svg"),
  caption: [
    #ez_caption[
      Obtaining the Vector between Two Points
    ][
      获取两个点之间的向量
    ]
  ],
) <pointsub>

```cpp
<<Point3 Public Methods>>+=
template <typename U>
auto operator-(Point3<U> p) const -> Vector3<decltype(T{} - U{})> {
    return {x - p.x, y - p.y, z - p.z};
}
```


#parec[
  The distance between two points can be computed by subtracting them to compute the vector between them and then finding the length of that vector. Note that we can just use auto for the return type and let it be set according to the return type of Length(); there is no need to use the TupleLength type trait to find that type.
][
  两点之间的距离可以通过减去它们来计算它们之间的向量，然后找到该向量的长度来计算。请注意，我们可以只使用 auto 对于返回类型并让它根据返回类型设置 Length() ;没有必要使用 TupleLength 输入特征来查找该类型。
]

#parec[
  The squared distance between two points can be similarly computed using LengthSquared().
][
  两点之间的平方距离可以类似地计算为 LengthSquared() 。
]
```cpp
// <<Point3 Inline Functions>>+=
template <typename T>
auto DistanceSquared(Point3<T> p1, Point3<T> p2) {
    return LengthSquared(p1 - p2);
}
```