#import "../template.typ": parec, ez_caption


== Transformations
#parec[
  In general, a #emph[transformation] $upright(bold(T))$ is a mapping from points to points and from vectors to vectors:
][
  一般来说，#emph[变换] $upright(bold(T))$ 是从点到点和从向量到向量的映射：
]

$
  upright(bold(p prime)) = upright(bold(T)) (upright(bold(p))) , quad upright(bold(v prime)) = upright(bold(T)) (
    upright(bold(v))
  )
$


#parec[
  The transformation $upright(bold(T))$ may be an arbitrary procedure. However, we will consider a subset of all possible transformations in this chapter. In particular, they will be
][
  变换 $upright(bold(T))$ 可以是任意的过程。然而，在本章中，我们将只考虑所有可能变换中的一个子集。特别是，它们将是：
]

#parec[
  #emph[Linear:] If $upright(bold(T))$ is an arbitrary linear transformation and $s$ is an arbitrary scalar, then $upright(bold(T))(s upright(bold(v))) = s upright(bold(T))(upright(bold(v)))$ and $upright(bold(T))(upright(bold(v))_1 + upright(bold(v))_2) = upright(bold(T))(upright(bold(v))_1) + upright(bold(T))(upright(bold(v))_2)$. These two properties can greatly simplify reasoning about transformations.
][
  #emph[线性:] 如果 $upright(bold(T))$ 是一个任意的线性变换且 $s$ 是一个任意标量，那么 $upright(bold(T))(s upright(bold(v))) = s upright(bold(T))(upright(bold(v)))$ 且 $upright(bold(T))(upright(bold(v))_1 + upright(bold(v))_2) = upright(bold(T))(upright(bold(v))_1) + upright(bold(T))(upright(bold(v))_2)$。这两个性质可以极大地简化对变换的推理。
]

#parec[
  #emph[Continuous:] Roughly speaking, $upright(bold(T))$ maps the neighborhoods around $p$ and $upright(bold(v))$ to neighborhoods around $p'$ and $upright(bold(v))'$ .
][
  #emph[连续:] 粗略地说， $upright(bold(T))$ 将 $p$ 和 $upright(bold(v))$ 周围的邻域映射到 $p'$ and $upright(bold(v))'$ 周围的邻域。
]

#parec[
  #emph[One-to-one and invertible:] For each $p$, $upright(bold(T))$ maps $p$ to a single unique $p'$. Furthermore, there exists an inverse transform $upright(bold(T))^(-1)$ that maps $p'$ back to $p$.
][
  #emph[一对一和可逆：] 对于每个 $p$， $upright(bold(T))$ 将 $p$ 映射到一个唯一的 $p'$。此外，存在一个逆变换 $upright(bold(T))^(-1)$，将 $p'$ 再映射回 $p$。
]

#parec[
  We will often want to take a point, vector, or normal defined with respect to one coordinate frame and find its coordinate values with respect to another frame. Using basic properties of linear algebra, a $4 times 4$ matrix can be shown to express the linear transformation of a point or vector from one frame to another. Furthermore, such a $4 times 4$ matrix suffices to express all linear transformations of points and vectors within a fixed frame, such as translation in space or rotation around a point. Therefore, there are two different (and incompatible!) ways that a matrix can be interpreted:
][
  我们经常希望将相对于一个坐标系定义的点、向量或法线转换为相对于另一个坐标系的坐标值。利用线性代数的基本性质，可以证明一个 $4 times 4$ 矩阵可以表达从一个坐标系到另一个坐标系的点或向量的线性变换。 此外，这样的 $4 times 4$ 矩阵足以表达在固定坐标系内的所有线性变换，例如空间中的平移或绕某一点的旋转。 因此，矩阵可以有两种不同的（且不兼容的！）解释方式：
]

#parec[
  - #emph[Transformation within the frame:] Given a point, the matrix could express how to compute a #emph[new] point in the same frame that represents the transformation of the original point (e.g., by translating it in some direction).
][
  - #emph[坐标系内的变换:] 给定一个点，矩阵可以表达如何在同一坐标系中计算一个表示原始点变换的新点（例如，通过在某个方向上平移它）。
]

#parec[
  - #emph[Transformation from one frame to another:] A matrix can express the coordinates of a point or vector in a new frame in terms of the coordinates in the original frame.
][
  - #emph[从一个坐标系到另一个坐标系的变换:] 矩阵可以用原始坐标系中的坐标表示新坐标系中的点或向量的坐标。
]

#parec[
  Most uses of transformations in `pbrt` are for transforming points from one frame to another.
][
  在 `pbrt` 中，变换的大多数用途是用于将点从一个坐标系转换到另一个坐标系。
]

#parec[
  In general, transformations make it possible to work in the most convenient coordinate space. For example, we can write routines that define a virtual camera, assuming that the camera is located at the origin, looks down the $z$ axis, and has the $y$ axis pointing up and the $x$ axis pointing right. These assumptions greatly simplify the camera implementation. To place the camera at any point in the scene looking in any direction, we construct a transformation that maps points in the scene's coordinate system to the camera's coordinate system. (See @camera-coordinate-spaces for more information about camera coordinate spaces in `pbrt`.)
][
  一般来说，变换使得在最方便的坐标空间中工作成为可能。 例如，我们可以编写定义虚拟相机的例程，假设相机位于原点，沿 $z$ 轴向下看， $y$ 轴向上， $x$ 轴向右。 这些假设大大简化了相机的实现过程。为了将相机放置在场景中的任意点并朝任意方向看，我们构建一个变换，将场景坐标系中的点映射到相机坐标系中。 （有关 `pbrt` 中相机坐标空间的更多信息，请参见@camera-coordinate-spaces。）
]

=== Homogeneous Coordinates
<homogeneous-coordinates>

