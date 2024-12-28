#import "../template.typ": parec, ez_caption, translator


== Improving Efficiency


#parec[
  Given an unbiased Monte Carlo estimator, we are in the fortunate position of having a reliable relationship between the number of samples taken and variance (and thus, error). If we have an unacceptably noisy rendered image, increasing the number of samples will reduce error in a predictable way, and—given enough computation—an image of sufficient quality can be generated.
][
  给定一个无偏的蒙特卡洛估计量，我们幸运地拥有一个可靠的关系，即采样数量与方差（以及因此产生的误差）之间的关系。如果我们得到一个噪声过大的渲染图像，增加采样数量将以可预测的方式减少误差，并且——在足够的计算资源下——可以生成足够质量的图像。
]

#parec[
  However, computation takes time, and often there is not enough of it. The deadline for a movie may be at hand, or the sixtieth-of-a-second time slice in a real-time renderer may be coming to an end. Given the consequentially limited number of samples, the only option for variance reduction is to find ways to make more of the samples that can be taken. Fortunately, a variety of techniques have been developed to improve the basic Monte Carlo estimator by making the most of the samples that are taken; here we will discuss the most important ones that are used in `pbrt`.
][
  然而，计算需要时间，而且往往时间不够用。电影的截止日期可能迫在眉睫，或者实时渲染器中的六十分之一秒时间片可能即将结束。鉴于因此有限的采样数量，减少方差的唯一选择是找到更多利用可采样数量的方法。幸运的是，已经开发了多种技术来通过充分利用采样数量来改进基本的蒙特卡洛估计量；在这里，我们将讨论在 `pbrt` 中使用的一些最重要的技术。
]


=== Stratified Sampling
<Stratified-Sampling>

#parec[
  A classic and effective family of techniques for variance reduction is based on the careful placement of samples in order to better capture the features of the integrand (or, more accurately, to be less likely to miss important features). These techniques are used extensively in `pbrt`. Stratified sampling decomposes the integration domain into regions and places samples in each one; here we will analyze that approach in terms of its variance reduction properties. Later, in @fourier-analysis-of-variance , we will return with machinery based on Fourier analysis that provides further insights about it.
][
  `pbrt`大量使用了一类经典且有效的方差缩减技术——基于精心放置采样点以更好地捕捉被积函数特征（或者更准确地说，减少错过重要特征的可能性）。分层采样将积分域分解为多个层，并在每个层中放置采样点；在这里，我们将从方差减少的角度分析这种方法。稍后，在@fourier-analysis-of-variance 中，我们将基于傅里叶分析的机制返回，提供关于它的进一步见解。
]



#parec[
  Stratified sampling subdivides the integration domain $Lambda$ into $n$ nonoverlapping regions $Lambda_1 , Lambda_2 , dots.h , Lambda_n$ . Each region is called a #emph[stratum];, and they must completely cover the original domain:
][
  分层采样将积分域 $Lambda$ 细分为 $n$ 个不重叠的层 $Lambda_1 , Lambda_2 , dots.h , Lambda_n$ 。每个层称为一个“层”，它们必须完全覆盖原始域：
]

$ union.big_(i = 1)^n Lambda_i = Lambda . $

#parec[
  To draw samples from $Lambda$ , we will draw $n_i$ samples from each $Lambda_i$ , according to densities $p_i$ inside each stratum. A simple example is supersampling a pixel. With stratified sampling, the area around a pixel is divided into a $k times k$ grid, and a sample is drawn uniformly within each grid cell. This is better than taking $k^2$ random samples, since the sample locations are less likely to clump together. Here we will show why this technique reduces variance.
][
  为了从 $Lambda$ 中抽取样本，我们将从每个 $Lambda_i$ 中抽取 $n_i$ 个样本，根据每个层内的密度 $p_i$ 。一个简单的例子是像素超采样。使用分层采样，像素周围的区域被划分为一个 $k times k$ 的网格，并在每个网格单元内均匀地抽取一个样本。这比取 $k^2$ 个随机样本要好，因为样本位置不太可能聚集在一起。在这里，我们将解释为什么这种技术能减少方差。
]


#parec[
  Within a single stratum $Lambda_i$ , the Monte Carlo estimate is
][
  在一个单独的层 $Lambda_i$ 内，蒙特卡洛估计为
]

$ F_i = frac(1, n_i) sum_(j = 1)^(n_i) frac(f(X_(i comma j)), p_i (X_(i comma j))), $

#parec[
  where $X_(i , j)$ is the $j$ th sample drawn from density $p_i$ . The overall estimate is $F = sum_i v_i F_i$ , where $v_i$ is the fractional volume of stratum $i$ ( $v_i in (0 , 1]$ ).
][
  其中 $X_(i , j)$ 是从密度 $p_i$ 中抽取的第 $j$ 个样本。总体估计为 $F = sum_i v_i F_i$ ，其中 $v_i$ 是第 $i$ 层的体积比例（ $v_i in \(0 , 1\], v_i = (|Lambda_i|)/(|Lambda|)$ ）。
]



#parec[
  The true value of the integrand in stratum $i$ is
][
  层 $i$ 中被积函数的真实值为
]

