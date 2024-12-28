#import "../template.typ": parec

== Interactions
<interactions>
#parec[
  The last abstractions in this chapter, `SurfaceInteraction` and `MediumInteraction`, respectively represent local information at points on surfaces and in participating media. For example, the ray–shape intersection routines in Chapter #link("../Shapes.html#chap:shapes")[6] return information about the local differential geometry at intersection points in a `SurfaceInteraction`. Later, the texturing code in Chapter #link("../Textures_and_Materials.html#chap:texture")[10] computes material properties using values from the `SurfaceInteraction`. The closely related #link("<MediumInteraction>")[`MediumInteraction`] class is used to represent points where light interacts with participating media like smoke or clouds. The implementations of all of these classes are in the files `interaction.h` and `interaction.cpp`.
][
  本章最后的抽象类，`SurfaceInteraction` 和 `MediumInteraction`，分别表示表面上的点和参与介质中的局部信息。例如，第 #link("../Shapes.html#chap:shapes")[6] 章中的光线与形状相交的例程在 `SurfaceInteraction` 中返回关于相交点的局部微分几何信息。稍后，第 #link("../Textures_and_Materials.html#chap:texture")[10] 章中的纹理代码使用 `SurfaceInteraction` 中的值计算材料属性。相关的 #link("<MediumInteraction>")[`MediumInteraction`] 类用于表示光与参与介质（如烟雾或云）相互作用的点。这些类的实现都在文件 `interaction.h` 和 `interaction.cpp` 中。
]

#parec[
  Both `SurfaceInteraction` and #link("<MediumInteraction>")[`MediumInteraction`] inherit from a generic `Interaction` class that provides common member variables and methods, which allows parts of the system for which the differences between surface and medium interactions do not matter to be implemented purely in terms of `Interaction`s.
][
  `SurfaceInteraction` 和 #link("<MediumInteraction>")[`MediumInteraction`] 都继承自一个通用基类 `Interaction`，该类提供了成员变量和方法，使得系统中不关注表面与介质交互差异的部分可以仅基于 `Interaction` 实现。
]

```cpp
class Interaction {
  public:
    <<Interaction Public Methods>> Interaction() = default;
    Interaction(Point3fi pi, Normal3f n, Point2f uv, Vector3f wo, Float time)
        : pi(pi), n(n), uv(uv), wo(Normalize(wo)), time(time) {}
    Point3f p() const { return Point3f(pi); }
    bool IsSurfaceInteraction() const { return n != Normal3f(0, 0, 0); }
    bool IsMediumInteraction() const { return !IsSurfaceInteraction(); }
    const SurfaceInteraction &AsSurface() const {
        CHECK(IsSurfaceInteraction());
        return (const SurfaceInteraction &)*this;
    }
    SurfaceInteraction &AsSurface() {
        CHECK(IsSurfaceInteraction());
        return (SurfaceInteraction &)*this;
    }
    // used by medium ctor
    PBRT_CPU_GPU
    Interaction(Point3f p, Vector3f wo, Float time, Medium medium)
        : pi(p), time(time), wo(wo), medium(medium) {}
    PBRT_CPU_GPU
    Interaction(Point3f p, Normal3f n, Float time, Medium medium)
        : pi(p), n(n), time(time), medium(medium) {}
    PBRT_CPU_GPU
    Interaction(Point3f p, Point2f uv)
        : pi(p), uv(uv) {}
    PBRT_CPU_GPU
    Interaction(const Point3fi &pi, Normal3f n, Float time = 0,
                Point2f uv = {})
        : pi(pi), n(n), uv(uv), time(time) {}
    PBRT_CPU_GPU
    Interaction(const Point3fi &pi, Normal3f n, Point2f uv)
        : pi(pi), n(n), uv(uv) {}
    PBRT_CPU_GPU
    Interaction(Point3f p, Float time, Medium medium)
        : pi(p), time(time), medium(medium) {}
    PBRT_CPU_GPU
    Interaction(Point3f p, const MediumInterface *mediumInterface)
        : pi(p), mediumInterface(mediumInterface) {}
    PBRT_CPU_GPU
    Interaction(Point3f p, Float time, const MediumInterface *mediumInterface)
        : pi(p), time(time), mediumInterface(mediumInterface) {}
    PBRT_CPU_GPU
    const MediumInteraction &AsMedium() const {
        CHECK(IsMediumInteraction());
        return (const MediumInteraction &)*this;
    }
    PBRT_CPU_GPU
    MediumInteraction &AsMedium() {
        CHECK(IsMediumInteraction());
        return (MediumInteraction &)*this;
    }

    std::string ToString() const;
    Point3f OffsetRayOrigin(Vector3f w) const {
        return pbrt::OffsetRayOrigin(pi, n, w);
    }
    Point3f OffsetRayOrigin(Point3f pt) const {
        return OffsetRayOrigin(pt - p());
    }
    RayDifferential SpawnRay(Vector3f d) const {
        return RayDifferential(OffsetRayOrigin(d), d, time, GetMedium(d));
    }
    Ray SpawnRayTo(Point3f p2) const {
        Ray r = pbrt::SpawnRayTo(pi, n, time, p2);
        r.medium = GetMedium(r.d);
        return r;
    }
    PBRT_CPU_GPU
    Ray SpawnRayTo(const Interaction &it) const {
        Ray r = pbrt::SpawnRayTo(pi, n, time, it.pi, it.n);
        r.medium = GetMedium(r.d);
        return r;
    }
    Medium GetMedium(Vector3f w) const {
        if (mediumInterface)
            return Dot(w, n) > 0 ? mediumInterface->outside :
                                  mediumInterface->inside;
        return medium;
    }
    Medium GetMedium() const {
        return mediumInterface ? mediumInterface->inside : medium;
    }
    <<Interaction Public Members>> Point3fi pi;
    Float time = 0;
    Vector3f wo;
    Normal3f n;
    Point2f uv;
    const MediumInterface *mediumInterface = nullptr;
    Medium medium = nullptr;
};
```


