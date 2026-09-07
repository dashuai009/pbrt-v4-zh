#import "../template.typ": parec, ez_caption, translator

#import "supplements/source-math.typ": source-math

== #ez_caption[Sampling Multidimensional Functions][多维函数采样]

<sampling-multidimensional-functions>

#parec[
Multidimensional sampling is also common in `pbrt`, most frequently when sampling points on the surfaces of shapes and sampling directions after scattering at points. This section therefore works through the derivations and implementations of algorithms for sampling in a number of useful multidimensional domains. Some of them involve separable PDFs where each dimension can be sampled independently, while others use the approach of sampling from marginal and conditional density functions that was introduced in Section #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-multidimensional-sampling")[2.4.2].
][
`pbrt` 也经常需要多维采样，最常见的是在形状表面采样点，以及在散射点采样方向。因此，本节推导并实现若干实用多维定义域上的采样算法。其中一些 PDF 可分离，各维可独立采样；另一些则使用第 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-multidimensional-sampling")[2.4.2] 节介绍的边缘密度与条件密度采样方法。
]

#block(breakable: false)[
=== #ez_caption[Sampling a Unit Disk][单位圆盘采样] <unit-disk-sample>

#parec[
Uniformly sampling a unit disk can be tricky because it has an incorrect intuitive solution. The wrong approach is the seemingly obvious one of sampling its polar coordinates uniformly: #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-ed8634300ea0ce3c.svg",16.003,2.509,0.671,"r equals xi 1 comma theta equals 2 pi xi 2"). Although the resulting point is both random and inside the disk, it is _not_ uniformly distributed; it actually clumps samples near the center of the disk. @fig:disk-sample-good-bad (a) shows a plot of samples on the unit disk when this mapping was used for a set of uniform random samples $(xi_1,xi_2)$. @fig:disk-sample-good-bad (b) shows uniformly distributed samples resulting from the following correct approach.
][
在单位圆盘内均匀采样并不简单，因为直觉可能引向错误解法。看似自然的做法是均匀采样极坐标：$r=xi_1, theta=2 pi xi_2$。得到的点虽然随机且位于圆盘内，却_不是_均匀分布的：样本会聚集在圆心附近。@fig:disk-sample-good-bad (a) 展示了对一组均匀随机样本 $(xi_1,xi_2)$ 应用这一映射的结果；(b) 则展示了下面正确方法生成的均匀样本。
]

]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf06.svg", width: 90%), caption: [#ez_caption[(a) When the obvious but incorrect mapping of uniform random variables to points on the disk is used, the resulting distribution is not uniform and the samples are more likely to be near the center of the disk. (b) The correct mapping gives a uniform distribution of points.][(a) 采用看似自然却不正确的映射，将均匀随机变量映射到圆盘上的点时，结果并不均匀，样本更容易聚集在圆心附近。(b) 正确的映射生成均匀分布的点。]]) <disk-sample-good-bad>

#parec[
Since we would like to sample uniformly with respect to area, the PDF #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-d55a79b9f81fe4f8.svg",6.555,2.843,0.838,"p left-parenthesis x comma y right-parenthesis") must be a constant. By the normalization constraint, #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-1694f47b266aa8d0.svg",13.303,2.843,0.838,"p left-parenthesis x comma y right-parenthesis equals 1 slash pi"). If we transform into polar coordinates, we have #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-c1421315b76a6665.svg",12.86,2.843,0.838,"p left-parenthesis r comma theta right-parenthesis equals r slash pi") given the relationship between probability densities in Cartesian coordinates and polar coordinates that was derived in Section #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-transform-multiple-dimensions")[2.4.1], Equation (#link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#eq:polar-cartesian-pdf-relation")[2.22]).
][
要相对于面积均匀采样，PDF $p(x,y)$ 必须为常数。由归一化条件可得 $p(x,y)=1/pi$。利用第 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-transform-multiple-dimensions")[2.4.1] 节公式 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#eq:polar-cartesian-pdf-relation")[(2.22)] 推导的笛卡尔坐标与极坐标下概率密度的关系，转换到极坐标后有 $p(r,theta)=r/pi$。
]

#parec[
We can now compute the marginal and conditional densities:
][
现在可以计算边缘密度和条件密度：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-54edbced50364a8c.svg",28.673,13.176,6.005,"StartLayout 1st Row 1st Column p left-parenthesis r right-parenthesis 2nd Column equals integral Subscript 0 Superscript 2 pi Baseline p left-parenthesis r comma theta right-parenthesis normal d theta Subscript Baseline equals 2 r 2nd Row 1st Column p left-parenthesis theta vertical-bar r right-parenthesis 2nd Column equals StartFraction p left-parenthesis r comma theta right-parenthesis Over p left-parenthesis r right-parenthesis EndFraction equals StartFraction 1 Over 2 pi EndFraction period EndLayout", display: true)]

#parec[
The fact that $p(theta | r)$ is a constant should make sense because of the symmetry of the disk. Integrating and inverting to find $P(r)$, $P^(-1) (r)$, $P(theta)$, and $P^(-1) (theta)$, we can find that the correct solution to generate uniformly distributed samples on a disk is
][
由于圆盘对称，$p(theta | r)$ 为常数是合理的。通过积分并求逆，得到 $P(r)$、$P^(-1)(r)$、$P(theta)$ 和 $P^(-1)(theta)$，进而得到在圆盘上均匀采样的正确方法：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-63d4a279f96793c6.svg",10.147,6.843,2.838,"StartLayout 1st Row 1st Column r 2nd Column equals StartRoot xi 1 EndRoot 2nd Row 1st Column theta 2nd Column equals 2 pi xi 2 period EndLayout", display: true)]

#parec[
Taking the square root of $xi_1$ effectively pushes the samples back toward the edge of the disk, counteracting the clumping referred to earlier.
][
对 $xi_1$ 取平方根，实际上把样本推向圆盘边缘，抵消了前面所说的聚集现象。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-30")[#raw("<<Sampling Inline Functions>>+=")] #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragment-SamplingInlineFunctions-29")[↑] #link(<fragment-SamplingInlineFunctions-31>)[↓]] <fragment-SamplingInlineFunctions-30>

#block(breakable: false)[
```cpp
Point2f SampleUniformDiskPolar(Point2f u) {
    Float r = std::sqrt(u[0]);
    Float theta = 2 * Pi * u[1];
    return {r * std::cos(theta), r * std::sin(theta)};
}
```
]

#metadata(none) <SampleUniformDiskPolar>

#parec[
The inversion method, `InvertUniformDiskPolarSample()`, is straightforward and is not included here.
][
逆采样函数 `InvertUniformDiskPolarSample()` 很直接，这里不再列出。
]

#metadata(none) <InvertUniformDiskPolarSample>

#parec[
Although this mapping solves the problem at hand, it distorts areas on the disk; areas on the unit square are elongated or compressed when mapped to the disk (@fig:disk-mapping-distortion ). This distortion can reduce the effectiveness of stratified sampling patterns by making the strata less compact. A better approach that avoids this problem is a “concentric” mapping from the unit square to the unit disk. The concentric mapping takes points in the square $[-1,1]^2$ to the unit disk by uniformly mapping concentric squares to concentric circles (@fig:square-to-sphere ).
][
这种映射虽然解决了均匀采样问题，却会扭曲圆盘上的区域形状：单位正方形中的区域映射到圆盘后会被拉长或压缩（@fig:disk-mapping-distortion ）。分层区域因此不够紧凑，可能降低分层采样模式的效果。较好的办法是使用从单位正方形到单位圆盘的“同心”映射。它把 $[-1,1]^2$ 中的点映射到单位圆盘，将同心正方形均匀映射为同心圆（@fig:square-to-sphere ）。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf07.svg", width: 90%), caption: [#ez_caption[The mapping from 2D random samples to points on the disk implemented in #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformDiskPolar")[`SampleUniformDiskPolar()`] distorts areas substantially. Each section of the disk here has equal area and represents #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-36b4674df4e3d503.svg",1.658,3.676,1.338,"one-eighth") of the unit square of uniform random samples in each direction. In general, we would prefer a mapping that did a better job at mapping nearby $(xi_1,xi_2)$ values to nearby points on the disk.][`SampleUniformDiskPolar()` 将二维随机样本映射到圆盘上的点时，会显著扭曲区域形状。图中各区域面积相等，每个区域对应均匀随机样本所在单位正方形中两个方向上各占 $1/8$ 的区间。一般而言，我们更希望相邻的 $(xi_1,xi_2)$ 值映射到圆盘上相邻的点。]]) <disk-mapping-distortion>

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf08.svg", width: 90%), caption: [#ez_caption[The concentric mapping maps squares to circles, giving a less distorted mapping than the first method shown for uniformly sampling points on the unit disk. It is based on mapping triangular wedges of the unit square to pie-shaped wedges of the disk, as shown here.][同心映射把正方形映射到圆。与前一种均匀圆盘采样方法相比，它造成的形状畸变较小。如图所示，其基础是将单位正方形的三角楔形区域映射到圆盘的扇形区域。]]) <square-to-sphere>

#parec[
The mapping turns wedges of the square into slices of the disk. For example, points in the shaded area in @fig:square-to-sphere are mapped to $(r,theta)$ by
][
这种映射将正方形的楔形区域变为圆盘的扇形。例如，@fig:square-to-sphere 中阴影区域内的点按下式映射到 $(r,theta)$：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-77593cef9d9e7d51.svg",9.914,8.176,3.505,"StartLayout 1st Row 1st Column r 2nd Column equals x 2nd Row 1st Column theta 2nd Column equals StartFraction y Over x EndFraction StartFraction pi Over 4 EndFraction period EndLayout", display: true)]

#parec[
See @fig:wedgemap . The other seven wedges are handled analogously.
][
见 @fig:wedgemap 。其余七个楔形区域采用类似的处理。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf09.svg", width: 90%), caption: [#ez_caption[Triangular wedges of the square are mapped into $(r,theta)$ pairs in pie-shaped slices of the disk in the `SampleUniformDiskConcentric()` function.][`SampleUniformDiskConcentric()` 将正方形中的三角楔形区域映射到圆盘扇形中的 $(r,theta)$ 坐标对。]]) <wedgemap>

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-31")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-30>)[↑] #link(<fragment-SamplingInlineFunctions-32>)[↓]] <fragment-SamplingInlineFunctions-31>

#block(breakable: false)[
```cpp
Point2f SampleUniformDiskConcentric(Point2f u) {
    <<Map u to [-1,1]^2 and handle degeneracy at the origin>>
    <<Apply concentric mapping to point>>
}
```
]

#metadata(none) <SampleUniformDiskConcentric>

#parec[
For the following, the random samples are mapped to the $[-1,1]^2$ square. The $(0,0)$ point is then handled specially so that the following code does not need to avoid dividing by zero.
][
接下来先把随机样本映射到 $[-1,1]^2$。对点 $(0,0)$ 单独处理后，后续代码便无需再防范除零。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Mapmonouto-112andhandledegeneracyattheorigin-0")[#raw("<<Map u to [-1,1]^2 and handle degeneracy at the origin>>=")]] <fragment-Mapmonouto-112andhandledegeneracyattheorigin-0>

#block(breakable: false)[
```cpp
Point2f uOffset = 2 * u - Vector2f(1, 1);
if (uOffset.x == 0 && uOffset.y == 0)
    return {0, 0};
```
]

