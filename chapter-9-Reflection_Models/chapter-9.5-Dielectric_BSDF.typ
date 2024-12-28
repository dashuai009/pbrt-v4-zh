#import "../template.typ": parec, ez_caption


== Dielectric BSDF
<dielectric-BSDF>

#parec[
  In the dielectric case, the relative index of refraction is real-valued, and specular transmission must be considered in addition to reflection. The `DielectricBxDF` handles this scenario for smooth and rough interfaces.
][
  在介电体情况下，相对折射率为实数值，除了反射外，还需考虑镜面透射。`DielectricBxDF` 处理平滑和粗糙界面的这种情况。
]

#parec[
  @fig:transparent-machines-glass shows an image of an abstract model using this `BxDF` to model a glass material.
][
  @fig:transparent-machines-glass 显示了使用此 `BxDF` 模型玻璃材料的抽象模型图像。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f14.svg"),
  caption: [
    #ez_caption[
      When the BRDF for specular reflection and the BTDF for specular
      transmission are modulated with the Fresnel formula for dielectrics, the
      realistic angle-dependent variation of the amount of reflection and
      transmission gives a visually accurate representation of the glass.
    ][
      当镜面反射的 BRDF 和镜面透射的 BTDF
      通过介电体的菲涅尔公式调制时，反射和透射量的真实角度依赖变化提供了玻璃的视觉准确表示。
    ]
  ],
)<transparent-machines-glass>

```cpp
<<DielectricBxDF Definition>>=
class DielectricBxDF {
  public:
    <<DielectricBxDF Public Methods>>
  private:
    <<DielectricBxDF Private Members>>
};
```

#parec[
  The constructor takes a single `Float`-valued `eta` parameter and a microfacet distribution `mfDistrib`. Spectrally varying IORs that disperse light into different directions are handled by randomly sampling a single wavelength to follow and then instantiating a corresponding `DielectricBxDF`. @material-interface-and-implementations discusses this topic in more detail.
][
  构造函数接受一个 `Float` 值的 `eta` 参数和一个微面分布 `mfDistrib`。通过随机采样单一波长来模拟光的色散，然后实例化相应的 `DielectricBxDF`。@material-interface-and-implementations 对此主题进行了更详细的讨论。
]

#parec[
  The `Flags()` method handles three different cases. The first is when the dielectric interface is index-matched— that is, with an equal IOR on both sides (in which case $eta = 1$ )—and light is only transmitted. Otherwise, in the other two cases, the BSDF has both reflected and transmitted components. In both of these cases, the `TrowbridgeReitzDistribution`'s `EffectivelySmooth()` method differentiates between specular and glossy scattering.
][
  `Flags()` 方法处理三种不同的情况。第一种是介电界面是#emph[折射率匹配];的，即两侧具有相等的折射率（在这种情况下 $eta = 1$ ），光仅被透射。 否则，在另外两种情况下，BSDF 具有反射和透射成分。在这两种情况下，`TrowbridgeReitzDistribution` 的 `EffectivelySmooth()` 方法用于区分镜面散射和光泽散射。
]

```cpp
<<DielectricBxDF Public Methods>>+=
BxDFFlags Flags() const {
    BxDFFlags flags = (eta == 1) ? BxDFFlags::Transmission :
                      (BxDFFlags::Reflection | BxDFFlags::Transmission);
    return flags | (mfDistrib.EffectivelySmooth() ? BxDFFlags::Specular
                                                  : BxDFFlags::Glossy);
}
```

#parec[
  The `Sample_f()` method must choose between sampling perfect specular reflection or transmission. As before, we postpone handling of rough surfaces and only discuss the perfect specular case for now.
][
  `Sample_f()` 方法必须在采样完美镜面反射或透射之间进行选择。和以前一样，我们推迟处理粗糙表面，现在只讨论完美镜面情况。
]

