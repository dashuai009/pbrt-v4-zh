#import "../template.typ": parec, translator

== Sampling 1D Functions

#parec[
  Throughout the implementation of `pbrt` we have found it
  useful to draw samples from a wide variety of functions. This section
  therefore presents the implementations of additional functions for
  sampling in 1D to augment the ones in Section 2.3.2. All are based on
  the inversion method and most introduce useful tricks for sampling that
  are helpful to know when deriving new sampling algorithms.
][
  在 `pbrt`
  的实现过程中，我们发现从各种不同的函数中进行采样非常有用。因此，本节介绍了一些额外的一维采样函数的实现，用来补充第
  2.3.2
  节中的方法。所有方法都基于反演法，大多数方法还引入了一些在推导新采样算法时十分有用的小技巧。
]



#parec[
  `SampleTent()` uses `SampleLinear()` to sample the "tent"
  function with radius $r$,
][
  `SampleTent()` 使用 `SampleLinear()`
  来对半径为 $r$ 的“帐篷函数”进行采样：
]

```cpp
Float SampleTent(Float u, Float r) {
    if (SampleDiscrete({0.5f, 0.5f}, u, nullptr, &u) == 0)
        return -r + r * SampleLinear(u, 0, 1);
    else
        return r * SampleLinear(u, 1, 0);
}
```

#parec[
  The tent function is easily normalized to find its PDF.
][

  帐篷函数很容易归一化以得到它的 PDF：
]

```cpp
Float TentPDF(Float x, Float r) {
    if (std::abs(x) >= r)
        return 0;
    return 1 / r - std::abs(x) / Sqr(r);
}
```

#parec[
  The inversion function is based on InvertLinearSample.
][

  反演函数基于 `InvertLinearSample`：
]

```cpp
inline Float InvertTentSample(Float x, Float r) {
    if (x <= 0)
        return (1 - InvertLinearSample(-x / r, 1, 0)) / 2;
    else
        return 0.5f + InvertLinearSample(x / r, 1, 0) / 2;
}
```



#parec[
  Sampling the transmittance function when rendering images with
  participating media often requires samples from a distribution
  $p (x) prop e^(- a x)$. As before, the first step is to find a constant
  $c$ that normalizes this distribution so that it integrates to one. In
  this case, we will assume for now that the range of values $x$ we’d like
  the generated samples to cover is $\\[0, inf)$ rather than
  $\\[0, 1
  ]$, so
][

  在渲染含有参与介质的图像时，采样透射率函数通常需要从一个分布
  $p (x) prop e^(- a x)$ 中取样。与之前一样，第一步是找到一个常数
  $c$，使该分布归一化，从而积分为
  1。在这里，我们假设生成样本所覆盖的范围是 $\\[0, inf)$，而不是
  $\\[0, 1
  ]$，因此有：
]

```tex
c \inf_0^∞ e^{-a x} dx = - (c / a) e^{-a x} |_{0}^{∞} = (c / a) = 1  →  c = a
```

#parec[
  Thus, $c = a$ and our PDF is $p (x) = a , e^(- a x)$.
][

  因此，$c = a$，我们的 PDF 为 $p (x) = a , e^(- a x)$。
]

```cpp
Float ExponentialPDF(Float x, Float a) {
    return a * std::exp(-a * x);
}
```

#parec[
  We can integrate to find $P (x)$:
][
  我们可以通过积分得到
  $P (x)$：
]

```tex
upper P(x) = \inf_0^x a e^{-a x'} dx' = 1 - e^{-a x}
```

#parec[
  Therefore, we can draw samples using
][

  因此，我们可以通过以下方式进行采样：
]

```cpp
Float InvertExponentialSample(Float x, Float a) {
    return 1 - std::exp(-a * x);
}
```

