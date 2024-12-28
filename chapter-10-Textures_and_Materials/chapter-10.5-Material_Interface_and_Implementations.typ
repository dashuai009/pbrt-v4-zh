#import "../template.typ": parec, ez_caption

== Material Interface and Implementations
<material-interface-and-implementations>
#parec[
  With a variety of textures available, we will turn to materials, first introducing the material interface and then a few material implementations. `pbrt`'s materials all follow a similar form, evaluating textures to get parameter values that are used to initialize their particular BSDF model. Therefore, we will only include a few of their implementations in the text here.
][
  在提供多种纹理的情况下，我们将探讨材质，首先介绍材质接口，然后介绍一些材质的实现。`pbrt`的材质都遵循类似的形式，通过评估纹理来获取用于初始化其特定BSDF模型的参数值。因此，我们这里只会包含它们的一些实现。
]

#parec[
  The `Material` interface is defined by the `Material` class, which can be found in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/material.h")[base/material.h];. `pbrt` includes the implementations of 11 materials; these are enough that we have collected all of their type names in a fragment that is not included in the text.
][
  `Material`接口由`Material`类定义，可以在文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/material.h")[base/material.h];中找到。`pbrt`包括了11种材质的实现，这些足以让我们在一个未包含在文本中的片段中收集它们所有的类型名称。
]

```cpp
class Material : public TaggedPointer<<<Material Types>>>  CoatedDiffuseMaterial, CoatedConductorMaterial,
        ConductorMaterial, DielectricMaterial,
        DiffuseMaterial, DiffuseTransmissionMaterial, HairMaterial,
        MeasuredMaterial, SubsurfaceMaterial,
        ThinDielectricMaterial, MixMaterial {
  public:
    <<Material Interface>>  using TaggedPointer::TaggedPointer;

       static Material Create(
           const std::string &name, const TextureParameterDictionary &parameters, Image *normalMap,
           /*const */ std::map<std::string, Material> &namedMaterials,
           const FileLoc *loc, Allocator alloc);

       std::string ToString() const;
       template <typename TextureEvaluator>
       inline
       BSDF GetBSDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                    SampledWavelengths &lambda, ScratchBuffer &buf) const;
       template <typename TextureEvaluator>
       BSSRDF GetBSSRDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                        SampledWavelengths &lambda, ScratchBuffer &buf) const;
       template <typename TextureEvaluator>
       bool CanEvaluateTextures(TextureEvaluator texEval) const;
       const Image *GetNormalMap() const;
       FloatTexture GetDisplacement() const;
       bool HasSubsurfaceScattering() const;
};
```

#parec[
  One of the most important methods that #link("<Material>")[Material] implementations must provide is `GetBxDF()`. It has the following signature:
][
  #link("<Material>")[Material];实现必须提供的最重要的方法之一是`GetBxDF()`。它具有以下签名：
]

```cpp
template <typename TextureEvaluator>
ConcreteBxDF GetBxDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                     SampledWavelengths &lambda) const;
```
#parec[
  There are a few things to notice in its declaration. First, it is templated based on a type `TextureEvaluator`. This class is used by materials to, unsurprisingly, evaluate their textures. We will discuss it further in a page or two, as well as #link("<MaterialEvalContext>")[`MaterialEvalContext`];, which serves a similar role to #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`];.
][
  在其声明中有几点需要注意。首先，它是基于类型`TextureEvaluator`的模板。材质使用此类来评估其纹理。我们将在一两页后讨论它，以及#link("<MaterialEvalContext>")[`MaterialEvalContext`];，它与#link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`];起到类似的作用。
]

#parec[
  Most importantly, note the return type, `ConcreteBxDF`. This type is specific to each `Material` and should be replaced with the actual #link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`] type that the material uses. (For example, the #link("<DiffuseMaterial>")[`DiffuseMaterial`] returns a #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];.) Different materials thus have different signatures for their `GetBxDF()` methods. This is unusual for an interface method in C++ and is not usually allowed with regular C++ virtual functions, though we will see shortly how `pbrt` handles the variety of them.
][
  最重要的是，注意返回类型`ConcreteBxDF`。此类型特定于每个`Material`，应替换为材质使用的实际#link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`];类型。（例如，#link("<DiffuseMaterial>")[`DiffuseMaterial`];返回#link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];。）因此，不同的材质对其`GetBxDF()`方法有不同的签名。这在C++接口方法中是不常见的，通常不允许使用常规C++虚函数，但我们将很快看到`pbrt`如何处理它们的多样性。
]

#parec[
  Each `Material` is also responsible for defining the type of `BxDF` that it returns from its `GetBxDF()` method with a local type definition for the type `BxDF`. For example, #link("<DiffuseMaterial>")[DiffuseMaterial] has

  ```cpp
  using BxDF = DiffuseBxDF;
  ```

  in the body of its definition.
][
  每个`Material`还负责定义其从`GetBxDF()`方法返回的`BxDF`类型，并为`BxDF`类型提供本地类型定义。例如，#link("<DiffuseMaterial>")[DiffuseMaterial];具有

  ```cpp
  using BxDF = DiffuseBxDF;
  ```

  在其定义中。
]

#parec[
  The value of defining the interface in this way is that doing so makes it possible to write generic BSDF evaluation code that is templated on the type of material. Such code can then allocate storage for the `BxDF` on the stack, for whatever type of `BxDF` the material uses. `pbrt`'s wavefront renderer, which is described in Chapter @wavefront-rendering-on-gpus, takes advantage of this opportunity. (Further details and discussion of its use there are in @surface-scattering.) A disadvantage of this design is that materials cannot return different `BxDF` types depending on their parameter values; they are limited to the one that they declare.
][
  以这种方式定义接口的价值在于，它使得可以编写基于材质类型的通用BSDF评估代码。这样的代码可以为材质使用的任何类型的`BxDF`在栈上分配存储空间。`pbrt`的波前渲染器（在 @wavefront-rendering-on-gpus 中描述）利用了这一机会。（有关其使用的更多细节和讨论，请参见@surface-scattering 。）这种设计的一个缺点是材质无法根据参数值返回不同的`BxDF`类型；它们只能返回声明的类型。
]

#parec[
  The #link("<Material>")[Material] class provides a `GetBSDF()` method that handles the variety of material `BxDF` return types. It requires some C++ arcana, though it centralizes the complexity of handling the diversity of types returned from the `GetBxDF()` methods.
][
  #link("<Material>")[Material];类提供了一个`GetBSDF()`方法来处理各种材质`BxDF`返回类型。它需要一些C++的技巧，但它集中处理了从`GetBxDF()`方法返回的多种类型的复杂性。
]

#parec[
  `Material::GetBSDF()` has the same general form of most of the dynamic dispatch method implementations in `pbrt`. (We have elided almost all of them from the text since most of them are boilerplate code.) Here we define a lambda function, `getBSDF`, and call the `Dispatch()` method that #link("<Material>")[Material] inherits from #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[TaggedPointer];. Recall that `Dispatch()` uses type information encoded in a 64-bit pointer to determine which concrete material type the #link("<Material>")[Material] points to before casting the pointer to that type and passing it to the lambda.
][
  `Material::GetBSDF()`具有与`pbrt`中大多数动态调度方法实现相同的一般形式。（我们几乎省略了文本中的所有这些，因为它们大多数是样板代码。）在这里，我们定义了一个lambda函数`getBSDF`，并调用#link("<Material>")[Material];从#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[TaggedPointer];继承的`Dispatch()`方法。回想一下，`Dispatch()`使用编码在64位指针中的类型信息来确定#link("<Material>")[Material];指向的具体材质类型，然后将指针转换为该类型并传递给lambda。
]

```cpp
template <typename TextureEvaluator>
BSDF Material::GetBSDF(
        TextureEvaluator texEval, MaterialEvalContext ctx,
        SampledWavelengths &lambda, ScratchBuffer &scratchBuffer) const {
    <<Define getBSDF lambda function for Material::GetBSDF()>>
    auto getBSDF = [&](auto mtl) -> BSDF {
           using ConcreteMtl = typename std::remove_reference_t<decltype(*mtl)>;
           using ConcreteBxDF = typename ConcreteMtl::BxDF;
           if constexpr (std::is_same_v<ConcreteBxDF, void>)
               return BSDF();
           else {
               <<Allocate memory for ConcreteBxDF and return BSDF for material>>
                  ConcreteBxDF *bxdf = scratchBuffer.Alloc<ConcreteBxDF>();
                  *bxdf = mtl->GetBxDF(texEval, ctx, lambda);
                  return BSDF(ctx.ns, ctx.dpdus, bxdf);
           }
       };
    return Dispatch(getBSDF);
}
```