#parec[
  A variety of `Interaction` constructors are available; depending on what sort of interaction is being constructed and what sort of information about it is relevant, corresponding sets of parameters are accepted. This one is the most general of them.
][
  提供了多种 `Interaction` 构造函数；根据构造的交互类型及其相关信息，接受相应的参数集。这是其中最通用的一种。
]

```cpp
Interaction(Point3fi pi, Normal3f n, Point2f uv, Vector3f wo, Float time)
    : pi(pi), n(n), uv(uv), wo(Normalize(wo)), time(time) {}
```


#parec[
  All interactions have a point p associated with them. This point is stored using the #link("../Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] class, which uses an #link("../Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] to represent each coordinate value. Storing a small interval of floating-point values rather than a single #link("../Introduction/pbrt_System_Overview.html#Float")[`Float`] makes it possible to represent bounds on the numeric error in the intersection point, as occurs when the point p was computed by a ray intersection calculation. This information will be useful for avoiding incorrect self-intersections for rays leaving surfaces, as will be discussed in @robust-spawned-ray-origins .
][
  所有交互都有一个与之关联的点 $p$。这个点使用 #link("../Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`] 类存储，该类使用 #link("../Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] 来表示每个坐标值。存储一小段浮点值区间而不是单个 #link("../Introduction/pbrt_System_Overview.html#Float")[`Float`] 使得能够表示交点数值误差的界限，这在点 $p$ 是通过光线相交计算得出时会发生。这些信息对于避免光线离开表面时的错误自相交将非常有用，如将在@robust-spawned-ray-origins 中讨论的那样。
]

```cpp
Point3fi pi;
```


#parec[
  `Interaction` provides a convenience method that returns a regular #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] for the interaction point for the parts of the system that do not need to account for any error in it (e.g., the texture evaluation routines).
][
  `Interaction` 提供了一个便捷方法，返回一个常规的 #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 用于系统中不需要考虑其误差的部分（例如，纹理评估例程）。
]

```cpp
Point3f p() const { return Point3f(pi); }
```


