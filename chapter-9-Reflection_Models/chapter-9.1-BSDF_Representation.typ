#import "../template.typ": parec, ez_caption
== BSDF Representation
#parec[
  There are two components of pbrt's representation of BSDFs: the BxDF interface and its implementations (described in @BxDF_Interface ) and the BSDF class (described in @bsdfs). The former models specific types of scattering at surfaces, while the latter provides a convenient wrapper around a pointer to a specific BxDF implementation. The BSDF class also centralizes general functionality so that BxDF implementations do not individually need to handle it, and it records information about the local geometric properties of the surface.
][
  pbrt对BSDF的表示包括两个部分：BxDF接口及其实现（ @BxDF_Interface ）和BSDF类（见@bsdfs）。前者模拟表面的特定类型散射，而后者提供了一个围绕特定BxDF实现的指针的便捷封装。BSDF类还集中了通用功能，因此BxDF实现不需要单独处理，同时记录了表面的局部几何属性。
]
=== Geometric Setting and Conventions
<bsdf-geom-and-conventions>
#parec[
  Reflection computations in pbrt are performed in a reflection coordinate system where the two tangent vectors and the normal vector at the point being shaded are aligned with the `x`, `y`, and `z` axes, respectively (@fig:bsdf-basic-interface ). All direction vectors passed to and returned from the `BxDF` evaluation and sampling routines will be defined with respect to this coordinate system. It is important to understand this coordinate system in order to understand the `BxDF` implementations in this chapter.
][
  pbrt中的反射计算是在反射坐标系统中进行的，其中被着色点的两个切线向量和法线向量分别与`x`、`y`、`z`坐标轴对齐（@fig:bsdf-basic-interface ）。传递给`BxDF`估值和采样例程的所有方向向量都将根据这个坐标系统定义。理解这个坐标系统对于理解本章中的`BxDF`实现非常重要。
]

#parec[
  @Spherical_Geometry introduced a range of utility functions—like `SinTheta()`, `CosPhi()`, etc.—that efficiently evaluate trigonometric functions of unit vectors expressed in Cartesian coordinates matching the convention used here. They will be used extensively in this chapter, as quantities like the cosine of the elevation angle play a central role in most reflectance models.
][
  @Spherical_Geometry 介绍了一系列实用函数，如`SinTheta()`、`CosPhi()`等，它们能高效地计算在笛卡尔坐标中的单位向量的三角函数，如下所示。在本章中将大量使用这些三角量，因为像高度角的余弦这样的量在大多数反射模型中起着核心作用。
]


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f02.svg", width: 80%),
  caption: [
    #ez_caption[
      *The Basic BSDF Coordinate Setting. *The shading coordinate system is defined by the orthonormal basis vectors $(upright(bold(s)),upright(bold(t)),upright(bold(n)))$. We will orient these vectors such that they lie along the $x,y,z$ axes in this coordinate system. Direction vectors in rendering space are transformed into the shading coordinate system before any of the BRDF or BTDF methods are called.
    ][
      *基本BSDF坐标设置。*着色坐标系统由正交基向量 $(upright(bold(s)),upright(bold(t)),upright(bold(n)))$ 定义。我们将这些向量定向，使它们沿坐标系统的(x,y,z)轴线。渲染空间中的方向向量在调用BRDF或BTDF方法之前被转换为着色坐标系统。
    ]
  ],
)<bsdf-basic-interface>

#parec[
  We will frequently find it useful to check whether two direction vectors lie in the same hemisphere with respect to the surface normal in the BSDF coordinate system; the `SameHemisphere()` function performs this check.
][
  我们经常需要检查两个方向向量是否位于BSDF坐标系统中表面法线的同一半球；`SameHemisphere()`函数实现了执行此检查。
]
```cpp
<< Spherical Geometry Inline Functions>>+=
bool SameHemisphere(Vector3f w, Vector3f wp) {
    return w.z * wp.z > 0;
}
```

