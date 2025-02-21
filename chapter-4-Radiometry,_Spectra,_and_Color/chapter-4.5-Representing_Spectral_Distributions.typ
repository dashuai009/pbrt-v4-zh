#import "../template.typ": parec, ez_caption


== Representing Spectral Distributions
<representing-spectral-distributions>

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f16.svg"),
  caption: [
    #ez_caption[ Spectral Distribution of Reflection from Lemon Skin. ][Spectral Distribution of Reflection from Lemon Skin.
    ]
  ],
)
#parec[
  Spectral distributions in the real world can be complex; we have already seen a variety of complex emission spectra and @luminance-and-photometry shows a graph of the spectral distribution of the reflectance of lemon skin. In order to render images of scenes that include a variety of complex spectra, a renderer must have efficient and accurate representations of spectral distributions. This section will introduce `pbrt`'s abstractions for representing and performing computation with them; the corresponding code can be found in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.h")[`util/spectrum.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.cpp")[`util/spectrum.cpp`];.
][
  现实世界中的光谱分布可能很复杂；我们已经看到了各种复杂的发射光谱，@luminance-and-photometry 显示了柠檬皮反射光谱分布图。为了渲染包含各种复杂光谱的场景图像，渲染器必须具有高效且准确的光谱分布表示。本节将介绍 `pbrt` 用于表示和计算光谱分布的抽象；相应的代码可以在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.h")[`util/spectrum.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.cpp")[`util/spectrum.cpp`] 中找到。
]

#parec[
  We will start by defining constants that give the range of visible wavelengths. Both here and for the remainder of the spectral code in `pbrt`, wavelengths are specified in nanometers, which are of a magnitude that gives easily human-readable values for the visible wavelengths.
][
  我们将首先定义可见波长范围的常量。在这里以及 `pbrt` 的其余光谱代码中，波长以纳米为单位指定，这个量级使得可见波长的值易于人们阅读。
]

```cpp
// <<Spectrum Constants>>=
constexpr Float Lambda_min = 360, Lambda_max = 830;
```

=== Spectrum Interface
<spectrum-interface>
#parec[
  we will find a variety of spectral representations will be useful in `pbrt`, ranging from spectral sample values tabularized by wavelength to functional descriptions such as the blackbody function. This brings us to our first interface class, #link("<Spectrum>")[`Spectrum`];. A #link("<Spectrum>")[`Spectrum`] corresponds to a pointer to a class that implements one such spectral representation.
][
  在 `pbrt` 中，我们会发现各种光谱表示是有用的，从按波长制成表格的光谱样本值到功能描述如黑体函数。这引出了我们的第一个接口类，#link("<Spectrum>")[`Spectrum`];。一个 #link("<Spectrum>")[`Spectrum`] 对应于一个指向实现这种光谱表示的类的指针。
]

#parec[
  `Spectrum` inherits from #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];, which handles the details of runtime polymorphism. #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] requires that all the types of `Spectrum` implementations be provided as template parameters, which allows it to associate a unique integer identifier with each type.
][
  `Spectrum` 继承自 #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];，它处理运行时多态的细节。#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 要求所有 `Spectrum` 实现的类型作为模板参数提供，这使得它可以将唯一的整数标识符与每种类型关联。
]

```cpp
<<Spectrum Definition>>=
class Spectrum
    : public TaggedPointer<ConstantSpectrum, DenselySampledSpectrum,
                           PiecewiseLinearSpectrum, RGBAlbedoSpectrum,
                           RGBUnboundedSpectrum, RGBIlluminantSpectrum,
                           BlackbodySpectrum> {
  public:
    using TaggedPointer::TaggedPointer;
    std::string ToString() const;
    Float operator()(Float lambda) const;
    Float MaxValue() const;
    SampledSpectrum Sample(const SampledWavelengths &lambda) const;
};
```

#parec[
  As with other classes that are based on #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];, `Spectrum` defines an interface that must be implemented by all the spectral representations. Typical practice in C++ would be for such an interface to be specified by pure virtual methods in `Spectrum` and for `Spectrum` implementations to inherit from `Spectrum` and implement those methods. With the `TaggedPointer` approach, the interface is specified implicitly: for each method in the interface, there is a method in `Spectrum` that dispatches calls to the appropriate type's implementation.We will discuss the details of how this works for a single method here but will omit them for other Spectrum methods and for other interface classes since they all follow the same boilerplate.
][
  与其他基于 #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 的类一样，`Spectrum` 定义了一个必须由所有光谱表示实现的接口。在 C++ 中的典型做法是通过 `Spectrum` 中的纯虚方法指定这样的接口，并让 `Spectrum` 的实现继承自 `Spectrum` 并实现这些方法。使用 `TaggedPointer` 方法，接口是隐式指定的：对于接口中的每个方法，`Spectrum` 中都有一个方法将调用分派给适当类型的实现。我们将在这里讨论如何为单个方法工作的细节，但对于其他Spectrum方法和其他接口类，我们将省略它们，因为它们都遵循相同的样板。
]

#parec[
  The most important method that #link("<Spectrum>")[`Spectrum`] defines is `operator()`, which takes a single wavelength $lambda$ and returns the value of the spectral distribution for that wavelength.
][
  #link("<Spectrum>")[`Spectrum`] 定义的最重要的方法是 `operator()`，它接受一个单一波长 $lambda$ 并返回该波长的光谱分布值。
]

#parec[
  The corresponding method implementation is brief, though dense. A call to #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer::Dispatch")[`TaggedPointer::Dispatch()`] begins the process of dispatching the method call. The #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] class stores an integer tag along with the object's pointer that encodes its type; in turn, `Dispatch()` is able to determine the specific type of the pointer at runtime. It then calls the callback function provided to it with a pointer to the object, cast to be a pointer to its actual type.
][
  相应的方法实现简短但密集。调用 #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer::Dispatch")[`TaggedPointer::Dispatch()`] 开始了方法调用的分派过程。#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 类存储了一个整数标签以及对象的指针，该标签编码了其类型；反过来，`Dispatch()` 能够在运行时确定指针的具体类型。然后，它调用提供给它的回调函数，并将对象的指针作为其实际类型的指针传递给回调函数。
]

#parec[
  The lambda function that is called here, `op`, takes a pointer with the `auto` type specifier for its parameter. In C++17, such a lambda function acts as a templated function; a call to it with a concrete type acts as an instantiation of a lambda that takes that type. Thus, the call `(*ptr)(lambda)` in the lambda body ends up as a direct call to the appropriate method.
][
  这里调用的 lambda 函数 `op` 使用 `auto` 类型说明符作为其参数。在 C++17 中，这样的 lambda 函数充当模板函数；对其进行具体类型的调用相当于实例化一个接受该类型的 lambda。因此，lambda 主体中的调用 `(*ptr)(lambda)` 最终成为对适当方法的直接调用。
]

