#import "../template.typ": parec, ez_caption

== Spherical Geometry
<Spherical_Geometry>

#parec[
  Geometry on the unit sphere is also frequently useful in rendering. 3D unit direction vectors can equivalently be represented as points on the unit sphere, and sets of directions can be represented as areas on the unit sphere. Useful operations such as bounding a set of directions can often be cleanly expressed as bounds on the unit sphere. We will therefore introduce some useful principles of spherical geometry and related classes and functions in this section.
][
  在渲染中，单位球上的几何也常常是有用的。3D单位方向向量可以等效地表示为单位球上的点，方向的集合可以表示为单位球上的区域。诸如限制方向集合等有用的操作通常可以简洁地表达为单位球上的边界。因此，我们将在本节中介绍一些球面几何的有用原理以及相关的类和函数。
]

=== Solid Angles
<solid-angles>


#parec[
  In 2D, the #emph[planar angle] is the total angle subtended by some object with respect to some position (@fig:plane-angle ). Consider the unit circle around the point p; if we project the shaded object onto that circle, some length of the circle s will be covered by its projection. The arc length of s (which is the same as the angle $theta$ ) is the angle subtended by the object. Planar angles are measured in #emph[radians] and the entire unit circle covers $2 pi$ radians.
][
  在二维中，#emph[平面角];是某个物体相对于某个位置所形成的总角度（@fig:plane-angle）。考虑点 p 周围的单位圆；如果我们将阴影物体投影到该圆上，圆的一部分 s 将被其投影覆盖。弧长 s（即角度 $theta$ ）是物体所形成的角度。平面角以#emph[弧度];为单位测量，整个单位圆覆盖 $2pi$ 弧度。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f12.svg"),
  caption: [
    #ez_caption[_Planar Angle._ The planar angle of an object as seen from a point $p$ is equal to the angle it subtends as seen from $p$ or, equivalently, as the length of the arc $s$ on the unit sphere.][_平面角。_ 从点 $p$ 观察到的物体的平面角等于从 $p$ 处观察到的该物体所对的角度，或者等价地，等于单位球面上弧长 $s$ 的长度。]
  ],
)<plane-angle>

#parec[
  The solid angle extends the 2D unit circle to a 3D unit sphere (@fig:solid-angle ). The total area s is the solid angle subtended by the object. Solid angles are measured in #emph[steradians] (sr). The entire sphere subtends a solid angle of $4 pi$ sr, and a hemisphere subtends $2 pi$ sr.
][
  立体角将二维单位圆扩展到三维单位球（@fig:solid-angle ）。总面积 s 是物体在单位球上投影的面积。立体角以#emph[球面弧度];（sr）为单位测量。整个球形成的立体角为 $4pi$ sr，半球形成的立体角为 $2 pi$ sr。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f13.svg"),
  caption: [
    #ez_caption[The solid angle $s$ subtended by a 3D object is computed by projecting the object onto the unit sphere and measuring the area of its projection.][立体角。立体角 3D 对象所包围的面积是通过将对象投影到单位球体上并测量其投影面积来计算的。]
  ],
)<solid-angle>

#parec[
  By providing a way to measure area on the unit sphere (and thus over the unit directions), the solid angle also provides the foundation for a measure for integrating spherical functions; the #emph[differential solid angle] $d omega$ corresponds to the differential area measure on the unit sphere.
][
  通过提供一种在单位球上测量面积的方法（从而在单位方向上），立体角也为积分球面函数的度量提供了基础；#emph[微分立体角] $d omega$ 对应于单位球上的微分面积度量。
]

=== Spherical Polygons
<Spherical_Polygons>
#parec[
  We will sometimes find it useful to consider the set of directions from a point to the surface of a polygon. (Doing so can be useful, for example, when computing the illumination arriving at a point from an emissive polygon.) If a regular planar polygon is projected onto the unit sphere, it forms a #emph[spherical polygon];.
][
  有时我们会发现考虑从一点到多边形表面的方向集合是有用的。（例如，在计算从发光多边形到一点的照明时，这样做可能是有用的。）如果将一个常规平面多边形投影到单位球上，它就形成了一个#emph[球面多边形];。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f14.svg"),
  caption: [
    #ez_caption[A spherical polygon corresponds to the projection of a polygon onto the unit sphere. Its vertices correspond to the unit vectors to the original polygon's vertices and its edges are defined by the intersection of the sphere and the planes that go through the sphere's center and two vertices of the polygon.][球形多边形对应于多边形在单位球面上的投影。它的顶点对应于原始多边形顶点的单位向量，其边缘由球体和穿过球体中心和多边形两个顶点的平面的交集定义。]
  ],
)<spherical-polygon>

#parec[
  A vertex of a spherical polygon can be found by normalizing the vector from the center of the sphere to the corresponding vertex of the original polygon. Each edge of a spherical polygon is given by the intersection of the unit sphere with the plane that goes through the sphere's center and the corresponding two vertices of the polygon. The result is a #emph[great circle] on the sphere that is the shortest distance between the two vertices on the surface of the sphere (@fig:spherical-polygon ).
][
  球面多边形的顶点可以通过将从球心到原始多边形相应顶点的向量归一化来找到。球面多边形的每条边由单位球与通过球心和多边形相应两个顶点的平面的交线给出。结果是在球面上两个顶点之间的最短距离的#emph[大圆];（@fig:spherical-polygon ）。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f15.svg"),
  caption: [
    #ez_caption[ A Spherical Triangle. Each vertex's angle is labeled with the Greek letter corresponding to the letter used for its vertex.
    ][ 球面三角形。每个顶点的角度都标有与其顶点所用字母相对应的希腊字母。]
  ],
)<spherical-triangle>


#parec[
  The angle at each vertex is given by the angle between the planes corresponding to the two edges that meet at the vertex (@fig:spherical-triangle ). (The angle between two planes is termed their #emph[dihedral angle];.) We will label the angle at each vertex with the Greek letter that corresponds to its label ( $alpha$ for the vertex a and so forth). Unlike planar triangles, the three angles of a spherical triangle do not sum to $pi$ radians; rather, their sum is $pi$ + A, where A is the spherical triangle's area. Given the angles $alpha$, $beta$, and $gamma$, it follows that the area of a spherical triangle can be computed using #emph[Girard's theorem];, which says that a triangle's surface area A on the unit sphere is given by the "excess angle" A = $alpha$ + $beta$ + $gamma$ - $pi$.
][
  每个顶点的角度由在该顶点相交的两条边对应的平面之间的角度给出（@fig:spherical-triangle ）。（两个平面之间的角度称为它们的#emph[二面角];。）我们将用与其标签对应的希腊字母标记每个顶点的角度（顶点 a 的角度为 $alpha$ 等）。与平面三角形不同，球面三角形的三个角度之和不等于 $pi$ 弧度；而是它们的和为 $pi + A$，其中 A 是球面三角形的面积。 给定角度 $alpha$, $beta$ 和 $gamma$，可以使用#emph[吉拉德定理];计算球面三角形的面积，该定理指出单位球上三角形的表面积 A 由“超角”给出 $A = alpha + beta + gamma - pi$。
]