#parec[
  Given a frame defined by $(upright("p")_0 , upright(bold(v))_1 , upright(bold(v))_2 , upright(bold(v))_3)$, there is ambiguity between the representation of a point $(upright("p")_x , upright("p")_y , upright("p")_z)$ and a vector $(upright(bold(v))_x , upright(bold(v))_y , upright(bold(v))_z)$ with the same $(x , y , z)$ coordinates. Using the representations of points and vectors introduced at the start of the chapter, we can write the point as the inner product $[s_1 s_2 s_3 1] [upright(bold(v))_1 upright(bold(v))_2 upright(bold(v))_3 upright("p")_0]^T$ and the vector as the inner product $[s prime_1 s prime_2 s prime_3 0] [upright(bold(v))_1 upright(bold(v))_2 upright(bold(v))_3 upright("p")_0]^T$. These four-vectors of three $s_i$ values and a zero or one are called the #emph[homogeneous] representations of the point and the vector. The fourth coordinate of the homogeneous representation is sometimes called the #emph[weight];. For a point, its value can be any scalar other than zero: the homogeneous points $[1 , 3 , - 2 , 1]$ and $[- 2 , - 6 , 4 , - 2]$ describe the same Cartesian point $(1 , 3 , - 2)$. Converting homogeneous points into ordinary points entails dividing the first three components by the weight:
][
  给定一个由 $(upright("p")_0 , upright(bold(v))_1 , upright(bold(v))_2 , upright(bold(v))_3)$ 定义的坐标框架，点的表示 $(upright("p")_x , upright("p")_y , upright("p")_z)$ 与向量的表示 $(upright(bold(v))_x , upright(bold(v))_y , upright(bold(v))_z)$ 在相同的 $(x , y , z)$ 坐标下存在歧义。使用本章开始介绍的点和向量的表示方法，我们可以将点表示为内积 $[s_1 s_2 s_3 1] [upright(bold(v))_1 upright(bold(v))_2 upright(bold(v))_3 upright("p")_0]^T$，将向量表示为内积 $[s prime_1 s prime_2 s prime_3 0] [upright(bold(v))_1 upright(bold(v))_2 upright(bold(v))_3 upright("p")_0]^T$。这些四维向量中的三个 $s_i$ 值和一个零或一被称为点和向量的#emph[齐次];表示。齐次表示的第四个坐标有时被称为#emph[权重];。对于一个点，其值可以是除零以外的任何标量：齐次点 $[1 , 3 , - 2 , 1]$ 和 $[- 2 , - 6 , 4 , - 2]$ 描述相同的笛卡尔点 $(1 , 3 , - 2)$。将齐次点转换为普通点需要将前三个分量除以权重：
]
$ (x , y , z , w) arrow.r (x / w , y / w , z / w) . $

#parec[
  We will use these facts to see how a transformation matrix can describe how points and vectors in one frame can be mapped to another frame. Consider a matrix $upright(bold(M))$ that describes the transformation from one coordinate system to another:
][
  我们将使用这些事实来了解变换矩阵如何描述一个坐标框架中的点和向量如何映射到另一个坐标框架。考虑一个描述从一个坐标系统到另一个坐标系统的变换的矩阵 $upright(bold(M))$ ：
]
$
  upright(bold(M)) = mat(delim: "[", m_(0 , 0), m_(0 , 1), m_(0 , 2), m_(0 , 3); m_(1 , 0), m_(1 , 1), m_(1 , 2), m_(1 , 3); m_(2 , 0), m_(2 , 1), m_(2 , 2), m_(2 , 3); m_(3 , 0), m_(3 , 1), m_(3 , 2), m_(3 , 3)) .
$

#parec[
  (In this book, we define matrix element indices starting from zero, so that equations and source code correspond more directly.) Then if the transformation represented by $upright(bold(M))$ is applied to the $x$ axis vector $(1 , 0 , 0)$, we have
][
  （在本书中，我们定义矩阵元素索引从零开始，以便公式和源代码更直接对应。）然后，如果将由 $upright(bold(M))$ 表示的变换应用于 $x$ 轴向量 $(1 , 0 , 0)$，我们有
]



$
  upright(bold(M x)) = upright(bold(M))(mat(delim: #none, 1; 0; 0; 0))^T =(
    mat(delim: #none, m_(0 comma 0), m_(1 comma 0), m_(2 comma 0), m_(3 comma 0))
  )^T .
$


#parec[
  Thus, directly reading the columns of the matrix shows how the basis vectors and the origin of the current coordinate system are transformed by the matrix:
][
  因此，直接读取矩阵的列可以显示基向量和当前坐标系的原点如何通过矩阵变换：
]

$
  upright(bold(M y)) & =(mat(delim: #none, m_(0 comma 1), m_(1 comma 1), m_(2 comma 1), m_(3 comma 1)))^T \
  upright(bold(M z)) & =(mat(delim: #none, m_(0 comma 2), m_(1 comma 2), m_(2 comma 2), m_(3 comma 2)))^T \
  upright(bold(M p)) & =(mat(delim: #none, m_(0 comma 3), m_(1 comma 3), m_(2 comma 3), m_(3 comma 3)))^T .
$



#parec[
  In general, by characterizing how the basis is transformed, we know how any point or vector specified in terms of that basis is transformed. Because points and vectors in a coordinate system are expressed in terms of the coordinate system's frame, applying the transformation to them directly is equivalent to applying the transformation to the coordinate system's basis and finding their coordinates in terms of the transformed basis.
][
  通常，通过描述基如何变换，我们知道如何变换以该基为标准的任何点或向量。因为坐标系中的点和向量是以坐标系的框架表示的，直接对它们应用变换相当于对坐标系的基应用变换并找到它们在变换后的基中的坐标。
]

#parec[
  We will not use homogeneous coordinates explicitly in our code; there is no `HomogeneousPoint` class in `pbrt`. However, the various transformation routines in the next section will implicitly convert points, vectors, and normals to homogeneous form, transform the homogeneous points, and then convert them back before returning the result. This isolates the details of homogeneous coordinates in one place (namely, the implementation of transformations).
][
  我们不会在代码中显式使用齐次坐标；在`pbrt`中没有`HomogeneousPoint`类。然而，下一节中的各种变换例程将隐式地将点、向量和法线转换为齐次形式，变换齐次点，然后在返回结果之前将它们转换回来。这将齐次坐标的细节隔离在一个地方（即变换的实现中）。
]

=== Transform Class Definition


#parec[
  The `Transform` class represents a $4 times 4$ transformation. Its implementation is in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/transform.h")[util/transform.h] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/transform.cpp")[util/transform.cpp];.
][
  `Transform`类表示一个 $4 times 4$ 的变换。其实现位于文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/transform.h")[util/transform.h];和#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/transform.cpp")[util/transform.cpp];中。
]


```cpp
<<Transform Definition>>=
class Transform {
  public:
    <<Transform Public Methods>>
  private:
    <<Transform Private Members>>
};
```


#parec[
  The transformation matrix is represented by the elements of the matrix `m`, which is represented by a `SquareMatrix<4>` object. (The #link("../Utilities/Mathematical_Infrastructure.html#SquareMatrix")[`SquareMatrix`] class is defined in Section~#link("../Utilities/Mathematical_Infrastructure.html#sec:square-matrix")[B.2.12];.) The matrix `m` is stored in #emph[row-major] form, so element `m[i][j]` corresponds to $m_(i , j)$, where~ $i$ is the row number and~ $j$ is the column number. For convenience, the #link("<Transform>")[`Transform`] also stores the inverse of `m` in its #link("<Transform::mInv>")[`Transform::mInv`] member variable; for `pbrt`'s needs, it is better to have the inverse easily available than to repeatedly compute it as needed.
][
  变换矩阵由矩阵元素 `m` 表示，该矩阵由 `SquareMatrix<4>` 对象表示。（`SquareMatrix` 类在#link("../Utilities/Mathematical_Infrastructure.html#sec:square-matrix")[第B.2.12节];中定义。）矩阵 `m` 以#emph[行主序];存储，因此元素 `m[i][j]` 对应于 $m_(i , j)$，其中 $i$ 是行号， $j$ 是列号。为了方便，`Transform` 还在其成员变量 #link("<Transform::mInv>")[`Transform::mInv`] 中存储了 `m` 的逆；对于 `pbrt` 的需求，将逆矩阵轻松可用比反复计算更为有效。
]
```cpp
 <<Transform Private Members>>=
`SquareMatrix<4> m, mInv;`
```
#parec[
  This representation of transformations is relatively memory hungry: assuming 4 bytes of storage for a `Float` value, a #link("<Transform>")[`Transform`] requires 128 bytes of storage. Used naïvely, this approach can be wasteful; if a scene has millions of shapes but only a few thousand unique transformations, there is no reason to redundantly store the same matrices many times. Therefore, #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];s in `pbrt` store a pointer to a `Transform` and the scene specification code defined in Section~#link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#sec:managing-xforms")[C.2.3] uses an #link("../Utilities/Containers_and_Memory_Management.html#InternCache")[`InternCache`] of #link("<Transform>")[`Transform`];s to ensure that all shapes that share the same transformation point to a single instance of that transformation in memory.
][
  这种变换的表示相对于内存消耗较大：假设 `Float` 值的存储空间为4字节，一个 `Transform` 需要128字节的存储空间。如果使用不当，这种方法可能会造成浪费；如果一个场景有数百万个形状但只有几千个独特的变换，就没有理由重复存储相同的矩阵多次。因此，`pbrt` 中的 `Shape` 存储一个指向 `Transform` 的指针，并且在#link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#sec:managing-xforms")[第C.2.3节];中定义的场景规范代码使用 #link("../Utilities/Containers_and_Memory_Management.html#InternCache")[`InternCache`] 中的 `Transform` 来确保所有共享同一变换的形状指向内存中该变换的单一实例。
]


=== Basic Operations
<basic-operations>

#parec[
  When a new #link("<Transform>")[Transform] is created, it defaults to the #emph[identity transformation];—the transformation that maps each point and each vector to itself. This transformation is represented by the #emph[identity matrix];:
][
  当创建一个新的#link("<Transform>")[Transform];时，它默认为#emph[恒等变换];——将每个点和每个向量映射到自身的变换。此变换由#emph[恒等矩阵];表示：
]