```cpp
<<Spectrum Inline Method Definitions>>=
inline Float Spectrum::operator()(Float lambda) const {
    auto op = [&](auto ptr) { return (*ptr)(lambda); };
    return Dispatch(op);
}
```


#parec[
  `Spectrum` implementations must also provide a `MaxValue()` method that returns a bound on the maximum value of the spectral distribution over its wavelength range. This method's main use in `pbrt` is for computing bounds on the power emitted by light sources so that lights can be sampled according to their expected contribution to illumination in the scene.
][
  `Spectrum` 实现还必须提供一个 `MaxValue()` 方法，该方法返回其波长范围内光谱分布的最大值的界限。此方法在 `pbrt` 中的主要用途是计算光源发射功率的界限，以便根据光源在场景中对照明的预期贡献对其进行采样。
]

```cpp
<<Spectrum Interface>>+=
Float MaxValue() const;
```

=== General Spectral Distributions
<general-spectral-distributions>
#parec[
  With the `Spectrum` interface specified, we will start by defining a few `Spectrum` class implementations that explicitly tabularize values of the spectral distribution function. #link("<ConstantSpectrum>")[`ConstantSpectrum`] is the simplest: it represents a constant spectral distribution over all wavelengths. The most common use of the #link("<ConstantSpectrum>")[`ConstantSpectrum`] class in `pbrt` is to define a zero-valued spectral distribution in cases where a particular form of scattering is not present.
][
  在指定了 `Spectrum` 接口后，我们将首先定义一些 `Spectrum` 类的实现，这些实现明确地列出光谱分布函数的值。#link("<ConstantSpectrum>")[`ConstantSpectrum`] 是最简单的：它表示在所有波长上的恒定光谱分布。在 `pbrt` 中，#link("<ConstantSpectrum>")[`ConstantSpectrum`] 类最常见的用途是当某种形式的散射不存在时，定义一个零值的光谱分布。
]

#parec[
  The `ConstantSpectrum` implementation is straightforward and we omit its trivial `MaxValue()` method here. Note that it does not inherit from #link("<Spectrum>")[`Spectrum`];. This is another difference from using traditional C++ abstract base classes with virtual functions—as far as the C++ type system is concerned, there is no explicit connection between #link("<ConstantSpectrum>")[`ConstantSpectrum`] and `Spectrum`.
][
  `ConstantSpectrum` 的实现很简单，这里省略了其简单的 `MaxValue()` 方法。注意它没有继承自 #link("<Spectrum>")[`Spectrum`];。这与传统的 C++ 抽象基类和虚函数的使用不同——就 C++ 类型系统而言，#link("<ConstantSpectrum>")[`ConstantSpectrum`] 和 `Spectrum` 之间没有明确的连接。
]

```cpp
class ConstantSpectrum {
  public:
    ConstantSpectrum(Float c) : c(c) {}
    Float operator()(Float lambda) const { return c; }
  private:
    Float c;
};
```


#parec[
  More expressive is `DenselySampledSpectrum`, which stores a spectral distribution sampled at 1 nm intervals over a given range of integer wavelengths $[lambda_(upright("min")) , lambda_(upright("max"))]$.
][
  更具表现力的是 `DenselySampledSpectrum`，它存储在给定的整数波长范围 $[lambda_(upright("min")) , lambda_(upright("max"))]$ 内以 1 nm 间隔进行采样的光谱分布。
]

```cpp
<<Spectrum Definitions>>+=
class DenselySampledSpectrum {
  public:
    <<DenselySampledSpectrum Public Methods>>
  private:
    <<DenselySampledSpectrum Private Members>>
};
```


#parec[
  Its constructor takes another #link("<Spectrum>")[`Spectrum`] and evaluates that spectral distribution at each wavelength in the range. `DenselySampledSpectrum` can be useful if the provided spectral distribution is computationally expensive to evaluate, as it allows subsequent evaluations to be performed by reading a single value from memory.
][
  其构造函数接受另一个 #link("<Spectrum>")[`Spectrum`] 并在范围内的每个波长处评估该光谱分布。如果提供的光谱分布计算成本较高，`DenselySampledSpectrum` 可能会很有用，因为它允许通过从内存中读取单个值来进行后续评估。
]

```cpp
DenselySampledSpectrum(Spectrum spec, int lambda_min = Lambda_min,
                       int lambda_max = Lambda_max, Allocator alloc = {})
    : lambda_min(lambda_min), lambda_max(lambda_max),
      values(lambda_max - lambda_min + 1, alloc) {
    if (spec)
        for (int lambda = lambda_min; lambda <= lambda_max; ++lambda)
            values[lambda - lambda_min] = spec(lambda);
}
```

```cpp
int lambda_min, lambda_max;
pstd::vector<Float> values;
```

#parec[
  Finding the spectrum's value for a given wavelength `lambda` is a matter of returning zero for wavelengths outside of the valid range and indexing into the stored values otherwise.
][
  找到给定波长 `lambda` 的光谱值是返回超出有效范围的波长的零值，并在其他情况下索引存储的值。
]

```cpp
Float operator()(Float lambda) const {
    int offset = std::lround(lambda) - lambda_min;
    if (offset < 0 || offset >= values.size()) return 0;
    return values[offset];
}
```

#parec[
  While sampling a spectral distribution at 1 nm wavelengths gives sufficient accuracy for most uses in rendering, doing so requires nearly 2 kB of memory to store a distribution that covers the visible wavelengths. `PiecewiseLinearSpectrum` offers another representation that is often more compact; its distribution is specified by a set of pairs of values $(lambda_i , v_i)$ where the spectral distribution is defined by linearly interpolating between them; see @fig:piecewise-linear-spectrum. For spectra that are smooth in some regions and change rapidly in others, this representation makes it possible to specify the distribution at a higher rate in regions where its variation is greatest.
][
  虽然以 1 nm 波长采样光谱分布对于大多数渲染用途来说具有足够的精度，但这样做需要近 2 kB 的内存来存储覆盖可见波长的分布。`PiecewiseLinearSpectrum` 提供了另一种通常更紧凑的表示；其分布由一组值对 $(lambda_i , v_i)$ 指定，其中光谱分布通过在它们之间进行线性插值来定义；参见@fig:piecewise-linear-spectrum;。对于在某些区域平滑而在其他区域快速变化的光谱，这种表示使得可以在变化最大的区域以更高的速率指定分布。
]

