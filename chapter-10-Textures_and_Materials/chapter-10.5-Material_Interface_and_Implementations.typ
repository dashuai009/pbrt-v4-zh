// ## 翻译商榷
// 1. evalute 评估 -> 计算、求值

#import "../template.typ": parec, ez_caption, translator

== Material Interface and Implementations
<material-interface-and-implementations>

#parec[
  With a variety of textures available, we will turn to materials, first introducing the material interface and then a few material implementations. `pbrt`'s materials all follow a similar form, evaluating textures to get parameter values that are used to initialize their particular BSDF model. Therefore, we will only include a few of their implementations in the text here.
][
  在拥有了丰富的纹理之后，我们将转向材质（Materials）的讨论。
  我们会首先介绍材质接口（Material interface），然后再说明一些具体材质的实现方式。
  `pbrt` 中所有的材质遵循类似的形式：首先评估纹理（Textures），以获取初始化特定 BSDF 模型所需的参数。
  因此，本书仅选取少数几种材质的实现进行介绍。
]

#parec[
  The `Material` interface is defined by the `Material` class, which can be found in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/material.h")[base/material.h];. `pbrt` includes the implementations of 11 materials; these are enough that we have collected all of their type names in a fragment that is not included in the text.
][
  `Material` 接口由 `Material` 类定义，可以在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/material.h")[base/material.h]; 中找到。
  `pbrt` 包括了11种材质的实现，由于数量较多，我们将所有材质的类型名称归纳到了一个单独的代码片段中，该片段并未在此处正文列出。
]

```cpp
<<Material Definition>>=
// Material 类继承自 TaggedPointer，包含多种材质类型
class Material : public TaggedPointer
        <<<Material Types>>>
        CoatedDiffuseMaterial, CoatedConductorMaterial,
        ConductorMaterial, DielectricMaterial,
        DiffuseMaterial, DiffuseTransmissionMaterial, HairMaterial,
        MeasuredMaterial, SubsurfaceMaterial,
        ThinDielectricMaterial, MixMaterial {
  public:
    <<Material Interface>>
    using TaggedPointer::TaggedPointer;

    // 工厂方法：通过名称和参数创建材质实例
    static Material Create(
        const std::string &name, const TextureParameterDictionary &parameters, Image *normalMap,
        /*const */ std::map<std::string, Material> &namedMaterials,
        const FileLoc *loc, Allocator alloc);

    std::string ToString() const;

    // 获取材质对应的 BSDF
    template <typename TextureEvaluator>
    inline
    BSDF GetBSDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                SampledWavelengths &lambda, ScratchBuffer &buf) const;

    // 获取材质对应的 BSSRDF，用于次表面散射
    template <typename TextureEvaluator>
    BSSRDF GetBSSRDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                    SampledWavelengths &lambda, ScratchBuffer &buf) const;

    // 判断当前材质能否评估给定纹理
    template <typename TextureEvaluator>
    bool CanEvaluateTextures(TextureEvaluator texEval) const;

    // 获取法线贴图纹理
    const Image *GetNormalMap() const;

    // 获取置换贴图纹理
    FloatTexture GetDisplacement() const;

    // 检查材质是否支持次表面散射效果
    bool HasSubsurfaceScattering() const;
};
```

#parec[
  One of the most important methods that #link("<Material>")[Material] implementations must provide is `GetBxDF()`. It has the following signature:
][
  材质（#link("<Material>")[Material];）实现中必须提供的最重要的方法之一，就是 `GetBxDF()` ，其函数签名如下：
]

```cpp
template <typename TextureEvaluator>
ConcreteBxDF GetBxDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                     SampledWavelengths &lambda) const;
```
#parec[
  There are a few things to notice in its declaration. First, it is templated based on a type `TextureEvaluator`. This class is used by materials to, unsurprisingly, evaluate their textures. We will discuss it further in a page or two, as well as #link("<MaterialEvalContext>")[`MaterialEvalContext`];, which serves a similar role to #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`];.
][
  这里有几点需要特别注意。
  这个函数使用了模板类型参数 `TextureEvaluator` 。
  顾名思义，这个类型的对象用于材质对自身所使用的纹理进行求值。
  在接下来的内容中我们会详细探讨它的用法。
  同样需要讨论的还有 #link("<MaterialEvalContext>")[`MaterialEvalContext`]; 类，它的作用和前文提到的 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`]; 类似，我们稍后也会介绍。
]

#parec[
  Most importantly, note the return type, `ConcreteBxDF`. This type is specific to each `Material` and should be replaced with the actual #link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`] type that the material uses. (For example, the #link("<DiffuseMaterial>")[`DiffuseMaterial`] returns a #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];.) Different materials thus have different signatures for their `GetBxDF()` methods. This is unusual for an interface method in C++ and is not usually allowed with regular C++ virtual functions, though we will see shortly how `pbrt` handles the variety of them.
][
  更重要的是，请注意返回类型 `ConcreteBxDF` 。
  这个类型实际上并不是统一的，而是由具体的材质类各自定义的，应当替换为材质所真正使用的 #link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`]; 类型。
  例如， #link("<DiffuseMaterial>")[`DiffuseMaterial`]; 材质会返回 #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`]; 类型。
  因此，不同材质的 `GetBxDF()` 函数签名实际上各不相同（也就是函数签名差异）。
  在 C++ 中，接口方法通常不允许具有不同的返回类型。
  但是在 `pbrt` 中使用了一些特殊技巧，以巧妙地实现这种灵活性，我们很快就能在后文见到这种机制的具体实现。
]

#parec[
  Each `Material` is also responsible for defining the type of `BxDF` that it returns from its `GetBxDF()` method with a local type definition for the type `BxDF`. For example, #link("<DiffuseMaterial>")[DiffuseMaterial] has

  ```cpp
  using BxDF = DiffuseBxDF;
  ```

  in the body of its definition.
][
  每个 `Material` （材质）类还负责提供一个局部定义的类型 `BxDF` ，来说明其 `GetBxDF()` 方法返回的具体 `BxDF` 的类型。
  例如， #link("<DiffuseMaterial>")[DiffuseMaterial]; 类在其定义体内就包含：

  ```cpp
  using BxDF = DiffuseBxDF;
  ```
]

#parec[
  The value of defining the interface in this way is that doing so makes it possible to write generic BSDF evaluation code that is templated on the type of material. Such code can then allocate storage for the `BxDF` on the stack, for whatever type of `BxDF` the material uses. `pbrt`'s wavefront renderer, which is described in Chapter @wavefront-rendering-on-gpus, takes advantage of this opportunity. (Further details and discussion of its use there are in @surface-scattering.) A disadvantage of this design is that materials cannot return different `BxDF` types depending on their parameter values; they are limited to the one that they declare.
][
  这样的接口设计带来了明显的好处：这使得我们能够编写泛型的 BSDF 评估代码，这些代码可以根据材质的类型模板化。
  在这种方式下，无论具体材质是何种 `BxDF` 类型，代码都可以在栈（stack）上高效分配存储空间。
  `pbrt` 的 wavefront 渲染器（具体将在 @wavefront-rendering-on-gpus 中介绍）充分地利用了该特性。（有关其使用的更多细节和讨论，请参见 @surface-scattering 。）
  然而，这种设计也存在一个缺点：材质无法根据自身的参数值动态地返回不同类型的 `BxDF` ，只能固定返回其所声明的单一类型。
]

#parec[
  The #link("<Material>")[Material] class provides a `GetBSDF()` method that handles the variety of material `BxDF` return types. It requires some C++ arcana, though it centralizes the complexity of handling the diversity of types returned from the `GetBxDF()` methods.
][
  为了处理各种不同材质的 `GetBSDF()` 方法可能返回的不同类型， #link("<Material>")[Material]; 类中提供了一个 `GetBSDF()` 方法。
  实现时需要一些 C++ 的奇技淫巧，但它集中了处理 `BxDF` 需返回多种类型的复杂性。
]