$ mu_i = E [f(X_(i, j))] = frac(1, v_i) integral_(Lambda_i) f(x) dif x, $

#parec[
  and the variance in this stratum is
][
  该层的方差则为
]

$ sigma_i^2 = frac(1, v_i) integral_(Lambda_i)(f(x) - mu_i)^2 dif x . $


#parec[
  Thus, with $n_i$ samples in the stratum, the variance of the per-stratum estimator is $sigma_i^2 \/ n_i$ . This shows that the variance of the overall estimator is
][
  因此，在各层中有 $n_i$ 个样本的情况下，各层的估计方差则为 $sigma_i^2 \/ n_i$ 。这表明总体估计的方差为
]

$
  V [F] & = V [sum v_i F_i] \
  & = sum V [v_i F_i] \
  & = sum v_i^2 V [F_i] \
  & = sum frac(v_i^2 sigma_i^2, n_i) .
$


#parec[
  If we make the reasonable assumption that the number of samples $n_i$ is proportional to the volume $v_i$ , then we have $n_i = v_i n$ , and the variance of the overall estimator is
][
  如果我们合理地假设样本数量 $n_i$ 与体积 $v_i$ 成正比，那么我们有 $n_i = v_i n$ ，并且总体估计的方差为
]
$
  V [F_n] = frac(1, n) sum v_i sigma_i^2 .
$

#parec[
  To compare this result to the variance without stratification, we note that choosing an unstratified sample is equivalent to choosing a random stratum $I$ according to the discrete probability distribution defined by the volumes $v_i$ and then choosing a random sample $X$ in $Lambda_I$ . In this sense, $X$ is chosen #emph[conditionally] on $I$ , so it can be shown using conditional probability that
][
  为了比较此结果与不分层采样的方差，我们注意到选择不分层采样相当于根据体积 $v_i$ 定义的离散概率分布随机选择一个层 $I$ ，然后在 $Lambda_I$ 中选择一个随机样本 $X$ 。从这个意义上说， $X$ 是根据 $I$ 条件选择的，因此可以使用条件概率来证明
]


$
  V [F] = frac(1, n) [sum v_i sigma_i^2 + sum v_i (mu_i - Q)^2],
$ <strat-variance>

#parec[
  where $Q$ is the mean of $f$ over the whole domain $Lambda$ .#footnote[ See @veach1997robust for a derivation of this result.
]
][
  其中 $Q$ 是函数 $f$ 在整个定义域 $Lambda$ 上的均值。#footnote[ 关于此结果的详细推导，参见 @veach1997robust。 ]
]





#parec[
  There are two things to notice about @eqt:strat-variance . First, we know that the right-hand sum must be nonnegative, since variance is always nonnegative. Second, it demonstrates that stratified sampling can never increase variance. Stratification always reduces variance unless the right-hand sum is exactly 0. It can only be 0 when the function $f$ has the same mean over each stratum $Lambda_i$ . For stratified sampling to work best, we would like to maximize the right-hand sum, so it is best to make the strata have means that are as unequal as possible. This explains why #emph[compact] strata are desirable if one does not know anything about the function $f$ . If the strata are wide, they will contain more variation and will have $mu_i$ closer to the true mean $Q$ .
][
  关于@eqt:strat-variance，有两点需要注意。首先，我们知道右侧的和项必须是非负的，因为方差总是非负的。其次，它表明分层采样永远不会增加方差。分层总是减少方差，除非右侧的和项恰好为0。只有当函数 $f$ 在每个层 $Lambda_i$ 上的均值相同时，右侧的和项才可能为0。为了使分层采样的效果达到最佳，我们应尽量使右侧的和项最大化，因此最好使各层的均值尽可能不同。这解释了为何在缺乏函数 $f$ 信息的情况下，选择紧凑的层更为可取。如果层很宽，它们将包含更多的变化，并且 $mu_i$ 会更接近真实均值 $Q$ 。
]


#parec[
  @fig:mc-strat-images shows the effect of using stratified sampling versus an independent random distribution for sampling when rendering an image that includes glossy reflection. There is a reasonable reduction in variance at essentially no cost in running time.
][
  @fig:mc-strat-images 展示了在渲染包含光泽反射的图像时，使用分层采样与独立随机分布采样的效果。在运行时间几乎不增加的情况下，方差有合理的减少。
]

#figure(
  table(
    columns: 2,
    stroke: none,
    [#image("../pbr-book-website/4ed/Monte_Carlo_Integration/bunny-independent.png")],
    [#image("../pbr-book-website/4ed/Monte_Carlo_Integration/bunny-stratified.png")],

    [(a) Independent], [(b) Stratified],
  ),
  caption: [
    #ez_caption[Variance is higher and the image noisier (a) when independent random sampling is used than (b) when a stratified distribution of sample directions is used instead. (Bunny model courtesy of the Stanford Computer Graphics Laboratory.)][使用独立随机采样时 (a) 比使用样本方向分层分布时的 (b) 方差更高，图像噪声更大。 （兔子模型由斯坦福计算机图形实验室提供。）]
  ],
  kind: image,
)<mc-strat-images>


#parec[
  The main downside of stratified sampling is that it suffers from the same "curse of dimensionality" as standard numerical quadrature. Full stratification in $D$ dimensions with $S$ strata per dimension requires $S^D$ samples, which quickly becomes prohibitive. Fortunately, it is often possible to stratify some of the dimensions independently and then randomly associate samples from different dimensions; this approach will be used in Section 8.5. Choosing which dimensions are stratified should be done in a way that stratifies dimensions that tend to be most highly correlated in their effect on the value of the integrand (@owen1998latin).
][
  分层采样的主要缺点是它与标准数值积分一样，受到“维度灾难”的影响。在 $D$ 维空间中，每维有 $S$ 个层，需要 $S^D$ 个样本，这很快变得不可行。幸运的是，通常可以独立地对某些维度进行分层，然后随机关联来自不同维度的样本；这种方法将在第 8.5 节中使用。选择哪些维度进行分层应根据这些维度对被积函数值的影响相关性最大的原则进行（@owen1998latin）。
]


