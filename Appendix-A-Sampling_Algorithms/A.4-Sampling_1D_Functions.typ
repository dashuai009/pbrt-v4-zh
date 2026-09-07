#import "../template.typ": parec, ez_caption, translator

#import "supplements/source-math.typ": source-math

== #ez_caption[Sampling 1D Functions][一维函数采样]

<sampling-1d-functions>

#parec[
Throughout the implementation of `pbrt` we have found it useful to draw samples from a wide variety of functions. This section therefore presents the implementations of additional functions for sampling in 1D to augment the ones in Section #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#sec:inversion-method-continuous")[2.3.2]. All are based on the inversion method and most introduce useful tricks for sampling that are helpful to know when deriving new sampling algorithms.
][
在 `pbrt` 的实现中，我们发现从多种函数的分布中采样都很有用。因此，本节补充第 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#sec:inversion-method-continuous")[2.3.2] 节的一维采样函数。它们都基于逆变换法，其中大多数还展示了实用的采样技巧，有助于推导新的采样算法。
]

#block(breakable: false)[
=== #ez_caption[Sampling the Tent Function][帐篷函数采样] <sampling-tent-function>

#parec[
`SampleTent()` uses #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleLinear")[`SampleLinear()`] to sample the “tent” function with radius $r$,
][
`SampleTent()` 利用 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleLinear")[`SampleLinear()`] 对半径为 $r$ 的“帐篷”函数采样：
]

]