#parec[
  `Material::GetBSDF()` has the same general form of most of the dynamic dispatch method implementations in `pbrt`. (We have elided almost all of them from the text since most of them are boilerplate code.) Here we define a lambda function, `getBSDF`, and call the `Dispatch()` method that #link("<Material>")[Material] inherits from #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[TaggedPointer];. Recall that `Dispatch()` uses type information encoded in a 64-bit pointer to determine which concrete material type the #link("<Material>")[Material] points to before casting the pointer to that type and passing it to the lambda.
][
  `Material::GetBSDF()` 方法与 `pbrt` 中大部分动态分派（dynamic dispatch）方法的实现形式类似。（由于这些方法的实现大多都是重复的模板代码，我们在正文中省略了大部分内容。）
  这里我们定义了一个 lambda 函数 `getBSDF` ，并调用了从 #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[TaggedPointer]; 继承来的 `Dispatch()` 方法。
  回忆一下， `Dispatch()` 方法利用存储于64位指针中的类型信息，确定 #link("<Material>")[Material] 所指向的具体材质类型，然后将指针转换为对应的类型，并传递给 lambda 函数。
]

```cpp
<<Material Inline Method Definitions>>=
template <typename TextureEvaluator>
BSDF Material::GetBSDF(
        TextureEvaluator texEval, MaterialEvalContext ctx,
        SampledWavelengths &lambda, ScratchBuffer &scratchBuffer) const {
    <<Define getBSDF lambda function for Material::GetBSDF()>>
        auto getBSDF = [&](auto mtl) -> BSDF {
            using ConcreteMtl = typename std::remove_reference_t<decltype(*mtl)>;
            using ConcreteBxDF = typename ConcreteMtl::BxDF;
            if constexpr (std::is_same_v<ConcreteBxDF, void>)
                return BSDF(); // 如果材质未定义 BxDF，则返回空的 BSDF
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
  这里的 `getBSDF` 是一个 C++ #emph[泛型lambda]; ：当调用这个 lambda 时，其参数 `auto mtl` 会有一个具体的类型，即指向 `<<Material Types>>` 中所枚举的具体材质类型的指针引用。
  给定 `mtl` 之后，我们便能够进一步获取具体材质的类型（`ConcreteMtl`），从而找到它所定义的 `BxDF` 类型（即 `ConcreteBxDF` 类型）。
  如果某种材质并不返回任何 `BxDF` ，则应将其 `BxDF` 类型定义为 `void` 。
  在这种情况下， lambda 会返回一个空的 `BSDF` 对象。（在 `pbrt` 中，只有 #link("<MixMaterial>")[MixMaterial]; 是这种特殊情况。）
]

```cpp
<<Define getBSDF lambda function for Material::GetBSDF()>>=
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
  注意，此处使用了 #link("../Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[ScratchBuffer]; 来为具体材质的 `BxDF` 分配所需的内存。
  这种方式比直接使用 C++ 的 `new` 和 `delete` 运算符更高效。
  随后，分配的内存会用材质的 `GetBxDF()` 方法返回的值初始化，最后构造完整的 `BSDF` 对象返回给调用者。
]


```cpp
<<Allocate memory for ConcreteBxDF and return BSDF for material>>=
ConcreteBxDF *bxdf = scratchBuffer.Alloc<ConcreteBxDF>();
*bxdf = mtl->GetBxDF(texEval, ctx, lambda);
return BSDF(ctx.ns, ctx.dpdus, bxdf);
```

#parec[
  Materials that incorporate subsurface scattering must define a `GetBSSRDF()` method that follows a similar form. They must also include a `using` declaration in their class definition that defines a concrete `BSSRDF` type. (The code for rendering BSSRDFs is included only in the online edition.)
][
  包含次表面散射的材质必须定义一个`GetBSSRDF()`方法，其形式应与既定模式保持一致。
  它们还必须在其类定义中包含一个 `using` 声明，以定义一个具体的 `BSSRDF` 类型。（渲染BSSRDF的代码仅在在线版本中提供。）
]

```cpp
<<Material Interface>>=
template <typename TextureEvaluator>
ConcreteBSSRDF GetBSSRDF(TextureEvaluator texEval, MaterialEvalContext ctx,
                         SampledWavelengths &lambda) const;
```
#parec[
  The #link("<Material>")[Material] class provides a corresponding `GetBSSRDF()` method that uses the provided `ScratchBuffer` to allocate storage for the material-specific `BSSRDF`.
][
  #link("<Material>")[Material]; 类提供了一个相应的 `GetBSSRDF()` 方法，该方法使用提供的 `ScratchBuffer` 为材质特定的 `BSSRDF` 分配存储空间。
]

#parec[
  The #link("<MaterialEvalContext>")[MaterialEvalContext] that `GetBxDF()` and `GetBSSRDF()` take plays a similar role to other `*EvalContext` classes: it encapsulates only the values that are necessary for material evaluation. They are a superset of those that are used for texture evaluation, so it inherits from #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext];. Doing so has the added advantage that `MaterialEvalContext`s can be passed directly to the texture evaluation methods.
][
  // #link("<MaterialEvalContext>")[MaterialEvalContext]; 类在调用 `GetBxDF()` 和 `GetBSSRDF()` 时起着类似于其他 `*EvalContext` 类的作用：即仅封装材质求值时必需的少量信息。
  // 具体地讲，它所包含的数据是纹理求值上下文（#link("<MaterialEvalContext>")[MaterialEvalContext];）的超集，因此继承了 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext]; 。
  // 这样做的另一个好处是 `MaterialEvalContext` 的实例可以直接传递给纹理评估方法。
  `GetBxDF()` 和 `GetBSSRDF()` 接受的参数 #link("<MaterialEvalContext>")[MaterialEvalContext]; 与其他 `*EvalContext` 类有类似的作用：它封装了计算材质时必需的数值。
  这些数值是用于纹理求值的上下文（#link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext];）的超集，因此它继承自 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext]; 。
  采用这种继承方式的额外好处是，可以直接将 `MaterialEvalContext` 实例传递给纹理求值方法。
]

```cpp
<<MaterialEvalContext Definition>>=
struct MaterialEvalContext : public TextureEvalContext {
    <<MaterialEvalContext Public Methods>>
       MaterialEvalContext() = default;
       MaterialEvalContext(const SurfaceInteraction &si)
           : TextureEvalContext(si), wo(si.wo), ns(si.shading.n),
             dpdus(si.shading.dpdu) {}

    Vector3f wo;     // 出射光线方向
    Normal3f ns;     // 着色法线
    Vector3f dpdus; // 表面参数化坐标系中沿 u 方向的偏导数
};
```

#parec[
  As before, there is not only a constructor that initializes a `MaterialEvalContext` from a #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] but also a constructor that takes the values for the members individually (not included here).
][
  与之前一样， `MaterialEvalContext` 不仅提供了一个从 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction]; 初始化的构造函数，还提供了一个可以分别传入各个成员值的构造函数（此处未列出）。
]

```cpp
<<MaterialEvalContext Public Methods>>=
MaterialEvalContext() = default;
MaterialEvalContext(const SurfaceInteraction &si)
    : TextureEvalContext(si), wo(si.wo), ns(si.shading.n),
      dpdus(si.shading.dpdu) {}
```

#parec[
  A `TextureEvaluator` is a class that is able to evaluate some or all of `pbrt`'s texture types. One of its methods takes a set of textures and reports whether it is capable of evaluating them, while others actually evaluate textures.
][
  `TextureEvaluator` 是一个能够评估 `pbrt` 中部分或所有纹理类型的类。
  它的一个方法接受一组纹理并报告它是否能够评估它们，而其他方法则用于评估纹理。
]