=== Importance Sampling <importance-sampling>


#parec[
  Importance sampling is a powerful variance reduction technique that exploits the fact that the Monte Carlo estimator
][
  重要性采样是一种强大的方差减少技术，它利用了以下事实：如果样本是从与被积函数 $f (x)$ 相似的分布 $p (x)$ 中抽取的，那么蒙特卡罗估计量
]

$ F_n = frac(1, n) sum_(i = 1)^n frac(f(X_i), p(X_i)) $

#parec[
  converges more quickly if the samples are taken from a distribution $p (x)$ that is similar to the function $f (x)$ in the integrand. In this case, samples are more likely to be taken when the magnitude of the integrand is relatively large. Importance sampling is one of the most frequently used variance reduction techniques in rendering, since it is easy to apply and is very effective when good sampling distributions are used.
][
  收敛得更快。在这种情况下，样本更有可能在被积函数的幅值相对较大的地方被抽取。重要性采样是渲染中最常用的方差减少技术之一，因为它易于应用，并且在使用良好的采样分布时非常有效。
]


#parec[
  To see why such sampling distributions reduce error, first consider the effect of using a distribution $p (x) prop f (x)$ , or $p (x) = c f (x)$ .#footnote[We will generally assume that $f(x) gt.eq 0$; if it isnegative, we might set $p(x) prop |f(X)|$. See the "Further Reading" section for more discussion of this topic.] It is trivial to show that normalization of the PDF requires that
][
  要了解为什么这种采样分布能减少误差，首先考虑使用分布 $p (x) prop f (x)$ ，或 $p (x) = c f (x)$ 的效果。#footnote[我们通常假设 $f(x) gt.eq 0$；如果它是负数，我们可能设 $p(x) prop |f(X)|$。有关此主题的更多讨论，请参阅“进一步阅读”部分。] 很容易证明，PDF 的归一化要求
]


$ c = frac(1, integral f (x) thin d x) . $

#parec[
  Finding such a PDF requires that we know the value of the integral, which is what we were trying to estimate in the first place. Nonetheless, if we #emph[could] sample from this distribution, each term of the sum in the estimator would have the value
][
  找到这样的 PDF 需要我们知道积分的值，而这正是我们最初试图估计的。尽管如此，如果我们#emph[能够];从这个分布中采样，估计量中的每个项的值将是
]


$ frac(f (X_i), p (X_i)) = 1 / c = integral f (x) thin d x . $



#parec[
  The variance of the estimator is zero! Of course, this is ludicrous since we would not bother using Monte Carlo if we could integrate $f$ directly. However, if a density $p (x)$ can be found that is similar in shape to $f (x)$ , variance is reduced.
][
  估计量的方差为零！当然，这是荒谬的，因为如果我们能直接积分 $f$ ，就不会费心使用蒙特卡罗方法。然而，如果可以找到一个形状与 $f (x)$ 相似的密度 $p (x)$ ，方差就会减少。
]



#parec[
  As a more realistic example, consider the Gaussian function $f (x) = e^(- 1000 (x - 1 \/ 2)^2)$ , which is plotted in @gaussian-pdf-and-samples (a) over $[0 , 1]$ . Its value is close to zero over most of the domain. Samples $X$ with $X < 0.2$ or $X > 0.3$ are of little help in estimating the value of the integral since they give no information about the magnitude of the bump in the function's value around $1 \/ 4$ . With uniform sampling and the basic Monte Carlo estimator, variance is approximately $0.0365$ .
][
  作为一个更现实的例子，考虑高斯函数 $f (x) = e^(- 1000 (x - 1 \/ 2)^2)$ ，它在 $[0 , 1]$ 上绘制在图 2.2(a) 中。它的值在大部分定义域上接近于零。如果在 $X < 0.2$ 或 $X > 0.3$ 上对 $X$ 采样，对于估计积分值几乎没有帮助，因为它们没有提供关于函数在 $1 \/ 4$ #translator[这地方应该是1/2？] 附近峰值幅值的信息。使用均匀采样和基本的蒙特卡罗估计量，方差大约为 $0.0365$ 。
]


#parec[
  If samples are instead drawn from the piecewise-constant distribution
][
  如果样本是从分段常数分布中抽取的，该分布定义为
]

