#import "../template.typ": parec, ez_caption

== Color
<color>
#parec[
  "Spectral distribution" and "color" might seem like two names for the same thing, but they are distinct. A spectral distribution is a purely physical concept, while color describes the human perception of a spectrum. Color is thus closely connected to the physiology of the human visual system and the brain's processing of visual stimulus.
][
  "光谱分布"和“颜色”似乎是同一事物的两个名称，但它们是不同的。光谱分布是一个纯粹的物理概念，而颜色描述了人类对光谱的感知。因此，颜色与人类视觉系统的生理学和大脑对视觉刺激的处理密切相关。
]

#parec[
  Although the majority of rendering computation in `pbrt` is based on spectral distributions, color still must be treated carefully. For example, the spectral distribution at each pixel in a rendered image must be converted to RGB color to be displayed on a monitor. Performing this conversion accurately requires using information about the monitor's color characteristics. The renderer also finds color in scene descriptions that use it to describe reflectance and light emission. Although it is convenient for humans to use colors to describe the appearance of modeled scenes, these colors must be converted to spectra if a renderer uses spectral distributions in its light transport simulation. Unfortunately, doing so is an underspecified problem. A variety of approaches have been developed for it; the one implemented in `pbrt` is described in @from-rgb-to-specturm.
][
  尽管 `pbrt` 中的大多数渲染计算是基于光谱分布的，但仍然必须仔细处理颜色。例如，渲染图像中每个像素的光谱分布必须转换为 RGB 颜色（红绿蓝颜色），以便在显示器上显示。准确执行此转换需要使用有关显示器颜色特性的相关信息。渲染器还会在场景描述中找到颜色，用于描述反射和发光。 虽然人类使用颜色来描述建模场景的外观很方便，但如果渲染器在光传输模拟中需要使用光谱分布，则这些颜色必须转换为光谱。不幸的是，这样做是一个未充分明确的问题。为此已经开发了多种方法；`pbrt` 中实现的方法在 @from-rgb-to-specturm 中描述。
]


#parec[
  The #emph[tristimulus theory] of color perception says that all visible spectral distributions can be accurately represented for human observers using three scalar values. Its basis is that there are three types of photoreceptive cone cells in the eye, each sensitive to different wavelengths of light. This theory, which has been tested in numerous experiments since its introduction in the 1800s, has led to the development of #emph[spectral
matching functions];, which are functions of wavelength that can be used to compute a tristimulus representation of a spectral distribution.
][
  颜色感知的#emph[三刺激理论];（颜色感知的理论）表明，所有可见光谱分布都可以使用三个标量值准确表示给人类观察者。其基础是眼睛中有三种类型的感光锥细胞，每种细胞对不同波长的光敏感。 自19世纪引入以来，该理论已在众多实验中得到验证，并导致了#emph[光谱匹配函数];的发展，这些函数是波长的函数，可用于计算光谱分布的三刺激表示。
]

#parec[
  Integrating the product of a spectral distribution $S (lambda)$ with three tristimulus matching functions $m_({ 1 , 2 , 3 }) (lambda)$ gives three #emph[tristimulus values] $v_i$ :
][
  将光谱分布 $S (lambda)$ 与三个三刺激匹配函数 $m_({ 1 , 2 , 3 }) (lambda)$ 的乘积进行积分，得到三个#emph[三刺激值] $v_i$ ：
]

$ v_i = integral S (lambda) m_i (lambda) thin d lambda . $
#parec[
  The matching functions thus define a #emph[color space];, which is a 3D vector space of the tristimulus values: the tristimulus values for the sum of two spectra are given by the sum of their tristimulus values and the tristimulus values associated with a spectrum that has been scaled by a constant can be found by scaling the tristimulus values by the same factor. Note that from these definitions, the tristimulus values for the product of two spectral distributions are #emph[not] given by the product of their tristimulus values. This nit is why using tristimulus color like RGB for rendering may not give accurate results; we will say more about this topic in @from-rgb-to-specturm .
][
  匹配函数因此定义了一个#emph[颜色空间];，这是一个三维向量空间的三刺激值：两个光谱之和的三刺激值由它们的三刺激值之和给出，并且通过常数缩放的光谱的三刺激值可以通过相同因子缩放三刺激值来找到。 请注意，根据这些定义，两个光谱分布的乘积的三刺激值#emph[不是];由它们的三刺激值的乘积给出的。 这就是为什么使用像 RGB 这样的三刺激颜色进行渲染可能不会给出准确结果的原因；我们将在@from-rgb-to-specturm 中对此主题进行更多讨论。
]

#parec[
  The files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/color.h")[`util/color.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/color.cpp")[`util/color.cpp`] in the `pbrt` distribution contain the implementation of the functionality related to color that is introduced in this section.
][
  `pbrt` 分发中的文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/color.h")[`util/color.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/color.cpp")[`util/color.cpp`] 包含本节中介绍的与颜色相关的功能的实现。
]

=== XYZ Color
<xyz-color>


#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f18.svg"),
  caption: [
    #ez_caption[*The XYZ Color Matching Curves.*
      A given spectral distribution can be converted to XYZ by multiplying it
      by each of the three matching curves and integrating the result to
      compute the values $x_lambda$, $y_lambda$, and $z_lambda$, using
      @eqt:xyz-matching.][*XYZ颜色匹配曲线。*
      给定的光谱分布可以通过将其与三个匹配曲线相乘并积分结果来计算
      $x_lambda$、$y_lambda$ 和 $z_lambda$ 的值，从而转换为 XYZ，使用@eqt:xyz-matching。]
  ],
)<cie-xyz>

#parec[
  An important set of color matching functions were determined by the Commission Internationale de l'Éclairage (CIE) standards body after a series of experiments with human test subjects.
][
  国际照明委员会（CIE）标准机构在一系列人类测试对象实验后确定了一组重要的颜色匹配函数。
]

#parec[
  They define the #emph[XYZ color space] and are graphed in @fig:cie-xyz. XYZ is a #emph[device-independent] color space, which means that it does not describe the characteristics of a particular display or color measurement device.
][
  它们定义了#emph[XYZ 颜色空间];（用于颜色表示的数学空间），如@fig:cie-xyz 所示。XYZ 是一个#emph[设备无关];的颜色空间，这意味着它不描述特定显示器或颜色测量设备的特性。
]

#parec[
  Given a spectral distribution $S (lambda)$, its XYZ color space coordinates $x_lambda$, $y_lambda$, and $z_lambda$ are computed by integrating its product with the $X (lambda)$, $Y (lambda)$, and $Z (lambda)$ spectral matching curves:#footnote[A variety of conventions are used to define these integrals, sometimes with other or no normalization actors.  For use in `pbrt`, the normalization by one over the integral of the $Y$ matching curve is convenient, as it causes a spectral distribution with a constant value of 1 to have $y_lambda = 1$.]
][
  给定光谱分布 $S (lambda)$，其 XYZ 颜色空间坐标 $x_lambda$ 、 $y_lambda$ 和 $z_lambda$ 是通过将其与 $X (lambda)$ 、 $Y (lambda)$ 和 $Z (lambda)$ 光谱匹配曲线的乘积积分来计算的：#footnote[使用各种约定来定义这些积分，有时使用其他归一化因子或没有归一化因子。对于`pbrt`中的使用，在$Y$匹配曲线的积分上归一化1是方便的，因为它会使常数值为1的光谱分布具有$y_lambda = 1$。]
]

$
  x_lambda & = frac(1, integral Y (lambda) thin d lambda) integral S (lambda) X (lambda) thin d lambda ,\
  y_lambda & = frac(1, integral Y (lambda) thin d lambda) integral S (lambda) Y (lambda) thin d lambda ,\
  z_lambda & = frac(1, integral Y (lambda) thin d lambda) integral S (lambda) Z (lambda) thin d lambda .
$ <xyz-matching>


#parec[
  The CIE $Y (lambda)$ tristimulus curve was chosen to be proportional to the $V (lambda)$ spectral response curve used to define photometric quantities such as luminance in @eqt:luminance .
][
  CIE $Y(lambda)$ 三刺激值曲线被选择为与 $V(lambda)$ 光谱响应曲线成正比， $V(lambda)$ 被用于定义诸如在@eqt:luminance 中的亮度等光度量。
]

#parec[
  Remarkably, spectra with substantially different distributions may have very similar $x_lambda$, $y_lambda$, and $z_lambda$ values. To the human observer, such spectra appear the same. Pairs of such spectra are called #emph[metamers];.
][
  值得注意的是，具有显著不同分布的光谱可能具有非常相似的 $x_lambda$ 、 $y_lambda$ 和 $z_lambda$ 值。对于人类观察者来说，这样的光谱看起来是相同的。这种光谱对称为#emph[同色异谱];（视觉上相同但光谱不同的光）。
]

#parec[
  @fig:xyz-3d-curve shows a 3D plot of the curve in the XYZ space corresponding to the XYZ coefficients for single wavelengths of light over the visible range. The coefficients for more complex spectral distributions therefore correspond to linear combinations of points along this curve. Although all spectral distributions can be represented with XYZ coefficients, not all values of XYZ coefficients correspond to realizable spectra; such sets of coefficients are termed #emph[imaginary colors];.
][
  @fig:xyz-3d-curve 显示了对应于可见范围内单个波长光的 XYZ 系数（用于表示颜色的数值）的 XYZ 空间中的曲线的三维图。 更复杂光谱分布的系数因此对应于沿此曲线的点的线性组合。虽然所有光谱分布都可以用 XYZ 系数表示，但并非所有 XYZ 系数值都对应于可实现的光谱；这样的系数集称为#emph[虚色];（不可实现的颜色）。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f19.svg"),
  caption: [
    #ez_caption[Plot of XYZ color coefficients for the wavelengths of light in the visible range. The curve is shaded with the RGB color associated with each wavelength.][可见光波长的XYZ颜色系数图曲线。使用与每个波长相关联的RGB颜色进行着色。]
  ],
)<xyz-3d-curve>

#parec[
  Three functions in the `Spectra` namespace provide the CIE XYZ matching curves sampled at 1-nm increments from 360 nm to 830 nm.
][
  `Spectra` 命名空间中的三个函数提供了以 1 纳米增量从 360 纳米到 830 纳米采样的 CIE XYZ 匹配曲线。
]

```cpp
namespace Spectra {
    const DenselySampledSpectrum &X();
    const DenselySampledSpectrum &Y();
    const DenselySampledSpectrum &Z();
}
```

#parec[
  The integral of $Y (lambda)$ is precomputed and available in a constant.
][
  $Y (lambda)$ 的积分是预先计算的，并以常量形式提供。
]

```cpp
static constexpr Float CIE_Y_integral = 106.856895;
```


#parec[
  There is also an `XYZ` class that represents XYZ colors.
][
  还有一个表示 XYZ 颜色的 `XYZ` 类。
]

```cpp
class XYZ {
  public:
    XYZ(Float X, Float Y, Float Z) : X(X), Y(Y), Z(Z) {}
    Float Average() const { return (X + Y + Z) / 3; }
    Point2f xy() const {
        return Point2f(X / (X + Y + Z), Y / (X + Y + Z));
    }
    static XYZ FromxyY(Point2f xy, Float Y = 1) {
        if (xy.y == 0)
            return XYZ(0, 0, 0);
        return XYZ(xy.x * Y / xy.y, Y, (1 - xy.x - xy.y) * Y / xy.y);
    }
    PBRT_CPU_GPU
    XYZ &operator+=(const XYZ &s) {
        X += s.X;
        Y += s.Y;
        Z += s.Z;
        return *this;
    }
    PBRT_CPU_GPU
    XYZ operator+(const XYZ &s) const {
        XYZ ret = *this;
        return ret += s;
    }

    PBRT_CPU_GPU
    XYZ &operator-=(const XYZ &s) {
        X -= s.X;
        Y -= s.Y;
        Z -= s.Z;
        return *this;
    }
    PBRT_CPU_GPU
    XYZ operator-(const XYZ &s) const {
        XYZ ret = *this;
        return ret -= s;
    }
    PBRT_CPU_GPU
    friend XYZ operator-(Float a, const XYZ &s) { return {a - s.X, a - s.Y, a - s.Z}; }

    PBRT_CPU_GPU
    XYZ &operator*=(const XYZ &s) {
        X *= s.X;
        Y *= s.Y;
        Z *= s.Z;
        return *this;
    }
    PBRT_CPU_GPU
    XYZ operator*(const XYZ &s) const {
        XYZ ret = *this;
        return ret *= s;
    }
    PBRT_CPU_GPU
    XYZ operator*(Float a) const {
        DCHECK(!IsNaN(a));
        return {a * X, a * Y, a * Z};
    }
    PBRT_CPU_GPU
    XYZ &operator*=(Float a) {
        DCHECK(!IsNaN(a));
        X *= a;
        Y *= a;
        Z *= a;
        return *this;
    }

    PBRT_CPU_GPU
    XYZ &operator/=(const XYZ &s) {
        X /= s.X;
        Y /= s.Y;
        Z /= s.Z;
        return *this;
    }
    PBRT_CPU_GPU
    XYZ operator/(const XYZ &s) const {
        XYZ ret = *this;
        return ret /= s;
    }
    PBRT_CPU_GPU
    XYZ &operator/=(Float a) {
        DCHECK(!IsNaN(a));
        DCHECK_NE(a, 0);
        X /= a;
        Y /= a;
        Z /= a;
        return *this;
    }
    PBRT_CPU_GPU
    XYZ operator/(Float a) const {
        XYZ ret = *this;
        return ret /= a;
    }

    PBRT_CPU_GPU
    XYZ operator-() const { return {-X, -Y, -Z}; }

    PBRT_CPU_GPU
    bool operator==(const XYZ &s) const { return X == s.X && Y == s.Y && Z == s.Z; }
    PBRT_CPU_GPU
    bool operator!=(const XYZ &s) const { return X != s.X || Y != s.Y || Z != s.Z; }
    PBRT_CPU_GPU
    Float operator[](int c) const {
        DCHECK(c >= 0 && c < 3);
        if (c == 0)
            return X;
        else if (c == 1)
            return Y;
        return Z;
    }
    PBRT_CPU_GPU
    Float &operator[](int c) {
        DCHECK(c >= 0 && c < 3);
        if (c == 0)
            return X;
        else if (c == 1)
            return Y;
        return Z;
    }

    std::string ToString() const;
  private:
    Float X = 0, Y = 0, Z = 0;
};
```

