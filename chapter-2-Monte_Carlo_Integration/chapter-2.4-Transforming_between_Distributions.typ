#import "../template.typ": parec

== 2.4 Transforming between Distributions
#parec[
  In describing the inversion method, we introduced a technique that generates samples according to some distribution by transforming canonical uniform random variables in a particular manner. Here, we will investigate the more general question of which distribution results when we transform samples from an arbitrary distribution to some other distribution with a function $f$. Understanding the effect of such transformations is useful for a few reasons, though here we will focus on how they allow us to derive multidimensional sampling algorithms.
][
  在介绍逆变换方法时，我们引入了一种技术，该技术通过特定方式变换标准均匀随机变量，以生成符合某种分布的样本。在这里，我们将探讨一个更一般的问题：当我们用函数 $f$ 将任意分布的样本变换为另一种分布时，结果会是什么分布。理解这种变换的影响有多个原因，这里将重点讨论它们如何帮助我们推导多维采样算法。
]
#parec[
  Suppose we are given a random variable $X$ drawn from some PDF $p (x)$ with CDF $P (x)$. Given a function $f (x)$ with $y = f (x)$, if we compute $Y = f (X)$, we would like to find the distribution of the new random variable $Y$. In this case, the function $f (x)$ must be a one-to-one transformation; if multiple values of $x$ mapped to the same $y$ value, then it would be impossible to unambiguously describe the probability density of a particular $y$ value. A direct consequence of $f$ being one-to-one is that its derivative must either be strictly greater than 0 or strictly less than 0, which implies that for a given $x$,
][
  假设我们有一个随机变量 $X$，它从某个概率密度函数（PDF） $p (x)$ 和累积分布函数（CDF） $P (x)$ 中抽取。给定一个函数 $f (x)$ 且 $y = f (x)$，如果我们计算 $Y = f (X)$，我们希望找到新随机变量 $Y$ 的分布。在这种情况下，函数 $f (x)$ 必须是一对一变换；若多个 $x$ 值映射到相同的 $y$ 值，则无法明确描述特定 $y$ 值的概率密度。 $f$ 为一对一的直接结果是其导数必须严格大于 0 或严格小于 0，这意味着对于给定的 $x$，
]
$ "Pr" {Y lt.eq f (x)} = "Pr" {X lt.eq x} . $
#parec[
  From the definition of the CDF, @eqt:cdf-definition, we can see that
][
  根据 CDF 的定义，即@eqt:cdf-definition，我们可以得出
]

$ P_f (y) = P_f (f (x)) = P (x) . $

#parec[
  This relationship between CDFs leads directly to the relationship between their PDFs. If we assume that $f$'s derivative is greater than 0, differentiating gives
][
  这种 CDF 之间的关系直接导致了它们对应的 PDF 之间的关系。如果我们假设 $f$ 的导数大于 0，微分得到
]

$ p_f (y) frac(d f, d x) = p (x) , $

#parec[
  and so
][
  因此
]

$ p_f (y) = (frac(d f, d x))^(-1) p (x) . $




#parec[
  In general, $f$'s derivative is either strictly positive or strictly negative, and the relationship between the densities is
][
  一般来说， $f$ 的导数要么严格为正，要么严格为负，密度之间的关系为
]
$ p_f (y) = lr(|frac(d f, d x)|)^(- 1) p (x) . $

#parec[
  How can we use this formula? Suppose that $p (x) = 2 x$ over the domain $[0 , 1]$, and let $f (x) = sin x$. What is the PDF of the random variable $Y = f (X)$? Because we know that $d f\/ d x  = cos x$,
][
  我们如何使用这个公式？假设 $p (x) = 2 x$ 在区间 $[0 , 1]$ 上，且 $f (x) = sin x$。随机变量 $Y = f (X)$ 的 PDF 是什么？因为我们知道 $d f\/ d x = cos x$，
]
$ p_f (y) = frac(p (x), lr(|cos x|)) = frac(2 x, cos x) = frac(2 arcsin y, sqrt(1 - y^2)) . $

