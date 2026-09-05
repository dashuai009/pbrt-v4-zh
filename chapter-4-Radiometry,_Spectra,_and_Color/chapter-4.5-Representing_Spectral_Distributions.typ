#import "../template.typ": parec, ez_caption


== #ez_caption[Representing Spectral Distributions][表示光谱分布]
<representing-spectral-distributions>

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f16.svg"),
  caption: [
    #ez_caption[ Spectral Distribution of Reflection from Lemon Skin.  ][柠檬表皮反射光的光谱分布。
    ]
  ],
) <lemon-skin-spd>
#parec[
  Spectral distributions in the real world can be complex; we have already seen a variety of complex emission spectra and @fig:lemon-skin-spd shows a graph of the spectral distribution of the reflectance of lemon skin. In order to render images of scenes that include a variety of complex spectra, a renderer must have efficient and accurate representations of spectral distributions. This section will introduce `pbrt`'s abstractions for representing and performing computation with them; the corresponding code can be found in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.h")[`util/spectrum.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.cpp")[`util/spectrum.cpp`].
][
  现实世界中的光谱分布可能很复杂；我们已经看到了各种复杂的发射光谱，@fig:lemon-skin-spd 显示了柠檬表皮反射率的光谱分布。为了渲染包含各种复杂光谱的场景图像，渲染器必须具有高效且准确的光谱分布表示。本节将介绍 `pbrt` 用于表示和计算光谱分布的抽象；相应的代码可以在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.h")[`util/spectrum.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/spectrum.cpp")[`util/spectrum.cpp`] 中找到。
]

#parec[
  We will start by defining constants that give the range of visible wavelengths. Both here and for the remainder of the spectral code in `pbrt`, wavelengths are specified in nanometers, which are of a magnitude that gives easily human-readable values for the visible wavelengths.
][
  我们将首先定义可见波长范围的常量。在这里以及 `pbrt` 的其余光谱代码中，波长以纳米为单位指定，这个量级使得可见波长的值易于人们阅读。
]

#block(sticky: true)[#raw("<<Spectrum Constants>>=") #link(<fragment-SpectrumConstants-1>)[▼]] <fragment-SpectrumConstants-0>
```cpp
constexpr Float Lambda_min = 360, Lambda_max = 830;
```

=== #ez_caption[Spectrum Interface][Spectrum 接口]
<spectrum-interface>
#parec[
  We will find a variety of spectral representations useful in `pbrt`, ranging from spectral sample values tabularized by wavelength to functional descriptions such as the blackbody function. This brings us to our first interface class, #link(<Spectrum>)[`Spectrum`]. A #link(<Spectrum>)[`Spectrum`] corresponds to a pointer to a class that implements one such spectral representation.
][
  在 `pbrt` 中，多种光谱表示都能派上用场，从按波长制成表格的光谱样本值到黑体函数这样的函数形式描述。这引出了我们的第一个接口类，#link(<Spectrum>)[`Spectrum`]。一个 #link(<Spectrum>)[`Spectrum`] 对应于一个指向实现这种光谱表示的类的指针。
]

#parec[
  `Spectrum` inherits from #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`], which handles the details of runtime polymorphism. #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] requires that all the types of `Spectrum` implementations be provided as template parameters, which allows it to associate a unique integer identifier with each type. (See #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#sec:tagged-pointer")[Section B.4.4] for details of its implementation.)
][
  `Spectrum` 继承自 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`]，它处理运行时多态的细节。#link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 要求所有 `Spectrum` 实现的类型作为模板参数提供，这使得它可以将唯一的整数标识符与每种类型关联。（实现细节见 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#sec:tagged-pointer")[B.4.4 节]。）
]

#block(sticky: true)[#raw("<<Spectrum Definition>>=")] <fragment-SpectrumDefinition-0>
```cpp
class Spectrum
    : public TaggedPointer<ConstantSpectrum, DenselySampledSpectrum,
                           PiecewiseLinearSpectrum, RGBAlbedoSpectrum,
                           RGBUnboundedSpectrum, RGBIlluminantSpectrum,
                           BlackbodySpectrum> {
  public:
    <<Spectrum Interface>>
};
``` <Spectrum>

#parec[
  As with other classes that are based on #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`], `Spectrum` defines an interface that must be implemented by all the spectral representations. Typical practice in C++ would be for such an interface to be specified by pure virtual methods in `Spectrum` and for `Spectrum` implementations to inherit from `Spectrum` and implement those methods. With the `TaggedPointer` approach, the interface is specified implicitly: for each method in the interface, there is a method in `Spectrum` that dispatches calls to the appropriate type's implementation. We will discuss the details of how this works for a single method here but will omit them for other Spectrum methods and for other interface classes since they all follow the same boilerplate.
][
  与其他基于 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 的类一样，`Spectrum` 定义了一个必须由所有光谱表示实现的接口。在 C++ 中的典型做法是通过 `Spectrum` 中的纯虚方法指定这样的接口，并让 `Spectrum` 的实现继承自 `Spectrum` 并实现这些方法。使用 `TaggedPointer` 方法，接口是隐式指定的：对于接口中的每个方法，`Spectrum` 中都有一个方法将调用分派给适当类型的实现。这里将以一个方法为例，详述这种机制的工作方式；其他 `Spectrum` 方法和接口类都采用相同的模式，因此不再重复说明。
]

#parec[
  The most important method that #link(<Spectrum>)[`Spectrum`] defines is `operator()`, which takes a single wavelength $lambda$ and returns the value of the spectral distribution for that wavelength.
][
  #link(<Spectrum>)[`Spectrum`] 定义的最重要的方法是 `operator()`，它接受一个单一波长 $lambda$ 并返回该波长的光谱分布值。
]

#block(sticky: true)[#raw("<<Spectrum Interface>>=") #link(<fragment-SpectrumInterface-1>)[▼]] <fragment-SpectrumInterface-0>
```cpp
Float operator()(Float lambda) const;
```


#parec[
  The corresponding method implementation is brief, though dense. A call to #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer::Dispatch")[`TaggedPointer::Dispatch()`] begins the process of dispatching the method call. The #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] class stores an integer tag along with the object's pointer that encodes its type; in turn, `Dispatch()` is able to determine the specific type of the pointer at runtime. It then calls the callback function provided to it with a pointer to the object, cast to be a pointer to its actual type.
][
  相应的方法实现虽短，却包含不少细节。调用 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer::Dispatch")[`TaggedPointer::Dispatch()`] 开始了方法调用的分派过程。#link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 类存储了一个整数标签以及对象的指针，该标签编码了其类型；反过来，`Dispatch()` 能够在运行时确定指针的具体类型。然后，它调用提供给它的回调函数，并将对象的指针作为其实际类型的指针传递给回调函数。
]