```cpp
<<DielectricBxDF Method Definitions>>=
pstd::optional<BSDFSample>
DielectricBxDF::Sample_f(Vector3f wo, Float uc, Point2f u,
        TransportMode mode, BxDFReflTransFlags sampleFlags) const {
    if (eta == 1 || mfDistrib.EffectivelySmooth()) {
        <<Sample perfect specular dielectric BSDF>>
    } else {
        <<Sample rough dielectric BSDF>>
    }
}
```

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f15.svg"),
  caption: [
    #ez_caption[
      Glass Object Rendered Using the DielectricBxDF. (a) Choosing between specular reflection and transmission with equal probability at each scattering event. (b) Choosing with probability based on the value of the Fresnel equations, as is implemented in the Sample_f() method. Choosing between scattering modes with probability proportional to their contribution significantly reduces error by following fewer paths with low contributions.
    ][

    ]
  ],
)

#parec[
  Since dielectrics are characterized by both reflection and transmission, the sampling scheme must randomly choose between these two components, which influences the density function. While any discrete distribution is in principle admissible, an efficient approach from a Monte Carlo variance standpoint is to sample according to the contribution that these two components make—in other words, proportional to the Fresnel reflectance `R` and the complementary transmittance `1-R`.Figure 9.15 shows the benefit of sampling in this way compared to an equal split between reflection and transmission.
][
  由于介电体同时具有反射和透射特性，采样方案必须在这两者之间随机选择，这会影响密度函数。 虽然原则上任何离散分布都是可接受的，但从蒙特卡罗方差的角度来看，根据这两个成分的贡献进行采样是一种有效的方法——换句话说，按菲涅尔反射率 `R` 和互补透射率 `1-R` 的比例进行采样。Figure 9.15 shows the benefit of sampling in this way compared to an equal split between reflection and transmission.
]

```cpp
<<Sample perfect specular dielectric BSDF>>=
Float R = FrDielectric(CosTheta(wo), eta), T = 1 - R;
<<Compute probabilities pr and pt for sampling reflection and transmission>>
if (uc < pr / (pr + pt)) {
    <<Sample perfect specular dielectric BRDF>>
} else {
    <<Sample perfect specular dielectric BTDF>>
}
```

#parec[
  Because BSDF components can be selectively enabled or disabled via the `sampleFlags` argument, the component choice is based on adjusted probabilities `pr` and `pt` that take this into account.
][
  由于可以通过 `sampleFlags` 参数选择性地启用或禁用 BSDF 组件，因此组件选择基于调整后的概率 `pr` 和 `pt`。
]

```cpp
<<Compute probabilities pr and pt for sampling reflection and transmission>>=
Float pr = R, pt = T;
if (!(sampleFlags & BxDFReflTransFlags::Reflection)) pr = 0;
if (!(sampleFlags & BxDFReflTransFlags::Transmission)) pt = 0;
if (pr == 0 && pt == 0)
    return {};
```
#parec[
  In the most common case where both reflection and transmission are sampled, the BSDF value and sample probability contain the common factor `R` or `T`, which cancels when their ratio is taken.Thus, all sampled rays end up making the same contribution, and the Fresnel factor manifests in the relative proportion of reflected and transmitted rays.
][
  在最常见的情况下，反射和透射都被采样，BSDF 值和采样概率包含公共因子 `R` 或 `T`，当它们的比率被取时会相互抵消。Thus, all sampled rays end up making the same contribution, and the Fresnel factor manifests in the relative proportion of reflected and transmitted rays.
]

#parec[
  Putting all of this together, the only change in the following code compared to the analogous fragment `<<Sample perfect specular conductor BRDF>>` is the incorporation of the discrete probability of the sample.
][
  将所有这些结合在一起，以下代码与类似片段 `<<Sample perfect specular conductor BRDF>>` 的唯一变化是加入了样本的离散概率。
]

```cpp
<<Sample perfect specular dielectric BRDF>>=
Vector3f wi(-wo.x, -wo.y, wo.z);
SampledSpectrum fr(R / AbsCosTheta(wi));
return BSDFSample(fr, wi, pr / (pr + pt), BxDFFlags::SpecularReflection);
```