#parec[
  `getBSDF` is a C++ #emph[generic lambda];: when it is called, the `auto mtl` parameter will have a concrete type, that of a reference to a pointer to one of the materials enumerated in the `<<Material Types>>` fragment. Given `mtl`, then, we can find the concrete type of its material and thence the type of its `BxDF`. If a material does not return a `BxDF`, it should use `void` for its `BxDF` type definition. In that case, an unset `BSDF` is returned. (The #link("<MixMaterial>")[MixMaterial] is the only such `Material` in `pbrt`.)
][
  `getBSDF`是一个C++#emph[泛型lambda];：调用时，`auto mtl`参数将具有具体类型，即指向`<<Material Types>>`片段中枚举的材质之一的指针的引用。 给定`mtl`，我们可以找到其材质的具体类型，从而找到其`BxDF`的类型。如果材质不返回`BxDF`，则应将其`BxDF`类型定义为`void`。在这种情况下，将返回一个未设置的`BSDF`。（#link("<MixMaterial>")[MixMaterial];是`pbrt`中唯一这样的`Material`。）
]


```cpp
auto getBSDF = [&](auto mtl) -> BSDF {
    using ConcreteMtl = typename std::remove_reference_t<decltype(*mtl)>;
    using ConcreteBxDF = typename ConcreteMtl::BxDF;
    if constexpr (std::is_same_v<ConcreteBxDF, void>)
        return BSDF();
    else {
        <<Allocate memory for ConcreteBxDF and return BSDF for material>>
           ConcreteBxDF *bxdf = scratchBuffer.Alloc<ConcreteBxDF>();
           *bxdf = mtl->GetBxDF(texEval, ctx, lambda);
           return BSDF(ctx.ns, ctx.dpdus, bxdf);
    }
};
```

#parec[
  The provided #link("../Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[ScratchBuffer] is used to allocate enough memory to store the material's `BxDF`; using it is much more efficient than using C++'s `new` and `delete` operators here. That memory is then initialized with the value returned by the material's `GetBxDF()` method before the complete `BSDF` is returned to the caller.
][
  提供的#link("../Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[ScratchBuffer];用于分配足够的内存以存储材质的`BxDF`；使用它比在此处使用C++的`new`和`delete`操作符更高效。然后用材质的`GetBxDF()`方法返回的值初始化该内存，然后将完整的`BSDF`返回给调用者。
]


```cpp
ConcreteBxDF *bxdf = scratchBuffer.Alloc<ConcreteBxDF>();
*bxdf = mtl->GetBxDF(texEval, ctx, lambda);
return BSDF(ctx.ns, ctx.dpdus, bxdf);
```

#parec[
  Materials that incorporate subsurface scattering must define a `GetBSSRDF()` method that follows a similar form. They must also include a `using` declaration in their class definition that defines a concrete `BSSRDF` type. (The code for rendering BSSRDFs is included only in the online edition.)
][
  包含次表面散射的材质必须定义一个`GetBSSRDF()`方法，其形式类似。它们还必须在其类定义中包含一个`using`声明，以定义一个具体的`BSSRDF`类型。（渲染BSSRDF的代码仅包含在在线版中。）
]

```cpp
template <typename TextureEvaluator>
ConcreteBSSRDF GetBSSRDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                         SampledWavelengths &lambda) const;
```
#parec[
  The #link("<Material>")[Material] class provides a corresponding `GetBSSRDF()` method that uses the provided `ScratchBuffer` to allocate storage for the material-specific `BSSRDF`.
][
  #link("<Material>")[Material];类提供了一个相应的`GetBSSRDF()`方法，使用提供的`ScratchBuffer`为材质特定的`BSSRDF`分配存储空间。
]

#parec[
  The #link("<MaterialEvalContext>")[MaterialEvalContext] that `GetBxDF()` and `GetBSSRDF()` take plays a similar role to other `*EvalContext` classes: it encapsulates only the values that are necessary for material evaluation. They are a superset of those that are used for texture evaluation, so it inherits from #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext];. Doing so has the added advantage that `MaterialEvalContext`s can be passed directly to the texture evaluation methods.
][
  `GetBxDF()`和`GetBSSRDF()`所需的#link("<MaterialEvalContext>")[MaterialEvalContext];与其他`*EvalContext`类起到类似的作用：它仅封装了材质评估所需的值。它们是纹理评估所需值的超集，因此继承自#link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext];。这样做的另一个好处是`MaterialEvalContext`s可以直接传递给纹理评估方法。
]
```cpp
struct MaterialEvalContext : public TextureEvalContext {
    <<MaterialEvalContext Public Methods>>
       MaterialEvalContext() = default;
       MaterialEvalContext(const SurfaceInteraction &si)
           : TextureEvalContext(si), wo(si.wo), ns(si.shading.n),
             dpdus(si.shading.dpdu) {}

    Vector3f wo;
    Normal3f ns;
    Vector3f dpdus;
};
```

#parec[
  As before, there is not only a constructor that initializes a `MaterialEvalContext` from a #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] but also a constructor that takes the values for the members individually (not included here).
][
  和之前一样，不仅有一个从#link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];初始化`MaterialEvalContext`的构造函数，还有一个单独接受成员值的构造函数（未在此包含）。
]

```cpp
MaterialEvalContext() = default;
MaterialEvalContext(const SurfaceInteraction &si)
    : TextureEvalContext(si), wo(si.wo), ns(si.shading.n),
      dpdus(si.shading.dpdu) {}
```

#parec[
  A `TextureEvaluator` is a class that is able to evaluate some or all of `pbrt`'s texture types. One of its methods takes a set of textures and reports whether it is capable of evaluating them, while others actually evaluate textures.
][
  `TextureEvaluator`是一个能够评估`pbrt`的一些或所有纹理类型的类。它的一个方法接受一组纹理并报告它是否能够评估它们，而其他方法则实际评估纹理。
]

#parec[
  On the face of it, there is no obvious need for such a class: why not allow #link("<Material>")[Material];s to call the #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[Texture] `Evaluate()` methods directly? This additional layer of abstraction aids performance with the wavefront integrator; it makes it possible to separate materials into those that have lightweight textures and those with heavyweight textures and to process them separately. Doing so is beneficial to performance on the GPU; see Section @surface-scattering for further discussion.
][
  表面上看，似乎没有明显需要这样的类：为什么不允许#link("<Material>")[Material];直接调用#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[Texture];的`Evaluate()`方法呢？这种额外的抽象层有助于提高波前积分器的性能；它使得可以将材质分为具有轻量级纹理和重量级纹理的材质，并分别处理它们。 这样做有助于提高GPU上的性能；有关进一步讨论，请参见@surface-scattering 。
]

#parec[
  For now we will only define the #link("<UniversalTextureEvaluator>")[UniversalTextureEvaluator];, which can evaluate all textures.In practice, the indirection it adds is optimized away by the compiler such that it introduces no runtime overhead. It is used with all of `pbrt`'s integrators other than the one defined in Chapter #link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15];.
][
  目前我们只定义#link("<UniversalTextureEvaluator>")[UniversalTextureEvaluator];，它可以评估所有纹理。实际上，编译器优化掉了它增加的间接性，因此不会引入运行时开销。它用于除第#link("../Wavefront_Rendering_on_GPUs.html#chap:gpu")[15];章定义的积分器之外的所有`pbrt`积分器。
]

```cpp
class UniversalTextureEvaluator {
  public:
    <<UniversalTextureEvaluator Public Methods>>
       bool CanEvaluate(std::initializer_list<FloatTexture>,
                        std::initializer_list<SpectrumTexture>) const {
           return true;
       }
       PBRT_CPU_GPU
       Float operator()(FloatTexture tex, TextureEvalContext ctx);

       PBRT_CPU_GPU
       SampledSpectrum operator()(SpectrumTexture tex, TextureEvalContext ctx,
                                  SampledWavelengths lambda);
};
```
#parec[
  `TextureEvaluator`s must provide a `CanEvaluate()` method that takes lists of #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture];s and #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture];s. They can then examine the types of the provided textures to determine if they are able to evaluate them. For the universal texture evaluator, the answer is always the same.
][
  `TextureEvaluator`必须提供一个`CanEvaluate()`方法，该方法接受#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture];和#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture];的列表。 然后它们可以检查提供的纹理类型，以确定它们是否能够评估它们。对于通用纹理评估器，答案始终相同。
]

```cpp
bool CanEvaluate(std::initializer_list<FloatTexture>,
                 std::initializer_list<SpectrumTexture>) const {
    return true;
}
```
#parec[
  `TextureEvaluator`s must also provide `operator()` method implementations that evaluate a given texture. Thus, given a texture evaluator `texEval`, material code should use the expression `texEval(tex, ctx)` rather than `tex.Evaluate(ctx)`. The implementation of this method is again trivial for the universal evaluator. (A corresponding method for spectrum textures is effectively the same and not included here.)
][
  `TextureEvaluator`还必须提供`operator()`方法实现，以评估给定的纹理。因此，给定一个纹理评估器`texEval`，材质代码应使用表达式`texEval(tex, ctx)`而不是`tex.Evaluate(ctx)`。对于通用评估器，该方法的实现再次是微不足道的。
]