#parec[
  All interactions also have a time associated with them. Among other uses, this value is necessary for setting the time of a spawned ray leaving the interaction.
][
  所有交互也都有一个与之关联的时间值。除其他用途外，该值对于设置离开交互的生成光线的时间是必要的。
]

```cpp
Float time = 0;
```


#parec[
  For interactions that lie along a ray (either from a ray–shape intersection or from a ray passing through participating media), the negative ray direction is stored in the `wo` member variable, which corresponds to $omega_o$, the notation we use for the outgoing direction when computing lighting at points. For other types of interaction points where the notion of an outgoing direction does not apply (e.g., those found by randomly sampling points on the surface of shapes), `wo` has the value $(0, 0, 0)$.
][
  对于沿光线的交互（无论是从光线–形状相交还是从光线穿过参与介质），负光线方向存储在 `wo` 成员变量中，对应于 $omega_o$，我们在计算点的光照时使用的符号。对于其他类型的交互点，出射方向的概念不适用（例如，通过随机采样形状表面上的点找到的那些），`wo` 的值为 $(0, 0, 0)$。
]

```cpp
Vector3f wo;
```


#parec[
  For interactions on surfaces, `n` stores the surface normal at the point and `uv` stores its $(u, v)$ parametric oordinates. It is fair to ask, why are these values stored in the base `Interaction` class rather than in `SurfaceInteraction`? The reason is that there are some parts of the system that #emph[mostly] do not care about the distinction between surface and medium interactions— for example, some of the routines that sample points on light sources given a point to be illuminated. Those make use of these values if they are available and ignore them if they are set to zero. By accepting the small dissonance of having them in the wrong place here, the implementations of those methods and the code that calls them is made that much simpler.
][
  对于表面上的交互，`n` 存储点的表面法线，`uv` 存储其 $(u, v)$ 参数坐标。可以问，为什么这些值存储在基类 `Interaction` 而不是 `SurfaceInteraction` 中？原因是系统中有些部分#emph[大多];不关心表面和介质交互的区别——例如，给定一个要照亮的点，某些例程会采样光源上的点。如果这些值可用，它们会被使用，如果它们被设置为零，则会被忽略。虽然这些值的位置不太合适，但接受这一点可以简化这些方法的实现和调用。
]

```cpp
Normal3f n;
Point2f uv;
```


#parec[
  It is possible to check if a pointer or reference to an `Interaction` is one of the two subclasses. A nonzero surface normal is used as a distinguisher for a surface.
][
  可以检查指针或引用的 `Interaction` 是否为两个子类之一。非零表面法线用作表面的区分符。
]

```cpp
bool IsSurfaceInteraction() const { return n != Normal3f(0, 0, 0); }
bool IsMediumInteraction() const { return !IsSurfaceInteraction(); }
```


#parec[
  Methods are provided to cast to the subclass types as well. This is a good place for a runtime check to ensure that the requested conversion is valid. The non-`const` variant of this method as well as corresponding `AsMedium()` methods follow similarly and are not included in the text.
][
  还提供了方法来转换为子类类型。这是一个很好的地方进行运行时检查以确保请求的转换有效。此方法的非 `const` 变体以及相应的 `AsMedium()` 方法类似地遵循，并未包含在文本中。
]

```cpp
const SurfaceInteraction &AsSurface() const {
    CHECK(IsSurfaceInteraction());
    return (const SurfaceInteraction &)*this;
}
```

#parec[
  Interactions can also represent either an interface between two types of participating media using an instance of the #link("../Volume_Scattering/Media.html#MediumInterface")[`MediumInterface`] class, which is defined in Section #link("../Volume_Scattering/Media.html#sec:media")[11.4];, or the properties of the scattering medium at their point using a #link("../Volume_Scattering/Media.html#Medium")[`Medium`];. Here as well, the `Interaction` abstraction leaks: surfaces can represent interfaces between media, and at a point inside a medium, there is no interface but there is the current medium. Both of these values are stored in `Interaction` for the same reasons of expediency that `n` and `uv` were.
][
  交互还可以使用 #link("../Volume_Scattering/Media.html#MediumInterface")[`MediumInterface`] 类的实例表示两种参与介质之间的接口，该类在 #link("../Volume_Scattering/Media.html#sec:media")[11.4] 节中定义，或使用 #link("../Volume_Scattering/Media.html#Medium")[`Medium`] 表示其点的散射介质的属性。在这里，`Interaction` 抽象也有泄漏：表面可以表示介质之间的接口，而在介质内部的点，没有接口但有当前介质。出于与 `n` 和 `uv` 相同的简便性原因，这两个值都存储在 `Interaction` 中。
]

