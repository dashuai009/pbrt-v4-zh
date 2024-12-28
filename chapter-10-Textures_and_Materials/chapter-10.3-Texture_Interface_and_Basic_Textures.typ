#import "../template.typ": parec, ez_caption

== Texture Interface and Basic Textures
<texture-interface-and-basic-textures>
#parec[
  Given a variety of ways to generate 2D and 3D texture coordinates, we will now define the general interfaces for texture functions. As mentioned earlier, `pbrt` supports two types of `Texture`s: scalar `Float`-valued, and spectral-valued.
][
  在提供了多种生成二维和三维纹理坐标的方法后，我们现在定义纹理函数的一般接口。如前所述，`pbrt` 支持两种类型的 `Texture`：`Float`标量纹理和光谱值的纹理。
]

#parec[
  For the first, there is `FloatTexture`, which is defined in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[`base/texture.h`];. There are currently 14 implementations of this interface in `pbrt`, which leads to a lengthy list of types for the #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] template class. Therefore, we have gathered them into a fragment, `<<FloatTextures>>`, that is not included here.
][
  对于第一种，有 `FloatTexture`，它在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[`base/texture.h`] 中定义。目前在 `pbrt` 中有14种此接口的实现，这导致 #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 模板类的类型列表很长。因此，我们将它们收集到一个片段 `<<FloatTextures>>` 中，这里不包括。
]

```cpp
class FloatTexture : public TaggedPointer<FloatImageTexture, GPUFloatImageTexture, FloatMixTexture, FloatDirectionMixTexture, FloatScaledTexture, FloatConstantTexture, FloatBilerpTexture, FloatCheckerboardTexture, FloatDotsTexture, FBmTexture, FloatPtexTexture, GPUFloatPtexTexture, WindyTexture, WrinkledTexture> {
  public:
    using TaggedPointer::TaggedPointer;

    static FloatTexture Create(const std::string &name, const Transform &renderFromTexture, const TextureParameterDictionary &parameters, const FileLoc *loc, Allocator alloc, bool gpu);

    std::string ToString() const;
    Float Evaluate(TextureEvalContext ctx) const;
};
```


#parec[
  A `FloatTexture` takes a #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext] and returns a `Float` value.
][
  `FloatTexture` 接受一个 #link("../Textures_and_Materials/Texture_Coordinate_Generation.html#TextureEvalContext")[TextureEvalContext] 并返回一个 `Float` 值。
]

```cpp
Float Evaluate(TextureEvalContext ctx) const;
```

#parec[
  `SpectrumTexture` plays an equivalent role for spectral textures. It also has so many implementations that we have elided their enumeration from the text. It, too, is defined in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[base/texture.h];.
][
  `SpectrumTexture` 在光谱纹理中扮演了等效的角色。它也有很多实现，因此我们省略了列举。它同样在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/texture.h")[base/texture.h] 中定义。
]

```cpp
class SpectrumTexture : public TaggedPointer<<SpectrumTextures>> SpectrumImageTexture, GPUSpectrumImageTexture, SpectrumMixTexture, SpectrumDirectionMixTexture, SpectrumScaledTexture, SpectrumConstantTexture, SpectrumBilerpTexture, SpectrumCheckerboardTexture, MarbleTexture, SpectrumDotsTexture, SpectrumPtexTexture, GPUSpectrumPtexTexture {
  public:
    // <<SpectrumTexture Interface>>
    using TaggedPointer::TaggedPointer;

    static SpectrumTexture Create(const std::string &name, const Transform &renderFromTexture, const TextureParameterDictionary &parameters, SpectrumType spectrumType, const FileLoc *loc, Allocator alloc, bool gpu);

    std::string ToString() const;
    SampledSpectrum Evaluate(TextureEvalContext ctx, SampledWavelengths lambda) const;
};
```



#parec[
  For the reasons that were discussed in @sampled-spectral-distributions, the `SpectrumTexture` evaluation routine does not return a full spectral distribution (e.g., an implementation of the `Spectrum` interface from @spectrum-interface. Rather, it takes a set of wavelengths of interest and returns the texture's value at just those wavelengths.
][
  由于在@sampled-spectral-distributions 中讨论的原因，`SpectrumTexture` 评估例程不返回完整的光谱分布（例如，来自@spectrum-interface 的 `Spectrum` 接口的实现）。相反，它接受一组感兴趣的波长并仅返回这些波长的纹理值。
]

```cpp
SampledSpectrum Evaluate(TextureEvalContext ctx, SampledWavelengths lambda) const;
```