#parec[
  The `SpectrumToXYZ()` function computes the XYZ coefficients of a spectral distribution following @eqt:xyz-matching using the following `InnerProduct()` utility function to handle each component.
][
  `SpectrumToXYZ()` 函数根据 @eqt:xyz-matching 使用以下 `InnerProduct()` 实用函数计算光谱分布的 XYZ 系数，以处理每个分量。
]

```cpp
XYZ SpectrumToXYZ(Spectrum s) {
    return XYZ(InnerProduct(&Spectra::X(), s),
               InnerProduct(&Spectra::Y(), s),
               InnerProduct(&Spectra::Z(), s)) / CIE_Y_integral;
}
```

#parec[
  Monte Carlo is not necessary for a simple 1D integral of two spectra, so `InnerProduct()` computes a Riemann sum over integer wavelengths instead.
][
  对于两个光谱的简单一维积分，蒙特卡罗方法（用于随机采样的数学方法）不是必需的，因此 `InnerProduct()` 计算整数波长上的黎曼和（用于积分近似的数学方法）。
]


$
  integral_(lambda_min)^(lambda_max) f (lambda) g (
    lambda
  ) thin d lambda approx sum_(lambda = lambda_min)^(lambda_max) f (lambda) g (lambda) .
$


```cpp
<<Spectrum Inline Functions>>=
Float InnerProduct(Spectrum f, Spectrum g) {
    Float integral = 0;
    for (Float lambda = Lambda_min; lambda <= Lambda_max; ++lambda)
        integral += f(lambda) * g(lambda);
    return integral;
}
```

#parec[
  It is also useful to be able to compute XYZ coefficients for a #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[SampledSpectrum];. Because #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[SampledSpectrum] only has point samples of the spectral distribution at predetermined wavelengths, they are found via a Monte Carlo estimate of @eqt:xyz-matching using the sampled spectral values $s_i$ at wavelengths $lambda_i$ and their associated PDFs:
][
  计算 `SampledSpectrum` 的XYZ系数也是有用的。因为`SampledSpectrum`只有在预定波长的光谱分布的一些样本，它们通过使用波长 $lambda_i$ 处的采样光谱值 $s_i$ 及其相关的概率密度函数来找到@eqt:xyz-matching 的蒙特卡洛估计：
]

$
  x_lambda approx frac(1, integral_lambda Y (lambda) thin d lambda) (
    1 / n sum_(i = 1)^n frac(s_i X (lambda_i), p (lambda_i))
  ) ,
$ <xyz-mc>

#parec[
  and so forth, where $n$ is the number of wavelength samples.

  #link("<SampledSpectrum::ToXYZ>")[SampledSpectrum::ToXYZ()] computes the value of this estimator.
][
  等等，其中 $n$ 是波长样本的数量。

  #link("<SampledSpectrum::ToXYZ>")[SampledSpectrum::ToXYZ()];计算此估计器的值。
]

```cpp
// <<Spectrum Method Definitions>>+=
XYZ SampledSpectrum::ToXYZ(const SampledWavelengths &lambda) const {
    // <<Sample the X, Y, and Z matching curves at lambda>>
    SampledSpectrum X = Spectra::X().Sample(lambda);
    SampledSpectrum Y = Spectra::Y().Sample(lambda);
    SampledSpectrum Z = Spectra::Z().Sample(lambda);
    // <<Evaluate estimator to compute (x, y, z) coefficients>>
    SampledSpectrum pdf = lambda.PDF();
    return XYZ(SafeDiv(X * *this, pdf).Average(),
               SafeDiv(Y * *this, pdf).Average(),
               SafeDiv(Z * *this, pdf).Average()) / CIE_Y_integral;
}
```

#parec[
  The first step is to sample the matching curves at the specified wavelengths.
][
  第一步是在指定的波长处采样匹配曲线。
]

```cpp
// <<Sample the X, Y, and Z matching curves at lambda>>=
SampledSpectrum X = Spectra::X().Sample(lambda);
SampledSpectrum Y = Spectra::Y().Sample(lambda);
SampledSpectrum Z = Spectra::Z().Sample(lambda);
```


#parec[
  The summand in @eqt:xyz-mc is easily computed with values at hand. Here, we evaluate all terms of each sum with a single expression. Using #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum::SafeDiv")[`SampledSpectrum::SafeDiv()`] to divide by the PDF values handles the case of the PDF being equal to zero for some wavelengths, as can happen if #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`] was called. Finally, #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum::Average")[`SampledSpectrum::Average()`] conveniently takes care of summing the individual terms and dividing by $n$ to compute the estimator's value for each coefficient.
][
  @eqt:xyz-mc 中的求和项可以通过现有的值轻松计算。在这里，我们使用一个表达式评估每个和的所有项。使用#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum::SafeDiv")[`SampledSpectrum::SafeDiv()`];来除以概率密度函数值处理了概率密度函数在某些波长上等于零的情况，这可能发生在调用#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`];时。最后，#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum::Average")[`SampledSpectrum::Average()`];方便地处理了求和各个项并除以 $n$ 以计算每个系数的估计值。
]

```cpp
// <<Evaluate estimator to compute (x, y, z) coefficients>>=
SampledSpectrum pdf = lambda.PDF();
return XYZ(SafeDiv(X * *this, pdf).Average(),
           SafeDiv(Y * *this, pdf).Average(),
           SafeDiv(Z * *this, pdf).Average()) / CIE_Y_integral;
```

#parec[
  To avoid the expense of computing the $X$ and $Z$ coefficients when only luminance is needed, there is a `y()` method that only returns $Y$. Its implementation is the obvious subset of `XYZ()` and so is not included here.
][
  为了避免在只需要亮度时计算 $X$ 和 $Z$ 系数的开销，有一个`y()`方法只返回 $Y$。其实现是`XYZ()`的明显子集，因此这里不包括。
]

==== Chromaticity and xyY Color
<chromaticity-and-xyy-color>
#parec[
  Color can be separated into #emph[lightness];, which describes how bright it is relative to something white, and #emph[chroma];, which describes its relative colorfulness with respect to white. One approach to quantifying chroma is the #emph[xyz chromaticity coordinates];, which are defined in terms of XYZ color space coordinates by
][
  颜色可以分为_亮度_，描述其相对于某个白色的亮度，以及_色度_，描述其相对于白色的相对色彩度。量化色度的一种方法是 #emph[xyz色度坐标];，它们通过XYZ颜色空间坐标定义为
]

$
  x & = frac(x_lambda, x_lambda + y_lambda + z_lambda)\
  y & = frac(y_lambda, x_lambda + y_lambda + z_lambda)\
  z & = frac(z_lambda, x_lambda + y_lambda + z_lambda) = 1 - x - y .
$


#parec[
  Note that any two of them are sufficient to specify chromaticity.
][
  注意其中任意两个就足以指定色度。
]

#parec[
  Considering just $x$ and $y$, we can plot a #emph[chromaticity diagram] to visualize their values; see Figure~#link("<fig:xy-chromaticity-diagram>")[4.20];. Spectra with light at just a single wavelength—the pure spectral colors—lie along the curved part of the chromaticity diagram. This part corresponds to the $x y$ projection of the 3D XYZ curve that was shown in @fig:xyz-3d-curve. All the valid colors lie inside the upside-down horseshoe shape; points outside that region correspond to imaginary colors.
][
  仅考虑 $x$ 和 $y$，我们可以绘制一个\_色度图\_来可视化它们的值；见@fig:xy-chromaticity-diagram。仅在单一波长上有光的光谱——纯光谱颜色——位于色度图的弯曲部分。这部分对应于@fig:xyz-3d-curve 中显示的3D XYZ曲线的 $x y$ 投影。所有有效的颜色都位于倒马蹄形的内部；该区域外的点对应于虚构颜色。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f20.svg"),
  caption: [
    #ez_caption[
      Figure 4.20: $x y$ Chromaticity Diagram.
      All valid colors lie inside the shaded region.][
      图4.20：$x y$色度图。
      所有有效的颜色都位于阴影区域内。]
  ],
) <xy-chromaticity-diagram>
#parec[
  The xyY color space separates a color's chromaticity from its lightness. It uses the $x$ and $y$ chromaticity coordinates and $y_lambda$ from XYZ, since the $Y (lambda)$ matching curve was defined to be proportional to luminance. `pbrt` makes limited use of xyY colors and therefore does not provide a class to represent them, but the #link("<XYZ>")[XYZ] class does provide a method that returns its $x y$ chromaticity coordinates as a #link("../Geometry_and_Transformations/Points.html#Point2f")[Point2f];.
][
  xyY颜色空间将颜色的色度与其亮度分开。它使用 $x$ 和 $y$ 色度坐标以及来自XYZ的 $y_lambda$，因为 $Y (lambda)$ 匹配曲线被定义为与亮度成比例。`pbrt`对xyY颜色的使用有限，因此不提供表示它们的类，但#link("<XYZ>")[XYZ];类确实提供了一个方法，返回其 $x y$ 色度坐标作为#link("../Geometry_and_Transformations/Points.html#Point2f")[Point2f];。
]

```cpp
<<XYZ Public Methods>>+=
Point2f xy() const {
    return Point2f(X / (X + Y + Z), Y / (X + Y + Z));
}
```


#parec[
  A corresponding method converts from xyY to XYZ, given $x y$ and optionally $y_lambda$ coordinates.
][
  一个相应的方法将xyY转换为XYZ，给定 $x y$ 和可选的 $y_lambda$ 坐标。
]

```cpp
<<XYZ Public Methods>>+=
static XYZ FromxyY(Point2f xy, Float Y = 1) {
    if (xy.y == 0)
        return XYZ(0, 0, 0);
    return XYZ(xy.x * Y / xy.y, Y, (1 - xy.x - xy.y) * Y / xy.y);
}
```

=== RGB Color
<rgb-color>

#parec[
  RGB color is used more commonly than XYZ in rendering applications. In RGB color spaces, colors are represented by a triplet of values corresponding to red, green, and blue colors, often referred to as #emph[RGB];. However, an RGB triplet on its own is meaningless; it must be defined with respect to a specific RGB color space.
][
  在渲染应用中，RGB颜色比XYZ更常用。在RGB颜色空间中，颜色由对应于红、绿、蓝三种颜色的三元组表示，通常称为\_RGB\_。然而，单独的RGB三元组本身没有意义；它必须相对于特定的RGB颜色空间来定义。
]

#parec[
  To understand why, consider what happens when an RGB color is shown on a display: the spectrum that is displayed is given by the weighted sum of three spectral emission curves, one for each of red, green, and blue, as emitted by the display elements, be they phosphors, LED or LCD elements, or plasma cells.#footnote[This model is admittedly a
simplification in that it neglects any additional processing the display
does; in particular, many displays perform nonlinear remappings of the
displayed values; this topic will be discussed in
Section ] @fig:display-rgb-plots plots the red, green, and blue distributions emitted by an LCD display and an LED display; note that they are remarkably different. @display-rgb-result in turn shows the spectral distributions that result from displaying the RGB color $(0.6 , 0.3 , 0.2)$ on those displays. Not surprisingly, the resulting spectra are quite different as well.
][
  为了理解原因，考虑当RGB颜色在显示器上显示时会发生什么：所显示的光谱是由三个光谱发射曲线的加权和给出的，分别对应于红、绿、蓝，由显示元素发出，无论是荧光粉、LED或LCD元素，还是等离子体单元。#footnote[不可否认，这个模型是一个简化版，因为它忽略了显示器进行的任何额外处理；特别是，许多显示器对显示的值进行非线性重映射；这一主题将在第X节中讨论。] @fig:display-rgb-plots 绘制了LCD显示器和LED显示器发出的红、绿、蓝分布；注意它们有显著的不同。@fig:display-rgb-result 则显示了在这些显示器上显示RGB颜色 $(0.6 , 0.3 , 0.2)$ 所显示的光谱分布。不出所料，结果光谱也有很大不同。
]