#parec[
  There are some additional conventions that are important to keep in mind when reading the code in this chapter and when adding BRDFs and BTDFs to `pbrt`:
][
  阅读本章代码及向`pbrt`添加BRDF和BTDF时需牢记一些额外的约定：
]
#parec[
  - The incident light direction $omega_i$ and the outgoing viewing direction $omega_o$ will both be normalized and outward facing after being transformed into the local coordinate system at the surface. In other words, the directions will not model the physical propagation of light, which is helpful in bidirectional rendering algorithms that generate light paths in reverse order.
][
  - 入射光方向$omega_upright(i)$和出射观察方向$omega_upright(o)$在转换到表面的局部坐标系后都将被标准化并朝外。换句话说，这些方向不会模拟光的物理传播，这在以相反顺序生成光路径的双向渲染算法中有所帮助。
]
#parec[
  - In `pbrt`, the surface normal $upright(bold(n))$ always points to the “outside” of the object, which makes it easy to determine if light is entering or exiting transmissive objects: if the incident light direction $omega_i$ is in the same hemisphere as $upright(bold(n))$, then light is entering; otherwise, it is exiting. Therefore, the normal may be on the opposite side of the surface than one or both of the $omega_i$ and $omega_o$ direction vectors. Unlike many other renderers, `pbrt` does not flip the normal to lie on the same side as $omega_o$.
][
  - 在`pbrt`中，表面法线 $upright(bold(n))$ 始终指向物体的“外部”，这使得确定光是进入还是离开透射物体变得简单：如果入射光方向$omega_i$与$upright(bold(n))$同半球，则光进入；否则，它离开。因此，法线可能位于表面的另一侧，与$omega_i$和$omega_o$中的一个或两个方向向量不同。与许多其他渲染器不同，`pbrt`不会翻转法线使其位于与$omega_o$同一侧。
]
#parec[
  - The local coordinate system used for shading may not be exactly the same as the coordinate system returned by the `Shape::Intersect()` routines from @Shapes; it may have been modified between intersection and shading to achieve effects like bump mapping. See @textures-and-materials for examples of this kind of modification.
][
  - 用于着色的局部坐标系可能与@Shapes 中`Shape::Intersect()`例程返回的坐标系不完全相同；它可能在交点和着色之间被修改，以实现类似凹凸贴图的效果。@textures-and-materials 有此类修改的示例。
]
=== BxDF Interface
<BxDF_Interface>
#parec[
  The interface for the individual BRDF and BTDF functions is defined by BxDF, which is in the file `base/bxdf.h`.
][
  单独的BRDF和BTDF函数的接口由 BxDF 定义，位于文件`base/bxdf.h`中。
]

```cpp
<< BxDF Definition>>=
class BxDF
    : public TaggedPointer<
          DiffuseBxDF, CoatedDiffuseBxDF, CoatedConductorBxDF,
          DielectricBxDF, ThinDielectricBxDF, HairBxDF, MeasuredBxDF,
          ConductorBxDF, NormalizedFresnelBxDF> {
  public:
    <<BxDF Interface>>
};
```

#parec[
  The `BxDF` interface provides a method to query the material type following the earlier categorization, which some light transport algorithms in @light-transport-i-surface-reflection through @wavefront-rendering-on-gpus use to specialize their behavior.
][
  `BxDF`接口提供了一种查询材质类型的方法，这在@light-transport-i-surface-reflection 至@wavefront-rendering-on-gpus 中的某些光传输算法中用于特化其行为。
]

```cpp
<< BxDF Interface>>=
BxDFFlags Flags() const;
```
#parec[
  The `BxDFFlags` enumeration lists the previously mentioned categories and also distinguishes reflection from transmission. Note that retroreflection is treated as glossy reflection in this list.
][
  `BxDFFlags` 枚举列出了前面提到的类别，并区分了反射和透射。请注意，逆反射在此列表中被视为光泽反射。
]
```cpp
<< BxDFFlags Definition>>=
enum BxDFFlags {
    Unset = 0,
    Reflection = 1 << 0,
    Transmission = 1 << 1,
    Diffuse = 1 << 2,
    Glossy = 1 << 3,
    Specular = 1 << 4,
    <<Composite BxDFFlags definitions>>
};
```
#parec[
  These constants can also be combined via a binary `OR` operation to characterize materials that simultaneously exhibit multiple traits. A number of commonly used combinations are provided with their own names for convenience:
][
  这些常量还可以通过二进制或操作（`OR`）组合，以描述同时表现出多种特征的材质。为了方便，提供了一些常用组合的自定义名称：
]


```cpp
<< Composite BxDFFlags definitions>>=
DiffuseReflection = Diffuse | Reflection,
DiffuseTransmission = Diffuse | Transmission,
GlossyReflection = Glossy | Reflection,
GlossyTransmission = Glossy | Transmission,
SpecularReflection = Specular | Reflection,
SpecularTransmission = Specular | Transmission,
All = Diffuse | Glossy | Specular | Reflection | Transmission
```
#parec[
  A few utility functions encapsulate the logic for testing various flag characteristics.
][
  几个实用函数封装了测试各种标志特性的逻辑。
]
```cpp
<< BxDFFlags Inline Functions>>=
bool IsReflective(BxDFFlags f) { return f & BxDFFlags::Reflection; }
bool IsTransmissive(BxDFFlags f) { return f & BxDFFlags::Transmission; }
bool IsDiffuse(BxDFFlags f) { return f & BxDFFlags::Diffuse; }
bool IsGlossy(BxDFFlags f) { return f & BxDFFlags::Glossy; }
bool IsSpecular(BxDFFlags f) { return f & BxDFFlags::Specular; }
bool IsNonSpecular(BxDFFlags f) {
    return f & (BxDFFlags::Diffuse | BxDFFlags::Glossy); }
```