```cpp
const MediumInterface *mediumInterface = nullptr;
Medium medium = nullptr;
};
```


=== Surface Interaction
<surface-interaction>
#parec[
  As described earlier, the geometry of a particular point on a surface (often a position found by intersecting a ray against the surface) is represented by a `SurfaceInteraction`. Having this abstraction lets most of the system work with points on surfaces without needing to consider the particular type of geometric shape the points lie on.
][
  如前所述，表面上某一点的几何（通常是通过射线与表面相交找到的位置）由 `SurfaceInteraction` 表示。这种抽象使得系统的大部分功能可以处理表面上的点，而无需考虑这些点所处的几何形状类型。
]

```cpp
class SurfaceInteraction : public Interaction {
  public:
    <<SurfaceInteraction Public Methods>>       SurfaceInteraction() = default;
       SurfaceInteraction(Point3fi pi, Point2f uv, Vector3f wo, Vector3f dpdu,
               Vector3f dpdv, Normal3f dndu, Normal3f dndv, Float time,
               bool flipNormal)
           : Interaction(pi, Normal3f(Normalize(Cross(dpdu, dpdv))), uv, wo, time),
             dpdu(dpdu), dpdv(dpdv), dndu(dndu), dndv(dndv) {
              <<Initialize shading geometry from true geometry>>              shading.n = n;
              shading.dpdu = dpdu;
              shading.dpdv = dpdv;
              shading.dndu = dndu;
              shading.dndv = dndv;
              <<Adjust normal based on orientation and handedness>>              if (flipNormal) {
                  n *= -1;
                  shading.n *= -1;
              }
       }
       SurfaceInteraction(Point3fi pi, Point2f uv, Vector3f wo,
               Vector3f dpdu, Vector3f dpdv, Normal3f dndu,
               Normal3f dndv, Float time, bool flipNormal,
               int faceIndex)
           : SurfaceInteraction(pi, uv, wo, dpdu, dpdv, dndu, dndv, time, flipNormal) {
             this->faceIndex = faceIndex;
       }
       void SetShadingGeometry(Normal3f ns, Vector3f dpdus, Vector3f dpdvs,
               Normal3f dndus, Normal3f dndvs, bool orientationIsAuthoritative) {
              <<Compute shading.n for SurfaceInteraction>>              shading.n = ns;
              if (orientationIsAuthoritative)
                  n = FaceForward(n, shading.n);
              else
                  shading.n = FaceForward(shading.n, n);
              <<Initialize shading partial derivative values>>              shading.dpdu = dpdus;
              shading.dpdv = dpdvs;
              shading.dndu = dndus;
              shading.dndv = dndvs;

       }
       std::string ToString() const;
       void SetIntersectionProperties(Material mtl, Light area,
               const MediumInterface *primMediumInterface, Medium rayMedium) {
           material = mtl;
           areaLight = area;
              <<Set medium properties at surface intersection>>              if (primMediumInterface && primMediumInterface->IsMediumTransition())
                  mediumInterface = primMediumInterface;
              else
                  medium = rayMedium;
       }
       PBRT_CPU_GPU
       void ComputeDifferentials(const RayDifferential &r, Camera camera,
                                 int samplesPerPixel);
       PBRT_CPU_GPU
       void SkipIntersection(RayDifferential *ray, Float t) const;
       using Interaction::SpawnRay;
       RayDifferential SpawnRay(const RayDifferential &rayi, const BSDF &bsdf,
                                Vector3f wi, int /*BxDFFlags*/ flags, Float eta) const;
       BSDF GetBSDF(const RayDifferential &ray,
                    SampledWavelengths &lambda, Camera camera,
                    ScratchBuffer &scratchBuffer, Sampler sampler);
       BSSRDF GetBSSRDF(const RayDifferential &ray,
                    SampledWavelengths &lambda, Camera camera,
                    ScratchBuffer &scratchBuffer);
       PBRT_CPU_GPU
       SampledSpectrum Le(Vector3f w, const SampledWavelengths &lambda) const;
    <<SurfaceInteraction Public Members>>       Vector3f dpdu, dpdv;
       Normal3f dndu, dndv;
       struct {
           Normal3f n;
           Vector3f dpdu, dpdv;
           Normal3f dndu, dndv;
       } shading;
       int faceIndex = 0;
       Material material;
       Light areaLight;
       Vector3f dpdx, dpdy;
       Float dudx = 0, dvdx = 0, dudy = 0, dvdy = 0;
};
```

