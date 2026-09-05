#import "../template.typ": parec, ez_caption

== #ez_caption[Applying Transformations][应用变换]
#parec[
  We can now define routines that perform the appropriate matrix multiplications to transform points and vectors. We will overload the function application operator to describe these transformations; this lets us write code like:
][
  我们现在可以定义执行适当矩阵乘法以变换点和向量的函数。我们将重载函数调用运算符来描述这些变换，这使我们能够编写如下代码：
]

```cpp
Point3f p = ...;
Transform T = ...;
Point3f pNew = T(p);
```

=== #ez_caption[Points][点]
#parec[
  The point transformation routine takes a point $(x, y, z)$ and implicitly represents it as the homogeneous column vector $[x,y,z,1]^T$. It then transforms the point by premultiplying this vector with the transformation matrix. Finally, it divides by $w$ to convert back to a nonhomogeneous point representation. For efficiency, this method skips the division by the homogeneous weight, $w$, when $w = 1$, which is common for most of the transformations that will be used in pbrt—only the projective transformations defined in @cameras-and-film will require this division.
][
  点变换函数接受一个点 $(x, y, z)$ 并隐式地将其表示为齐次列向量 $[x,y,z,1]^T$。然后从左侧乘以变换矩阵，得到变换后的点。最后，通过除以 $w$ 转换回非齐次点表示。为了提高效率，当 $w = 1$ 时，此方法跳过齐次权重 $w$ 的除法。这对于大多数将用于 `pbrt` 的变换是常见的，只有@cameras-and-film 中定义的投影变换才需要进行此除法。
]

#block(sticky: true)[#raw("<<Transform Inline Methods>>=") #link(<fragment-TransformInlineMethods-1>)[▼]] <fragment-TransformInlineMethods-0>
```cpp
template <typename T>
Point3<T> Transform::operator()(Point3<T> p) const {
    T xp = m[0][0] * p.x + m[0][1] * p.y + m[0][2] * p.z + m[0][3];
    T yp = m[1][0] * p.x + m[1][1] * p.y + m[1][2] * p.z + m[1][3];
    T zp = m[2][0] * p.x + m[2][1] * p.y + m[2][2] * p.z + m[2][3];
    T wp = m[3][0] * p.x + m[3][1] * p.y + m[3][2] * p.z + m[3][3];
    if (wp == 1)
        return Point3<T>(xp, yp, zp);
    else
        return Point3<T>(xp, yp, zp) / wp;
}
```

#parec[
  The `Transform` class also provides a corresponding `ApplyInverse()` method for each type it transforms. The one for `Point3` applies its inverse transformation to the given point. Calling this method is more succinct and generally more efficient than calling `Transform::Inverse()` and then calling its `operator()`.
][
  #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[Transform] 类还为每种变换类型提供了相应的 `ApplyInverse()` 方法。对于 `Point3`，它对给定点应用其逆变换。调用此方法比调用 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform::Inverse")[Transform::Inverse()] 然后调用其 `operator()` 更简洁且通常更有效。
]


#block(sticky: true)[#raw("<<Transform Public Methods>>+=") #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#fragment-TransformPublicMethods-6")[▲] #link(<fragment-TransformPublicMethods-8>)[▼]] <fragment-TransformPublicMethods-7>
```cpp
template <typename T>
Point3<T> ApplyInverse(Point3<T> p) const;
```


#parec[
  All subsequent types that can be transformed also have an `ApplyInverse()` method, though we will not include them in the book text.
][
  所有后续可变换的类型也都有一个 `ApplyInverse()` 方法，尽管我们不会在书中包含它们。
]

=== #ez_caption[Vectors][向量]
#parec[
  The transformations of vectors can be computed in a similar fashion. However, the multiplication of the matrix and the column vector is simplified since the implicit homogeneous $w$ coordinate is zero.
][
  向量的变换可以以类似的方式计算。然而，由于隐式齐次坐标 $w$ 为零，矩阵和列向量的乘法得以简化。
]


#block(sticky: true)[#raw("<<Transform Inline Methods>>+=") #link(<fragment-TransformInlineMethods-0>)[▲] #link(<fragment-TransformInlineMethods-2>)[▼]] <fragment-TransformInlineMethods-1>
```cpp
template <typename T>
Vector3<T> Transform::operator()(Vector3<T> v) const {
    return Vector3<T>(m[0][0] * v.x + m[0][1] * v.y + m[0][2] * v.z,
                      m[1][0] * v.x + m[1][1] * v.y + m[1][2] * v.z,
                      m[2][0] * v.x + m[2][1] * v.y + m[2][2] * v.z);
}
```