=== Constant Texture
<constant-texture>
#parec[
  The constant textures return the same value no matter where they are evaluated. Because they represent constant functions, they can be accurately reconstructed with any sampling rate and therefore need no antialiasing. Although these two textures are trivial, they are actually quite useful. By providing these classes, all parameters to all #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[`Material`];s can be represented as `Texture`s, whether they are spatially varying or not. For example, a red diffuse object will have a #link("<SpectrumConstantTexture>")[`SpectrumConstantTexture`] that always returns red as the diffuse color of the material. This way, the material system always evaluates a texture to get the surface properties at a point, avoiding the need for separate textured and nontextured versions of materials. Such an approach would grow increasingly unwieldy as the number of material parameters increased.
][
  常量纹理无论在哪里评估都返回相同的值。因为它们表示常量函数（即不随位置变化的函数），所以可以用任何采样率精确重建，因此不需要抗锯齿。虽然这两种纹理很简单，但实际上非常有用。通过提供这些类，所有 #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[`Material`] 的所有参数都可以表示为 `Texture`，无论它们是否是空间变化的。例如，一个红色的漫反射物体将有一个 #link("<SpectrumConstantTexture>")[`SpectrumConstantTexture`];，它始终返回红色作为材料的漫反射颜色。这样，材料系统总是评估纹理以获取某点的表面属性，避免了需要分别处理纹理化和非纹理化的材料版本。随着材料参数数量的增加，这种方法将变得越来越繁琐。
]

#parec[
  `FloatConstantTexture`, like all the following texture implementations, is defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/texture.h")[texture.h] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/texture.cpp")[texture.cpp];.
][
  `FloatConstantTexture`，像所有后续的纹理实现一样，定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/texture.h")[texture.h] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/texture.cpp")[texture.cpp] 中。
]

```cpp
class FloatConstantTexture {
  public:
    FloatConstantTexture(Float value) : value(value) {}
    Float Evaluate(TextureEvalContext ctx) const { return value; }
  private:
    Float value;
};
```


#parec[
  The spectrum constant texture, `SpectrumConstantTexture`, is similarly simple. Here is its `Evaluate()` method; the rest of its structure parallels #link("<FloatConstantTexture>")[`FloatConstantTexture`] and so is not included here.
][
  光谱常量纹理 `SpectrumConstantTexture` 同样简单。以下是其 `Evaluate()` 方法；其余结构与 #link("<FloatConstantTexture>")[`FloatConstantTexture`] 类似，因此不在此处包括。
]

```cpp
SampledSpectrum Evaluate(TextureEvalContext ctx, SampledWavelengths lambda) const {
    return value.Sample(lambda);
}
```


=== Scale Texture
<scale-texture>
#parec[
  We have defined the texture interface in a way that makes it easy to use the output of one texture function when computing another. This is useful since it lets us define generic texture operations using any of the other texture types. The #link("<FloatScaledTexture>")[`FloatScaledTexture`] takes two `Float`-valued textures and returns the product of their values.
][
  我们定义了纹理接口，使得在计算另一个纹理时使用一个纹理函数的输出变得容易。这很有用，因为它允许我们使用任何其他纹理类型定义通用纹理操作。#link("<FloatScaledTexture>")[`FloatScaledTexture`] 接受两个 `Float` 值的纹理并返回它们值的乘积。
]

```cpp
class FloatScaledTexture {
  public:
    <<FloatScaledTexture Public Methods>> FloatScaledTexture(FloatTexture tex, FloatTexture scale) : tex(tex), scale(scale) {}

    static FloatTexture Create(const Transform &renderFromTexture, const TextureParameterDictionary &parameters, const FileLoc *loc, Allocator alloc);

    Float Evaluate(TextureEvalContext ctx) const {
        Float sc = scale.Evaluate(ctx);
        if (sc == 0) return 0;
        return tex.Evaluate(ctx) * sc;
    }
    std::string ToString() const;
  private:
    FloatTexture tex, scale;
};
```

#parec[
  `FloatScaledTexture` ignores antialiasing, leaving it to its two subtextures to antialias themselves but not making an effort to antialias their product. While it is easy to show that the product of two band-limited functions is also band limited, the maximum frequency present in the product may be greater than that of either of the two terms individually. Thus, even if the scale and value textures are perfectly antialiased, the result might not be. Fortunately, the most common use of this texture is to scale another texture by a constant, in which case the other texture's antialiasing is sufficient.
][
  `FloatScaledTexture` 忽略抗锯齿，将其留给两个子纹理自行抗锯齿，而不努力抗锯齿它们的乘积。虽然很容易证明两个带限函数的乘积也是带限的，但乘积中可能出现的最大频率可能大于两个项中的任何一个。因此，即使缩放和值纹理已抗锯齿，结果可能不是。幸运的是，这种纹理的最常见用途是通过常量缩放另一个纹理，在这种情况下，其他纹理的抗锯齿就足够了。
]

