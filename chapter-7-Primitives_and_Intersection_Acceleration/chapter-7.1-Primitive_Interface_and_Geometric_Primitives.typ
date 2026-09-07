#import "../template.typ": parec, ez_caption

== #ez_caption[Primitive Interface and Geometric Primitives][图元接口与几何图元]
<primitive-interface-and-geometric-primitives>
#parec[
  The #link(<Primitive>)[`Primitive`] class defines the `Primitive` interface. It and the `Primitive` implementations that are described in this section are defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.h")[`cpu/primitive.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.cpp")[`cpu/primitive.cpp`].
][
  `Primitive` 类定义图元接口。它与本节介绍的各项实现定义在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.h")[`cpu/primitive.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.cpp")[`cpu/primitive.cpp`] 中。
]

#block(sticky: true)[#raw("<<Primitive Definition>>=")] <fragment-PrimitiveDefinition-0>
#block(breakable: false)[
```cpp
class Primitive
    : public TaggedPointer<SimplePrimitive, GeometricPrimitive,
                           TransformedPrimitive, AnimatedPrimitive,
                           BVHAggregate, KdTreeAggregate> {
  public:
    <<Primitive Interface>>
};
```
] <Primitive>

#parec[
  The `Primitive` interface is composed of only three methods, each of which corresponds to a #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] method. The first, `Bounds()`, returns a bounding box that encloses the primitive's geometry in rendering space. There are many uses for such a bound; one of the most important is to place the #link(<Primitive>)[`Primitive`] in the acceleration data structures.
][
  `Primitive` 接口只有三个方法，分别对应 `Shape` 的方法。第一个是 `Bounds()`，它返回在渲染空间中包围图元几何形状的包围盒。这种包围范围有多种用途，其中一个重要用途是将图元组织到加速结构中。
]

#block(sticky: true)[#raw("<<Primitive Interface>>=")] <fragment-PrimitiveInterface-0>
#block(breakable: false)[
```cpp
Bounds3f Bounds() const;
```
]


#parec[
  The other two methods provide the two types of ray intersection tests.
][
  另外两个方法提供两种射线求交测试。
]

#block(sticky: true)[#raw("<<Primitive Interface>>+=")] <fragment-PrimitiveInterface-1>
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection> Intersect(const Ray &r,
                                            Float tMax = Infinity) const;
