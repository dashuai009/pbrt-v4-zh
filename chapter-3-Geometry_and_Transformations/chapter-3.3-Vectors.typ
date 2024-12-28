#import "../template.typ": parec, ez_caption

== Vectors

#parec[
  `pbrt` provides both 2D and 3D vector classes that are based on the corresponding two- and three-dimensional tuple classes. Both vector types are themselves parameterized by the type of the underlying vector element, thus making it easy to instantiate vectors of both integer and floating-point types.
][
  `pbrt` 提供了基于相应二维和三维元组类的二维和三维向量类。两种向量类型都通过底层向量元素的类型进行参数化，因此可以轻松实例化整数和浮点类型的向量。
]


```cpp
template <typename T>
class Vector2 : public Tuple2<Vector2, T> {
  public:
    // <<Vector2 公共方法>>
       using Tuple2<Vector2, T>::x;
       using Tuple2<Vector2, T>::y;
       Vector2() = default;
       Vector2(T x, T y) : Tuple2<pbrt::Vector2, T>(x, y) {}
       template <typename U>
       explicit Vector2(Point2<U> p);
       template <typename U>
       explicit Vector2(Vector2<U> v)
           : Tuple2<pbrt::Vector2, T>(T(v.x), T(v.y)) {}
};
```

#parec[
  Two-dimensional vectors of `Float`s and integers are widely used, so we will define aliases for those two types.
][
  `Float` 和整数的二维向量被广泛使用，因此我们将为这两种类型定义别名。
]

```cpp
using Vector2f = Vector2<Float>;
using Vector2i = Vector2<int>;
```

#parec[
  As with #link("../Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple2")[Tuple2];, we will not include any further details of #link("<Vector2>")[Vector2] since it is very similar to #link("<Vector3>")[Vector3];, which we will discuss in more detail.
][
  与 #link("../Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple2")[Tuple2] 类似，我们不会包含 #link("<Vector2>")[Vector2] 的更多细节，因为它与我们将更详细讨论的 #link("<Vector3>")[Vector3] 非常相似。
]

#parec[
  A `Vector3`'s tuple of component values gives its representation in terms of the $x$, $y$, and $z$ (in 3D) axes of the space it is defined in. The individual components of a 3D vector $bold(v)$ will be written $bold(v)_x, bold(v)_y$ and $bold(v)_z$.
][
  `Vector3` 的组件值元组表示其在定义空间中的 $x$, $y$, and $z$ （在 3D 中）轴上的表示。三维向量 $bold(v)$ 的各个组件将写为 $bold(v)_x, bold(v)_y$ and $bold(v)_z$。
]

```cpp
template <typename T>
class Vector3 : public Tuple3<Vector3, T> {
  public:
    //  <<Vector3 Public Methods>>
       using Tuple3<Vector3, T>::x;
       using Tuple3<Vector3, T>::y;
       using Tuple3<Vector3, T>::z;
       Vector3(T x, T y, T z) : Tuple3<pbrt::Vector3, T>(x, y, z) {}
       template <typename U>
       explicit Vector3(Vector3<U> v)
           : Tuple3<pbrt::Vector3, T>(T(v.x), T(v.y), T(v.z)) {}
       template <typename U>
       explicit Vector3(Point3<U> p);
       template <typename U>
       explicit Vector3(Normal3<U> n);
};
```


#parec[
  We also define type aliases for two commonly used three-dimensional vector types.
][
  我们还为两种常用的三维向量类型定义了类型别名。
]

```cpp
// <<Vector3* Definitions>>=
using Vector3f = Vector3<Float>;
using Vector3i = Vector3<int>;
```

#parec[
  `Vector3` provides a few constructors, including a default constructor (not shown here) and one that allows specifying each component value directly.
][
  `Vector3` 提供了一些构造函数，包括一个默认构造函数（此处未显示）和一个允许直接指定每个组件值的构造函数。
]

```cpp
Vector3(T x, T y, T z) : Tuple3<pbrt::Vector3, T>(x, y, z) {}
```