#parec[
  On the face of it, there is no obvious need for such a class: why not allow #link("<Material>")[Material];s to call the #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[Texture] `Evaluate()` methods directly? This additional layer of abstraction aids performance with the wavefront integrator; it makes it possible to separate materials into those that have lightweight textures and those with heavyweight textures and to process them separately. Doing so is beneficial to performance on the GPU; see Section @surface-scattering for further discussion.
][
  表面上看，似乎并不需要这样一个类：为什么不允许 #link("<Material>")[Material]; 直接调用 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[Texture]; 的 `Evaluate()` 方法呢？
  这种额外的抽象层有助于提高波前积分器（wavefront）的性能；它可以将材质分为两类：纹理计算量较轻的和较重的，从而区别对待，以更好地在 GPU 上优化性能。（详细请参见 @surface-scattering 。）
]

#parec[
  For now we will only define the #link("<UniversalTextureEvaluator>")[UniversalTextureEvaluator];, which can evaluate all textures. In practice, the indirection it adds is optimized away by the compiler such that it introduces no runtime overhead. It is used with all of `pbrt`'s integrators other than the one defined in Chapter @wavefront-rendering-on-gpus .
][
  目前，我们只定义 #link("<UniversalTextureEvaluator>")[UniversalTextureEvaluator]; ，它可以评估所有类型的纹理。
  实际上，编译器优化掉了它增加的间接调用（indirection），因此不会增加运行时的开销。
  它用于除 @wavefront-rendering-on-gpus 定义的积分器之外的所有 `pbrt` 积分器。
]

#translator("虽然 UniversalTextureEvaluator 作为一个额外的类，在 Material 和 Texture 之间增加了一个抽象层，但是在实际编译过程中编译器会优化掉这些间接引用。最终的机器代码相当于直接调用 Texture::Evaluate() 方法。")

```cpp
<<UniversalTextureEvaluator Definition>>=
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
  `TextureEvaluator` 必须提供一个 `CanEvaluate()` 方法，该方法接受 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture]; 和 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture]; 的列表。
  然后，它们可以检查提供的纹理类型，以确定它们是否能够评估它们。
  对于通用纹理评估器（universal texture evaluator），答案始终是肯定的。
]

```cpp
<<UniversalTextureEvaluator Public Methods>>=
bool CanEvaluate(std::initializer_list<FloatTexture>,
                 std::initializer_list<SpectrumTexture>) const {
    return true;
}
```
#parec[
  `TextureEvaluator`s must also provide `operator()` method implementations that evaluate a given texture. Thus, given a texture evaluator `texEval`, material code should use the expression `texEval(tex, ctx)` rather than `tex.Evaluate(ctx)`. The implementation of this method is again trivial for the universal evaluator. (A corresponding method for spectrum textures is effectively the same and not included here.)
][
  `TextureEvaluator` 还必须提供 `operator()` 方法实现，用于对给定的纹理进行评估。
  因此，当材质代码使用 `texEval` 时，应使用 `texEval(tex, ctx)` 这样的表达式，而不是 `tex.Evaluate(ctx)` 。
  对于通用纹理评估器，这个方法的实现依旧非常简单。（对于光谱纹理（spectrum textures）的对应方法，其实现方式基本相同，这里并没有列出。）
]

```cpp
<<UniversalTextureEvaluator Method Definitions>>=
Float UniversalTextureEvaluator::operator()(FloatTexture tex,
                                            TextureEvalContext ctx) {
    return tex.Evaluate(ctx);
}
```

#parec[
  Returning to the #link("<Material>")[Material] interface, all materials must provide a `CanEvaluateTextures()` method that takes a texture evaluator. They should return the result of calling its `CanEvaluate()` method with all of their textures provided. Code that uses #link("<Material>")[Material];s is then responsible for ensuring that a #link("<Material>")[Material];'s `GetBxDF()` or `GetBSSRDF()` method is only called with a texture evaluator that is able to evaluate its textures.
][
  回到 #link("<Material>")[Material]; 接口，所有材质都必须提供一个 `CanEvaluateTextures()` 方法，该方法接受一个纹理评估器作为参数。
  它应调用该评估器的 `CanEvaluate()` 方法，并传入材质的所有纹理，然后返回 其结果。
  使用 #link("<Material>")[Material]; 的代码需要确保： #link("<Material>")[Material]; 的 `GetBxDF()` 或 `GetBSSRDF()` 方法只能使用能够正确评估其纹理的纹理评估器。
]

```cpp
<<Material Interface>>+=
template <typename TextureEvaluator>
bool CanEvaluateTextures(TextureEvaluator texEval) const;
```

#parec[
  Materials also may modify the shading normals of objects they are bound to, usually in order to introduce the appearance of greater geometric detail than is actually present. The #link("<Material>")[Material] interface has two ways that they may do so, normal mapping and bump mapping.
][
  材质还可以修改他们所绑定对象的着色法线，通常是为了引入比实际几何细节更丰富的外观。
  #link("<Material>")[Material]; 接口提供了两种方法来实现这一点：法线贴图（normal mapping）和凹凸贴图（bump mapping）。
]

#parec[
  `pbrt`'s normal mapping code, which will be described in @normal-mapping , takes an image that specifies the shading normals. A `nullptr` value should be returned by this interface method if no normal map is included with a material.
][
  `pbrt` 的法线贴图代码将在 @normal-mapping 中描述。
  法线贴图使用一张图像来指定着色法线。
  如果材质不包含法线贴图，则此接口方法应返回 `nullptr` 。
]

```cpp
<<Material Interface>>+=
const Image *GetNormalMap() const;
```

#parec[
  Alternatively, shading normals may be specified via bump mapping, which takes a displacement function that specifies surface detail with a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture];. A `nullptr` value should be returned if no such displacement function has been specified.
][
  另一种方法是通过凹凸贴图指定着色法线。
  凹凸贴图使用一个置换函数（displacement function）来定义表面细节，该函数通过 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[FloatTexture]; 来表示。
  如果没有指定这样的置换函数，则该接口方法应返回 `nullptr` 值。
]

```cpp
<<Material Interface>>+=
FloatTexture GetDisplacement() const;
```

#parec[
  What should be returned by `HasSubsurfaceScattering()` method implementations should be obvious; this method is used to determine for which materials in a scene it is necessary to do the additional processing to model that effect.
][
  `HasSubsurfaceScattering()` 方法实现应返回什么应该是显而易见的；此方法用于确定场景中哪些材质需要进行额外处理以建模该效果。
]

```cpp
<<Material Interface>>+=
bool HasSubsurfaceScattering() const;
```


=== Material Implementations
<material-implementations>
#parec[
  With the preliminaries covered, we will now present a few material implementations. All the `Material`s in `pbrt` are fairly basic bridges between `Texture`s and `BxDF`s, so we will focus here on their basic form and some of the unique details of one of them.
][
  在介绍完基础知识后，我们现在将展示一些材质的实现方式。
  在 `pbrt` 中，所有的材质（`Material`）都是纹理（`Texture`）和声响反射分布（`BxDF`）之间的基础桥梁，因此我们将重点介绍它们的基本结构，以及某些材质的一些独特细节。
]

==== Diffuse Material
<diffuse-material>
#parec[
  `DiffuseMaterial` is the simplest material implementation and is a good starting point for understanding the material requirements.
][
  `DiffuseMaterial` 是最简单的材质实现，是理解材质需求的一个很好的起点。
]

```cpp
<<DiffuseMaterial Definition>>=
class DiffuseMaterial {
  public:
    <<DiffuseMaterial Type Definitions>>
    <<DiffuseMaterial Public Methods>>
  private:
    <<DiffuseMaterial Private Members>>
};
```

#parec[
  These are the `BxDF` and `BSSRDF` type definitions for `DiffuseMaterial`. Because this material does not include subsurface scattering, `BSSRDF` can be set to be `void`.
][
  以下是 `DiffuseMaterial` 的 `BxDF` 和 `BSSRDF` 类型定义。
  因为这种材质不包括次表面散射，所以 `BSSRDF` 可以设置为 `void`。
]

```cpp
<<DiffuseMaterial Type Definitions>>=
using BxDF = DiffuseBxDF;
using BSSRDF = void;
```
#parec[
  The constructor initializes the following member variables with provided values, so it is not included here.
][
  构造函数初始化以下成员变量，因此不在此处包含。
]

```cpp
<<DiffuseMaterial Private Members>>=
Image *normalMap;
FloatTexture displacement;
SpectrumTexture reflectance;
```

#parec[
  The `CanEvaluateTextures()` method is easy to implement; the various textures used for BSDF evaluation are passed to the given `TextureEvaluator`. Note that the displacement texture is not included here; if present, it is handled separately by the bump mapping code.
][
  `CanEvaluateTextures()` 方法的实现相对简单；用于 BSDF评估 的各种纹理被传递给指定的 `TextureEvaluator` 进行处理。
  注意，置换贴图不包括在其中；如果存在，它会由凹凸贴图代码单独处理。
]

```cpp
<<DiffuseMaterial Public Methods>>=
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
<<DiffuseMaterial Public Methods>>+=
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
  `DielectricMaterial` 表示一个电介质表面。
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

