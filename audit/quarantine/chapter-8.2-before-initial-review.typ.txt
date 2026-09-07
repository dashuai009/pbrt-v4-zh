#import "../template.typ": ez_caption, parec

== Sampling and Integration
<sampling-and-integration>
#parec[
  The lighting integration algorithms used throughout `pbrt` are based on Monte Carlo integration, yet the focus of Section @sampling-theory was on sampling and reconstruction. That topic is an important one for understanding aliasing and the use of filters for image reconstruction, but it is a different one than minimizing Monte Carlo integration error. There are a number of connections between Monte Carlo and both Fourier analysis and other approaches to analyzing point-sampling algorithms, however. For example, jittered sampling is a form of stratified sampling, a variance reduction technique that was introduced in @Stratified-Sampling . Thus, we can see that jittered sampling is advantageous from both perspectives.
][
  `pbrt` 中使用的光照积分算法基于蒙特卡罗积分，而@sampling-theory 的重点是采样和重建。这个主题对于理解混叠和使用滤波器进行图像重建非常重要，但与最小化蒙特卡罗积分误差不同。然而，蒙特卡罗与傅里叶分析和其他分析点采样算法的方法之间存在许多联系。例如，抖动采样是一种分层采样，是在@Stratified-Sampling 中介绍的方差减少技术。因此，我们可以看到，从两个角度来看，抖动采样都是有利的。
]

#parec[
  Given multiple perspectives on the problem, one might ask, what is the best sampling approach to use for Monte Carlo integration? There is no easy answer to this question, which is reflected by the fact that this chapter presents a total of 6 classes that implement the upcoming #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] interface to generate sample points, though a number of them offer a few variations of an underlying sampling approach, giving a total of 17 different techniques.
][
  考虑到问题的多种视角，人们可能会问，蒙特卡罗积分的最佳采样方法是什么？这个问题没有简单的答案，这反映在本章中介绍了总共 6 个类来实现即将到来的 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 接口以生成采样点，尽管其中一些提供了底层采样方法的几种变体，总共提供了 17 种不同的技术。
]

#parec[
  Although some of this variety is for pedagogy, it is largely due to the fact that the question of which sampling technique is best is not easily answered. Not only do the various mathematical approaches to analyzing sampling techniques often disagree, but another difficulty comes from the human visual system: rendered images are generally for human consumption and most mathematical approaches for evaluating sampling patterns do not account for this fact. Later in this chapter, we will see that sampling patterns that lead to errors in the image having blue noise characteristics are visually preferable, yet may not have any lower numeric error than those that do not. Thus, `pbrt` provides a variety of options, allowing the user to make their own choice among them.
][
  虽然这种多样性部分是为了教学，但主要是因为很难简单地回答哪种采样技术是最好的问题。各种数学方法在分析采样技术时往往意见不一，另一个困难来自人类视觉系统：渲染图像通常是供人类使用的，而大多数数学方法在评估采样模式时并未考虑这一事实。在本章后面，我们将看到导致图像中具有蓝噪声特征的误差的采样模式在视觉上更可取，但其数值误差可能并不比那些没有蓝噪声特征的模式低。因此，`pbrt` 提供了多种选项，允许用户在其中自行选择。
]

=== Fourier Analysis of Variance #emoji.warning
<fourier-analysis-of-variance>
#parec[
  Fourier analysis can also be applied to evaluate sampling patterns in the context of Monte Carlo integration, leading to insights about both variance and the convergence rates of various sampling algorithms. We will make three simplifications in our treatment of this topic here. There are more general forms of the theory that do not require these, though they are more complex. (As always, see the "Further Reading" section for more information.) We assume that:
][
  傅里叶分析也可以用于在蒙特卡罗积分的背景下评估采样模式，从而对各种采样算法的方差和收敛速度提供见解。我们将在这里对这一主题的处理进行三个简化。更一般的理论形式不需要这些简化，尽管它们更复杂。（一如既往，参见“进一步阅读”部分以获取更多信息。）我们假设：
]

#parec[
  + The sample points are uniformly distributed and equally weighted
    (i.e., importance sampling is not being used).
  + The Monte Carlo estimator used is unbiased. 、
  + The properties of the sample points are homogeneous with respect to
    toroidal translation over the sampling domain. (If they are not, the
    analysis is effectively over all possible random translations of the
    sample points.)
][
  + 采样点均匀分布且权重相等（即未使用重要性采样）。
  + 使用的蒙特卡罗估计器是无偏的。
  + 样本点的属性相对于采样域上的环形平移是齐次的（均匀的、homogeneous）。（如果不是，分析实际上是对所有可能的随机平移后的样本点进行的。）
]