#parec[
  The key method that BxDFs provide is `f()`, which returns the value of the distribution function for the given pair of directions. The provided directions must be expressed in the local reflection coordinate system introduced in the previous section.
][
  BxDF提供的关键方法是`f()`，它返回给定入射方向和出射方向的分布函数的值。提供的方向必须在上一节介绍的局部反射坐标系统中表示。
]
#parec[
  This interface implicitly assumes that light in different wavelengths is decoupled—energy at one wavelength will not be reflected at a different wavelength. In this case, the effect of reflection can be described by a per-wavelength factor returned in the form of a `SampledSpectrum`. Fluorescent materials that redistribute energy between wavelengths would require that this method return an $n times n$ matrix to encode the transfer between the $n$ spectral samples of `SampledSpectrum`.
][
  此接口隐含地假设不同波长的光是解耦的——在一个波长的能量不会以不同的波长反射。在这种情况下，反射的效果可以通过以`SampledSpectrum`形式返回的每波长因子来描述。需要将能量在波长间重新分配的荧光材质，这种方法需要返回一个 $n times n$ 矩阵，以 $n$ 个`SampledSpectrum`的光谱样本之间的转移。
]
#parec[
  Neither constructors nor methods of BxDF implementations will generally be informed about the specific wavelengths associated with SampledSpectrum entries, since they do not require this information.
][
  BxDF实现的构造函数或方法通常不会输入与`SampledSpectrum`条目相关的特定波长，因为它们不需要这些信息。
]

```cpp
<< BxDF Interface>>+=
SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const;
```

#parec[
  The function also takes a `TransportMode` enumerator that indicates whether the outgoing direction is toward the camera or toward a light source (and the corresponding opposite for the incident direction). This is necessary to handle cases where scattering is non-symmetric; this subtle aspect is discussed further in Section 9.5.2.
][
  该函数还接受一个`TransportMode`枚举值，用于指定出射方向是朝向相机还是朝向光源（以及相应的入射方向）。这对于处理散射不对称的情况是必要的；这个微妙的方面将在9.5.2节中进一步讨论。
]
#parec[
  `BxDFs` must also provide a method that uses importance sampling to draw a direction from a distribution that approximately matches the scattering function's shape. Not only is this operation crucial for efficient Monte Carlo integration of the light transport equation (1.1), it is the only way to evaluate some BSDFs. For example, perfect specular objects like a mirror, glass, or water only scatter light from a single incident direction into a single outgoing direction. Such BxDFs are best described with Dirac delta distributions (covered in more detail in Section 9.1.4) that are zero except for the single direction where light is scattered. Their `f()` and `PDF()` methods always return zero.
][
  `BxDFs`必须提供一种方法，使用重要性采样从一个分布中抽取一个方向，这个分布大致匹配散射函数的形状。这个操作不仅对于高效的蒙特卡洛积分光传输方程（1.1）至关重要，而且是估计某些`BSDFs`的唯一方法。例如，完美的镜面物体，如镜子、玻璃或水，只会将光从单一入射方向散射到单一出射方向。这样的BxDFs最好用 *Dirac delta分布*（在第9.1.4节中详细介绍）来描述，除了光被散射的单一方向外，其它方向均为零。它们的f()和PDF()方法总是返回零。
]
#parec[
  Implementations of the `Sample_f()` method should determine the direction of incident light $omega_i$ given an outgoing direction $omega_o$ and return the value of the BxDF for the pair of directions. They take three uniform samples in the range $[0,1)^2$ via the uc and u parameters. Implementations can use these however they wish, though it is generally best if they use the 1D sample uc to choose between different types of scattering (e.g., reflection or transmission) and the 2D sample to choose a specific direction. Using uc and u[0] to choose a direction, for example, would likely give inferior results to using u[0] and u[1], since uc and u[0] are not necessarily jointly well distributed. Not all the sample values need be used, and BxDFs that need additional sample values must generate them themselves. (The LayeredBxDF described in Section 14.3 is one such example.)
][
  `Sample_f()`方法的实现应确定给定出射方向 $omega_o$ 的入射光方向 $omega_i$，并返回这对方向的BxDF值。它们通过uc和u参数，在 $[0,1)^2$ 范围内取三个均匀样本。实现可以按照它们希望的方式使用这些样本，尽管一般最好使用1D样本uc在不同类型的散射（例如，反射或透射）之间进行选择，并使用2D样本选择特定方向。例如，使用uc和u[0]选择方向可能会比使用u[0]和u[1]得到较差的结果，因为uc和u[0]未必是联合分布良好的。并非所有样本值都需要使用，需要额外样本值的BxDFs必须自己生成它们。（第14.3节描述的LayeredBxDF就是一个例子。）
]