#parec[
  There is also a constructor that takes a `Vector3` with a different element type. It is qualified with `explicit` so that it is not unintentionally used in automatic type conversions; a cast must be used to signify the intent of the type conversion.
][
  还有一个构造函数接受具有不同元素类型的 `Vector3`。它用 `explicit` 限定，以防止在自动类型转换中不小心使用；必须使用强制转换来表示类型转换的意图。
]

```cpp
template <typename U>
explicit Vector3(Vector3<U> v)
    : Tuple3<pbrt::Vector3, T>(T(v.x), T(v.y), T(v.z)) {}
```

#parec[
  Finally, constructors are provided to convert from the forthcoming #link("../Geometry_and_Transformations/Points.html#Point3")[Point3] and #link("../Geometry_and_Transformations/Normals.html#Normal3")[Normal3] types. Their straightforward implementations are not included here. These, too, are `explicit` to help ensure that they are only used in situations where the conversion is meaningful.
][
  最后，提供了从即将到来的 #link("../Geometry_and_Transformations/Points.html#Point3")[Point3] 和 #link("../Geometry_and_Transformations/Normals.html#Normal3")[Normal3] 类型进行转换的构造函数。它们的简单实现此处未包含。这些构造函数也是 `explicit` 的，以帮助确保它们仅在转换有意义的情况下使用。
]

```cpp
// <<Vector3 Public Methods>>+=
template <typename U>
explicit Vector3(Point3<U> p);
template <typename U>
explicit Vector3(Normal3<U> n);
```

#parec[
  Addition and subtraction of vectors is performed component-wise, via methods from #link("../Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple3")[Tuple3];. The usual geometric interpretation of vector addition and subtraction is shown in @fig:vectoradd and @fig:vectorsubtract . A vector's length can be changed via component-wise multiplication or division by a scalar. These capabilities, too, are provided by #link("../Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple3")[Tuple3] and so do not require any additional implementation in the #link("<Vector3>")[Vector3] class.
][
  向量的加减通过 #link("../Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple3")[Tuple3] 的方法逐个组件执行。向量加减的通常几何解释如@fig:vectoradd 和 @fig:vectorsubtract 所示。向量的长度可以通过标量逐个组件乘法或除法来改变。这些功能也由 #link("../Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple3")[Tuple3] 提供，因此不需要在 #link("<Vector3>")[Vector3] 类中进行任何额外实现。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f03.svg"),
  caption: [
    #ez_caption[(a) Vector addition: $bold(v) + bold(w)$. (b) Notice that the sum $bold(v) + bold(w)$ forms the diagonal of the parallelogram formed by $bold(v)$ and $bold(w)$, which shows the commutativity of vector addition: $bold(v) + bold(w) = bold(w) + bold(v)$. ][(a) 向量加法: $bold(v) + bold(w)$。(b) 注意，和$bold(v) + bold(w)$形成了由$bold(v)$ and $bold(w)$形成的平行四边形的对角线，这显示了向量加法的交换性$bold(v) + bold(w) = bold(w) + bold(v)$。 ]
  ],
)
<vectoradd>

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f04.svg"),
  caption: [
    #ez_caption[
      (a) Vector subtraction. (b) If we consider the parallelogram formed by two vectors, the diagonals are given by $bold(w) - bold(v)$ (dashed line) and $ - bold(v) - bold(w)$ (not shown).
    ][
      (a) 向量减法。(b) 如果我们考虑由两个向量形成的平行四边形，对角线由$bold(w) - bold(v)$（虚线）和 $ - bold(v) - bold(w)$ （未显示）给出。
    ]
  ],
)
<vectorsubtract>

=== 3.3.1 Normalization and Vector Length
<normalization-and-vector-length>