#parec[
  It may be tempting to simplify the log term from $ln (1 - x)$
  to $ln x$, under the theory that because $x \\in \\[0,1)$ these are
  effectively the same and a subtraction can thus be saved. The problem
  with this idea is that $x$ may have the value 0 but never has the value
  1. With the simplification, it is possible that we would try to take the
  logarithm of 0, which is undefined; this danger is avoided with the
  first formulation. While a $x = 0$ value may seem very unlikely, it is
  possible, especially in the world of floating-point arithmetic and not
  the real numbers. Sample generation algorithms based on the radical
  inverse function are particularly prone to generating the value 0.
][

  人们可能会想把对数项 $ln (1 - x)$ 简化为 $ln x$，理由是
  $x \\in \\[0,1)$
  时它们几乎等价，从而节省一次减法操作。然而问题在于，$x$ 可以取到 0
  但永远不会取到 1。在这种简化下，我们可能会尝试对 0
  取对数，这是未定义的；而原始公式避免了这一风险。虽然 $x = 0$
  看似极不可能，但在浮点数运算而非实数的世界里，它是可能出现的。特别是基于基数逆函数（radical
  inverse function）的采样算法很容易生成 0。
]

#parec[
  As before, the inverse sampling function is given by
  evaluating $P (x)$.
][
  与之前一样，反演采样函数通过计算 $P (x)$
  得到。
]

```cpp
Float InvertExponentialSample(Float x, Float a) {
    return 1 - std::exp(-a * x);
}
```

#parec[
  The Gaussian function is parameterized by its center $mu$ and
  standard deviation $sigma$:
][
  高斯函数由其中心 $mu$ 和标准差 $sigma$
  参数化：
]

```tex
g(x) = \frac{1}{\sqrt{2 \pi \sigma^2}} \exp\left(-\frac{(x-\mu)^2}{2 \sigma^2}\right)
```

#parec[
  The probability distribution it defines is called the normal
  distribution. The Gaussian is already normalized, so the PDF follows
  directly.
][
  它所定义的概率分布称为正态分布。高斯函数已经归一化，因此
  PDF 可以直接得到：
]

```cpp
Float NormalPDF(Float x, Float mu = 0, Float sigma = 1) {
    return Gaussian(x, mu, sigma);
}
```

#parec[
  However, the Gaussian’s CDF cannot be expressed with
  elementary functions. It is
][
  然而，高斯分布的 CDF
  无法用初等函数表示，它的形式为：
]

```tex
upper P(x) = ½ [1 + erf((x - mu) / (sigma √2))]
```

#parec[
  where erf is the error function. If we equate xi = P(x) and
  solve, we find that:
][
  其中 erf 是误差函数。如果令 $xi = P (x)$ 并解出
  $x$，得到：
]

```tex
x = mu + √2 σ erf^{-1}(2 ξ - 1)
```

#parec[
  The inverse error function can be well approximated with a
  polynomial, which in turn gives a sampling technique.
][

  误差函数的反函数可以通过多项式很好地近似，从而得到一种采样方法：
]

```cpp
Float SampleNormal(Float u, Float mu = 0, Float sigma = 1) {
    return mu + Sqrt2 * sigma * ErfInv(2 * u - 1);
}
```

#parec[
  InvertNormalSample(), not included here, evaluates upper
  P(x).
][
  未在此列出的 `InvertNormalSample()` 函数用于计算 $P (x)$。
]

#parec[
  The Box–Muller transform is an alternative sampling technique
  for the normal distribution; it takes a pair of random samples and
  returns a pair of normally distributed samples. It makes use of the fact
  that if two normally distributed variables are considered as a 2D point
  and transformed to 2D polar coordinates $(r , theta)$, then
  $r^2 = - 2 ln xi_1$ and $theta = 2 pi xi_2$.
][
  Box–Muller
  变换是另一种正态分布采样技术；它接收一对随机样本并返回一对服从正态分布的样本。其原理是：若将两个正态分布的变量视为一个二维点并转换为极坐标
  $(r , theta)$，则 $r^2 = - 2 ln xi_1$ 且 $theta = 2 pi xi_2$。
]

