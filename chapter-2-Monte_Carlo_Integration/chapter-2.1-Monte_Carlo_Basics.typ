#import "../template.typ": parec, ez_caption

== #ez_caption[Monte Carlo: Basics][蒙特卡洛基础]
<mc-basics>


#parec[
  Because Monte Carlo integration is based on randomization, we will start this chapter with a brief review of ideas from probability and statistics that provide the foundations of the approach. Doing so will allow us to introduce the basic Monte Carlo algorithm as well as mathematical tools for evaluating its error.
][
  由于蒙特卡洛积分基于随机化，本章将从回顾概率和统计的基本概念开始，这些概念为蒙特卡洛方法奠定了基础。这样做将使我们能够介绍基本的蒙特卡洛算法以及评估其误差的数学工具。
]



=== #ez_caption[Background and Probability Review][背景与概率知识回顾]

#parec[
  We will start by defining some terms and reviewing basic ideas from probability. We assume that the reader is already familiar with basic probability concepts; readers needing a more complete introduction to this topic should consult a textbook such as Sheldon Ross's #emph[Introduction to Probability Models] (@ross2002probability ).
][
  我们将从定义一些术语和回顾概率的基本概念开始。我们假设读者已经熟悉基本的概率概念；需要更完整介绍的读者可以参考如 Sheldon Ross 的《概率模型导论》（@ross2002probability）等教科书。
]

#parec[
  A #emph[random variable] $X$ is a value chosen by some random process. We will generally use capital letters to denote random variables, with exceptions made for a few Greek symbols that represent special random variables. Random variables are always drawn from some domain, which can be either discrete (e.g., a fixed, finite set of possibilities) or continuous (e.g., the real numbers $bb(R)$). Applying a function $f$ to a random variable $X$ results in a new random variable ( $Y = f(X)$ ).
][
  #emph[随机变量] $X$ 是由某个随机过程选择的一个值。我们通常用大写字母表示随机变量，少数表示特殊随机变量的希腊符号除外。随机变量总是在某个定义域中取值，这个域可以是离散的（例如，一组固定的有限可能性）或连续的（例如，实数 $bb(R)$ ）。对随机变量 $X$ 应用函数 $f$ 会得到一个新的随机变量 $Y = f(X)$。
]



#parec[
  For example, the result of a roll of a die is a discrete random variable sampled from the set of events $X_i in {1, 2, 3, 4, 5, 6}$. Each event has a probability $p_i=1/6$ , and the sum of probabilities $sum p_i$ is necessarily one. A random variable like this one that has the same probability for all potential values of it is said to be #emph[uniform]. A function $p(X)$ that gives a discrete random variable's probability is termed a #emph[probability mass function] (PMF), and so we could equivalently write $p(X) = 1/6$ in this case.
][
  例如，掷骰子的结果是从事件集合 $X_i in {1, 2, 3, 4, 5, 6}$ 中采样的离散随机变量。每个事件的概率 $p_i = 1/6$，并且概率的总和 $sum p_i$ 必然为 1。这种所有可能值具有相同概率的随机变量被称为#emph[均匀分布]。给出离散随机变量概率的函数 $p(X)$ 被称为#emph[概率质量函数]（PMF），因此在这种情况下我们可以等价地写成 $p(X) = 1/6$。
]


#parec[
  Two random variables are #emph[independent] if the probability of one does not affect the probability of the other. In this case, the #emph[joint probability] $p(X, Y)$ of two random variables is given by the product of their probabilities:
][
  两个随机变量如果其中一个的概率不影响另一个的概率，则这两个随机变量是#emph[独立]的，在这种情况下，两个随机变量的#emph[联合概率] $p(X, Y)$ 由它们的概率的乘积给出：
]


$ p(X, Y) = p(X) p(Y). $



#parec[
  For example, two random variables representing random samples of the six sides of a die are independent.
][
  例如，分别表示两次随机掷骰子结果的随机变量是独立的。
]



