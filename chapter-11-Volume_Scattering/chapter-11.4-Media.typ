#import "../template.typ": parec, ez_caption

== Media
<media>

#parec[
  Implementations of the `Medium` interface provide various representations of volumetric scattering properties in a region of space. In a complex scene, there may be multiple `Medium` instances, each representing different types of scattering in different parts of the scene. For example, an outdoor lake scene might have one `Medium` to model atmospheric scattering, another to model mist rising from the lake, and a third to model particles suspended in the water of the lake.
][
  `Medium` 接口的实现提供了空间区域中体积散射属性的各种表示。在复杂场景中，可能存在多个 `Medium` 实例，每个实例代表场景不同部分的不同类型的散射。例如，一个户外湖泊场景可能有一个 `Medium` 用于模拟大气散射，另一个用于模拟从湖面升起的薄雾，第三个用于模拟悬浮在湖水中的颗粒。
]

#parec[
  The `Medium` interface is also defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/media.h")[base/media.h];.
][
  `Medium` 接口也在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/media.h")[base/media.h] 中定义。
]

```cpp
<<Medium Definition>>=
class Medium : public TaggedPointer<<<Medium Types>> > {
  public:
    <<Medium Interface>>
    <<Medium Public Methods>>
};
```

#parec[
  `pbrt` provides five medium implementations. The first three will be discussed in the book, but `CloudMedium` is only included in the online edition of the book and the last, `NanoVDBMedium`, will not be presented at all. (It provides support for using volumes defined in the #emph[NanoVDB] format in `pbrt`. As elsewhere, we avoid discussion of the use of third-party APIs in the book text.)
][
  `pbrt` 提供了五种介质实现。 前三种将在书中讨论，但 `CloudMedium` 仅包含在书的在线版中，最后一种 `NanoVDBMedium` 将不会被介绍。（它提供了在 `pbrt` 中使用 #emph[NanoVDB] 格式定义的体积的支持。与其他部分一样，我们避免在书中讨论第三方 API 的使用。）
]

```cpp
<<Medium Types>>=
HomogeneousMedium, GridMedium, RGBGridMedium, CloudMedium, NanoVDBMedium
```

#parec[
  Before we get to the specification of the methods in the interface, we will describe a few details related to how media are represented in `pbrt`.
][
  在详细说明接口中的方法之前，我们将描述一些与 `pbrt` 中介质表示相关的细节。
]

#parec[
  The spatial distribution and extent of media in a scene is defined by associating `Medium` instances with the camera, lights, and primitives in the scene. For example, #link("../Cameras_and_Film/Camera_Interface.html#Camera")[Cameras];s store a `Medium` that represents the medium that the camera is inside. Rays leaving the camera then have the `Medium` associated with them. In a similar fashion, each #link("../Light_Sources/Light_Interface.html#Light")[Light] stores a `Medium` representing its medium. A `nullptr` value can be used to indicate a vacuum (where no volumetric scattering occurs).
][
  场景中介质的空间分布和范围是通过将 `Medium` 实例与场景中的相机、光源和基本体关联来定义的。例如，#link("../Cameras_and_Film/Camera_Interface.html#Camera")[相机] 存储一个表示相机内部介质的 `Medium`。离开相机的光线将与该 `Medium` 相关联。 类似地，每个#link("../Light_Sources/Light_Interface.html#Light")[光源] 存储一个表示其介质的 `Medium`。`nullptr` 值可以用来表示真空（没有体积散射发生的地方）。
]

#parec[
  In `pbrt`, the boundary between two different types of scattering media is always represented by the surface of a primitive. Rather than storing a single `Medium` like lights and cameras each do, primitives may store a `MediumInterface`, which stores the medium on each side of the primitive's surface.
][
  在 `pbrt` 中，不同类型散射介质的边界通常由基本体的表面表示。与灯光和相机每个存储一个 `Medium` 不同，基本体可以存储一个 `MediumInterface`，它存储基本体表面每一侧的介质。
]
```cpp
<<MediumInterface Definition>>=
struct MediumInterface {
    <<MediumInterface Public Methods>>
    <<MediumInterface Public Members>>
};
```

#parec[
  `MediumInterface` holds two #link("<Medium>")[Medium];s, one for the interior of the primitive and one for the exterior.
][
  `MediumInterface` 持有两个 #link("<Medium>")[Medium];，一个用于基本体的内部，一个用于外部。
]

```cpp
<<MediumInterface Public Members>>=
Medium inside, outside;
```

#parec[
  Specifying the extent of participating media in this way does allow the user to specify impossible or inconsistent configurations. For example, a primitive could be specified as having one medium outside of it, and the camera could be specified as being in a different medium without there being a `MediumInterface` between the camera and the surface of the primitive. In this case, a ray leaving the primitive toward the camera would be treated as being in a different medium from a ray leaving the camera toward the primitive. In turn, light transport algorithms would be unable to compute consistent results. For `pbrt`'s purposes, we think it is reasonable to expect that the user will be able to specify a consistent configuration of media in the scene and that the added complexity of code to check this is not worthwhile.
][
  这种方式确实允许用户指定不可能或不一致的介质配置。例如，可以将一个基本体指定为其外部有一种介质，而相机可以被指定为在不同的介质中，而相机与基本体表面之间没有 `MediumInterface`。 在这种情况下，从基本体向相机发出的光线将被视为在不同的介质中，而从相机向基本体发出的光线则在另一种介质中。反过来，光传输算法将无法计算出一致的结果。 对于 `pbrt` 的目的，我们认为用户能够在场景中指定一致的介质配置是合理的，并且检查这一点的代码增加的复杂性是不值得的。
]

#parec[
  A `MediumInterface` can be initialized with either one or two `Medium` values. If only one is provided, then it represents an interface with the same medium on both sides.
][
  `MediumInterface` 可以用一个或两个 `Medium` 值初始化。如果只提供一个，则表示两侧具有相同介质的接口。
]

```cpp
<<MediumInterface Public Methods>>=
MediumInterface(Medium medium) : inside(medium), outside(medium) {}
MediumInterface(Medium inside, Medium outside)
    : inside(inside), outside(outside) {}
```

#parec[
  The `IsMediumTransition()` method indicates whether a particular `MediumInterface` instance marks a transition between two distinct media.
][
  `IsMediumTransition()` 方法指示特定的 `MediumInterface` 实例是否标志着两个不同介质之间的过渡。
]
```cpp
<<MediumInterface Public Methods>>+=
bool IsMediumTransition() const { return inside != outside; }
```

#parec[
  With this context in hand, we can now provide a missing piece in the implementation of the #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#SurfaceInteraction::SetIntersectionProperties")[`SurfaceInteraction::SetIntersectionProperties()`] method—the implementation of the `<<Set medium properties at surface intersection>>` fragment.
][
  在理解了这些背景之后，我们现在可以提供 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#SurfaceInteraction::SetIntersectionProperties")[`SurfaceInteraction::SetIntersectionProperties()`] 方法实现中缺失的一部分——实现 `<<Set medium properties at surface intersection>>` 片段。
]

#parec[
  Instead of simply copying the value of the primitive's #link("<MediumInterface>")[MediumInterface] into the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];, it follows a slightly different approach and only uses this #link("<MediumInterface>")[MediumInterface] if it specifies a proper transition between participating media. Otherwise, the `Ray::medium` field takes precedence. Setting the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];'s `mediumInterface` field in this way greatly simplifies the specification of scenes containing media: in particular, it is not necessary to provide corresponding `Medium`s at every scene surface that is in contact with a medium. Instead, only non-opaque surfaces that have different media on each side require an explicit medium interface. In the simplest case where a scene containing opaque objects is filled with a participating medium (e.g., haze), it is enough for the camera and light sources to have their media specified accordingly.
][
  与简单地将基本体的 #link("<MediumInterface>")[MediumInterface] 值复制到 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] 不同，它采用略有不同的方法，仅在它指定了参与介质之间的适当过渡时才使用此 #link("<MediumInterface>")[MediumInterface];。 否则，`Ray::medium` 字段优先。以这种方式设置 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] 的 `mediumInterface` 字段极大地简化了包含介质的场景的规范：特别是，不必在每个与介质接触的场景表面提供相应的 `Medium`。 相反，只有两侧具有不同介质的非不透明表面才需要显式的介质接口。在最简单的情况下，若场景中充满参与介质（例如，薄雾），只需为相机和光源指定其介质。
]

```cpp
<<Set medium properties at surface intersection>>=
if (primMediumInterface && primMediumInterface->IsMediumTransition())
    mediumInterface = primMediumInterface;
else
    medium = rayMedium;
```

#parec[
  Once `mediumInterface` or `medium` is set, it is possible to implement methods that return information about the local media. For surface interactions, a direction `w` can be specified to select a side of the surface. If a `MediumInterface` has been stored, the dot product with the surface normal determines whether the inside or outside medium should be returned. Otherwise, `medium` is returned.
][
  一旦设置了 `mediumInterface` 或 `medium`，就可以实现返回局部介质信息的方法。对于表面交互，可以指定一个方向 `w` 来选择表面的一侧。 如果存储了 `MediumInterface`，则与表面法线的点积决定是返回内部还是外部介质。否则，返回 `medium`。
]

```cpp
<<Interaction Public Methods>>+=
Medium GetMedium(Vector3f w) const {
    if (mediumInterface)
        return Dot(w, n) > 0 ? mediumInterface->outside :
                               mediumInterface->inside;
    return medium;
}
```


#parec[
  For interactions that are known to be inside participating media, another variant of `GetMedium()` that does not take the irrelevant outgoing direction vector is available. In this case, if a `MediumInterface *` has been stored, it should point to the same medium for both "inside" and "outside."
][
  对于已知在参与介质内部的交互，提供了不需要不相关的出射方向向量的 `GetMedium()` 变体。在这种情况下，如果存储了 `MediumInterface *`，它应该指向相同的内部和外部介质。
]

```cpp
<<Interaction Public Methods>>+=
Medium GetMedium() const {
    return mediumInterface ? mediumInterface->inside : medium;
}
```

#parec[
  Primitives associated with shapes that represent medium boundaries generally have a #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[Material] associated with them. For example, the surface of a lake might use an instance of #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#DielectricMaterial")[DielectricMaterial] to describe scattering at the lake surface, which also acts as the boundary between the rising mist's `Medium` and the lake water's `Medium`. However, sometimes we only need the shape for the boundary surface that it provides to delimit a participating medium boundary and we do not want to see the surface itself. For example, the medium representing a cloud might be bounded by a box made of triangles where the triangles are only there to delimit the cloud's extent and should not otherwise affect light passing through them.
][
  与表示介质边界的形状相关联的基本体通常与一个 #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[材质] 相关联。例如，湖泊的表面可能使用 #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#DielectricMaterial")[DielectricMaterial] 的实例来描述湖泊表面的散射，这也作为上升薄雾的 `Medium` 和湖水的 `Medium` 之间的边界。 然而，有时我们只需要形状提供的边界表面来限定参与介质边界，而不希望看到表面本身。 例如，表示云的介质可能由一个三角形构成的盒子界定，其中三角形仅用于限定云的范围，不应影响穿过它们的光线。
]

