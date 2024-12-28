#import "../template.typ": parec, ez_caption

== Phase Functions
<phase-functions>


#parec[
  Just as there is a wide variety of BSDF models that describe scattering from surfaces, many phase functions have also been developed. These range from parameterized models (which can be used to fit a function with a small number of parameters to measured data) to analytic models that are based on deriving the scattered radiance distribution that results from particles with known shape and material (e.g., spherical water droplets).
][
  正如存在多种用于描述表面散射的 BSDF 模型，同样也开发了许多相函数。这些模型从参数化模型（可以用少量参数拟合测量数据的函数）到基于已知形状和材料的粒子推导出的散射辐射分布的解析模型（例如，球形水滴）。
]

#parec[
  In most naturally occurring media, the phase function is a 1D function of the angle $theta$ between the two directions $omega_o$ and $omega_i$ ; these phase functions are often written as $p (cos theta)$. Media with this type of phase function are called #emph[isotropic] or #emph[symmetric] because their response to incident illumination is (locally) invariant under rotations. In addition to being normalized, an important property of naturally occurring phase functions is that they are #emph[reciprocal];: the two directions can be interchanged and the phase function's value remains unchanged. Note that symmetric phase functions are trivially reciprocal because $cos (- theta) = cos (theta)$.
][
  在大多数自然存在的介质中，相函数是角度 $theta$ 的一维函数，角度 $theta$ 是两个方向 $omega_o$ 和 $omega_i$ 之间的夹角；这些相函数通常写作 $p (cos theta)$。具有这种类型相函数的介质称为#emph[各向同性];或#emph[对称];，因为它们对入射光的响应（局部）在旋转下是不变的。除了归一化之外，自然存在的相函数的一个重要属性是它们是#emph[互易的];：两个方向可以互换，相函数的值保持不变。注意，对称相函数是显然互易的，因为 $cos (- theta) = cos (theta)$。
]

#parec[
  In #emph[anisotropic] media that consist of particles arranged in a coherent structure, the phase function can be a 4D function of the two directions, which satisfies a more involved kind of reciprocity relation. Examples of this are crystals or media made of coherently oriented fibers; the "Further Reading" discusses these types of media further.
][
  在由有序结构排列的粒子组成的#emph[各向异性];介质中，相函数可以是两个方向的四维函数，满足一种更复杂的互易关系。晶体或由有序纤维构成的介质就是这种情况的例子；"延伸阅读"部分对这些类型的介质进行了更深入的讨论。
]

#parec[
  In a slightly confusing overloading of terminology, phase functions themselves can be isotropic or anisotropic as well. Thus, we might have an anisotropic phase function in an isotropic medium. An isotropic phase function describes equal scattering in all directions and is thus independent of either of the two directions. Because phase functions are normalized, there is only one such function:
][
  在术语的稍微混淆的重载中，相函数本身也可以是各向同性或各向异性的。因此，我们可能在各向同性介质中有一个各向异性相函数。各向同性相函数描述了所有方向上的均匀散射，因此与两个方向中的任何一个无关。因为相函数是归一化的，所以只有一个这样的函数：
]

$ p (omega_o , omega_i) = frac(1, 4 pi) . $

#parec[
  The `PhaseFunction` class defines the `PhaseFunction` interface. Only a single phase function is currently provided in `pbrt`, but we have used the #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] machinery to make it easy to add others. Its implementation is in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/medium.h")[`base/medium.h`];.
][
  `PhaseFunction` 类定义了 `PhaseFunction` 接口。目前在 `pbrt` 中仅提供了一个相函数，但我们使用了 #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 机制，以便于添加其他相函数。其实现位于文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/medium.h")[`base/medium.h`];。
]

```cpp
<<PhaseFunction Definition>>=
class PhaseFunction : public TaggedPointer<HGPhaseFunction> {
  public:
    <<PhaseFunction Interface>>
};
```

#parec[
  The `p()` method returns the value of the phase function for the given pair of directions. As with `BSDF`s, `pbrt` uses the convention that the two directions both point away from the point where scattering occurs; this is a different convention from what is usually used in the scattering literature (Figure 11.13).
][
  `p()` 方法返回给定方向对的相函数值。与 `BSDF` 类似，`pbrt` 使用的约定是两个方向都指向散射发生的点之外；这与散射文献中通常使用的约定不同（图 11.13）。
]

```cpp
Float p(Vector3f wo, Vector3f wi) const;
```