$ A = alpha + beta + gamma - pi . $ <girards-theorem>

#parec[
  Direct implementation of @eqt:girards-theorem requires multiple calls to expensive inverse trigonometric functions, and its computation can be prone to error due to floating-point cancellation. A more efficient and accurate approach is to apply the relationship
][
  直接实现@eqt:girards-theorem 需要多次调用计算量大的反三角函数，并且由于浮点数消除，其计算可能容易出错。更高效且准确的方法是应用以下关系
]

$
  tan(frac(1, 2) A) = frac(upright(bold(a)) dot (upright(bold(b)) times upright(bold(c))), 1 +(upright(bold(a)) dot.op upright(bold(b))) +(upright(bold(a)) dot.op upright(bold(c))) +(upright(bold(b)) dot.op upright(bold(c)))),
$<triangle-solid-angle-better>

#parec[
  which can be derived from @eqt:girards-theorem using spherical trigonometric identities. That approach is used in `SphericalTriangleArea()`, which takes three vectors on the unit sphere corresponding to the spherical triangle's vertices.
][
  这种方法可以使用球面三角恒等式从@eqt:girards-theorem 推导出。在`SphericalTriangleArea()`中使用，该函数接收单位球面上对应于球面三角形顶点的三个向量。
]

```cpp
Float SphericalTriangleArea(Vector3f a, Vector3f b, Vector3f c) {
    return std::abs(2 * std::atan2(Dot(a, Cross(b, c)),
                                   1 + Dot(a, b) + Dot(a, c) + Dot(b, c)));
}
```

#parec[
  The area of a quadrilateral projected onto the unit sphere is given by $alpha + beta + gamma + delta - 2 pi$ , where $alpha$, $beta$, $gamma$ and $delta$ are its interior angles. This value is computed by `SphericalQuadArea()`, which takes the vertex positions on the unit sphere. Its implementation is very similar to #link("<SphericalTriangleArea>")[`SphericalTriangleArea()`];, so it is not included here.
][
  投影到单位球面上的四边形的面积给出为 $alpha + beta + gamma + delta - 2 pi$，其中 $alpha$, $beta$, $gamma$ and $delta$ 是其内角。这个值由`SphericalQuadArea()`计算，该函数接收单位球面上的顶点位置。其实现与#link("<SphericalTriangleArea>")[`SphericalTriangleArea()`];非常相似，因此这里不包括。
]

```cpp
Float SphericalQuadArea(Vector3f a, Vector3f b, Vector3f c, Vector3f d);
```

=== Spherical Parameterizations
<spherical-parameterizations>

#parec[
  The 3D Cartesian coordinates of a point on the unit sphere are not always the most convenient representation of a direction. For example, if we are tabulating a function over the unit sphere, a 2D parameterization that takes advantage of the fact that the sphere's surface is two-dimensional is preferable.
][
  在单位球面上，一个点的三维笛卡尔坐标并不总是表示方向的最方便方式。例如，如果我们在单位球面上列出一个函数，一个利用球面表面是二维的2D参数化更为合适。
]

#parec[
  There are a variety of mappings between 2D and the sphere. Developing such mappings that fulfill various goals has been an important part of map making since its beginnings. It can be shown that any mapping from the plane to the sphere introduces some form of distortion; the task then is to choose a mapping that best fulfills the requirements for a particular application. `pbrt` thus uses three different spherical parameterizations, each with different advantages and disadvantages.
][
  在二维到球面的映射之间有多种选择。自地图制作开始以来，开发能够满足各种目标的映射一直是地图制作的重要组成部分。可以证明，从平面到球面的任何映射都会引入某种形式的失真；因此任务是选择一个最能满足特定应用要求的映射。因此，`pbrt`使用了三种不同的球面参数化表示，每种都有不同的优缺点。
]

==== Spherical Coordinates
<spherical-coordinates>


#parec[
  Spherical coordinates $(theta, phi)$ are a well-known parameterization of the sphere. For a general sphere of radius $r$, they are related to Cartesian coordinates by
][
  球面坐标 $(theta, phi)$ 是球面的一种著名参数化。对于一般半径为 $r$ 的球，它们与笛卡尔坐标的关系为
]

$
  mat(delim: #none, r l
x, = r sin theta cos phi.alt;
y, = r sin theta sin phi.alt;
z, = r cos theta .)
$<spherical-coordinates>
#parec[
  (See @fig:spherical-angles)
][
  (见@fig:spherical-angles )
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f16.svg"),
  caption: [#ez_caption[
      A direction vector can be written in terms of spherical coordinates $(theta, phi)$ if the $x$, $y$, and $z$ basis vectors are given as well. The spherical angle formulae make it easy to convert between the two representations.

    ][
      如果给定$x$, $y$, and $z$基向量，则可以用球面坐标$(theta, phi)$表示一个方向向量。球面角公式使得在两种表示之间的转换变得容易。
    ]
  ],
)<spherical-angles>



#parec[
  For convenience, we will define a `SphericalDirection()` function that converts a $theta$ and $phi$ pair into a unit $(x, y, z)$ vector, applying these equations directly. Notice that the function is given the sine and cosine of $theta$, rather than $theta$ itself. This is because the sine and cosine of $theta$ are often already available to the caller. This is not normally the case for $phi$, however, so $phi$ is passed in as is.
][
  为了方便起见，我们将定义一个 `SphericalDirection()` 函数，该函数将 $theta$ 和 $phi$ 对应的值转换为一个单位 $(x, y, z)$ 向量，直接应用这些方程。注意，该函数接收的是 $theta$ 的正弦值和余弦值，而不是 $theta$ 本身。这是因为调用者通常已经拥有 $theta$ 的正弦值和余弦值。然而， $phi$ 的情况通常不是这样，所以 $phi$ 会直接传入。
]

```cpp
Vector3f SphericalDirection(Float sinTheta, Float cosTheta, Float phi) {
    return Vector3f(Clamp(sinTheta, -1, 1) * std::cos(phi),
                    Clamp(sinTheta, -1, 1) * std::sin(phi),
                    Clamp(cosTheta, -1, 1));
}
```

#parec[
  The conversion of a direction $(x, y, z)$ to spherical coordinates can be found by
][
  可以通过以下公式将方向 $(x, y, z)$ 转换为球面坐标：
]

$
  mat(delim: #none, r l
theta, = arccos z;
phi.alt, = arctan(frac(y, x)) .)
$<spherical-coordinates-from-xyz>


#parec[
  The corresponding functions follow. Note that #link("<SphericalTheta>")[`SphericalTheta()`] assumes that the vector `v` has been normalized before being passed in; using #link("../Utilities/Mathematical_Infrastructure.html#SafeACos")[`SafeACos()`] in place of `std::acos()` avoids errors if $|v.z|$ is slightly greater than 1 due to floating-point round-off error.
][
  对应的函数如下。注意#link("<SphericalTheta>")[`SphericalTheta()`];假设向量`v`在传入之前已经被归一化；使用#link("../Utilities/Mathematical_Infrastructure.html#SafeACos")[`SafeACos()`];代替`std::acos()`可以避免由于浮点舍入误差导致的 $|v.z|$ 略大于1的错误。
]