#parec[
  While such a surface that disappears and does not affect ray paths could be accurately described by a BTDF that represents perfect specular transmission with the same index of refraction on both sides, dealing with such surfaces places extra burden on the `Integrator`s (not all of which handle this type of specular light transport well). Therefore, `pbrt` allows such surfaces to have a #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[Material] that is `nullptr`, indicating that they do not affect light passing through them; in turn, #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#SurfaceInteraction::GetBSDF")[SurfaceInteraction::GetBSDF()] will return an unset `BSDF`. The light transport routines then do not worry about light scattering from such surfaces and only account for changes in the current medium at them. For an example of the difference that scattering at the surface makes, see Figure 11.16, which has two instances of the Ganesha model filled with scattering media; one has a scattering surface at the boundary and the other does not.
][
  虽然这种消失且不影响光线路径的表面可以通过一个表示完美镜面传输且两侧折射率相同的 BTDF 来准确描述，但处理这种表面会给 `Integrator` 带来额外的负担（并非所有的 `Integrator` 都能很好地处理这种类型的镜面光传输）。 因此，`pbrt` 允许这样的表面具有一个 `nullptr` 的 #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[材质];，表示它们不影响通过它们的光线；反过来，#link("../Textures_and_Materials/Material_Interface_and_Implementations.html#SurfaceInteraction::GetBSDF")[SurfaceInteraction::GetBSDF()] 将返回一个未设置的 `BSDF`。 光传输例程不再担心这种表面的光散射，只考虑它们处的当前介质变化。 有关表面散射的差异的示例，请参见图 11.16，其中有两个填充有散射介质的 Ganesha 模型实例；一个在边界处有散射表面，另一个没有。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/ganesha-interface-and-none.png"),
  caption: [
    #ez_caption[
      Figure 11.16: Scattering Media inside the Ganesha. Both models have
      the same isotropic homogeneous scattering media inside of them. On
      the left, the `Material` is `nullptr`, which indicates that the
      surface should be ignored by rays and is only used to delineate a
      participating medium’s extent. On the right, the model’s surface has
      a dielectric interface that both makes the interface visible and
      scatters some of the incident light, making the interior darker.
    ][
      Ganesha 内的散射介质。两个模型内部具有相同的各向同性均匀散射介质。左侧，`Material`
      为 `nullptr`，表示光线应忽略表面，仅用于划定参与介质的范围。右侧，模型的表面具有介电接口，使接口可见并散射部分入射光，使内部变暗。
    ]
  ],
)<media-boundary-and-no>

=== Medium Interface
<medium-interface>

#parec[
  Implementations must include three methods. The first is `IsEmissive()`, which indicates whether they include any volumetric emission. This method is used solely so that `pbrt` can check if a scene has been specified without any light sources and print an informative message if so.
][
  实现必须包含三个方法。第一个是 `IsEmissive()`，用于指示它们是否包含任何体积光源。此方法仅用于让 `pbrt` 检查场景是否已指定而没有任何光源，并在这种情况下打印一条信息性消息。
]

```cpp
<<Medium Interface>>=
bool IsEmissive() const;
```


#parec[
  The `SamplePoint()` method returns information about the scattering and emission properties of the medium at a specified rendering-space point in the form of a `MediumProperties` object.
][
  `SamplePoint()` 方法以 `MediumProperties` 对象的形式返回渲染空间中的点处介质的散射和发射属性信息。
]
```cpp
<<Medium Interface>>+=
MediumProperties SamplePoint(Point3f p,
                             const SampledWavelengths &lambda) const;
```


#parec[
  `MediumProperties` is a simple structure that wraps up the values that describe scattering and emission at a point inside a medium. When initialized to their default values, its member variables together indicate no scattering or emission. Thus, implementations of `SamplePoint()` can directly return a `MediumProperties` with no further initialization if the specified point is outside of the medium's spatial extent.
][
  `MediumProperties` 是一个简单的结构，封装了描述介质内部某点的散射和发射的值。当初始化为默认值时，其成员变量共同指示没有散射或发射。因此，如果指定点在介质的空间范围之外，`SamplePoint()` 的实现可以直接返回一个无需进一步初始化的 `MediumProperties`。
]

```cpp
<<MediumProperties Definition>>=
struct MediumProperties {
    SampledSpectrum sigma_a, sigma_s;
    PhaseFunction phase;
    SampledSpectrum Le;
};
```

#parec[
  The third method that `Medium` implementations must implement is `SampleRay()`, which provides information about the medium's majorant $sigma_(m a j)$ along the ray's extent. It does so using one or more `RayMajorantSegment` objects. Each describes a constant majorant over a segment of a ray.
][
  `Medium` 实现必须实现的第三个方法是 `SampleRay()`，它提供有关沿射线范围的介质主导量 $sigma_(m a j)$ 的信息。它通过一个或多个 `RayMajorantSegment` 对象来实现。每个对象描述射线某段的恒定主导量。
]

```cpp
<<RayMajorantSegment Definition>>=
struct RayMajorantSegment {
    Float tMin, tMax;
    SampledSpectrum sigma_maj;
};
```

#parec[
  Some `Medium` implementations have a single medium-wide majorant (e.g., `HomogeneousMedium`), though for media where the scattering coefficients vary significantly over their extent, it is usually better to have distinct local majorants that bound $sigma_t$ over smaller regions. These tighter majorants can improve rendering performance by reducing the frequency of null scattering when sampling interactions along a ray.
][
  一些 `Medium` 实现具有单一的介质范围主导量（例如，`HomogeneousMedium`），但对于散射系数在其范围内显著变化的介质，通常最好有不同的局部主导量，以限制较小区域内的 $sigma_t$。这些更严格的主导量可以通过减少沿射线采样交互时的无效散射频率来提高渲染性能。
]

#parec[
  The number of segments along a ray is variable, depending on both the ray's geometry and how the medium discretizes space. However, we would not like to return variable-sized arrays of `RayMajorantSegment`s from `SampleRay()` method implementations. Although dynamic memory allocation to store them could be efficiently handled using a `ScratchBuffer`, another motivation not to immediately return all of them is that often not all the `RayMajorantSegment`s along the ray are needed; if the ray path terminates or scattering occurs along the ray, then any additional `RayMajorantSegment`s past the corresponding point would be unused and their initialization would be wasted work.
][
  射线上的段数是可变的，取决于射线的几何形状以及介质如何离散化空间。然而，我们不希望从 `SampleRay()` 方法实现中返回可变大小的 `RayMajorantSegment` 数组。虽然可以使用 `ScratchBuffer`（临时缓冲区）来有效地处理动态内存分配以存储它们，但不立即返回所有这些的另一个动机是，通常并不需要射线上的所有 `RayMajorantSegment`；如果射线路径终止或沿射线发生散射，则在相应点之后的任何额外 `RayMajorantSegment` 都将未被使用，其初始化将是浪费的工作。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f17.svg"),
  caption: [
    #ez_caption[
      RayMajorantIterator implementations return a series of segments in parametric $t$ along a ray where each segment has a majorant that is an upper bound of the medium’s $sigma_t$ value along the segment. Implementations are free to specify segments of varying lengths and to skip regions of space with no scattering, though they must provide segments in front-to-back order.
    ][

    ]
  ],
)<medium-ray-iterator>


#parec[
  Therefore, the `RayMajorantIterator` interface provides a mechanism for `Medium` implementations to return `RayMajorantSegment`s one at a time as they are needed. There is a single method in this interface: `Next()`. Implementations of it should return majorant segments from the front to the back of the ray with no overlap in $t$ between segments, though it may skip over ranges of $t$ corresponding to regions of space where there is no scattering.(See @fig:medium-ray-iterator) After it has returned all segments along the ray, an unset `optional` value should be returned. Thanks to this interface, different `Medium` implementations can generate `RayMajorantSegment`s in different ways depending on their internal medium representation.
][
  因此，`RayMajorantIterator`接口提供了一种机制，使 `Medium` 实现可以在需要时一次返回一个 `RayMajorantSegment`。此接口中有一个方法：`Next()`。它的实现应从射线的前端到后端返回主导段，段之间在 $t$ 上没有重叠，但可以跳过对应于没有散射的空间区域的 $t$ 范围。（如@fig:medium-ray-iterator） 在返回射线上的所有段之后，应返回一个未设置的 `optional` 值。由于此接口，不同的 `Medium` 实现可以根据其内部介质表示以不同方式生成 `RayMajorantSegment`。
]

```cpp
<<RayMajorantIterator Definition>>=
class RayMajorantIterator : public TaggedPointer<HomogeneousMajorantIterator,
                                                 DDAMajorantIterator> {
  public:
    pstd::optional<RayMajorantSegment> Next();
};
```

#parec[
  Turning back now to the `SampleRay()` interface method: in @light-transport-ii-volume-rendering and @wavefront-rendering-on-gpus we will find it useful to know the type of `RayMajorantIterator` that is associated with a specific `Medium` type. We can then declare the iterator as a local variable that is stored on the stack, which improves efficiency both from avoiding dynamic memory allocation for it and from allowing the compiler to more easily store it in registers. Therefore, `pbrt` requires that `Medium` implementations include a local type definition for `MajorantIterator` in their class definition that gives the type of their `RayMajorantIterator`. Their `SampleRay()` method itself should then directly return their majorant iterator type. Concretely, a `Medium` implementation should include declarations like the following in its class definition, with the ellipsis replaced with its `RayMajorantIterator` type.
][
  现在回到 `SampleRay()` 接口方法：在@light-transport-ii-volume-rendering 和 @wavefront-rendering-on-gpus 中，我们将发现知道与特定 `Medium` 类型相关的 `射线主导迭代器` 类型是有用的。然后我们可以将迭代器声明为存储在堆栈上的局部变量，这不仅避免了动态内存分配的效率问题，还使编译器更容易将其存储在寄存器中。 因此，`pbrt` 要求 `Medium` 实现在其类定义中包含 `MajorantIterator` 的本地类型定义，以给出其 `RayMajorantIterator` 的类型。然后其 `SampleRay()` 方法本身应直接返回其主导迭代器类型。具体来说，`Medium` 实现应在其类定义中包含如下声明，其中省略号替换为其 `RayMajorantIterator` 类型。
]

```cpp
using MajorantIterator = ...;
MajorantIterator SampleRay(Ray ray, Float tMax,
                           const SampledWavelengths &lambda) const;
```

#parec[
  (The form of this type and method definition is similar to the Material::GetBxDF() methods in Section 10.5.)
][
  (The form of this type and method definition is similar to the Material::GetBxDF() methods in Section 10.5.)
]