```cpp
<<Spectrum Definitions>>+=
class PiecewiseLinearSpectrum {
  public:
    <<PiecewiseLinearSpectrum Public Methods>>
  private:
    <<PiecewiseLinearSpectrum Private Members>>
};
```

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/piecewise-linear-spectrum.svg"),
  caption: [ #ez_caption[
      `PiecewiseLinearSpectrum` defines a spectral
      distribution using a set of sample values $(lambda_i , v_i)$. A
      continuous distribution is then defined by linearly interpolating
      between them.
    ][
      `PiecewiseLinearSpectrum` 使用一组样本值 $(lambda_i , v_i)$
      定义光谱分布。然后通过在它们之间进行线性插值来定义连续分布。]
  ],
)<piecewise-linear-spectrum>


#parec[
  The `PiecewiseLinearSpectrum` constructor, not included here, checks that the provided `lambda` values are sorted and then stores them and the associated spectrum values in corresponding member variables.
][
  `PiecewiseLinearSpectrum` 构造函数（未在此处包含）检查提供的 `lambda` 值是否已排序，然后将它们和相关的光谱值存储在相应的成员变量中。
]

```cpp
PiecewiseLinearSpectrum(pstd::span<const Float> lambdas,
    pstd::span<const Float> values, Allocator alloc = {});
```

```cpp
pstd::vector<Float> lambdas, values;
```


#parec[
  Finding the value for a given wavelength requires first finding the pair of values in the `lambdas` array that bracket it and then linearly interpolating between them.
][
  要找到给定波长的值，首先需要在 `lambdas` 数组中找到将其括住的值对，然后在它们之间进行线性插值。
]

```cpp
Float PiecewiseLinearSpectrum::operator()(Float lambda) const {
    <<Handle PiecewiseLinearSpectrum corner cases>>
    if (lambdas.empty() || lambda < lambdas.front() || lambda > lambdas.back())
       return 0;
    <<Find offset to largest lambdas below lambda and interpolate>>
    int o = FindInterval(lambdas.size(),
                        [&](int i) { return lambdas[i] <= lambda; });
    Float t = (lambda - lambdas[o]) / (lambdas[o + 1] - lambdas[o]);
    return Lerp(t, values[o], values[o + 1]);
}
```


#parec[
  As with #link("<DenselySampledSpectrum>")[`DenselySampledSpectrum`];, wavelengths outside of the specified range are given a value of zero.
][
  与 #link("<DenselySampledSpectrum>")[`DenselySampledSpectrum`] 一样，超出指定范围的波长被赋予零值。
]

```cpp
if (lambdas.empty() || lambda < lambdas.front() || lambda > lambdas.back())
    return 0;
```


#parec[
  If `lambda` is in range, then #link("../Utilities/Mathematical_Infrastructure.html#FindInterval")[`FindInterval()`] gives the offset to the largest value of `lambdas` that is less than or equal to `lambda`. In turn, `lambda`'s offset between that wavelength and the next gives the linear interpolation parameter to use with the stored values.
][
  如果 `lambda` 在范围内，则 #link("../Utilities/Mathematical_Infrastructure.html#FindInterval")[`FindInterval()`] 给出小于或等于 `lambda` 的最大 `lambdas` 值的偏移量。反过来，`lambda` 在该波长和下一个波长之间的偏移量给出了用于存储值的线性插值参数。
]

```cpp
<<Find offset to largest lambdas below lambda and interpolate>>=
int o = FindInterval(lambdas.size(),
                     [&](int i) { return lambdas[i] <= lambda; });
Float t = (lambda - lambdas[o]) / (lambdas[o + 1] - lambdas[o]);
return Lerp(t, values[o], values[o + 1]);
```

#parec[
  The maximum value of the distribution is easily found using `std::max_element()`, which performs a linear search. This function is not currently called in any performance-sensitive parts of `pbrt`; if it was, it would likely be worth caching this value to avoid recomputing it.
][
  分布的最大值可以通过 `std::max_element()` 轻松找到，它执行线性搜索。此函数目前未在 `pbrt` 的任何性能敏感部分调用；如果调用，可能值得缓存此值以避免重新计算。
]

```cpp
Float PiecewiseLinearSpectrum::MaxValue() const {
    if (values.empty()) return 0;
    return *std::max_element(values.begin(), values.end());
}
```

#parec[
  Another useful #link("<Spectrum>")[`Spectrum`] implementation, `BlackbodySpectrum`, gives the spectral distribution of a blackbody emitter at a specified temperature.
][
  另一个有用的 #link("<Spectrum>")[`Spectrum`] 实现，`BlackbodySpectrum`，给出了在指定温度下黑体发射器的光谱分布。
]

```cpp
class BlackbodySpectrum {
  public:
    <<BlackbodySpectrum Public Methods>>
    BlackbodySpectrum(Float T) : T(T) {
           <<Compute blackbody normalization constant for given temperature>>
           Float lambdaMax = 2.8977721e-3f / T;
          normalizationFactor = 1 / Blackbody(lambdaMax * 1e9f, T);
    }
    Float operator()(Float lambda) const {
        return Blackbody(lambda, T) * normalizationFactor;
    }
    PBRT_CPU_GPU
    SampledSpectrum Sample(const SampledWavelengths &lambda) const {
        SampledSpectrum s;
        for (int i = 0; i < NSpectrumSamples; ++i)
            s[i] = Blackbody(lambda[i], T) * normalizationFactor;
        return s;
    }
    PBRT_CPU_GPU
    Float MaxValue() const { return 1.f; }

    std::string ToString() const;
  private:
    <<BlackbodySpectrum Private Members>>
    Float T;
    Float normalizationFactor;
};
```


#parec[
  The temperature of the blackbody in Kelvin is the constructor's only parameter.
][
  黑体的温度（以开尔文为单位）是构造函数的唯一参数。
]

```cpp
BlackbodySpectrum(Float T) : T(T) {
    <<Compute blackbody normalization constant for given temperature>>
    Float lambdaMax = 2.8977721e-3f / T;
    normalizationFactor = 1 / Blackbody(lambdaMax * 1e9f, T);
}
```

```cpp
Float T;
```

// https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Light_Emission.html#eq:stefan-boltzmann
#parec[
  Because the power emitted by a blackbody grows so quickly with temperature (recall the Stefan–Boltzmann law, @eqt:stefan-boltzmann), the #link("<BlackbodySpectrum>")[`BlackbodySpectrum`] represents a normalized blackbody spectral distribution where the maximum value at any wavelength is 1. Wien's displacement law, @eqt:wien-displacement, gives the wavelength in meters where emitted radiance is at its maximum; we must convert this value to nm before calling `Blackbody()` to find the corresponding radiance value.
][
  由于黑体辐射的功率随着温度迅速增长（回忆斯特藩-玻尔兹曼定律，@eqt:stefan-boltzmann），#link("<BlackbodySpectrum>")[`BlackbodySpectrum`] 表示一个归一化的黑体光谱分布，其中任何波长的最大值为 1。维恩位移定律（@eqt:wien-displacement）给出了发射辐射达到最大值的波长（以米为单位）；在调用 `Blackbody()` 以找到相应的辐射值之前，我们必须将此值转换为 nm。
]