#parec[
  For #emph[dependent] random variables, one's probability affects the other's. Consider a bag filled with some number of black balls and some number of white balls. If we randomly choose two balls from the bag, the probability of the second ball being white is affected by the color of the first ball since its choice changes the number of balls of one type left in the bag. We will say that the second ball's probability is #emph[conditioned] on the choice of the first one. In this case, the joint probability for choosing two balls $X$ and $Y$ is given by
][
  对于#emph[不独立]的随机变量，一个的概率会影响另一个的概率。考虑一个装有若干黑球和白球的袋子。如果我们从袋子中随机选择两个球，第二个球是白色的概率会受到第一个球颜色的影响，因为选择第一个球会改变袋中某种颜色球的数量。我们称第二个球的概率#emph[以第一个球的选择为条件]。在这种情况下，选择两个球 $X$ 和 $Y$ 的联合概率由下式给出：
]

$ p(X, Y) = p(X) p(Y|X), $ <conditional-2d-density>


#parec[
  where $p(Y|X)$ is the #emph[conditional probability] of $Y$ given a value of $X$.
][
  其中 $p(Y|X)$ 是给定 $X$ 值时 $Y$ 的#emph[条件概率]。
]


#parec[
  In the following, it will often be the case that a random variable's probability is conditioned on many values; for example, when choosing a light source from which to sample illumination, the `BVHLightSampler` in @bvh-light-sampling considers the 3D position of the receiving point and its surface normal, and so the choice of light is conditioned on them. However, we will often omit the variables that a random variable is conditioned on in cases where there are many of them and where enumerating them would obscure notation.
][
  在后续内容中，随机变量的概率往往依赖于多个值；例如，@bvh-light-sampling 中的 `BVHLightSampler` 在选择用于采样光照的光源时，会考虑接收点的三维位置及其表面法线，因此光源的选择依赖于这些因素。然而，当条件变量很多、逐一列出会使记号难以辨读时，我们通常省略这些条件变量。
]

#let f_en_211 = "Although the theory of Monte Carlo is based on using truly random numbers, in practice a well-written pseudo-random number generator (PRNG) is sufficient. pbrt uses a particularly high-quality PRNG that returns a sequence of pseudo-random values that is effectively as “random” as true random numbers.  True random numbers, found by measuring random phenomena like atomic decay or atmospheric noise, are available from sources like www.random.org for those for whom PRNGs are not acceptable."

#let f_zh_211 = "虽然蒙特卡洛理论是基于使用真正的随机数，但在实践中，一个编写良好的伪随机数生成器（PRNG）已经足够。pbrt 使用了一个质量很高的 PRNG，它返回的伪随机值序列在效果上与真正的随机数几乎一样“随机”。对于那些不能接受 PRNG 的人来说，可以通过测量原子衰变或大气噪声等随机现象获得真正的随机数，这些随机数可以从例如 www.random.org 等来源获取。"

#parec[
  A particularly important random variable is the #emph[canonical uniform random variable], which we will write as $xi$. This variable takes on all values in its domain $\[0, 1\)$ independently and with uniform probability. This particular variable is important for two reasons. First, it is easy to generate a variable with this distribution in software—most runtime libraries have a pseudo-random number generator that does just that#footnote[#f_en_211]. Second, we can take the canonical uniform random variable $xi$ and map it to a discrete random variable, choosing $X_i$ if
][
  一个特别重要的随机变量是#emph[标准均匀随机变量]，我们将其记为 $xi$。该变量在其域 $\[0, 1\)$ 内独立且均匀地取所有值。这个变量之所以重要有两个原因。首先，在软件中生成具有这种分布的变量很容易——大多数运行时库都有一个伪随机数生成器可以做到这一点#footnote[#f_zh_211]。其次，我们可以将标准均匀随机变量 $xi$ 映射到一个离散随机变量，当下式成立时选择 $X_i$：
]


