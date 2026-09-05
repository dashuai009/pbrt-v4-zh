#import "../template.typ": parec, ez_caption

== #ez_caption[Normals][法向量]
<normals>
#parec[
  A #emph[surface normal] (or just #emph[normal]) is a vector that is perpendicular to a surface at a particular position. It can be defined as the cross product of any two nonparallel vectors that are tangent to the surface at a point. Although normals are superficially similar to vectors, it is important to distinguish between the two of them: because normals are defined in terms of their relationship to a particular surface, they behave differently than vectors in some situations, particularly when applying transformations. (That difference is discussed in Section #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Applying_Transformations.html#sec:applying-transforms")[3.10].)
][
  #emph[表面法向量]（或简称#emph[法向量]）是一个在特定位置垂直于表面的向量。它可以定义为在某一点上与表面相切的任意两个不平行向量的叉积。虽然从表面上看法向量与向量相似，但重要的是要区分两者：因为法向量是根据它们与特定表面的关系定义的，所以在某些情况下它们的行为与向量不同，特别是在应用变换时。（这种区别在第#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Applying_Transformations.html#sec:applying-transforms")[3.10] 节中讨论。）
]


#block(sticky: true)[#raw("<<Normal3 Definition>>=") #link(<fragment-Normal3Definition-1>)[▼]] <fragment-Normal3Definition-0>
```cpp
template <typename T>
class Normal3 : public Tuple3<Normal3, T> {
  public:
    <<Normal3 Public Methods>>
};
``` <Normal3>

#block(sticky: true)[#raw("<<Normal3 Definition>>+=") #link(<fragment-Normal3Definition-0>)[▲]] <fragment-Normal3Definition-1>
```cpp
using Normal3f = Normal3<Float>;
```

#parec[
  The implementations of `Normal3`s and `Vector3`s are very similar. Like vectors, normals are represented by three components `x`, `y`, and `z`; they can be added and subtracted to compute new normals; and they can be scaled and normalized. However, a normal cannot be added to a point, and one cannot take the cross product of two normals. Note that, in an unfortunate turn of terminology, normals are not necessarily normalized.
][
  `Normal3` 与 `Vector3` 的实现十分相似。法向量同样用三个分量 `x`、`y` 和 `z` 表示；它们可以相加、相减得到新的法向量，也可以缩放和归一化。不过，法向量不能与点相加，也不能对两个法向量求叉积。术语容易引起混淆，需要注意：法向量并不一定已经归一化。
]

#parec[
  In addition to the usual constructors (not included here), `Normal3` allows conversion from `Vector3` values given an explicit typecast, similarly to the other Tuple2- and Tuple3-based classes.
][
  除常规构造函数（此处未列出）外，`Normal3` 还允许通过显式类型转换从 `Vector3` 值构造，与其他基于 `Tuple2` 和 `Tuple3` 的类类似。
]

#block(sticky: true)[#raw("<<Normal3 Public Methods>>=")] <fragment-Normal3PublicMethods-0>
```cpp
template <typename U>
explicit Normal3<T>(Vector3<U> v)
    : Tuple3<pbrt::Normal3, T>(T(v.x), T(v.y), T(v.z)) {}
```
#parec[
  The `Dot()` and `AbsDot()` functions are also overloaded to compute dot products between the various possible combinations of normals and vectors. This code will not be included in the text here. We also will not include implementations of all the various other `Normal3` methods here, since they are similar to those for vectors.
][
  `Dot()` 和 `AbsDot()` 也提供了重载，用于计算法向量与向量各种组合的点积。这里不列出这些代码，也不列出 `Normal3` 的其他方法，因为它们与向量的相应实现类似。
]

#parec[
  One new operation to implement comes from the fact that it is often necessary to flip a surface normal so it lies in the same hemisphere as a given vector—for example, the surface normal that lies in the same hemisphere as a ray leaving a surface is frequently needed. The `FaceForward()` utility function encapsulates this small computation. (pbrt also provides variants of this function for the other three combinations of Vector3s and Normal3s as parameters.) Be careful when using the other instances, though: when using the version that takes two Vector3s, for example, ensure that the first parameter is the one that should be returned (possibly flipped) and the second is the one to test against. Reversing the two parameters will give unexpected results.
][
  另一个需要实现的操作是翻转表面法向量，使其与给定向量位于同一半球。例如，我们经常需要与离开表面的光线位于同一半球的表面法向量。`FaceForward()` 实用函数封装了这一简单计算。（`pbrt` 还为 `Vector3` 与 `Normal3` 作为参数的其他三种组合提供了变体。）使用这些重载时需要注意参数顺序：例如，两个参数均为 `Vector3` 时，第一个参数是要返回的向量（可能翻转），第二个则用于判断是否翻转。颠倒参数会得到意料之外的结果。
]


#block(sticky: true)[#raw("<<Normal3 Inline Functions>>=")] <fragment-Normal3InlineFunctions-0>
```cpp
template <typename T>
Normal3<T> FaceForward(Normal3<T> n, Vector3<T> v) {
    return (Dot(n, v) < 0.f) ? -n : n;
}
```


#heading(level: 3, numbering: none)[#ez_caption[Supplement: Additional Code in the Original Collapsed Panels][补充：原网页折叠面板中的额外代码]]
#include "supplements/3.5-expanded.typ"