```cpp
Point2f SampleTwoNormal(Point2f u, Float mu = 0, Float sigma = 1) {
    Float r2 = -2 * std::log(1 - u[0]);
    return {mu + sigma * std::sqrt(r2 * std::cos(2 * Pi * u[1])),
            mu + sigma * std::sqrt(r2 * std::sin(2 * Pi * u[1]))};
}
```

#parec[
  The logistic function is shaped similarly to the Gaussian, but
  can be sampled directly. It is therefore useful in cases where a
  distribution similar to the Gaussian is useful but an exact Gaussian is
  not needed. (It is used, for example, in the implementation of pbrt’s
  scattering model for hair.) The logistic function centered at the origin
  is
][

  逻辑斯蒂函数的形状与高斯函数相似，但它可以直接采样。因此，在需要类似高斯的分布但并不需要精确高斯时，它非常有用。（例如，它在
  `pbrt` 的毛发散射模型实现中被使用。）以原点为中心的逻辑斯蒂函数为：
]

```tex
f(x) = \frac{e^{-|x|/s}}{s (1 + e^{-|x|/s})^2}
```

#parec[
  where $s$ is a parameter that controls its rate of falloff
  similar to $sigma$ in the Gaussian. Figure A.4 shows a plot of the
  logistic and Gaussian functions with parameter values that lead to
  curves with similar shapes.
][
  $s$
  是一个参数，用来控制衰减速率，类似于高斯分布中的 $sigma$。图 A.4
  显示了逻辑斯蒂函数和高斯函数在某些参数下的对比曲线，它们的形状十分相似。
]

```cpp
Float LogisticPDF(Float x, Float s) {
    x = std::abs(x);
    return std::exp(-x / s) / (s * Sqr(1 + std::exp(-x / s)));
}
```

#parec[
  Its CDF,
][
  它的 CDF 为：
]

```tex
upper P(x) = \frac{1}{1 + e^{-x/s}}
```

#parec[
  is easily found, and can be inverted to derive a sampling
  routine. The result is implemented in the function below.
][

  很容易求出，并且可以反演从而得到采样过程。结果实现如下：
]

```cpp
Float SampleLogistic(Float u, Float s) {
    return -s * std::log(1 / u - 1);
}
```

#parec[
  As usual in 1D, the sample inversion method is performed by
  evaluating the CDF.
][
  和一维采样中一样，反演方法通过计算 CDF
  来完成：
]

```cpp
Float InvertLogisticSample(Float x, Float s) {
    return 1 / (1 + std::exp(-x / s));
}
```

好的，我们继续从 #strong[A.4.5 Sampling a Function over an Interval]
开始。



#parec[
  It is sometimes useful to sample from a function’s
  distribution over a specified interval [a, b
  ]. It turns out that this
  is easy to do if we are able to evaluate the function’s CDF. We will use
  the logistic function as an example here, though the underlying
  technique applies more generally.
][
  有时需要在指定区间 $[a, b
  ]$
  上对一个函数的分布进行采样。如果我们能够计算该函数的
  CDF，这件事会变得很容易。这里我们用逻辑斯蒂函数作为示例，但其底层技术更普遍适用。
]

#parec[
  First consider the task of finding the PDF of the function
  limited to the interval, $p\_{\\[a,b
    ]}(x)$: we need to renormalize
  it. Doing so requires being able to integrate $p (x)$, which is
  otherwise known as finding its CDF:
][
  首先考虑在区间限制下求函数的
  PDF，记作 $p\_{\\[a,b
    ]}(x)$：我们需要对其重新归一化。这需要能够对
  $p (x)$ 积分，也就是找到它的 CDF：
]

```tex
p_{[a,b]}(x) = \frac{p(x)}{\int_a^b p(x) dx} \quad\Rightarrow\quad
\text{upper P}_{[a,b]}(x) = \frac{\text{upper P}(x) - \text{upper P}(a)}{\text{upper P}(b) - \text{upper P}(a)}
```