#parec[
All the other points are transformed using the mapping from square wedges to disk slices by way of computing $(r,theta)$ polar coordinates for them. The following implementation is carefully crafted so that the mapping is continuous across adjacent slices.
][
对其他点，计算其极坐标 $(r,theta)$，将正方形楔形映射到圆盘扇形。下面的实现经过仔细安排，使映射在相邻扇形之间连续。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Applyconcentricmappingtopoint-0")[#raw("<<Apply concentric mapping to point>>=")]] <fragment-Applyconcentricmappingtopoint-0>

#block(breakable: false)[
```cpp
Float theta, r;
if (std::abs(uOffset.x) > std::abs(uOffset.y)) {
    r = uOffset.x;
    theta = PiOver4 * (uOffset.y / uOffset.x);
} else {
    r = uOffset.y;
    theta = PiOver2 - PiOver4 * (uOffset.x / uOffset.y);
}
return r * Point2f(std::cos(theta), std::sin(theta));
```
]

#parec[
The corresponding inversion function, `InvertUniformDiskConcentricSample()`, is not included in the text here.
][
相应的逆采样函数 `InvertUniformDiskConcentricSample()` 不在这里列出。
]

#metadata(none) <InvertUniformDiskConcentricSample>

#block(breakable: false)[
=== #ez_caption[Uniformly Sampling Hemispheres and Spheres][半球与球面的均匀采样] <unisample-hemi>

#parec[
The area of a unit hemisphere is $2 pi$, and thus the PDF for uniform sampling must be #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-d221d8125b3b2b52.svg",14.218,2.843,0.838,"p left-parenthesis omega right-parenthesis equals 1 slash left-parenthesis 2 pi right-parenthesis").
][
单位半球的面积为 $2 pi$，因此均匀采样的 PDF 必须为 $p(omega)=1/(2 pi)$。
]

]

#parec[
We will use spherical coordinates to derive a sampling algorithm. Using Equation (#link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#eq:spherical-cartesian-pdf-relation")[2.23]) from Section #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-transform-multiple-dimensions")[2.4.1], we have #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-00b822269fbb3b90.svg",19.453,2.843,0.838,"p left-parenthesis theta comma phi right-parenthesis equals sine theta slash left-parenthesis 2 pi right-parenthesis"). This density function is separable. Because $phi.alt$ ranges from 0 to $2 pi$ and must have a constant PDF, #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-727246f9ad3cf314.svg",14.157,2.843,0.838,"p left-parenthesis phi right-parenthesis equals 1 slash left-parenthesis 2 pi right-parenthesis") and therefore #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-6e25b25832e1c2f6.svg",11.574,2.843,0.838,"p left-parenthesis theta right-parenthesis equals sine theta"). The two CDFs follow:
][
下面使用球坐标推导采样算法。根据第 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-transform-multiple-dimensions")[2.4.1] 节的公式 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#eq:spherical-cartesian-pdf-relation")[(2.23)]，有 $p(theta,phi.alt)=frac(sin theta,2 pi)$。该密度可分离。由于 $phi.alt$ 从 0 到 $2 pi$，且其 PDF 为常数，所以 $p(phi.alt)=1/(2 pi)$，进而有 $p(theta)=sin theta$。两个 CDF 为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-e3544ebac69a5ed9.svg",33.232,13.176,6.005,"StartLayout 1st Row 1st Column upper P left-parenthesis theta right-parenthesis 2nd Column equals integral Subscript 0 Superscript theta Baseline sine theta prime normal d theta Subscript Superscript prime Baseline equals 1 minus cosine theta 2nd Row 1st Column upper P left-parenthesis phi right-parenthesis 2nd Column equals integral Subscript 0 Superscript phi Baseline StartFraction 1 Over 2 pi EndFraction normal d phi Superscript prime Baseline equals StartFraction phi Over 2 pi EndFraction period EndLayout", display: true)]

#parec[
Inverting these functions is straightforward, and in this case we can tidy the result by replacing $1-xi$ with $xi$, giving
][
这些函数很容易求逆；在这里还可以用 $xi$ 替换 $1-xi$ 来简化结果，得到
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-e0d34c06418ec4db.svg",13.139,6.509,2.671,"StartLayout 1st Row 1st Column theta 2nd Column equals cosine Superscript negative 1 Baseline xi 1 2nd Row 1st Column phi 2nd Column equals 2 pi xi 2 period EndLayout", display: true)]

#parec[
Converting back to Cartesian coordinates, we get the final sampling formulae:
][
转换回笛卡尔坐标，得到最终的采样公式：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-e59bf4f6ad88e74c.svg",35.786,13.843,6.338,"StartLayout 1st Row 1st Column x 2nd Column equals sine theta cosine phi equals cosine left-parenthesis 2 pi xi 2 right-parenthesis StartRoot 1 minus xi 1 squared EndRoot 2nd Row 1st Column y 2nd Column equals sine theta sine phi equals sine left-parenthesis 2 pi xi 2 right-parenthesis StartRoot 1 minus xi 1 squared EndRoot 3rd Row 1st Column z 2nd Column equals cosine theta equals xi 1 period EndLayout", display: true)] <uniform-hemi-sample>

#parec[
This sampling strategy is implemented in the following code. Two uniform random numbers are provided in `u`, and a vector on the hemisphere is returned.
][
下面的代码实现这一策略。参数 `u` 提供两个均匀随机数，函数返回一个位于半球上的向量。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-32")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-31>)[↑] #link(<fragment-SamplingInlineFunctions-33>)[↓]] <fragment-SamplingInlineFunctions-32>

#block(breakable: false)[
```cpp
Vector3f SampleUniformHemisphere(Point2f u) {
    Float z = u[0];
    Float r = SafeSqrt(1 - Sqr(z));
    Float phi = 2 * Pi * u[1];
    return {r * std::cos(phi), r * std::sin(phi), z};
}
```
]

#metadata(none) <SampleUniformHemisphere>

#parec[
For each PDF evaluation function, it is important to be clear which PDF is being evaluated—for example, we have already seen directional probabilities expressed both in terms of solid angle and in terms of $(theta,phi.alt)$. For hemispheres (and all other directional sampling in `pbrt`), these functions return probability with respect to solid angle. Thus, the uniform hemisphere PDF function is trivial and does not require that the direction be passed to it.
][
每个 PDF 求值函数都必须明确自己计算的是哪一种密度。例如，前面已经分别用立体角和 $(theta,phi.alt)$ 表示过方向的分布。半球采样以及 `pbrt` 中所有其他方向采样的这些函数，返回的都是相对于立体角的概率密度。因此，均匀半球 PDF 的实现很简单，甚至不需要传入方向。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-33")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-32>)[↑] #link(<fragment-SamplingInlineFunctions-34>)[↓]] <fragment-SamplingInlineFunctions-33>

#block(breakable: false)[
```cpp
Float UniformHemispherePDF() { return Inv2Pi; }
```
]

#metadata(none) <UniformHemispherePDF>

#parec[
The inverse sampling method can be derived starting from @eqt:uniform-hemi-sample .
][
逆采样方法可以从 @eqt:uniform-hemi-sample 推导得到。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-34")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-33>)[↑] #link(<fragment-SamplingInlineFunctions-35>)[↓]] <fragment-SamplingInlineFunctions-34>

#block(breakable: false)[
```cpp
Point2f InvertUniformHemisphereSample(Vector3f w) {
    Float phi = std::atan2(w.y, w.x);
    if (phi < 0)
        phi += 2 * Pi;
    return Point2f(w.z, phi / (2 * Pi));
}
```
]

#metadata(none) <InvertUniformHemisphereSample>

#parec[
Sampling the full sphere uniformly over its area follows almost exactly the same derivation, which we omit here. The end result is
][
在整个球面上按面积均匀采样，推导过程几乎相同，这里省略。最终结果为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-5fd2f662106c973f.svg",49.151,13.843,6.338,"StartLayout 1st Row 1st Column x 2nd Column equals cosine left-parenthesis 2 pi xi 2 right-parenthesis StartRoot 1 minus z squared EndRoot equals cosine left-parenthesis 2 pi xi 2 right-parenthesis 2 StartRoot xi 1 left-parenthesis 1 minus xi 1 right-parenthesis EndRoot 2nd Row 1st Column y 2nd Column equals sine left-parenthesis 2 pi xi 2 right-parenthesis StartRoot 1 minus z squared EndRoot equals sine left-parenthesis 2 pi xi 2 right-parenthesis 2 StartRoot xi 1 left-parenthesis 1 minus xi 1 right-parenthesis EndRoot 3rd Row 1st Column z 2nd Column equals 1 minus 2 xi 1 period EndLayout", display: true)]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-35")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-34>)[↑] #link(<fragment-SamplingInlineFunctions-36>)[↓]] <fragment-SamplingInlineFunctions-35>

#block(breakable: false)[
```cpp
Vector3f SampleUniformSphere(Point2f u) {
    Float z = 1 - 2 * u[0];
    Float r = SafeSqrt(1 - Sqr(z));
    Float phi = 2 * Pi * u[1];
    return {r * std::cos(phi), r * std::sin(phi), z};
}
```
]

#metadata(none) <SampleUniformSphere>

#parec[
The PDF is $1/(4 pi)$, one over the surface area of the unit sphere.
][
PDF 为 $1/(4 pi)$，即单位球表面积的倒数。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-36")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-35>)[↑] #link(<fragment-SamplingInlineFunctions-37>)[↓]] <fragment-SamplingInlineFunctions-36>

#block(breakable: false)[
```cpp
Float UniformSpherePDF() { return Inv4Pi; }
```
]

#metadata(none) <UniformSpherePDF>

#parec[
The sampling inversion method also follows directly.
][
逆采样方法也可直接得到。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-37")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-36>)[↑] #link(<fragment-SamplingInlineFunctions-38>)[↓]] <fragment-SamplingInlineFunctions-37>

#block(breakable: false)[
```cpp
Point2f InvertUniformSphereSample(Vector3f w) {
    Float phi = std::atan2(w.y, w.x);
    if (phi < 0)
        phi += 2 * Pi;
    return Point2f((1 - w.z) / 2, phi / (2 * Pi));
}
```
]

#metadata(none) <InvertUniformSphereSample>

#block(breakable: false)[
=== #ez_caption[Cosine-Weighted Hemisphere Sampling][余弦加权半球采样] <cos-hemisphere-sampling>

#parec[
As we saw in the discussion of importance sampling (Section #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Improving_Efficiency.html#sec:importance-sampling")[2.2.2]), it is often useful to sample from a distribution that has a shape similar to that of the integrand being estimated. Many light transport integrals include a cosine factor, and therefore it is useful to have a method that generates directions according to a cosine-weighted distribution on the hemisphere. Such a method gives samples that are more likely to be close to the top of the hemisphere, where the cosine term has a large value, rather than near the bottom, where the cosine term is small.
][
正如重要性采样的讨论（第 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Improving_Efficiency.html#sec:importance-sampling")[2.2.2] 节）所述，按形状接近待估计被积函数的分布采样往往很有帮助。许多光传输积分含有余弦因子，因此需要一种按半球上余弦加权分布生成方向的方法。这样生成的样本更可能靠近余弦值较大的半球顶部，而非余弦值较小的底部边缘。
]

]