$
  p (x) =
  cases(
    delim: "{",
     0.1 & x in \[0 comma 0.45\) ,
     9.1 & x in \[0.45 comma 0.55\),
     0.2 & x in \[0.55 comma 1\)
  )
$


// #parec[ the variance is reduced to approximately $0.0013$. ][
//   方差降低到大约 $0.0013$。 ]


#parec[
  which is plotted in @gaussian-pdf-and-samples(b), and the estimator from @eqt:MC-estimator is used instead, then variance is reduced by a factor of approximately 6.7 times. A representative set of 6~points from this distribution is shown in @gaussian-pdf-and-samples(c); we can see that most of the evaluations of $f(x)$ are in the interesting region where it is not nearly zero.
][
  该函数绘制于 @gaussian-pdf-and-samples(b)，若采用@eqt:MC-estimator 的估计器，方差将减少约6.7倍。从该分布中选取的6个代表性点如 @gaussian-pdf-and-samples(c)所示；我们可以观察到， $f(x)$ 的多数评估值位于我们感兴趣的非零的区域。
]


#figure(
  table(
    columns: 3,
    stroke: none,
    [
      #image("../pbr-book-website/4ed/Monte_Carlo_Integration/narrow-gaussian.svg")
    ],
    [
      #image("../pbr-book-website/4ed/Monte_Carlo_Integration/piecewise-gaussian-samples.svg")
    ],
    [
      #image("../pbr-book-website/4ed/Monte_Carlo_Integration/piecewise-gaussian-samples.svg")
    ],

    [(a)], [(b)], [(c)],
  ),

  caption: [
    #ez_caption[
      (a) A narrow Gaussian function that is close to zero over most of the range $[0,1]$. The basic Monte Carlo estimator of Equation (2.6) has relatively high variance if it is used to integrate this function, since most samples have values that are close to zero. (b) A PDF that roughly approximates the function's distribution. If this PDF is used to generate samples, variance is reduced substantially. (c) A representative distribution of samples generated according to (b).
    ][
      (a) 一个在大部分区间 $[0,1]$ 上接近零的窄高斯函数。如果用来积分这个函数，方程（2.6）的基本蒙特卡罗估计器的方差相对较高，因为大多数样本的值接近于零。 (b) 大致近似函数分布的概率密度函数（PDF）。如果使用这个PDF生成样本，方差会大幅减少。 (c) 根据 (b) 生成的样本的代表性分布。
    ]
  ],
  kind: image,
) <gaussian-pdf-and-samples>


#parec[
  Importance sampling can increase variance if a poorly chosen distribution is used, however. Consider instead using the distribution
][
  若重要性采样使用了不恰当的分布，方差可能会增加。考虑使用以下分布
]


$ p (x) = cases(delim: "{", 1.2 & x in \[ 0 comma 0.4\), 0.2 & x in \[ 0.4 \, 0.6\), 1.2 & x in \[ 0.6 \, 1\)) $


#parec[
  for estimating the integral of the Gaussian function. This PDF increases the probability of sampling the function where its value is close to zero and decreases the probability of sampling it where its magnitude is larger.
][
  来估计高斯函数的积分。这个PDF增加了函数值接近零处的采样概率，并减少了其幅值较大处的采样概率。
]


#parec[
  Not only does this PDF generate fewer samples where the integrand is large, but when it does, the magnitude of $f(x)\/p(x)$ in the Monte Carlo estimator will be especially high since $p(x) = 0.4$ in that region. The result is approximately $5.4 times$ higher variance than uniform sampling, and nearly $36 times$ higher variance than the better PDF above. In the context of Monte Carlo integration for rendering where evaluating the integrand generally involves the expense of tracing a ray, it is desirable to minimize the number of samples taken; using an inferior sampling distribution and making up for it by evaluating more samples is an unappealing option.
][
  这不仅减少了在积分值较大区域的样本生成，而且在这些区域采样时，蒙特卡罗估计器中的 $f(x)\/p(x)$ 幅值会特别高，因为该区域 $p(x) = 0.4$ 。结果是方差大约比均匀采样高5.4倍，比上述更好的PDF高近36倍。在渲染中进行蒙特卡罗积分的背景下，评估积分通常涉及追踪光线的成本，因此希望最小化采样数量；使用较差的采样分布并通过评估更多样本来弥补是一个不吸引人的选择。
]


=== Multiple Importance Sampling
<multiple-importance-sampling>

#parec[
  We are frequently faced with integrals that are the product of two or more functions: $integral f_a (x) f_b (x) , d x $ . It is often possible to derive separate importance sampling strategies for individual factors individually, though not one that is similar to their product. This situation is especially common in the integrals involved with light transport, such as in the product of BSDF, incident radiance, and a cosine factor in the light transport @eqt:rendering-equation.
][
  我们经常遇到积分是两个或多个函数乘积的情况： $integral f_a (x) f_b (x) , d x $ 。通常可以为单个因子分别推导出重要性采样策略，尽管没有一个与它们的乘积相似。这种情况在涉及光传输的积分中尤其常见，例如光传输方程@eqt:rendering-equation 中的BSDF、入射辐射和余弦因子的乘积。
]