#parec[
  In addition to the point `p`, the surface normal `n`, and $(u , v)$ coordinates from the parameterization of the surface from the `Interaction` base class, the `SurfaceInteraction` also stores the parametric partial derivatives of the point $partial p / partial u$ and $partial p / partial v$ and the partial derivatives of the surface normal $partial upright(bold(n)) / partial u$ and $partial upright(bold(n)) / partial v$. See Figure~#link("<fig:differential-geometry>")[3.30] for a depiction of these values.
][
  除了点 `p`、表面法线 `n` 和来自 `Interaction` 基类的 $(u , v)$ 坐标外，`SurfaceInteraction` 还存储了点的参数偏导数 () 和 () 以及表面法线的偏导数 () 和 ()。参见图 #link("<fig:differential-geometry>")[3.30] 以了解这些值的描述。
]

```cpp
Vector3f dpdu, dpdv;
Normal3f dndu, dndv;
```

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f31.svg"),
  caption: [

    #parec[The parametric partial derivatives of the surface, $partial p / partial u$ and $partial p / partial v$, lie in the tangent plane but are not necessarily orthogonal. The surface normal $upright(bold(n))$ is given by the cross product of $partial upright(bold(p)) / partial u$ and $partial upright(bold(p)) / partial v$. The vectors $partial upright(bold(n)) / partial u$ and $partial upright(bold(n)) / partial v$ record the differential change in surface normal as we move $u$ and $v$ along the surface.
    ][
      #emph[曲面的参数偏导数 $partial p / partial u$ 和 $partial p / partial v$ 位于切平面内，但不一定正交。曲面法向量 $upright(bold(n))$ 由 $partial upright(bold(p)) / partial u$ 和 $partial upright(bold(p)) / partial v$ 的叉积给出。向量 $partial upright(bold(n)) / partial u$ 和 $partial upright(bold(n)) / partial v$ 记录了当我们沿着曲面移动 $u$ 和 $v$ 时，法向量的微分变化。]
    ]
    #parec[
      Figure 3.30: The Local Differential Geometry around a Point (p).][
      图 3.30: 点 (p) 周围的局部微分几何。

    ]
  ],
)



#parec[
  This representation implicitly assumes that shapes have a parametric description—that for some range of ( $(u, v)$ ) values, points on the surface are given by some function ( $f$ ) such that ( $p = f(u, v)$ ). Although this is not true for all shapes, all of the shapes that `pbrt` supports do have at least a local parametric description, so we will stick with the parametric representation since this assumption is helpful elsewhere (e.g., for antialiasing of textures in @textures-and-materials ).
][
  这种表示法隐含地假设形状具有参数描述——对于某些 ( $(u, v)$ ) 值的范围，表面上的点由某个函数 ( $f$ ) 给出，使得 ( $p = f(u,
  v)$ )。虽然这对所有形状并不适用，但 `pbrt` 支持的所有形状至少都有局部的参数描述，因此我们将坚持使用参数表示，因为这种假设在其他地方是有帮助的（例如，在@textures-and-materials 中用于纹理的抗锯齿）。
]