```cpp
<<DielectricMaterial Type Definitions>>=
using BxDF = DielectricBxDF;
using BSSRDF = void;
```

#parec[
  `DielectricMaterial` has a few more parameters than `DiffuseMaterial`. The index of refraction is specified with a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[`SpectrumTexture`] so that it may vary with wavelength. Note also that two roughness values are stored, which allows the specification of an anisotropic microfacet distribution. If the distribution is isotropic, this leads to a minor inefficiency in storage and, shortly, texture evaluation, since both are always evaluated.
][
  `DielectricMaterial` 比 `DiffuseMaterial` 有更多的参数。
  其中，折射率（index of refraction, IOR）通过一个 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[`SpectrumTexture`] 指定，因此它可以随波长变化。
  还要注意，材质存储了两个粗糙度值（roughness），这允许指定各向异性（anisotropic）的微表面分布。
  如果分布是各向同性（isotropic）的，这可能会导致存储和纹理评估上的轻微效率损失，因为在各向同性的情况下，总是会计算两个（一样的）粗糙度值。
]


```cpp
<<DielectricMaterial Private Members>>=
Image *normalMap;
FloatTexture displacement;
FloatTexture uRoughness, vRoughness;
bool remapRoughness;
Spectrum eta;
```

#parec[
  `GetBxDF()` follows a similar form to `DiffuseMaterial`, evaluating various textures and using their results to initialize the returned #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`];.
][
  `GetBxDF()` 的形式类似于 `DiffuseMaterial`，评估各种纹理并使用其结果初始化返回的 #link("../Reflection_Models/Dielectric_BSDF.html#DielectricBxDF")[`DielectricBxDF`]; 。
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
  如果所有波长的折射率相同，那么当光线被折射时，所有波长将遵循相同的路径。
  否则，它们将朝不同方向行进——这就是色散（dispersion）。
  在这种情况下， `pbrt` 仅根据 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[`SampledWavelengths`] 中的第一个波长跟踪单个光线路径，而不是跟踪多个光线来追踪每个波长，因此需要调用 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`]; 来终止额外的波长。（有关更多信息，请参见 @sampled-spectral-distributions 。）
]

#parec[
  #link("<DielectricMaterial>")[`DielectricMaterial`] therefore calls `TerminateSecondary()` unless the index of refraction is known to be constant, as determined by checking if `eta`'s #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`] type is a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#ConstantSpectrum")[`ConstantSpectrum`];. This check does not detect all cases where the sampled spectrum values are all the same, but it catches most of them in practice, and unnecessarily terminating the secondary wavelengths affects performance but not correctness. A bigger shortcoming of the implementation here is that there is no dispersion if light is reflected at a surface and not refracted. In that case, all wavelengths could still be followed. However, how light paths will be sampled at the surface is not known at this point in program execution.
][
  因此，在 #link("<DielectricMaterial>")[`DielectricMaterial`]; 的执行过程中，除非可以确定折射率是恒定的，否则会调用 `TerminateSecondary()` 。
  `pbrt` 通过检查 `eta` 的 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`]; 类型是否为 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#ConstantSpectrum")[`ConstantSpectrum`]; 来决定是否终止次要波长的计算。
  虽然这种检查不能完全覆盖所有采样光谱值相同的情况，但在大多数情况下，它能够正确判断。
  而且，过早终止次要波长会影响性能，但不会影响正确性。
  然而，该实现的一个更大局限是：如果光线在表面上被反射而未发生折射，则不会触发色散现象。
  实际上，在这种情况下，各个波长仍然可以沿相同路径传播，而不应该被终止。
  然而，在 #link("<DielectricMaterial>")[`DielectricMaterial`]; 这一阶段，尚无法确定光线如何在表面上被采样，因此无法正确区分反射和折射情况，从而导致这一实现缺乏色散效应的处理。
]

```cpp
<<Compute index of refraction for dielectric material>>=
Float sampledEta = eta(lambda[0]);
if (!eta.template Is<ConstantSpectrum>())
    lambda.TerminateSecondary();
```

#parec[
  It can be convenient to specify a microfacet distribution's roughness with a scalar parameter in the interval $[0 , 1]$, where values close to zero correspond to near-perfect specular reflection, rather than by specifying $alpha$ values directly. The `RoughnessToAlpha()` method performs a mapping that gives a reasonably intuitive control for surface appearance.
][
  用一个介于 $[0 , 1]$ 之间的标量参数来指定微表面分布（microfacet distribution）的粗糙度，会更加直观和方便。
  数值接近 0 时，意味着表面接近完全镜面反射；而不是直接使用 $alpha$ 参数。
  `RoughnessToAlpha()` 方法提供了一种合理的映射方式，让用户可以更直观地控制表面的外观。
]

```cpp
<<TrowbridgeReitzDistribution Public Methods>>+=
static Float RoughnessToAlpha(Float roughness) {
    return std::sqrt(roughness);
}
```

#parec[
  The `GetBxDF()` method then evaluates the roughness textures and remaps the returned values if required.
][
  `GetBxDF()` 方法然后评估粗糙度纹理，并在需要时重新映射返回的值。
]

```cpp
<<Create microfacet distribution for dielectric material>>=
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

```cpp
<<Return BSDF for dielectric material>>=
return DielectricBxDF(sampledEta, distrib);
```

==== Mix Material
<mix-material>

#parec[
  The final material implementation that we will describe in the text is #link("<MixMaterial>")[MixMaterial], which stores two other materials and uses a `Float`-valued texture to blend between them.
][
  我们最后要介绍的材质实现是混合材质（#link("<MixMaterial>")[MixMaterial]），它存储了两种不同的材质，并使用一个浮点值纹理在它们之间进行混合。
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
  `MixMaterial` 并不能完全符合 `pbrt` 的 `Material` 抽象。
  例如，它无法定义一个唯一的 `BxDF` 类型来返回，因为它的两个组成材质可能具有不同的 `BxDF`，并且这些材质本身也可能是 `MixMaterial`。
  因此，`MixMaterial` 需要在使用材质的代码中进行特殊处理。（例如，在 @finding-the-bsdf-at-a-surface 描述的 `SurfaceInteraction::GetBSDF()` 方法中，对 `MixMaterial` 有一个特殊情况。）
]

#parec[
  This is not ideal: as a general point of software design, it would be better to have abstractions that make it possible to provide this functionality without requiring special-case handling in calling code. However, we were unable to find a clean way to do this while still being able to statically reason about the type of `BxDF` a material will return; that aspect of the `Material` interface offers enough of a performance benefit that we did not want to change it.
][
  这种设计并不理想：从软件设计的角度来看，更好的做法是提供一种更加通用的抽象，使得 `Material` 的功能可以无须在调用代码中做特殊处理。
  然而，我们无法找到一种既能保持代码清晰，又能在编译时静态确定 `BxDF` 类型的方法。
  `Material` 接口当前的设计能够提供显著的性能优化，因此我们不希望为了 `MixMaterial` 的通用性而改变这一设计。
]

