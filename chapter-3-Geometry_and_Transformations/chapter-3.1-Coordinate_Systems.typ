#import "../template.typ": parec, ez_caption


== #ez_caption[Coordinate Systems][坐标系]
<coordinate-systems>
#parec[
  As is typical in computer graphics, `pbrt` represents three-dimensional points, vectors, and normal vectors with three coordinate values: $x$, $y$, and $z$. These values are meaningless without a #emph[coordinate system] that defines the origin of the space and gives three linearly independent vectors that define the $x$, $y$, and $z$ axes of the space. Together, the origin and three vectors are called the #emph[frame] that defines the coordinate system. Given an arbitrary point or direction in 3D, its $(x, y, z)$ coordinate values depend on its relationship to the frame. @fig:point-wrt-coordsys shows an example that illustrates this idea in 2D.
][
  与计算机图形学中的常见做法一样，`pbrt` 用三个坐标值 $x$、$y$ 和 $z$ 表示三维点、向量和法向量。这些值只有在#emph[坐标系]中才有意义：坐标系规定空间的原点，并给出三个线性无关的向量，定义空间的 $x$、$y$ 和 $z$ 轴。原点与这三个向量合称定义坐标系的#emph[标架]。对于三维空间中的任意点或方向，其 $(x, y, z)$ 坐标值取决于它与标架的关系。@fig:point-wrt-coordsys 用二维例子说明了这一概念。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f01.svg"),
  caption: [
    #ez_caption[
      In 2D, the $(x, y)$ coordinates of a point $p$ are defined by the relationship of the point to a particular 2D coordinate system. Here, two coordinate systems are shown; the point might have coordinates $(3,3)$ with respect to the coordinate system with its coordinate axes drawn in solid lines but have coordinates $(2, -4)$ with respect to the coordinate system with dashed axes. In either case, the 2D point $p$ is at the same absolute position in space.
    ][
      在二维空间中，点 $p$ 的 $(x, y)$ 坐标由它与某个二维坐标系的关系确定。图中显示了两个坐标系：相对于坐标轴用实线表示的坐标系，该点的坐标可能是 $(3,3)$；相对于坐标轴用虚线表示的坐标系，其坐标却可能是 $(2,-4)$。无论采用哪个坐标系，二维点 $p$ 在空间中的绝对位置都没有改变。
    ]
  ],
)
<point-wrt-coordsys>

#parec[
  In the general $n$-dimensional case, a frame's origin $p_o$ and its $n$ linearly independent basis vectors define an $n$-dimensional #emph[affine space]. All vectors $bold(v)$ in the space can be expressed as a linear combination of the basis vectors. Given a vector $bold(v)$ and the basis vectors $bold(v)_i$, there is a unique set of scalar values $s_i$ such that
][
  在一般的 $n$ 维情形下，标架的原点 $p_o$ 及其 $n$ 个线性无关的基向量定义了一个 $n$ 维#emph[仿射空间]。空间中的任意向量 $bold(v)$ 都可表示为基向量的线性组合。给定向量 $bold(v)$ 和基向量 $bold(v)_i$，存在唯一一组标量值 $s_i$，使得
]

$
  bold(v) = s_1 bold(v)_1 + dots.c + s_n bold(v)_n
$

#parec[
  The scalars $s_i$ are the #emph[representation] of $bold(v)$ with respect to the basis ${bold(v)_1, bold(v)_2, dots.c , bold(v)_n}$ and are the coordinate values that we store with the vector. Similarly, for all points $p$, there are unique scalars $s_i$ such that the point can be expressed in terms of the origin $p_o$ and the basis vectors
][
  标量 $s_i$ 是向量 $bold(v)$ 相对于基 ${bold(v)_1, bold(v)_2, dots.c , bold(v)_n}$ 的 #emph[表示形式]，也是我们与向量一起存储的坐标值。类似地，对于所有点 $p$，存在唯一的标量 $s_i$，使得该点可以用原点 $p_o$ 和基向量表示为
]

$
  p = p_o + s_1 bold(v)_1 + dots.c + s_n bold(v)_n
$

#parec[
  Thus, although points and vectors are both represented by $x$, $y$, and $z$ coordinates in 3D, they are distinct mathematical entities and are not freely interchangeable.
][
  因此，尽管点和向量在三维中都用 $x$、$y$ 和 $z$ 坐标表示，但它们是不同的数学实体，并不是可以自由互换的。
]

#parec[
  This definition of points and vectors in terms of coordinate systems reveals a paradox: to define a frame we need a point and a set of vectors, but we can only meaningfully talk about points and vectors with respect to a particular frame. Therefore, in three dimensions we need a #emph[standard frame] with origin $(0, 0, 0)$ and basis vectors $(1, 0, 0)$, $(0, 1, 0)$, and $(0, 0, 1)$. All other frames will be defined with respect to this canonical coordinate system, which we call #emph[world space].
][
  这种通过坐标系来定义点和向量的方式揭示了一个悖论：为了定义一个标架，我们需要一个点和一组向量，但我们只能相对于特定标架有意义地谈论点和向量。因此，在三维空间中，我们需要一个原点为 $(0, 0, 0)$ 和基向量为 $(1, 0, 0)$、$(0, 1, 0)$ 和 $(0, 0, 1)$ 的 #emph[标准标架]。所有其他标架都将相对于这个标准坐标系定义，我们称之为 #emph[世界空间]。
]

=== #ez_caption[Coordinate System Handedness][坐标系的手性]

#parec[
  There are two different ways that the three coordinate axes can be arranged, as shown in @fig:handedness . Given perpendicular $x$ and $y$ coordinate axes, the $z$ axis can point in one of two directions. These two choices are called #emph[left-handed] and #emph[right-handed]. The choice between the two is arbitrary but has a number of implications for how some of the geometric operations throughout the system are implemented. `pbrt` uses a left-handed coordinate system.
][
  三条坐标轴可以以两种不同的方式进行排列，如@fig:handedness 所示。给定相互垂直的 $x$ 和 $y$ 坐标轴， $z$ 轴可以指向两个方向之一。这两种选择被称为 #emph[左手坐标系] 和 #emph[右手坐标系]。在两者之间的选择是任意的，但对系统中某些几何操作的实现有多方面的影响。`pbrt` 使用左手坐标系。
]


#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f02.svg"),
  caption: [
    #ez_caption[
      (a) In a left-handed coordinate system, the $z$ axis points into the page when the $x$ and $y$ axes are oriented with $x$ pointing to the right and $y$ pointing up. (b) In a right-handed system, the $z$ axis points out of the page.
    ][
      （a）在左手坐标系中，当 $x$ 轴指向右侧、$y$ 轴指向上方时，$z$ 轴指向页面内部。（b）在右手系统中，$z$ 轴指向页面外部。
    ]
  ],
) <handedness>