$ f(x)=cases(r-abs(x) & quad abs(x)<r,0 & quad #ez_caption[otherwise.][其他情况。]) $

#parec[
The sampling algorithm first uses the provided uniform sample `u` with the #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] function to choose whether to sample a value greater than or less than zero, with each possibility having equal probability. Note the use of `SampleDiscrete()`’s capability of returning a new uniform random sample here, overwriting `u`’s original value. In turn, one of the two linear functions is sampled, with the result scaled so that the interval #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-db6f02dee83791fc.svg",6.233,2.843,0.838,"left-bracket negative r comma r right-bracket") is sampled.
][
采样算法首先把给定的均匀样本 `u` 传给 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`]，以相等概率选择在零的哪一侧采样。注意，这里利用了 `SampleDiscrete()` 返回新的均匀随机样本的能力，用它覆盖原来的 `u`。随后对相应的线性函数采样，并缩放结果，使样本落在区间 $[-r,r]$ 中。
]

#parec[
One thing to note in this function is that the cases and expressions have been carefully crafted so that `u==0` maps to `-r` and then as `u` increases, the sampled value increases monotonically until `u==1` maps to `r`, without any jumps or reversals. This property is helpful for preserving well-distributed sample points (e.g., if they have low discrepancy).
][
这里的分支和表达式经过仔细安排：`u==0` 映射到 `-r`；随着 `u` 增大，采样值单调增大，直到 `u==1` 映射到 `r`，中间没有跳变或反向变化。这一性质有助于保持样本点的良好分布，例如低差异性。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-12")[#raw("<<Sampling Inline Functions>>+=")] #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragment-SamplingInlineFunctions-11")[↑] #link(<fragment-SamplingInlineFunctions-13>)[↓]] <fragment-SamplingInlineFunctions-12>

#block(breakable: false)[
```cpp
Float SampleTent(Float u, Float r) {
    if (SampleDiscrete({0.5f, 0.5f}, u, nullptr, &u) == 0)
        return -r + r * SampleLinear(u, 0, 1);
    else
        return r * SampleLinear(u, 1, 0);
}
```
]

#metadata(none) <SampleTent>

#parec[
The tent function is easily normalized to find its PDF.
][
帐篷函数很容易归一化，得到其 PDF。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-13")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-12>)[↑] #link(<fragment-SamplingInlineFunctions-14>)[↓]] <fragment-SamplingInlineFunctions-13>

#block(breakable: false)[
```cpp
Float TentPDF(Float x, Float r) {
    if (std::abs(x) >= r)
        return 0;
    return 1 / r - std::abs(x) / Sqr(r);
}
```
]

#metadata(none) <TentPDF>

#parec[
The inversion function is based on #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#InvertLinearSample")[`InvertLinearSample()`].
][
逆采样函数基于 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#InvertLinearSample")[`InvertLinearSample()`]。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-14")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-13>)[↑] #link(<fragment-SamplingInlineFunctions-15>)[↓]] <fragment-SamplingInlineFunctions-14>

#block(breakable: false)[
```cpp
inline Float InvertTentSample(Float x, Float r) {
    if (x <= 0)
        return (1 - InvertLinearSample(-x / r, 1, 0)) / 2;
    else
        return 0.5f + InvertLinearSample(x / r, 1, 0) / 2;
}
```
]

#metadata(none) <InvertTentSample>

#block(breakable: false)[
=== #ez_caption[Sampling Exponential Distributions][指数分布采样] <exponential-sampling>

#parec[
Sampling the transmittance function when rendering images with participating media often requires samples from a distribution #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-2e93da28d78777f2.svg",11.833,2.843,0.838,"p left-parenthesis x right-parenthesis proportional-to normal e Superscript minus a x"). As before, the first step is to find a constant $c$ that normalizes this distribution so that it integrates to one. In this case, we will assume for now that the range of values $x$ we’d like the generated samples to cover is $lr([0,infinity))$ rather than $[0,1]$, so
][
渲染含参与介质的图像时，对透射率函数采样往往需要从 $p(x) prop exp(-a x)$ 这样的分布中生成样本。与前面一样，第一步是求出使分布积分为 1 的归一化常数 $c$。这里暂且假设，希望生成的 $x$ 样本覆盖的范围是 $lr([0,infinity))$，而非 $[0,1]$，因此有
]

]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-93945a349ad9ac58.svg",37.387,5.843,2.338,"c integral Subscript 0 Superscript normal infinity Baseline normal e Superscript minus a x Baseline normal d x equals minus StartFraction c Over a EndFraction normal e Superscript minus a x Baseline vertical-bar Subscript 0 Superscript normal infinity Baseline equals StartFraction c Over a EndFraction equals 1 period", display: true)]

#parec[
Thus, #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-3e8648443c8271bb.svg",5.335,1.676,0.338,"c equals a") and our PDF is #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-362fa7d993f0c33a.svg",13.063,2.843,0.838,"p left-parenthesis x right-parenthesis equals a normal e Superscript minus a x").
][
于是 $c=a$，PDF 为 $p(x)=a exp(-a x)$。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-15")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-14>)[↑] #link(<fragment-SamplingInlineFunctions-16>)[↓]] <fragment-SamplingInlineFunctions-15>

#block(breakable: false)[
```cpp
Float ExponentialPDF(Float x, Float a) {
    return a * std::exp(-a * x);
}
```
]

#metadata(none) <ExponentialPDF>

#parec[
We can integrate to find $P(x)$:
][
积分得到 $P(x)$：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-fa584913b50f5c10.svg",34.3,5.843,2.338,"upper P left-parenthesis x right-parenthesis equals integral Subscript 0 Superscript x Baseline a normal e Superscript minus a x Super Superscript prime Superscript Baseline normal d x Superscript prime Baseline equals 1 minus normal e Superscript minus a x Baseline comma", display: true)] <exponential-cdf>

#parec[
which gives a function that is easy to invert:
][
这个函数很容易求逆：
]

$ P^(-1)(x)=-ln(1-x)/a . $

#parec[
Therefore, we can draw samples using
][
因此，可以按下式生成样本：
]

$ X=-ln(1-xi)/a . $ <exponential-sampling-distance>

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-16")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-15>)[↑] #link(<fragment-SamplingInlineFunctions-17>)[↓]] <fragment-SamplingInlineFunctions-16>

#block(breakable: false)[
```cpp
Float SampleExponential(Float u, Float a) {
    return -std::log(1 - u) / a;
}
```
]

#metadata(none) <SampleExponential>

#parec[
It may be tempting to simplify the log term from #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-d85bc615c321a492.svg",8.789,2.843,0.838,"ln left-parenthesis 1 minus xi Subscript Baseline right-parenthesis") to #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-2d186eb439d3211c.svg",3.363,2.509,0.671,"ln xi Subscript"), under the theory that because #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-238f2b9665762b0e.svg",8.788,2.843,0.838,"xi Subscript Baseline element-of left-bracket 0 comma 1 right-parenthesis"), these are effectively the same and a subtraction can thus be saved. The problem with this idea is that $xi$ may have the value 0 but never has the value 1. With the simplification, it is possible that we would try to take the logarithm of 0, which is undefined; this danger is avoided with the first formulation.#footnote[This is a subtlety that the authors did not appreciate in the first two editions of the book.] While a $xi$ value of 0 may seem very unlikely, it is possible, especially in the world of floating-point arithmetic and not the real numbers. Sample generation algorithms based on the radical inverse function (Section #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Halton_Sampler.html#sec:hammersley-halton")[8.6.1]) are particularly prone to generating the value 0.
][
也许有人想把对数项 $ln(1-xi)$ 简化为 $ln xi$，认为既然 $xi in lr([0,1))$，两者实际上等价，还能省去一次减法。问题在于，$xi$ 可以等于 0，却不会等于 1。这样简化后，就可能对 0 取对数，而该值未定义；原来的写法避免了这一风险。#footnote[本书前两版中，作者也没有意识到这一细节。] 虽然 $xi$ 恰为 0 似乎很罕见，但它确实可能出现，尤其是在浮点运算而非实数运算中。基于基数反转函数的样本生成算法（第 #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Halton_Sampler.html#sec:hammersley-halton")[8.6.1] 节）尤其容易生成 0。
]

#parec[
As before, the inverse sampling function is given by evaluating $P(x)$.
][
与前面一样，逆采样函数只需计算 $P(x)$。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-17")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-16>)[↑] #link(<fragment-SamplingInlineFunctions-18>)[↓]] <fragment-SamplingInlineFunctions-17>

#block(breakable: false)[
```cpp
Float InvertExponentialSample(Float x, Float a) {
    return 1 - std::exp(-a * x);
}
```
]

#metadata(none) <InvertExponentialSample>

#block(breakable: false)[
=== #ez_caption[Sampling the Gaussian][高斯函数采样] <sampling-gaussian>

#parec[
The Gaussian function is parameterized by its center $mu$ and standard deviation $sigma$:
][
高斯函数由中心 $mu$ 和标准差 $sigma$ 参数化：
]

]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-838938536d234a10.svg",23.459,7.176,2.838,"g left-parenthesis x right-parenthesis equals StartFraction 1 Over StartRoot 2 pi sigma squared EndRoot EndFraction normal e Superscript minus StartFraction left-parenthesis x minus mu right-parenthesis squared Over 2 sigma squared EndFraction Baseline period", display: true)] <gaussian-function>

#parec[
The probability distribution it defines is called the _normal distribution_. The Gaussian is already normalized, so the PDF follows directly.
][
它定义的概率分布称为_正态分布_。高斯函数已经归一化，因此可以直接得到 PDF。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-18")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-17>)[↑] #link(<fragment-SamplingInlineFunctions-19>)[↓]] <fragment-SamplingInlineFunctions-18>

#block(breakable: false)[
```cpp
Float NormalPDF(Float x, Float mu = 0, Float sigma = 1) {
    return Gaussian(x, mu, sigma);
}
```
]

#metadata(none) <NormalPDF>

#parec[
However, the Gaussian’s CDF cannot be expressed with elementary functions. It is
][
不过，高斯函数的 CDF 无法用初等函数表示，其形式为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-e5b815216bb34388.svg",31.216,6.509,2.838,"upper P left-parenthesis x right-parenthesis equals one-half left-parenthesis 1 plus e r f left-parenthesis StartFraction x minus mu Over sigma StartRoot italic 2 EndRoot EndFraction right-parenthesis right-parenthesis comma", display: true)]

#parec[
where #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-aed5cd1a382ac952.svg",5.693,2.843,0.838,"e r f italic left-parenthesis x italic right-parenthesis") is the error function. If we equate #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-3c3ee2b3799a6b5a.svg",9.027,2.843,0.838,"xi equals upper P left-parenthesis x right-parenthesis") and solve, we find that:
][
其中 $op("erf")(x)$ 是误差函数。令 $xi=P(x)$ 并求解，得到
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-4b1e3066bdf53785.svg",27.13,3.176,0.838,"x equals mu plus StartRoot 2 EndRoot sigma e r f Superscript negative italic 1 Baseline italic left-parenthesis italic 2 xi minus italic 1 italic right-parenthesis italic period", display: true)]

#parec[
The inverse error function #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-930338120b2dba71.svg",4.989,2.676,0.338,"e r f Superscript negative italic 1") can be well approximated with a polynomial, which in turn gives a sampling technique.
][
逆误差函数 $op("erf")^(-1)$ 可以用多项式很好地近似，从而得到一种采样方法。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-19")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-18>)[↑] #link(<fragment-SamplingInlineFunctions-20>)[↓]] <fragment-SamplingInlineFunctions-19>

#block(breakable: false)[
```cpp
Float SampleNormal(Float u, Float mu = 0, Float sigma = 1) {
    return mu + Sqrt2 * sigma * ErfInv(2 * u - 1);
}
```
]

#metadata(none) <SampleNormal>

#parec[
`InvertNormalSample()`, not included here, evaluates $P(x)$.
][
这里未列出的 `InvertNormalSample()` 通过计算 $P(x)$ 实现。
]

#metadata(none) <InvertNormalSample>

#parec[
The _Box-Muller transform_ is an alternative sampling technique for the normal distribution; it takes a pair of random samples and returns a pair of normally distributed samples. It makes use of the fact that if two normally distributed variables are considered as a 2D point and transformed to 2D polar coordinates $(r,theta)$, then #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-363c4455b0629c4b.svg",12.958,2.843,0.671,"r squared equals minus 2 ln xi 1") and #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-62f159dafb0b79e2.svg",8.749,2.509,0.671,"theta equals 2 pi xi 2").
][
_Box–Muller 变换_是另一种正态分布采样方法：输入一对随机样本，返回一对正态分布样本。它利用了如下事实：将两个正态分布变量视为二维点，并转换为二维极坐标 $(r,theta)$ 后，有 $r^2=-2 ln xi_1$ 和 $theta=2 pi xi_2$。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-20")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-19>)[↑] #link(<fragment-SamplingInlineFunctions-21>)[↓]] <fragment-SamplingInlineFunctions-20>

#block(breakable: false)[
```cpp
Point2f SampleTwoNormal(Point2f u, Float mu = 0, Float sigma = 1) {
    Float r2 = -2 * std::log(1 - u[0]);
    return {mu + sigma * std::sqrt(r2 * std::cos(2 * Pi * u[1])),
            mu + sigma * std::sqrt(r2 * std::sin(2 * Pi * u[1]))};
}
```
]

#metadata(none) <SampleTwoNormal>

#translator([固定原书此处代码将 `cos`、`sin` 因子置于 `std::sqrt` 内，与前文极坐标关系不一致，并可能对负数开平方。此处保留原代码，不能据此视为正确的 Box–Muller 实现；需要上游勘误。], en: [The fixed source places the cosine and sine factors inside `std::sqrt`, contradicting the preceding polar-coordinate relation and potentially taking the square root of a negative number. The code is retained as printed; it should not be treated as a verified Box–Muller implementation.])

#block(breakable: false)[
=== #ez_caption[Sampling the Logistic Function][logistic 函数采样] <sample-logistic-fun>

#parec[
The _logistic function_ is shaped similarly to the Gaussian, but can be sampled directly. It is therefore useful in cases where a distribution similar to the Gaussian is useful but an exact Gaussian is not needed. (It is used, for example, in the implementation of `pbrt`’s scattering model for hair.) The logistic function centered at the origin is
][
_logistic 函数_的形状与高斯函数相似，却可以直接采样。因此，当需要类似高斯的分布而不要求严格为高斯时，它很有用。例如，`pbrt` 的毛发散射模型就使用了它。以原点为中心的 logistic 函数为
]

]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-9940d8841b2f0b7c.svg",22.952,6.676,2.838,"f left-parenthesis x right-parenthesis equals StartFraction normal e Superscript minus StartAbsoluteValue x EndAbsoluteValue slash s Baseline Over s left-parenthesis 1 plus normal e Superscript minus StartAbsoluteValue x EndAbsoluteValue slash s Baseline right-parenthesis squared EndFraction comma", display: true)] <logistic-function>

#parec[
where $s$ is a parameter that controls its rate of falloff similar to $sigma$ in the Gaussian. @fig:plot-logistic-gaussian shows a plot of the logistic and Gaussian functions with parameter values that lead to curves with similar shapes.
][
其中，参数 $s$ 控制衰减速度，作用类似于高斯函数中的 $sigma$。@fig:plot-logistic-gaussian 展示了两类函数；图中选择的参数使它们的曲线形状接近。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf04.svg", width: 90%), caption: [#ez_caption[Plots of the logistic function, @eqt:logistic-function with #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-09dc67578797c7cd.svg",9.486,2.176,0.338,"s equals 0.603"), and the Gaussian, @eqt:gaussian-function , with #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-1643234b39a78caa.svg",5.588,2.176,0.338,"sigma equals 1"). ($s$ was found via a least-squares fit to minimize error over the domain of the plot.)][logistic 函数（@eqt:logistic-function ，$s=0.603$）与高斯函数（@eqt:gaussian-function ，$sigma=1$）的曲线。参数 $s$ 通过最小二乘拟合选取，使图示定义域内的误差最小。]]) <plot-logistic-gaussian>

#parec[
The logistic function is normalized by design, so the PDF evaluation function follows directly.
][
logistic 函数本身已经归一化，因此可以直接实现 PDF 求值函数。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-21")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-20>)[↑] #link(<fragment-SamplingInlineFunctions-22>)[↓]] <fragment-SamplingInlineFunctions-21>

#block(breakable: false)[
```cpp
Float LogisticPDF(Float x, Float s) {
    x = std::abs(x);
    return std::exp(-x / s) / (s * Sqr(1 + std::exp(-x / s)));
}
```
]

#metadata(none) <LogisticPDF>

#parec[
Its CDF,
][
其 CDF 为
]

$ P(x)=1/(1+exp(-x/s)) , $

#parec[
is easily found, and can be inverted to derive a sampling routine. The result is implemented in #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#SampleLogistic")[`SampleLogistic()`].
][
这个 CDF 很容易求得，也容易求逆，从而得到采样方法。结果由 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#SampleLogistic")[`SampleLogistic()`] 实现。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-22")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-21>)[↑] #link(<fragment-SamplingInlineFunctions-23>)[↓]] <fragment-SamplingInlineFunctions-22>

#block(breakable: false)[
```cpp
Float SampleLogistic(Float u, Float s) {
    return -s * std::log(1 / u - 1);
}
```
]

#metadata(none) <SampleLogistic>

#parec[
As usual in 1D, the sample inversion method is performed by evaluating the CDF.
][
与通常的一维情况一样，逆采样通过计算 CDF 实现。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-23")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-22>)[↑] #link(<fragment-SamplingInlineFunctions-24>)[↓]] <fragment-SamplingInlineFunctions-23>

#block(breakable: false)[
```cpp
Float InvertLogisticSample(Float x, Float s) {
    return 1 / (1 + std::exp(-x / s));
}
```
]

#metadata(none) <InvertLogisticSample>

#block(breakable: false)[
=== #ez_caption[Sampling a Function over an Interval][区间内的函数采样] <sampling-function-over-interval>

#parec[
It is sometimes useful to sample from a function’s distribution over a specified interval $[a,b]$. It turns out that this is easy to do if we are able to evaluate the function’s CDF. We will use the logistic function as an example here, though the underlying technique applies more generally.
][
有时需要只在指定区间 $[a,b]$ 内按函数的分布采样。只要能够计算该函数的 CDF，这件事就很容易。这里以 logistic 函数为例，不过方法适用于更一般的情形。
]

]

#parec[
First consider the task of finding the PDF of the function limited to the interval, #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-718102b808e3495b.svg",7.561,3.176,1.171,"p Subscript left-bracket a comma b right-bracket Baseline left-parenthesis x right-parenthesis"): we need to renormalize it. Doing so requires being able to integrate $p(x)$, which is otherwise known as finding its CDF:
][
首先考虑如何求限制到该区间后的 PDF，即 $p_([a,b])(x)$：必须重新归一化它。这需要对 $p(x)$ 积分，也就是求出其 CDF：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-ebfe796475438258.svg",25.012,14.176,6.505,"StartLayout 1st Row 1st Column p Subscript left-bracket a comma b right-bracket Baseline left-parenthesis x right-parenthesis 2nd Column equals StartFraction p left-parenthesis x right-parenthesis Over integral Subscript a Superscript b Baseline p left-parenthesis x right-parenthesis normal d x EndFraction 2nd Row 1st Column Blank 2nd Column equals StartFraction p left-parenthesis x right-parenthesis Over upper P left-parenthesis b right-parenthesis minus upper P left-parenthesis a right-parenthesis EndFraction period EndLayout", display: true)] <function-interval-pdf>

#parec[
The function to evaluate the PDF follows directly. Here we have wrapped a call to `InvertLogisticSample()` in a simple lambda expression in order to make the relationship to @eqt:function-interval-pdf more clear.
][
由此可以直接实现 PDF 求值函数。这里用一个简单的 lambda 表达式封装 `InvertLogisticSample()` 调用，以便更清楚地体现代码与 @eqt:function-interval-pdf 的对应关系。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-24")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-23>)[↑] #link(<fragment-SamplingInlineFunctions-25>)[↓]] <fragment-SamplingInlineFunctions-24>

#block(breakable: false)[
```cpp
Float TrimmedLogisticPDF(Float x, Float s, Float a, Float b) {
    if (x < a || x > b) return 0;
    auto P = [&](Float x) { return InvertLogisticSample(x, s); };
    return Logistic(x, s) / (P(b) - P(a));
}
```
]

#metadata(none) <TrimmedLogisticPDF>

#translator([固定原书这里调用 `Logistic(x, s)`，而前面展示的 PDF 函数名为 `LogisticPDF`。保留原书标识符，此名称对应关系待上游确认。], en: [The fixed source calls `Logistic(x, s)`, whereas the PDF function shown earlier is named `LogisticPDF`. The original identifier is retained; this naming discrepancy requires upstream clarification.])

#parec[
Next, consider sampling using the inversion method. Following the definition of #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-718102b808e3495b.svg",7.561,3.176,1.171,"p Subscript left-bracket a comma b right-bracket Baseline left-parenthesis x right-parenthesis"), we can see that the CDF associated with #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-718102b808e3495b.svg",7.561,3.176,1.171,"p Subscript left-bracket a comma b right-bracket Baseline left-parenthesis x right-parenthesis") is
][
接着考虑用逆变换法采样。根据 $p_([a,b])(x)$ 的定义，相应的 CDF 为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-a8695574361d9a48.svg",44.322,6.509,2.671,"upper P Subscript left-bracket a comma b right-bracket Baseline left-parenthesis x right-parenthesis equals integral Subscript a Superscript x Baseline p Subscript left-bracket a comma b right-bracket Baseline left-parenthesis x Superscript prime Baseline right-parenthesis normal d x Superscript prime Baseline equals StartFraction upper P left-parenthesis x right-parenthesis minus upper P left-parenthesis a right-parenthesis Over upper P left-parenthesis b right-parenthesis minus upper P left-parenthesis a right-parenthesis EndFraction period", display: true)] <trimmed-logistic-cdf>

#parec[
Setting #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-bac4efdaefc2e353.svg",12.594,3.176,1.171,"xi equals upper P Subscript left-bracket a comma b right-bracket Baseline left-parenthesis upper X right-parenthesis") and solving for $X$, we have
][
令 $xi=P_([a,b])(X)$ 并对 $X$ 求解，得到
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-695b74811b8aebd8.svg",35.139,3.176,0.838,"upper X equals upper P Superscript negative 1 Baseline left-parenthesis xi left-parenthesis upper P left-parenthesis b right-parenthesis minus upper P left-parenthesis a right-parenthesis right-parenthesis plus upper P left-parenthesis a right-parenthesis right-parenthesis period", display: true)]

#parec[
Thus, if we compute a new $xi$ value (that, in a slight abuse of notation, is not between 0 and 1) by using $xi$ to linearly interpolate between $P(a)$ and $P(b)$ and then apply the original sampling algorithm, we will generate a sample from the distribution over the interval $[a,b]$.#footnote[Editorial note: The source’s parenthetical range claim is incorrect. The CDF endpoints and their interpolation remain within $[0,1]$; the covered subinterval and sampling distribution change.]
][
因此，先用 $xi$ 在 $P(a)$ 与 $P(b)$ 之间作线性插值，求出新的 $xi$ 值（原文沿用这一符号，并称其“不在 0 与 1 之间”），再应用原来的采样算法，就能在区间 $[a,b]$ 上按该分布生成样本。#footnote[校注：原文括号中的范围说法有误。CDF 值 $P(a)$、$P(b)$ 及其线性插值仍在 $[0,1]$ 内；改变的是样本在这一范围内的分布及覆盖的子区间。]
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-25")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-24>)[↑] #link(<fragment-SamplingInlineFunctions-26>)[↓]] <fragment-SamplingInlineFunctions-25>

#block(breakable: false)[
```cpp
Float SampleTrimmedLogistic(Float u, Float s, Float a, Float b) {
    auto P = [&](Float x) { return InvertLogisticSample(x, s); };
    u = Lerp(u, P(a), P(b));
    Float x = SampleLogistic(u, s);
    return Clamp(x, a, b);
}
```
]

#metadata(none) <SampleTrimmedLogistic>

#parec[
The inversion routine follows directly from @eqt:trimmed-logistic-cdf .
][
逆采样函数可直接由 @eqt:trimmed-logistic-cdf 得到。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-26")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-25>)[↑] #link(<fragment-SamplingInlineFunctions-27>)[↓]] <fragment-SamplingInlineFunctions-26>

#block(breakable: false)[
```cpp
Float InvertTrimmedLogisticSample(Float x, Float s, Float a, Float b) {
    auto P = [&](Float x) { return InvertLogisticSample(x, s); };
    return (P(x) - P(a)) / (P(b) - P(a));
}
```
]

#metadata(none) <InvertTrimmedLogisticSample>

#block(breakable: false)[
=== #ez_caption[Sampling Non-Invertible CDFs][无法解析求逆的 CDF 采样] <SamplingNon-InvertibleCDFs>

#parec[
It was not possible to invert the normal distribution’s CDF to derive a sampling technique, so there we used a polynomial approximation of the inverse CDF. In cases like that, another option is to use numerical root–finding techniques. We will demonstrate that approach using the _smoothstep_ function as an example.
][
前面无法通过对正态分布的 CDF 求逆来推导采样方法，因而使用了逆 CDF 的多项式近似。在这类情况下，还可以采用数值求根方法。下面以 _smoothstep_ 函数为例说明这一方法。
]

]

#parec[
Smoothstep defines an s-shaped curve based on a third-degree polynomial that goes from zero to one starting at a point $a$ and ending at a point $b$. It is zero for values $x<a$ and one for values $x>b$. Otherwise, it is defined as
][
smoothstep 用三次多项式定义一条 S 形曲线，从点 $a$ 处的 0 过渡到点 $b$ 处的 1。在 $x<a$ 时函数为 0，在 $x>b$ 时为 1；其余位置定义为
]

$ f(x)=3t^2-2t^3 , $

#parec[
with $t=(x-a)/(b-a)$. In `pbrt` the smoothstep function is used to define the falloff at the edges of a spotlight.
][
其中 $t=(x-a)/(b-a)$。`pbrt` 用 smoothstep 函数描述聚光灯边缘的衰减。
]

#parec[
We will consider the task of sampling the function within the range $[a,b]$. First, it is easy to show that the PDF is
][
下面考虑在 $[a,b]$ 内对该函数采样。首先，容易证明其 PDF 为
]

$ p(x)=2f(x)/(b-a) . $

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-27")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-26>)[↑] #link(<fragment-SamplingInlineFunctions-28>)[↓]] <fragment-SamplingInlineFunctions-27>

#block(breakable: false)[
```cpp
Float SmoothStepPDF(Float x, Float a, Float b) {
    if (x < a || x > b) return 0;
    return (2 / (b - a)) * SmoothStep(x, a, b);
}
```
]

#metadata(none) <SmoothStepPDF>

#parec[
Integrating the PDF is also easy; the resulting CDF is
][
对 PDF 积分也很容易，得到的 CDF 为
]

$ P(x)=(2t^3-t^4)/(b-a) . $

#translator([固定原书上式含分母 $b-a$，但由前一 PDF 积分得到的归一化 CDF 应为 $2t^3-t^4$；下方 `SampleSmoothStep()` 的代码也使用后者。这里保留原式并标出矛盾，不能把它当作已确认的数学结论。], en: [The fixed source includes a denominator $b-a$ above. Integrating the preceding PDF gives the normalized CDF $2t^3-t^4$, which is also used by `SampleSmoothStep()` below. The printed formula is retained with this discrepancy explicitly noted.])

#parec[
The challenge in sampling $f$ is evident: doing so requires solving a fourth-degree polynomial.
][
采样 $f$ 的困难已经显现：这需要求解一个四次多项式方程。
]

#parec[
The sampling task can be expressed as a zero-finding problem: to apply the inversion method, we would like to solve #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-4ff72854e8c5b332.svg",9.675,2.843,0.838,"xi equals upper P left-parenthesis upper X right-parenthesis") for $X$. Doing so is equivalent to finding the value $X$ such that #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-3ab817d409a3ab0e.svg",13.678,2.843,0.838,"upper P left-parenthesis upper X right-parenthesis minus xi equals 0"). The #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#SampleSmoothStep")[`SampleSmoothStep()`] function below uses a Newton-bisection solver that is defined in Section #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:math-finding-zeros")[B.2.10] to do this. That function takes a callback that returns the value of the function and its derivative at a given point; these values are easily computed given the equations derived so far.
][
采样任务可以表述为求零点问题：逆变换法要求对 $X$ 求解 $xi=P(X)$，这等价于寻找满足 $P(X)-xi=0$ 的 $X$。下面的 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#SampleSmoothStep")[`SampleSmoothStep()`] 使用第 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:math-finding-zeros")[B.2.10] 节定义的牛顿法与二分法结合的求解器。该求解器接收一个回调，返回给定点的函数值及导数；利用已经推导出的公式，可以方便地计算这两个量。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-28")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-27>)[↑] #link(<fragment-SamplingInlineFunctions-29>)[↓]] <fragment-SamplingInlineFunctions-28>

#block(breakable: false)[
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
]

#metadata(none) <SampleSmoothStep>

#parec[
Sample inversion can be performed following the same approach as was used earlier in @eqt:trimmed-logistic-cdf for the logistic over an interval.
][
逆采样可以沿用先前对区间内 logistic 分布所采用的方法，见 @eqt:trimmed-logistic-cdf 。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-29")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-28>)[↑] #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-30")[↓]] <fragment-SamplingInlineFunctions-29>

#block(breakable: false)[
```cpp
Float InvertSmoothStepSample(Float x, Float a, Float b) {
    Float t = (x - a) / (b - a);
    auto P = [&](Float x) { return 2 * Pow<3>(t) - Pow<4>(t); };
    return (P(x) - P(a)) / (P(b) - P(a));
}
```
]

#metadata(none) <InvertSmoothStepSample>

#translator([固定原书的 lambda 捕获外部已计算的 `t`，没有使用传入的参数 `x`，因此 `P(x)`、`P(a)`、`P(b)` 返回相同值，最后的表达式成为零除以零。保留原代码并提交上游疑点，不擅自改写算法。], en: [The fixed source lambda captures the previously computed `t` without using its parameter `x`. Hence `P(x)`, `P(a)`, and `P(b)` return the same value and the final expression becomes zero divided by zero. The source code is preserved pending upstream correction.])

#block(breakable: false)[
=== #ez_caption[Sampling Piecewise-Constant 1D Functions][一维分段常数函数采样] <piecewise-constant-1d>

#parec[
The inversion method can also be applied to tabularized functions; in this section, we will consider piecewise-constant functions defined over $[0,1]$. The algorithms described here will provide the foundation for sampling piecewise-constant 2D functions, used in multiple parts of `pbrt` to sample from distributions defined by images.
][
逆变换法也可用于以表格存储的函数。本节考虑定义在 $[0,1]$ 上的分段常数函数。这里的算法是一维基础，后面将据此对二维分段常数函数采样；`pbrt` 的多个部分用后者对图像定义的分布采样。
]

]

#parec[
Assume that the 1D function’s domain is split into $n$ equal-sized pieces of size #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-22715a7dbbd90792.svg",8.754,2.843,0.838,"normal upper Delta equals 1 slash n"). These regions start and end at points #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-065ba315005b2ded.svg",7.966,2.509,0.671,"x Subscript i Baseline equals i normal upper Delta"), where #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-14c4858c78588ccf.svg",0.802,2.176,0.338,"i") ranges from 0 to $n$, inclusive. Within each region, the value of the function $f(x)$ is a constant (@fig:piecewise-constant (a)).
][
假设把一维函数的定义域分为 $n$ 个等长区间，每个区间长度为 $Delta=1/n$。区间端点为 $x_i=i Delta$，其中 $i$ 从 0 到 $n$，包括两端。函数 $f(x)$ 在各区间内为常数（@fig:piecewise-constant (a)）。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf05.svg", width: 90%), caption: [#ez_caption[(a) Probability density function for a piecewise-constant 1D function and (b) cumulative distribution function defined by this PDF.][(a) 一维分段常数函数的概率密度函数；(b) 由该 PDF 定义的累积分布函数。]]) <piecewise-constant>

#parec[
The value of $f(x)$ is then
][
于是，$f(x)$ 的值为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-bc9029c7b5d23e1b.svg",28.972,7.843,3.338,"f left-parenthesis x right-parenthesis equals StartLayout Enlarged left-brace 1st Row 1st Column v 0 2nd Column x 0 less-than-or-equal-to x less-than x 1 2nd Row 1st Column v 1 2nd Column x 1 less-than-or-equal-to x less-than x 2 3rd Row 1st Column vertical-ellipsis EndLayout period", display: true)]

#parec[
The function need not always be positive, though its PDF must be. Therefore, the absolute value of the function is taken to define its PDF. The integral #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-9d12575f38a6e8b9.svg",10.658,3.176,1.005,"integral StartAbsoluteValue f left-parenthesis x right-parenthesis EndAbsoluteValue normal d x") is
][
函数本身不必处处为正，但 PDF 必须非负。因此，用函数的绝对值来定义其 PDF。$abs(f(x))$ 的积分为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-383fbe4c0c8fa594.svg",40.262,7.343,3.005,"c equals integral Subscript 0 Superscript 1 Baseline StartAbsoluteValue f left-parenthesis x right-parenthesis EndAbsoluteValue normal d x equals sigma-summation Underscript i equals 0 Overscript n minus 1 Endscripts StartAbsoluteValue v Subscript i Baseline EndAbsoluteValue normal upper Delta equals sigma-summation Underscript i equals 0 Overscript n minus 1 Endscripts StartFraction StartAbsoluteValue v Subscript i Baseline EndAbsoluteValue Over n EndFraction comma", display: true)] <piecewise-step-integral>

#parec[
and so it is easy to construct the PDF $p(x)$ for $f(x)$ as #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-563249193379ca09.svg",7.885,2.843,0.838,"StartAbsoluteValue f left-parenthesis x right-parenthesis EndAbsoluteValue slash c"). By direct application of the relevant formulae, the CDF $P(x)$ is a piecewise-linear function defined at points $x_i$ by
][
因此，容易构造 $f(x)$ 的 PDF：$p(x)=abs(f(x))/c$。直接应用相应公式可知，CDF $P(x)$ 是分段线性函数，在各点 $x_i$ 的值为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-dc7b5a5a7b40c873.svg",68.403,23.509,11.171,"StartLayout 1st Row 1st Column upper P left-parenthesis x 0 right-parenthesis 2nd Column equals 0 2nd Row 1st Column upper P left-parenthesis x 1 right-parenthesis 2nd Column equals integral Subscript x 0 Superscript x 1 Baseline p left-parenthesis x right-parenthesis normal d x equals StartFraction StartAbsoluteValue v 0 EndAbsoluteValue Over c n EndFraction equals upper P left-parenthesis x 0 right-parenthesis plus StartFraction StartAbsoluteValue v 0 EndAbsoluteValue Over c n EndFraction 3rd Row 1st Column upper P left-parenthesis x 2 right-parenthesis 2nd Column equals integral Subscript x 0 Superscript x 2 Baseline p left-parenthesis x right-parenthesis normal d x equals integral Subscript x 0 Superscript x 1 Baseline p left-parenthesis x right-parenthesis normal d x plus integral Subscript x 1 Superscript x 2 Baseline p left-parenthesis x right-parenthesis normal d x equals upper P left-parenthesis x 1 right-parenthesis plus StartFraction StartAbsoluteValue v 1 EndAbsoluteValue Over c n EndFraction 4th Row 1st Column upper P left-parenthesis x Subscript i Baseline right-parenthesis 2nd Column equals upper P left-parenthesis x Subscript i minus 1 Baseline right-parenthesis plus StartFraction StartAbsoluteValue v Subscript i minus 1 Baseline EndAbsoluteValue Over c n EndFraction period EndLayout", display: true)]

#parec[
Between two points $x_i$ and $x_(i+1)$, the CDF is linearly increasing with slope #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-1de33f171eca8586.svg",5.39,2.843,0.838,"StartAbsoluteValue v Subscript i Baseline EndAbsoluteValue slash c").
][
在相邻点 $x_i$ 与 $x_(i+1)$ 之间，CDF 以斜率 $abs(v_i)/c$ 线性增长。
]

#parec[
Recall that in order to sample $f(x)$ we need to invert the CDF to find the value $x$ such that
][
回忆一下，为了对 $f(x)$ 采样，需要对 CDF 求逆，寻找满足下式的 $x$：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-188a2b3038fb0fbf.svg",25.901,5.843,2.338,"xi Subscript Baseline equals integral Subscript 0 Superscript x Baseline p left-parenthesis x Superscript prime Baseline right-parenthesis normal d x Superscript prime Baseline equals upper P left-parenthesis x right-parenthesis period", display: true)]

#parec[
Because the CDF is monotonically increasing, the value of $x$ must be between the $x_i$ and $x_(i+1)$ such that #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-4d823892a6559a1c.svg",20.717,2.843,0.838,"upper P left-parenthesis x Subscript i Baseline right-parenthesis less-than-or-equal-to xi Subscript Baseline less-than upper P left-parenthesis x Subscript i plus 1 Baseline right-parenthesis"). Given an array of CDF values, this pair of #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-0c8d52a3215107cb.svg",5.691,2.843,0.838,"upper P left-parenthesis x Subscript i Baseline right-parenthesis") values can be efficiently found with a binary search.
][
由于 CDF 单调不减，$x$ 一定位于满足 $P(x_i)<=xi<P(x_(i+1))$ 的两个端点 $x_i$、$x_(i+1)$ 之间。给定存储 CDF 值的数组，可以通过二分查找高效地找到这两个端点处的 $P(x_i)$ 值。
]

#parec[
The `PiecewiseConstant1D` class brings these ideas together to provide methods for efficient sampling and PDF evaluation of this class of functions.
][
`PiecewiseConstant1D` 类把这些思想组合起来，提供高效的采样和 PDF 求值方法。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DDefinition-0")[#raw("<<PiecewiseConstant1D Definition>>=")]] <fragment-PiecewiseConstant1DDefinition-0>

#block(breakable: false)[
```cpp
class PiecewiseConstant1D {
  public:
    <<PiecewiseConstant1D Public Methods>>
    <<PiecewiseConstant1D Public Members>>
};
```
]

#metadata(none) <PiecewiseConstant1D>

#parec[
The `PiecewiseConstant1D` constructor takes `n` values of a piecewise-constant function `f` defined over a range #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-f9877626a906bb2b.svg",9.651,2.843,0.838,"left-bracket monospace m monospace i monospace n comma monospace m monospace a monospace x right-bracket"). (The generalization to a non-$[0,1]$ interval simply requires remapping returned samples to the specified range and renormalizing the PDF based on its extent.)
][
`PiecewiseConstant1D` 的构造函数接收分段常数函数 `f` 的 `n` 个值，该函数定义在 `[min,max]` 上。推广到非 $[0,1]$ 区间，只需把返回的样本映射到指定范围，并根据区间长度重新归一化 PDF。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DPublicMethods-0")[#raw("<<PiecewiseConstant1D Public Methods>>=")] #link(<fragment-PiecewiseConstant1DPublicMethods-1>)[↓]] <fragment-PiecewiseConstant1DPublicMethods-0>

#block(breakable: false)[
```cpp
PiecewiseConstant1D(pstd::span<const Float> f, Float min, Float max,
                    Allocator alloc = {})
    : func(f.begin(), f.end(), alloc), cdf(f.size() + 1, alloc),
      min(min), max(max) {
    <<Take absolute value of func>>
    <<Compute integral of step function at x_i>>
    <<Transform step function integral into CDF>>
}
```
]

#parec[
The constructor makes its own copy of the function values and computes the function’s CDF. Note that the constructor allocates `n+1` `Float`s for the `cdf` array because if $f(x)$ has $n$ step values, then there are $n+1$ values #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-0c8d52a3215107cb.svg",5.691,2.843,0.838,"upper P left-parenthesis x Subscript i Baseline right-parenthesis") that define the CDF. Storing the final CDF value of 1 is redundant but simplifies the sampling code later.
][
构造函数自行复制函数值，并计算 CDF。注意，`cdf` 数组分配了 `n+1` 个 `Float`，因为 $f(x)$ 有 $n$ 个阶梯值时，定义 CDF 需要 $n+1$ 个 $P(x_i)$ 值。存储最后一个恒为 1 的 CDF 值虽属冗余，却能简化后面的采样代码。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DPublicMembers-0")[#raw("<<PiecewiseConstant1D Public Members>>=")] #link(<fragment-PiecewiseConstant1DPublicMembers-1>)[↓]] <fragment-PiecewiseConstant1DPublicMembers-0>

#block(breakable: false)[
```cpp
pstd::vector<Float> func, cdf;
Float min, max;
```
]

#metadata(none) <PiecewiseConstant1D::func>

#metadata(none) <PiecewiseConstant1D::cdf>

#metadata(none) <PiecewiseConstant1D::min>

#metadata(none) <PiecewiseConstant1D::max>

#parec[
Because the specified function may be negative, the absolute value of it is taken here first. (There is no further need for the original function in the `PiecewiseConstant1D` implementation.)
][
由于给定函数可能为负，首先对它取绝对值。`PiecewiseConstant1D` 的后续实现不再需要原函数值。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-Takeabsolutevalueofmonofunc-0")[#raw("<<Take absolute value of func>>=")]] <fragment-Takeabsolutevalueofmonofunc-0>

#block(breakable: false)[
```cpp
for (Float &f : func) f = std::abs(f);
```
]

#parec[
Next, the integral of #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-780c8ee0454adeaa.svg",5.716,2.843,0.838,"StartAbsoluteValue f left-parenthesis x right-parenthesis EndAbsoluteValue") at each point $x_i$ is computed using @eqt:piecewise-step-integral , with the result stored in the `cdf` array for now.
][
接下来利用 @eqt:piecewise-step-integral ，计算 $abs(f(x))$ 从定义域起点到各点 $x_i$ 的积分，暂时存入 `cdf` 数组。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-Computeintegralofstepfunctionatx_i-0")[#raw("<<Compute integral of step function at x_i>>=")]] <fragment-Computeintegralofstepfunctionatx_i-0>

#block(breakable: false)[
```cpp
cdf[0] = 0;
size_t n = f.size();
for (size_t i = 1; i < n + 1; ++i)
    cdf[i] = cdf[i - 1] + func[i - 1] * (max - min) / n;
```
]

#parec[
With the value of the integral stored in `cdf[n]`, this value can be copied into `funcInt` and the CDF can be normalized by dividing through all entries by this value. The case of a zero-valued function is handled by defining a linear CDF, which leads to uniform sampling. That case occurs more frequently than one might expect due to the use of this class when sampling piecewise-constant 2D functions; when that is used with images, images with zero-valued scanlines lead to zero-valued functions here.
][
总积分保存在 `cdf[n]` 中，将其复制到 `funcInt`，再用它除 CDF 的每个元素，完成归一化。如果函数恒为零，则定义线性 CDF，从而均匀采样。这种情况比想象中更常见：本类也用于二维分段常数函数采样；以图像定义分布时，整条扫描线为零就会在这里产生零函数。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-TransformstepfunctionintegralintoCDF-0")[#raw("<<Transform step function integral into CDF>>=")]] <fragment-TransformstepfunctionintegralintoCDF-0>

#block(breakable: false)[
```cpp
funcInt = cdf[n];
if (funcInt == 0)
    for (size_t i = 1; i < n + 1; ++i)
        cdf[i] = Float(i) / Float(n);
else
    for (size_t i = 1; i < n + 1; ++i)
        cdf[i] /= funcInt;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DPublicMembers-1")[#raw("<<PiecewiseConstant1D Public Members>>+=")] #link(<fragment-PiecewiseConstant1DPublicMembers-0>)[↑]] <fragment-PiecewiseConstant1DPublicMembers-1>

#block(breakable: false)[
```cpp
Float funcInt = 0;
```
]