#parec[
  Next, consider sampling using the inversion method. Following
  the definition of $p\_{\\[a,b
    ]}(x)$, we see that the CDF associated
  with $p\_{\\[a,b
    ]}(x)$ is
][
  接下来，考虑使用反演法进行采样。根据
  $p\_{\\[a,b
    ]}(x)$ 的定义，我们看到其对应的 CDF 为：
]

```tex
upper P_{[a,b]}(x) = \frac{\text{upper P}(x) - \text{upper P}(a)}{\text{upper P}(b) - \text{upper P}(a)}
```

#parec[
  Thus, if we compute a new xi value (that, in a slight abuse of
  notation, is not between 0 and 1) by using xi to linearly interpolate
  between upper P(a) and upper P(b) and then apply the original sampling
  algorithm, we will generate a sample from the distribution over the
  interval [a, b
  ].
][
  因此，如果我们通过 $xi$ 在 $P (a)$ 与 $P (b)$
  之间进行线性插值计算一个新的值（严格来说，这个值并不在 $\\[0,1
  ]$
  内），然后再应用原始采样算法，就能从区间 $\\[a, b
  ]$
  的分布中生成样本。
]

```cpp
Float SampleTrimmedLogistic(Float u, Float s, Float a, Float b) {
    auto P = [&](Float x) { return InvertLogisticSample(x, s); };
    u = Lerp(u, P(a), P(b));
    Float x = SampleLogistic(u, s);
    return Clamp(x, a, b);
}
```

#parec[
  The inversion routine follows directly from Equation
  (A.17).
][
  反演过程直接来自公式 (A.17)：
]

```cpp
Float InvertTrimmedLogisticSample(Float x, Float s, Float a, Float b) {
    auto P = [&](Float x) { return InvertLogisticSample(x, s); };
    return (P(x) - P(a)) / (P(b) - P(a));
}
```



#parec[
  It was not possible to invert the normal distribution’s CDF to
  derive a sampling technique, so there we used a polynomial approximation
  of the inverse CDF. In cases like that, another option is to use
  numerical root-finding techniques. We will demonstrate that approach
  using the smoothstep function as an example.
][
  正态分布的 CDF
  无法直接反演来推导采样方法，因此我们之前使用了逆 CDF
  的多项式近似。在这种情况下，另一种选择是使用数值求根技术。这里我们用
  smoothstep 函数作为例子来展示这种方法。
]

#parec[
  Smoothstep defines an S-shaped curve based on a third-degree
  polynomial that goes from zero to one starting at a point $a$ and ending
  at a point $b$. It is zero for values $x < a$ and one for values
  $x > b$. Otherwise, it is defined as
][
  Smoothstep
  定义了一条基于三次多项式的 S 形曲线，它从点 $a$ 开始从 0 上升到点 $b$ 的
  1。对于 $x < a$，函数值为 0；对于 $x > b$，函数值为
  1；在中间区间则定义为：
]

```tex
f(x) = 3 t^2 - 2 t^3, \quad t = (x - a) / (b - a)
```

#parec[
  In `pbrt` the smoothstep function is used to define the
  falloff at the edges of a spotlight.
][
  在 `pbrt` 中，smoothstep
  函数被用于定义聚光灯边缘的衰减。
]

#parec[
  We will consider the task of sampling the function within the
  range [a, b
  ]. First, it is easy to show that the PDF is
][

  我们考虑在区间 $\\[a, b
  ]$ 内对该函数采样。首先，可以容易地证明 PDF
  为：
]

```tex
p(x) = \frac{2 f(x)}{b - a}
```

#parec[
  Integrating the PDF is also easy; the resulting CDF is
][
  对
  PDF 积分也很简单，得到的 CDF 为：
]

```tex
upper P(x) = \frac{2 t^3 - t^4}{b - a}
```

#parec[
  The challenge in sampling $f$ is evident: doing so requires
  solving a fourth-degree polynomial.
][
  采样 $f$
  的难点显而易见：它需要解一个四次多项式。
]

