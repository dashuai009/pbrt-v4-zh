#import "../template.typ": parec, ez_caption

== Texture Coordinate Generation
<texture-coordinate-generation>
#parec[
  Almost all the textures in this chapter are functions that take a 2D or 3D coordinate and return a texture value. Sometimes there are obvious ways to choose these texture coordinates; for parametric surfaces, such as the quadrics in @Shapes, there is a natural 2D $(u , v)$ parameterization of the surface, and for all types of surfaces the shading point $p$ is a natural choice for a 3D coordinate.
][
  本章几乎所有的纹理都是接受二维或三维坐标并返回纹理值的函数。有时选择这些纹理坐标的方法很明显；对于参数化曲面，例如@Shapes 中的二次曲面，曲面有自然的二维 $(u , v)$ 参数化方式，对于所有类型的曲面，着色点 $p$ 是三维坐标的自然选择。
]

#parec[
  In other cases, there is no natural parameterization, or the natural parameterization may be undesirable. For instance, the $(u , v)$ values near the poles of spheres are severely distorted. Therefore, this section introduces classes that provide an interface to different techniques for generating these parameterizations as well as a number of implementations of them.
][
  在其他情况下，没有自然的参数化，或者自然的参数化可能不理想。例如，球体极点附近的 $(u , v)$ 值严重失真。因此，本节介绍了一些类，这些类提供了生成这些参数化的不同技术的接口以及它们的一些实现。
]

#parec[
  The `Texture` implementations later in this chapter store a tagged pointer to a 2D or 3D mapping function as appropriate and use it to compute the texture coordinates at each point at which they are evaluated. Thus, it is easy to add new mappings to the system without having to modify all the `Texture` implementations, and different mappings can be used for different textures associated with the same surface. In `pbrt`, we will use the convention that 2D texture coordinates are denoted by $(s , t)$ ; this helps make clear the distinction between the intrinsic $(u , v)$ parameterization of the underlying surface and the possibly different coordinate values used for texturing.
][
  本章后面的 `Texture` 实现存储了指向二维或三维映射函数的标记指针，并使用它来计算每个评估点的纹理坐标。因此，可以轻松地向系统添加新的映射，而无需修改所有的 `Texture` 实现，并且可以为与同一曲面关联的不同纹理使用不同的映射。在 `pbrt` 中，我们采用二维纹理坐标用 $(s , t)$ 表示的惯例；这有助于明确区分底层曲面的内在 $(u , v)$ 参数化和用于纹理的可能不同的坐标值。
]

#parec[
  #link("<TextureMapping2D>")[`TextureMapping2D`] defines the interface for 2D texture coordinate generation. It is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[base/texture.h];. The implementations of the texture mapping classes are in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.h")[textures.h] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.cpp")[textures.cpp] .
][
  #link("<TextureMapping2D>")[`TextureMapping2D`] 定义了二维纹理坐标生成的接口。它在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[base/texture.h] 中定义。纹理映射类的实现位于 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.h")[textures.h] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/textures.cpp")[textures.cpp] 中。
]

```cpp
class TextureMapping2D
    : public TaggedPointer<UVMapping, SphericalMapping,
                           CylindricalMapping, PlanarMapping> {
  public:
    using TaggedPointer::TaggedPointer;
       PBRT_CPU_GPU
       TextureMapping2D(TaggedPointer<UVMapping, SphericalMapping,
                                            CylindricalMapping, PlanarMapping>
                                  tp)
           : TaggedPointer(tp) {}

       static TextureMapping2D Create(const ParameterDictionary &parameters,
                                            const Transform &renderFromTexture,
                                            const FileLoc *loc, Allocator alloc);
       TexCoord2D Map(TextureEvalContext ctx) const;
};
```