#parec[
  Note the potentially counterintuitive direction convention: the outgoing direction $omega_o$ is given, and the implementation then samples an incident direction $omega_i$. The Monte Carlo methods in this book construct light paths in reverse order—that is, counter to the propagation direction of the transported quantity (radiance or importance)—motivating this choice.
][
  注意反直觉的方向约定：给定了出射方向 $omega_o$ ，然后实现采样一个入射方向 $omega_i$。这本书中的蒙特卡洛方法以反向顺序构建光路径——也就是说，与传输量（辐射度或重要性）的传播方向相反。
]

#parec[
  Callers of this method must be prepared for the possibility that sampling fails, in which case an unset optional value will be returned.
][
  调用此方法的用户必须为采样失败的可能性做好准备，在这种情况下，将返回一个未设置的可选值。
]

<< BxDF Interface>>+=
```cpp
pstd::optional<BSDFSample>
Sample_f(Vector3f wo, Float uc, Point2f u,
         TransportMode mode = TransportMode::Radiance,
         BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const;
```

#parec[
  The sample generation can optionally be restricted to the reflection or transmission component via the `sampleFlags` parameter. A sampling failure will occur in invalid cases—for example, if the caller requests a transmission sample on an opaque surface.
][
  样本生成可以通过`sampleFlags`参数选择性地限制为反射或透射分量。在无效情况下会发生采样失败——例如，如果调用者在不透明表面上请求透射采样。
]
`<< BxDFReflTransFlags Definition>>= `
```cpp
enum class BxDFReflTransFlags {
    Unset = 0,
    Reflection = 1 << 0,
    Transmission = 1 << 1,
    All = Reflection | Transmission
};
```

#parec[
  If sampling succeeds, the method returns a `BSDFSample` that includes the value of the BSDF f, the sampled direction wi, its probability density function (PDF) measured with respect to solid angle, and a BxDFFlags instance that describes the characteristics of the particular sample. BxDFs should specify the direction wi with respect to the local reflection coordinate system, though `BSDF::Sample_f()` will transform this direction to rendering space before returning it.
][
  如果采样成功，该方法返回一个`BSDFSample`，其中包括BSDF f的值，采样方向wi，其概率密度函数（PDF）相对于立体角测量，以及描述特定样本特征的BxDFFlags实例。BxDFs应该相对于本地反射坐标系指定方向wi，尽管`BSDF::Sample_f()`会在返回之前将这个方向转换到渲染空间。
]
#parec[
  Some BxDF implementations (notably, the LayeredBxDF described in Section 14.3) generate samples via simulation, following a random light path. The distribution of paths that escape is the BxDF's exact (probabilistic) distribution, but the returned f and pdf are only proportional to their true values. (Fortunately, by the same proportion!) This case needs special handling in light transport algorithms, and is indicated by the `pdfIsProportional` field. For all the BxDFs in this chapter, it can be left set to its default `false` value.
][
  一些BxDF实现（特别是第14.3节描述的LayeredBxDF）通过模拟生成样本，遵循随机光路径。逃逸的路径分布是BxDF的确切（概率）分布，但返回的f和pdf只与它们的真实值成比例。（幸运的是，按同样的比例！）这种情况需要在光传输算法中进行特殊处理，并由`pdfIsProportional`字段表示。对于本章中的所有BxDF，可以将其设置为默认的`false`值。
]
```cpp
<< BSDFSample Definition>>=
struct BSDFSample {
    <<BSDFSample Public Methods>>
    SampledSpectrum f;
    Vector3f wi;
    Float pdf = 0;
    BxDFFlags flags;
    Float eta = 1;
    bool pdfIsProportional = false;
};
```
```cpp
<< BSDFSample Public Methods>>=
BSDFSample(SampledSpectrum f, Vector3f wi, Float pdf, BxDFFlags flags,
           Float eta = 1, bool pdfIsProportional = false)
    : f(f), wi(wi), pdf(pdf), flags(flags), eta(eta),
      pdfIsProportional(pdfIsProportional) {}
```
#parec[
  Several convenience methods can be used to query characteristics of the sample using previously defined functions like BxDFFlags::IsReflective(), etc.
][
  可以使用一些方便的方法，使用以前定义的函数（如`BxDDFFlags:：IsReflective()`））来查询样本的特征。
]
<< BSDFSample Public Methods>>+=
```cpp
bool IsReflection() const { return pbrt::IsReflective(flags); }
bool IsTransmission() const { return pbrt::IsTransmissive(flags); }
bool IsDiffuse() const { return pbrt::IsDiffuse(flags); }
bool IsGlossy() const { return pbrt::IsGlossy(flags); }
bool IsSpecular() const { return pbrt::IsSpecular(flags); }
```
#parec[
  The `PDF()` method returns the value of the PDF for a given pair of directions, which is useful for techniques like multiple importance sampling that compare probabilities of multiple strategies for obtaining a given sample.
][
  `PDF()`方法返回给定方向对的PDF值，这对于比较获得给定样本的多种策略的概率的多重要性采样等技术很有用。
]
`<< BxDF Interface>>+=`
```cpp
Float PDF(Vector3f wo, Vector3f wi, TransportMode mode,
          BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const;
```