#parec[
  Excluding importance sampling has obvious implications, though we note that the last assumption, homogeneity, is also significant. Many of the sampling approaches later in this chapter are based on decomposing the $[0 , 1]^n$ sampling domain into strata and placing a single sample in each one. Homogenizing such algorithms causes some of those regions to wrap around the boundaries of the domain, which harms their effectiveness. Equivalently, homogenization can be seen as toroidally translating the function being integrated, which can introduce discontinuities that were not previously present. Nevertheless, we will see that there is still much useful insight to be had about the behavior of sampling patterns in spite of these simplifications.
][
  排除重要性采样有明显的影响，但我们注意到最后一个假设，即均匀性，也很重要。本章后面的许多采样方法基于将 $[0 , 1]^n$ 采样域分解为层，并在每个层中放置一个样本。均匀化这样的算法会导致其中一些区域绕过域的边界，从而损害其有效性。同样，均匀化可以看作是对被积分的函数进行环形平移，这可能引入先前不存在的不连续性。尽管如此，我们将看到，尽管有这些简化，关于采样模式行为的见解仍然非常有用。
]

#parec[
  Our first step is to introduce the #emph[Fourier series] representation of functions, which we will use as the basis for analysis of sampling patterns for the remainder of this section. The Fourier transform assumes that the function $f (x)$ has infinite extent, while for rendering we are generally operating over the $[0 , 1]^n$ domain or on mappings from there to other finite domains such as the unit hemisphere. While it is tempting to apply the Fourier transform as is, defining $f (x)$ to be zero outside the domain of interest, doing so introduces a discontinuity in the function at the boundaries that leads to error due to the Gibbs phenomenon in the Fourier coefficients. Fourier series are defined over a specific finite domain and so do not suffer from this problem.
][
  我们的第一步是介绍函数的 #emph[傅里叶级数] 表示，我们将其用作本节余下部分分析采样模式的基础。傅里叶变换假设函数 $f (x)$ 具有无限范围，而对于渲染，我们通常在 $[0 , 1]^n$ 域上或从那里映射到其他有限域（如单位半球）进行操作。虽然直接应用傅里叶变换很有诱惑力，将 $f (x)$ 定义为在感兴趣域之外为零，但这样做会在边界处引入函数的不连续性，从而由于傅里叶系数中的吉布斯现象导致误差。傅里叶级数是在特定有限域上定义的，因此不会出现这个问题。
]

#parec[
  The Fourier series represents a function using an infinite set of coefficients $f_j$ for all integer-valued $j gt.eq 0$. (We use $j$ to index coefficients in order to avoid confusion with the use of $i$ for the unit imaginary number.) For the $\[0 , 1\)$ domain, the coefficients are given by#footnote[We will continue to stick with 1D for Fourier analysis,
    though as before, all concepts extend naturally to multiple dimensions.]
][
  傅里叶级数使用一组无限的系数 $f_j$ 表示函数，适用于所有整数值 $j gt.eq 0$。（我们使用 $j$ 来索引系数，以避免与单位虚数 $i$ 的使用混淆。）对于域 $\[0 , 1\)$ ，系数由以下公式给出#footnote[We will continue to stick with 1D for Fourier analysis,
    though as before, all concepts extend naturally to multiple dimensions.]
]
$ f_j = integral_(\[0 , 1\)) f (x) e^(- i 2 pi j x) d x . $
<fourier-series-analysis>

#parec[
  (Domains other than $\[0 , 1\)$ can be handled using a straightforward reparameterization.)
][
  （其他域可以通过简单的重新参数化来处理。）
]
#parec[
  Expressed using the Fourier series coefficients, the original function is
][
  使用傅里叶级数系数表示，原始函数为
]

$ f (x) = sum_(j in ZZ) f_j e^(- i 2 pi j x) . $<fourier-series-synthesis>

#parec[
  It can be shown that the continuous Fourier transform corresponds to the limit of taking the Fourier series with an infinite extent.
][
  可以证明，连续傅里叶变换对应于取傅里叶级数的无限范围的极限。
]

