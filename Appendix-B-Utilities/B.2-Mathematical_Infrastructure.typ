#import "../template.typ": parec, translator

== mathematical infrastructure

=== 基础代数函数
<b.2.1-基础代数函数>
#parec[
  Clamp() clamps the given value to lie between the values low
  and high. For convenience, it allows the types of the values giving the
  extent to be different than the type being clamped (but its
  implementation requires that implicit conversion among the types
  involved is legal). By being implemented this way rather than requiring
  all to have the same type, the implementation allows calls like
  `Clamp(floatValue, 0, 1)` that would otherwise be disallowed by C++’s
  template type resolution rules.
][
  `Clamp()` 将给定的值限制在 `low` 和
  `high`
  之间。为了方便，它允许上下限的类型与被约束的值的类型不同（但前提是这些类型之间的隐式转换是合法的）。通过这种实现方式，而不是要求所有参数具有相同类型，`Clamp()`
  就允许像 `Clamp(floatValue, 0, 1)` 这样的调用，这在 C++
  的模板类型解析规则下原本是不允许的。
]

```cpp
template <typename T, typename U, typename V>
constexpr T Clamp(T val, U low, V high) {
    if (val < low)       return T(low);
    else if (val > high) return T(high);
    else                 return val;
}
```

#parec[
  `Mod()` computes the remainder of a/b. `pbrt` has its own
  version of this (rather than using %) in order to provide the behavior
  that the modulus of a negative number is always positive or zero.
  Starting with C++11, the behavior of % has been specified to return a
  negative value or zero in this case, so that the identity

  ```
  (a/b)*b + a%b == a
  ```

  holds.
][
  `Mod()` 计算 `a/b` 的余数。`pbrt`
  实现了自己的版本（而不是使用 `%`），以保证负数的取模结果始终是非负的。从
  C++11 开始，标准规定 `%` 在这种情况下会返回负值或零，从而保证恒等式

  ```
  (a/b)*b + a%b == a
  ```

  成立。
]

```cpp
template <typename T>
T Mod(T a, T b) {
    T result = a - (a / b) * b;
    return (T)((result < 0) ? result + b : result);
}
```

#parec[
  A specialization for `Floats` calls the corresponding standard
  library function.
][
  对于 `Float` 类型，有一个特化版本调用标准库中的
  `fmod()` 函数。
]

```cpp
template <>
Float Mod(Float a, Float b) { return std::fmod(a, b); }
```

#parec[
  It can be useful to be able to invert the bilinear
  interpolation function, Equation (2.25). Because there are two unknowns
  in the result, values with at least two dimensions must be bilinearly
  interpolated in order to invert it. In that case, two equations with two
  unknowns can be formed, which in turn leads to a quadratic equation.

][
  在某些情况下，能够对双线性插值函数（公式
  (2.25)）求逆是很有用的。由于结果中有两个未知数，因此必须对至少二维的数值进行双线性插值才能进行反演。在这种情况下，可以得到两个含两个未知数的方程，进而得到一个二次方程。

]

```cpp
Point2f InvertBilinear(Point2f p, pstd::span<const Point2f> v);
```

#parec[
  A number of constants, most of them related to π, are used
  enough that it is worth having them easily available.
][

  有一些常数（大多数与 π
  有关）在系统中使用频繁，因此将它们定义为可直接访问的常量是值得的。
]

```cpp
constexpr Float Pi = 3.14159265358979323846;
constexpr Float InvPi = 0.31830988618379067154;
constexpr Float Inv2Pi = 0.15915494309189533577;
constexpr Float Inv4Pi = 0.07957747154594766788;
constexpr Float PiOver2 = 1.57079632679489661923;
constexpr Float PiOver4 = 0.78539816339744830961;
constexpr Float Sqrt2 = 1.41421356237309504880;
```

#parec[
  Two simple functions convert from angles expressed in degrees
  to radians, and vice versa:
][

  两个简单的函数用来在角度制和弧度制之间转换：
]

```cpp
Float Radians(Float deg) { return (Pi / 180) * deg; }
Float Degrees(Float rad) { return (180 / Pi) * rad; }
```

#parec[
  It is often useful to blend between two values using a smooth
  curve that does not have the first derivative discontinuities that a
  linear interpolant would. `SmoothStep()` takes a range $[a, b
  ]$ and a
  value $x$, returning 0 if $x$ less-than-or-equal-to a, 1 if $x \>=
  b$, and smoothly blends between 0 and 1 for intermediate values of
  $x$ using a cubic polynomial. Among other uses in the system, the
  `SpotLight` uses `SmoothStep()` to model the falloff to its edge.
][

  在许多情况下，我们希望在两个值之间进行平滑过渡，而不是使用在线性插值中会出现一阶导数不连续的曲线。`SmoothStep()`
  接受一个区间 $[a, b]$ 和一个值 $x$，当 $x a$ 时返回 0，当 $x b$
  时返回 1，而在 $x$ 的中间值上，则通过一个三次多项式在 0 和 1
  之间平滑过渡。在系统的多个地方，`SpotLight` 就使用了 `SmoothStep()`
  来模拟光斑边缘的衰减。
]

```cpp
Float SmoothStep(Float x, Float a, Float b) {
    if (a == b) return (x < a) ? 0 : 1;
    Float t = Clamp((x - a) / (b - a), 0, 1);
    return t * t * (3 - 2 * t);
}
```

#parec[
  Finally, `SafeSqrt()` returns the square root of the given
  value, clamping it to zero in case of rounding errors being the cause of
  a slightly negative value. A second variant for `double`s is effectively
  the same and is therefore not included here.
][
  最后，`SafeSqrt()`
  返回给定值的平方根；如果由于舍入误差导致输入是一个略小于零的值，它会将其钳制为零。对于
  `double` 类型也有一个类似版本，本质相同，因此在此不再给出。
]

```cpp
float SafeSqrt(float x) { return std::sqrt(std::max(0.f, x)); }
```

=== B.2.2 整数幂与多项式
<b.2.2-整数幂与多项式>
#parec[
  \<Sqr()\> squares the provided value. Though it is not much
  work to write this operation out directly, we have often found this
  function to be helpful in making the implementations of formulae more
  succinct.
][
  `Sqr()`
  用来对给定的值求平方。虽然直接写出这个运算并不复杂，但我们发现这个函数在实现公式时能让代码更加简洁。

]

```cpp
template <typename T>
constexpr T Sqr(T v) { return v * v; }
```

#parec[
  `Pow()` efficiently raises a value to a power if the power is
  a compile-time constant. Note that the total number of multiply
  operations works out to be logarithmic in the power `n`.
][
  `Pow()`
  用来高效地将一个值提升到幂次，当幂次 `n`
  是编译期常量时尤其有效。需要注意的是，总的乘法运算次数与 `n`
  呈对数关系。
]

```cpp
template <int n>
constexpr float Pow(float v) {
    if constexpr (n < 0) return 1 / Pow<-n>(v);
    float n2 = Pow<n / 2>(v);
    return n2 * n2 * Pow<n & 1>(v);
}
```

#parec[
  Specializations for $n == 1$ and $n == 0$
  terminate the template function recursion.
][
  对于 $n = 1$ 和 $n =
  0$，提供了特化版本以终止模板函数的递归展开。
]

```cpp
template <>
constexpr float Pow<1>(float v) { return v; }
template <>
constexpr float Pow<0>(float v) { return 1; }
```

#parec[
  \<EvaluatePolynomial()\> evaluates a provided polynomial using
  Horner’s method, which is based on the equivalence
][

  `EvaluatePolynomial()` 使用 #strong[Horner 法则]
  来计算给定的多项式，其原理基于如下等式：
]

```
c0 + c1 x + c2 x^2 + ...  =  c0 + x ( c1 + x ( c2 + ... ) )
```

```cpp
template <typename Float, typename C>
constexpr Float EvaluatePolynomial(Float t, C c) { return c; }

template <typename Float, typename C, typename... Args>
constexpr Float EvaluatePolynomial(Float t, C c, Args... cRemaining) {
    return FMA(t, EvaluatePolynomial(t, cRemaining...), c);
}
```

=== B.2.3 三角函数
<b.2.3-三角函数>
#parec[
  The function $sin(x)$ divided by x is used in multiple
  places in `pbrt`, including in the implementation of the
  `LanczosSincFilter`. It is undefined at $x == 0$ and suffers from
  poor numerical accuracy if directly evaluated at nearby values. A robust
  computation of its value is possible by considering the power series
  expansion
][
  函数 $(x)/x$ 在 `pbrt` 的多个地方会用到，例如在
  `LanczosSincFilter` 的实现中。该函数在 $x=0$
  处未定义，并且在接近零时若直接计算会有较差的数值精度。通过考虑它的幂级数展开，可以更稳健地计算其值：

]

$ frac(sin x, x) = 1 - frac(x^2, 3 !) + frac(x^4, 5 !) - dots.h $

#parec[
  If $x$ is small and $1 - x^2/3!$ rounds to 1, then
  $sin(x)/x$ also rounds to 1. The following function uses a slightly
  more conservative variant of that test, which is close enough for our
  purposes.
][
  如果 $x$ 很小，以至于 $1 - x^2/3!$
  在浮点运算中四舍五入后等于 1，那么 $(x)/x$ 的值也会四舍五入为
  1。下面的函数使用了一个更保守的判定方式，但对于我们的需求已经足够精确。

]

```cpp
Float SinXOverX(Float x) {
    if (1 - x * x == 1)
        return 1;
    return std::sin(x) / x;
}
```

#parec[
  Similar to SafeSqrt, `pbrt` also provides "safe" versions of
  the inverse sine and cosine functions so that if the provided value is
  slightly outside of the legal range $[-1, 1
  ]$, a reasonable result is
  returned rather than a not-a-number value. In debug builds, an
  additional check is performed to make sure that the provided value is
  not too far outside the valid range.
][
  与 `SafeSqrt` 类似，`pbrt`
  也提供了“安全”的反正弦和反余弦函数。如果传入的值稍微超出了合法区间 $[-1,
    1
  ]$，这些函数会返回一个合理的结果，而不是
  NaN。在调试版本中，还会额外检查输入值是否超出过远，以保证数值的合理性。

]

```cpp
float SafeASin(float x) { return std::asin(Clamp(x, -1, 1)); }
float SafeACos(float x) { return std::acos(Clamp(x, -1, 1)); }
```

=== B.2.4 对数与指数运算
<b.2.4-对数与指数运算>
#parec[
  Because the math library does not provide a base-2 logarithm
  function, we provide one here, using the identity
][

  由于标准数学库没有提供以 2
  为底的对数函数，这里我们实现了一个，基于如下恒等式：
]

$ log_2 (x) = frac(log x, log 2) . $

```cpp
Float Log2(Float x) {
    const Float invLog2 = 1.442695040888963387004650940071;
    return std::log(x) * invLog2;
}
```

#parec[
  If only the integer component of the base-2 logarithm of a
  `float` is needed, then the result is available (nearly) in the exponent
  of the floating-point representation. In the implementation below, we
  augment that approach by testing the significand of the provided value
  to the midpoint of significand values between the current exponent and
  the next one up, using the result to determine whether rounding the
  exponent up or rounding it down gives a more accurate result. A
  corresponding function for `double`s is not included here.
][

  如果只需要 `float` 的以 2
  为底的对数的整数部分，那么结果几乎可以直接从浮点数表示的指数位中获得。在下面的实现中，我们在此基础上增加了一个判定：检查给定值的尾数部分是否超过了当前指数和下一个指数之间的中点，由此决定是向上取整还是向下取整，以获得更准确的结果。这里没有给出对应
  `double` 类型的版本。
]

```cpp
int Log2Int(float v) {
    if (v < 1) return -Log2Int(1 / v);
    // midsignif = Significand(std::pow(2., 1.5))
    const uint32_t midsignif = 0b00000000001101010000010011110011;
    return Exponent(v) + ((Significand(v) >= midsignif) ? 1 : 0);
}
```

#parec[
  It is also often useful to be able to compute the base-2
  logarithm of an integer. Rather than computing an expensive
  floating-point logarithm and converting to an integer, it is much more
  efficient to count the number of leading zeros up to the first one in
  the 32-bit binary representation of the value and then subtract this
  value from 31, which gives the index of the first bit set, which is in
  turn the integer base-2 logarithm. (This efficiency comes in part from
  the fact that most processors have an instruction to count these zeros.)

][
  有时也需要计算整数的以 2
  为底的对数。与其先计算昂贵的浮点对数再转换为整数，不如直接数 32
  位二进制表示中开头连续的 0 的数量，然后用 31
  减去该数量，这样得到的就是首个置位的比特位置，也就是整数的 $\_2$
  值。（这种方法之所以高效，部分原因是大多数处理器都提供了专门的指令来计算前导零的数量。）

]

```cpp
int Log2Int(uint32_t v) {
#ifdef PBRT_IS_GPU_CODE
    return 31 - __clz(v);
#elif defined(PBRT_HAS_INTRIN_H)
    unsigned long lz = 0;
    if (_BitScanReverse(&lz, v))
        return lz;
    return 0;
#else
    return 31 - __builtin_clz(v);
#endif
}
```

#parec[
  It is also useful to compute the base-4 logarithm of an
  integer value. This is easily done using the identity
][

  有时也需要计算整数的以 4 为底的对数。这可以通过以下恒等式轻松完成：
]

$ log_4 x = frac(log_2 x, 2) . $

```cpp
template <typename T>
int Log4Int(T v) { return Log2Int(v) / 2; }
```

#parec[
  An efficient approximation to the exponential function e^x
  comes in handy, especially for volumetric light transport algorithms
  where such values need to be computed frequently. Like `Log2Int()`, this
  value can be computed efficiently by taking advantage of the
  floating-point representation.
][
  一个高效的 $e^x$
  近似计算函数在很多情况下都很有用，尤其是在体渲染的光传输算法中，这类运算会被频繁调用。与
  `Log2Int()` 类似，这个近似函数也利用了浮点数表示的特性来实现高效计算。

]

```cpp
float FastExp(float x) {
    // Compute x' such that e^x = 2^{x'}
    float xp = x * 1.442695041f;
    // Find integer and fractional components of x'
    float fxp = floor(xp), f = xp - fxp;
    int i = (int)fxp;
    // Evaluate polynomial approximation of 2^f
    float twoToF = EvaluatePolynomial(f, 1.f, 0.695556856f,
                                      0.226173572f, 0.0781455737f);
    // Scale 2^f by 2^i and return final result
    int exponent = Exponent(twoToF) + i;
    if (exponent < -126) return 0;
    if (exponent > 127) return Infinity;
    uint32_t bits = FloatToBits(twoToF);
    bits &= 0b10000000011111111111111111111111u;
    bits |= (exponent + 127) << 23;
    return BitsToFloat(bits);
}
```

#parec[
  The first step is to convert the problem into one to compute a
  base-2 exponential; a factor of 1/log 2 does so. This step makes it
  possible to take advantage of computers’ native floating-point
  representation.
][
  第一步是将问题转换为以 2 为底的指数计算；乘以一个
  $"1/"$
  的因子即可完成。这使得我们能够利用计算机原生的浮点数表示来优化计算。
]

```cpp
float xp = x * 1.442695041f;
```

#parec[
  Next, the function splits the exponent into an integer $i$
  equals floor(x’), and a fractional part $f$ equals x’ - i, giving
][

  接着，函数将指数拆分为整数部分 $i = x’$ 和小数部分 $f = x’ -
  i$，从而得到：
]

$ 2^(x prime) = 2^(i + f) = 2^i thin 2^f . $

```cpp
float fxp = floor(xp), f = xp - fxp;
int i = (int)fxp;
```

#parec[
  Because $f$ is between 0 and 1, $2^f$ can be accurately
  approximated with a polynomial. We have fit a cubic polynomial to this
  function using a constant term of 1 so that $2^0$ is exact. The
  following coefficients give a maximum absolute error of less than
  $0.0002$ over the range of $f$.
][
  由于 $f$ 在 $[0,1
  ]$
  范围内，$2^f$ 可以通过多项式近似来高效计算。我们使用一个以常数项为 1
  的三次多项式拟合该函数，以保证 $2^0=1$ 的准确性。下面的系数在 $f$
  的整个区间内保证最大绝对误差小于 $0.0002$。
]

```cpp
float twoToF = EvaluatePolynomial(f, 1.f, 0.695556856f,
                                  0.226173572f, 0.0781455737f);
```

#parec[
  The last task is to apply the $2^i$ scale. This can be done
  by directly operating on the exponent in the `twoToF` value. It is
  necessary to make sure that the resulting exponent fits in the valid
  exponent range of 32-bit `float`s; if it does not, then the computation
  has either underflowed to 0 or overflowed to infinity. If the exponent
  is valid, then the existing exponent bits are cleared so that final
  exponent can be stored. (For the source of the value of 127 that is
  added to the exponent, see Equation (6.17).)
][
  最后一步是施加 $2^i$
  的缩放。这一步可以通过直接修改 `twoToF`
  的指数位来完成。需要确保结果指数在 32 位 `float`
  的有效范围内；否则计算要么下溢为
  0，要么上溢为无穷大。如果指数有效，就将已有的指数位清零，然后存入新的指数值。（至于为什么要加上
  127，可参考公式 (6.17)，它来源于 IEEE 754 单精度浮点数的指数偏移量。）

]

```cpp
int exponent = Exponent(twoToF) + i;
if (exponent < -126) return 0;
if (exponent > 127) return Infinity;
uint32_t bits = FloatToBits(twoToF);
bits &= 0b10000000011111111111111111111111u;
bits |= (exponent + 127) << 23;
return BitsToFloat(bits);
```