#parec[
  For cases where the medium's type is not known at compile time, the `Medium` class itself provides the implementation of a different `SampleRay()` method that takes a `ScratchBuffer`, uses it to allocate the appropriate amount of storage for the medium's ray iterator, and then calls the `Medium`'s `SampleRay()` method implementation to initialize it. The returned `RayMajorantIterator` can then be used to iterate over the majorant segments.
][
  对于在编译时未知介质类型的情况，`Medium` 类本身提供了一个不同的 `SampleRay()` 方法的实现，该方法接受一个 `ScratchBuffer`（临时缓冲区），使用它为介质的射线迭代器分配适当的存储量，然后调用 `Medium` 的 `SampleRay()` 方法实现来初始化它。然后返回的 `RayMajorantIterator` 可以用于迭代主导段。
]

#parec[
  The implementation of this method uses the same trick that `Material::GetBSDF()` does: the `TaggedPointer`'s dynamic dispatch capabilities are used to automatically generate a separate call to the provided lambda function for each medium type, with the `medium` parameter specialized to be of the `Medium`'s concrete type.
][
  此方法的实现使用了与 `Material::GetBSDF()` 相同的技巧：`TaggedPointer`（标记指针）的动态派发功能用于自动为每种介质类型生成对提供的 lambda 函数的单独调用，其中 `medium` 参数专用于 `Medium` 的具体类型。
]

```cpp
<<Medium Sampling Function Definitions>>=
RayMajorantIterator Medium::SampleRay(Ray ray, Float tMax,
        const SampledWavelengths &lambda, ScratchBuffer &buf) const {
    auto sample = [ray,tMax,lambda,&buf](auto medium) {
        <<Return RayMajorantIterator for medium’s majorant iterator>>
    };
    return DispatchCPU(sample);
}
```
#parec[
  The `Medium` passed to the lambda function arrives as a reference to a pointer to the medium type; those are easily removed to get the basic underlying type. From it, the iterator type follows from the `MajorantIterator` type declaration in the associated class. In turn, storage can be allocated for the iterator type and it can be initialized. Since the returned value is of the `RayMajorantIterator` interface type, the caller can proceed without concern for the actual type.
][
  传递给 lambda 函数的 `Medium` 作为对介质类型指针的引用到达；这些很容易移除以获得基本的底层类型。从中，迭代器类型遵循关联类中的 `MajorantIterator` 类型声明。反过来，可以为迭代器类型分配存储并进行初始化。由于返回值是 `RayMajorantIterator` 接口类型，调用者可以继续而不必担心实际类型。
]

```cpp
<<Return RayMajorantIterator for medium’s majorant iterator>>=
using ConcreteMedium = typename std::remove_reference_t<decltype(*medium)>;
using Iter = typename ConcreteMedium::MajorantIterator;
Iter *iter = (Iter *)buf.Alloc(sizeof(Iter), alignof(Iter));
*iter = medium->SampleRay(ray, tMax, lambda);
return RayMajorantIterator(iter);
```

=== Homogeneous Medium

#parec[
  The `HomogeneousMedium` is the simplest possible medium. It represents a region of space with constant $sigma_a$, $sigma_s$, and $L_e$ values throughout its extent. It uses the Henyey–Greenstein phase function to represent scattering in the medium, also with a constant $g$. Its definition is in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.h")[`media.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.cpp")[`media.cpp`];. This medium was used for the images in @fig:hg-renderings and @fig:media-boundary-and-no.
][
  `HomogeneousMedium` 是最简单的介质。它表示一个空间区域，其内部的 $sigma_a$, $sigma_s$, and $L_e$ 值是恒定的。它使用 Henyey–Greenstein 相位函数来表示介质中的散射，且 $g$ 也是恒定的。其定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.h")[`media.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/media.cpp")[`media.cpp`] 中。该介质用于@fig:hg-renderings 和@fig:media-boundary-and-no 的图像中。
]

```cpp
class HomogeneousMedium {
  public:
    <<HomogeneousMedium Public Type Definitions>>       using MajorantIterator = HomogeneousMajorantIterator;
    <<HomogeneousMedium Public Methods>>       HomogeneousMedium(Spectrum sigma_a, Spectrum sigma_s,
                         Float sigmaScale, Spectrum Le, Float LeScale, Float g, Allocator alloc)
           : sigma_a_spec(sigma_a, alloc), sigma_s_spec(sigma_s, alloc),
             Le_spec(Le, alloc), phase(g) {
           sigma_a_spec.Scale(sigmaScale);
           sigma_s_spec.Scale(sigmaScale);
           Le_spec.Scale(LeScale);
       }
       static HomogeneousMedium *Create(const ParameterDictionary &parameters,
                                        const FileLoc *loc, Allocator alloc);
       bool IsEmissive() const { return Le_spec.MaxValue() > 0; }
       MediumProperties SamplePoint(Point3f p,
                                    const SampledWavelengths &lambda) const {
           SampledSpectrum sigma_a = sigma_a_spec.Sample(lambda);
           SampledSpectrum sigma_s = sigma_s_spec.Sample(lambda);
           SampledSpectrum Le = Le_spec.Sample(lambda);
           return MediumProperties{sigma_a, sigma_s, &phase, Le};
       }
       HomogeneousMajorantIterator SampleRay(
               Ray ray, Float tMax, const SampledWavelengths &lambda) const {
           SampledSpectrum sigma_a = sigma_a_spec.Sample(lambda);
           SampledSpectrum sigma_s = sigma_s_spec.Sample(lambda);
           return HomogeneousMajorantIterator(0, tMax, sigma_a + sigma_s);
       }
       std::string ToString() const;
  private:
    <<HomogeneousMedium Private Data>>       DenselySampledSpectrum sigma_a_spec, sigma_s_spec, Le_spec;
       HGPhaseFunction phase;
};
```



#parec[
  Its constructor (not included here) initializes the following member variables from provided parameters. It takes spectral values in the general form of #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`];s but converts them to the form of #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`DenselySampledSpectrum`];s. While this incurs a memory cost of a kilobyte or so for each one, it ensures that sampling the spectrum will be fairly efficient and will not require, for example, the binary search that #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#PiecewiseLinearSpectrum")[`PiecewiseLinearSpectrum`] uses. It is unlikely that there will be enough distinct instances of `HomogeneousMedium` in a scene that this memory cost will be significant.
][
  其构造函数（此处未包含）根据提供的参数初始化以下成员变量。它以 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] 的一般形式接收光谱值，但将其转换为 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#DenselySampledSpectrum")[`密集采样光谱`] 的形式。虽然这会为每个光谱带来约一千字节左右的内存成本，但它确保了采样光谱的效率，不需要例如 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#PiecewiseLinearSpectrum")[`PiecewiseLinearSpectrum`] 使用的二分搜索。在场景中不太可能有足够多的 `HomogeneousMedium` 实例使得这种内存成本变得显著。
]

```cpp
DenselySampledSpectrum sigma_a_spec, sigma_s_spec, Le_spec;
       HGPhaseFunction phase;
```


#parec[
  Implementation of the `IsEmissive()` interface method is straightforward.
][
  `IsEmissive()` 接口方法的实现很简单。
]


```cpp
bool IsEmissive() const { return Le_spec.MaxValue() > 0; }
```


#parec[
  `SamplePoint()` just needs to sample the various constant scattering properties at the specified wavelengths.
][
  `SamplePoint()` 方法只需在指定波长采样各种恒定的散射属性。
]


```cpp
MediumProperties SamplePoint(Point3f p,
                             const SampledWavelengths &lambda) const {
    SampledSpectrum sigma_a = sigma_a_spec.Sample(lambda);
    SampledSpectrum sigma_s = sigma_s_spec.Sample(lambda);
    SampledSpectrum Le = Le_spec.Sample(lambda);
    return MediumProperties{sigma_a, sigma_s, &phase, Le};
}
```


#parec[
  `SampleRay()` uses the #link("<HomogeneousMajorantIterator>")[`HomogeneousMajorantIterator`] class for its #link("<RayMajorantIterator>")[`RayMajorantIterator`];.
][
  `SampleRay()` 使用 #link("<HomogeneousMajorantIterator>")[`HomogeneousMajorantIterator`] 类作为其 #link("<RayMajorantIterator>")[`RayMajorantIterator`];。
]

```cpp
using MajorantIterator = HomogeneousMajorantIterator;
```


#parec[
  There is no need for null scattering in a homogeneous medium and so a single #link("<RayMajorantSegment>")[`RayMajorantSegment`] for the ray's entire extent suffices. `HomogeneousMajorantIterator` therefore stores such a segment directly.
][
  在均匀介质中不需要考虑空散射，因此光线的整个范围只需一个 #link("<RayMajorantSegment>")[`RayMajorantSegment`];。因此，`HomogeneousMajorantIterator` 直接存储这样的段。
]



```cpp
class HomogeneousMajorantIterator {
  public:
    <<HomogeneousMajorantIterator Public Methods>>       HomogeneousMajorantIterator() : called(true) {}
       HomogeneousMajorantIterator(Float tMin, Float tMax,
                                   SampledSpectrum sigma_maj)
           : seg{tMin, tMax, sigma_maj}, called(false) {}
       pstd::optional<RayMajorantSegment> Next() {
           if (called) return {};
           called = true;
           return seg;
       }
       std::string ToString() const;
  private:
    RayMajorantSegment seg;
    bool called;
};
```


#parec[
  Its default constructor sets `called` to true and stores no segment; in this way, the case of a ray missing a medium and there being no valid segment can be handled with a default-initialized `HomogeneousMajorantIterator`.
][
  其默认构造函数将 `called` 设置为 true 并且不存储段；这样，光线未穿过介质且没有有效段的情况可以通过默认初始化的 `HomogeneousMajorantIterator` 处理。
]


```cpp
HomogeneousMajorantIterator() : called(true) {}
HomogeneousMajorantIterator(Float tMin, Float tMax,
                            SampledSpectrum sigma_maj)
    : seg{tMin, tMax, sigma_maj}, called(false) {}
```


#parec[
  If a segment was specified, it is returned the first time `Next()` is called. Subsequent calls return an unset value, indicating that there are no more segments.
][
  如果指定了一个段，则在首次调用 `Next()` 时返回。后续调用返回未设置的值，表示没有更多段。
]



```cpp
pstd::optional<RayMajorantSegment> Next() {
    if (called) return {};
    called = true;
    return seg;
}
```


#parec[
  The implementation of `HomogeneousMedium::SampleRay()` is now trivial. Its only task is to compute the majorant, which is equal to $sigma_t = sigma_a + sigma_s$.
][
  `HomogeneousMedium::SampleRay()` 的实现变得非常简单。其唯一任务是计算主导值，即 $sigma_t = sigma_a + sigma_s$。
]


```cpp
HomogeneousMajorantIterator SampleRay(
        Ray ray, Float tMax, const SampledWavelengths &lambda) const {
    SampledSpectrum sigma_a = sigma_a_spec.Sample(lambda);
    SampledSpectrum sigma_s = sigma_s_spec.Sample(lambda);
    return HomogeneousMajorantIterator(0, tMax, sigma_a + sigma_s);
}
```


