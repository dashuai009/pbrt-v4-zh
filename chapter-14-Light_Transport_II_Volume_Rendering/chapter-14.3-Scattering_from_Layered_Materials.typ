#import "../template.typ": parec, ez_caption

== Scattering from Layered Materials
<scattering-from-layered-materials>

#parec[
  In addition to describing scattering from larger-scale volumetric media like clouds or smoke, the equation of transfer can be used to model scattering at much smaller scales. The `LayeredBxDF` applies it to this task, implementing a reflection model that accounts for scattering from two interfaces that are represented by surfaces with independent BSDFs and with a medium between them. Monte Carlo can be applied to estimating the integrals that describe the aggregate scattering behavior, in a way similar to what is done in light transport algorithms. This approach is effectively the generalization of the technique used to sum up aggregate scattering from a pair of perfectly smooth dielectric interfaces in the `ThinDielectricBxDF` in @thin-dielectric-bsdf.
][
  除了描述来自云或烟雾等大尺度体积介质的散射外，传输方程还可以用于模拟更小尺度的散射。 `LayeredBxDF` 将其应用于这一任务，实现了一种反射模型，该模型考虑了由具有独立BSDF的表面表示的两个界面之间的散射，并在它们之间有一个介质。 蒙特卡罗方法可以用于估计描述整体散射行为的积分，类似于在光传输算法中所做的。 这种方法实际上是对在@thin-dielectric-bsdf 中`ThinDielectricBxDF`用于总结一对完美光滑的介电界面整体散射的技术的推广。
]

#parec[
  Modeling surface reflectance as a composition of layers makes it possible to describe a variety of surfaces that are not well modeled by the BSDFs presented in @reflection-models. For example, automobile paint generally has a smooth reflective "clear coat" layer applied on top of it; the overall appearance of the paint is determined by the combination of light scattering from the layer's interface as well as light scattering from the paint. (See @fig:scattering-layered-surfaces.) Tarnished metal can be modeled by an underlying metal BRDF with a thin scattering medium on top of it; it is again the aggregate result of a variety of light scattering paths that determines the overall appearance of the surface.
][
  将表面反射建模为层的组合，使得可以描述@reflection-models 中提出的BSDF无法很好建模的各种表面。 例如，汽车漆通常在其上涂有一层光滑的反射“清漆”层；漆的整体外观由层界面的光散射与漆的光散射的组合决定。 （见@fig:scattering-layered-surfaces。）失去光泽的金属可以通过在其底层金属BRDF上方添加一层薄散射介质来建模；再次是各种光散射路径的整体结果决定了表面的整体外观。
]


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f11.svg"),
  caption: [
    #ez_caption[
      #emph[Scattering from Layered Surfaces.] Surface
      reflection can be modeled with a series of layers, where each interface
      between media is represented with a BSDF and where the media between
      layers may itself both absorb and scatter light.
      The aggregate scattering from such a configuration can be determined by
      finding solutions to the equation of transfer.
    ][
      #emph[分层表面的散射。]
      表面反射可以通过一系列层来建模，其中介质之间的每个界面都由一个BSDF表示，而层之间的介质本身可能既吸收又散射光。 通过求解传输方程，可以确定这种配置的整体散射。

    ]
  ],
)<scattering-layered-surfaces>

#parec[
  With general layered media, light may exit the surface at a different point than that at which it entered it. The `LayeredBxDF` does not model this effect but instead assumes that light enters and exits at the same point on the surface. (As a `BxDF`, it is unable to express any other sort of scattering, anyway.) This is a reasonable approximation if the distance between the two interfaces is relatively small. This approximation makes it possible to use a simplified 1D version of the equation of transfer. After deriving this variant, we will show its application to evaluating and sampling such BSDFs.
][
  对于一般的分层介质，光可能在不同于进入点的表面点处退出。 `LayeredBxDF` 不模拟这种效果，而是假设光在表面的同一点进入和退出。 （作为一个`BxDF`，它本质上无法表达任何其他类型的散射。）如果两个界面之间的距离相对较小，这是一种合理的近似。 这种近似使得可以使用简化的一维传输方程。 在推导出这个变体后，我们将展示其在评估和采样此类BSDF中的应用。
]


=== The One-Dimensional Equation of Transfer

#parec[
  Given #emph[plane-parallel] 3D scattering media where the scattering properties are homogeneous across planes and only vary in depth, and where the incident illumination does not vary as a function of position over the medium's planar boundary, the equations that describe scattering can be written in terms of 1D functions over depth (see @fig:1d-eot-setting).
][
  给定#emph[平行平面];三维散射介质，其中散射特性在平面上是均匀的，仅在深度上变化，并且入射光照不随介质平面边界上的位置变化，描述散射的方程可以用深度上的一维函数来表示（见@fig:1d-eot-setting）。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f12.svg"),
  caption: [
    #ez_caption[
      Setting for the One-Dimensional Equation of Transfer. If the properties of the medium only vary in one dimension and if the incident illumination is uniform over its boundary, then the equilibrium radiance distribution varies only with depth $z$ and direction $omega$ and a 1D specialization of the equation of transfer can be used.
    ][
      一维辐射传输方程的设置：如果介质的属性仅在一个维度上变化，并且入射辐射在其边界上是均匀的，那么平衡辐射分布仅随深度 $z$ 和方向 $omega$ 变化，此时可以使用辐射传输方程的一维特化形式。
    ]
  ],
)<1d-eot-setting>

#parec[
  In this setting, the various quantities are more conveniently expressed as functions of depth $z$ rather than of distance $t$ along a ray. For example, if the extinction coefficient is given by $sigma_t (z)$, then the transmittance between two depths $z_0$ and $z_1$ for a ray with direction $omega$ is
][
  在这种设置中，各种量更方便地表示为深度 $z$ 的函数，而非射线距离 $t$。 例如，如果消光系数由 $sigma_t (z)$ 给出，则对于方向为 $omega$ 的射线 ， 从 深 度 $z_0$ 到 $z_1$ 的透射率为
]

$
  T_r (z_0 arrow.r z_1 , omega) = e^(- integral_(z_0)^(z_1) sigma_t ( z' ) \/ lr(|cos theta|) thin d z') = e^(- integral_(z_0)^(z_1) sigma_t (z') \/ lr(|omega_z|) thin d z') .
$


#parec[
  See @fig:transmittance-1d. This definition uses the fact that if a ray with direction $omega$ travels a distance $t$, then the change in $z$ is $t omega_z$.
][
  见@fig:transmittance-1d。这个定义利用了这样一个事实：如果一个方向为 $omega$ 的 射 线 行 进 距 离 $t$， 则 $z$ 的 变 化 为 $t_z$。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f13.svg"),
  caption: [
    #ez_caption[
      The distance between two depths $d$ is given by the $z$ distance between
      them divided by the cosine of the ray’s angle with respect to the $z$
      axis, $omega$.
      The transmittance follows.

    ][
      两个深度之间的距离$d$由它们之间的$z$距离除以射线与$z$轴的角度$omega$的余弦给出。
      透射率随之而来。
    ]
  ],
)<transmittance-1d>

#parec[
  In the case of a homogeneous medium,
][
  在均匀介质的情况下，
]

$ T_r (z_0 arrow.r z_1 , omega) = e^(- sigma_t lr(|(z_0 - z_1) / omega_z|)) . $
<beamtrans-1d-homogeneous>

#parec[
  The 1D equation of transfer can be found in a similar fashion. It says that at points inside the medium the incident radiance at a depth $z$ in direction $omega$ is given by
][
  可以以类似的方式找到一维传输方程。 它表示在介质内部的点处，深度 $z$ 方向 $omega$ 上的入射辐射由
]


$
  L_i (z , omega) = T_r (z arrow.r z_i , omega) L_o ( z_i , - omega ) + integral_z^(z_i) frac(T_r (z arrow.r z prime , omega) L_s (z prime , - omega), lr(|omega_z|)) thin d z prime ,
$<eot-1d>


#parec[
  where $z_i$ is the depth of the medium interface that the ray from $z$ in direction $omega$ intersects. (See @fig:1d-eot-specialization.) At boundaries, the incident radiance function is given by @eqt:eot-1d for directions $omega$ that point into the medium. For directions that point outside it, incident radiance is found by integrating illumination from the scene.
][
  其中 $z_i$ 是从 $z$ 出发，沿方向 $omega$ 的光线与介质界面相交的深度。（见@fig:1d-eot-specialization。）在边界处，当方向 $omega$ 指向介质内部时，入射辐射度函数由@eqt:eot-1d 给出。对于指向外部的方向，入射辐射度是通过对场景中的照明进行积分来获得的。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f14.png"),
  caption: [
    #ez_caption[
      The 1D specialization of the equation of transfer from
      @eqt:eot-1d expresses the incident radiance $L_i$ at
      a depth $z$ as the sum of attenuated radiance $L_o$ from the
      interface that is visible along the ray and the transmission-modulated
      source function $L_s$ integrated over $z$.
    ][
      辐射传输方程（@eqt:eot-1d）的一维特化形式表示，在深度 $z$ 处的入射辐射 $L_i$ 是从光线方向上可见的界面处的衰减辐射 $L_o$ 与沿 $z$ 积分的透射调制源函数 $L_s$ 之和。
    ]
  ],
)<1d-eot-specialization>

#parec[
  The scattering from an interface at a boundary of the medium is given by the incident radiance modulated by the boundary's BSDF,
][
  介质边界处界面散射由边界的 BSDF 调制的入射辐射度给出，
]

$
  L_o (z , omega_o) = integral_(cal(S)^2) f_z (omega_o , omega prime) L_i ( z , omega prime ) lr(|cos theta prime|) thin d omega prime .
$<boundary-scattering-1d>