=== B.2.5 超越函数与特殊函数
<b.2.5-超越函数与特殊函数>
#parec[
  `Gaussian()` evaluates the Gaussian function
][
  `Gaussian()`
  用于计算高斯函数：
]

```cpp
Float Gaussian(Float x, Float mu = 0, Float sigma = 1) {
    return 1 / std::sqrt(2 * Pi * sigma * sigma) *
           FastExp(-Sqr(x - mu) / (2 * sigma * sigma));
}
```

#parec[
  The integral of the Gaussian over a range $[x_0, x_1
  ]$ can be
  expressed in terms of the error function, which is available from the
  standard library.
][
  高斯函数在区间$[x_0, x_1]$
  上的积分可以通过误差函数（标准库已提供）来表示。
]

```cpp
Float GaussianIntegral(Float x0, Float x1, Float mu = 0, Float sigma = 1) {
    Float sigmaRoot2 = sigma * Float(1.414213562373095);
    return 0.5f * (std::erf((mu - x0) / sigmaRoot2) -
                   std::erf((mu - x1) / sigmaRoot2));
}
```

#parec[
  The logistic distribution takes a scale factor $s$, which
  controls its width:
][
  Logistic（逻辑分布）函数接受一个尺度因子
  $s$，用于控制分布的宽度：
]

```cpp
Float Logistic(Float x, Float s) {
    x = std::abs(x);
    return std::exp(-x / s) / (s * Sqr(1 + std::exp(-x / s)));
}
```

#parec[
  The logistic function is normalized so it is its own
  probability density function (PDF). Its cumulative distribution function
  (CDF) can be easily found via integration.
][

  逻辑分布函数已经归一化，因此它本身就是一个概率密度函数（PDF）。它的累积分布函数（CDF）可以通过积分轻松得到：

]

```cpp
Float LogisticCDF(Float x, Float s) { return 1 / (1 + std::exp(-x / s)); }
```

#parec[
  The trimmed logistic function is the logistic limited to an
  interval $[a, b
  ]$ and then renormalized using the technique introduced
  in Section A.4.5.
][
  截断逻辑分布是将逻辑分布限制在区间$[a, b
  ]$
  内，并按照 A.4.5 节介绍的技术进行重新归一化后的结果：
]

```cpp
Float TrimmedLogistic(Float x, Float s, Float a, Float b) {
    return Logistic(x, s) / (LogisticCDF(b, s) - LogisticCDF(a, s));
}
```

#parec[
  `ErfInv()` is the inverse to the error function `std::erf()`,
  implemented via a polynomial approximation. `I0()` evaluates the
  modified Bessel function of the first kind and `LogI0()` returns its
  logarithm.
][
  `ErfInv()` 是误差函数 `std::erf()`
  的反函数，其实现基于多项式近似。`I0()`
  用来计算第一类修正贝塞尔函数，`LogI0()` 则返回它的对数值。
]

```cpp
Float ErfInv(Float a);
Float I0(Float x);
Float LogI0(Float x);
```

=== B.2.6 区间查找
<b.2.6-区间查找>
#parec[
  `FindInterval()` is a helper function that emulates the
  behavior of `std::upper_bound()` but uses a function object to get
  values at various indices instead of requiring access to an actual
  array. This way, it becomes possible to bisect arrays that are
  procedurally generated, such as those interpolated from point samples.

][
  `FindInterval()` 是一个辅助函数，它的行为类似于
  `std::upper_bound()`，但不同之处在于它通过函数对象来获取索引处的值，而不是依赖对实际数组的访问。这样一来，就可以对那些过程生成的“数组”进行二分查找，例如由点采样插值得到的数据。

]

#parec[
  It generally returns the index $i$ such that $p(i)$ is
  true and $p(i+1)$ is false. However, since this function is primarily
  used to locate an interval (i, i+1) for linear interpolation, it applies
  the following boundary conditions to prevent out-of-bounds accesses and
  to deal with predicates that evaluate to true or false over the entire
  domain:
][
  该函数通常返回满足条件 $p(i)$ 为真且 $p(i+1)$
  为假的索引 $i$。不过，由于它的主要用途是定位一个线性插值区间 $(i,
    i+1)$，因此实现中加入了以下边界条件，以避免越界访问并处理谓词在整个域内恒为真或恒为假的情况：

]

- #parec[
    The returned index $i$ is no larger than sz-2, so that it
    is always legal to access both of the elements i and
    i+1.
  ][
    返回的索引 $i$ 永远不会超过 `sz-2`，这样访问元素 `i` 和
    `i+1` 总是合法的。
  ]
- #parec[
    If there is no index such that the predicate is true, 0 is
    returned.
  ][
    如果没有任何索引使谓词成立，则返回 0。
  ]
- #parec[
    If there is no index such that the predicate is false, sz-2
    is returned.
  ][
    如果没有任何索引使谓词为假，则返回 `sz-2`。
  ]

```cpp
template <typename Predicate>
size_t FindInterval(size_t sz, const Predicate &pred) {
    using ssize_t = std::make_signed_t<size_t>;
    ssize_t size = (ssize_t)sz - 2, first = 1;
    while (size > 0) {
        // Evaluate predicate at midpoint and update first and size
        size_t half = (size_t)size >> 1, middle = first + half;
        bool predResult = pred(middle);
        first = predResult ? middle + 1 : first;
        size = predResult ? size - (half + 1) : half;
    }
    return (size_t)Clamp((ssize_t)first - 1, 0, sz - 2);
}
```

#parec[


  ```cpp
  size_t half = (size_t)size >> 1, middle = first + half;
  bool predResult = pred(middle);
  first = predResult ? middle + 1 : first;
  size = predResult ? size - (half + 1) : half;
  ```

  This code fragment shows the key logic inside the loop: find the
  midpoint, test the predicate, and update the search range accordingly.

][

  这段代码片段展示了循环中的核心逻辑：找到中点、评估谓词，并据此更新搜索区间。

]

=== B.2.7 位运算
<b.2.7-位运算>
#parec[
  There are clever tricks that can be used to efficiently
  determine if a given integer is an exact power of 2, or round an integer
  up to the next higher (or equal) power of 2. (It is worthwhile to take a
  minute and work through for yourself how these two functions work.)
][

  有一些巧妙的技巧可以高效地判断一个整数是否正好是 2
  的幂，或者将一个整数向上取整到不小于它的下一个 2
  的幂。（值得花一点时间亲自推演一下这两个函数的工作原理。）
]

```cpp
template <typename T>
bool IsPowerOf2(T v) { return v && !(v & (v - 1)); }
```

```cpp
int32_t RoundUpPow2(int32_t v) {
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    return v + 1;
}
```

#parec[
  A variant of `RoundUpPow2()` for `int64_t` is also provided
  but is not included in the text here.
][
  针对 `int64_t` 的
  `RoundUpPow2()` 变体也有实现，但这里未列出。
]

#parec[
  The bits of an integer quantity can be efficiently reversed
  with a series of bitwise operations. The first line of the
  `ReverseBits32()` function, which reverses the bits of a 32-bit integer,
  swaps the lower 16 bits with the upper 16 bits of the value. The next
  line simultaneously swaps the first 8 bits of the result with the second
  8 bits and the third 8 bits with the fourth. This process continues
  until the last line, which swaps adjacent bits.
][

  一个整数的比特位可以通过一系列按位操作高效地反转。`ReverseBits32()`
  用于反转 32 位整数的比特位。它的第一行代码交换了高 16 位与低 16
  位；第二行同时交换了第一个 8 位与第二个 8 位、第三个 8 位与第四个 8
  位；这个过程持续进行，直到最后一行交换相邻的比特。
]

#parec[
  To understand this code, it is helpful to write out the binary
  values of the various hexadecimal constants. For example, 0xff00ff00 is
  11111111 00000000 11111111 00000000 in binary; it is then easy to see
  that a bitwise or with this value masks off the first and third 8-bit
  quantities.
][

  理解这段代码时，将使用到的十六进制常量写成二进制会很有帮助。例如，`0xff00ff00`
  的二进制形式是
  `11111111 00000000 11111111 00000000`，这样就能清楚地看到，与它按位与（AND）运算时会屏蔽掉第
  1 和第 3 个 8 位分量。
]

```cpp
inline uint32_t ReverseBits32(uint32_t n) {
    n = (n << 16) | (n >> 16);
    n = ((n & 0x00ff00ff) << 8) | ((n & 0xff00ff00) >> 8);
    n = ((n & 0x0f0f0f0f) << 4) | ((n & 0xf0f0f0f0) >> 4);
    n = ((n & 0x33333333) << 2) | ((n & 0xcccccccc) >> 2);
    n = ((n & 0x55555555) << 1) | ((n & 0xaaaaaaaa) >> 1);
    return n;
}
```

#parec[
  The bits of a 64-bit value can then be reversed by reversing
  the two 32-bit components individually and then interchanging them.
][

  一个 64 位整数的比特位反转可以通过先分别反转两个 32
  位分量，然后再交换它们来实现。
]

```cpp
inline uint64_t ReverseBits64(uint64_t n) {
    uint64_t n0 = ReverseBits32((uint32_t)n);
    uint64_t n1 = ReverseBits32((uint32_t)(n >> 32));
    return (n0 << 32) | n1;
}
```

=== Morton 编码（Morton’s indexing）
<morton-编码mortons-indexing>
#parec[
  To be able to compute 3D Morton codes, which were introduced
  in Section 7.3.3, we will first define a helper function: `LeftShift3()`
  takes a 32-bit value and returns the result of shifting the $i$th bit
  to be at the $3i$th bit, leaving zeros in other bits. Figure B.1
  illustrates this operation.
][
  为了能够计算 3D Morton 编码（在第 7.3.3
  节中介绍过），我们首先定义一个辅助函数：`LeftShift3()` 接受一个 32
  位的数，并将其第 $i$ 个比特移到第 $3i$ 个比特位置上，其余比特填充为
  0。图 B.1 展示了该操作。
]

#figure(image("../pbr-book-website/4ed/Utilities/phabbf01.svg"), caption: [
  Figure B.1: Bit Shifts to Compute 3D Morton Codes.
])

#parec[
  The most obvious approach to implement this operation,
  shifting each bit value individually, is not the most efficient. (It
  would require a total of 9 shifts, along with bitwise or operations to
  compute the final value.) Instead, we can decompose each bit’s shift
  into multiple shifts of power-of-two size that together shift the bit’s
  value to its final position. Then, all the bits that need to be shifted
  a given power-of-two number of places can be shifted together. The
  `LeftShift3()` function implements this computation, and Figure B.2
  shows how it works.
][

  实现这一操作最直观的方法是单独移动每一位比特，但这种方式并不高效（需要 9
  次移位以及多次按位或运算才能得到最终结果）。更好的方式是：将每个比特的位移分解为多个
  2
  的幂次大小的移位组合，从而一步步把比特移到目标位置。这样，所有需要移动相同距离的比特都可以一次性整体移动。`LeftShift3()`
  的实现正是基于这种方法，图 B.2 展示了其工作原理。
]

#figure(image("../pbr-book-website/4ed/Utilities/phabbf02.svg"), caption: [
  Figure B.2: Power-of-Two Decomposition of Morton Bit Shifts.
])

```cpp
inline uint32_t LeftShift3(uint32_t x) {
    if (x == (1 << 10))
        --x;
    x = (x | (x << 16)) & 0b00000011000000000000000011111111;
    x = (x | (x << 8)) & 0b00000011000000001111000000001111;
    x = (x | (x << 4)) & 0b00000011000011000011000011000011;
    x = (x | (x << 2)) & 0b00001001001001001001001001001001;
    return x;
}
```

#parec[
  `EncodeMorton3()` takes a 3D coordinate value where each
  component is a floating-point value between 0 and $2^{10}$. It
  converts these values to integers and then computes the Morton code by
  expanding the three 10-bit quantized values so that their $i$th bits
  are at position $3i$, then shifting the $y$ bits over one more, the
  $z$ bits over two more, and computing the bitwise or of the result
  (Figure B.3).
][
  `EncodeMorton3()` 接收一个 3D 坐标值，每个分量是介于
  0 和 $2^{10}$ 之间的浮点数。它首先将这些值转换为整数，然后计算 Morton
  编码：将三个 10 位量化值的比特展开，使得它们的第 $i$
  位比特分别落在位置 $3i$ 上；随后将 $y$ 的比特再左移 1 位，$z$
  的比特再左移 2 位，最后将三个结果按位或组合在一起（如图 B.3 所示）。
]

#figure(image("../pbr-book-website/4ed/Utilities/phabbf03.svg"), caption: [
  Figure B.3: Final Interleaving of Coordinate Values.
])

```cpp
uint32_t EncodeMorton3(float x, float y, float z) {
    return (LeftShift3(z) << 2) | (LeftShift3(y) << 1) | LeftShift3(x);
}
```

#parec[
  Support for 2D Morton encoding is provided by the
  `EncodeMorton2()` function, which takes a pair of 32-bit integer values
  and follows an analogous approach. It is not included here.
][
  `pbrt`
  还提供了二维 Morton 编码函数 `EncodeMorton2()`，它接收一对 32
  位整数值，并采用类似的方法进行处理。不过这里不再给出具体实现。
]

=== B.2.8 哈希与随机排列
<b.2.8-哈希与随机排列>
#parec[
  A handful of hashing functions are provided. Their
  implementations are in the file util/cmd/hash.h.
][
  `pbrt`
  提供了一些哈希函数，它们的具体实现位于 `util/cmd/hash.h` 文件中。
]

#parec[
  The first, `MixBits()`, takes an integer value and applies a
  so-called finalizer, which is commonly found at the end of hash function
  implementations. A good hash function has the property that flipping a
  single bit in the input causes each of the bits in the result to flip
  with probability $1/2$; a finalizer takes values where this may not be
  the case and shuffles them around in a way that increases this
  likelihood.
][
  第一个函数是 `MixBits()`，它接收一个整数并应用所谓的
  #emph[finalizer];（终结器），这种操作通常出现在哈希函数的最后阶段。一个好的哈希函数具有这样的性质：输入中的任意一位比特翻转，结果中的每一位比特也会以
  $1/2$ 的概率翻转；而 #emph[finalizer]
  的作用就是对那些不满足此性质的值进行进一步混合，以提升这种随机性。
]

#parec[
  `MixBits()` is particularly handy for tasks like computing
  unique seeds for a pseudo-random number generator at each pixel:
  depending on the RNG implementation, the naive approach of converting
  the pixel coordinates into an index and giving the RNG successive
  integer values as seeds may lead to correlation between values it
  generates at nearby pixels. Running such an index through `MixBits()`
  first is good protection against this.
][
  `MixBits()`
  特别适合用于一些场景，比如为每个像素计算唯一的伪随机数发生器（RNG）种子：如果简单地将像素坐标转为索引，并依次将整数作为种子传入
  RNG，不同像素生成的值可能会出现相关性。而如果先用 `MixBits()`
  对索引进行处理，就能有效避免这种情况。
]

```cpp
uint64_t MixBits(uint64_t v);
```

#parec[
  There are also complete hash functions for arbitrary data.
  `HashBuffer()` hashes a region of memory of given size using
  #emph[MurmurHash64A];, which is an efficient and high-quality hash
  function.
][
  此外，还提供了针对任意数据的完整哈希函数。`HashBuffer()`
  会使用
  #emph[MurmurHash64A];（一种高效且高质量的哈希函数）对指定大小的内存区域进行哈希。

]

```cpp
template < typename T >
uint64_t HashBuffer(const T *ptr, size_t size, uint64_t seed = 0) {
    return MurmurHash64A((const unsigned char *)ptr, size, seed);
}
```

#parec[
  For convenience, `pbrt` also provides a `Hash()` function that
  can be passed an arbitrary sequence of values, all of which are hashed
  together.
][
  为了方便，`pbrt` 还提供了 `Hash()`
  函数，它可以接收任意数量的值，并将它们一起进行哈希。
]

```cpp
template <typename... Args>
uint64_t Hash(Args... args);
```

#parec[
  It is sometimes useful to convert a hash to a floating-point
  value between 0 and 1; the `HashFloat()` function handles the details of
  doing so.
][
  有时将哈希值转换为区间 $[0,1
  ]$
  内的浮点数会很有用，`HashFloat()` 函数就负责处理这些细节。
]

```cpp
template <typename... Args>
Float HashFloat(Args... args) { return uint32_t(Hash(args...)) * 0x1p-32f; }
```

#parec[
  `PermutationElement()` returns the `i`-th element of a random
  permutation of `n` values based on the provided seed. Remarkably, it is
  able to do so without needing to explicitly represent the permutation.
  The key idea underlying its implementation is the insight that any
  invertible hash function of `n` bits represents a permutation of the
  values from 0 to $2^n - 1$; otherwise, it would not be invertible.

][
  `PermutationElement()` 返回基于给定种子生成的一个 `n`
  元随机排列中的第 `i`
  个元素。值得注意的是，它无需显式存储整个排列就能做到这一点。其核心思想在于：任意一个可逆的
  `n` 位哈希函数实际上对应着从 0 到 $2^n - 1$
  的一个排列；如果它不可逆，就无法成为一个有效的排列。
]

#parec[
  Such a hash function can be used to define a permutation over
  a non-power-of-two number of elements `n` using the permutation for the
  next power-of-two number of elements and then repermuting any values
  greater than `n` until a valid one is reached.
][

  这种哈希函数还可以用于定义一个元素个数不是 2
  的幂的排列：方法是先在下一个 2
  的幂大小的集合上定义排列，然后不断对结果中大于 `n`
  的值重新取排列，直到得到一个合法值为止。
]