#parec[
  The PSD of a function in the Fourier series basis is given by the product of each coefficient with its complex conjugate,
][
  傅里叶级数的基中的函数的 PSD 由每个系数与其复共轭的乘积给出，
]
$ P_f (j) = f_j overline(f_j) . $

#parec[
  In order to analyze Monte Carlo integration in frequency space, we will start by defining the sampling function $s (x)$ for a set of sample points $x_i$ as the averaged sum of $n$ samples, each represented by a delta distribution,
][
  为了在频率空间中分析蒙特卡罗积分，我们将首先定义一组采样点 $x_i$ 的采样函数 $s (x)$，作为 $n$ 个样本的平均和，每个样本由一个 delta 分布表示，
]


$ s (x) = 1 / n sum_(i = 1)^n delta (x - x_i) $
#parec[
  Given the sampling function, it is possible to rewrite the Monte Carlo estimator as an integral:
][
  给定采样函数，可以将蒙特卡罗估计量重写为积分形式：
]

$
  integral_(\[ 0 , 1 \)) f (x) thin d x & approx 1 / n sum_(i = 1)^n f (x_i) \
                                    med & = integral_(\[ 0 , 1 \)) f (x) s (x) thin d x
$<mc-estimator-continuous>
#parec[
  It may seem like we are moving backward: after all, the point of Monte Carlo integration is to transform integrals into sums. However, this transformation is key to being able to apply the Fourier machinery to the problem.
][
  这看起来像是在倒退：毕竟，蒙特卡罗积分的目的是将积分转化为求和。然而，这种转化是能够将傅里叶方法应用于问题的关键。
]

#parec[
  If we substitute the Fourier series expansion of @eqt:fourier-series-synthesis into @eqt:mc-estimator-continuous, we can find that:
][
  如果将@eqt:fourier-series-synthesis 的傅里叶级数展开式代入@eqt:mc-estimator-continuous，我们可以发现：
]

$ integral_(\[ 0 , 1 \)) f (x) s (x) thin d x = sum_(j in bb(Z)) f_j overline(s_j) . $
#parec[
  From the definition of the Fourier series coefficients, we know that $f_0 = overline(f_0) = integral f (x) thin d x$. Furthermore, $s_0 = 1$ from the definition of $s (x)$ and the assumption of uniform and unweighted samples. Therefore, the error in the Monte Carlo estimate is given by
][
  从傅里叶级数系数的定义中，我们知道 $f_0 = overline(f_0) = integral f (x) thin d x$。此外，从 $s (x)$ 的定义和均匀无权样本的假设中得知 $s_0 = 1$。因此，蒙特卡罗估计的误差为：
]

$
  lr(|integral_(\[ 0 , 1 \)) f (x) thin d x - integral_(\[ 0 , 1 \)) f (x) s (x) thin d x|) = lr(|f_0 - sum_(j in bb(Z)) f_j overline(s_j)|) = sum_(j in bb(Z)^(\*)) f_j overline(s_j) ,
$<fourier-mc-error>
#parec[
  where $bb(Z)^(\*)$ denotes the set of all integers except for zero.
][
  其中 $bb(Z)^(\*)$ 表示除零以外的所有整数集合。
]

#parec[
  @eqt:fourier-mc-error is the key result that gives us insight about integration error. It is worth taking the time to understand and to consider the implications of it. For example, if $f$ is band limited, then $f_j = 0$ for all $j$ after some value $j_(upright("max"))$. In that case, if $s$ 's sampling rate is at least equal to $f$ 's highest frequency, then $s_j = 0$ for all $0 < j < j_(upright("max"))$ and a zero variance estimator is the result. Only half the sampling rate is necessary for perfect integration compared to what is needed for perfect reconstruction!
][
  @eqt:fourier-mc-error 是关于积分误差的关键结果。值得花时间去理解并考虑其影响。例如，如果 $f$ 是带限的，那么对于所有大于某个值 $j_(upright("max"))$ 的 $j$， $f_j = 0$。在这种情况下，如果 $s$ 的采样率至少等于 $f$ 的最高频率，那么对于所有 $0 < j < j_(upright("max"))$， $s_j = 0$，结果是零方差估计量。相比于完美重建，完美积分所需的采样率仅需一半！
]