#parec[
  To understand the challenges involved with applying Monte Carlo to such products, assume for now the good fortune of having two sampling distributions $p_a$ and $p_b$ that match the distributions of $f_a$ and $f_b$ exactly. (In practice, this will not normally be the case.) With the Monte Carlo estimator of @eqt:MC-estimator, we have two options: we might draw samples using $p_a$ , which gives the estimator
][
  为了理解将蒙特卡罗应用于此类乘积的难点，假设目前幸运地拥有两个采样分布 ( $p_a$ 和 $p_b$ ，它们完全匹配 $f_a$ 和 $f_b$ 的分布。（实际上，这种情况通常不会发生。）使用@eqt:MC-estimator 的蒙特卡罗估计器，我们有两个选择：我们可以使用 $p_a$ 抽取样本，给出估计器
]


$ frac(f (X), p_a (X)) = frac(f_a (X) f_b (X), p_a (X)) = c f_b (X) , $

#parec[
  where $c$ is a constant equal to the integral of $f_a$ , since $ p_a (x) prop f_a (x)$ . The variance of this estimator is proportional to the variance of $f_a$ , which may itself be high. Conversely, we might sample from $p_b$ , though doing so gives us an estimator with variance proportional to the variance of $f_a$ , which may similarly be high. In the more common case where the sampling distributions only approximately match one of the factors, the situation is usually even worse.
][
  其中 $c$ 是一个常数，等于 $f_a$ 的积分，因为 $ p_a (x) prop f_a (x)$ 。这个估计器的方差与 $f_a$ 的方差成正比，这本身可能很高。相反，我们可以从 $p_b$ 采样，尽管这样做会给我们一个方差与 $f_a$ 的方差成正比的估计器，这同样可能很高。在采样分布仅近似匹配其中一个因子的情况下，情况通常更糟。
]



#parec[
  Unfortunately, the obvious solution of taking some samples from each distribution and averaging the two estimators is not much better. Because variance is additive, once variance has crept into an estimator, we cannot eliminate it by adding it to another low-variance estimator.
][
  不幸的是，显而易见的解决方案是从每个分布中抽取一些样本并平均两个估计器，但这并没有显著改善。因为方差是可加的，一旦方差进入估计器，我们就无法通过将其添加到另一个低方差估计器来消除它。
]


#parec[
  Multiple importance sampling (MIS) addresses exactly this issue, with an easy-to-implement variance reduction technique. The basic idea is that, when estimating an integral, we should draw samples from multiple sampling distributions, chosen in the hope that at least one of them will match the shape of the integrand reasonably well, even if we do not know which one this will be. MIS then provides a method to weight the samples from each technique that can eliminate large variance spikes due to mismatches between the integrand's value and the sampling density. Specialized sampling routines that only account for unusual special cases are even encouraged, as they reduce variance when those cases occur, with relatively little cost in general.
][
  多重重要性采样(MIS)正是针对这一问题，提供了一种易于实施的方差减少技术。基本思想是，在估计积分时，我们应该从多个采样分布中抽取样本，希望至少有一个能合理地匹配被积函数的形状，即使我们不知道是哪一个。MIS然后提供了一种方法来加权来自每种技术的样本，可以消除由于被积函数值与采样密度不匹配而导致的大方差峰值。鼓励编写仅针对特殊情况进行特殊采样的专用代码，因为当这些情况发生时，它们会减少方差，而在一般情况下成本相对较低。
]



#parec[
  With two sampling distributions $p_a$ and $p_b$ and a single sample taken from each one, $X prop p_a $ and $Y prop p_b $ , the MIS Monte Carlo estimator is
][
  对于两个采样分布 $p_a$ 和 $p_b$ ，以及从每个分布中抽取的一个样本 $X prop p_a $ 和 $Y prop p_b $ ，MIS蒙特卡罗估计器为
]


$ w_a (X) frac(f(X), p_a (X)) + w_b (Y) frac(f(Y), p_b (Y)), $
<mis-single-simple-two>

#parec[
  where $w_a$ and $w_b$ are weighting functions that determine how much each sample contributes to the final estimate.
][
  其中 $w_a$ 和 $w_b$ 是确定每个样本对最终估计贡献多少的加权函数。
]


#parec[
  More generally, given $n$ sampling distributions $p_i$ with $n_i$ samples $X_(i,j)$ taken from the $i$ -th distribution, the MIS Monte Carlo estimator is
][
  更一般地，给定 $n$ 个采样分布 $p_i$ ，每个分布 $p_i$ 抽取 $n_i$ 个样本 $X_(i,j)$ ，多重重要性采样（MIS）蒙特卡洛估计量为
]


$
  F_n = sum_(i = 1)^n frac(1, n_i) sum_(j = 1)^(n_i) w_i (X_(i, j)) frac(f(X_(i comma j)), p_i (X_(i comma j))) .
$

#parec[
  (The full set of conditions on the weighting functions for the estimator to be unbiased are that they sum to 1 when $f(x) eq.not 0$ , $sum_(i = 1)^n w_i (x) = 1,$ and that $w_i (x) = 0$ if $p_i (x) = 0$
][
  （对于估计量无偏的条件是，当 $f(x) eq.not 0$ 时，权重函数之和为1，即 $sum_(i = 1)^n w_i (x) = 1,$ ，并且如果 $p_i (x) = 0$ ，则 $w_i (x) = 0$ 。）
]