```cpp
int PermutationElement(uint32_t i, uint32_t n, uint32_t seed);
```

=== B.2.9 无误差变换（Error-Free Transformations）
<b.2.9-无误差变换error-free-transformations>
#parec[
  It is possible to increase the accuracy of some floating-point
  calculations using an approach known as error-free transformations
  (EFT). The idea of them is to maintain the accumulated error that is in
  a computed floating-point value and to then make use of that error to
  correct later computations. For example, we know that the rounded
  floating-point value $a b$ is in general not equal to the true product
  $a b$. Using EFTs, we also compute an error term $e$ such that
][

  在浮点数计算中，可以通过一种称为\*\*无误差变换（EFT, Error-Free
  Transformations）\*\*的方法来提高精度。其核心思想是：保留浮点运算过程中产生的舍入误差，并在后续计算中利用这些误差进行修正。例如，我们知道舍入后的浮点结果
  $a b$ 一般不等于真实的乘积 $a b$。通过
  EFT，我们可以额外计算一个误差项 $e$，使得：
]

$"a \\circledtimes b = (a \\times b) + e"$

#parec[
  A clever use of fused multiply add (FMA) makes it possible to
  compute $e$ without resorting to higher-precision floating-point
  numbers. Consider the computation `FMA(-a, b, a * b)`: on the face of
  it, it computes zero, adding the negated product of `a` and `b` to
  itself. In the context of the FMA operation, however, it gives the
  rounding error, since the product of negative `a` and `b` is not rounded
  before $a b$, which is rounded, is added to it.
][

  一个巧妙的做法是利用\*\*融合乘加运算（FMA, Fused Multiply
  Add）\*\*来计算 $e$，而无需使用更高精度的浮点数。例如考虑
  `FMA(-a, b, a * b)`：表面上它的结果是零（因为 $-a b + a b = 0$），但在
  FMA 的上下文中，它实际上给出了舍入误差。原因是 $-a b$ 的乘积在与 $a
  b$ 相加之前并未舍入，而 $a b$ 本身已经是舍入后的结果。
]

```cpp
CompensatedFloat TwoProd(Float a, Float b) {
    Float ab = a * b;
    return {ab, FMA(a, b, -ab)};
}
```

#parec[
  `CompensatedFloat` is a small wrapper class that holds the
  results of EFT-based computations.
][
  `CompensatedFloat`
  是一个小型封装类，用于存储基于 EFT 的计算结果。
]

```cpp
struct CompensatedFloat {
  public:
    CompensatedFloat(Float v, Float err = 0) : v(v), err(err) {}
    explicit operator float() const { return v + err; }
    explicit operator double() const { return double(v) + double(err); }

    Float v, err;
};
```

#parec[
  It provides the expected constructor and conversion operators,
  which are qualified with `explicit` to force callers to express their
  intent to use them.
][

  该类提供了常见的构造函数和类型转换操作符，这些操作符都加上了 `explicit`
  限定，以强制调用者明确表示使用意图。
]

```cpp
CompensatedFloat(Float v, Float err = 0) : v(v), err(err) {}
explicit operator float() const { return v + err; }
explicit operator double() const { return double(v) + double(err); }
```

#parec[
  It is also possible to compute a compensation term `e` for
  floating-point addition of two values: $a b = (a + b) + e$.
][

  同样地，对于两个浮点数相加，也可以计算一个补偿项 $e$，使得
  $"a \\circledPlus b = (a + b) + e."$
]

```cpp
CompensatedFloat TwoSum(Float a, Float b) {
    Float s = a + b, delta = s - a;
    return {s, (a - (s - delta)) + (b - delta)};
}
```

#parec[
  It is not in general possible to compute exact compensation
  terms for sums or products of more than two values. However, maintaining
  them anyway, even if they carry some rounding error, makes it possible
  to implement various algorithms with lower error than if they were not
  used.
][

  对于超过两个数的加法或乘法，一般无法精确计算补偿项。不过，即便如此，仍然可以在计算中维护这些误差项（即使它们本身带有一定舍入误差），这样实现的算法往往比完全忽略误差时的结果更精确。

]

#parec[
  A similar trick based on FMA can be applied to the
  difference-of-products calculation of the form $a b - c d$. To
  understand the challenge involved in this computation, consider
  computing this difference as monospace F monospace M monospace A
  monospace left-parenthesis a comma b comma negative monospace c
  monospace times monospace d right-parenthesis. There are two rounding
  operations, one after computing $c d$ and then another after the FMA.
][
  基于 FMA 的类似技巧也可以用于计算形如$a b - c d$ 的差积运算。困难在于，直接计算时会涉及两次舍入：一次是在求 $c d$时，另一次是在执行 FMA 时。*[脚注省略
    ]*
]


#parec[
  The following `DifferenceOfProducts()` function uses FMA in a
  similar manner to `TwoProd()`, finding an initial value for the
  difference of products as well as the rounding error from $c d$. The
  rounding error is then added back to the value that is returned, thus
  fixing up catastrophic cancellation after the fact. It has been shown
  that this gives a result within 1.5 ulps of the correct value; see the
  "Further Reading" section for details.
][
  下面的
  `DifferenceOfProducts()` 函数采用了与 `TwoProd()` 类似的 FMA
  技巧：它首先计算差积的初始值，同时获得 $c d$
  的舍入误差。然后将这个误差加回到结果中，从而在事后修正可能发生的灾难性抵消（catastrophic
  cancellation）。研究表明，这种方法能保证结果在正确值的 1.5 ulps
  之内；更多细节可参见“进一步阅读”部分。
]

```cpp
template < typename Ta, typename Tb, typename Tc, typename Td >
inline auto DifferenceOfProducts(Ta a, Tb b, Tc c, Td d) {
    auto cd = c * d;
    auto differenceOfProducts = FMA(a, b, -cd);
    auto error = FMA(-c, d, cd);
    return differenceOfProducts + error;
}
```

#parec[
  pbrt also provides a `SumOfProducts` function that reliably
  computes $a b + c d$ in a similar manner.
][
  `pbrt` 还提供了
  `SumOfProducts` 函数，以类似的方法稳定地计算 $a b + c d$。
]

#parec[
  Compensation can also be used to compute a sum of numbers more
  accurately than adding them together directly. An algorithm to do so is
  implemented in the `CompensatedSum` class.
][

  补偿技术也可以用在求和上，使得结果比直接相加更准确。`CompensatedSum`
  类就实现了这样一种算法。
]

```cpp
template <typename Float = Float>
class CompensatedSum {
  public:
    CompensatedSum() = default;
    PBRT_CPU_GPU
    explicit CompensatedSum(Float v) : sum(v) {}

    PBRT_CPU_GPU
    CompensatedSum &operator=(Float v) {
        sum = v;
        c = 0;
        return *this;
    }
    CompensatedSum &operator+=(Float v) {
        Float delta = v - c;
        Float newSum = sum + delta;
        c = (newSum - sum) - delta;
        sum = newSum;
        return *this;
    }
    explicit operator Float() const { return sum; }
    std::string ToString() const;
  private:
    Float sum = 0, c = 0;
};
```

#parec[


  ```cpp
  CompensatedSum &operator+=(Float v) {
      Float delta = v - c;
      Float newSum = sum + delta;
      c = (newSum - sum) - delta;
      sum = newSum;
      return *this;
  }
  ```

  This is the core of the compensated summation algorithm: update the
  running sum while tracking the small error term.
][

  这段代码是补偿求和算法的核心：在更新累计和的同时，维护一个小的误差项
  `c`，用于补偿舍入误差。
]

=== B.2.10 求解零点（Finding Zeros）
<b.2.10-求解零点finding-zeros>
#parec[
  The quadratic equation solver is given by the following
  function. It finds solutions of the quadratic equation
  $a t^2 + b t + c = 0$ ; the Boolean return value indicates whether
  solutions were found.
][

  下面的函数实现了一个二次方程求解器。它用于求解如下方程的解：
  $a t^2 + b t + c = 0$ 其返回值是布尔类型，用于指示是否找到了实数解。
]

```cpp
bool Quadratic(float a, float b, float c, float *t0, float *t1) {
    // Handle case of a equals 0 for quadratic solution
    if (a == 0) {
        if (b == 0) return false;
        *t0 = *t1 = -c / b;
        return true;
    }

    // Find quadratic discriminant
    float discrim = DifferenceOfProducts(b, b, 4 * a, c);
    if (discrim < 0)
        return false;
    float rootDiscrim = std::sqrt(discrim);

    // Compute quadratic t values
    float q = -0.5f * (b + std::copysign(rootDiscrim, b));
    *t0 = q / a;
    *t1 = c / q;
    if (*t0 > *t1)
        std::swap(*t0, *t1);
    return true;
}
```

#parec[
  If `a` is zero, then the caller has actually specified a
  linear function. That case is handled first to avoid not-a-number values
  being generated via the usual execution path. (Our implementation does
  not handle the case of all coefficients being equal to zero, in which
  case there are an infinite number of solutions.)
][
  如果 `a`
  为零，则方程实际上是一个一次函数。这种情况首先被处理，以避免在常规计算路径中产生
  NaN（非数）结果。（我们的实现没有处理所有系数均为零的情况，此时解的个数是无穷多个。）

]

#parec[
  The discriminant $b^2 - 4a c$ is computed using
  `DifferenceOfProducts()`, which improves the accuracy of the computed
  value compared to computing it directly using floating-point
  multiplication and subtraction. If the discriminant is negative, then
  there are no real roots and the function returns `false`.
][
  判别式
  $b^2 - 4a c$ 是通过 `DifferenceOfProducts()`
  计算的，这比直接使用浮点乘法和减法的精度更高。如果判别式小于零，则没有实数解，函数返回
  `false`。
]

```cpp
float discrim = DifferenceOfProducts(b, b, 4 * a, c);
if (discrim < 0)
    return false;
float rootDiscrim = std::sqrt(discrim);
```

#parec[
  The usual version of the quadratic equation can give poor
  numerical accuracy when $b$ is almost equal to $$ due to
  cancellation error. It can be rewritten algebraically into a more stable
  form:
][
  常见的二次方程解公式在 $b$ 接近 $$
  时会因抵消误差而导致数值精度很差。通过代数变换，可以得到一种更稳定的形式：

]

$
  t_0 = q / a , quad t_1 = c / q , quad upright("其中") cases(delim: "{", q = - 1 / 2 thin (b - sqrt(b^2 - 4 a c)) & b < 0, q = - 1 / 2 thin (b + sqrt(b^2 - 4 a c)) & upright("否则") .)
$

```cpp
float q = -0.5f * (b + pstd::copysign(rootDiscrim, b));
*t0 = q / a;
*t1 = c / q;
if (*t0 > *t1)
    pstd::swap(*t0, *t1);
```

#parec[
  The implementation uses `pstd::copysign()` in place of an `if`
  test for the condition on `b`, setting the sign of the square root of
  the discriminant to be the same as the sign of `b`, which is equivalent.
  This micro-optimization does not meaningfully affect pbrt’s performance,
  but it is a trick that is worth being aware of.
][
  实现中使用了
  `pstd::copysign()` 来替代 `if` 判断：它将判别式平方根的符号设置为与 `b`
  相同，这在数学上是等价的。这种小优化对 pbrt
  的整体性能没有实质影响，但作为一种技巧值得了解。
]



#parec[
  Newton-Bisection finds a zero of an arbitrary function $ f(x) $ over a specified range $[x\_0, x\_1
  ]$ using an iterative
  root-finding technique that is guaranteed to converge to the solution so
  long as $[x\_0, x\_1
  ]$ brackets a root and $ f(x\_0) $ and $ f(x\_1) $ differ in sign.
][
  Newton-二分法用于在指定区间 $[x\_0,
    x\_1
  ]$ 上寻找任意函数 $ f(x) $
  的零点。只要区间两端点包围了一个根，且 $ f(x\_0) $ 与 $ f(x\_1) $
  符号不同，该方法就保证能收敛到解。
]

#parec[
  In each iteration, bisection search splits the interval into
  two parts and discards the subinterval that does not bracket the
  solution—in this way, it can be interpreted as a continuous extension of
  binary search. The method’s robustness is clearly desirable, but its
  relatively slow (linear) convergence can still be improved. We therefore
  use Newton-bisection, which is a combination of the quadratically
  converging but potentially unsafe Newton’s method with the safety of
  bisection search as a fallback.
][

  在每次迭代中，二分查找会将区间分为两部分，并舍弃不包含解的那一半——因此它可以看作是二分查找的连续形式。二分法的鲁棒性非常好，但其收敛速度相对较慢（线性收敛）。因此我们采用
  #strong[Newton-二分法];：它结合了牛顿法（二次收敛，但不总是安全）与二分法（鲁棒性好）两者的优点，当牛顿法失败时就回退到二分法。

]

#parec[
  The provided function `f` should return a
  `std::pair<Float, Float>` where the first value is the function’s value
  and the second is its derivative. Two "epsilon" values control the
  accuracy of the result: `xEps` gives a minimum distance between the x
  values that bracket the root, and `fEps` specifies how close to zero is
  sufficient for `f(x)`.
][
  传入的函数 `f` 应返回一个
  `std::pair<Float, Float>`，其中第一个值是函数值，第二个值是导数。两个“epsilon”参数用于控制结果的精度：`xEps`
  给出了包围根的两个 $x$ 值之间的最小间隔，`fEps` 指定了 $f(x)$
  接近零的容差。
]

```cpp
template <typename Func>
Float NewtonBisection(Float x0, Float x1, Func f, Float xEps = 1e-6f,
                      Float fEps = 1e-6f) {
    // Check function endpoints for roots
    Float fx0 = f(x0).first, fx1 = f(x1).first;
    if (std::abs(fx0) < fEps) return x0;
    if (std::abs(fx1) < fEps) return x1;
    bool startIsNegative = fx0 < 0;

    // Set initial midpoint using linear approximation of f
    Float xMid = x0 + (x1 - x0) * -fx0 / (fx1 - fx0);
    while (true) {
        // Fall back to bisection if xMid is out of bounds
        if (!(x0 < xMid && xMid < x1))
            xMid = (x0 + x1) / 2;

        // Evaluate function and narrow bracket range [x0, x1]
        std::pair<Float, Float> fxMid = f(xMid);
        if (startIsNegative == (fxMid.first < 0))
            x0 = xMid;
        else
            x1 = xMid;

        // Stop the iteration if converged
        if ((x1 - x0) < xEps || std::abs(fxMid.first) < fEps)
            return xMid;

        // Perform a Newton step
        xMid -= fxMid.first / fxMid.second;
    }
}
```

#parec[
  Before the iteration begins, a check is performed to see if
  one of the endpoints is a zero. (For example, this case comes up if a
  zero-valued function is specified.) If so, there is no need to do any
  further work.
][

  迭代开始前，首先检查区间端点是否已经是零点。（例如，当函数本身就是零函数时，就会出现这种情况。）如果是，就无需进一步计算。

]

```cpp
Float fx0 = f(x0).first, fx1 = f(x1).first;
if (std::abs(fx0) < fEps) return x0;
if (std::abs(fx1) < fEps) return x1;
bool startIsNegative = fx0 < 0;
```

#parec[
  The number of required Newton-bisection iterations can be
  reduced by starting the algorithm with a good initial guess. The
  function uses a heuristic that assumes that the function is linear and
  finds the zero crossing of the line between the two endpoints.
][

  Newton-二分法的迭代次数可以通过一个良好的初始猜测来减少。这里使用了一种启发式方法：假设函数在端点之间是线性的，取通过两个端点的直线的零点作为初始猜测。

]

```cpp
Float xMid = x0 + (x1 - x0) * -fx0 / (fx1 - fx0);
```

#parec[
  The inner-loop fragment checks if the current proposed
  midpoint is inside the bracketing interval $[x\_0, x\_1
  ]$.
  Otherwise, it is reset to the interval center, resulting in a standard
  bisection step (Figure B.4).
][
  循环体中的这段逻辑检查当前候选的中点是否仍然落在区间$[x\_0, x\_1
  ]$
  内。如果没有，则将其重置为区间中点，从而退化为标准的二分法步骤（图 B.4
  所示）。
]

```cpp
// Fall back to bisection if xMid is out of bounds
if (!(x0 < xMid && xMid < x1))
    xMid = (x0 + x1) / 2;
```

#parec[
  Figure B.4: The Robustness of Newton-Bisection. (a) This
  function increases monotonically and contains a single root on the shown
  interval, but a naive application of Newton’s method diverges. (b) The
  bisection feature of the robust root-finder enables recovery from the
  third Newton step, which jumps far away from the root (the bisection
  interval is highlighted). The method converges a few iterations later.

][
  图 B.4：Newton-二分法的鲁棒性。(a)
  该函数单调递增，并且在所示区间内有一个零点，但天真应用牛顿法会发散。(b)
  鲁棒求根器中的二分特性使其能从第三次牛顿迭代的“远跳”中恢复（高亮区域为二分区间）。该方法在随后几次迭代中收敛。

]

=== B.2.11 鲁棒方差估计
<b.2.11-鲁棒方差估计>
#parec[
  One problem with computing the sample variance using Equation
  (2.11) is that doing so requires storing all the samples Xi. The storage
  requirements for this may be unacceptable—for example, for a Film
  implementation that is estimating per-pixel variance with thousands of
  samples per pixel. Equation (2.9) suggests another possibility: if we
  accumulate estimates of both X̄ and ΣXi,2 then the sample variance could
  be estimated aas
][
  使用公式 (2.11)
  计算样本方差的一个问题是：必须存储所有样本
  $X\_i$。在某些场景下，这样的存储需求是难以接受的——例如，一个 `Film`
  实现若要估计每像素的方差，每个像素可能会有成千上万个样本。公式 (2.9)
  提供了另一种可能：如果我们同时累积样本均值 ${X}$ 和
  $X\_i^2$，则样本方差可以估计为
]