#parec[
  Using @eqt:fourier-mc-error with the definition of variance, it can be shown that the variance of the estimator is given by the sum of products of $f (x)$ 's and $s (x)$ 's PSDs:
][
  使用 @eqt:fourier-mc-error 和方差定义，可以证明估计量的方差由 $f (x)$ 和 $s (x)$ 的功率谱密度(PSD)的乘积之和给出：
]

$ V [1 / n sum_(i = 1)^n f (x_i)] = sum_(j in bb(Z)^(\*)) cal(P)_f (j) cal(P)_s (j) . $<mc-estimator-variance-psd>
#parec[
  This gives a clear direction about how to reduce variance: it is best if the power spectrum of the sampling pattern is low where the function's power spectrum is high. In rendering, the function is generally not available analytically, let alone in the Fourier series basis, so we follow the usual expectation that the function has most of its frequency content in lower frequencies. This assumption argues for a sampling pattern with its energy concentrated in higher frequencies and minimal energy in the lower frequencies—precisely the same blue noise criterion that we earlier saw was effective for antialiasing.
][
  这为降低方差提供了明确的方向：最好是采样模式的功率谱在函数的功率谱高的地方较低。在渲染中，函数通常无法解析，更不用在傅里叶级数的基底，因此我们通常期望函数的大多数频率内容集中在较低频率。这一假设支持采样模式的能量集中在较高频率，且在较低频率中能量最小——正是我们之前看到的对抗锯齿有效的蓝噪声标准。
]

#parec[
  An insight that directly follows from @eqt:mc-estimator-variance-psd is that with uniform random sampling (i.e., white noise), $cal(P)_s$ is the constant $1 \/ n$, which leads to the variance of:
][
  从@eqt:mc-estimator-variance-psd 直接得出的是，对于均匀随机采样（即白噪声）， $cal(P)_s$ 是常数 $1 \/ n$，这导致方差为：
]

$ 1 / n sum_(j in bb(Z)^(\*)) cal(P)_f (j) = O (1 / n) , $
#parec[
  which is the same variance of the Monte Carlo estimator that was derived earlier using different means in @error-in-monte-carlo-estimators . More generally, if the PSD for a sampling technique can be asymptotically bounded, it can be shown that the technique exhibits a higher rate of variance reduction given a suitable function being integrated. One example is that in 2D, a jittered sampling pattern can achieve $O (n^(- 2))$ variance, given a smooth integrand.
][
  这与之前在@error-in-monte-carlo-estimators 中通过不同方法推导出的蒙特卡罗估计量的方差相同。更一般地说，如果一种采样技术的功率谱密度可以渐近有界，则可以证明该技术在给定合适的被积函数时更快降低方差。一个例子是在二维中，抖动采样模式可以实现 $O (n^(- 2))$ 的方差，前提是被积函数是光滑的。
]

#parec[
  Fourier analysis has also revealed that Poisson disk sampling patterns have unexpectedly bad asymptotic convergence. Poisson disk point sets are constructed such that no two points can be closer than some minimum distance $d$ (see Figure~8.16). For many years, they were believed to be superior to jittered patterns. The Poisson disk criterion is an appealing one, as it prohibits multiple samples from clumping close together, as is possible with adjacent jittered samples.
][
  傅里叶分析还揭示了泊松盘采样模式具有意外的糟糕渐近收敛性。泊松盘点集的构造方式是没有两个点可以比某个最小距离 $d$ 更近（见图~8.16）。多年来，人们认为它们优于抖动模式。泊松盘标准具有吸引力，因为它禁止多个样本聚集在一起，这在相邻抖动样本中是可能的。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f16.svg"),
  caption: [
    #ez_caption[256 sample points distributed using (a)~a jittered
      distribution, and (b)~a Poisson disk distribution. Poisson disk point
      sets combine some randomness in the locations of the points with some
      structure from no two of them being too close together.][256 个样本点使用 (a)~抖动分布和 (b)~泊松盘分布。泊松盘点集结合了一些点位置的随机性和没有两个点太接近的结构。]
  ],
)