#parec[
  Specular transmission is handled along similar lines, though using the refracted ray direction for `wi`. The equation for the corresponding BTDF is similar to the case for perfect specular reflection, Equation (9.9), though there is an additional subtle technical detail: depending on the IOR $eta$, refraction either compresses or expands radiance in the angular domain, and the implementation must scale `ft` to account for this. This correction does not change the amount of radiant power in the scene—rather, it models how the same power is contained in a different solid angle. The details of this step differ depending on the direction of propagation in bidirectional rendering algorithms, and we therefore defer the corresponding fragment `<<Account for non-symmetry with transmission to different medium>>` to Section 9.5.2.
][
  镜面透射的处理方式类似，但使用折射射线方向作为入射方向 `wi`。对应的 BTDF（双向透射分布函数）公式与完美镜面反射的情况（公式 9.9）类似，但多了一个微妙的技术细节：根据折射率 $eta$，折射在角域内会压缩或扩展辐射度，代码实现时必须对 `ft ` 进行缩放以补偿这一变化。此修正不会改变场景中的辐射功率总量，而是用于模拟相同功率在不同立体角中的分布。这个步骤的具体实现会因双向渲染算法中传播方向的不同而有所差异，因此我们将对应的片段 `<<考虑在传输至不同介质时的非对称性>>` 留至 9.5.2 节再行讨论。
]

```cpp
<<Sample perfect specular dielectric BTDF>>=
<<Compute ray direction for specular transmission>>
SampledSpectrum ft(T / AbsCosTheta(wi));
<<Account for non-symmetry with transmission to different medium>>
return BSDFSample(ft, wi, pt / (pr + pt),
                  BxDFFlags::SpecularTransmission, etap);
```

#parec[
  The function `Refract()` computes the refracted direction `wi` via Snell's law, which fails in the case of total internal reflection. In principle, this should never happen: the transmission case is sampled with probability `T`, which is zero in the case of total internal reflection. However, due to floating-point rounding errors, inconsistencies can occasionally arise here. We handle this corner case by returning an invalid sample.
][
  函数 `Refract()` 通过斯涅尔定律计算折射方向 `wi`，在全内反射的情况下可能会失败。 原则上，这种情况不应该发生：透射情况以概率 `T` 进行采样，在全内反射的情况下为零。 然而，由于浮点舍入误差，这里偶尔会出现不一致。我们通过返回无效样本来处理这个极端情况。
]

```cpp
<<Compute ray direction for specular transmission>>=
Vector3f wi;
Float etap;
bool valid = Refract(wo, Normal3f(0, 0, 1), eta, &etap, &wi);
if (!valid) return {};
```

#parec[
  As with the ConductorBxDF, zero is returned from the `f()` method if the interface is smooth and all scattering is perfect specular.
][
  As with the ConductorBxDF, zero is returned from the f() method if the interface is smooth and all scattering is perfect specular.
]

```cpp
<<DielectricBxDF Method Definitions>>+=
SampledSpectrum DielectricBxDF::f(Vector3f wo, Vector3f wi,
                                  TransportMode mode) const {
    if (eta == 1 || mfDistrib.EffectivelySmooth())
        return SampledSpectrum(0.f);
    <<Evaluate rough dielectric BSDF>>
}
```

#parec[
  Also, a PDF value of zero is returned if the BSDF is represented using delta distributions.
][
  此外，如果 BSDF 使用 delta 分布表示，则返回的 PDF 值为零。
]

```cpp
<<DielectricBxDF Method Definitions>>+=
Float DielectricBxDF::PDF(Vector3f wo, Vector3f wi, TransportMode mode,
          BxDFReflTransFlags sampleFlags) const {
    if (eta == 1 || mfDistrib.EffectivelySmooth())
        return 0;
    <<Evaluate sampling PDF of rough dielectric BSDF>>
}
```

#parec[
  The missing three fragments — `<<Sample rough dielectric BSDF>>` , `<<Evaluate rough dielectric BSDF>>` , and `<<Evaluate sampling PDF of rough dielectric BSDF>>`—will be presented in Section 9.7.
][
  缺失的三个片段——`<<Sample rough dielectric BSDF>>`、`<<Evaluate rough dielectric BSDF>>` 和 `<<Evaluate sampling PDF of rough dielectric BSDF>>`——将在第 9.7 节中介绍。
]


=== Thin Dielectric BSDF
<thin-dielectric-bsdf>