#parec[
  One thing to note in the implementation of its `Evaluate()` method is that it skips evaluating the `tex` texture if the scale texture returns 0. It is worthwhile to avoid incurring the cost of this computation if it is unnecessary.
][
  在其 `Evaluate()` 方法的实现中需要注意的一点是，如果缩放纹理返回0，它会跳过评估 `tex` 纹理。如果不必要，避免进行这种计算的开销是值得的。
]

```cpp
Float Evaluate(TextureEvalContext ctx) const {
    Float sc = scale.Evaluate(ctx);
    if (sc == 0) return 0;
    return tex.Evaluate(ctx) * sc;
}
```

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f11.svg"),
  caption: [
    #ez_caption[
      Use of the `SpectrumScaledTexture` in the #emph[Watercolor] Scene.
      The product of (a) a texture of paint strokes and (b) a mask
      representing splotches gives (c) colorful splotches. (d) When
      applied to the surface of a table, a convincing paint spill results.
      #emph[Scene courtesy of Angelo Ferretti.]
    ][
      在 #emph[Watercolor] 场景中使用 `SpectrumScaledTexture`。 (a)
      画笔纹理与 (b) 代表斑点的遮罩的乘积得到 (c) 彩色斑点。 (d)
      当应用于桌面时，得到一个逼真的油漆溢出效果。#emph[场景由 Angelo Ferretti 提供。]
    ]
  ],
)<scale-texture-paint>


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f12.svg"),
  caption: [
    #ez_caption[
      Use of the Mix Texture in the #emph[Kroken] Scene. (a) The
      `SpectrumMixTexture` is used to find the color at each point on the
      bottom two cups. (b) Two fixed RGB colors are modulated using this
      image texture. #emph[Scene courtesy of Angelo Ferretti.]

    ][
      在 #emph[Kroken] 场景中使用混合纹理。 (a) `SpectrumMixTexture`
      用于找到底部两个杯子上每个点的颜色。 (b) 使用此图像纹理调制两个固定的RGB颜色。#emph[场景由 Angelo Ferretti 提供。]

    ]
  ],
)<mix-texture-cup>


#parec[
  `SpectrumScaledTexture` is the straightforward variant and is therefore not included here. An example of its use is shown in @fig:scale-texture-paint.
][
  `SpectrumScaledTexture` 是直接的变体，因此不在此处包括。其使用示例如@fig:scale-texture-paint 所示。
]


=== Mix Textures
<mix-textures>
#parec[
  The mix textures are more general variations of the scale textures. They blend between two textures of the same type based on a scalar blending factor. Note that a constant texture could be used for the blending factor to achieve a uniform blend, or a more complex `Texture` could be used to blend in a spatially nonuniform way. @fig:mix-texture-cup shows the use of the `SpectrumMixTexture` where an image is used to blend between two constant RGB colors.
][
  混合纹理是缩放纹理的更一般的变体。它们在两种相同类型的纹理之间进行混合，依据的是一个标量混合因子。请注意，可以使用常量纹理作为混合因子以实现均匀混合，或者可以使用更复杂的`Texture`以空间不均匀的方式进行混合。@fig:mix-texture-cup 展示了`SpectrumMixTexture`的使用，其中使用图像在两个常量RGB颜色之间进行混合。
]

```cpp
class FloatMixTexture {
  public:
    // <<FloatMixTexture Public Methods>>
    FloatMixTexture(FloatTexture tex1, FloatTexture tex2,
                       FloatTexture amount)
           : tex1(tex1), tex2(tex2), amount(amount) {}
       Float Evaluate(TextureEvalContext ctx) const {
           Float amt = amount.Evaluate(ctx);
           Float t1 = 0, t2 = 0;
           if (amt != 1) t1 = tex1.Evaluate(ctx);
           if (amt != 0) t2 = tex2.Evaluate(ctx);
           return (1 - amt) * t1 + amt * t2;
       }
       static FloatMixTexture *Create(const Transform &renderFromTexture,
                                      const TextureParameterDictionary &parameters,
                                      const FileLoc *loc, Allocator alloc);

       std::string ToString() const;
  private:
    FloatTexture tex1, tex2;
    FloatTexture amount;
};
```

