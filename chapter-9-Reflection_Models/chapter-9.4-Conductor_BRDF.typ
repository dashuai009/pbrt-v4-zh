#import "../template.typ": parec


== Conductor BRDF
<conductor-BRDF>
#parec[
  Having described the relevant physical principles, we now turn to the implementation of a BRDF that models specular reflection from an interface between a dielectric (e.g., air or water) and a conductor (e.g., a polished metal surface). We initially focus on the smooth case, and later generalize the implementation to rough interfaces in @roughness-using-microfacet-theory.
][
  在描述了相关的物理原理之后，我们现在转向实现一个BRDF，该BRDF模拟了从介质（例如，空气或水）和导体（例如，抛光金属表面）之间的界面的镜面反射。我们首先关注光滑情况，稍后在@roughness-using-microfacet-theory 中将实现推广到粗糙界面。
]
```cpp
<<ConductorBxDF Definition>>=
class ConductorBxDF {
  public:
    <<ConductorBxDF Public Methods>>
  private:
    <<ConductorBxDF Private Members>>
};
```

#parec[
  The internal state of the ConductorBxDF consists of the real (`eta`) and imaginary (`k`) component of the index of refraction. Furthermore, the implementation requires a microfacet distribution that statistically describes its roughness. The TrowbridgeReitzDistribution class handles the details here. The constructor, not included here, takes these fields as input and stores them in the ConductorBxDF instance.
][
  ConductorBxDF的内部状态包括折射率的实数（`eta`）和虚数（`k`）部分。此外，实现还需要一个微观平面分布，用于统计地描述其粗糙度。TrowbridgeReitzDistribution类在这里处理细节。构造函数（这里未包括）将这些字段作为输入，并将它们存储在ConductorBxDF实例中。
]
```cpp
<<ConductorBxDF Private Members>>=
TrowbridgeReitzDistribution mfDistrib;
SampledSpectrum eta, k;
```

#parec[
  We will sidestep all discussion of microfacets for the time being and only cover the effectively smooth case in this section, where the surface is either perfectly smooth or so close to it that it can be modeled as such. The TrowbridgeReitzDistribution provides an EffectivelySmooth() method that indicates this case, in which the microfacet distribution plays no further role. The ConductorBxDF::Flags() method returns `BxDFFlags` accordingly.
][
  我们将暂时回避所有关于微观平面的讨论，并且只在本节中讨论实际上光滑的情况，即表面要么完全光滑，要么非常接近光滑，以至于可以如此建模。TrowbridgeReitzDistribution提供了一个EffectivelySmooth()方法，用于指示这种情况，在这种情况下，微观平面分布不再起作用。`ConductorBxDF::Flags()`方法相应地返回`BxDFFlags`。
]
```cpp
<<ConductorBxDF Public Methods>>=
BxDFFlags Flags() const {
    return mfDistrib.EffectivelySmooth() ? BxDFFlags::SpecularReflection :
        BxDFFlags::GlossyReflection;
}
```

#parec[
  The conductor BRDF builds on two physical ideas: the law of specular reflection assigns a specific reflected direction to each ray, and the Fresnel equations determine the portion of reflected light. Any remaining light refracts into the conductor, where it is rapidly absorbed and converted into heat.
][
  导体BRDF建立在两个物理概念之上：镜面反射定律为每个射线指定了一个特定的反射方向，而菲涅尔方程确定了反射光的比例。任何剩余的光都会折射进入导体，在那里它会迅速被吸收并转化为热量。
]

#parec[
  Let $F_r (omega)$ denote the unpolarized Fresnel reflectance of a given direction $omega$ (which only depends on the angle $theta$ that this direction makes with the surface normal $upright(bold(n))$ ). Because the law of specular reflection states that $theta_r = theta_o$ , we have $F_r (omega_r) = F_r (omega_o)$. We thus require a BRDF $f_r$ such that
][
  设 $F_r (omega)$ 表示给定方向 $omega$ 的非偏振菲涅尔反射率（它只依赖于该方向与表面法线 $upright(bold(n))$ 所成角度 $theta$ ）。因为镜面反射定律指出，我们有 $F_r (omega_r) = F_r (omega_o)$。因此，我们需要一个BRDF $f_r$，使得
]


$
  L_o (omega_o) = integral_(H^2 (upright(bold(n)))) f_r (omega_o, omega_i) L_i ( omega_i )|cos theta_i|thin d omega_i = F_r (omega_r) L_i (omega_r)
$
#parec[
  where $omega_r = R(omega_o, upright(bold(n)))$ is the specular reflection vector for $omega_o$ reflected about the surface normal $upright(bold(n))$. Such a BRDF can be constructed using the Dirac delta distribution that represents an infinitely peaked signal. Recall from @sampling-theory that the delta distribution has the useful property that
][
  其中 $omega_r = R(omega_o, upright(bold(n)))$ 是关于表面法线 $upright(bold(n))$ 反射 $omega_o$ 后得到的镜面反射向量。这样的双向反射分布函数（BRDF）可以使用表示无限尖锐信号的狄拉克δ分布来构建。回想一下 @sampling-theory 中的内容，δ分布具有以下有用的性质：
]

$
  integral f(x) thin delta(x - x_0) thin d x = f(x_0) .
