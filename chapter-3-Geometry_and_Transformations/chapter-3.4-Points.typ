#import "../template.typ": parec, ez_caption, translator

== #ez_caption[Points][点]

#parec[
  A point is a zero-dimensional location in 2D or 3D space. The `Point2` and #link(<Point3>)[`Point3`] classes in `pbrt` represent points in the obvious way: using $x,y,z$ (in 3D) coordinates with respect to a coordinate system. Although the same representation is used for vectors, the fact that a point represents a position whereas a vector represents a direction leads to a number of important differences in how they are treated. Points are denoted in text by $p$.
][
  一个点是二维或三维空间中的零维位置。在 `pbrt` 中，`Point2` 和 #link(<Point3>)[`Point3`] 类以直观的方式表示点：使用相对于坐标系的 $x,y,z$ （在三维中）坐标。尽管向量使用相同的表示方式，但由于点表示位置而向量表示方向，这导致它们在处理方式上有许多重要的区别。文本中的点用 $p$ 表示。
]

#parec[
  In this section, we will continue the approach of only including implementations of the 3D point methods for the `Point3` class here.
][
  在本节中，我们将继续只在此处展示 `Point3` 类的三维点方法的实现。
]

#block(sticky: true)[#raw("<<Point3 Definition>>=")] <fragment-Point3Definition-0>
```cpp
template <typename T>
class Point3 : public Tuple3<Point3, T> {
  public:
    <<Point3 Public Methods>>
};
``` <Point3>

#parec[
  As with vectors, it is helpful to have shorter type names for commonly used point types.
][
  与向量一样，为常用的点类型使用更短的类型名称是有益的。
]

#block(sticky: true)[#raw("<<Point3* Definitions>>=")] <fragment-Point3Definitions-0>
```cpp
using Point3f = Point3<Float>;
using Point3i = Point3<int>;
```

#parec[
  It is also useful to be able to convert a point with one element type (e.g., a `Point3f`) to a point of another one (e.g., `Point3i`) as well as to be able to convert a point to a vector with a different underlying element type. The following constructor and conversion operator provide these conversions. Both also require an explicit cast, to make it clear in source code when they are being used.
][
  能够将一种元素类型的点（例如，`Point3f`）转换为另一种类型的点（例如，`Point3i`），以及能够将点转换为具有不同底层元素类型的向量也是很有用的。以下构造函数和转换运算符提供了这些转换。两者都需要显式转换，以便在源代码中清楚地表明何时使用它们。
]

#block(sticky: true)[#raw("<<Point3 Public Methods>>=") #link(<fragment-Point3PublicMethods-1>)[▼]] <fragment-Point3PublicMethods-0>
```cpp
template <typename U>
explicit Point3(Point3<U> p)
    : Tuple3<pbrt::Point3, T>(T(p.x), T(p.y), T(p.z)) {}
template <typename U>
explicit Point3(Vector3<U> v)
    : Tuple3<pbrt::Point3, T>(T(v.x), T(v.y), T(v.z)) {}
```

#parec[
  There are certain #link(<Point3>)[`Point3`] methods that either return or take a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`]. For instance, one can add a vector to a point, offsetting it in the given direction to obtain a new point. Analogous methods, not included in the text, also allow subtracting a vector from a point.
][
  某些 #link(<Point3>)[`Point3`] 方法要么返回要么接受一个 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`]。例如，可以将一个向量加到一个点上，沿给定方向偏移以获得一个新点。类似的方法（未在文本中包含）也允许从一个点中减去一个向量。
]

#block(sticky: true)[#raw("<<Point3 Public Methods>>+=") #link(<fragment-Point3PublicMethods-0>)[▲] #link(<fragment-Point3PublicMethods-2>)[▼]] <fragment-Point3PublicMethods-1>
```cpp
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
      Obtaining the Vector between Two Points. The vector $upright(bold(v)) = p' - p$ is given by the component-wise subtraction of the points $p'$ and $p$.
    ][
      求两点之间的向量。向量 $upright(bold(v)) = p' - p$ 由点 $p'$ 与 $p$ 的对应分量相减得到。
    ]
  ],
) <pointsub>

#block(sticky: true)[#raw("<<Point3 Public Methods>>+=") #link(<fragment-Point3PublicMethods-1>)[▲]] <fragment-Point3PublicMethods-2>
```cpp
template <typename U>
auto operator-(Point3<U> p) const -> Vector3<decltype(T{} - U{})> {
    return {x - p.x, y - p.y, z - p.z};
}
```


#parec[
  The distance between two points can be computed by subtracting them to compute the vector between them and then finding the length of that vector. Note that we can just use `auto` for the return type and let it be set according to the return type of `Length()`; there is no need to use the `TupleLength` type trait to find that type.
][
  计算两点之间的距离时，先将两点相减，得到它们之间的向量，再求该向量的长度即可。返回类型可以直接写成 `auto`，让它根据 `Length()` 的返回类型推导，无需用 `TupleLength` 类型特征来确定。
]

#block(sticky: true)[#raw("<<Point3 Inline Functions>>=") #link(<fragment-Point3InlineFunctions-1>)[▼]] <fragment-Point3InlineFunctions-0>
```cpp
template <typename T>
auto Distance(Point3<T> p1, Point3<T> p2) { return Length(p1 - p2); }
```


#parec[
  The squared distance between two points can be similarly computed using `LengthSquared()`.
][
  两点之间的平方距离可以类似地通过 `LengthSquared()` 计算。
]
#block(sticky: true)[#raw("<<Point3 Inline Functions>>+=") #link(<fragment-Point3InlineFunctions-0>)[▲]] <fragment-Point3InlineFunctions-1>
```cpp
template <typename T>
auto DistanceSquared(Point3<T> p1, Point3<T> p2) {
    return LengthSquared(p1 - p2);
}
```
#parec[][
  #translator[固定原书的转换说明写作“点转为向量”以及“构造函数和转换运算符”，但下面展示的是两个构造函数，第二个从向量构造点。此处保留原文和代码，差异待统一核实。]
]


#heading(level: 3, numbering: none)[#ez_caption[Supplement: Additional Code in the Original Collapsed Panels][补充：原网页折叠面板中的额外代码]]
#include "supplements/3.4-expanded.typ"