#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f21.svg"),
)<display-rgb-plots>


#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f22.svg"),
)<display-rgb-result>


#parec[
  If a display's $R(lambda)$, $G(lambda)$, and $B(lambda)$ curves are known, the RGB coefficients for displaying a spectral distribution $S(lambda)$ on that display can be found by integrating $S(lambda)$ with each curve:
][
  如果已知显示器的 $R(lambda)$ 、 $G(lambda)$ 和 $B(lambda)$ 曲线，则可以通过将光谱分布 $S(lambda)$ 与每个曲线积分来找到在该显示器上显示光谱分布的RGB系数：
]

$
  r =integral R(lambda)S(lambda)d lambda
$

#parec[
  and so forth. The same approaches that were used to compute XYZ values for spectra in the previous section can be used to compute the values of these integrals.
][
  等等。用于计算前一节中光谱的XYZ值的相同方法可以用于计算这些积分的值。
]

#parec[
  Alternatively, if we already have the $(x_lambda, y_lambda, z_lambda)$ representation of $S(lambda)$, it is possible to convert the XYZ coefficients directly to corresponding RGB coefficients. Consider, for example, computing the value of the red component for a spectral distribution $S(lambda)$ :
][
  或者，如果我们已经有了 $S(lambda)$ 的 $(x_lambda, y_lambda, z_lambda)$ 表示，则可以将XYZ系数直接转换为相应的RGB系数。例如，考虑计算光谱分布 $S(lambda)$ 的红色分量值：
]


$
  r& = integral R(lambda) S(lambda) thin d lambda \
  & approx integral R(lambda)(x_lambda X(lambda) + y_lambda Y(lambda) + z_lambda Z(lambda)) d lambda \
  & = x_lambda integral R(lambda) X(lambda) thin d lambda + y_lambda integral R(lambda) Y(
    lambda
  ) thin d lambda + z_lambda integral R(lambda) Z(lambda) thin d lambda .
$ <red-from-spectrum-integral>

#parec[
  where the second step takes advantage of the tristimulus theory of color perception.
][
  其中第二步利用了颜色感知的三刺激理论。
]

#parec[
  The integrals of the products of an RGB response function and XYZ matching function can be precomputed for given response curves, making it possible to express the full conversion as a matrix:
][
  RGB响应函数和XYZ匹配函数的乘积的积分可以为给定的响应曲线预先计算，从而可以将完整的转换表示为矩阵形式：
]

$
  mat(delim: "[", r;
g;
b)
  =
  mat(delim: "(", integral R(lambda) X(lambda) thin d lambda, integral R(lambda) Y(lambda) thin d lambda, integral R(lambda) Z(lambda) thin d lambda;
integral G(lambda) X(lambda) thin d lambda, integral G(lambda) Y(lambda) thin d lambda, integral G(lambda) Z(lambda) thin d lambda;
integral B(lambda) X(lambda) thin d lambda, integral B(lambda) Y(lambda) thin d lambda, integral B(lambda) Z(lambda) thin d lambda)
  mat(delim: "[", x_lambda;
y_lambda;
z_lambda) .
$

#parec[
  `pbrt` frequently uses this approach in order to efficiently convert colors from one color space to another.
][
  `pbrt`经常使用这种方法来有效地将颜色从一个颜色空间转换到另一个颜色空间。
]

#parec[
  An `RGB` class that has the obvious representation and provides a variety of useful arithmetic operations (not included in the text) is also provided by `pbrt`.
][
  `pbrt`还提供了一个`RGB`类，它具有明显的表示并提供多种有用算术操作（本文中未详细列出）。
]


```cpp
// <<RGB Definition>>=
class RGB {
  public:
    <<RGB Public Methods>>
    <<RGB Public Members>>
};
<<RGB Public Methods>>=
RGB(Float r, Float g, Float b) : r(r), g(g), b(b) {}
<<RGB Public Members>>=
Float r = 0, g = 0, b = 0;
```

=== RGB Color Spaces
<rgb-color-spaces>
#parec[
  Full spectral response curves are not necessary to define color spaces. For example, a color space can be defined using $x y$ chromaticity coordinates to specify three #emph[color primaries];. From them, it is possible to derive matrices that convert XYZ colors to and from that color space. In cases where we do not otherwise need explicit spectral response curves, this is a convenient way to specify a color space.
][
  定义颜色空间不需要完整的光谱响应曲线。例如，可以使用 $x y$ 色度坐标来定义一个颜色空间，以指定三个#emph[基色];。可以从中推导出将XYZ颜色转换到该颜色空间以及从该颜色空间转换回来的矩阵。在不需要明确光谱响应曲线的情况下，这是一种方便的指定颜色空间的方法。
]

#parec[
  The `RGBColorSpace` class, which is defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/util/colorspace.h")[`util/colorspace.h`] and `util/colorspace.cpp`, uses this approach to encapsulate a representation of an RGB color space as well as a variety of useful operations like converting XYZ colors to and from its color space.
][
  `RGBColorSpace`类定义在文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/util/colorspace.h")[`util/colorspace.h`];和`util/colorspace.cpp`中，使用这种方法来封装RGB颜色空间的表示以及各种有用的操作，比如将XYZ颜色转换到其颜色空间及从其颜色空间转换回来。
]

#parec[
  An RGB color space is defined using the chromaticities of red, green, and blue color primaries. The primaries define the #emph[gamut] of the color space, which is the set of colors it can represent with RGB values between 0 and 1. For three primaries, the gamut forms a triangle on the chromaticity diagram where each primary's chromaticity defines one of the vertices.#footnote[Some displays use more than three primaries to increase
the size of the gamut, though we will assume conventional RGB here.]
][
  RGB颜色空间是使用红、绿、蓝颜色基色的色度来定义的。基色定义了颜色空间的#emph[色域];，即它可以用RGB值在0到1之间表示的颜色集合。对于三个基色，色域在色度图上形成一个三角形，每个基色的色度定义了一个顶点。#footnote[一些显示器使用超过三种原色来扩大色域范围，不过在这里我们将假设使用常规的RGB。]
]

#parec[
  In addition to the primaries, it is necessary to specify the color space's #emph[whitepoint];, which is the color that is displayed when all three primaries are activated to their maximum emission. It may be surprising that this is necessary—after all, should not white correspond to a spectral distribution with the same value at every wavelength? White is, however, a color, and as a color it is what humans #emph[perceive] as being uniform and label "white." The spectra for white colors tend to have more power in the lower wavelengths that correspond to blues and greens than they do at higher wavelengths that correspond to oranges and reds. The D65 illuminant, which was described in @standard-illuminants and plotted in @fig:d-illuminant , is a common choice for specifying color spaces' whitepoints.
][
  除了基色外，还需要指定颜色空间的#emph[白点];，即当三个基色都激活到其最大发射时显示的颜色。这可能会令人惊讶，因为白色难道不应该是在每个波长上具有相同值的光谱分布吗？然而，白色是一种颜色，作为一种颜色，它是人类#emph[感知];为均匀并标记为“白色”的颜色。 白色的光谱往往在对应于蓝色和绿色的较低波长上具有更多的能量，而在对应于橙色和红色的较高波长上则较少。D65光源，是在 @standard-illuminants 中描述并在 @fig:d-illuminant 中绘制的，是指定颜色空间白点的常见选择。
]

#parec[
  While the chromaticities of the whitepoint are sufficient to define a color space, the `RGBColorSpace` constructor takes its full spectral distribution, which is useful for forthcoming code that converts from color to spectral distributions.
][
  虽然白点的色度足以定义一个颜色空间，但`RGBColorSpace`构造函数采用其完整的光谱分布，这对于即将到来的从颜色到光谱分布的转换代码非常有用。
]

#parec[
  Storing the illuminant spectrum allows users of the renderer to specify emission from light sources using RGB color; the provided illuminant then gives the spectral distribution for RGB white, $(1 , 1 , 1)$.
][
  存储光源光谱允许渲染器的用户使用RGB颜色指定光源的发射；提供的光源然后给出RGB白色 $(1 , 1 , 1)$ 的光谱分布。
]
```cpp
// <<RGBColorSpace Method Definitions>>=
RGBColorSpace::RGBColorSpace(Point2f r, Point2f g, Point2f b,
        Spectrum illuminant, const RGBToSpectrumTable *rgbToSpec,
        Allocator alloc)
    : r(r), g(g), b(b), illuminant(illuminant, alloc),
      rgbToSpectrumTable(rgbToSpec) {
    <<Compute whitepoint primaries and XYZ coordinates>>
    <<Initialize XYZ color space conversion matrices>>
}
RGBColorSpace represents the illuminant as a DenselySampledSpectrum for efficient lookups by wavelength.

// <<RGBColorSpace Public Members>>=
Point2f r, g, b, w;
DenselySampledSpectrum illuminant;
RGBColorSpaces also store a pointer to an RGBToSpectrumTable class that stores information related to converting RGB values in the color space to full spectral distributions; it will be introduced shortly, in Section 4.6.6.

<<RGBColorSpace Private Members>>=
const RGBToSpectrumTable *rgbToSpectrumTable;
```

#parec[
  To find RGB values in the color space, it is useful to be able to convert to and from XYZ. This can be done using $3 times 3$ matrices. To compute them, we will require the XYZ coordinates of the chromaticities and the whitepoint. We will first derive the matrix $M$ that transforms from RGB coefficients in the color space to XYZ:
][
  在颜色空间中找到RGB值时，能够在XYZ之间进行转换是很有用的。这可以使用 $3 times 3$ 矩阵来完成。为了计算它们，我们将需要色度和白点的XYZ坐标。 我们将首先推导出从颜色空间中的RGB系数转换为XYZ的矩阵 $M$ ：
]
$
  mat(delim: "[", x_lambda;
y_lambda;
z_lambda) = M mat(delim: "[", r;
g;
b) .
$
#parec[
  This matrix can be found by considering the relationship between the RGB triplet $(1 , 1 , 1)$ and the whitepoint in XYZ coordinates, which is available in `W`. In this case, we know that $w_x lambda$ must be proportional to the sum of the $x_lambda$ coordinates of the red, green, and blue primaries, since we are considering the case of a $(1 , 1 , 1)$ RGB.
][
  这个矩阵可以通过考虑RGB三元组 $(1 , 1 , 1)$ 与XYZ坐标中的白点之间的关系来找到，这在`W`中可用。在这种情况下，我们知道 $w_x lambda$ 必须与红、绿、蓝基色的 $x_lambda$ 坐标之和成比例，因为我们正在考虑 $(1 , 1 , 1)$ RGB的情况。
]


$
  mat(delim: "[", w_(x_lambda); w_(y_lambda); w_(z_lambda)) = mat(delim: "(", r_(x_lambda), g_(x_lambda), b_(x_lambda); r_(y_lambda), g_(y_lambda), b_(y_lambda); r_(z_lambda), g_(z_lambda), b_(z_lambda)) mat(delim: "(", c_r, 0, 0; 0, c_g, 0; 0, 0, c_b) mat(delim: "[", 1; 1; 1) = mat(delim: "(", r_(x_lambda), g_(x_lambda), b_(x_lambda); r_(y_lambda), g_(y_lambda), b_(y_lambda); r_(z_lambda), g_(z_lambda), b_(z_lambda)) mat(delim: "[", c_r; c_g; c_b) ,
$


#parec[
  which only has unknowns $c_r$, $c_g$, and $c_b$. These can be found by multiplying the whitepoint XYZ coordinates by the inverse of the remaining matrix. Inverting this matrix then gives the matrix that goes to RGB from XYZ.
][
  其中只有未知数 $c_r$ 、 $c_g$ 和 $c_b$。可以通过将白点的 XYZ 坐标乘以剩余矩阵的逆矩阵来求得。反转此矩阵后得到从 XYZ 到 RGB 的转换矩阵。
]
```cpp
// <<Initialize XYZ color space conversion matrices>>=
SquareMatrix<3> rgb(R.X, G.X, B.X,
                    R.Y, G.Y, B.Y,
                    R.Z, G.Z, B.Z);
XYZ C = InvertOrExit(rgb) * W;
XYZFromRGB = rgb * SquareMatrix<3>::Diag(C[0], C[1], C[2]);
RGBFromXYZ = InvertOrExit(XYZFromRGB);
```