#parec[
Mathematically, this means that we would like to sample directions $omega$ from a PDF
][
从数学上说，就是希望按如下 PDF 采样方向 $omega$：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-85781478b3e2062c.svg",12.832,2.843,0.838,"p left-parenthesis omega right-parenthesis proportional-to cosine theta period", display: true)]

#parec[
Normalizing as usual,
][
按通常方法归一化：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-41ca5b818792d5a8.svg",32.688,25.843,12.338,"StartLayout 1st Row 1st Column integral Underscript script upper H squared Endscripts p left-parenthesis omega Subscript Baseline right-parenthesis normal d omega Subscript 2nd Column equals 1 2nd Row 1st Column integral Subscript 0 Superscript 2 pi Baseline integral Subscript 0 Superscript StartFraction pi Over 2 EndFraction Baseline c cosine theta sine theta normal d theta Subscript Baseline normal d phi Subscript 2nd Column equals 1 3rd Row 1st Column c Baseline 2 pi integral Subscript 0 Superscript pi slash 2 Baseline cosine theta sine theta normal d theta Subscript 2nd Column equals 1 4th Row 1st Column c 2nd Column equals StartFraction 1 Over pi EndFraction period EndLayout", display: true)]

#parec[
Thus,
][
因此，
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-764a7825c148d407.svg",21.777,5.176,1.838,"p left-parenthesis theta comma phi right-parenthesis equals StartFraction 1 Over pi EndFraction cosine theta sine theta period", display: true)]

#parec[
We could compute the marginal and conditional densities as before, but instead we can use a technique known as _Malley’s method_ to generate these cosine-weighted points. The idea behind Malley’s method is that if we choose points uniformly from the unit disk and then generate directions by projecting the points on the disk up to the hemisphere above it, the result will have a cosine-weighted distribution of directions (@fig:malley ).
][
可以像前面一样计算边缘密度与条件密度，但也可以用 _Malley 方法_生成这些余弦加权样本。其思想是：先在单位圆盘内均匀选择点，再把这些点向上投影到上方的半球以生成方向，得到的方向就服从余弦加权分布（@fig:malley ）。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf10.svg", width: 90%), caption: [#ez_caption[Malley’s Method. To sample direction vectors from a cosine-weighted distribution, uniformly sample points on the unit disk and project them up to the unit hemisphere.][*Malley 方法。*要按余弦加权分布采样方向向量，先在单位圆盘内均匀采样点，再向上投影到单位半球。]]) <malley>

#parec[
Why does this work? Let $(r,phi.alt)$ be the polar coordinates of the point chosen on the disk (note that we are using $phi.alt$ instead of the usual $theta$ for the polar angle here). From Section #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[A.5.1], we know that the joint density #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-f0bb023d945f8397.svg",13.154,2.843,0.838,"p left-parenthesis r comma phi right-parenthesis equals r slash pi") gives the density of a point sampled on the disk.
][
为什么这样做有效？用 $(r,phi.alt)$ 表示圆盘采样点的极坐标。注意，这里用 $phi.alt$ 而非通常的 $theta$ 表示极角。由第 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[A.5.1] 节可知，圆盘采样点的联合密度为 $p(r,phi.alt)=r/pi$。
]

#parec[
Now, we map this point to the hemisphere. The vertical projection gives #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-344e7a1549f05b00.svg",8.48,2.176,0.338,"sine theta equals r"), which is easily seen from @fig:malley . To complete the #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-d73e4fdf04f391dd.svg",25.871,2.843,0.838,"left-parenthesis r comma phi right-parenthesis equals left-parenthesis sine theta comma phi right-parenthesis right-arrow left-parenthesis theta comma phi right-parenthesis") transformation, we need the determinant of the Jacobian
][
现在把该点映射到半球。如 @fig:malley 所示，竖直投影给出 $sin theta=r$。为完成 $(r,phi.alt)=(sin theta,phi.alt) arrow.r (theta,phi.alt)$ 的变换，需要计算雅可比矩阵的行列式：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-d8e7365065f66e13.svg",25.524,6.176,2.505,"StartAbsoluteValue upper J Subscript upper T Baseline EndAbsoluteValue equals Start 2 By 2 Determinant 1st Row 1st Column cosine theta 2nd Column 0 2nd Row 1st Column 0 2nd Column 1 EndDeterminant equals cosine theta period", display: true)]

#parec[
Therefore,
][
因此，
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-fc62757e206e6ae8.svg",44.206,5.343,1.838,"p left-parenthesis theta comma phi right-parenthesis equals StartAbsoluteValue upper J Subscript upper T Baseline EndAbsoluteValue p left-parenthesis r comma phi right-parenthesis equals cosine theta StartFraction r Over pi EndFraction equals StartFraction cosine theta sine theta Over pi EndFraction comma", display: true)]

#parec[
which is exactly what we wanted! We have used the transformation method to prove that Malley’s method generates directions with a cosine-weighted distribution. Note that this technique works with any uniform disk sampling approach, so we can use the earlier concentric mapping just as well as the simpler #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-8b25cd088ccc03b3.svg",19.881,3.343,1.005,"left-parenthesis r comma theta right-parenthesis equals left-parenthesis StartRoot xi 1 EndRoot comma 2 pi xi 2 right-parenthesis") method.
][
这正是所需的结果！我们用分布变换证明了 Malley 方法生成的方向服从余弦加权分布。注意，任何均匀圆盘采样方法都可用于这里，因此既可以使用先前的同心映射，也可以使用更简单的 $(r,theta)=(sqrt(xi_1),2 pi xi_2)$ 方法。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-38")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-37>)[↑] #link(<fragment-SamplingInlineFunctions-39>)[↓]] <fragment-SamplingInlineFunctions-38>

#block(breakable: false)[
```cpp
Vector3f SampleCosineHemisphere(Point2f u) {
    Point2f d = SampleUniformDiskConcentric(u);
    Float z = SafeSqrt(1 - Sqr(d.x) - Sqr(d.y));
    return Vector3f(d.x, d.y, z);
}
```
]

#metadata(none) <SampleCosineHemisphere>

#parec[
Because directional PDFs in `pbrt` are defined with respect to solid angle, the PDF function returns the value #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-36e543b46f4a9609.svg",7.076,2.843,0.838,"cosine theta slash pi").
][
由于 `pbrt` 的方向 PDF 相对于立体角定义，PDF 函数返回 $frac(cos theta,pi)$。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-39")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-38>)[↑] #link(<fragment-SamplingInlineFunctions-40>)[↓]] <fragment-SamplingInlineFunctions-39>

#block(breakable: false)[
```cpp
Float CosineHemispherePDF(Float cosTheta) {
    return cosTheta * InvPi;
}
```
]

#metadata(none) <CosineHemispherePDF>

#parec[
Finally, a directional sample can be inverted purely from its $(x,y)$ coordinates on the disk.
][
最后，仅用方向样本在圆盘上的 $(x,y)$ 坐标，就能执行逆采样。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-40")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-39>)[↑] #link(<fragment-SamplingInlineFunctions-41>)[↓]] <fragment-SamplingInlineFunctions-40>

#block(breakable: false)[
```cpp
Point2f InvertCosineHemisphereSample(Vector3f w) {
    return InvertUniformDiskConcentricSample({w.x, w.y});
}
```
]

#metadata(none) <InvertCosineHemisphereSample>

#block(breakable: false)[
=== #ez_caption[Sampling Within a Cone][圆锥内采样] <sampling-a-cone>

#parec[
It is sometimes useful to be able to uniformly sample rays in a cone of directions. This distribution is separable in $(theta,phi.alt)$, with #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-727246f9ad3cf314.svg",14.157,2.843,0.838,"p left-parenthesis phi right-parenthesis equals 1 slash left-parenthesis 2 pi right-parenthesis"), and so we therefore need to derive a method to sample a direction $theta$ up to the maximum angle of the cone, $theta_("max")$. Incorporating the #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-0c4f565ef8ce03ec.svg",4.333,2.176,0.338,"sine theta") term from the measure on the unit sphere from Equation (#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Working_with_Radiometric_Integrals.html#eq:sintheta-dtheta-dphi")[4.8]), we have
][
有时需要在一个圆锥方向范围内均匀采样射线。这一分布在 $(theta,phi.alt)$ 上可分离，且 $p(phi.alt)=1/(2 pi)$。因此，只需推导如何采样不超过圆锥最大角度 $theta_("max")$ 的 $theta$。计入公式 #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Working_with_Radiometric_Integrals.html#eq:sintheta-dtheta-dphi")[(4.8)] 中单位球面测度的 $sin theta$ 因子，可得
]

]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-6d0c24c1ebc8022b.svg",20.358,9.843,4.338,"StartLayout 1st Row 1st Column 1 2nd Column equals c integral Subscript 0 Superscript theta Subscript normal m normal a normal x Baseline Baseline sine theta normal d theta Subscript Baseline 2nd Row 1st Column Blank 2nd Column equals c left-parenthesis 1 minus cosine theta Subscript normal m normal a normal x Baseline right-parenthesis period EndLayout", display: true)]

#parec[
So #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-97dad6a71d216c50.svg",26.428,2.843,0.838,"p left-parenthesis theta right-parenthesis equals sine theta slash left-parenthesis 1 minus cosine theta Subscript normal m normal a normal x Baseline right-parenthesis") and #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-3a9557b7d470925e.svg",27.91,2.843,0.838,"p left-parenthesis omega right-parenthesis equals 1 slash left-parenthesis 2 pi left-parenthesis 1 minus cosine theta Subscript normal m normal a normal x Baseline right-parenthesis right-parenthesis").
][
所以 $p(theta)=frac(sin theta,1-cos theta_("max"))$，而 $p(omega)=1/(2 pi (1-cos theta_("max")))$。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-41")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-40>)[↑] #link(<fragment-SamplingInlineFunctions-42>)[↓]] <fragment-SamplingInlineFunctions-41>

#block(breakable: false)[
```cpp
Float UniformConePDF(Float cosThetaMax) {
    return 1 / (2 * Pi * (1 - cosThetaMax));
}
```
]

#metadata(none) <UniformConePDF>