```cpp
Float lambdaMax = 2.8977721e-3f / T;
normalizationFactor = 1 / Blackbody(lambdaMax * 1e9f, T);
```


```cpp
Float normalizationFactor;
```


#parec[
  The method that returns the value of the distribution at a wavelength then returns the product of the value returned by `Blackbody()` and the normalization factor.
][
  返回在某个波长处分布值的方法返回 `Blackbody()` 返回的值与归一化因子的乘积。
]

```cpp
Float operator()(Float lambda) const {
    return Blackbody(lambda, T) * normalizationFactor;
}
```


=== Embedded Spectral Data
<embedded-spectral-data>
#parec[
  `pbrt`'s scene description format provides multiple ways to specify spectral data, ranging from blackbody temperatures to arrays of $lambda$ -value pairs to specify a piecewise-linear spectrum. For convenience, a variety of useful spectral distributions are also embedded directly in the `pbrt` binary, including ones that describe the emission profiles of various types of light source, the scattering properties of various conductors, and the wavelength-dependent indices of refraction of various types of glass. See the online `pbrt` file format documentation for a list of all of them.
][
  `pbrt`的场景描述格式提供了多种指定光谱数据的方法，从黑体温度到 $lambda$ -值对数组，用于指定分段线性光谱。为了方便使用，各种有用的光谱分布也直接嵌入在`pbrt`二进制文件中，包括描述各种光源发射特性的光谱、各种导体的散射特性以及各种玻璃的波长依赖折射率的光谱。请参阅`pbrt`文件格式文档以获取它们的完整列表。
]

#parec[
  The `GetNamedSpectrum()` function searches through these spectra and returns a #link("<Spectrum>")[Spectrum] corresponding to a given named spectrum if it is available.
][
  `GetNamedSpectrum()`函数在这些光谱中搜索，并返回与给定命名光谱对应的#link("<Spectrum>")[光谱];，如果该光谱可用的话。
]

```cpp
Spectrum GetNamedSpectrum(std::string name);
```

#parec[
  A number of important spectra are made available directly through corresponding functions, all of which are in a `Spectra` namespace. Among them are `Spectra::X()`, `Spectra::Y()`, and `Spectra::Z()`, which return the color matching curves that are described in @xyz-color, and `Spectra::D()`, which returns a #link("<DenselySampledSpectrum>")[DenselySampledSpectrum] representing the D illuminant at the given temperature.
][
  一些重要的光谱通过相应的函数直接提供，所有这些函数都在`Spectra`命名空间中。其中包括`Spectra::X()`、`Spectra::Y()`和`Spectra::Z()`，它们返回如@xyz-color 中所述的颜色匹配曲线，以及`Spectra::D()`，它返回一个表示给定温度下D光源的#link("<DenselySampledSpectrum>")[DenselySampledSpectrum];。
]

```cpp
DenselySampledSpectrum D(Float T, Allocator alloc);
```


=== Sampled Spectral Distributions
<sampled-spectral-distributions>
#parec[
  The attentive reader may have noticed that although #link("<Spectrum>")[Spectrum] makes it possible to evaluate spectral distribution functions, it does not provide the ability to do very much computation with them other than sampling their value at a specified wavelength. Yet, for example, evaluating the integrand of the reflection equation, (@eqt:scattering-equation), requires taking the product of two spectral distributions, one for the BSDF and one for the incident radiance function.
][
  细心的读者可能已经注意到，虽然#link("<Spectrum>")[光谱];使得评估光谱分布函数成为可能，但它除了在指定波长处采样其值之外，并没有提供太多的计算能力。然而，例如，要评估反射方程的被积函数（@eqt:scattering-equation）需要将两个光谱分布相乘，一个用于BSDF，一个用于入射辐射函数。
]

#parec[
  Providing this functionality with the abstractions that have been introduced so far would quickly become unwieldy. For example, while the product of two #link("<DenselySampledSpectrum>")[DenselySampledSpectrum];s could be faithfully represented by another #link("<DenselySampledSpectrum>")[DenselySampledSpectrum];, consider taking the product of two #link("<PiecewiseLinearSpectrum>")[PiecewiseLinearSpectrum];s: the resulting function would be piecewise-quadratic and subsequent products would only increase its degree. Further, operations between `Spectrum` implementations of different types would not only require a custom implementation for each pair, but would require choosing a suitable `Spectrum` representation for each result.
][
  使用目前为止引入的抽象来提供此功能将很快变得繁琐。例如，虽然两个#link("<DenselySampledSpectrum>")[DenselySampledSpectrum];的乘积可以通过另一个#link("<DenselySampledSpectrum>")[DenselySampledSpectrum];准确地表示，但考虑两个#link("<PiecewiseLinearSpectrum>")[PiecewiseLinearSpectrum];的乘积：结果函数将是分段二次的，后续的乘积只会增加其阶数。此外，不同类型的`Spectrum`实现之间的运算不仅需要为每对实现自定义实现，还需要为每个结果选择合适的`Spectrum`表示。
]

#parec[
  `pbrt` avoids this complexity by performing spectral calculations at a set of discrete wavelengths as part of the Monte Carlo integration that is already being performed for image synthesis. To understand how this works, consider computing the (non-spectral) irradiance at some point $p$ with surface normal $upright(bold(n))$ over some range of wavelengths of interest, $[lambda_0 , lambda_1]$. Using Equation (@eqt:irradiance-from-radiance), which expresses irradiance in terms of incident radiance, and Equation (@eqt:radiance-from-spectral), which expresses radiance in terms of spectral radiance, we have
][
  `pbrt`通过在一组离散波长上执行光谱计算来避免这种复杂性，这也是图像合成中已经执行的蒙特卡罗积分的一部分。为了理解其工作原理，考虑在某点 $p$ 处具有表面法线 $upright(bold(n))$ 的某些感兴趣波长范围 $[lambda_0 , lambda_1]$ 上的（非光谱）辐照度的计算。使用表达辐照度与入射辐射之间关系的方程（@eqt:irradiance-from-radiance）和表达辐射与光谱辐射之间关系的方程（@eqt:radiance-from-spectral），我们有
]

$
  E = integral_Omega integral_(lambda_0)^(lambda_1) L_i (
    p , omega , lambda
  ) lr(|cos theta|) thin d omega thin d lambda ,
$


#parec[
  where $L_i (p , omega , lambda)$ is the incident spectral radiance at wavelength $lambda$.
][
  其中 $L_i (p , omega , lambda)$ 是波长 $lambda$ 处的入射光谱辐射。
]