$ sum_(j=1)^(i-1) p_j <= xi < sum_(j=1)^i p_j. $ <sampling-discrete-random>

#parec[
  For lighting applications, we might want to define the probability of sampling illumination from each light in the scene based on its power ( $Phi_i$ ) relative to the total power from all sources:
][
  在光照应用中，我们可能希望根据每个光源的功率 $Phi_i$ 相对于所有光源的总功率来定义从每个光源采样光照的概率：
]

$ p_i = frac(Phi_i, sum_j Phi_j) . $


#parec[
  Notice that these $p_i$ values also sum to 1. Given such per-light probabilities, $xi$ could be used to select a light source from which to sample illumination.
][
  注意这些 $p_i$ 值的总和也为 1。给定这样的每个光源的概率， $xi$ 可以用来选择从哪个光源采样光照。
]


#parec[
  The #emph[cumulative distribution function] (CDF) $P(x)$ of a random variable is the probability that a value from the variable's distribution is less than or equal to some value $x$ :
][
  随机变量的#emph[累积分布函数]（CDF） $P(x)$ 表示该随机变量取值小于或等于 $x$ 的概率：
]

$ P(x) = "Pr"{X lt.eq x} . $ <cdf-definition>

#parec[
  For the die example, $P(2) = 1/3$, since two of the six possibilities are less than or equal to 2.
][
  以骰子为例， $P(2) = 1/3$，因为六个可能结果中有两个小于或等于 2。
]


#parec[
  _Continuous random variables_ take on values over ranges of continuous domains (e.g., the real numbers, directions on the unit sphere, or the surfaces of shapes in the scene). Beyond $xi$, another example of a continuous random variable is the random variable that ranges over the real numbers between 0 and 2, where the probability of its taking on any particular value $x$ is proportional to the value $2 - x$ : it is twice as likely for this random variable to take on a value around 0 as it is to take one around 1, and so forth.
][
  _连续随机变量_在连续的定义域上取值，例如实数、单位球面上的方向或场景中形状的表面。除了 $xi$，另一个例子是在 0 到 2 之间的实数上取值的随机变量，其中取任何特定值 $x$ 的概率与 $2 - x$ 成正比：该随机变量在 0 附近取值的概率是 1 附近的两倍，以此类推。
]

#parec[
  The _probability density function_ (PDF) formalizes this idea: it describes the relative probability of a random variable taking on a particular value and is the continuous analog of the PMF. The PDF $p(x)$ is the derivative of the random variable's CDF,
][
  _概率密度函数_（PDF）形式化了这一概念：它描述了随机变量取特定值的相对概率，是 PMF 在连续情形下的对应概念。概率密度函数 $p(x)$ 是随机变量的 CDF 的导数，
]

$ p(x) = (d P(x)) / (d x). $


#parec[
  For uniform random variables, $p(x)$ is a constant; this is a direct consequence of uniformity. For $xi$ we have
][
  对于均匀随机变量， $p(x)$ 是常数，这是均匀性的直接结果。对于 $xi$ 我们有
]

$
  p(x) = cases(
  delim: "{",
  1 & x in lr([0, 1)),
  0 & #ez_caption[otherwise.][其他情况。]
)
$

#parec[
  PDFs are necessarily nonnegative and always integrate to 1 over their domains. Note that their value at a point $x$ is *not* necessarily less than 1, however.
][
  PDF 在其定义域上必定非负且积分值为 1。注意，它们在某点 $x$ 的值*不*一定小于 1。
]



#parec[
  Given an interval $[a, b]$ in the domain, integrating the PDF gives the probability that a random variable lies inside the interval:
][
  给定定义域内的一个区间 $[a, b]$，对 PDF 积分得到随机变量位于该区间内的概率：
]

$ "Pr"{x in [a, b]} = integral_a^b p(x) dif x = P(b) - P(a) . $