```
<<UniversalTextureEvaluator Method Definitions>>=
Float UniversalTextureEvaluator::operator()(FloatTexture tex,
                                            TextureEvalContext ctx) {
    return tex.Evaluate(ctx);
}
```

///

#parec[
  Returning to the #link("<Material>")[Material] interface, all materials must provide a `CanEvaluateTextures()` method that takes a texture evaluator. They should return the result of calling its `CanEvaluate()` method with all of their textures provided. Code that uses #link("<Material>")[Material];s is then responsible for ensuring that a #link("<Material>")[Material];'s `GetBxDF()` or `GetBSSRDF()` method is only called with a texture evaluator that is able to evaluate its textures.
][
  回到#link("<Material>")[Material];接口，所有材质都必须提供一个`CanEvaluateTextures()`方法，该方法接受一个纹理评估器。它们应返回调用其`CanEvaluate()`方法的结果，并提供其所有纹理。 使用#link("<Material>")[Material];的代码负责确保仅使用能够评估其纹理的纹理评估器调用#link("<Material>")[Material];的`GetBxDF()`或`GetBSSRDF()`方法。
]

```cpp
<<Material Interface>>+=
template <typename TextureEvaluator>
bool CanEvaluateTextures(TextureEvaluator texEval) const;
```

#parec[
  Materials also may modify the shading normals of objects they are bound to, usually in order to introduce the appearance of greater geometric detail than is actually present. The #link("<Material>")[Material] interface has two ways that they may do so, normal mapping and bump mapping.
][
  材质还可以修改绑定到它们的对象的着色法线，通常是为了引入比实际存在的几何细节更大的外观。#link("<Material>")[Material];接口有两种方法可以做到这一点，法线贴图和凹凸贴图。
]


#parec[
  `pbrt`'s normal mapping code, which will be described in @normal-mapping , takes an image that specifies the shading normals. A `nullptr` value should be returned by this interface method if no normal map is included with a material.
][
  `pbrt`的法线贴图代码将在@normal-mapping 中描述，它需要一个指定着色法线的图像。如果材质不包含法线贴图，则此接口方法应返回`nullptr`值。
]
```cpp
<<Material Interface>>+=
const Image *GetNormalMap() const;
```

#parec[
  Alternatively, shading normals may be specified via bump mapping, which takes a displacement function that specifies surface detail with a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture];. A `nullptr` value should be returned if no such displacement function has been specified.
][
  或者，可以通过凹凸贴图指定着色法线，凹凸贴图使用#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture];指定表面细节。如果未指定此类位移函数，则应返回`nullptr`值。
]


```
<<Material Interface>>+=
FloatTexture GetDisplacement() const;
```

#parec[
  What should be returned by `HasSubsurfaceScattering()` method implementations should be obvious; this method is used to determine for which materials in a scene it is necessary to do the additional processing to model that effect.
][
  `HasSubsurfaceScattering()`方法实现应返回什么应该是显而易见的；此方法用于确定场景中哪些材质需要进行额外处理以建模该效果。
]

```cpp
bool HasSubsurfaceScattering() const;
```



=== Material Implementations
<material-implementations>
#parec[
  With the preliminaries covered, we will now present a few material implementations. All the `Material`s in `pbrt` are fairly basic bridges between `Texture`s and `BxDF`s, so we will focus here on their basic form and some of the unique details of one of them.
][
  在介绍完基础知识后，我们现在将展示一些材质的实现方式。在 `pbrt` 中，所有的 `Material` 都是 `Texture` 和 `BxDF` 之间的基础桥梁，因此我们将在这里关注它们的基本形式以及其中一个的独特特征。
]

==== Diffuse Material
<diffuse-material>
#parec[
  `DiffuseMaterial` is the simplest material implementation and is a good starting point for understanding the material requirements.
][
  `DiffuseMaterial` 是最简单的材质实现，是理解材质需求的一个很好的起点。
]

```cpp
class DiffuseMaterial {
  public:
    // <<DiffuseMaterial Type Definitions>>
    using BxDF = DiffuseBxDF;
       using BSSRDF = void;
    // <<DiffuseMaterial Public Methods>>
    static const char *Name() { return "DiffuseMaterial"; }

       PBRT_CPU_GPU
       FloatTexture GetDisplacement() const { return displacement; }
       PBRT_CPU_GPU
       const Image *GetNormalMap() const { return normalMap; }

       static DiffuseMaterial *Create(const TextureParameterDictionary &parameters,
                                      Image *normalMap, const FileLoc *loc, Allocator alloc);

       template <typename TextureEvaluator>
       PBRT_CPU_GPU void GetBSSRDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                                           SampledWavelengths &lambda,
                                           void *) const {
       }

       PBRT_CPU_GPU static constexpr bool HasSubsurfaceScattering() { return false; }

       std::string ToString() const;
       DiffuseMaterial(SpectrumTexture reflectance,
                       FloatTexture displacement, Image *normalMap)
           : normalMap(normalMap), displacement(displacement), reflectance(reflectance) {}
       template <typename TextureEvaluator>
       bool CanEvaluateTextures(TextureEvaluator texEval) const {
           return texEval.CanEvaluate({}, {reflectance});
       }
       template <typename TextureEvaluator>
       DiffuseBxDF GetBxDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                           SampledWavelengths &lambda) const {
           SampledSpectrum r = Clamp(texEval(reflectance, ctx, lambda), 0, 1);
           return DiffuseBxDF(r);
       }
  private:
    <<DiffuseMaterial Private Members>>       Image *normalMap;
       FloatTexture displacement;
       SpectrumTexture reflectance;
};
```

#parec[
  These are the `BxDF` and `BSSRDF` type definitions for `DiffuseMaterial`. Because this material does not include subsurface scattering, `BSSRDF` can be set to be `void`.
][
  这些是 `DiffuseMaterial` 的 `BxDF` 和 `BSSRDF` 类型定义。因为这种材质不包括次表面散射，所以 `BSSRDF` 可以设置为 `void`。
]

```cpp
using BxDF = DiffuseBxDF;
using BSSRDF = void;
```
#parec[
  The constructor initializes the following member variables with provided values, so it is not included here.
][
  构造函数初始化以下成员变量，因此不在此处包含。
]

```cpp
Image *normalMap;
FloatTexture displacement;
SpectrumTexture reflectance;
```

#parec[
  The `CanEvaluateTextures()` method is easy to implement; the various textures used for BSDF evaluation are passed to the given `TextureEvaluator`. Note that the displacement texture is not included here; if present, it is handled separately by the bump mapping code.
][
  `CanEvaluateTextures()` 方法易于实现；用于 BSDF 评估的各种纹理被传递给给定的 `TextureEvaluator`。注意，这里不包括位移纹理；如果存在，它由凹凸映射代码单独处理。
]

```cpp
template <typename TextureEvaluator>
bool CanEvaluateTextures(TextureEvaluator texEval) const {
    return texEval.CanEvaluate({}, {reflectance});
}
```
#parec[
  There is also not very much to `GetBxDF()`; it evaluates the reflectance texture, clamping the result to the range of valid reflectances before passing it along to the `DiffuseBxDF` constructor and returning a `DiffuseBxDF`.
][
  `GetBxDF()` 也没有太多内容；它评估反射率纹理，将结果限制在有效范围内，然后传递给 `DiffuseBxDF` 构造函数并返回一个 `DiffuseBxDF`。
]

```cpp
template <typename TextureEvaluator>
DiffuseBxDF GetBxDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                    SampledWavelengths &lambda) const {
    SampledSpectrum r = Clamp(texEval(reflectance, ctx, lambda), 0, 1);
    return DiffuseBxDF(r);
}
```
#parec[
  `GetNormalMap()` and `GetDisplacement()` return the corresponding member variables, and the remaining methods are trivial; see the source code for details.
][
  `GetNormalMap()` 和 `GetDisplacement()` 返回相应的成员变量，其余方法很琐碎；具体细节请参见源代码。
]


==== Dielectric Material
<dielectric-material>
#parec[
  `DielectricMaterial` represents a dielectric interface.
][
  `DielectricMaterial` 表示一个介电界面。
]

```cpp
 <<DielectricMaterial Definition>>=
class DielectricMaterial {
  public:
    <<DielectricMaterial Type Definitions>>
    <<DielectricMaterial Public Methods>>
  private:
    <<DielectricMaterial Private Members>>
};
```
#parec[
  It returns a #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`] and does not include subsurface scattering.
][
  它返回一个 #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`];，不包括次表面散射。
]

```
using BxDF = DielectricBxDF;
using BSSRDF = void;
```