#parec[
  Therefore, when a `MixMaterial` is encountered, one of its constituent materials is randomly chosen, with probability given by the floating-point `amount` texture. Thus, a 50/50 mix of two materials is not represented by the average of their respective BSDFs and so forth, but instead by each of them being evaluated half the time. This is effectively the material analog of the stochastic alpha test that was described in @geometric-primitives . The `ChooseMaterial()` method implements the logic.
][
  因此，当遇到 `MixMaterial` 时，`pbrt` 会根据浮点数 `amount` 纹理给出的概率随机选择其一个混合材质。
  这样一来，一个 50/50 混合并不是简单地取两个材质各自的 BSDF 平均值等来表示，而是每次渲染时分别以 50% 的概率选取其中一个材质进行评估。
  这种方法本质上类似于 @geometric-primitives 中描述的随机 alpha 测试，只是这里应用在了材质上。
  `ChooseMaterial()` 方法实现了这一逻辑。
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
      Effect of Sampling Rate with the MixMaterial. In this scene, the MixMaterial is used to blend between blue and red diffuse materials for the dragon, using an equal weighting for each. (a) With one sample per pixel, there is visible noise in the corresponding pixels since each pixel only includes one of the two constituent materials. (b) With a sufficient number of samples (here, 128), stochastic selection of materials causes no visual harm. In practice, the pixel sampling rates necessary to reduce other forms of error from simulating light transport are almost always enough to resolve stochastic material sampling.
    ][
      采样率对 MixMaterial 的影响。
      在这个场景中，MixMaterial 被用来在红色和蓝色的漫反射材质之间进行混合，且两者的权重相等。
      (a) 当每像素仅使用一次采样时，
      由于每个像素只能随机选择红色或蓝色中的一个，导致图像中出现明显的噪声。
      (b) 当采样次数足够多（此处为 128 次）时，材质的随机选择不会对视觉效果造成影响。
      在实际操作中，为减少其他因模拟光线传播引起的误差而所需的像素采样率，几乎总是足以解决随机材质采样的问题。
    ]
  ],
)<mix-material-stoshastic>

#parec[
  Stochastic selection of materials can introduce noise in images at low sampling rates; see @fig:mix-material-stoshastic. However, a few tens of samples are generally plenty to resolve any visual error. Furthermore, this approach does bring benefits: sampling and evaluation of the resulting #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`] is more efficient than if it was a weighted sum of the #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`]s from the constituent materials.
][
  材质的随机选择可能会在低采样率下引入噪声，参考 @fig:mix-material-stoshastic 。
  然而，通常只需几十次采样，就足以消除这种视觉误差。
  此外，这种方法带来了计算上的优势：相比于直接对两个材质的 #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`] 进行加权平均，随机选择一种材质进行采样和评估的方式更加高效，减少了计算开销。
]

#parec[
  `MixMaterial` provides an accessor that makes it possible to traverse all the materials in the scene, including those nested inside a MixMaterial, so that it is possible to perform operations such as determining which types of materials are and are not present in a scene.
][
  `MixMaterial` 提供了一个访问器（accessor），使得遍历场景中的所有材质成为可能，包括嵌套在 MixMaterial 内部的材质。
  这样，渲染器可以执行一些全局操作，例如检查场景中存在哪些类型的材质，以及哪些材质不存在。
]

```cpp
<<MixMaterial Public Methods>>+=
Material GetMaterial(int i) const { return materials[i]; }
```

#parec[
  A fatal error is issued if the `GetBxDF()` method is called. A call to `GetBSSRDF()` is handled similarly, in code not included here.
][
  调用 `GetBxDF()` 方法会引发致命错误。
  同样，对于 `GetBSSRDF()` 的调用也以类似方式处理，相关代码未包含在此处。
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
  由于 `pbrt` 的 #link("../Introduction/pbrt_System_Overview.html#Integrator")[`Integrator`]; 使用 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`]; 类来收集与每个交点相关的必要信息，我们将向该类添加一个 `GetBSDF()` 方法，以处理计算交点 BSDF 的所有相关细节。
]

```cpp
<<SurfaceInteraction Method Definitions>>+=
BSDF SurfaceInteraction::GetBSDF(
        const RayDifferential &ray, SampledWavelengths &lambda,
        Camera camera, ScratchBuffer &scratchBuffer, Sampler sampler) {
    <<Estimate (u, v) and position differentials at intersection point>>
    <<Resolve MixMaterial if necessary>>
    <<Return unset BSDF if surface has a null material>>
    <<Evaluate normal or bump map, if present>>
    <<Return BSDF for surface interaction>>
}
```

#parec[
  This method first calls the `SurfaceInteraction`'s `ComputeDifferentials()` method to compute information about the projected size of the surface area around the intersection on the image plane for use in texture antialiasing.
][
  此方法首先调用 `SurfaceInteraction` 的 `ComputeDifferentials()` 方法，以计算交点周围表面区域在图像平面上的投影尺寸信息，用于纹理的抗锯齿处理。
]

```cpp
<<Estimate (u, v) and position differentials at intersection point>>=
ComputeDifferentials(ray, camera, sampler.SamplesPerPixel());
```

#parec[
  As described in @mix-material , if there is a #link("<MixMaterial>")[`MixMaterial`] at the intersection point, it is necessary to resolve it to be a regular material. A `while` loop here ensures that nested `MixMaterial`s are handled correctly.
][
  如 @mix-material 所述，如果交点处存在 #link("<MixMaterial>")[`MixMaterial`]; ，则需要将其解析为常规材质。
  这里的 `while` 循环确保正确处理嵌套的 `MixMaterial`。
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
  如果最终材质为 `nullptr` ，则表示这是两种参与介质（participating media）之间的非散射（non-scattering）界面。
  在这种情况下，将返回一个默认的未初始化 `BSDF`。
]

```cpp
<<Return unset BSDF if surface has a null material>>=
if (!material)
    return {};
```

#parec[
  Otherwise, normal or bump mapping is performed before the #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`] is created.
][
  否则，在创建 #link("../Reflection_Models/BSDF_Representation.html#BSDF")[`BSDF`] 之前会先执行法线或凹凸贴图。
]

```cpp
<<Evaluate normal or bump map, if present>>=
FloatTexture displacement = material.GetDisplacement();
const Image *normalMap = material.GetNormalMap();
if (displacement || normalMap) {
    <<Get shading ∂p/∂u and ∂p/∂v using normal or bump map>>
    Normal3f ns(Normalize(Cross(dpdu, dpdv)));
    SetShadingGeometry(ns, dpdu, dpdv, shading.dndu, shading.dndv, false);
}
```

#parec[
  The appropriate utility function for normal or bump mapping is called, depending on which technique is to be used.
][
  根据使用的技术，调用相应的法线贴图或凹凸贴图函数。
]

```cpp
<<Get shading ∂p/∂u and ∂p/∂v using normal or bump map>>=
Vector3f dpdu, dpdv;
if (normalMap)
    NormalMap(*normalMap, *this, &dpdu, &dpdv);
else
    BumpMap(UniversalTextureEvaluator(), displacement, *this, &dpdu, &dpdv);
```

#parec[
  With differentials both for texture filtering and for shading geometry now settled, the #link("<Material::GetBSDF>")[`Material::GetBSDF()`] method can be called. Note that the universal texture evaluator is used both here and previously in the method, as there is no need to distinguish between different texture complexities in this part of the system.
][
  现在，纹理过滤和着色几何的微分都已确定，可以调用 #link("<Material::GetBSDF>")[`Material::GetBSDF()`]; 方法。
  请注意，通用纹理评估器在此方法中和之前都被使用，因为在系统的这一部分不需要区分不同的纹理复杂性。
]

```cpp
<<Return BSDF for surface interaction>>=
BSDF bsdf = material.GetBSDF(UniversalTextureEvaluator(), *this, lambda,
                             scratchBuffer);
if (bsdf && GetOptions().forceDiffuse) {
    <<Override bsdf with diffuse equivalent>>
}
return bsdf;
```