=== Hemispherical Reflectance
#parec[
  With the BxDF methods described so far, it is possible to implement methods that compute the reflectance of a BxDF by applying the Monte Carlo estimator to the definitions of reflectance from Equations (4.12) and (4.13).
][
  到目前为止，我们已经介绍了几种BxDF方法，这些方法可以实现计算BxDF反射率的功能，方法是将蒙特卡洛估计器应用于方程（4.12）和（4.13）中定义的反射率。
]
#parec[
  A first variant of BxDF::rho() computes the reflectance function $rho_(h d)$. Its caller is responsible for determining how many samples should be taken and for providing the uniform sample values to be used in computing the estimate. Thus, depending on the context, callers have control over sampling and the quality of the returned estimate.
][
  `BxDF::rho()`的第一个变体计算反射函数 $rho_(h d)$。调用此函数的用户负责决定采样次数，并提供用于计算估计值的统一样本值。因此，根据上下文，调用者可以控制采样和返回估计值的质量。
]

`<< BxDF Method Definitions>>=`
```cpp
SampledSpectrum BxDF::rho(Vector3f wo, pstd::span<const Float> uc,
                          pstd::span<const Point2f> u2) const {
    SampledSpectrum r(0.);
    for (size_t i = 0; i < uc.size(); ++i) {
        <<Compute estimate of >>
    }
    return r / uc.size();
}
```

#parec[
  Each term of the estimator $ 1 / n sum_j^n (f_r (omega, omega_j)|cos theta_j|) / p(omega_j) $ is easily evaluated.
][
  估计器的每个项 $ 1 / n sum_j^n (f_r (omega, omega_j)|cos theta_j|) / p(omega_j) $ 都很容易计算。
]

`<< Compute estimate of >>=`
```cpp
pstd::optional<BSDFSample> bs = Sample_f(wo, uc[i], u2[i]);
if (bs)
    r += bs->f * AbsCosTheta(bs->wi) / bs->pdf;
```
#parec[
  The hemispherical-hemispherical reflectance is found in the second `BxDF::rho()` method that evaluates Equation (4.13). As with the first rho() method, the caller is responsible for passing in uniform sample values—in this case, five dimensions' worth of them.
][
  _半球-半球反射率_ 在第二个`BxDF::rho()`方法中找到，该方法评估方程（4.13）。与第一个`rho()`方法一样，调用者负责传入统一样本值——在这种情况下，是五维值。
]

```cpp
<< BxDF Method Definitions>>+=
SampledSpectrum BxDF::rho(pstd::span<const Point2f> u1,
        pstd::span<const Float> uc, pstd::span<const Point2f> u2) const {
    SampledSpectrum r(0.f);
    for (size_t i = 0; i < uc.size(); ++i) {
        <<Compute estimate of >>
    }
    return r / (Pi * uc.size());
}
```

#parec[
  Our implementation samples the first direction `wo` uniformly over the hemisphere. Given this, the second direction can be sampled using BxDF::Sample_f().
][
  我们的实现将第一个方向`wo`均匀地采样于半球上。鉴于此，可以使用`BxDF::Sample_f()`来采样第二个方向。
]
```cpp
<< Compute estimate of >>=
Vector3f wo = SampleUniformHemisphere(u1[i]);
if (wo.z == 0)
    continue;
Float pdfo = UniformHemispherePDF();
pstd::optional<BSDFSample> bs = Sample_f(wo, uc[i], u2[i]);
if (bs)
    r += bs->f * AbsCosTheta(bs->wi) * AbsCosTheta(wo) / (pdfo * bs->pdf);
```