```cpp
Float SphericalTheta(Vector3f v) { return SafeACos(v.z); }
```


#parec[
  `SphericalPhi()` returns an angle in $\[0, 2)$ , which sometimes requires an adjustment to the value returned by `std::atan2()`.
][
  `SphericalPhi()`返回一个在 $\[0, 2)$ 范围内的角度，有时需要对`std::atan2()`返回的值进行调整。
]


```cpp
Float SphericalPhi(Vector3f v) {
    Float p = std::atan2(v.y, v.x);
    return (p < 0) ? (p + 2 * Pi) : p;
}
```


#parec[
  Given a direction vector $omega$, it is easy to compute quantities like the cosine of the angle $theta$ :
][
  给定一个方向向量 $omega$，可以很容易地计算出诸如角度 $theta$ 的余弦等量：
]

$
  cos theta =((0, 0, 1) dot.op bold(omega)) = omega_z .
$


#parec[
  This is a much more efficient computation than it would have been to compute $omega$ 's $theta$ value using first an expensive inverse trigonometric function to compute $theta$ and then another expensive function to compute its cosine. The following functions compute this cosine and a few useful variations.
][
  这比先使用昂贵的反三角函数来计算 $omega$ 的 $theta$ 值，然后再使用另一个昂贵的函数来计算它的余弦值要高效得多。以下函数用于计算这个余弦值以及一些有用的变体。
]

```cpp
Float CosTheta(Vector3f w) { return w.z; }
Float Cos2Theta(Vector3f w) { return Sqr(w.z); }
Float AbsCosTheta(Vector3f w) { return std::abs(w.z); }
```


#parec[
  The value of $sin^2 theta$ can be efficiently computed using the trigonometric identity $( sin^2 theta + cos^2 theta = 1 )$, though we need to be careful to avoid returning a negative value in the rare case that `1 - Cos2Theta(w)` is less than zero due to floating-point round-off error.
][
  $sin^2 theta$ 的值可以通过三角恒等式 $( sin^2 theta + cos^2 theta = 1 )$ 高效计算，但是我们需要小心避免在由于浮点舍入误差导致 `1 - Cos2Theta(w)` 小于零的罕见情况下返回负值。
]

```cpp
Float Sin2Theta(Vector3f w) { return std::max<Float>(0, 1 - Cos2Theta(w)); }
Float SinTheta(Vector3f w) { return std::sqrt(Sin2Theta(w)); }
```


#parec[
  The tangent of the angle $theta$ can be computed via the identity $tan theta =  sin theta \/ cos theta$.
][
  角 $theta$ 的正切可以通过公式 $tan theta =  sin theta \/ cos theta$ 计算。
]

```cpp
Float TanTheta(Vector3f w) { return SinTheta(w) / CosTheta(w); }
Float Tan2Theta(Vector3f w) { return Sin2Theta(w) / Cos2Theta(w); }
```


#parec[
  The sine and cosine of the $phi.alt$ angle can also be easily found from $(x , y , z)$ coordinates without using inverse trigonometric functions (@fig:phi-angles). In the $z = 0$ plane, the vector $omega$ has coordinates $(x , y)$, which are given by $r cos phi.alt$ and $r sin phi.alt$, respectively. The radius~ $r$ is $sin theta$, so
][
  $phi.alt$ 角的正弦和余弦也可以从 $(x, y, z)$ 坐标中轻松找到，而无需使用反三角函数（@fig:phi-angles）。在 $z = 0$ 平面中，向量 $omega$ 的坐标为 $(x , y)$，分别由 $r cos phi.alt$ 和 $r sin phi.alt$ 给出。半径 $r$ 是 $sin theta$，所以
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f17.svg"),
  caption: [
    #ez_caption[
      The values of $sin phi.alt$ and $cos phi.alt$ can be computed using the circular coordinate equations $x = r cos phi.alt$ and $y = r sin phi.alt$, where $r$, the length of the dashed line, is equal to $sin theta$.
    ][
      $sin phi.alt$ 和 $cos phi.alt$ 的值可以通过圆形坐标方程 $x = r cos phi.alt$ 和 $y = r sin phi.alt$ 计算，其中 $r$ （虚线的长度）等于 $sin theta$。
    ]
  ],
) <phi-angles>


```cpp
Float CosPhi(Vector3f w) {
    Float sinTheta = SinTheta(w);
    return (sinTheta == 0) ? 1 : Clamp(w.x / sinTheta, -1, 1);
}
Float SinPhi(Vector3f w) {
    Float sinTheta = SinTheta(w);
    return (sinTheta == 0) ? 0 : Clamp(w.y / sinTheta, -1, 1);
}
```


#parec[
  Finally, the cosine of the angle $Delta phi.alt$ between two vectors' $phi.alt$ values can be found by zeroing their $z$ coordinates to get 2D vectors in the $z=0$ plane and then normalizing them. The dot product of these two vectors gives the cosine of the angle between them. The implementation below rearranges the terms a bit for efficiency so that only a single square root operation needs to be performed.
][
  最后，两个向量的 $phi.alt$ 值之间的角度 $Delta phi.alt$ 的余弦可以通过将它们的 $z$ 坐标设为零来获得位于 $z=0$ 平面中的二维向量，然后对它们进行归一化。这两个向量的点积给出了它们之间角度的余弦。下面的实现对这些项进行了些许重排以提高效率，从而只需要执行一次平方根运算。
]

```cpp
Float CosDPhi(Vector3f wa, Vector3f wb) {
    Float waxy = Sqr(wa.x) + Sqr(wa.y), wbxy = Sqr(wb.x) + Sqr(wb.y);
    if (waxy == 0 || wbxy == 0) return 1;
    return Clamp((wa.x * wb.x + wa.y * wb.y) / std::sqrt(waxy * wbxy),
                 -1, 1);
}
```


#parec[
  Parameterizing the sphere with spherical coordinates corresponds to the #emph[equirectangular] mapping of the sphere. It is not a particularly good parameterization for representing regularly sampled data on the sphere due to substantial distortion at the sphere's poles.
][
  使用球面坐标对球体进行参数化对应于球体的#emph[等距矩形];映射。由于在球体的极点处存在显著的变形，它不是表示球体上规则采样数据的特别好的参数化方法。
]