#parec[
  `pbrt` provides an option to override all the materials in a scene with equivalent diffuse BSDFs; doing so can be useful for some debugging problems. In this case, the hemispherical–directional reflectance is used to initialize a #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`];.
][
  `pbrt` 提供了一个选项，可以用等效的漫反射 BSDF 替换场景中的所有材料；这样做对于某些调试问题可能很有用。
  在这种情况下，使用半球-方向反射率来初始化 #link("../Reflection_Models/Diffuse_Reflection.html#DiffuseBxDF")[`DiffuseBxDF`]; 。
]

```cpp
<<Override bsdf with diffuse equivalent>>=
SampledSpectrum r = bsdf.rho(wo, {sampler.Get1D()}, {sampler.Get2D()});
bsdf = BSDF(shading.n, shading.dpdu,
            scratchBuffer.Alloc<DiffuseBxDF>(r));
```

#parec[
  The `SurfaceInteraction::GetBSSRDF()` method, not included here, follows a similar path before calling #link("<Material::GetBSSRDF>")[Material::GetBSSRDF];.
][
  未在此处包含的 `SurfaceInteraction::GetBSSRDF()` 方法在调用 #link("<Material::GetBSSRDF>")[Material::GetBSSRDF]; 之前遵循类似的路径。
]

=== Normal mapping
<normal-mapping>

#parec[
  Normal mapping is a technique that maps tabularized surface normals stored in images to surfaces and uses them to specify shading normals in order to give the appearance of fine geometric detail.
][
  法线贴图是一种将表格化的表面法线映射到表面上的技术。
  使用它们来指定着色法线，以呈现细致的几何细节。
]

#parec[
  With normal maps, one must choose a coordinate system for the stored normals. While any coordinate system may be chosen, one of the most useful is the local shading coordinate system at each point on a surface where the $z$ axis is aligned with the surface normal and tangent vectors are aligned with $x$ and $y$. (This is the same as the reflection coordinate system described in @bsdf-geom-and-conventions.) When that coordinate system is used, the approach is called #emph[tangent-space normal mapping];. With tangent-space normal mapping, a given normal map can be applied to a variety of shapes, while choosing a coordinate system like object space would closely couple a normal map's encoding to a specific geometric object.
][
  使用法线贴图时，必须为存储的法线选择一个坐标系。
  虽然可以选择任何坐标系，但其中最有用的一种是局部着色坐标系（local shading coordinate），其中 $z$ 轴与表面法线对齐，切线向量与 $x$ 和 $y$ 对齐。（这与@bsdf-geom-and-conventions 中描述的反射坐标系相同。）
  当使用该坐标系时，这种方法称为 #emph[切线空间法线贴图]; 。
  使用切线空间法线贴图时，可以将同一个法线贴图应用于各种形状，而如果选择如物体空间（object space）作为坐标系统，则法线贴图的编码会与特定的几何对象紧密绑定，限制了其适用性。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f21.svg"),
  caption: [
    #ez_caption[
      (a) A normal map modeling wrinkles for a pillow model. (b) Pillow geometry without normal map. (c) When applied to the pillow, the normal map gives a convincing approximation to more detailed geometry than is actually present. (Scene courtesy of Angelo Ferretti.)
    ][
      (a) 一个用于模拟枕头模型皱褶的法线贴图。
      (b) 不使用法线贴图的枕头几何形状。
      (c) 当法线贴图应用到枕头模型上时，它能够逼真地近似更精细的几何细节，而实际几何并未包含这些细节。
      （场景由 Angelo Ferretti 提供。）
    ]
  ],
)<normal-map>

#parec[
  Normal maps are traditionally encoded in RGB images, where red, green, and blue respectively store the $x$, $y$, and $z$ components of the surface normal. When tangent-space normal mapping is used, normal map images are typically predominantly blue, reflecting the fact that the $z$ component of the surface normal has the largest magnitude unless the normal has been substantially perturbed. (See @fig:normal-map .)
][
  法线贴图通常被编码为 RGB 图像，其中红、绿、蓝通道分别存储表面法线的 $x$ 、 $y$ 和 $z$ 分量。
  当使用切线空间法线贴图时，法线贴图图像通常主要是蓝色的，反映了表面法线的 $z$ 分量具有最大幅度，除非法线被大幅扰动。（参见 @fig:normal-map 。）
]

#parec[
  This RGB encoding brings us to an unfortunate casualty from the adoption of spectral rendering in this version of `pbrt`: while `pbrt`'s #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] previously returned RGB colors, they now return point-sampled spectral values. If an RGB image map is used for a spectrum texture, it is not possible to exactly reconstruct the original RGB colors; there will unavoidably be error in the Monte Carlo estimator that must be evaluated to find RGB. Introducing noise in the orientations of surface normals is unacceptable, since it would lead to systemic bias in rendered images. Consider a bumpy shiny object: error in the surface normal would lead to scattered rays intersecting objects that they would never intersect given the correct normals, which could cause arbitrarily large error.
][
  这种 RGB 编码在本版 `pbrt` 采用光谱渲染时带来了不幸的问题：虽然 `pbrt` 的 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] 以前返回的是 RGB 颜色，但现在返回逐点采样的光谱值。
  如果将 RGB 图像贴图用于光谱纹理，则无法精确重建原始 RGB 颜色；
  蒙特卡罗估计器在计算 RGB 时将不可避免地产生误差。
  在法线映射中引入噪声是不可接受的，因为这会导致渲染图像出现系统性偏差。
  举个例子，考虑一个有凹凸表面的光滑反射物体：表面法线的误差会导致散射的光线与它们在正确法线下永远不会相交的物体相交，这可能导致不可预测的大幅偏差。
]

#parec[
  We might avoid that problem by augmenting the #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture] interface to include a method that returned RGB color, introducing a separate `RGBTexture` interface and texture implementations, or by introducing a `NormalTexture` that returned normals directly. Any of these could cleanly support normal mapping, though all would require a significant amount of additional code.
][
  为了解决这个问题，我们可以扩展 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#SpectrumTexture")[SpectrumTexture]; 接口以包含返回 RGB 颜色的方法，引入一个单独的 `RGBTexture` 接口及其纹理实现；或者引入一个直接返回法线的 `NormalTexture` 。
  这些方法都可以优雅地支持法线映射，尽管它们都需要大量额外的代码。
]

#parec[
  Because the capability of directly looking up RGB values is only needed for normal mapping, the `NormalMap()` function therefore takes an #link("../Utilities/Images.html#Image")[Image] to specify the normal map. It assumes that the first three channels of the image represent red, green, and blue. With this approach we have lost the benefits of being able to scale and mix textures as well as the ability to apply a variety of mapping functions to compute texture coordinates. While that is unfortunate, those capabilities are less often used with normal maps than with other types of textures, and so we prefer not to make the `Texture` interfaces more complex purely for normal mapping.
][
  由于直接查找 RGB 值的能力仅在法线贴图中需要，所以 `NormalMap()` 函数因此采用一个 #link("../Utilities/Images.html#Image")[Image]; 来指定法线贴图。
  它假设图像的前三个通道代表红、绿、蓝。
  采用这种方法后，我们失去了缩放和混合纹理以及应用各种映射函数计算纹理坐标的能力。
  尽管这有些遗憾，但这些功能在法线贴图中的使用频率远低于其他类型的纹理，因此我们更倾向于不让 `Texture` 接口因法线映射而变得复杂。
]

```cpp
<<Normal Mapping Function Definitions>>=
void NormalMap(const Image &normalMap, const NormalBumpEvalContext &ctx,
               Vector3f *dpdu, Vector3f *dpdv) {
    <<Get normalized normal vector from normal map>>
    <<Transform tangent-space normal to rendering space>>
    <<Find ∂p/∂u and ∂p/∂u that give shading normal>>
}
```

#parec[
  Both `NormalMap()` and #link("<BumpMap>")[`BumpMap()`] take a NormalBumpEvalContext to specify the local geometric information for the point where the shading geometry is being computed.
][
  `NormalMap()` 和 #link("<BumpMap>")[`BumpMap()`] 都接受一个 NormalBumpEvalContext 作为参数，以指定计算着色几何（shading geometry）时该点的局部几何信息。
]