#parec[
  The `TextureMapping2D` interface consists of a single method, `Map()`. It is given a #link("<TextureEvalContext>")[`TextureEvalContext`] that stores relevant geometric information at the shading point and returns a small structure, `TexCoord2D`, that stores the $(s , t)$ texture coordinates and estimates for the change in $(s , t)$ with respect to pixel $x$ and $y$ coordinates so that textures that use the mapping can determine the $(s , t)$ sampling rate and filter accordingly.
][
  `TextureMapping2D` 接口由一个方法 `Map()` 组成。它接受一个存储着色点相关几何信息的 #link("<TextureEvalContext>")[`TextureEvalContext`];，并返回一个小结构 `TexCoord2D`，该结构存储 $(s , t)$ 纹理坐标，并估计 $(s , t)$ 相对于像素 $x$ 和 $y$ 坐标的变化，以便使用该映射的纹理可以确定 $(s , t)$ 采样率并相应地进行过滤。
]

```cpp
TexCoord2D Map(TextureEvalContext ctx) const;
```


```cpp
struct TexCoord2D {
    Point2f st;
    Float dsdx, dsdy, dtdx, dtdy;
};
```


#parec[
  In previous versions of `pbrt`, the `Map()` interface was defined to take a complete #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];; the `TextureEvalContext` structure did not exist. In this version, we have tightened up the interface to only include specific values that are useful for texture coordinate generation. This change was largely motivated by the GPU rendering path: with the CPU renderer, all the relevant information is already at hand in the functions that call the `Map()` methods; most likely the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] is already in the CPU cache. On the GPU, the necessary values have to be read from off-chip memory. #link("<TextureEvalContext>")[`TextureEvalContext`] makes it possible for the GPU renderer to only read the necessary values from memory, which in turn has measurable performance benefits.
][
  在以前版本的 `pbrt` 中，`Map()` 接口被定义为接受一个完整的 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];；`TextureEvalContext` 结构不存在。在这个版本中，我们收紧了接口，只包含对纹理坐标生成有用的特定值。这一变化主要是为了适应 GPU 渲染路径的需求：对于 CPU 渲染器，所有相关信息已经在调用 `Map()` 方法的函数中；很可能 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 已经在 CPU 缓存中。在 GPU 上，必须从芯片外部内存读取必要的值。#link("<TextureEvalContext>")[`TextureEvalContext`] 使得 GPU 渲染器只需从内存中读取必要的值，从而带来了可测量的性能优势。
]

#parec[
  `TextureEvalContext` provides three constructors, not included here. Two initialize the various fields using corresponding values from either an #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] or a #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] and the third allows specifying them directly.
][
  `TextureEvalContext` 提供了三个构造函数，这里不包括。两个构造函数使用来自 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] 或 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 的相应值初始化各个字段，第三个允许直接指定它们。
]

```cpp
struct TextureEvalContext {
    TextureEvalContext() = default;
       PBRT_CPU_GPU
       TextureEvalContext(const Interaction &intr)
           : p(intr.p()), uv(intr.uv) {}
       PBRT_CPU_GPU
       TextureEvalContext(const SurfaceInteraction &si)
           : p(si.p()), dpdx(si.dpdx), dpdy(si.dpdy), n(si.n),
             uv(si.uv), dudx(si.dudx), dudy(si.dudy), dvdx(si.dvdx),
             dvdy(si.dvdy), faceIndex(si.faceIndex) {}
       PBRT_CPU_GPU
       TextureEvalContext(Point3f p, Vector3f dpdx, Vector3f dpdy, Normal3f n,
                          Point2f uv, Float dudx, Float dudy, Float dvdx,
                          Float dvdy, int faceIndex)
           : p(p), dpdx(dpdx), dpdy(dpdy), n(n), uv(uv), dudx(dudx), dudy(dudy),
             dvdx(dvdx), dvdy(dvdy), faceIndex(faceIndex) {}

       std::string ToString() const;
    Point3f p;
    Vector3f dpdx, dpdy;
    Normal3f n;
    Point2f uv;
    Float dudx = 0, dudy = 0, dvdx = 0, dvdy = 0;
};
```




=== $(u , v)$ Mapping
<u-v-mapping>