$
  upright(bold(I)) = mat(delim: #none, 1, 0, 0, 0;
0, 1, 0, 0;
0, 0, 1, 0;
0, 0, 0, 1) .
$
#parec[
  The implementation here relies on the default #link("../Utilities/Mathematical_Infrastructure.html#SquareMatrix")[SquareMatrix] constructor to fill in the identity matrix for `m` and `mInv`.
][
  这里的实现依赖于默认的#link("../Utilities/Mathematical_Infrastructure.html#SquareMatrix")[SquareMatrix];构造函数来填充`m`和`mInv`的恒等矩阵。
]


```cpp
Transform() = default;
```


#parec[
  A #link("<Transform>")[Transform] can also be created from a given matrix. In this case, the matrix must be explicitly inverted.
][
  也可以从给定的矩阵创建一个#link("<Transform>")[Transform];。在这种情况下，矩阵必须显式地求逆。
]




```cpp
Transform(const SquareMatrix<4> &m) : m(m) {
    pstd::optional<SquareMatrix<4>> inv = Inverse(m);
    if (inv)
        mInv = *inv;
    else {
        // Initialize mInv with not-a-number values
        Float NaN = std::numeric_limits<Float>::has_signaling_NaN
                                    ? std::numeric_limits<Float>::signaling_NaN()
                                    : std::numeric_limits<Float>::quiet_NaN();
        for (int i = 0; i < 4; ++i)
            for (int j = 0; j < 4; ++j)
                mInv[i][j] = NaN;
    }
}
```


#parec[
  If the matrix provided by the caller is degenerate and cannot be inverted, `mInv` is initialized with floating-point not-a-number values, which poison computations that involve them: arithmetic performed using a not-a-number value always gives a not-a-number value. In this way, a caller who provides a degenerate matrix `m` can still use the #link("<Transform>")[Transform] as long as no methods that access `mInv` are called.
][
  如果调用者提供的矩阵是退化的且无法求逆，`mInv`将用浮点非数字值初始化，这会影响涉及它们的计算：使用非数字值进行的算术运算总是会产生非数字值。这样，提供退化矩阵`m`的调用者仍然可以使用#link("<Transform>")[Transform];，只要不调用需要访问`mInv`的方法即可。
]

```cpp
Float NaN = std::numeric_limits<Float>::has_signaling_NaN
                         ? std::numeric_limits<Float>::signaling_NaN()
                         : std::numeric_limits<Float>::quiet_NaN();
for (int i = 0; i < 4; ++i)
    for (int j = 0; j < 4; ++j)
        mInv[i][j] = NaN;
```


#parec[
  Another constructor allows specifying the elements of the matrix using a regular 2D array.
][
  另一个构造函数允许使用常规二维数组指定矩阵的元素。
]


```cpp
Transform(const Float mat[4][4]) : Transform(SquareMatrix<4>(mat)) {}
```


#parec[
  The most commonly used constructor takes a reference to the transformation matrix along with an explicitly provided inverse. This is a superior approach to computing the inverse in the constructor because many geometric transformations have simple inverses, and we can avoid the expense and potential loss of numeric accuracy from computing a general $4 times 4$ matrix inverse. Of course, this places the burden on the caller to make sure that the supplied inverse is correct.
][
  最常用的构造函数接受一个变换矩阵的引用以及一个显式提供的逆矩阵。这是一种优于在构造函数中计算逆矩阵的方法，因为许多几何变换有简单的逆矩阵，我们可以避免计算一般 $4 times 4$ 矩阵逆矩阵的开销和潜在的数值精度损失。当然，这将责任放在调用者身上，以确保提供的逆矩阵是正确的。
]



```cpp
Transform(const SquareMatrix<4> &m, const SquareMatrix<4> &mInv)
    : m(m), mInv(mInv) {}
```
#parec[
  Both the matrix and its inverse are made available for callers that need to access them directly.
][
  矩阵及其逆矩阵都可供需要直接访问它们的调用者使用。
]


```cpp
const SquareMatrix<4> &GetMatrix() const { return m; }
const SquareMatrix<4> &GetInverseMatrix() const { return mInv; }
```


#parec[
  The #link("<Transform>")[Transform] representing the inverse of a `Transform` can be returned by just swapping the roles of `mInv` and `m`.
][
  表示`Transform`逆的#link("<Transform>")[Transform];可以通过交换`mInv`和`m`的角色返回。
]


```cpp
Transform Inverse(const Transform &t) {
    return Transform(t.GetInverseMatrix(), t.GetMatrix());
}
```


#parec[
  Transposing the two matrices in the transform to compute a new transform can also be useful.
][
  通过转置变换中的两个矩阵来计算新变换可能会有用。
]



```cpp
Transform Transpose(const Transform &t) {
    return Transform(Transpose(t.GetMatrix()),
                     Transpose(t.GetInverseMatrix()));
}
```