$ frac(1, n - 1) (sum_(i = 1)^n X_i^2 - X^(‾)^2) , $

#parec[
  which only requires storing two values. This approach is
  numerically unstable, however, due to ΣXi,2 having a much larger
  magnitude than X̄. Thherefore, the following `VarianceEstimator` class,
  which computes an online estimate of variance without storing all the
  samples, uses Welford’s algorithm, which is numerically stable. Its
  implementation in pbrt is parameterized by a floating-point type so
  that, for example, double precision can be used even when pbrt is built
  to use single-precision Floats.
][

  这种方法只需存储两个值即可。但数值上它是不稳定的，因为 $X\_i^2$
  的数量级远大于 ${X}$。因此，下面的 `VarianceEstimator` 类采用了
  #strong[Welford 算法] 来实现在线方差估计，它在数值上更稳定。`pbrt`
  的实现还将其参数化为浮点类型，这样即便 `pbrt`
  默认使用单精度浮点数，也可以通过指定为双精度来提高精度。
]

```cpp
template <typename Float = Float>
class VarianceEstimator {
  public:
    // VarianceEstimator Public Methods
    void Add(Float x) {
        ++n;
        Float delta = x - mean;
        mean += delta / n;
        Float delta2 = x - mean;
        S += delta * delta2;
    }
    Float Mean() const { return mean; }
    Float Variance() const { return (n > 1) ? S / (n - 1) : 0; }
    Float RelativeVariance() const {
        return (n < 1 || mean == 0) ? 0 : Variance() / Mean();
    }
    void Merge(const VarianceEstimator &ve) {
        if (ve.n == 0)
            return;
        S = S + ve.S + (ve.mean - mean) * (ve.mean - mean) * n * ve.n / (n + ve.n);
        mean = (n * mean + ve.n * ve.mean) / (n + ve.n);
        n += ve.n;
    }
  private:
    // VarianceEstimator Private Members
    Float mean = 0, S = 0;
    int64_t n = 0;
};
```

#parec[
  Welford’s algorithm computes two quantities: the sample mean X̄
  and the sum of squares of differences between the samples and the sample
  mean,

  $ S = sum_(i = 1)^n (X_i - X^(‾))^2 . $

  In turn, $S/(n-1)$ gives the sample variance.
][
  Welford
  算法维护两个量：样本均值 ${X}$，以及样本与均值差的平方和

  $ S = sum_(i = 1)^n (X_i - X^(‾))^2 . $

  最后 $S/(n-1)$ 就是样本方差。
]

```cpp
// Private Members
Float mean = 0, S = 0;
int64_t n = 0;
```

#parec[
  Both of these quantities can be computed incrementally. First,
  if X̄n−1 is the sample mean of the first n−1 samples, then given an
  additional ssample Xn, the updated sample mean X̄n is
][

  这两个量都可以增量计算。首先，如果 ${X}\_{n-1}$ 是前 $n-1$
  个样本的均值，那么给定一个新样本 $X\_n$ 后，更新的样本均值 ${X}\_n$
  为
]

$ X^(‾)_n = frac(X^(‾)_(n - 1) (n - 1) + X_n, n) = X^(‾)_(n - 1) + frac(X_n - X^(‾)_(n - 1), n) . $

```text
X̄n = X̄(n-1) + (Xn - X̄(n-1)) / n
```

#parec[
  Next, if Sn is the sum of squares of differences from the
  current mean, then consider the difference $M\_n = S\_n − S\_{n−1}$,
  which is the quantity that when added to Sn−1 gives Sn:
][

  接下来，如果 $S\_n$ 表示关于当前均值的平方差之和，那么我们考虑差值
  $M\_n = S\_n - S\_{n-1}$， 它正是将 $S\_{n-1}$ 更新为 $S\_n$
  时需要加上的量：
]

```text
Sn = sum_{i=1}^n (Xi - X̄n)^2
Mn = Sn - Sn-1 = sum_{i=1}^n (Xi - X̄n)^2 - sum_{i=1}^{n-1} (Xi - X̄(n-1))^2
```

```text
Mn = sum_{i=1}^{n-1} (Xi - X̄n)^2 + (Xn - X̄n)^2 - sum_{i=1}^{n-1} (Xi - X̄(n-1))^2
```

#parec[
  After some algebraic manipulation, this can be found to be
  equal to (B.18) which is comprised of quantities that are all readily
  available. The implementation of the VarianceEstimator Add() method is
  then just a matter of applying Equations (B.18) and (B.18).
][

  经过代数推导，可以得到该表达式等于公式 (B.18)，它仅由已知量构成。因此
  `VarianceEstimator::Add()` 方法的实现其实就是直接应用公式 (B.18)。
]

```cpp
// VarianceEstimator Public Methods
void Add(Float x) {
    ++n;
    Float delta = x - mean;
    mean += delta / n;
    Float delta2 = x - mean;
    S += delta * delta2;
}
```

#parec[
  Given these two quantities, VarianceEstimator can provide a
  number of useful statistical quantities.
][

  有了这两个量，`VarianceEstimator` 就可以提供一些有用的统计指标。
]

```cpp
// VarianceEstimator Public Methods
Float Mean() const { return mean; }
Float Variance() const { return (n > 1) ? S / (n - 1) : 0; }
Float RelativeVariance() const {
    return (n < 1 || mean == 0) ? 0 : Variance() / Mean();
}
```

#parec[
  It is also possible to merge two VarianceEstimators so that
  the result stores the same mean and variance estimates (modulo minor
  floating-point rounding error) as if a single VarianceEstimator had
  processed all the values seen by the two of them. This capability is
  particularly useful in parallel implementations, where separate threads
  may separately compute sample statistics that are merged later.
][

  我们还可以将两个 `VarianceEstimator` 合并，使得合并结果与单个
  `VarianceEstimator`
  处理所有样本得到的均值和方差（忽略轻微的浮点舍入误差）一致。这在并行实现中特别有用：多个线程可以独立统计样本信息，最后再合并。

]

#parec[
  The Merge() method implements this operation, which we will
  not include here; see the "Further Reading" section for details of its
  derivation.
][
  `Merge()`
  方法实现了这个合并操作，具体推导这里不再展开；更多细节可参见“进一步阅读”部分。

]

=== 方阵（Square Matrices）
<方阵square-matrices>
#parec[
  The SquareMatrix class provides a representation of square
  matrices with dimensionality set at compile time via the template
  parameter N. It is an integral part of both the Transform class and
  pbrt’s color space conversion code.
][
  `SquareMatrix`
  类表示一个方阵，其维度由模板参数 `N` 在编译期决定。它既是 `Transform`
  类的重要组成部分，也被用于 `pbrt` 的颜色空间转换代码中。
]

```cpp
template <int N>
class SquareMatrix {
  public:
    <<SquareMatrix Public Methods>>
  private:
    Float m[N][N];
};
```

#parec[
  The default constructor initializes the identity matrix. Other
  constructors (not included here) allow providing the values of the
  matrix directly or via a two-dimensional array of values. Alternatively,
  `Zero()` can be used to get a zero-valued matrix or `Diag()` can be
  called with `N` values to get the corresponding diagonal matrix.
][

  默认构造函数会将矩阵初始化为单位矩阵。其他构造函数（此处未列出）允许直接提供矩阵元素，或通过二维数组赋值。除此之外，还可以使用
  `Zero()` 生成零矩阵，或者调用 `Diag()` 并传入 `N`
  个值来生成对应的对角矩阵。
]

```cpp
static SquareMatrix Zero() {
    SquareMatrix m;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            m.m[i][j] = 0;
    return m;
}
```

#parec[
  All the basic arithmetic operations between matrices are
  provided, including multiplying them or dividing them by scalar values.
  Here is the implementation of the method that adds two matrices
  together.
][

  类中提供了所有常见的矩阵运算，包括矩阵间的加法、数乘和数除。下面展示的是矩阵加法的实现：

]

```cpp
SquareMatrix operator+(const SquareMatrix &m) const {
    SquareMatrix r = *this;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            r.m[i][j] += m.m[i][j];
    return r;
}
```

#parec[
  The `IsIdentity()` checks whether the matrix is the identity
  matrix via a simple loop over its elements.
][
  `IsIdentity()`
  方法通过遍历所有元素，检查矩阵是否为单位矩阵。
]

```cpp
bool IsIdentity() const;
```

#parec[
  Indexing operators are provided as well. Because these methods
  return `span`s, the syntax for multidimensional indexing is the same as
  it is for regular C++ arrays: `m[i][j]`.
][

  类中还提供了索引运算符。由于它们返回的是
  `span`，因此二维索引的语法与常规 C++ 数组相同，可以直接写作 `m[i][j]`。

]

```cpp
pstd::span<const Float> operator[](int i) const { return m[i]; }
pstd::span<Float> operator[](int i) { return pstd::span<Float>(m[i]); }
```

#parec[
  The #link("<SquareMatrix>")[SquareMatrix] class provides a
  matrix–vector multiplication function based on template classes to
  define the types of both the vector that is operated on and the result.
  It only requires that the result type has a default constructor and that
  both types allow element indexing via `operator[]`. Thus it can, for
  example, be used in pbrt’s color space conversion code to convert from
  #link("../Radiometry,_Spectra,_and_Color/Color.html#RGB")[RGB] to
  #link("../Radiometry,_Spectra,_and_Color/Color.html#XYZ")[XYZ] via a
  call of the form `Mul<XYZ>(m, rgb)`, where `m` is a 3×3 a SquareMatrix
  and `rgb` is of type `RGB`. The math is often written as a 3×3
  matrix–vector product, i.e.~a display of a 3×3 SquareMatrix acting on a
  3-vector.
][
  `SquareMatrix`
  类提供了矩阵–向量乘法函数，其实现基于模板来定义操作向量和结果的类型。它只要求结果类型有默认构造函数，并且这两种类型都支持通过
  `operator[]` 进行索引。因此，它可以用于 `pbrt` 的颜色空间转换，例如通过
  `Mul<XYZ>(m, rgb)` 将 RGB 转换为 XYZ，其中 `m` 是一个 3×3
  `SquareMatrix`，`rgb` 是 `RGB` 类型。从数学上看，这通常记作一个 $3$
  方阵与三维向量的乘积。
]

```cpp
template <typename Tresult, int N, typename T>
Tresult Mul(const SquareMatrix<N> &m, const T &v) {
    Tresult result;
    for (int i = 0; i < N; ++i) {
        result[i] = 0;
        for (int j = 0; j < N; ++j)
            result[i] += m[i][j] * v[j];
    }
    return result;
}
```

#parec[
  The `Determinant()` function returns the value of the matrix’s
  determinant using the standard formula. Specializations for $3$ and
  $4$ matrices are carefully written to use DifferenceOfProducts() for
  intermediate calculations of matrix minors in order to maximize accuracy
  in the result for those common cases.
][
  `Determinant()`
  函数返回矩阵的行列式，采用标准公式实现。对于 $3$ 和 $4$
  矩阵，提供了专门实现，它们在计算子式时使用
  `DifferenceOfProducts()`，以在这些常见情形下尽可能提高精度。
]

```cpp
template <int N>
Float Determinant(const SquareMatrix<N> &m);
```

#parec[
  Finally, there are both `Transpose()` and `Inverse()`
  functions. Like `Determinant()`, `Inverse()` has specializations for `N`
  up to 4 and then a general implementation for matrices of larger
  dimensionality.
][
  最后，还提供了 `Transpose()` 和 `Inverse()`
  函数。与 `Determinant()` 类似，`Inverse()` 针对 $N$
  的情况提供了专门实现，而对于更高维度的矩阵则使用通用算法。
]

```cpp
template <int N>
SquareMatrix<N> Transpose(const SquareMatrix<N> &m);
template <int N>
pstd::optional<SquareMatrix<N>> Inverse(const SquareMatrix<N> &);
```

#parec[
  The regular `Inverse()` function returns an unset `optional`
  value if the matrix has no inverse. If no recovery is possible in that
  case, `InvertOrExit()` can be used, allowing calling code to directly
  access the matrix result.
][
  常规的 `Inverse()`
  函数在矩阵不可逆时会返回一个未设置的
  `optional`。如果调用方无法处理这种情况，可以使用
  `InvertOrExit()`，它会确保返回一个结果矩阵，否则程序直接终止。
]

```cpp
template <int N>
SquareMatrix<N> InvertOrExit(const SquareMatrix<N> &m) {
    pstd::optional<SquareMatrix<N>> inv = Inverse(m);
    CHECK(inv.has_value());
    return *inv;
}
```

#parec[
  Given the `SquareMatrix` definition, it is easy to implement a
  `LinearLeastSquares()` function that finds a matrix $M$ that minimizes
  the least squares error of a mapping from one set of vectors to another.
  This function is used as part of pbrt’s infrastructure for modeling
  camera response curves.
][
  基于 `SquareMatrix`，实现一个
  `LinearLeastSquares()` 函数也很容易。该函数会找到一个矩阵
  $M$，使其在将一组向量映射到另一组向量时的最小二乘误差最小化。这个函数被
  `pbrt` 用于相机响应曲线的建模。
]

```cpp
template <int N>
pstd::optional<SquareMatrix<N>>
LinearLeastSquares(const Float A[][N], const Float B[][N], int rows);
```

=== Bézier 曲线相关函数
<bézier-曲线相关函数>
#parec[


  ```cpp
  template <typename T>
  P BlossomCubicBezier(pstd::span<const P> p, Float u0, Float u1, Float u2) {
      P a[3] = { Lerp(u0, p[0], p[1]), Lerp(u0, p[1], p[2]),
                 Lerp(u0, p[2], p[3]) };
      P b[2] = { Lerp(u1, a[0], a[1]), Lerp(u1, a[1], a[2]) };
      return Lerp(u2, b[0], b[1]);
  }
  ```

  The blossom p(u, u, u) gives the curve’s value at position u. (To verify
  this for yourself, expand Equation (B.18) using ui = u, simplify, and
  compare to Equation (6.16).) Thus, implementation of the
  `EvaluateCubicBezier()` function is trivial. It too is a template
  function of the type of control point.
][


  ```cpp
  template <typename T>
  P BlossomCubicBezier(pstd::span<const P> p, Float u0, Float u1, Float u2) {
      P a[3] = { Lerp(u0, p[0], p[1]), Lerp(u0, p[1], p[2]),
                 Lerp(u0, p[2], p[3]) };
      P b[2] = { Lerp(u1, a[0], a[1]), Lerp(u1, a[1], a[2]) };
      return Lerp(u2, b[0], b[1]);
  }
  ```

  在 #strong[blossom] 表示法中，$p(u, u, u)$ 就是曲线在参数 $u$
  处的值。（你可以自己验证：将式 (B.18) 中的 $u\_i =
  u$，化简后会得到等价于式 (6.16) 的 Bézier 曲线定义。）因此，实现
  `EvaluateCubicBezier()`
  函数非常直接。它同样是一个基于控制点类型的模板函数。
]

```cpp
template <typename P>
P EvaluateCubicBezier(pstd::span<const P> cp, Float u) {
    return BlossomCubicBezier(cp, u, u, u);
}
```

#parec[
  A second variant of `EvaluateCubicBezier()` also optionally
  returns the curve’s derivative at the evaluation point. This and the
  following Bézier functions could also be template functions based on the
  type of control point; for pbrt’s uses, however, only `Point3f` variants
  are required. We therefore implement them in terms of `Point3f`, if only
  to save the verbosity and slight obscurity of the templated variants.

][
  `EvaluateCubicBezier()`
  的另一个变体在计算曲线值的同时，还可以返回曲线在该点的导数。这个函数以及后续的
  Bézier 相关函数都可以写成控制点类型的模板，但在 `pbrt` 中只需要
  `Point3f` 版本。为了简洁，我们就直接用 `Point3f` 来实现。
]

```cpp
Point3f EvaluateCubicBezier(pstd::span<const Point3f> cp, Float u,
                            Vector3f *deriv) {
    Point3f cp1[3] = { Lerp(u, cp[0], cp[1]), Lerp(u, cp[1], cp[2]),
                       Lerp(u, cp[2], cp[3]) };
    Point3f cp2[2] = { Lerp(u, cp1[0], cp1[1]), Lerp(u, cp1[1], cp1[2]) };
    if (deriv) {
        // Compute Bézier curve derivative at u
        if (LengthSquared(cp2[1] - cp2[0]) > 0)
            *deriv = 3 * (cp2[1] - cp2[0]);
        else
            *deriv = cp[3] - cp[0];
    }
    return Lerp(u, cp2[0], cp2[1]);
}
```

#parec[
  With blossoming, the final two control points that are
  linearly interpolated to compute the curve value define a line that is
  tangent to the curve.
][
  在 #strong[blossom]
  表示下，最后两个线性插值得到的控制点所形成的连线，就是曲线在该处的切线。

]

#parec[
  One edge case must be handled here: if, for example, the first
  three control points are coincident, then the derivative of the curve is
  legitimately 0 at $u = 0$. However, returning a zero-valued derivative
  in that case would be problematic since pbrt uses the derivative to
  compute the tangent vector of the curve. Therefore, this function
  returns the difference between the first and last control points in such
  cases.
][

  这里需要处理一个特殊情况：例如，如果前三个控制点重合，那么曲线在 $u=0$
  时的导数确实为 0。但在 `pbrt`
  中，这样返回一个零向量会有问题，因为系统需要用导数来计算曲线的切向量。因此，在这种情况下，该函数返回首尾控制点的差值作为导数。

]