#parec[
  `UVMapping` uses the $(u , v)$ coordinates in the #link("<TextureEvalContext>")[`TextureEvalContext`] to compute the texture coordinates, optionally scaling and offsetting their values in each dimension.
][
  `UVMapping` 使用 #link("<TextureEvalContext>")[`TextureEvalContext`] 中的 $(u , v)$ 坐标来计算纹理坐标，可以选择性地对每个维度的值进行缩放和偏移。
]

```cpp
class UVMapping {
  public:
    <<UVMapping Public Methods>>       UVMapping(Float su = 1, Float sv = 1, Float du = 0, Float dv = 0)
           : su(su), sv(sv), du(du), dv(dv) {}
       std::string ToString() const;
       TexCoord2D Map(TextureEvalContext ctx) const {
           <<Compute texture differentials for 2D $(u, v)$ mapping>>              Float dsdx = su * ctx.dudx, dsdy = su * ctx.dudy;
              Float dtdx = sv * ctx.dvdx, dtdy = sv * ctx.dvdy;
           Point2f st(su * ctx.uv[0] + du, sv * ctx.uv[1] + dv);
           return TexCoord2D{st, dsdx, dsdy, dtdx, dtdy};
       }
  private:
    Float su, sv, du, dv;
};
```


#parec[
  The scale-and-shift computation to compute $(s , t)$ coordinates is straightforward:
][
  计算 $(s , t)$ 坐标的缩放和偏移过程是简单直接的：
]

```cpp
TexCoord2D Map(TextureEvalContext ctx) const {
    <<Compute texture differentials for 2D $(u, v)$ mapping>>       Float dsdx = su * ctx.dudx, dsdy = su * ctx.dudy;
       Float dtdx = sv * ctx.dvdx, dtdy = sv * ctx.dvdy;
    Point2f st(su * ctx.uv[0] + du, sv * ctx.uv[1] + dv);
    return TexCoord2D{st, dsdx, dsdy, dtdx, dtdy};
}
```


#parec[
  For a general 2D mapping function $f (u , v) arrow.r (s , t)$, the screen-space derivatives of $s$ and $t$ are given by the chain rule:
][
  对于一般的二维映射函数 $f (u , v) arrow.r (s , t)$， $s$ 和 $t$ 的屏幕空间导数可以通过链式法则计算得出：
]


$
  frac(partial (s , t), partial (x , y)) = mat(delim: "(", frac(partial s, partial (u , v)) dot.op frac(partial (u , v), partial x), frac(partial s, partial (u , v)) dot.op frac(partial (u , v), partial y); frac(partial t, partial (u , v)) dot.op frac(partial (u , v), partial x), frac(partial t, partial (u , v)) dot.op frac(partial (u , v), partial y)) = mat(delim: "(", frac(d s, d x), frac(d s, d y); frac(d t, d x), frac(d t, d y)) .
$

#parec[
  Note that the TextureEvalContext provides the values $frac(partial (u , v), partial (x , y))$.
][
  请注意，TextureEvalContext 提供了 $frac(partial (u , v), partial (x , y))$ 的值。
]

#parec[
  In this case, $f (u , v) = (s_u u + d_u , s_v v + d_v)$ and so
][
  在这种情况下， $f (u , v) = (s_u u + d_u , s_v v + d_v)$，因此
]

$
  frac(partial (s , t), partial (x , y)) = mat(delim: "(", (s_u , 0) dot.op frac(partial (u , v), partial x), (s_u , 0) dot.op frac(partial (u , v), partial y); med (0 , s_v) dot.op frac(partial (u , v), partial x), (0 , s_v) dot.op frac(partial (u , v), partial y)) = mat(delim: "(", s_u frac(d u, d x), s_u frac(d u, d y); med s_v frac(d v, d x), s_v frac(d v, d y)) .
$


#parec[
  We will skip past the straightforward fragment that implements Equation~(10.7) to initialize dsdx, dsdy, dtdx, and dtdy.
][
  我们将跳过实现方程~(10.7) 的简单片段来初始化 dsdx、dsdy、dtdx 和 dtdy。
]