#parec[
  Dielectric interfaces rarely occur in isolation: a particularly common configuration involves two nearby index of refraction changes that are smooth, locally parallel, and mutually reciprocal—that is, with relative IOR $eta$ and a corresponding interface with the inverse $1 \/ eta$. Examples include plate- and acrylic glass in windows or plastic foil used to seal and preserve food.
][
  介电界面很少单独出现：一种特别常见的配置涉及两个相邻的折射率变化，它们是光滑的、局部平行的并且互为倒数的——即具有相对折射率 $eta$ 和相应的逆界面 $1 \/ eta$。例子包括窗户中的平板玻璃和亚克力玻璃或用于密封和保存食物的塑料薄膜。
]

#parec[
  This important special case is referred to as a #emph[thin dielectric] due to the spatial proximity of the two interfaces compared to the larger lateral dimensions. When incident light splits into a reflected and a transmitted component with two separate interfaces, it is scattered in a recursive process that traps some of the light within the two interfaces (though this amount progressively decays as it undergoes an increasing number of reflections).
][
  由于两个界面在空间上非常接近，相对于较大的横向尺寸，这种重要的特殊情况被称为#emph[薄介电介质];。当入射光在两个独立的界面上分裂为反射和透射分量时，它在一个递归过程中被散射，这个过程将一些光困在两个界面之间（尽管随着反射次数的增加，这个量逐渐衰减）。
]

#parec[
  While the internal scattering process within a general dielectric may be daunting, simple analytic solutions can fully describe what happens inside such a thin dielectric—that is, an interface pair satisfying the above simplifying conditions. `pbrt` provides a specialized BSDF named `ThinDielectricBxDF` that exploits these insights to efficiently represent an infinite number of internal interactions. It further allows such surfaces to be represented with a single interface, saving the ray intersection expense of tracing ray paths between the two surfaces.
][
  虽然一般介电体内部的散射过程可能令人望而生畏，但简单的解析解可以完全描述在这样一个薄介电介质内部发生的事情——即满足上述简化条件的界面对。`pbrt`提供了一种名为`ThinDielectricBxDF`的专用BSDF，它利用这些见解有效地表示无限数量的内部相互作用。 它还允许用单个界面表示这样的表面，从而节省了光线路径追踪的交叉计算开销。
]

```cpp
class ThinDielectricBxDF {
  public:
    ThinDielectricBxDF(Float eta) : eta(eta) {}
    SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const {
        return SampledSpectrum(0);
    }
    pstd::optional<BSDFSample>
    Sample_f(Vector3f wo, Float uc, Point2f u, TransportMode mode,
             BxDFReflTransFlags sampleFlags) const {
        Float R = FrDielectric(AbsCosTheta(wo), eta), T = 1 - R;
        <<Compute R and T accounting for scattering between interfaces>>
        if (R < 1) {
            R += Sqr(T) * R / (1 - Sqr(R));
            T = 1 - R;
        }
        <<Compute probabilities pr and pt for sampling reflection and transmission>>
        Float pr = R, pt = T;
        if (!(sampleFlags & BxDFReflTransFlags::Reflection)) pr = 0;
        if (!(sampleFlags & BxDFReflTransFlags::Transmission)) pt = 0;
        if (pr == 0 && pt == 0)
            return {};
        if (uc < pr / (pr + pt)) {
            <<Sample perfect specular dielectric BRDF>>
            Vector3f wi(-wo.x, -wo.y, wo.z);
            SampledSpectrum fr(R / AbsCosTheta(wi));
            return BSDFSample(fr, wi, pr / (pr + pt), BxDFFlags::SpecularReflection);
        } else {
            <<Sample perfect specular transmission at thin dielectric interface>>
            Vector3f wi = -wo;
            SampledSpectrum ft(T / AbsCosTheta(wi));
            return BSDFSample(ft, wi, pt / (pr + pt), BxDFFlags::SpecularTransmission);
        }
    }
    PBRT_CPU_GPU
    Float PDF(Vector3f wo, Vector3f wi, TransportMode mode,
              BxDFReflTransFlags sampleFlags) const {
        return 0;
    }
    PBRT_CPU_GPU
    static constexpr const char *Name() { return "ThinDielectricBxDF"; }
    std::string ToString() const;
    PBRT_CPU_GPU
    void Regularize() { /* TODO */ }
    PBRT_CPU_GPU
    BxDFFlags Flags() const {
        return (BxDFFlags::Reflection | BxDFFlags::Transmission | BxDFFlags::Specular);
    }
  private:
    Float eta;
};
```