#parec[
  Setting $w_i(X) =1\/n$ corresponds to the case of summing the various estimators, which we have already seen is an ineffective way to reduce variance. It would be better if the weighting functions were relatively large when the corresponding sampling technique was a good match to the integrand and relatively small when it was not, thus reducing the contribution of high-variance samples.
][
  设定 $w_i(X) =1\/n$ 对应于求和各种估计量的情况，我们已经知道这是一种降低方差的无效方法。如果权重函数在相应的采样技术与被积函数匹配良好时相对较大，而在不匹配时相对较小，则会减少高方差样本的贡献。
]


#parec[
  In practice, a good choice for the weighting functions is given by the #emph[balance heuristic];, which attempts to fulfill this goal by taking into account all the different ways that a sample could have been generated, rather than just the particular one that was used to do so. The balance heuristic's weighting function for the $i$ -th sampling technique is
][
  实际上，一个好的权重函数选择是#emph[平衡启发式];，它通过考虑所有可能生成样本的不同方式，而不是仅考虑用于生成样本的特定方式，来实现这一目标。平衡启发式的第 $i$ 个采样技术的权重函数为
]

$ w_i (x) = frac(n_i p_i (x), sum_j n_j p_j (x)) . $
<balance-heuristic>
#parec[
  With the balance heuristic and our example of taking a single sample from each of two sampling techniques, the estimator of @eqt:mis-single-simple-two works out to be
][
  使用平衡启发式和我们从两种采样技术中各取一个样本的例子，@eqt:mis-single-simple-two 的估计量变为
]

$ frac(f(X), p_a (X) + p_b (X)) + frac(f(Y), p_a (Y) + p_b (Y)) . $


#parec[
  Each evaluation of $f$ is divided by the sum of all PDFs for the corresponding sample rather than just the one that generated the sample. Thus, if $p_a$ generates a sample with low probability at a point where the $p_b$ has a higher probability, then dividing by $p_a (X) + p_b (X)$ reduces the sample's contribution. Effectively, such samples are downweighted when sampled from $p_a$ , recognizing that the sampling technique associated with $p_b$ is more effective at the corresponding point in the integration domain. As long as just one of the sampling techniques has a reasonable probability of sampling a point where the function's value is large, the MIS weights can lead to a significant reduction in variance.
][
  每次 $f$ 的评估都除以所有 PDF 对应样本的总和，而不仅仅是生成样本的那个。因此，如果 $p_a$ 在 $p_b$ 的概率较高的点生成低概率样本，则除以 $p_a (X) + p_b (X)$ 会减少该样本的贡献。实际上，从 $p_a$ 采样时，这些样本被降权，认识到与 $p_b$ 相关的采样技术在相应的积分域点更有效。只要有一种采样技术有合理的概率在函数值较大的点采样，MIS 权重就能显著降低方差。
]


#parec[
  `BalanceHeuristic()` computes @eqt:balance-heuristic for the specific case of two distributions $p_a$ and $p_b$ . We will not need a more general multidistribution case in `pbrt`.
][
  `BalanceHeuristic()` 计算@eqt:balance-heuristic 在两种分布 $p_a$ 和 $p_b$ 的特定情况。我们在`pbrt` 中不需要更一般的多分布情况。
]

```cpp
Float BalanceHeuristic(int nf, Float fPdf, int ng, Float gPdf) {
    return (nf * fPdf) / (nf * fPdf + ng * gPdf);
}
```

#parec[
  In practice, the _power heuristic_ often reduces variance even further. For an exponent $beta$ , the power heuristic is
][
  实际上，_幂启发式_通常进一步降低方差。对于指数 $beta$ ，幂启发式为
]

$ w_i (x) = frac((n_i p_i (x))^beta, sum_j (n_j p_j (x))^beta) . $ <mis-power-heuristic>

#parec[
  Note that the power heuristic has a similar form to the balance heuristic, though it further reduces the contribution of relatively low probabilities. Our implementation has $beta = 2$ hard-coded in its implementation; that parameter value usually works well in practice.
][
  注意，幂启发式与平衡启发式形式相似，但它进一步减少了相对低概率的贡献。我们的实现中 $beta = 2$ 是硬编码的；该参数值通常在实践中表现良好。
]

```cpp
Float PowerHeuristic(int nf, Float fPdf, int ng, Float gPdf) {
    Float f = nf * fPdf, g = ng * gPdf;
    return Sqr(f) / (Sqr(f) + Sqr(g));
}
```


#parec[
  Multiple importance sampling can be applied even without sampling from all the distributions. This approach is known as the _single sample model_. We will not include the derivation here, but it can be shown that given an integrand $f(x)$ , if a sampling technique $p_i$ is chosen from a set of techniques with probability $q_i$ and a sample $X$ is drawn from $p_i$ , then the _single sample estimator_
][
  多重重要性采样甚至可以在不从所有分布中采样的情况下应用。这种方法称为_单样本模型_。我们在这里不包括推导，但可以证明，给定被积函数 $f(x)$ ，如果从一组技术中以概率 $q_i$ 选择采样技术 $p_i$ ，并从 $p_i$ 中抽取样本 $X$ ，则_单样本估计量_
]