#metadata(none) <PiecewiseConstant1D::funcInt>

#parec[
The integral of the absolute value of the function is made available via a method and the `size()` method returns the number of tabularized values.
][
一个方法提供函数绝对值的积分，`size()` 方法则返回表格中函数值的数量。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DPublicMethods-1")[#raw("<<PiecewiseConstant1D Public Methods>>+=")] #link(<fragment-PiecewiseConstant1DPublicMethods-0>)[↑] #link(<fragment-PiecewiseConstant1DPublicMethods-2>)[↓]] <fragment-PiecewiseConstant1DPublicMethods-1>

#block(breakable: false)[
```cpp
Float Integral() const { return funcInt; }
size_t size() const { return func.size(); }
```
]

#metadata(none) <PiecewiseConstant1D::Integral>

#metadata(none) <PiecewiseConstant1D::size>

#parec[
The #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D::Sample")[`PiecewiseConstant1D::Sample()`] method uses the given random sample `u` to sample from its distribution. It returns the corresponding value $x$ and the value of the PDF $p(x)$. If the optional `offset` parameter is not `nullptr`, it returns the offset into the array of function values of the largest index where the CDF was less than or equal to `u`. (In other words, `cdf[*offset] <= u < cdf[*offset+1]`.)
][
#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D::Sample")[`PiecewiseConstant1D::Sample()`] 使用给定随机样本 `u` 对分布采样，返回相应的 $x$ 和 PDF 值 $p(x)$。如果可选参数 `offset` 不是 `nullptr`，还会返回函数值数组中的索引：它是 CDF 小于等于 `u` 的最大索引，也就是满足 `cdf[*offset] <= u < cdf[*offset+1]` 的索引。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DPublicMethods-2")[#raw("<<PiecewiseConstant1D Public Methods>>+=")] #link(<fragment-PiecewiseConstant1DPublicMethods-1>)[↑] #link(<fragment-PiecewiseConstant1DPublicMethods-3>)[↓]] <fragment-PiecewiseConstant1DPublicMethods-2>

#block(breakable: false)[
```cpp
Float Sample(Float u, Float *pdf = nullptr, int *offset = nullptr) const {
    <<Find surrounding CDF segments and offset>>
    <<Compute offset along CDF segment>>
    <<Compute PDF for sampled offset>>
    <<Return x corresponding to sample>>
}
```
]

