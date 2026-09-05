#import "../template.typ": parec, ez_caption, translator

== #ez_caption[Interactions][交互信息]
<interactions>
#parec[
  The last abstractions in this chapter, `SurfaceInteraction` and `MediumInteraction`, respectively represent local information at points on surfaces and in participating media. For example, the ray–shape intersection routines in Chapter #link("https://pbr-book.org/4ed/Shapes.html#chap:shapes")[6] return information about the local differential geometry at intersection points in a `SurfaceInteraction`. Later, the texturing code in Chapter #link("https://pbr-book.org/4ed/Textures_and_Materials.html#chap:texture")[10] computes material properties using values from the `SurfaceInteraction`. The closely related #link(<MediumInteraction>)[`MediumInteraction`] class is used to represent points where light interacts with participating media like smoke or clouds. The implementations of all of these classes are in the files `interaction.h` and `interaction.cpp`.
][
  本章最后介绍的两个抽象，`SurfaceInteraction` 和 `MediumInteraction`，分别表示表面点与参与介质内部点处的局部信息。例如，第 #link("https://pbr-book.org/4ed/Shapes.html#chap:shapes")[6] 章中的光线与形状相交的例程在 `SurfaceInteraction` 中返回关于相交点的局部微分几何信息。稍后，第 #link("https://pbr-book.org/4ed/Textures_and_Materials.html#chap:texture")[10] 章中的纹理代码使用 `SurfaceInteraction` 中的值计算材质属性。相关的 #link(<MediumInteraction>)[`MediumInteraction`] 类用于表示光与参与介质（如烟雾或云）相互作用的点。这些类的实现都在文件 `interaction.h` 和 `interaction.cpp` 中。
]

#parec[
  Both `SurfaceInteraction` and #link(<MediumInteraction>)[`MediumInteraction`] inherit from a generic `Interaction` class that provides common member variables and methods, which allows parts of the system for which the differences between surface and medium interactions do not matter to be implemented purely in terms of `Interaction`s.
][
  `SurfaceInteraction` 和 #link(<MediumInteraction>)[`MediumInteraction`] 都继承自一个通用基类 `Interaction`，该类提供了共用的成员变量和方法，使得系统中不关注表面与介质交互差异的部分可以仅基于 `Interaction` 实现。
]

#block(sticky: true)[#raw("<<Interaction Definition>>=")] <fragment-InteractionDefinition-0>
```cpp
class Interaction {
  public:
    <<Interaction Public Methods>> 
    <<Interaction Public Members>> 
};
``` <Interaction>


#parec[
  A variety of `Interaction` constructors are available; depending on what sort of interaction is being constructed and what sort of information about it is relevant, corresponding sets of parameters are accepted. This one is the most general of them.
][
  提供了多种 `Interaction` 构造函数；根据构造的交互类型及其相关信息，接受相应的参数集。这是其中最通用的一种。
]

#block(sticky: true)[#raw("<<Interaction Public Methods>>=") #link(<fragment-InteractionPublicMethods-1>)[▼]] <fragment-InteractionPublicMethods-0>
```cpp
Interaction(Point3fi pi, Normal3f n, Point2f uv, Vector3f wo, Float time)
    : pi(pi), n(n), uv(uv), wo(Normalize(wo)), time(time) {}
```


#parec[
  All interactions have a point $p$ associated with them. This point is stored using the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] class, which uses an #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] to represent each coordinate value. Storing a small interval of floating-point values rather than a single #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Float")[`Float`] makes it possible to represent bounds on the numeric error in the intersection point, as occurs when the point $p$ was computed by a ray intersection calculation. This information will be useful for avoiding incorrect self-intersections for rays leaving surfaces, as will be discussed in @robust-spawned-ray-origins .
][
  所有交互都有一个与之关联的点 $p$。这个点使用 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] 类存储，该类使用 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] 来表示每个坐标值。存储一小段浮点值区间而不是单个 #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Float")[`Float`] 使得能够表示交点数值误差的界限，这在点 $p$ 是通过光线相交计算得出时会发生。这些信息对于避免光线离开表面时的错误自相交将非常有用，如将在@robust-spawned-ray-origins 中讨论的那样。
]

#block(sticky: true)[#raw("<<Interaction Public Members>>=") #link(<fragment-InteractionPublicMembers-1>)[▼]] <fragment-InteractionPublicMembers-0>
```cpp
Point3fi pi;
```