=== DDA Majorant Iterator
<dda-majorant-iterator>


#parec[
  Before moving on to the remaining two Medium implementations, we will describe another `RayMajorantIterator` that is much more efficient than the `HomogeneousMajorantIterator` when the medium's scattering coefficients vary over its extent. To understand the problem with a single majorant in this case, recall that the mean free path is the average distance between scattering events. It is one over the attenuation coefficient and so the average $t$ step returned by a call to `SampleExponential()` given a majorant $sigma_"maj"$ will be $1 \/ sigma_"maj"$. Now consider a medium that has a $sigma_t = 1$ almost everywhere but has $sigma_t = 100$ in a small region. If $sigma_"maj" = 100$ everywhere, then in the less dense region 99% of the sampled distances will be null-scattering events and the ray will take steps that are 100 times shorter than it would take if $sigma_"maj"$ was 1. Rendering performance suffers accordingly.
][
  在继续介绍剩下的两个 Medium 实现之前，我们将描述另一种 `RayMajorantIterator`，当介质的散射系数在其范围内变化时，它比 `HomogeneousMajorantIterator` 更高效。 为了理解在这种情况下单一上界的问题，回忆一下平均自由程是散射事件之间的平均距离。它是衰减系数的倒数，因此给定一个上界 $sigma_"maj"$，调用 `SampleExponential()` 返回的平均 $t$ 步长将是 $1 \/ sigma_"maj"$。 现在考虑一个介质，其 $sigma_t = 1$ 几乎在所有地方都是如此，但在一个小区域内 $sigma_t = 100$。如果 $sigma_"maj" = 100$ 在所有地方都是如此，那么在较不密集的区域，99% 的采样距离将导致零散射事件，光线的步长将比 $sigma_"maj"$ 为 1 时短 100 倍。因此渲染性能相应地受到影响。
]

#parec[
  This issue motivates using a data structure to store spatially varying majorants, which allows tighter majorants and more efficient sampling operations. A variety of data structures have been used for this problem; the "Further Reading" section has details. The remainder of pbrt's Medium implementations all use a simple grid where each cell stores a majorant over the corresponding region of the volume. In turn, as a ray passes through the medium, it is split into segments through this grid and sampled based on the local majorant.
][
  这个问题促使我们使用一种数据结构来存储空间变化的上界，这允许更紧密的上界和更高效的采样操作。 为了解决这个问题，已经使用了多种数据结构；"进一步阅读"部分有详细信息。pbrt 的其余 Medium 实现都使用一个简单的网格，其中每个单元格存储相应体积区域的上界。 反过来，当光线穿过介质时，它被分割成通过这个网格的段，并基于局部上界进行采样。
]

#parec[
  More precisely, the local majorant is found with the combination of a regular grid of voxels of scalar densities and a `SampledSpectrum` $sigma_t$ value. The majorant in each voxel is given by the product of $sigma_t$ and the voxel's density. The MajorantGrid class stores that grid of voxels.
][
  更准确地说，局部上界是通过标量密度的规则体素网格和一个 `SampledSpectrum` $sigma_t$ 值的组合找到的。 每个体素中的上界由 $sigma_t$ 和体素密度的乘积给出。`MajorantGrid` 类存储该体素网格。
]

```cpp
struct MajorantGrid {
    // MajorantGrid Public Methods
    MajorantGrid() = default;
    MajorantGrid(Bounds3f bounds, Point3i res, Allocator alloc)
        : bounds(bounds), voxels(res.x * res.y * res.z, alloc), res(res) {}
    Float Lookup(int x, int y, int z) const {
        return voxels[x + res.x * (y + res.y * z)];
    }
    void Set(int x, int y, int z, Float v) {
        voxels[x + res.x * (y + res.y * z)] = v;
    }
    Bounds3f VoxelBounds(int x, int y, int z) const {
        Point3f p0(Float(x) / res.x, Float(y) / res.y, Float(z) / res.z);
        Point3f p1(Float(x+1) / res.x, Float(y+1) / res.y, Float(z+1) / res.z);
        return Bounds3f(p0, p1);
    }
    // MajorantGrid Public Members
    Bounds3f bounds;
    pstd::vector<Float> voxels;
    Point3i res;
};
```



#parec[
  `MajorantGrid` just stores an axis-aligned bounding box for the grid, its voxel values, and its resolution in each dimension.
][
  MajorantGrid 仅存储网格的轴对齐边界框、其体素值及其在每个维度上的分辨率。
]

```cpp
 Bounds3f bounds;
 pstd::vector<Float> voxels;
 Point3i res;
```


#parec[
  The voxel array is indexed in the usual manner, with $x$ values laid out consecutively in memory, then $y$, and then $z$. Two simple methods handle the indexing math for setting and looking up values in the grid.
][
  体素数组按照通常的方式索引， $x$ 值在内存中连续排列，然后是 $y$，然后是 $z$。两个简单的方法处理网格中值的设置和查找的索引数学。
]

```cpp
Float Lookup(int x, int y, int z) const {
    return voxels[x + res.x * (y + res.y * z)];
}
void Set(int x, int y, int z, Float v) {
    voxels[x + res.x * (y + res.y * z)] = v;
}
```


#parec[
  Next, the `VoxelBounds()` method returns the bounding box corresponding to the specified voxel in the grid. Note that the returned bounds are with respect to $[0, 1]^3$ and not the bounds member variable.
][
  接下来，`VoxelBounds()` 方法返回网格中指定体素对应的边界框。注意返回的边界是相对于 $[0, 1]^3$ 的，而不是 bounds 成员变量。
]

```cpp
Bounds3f VoxelBounds(int x, int y, int z) const {
    Point3f p0(Float(x) / res.x, Float(y) / res.y, Float(z) / res.z);
    Point3f p1(Float(x+1) / res.x, Float(y+1) / res.y, Float(z+1) / res.z);
    return Bounds3f(p0, p1);
}
```


#parec[
  Efficiently enumerating the voxels that the ray passes through can be done with a technique that is similar in spirit to Bresenham's classic line drawing algorithm, which incrementally finds series of pixels that a line passes through using just addition and comparisons to step from one pixel to the next. (This type of algorithm is known as a digital differential analyzer (DDA)—hence the name of the DDAMajorantIterator.) The main difference between the ray stepping algorithm and Bresenham's is that we would like to find all of the voxels that the ray passes through, while Bresenham's algorithm typically only turns on one pixel per row or column that a line passes through.
][
  有效地枚举光线穿过的体素可以使用一种类似于 Bresenham 经典的线绘制算法的技术，该算法通过仅使用加法和比较从一个像素步进到下一个像素来增量地找到线穿过的一系列像素。 （这种类型的算法被称为数字微分分析器（DDA）——因此 DDAMajorantIterator 的名称。） 光线步进算法和 Bresenham 算法之间的主要区别在于我们希望找到光线穿过的所有体素，而 Bresenham 算法通常只在线穿过的每行或每列打开一个像素。
]

```cpp
<<DDAMajorantIterator Definition>>=
class DDAMajorantIterator {
  public:
    <<DDAMajorantIterator Public Methods>>
  private:
    <<DDAMajorantIterator Private Members>>
};
```

#parec[
  After copying parameters passed to it to member variables, the constructor's main task is to compute a number of values that represent the DDA's state.
][
  在将传入的参数复制到成员变量后，构造函数的主要任务是计算一些表示DDA状态的值。
]

```cpp
<<DDAMajorantIterator Public Methods>>=
DDAMajorantIterator(Ray ray, Float tMin, Float tMax,
                    const MajorantGrid *grid, SampledSpectrum sigma_t)
    : tMin(tMin), tMax(tMax), grid(grid), sigma_t(sigma_t) {
    <<Set up 3D DDA for ray through the majorant grid>>
}
```

#parec[
  The `tMin` and `tMax` member variables store the parametric range of the ray for which majorant segments are yet to be generated; `tMin` is advanced after each step. Their default values specify a degenerate range, which causes a default-initialized `DDAMajorantIterator` to return no segments when its `Next()` method is called.
][
  `tMin` 和 `tMax` 成员变量存储光线的参数范围，在该范围内主量段尚未生成；`tMin` 会在每一步后前进。它们的默认值指定了一个退化范围，这使得默认初始化的 `DDAMajorantIterator` 在调用其 `Next()` 方法时不返回任何段。
]

```cpp
SampledSpectrum sigma_t;
Float tMin = Infinity, tMax = -Infinity;
const MajorantGrid *grid;
```

#parec[
  Grid voxel traversal is handled by an incremental algorithm that tracks the current voxel and the parametric $t$ where the ray enters the next voxel in each direction. It successively takes a step in the direction that has the smallest such $t$ until the ray exits the grid or traversal is halted. The values that the algorithm needs to keep track of are the following:
][
  网格体素的遍历由一种增量算法处理，该算法跟踪当前体素以及光线进入每个方向上下一个体素的参数化 $t$ 值。算法依次向具有最小 $t$ 值的方向迈进一步，直到光线退出网格或遍历被中止。算法需要跟踪的值如下：
]

#parec[
  1. The integer coordinates of the voxel currently being considered, `voxel`.
][
  1. 当前所考虑的体素的整数坐标，`voxel`。
]

#parec[
  2. The parametric $t$ position along the ray where it makes its next crossing into another voxel in each of the $x$, $y$, and $z$ directions, `nextCrossingT` (@fig:grid-dda).
][
  2. 光线在每个 $x$、$y$ 和 $z$ 方向上穿越到下一个体素的参数化 $t$ 位置，`nextCrossingT`（@fig:grid-dda）。
]


#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f18.svg"),
  caption: [
    #ez_caption[
      *Stepping a Ray through a Voxel Grid.*
      The parametric distance along the ray to the point where it crosses into the next voxel in the $x$ direction is stored in `nextCrossingT[0]`, and similarly for the $y$ and $z$ directions (not shown). When the ray crosses into the next $x$ voxel, for example, it is immediately possible to update the value of `nextCrossingT[0]` by adding a fixed value, the voxel width in $x$ divided by the ray's $x$ direction, `deltaT[0]`.
    ][
      *光线穿越体素网格的过程。*
      光线沿着 $x$ 方向穿越到下一个体素的点的参数化距离存储在 `nextCrossingT[0]` 中，$y$ 和 $z$ 方向类似（未显示）。例如，当光线穿越到下一个 $x$ 方向的体素时，可以立即通过添加一个固定值来更新 `nextCrossingT[0]` 的值，该固定值是体素在 $x$ 方向的宽度除以光线的 $x$ 方向，`deltaT[0]`。
    ]
  ],
)<grid-dda>


#parec[
  3. The change in the current voxel coordinates after a step in each direction (1 or -1), stored in `step`.
][
  3. 在每个方向迈出一步后当前体素坐标的变化（1 或 -1），存储在 `step` 中。
]

#parec[
  4. The parametric distance along the ray between voxels in each direction, `deltaT`.
][
  4. 光线在每个方向上两个体素之间的参数化距离，`deltaT`。
]