#parec[
  The `Transform` class also provides equality and inequality testing methods as well as an `IsIdentity()` method that checks to see if the transformation is the identity.
][
  `Transform`类还提供了等价和不等价测试方法以及一个`IsIdentity()`方法，用于检查变换是否为恒等变换。
]




```cpp
bool operator==(const Transform &t) const { return t.m == m; }
bool operator!=(const Transform &t) const { return t.m != m; }
bool IsIdentity() const { return m.IsIdentity(); }
```



=== Translations
<translations>


#parec[
  One of the simplest transformations is the #emph[translationtransformation];, $upright(bold(T))(Delta x, Delta y, Delta z)$. When applied to a point $p$, it translates $p$ 's coordinates by $Delta x$, $Delta y$, and $Delta z$, as shown in @fig:translateexample. As an example, $upright(bold(T))(2, 2, 1)(x, y, z) =(x + 2, y + 2, z + 1)$.
][
  最简单的变换之一是#emph[平移变换];， $upright(bold(T))(Delta x, Delta y, Delta z)$ 当应用于点 $p$ 时，它将 $p$ 的坐标平移 $Delta x$, $Delta y$, and $Delta z$，如@fig:translateexample 所示。例如， $upright(bold(T))(2, 2, 1)(x, y, z) =(x + 2, y + 2, z + 1)$。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f25.svg"),
  caption: [
    #ez_caption[ Translation in 2D. Adding offsets (x) and (y) to a point’s coordinates correspondingly changes its position in space. ][ 平移。将偏移量(x)和(y)添加到点的二维坐标，相应地改变其在空间中的位置。 ]

  ],
) <translateexample>

#parec[
  Translation has some basic properties:
][
  平移具有一些基本属性：
]


$
  bold("T") (0 , 0 , 0) & = bold("I")\
  bold("T") (x_1 , y_1 , z_1) bold("T") (x_2 , y_2 , z_2) & = bold("T") (x_1 + x_2 , y_1 + y_2 , z_1 + z_2)\
  bold("T") (x_1 , y_1 , z_1) bold("T") (x_2 , y_2 , z_2) & = bold("T") (x_2 , y_2 , z_2) bold("T") (x_1 , y_1 , z_1)\
  bold("T")^(- 1) (x , y , z) & = bold("T") (- x , - y , - z) .
$


#parec[
  Translation only affects points, leaving vectors unchanged. In matrix form, the translation transformation is
][
  平移只影响点，而不改变方向向量。在矩阵形式下，平移变换表示为
]

$
  bold("T") (
    Delta x , Delta y , Delta z
  ) = mat(delim: "[", 1, 0, 0, Delta x; 0, 1, 0, Delta y; 0, 0, 1, Delta z; 0, 0, 0, 1) .
$

#parec[
  When we consider the operation of a translation matrix on a point, we see the value of homogeneous coordinates. Consider the product of the matrix for $bold("T") (Delta x , Delta y , Delta z)$ with a point $upright(bold(p))$ in homogeneous coordinates $mat(delim: "[", x; y; z; 1)$ :
][
  当我们考虑平移矩阵对一个点的操作时，我们可以看到齐次坐标的作用。考虑矩阵 $bold("T") (Delta x , Delta y , Delta z)$ 与一个点 $upright(bold(p))$ 在 齐次坐标 $mat(delim: "[", x, comma, y, comma, z,  comma, 1)^T$ 中的乘积：
]

$
  mat(delim: "(", 1, 0, 0, Delta x; 0, 1, 0, Delta y; 0, 0, 1, Delta z; 0, 0, 0, 1) mat(delim: "(", x; y; z; 1) = mat(delim: "(", x + Delta x; y + Delta y; z + Delta z; 1) .
$


#parec[
  As expected, we have computed a new point with its coordinates offset by $(Delta x , Delta y , Delta z)$. However, if we apply $bold("T")$ to a vector $bold("v")$, we have
][
  如预期，我们计算出了一个新点，其坐标偏移为 $(Delta x , Delta y , Delta z)$。然而，如果我们将 $bold("T")$ 应用于一个向量 $bold("v")$，我们得到
]

$
  mat(delim: "(", 1, 0, 0, Delta x; 0, 1, 0, Delta y; 0, 0, 1, Delta z; 0, 0, 0, 1) mat(delim: "(", x; y; z; 0) = mat(delim: "(", x; y; z; 0) .
$


#parec[
  The result is the same vector $bold("v")$. This makes sense because vectors represent directions, so translation leaves them unchanged.
][
  结果仍然是相同的向量 $bold("v")$。这是合理的，因为向量表示的是方向，所以平移不改变它们。
]

#parec[
  The `Translate()` function returns a `Transform` that represents a given translation—it is a straightforward application of the translation matrix equation. The inverse of the translation is easily computed, so it is provided to the `Transform` constructor as well.
][
  `Translate()` 函数返回一个表示指定平移的 `Transform`——这是平移矩阵方程的直接应用。平移的逆变换很容易计算，因此也提供给 `Transform` 构造函数。
]

```cpp
Transform Translate(Vector3f delta) {
    SquareMatrix<4> m(1, 0, 0, delta.x,
                      0, 1, 0, delta.y,
                      0, 0, 1, delta.z,
                      0, 0, 0, 1);
    SquareMatrix<4> minv(1, 0, 0, -delta.x,
                         0, 1, 0, -delta.y,
                         0, 0, 1, -delta.z,
                         0, 0, 0, 1);
    return Transform(m, minv);
}
```

=== Scaling

#parec[
  Another basic transformation is the scale transformation, $bold("S") (s_x , s_y , s_z)$. It has the effect of taking a point or vector and multiplying its components by scale factors in $x$, $y$, and $z$ : $bold("S") (2 , 2 , 1) (x , y , z) = (2 x , 2 y , z)$. It has the following basic properties:
][
  另一种基本变换是缩放变换， $bold("S") (s_x , s_y , s_z)$。它的作用是将点或向量的各个分量乘以 $x$ 、 $y$ 和 $z$ 的缩放因子： $bold("S") (2 , 2 , 1) (x , y , z) = (2 x , 2 y , z)$。它具有以下基本属性：
]

$
  bold("S") (1 , 1 , 1) & = bold("I")\
  bold("S") (x_1 , y_1 , z_1) bold("S") (x_2 , y_2 , z_2) & = bold("S") (x_1 x_2 , y_1 y_2 , z_1 z_2)\
  bold("S") (x_1 , y_1 , z_1) bold("S") (x_2 , y_2 , z_2) & = bold("S") (x_2 , y_2 , z_2) bold("S") (x_1 , y_1 , z_1)\
  bold("S")^(- 1) (x , y , z) & = bold("S") (1 / x , 1 / y , 1 / z) .
$


#parec[
  We can differentiate between uniform scaling, where all three scale factors have the same value, and nonuniform scaling, where they may have different values. The general scale matrix is
][
  我们可以区分均匀缩放（即三个缩放因子相同）和非均匀缩放（即缩放因子不同）。一般的缩放矩阵是
]