#parec[
  The only parameter to this `BxDF` is the relative index of refraction of the interior medium.
][
  这个`BxDF`的唯一参数是内部介质的相对折射率。
]

#parec[
  Since this `BxDF` models only perfect specular scattering, both its `f()` and `PDF()` methods just return zero and are therefore not included here.
][
  由于这个`BxDF`仅模拟完美镜面散射，因此它的`f()`和`PDF()`方法仅返回零，因此这里不包括它们。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f16.svg"),
  caption: [
    #ez_caption[
      Light Paths in a Thin Plane-Parallel Dielectric Medium. An incident light ray (red) gives rise to an infinite internal scattering process that occurs within the glass plate (blue). At each scattering event, some fraction of the light manages to escape, causing a successive decay of the trapped energy.
    ][
      薄平行电介质介质中的光路径。入射光线（红色）在玻璃板（蓝色）内引发无限次的内部散射过程。每次散射事件中，都会有一部分光线逃逸出来，导致被困能量逐步衰减。
    ]
  ],
)<plane-parallel-specular-dielectric>

#parec[
  The theory of the thin dielectric BSDF goes back to seminal work by Stokes (#link("Further_Reading.html#cite:Stokes1860")[1860];), who investigated light propagation in stacks of glass plates. @fig:plane-parallel-specular-dielectric illustrates the most common case involving only a single glass plate: an incident light ray (red) reflects and transmits in proportions $R$ and $T = 1 - R$. When the transmitted ray encounters the bottom interface, reciprocity causes it to reflect and transmit according to the same proportions. This process repeats in perpetuity.
][
  薄介电介质BSDF的理论可以追溯到Stokes的开创性工作（#link("Further_Reading.html#cite:Stokes1860")[1860];），他研究了玻璃板堆叠中的光传播。@fig:plane-parallel-specular-dielectric 展示了仅涉及单个玻璃板的最常见情况：入射光线（红色）以比例 $R$ 和 $T = 1 - R$ 反射和透射。当透射光线遇到底部界面时，互易性使其按照相同的比例反射和透射。这个过程不断重复。
]

#parec[
  Of course, rays beyond the first interaction are displaced relative to the entrance point. Due to the assumption of a #emph[thin] dielectric, this spatial shift is considered to be negligible; only the total amount of reflected or transmitted light matters. By making this simplification, it is possible to aggregate the effect of the infinite number of scattering events into a simple modification of the reflectance and transmittance factors.
][
  当然，超出第一次相互作用的光线相对于入口点是位移的。由于假设是#emph[薄];介电介质，这种空间位移被认为是可以忽略的；只有反射或透射光的总量才重要。通过这种简化，可以将无限次散射事件的效果简化为反射率和透射率因子的简单调整。
]

#parec[
  Consider the paths that are reflected out from the top layer. Their aggregate reflectance $R prime$ is given by a geometric series that can be converted into an explicit form:
][
  考虑从顶层反射出的路径。它们的总反射率 $R prime$ 由一个几何级数给出，可以转换为显式形式：
]

$ R' = R + T R T + T R R R T + dots.h = R + frac(T^2 R, 1 - R^2) . $<stokes-plates-R>

#parec[
  A similar series gives how much light is transmitted, but it can be just as easily computed as $T prime = 1 - R prime$, due to energy conservation. @fig:stokes-R-vs-Rprime plots $R prime$ and $R$ as a function of incident angle $theta$. The second interface has the effect of increasing the overall amount of reflection compared to a single Fresnel interaction.
][
  类似的级数给出透射光的量，但由于能量守恒，它可以同样容易地计算为 $T prime = 1 - R prime$。@fig:stokes-R-vs-Rprime 绘制了 $R prime$ 和 $R$ 作为入射角 $theta$ 的函数。第二个界面的效果是增加了相对于单个Fresnel相互作用的整体反射量。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f17.svg"),
  caption: [
    #ez_caption[
      Reflectance of a Fresnel Interface and a Thin Dielectric. This plot compares the reflectance of a single dielectric interface with $eta=1.5$ as determined by the Fresnel equations (@eqt:fresnel) to that of a matching thin dielectric according to @eqt:stokes-plates-R.
    ][
      菲涅耳界面与薄电介质的反射率。这张图将通过菲涅耳方程（@eqt:fresnel）计算的单一电介质界面（折射率 \( \eta = 1.5 \)）的反射率，与根据@eqt:stokes-plates-R 计算的匹配的薄电介质的反射率进行了比较。

    ]
  ],
)<stokes-R-vs-Rprime>