#parec[
  If we also assume there is no volumetric emission (as we will do in the LayeredBxDF), the source function in @eqt:eot-1d simplifies to
][
  如果我们还假设没有体积发射（正如我们将在 LayeredBxDF 中所做的那样），则@eqt:eot-1d 中的源函数简化为
]

$
  L_s (z , omega) = sigma_s / sigma_t integral_(cal(S)^2) p (omega prime , omega) L_i ( z , omega prime ) thin d omega prime .
$<source-term-1d>


#parec[
  The LayeredBxDF further assumes that $sigma_t$ is constant over all wavelengths in the medium, which means that null scattering is not necessary for sampling distances in the medium. Null scattering is easily included in the 1D simplification of the equation of transfer if necessary, though we will not do so here. For similar reasons, we will also not derive its path integral form in 1D, though it too can be found with suitable simplifications to the approach that was used in @generalized-path-space. The "Further Reading" section has pointers to more details.
][
  LayeredBxDF 进一步假设 $sigma_t$ 在介质中的所有波长上都是恒定的，这意味着在介质中采样距离时不需要零散射。尽管如此，零散射很容易包含在传输方程的 1D 简化中，但我们在这里不会这样做。出于类似的原因，我们也不会在 1D 中推导其路径积分形式，尽管它也可以通过适当简化@generalized-path-space 中使用的方法找到。"进一步阅读"部分提供了更多详细信息的指引。
]

=== Layered BxDF
<layered-bxdf>


#parec[
  The equation of transfer describes the equilibrium distribution of radiance, though our interest here is in evaluating and sampling the BSDF that represents all the scattering from the layered medium. Fortunately, these two things can be connected. If we would like to evaluate the BSDF for a pair of directions $omega_o$ and $omega_i$, then we can define an incident radiance function from a virtual light source from $omega_i$ as
][
  传输方程描述了辐射度的平衡分布，尽管我们在这里的兴趣在于评估和采样代表所有来自分层介质的散射的 BSDF。幸运的是，这两者可以连接起来。如果我们想要评估一对方向 $omega_o$ 和 $omega_i$ 的 BSDF，那么我们可以从 $omega_i$ 的虚拟光源定义一个入射辐射度函数，如下所示：
]

$ L_i (omega) = frac(delta (omega - omega_i), lr(|cos theta_i|)) . $
<virtual-directional-light>

#parec[
  If a 1D medium is illuminated by such a light, then the outgoing radiance $L_o (omega_o)$ at the medium's interface is equivalent to the value of the BSDF, $f (omega_o , omega_i)$ (see @fig:layers-virtual-directional-light). One way to understand why this is so is to consider using such a light with the surface reflection equation:
][
  如果这样的光照亮 1D 介质，那么在介质界面处的出射辐射度 $L_o (omega_o)$ 等于 BSDF 的值 $f (omega_o , omega_i)$ （见@fig:layers-virtual-directional-light）。理解这种情况的一种方法是考虑将这样的光与表面反射方程结合使用：
]


$
  L_o (omega_o) = integral_(S^2) f (omega_o , omega) L_i (omega) lr(|cos theta|) thin d omega = integral_(S^2) f ( omega_o , omega ) delta (omega - omega_i) thin d omega = f (omega_o , omega_i) .
$


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f15.png"),
  caption: [
    #ez_caption[
      If a medium is illuminated with a virtual light source of
      the form of @eqt:virtual-directional-light, then the radiance leaving the surface in
      the direction $omega_o$ is equivalent to the layered surface’s BSDF,
      $f (omega_o , omega_i)$.
    ][
      如果一个介质被@eqt:virtual-directional-light 形式的虚拟光源照亮，那么在方向
      $omega_o$ 离开表面的辐射度等同于分层表面的
      BSDF，$f (omega_o , omega_i)$。
    ]
  ],
)<layers-virtual-directional-light>


#parec[
  Thus, integrating the equation of transfer with such a light allows us to evaluate and sample the corresponding BSDF. However, this means that unlike all the `BxDF` implementations from @reflection-models, the values that `LayeredBxDF` returns from methods like `f()` and `PDF()` are stochastic. This is perfectly fine in the context of all of `pbrt`'s Monte Carlo–based techniques and does not affect the correctness of other estimators that use these values; it is purely one more source of error that can be controlled in a predictable way by increasing the number of samples.
][
  因此，使用这样的光源对传输方程进行积分可以让我们评估和采样相应的 BSDF。然而，这意味着与@reflection-models 中的所有 `BxDF` 实现不同，`LayeredBxDF` 从方法如 `f()` 和 `PDF()` 返回的值是随机的。 在 `pbrt` 的所有基于蒙特卡罗的技术背景下，这完全没有问题，并且不会影响使用这些值的其他估计器的正确性；这只是一个可以通过增加样本数量以可预测的方式控制的误差来源。
]

#parec[
  The `LayeredBxDF` allows the specification of only two interfaces and a homogeneous participating medium between them. @fig:layered-bxdf-geometric-setting illustrates the geometric setting. Surfaces with more layers can be modeled using a `LayeredBxDF` where one or both of its layers are themselves `LayeredBxDF`s. (An exercise at the end of the chapter discusses a more efficient approach for supporting additional layers.)
][
  `LayeredBxDF` 允许指定仅有两个界面和它们之间的均匀参与介质。@fig:layered-bxdf-geometric-setting 展示了几何设置。 具有更多层的表面可以使用 `LayeredBxDF` 来建模，其中一个或两个层本身是 `LayeredBxDF`。（本章末尾的练习讨论了一种支持额外层的更高效的方法。）
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f16.png"),
  caption: [
    #ez_caption[
      Geometric Setting for the `LayeredBxDF`. Scattering is
      specified by two interfaces with associated BSDFs where the bottom one
      is at $z = 0$ and there is a medium of user-specified thickness between
      the two interfaces.
    ][
      `LayeredBxDF` 的几何设置。散射由两个界面指定，相关的 BSDF
      位于底部 $z = 0$，并且在两个界面之间有一个用户指定厚度的介质。
    ]
  ],
)<layered-bxdf-geometric-setting>


#parec[
  The types of `BxDF`s at both interfaces can be provided as template parameters. While the user of a `LayeredBxDF` is free to provide a `BxDF` for both of these types (in which case `pbrt`'s regular dynamic dispatch mechanism will be used), performance is better if they are specific `BxDF`s and the compiler can generate a specialized implementation.
][
  可以将两界面处的 `BxDF` 类型作为模板参数提供。虽然 `LayeredBxDF` 的用户可以自由提供这两种类型的 `BxDF`（在这种情况下将使用 `pbrt` 的常规动态调度机制），但如果它们是特定的 `BxDF` 并且编译器可以生成专门的实现，则性能更好。
]

#parec[
  This approach is used for the `CoatedDiffuseBxDF` and the `CoatedConductorBxDF` that are defined in @coated-diffuse-and-coated-conductor-materials. (The meaning of the `twoSided` template parameter will be explained in a few pages, where it is used.)
][
  这种方法用于@coated-diffuse-and-coated-conductor-materials 中定义的 `CoatedDiffuseBxDF` 和 `CoatedConductorBxDF`。（`twoSided` 模板参数的含义将在几页后解释。）
]

```cpp
<<LayeredBxDF Definition>>=
template <typename TopBxDF, typename BottomBxDF, bool twoSided>
class LayeredBxDF {
  public:
    <<LayeredBxDF Public Methods>>
  private:
    <<LayeredBxDF Private Methods>>
    <<LayeredBxDF Private Members>>
};
```


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f17.svg"),
  caption: [
    #ez_caption[
      Effect of Varying Medium Thickness with the `LayeredBxDF`. (a) Dragon with surface reflectance modeled by a smooth conductor base
      layer and a dielectric interface above it. (b) With a scattering layer with albedo $0.7$ and thickness $0.15$ between
      the interface and the conductor, the reflection of the conductor is
      slightly dimmed. (c) ith a thicker scattering layer of thickness $0.5$, the conductor is
      much more attenuated and the overall reflection is more diffuse. (Dragon model courtesy of the Stanford Computer Graphics Laboratory.)
    ][
      (a) 龙的表面反射由光滑导体基底层和其上方的介电界面建模。 (b) 在界面和导体之间有一个散射层，反照率为 $0.7$，厚度为
      $0.15$，导体的反射略微变暗。 (c) 在厚度为 $0.5$ 的更厚的散射层下，导体被大大削弱，整体反射更加漫射。 （龙模型由斯坦福计算机图形实验室提供。）
    ]
  ],
)<layered-bxdf-thickness>




#parec[
  In addition to `BxDF`s for the two interfaces, the `LayeredBxDF` maintains member variables that describe the medium between them. Rather than have the user specify scattering coefficients, which can be unintuitive to set manually, it assumes a medium with $sigma_t = 1$ and leaves it to the user to specify both the thickness of the medium and its scattering albedo. @fig:layered-bxdf-thickness shows the effect of varying the thickness of the medium between a conductor base layer and a dielectric interface.
][
  除了两个界面的 `BxDF`，`LayeredBxDF` 还维护描述它们之间介质的成员变量。 它假设一个 $sigma_t = 1$ 的介质，而不是让用户指定散射系数，这可能难以手动设置，并让用户指定介质的厚度和其散射反照率。@fig:layered-bxdf-thickness 显示了在导体基底层和介电界面之间改变介质厚度的效果。
]

```cpp
<<LayeredBxDF Private Members>>=
TopBxDF top;
BottomBxDF bottom;
Float thickness, g;
SampledSpectrum albedo;
```