#parec[
  `Interaction` provides a convenience method that returns a regular #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] for the interaction point for the parts of the system that do not need to account for any error in it (e.g., the texture evaluation routines).
][
  `Interaction` 提供了一个便捷方法，返回一个常规的 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 用于系统中不需要考虑其误差的部分（例如，纹理评估例程）。
]

#block(sticky: true)[#raw("<<Interaction Public Methods>>+=") #link(<fragment-InteractionPublicMethods-0>)[▲] #link(<fragment-InteractionPublicMethods-2>)[▼]] <fragment-InteractionPublicMethods-1>
```cpp
Point3f p() const { return Point3f(pi); }
```


#parec[
  All interactions also have a time associated with them. Among other uses, this value is necessary for setting the time of a spawned ray leaving the interaction.
][
  所有交互也都有一个与之关联的时间值。除其他用途外，该值对于设置离开交互的生成光线的时间是必要的。
]

#block(sticky: true)[#raw("<<Interaction Public Members>>+=") #link(<fragment-InteractionPublicMembers-0>)[▲] #link(<fragment-InteractionPublicMembers-2>)[▼]] <fragment-InteractionPublicMembers-1>
```cpp
Float time = 0;
```


#parec[
  For interactions that lie along a ray (either from a ray–shape intersection or from a ray passing through participating media), the negative ray direction is stored in the `wo` member variable, which corresponds to $omega_o$, the notation we use for the outgoing direction when computing lighting at points. For other types of interaction points where the notion of an outgoing direction does not apply (e.g., those found by randomly sampling points on the surface of shapes), `wo` has the value $(0, 0, 0)$.
][
  对于位于射线上的交互（无论来自射线与形状求交，还是射线在参与介质中传播），射线方向的相反方向存储在 `wo` 成员变量中，对应于计算点处光照时表示出射方向的符号 $omega_o$。对于其他类型的交互点，出射方向的概念不适用（例如，通过随机采样形状表面上的点找到的那些），`wo` 的值为 $(0, 0, 0)$。
]

#block(sticky: true)[#raw("<<Interaction Public Members>>+=") #link(<fragment-InteractionPublicMembers-1>)[▲] #link(<fragment-InteractionPublicMembers-3>)[▼]] <fragment-InteractionPublicMembers-2>
```cpp
Vector3f wo;
```


#parec[
  For interactions on surfaces, `n` stores the surface normal at the point and `uv` stores its $(u, v)$ parametric coordinates. It is fair to ask, why are these values stored in the base `Interaction` class rather than in `SurfaceInteraction`? The reason is that there are some parts of the system that #emph[mostly] do not care about the distinction between surface and medium interactions— for example, some of the routines that sample points on light sources given a point to be illuminated. Those make use of these values if they are available and ignore them if they are set to zero. By accepting the small dissonance of having them in the wrong place here, the implementations of those methods and the code that calls them is made that much simpler.
][
  对于表面上的交互，`n` 存储点的表面法向量，`uv` 存储其 $(u, v)$ 参数坐标。可以问，为什么这些值存储在基类 `Interaction` 而不是 `SurfaceInteraction` 中？原因是系统中有些部分#emph[大多]不关心表面和介质交互的区别——例如，给定一个要照亮的点，某些例程会采样光源上的点。如果这些值可用，它们会被使用，如果它们被设置为零，则会被忽略。虽然这些值的位置不太合适，但接受这一点可以简化这些方法的实现和调用。
]

#block(sticky: true)[#raw("<<Interaction Public Members>>+=") #link(<fragment-InteractionPublicMembers-2>)[▲] #link(<fragment-InteractionPublicMembers-4>)[▼]] <fragment-InteractionPublicMembers-3>
```cpp
Normal3f n;
Point2f uv;
```


#parec[
  It is possible to check if a pointer or reference to an `Interaction` is one of the two subclasses. A nonzero surface normal is used as a distinguisher for a surface.
][
  可以检查指针或引用的 `Interaction` 是否为两个子类之一。通过表面法向量是否为零，可以区分表面交互与介质交互。
]

#block(sticky: true)[#raw("<<Interaction Public Methods>>+=") #link(<fragment-InteractionPublicMethods-1>)[▲] #link(<fragment-InteractionPublicMethods-3>)[▼]] <fragment-InteractionPublicMethods-2>
```cpp
bool IsSurfaceInteraction() const { return n != Normal3f(0, 0, 0); }
bool IsMediumInteraction() const { return !IsSurfaceInteraction(); }
```