#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f13.svg"),
  caption: [
    #ez_caption[
      Figure 11.13: Phase functions in `pbrt` are implemented with the
      convention that both the incident direction and the outgoing
      direction point away from the point where scattering happens. This
      is the same convention that is used for BSDFs in `pbrt` but is
      different from the convention in the scattering literature, where
      the incident direction generally points toward the scattering point.
      The angle between the two directions is denoted by $theta$.
    ][
      在 `pbrt`
      中，相函数的实现采用了入射方向和出射方向都指向散射发生点之外的约定。这与
      `pbrt` 中 BSDF
      的约定相同，但与散射文献中的约定不同，在文献中入射方向通常指向散射点。两个方向之间的角度用
      $theta$ 表示。
    ]
  ],
)<phase-costheta>

#parec[
  It is also useful to be able to draw samples from the distribution described by a phase function. `PhaseFunction` implementations therefore must provide a `Sample_p()` method, which samples an incident direction $omega_i$ given the outgoing direction $omega_o$ and a sample value in the range $lr([0 , 1))^2$.
][
  能够从相函数描述的分布中抽取样本也是有用的。因此，`PhaseFunction` 实现必须提供一个 `Sample_p()` 方法，该方法在给定出射方向 $omega_o$ 和范围 $lr([0 , 1))^2$ 内的样本值的情况下，采样入射方向 $omega_i$。
]

```cpp
pstd::optional<PhaseFunctionSample> Sample_p(Vector3f wo, Point2f u) const;
```


#parec[
  Phase function samples are returned in a structure that stores the phase function's value $p$, the sampled direction $w i$, and the PDF $p d f$.
][
  相函数样本以一个结构返回，该结构存储相函数的值 $p$ 、采样方向 $w i$ 和概率密度函数 (PDF) $p d f$。
]

```cpp
struct PhaseFunctionSample {
    Float p;
    Vector3f wi;
    Float pdf;
};
```

#parec[
  An accompanying `PDF()` method returns the value of the phase function sampling PDF for the provided directions.
][
  伴随的 `PDF()` 方法返回给定方向的相函数采样概率密度函数 (PDF) 的值。
]

```cpp
Float PDF(Vector3f wo, Vector3f wi) const;
```


=== The Henyey–Greenstein Phase Function
<the-henyeygreenstein-phase-function>


#parec[
  A widely used phase function was developed by Henyey and Greenstein (1941). This phase function was specifically designed to be easy to fit to measured scattering data. A single parameter $g$ (called the #emph[asymmetry parameter];) controls the distribution of scattered light: #footnote[Note
that the sign of the 2 g cos θ term in the denominator is the
opposite of the sign used in the scattering literature. This difference is
due to our use of the same direction convention for BSDFs and phase
functions.]
][
  Henyey 和 Greenstein（1941）开发了一种广泛使用的相函数。该相函数专门设计为易于拟合测量的散射数据。单个参数 $g$ （称为#emph[不对称参数];）控制散射光的分布：#footnote[Note
that the sign of the 2 g cos θ term in the denominator is the
opposite of the sign used in the scattering literature. This difference is
due to our use of the same direction convention for BSDFs and phase
functions.]
]

$ p_(H G) (cos theta) = frac(1, 4 pi) frac(1 - g^2, (1 + g^2 + 2 g cos theta)^(3 \/ 2)) . $

#parec[
  The `HenyeyGreenstein()` function implements this computation.
][
  `HenyeyGreenstein()` 函数实现了这一计算。
]

```cpp
Float HenyeyGreenstein(Float cosTheta, Float g) {
    Float denom = 1 + Sqr(g) + 2 * g * cosTheta;
    return Inv4Pi * (1 - Sqr(g)) / (denom * SafeSqrt(denom));
}
```


#parec[
  The asymmetry parameter $g$ in the Henyey–Greenstein model has a precise meaning. It is the integral of the product of the given phase function and the cosine of the angle between $omega prime$ and $omega$ and is referred to as the #emph[mean cosine];. Given an arbitrary phase function $p$, the value of $g$ can be computed as: #footnote[    Once more, there is a sign difference compared to the radiative transfer literature: the first argument to p is negated due to our use of the same direction convention for BSDFs and phase functions.  ]
][
  Henyey–Greenstein 模型中的不对称参数 $g$ 有一个精确的意义。它是给定相函数与 $omega prime$ 和 $omega$ 之间角度的余弦的乘积的积分，被称为#emph[平均余弦];。给定任意相函数 $p$，可以计算 $g$ 的值为：#footnote[
    Once
more, there is a sign difference compared to the radiative transfer literature:
the first argument to p is negated due to our use of the same direction
convention for BSDFs and phase functions.
]
]