#parec[
  This procedure may seem backward—usually we have some PDF that we want to sample from, not a given transformation. For example, we might have $X$ drawn from some $p (x)$ and would like to compute $Y$ from some distribution $p_f (y)$. What transformation should we use? All we need is for the CDFs to be equal, or $P_f (y) = P (x)$, which immediately gives the transformation
][
  这个过程可能看起来是反向的——通常我们有一些 PDF 是我们想要从中采样的，而不是给定的变换。例如，我们可能有从某个 $p (x)$ 中抽取的 $X$，并且希望从某个分布 $p_f (y)$ 计算 $Y$。我们应该使用什么变换？我们只需要 CDF 相等，即 $P_f (y) = P (x)$，这立即给出了变换
]

$ f (x) = P_f^(- 1) (P (x)) . $

#parec[
  This is a generalization of the inversion method, since if $X$ were uniformly distributed over $\[ 0 , 1 \)$ then $P (x) = x$, and we have the same procedure as was introduced previously.
][
  这是逆变换方法的推广，因为若 $X$ 在 $\[ 0 , 1 \)$ 上均匀分布，则 $P (x) = x$，我们使用的方法与之前介绍的相同。
]


=== Transformation in Multiple Dimensions
<transformation-in-multiple-dimensions>

#parec[
  In the general $d$-dimensional case, a similar derivation gives the analogous relationship between different densities. We will not show the derivation here; it follows the same form as the 1D case. Suppose we have a $d$-dimensional random variable $X$ with density function $p (x)$. Now let $Y = T (X)$, where $T$ is a bijection. In this case, the densities are related by
][
  在一般的 $d$ 维情况下，类似的推导给出了不同密度之间的类似关系。我们在这里不展示推导过程；它遵循与一维情况相同的格式。假设我们有一个 $d$ 维随机变量 $X$，其密度函数为 $p (x)$。现在设 $Y = T (X)$，其中 $T$ 是一个双射。在这种情况下，密度之间的关系为
]

$ p_T (y) = p_T (T (x)) = frac(p (x), lr(|J_T (x)|)) , $ <multidimensional-xform-pdf>


#parec[
  where $J_T (x)$ is the Jacobian of the transformation $T$.
][
  其中 $J_T (x)$ 是变换 $T$ 的雅可比矩阵。
]

$
  mat(
    delim: "(",
  diff T_1 slash diff x_1  , dots.c,  diff T_1 slash diff x_d ;
  dots.v, dots.down, dots.v;
   diff T_d slash diff x_1 , dots.c,  diff T_d slash diff x_d
   ),
$

#parec[
  where subscripts index dimensions of $T(x)$ and $x$.
][
  其中下标用于索引 $T(x)$ 和 $x$ 的维度。
]


#parec[
  For a 2D example of the use of @eqt:multidimensional-xform-pdf, the polar transformation relates Cartesian $(x, y)$ coordinates to a polar radius and angle,
][
  作为二维应用示例，使用@eqt:multidimensional-xform-pdf，极坐标变换将笛卡尔坐标 $(x, y)$ 转换为极径和角度，
]

$
  x &= r cos theta \
  y &= r sin theta.
$

#parec[
  Suppose we draw samples from some density $p(r, theta)$. What is the corresponding density $p(x, y)$? The Jacobian of this transformation is
][
  假设我们从某个密度 $p(r, theta)$ 中抽取样本。对应的密度 $p(x, y)$ 是什么？这个变换的雅可比矩阵是
]


#parec[
  and the determinant is $r ( cos^2  theta +  sin^2  theta) = r$. So, $p(x, y) =  frac(p(r,  theta),r)$. Of course, this is backward from what we usually want—typically we start with a sampling strategy in Cartesian coordinates and want to transform it to one in polar coordinates. In that case, we would have
][
  行列式是 $r ( cos^2  theta +  sin^2  theta) = r$。因此，$p(x, y) =  frac(p(r,  theta),r)$。当然，这与我们通常的需求相反——通常我们从笛卡尔坐标中的采样策略开始，并希望将其转换为极坐标中的采样策略。在这种情况下，我们有
]


$
  p(r, theta) = r p(x, y) .
$<polar-cartesian-pdf-relation>
#parec[
  In 3D, given the spherical coordinate representation of directions, @eqt:spherical-coordinates, the Jacobian of this transformation has determinant $|J_T| = r^2  sin  theta$, so the corresponding density function is
][
  在三维中，给定方向的球坐标表示，@eqt:spherical-coordinates ，这个变换的雅可比矩阵的行列式是 $|J_T| = r^2  sin  theta$，因此对应的密度函数是
]