#parec[
  5. The coordinates of the voxel after the last one the ray passes through when it exits the grid, `voxelLimit`.
][
  5. 光线退出网格时经过的最后一个体素的坐标，`voxelLimit`。
]

#parec[
  The first two values are updated as the ray steps through the grid, while the last three are constant for each ray. All are stored in member variables.
][
  前两个值在光线遍历网格时更新，而后三个值对于每条光线都是固定的。所有值都存储在成员变量中。
]

```cpp
Float nextCrossingT[3], deltaT[3];
int step[3], voxelLimit[3], voxel[3];
```

#parec[
  For the DDA computations, we will transform the ray to a coordinate system where the grid spans $[0, 1]^3$, giving the ray `rayGrid`. Working in this space simplifies some of the calculations related to the DDA. #footnote[If you are wondering why it is correct to use
the value of <tt>tMin</tt> that was computed using <tt>ray</tt> with
<tt>rayGrid</tt> to find the point <tt>gridIntersect</tt>, review
Section 6.1.4]
][
  对于DDA计算，我们将光线转换到一个网格跨越 $[0, 1]^3$ 的坐标系中，生成光线 `rayGrid`。在这个空间中工作可以简化与DDA相关的一些计算。#footnote[If you are wondering why it is correct to use
the value of <tt>tMin</tt> that was computed using <tt>ray</tt> with
<tt>rayGrid</tt> to find the point <tt>gridIntersect</tt>, review
Section 6.1.4]
]

```cpp
<<Set up 3D DDA for ray through the majorant grid>>=
Vector3f diag = grid->bounds.Diagonal();
Ray rayGrid(Point3f(grid->bounds.Offset(ray.o)),
            Vector3f(ray.d.x / diag.x, ray.d.y / diag.y, ray.d.z / diag.z));
Point3f gridIntersect = rayGrid(tMin);
for (int axis = 0; axis < 3; ++axis) {
    <<Initialize ray stepping parameters for axis>>
}
```

#parec[
  Some of the DDA state values for each dimension are always computed in the same way, while others depend on the sign of the ray's direction in that dimension.
][
  对于每个维度，一些DDA状态值总是以相同的方式计算，而另一些则依赖于光线在该维度方向上的符号。
]

#parec[
  The integer coordinates of the initial voxel are easily found using the grid intersection point. Because it is with respect to the $[0, 1]^3$ cube, all that is necessary is to scale by the resolution in each dimension and take the integer component of that value. It is, however, important to clamp this value to the valid range in case round-off error leads to an out-of-bounds value.
][
  初始体素的整数坐标可以通过网格交点轻松找到。因为它是相对于 $[0, 1]^3$ 立方体的，只需要在每个维度上按分辨率缩放并取该值的整数部分即可。然而，重要的是将该值限制在有效范围内，以防舍入误差导致超出范围的值。
]

#parec[
  Next, `deltaT` is found by dividing the voxel width, which is one over its resolution since we are working in $[0, 1]^3$, by the absolute value of the ray's direction component for the current axis. (The absolute value is taken since $t$ only increases as the DDA visits successive voxels.)
][
  接下来，通过将体素宽度（在 $[0, 1]^3$ 中是其分辨率的倒数）除以光线在当前轴方向上的方向分量的绝对值来计算 `deltaT`。（取绝对值是因为随着DDA访问连续体素， $t$ 只会增加。）
]

#parec[
  Finally, a rare and subtle case related to the IEEE floating-point representation must be handled. Recall that both “positive” and “negative” zero values can be represented as floats. Normally there is no need to distinguish between them, but the fragment after this one will take advantage of the fact that it is legal to compute $1 "div" 0$ in floating point, which gives an infinite value.
][
  最后，必须处理与IEEE浮点数表示相关的一个罕见而微妙的情况。请记住，浮点数可以表示“正零”和“负零”值。通常无需区分它们，但接下来的代码片段将利用一个事实：在浮点数中计算 $1 "div" 0$ 是合法的，并且会返回一个无穷大值。
]

```cpp
voxel[axis] = Clamp(gridIntersect[axis] * grid->res[axis],
                    0, grid->res[axis] - 1);
deltaT[axis] = 1 / (std::abs(rayGrid.d[axis]) * grid->res[axis]);
if (rayGrid.d[axis] == -0.f)
    rayGrid.d[axis] = 0.f;
```



#parec[
  The parametric $t$ value where the ray exits the current voxel, `nextCrossingT[axis]`, is found with the ray-slab intersection algorithm, using the plane that passes through the corresponding voxel face. Given a zero-valued direction component, `nextCrossingT` ends up with the positive floating-point infinity value. The voxel stepping logic will always decide to step in one of the other directions and will correctly never step in this direction.
][
  光线离开当前体素的参数化 $t$ 值 `nextCrossingT[axis]` 是通过光线-平面相交算法计算的，该平面通过相应体素面的中心。当方向分量为零时，`nextCrossingT` 的结果是正浮点无穷大值。体素步进逻辑将始终决定朝其他方向之一迈进，并正确地不会在该方向上步进。
]

#parec[
  For positive directions, rays exit at the upper end of a voxel's extent and therefore advance plus one voxel in each dimension. Traversal completes when the upper limit of the grid is reached.
][
  对于正方向，光线从体素范围的上端离开，因此每个维度向前推进一个体素。当到达网格的上限时，遍历完成。
]

```cpp
Float nextVoxelPos = Float(voxel[axis] + 1) / grid->res[axis];
nextCrossingT[axis] = tMin + (nextVoxelPos - gridIntersect[axis]) /
                        rayGrid.d[axis];
step[axis] = 1;
voxelLimit[axis] = grid->res[axis];
```

#parec[
  Similar expressions give these values for rays with negative direction components.
][
  对于具有负方向分量的光线，类似的表达式用于计算这些值。
]

```cpp
Float nextVoxelPos = Float(voxel[axis]) / grid->res[axis];
nextCrossingT[axis] = tMin + (nextVoxelPos - gridIntersect[axis]) /
                        rayGrid.d[axis];
step[axis] = -1;
voxelLimit[axis] = -1;
```

#parec[
  The `Next()` method takes care of generating the majorant segment for the current voxel and taking a step to the next using the DDA. Traversal terminates when the remaining parametric range $[t_"min", t_"max"]$ is degenerate.
][
  `Next()` 方法负责为当前体素生成主量段，并使用DDA迈向下一个体素。当剩余的参数化范围 $[t_"min", t_"max"]$ 退化时，遍历终止。
]

```cpp
pstd::optional<RayMajorantSegment> Next() {
    if (tMin >= tMax) return {};
    // Find stepAxis for stepping to next voxel and exit point tVoxelExit
    int bits = ((nextCrossingT[0] < nextCrossingT[1]) << 2) +
                ((nextCrossingT[0] < nextCrossingT[2]) << 1) +
                ((nextCrossingT[1] < nextCrossingT[2]));
    const int cmpToAxis[8] = {2, 1, 2, 1, 2, 2, 0, 0};
    int stepAxis = cmpToAxis[bits];
    Float tVoxelExit = std::min(tMax, nextCrossingT[stepAxis]);
    // Get maxDensity for current voxel and initialize RayMajorantSegment, seg
    SampledSpectrum sigma_maj = sigma_t *
                                 grid->Lookup(voxel[0], voxel[1], voxel[2]);
    RayMajorantSegment seg{tMin, tVoxelExit, sigma_maj};
    // Advance to next voxel in maximum density grid
    tMin = tVoxelExit;
    if (nextCrossingT[stepAxis] > tMax) tMin = tMax;
    voxel[stepAxis] += step[stepAxis];
    if (voxel[stepAxis] == voxelLimit[stepAxis]) tMin = tMax;
    nextCrossingT[stepAxis] += deltaT[stepAxis];
    return seg;
}
```

#parec[
  The first order of business when `Next()` executes is to figure out which axis to step along to visit the next voxel. This gives the $t$ value at which the ray exits the current voxel, `tVoxelExit`. Determining this axis requires finding the smallest of three numbers—the parametric $t$ values where the ray enters the next voxel in each dimension. It is possible to compute this index in straight-line code without any branches, which can be beneficial to performance.
][
  当 `Next()` 执行时，首要任务是确定沿哪个轴迈进以访问下一个体素。这会给出光线离开当前体素的 $t$ 值，即 `tVoxelExit`。确定该轴需要找到三个数中的最小值——光线进入每个维度的下一个体素的参数化 $t$ 值。可以通过无分支的直线代码计算此索引，这对性能有益。
]


#parec[
  The following tricky bit of code determines which of the three `nextCrossingT` values is the smallest and sets `stepAxis` accordingly. It encodes this logic by setting each of the three low-order bits in an integer to the results of three comparisons between pairs of `nextCrossingT` values.
][
  以下这段复杂代码确定了三个 `nextCrossingT` 值中最小的一个，并相应地设置 `stepAxis`。它通过将整数的低三位分别设置为三组 `nextCrossingT` 值比较的结果来实现这一逻辑。
]

```cpp
int bits = ((nextCrossingT[0] < nextCrossingT[1]) << 2) +
            ((nextCrossingT[0] < nextCrossingT[2]) << 1) +
            ((nextCrossingT[1] < nextCrossingT[2]));
const int cmpToAxis[8] = {2, 1, 2, 1, 2, 2, 0, 0};
int stepAxis = cmpToAxis[bits];
Float tVoxelExit = std::min(tMax, nextCrossingT[stepAxis]);
```

#parec[
  Computing the majorant for the current voxel is a matter of multiplying `sigma_t` with the maximum density value over the voxel's volume.
][
  计算当前体素的主量是通过将 `sigma_t` 乘以该体素体积上的最大密度值实现的。
]

```cpp
SampledSpectrum sigma_maj = sigma_t *
                             grid->Lookup(voxel[0], voxel[1], voxel[2]);
RayMajorantSegment seg{tMin, tVoxelExit, sigma_maj};
```

#parec[
  With the majorant segment initialized, the method finishes by updating the `DDAMajorantIterator`'s state to reflect stepping to the next voxel in the ray's path. That is easy to do given that the `stepAxis` is set to the dimension with the smallest $t$ step that advances to the next voxel. First, `tMin` is tentatively set to correspond to the current voxel's exit point, though if stepping causes the ray to exit the grid, it is advanced to `tMax`. This way, the `if` test at the start of the `Next()` method will return immediately the next time it is called.
][
  在初始化主量段后，该方法通过更新 `DDAMajorantIterator` 的状态来完成操作，以反映光线路径中迈向下一个体素的步进。由于 `stepAxis` 被设置为具有最小 $t$ 步长并推进到下一个体素的维度，这一点很容易实现。首先，`tMin` 被暂时设置为当前体素的出口点，如果步进导致光线退出网格，则将其推进到 `tMax`。这样，在下一次调用 `Next()` 方法时，开头的 `if` 测试会立即返回。
]