```cpp
<<NormalBumpEvalContext Definition>>=
struct NormalBumpEvalContext {
    <<NormalBumpEvalContext Public Methods>>
    <<NormalBumpEvalContext Public Members>>
};
```

#parec[
  As usual, it has a constructor, not included here, that performs initialization given a #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`]; .
][
  和之前一样，它具有一个构造函数（在此处未列出），该构造函数根据 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`]; 进行初始化。
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
  It also provides a conversion operator to #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext]; , which only needs a subset of the values stored in NormalBumpEvalContext.
][
  它还提供了一个转换运算符 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext]; ，后者仅需要 NormalBumpEvalContext 中储存的部分值。
]

```cpp
<<NormalBumpEvalContext Public Methods>>=
operator TextureEvalContext() const {
    return TextureEvalContext(p, dpdx, dpdy, n, uv, dudx, dudy,
                              dvdx, dvdy);
}
```

#parec[
  The first step in the normal mapping computation is to read the tangent-space normal vector from the image map. The image wrap mode is hard-coded here since Repeat is almost always the desired mode, though it would be easy to allow the wrap mode to be set via a parameter. Note also that the $v$ coordinate is inverted, again following the image texture coordinate convention discussed in @image-texture-evaluation .
][
  法线映射的第一步是从图像贴图中读取切线空间法线向量。
  此处的图像环绕模式（wrap mode）被硬编码为 Repeat，因为在大多数情况下，这是最理想的模式。
  不过，若需要支持不同的环绕模式，通过参数设置也是相对容易的。
  此外，需要注意 $v$ 坐标被反转，这一点与 @image-texture-evaluation 讨论的图像纹理坐标约定保持一致。
]

#parec[
  Normal maps are traditionally encoded in fixed-point image formats with pixel values that range from $0$ to $1$. This encoding allows the use of compact 8-bit pixel representations as well as compressed image formats that are supported by GPUs. Values read from the image must therefore be remapped to the range $[-1, 1]$ to reconstruct an associated normal vector. The normal vector must be renormalized, as both the quantization in the image pixel format and the bilinear interpolation may have caused it to be non-unit-length.
][
  法线贴图通常是被编码为定点格式（fixed-point image formats），其像素值范围为 $0$ 到 $1$ 。
  这种编码方式紧凑的 8 位像素表示，同时也支持 GPU 兼容的压缩图像格式。
  因此，从图像中读取的值必须 重新映射到 $[-1, 1]$ 区间，以正确重建对应的法线向量。
  此外，法线向量需要重新归一化，因为像素格式的量化（quantization）以及双线性插值（bilinear interpolation）可能会导致其不再是单位长度。
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
  为了将法线转换到渲染空间（rendering space），可以使用一个 Frame 来指定一个 坐标系，其中 原始着色法线（shading normal）与 $+z$ 轴对齐。将 切线空间（tangent-space） 法线转换到这个坐标系后，就得到了渲染空间法线（rendering-space normal）。
]

```cpp
<<Transform tangent-space normal to rendering space>>=
Frame frame = Frame::FromZ(ctx.shading.n);
ns = frame.FromLocal(ns);
```

#parec[
  This function returns partial derivatives of the surface that account for the shading normal rather than the shading normal itself. Suitable partial derivatives can be found in two steps. First, a call to #link("../Geometry_and_Transformations/Vectors.html#GramSchmidt")[GramSchmidt()] with the original $partial p \/ partial u$ and the new shading normal $upright(bold(n))_s$ gives the closest vector to $partial p \/ partial u$ that is perpendicular to $upright(bold(n))_s$. $partial p \/ partial v$ is then found by taking the cross product of $upright(bold(n))_s$ and the new $partial p \/ partial v$ , giving an orthogonal coordinate system. Both of these vectors are respectively scaled to have the same length as the original $partial p \/ partial u$ and $partial p \/ partial v$ vectors.
][
  此函数返回考虑了着色法线影响的曲面偏导数，而不是直接返回着色法线本身。
  可以通过以下两个步骤找到合适的偏导数。
  首先，使用原始的 $partial p \/ partial u$ 和新的着色法线 $upright(bold(n))_s$ 调用 #link("../Geometry_and_Transformations/Vectors.html#GramSchmidt")[GramSchmidt()]; 进行正交化。
  然后，通过 $upright(bold(n))_s$ 与新的 $partial p \/ partial u$ 进行叉乘，计算新的 $partial p \/ partial v$ ，从而构建一个正交坐标系。
  最终，这两个向量分别被缩放，使其长度与原始的 $partial p \/ partial u$ 和 $partial p \/ partial v$ 相同，从而保持原始的尺度信息。
]

```cpp
<<Find ∂p/∂u and ∂p/∂v that give shading normal>>=
Float ulen = Length(ctx.shading.dpdu), vlen = Length(ctx.shading.dpdv);
*dpdu = Normalize(GramSchmidt(ctx.shading.dpdu, ns)) * ulen;
*dpdv = Normalize(Cross(ns, *dpdu)) * vlen;
```

=== Bump Mapping
<Bump-Mapping>

#parec[
  Another way to define shading normals is via a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[`FloatTexture`] that defines a displacement at each point on the surface: each point $p$ has a displaced point $p prime$ associated with it, defined by $p prime = p + d (p) upright(bold(n)) (p)$, where $d (p)$ is the offset returned by the displacement texture at $p$ and $n(p)$ is the surface normal at $p$ (@fig:display-surf). We can use this texture to compute shading normals so that the surface appears as if it actually had been offset by the displacement function, without modifying its geometry. This process is called #emph[bump mapping];. For relatively small displacement functions, the visual effect of bump mapping can be quite convincing.
][
  另一种定义着色法线的方法是通过一个 #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatTexture")[`FloatTexture`]; ，它在表面的每个点定义一个置换（displacement）：每个点 $p$ 都有一个与之相关的置换点（displaced point） $p prime$ ，定义为 $p prime = p + d (p) upright(bold(n)) (p)$ ，其中 $d (p)$ 是置换贴图在 $p$ 处返回的偏移量，$n(p)$ 是 $p$ 处的表面法线（参见 @fig:display-surf ）。
  我们可以利用这个贴图来计算着色法线，使得表面看起来好像被置换函数改变了几何形态，而实际上并没有修改其几何结构。
  这个过程称为 #emph[凹凸贴图]; 。
  对于相对较小的置换函数，凹凸贴图的视觉效果可以非常逼真。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f22.svg"),
  caption: [
    #ez_caption[
      A displacement function associated with a material defines a new surface based on the old one, offset by the displacement amount along the normal at each point. `pbrt` does not compute a geometric representation of this displaced surface in the #link("<BumpMap>")[`BumpMap()`] function, but instead uses it to compute shading normals for bump mapping.
    ][
      与材质相关联的置换函数基于原有表面定义了一个新的表面，该新表面沿着每个点的法线方向按置换量偏移。
      在 #link("<BumpMap>")[`BumpMap()`] 函数中，`pbrt` 并不会直接计算这个置换后的几何曲面，而是利用它来计算凹凸贴图的着色法线。
    ]
  ],
)<display-surf>

#parec[
  An example of bump mapping is shown in @fig:sanmiguel-bump-vs-no , which shows part of the #emph[San Miguel] scene rendered with and without bump mapping. There, the bump map gives the appearance of a substantial amount of detail in the walls and floors that is not actually present in the geometric model. @fig:sanmiguel-bumpmap shows one of the image maps used to define the bump function in @fig:sanmiguel-bump-vs-no .
][
  @fig:sanmiguel-bump-vs-no 展示了凹凸贴图的一个示例，该图对比了在 #emph[San Miguel] 场景中，使用和未使用凹凸贴图的渲染效果。
  在该场景中，凹凸贴图使墙壁和地板呈现出大量的细节，而这些细节实际上并不存在于几何模型中。
  @fig:sanmiguel-bumpmap 显示了用于定义 @fig:sanmiguel-bump-vs-no 中凹凸函数的某个图像纹理。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f23.svg"),
  caption: [
    #ez_caption[
      Detail of the #emph[San Miguel] scene, rendered (a) without bump mapping and (b) with bump mapping. Bump mapping substantially increases the apparent geometric complexity of the model, without the increased rendering time and memory use that would result from a geometric representation with the equivalent amount of small-scale detail. #emph[(Scene courtesy of Guillermo M. Leal Llaguno.)]
    ][
      #emph[San Miguel]; 场景的细节展示：(a) 未使用凹凸贴图，(b) 使用了凹凸贴图。凹凸贴图显著增强了模型的表观几何复杂度，而不会像直接使用等效的小尺度几何细节那样增加渲染时间和内存消耗。 #emph[（场景由 Guillermo M. Leal Llaguno 提供。）];
    ]
  ],
)<sanmiguel-bump-vs-no>

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f24.svg"),
  caption: [
    #ez_caption[
      The image used as a bump map for the tiles in the #emph[San Miguel] rendering in @fig:sanmiguel-bump-vs-no .
    ][
      用于 #emph[San Miguel]; 渲染中瓷砖凹凸贴图的图像（见 @fig:sanmiguel-bump-vs-no）。
    ]
  ],
)<sanmiguel-bumpmap>

#parec[
  The #link("<BumpMap>")[`BumpMap()`] function is responsible for computing the effect of bump mapping at the point being shaded given a particular displacement texture. Its implementation is based on finding an approximation to the partial derivatives $partial p \/ partial u$ and $partial p \/ partial v$ of the displaced surface and using them in place of the surface's actual partial derivatives to compute the shading normal. Assume that the original surface is defined by a parametric function $p (u , v)$, and the bump offset function is a scalar function $d (u , v)$. Then the displaced surface is given by
][
  #link("<BumpMap>")[`BumpMap()`]; 函数负责根据给定的置换贴图计算凹凸贴图的效果。
  它的实现基于找到位移表面偏导数的近似值 $partial p \/ partial u$ 和 $partial p \/ partial v$ ，并用它们代替表面的实际偏导数来计算着色法线。
  假设原始表面由参数化函数 $p (u , v)$ 定义，凹凸偏移函数是标量函数 $d (u , v)$ 。
  那么置换后的表面可以表示为
]

$
  p prime (u , v) = p (u , v) + d (u , v) upright(bold(n)) (u , v) ,
$

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
$ <bump-map>


#parec[
  We have already computed the value of $partial p (u , v) \/ partial u$ ; it is $partial p \/ partial u$ and is available in the #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`] structure, which also stores the surface normal $upright(bold(n)) (u , v)$ and the partial derivative $partial upright(bold(n)) (u , v) \/ partial u = partial upright(bold(n)) \/ partial u$. The displacement function $d (u , v)$ can be readily evaluated, which leaves $partial d (u , v) \/ partial u$ as the only remaining term.
][
  我们已经计算了 $partial p (u , v) \/ partial u$ 的值，即 $partial p \/ partial u$ ，并且它存储在 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[`TextureEvalContext`] 结构中。
  该结构还存储了表面法线 $upright(bold(n)) (u , v)$ 和偏导数 $partial upright(bold(n)) (u , v) \/ partial u = partial upright(bold(n)) \/ partial u$ 。
  置换函数 $d (u , v)$ 可以直接求值，因此剩下唯一需要计算的项是 $partial d (u , v) \/ partial u$ 。
]

