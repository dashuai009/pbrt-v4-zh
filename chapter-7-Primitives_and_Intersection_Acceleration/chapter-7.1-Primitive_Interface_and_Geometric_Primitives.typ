#import "../template.typ": parec

== Primitive Interface and Geometric Primitives
<primitive-interface-and-geometric-primitives>
#parec[
  The #link("<Primitive>")[`Primitive`] class defines the `Primitive` interface. It and the `Primitive` implementations that are described in this section are defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.h")[`cpu/primitive.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.cpp")[`cpu/primitive.cpp`];.
][
  #link("<Primitive>")[`Primitive`] 类定义了 `Primitive` 接口。它和本节中描述的 `Primitive` 实现定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.h")[`cpu/primitive.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cpu/primitive.cpp")[`cpu/primitive.cpp`] 中。
]

```cpp
class Primitive
    : public TaggedPointer<SimplePrimitive, GeometricPrimitive,
                           TransformedPrimitive, AnimatedPrimitive,
                           BVHAggregate, KdTreeAggregate> {
  public:
    // <<Primitive Interface>>
    using TaggedPointer::TaggedPointer;
    Bounds3f Bounds() const;
    pstd::optional<ShapeIntersection> Intersect(const Ray &r,
                                                Float tMax = Infinity) const;
    bool IntersectP(const Ray &r, Float tMax = Infinity) const;
};
```

#parec[
  The `Primitive` interface is composed of only three methods, each of which corresponds to a #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] method. The first, `Bounds()`, returns a bounding box that encloses the primitive's geometry in rendering space. There are many uses for such a bound; one of the most important is to place the #link("<Primitive>")[`Primitive`] in the acceleration data structures.
][
  `Primitive` 接口仅由三个方法组成，每个方法都对应一个 #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 方法。第一个方法 `Bounds()` 返回一个包围盒，该包围盒在渲染空间中包围原始体的几何形状。这样的边界有很多用途，其中一个最重要的用途是将 #link("<Primitive>")[`Primitive`] 放置在加速数据结构中。
]

```cpp
Bounds3f Bounds() const;
```


#parec[
  The other two methods provide the two types of ray intersection tests.
][
  另外两个方法提供两种光线相交测试。
]

```cpp
pstd::optional<ShapeIntersection> Intersect(const Ray &r,
                                            Float tMax = Infinity) const;
bool IntersectP(const Ray &r, Float tMax = Infinity) const;
```

#parec[
  Upon finding an intersection, a `Primitive`'s `Intersect()` method is also responsible for initializing a few member variables in the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] in the #link("../Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] that it returns. The first two are representations of the shape's material and its emissive properties, if it is itself an emitter. For convenience, #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] provides a method to set these, which reduces the risk of inadvertently not setting all of them.
][
  在找到相交点后，`Primitive` 的 `Intersect()` 方法还负责初始化它返回的 #link("../Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] 中的一些成员变量。首先要有表示形状的材料和发光（如果它本身是一个发光源）的两个属性。为了方便，#link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 提供了一个方法来设置这些属性，以减少遗漏设置的风险。
]

#parec[
  The second two are related to medium scattering properties and the fragment that initializes them will be described later, in Section #link("../Volume_Scattering/Media.html#sec:media")[11.4];.
][
  后两个与介质散射属性相关，初始化它们的片段将在 #link("../Volume_Scattering/Media.html#sec:media")[11.4] 节中描述。
]

```cpp
//<<SurfaceInteraction Public Methods>>
void SetIntersectionProperties(Material mtl, Light area,
        const MediumInterface *primMediumInterface, Medium rayMedium) {
    material = mtl;
    areaLight = area;
    // <<Set medium properties at surface intersection>>
    if (primMediumInterface && primMediumInterface->IsMediumTransition())
           mediumInterface = primMediumInterface;
       else
           medium = rayMedium;
}
```


```cpp
// <<SurfaceInteraction Public Members>>+=
Material material;
Light areaLight;
```