==== Octahedral Encoding
<octahedral-encoding>
#parec[
  While #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] is a convenient representation for computation using unit vectors, it does not use storage efficiently: not only does it use 12 bytes of memory (assuming 4-byte #link("../Introduction/pbrt_System_Overview.html#Float")[`Float`];s), but it is capable of representing 3D direction vectors of arbitrary length. Normalized vectors are a small subset of all the possible #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];s, however, which means that the storage represented by those 12 bytes is not well allocated for them. When many normalized vectors need to be stored in memory, a more space-efficient representation can be worthwhile.
][
  虽然#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];是使用单位向量进行计算的便捷表示，但它的存储效率不高：不仅占用12字节的内存（假设4字节的#link("../Introduction/pbrt_System_Overview.html#Float")[`Float`];），而且能够表示任意长度的3D方向向量。然而，归一化向量只是所有可能的#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];中的一个小子集，这意味着这12字节的存储对它们来说分配不当。当需要在内存中存储许多归一化向量时，使用更节省空间的表示可能是值得的。
]

#parec[
  Spherical coordinates could be used for this task. Doing so would reduce the storage required to two `Float`s, though with the disadvantage that relatively expensive trigonometric and inverse trigonometric functions would be required to convert to and from #link("../Geometry_and_Transformations/Vectors.html#Vector3")[`Vector3`];s. Further, spherical coordinates provide more precision near the poles and less near the equator; a more equal distribution of precision across all unit vectors is preferable. (Due to the way that floating-point numbers are represented, #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] suffers from providing different precision in different parts of the unit sphere as well.)
][
  可以使用球面坐标来完成此任务。这样做可以将存储需求减少到两个`Float`，但缺点是需要相对昂贵的三角函数和反三角函数来进行转换。此外，球面坐标在极点附近提供了更多的精度，而在赤道附近则较少；在所有单位向量中更均匀地分布精度是更可取的。（由于浮点数的表示方式，#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];在单位球体的不同部分也提供了不同的精度。）
]

#parec[
  #link("<OctahedralVector>")[`OctahedralVector`] provides a compact representation for unit vectors with an even distribution of precision and efficient encoding and decoding routines. Our implementation uses just 4 bytes of memory for each unit vector; all the possible values of those 4 bytes correspond to a valid unit vector. Its representation is not suitable for computation, but it is easy to convert between it and #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];, which makes it an appealing option for in-memory storage of normalized vectors.
][
  #link("<OctahedralVector>")[`OctahedralVector`];提供了一种紧凑的单位向量表示，具有均匀的精度分布和高效的编码和解码例程。我们的实现为每个单位向量仅使用4字节的内存；这4字节的所有可能值都对应于一个有效的单位向量。它的表示不适合计算，但很容易在它和#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];之间转换，这使得它成为在内存中存储归一化向量的一个有吸引力的选项。
]

```cpp
class OctahedralVector {
  public:
    OctahedralVector(Vector3f v) {
           v /= std::abs(v.x) + std::abs(v.y) + std::abs(v.z);
           if (v.z >= 0) {
               x = Encode(v.x);
               y = Encode(v.y);
           } else {
                  x = Encode((1 - std::abs(v.y)) * Sign(v.x));
                  y = Encode((1 - std::abs(v.x)) * Sign(v.y));
           }
       }
       explicit operator Vector3f() const {
           Vector3f v;
           v.x = -1 + 2 * (x / 65535.f);
           v.y = -1 + 2 * (y / 65535.f);
           v.z = 1 - (std::abs(v.x) + std::abs(v.y));
              if (v.z < 0) {
                  Float xo = v.x;
                  v.x = (1 - std::abs(v.y)) * Sign(xo);
                  v.y = (1 - std::abs(xo)) * Sign(v.y);
              }
           return Normalize(v);
       }
       std::string ToString() const { return StringPrintf("[ OctahedralVector x: %d y: %d ]", x, y); }
  private:
       static Float Sign(Float v) { return std::copysign(1.f, v); }
       static uint16_t Encode(Float f) {
           return std::round(Clamp((f + 1) / 2, 0, 1) * 65535.f);
       }
       uint16_t x, y;
};
```

#parec[
  As indicated by its name, this unit vector is based on an octahedral mapping of the unit sphere that is illustrated in @fig:octahedral-vec-parameterization.
][
  正如其名称所示，这个单位向量基于fig:octahedral-vec-parameterization 中所示的单位球体的八面体映射。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f18.svg"),
  caption: [
    #ez_caption[ The
      #link("<OctahedralVector>")[`OctahedralVector`];'s parameterization of the
      unit sphere can be understood by first considering (a) an octahedron
      inscribed in the sphere. Its 2D parameterization is then defined by (b)
      flattening the top pyramid into the $z = 0$ plane and (c) unwrapping the
      bottom half and projecting its triangles onto the same plane. (d) The
      result allows a simple (\[-1, 1\]^2) parameterization. (Figure after
      Figure 2 in Meyer et al.~(2010).)

    ][
      #link("<OctahedralVector>")[`OctahedralVector`];对单位球体的参数化可以通过首先考虑(a)一个内接于球体的八面体来理解。然后通过(b)将顶部金字塔展平到$z = 0$平面，并(c)展开底部并将其三角形投影到同一平面上定义其二维参数化。(d)结果允许一个简单的(\[-1,
      1\]^2)参数化。（图改编自Meyer等人(2010)的图2。）
    ]
  ],
) <octahedral-vec-parameterization>


#parec[
  The algorithm to convert a unit vector to this representation is surprisingly simple. The first step is to project the vector onto the faces of the 3D octahedron; this can be done by dividing the vector components by the vector's L1 norm, $| upright(bold(v))_x | + | upright(bold(v))_y | + | upright(bold(v))_z |$. For points in the upper hemisphere (i.e., with $ upright(bold(v))_z gt.eq 0$ ), projection down to the $z = 0$ plane then just requires taking the $x$ and $y$ components directly.
][
  将单位向量转换为这种表示的算法出乎意料地简单。第一步是将向量投影到三维八面体的各个面上；这可以通过将向量的各个分量除以向量的L1范数 $| upright(bold(v))_x | + | upright(bold(v))_y | + | upright(bold(v))_z |$ 来完成。对于上半球中的点（即 $ upright(bold(v))_z gt.eq 0$ ），投影到 $z = 0$ 平面只需要直接取 $x$ 和 $y$ 分量即可。
]

```cpp
OctahedralVector(Vector3f v) {
    v /= std::abs(v.x) + std::abs(v.y) + std::abs(v.z);
    if (v.z >= 0) {
        x = Encode(v.x);
        y = Encode(v.y);
    } else {
           x = Encode((1 - std::abs(v.y)) * Sign(v.x));
           y = Encode((1 - std::abs(v.x)) * Sign(v.y));
    }
}
```


#parec[
  For directions in the lower hemisphere, the reprojection to the appropriate point in ( $\[-1, 1\]^2$ ) is slightly more complex, though it can be expressed without any conditional control flow with a bit of care. (Here is another concise fragment of code that is worth understanding; consider in comparison code based on `if` statements that handled unwrapping the four triangles independently.)
][
  对于下半球的方向，重新投影到 $\[-1, 1\]^2$ 中的适当点稍显复杂，尽管可以在不使用任何条件控制流的情况下小心地表达出来。（这里是另一个值得理解的简洁代码片段；考虑与基于`if`语句的代码进行比较，这些代码独立处理展开四个三角形。）
]