#metadata(none) <PiecewiseConstant1D::Sample>

#parec[
Mapping `u` to an interval matching the above criterion is carried out using the efficient binary search implemented in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#FindInterval")[`FindInterval()`].
][
利用 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#FindInterval")[`FindInterval()`] 中高效的二分查找，将 `u` 映射到满足上述条件的区间。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-FindsurroundingCDFsegmentsandmonooffset-0")[#raw("<<Find surrounding CDF segments and offset>>=")]] <fragment-FindsurroundingCDFsegmentsandmonooffset-0>

#block(breakable: false)[
```cpp
int o = FindInterval((int)cdf.size(),
                     [&](int index) { return cdf[index] <= u; });
if (offset)
    *offset = o;
```
]

#parec[
Given the pair of CDF values that straddle `u`, we can compute $x$. First, we determine how far `u` is between `cdf[o]` and `cdf[o+1]`. We denote this value with `du`, where `du` is 0 if `u == cdf[o]` and goes up to 1 if `u == cdf[o+1]`. Because the CDF is piecewise-linear, the sample value $x$ is the same offset between $x_i$ and $x_(i+1)$ (@fig:piecewise-constant (b)).
][
给定夹住 `u` 的两个 CDF 值，就可以计算 $x$。首先求 `u` 在 `cdf[o]` 和 `cdf[o+1]` 之间的相对位置，记为 `du`：当 `u == cdf[o]` 时为 0，当 `u == cdf[o+1]` 时达到 1。由于 CDF 分段线性，样本值 $x$ 在 $x_i$ 和 $x_(i+1)$ 之间具有相同的相对位置（@fig:piecewise-constant (b)）。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-ComputeoffsetalongCDFsegment-0")[#raw("<<Compute offset along CDF segment>>=")]] <fragment-ComputeoffsetalongCDFsegment-0>

#block(breakable: false)[
```cpp
Float du = u - cdf[o];
if (cdf[o + 1] - cdf[o] > 0)
    du /= cdf[o + 1] - cdf[o];
```
]