#parec[
  It is often necessary to #emph[normalize] a vector—that is, to compute a new vector pointing in the same direction but with unit length. A normalized vector is often called a #emph[unit vector];. The notation used in this book for normalized vectors is that $hat(upright(bold(v)))$ is the normalized version of $upright(bold(v))$. Before getting to normalization, we will start with computing vectors' lengths.
][
  通常需要#emph[归一化];一个向量，即计算一个指向相同方向但长度为单位的新向量。归一化向量通常称为#emph[单位向量];。本书中用于归一化向量的符号是 $hat(upright(bold(v)))$ 是 $upright(bold(v))$ 的归一化版本。在进行归一化之前，我们将从计算向量的长度开始。
]

#parec[
  The squared length of a vector is given by the sum of the squares of its component values.
][
  向量的平方长度由其组件值的平方和给出。
]

```cpp
// <<Vector3 Inline Functions>>=
template <typename T>
T LengthSquared(Vector3<T> v) { return Sqr(v.x) + Sqr(v.y) + Sqr(v.z); }
```

#parec[
  Moving on to computing the length of a vector leads us to a quandary: what type should the `Length()` function return? For example, if the #link("<Vector3>")[Vector3] stores an integer type, that type is probably not an appropriate return type since the vector's length will not necessarily be integer-valued. In that case, #link("../Introduction/pbrt_System_Overview.html#Float")[Float] would be a better choice, though we should not standardize on #link("../Introduction/pbrt_System_Overview.html#Float")[Float] for everything, because given a #link("<Vector3>")[Vector3] of double-precision values, we should return the length as a `double` as well. Continuing our journey through advanced C++, we turn to a technique known as #emph[type traits] to solve this dilemma.
][
  继续计算向量的长度使我们陷入困境：`Length()` 函数应该返回什么类型？例如，如果 #link("<Vector3>")[Vector3] 存储一个整数类型，该类型可能不是合适的返回类型，因为向量的长度不一定是整数值。在这种情况下，#link("../Introduction/pbrt_System_Overview.html#Float")[Float] 是一个更好的选择，但我们不应该对所有内容都标准化为 #link("../Introduction/pbrt_System_Overview.html#Float")[Float];，因为给定一个双精度值的 #link("<Vector3>")[Vector3];，我们也应该将长度返回为 `double`。随着我们对高级 C++ 的探索，我们转向一种称为#emph[类型特性];的技术来解决这个难题。
]

#parec[
  First, we define a general `TupleLength` template class that holds a type definition, `type`. The default is set here to be #link("../Introduction/pbrt_System_Overview.html#Float")[Float];.
][
  首先，我们定义一个通用的 `TupleLength` 模板类，该类包含一个类型定义 `type`。默认情况下设置为 #link("../Introduction/pbrt_System_Overview.html#Float")[Float];。
]


```cpp
// <<TupleLength Definition>>=
template <typename T>
struct TupleLength { using type = Float; };
```

#parec[
  For `Vector3`s of `double`s, we also provide a template specialization that defines `double` as the type for length given `double` for the element type.
][
  对于 `double` 的 `Vector3`，我们还提供了一个模板特化，定义 `double` 为给定元素类型为 `double` 时的长度类型。
]

```cpp
// <<TupleLength Definition>>+=
template <>
struct TupleLength<double> { using type = double; };
```