#parec[
  Applying the standard Monte Carlo estimator and taking advantage of the fact that $omega$ and $lambda$ are independent, we can see that estimates of $E$ can be computed by sampling directions $omega_i$ from some distribution $p_omega$, wavelengths $lambda_i$ from some distribution $p_lambda$, and then evaluating:
][
  应用标准蒙特卡罗估计器并利用 $omega$ 和 $lambda$ 是独立的这一事实，我们可以看到 $E$ 的估计可以通过从某个分布 $p_omega$ 中采样方向 $omega_i$，从某个分布 $p_lambda$ 中采样波长 $lambda_i$，然后评估：
]

$
  E approx 1 / n sum_(i = 1)^n frac(L_i (p , omega_i , lambda_i) lr(|cos theta_i|), p_omega (omega_i) p_lambda (lambda_i)) .
$ <irradiance-from-spectral-radiance-estimate>

#parec[
  Thus, we only need to be able to evaluate the integrand at the specified discrete wavelengths to estimate the irradiance. More generally, we will see that it is possible to express all the spectral quantities that `pbrt` outputs as integrals over wavelength. For example, @color shows that when rendering an image represented using RGB colors, each pixel's color can be computed by integrating the spectral radiance arriving at a pixel with functions that model red, green, and blue color response. `pbrt` therefore uses only discrete spectral samples for spectral computation.
][
  因此，我们只需要能够在指定的离散波长处评估被积函数即可估计辐照度。更一般地，我们将看到，可以将`pbrt`输出的所有光谱量表示为波长上的积分。例如，@color 显示，当使用RGB颜色表示渲染图像时，每个像素的颜色可以通过将到达像素的光谱辐射与模拟红、绿、蓝颜色响应的函数进行积分来计算。因此，`pbrt`仅使用离散光谱样本进行光谱计算。
]

#parec[
  So that we can proceed to the implementation of the classes related to sampling spectra and performing computations with spectral samples, we will define the constant that sets the number of spectral samples here. (@choosing-the-number-of-wavelength-samples will discuss in more detail the trade-offs involved in choosing this value.) `pbrt` uses 4 wavelength samples by default; this value can easily be changed, though doing so requires recompiling the system.
][
  为了能够继续实现与采样光谱和光谱样本计算相关的类，我们将在此定义设置光谱样本数量的常量。（@choosing-the-number-of-wavelength-samples 将更详细地讨论选择此值时涉及的权衡。）`pbrt`默认使用4个波长样本；此值可以轻松地更改，但这样做需要重新编译系统。
]

```cpp
static constexpr int NSpectrumSamples = 4;
```



==== SampledSpectrum
<sampledspectrum>
#parec[
  The `SampledSpectrum` class stores an array of `NSpectrumSamples` values that represent values of the spectral distribution at discrete wavelengths. It provides methods that allow a variety of mathematical operations to be performed with them.
][
  `SampledSpectrum` 类存储了一个 `NSpectrumSamples` 值的数组，这些值表示在离散波长下的光谱分布值。它提供了多种对这些值进行数学运算的方法。
]

```cpp
class SampledSpectrum {
  public:
    SampledSpectrum operator+(const SampledSpectrum &s) const {
        SampledSpectrum ret = *this;
        return ret += s;
    }

    SampledSpectrum &operator-=(const SampledSpectrum &s) {
        for (int i = 0; i < NSpectrumSamples; ++i)
            values[i] -= s.values[i];
        return *this;
    }
    SampledSpectrum operator-(const SampledSpectrum &s) const {
        SampledSpectrum ret = *this;
        return ret -= s;
    }
    friend SampledSpectrum operator-(Float a, const SampledSpectrum &s) {
        DCHECK(!IsNaN(a));
        SampledSpectrum ret;
        for (int i = 0; i < NSpectrumSamples; ++i)
            ret.values[i] = a - s.values[i];
        return ret;
    }

    SampledSpectrum &operator*=(const SampledSpectrum &s) {
        for (int i = 0; i < NSpectrumSamples; ++i)
            values[i] *= s.values[i];
        return *this;
    }
    SampledSpectrum operator*(const SampledSpectrum &s) const {
        SampledSpectrum ret = *this;
        return ret *= s;
    }
    SampledSpectrum operator*(Float a) const {
        DCHECK(!IsNaN(a));
        SampledSpectrum ret = *this;
        for (int i = 0; i < NSpectrumSamples; ++i)
            ret.values[i] *= a;
        return ret;
    }
    SampledSpectrum &operator*=(Float a) {
        DCHECK(!IsNaN(a));
        for (int i = 0; i < NSpectrumSamples; ++i)
            values[i] *= a;
        return *this;
    }
    friend SampledSpectrum operator*(Float a, const SampledSpectrum &s) { return s * a; }

    SampledSpectrum &operator/=(const SampledSpectrum &s) {
        for (int i = 0; i < NSpectrumSamples; ++i) {
            DCHECK_NE(0, s.values[i]);
            values[i] /= s.values[i];
        }
        return *this;
    }
    SampledSpectrum operator/(const SampledSpectrum &s) const {
        SampledSpectrum ret = *this;
        return ret /= s;
    }
    SampledSpectrum &operator/=(Float a) {
        DCHECK_NE(a, 0);
        DCHECK(!IsNaN(a));
        for (int i = 0; i < NSpectrumSamples; ++i)
            values[i] /= a;
        return *this;
    }
    SampledSpectrum operator/(Float a) const {
        SampledSpectrum ret = *this;
        return ret /= a;
    }

    SampledSpectrum operator-() const {
        SampledSpectrum ret;
        for (int i = 0; i < NSpectrumSamples; ++i)
            ret.values[i] = -values[i];
        return ret;
    }
    bool operator==(const SampledSpectrum &s) const { return values == s.values; }
    bool operator!=(const SampledSpectrum &s) const { return values != s.values; }

    std::string ToString() const;

    bool HasNaNs() const {
        for (int i = 0; i < NSpectrumSamples; ++i)
            if (IsNaN(values[i]))
                return true;
        return false;
    }

    XYZ ToXYZ(const SampledWavelengths &lambda) const;
    RGB ToRGB(const SampledWavelengths &lambda, const RGBColorSpace &cs) const;
    Float y(const SampledWavelengths &lambda) const;
    explicit SampledSpectrum(Float c) { values.fill(c); }
    SampledSpectrum(pstd::span<const Float> v) {
        for (int i = 0; i < NSpectrumSamples; ++i)
            values[i] = v[i];
    }
    Float operator[](int i) const { return values[i]; }
    Float &operator[](int i) { return values[i]; }
    explicit operator bool() const {
        for (int i = 0; i < NSpectrumSamples; ++i)
            if (values[i] != 0) return true;
        return false;
    }
    SampledSpectrum &operator+=(const SampledSpectrum &s) {
        for (int i = 0; i < NSpectrumSamples; ++i)
            values[i] += s.values[i];
        return *this;
    }
    Float MinComponentValue() const {
     Float m = values[0];
        for (int i = 1; i < NSpectrumSamples; ++i)
            m = std::min(m, values[i]);
        return m;
    }
    Float MaxComponentValue() const {
        Float m = values[0];
        for (int i = 1; i < NSpectrumSamples; ++i)
            m = std::max(m, values[i]);
        return m;
    }
    Float Average() const {
        Float sum = values[0];
        for (int i = 1; i < NSpectrumSamples; ++i)
            sum += values[i];
        return sum / NSpectrumSamples;
    }
  private:
    pstd::array<Float, NSpectrumSamples> values;
};
```