#parec[
  `DielectricMaterial` has a few more parameters than `DiffuseMaterial`. The index of refraction is specified with a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[`SpectrumTexture`] so that it may vary with wavelength. Note also that two roughness values are stored, which allows the specification of an anisotropic microfacet distribution. If the distribution is isotropic, this leads to a minor inefficiency in storage and, shortly, texture evaluation, since both are always evaluated.
][
  `DielectricMaterial` 比 `DiffuseMaterial` 有更多的参数。折射率通过一个 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[`SpectrumTexture`] 指定，因此它可以随波长变化。还要注意，存储了两个粗糙度值，这允许指定各向异性的微面分布。如果分布是各向同性的，这可能会导致存储和纹理评估上的轻微效率损失，因为在各向同性的情况下，两个粗糙度值总是被评估的。
]


```
Image *normalMap;
FloatTexture displacement;
FloatTexture uRoughness, vRoughness;
bool remapRoughness;
Spectrum eta;
```

#parec[
  `GetBxDF()` follows a similar form to `DiffuseMaterial`, evaluating various textures and using their results to initialize the returned #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`];.
][
  `GetBxDF()` 的形式类似于 `DiffuseMaterial`，评估各种纹理并使用其结果初始化返回的 #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`];。
]

```cpp
<<DielectricMaterial Public Methods>>=
template <typename TextureEvaluator>
DielectricBxDF GetBxDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                       SampledWavelengths &lambda) const {
    <<Compute index of refraction for dielectric material>>
    <<Create microfacet distribution for dielectric material>>
    <<Return BSDF for dielectric material>>
}
```

#parec[
  If the index of refraction is the same for all wavelengths, then all wavelengths will follow the same path if a ray is refracted. Otherwise, they will go in different directions—this is dispersion. In that case, `pbrt` only follows a single ray path according to the first wavelength in #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[`SampledWavelengths`] rather than tracing multiple rays to track each of them, and a call to #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`] is necessary. (See @sampled-spectral-distributions for more information.)
][
  如果所有波长的折射率相同，那么如果光线被折射，所有波长将遵循相同的路径。否则，它们将朝不同方向行进——这就是色散。在这种情况下，`pbrt` 仅根据 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[`SampledWavelengths`] 中的第一个波长跟踪单个光线路径，而不是跟踪多个光线来追踪每个波长，因此需要调用 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`];。有关更多信息，请参见@sampled-spectral-distributions。
]

#parec[
  #link("<DielectricMaterial>")[`DielectricMaterial`] therefore calls `TerminateSecondary()` unless the index of refraction is known to be constant, as determined by checking if `eta`'s #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] type is a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#ConstantSpectrum")[`ConstantSpectrum`];. This check does not detect all cases where the sampled spectrum values are all the same, but it catches most of them in practice, and unnecessarily terminating the secondary wavelengths affects performance but not correctness. A bigger shortcoming of the implementation here is that there is no dispersion if light is reflected at a surface and not refracted. In that case, all wavelengths could still be followed. However, how light paths will be sampled at the surface is not known at this point in program execution.
][
  #link("<DielectricMaterial>")[`DielectricMaterial`] 因此调用 `TerminateSecondary()`，除非折射率被确定为常数，这通过检查 `eta`（表示材料的折射率）的 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] 类型是否为 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#ConstantSpectrum")[`ConstantSpectrum`] 来确定。此检查并不能检测所有采样光谱值都相同的情况，但在实践中它能捕获大多数情况，不必要地终止次要波长会影响性能，但不会影响正确性。这里实现的一个更大缺陷是，如果光在表面反射而不是折射，则没有色散。在这种情况下，所有波长仍然可以被跟踪。然而，在程序执行的这一点上，尚不知道光线路径将在表面如何采样。
]

```
Float sampledEta = eta(lambda[0]);
if (!eta.template Is<ConstantSpectrum>())
    lambda.TerminateSecondary();
```
#parec[
  It can be convenient to specify a microfacet distribution's roughness with a scalar parameter in the interval $[0 , 1]$, where values close to zero correspond to near-perfect specular reflection, rather than by specifying $alpha$ values directly. The `RoughnessToAlpha()` method performs a mapping that gives a reasonably intuitive control for surface appearance.
][
  可以方便地用区间 $[0 , 1]$ 中的标量参数指定微面分布的粗糙度，其中接近零的值对应于接近完美的镜面反射，而不是直接指定 $alpha$ 值。`RoughnessToAlpha()` 方法执行了一种映射，提供了对表面外观的合理直观控制。
]

```
static Float RoughnessToAlpha(Float roughness) {
    return std::sqrt(roughness);
}
```

#parec[
  The `GetBxDF()` method then evaluates the roughness textures and remaps the returned values if required.
][
  `GetBxDF()` 方法然后评估粗糙度纹理，并在需要时重新映射返回的值。
]

```
Float urough = texEval(uRoughness, ctx), vrough = texEval(vRoughness, ctx);
if (remapRoughness) {
    urough = TrowbridgeReitzDistribution::RoughnessToAlpha(urough);
    vrough = TrowbridgeReitzDistribution::RoughnessToAlpha(vrough);
}
TrowbridgeReitzDistribution distrib(urough, vrough);
```

#parec[
  Given the index of refraction and microfacet distribution, it is easy to pull the pieces together to return the final `BxDF`.
][
  给定折射率和微面分布，很容易将各个部分组合起来返回最终的 `BxDF`。
]

```
return DielectricBxDF(sampledEta, distrib);
```

==== Mix Material
<mix-material>

#parec[
  The final material implementation that we will describe in the text is `MixMaterial`, which stores two other materials and uses a `Float`-valued texture to blend between them.
][
  我们将在文本中描述的最终材料实现是 `MixMaterial`，它存储了另外两种材料，并使用一个浮点值纹理在它们之间进行混合。
]

```cpp
<<MixMaterial Definition>>=
class MixMaterial {
public:
  <<MixMaterial Type Definitions>>
  <<MixMaterial Public Methods>>
private:
  <<MixMaterial Private Members>>
};
```

```cpp
<<MixMaterial Private Members>>=
FloatTexture amount;
Material materials[2];
```

#parec[
  `MixMaterial` does not cleanly fit into `pbrt`'s `Material` abstraction. For example, it is unable to define a single `BxDF` type that it will return, since its two constituent materials may have different `BxDF`s, and may themselves be `MixMaterial`s, for that matter. Thus, `MixMaterial` requires special handling by the code that uses materials. (For example, there is a special case for `MixMaterial`s in the `SurfaceInteraction::GetBSDF()` method described in Section @finding-the-bsdf-at-a-surface.)
][
  `MixMaterial` 并不能完全符合 `pbrt` 的 `Material` 抽象。例如，它无法定义一个单一的 `BxDF` 类型来返回，因为它的两个组成材质可能具有不同的 `BxDF`，并且它们本身也可能是 `MixMaterial`。因此，`MixMaterial` 需要在使用材质的代码中进行特殊处理。（例如，在 @finding-the-bsdf-at-a-surface 描述的 `SurfaceInteraction::GetBSDF()` 方法中，对 `MixMaterial` 有一个特殊情况。）
]

#parec[
  This is not ideal: as a general point of software design, it would be better to have abstractions that make it possible to provide this functionality without requiring special-case handling in calling code. However, we were unable to find a clean way to do this while still being able to statically reason about the type of `BxDF` a material will return; that aspect of the `Material` interface offers enough of a performance benefit that we did not want to change it.
][
  这并不理想：从软件设计的一般原则来看，最好有一种抽象方法，可以在不需要调用代码中特殊处理的情况下提供这种功能。然而，我们无法找到一种清晰的方法来实现这一点，同时仍然能够静态推断出材质将返回的 `BxDF` 类型；`Material` 接口的这一方面提供了足够的性能优势，以至于我们不想改变它。
]


#parec[
  Therefore, when a `MixMaterial` is encountered, one of its constituent materials is randomly chosen, with probability given by the floating-point `amount` texture. Thus, a 50/50 mix of two materials is not represented by the average of their respective BSDFs and so forth, but instead by each of them being evaluated half the time. This is effectively the material analog of the stochastic alpha test that was described in @geometric-primitives . The `ChooseMaterial()` method implements the logic.
][
  因此，当遇到 `MixMaterial` 时，会根据浮点数 `amount` 纹理给出的概率随机选择其一个组成材质。因此，两个材质的 50/50 混合并不是通过它们各自 BSDF 的平均值等来表示，而是通过每个材质分别被评估一半时间来实现。这实际上是 @geometric-primitives 中描述的随机 alpha 测试的材质类比。`ChooseMaterial()` 方法实现了该逻辑。
]

```cpp
<<MixMaterial Public Methods>>=
template <typename TextureEvaluator>
Material ChooseMaterial(TextureEvaluator texEval,
                        MaterialEvalContext ctx) const {
    Float amt = texEval(amount, ctx);
    if (amt <= 0) return materials[0];
    if (amt >= 1) return materials[1];
    Float u = HashFloat(ctx.p, ctx.wo, materials[0], materials[1]);
    return (amt < u) ? materials[0] : materials[1];
}
```


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f20.svg"),
  caption: [
    #ez_caption[
      *Effect of Sampling Rate with the MixMaterial.* In this scene, the MixMaterial is used to blend between blue and red diffuse materials for the dragon, using an equal weighting for each. (a) With one sample per pixel, there is visible noise in the corresponding pixels since each pixel only includes one of the two constituent materials. (b) With a sufficient number of samples (here, 128), stochastic selection of materials causes no visual harm. In practice, the pixel sampling rates necessary to reduce other forms of error from simulating light transport are almost always enough to resolve stochastic material sampling.
    ][
      *采样率对 MixMaterial 的影响*
      在这个场景中，MixMaterial 被用于将蓝色和红色的漫反射材质以相等权重混合在龙的表面。
      (a) 当每像素仅使用一次采样时，由于每个像素只包含两个组成材质中的一个，因此会在对应的像素中出现可见的噪声。
      (b) 当采样次数足够多（此处为 128 次）时，材质的随机选择不会对视觉效果造成影响。
      在实际操作中，为减少其他因模拟光线传播引起的误差而所需的像素采样率，几乎总是足以解决随机材质采样的问题。

    ]
  ],
)<mix-material-stoshastic>

#parec[
  Stochastic selection of materials can introduce noise in images at low sampling rates; see @fig:mix-material-stoshastic. However, a few tens of samples are generally plenty to resolve any visual error. Furthermore, this approach does bring benefits: sampling and evaluation of the resulting BSDF is more efficient than if it was a weighted sum of the BSDFs from the constituent materials.
][
  材质的随机选择可能会在低采样率下引入噪声 。 参考@fig:mix-material-stoshastic。然而，通常只需几十次采样就足以解决任何视觉误差。此外，这种方法确实带来了好处：对生成的 BSDF 进行采样和评估比直接对组成材质的 BSDF 加权求和更高效。
]


#parec[
  `MixMaterial` provides an accessor that makes it possible to traverse all the materials in the scene, including those nested inside a MixMaterial, so that it is possible to perform operations such as determining which types of materials are and are not present in a scene.
][
  `MixMaterial` 提供了一个访问器。 该访问器使得可以遍历场景中的所有材质，包括嵌套在 MixMaterial 中的材质，从而能够执行诸如确定场景中存在哪些类型的材质之类的操作。
]

```
<<MixMaterial Public Methods>>+=
Material GetMaterial(int i) const { return materials[i]; }
```

#parec[
  A fatal error is issued if the `GetBxDF()` method is called. A call to `GetBSSRDF()` is handled similarly, in code not included here.
][
  调用 `GetBxDF()` 方法会引发致命错误。 对于 `GetBSSRDF()` 的调用也以类似方式处理，相关代码未包含在此处。
]

```cpp
<<MixMaterial Public Methods>>+=
template <typename TextureEvaluator>
void GetBxDF(TextureEvaluator texEval, MaterialEvalContext ctx,
             SampledWavelengths &lambda) const {
    LOG_FATAL("MixMaterial::GetBxDF() shouldn't be called");
}
```


=== Finding the BSDF at a Surface
<finding-the-bsdf-at-a-surface>


#parec[
  Because `pbrt`'s #link("../Introduction/pbrt_System_Overview.html#Integrator")[`Integrator`];s use the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] class to collect the necessary information associated with each intersection point, we will add a `GetBSDF()` method to this class that handles all the details related to computing the BSDF at its point.
][
  由于 `pbrt` 的 #link("../Introduction/pbrt_System_Overview.html#Integrator")[`Integrator`] 使用 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 类来收集与每个交点相关的必要信息，我们将向该类添加一个 `GetBSDF()` 方法，以处理计算交点 BSDF 的所有相关细节。
]

```cpp
<<SurfaceInteraction Method Definitions>>+=
BSDF SurfaceInteraction::GetBSDF(
        const RayDifferential &ray, SampledWavelengths &lambda,
        Camera camera, ScratchBuffer &scratchBuffer, Sampler sampler) {
    <<Estimate  and position differentials at intersection point>>
    <<Resolve MixMaterial if necessary>>
    <<Return unset BSDF if surface has a null material>>
    <<Evaluate normal or bump map, if present>>
    <<Return BSDF for surface interaction>>
}
```

#parec[
  This method first calls the `SurfaceInteraction`'s `ComputeDifferentials()` method to compute information about the projected size of the surface area around the intersection on the image plane for use in texture antialiasing.
][
  此方法首先调用 `SurfaceInteraction` 的 `ComputeDifferentials()` 方法，以计算用于纹理抗锯齿的表面区域在图像平面上的投影大小。
]

```cpp
ComputeDifferentials(ray, camera, sampler.SamplesPerPixel());
```


#parec[
  As described in @mix-material , if there is a #link("<MixMaterial>")[`MixMaterial`] at the intersection point, it is necessary to resolve it to be a regular material. A `while` loop here ensures that nested `MixMaterial`s are handled correctly.
][
  如@mix-material 所述，如果交点处存在 #link("<MixMaterial>")[`MixMaterial`];，则需要将其解析为常规材料。这里的 `while` 循环确保正确处理嵌套的 `MixMaterial`。
]

```cpp
while (material.Is<MixMaterial>()) {
    MixMaterial *mix = material.Cast<MixMaterial>();
    material = mix->ChooseMaterial(UniversalTextureEvaluator(), *this);
}
```
#parec[
  This method first calls the SurfaceInteraction's `ComputeDifferentials()` method to compute information about the projected size of the surface area around the intersection on the image plane for use in texture antialiasing.
][
  此方法首先调用 SurfaceInteraction 的 `ComputeDifferentials()` 方法。 该方法用于计算交点周围表面区域在图像平面上的投影尺寸信息，以便用于纹理抗锯齿处理。
]

```
<<Estimate  and position differentials at intersection point>>=
ComputeDifferentials(ray, camera, sampler.SamplesPerPixel());
```

#parec[
  As described in @mix-material, if there is a MixMaterial at the intersection point, it is necessary to resolve it to be a regular material. A while loop here ensures that nested MixMaterials are handled correctly.
][
  如@mix-material 所述 如果交点处存在一个 MixMaterial，则需要将其解析为一个常规材质。这里使用了一个 while 循环来确保正确处理嵌套的 MixMaterial。
]

```cpp
<<Resolve MixMaterial if necessary>>=
while (material.Is<MixMaterial>()) {
    MixMaterial *mix = material.Cast<MixMaterial>();
    material = mix->ChooseMaterial(UniversalTextureEvaluator(), *this);
}
```

#parec[
  If the final material is `nullptr`, it represents a non-scattering interface between two types of participating media. In this case, a default uninitialized `BSDF` is returned.
][
  如果最终材料为 `nullptr`，则表示两种参与介质之间的非散射界面。在这种情况下，将返回一个默认的未初始化 `BSDF`。
]

```cpp
if (!material)
    return {};
```


#parec[
  Otherwise, normal or bump mapping is performed before the #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`] is created.
][
  否则，在创建 #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`] 之前执行法线或凹凸贴图。
]