#parec[
  There are two possible approaches to finding the values of $partial d (u , v) \/ partial u$ and $partial d (u , v) \/ partial v$. One option would be to augment the `FloatTexture` interface with a method to compute partial derivatives of the underlying texture function. For example, for image map textures mapped to the surface directly using its $(u , v)$ parameterization, these partial derivatives can be computed by subtracting adjacent texels in the $u$ and $v$ directions. However, this approach is difficult to extend to complex procedural textures like some of the ones defined earlier in this chapter. Therefore, `pbrt` directly computes these values with forward differencing, without modifying the `FloatTexture` interface.
][
  有两种可能的方法来找到 $partial d (u , v) \/ partial u$ 和 $partial d (u , v) \/ partial v$ 的值。一种选择是通过一种方法来增强 `FloatTexture` 接口，以计算底层纹理函数的偏导数。例如，对于直接使用其 $(u , v)$ 参数化映射到表面的图像贴图纹理，这些偏导数可以通过在 $u$ 和 $v$ 方向上减去相邻的纹素来计算。然而，这种方法很难扩展到本章前面定义的一些复杂程序纹理。因此，`pbrt` 直接通过前向差分计算这些值，而不修改 `FloatTexture` 接口。
]

#parec[
  Recall the definition of the partial derivative:
][
  回忆偏导数的定义：
]

$
  frac(partial d (u , v), partial u) = lim_(Delta u arrow.r 0) frac(d (u + Delta u , v) - d (u , v), Delta u) .
$

#parec[
  Forward differencing approximates the value using a finite value of $Delta u$ and evaluating $d (u , v)$ at two positions. Thus, the final expression for $partial p prime \/ partial u$ is the following (for simplicity, we have dropped the explicit dependence on $(u , v)$ for some of the terms):
][
  前向差分使用有限的 $Delta u$ 值来近似该值，并在两个位置评估 $d (u , v)$。
  因此， $partial p prime \/ partial u$ 的最终表达式如下（为简单起见，我们省略了一些项对 $(u , v)$ 的显式依赖）：
]
$
  frac(partial p prime, partial u) approx frac(partial p, partial u) + frac(d (u + Delta u , v) - d (u , v), Delta u) upright(bold(n)) + d ( u , v ) frac(partial upright(bold(n)), partial u) .
$

#parec[
  Interestingly enough, most bump-mapping implementations ignore the final term under the assumption that $d (u , v)$ is expected to be relatively small. (Since bump mapping is mostly useful for approximating small perturbations, this is a reasonable assumption.) The fact that many renderers do not compute the values $partial upright(bold(n)) \/ partial u$ and $partial upright(bold(n)) \/ partial v$ may also have something to do with this simplification. An implication of ignoring the last term is that the magnitude of the displacement function then does not affect the bump-mapped partial derivatives; adding a constant value to it globally does not affect the final result, since only differences of the bump function affect it. `pbrt` computes all three terms since it has $partial upright(bold(n)) \/ partial u$ and $partial upright(bold(n)) \/ partial v$ readily available, although in practice this final term rarely makes a visually noticeable difference.
][
  有趣的是，大多数凹凸贴图实现都会忽略最终项，这是基于 $d (u , v)$ 影响相对较小的假设。（由于凹凸贴图主要用于近似小扰动，这是一个合理的假设。）
  许多渲染器不进行 $partial upright(bold(n)) \/ partial u$ 和 $partial upright(bold(n)) \/ partial v$ 的计算，这也可能与这种简化有关。
  忽略最后一项的一个含义是，置换函数的大小不影响凹凸贴图的偏导数；因为只有凹凸函数的差值才会影响最终结果，因此在全局上添加一个常数值不会影响最终结果，
  `pbrt` 计算所有三个项，因为它可以直接获得 $partial upright(bold(n)) \/ partial u$ 和 $partial upright(bold(n)) \/ partial v$ ，尽管在实践中，这个最终项对视觉效果的影响通常微乎其微。
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
  `<<Shift shiftedCtx dv in the  direction>>` 代码片段与用于偏移 du 的片段几乎相同，因此此处不再重复包含。
]
#parec[
  Given the new positions and the displacement texture's values at them, the partial derivatives can be computed directly using @eqt:bump-map :
][
  在获得新的位置以及这些位置处的置换贴图值后，可以直接使用 @eqt:bump-map 计算偏导数：
]

```cpp
<<Compute bump-mapped differential geometry>>=
*dpdu = ctx.shading.dpdu +
        (uDisplace - displace) / du * Vector3f(ctx.shading.n) +
        displace * Vector3f(ctx.shading.dndu);
*dpdv = ctx.shading.dpdv +
        (vDisplace - displace) / dv * Vector3f(ctx.shading.n) +
        displace * Vector3f(ctx.shading.dndv);
```