=== Spherical Mapping

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f09.svg"),
  caption: [
    #ez_caption[Use of the SphericalMapping in the Kroken Scene. (a) Visualization of the resulting $(u,v)$ parameterization. (b) Effect of using the SphericalMapping to apply a texture. Note that although the shape is spherical, it is modeled with a triangle mesh, to which the SphericalMapping is applied. (Scene courtesy of Angelo Ferretti.)][在 Kroken 场景中使用 `SphericalMapping`。（a）结果 $(u, v)$ 参数化的可视化。（b）使用 `SphericalMapping` 应用纹理的效果。请注意，尽管形状是球形的，但它是用三角网格建模的，并应用了 `SphericalMapping`。（场景由 Angelo Ferretti 提供。）]
  ],
)
#parec[
  Another useful mapping effectively wraps a sphere around the object. Each point is projected along the vector from the sphere's center through the point on to the sphere's surface. Since this mapping is based on spherical coordinates, Equation~(3.8) can be applied, with the angles it returns remapped to $[0 , 1]$.
][
  另一种有用的映射有效地将一个球体包裹在对象周围。每个点沿着从球心通过该点到球面上的向量投影。由于此映射基于球面坐标，方程~(3.8) 可以应用，返回的角度重新映射到 $[0 , 1]$。
]

$
  f (upright(p)) = (frac(1, 2 pi) (pi + arctan (p_y / p_x)) , 1 / pi arccos (p_z / norm(p_x^2 + p_y^2 + p_z^2))) .
$


#parec[
  Figure~10.9 shows the use of this mapping with an object in the Kroken scene.
][
  图~10.9 显示了在 Kroken 场景中使用此映射的对象。
]

#parec[
  The SphericalMapping further stores a transformation that is applied to points before this mapping is performed; this effectively allows the mapping sphere to be arbitrarily positioned and oriented with respect to the object.
][
  SphericalMapping 还存储了一个在执行此映射之前应用于点的变换；这有效地允许映射球相对于对象任意定位和定向。
]

```cpp
<<SphericalMapping Definition>>=
class SphericalMapping {
  public:
    <<SphericalMapping Public Methods>>
  private:
    <<SphericalMapping Private Members>>
};
<<SphericalMapping Private Members>>=
Transform textureFromRender;
```

#parec[
  The Map() function starts by computing the texture-space point pt.
][
  函数`Map()`从计算纹理空间中的点`pt`开始：
]

```
<<SphericalMapping Public Methods>>=
TexCoord2D Map(TextureEvalContext ctx) const {
    Point3f pt = textureFromRender(ctx.p);
    <<Compute  and  for spherical mapping>>
    <<Compute texture coordinate differentials for spherical mapping>>
    <<Return  texture coordinates and differentials based on spherical mapping>>
}
```

#parec[
  For a mapping function based on a 3D point $upright(p)$, the generalization of Equation (10.6) is
][
  For a mapping function based on a 3D point $upright(p)$, the generalization of Equation (10.6) is
]

$
  frac(diff(s comma t), diff(x comma y)) = mat(delim: #none, frac(diff s, diff p) dot.op frac(diff p, diff x), frac(diff s, diff p) dot.op frac(diff p, diff y); frac(diff t, diff p) dot.op frac(diff p, diff x), frac(diff t, diff p) dot.op frac(diff p, diff y)) = mat(delim: #none, frac(d s, d x), frac(d s, d y); frac(d t, d x), frac(d t, d y)) .
$

#parec[
  Taking the partial derivatives of the mapping function, Equation (10.8), we can find
][
  通过对映射函数方程 (10.8) 求偏导数，我们可以得到
]

$
  frac(diff s, diff p) &= frac(1, 2 pi(x^2 + y^2)) thin(-y, x, 0)\
  frac(diff t, diff p) &= frac(1, pi(x^2 + y^2 + z^2))( frac(x z, sqrt(x^2 + y^2)), frac(y z, sqrt(x^2 + y^2)), - sqrt(x^2 + y^2) ) .