=== #ez_caption[Normals][法向量]
<normals-310>

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f29.svg"),
  caption: [#ez_caption[Transforming Surface Normals. (a) Original circle, with the normal at a point indicated by an arrow. (b) When scaling the circle to be half as tall in the $y$ direction, simply treating the normal as a direction and scaling it in the same manner gives a normal that is no longer perpendicular to the surface. (c) A properly transformed normal.][变换表面法向量。（a）原始圆形，箭头表示某点的法向量。（b）将圆形沿 $y$ 方向缩放到原高度的一半时，如果把法向量当作普通方向向量同样缩放，结果将不再垂直于表面。（c）正确变换后的法向量。]],
)<normaltransform>


#parec[
  Normals do not transform in the same way that vectors do, as shown in @fig:normaltransform. Although tangent vectors at a surface transform in the straightforward way, normals require special treatment. Because the normal vector $upright(bold(n))$ and any tangent vector $upright(bold(t))$ on the surface are orthogonal by construction, we know that
][
  法向量的变换方式与向量不同，如@fig:normaltransform 所示。尽管表面的切向量以直接方式变换，法向量需要特殊处理。因为法向量 $upright(bold(n))$ 和表面上的任何切向量 $upright(bold(t))$ 都是正交的，所以我们知道
]

$
  upright(bold(n)) dot.op upright(bold(t)) = upright(bold(n))^T upright(bold(t)) = 0 .
$
#parec[
  When we transform a point on the surface by some matrix $upright(bold(M))$, the new tangent vector $upright(bold(t))'$ at the transformed point is $upright(bold(M)) upright(bold(t))$. The transformed normal $upright(bold(n))'$ should be equal to $upright(bold(S)) upright(bold(n))$ for some $4 times 4$ matrix $upright(bold(S))$. To maintain the orthogonality requirement, we must have
][
  当我们通过某个矩阵 $upright(bold(M))$ 变换曲面上的一个点时，变换后该点的新切向量 $upright(bold(t))'$ 为 $upright(bold(M)) upright(bold(t))$。变换后的法向量 $upright(bold(n))'$ 应等于 $upright(bold(S)) upright(bold(n))$，其中 $upright(bold(S))$ 是某个 $4 times 4$ 矩阵。为了保持正交性要求，我们必须满足
]

$
  0 &= (upright(bold(n))')^T upright(bold(t))' \
  &= (upright(bold(S)) upright(bold(n)))^T upright(bold(M)) upright(bold(t)) \
  &= upright(bold(n))^T upright(bold(S))^T upright(bold(M)) upright(bold(t)) .
$

#parec[
  This condition holds if $upright(bold(S))^T upright(bold(M)) = upright(bold(I))$, the identity matrix. Therefore, $upright(bold(S))^T=upright(bold(M)) ^(-1) $, and so $upright(bold(S)) = (upright(bold(M))^(-1))^(upright(T))$, and we see that normals must be transformed by the inverse transpose of the transformation matrix. This detail is one of the reasons why Transforms maintain their inverses.
][
  若 $upright(bold(S))^T upright(bold(M)) = upright(bold(I))$（其中 $upright(bold(I))$ 为单位矩阵），上述条件便成立。因此， $upright(bold(S))^T=upright(bold(M)) ^(-1) $，所以 $upright(bold(S)) = (upright(bold(M))^(-1))^(upright(T))$， 我们看到法向量必须通过变换矩阵的逆转置来变换。这一细节是 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[Transforms] 保持其逆的原因之一。
]

#parec[
  Note that this method does not explicitly compute the transpose of the inverse when transforming normals. It just indexes into the inverse matrix in a different order (compare to the code for transforming Vector3f s).
][
  注意，此方法在变换法向量时并未显式计算逆的转置。它只是以不同的顺序索引到逆矩阵中（与变换 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f] 的代码相比）。
]