=== Delta Distributions in BSDFs
#parec[
  Several BSDF models in this chapter make use of Dirac delta distributions to represent interactions with perfect specular materials like smooth metal or glass surfaces. They represent a curious corner case in implementations, and we therefore establish a few important conventions.
][
  本章中的几个BSDF模型使用Dirac delta分布来表示与完美镜面材质（如光滑的金属或玻璃表面）的相互作用。这些分布在实现中代表了一个奇特的特例，因此我们建立了一些重要的约定。
]


#parec[
  Recall from Section 8.1.1 that the Dirac delta distribution is defined such that
][
  回想一下第8.1.1节中提到的Dirac delta分布是这样定义的：
]
$ delta (x) = 0 forall x eq.not 0 $
and
$ integral_(- oo)^(+oo) delta(x) d x = 1. $


#parec[
  According to these equations, $delta$ can be interpreted as a normalized density function that is zero for all $x eq.not 0$. Generating a sample from such a distribution is trivial, since there is only one value that it can take. In this sense, the forthcoming implementations of `Sample_f()` involving delta functions naturally fit into the Monte Carlo sampling framework.
][
  根据这些方程， $delta$ 可以将视为一个规范化的密度函数，对所有的 $x eq.not 0$ 函数值取0。从这样的分布中生成样本是微不足道的，因为它只能取一个值。在这个意义上，接下来涉及delta函数的`Sample_f()`的实现自然适合蒙特卡罗采样框架。
]
#parec[
  However, sampling alone is not enough: two methods (`Sample_f()` and `PDF`) also provide sampling densities, and it is considerably less clear what values should be returned here. Strictly speaking, the delta distribution is not a true function but constitutes the limit of a sequence of functions—for example, one describing a box of unit area whose width approaches 0; see Chapter 5 of Bracewell (2000) for details. In the limit, the value of $delta(0)$ must then necessarily tend toward infinity. This important theoretical realization does not easily translate into C++ code: certainly, returning an infinite or very large PDF value is not going to lead to correct results from the renderer.
][
  然而，仅仅采样是不够的：两种方法（`Sample_f()`和`PDF`）还提供采样密度，而返回什么值在这里就不那么清楚了。严格来说，delta分布不是一个真正的函数，而是一系列函数的极限——例如，描述一个单位面积的盒子，其宽度趋近于0；有关详细信息，请参见Bracewell（2000）的第5章。在极限情况下， $delta(0)$ 的值必然趋于无穷大。这个重要的理论认识不容易转化为C++代码：当然，返回无限大或非常大的PDF值不会导致渲染器得到正确的结果。
]
#parec[
  To resolve this conflict, BSDFs may only contain matched pairs of delta functions in their $f_r$ function and PDF. For example, suppose that the PDF factors into a remainder term and a delta function involving a particular direction $omega'$ :
][
  为了解决这个冲突，BSDFs可能只在其函数和PDF中包含delta函数的匹配对。例如，假设PDF分解为一个余项和一个涉及特定方向 $omega'$ 的delta函数：
]

$ p lr((omega_i)) eq p^(r e m) lr((omega_i)) delta lr((omega prime minus omega_i)) $

// The formula in the image appears to be a mathematical or physical equation, which reads:

// \[ p(\omega_i) = p^{rem}(\omega_i) \delta(\omega' - \omega_i) \]

// Here, \( p(\omega_i) \) seems to represent a probability density function (pdf) evaluated at a frequency \( \omega_i \). The term \( p^{rem}(\omega_i) \) might denote a remnant or remaining pdf after some process or event, also evaluated at \( \omega_i \). The \( \delta \) function, specifically \( \delta(\omega' - \omega_i) \), is the Dirac delta function, which is commonly used in physics and engineering to denote a point impulse; in this context, it implies that the value is only non-zero when \( \omega' = \omega_i \).

// This equation could be seen in contexts such as signal processing, quantum mechanics, or other fields where frequencies and probability densities are relevant.

#parec[
  If the same holds true for , then a Monte Carlo estimator that divides by the PDF will never require evaluation of the delta function:
][
  如果对也成立，那么一个将通过PDF分割的蒙特卡罗估计器将永远不需要评估delta函数：
]
$
  frac(f_r lr((p comma omega_o comma omega_i)), p lr((omega_i))) eq frac(delta lr((omega prime minus omega_i)) f_r^(r e m) lr((p comma omega_o comma omega_i)), delta lr((omega prime minus omega_i)) p^(r e m) lr((omega_i))) eq frac(f_r^(r e m) lr((p comma omega_o comma omega_i)), p^(r e m) lr((omega_i))) dot.basic