#parec[
  Methods are provided to cast to the subclass types as well. This is a good place for a runtime check to ensure that the requested conversion is valid. The non-`const` variant of this method as well as corresponding `AsMedium()` methods follow similarly and are not included in the text.
][
  还提供了方法来转换为子类类型。可以在这里进行运行时检查，确保所请求的转换有效。非 `const` 变体及相应的 `AsMedium()` 方法实现类似，此处不再列出。
]

#block(sticky: true)[#raw("<<Interaction Public Methods>>+=") #link(<fragment-InteractionPublicMethods-2>)[▲]] <fragment-InteractionPublicMethods-3>
```cpp
const SurfaceInteraction &AsSurface() const {
    CHECK(IsSurfaceInteraction());
    return (const SurfaceInteraction &)*this;
}
```

#parec[
  Interactions can also represent either an interface between two types of participating media using an instance of the #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#MediumInterface")[`MediumInterface`] class, which is defined in Section #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#sec:media")[11.4], or the properties of the scattering medium at their point using a #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#Medium")[`Medium`]. Here as well, the `Interaction` abstraction leaks: surfaces can represent interfaces between media, and at a point inside a medium, there is no interface but there is the current medium. Both of these values are stored in `Interaction` for the same reasons of expediency that `n` and `uv` were.
][
  交互还可以使用 #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#MediumInterface")[`MediumInterface`] 类的实例表示两种参与介质之间的界面，该类在 #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#sec:media")[11.4] 节中定义，或使用 #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#Medium")[`Medium`] 表示其点的散射介质的属性。在这里，`Interaction` 抽象也有泄漏：表面可以表示介质之间的界面，而在介质内部的点，不存在界面，但需要记录当前介质。出于与 `n` 和 `uv` 相同的简便性原因，这两个值都存储在 `Interaction` 中。
]

#block(sticky: true)[#raw("<<Interaction Public Members>>+=") #link(<fragment-InteractionPublicMembers-3>)[▲]] <fragment-InteractionPublicMembers-4>
```cpp
const MediumInterface *mediumInterface = nullptr;
Medium medium = nullptr;
```


=== #ez_caption[Surface Interaction][表面交互]
<surface-interaction>
#parec[
  As described earlier, the geometry of a particular point on a surface (often a position found by intersecting a ray against the surface) is represented by a `SurfaceInteraction`. Having this abstraction lets most of the system work with points on surfaces without needing to consider the particular type of geometric shape the points lie on.
][
  如前所述，表面上某一点的几何（通常是通过射线与表面相交找到的位置）由 `SurfaceInteraction` 表示。这种抽象使得系统的大部分功能可以处理表面上的点，而无需考虑这些点所处的几何形状类型。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Definition>>=")] <fragment-SurfaceInteractionDefinition-0>
```cpp
class SurfaceInteraction : public Interaction {
  public:
    <<SurfaceInteraction Public Methods>> 
    <<SurfaceInteraction Public Members>> 
};
``` <SurfaceInteraction>

#parec[
  In addition to the point `p`, the surface normal `n`, and $(u , v)$ coordinates from the parameterization of the surface from the `Interaction` base class, the `SurfaceInteraction` also stores the parametric partial derivatives of the point $frac(partial p, partial u)$ and $frac(partial p, partial v)$ and the partial derivatives of the surface normal $frac(partial upright(bold(n)), partial u)$ and $frac(partial upright(bold(n)), partial v)$. See @fig:differential-geometry for a depiction of these values.
][
  除了点 `p`、表面法向量 `n` 和来自 `Interaction` 基类的 $(u , v)$ 坐标外，`SurfaceInteraction` 还存储了点的参数偏导数 $frac(partial p, partial u)$、$frac(partial p, partial v)$，以及表面法向量的偏导数 $frac(partial upright(bold(n)), partial u)$、$frac(partial upright(bold(n)), partial v)$。参见@fig:differential-geometry 以了解这些值的描述。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Public Members>>=") #link(<fragment-SurfaceInteractionPublicMembers-1>)[▼]] <fragment-SurfaceInteractionPublicMembers-0>
```cpp
Vector3f dpdu, dpdv;
Normal3f dndu, dndv;
```

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f31.svg"),
  caption: [#ez_caption[The Local Differential Geometry around a Point $p$. The parametric partial derivatives of the surface, $frac(partial p, partial u)$ and $frac(partial p, partial v)$, lie in the tangent plane but are not necessarily orthogonal. The surface normal $upright(bold(n))$ is given by the cross product of $frac(partial p, partial u)$ and $frac(partial p, partial v)$. The vectors $frac(partial upright(bold(n)), partial u)$ and $frac(partial upright(bold(n)), partial v)$ record the differential change in surface normal as we move $u$ and $v$ along the surface.][点 $p$ 附近的局部微分几何。表面的参数偏导数 $frac(partial p, partial u)$、$frac(partial p, partial v)$ 位于切平面内，但不一定正交。表面法向量 $upright(bold(n))$ 由这两个偏导数的叉积给出。$frac(partial upright(bold(n)), partial u)$ 和 $frac(partial upright(bold(n)), partial v)$ 记录沿表面改变 $u$、$v$ 时法向量的微分变化。]],
) <differential-geometry>



#parec[
  This representation implicitly assumes that shapes have a parametric description—that for some range of ( $(u, v)$ ) values, points on the surface are given by some function ( $f$ ) such that ( $p = f(u, v)$ ). Although this is not true for all shapes, all of the shapes that `pbrt` supports do have at least a local parametric description, so we will stick with the parametric representation since this assumption is helpful elsewhere (e.g., for antialiasing of textures in @textures-and-materials ).
][
  这种表示法隐含地假设形状具有参数描述——在一定的 $(u,v)$ 取值范围内，表面点可由函数 $f$ 表示为 $p=f(u,v)$。虽然这对所有形状并不适用，但 `pbrt` 支持的所有形状至少都有局部的参数描述，因此我们将坚持使用参数表示，因为这种假设在其他地方是有帮助的（例如，在@textures-and-materials 中用于纹理的抗锯齿）。
]