bool IntersectP(const Ray &r, Float tMax = Infinity) const;
```
]

#parec[
  Upon finding an intersection, a `Primitive`'s `Intersect()` method is also responsible for initializing a few member variables in the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] in the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] that it returns. The first two are representations of the shape's material and its emissive properties, if it is itself an emitter. For convenience, #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] provides a method to set these, which reduces the risk of inadvertently not setting all of them.
][
  找到交点后，`Primitive::Intersect()` 还要初始化所返回的 `ShapeIntersection` 中的 `SurfaceInteraction` 的若干成员。前两个分别表示形状的材质，以及形状本身作为发光体时的发光属性。为方便使用，`SurfaceInteraction` 提供统一设置它们的方法，降低遗漏某项属性的风险。
]

#parec[
  The second two are related to medium scattering properties and the fragment that initializes them will be described later, in Section #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#sec:media")[11.4].
][
  另外两个与介质散射属性有关，初始化它们的片段将在 #link("https://pbr-book.org/4ed/Volume_Scattering/Media.html#sec:media")[11.4 节]介绍。
]

#block(sticky: true)[#raw("<<SurfaceInteraction Public Methods>>+=")] <fragment-SurfaceInteractionPublicMethods-2>
#block(breakable: false)[
```cpp
void SetIntersectionProperties(Material mtl, Light area,
        const MediumInterface *primMediumInterface, Medium rayMedium) {
    material = mtl;
    areaLight = area;
    <<Set medium properties at surface intersection>>
}
```
]


#block(sticky: true)[#raw("<<SurfaceInteraction Public Members>>+=")] <fragment-SurfaceInteractionPublicMembers-3>
#block(breakable: false)[
```cpp
Material material;
Light areaLight;
```
]



=== #ez_caption[Geometric Primitives][几何图元]
<geometric-primitives>
#parec[
  The #link(<GeometricPrimitive>)[`GeometricPrimitive`] class provides a basic implementation of the `Primitive` interface that stores a variety of properties that may be associated with a shape.
][
  `GeometricPrimitive` 提供 `Primitive` 接口的基本实现，保存可与形状关联的各种属性。
]

#block(sticky: true)[#raw("<<GeometricPrimitive Definition>>=")] <fragment-GeometricPrimitiveDefinition-0>
#block(breakable: false)[
```cpp
class GeometricPrimitive {
  public:
    <<GeometricPrimitive Public Methods>>
  private:
    <<GeometricPrimitive Private Members>>
};
```
] <GeometricPrimitive>


#parec[
  Each #link(<GeometricPrimitive>)[`GeometricPrimitive`] holds a #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] with a description of its appearance properties, including its material, its emissive properties if it is a light source, the participating media on each side of its surface, and an optional #emph[alpha texture], which can be used to make some parts of a shape's surface disappear.
][
  每个 `GeometricPrimitive` 都保存一个 `Shape` 及其外观属性：材质、作为光源时的发光属性、表面两侧的参与介质，以及可选的 #emph[alpha 纹理]。alpha 纹理可使形状表面的某些部分消失。
]

#block(sticky: true)[#raw("<<GeometricPrimitive Private Members>>=")] <fragment-GeometricPrimitivePrivateMembers-0>
#block(breakable: false)[
```cpp
Shape shape;
Material material;
Light areaLight;
MediumInterface mediumInterface;
FloatTexture alpha;
```
]


#parec[
  The `GeometricPrimitive` constructor initializes these variables from the parameters passed to it. It is straightforward, so we do not include it here.
][
  `GeometricPrimitive` 的构造函数用传入参数初始化这些变量。实现很直接，因此这里不列出。
]

#parec[
  Most of the methods of the #link(<Primitive>)[`Primitive`] interface start out with a call to the corresponding `Shape` method. For example, its `Bounds()` method directly returns the bounds from the `Shape`.
][
  `Primitive` 接口的大多数方法先调用相应的 `Shape` 方法。例如，`Bounds()` 直接返回 `Shape` 的包围范围。
]

#block(sticky: true)[#raw("<<GeometricPrimitive Method Definitions>>=")] <fragment-GeometricPrimitiveMethodDefinitions-0>
#block(breakable: false)[
```cpp
Bounds3f GeometricPrimitive::Bounds() const {
    return shape.Bounds();
}
```
]

#parec[
  #link(<GeometricPrimitive::Intersect>)[`GeometricPrimitive::Intersect()`] calls the `Intersect()` method of its #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] to do the actual intersection test and to initialize a #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] to describe the intersection, if any. If an intersection is found, then additional processing specific to the `GeometricPrimitive` is performed.
][
  `GeometricPrimitive::Intersect()` 调用其 `Shape` 的 `Intersect()` 进行实际求交。若存在交点，就初始化 `ShapeIntersection` 来描述它，再执行 `GeometricPrimitive` 特有的后续处理。
]

#block(sticky: true)[#raw("<<GeometricPrimitive Method Definitions>>+=")] <fragment-GeometricPrimitiveMethodDefinitions-1>
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection>
GeometricPrimitive::Intersect(const Ray &r, Float tMax) const {
    pstd::optional<ShapeIntersection> si = shape.Intersect(r, tMax);
    if (!si) return {};
    <<Test intersection against alpha texture, if present>>
    <<Initialize SurfaceInteraction after Shape intersection>>
    return si;
}
```
] <GeometricPrimitive::Intersect>