#parec[
  Its constructors include one that allows providing a single value for all wavelengths and one that takes an appropriately sized `pstd::span` of per-wavelength values.
][
  其构造函数包括一个可以为所有波长设置相同值的构造函数，以及一个接受适当大小的每波长值的 `pstd::span` 的构造函数。
]

```cpp
explicit SampledSpectrum(Float c) { values.fill(c); }
SampledSpectrum(pstd::span<const Float> v) {
    for (int i = 0; i < NSpectrumSamples; ++i)
        values[i] = v[i];
}
```


#parec[
  The usual indexing operations are also provided for accessing and setting each wavelength's value.
][
  还提供了常用的索引操作，用于访问和设置每个波长的值。
]

```cpp
Float operator[](int i) const { return values[i]; }
Float &operator[](int i) { return values[i]; }
```


#parec[
  It is often useful to know if all the values in a `SampledSpectrum` are zero. For example, if a surface has zero reflectance, then the light transport routines can avoid the computational cost of casting reflection rays that have contributions that would eventually be multiplied by zeros. This capability is provided through a type conversion operator to `bool`.
][
  通常需要知道 `SampledSpectrum` 中的所有值是否为零。例如，如果一个表面的反射率为零，那么光传输程序可以避免投射反射光线的计算成本，因为这些光线的贡献最终会被乘以零。这种功能是通过类型转换为 `bool` 实现的。
]

```cpp
explicit operator bool() const {
    for (int i = 0; i < NSpectrumSamples; ++i)
        if (values[i] != 0) return true;
    return false;
}
```


#parec[
  All the standard arithmetic operations on `SampledSpectrum` objects are provided; each operates component-wise on the stored values. The implementation of `operator+=` is below. The others are analogous and are therefore not included in the text.
][
  提供了所有标准的 `SampledSpectrum` 对象的算术运算；每个运算在存储的值上逐个分量进行。`operator+=` 的实现如下。其他的类似，因此不包括在文本中。
]

```cpp
SampledSpectrum &operator+=(const SampledSpectrum &s) {
    for (int i = 0; i < NSpectrumSamples; ++i)
        values[i] += s.values[i];
    return *this;
}
```

#parec[
  `SafeDiv()` divides two sampled spectra, but generates zero for any sample where the divisor is zero.
][
  `SafeDiv()` 对两个采样光谱进行除法运算，但对于除数为零的任何样本，结果为零。
]

```cpp
SampledSpectrum SafeDiv(SampledSpectrum a, SampledSpectrum b) {
    SampledSpectrum r;
    for (int i = 0; i < NSpectrumSamples; ++i)
        r[i] = (b[i] != 0) ? a[i] / b[i] : 0.;
    return r;
}
```


#parec[
  In addition to the basic arithmetic operations, `SampledSpectrum` also provides `Lerp()`, `Sqrt()`, `Clamp()`, `ClampZero()`, `Pow()`, `Exp()`, and `FastExp()` functions that operate (again, component-wise) on `SampledSpectrum` objects; some of these operations are necessary for evaluating some of the reflection models in @reflection-models and for evaluating volume scattering models in @light-transport-i-surface-reflection. Finally, `MinComponentValue()` and `MaxComponentValue()` return the minimum and maximum of all the values, and `Average()` returns their average. These methods are all straightforward and are therefore not included in the text.
][
  除了基本的算术运算，`SampledSpectrum` 还提供了 `Lerp()`、`Sqrt()`、`Clamp()`、`ClampZero()`、`Pow()`、`Exp()` 和 `FastExp()` 函数，这些函数对 `SampledSpectrum` 对象进行（同样是逐个分量的）操作；在@reflection-models 的反射模型评估和@light-transport-i-surface-reflection 的体积散射模型评估中，这些运算是必要的。 最后，`MinComponentValue()` 和 `MaxComponentValue()` 返回所有值的最小值和最大值，而 `Average()` 返回它们的平均值。这些方法都很简单，因此未在文本中详细列出。
]



=== SampledWavelengths
<sampledwavelengths>
#parec[
  A separate class, `SampledWavelengths`, stores the wavelengths for which a #link("<SampledSpectrum>")[`SampledSpectrum`] stores samples. Thus, it is important not only to keep careful track of the `SampledWavelengths` that are represented by an individual `SampledSpectrum` but also to not perform any operations that combine `SampledSpectrum`s that have samples at different wavelengths.
][
  一个单独的类，`SampledWavelengths`，存储一个#link("<SampledSpectrum>")[`SampledSpectrum`];实例对应样本的波长。因此，重要的是不仅要仔细跟踪由单个`SampledSpectrum`表示的`SampledWavelengths`，而且不要执行任何将具有不同波长样本的`SampledSpectrum`组合的操作。
]

```cpp
class SampledWavelengths {
  public:
    bool operator==(const SampledWavelengths &swl) const {
        return lambda == swl.lambda && pdf == swl.pdf;
    }
    bool operator!=(const SampledWavelengths &swl) const {
        return lambda != swl.lambda || pdf != swl.pdf;
    }

    std::string ToString() const;
    static SampledWavelengths SampleUniform(Float u,
            Float lambda_min = Lambda_min, Float lambda_max = Lambda_max) {
        SampledWavelengths swl;
        swl.lambda[0] = Lerp(u, lambda_min, lambda_max);
        Float delta = (lambda_max - lambda_min) / NSpectrumSamples;
        for (int i = 1; i < NSpectrumSamples; ++i) {
            swl.lambda[i] = swl.lambda[i - 1] + delta;
            if (swl.lambda[i] > lambda_max)
                swl.lambda[i] = lambda_min + (swl.lambda[i] - lambda_max);
        }
        for (int i = 0; i < NSpectrumSamples; ++i)
            swl.pdf[i] = 1 / (lambda_max - lambda_min);
        return swl;
    }
    Float operator[](int i) const { return lambda[i]; }
    Float &operator[](int i) { return lambda[i]; }
    SampledSpectrum PDF() const { return SampledSpectrum(pdf); }
    void TerminateSecondary() {
        if (SecondaryTerminated()) return;
        for (int i = 1; i < NSpectrumSamples; ++i)
            pdf[i] = 0;
        pdf[0] /= NSpectrumSamples;
    }
    bool SecondaryTerminated() const {
        for (int i = 1; i < NSpectrumSamples; ++i)
            if (pdf[i] != 0)
                return false;
        return true;
    }
    static SampledWavelengths SampleVisible(Float u) {
        SampledWavelengths swl;
        for (int i = 0; i < NSpectrumSamples; ++i) {
            Float up = u + Float(i) / NSpectrumSamples;
            if (up > 1)
                up -= 1;
            swl.lambda[i] = SampleVisibleWavelengths(up);
            swl.pdf[i] = VisibleWavelengthsPDF(swl.lambda[i]);
        }
        return swl;
    }
  private:
    friend struct SOA<SampledWavelengths>;
    pstd::array<Float, NSpectrumSamples> lambda, pdf;
};
```