#parec[
The PDF can be integrated to find the CDF and the sampling technique for $theta$ follows:
][
对 PDF 积分可得 CDF，进而得到 $theta$ 的采样方法：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-bc015d2a6f034d6c.svg",27.327,2.843,0.838,"cosine theta equals left-parenthesis 1 minus xi Subscript Baseline right-parenthesis plus xi Subscript Baseline cosine theta Subscript normal m normal a normal x Baseline period", display: true)]

#parec[
The following code samples a canonical cone around the $(0,0,1)$ axis; the sample can be transformed to cones with other orientations using the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Applying_Transformations.html#Frame")[`Frame`] class.
][
下面的代码采样以 $(0,0,1)$ 轴为中心的标准圆锥；利用 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Applying_Transformations.html#Frame")[`Frame`] 类，可以把样本变换到其他朝向的圆锥。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SamplingInlineFunctions-42")[#raw("<<Sampling Inline Functions>>+=")] #link(<fragment-SamplingInlineFunctions-41>)[↑]] <fragment-SamplingInlineFunctions-42>

#block(breakable: false)[
```cpp
Vector3f SampleUniformCone(Point2f u, Float cosThetaMax) {
    Float cosTheta = (1 - u[0]) + u[0] * cosThetaMax;
    Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
    Float phi = u[1] * 2 * Pi;
    return SphericalDirection(sinTheta, cosTheta, phi);
}
```
]

#metadata(none) <SampleUniformCone>

#parec[
The inversion function, `InvertUniformConeSample()`, is not included here.
][
逆采样函数 `InvertUniformConeSample()` 不在这里列出。
]

#metadata(none) <InvertUniformConeSample>

#block(breakable: false)[
=== #ez_caption[Piecewise-Constant 2D Distributions][二维分段常数分布] <piecewise-constant-2d>

#parec[
Building on the approach for sampling piecewise-constant 1D distributions in Section #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#sec:piecewise-constant-1d")[A.4.7], we can apply the marginal-conditional approach to sample from piecewise-constant 2D distributions. We will consider the case of a 2D function defined over a user-specified domain by a 2D array of $n_u times n_v$ sample values. This case is particularly useful for generating samples from distributions defined by image maps and environment maps.
][
基于第 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#sec:piecewise-constant-1d")[A.4.7] 节的一维分段常数分布采样方法，可以使用边缘—条件方法采样二维分段常数分布。这里考虑用一个含 $n_u times n_v$ 个样本值的二维数组，在用户指定的定义域上定义二维函数。这种情形尤其适合从纹理图像和环境贴图所定义的分布生成样本。
]

]

#parec[
Consider a 2D function $f(u,v)$ defined by a set of $n_u times n_v$ values #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-a32e07ae0aa8b201.svg",7.39,3.009,1.005,"f left-bracket u Subscript i Baseline comma v Subscript j Baseline right-bracket") where #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-19000ffff6fb6fab.svg",20.593,2.843,0.838,"u Subscript i Baseline element-of left-bracket 0 comma 1 comma ellipsis comma n Subscript u Baseline minus 1 right-bracket"), #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-b0c16f3330b7ed75.svg",19.971,3.009,1.005,"v Subscript j Baseline element-of left-bracket 0 comma 1 comma ellipsis comma n Subscript v Baseline minus 1 right-bracket"), and #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-a32e07ae0aa8b201.svg",7.39,3.009,1.005,"f left-bracket u Subscript i Baseline comma v Subscript j Baseline right-bracket") gives the constant value of $f$ over the range #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-165f8c98eca6d398.svg",37.789,2.843,0.838,"left-bracket i slash n Subscript u Baseline comma left-parenthesis i plus 1 right-parenthesis slash n Subscript u Baseline right-parenthesis times left-bracket j slash n Subscript v Baseline comma left-parenthesis j plus 1 right-parenthesis slash n Subscript v Baseline right-parenthesis"). Given continuous values #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-a2d81c2113b35c8c.svg",5.301,2.843,0.838,"left-parenthesis u comma v right-parenthesis"), we will use #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-2ff713b16b3c5bb7.svg",5.301,2.843,0.838,"left-parenthesis u overTilde comma v overTilde right-parenthesis") to denote the corresponding discrete #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-632d601fa86cea1e.svg",6.623,3.009,1.005,"left-parenthesis u Subscript i Baseline comma v Subscript j Baseline right-parenthesis") indices, with #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-c0ba7ceabdc9d9c7.svg",10.39,2.843,0.838,"u overTilde equals left floor n Subscript u Baseline u right floor") and #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-b439c61c2431e2a4.svg",9.843,2.843,0.838,"v overTilde equals left floor n Subscript v Baseline v right floor") so that #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-9919f938a399e4c8.svg",15.75,2.843,0.838,"f left-parenthesis u comma v right-parenthesis equals f left-bracket u overTilde comma v overTilde right-bracket").
][
考虑二维函数 $f(u,v)$，由 $n_u times n_v$ 个值 $f[u_i,v_j]$ 定义。其中 $u_i in {0,1,dots,n_u-1}$、$v_j in {0,1,dots,n_v-1}$ 是整数索引，$f[u_i,v_j]$ 给出 $f$ 在 $lr([i/n_u,(i+1)/n_u)) times lr([j/n_v,(j+1)/n_v))$ 上的常数值。对于连续坐标 $(u,v)$，用 $(tilde(u),tilde(v))$ 表示相应的离散索引：$tilde(u)=floor(n_u u)$、$tilde(v)=floor(n_v v)$，于是 $f(u,v)=f[tilde(u),tilde(v)]$。
]

#parec[
Integrals of $f$ are sums of #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-a32e07ae0aa8b201.svg",7.39,3.009,1.005,"f left-bracket u Subscript i Baseline comma v Subscript j Baseline right-bracket"), so that, for example, the integral of $f$ over the domain is
][
$f$ 的积分可以表示为 $f[u_i,v_j]$ 的加权和。例如，它在整个定义域上的积分为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-5a7151cee1b7d3c5.svg",48.082,7.676,3.338,"upper I Subscript f Baseline equals integral integral f left-parenthesis u comma v right-parenthesis normal d u normal d v equals StartFraction 1 Over n Subscript u Baseline n Subscript v Baseline EndFraction sigma-summation Underscript i equals 0 Overscript n Subscript u Baseline minus 1 Endscripts sigma-summation Underscript j equals 0 Overscript n Subscript v Baseline minus 1 Endscripts f left-bracket u Subscript i Baseline comma v Subscript j Baseline right-bracket period", display: true)]

#parec[
Using the definition of the PDF and the integral of $f$, we can find $f$’s PDF,
][
利用 PDF 的定义与 $f$ 的积分，可得 $f$ 的 PDF：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-34de366498ef94a1.svg",61.513,7.343,3.505,"p left-parenthesis u comma v right-parenthesis equals StartFraction f left-parenthesis u comma v right-parenthesis Over integral integral f left-parenthesis u comma v right-parenthesis normal d u normal d v EndFraction equals StartFraction f left-bracket u overTilde comma v overTilde right-bracket Over 1 slash left-parenthesis n Subscript u Baseline n Subscript v Baseline right-parenthesis sigma-summation Underscript i equals 0 Overscript n Subscript u Baseline minus 1 Endscripts sigma-summation Underscript j equals 0 Overscript n Subscript v Baseline minus 1 Endscripts f left-bracket u Subscript i Baseline comma v Subscript j Baseline right-bracket EndFraction period", display: true)]

#parec[
Recalling Equation (#link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#eq:2d-marginal-density")[2.24]), the marginal density #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-a8d9adb1383b5e14.svg",4.179,2.843,0.838,"p left-parenthesis v right-parenthesis") can be computed as a sum of #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-a32e07ae0aa8b201.svg",7.39,3.009,1.005,"f left-bracket u Subscript i Baseline comma v Subscript j Baseline right-bracket") values
][
回忆公式 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#eq:2d-marginal-density")[(2.24)]，边缘密度 $p(v)$ 可以通过对 $f[u_i,v_j]$ 求和来计算：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-557fe096cd971819.svg",44.961,6.843,2.505,"p left-parenthesis v right-parenthesis equals integral p left-parenthesis u comma v right-parenthesis normal d u equals StartFraction left-parenthesis 1 slash n Subscript u Baseline right-parenthesis sigma-summation Underscript i equals 0 Overscript n Subscript u Baseline minus 1 Endscripts f left-bracket u Subscript i Baseline comma v overTilde right-bracket Over upper I Subscript f Baseline EndFraction period", display: true)] <2d-discrete-marginal-density>

#parec[
Because this function only depends on $tilde(v)$, it is thus itself a piecewise-constant 1D function, $p[tilde(v)]$, defined by $n_v$ values. The 1D sampling machinery from Section #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#sec:piecewise-constant-1d")[A.4.7] can be applied to sampling from its distribution.
][
这个函数仅取决于 $tilde(v)$，因此它本身也是由 $n_v$ 个值定义的一维分段常数函数 $p[tilde(v)]$。可以直接用第 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#sec:piecewise-constant-1d")[A.4.7] 节的一维方法对其分布采样。
]

#parec[
Given a $v$ sample, the conditional density $p(u | v)$ is then
][
给定 $v$ 样本，条件密度 $p(u | v)$ 为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-db9e575267ed4501.svg",30.535,6.509,2.671,"p left-parenthesis u vertical-bar v right-parenthesis equals StartFraction p left-parenthesis u comma v right-parenthesis Over p left-parenthesis v right-parenthesis EndFraction equals StartFraction f left-bracket u overTilde comma v overTilde right-bracket slash upper I Subscript f Baseline Over p left-bracket v overTilde right-bracket EndFraction period", display: true)] <2d-discrete-conditional-density>

#parec[
Note that, given a particular value of $tilde(v)$, $p[tilde(u)|tilde(v)]$ is a piecewise-constant 1D function of $tilde(u)$ that can be sampled with the usual 1D approach. There are $n_v$ such distinct 1D conditional densities, one for each possible value of $tilde(v)$.
][
注意，对于特定的 $tilde(v)$，$p[tilde(u)|tilde(v)]$ 是关于 $tilde(u)$ 的一维分段常数函数，可按通常的一维方法采样。共有 $n_v$ 个不同的一维条件密度，每个可能的 $tilde(v)$ 对应一个。
]

#parec[
Putting this all together, the `PiecewiseConstant2D` class provides functionality similar to #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`], except that it generates samples from piecewise-constant 2D distributions.
][
综合以上方法，`PiecewiseConstant2D` 类提供与 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] 类似的功能，不过生成的是二维分段常数分布的样本。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DDefinition-0")[#raw("<<PiecewiseConstant2D Definition>>=")]] <fragment-PiecewiseConstant2DDefinition-0>

#block(breakable: false)[
```cpp
class PiecewiseConstant2D {
  public:
    <<PiecewiseConstant2D Public Methods>>
  private:
    <<PiecewiseConstant2D Private Members>>
};
```
]

#metadata(none) <PiecewiseConstant2D>