#parec[
  Otherwise, the DDA steps to the next voxel coordinates and increments the chosen direction's `nextCrossingT` by its `deltaT` value so that future traversal steps will know how far it is necessary to go before stepping in this direction again.
][
  否则，DDA 将步进到下一个体素坐标，并将选定方向的 `nextCrossingT` 增加其 `deltaT` 值，以便未来的遍历步骤能够知道在该方向上再次步进之前需要前进多远。
]

```cpp
tMin = tVoxelExit;
if (nextCrossingT[stepAxis] > tMax) tMin = tMax;
voxel[stepAxis] += step[stepAxis];
if (voxel[stepAxis] == voxelLimit[stepAxis]) tMin = tMax;
nextCrossingT[stepAxis] += deltaT[stepAxis];
```


#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f19.svg"),
  caption: [
    #ez_caption[
      *Rendering Performance versus Maximum Density Grid Resolution. *Performance is measured when rendering the cloud model in @fig:cloud-inscattering on both the CPU and the GPU; results are normalized to the performance on the corresponding processor with a single-voxel grid. Low-resolution grids give poor performance from many null-scattering events due to loose majorants, while high-resolution grids harm performance from grid traversal overhead.
    ][
      *渲染性能与最大密度网格分辨率的关系。* 在CPU和GPU上渲染@fig:cloud-inscattering 的云模型时测量性能；结果被归一化为在单体素网格上相应处理器的性能。低分辨率网格由于松散的主量导致了许多无散射事件，从而性能较差，而高分辨率网格由于网格遍历的开销导致性能下降。
    ]
  ],
)<max-density-grid-perf>

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f20.svg"),
  caption: [
    #ez_caption[
      *  Extinction Coefficient and Majorant along a Ray.*
      These quantities are plotted for a randomly selected ray that was traced when rendering the image in @fig:cloud-inscattering. The majorant grid resolution was 256 voxels on a side, which leads to a good fit to the actual extinction coefficient along the ray.
    ][
      * 沿光线的消光系数和主量。*这些量是为渲染@fig:cloud-inscattering 的图像时跟踪的随机选择光线绘制的。主量网格的分辨率是每侧256个体素，这使得主量很好地拟合了沿光线的实际消光系数。
    ]
  ],
)<ray-density-majorant>

#parec[
  Although the grid can significantly improve the efficiency of volume sampling by providing majorants that are a better fit to the local medium density and thence reducing the number of null-scattering events, it also introduces the overhead of additional computations for stepping through voxels with the DDA. Too low a grid resolution and the majorants may not fit the volume well; too high a resolution and too much time will be spent walking through the grid. @fig:max-density-grid-perf has a graph that illustrates these trade-offs, plotting voxel grid resolution versus execution time when rendering the cloud model used in @fig:cloud-absorption and @fig:cloud-inscattering. We can see that the performance characteristics are similar on both the CPU and the GPU, with both exhibiting good performance with grid resolutions that span roughly 64 through 256 voxels on a side. @fig:ray-density-majorant shows the extinction coefficient and the majorant along a randomly selected ray that was traced when rendering the cloud scene; we can see that the majorants end up fitting the extinction coefficient well.
][
  尽管网格可以通过提供更适合局部介质密度的主量来显著提高体采样的效率，从而减少无散射事件的数量，但它也引入了使用DDA遍历体素时的额外计算开销。网格分辨率过低时，主量可能无法很好地拟合体积；分辨率过高时，则会在网格遍历上花费过多时间。@fig:max-density-grid-perf 显示了一张图表，说明了这些权衡关系，绘制了渲染@fig:cloud-absorption 和@fig:cloud-inscattering 中使用的云模型时体素网格分辨率与执行时间之间的关系。可以看到，在CPU和GPU上，性能特性是相似的，分辨率在每侧大约64到256个体素之间时性能表现良好。@fig:ray-density-majorant 展示了渲染云场景时跟踪的一条随机选定光线沿途的消光系数和主量；可以看出，主量最终很好地拟合了消光系数。
]
=== Uniform Grid Medium
<uniform-grid-medium>
#parec[
  The #link("<GridMedium>")[GridMedium] stores medium densities and (optionally) emission at a regular 3D grid of positions, similar to the way that the image textures represent images with a 2D grid of samples.
][
  "网格介质"在一个规则的三维网格位置上存储介质密度和（可选的）辐射，类似于图像纹理用二维网格样本表示图像的方式。
]

```cpp
<<GridMedium Definition>>=
class GridMedium {
  public:
    <<GridMedium Public Type Definitions>>
    <<GridMedium Public Methods>>
  private:
    <<GridMedium Private Members>>
};
```


#parec[
  The constructor takes a 3D array that stores the medium's density and values that define emission as well as the medium space bounds of the grid and a transformation matrix that goes from medium space to rendering space. Most of its work is direct initialization of member variables, which we have elided here. Its one interesting bit is in the fragment `<<Initialize majorantGrid for GridMedium>>`, which we will see in a few pages.
][
  构造函数接收一个存储介质密度的三维数组，以及定义辐射值的参数、网格在介质空间中的边界和一个从介质空间到渲染空间的变换矩阵。构造函数的大部分工作是直接初始化成员变量，这里已省略。它唯一有趣的部分是在片段 `<<Initialize majorantGrid for GridMedium>>` 中，这将在接下来的几页中看到。
]


```cpp
<<GridMedium Private Members>>=
Bounds3f bounds;
Transform renderFromMedium;
```


#parec[
  Two steps give the $sigma_a$ and $sigma_s$ values for the medium at a point: first, baseline spectral values of these coefficients, `sigma_a_spec` and `sigma_s_spec`, are sampled at the specified wavelengths to give #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] values for them. These are then scaled by the interpolated density from `densityGrid`. The phase function in this medium is uniform and parameterized only by the Henyey–Greenstein $g$ parameter.
][
  给定点的介质的 $sigma_a$ and $sigma_s$ 值通过两个步骤获得：首先，这些系数的基线光谱值 `sigma_a_spec` 和 `sigma_s_spec` 在指定波长上采样，得到它们的采样光谱值。然后通过 `densityGrid` 的插值密度进行缩放。该介质中的相位函数是均匀的，仅由 Henyey–Greenstein $g$ 参数参数化。
]

```cpp
<<GridMedium Private Members>>+=
DenselySampledSpectrum sigma_a_spec, sigma_s_spec;
SampledGrid<Float> densityGrid;
HGPhaseFunction phase;
```

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/anemone-emission.png"),
  caption: [
    #ez_caption[
      Volumetric Emission Specified with a Spectrum. The emission inside
      the globe is specified using a fixed spectrum that represents a
      purple color that is then scaled by a spatially varying factor.
      (Scene courtesy of Jim Price.)
    ][
      通过光谱指定的体积辐射。球体内部的辐射使用固定光谱指定，该光谱表示紫色，然后通过空间变化因子缩放。（场景由
      Jim Price 提供。）
    ]
  ],
)<globe-emission>



#parec[
  The `GridMedium` allows volumetric emission to be specified in one of two ways. First, a grid of temperature values may be provided; these are interpreted as blackbody emission temperatures specified in degrees Kelvin @blackbody-emitters)). Alternatively, a single general spectral distribution may be provided. Both are then scaled by values from the `LeScale` grid. Even though spatially varying general spectral distributions are not supported, these representations make it possible to specify a variety of emissive effects; @fig:explosion-emission) uses blackbody emission and @fig:globe-emission) uses a scaled spectrum. An exercise at the end of the chapter outlines how this representation might be generalized.
][
  `GridMedium` 允许以两种方式之一来指定体积发射。首先，可以提供一个温度值网格；这些温度被解释为以开尔文为单位的黑体发射温度（参见@blackbody-emitters) 节）。或者，也可以提供一个通用的光谱分布。然后，这两种方式都通过 `LeScale` 网格中的值进行缩放。尽管不支持空间变化的通用光谱分布，这些表示仍然可以用来指定各种发射效果；@fig:explosion-emission 使用了黑体发射，而@fig:globe-emission 使用了缩放的光谱。本章末尾的练习介绍了如何将这种表示进行泛化。
]

```cpp
**<GridMedium Private Members>**+=
pstd::optional<SampledGrid<Float>> temperatureGrid;
DenselySampledSpectrum Le_spec;
SampledGrid<Float> LeScale;
```

#parec[
  A Boolean, `isEmissive`, indicates whether any emission has been specified. It is initialized in the `GridMedium` constructor, which makes the implementation of the `IsEmissive()` interface method easy.
][
  一个布尔变量 `isEmissive` 指示是否已指定发射。这在 `GridMedium` 构造函数中初始化，从而使 `IsEmissive()` 接口方法的实现变得简单。
]

```cpp
**<GridMedium Public Methods>**=
bool IsEmissive() const { return isEmissive; }
```

#parec[
  The medium's properties at a given point are found by interpolating values from the appropriate grids.
][
  介质在给定点的属性通过从相应的网格插值获得。
]

```cpp
**<GridMedium Public Methods>**+=
MediumProperties SamplePoint(Point3f p,
                             const SampledWavelengths &lambda) const {
    **Sample spectra for grid medium $\sigma_a$ and $\sigma_s$**
    SampledSpectrum sigma_a = sigma_a_spec.Sample(lambda);
    SampledSpectrum sigma_s = sigma_s_spec.Sample(lambda);

    **Scale scattering coefficients by medium density at p**
    p = renderFromMedium.ApplyInverse(p);
    p = Point3f(bounds.Offset(p));
    Float d = densityGrid.Lookup(p);
    sigma_a *= d;
    sigma_s *= d;

    **Compute grid emission $L_e$ at p**
    SampledSpectrum Le(0.f);
    if (isEmissive) {
        Float scale = LeScale.Lookup(p);
        if (scale > 0) {
            **Compute emitted radiance using temperatureGrid or $L_e$-spec**
            if (temperatureGrid) {
                Float temp = temperatureGrid->Lookup(p);
                Le = scale * BlackbodySpectrum(temp).Sample(lambda);
            } else
                Le = scale * Le_spec.Sample(lambda);
        }
    }
    return MediumProperties{sigma_a, sigma_s, &phase, Le};
}
```


#parec[
  Initial values of $sigma_a$ and $sigma_s$ are found by sampling the baseline values.
][
  $sigma_a$ 和 $sigma_s$ 的初始值是通过对基线值进行采样获得的。
]

```cpp
**<Sample spectra for grid medium $\sigma_a$ and $\sigma_s$>**=
SampledSpectrum sigma_a = sigma_a_spec.Sample(lambda);
SampledSpectrum sigma_s = sigma_s_spec.Sample(lambda);
```

#parec[
  Next, $sigma_a$ and $sigma_s$ are scaled by the interpolated density at `p`. The provided point must be transformed from rendering space to the medium's space and then remapped to $[0, 1]^3$ before the grid's `Lookup()` method is called to interpolate the density.
][
  接下来， $sigma_a$ 和 $sigma_s$ 按 `p` 点的插值密度进行缩放。在调用网格的 `Lookup()` 方法进行密度插值之前，必须将提供的点从渲染空间转换到介质空间，然后重新映射到 $[0, 1]^3$。
]