#parec[
  Two parameters control the Monte Carlo estimates. `maxDepth` has its usual role in setting a maximum number of scattering events along a path and `nSamples` controls the number of independent samples of the estimators that are averaged. Because additional samples in this context do not require tracing more rays or evaluating textures, it is more efficient to reduce any noise due to the stochastic BSDF by increasing this sampling rate rather than increasing the pixel sampling rate if a higher pixel sampling rate is not otherwise useful.
][
  两个参数控制蒙特卡洛估计：`maxDepth` 扮演其通常的角色，设置路径上的最大散射事件数；`nSamples` 控制被平均的估计值的独立样本数量。由于在这种情况下增加样本数量不需要追踪更多光线或评估更多纹理，因此，如果提高像素采样率并无其他作用，通过增加该采样率来减少因随机 BSDF 导致的噪声会更加高效。
]

```cpp
<<LayeredBxDF Private Members>>+=
int maxDepth, nSamples;
```

#parec[
  We will find it useful to have a helper function `Tr()` that returns the transmittance for a ray segment in the medium with given direction `w` that passes through a distance `dz` in $z$, following @eqt:beamtrans-1d-homogeneous with $sigma_t = 1$.
][
  我们将发现有一个辅助函数 `Tr()` 很有用，它返回在给定方向 `w` 的介质中穿过距离 `dz` 的光线段的透射率，遵循@eqt:beamtrans-1d-homogeneous 设定 $sigma_t = 1$。
]

```cpp
static Float Tr(Float dz, Vector3f w) {
    return FastExp(-std::abs(dz / w.z));
}
```

#parec[
  Although the `LayeredBxDF` is specified in terms of top and bottom interfaces, we will find it useful to exchange the “top” and “bottom” as necessary to have the convention that the interface that the incident ray intersects is defined to be the top one. (See @fig:layeredbxdf-top-or-bottom.) A helper class, `TopOrBottomBxDF`, manages the logic related to these possibilities. As its name suggests, it stores a pointer to one (and only one) of two `BxDF` types that are provided as template parameters.
][
  尽管 `LayeredBxDF` 是根据顶部和底部界面定义的，但为了方便起见，我们会在必要时交换“顶部”和“底部”，以遵循这样的约定：入射光线与其相交的界面被定义为顶部界面。（参见@fig:layeredbxdf-top-or-bottom。）一个辅助类 `TopOrBottomBxDF` 管理与这些可能性相关的逻辑。顾名思义，它存储了一个指针，指向作为模板参数提供的两种 `BxDF` 类型之一（且仅限其中之一）。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f18.svg"),
  caption: [
    #ez_caption[
      If the incident ray intersects the layer at
      $z = upright("thickness")$, then the top layer is the same as is
      specified in the `LayeredBxDF::top` member variable.
      However, if it intersects the surface from the other direction at
      $z = 0$, we will find it useful to treat the $z = 0$ layer as the top
      one and the other as the bottom.
      The `TopOrBottomBxDF` class helps with related bookkeeping.

    ][
      如果入射光线在 $z = upright("thickness")$
      处与层相交，那么顶层与 `LayeredBxDF::top` 成员变量中指定的相同。
      然而，如果它从另一个方向在 $z = 0$ 处与表面相交，我们会发现将 $z = 0$
      层视为顶层而另一个视为底层是有用的。
      `TopOrBottomBxDF` 类有助于相关的簿记。
    ]
  ],
)<layeredbxdf-top-or-bottom>


```cpp
template <typename TopBxDF, typename BottomBxDF>
class TopOrBottomBxDF {
  public:
    TopOrBottomBxDF() = default;
    PBRT_CPU_GPU
    TopOrBottomBxDF &operator=(const TopBxDF *t) {
        top = t;
        bottom = nullptr;
        return *this;
    }
    PBRT_CPU_GPU
    TopOrBottomBxDF &operator=(const BottomBxDF *b) {
        bottom = b;
        top = nullptr;
        return *this;
    }
    SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const {
        return top ? top->f(wo, wi, mode) : bottom->f(wo, wi, mode);
    }
    PBRT_CPU_GPU
    pstd::optional<BSDFSample> Sample_f(
        Vector3f wo, Float uc, Point2f u, TransportMode mode,
        BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const {
        return top ? top->Sample_f(wo, uc, u, mode, sampleFlags)
                   : bottom->Sample_f(wo, uc, u, mode, sampleFlags);
    }

    PBRT_CPU_GPU
    Float PDF(Vector3f wo, Vector3f wi, TransportMode mode,
              BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const {
        return top ? top->PDF(wo, wi, mode, sampleFlags)
                   : bottom->PDF(wo, wi, mode, sampleFlags);
    }

    PBRT_CPU_GPU
    BxDFFlags Flags() const { return top ? top->Flags() : bottom->Flags(); }
  private:
    const TopBxDF *top = nullptr;
    const BottomBxDF *bottom = nullptr;
};
```


#parec[
  `TopOrBottomBxDF` provides the implementation of a number of `BxDF` methods like `f()`, where it calls the corresponding method of whichever of the two `BxDF` types has been provided. In addition to `f()`, it has similar straightforward `Sample_f()`, `PDF()`, and `Flags()` methods, which we will not include here.
][
  `TopOrBottomBxDF` 提供了多个 `BxDF` 方法的实现，如 `f()`，它调用提供的两个 `BxDF` 类型中对应的方法。 除了 `f()`，它还有类似的简单 `Sample_f()`、`PDF()` 和 `Flags()` 方法，这里我们将不包括在内。
]

```cpp
SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const {
    return top ? top->f(wo, wi, mode) : bottom->f(wo, wi, mode);
}
```
==== BSDF Evaluation

#parec[
  The BSDF evaluation method `f()` can now be implemented; it returns an average of the specified number of independent samples.
][
  The BSDF evaluation method `f()` can now be implemented; it returns an average of the specified number of independent samples.
]


```cpp
<<LayeredBxDF Public Methods>>=
SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const {
    SampledSpectrum f(0.);
    <<Estimate LayeredBxDF value f using random sampling>>
    return f / nSamples;
}
```

#parec[
  There is some preliminary computation that is independent of each sample taken to estimate the BSDF's value. A few fragments take care of it before the random estimation begins.
][
  There is some preliminary computation that is independent of each sample taken to estimate the BSDF's value. A few fragments take care of it before the random estimation begins.
]


```cpp
<<Estimate LayeredBxDF value f using random sampling>>=
<<Set wo and wi for layered BSDF evaluation>>
<<Determine entrance interface for layered BSDF>>
<<Determine exit interface and exit  for layered BSDF>>
<<Account for reflection at the entrance interface>>
<<Declare RNG for layered BSDF evaluation>>
for (int s = 0; s < nSamples; ++s) {
    <<Sample random walk through layers to estimate BSDF value>>
}
```

#parec[
  With this BSDF, layered materials can be specified as either one- or two-sided via the `twoSided` template parameter. If a material is one-sided, then the shape's surface normal is used to determine which interface an incident ray enters. If it is in the same hemisphere as the surface normal, it enters the top interface and otherwise it enters the bottom. This configuration is especially useful when both interfaces are transmissive and have different BSDFs.
][
  使用此 BSDF 时，分层材料可以通过 `twoSided` 模板参数指定为单面或双面。如果材料是单面的，则使用形状的表面法线来确定入射光线进入的界面。如果光线位于表面法线的同一半球内，则进入顶部界面；否则进入底部界面。这种配置在两个界面都为透射型并且具有不同 BSDF 时尤其有用。
]

#parec[
  For two-sided materials, the ray always enters the top interface. This option is useful when the bottom interface is opaque as is the case with the `CoatedDiffuseBxDF`, for example. In this case, it is usually desirable for scattering from both layers to be included, no matter which side the ray intersects.
][
  对于双面材料，光线始终进入顶部界面。此选项在底部界面是不透明时非常有用，例如 `CoatedDiffuseBxDF` 的情况。在这种情况下，无论光线从哪一侧入射，通常都希望包括来自两层的散射。
]

#parec[
  One way to handle these options in the `f()` method would be to negate both directions and make a recursive call to `f()` if $omega_o$ points below the surface and the material is two-sided. However, that solution is not a good one for the GPU, where it is likely to introduce thread divergence. (This topic is discussed in more detail in Section 15.1.1.) Therefore, both directions are negated at the start of the method and no recursive call is made in this case, which gives an equivalent result.
][
  在 `f()` 方法中，可以通过取反两个方向并递归调用 `f()` 来处理这些选项，如果 $omega_o$ 指向表面下方且材料是双面的。然而，这种解决方案不适合 GPU，因为它可能引入线程分歧。（有关此主题的详细讨论，请参见第 15.1.1 节。）因此，在方法开始时直接对两个方向取反，而不进行递归调用，这可以得到等效的结果。
]

```cpp
// Set wo and wi for layered BSDF evaluation
if (twoSided && wo.z < 0) {
    wo = -wo;
    wi = -wi;
}
```


#parec[
  The next step is to determine which of the two `BxDF`s is the one that is encountered first by the incident ray. The sign of $omega_o$ 's $z$ component in the reflection coordinate system gives the answer.
][
  下一步是确定哪个 `BxDF` 是入射光线首先遇到的。可以通过反射坐标系中 $omega_o$ 的 $z$ 分量的符号来判断。
]

```cpp
// Determine entrance interface for layered BSDF
TopOrBottomBxDF<TopBxDF, BottomBxDF> enterInterface;
bool enteredTop = twoSided || wo.z > 0;
if (enteredTop) enterInterface = &top;
else            enterInterface = &bottom;
```