#parec[
The PDF for this sample $p(x)$ is easily computed since we have the function’s integral in `funcInt`. (Note that the offset `o` into the CDF array has been computed in a way so that `func[o]` gives the value of the function in the CDF range that the sample landed in.)
][
函数积分已经保存在 `funcInt` 中，因此容易计算样本的 PDF $p(x)$。注意，CDF 数组索引 `o` 的计算方式保证了 `func[o]` 就是样本所在 CDF 区间对应的函数值。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-ComputePDFforsampledoffset-0")[#raw("<<Compute PDF for sampled offset>>=")]] <fragment-ComputePDFforsampledoffset-0>

#block(breakable: false)[
```cpp
if (pdf)
    *pdf = (funcInt > 0) ? func[o] / funcInt : 0;
```
]

#parec[
Finally, the appropriate value of $x$ is computed and returned. Here is where the sampled value in $lr([0,1))$ is remapped to the user-specified range #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-232f6786c7642816.svg",9.909,2.843,0.838,"left-bracket monospace m monospace i monospace n comma monospace m monospace a monospace x right-parenthesis").
][
最后计算并返回相应的 $x$，同时把 $lr([0,1))$ 内的采样值映射到用户指定的 `[min,max)` 范围。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-Returnxcorrespondingtosample-0")[#raw("<<Return x corresponding to sample>>=")]] <fragment-Returnxcorrespondingtosample-0>

#block(breakable: false)[
```cpp
return Lerp((o + du) / size(), min, max);
```
]