```cpp
// <<RGBColorSpace Public Members>>+=
SquareMatrix<3> XYZFromRGB, RGBFromXYZ;
```


#parec[
  Given a color space's XYZ/RGB conversion matrices, a matrix-vector multiplication is sufficient to convert any XYZ triplet into the color space and to convert any RGB in the color space to XYZ.
][
  给定一个色彩空间的 XYZ/RGB 转换矩阵，矩阵-向量乘法足以将任何 XYZ 三元组转换为该色彩空间，并将该色彩空间中的任何 RGB 转换为 XYZ。
]

```cpp
// <<RGBColorSpace Public Methods>>=
RGB ToRGB(XYZ xyz) const { return Mul<RGB>(RGBFromXYZ, xyz); }
XYZ ToXYZ(RGB rgb) const { return Mul<XYZ>(XYZFromRGB, rgb); }
```


#parec[
  Furthermore, it is easy to compute a matrix that converts from one color space to another by using these matrices and converting by way of XYZ colors.
][
  此外，通过使用这些矩阵进行 XYZ 颜色转换，可以很容易地计算出从一个色彩空间转换到另一个色彩空间的矩阵。
]

```cpp
// <<RGBColorSpace Method Definitions>>+=
SquareMatrix<3> ConvertRGBColorSpace(const RGBColorSpace &from,
                                     const RGBColorSpace &to) {
    if (from == to) return {};
    return to.RGBFromXYZ * from.XYZFromRGB;
}
```


#parec[
  #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] provides a convenience method that converts to RGB in a given color space, again via XYZ.
][
  #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`] 提供了一种方便的方法，通过 XYZ 将给定色彩空间转换为 RGB。
]

```cpp
// <<Spectrum Method Definitions>>+=
RGB SampledSpectrum::ToRGB(const SampledWavelengths &lambda,
                           const RGBColorSpace &cs) const {
    XYZ xyz = ToXYZ(lambda);
    return cs.ToRGB(xyz);
}
```


==== Standard Color Spaces
<standard-color-spaces>

#parec[
  There are a number of widely used standard color spaces for which `pbrt` includes built-in support. A few examples include:
][
  有许多广泛使用的标准色彩空间，`pbrt` 包含对它们的内置支持。例如：
]

#parec[
  - sRGB, which was developed in the 1990s and was widely used for
    monitors for many years. One of the original motivations for its
    development was to standardize color on the web.
][
  - sRGB，开发于 1990
    年代，多年来广泛用于显示器。其开发的最初动机之一是为了在网络上标准化颜色。
]

#parec[
  - DCI-P3, which was developed for digital film projection and covers a
    wider gamut than sRGB. At the time of writing, it is increasingly
    being adopted for computer displays and mobile phones.
][
  - DCI-P3，为数字电影投影开发，覆盖的色域比 sRGB
    更广。在撰写本文时，它正越来越多地被用于计算机显示器和手机。
]

#parec[
  - Rec2020, which covers an even wider gamut, and is used in the UHDTV
    television standard.
][
  - Rec2020，覆盖了更广的色域，用于 UHDTV 电视标准。
]

#parec[
  - ACES2065-1, which has primaries that are outside of the representable
    colors and are placed so that all colors can be represented by it. One
    reason for this choice was for it to be suitable as a format for
    long-term archival storage.
][
  - ACES2065-1，其原色超出了可表示的颜色范围，因此可以表示所有颜色。选择这种方式的一个原因是它适合作为长期存档存储的格式。
]

#parec[
  The gamuts of each are shown in @fig:color-space-gamuts .
][
  每个色彩空间的色域如@fig:color-space-gamuts 所示。
]
#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f23.svg"),
  caption: [
    #ez_caption[
      The gamuts of the sRGB, DCI-P3, Rec2020, and ACES2065-1 color spaces, visualized using the chromaticity diagram. sRGB covers the smallest gamut, DCI-P3 the next largest, Rec2020 an even larger one. ACES2065-1, which corresponds to the large triangle, is distinguished by using primaries that correspond to imaginary colors. In doing so, it is able to represent all valid colors, unlike the others.
    ][
      sRGB、DCI-P3、Rec2020 和 ACES2065-1 色彩空间的色域，使用色度图可视化。sRGB 覆盖的色域最小，DCI-P3 次之，Rec2020 更大。ACES2065-1 对应于大三角形，其特点是使用对应于虚拟颜色的原色。因此，它能够表示所有有效颜色，而其他色彩空间则无法做到。
    ]
  ],
)<color-space-gamuts>



#parec[
  The `RGBColorSpace` class provides pre-initialized instances of the #link("<RGBColorSpace>")[RGBColorSpace];s for each of these.
][
  `RGBColorSpace` 类为每个#link("<RGBColorSpace>")[RGBColorSpace];提供了预初始化的实例。
]

```cpp
<<RGBColorSpace Public Members>>+=
static const RGBColorSpace *sRGB, *DCI_P3, *Rec2020, *ACES2065_1;
```


#parec[
  It is also possible to look color spaces up by name or by specifying the chromaticity of primaries and a whitepoint.
][
  还可以通过名称或通过指定原色的色度和白点来查找特定的色彩空间。
]

```cpp
<<RGBColorSpace Public Methods>>+=
static const RGBColorSpace *GetNamed(std::string name);
static const RGBColorSpace *Lookup(Point2f r, Point2f g, Point2f b,
                                   Point2f w);
```

=== Why Spectral Rendering?

#parec[
  Thus far, we have been proceeding with the description of `pbrt`'s implementation with the understanding that it uses point-sampled spectra to represent spectral quantities. While that may seem natural given `pbrt`'s physical basis and general adoption of Monte Carlo integration, it does not fit with the current widespread practice of using RGB color for spectral computations in rendering. We hinted at a significant problem with that practice at the start of this section; having introduced RGB color spaces, we can now go farther.
][
  到目前为止，我们在描述 `pbrt` 的实现时，一直假设它使用点样光谱来表示光谱量。虽然鉴于 `pbrt` 的物理基础和对蒙特卡罗积分的普遍采用，这似乎是理所当然的，但这与当前广泛使用 RGB 颜色进行渲染中的光谱计算的实践并不一致。 在本节开始时，我们提到了这种做法的一个重大问题；在介绍了 RGB 颜色空间后，我们现在可以更深入地探讨。
]


#parec[
  As discussed earlier, because color spaces are vector spaces, addition of two colors in the same color space gives the same color as adding the underlying spectra and then finding the resulting spectrum's color. That is not so for multiplication. To understand the problem, suppose that we are rendering a uniformly colored object (e.g., green) that is uniformly illuminated by light of the same color. For simplicity, assume that both illumination and the object's reflectance value are represented by the RGB color $(0 , 1 , 0)$. The scattered light is then given by a product of reflectance and incident illumination:
][
  如前所述，由于颜色空间是向量空间，在同一颜色空间中相加两个颜色，与先相加其底层光谱然后找出结果光谱的颜色是相同的。但对于乘法则不然。 为了理解这个问题，假设我们正在渲染一个颜色均匀的物体（例如绿色），它被同样颜色的光均匀照亮。为简单起见，假设光照和物体的反射值都用 RGB 颜色 $(0 , 1 , 0)$ 表示。散射光由反射率和入射光的逐分量乘法给出：
]


$ mat(delim: "[", 0; 1; 0) dot.circle mat(delim: "[", 0; 1; 0) = mat(delim: "[", 0; 1; 0) , $

#parec[
  where componentwise multiplication of RGB colors is indicated by the " $thin dot.circle$ " operator.
][
  其中 RGB 颜色的逐分量乘法由“ $thin dot.circle$ ”运算符表示。
]

#parec[
  In the sRGB color space, the green color $(0 , 1 , 0)$ maps to the upper vertex of the gamut of representable colors @fig:green-in-two-color-spaces), and this RGB color value furthermore remains unchanged by the multiplication.
][
  在 sRGB 颜色空间中，绿色 $(0 , 1 , 0)$ 映射到可表示颜色范围的上顶点（@fig:green-in-two-color-spaces），并且这个 RGB 颜色值在乘法后保持不变。
]

#parec[
  Now suppose that we change to the wide-gamut color space ACES2065-1. The sRGB color $(0 , 1 , 0)$ can be found to be $(0.38 , 0.82 , 0.12)$ in this color space—it thus maps to a location that lies in the interior of the set of representable colors. Performing the same component-wise multiplication gives the result:
][
  现在假设我们切换到广色域色彩空间 ACES2065-1。在这个颜色空间中，sRGB 颜色 $(0 , 1 , 0)$ 可以表示为 $(0.38 , 0.82 , 0.12)$ ——因此它映射到可表示颜色范围的内部。 执行相同的逐分量乘法得到结果：
]

$
  mat(delim: "[", 0.38; 0.82; 0.12) dot.circle mat(delim: "[", 0.38; 0.82; 0.12) approx mat(delim: "[", 0.14; 0.67; 0.01)
$


#parec[
  This time, the resulting color has lower intensity than it started with and has also become more saturated due to an increase in the relative proportion of green light. That leads to the somewhat bizarre situation shown in @fig:green-in-two-color-spaces: component-wise multiplication in this new color space not only produces a different color—it also increases saturation so severely that the color is pushed outside of the CIE horseshoe shape of physically realizable colors!
][
  这次，结果颜色的强度比最初低，并且由于绿色光的相对比例增加而变得更加饱和。 这导致了@fig:green-in-two-color-spaces 中所示的有些奇怪的情况：在这个新颜色空间中进行的逐分量乘法不仅产生了不同的颜色——还增加了饱和度，以至于颜色被推到了 CIE 马蹄形色域之外！
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f24.svg"),
  caption: [
    #ez_caption[The same color can have very different RGB values when expressed in RGB color spaces with differently shaped gamuts. The green primary $(0, 1, 0)$ in the sRGB color gamut (inner triangle) has chromaticity coordinates $(0.3, 0.5)$ (white dot). In the wide-gamut ACES2065-1 color space (outer triangle), the same color has the RGB value $(0.38, 0.82, 0.12)$.][在具有不同形状的色域的 RGB 色彩空间中，相同的颜色可以具有非常不同的 RGB 值。在 sRGB 色域（内部三角形）中，绿色主色 $(0, 1, 0)$ 的色度坐标为 $(0.3, 0.5)$（白点）。在宽色域的 ACES2065-1 色彩空间（外部三角形）中，相同的颜色具有 RGB 值 $(0.38, 0.82, 0.12)$。]
  ],
) <green-in-two-color-spaces>


=== Choosing the Number of Wavelength Samples
<choosing-the-number-of-wavelength-samples>
#parec[
  Even though it uses a spectral model for light transport simulation, `pbrt`'s output is generally an image in a tristimulus color representation like RGB. Having described how those colors are computed—Monte Carlo estimates of the products of spectra and matching functions of the form of @eqt:xyz-mc —we will briefly return to the question of how many spectral samples are used for the #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[SampledSpectrum] class. The associated Monte Carlo estimators are easy to evaluate, but error in them leads to #emph[color noise] in images. @fig:color-noise-example shows an example of this phenomenon.
][
  尽管 `pbrt` 使用光谱模型进行光传输模拟，其输出通常是三基色表示的图像，如 RGB。我们已经描述了这些颜色是如何计算的——光谱和匹配函数的乘积的蒙特卡罗估计，如@eqt:xyz-mc 的形式——我们将简要讨论 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[SampledSpectrum] 类使用多少光谱样本的问题。相关的蒙特卡罗估计器易于评估，但其中的误差会导致图像中的 #emph[色彩噪声];。图 4.25 展示了这种现象的一个例子。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f25.svg"),
  caption: [
    #ez_caption[
      (a) Reference image of the example scene.
      (b) If the scene is rendered using only a single image sample per pixel,
      each sampling only a single wavelength, there is a substantial amount of
      variance from error in the Monte Carlo estimates of the pixels' RGB
      colors.
      (c) With four wavelength samples (`pbrt`'s default), this variance is
      substantially reduced, though color noise is still evident. In practice,
      four wavelength samples is usually sufficient since multiple image
      samples are generally taken at each pixel.
      #emph[(Model courtesy of Yasutoshi Mori.)]
    ][
      (a) 示例场景的参考图像。
      (b)
      如果场景仅使用每像素一个图像样本渲染，每次采样仅一个波长，则蒙特卡罗估计的像素
      RGB 颜色的误差会导致显著的方差。
      (c) 使用四个波长样本（`pbrt`
      的默认值）时，这种方差大大减少，尽管色彩噪声仍然明显。在实践中，四个波长样本通常足够，因为通常在每个像素处会进行多个图像样本。
      #emph[(模型由 Yasutoshi Mori 提供。)]
    ]
  ],
)<color-noise-example>