$
#parec[
  Implementations of perfect specular materials will thus return a constant PDF of 1 when Sample_f() generates a direction associated with a delta function, with the understanding that the delta function will cancel in the estimator.
][
  因此，完美镜面材质的实现在`Sample_f()`生成与`delta`函数相关的方向时，将返回一个恒定的PDF值1，理解上delta函数将在估计器中抵消。
]
#parec[
  In contrast, the respective PDF() methods should return 0 for all directions, since there is zero probability that another sampling method will randomly find the direction from a delta distribution.
][
  相比之下，相应的PDF()方法应该为所有方向返回0，因为其他采样方法随机找到delta分布的方向的概率为零。
]

=== BSDFs
<bsdfs>

#parec[
  BxDF class implementations perform all computation in a local shading coordinate system that is most appropriate for this task. In contrast, rendering algorithms operate in rendering space (Section 5.1.1); hence a transformation between these two spaces must be performed somewhere. The BSDF is a small wrapper around a BxDF that handles this transformation.
][
  BxDF 类的实现在最适合此任务的局部着色坐标系中执行所有计算。相比之下，渲染算法在渲染空间中运行（参见5.1.1节）；因此，必须在某处执行这两个空间之间的转换。BSDF 是一个围绕 BxDF 的小包装器，负责处理这种转换。
]

```cpp
<< BSDF Definition>>=
class BSDF {
  public:
    <<BSDF Public Methods>>
  private:
    <<BSDF Private Members>>
};
```
#parec[
  In addition to an encapsulated BxDF, the BSDF holds a shading frame based on the Frame class.
][
  除了封装的 BxDF 外，BSDF 还持有基于 Frame 类的着色框架。
]
```cpp
<< BSDF Private Members>>=
BxDF bxdf;
Frame shadingFrame;
```


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f02.svg", width: 80%),
  caption: [
    #parec[
      The geometric normal, , defined by the surface geometry, and the shading normal, , given by per-vertex normals and/or bump mapping, will generally define different hemispheres for integrating incident illumination to compute surface reflection. It is important to handle this inconsistency carefully since it can otherwise lead to artifacts in images.

    ][
      由表面几何定义的几何法线，以及由逐顶点法线和/或凹凸映射给出的着色法线，通常会定义用于整合入射光照以计算表面反射的不同半球。处理这种不一致性很重要，因为否则可能会在图像中产生伪影。
    ]
  ],
) <pha09f03>

#parec[
  The constructor initializes the latter from the shading normal and using the shading coordinate system convention (@pha09f03 ).
][
  构造函数根据着色法线和着色坐标系约定（见@pha09f03 ）初始化后者。
]
<< BSDF Public Methods>>=
```cpp
BSDF() = default;
BSDF(Normal3f ns, Vector3f dpdus, BxDF bxdf)
    : bxdf(bxdf),
      shadingFrame(Frame::FromXZ(Normalize(dpdus), Vector3f(ns))) {}
```
#parec[
  The default constructor creates a BSDF with a nullptr-valued bxdf, which is useful to represent transitions between different media that do not themselves scatter light. An operator bool() method checks whether the BSDF represents a real material interaction, in which case the Flags() method provides further information about its high-level properties.
][
  默认构造函数创建一个 bxdf 值为 nullptr 的 BSDF，这对于表示不自身散射光的不同媒介之间的过渡很有用。一个 `operator bool()` 方法检查 BSDF 是否代表一个真实的材质交互，如果是，`Flags()` 方法提供关于其高层属性的更多信息。
]
```cpp
<< BSDF Public Methods>>+=
operator bool() const { return (bool)bxdf; }
BxDFFlags Flags() const { return bxdf.Flags(); }
```
#parec[
  The BSDF provides methods that perform transformations to and from the reflection coordinate system used by BxDFs.
][
  BSDF 提供了执行到 BxDFs 使用的反射坐标系的转换和从中转换的方法。
]
<< BSDF Public Methods>>+=
```cpp
Vector3f RenderToLocal(Vector3f v) const {
    return shadingFrame.ToLocal(v);
}
Vector3f LocalToRender(Vector3f v) const {
    return shadingFrame.FromLocal(v);
}
```
#parec[
  The f() function performs the required coordinate frame conversion and then queries the BxDF. The rare case in which the wo direction lies exactly in the surface's tangent plane often leads to not-a-number (NaN) values in BxDF implementations that further propagate and may eventually contaminate the rendered image. The BSDF avoids this case by immediately returning a zero-valued SampledSpectrum.
][
  f() 函数执行所需的坐标框架转换，然后查询 BxDF。wo 方向正好位于表面的切平面中的罕见情况通常会导致 BxDF 实现中出现非数字（NaN）值，这些值可能会进一步传播，并最终可能污染渲染图像。BSDF 通过立即返回一个零值的 SampledSpectrum 来避免这种情况。
]
```cpp
<< BSDF Public Methods>>+=
SampledSpectrum f(Vector3f woRender, Vector3f wiRender,
                  TransportMode mode = TransportMode::Radiance) const {
    Vector3f wi = RenderToLocal(wiRender), wo = RenderToLocal(woRender);
    if (wo.z == 0) return {};
    return bxdf.f(wo, wi, mode);
}
```
#parec[
  The BSDF also provides a second templated f() method that can be parameterized by the underlying BxDF. If the caller knows the specific type of BSDF::bxdf, it can call this variant directly without involving the dynamic method dispatch used in the method above. This approach is used by pbrt's wavefront rendering path, which groups evaluations based on the underlying BxDF to benefit from vectorized execution on the GPU. The implementation of this specialized version simply casts the BxDF to the provided type before invoking its f() method.
][
  BSDF还提供了第二种模板化的 f() 方法，可以根据底层 BxDF 进行参数化。如果调用者知道 BSDF::bxdf 的具体类型，它可以直接调用这个变体，而不涉及上述方法中使用的动态方法分派。这种方法被 pbrt 的波前渲染路径使用，该路径根据底层 BxDF 对评估进行分组，从而在 GPU 上受益于矢量化执行。这个特殊版本的实现只是在调用其 f() 方法之前，将 BxDF 转换为提供的类型。
]