#parec[
  To evaluate the mixture, the three textures are evaluated and the floating-point value is used to linearly interpolate between the two. When the blend amount `amt` is zero, the first texture's value is returned, and when it is one the second one's value is returned. The `Evaluate()` method here makes sure not to evaluate textures unnecessarily if the blending amount implies that only one of their values is necessary. (Section 15.1.1 has further discussion about why the logic for that is written just as it is here, rather than with, for example, cascaded `if` tests that each directly return the appropriate value.) We will generally assume that `amt` will be between zero and one, but this behavior is not enforced, so extrapolation is possible as well.
][
  为了评估混合，评估三个纹理并使用浮点值在线性插值两者之间。当混合量`amt`为零时，返回第一个纹理的值，当为一时，返回第二个纹理的值。这里的`Evaluate()`方法确保如果混合量意味着只需要其中一个值，则不必要地评估纹理。（第15.1.1节进一步讨论了为什么该逻辑的编写方式正如这里所示，而不是例如使用级联的`if`测试直接返回适当的值。）我们通常假设`amt`将在零到一之间，但这种行为并未强制执行，因此也可能进行外推。
]

#parec[
  As with the scale textures, antialiasing is ignored, so the introduction of aliasing here is a possibility.
][
  与缩放纹理一样，忽略抗锯齿，因此这里引入锯齿的可能性存在。
]

```cpp
Float Evaluate(TextureEvalContext ctx) const {
    Float amt = amount.Evaluate(ctx);
    Float t1 = 0, t2 = 0;
    if (amt != 1) t1 = tex1.Evaluate(ctx);
    if (amt != 0) t2 = tex2.Evaluate(ctx);
    return (1 - amt) * t1 + amt * t2;
}
```

#parec[
  We will not include the implementation of `SpectrumMixTexture` here, as it parallels that of `FloatMixTexture`.
][
  由于`SpectrumMixTexture`与`FloatMixTexture`相似，我们在此不包含其实现。
]

#parec[
  It can also be useful to blend between two textures based on the surface's orientation. The `FloatDirectionMixTexture` and `SpectrumDirectionMixTexture` use the dot product of the surface normal with a specified direction to compute such a weight. As they are very similar, we will only discuss `SpectrumDirectionMixTexture` here.
][
  基于表面方向在两个纹理之间进行混合也很有用。`FloatDirectionMixTexture`和`SpectrumDirectionMixTexture`使用表面法线与指定方向的点积来计算这样的权重。由于它们非常相似，我们将在此仅讨论`SpectrumDirectionMixTexture`。
]

```cpp
class SpectrumDirectionMixTexture {
  public:
    <<SpectrumDirectionMixTexture Public Methods>>       SpectrumDirectionMixTexture(SpectrumTexture tex1, SpectrumTexture tex2,
                                   Vector3f dir)
           : tex1(tex1), tex2(tex2), dir(dir) {}
       SampledSpectrum Evaluate(TextureEvalContext ctx,
                                SampledWavelengths lambda) const {
           Float amt = AbsDot(ctx.n, dir);
           SampledSpectrum t1, t2;
           if (amt != 0) t1 = tex1.Evaluate(ctx, lambda);
           if (amt != 1) t2 = tex2.Evaluate(ctx, lambda);
           return amt * t1 + (1 - amt) * t2;
       }
       static SpectrumDirectionMixTexture *Create(const Transform &renderFromTexture,
                                         const TextureParameterDictionary &parameters,
                                         SpectrumType spectrumType, const FileLoc *loc,
                                         Allocator alloc);

       std::string ToString() const;
  private:
    <<SpectrumDirectionMixTexture Private Members>>       SpectrumTexture tex1, tex2;
       Vector3f dir;
};
```


```cpp
SpectrumTexture tex1, tex2;
Vector3f dir;
```


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f13.svg"),
  caption: [
    #ez_caption[
      Use of the `SpectrumDirectionMixTexture` in the #emph[Kroken] Scene.
    ][
      在#emph[Kroken];场景中使用`SpectrumDirectionMixTexture`。
    ]
  ],
)<direction-mix-book>



#parec[
  If the normal is coincident with the specified direction, `tex1` is returned; if it is perpendicular, then `tex2` is. Otherwise, the two textures are blended. @fig:direction-mix-book shows an example of the use of this texture.
][
  如果法线与指定方向重合，返回`tex1`；如果垂直，返回`tex2`。否则，两个纹理混合。@fig:direction-mix-book 展示了此纹理的使用示例。
]

```cpp
SampledSpectrum Evaluate(TextureEvalContext ctx,
                         SampledWavelengths lambda) const {
    Float amt = AbsDot(ctx.n, dir);
    SampledSpectrum t1, t2;
    if (amt != 0) t1 = tex1.Evaluate(ctx, lambda);
    if (amt != 1) t2 = tex2.Evaluate(ctx, lambda);
    return amt * t1 + (1 - amt) * t2;
}
```