```cpp
if (LengthSquared(cp2[1] - cp2[0]) > 0)
    *deriv = 3 * (cp2[1] - cp2[0]);
else
    *deriv = cp[3] - cp[0];
```

#parec[
  `SubdivideCubicBezier()` splits a Bézier curve into two Bézier
  curves that together are equivalent to the original curve. The last
  control point of the first subdivided curve is the same as the first
  control point of the second one and the 7 total control points are
  specified by the blossoms: (0,0,0), (0,0,1/2), (0,1/2,1/2),
  (1/2,1/2,1/2), (1/2,1/2,1), (1/2,1,1/2), and (1,1,1). There is no need
  to call #link("<BlossomCubicBezier>")[BlossomCubicBezier] to evaluate
  them, however, as each one works out to be a simple combination of
  existing control points.
][
  `SubdivideCubicBezier()` 将一条三次 Bézier
  曲线分割为两条新的 Bézier
  曲线，它们拼接后与原曲线完全一致。第一条曲线的最后一个控制点与第二条曲线的第一个控制点相同。分割后的
  7 个控制点由如下 blossom 形式给出：(0,0,0), (0,0,1/2), (0,1/2,1/2),
  (1/2,1/2,1/2), (1/2,1/2,1), (1/2,1,1/2), (1,1,1)。不过无需显式调用
  `BlossomCubicBezier()`
  来计算，因为它们都可以通过已有控制点的简单组合得到。
]

```cpp
pstd::array<Point3f, 7> SubdivideCubicBezier(pstd::span<const Point3f> cp) {
    return {cp[0],
            (cp[0] + cp[1]) / 2,
            (cp[0] + 2 * cp[1] + cp[2]) / 4,
            (cp[0] + 3 * cp[1] + 3 * cp[2] + cp[3]) / 8,
            (cp[1] + 2 * cp[2] + cp[3]) / 4,
            (cp[2] + cp[3]) / 2,
            cp[3]};
}
```

#parec[
  Figure B.5: Blossoming to Find Control Points for a Segment of
  a Bézier Curve. The four blossoms in Equation (B.18) give the control
  points for the curve from $u\_m$ to $u\_a$. Blossoming provides an
  elegant method to compute the Bézier control points of the curve that
  represent a subset of the overall curve.
][
  图 B.5：利用
  #strong[blossoming] 计算 Bézier 曲线子段的控制点。 公式 (B.18) 中的四个
  blossom 给出了从 $u\_m$ 到 $u\_a$ 的曲线控制点。Blossoming
  提供了一种优雅的方法来计算曲线子段的 Bézier 控制点。
]

#parec[
  More generally, the four control points for the curve segment
  over the range from $u\_m$ to $u\_a$ are given by the blossoms:
][

  更一般地，曲线区间 $[u\_m, u\_a
  ]$ 的四个控制点由如下 blossom 给出：

]

```tex
a_i = (1 - u_0) p_i + u_0 p_{i+1}, \quad i \in \{0,1,2\}
b_j = (1 - u_1) a_j + u_1 a_{j+1}, \quad j \in \{0,1\}
b(u_0,u_1,u_2) = (1 - u_2) b_0 + u_2 b_1
```

#parec[
  (see Figure B.5). CubicBezierControlPoints() implements this
  computation.
][
  （见图 B.5）。函数 `CubicBezierControlPoints()`
  实现了这一计算。
]

```cpp
pstd::array<Point3f, 4>
CubicBezierControlPoints(pstd::span<const Point3f> cp, Float uMin,
                         Float uMax) {
    return { BlossomCubicBezier(cp, uMin, uMin, uMin),
             BlossomCubicBezier(cp, uMin, uMin, uMax),
             BlossomCubicBezier(cp, uMin, uMax, uMax),
             BlossomCubicBezier(cp, uMax, uMax, uMax) };
}
```

#parec[
  Bounding boxes of Curves can be efficiently computed by taking
  advantage of the convex hull property, a property of Bézier curves that
  says that they must lie within the convex hull of their control points.
  Therefore, the bounding box of the control points gives a conservative
  bound of the underlying curve. This bounding box is returned by the
  `BoundCubicBezier()` function.
][
  Bézier
  曲线的包围盒可以高效计算，这是因为它们具有#strong[凸包性质];：曲线必然位于控制点的凸包之内。因此，控制点的包围盒就是曲线的保守边界。`BoundCubicBezier()`
  函数就返回这个边界。
]

```cpp
Bounds3f BoundCubicBezier(pstd::span<const Point3f> cp) {
    return Union(Bounds3f(cp[0], cp[1]), Bounds3f(cp[2], cp[3]));
}
```

#parec[
  A second variant of this function bounds a Bézier curve over a
  specified parametric range via a call to `CubicBezierControlPoints()`.

][
  该函数还有一个变体，可以通过调用 `CubicBezierControlPoints()`
  来计算 Bézier 曲线在指定参数区间上的包围盒。
]

```cpp
Bounds3f BoundCubicBezier(pstd::span<const Point3f> cp, Float uMin,
                          Float uMax) {
    if (uMin == 0 && uMax == 1)
        return BoundCubicBezier(cp);
    auto cpSeg = CubicBezierControlPoints(cp, uMin, uMax);
    return BoundCubicBezier(pstd::span<const Point3f>(cpSeg));
}
```

=== B.2.14 伪随机数生成
<b.2.14-伪随机数生成>
#parec[
  pbrt uses an implementation of the PCG pseudo-random number
  generator (O’Neill 2014) to generate pseudo-random numbers. This
  generator not only passes a variety of rigorous statistical tests of
  randomness, but its implementation is also extremely efficient.
][

  `pbrt` 使用了 #strong[PCG] 伪随机数生成器（O’Neill
  2014）的一个实现来生成随机数。该生成器不仅通过了各种严格的随机性统计测试，而且实现非常高效。

]

#parec[
  We wrap its implementation in a small random number generator
  class, `RNG`, which can be found in the files (util/rng.h) and
  (util/rng.cpp). Random number generator implementation is an esoteric
  art; therefore, we will not include or discuss the implementation here
  but will describe the interfaces provided.
][

  我们将其实现封装在一个小型的随机数生成器类 `RNG` 中，相关代码位于
  `(util/rng.h)` 和
  `(util/rng.cpp)`。随机数生成器的实现本身是一门复杂的技术，因此这里不展开具体代码，而只介绍其接口。

]

```cpp
class RNG {
  public:
    <<RNG Public Methods>>
  private:
    <<RNG Private Members>>
};
```

#parec[
  The `RNG` class provides three constructors. The first, which
  takes no arguments, sets the internal state to reasonable defaults. The
  others allow providing values that seed its state. The PCG random number
  generator actually allows the user to provide two 64-bit values to
  configure its operation: one chooses from one of $2^{63}$ different
  sequences of $2^{64}$ random numbers, while the second effectively
  selects a starting point within such a sequence. Many pseudo-random
  number generators only allow this second form of configuration, which
  alone is not as useful: having independent non-overlapping sequences of
  values rather than different starting points in a single sequence
  provides greater nonuniformity in the generated values.
][
  `RNG`
  类提供了三个构造函数。第一个不带参数，会将内部状态设为合理的默认值。其他构造函数允许传入用于初始化状态的参数。PCG
  生成器实际上允许用户提供两个 64 位数来配置它：第一个决定选择 $2^{63}$
  个长度为 $2^{64}$
  的随机序列中的哪一个；第二个则选择该序列中的起始位置。许多其他伪随机数生成器只支持第二种配置方式，即选择起始点，这样不如支持独立的不重叠序列来得灵活，因为后者能产生更好的不相关性。

]

```cpp
RNG() : state(PCG32_DEFAULT_STATE), inc(PCG32_DEFAULT_STREAM) {}
RNG(uint64_t seqIndex, uint64_t offset) { SetSequence(seqIndex, offset); }
RNG(uint64_t seqIndex) { SetSequence(seqIndex); }
```

#parec[
  The RNG class also provides basic sequence handling:
][

  `RNG` 类还提供了基本的序列管理方法：
]

```cpp
void SetSequence(uint64_t sequenceIndex, uint64_t offset);
void SetSequence(uint64_t sequenceIndex) {
    SetSequence(sequenceIndex, MixBits(sequenceIndex));
}
```

#parec[
  The `RNG` class defines a template method `Uniform()` that
  returns a uniformly distributed random value of the specified type. A
  variety of specializations of this method are provided for basic
  arithmetic types.
][
  `RNG` 类定义了一个模板方法
  `Uniform()`，它返回指定类型的均匀分布随机值。针对常见算术类型，提供了多种特化版本。

]

```cpp
template <typename T>
T Uniform();
```

#parec[
  The default implementation of `Uniform()` attempts to ensure
  that a useful error message is issued if it is invoked with an
  unsupported type.
][
  `Uniform()`
  的默认实现会保证在传入不支持的类型时，抛出有意义的错误提示。
]

```cpp
template <>
uint32_t RNG::Uniform<uint32_t>();
```

#parec[
  A specialization for `uint32_t` uses the PCG algorithm to
  generate a 32-bit value. We will not include its implementation here, as
  it would be impenetrable without an extensive discussion of the details
  of the pseudo-random number generation approach it implements.
][
  针对
  `uint32_t` 的特化版本使用 PCG 算法生成一个 32
  位整数。其实现过于复杂，如果不详细讲解 PCG
  算法的原理会显得难以理解，因此这里不展开。
]

```cpp
template <>
uint64_t RNG::Uniform<uint64_t>() {
    uint64_t v0 = Uniform<uint32_t>(), v1 = Uniform<uint32_t>();
    return (v0 << 32) | v1;
}
```

#parec[
  Generating a uniformly distributed signed 32-bit integer
  requires surprisingly tricky code. The issue is that in C++, it is
  undefined behavior to assign a value to a signed integer that is larger
  than it can represent. Undefined behavior does not just mean that the
  result is undefined, but that, in principle, no further guarantees are
  made about correct program execution after it occurs. Therefore, the
  following code is carefully written to avoid integer overflow. In
  practice, a good compiler can be expected to optimize away the extra
  work.
][
  生成均匀分布的有符号 32
  位整数的代码出乎意料地复杂。问题在于，在 C++
  中，将超出表示范围的值赋给有符号整数会导致
  #strong[未定义行为];。这不仅意味着结果不确定，还可能破坏程序的正确执行。因此，下面的代码被精心设计，以避免整数溢出。在实际应用中，一个优秀的编译器会优化掉这些额外操作。

]

```cpp
template <>
int32_t RNG::Uniform<int32_t>() {
    uint32_t v = Uniform<uint32_t>();
    if (v <= (uint32_t)std::numeric_limits<int32_t>::max())
        return int32_t(v);
    return int32_t(v - std::numeric_limits<int32_t>::min()) +
           std::numeric_limits<int32_t>::min();
}
```

#parec[
  A similar method returns pseudo-random `int64_t` values.
][

  类似的方法也被用于生成伪随机的 `int64_t` 值。
]

#parec[
  It is often useful to generate a value that is uniformly
  distributed in the range $[0, b-1
  ]$ given a bound$b$. The first two
  versions of pbrt effectively computed Uniform\<int32\_t\>() % b to do
  so. That approach is subtly flawed—in the case that$b$ does not
  evenly divide $2^{32}$, there is higher probability of choosing any
  given value in the sub-range$[0, 2^{32}-1]$.
][
  在许多情况下，我们希望生成一个范围在$[0, b-1]$ 内的均匀随机整数（其中$b$ 为上界）。在 `pbrt` 的前两个版本中，通常通过  `Uniform<int32_t>() % b` 来实现。但这种方法有细微缺陷：如果 $b$ 不能整除 $2^{32}$，那么在$[0, 2^{32}-1]$
  内某些值的出现概率会更高，从而导致分布不均匀。
]

#parec[
  Therefore, the implementation here first computes the above
  remainder $2^{32}$ efficiently using 32-bit arithmetic and stores it
  in the variable `threshold`. Then, if the value returned by `Uniform()`
  is less than `threshold`, it is discarded and a new value is generated.
  The resulting distribution of values has a uniform distribution after
  the modulus operation, giving a uniformly distributed sample value.
][

  因此，这里的实现会先高效地计算出 $2^{32}$ 对 $b$ 的余数，并存入
  `threshold`。随后，如果 `Uniform()`
  生成的值小于该阈值，就舍弃并重新生成一个。最终保留下来的结果在取模运算后能得到严格均匀分布的值。

]

#parec[
  The tricky declaration of the return value ensures that this
  variant of Uniform() is only available for integral types.
][

  这里返回值的声明方式保证了该版本的 `Uniform()` 仅适用于整数类型。
]

```cpp
template <typename T>
typename std::enable_if_t<std::is_integral_v<T>, T> Uniform(T b) {
    T threshold = (~b + 1u) % b;
    while (true) {
        T r = Uniform<T>();
        if (r >= threshold)
            return r % b;
    }
}
```

#parec[
  A specialization of `Uniform()` for `float`s generates a
  pseudo-random floating-point number in the half-open interval $[0, 1)$ by
  multiplying a 32-bit random value by $2^{-32}$. Mathematically, this
  value is always less than one; it can be at most (2#super[32−1)/2];32.
  However, some values still round to 1 when computed using floating-point
  arithmetic. That case is handled here by clamping to the largest
  representable less than one. Doing so introduces a tiny bias, but not
  one that is meaningful for rendering applications.
][
  针对 `float`
  的特化版本会返回一个区间 $[0,1)$ 内的伪随机浮点数，它的实现方式是将 32
  位随机整数乘以 $2^{-32}$。从数学上说，该值一定小于 1，最大为
  $(2#super[{32}-1)/2];{32}$。然而，由于浮点舍入的原因，某些值可能会变成
  1。对此，这里将结果钳制到小于 1
  的最大可表示浮点数。虽然这样会引入极小的偏差，但对渲染应用没有实际影响。

]

```cpp
template <>
float RNG::Uniform<float>() {
    return std::min<float>(OneMinusEpsilon, Uniform<uint32_t>() * 0x1p-32f);
}
```

#parec[
  An equivalent method for `double`s is provided but is not
  included here.
][
  对于 `double` 类型也提供了等价的方法，但此处未列出。

]

#parec[
  With this random number generator, it is possible to step
  forward or back to a different spot in the sequence without generating
  all the intermediate values. The `Advance()` method provides this
  functionality.
][

  使用该随机数生成器，可以在序列中向前或向后跳转，而无需生成所有中间值。`Advance()`
  方法就提供了这种功能。
]

```cpp
void RNG::Advance(int64_t idelta);
```

=== B.2.15 区间算术（Interval Arithmetic）
<b.2.15-区间算术interval-arithmetic>
#parec[
  Interval arithmetic is a technique that can be used to reason
  about the range of a function over some range of values and also to
  bound the round-off error introduced by a series of floating-point
  calculations. The `Interval` class provides functionality for both of
  these uses.
][

  区间算术是一种技术，可以用来推导函数在某个取值区间上的范围，同时还可以用来约束一系列浮点运算所引入的舍入误差。`Interval`
  类为这两类用途都提供了支持。
]

#parec[
  To understand the basic idea of interval arithmetic, consider,
  for example, the function $f(x) = 2x$. If we have an interval of
  values $[a, b
  ]$, then we can see that, over the interval, the range
  of$f$ is the interval $[2a, 2b
  ]$. In other words,$f($[a,b
  ])$[2a, 2b
  ]$. More generally, all the basic operations of arithmetic
  have #emph[interval extensions] that describe how they operate on
  intervals of values. For example, given two intervals$[a,b
  ]$ and $[c,d ]$,
][
  为了理解区间算术的基本思想，我们考虑函数$f(x) =
  2x$。如果输入是一个区间$[a, b
  ]$，那么显然$f$ 在该区间上的取值范围就是 $[2a, 2b
  ]$。换句话说，$f($[a,b
  ]) $[2a,
    2b
  ]$。更一般地，所有基本算术运算都有其#strong[区间扩展];，用来描述它们在区间输入上的结果。例如，给定两个区间
  $[a,b
  ]$ 和 $[c,d
  ]$：
]

$[a , b] + [c , d] subset.eq [a + c , b + d] .$

#parec[
  Interval arithmetic has the important property that the
  intervals that it gives are conservative. For example, if $f($[a,b
  ])
  $[c,d
  ]$ and if $c \> 0$, then we know for sure that no value in
  $[a,b]$ causes f to be negative.
][
  区间算术的一个重要性质是其结果是#strong[保守的];。例如，如果$f($[a,b
  ])$[c,d
  ]$ 且 $c \> 0$，那么我们可以确定，$[a,b
  ]$
  中的任何值都不会使 $f$ 变为负数。
]

#parec[
  When implemented in floating-point arithmetic, interval
  operations can be defined so that they result in intervals that bound
  the true value. Given a function that rounds a value that cannot exactly
  be represented as a floating-point value down to the next lower
  floating-point value and one that similarly rounds up, interval addition
  can be defined as
][

  在浮点数实现中，区间运算被定义为返回包含真实值的区间。假设我们有一个函数，可以将不能精确表示的浮点数向下舍入到下一个更小的浮点数，另一个函数则可以向上舍入到更大的浮点数，那么区间加法可以定义为：

]

$[a , b] xor [c , d] subset.eq [a + c , b + d] .$

#parec[
  Performing a series of floating-point calculations in this
  manner is the basis of running error analysis, which was described in
  Section 6.8.1.
][

  以这种方式执行一系列浮点运算，就是#strong[运行误差分析];（running error
  analysis）的基础，这在第 6.8.1 节中有介绍。
]