#parec[
Its constructor has two tasks. First, it computes a 1D conditional sampling density $p[tilde(u)|tilde(v)]$ for each of the $n_v$ individual $tilde(v)$ values using @eqt:2d-discrete-conditional-density . It then computes the marginal sampling density $p[tilde(v)]$ with @eqt:2d-discrete-marginal-density . (`PiecewiseConstant2D` provides a variety of additional constructors, not included here, including ones that take an #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#Array2D")[`Array2D`] to specify the values. See the `pbrt` source code for details.)
][
它的构造函数有两项任务。首先，对每个 $tilde(v)$，用 @eqt:2d-discrete-conditional-density 计算一维条件采样密度 $p[tilde(u)|tilde(v)]$，共 $n_v$ 个；然后用 @eqt:2d-discrete-marginal-density 计算边缘采样密度 $p[tilde(v)]$。`PiecewiseConstant2D` 还提供了多种未在此列出的构造函数，包括用 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#Array2D")[`Array2D`] 指定函数值的形式，详见 `pbrt` 源码。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPublicMethods-0")[#raw("<<PiecewiseConstant2D Public Methods>>=")] #link(<fragment-PiecewiseConstant2DPublicMethods-1>)[↓]] <fragment-PiecewiseConstant2DPublicMethods-0>

#block(breakable: false)[
```cpp
PiecewiseConstant2D(pstd::span<const Float> func, int nu, int nv,
                    Bounds2f domain, Allocator alloc = {})
    : domain(domain), pConditionalV(alloc), pMarginal(alloc) {
    for (int v = 0; v < nv; ++v)
        <<Compute conditional sampling distribution for ṽ>>
    <<Compute marginal sampling distribution p[ṽ]>>
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPrivateMembers-0")[#raw("<<PiecewiseConstant2D Private Members>>=")] #link(<fragment-PiecewiseConstant2DPrivateMembers-1>)[↓]] <fragment-PiecewiseConstant2DPrivateMembers-0>

#block(breakable: false)[
```cpp
Bounds2f domain;
```
]

#metadata(none) <PiecewiseConstant2D::domain>

#parec[
#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] can directly compute the $p[tilde(u)|tilde(v)]$ distributions from each of the $n_v$ rows of $n_u$ function values, since they are laid out linearly in memory. The $I_f$ and $p[tilde(v)]$ terms from @eqt:2d-discrete-conditional-density do not need to be included in the values passed to #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] since they have the same value for all the $n_u$ values and are thus just a constant scale that does not affect the normalized distribution that #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] computes.
][
$n_v$ 行函数值各有 $n_u$ 个元素，且每行在内存中连续存放，因此 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] 可直接由每行数据计算 $p[tilde(u)|tilde(v)]$。传入的值无需包含 @eqt:2d-discrete-conditional-density 中的 $I_f$ 与 $p[tilde(v)]$ 项，因为对于一行的全部 $n_u$ 个值，这些项都是相同的常数缩放，不影响 `PiecewiseConstant1D` 最终计算出的归一化分布。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Computeconditionalsamplingdistributionfortildev-0")[#raw("<<Compute conditional sampling distribution for ṽ>>=")]] <fragment-Computeconditionalsamplingdistributionfortildev-0>

#block(breakable: false)[
```cpp
pConditionalV.emplace_back(func.subspan(v * nu, nu), domain.pMin[0],
                           domain.pMax[0], alloc);
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPrivateMembers-1")[#raw("<<PiecewiseConstant2D Private Members>>+=")] #link(<fragment-PiecewiseConstant2DPrivateMembers-0>)[↑] #link(<fragment-PiecewiseConstant2DPrivateMembers-2>)[↓]] <fragment-PiecewiseConstant2DPrivateMembers-1>

#block(breakable: false)[
```cpp
pstd::vector<PiecewiseConstant1D> pConditionalV;
```
]

#metadata(none) <PiecewiseConstant2D::pConditionalV>

#parec[
Given the conditional densities for each $tilde(v)$ value, we can find the 1D marginal density for sampling each one, $p[tilde(v)]$. Because the `PiecewiseConstant1D` class has a method that provides the integral of its function, it is just necessary to copy these values to the `marginalFunc` buffer so they are stored linearly in memory for the `PiecewiseConstant1D` constructor.
][
给定各个 $tilde(v)$ 的条件密度后，可以求得用于采样这些行的一维边缘密度 $p[tilde(v)]$。`PiecewiseConstant1D` 已有返回函数积分的方法，因此只需把各行积分复制到 `marginalFunc` 缓冲区，供 `PiecewiseConstant1D` 构造函数按连续内存读取。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Computemarginalsamplingdistributionptildev-0")[#raw("<<Compute marginal sampling distribution p[ṽ]>>=")]] <fragment-Computemarginalsamplingdistributionptildev-0>

#block(breakable: false)[
```cpp
pstd::vector<Float> marginalFunc;
for (int v = 0; v < nv; ++v)
    marginalFunc.push_back(pConditionalV[v].Integral());
pMarginal = PiecewiseConstant1D(marginalFunc, domain.pMin[1],
                                domain.pMax[1], alloc);
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPrivateMembers-2")[#raw("<<PiecewiseConstant2D Private Members>>+=")] #link(<fragment-PiecewiseConstant2DPrivateMembers-1>)[↑]] <fragment-PiecewiseConstant2DPrivateMembers-2>

#block(breakable: false)[
```cpp
PiecewiseConstant1D pMarginal;
```
]

#metadata(none) <PiecewiseConstant2D::pMarginal>

#parec[
The integral of the function over the $[0,1]^2$ domain is made available via the `Integral()` method. Because the marginal distribution is the integral of one dimension, its integral gives the function’s full integral.
][
`Integral()` 方法提供函数在 $[0,1]^2$ 定义域上的积分。由于边缘分布已经积掉一个维度，再对它积分就得到函数的完整积分。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPublicMethods-1")[#raw("<<PiecewiseConstant2D Public Methods>>+=")] #link(<fragment-PiecewiseConstant2DPublicMethods-0>)[↑] #link(<fragment-PiecewiseConstant2DPublicMethods-2>)[↓]] <fragment-PiecewiseConstant2DPublicMethods-1>

#block(breakable: false)[
```cpp
Float Integral() const { return pMarginal.Integral(); }
```
]

#metadata(none) <PiecewiseConstant2D::Integral>

#parec[
As described previously, in order to sample from the 2D distribution, first a sample is drawn from the $p[tilde(v)]$ marginal distribution in order to find the $v$ coordinate of the sample. The offset of the sampled function value gives the integer $tilde(v)$ value that determines which of the precomputed conditional distributions should be used for sampling the $u$ value. @fig:sample-2d-image illustrates this idea using a low-resolution image as an example.
][
如前所述，二维采样首先从边缘分布 $p[tilde(v)]$ 生成样本，确定 $v$ 坐标。被采样函数值的数组索引给出整数 $tilde(v)$，据此选择预先计算好的条件分布，再采样 $u$。@fig:sample-2d-image 以低分辨率图像为例说明这一过程。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf11.svg", width: 90%), caption: [#ez_caption[The Piecewise-Constant Sampling Distribution for a High-Dynamic-Range Environment Map. (a) The original environment map. (b) A low-resolution version of the marginal density function #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-5a9ae6c34688132f.svg",3.664,2.843,0.838,"p left-bracket ModifyingAbove v With caret right-bracket") and the conditional distributions for rows of the image. First the marginal 1D distribution is used to select a $v$ value, giving a row of the image to sample. Rows with bright pixels are more likely to be sampled. Then, given a row, a value $u$ is sampled from that row’s 1D distribution.][*高动态范围环境贴图的分段常数采样分布。*(a) 原环境贴图。(b) 低分辨率的边缘密度 $p[hat(v)]$ 及各图像行的条件分布。首先用一维边缘分布选择 $v$，确定待采样的图像行；含明亮像素的行更可能被选中。给定行后，再从该行的一维分布采样 $u$。]]) <sample-2d-image>

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPublicMethods-2")[#raw("<<PiecewiseConstant2D Public Methods>>+=")] #link(<fragment-PiecewiseConstant2DPublicMethods-1>)[↑] #link(<fragment-PiecewiseConstant2DPublicMethods-3>)[↓]] <fragment-PiecewiseConstant2DPublicMethods-2>

#block(breakable: false)[
```cpp
Point2f Sample(Point2f u, Float *pdf = nullptr,
               Point2i *offset = nullptr) const {
    Float pdfs[2];
    Point2i uv;
    Float d1 = pMarginal.Sample(u[1], &pdfs[1], &uv[1]);
    Float d0 = pConditionalV[uv[1]].Sample(u[0], &pdfs[0], &uv[0]);
    if (pdf)
        *pdf = pdfs[0] * pdfs[1];
    if (offset)
        *offset = uv;
    return Point2f(d0, d1);
}
```
]

#metadata(none) <PiecewiseConstant2D::Sample>

#parec[
The value of the PDF for a given sample value is computed as the product of the conditional and marginal PDFs for sampling it.
][
给定样本的 PDF 等于生成它时的条件 PDF 与边缘 PDF 的乘积。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-PiecewiseConstant2DPublicMethods-3")[#raw("<<PiecewiseConstant2D Public Methods>>+=")] #link(<fragment-PiecewiseConstant2DPublicMethods-2>)[↑]] <fragment-PiecewiseConstant2DPublicMethods-3>

#block(breakable: false)[
```cpp
Float PDF(Point2f pr) const {
    Point2f p = Point2f(domain.Offset(pr));
    int iu = Clamp(int(p[0] * pConditionalV[0].size()), 0,
                   pConditionalV[0].size() - 1);
    int iv = Clamp(int(p[1] * pMarginal.size()), 0, pMarginal.size() - 1);
    return pConditionalV[iv].func[iu] / pMarginal.Integral();
}
```
]

#metadata(none) <PiecewiseConstant2D::PDF>

#parec[
The `Invert()` method, not included here, inverts the provided sample by inverting the $v$ sample using the marginal distribution and then inverting $u$ via the appropriate conditional distribution.
][
这里未列出的 `Invert()` 方法先用边缘分布反求 $v$ 样本，再用相应条件分布反求 $u$。
]

#metadata(none) <PiecewiseConstant2D::Invert>

#block(breakable: false)[
=== #ez_caption[Windowed Piecewise-Constant 2D Distributions][带窗口的二维分段常数分布] <windowed-piecewise-constant>

#parec[
#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#WindowedPiecewiseConstant2D")[`WindowedPiecewiseConstant2D`] generalizes the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`] class to allow the caller to specify a window that limits the sampling domain to a given rectangular subset of it. (This capability was key for the implementation of the `PortalImageInfiniteLight` in Section #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#sec:portal-image-infinite-light")[12.5.3].) Before going into its implementation, we will start with the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`] class, which provides some capabilities that make it easier to implement. We have encapsulated them in a stand-alone class, as they can be useful in other settings as well.
][
#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#WindowedPiecewiseConstant2D")[`WindowedPiecewiseConstant2D`] 推广了 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`]，允许调用方指定一个窗口，把采样域限制到给定的矩形子区域。这一能力是第 #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#sec:portal-image-infinite-light")[12.5.3] 节 `PortalImageInfiniteLight` 实现的关键。在介绍其实现前，先讨论提供基础能力的 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`] 类。这些能力在其他场合也有用，因此将其封装为独立的类。
]

]