$ upright(bold(S)) (x , y , z) = mat(delim: "(", x, 0, 0, 0; 0, y, 0, 0; 0, 0, z, 0; 0, 0, 0, 1) . $

```cpp
<<Transform Function Definitions>>+=
Transform Scale(Float x, Float y, Float z) {
    SquareMatrix<4> m(x, 0, 0, 0,
                      0, y, 0, 0,
                      0, 0, z, 0,
                      0, 0, 0, 1);
    SquareMatrix<4> minv(1 / x,     0,     0, 0,
                             0, 1 / y,     0, 0,
                             0,     0, 1 / z, 0,
                             0,     0,     0, 1);
    return Transform(m, minv);
}
```


#parec[
  It is useful to be able to test if a transformation has a scaling term in it; an easy way to do this is to transform the three coordinate axes and see if any of their lengths are appreciably different from one.
][
  能够测试一个变换中是否有缩放项是很有用的；一个简单的方法是对三个坐标轴进行变换，观察它们的长度是否显著不同于一。
]


```cpp
bool HasScale(Float tolerance = 1e-3f) const {
    Float la2 = LengthSquared((*this)(Vector3f(1, 0, 0)));
    Float lb2 = LengthSquared((*this)(Vector3f(0, 1, 0)));
    Float lc2 = LengthSquared((*this)(Vector3f(0, 0, 1)));
    return (std::abs(la2 - 1) > tolerance ||
            std::abs(lb2 - 1) > tolerance ||
            std::abs(lc2 - 1) > tolerance);
}
```

=== $x$, $y$, and $z$ Axis Rotations



#parec[
  Another useful type of transformation is the #emph[rotation
transformation];, $upright(bold(R))$. In general, we can define an arbitrary axis from the origin in any direction and then rotate around that axis by a given angle. The most common rotations of this type are around the $x$, $y$, and $z$ coordinate axes. We will write these rotations as $upright(bold(R))_x (theta)$, $upright(bold(R))_y (theta)$, and so on. The rotation around an arbitrary axis $(x , y , z)$ is denoted by $upright(bold(R))_((x , y , z)) (theta)$.
][
  另一种有用的变换类型是#emph[旋转变换];，记作 $upright(bold(R))$。通常，我们可以从原点定义一个任意方向的轴，然后围绕该轴旋转一个给定的角度。这种类型最常见的旋转是围绕 $x$ 、 $y$ 和 $z$ 坐标轴。我们将这些旋转写为 $upright(bold(R))_x (theta)$ 、 $upright(bold(R))_y (theta)$ 等。围绕任意轴 $(x , y , z)$ 的旋转记作 $upright(bold(R))_((x , y , z)) (theta)$。
]

#parec[
  Rotations also have some basic properties:
][
  旋转还有一些基本性质：
]

$
  upright(bold(R))_a (0) & = upright(bold(I))\
  upright(bold(R))_a (theta_1) upright(bold(R))_a (theta_2) & = upright(bold(R))_a (theta_1 + theta_2)\
  upright(bold(R))_a (theta_1) upright(bold(R))_a (theta_2) & = upright(bold(R))_a (theta_2) upright(bold(R))_a (
    theta_1
  )\
  upright(bold(R))_a^(- 1) (theta) & = upright(bold(R))_a (- theta) = upright(bold(R))_a^(upright(T)) (theta) ,
$


#parec[
  where $upright(bold(R))^(upright(T))$ is the matrix transpose of $upright(bold(R))$. This last property, that the inverse of $upright(bold(R))$ is equal to its transpose, stems from the fact that $upright(bold(R))$ is an #emph[orthogonal matrix];; its first three columns (or rows) are all normalized and orthogonal to each other. Fortunately, the transpose is much easier to compute than a full matrix inverse.
][
  其中 $upright(bold(R))^(upright(T))$ 是 $upright(bold(R))$ 的转置矩阵。最后一个性质，即 $upright(bold(R))$ 的逆矩阵等于其转置矩阵，源于 $upright(bold(R))$ 是一个#emph[正交矩阵];；它的前三列（或行）都是标准化的并且彼此正交。幸运的是，计算转置矩阵比计算完整的逆矩阵要容易得多。
]

#parec[
  For a left-handed coordinate system, the matrix for clockwise rotation around the $x$ axis is
][
  对于左手坐标系，绕 $x$ 轴顺时针旋转的矩阵为
]
$
  upright(bold(R))_x (
    theta
  ) = mat(delim: "[", 1, 0, 0, 0; 0, cos theta, - sin theta, 0; 0, sin theta, cos theta, 0; 0, 0, 0, 1) .
$


#parec[
  Figure 3.26 gives an intuition for how this matrix works.
][
  图 3.26 给出了这个矩阵如何工作的直观理解。
]

#parec[
  It is easy to see that the matrix leaves the $x$ axis unchanged:
][
  很容易看出矩阵保持 $x$ 轴不变：
]


$
  upright(bold(R))_x (theta)(mat(delim: #none, 1; 0; 0; 0))^T =(mat(delim: #none, 1; 0; 0; 0))^T .
$
#parec[
  It maps the $y$ axis $(0 , 1 , 0)$ to $(0 , cos theta , sin theta)$ and the $z$ axis to $(0 , - sin theta , cos theta)$. The $y$ and $z$ axes remain in the same plane, perpendicular to the $x$ axis, but are rotated by the given angle. An arbitrary point in space is similarly rotated about the $x$ axis by this transformation while staying in the same $y z$ plane as it was originally.
][
  它将 $y$ 轴 $(0 , 1 , 0)$ 映射到 $(0 , cos theta , sin theta)$，将 $z$ 轴映射到 $(0 , - sin theta , cos theta)$。 $y$ 和 $z$ 轴保持在同一平面内，与 $x$ 轴垂直，但旋转了给定的角度。空间中的任意点通过此变换同样绕 $x$ 轴旋转，且保持在原来的 $y z$ 平面内。
]

#parec[
  The implementation of the `RotateX()` function is straightforward.
][
  `RotateX()` 函数的实现很简单。
]

```
Transform RotateX(Float theta) {
    Float sinTheta = std::sin(Radians(theta));
    Float cosTheta = std::cos(Radians(theta));
    SquareMatrix<4> m(1,        0,         0, 0,
                      0, cosTheta, -sinTheta, 0,
                      0, sinTheta,  cosTheta, 0,
                      0,        0,         0, 1);
    return Transform(m, Transpose(m));
}
```

#parec[
  Similarly, for clockwise rotation around $y$ and $z$, we have
][
  类似地，对于绕 $y$ 和 $z$ 的顺时针旋转，我们有
]

$
  upright(bold(R))_y (
    theta
  ) = mat(delim: "[", cos theta, 0, sin theta, 0; 0, 1, 0, 0; - sin theta, 0, cos theta, 0; 0, 0, 0, 1) quad upright(bold(R))_z (
    theta
  ) = mat(delim: "[", cos theta, - sin theta, 0, 0; sin theta, cos theta, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1) .