$
  g = integral_(SS^2) p(-omega, omega')(omega dot.op omega') thin d omega' = 2 pi integral_0^pi p( -cos theta ) cos theta sin theta thin d theta .
$<scattering-anisotropy>


#parec[
  Thus, an isotropic phase function gives $g = 0$, as expected.
][
  因此，各向同性相函数如预期般给出 $g = 0$。
]

#parec[
  Any number of phase functions can satisfy this equation; the g value alone is not enough to uniquely describe a scattering distribution. Nevertheless, the convenience of being able to easily convert a complex scattering distribution into a simple parameterized model is often more important than this potential loss in accuracy.
][
  任何数量的相函数都可以满足这个方程；仅凭 $g$ 值不足以唯一描述散射分布。然而，能够轻松地将复杂的散射分布转换为简单的参数化模型的便利性通常比这种潜在的精度损失更为重要。
]

#parec[
  More complex phase functions that are not described well with a single asymmetry parameter can often be modeled by a weighted sum of phase functions like Henyey–Greenstein, each with different parameter values:
][
  更复杂的相函数不能用单一的不对称参数很好地描述，通常可以通过像 Henyey–Greenstein 这样的相函数的加权和来建模，每个都有不同的参数值：
]


$
  p(omega, omega') = sum_(i = 1)^n w_i p_i (omega arrow.r omega'),
$
#parec[
  where the weights $w_i$ sum to one to maintain normalization. This generalization is not provided in `pbrt` but would be easy to add.
][
  其中权重 $w_i$ 的和为一，以保持归一化。这种泛化在 `pbrt` 中没有提供；但很容易添加。
]

#parec[
  @fig:hg-plots shows plots of the Henyey–Greenstein phase function with varying asymmetry parameters. The value of g for this model must be in the range $(- 1 , 1)$. Negative values of g correspond to back-scattering, where light is mostly scattered back toward the incident direction, and positive values correspond to forward-scattering. The greater the magnitude of g, the more scattering occurs close to the or -directions (for back-scattering and forward-scattering, respectively). See @fig:hg-renderings to compare the visual effect of forward- and back-scattering.
][
  @fig:hg-plots 显示了具有不同不对称参数的 Henyey–Greenstein 相函数的图。对于这个模型， $g$ 的值必须在 $(- 1 , 1)$ 范围内。 负的 $g$ 值对应于后向散射，即光主要向入射方向散射，而正值对应于前向散射。 $g$ 的绝对值越大，散射越接近于 $thin omega$ 或 $- omega$ 方向（分别用于后向散射和前向散射）。参见@fig:hg-renderings 以比较前向和后向散射的视觉效果。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f14.svg"),
  caption: [
    #ez_caption[
      Plots of the Henyey–Greenstein Phase Function for Asymmetry $g$ Parameters -- $0.25$ and $0.7$. Negative $g$ values describe phase functions that primarily scatter light back in the incident direction, and positive $g$ values describe phase functions that primarily scatter light forward in the direction it was already traveling (here, along the $+x$ axis).
    ][
      Plots of the Henyey–Greenstein Phase Function for Asymmetry $g$ Parameters -- $0.25$ and $0.7$. Negative $g$ values describe phase functions that primarily scatter light back in the incident direction, and positive $g$ values describe phase functions that primarily scatter light forward in the direction it was already traveling (here, along the $+x$ axis).

    ]
  ],
)<hg-plots>


#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f15.svg"),
  caption: [
    #ez_caption[
      Ganesha model filled with participating media rendered with (left) strong backward scattering ($g=-0.9$) and (right) strong forward scattering ($g=0.9$). Because most of the light comes from a light source behind the objects, forward scattering leads to more light reaching the camera in this case.
    ][
      Ganesha model filled with participating media rendered with (left) strong backward scattering ($g=-0.9$) and (right) strong forward scattering ($g=0.9$). Because most of the light comes from a light source behind the objects, forward scattering leads to more light reaching the camera in this case.
    ]
  ],
)<hg-renderings>


#parec[
  `HGPhaseFunction` class implements the Henyey–Greenstein model in the context of the `PhaseFunction` interface.
][
  `HGPhaseFunction` 类在 `PhaseFunction` 接口的上下文中实现了 Henyey–Greenstein 模型。
]

```cpp
<<HGPhaseFunction Definition>>=
class HGPhaseFunction {
  public:
    <<HGPhaseFunction Public Methods>>
  private:
    <<HGPhaseFunction Private Members>>
};
```

#parec[
  Its only parameter is $g$, which is provided to the constructor and stored in a member variable.
][
  它的唯一参数是 $g$，它被提供给构造函数并存储在一个成员变量中。
]