#parec[
  If an alpha texture is associated with the shape, then the intersection point is tested against the alpha texture before a successful intersection is reported. (The definition of the texture interface and a number of implementations are in Chapter 10.) The alpha texture can be thought of as a scalar function over the shape's surface that indicates whether the surface is actually present at each point. An alpha value of 0 indicates that it is not, and 1 that it is. Alpha textures are useful for representing objects like leaves: a leaf might be modeled as a single triangle or bilinear patch, with an alpha texture cutting out the edges so that a detailed outline of a leaf remains.
][
  若形状关联了 alpha 纹理，就要先在交点处测试该纹理，再报告有效交点。（纹理接口及若干实现见第 10 章。）可以将 alpha 纹理视为定义在形状表面上的标量函数，表示各处的表面是否实际存在：alpha 为 0 表示不存在，为 1 表示存在。它适合表示叶片等对象：只用一个三角形或双线性面片表示叶片，再用 alpha 纹理裁去边缘，就能保留精细的叶片轮廓。
]

#block(sticky: true)[#raw("<<Test intersection against alpha texture, if present>>=")] <fragment-Testintersectionagainstalphatextureifpresent-0>
#block(breakable: false)[
```cpp
if (alpha) {
    if (Float a = alpha.Evaluate(si->intr); a < 1) {
        <<Possibly ignore intersection based on stochastic alpha test>>
   }
}
```
]



#parec[
  If the alpha texture has a value of 0 or 1 at the intersection point, then it is easy to decide whether or not the intersection reported by the shape is valid. For intermediate alpha values, the correct answer is less clear.
][
  若交点处的 alpha 为 0 或 1，就容易判断形状报告的交点是否有效；对于介于两者之间的值，应如何处理则不那么明确。
]

#parec[
  One possibility would be to use a fixed threshold—for example, accepting all intersections with an alpha of 1 and ignoring them otherwise. However, this approach leads to hard transitions at the resulting boundary. Another option would be to return the alpha from the intersection method and leave calling code to handle it, effectively treating the surface as partially transparent at such points. However, that approach would not only make the `Primitive` intersection interfaces more complex, but it would place a new burden on integrators, requiring them to compute the shading at such intersection points as well as to trace an additional ray to find what was visible behind them.
][
  一种方法是采用固定阈值，例如只接受 alpha 为 1 的交点，忽略其余交点，但这会使边界出现生硬的过渡。另一种方法是由求交方法返回 alpha，交给调用方处理，相当于将这些位置的表面视为部分透明。然而，这不仅使 `Primitive` 求交接口更复杂，还会增加积分器的负担：既要在交点处计算着色，又要额外追踪一条射线，确定后方可见的内容。
]

#parec[
  A #emph[stochastic alpha test] addresses these issues. With it, intersections with the shape are randomly reported with probability proportional to the value of the alpha texture. This approach is easy to implement, gives the expected results for an alpha of 0 or 1, and with a sufficient number of samples gives a better result than using a fixed threshold. @fig:fixed-vs-stochastic-alpha compares the approaches.
][
  #emph[随机 alpha 测试]可以解决这些问题：以与 alpha 纹理值成比例的概率随机报告交点。它容易实现，在 alpha 为 0 或 1 时给出预期结果，样本足够多时也比固定阈值效果更好。@fig:fixed-vs-stochastic-alpha 比较了两种方法。
]

#figure(image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f01.svg"), caption: [#ez_caption[Comparison of Stochastic Alpha Testing to Using a Fixed Threshold. (a) Example scene: the two fir branches are modeled using a single quadrilateral with an alpha texture. (b) If a fixed threshold is used for the alpha test, the shape is not faithfully reproduced. Here a threshold of 1 was used, leading to shrinkage and jagged edges. (c) If a stochastic alpha test is used, the result is a smoother and more realistic transition.][随机 alpha 测试与固定阈值的比较。（a）示例场景：两根冷杉枝用一个带 alpha 纹理的四边形建模。（b）固定阈值无法忠实再现形状。这里阈值为 1，导致轮廓收缩、边缘呈锯齿状。（c）随机 alpha 测试得到更平滑、更真实的过渡。]]) <fixed-vs-stochastic-alpha>