$


#parec[
  The implementations of `RotateY()` and `RotateZ()` follow directly and are not included here.
][
  `RotateY()` 和 `RotateZ()` 的实现直接得出，这里不再包括。
]

=== Rotation around an Arbitrary Axis
<rotation-around-an-arbitrary-axis>
#parec[
  We also provide a routine to compute the transformation that represents rotation around an arbitrary axis. A common derivation of this matrix is based on computing rotations that map the given axis to a fixed axis (e.g., $z$ ), performing the rotation there, and then rotating the fixed axis back to the original axis. A more elegant derivation can be constructed with vector algebra.
][
  我们还提供了一个例程来计算表示绕任意轴旋转的变换。这个矩阵的常见推导基于计算将给定轴映射到固定轴（例如 $z$ ）的旋转，在那里执行旋转，然后将固定轴旋转回原始轴。可以用向量代数构建一个更优雅的推导。
]

#parec[
  Consider a normalized direction vector $upright(bold(a))$ that gives the axis to rotate around by angle $theta$, and a vector $upright(bold(v))$ to be rotated (Figure 3.27).
][
  考虑一个标准化方向向量 $upright(bold(a))$，它给出了绕其旋转的轴和一个要旋转的向量 $upright(bold(v))$ （图 3.27）。
]

#parec[
  First, we can compute the vector $upright(bold(v))_c$ along the axis $upright(bold(a))$ that is in the plane through the end point of $upright(bold(v))$ and is parallel to $upright(bold(a))$. Assuming $upright(bold(v))$ and $upright(bold(a))$ form an angle $alpha$, we have
][
  首先，我们可以计算沿轴 $upright(bold(a))$ 的向量 $upright(bold(v))_c$，它在通过 $upright(bold(v))$ 的终点的平面中并且与 $upright(bold(a))$ 平行。假设 $upright(bold(v))$ 和 $upright(bold(a))$ 形成一个角度 $alpha$，我们有
]

$
  upright(bold(v))_(upright(bold(c))) = upright(bold(a)) parallel upright(bold(v)) parallel cos alpha = upright(bold(a)) (
    upright(bold(v)) dot.op upright(bold(a))
  ) .
$



#parec[
  We now compute a pair of basis vectors $upright(bold(v))_1$ and $upright(bold(v))_2$ in this plane. Trivially, one of them is
][
  现在我们在这个平面上计算一对基向量 $upright(bold(v))_1$ 和 $upright(bold(v))_2$。显然，其中一个基向量为
]

$ upright(bold(v))_1 = upright(bold(v)) - upright(bold(v))_(upright(bold(c))) , $


#parec[
  and the other can be computed with a cross product
][
  另一个可以通过叉积计算
]

$ upright(bold(v))_2 = (upright(bold(v))_1 times upright(bold(a))) . $


#parec[
  Because $upright(bold(a))$ is normalized, $upright(bold(v))_1$ and $upright(bold(v))_2$ have the same length, equal to the length of the vector between $upright(bold(v))$ and $upright(bold(v))_(upright(bold(c)))$. To now compute the rotation by an angle $theta$ about $upright(bold(v))_(upright(bold(c)))$ in the plane of rotation, the rotation formulae earlier give us
][
  因为 $upright(bold(a))$ 是单位向量， $upright(bold(v))_1$ 和 $upright(bold(v))_2$ 具有相同的长度，等于向量 $upright(bold(v))$ 减去 $upright(bold(v))_(upright(bold(c)))$ 的长度。现在要计算绕 $upright(bold(v))_(upright(bold(c)))$ 在旋转平面内旋转角度 $theta$ 的旋转，之前的旋转公式给出
]

$
  upright(bold(v)) prime = upright(bold(v))_(upright(bold(c))) + upright(bold(v))_1 cos theta + upright(bold(v))_2 sin theta .
$


#parec[
  To convert this to a rotation matrix, we apply this formula to the basis vectors $(1 , 0 , 0)$, $(0 , 1 , 0)$, and $(0 , 0 , 1)$ to get the values of the rows of the matrix. The result of all this is encapsulated in the following function. As with the other rotation matrices, the inverse is equal to the transpose.
][
  要将其转换为旋转矩阵，我们将此公式应用于标准基向量 $(1 , 0 , 0)$, $(0 , 1 , 0)$ 和 $(0 , 0 , 1)$ 以获取矩阵行的值。所有这些的结果都封装在以下函数中。与其他旋转矩阵一样，其逆矩阵等于其转置矩阵。
]



#parec[
  Because some callers of the `Rotate()` function already have $sin theta$ and $cos theta$ at hand, `pbrt` provides a variant of the function that takes those values directly.
][
  因为 `Rotate()` 函数的一些调用者已经有 $sin theta$ 和 $cos theta$，`pbrt` 提供了一个直接接受这些值的函数变体。
]

```cpp
Transform Rotate(Float sinTheta, Float cosTheta, Vector3f axis) {
    Vector3f a = Normalize(axis);
    SquareMatrix<4> m;
    <<Compute rotation of first basis vector>>       m[0][0] = a.x * a.x + (1 - a.x * a.x) * cosTheta;
       m[0][1] = a.x * a.y * (1 - cosTheta) - a.z * sinTheta;
       m[0][2] = a.x * a.z * (1 - cosTheta) + a.y * sinTheta;
       m[0][3] = 0;
    <<Compute rotations of second and third basis vectors>>       m[1][0] = a.x * a.y * (1 - cosTheta) + a.z * sinTheta;
       m[1][1] = a.y * a.y + (1 - a.y * a.y) * cosTheta;
       m[1][2] = a.y * a.z * (1 - cosTheta) - a.x * sinTheta;
       m[1][3] = 0;

       m[2][0] = a.x * a.z * (1 - cosTheta) - a.y * sinTheta;
       m[2][1] = a.y * a.z * (1 - cosTheta) + a.x * sinTheta;
       m[2][2] = a.z * a.z + (1 - a.z * a.z) * cosTheta;
       m[2][3] = 0;
    return Transform(m, Transpose(m));
}
```

```cpp
m[0][0] = a.x * a.x + (1 - a.x * a.x) * cosTheta;
m[0][1] = a.x * a.y * (1 - cosTheta) - a.z * sinTheta;
m[0][2] = a.x * a.z * (1 - cosTheta) + a.y * sinTheta;
m[0][3] = 0;
```

#parec[
  The code for the other two basis vectors follows similarly and is not included here.
][
  其他两个基向量的代码类似，这里不包括。
]

#parec[
  A second variant of `Rotate()` takes the angle $theta$ in degrees, computes its sine and cosine, and calls the first.
][
  `Rotate()` 的第二个变体接受角度 $theta$ （以度为单位），计算其正弦和余弦，然后调用第一个。
]