#parec[
  @fig:color-noise-example(a) shows a scene illuminated by a point light source where only direct illumination from the light is included. In this simple setting, the Monte Carlo estimator for the scattered light has zero variance at all wavelengths, so the only source of Monte Carlo error is the integrals of the color matching functions. With a single ray path per pixel and each one tracking a single wavelength, the image is quite noisy, as shown in @fig:color-noise-example(b). Intuitively, the challenge in this case can be understood from the fact that the renderer is trying to estimate three values at each pixel—red, green, and blue—all from the spectral value at a single wavelength.
][
  图 4.25(a) 显示了一个由点光源照明的场景，其中仅包含来自光源的直接照明。在这种简单设置中，散射光的蒙特卡罗估计器在所有波长上的方差为零，因此蒙特卡罗误差的唯一来源是颜色匹配函数的积分。每个像素只有一条光线路径，每条路径仅跟踪一个波长，图像非常嘈杂，如图 4.25(b) 所示。直观地说，这种情况下的挑战可以理解为渲染器试图在每个像素处估计三个值——红色、绿色和蓝色——全部来自单个波长的光谱值。
]

#parec[
  Increasing the number of pixel samples can reduce this error (as long as they sample different wavelengths), though it is more effective to associate multiple wavelength samples with each ray. The path that a ray takes through the scene is usually independent of wavelength and the incremental cost to compute lighting at multiple wavelengths is generally small compared to the cost of finding ray intersections and computing other wavelength-independent quantities. (Considering multiple wavelengths for each ray can be seen as an application of the Monte Carlo splitting technique that is described in @mc-splitting .) @fig:color-noise-example(c) shows the improvement from associating four wavelengths with each ray; color noise is substantially reduced.
][
  增加像素样本的数量可以减少这种误差（只要它们采样不同的波长），尽管将多个波长样本与每条光线关联更为有效。光线在场景中经过的路径的计算通常与波长无关，而在多个波长上计算照明的增量成本通常与找到光线交点和计算其他与波长无关的量相比较小。（为每条光线考虑多个波长可以看作是蒙特卡罗分裂技术的应用，该技术在@mc-splitting 中描述。）图 4.25(c) 显示了将四个波长与每条光线关联所带来的改进；色彩噪声大大减少。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f26.svg"),
  caption: [
    #ez_caption[
      (a) Rendering time when rendering the scene in @fig:color-noise-example graphed as a
      function of the number of wavelength samples, normalized to rendering
      time with one wavelength sample.
      (b) Mean squared error as a function of the number of wavelength samples
      for both independent and stratified samples.
      (c) Monte Carlo efficiency as a function of the number of stratified
      wavelength samples.
      These results suggest that at least 32 wavelength samples are optimal.
    ][
      (a) 渲染@fig:color-noise-example
      中场景时的渲染时间，作为波长样本数量的函数绘制，归一化为一个波长样本的渲染时间。
      (b) 独立和分层样本的均方误差作为波长样本数量的函数。
      (c) 蒙特卡罗效率作为分层波长样本数量的函数。
      这些结果表明至少 32 个波长样本是最佳的。
    ]
  ],
) <mc-efficiency-vs-wavelength-samples-simple-scene>

#parec[
  However, computing scattering from too many wavelengths with each ray can harm efficiency due to the increased computation required to compute spectral quantities. To investigate this trade-off, we rendered the scene from @fig:color-noise-example with a variety of numbers of wavelength samples, both with wavelengths sampled independently and with stratified sampling of wavelengths. (For both, wavelengths were sampled uniformly over the range 360-830 nm.) @fig:mc-efficiency-vs-wavelength-samples-simple-scene shows the results.
][
  然而，使用每条光线计算过多波长的散射会因计算光谱量所需的增加而损害效率。为了研究这种权衡，我们使用各种波长样本数量渲染了@fig:color-noise-example 中的场景，包括独立采样波长和分层采样波长。（对于两者，波长在 360-830 nm 范围内均匀采样。）@fig:mc-efficiency-vs-wavelength-samples-simple-scene 显示了渲染时间和误差的结果。
]

#parec[
  @fig:mc-efficiency-vs-wavelength-samples-simple-scene(a) shows that for this scene, rendering with 32 wavelength samples requires nearly $1.6 upright(" times")$ more time than rendering with a single wavelength sample. (Rendering performance with both independent and stratified sampling is effectively the same.) However, as shown in @fig:mc-efficiency-vs-wavelength-samples-simple-scene(b), the benefit of more wavelength samples is substantial. On the log-log plot there, we can see that with independent samples, mean squared error decreases at a rate $O (1 / n)$, in line with the rate at which variance decreases with more samples. Stratified sampling does remarkably well, not only delivering orders of magnitude lower error but at a faster asymptotic convergence rate as well.
][
  @fig:mc-efficiency-vs-wavelength-samples-simple-scene(a) 显示，对于这个场景，使用 32 个波长样本渲染所需的时间几乎是使用单个波长样本渲染时间的 $1.6 upright(" 倍")$。（独立和分层采样的渲染性能实际上相同。）然而，如@fig:mc-efficiency-vs-wavelength-samples-simple-scene(b) 所示，更多波长样本的好处是显著的。在对数-对数图上，我们可以看到对于独立样本，均方误差以 $O (1 / n)$ 的速率下降，与更多样本时方差下降的速率一致。分层采样表现得非常好，不仅提供了数量级更低的误差，而且收敛速率也更快。
]

#parec[
  @fig:mc-efficiency-vs-wavelength-samples-simple-scene(c) plots Monte Carlo efficiency for both approaches (note, with a logarithmic scale for the $y$ axis). The result seems clear; 32 stratified wavelength samples are over a million times more efficient than one sample and there the curve has not yet leveled off. Why stop measuring at 32, and why is `pbrt` stuck with a default of four wavelength samples for its #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#NSpectrumSamples")[NSpectrumSamples] parameter?
][
  @fig:mc-efficiency-vs-wavelength-samples-simple-scene(c) 绘制了两种方法的蒙特卡罗效率（注意， $y$ 轴为对数刻度）。结果似乎很明确；32 个分层波长样本的蒙特卡罗效率比一个样本高出一百万倍，曲线尚未趋于平稳。为什么在 32 个样本时停止测量，而 `pbrt` 的 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#NSpectrumSamples")[NSpectrumSamples] 参数默认为四个波长样本？
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f27.svg"),
  caption: [
    #ez_caption[
      (a) A more complex scene, where variance in the Monte Carlo estimator is
      present from a variety of sources beyond wavelength sampling.
      (b) Graph of mean squared error versus the number of stratified
      wavelength samples. The benefits of additional wavelength samples are
      limited after six of them.
      (c) Monte Carlo efficiency versus the number of stratified wavelength
      samples, normalized to efficiency with one wavelength sample. For this
      scene, eight samples are optimal.
    ][
      (a)
      一个更复杂的场景，其中蒙特卡罗估计器的方差来自波长采样以外的多种来源。
      (b)
      均方误差与分层波长样本数量的关系图。额外波长样本的好处在六个之后有限。
      (c)
      蒙特卡罗效率与分层波长样本数量的关系，归一化为一个波长样本的效率。对于这个场景，八个样本是最佳的。
    ]
  ],
)<mc-efficiency-vs-wavelength-samples-watercolor>
#parec[
  There are three main reasons for the current setting. First, although @fig:mc-efficiency-vs-wavelength-samples-simple-scene(a) shows nearly a $500 upright(" times")$ reduction in error from 8 to 32 wavelength samples, the two images are nearly indistinguishable—the difference in error is irrelevant due to limitations in display technology and the human visual system. Second, scenes are usually rendered following multiple ray paths in each pixel in order to reduce error from other Monte Carlo estimators. As more pixel samples are taken with fewer wavelengths, the total number of wavelengths that contribute to each pixel's value increases.
][
  当前设置的原因主要有三个。首先，尽管图 4.26(a) 显示从 8 到 32 个波长样本的误差减少了近 $500 upright(" 倍")$，但两幅图像几乎无法区分——由于显示技术和人类视觉系统的限制，误差的差异无关紧要。其次，场景通常在每个像素中遵循多条光线路径进行渲染，以减少其他蒙特卡罗估计器的误差。随着在更少波长下采集更多像素样本，贡献到每个像素值的波长总数增加。
]

#parec[
  Finally, and most importantly, those other sources of Monte Carlo error often make larger contributions to the overall error than wavelength sampling. @fig:mc-efficiency-vs-wavelength-samples-watercolor(a) shows a much more complex scene with challenging lighting that is sampled using Monte Carlo. A graph of mean squared error as a function of the number of wavelength samples is shown in @fig:mc-efficiency-vs-wavelength-samples-watercolor(b) and Monte Carlo efficiency is shown in @fig:mc-efficiency-vs-wavelength-samples-watercolor(c). It is evident that after eight wavelength samples, the incremental cost of more of them is not beneficial.
][
  最后，也是最重要的，其他蒙特卡罗误差来源通常对总体误差的贡献比波长采样更大。@fig:mc-efficiency-vs-wavelength-samples-watercolor(a) 显示了一个更复杂的场景，其中使用蒙特卡罗采样的具有挑战性的照明。均方误差作为波长样本数量的函数的图表如图 4.27(b) 所示，蒙特卡罗效率如@fig:mc-efficiency-vs-wavelength-samples-watercolor(c) 所示。显然，在八个波长样本之后，更多样本的增量成本并不有利。
]

=== From RGB to Spectra
<from-rgb-to-specturm>
#parec[
  Although converting spectra to RGB for image output is a well-specified operation, the same is not true for converting RGB colors to spectral distributions. That is an important task, since much of the input to a renderer is often in the form of RGB colors. Scenes authored in current 3D modeling tools normally specify objects' reflection properties and lights' emission using RGB parameters and textures. In a spectral renderer, these RGB values must somehow be converted into equivalent color spectra, but unfortunately any such conversion is inherently ambiguous due to the existence of metamers. How we can expect to find a reasonable solution if the problem is so poorly defined? On the flip side, this ambiguity can also be seen positively: it leaves a large space of possible answers containing techniques that are simple and efficient.
][
  尽管将光谱转换为 RGB 以进行图像输出是一个明确的操作，但将 RGB 颜色转换为光谱分布却并非如此。这是一项重要任务，因为渲染器的大部分输入通常是以 RGB 颜色的形式出现的。 在当前的 3D 建模工具中创建的场景通常使用 RGB 参数和纹理来指定对象的反射属性和光源的发射。在光谱渲染器中，这些 RGB 值必须以某种方式转换为等效的颜色光谱，但不幸的是，由于存在同色异谱现象，任何此类转换本质上都是模糊的。 如果问题定义得如此不明确，我们如何期望找到一个合理的解决方案？另一方面，这种模糊性也可以被视为积极的：它留下了一个包含简单且高效技术的大空间。
]



#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f28.svg"),
  caption: [
    #ez_caption[Spectral reflectances of several color checker patches. Each curve is shaded with the associated RGB color.][几个颜色检查器斑块的光谱反射率。每条曲线都用相关的RGB颜色着色。]
  ],
)
#parec[
  Further complicating this task, we must account for three fundamentally different types of spectral distributions:
][
  进一步复杂化这一任务的是，我们必须考虑三种根本不同类型的光谱分布：
]

#parec[
  - _Illuminant spectra_, which specify the spectral dependence of a light source's emission profile. These are nonnegative and unbounded; their shapes range from smooth (incandescent light sources, LEDs) to extremely spiky (stimulated emission in lasers or gas discharge in xenon arc and fluorescent lamps).
][
  - _光源光谱_，指定光源发射轮廓的光谱依赖性。这些是非负且无界的；它们的形状从平滑（白炽光源、LED）到极其尖锐（激光中的受激发射或氙弧灯和荧光灯中的气体放电）。
]

#parec[
  - _Reflectance spectra_, which describe reflection from absorbing surfaces.Reflectance spectra conserve the amount of energy at each wavelength, meaning that values cannot be outside of the \[0, 1\] range. They are typically smooth functions in the visible wavelength range.
][
  - _反射光谱_，描述吸收表面的反射。反射光谱在每个波长上保持能量的量，这意味着值不能超出\[0, 1\] 范围。它们通常是可见波长范围内的平滑函数。
]

#parec[
  - _Unbounded spectra_, which are nonnegative and unbounded but do not describe emission. Common examples include spectrally varying indices of refraction and coefficients used to describe medium scattering properties.
][
  - _无界光谱_，它们是非负且无界的，但不描述发射。常见示例包括光谱变化的折射率和用于描述介质散射特性的系数。
]

#parec[
  This section first presents an approach for converting an RGB color value with components between 0 and 1 into a corresponding reflectance spectrum, followed by a generalization to unbounded and illuminant spectra. The conversion exploits the ambiguity of the problem to achieve the following goals:
][
  本节首先介绍了一种将 RGB 颜色值（其分量在 0 和 1 之间）转换为相应反射光谱的方法，然后推广到无界和光源光谱。 该转换利用问题的模糊性来实现以下目标：
]