#block(sticky: true)[#raw("<<Transform Inline Methods>>+=") #link(<fragment-TransformInlineMethods-1>)[▲] #link(<fragment-TransformInlineMethods-3>)[▼]] <fragment-TransformInlineMethods-2>
```cpp
template <typename T>
Normal3<T> Transform::operator()(Normal3<T> n) const {
    T x = n.x, y = n.y, z = n.z;
    return Normal3<T>(mInv[0][0] * x + mInv[1][0] * y + mInv[2][0] * z,
                      mInv[0][1] * x + mInv[1][1] * y + mInv[2][1] * z,
                      mInv[0][2] * x + mInv[1][2] * y + mInv[2][2] * z);
}
```



=== #ez_caption[Rays][射线]
<transforming-rays>
#parec[
  Transforming rays is conceptually straightforward: it is a matter of transforming the constituent origin and direction and copying the other data members. (`pbrt` also provides a similar method for transforming #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#RayDifferential")[RayDifferential]s.)
][
  射线变换在概念上很简单：变换其起点与方向，再复制其他数据成员即可。（`pbrt` 还提供了类似的方法来变换 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#RayDifferential")[RayDifferential]）。
]

#parec[
  The approach used in `pbrt` to manage floating-point round-off error introduces some subtleties that require a small adjustment to the transformed ray origin. The \<\<#link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#fragment-OffsetrayorigintoedgeoferrorboundsandcomputemonotMax-0")[Offset ray origin to edge of error bounds and compute `tMax`]\>\> fragment handles these details; it is defined in Section #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:generating-rays")[6.8.6], where round-off error and `pbrt`'s mechanisms for dealing with it are discussed.
][
  `pbrt` 用于管理浮点舍入误差的方法引入了一些复杂性，需要对转换后的射线起点进行小的调整。\<\<#link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#fragment-OffsetrayorigintoedgeoferrorboundsandcomputemonotMax-0")[偏移光线起点至误差边界并计算 `tMax`]\>\> 片段处理这些细节；它在第 #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:generating-rays")[6.8.6] 节中定义，其中讨论了舍入误差及 `pbrt` 处理它的机制。
]

#block(sticky: true)[#raw("<<Transform Inline Methods>>+=") #link(<fragment-TransformInlineMethods-2>)[▲]] <fragment-TransformInlineMethods-3>
```cpp
Ray Transform::operator()(const Ray &r, Float *tMax) const {
    Point3fi o = (*this)(Point3fi(r.o));
    Vector3f d = (*this)(r.d);
    <<Offset ray origin to edge of error bounds and compute tMax>> 
    return Ray(Point3f(o), d, r.time, r.medium);
}
```


=== #ez_caption[Bounding Boxes][包围盒]
<bounding-boxes>

#parec[
  The easiest way to transform an axis-aligned bounding box is to transform all eight of its corner vertices and then compute a new bounding box that encompasses those points. The implementation of this approach is shown below; one of the exercises for this chapter is to implement a technique to do this computation more efficiently.
][
  转换轴对齐包围盒的最简单方法是转换其八个角顶点，然后计算一个包含这些点的新包围盒。下面显示了这种方法的实现；本章的一道习题是实现一种更高效地进行此计算的技术。
]
#block(sticky: true)[#raw("<<Transform Method Definitions>>=") #link(<fragment-TransformMethodDefinitions-1>)[▼]] <fragment-TransformMethodDefinitions-0>
```cpp
Bounds3f Transform::operator()(const Bounds3f &b) const {
    Bounds3f bt;
    for (int i = 0; i < 8; ++i)
        bt = Union(bt, (*this)(b.Corner(i)));
    return bt;
}
```

=== #ez_caption[Composition of Transformations][变换的复合]
<composition-of-transformations>

#parec[
  Having defined how the matrices representing individual types of transformations are constructed, we can now consider an aggregate transformation resulting from a series of individual transformations. We will finally see the real value of representing transformations with matrices.
][
  在定义了如何构建表示单个变换类型的矩阵后，我们现在可以考虑由一系列单个变换产生的合成变换。我们将最终看到用矩阵表示变换的实际价值。
]