#parec[
  This follows directly from the first fundamental theorem of calculus and the definition of the PDF.
][
  这直接由微积分第一基本定理和 PDF 的定义得出。
]

=== #ez_caption[Expected Values][期望值]


#parec[
  The _expected value_ $E_p [ f(x) ]$ of a function $f$ is defined as the average value of the function over some distribution of values $p(x)$ over its domain $D$. It is defined as
][
  函数 $f$ 的_期望值_ $E_p [ f(x) ]$，是其定义域 $D$ 上按某个分布 $p(x)$ 取值时的函数平均值，定义为
]

$ E_p [f(x)] = integral_D f(x) p(x) d x. $ <expected-value>


#parec[
  As an example, consider finding the expected value of the cosine function between 0 and $pi$, where $p$ is uniform. Because the PDF $p(x)$ must integrate to 1 over the domain, $p(x) = (1)/(pi)$, so #footnote[When computing expected values with a uniform distribution, we will drop the subscript $p$ from $E_p$.]
][
  例如，考虑在 0 到 $pi$ 上计算余弦函数的期望值，其中 $p$ 是均匀分布。因为 PDF $p(x)$ 必须在定义域上积分为 1，所以 $p(x) = (1)/(pi)$，因此#footnote[在使用均匀分布计算期望值时，我们将从 $E_p$ 中省略下标 $p$。]
]

$ E [cos x] = integral_0^pi (cos x) / (pi) \, d x = (1) / (pi) (sin pi - sin 0) = 0, $


#parec[
  which is precisely the expected result. (Consider the graph of $cos x$ over $[0, pi]$ to see why this is so.)
][
  这正是预期的结果。（考虑 $cos x$ 在 $[0, pi]$ 上的图像来看看为什么会是这样。）
]

#parec[
  The expected value has a few useful properties that follow from its definition:
][
  期望值有一些有用的性质，这些性质来自其定义：
]

$
  E [a f(x)] & = a E [f(x)] \
  E [sum_(i = 1)^n f(X_i)] & = sum_(i = 1)^n E [f(X_i)] .
$ <expected-value-properties>
#parec[
  We will repeatedly use these properties in derivations in the following sections.
][
  我们将在以下章节的推导中反复使用这些性质。
]


=== #ez_caption[The Monte Carlo Estimator][蒙特卡洛估计量]

#parec[
  We can now define the Monte Carlo estimator, which approximates the value of an arbitrary integral. Suppose that we want to evaluate a 1D integral $integral _a^b f(x) d x $. Given a supply of independent uniform random variables $X_i  in  [a, b ]$, the Monte Carlo estimator says that the expected value of the estimator
][
  现在可以定义蒙特卡洛估计量，用它近似计算任意积分的值。假设我们想要计算一维积分 $integral_a^b f(x) d x $。给定一组独立均匀随机变量 $X_i in  [a, b ]$，蒙特卡洛估计量如下：
]


$ F_n = (b - a) / (n) sum_(i=1)^n f(X_i) $ <mc-uniform-estimator>

#parec[
  $E[F_n]$, is equal to the integral. This fact can be demonstrated with just a few steps. First, note that the PDF $p(x)$ corresponding to the random variable $X_i$ must be equal to $(1)/(b - a)$, since $p$ must not only be a constant but also integrate to 1 over the domain $[a, b]$. Algebraic manipulation using the properties from @eqt:expected-value and @eqt:expected-value-properties then shows that
][
  其期望值 $E[F_n]$ 等于该积分。这一事实可以通过几个步骤来证明。首先，注意到与随机变量 $X_i$ 对应的概率密度函数 $p(x)$ 必须等于 $(1)/(b - a)$，因为 $p$ 不仅必须是常数，而且必须在区间 $[a, b]$ 上积分为 1。利用@eqt:expected-value 和 @eqt:expected-value-properties 的性质进行代数操作，然后可以证明
]

