#import "../template.typ": parec

== Normals
<normals>
#parec[
  A #emph[surface normal] (or just #emph[normal];) is a vector that is perpendicular to a surface at a particular position. It can be defined as the cross product of any two nonparallel vectors that are tangent to the surface at a point. Although normals are superficially similar to vectors, it is important to distinguish between the two of them: because normals are defined in terms of their relationship to a particular surface, they behave differently than vectors in some situations, particularly when applying transformations. (That difference is discussed in Section~#link("../Geometry_and_Transformations/Applying_Transformations.html#sec:applying-transforms")[3.10];.)
][
  #emph[表面法线];（或简称#emph[法线];）是一个在特定位置垂直于表面的向量。它可以定义为在某一点上与表面相切的任意两个不平行向量的叉积。虽然从表面上看法线与向量相似，但重要的是要区分两者：因为法线是根据它们与特定表面的关系定义的，所以在某些情况下它们的行为与向量不同，特别是在应用变换时。（这种区别在第#link("../Geometry_and_Transformations/Applying_Transformations.html#sec:applying-transforms")[3.10];节中讨论。）
]


```cpp
template <typename T>
class Normal3 : public Tuple3<Normal3, T> {
  public:
    <<Normal3 Public Methods>>
       using Tuple3<Normal3, T>::x;
       using Tuple3<Normal3, T>::y;
       using Tuple3<Normal3, T>::z;
       using Tuple3<Normal3, T>::HasNaN;
       using Tuple3<Normal3, T>::operator+;
       using Tuple3<Normal3, T>::operator*;
       using Tuple3<Normal3, T>::operator*=;

       Normal3() = default;
       PBRT_CPU_GPU
       Normal3(T x, T y, T z) : Tuple3<pbrt::Normal3, T>(x, y, z) {}
       template <typename U>
       PBRT_CPU_GPU explicit Normal3<T>(Normal3<U> v)
           : Tuple3<pbrt::Normal3, T>(T(v.x), T(v.y), T(v.z)) {}
       template <typename U>
       explicit Normal3<T>(Vector3<U> v)
           : Tuple3<pbrt::Normal3, T>(T(v.x), T(v.y), T(v.z)) {}
};
```

```cpp
<<Normal3 Definition>>+=
  using Normal3f = Normal3;
```

#parec[
  The implementations of Normal3s and Vector3s are very similar. Like vectors, normals are represented by three components x, y, and z; they can be added and subtracted to compute new normals; and they can be scaled and normalized. However, a normal cannot be added to a point, and one cannot take the cross product of two normals. Note that, in an unfortunate turn of terminology, normals are not necessarily normalized.
][
  `Normal3s`的实现和`Vector3` 非常相似。与向量一样，法线由三个分量表示 x , y ， 和 z ;可以将它们相加或相减来计算新的法线；并且它们可以被缩放和标准化。但是，无法将法线添加到一点，也无法计算两个法线的叉积。请注意，不幸的是，在术语上，法线不一定是标准化的。
]

#parec[
  In addition to the usual constructors (not included here), Normal3 allows conversion from Vector3 values given an explicit typecast, similarly to the other Tuple2- and Tuple3-based classes.
][
  除了通常的构造函数（这里不包括）之外， Normal3 允许转换自 Vector3 给定显式类型转换的值，与其他类似 Tuple2 - 和 Tuple3 为基础类。
]

```cpp
<<Normal3 Public Methods>>=
template <typename U>
explicit Normal3<T>(Vector3<U> v)
    : Tuple3<pbrt::Normal3, T>(T(v.x), T(v.y), T(v.z)) {}
```
#parec[
  The Dot() and AbsDot() functions are also overloaded to compute dot products between the various possible combinations of normals and vectors. This code will not be included in the text here. We also will not include implementations of all the various other Normal3 methods here, since they are similar to those for vectors.
][
  这 Dot() 和 AbsDot() 函数也被重载以计算法线和向量的各种可能组合之间的点积。该代码不会包含在此处的文本中。我们也不会包括所有其他各种的实现 Normal3 这里的方法，因为它们与向量的方法类似。
]

#parec[
  One new operation to implement comes from the fact that it is often necessary to flip a surface normal so it lies in the same hemisphere as a given vector—for example, the surface normal that lies in the same hemisphere as a ray leaving a surface is frequently needed. The FaceForward() utility function encapsulates this small computation. (pbrt also provides variants of this function for the other three combinations of Vector3s and Normal3s as parameters.) Be careful when using the other instances, though: when using the version that takes two Vector3s, for example, ensure that the first parameter is the one that should be returned (possibly flipped) and the second is the one to test against. Reversing the two parameters will give unexpected results.
][
  要实现的一项新操作来自这样一个事实，即通常需要翻转表面法线，使其与给定向量位于同一半球内，例如，与离开表面的光线位于同一半球内的表面法线为经常需要。这 FaceForward() 实用函数封装了这个小计算。 （ pbrt 还为其他三种组合提供了该函数的变体 Vector3 沙 Normal3 s 作为参数。）不过，在使用其他实例时要小心：当使用需要两个实例的版本时 Vector3 例如，确保第一个参数是应该返回的参数（可能翻转），第二个参数是要测试的参数。颠倒这两个参数将会产生意想不到的结果。
]


```cpp
<<Normal3 Inline Functions>>=
template <typename T>
Normal3<T> FaceForward(Normal3<T> n, Vector3<T> v) {
    return (Dot(n, v) < 0.f) ? -n : n;
}
```