#parec[
  It is also necessary to determine which interface $omega_i$ exits. This is determined both by which interface $omega_o$ enters and by whether $omega_o$ and $omega_i$ are in the same hemisphere. We end up with an unusual case where the #strong[exclusive-or] operator comes in handy. Along the way, the method also stores which interface is the one that $omega_i$ does not exit from. As random paths are sampled through the layers and medium, the implementation will always choose reflection from this interface and not transmission, as choosing the latter would end the path without being able to scatter out in the $omega_i$ direction. The same logic then covers determining the $z$ depth at which the ray path will exit the surface.
][
  还需要确定 $omega_i$ 从哪个界面出射。这取决于 $omega_o$ 进入的界面以及 $omega_o$ 和 $omega_i$ 是否位于同一半球。这里会用到 #strong[异或] 操作符。与此同时，方法还存储了 $omega_i$ 没有从中出射的界面。在通过层和介质采样随机路径时，程序总是选择从这个界面反射，而不是透射，因为选择后者会导致路径终止，无法沿 $omega_i$ 方向散射出去。相同的逻辑还用于确定光线路径退出表面的 $z$ 深度。
]
```cpp
// Determine exit interface and exit z for layered BSDF
TopOrBottomBxDF<TopBxDF, BottomBxDF> exitInterface, nonExitInterface;
if (SameHemisphere(wo, wi) ^ enteredTop) {
    exitInterface = &bottom;
    nonExitInterface = &top;
} else {
    exitInterface = &top;
    nonExitInterface = &bottom;
}
Float exitZ = (SameHemisphere(wo, wi) ^ enteredTop) ? 0 : thickness;
```


#parec[
  If both directions are on the same side of the surface, then part of the BSDF's value is given by reflection at the entrance interface. This can be evaluated directly by calling the interface's BSDF's `f()` method. The resulting value must be scaled by the total number of samples taken to estimate the BSDF in this method, since the final returned value is divided by `nSamples`.
][
  如果两个方向位于表面的同一侧，则 BSDF 的部分值由入射界面的反射决定。可以直接通过调用该界面的 BSDF 的 `f()` 方法进行评估。由于最终返回的值将被 `nSamples` 除，因此结果值必须乘以在此方法中估计 BSDF 时使用的总样本数。
]
```cpp
// Account for reflection at the entrance interface
if (SameHemisphere(wo, wi))
    f = nSamples * enterInterface.f(wo, wi, mode);
```

#parec[
  `pbrt`'s `BxDF` interface does not include any uniform sample values as parameters to the `f()` method; there is no need for them for any of the other `BxDF`s in the system. In any case, an unbounded number of uniform random numbers are required for sampling operations when evaluating layered BSDFs. Therefore, `f()` initializes an `RNG` and defines a convenience lambda function that returns uniform random sample values. This does mean that the benefits of sampling with well-distributed point sets are not present here; an exercise at the end of the chapter returns to this issue.
][
  `pbrt` 的 `BxDF` 接口不包括作为参数传递给 `f()` 方法的均匀样本值；对于系统中的其他 `BxDF`，这些值不是必要的。然而，在评估分层 BSDF 时，采样操作需要无限数量的均匀随机数。因此，`f()` 方法初始化了一个 `RNG`，并定义了一个方便的 lambda 函数来返回均匀随机样本值。这意味着这里不能利用良分布点集采样的优势；本章结尾的练习将回到这个问题。
]

#parec[
  The `RNG` is seeded carefully: it is important that calls to `f()` with different directions have different seeds so that there is no risk of errors due to correlation between the `RNG`s used for multiple samples in a pixel or across nearby pixels. However, we would also like the samples to be deterministic so that any call to `f()` with the same two directions always has the same set of random samples. This sort of reproducibility is important for debugging so that errors appear consistently across multiple runs of the program. Hashing the two provided directions along with the system-wide seed addresses all of these concerns.
][
  `RNG` 的种子被小心地设置：重要的是，对于不同方向的 `f()` 调用，种子必须不同，以避免因像素内或相邻像素的多次采样中 `RNG` 的相关性而引发错误。然而，我们也希望样本是确定性的，以便对相同方向的任何 `f()` 调用始终生成相同的一组随机样本。这种可重复性对于调试非常重要，因为错误会在多次运行程序时一致出现。将两个方向和系统全局种子一起进行哈希可以满足这些需求。
]

```cpp
// Declare RNG for layered BSDF evaluation
RNG rng(Hash(GetOptions().seed, wo), Hash(wi));
auto r = [&rng]() { return std::min<Float>(rng.Uniform<Float>(), OneMinusEpsilon); };
```

#parec[
  In order to find the radiance leaving the interface in the direction $omega_o$, we need to integrate the product of the cosine-weighted BTDF at the interface with the incident radiance from inside the medium.
][
  为了找到在界面沿 $omega_o$ 方向出射的辐射，需要将界面处余弦加权的 BTDF 与来自介质内部的入射辐射相乘并进行积分。
]



$
  integral_(H_t^2) f_t (omega_o, omega') L_i (z, omega')|cos theta'|thin d omega',
$<layered-top-btdf-integrate>

#parec[
  where $H_t^2$ is the hemisphere inside the medium (@fig:layered-layer-scatter-contrib). The implementation uses the standard Monte Carlo estimator, taking a sample $omega prime$ from the BTDF and then proceeding to estimate $L_i$.
][
  其中 $H_t^2$ 是介质内部的半球（见@fig:layered-layer-scatter-contrib）。实现中使用了标准的蒙特卡罗估计器，从 BTDF 中取样 $omega prime$，然后继续估计 $L_i$。
]

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f19.svg"),
  caption: [
    #ez_caption[
      The effect of light that scatters between the interface layers is found by integrating the product of the cosine-weighted BTDF at the entrance interface with the incident radiance from the medium, @eqt:layered-top-btdf-integrate.

    ][
      界面层之间散射光的效果通过积分入口界面处余弦加权的 BTDF 与介质中入射辐射的乘积来获得，参见@eqt:layered-top-btdf-integrate。
    ]
  ],
)<layered-layer-scatter-contrib>

```cpp
<<Sample random walk through layers to estimate BSDF value>>=
<<Sample transmission direction through entrance interface>>
<<Sample BSDF for virtual light from wi>>
<<Declare state for random walk through BSDF layers>>
for (int depth = 0; depth < maxDepth; ++depth) {
    <<Sample next event for layered BSDF evaluation random walk>>
}
```

#parec[
  Sampling the direction $omega prime$ is a case where it is useful to be able to specify to `Sample_f()` that only transmission should be sampled.
][
  采样方向 $omega prime$ 是一个需要向 `Sample_f()` 指定只采样透射的情况。
]

```cpp
Float uc = r();
pstd::optional<BSDFSample> wos =
    enterInterface.Sample_f(wo, uc, Point2f(r(), r()), mode,
                            BxDFReflTransFlags::Transmission);
if (!wos || !wos->f || wos->pdf == 0 || wos->wi.z == 0)
    continue;
```

#parec[
  The task now is to compute a Monte Carlo estimate of the 1D equation of transfer, @eqt:eot-1d. Before discussing how it is sampled, however, we will first consider some details related to the lighting calculation with the virtual light source. At each vertex of the path, we will want to compute the incident illumination due to the light. As shown in @fig:layered-virtual-light-contribution, there are three factors in the light's contribution: the value of the phase function or interface BSDF for a direction $omega$, the transmittance between the vertex and the exit interface, and the value of the interface's BTDF for the direction from $- omega$ to $omega_i$.
][
  接下来的任务是计算 1D 传输方程（@eqt:eot-1d）的蒙特卡洛估计。然而，在讨论其采样方法之前，我们首先考虑与虚拟光源照明计算相关的一些细节。在路径的每个顶点，我们需要计算来自光源的入射辐射。如@fig:layered-virtual-light-contribution 所示，光源贡献中包含三个因素：某一方向 $omega$ 上相函数或界面 BSDF 的值、顶点与出口界面之间的透射率，以及界面 BTDF 在从 $- omega$ 到 $omega_i$ 方向上的值。
]
#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f20.svg"),
  caption: [
    #ez_caption[
      Illumination Contribution from the Virtual Light
      Source. At a path vertex, the contribution of the virtual light source
      is given by the product of the path throughput weight $beta$ that
      accounts for previous scattering along the path, the scattering at the
      vertex, the transmittance $T_r$ to the exit interface, and the effect of
      the BTDF at the interface.
    ][
      虚拟光源的照明贡献。在路径顶点，虚拟光源的贡献由路径吞吐权重 $beta$（用于计算路径上的前向散射）、顶点处的散射、到出口界面的透射率 $T_r$
      以及界面 BTDF 的影响的乘积表示。
    ]
  ],
)<layered-virtual-light-contribution>

#parec[
  Each of these three factors could be used for sampling; as before, one may sometimes be much more effective than the others. The `LayeredBxDF` implementation uses two of the three—sampling the phase function or BRDF at the current path vertex (as appropriate) and sampling the BTDF at the exit interface—and then weights the results using MIS.
][
  这三个因素中的每一个都可以用于采样；如前所述，其中一个有时可能比其他两个更有效。`LayeredBxDF` 的实现使用了其中的两个——在当前路径顶点处采样相函数或 BRDF（根据需要）以及采样出口界面的 BTDF，并使用多重重要性采样（MIS）对结果进行加权。
]


#parec[
  There is no reason to repeatedly sample the exit interface BTDF at each path vertex since the direction $omega_i$ is fixed. Therefore, the following fragment samples it once and holds on to the resulting `BSDFSample`. Note that the negation of the `TransportMode` parameter value `mode` is taken for the call to `Sample_f()`, which is important to reflect the fact that this sampling operation is following the reverse path with respect to sampling in terms of $omega_o$. This is an important detail so that the underlying #link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BXDF`] can correctly account for non-symmetric scattering; see @non-symmetric-scattering-and-refraction.
][
  没有理由在路径的每个顶点都重复采样出口界面的 BTDF，因为方向 $omega_i$ 是固定的。因此，以下代码片段只对其采样一次，并保留结果 `BSDFSample`。注意，对 `Sample_f()` 的调用中，`TransportMode` 参数值 `mode` 取了相反的值，这一点很重要，因为此采样操作沿着与 $omega_o$ 采样方向相反的路径进行。这是一个重要的细节，确保底层 #link("../Reflection_Models/BSDF_Representation.html#BxDF")[BXDF] 可以正确处理非对称散射；参见@non-symmetric-scattering-and-refraction。
]