#parec[
  The `Sample_f()` method computes the $R prime$ and $T prime$ coefficients and then computes probabilities for sampling reflection and transmission, just as the #link("<DielectricBxDF>")[`DielectricBxDF`] did, reusing the corresponding code fragment.
][
  `Sample_f()`方法计算 $R prime$ 和 $T prime$ 系数，然后计算采样反射和透射的概率，就像#link("<DielectricBxDF>")[`DielectricBxDF`];所做的那样，重用相应的代码片段。
]

```cpp
pstd::optional<BSDFSample>
Sample_f(Vector3f wo, Float uc, Point2f u, TransportMode mode,
         BxDFReflTransFlags sampleFlags) const {
    Float R = FrDielectric(AbsCosTheta(wo), eta), T = 1 - R;
    <<Compute R and T accounting for scattering between interfaces>>
    if (R < 1) {
        R += Sqr(T) * R / (1 - Sqr(R));
        T = 1 - R;
    }
    <<Compute probabilities pr and pt for sampling reflection and transmission>>
    Float pr = R, pt = T;
    if (!(sampleFlags & BxDFReflTransFlags::Reflection)) pr = 0;
    if (!(sampleFlags & BxDFReflTransFlags::Transmission)) pt = 0;
    if (pr == 0 && pt == 0)
        return {};
    if (uc < pr / (pr + pt)) {
        <<Sample perfect specular dielectric BRDF>>
        Vector3f wi(-wo.x, -wo.y, wo.z);
        SampledSpectrum fr(R / AbsCosTheta(wi));
        return BSDFSample(fr, wi, pr / (pr + pt), BxDFFlags::SpecularReflection);
    } else {
        <<Sample perfect specular transmission at thin dielectric interface>>
        Vector3f wi = -wo;
        SampledSpectrum ft(T / AbsCosTheta(wi));
        return BSDFSample(ft, wi, pt / (pr + pt), BxDFFlags::SpecularTransmission);
    }
}
```


#parec[
  The updated reflection and transmission coefficients are easily computed using @eqt:stokes-plates-R, though care must be taken to avoid a division by zero in the case of $R = 1$.
][
  使用@eqt:stokes-plates-R 可以轻松计算更新的反射和透射系数，但在 $R = 1$ 的情况下必须小心避免除以零。
]

```cpp
if (R < 1) {
    R += Sqr(T) * R / (1 - Sqr(R));
    T = 1 - R;
}
```

#parec[
  The #link("<DielectricBxDF>")[`DielectricBxDF`] fragment that samples perfect specular reflection is also reused in this method's implementation, inheriting the computed `R` value. The transmission case slightly deviates from the `DielectricBxDF`, as the transmitted direction is simply the negation of `wo`.
][
  在这个方法的实现中，还重用了#link("<DielectricBxDF>")[`DielectricBxDF`];片段，该片段采样完美镜面反射，继承了计算的`R`值。透射情况与`DielectricBxDF`略有不同，因为透射方向只是`wo`的负值。
]

```cpp
Vector3f wi = -wo;
SampledSpectrum ft(T / AbsCosTheta(wi));
return BSDFSample(ft, wi, pt / (pr + pt), BxDFFlags::SpecularTransmission);
```



=== Non-Symmetric Scattering and Refraction #emoji.warning
<non-symmetric-scattering-and-refraction>

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f18.svg"),
  caption: [
    #ez_caption[
      Snell’s Window. If one looks upward when underwater in a swimming pool, the sky is only visible through a circular window because no light is refracted beyond the critical angle. Outside of the window, only the reflection of the pool bottom is seen.
    ][
      斯涅尔之窗。在游泳池中向上看时，天空只能通过一个圆形窗口看到，因为超过临界角后光线不会再发生折射。在这个窗口之外，能看到的只有池底的反射。
    ]
  ],
)<snells-window>