=== Geometric Primitives
<geometric-primitives>
#parec[
  The #link("<GeometricPrimitive>")[`GeometricPrimitive`] class provides a basic implementation of the `Primitive` interface that stores a variety of properties that may be associated with a shape.
][
  #link("<GeometricPrimitive>")[`GeometricPrimitive`] 类提供了 `Primitive` 接口的基本实现，该接口存储了可能与形状相关联的各种属性。
]

```cpp
class GeometricPrimitive {
  public:
    // GeometricPrimitive Public Methods
    GeometricPrimitive(Shape shape, Material material, Light areaLight,
                      const MediumInterface &mediumInterface,
                      FloatTexture alpha = nullptr);
    Bounds3f Bounds() const;
    pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
    bool IntersectP(const Ray &r, Float tMax) const;
  private:
    // GeometricPrimitive Private Members
    Shape shape;
    Material material;
    Light areaLight;
    MediumInterface mediumInterface;
    FloatTexture alpha;
};
```


#parec[
  Each #link("<GeometricPrimitive>")[`GeometricPrimitive`] holds a #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] with a description of its appearance properties, including its material, its emissive properties if it is a light source, the participating media on each side of its surface, and an optional #emph[alpha texture];, which can be used to make some parts of a shape's surface disappear.
][
  每个 #link("<GeometricPrimitive>")[`GeometricPrimitive`] 持有一个 #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];，描述其外观属性，包括其材质、如果是光源则有其发光属性、其表面两侧的参与介质，以及一个可选的 #emph[alpha 透明纹理];，可用于使形状表面的一部分消失。
]

```cpp
Shape shape;
Material material;
Light areaLight;
MediumInterface mediumInterface;
FloatTexture alpha;
```


#parec[
  The `GeometricPrimitive` constructor initializes these variables from the parameters passed to it. It is straightforward, so we do not include it here.
][
  `GeometricPrimitive` 构造函数从传递给它的参数初始化这些变量。由于其实现简单，因此未在此处展示。
]

#parec[
  Most of the methods of the #link("<Primitive>")[`Primitive`] interface start out with a call to the corresponding `Shape` method. For example, its `Bounds()` method directly returns the bounds from the `Shape`.
][
  #link("<Primitive>")[`Primitive`] 接口的大多数方法以调用相应的 `Shape` 方法开始。例如，其 `Bounds()` 方法直接返回来自 `Shape` 的边界。
]

```cpp
Bounds3f GeometricPrimitive::Bounds() const {
    return shape.Bounds();
}
```

#parec[
  #link("<GeometricPrimitive::Intersect>")[`GeometricPrimitive::Intersect()`] calls the `Intersect()` method of its #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] to do the actual intersection test and to initialize a #link("../Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] to describe the intersection, if any. If an intersection is found, then additional processing specific to the `GeometricPrimitive` is performed.
][
  #link("<GeometricPrimitive::Intersect>")[`GeometricPrimitive::Intersect()`] 调用其 #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 的 `Intersect()` 方法进行实际的相交测试，并初始化一个 #link("../Shapes/Basic_Shape_Interface.html#ShapeIntersection")[`ShapeIntersection`] 来描述相交情况（如果有）。如果找到相交点，则执行特定于 `GeometricPrimitive` 的附加处理。
]

```cpp
pstd::optional<ShapeIntersection>
GeometricPrimitive::Intersect(const Ray &r, Float tMax) const {
    pstd::optional<ShapeIntersection> si = shape.Intersect(r, tMax);
    if (!si) return {};
    // Test intersection against alpha texture, if present
    if (alpha) {
        if (Float a = alpha.Evaluate(si->intr); a < 1) {
            // Possibly ignore intersection based on stochastic alpha test
            Float u = (a <= 0) ? 1.f : HashFloat(r.o, r.d);
            if (u > a) {
                // Ignore this intersection and trace a new ray
                Ray rNext = si->intr.SpawnRay(r.d);
                pstd::optional<ShapeIntersection> siNext = Intersect(rNext, tMax - si->tHit);
                if (siNext)
                    siNext->tHit += si->tHit;
                return siNext;
            }
        }
    }
    // Initialize SurfaceInteraction after Shape intersection
    si->intr.SetIntersectionProperties(material, areaLight, &mediumInterface,
                                        r.medium);
    return si;
}
```