$
  E [F_n] & = E [frac(b - a, n) sum_(i = 1)^n f(X_i)] \
  & = frac(b - a, n) sum_(i = 1)^n E [f(X_i)] \
  & = frac(b - a, n) sum_(i = 1)^n integral_a^b f(x) p(x) dif x \
  & = frac(1, n) sum_(i = 1)^n integral_a^b f(x) dif x \
  & = integral_a^b f(x) dif x .
$

#parec[
  Extending this estimator to multiple dimensions or complex integration domains is straightforward: $n$ independent samples $X_i$ are taken from a uniform multidimensional PDF, and the estimator is applied in the same way. For example, consider the 3D integral
][
  这一估计量可以直接扩展到多维或复杂的积分域：从均匀的多维概率密度函数中抽取 $n$ 个独立样本 $X_i$，并以相同的方式应用估计量。例如，考虑三维积分
]


$ integral_(z_0)^(z_1) integral_(y_0)^(y_1) integral_(x_0)^(x_1) f(x, y, z) dif x dif y dif z . $


#parec[
  If samples $X_i = (x_i, y_i, z_i)$ are chosen uniformly from the cube from $[x_0, x_1] times [y_0, y_1] times [z_0, z_1] $, then the PDF $p(X) $ is the constant value
][
  如果样本 $X_i = (x_i, y_i, z_i) $ 从 $[x_0, x_1] times [y_0, y_1] times [z_0, z_1] $ 的立方体中均匀选择，那么概率密度函数 $p(X) $ 是常数值
]

$ frac(1,(x_1 - x_0)) frac(1,(y_1 - y_0)) frac(1,(z_1 - z_0)), $

#parec[
  and the estimator is
][
  估计量为
]

$ ((x_1 - x_0)(y_1 - y_0)(z_1 - z_0)) / (n) sum_(i = 1)^n f(X_i) . $

#parec[
  The restriction to uniform random variables can be relaxed with a small generalization. This is an important step, since carefully choosing the PDF from which samples are drawn leads to a key technique for reducing error in Monte Carlo that will be introduced in @importance-sampling. If the random variables $X_i$ are drawn from a PDF $p(x)$, then the estimator
][
  对均匀随机变量的限制可以通过一个小小的推广来放宽。这是重要的一步：仔细选择用于采样的概率密度函数，会引出一种降低蒙特卡洛误差的关键技术；@importance-sampling 将介绍它。如果随机变量 $X_i$ 是从概率密度函数 $p(x)$ 中抽取的，那么估计量
]

$
  F_n = 1 / n sum_(i=1)^n f(X_i) / p(X_i)
$ <MC-estimator>

#parec[
  can be used to estimate the integral instead. The only limitation on $p(x)$ is that it must be nonzero for all $x$ where $|f(x)| > 0$.
][
  可以用来估计积分。对 $p(x)$ 的唯一限制是它在所有 $|f(x)| > 0$ 的 $x$ 处必须不为零。
]

#parec[
  It is similarly not too hard to see that the expected value of this estimator is the desired integral of $f$:
][
  同样不难看出，这个估计量的期望值正是所求的 $f$ 的积分：
]
$
  E [F_n] & = E [frac(1, n) sum_(i = 1)^n frac(f(X_i), p(X_i))] \
  & = frac(1, n) sum_(i = 1)^n integral_a^b frac(f(x), p(x)) p(x) dif x \
  & = frac(1, n) sum_(i = 1)^n integral_a^b f(x) dif x \
  & = integral_a^b f(x) dif x .
$
#parec[
  We can now understand the factor of $(1)/(4pi) $ in the implementation of the `RandomWalkIntegrator`: directions are uniformly sampled over the unit sphere, which has area $4pi$. Because the PDF is normalized over the sampling domain, it must have the constant value $(1)/(4pi) $. When the estimator of @eqt:MC-estimator is applied, that value appears in the divisor.
][
  我们现在可以理解 `RandomWalkIntegrator` 实现中 $(1)/(4pi) $ 因子的含义：方向在单位球面上均匀采样，该球面的面积为 $4pi $。由于概率密度函数在采样域上归一化，它必须具有常数值 $(1)/(4pi) $。当应用@eqt:MC-estimator 的估计量时，需要用该值作除数。
]