#parec[
As with the other sampling routines so far, `PiecewiseConstant1D` provides an inversion method that takes a point $x$ in the range #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-f9877626a906bb2b.svg",9.651,2.843,0.838,"left-bracket monospace m monospace i monospace n comma monospace m monospace a monospace x right-bracket") and returns the $lr([0,1))$ sample value that maps to it. As before, this is a matter of evaluating the CDF $P(x)$ at the given position.#footnote[Editorial note: For nonempty, nondegenerate input with valid arithmetic, the code below accepts `x == max` and returns the final CDF value 1, contrary to the source’s stated half-open return range.]
][
与前面的采样函数一样，`PiecewiseConstant1D` 提供逆采样方法：接收 `[min,max]` 范围内的点 $x$，返回映射到它的 $lr([0,1))$ 样本值。与前面一样，只需在给定位置计算 CDF $P(x)$。#footnote[校注：原文把逆采样返回范围写作 $lr([0,1))$，但在非空、区间非退化且计算有效时，下列实现接受 `x == max`，并返回末端 CDF 值 1。因此该边界与原文所写的半开范围不一致。]
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-PiecewiseConstant1DPublicMethods-3")[#raw("<<PiecewiseConstant1D Public Methods>>+=")] #link(<fragment-PiecewiseConstant1DPublicMethods-2>)[↑]] <fragment-PiecewiseConstant1DPublicMethods-3>

#block(breakable: false)[
```cpp
pstd::optional<Float> Invert(Float x) const {
    <<Compute offset to CDF values that bracket x>>
    <<Linearly interpolate between adjacent CDF values to find sample value>>
}
```
]