```cpp
x = Encode((1 - std::abs(v.y)) * Sign(v.x));
y = Encode((1 - std::abs(v.x)) * Sign(v.y));
```


#parec[
  The helper function #link("<OctahedralVector::Sign>")[`OctahedralVector::Sign()`] uses the standard math library function `std::copysign()` to return $plus.minus 1$ according to the sign of $(v)$ (positive/negative zero are treated like ordinary numbers).
][
  辅助函数#link("<OctahedralVector::Sign>")[`OctahedralVector::Sign()`];使用标准数学库函数`std::copysign()`根据(v)的符号返回 $plus.minus 1$ （正/负零被视为普通数字）。
]

```cpp
static Float Sign(Float v) { return std::copysign(1.f, v); }
```

#parec[
  The 2D parameterization in @fig:octahedral-vec-parameterization (d) is then represented using a 16-bit value for each coordinate that quantizes the range (\[-1, 1\]) with ( $2^{16}$ ) steps.
][
  @fig:octahedral-vec-parameterization (d)中的二维参数化然后使用每个坐标的16位值表示，该值将(\[-1, 1\])的范围量化为( $2^{16}$ )个步骤。
]

```cpp
uint16_t x, y;
```


#parec[
  `Encode()` performs the encoding from a value in (\[-1, 1\]) to the integer encoding.
][
  `Encode()`执行从(\[-1, 1\])的值到整数编码的编码。
]

```cpp
static uint16_t Encode(Float f) {
    return std::round(Clamp((f + 1) / 2, 0, 1) * 65535.f);
}
```


#parec[
  The mapping back to a #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] follows the same steps in reverse. For directions in the upper hemisphere, the (z) value on the octahedron face is easily found. Normalizing that vector then gives the corresponding unit vector.
][
  映射回#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];时，遵循相同步骤的逆过程。对于上半球的方向，很容易找到八面体面上的(z)值。然后归一化该向量以得到相应的单位向量。
]

```cpp
explicit operator Vector3f() const {
    Vector3f v;
    v.x = -1 + 2 * (x / 65535.f);
    v.y = -1 + 2 * (y / 65535.f);
    v.z = 1 - (std::abs(v.x) + std::abs(v.y));
       if (v.z < 0) {
           Float xo = v.x;
           v.x = (1 - std::abs(v.y)) * Sign(xo);
           v.y = (1 - std::abs(xo)) * Sign(v.y);
       }
    return Normalize(v);
}
```

#parec[
  For directions in the lower hemisphere, the inverse of the mapping implemented in the `<<Encode octahedral vector with z < 0>>` fragment must be performed before the direction is normalized.
][
  对于下半球的方向，必须在归一化方向之前执行 `<<Encode octahedral vector with $z < 0$>>` 片段中实现的映射的逆过程。
]

```cpp
if (v.z < 0) {
    Float xo = v.x;
    v.x = (1 - std::abs(v.y)) * Sign(xo);
    v.y = (1 - std::abs(xo)) * Sign(v.y);
}
```

==== Equal-Area Mapping
<equal-area-mapping>
#parec[
  The third spherical parameterization used in `pbrt` is carefully designed to preserve area: any area on the surface of the sphere maps to a proportional area in the parametric domain. This representation is a good choice for tabulating functions on the sphere, as it is continuous, has reasonably low distortion, and all values stored represent the same solid angle. It combines the octahedral mapping used in the #link("<OctahedralVector>")[`OctahedralVector`] class with a variant of the square-to-disk mapping from #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[Section A.5.1];, which maps the unit square to the hemisphere in a way that preserves area.
][
  `pbrt`中使用的第三种球面参数化经过精心设计，以保持面积：球面上的任何面积都映射到参数域中的一个比例面积。 这种表示法是对球面函数进行制表的理想选择，因为它是连续的，具有相对较低的失真，并且存储的所有值代表相同的立体角。 它结合了#link("<OctahedralVector>")[`OctahedralVector`];类中使用的八面体映射和#link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[Section A.5.1];中的方形到圆盘映射的变体，该映射以保持面积的方式将单位方形映射到半球。
]

#parec[
  The mapping splits the unit square into four sectors, each of which is mapped to a sector of the hemisphere (see @fig:equi-area-mapping).
][
  该映射将单位方形分成四个扇区，每个扇区映射到半球的一个扇区（@fig:equi-area-mapping）。
]
#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f19.svg"),
  caption: [
    #ez_caption[ The uniform hemispherical mapping (a) first transforms the unit square to the unit disk so that the four shaded sectors of the square are mapped to the corresponding shaded sectors of the disk. (b) Points on the disk are then mapped to the hemisphere in a manner that preserves relative area.][均匀半球映射(a)首先将单位正方形转换为单位圆盘，使得正方形的四个阴影区域映射到圆盘上对应的阴影区域。(b) 然后圆盘上的点被映射到半球上，且保持相对面积不变。]
  ],
)<equi-area-mapping>
#parec[
  Given $(u , v) in [- 1 , 1]^2$ ; then in the first sector where $u gt.eq 0$ and $u - lr(|v|) gt.eq 0$, defining the polar coordinates of a point on the unit disk by
][
  给定 $(u , v) in [- 1 , 1]^2$ ；那么在第一个扇区中， $u gt.eq 0$ 且 $u - lr(|v|) gt.eq 0$，通过定义单位圆盘上点的极坐标
]

$
  r = u \
  phi.alt = pi / 4 v / u
$


#parec[
  gives an area-preserving mapping with $phi.alt in [- pi \/ 4 , pi \/ 4]$. Similar mappings can be found for the other three sectors.
][
  得到一个面积保持的映射，其中 $phi.alt in [- pi \/ 4 , pi \/ 4]$。其他三个扇区也可以找到类似的映射。
]

#parec[
  Given $(r , phi.alt)$, the corresponding point on the positive hemisphere is then given by
][
  给定 $(r , phi.alt)$，则正半球上的对应点为
]

$ x = (cos phi.alt) r sqrt(2 - r^2) med y = (sin phi.alt) r sqrt(2 - r^2) med z = 1 - r^2 . $


#parec[
  This mapping is also area-preserving.
][
  此映射也是面积保持的。
]

#parec[
  This mapping can be extended to the entire sphere using the same octahedral mapping that was used for the `OctahedralVector`.
][
  此映射可以使用`OctahedralVector`中使用的相同八面体映射扩展到整个球体。
]

#parec[
  There are then three steps:
][
  然后有三个步骤：
]

#parec[
  + First, the octahedral mapping is applied to the direction, giving a
    point $(u , v) in [- 1 , 1]^2$.
][
  + 首先，八面体映射应用于方向，得到一个点$(u , v) in [- 1 , 1]^2$。
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + For directions in the upper hemisphere, the concentric hemisphere
      mapping, Equation (3.9), is applied to the inner square of the
      octahedral mapping.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + 对于上半球的方向，应用方程(3.9)中的同心半球映射到八面体映射的内部方形。
  ]
]