```cpp
**<Scale scattering coefficients by medium density at p>**=
p = renderFromMedium.ApplyInverse(p);
p = Point3f(bounds.Offset(p));
Float d = densityGrid.Lookup(p);
sigma_a *= d;
sigma_s *= d;
```

#parec[
  If emission is present, the emitted radiance at the point is computed using whichever of the methods was used to specify it. The implementation here goes through some care to avoid calls to `Lookup()` when they are unnecessary, in order to improve performance.
][
  如果存在发射，则使用指定发射的任何一种方法计算该点的辐射亮度。此实现经过精心设计以避免在不必要时调用 `Lookup()`，以提高性能。
]

```cpp
**<Compute grid emission $L_e$ at p>**=
SampledSpectrum Le(0.f);
if (isEmissive) {
    Float scale = LeScale.Lookup(p);
    if (scale > 0) {
        **Compute emitted radiance using temperatureGrid or $L_e$-spec**
        if (temperatureGrid) {
            Float temp = temperatureGrid->Lookup(p);
            Le = scale * BlackbodySpectrum(temp).Sample(lambda);
        } else
            Le = scale * Le_spec.Sample(lambda);
    }
}
```

#parec[
  Given a nonzero `scale`, whichever method is being used to specify emission is queried to get the `SampledSpectrum` .
][
  对于非零的 `scale`，将查询用于指定发射的任一方法，以获取 `SampledSpectrum` 。
]

```cpp
**<Compute emitted radiance using temperatureGrid or $L_e$-spec>**=
if (temperatureGrid) {
    Float temp = temperatureGrid->Lookup(p);
    Le = scale * BlackbodySpectrum(temp).Sample(lambda);
} else
    Le = scale * Le_spec.Sample(lambda);
```

#parec[
  As mentioned earlier, `GridMedium` uses `DDAMajorantIterator` to provide its majorants rather than using a single grid-wide majorant.
][
  如前所述，`GridMedium` uses `DDAMajorantIterator` 提供其主量，而不是使用单一的全网格主量。
]

```cpp
**<GridMedium Public Type Definitions>**=
using MajorantIterator = DDAMajorantIterator;
```
#parec[
  The `GridMedium` constructor concludes with the following fragment, which initializes a `MajorantGrid` with its majorants. Doing so is just a matter of iterating over all the majorant cells, computing their bounds, and finding the maximum density over them. The maximum density is easily found with a convenient `SampledGrid` method.
][
  `GridMedium` 的构造函数以以下片段结束，该片段用主量初始化 `MajorantGrid`。这只是遍历所有主量单元，计算其边界，并找到它们的最大密度。使用方便的 `SampledGrid` 方法可以轻松找到最大密度。
]

```cpp
**<Initialize majorantGrid for GridMedium>**=
for (int z = 0; z < majorantGrid.res.z; ++z)
    for (int y = 0; y < majorantGrid.res.y; ++y)
        for (int x = 0; x < majorantGrid.res.x; ++x) {
            Bounds3f bounds = majorantGrid.VoxelBounds(x, y, z);
            majorantGrid.Set(x, y, z, densityGrid.MaxValue(bounds));
        }
```

```cpp
MajorantGrid majorantGrid;
```

#parec[
  The implementation of the `SampleRay()` `Medium` interface method is now easy. We can find the overlap of the ray with the medium using a straightforward fragment, not included here, and compute the baseline $sigma_t$ value. With that, we have enough information to initialize the `DDAMajorantIterator`.
][
  现在，实现 `SampleRay()` 的 `Medium` 接口方法变得很简单。我们可以使用一个简单的代码片段（此处未包含）找到光线与介质的重叠部分，并计算基线 $sigma_t$ 值。基于此，我们拥有足够的信息来初始化 `DDAMajorantIterator`。
]

```cpp
<<GridMedium Public Methods>>+=
DDAMajorantIterator SampleRay(Ray ray, Float raytMax,
                              const SampledWavelengths &lambda) const {
    <<Transform ray to medium’s space and compute bounds overlap>>
    <<Sample spectra for grid medium  and >>
    SampledSpectrum sigma_t = sigma_a + sigma_s;
    return DDAMajorantIterator(ray, tMin, tMax, &majorantGrid, sigma_t);
}
```

=== RGB Grid Medium

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f22.svg"),
  caption: [
    #ez_caption[
      Volumetric Scattering Properties Specified Using RGB Coefficients. The RGBGridMedium class makes it possible to specify colorful participating media like the example shown here. (Scene courtesy of Jim Price.)
    ][
      Volumetric Scattering Properties Specified Using RGB Coefficients. The RGBGridMedium class makes it possible to specify colorful participating media like the example shown here. (Scene courtesy of Jim Price.)
    ]
  ],
)<rgb-medium-plumes>

#parec[
  The last `Medium` implementation that we will describe is the #link("<RGBGridMedium>")[`RGBGridMedium`];. It is a variant of #link("<GridMedium>")[`GridMedium`] that allows specifying the absorption and scattering coefficients as well as volumetric emission via RGB colors. This makes it possible to render a variety of colorful volumetric effects; an example is shown in Figure @fig:rgb-medium-plumes .
][
  我们将描述的最后一个`Medium`实现是#link("<RGBGridMedium>")[`RGBGridMedium`];。它是#link("<GridMedium>")[`GridMedium`];的一个变体，允许通过RGB颜色指定吸收和散射系数以及体积辐射。这使得渲染各种多彩的体积效果成为可能；@fig:rgb-medium-plumes 展示了一个例子。
]


```cpp
class RGBGridMedium {
  public:
    using MajorantIterator = DDAMajorantIterator;
    RGBGridMedium(const Bounds3f &bounds, const Transform &renderFromMedium,
                  Float g,
                  pstd::optional<SampledGrid<RGBUnboundedSpectrum>> sigma_a,
                  pstd::optional<SampledGrid<RGBUnboundedSpectrum>> sigma_s,
                  Float sigmaScale,
                  pstd::optional<SampledGrid<RGBIlluminantSpectrum>> Le,
                  Float LeScale, Allocator alloc);

       static RGBGridMedium *Create(const ParameterDictionary &parameters,
                                    const Transform &renderFromMedium,
                                    const FileLoc *loc, Allocator alloc);

       std::string ToString() const;
       bool IsEmissive() const { return LeGrid && LeScale > 0; }
       MediumProperties SamplePoint(Point3f p,
                                    const SampledWavelengths &lambda) const {
           p = renderFromMedium.ApplyInverse(p);
           p = Point3f(bounds.Offset(p));
           // Compute σ_a and σ_s for RGBGridMedium
           auto convert = [=] (RGBUnboundedSpectrum s) { return s.Sample(lambda); };
           SampledSpectrum sigma_a = sigmaScale *
               (sigma_aGrid ? sigma_aGrid->Lookup(p, convert) : SampledSpectrum(1.f));
           SampledSpectrum sigma_s = sigmaScale *
               (sigma_sGrid ? sigma_sGrid->Lookup(p, convert) : SampledSpectrum(1.f));
           // Find emitted radiance Le for RGBGridMedium
           SampledSpectrum Le(0.f);
           if (LeGrid && LeScale > 0) {
               auto convert =
                 [=] (RGBIlluminantSpectrum s) { return s.Sample(lambda); };
               Le = LeScale * LeGrid->Lookup(p, convert);
           }
           return MediumProperties{sigma_a, sigma_s, &phase, Le};
       }
       DDAMajorantIterator SampleRay(Ray ray, Float raytMax,
                                     const SampledWavelengths &lambda) const {
           // Transform ray to medium’s space and compute bounds overlap
           ray = renderFromMedium.ApplyInverse(ray, &raytMax);
           Float tMin, tMax;
           if (!bounds.IntersectP(ray.o, ray.d, raytMax, &tMin, &tMax))
               return {};

           SampledSpectrum sigma_t(1);
           return DDAMajorantIterator(ray, tMin, tMax, &majorantGrid, sigma_t);
       }
  private:
    // RGBGridMedium Private Members
    Bounds3f bounds;
    Transform renderFromMedium;
    pstd::optional<SampledGrid<RGBIlluminantSpectrum>> LeGrid;
    Float LeScale;
    HGPhaseFunction phase;
    pstd::optional<SampledGrid<RGBUnboundedSpectrum>> sigma_aGrid, sigma_sGrid;
    Float sigmaScale;
    MajorantGrid majorantGrid;
};
```


#parec[
  Its constructor, not included here, is similar to that of #link("<GridMedium>")[`GridMedium`] in that most of what it does is to directly initialize member variables with values passed to it. As with #link("<GridMedium>")[`GridMedium`];, the medium's extent is jointly specified by a medium space bounding box and a transformation from medium space to rendering space.
][
  其构造函数（未包含在此）与#link("<GridMedium>")[`GridMedium`];的构造函数类似，因为它主要是直接用传递给它的值初始化成员变量。与#link("<GridMedium>")[`GridMedium`];一样，介质的范围由介质空间边界框和从介质空间到渲染空间的变换共同指定。
]


```cpp
Bounds3f bounds;
Transform renderFromMedium;
```


#parec[
  Emission is specified by the combination of an optional #link("../Utilities/Containers_and_Memory_Management.html#SampledGrid")[`SampledGrid`] of #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBIlluminantSpectrum")[`RGBIlluminantSpectrum`] values and a scale factor. The #link("<RGBGridMedium>")[`RGBGridMedium`] reports itself as emissive if the grid is present and the scale is nonzero. This misses the case of a fully zero `LeGrid`, though we assume that case to be unusual.
][
  发射由可选的#link("../Utilities/Containers_and_Memory_Management.html#SampledGrid")[`SampledGrid`];的#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBIlluminantSpectrum")[`RGBIlluminantSpectrum`];值和一个比例因子的组合指定。如果网格存在且比例非零，#link("<RGBGridMedium>")[`RGBGridMedium`];将报告自己为发光体。不过，这没有考虑到`LeGrid`完全为零的情况，尽管我们假设这种情况是不常见的。
]


```cpp
bool IsEmissive() const { return LeGrid && LeScale > 0; }
```

```cpp
pstd::optional<SampledGrid<RGBIlluminantSpectrum>> LeGrid;
Float LeScale;
```

#parec[
  Sampling the medium at a point is mostly a matter of converting the various RGB values to #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] values and trilinearly interpolating them to find their values at the lookup point `p`.
][
  在一个点采样介质主要是将各种RGB值转换为#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];值并对它们进行三线性插值以找到它们在查找点`p`的值。
]