#parec[
  Part of the appeal of Poisson disk patterns is that initially they seem to have superior blue noise characters to jittered patterns, with a much larger range of frequencies around the origin where the PSD is low. Figure~8.17 shows the PSDs of 2D jittered and Poisson disk sample points. Both feature a spike at the origin, a ring of low energy around it, and then a transition to fairly equal-energy noise at higher frequencies.
][
  泊松盘模式的吸引力部分在于它们似乎比抖动模式具有更优越的蓝噪声特性，在原点周围有更大的低PSD。图~8.17 显示了二维抖动和泊松盘样本点的功率谱密度。两者都在原点有一个尖峰，周围有一个低能量环，然后过渡到较高频率的相对均等能量噪声。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f17.svg"),
  caption: [
    #ez_caption[
      PSDs of (a) jittered and (b) Poisson disk-distributed sample points. The origin with the central spike is at the center of each image.
    ][
      (a)~抖动和
      (b)~泊松盘分布样本点的功率谱密度。中心尖峰位于每个图像的中心。
    ]
  ],
)<jittered-poisson-disk-psds>

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f18.svg"),
  caption: [
    #ez_caption[
      Radially averaged PSDs of (a)~jittered and (b)~Poisson
      disk-distributed sample points.
    ][
      (a)~抖动和 (b)~泊松盘分布样本点的径向平均功率谱密度。
    ]
  ],
)<radially-averaged-psds>

#parec[
  However, radially averaged plots of the distribution of energy in these PSDs, however, makes their behavior in the low frequencies more clear; see @fig:radially-averaged-psds. #footnote[Some
    of the sampling patterns that we will see later in the
    chapter have anisotropic PSDs, in which case a radial average loses some
    information about their behavior, though these two patterns are both
    isotropic and thus radially symmetric.] We can see that although the Poisson disk pattern has low energy for a larger range of frequencies than the jittered pattern, its PSD retains a small amount of energy all the way until~0, while the jittered pattern does~not.
][
  然而，径向平均图使这些功率谱密度在低频率中的行为更加清晰；见@fig:radially-averaged-psds。#footnote[Some
    of the sampling patterns that we will see later in the
    chapter have anisotropic PSDs, in which case a radial average loses some
    information about their behavior, though these two patterns are both
    isotropic and thus radially symmetric.] 我们可以看到，虽然泊松盘模式在比抖动模式更大范围的频率上能量较低，但其功率谱密度在直到~0 的范围内仍保留少量能量，而抖动模式则没有。
]


#parec[
  Using Fourier analysis of variance, it can be shown that due to this lingering energy, the variance when using Poisson disk sampling is never any better than $O (n^(- 1))$ —worse than jittered points for some integrands. (Though remember that these are asymptotic bounds, and that for small $n$, Poisson disk-distributed points may give lower variance.) Nevertheless, the poor asymptotic convergence for what seems like it should be an effective sampling approach was a surprise, and points to the value of this form of analysis.
][
  通过方差的傅里叶分析，可以证明由于这种残留能量，使用泊松盘采样时的方差从未优于 $O (n^(- 1))$ ——对于某些被积函数甚至比抖动点更差。（不过请记住，这些是渐近界，对于小 $n$，泊松盘分布的点可能会给出更低的方差。） 尽管如此，对于这种似乎应该是有效的采样方法的糟糕渐近收敛性是一个惊喜，并指出了这种分析形式的价值。
]

=== Low Discrepancy and Quasi Monte Carlo
#parec[
  Outside of Fourier analysis, another useful approach for evaluating the quality of sample points is based on a concept called #emph[discrepancy];. Well-distributed sampling patterns have low discrepancy, and thus the sample pattern generation problem can be considered to be one of finding a suitable pattern of points with low discrepancy.
][
  除了傅里叶分析之外，评估样本点质量的另一种有用方法是基于一个称为#emph[不一致性];的概念。分布良好的采样模式具有低不一致性，因此样本模式生成问题可以看作是寻找具有低不一致性的合适点模式的问题。
]

#parec[
  In discussing the discrepancy of sample points, we will draw a distinction between #emph[sample sets];, which are a specific number of points, and #emph[sample sequences];, which are defined by an algorithm that can generate an arbitrary number of points. For a fixed number of samples, it is generally possible to distribute points in a sample set slightly better than the same number of points in a sample sequence. However, sequences can be especially useful with adaptive sampling algorithms, thanks to their flexibility in the number of points they generate.
][
  在讨论样本点的不一致性时，我们将区分#emph[样本集];（即特定数量的点）和#emph[样本序列];（由一个可以生成任意数量点的算法定义）。对于固定数量的样本，通常可以在样本集中比在样本序列中稍微更好地分布点。 然而，序列由于其在生成点数量上的灵活性，在自适应采样算法中尤其有用。
]

