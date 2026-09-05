#import "../template.typ": parec, ez_caption, translator

== #ez_caption[The Rejection Method][拒绝采样法]
<rejection-method>

#parec[
  Many functions cannot be integrated in order to normalize them to find their PDFs. Even given a PDF, it is often not possible to invert the associated CDF to generate samples using the inversion method. In such cases, the _rejection method_ can be useful: it is a technique for generating samples according to a function’s distribution without needing to do either of these steps. Assume that we want to draw samples from some function $f(x)$ where we have some PDF $p(x)$ that satisfies $f(x)<c p(x)$ for a constant $c$, and suppose that we do know how to sample from $p$. The rejection method is then:
][
  许多函数的积分难以求得，因而无法据此归一化为 PDF。即使已有 PDF，也往往无法对相应 CDF 求逆，进而用逆变换法生成样本。这时可以使用_拒绝采样法_：不必完成上述任一步骤，也能按函数的分布生成样本。假设要从函数 $f(x)$ 的分布采样，并且有一个 PDF $p(x)$，对某个常数 $c$ 满足 $f(x)<c p(x)$，且我们知道如何从 $p$ 采样。拒绝采样法如下：
]

$
  & #ez_caption[loop forever:][无限循环：] \
  & quad #ez_caption[sample][采样] X tilde.op p \
  & quad #ez_caption[if][若] xi < f(X)/(c p(X)) #ez_caption[then][则] \
  & quad quad #ez_caption[return][返回] X
$

#parec[
  This procedure repeatedly chooses a pair of random variables $(X,xi)$. If the point $(X,xi c p(X))$ lies under $f(X)$, then the sample $X$ is accepted. Otherwise, it is rejected and a new sample pair is chosen. This idea is illustrated in @fig:rejection-sample; it works in any number of dimensions. It should be evident that the efficiency of this scheme depends on how tightly $c p(x)$ bounds $f(x)$.
][
  该过程反复选择一对随机变量 $(X,xi)$。若点 $(X,xi c p(X))$ 位于 $f(X)$ 的图像下方，就接受样本 $X$；否则拒绝它，再选择一对新样本。@fig:rejection-sample 展示了这一思想，它适用于任意维数。显然，其效率取决于 $c p(x)$ 对 $f(x)$ 的上界有多紧。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf02.svg",width:85%),caption:[#ez_caption[Rejection sampling generates samples according to the distribution of a function $f(x)$ even if $f$’s PDF is unknown or its CDF cannot be inverted. If some distribution $p(x)$ and a scalar constant $c$ are known such that $f(x)<c p(x)$, then samples can be drawn from $p(x)$ and randomly accepted in a way that causes the accepted samples to be from $f$’s distribution. The closer the fit of $c p(x)$ to $f(x)$, the more efficient this process is.][即使不知道函数$f(x)$的PDF，或无法对其CDF求逆，拒绝采样也能生成服从其分布的样本。若已知分布$p(x)$和标量常数$c$，满足$f(x)<c p(x)$，就能从$p(x)$采样，再随机决定是否接受，使接受的样本服从$f$的分布。$c p(x)$与$f(x)$贴合得越紧，这个过程就越高效。]]) <rejection-sample>

#parec[
  For example, suppose we want to select a uniformly distributed point inside a unit disk. Using the rejection method, we simply select a random $(x,y)$ position inside the circumscribed square and return it if it falls inside the disk. This process is shown in @fig:rejection-sample-disk.
][
  例如，要在单位圆盘内均匀采样，只需先在外接正方形内随机选择位置 $(x,y)$，若落在圆盘内就返回。@fig:rejection-sample-disk 展示了这一过程。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf03.svg",width:75%),caption:[#ez_caption[*Rejection Sampling a Disk.* One approach to finding uniform points in the unit disk is to sample uniform random points in the unit square and reject all that lie outside the disk (red points). The remaining points will be uniformly distributed within the disk.][*圆盘的拒绝采样。*一种在单位圆盘中寻找均匀分布点的方法，是在单位正方形中均匀采样，拒绝圆盘以外的所有点（红点）。剩余点在圆盘内均匀分布。]]) <rejection-sample-disk>

#parec[
  The function #link("https://pbr-book.org/4ed/Sampling_Algorithms/The_Rejection_Method.html#RejectionSampleDisk")[`RejectionSampleDisk()`] implements this algorithm. A similar approach will work to generate uniformly distributed samples on the inside of any complex shape as long as it has an inside–outside test.
][
  `RejectionSampleDisk()` 实现了这个算法。对于任意复杂形状，只要能判断点在形状内部还是外部，也可以用类似方法在其内部生成均匀分布的样本。
]