```cpp
uc = r();
pstd::optional<BSDFSample> wis =
    exitInterface.Sample_f(wi, uc, Point2f(r(), r()), !mode,
                           BxDFReflTransFlags::Transmission);
if (!wis || !wis->f || wis->pdf == 0 || wis->wi.z == 0)
    continue;
```

#parec[
  Moving forward to the random walk estimation of the equation of transfer, the implementation maintains the current path throughput weight `beta`, the depth `z` of the last scattering event, and the ray direction `w`.
][
  在继续随机行走估计传输方程时，实现会维护当前路径的吞吐权重 `beta`、上一次散射事件的深度 `z`，以及光线方向 `w`。
]

```cpp
SampledSpectrum beta = wos->f * AbsCosTheta(wos->wi) / wos->pdf;
Float z = enteredTop ? thickness : 0;
Vector3f w = wos->wi;
HGPhaseFunction phase(g);
```

#parec[
  We can now move to the body of the inner loop over scattering events along the path. After a Russian roulette test, a distance is sampled along the ray to determine the next path vertex either within the medium or at whichever interface the ray intersects.
][
  现在可以进入内循环的主体，处理路径上的散射事件。在进行俄罗斯轮盘赌测试后，沿光线采样一个距离，以确定下一个路径顶点的位置，可能在介质内部，也可能在光线与某个界面相交的位置。
]

```cpp
<<Sample next event for layered BSDF evaluation random walk>>=
<<Possibly terminate layered BSDF random walk with Russian roulette>>
<<Account for media between layers and possibly scatter>>
<<Account for scattering at appropriate interface>>
```

#parec[
  It is worth considering terminating the path as the path throughput weight becomes low, though here the termination probability is set less aggressively than it was in the #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`] and #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`];. This reflects the fact that each bounce here is relatively inexpensive, so doing more work to improve the accuracy of the estimate is worthwhile.
][
  当路径的通量权重变得较低时，值得考虑终止路径。不过，在这里的终止概率设置比 #link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[`PathIntegrator`] 和 #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`] 中不那么激进。这是因为每次反弹的计算代价相对较低，因此为了提高估计的精度而进行更多的计算是值得的。
]


```cpp
if (depth > 3 && beta.MaxComponentValue() < 0.25f) {
    Float q = std::max<Float>(0, 1 - beta.MaxComponentValue());
    if (r() < q) break;
    beta /= 1 - q;
}
```

#parec[
  The common case of no scattering in the medium is handled separately since it is much simpler than the case where volumetric scattering must be considered.
][
  在介质中没有散射的常见情况下，可以单独处理，因为这种情况比需要考虑体积散射的情况要简单得多。
]
```cpp
<<Account for media between layers and possibly scatter>>=
if (!albedo) {
    <<Advance to next layer boundary and update beta for transmittance>>
} else {
    <<Sample medium scattering for layered BSDF evaluation>>
}
```

#parec[
  If there is no medium scattering, then only the first term of @eqt:eot-1d needs to be evaluated. The path vertices alternate between the two interfaces. Here `beta` is multiplied by the transmittance for the ray segment through the medium; the $L_o$ factor is found by estimating @eqt:boundary-scattering-1d, which will be handled shortly.
][
  如果没有介质散射，则只需要计算@eqt:eot-1d 的第一项。路径顶点在两个界面之间交替。这里通过介质的射线段的透射率会乘以 `beta`，而 $L_o$ 因子通过估计@eqt:boundary-scattering-1d 获得，这将在后续处理。
]


```cpp
z = (z == thickness) ? 0 : thickness;
beta *= Tr(thickness, w);
```

#parec[
  If the medium is scattering, we only sample one of the two terms of the 1D equation of transfer, choosing between taking a sample inside the medium and scattering at the other interface. A change in depth $Delta z$ can be perfectly sampled from the 1D beam transmittance, @eqt:beamtrans-1d-homogeneous. Since $sigma_t = 1$, the PDF is
][
  如果介质是散射的，我们只采样一维传输方程中的两项之一，在介质内部采样或在另一界面散射之间选择。深度变化 $Delta z$ 可以从一维光束透射率的@eqt:beamtrans-1d-homogeneous 中完美采样。由于 $sigma_t = 1$，其概率密度函数 (PDF) 为
]


$ p (Delta z) = 1 / lr(|omega_z|) e^(- frac(Delta z, lr(|omega_z|))) . $


#parec[
  Given a depth $z prime$ found by adding or subtracting $Delta z$ from the current depth $z$ according to the ray's direction, medium scattering is chosen if $z prime$ is inside the medium and surface scattering is chosen otherwise. (The sampling scheme is thus similar to how the #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`] chooses between medium and surface scattering.) In the case of scattering from an interface, the `Clamp()` call effectively forces $z$ to lie on whichever of the two interfaces the ray intersects next.
][
  给定一个深度 $z prime$，通过根据光线的方向从当前深度 $z$ 加上或减去 $Delta z$ 得到，如果 $z prime$ 在介质内，则选择介质散射，否则选择表面散射。（采样方案类似于 #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[`VolPathIntegrator`] 在介质和表面散射之间的选择。）在界面发生散射的情况下，`Clamp()` 调用有效地将 $z$ 限制在光线接下来会交叉的两个界面之一上。
]

```cpp
<<Sample medium scattering for layered BSDF evaluation>>=
Float sigma_t = 1;
Float dz = SampleExponential(r(), sigma_t / std::abs(w.z));
Float zp = w.z > 0 ? (z + dz) : (z - dz);
if (0 < zp && zp < thickness) {
    <<Handle scattering event in layered BSDF medium>>
    <<Account for scattering through exitInterface using wis>>
    Float wt = 1;
    if (!IsSpecular(exitInterface.Flags()))
        wt = PowerHeuristic(1, wis->pdf, 1, phase.PDF(-w, -wis->wi));
    f += beta * albedo * phase.p(-w, -wis->wi) * wt * Tr(zp - exitZ, wis->wi) *
         wis->f / wis->pdf;
    <<Sample phase function and update layered path state>>
    Point2f u{r(), r()};
    pstd::optional<PhaseFunctionSample> ps = phase.Sample_p(-w, u);
    if (!ps || ps->pdf == 0 || ps->wi.z == 0)
        continue;
    beta *= albedo * ps->p / ps->pdf;
    w = ps->wi;
    z = zp;
    <<Possibly account for scattering through exitInterface>>
    if (((z < exitZ && w.z > 0) || (z > exitZ && w.z < 0)) &&
        !IsSpecular(exitInterface.Flags())) {
        <<Account for scattering through exitInterface>>
        SampledSpectrum fExit = exitInterface.f(-w, wi, mode);
        if (fExit) {
            Float exitPDF =
                exitInterface.PDF(-w, wi, mode, BxDFReflTransFlags::Transmission);
            Float wt = PowerHeuristic(1, ps->pdf, 1, exitPDF);
            f += beta * Tr(zp - exitZ, ps->wi) * fExit * wt;
        }
    }
    continue;
}
z = Clamp(zp, 0, thickness);
```



#parec[
  If $z prime$ is inside the medium, we have the estimator
][
  如果 $z prime$ 在介质内，我们有估计量
]


$ frac(T_r (z arrow.r z prime) (L_s^((z prime , - omega))), p (Delta z) lr(|omega_z|)) . $


#parec[
  Both the exponential factors and $lr(|omega_z|)$ factors in $T_r$ and $p (Delta z)$ cancel, and we are left with simply the source function $L_s (z prime , - omega)$, which should be scaled by the path throughput. The following fragment adds an estimate of its value to the sum in f.
][
  在 $T_r$ 和 $p (Delta z)$ 中，指数因子和 $lr(|omega_z|)$ 因子相互抵消，我们仅剩下源函数 $L_s (z prime , - omega)$，它应根据路径吞吐量进行缩放。以下片段将其值的估计添加到 f 中的总和。
]

```cpp
<<Handle scattering event in layered BSDF medium>>=
<<Account for scattering through exitInterface using wis>>
<<Sample phase function and update layered path state>>
<<Possibly account for scattering through exitInterface>>
```


#parec[
  For a scattering event inside the medium, it is necessary to add the contribution of the virtual light source to the path radiance estimate and to sample a new direction to continue the path. For the MIS lighting sample based on sampling the interface's BTDF, the outgoing direction from the path vertex is predetermined by the BTDF sample `wis`; all the factors of the path contribution are easily evaluated and the MIS weight is found using the PDF for the other sampling technique, sampling the phase function.
][
  对于介质内的散射事件，需要将虚拟光源的贡献添加到路径辐射估计中，并采样一个新的方向以继续路径。对于基于界面 BTDF 采样的 MIS 光照样本，路径顶点的出射方向由 BTDF 样本 `wis` 预先确定；路径贡献的所有因素可以轻松计算，并使用相位函数采样技术的 PDF 找到 MIS 权重。
]
```cpp
<<Account for scattering through exitInterface using wis>>=
Float wt = 1;
if (!IsSpecular(exitInterface.Flags()))
    wt = PowerHeuristic(1, wis->pdf, 1, phase.PDF(-w, -wis->wi));
f += beta * albedo * phase.p(-w, -wis->wi) * wt * Tr(zp - exitZ, wis->wi) *
     wis->f / wis->pdf;
```


#parec[
  The second sampling strategy for the virtual light is based on sampling the phase function and then connecting to the virtual light source through the exit interface. Doing so shares some common work with sampling a new direction for the path, so the implementation takes the opportunity to update the path state after sampling the phase function here.
][
  虚拟光的第二种采样策略是基于相位函数采样，然后通过出口界面连接到虚拟光源。这种方法与为路径采样新方向共享一些共同工作，因此在此处采样相位函数后可以顺便更新路径状态。
]
```cpp
<<Sample phase function and update layered path state>>=
Point2f u{r(), r()};
pstd::optional<PhaseFunctionSample> ps = phase.Sample_p(-w, u);
if (!ps || ps->pdf == 0 || ps->wi.z == 0)
    continue;
beta *= albedo * ps->p / ps->pdf;
w = ps->wi;
z = zp;
```