$

#parec[
  These quantities are computed using the texture-space position pt.
][
  这些量是通过使用纹理空间位置 `pt` 计算的。
]

```cpp
<<Compute  and  for spherical mapping>>=
Float x2y2 = Sqr(pt.x) + Sqr(pt.y);
Float sqrtx2y2 = std::sqrt(x2y2);
Vector3f dsdp = Vector3f(-pt.y, pt.x, 0) / (2 * Pi * x2y2);
Vector3f dtdp = 1 / (Pi * (x2y2 + Sqr(pt.z))) *
    Vector3f(pt.x * pt.z / sqrtx2y2, pt.y * pt.z / sqrtx2y2, -sqrtx2y2);
```


#parec[
  The final differentials are then found using the four dot products from Equation (10.9).
][
  最终的微分通过方程 (10.9) 的四个点积计算得出。
]

```
<<Compute texture coordinate differentials for spherical mapping>>=
Vector3f dpdx = textureFromRender(ctx.dpdx);
Vector3f dpdy = textureFromRender(ctx.dpdy);
Float dsdx = Dot(dsdp, dpdx), dsdy = Dot(dsdp, dpdy);
Float dtdx = Dot(dtdp, dpdx), dtdy = Dot(dtdp, dpdy);
```
#parec[
  Finally, previously defined spherical geometry utility functions compute the mapping of Equation (10.8).
][
  Finally, previously defined spherical geometry utility functions compute the mapping of Equation (10.8).
]

```
<<Return  texture coordinates and differentials based on spherical mapping>>=
Vector3f vec = Normalize(pt - Point3f(0,0,0));
Point2f st(SphericalTheta(vec) * InvPi, SphericalPhi(vec) * Inv2Pi);
return TexCoord2D{st, dsdx, dsdy, dtdx, dtdy};
```
=== Cylindrical Mapping
<cylindrical-mapping>


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f10.svg"),
  caption: [
    #parec[
      Use of the Cylindrical Texture Mapping. (a) Visualization of the
      $(u,v)$ mapping from the CylindricalMapping. (b) Kettle with texture maps applied. (c) Scratch texture that is applied using the cylindrical texture mapping. (Scene courtesy of Angelo Ferretti.)
    ][
      Use of the Cylindrical Texture Mapping. (a) Visualization of the
      $(u,v)$ mapping from the CylindricalMapping. (b) Kettle with texture maps applied. (c) Scratch texture that is applied using the cylindrical texture mapping. (Scene courtesy of Angelo Ferretti.)
    ]

  ],
)

#parec[
  The cylindrical mapping effectively wraps a cylinder around the object and then uses the cylinder's parameterization.
][
  The cylindrical mapping effectively wraps a cylinder around the object and then uses the cylinder's parameterization.
]

$ f (p) = (frac(1, 2 pi) (pi + tan^(- 1) (p_y / p_x)) , p_z) . $

#parec[
  Note that the $t$ texture coordinate it returns is not necessarily between 0 and 1; the mapping should either be scaled in $z$ so that the object being textured has $t in [0 , 1]$ or the texture being used should return results for coordinates outside that range that match the desired result.
][
  注意，返回的 $t$ 纹理坐标可能不在 0 和 1 之间；映射应在 $z$ 上进行缩放，以便被纹理化的对象具有 $t in [0 , 1]$，或者所使用的纹理应返回该范围之外的坐标的结果，以匹配所需的结果。
]