$
  p(r, theta, phi) = r^2 sin theta p(x, y, z).
$

#parec[
  This transformation is important since it helps us represent directions as points $(x,y,z)$ on the unit sphere.
][
  这一变换之所以重要，是因为它帮助我们将方向表示为单位球面上的点 $(x, y, z)$。
]




=== Sampling with Multidimensional Transformations
<sampling-with-multidimensional-transformations>

#parec[
  Suppose we have a 2D joint density function $p (x , y)$ that we wish to draw samples $(X , Y)$ from. If the densities are independent, they can be expressed as the product of 1D densities
][
  假设我们有一个二维联合密度函数 $p (x , y)$，我们希望从中抽取样本 $(X , Y)$。如果密度是独立的，它们可以表示为 1D 密度的乘积
]


$ p (x , y) = p_x (x) p_y (y) , $
#parec[
  and random variables $(X , Y)$ can be found by independently sampling $X$ from $p_x$ and $Y$ from $p_y$. Many useful densities are not separable, however, so we will introduce the theory of how to sample from multidimensional distributions in the general case.
][
  随机变量 $(X , Y)$ 可以通过独立地从 $p_x$ 和 $p_y$ 中采样 $X$ 和 $Y$ 来找到。然而，许多有用的密度并非可分离的，因此我们将介绍如何在一般情况下从多维分布中采样的理论。
]

#parec[
  Given a 2D density function, the #emph[marginal density function] $p (x)$ is obtained by "integrating out" one of the dimensions:
][
  给定一个二维密度函数，#emph[边缘密度函数] $p (x)$ 是通过“积分掉”一个维度得到的：
]

$ p (x) = integral p (x , y) thin d y . $ <2d-marginal-density>


#parec[
  This can be thought of as the density function for $X$ alone. More precisely, it is the average density for a particular $x$ over #emph[all] possible $y$ values.
][
  这可以视为 $X$ 自身的密度函数。更确切地说，它是特定 $x$ 在所有可能 $y$ 值上的平均密度。
]

#parec[
  If we can draw a sample $X tilde.op p (x)$, then—using @eqt:conditional-2d-density —we can see that in order to sample $Y$, we need to sample from the conditional probability density, $Y tilde.op p (y divides x)$, which is given by:
][
  如果我们能从 $p (x)$ 中抽取样本 $X$，那么——利用方程（@eqt:conditional-2d-density）——我们可以看出，为了采样 $Y$，我们需要从条件概率密度 $Y tilde.op p (y divides x)$ 中采样，该密度由以下公式给出：
]

$
  p (y \| x) = frac(p (x , y), integral p (x , y) thin d y) .
$

#parec[
  Sampling from higher-dimensional distributions can be performed in a similar fashion, integrating out all but one of the dimensions, sampling that one, and then applying the same technique to the remaining conditional distribution, which has one fewer dimension. $p (y \| x) = frac(p (x , y), integral p (x , y) thin d y) .$
][
  在高维分布中采样时，可以通过逐步积分去除所有维度，仅保留一个维度进行采样，然后对剩余的条件分布重复此过程，每次减少一个维度。
]
==== Sampling the Bilinear Function
<sampling-the-bilinear-function>

#parec[
  The bilinear function
][
  双线性函数
]
$
  f (x , y) = (1 - x) (1 - y) w_0 + x (1 - y) w_1 + y (1 - x) w_2 + x y w_3
$ <bilinear-interp>
#parec[
  interpolates between four values $w_i$ at the four corners of $[0 , 1]^2$. ($w_0$ is at $(0 , 0)$, $w_1$ is at $(1 , 0)$, $w_2$ at $(0 , 1)$, and $w_3$ at $(1 , 1)$.) After integration and normalization, we can find that its PDF is
][
  在 $[0 , 1]^2$ 的四个顶点 $w_i$ 之间进行插值。（$w_0$ 在 $(0 , 0)$， $w_1$ 在 $(1 , 0)$， $w_2$ 在 $(0 , 1)$， $w_3$ 在 $(1 , 1)$。）经过积分和归一化后，我们可以发现其概率密度函数（PDF）为
]
$ p (x , y) = frac(4 f (x , y), w_0 + w_1 + w_2 + w_3) . $