#parec[
  Consider a series of transformations $upright(bold(A)) upright(bold(B)) upright(bold(C))$. We would like to compute a new transformation $upright(bold(T))$ such that applying $upright(bold(T))$ gives the same result as applying each of $upright(bold(A))$, $upright(bold(B))$, and $upright(bold(C))$ in reverse order; that is, $upright(bold(A)) (upright(bold(B)) (upright(bold(C)) (p))) = upright(bold(T)) (p)$. Such a transformation $upright(bold(T))$ can be computed by multiplying the matrices of the transformations $upright(bold(A))$, $upright(bold(B))$, and $upright(bold(C))$ together. In `pbrt`, we can write:
][
  考虑一系列变换 $upright(bold(A)) upright(bold(B)) upright(bold(C))$。我们希望计算一个新的变换 $upright(bold(T))$，使得应用 $upright(bold(T))$ 的结果与按相反顺序先应用 $upright(bold(C))$、再应用 $upright(bold(B))$、最后应用 $upright(bold(A))$ 的结果相同；即 $upright(bold(A)) (upright(bold(B)) (upright(bold(C)) (p))) = upright(bold(T)) (p)$。这样的变换 $upright(bold(T))$ 可以通过将变换 $upright(bold(A))$ 、 $upright(bold(B))$ 和 $upright(bold(C))$ 的矩阵相乘来计算。在 `pbrt` 中，我们可以写：
]
```cpp
Transform T = A * B * C;
```

#parec[
  Then we can apply `T` to #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[Point3f]s `p` as usual, `Point3f pp = T(p)`, instead of applying each transformation in turn: `Point3f pp = A(B(C(p)))`.
][
  然后我们可以像往常一样将 `T` 应用于 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[Point3f] `p`，`Point3f pp = T(p)`，而不是依次应用每个变换：`Point3f pp = A(B(C(p)))`。
]

#parec[
  We overload the C++ `*` operator in the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[Transform] class to compute the new transformation that results from postmultiplying a transformation with another transformation `t2`. In matrix multiplication, the $(i , j)$ th element of the resulting matrix is the inner product of the $i$ th row of the first matrix with the $j$ th column of the second.
][
  我们在 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[Transform] 类中重载了 C++ 的 `*` 运算符，以计算通过将一个变换与另一个变换 `t2` 后乘得到的新变换。在矩阵乘法中，结果矩阵的 $(i , j)$ 元素是第一个矩阵的第 $i$ 行与第二个矩阵的第 $j$ 列的内积。
]

#parec[
  The inverse of the resulting transformation is equal to the product of `t2.mInv * mInv`. This is a result of the matrix identity
][
  结果变换的逆等于 `t2.mInv * mInv` 的乘积。这是矩阵恒等式的结果
]
$ (upright(bold(A)) upright(bold(B)))^(- 1) = upright(bold(B))^(- 1) upright(bold(A))^(- 1) . $

#block(sticky: true)[#raw("<<Transform Method Definitions>>+=") #link(<fragment-TransformMethodDefinitions-0>)[▲] #link(<fragment-TransformMethodDefinitions-2>)[▼]] <fragment-TransformMethodDefinitions-1>
```cpp
Transform Transform::operator*(const Transform &t2) const {
    return Transform(m * t2.m, t2.mInv * mInv);
}
```

=== #ez_caption[Transformations and Coordinate System Handedness][变换与坐标系手性]
<transformations-and-coordinate-system-handedness>

#parec[
  Certain types of transformations change a left-handed coordinate system into a right-handed one, or vice versa. Some routines will need to know if the handedness of the source coordinate system is different from that of the destination. In particular, routines that want to ensure that a surface normal always points "outside" of a surface might need to flip the normal's direction after transformation if the handedness changes.
][
  某些类型的变换会将左手坐标系转换为右手坐标系，反之亦然。某些例程需要知道源坐标系的手性是否与目标坐标系不同。特别是，想要确保表面法向量始终指向表面“外部”的例程可能需要在变换后翻转法向量的方向，如果手性发生变化。
]

#parec[
  Fortunately, it is easy to tell if handedness is changed by a transformation: it happens only when the determinant of the transformation's upper-left $3 times 3$ submatrix is negative.
][
  幸运的是，很容易判断变换是否改变了手性：只有当变换的左上 $3 times 3$ 子矩阵的行列式为负时才会发生。
]
#block(sticky: true)[#raw("<<Transform Method Definitions>>+=") #link(<fragment-TransformMethodDefinitions-1>)[▲]] <fragment-TransformMethodDefinitions-2>
```cpp
bool Transform::SwapsHandedness() const {
    SquareMatrix<3> s(m[0][0], m[0][1], m[0][2],
                      m[1][0], m[1][1], m[1][2],
                      m[2][0], m[2][1], m[2][2]);
    return Determinant(s) < 0;
}
```


=== #ez_caption[Vector Frames][向量标架]
<vector-frames>