$ frac(w_i (X), q_i) frac(f(X), p_i (X)) $ <mis-single-sample-estimator>

#parec[
  gives an unbiased estimate of the integral. For the single sample model, the balance heuristic is provably optimal.
][
  分式给出了积分的无偏估计。在单样本模型中，平衡启发法已被证明是最优方法。
]


#parec[
  One shortcoming of multiple importance sampling is that if one of the sampling techniques is a very good match to the integrand, MIS can slightly increase variance. For rendering applications, MIS is almost always worthwhile for the variance reduction it provides in cases that can otherwise have high variance.
][
  多重重要性采样的一个缺点是，如果其中一种采样技术与被积函数非常匹配，MIS 可能会稍微增加方差。对于渲染应用，MIS 几乎总是值得的，因为它在其他情况下可能具有高方差的情况下提供了方差减少。
]

==== MIS Compensation


#parec[
  Multiple importance sampling is generally applied using probability distributions that are all individually valid for importance sampling the integrand, with nonzero probability of generating a sample anywhere that the integrand is nonzero. However, when MIS is being used, it is not a requirement that all PDFs are nonzero where the function's value is nonzero; only one of them must be.
][
  多重重要性采样（MIS）通常应用于使用单独对被积函数进行重要性采样时有效的概率分布，这些分布在被积函数为非零的地方都有非零的生成样本的概率。然而，当使用MIS时，并不要求所有的概率密度函数（PDF）在函数值为非零的地方都为非零；只需要其中一个是非零即可。
]


#parec[
  This observation led to the development of a technique called _MIS compensation_, which can further reduce variance. It is motivated by the fact that if all the sampling distributions allocate some probability to sampling regions where the integrand's value is small, it is often the case that that region of the integrand ends up being oversampled, leaving the region where the integrand is high undersampled.
][
  这一观察结果引出了一种称为 _MIS 补偿_ 的技术的发展，它可以进一步减少方差。其动机源于这样一个事实：如果所有采样分布都分配了一定的概率在被积函数值较小的区域进行采样，通常情况下，该区域会被过度采样，而被积函数值较高的区域则会被采样不足。
]


#parec[
  MIS compensation is based on the idea of sharpening one or more (but not all) the probability distributions—for example, by adjusting them to have zero probability in areas where they earlier had low probability. A new sampling distribution $p prime$ can, for example, be defined by
][
  MIS 补偿基于锐化一个或多个（但不是全部）概率分布的想法——例如，通过调整它们，使它们在之前概率较低的区域具有零概率。例如，可以通过以下方式定义新的采样分布 $p prime$ ：
]

$ p prime (x) = frac(max (0 , p (x) - delta), integral max (0 , p (x) - delta) thin d x) , $


#parec[
  for some fixed value $delta$ .
][
  对于固定的值 $delta$
]



#parec[
  This technique is especially easy to apply in the case of tabularized sampling distributions. In @infinite-area-lights, it is used to good effect for sampling environment map light sources.
][
  这种技术在处理表格化的采样分布时尤为简便。在@infinite-area-lights 中，它被有效地用于采样环境贴图光源。
]

=== Russian Roulette
<russian-roulette>

#parec[
  Russian roulette is a technique that can improve the efficiency of Monte Carlo estimates by skipping the evaluation of samples that would make a small contribution to the final result.
][
  俄罗斯轮盘赌是一种技术，可以通过跳过对最终结果贡献很小的样本的评估来提高蒙特卡洛估计的效率。在渲染过程中，我们常遇到以下形式的估计量：
]

$ frac(f (X) v (X), p (X)) , $

#parec[
  where the integrand consists of some factors $f (X)$ that are easily evaluated (e.g., those that relate to how the surface scatters light) and others that are more expensive to evaluate, such as a binary visibility factor $v (X)$ that requires tracing a ray. In these cases, most of the computational expense of evaluating the estimator lies in $v$ .
][
  其中被积函数由一些容易评估的因素 $f (X)$ （例如，与表面散射光相关的因素）和其他更昂贵的评估因素组成，例如需要追踪光线的二元可见性因子 $v (X)$ 。在这些情况下，评估估计量的计算开销主要在于 $v$ 。
]


#parec[
  If $f (X)$ is zero, it is obviously worth skipping the work of evaluating $v (X)$ , since its value will not affect the value of the estimator. However, if we also skipped evaluating estimators where $f (X)$ was small but nonzero, then we would introduce bias into the estimator and would systematically underestimate the value of the integrand. Russian roulette solves this problem, making it possible to also skip tracing rays when $f (X)$ 's value is small but not necessarily 0, while still computing the correct value on average.
][
  如果 $f(X)$ 为零，显然值得跳过 $v(X)$ 的评估工作，因为它的值不会影响估计量的值。然而，如果我们还跳过了 $f(X)$ 小但非零的估计量的评估，那么我们就会引入偏差，并系统性地低估被积函数的值。俄罗斯轮盘赌解决了这个问题，使得在 $f(X)$ 的值小但不一定为零时也可以跳过光线追踪，同时仍然在平均上计算出正确的值。
]