#parec[
  With Monte Carlo, the number of samples $n$ can be chosen arbitrarily, regardless of the dimensionality of the integrand. This is another important advantage of Monte Carlo over traditional deterministic quadrature techniques, which typically require a number of samples that is exponential in the dimension.
][
  使用蒙特卡洛方法，样本数量 $n$ 可以任意选择，与被积函数的维度无关。这是蒙特卡洛方法相对于传统确定性求积技术的另一个重要优势，后者所需的样本数通常随维数呈指数增长。
]

=== #ez_caption[Error in Monte Carlo Estimators][蒙特卡洛估计量的误差]
<error-in-monte-carlo-estimators>

#parec[
  Showing that the Monte Carlo estimator converges to the right answer is not enough to justify its use; its rate of convergence is important too. *Variance*, the expected squared deviation of a function from its expected value, is a useful way to characterize Monte Carlo estimators' convergence. The variance of an estimator $F$ is defined as
][
  仅证明蒙特卡洛估计量收敛到正确答案，还不足以说明它值得使用；收敛速率同样重要。*方差*是函数偏离其期望值的平方的期望，可用于刻画蒙特卡洛估计量的收敛性。估计量 $F$ 的方差定义为
]

$ V [F] = E [(F - E [F])^2], $ <variance-initial>
#parec[
  from which it follows that
][
  由此可得
]

$ V[a F] = a^2 V[F]. $

#parec[
  This property and @eqt:expected-value-properties yield an alternative expression for the variance:
][
  由这一性质与 @eqt:expected-value-properties，可以得到方差的另一种表达式：
]

$ V [F] = E [F^2] - E [F]^2 . $ <variance>


#parec[
  Thus, the variance is the expected value of the square minus the square of the expected value.
][
  因此，方差是平方的期望值减去期望值的平方。
]

#parec[
  If the estimator is a sum of independent random variables (like the Monte Carlo estimator $F_n$ ), then the variance of the sum is the sum of the individual random variables' variances:
][
  如果估计量是独立随机变量之和（如蒙特卡洛估计量 $F_n$ ），那么总和的方差就是各个随机变量方差之和：
]

$ V [sum_(i = 1)^n X_i] = sum_(i = 1)^n V [X_i] . $ <variance-properties>


#parec[
  From @eqt:variance-properties it is easy to show that variance decreases linearly with the number of samples $n$. Because variance is squared error, the error in a Monte Carlo estimate therefore only goes down at a rate of $O(n^(-1/2))$ in the number of samples. Although standard quadrature techniques converge at a faster rate in one dimension, their performance becomes exponentially worse as the dimensionality of the integrand increases, while Monte Carlo's convergence rate is independent of the dimension, making Monte Carlo the only practical numerical integration algorithm for high-dimensional integrals.
][
  从@eqt:variance-properties 可以很容易地看出，方差与样本数量 $n$ 成反比。由于方差以误差的平方计量，因此蒙特卡洛估计的误差仅随样本数的增加以 $O(n^(-1/2))$ 的速率减小。尽管标准数值积分技术在一维情况下收敛更快，但随着被积函数维度的增加，其性能会呈指数级下降，而蒙特卡洛的收敛速率与维度无关，这使得蒙特卡洛成为高维积分唯一实用的数值积分算法。
]