#parec[
  Now we can implement `Length()`, using #link("<TupleLength>")[TupleLength] to determine which type to return. Note that the return type cannot be specified before the function declaration is complete since the type `T` is not known until the function parameters have been parsed. Therefore, the function is declared as `auto` with the return type specified after its parameter list.
][
  现在我们可以实现 `Length()`，使用 #link("<TupleLength>")[TupleLength] 来确定返回的类型。注意，由于在函数声明完成之前无法指定返回类型，因为在解析函数参数之前类型 `T` 是未知的。因此，函数被声明为 `auto`，返回类型在其参数列表之后指定。
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
auto Length(Vector3<T> v) -> typename TupleLength<T>::type {
    using std::sqrt;
    return sqrt(LengthSquared(v));
}
```

#parec[
  There is one more C++ subtlety in these few lines of code: the reader may wonder, why have a `using std::sqrt` declaration in the implementation of `Length()` and then call `sqrt()` rather than just calling `std::sqrt()` directly? That construction is used because we would like to be able to use component types `T` that do not have overloaded versions of `std::sqrt()` available to them. For example, we will later make use of #link("<Vector3>")[Vector3];s that store intervals of values for each component using a forthcoming #link("../Utilities/Mathematical_Infrastructure.html#Interval")[Interval] class. With the way the code is written here, if `std::sqrt()` supports the type `T`, the `std` variant of the function is called. If not, then so long as we have defined a function named `sqrt()` that takes our custom type, that version will be used.
][
  在这几行代码中还有一个 C++ 的细节：读者可能会想，为什么在 `Length()` 的实现中有一个 `using std::sqrt` 声明，然后调用 `sqrt()`，而不是直接调用 `std::sqrt()`？这种构造是因为我们希望能够使用没有重载版本的 `std::sqrt()` 可用的组件类型 `T`。例如，我们稍后将使用存储每个组件值区间的 #link("../Utilities/Mathematical_Infrastructure.html#Interval")[Interval] 类的 #link("<Vector3>")[Vector3];。以这种方式编写代码，如果 `std::sqrt()` 支持类型 `T`，则调用 `std` 版本的函数。如果没有，那么只要我们定义了一个接受我们自定义类型的名为 `sqrt()` 的函数，就会使用该版本。
]

#parec[
  With all of this in hand, the implementation of `Normalize()` is thankfully now trivial. The use of `auto` for the return type ensures that if for example `Normalize()` is called with a vector with integer components, then the returned vector type has #link("../Introduction/pbrt_System_Overview.html#Float")[Float] components according to type conversion from the division operator.
][
  有了这些，`Normalize()` 的实现现在非常简单。使用 `auto` 作为返回类型可以确保如果例如 `Normalize()` 被调用时使用的是整数组件的向量，则返回的向量类型具有根据除法运算符的类型转换得到的 #link("../Introduction/pbrt_System_Overview.html#Float")[Float] 组件。
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
auto Normalize(Vector3<T> v) { return v / Length(v); }
```

=== 3.3.2 Dot and Cross Product
<dot-and-cross-product>


#parec[
  Two useful operations on vectors are the dot product (also known as the scalar or inner product) and the cross product. For two 3D vectors $upright(bold(v))$ and $upright(bold(w))$, their #emph[dot product] $(upright(bold(v)) dot upright(bold(w)))$ is defined as
][
  向量上的两个有用操作是点积（也称为标量积或内积）和叉积。对于两个三维向量 $upright(bold(v))$ 和 $upright(bold(w))$，它们的#emph[点积] $(upright(bold(v)) dot upright(bold(w)))$ 定义为
]

$
  upright(bold(v))_x upright(bold(w))_x + upright(bold(v))_y upright(bold(w))_y + upright(bold(v))_z upright(bold(w))_z,
$