$<delta-defn>
#parec[
  A first guess might be to use delta functions to restrict the incident direction to the specular reflection direction $omega_r$. This would yield a BRDF of
][
  首先可能会想到使用δ函数将入射方向限制为镜面反射方向。这将产生一个BRDF：
]

$
  f_r (omega_o, omega_i) = delta(omega_i - omega_r) F_r (omega_i) .
$

#parec[
  Although this seems appealing, plugging it into the scattering equation, @eqt:scattering-equation, reveals a problem:
][
  尽管这看起来很吸引人，但将其代入散射方程，即@eqt:scattering-equation，就会发现一个问题：
]

$
  L_o (omega_o) & = integral_(H^2 (upright(bold(n)))) delta(omega_i - omega_r) F_r (omega_i) L_i ( omega_i )|cos theta_i|thin d omega_i \
  & = F_r (omega_r) L_i (omega_r)|cos theta_r| .
$

#parec[
  This is not correct because it contains an extra factor of $cos theta_r$. However, we can divide out this factor to find the correct BRDF for perfect specular reflection:
][
  这不正确，因为它包含了额外的因子 $cos theta_r$。然而，我们可以将这个因子除掉，以找到完美镜面反射的正确BRDF：
]

$
  f_r (p, omega_o, omega_i) = F_r (omega_r) frac(delta(omega_i - omega_r),|cos theta_r|) .
$<fresnel-perfect-specular>
#parec[
  The `Sample_f()` method of the `ConductorBxDF` method implements @eqt:fresnel-perfect-specular.
][
  `ConductorBxDF`的`Sample_f()`方法实现了@eqt:fresnel-perfect-specular。
]

```cpp
<<ConductorBxDF Public Methods>>+=
pstd::optional<BSDFSample>
Sample_f(Vector3f wo, Float uc, Point2f u, TransportMode mode,
         BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const {
    if (!(sampleFlags & BxDFReflTransFlags::Reflection)) return {};
    if (mfDistrib.EffectivelySmooth()) {
        <<Sample perfect specular conductor BRDF>>
    }
    <<Sample rough conductor BRDF>>
}
```
#parec[
  Note that Dirac delta distributions require special handling compared to standard functions. In particular, the probability of successfully drawing a point on the peak is zero, unless the sampling probability is also a delta distribution. In other words, the distribution must be used to determine the sample location.
][
  需要注意的是，与标准函数相比，狄拉克δ分布需要特殊处理。特别是，除非抽样概率也是δ分布，否则成功在峰值上抽取点的概率为零。换句话说，必须使用分布来确定样本位置。
]

#parec[
  Because the surface normal $upright(bold(n))_g$ is $(0,0,1)$ in the reflection coordinate system, the equation for the perfect specular reflection direction, (9.1), simplifies substantially; the $x$ and $y$ components only need to be negated to compute this direction and there is no need to call `Reflect()` (the rough case will require this function, however).
][
  因为反射坐标系统中的表面法线是，完美镜面反射方向的方程（9.1）大大简化了；只需要将 $x$ 和 $y$ 分量取反来计算这个方向，无需调用`Reflect()`（粗糙情况将需要这个函数）。
]

```cpp
<<Sample perfect specular conductor BRDF>>=
Vector3f wi(-wo.x, -wo.y, wo.z);
SampledSpectrum f = FrComplex(AbsCosTheta(wi), eta, k) / AbsCosTheta(wi);
return BSDFSample(f, wi, 1, BxDFFlags::SpecularReflection);
```

#parec[
  The PDF value in the returned BSDFSample is set to one, as per the discussion of delta distribution BSDFs in @BxDF_Interface. Following the other conventions outlined in that section, BRDF evaluation always returns zero in the smooth case, since the specular peak is considered unreachable by other sampling methods.
][
  返回的BSDFSample中的PDF值被设为一，正如 @BxDF_Interface 中关于δ分布BSDF的讨论所述。按照该节中概述的其他约定，在光滑情况下，BRDF评估总是返回零，因为其他采样方法认为镜面峰是不可达的。
]
```cpp
<<ConductorBxDF Public Methods>>+=
SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const {
    if (!SameHemisphere(wo, wi)) return {};
    if (mfDistrib.EffectivelySmooth()) return {};
    <<Evaluate rough conductor BRDF>>
}
```
#parec[
  The same convention also applies to the `PDF()` method.
][
  同样的约定也适用于`PDF()`方法。
]
```cpp
<<ConductorBxDF Public Methods>>+=
Float PDF(Vector3f wo, Vector3f wi, TransportMode mode,
          BxDFReflTransFlags sampleFlags) const {
    if (!(sampleFlags & BxDFReflTransFlags::Reflection)) return 0;
    if (!SameHemisphere(wo, wi)) return 0;
    if (mfDistrib.EffectivelySmooth()) return 0;
    <<Evaluate sampling PDF of rough conductor BRDF>>
}
```

#parec[
  The missing three fragments—<`<Sample rough conductor BRDF>>`, `<<Evaluate rough conductor BRDF>>`, and `<<Evaluate sampling PDF of rough conductor BRDF>>`—will be presented in @roughness-using-microfacet-theory.
][
  遗漏的三个片段—`<<Sample rough conductor BRDF>>`、`<<Evaluate rough conductor BRDF>>`和`<<Evaluate sampling PDF of rough conductor BRDF>>`—将在@roughness-using-microfacet-theory 中呈现。
]