#parec[
  To be used in the context of Monte Carlo integration, the wavelengths stored in #link("<SampledWavelengths>")[`SampledWavelengths`] must be sampled from some probability distribution. Therefore, the class stores the wavelengths themselves as well as each one's probability density.
][
  为了在蒙特卡罗积分中使用，存储在#link("<SampledWavelengths>")[`SampledWavelengths`];中的波长必须是从某个概率分布中采样。因此，该类存储了波长本身以及每个波长的概率密度。
]

```cpp
pstd::array<Float, NSpectrumSamples> lambda, pdf;
```


#parec[
  The easiest way to sample wavelengths is uniformly over a given range. This approach is implemented in the `SampleUniform()` method, which takes a single uniform sample `u` and a range of wavelengths.
][
  采样波长最简单的方法是在给定范围内进行均匀采样。这个方法在`SampleUniform()`方法中实现，它接受一个均匀样本`u`和一个波长范围。
]

```cpp
static SampledWavelengths SampleUniform(Float u, Float lambda_min = Lambda_min, Float lambda_max = Lambda_max) {
    SampledWavelengths swl;
    swl.lambda[0] = Lerp(u, lambda_min, lambda_max);
    Float delta = (lambda_max - lambda_min) / NSpectrumSamples;
    for (int i = 1; i < NSpectrumSamples; ++i) {
        swl.lambda[i] = swl.lambda[i - 1] + delta;
        if (swl.lambda[i] > lambda_max)
            swl.lambda[i] = lambda_min + (swl.lambda[i] - lambda_max);
    }
    for (int i = 0; i < NSpectrumSamples; ++i)
        swl.pdf[i] = 1 / (lambda_max - lambda_min);
    return swl;
}
```

#parec[
  It chooses the first wavelength uniformly within the range.
][
  这个方法通过在给定范围内均匀选择波长来实现采样。
]

```cpp
swl.lambda[0] = Lerp(u, lambda_min, lambda_max);
```


#parec[
  The remaining wavelengths are chosen by taking uniform steps `delta` starting from the first wavelength and wrapping around if `lambda_max` is passed. The result is a set of stratified wavelength samples that are generated using a single random number. One advantage of sampling wavelengths in this way rather than using a separate uniform sample for each one is that the value of #link("<NSpectrumSamples>")[`NSpectrumSamples`] can be changed without requiring the modification of code that calls `SampleUniform()` to adjust the number of sample values that are passed to this method.
][
  其余的波长通过从第一个波长开始以均匀步长`delta`选择，如果超过`lambda_max`则回绕。结果是一组分层的波长样本，这些样本是使用单个随机数生成的。以这种方式采样波长的一个优点是，不需要为每个波长使用单独的均匀样本，这样#link("<NSpectrumSamples>")[`NSpectrumSamples`];的值可以更改，而不需要修改调用`SampleUniform()`的代码来调整传递给该方法的样本值的数量。
]

```cpp
Float delta = (lambda_max - lambda_min) / NSpectrumSamples;
for (int i = 1; i < NSpectrumSamples; ++i) {
    swl.lambda[i] = swl.lambda[i - 1] + delta;
    if (swl.lambda[i] > lambda_max)
        swl.lambda[i] = lambda_min + (swl.lambda[i] - lambda_max);
}
```


#parec[
  The probability density for each sample is easily computed, since the sampling distribution is uniform.
][
  由于采样分布是均匀的，因此每个样本的概率密度很容易计算。
]

```cpp
for (int i = 0; i < NSpectrumSamples; ++i)
    swl.pdf[i] = 1 / (lambda_max - lambda_min);
```


#parec[
  Additional methods provide access to the individual wavelengths and to all of their PDFs. PDF values are returned in the form of a #link("<SampledSpectrum>")[`SampledSpectrum`];, which makes it easy to compute the value of associated Monte Carlo estimators.
][
  附加方法提供对各个波长及其所有PDF的访问。PDF值以#link("<SampledSpectrum>")[`SampledSpectrum`];的形式返回，这使得计算相关蒙特卡罗估计器的值变得容易。
]

```cpp
Float operator[](int i) const { return lambda[i]; }
Float &operator[](int i) { return lambda[i]; }
SampledSpectrum PDF() const { return SampledSpectrum(pdf); }
```


#parec[
  In some cases, different wavelengths of light may follow different paths after a scattering event. The most common example is when light undergoes dispersion and different wavelengths of light refract to different directions. When this happens, it is no longer possible to track multiple wavelengths of light with a single ray. For this case, #link("<SampledWavelengths>")[`SampledWavelengths`] provides the capability of terminating all but one of the wavelengths; subsequent computations can then consider the single surviving wavelength exclusively.
][
  在某些情况下，不同波长的光在散射后可能会沿不同路径传播。最常见的例子是光发生色散，不同波长的光折射到不同的方向。当这种情况发生时，就不再可能用单一光线跟踪多个波长的光。对于这种情况，#link("<SampledWavelengths>")[`SampledWavelengths`];提供了终止除一个波长之外的所有波长的功能；随后可以只考虑单个存活的波长进行计算。这在光线跟踪中是必要的，以确保计算的准确性。
]

```cpp
void TerminateSecondary() {
    if (SecondaryTerminated()) return;
    for (int i = 1; i < NSpectrumSamples; ++i)
        pdf[i] = 0;
    pdf[0] /= NSpectrumSamples;
}
```


#parec[
  The wavelength stored in `lambda[0]` is always the survivor: there is no need to randomly select the surviving wavelength so long as each `lambda` value was randomly sampled from the same distribution as is the case with `SampleUniform()`, for example. Note that this means that it would be incorrect for #link("<SampledWavelengths::SampleUniform>")[`SampledWavelengths::SampleUniform`] to always place `lambda[0]` in a first wavelength stratum between `lambda_min` and `lambda_min+delta`, `lambda[1]` in the second, and so forth.
][
  存储在`lambda[0]`中的波长始终是保留下来的波长：只要每个`lambda`值都是从相同的分布中随机采样的，就不需要随机选择幸存的波长，例如`SampleUniform()`就是这种情况。请注意，这意味着#link("<SampledWavelengths::SampleUniform>")[`SampledWavelengths::SampleUniform`];将`lambda[0]`始终放在`lambda_min`和`lambda_min+delta`之间的第一个波长层中，`lambda[1]`放在第二个波长层中，依此类推是错误的。
]