#parec[
  and the implementation follows directly.
][
  实现过程直接遵循定义。
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
T Dot(Vector3<T> v, Vector3<T> w) {
    return v.x * w.x + v.y * w.y + v.z * w.z;
}
```

#parec[
  A few basic properties directly follow from the definition of the dot product. For example, if $upright(bold(v))$, $upright(bold(v))$, and $upright(bold(w))$ are vectors and $s$ is a scalar value, then:
][
  点积的一些基本性质直接从定义中得出。例如，如果 $upright(bold(v))$ 、 $upright(bold(v))$ 和 $upright(bold(w))$ 是向量， $s$ 是一个标量值，则：
]

$
  (upright(bold(u)) dot.op upright(bold(v))) & =(upright(bold(v)) dot.op upright(bold(u))) \
  (s upright(bold(u)) dot.op upright(bold(v))) & = s(upright(bold(u)) dot.op upright(bold(v))) \
  (upright(bold(u)) dot.op(upright(bold(v)) + upright(bold(w)))) & =(upright(bold(u)) dot.op upright(bold(v))) +(
    upright(bold(u)) dot.op upright(bold(w))
  ) .
$

#parec[
  The dot product has a simple relationship to the angle between the two vectors:
][
  点积与两个向量之间的角度有简单的关系：
]

$
  (upright(bold(v)) dot.op upright(bold(w))) =norm(upright(bold(v))) norm(upright(bold(w)))cos theta,
$
<dot-cos>

#parec[
  where $theta$ is the angle between $upright(bold(v))$ and $upright(bold(w))$, and $norm(upright(bold(w)))$ denotes the length of the vector $norm(upright(bold(v)))$. It follows from this that $(upright(bold(v)) dot.op upright(bold(w)))$ is zero if and only if $upright(bold(v))$ and $upright(bold(w))$ are perpendicular, provided that neither $upright(bold(v))$ nor $upright(bold(w))$ is #emph[degenerate];—equal to ((0, 0, 0)). A set of two or more mutually perpendicular vectors is said to be #emph[orthogonal];. An orthogonal set of unit vectors is called #emph[orthonormal];.
][
  其中 $theta$ 是 $upright(bold(v))$ 和 $upright(bold(w))$ 之间的角度， $norm(upright(bold(w)))$ 表示向量 $norm(upright(bold(v)))$ 的长度。由此可得，当且仅当 $upright(bold(v))$ 和 $upright(bold(w))$ 垂直时， $(upright(bold(v)) dot.op upright(bold(w)))$ 才为零，前提是 $upright(bold(v))$ 和 $upright(bold(w))$ 都不是 #emph[退化的]——即等于 ((0, 0, 0))。 一组两个或多个相互垂直的向量称为#emph[正交];。一组正交的单位向量称为#emph[正交归一];。
]


#parec[
  It follows from @eqt:dot-cos that if $upright(bold(v))$ and $upright(bold(w))$ are unit vectors, their dot product is the cosine of the angle between them. As the cosine of he angle between two vectors often needs to be computed for rendering, we will frequently make use of this property.
][
  根据@eqt:dot-cos，如果 $upright(bold(v))$ 和 $upright(bold(w))$ 是单位向量，它们的点积就是它们之间角度的余弦。由于在渲染中经常需要计算两个向量之间角度的余弦，我们将频繁使用这一性质。
]

#parec[
  If we would like to find the angle between two normalized vectors, we could use the standard library's inverse cosine function, passing it the value of the dot product between the two vectors. However, that approach can suffer from a loss of accuracy when the two vectors are nearly parallel or facing in nearly opposite directions. The following reformulation does more of its computation with values close to the origin where there is more floating-point precision, giving a more accurate result.
][
  如果我们想找到两个归一化向量之间的角度，可以使用标准库的反余弦函数，将两个向量之间的点积值传递给它。 然而，当两个向量几乎平行或几乎相对时，这种方法可能会导致精度损失。通过在接近原点的区域进行更多计算，利用更高的浮点精度，从而获得更准确的结果。
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
Float AngleBetween(Vector3<T> v1, Vector3<T> v2) {
    if (Dot(v1, v2) < 0)
        return Pi - 2 * SafeASin(Length(v1 + v2) / 2);
    else
        return 2 * SafeASin(Length(v2 - v1) / 2);
}
```


#parec[
  We will frequently need to compute the absolute value of the dot product as well. The #link("<AbsDot>")[AbsDot()] function does this for us so that a separate call to `std::abs()` is not necessary in that case.
][
  我们也经常需要计算点积的绝对值。以下代码示例展示了如何计算点积的绝对值：
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
T AbsDot(Vector3<T> v1, Vector3<T> v2) { return std::abs(Dot(v1, v2)); }
```

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f05.svg"),
  caption: [
    #parec[The orthogonal projection of a vector $upright(bold(v))$ onto a normalized vector $hat(upright(bold(w)))$ gives a vector $upright(bold(v))_o$ that is parallel to $hat(upright(bold(w)))$. The difference vector, $upright(bold(v)) - upright(bold(v))_o$, shown here as a dashed line, is perpendicular to $hat(upright(bold(w)))$.
    ][
      向量 $upright(bold(v))$ 在单位化向量 $hat(upright(bold(w)))$ 上的正交投影得到一个与 $hat(upright(bold(w)))$ 平行的向量 $upright(bold(v))_o$。差向量 $upright(bold(v)) - upright(bold(v))_o$（此处显示为虚线）与 $hat(upright(bold(w)))$ 垂直。
    ]
  ],
)<gs-orthogonal-projection>


#parec[
  A useful operation on vectors that is based on the dot product is the #emph[Gram-Schmidt] process, which transforms a set of non-orthogonal vectors that form a basis into orthogonal vectors that span the same basis.
][
  基于点积的一个有用的向量操作是#emph[格拉姆-施密特过程];，它将形成基的非正交向量集转换为跨越相同基的正交向量。
]

#parec[
  It is based on successive application of the #emph[orthogonal projection] of a vector $upright(bold(v))$ onto a normalized vector $hat(upright(bold(w)))$, which is given by $(upright(bold(v)) dot.op hat(upright(bold(w)))) hat(upright(bold(w)))$ (see @gs-orthogonal-projection ). The orthogonal projection can be used to compute a new vector
][
  它基于将向量 $upright(bold(v))$ 依次投影到单位化向量 $hat(upright(bold(w)))$ 上的 #emph[正交投影]，其表示为 $(upright(bold(v)) dot.op hat(upright(bold(w)))) hat(upright(bold(w)))$ （参见 @gs-orthogonal-projection）。正交投影可以用于计算一个新的向量。
]

$
  upright(bold(v))_perp = upright(bold(v)) -(upright(bold(v)) dot.op hat(upright(bold(w)))) hat(upright(bold(w)))
$<eq_gs-orthogonal-projection>
#parec[
  that is orthogonal to $upright(bold(w))$. An advantage of computing $upright(bold(v))_perp$ in this way is that $upright(bold(v))_perp$ and $upright(bold(w))$ span the same subspace as $bold(w)$ and $bold(w)$ did.
][
  这种方式计算得到的向量 $upright(bold(v))_perp$ 与 $upright(bold(w))$ 是正交的。以这种方式计算 $upright(bold(v))_perp$ 的一个优点是， $upright(bold(v))_perp$ 和 $upright(bold(w))$ 张成的子空间与 $bold(w)$ 和 $bold(w)$ 之前张成的子空间相同。
]

#parec[
  The `GramSchmidt()` function implements @eqt:eq_gs-orthogonal-projection; it expects the vector `w` to already be normalized.
][
  `GramSchmidt()`函数实现了@eqt:eq_gs-orthogonal-projection；它要求向量`w`已经被归一化。
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
Vector3<T> GramSchmidt(Vector3<T> v, Vector3<T> w) {
    return v - Dot(v, w) * w;
}
```
#parec[
  The #emph[cross product] is another useful operation for 3D vectors. Given two vectors in 3D, the cross product $upright(bold(v)) times upright(bold(w))$ is a vector that is perpendicular to both of them. Given orthogonal vectors $upright(bold(v))$ and $upright(bold(w))$ ;, then $upright(bold(v)) times upright(bold(w))$ is defined to be a vector such that $(upright(bold(v)), upright(bold(w)), upright(bold(v)) times upright(bold(w)))$ form an orthogonal coordinate system.
][
  #emph[叉积] 是 3D 向量中另一种有用的运算。给定 3D 中的两个向量，叉积 $upright(bold(v)) times upright(bold(w))$ 是一个同时垂直于这两个向量的向量。给定正交向量 $upright(bold(v))$ 和 $upright(bold(w))$，则定义 $upright(bold(v)) times upright(bold(w))$ 为使 $(upright(bold(v)), upright(bold(w)), upright(bold(v)) times upright(bold(w)))$ 形成一个正交坐标系的向量。
]