#parec[
  If an alpha texture is associated with the shape, then the intersection point is tested against the alpha texture before a successful intersection is reported. (The definition of the texture interface and a number of implementations are in Chapter 10.) The alpha texture can be thought of as a scalar function over the shape's surface that indicates whether the surface is actually present at each point. An alpha value of 0 indicates that it is not, and 1 that it is. Alpha textures are useful for representing objects like leaves: a leaf might be modeled as a single triangle or bilinear patch, with an alpha texture cutting out the edges so that a detailed outline of a leaf remains.
][
  如果形状关联了 alpha 透明纹理，则在报告成功相交之前，测试相交点与 alpha 透明纹理。（纹理接口的定义和多个实现见第 10 章。）alpha 透明纹理可以被视为形状表面上的一个标量函数，指示表面在每个点是否实际存在。alpha 值为 0 表示不存在，为 1 表示存在。alpha 透明纹理对于表示像叶子这样的对象很有用：叶子可以被建模为一个单一的三角形或双线性补丁，alpha 透明纹理切割出边缘，以便保留叶子的详细轮廓。
]

```cpp
if (alpha) {
    if (Float a = alpha.Evaluate(si->intr); a < 1) {
        // Possibly ignore intersection based on stochastic alpha test
        Float u = (a <= 0) ? 1.f : HashFloat(r.o, r.d);
        if (u > a) {
            // Ignore this intersection and trace a new ray
            Ray rNext = si->intr.SpawnRay(r.d);
            pstd::optional<ShapeIntersection> siNext = Intersect(rNext, tMax - si->tHit);
            if (siNext)
                siNext->tHit += si->tHit;
            return siNext;
        }
    }
}
```



#parec[
  If the alpha texture has a value of 0 or 1 at the intersection point, then it is easy to decide whether or not the intersection reported by the shape is valid. For intermediate alpha values, the correct answer is less clear.
][
  如果 alpha 透明纹理在相交点处的值为 0 或 1，则很容易决定形状报告的相交是否有效。对于中间的 alpha 值，判断其有效性较为复杂。
]

#parec[
  One possibility would be to use a fixed threshold—for example, accepting all intersections with an alpha of 1 and ignoring them otherwise. However, this approach leads to hard transitions at the resulting boundary. Another option would be to return the alpha from the intersection method and leave calling code to handle it, effectively treating the surface as partially transparent at such points. However, that approach would not only make the `Primitive` intersection interfaces more complex, but it would place a new burden on integrators, requiring them to compute the shading at such intersection points as well as to trace an additional ray to find what was visible behind them.
][
  一种可能性是使用固定阈值——例如，接受所有 alpha 为 1 的相交，否则忽略它们。然而，这种方法会导致结果边界处的硬过渡。另一种选择是从相交方法返回 alpha，并让调用代码处理它，实际上将表面视为在这些点上部分透明。然而，这种方法不仅会使 `Primitive` 相交接口更加复杂，还会给积分器带来新的负担，要求它们在这些相交点计算阴影，并追踪额外的光线以找到它们后面的可见物。
]

#parec[
  A #emph[stochastic alpha test] addresses these issues. With it, intersections with the shape are randomly reported with probability proportional to the value of the alpha texture. This approach is easy to implement, gives the expected results for an alpha of 0 or 1, and with a sufficient number of samples gives a better result than using a fixed threshold. Figure 7.1 compares the approaches.
][
  #emph[随机 alpha 测试] 解决了这些问题。通过它，与形状的相交以与 alpha 透明纹理值成比例的概率随机报告。该方法实现简单，且在 alpha 为 0 或 1 时能给出预期结果，并且在足够多的样本下比使用固定阈值产生更好的结果。图 7.1 比较了这些方法。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f01.svg"),
    caption: [
      Figure 7.1: Comparison of Stochastic Alpha Testing to Using a Fixed
      Threshold. (a) Example scene: the two fir branches are modeled using
      a single quadrilateral with an alpha texture. (b) If a fixed
      threshold is used for the alpha test, the shape is not faithfully
      reproduced. Here a threshold of 1 was used, leading to shrinkage and
      jagged edges. (c) If a stochastic alpha test is used, the result is
      a smoother and more realistic transition.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Primitives_and_Intersection_Acceleration/pha07f01.svg"),
    caption: [
      图 7.1：随机 Alpha 测试与使用固定阈值的比较。(a)
      示例场景：两个冷杉树枝使用单个四边形和 alpha 透明纹理建模。(b)
      如果对 alpha 测试使用固定阈值，则形状无法忠实再现。这里使用了阈值
      1，导致收缩和锯齿边缘。(c) 如果使用随机 alpha
      测试，结果是更平滑和更逼真的过渡。
    ],
  )
]