```cpp
<<Sampling Inline Functions>>+=
Float BilinearPDF(Point2f p, pstd::span<const Float> w) {
    if (p.x < 0 || p.x > 1 || p.y < 0 || p.y > 1)
        return 0;
    if (w[0] + w[1] + w[2] + w[3] == 0)
        return 1;
    return 4 * ((1 - p[0]) * (1 - p[1]) * w[0] + p[0] * (1 - p[1]) * w[1] +
                (1 - p[0]) * p[1] * w[2] + p[0] * p[1] * w[3]) /
           (w[0] + w[1] + w[2] + w[3]);
}
```

#parec[
  The two dimensions of this function are not independent, so the sampling method samples a marginal distribution before sampling the resulting conditional distribution.
][
  该函数的两个维度不是独立的，因此采样方法先采样边缘分布，然后再采样结果条件分布。
]


```cpp
<<Sampling Inline Functions>>+=
Point2f SampleBilinear(Point2f u, pstd::span<const Float> w) {
    Point2f p;
    // <<Sample y for bilinear marginal distribution>>
    p.y = SampleLinear(u[1], w[0] + w[1], w[2] + w[3]);
    // <<Sample x for bilinear conditional distribution>>
    p.x = SampleLinear(u[0], Lerp(p.y, w[0], w[2]), Lerp(p.y, w[1], w[3]));
    return p;
}
```
#parec[
  We can choose either $x$ or $y$ to be the marginal distribution. If we choose $y$ and integrate out $x$, we find that
][
  我们可以选择 $x$ 或 $y$ 作为边缘分布。若选择 $y$ 并积分掉 $x$，则发现
]


$
  p (y) & = integral_0^1 p (x , y) thin d x\
  & = 2 frac((1 - y) (w_0 + w_1) + y (w_2 + w_3), w_0 + w_1 + w_2 + w_3)\
  & prop (1 - y) (w_0 + w_1) + y (w_2 + w_3) .
$

#parec[
  $p (y)$ performs linear interpolation between two constant values, and so we can use `SampleLinear()` to sample from the simplified proportional function since it normalizes the associated PDF.
][
  $p (y)$ 在两个常数值之间进行线性插值，因此我们可以使用 `SampleLinear()` 从简化的比例函数中采样，因为它归一化了相关的 PDF。
]


```
<<Sample $y$ for bilinear marginal distribution>>=
p.y = SampleLinear(u[1], w[0] + w[1], w[2] + w[3]);
```
#parec[
  Applying @eqt:conditional-2d-density and again canceling out common factors, we have
][
  应用@eqt:conditional-2d-density 并再次消去公共因子，我们有
]

$
  p(x|y) = frac(p(x comma y), p(y)) prop(1 - x) [(1 - y) w_0 + y w_2] + x [(1 - y) w_1 + y w_3],
$

#parec[
  which can also be sampled in $x$ using `SampleLinear()`.
][
  这也可以使用 `SampleLinear()` 在 $x$ 中采样。
]



```cpp
<<Sample $x$ for bilinear conditional distribution>>=
p.x = SampleLinear(u[0], Lerp(p.y, w[0], w[2]), Lerp(p.y, w[1], w[3]));
```
#parec[
  Because the bilinear sampling routine is based on the composition of two 1D linear sampling operations, it can be inverted by applying the inverses of those two operations in reverse order.
][
  由于双线性采样程序基于两个一维线性采样操作的组合，因此可以通过反向应用这两个操作的逆操作来实现反转。
]


```cpp
<<Sampling Inline Functions>>+=
Point2f InvertBilinearSample(Point2f p, pstd::span<const Float> w) {
    return {InvertLinearSample(p.x, Lerp(p.y, w[0], w[2]),
                               Lerp(p.y, w[1], w[3])),
            InvertLinearSample(p.y, w[0] + w[1], w[2] + w[3])};
}
```

#parec[
  See Section A.5 for further examples of multidimensional sampling algorithms, including techniques for sampling directions on the unit sphere and hemisphere, sampling unit disks, and other useful distributions for rendering.
][
  请参阅A.5节，了解多维采样算法的更多示例，包括在单位球体和半球上采样方向、单位圆盘采样以及其他对渲染有用的分布技术。
]