#parec[
  It is sometimes useful to define a rotation that aligns three orthonormal vectors in a coordinate system with the $x$, $y$, and $z$ axes. Applying such a transformation to direction vectors in that coordinate system can simplify subsequent computations. For example, in `pbrt`, BSDF evaluation is performed in a coordinate system where the surface normal is aligned with the $z$ axis. Among other things, this makes it possible to efficiently evaluate trigonometric functions using functions like the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#CosTheta")[CosTheta()] function that was introduced in @spherical-parameterizations.
][
  有时定义一个旋转以使坐标系中的三个正交归一向量与 $x$ 、 $y$ 和 $z$ 轴对齐是有用的。将这样的变换应用于该坐标系中的方向向量可以简化后续计算。例如，在 `pbrt` 中，BSDF 评估是在一个表面法向量与 $z$ 轴对齐的坐标系中进行的。除其他事项外，这使得可以使用在@spherical-parameterizations 中介绍的 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#CosTheta")[CosTheta()] 函数等函数高效地计算三角函数。
]

#parec[
  The `Frame` class efficiently represents and performs such transformations, avoiding the full generality (and hence, complexity) of the `Transform` class. It only needs to store a $3 times 3$ matrix, and storing the inverse is unnecessary since it is just the matrix's transpose, given orthonormal basis vectors.
][
  `Frame` 类有效地表示和执行这样的变换，无需承担 `Transform` 类为全面通用性带来的复杂度。它只需要存储一个 $3 times 3$ 矩阵，并且由于正交归一基向量，存储逆矩阵是不必要的，因为它只是矩阵的转置。
]

#block(sticky: true)[#raw("<<Frame Definition>>=")] <fragment-FrameDefinition-0>
```cpp
class Frame {
  public:
    <<Frame Public Methods>> 
    <<Frame Public Members>> 
};
``` <Frame>

#parec[
  Given three orthonormal vectors $upright(bold(x))$, $upright(bold(y))$, and $upright(bold(z))$, the matrix $upright(bold(F))$ that transforms vectors into their space is:
][
  给定三个正交归一向量 $upright(bold(x))$ 、 $upright(bold(y))$ 和 $upright(bold(z))$，将向量转换到其空间的矩阵 $upright(bold(F))$ 是：
]




$
  upright(bold(F)) = mat(delim: "(", upright(bold(x))_x, upright(bold(x))_y, upright(bold(x))_z;
upright(bold(y))_x, upright(bold(y))_y, upright(bold(y))_z;
upright(bold(z))_x, upright(bold(z))_y, upright(bold(z))_z) = mat(delim: "(", upright(bold(x));
upright(bold(y));
upright(bold(z))) .
$





#parec[
  The `Frame` stores this matrix using three #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f]s.
][
  `Frame` 使用三个 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f] 存储这个矩阵。
]

#block(sticky: true)[#raw("<<Frame Public Members>>=")] <fragment-FramePublicMembers-0>
```cpp
Vector3f x, y, z;
```

#parec[
  The three basis vectors can be specified explicitly; in debug builds, #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#DCHECK")[DCHECK()]s in the constructor ensure that the provided vectors are orthonormal.
][
  可以显式指定这三个基向量；在调试版本中，构造函数中的 #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#DCHECK")[DCHECK()] 确保提供的向量是正交单位向量。
]

#block(sticky: true)[#raw("<<Frame Public Methods>>=") #link(<fragment-FramePublicMethods-1>)[▼]] <fragment-FramePublicMethods-0>
```cpp
Frame() : x(1, 0, 0), y(0, 1, 0), z(0, 0, 1) {}
Frame(Vector3f x, Vector3f y, Vector3f z);
```

#parec[
  `Frame` also provides convenience methods that construct a frame from just two of the basis vectors, using the cross product to compute the third.
][
  `Frame` 还提供了便捷的方法，可以仅从两个基向量构造一个标架，使用叉积计算第三个向量。
]

#block(sticky: true)[#raw("<<Frame Public Methods>>+=") #link(<fragment-FramePublicMethods-0>)[▲] #link(<fragment-FramePublicMethods-2>)[▼]] <fragment-FramePublicMethods-1>
```cpp
static Frame FromXZ(Vector3f x, Vector3f z) {
    return Frame(x, Cross(z, x), z);
}
static Frame FromXY(Vector3f x, Vector3f y) {
    return Frame(x, y, Cross(x, y));
}
```
#parec[
  Only the $z$ axis vector can be provided as well, in which case the others are set arbitrarily.
][
  也可以仅提供 $z$ 轴向量，在这种情况下其余向量可以任意选取。
]