#parec[
  Doing so requires accounting for the fact that it is rotated by $45^circle.stroked.tiny$ from the square expected by the hemispherical mapping.
][
  这样做需要考虑到它相对于半球映射预期的方形旋转了 $45^circle.stroked.tiny$。
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + Directions in the lower hemisphere are mirrored over across their quadrant's diagonal before the hemispherical mapping is applied. The resulting direction vector's $z$ component is then negated.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 在应用半球映射之前，下半球的方向沿其象限的对角线镜像。然后将结果方向向量的$z$分量取反。
  ]
]


#parec[
  The following implementation of this approach goes through some care to be #emph[branch free];: no matter what the input value, there is a single path of control flow through the function. When possible, this characteristic is often helpful for performance, especially on the GPU, though we note that this function usually represents a small fraction of `pbrt`'s execution time, so this characteristic does not affect the system's overall performance.
][
  这种方法的以下实现经过一些小心处理以实现#emph[无分支];：无论输入值是什么，函数中都有一条单一的控制流路径。 在可能的情况下，这种特性通常有助于提高性能，尤其是在GPU上，尽管我们注意到此函数通常代表`pbrt`执行时间的一小部分，因此这种特性不会影响系统的整体性能。
]

```cpp
Vector3f EqualAreaSquareToSphere(Point2f p) {
    <<Transform p to [-1, 1]^2 and compute absolute values>>
       Float u = 2 * p.x - 1, v = 2 * p.y - 1;
       Float up = std::abs(u), vp = std::abs(v);
    <<Compute radius r as signed distance from diagonal>>
       Float signedDistance = 1 - (up + vp);
       Float d = std::abs(signedDistance);
       Float r = 1 - d;
    <<Compute angle phi for square to sphere mapping>>
       Float phi = (r == 0 ? 1 : (vp - up) / r + 1) * Pi / 4;
    <<Find z coordinate for spherical direction>>
       Float z = pstd::copysign(1 - Sqr(r), signedDistance);
    <<Compute cosine phi and sine phi for original quadrant and return vector>>
       Float cosPhi = pstd::copysign(std::cos(phi), u);
       Float sinPhi = pstd::copysign(std::sin(phi), v);
       return Vector3f(cosPhi * r * SafeSqrt(2 - Sqr(r)),
                       sinPhi * r * SafeSqrt(2 - Sqr(r)), z);
}
```

#parec[
  After transforming the original point `p` in $[0 , 1]^2$ to $(u , v) in [- 1 , 1]^2$, the implementation also computes the absolute value of these coordinates $u prime = lr(|u|)$ and $v prime = lr(|v|)$. Doing so remaps the three quadrants with one or two negative coordinate values to the positive quadrant, flipping each quadrant so that its upper hemisphere is mapped to $u prime + v prime < 1$, which corresponds to the upper hemisphere in the original positive quadrant. (Each lower hemisphere is also mapped to the $u prime + v prime > 1$ region, corresponding to the original negative quadrant.)
][
  在将原始点`p`从 $[0 , 1]^2$ 转换为 $(u , v) in [- 1 , 1]^2$ 后，实现还计算了这些坐标的绝对值 $u prime = lr(|u|)$ 和 $v prime = lr(|v|)$。 这样做将一个或两个负坐标值的三个象限重新映射到正象限，翻转每个象限，使其上半球映射到 $u prime + v prime < 1$，这对应于原始正象限中的上半球。 （每个下半球也映射到 $u prime + v prime > 1$ 区域，对应于原始负象限。）
]


```cpp
Float u = 2 * p.x - 1, v = 2 * p.y - 1;
Float up = std::abs(u), vp = std::abs(v);
```

#parec[
  Most of this function's implementation operates using $(u prime , v prime)$ in the positive quadrant. Its next step is to compute the radius $r$ for the mapping to the disk by computing the signed distance to the $u + v = 1$ diagonal that splits the upper and lower hemispheres where the lower hemisphere's signed distance is negative (Figure 3.20).
][
  此函数的大部分实现使用正象限中的 $(u prime , v prime)$。 其下一步是通过计算到分割上半球和下半球的 $u + v = 1$ 对角线的有符号距离来计算映射到圆盘的半径 $r$，其中下半球的有符号距离为负（图3.20）。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f20.svg"),
  caption: [
    #ez_caption[Computation of the Radius r for the Square-to-Disk
      Mapping. The signed distance to the u' + v' = 1 line is computed.
      One minus its absolute value gives a radius between 0 and 1.][方形到圆盘映射的半径r的计算。计算到$u prime + v prime = 1$线的有符号距离。其绝对值减去1给出0到1之间的半径。]
  ],
)


```cpp
Float signedDistance = 1 - (up + vp);
Float d = std::abs(signedDistance);
Float r = 1 - d;
```


#parec[
  The $phi.alt$ computation accounts for the $45^circle.stroked.tiny$ rotation with an added $pi \/ 4$ term.
][
  $phi.alt$ 的计算考虑了 $45^circle.stroked.tiny$ 的旋转，并添加了一个 $pi \/ 4$ 项。
]

```cpp
Float phi = (r == 0 ? 1 : (vp - up) / r + 1) * Pi / 4;
```


#parec[
  The sign of the signed distance computed earlier indicates whether the $(u prime , v prime)$ point is in the lower hemisphere; the returned $z$ coordinate takes its sign.
][
  先前计算的有符号距离的符号指示 $(u prime , v prime)$ 点是否在下半球；返回的 $z$ 坐标取其符号。
]

```cpp
Float z = pstd::copysign(1 - Sqr(r), signedDistance);
```


#parec[
  After computing $cos phi.alt$ and $sin phi.alt$ in the positive quadrant, it is necessary to remap those values to the correct ones for the actual quadrant of the original point $(u , v)$. Associating the sign of $u$ with the computed $cos phi.alt$ value and the sign of $v$ with $sin phi.alt$ suffices to do so and this operation can be done with another use of `copysign()`.
][
  在正象限中计算 $cos phi.alt$ 和 $sin phi.alt$ 之后，有必要将这些值重新映射到原始点 $(u , v)$ 的实际象限的正确值。 将 $u$ 的符号与计算的 $cos phi.alt$ 值关联，将 $v$ 的符号与 $sin phi.alt$ 关联即可做到这一点，这个操作可以通过另一次使用`copysign()`来完成。
]

```cpp
Float cosPhi = pstd::copysign(std::cos(phi), u);
Float sinPhi = pstd::copysign(std::sin(phi), v);
return Vector3f(cosPhi * r * SafeSqrt(2 - Sqr(r)),
                sinPhi * r * SafeSqrt(2 - Sqr(r)), z);
}
```