#parec[
  - _Identity_: If an RGB value is converted to a spectrum, converting that spectrum back to RGB should give the same RGB coefficients.
][
  - _一致性_：如果将 RGB 值转换为光谱，则将该光谱转换回 RGB 应该给出相同的 RGB 系数。
]

#parec[
  - _Smoothness_: Motivated by the earlier observation about real-world reflectance spectra, the output spectrum should be as smooth as possible. Another kind of smoothness is also important: slight perturbations of the input RGB color should lead to a corresponding small change of the output spectrum. Discontinuities are undesirable, since they would cause visible seams on textured objects if observed under different illuminants.
][
  - _光谱平滑性_：受之前关于真实世界反射光谱的观察启发，输出光谱应尽可能平滑。另一种平滑性也很重要：输入 RGB 颜色的轻微扰动应导致输出光谱的相应小变化。 不连续性是不受欢迎的，因为在不同光源下观察时，它们会导致纹理对象上出现可见的接缝。
]

#parec[
  - _Energy conservation_: Given RGB values in \[0, 1\], the associated spectral distribution should also be within \[0, 1\].
][
  - _能量守恒性_：给定 \[0, 1\] 范围内的 RGB 值，相关的光谱分布也应在 \[0, 1\] 范围内。
]

#parec[
  Although real-world reflectance spectra exist in a wide variety of shapes, they are often well-approximated by constant (white, black), approximately linear, or peaked curves with one (green, yellow) or two modes (bluish-purple).
][
  尽管真实世界的反射光谱存在多种形状，但它们通常可以通过恒定（白色、黑色）、近似线性或具有一个（绿色、黄色）或两个模式（蓝紫色）的峰值曲线很好地近似。
]

#parec[
  The approach chosen here attempts to represent such spectra using a function family that is designed to be simple, smooth, and efficient to evaluate at runtime, while exposing a sufficient number of degrees of freedom to precisely reproduce arbitrary RGB color values.
][
  这里选择的方法尝试使用一个设计为简单、平滑且在运行时高效评估的函数族来表示这些光谱，同时暴露足够数量的自由度以精确再现任意 RGB 颜色值。
]

#parec[
  Polynomials are typically a standard building block in such constructions; indeed, a quadratic polynomial could represent constant and linear curves, as well as ones that peak in the middle or toward the endpoints of the wavelength range. However, their lack of energy conservation poses a problem that we address using a sigmoid function:
][
  多项式通常是此类构造中的标准构建块；实际上，二次多项式方程可以表示恒定和线性曲线，以及在波长范围中间或端点附近达到峰值的曲线。 然而，它们缺乏能量守恒性，这个问题我们通过使用 S 形函数来解决：
]

$
  s(x) = 1 / 2 + x / (2sqrt(1+x^2))
$
<rgb-to-spectrum-polynomial>


#parec[
  This function, plotted in @fig:sigmoid, is strictly monotonic and smoothly approaches the endpoints 0 and 1 as $x arrow.r minus.plus infinity
$.
][
  此函数在@fig:sigmoid 中绘制，严格单调且在 $x arrow.r minus.plus infinity
$ 时平滑地接近端点 0 和 1。
]



#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f29.svg"),
  caption: [
    #ez_caption[*Sigmoid curve.* The term sigmoid refers to smooth S-shaped curves that map all inputs to a bounded output interval. The particular type of sigmoid used here is defined in terms of algebraic functions, enabling highly efficient evaluation at runtime.
    ][*Sigmoid曲线*。术语sigmoid是指将所有输入映射到有界输出区间的平滑S形曲线。这里使用的特殊类型的sigmoid是根据代数函数定义的，可以在运行时进行高效的计算。]
  ],
)<sigmoid>

#parec[
  We apply this sigmoid to a quadratic polynomial defined by three coefficients $c_i$, squashing its domain to the interval \[0, 1\] to ensure energy conservation.
][
  我们将此 sigmoid 应用于由三个系数 $c_i$ 定义的二次多项式，将其域压缩到区间 \[0, 1\] 以确保能量守恒。
]


$
  S(lambda) = s(c_0 lambda^2 + c_1 lambda + c_2)
$ <rgb-to-spectrum-spd>
#parec[
  Representing ideally absorptive and reflective spectra (i.e., $S(lambda)= 0 "or" 1$ is somewhat awkward using this representation, since the polynomial must evaluate to positive or negative infinity to reach these two limits. This in turn leads to a fraction of the form $plus.minus oo \/ oo$ in @eqt:rgb-to-spectrum-polynomial , which evaluates to a not-a-number value in IEEE-754 arithmetic. We will need to separately handle this limit case.
][
  使用这种表示法表示理想的吸收和反射光谱（即 $S(lambda) = 0$ 或 1）有些尴尬，因为多项式必须评估为正无穷或负无穷才能达到这两个极限。 这反过来导致@eqt:rgb-to-spectrum-polynomial 中的形式为 $plus.minus oo \/ oo$ 的分数，在 IEEE-754 算术中评估为非数字值。 我们需要单独处理这种极限情况。
]

#parec[
  We begin with the definition of a class that encapsulates the coefficients $c_i$ and evaluates Equation (4.26).
][
  我们从封装系数 $c_i$ 并评估方程 (4.26) 的类定义开始。
]

```cpp
// <<RGBSigmoidPolynomial Definition>>=
class RGBSigmoidPolynomial {
  public:
    // <<RGBSigmoidPolynomial Public Methods>>
  private:
    // <<RGBSigmoidPolynomial Private Methods>>
    // <<RGBSigmoidPolynomial Private Members>>
};
```

#parec[
  It has the expected constructor and member variables.
][
  他有我们预期的构造函数和成员变量。
]
```cpp
// <<RGBSigmoidPolynomial Public Methods>>=
RGBSigmoidPolynomial(Float c0, Float c1, Float c2)
    : c0(c0), c1(c1), c2(c2) {}
// <<RGBSigmoidPolynomial Private Members>>=
Float c0, c1, c2;
```


#parec[
  Given coefficient values, it is easy to evaluate the spectral function at a specified wavelength.
][
  给定系数值，很容易在指定波长处评估光谱函数。
]

#parec[
  The sigmoid function follows the earlier definition and adds a special case to handle positive and negative infinity.
][
  sigmoid 函数遵循之前的定义，并添加了一个特殊情况来处理正无穷和负无穷。
]

#parec[
  The MaxValue() method returns the maximum value of the spectral distribution over the visible wavelength range 360-830 nm. Because the sigmoid function is monotonically increasing, this problem reduces to locating the maximum of the quadratic polynomial from @eqt:rgb-to-spectrum-polynomial and evaluating the model there.
][
  `MaxValue()` 方法用于计算可见波长范围 360-830 nm 上光谱分布的最大值。 因为 sigmoid 函数是严格单调递增的，这个问题简化为定位@eqt:rgb-to-spectrum-polynomial 的二次多项式的最大值并在那里评估模型。
]

#parec[
  We conservatively check the endpoints of the interval along with the extremum found by setting the polynomial's derivative to zero and solving for the wavelength lambda. The value will be ignored if it happens to be a local minimum.
][
  我们保守地检查区间的端点以及通过将多项式的导数设为零并求解波长 lambda 找到的极值。 如果它碰巧是局部最小值，则该值将被忽略。
]

```cpp
// <<RGBSigmoidPolynomial Public Methods>>+=
Float MaxValue() const {
    Float result = std::max((*this)(360), (*this)(830));
    Float lambda = -c1 / (2 * c0);
    if (lambda >= 360 && lambda <= 830)
        result = std::max(result, (*this)(lambda));
    return result;
}
```

#parec[
  We now turn to the second half of RGBSigmoidPolynomial, which is the computation that determines suitable coefficients $c_0, c_1, c\2$ for a given RGB color. This step depends on the spectral emission curves of the color primaries and generally does not have an explicit solution. We instead formulate it as an optimization problem that minimizes the round-trip error (i.e., the _identity_ goal mentioned above) by computing the difference between input and output RGB values following forward and reverse conversion. The precise optimization goal is
][
  我们现在转向 RGBSigmoidPolynomial 的后半部分，即确定给定 RGB 颜色的合适系数 $c_0, c_1, c_2$ 的计算。 这一步取决于颜色基色的光谱发射曲线，通常没有明确的解决方案。 我们将其表述为一个优化计算问题，通过计算正向和反向转换后输入和输出 RGB 值之间的差异来最小化往返转换误差（即上述_一致性_目标）。 精确的优化目标是
]

// \left(c_0^*, c_1^*, c_2^*\right) = \arg\min_{c_0, c_1, c_2} \left\| \begin{pmatrix}
// r \\
// g \\
// b
// \end{pmatrix} - \int \begin{pmatrix}
// R(\lambda) \\
// G(\lambda) \\
// B(\lambda)
// \end{pmatrix} S(\lambda, c_0, c_1, c_2) W(\lambda) \, d\lambda \right\|

$
  (
    c_0^*, c_1^*, c_2^*
  ) = arg min_(c_0, c_1, c_2) norm(
    mat(delim: "[", r;  g; b) - integral
    mat(delim: "[", R(lambda);G(lambda); B(lambda))
     S(lambda, c_0, c_1, c_2) W(lambda) thin d lambda
  )
$

#parec[
  where $R(lambda), G(lambda), B(lambda)$ describe emission curves of the color primaries and $W(lambda)$ represents the whitepoint (e.g., D65 shown in Figure #link("../Radiometry,_Spectra,_and_Color/Light_Emission.html#fig:d-illuminant")[4.14] in the case of the sRGB color space). Including the whitepoint in this optimization problem ensures that monochromatic RGB values map to uniform reflectance spectra.
][
  其中 $R (lambda) , G (lambda) , B (lambda)$ 描述了颜色原色的发射曲线， $W (lambda)$ 表示白点（例如，在 sRGB 色彩空间中如图 #link("../Radiometry,_Spectra,_and_Color/Light_Emission.html#fig:d-illuminant")[4.14] 所示的 D65）。在此优化问题中包含白点确保单色的 RGB 值映射到均匀的反射光谱。
]

#parec[
  In spaces with a relatively compact gamut like sRGB, this optimization can achieve zero error regardless of the method used to quantify color distances. In larger color spaces, particularly those including imaginary colors like ACES2065-1, zero round-trip error is clearly not achievable, and the choice of norm || becomes relevant. In principle, we could simply use the 2-norm—however, a problem with such a basic choice is that it is not #emph[perceptually uniform];: whether a given amount of error is actually visible depends on its position within the RGB cube. We instead use CIE76 E, which first transforms both colors into a color space known as CIELAB before evaluating the L\_2-distance.
][
  在 sRGB 这样相对紧凑的色域中，无论使用哪种方法量化颜色距离，这种优化都可以实现零误差。在较大的色彩空间中，特别是那些包含虚拟颜色的空间，如 ACES2065-1，显然无法实现零往返误差，选择范数 $parallel dot.op parallel$ 变得重要。 原则上，我们可以简单地使用 2-范数（即欧几里得范数）——然而，这样一个基本选择的问题在于它不是 #emph[感知均匀的];：给定的误差量是否实际可见取决于其在 RGB 立方体中的位置。我们选择使用 CIE76 $Delta E$，它首先将两种颜色转换为称为 CIELAB 的颜色空间，然后评估 $L_2$ -距离。
]

#parec[
  We then solve this optimization problem using the Gauss-Newton algorithm, an approximate form of Newton's method. This optimization takes on the order of a few microseconds, which would lead to inefficiencies if performed every time an RGB value must be converted to a spectrum (e.g., once for every pixel of a high-resolution texture).
][
  然后我们使用高斯-牛顿算法解决这个优化问题，高斯-牛顿算法是一种牛顿法的近似形式。此优化大约需要几微秒，如果每次需要将 RGB 值转换为光谱时（例如，每个高分辨率纹理的像素）都执行此操作，将导致效率低下。
]

#parec[
  To avoid this inefficiency, we precompute coefficient tables spanning the \[0, 1\]^3 RGB color cube when pbrt is first compiled. It is worth noting that the tabulation could in principle also be performed over a lower-dimensional 2D space of chromaticities: for example, a computed spectrum representing the maximally saturated color red (1, 0, 0) could simply be scaled to reproduce less saturated RGB colors (c, 0, 0), where c (0, 1). However, spectra for highly saturated colors must necessarily peak within a small wavelength range to achieve this saturation, while less saturated colors can be represented by smoother spectra. This is generally preferable whenever possible due to the inherent smoothness of reflectance spectra encountered in physical reality.
][
  为了避免这种低效，我们在首次编译 `pbrt` 时预计算跨越 $[0 , 1]^3$ RGB 颜色空间立方体的系数表。值得注意的是，原则上也可以在较低维度的 2D 色度空间上进行表格化：例如，一个计算出的光谱表示最大饱和度的红色 $(1 , 0 , 0)$ 可以简单地缩放以再现较不饱和的 RGB 颜色 $(c , 0 , 0)$，其中 $c in (0 , 1)$。 然而，要实现这种饱和度，高度饱和的颜色的光谱必须在一个小的波长范围内达到峰值，而较不饱和的颜色可以由更平滑的光谱表示。由于物理现实中反射光谱的固有平滑性，这通常是更可取的。
]