```cpp
MediumProperties SamplePoint(Point3f p,
                             const SampledWavelengths &lambda) const {
    p = renderFromMedium.ApplyInverse(p);
    p = Point3f(bounds.Offset(p));
    // Compute σ_a and σ_s for RGBGridMedium
    auto convert = [=] (RGBUnboundedSpectrum s) { return s.Sample(lambda); };
    SampledSpectrum sigma_a = sigmaScale *
        (sigma_aGrid ? sigma_aGrid->Lookup(p, convert) : SampledSpectrum(1.f));
    SampledSpectrum sigma_s = sigmaScale *
        (sigma_sGrid ? sigma_sGrid->Lookup(p, convert) : SampledSpectrum(1.f));
    // Find emitted radiance Le for RGBGridMedium
    SampledSpectrum Le(0.f);
    if (LeGrid && LeScale > 0) {
        auto convert =
          [=] (RGBIlluminantSpectrum s) { return s.Sample(lambda); };
        Le = LeScale * LeGrid->Lookup(p, convert);
    }
    return MediumProperties{sigma_a, sigma_s, &phase, Le};
}
```


#parec[
  As with earlier `Medium` implementations, the phase function is uniform throughout this medium.
][
  与早期的`Medium`实现一样，相位函数在整个介质中是均匀的。
]

```cpp
HGPhaseFunction phase;
```


#parec[
  The absorption and scattering coefficients are stored using the #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`] class. However, this class does not support the arithmetic operations that are necessary to perform trilinear interpolation in the #link("../Utilities/Containers_and_Memory_Management.html#SampledGrid::Lookup")[`SampledGrid::Lookup()`] method. For such cases, #link("../Utilities/Containers_and_Memory_Management.html#SampledGrid")[`SampledGrid`] allows passing a callback function that converts the in-memory values to another type that does support them. Here, the implementation provides one that converts to #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];, which does allow arithmetic and matches the type to be returned in #link("<MediumProperties>")[`MediumProperties`] as well.
][
  吸收和散射系数使用#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`];类存储。然而，该类不支持在#link("../Utilities/Containers_and_Memory_Management.html#SampledGrid::Lookup")[`SampledGrid::Lookup()`];方法中执行三线性插值所需的算术操作。对于这种情况，#link("../Utilities/Containers_and_Memory_Management.html#SampledGrid")[`SampledGrid`];允许传递一个回调函数，将内存中的值转换为支持这些操作的另一种类型。在这里，实现提供了一个转换为#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];的函数，该函数允许算术运算并匹配要在#link("<MediumProperties>")[`MediumProperties`];中返回的类型。
]

```cpp
auto convert = [=] (RGBUnboundedSpectrum s) { return s.Sample(lambda); };
SampledSpectrum sigma_a = sigmaScale *
    (sigma_aGrid ? sigma_aGrid->Lookup(p, convert) : SampledSpectrum(1.f));
SampledSpectrum sigma_s = sigmaScale *
    (sigma_sGrid ? sigma_sGrid->Lookup(p, convert) : SampledSpectrum(1.f));
```


#parec[
  Because `sigmaScale` is applied to both $sigma_a$ and $sigma_s$ , it provides a convenient way to fine-tune the density of a medium without needing to update all of its individual RGB values.
][
  因为`sigmaScale`同时应用于 $sigma_a$ 和 $sigma_s$，它提供了一种方便的方法来微调介质的密度，而无需更新其所有单独的RGB值。
]



```cpp
pstd::optional<SampledGrid<RGBUnboundedSpectrum>> sigma_aGrid, sigma_sGrid;
Float sigmaScale;
```

#parec[
  Volumetric emission is handled similarly, with a lambda function that converts the #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBIlluminantSpectrum")[`RGBIlluminantSpectrum`] values to #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];s for trilinear interpolation in the `Lookup()` method.
][
  体积辐射以类似的方式处理，使用一个lambda函数将#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBIlluminantSpectrum")[`RGBIlluminantSpectrum`];值转换为#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];以在`Lookup()`方法中进行三线性插值。
]


```cpp
SampledSpectrum Le(0.f);
if (LeGrid && LeScale > 0) {
    auto convert =
      [=] (RGBIlluminantSpectrum s) { return s.Sample(lambda); };
    Le = LeScale * LeGrid->Lookup(p, convert);
}
```

#parec[
  The #link("<DDAMajorantIterator>")[`DDAMajorantIterator`] provides majorants for the `RGBGridMedium` as well.
][
  #link("<DDAMajorantIterator>")[`DDAMajorantIterator`];也为`RGBGridMedium`提供了主值。
]


```cpp
using MajorantIterator = DDAMajorantIterator;
```


#parec[
  The #link("<MajorantGrid>")[`MajorantGrid`] that is used by the #link("<DDAMajorantIterator>")[`DDAMajorantIterator`] is initialized by the following fragment, which runs at the end of the #link("<RGBGridMedium>")[`RGBGridMedium`] constructor.
][
  #link("<DDAMajorantIterator>")[`DDAMajorantIterator`];使用的#link("<MajorantGrid>")[`MajorantGrid`];通过以下片段初始化，该片段在#link("<RGBGridMedium>")[`RGBGridMedium`];构造函数的末尾运行。
]


```cpp
for (int z = 0; z < majorantGrid.res.z; ++z)
    for (int y = 0; y < majorantGrid.res.y; ++y)
        for (int x = 0; x < majorantGrid.res.x; ++x) {
            Bounds3f bounds = majorantGrid.VoxelBounds(x, y, z);
            // Initialize majorantGrid voxel for RGB σ_a and σ_s
            auto max = [] (RGBUnboundedSpectrum s) { return s.MaxValue(); };
            Float maxSigma_t = (sigma_aGrid ? sigma_aGrid->MaxValue(bounds, max) : 1) +
                               (sigma_sGrid ? sigma_sGrid->MaxValue(bounds, max) : 1);
            majorantGrid.Set(x, y, z, sigmaScale * maxSigma_t);
        }
```


#parec[
  Before explaining how the majorant grid voxels are initialized, we will discuss why #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`] values are stored in `rgbDensityGrid` rather than the more obvious choice of #link("../Radiometry,_Spectra,_and_Color/Color.html#RGB")[`RGB`] values. The most important reason is that the RGB to spectrum conversion approach from Section @from-rgb-to-specturm does not guarantee that the spectral distribution's value will always be less than or equal to the maximum of the original RGB components. Thus, storing RGB and setting majorants using bounds on RGB values would not give bounds on the eventual #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] values that are computed.
][
  在解释如何初始化主值网格体素之前，我们将讨论为什么在`rgbDensityGrid`中存储#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`];值，而不是更明显的#link("../Radiometry,_Spectra,_and_Color/Color.html#RGB")[`RGB`];值。最重要的原因是，@from-rgb-to-specturm 的RGB到光谱转换方法不保证光谱分布的值总是小于或等于原始RGB分量的最大值。因此，存储RGB并使用RGB值的界限设置主值将无法提供最终计算的#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];值的界限。
]

#parec[
  One might nevertheless try to store RGB, convert those RGB values to spectra when initializing the majorant grid, and then bound those spectra to find majorants. That approach would also be unsuccessful, since when two RGB values are linearly interpolated, the corresponding #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`] does not vary linearly between the #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`] distributions of the two original RGB values.
][
  尽管如此，有人可能会尝试存储RGB，在初始化主值网格时将这些RGB值转换为光谱，然后对这些光谱进行界限以找到主值。该方法也不会成功，因为当两个RGB值线性插值时，相应的#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`];不会在两个原始RGB值的#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`];分布之间线性变化。
]

#parec[
  Thus, `RGBGridMedium` stores #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`] values at the grid sample points and linearly interpolates their #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] values at lookup points. With that approach, we can guarantee that bounds on #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`] values in a region of space (and then a bit more, given trilinear interpolation) give bounds on the sampled spectral values that are returned by #link("../Utilities/Containers_and_Memory_Management.html#SampledGrid::Lookup")[`SampledGrid::Lookup()`] in the `SamplePoint()` method, fulfilling the requirement for the majorant grid.
][
  因此，`RGBGridMedium`在网格采样点存储#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`];值，并在查找点线性插值其#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];值。通过这种方法，我们可以确保在空间区域内的#link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[`RGBUnboundedSpectrum`];值的界限（然后再加上一点，考虑到三线性插值）提供了由`SamplePoint()`方法中的#link("../Utilities/Containers_and_Memory_Management.html#SampledGrid::Lookup")[`SampledGrid::Lookup()`];返回的采样光谱值的界限，从而满足主值网格的要求。
]

#parec[
  To compute the majorants, we use a #link("../Utilities/Containers_and_Memory_Management.html#SampledGrid")[`SampledGrid`] method that returns its maximum value over a region of space and takes a lambda function that converts its underlying type to another—here, `Float` for the #link("<MajorantGrid>")[`MajorantGrid`];.
][
  为了计算主值，我们使用#link("../Utilities/Containers_and_Memory_Management.html#SampledGrid")[`SampledGrid`];方法，该方法返回其在空间区域内的最大值，并使用一个lambda函数将其底层类型转换为另一种类型——在这里是#link("<MajorantGrid>")[`MajorantGrid`];的`Float`。
]

#parec[
  One nit in how the majorants are computed is that the following code effectively assumes that the values in the $sigma_a$ and $sigma_s$ grids are independent. Although it computes a valid majorant, it is unable to account for cases like the two being defined such that $sigma_s = c - sigma_a$ for some constant $c$. Then, the bound will be looser than it could be.
][
  计算主值的一点小问题是，以下代码有效地假设 $sigma_a$ 和 $sigma_s$ 网 格 中 的 值 是 独 立 的 。 虽 然 它 计 算 了 一 个 有 效 的 主 值 ， 但 无 法 处 理 像 $sigma_s = c - sigma_a$ 这 种 情 况 （ 其 中 $c$ 为常数）。
]



```cpp
auto max = [] (RGBUnboundedSpectrum s) { return s.MaxValue(); };
Float maxSigma_t = (sigma_aGrid ? sigma_aGrid->MaxValue(bounds, max) : 1) +
                   (sigma_sGrid ? sigma_sGrid->MaxValue(bounds, max) : 1);
majorantGrid.Set(x, y, z, sigmaScale * maxSigma_t);
```


```cpp
MajorantGrid majorantGrid;
```

#parec[
  With the majorant grid initialized, the `SampleRay()` method's implementation is trivial. (See Exercise 11.3 for a way in which it might be improved, however.)
][
  在主值网格初始化后，`SampleRay()`方法的实现变得相对简单。（参见练习11.3，了解可能的改进方法。）
]


```cpp
DDAMajorantIterator SampleRay(Ray ray, Float raytMax,
                              const SampledWavelengths &lambda) const {
    // Transform ray to medium’s space and compute bounds overlap
    ray = renderFromMedium.ApplyInverse(ray, &raytMax);
    Float tMin, tMax;
    if (!bounds.IntersectP(ray.o, ray.d, raytMax, &tMin, &tMax))
        return {};

    SampledSpectrum sigma_t(1);
    return DDAMajorantIterator(ray, tMin, tMax, &majorantGrid, sigma_t);
}
```
