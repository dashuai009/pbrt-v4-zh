#import "../template.typ": parec, translator

== The Rejection Method

#parec[
  Many functions cannot be integrated in order to normalize them
  to find their PDFs. Even given a PDF, it is often not possible to invert
  the associated CDF to generate samples using the inversion method. In
  such cases, the #emph[rejection method] can be useful: it is a technique
  for generating samples according to a function’s distribution without
  needing to do either of these steps. Assume that we want to draw samples
  from some function f(x) where we have some PDF p(x) that satisfies f(x)
  \< c p(x) for a constant c, and suppose that we do know how to sample
  from p.~The rejection method is
  then:
][
  很多函数无法直接积分以归一化从而得到它们的概率密度函数（PDF）。即使给定了一个
  PDF，我们也常常无法对其累积分布函数（CDF）求逆来通过反演法生成样本。在这种情况下，#emph[拒绝采样法];（rejection
  method）就很有用：它是一种根据函数的分布来生成样本的技术，而无需执行积分或反演操作。假设我们要从某个函数
  f(x) 中抽样，并且存在一个 PDF p(x)，它满足对某个常数 c，恒有 f(x) \< c
  p(x)。同时假设我们知道如何从 p 中采样。拒绝采样法的过程如下：
]

$
  X tilde.op p (x) , quad xi tilde.op U (0 , 1) , quad upright("and if ") xi < frac(f (X), c thin p (X)) , upright(" return ") X .
$

#parec[
  The rejection method is then:

  - Draw a pair of random variables (X, ξ). If the point (X, ξ) lies under
    f(X) vs.~c p(X), then the sample X is accepted. Otherwise, it is
    rejected and a new sample pair is chosen. This idea is illustrated in
    Figure A.2; it works in any number of dimensions. It should be evident
    that the efficiency of this scheme depends on how tightly c p(x)
    bounds f(x).
][
  拒绝采样法的具体过程如下：
  - 抽取一对随机变量 (X, ξ)。如果点 (X, ξ) 落在 f(X) 与 c p(X)
    之间的区域下方，则接受该样本 X；否则拒绝它并重新抽取一对样本。图 A.2
    展示了这一思想；它适用于任意维度的情况。显然，该方法的效率取决于 c
    p(x) 对 f(x) 的拟合有多紧密。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf02.svg"), caption: [
  Figure A.2: Rejection sampling generates samples according to the
  distribution of a function f(x) even if f’s PDF is unknown or its
  CDF cannot be inverted. If some distribution p(x) and a scalar
  constant c are known such that f(x) \< c p(x), then samples can be
  drawn from p(x) and randomly accepted in a way that causes the
  accepted samples to be from f’s distribution. The closer the fit of
  c p(x) to f(x), the more efficient this process is.
])

#parec[
  For example, suppose we want to select a uniformly distributed
  point inside a unit disk. Using the rejection method, we simply select a
  random (x, y) position inside the circumscribed square and return it if
  it falls inside the disk. This process is shown in Figure
  A.3.
][
  例如，假设我们要在单位圆盘内均匀采样一个点。利用拒绝采样法，我们只需在外接正方形中随机选择一个
  (x, y) 位置，如果它落在圆盘内就接受，否则丢弃。该过程如图 A.3 所示。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf03.svg"), caption: [
  Figure A.3: Rejection Sampling a Disk. One approach to finding
  uniform points in the unit disk is to sample uniform random points
  in the unit square and reject all that lie outside the disk (red
  points). The remaining points will be uniformly distributed within
  the disk.
])

#parec[
  The function RejectionSampleDisk() implements this algorithm. A
  similar approach will work to generate uniformly distributed samples on
  the inside of any complex shape as long as it has an inside–outside
  test.
][
  函数 RejectionSampleDisk()
  实现了该算法。对于任意复杂形状，只要能够进行“内部–外部”测试，也可以采用类似的方法来生成均匀分布的样本。
]

```cpp
Point2f RejectionSampleDisk(RNG &rng) {
    Point2f p;
    do {
        p.x = 1 - 2 * rng.Uniform<Float>();
        p.y = 1 - 2 * rng.Uniform<Float>();
    } while (Sqr(p.x) + Sqr(p.y) > 1);
    return p;
}
```

#parec[
  In general, the efficiency of rejection sampling depends on the
  percentage of samples that are expected to be rejected. For
  RejectionSampleDisk, this is easy to compute. It is the area of the disk
  divided by the area of the square: \$ % .\$ If the method is applied to
  generate samples in hyperspheres in the general n-dimensional case,
  however, the volume of an n-dimensional hypersphere goes to 0 as n
  increases, and this approach becomes increasingly
  inefficient.
][
  总体而言，拒绝采样的效率取决于预期会被拒绝的样本比例。对于
  RejectionSampleDisk，这个比例很容易计算：它等于圆盘面积与正方形面积的比值，即
  $pi / 4 approx 78.5 %$。然而，如果将该方法推广到 n 维超球体的采样，随着
  n 的增加，超球体的体积趋于 0，因此这种方法会变得越来越低效。
]

#parec[
  Rejection sampling is not used in any of the Monte Carlo
  algorithms currently implemented in pbrt. We will normally prefer to
  find distributions that are similar to the function that can be sampled
  directly, so that well-distributed sample points in $[0,1
  ]^n$ can be
  mapped to sample points that are in turn well distributed. Nevertheless,
  rejection sampling is an important technique to be aware of,
  particularly when debugging Monte Carlo implementations. For example, if
  one suspects the presence of a bug in code that draws samples from some
  distribution using the inversion method, then one can replace it with a
  straightforward implementation based on the rejection method and see if
  the Monte Carlo estimator converges to the same value. Of course, it is
  necessary to take many samples in situations like these, so that
  variance in the estimates does not mask errors.
][
  目前在 pbrt 已实现的
  Monte Carlo
  算法中，并未使用拒绝采样。我们通常更倾向于找到与目标函数相似、且能够直接采样的分布，这样
  $[0,1]^n$
  中分布良好的样本点就能映射为目标域中同样分布良好的样本点。然而，拒绝采样仍然是一个重要的方法，尤其在调试
  Monte Carlo 实现时。例如，如果怀疑使用反演法从某个分布中采样的代码存在
  bug，可以用基于拒绝采样的直接实现替换它，并观察 Monte Carlo
  估计器是否仍能收敛到相同的结果。当然，在这种情况下需要足够多的样本，以避免估计的方差掩盖错误。
]