```cpp
class CylindricalMapping {
  public:
    <<CylindricalMapping Public Methods>>       CylindricalMapping(const Transform &textureFromRender)
           : textureFromRender(textureFromRender) {}
       std::string ToString() const;
       TexCoord2D Map(TextureEvalContext ctx) const {
           Point3f pt = textureFromRender(ctx.p);
           <<Compute texture coordinate differentials for cylinder $(u,v)$ mapping>>              Float x2y2 = Sqr(pt.x) + Sqr(pt.y);
              Vector3f dsdp = Vector3f(-pt.y, pt.x, 0) / (2 * Pi * x2y2), dtdp = Vector3f(0, 0, 1);
              Vector3f dpdx = textureFromRender(ctx.dpdx), dpdy = textureFromRender(ctx.dpdy);
              Float dsdx = Dot(dsdp, dpdx), dsdy = Dot(dsdp, dpdy);
              Float dtdx = Dot(dtdp, dpdx), dtdy = Dot(dtdp, dpdy);
           Point2f st((Pi + std::atan2(pt.y, pt.x)) * Inv2Pi, pt.z);
           return TexCoord2D{st, dsdx, dsdy, dtdx, dtdy};
       }
  private:
    <<CylindricalMapping Private Members>>       Transform textureFromRender;
};
```


#parec[
  Because the $s$ texture coordinate is computed in the same way as it is with the spherical mapping, the cylindrical mapping's $frac(partial s, partial p)$ matches the sphere's in Equation (10.10). The partial derivative in $t$ can easily be seen to be $frac(partial t, partial p) = (0 , 0 , 1)$. Since the cylindrical mapping function and derivative computation are only slight variations on the spherical mapping's, we will not include the implementation of its `Map()` function here.
][
  由于 $s$ 纹理坐标的计算方式与球面映射相同，因此圆柱映射的 $frac(partial s, partial p)$ 与方程 (10.10) 中的球面映射相匹配。可以很容易看出 $t$ 的偏导数为 $frac(partial t, partial p) = (0 , 0 , 1)$。 由于圆柱映射函数和导数计算只是球面映射的轻微变化，我们将在此不包括其 `Map()` 函数的实现。
]

=== Planar Mapping
#parec[
  Another classic mapping method is planar mapping. The point is effectively projected onto a plane; a 2D parameterization of the plane then gives texture coordinates for the point. For example, a point $p$ might be projected onto the $z = 0$ plane to yield texture coordinates given by $s = p_x$ and $t = p_y$ .
][
  另一种经典的映射方法是平面映射。点被有效地投影到一个平面上；平面的二维参数化然后为该点提供纹理坐标。例如，一个点 $p$ 可以被投影到 $z = 0$ 平面上，以得到纹理坐标 $s = p_x$ 和 $t = p_y$。
]

#parec[
  One way to define such a parameterized plane is with two nonparallel vectors $upright(bold(n))_s$ and $upright(bold(n))_t$ and offsets $d_s$ and $d_t$. The texture coordinates are given by the coordinates of the point with respect to the plane's coordinate system, which are computed by taking the dot product of the vector from the point to the origin with each vector $upright(bold(n))_s$ and $upright(bold(n))_t$ and then adding the corresponding offset:
][
  定义这样一个参数化平面的一种方法是使用两个不平行的向量 $upright(bold(n))_s$ 和 $upright(bold(n))_t$ 以及偏移 $d_s$ 和 $d_t$。纹理坐标由点相对于平面坐标系的坐标给出，这些坐标通过将从点到原点的向量与每个向量 $upright(bold(n))_s$ 和 $upright(bold(n))_t$ 的点积计算出来，然后加上相应的偏移：
]

$
  f (p) = ((p - (0 , 0 , 0)) dot.op upright(bold(v))_s + d_s , (p - (0 , 0 , 0)) dot.op upright(bold(v))_t + d_t)
$


```cpp
<<PlanarMapping Definition>>=
class PlanarMapping {
  public:
    <<PlanarMapping Public Methods>>
  private:
    <<PlanarMapping Private Members>>
};
```

#parec[
  A straightforward constructor, not included here, initializes the following member variables.
][
  这里未列出的一个简单构造函数用于初始化以下成员变量。
]