```cpp
<< BSDF Public Methods>>+=
template <typename BxDF>
SampledSpectrum f(Vector3f woRender, Vector3f wiRender,
                  TransportMode mode = TransportMode::Radiance) const {
    Vector3f wi = RenderToLocal(wiRender), wo = RenderToLocal(woRender);
    if (wo.z == 0) return {};
    const BxDF *specificBxDF = bxdf.CastOrNullptr<BxDF>();
    return specificBxDF->f(wo, wi, mode);
}
```
#parec[
  `The BSDF::Sample_f()` method similarly forwards the sampling request on to the BxDF after transforming the direction to the local coordinate system.
][
  `BSDF::Sample_f()` 方法以类似的方式在将方向转换到局部坐标系统后，将采样请求转发到 BxDF。
]
<< BSDF Public Methods>>+=
```cpp
pstd::optional<BSDFSample> Sample_f(
        Vector3f woRender, Float u, Point2f u2,
        TransportMode mode = TransportMode::Radiance,
        BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const {
    Vector3f wo = RenderToLocal(woRender);
    if (wo.z == 0 ||!(bxdf.Flags() & sampleFlags)) return {};
    <<Sample bxdf and return BSDFSample>>
}
```
#parec[
  If the BxDF implementation returns a sample that has a zero-valued BSDF or PDF or an incident direction in the tangent plane, this method nevertheless returns an unset sample value. This allows calling code to proceed without needing to check those cases.
][
  如果 BxDF 实现返回一个 BSDF 或 PDF 值为零的样本，或者入射方向在切平面中，这种方法仍然返回一个未设置的样本值。这允许调用代码继续进行，而无需检查这些情况。
]

<< Sample bxdf and return BSDFSample>>=
```cpp
pstd::optional<BSDFSample> bs = bxdf.Sample_f(wo, u, u2, mode, sampleFlags);
if (!bs || !bs->f || bs->pdf == 0 || bs->wi.z == 0)
    return {};
bs->wi = LocalToRender(bs->wi);
return bs;
```
#parec[
  BSDF::PDF() follows the same pattern.
][
  BSDF::PDF() 遵循相同的模式。
]
<< BSDF Public Methods>>+=
```cpp
Float PDF(Vector3f woRender, Vector3f wiRender,
          TransportMode mode = TransportMode::Radiance,
          BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const {
    Vector3f wo = RenderToLocal(woRender), wi = RenderToLocal(wiRender);
    if (wo.z == 0) return 0;
    return bxdf.PDF(wo, wi, mode, sampleFlags);
}
```
#parec[
  We have omitted the definitions of additional templated Sample_f() and PDF() variants that are parameterized by the BxDF type.
][
  我们省略了由 BxDF 类型参数化的额外模板化 Sample_f() 和 PDF() 变体的定义。
]

#parec[
  Finally, BSDF provides rho() methods to compute the reflectance that forward the call on to its underlying bxdf. They are trivial and therefore not included here.
][
  最后，BSDF 提供了 rho() 方法来计算反射率，这些方法将调用转发到其底层 bxdf。这些方法很简单，因此不在这里包括。
]