#parec[
  One challenge in performing the stochastic alpha test is generating a uniform random number to apply it. For a given ray and shape, we would like this number to be the same across multiple runs of the system; doing so is a part of making the set of computations performed by `pbrt` be deterministic, which is a great help for debugging. If a different random number was used on different runs of the system, then we might hit a runtime error on some runs but not others. However, it is important that different random numbers be used for different rays; otherwise, the approach could devolve into the same as using a fixed threshold.
][
  随机 alpha 测试的一个难点是如何生成均匀随机数。对于给定的射线和形状，希望多次运行时使用相同的数值，从而保证 `pbrt` 计算的确定性，便于调试。否则，某些运行可能触发运行时错误，而另一些却不会。不过，不同射线应使用不同的随机数，否则这种方法可能退化成固定阈值测试。
]

#parec[
  The #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#HashFloat")[`HashFloat()`] utility function provides a solution to this problem. Here it is used to compute a random floating-point value between 0 and 1 for the alpha test; this value is determined by the ray's origin and direction.
][
  #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#HashFloat")[`HashFloat()`] 工具函数解决了这一问题。这里根据射线原点和方向，生成 0 与 1 之间的随机浮点数供 alpha 测试使用。
]

#block(sticky: true)[#raw("<<Possibly ignore intersection based on stochastic alpha test>>=")] <fragment-Possiblyignoreintersectionbasedonstochasticalphatest-0>
#block(breakable: false)[
```cpp
Float u = (a <= 0) ? 1.f : HashFloat(r.o, r.d);
if (u > a) {
    <<Ignore this intersection and trace a new ray>>
}
```
]

#parec[
  If the alpha test indicates that the intersection should be ignored, then another intersection test is performed with the current `GeometricPrimitive`, with a recursive call to `Intersect()`. This additional test is important for shapes like spheres, where we may reject the closest intersection but then intersect the shape again further along the ray. This recursive call requires adjustment of the `tMax` value passed to it to account for the distance along the ray to the initial alpha tested intersection point. Then, if it reports an intersection, the reported `tHit` value should account for that segment as well.
][
  若 alpha 测试要求忽略交点，就递归调用当前 `GeometricPrimitive` 的 `Intersect()`，继续对同一图元求交。对球面等形状，这一步很重要：最近的交点被拒绝后，射线仍可能在更远处再次穿过形状。递归调用需从 `tMax` 中扣除到最初进行 alpha 测试的交点的射线参数距离；若递归返回交点，也要在返回的 `tHit` 中加回这一段。
]

#block(sticky: true)[#raw("<<Ignore this intersection and trace a new ray>>=")] <fragment-Ignorethisintersectionandtraceanewray-0>
#block(breakable: false)[
```cpp
Ray rNext = si->intr.SpawnRay(r.d);
pstd::optional<ShapeIntersection> siNext = Intersect(rNext, tMax - si->tHit);
if (siNext)
    siNext->tHit += si->tHit;
return siNext;
```
]


#parec[
  Given a valid intersection, the `GeometricPrimitive` can go ahead and finalize the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`]'s representation of the intersection.
][
  交点确定有效后，`GeometricPrimitive` 就可以补全 `SurfaceInteraction` 中的交点信息。
]

#block(sticky: true)[#raw("<<Initialize SurfaceInteraction after Shape intersection>>=")] <fragment-InitializemonoSurfaceInteractionaftermonoShapeintersection-0>
#block(breakable: false)[
```cpp
si->intr.SetIntersectionProperties(material, areaLight, &mediumInterface,
                                   r.medium);