#parec[
  The sampling task can be expressed as a zero-finding problem:
  to apply the inversion method, we would like to solve xi = upper P(X)
  for X. Doing so is equivalent to finding the value X such that upper
  P(X) − xi = 0. The following function uses a Newton–Bisection solver
  that is defined in Section B.2.10 to do this. That function takes a
  callback that returns the value of the function and its derivative at a
  given point; these values are easily computed given the equations
  derived so far.
][

  采样任务可以表述为一个求根问题：为了应用反演法，我们需要解方程
  $xi = P (X)$，即找到使 $P (X) - xi = 0$ 的 $X$。下面的函数使用第 B.2.10
  节定义的牛顿–二分法求解器来完成这一任务。该函数接收一个回调，用于返回某一点的函数值和导数；利用我们之前推导的公式，这些值很容易计算。
]

```cpp
Float SampleSmoothStep(Float u, Float a, Float b) {
    auto cdfMinusU = [=](Float x) -> std::pair<Float, Float> {
        Float t = (x - a) / (b - a);
        Float P = 2 * Pow<3>(t) - Pow<4>(t);
        Float PDeriv = SmoothStepPDF(x, a, b);
        return {P - u, PDeriv};
    };
    return NewtonBisection(a, b, cdfMinusU);
}
```

#parec[
  Sample inversion can be performed following the same approach
  as was used earlier in Equation (A.17) for the logistic over an
  interval.
][
  反演采样可以采用与之前逻辑斯蒂函数在区间上的方法（公式
  (A.17)）相同的方式进行：
]

```cpp
Float InvertSmoothStepSample(Float x, Float a, Float b) {
    Float t = (x - a) / (b - a);
    auto P = [&](Float x) { return 2 * Pow<3>(t) - Pow<4>(t); };
    return (P(x) - P(a)) / (P(b) - P(a));
}
```



#parec[
  The inversion method can also be applied to tabularized
  functions; in this section, we will consider piecewise-constant
  functions defined over [0, 1
  ]. The algorithms described here will
  provide the foundation for sampling piecewise-constant 2D functions,
  used in multiple parts of pbrt to sample from distributions defined by
  images.
][

  反演法同样可以应用于表格化的函数；在本节中，我们考虑定义在区间
  $\\[0, 1
  ]$
  上的分段常数函数。这里描述的算法将为二维分段常数函数的采样奠定基础，而这些函数在
  `pbrt` 的多个部分中被用于从图像定义的分布中采样。
]

#parec[
  Assume that the 1D function’s domain is split into $n$
  equal-sized pieces of size Δ = 1 / n.~These regions start and end at
  points $x_i = i Delta$, where $i$ ranges from 0 to $n$, inclusive.
  Within each region, the value of the function $f (x)$ is a constant
  (Figure A.5(a)).
][
  假设将该一维函数的定义域划分为 $n$
  个大小相等的区间，每个区间的长度为 $Delta = 1 \/ n$。这些区间在
  $x_i = i Delta$ 处开始和结束，其中 $i$ 从 0 到 $n$。在每个区间内，函数
  $f (x)$ 的值是一个常数（见图 A.5(a)）。
]

```tex
f(x) = { v_0, 0 <= x < x_1
       { v_1, x_1 <= x < x_2
       { ...
       { v_{n-1}, x_{n-1} <= x < x_n
```

#parec[
  The function need not always be positive, though its PDF must
  be. Therefore, the absolute value of the function is taken to define its
  PDF. The integral |f(x)| dx is
][
  函数不一定总是正的，但它的 PDF
  必须是非负的。因此我们取其绝对值来定义 PDF。积分
  $integral lr(|f (x)|) d x$ 为：
]

```tex
c = \inf_0^1 |f(x)| dx = sum_{i=0}^{n-1} |v_i| Δ
```

#parec[
  The integral of the absolute value of the function is made
  available via a method and the size() method returns the number of
  tabularized values.
][
  函数绝对值的积分可以通过一个方法获得，`size()`
  方法返回表格化值的数量。
]

```cpp
class PiecewiseConstant1D {
  public:
    // public methods...
    Float funcInt = 0;
};
```