#parec[
  All physically based BRDFs are symmetric: the incident and outgoing directions can be interchanged without changing the function's value. However, the same is not generally true for BTDFs. Non-symmetry with BTDFs is due to the fact that when light refracts into a material with a higher index of refraction than the incident medium's index of refraction, energy is compressed into a smaller set of angles (and vice versa, when going in the opposite direction). This effect is easy to see yourself, for instance, by looking at the sky from underwater in a quiet outdoor swimming pool. Because no light can be refracted above the critical angle ( $~48.6#sym.degree$ for water), the incident hemisphere of light is squeezed into a considerably smaller subset of the hemisphere, which covers the remaining set of angles (@fig:snells-window). Radiance along rays that do refract therefore must increase so that energy is preserved when light passes through the interface.
][
  所有基于物理原理的BRDF都是对称的：入射和出射方向可以互换而不改变函数的值。然而，对于BTDF来说，情况通常并非如此。BTDF的非对称性是由于当光折射进入折射率高于入射介质的材料时，能量被压缩到一组较小的角度（反之亦然，当光从相反方向进入时）。 这种效果很容易观察到，例如，当你在一个安静的室外游泳池中从水下看天空时。由于没有光可以在超过临界角（对于水约为48.6°）的情况下折射，入射光的半球被压缩到一个明显较小的半球子集中，覆盖剩余的角度集合（@fig:snells-window）。因此，沿着折射光线的辐射亮度必须增加，以便在光通过界面时能量得以保持。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f19.svg"),
  caption: [
    #ez_caption[
      The amount of transmitted radiance at the boundary between media with different indices of refraction is scaled by the squared ratio of the two indices of refraction. Intuitively, this can be understood as the result of the radiance’s differential solid angle being compressed or expanded as a result of transmission.
    ][
      在具有不同折射率的介质边界处，透射辐射度的量会按两个折射率的平方比进行缩放。直观上，这可以理解为由于透射，辐射度的微分立体角被压缩或扩展的结果。
    ]
  ],
)<radiance-boundary>

#parec[
  More formally, consider incident radiance arriving at the boundary between two media, with indices of refraction $eta_i$ and $eta_o$ (@fig:radiance-boundary). Assuming for now that all the incident light is transmitted, the amount of transmitted differential flux is then
][
  更正式地，考虑到达两个介质边界的入射辐射亮度，其折射率为 $eta_i$ 和 $eta_o$ （@fig:radiance-boundary）。暂时假设所有入射光都被传输，传输的微分通量为
]

$ upright(d)^2 Phi_o = upright(d)^2 Phi_i . $



#parec[
  If we use the definition of radiance, Equation (4.3), we equivalently have
][
  如果我们使用辐射亮度的定义，方程（4.3），我们同样有
]

$ L_o cos theta_o thin upright(d) A thin d omega_o = L_i cos theta_i thin upright(d) A thin omega_i . $


#parec[
  Expanding the solid angles to spherical angles gives
][
  将立体角扩展为球面角，得到
]

$
  L_o cos theta_o thin upright(d) A thin sin theta_o thin upright(d) theta_o thin upright(d) phi.alt_o = L_i cos theta_i thin upright(d) A thin sin theta_i thin upright(d) theta_i thin upright(d) phi.alt_i .
$<spherical-L-transmitted>

#parec[
  Differentiating Snell's law, @eqt:snells-law, with respect to $theta$ gives the useful relation
][
  对斯涅尔定律（ @eqt:snells-law）关于 $theta$ 求导，得到一个有用的关系
]

$ eta_o cos theta_o thin upright(d) theta_o = eta_i cos theta_i thin upright(d) theta_i , $

#parec[
  or
][
  或
]

$ frac(cos theta_o thin upright(d) theta_o, cos theta_i thin upright(d) theta_i) = eta_i / eta_o . $


#parec[
  Substituting both Snell's law and this relationship into @eqt:spherical-L-transmitted and then simplifying, we have
][
  将斯涅尔定律和这个关系代入@eqt:spherical-L-transmitted 并简化，得到
]

$ L_o eta_i^2 thin d phi.alt_o = L_i eta_o^2 thin d phi.alt_i . $



#parec[
  Finally, $upright(d) phi.alt_i = upright(d) phi.alt_o$, which gives the final relationship between incident and transmitted radiance:
][
  最后，由于 $upright(d) phi.alt_i = upright(d) phi.alt_o$，这给出了入射和传输辐射亮度之间的最终关系：
]