```cpp
<<Evaluate normal or bump map, if present>>=
FloatTexture displacement = material.GetDisplacement();
const Image *normalMap = material.GetNormalMap();
if (displacement || normalMap) {
    <<Get shading  and  using normal or bump map>>
    Normal3f ns(Normalize(Cross(dpdu, dpdv)));
    SetShadingGeometry(ns, dpdu, dpdv, shading.dndu, shading.dndv, false);
}
```

#parec[
  The appropriate utility function for normal or bump mapping is called, depending on which technique is to be used.
][
  根据使用的技术，调用相应的法线或凹凸贴图函数。
]

```cpp
Vector3f dpdu, dpdv;
if (normalMap)
    NormalMap(*normalMap, *this, &dpdu, &dpdv);
else
    BumpMap(UniversalTextureEvaluator(), displacement, *this, &dpdu, &dpdv);
```


#parec[
  With differentials both for texture filtering and for shading geometry now settled, the #link("<Material::GetBSDF>")[`Material::GetBSDF()`] method can be called. Note that the universal texture evaluator is used both here and previously in the method, as there is no need to distinguish between different texture complexities in this part of the system.
][
  现在，纹理过滤和着色几何的微分都已确定，可以调用 #link("<Material::GetBSDF>")[`Material::GetBSDF()`] 方法。请注意，通用纹理评估器在此方法中和之前都被使用，因为在系统的这一部分不需要区分不同的纹理复杂性。
]

```cpp
BSDF bsdf = material.GetBSDF(UniversalTextureEvaluator(), *this, lambda,
                             scratchBuffer);
if (bsdf && GetOptions().forceDiffuse) {
    <<Override bsdf with diffuse equivalent>>       SampledSpectrum r = bsdf.rho(wo, {sampler.Get1D()}, {sampler.Get2D()});
    bsdf = BSDF(shading.n, shading.dpdu,
                scratchBuffer.Alloc<DiffuseBxDF>(r));
}
return bsdf;
```