#parec[
  The cross product is defined as:
][
  叉积定义为：
]

$
  (
    upright(bold(v)) times upright(bold(w))
  )_x & = upright(bold(v))_y upright(bold(w))_z - upright(bold(v))_z upright(bold(w))_y, \
  (
    upright(bold(v)) times upright(bold(w))
  )_y & = upright(bold(v))_z upright(bold(w))_x - upright(bold(v))_x upright(bold(w))_z, \
  (
    upright(bold(v)) times upright(bold(w))
  )_z & = upright(bold(v))_x upright(bold(w))_y - upright(bold(v))_y upright(bold(w))_x .
$

#parec[
  A way to remember this is to compute the determinant of the matrix:
][
  记住这一点的方法是计算矩阵的行列式：
]

$
  upright(bold(v)) times upright(bold(w)) = mat(delim: "|", upright(bold(i)), upright(bold(j)), upright(bold(k));
upright(bold(v))_x, upright(bold(v))_y, upright(bold(v))_z;
upright(bold(w))_x, upright(bold(w))_y, upright(bold(w))_z),
$

#parec[
  where $i$ ;, $j$ ;, and $k$ represent the axes $(1, 0, 0)$, $(0, 1, 0)$, and $(0, 0, 1)$, respectively. Note that this equation is merely a memory aid and not a rigorous mathematical construction, since the matrix entries are a mix of scalars and vectors.
][
  其中 $i$ ;、 $j$ ;和 $k$ ;分别代表轴 $(1, 0, 0)$, $(0, 1, 0)$, and $(0, 0, 1)$. 注意，这个方程只是一个记忆辅助，而不是严格的数学构造，因为矩阵条目是标量和向量的混合。
]