#parec[
  The #link(<SurfaceInteraction>)[SurfaceInteraction] constructor takes parameters that set all of these values. It computes the normal as the cross product of the partial derivatives.
][
  #link(<SurfaceInteraction>)[SurfaceInteraction] 构造函数接受用于设置这些量的参数，并通过两个偏导数的叉积计算法向量。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Public Methods>>=") #link(<fragment-SurfaceInteractionPublicMethods-1>)[▼]] <fragment-SurfaceInteractionPublicMethods-0>
```cpp
SurfaceInteraction(Point3fi pi, Point2f uv, Vector3f wo, Vector3f dpdu,
        Vector3f dpdv, Normal3f dndu, Normal3f dndv, Float time,
        bool flipNormal)
    : Interaction(pi, Normal3f(Normalize(Cross(dpdu, dpdv))), uv, wo, time),
      dpdu(dpdu), dpdv(dpdv), dndu(dndu), dndv(dndv) {
    <<Initialize shading geometry from true geometry>> 
    <<Adjust normal based on orientation and handedness>> 
}
```
#parec[
  `SurfaceInteraction` stores a second instance of a surface normal and the various partial derivatives to represent possibly perturbed values of these quantities—as can be generated by bump mapping or interpolated per-vertex normals with meshes. Some parts of the system use this shading geometry, while others need to work with the original quantities.
][
  `SurfaceInteraction` 存储了表面法向量的第二个实例和各种偏导数，以表示这些量可能的扰动值——例如通过凹凸贴图或网格的插值顶点法向量生成的。 系统的某些部分使用这种着色几何，而其他部分需要使用原始量。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Public Members>>+=") #link(<fragment-SurfaceInteractionPublicMembers-0>)[▲] #link(<fragment-SurfaceInteractionPublicMembers-2>)[▼]] <fragment-SurfaceInteractionPublicMembers-1>
```cpp
struct {
    Normal3f n;
    Vector3f dpdu, dpdv;
    Normal3f dndu, dndv;
} shading;
```
#parec[
  The shading geometry values are initialized in the constructor to match the original surface geometry.
][
  着色几何值在构造函数中初始化为与原始表面几何匹配。
]

#parec[
  If shading geometry is present, it generally is not computed until some time after the `SurfaceInteraction` constructor runs. The `SetShadingGeometry()` method, to be defined shortly, updates the shading geometry.
][
  如果存在着色几何，通常要等到 `SurfaceInteraction` 构造完成后才计算。稍后将定义的 `SetShadingGeometry()` 方法更新着色几何。
]

#block(sticky: true)[#raw("<<Initialize shading geometry from true geometry>>=")] <fragment-Initializeshadinggeometryfromtruegeometry-0>
```cpp
shading.n = n;
shading.dpdu = dpdu;
shading.dpdv = dpdv;
shading.dndu = dndu;
shading.dndv = dndv;
```