#parec[
  The lambda function that is called here, `op`, takes a pointer with the `auto` type specifier for its parameter. In C++17, such a lambda function acts as a templated function; a call to it with a concrete type acts as an instantiation of a lambda that takes that type. Thus, the call `(*ptr)(lambda)` in the lambda body ends up as a direct call to the appropriate method.
][
  这里调用的 lambda 函数 `op` 接受一个指针参数，其类型使用 `auto` 说明符。在 C++17 中，这样的 lambda 函数充当模板函数；对其进行具体类型的调用相当于实例化一个接受该类型的 lambda。因此，lambda 主体中的调用 `(*ptr)(lambda)` 最终成为对适当方法的直接调用。
]

#block(sticky: true)[#raw("<<Spectrum Inline Method Definitions>>=")] <fragment-SpectrumInlineMethodDefinitions-0>
```cpp
inline Float Spectrum::operator()(Float lambda) const {
    auto op = [&](auto ptr) { return (*ptr)(lambda); };
    return Dispatch(op);
}
``` <Spectrum::operator>


#parec[
  `Spectrum` implementations must also provide a `MaxValue()` method that returns a bound on the maximum value of the spectral distribution over its wavelength range. This method's main use in `pbrt` is for computing bounds on the power emitted by light sources so that lights can be sampled according to their expected contribution to illumination in the scene.
][
  `Spectrum` 实现还必须提供一个 `MaxValue()` 方法，该方法返回其波长范围内光谱分布的最大值的上界。此方法在 `pbrt` 中的主要用途是计算光源发射功率的上界，以便根据光源在场景中对照明的预期贡献对其进行采样。
]

#block(sticky: true)[#raw("<<Spectrum Interface>>+=") #link(<fragment-SpectrumInterface-0>)[▲] #link(<fragment-SpectrumInterface-2>)[▼]] <fragment-SpectrumInterface-1>
```cpp
Float MaxValue() const;
```

=== #ez_caption[General Spectral Distributions][通用光谱分布]
<general-spectral-distributions>
#parec[
  With the `Spectrum` interface specified, we will start by defining a few `Spectrum` class implementations that explicitly tabularize values of the spectral distribution function. #link(<ConstantSpectrum>)[`ConstantSpectrum`] is the simplest: it represents a constant spectral distribution over all wavelengths. The most common use of the #link(<ConstantSpectrum>)[`ConstantSpectrum`] class in `pbrt` is to define a zero-valued spectral distribution in cases where a particular form of scattering is not present.
][
  在指定了 `Spectrum` 接口后，我们将首先定义一些 `Spectrum` 类的实现，这些实现将光谱分布函数的值显式存储下来。#link(<ConstantSpectrum>)[`ConstantSpectrum`] 是最简单的：它表示在所有波长上的恒定光谱分布。在 `pbrt` 中，#link(<ConstantSpectrum>)[`ConstantSpectrum`] 类最常见的用途是当某种形式的散射不存在时，定义一个零值的光谱分布。
]

#parec[
  The `ConstantSpectrum` implementation is straightforward and we omit its trivial `MaxValue()` method here. Note that it does not inherit from #link(<Spectrum>)[`Spectrum`]. This is another difference from using traditional C++ abstract base classes with virtual functions—as far as the C++ type system is concerned, there is no explicit connection between #link(<ConstantSpectrum>)[`ConstantSpectrum`] and `Spectrum`.
][
  `ConstantSpectrum` 的实现很简单，这里省略了其简单的 `MaxValue()` 方法。注意它没有继承自 #link(<Spectrum>)[`Spectrum`]。这与传统的 C++ 抽象基类和虚函数的使用不同——就 C++ 类型系统而言，#link(<ConstantSpectrum>)[`ConstantSpectrum`] 和 `Spectrum` 之间没有明确的连接。
]

#block(sticky: true)[#raw("<<Spectrum Definitions>>=") #link(<fragment-SpectrumDefinitions-1>)[▼]] <fragment-SpectrumDefinitions-0>
```cpp
class ConstantSpectrum {
  public:
    ConstantSpectrum(Float c) : c(c) {}
    Float operator()(Float lambda) const { return c; }
  private:
    Float c;
};
``` <ConstantSpectrum>


#parec[
  More expressive is `DenselySampledSpectrum`, which stores a spectral distribution sampled at 1 nm intervals over a given range of integer wavelengths $[lambda_(upright("min")) , lambda_(upright("max"))]$.
][
  更具表现力的是 `DenselySampledSpectrum`，它存储在给定的整数波长范围 $[lambda_(upright("min")) , lambda_(upright("max"))]$ 内以 1 nm 间隔进行采样的光谱分布。
]

#block(sticky: true)[#raw("<<Spectrum Definitions>>+=") #link(<fragment-SpectrumDefinitions-0>)[▲] #link(<fragment-SpectrumDefinitions-2>)[▼]] <fragment-SpectrumDefinitions-1>
```cpp
class DenselySampledSpectrum {
  public:
    <<DenselySampledSpectrum Public Methods>>
  private:
    <<DenselySampledSpectrum Private Members>>
};
``` <DenselySampledSpectrum>


#parec[
  Its constructor takes another #link(<Spectrum>)[`Spectrum`] and evaluates that spectral distribution at each wavelength in the range. `DenselySampledSpectrum` can be useful if the provided spectral distribution is computationally expensive to evaluate, as it allows subsequent evaluations to be performed by reading a single value from memory.
][
  其构造函数接受另一个 #link(<Spectrum>)[`Spectrum`] 并在范围内的每个波长处计算该光谱分布的值。如果提供的光谱分布计算成本较高，`DenselySampledSpectrum` 可能会很有用，因为它允许通过从内存中读取单个值来完成后续求值。
]

#block(sticky: true)[#raw("<<DenselySampledSpectrum Public Methods>>=") #link(<fragment-DenselySampledSpectrumPublicMethods-1>)[▼]] <fragment-DenselySampledSpectrumPublicMethods-0>
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