#parec[
  The basic idea of discrepancy is that the quality of a set of points in a $d$ -dimensional space $[0 , 1]^d$ can be evaluated by looking at regions of the domain $[0 , 1]^d$, counting the number of points inside each region, and comparing the volume of each region to the number of sample points inside. In general, a given fraction of the volume should have roughly the same fraction of the total number of sample points inside of it. While it is not possible for this always to be the case, we can still try to use patterns that minimize the maximum difference between the actual volume and the volume estimated by the points (the #emph[discrepancy];).@fig:discrepancy-2d shows an example of the idea in two dimensions.
][
  不一致性的基本思想是，通过观察 $d$ 维空间 $[0 , 1]^d$ 的区域，计算每个区域内的点数，并将每个区域的体积与其中的样本点数进行比较，从而评估一组点的质量。 一般来说，给定体积的某个比例应大致与其中的样本点总数的比例相同。虽然不可能总是如此，但我们仍然可以尝试使用那些能够最小化实际体积与点估计体积之间最大差异（即#emph[不一致性];）的模式。@fig:discrepancy-2d 展示了二维中这一思想的一个例子。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f19.svg"),
  caption: [
    #ez_caption[
      The discrepancy of a box (shaded) given a set of 2D sample points in $\[0,1\)^2$. One of the four sample points is inside the box, so this set of points would estimate the box's area to be $1\/4$. The true area of the box is $0.3 times 0.3 = 0.09$, so the discrepancy for this particular box is $0.25 - 0.09 = 0.16$. In general, we are interested in finding the maximum discrepancy of all possible boxes (or some other shape).
    ][
      在$\[0,1\)^2$中的一组二维样本点下，盒子的差异度（阴影部分）。四个样本点中有一个位于盒子内，因此该样本集估计盒子的面积为$1\/4$。盒子的真实面积是$0.3 times 0.3 = 0.09$，所以这个盒子的差异度是$0.25 - 0.09 = 0.16$。一般来说，我们感兴趣的是找到所有可能的盒子（或其他形状）的最大差异度。
    ]
  ],
)<discrepancy-2d>
#parec[
  To compute the discrepancy of a set of points, we first pick a family of shapes $B$ that are subsets of $[0 , 1]^d$. For example, boxes with one corner at the origin are often used. This corresponds to
][
  为了计算一组点的不一致性，我们首先选择一个形状族 $B$，它们是 $[0 , 1]^d$ 的子集。例如，通常使用一个角在原点的盒子。 这对应于
]
$ B = {[0 , v_1] times [0 , v_2] times dots.h.c times [0 , v_d] thin \| thin 0 lt.eq v_i < 1} , $
#parec[
  given a set of $n$ sample points $P = { x_1 , dots.h , x_n }$, the discrepancy of $P$ with respect to $B$ is
][
  给定一组 $n$ 个样本点 $P = { x_1 , dots.h , x_n }$， $P$ 相对于 $B$ 的不一致性为
]

$ D_n (B , P) = sup_(b in B) lr(|frac(#sym.hash{x_i in b}, n) - V (b)|) , $<discrepancy>

#parec[
  where $#sym.hash{x_i in b}$ is the number of points in $b$ and $V (b)$ is the volume of $b$.
][
  其中 $#sym.hash{x_i in b}$ 是 $b$ 中的点数， $V (b)$ 是 $b$ 的体积。
]

#parec[
  The intuition for why @eqt:discrepancy is a reasonable measure of quality is that the value $N {x_i in b} \/ n$ is an approximation of the volume of the box $b$ given by the particular points $P$. Therefore, the discrepancy is the worst error over all possible boxes from this way of approximating the volume. When the set of shapes $B$ is the set of boxes with a corner at the origin, this value is called the #emph[star discrepancy];, $D_n^(\*) (P)$.Another popular option for $B$ is the set of all axis-aligned boxes, where the restriction that one corner be at the origin has been removed.
][
  为什么@eqt:discrepancy 是一个合理的质量测量？直觉上来说，值 $\#{x_i in b} \/ n$ 是由特定点 $P$ 给出的盒子 $b$ 体积的近似。 因此，不一致性是通过这种方式近似体积的所有可能盒子中最差的误差。当形状集 $B$ 是一个角在原点的盒子集时，这个值被称为#emph[星不一致性];， $D_n^(\*) (P)$。 另一个常见的选择是 $B$ 为所有轴对齐的盒子集合，不再要求其中一个角在原点。
]