#parec[
  The surface normal has special meaning to `pbrt`, which assumes that, for closed shapes, the normal is oriented such that it points to the outside of the shape. For geometry used as an area light source, light is by default emitted from only the side of the surface that the normal points toward; the other side is black. Because normals have this special meaning, `pbrt` provides a mechanism for the user to reverse the orientation of the normal, flipping it to point in the opposite direction. A `ReverseOrientation` directive in a `pbrt` input file flips the normal to point in the opposite, non-default direction. Therefore, it is necessary to check if the given `Shape` has the corresponding flag set and, if so, switch the normal's direction here.
][
  表面法向量对 `pbrt` 有特殊意义，它假设对于封闭形状，法向量的方向指向形状的外部。 对于用作面光源的几何体，默认情况下，光仅从法向量指向的一侧发出；另一侧是黑色的。 由于法向量具有这种特殊意义，`pbrt` 提供了一种机制，允许用户反转法向量的方向，使其指向相反的方向。 在 `pbrt` 输入文件中的 `ReverseOrientation` 指令将法向量翻转为指向相反的非默认方向。 因此，有必要检查给定的 `Shape` 是否设置了相应的标志，如果是，则在此处切换法向量的方向。
]

#parec[
  However, one other factor plays into the orientation of the normal and must be accounted for here as well.
][
  然而，影响法向量方向的另一个因素也必须在此考虑。
]

#parec[
  If a shape's transformation matrix has switched the handedness of the object coordinate system from `pbrt`'s default left-handed coordinate system to a right-handed one, we need to switch the orientation of the normal as well.
][
  如果形状的变换矩阵将对象坐标系的手性从 `pbrt` 的默认左手坐标系切换为右手坐标系，我们也需要切换法向量的方向。
]

#parec[
  To see why this is so, consider a scale matrix $upright(bold(S))(1, 1, -1)$. We would naturally expect this scale to switch the direction of the normal, although because we have computed the normal by $upright(bold(n)) = frac(partial p, partial u) times frac(partial p, partial v)$ ,
][
  要理解这一点，请考虑一个缩放矩阵 $upright(bold(S))(1, 1, -1)$。我们自然会期望这种缩放会切换法向量的方向，尽管我们是通过$upright(bold(n)) = frac(partial p, partial u) times frac(partial p, partial v)$ 计算法向量的，
]


$
  bold("S") (1 , 1 , - 1) frac(partial p, partial u) times bold("S") (
    1 , 1 , - 1
  ) frac(partial p, partial v) & = bold("S") (- 1 , - 1 , 1) (
    frac(partial p, partial u) times frac(partial p, partial v)
  )\
  & = bold("S") (- 1 , - 1 , 1) upright(bold(n))\
  & eq.not bold("S") (1 , 1 , - 1) upright(bold(n)) .
$


#parec[
  Therefore, it is also necessary to flip the normal's direction if the transformation switches the handedness of the coordinate system, since the flip will not be accounted for by the computation of the normal's direction using the cross product. A flag passed by the caller indicates whether this flip is necessary.
][
  因此，如果变换改变了坐标系的手性，也有必要翻转法向量的方向，因为通过叉积计算法向量方向时不会考虑翻转。调用者传递的一个标志指示是否需要这种翻转。
]

#block(sticky: true)[#raw("<<Adjust normal based on orientation and handedness>>=")] <fragment-Adjustnormalbasedonorientationandhandedness-0>
```cpp
if (flipNormal) {
    n *= -1;
    shading.n *= -1;
}
```