#parec[
  pbrt uses interval arithmetic to compute error bounds for ray
  intersections with quadrics and also uses the interval-based Point3i
  class to store computed ray intersection points on surfaces. The
  zero-finding method used to find the extrema of moving bounding boxes in
  `AnimatedTransform::BoundPointMotion()` (included in the online edition)
  is also based on interval arithmetic.
][
  `pbrt`
  使用区间算术来计算光线与二次曲面的相交误差范围，同时还用基于区间的
  `Point3i` 类来存储曲面上的光线交点。在线版代码中
  `AnimatedTransform::BoundPointMotion()`
  用于计算运动包围盒极值的零点查找方法，也基于区间算术。
]

#parec[
  The `Interval` class provides interval arithmetic capabilities
  using operator overloading to make it fairly easy to switch existing
  regular floating-point computations over to be interval-based.
][

  `Interval`
  类通过运算符重载提供区间算术功能，这使得将现有的浮点数计算替换为区间计算变得相对容易。

]

```cpp
class Interval {
  public:
    <<Interval Public Methods>>
  private:
    <<Interval Private Members>>
};
```

#parec[
  Before we go further with `Interval`, we will define some
  supporting utility functions for performing basic arithmetic with
  specified rounding. Recall that the default with floating-point
  arithmetic is that results are rounded to the nearest representable
  floating-point value, with ties being rounded to the nearest even value
  (i.e., with a zero-valued low bit in its significand). However, in order
  to compute conservative intervals like those in Equation (B.18), it is
  necessary to specify different rounding modes for different operations,
  rounding down when computing the value at the lower range of the
  interval and rounding up at the upper range.
][
  在深入介绍 `Interval`
  之前，我们先定义一些支持函数，用于执行带有特定舍入模式的基本运算。回顾一下，浮点数运算的默认规则是：结果会被舍入到最接近的可表示浮点数，若正好在中间，则舍入到尾数最低位为
  0 的偶数。然而，要想计算出如公式 (B.18)
  那样的保守区间，就必须为不同运算指定不同的舍入模式：在区间下界计算时向下舍入，在区间上界计算时向上舍入。

]

#parec[
  The IEEE floating-point standard requires capabilities to
  control the rounding mode, but unfortunately it is expensive to change
  it on modern CPUs. Doing so generally requires a flush of the execution
  pipeline, which may cost many tens of cycles. Therefore, `pbrt` provides
  utility functions that perform various arithmetic operations where the
  final value is then nudged up or down to the next representable float.
  This will lead to intervals that are slightly too large, sometimes
  nudging when it is not necessary, but for `pbrt`’s purposes it is
  preferable to paying the cost of changing the rounding mode.
][
  IEEE
  浮点标准规定可以控制舍入模式，但在现代 CPU
  上切换舍入模式的代价很高，一般需要清空流水线，可能耗费数十个时钟周期。因此，`pbrt`
  提供了一些工具函数，在完成常规浮点运算后，再将结果向上或向下调整到下一个可表示浮点数。这样得到的区间可能比实际略大，有时甚至是非必要的调整，但对于
  `pbrt` 来说，这样做比频繁切换舍入模式要高效得多。
]

```cpp
Float AddRoundUp(Float a, Float b) {
    return NextFloatUp(a + b);
}
Float AddRoundDown(Float a, Float b) {
    return NextFloatDown(a + b);
}
```

#parec[
  An interval can be initialized with a single value or a pair of values
  that specify an interval with nonzero width.
][

  一个区间既可以用单个值初始化（表示零宽度区间），也可以用一对值初始化（表示非零宽度的区间）。

]


```cpp
explicit Interval(Float v) : low(v), high(v) {}
Interval(Float low, Float high)
    : low(std::min(low, high)), high(std::max(low, high)) {}
```

```cpp
Float low, high;
```

#parec[
  It can also be specified by a value and an error bound. Note
  that the implementation uses rounded arithmetic functions to ensure a
  conservative interval.
][

  还可以通过一个值和一个误差范围来定义区间。需要注意的是，这里的实现使用了带舍入的算术函数，以确保生成的区间是#strong[保守的];。

]

```cpp
static Interval FromValueAndError(Float v, Float err) {
    Interval i;
    if (err == 0)
        i.low = i.high = v;
    else {
        i.low = SubRoundDown(v, err);
        i.high = AddRoundUp(v, err);
    }
    return i;
}
```

#parec[
  A number of accessor methods provide information about the
  interval. An implementation of `operator[]`, not included here, allows
  indexing the two bounding values.
][

  类中还提供了一些访问方法，可以获取区间的相关信息。此外，它还实现了
  `operator[]`（此处未展示），允许通过下标访问上下界。
]

```cpp
Float UpperBound() const { return high; }
Float LowerBound() const { return low; }
Float Midpoint() const { return (low + high) / 2; }
Float Width() const { return high - low; }
```

#parec[
  An interval can be converted to a `Float` approximation to it,
  but only through an explicit cast, which ensures that intervals are not
  accidentally reduced to `Float`s in the middle of a computation, thus
  causing an inaccurate final interval.
][
  区间也可以显式转换为
  `Float`，得到一个近似值。但这种转换必须通过#strong[显式类型转换];完成，从而避免在计算过程中区间被无意间降为单个
  `Float`，导致最终结果不准确。
]

```cpp
explicit operator Float() const { return Midpoint(); }
```

#parec[
  `InRange()` method implementations check whether a given value
  is in the interval and whether two intervals overlap.
][
  `InRange()`
  方法用来检查某个值是否落在区间内，以及两个区间是否重叠。
]

```cpp
bool InRange(Float v, Interval i) {
    return v >= i.LowerBound() && v <= i.UpperBound();
}
bool InRange(Interval a, Interval b) {
    return a.LowerBound() <= b.UpperBound() &&
           a.UpperBound() >= b.LowerBound();
}
```

#parec[
  Negation of an interval is straightforward, as it does not
  require any rounding.
][

  区间的取负操作非常直接，因为它不需要任何舍入操作。
]

```cpp
Interval operator-() const { return {-high, -low}; }
```

#parec[
  The addition operator just requires implementing Equation
  (B.18) with the appropriate rounding.
][
  区间的加法运算只需按照公式
  (B.18)，并在必要时进行适当的舍入即可。
]

```cpp
Interval operator+(Interval i) const {
    return {AddRoundDown(low, i.low), AddRoundUp(high, i.high)};
}
```

#parec[
  The subtraction operator and the `+=` and `-=` operators
  follow the same pattern, so they are not included in the text.
][

  减法运算以及 `+=`、`-=` 等操作符遵循相同的模式，因此这里省略不再展开。

]

#parec[
  Interval multiplication and division are slightly more
  involved: which of the `low` and `high` bounds of each of the two
  intervals is used to determine each of the bounds of the result depends
  on the signs of the values involved. Rather than incur the overhead of
  working out exactly which pairs to use, Interval’s implementation of the
  multiply operator computes all of them and then takes the minimum and
  maximum.
][

  区间的乘法和除法要稍微复杂一些：结果区间的上下界取决于输入两个区间的上下界符号组合。为了避免逐一判断到底该取哪一对边界，`Interval`
  的乘法实现采取了更直接的方式：计算所有可能的乘积，然后取最小值作为下界，取最大值作为上界。

]

```cpp
Interval operator*(Interval i) const {
    Float lp[4] = { MulRoundDown(low, i.low),  MulRoundDown(high, i.low),
                    MulRoundDown(low, i.high), MulRoundDown(high, i.high)};
    Float hp[4] = { MulRoundUp(low, i.low),  MulRoundUp(high, i.low),
                    MulRoundUp(low, i.high), MulRoundUp(high, i.high)};
    return {std::min({lp[0], lp[1], lp[2], lp[3]}),
            std::max({hp[0], hp[1], hp[2], hp[3]})};
}
```

#parec[
  The division operator follows a similar form, though it must
  check to see if the divisor interval spans zero. If so, an infinite
  interval must be returned.
][

  除法运算符遵循类似的形式，但必须额外检查除数区间是否跨越 0。如果跨越
  0，则结果是一个无穷大的区间。
]



#parec[
  The interval `Sqr()` function is more than a shorthand; it is
  sometimes able to compute a tighter bound than would be found by
  multiplying an interval by itself using `operator*`. To see why,
  consider two independent intervals that both happen to have the range
  $[-2, 3]$. Multiplying them together results in the interval$[-6, 9
  ]$.  However, if we are multiplying an interval by itself, we know that there  is no way that squaring it would result in a negative value. Therefore,  if an interval with the bounds$[-2, 3
  ]$is multiplied by itself, it is  possible to return the tighter interval$[0, 9 ]$ instead.
][
  `Sqr()`
  函数并不仅仅是一个简写形式；它有时能给出比直接用 `operator*`
  将区间自乘更紧的边界。原因如下：假设两个独立的区间都是$[-2, 3 ]$，那么相乘得到的区间是$[-6, 9 ]$。但如果是同一个区间自乘，我们知道平方结果不可能为负。因此，$[-2, 3 ]$的平方区间可以收紧为$[0, 9
  ]$。
]

```cpp
Interval Sqr(Interval i) {
    Float alow = std::abs(i.LowerBound()), ahigh = std::abs(i.UpperBound());
    if (alow > ahigh)
        pstd::swap(alow, ahigh);
    if (InRange(0, i))
        return Interval(0, MulRoundUp(ahigh, ahigh));
    return Interval(MulRoundDown(alow, alow), MulRoundUp(ahigh, ahigh));
}
```



#parec[
  A variety of additional arithmetic operations are provided by
  the `Interval` class, including `Abs()`, `Min()`, `Max()`, `Sqrt()`,
  `Floor()`, `Ceil()`, `Quadratic()`, and assorted trigonometric
  functions. See the pbrt source code for their implementations.
][

  `Interval` 类还提供了多种其他算术运算，包括
  `Abs()`、`Min()`、`Max()`、`Sqrt()`、`Floor()`、`Ceil()`、`Quadratic()`
  以及若干三角函数。具体实现可参考 `pbrt` 源码。
]

#parec[
  `pbrt` provides 3D vector and point classes that use
  `Interval` for the coordinate values. Here, the "fi" at the end of
  `Vector3fi` denotes "float interval." These classes are easily defined
  thanks to the templated definition of the `Vector3` and `Point3` classes
  and the underlying `Tuple3` class from Section 3.2.
][
  `pbrt`
  提供了使用 `Interval` 作为坐标分量的三维向量和点类。这里 `Vector3fi`
  名称中的 "fi" 表示 "float
  interval（浮点区间）"。这些类的定义非常简洁，因为它们直接基于
  `Vector3`、`Point3` 的模板定义，以及第 3.2 节介绍过的底层 `Tuple3`
  类实现。
]

```cpp
class Vector3fi : public Vector3<Interval> {
  public:
    <<Vector3fi Public Methods>>
};
```

#parec[
  In addition to the usual constructors, `Vector3fi` can be
  initialized by specifying a base vector and a second one that gives
  error bounds for each component.
][
  除了常规构造函数外，`Vector3fi`
  还可以通过指定一个基向量和另一个误差向量来初始化，每个分量的误差都会作为对应区间的范围。

]

```cpp
Vector3fi(Vector3f v, Vector3f e)
    : Vector3<Interval>(Interval::FromValueAndError(v.x, e.x),
                        Interval::FromValueAndError(v.y, e.y),
                        Interval::FromValueAndError(v.z, e.z)) {}
```

#parec[
  Helper methods return error bounds for the vector components
  and indicate if the value stored has empty intervals.
][

  该类还提供辅助方法来返回向量分量的误差范围，并检查存储的值是否是精确的（即区间宽度为零）。

]

```cpp
Vector3f Error() const {
    return {x.Width() / 2, y.Width() / 2, z.Width() / 2};
}
bool IsExact() const {
    return x.Width() == 0 && y.Width() == 0 && z.Width() == 0;
}
```

#parec[
  The `Point3fi` class, not included here, similarly provides
  the capabilities of a `Point3` using intervals for its coordinate
  values. It, too, provides `Error()` and `IsExact()` methods.
][

  `Point3fi`
  类（此处未列出）与之类似，它提供了基于区间的三维点表示。同样实现了
  `Error()` 和 `IsExact()` 方法。
]

=== Square Matrices （方阵）
<square-matrices-方阵>
#parec[
  The SquareMatrix class provides a representation of square
  matrices with dimensionality set at compile time via the template
  parameter N. It is an integral part of both the Transform class and
  pbrt’s color space conversion code.
][
  `SquareMatrix`
  类提供了方阵的表示形式，其维度在编译期通过模板参数 `N` 指定。它既是
  `Transform` 类的重要组成部分，也是 `pbrt` 颜色空间转换代码中的核心组件。

]

```cpp
<<SquareMatrix Definition>>=
template <int N>
class SquareMatrix {
  public:
    <<SquareMatrix Public Methods>>
  private:
    Float m[N][N];
};
```

#parec[
  The default constructor initializes the identity matrix. Other
  constructors (not included here) allow providing the values of the
  matrix directly or via a two-dimensional array of values. Alternatively,
  `Zero()` can be used to get a zero-valued matrix or `Diag()` can be
  called with `N` values to get the corresponding diagonal matrix.
][

  默认构造函数会初始化为单位矩阵。其他构造函数（此处未列出）允许直接提供矩阵的值，或者通过二维数组提供值。除此之外，还可以调用
  `Zero()` 得到零矩阵，或调用 `Diag()` 并传入 `N`
  个值来得到对应的对角矩阵。
]

```cpp
static SquareMatrix Zero() {
    SquareMatrix m;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            m.m[i][j] = 0;
    return m;
}
```

#parec[
  All the basic arithmetic operations between matrices are
  provided, including multiplying them or dividing them by scalar values.
  Here is the implementation of the method that adds two matrices
  together.
][

  类中实现了所有基本的矩阵算术运算，包括矩阵与矩阵相乘、矩阵与标量相除等。下面是两个矩阵相加的实现：

]

```cpp
SquareMatrix operator+(const SquareMatrix &m) const {
    SquareMatrix r = *this;
    for (int i = 0; i < N; ++i)
        for (int j = 0; j < N; ++j)
            r.m[i][j] += m.m[i][j];
    return r;
}
```

#parec[
  The `IsIdentity()` checks whether the matrix is the identity
  matrix via a simple loop over its elements.
][
  `IsIdentity()`
  方法检查矩阵是否为单位矩阵，其实现就是简单地遍历所有元素。
]

```cpp
bool IsIdentity() const;
```

#parec[
  Indexing operators are provided as well. Because these methods
  return `span`s, the syntax for multidimensional indexing is the same as
  it is for regular C++ arrays: `m[i][j]`.
][

  还提供了索引操作符。由于这些方法返回的是
  `span`，所以多维索引的语法和普通 C++ 数组一样，可以写作 `m[i][j]`。
]

```cpp
pstd::span<const Float> operator[](int i) const { return m[i]; }
pstd::span<Float> operator[](int i) { return pstd::span<Float>(m[i]); }
```

#parec[
  The SquareMatrix class provides a matrix–vector multiplication
  function based on template classes to define the types of both the
  vector that is operated on and the result. It only requires that the
  result type has a default constructor and that both types allow element
  indexing via `operator[]`. Thus it can, for example, be used in pbrt’s
  color space conversion code to convert from RGB to XYZ via a call of the
  form `Mul<XYZ>(m, rgb)`, where `m` is a 3×3 a SquareMatrix and `rgb` is
  of type RGB. The math is often written as a 3×3 matrix–vector product,
  i.e.~a display of a 3×3 SquareMatrix acting on a 3-vector.
][

  `SquareMatrix`
  类还提供了矩阵–向量乘法函数。该函数基于模板类实现，用于指定输入向量和结果向量的类型。它仅要求结果类型有一个默认构造函数，并且两者都支持
  `operator[]` 访问。 例如，它可用于 `pbrt` 的颜色空间转换，将 `RGB`
  转换为 `XYZ`：调用形式为 `Mul<XYZ>(m, rgb)`，其中 `m` 是一个 3×3 的
  `SquareMatrix`，`rgb` 是 `RGB` 类型。数学表达上，这就是一个 $3$
  矩阵与三维向量的乘法。
]

```cpp
template <typename Tresult, int N, typename T>
Tresult Mul(const SquareMatrix<N> &m, const T &v) {
    Tresult result;
    for (int i = 0; i < N; ++i) {
        result[i] = 0;
        for (int j = 0; j < N; ++j)
            result[i] += m[i][j] * v[j];
    }
    return result;
}
```

#parec[
  The `Determinant()` function returns the value of the matrix’s
  determinant using the standard formula. Specializations for $3$ and
  $4$ matrices are carefully written to use `DifferenceOfProducts()` for
  intermediate calculations of matrix minors in order to maximize accuracy
  in the result for those common cases.
][
  `Determinant()`
  函数返回矩阵的行列式值，使用的是标准公式。针对 $3$ 和 $4$
  矩阵的特化实现会特别小心，利用 `DifferenceOfProducts()`
  计算子式，以提高这些常见情况的数值精度。
]

```cpp
template <int N>
Float Determinant(const SquareMatrix<N> &m);
```

#parec[
  Finally, there are both `Transpose()` and `Inverse()`
  functions. Like `Determinant()`, `Inverse()` has specializations for `N`
  up to 4 and then a general implementation for matrices of larger
  dimensionality.
][
  最后，还提供了 `Transpose()` 和 `Inverse()`
  函数。与 `Determinant()` 类似，`Inverse()` 针对 $N$
  的情况有特化实现，而对于更高维度的矩阵则使用通用实现。
]

```cpp
template <int N>
SquareMatrix<N> Transpose(const SquareMatrix<N> &m);
template <int N>
pstd::optional<SquareMatrix<N>> Inverse(const SquareMatrix<N> &);
```