#parec[
  The constructor makes its own copy of the function values and
  computes the function’s CDF. It allocates $n + 1$ Floats for the CDF
  array because if $f (x)$ has $n$ step values, then there are $n + 1$
  values P(x\_i) that define the CDF. Storing the final CDF value of 1 is
  redundant but simplifies the sampling code later.
][

  构造函数会复制函数值并计算函数的 CDF。它为 CDF 数组分配 $n + 1$
  个浮点数，因为如果 $f (x)$ 有 $n$ 个阶梯值，那么定义 CDF 的 $P (x_i)$ 有
  $n + 1$ 个。存储最终的 CDF 值 1 虽然冗余，但能简化后续的采样代码。
]

好的，我们继续把 #strong[PiecewiseConstant1D] 类剩余的部分翻译完。



```cpp
PiecewiseConstant1D(pstd::span<const Float> f, Float min, Float max,
                    Allocator alloc = {})
    : func(f.begin(), f.end(), alloc), cdf(f.size() + 1, alloc),
      min(min), max(max) {
    // Take absolute value of func
    for (Float &f : func) f = std::abs(f);

    // Transform step function integral into CDF
    cdf[0] = 0;
    size_t n = f.size();
    for (size_t i = 1; i < n + 1; ++i)
        cdf[i] = cdf[i - 1] + func[i - 1] * (max - min) / n;

    funcInt = cdf[n];
    if (funcInt == 0)
        for (size_t i = 1; i < n + 1; ++i)
            cdf[i] = Float(i) / Float(n);
    else
        for (size_t i = 1; i < n + 1; ++i)
            cdf[i] /= funcInt;
}
```

#parec[
  The public members are
][
  公共成员包括：
]

```cpp
pstd::vector<Float> func, cdf;
Float min, max;
```

#parec[
  The value of the integral of the absolute value is available
  via
][
  绝对值积分的值可通过以下函数获取：
]

```cpp
Float Integral() const { return funcInt; }
size_t size() const { return func.size(); }
```

#parec[
  The PiecewiseConstant1D class provides a sampling method. It
  returns the sampled value $x$ and the value of the PDF $p (x)$. If the
  optional offset parameter is not null, it returns the offset into the
  array of function values of the largest index where the CDF was less
  than or equal to $u$.
][
  `PiecewiseConstant1D`
  类提供了一个采样方法。它返回采样值 $x$ 以及对应的 PDF 值
  $p (x)$。如果可选参数 offset
  非空，则返回函数值数组中的下标，该下标是满足 CDF 不大于 $u$
  的最大索引。
]

```cpp
Float Sample(Float u, Float *pdf = nullptr, int *offset = nullptr) const {
    // Find surrounding CDF segments and offset
    int o = FindInterval((int)cdf.size(),
                         [&](int index) { return cdf[index] <= u; });
    if (offset)
        *offset = o;

    // Compute offset along CDF segment
    Float du = u - cdf[o];
    if (cdf[o + 1] - cdf[o] > 0)
        du /= cdf[o + 1] - cdf[o];

    // Compute PDF for sampled offset
    if (pdf)
        *pdf = (funcInt > 0) ? func[o] / funcInt : 0;

    // Return x corresponding to sample
    return Lerp((o + du) / size(), min, max);
}
```

#parec[
  Mapping $u$ to an interval matching the above criterion is
  carried out using the efficient binary search implemented in
  FindInterval.
][
  将 $u$ 映射到符合上述条件的区间是通过 `FindInterval`
  实现的高效二分查找完成的。
]

```cpp
int o = FindInterval((int)cdf.size(),
                     [&](int index) { return cdf[index] <= u; });
if (offset)
    *offset = o;
```