#parec[
  There is no reason to try connecting through the exit interface if the current ray direction is pointing away from it or if its BSDF is perfect specular.
][
  如果当前射线方向指向远离出口界面，或者其 BSDF 是完全镜面反射，则没有理由尝试通过出口界面连接。
]
```cpp
<<Possibly account for scattering through exitInterface>>=
if (((z < exitZ && w.z > 0) || (z > exitZ && w.z < 0)) &&
     !IsSpecular(exitInterface.Flags())) {
    <<Account for scattering through exitInterface>>
}
```


#parec[
  If there is transmission through the interface, then because `beta` has already been updated to include the effect of scattering at $z'$ only the transmittance to the exit, MIS weight, and BTDF value need to be evaluated to compute the light's contribution. One important detail in the following code is the ordering of arguments to the call to `f()` in the first line: due to the non-reciprocity of BTDFs, swapping these would lead to incorrect results.#footnote[As was learned, painfully, during the&#10;implementation of this `BxDF`]
][
  如果通过界面发生了透射，因为 <tt>beta</tt> 已经更新以包含在 $z'$ 的散射效应，那么只需评估到出口的透射率、MIS 权重和 BTDF 值即可计算光的贡献。在以下代码中，一个重要的细节是调用 <tt>f()</tt> 的参数顺序：由于 BTDF 的非互易性，交换这些参数会导致错误结果。#footnote[这是在实现此 `BxDF` 过程中痛苦地得知的。]
]

```cpp
<<Account for scattering through exitInterface>>=
SampledSpectrum fExit = exitInterface.f(-w, wi, mode);
if (fExit) {
    Float exitPDF =
        exitInterface.PDF(-w, wi, mode, BxDFReflTransFlags::Transmission);
    Float wt = PowerHeuristic(1, ps->pdf, 1, exitPDF);
    f += beta * Tr(zp - exitZ, ps->wi) * fExit * wt;
}
```


#parec[
  If no medium scattering event was sampled, the next path vertex is at an interface. In this case, the transmittance along the ray can be ignored: as before, the probability of evaluating the first term of @eqt:eot-1d has probability equal to $T_r$ and thus the two $T_r$ factors cancel, leaving us only needing to evaluate scattering at the boundary, @eqt:boundary-scattering-1d. The details differ depending on which interface the ray intersected.
][
  如果没有采样到介质散射事件，路径的下一个顶点将位于界面。在这种情况下，可以忽略沿射线的透射率：与之前一样，评估@eqt:eot-1d 的第一项的概率等于 $T_r$，因此两个 $T_r$ 因子相互抵消，只需要评估边界上的散射即可，参见 @eqt:boundary-scattering-1d。具体细节取决于射线与哪个界面相交。
]


```cpp
<<Account for scattering at appropriate interface>>=
if (z == exitZ) {
    <<Account for reflection at exitInterface>>
} else {
    <<Account for scattering at nonExitInterface>>
}
```

#parec[
  If the ray intersected the exit interface, then it is only necessary to update the path throughput: no connection is made to the virtual light source since transmission through the exit interface to the light is accounted for by the lighting computation at the previous vertex. This fragment samples only the reflection component of the path here, since a ray that was transmitted outside the medium would end the path.
][
  如果射线与出口界面相交，那么只需更新路径通量：无需与虚拟光源连接，因为通过出口界面到光源的透射已经在前一个顶点的光照计算中考虑到了。此代码段仅对路径的反射分量进行采样，因为透射到介质外部的射线将结束路径。
]

```cpp
<<Account for reflection at exitInterface>>=
Float uc = r();
pstd::optional<BSDFSample> bs = exitInterface.Sample_f(
    -w, uc, Point2f(r(), r()), mode, BxDFReflTransFlags::Reflection);
if (!bs || !bs->f || bs->pdf == 0 || bs->wi.z == 0)
    break;
beta *= bs->f * AbsCosTheta(bs->wi) / bs->pdf;
w = bs->wi;
```


#parec[
  The `<<Account for scattering at nonExitInterface>>` fragment handles scattering from the other interface. It applies MIS to compute the contribution of the virtual light and samples a new direction with a form very similar to the case of scattering within the medium, just with the phase function replaced by the BRDF for evaluation and sampling. Therefore, we have not included its implementation here.
][
  代码段 `<<Account for scattering at nonExitInterface>>` 负责处理来自另一个界面的散射。它应用 MIS 方法计算虚拟光源的贡献，并以一种与介质内散射非常相似的形式采样新的方向，只是将相位函数替换为 BRDF 进行评估和采样。因此，我们在此未包括其具体实现。
]


==== BSDF Sampling
<bsdf-sampling>
#parec[
  The implementation of `Sample_f()` is generally similar to `f()`, so we will not include its implementation here, either. Its task is actually simpler: given the initial direction $omega_(upright(o))$ at one of the layer's boundaries, it follows a random walk of scattering events through the layers and the medium, maintaining both the path throughput and the product of PDFs for each of the sampling decisions. When the random walk exits the medium, the outgoing direction is the sampled direction that is returned in the `BSDFSample`.
][
  `Sample_f()`的实现通常与`f()`类似，因此我们在这里也不包括其实现。它的任务实际上更简单：给定层边界处的初始方向 $omega_(upright(o))$，它在层和介质中进行随机散射事件的游走，同时保持路径通量和每个采样决策的PDF的乘积。当随机游走退出介质时，出射方向就是在`BSDFSample`中返回的采样方向。
]

#parec[
  With this approach, it can be shown that the ratio of the path throughput to the PDF is equal to the ratio of the actual value of the BSDF and its PDF for the sampled direction (see the "Further Reading" section for details). Therefore, when the weighted path throughput is multiplied by the ratio of `BSDFSample::f` and `BSDFSample::pdf`, the correct weighting term is applied. (Review, for example, the fragment `<<Update path state variables after surface scattering>>` in the `PathIntegrator`.)
][
  通过这种方法，可以证明路径通量与PDF的比率等于BSDF的实际值与其采样方向的PDF的比率（详情请参见“进一步阅读”部分）。因此，当加权路径通量乘以`BSDFSample::f`和`BSDFSample::pdf`的比率时，应用了正确的加权项。（例如，查看`PathIntegrator`中的片段 `<<Update path state variables after surface scattering>>`。）
]

#parec[
  However, an implication of this is that the PDF value returned by `Sample_f()` cannot be used to compute the multiple importance sampling weight if the sampled ray hits an emissive surface; in that case, an independent estimate of the PDF must be computed via a call to the `PDF()` method. The `BSDFSample::pdfIsProportional` member variable flags this case and is set by `Sample_f()` here.
][
  然而，这意味着如果采样的光线击中发光表面，`Sample_f()`返回的PDF值不能用于计算多重重要性采样权重；在这种情况下，必须通过调用`PDF()`方法来计算PDF的独立估计。`BSDFSample::pdfIsProportional`成员变量标记了这种情况，并由`Sample_f()`在此处设置。
]

==== PDF Evaluation
<pdf-evaluation>


#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f21.svg"),
  caption: [
    #ez_caption[
      The First Two Terms of the Infinite Sum that Give a
      Layered BSDF’s PDF. (a) The PDF of the reflection component of the interface’s BSDF accounts
      for light that scatters without entering the layers. (b) The second
      term is given by a double integral over directions. A direction $omega '$ pointing into the medium is sampled; it gives the
      second direction for the interface’s BTDF PDF $p_t^(+)$ and its
      negation gives one of the two directions for $p_r^(-)$. A second
      direction $omega ''$ is used for $p_r^(-)$ as well as for a second
      evaluation of $p_t^(+)$.
    ][
      给出分层BSDF的PDF的无限和的前两项。 (a) 界面BSDF的反射组件的PDF考虑了不进入层的光散射。(b) 第二项由方向上的双重积分给出。采样一个指向介质的方向$omega '$；它给出了界面BTDF PDF $p_t^(+)$的第二个方向，其负值给出了$p_r^(-)$的两个方向之一。第二个方向$omega ''$用 于$p_r^(-)$以 及$p_t^(+)$的第二次评估。
    ]
  ],
)<layered-pdf-sampling>

#parec[
  The PDF $p (omega_o , omega_i)$ that corresponds to a `LayeredBxDF`'s BSDF can be expressed as an infinite sum. For example, consider the case of having a bottom layer that reflects light with BRDF $f_r^(-)$ and a top layer that both reflects light with BRDF $f_r^(+)$ and transmits it with BTDF $f_t^(+)$, with an overall BSDF $f^(+) = f_r^(+) + f_t^(+)$. If those BSDFs have associated PDFs $p$ and if scattering in the medium is neglected, then the overall PDF is
][
  对应于`LayeredBxDF`的BSDF的PDF $p (omega_o , omega_i)$ 可以表示为一个无限和。例如，考虑底层反射光的BRDF $f_r^(-)$ 和顶层既反射光的BRDF $f_r^(+)$ 又透射光的BTDF $f_t^(+)$，整体BSDF $f^(+) = f_r^(+) + f_t^(+)$ 的情况。如果这些BSDF有相关的PDF $p$，并且忽略介质中的散射，那么整体PDF为
]

$
  p(omega_o, omega_i) = p_r^+ (omega_o, omega_i) + integral_(SS^2) integral_(SS^2) p_t^+ (omega_o, omega') p_r^- (-omega', omega^('')) p_t^+ (-omega^(''), omega_i) thin d omega' thin d omega^('') + dots .
$<pdf-estimate-sum>