#parec[
  One challenge in performing the stochastic alpha test is generating a uniform random number to apply it. For a given ray and shape, we would like this number to be the same across multiple runs of the system; doing so is a part of making the set of computations performed by `pbrt` be deterministic, which is a great help for debugging. If a different random number was used on different runs of the system, then we might hit a runtime error on some runs but not others. However, it is important that different random numbers be used for different rays; otherwise, the approach could devolve into the same as using a fixed threshold.
][
  执行随机 alpha 测试的一个挑战是生成一个均匀的随机数来应用它。对于给定的光线和形状，我们希望这个数字在系统的多次运行中保持相同；这样做是 `pbrt` 使执行的计算集确定性的一个部分，这对于调试非常有帮助。如果在系统的不同运行中使用了不同的随机数，那么我们可能会在某些运行中遇到运行时错误，而在其他运行中则不会。然而，重要的是为不同的光线使用不同的随机数；否则，这种方法可能会退化为使用固定阈值。
]

#parec[
  The #link("../Utilities/Mathematical_Infrastructure.html#HashFloat")[`HashFloat()`] utility function provides a solution to this problem. Here it is used to compute a random floating-point value between 0 and 1 for the alpha test; this value is determined by the ray's origin and direction.
][
  #link("../Utilities/Mathematical_Infrastructure.html#HashFloat")[`HashFloat()`] 实用函数提供了这个问题的解决方案。这里它用于为 alpha 测试计算一个介于 0 和 1 之间的随机浮点值；这个值由光线的起点和方向决定。
]

```cpp
Float u = (a <= 0) ? 1.f : HashFloat(r.o, r.d);
if (u > a) {
    // Ignore this intersection and trace a new ray
    Ray rNext = si->intr.SpawnRay(r.d);
    pstd::optional<ShapeIntersection> siNext = Intersect(rNext, tMax - si->tHit);
    if (siNext)
        siNext->tHit += si->tHit;
    return siNext;
}
```

#parec[
  If the alpha test indicates that the intersection should be ignored, then another intersection test is performed with the current `GeometricPrimitive`, with a recursive call to `Intersect()`. This additional test is important for shapes like spheres, where we may reject the closest intersection but then intersect the shape again further along the ray. This recursive call requires adjustment of the `tMax` value passed to it to account for the distance along the ray to the initial alpha tested intersection point. Then, if it reports an intersection, the reported `tHit` value should account for that segment as well.
][
  如果 alpha 测试表明应该忽略相交，则使用当前 `GeometricPrimitive` 执行另一个相交测试，递归调用 `Intersect()`。对于像球体这样的形状，这个附加测试很重要，因为我们可能会拒绝最近的相交，但随后在光线进一步的地方再次与形状相交。这个递归调用需要调整传递给它的 `tMax` 值，以考虑沿光线到初始 alpha 测试相交点的距离。然后，如果它报告了一个相交，报告的 `tHit` 值也应该考虑到该段。
]

```cpp
Ray rNext = si->intr.SpawnRay(r.d);
pstd::optional<ShapeIntersection> siNext = Intersect(rNext, tMax - si->tHit);
if (siNext)
    siNext->tHit += si->tHit;
return siNext;
```


#parec[
  Given a valid intersection, the `GeometricPrimitive` can go ahead and finalize the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];'s representation of the intersection.
][
  给定一个有效的相交，`GeometricPrimitive` 可以继续并完成 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 对相交的表示。
]

```cpp
si->intr.SetIntersectionProperties(material, areaLight, &mediumInterface,
                                   r.medium);
```