#parec[
  We therefore precompute a full 3D tabulation for each RGB color space that pbrt supports (currently, sRGB, DCI-P3, Rec2020, and ACES2065-1). The implementation of this optimization step is contained in the file cmd/rgb2spec\_opt.cpp, though we will not discuss it in detail here; see the "Further Reading" section for additional information. Figure #link("<fig:rgb-albedo-spectrum>")[4.30] shows plots of spectra corresponding to a few RGB values.
][
  因此，我们为 `pbrt` 支持的每个 RGB 色彩空间（目前为 sRGB、DCI-P3、Rec2020 和 ACES2065-1）预计算一个完整的 3D 表格化。此优化步骤的实现包含在文件 `cmd/rgb2spec_opt.cpp` 中，尽管我们在此不详细讨论；有关更多信息，请参阅“进一步阅读”部分。 图 #link("<fig:rgb-albedo-spectrum>")[4.30] 显示了对应于一些 RGB 值的光谱图。
]



#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f30.svg"),
  caption: [
    #ez_caption[
      Spectra Computed from RGB Values. Plots of reflectance spectra represented by the RGBSigmoidPolynomial for the RGB colors $(0.7 comma 0.5 comma 0.8)$(purple line), $(0.25 comma 0.44 comma 0.33)$(green line), and $(0.36 comma 0.275 comma 0.21)$(brown line). Each line is colored with its corresponding RGB color.
    ][
      从RGB值计算的光谱。反射光谱的图表由RGBSigmoidPolynomial表示，针对以下RGB颜色：$(0.7, 0.5, 0.8)$（紫色线）、$(0.25, 0.44, 0.33)$（绿色线）和$(0.36, 0.275, 0.21)$（棕色线）。每条线的颜色与其对应的RGB颜色相同。
    ]
  ],
)
#parec[
  The resulting tables are stored in the pbrt binary. At system startup time, an RGBToSpectrumTable for each of the RGB color spaces is created.
][
  生成的表存储在 `pbrt` 二进制文件中。在系统启动时，为每个 RGB 色彩空间创建一个 `RGBToSpectrumTable`。
]

```cpp
// <<RGBToSpectrumTable Definition>>=
class RGBToSpectrumTable {
  public:
    // <<RGBToSpectrumTable Public Constants>>
    // <<RGBToSpectrumTable Public Methods>>
  private:
    // <<RGBToSpectrumTable Private Members>>
};
```

#parec[
  The principal method of RGBToSpectrumTable returns the RGBSigmoidPolynomial corresponding to the given RGB color.
][
  `RGBToSpectrumTable` 的主要方法返回给定 RGB 颜色对应的 `RGBSigmoidPolynomial`。
]

```cpp
// <<RGBToSpectrumTable Method Definitions>>=
RGBSigmoidPolynomial RGBToSpectrumTable::operator()(RGB rgb) const {
    // <<Handle uniform rgb values>>
    // <<Find maximum component and compute remapped component values>>
    // <<Compute integer indices and offsets for coefficient interpolation>>
    // <<Trilinearly interpolate sigmoid polynomial coefficients c>>
    return RGBSigmoidPolynomial(c[0], c[1], c[2]);
}
```

#parec[
  If the three RGB values are equal, it is useful to ensure that the returned spectrum is exactly constant. (In some cases, a slight color shift may otherwise be evident if interpolated values from the coefficient tables are used.) A constant spectrum results if c\_0 = c\_1 \= 0 in Equation ( #link("<eq:rgb-to-spectrum-spd>")[4.26] ) and the appropriate value of c\_2 can be found by inverting the sigmoid function.
][
  如果三个 RGB 值相等，确保返回的光谱是完全恒定的是有用的。（在某些情况下，如果使用系数表中的插值值，可能会明显出现轻微的颜色偏移。）如果在方程（ #link("<eq:rgb-to-spectrum-spd>")[4.26] ）中 $c_0 = c_1 = 0$，则结果为恒定光谱，并且可以通过反转 sigmoid 函数找到适当的 $c_2$ 值。
]

```cpp
<<Handle uniform rgb values>>=
if (rgb[0] == rgb[1] && rgb[1] == rgb[2])
    return RGBSigmoidPolynomial(
        0, 0, (rgb[0] - .5f) / std::sqrt(rgb[0] * (1 - rgb[0])));
```

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f31.svg"),
  caption: [#ez_caption[
      Figure #link("<fig:rgb-spectrum-ci-plots>")[4.31] shows plots of spectrum
      polynomial coefficients c\_i. These plots show the polynomial
      coefficients for the corresponding xy chromaticities in the sRGB color
      space. Each of (a) c\_0, (b) c\_1, and (c) c\_2 mostly vary smoothly,
      though they exhibit sharp transitions. (d) Partitioning the gamut
      according to which of red, green, or blue has the largest magnitude
      closely corresponds to these transitions; coefficients are therefore
      independently tabularized in those three regions.][
      图 4.31: 光谱多项式系数 $c_i$ 的图示。这些图显示了 sRGB
      色彩空间中对应 $x y$ 色度的多项式系数。每个 (a) $c_0$，(b) $c_1$ 和
      (c) $c_2$ 大多变化平滑，尽管它们表现出急剧的过渡。(d)
      根据红色、绿色或蓝色哪个具有最大幅度来划分色域，与这些过渡紧密对应；因此系数在这三个区域中独立表格化。
    ]],
)


#parec[
  The coefficients $c_i$ from the optimization are generally smoothly varying; small changes in RGB generally lead to small changes in their values. (This property also ends up being helpful for the smoothness goal.) However, there are a few regions of the RGB space where they change rapidly, which makes direct 3D tabularization of them prone to error in those regions—see Figure 4.31(a), (b), and (c). A better approach is to tabularize them independently based on which of the red, green, or blue RGB coefficients has the largest magnitude. This partitioning matches the coefficient discontinuities well, as is shown in Figure 4.31(d).

  A 3D tabularization problem remains within each of the three partitions. We will use the partition where the red component $r$ has the greatest magnitude to explain how the table is indexed. For a given $(r,g,b)$, the first step is to compute a renormalized coordinate
][
  优化中的系数 $c_i$ 通常是平滑变化的；RGB的微小变化通常会导致它们值的微小变化。（这一特性对于平滑性目标也很有帮助。）然而，在RGB空间的某些区域，它们的变化速度较快，这使得直接对这些区域进行3D表格化容易产生误差——见图4.31(a)、(b)和(c)。一种更好的方法是根据红色、绿色或蓝色RGB系数中哪个具有最大的幅度来分别对它们进行表格化。这种划分很好地匹配了系数的不连续性，如图4.31(d)所示。

  在每个三个划分中的3D表格化问题依然存在。我们将使用红色分量 $r$ 具有最大幅度的划分来解释表格的索引方式。对于给定的 $(r,g,b)$，第一步是计算一个重新标准化的坐标。
]
$ (x , y , z) = (g / r , b / r , r) . $
#parec[
  (By convention, the largest component is always mapped to $z$.) A similar remapping is applied if $g$ or $b$ is the maximum. With this mapping, all three coordinates span the range $[0 , 1]$, which makes it possible to make better use of samples in a fixed grid.
][
  （按照惯例，最大的分量总是映射到 $z$。）如果 $g$ 或 $b$ 是最大值，则应用类似的重新映射。通过这种映射，所有三个坐标都在 $[0 , 1]$ 范围内，这使得在固定网格中更好地利用样本成为可能。
]

```cpp
int maxc = (rgb[0] > rgb[1]) ? ((rgb[0] > rgb[2]) ? 0 : 2) :
                           ((rgb[1] > rgb[2]) ? 1 : 2);
float z = rgb[maxc];
float x = rgb[(maxc + 1) % 3] * (res - 1) / z;
float y = rgb[(maxc + 2) % 3] * (res - 1) / z;
```

#parec[
  The resolution of the tabularization, `res`, is the same in all three dimensions. Because it is set to be a compile time constant here, changing the size of the tables would require recompiling `pbrt`.
][
  因为 `res` 是编译时常量，改变表格的大小需要重新编译 `pbrt`。表格化处理的分辨率 `res` 在所有三个维度中都是相同的。
]

```cpp
static constexpr int res = 64;
```


#parec[
  An equally spaced discretization is used for the $x$ and $y$ coordinates in the coefficient tables, though $z$ is remapped through a nonlinear function that allocates more samples near both 0 and 1. The $c_i$ coefficients vary most rapidly in that region, so this remapping allocates samples more effectively.
][
  在系数表中，虽然 $z$ 通过一个在接近 0 和 1 的地方分配更多样本的非线性函数重新映射，但 $x$ 和 $y$ 坐标使用等间距离散化。 $c_i$ 系数在该区域变化最快，因此这种重新映射更有效地分配样本。
]

#parec[
  The `zNodes` array (which is of `res` elements) stores the result of the remapping where if $f$ is the remapping function then the $i$ th element of `zNodes` stores $f (i / upright("res"))$.
][
  `zNodes` 数组（有 `res` 个元素）存储重新映射的结果，其中如果 $f$ 是重新映射函数，则 `zNodes` 的第 $i$ 个元素存储 $f (i / upright("res"))$。
]

```cpp
const float *zNodes;
```


#parec[
  Finding integer coordinates in the table is simple for $x$ and $y$ given the equally spaced discretization. For $z$, a binary search through `zNodes` is required. Given these coordinates, floating-point offsets from them are then found for use in interpolation.
][
  在表中找到整数坐标对于 $x$ 和 $y$ 来说很简单，因为它们是等间距离散化的。对于 $z$，需要通过 `zNodes` 进行二分查找。给定这些坐标，然后找到用于插值的浮点偏移量。
]

```cpp
int xi = std::min((int)x, res - 2), yi = std::min((int)y, res - 2),
    zi = FindInterval(res, [&](int i) { return zNodes[i] < z; });
Float dx = x - xi, dy = y - yi,
      dz = (z - zNodes[zi]) / (zNodes[zi + 1] - zNodes[zi]);
```


#parec[
  We can now implement the fragment that trilinearly interpolates between the eight coefficients around the $(x , y , z)$ lookup point. The details of indexing into the coefficient tables are handled by the `co` lambda function, which we will define shortly, after describing the layout of the tables in memory. Note that although the $z$ coordinate has a nonlinear mapping applied to it, we still linearly interpolate between coefficient samples in $z$. In practice, the error from doing so is minimal.
][
  我们现在可以实现三线性插值在 $(x , y , z)$ 查找点周围的八个系数之间的片段。系数表的索引细节由 `co` Lambda 函数处理，我们将在描述内存中表的布局后不久定义它。注意，尽管对 $z$ 坐标应用了非线性映射，我们在 $z$ 中的系数样本之间仍然进行线性插值。实际上，这样做的误差是很小的。
]

```cpp
pstd::array<Float, 3> c;
for (int i = 0; i < 3; ++i) {
    auto co = [&](int dx, int dy, int dz) {
       return (*coeffs)[maxc][zi + dz][yi + dy][xi + dx][i];
    };
    c[i] = Lerp(dz, Lerp(dy, Lerp(dx, co(0, 0, 0), co(1, 0, 0)),
                         Lerp(dx, co(0, 1, 0), co(1, 1, 0))),
                Lerp(dy, Lerp(dx, co(0, 0, 1), co(1, 0, 1)),
                         Lerp(dx, co(0, 1, 1), co(1, 1, 1)));
}
```


#parec[
  The coefficients are stored in a five-dimensional array. The first dimension corresponds to whether $r$, $g$, or $b$ had the largest magnitude and the next three correspond to $z$, $y$, and $x$, respectively. The last dimension is over the three coefficients $c_i$.
][
  这些系数存储在一个五维数组中。第一个维度对应于 $r$ 、 $g$ 或 $b$ 是否具有最大幅度，接下来的三个对应于 $z$ 、 $y$ 和 $x$。最后一个维度是三个系数 $c_i$。
]

```cpp
using CoefficientArray = float[3][res][res][res][3];
```

```cpp
const CoefficientArray *coeffs;
```


#parec[
  The coefficient lookup lambda function is now just a matter of using the correct values for each dimension of the array. The provided integer deltas are applied in $x$, $y$, and $z$ when doing so.
][
  系数查找 Lambda 函数现在只是使用数组每个维度的正确值的问题。在这样做时，提供的整数增量应用于 $x$ 、 $y$ 和 $z$。
]

```cpp
auto co = [&](int dx, int dy, int dz) {
    return (*coeffs)[maxc][zi + dz][yi + dy][xi + dx][i];
};
```