#parec[
  The #link("<SurfaceInteraction>")[SurfaceInteraction] constructor takes parameters that set all of these values. It computes the normal as the cross product of the partial derivatives.
][
  #link("<SurfaceInteraction>")[SurfaceInteraction] 构造函数接受设置所有这些值的参数。它计算法线为偏导数的叉积。
]

```cpp
SurfaceInteraction(Point3fi pi, Point2f uv, Vector3f wo, Vector3f dpdu,
        Vector3f dpdv, Normal3f dndu, Normal3f dndv, Float time,
        bool flipNormal)
    : Interaction(pi, Normal3f(Normalize(Cross(dpdu, dpdv))), uv, wo, time),
      dpdu(dpdu), dpdv(dpdv), dndu(dndu), dndv(dndv) {
    <<Initialize shading geometry from true geometry>>       shading.n = n;
       shading.dpdu = dpdu;
       shading.dpdv = dpdv;
       shading.dndu = dndu;
       shading.dndv = dndv;
    <<Adjust normal based on orientation and handedness>>       if (flipNormal) {
           n *= -1;
           shading.n *= -1;
       }
}
```
#parec[
  `SurfaceInteraction` stores a second instance of a surface normal and the various partial derivatives to represent possibly perturbed values of these quantities—as can be generated by bump mapping or interpolated per-vertex normals with meshes. Some parts of the system use this shading geometry, while others need to work with the original quantities.
][
  `SurfaceInteraction` 存储了表面法线的第二个实例和各种偏导数，以表示这些量可能的扰动值——例如通过凸凹贴图或网格的插值顶点法线生成的。 系统的某些部分使用这种着色几何，而其他部分需要使用原始量。
]

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
  如果存在着色几何，通常是在 `SurfaceInteraction` 构造函数运行后的某个时间才进行计算。稍后将定义的 `SetShadingGeometry()` 方法更新着色几何。
]

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
  表面法线对 `pbrt` 有特殊意义，它假设对于封闭形状，法线的方向指向形状的外部。 对于用作面积光源的几何，默认情况下，光仅从法线指向的一侧发出；另一侧是黑色的。 由于法线具有这种特殊意义，`pbrt` 提供了一种机制，允许用户反转法线的方向，使其指向相反的方向。 在 `pbrt` 输入文件中的 `ReverseOrientation` 指令将法线翻转为指向相反的非默认方向。 因此，有必要检查给定的 `Shape` 是否设置了相应的标志，如果是，则在此处切换法线的方向。
]

#parec[
  However, one other factor plays into the orientation of the normal and must be accounted for here as well.
][
  然而，影响法线方向的另一个因素也必须在此考虑。
]

#parec[
  If a shape's transformation matrix has switched the handedness of the object coordinate system from `pbrt`'s default left-handed coordinate system to a right-handed one, we need to switch the orientation of the normal as well.
][
  如果形状的变换矩阵将对象坐标系的手性从 `pbrt` 的默认左手坐标系切换为右手坐标系，我们也需要切换法线的方向。
]

#parec[
  To see why this is so, consider a scale matrix $upright(bold(S))(1, 1, -1)$. We would naturally expect this scale to switch the direction of the normal, although because we have computed the normal by upright(bold(n)) = frac(diff p, diff u) times frac(diff p, diff v) ,
][
  要理解这一点，请考虑一个缩放矩阵 $upright(bold(S))(1, 1, -1)$。我们自然会期望这种缩放会切换法线的方向，尽管我们是通过upright(bold(n)) = frac(diff p, diff u) times frac(diff p, diff v) 计算法线的，
]


$
  bold("S") (1 , 1 , - 1) frac(partial p, partial u) dot.op bold("S") (
    1 , 1 , - 1
  ) frac(partial p, partial v) & = bold("S") (- 1 , - 1 , 1) (
    frac(partial p, partial u) dot.op frac(partial p, partial v)
  )\
  & = bold("S") (- 1 , - 1 , 1) n\
  & eq.not bold("S") (1 , 1 , - 1) n .
$