```
]


#parec[
  The `IntersectP()` method must also handle the case of the `GeometricPrimitive` having an alpha texture associated with it. In that case, it may be necessary to consider all the intersections of the ray with the shape in order to determine if there is a valid intersection. Because `IntersectP()` implementations in shapes return early when they find any intersection and because they do not return the geometric information associated with an intersection, a full intersection test is performed in this case. In the more common case of no alpha texture, #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape::IntersectP")[`Shape::IntersectP`] can be called directly.
][
  `IntersectP()` 也必须处理图元带有 alpha 纹理的情况。此时，可能要考察射线与形状的全部交点，才能确定是否存在有效交点。形状的 `IntersectP()` 找到任意交点就返回，而且不提供交点的几何信息，因此这里必须执行完整求交。更常见的情况是没有 alpha 纹理，此时可直接调用 `Shape::IntersectP()`。
]

#block(sticky: true)[#raw("<<GeometricPrimitive Method Definitions>>+=")] <fragment-GeometricPrimitiveMethodDefinitions-2>
#block(breakable: false)[
```cpp
bool GeometricPrimitive::IntersectP(const Ray &r, Float tMax) const {
    if (alpha)
        return Intersect(r, tMax).has_value();
    else
        return shape.IntersectP(r, tMax);
}
```
]


#parec[
  Most objects in a scene are neither emissive nor have alpha textures. Further, only a few of them typically represent the boundary between two different types of participating media. It is wasteful to store `nullptr` values for the corresponding member variables of #link(<GeometricPrimitive>)[`GeometricPrimitive`] in that common case. Therefore, `pbrt` also provides `SimplePrimitive`, which also implements the `Primitive` interface but does not store those values. The code that converts the parsed scene representation into the scene for rendering uses a `SimplePrimitive` in place of a `GeometricPrimitive` when it is possible to do so.
][
  场景中的大多数对象既不发光，也没有 alpha 纹理；通常也只有少数对象位于不同参与介质的分界面上。在这种常见情形下，为 `GeometricPrimitive` 的相应成员存储 `nullptr` 很浪费。因此，`pbrt` 还提供 `SimplePrimitive`：它实现相同的 `Primitive` 接口，却不存储这些值。将解析后的场景转换为渲染所用场景的代码，会在条件允许时用 `SimplePrimitive` 代替 `GeometricPrimitive`。
]

#block(sticky: true)[#raw("<<SimplePrimitive Definition>>=")] <fragment-SimplePrimitiveDefinition-0>
#block(breakable: false)[
```cpp
class SimplePrimitive {
  public:
    <<SimplePrimitive Public Methods>>
  private:
    <<SimplePrimitive Private Members>>
};
```
] <SimplePrimitive>


#parec[
  Because `SimplePrimitive` only stores a shape and a material, it saves 32 bytes of memory. For scenes with millions of primitives, the overall savings can be meaningful.
][
  `SimplePrimitive` 只保存形状与材质，因而节省 32 字节内存。在拥有数百万个图元的场景中，这种节省可能相当可观。
]

#block(sticky: true)[#raw("<<SimplePrimitive Private Members>>=")] <fragment-SimplePrimitivePrivateMembers-0>
#block(breakable: false)[
```cpp
Shape shape;
Material material;
```
]

#parec[
  We will not include the remainder of the #link(<SimplePrimitive>)[`SimplePrimitive`] implementation here; it is effectively a simplified subset of #link(<GeometricPrimitive>)[`GeometricPrimitive`]'s.
][
  这里不再列出 `SimplePrimitive` 的其余实现；它基本上就是 `GeometricPrimitive` 的简化子集。
]

=== #ez_caption[Object Instancing and Primitives in Motion][对象实例化与运动图元]
<object-instancing-and-primitives-in-Motion>
#figure(image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/landscape-above.png"), caption: [#ez_caption[This outdoor scene makes heavy use of instancing as a mechanism for compressing the scene’s description. There are only 24 million unique triangles in the scene, although, thanks to object reuse through instancing, the total geometric complexity is 3.1 billion triangles. (Scene courtesy of Laubwerk.)][这个室外场景大量使用实例化来压缩场景描述。场景只有 2400 万个不同的三角形，通过实例化复用对象后，总几何复杂度却达到 31 亿个三角形。（场景由 Laubwerk 提供。）]]) <ecosys-instancing>


#parec[
  Object instancing is a classic technique in rendering that reuses transformed copies of a single collection of geometry at multiple positions in a scene.
][
  对象实例化是一种经典的渲染技术：在场景中的多个位置复用同一组几何体，每份实例施加各自的变换。
]

#parec[
  For example, in a model of a concert hall with thousands of identical seats, the scene description can be compressed substantially if all the seats refer to a shared geometric representation of a single seat.
][
  例如，音乐厅模型有数千个相同的座位时，让所有座位共享同一个座位的几何表示，可以大幅压缩场景描述。
]

#parec[
  The ecosystem scene in @fig:ecosys-instancing has 23,241 individual plants of various types, although only 31 unique plant models.
][
  @fig:ecosys-instancing 的生态系统场景有各种植物共 23,241 株，却只有 31 个不同的植物模型。
]

#parec[
  Because each plant model is instanced multiple times with a different transformation for each instance, the complete scene has a total of 3.1 billion triangles.
][
  每个植物模型都以不同变换多次实例化，因此完整场景共有 31 亿个三角形。
]

#parec[
  However, only 24 million triangles are stored in memory thanks to primitive reuse through object instancing.
][
  利用对象实例化复用图元后，内存中实际只需保存 2400 万个三角形。
]

#parec[
  `pbrt` uses just over 4 GB of memory when rendering this scene with object instancing (1.7 GB for BVHs, 707 MB for `Primitive`s, 877 MB for triangle meshes, and 846 MB for texture images), but would need upward of 516 GB to render it without instancing.#footnote[The previous version of `pbrt` used 7 GB of memory when rendering this scene, with most of that difference due to less memory-efficient `Primitive` representations, virtual function pointers stored with each `Shape` and each `Primitive`, and the use of 32-bit floats for image texture pixels even for textures that were originally stored with 8-bit values.]
][
  使用对象实例化渲染该场景时，`pbrt` 仅需略多于 4 GB 内存：BVH 占 1.7 GB，图元占 707 MB，三角网格占 877 MB，纹理图像占 846 MB；不使用实例化则需要超过 516 GB。#footnote[上一版 `pbrt` 渲染该场景需 7 GB 内存。增加的开销主要来自较低效的 `Primitive` 表示、每个 `Shape` 和 `Primitive` 中存储的虚函数指针，以及即使源纹理为 8 位格式，也使用 32 位浮点数存储图像纹理像素。]
]

#parec[
  The TransformedPrimitive implementation of the `Primitive` interface makes object instancing possible in `pbrt`.
][
  `Primitive` 接口的 `TransformedPrimitive` 实现让 `pbrt` 能够进行对象实例化。
]

#parec[
  Rather than holding a shape, it stores a single Primitive as well as a Transform that is injected in between the underlying primitive and its representation in the scene.
][
  它保存一个 `Primitive` 和一个 `Transform`，而不直接保存形状；该变换施加在底层图元与它在场景中的表示之间。
]

#parec[
  This extra transformation enables object instancing.
][
  这一额外的变换使对象实例化成为可能。
]

#parec[
  Recall that the Shapes of Chapter 6 themselves had rendering from object space transformations applied to them to place them in the scene.
][
  回顾第 6 章，`Shape` 已应用从对象空间到渲染空间的变换，将自身放置到场景中。
]

#parec[
  If a shape is held by a TransformedPrimitive, then the shape's notion of rendering space is not the actual scene rendering space—only after the TransformedPrimitive's transformation is also applied is the shape actually in rendering space.
][
  如果形状由 `TransformedPrimitive` 持有，那么它所理解的“渲染空间”并不是真正的场景渲染空间；还需施加 `TransformedPrimitive` 的额外变换，才能到达实际的渲染空间。
]

#parec[
  For this application here, it makes sense for the shape to not be at all aware of the additional transformation being applied.
][
  在这一应用中，形状本身不必感知额外变换。
]

#parec[
  For instanced primitives, letting Shapes know all the instance transforms is of limited utility: we would not want the TriangleMesh to make a copy of its vertex positions for each instance transformation and transform them all the way to rendering space, since this would negate the memory savings of object instancing.
][
  让实例化的形状知道每份实例的变换并无多大用处。我们不希望 `TriangleMesh` 为每个实例复制顶点位置，并将所有副本变换到实际渲染空间，因为那会抵消对象实例化带来的内存节省。
]

#block(sticky: true)[#raw("<<TransformedPrimitive Definition>>=")] <fragment-TransformedPrimitiveDefinition-0>
#block(breakable: false)[
```cpp
class TransformedPrimitive {
  public:
    <<TransformedPrimitive Public Methods>>
  private:
    <<TransformedPrimitive Private Members>>
};
```
] <TransformedPrimitive>



#parec[
The TransformedPrimitive constructor takes a Primitive that represents the model and the transformation that places it in the scene. If the instanced geometry is described by multiple Primitives, the calling code is responsible for placing them in an aggregate so that only a single Primitive needs to be stored here.
][
`TransformedPrimitive` 的构造函数接受表示模型的 `Primitive`，以及将模型放置到场景中的变换。如果实例化的几何体包含多个图元，调用方需先将它们装入聚合体，使这里只需保存一个 `Primitive`。
]

#block(sticky: true)[#raw("<<TransformedPrimitive Public Methods>>=")] <fragment-TransformedPrimitivePublicMethods-0>
#block(breakable: false)[
```cpp
TransformedPrimitive(Primitive primitive,
                     const Transform *renderFromPrimitive)
    : primitive(primitive), renderFromPrimitive(renderFromPrimitive) { }