```cpp
Transform Rotate(Float theta, Vector3f axis) {
    Float sinTheta = std::sin(Radians(theta));
    Float cosTheta = std::cos(Radians(theta));
    return Rotate(sinTheta, cosTheta, axis);
}
```

=== Rotating One Vector to Another
<rotating-one-vector-to-another>


#parec[
  It is sometimes useful to find the transformation that performs a rotation that aligns one unit vector $upright(bold(f))$ with another $upright(bold(t))$ (where $upright(bold(f))$ denotes "from" and $upright(bold(t))$ denotes "to"). One way to do so is to define a rotation axis by the cross product of the two vectors, compute the rotation angle as the arccosine of their dot product, and then use the `Rotate()` function. However, this approach not only becomes unstable when the two vectors are nearly parallel but also requires a number of expensive trigonometric function calls.
][
  有时，找到执行旋转的变换以将一个单位向量 $upright(bold(f))$ 对齐到另一个单位向量 $upright(bold(t))$ 是很有用的（其中 $upright(bold(f))$ 表示“从”， $upright(bold(t))$ 表示“到”）。一种方法是通过两个向量的叉积定义旋转轴，计算它们点积的反余弦作为旋转角度，然后使用 `Rotate()` 函数。 然而，这种方法不仅在两个向量几乎平行时变得不稳定，而且还需要大量昂贵的三角函数调用。
]

#parec[
  A different approach to deriving this rotation matrix is based on finding a pair of reflection transformations that reflect $upright(bold(f))$ to an intermediate vector $upright(bold(r))$ and then reflect $upright(bold(r))$ to $upright(bold(t))$. The product of such a pair of reflections gives the desired rotation. The #emph[Householder matrix] $upright(bold(H))(upright(bold(v)))$ provides a way to find these reflections: it reflects the given vector $upright(bold(v))$ to its negation $- upright(bold(v))$ while leaving all vectors orthogonal to $upright(bold(v))$ unchanged and is defined as
][
  一种不同的方法是基于找到一对反射变换，将 $upright(bold(f))$ 反射到一个中间向量 $upright(bold(r))$，然后将 $upright(bold(r))$ 反射到 $upright(bold(t))$。这样一对反射的乘积给出了所需的旋转。 #emph[Householder 矩阵] $upright(bold(H))(upright(bold(v)))$ 提供了一种找到这些反射的方法：它将给定向量 $upright(bold(v))$ 反射到其相反方向 $- upright(bold(v))$，同时保持所有与 $upright(bold(v))$ 垂直的向量不变，定义为
]

$
  upright(bold(H))(
    upright(bold(v))
  ) = upright(bold(I)) - frac(2, upright(bold(v)) dot.op upright(bold(v))) upright(bold(v)) upright(bold(v))^T,
$

#parec[
  where $upright(bold(I))$ is the identity matrix.
][
  其中 $upright(bold(I))$ 是单位矩阵。
]

#parec[
  With the product of the two reflections
][
  通过两次反射变换的组合
]

$
  upright(bold(R)) = upright(bold(H)) (upright(bold(r)) - upright(bold(t))) upright(bold(H)) (
    upright(bold(r)) - upright(bold(f))
  ) ,
$


$ (3.10) $


#parec[
  the second matrix reflects $upright(bold(f))$ to $upright(bold(r))$ and the first then reflects $upright(bold(r))$ to $upright(bold(t))$, which together give the desired rotation.
][
  第二个矩阵将 $upright(bold(f))$ 反射到 $upright(bold(r))$，然后第一个矩阵将 $upright(bold(r))$ 反射到 $upright(bold(t))$，这两个矩阵共同实现了所需的旋转。
]

```cpp
Transform RotateFromTo(Vector3f from, Vector3f to) {
    <<Compute intermediate vector for vector reflection>>
    Vector3f refl;
    if (std::abs(from.x) < 0.72f && std::abs(to.x) < 0.72f)
        refl = Vector3f(1, 0, 0);
    else if (std::abs(from.y) < 0.72f && std::abs(to.y) < 0.72f)
        refl = Vector3f(0, 1, 0);
    else
        refl = Vector3f(0, 0, 1);
    <<Initialize matrix r for rotation>>
    Vector3f u = refl - from, v = refl - to;
    SquareMatrix<4> r;
    for (int i = 0; i < 3; ++i)
        for (int j = 0; j < 3; ++j)
            <<Initialize matrix element r[i][j]>>
            r[i][j] = ((i == j) ? 1 : 0) -
                      2 / Dot(u, u) * u[i] * u[j] -
                      2 / Dot(v, v) * v[i] * v[j] +
                      4 * Dot(u, v) / (Dot(u, u) * Dot(v, v)) * v[i] * u[j];
    return Transform(r, Transpose(r));
}
```


#parec[
  The intermediate reflection direction `refl` is determined by choosing a basis vector that is not too closely aligned to either of the `from` and `to` vectors. In the computation here, because $0.72$ is just slightly greater than $sqrt(2)\/2$, the absolute value of at least one pair of matching coordinates must then both be less than $0.72$, assuming the vectors are normalized. In this way, a loss of accuracy is avoided when the reflection direction is nearly parallel to either `from` or `to`.
][
  中间反射方向 `refl` 是通过选择一个与 `from` 和 `to` 向量 不太接近的基向量来确定的。在这里的计算中，因为 $0.72$ 略大于 $sqrt(2)\/2$ ，所以至少有一对匹配坐标的绝对值必须都小于 $0.72$，假设这些向量是归一化的。这样可以避免反射方向几乎与 `from` 或 `to` 平行时的精度损失。
]

```cpp
Vect  or3f refl;
  if (std::abs(from.x) < 0.72f && std::abs(to.x) < 0.72f)
      refl = Vector3f(1, 0, 0);
  else if (std::abs(from.y) < 0.72f && std::abs(to.y) < 0.72f)
      refl = Vector3f(0, 1, 0);
  else
    refl = Vector3f(0, 0, 1);
```


#parec[
  Given the reflection axis, the matrix elements can be initialized directly.
][
  给定反射轴，矩阵元素可以直接初始化。
]

```cpp
  Vector3f u = refl - from, v = refl - to;
Squa  reMatrix<4> r;
for (int   i = 0; i < 3; ++i)
    for   (int j= 0; j < 3; ++j)
        <<Initiali  ze matrix element r[i][j]>>
        r[i][j] =   ((i == j) ? 1 : 0) -
                    2 / Dot(u, u) * u[i] * u[j] -
                    2 / Dot(v, v) * v[i] * v[j] +
                  4 * Dot(u, v) / (Dot(u, u) * Dot(v, v)) * v[i] * u[j];
```


#parec[
  Expanding the product of the Householder matrices in Equation (3.10), we can find that the matrix element $r_(i , j)$ is given by
][
  通过展开方程 (3.10) 中 Householder 矩阵的乘积，我们可以发现矩阵元素 $r_(i , j)$ 给出为
]