#parec[
In 2D, a _summed-area table_ is a 2D array where each element $(x,y)$ stores a sum of values from another array $a$:
][
二维_积分表_是一个二维数组，其中每个元素 $(x,y)$ 存储另一个数组 $a$ 的如下累加和：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-d1b29eca3cb85300.svg",26.629,8.009,3.671,"s left-parenthesis x comma y right-parenthesis equals sigma-summation Underscript x prime equals 0 Overscript x minus 1 Endscripts sigma-summation Underscript y prime equals 0 Overscript y minus 1 Endscripts a left-parenthesis x prime comma y Superscript prime Baseline right-parenthesis comma", display: true)] <summed-area-table>

#parec[
where here we have used C++’s zero-based array indexing convention.
][
这里采用 C++ 从零开始的数组索引约定。
]

#parec[
Summed-area tables can be used to compute the sum of array values over rectangular regions of the original array in constant time. If the array $a$ is interpreted as samples of a function, a summed-area table can efficiently compute integrals over arbitrary rectangular regions in a similar fashion. (Summed-area tables are therefore sometimes referred to as _integral images_.) They have a straightforward generalization to higher dimensions, though two of them suffice for `pbrt`’s needs.
][
积分表可以在常数时间内求出原数组任意矩形区域的元素和。如果把数组 $a$ 看作函数的样本，也可以用同样的方法高效计算任意矩形区域的积分。因此，积分表有时也称为_积分图像_。它可直接推广到更高维，但二维已经满足 `pbrt` 的需要。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SummedAreaTableDefinition-0")[#raw("<<SummedAreaTable Definition>>=")]] <fragment-SummedAreaTableDefinition-0>

#block(breakable: false)[
```cpp
class SummedAreaTable {
  public:
    <<SummedAreaTable Public Methods>>
  private:
    <<SummedAreaTable Private Methods>>
    <<SummedAreaTable Private Members>>
};
```
]

#metadata(none) <SummedAreaTable>

#parec[
The constructor takes a 2D array of values that are used to initialize its `sum` array, which holds the corresponding sums. The first entry is easy: it is just the $(0,0)$ entry from the provided `values` array.
][
构造函数接收二维数组，用它初始化存储累加和的 `sum` 数组。第一个元素很简单，就是输入 `values` 数组的 $(0,0)$ 元素。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SummedAreaTablePublicMethods-0")[#raw("<<SummedAreaTable Public Methods>>=")] #link(<fragment-SummedAreaTablePublicMethods-1>)[↓]] <fragment-SummedAreaTablePublicMethods-0>

#block(breakable: false)[
```cpp
SummedAreaTable(const Array2D<Float> &values, Allocator alloc = {})
    : sum(values.XSize(), values.YSize(), alloc) {
    sum(0, 0) = values(0, 0);
    <<Compute sums along first row and column>>
    <<Compute sums for the remainder of the entries>>
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SummedAreaTablePrivateMembers-0")[#raw("<<SummedAreaTable Private Members>>=")]] <fragment-SummedAreaTablePrivateMembers-0>

#block(breakable: false)[
```cpp
Array2D<double> sum;
```
]

#metadata(none) <SummedAreaTable::sum>

#parec[
All the remaining entries in `sum` can be computed incrementally. It is easiest to start out by computing sums as $x$ varies with $y=0$ and vice versa.
][
`sum` 的其余元素都能增量计算。最方便的是先计算 $y=0$ 时随 $x$ 变化的累加和，以及 $x=0$ 时随 $y$ 变化的累加和。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Computesumsalongfirstrowandcolumn-0")[#raw("<<Compute sums along first row and column>>=")]] <fragment-Computesumsalongfirstrowandcolumn-0>

#block(breakable: false)[
```cpp
for (int x = 1; x < sum.XSize(); ++x)
    sum(x, 0) = values(x, 0) + sum(x - 1, 0);
for (int y = 1; y < sum.YSize(); ++y)
    sum(0, y) = values(0, y) + sum(0, y - 1);
```
]

#parec[
The remainder of the sums are computed incrementally by adding the corresponding value from the provided array to two of the previous sums and subtracting a third. It is possible to use the definition from @eqt:summed-area-table to verify that this expression gives the desired value, but it can also be understood geometrically; see @fig:sat-previous-sums .
][
其余累加和通过增量方式计算：将输入数组的相应值加到前两个累加和上，再减去第三个。可以用 @eqt:summed-area-table 的定义验证这一表达式，也可以从几何上理解，见 @fig:sat-previous-sums 。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf12.svg", width: 90%), caption: [#ez_caption[Computing a Value in a Summed-Area Table Based on Previous Sums. (a) A starting value for the sum at a location $(x,y)$ (filled circle) is given by the sum at $(x-1,y)$ (shaded region). To this value, we need to add the provided array’s value at $(x,y)$. (b) What is left is the sum of values in the column beneath $(x,y)$ (lighter shaded region); that value can be found by taking the sum at $(x,y-1)$ and subtracting the sum at $(x-1,y-1)$ (darker shaded region).][*用已有累加和计算积分表中的值。*(a) 位置 $(x,y)$（实心圆）处累加和的起始值为 $(x-1,y)$ 处的累加和（阴影区域），还需加上输入数组在 $(x,y)$ 处的值。(b) 剩余部分是 $(x,y)$ 下方这一列的累加和（浅色阴影），可由 $(x,y-1)$ 处的累加和减去 $(x-1,y-1)$ 处的累加和（深色阴影）得到。]]) <sat-previous-sums>

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Computesumsfortheremainderoftheentries-0")[#raw("<<Compute sums for the remainder of the entries>>=")]] <fragment-Computesumsfortheremainderoftheentries-0>

#block(breakable: false)[
```cpp
for (int y = 1; y < sum.YSize(); ++y)
    for (int x = 1; x < sum.XSize(); ++x)
        sum(x, y) = (values(x, y) + sum(x - 1, y) + sum(x, y - 1) -
                     sum(x - 1, y - 1));
```
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf13.svg", width: 90%), caption: [#ez_caption[Interpretation of `sum` Array Values. If the sample array `values` is interpreted as defining a piecewise-constant function over $[0,1]^2$, then the values stored in `sum` represent the sums at the upper-right corner of each piecewise-constant region. The sums along $x=0$ and $y=0$, all of which are 0, are not stored.][*`sum` 数组值的含义。*若把样本数组 `values` 解释为 $[0,1]^2$ 上的分段常数函数，则 `sum` 中的值代表各分段常数区域右上角处的累加和。沿 $x=0$ 和 $y=0$ 的累加和都为 0，不予存储。]]) <sat-sum-value-interpretation>

#parec[
We will find it useful to be able to treat the sum as a continuous function defined over $[0,1]^2$. In doing so, our implementation effectively treats the originally provided array of values as the specification of a piecewise-constant function. Under this interpretation, the stored `sum` values effectively represent the function’s value at the upper corners of the box-shaped regions that the domain has been discretized into. (See @fig:sat-sum-value-interpretation .)
][
把累加和视为定义在 $[0,1]^2$ 上的连续函数会很有用。在这种解释下，输入数组定义的是分段常数函数，而存储的 `sum` 值对应于定义域离散化后各矩形区域右上角处的累加和函数值（见 @fig:sat-sum-value-interpretation ）。
]

#parec[
This `Lookup()` method returns the interpolated sum at the given continuous coordinate values.
][
`Lookup()` 返回给定连续坐标处插值得到的累加和。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SummedAreaTablePrivateMethods-0")[#raw("<<SummedAreaTable Private Methods>>=")] #link(<fragment-SummedAreaTablePrivateMethods-1>)[↓]] <fragment-SummedAreaTablePrivateMethods-0>

#block(breakable: false)[
```cpp
Float Lookup(Float x, Float y) const {
    <<Rescale (x, y) to table resolution and compute integer coordinates>>
    <<Bilinearly interpolate between surrounding table values>>
}
```
]

#metadata(none) <SummedAreaTable::Lookup>

#parec[
It is more convenient to work with coordinates that are with respect to the array’s dimensions and so this method starts by scaling the provided coordinates accordingly. Note that an offset of $0.5$ is not included in this remapping, as is done when indexing pixel values (recall the discussion of this topic in Section #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Theory.html#sec:pixel-concepts")[8.1.4]); this is due to the fact that `sum` defines function values at the upper corners of the discretized regions rather than at their center.
][
使用相对于数组尺寸的坐标更方便，因此先按数组尺寸缩放输入坐标。注意，此处不像索引像素值那样加入 $0.5$ 偏移量（回忆第 #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Theory.html#sec:pixel-concepts")[8.1.4] 节的讨论），因为 `sum` 给出的是离散区域右上角而非中心处的函数值。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Rescalexytotableresolutionandcomputeintegercoordinates-0")[#raw("<<Rescale (x, y) to table resolution and compute integer coordinates>>=")]] <fragment-Rescalexytotableresolutionandcomputeintegercoordinates-0>

#block(breakable: false)[
```cpp
x *= sum.XSize();
y *= sum.YSize();
int x0 = (int)x, y0 = (int)y;
```
]

#parec[
Bilinear interpolation of the four values surrounding the lookup point proceeds as usual, using `LookupInt()` to look up values of the sum at provided integer coordinates.
][
然后按通常方式对查询点周围的四个值作双线性插值，并用 `LookupInt()` 查询整数坐标处的累加和。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Bilinearlyinterpolatebetweensurroundingtablevalues-0")[#raw("<<Bilinearly interpolate between surrounding table values>>=")]] <fragment-Bilinearlyinterpolatebetweensurroundingtablevalues-0>

#block(breakable: false)[
```cpp
Float v00 = LookupInt(x0, y0), v10 = LookupInt(x0 + 1, y0);
Float v01 = LookupInt(x0, y0 + 1), v11 = LookupInt(x0 + 1, y0 + 1);
Float dx = x - int(x), dy = y - int(y);
return (1 - dx) * (1 - dy) * v00 + (1 - dx) * dy * v01 +
            dx  * (1 - dy) * v10 +      dx *  dy * v11;
```
]

#parec[
`LookupInt()` returns the value of the sum for provided integer coordinates. In particular, it is responsible for handling the details related to the `sum` array storing the sum at the upper corners of the domain strata.
][
`LookupInt()` 返回给定整数坐标处的累加和。尤其是，它负责处理 `sum` 存储的是各分层区域右上角处累加和这一细节。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SummedAreaTablePrivateMethods-1")[#raw("<<SummedAreaTable Private Methods>>+=")] #link(<fragment-SummedAreaTablePrivateMethods-0>)[↑]] <fragment-SummedAreaTablePrivateMethods-1>

#block(breakable: false)[
```cpp
Float LookupInt(int x, int y) const {
    <<Return zero at lower boundaries>>
    <<Reindex (x, y) and return actual stored value>>
}
```
]

#metadata(none) <SummedAreaTable::LookupInt>

#parec[
If either coordinate is zero-valued, the lookup point is along one of the lower edges of the domain (or is at the origin). In this case, a sum value of 0 is returned.
][
只要有一个坐标为零，查询点就位于定义域的一条下界边上，或位于原点。此时返回累加和 0。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Returnzeroatlowerboundaries-0")[#raw("<<Return zero at lower boundaries>>=")]] <fragment-Returnzeroatlowerboundaries-0>

#block(breakable: false)[
```cpp
if (x == 0 || y == 0)
    return 0;
```
]

#parec[
Otherwise, one is subtracted from each coordinate so that indexing into the `sum` array accounts for the zero sums at the lower edges not being stored in `sum`.
][
否则，对两个坐标各减 1，再索引 `sum`，以补偿定义域下界边上的零累加和没有存储在数组中的事实。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Reindexxyandreturnactualstoredvalue-0")[#raw("<<Reindex (x, y) and return actual stored value>>=")]] <fragment-Reindexxyandreturnactualstoredvalue-0>

#block(breakable: false)[
```cpp
x = std::min(x - 1, sum.XSize() - 1);
y = std::min(y - 1, sum.YSize() - 1);
return sum(x, y);
```
]

#parec[
Summed-area tables compute sums and integrals over arbitrary rectangular regions in a similar way to how the interior sum values were originally initialized. Here it is also possible to verify this computation algebraically, but the geometric interpretation may be more intuitive; see @fig:sat-arbitrary-rect .
][
用积分表计算任意矩形区域的累加和及积分，与初始化内部元素时采用的方法类似。同样可以从代数上验证，也可以借助更直观的几何解释，见 @fig:sat-arbitrary-rect 。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf14.png", width: 90%), caption: [#ez_caption[Computing the Sum of an Arbitrary Rectangular Region. Given two points $(x_0,y_0)$ and $(x_1,y_1)$ representing the corners of a rectangular region, the sum of values inside the rectangular region can be found in terms of sums of subregions. (a) The sum at $(x_1,y_1)$ gives the desired result and then much more. (b) Subtracting the $(x_0,y_1)$ sum eliminates some of the excess, leaving the region underneath the region to be removed. (c) Subtracting the $(x_1,y_0)$ sum takes care of the excess and then some; the shaded region has now been removed twice. (d) Adding the shaded region’s sum, which is the sum at $(x_0,y_0)$, rectifies the excess subtraction and leaves us with the desired result.][*计算任意矩形区域的累加和。*给定矩形两角 $(x_0,y_0)$ 和 $(x_1,y_1)$，可以用子区域的累加和求出矩形内部的总和。(a) $(x_1,y_1)$ 处的累加和包含目标区域，也包含大量多余区域。(b) 减去 $(x_0,y_1)$ 处的累加和，去掉一部分多余区域，留下目标区域下方仍待移除的部分。(c) 减去 $(x_1,y_0)$ 处的累加和后，多余区域已被去除，但阴影部分被减了两次。(d) 加回阴影区域的累加和，即 $(x_0,y_0)$ 处的值，补偿多减的一次，得到所需结果。]]) <sat-arbitrary-rect>

#parec[
The `SummedAreaTable` class provides this capability through its `Integral()` method, which returns the integral of the piecewise-constant function over a 2D bounding box. Here, the sum of function values over the region is converted to an integral by dividing by the size of the function strata over the domain. We have used double precision here to compute the final sum in order to improve its accuracy: especially if there are thousands of values in each dimension, the sums may have large magnitudes and thus taking their differences can lead to catastrophic cancellation.#footnote[Editorial note: The source says to divide by the strata’s “size.” The code divides by `sum.XSize() * sum.YSize()`, which multiplies the sum by each cell’s area in the unit domain.]
][
`SummedAreaTable` 通过 `Integral()` 方法提供这一能力，返回分段常数函数在二维包围范围内的积分。代码将区域内的函数值累加和除以定义域的离散网格总数，以转换成积分。#footnote[校注：原文称为除以分层的“大小”；代码实际除以 `sum.XSize() * sum.YSize()`，即乘上单位定义域内每格的面积。] 这里使用双精度计算最后的和，以提高精度；尤其当每个维度有数千个值时，累加和可能很大，相减就可能发生灾难性消减。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-SummedAreaTablePublicMethods-1")[#raw("<<SummedAreaTable Public Methods>>+=")] #link(<fragment-SummedAreaTablePublicMethods-0>)[↑]] <fragment-SummedAreaTablePublicMethods-1>

#block(breakable: false)[
```cpp
Float Integral(Bounds2f extent) const {
    double s = (((double)Lookup(extent.pMax.x, extent.pMax.y) -
                 (double)Lookup(extent.pMin.x, extent.pMax.y)) +
                ((double)Lookup(extent.pMin.x, extent.pMin.y) -
                 (double)Lookup(extent.pMax.x, extent.pMin.y)));
    return std::max<Float>(s  / (sum.XSize() * sum.YSize()), 0);
}
```
]

#metadata(none) <SummedAreaTable::Integral>

#parec[
Given #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`]’s capability of efficiently evaluating integrals over rectangular regions of a piecewise-constant function’s domain, the `WindowedPiecewiseConstant2D` class is able to provide sampling and PDF evaluation functions that operate over arbitrary caller-specified regions.
][
借助 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`] 高效计算分段常数函数任意矩形区域积分的能力，`WindowedPiecewiseConstant2D` 可以在调用方指定的任意区域内提供采样和 PDF 求值。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DDefinition-0")[#raw("<<WindowedPiecewiseConstant2D Definition>>=")]] <fragment-WindowedPiecewiseConstant2DDefinition-0>

#block(breakable: false)[
```cpp
class WindowedPiecewiseConstant2D {
  public:
    <<WindowedPiecewiseConstant2D Public Methods>>
  private:
    <<WindowedPiecewiseConstant2D Private Methods>>
    <<WindowedPiecewiseConstant2D Private Members>>
};
```
]

#metadata(none) <WindowedPiecewiseConstant2D>

#parec[
The constructor both copies the provided function values and initializes a summed-area table with them.
][
构造函数复制输入函数值，并用这些值初始化积分表。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DPublicMethods-0")[#raw("<<WindowedPiecewiseConstant2D Public Methods>>=")] #link(<fragment-WindowedPiecewiseConstant2DPublicMethods-1>)[↓]] <fragment-WindowedPiecewiseConstant2DPublicMethods-0>

#block(breakable: false)[
```cpp
WindowedPiecewiseConstant2D(Array2D<Float> f, Allocator alloc = {})
    : sat(f, alloc), func(f, alloc) {}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DPrivateMembers-0")[#raw("<<WindowedPiecewiseConstant2D Private Members>>=")]] <fragment-WindowedPiecewiseConstant2DPrivateMembers-0>

#block(breakable: false)[
```cpp
SummedAreaTable sat;
Array2D<Float> func;
```
]