#parec[
  The inverse mapping is performed by the `EqualAreaSphereToSquare()` function, which effectively performs the same operations in reverse and is therefore not included here. Also useful and also not included, `WrapEqualAreaSquare()` handles the boundary cases of points `p` that are just outside of $[0 , 1]^2$ (as may happen during bilinear interpolation with image texture lookups) and wraps them around to the appropriate valid coordinates that can be passed to #link("<EqualAreaSquareToSphere>")[`EqualAreaSquareToSphere()`];.
][
  逆映射由`EqualAreaSphereToSquare()`函数执行，该函数实际上执行相同的操作顺序，因此在此不包括。 此外，`WrapEqualAreaSquare()`处理略微超出 $[0 , 1]^2$ 的点`p`的边界情况（如在图像纹理查找的双线性插值期间可能发生的情况），并将它们环绕到可以传递给#link("<EqualAreaSquareToSphere>")[`EqualAreaSquareToSphere()`];的适当有效坐标。
]



=== Bounding Directions
<bounding-directions>
#parec[
  In addition to bounding regions of space, it is also sometimes useful to bound a set of directions. For example, if a light source emits illumination in some directions but not others, that information can be used to cull that light source from being included in lighting calculations for points it certainly does not illuminate. `pbrt` provides the #link("<DirectionCone>")[DirectionCone] class for such uses; it represents a cone that is parameterized by a central direction and an angular spread (see @fig:cone-bound-directions).
][
  除了界定空间区域，有时界定一组方向也是有用的。例如，如果一个光源在某些方向上发出光而在其他方向上不发光，这些信息可以用来从光照计算中排除该光源，因为它们肯定不会照亮某些点。 `pbrt` 提供了 #link("<DirectionCone>")[DirectionCone] 类用于这种用途；它表示一个由中心方向和张角参数化的圆锥（见@fig:cone-bound-directions）。
]
#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f21.svg"),
  caption: [
    #ez_caption[Bounding a Set of Directions with a Cone. A set of
      directions, shown here as a shaded region on the sphere, can be bounded
      using a cone described by a central direction vector $upright(bold(v))$
      and a spread angle $theta$ set such that all the directions in the set
      are inside the cone.

    ][
      用圆锥界定一组方向。这里显示为球面上的阴影区域的一组方向，可以使用一个由中心方向向量
      $upright(bold(v))$ 和张角 $theta$
      描述的圆锥来界定，以便集合中的所有方向都在圆锥内。

    ]
  ],
)<cone-bound-directions>

```cpp
<<DirectionCone Definition>>=
class DirectionCone {
  public:
    <<DirectionCone Public Methods>>
    <<DirectionCone Public Members>>
};
```

#parec[
  The `DirectionCone` provides a variety of constructors, including one that takes the central axis of the cone and the cosine of its spread angle and one that bounds a single direction. For both the constructor parameters and the cone representation stored in the class, the cosine of the spread angle is used rather than the angle itself. Doing so makes it possible to perform some of the following operations with `DirectionCone`s using efficient dot products in place of more expensive trigonometric functions.
][
  `DirectionCone` 提供了多种构造函数，包括一个接受圆锥的中心轴和其张角余弦值的构造函数，以及一个界定单一方向的构造函数。对于构造函数参数和类中存储的圆锥表示，使用的是张角的余弦值而不是角度本身。 这样可以使用高效的点积运算来代替较昂贵的三角函数运算进行一些后续操作。
]

```cpp
<<DirectionCone Public Methods>>=
DirectionCone() = default;
DirectionCone(Vector3f w, Float cosTheta)
    : w(Normalize(w)), cosTheta(cosTheta) {}
explicit DirectionCone(Vector3f w) : DirectionCone(w, 1) {}
```


#parec[
  The default `DirectionCone` is empty; an invalid value of infinity for `cosTheta` encodes that case.
][
  默认的 `DirectionCone` 是空的；`cosTheta` 的无穷大值表示这种情况。
]

```cpp
<<DirectionCone Public Members>>=
Vector3f w;
Float cosTheta = Infinity;
```


#parec[
  A convenience method reports whether the cone is empty.
][
  一个便捷方法报告圆锥是否为空。
]


```cpp
<<DirectionCone Public Methods>>+=
bool IsEmpty() const { return cosTheta == Infinity; }
```

#parec[
  Another convenience method provides the bound for all directions.
][
  另一个便捷方法提供所有方向的界限。
]

```cpp
<<DirectionCone Public Methods>>+=
static DirectionCone EntireSphere() {
    return DirectionCone(Vector3f(0, 0, 1), -1);
}
```

#parec[
  Given a `DirectionCone`, it is easy to check if a given direction vector is inside its bounds: the cosine of the angle between the direction and the cone's central direction must be greater than the cosine of the cone's spread angle. (Note that for the angle to be smaller, the cosine must be larger.)
][
  给定一个 `DirectionCone`，很容易检查给定的方向向量是否在其界限内：方向与圆锥中心方向之间的角度余弦必须大于圆锥张角的余弦。（注意，要使角度更小，余弦值必须更大。）
]

```cpp
<<DirectionCone Inline Functions>>=
bool Inside(const DirectionCone &d, Vector3f w) {
    return !d.IsEmpty() && Dot(d.w, Normalize(w)) >= d.cosTheta;
}
```

#parec[
  `BoundSubtendedDirections()` returns a `DirectionCone` that bounds the directions subtended by a given bounding box with respect to a point `p`.
][
  `BoundSubtendedDirections()` 返回一个 `DirectionCone`，它界定了相对于点 `p` 的给定边界框所覆盖的方向。
]

```cpp
<<DirectionCone Inline Functions>>+=
DirectionCone BoundSubtendedDirections(const Bounds3f &b, Point3f p) {
    <<Compute bounding sphere for b and check if p is inside>>
    <<Compute and return DirectionCone for bounding sphere>>
}
```


#parec[
  First, a bounding sphere is found for the bounds `b`. If the given point `p` is inside the sphere, then a direction bound of all directions is returned. Note that the point `p` may be inside the sphere but outside `b`, in which case the returned bounds will be overly conservative.
][
  首先，为边界 `b` 找到一个包围球。如果给定点 `p` 在球内，则返回所有方向的方向界限。注意，点 `p` 可能在球内但在 `b` 外部，在这种情况下返回的界限将过于保守。
]

```cpp
<<Compute bounding sphere for b and check if p is inside>>=
Float radius;
Point3f pCenter;
b.BoundingSphere(&pCenter, &radius);
if (DistanceSquared(p, pCenter) < Sqr(radius))
    return DirectionCone::EntireSphere();
```
#parec[
  Otherwise, the central axis of the bounds is given by the vector from `p` to the center of the sphere, and the cosine of the spread angle is easily found using basic trigonometry (see @fig:bounding-sphere-angle).
][
  否则，界限的中心轴由从 `p` 到球心的向量确定，并且张角的余弦可以通过基本三角学轻松找到（见@fig:bounding-sphere-angle）。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f22.svg"),
  caption: [
    #ez_caption[Given a bounding sphere and a reference point $p$ outside of the sphere, the cosine of the angle $theta$ can be found by first computing $sin theta$ by dividing the sphere's radius $r$ by the distance $d$ between $p$ and the sphere's center and then using the identity $sin^2 theta + cos^2 theta = 1$.][给定一个包围球和一个位于球外的参考点 $p$，可以通过首先计算角度 $theta$ 的 $sin theta$ 来找到余弦值。$sin theta$ 可以通过将球的半径 $r$ 除以 $p$ 与球心之间的距离 $d$ 来计算，接着使用恒等式 $sin^2 theta + cos^2 theta = 1$ 来求得余弦值。]
  ],
) <bounding-sphere-angle>