#parec[
  Given the pair of CDF values that straddle $u$, we can compute
  $x$. First, we determine how far $u$ is between $"cdf"\\[o
  ]$ and
  $"cdf"\\[o+1
  ]$. We denote this value with $d u$, where $d u$ is 0 if
  $u == "cdf"\\[o
  ]$ and goes up to 1 if $u == "cdf"[o+1
  ]$. Because
  the CDF is piecewise-linear, the sample value $x$ is the same offset
  between $x_i$ and $x_(i + 1)$ (Figure A.5(b)).
][
  给定一对跨越 $u$ 的  CDF 值，我们可以计算 $x$。首先，确定 $u$ 在 $"cdf"[o
  ]$ 与  $"cdf"[o+1 ]$ 之间的相对位置。记这个值为 $d u$，当 $u ="cdf"[o
  ]$  时 $d u = 0$，当 $u = "cdf"[o+1 ]$ 时 $d u = 1$。由于 CDF
  是分段线性的，因此采样值 $x$ 在 $x_i$ 与 $x_(i + 1)$  之间具有相同的相对位置（见图 A.5(b)）。
]

```cpp
Float du = u - cdf[o];
if (cdf[o + 1] - cdf[o] > 0)
    du /= cdf[o + 1] - cdf[o];
```

#parec[
  The PDF for this sample $p (x)$ is easily computed since we
  have the function’s integral in funcInt.
][

  由于我们已经得到了函数的积分 funcInt，该样本的 PDF $p (x)$
  很容易计算：
]

```cpp
if (pdf)
    *pdf = (funcInt > 0) ? func[o] / funcInt : 0;
```

#parec[
  Finally, the appropriate value of $x$ is computed and
  returned. Here is where the sampled value in $[0, 1)$ is remapped to the
  user-specified range [m, n
  ].
][
  最后，计算并返回合适的 $x$
  值。在这里，区间 $[0,1)$ 上的采样值被重新映射到用户指定的区间
  $[m, n
  ]$：
]

```cpp
return Lerp((o + du) / size(), min, max);
```

#parec[
  As with the other sampling routines so far, the
  PiecewiseConstant1D class provides an inversion method that takes a
  point $x$ in the range $[m, n]$ and returns the $[0, 1)$ sample value
  that maps to it. As before, this is a matter of evaluating the CDF
  $P (x)$ at the given position.
][

  与之前的采样方法类似，`PiecewiseConstant1D`
  类提供了一个反演方法，它接受一个位于区间 $[m, n
  ]$ 内的点 $x$
  并返回映射到它的 $[0,1)$ 样本值。同样地，这只需要在给定位置计算 CDF
  $P (x)$。
]

```cpp
Float Invert(Float x) const {
    // Compute offset to CDF values that bracket x
    if (x < min || x > max)
        return {};
    Float c = (x - min) / (max - min) * func.size();
    int offset = Clamp(int(c), 0, func.size() - 1);

    // Linearly interpolate between adjacent CDF values to find sample value
    Float delta = c - offset;
    return Lerp(delta, cdf[offset], cdf[offset + 1]);
}
```



#parec[
  The constructor’s behavior and the piecewise-constant sampling
  logic are designed to work with $n$-step functions over a range; they
  generalize to more complex cases by renormalizing and remapping returned
  samples to the desired domain.
][

  构造函数的行为和分段常数采样逻辑是针对区间上的 $n$
  阶函数设计的；通过归一化和对返回样本的重新映射，它们可以推广到更复杂的情况。
]

#parec[
  The following snippets summarize some of the public members
  and methods.
][
  下面的代码片段总结了部分公共成员和方法：
]

```cpp
Float funcInt = 0;
```

```cpp
pstd::vector<Float> func, cdf;
Float min, max;
```

```cpp
Float Integral() const { return funcInt; }
size_t size() const { return func.size(); }
```

```cpp
Float Sample(Float u, Float *pdf = nullptr, int *offset = nullptr) const { /* see above */ }
```

```cpp
Float Invert(Float x) const { /* see above */ }
```

#parec[
  Mappings and related helpers (e.g., FindInterval) are used to
  implement the class efficiently.
][

  该类的高效实现依赖于映射和相关辅助函数（如 `FindInterval`）。
]