#parec[
  Therefore, it is also necessary to flip the normal's direction if the transformation switches the handedness of the coordinate system, since the flip will not be accounted for by the computation of the normal's direction using the cross product. A flag passed by the caller indicates whether this flip is necessary.
][
  因此，如果变换改变了坐标系的手性，也有必要翻转法线的方向，因为通过叉积计算法线方向时不会考虑翻转。调用者传递的一个标志指示是否需要这种翻转。
]

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

```cpp
int faceIndex = 0;
```

#parec[
  When a shading coordinate frame is computed, the `SurfaceInteraction` is updated via its `SetShadingGeometry()` method.
][
  当计算阴影坐标系时，通过其 `SetShadingGeometry()` 方法更新 `SurfaceInteraction`。
]

```cpp
void SetShadingGeometry(Normal3f ns, Vector3f dpdus, Vector3f dpdvs,
        Normal3f dndus, Normal3f dndvs, bool orientationIsAuthoritative) {
    // Compute shading.n for SurfaceInteraction
    shading.n = ns;
    if (orientationIsAuthoritative)
        n = FaceForward(n, shading.n);
    else
        shading.n = FaceForward(shading.n, n);
    // Initialize shading partial derivative values
    shading.dpdu = dpdus;
    shading.dpdv = dpdvs;
    shading.dndu = dndus;
    shading.dndv = dndvs;
}
```

#parec[
  After performing the same cross product (and possibly flipping the orientation of the normal) as before to compute an initial shading normal, the implementation then flips either the shading normal or the true geometric normal if needed so that the two normals lie in the same hemisphere. Since the shading normal generally represents a relatively small perturbation of the geometric normal, the two of them should always be in the same hemisphere. Depending on the context, either the geometric normal or the shading normal may more authoritatively point toward the correct "outside" of the surface, so the caller passes a Boolean value that determines which should be flipped if needed.
][
  在执行与之前相同的叉积（并可能翻转法线的方向）以计算初始阴影法线后，实施然后根据需要翻转阴影法线或真实几何法线，以便两个法线位于同一半球中。 因为阴影法线通常是几何法线的一个相对较小的扰动，所以它们应始终位于同一半球中。 根据上下文，几何法线或阴影法线可能更权威地指向表面的正确“外部”，因此调用者传递一个布尔值来确定如果需要翻转哪个。
]

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
  设置法线后，可以复制各种偏导数。
]

```cpp
shading.dpdu = dpdus;
shading.dpdv = dpdvs;
shading.dndu = dndus;
shading.dndv = dndvs;
```
=== Medium Interaction

#parec[
  As described earlier, the `MediumInteraction` class is used to represent an interaction at a point in a scattering medium like smoke or clouds.
][
  如前所述，`MediumInteraction` 类用于表示在烟雾或云等散射介质中的某一点的交互。
]

```cpp
class MediumInteraction : public Interaction {
  public:
    // MediumInteraction Public Methods
    MediumInteraction(Point3f p, Vector3f wo, Float time, Medium medium,
                         PhaseFunction phase)
           : Interaction(p, wo, time, medium), phase(phase) {}
       std::string ToString() const;
    // MediumInteraction Public Members
       PhaseFunction phase;
};
```


#parec[
  In contrast to `SurfaceInteraction`, it adds little to the base #link("<Interaction>")[Interaction] class. The only addition is a #link("../Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction];, which describes how the particles in the medium scatter light. Phase functions and the #link("../Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction] class are introduced in @phase-functions .
][
  与 `SurfaceInteraction` 相比，它对基础 #link("<Interaction>")[Interaction] 类的添加很少。 唯一的添加是一个 #link("../Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction];，它描述了介质中的粒子如何散射光。 相函数和 #link("../Volume_Scattering/Phase_Functions.html#PhaseFunction")[PhaseFunction] 类在@phase-functions 中介绍。
]

```cpp
MediumInteraction(Point3f p, Vector3f wo, Float time, Medium medium,
                  PhaseFunction phase)
    : Interaction(p, wo, time, medium), phase(phase) {}
```

```cpp
<<MediumInteraction Public Members>>=
PhaseFunction phase;
```