#parec[
  `pbrt` provides an option to override all the materials in a scene with equivalent diffuse BSDFs; doing so can be useful for some debugging problems. In this case, the hemispherical–directional reflectance is used to initialize a #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];.
][
  `pbrt` 提供了一个选项，可以用等效的漫反射 BSDF 覆盖场景中的所有材料；这样做对于某些调试问题可能很有用。在这种情况下，使用半球-方向反射率来初始化 #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];。
]

```cpp
SampledSpectrum r = bsdf.rho(wo, {sampler.Get1D()}, {sampler.Get2D()});
bsdf = BSDF(shading.n, shading.dpdu,
            scratchBuffer.Alloc<DiffuseBxDF>(r));
```


#parec[
  The `SurfaceInteraction::GetBSSRDF()` method, not included here, follows a similar path before calling #link("<Material::GetBSSRDF>")[Material::GetBSSRDF];.
][
  未在此处包含的 `SurfaceInteraction::GetBSSRDF()` 方法在调用 #link("<Material::GetBSSRDF>")[Material::GetBSSRDF] 之前遵循类似的路径。
]

=== Normal mapping
<normal-mapping>

#parec[
  Normal mapping is a technique that maps tabularized surface normals stored in images to surfaces and uses them to specify shading normals in order to give the appearance of fine geometric detail.
][
  法线贴图是一种技术，它将表格化的表面法线映射到表面上，并使用它们来指定阴影法线，以呈现细致的几何细节。
]

#parec[
  With normal maps, one must choose a coordinate system for the stored normals. While any coordinate system may be chosen, one of the most useful is the local shading coordinate system at each point on a surface where the $z$ axis is aligned with the surface normal and tangent vectors are aligned with $x$ and $y$. (This is the same as the reflection coordinate system described in @bsdf-geom-and-conventions.) When that coordinate system is used, the approach is called #emph[tangent-space normal mapping];. With tangent-space normal mapping, a given normal map can be applied to a variety of shapes, while choosing a coordinate system like object space would closely couple a normal map's encoding to a specific geometric object.
][
  使用法线贴图时，必须为存储的法线选择一个坐标系。虽然可以选择任何坐标系，但最有用的之一是在表面上每个点的局部着色坐标系，其中 $z$ 轴与表面法线对齐，切线向量与 $x$ 和 $y$ 对齐。（这与@bsdf-geom-and-conventions 中描述的反射坐标系相同。）当使用该坐标系时，这种方法称为#emph[切线空间法线贴图];。 使用切线空间法线贴图时，可以将同一个法线贴图应用于各种形状，而选择像物体空间这样的坐标系会将法线贴图的编码紧密耦合到特定的几何对象上。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f21.svg"),
  caption: [
    #ez_caption[
      (a) A normal map modeling wrinkles for a pillow model. (b) Pillow geometry without normal map. (c) When applied to the pillow, the normal map gives a convincing approximation to more detailed geometry than is actually present. (Scene courtesy of Angelo Ferretti.)
    ][
      (a) A normal map modeling wrinkles for a pillow model. (b) Pillow geometry without normal map. (c) When applied to the pillow, the normal map gives a convincing approximation to more detailed geometry than is actually present. (Scene courtesy of Angelo Ferretti.)
    ]
  ],
)<normal-map>

#parec[
  Normal maps are traditionally encoded in RGB images, where red, green, and blue respectively store the $x$, $y$, and $z$ components of the surface normal. When tangent-space normal mapping is used, normal map images are typically predominantly blue, reflecting the fact that the $z$ component of the surface normal has the largest magnitude unless the normal has been substantially perturbed. @fig:normal-map
][
  法线贴图传统上编码在 RGB 图像中，其中红、绿、蓝分别存储表面法线的 $x$ 、 $y$ 和 $z$ 分量。 当使用切线空间法线贴图时，法线贴图图像通常主要是蓝色的，反映了表面法线的 $z$ 分量具有最大幅度，除非法线被大幅扰动。 @fig:normal-map
]

#parec[
  This RGB encoding brings us to an unfortunate casualty from the adoption of spectral rendering in this version of `pbrt`: while `pbrt`'s #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] previously returned RGB colors, they now return point-sampled spectral values. If an RGB image map is used for a spectrum texture, it is not possible to exactly reconstruct the original RGB colors; there will unavoidably be error in the Monte Carlo estimator that must be evaluated to find RGB. Introducing noise in the orientations of surface normals is unacceptable, since it would lead to systemic bias in rendered images. Consider a bumpy shiny object: error in the surface normal would lead to scattered rays intersecting objects that they would never intersect given the correct normals, which could cause arbitrarily large error.
][
  这种 RGB 编码在本版 `pbrt` 采用光谱渲染时带来了不幸的问题：虽然 `pbrt` 的 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] 以前返回 RGB 颜色，但现在返回逐点采样的光谱值。 如果将 RGB 图像贴图用于光谱纹理，则无法精确重建原始 RGB 颜色；在蒙特卡罗估计中不可避免地会产生误差，必须评估以找到 RGB。 在表面法线的方向上引入噪声是不可接受的，因为这会导致渲染图像中的系统性偏差。 考虑一个有凹凸的光滑物体：表面法线的误差会导致散射的光线与它们在正确法线下永远不会相交的物体相交，这可能导致任意大的误差。
]

#parec[
  We might avoid that problem by augmenting the #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] interface to include a method that returned RGB color, introducing a separate `RGBTexture` interface and texture implementations, or by introducing a `NormalTexture` that returned normals directly. Any of these could cleanly support normal mapping, though all would require a significant amount of additional code.
][
  我们可以通过扩展 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] 接口以包含返回 RGB 颜色的方法，引入一个单独的 `RGBTexture` 接口和纹理实现，或者通过引入一个直接返回法线的 `NormalTexture` 来避免这个问题。 任何一种方法都可以干净地支持法线贴图，尽管所有方法都需要大量额外的代码。
]

#parec[
  Because the capability of directly looking up RGB values is only needed for normal mapping, the `NormalMap()` function therefore takes an #link("../Utilities/Images.html#Image")[Image] to specify the normal map. It assumes that the first three channels of the image represent red, green, and blue. With this approach we have lost the benefits of being able to scale and mix textures as well as the ability to apply a variety of mapping functions to compute texture coordinates. While that is unfortunate, those capabilities are less often used with normal maps than with other types of textures, and so we prefer not to make the `Texture` interfaces more complex purely for normal mapping.
][
  由于直接查找 RGB 值的能力仅在法线贴图中需要，所以 `NormalMap()` 函数因此采用一个 #link("../Utilities/Images.html#Image")[Image] 来指定法线贴图。 它假设图像的前三个通道代表红、绿、蓝。 通过这种方法，我们失去了缩放和混合纹理以及应用各种映射函数计算纹理坐标的能力。 虽然这很不幸，但这些功能在法线贴图中使用的频率比其他类型的纹理要少，因此我们不希望仅仅为了法线贴图而使 `Texture` 接口更复杂。
]

```cpp
<<Normal Mapping Function Definitions>>=
void NormalMap(const Image &normalMap, const NormalBumpEvalContext &ctx,
               Vector3f *dpdu, Vector3f *dpdv) {
    <<Get normalized normal vector from normal map>>
    <<Transform tangent-space normal to rendering space>>
    <<Find  and  that give shading normal>>
}
```


#parec[
  Both `NormalMap()` and `BumpMap()` take a NormalBumpEvalContext to specify the local geometric information for the point where the shading geometry is being computed.
][
  Both `NormalMap()` and `BumpMap()` take a NormalBumpEvalContext to specify the local geometric information for the point where the shading geometry is being computed.
]

```cpp
<<NormalBumpEvalContext Definition>>=
struct NormalBumpEvalContext {
    <<NormalBumpEvalContext Public Methods>>
    <<NormalBumpEvalContext Public Members>>
};
```

#parec[
  As usual, it has a constructor, not included here, that performs initialization given a SurfaceInteraction.
][
  As usual, it has a constructor, not included here, that performs initialization given a SurfaceInteraction.
]


```cpp
<<NormalBumpEvalContext Public Members>>=
Point3f p;
Point2f uv;
Normal3f n;
struct {
    Normal3f n;
    Vector3f dpdu, dpdv;
    Normal3f dndu, dndv;
} shading;
Float dudx = 0, dudy = 0, dvdx = 0, dvdy = 0;
Vector3f dpdx, dpdy;
```


#parec[
  It also provides a conversion operator to TextureEvalContext, which only needs a subset of the values stored in NormalBumpEvalContext.
][
  It also provides a conversion operator to TextureEvalContext, which only needs a subset of the values stored in NormalBumpEvalContext.
]

```cpp
<<NormalBumpEvalContext Public Methods>>=
operator TextureEvalContext() const {
    return TextureEvalContext(p, dpdx, dpdy, n, uv, dudx, dudy,
                              dvdx, dvdy);
}
```