#block(sticky: true)[#raw("<<DenselySampledSpectrum Private Members>>=")] <fragment-DenselySampledSpectrumPrivateMembers-0>
```cpp
int lambda_min, lambda_max;
pstd::vector<Float> values;
```

#parec[
  Finding the spectrum's value for a given wavelength `lambda` is a matter of returning zero for wavelengths outside of the valid range and indexing into the stored values otherwise.
][
  求给定波长 `lambda` 处的光谱值时，若波长超出有效范围就返回零，否则按索引读取存储的值。
]

#block(sticky: true)[#raw("<<DenselySampledSpectrum Public Methods>>+=") #link(<fragment-DenselySampledSpectrumPublicMethods-0>)[▲]] <fragment-DenselySampledSpectrumPublicMethods-1>
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
  虽然以 1 nm 间隔采样光谱分布对于大多数渲染用途来说具有足够的精度，但这样做需要近 2 kB 的内存来存储覆盖可见波长的分布。`PiecewiseLinearSpectrum` 提供了另一种通常更紧凑的表示；其分布由一组值对 $(lambda_i , v_i)$ 指定，其中光谱分布通过在它们之间进行线性插值来定义；参见@fig:piecewise-linear-spectrum。对于在某些区域平滑而在其他区域快速变化的光谱，这种表示使得可以在变化最大的区域更密集地给出样本值。
]

#block(sticky: true)[#raw("<<Spectrum Definitions>>+=") #link(<fragment-SpectrumDefinitions-1>)[▲] #link(<fragment-SpectrumDefinitions-3>)[▼]] <fragment-SpectrumDefinitions-2>
```cpp
class PiecewiseLinearSpectrum {
  public:
    <<PiecewiseLinearSpectrum Public Methods>>
  private:
    <<PiecewiseLinearSpectrum Private Members>>
};
``` <PiecewiseLinearSpectrum>

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

#block(sticky: true)[#raw("<<PiecewiseLinearSpectrum Public Methods>>=")] <fragment-PiecewiseLinearSpectrumPublicMethods-0>
```cpp
PiecewiseLinearSpectrum(pstd::span<const Float> lambdas,
    pstd::span<const Float> values, Allocator alloc = {});
```

#block(sticky: true)[#raw("<<PiecewiseLinearSpectrum Private Members>>=")] <fragment-PiecewiseLinearSpectrumPrivateMembers-0>
```cpp
pstd::vector<Float> lambdas, values;
```


#parec[
  Finding the value for a given wavelength requires first finding the pair of values in the `lambdas` array that bracket it and then linearly interpolating between them.
][
  要找到给定波长的值，首先需要在 `lambdas` 数组中找到将其括住的值对，然后在它们之间进行线性插值。
]

#block(sticky: true)[#raw("<<Spectrum Method Definitions>>=") #link(<fragment-SpectrumMethodDefinitions-1>)[▼]] <fragment-SpectrumMethodDefinitions-0>
```cpp
Float PiecewiseLinearSpectrum::operator()(Float lambda) const {
    <<Handle PiecewiseLinearSpectrum corner cases>>
    <<Find offset to largest lambdas below lambda and interpolate>>
}
```


#parec[
  As with #link(<DenselySampledSpectrum>)[`DenselySampledSpectrum`], wavelengths outside of the specified range are given a value of zero.
][
  与 #link(<DenselySampledSpectrum>)[`DenselySampledSpectrum`] 一样，超出指定范围的波长被赋予零值。
]

#block(sticky: true)[#raw("<<Handle PiecewiseLinearSpectrum corner cases>>=")] <fragment-HandlemonoPiecewiseLinearSpectrumcornercases-0>
```cpp
if (lambdas.empty() || lambda < lambdas.front() || lambda > lambdas.back())
    return 0;
```


#parec[
  If `lambda` is in range, then #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#FindInterval")[`FindInterval()`] gives the offset to the largest value of `lambdas` that is less than or equal to `lambda`. In turn, `lambda`'s offset between that wavelength and the next gives the linear interpolation parameter to use with the stored values.
][
  如果 `lambda` 在范围内，则 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#FindInterval")[`FindInterval()`] 返回 `lambdas` 中小于或等于 `lambda` 的最大元素的索引。反过来，`lambda` 在该波长和下一个波长之间的偏移量给出了用于存储值的线性插值参数。
]