#metadata(none) <WindowedPiecewiseConstant2D::sat>

#metadata(none) <WindowedPiecewiseConstant2D::func>

#parec[
With the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`] in hand, it is now possible to bring the pieces together to implement the `Sample()` method. Because it is possible that there is no valid sample inside the specified bounds (e.g., if the function’s value is zero), an optional return value is used in order to be able to indicate such cases.
][
有了 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`]，就可以组合前面的部分来实现 `Sample()`。指定边界内可能不存在有效样本，例如函数恒为零时，因此使用可选返回值来表示这种情况。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DPublicMethods-1")[#raw("<<WindowedPiecewiseConstant2D Public Methods>>+=")] #link(<fragment-WindowedPiecewiseConstant2DPublicMethods-0>)[↑] #link(<fragment-WindowedPiecewiseConstant2DPublicMethods-2>)[↓]] <fragment-WindowedPiecewiseConstant2DPublicMethods-1>

#block(breakable: false)[
```cpp
pstd::optional<Point2f> Sample(Point2f u, Bounds2f b, Float *pdf) const {
    <<Handle zero-valued function for windowed sampling>>
    <<Define lambda function Px for marginal cumulative distribution>>
    <<Sample marginal windowed function in x>>
    <<Sample conditional windowed function in y>>
    <<Compute PDF and return point sampled from windowed function>>
}
```
]

#metadata(none) <WindowedPiecewiseConstant2D::Sample>

#parec[
The first step is to check whether the function’s integral is zero over the specified bounds. This may happen due to a degenerate `Bounds2f` or due to a plain old zero-valued function over the corresponding part of its domain. In this case, it is not possible to return a valid sample.
][
第一步检查函数在指定边界内的积分是否为零。可能是 `Bounds2f` 退化，也可能只是函数在该区域内恒为零。此时无法返回有效样本。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Handlezero-valuedfunctionforwindowedsampling-0")[#raw("<<Handle zero-valued function for windowed sampling>>=")]] <fragment-Handlezero-valuedfunctionforwindowedsampling-0>

#block(breakable: false)[
```cpp
if (sat.Integral(b) == 0)
    return {};
```
]

#parec[
As discussed in Section #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-multidimensional-sampling")[2.4.2], multidimensional distributions can be sampled by first integrating out all of the dimensions but one, sampling the resulting function, and then using that sample value in sampling the corresponding conditional distribution. `WindowedPiecewiseConstant2D` applies that very same idea, taking advantage of the fact that the summed-area table can efficiently evaluate the necessary integrals as needed.
][
如第 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Transforming_between_Distributions.html#sec:mc-multidimensional-sampling")[2.4.2] 节所述，多维采样可以先积分消去除一个维度以外的所有维度，对所得函数采样，再利用该样本采样相应的条件分布。`WindowedPiecewiseConstant2D` 使用完全相同的思想，并利用积分表按需高效计算必要的积分。
]

#parec[
For a 2D continuous function $f(x,y)$ defined over a rectangular domain from $(x_0,y_0)$ to $(x_1,y_1)$, the marginal distribution in $x$ is defined by
][
对于定义在 $(x_0,y_0)$ 到 $(x_1,y_1)$ 的矩形区域上的二维连续函数 $f(x,y)$，$x$ 的边缘分布定义为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-08563a8b311ccbee.svg",32.732,8.176,3.505,"p left-parenthesis x right-parenthesis equals StartFraction integral Subscript y 0 Superscript y 1 Baseline f left-parenthesis x comma y Superscript prime Baseline right-parenthesis normal d y Superscript prime Baseline Over integral Subscript x 0 Superscript x 1 Baseline integral Subscript y 0 Superscript y 1 Baseline f left-parenthesis x prime comma y Superscript prime Baseline right-parenthesis normal d x prime normal d y Superscript prime Baseline EndFraction comma", display: true)]

#parec[
and the marginal’s cumulative distribution is
][
其边缘累积分布为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-15e0b3ac07cbf86c.svg",33.241,8.176,3.505,"upper P left-parenthesis x right-parenthesis equals StartFraction integral Subscript x 0 Superscript x Baseline integral Subscript y 0 Superscript y 1 Baseline f left-parenthesis x prime comma y Superscript prime Baseline right-parenthesis normal d x prime normal d y Superscript prime Baseline Over integral Subscript x 0 Superscript x 1 Baseline integral Subscript y 0 Superscript y 1 Baseline f left-parenthesis x prime comma y Superscript prime Baseline right-parenthesis normal d x prime normal d y Superscript prime Baseline EndFraction period", display: true)]

#parec[
The integrals in both the numerator and denominator of $P(x)$ can be evaluated using a summed-area table. The following lambda function evaluates $P(x)$, using a cached normalization factor for the denominator in `bInt` to improve performance, as it will be necessary to repeatedly evaluate `Px` in order to sample from the distribution.
][
$P(x)$ 分子和分母中的积分都可以用积分表求值。下面的 lambda 函数计算 $P(x)$，并利用 `bInt` 中缓存的分母归一化因子提高性能，因为采样过程需要反复计算 `Px`。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-DefinelambdafunctionmonoPxformarginalcumulativedistribution-0")[#raw("<<Define lambda function Px for marginal cumulative distribution>>=")]] <fragment-DefinelambdafunctionmonoPxformarginalcumulativedistribution-0>

#block(breakable: false)[
```cpp
Float bInt = sat.Integral(b);
auto Px = [&, this](Float x) -> Float {
    Bounds2f bx = b;
    bx.pMax.x = x;
    return sat.Integral(bx) / bInt;
};
```
]