#parec[
  For some point sets, the discrepancy can be computed analytically. For example, consider the set of points in one dimension
][
  对于某些点集，不一致性可以通过解析计算。例如，考虑一维中的点集
]
$ x_i = i / n . $
#parec[
  We can see that the star discrepancy of $x_i$ is
][
  可以计算出 $x_i$ 的星不一致性为
]

$ D_n^(\*) (x_1 , dots.h , x_n) = 1 / n . $

#parec[
  For example, take the interval $b = lr(\[0, 1 / n\))$. Then $V (b) = 1 / n$, but $N {x_i in b} = 0$ This interval (and the intervals $lr(\[0, 2 / n\))$, etc.) is the interval where the largest differences between volume and fraction of points inside the volume are seen.
][
  例如，取区间 $b = lr(\[0, 1 / n\))$。那么 $V (b) = 1 / n$，但 $N {x_i in b} = 0$。 在这个区间（以及区间 $lr(\[0, 2 / n\))$ 等）中，体积与体积内点数比例之间的差异最大。
]

#parec[
  The star discrepancy of this point set can be improved by modifying it slightly:
][
  通过稍微修改这个点集可以改善其星不一致性：
]

$ x_i = frac(i - 1 / 2, n) . $<shifted-regular-1d>


#parec[
  Then
][
  然后
]

$ D_n^(\*) (x_i) = frac(1, 2 n) . $

#parec[
  The bounds for the star discrepancy of a sequence of points in one dimension have been shown to be
][
  已证明一维点序列的星不一致性界限为
]

$ D_n^(\*) (x_i) = frac(1, 2 n) + max_(1 lt.eq i lt.eq n) lr(|x_i - frac(2 i - 1, 2 n)|) . $


#parec[
  Thus, the earlier set from @eqt:shifted-regular-1d has the lowest possible discrepancy for a sequence in 1D. In general, it is much easier to analyze and compute bounds for the discrepancy of sequences in 1D than for those in higher dimensions. When it is not possible to derive the discrepancy of a sampling technique analytically, it can be estimated numerically by constructing a large number of shapes $b$, computing their discrepancy, and reporting the maximum value found.
][
  因此，@eqt:shifted-regular-1d 中的早期集合对于一维序列具有最低的可能不一致性。一般来说，分析和计算一维序列的不一致性界限比高维序列要容易得多。 当无法解析地推导出采样技术的不一致性时，可以通过构建大量形状 $b$，计算其不一致性，并报告发现的最大值来进行数值估计。
]

#parec[
  The astute reader will notice that according to the discrepancy measure, the uniform sequence in 1D is optimal, but Fourier analysis indicated that jittering was superior to uniform sampling.Fortunately, low-discrepancy patterns in higher dimensions are much less uniform than they are in one dimension and thus usually work reasonably well as sample patterns in practice.Nevertheless, their underlying uniformity means that low-discrepancy patterns can be more prone to visually objectionable aliasing than patterns with pseudo-random variation.
][
  敏锐的读者会注意到，根据不一致性度量，一维中的均匀序列是最优的，但傅里叶分析表明抖动（即在采样中引入随机扰动）优于均匀采样。 幸运的是，高维中的低不一致性模式比一维中的均匀性要差得多，因此在实践中通常作为样本模式效果相当好。 然而，它们的基本均匀性意味着低不一致性模式比具有伪随机变化的模式更容易出现视觉上令人反感的混叠。
]

#parec[
  A $d$ -dimensional sequence of points is said to have #emph[low
    discrepancy] if its discrepancy is of the order
][
  如果一个 $d$ 维点序列的不一致性是如下的量级，则称其具有#emph[低不一致性];。
]
$ O ((log n)^d / n) . $<ld-definition>

#parec[
  These bounds are the best that are known for arbitrary $d$.
][
  这些界限是已知的任意 $d$ 的最佳界限。
]

#parec[
  Low-discrepancy point sets and sequences are often generated using deterministic algorithms; we will see a number of such algorithms in @halton-sampler and @sobol-samplers . Using such points to sample functions for integration brings us to #emph[quasi-Monte Carlo] (QMC) methods. Many of the techniques used in regular Monte Carlo algorithms can be shown to work equally well with such #emph[quasi-random] sample points.
][
  低不一致性点集和序列通常使用确定性算法生成；我们将在@halton-sampler 和 @sobol-samplers 节中看到许多这样的算法。 使用这些点来对函数进行采样以进行积分将我们引入#emph[准蒙特卡罗];（QMC）方法。 许多常规蒙特卡罗算法中使用的技术可以证明在使用这种#emph[准随机];样本点时同样有效。
]