#parec[
  The first step in the normal mapping computation is to read the tangent-space normal vector from the image map. The image wrap mode is hard-coded here since Repeat is almost always the desired mode, though it would be easy to allow the wrap mode to be set via a parameter. Note also that the $v$ coordinate is inverted, again following the image texture coordinate convention discussed in Section 10.4.2.
][
  The first step in the normal mapping computation is to read the tangent-space normal vector from the image map. The image wrap mode is hard-coded here since Repeat is almost always the desired mode, though it would be easy to allow the wrap mode to be set via a parameter. Note also that the $v$ coordinate is inverted, again following the image texture coordinate convention discussed in Section 10.4.2.
]


#parec[
  Normal maps are traditionally encoded in fixed-point image formats with pixel values that range from 0 to 1. This encoding allows the use of compact 8-bit pixel representations as well as compressed image formats that are supported by GPUs. Values read from the image must therefore be remapped to the range $[-1, 1]$ to reconstruct an associated normal vector. The normal vector must be renormalized, as both the quantization in the image pixel format and the bilinear interpolation may have caused it to be non-unit-length.
][
  Normal maps are traditionally encoded in fixed-point image formats with pixel values that range from 0 to 1. This encoding allows the use of compact 8-bit pixel representations as well as compressed image formats that are supported by GPUs. Values read from the image must therefore be remapped to the range $[-1, 1]$ to reconstruct an associated normal vector. The normal vector must be renormalized, as both the quantization in the image pixel format and the bilinear interpolation may have caused it to be non-unit-length.
]


```cpp
<<Get normalized normal vector from normal map>>=
WrapMode2D wrap(WrapMode::Repeat);
Point2f uv(ctx.uv[0], 1 - ctx.uv[1]);
Vector3f ns(2 * normalMap.BilerpChannel(uv, 0, wrap) - 1,
            2 * normalMap.BilerpChannel(uv, 1, wrap) - 1,
            2 * normalMap.BilerpChannel(uv, 2, wrap) - 1);
ns = Normalize(ns);
```


#parec[
  In order to transform the normal to rendering space, a Frame can be used to specify a coordinate system where the original shading normal is aligned with the $+z$ axis. Transforming the tangent-space normal into this coordinate system gives the rendering-space normal.
][
  In order to transform the normal to rendering space, a Frame can be used to specify a coordinate system where the original shading normal is aligned with the $+z$ axis. Transforming the tangent-space normal into this coordinate system gives the rendering-space normal.
]

```cpp
<<Transform tangent-space normal to rendering space>>=
Frame frame = Frame::FromZ(ctx.shading.n);
ns = frame.FromLocal(ns);
```


#parec[
  This function returns partial derivatives of the surface that account for the shading normal rather than the shading normal itself. Suitable partial derivatives can be found in two steps. First, a call to #link("../Geometry_and_Transformations/Vectors.html#GramSchmidt")[GramSchmidt()] with the original $frac(partial n, partial u)$ and the new shading normal $upright(bold(n))_s$ gives the closest vector to $frac(partial n, partial u)$ that is perpendicular to $upright(bold(n))_s$. $frac(partial n, partial v)$ is then found by taking the cross product of $upright(bold(n))_s$ and the new $frac(partial n, partial v)$, giving an orthogonal coordinate system. Both of these vectors are respectively scaled to have the same length as the original $frac(partial n, partial u)$ and $frac(partial n, partial v)$ vectors.
][
  This function returns partial derivatives of the surface that account for the shading normal rather than the shading normal itself. Suitable partial derivatives can be found in two steps. First, a call to #link("../Geometry_and_Transformations/Vectors.html#GramSchmidt")[GramSchmidt()] with the original $frac(partial n, partial u)$ and the new shading normal $upright(bold(n))_s$ gives the closest vector to $frac(partial n, partial u)$ that is perpendicular to $upright(bold(n))_s$. $frac(partial n, partial v)$ is then found by taking the cross product of $upright(bold(n))_s$ and the new $frac(partial n, partial v)$, giving an orthogonal coordinate system. Both of these vectors are respectively scaled to have the same length as the original $frac(partial n, partial u)$ and $frac(partial n, partial v)$ vectors.
]

```cpp
<<Find  and  that give shading normal>>=
Float ulen = Length(ctx.shading.dpdu), vlen = Length(ctx.shading.dpdv);
*dpdu = Normalize(GramSchmidt(ctx.shading.dpdu, ns)) * ulen;
*dpdv = Normalize(Cross(ns, *dpdu)) * vlen;
```

=== Bump Mapping
<Bump-Mapping>

#parec[
  Another way to define shading normals is via a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[`FloatTexture`] that defines a displacement at each point on the surface: each point $p$ has a displaced point $p prime$ associated with it, defined by $p prime = p + d (p) upright(bold(n)) (p)$, where $d (p)$ is the offset returned by the displacement texture at $p$ and (p) is the surface normal at $p$ (@fig:display-surf). We can use this texture to compute shading normals so that the surface appears as if it actually had been offset by the displacement function, without modifying its geometry. This process is called #emph[bump mapping];. For relatively small displacement functions, the visual effect of bump mapping can be quite convincing.
][
  另一种定义着色法线的方法是通过一个 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[`FloatTexture`];，它在表面的每个点定义一个位移：每个点 $p$ 都有一个与之相关的位移点 $p prime$，定义为 $p prime = p + d (p) upright(bold(n)) (p)$，其中 $d (p)$ 是位移纹理在 $p$ 处返回的偏移量，(p)\$ 是 $p$ 处的表面法线（@fig:display-surf）。我们可以使用这种纹理来计算着色法线，使表面看起来仿佛被位移函数实际偏移过，而不修改其几何形状。这个过程称为#emph[凹凸贴图];。对于相对较小的位移函数，凹凸贴图的视觉效果可以非常逼真。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f22.svg"),
  caption: [
    #ez_caption[
      A displacement function associated with a material defines a new surface based on the old one, offset by the displacement amount along the normal at each point. pbrt does not compute a geometric representation of this displaced surface in the BumpMap() function, but instead uses it to compute shading normals for bump mapping.
    ][
      A displacement function associated with a material defines a new surface based on the old one, offset by the displacement amount along the normal at each point. pbrt does not compute a geometric representation of this displaced surface in the BumpMap() function, but instead uses it to compute shading normals for bump mapping.
    ]
  ],
)<display-surf>

#parec[
  An example of bump mapping is shown in @fig:sanmiguel-bump-vs-no , which shows part of the #emph[San Miguel] scene rendered with and without bump mapping. There, the bump map gives the appearance of a substantial amount of detail in the walls and floors that is not actually present in the geometric model. @fig:sanmiguel-bumpmap shows one of the image maps used to define the bump function in @fig:sanmiguel-bump-vs-no .
][
  图 @fig:sanmiguel-bump-vs-no 显示了凹凸贴图的一个例子，其中展示了#emph[San Miguel] 场景的一部分，分别在有和没有凹凸贴图的情况下渲染。在那里，凹凸贴图使墙壁和地板看起来具有大量细节，而这些细节实际上在几何模型中并不存在。@fig:sanmiguel-bumpmap 显示了用于定义图 @fig:sanmiguel-bump-vs-no 中凹凸函数的图像贴图之一。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f23.svg"),
  caption: [
    #ez_caption[
      Detail of the San Miguel scene, rendered (a) without bump mapping and (b) with bump mapping. Bump mapping substantially increases the apparent geometric complexity of the model, without the increased rendering time and memory use that would result from a geometric representation with the equivalent amount of small-scale detail. (Scene courtesy of Guillermo M. Leal Llaguno.)
    ][
      Detail of the San Miguel scene, rendered (a) without bump mapping and (b) with bump mapping. Bump mapping substantially increases the apparent geometric complexity of the model, without the increased rendering time and memory use that would result from a geometric representation with the equivalent amount of small-scale detail. (Scene courtesy of Guillermo M. Leal Llaguno.)
    ]
  ],
)<sanmiguel-bump-vs-no>


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f24.svg"),
  caption: [
    #ez_caption[
      The image used as a bump map for the tiles in the San Miguel rendering in Figure 10.23.
    ][
      The image used as a bump map for the tiles in the San Miguel rendering in Figure 10.23.
    ]
  ],
)<sanmiguel-bumpmap>


#parec[
  The #link("<BumpMap>")[`BumpMap()`] function is responsible for computing the effect of bump mapping at the point being shaded given a particular displacement texture. Its implementation is based on finding an approximation to the partial derivatives $frac(partial p prime, partial u)$ and $frac(partial p prime, partial v)$ of the displaced surface and using them in place of the surface's actual partial derivatives to compute the shading normal. Assume that the original surface is defined by a parametric function $p (u , v)$, and the bump offset function is a scalar function $d (u , v)$. Then the displaced surface is given by
][
  #link("<BumpMap>")[`BumpMap()`] 函数负责在给定特定位移纹理的情况下计算凹凸贴图在被着色点的效果。它的实现基于找到位移表面偏导数的近似值 $frac(partial p prime, partial u)$ 和 $frac(partial p prime, partial v)$，并用它们代替表面的实际偏导数来计算着色法线。假设原始表面由参数化函数 $p (u , v)$ 定义，凹凸偏移函数是标量函数 $d (u , v)$。那么位移表面由以下公式给出
]