#parec[
  To apply Russian roulette, we select some termination probability $q$ . This value can be chosen in almost any manner; for example, it could be based on an estimate of the value of the integrand for the particular sample chosen, increasing as the integrand's value becomes smaller. With probability $q$ , the estimator is not evaluated for the particular sample, and some constant value $c$ is used in its place ( $c = 0$ is often used). With probability $1 - q$ , the estimator is still evaluated but is weighted by the factor $1 \/ (1 - q)$ , which effectively compensates for the samples that were skipped.
][
  为了应用俄罗斯轮盘赌，我们选择某个终止概率 $q$ 。这个值几乎可以以任何方式选择；例如，它可以基于对所选样本的被积函数值的估计，随着被积函数值变小而增加。以概率 $q$ ，特定样本的估计量不被评估，而是使用某个常数值 $c$ 代替（通常 $c = 0$ ）。以概率 $1 - q$ ，估计量仍然被评估，但通过因子 $1 \/ (1 - q)$ 加权，这有效地补偿了被跳过的样本。
]

#parec[
  We have the new estimator
][
  我们有新的估计量：
]

$ F prime = cases(delim: "{", frac(F - q c, 1 - q) & upright("if ") xi > q, c & upright("otherwise") .) $

#parec[
  It is easy to see that its expected value is the same as the expected value of the original estimator:
][
  很容易看出它的期望值与原始估计器的期望值相同：
]


$ E [F prime] = (1 - q) (frac(E [F] - q c, 1 - q)) + q c = E [F] . $
#parec[
  Russian roulette never reduces variance. In fact, unless somehow $c = F$ , it will always increase variance. However, it does improve Monte Carlo efficiency if the probabilities are chosen so that samples that are likely to make a small contribution to the final result are skipped.
][
  俄罗斯轮盘赌从不减少方差。事实上，除非某种方式 $c = F$ ，否则它总是会增加方差。然而，如果选择概率使得对最终结果贡献可能很小的样本被跳过，它确实提高了蒙特卡洛的效率。
]

=== Splitting
<mc-splitting>

#parec[
  While Russian roulette reduces the number of samples, splitting increases the number of samples in some dimensions of multidimensional integrals in order to improve efficiency. As an example, consider an integral of the general form
][
  尽管俄罗斯轮盘赌减少了样本数量，但样本分散在多维积分的某些维度上，增加了样本数量，从而提高效率。例如，考虑以下一般形式的积分：
]

$ integral_A integral_B f (x , y) thin d x thin d y . $ <splitting-candidate-integral>

#parec[
  With the standard importance sampling estimator, we might draw $n$ samples from independent distributions, $X_i prop p_x$ and $Y_i prop p_y$ , and compute
][
  采用标准重要性采样估计方法，我们可能从独立分布中抽取 $n$ 个样本， $X_i prop p_x$ 和 $Y_i prop p_y$ ，并计算
]


$ frac(1, n) sum_(i = 1)^n frac(f(X_i comma Y_i), p_x (X_i) p_y (Y_i)) . $
<splitting-std-estimator>

#parec[
  Splitting allows us to formalize the idea of taking more than one sample for the integral over $B$ for each sample taken in $A$ . With splitting, we might take $m$ samples $Y_(i,j)$ for each sample $x_i$ , giving the estimator
][
  分割使我们能够将针对 $A$ 中每个样本在 $B$ 上抽取多个样本的想法形式化。通过分割，我们可能为每个样本 $x_i$ 抽取 $m$ 个样本 $Y_(i,j)$ ，给出估计器
]

$ frac(1, n) sum_(i = 1)^n frac(1, m) sum_(j = 1)^m frac(f(X_i comma Y_(i comma j)), p_x (X_i) p_y (Y_(i comma j))) . $

#parec[
  If it is possible to partially evaluate $f(X_i)$ for each $X_i$ , then we can compute a total of $n m$ samples more efficiently than we had taken $n m$ independent $x_i$ values using @eqt:splitting-std-estimator.
][
  如果能够对每个 $x_i$ 进行部分评估 $f(X_i)$ ，那么我们在采样 $n m$ 个值时，可以比使用@eqt:splitting-std-estimator 抽取 $n m$ 个独立的 $x_i$ 值时，更有效。
]


#parec[
  For an example from rendering, an integral of the form of @eqt:splitting-candidate-integral is evaluated to compute the color of pixels in an image: an integral is taken over the area of the pixel $A$ where at each point in the pixel $x$ , a ray is traced into the scene and the reflected radiance at the intersection point is computed using an integral over the hemisphere (denoted here by $B$ ) for which one or more rays are traced. With splitting, we can take multiple samples for each lighting integral, improving efficiency by amortizing the cost of tracing the initial ray from the camera over them.
][
  在渲染领域中，形式如@eqt:splitting-candidate-integral 的积分被评估以计算图像中像素的颜色：在像素 $A$ 的区域内进行积分计算，其中在像素内的每个点 $x$ ，光线被追踪到场景中，并在交点处利用对半球（此处表示为 $B$ ）的积分来计算反射辐射，为此追踪一个或多个光线。通过分割，我们可以为每个光照积分抽取多个样本，通过在这些样本上分摊从相机追踪初始光线的成本，从而提高效率。
]