#block(sticky: true)[#raw("<<Frame Public Methods>>+=") #link(<fragment-FramePublicMethods-1>)[▲] #link(<fragment-FramePublicMethods-3>)[▼]] <fragment-FramePublicMethods-2>
```cpp
static Frame FromZ(Vector3f z) {
    Vector3f x, y;
    CoordinateSystem(z, &x, &y);
    return Frame(x, y, z);
}
```
#parec[
  A variety of other functions, not included here, allow specifying a frame using a normal vector and specifying it via just the $x$ or $y$ basis vector.
][
  还有多种其他函数（未在此列出），允许使用法向量指定标架，并通过仅提供 $x$ 或 $y$ 基向量来指定。
]

#parec[
  Transforming a vector into the frame's coordinate space is done using the $upright(bold(F))$ matrix. Because #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f]s were used to store its rows, the matrix-vector product can be expressed as three dot products.
][
  将向量转换到标架的坐标空间是通过使用 $upright(bold(F))$ 矩阵完成的。由于 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[Vector3f] 被用来存储其行，矩阵-向量积可以表示为三个点积。
]

#block(sticky: true)[#raw("<<Frame Public Methods>>+=") #link(<fragment-FramePublicMethods-2>)[▲] #link(<fragment-FramePublicMethods-4>)[▼]] <fragment-FramePublicMethods-3>
```cpp
Vector3f ToLocal(Vector3f v) const {
    return Vector3f(Dot(v, x), Dot(v, y), Dot(v, z));
}
```
#parec[
  A `ToLocal()` method is also provided for normal vectors. In this case, we do not need to compute the inverse transpose of $upright(bold(F))$ for the transformation normals (recall the discussion of transforming normals in @normals-310). Because $upright(bold(F))$ is an orthonormal matrix (its rows and columns are mutually orthogonal and unit length), its inverse is equal to its transpose, so it is its own inverse transpose already.
][
  还提供了一个 `ToLocal()` 方法用于法向量。在这种情况下，我们不需要计算 $upright(bold(F))$ 的逆转置来转换法向量（可回顾 @normals-310 中的讨论）。 因为 $upright(bold(F))$ 是一个正交矩阵（其行和列是相互正交且单位长度的），其逆等于其转置，所以它已经是其自身的逆转置。
]

#block(sticky: true)[#raw("<<Frame Public Methods>>+=") #link(<fragment-FramePublicMethods-3>)[▲] #link(<fragment-FramePublicMethods-5>)[▼]] <fragment-FramePublicMethods-4>
```cpp
Normal3f ToLocal(Normal3f n) const {
    return Normal3f(Dot(n, x), Dot(n, y), Dot(n, z));
}
```
#parec[
  The method that transforms vectors out of the frame's local space transposes $upright(bold(F))$ to find its inverse before multiplying by the vector.
][
  将向量从标架的局部空间转换出去的方法是转置 $upright(bold(F))$ 以找到其逆，然后再乘以向量。
]

#parec[
  In this case, the resulting computation can be expressed as the sum of three scaled versions of the matrix columns. As before, surface normals transform as regular vectors. (That method is not included here.)
][
  在这种情况下，结果计算可以表示为矩阵列的三个缩放版本的和。与之前一样，表面法向量像常规向量一样转换。（该方法未在此列出。）
]

#block(sticky: true)[#raw("<<Frame Public Methods>>+=") #link(<fragment-FramePublicMethods-4>)[▲]] <fragment-FramePublicMethods-5>
```cpp
Vector3f FromLocal(Vector3f v) const {
    return v.x * x + v.y * y + v.z * z;
}
```
#parec[
  For convenience, there is a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[Transform] constructor that takes a `Frame`. Its simple implementation is not included here.
][
  为了方便，有一个 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[Transform] 构造函数可以接受一个 `Frame`。其简单实现未在此列出。
]

#block(sticky: true)[#raw("<<Transform Public Methods>>+=") #link(<fragment-TransformPublicMethods-7>)[▲]] <fragment-TransformPublicMethods-8>
```cpp
explicit Transform(const Frame &frame);
```

#heading(level: 3, numbering: none)[#ez_caption[Supplement: Additional Code in the Original Collapsed Panels][补充：原网页折叠面板中的额外代码]]
#include "supplements/3.10-expanded.typ"