$ p prime (u , v) = p (u , v) + d (u , v) upright(bold(n)) (u , v) , $
#parec[
  where $upright(bold(n)) (u , v)$ is the surface normal at $(u , v)$.
][
  其中 $upright(bold(n)) (u , v)$ 是 $(u , v)$ 处的表面法线。
]

```cpp
<<Bump Mapping Function Definitions>>=
template <typename TextureEvaluator>
void BumpMap(TextureEvaluator texEval, FloatTexture displacement,
        const NormalBumpEvalContext &ctx, Vector3f *dpdu, Vector3f *dpdv) {
    <<Compute offset positions and evaluate displacement texture>>
    <<Compute bump-mapped differential geometry>>
}
```

#parec[
  The partial derivatives of $p prime$ can be found using the chain rule. For example, the partial derivative in $u$ is
][
  $p prime$ 的偏导数可以通过链式法则找到。例如， $u$ 的偏导数为
]

$
  frac(partial p prime, partial u) = frac(partial p (u , v), partial u) + frac(partial d (u , v), partial u) upright(bold(n)) ( u , v ) + d (u , v) frac(partial upright(bold(n)) (u , v), partial u) .
$


#parec[
  We have already computed the value of $frac(partial p (u , v), partial u)$ ; it is $frac(partial n, partial u)$ and is available in the #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`] structure, which also stores the surface normal $upright(bold(n)) (u , v)$ and the partial derivative $frac(partial upright(bold(n)) (u , v), partial u) = frac(partial upright(bold(n)), partial u)$. The displacement function $d (u , v)$ can be readily evaluated, which leaves $frac(partial d (u , v), partial u)$ as the only remaining term.
][
  我们已经计算了 $frac(partial p (u , v), partial u)$ 的值；它是 $frac(partial n, partial u)$，并且在 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`] 结构中可用，该结构还存储了表面法线 $upright(bold(n)) (u , v)$ 和偏导数 $frac(partial upright(bold(n)) (u , v), partial u) = frac(partial upright(bold(n)), partial u)$。位移函数 $d (u , v)$ 可以很容易地计算，因此 $frac(partial d (u , v), partial u)$ 是唯一剩下的项。
]

#parec[
  There are two possible approaches to finding the values of $frac(partial d (u , v), partial u)$ and $frac(partial d (u , v), partial v)$. One option would be to augment the `FloatTexture` interface with a method to compute partial derivatives of the underlying texture function. For example, for image map textures mapped to the surface directly using its $(u , v)$ parameterization, these partial derivatives can be computed by subtracting adjacent texels in the $u$ and $v$ directions. However, this approach is difficult to extend to complex procedural textures like some of the ones defined earlier in this chapter. Therefore, `pbrt` directly computes these values with forward differencing, without modifying the `FloatTexture` interface.
][
  有两种可能的方法来找到 $frac(partial d (u , v), partial u)$ 和 $frac(partial d (u , v), partial v)$ 的值。一种选择是通过一种方法来增强 `FloatTexture` 接口，以计算底层纹理函数的偏导数。例如，对于直接使用其 $(u , v)$ 参数化映射到表面的图像贴图纹理，这些偏导数可以通过在 $u$ 和 $v$ 方向上减去相邻的纹素来计算。然而，这种方法很难扩展到本章前面定义的一些复杂程序纹理。因此，`pbrt` 直接通过前向差分计算这些值，而不修改 `FloatTexture` 接口。
]

#parec[
  Recall the definition of the partial derivative:
][
  回忆偏导数的定义：
]

$ frac(partial d (u , v), partial u) = lim_(Delta u arrow.r 0) frac(d (u + Delta u , v) - d (u , v), Delta u) . $

#parec[
  Forward differencing approximates the value using a finite value of $Delta u$ and evaluating $d (u , v)$ at two positions. Thus, the final expression for $frac(partial p prime, partial u)$ is the following (for simplicity, we have dropped the explicit dependence on $(u , v)$ for some of the terms):
][
  前向差分使用有限的 $Delta u$ 值来近似该值，并在两个位置评估 $d (u , v)$。因此， $frac(partial p prime, partial u)$ 的最终表达式如下（为简单起见，我们省略了一些项对
]
$
  frac(partial p prime, partial u) approx frac(partial n, partial u) + frac(d (u + Delta u , v) - d (u , v), Delta u) upright(bold(n)) + d ( u , v ) frac(partial upright(bold(n)), partial u) .
$

#parec[
  Interestingly enough, most bump-mapping implementations ignore the final term under the assumption that $d (u , v)$ is expected to be relatively small. (Since bump mapping is mostly useful for approximating small perturbations, this is a reasonable assumption.) The fact that many renderers do not compute the values $frac(partial upright(bold(n)), partial u)$ and $frac(partial upright(bold(n)), partial v)$ may also have something to do with this simplification. An implication of ignoring the last term is that the magnitude of the displacement function then does not affect the bump-mapped partial derivatives; adding a constant value to it globally does not affect the final result, since only differences of the bump function affect it. `pbrt` computes all three terms since it has $frac(partial upright(bold(n)), partial u)$ and $frac(partial upright(bold(n)), partial v)$ readily available, although in practice this final term rarely makes a visually noticeable difference.
][
  有趣的是，大多数凹凸贴图实现忽略了最后一项，假设 $d (u , v)$ 预期相对较小。（由于凹凸贴图主要用于近似小扰动，这是一个合理的假设。）许多渲染器不进行 $frac(partial upright(bold(n)), partial u)$ 和 $frac(partial upright(bold(n)), partial v)$ 的计算，这也可能与这种简化有关。忽略最后一项的一个影响是，位移函数的大小不影响凹凸贴图的偏导数；在全局上添加一个常数值不会影响最终结果，因为只有凹凸函数的差异才会影响结果。`pbrt` 计算所有三个项，因为它可以方便地获得 $frac(partial upright(bold(n)), partial u)$ 和 $frac(partial upright(bold(n)), partial v)$，尽管在实践中，这个最终项很少产生视觉上显著的差异。
]

```cpp
<<Compute offset positions and evaluate displacement texture>>=
TextureEvalContext shiftedCtx = ctx;
<<Shift shiftedCtx du in the  direction>>
Float uDisplace = texEval(displacement, shiftedCtx);
<<Shift shiftedCtx dv in the  direction>>
Float vDisplace = texEval(displacement, shiftedCtx);
Float displace = texEval(displacement, ctx);
```

#parec[
  One remaining issue is how to choose the offsets $Delta u$ and $Delta v$ for the finite differencing computations. They should be small enough that fine changes in $d (u , v)$ are captured but large enough so that available floating-point precision is sufficient to give a good result. Here, we will choose $Delta u$ and $Delta v$ values that lead to an offset that is about half the image-space pixel sample spacing and use them to update the appropriate member variables in the #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`] to reflect a shift to the offset position.
][
  剩下的一个问题是如何选择用于有限差分计算的偏移量 $Delta u$ 和 $Delta v$。它们应该足够小以捕捉 $d (u , v)$ 的细微变化，但又足够大，以便可用的浮点精度足以给出良好的结果。在这里，我们将选择 $Delta u$ 和 $Delta v$ 值，使得偏移量大约是图像空间像素样本间距的一半，并使用它们来更新 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`] 中的适当成员变量，以反映偏移位置的变化。
]

```cpp
<<Shift shiftedCtx du in the  direction>>=
Float du = .5f * (std::abs(ctx.dudx) + std::abs(ctx.dudy));
if (du == 0) du = .0005f;
shiftedCtx.p = ctx.p + du * ctx.shading.dpdu;
shiftedCtx.uv = ctx.uv + Vector2f(du, 0.f);
```

#parec[
  The `<<Shift shiftedCtx dv in the  direction>>` fragment is nearly the same as the fragment that shifts du, so it is not included here.
][
  The `<<Shift shiftedCtx dv in the  direction>>` fragment is nearly the same as the fragment that shifts du, so it is not included here.
]
#parec[
  Given the new positions and the displacement texture's values at them, the partial derivatives can be computed directly using Equation (10.12):
][
  给定新位置和位移纹理在这些位置的值，可以直接使用方程 (10.12) 计算偏导数：
]

```cpp
*dpdu = ctx.shading.dpdu +
        (uDisplace - displace) / du * Vector3f(ctx.shading.n) +
        displace * Vector3f(ctx.shading.dndu);
*dpdv = ctx.shading.dpdv +
        (vDisplace - displace) / dv * Vector3f(ctx.shading.n) +
        displace * Vector3f(ctx.shading.dndv);
```