#parec[
  The first term gives the contribution for the PDF at the top interface and the second is the PDF for directions $omega_i$ that were sampled via transmission through the top interface, scattering at the bottom, and then transmission back out in direction $omega_i$. Note the coupling of directions between the PDF factors in the integrand: the negation of the initial transmitted direction $omega'$ gives the first direction for evaluation of the base PDF $p_r^(-)$, and so forth (see @fig:layered-pdf-sampling. Subsequent terms of this sum account for light that is reflected back downward at the top interface instead of exiting the layers, and expressions of a similar form can be found for the PDF if the base layer is also transmissive.
][
  第一项给出了顶界面的PDF贡献，第二项是通过顶界面透射、在底部散射然后再透射回方向 $omega_i$ 的方向的PDF。注意在积分中PDF因子之间的方向耦合 ： 初 始 透 射 方 向 $omega'$ 的负值给出了基PDF $p_r^(-)$ 的第一个方向，等等（见@fig:layered-pdf-sampling ）。这个和的后续项考虑了在顶界面反射回下方而不是退出层的光，并且如果基层也是透射的，可以找到类似形式的PDF表达式。
]

#parec[
  It is possible to compute a stochastic estimate of the PDF by applying Monte Carlo to the integrals and by terminating the infinite sum using Russian roulette. For example, for the integral in @eqt:pdf-estimate-sum, we have the estimator
][
  可以通过对积分应用蒙特卡罗方法并使用俄罗斯轮盘赌终止无限和来计算PDF的随机估计。例如，对于@eqt:pdf-estimate-sum 中的积分，我们有估计器
]

$
  frac(p_t^(+) (omega_o , omega prime) p_r^(-) (- omega prime , omega prime.double) p_t^(+) (- omega prime.double , omega_i), p_1 (omega prime) p_2 (omega prime.double)) ,
$<pdf-triple-estimate>



#parec[
  where $omega prime$ is sampled from some distribution $p_1$ and $omega prime.double$ from a distribution $p_2$. There is great freedom in choosing the distributions $p_1$ and $p_2$. However, as with algorithms like path tracing, care must be taken if some of the PDFs are Dirac delta distributions. For example, if the bottom layer is perfect specular, then $p_r^(-) (- omega prime , omega prime.double)$ will always be zero unless $omega prime.double$ was sampled according to its PDF.
][
  其中 $omega prime$ 从某个分布 $p_1$ 中采样， $omega prime.double$ 从分布 $p_2$ 中采样。在选择分布 $p_1$ 和 $p_2$ 时有很大的自由度。然而，与路径追踪等算法一样，如果某些概率密度函数是狄拉克δ分布，则必须小心。例如，如果底层是完美镜面反射，则 $p_r^(-) (- omega prime , omega prime.double)$ 将始终为零，除非 $omega prime.double$ 是根据其概率密度函数采样的。
]

#parec[
  Consider what happens if $omega prime$ is sampled using $f_t^(+)$ 's sampling method, conditioned on $omega_o$, and if $omega prime.double$ is sampled using $f_t^(+)$ 's sampling method, conditioned on $omega_i$ : the first and last probabilities in the numerator cancel with the probabilities in the denominator, and we are left simply with $p_r^(-) (- omega prime , omega prime.double)$ as the estimate; the effect of $f_t^(+)$ in the PDF is fully encapsulated by the distribution of directions used to evaluate $p_r^(-)$ .
][
  考虑如果 $omega prime$ 使用 $f_t^(+)$ 的采样方法采样，以 $omega_o$ 为条件，并且 $omega prime.double$ 使用 $f_t^(+)$ 的采样方法采样，以 $omega_i$ 为条件：分子中的第一个和最后一个概率项与分母中的概率项相抵消，我们仅剩下 $p_r^(-) (- omega prime , omega prime.double)$ 作为估计；在概率密度函数中 $f_t^(+)$ 的影响完全由用于评估 $p_r^(-)$ 的方向分布所体现。
]

#parec[
  A stochastic estimate of the PDF can be computed by following a random walk in a manner similar to the `f()` method, just with phase function and BSDF evaluation replaced with evaluations of the corresponding PDFs. However, because the `PDF()` method is only called to compute PDF values that are used for computing MIS weights, the implementation here will return an approximate PDF; doing so does not invalidate the MIS estimator. #footnote[It is admittedly unfriendly to provide an
implementation of a method with a name that very clearly indicates that it
should return a valid PDF and yet does not in fact do that, and to justify
this with the fact that doing so is fine due to the current usage of
the function.  This represents a potentially gnarly bug lying in wait for
someone in the future who might not expect this when extending the system.  For
that, our apologies in advance.]
][
  可以通过类似于 `f()` 方法的方式进行随机游走来计算概率密度函数的随机估计，只是将相位函数和 BSDF 评估替换为相应概率密度函数的评估。然而，由于 `PDF()` 方法仅用于计算用于计算 MIS 权重的概率密度值，因此此处的实现将返回一个近似的概率密度函数；这样做不会使 MIS 估计失效。#footnote[不得不承认，提供一个方法的实现，而该方法的名字显然表明它应该返回一个有效的 PDF，但实际上却没有这样做，并以当前函数的使用方式作为理由来为此辩护，这确实不够友好。这种设计可能会成为潜在的棘手漏洞，未来某些人可能在扩展系统时，未料到这一点而中招。对此，我们提前表示歉意。]
]

```cpp
<<LayeredBxDF Public Methods>>+=
Float PDF(Vector3f wo, Vector3f wi, TransportMode mode,
          BxDFReflTransFlags sampleFlags = BxDFReflTransFlags::All) const {
    <<Set wo and wi for layered BSDF evaluation>>
    <<Declare RNG for layered PDF evaluation>>
    <<Update pdfSum for reflection at the entrance layer>>
    for (int s = 0; s < nSamples; ++s) {
        <<Evaluate layered BSDF PDF sample>>
    }
    <<Return mixture of PDF estimate and constant PDF>>
}
```

#parec[
  It is important that the `RNG` for the `PDF()` method is seeded differently than it is for the `f()` method, since it will often be called with the same pair of directions as are passed to `f()`, and we would like to be certain that there is no correlation between the results returned by the two of them.
][
  对于 `PDF()` 方法的 `RNG`，其种子必须与 `f()` 方法的不同，因为它通常会与传递给 `f()` 的相同方向对一起调用，我们需要确保它们返回的结果之间没有相关性。
]

```cpp
<<Declare RNG for layered PDF evaluation>>=
RNG rng(Hash(GetOptions().seed, wi), Hash(wo));
auto r = [&rng]() { return std::min<Float>(rng.Uniform<Float>(),
                                           OneMinusEpsilon); };
```



#parec[
  If both directions are on the same side of the surface, then part of the full PDF is given by the PDF for reflection at the interface (this was the first term of @eqt:pdf-estimate-sum). This component can be evaluated non-stochastically, assuming that the underlying `PDF()` methods are not themselves stochastic.
][
  如果两个方向在表面的同一侧，则完整概率密度的一部分由界面反射的概率密度给出（这是@eqt:pdf-estimate-sum 的第一项）。假设底层的 `PDF()` 方法本身不是随机的，则可以非随机地评估此组件。
]

```cpp
<<Update pdfSum for reflection at the entrance layer>>=
bool enteredTop = twoSided || wo.z > 0;
Float pdfSum = 0;
if (SameHemisphere(wo, wi)) {
    auto reflFlag = BxDFReflTransFlags::Reflection;
    pdfSum += enteredTop ?
              nSamples * top.PDF(wo, wi, mode, reflFlag) :
              nSamples * bottom.PDF(wo, wi, mode, reflFlag);
}
```

#parec[
  The more times light has been scattered, the more isotropic its directional distribution tends to become. We can take advantage of this fact by evaluating only the first term of the stochastic PDF estimate and modeling the remaining terms with a uniform distribution. We further neglect the effect of scattering in the medium, again under the assumption that if it is significant, a uniform distribution will be a suitable approximation.
][
  光散射的次数越多，其方向分布越趋向于各向同性。我们可以利用这一事实，仅评估随机概率密度估计的第一项，并用均匀分布对剩余项建模。我们进一步忽略介质中散射的影响，同样假设如果它是显著的，均匀分布将是一个合适的近似。
]

```cpp
<<Evaluate layered BSDF PDF sample>>=
if (SameHemisphere(wo, wi)) {
    <<Evaluate TRT term for PDF estimate>>
} else {
    <<Evaluate TT term for PDF estimate>>
}
```


#parec[
  If both directions are on the same side of the interface, then the remaining PDF integral is the double integral of the product of three PDFs that we considered earlier. We use the shorthand "TRT" for this case, corresponding to transmission, then reflection, then transmission.
][
  如果两个方向在界面的同一侧，则剩余的概率密度积分是我们之前考虑的三个概率密度乘积的双重积分。我们用简写“TRT”表示这种情况，即透射-反射-透射。
]


```cpp
<<Evaluate TRT term for PDF estimate>>=
TopOrBottomBxDF<TopBxDF, BottomBxDF> rInterface, tInterface;
if (enteredTop) {
    rInterface = &bottom;  tInterface = &top;
} else {
    rInterface = &top;     tInterface = &bottom;
}
<<Sample tInterface to get direction into the layers>>
<<Update pdfSum accounting for TRT scattering events>>
```


#parec[
  We will apply two sampling strategies. The first is sampling both directions via `tInterface`, once conditioned on $omega_o$ and once on $omega_i$ —effectively a bidirectional approach. The second is sampling one direction via `tInterface` conditioned on $omega_o$ and the other via `rInterface` conditioned on the first sampled direction. These are then combined using multiple importance sampling. After canceling factors and introducing an MIS weight $w (omega prime.double)$, @eqt:pdf-triple-estimate simplifies to
][
  我们将应用两种采样策略。第一种是通过 `tInterface` 采样两个方向，一次以 $omega_o$ 为条件，一次以 $omega_i$ 为条件——实际上是一种双向方法。第二种是通过 `tInterface` 以 $omega_o$ 为条件采样一个方向，通过 `rInterface` 以第一个采样方向为条件采样另一个方向。然后使用多重重要性采样将它们组合。在消去因子并引入 MIS 权重 $w (omega prime.double)$ 后，@eqt:pdf-triple-estimate 简化为
]