#parec[
  Terminated wavelengths have their PDF values set to zero; code that computes Monte Carlo estimates using `SampledWavelengths` must therefore detect this case and ignore terminated wavelengths accordingly. The surviving wavelength's PDF is updated to account for the termination event by multiplying it by the probability of a wavelength surviving termination, $1 \/ upright("NSpectrumSamples")$. (This is similar to how applying Russian roulette affects the Monte Carlo estimator—see @russian-roulette .)
][
  终止的波长将其PDF值设置为零；使用`SampledWavelengths`计算蒙特卡罗估计的代码因此必须检测这种情况并相应地忽略终止的波长。通过将幸存波长的PDF乘以波长幸存终止的概率 $1 \/ upright("NSpectrumSamples")$ 来更新幸存波长的PDF。（这类似于如何应用俄罗斯轮盘赌影响蒙特卡罗估计器——参见@russian-roulette ）
]

```cpp
for (int i = 1; i < NSpectrumSamples; ++i)
    pdf[i] = 0;
pdf[0] /= NSpectrumSamples;
```


#parec[
  `SecondaryTerminated()` indicates whether `TerminateSecondary()` has already been called. Because path termination is the only thing that causes zero-valued PDFs after the first wavelength, checking the PDF values suffices for this test.
][
  `SecondaryTerminated()`指示是否已经调用了`TerminateSecondary()`。因为路径终止是导致第一个波长之后的PDF值为零的唯一原因，所以检查PDF值就足以进行此测试。
]

```cpp
bool SecondaryTerminated() const {
    for (int i = 1; i < NSpectrumSamples; ++i)
        if (pdf[i] != 0)
            return false;
    return true;
}
```


#parec[
  We will often have a #link("<Spectrum>")[`Spectrum`] and a set of wavelengths for which we would like to evaluate it. Therefore, we will add a method to the #link("<Spectrum>")[`Spectrum`] interface that provides a `Sample()` method that takes a set of wavelengths, evaluates its spectral distribution function at each one, and returns a #link("<SampledSpectrum>")[`SampledSpectrum`];. This convenience method eliminates the need for an explicit loop over wavelengths with individual calls to #link("<Spectrum::operator>")[`Spectrum::operator`] in this common case. The implementations of this method are straightforward and not included here.
][
  我们经常会有一个#link("<Spectrum>")[`Spectrum`];和一组我们希望评估的波长。因此，我们将在#link("<Spectrum>")[`Spectrum`];接口中添加一个`Sample()`方法，该方法接受一组波长，在每个波长上评估其光谱分布函数，并返回一个#link("<SampledSpectrum>")[`SampledSpectrum`];。这个便利的方法消除了在这种常见情况下需要通过单独调用#link("<Spectrum::operator>")[`Spectrum::operator`];进行显式波长循环的需求。该方法的实现很简单，这里不再列出。
]

```cpp
SampledSpectrum Sample(const SampledWavelengths &lambda) const;
```


=== Discussion
<discussion>
#parec[
  Now that #link("<SampledWavelengths>")[`SampledWavelengths`] and #link("<SampledSpectrum>")[`SampledSpectrum`] have been introduced, it is reasonable to ask the question: why are they separate classes, rather than a single class that stores both wavelengths and their sample values? Indeed, an advantage of such a design would be that it would be possible to detect at runtime if an operation was performed with two #link("<SampledSpectrum>")[`SampledSpectrum`] instances that stored values for different wavelengths—such an operation is nonsensical and would signify a bug in the system.
][
  现在已经介绍了#link("<SampledWavelengths>")[`SampledWavelengths`];和#link("<SampledSpectrum>")[`SampledSpectrum`];，合理的问题是：为什么它们是单独的类，而不是一个同时存储波长及其样本值的类？实际上，这种设计的一个优点是可以在运行时检测是否对存储不同波长值的两个#link("<SampledSpectrum>")[`SampledSpectrum`];实例执行了操作——这种操作是无意义的，并且表示系统中的一个错误。
]

#parec[
  However, in practice many #link("<SampledSpectrum>")[`SampledSpectrum`] objects are created during rendering, many as temporary values in the course of evaluating expressions involving spectral computation. It is therefore worthwhile to minimize the object's size, if only to avoid initialization and copying of additional data. While the `pbrt`'s CPU-based integrators do not store many #link("<SampledSpectrum>")[`SampledSpectrum`] values in memory at the same time, the GPU rendering path stores a few million of them, giving further motivation to minimize their size.
][
  然而，在实践中，许多#link("<SampledSpectrum>")[`SampledSpectrum`];对象是在渲染过程中创建的，许多是在评估涉及光谱计算的表达式过程中作为临时值创建的。因此，值得最小化对象的大小，即使只是为了避免初始化和复制额外的数据。虽然`pbrt`的基于CPU的积分器不会在内存中同时存储许多#link("<SampledSpectrum>")[`SampledSpectrum`];值，但GPU渲染路径存储了几百万个，这促使进一步优化它们的大小。
]

#parec[
  Our experience has been that bugs from mixing computations at different wavelengths have been rare. With the way that computation is structured in `pbrt`, wavelengths are generally sampled at the start of following a ray's path through the scene, and then the same wavelengths are used throughout for all spectral calculations along the path. There ends up being little opportunity for inadvertent mingling of sampled wavelengths in #link("<SampledSpectrum>")[`SampledSpectrum`] instances. Indeed, in an earlier version of the system, #link("<SampledSpectrum>")[`SampledSpectrum`] did carry along a #link("<SampledWavelengths>")[`SampledWavelengths`] member variable in debug builds in order to be able to check for that case. It was eliminated in the interests of simplicity after a few months' existence without finding a bug.
][
  我们的经验是，不同波长下混合计算的错误很少发生。由于在`pbrt`中计算的结构，波长通常是在跟踪光线路径的开始时采样的，然后在路径上的所有光谱计算中使用相同的波长。最终，在#link("<SampledSpectrum>")[`SampledSpectrum`];实例中无意中混合采样波长的机会很少。实际上，在系统的早期版本中，#link("<SampledSpectrum>")[`SampledSpectrum`];确实在调试版本中携带了一个#link("<SampledWavelengths>")[`SampledWavelengths`];成员变量，以便能够检查这种情况。经过几个月没有发现错误的存在后，为了简化而将其删除。
]