#parec[
  `pbrt` also provides the capability to associate an integer index with each face of a polygon mesh. This information is used for certain texture mapping operations. A separate `SurfaceInteraction` constructor allows its specification.
][
  `pbrt` 还提供了将整数索引与多边形网格的每个面关联的功能。此信息用于某些纹理映射操作。一个单独的 `SurfaceInteraction` 构造函数允许指定它。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Public Members>>+=") #link(<fragment-SurfaceInteractionPublicMembers-1>)[▲]] <fragment-SurfaceInteractionPublicMembers-2>
```cpp
int faceIndex = 0;
```

#parec[
  When a shading coordinate frame is computed, the `SurfaceInteraction` is updated via its `SetShadingGeometry()` method.
][
  当计算着色标架时，通过其 `SetShadingGeometry()` 方法更新 `SurfaceInteraction`。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Public Methods>>+=") #link(<fragment-SurfaceInteractionPublicMethods-0>)[▲]] <fragment-SurfaceInteractionPublicMethods-1>
```cpp
void SetShadingGeometry(Normal3f ns, Vector3f dpdus, Vector3f dpdvs,
        Normal3f dndus, Normal3f dndvs, bool orientationIsAuthoritative) {
    <<Compute shading.n for SurfaceInteraction>> 
    <<Initialize shading partial derivative values>> 
}
```

#parec[
  After performing the same cross product (and possibly flipping the orientation of the normal) as before to compute an initial shading normal, the implementation then flips either the shading normal or the true geometric normal if needed so that the two normals lie in the same hemisphere. Since the shading normal generally represents a relatively small perturbation of the geometric normal, the two of them should always be in the same hemisphere. Depending on the context, either the geometric normal or the shading normal may more authoritatively point toward the correct "outside" of the surface, so the caller passes a Boolean value that determines which should be flipped if needed.
][
  在执行与之前相同的叉积（并可能翻转法向量的方向）以计算初始着色法向量后，实现随后根据需要翻转着色法向量或真实几何法向量，以便两个法向量位于同一半球中。 因为着色法向量通常是几何法向量的一个相对较小的扰动，所以它们应始终位于同一半球中。 根据上下文，应以几何法向量或着色法向量中的一个为准，确定表面的正确“外侧”。因此，调用者传入一个布尔值，指定必要时应翻转哪一个。#translator[固定原文此处描述了先用叉积计算初始着色法向量，但随后代码直接以 `shading.n = ns` 采用传入法向量；该方法内部没有此处所说的叉积计算。英文原文与实际代码均保留，差异在此说明。]
]

#block(sticky: true)[#raw("<<Compute shading.n for SurfaceInteraction>>=")] <fragment-Computemonoshading.nformonoSurfaceInteraction-0>
```cpp
shading.n = ns;
if (orientationIsAuthoritative)
    n = FaceForward(n, shading.n);
else
    shading.n = FaceForward(shading.n, n);
```


#parec[
  With the normal set, the various partial derivatives can be copied.
][
  设置法向量后，可以复制各种偏导数。
]

#block(sticky: true)[#raw("<<Initialize shading partial derivative values>>=")] <fragment-Initializemonoshadingpartialderivativevalues-0>
```cpp
shading.dpdu = dpdus;
shading.dpdv = dpdvs;
shading.dndu = dndus;
shading.dndv = dndvs;
```
=== #ez_caption[Medium Interaction][介质交互]

#parec[
  As described earlier, the `MediumInteraction` class is used to represent an interaction at a point in a scattering medium like smoke or clouds.
][
  如前所述，`MediumInteraction` 类用于表示在烟雾或云等散射介质中的某一点的交互。
]

#block(sticky: true)[#raw("<<MediumInteraction Definition>>=")] <fragment-MediumInteractionDefinition-0>
```cpp
class MediumInteraction : public Interaction {
  public:
    <<MediumInteraction Public Methods>> 
    <<MediumInteraction Public Members>> 
};
``` <MediumInteraction>


#parec[
  In contrast to `SurfaceInteraction`, it adds little to the base #link(<Interaction>)[Interaction] class. The only addition is a #link("https://pbr-book.org/4ed/Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction], which describes how the particles in the medium scatter light. Phase functions and the #link("https://pbr-book.org/4ed/Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction] class are introduced in @phase-functions .
][
  与 `SurfaceInteraction` 相比，它只在基类 #link(<Interaction>)[Interaction] 上增加了少量内容。 唯一的添加是一个 #link("https://pbr-book.org/4ed/Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction]，它描述了介质中的粒子如何散射光。 相函数和 #link("https://pbr-book.org/4ed/Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction] 类在@phase-functions 中介绍。
]

#block(sticky: true)[#raw("<<MediumInteraction Public Methods>>=")] <fragment-MediumInteractionPublicMethods-0>
```cpp
MediumInteraction(Point3f p, Vector3f wo, Float time, Medium medium,
                  PhaseFunction phase)
    : Interaction(p, wo, time, medium), phase(phase) {}
```

#block(sticky: true)[#raw("<<MediumInteraction Public Members>>=")] <fragment-MediumInteractionPublicMembers-0>
```cpp
PhaseFunction phase;
```

#heading(level: 3, numbering: none)[#ez_caption[Supplement: Additional Code in the Original Collapsed Panels][补充：原网页折叠面板中的额外代码]]
#include "supplements/3.11-expanded.typ"