#parec[
  The `IntersectP()` method must also handle the case of the `GeometricPrimitive` having an alpha texture associated with it. In that case, it may be necessary to consider all the intersections of the ray with the shape in order to determine if there is a valid intersection. Because `IntersectP()` implementations in shapes return early when they find any intersection and because they do not return the geometric information associated with an intersection, a full intersection test is performed in this case. In the more common case of no alpha texture, #link("../Shapes/Basic_Shape_Interface.html#Shape::IntersectP")[`Shape::IntersectP`] can be called directly.
][
  `IntersectP()` 方法也必须处理 `GeometricPrimitive` 关联了 alpha 透明纹理的情况。在这种情况下，可能需要考虑光线与形状的所有相交，以确定是否存在有效的相交。因为形状中的 `IntersectP()` 实现会在找到任何相交时提前返回，并且因为它们不返回与相交相关的几何信息，所以在这种情况下执行完整的相交测试。在更常见的无 alpha 透明纹理情况下，可直接调用 #link("../Shapes/Basic_Shape_Interface.html#Shape::IntersectP")[`Shape::IntersectP`];。
]

```cpp
bool GeometricPrimitive::IntersectP(const Ray &r, Float tMax) const {
    if (alpha)
        return Intersect(r, tMax).has_value();
    else
        return shape.IntersectP(r, tMax);
}
```


#parec[
  Most objects in a scene are neither emissive nor have alpha textures. Further, only a few of them typically represent the boundary between two different types of participating media. It is wasteful to store `nullptr` values for the corresponding member variables of #link("<GeometricPrimitive>")[`GeometricPrimitive`] in that common case. Therefore, `pbrt` also provides `SimplePrimitive`, which also implements the `Primitive` interface but does not store those values.
][
  场景中的大多数对象既不发光也没有 alpha 透明纹理。此外，只有少数对象通常代表两种不同类型的参与介质之间的边界。在这种常见情况下，为 #link("<GeometricPrimitive>")[`GeometricPrimitive`] 的相应成员变量存储 `nullptr` 值是浪费的。因此，`pbrt` 还提供了 `SimplePrimitive`，它也实现了 `Primitive` 接口，但不存储这些值。
]

```cpp
class SimplePrimitive {
  public:
    // SimplePrimitive Public Methods
    Bounds3f Bounds() const;
    pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
    bool IntersectP(const Ray &r, Float tMax) const;
    SimplePrimitive(Shape shape, Material material);
  private:
    // SimplePrimitive Private Members
    Shape shape;
    Material material;
};
```


#parec[
  Because `SimplePrimitive` only stores a shape and a material, it saves 32 bytes of memory. For scenes with millions of primitives, the overall savings can be meaningful.
][
  因为 `SimplePrimitive` 只存储形状和材质，所以它节省了 32 字节的内存。在包含数百万个图元的场景中，这种内存节省可能具有重要意义。
]

```cpp
Shape shape;
Material material;
```

#parec[
  We will not include the remainder of the #link("<SimplePrimitive>")[`SimplePrimitive`] implementation here; it is effectively a simplified subset of #link("<GeometricPrimitive>")[`GeometricPrimitive`];'s.
][
  我们不会在这里包括 #link("<SimplePrimitive>")[`SimplePrimitive`] 的其余实现；它实际上是 #link("<GeometricPrimitive>")[`GeometricPrimitive`] 的简化子集。
]

=== Object Instancing and Primitives in Motion
<object-instancing-and-primitives-in-Motion>

#parec[
  Object instancing is a classic technique in rendering that reuses transformed copies of a single collection of geometry at multiple positions in a scene.
][
  对象实例化是渲染中的一种经典技术，通过在场景中的多个位置重用单个几何集合的变换副本来实现。
]

#parec[
  For example, in a model of a concert hall with thousands of identical seats, the scene description can be compressed substantially if all the seats refer to a shared geometric representation of a single seat.
][
  例如，在一个有成千上万个相同座位的音乐厅模型中，如果所有座位都引用一个共享的单个座位的几何表示，则场景描述可以大大压缩。
]