```cpp
<<PlanarMapping Private Members>>=
Transform textureFromRender;
Vector3f vs, vt;
Float ds, dt;


<<PlanarMapping Public Methods>>=
TexCoord2D Map(TextureEvalContext ctx) const {
    Vector3f vec(textureFromRender(ctx.p));
    <<Initialize partial derivatives of planar mapping  coordinates>>
    Point2f st(ds + Dot(vec, vs), dt + Dot(vec, vt));
    return TexCoord2D{st, dsdx, dsdy, dtdx, dtdy};
}
```

#parec[
  The planar mapping differentials can be computed directly using the partial derivatives of the mapping function, which are easily found. For example, the partial derivative of the $s$ texture coordinate with respect to screen-space $x$ is just $partial s \/ partial x = (upright(bold(v)) _ s dot partial upright(p) \/ partial x)$
][
  平面映射的微分可以直接通过映射函数的偏导数计算出来，这些偏导数很容易找到。例如，纹理坐标 $s$ 对屏幕空间 $x$ 的偏导数是 $partial s \/ partial x = (upright(bold(v)) _ s dot partial upright(p) \/ partial x)$
]

```cpp
Vector3f dpdx = textureFromRender(ctx.dpdx);
Vector3f dpdy = textureFromRender(ctx.dpdy);
Float dsdx = Dot(vs, dpdx), dsdy = Dot(vs, dpdy);
Float dtdx = Dot(vt, dpdx), dtdy = Dot(vt, dpdy);
```

=== 3D Mapping

#parec[
  We will also define a `TextureMapping3D` class that defines the interface for generating 3D texture coordinates.
][
  我们还将定义一个 `TextureMapping3D` 类，该类定义了生成三维纹理坐标的接口。
]


```cpp
class TextureMapping3D : public TaggedPointer<PointTransformMapping> {
  public:
    using TaggedPointer::TaggedPointer;
    PBRT_CPU_GPU
    TextureMapping3D(TaggedPointer<PointTransformMapping> tp) : TaggedPointer(tp) {}

    static TextureMapping3D Create(const ParameterDictionary &parameters,
                                    const Transform &renderFromTexture,
                                    const FileLoc *loc, Allocator alloc);
    TexCoord3D Map(TextureEvalContext ctx) const;
};
```

#parec[
  The `Map()` method it specifies returns a 3D point and partial derivative vectors in the form of a `TexCoord3D` structure.
][

]

```cpp
TexCoord3D Map(TextureEvalContext ctx) const;
```

#parec[
  `TexCoord3D` parallels `TexCoord2D` , storing both the point and its screen-space derivatives.
][
  它指定的 `Map()` 方法返回一个三维点和形式为 `TexCoord2D` 结构的偏导向量。
]

```cpp
struct TexCoord3D {
    Point3f p;
    Vector3f dpdx, dpdy;
};
```

#parec[
  The natural 3D mapping takes the rendering-space coordinate of the point and applies a linear transformation to it. This will often be a transformation that takes the point back to the primitive's object space. Such a mapping is implemented by the `PointTransformMapping` class.
][
  自然的三维映射获取点的渲染空间坐标并对其应用线性变换。这通常是将点转换回原始对象空间的变换。这样的映射由 `PointTransformMapping` 类实现。
]
```cpp
class PointTransformMapping {
  public:
    PointTransformMapping(const Transform &textureFromRender)
           : textureFromRender(textureFromRender) {}

    std::string ToString() const;
    TexCoord3D Map(TextureEvalContext ctx) const {
        return TexCoord3D{textureFromRender(ctx.p), textureFromRender(ctx.dpdx),
                          textureFromRender(ctx.dpdy)};
    }
  private:
    Transform textureFromRender;
};
```

#parec[
  Because it applies a linear transformation, the differential change in texture coordinates can be found by applying the same transformation to the partial derivatives of position.
][
  因为它应用了线性变换，纹理坐标的微分变化可以通过对位置的偏导数应用相同的变换来找到。
]

```cpp
TexCoord3D Map(TextureEvalContext ctx) const {
    return TexCoord3D{textureFromRender(ctx.p), textureFromRender(ctx.dpdx),
                      textureFromRender(ctx.dpdy)};
}
```