#parec[
  The regular `Inverse()` function returns an unset `optional`
  value if the matrix has no inverse. If no recovery is possible in that
  case, `InvertOrExit()` can be used, allowing calling code to directly
  access the matrix result.
][
  常规的 `Inverse()`
  函数在矩阵不可逆时会返回一个未设置的 `optional`
  值。如果调用场景下无法接受这种情况，可以使用
  `InvertOrExit()`，它会在矩阵不可逆时报错退出，从而保证调用代码始终能得到一个结果。

]

```cpp
template <int N>
SquareMatrix<N> InvertOrExit(const SquareMatrix<N> &m) {
    pstd::optional<SquareMatrix<N>> inv = Inverse(m);
    CHECK(inv.has_value());
    return *inv;
}
```

#parec[
  Given the `SquareMatrix` definition, it is easy to implement a
  `LinearLeastSquares()` function that finds a matrix $M$ that minimizes
  the least squares error of a mapping from one set of vectors to another.
  This function is used as part of pbrt’s infrastructure for modeling
  camera response curves.
][
  基于 `SquareMatrix`
  的定义，可以很容易实现一个 `LinearLeastSquares()` 函数，用于寻找一个矩阵
  $M$，使其最小化一组向量到另一组向量之间的最小二乘误差。该函数在 `pbrt`
  中用于建模相机响应曲线。
]

```cpp
template <int N> pstd::optional<SquareMatrix<N>>
LinearLeastSquares(const Float A[][N], const Float B[][N], int rows);
```



=== Bézier 多项式相关
<bézier-多项式相关>
#parec[
  The blossom p(u, u, u) gives the curve’s value at position u.
  (To verify this for yourself, expand Equation (B.18) using ui = u,
  simplify, and compare to Equation (6.16).) Thus, implementation of the
  `EvaluateCubicBezier()` function is trivial. It too is a template
  function of the type of control point.
][
  blossom 表示法中的
  $p(u,u,u)$ 就是曲线在参数 $u$ 处的值。（你可以自己验证：将公式
  (B.18) 中的 $u\_i = u$，化简后对比公式 (6.16) 即可。）因此，实现
  `EvaluateCubicBezier()`
  函数非常直接，它同样是一个基于控制点类型的模板函数。
]

```cpp
template <typename P>
P EvaluateCubicBezier(pstd::span<const P> cp, Float u) {
    return BlossomCubicBezier(cp, u, u, u);
}
```

#parec[
  A second variant of `EvaluateCubicBezier()` also optionally
  returns the curve’s derivative at the evaluation point. This and the
  following Bézier functions could also be template functions based on the
  type of control point; for pbrt’s uses, however, only `Point3f` variants
  are required. We therefore implement them in terms of `Point3f`, if only
  to save the verbosity and slight obscurity of the templated variants.

][
  `EvaluateCubicBezier()`
  的另一个版本还可以返回曲线在给定点的导数。这个函数以及后续的 Bézier
  函数本可以写成模板以支持不同类型的控制点，但 `pbrt` 中只需要 `Point3f`
  类型，因此直接用 `Point3f` 来实现，避免模板带来的冗长与复杂性。
]

```cpp
Point3f EvaluateCubicBezier(pstd::span<const Point3f> cp, Float u,
                            Vector3f *deriv) {
    Point3f cp1[3] = { Lerp(u, cp[0], cp[1]), Lerp(u, cp[1], cp[2]),
                       Lerp(u, cp[2], cp[3]) };
    Point3f cp2[2] = { Lerp(u, cp1[0], cp1[1]), Lerp(u, cp1[1], cp1[2]) };
    if (deriv) {
        // Compute Bézier curve derivative at u
        if (LengthSquared(cp2[1] - cp2[0]) > 0)
            *deriv = 3 * (cp2[1] - cp2[0]);
        else
            *deriv = cp[3] - cp[0];
    }
    return Lerp(u, cp2[0], cp2[1]);
}
```

#parec[
  With blossoming, the final two control points that are
  linearly interpolated to compute the curve value define a line that is
  tangent to the curve.
][
  在 #strong[blossoming]
  表示中，用于计算曲线值的最后两个控制点（经过线性插值得到）构成的直线，就是曲线在该点的切线。

]

#parec[
  One edge case must be handled here: if, for example, the first
  three control points are coincident, then the derivative of the curve is
  legitimately 0 at $u = 0$. However, returning a zero-valued derivative
  in that case would be problematic since pbrt uses the derivative to
  compute the tangent vector of the curve. Therefore, this function
  returns the difference between the first and last control points in such
  cases.
][
  这里需要处理一个特殊情况：如果前三个控制点重合，那么曲线在
  $u=0$ 时的导数确实为 0。然而在 `pbrt`
  中返回零向量会带来问题，因为它需要利用导数来计算切向量。因此在这种情况下，该函数返回首尾控制点的差值作为导数。

]



=== Bézier 分割与包围盒
<bézier-分割与包围盒>
#parec[
  `SubdivideCubicBezier()` splits a Bézier curve into two Bézier
  curves that together are equivalent to the original curve. The last
  control point of the first subdivided curve is the same as the first
  control point of the second one and the 7 total control points are
  specified by the blossoms: (0,0,0), (0,0,1/2), (0,1/2,1/2),
  (1/2,1/2,1/2), (1/2,1/2,1), (1/2,1,1/2), and (1,1,1). There is no need
  to call #link("<BlossomCubicBezier>")[BlossomCubicBezier] to evaluate
  them, however, as each one works out to be a simple combination of
  existing control points.
][
  `SubdivideCubicBezier()` 将一条三次 Bézier
  曲线拆分为两条子曲线，二者拼接后与原曲线完全一致。第一条曲线的最后一个控制点与第二条曲线的第一个控制点相同。分割后的
  7 个控制点可以通过以下 blossom
  给出：(0,0,0)、(0,0,1/2)、(0,1/2,1/2)、(1/2,1/2,1/2)、(1/2,1/2,1)、(1/2,1,1/2)、(1,1,1)。不过无需显式调用
  `BlossomCubicBezier()`
  来计算，因为它们都可以通过已有控制点的简单组合得到。
]

```cpp
pstd::array<Point3f, 7> SubdivideCubicBezier(pstd::span<const Point3f> cp) {
    return {cp[0],
            (cp[0] + cp[1]) / 2,
            (cp[0] + 2 * cp[1] + cp[2]) / 4,
            (cp[0] + 3 * cp[1] + 3 * cp[2] + cp[3]) / 8,
            (cp[1] + 2 * cp[2] + cp[3]) / 4,
            (cp[2] + cp[3]) / 2,
            cp[3]};
}
```

#parec[
  Figure B.5: Blossoming to Find Control Points for a Segment of
  a Bézier Curve. The four blossoms in Equation (B.18) give the control
  points for the curve from $u\_m$ to $u\_a$. Blossoming provides an
  elegant method to compute the Bézier control points of the curve that
  represent a subset of the overall curve.
][
  图 B.5：通过
  #strong[blossoming] 计算 Bézier 曲线子段的控制点。 公式 (B.18) 中的四个
  blossom 给出了从 $u\_m$ 到 $u\_a$ 的曲线控制点。Blossoming
  提供了一种优雅的方式来计算曲线子段的 Bézier 控制点。
]

#parec[
  More generally, the four control points for the curve segment
  over the range from $u\_m$ to $u\_a$ are given by the blossoms:
][

  更一般地，曲线区间 $[u\_m, u\_a
  ]$ 的四个控制点由以下 blossom 给出：

]

```tex
a_i = (1 - u_0) p_i + u_0 p_{i+1}, \quad i \in \{0,1,2\}
b_j = (1 - u_1) a_j + u_1 a_{j+1}, \quad j \in \{0,1\}
b(u_0,u_1,u_2) = (1 - u_2) b_0 + u_2 b_1
```

```cpp
pstd::array<Point3f, 4>
CubicBezierControlPoints(pstd::span<const Point3f> cp, Float uMin,
                         Float uMax) {
    return { BlossomCubicBezier(cp, uMin, uMin, uMin),
             BlossomCubicBezier(cp, uMin, uMin, uMax),
             BlossomCubicBezier(cp, uMin, uMax, uMax),
             BlossomCubicBezier(cp, uMax, uMax, uMax) };
}
```

#parec[
  Bounding boxes of Curves can be efficiently computed by taking
  advantage of the convex hull property, a property of Bézier curves that
  says that they must lie within the convex hull of their control points.
  Therefore, the bounding box of the control points gives a conservative
  bound of the underlying curve. This bounding box is returned by the
  `BoundCubicBezier()` function.
][
  Bézier
  曲线的包围盒可以通过#strong[凸包性质];高效计算：曲线必然位于其控制点的凸包内。因此，控制点的包围盒就是曲线的保守边界。`BoundCubicBezier()`
  函数就返回这个包围盒。
]

```cpp
Bounds3f BoundCubicBezier(pstd::span<const Point3f> cp) {
    return Union(Bounds3f(cp[0], cp[1]), Bounds3f(cp[2], cp[3]));
}
```

#parec[
  A second variant of this function bounds a Bézier curve over a
  specified parametric range via a call to `CubicBezierControlPoints()`.

][
  该函数还有一个变体，可以通过调用 `CubicBezierControlPoints()`
  来计算 Bézier 曲线在给定参数区间上的包围盒。
]

```cpp
Bounds3f BoundCubicBezier(pstd::span<const Point3f> cp, Float uMin,
                          Float uMax) {
    if (uMin == 0 && uMax == 1)
        return BoundCubicBezier(cp);
    auto cpSeg = CubicBezierControlPoints(cp, uMin, uMax);
    return BoundCubicBezier(pstd::span<const Point3f>(cpSeg));
}
```

=== B.2.14 Pseudo-Random Number Generation
<b.2.14-pseudo-random-number-generation>
#parec[
  `pbrt` uses an implementation of the PCG pseudo-random
  number generator (O’Neill 2014) to generate pseudo-random numbers. This
  generator not only passes a variety of rigorous statistical tests of
  randomness, but its implementation is also extremely efficient.
][
  `pbrt` 使用了 PCG 伪随机数生成器（O’Neill
  2014）的实现来生成伪随机数。该生成器不仅通过了各种严格的随机性统计测试，而且其实现也极其高效。

]

#parec[
  We wrap its implementation in a small random number generator
  class, `RNG`, which can be found in the files (util/rng.h) and
  (util/rng.cpp). Random number generator implementation is an esoteric
  art; therefore, we will not include or discuss the implementation here
  but will describe the interfaces provided.
][

  我们将其实现封装在一个小型的随机数生成器类 `RNG` 中，该类定义在
  (util/rng.h) 和 (util/rng.cpp)
  文件中。随机数生成器的实现是一门非常深奥的技术，因此这里不会给出或讨论具体实现，而只介绍其提供的接口。

]

```cpp
class RNG {
  public:
    <<RNG Public Methods>>
  private:
    <<RNG Private Members>>
};
```

#parec[
  The `RNG` class provides three constructors. The first, which
  takes no arguments, sets the internal state to reasonable defaults. The
  others allow providing values that seed its state. The PCG random number
  generator actually allows the user to provide two 64-bit values to
  configure its operation: one chooses from one of $2^{63}$ different
  sequences of $2^{64}$ random numbers, while the second effectively
  selects a starting point within such a sequence. Many pseudo-random
  number generators only allow this second form of configuration, which
  alone is not as useful: having independent non-overlapping sequences of
  values rather than different starting points in a single sequence
  provides greater nonuniformity in the generated values.
][
  `RNG`
  类提供了三个构造函数。第一个不带参数，会将内部状态设置为合理的默认值。其他构造函数允许通过传入参数来设定种子。PCG
  随机数生成器实际上允许用户提供两个 64
  位值来配置其运行方式：其中一个用于从 $2^{63}$
  个不同的随机数序列（每个序列包含 $2^{64}$
  个随机数）中选择一个，另一个则选择该序列中的起始位置。许多伪随机数生成器只支持第二种配置方式（即仅设置起始位置），但这不如前者有用：生成相互独立、不重叠的随机序列要比在单一序列中选择不同起点更能保证生成值的非均匀性。

]

```cpp
RNG() : state(PCG32_DEFAULT_STATE), inc(PCG32_DEFAULT_STREAM) {}
RNG(uint64_t seqIndex, uint64_t offset) { SetSequence(seqIndex, offset); }
RNG(uint64_t seqIndex) { SetSequence(seqIndex); }
```

#parec[
  The RNG class also provides basic sequence handling:
][

  `RNG` 类还提供了基本的序列处理方法：
]

```cpp
void SetSequence(uint64_t sequenceIndex, uint64_t offset);
void SetSequence(uint64_t sequenceIndex) {
    SetSequence(sequenceIndex, MixBits(sequenceIndex));
}
```

#parec[
  The `RNG` class defines a template method `Uniform()` that
  returns a uniformly distributed random value of the specified type. A
  variety of specializations of this method are provided for basic
  arithmetic types.
][
  `RNG` 类定义了一个模板方法
  `Uniform()`，用于返回指定类型的均匀分布随机值。针对一些基础算术类型，该方法提供了专门化版本。

]

```cpp
template <typename T>
T Uniform();
```

#parec[
  The default implementation of `Uniform()` attempts to ensure
  that a useful error message is issued if it is invoked with an
  unsupported type.
][
  `Uniform()`
  的默认实现会在调用了不支持的类型时，尽量给出有用的错误提示。
]

```cpp
template <>
uint32_t RNG::Uniform<uint32_t>();
```

#parec[
  A specialization for `uint32_t` uses the PCG algorithm to
  generate a 32-bit value. We will not include its implementation here, as
  it would be impenetrable without an extensive discussion of the details
  of the pseudo-random number generation approach it implements.
][
  针对
  `uint32_t` 的专门化使用 PCG 算法生成一个 32
  位值。这里不会给出实现细节，因为若不对其伪随机数生成方法进行深入讨论，实现代码将难以理解。

]

```cpp
template <>
uint64_t RNG::Uniform<uint64_t>() {
    uint64_t v0 = Uniform<uint32_t>(), v1 = Uniform<uint32_t>();
    return (v0 << 32) | v1;
}
```

#parec[
  Generating a uniformly distributed signed 32-bit integer
  requires surprisingly tricky code. The issue is that in C++, it is
  undefined behavior to assign a value to a signed integer that is larger
  than it can represent. Undefined behavior does not just mean that the
  result is undefined, but that, in principle, no further guarantees are
  made about correct program execution after it occurs. Therefore, the
  following code is carefully written to avoid integer overflow. In
  practice, a good compiler can be expected to optimize away the extra
  work.
][
  生成均匀分布的有符号 32 位整数出乎意料地复杂。问题在于，在
  C++
  中，如果将超出可表示范围的值赋给有符号整数，会导致未定义行为。未定义行为不仅意味着结果不确定，而且原则上程序的正确执行也不再有任何保证。因此，下面的代码经过仔细设计以避免整数溢出。实际上，一个好的编译器会优化掉这些额外的处理。

]

```cpp
template <>
int32_t RNG::Uniform<int32_t>() {
    uint32_t v = Uniform<uint32_t>();
    if (v <= (uint32_t)std::numeric_limits<int32_t>::max())
        return int32_t(v);
    return int32_t(v - std::numeric_limits<int32_t>::min()) +
           std::numeric_limits<int32_t>::min();
}
```

#parec[
  A similar method returns pseudo-random `int64_t` values.
][

  类似的方法可用于返回伪随机的 `int64_t` 值。
]

#parec[
  It is often useful to generate a value that is uniformly
  distributed in the range $[0, b-1
  ]$ given a bound$b$. The first two
  versions of effectively computed Uniform\<int32\_t\>() % b to do so.
  That approach is subtly flawed—in the case that$b$ does not evenly
  divide $2^{32}$, there is higher probability of choosing any given
  value in the sub-range$[0, 2^{32}-1
  ]$.
][
  在很多情况下，我们希望生成一个范围在$[0, b-1
  ]$ 内均匀分布的值（给定边界$b$）。pbrt 的前两个版本通过计算 `Uniform<int32_t>() % b`
  来实现。但这种方法存在细微缺陷：如果$b$ 不能整除 $2^{32}$，则在区间$[0, 2^{32}-1
  ]$ 内的某些值被选中的概率会更高。
]

#parec[
  Therefore, the implementation here first computes the above
  remainder $2^{32}$ efficiently using 32-bit arithmetic and stores it
  in the variable `threshold`. Then, if the value returned by `Uniform()`
  is less than `threshold`, it is discarded and a new value is generated.
  The resulting distribution of values has a uniform distribution after
  the modulus operation, giving a uniformly distributed sample value.
][

  因此，这里的实现首先用 32 位算术高效地计算 $2^{32}$
  的余数，并将结果存储在变量 `threshold` 中。然后，如果 `Uniform()`
  返回的值小于
  `threshold`，就丢弃该值并重新生成一个新的值。这样在取模操作后，最终的值分布是均匀的，从而保证样本值均匀分布。

]

#parec[
  The tricky declaration of the return value ensures that this
  variant of Uniform() is only available for integral types.
][

  返回值声明方式经过特殊设计，以确保该版本的 `Uniform()`
  仅适用于整型类型。
]

```cpp
template <typename T>
typename std::enable_if_t<std::is_integral_v<T>, T> Uniform(T b) {
    T threshold = (~b + 1u) % b;
    while (true) {
        T r = Uniform<T>();
        if (r >= threshold)
            return r % b;
    }
}
```