#parec[
  The cross product implementation here uses the #link("../Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[DifferenceOfProducts()] function that is introduced in Section #link("../Utilities/Mathematical_Infrastructure.html#sec:fp-error-free-xforms")[B.2.9];. Given values `a`, `b`, `c`, and `d`, it computes `a*b-c*d` in a way that maintains more floating-point accuracy than a direct implementation of that expression would. This concern is not a theoretical one: previous versions of `pbrt` have resorted to using double precision for the implementation of `Cross()` so that numerical error would not lead to artifacts in rendered images. Using #link("../Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[DifferenceOfProducts()] is a better solution since it can operate entirely in single precision while still computing a result with low error.
][
  这里的叉积实现使用了在#link("../Utilities/Mathematical_Infrastructure.html#sec:fp-error-free-xforms")[第B.2.9节];中介绍的#link("../Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[DifferenceOfProducts()];函数。 给定值`a`、`b`、`c`和`d`，它以比直接实现该表达式更能保持浮点精度的方式计算`a*b-c*d`。 这个问题不仅仅是理论上的：`pbrt`的早期版本曾经使用双精度来实现`Cross()`，以免数值误差导致渲染图像中的伪影。 使用#link("../Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[DifferenceOfProducts()];是一个更好的解决方案，因为它可以完全在单精度下操作，同时仍然计算出低误差的结果。
]

```cpp
// <<Vector3 Inline Functions>>+=
template <typename T>
Vector3<T> Cross(Vector3<T> v, Vector3<T> w) {
    return {DifferenceOfProducts(v.y, w.z, v.z, w.y),
            DifferenceOfProducts(v.z, w.x, v.x, w.z),
            DifferenceOfProducts(v.x, w.y, v.y, w.x)};
}
```

#parec[
  From the definition of the cross product, we can derive:
][
  从叉积的定义，我们可以推导出：
]

$
  |upright(bold(v)) times upright(bold(w))| =|upright(bold(v))||upright(bold(w))| |sin theta|,
$<cross-sin-theta>

#parec[
  where $theta$ is the angle between $upright(bold(v))$ and $upright(bold(w))$. An important implication of this is that the cross product of two perpendicular unit vectors is itself a unit vector. Note also that the result of the cross product is a degenerate vector if $upright(bold(v))$ and $upright(bold(w))$ are parallel.
][
  其中 $theta$ 是 $upright(bold(v))$ ;和 $upright(bold(w))$ ;之间的角度。一个重要的含义是，两个垂直单位向量的叉积本身也是一个单位向量。 还要注意，如果 $upright(bold(v))$ ;和 $upright(bold(w))$ ;平行，则叉积的结果是一个退化向量。
]