#block(sticky: true)[#raw("<<Find offset to largest lambdas below lambda and interpolate>>=")] <fragment-Findoffsettolargestmonolambdasbelowmonolambdaandinterpolate-0>
```cpp
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

#block(sticky: true)[#raw("<<Spectrum Method Definitions>>+=") #link(<fragment-SpectrumMethodDefinitions-0>)[▲] #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragment-SpectrumMethodDefinitions-2")[▼]] <fragment-SpectrumMethodDefinitions-1>
```cpp
Float PiecewiseLinearSpectrum::MaxValue() const {
    if (values.empty()) return 0;
    return *std::max_element(values.begin(), values.end());
}
```

#parec[
  Another useful #link(<Spectrum>)[`Spectrum`] implementation, `BlackbodySpectrum`, gives the spectral distribution of a blackbody emitter at a specified temperature.
][
  另一个有用的 #link(<Spectrum>)[`Spectrum`] 实现，`BlackbodySpectrum`，给出了在指定温度下黑体辐射体的光谱分布。
]

#block(sticky: true)[#raw("<<Spectrum Definitions>>+=") #link(<fragment-SpectrumDefinitions-2>)[▲] #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragment-SpectrumDefinitions-4")[▼]] <fragment-SpectrumDefinitions-3>
```cpp
class BlackbodySpectrum {
  public:
    <<BlackbodySpectrum Public Methods>>
  private:
    <<BlackbodySpectrum Private Members>>
};
``` <BlackbodySpectrum>


#parec[
  The temperature of the blackbody in Kelvin is the constructor's only parameter.
][
  黑体的温度（以开尔文为单位）是构造函数的唯一参数。
]

#block(sticky: true)[#raw("<<BlackbodySpectrum Public Methods>>=") #link(<fragment-BlackbodySpectrumPublicMethods-1>)[▼]] <fragment-BlackbodySpectrumPublicMethods-0>
```cpp
BlackbodySpectrum(Float T) : T(T) {
    <<Compute blackbody normalization constant for given temperature>>
}
```

#block(sticky: true)[#raw("<<BlackbodySpectrum Private Members>>=") #link(<fragment-BlackbodySpectrumPrivateMembers-1>)[▼]] <fragment-BlackbodySpectrumPrivateMembers-0>
```cpp
Float T;
```

// https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Light_Emission.html#eq:stefan-boltzmann
#parec[
  Because the power emitted by a blackbody grows so quickly with temperature (recall the Stefan–Boltzmann law, @eqt:stefan-boltzmann), the #link(<BlackbodySpectrum>)[`BlackbodySpectrum`] represents a normalized blackbody spectral distribution where the maximum value at any wavelength is 1. Wien's displacement law, @eqt:wien-displacement, gives the wavelength in meters where emitted radiance is at its maximum; we must convert this value to nm before calling `Blackbody()` to find the corresponding radiance value.
][
  由于黑体辐射的功率随着温度迅速增长（回忆斯特藩-玻尔兹曼定律，@eqt:stefan-boltzmann），#link(<BlackbodySpectrum>)[`BlackbodySpectrum`] 表示一个归一化的黑体光谱分布，其在所有波长上的最大值为 1。维恩位移定律（@eqt:wien-displacement）给出了发射辐亮度达到最大值的波长（以米为单位）；在调用 `Blackbody()` 以找到相应的辐亮度值之前，我们必须将此值转换为 nm。
]

#block(sticky: true)[#raw("<<Compute blackbody normalization constant for given temperature>>=")] <fragment-Computeblackbodynormalizationconstantforgiventemperature-0>
```cpp
Float lambdaMax = 2.8977721e-3f / T;
normalizationFactor = 1 / Blackbody(lambdaMax * 1e9f, T);
```


#block(sticky: true)[#raw("<<BlackbodySpectrum Private Members>>+=") #link(<fragment-BlackbodySpectrumPrivateMembers-0>)[▲]] <fragment-BlackbodySpectrumPrivateMembers-1>
```cpp
Float normalizationFactor;
```


#parec[
  The method that returns the value of the distribution at a wavelength then returns the product of the value returned by `Blackbody()` and the normalization factor.
][
  返回在某个波长处分布值的方法将 `Blackbody()` 的结果乘以归一化因子后返回。
]

#block(sticky: true)[#raw("<<BlackbodySpectrum Public Methods>>+=") #link(<fragment-BlackbodySpectrumPublicMethods-0>)[▲]] <fragment-BlackbodySpectrumPublicMethods-1>
```cpp
Float operator()(Float lambda) const {
    return Blackbody(lambda, T) * normalizationFactor;
}
```


=== #ez_caption[Embedded Spectral Data][内置光谱数据]
<embedded-spectral-data>
#parec[
  `pbrt`'s scene description format provides multiple ways to specify spectral data, ranging from blackbody temperatures to arrays of $lambda$ -value pairs to specify a piecewise-linear spectrum. For convenience, a variety of useful spectral distributions are also embedded directly in the `pbrt` binary, including ones that describe the emission profiles of various types of light source, the scattering properties of various conductors, and the wavelength-dependent indices of refraction of various types of glass. See the online `pbrt` file format documentation for a list of all of them.
][
  `pbrt`的场景描述格式提供了多种指定光谱数据的方法，从黑体温度到“波长 $lambda$—光谱值”数对数组，用于指定分段线性光谱。为了方便使用，各种有用的光谱分布也直接嵌入在`pbrt`二进制文件中，包括描述各种光源发射特性的光谱、各种导体的散射特性以及各种玻璃的波长依赖折射率的光谱。请参阅`pbrt`文件格式文档以获取它们的完整列表。
]

#parec[
  The `GetNamedSpectrum()` function searches through these spectra and returns a #link(<Spectrum>)[Spectrum] corresponding to a given named spectrum if it is available.
][
  `GetNamedSpectrum()` 函数在这些光谱中搜索，并返回与给定命名光谱对应的#link(<Spectrum>)[`Spectrum`]，如果该光谱可用的话。
]

#block(sticky: true)[#raw("<<Spectral Function Declarations>>=") #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragment-SpectralFunctionDeclarations-1")[▼]] <fragment-SpectralFunctionDeclarations-0>
```cpp
Spectrum GetNamedSpectrum(std::string name);
```

#parec[
  A number of important spectra are made available directly through corresponding functions, all of which are in a `Spectra` namespace. Among them are `Spectra::X()`, `Spectra::Y()`, and `Spectra::Z()`, which return the color matching curves that are described in @xyz-color, and `Spectra::D()`, which returns a #link(<DenselySampledSpectrum>)[DenselySampledSpectrum] representing the D illuminant at the given temperature.
][
  一些重要的光谱通过相应的函数直接提供，所有这些函数都在 `Spectra` 命名空间中。其中包括`Spectra::X()`、`Spectra::Y()`和`Spectra::Z()`，它们返回如@xyz-color 中所述的颜色匹配曲线，以及`Spectra::D()`，它返回一个表示给定温度下D 照明体的#link(<DenselySampledSpectrum>)[DenselySampledSpectrum]。
]

#block(sticky: true)[#raw("<<Spectrum Function Declarations>>+=") #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Light_Emission.html#fragment-SpectrumFunctionDeclarations-0")[▲]] <fragment-SpectrumFunctionDeclarations-1>
```cpp
DenselySampledSpectrum D(Float T, Allocator alloc);
```


=== #ez_caption[Sampled Spectral Distributions][采样光谱分布]
<sampled-spectral-distributions>
#parec[
  The attentive reader may have noticed that although #link(<Spectrum>)[Spectrum] makes it possible to evaluate spectral distribution functions, it does not provide the ability to do very much computation with them other than sampling their value at a specified wavelength. Yet, for example, evaluating the integrand of the reflection equation, (@eqt:scattering-equation), requires taking the product of two spectral distributions, one for the BSDF and one for the incident radiance function.
][
  细心的读者可能已经注意到，虽然#link(<Spectrum>)[`Spectrum`] 使得对光谱分布函数求值成为可能，但它除了在指定波长处采样其值之外，并未提供多少其他计算功能。然而，例如，要计算反射方程的被积函数（@eqt:scattering-equation）需要将两个光谱分布相乘，一个用于 BSDF，一个用于入射辐亮度函数。
]

#parec[
  Providing this functionality with the abstractions that have been introduced so far would quickly become unwieldy. For example, while the product of two #link(<DenselySampledSpectrum>)[DenselySampledSpectrum]s could be faithfully represented by another #link(<DenselySampledSpectrum>)[DenselySampledSpectrum], consider taking the product of two #link(<PiecewiseLinearSpectrum>)[PiecewiseLinearSpectrum]s: the resulting function would be piecewise-quadratic and subsequent products would only increase its degree. Further, operations between `Spectrum` implementations of different types would not only require a custom implementation for each pair, but would require choosing a suitable `Spectrum` representation for each result.
][
  使用目前为止引入的抽象来提供此功能将很快变得繁琐。例如，虽然两个#link(<DenselySampledSpectrum>)[DenselySampledSpectrum] 的乘积可以通过另一个#link(<DenselySampledSpectrum>)[DenselySampledSpectrum]准确地表示，但考虑两个#link(<PiecewiseLinearSpectrum>)[PiecewiseLinearSpectrum] 的乘积：结果函数将是分段二次的，后续的乘积只会增加其次数。此外，不同类型的`Spectrum`实现之间的运算不仅需要为每对实现自定义实现，还需要为每个结果选择合适的`Spectrum`表示。
]

#parec[
  `pbrt` avoids this complexity by performing spectral calculations at a set of discrete wavelengths as part of the Monte Carlo integration that is already being performed for image synthesis. To understand how this works, consider computing the (non-spectral) irradiance at some point $p$ with surface normal $upright(bold(n))$ over some range of wavelengths of interest, $[lambda_0 , lambda_1]$. Using @eqt:irradiance-from-radiance, which expresses irradiance in terms of incident radiance, and @eqt:radiance-from-spectral, which expresses radiance in terms of spectral radiance, we have
][
  `pbrt`通过在一组离散波长上执行光谱计算来避免这种复杂性，这也是图像合成中已经执行的蒙特卡洛积分的一部分。为了理解其工作原理，考虑在某点 $p$ 处具有表面法向量 $upright(bold(n))$ 的某些感兴趣波长范围 $[lambda_0 , lambda_1]$ 上的（非光谱）辐照度的计算。使用表达辐照度与入射辐亮度之间关系的方程（@eqt:irradiance-from-radiance）和表达辐亮度与光谱辐亮度之间关系的方程（@eqt:radiance-from-spectral），我们有
]

$
  E = integral_Omega integral_(lambda_0)^(lambda_1) L_(i) (
    p , omega , lambda
  ) lr(|cos theta|) thin d omega thin d lambda ,
$


#parec[
  where $L_(i) (p , omega , lambda)$ is the incident spectral radiance at wavelength $lambda$.
][
  其中 $L_(i) (p , omega , lambda)$ 是波长 $lambda$ 处的入射光谱辐亮度。
]

#parec[
  Applying the standard Monte Carlo estimator and taking advantage of the fact that $omega$ and $lambda$ are independent, we can see that estimates of $E$ can be computed by sampling directions $omega_i$ from some distribution $p_(omega)$, wavelengths $lambda_i$ from some distribution $p_(lambda)$, and then evaluating:
][
  应用标准蒙特卡洛估计量并利用 $omega$ 和 $lambda$ 是独立的这一事实，我们可以看到 $E$ 的估计可以通过从某个分布 $p_(omega)$ 中采样方向 $omega_i$，从某个分布 $p_(lambda)$ 中采样波长 $lambda_i$，然后计算下式：
]

$
  E approx 1 / n sum_(i = 1)^n frac(L_(i) (p , omega_i , lambda_i) lr(|cos theta_i|), p_(omega) (omega_i) p_(lambda) (lambda_i)) .
$ <irradiance-from-spectral-radiance-estimate>

#parec[
  Thus, we only need to be able to evaluate the integrand at the specified discrete wavelengths to estimate the irradiance. More generally, we will see that it is possible to express all the spectral quantities that `pbrt` outputs as integrals over wavelength. For example, @color shows that when rendering an image represented using RGB colors, each pixel's color can be computed by integrating the spectral radiance arriving at a pixel with functions that model red, green, and blue color response. `pbrt` therefore uses only discrete spectral samples for spectral computation.
][
  因此，我们只需要能够在指定的离散波长处计算被积函数的值即可估计辐照度。更一般地，我们将看到，可以将`pbrt`输出的所有光谱量表示为波长上的积分。例如，@color 显示，当使用RGB颜色表示渲染图像时，每个像素的颜色可以通过将到达像素的光谱辐亮度分别乘以模拟红、绿、蓝颜色响应的函数后，对波长积分来计算。因此，`pbrt`仅使用离散光谱样本进行光谱计算。
]

#parec[
  So that we can proceed to the implementation of the classes related to sampling spectra and performing computations with spectral samples, we will define the constant that sets the number of spectral samples here. (@choosing-the-number-of-wavelength-samples will discuss in more detail the trade-offs involved in choosing this value.) `pbrt` uses 4 wavelength samples by default; this value can easily be changed, though doing so requires recompiling the system.
][
  为了能够继续实现与采样光谱和光谱样本计算相关的类，我们将在此定义设置光谱样本数量的常量。（@choosing-the-number-of-wavelength-samples 将更详细地讨论选择此值时涉及的权衡。）`pbrt`默认使用4个波长样本；此值可以轻松地更改，但这样做需要重新编译系统。
]

#block(sticky: true)[#raw("<<Spectrum Constants>>+=") #link(<fragment-SpectrumConstants-0>)[▲] #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragment-SpectrumConstants-2")[▼]] <fragment-SpectrumConstants-1>
```cpp
static constexpr int NSpectrumSamples = 4;
``` <NSpectrumSamples>



==== #ez_caption[SampledSpectrum][SampledSpectrum]
<sampledspectrum>
#parec[
  The `SampledSpectrum` class stores an array of `NSpectrumSamples` values that represent values of the spectral distribution at discrete wavelengths. It provides methods that allow a variety of mathematical operations to be performed with them.
][
  `SampledSpectrum` 类存储了一个包含 `NSpectrumSamples` 个值的数组，这些值表示在离散波长下的光谱分布值。它提供了多种对这些值进行数学运算的方法。
]

#block(sticky: true)[#raw("<<SampledSpectrum Definition>>=")] <fragment-SampledSpectrumDefinition-0>
```cpp
class SampledSpectrum {
  public:
    <<SampledSpectrum Public Methods>>
  private:
    pstd::array<Float, NSpectrumSamples> values;
};
``` <SampledSpectrum>

#parec[
  Its constructors include one that allows providing a single value for all wavelengths and one that takes an appropriately sized `pstd::span` of per-wavelength values.
][
  其构造函数包括一个可以为所有波长设置相同值的构造函数，以及一个接受长度适当、包含各波长处数值的 `pstd::span` 的构造函数。
]

#block(sticky: true)[#raw("<<SampledSpectrum Public Methods>>=") #link(<fragment-SampledSpectrumPublicMethods-1>)[▼]] <fragment-SampledSpectrumPublicMethods-0>
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

#block(sticky: true)[#raw("<<SampledSpectrum Public Methods>>+=") #link(<fragment-SampledSpectrumPublicMethods-0>)[▲] #link(<fragment-SampledSpectrumPublicMethods-2>)[▼]] <fragment-SampledSpectrumPublicMethods-1>
```cpp
Float operator[](int i) const { return values[i]; }
Float &operator[](int i) { return values[i]; }
```


#parec[
  It is often useful to know if all the values in a `SampledSpectrum` are zero. For example, if a surface has zero reflectance, then the light transport routines can avoid the computational cost of casting reflection rays that have contributions that would eventually be multiplied by zeros. This capability is provided through a type conversion operator to `bool`.#footnote[C++ arcana: the `explicit` qualifier ensures that a `SampledSpectrum` is not unintentionally passed as a `bool` argument to a function without an explicit cast. However, if a `SampledSpectrum` is used as the condition in an “if” test, it is still automatically converted to a Boolean value without a cast.]
][
  通常需要知道 `SampledSpectrum` 中的所有值是否为零。例如，如果一个表面的反射率为零，那么光传输程序可以避免投射反射光线的计算成本，因为这些光线的贡献最终会被乘以零。这一功能通过转换为 `bool` 的类型转换运算符提供。#footnote[C++ 细节：`explicit` 限定符可防止 `SampledSpectrum` 在没有显式转换时，被无意地作为 `bool` 参数传入函数。但将它用作 `if` 的条件时，仍会自动转换为布尔值，无需显式转换。]
]

#block(sticky: true)[#raw("<<SampledSpectrum Public Methods>>+=") #link(<fragment-SampledSpectrumPublicMethods-1>)[▲] #link(<fragment-SampledSpectrumPublicMethods-3>)[▼]] <fragment-SampledSpectrumPublicMethods-2>
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

#block(sticky: true)[#raw("<<SampledSpectrum Public Methods>>+=") #link(<fragment-SampledSpectrumPublicMethods-2>)[▲]] <fragment-SampledSpectrumPublicMethods-3>
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

#block(sticky: true)[#raw("<<SampledSpectrum Inline Functions>>=")] <fragment-SampledSpectrumInlineFunctions-0>
```cpp
SampledSpectrum SafeDiv(SampledSpectrum a, SampledSpectrum b) {
    SampledSpectrum r;
    for (int i = 0; i < NSpectrumSamples; ++i)
        r[i] = (b[i] != 0) ? a[i] / b[i] : 0.;
    return r;
}
```


#parec[
  In addition to the basic arithmetic operations, `SampledSpectrum` also provides `Lerp()`, `Sqrt()`, `Clamp()`, `ClampZero()`, `Pow()`, `Exp()`, and `FastExp()` functions that operate (again, component-wise) on `SampledSpectrum` objects; some of these operations are necessary for evaluating some of the reflection models in @reflection-models and for evaluating volume scattering models in @light-transport-ii-volume-rendering. Finally, `MinComponentValue()` and `MaxComponentValue()` return the minimum and maximum of all the values, and `Average()` returns their average. These methods are all straightforward and are therefore not included in the text.
][
  除了基本的算术运算，`SampledSpectrum` 还提供了 `Lerp()`、`Sqrt()`、`Clamp()`、`ClampZero()`、`Pow()`、`Exp()` 和 `FastExp()` 函数，这些函数对 `SampledSpectrum` 对象进行（同样是逐个分量的）操作；在@reflection-models 的反射模型计算和@light-transport-ii-volume-rendering 的体积散射模型计算中，其中一些运算是必要的。 最后，`MinComponentValue()` 和 `MaxComponentValue()` 返回所有值的最小值和最大值，而 `Average()` 返回它们的平均值。这些方法都很简单，因此未在文本中详细列出。
]



==== #ez_caption[SampledWavelengths][SampledWavelengths]
<sampledwavelengths>
#parec[
  A separate class, `SampledWavelengths`, stores the wavelengths for which a #link(<SampledSpectrum>)[`SampledSpectrum`] stores samples. Thus, it is important not only to keep careful track of the `SampledWavelengths` that are represented by an individual `SampledSpectrum` but also to not perform any operations that combine `SampledSpectrum`s that have samples at different wavelengths.
][
  一个单独的类，`SampledWavelengths`，存储一个#link(<SampledSpectrum>)[`SampledSpectrum`] 实例对应样本的波长。因此，重要的是不仅要仔细跟踪由单个`SampledSpectrum`表示的`SampledWavelengths`，而且不要执行任何将具有不同波长样本的`SampledSpectrum`组合的操作。
]

#block(sticky: true)[#raw("<<SampledWavelengths Definitions>>=")] <fragment-SampledWavelengthsDefinitions-0>
```cpp
class SampledWavelengths {
  public:
    <<SampledWavelengths Public Methods>>
  private:
    <<SampledWavelengths Private Members>>
};
``` <SampledWavelengths>


#parec[
  To be used in the context of Monte Carlo integration, the wavelengths stored in #link(<SampledWavelengths>)[`SampledWavelengths`] must be sampled from some probability distribution. Therefore, the class stores the wavelengths themselves as well as each one's probability density.
][
  为了在蒙特卡洛积分中使用，存储在#link(<SampledWavelengths>)[`SampledWavelengths`] 中的波长必须是从某个概率分布中采样。因此，该类存储了波长本身以及每个波长的概率密度。
]

#block(sticky: true)[#raw("<<SampledWavelengths Private Members>>=")] <fragment-SampledWavelengthsPrivateMembers-0>
```cpp
pstd::array<Float, NSpectrumSamples> lambda, pdf;
```


#parec[
  The easiest way to sample wavelengths is uniformly over a given range. This approach is implemented in the `SampleUniform()` method, which takes a single uniform sample `u` and a range of wavelengths.
][
  采样波长最简单的方法是在给定范围内进行均匀采样。这个方法在`SampleUniform()`方法中实现，它接受一个均匀样本`u`和一个波长范围。
]

#block(sticky: true)[#raw("<<SampledWavelengths Public Methods>>=") #link(<fragment-SampledWavelengthsPublicMethods-1>)[▼]] <fragment-SampledWavelengthsPublicMethods-0>
```cpp
static SampledWavelengths SampleUniform(Float u,
        Float lambda_min = Lambda_min, Float lambda_max = Lambda_max) {
    SampledWavelengths swl;
    <<Sample first wavelength using u>>
    <<Initialize lambda for remaining wavelengths>>
    <<Compute PDF for sampled wavelengths>>
    return swl;
}
``` <SampledWavelengths::SampleUniform>

#parec[
  It chooses the first wavelength uniformly within the range.
][
  它在给定范围内均匀选取第一个波长。
]

#block(sticky: true)[#raw("<<Sample first wavelength using u>>=")] <fragment-Samplefirstwavelengthusingmonou-0>
```cpp
swl.lambda[0] = Lerp(u, lambda_min, lambda_max);
```


#parec[
  The remaining wavelengths are chosen by taking uniform steps `delta` starting from the first wavelength and wrapping around if `lambda_max` is passed. The result is a set of stratified wavelength samples that are generated using a single random number. One advantage of sampling wavelengths in this way rather than using a separate uniform sample for each one is that the value of #link(<NSpectrumSamples>)[`NSpectrumSamples`] can be changed without requiring the modification of code that calls `SampleUniform()` to adjust the number of sample values that are passed to this method.
][
  其余的波长通过从第一个波长开始以均匀步长`delta`选择，如果超过`lambda_max`则回绕。结果是一组分层的波长样本，这些样本是使用单个随机数生成的。以这种方式采样波长的一个优点是，不需要为每个波长使用单独的均匀样本，这样#link(<NSpectrumSamples>)[`NSpectrumSamples`] 的值可以更改，而不需要修改调用`SampleUniform()`的代码来调整传递给该方法的样本值的数量。
]

#block(sticky: true)[#raw("<<Initialize lambda for remaining wavelengths>>=")] <fragment-Initializemonolambdaforremainingwavelengths-0>
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

#block(sticky: true)[#raw("<<Compute PDF for sampled wavelengths>>=")] <fragment-ComputePDFforsampledwavelengths-0>
```cpp
for (int i = 0; i < NSpectrumSamples; ++i)
    swl.pdf[i] = 1 / (lambda_max - lambda_min);