#parec[
  With `RGBSigmoidPolynomial`'s implementation complete, we can now add a method to `RGBColorSpace` to transform an RGB in its color space to an `RGBSigmoidPolynomial`.
][
  随着 `RGBSigmoidPolynomial` 的实现完成，我们现在可以向 `RGBColorSpace` 添加一个方法，以将其颜色空间中的 RGB 转换为 `RGBSigmoidPolynomial`。
]

```cpp
RGBSigmoidPolynomial RGBColorSpace::ToRGBCoeffs(RGB rgb) const {
    return (*rgbToSpectrumTable)(ClampZero(rgb));
}
```

#parec[
  With these capabilities, we can now define the `RGBAlbedoSpectrum` class, which implements the `Spectrum` interface to return spectral samples according to the sigmoid-polynomial model.
][
  有了这些功能，我们现在可以定义 `RGBAlbedoSpectrum` 类，该类实现 `Spectrum` 接口以根据 sigmoid-polynomial 模型返回光谱样本。
]

```cpp
class RGBAlbedoSpectrum {
  public:
    Float operator()(Float lambda) const { return rsp(lambda); }
    Float MaxValue() const { return rsp.MaxValue(); }
    PBRT_CPU_GPU
    RGBAlbedoSpectrum(const RGBColorSpace &cs, RGB rgb);

    PBRT_CPU_GPU
    SampledSpectrum Sample(const SampledWavelengths &lambda) const {
        SampledSpectrum s;
        for (int i = 0; i < NSpectrumSamples; ++i)
            s[i] = rsp(lambda[i]);
        return s;
    }

    std::string ToString() const;
  private:
    RGBSigmoidPolynomial rsp;
};
```



#parec[
  Runtime assertions in the constructor, not shown here, verify that the provided RGB value is between 0 and 1.
][
  构造函数中的运行时断言（此处未显示）用于验证提供的 RGB 值在 0 和 1 之间。
]

```cpp
RGBAlbedoSpectrum::RGBAlbedoSpectrum(const RGBColorSpace &cs, RGB rgb) {
    rsp = cs.ToRGBCoeffs(rgb);
}
```

#parec[
  The only member variable necessary is one to store the polynomial coefficients.
][
  唯一需要的成员变量是用于存储多项式系数的。
]

```cpp
RGBSigmoidPolynomial rsp;
```


#parec[
  Implementation of the required `Spectrum` methods is a matter of forwarding the requests on to the appropriate `RGBSigmoidPolynomial` methods. As with most `Spectrum` implementations, we will not include the `Sample()` method here since it just loops over the wavelengths and evaluates Equation (4.26) at each one.
][
  所需的 `Spectrum` 方法的实现是将请求转发到适当的 `RGBSigmoidPolynomial` 方法。与大多数 `Spectrum` 实现一样，我们不会在此处包含 `Sample()` 方法，因为它只是遍历波长并在每个波长处评估方程 (4.26)。
]


==== Unbounded RGB
<unbounded-rgb>
#parec[
  For unbounded (positive-valued) RGB values, the `RGBSigmoidPolynomial` foundation can still be used—just with the addition of a scale factor that remaps its range to the necessary range for the given RGB. That approach is implemented in the `RGBUnboundedSpectrum` class.
][
  对于无限（正值）RGB值，仍然可以使用`RGBSigmoidPolynomial`基础——只需添加一个缩放因子，将其范围重新映射到给定RGB的必要范围即可。这种方法在`RGBUnboundedSpectrum`类中实现。
]

```cpp
class RGBUnboundedSpectrum {
  public:
    <<RGBUnboundedSpectrum Public Methods>>
    Float operator()(Float lambda) const { return scale * rsp(lambda); }
    Float MaxValue() const { return scale * rsp.MaxValue(); }
    PBRT_CPU_GPU
    RGBUnboundedSpectrum(const RGBColorSpace &cs, RGB rgb);

    PBRT_CPU_GPU
    RGBUnboundedSpectrum()
        : rsp(0, 0, 0), scale(0) {}

    PBRT_CPU_GPU
    SampledSpectrum Sample(const SampledWavelengths &lambda) const {
        SampledSpectrum s;
        for (int i = 0; i < NSpectrumSamples; ++i)
            s[i] = scale * rsp(lambda[i]);
        return s;
    }

    std::string ToString() const;
  private:
    <<RGBUnboundedSpectrum Private Members>>
    Float scale = 1;
    RGBSigmoidPolynomial rsp;
};
```

#parec[
  A natural choice for a scale factor would be one over the maximum of the red, green, and blue color components. We would then use that to normalize the RGB value before finding polynomial coefficients and then rescale values returned by `RGBSigmoidPolynomial` accordingly. However, it is possible to get better results by instead normalizing RGB to have a maximum value of $1 / 2$ rather than 1. The reason is illustrated in Figure 4.32: because reflectance spectra must not exceed one, when highly saturated colors are provided, the resulting spectra may have unusual features, including large magnitudes in the unsaturated region of the spectrum. Rescaling to $1 / 2$ gives the fit more room to work with, since the normalization constraint does not immediately affect it.
][
  一个自然的缩放因子选择是红、绿、蓝颜色分量的最大值的倒数。然后我们可以用它来在找到多项式系数之前对RGB值进行标准化，然后相应地重新缩放`RGBSigmoidPolynomial`返回的值。然而，通过将RGB标准化为最大值为 $1 / 2$ 而不是1，可以获得更好的结果。原因如图4.32所示：因为反射光谱不能超过1，当提供高饱和度颜色时，生成的光谱可能具有意想不到的特征，包括在光谱的不饱和区域具有大的幅度。重新缩放到 $1 / 2$ 给拟合提供了更多的空间，因为标准化约束不会立即影响它。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f32.svg"),
  caption: [
    #ez_caption[With the sigmoid polynomial representation, highly
      saturated colors may end up with unexpected features in their spectra.
      Here we have plotted the spectrum returned by `RGBAlbedoSpectrum` for
      the RGB color $(0.95 , 0.05 , 0.025)$ as well as that color with all
      components divided by two. With the original color, we see a wide range
      of the higher wavelengths are near 1 and that the lower wavelengths have
      more energy than expected. If that color is divided by two, the
      resulting spectrum is better behaved, though note that its magnitude
      exceeds the original red value of $0.475$ in the higher wavelengths.
    ][
      图4.32：使用S型多项式表示，高饱和度颜色可能在其光谱中出现意想不到的特征。这里我们绘制了`RGBAlbedoSpectrum`为RGB颜色$(0.95 , 0.05 , 0.025)$返回的光谱，以及该颜色的所有分量除以二后的光谱。对于原始颜色，我们看到较高波长的范围接近1，而较低波长的能量比预期的多。如果将该颜色除以二，得到的光谱表现得更为稳定，尽管注意到在较高波长中其幅度超过了原始红色值$0.475$。
    ]
  ],
)


```cpp
<<Spectrum Method Definitions>>+=
RGBUnboundedSpectrum::RGBUnboundedSpectrum(const RGBColorSpace &cs,
                                           RGB rgb) {
    Float m = std::max({rgb.r, rgb.g, rgb.b});
    scale = 2 * m;
    rsp = cs.ToRGBCoeffs(scale ? rgb / scale : RGB(0, 0, 0));
}
<<RGBUnboundedSpectrum Private Members>>=
Float scale = 1;
RGBSigmoidPolynomial rsp;
```

#parec[
  In comparison to the `RGBAlbedoSpectrum` implementation, the wavelength evaluation and `MaxValue()` methods here are just augmented with a multiplication by the scale factor. The `Sample()` method has been updated similarly, but is not included here.
][
  与`RGBAlbedoSpectrum`实现相比，这里的波长评估和`MaxValue()`方法只是增加了一个乘以缩放因子的操作。`Sample()`方法也进行了类似的更新，但这里不包括。
]

==== RGB Illuminants
<rgb-illuminants>
#parec[
  As illustrated in the plots of illuminant spectra in @standard-illuminants, real-world illuminants often have complex spectral distributions. Given a light source specified using RGB color, we do not attempt to infer a complex spectral distribution but will stick with a smooth spectrum, scaled appropriately. The details are handled by the `RGBIlluminantSpectrum` class.
][
  如@standard-illuminants 中光源光谱的图示所示，现实世界的光源通常具有复杂光谱分布。给定使用RGB颜色指定的光源，我们不尝试推断复杂的光谱分布，而是坚持使用平滑光谱，并进行适当的缩放。详细信息由`RGBIlluminantSpectrum`类处理。
]

```cpp
class RGBIlluminantSpectrum {
  public:
    <<RGBIlluminantSpectrum Public Methods>>
    RGBIlluminantSpectrum() = default;
    RGBIlluminantSpectrum(const RGBColorSpace &cs, RGB rgb);
    Float operator()(Float lambda) const {
        if (!illuminant) return 0;
        return scale * rsp(lambda) * (*illuminant)(lambda);
    }
    Float MaxValue() const {
        if (!illuminant) return 0;
        return scale * rsp.MaxValue() * illuminant->MaxValue();
    }
    const DenselySampledSpectrum *Illuminant() const {
        return illuminant;
    }
    PBRT_CPU_GPU
    SampledSpectrum Sample(const SampledWavelengths &lambda) const {
        if (!illuminant) return SampledSpectrum(0);
        SampledSpectrum s;
        for (int i = 0; i < NSpectrumSamples; ++i)
            s[i] = scale * rsp(lambda[i]);
        return s * illuminant->Sample(lambda);
    }

    std::string ToString() const;
  private:
    <<RGBIlluminantSpectrum Private Members>>
    Float scale;
    RGBSigmoidPolynomial rsp;
    const DenselySampledSpectrum *illuminant;
};
```


#parec[
  Beyond a scale factor that is equivalent to the one used in `RGBUnboundedSpectrum` to allow an arbitrary maximum RGB value, the `RGBIlluminantSpectrum` also multiplies the value returned at the given wavelength by the value of the color space's standard illuminant at that wavelength. A non-intuitive aspect of spectral modeling of illuminants is that uniform spectra generally do not map to neutral white colors following conversion to RGB. Color spaces always assume that the viewer is adapted to some type of environmental illumination that influences color perception and the notion of a neutral color. For example, the commonly used D65 whitepoint averages typical daylight illumination conditions. To reproduce illuminants with a desired color, we therefore use a crude but effective solution, which is to multiply the whitepoint with a suitable reflectance spectra. Conceptually, this resembles viewing a white reference light source through a colored film. It also ensures that white objects lit by white lights lead to white pixel values in the rendered image.
][
  除了与`RGBUnboundedSpectrum`中使用的等效缩放因子以允许任意最大RGB值之外，`RGBIlluminantSpectrum`还将给定波长返回的值乘以该波长处颜色空间的标准光源的值。光源光谱建模的一个非直观方面是，均匀光谱通常不会在转换为RGB后映射到中性色白。颜色空间总是假设观察者适应某种类型的环境光照，这影响颜色感知和中性色的概念。例如，常用的D65白点平均了典型的日光照明条件。因此，为了重现具有期望颜色的光源，我们使用一种粗略但有效的解决方案，即将白点与合适的反射光谱相乘。从概念上讲，这类似于通过彩色薄膜查看白色基准光源。这也确保了由白光照射的白色物体在渲染图像中产生白色像素数值。
]

```cpp
RGBIlluminantSpectrum::RGBIlluminantSpectrum(const RGBColorSpace &cs, RGB rgb)
    : illuminant(&cs.illuminant) {
    Float m = std::max({rgb.r, rgb.g, rgb.b});
    scale = 2 * m;
    rsp = cs.ToRGBCoeffs(scale ? rgb / scale : RGB(0, 0, 0));
}
```

#parec[
  Thus, a pointer to the illuminant is held in a member variable.
][
  因此，光源的指针保存在一个成员变量中。
]

```cpp
Float scale;
RGBSigmoidPolynomial rsp;
const DenselySampledSpectrum *illuminant;
```


#parec[
  Implementations of the various `Spectrum` interface methods follow; here is the one that evaluates the spectral distribution at a single wavelength. One detail is that it must handle the case of a `nullptr` `illuminant`, as will happen if an `RGBIlluminantSpectrum` is default-initialized. In that case, a zero-valued spectrum should be the result.
][
  以下是各种`Spectrum`接口方法的实现；这里是评估单个波长处光谱分布的方法。一个细节是它必须处理`illuminant`为`nullptr`的情况，这将在`RGBIlluminantSpectrum`默认初始化时发生。在这种情况下，结果应该是一个零值光谱。
]

```cpp
Float operator()(Float lambda) const {
    if (!illuminant) return 0;
    return scale * rsp(lambda) * (*illuminant)(lambda);
}
```


#parec[
  We will not include the implementations of the `Sample()` or `MaxValue()` methods here, as their implementations are as would be expected.
][
  我们不会在这里包括`Sample()`或`MaxValue()`方法的实现，因为它们的实现是预期的。
]