```cpp
<<Compute and return DirectionCone for bounding sphere>>=
Vector3f w = Normalize(pCenter - p);
Float sin2ThetaMax = Sqr(radius) / DistanceSquared(pCenter, p);
Float cosThetaMax = SafeSqrt(1 - sin2ThetaMax);
return DirectionCone(w, cosThetaMax);
```

#parec[
  Finally, we will find it useful to be able to take the union of two `DirectionCone`s, finding a `DirectionCone` that bounds both of them.
][
  最后，我们将发现能够合并两个 `DirectionCone` 是有用的，找到一个界定它们两者的 `DirectionCone`。
]

```cpp
<<DirectionCone Function Definitions>>=
DirectionCone Union(const DirectionCone &a, const DirectionCone &b) {
    <<Handle the cases where one or both cones are empty>>
    <<Handle the cases where one cone is inside the other>>
    <<Compute the spread angle of the merged cone, >>
    <<Find the merged cone’s axis and return cone union>>
}
```


#parec[
  If one of the cones is empty, we can immediately return the other one.
][
  如果其中一个圆锥为空，我们可以立即返回另一个。
]



```cpp
<<Handle the cases where one or both cones are empty>>=
if (a.IsEmpty()) return b;
if (b.IsEmpty()) return a;
```


#parec[
  Otherwise, the implementation computes a few angles that will be helpful, including the actual spread angle of each cone as well as the angle between their two central direction vectors. These values give enough information to determine if one cone is entirely bounded by the other (see @fig:cone-inside-another).
][
  否则，实施计算一些有用的角度，包括每个圆锥的实际张角以及它们两个中心方向向量之间的角度。 这些值提供了足够的信息来确定一个圆锥是否完全被另一个圆锥包围（见@fig:cone-inside-another）。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f23.svg"),
  caption: [
    #ez_caption[Determining If One Cone of Directions Is Entirely inside Another. Given two direction cones $a$ and $b$, their spread angles $theta_a$ and $theta_b$, and the angle between their two central direction vectors $theta_d$, we can determine if one cone is entirely inside the other. Here, $theta_a > theta_d + theta_b$, and so $b$ is inside $a$.
    ][确定一个方向圆锥是否完全在另一个圆锥内。给定两个方向圆锥 $a$ 和 $b$，它们的张角 $theta_a$ 和 $theta_b$，以及它们两个中心方向向量之间的角度 $theta_d$，我们可以确定一个圆锥是否完全在另一个圆锥内。这里，$theta_a > theta_d + theta_b$，因此 $b$ 在 $a$ 内。
    ]
  ],
)<cone-inside-another>

```cpp
<<Handle the cases where one cone is inside the other>>=
Float theta_a = SafeACos(a.cosTheta), theta_b = SafeACos(b.cosTheta);
Float theta_d = AngleBetween(a.w, b.w);
if (std::min(theta_d + theta_b, Pi) <= theta_a)
    return a;
if (std::min(theta_d + theta_a, Pi) <= theta_b)
    return b;
```

#parec[
  Otherwise, it is necessary to compute a new cone that bounds both of them. As illustrated in @fig:cone-bound-two-angle, the sum of $theta_a$, $theta_d$, and $theta_b$ gives the full angle that the new cone must cover; half of that is its spread angle.
][
  否则，有必要计算一个新的圆锥来界定它们两者。如@fig:cone-bound-two-angle 所示， $theta_a$ 、 $theta_d$ 和 $theta_b$ 的总和给出了新圆锥必须覆盖的完整角度；其张角是其一半。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f24.svg"),
  caption: [
    #ez_caption[Computing the Spread Angle of the Direction Cone That Bounds Two Others. If $theta_d$ is the angle between two cones’ central axes and the two cones have spread angles $theta_a$ and $theta_b$, then the total angle that the cone bounds is $theta_a + theta_d + theta_b$ and so its spread angle is half of that.
    ][计算界定两个其他方向圆锥的方向圆锥的张角。如果 $theta_d$ 是两个圆锥中心轴之间的角度，并且两个圆锥有张角 $theta_a$ 和 $theta_b$，那么圆锥界定的总角度是 $theta_a + theta_d + theta_b$，所以其张角是其一半。
    ]
  ],
)<cone-bound-two-angle>

```cpp
<<Compute the spread angle of the merged cone, >>=
Float theta_o = (theta_a + theta_d + theta_b) / 2;
if (theta_o >= Pi)
    return DirectionCone::EntireSphere();
```


#parec[
  The direction vector for the new cone should _not_ be set with the average of the two cones' direction vectors; that vector and a spread angle of $theta_o$ does not necessarily bound the two given cones. Using that vector would require a spread angle of $frac(theta_d, 2) + max(2 theta_a, 2 theta_b),$, which is never less than $theta_o$. (It is worthwhile to sketch out a few cases on paper to convince yourself of this.)
][
  新圆锥的方向向量_不应该_通过两个圆锥方向向量的平均值来设定；该向量和扩展角 $theta_o$ 不一定能包围给定的两个圆锥。使用该向量将需要一个扩展角 $frac(theta_d, 2) + max(2 theta_a, 2 theta_b)$，这个角度从不小于 $theta_o$。（值得在纸上画出几个例子来让自己确信这一点。）
]

#parec[
  Instead, we find the vector perpendicular to the cones'; direction vectors using the cross product and rotate `a.w` by the angle around that axis that causes it to bound both cones' angles. (The `Rotate()` function used for this will be introduced shortly, in @rotation-around-an-arbitrary-axis). In the case that `LengthSquared(wr) == 0` , the vectors face in opposite directions and a bound of the entire sphere is returned.#footnote[A tighter bound is&#10;possible in this case, but it occurs very rarely and so we have not bothered with&#10;handling it more effectively.]
][
  相反，我们通过使用叉积找到垂直于两个圆锥方向向量的向量，并将 `a.w` 绕该轴旋转，使其能够包围两个圆锥的角度。（用于此操作的 `Rotate()` 函数将在@rotation-around-an-arbitrary-axis 中引入。）如果 `LengthSquared(wr) == 0` ，则向量朝相反方向，并返回整个球的包围。#footnote[在这种情况下可以有一个更紧的边界，但这种情况非常罕见，因此我们没有费心去更有效地处理它。]
]

```cpp
<<Find the merged cone’s axis and return cone union>>=
Float theta_r = theta_o - theta_a;
Vector3f wr = Cross(a.w, b.w);
if (LengthSquared(wr) == 0)
    return DirectionCone::EntireSphere();
Vector3f w = Rotate(Degrees(theta_r), wr)(a.w);
return DirectionCone(w, std::cos(theta_o));
```