#parec[
  The #emph[Koksma-Hlawka inequality] relates the discrepancy of a set of points used for integration to the error of an estimate of the integral of a function $f$. It is:
][
  #emph[Koksma-Hlawka 不等式];将用于积分的点集的不一致性与函数 $f$ 积分估计的误差联系起来。它是：
]
$ lr(|integral f (x) thin d x - 1 / n sum_i f (x_i)|) lt.eq D_n (B , P) V_f , $<koksma-hlawka>


#parec[
  where $V_f$ is the #emph[total variation] of the function $f$ being integrated.It is defined as
][
  其中 $V_f$ 是被积分函数 $f$ 的#emph[总变差];。它被定义为
]

$ V_f = sup_(0 = y_1 < y_2 < dots.h.c < y_m = 1) sum_(i = 1)^m lr(|f (y_i) - f (y_(i + 1))|) , $


#parec[
  over all partitions of the $[0 , 1]$ domain at points $y_i$. In essence, the total variation represents how quickly the function's value ever changes between points, and the discrepancy represents how effective the points used for integration are at catching the function's variation.
][
  在 $[0 , 1]$ 区域的所有分区点 $y_i$ 上。 总变差本质上表示函数值在点之间变化的速度，而不一致性表示用于积分的点捕捉函数变化的有效性。
]

#parec[
  Given the definition of low discrepancy from @eqt:ld-definition, we can see from the Koksma-Hlawka inequality that as the dimensionality $d$ of the integrand increases, the integration error with low discrepancy approaches $O (n^(- 1))$, which is asymptotically much better than the $O (n^(- 1 \/ 2))$ error from Monte Carlo integration (@error-in-monte-carlo-estimators).Note also that these error bounds are asymptotic; in practice, QMC usually has an even better rate of convergence.
][
  根据@eqt:ld-definition 中低不一致性的定义，我们可以从 Koksma-Hlawka 不等式中看到，随着被积函数的维数 $d$ 增加，低不一致性积分的误差接近 $O (n^(- 1))$，这在渐近地比蒙特卡罗积分（@error-in-monte-carlo-estimators）的 $O (n^(- 1 \/ 2))$ 误差要好得多。 还要注意，这些误差界限是渐近的；在实践中，QMC 通常具有更好的收敛速度。
]

#parec[
  However, because QMC integration is deterministic, it is not possible to use variance as a measure of an estimator's quality, though of course one can still compute the mean squared error. Alternatively, the sample points can be randomized using approaches that are carefully designed not to harm their discrepancy. We will see later in the chapter that randomization can even lead to improved rates of convergence. Such approaches are #emph[randomized quasi-Monte Carlo] (RQMC) methods and again allow the use of variance. RQMC is the foundation of most of `pbrt`'s Monte Carlo integration algorithms.
][
  然而，由于 QMC 积分是确定性的，因此无法使用方差作为估计器质量的度量，尽管当然仍然可以计算均方误差（即误差的平方平均值）。 或者，可以使用精心设计的方法对样本点进行随机化，以确保不损害其不一致性。 我们将在本章后面看到，随机化甚至可以提高收敛速度。 这些方法是#emph[随机化准蒙特卡罗];（RQMC）方法，并再次允许使用方差。 RQMC 是大多数 `pbrt` 的蒙特卡罗积分算法的基础。
]

#parec[
  In most of this text, we have glossed over the differences between Monte Carlo, QMC, and RQMC, and have localized the choice among them in the `Sampler`s in this chapter. Doing so introduces the possibility of subtle errors if a `Sampler` generates quasi-random sample points that an `Integrator` then improperly uses as part of an implementation of an algorithm that is not suitable for quasi Monte Carlo, though none of the integrators described in the text do so.
][
  在本文的大部分内容中，我们忽略了蒙特卡罗、QMC 和 RQMC 之间的差异，并在本章的 `Sampler` 中将选择集中在它们之间。 这样做引入了细微错误的可能性，如果一个 `Sampler` 生成准随机样本点，而一个 `Integrator` 然后不当使用它们作为不适合准蒙特卡罗的算法实现的一部分，尽管本文中描述的积分器没有这样做。
]