```


#parec[
  Additional methods provide access to the individual wavelengths and to all of their PDFs. PDF values are returned in the form of a #link(<SampledSpectrum>)[`SampledSpectrum`], which makes it easy to compute the value of associated Monte Carlo estimators.
][
  附加方法提供对各个波长及其所有PDF的访问。PDF值以#link(<SampledSpectrum>)[`SampledSpectrum`] 的形式返回，这使得计算相关蒙特卡洛估计量的值变得容易。
]

#block(sticky: true)[#raw("<<SampledWavelengths Public Methods>>+=") #link(<fragment-SampledWavelengthsPublicMethods-0>)[▲] #link(<fragment-SampledWavelengthsPublicMethods-2>)[▼]] <fragment-SampledWavelengthsPublicMethods-1>
```cpp
Float operator[](int i) const { return lambda[i]; }
Float &operator[](int i) { return lambda[i]; }
SampledSpectrum PDF() const { return SampledSpectrum(pdf); }
```


#parec[
  In some cases, different wavelengths of light may follow different paths after a scattering event. The most common example is when light undergoes dispersion and different wavelengths of light refract to different directions. When this happens, it is no longer possible to track multiple wavelengths of light with a single ray. For this case, #link(<SampledWavelengths>)[`SampledWavelengths`] provides the capability of terminating all but one of the wavelengths; subsequent computations can then consider the single surviving wavelength exclusively.
][
  在某些情况下，不同波长的光在散射后可能会沿不同路径传播。最常见的例子是光发生色散，不同波长的光折射到不同的方向。当这种情况发生时，就不再可能用单一光线跟踪多个波长的光。对于这种情况，#link(<SampledWavelengths>)[`SampledWavelengths`] 提供了终止除一个波长之外的所有波长的功能；随后可以只考虑单个存活的波长进行计算。
]

#block(sticky: true)[#raw("<<SampledWavelengths Public Methods>>+=") #link(<fragment-SampledWavelengthsPublicMethods-1>)[▲] #link(<fragment-SampledWavelengthsPublicMethods-3>)[▼]] <fragment-SampledWavelengthsPublicMethods-2>
```cpp
void TerminateSecondary() {
    if (SecondaryTerminated()) return;
    <<Update wavelength probabilities for termination>>
}
```


#parec[
  The wavelength stored in `lambda[0]` is always the survivor: there is no need to randomly select the surviving wavelength so long as each `lambda` value was randomly sampled from the same distribution as is the case with `SampleUniform()`, for example. Note that this means that it would be incorrect for #link(<SampledWavelengths::SampleUniform>)[`SampledWavelengths::SampleUniform`] to always place `lambda[0]` in a first wavelength stratum between `lambda_min` and `lambda_min+delta`, `lambda[1]` in the second, and so forth.#footnote[This mistake is one of the bugs that the authors encountered during the initial development of this functionality in `pbrt`.]
][
  存储在`lambda[0]`中的波长始终是保留下来的波长：只要每个`lambda`值都是从相同的分布中随机采样的，就不需要随机选择保留的波长，例如`SampleUniform()`就是这种情况。请注意，这意味着#link(<SampledWavelengths::SampleUniform>)[`SampledWavelengths::SampleUniform`]将`lambda[0]`始终放在`lambda_min`和`lambda_min+delta`之间的第一个波长层中，`lambda[1]`放在第二个波长层中，依此类推是错误的。#footnote[作者在最初开发 `pbrt` 的这一功能时，就曾遇到过这个错误。]
]

#parec[
  Terminated wavelengths have their PDF values set to zero; code that computes Monte Carlo estimates using `SampledWavelengths` must therefore detect this case and ignore terminated wavelengths accordingly. The surviving wavelength's PDF is updated to account for the termination event by multiplying it by the probability of a wavelength surviving termination, $1 \/ upright("NSpectrumSamples")$. (This is similar to how applying Russian roulette affects the Monte Carlo estimator—see @russian-roulette .)
][
  终止的波长将其PDF值设置为零；使用`SampledWavelengths`计算蒙特卡洛估计的代码因此必须检测这种情况并相应地忽略终止的波长。将保留波长的 PDF 乘以其在终止操作中被保留的概率 $1 \/ upright("NSpectrumSamples")$ 来更新保留波长的PDF。（这类似于如何应用俄罗斯轮盘赌影响蒙特卡洛估计量——参见@russian-roulette ）
]

#block(sticky: true)[#raw("<<Update wavelength probabilities for termination>>=")] <fragment-Updatewavelengthprobabilitiesfortermination-0>
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

#block(sticky: true)[#raw("<<SampledWavelengths Public Methods>>+=") #link(<fragment-SampledWavelengthsPublicMethods-2>)[▲] #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/../Cameras_and_Film/Film_and_Imaging.html#fragment-SampledWavelengthsPublicMethods-4")[▼]] <fragment-SampledWavelengthsPublicMethods-3>
```cpp
bool SecondaryTerminated() const {
    for (int i = 1; i < NSpectrumSamples; ++i)
        if (pdf[i] != 0)
            return false;
    return true;
}
```


#parec[
  We will often have a #link(<Spectrum>)[`Spectrum`] and a set of wavelengths for which we would like to evaluate it. Therefore, we will add a method to the #link(<Spectrum>)[`Spectrum`] interface that provides a `Sample()` method that takes a set of wavelengths, evaluates its spectral distribution function at each one, and returns a #link(<SampledSpectrum>)[`SampledSpectrum`]. This convenience method eliminates the need for an explicit loop over wavelengths with individual calls to #link(<Spectrum::operator>)[`Spectrum::operator()`] in this common case. The implementations of this method are straightforward and not included here.
][
  我们经常会有一个#link(<Spectrum>)[`Spectrum`] 和一组我们希望评估的波长。因此，我们将在#link(<Spectrum>)[`Spectrum`]接口中添加一个`Sample()`方法，该方法接受一组波长，在每个波长上评估其光谱分布函数，并返回一个#link(<SampledSpectrum>)[`SampledSpectrum`]。这个便利的方法消除了在这种常见情况下需要通过单独调用#link(<Spectrum::operator>)[`Spectrum::operator()`]进行显式波长循环的需求。该方法的实现很简单，这里不再列出。
]

#block(sticky: true)[#raw("<<Spectrum Interface>>+=") #link(<fragment-SpectrumInterface-1>)[▲]] <fragment-SpectrumInterface-2>
```cpp
SampledSpectrum Sample(const SampledWavelengths &lambda) const;
```


==== #ez_caption[Discussion][讨论]
<discussion>
#parec[
  Now that #link(<SampledWavelengths>)[`SampledWavelengths`] and #link(<SampledSpectrum>)[`SampledSpectrum`] have been introduced, it is reasonable to ask the question: why are they separate classes, rather than a single class that stores both wavelengths and their sample values? Indeed, an advantage of such a design would be that it would be possible to detect at runtime if an operation was performed with two #link(<SampledSpectrum>)[`SampledSpectrum`] instances that stored values for different wavelengths—such an operation is nonsensical and would signify a bug in the system.
][
  现在已经介绍了#link(<SampledWavelengths>)[`SampledWavelengths`] 和#link(<SampledSpectrum>)[`SampledSpectrum`]，合理的问题是：为什么它们是单独的类，而不是一个同时存储波长及其样本值的类？实际上，这种设计的一个优点是可以在运行时检测是否对存储不同波长值的两个#link(<SampledSpectrum>)[`SampledSpectrum`] 实例执行了操作——这种操作是无意义的，并且表示系统中的一个错误。
]

#parec[
  However, in practice many #link(<SampledSpectrum>)[`SampledSpectrum`] objects are created during rendering, many as temporary values in the course of evaluating expressions involving spectral computation. It is therefore worthwhile to minimize the object's size, if only to avoid initialization and copying of additional data. While the `pbrt`'s CPU-based integrators do not store many #link(<SampledSpectrum>)[`SampledSpectrum`] values in memory at the same time, the GPU rendering path stores a few million of them, giving further motivation to minimize their size.
][
  然而，在实践中，许多#link(<SampledSpectrum>)[`SampledSpectrum`]对象是在渲染过程中创建的，许多是在评估涉及光谱计算的表达式过程中作为临时值创建的。因此，值得最小化对象的大小，即使只是为了避免初始化和复制额外的数据。虽然`pbrt`的基于CPU的积分器不会在内存中同时存储许多#link(<SampledSpectrum>)[`SampledSpectrum`]值，但GPU渲染路径存储了几百万个，这促使进一步优化它们的大小。
]

#parec[
  Our experience has been that bugs from mixing computations at different wavelengths have been rare. With the way that computation is structured in `pbrt`, wavelengths are generally sampled at the start of following a ray's path through the scene, and then the same wavelengths are used throughout for all spectral calculations along the path. There ends up being little opportunity for inadvertent mingling of sampled wavelengths in #link(<SampledSpectrum>)[`SampledSpectrum`] instances. Indeed, in an earlier version of the system, #link(<SampledSpectrum>)[`SampledSpectrum`] did carry along a #link(<SampledWavelengths>)[`SampledWavelengths`] member variable in debug builds in order to be able to check for that case. It was eliminated in the interests of simplicity after a few months' existence without finding a bug.
][
  我们的经验是，不同波长下混合计算的错误很少发生。由于在`pbrt`中计算的结构，波长通常是在跟踪光线路径的开始时采样的，然后在路径上的所有光谱计算中使用相同的波长。最终，在#link(<SampledSpectrum>)[`SampledSpectrum`] 实例中无意中混合采样波长的机会很少。实际上，在系统的早期版本中，#link(<SampledSpectrum>)[`SampledSpectrum`]确实在调试版本中携带了一个#link(<SampledWavelengths>)[`SampledWavelengths`]成员变量，以便能够检查这种情况。这项检查保留了几个月，却未发现错误，后来为简化系统而删除。
]


#heading(level: 3, numbering: none)[#ez_caption[Supplement: Additional Code in the Original Collapsed Panels][补充：原网页折叠面板中的额外代码]]
#include "supplements/4.5-expanded.typ"