```cpp
<<HGPhaseFunction Public Methods>>=
HGPhaseFunction(Float g) : g(g) {}

<<HGPhaseFunction Private Members>>=
Float g;
```

#parec[
  Evaluating the phase function is a simple matter of calling the `HenyeyGreenstein()` function.
][
  评估相函数只需调用 `HenyeyGreenstein()` 函数。
]

```cpp
<<HGPhaseFunction Public Methods>>+=
Float p(Vector3f wo, Vector3f wi) const {
    return HenyeyGreenstein(Dot(wo, wi), g);
}
```

#parec[
  It is possible to sample directly from the Henyey–Greenstein phase function's distribution. This operation is provided via a stand-alone utility function. Because the sampling algorithm is exact and because the Henyey–Greenstein phase function is normalized, the PDF is equal to the phase function's value for the sampled direction.
][
  可以直接从 Henyey–Greenstein 相函数的分布中采样。此操作通过一个独立的实用函数提供。 因为采样算法是精确的，并且 Henyey–Greenstein 相函数是归一化的，PDF 等于相函数在采样方向的值。
]
```cpp
<<Sampling Function Definitions>>+=
Vector3f SampleHenyeyGreenstein(Vector3f wo, Float g,
                                Point2f u, Float *pdf) {
    <<Compute  for Henyey–Greenstein sample>>
    <<Compute direction wi for Henyey–Greenstein sample>>
    if (pdf) *pdf = HenyeyGreenstein(cosTheta, g);
    return wi;
}
```

#parec[
  The PDF for the Henyey–Greenstein phase function is separable into $theta$ and $phi.alt$ components, with $p (phi.alt) = frac(1, 2 pi)$ as usual. The main task is to sample $cos theta$. With `pbrt`'s convention for the orientation of direction vectors, the distribution for $theta$ is
][
  Henyey–Greenstein 相函数的 PDF 可以分离成 $theta$ 和 $phi.alt$ 组件， $p (phi.alt) = frac(1, 2 pi)$ 如常。主要任务是采样 $cos theta$。根据 `pbrt` 对方向向量的方向约定， $theta$ 的分布为
]

$
  cos theta = - frac(1, 2 g)(1 + g^2 -(frac(1 - g^2, 1 + g - 2 g xi))^2),
$

#parec[
  if $g eq.not 0$ ; otherwise, $cos theta = 1 - 2 xi$ gives a uniform sampling over the sphere of directions.
][
  如果 $g eq.not 0$ ；否则， $cos theta = 1 - 2 xi$ 给出方向球面的均匀采样。
]

```cpp
<<Compute  for Henyey–Greenstein sample>>=
Float cosTheta;
if (std::abs(g) < 1e-3f)
    cosTheta = 1 - 2 * u[0];
else
    cosTheta = -1 / (2 * g) *
               (1 + Sqr(g) - Sqr((1 - Sqr(g)) / (1 + g - 2 * g * u[0])));
```


#parec[
  The $(cos theta , phi.alt)$ values specify a direction with respect to a coordinate system where `wo` is along the $+ z$ axis. Therefore, it is necessary to transform the sampled vector to `wo`'s coordinate system before returning it.
][
  $(cos theta , phi.alt)$ 值指定了相对于一个坐标系的方向，其中 `wo` 沿 $+ z$ 轴。因此，有必要在返回之前将采样向量转换为 `wo` 的坐标系。
]

```cpp
<<Compute direction wi for Henyey–Greenstein sample>>=
Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
Float phi = 2 * Pi * u[1];
Frame wFrame = Frame::FromZ(wo);
Vector3f wi = wFrame.FromLocal(SphericalDirection(sinTheta, cosTheta, phi));
```

#parec[
  The `HGPhaseFunction` sampling method is now easily implemented.
][
  `HGPhaseFunction` 采样方法现在可以轻松实现。
]

```cpp
<<HGPhaseFunction Public Methods>>+=
pstd::optional<PhaseFunctionSample> Sample_p(Vector3f wo, Point2f u) const {
    Float pdf;
    Vector3f wi = SampleHenyeyGreenstein(wo, g, u, &pdf);
    return PhaseFunctionSample{pdf, wi, pdf};
}
```

#parec[
  Because sampling is exact and phase functions are normalized, its `PDF()` method just evaluates the phase function for the given directions.
][
  因为采样是精确的并且相函数是归一化的，其 `PDF()` 方法只需评估给定方向的相函数。
]


```cpp
<<HGPhaseFunction Public Methods>>+=
Float PDF(Vector3f wo, Vector3f wi) const { return p(wo, wi); }
```