#parec[
  The ecosystem scene in Figure 7.2 has 23,241 individual plants of various types, although only 31 unique plant models.
][
  图 7.2 中的生态系统场景有 23,241 株不同类型的植物，但只有 31 种独特的植物模型。
]

#parec[
  Because each plant model is instanced multiple times with a different transformation for each instance, the complete scene has a total of 3.1 billion triangles.
][
  因为每个植物模型被多次实例化，每个实例都有不同的变换，完整的场景总共有 31 亿个三角形。
]

#parec[
  However, only 24 million triangles are stored in memory thanks to primitive reuse through object instancing.
][
  然而，由于通过对象实例化重用基本体，内存中只存储了 2400 万个三角形。
]

#parec[
  `pbrt` uses just over 4 GB of memory when rendering this scene with object instancing (1.7 GB for BVHs, 707 MB for `Primitive`s, 877 MB for triangle meshes, and 846 MB for texture images), but would need upward of 516 GB to render it without instancing.
][
  `pbrt` 在渲染这个场景时使用了略多于 4 GB 的内存（1.7 GB 用于 BVH，707 MB 用于基本体，877 MB 用于三角网格，846 MB 用于纹理图像），但如果不使用实例化，则需要超过 516 GB 的内存。
]

#parec[
  The TransformedPrimitive implementation of the `Primitive` interface makes object instancing possible in `pbrt`.
][
  `Primitive` 接口的 #link("<TransformedPrimitive>")[TransformedPrimitive] 实现使得在 `pbrt` 中对象实例化成为可能。
]

#parec[
  Rather than holding a shape, it stores a single Primitive as well as a Transform that is injected in between the underlying primitive and its representation in the scene.
][
  它不持有形状，而是存储一个单一的基本体以及一个注入在基础基本体和其在场景中的表示之间的 #link("../Geometry_and_Transformations/Transformations.html#Transform")[Transform];。
]

#parec[
  This extra transformation enables object instancing.
][
  这个额外的变换使对象实例化成为可能。
]

#parec[
  Recall that the Shapes of Chapter 6 themselves had rendering from object space transformations applied to them to place them in the scene.
][
  请注意，第 6 章中的 #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shapes] 自身在渲染时应用了从对象空间变换到场景中的变换。
]

#parec[
  If a shape is held by a TransformedPrimitive, then the shape's notion of rendering space is not the actual scene rendering space—only after the TransformedPrimitive's transformation is also applied is the shape actually in rendering space.
][
  如果一个形状被 #link("<TransformedPrimitive>")[TransformedPrimitive] 持有，那么该形状的渲染空间概念并不是实际的场景渲染空间——只有在应用了 #link("<TransformedPrimitive>")[TransformedPrimitive] 的变换之后，形状才真正处于渲染空间。
]

#parec[
  For this application here, it makes sense for the shape to not be at all aware of the additional transformation being applied.
][
  对于这里的应用来说，让形状完全不知道正在应用的额外变换是有意义的。
]

#parec[
  For instanced primitives, letting Shapes know all the instance transforms is of limited utility: we would not want the TriangleMesh to make a copy of its vertex positions for each instance transformation and transform them all the way to rendering space, since this would negate the memory savings of object instancing.
][
  对于实例化的基本体，让 #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shapes] 知道所有的实例变换用处有限：我们不希望 #link("../Shapes/Triangle_Meshes.html#TriangleMesh")[TriangleMesh] 为每个实例变换复制其顶点位置并将它们全部变换到渲染空间，因为这会抵消对象实例化的内存节省。
]

```cpp
class TransformedPrimitive {
public:
    // 公共方法
    TransformedPrimitive(Primitive primitive,
                            const Transform *renderFromPrimitive)
        : primitive(primitive), renderFromPrimitive(renderFromPrimitive) { }
    pstd::optional<ShapeIntersection> Intersect(const Ray &r, Float tMax) const;
    bool IntersectP(const Ray &r, Float tMax) const;
    Bounds3f Bounds() const {
        return (*renderFromPrimitive)(primitive.Bounds());
    }
private:
    // 私有成员
    Primitive primitive;
    const Transform *renderFromPrimitive;
};
```