$
  delta_(i , j) - frac(2, upright(bold(u)) dot.op upright(bold(u))) upright(bold(u))_i upright(bold(u))_j - frac(2, upright(bold(v)) dot.op upright(bold(v))) upright(bold(v))_i upright(bold(v))_j + frac(4 (upright(bold(u)) dot.op upright(bold(v))), (upright(bold(u)) dot.op upright(bold(u))) (upright(bold(v)) dot.op upright(bold(v)))) upright(bold(v))_i upright(bold(u))_j ,
$



#parec[
  where $delta_(i,j)$ is the Kronecker delta function that is 1 if $i$ and $j$ are equal and 0 otherwise. The implementation follows directly.
][
  其中 $delta_(i,j)$ 是 Kronecker delta 函数，即当 $i$ 和 $j$ 相等时为 1，否则为 0。实现直接遵循。
]



```cpp
r[  i][j] =   ((i == j) ? 1 : 0) -
            2 / Dot(u, u) * u[i] * u[j] -
            2 / Dot(v, v) * v[i] * v[j] +
          4 * Dot(u, v) / (Dot(u, u) * Dot(v, v)) * v[i] * u[j];
```

=== The Look-at Transformation
<the-look-at-transformation>

#parec[
  The #emph[look-at transformation] is particularly useful for placing a camera in the scene. The caller specifies the desired position of the camera, a point the camera is looking at, and an "up" vector that orients the camera along the viewing direction implied by the first two parameters. All of these values are typically given in world-space coordinates; this gives a transformation from world space to camera space (Figure 3.28). We will assume that use in the discussion below, though note that this way of specifying transformations can also be useful for placing light sources in the scene.
][
  #emph[观察变换] 在场景中放置相机时特别有用。调用者指定相机的期望位置、相机正在观察的点以及一个“向上”向量，该向量沿着由前两个参数隐含的视图方向定向相机。所有这些值通常以世界空间坐标给出；这提供了从世界空间到相机空间的变换（图 3.28）。我们将在下面的讨论中假设使用这种方式，尽管这种指定变换的方法也可以用于在场景中放置光源。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f28.svg"),

  caption: [

    #ez_caption[
      Figure 3.28: Given a camera position, the position being looked at from
      the camera, and an "up" direction, the look-at transformation describes
      a transformation from a left-handed viewing coordinate system where the
      camera is at the origin looking down the $+ z$ axis, and the $+ y$ axis
      is along the up direction.

    ][
      图
      3.28：给定相机位置、从相机观察的位置和“向上”方向，观察变换描述了从左手视图坐标系的变换，其中相机位于原点，沿着
      $+ z$ 轴观察，$+ y$ 轴沿着向上方向。
    ]
  ],
)


#parec[
  In order to find the entries of the look-at transformation matrix, we use principles described earlier in this section: the columns of a transformation matrix give the effect of the transformation on the basis of a coordinate system.
][
  为了找到观察变换矩阵的条目，我们使用本节前面描述的原则：变换矩阵的列给出了变换对坐标系基的影响。
]

```cpp
  Transform LookAt(Point3f pos, Point3f look, Vectorf up) {
      SquareMatrix<4> worldFromCamera;
      <<Initialize fourth column of viewing matrix>>
      worldFromCamera[0][3] = pos.x;
      worldFromCamera[1][3] = pos.y;
      worldFromCamera[2][3] = pos.z;
      worldFromCamer[3][3] = 1;
      <<Initialize first three columns of viewing matrix>>
      Vector3f dir = Normalize(look - pos);
      Vector3f right = Normalize(Cross(Normalize(up), dir));
      Vector3f newUp = Cross(dir, right);
      worldFromCamera[0][0] = right.x;
      worldFromCamera[1][0] = right.y;
      worldFromCamera[2][0] = right.z;
      worldFromCamera[3][0] = 0.;
      worldFromCamera[0][1] = newUp.x;
      worldFromCamera[1][1] = newUp.y;
      worldFromCamera[2][1] = newUp.z;
      worldFromCamera[3][1] = 0.;
      worldFromCamera[0][2] = dir.x;
      worldFromCamera[1][2] = dir.y;
      worldFromCamera[2][2] = dir.z;
      worldFromCamera[3][2] = 0.;
      SquareMatrix<4> cameraFromWorld = InvertOrExit(worldFromCamera);
      return Transform(cameraFromWorld, worldFromCamera);
}
```


#parec[
  The easiest column is the fourth one, which gives the point that the camera-space origin, $[0 thin 0 thin 0 thin 1]^(upright(T))$, maps to in world space. This is clearly just the camera position, supplied by the user.
][
  最简单的列是第四列，它给出了相机空间原点 $[0 thin 0 thin 0 thin 1]^(upright(T))$ 在世界空间中映射到的点。这显然就是用户指定的相机位置。
]

```cpp
  worldFromCamera[0][3] = pos.x;
  worldFromCamera[1][3] = pos.y;
  worldFromCamera[2][3] = pos.z;
worldFromCamera[3][3] = 1;
```


#parec[
  The other three columns are not much more difficult. First, `LookAt()` computes the normalized direction vector from the camera location to the look-at point; this gives the vector coordinates that the $z$ axis should map to and, thus, the third column of the matrix. (In a left-handed coordinate system, camera space is defined with the viewing direction down the $+ z$ axis.) The first column, giving the world-space direction that the $+ x$ axis in camera space maps to, is found by taking the cross product of the user-supplied "up" vector with the recently computed viewing direction vector. Finally, the "up" vector is recomputed by taking the cross product of the viewing direction vector with the transformed $x$ axis vector, thus ensuring that the $y$ and $z$ axes are perpendicular and we have an orthonormal viewing coordinate system.
][
  其他三列也不难。首先，`LookAt()` 计算从相机位置到观察点的归一化方向向量；这给出了 $z$ 轴应该映射到的向量坐标，从而给出了矩阵的第三列。（在左手坐标系中，相机空间定义为沿着 $+ z$ 轴的视图方向。）第一列，给出相机空间中 $+ x$ 轴映射到的世界空间方向，是通过用户提供的“向上”向量与最近计算的视图方向向量的叉积得到的。最后，通过视图方向向量与变换后的 $x$ 轴向量的叉积重新计算“向上”向量，从而确保 $y$ 轴和 $z$ 轴是垂直的，并且我们有一个正交的视图坐标系。
]

```cpp
  Vector3f dir = Normalize(look - pos);
  Vector3f right = Normalize(Cross(Normalize(up), dir));
  Vector3f newUp = Cross(dir, right);
  worldFromCamera[0][0] = right.x;
  worldFromCamera[1][0] = right.y;
  worldFromCamera[2][0] = right.z;
  worldFromCamera[3][0] = 0.;
  worldFromCamera[0][1] = newUp.x;
  worldFromCamera[1][1] = newUp.y;
  worldFromCamera[2][1] = newUp.z;
  worldFromCamera[3][1] = 0.;
  worldFromCamera[0][2] = dir.x;
  worldFromCamera[1][2] = dir.y;
  worldFromCamera[2][2] = dir.z;
worldFromCamera[3][2] = 0.;

```