#metadata(none) <PiecewiseConstant1D::Invert>

#parec[
Because the CDF is tabularized at regular steps over #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A4-f9877626a906bb2b.svg",9.651,2.843,0.838,"left-bracket monospace m monospace i monospace n comma monospace m monospace a monospace x right-bracket"), if we remap $x$ to lie within $lr([0,1))$, scale by the number of CDF values, and take the floor of that value, we have the offset to the entry in the `cdf` array that precedes $x$.
][
由于 CDF 在 `[min,max]` 上等间隔存储，把 $x$ 映射到 $lr([0,1))$，乘以 CDF 的离散区间数，再向下取整，就得到 `cdf` 数组中位于 $x$ 之前的元素索引。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-ComputeoffsettoCDFvaluesthatbracketx-0")[#raw("<<Compute offset to CDF values that bracket x>>=")]] <fragment-ComputeoffsettoCDFvaluesthatbracketx-0>

#block(breakable: false)[
```cpp
if (x < min || x > max)
    return {};
Float c = (x - min) / (max - min) * func.size();
int offset = Clamp(int(c), 0, func.size() - 1);
```
]

#parec[
Given those two points, we linearly interpolate between their values to evaluate the CDF.
][
给定这两个端点，在它们的值之间进行线性插值，即可计算 CDF。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-LinearlyinterpolatebetweenadjacentCDFvaluestofindsamplevalue-0")[#raw("<<Linearly interpolate between adjacent CDF values to find sample value>>=")]] <fragment-LinearlyinterpolatebetweenadjacentCDFvaluestofindsamplevalue-0>

#block(breakable: false)[
```cpp
Float delta = c - offset;
return Lerp(delta, cdf[offset], cdf[offset + 1]);
```
]

#include "supplements/A.4-expanded.typ"