$
  w ( omega prime.double ) = frac(p_r^(-) (- omega prime , omega prime.double) p_t^(+) (- omega prime.double , omega_i), p (omega prime.double)) ,
$<pdf-triple-canceled-one>

#parec[
  which is the estimator for both strategies.
][
  which is the estimator for both strategies.
]

#parec[
  Both sampling methods will use the wos sample while only one uses `wis`.
][
  Both sampling methods will use the wos sample while only one uses `wis`.
]


```cpp

<<Sample tInterface to get direction into the layers>>=
auto trans = BxDFReflTransFlags::Transmission;
pstd::optional<BSDFSample> wos, wis;
wos = tInterface.Sample_f(wo, r(), {r(), r()},  mode, trans);
wis = tInterface.Sample_f(wi, r(), {r(), r()}, !mode, trans);
```

#parec[
  If `tInterface` is perfect specular, then there is no need to try sampling $p_r^(-)$ or to apply MIS. The $p_r^(-)$ PDF is all that remains from @eqt:pdf-triple-canceled-one.
][
  如果 `tInterface` 是完美镜面反射的，那么不需要尝试采样 $p_r^(-)$ 或应用 MIS（多重重要性采样）。此时，@eqt:pdf-triple-canceled-one 中剩下的只剩 $p_r^(-)$ 的概率密度函数 (PDF)。
]


```cpp
if (wos && wos->f && wos->pdf > 0 && wis && wis->f && wis->pdf > 0) {
    if (!IsNonSpecular(tInterface.Flags()))
        pdfSum += rInterface.PDF(-wos->wi, -wis->wi, mode);
    else {
        <<Use multiple importance sampling to estimate PDF product>>
        pstd::optional<BSDFSample> rs =
               rInterface.Sample_f(-wos->wi, r(), {r(), r()}, mode);
           if (rs && rs->f && rs->pdf > 0) {
               if (!IsNonSpecular(rInterface.Flags()))
                   pdfSum += tInterface.PDF(-rs->wi, wi, mode);
               else {
                   <<Compute MIS-weighted estimate of Equation (14.38) >>
                      Float rPDF = rInterface.PDF(-wos->wi, -wis->wi, mode);
                      Float wt = PowerHeuristic(1, wis->pdf, 1, rPDF);
                      pdfSum += wt * rPDF;
                      Float tPDF = tInterface.PDF(-rs->wi, wi, mode);
                      wt = PowerHeuristic(1, rs->pdf, 1, tPDF);
                      pdfSum += wt * tPDF;
               }
           }
    }
}
```

#parec[
  Otherwise, we sample from $p_r^(-)$ as well. If that sample is from a perfect specular component, then again there is no need to use MIS and the estimator is just $p_t^(+) (- omega prime.double , omega_i)$.
][
  否则，我们也会对 $p_r^(-)$ 进行采样。如果该采样来自完美镜面分量，那么同样不需要使用 MIS，此时估算值只是 $p_t^(+) (- omega prime.double , omega_i)$。
]


```cpp
pstd::optional<BSDFSample> rs =
    rInterface.Sample_f(-wos->wi, r(), {r(), r()}, mode);
if (rs && rs->f && rs->pdf > 0) {
    if (!IsNonSpecular(rInterface.Flags()))
        pdfSum += tInterface.PDF(-rs->wi, wi, mode);
    else {
        <<Compute MIS-weighted estimate of Equation (14.38)>>
           Float rPDF = rInterface.PDF(-wos->wi, -wis->wi, mode);
           Float wt = PowerHeuristic(1, wis->pdf, 1, rPDF);
           pdfSum += wt * rPDF;
           Float tPDF = tInterface.PDF(-rs->wi, wi, mode);
           wt = PowerHeuristic(1, rs->pdf, 1, tPDF);
           pdfSum += wt * tPDF;
    }
}
```


#parec[
  If neither interface has a specular sample, then both are combined. For the first sampling technique, the second $p_t^(+)$ factor cancels out as well and the estimator is $p_r^(-) (- omega prime , - omega prime.double)$ times the MIS weight.
][
  如果两个界面都没有镜面采样，则两者的贡献会结合起来。对于第一种采样技术，第二个 $p_t^(+)$ 因子也会抵消，因此估算器为 $p_r^(-) (- omega prime , - omega prime.double)$ 乘以 MIS 权重。
]
```cpp
Float rPDF = rInterface.PDF(-wos->wi, -wis->wi, mode);
Float wt = PowerHeuristic(1, wis->pdf, 1, rPDF);
pdfSum += wt * rPDF;
```

#parec[
  Similarly, for the second sampling technique, we are left with a $p_t^(+)$ PDF to evaluate and then weight using MIS.
][
  类似地，对于第二种采样技术，只需评估 $p_t^(+)$ 的 PDF，并使用 MIS 对其加权。
]
```cpp
Float tPDF = tInterface.PDF(-rs->wi, wi, mode);
wt = PowerHeuristic(1, rs->pdf, 1, tPDF);
pdfSum += wt * tPDF;
```

#parec[
  The `<<Evaluate TT term for PDF estimate>>` fragment is of a similar form, so it is not included here.
][
  对于 PDF 估算的 `<<Evaluate TT term for PDF estimate>>` 片段具有类似的形式，这里不再赘述。
]

#parec[
  The final returned PDF value has the PDF for uniform spherical sampling, $frac(1, 4 pi)$, mixed with the estimate to account for higher-order terms.
][
  最终返回的 PDF 值将均匀球面采样的 PDF（ $frac(1, 4 pi)$ ）与估算值混合，以考虑高阶项。
]
```cpp
return Lerp(0.9f, 1 / (4 * Pi), pdfSum / nSamples);
```
=== Coated Diffuse and Coated Conductor Materials
<coated-diffuse-and-coated-conductor-materials>

#parec[
  Adding a dielectric interface on top of both diffuse materials and conductors is often useful to model surface reflection. For example, plastic can be modeled by putting such an interface above a diffuse material, and coated metals can be modeled by adding such an interface as well. In both cases, introducing a scattering layer can model effects like tarnish or weathering. @fig:layered-bxdf-dragon-renderings shows the dragon model with a few variations of these.
][
  在漫反射材质和导体上添加一个介电界面，通常可以用于模拟表面反射。例如，可以通过在漫反射材质上添加这样的界面来模拟塑料，也可以通过添加这样的界面来模拟涂层金属。在这两种情况下，引入一个散射层可以模拟例如锈蚀或风化等效果。@fig:layered-bxdf-dragon-renderings 展示了使用这些方法实现的龙模型的几种变化。
]

#parec[
  `pbrt` provides both the `CoatedDiffuseBxDF` and the `CoatedConductorBxDF` for such uses. There is almost nothing to their implementations other than a public inheritance from `LayeredBxDF` with the appropriate types for the two interfaces.
][
  `pbrt` 提供了 `CoatedDiffuseBxDF` 和 `CoatedConductorBxDF` 用于这些用途。它们的实现几乎只是公开继承自 `LayeredBxDF`，并为两个界面提供了适当的类型。
]
```cpp
class CoatedDiffuseBxDF :
    public LayeredBxDF<DielectricBxDF, DiffuseBxDF, true> {
  public:
    <<CoatedDiffuseBxDF Public Methods>>
       using LayeredBxDF::LayeredBxDF;
       PBRT_CPU_GPU
       static constexpr const char *Name() { return "CoatedDiffuseBxDF"; }
};
```

```cpp
class CoatedConductorBxDF :
    public LayeredBxDF<DielectricBxDF, ConductorBxDF, true> {
  public:
    <<CoatedConductorBxDF Public Methods>>
       PBRT_CPU_GPU
       static constexpr const char *Name() { return "CoatedConductorBxDF"; }
       using LayeredBxDF::LayeredBxDF;
};
```

#figure(
  image("../pbr-book-website/4ed/Light_Transport_II_Volume_Rendering/pha14f22.svg"),
  caption: [
    #ez_caption[
      A Variety of Effects That Can Be Achieved Using Layered
      Materials. (a) Dragon model with a blue diffuse BRDF. (b) The effect of
      adding a smooth dielectric interface on top of the diffuse BRDF. In
      addition to the specular highlights, note how the color has become more
      saturated, which is due to multiple scattering from paths that reflected
      back into the medium from the exit interface. (c) The effect of
      roughening the interface. The surface appears less shiny, but the blue
      remains more saturated.
    ][
      使用分层材质可以实现多种效果。(a) 带有蓝色漫反射 BRDF 的龙模型。(b) 在漫反射 BRDF 上添加光滑介电界面的效果。除了镜面高光外，还可以注意到颜色变得更加饱和，这是由于从出口界面反射回介质的路径产生的多次散射。(c) 界面粗糙化的效果。表面看起来不那么光亮，但蓝色仍然保持较高的饱和度。
    ]
  ],
)<layered-bxdf-dragon-renderings>


#parec[
  There are also corresponding `Material` implementations, `CoatedDiffuseMaterial` and `CoatedConductorMaterial`. Their implementations follow the familiar pattern of evaluating textures and then initializing the corresponding `BxDF`, and they are therefore not included here.
][
  还有对应的 `Material` 实现，如 `CoatedDiffuseMaterial` 和 `CoatedConductorMaterial`。它们的实现遵循熟悉的模式：先评估纹理，然后初始化对应的 `BxDF`，因此这里不再赘述。
]