#parec[
  The $O(n^(-1/2))$ characteristic of Monte Carlo's rate of error reduction is apparent when watching a progressive rendering of a scene where additional samples are incrementally taken in all pixels. The image improves rapidly for the first few samples when doubling the number of samples is relatively little additional work. Later on, once tens or hundreds of samples have been taken, each additional sample doubling takes much longer and remaining error in the image takes a long time to disappear.
][
  蒙特卡洛误差减少的 $O(n^(-1/2))$ 特性在观察场景的渐进渲染时表现得尤为明显，其中所有像素逐渐增加样本。最初只有少量样本时，将样本数加倍所需的额外工作相对较少，因此图像很快就能得到改善。之后，一旦采集了数十或数百个样本，每次样本翻倍所需时间更长，图像中的剩余误差需要很长时间才能消失。
]


#parec[
  The linear decrease in variance with increasing numbers of samples makes it easy to compare different Monte Carlo estimators. Consider two estimators, where the second has half the variance of the first but takes three times as long to compute an estimate; which of the two is better? In that case, the first is preferable: it could take three times as many samples in the time consumed by the second, in which case it would achieve a $3times$ variance reduction. This concept can be encapsulated in the *efficiency* of an estimator $F$, which is defined as
][
  方差与样本数成反比，这让不同蒙特卡洛估计量之间的比较变得简单。考虑两个估计量，第二个的方差是第一个的一半，但计算估计值所需时间是第一个的三倍；哪一个更好？在这种情况下，第一个更可取：它可以在第二个消耗的时间内采集三倍的样本，从而将方差降至原来的三分之一。这一概念可以用估计量 $F$ 的*效率*来概括，定义为
]

$ epsilon.alt [F] = 1 / (V[F] T[F]), $


#parec[
  where $V[F]$ is its variance and $T[F]$ is the running time to compute its value.
][
  其中 $V[F]$ 是其方差， $T[F]$ 是计算其值的运行时间。
]



#parec[
  Not all estimators of integrals have expected values that are equal to the value of the integral. Such estimators are said to be _biased_, where the difference
][
  并非所有积分估计量的期望值都等于积分值。期望值不等于积分值的估计量称为_有偏估计量_，两者之差
]

$ beta = E [F] - integral f(x) d x $



#parec[
  is the amount of bias. Biased estimators may still be desirable if they are able to get close to the correct result more quickly than unbiased estimators. Kalos and Whitlock (@kalos1986monte, pp. 36–37) gave the following example: consider the problem of computing an estimate of the mean value of a uniform distribution $X_i ~ p$ over the interval from 0 to 1. One could use the estimator
][
  就是其偏差。如果有偏估计量能比无偏估计量更快接近正确结果，它们仍是可取的。Kalos 和 Whitlock（@kalos1986monte，第 36–37 页）给出了以下例子：考虑估计 0 到 1 区间上均匀分布 $X_i ~ p$ 的均值这一问题。可以使用估计量
]

$ (1) / (n) sum_(i=1)^n X_i, $

#parec[
  or one could use the biased estimator
][
  或者使用有偏估计量
]

$ (1) / (2) max(X_1, X_2, dots, X_n). $


#parec[
  The first estimator is unbiased but has variance with order $O(n^(- 1))$. The second estimator's expected value is
][
  第一个估计量是无偏的，但其方差的阶为 $O(n^(-1))$。第二个估计量的期望值是
]

$ 0.5 n / (n + 1) != 0.5 $
#let f_en_214 = "As a technical note, it is possible for an estimator with infinite variance to be unbiased but not consistent.  Such estimators do not generally come up in rendering, however."

#let f_zh_214 = "从技术上说，具有无限方差的估计量可能是无偏的，但不相合。然而，在渲染中通常不会出现这样的估计量。"
#parec[
  so it is biased, although its variance is $O(n^(-2))$, which is much better. This estimator has the useful property that its error goes to 0 in the limit as the number of samples $n$ goes to infinity; such estimators are _consistent_.#footnote[#f_en_214] Most of the Monte Carlo estimators used in `pbrt` are unbiased, with the notable exception of the `SPPMIntegrator`, which implements a photon mapping algorithm.
][
  因此它是有偏的，尽管其方差的阶为 $O(n^(-2))$，这是一个显著的改进。这个估计量有一个有用的性质，即当样本数量 $n$ 趋向于无穷大时，其误差趋近于 0；这样的估计量是#emph[相合的]。#footnote[#f_zh_214]`pbrt` 中使用的大多数蒙特卡洛估计量都是无偏的，但 `SPPMIntegrator` 是个例外，它采用了光子映射算法。
]