#parec[
Sampling is performed using a separate utility method, `SampleBisection()`, that will also be useful for sampling the conditional density in $y$.
][
采样由独立的辅助方法 `SampleBisection()` 完成；后面对 $y$ 的条件密度采样时也会用到它。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Samplemarginalwindowedfunctioninx-0")[#raw("<<Sample marginal windowed function in x>>=")]] <fragment-Samplemarginalwindowedfunctioninx-0>

#block(breakable: false)[
```cpp
Point2f p;
p.x = SampleBisection(Px, u[0], b.pMin.x, b.pMax.x, func.XSize());
```
]

#parec[
`SampleBisection()` draws a sample from the density described by the provided CDF `P` by applying the bisection method to solve #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-dac2b000ee96a905.svg",9.32,2.843,0.838,"u equals upper P left-parenthesis x right-parenthesis") for $x$ over a specified range #source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-283b1fc27b65766c.svg",10.421,3.676,1.171,"left-bracket monospace m monospace i monospace n monospace comma monospace m monospace a monospace x monospace right-bracket"). (It expects $P(x)$ to have the value 0 at `min` and 1 at `max`.) This function has the built-in assumption that the CDF is piecewise-linear over $n$ equal-sized segments over $[0,1]$. This fits #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`] perfectly, though it means that `SampleBisection()` would need modification to be used in other contexts.
][
`SampleBisection()` 根据给定 CDF `P` 所描述的密度生成样本：在指定区间 `[min,max]` 内，用二分法对 $x$ 求解 $u=P(x)$。它要求 $P(x)$ 在 `min` 处为 0，在 `max` 处为 1。该函数内置了一个假设：CDF 在 $[0,1]$ 上分成 $n$ 个等长区间，并在每段内线性变化。这恰好适合 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`]，但用于其他情形时可能需要修改。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DPrivateMethods-0")[#raw("<<WindowedPiecewiseConstant2D Private Methods>>=")] #link(<fragment-WindowedPiecewiseConstant2DPrivateMethods-1>)[↓]] <fragment-WindowedPiecewiseConstant2DPrivateMethods-0>

#block(breakable: false)[
```cpp
template <typename CDF>
static Float SampleBisection(CDF P, Float u, Float min, Float max, int n) {
    <<Apply bisection to bracket u>>
    <<Find sample by interpolating between min and max>>
}
```
]

#metadata(none) <WindowedPiecewiseConstant2D::SampleBisection>

#parec[
The initial `min` and `max` values bracket the solution. Therefore, bisection can proceed by successively evaluating $P$ at their midpoint and then updating one or the other of them to maintain the bracket. This process continues until both endpoints lie inside one of the function discretization strata of width $1/n$.
][
初始 `min` 和 `max` 夹住了所求解。因此，二分过程不断在二者中点计算 $P$，再更新其中一个端点，以保持对解的夹逼，直到两个端点落入同一个宽度为 $1/n$ 的函数离散区间。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Applybisectiontobracketmonou-0")[#raw("<<Apply bisection to bracket u>>=")]] <fragment-Applybisectiontobracketmonou-0>

#block(breakable: false)[
```cpp
while (pstd::ceil(n * max) - pstd::floor(n * min) > 1) {
    Float mid = (min + max) / 2;
    if (P(mid) > u) max = mid;
    else min = mid;
}
```
]

#parec[
Once both endpoints are in the same stratum, it is possible to take advantage of the fact that $P$ is known to be piecewise-linear and to find the value of $x$ in closed form.
][
一旦两端点落入同一分层区间，就可以利用 $P$ 分段线性的已知性质，求出 $x$ 的闭式解。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Findsamplebyinterpolatingbetweenmonominandmonomax-0")[#raw("<<Find sample by interpolating between min and max>>=")]] <fragment-Findsamplebyinterpolatingbetweenmonominandmonomax-0>

#block(breakable: false)[
```cpp
Float t = (u - P(min)) / (P(max) - P(min));
return Clamp(Lerp(t, min, max), min, max);
```
]

#parec[
Given the sample $x$, we now need to draw a sample from the conditional distribution
][
给定样本 $x$ 后，需要从如下条件分布中生成样本：
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-fde3b34d9dace8be.svg",25.768,7.343,3.505,"p left-parenthesis y vertical-bar x right-parenthesis equals StartFraction f left-parenthesis x comma y right-parenthesis Over integral Subscript y 0 Superscript y 1 Baseline f left-parenthesis x comma y Superscript prime Baseline right-parenthesis normal d y Superscript prime Baseline EndFraction comma", display: true)]

#parec[
which has CDF
][
其 CDF 为
]

#math.equation(block: true)[#source-math("/Appendix-A-Sampling_Algorithms/supplements/math/A5-dc66459c5d4b4d65.svg",26.278,8.176,3.505,"upper P left-parenthesis y vertical-bar x right-parenthesis equals StartFraction integral Subscript y 0 Superscript y Baseline f left-parenthesis x comma y Superscript prime Baseline right-parenthesis normal d y Superscript prime Baseline Over integral Subscript y 0 Superscript y 1 Baseline f left-parenthesis x comma y Superscript prime Baseline right-parenthesis normal d y Superscript prime Baseline EndFraction period", display: true)]

#parec[
Although the `SummedAreaTable` class does not provide the capability to evaluate 1D integrals directly, because the function is piecewise-constant we can equivalently evaluate a 2D integral where the $x$ range spans only the stratum of the sampled $x$ value.
][
虽然 `SummedAreaTable` 不直接计算一维积分，但函数是分段常数的，因此可等价地计算二维积分，并把 $x$ 范围限制在样本 $x$ 所在的单个分层区间内。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Sampleconditionalwindowedfunctioniny-0")[#raw("<<Sample conditional windowed function in y>>=")]] <fragment-Sampleconditionalwindowedfunctioniny-0>

#block(breakable: false)[
```cpp
<<Compute 2D bounds bCond for conditional sampling>>
<<Define lambda function for conditional distribution and sample y>>
```
]

#parec[
`bCond` stores the bounding box that spans the range of potential $y$ values and the stratum of the $x$ sample. It is necessary to check for a zero function integral over these bounds: this should not be possible mathematically, but may be the case due to floating-point round-off error. In that rare case, conditional sampling is not possible and an invalid sample must be returned.
][
`bCond` 保存的包围范围覆盖所有可能的 $y$，以及 $x$ 样本所在的分层区间。必须检查函数在这一范围内的积分是否为零：数学上本不应如此，但浮点舍入误差可能造成这种情况。遇到这一罕见情况时，无法进行条件采样，必须返回无效样本。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Compute2DboundsmonobCondforconditionalsampling-0")[#raw("<<Compute 2D bounds bCond for conditional sampling>>=")]] <fragment-Compute2DboundsmonobCondforconditionalsampling-0>

#block(breakable: false)[
```cpp
int nx = func.XSize();
Bounds2f bCond(Point2f(pstd::floor(p.x * nx) / nx, b.pMin.y),
               Point2f(pstd::ceil(p.x * nx) / nx, b.pMax.y));
if (bCond.pMin.x == bCond.pMax.x) bCond.pMax.x += 1.f / nx;
if (sat.Integral(bCond) == 0)
    return {};
```
]

#parec[
Similar to the marginal CDF $P(x)$, we can define a lambda function to evaluate the conditional CDF $P(y | x)$. Again precomputing the normalization factor is worthwhile, as `Py` will be evaluated multiple times in the course of the sampling operation.
][
与边缘 CDF $P(x)$ 类似，可以定义 lambda 函数来计算条件 CDF $P(y | x)$。同样值得预先计算归一化因子，因为采样过程中需要多次计算 `Py`。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-Definelambdafunctionforconditionaldistributionandsampley-0")[#raw("<<Define lambda function for conditional distribution and sample y>>=")]] <fragment-Definelambdafunctionforconditionaldistributionandsampley-0>

#block(breakable: false)[
```cpp
Float condIntegral = sat.Integral(bCond);
auto Py = [&, this](Float y) -> Float {
    Bounds2f by = bCond;
    by.pMax.y = y;
    return sat.Integral(by) / condIntegral;
};
p.y = SampleBisection(Py, u[1], b.pMin.y, b.pMax.y, func.YSize());
```
]

#parec[
The PDF value is computed by evaluating the function at the sampled point `p` and normalizing with its integral over `b`, which is already available in `bInt`.
][
在采样点 `p` 处计算函数值，再用它在 `b` 内的积分归一化，就得到 PDF；该积分已保存在 `bInt` 中。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-ComputePDFandreturnpointsampledfromwindowedfunction-0")[#raw("<<Compute PDF and return point sampled from windowed function>>=")]] <fragment-ComputePDFandreturnpointsampledfromwindowedfunction-0>

#block(breakable: false)[
```cpp
*pdf = Eval(p) / bInt;
return p;
```
]

#parec[
The `Eval()` method wraps up the details of looking up the function value corresponding to the provided 2D point.
][
`Eval()` 封装了查询给定二维点对应函数值的细节。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DPrivateMethods-1")[#raw("<<WindowedPiecewiseConstant2D Private Methods>>+=")] #link(<fragment-WindowedPiecewiseConstant2DPrivateMethods-0>)[↑]] <fragment-WindowedPiecewiseConstant2DPrivateMethods-1>

#block(breakable: false)[
```cpp
Float Eval(Point2f p) const {
    Point2i pi(std::min<int>(p[0] * func.XSize(), func.XSize() - 1),
               std::min<int>(p[1] * func.YSize(), func.YSize() - 1));
    return func[pi];
}
```
]

#metadata(none) <WindowedPiecewiseConstant2D::Eval>

#parec[
The PDF method implements the same computation that is used to compute the PDF in the `Sample()` method.
][
PDF 方法使用与 `Sample()` 中计算 PDF 时相同的运算。
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragment-WindowedPiecewiseConstant2DPublicMethods-2")[#raw("<<WindowedPiecewiseConstant2D Public Methods>>+=")] #link(<fragment-WindowedPiecewiseConstant2DPublicMethods-1>)[↑]] <fragment-WindowedPiecewiseConstant2DPublicMethods-2>

#block(breakable: false)[
```cpp
Float PDF(Point2f p, const Bounds2f &b) const {
    Float funcInt = sat.Integral(b);
    if (funcInt == 0)
        return 0;
    return Eval(p) / funcInt;
}
```
]

#metadata(none) <WindowedPiecewiseConstant2D::PDF>

#include "supplements/A.5-expanded.typ"