```
]

#block(sticky: true)[#raw("<<TransformedPrimitive Private Members>>=")] <fragment-TransformedPrimitivePrivateMembers-0>
#block(breakable: false)[
```cpp
Primitive primitive;
const Transform *renderFromPrimitive;
```
]

#parec[
The key task of TransformedPrimitive is to bridge between the Primitive interface that it implements and the Primitive that it holds, accounting for the effects of the rendering from primitive space transformation. If the primitive member has its own transformation, that should be interpreted as the transformation from object space to the TransformedPrimitive’s coordinate system. The complete transformation to rendering space requires both of these transformations together.
][
`TransformedPrimitive` 的主要任务是在自身实现的 `Primitive` 接口与所持有的图元之间衔接调用，并计入从图元空间到渲染空间的变换。如果 `primitive` 成员本身也有变换，应将它理解为从对象空间到 `TransformedPrimitive` 坐标系的变换。二者复合，才得到通往真正渲染空间的完整变换。
]

#block(sticky: true)[#raw("<<TransformedPrimitive Public Methods>>+=")] <fragment-TransformedPrimitivePublicMethods-1>
#block(breakable: false)[
```cpp
Bounds3f Bounds() const {
    return (*renderFromPrimitive)(primitive.Bounds());
}
```
]

#parec[
The Intersect() method also must account for the transformation, both for the ray passed to the held primitive and for any intersection information it returns.
][
`Intersect()` 同样需要处理该变换：既要变换传给底层图元的射线，也要变换它返回的交点信息。
]

#block(sticky: true)[#raw("<<TransformedPrimitive Method Definitions>>=")] <fragment-TransformedPrimitiveMethodDefinitions-0>
#block(breakable: false)[
```cpp
pstd::optional<ShapeIntersection>
TransformedPrimitive::Intersect(const Ray &r, Float tMax) const {
    <<Transform ray to primitive-space and intersect with primitive>>
    <<Return transformed instance’s intersection information>>
}
```
]

#parec[
The method first transforms the given ray to the primitive’s coordinate system and passes the transformed ray to its Intersect() routine.
][
该方法先将给定射线变换到图元坐标系，再传给图元的 `Intersect()`。
]

#block(sticky: true)[#raw("<<Transform ray to primitive-space and intersect with primitive>>=")] <fragment-Transformraytoprimitive-spaceandintersectwithprimitive-0>
#block(breakable: false)[
```cpp
Ray ray = renderFromPrimitive->ApplyInverse(r, &tMax);
pstd::optional<ShapeIntersection> si = primitive.Intersect(ray, tMax);
if (!si) return {};
```
]

#parec[
Given an intersection, the SurfaceInteraction needs to be transformed to rendering space; the primitive’s intersection method will already have transformed the SurfaceInteraction to its notion of rendering space, so here we only need to apply the effect of the additional transformation held by TransformedPrimitive. Note that any returned ShapeIntersection::tHit value from the primitive can be returned to the caller as is; recall the discussion of intersection coordinate spaces and ray $t$ values in #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#sec:isect-coordinate-spaces")[Section 6.1.4].
][
找到交点后，需将 `SurfaceInteraction` 变换到渲染空间。图元的求交方法已将其变换到该图元所理解的渲染空间，因此这里只需施加 `TransformedPrimitive` 保存的额外变换。图元返回的 `ShapeIntersection::tHit` 可原样传给调用方；参见 #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#sec:isect-coordinate-spaces")[6.1.4 节]关于求交坐标空间与射线参数 $t$ 的讨论。
]

#block(sticky: true)[#raw("<<Return transformed instance’s intersection information>>=")] <fragment-Returntransformedinstancesintersectioninformation-0>
#block(breakable: false)[
```cpp
si->intr = (*renderFromPrimitive)(si->intr);
return si;
```
]

#parec[
The IntersectP() method is similar and is therefore elided.
][
`IntersectP()` 的实现相似，因此省略。
]

#parec[
The AnimatedPrimitive class uses an AnimatedTransform in place of the Transform stored by TransformedPrimitives. It thus enables rigid-body animation of primitives in the scene. See Figure fig:spinning-spheres for an image that exhibits motion blur due to animated transformations.
][
`AnimatedPrimitive` 使用 `AnimatedTransform`，替代 `TransformedPrimitive` 中的 `Transform`，从而支持场景图元的刚体动画。原文指向图“fig:spinning-spheres”，用来展示动画变换造成的运动模糊。
]

#block(sticky: true)[#raw("<<AnimatedPrimitive Definition>>=")] <fragment-AnimatedPrimitiveDefinition-0>
#block(breakable: false)[
```cpp
class AnimatedPrimitive {
  public:
    <<AnimatedPrimitive Public Methods>>
  private:
    <<AnimatedPrimitive Private Members>>
};
```
] <AnimatedPrimitive>

#parec[
The AnimatedTransform class uses substantially more memory than Transform. On the system used to develop pbrt, the former uses 696 bytes of memory, while the latter uses 128. Thus, just as was the case with GeometricPrimitive and SimplePrimitive, it is worthwhile to only use AnimatedPrimitive for shapes that actually are animated. Making this distinction is the task of the code that constructs the scene specification used for rendering.
][
`AnimatedTransform` 的内存开销远大于 `Transform`。在开发 `pbrt` 所用的系统上，前者占 696 字节，后者占 128 字节。因此，与区分 `GeometricPrimitive` 和 `SimplePrimitive` 类似，只为确实带动画的形状使用 `AnimatedPrimitive` 是值得的。构建渲染用场景表示的代码负责做出这一区分。
]

#block(sticky: true)[#raw("<<AnimatedPrimitive Private Members>>=")] <fragment-AnimatedPrimitivePrivateMembers-0>
#block(breakable: false)[
```cpp
Primitive primitive;
AnimatedTransform renderFromPrimitive;
```
]

#parec[
A bounding box of the primitive over the frame’s time range is found via the AnimatedTransform::MotionBounds() method.
][
`AnimatedTransform::MotionBounds()` 给出覆盖一帧时间范围内图元运动的包围盒。
]

#block(sticky: true)[#raw("<<AnimatedPrimitive Public Methods>>=")] <fragment-AnimatedPrimitivePublicMethods-0>
#block(breakable: false)[
```cpp
Bounds3f Bounds() const {
    return renderFromPrimitive.MotionBounds(primitive.Bounds());
}
```
]

#parec[
We will also skip past the rest of the implementations of the AnimatedPrimitive intersection methods; they parallel those of TransformedPrimitive, just using an AnimatedTransform.
][
这里也省略 `AnimatedPrimitive` 其余求交方法的实现：它们与 `TransformedPrimitive` 对应，只是改用 `AnimatedTransform`。
]

#parec[Editorial note: the fixed source prints the unresolved reference “Figure fig:spinning-spheres” in the AnimatedPrimitive paragraph. No corresponding figure is provided on that page; the original reference is preserved without inventing a local figure number.][校订说明：固定原文在 `AnimatedPrimitive` 段直接显示未解析的引用“Figure fig:spinning-spheres”，该页没有对应图像。此处保留原引用，不虚构本地图号。]

#include "supplements/7.1-expanded.typ"