#parec[
  Closely related to the variance is the #emph[mean squared error] (MSE), which is defined as the expectation of the squared difference of an estimator and the true value,
][
  与方差密切相关的是_均方误差_（MSE），其定义为估计量与真实值的平方差的期望，
]

$ "MSE"[F] = E [(F - integral f(x) dif x)^2] . $

#parec[
  For an unbiased estimator, MSE is equal to the variance; otherwise it is the sum of variance and the squared bias of the estimator.
][
  对于无偏估计量，MSE 等于方差；否则，MSE 是方差与估计量偏差的平方之和。
]

#parec[
  It is possible to work out the variance and MSE of some simple estimators in closed form, but for most of the ones of interest in rendering, this is not possible. Yet it is still useful to be able to quantify these values. For this purpose, the #emph[sample variance] can be computed using a set of independent random variables $X_i$. @eqt:variance-initial points at one way to compute the sample variance for a set of $n$ random variables $X_i$. If the #emph[sample mean] is computed as their average, $overline(X) = (1)/(n) sum X_i$, then the sample variance is
][
  可以用闭式表达式计算一些简单估计量的方差和 MSE，但对于渲染中关注的大多数估计量，这是不可能的。然而，量化这些值仍然是有用的。为此，可以使用一组独立随机变量 $X_i$ 计算_样本方差_。@eqt:variance-initial 指出了一种计算一组 $n$ 个随机变量 $X_i$ 的样本方差的方法。如果*样本均值*计算为其平均值， $overline(X) = (1)/(n) sum X_i$，那么样本方差为
]


$
  frac(1, n - 1) sum_(i = 1)^n (X_i - overline(X))^2 .
$ <sample-variance-basic>
#parec[
  The division by $n-1$ rather than $n$ is *Bessel's correction*, and ensures that the sample variance is an unbiased estimate of the variance. (See also @b.2.11-鲁棒方差估计, where a numerically stable approach for computing the sample variance is introduced.)
][
  除以 $n-1$ 而不是 $n$ 称为*贝塞尔校正*，它保证样本方差是总体方差的无偏估计量。（另见 @b.2.11-鲁棒方差估计，其中介绍了计算样本方差的数值稳定方法。）
]


#parec[
  The sample variance is itself an estimate of the variance, so it has variance itself. Consider, for example, a random variable that has a value of 1 99.99% of the time, and a value of one million 0.01% of the time. If we took ten random samples of it that all had the value 1, the sample variance would suggest that the random variable had zero variance even though its variance is actually much higher.
][
  样本方差本身是方差的估计，因此它也有方差。例如，考虑一个随机变量，以 99.99% 的概率取值 1，以 0.01% 的概率取值 100 万。若我们抽取十个随机样本，结果恰好全为 1，样本方差会表明该随机变量的方差为零，而实际上其方差远高于此。
]


#parec[
  If an accurate estimate of the integral $tilde(F) approx integral f(x) "d" x$ can be computed (for example, using a large number of samples), then the mean squared error can be estimated by
][
  如果可以计算积分 $tilde(F) approx integral f(x) d x$ 的准确估计（例如，使用大量样本），那么可以通过以下公式估计均方误差：
]

$ "MSE"[F] approx frac(1, n) sum_(i = 1)^n (f(X_i) - tilde(F))^2 . $

#parec[
  The `imgtool` utility program that is provided in pbrt's distribution can compute an image's MSE with respect to a reference image via its `diff` option.
][
  `pbrt` 发行版提供的 `imgtool` 工具可通过 `diff` 选项计算图像相对于参考图像的 MSE。
]