$ L_o = L_i eta_o^2 / eta_i^2 . $<transmitted-radiance-change>

#parec[
  The symmetry relationship satisfied by a BTDF is thus
][
  因此，BTDF满足的对称关系为
]

$ eta_o^2 f_t (p , omega_o , omega_i) = eta_i^2 f_t (p , omega_i , omega_o) . $<btdf-symmetry>



#parec[
  Non-symmetric scattering can be particularly problematic for bidirectional light transport algorithms that sample light paths starting both from the camera and from the lights. If non-symmetry is not accounted for, then such algorithms may produce incorrect results, since the design of such algorithms is fundamentally based on the principle of symmetry.
][
  非对称散射对于双向光传输算法来说可能特别棘手，这些算法从相机和光源同时采样光路径。如果不考虑非对称性，那么这些算法可能会产生错误的结果，因为这些算法的设计基本上是基于对称性原则的。
]

#parec[
  We will say that light paths sampled starting from the lights carry #emph[importance] while paths starting from the camera carry radiance. These terms correspond to the quantity that is recorded at a path's starting point. With importance transport, the incident and outgoing direction arguments of the BSDFs will be (incorrectly) reversed unless special precautions are taken.
][
  我们将说，从光源开始采样的光路径携带#emph[重要度];，而从相机开始的路径携带辐射。这些术语对应于在路径起始点记录的物理量。 在重要度传输中，若未采取特殊措施，BSDF的入射和出射方向参数将被错误地颠倒。
]

#parec[
  We thus define the #emph[adjoint BSDF] $f^(*)$, whose only role is to evaluate the original BSDF with swapped arguments:
][
  因此，我们定义了#emph[伴随BSDF] $f^(*)$，其唯一作用是用交换后的参数评估原始BSDF：
]

$ f^(\*) (p , omega_o , omega_i) = f (p , omega_i , omega_o) . $


#parec[
  All sampling steps based on importance transport use the adjoint form of the BSDF rather than its original version. Most BSDFs in `pbrt` are symmetric so that there is no actual difference between $f$ and $f^(\*)$. However, non-symmetric cases require additional attention.
][
  所有基于重要度传输的采样步骤都使用BSDF的伴随形式，而不是其原始版本。`pbrt`中的大多数BSDF是对称的，因此 $f$ 和 $f^(\*)$ 之间实际上没有区别。然而，非对称情况需要额外的注意。
]

#parec[
  The `TransportMode` enumeration is used to inform such non-symmetric BSDFs about the transported quantity so that they can correctly switch between the adjoint and non-adjoint forms.
][
  `传输模式`枚举用于通知这些非对称BSDF关于传输的量，以便它们可以在伴随和非伴随形式之间正确切换。
]

```cpp
enum class TransportMode { Radiance, Importance };
```


#parec[
  The adjoint BTDF is then
][
  伴随BTDF为
]

$ f_t^(\*) (p , omega_o , omega_i) = f_t (p , omega_i , omega_o) = eta_i^2 / eta_o^2 f_t (p , omega_o , omega_i) , $


#parec[
  which effectively cancels out the scale factor in @eqt:transmitted-radiance-change.
][
  这有效地消除了@eqt:transmitted-radiance-change 中的比例因子的影响。
]

#parec[
  With these equations, we can now define the remaining missing piece in the implementation of the `DielectricBxDF` evaluation and sampling methods. Whenever radiance is transported over a refractive boundary, we apply the scale factor from Equation (@eqt:transmitted-radiance-change ). For importance transport, we use the adjoint BTDF, which lacks the scaling factor due to the combination of Equations (@eqt:transmitted-radiance-change) and (@eqt:btdf-symmetry).
][
  通过这些方程，我们现在可以定义`DielectricBxDF`评估和采样方法实现中剩余的缺失部分。每当辐射通过折射边界传输时，我们应用方程(@eqt:transmitted-radiance-change)中的比例因子。对于重要度传输，我们使用缺少比例因子的伴随BTDF，这是由于方程(@eqt:transmitted-radiance-change)和(@eqt:btdf-symmetry)的组合。
]

```cpp
if (mode == TransportMode::Radiance)
    ft /= Sqr(etap);
```