#parec[
  This definition also shows a convenient way to compute the area of a parallelogram (Figure 3.6). If the two edges of the parallelogram are given by vectors $upright(bold(v))_1$ and $upright(bold(v))_2$, and it has height $h$, the area is given by $norm(upright(bold(v)))_1h$. Since $h = sin theta norm(upright(bold(v))_2)$, we can use Equation (3.3) to see that the area is $norm( upright(v)_1 times upright(v)_2)$.
][
  这个定义还展示了一种方便的方法来计算平行四边形的面积（图 3.6）。如果平行四边形的两条边由向量 $upright(bold(v))_1$ 和 $upright(bold(v))_2$ 表示，并且它的高度为 $h$，则面积为 $norm(upright(bold(v)))_1h$。由于 $h = sin theta \cdot norm(upright(bold(v))_2)$，我们可以利用公式 (3.3) 得出面积为 $norm( upright(v)_1 times upright(v)_2)$。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f05.svg"),
  caption: [
    #parec[ The area of a parallelogram with edges given by vectors $upright(bold(v))_1$ and $upright(bold(v))_2$ is equal to $norm( upright(bold(v))_1)h$. From @eqt:cross-sin-theta , the length of the cross product of $upright(bold(v))_1$ and $upright(bold(v))_2$ is equal to the product of the two vector lengths times the sine of the angle between them—the parallelogram area.

    ][
      由向量 $upright(bold(v))_1$ 和 $upright(bold(v))_2$ 构成的平行四边形的面积等于 $norm( upright(bold(v))_1)h$。根据 @eqt:cross-sin-theta，向量 $upright(bold(v))_1$ 和 $upright(bold(v))_2$ 的叉积的长度等于两个向量长度的乘积再乘以它们之间夹角的正弦值，这就是平行四边形的面积。
    ]
  ],
)
<parallelogram-area>

=== Coordinate System from a Vector
<coordinate-system-from-a-vector>


#parec[
  We will sometimes find it useful to construct a local coordinate system given only a single normalized 3D vector. To do so, we must find two additional normalized vectors such that all three vectors are mutually perpendicular.
][
  有时，仅依靠一个归一化的3D向量来构建局部坐标系是非常有用的。 为此，我们必须找到两个额外的归一化向量，使得所有三个向量互相垂直。
]

#parec[
  Given a vector $upright(bold(v))$ ;, it can be shown that the two vectors
][
  给定一个向量 $upright(bold(v))$ ;，可以证明以下两个向量
]

$
  (
    1 - frac(upright(bold(v))_x^2, 1 + upright(bold(v))_z), - frac(upright(bold(v))_x upright(bold(v))_y, 1 + upright(bold(v))_z), - upright(bold(v))_x
  ) "and"(
    -frac(upright(bold(v))_x upright(bold(v))_y, 1 + upright(bold(v))_z), 1 - frac(upright(bold(v))_y^2, 1 + upright(bold(v))_z), - upright(bold(v))_y
  )
$


#parec[
  fulfill these conditions. However, computing those properties directly has high error when $upright(bold(v))_z approx - 1$ due to a loss of accuracy when $frac(1, 1 + upright(bold(v))_z)$ is calculated. A reformulation of that computation, used in the following implementation, addresses that issue.
][
  满足这些条件。然而，当 $upright(bold(v))_z approx - 1$ 时，由于计算 $frac(1, 1 + upright(bold(v))_z)$ 时精度的损失，直接计算这些属性会有较高的误差。以下实现中使用的计算重新公式化解决了这个问题。
]

```cpp
<<Vector3 Inline Functions>>+=
template <typename T>
void CoordinateSystem(Vector3<T> v1, Vector3<T> *v2, Vector3<T> *v3) {
    Float sign = pstd::copysign(Float(1), v1.z);
    Float a = -1 / (sign + v1.z);
    Float b = v1.x * v1.y * a;
    *v2 = Vector3<T>(1 + sign * Sqr(v1.x) * a, sign * b, -sign * v1.x);
    *v3 = Vector3<T>(b, sign + Sqr(v1.y) * a, -v1.y);
}
```