#block(sticky:true)[#raw("<<Sampling Function Definitions>>+=") #link("https://pbr-book.org/4ed/Volume_Scattering/Phase_Functions.html#fragment-SamplingFunctionDefinitions-2")[▲]] <fragment-SamplingFunctionDefinitions-3>
#block(breakable:false)[
```cpp
Point2f RejectionSampleDisk(RNG &rng) {
    Point2f p;
    do {
        p.x = 1 - 2 * rng.Uniform<Float>();
        p.y = 1 - 2 * rng.Uniform<Float>();
    } while (Sqr(p.x) + Sqr(p.y) > 1);
    return p;
}
``` <RejectionSampleDisk>
]

#parec[
  In general, the efficiency of rejection sampling depends on the percentage of samples that are expected to be rejected. For #link("https://pbr-book.org/4ed/Sampling_Algorithms/The_Rejection_Method.html#RejectionSampleDisk")[`RejectionSampleDisk()`], this is easy to compute. It is the area of the disk divided by the area of the square: $pi/4 approx 78.5%$. If the method is applied to generate samples in hyperspheres in the general $n$-dimensional case, however, the volume of an $n$-dimensional hypersphere goes to 0 as $n$ increases, and this approach becomes increasingly inefficient.
  #emph[Editorial note:] The fixed source first calls this a rejection percentage, but the disk-to-square area ratio is the acceptance percentage. The original value is retained above; 78.5% is not the rejection rate.
][
  一般而言，拒绝采样的效率取决于预期拒绝的样本比例。对于 `RejectionSampleDisk()`，原文随后给出的量很容易计算：圆盘面积与正方形面积之比，即 $pi/4 approx 78.5%$。不过，将该方法推广到一般 $n$ 维超球体时，随着 $n$ 增加，单位超球体体积趋于零，因此方法会越来越低效。#translator[固定原文先称这一量为预期被拒绝的比例，随后却给出圆盘与外接正方形面积之比。该比值实际是接受率；这里保留源数值并指出前后措辞不一致，不将78.5%误当拒绝率。]
]

#parec[
  Rejection sampling is not used in any of the Monte Carlo algorithms currently implemented in `pbrt`. We will normally prefer to find distributions that are similar to the function that can be sampled directly, so that well-distributed sample points in $lr([0,1))^n$ can be mapped to sample points that are in turn well distributed. Nevertheless, rejection sampling is an important technique to be aware of, particularly when debugging Monte Carlo implementations. For example, if one suspects the presence of a bug in code that draws samples from some distribution using the inversion method, then one can replace it with a straightforward implementation based on the rejection method and see if the Monte Carlo estimator converges to the same value. Of course, it is necessary to take many samples in situations like these, so that variance in the estimates does not mask errors.
][
  `pbrt` 当前实现的蒙特卡洛算法都不使用拒绝采样。我们通常倾向于寻找与目标函数相似、且能直接采样的分布，使 $lr([0,1))^n$ 中分布良好的样本点映射后仍分布良好。不过，拒绝采样仍值得掌握，尤其是在调试蒙特卡洛实现时。例如，若怀疑用逆变换法从某分布采样的代码有错误，可以改用直接的拒绝采样实现，检查蒙特卡洛估计量是否收敛到同一数值。当然，这时必须采集大量样本，以免估计方差掩盖错误。
]