#parec[
  A specialization of `Uniform()` for `float`s generates a
  pseudo-random floating-point number in the half-open interval $[0, 1)$ by
  multiplying a 32-bit random value by $2^{-32}$. Mathematically, this
  value is always less than one; it can be at most (2#super[32−1)/2];32.
  However, some values still round to 1 when computed using floating-point
  arithmetic. That case is handled here by clamping to the largest
  representable less than one. Doing so introduces a tiny bias, but not
  one that is meaningful for rendering applications.
][
  针对 `float` 的
  `Uniform()` 专门化通过将一个 32 位随机数乘以 $2^{-32}$
  来生成一个位于区间 $[0, 1)$ 的伪随机浮点数。从数学上看，这个值始终小于
  1，最大为
  (2#super[32−1)/2];32。然而，由于浮点运算的舍入，有些值仍可能被舍入到
  1。对此，代码会将结果钳制到小于 1 的最大可表示
  `float`。这样会引入极小的偏差，但对渲染应用来说无关紧要。
]

```cpp
template <>
float RNG::Uniform<float>() {
    return std::min<float>(OneMinusEpsilon, Uniform<uint32_t>() * 0x1p-32f);
}
```

#parec[
  An equivalent method for `double`s is provided but is not
  included here.
][
  针对 `double` 的等价方法也被提供，但这里未给出。
]

#parec[
  With this random number generator, it is possible to step
  forward or back to a different spot in the sequence without generating
  all the intermediate values. The `Advance()` method provides this
  functionality.
][

  使用该随机数生成器，可以前进或后退到序列中的不同位置，而无需生成所有中间值。`Advance()`
  方法提供了这种功能。
]

```cpp
void RNG::Advance(int64_t idelta);
```

```cpp
template <>
uint32_t RNG::Uniform<uint32_t>();
```

#parec[
  The above is a placeholder for the full specialization; see
  the section above for details.
][
  上面只是 `uint32_t`
  专门化的占位符；详情参见前文描述。
]

=== B.2.15 Interval Arithmetic
<b.2.15-interval-arithmetic>
#parec[
  Interval arithmetic is a technique that can be used to reason
  about the range of a function over some range of values and also to
  bound the round-off error introduced by a series of floating-point
  calculations. The `Interval` class provides functionality for both of
  these uses.
][

  区间算术是一种技术，可以用来分析函数在某一区间上的取值范围，同时还能对一系列浮点运算所引入的舍入误差进行约束。`Interval`
  类为这两种用途都提供了功能支持。
]

#parec[
  To understand the basic idea of interval arithmetic, consider,
  for example, the function $f(x) = 2x$. If we have an interval of
  values $[a, b]$, then we can see that, over the interval, the range
  of$f$ is the interval $[2a, 2b]$. In other words, $f([a,b])[2a, 2b
  ]$. More generally, all the basic operations of arithmetic
  have #emph[interval extensions] that describe how they operate on
  intervals of values. For example, given two intervals$[a,b
  ]$ and $[c,d]$,
][
  为了理解区间算术的基本思想，考虑函数 $f(x) = 2x$。如果我们有一个区间 $[a, b ]$，那么在这个区间上，函数$f$ 的取值范围就是区间 $[2a, 2b ]$。换句话说，$f($[a,b  ]) $[2a, 2b ]$。更一般地，所有基本算术运算都有其  #strong[区间扩展];，用于描述它们如何作用于区间。例如，给定两个区间  $[a,b ]$ 和 $[c,d
  ]$：
]

$[a , b] + [c , d] subset.eq [a + c , b + d] .$

#parec[
  Interval arithmetic has the important property that the
  intervals that it gives are conservative. For example, if $f($[a,b
  ])
  $[c,d
  ]$ and if $c \> 0$, then we know for sure that no value in
  $[a,b]$ causes f to be negative.
][
  区间算术的一个重要性质是它给出的区间是保守的。例如，如果$f($[a,b
  ])$[c,d]$ 且 $c \> 0$，那么我们可以确定，在$[a,b
  ]$
  内没有任何值会导致 $f$ 为负数。
]

#parec[
  When implemented in floating-point arithmetic, interval
  operations can be defined so that they result in intervals that bound
  the true value. Given a function that rounds a value that cannot exactly
  be represented as a floating-point value down to the next lower
  floating-point value and one that similarly rounds up, interval addition
  can be defined as
][

  当使用浮点数实现时，可以将区间运算定义为返回一个覆盖真实值的区间。假设我们有两个函数：一个将无法精确表示的浮点数向下舍入到下一个更小的浮点数，另一个将其向上舍入到下一个更大的浮点数，那么区间加法就可以定义为：

]

$[a , b] xor [c , d] subset.eq [a + c , b + d] .$

#parec[
  Performing a series of floating-point calculations in this
  manner is the basis of running error analysis, which was described in
  Section 6.8.1.
][

  以这种方式执行一系列浮点计算，就是所谓的运行时误差分析，其在第 6.8.1
  节中已经介绍过。
]

#parec[
  uses interval arithmetic to compute error bounds for ray
  intersections with quadrics and also uses the interval-based Point3i
  class to store computed ray intersection points on surfaces. The
  zero-finding method used to find the extrema of moving bounding boxes in
  AnimatedTransform::BoundPointMotion() (included in the online edition)
  is also based on interval arithmetic.
][

  使用区间算术来计算射线与二次曲面的交点误差范围，并使用基于区间的
  `Point3i` 类来存储计算得到的曲面交点。同时，在
  `AnimatedTransform::BoundPointMotion()`（仅在线版包含）中，用于寻找运动包围盒极值的零点求解方法也是基于区间算术的。

]

#parec[
  The `Interval` class provides interval arithmetic capabilities
  using operator overloading to make it fairly easy to switch existing
  regular floating-point computations over to be interval-based.
][

  `Interval`
  类通过运算符重载提供了区间算术功能，从而使得将现有的普通浮点计算切换为区间计算变得相对容易。

]

```cpp
class Interval {
  public:
    <<Interval Public Methods>>
  private:
    <<Interval Private Members>>
};
```

#parec[
  Before we go further with `Interval`, we will define some
  supporting utility functions for performing basic arithmetic with
  specified rounding. Recall that the default with floating-point
  arithmetic is that results are rounded to the nearest representable
  floating-point value, with ties being rounded to the nearest even value
  (i.e., with a zero-valued low bit in its significand). However, in order
  to compute conservative intervals like those in Equation (B.18), it is
  necessary to specify different rounding modes for different operations,
  rounding down when computing the value at the lower range of the
  interval and rounding up at the upper range.
][
  在进一步介绍
  `Interval`
  之前，我们需要先定义一些辅助函数，用于在指定舍入方式下执行基本算术运算。回忆一下：浮点数运算的默认规则是将结果舍入到最接近的可表示值，如果正好在两个值的中间，则舍入到最低有效位为零的那个值（即“偶数舍入”）。然而，为了计算像公式
  (B.18)
  那样的保守区间，有必要在不同操作中指定不同的舍入模式：在计算区间下界时向下舍入，在计算上界时向上舍入。

]

#parec[
  The IEEE floating-point standard requires capabilities to
  control the rounding mode, but unfortunately it is expensive to change
  it on modern CPUs. Doing so generally requires a flush of the execution
  pipeline, which may cost many tens of cycles. Therefore, `pbrt` provides
  utility functions that perform various arithmetic operations where the
  final value is then nudged up or down to the next representable float.
  This will lead to intervals that are slightly too large, sometimes
  nudging when it is not necessary, but for `pbrt`’s purposes it is
  preferable to paying the cost of changing the rounding mode.
][
  IEEE
  浮点标准确实支持控制舍入模式，但在现代 CPU
  上修改舍入模式代价很高。通常需要刷新执行流水线，可能会耗费数十个时钟周期。因此，`pbrt`
  提供了一些辅助函数，用于执行算术运算后再将结果轻微调整（向上或向下）到下一个可表示浮点数。这会导致区间稍微偏大，有时甚至在不必要时也会调整，但对于
  `pbrt` 的用途来说，这种方式比频繁修改舍入模式要高效得多。
]

#parec[
  Some GPUs provide intrinsic functions to perform these various
  operations directly, with the rounding mode specified as part of the
  instruction and with no performance cost. Alternative implementations of
  these functions, not included here, use those when they are available.

][
  有些 GPU
  提供了内建函数，可以直接执行这些运算，并且在指令中指定舍入模式而没有性能开销。在可用的情况下，另一种实现（未在此列出）会使用这些
  GPU 内建函数。
]

```cpp
Float AddRoundUp(Float a, Float b) {
    return NextFloatUp(a + b);
}
Float AddRoundDown(Float a, Float b) {
    return NextFloatDown(a + b);
}
```

#parec[
  Beyond addition, there are equivalent methods that are not
  included here for subtraction, multiplication, division, the square
  root, and FMA.
][
  除了加法之外，针对减法、乘法、除法、平方根和
  FMA（融合乘加）等运算，也有类似的方法，这里未列出。
]

#parec[
  An interval can be initialized with a single value or a pair of values
  that specify an interval with nonzero width.
][

  一个区间既可以用单一值初始化（表示宽度为零的区间），也可以用一对值初始化（表示一个非零宽度的区间）。

]


```cpp
explicit Interval(Float v) : low(v), high(v) {}
Interval(Float low, Float high)
    : low(std::min(low, high)), high(std::max(low, high)) {}
```

```cpp
Float low, high;
```

#parec[
  It can also be specified by a value and an error bound. Note
  that the implementation uses rounded arithmetic functions to ensure a
  conservative interval.
][

  区间也可以通过一个值和一个误差范围来指定。注意，这里的实现使用了带舍入的算术函数，以确保区间是保守的。

]

```cpp
static Interval FromValueAndError(Float v, Float err) {
    Interval i;
    if (err == 0)
        i.low = i.high = v;
    else {
        i.low = SubRoundDown(v, err);
        i.high = AddRoundUp(v, err);
    }
    return i;
}
```

#parec[
  A number of accessor methods provide information about the
  interval. An implementation of `operator[]`, not included here, allows
  indexing the two bounding values.
][

  一些访问方法可以提供区间的信息。另一个未列出的 `operator[]`
  实现允许对上下界进行索引访问。
]

```cpp
Float UpperBound() const { return high; }
Float LowerBound() const { return low; }
Float Midpoint() const { return (low + high) / 2; }
Float Width() const { return high - low; }
```

#parec[
  An interval can be converted to a `Float` approximation to it,
  but only through an explicit cast, which ensures that intervals are not
  accidentally reduced to `Float`s in the middle of a computation, thus
  causing an inaccurate final interval.
][
  区间可以显式转换为 `Float`
  类型的近似值，但这种转换必须是显式的，以避免在计算过程中意外将区间缩减为
  `Float`，从而导致最终区间不准确。
]

```cpp
explicit operator Float() const { return Midpoint(); }
```

#parec[
  `InRange()` method implementations check whether a given value
  is in the interval and whether two intervals overlap.
][
  `InRange()`
  方法用于检查某个值是否落在区间内，以及两个区间是否重叠。
]

```cpp
bool InRange(Float v, Interval i) {
    return v >= i.LowerBound() && v <= i.UpperBound();
}
bool InRange(Interval a, Interval b) {
    return a.LowerBound() <= b.UpperBound() &&
           a.UpperBound() >= b.LowerBound();
}
```

#parec[
  Negation of an interval is straightforward, as it does not
  require any rounding.
][
  对区间取负非常直接，不需要任何舍入操作。
]

```cpp
Interval operator-() const { return {-high, -low}; }
```

#parec[
  The addition operator just requires implementing Equation
  (B.18) with the appropriate rounding.
][
  加法运算符只需按照公式 (B.18)
  的定义来实现，并应用合适的舍入。
]

```cpp
Interval operator+(Interval i) const {
    return {AddRoundDown(low, i.low), AddRoundUp(high, i.high)};
}
```

#parec[
  The subtraction operator and the `+=` and `-=` operators
  follow the same pattern, so they are not included in the text.
][

  减法运算符以及 `+=`、`-=` 运算符遵循同样的模式，因此这里未给出。
]

#parec[
  Interval multiplication and division are slightly more
  involved: which of the `low` and `high` bounds of each of the two
  intervals is used to determine each of the bounds of the result depends
  on the signs of the values involved. Rather than incur the overhead of
  working out exactly which pairs to use, Interval’s implementation of the
  multiply operator computes all of them and then takes the minimum and
  maximum.
][

  区间乘法和除法稍微复杂一些：在计算结果区间的上下界时，究竟使用两个区间中的
  `low` 还是 `high`
  取决于它们的符号。为了避免计算具体组合的开销，`Interval`
  的乘法实现会直接计算所有可能的组合，然后取最小值和最大值作为结果的上下界。

]

```cpp
Interval operator*(Interval i) const {
    Float lp[4] = { MulRoundDown(low, i.low),  MulRoundDown(high, i.low),
                    MulRoundDown(low, i.high), MulRoundDown(high, i.high)};
    Float hp[4] = { MulRoundUp(low, i.low),  MulRoundUp(high, i.low),
                    MulRoundUp(low, i.high), MulRoundUp(high, i.high)};
    return {std::min({lp[0], lp[1], lp[2], lp[3]}),
            std::max({hp[0], hp[1], hp[2], hp[3]})};
}
```

#parec[
  The division operator follows a similar form, though it must
  check to see if the divisor interval spans zero. If so, an infinite
  interval must be returned.
][

  除法运算符实现方式类似，但必须检查除数区间是否跨越零。如果跨越零，则必须返回一个无限区间。

]

#parec[
  The interval `Sqr()` function is more than a shorthand; it is
  sometimes able to compute a tighter bound than would be found by
  multiplying an interval by itself using `operator*`. To see why,
  consider two independent intervals that both happen to have the range
  $[-2, 3]$. Multiplying them together results in the interval$[-6, 9
  ]$.
  However, if we are multiplying an interval by itself, we know that there
  is no way that squaring it would result in a negative value. Therefore,
  if an interval with the bounds$[-2, 3
  ]$is multiplied by itself, it is
  possible to return the tighter interval$[0, 9
  ]$ instead.
][
  `Sqr()`
  函数不仅仅是一个简写，它有时还能计算出比
  `operator*`（区间自乘）更紧的边界。原因如下：假设有两个相互独立但相同的区间
  $[-2, 3]$，它们相乘会得到区间$[-6,
    9
  ]$。但如果是对同一个区间求平方，我们知道结果不可能为负，因此 $[-2, 3
  ]$
  的平方实际上应该是更紧的区间$[0, 9
  ]$。
]

```cpp
Interval Sqr(Interval i) {
    Float alow = std::abs(i.LowerBound()), ahigh = std::abs(i.UpperBound());
    if (alow > ahigh)
        pstd::swap(alow, ahigh);
    if (InRange(0, i))
        return Interval(0, MulRoundUp(ahigh, ahigh));
    return Interval(MulRoundDown(alow, alow), MulRoundUp(ahigh, ahigh));
}
```

#parec[
  A variety of additional arithmetic operations are provided by
  the `Interval` class, including `Abs()`, `Min()`, `Max()`, `Sqrt()`,
  `Floor()`, `Ceil()`, `Quadratic()`, and assorted trigonometric
  functions. See the pbrt source code for their implementations.
][

  `Interval` 类还提供了多种额外的算术操作，包括
  `Abs()`、`Min()`、`Max()`、`Sqrt()`、`Floor()`、`Ceil()`、`Quadratic()`
  以及一些三角函数。具体实现可参见 pbrt 源码。
]

#parec[
  `pbrt` provides 3D vector and point classes that use
  `Interval` for the coordinate values. Here, the "fi" at the end of
  `Vector3fi` denotes "float interval." These classes are easily defined
  thanks to the templated definition of the `Vector3` and `Point3` classes
  and the underlying `Tuple3` class from Section 3.2.
][
  `pbrt`
  还提供了使用 `Interval` 作为坐标值的三维向量和点类。其中 `Vector3fi`
  名字末尾的 "fi" 表示 "float interval（浮点区间）"。由于第 3.2
  节中已经定义了模板化的 `Vector3`、`Point3` 以及底层的 `Tuple3`
  类，因此这些区间版本的类定义起来非常方便。
]

```cpp
class Vector3fi : public Vector3<Interval> {
  public:
    <<Vector3fi Public Methods>>
};
```

#parec[
  In addition to the usual constructors, `Vector3fi` can be
  initialized by specifying a base vector and a second one that gives
  error bounds for each component.
][
  除了常规构造函数外，`Vector3fi`
  还可以通过指定一个基向量和另一个表示各分量误差范围的向量来初始化。
]

```cpp
Vector3fi(Vector3f v, Vector3f e)
    : Vector3<Interval>(Interval::FromValueAndError(v.x, e.x),
                        Interval::FromValueAndError(v.y, e.y),
                        Interval::FromValueAndError(v.z, e.z)) {}
```

#parec[ Helper methods return error bounds for the vector components and
  indicate if the value stored has empty intervals.
][

  一些辅助方法用于返回向量分量的误差范围，并指示存储的值是否为精确值（即区间宽度是否为零）。

]

```cpp
Vector3f Error() const {
    return {x.Width() / 2, y.Width() / 2, z.Width() / 2};
}
bool IsExact() const {
    return x.Width() == 0 && y.Width() == 0 && z.Width() == 0;
}
```

#parec[
  The `Point3fi` class, not included here, similarly provides
  the capabilities of a `Point3` using intervals for its coordinate
  values. It, too, provides `Error()` and `IsExact()` methods.
][

  `Point3fi` 类（这里未列出）与 `Vector3fi` 类似，使用区间作为坐标值来实现
  `Point3` 的功能。它同样提供了 `Error()` 和 `IsExact()` 方法。
]
