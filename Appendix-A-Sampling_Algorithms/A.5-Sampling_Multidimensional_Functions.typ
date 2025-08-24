#import "../template.typ": parec, translator
== Sampling Multidimensional Functions

#parec[
  Multidimensional sampling is also common in pbrt, most
  frequently when sampling points on the surfaces of shapes and sampling
  directions after scattering at points. This section therefore works
  through the derivations and implementations of algorithms for sampling
  in a number of useful multidimensional domains. Some of them involve
  separable PDFs where each dimension can be sampled independently, while
  others use the approach of sampling from marginal and conditional
  density functions that was introduced in Section 2.4.2.
][
  多维采样在
  pbrt
  中同样非常常见，最常见的应用是采样形状表面上的点以及散射后的方向。本节将推导并实现若干有用的多维域采样算法。其中有些情况涉及可分离的
  PDF，每个维度可以独立采样；另一些情况则使用第 2.4.2
  节介绍的边缘与条件密度函数的采样方法。
]

#parec[
  Uniformly sampling a unit disk can be tricky because it has an
  incorrect intuitive solution. The wrong approach is the seemingly
  obvious one of sampling its polar coordinates uniformly: $r = xi_1$,
  $theta = 2 pi , xi_2$. Although the resulting point is both random
  and inside the disk, it is not uniformly distributed; it actually clumps
  samples near the center of the disk. Figure A.6(a) shows a plot of
  samples on the unit disk when this mapping was used for a set of uniform
  random samples $(xi_1 , xi_2)$. Figure A.6(b) shows uniformly
  distributed samples resulting from the following correct
  approach.
][
  在单位圆盘上进行均匀采样看似简单，但直观的解法其实是错误的。错误的方法是将极坐标直接均匀采样：$r = xi_1$,
  $theta = 2 pi , xi_2$。虽然这样得到的点确实是随机的且落在圆盘内，但分布并不均匀，反而会在圆心附近产生过多样本。图
  A.6(a) 显示了这种映射在一组均匀随机样本 $(xi_1 , xi_2)$
  下的分布情况，可以看到样本集中在中心区域。图 A.6(b)
  展示了通过正确方法得到的均匀分布样本。
]

#parec[
  Since we would like to sample uniformly with respect to area,
  the PDF for a point $(x , y)$ must be constant. By the normalization
  constraint, $p (x , y) = 1 \/ pi$. If we transform into polar
  coordinates, we have $p (r , theta) = r \/ pi$ given the relationship
  between probability densities in Cartesian coordinates and polar
  coordinates that was derived in Section 2.4.1, Equation
  (2.22).
][
  因为我们希望相对于面积进行均匀采样，因此点 $(x , y)$ 的 PDF
  必须是常数。根据归一化约束，有
  $p (x , y) = 1 \/ pi$。将其转换到极坐标后，根据第 2.4.1 节公式 (2.22)
  给出的笛卡尔坐标与极坐标之间的概率密度关系，可以得到
  $p (r , theta) = r \/ pi$。
]

#parec[
  We can now compute the marginal and conditional densities:

  - $p (r) = integral_0^(2 pi) p (r , theta) , d theta = 2 r$
  - $p (theta \| r) = frac(p (r , theta), p (r)) = frac(1, 2 pi)$

  The fact that $p (theta \| r)$ is a constant should make sense because
  of the symmetry of the disk. Integrating and inverting to find $P (r)$,
  $P^(- 1) (r)$, $P (theta)$, and $P^(- 1) (theta)$, we can find that the
  correct solution to generate uniformly distributed samples on a disk is

  $ r = sqrt(xi_1) , quad theta = 2 pi thin xi_2 . $

  Taking the square root of $xi_1$ effectively pushes the samples back
  toward the edge of the disk, counteracting the clumping referred to
  earlier.
][
  接下来我们可以计算边缘密度与条件密度：

  - $p (r) = integral_0^(2 pi) p (r , theta) , d theta = 2 r$
  - $p (theta \| r) = frac(p (r , theta), p (r)) = frac(1, 2 pi)$

  $p (theta \| r)$
  是常数是符合直觉的，因为圆盘具有旋转对称性。对这些密度进行积分并求反函数，得到累积分布函数
  $P (r)$、$P^(- 1) (r)$、$P (theta)$ 和
  $P^(- 1) (theta)$，最终可得在圆盘上生成均匀分布样本的正确解法为：

  $ r = sqrt(xi_1) , quad theta = 2 pi thin xi_2 . $

  取 $xi_1$
  的平方根的效果是将样本“推向”圆盘边缘，从而抵消了之前所说的在中心聚集的现象。
]

#parec[
  Although this mapping solves the problem at hand, it distorts
  areas on the disk; areas on the unit square are elongated or compressed
  when mapped to the disk (Figure A.7). This distortion can reduce the
  effectiveness of stratified sampling patterns by making the strata less
  compact. A better approach that avoids this problem is a "concentric"
  mapping from the unit square to the unit disk. The concentric mapping
  takes points in the square $[-1,1
  ]^2$ to the unit disk by
  uniformly mapping concentric squares to concentric circles (Figure
  A.8).
][
  虽然这种映射解决了分布不均的问题，但它在圆盘上造成了面积畸变：单位方形上的区域在映射到圆盘时会被拉伸或压缩（见图
  A.7）。这种畸变会削弱分层采样模式的效果，使得分层不够紧凑。一个更好的方法是采用“同心映射”（concentric
  mapping），它将 $[-1,1
  ]^2$
  方形区域上的点映射到单位圆盘，通过将同心方形均匀地映射为同心圆环（见图
  A.8）。
]

#parec[
  The mapping turns wedges of the square into slices of the disk.
  For example, points in the shaded area in Figure A.8 are mapped to
  $(r , theta)$ by

  - $r$ and $theta$ are obtained via the concentric mapping of the square
    to the disk.

  - The exact transformation from the square wedge to disk wedge is
    designed to ensure continuity across adjacent
    wedges.
][
  这种映射将方形区域的扇形楔块转换为圆盘的扇形切片。例如，图
  A.8 中阴影区域内的点会被映射到 $(r , theta)$，其规则是：

  - $r$ 和 $theta$ 通过同心映射由方形坐标转换到圆盘坐标。

  - 从方形楔块到圆盘扇形的具体变换经过设计，以确保相邻楔块之间的连续性。
]

#parec[
  For each PDF evaluation function, it is important to be clear
  which PDF is being evaluated—for example, we have already seen
  directional probabilities expressed both in terms of solid angle and in
  terms of $(theta , phi.alt)$. For hemispheres (and all other directional
  sampling in pbrt), these functions return probability with respect to
  solid angle. Thus, the uniform hemisphere PDF function is trivial and
  does not require that the direction be passed to it.
][
  在实现 PDF
  评估函数时，必须明确当前计算的是哪种
  PDF。例如，我们已经看到方向概率既可以用立体角形式表示，也可以用
  $(theta , phi.alt)$ 表示。对于半球（以及 pbrt
  中的其他方向采样），这些函数返回的是相对于立体角的概率。因此，均匀半球的
  PDF 函数非常简单，并且不需要传入具体的方向向量。
]

#parec[
  As we saw in the discussion of importance sampling (Section
  2.2.2), it is often useful to sample from a distribution that has a
  shape similar to that of the integrand being estimated. Many light
  transport integrals include a cosine factor, and therefore it is useful
  to have a method that generates directions according to a
  cosine-weighted distribution on the hemisphere. Such a method gives
  samples that are more likely to be close to the top of the hemisphere,
  where the cosine term has a large value, rather than near the bottom,
  where the cosine term is small.
][
  正如在重要性采样（第 2.2.2
  节）中讨论的那样，从与被积函数形状相似的分布中采样通常是有益的。很多光传输积分都包含一个余弦因子，因此，拥有一种能在半球上按余弦加权分布生成方向的方法非常有用。这种方法会使得样本更可能出现在半球顶部（余弦项较大），而不是底部（余弦项较小）。
]

#parec[
  We could compute the marginal and conditional densities as
  before, but instead we can use a technique known as Malley’s method to
  generate these cosine-weighted points. The idea behind Malley’s method
  is that if we choose points uniformly from the unit disk and then
  generate directions by projecting the points on the disk up to the
  hemisphere above it, the result will have a cosine-weighted distribution
  of directions (Figure
  A.10).
][
  我们可以像之前那样推导边缘和条件密度，但更简便的方法是使用
  Malley 方法来生成这些余弦加权点。Malley
  方法的思想是：如果我们从单位圆盘上均匀采样点，然后将圆盘上的点投影到其上方的半球，就会得到一个按余弦加权分布的方向集（见图
  A.10）。
]

#parec[
  It is sometimes useful to be able to uniformly sample rays in a
  cone of directions. This distribution is separable in
  $(theta , phi.alt)$, with $p (phi.alt) = 1 \/ (2 pi)$, and so we
  therefore need to derive a method to sample a direction $theta$ up to
  the maximum angle of the cone, $theta_max$. Incorporating the sine
  term from the measure on the unit sphere from Equation (4.8), we
  have
][
  在某些情况下，能够在一个方向圆锥内均匀采样射线是很有用的。该分布在
  $(theta , phi.alt)$ 上是可分离的，其中
  $p (phi.alt) = 1 \/ (2 pi)$，因此我们需要推导一种方法，使方向 $theta$
  能在圆锥的最大角度 $theta_max$
  内采样。结合单位球面测度中的正弦项（公式 4.8），我们得到：
]

#parec[
  Building on the approach for sampling piecewise-constant 1D
  distributions in Section A.4.7, we can apply the marginal-conditional
  approach to sample from piecewise-constant 2D distributions. We will
  consider the case of a 2D function $f (u , v)$ defined by a set of
  $n_u times n_v$ sample values $f\[u_i,v_j
  ]$, where
  $u_i in \[0,1)$ and $v_j in \[0,1)$, and
  $f\[u_i,v_j
  ]$ gives the constant value of $f$ over the domain
  $"bigl\[i/n_u,(i+1)/n_ubigr)times bigl\[j/n_v,(j+1)/n_vbigr)"$.
][
  在第
  A.4.7 节分段常数 1D
  分布采样方法的基础上，我们可以采用边缘–条件的方法来对分段常数 2D
  分布进行采样。我们考虑一个二维函数 $f (u , v)$，其由
  $n_u times n_v$ 个采样值 $f\[u_i,v_j
  ]$ 定义，其中
  $u_i in \[0,1)$，$v_j in \[0,1)$，并且
  $f\[u_i,v_j
  ]$ 表示函数在区域
  $"bigl\[i/n_u,(i+1)/n_ubigr)times bigl\[j/n_v,(j+1)/n_vbigr)"$
  上的常数值。
]

#parec[
  Integrals of $f$ are sums of $f\[u_i,v_j
  ]$, so that,
  for example, the integral of $f$ over the domain is

  $
    I_f #h(0em) = #h(0em) integral.double f (u , v) thin d u thin d v #h(0em) = #h(0em) frac(1, n_u n_v) sum_(i = 0)^(n_u - 1) sum_(j = 0)^(n_v - 1) f [u_i , v_j] .
  $


][
  函数 $f$ 的积分可以通过对 $f [u_i , v_j]$ 的求和得到。例如，$f$
  在整个定义域上的积分为： \
  $
    I_f #h(0em) = #h(0em) integral.double f (u , v) thin d u thin d v #h(0em) = #h(0em) frac(1, n_u n_v) sum_(i = 0)^(n_u - 1) sum_(j = 0)^(n_v - 1) f [u_i , v_j] .
  $
]

#parec[
  WindowedPiecewiseConstant2D generalizes the
  `PiecewiseConstant2D` class to allow the caller to specify a window that
  limits the sampling domain to a given rectangular subset of it. (This
  capability was key for the implementation of the
  `PortalImageInfiniteLight` in Section 12.5.3.) Before going into its
  implementation, we will start with the `SummedAreaTable` class, which
  provides some capabilities that make it easier to implement. We have
  encapsulated them in a stand-alone class, as they can be useful in other
  settings as well.
][
  `WindowedPiecewiseConstant2D` 类是对
  `PiecewiseConstant2D`
  的推广，它允许调用方指定一个矩形窗口，从而将采样域限制在该子区域内。（这种能力在第
  12.5.3 节 `PortalImageInfiniteLight`
  的实现中至关重要。）在介绍其实现之前，我们先从 `SummedAreaTable`
  类开始，该类提供了一些功能，使得实现更加简便。我们将其封装成一个独立类，因为它在其他场景下也很有用。
]

#parec[
  In 2D, a #emph[summed-area table] is a 2D array where each
  element $(x , y)$ stores a sum of values from another array $a$:

  $ s (x , y) = sum_(x prime = 0)^(x - 1) sum_(y prime = 0)^(y - 1) a (x prime , y prime) $

  The constructor takes a 2D array of values that are used to initialize
  its `sum` array, which holds the corresponding sums. The first entry is
  easy: it is just the $(0 , 0)$ entry from the provided `values`
  array.
][
  在二维情况下，#emph[积分区域表];（summed-area
  table）是一个二维数组，其中每个元素 $(x , y)$ 存储来自另一个数组 $a$
  的值的累加和：

  $ s (x , y) = sum_(x prime = 0)^(x - 1) sum_(y prime = 0)^(y - 1) a (x prime , y prime) $

  构造函数接受一个二维数组作为输入，用它来初始化内部的 `sum`
  数组，该数组存储相应的累加和。第一个元素很简单，就是输入 `values` 数组的
  $(0 , 0)$ 位置的值。
]

#parec[
  All the remaining entries in `sum` can be computed
  incrementally. It is easiest to start out by computing sums as $x$
  varies with $y = 0$ and vice versa.
][
  其余的 `sum`
  条目可以逐步递推计算。最容易的方式是先在 $y = 0$ 时沿着 $x$
  方向计算累加和，然后在 $x = 0$ 时沿着 $y$ 方向计算累加和。
]

#parec[
  The remainder of the sums are computed incrementally by adding
  the corresponding value from the provided array to two of the previous
  sums and subtracting a third. It is possible to use the definition from
  Equation (A.17) to verify that this expression gives the desired value,
  but it can also be understood geometrically; see Figure
  A.12.
][
  其余的累加和通过递推方式计算：将输入数组的当前值加上前两个累加和，再减去第三个累加和即可。可以用公式
  (A.17) 来验证该表达式确实正确，也可以从几何角度理解（见图 A.12）。
]

#parec[
  We will find it useful to be able to treat the sum as a
  continuous function defined over $[0 , 1]^2$. In doing so, our
  implementation effectively treats the originally provided array of
  values as the specification of a piecewise-constant function. Under this
  interpretation, the stored `sum` values effectively represent the
  function’s value at the upper corners of the box-shaped regions that the
  domain has been discretized into. (See Figure
  A.13.)
][
  我们希望能够将这个积分区域表视为定义在 $[0 , 1]^2$
  上的一个连续函数。在实现上，这相当于把输入的二维数组看作一个分段常数函数的定义。基于这种解释，存储的
  `sum` 值可以看作是该函数在域被划分后的方块区域右上角的函数值（见图
  A.13）。
]

#parec[
  It is more convenient to work with coordinates that are with
  respect to the array’s dimensions and so this method starts by scaling
  the provided coordinates accordingly. Note that an offset of 0.5 is not
  included in this remapping, as is done when indexing pixel values
  (recall the discussion of this topic in Section 8.1.4); this is due to
  the fact that `sum` defines function values at the upper corners of the
  discretized regions rather than at their
  center.
][
  在实现中，更方便的做法是将输入的连续坐标缩放到数组的维度范围内。因此该方法首先按数组的尺寸对输入坐标进行缩放。注意，这里没有像像素索引那样加上
  0.5（回忆第 8.1.4 节的讨论），原因在于 `sum`
  表存储的是分段区域右上角的函数值，而不是区域中心的值。
]

#parec[
  Bilinear interpolation of the four values surrounding the
  lookup point proceeds as usual, using `LookupInt()` to look up values of
  the sum at provided integer
  coordinates.
][
  在查询时，采用常规的双线性插值方法，使用 `LookupInt()`
  获取周围四个整数坐标的累积值，并在它们之间进行插值。
]

#parec[
  `LookupInt()` returns the value of the sum for provided integer
  coordinates. In particular, it is responsible for handling the details
  related to the `sum` array storing the sum at the upper corners of the
  domain strata.
][
  `LookupInt()`
  根据输入的整数坐标返回累加和。特别是，它负责处理 `sum`
  数组存储的值是定义域分块右上角累加值这一细节。
]

#parec[
  If either coordinate is zero-valued, the lookup point is along
  one of the lower edges of the domain (or is at the origin). In this
  case, a sum value of 0 is
  returned.
][
  如果某一维坐标为零，那么查询点就在定义域的下边界（或者在原点）。这种情况下返回的累积值为
  0。
]

#parec[
  Otherwise, one is subtracted from each coordinate so that
  indexing into the `sum` array accounts for the zero sums at the lower
  edges not being stored in `sum`.
][
  否则，每个坐标都需要减去 1，以便在
  `sum` 数组中正确索引。这样做是因为下边界处的零和并没有存储在 `sum`
  中。
]

#parec[
  Summed-area tables compute sums and integrals over arbitrary
  rectangular regions in a similar way to how the interior sum values were
  originally initialized. Here it is also possible to verify this
  computation algebraically, but the geometric interpretation may be more
  intuitive; see Figure
  A.14.
][
  积分区域表可以像初始化内部累加值时那样，对任意矩形区域高效地计算累加和与积分。这种计算既可以从代数上验证其正确性，也可以从几何角度更直观地理解（见图
  A.14）。
]

#parec[
  The SummedAreaTable class provides this capability through its
  Integral() method, which returns the integral of the piecewise-constant
  function over a 2D bounding box. Here, the sum of function values over
  the region is converted to an integral by dividing by the size of the
  function strata over the domain. We have used double precision here to
  compute the final sum in order to improve its accuracy: especially if
  there are thousands of values in each dimension, the sums may have large
  magnitudes and thus taking their differences can lead to catastrophic
  cancellation.
][
  `SummedAreaTable` 类通过其 `Integral()`
  方法提供这种功能，该方法返回某个二维包围盒区域内分段常数函数的积分。这里通过将区域内的累加和除以定义域的分块大小来转化为积分。为了提高精度，我们使用双精度计算最终和，尤其是在每个维度上有成千上万个值时，累加和可能非常大，相减时容易发生灾难性抵消。
]

#parec[
  Given SummedAreaTable’s capability of efficiently evaluating
  integrals over rectangular regions of a piecewise-constant function’s
  domain, the `WindowedPiecewiseConstant2D` class is able to provide
  sampling and PDF evaluation functions that operate over arbitrary
  caller-specified regions.
][
  借助 `SummedAreaTable`
  高效计算分段常数函数在矩形区域上的积分的能力，`WindowedPiecewiseConstant2D`
  类能够在任意调用者指定的区域上实现采样和 PDF 评估功能。
]

#parec[
  With the SummedAreaTable in hand, it is now possible to bring
  the pieces together to implement the `Sample()` method. Because it is
  possible that there is no valid sample inside the specified bounds
  (e.g., if the function’s value is zero), an optional return value is
  used in order to be able to indicate such cases.
][
  有了
  `SummedAreaTable` 之后，我们就可以将各个部分组合起来实现 `Sample()`
  方法了。由于在指定的采样窗口内可能不存在有效样本（例如函数在该区域内取值全为零），因此这里使用可选返回值来表示这种情况。
]

#parec[
  The first step is to check whether the function’s integral is
  zero over the specified bounds. This may happen due to a degenerate
  Bounds2f or due to a plain old zero-valued function over the
  corresponding part of its domain. In this case, it is not possible to
  return a valid
  sample.
][
  第一步是检查函数在指定窗口内的积分是否为零。这可能是由于
  `Bounds2f`
  退化（例如面积为零），也可能是因为函数在对应区域上恒为零。在这种情况下无法返回有效样本。
]

#parec[
  As discussed in Section 2.4.2, multidimensional distributions
  can be sampled by first integrating out all of the dimensions but one,
  sampling the resulting function, and then using that sample value in
  sampling the corresponding conditional distribution.
  `WindowedPiecewiseConstant2D` applies that very same idea, taking
  advantage of the fact that the summed-area table can efficiently
  evaluate the necessary integrals as needed.
][
  正如在第 2.4.2
  节中讨论的，多维分布可以通过“先对除一个维度外的其他维度积分，再对得到的边缘分布采样，最后基于该采样值对条件分布采样”的方式来实现。`WindowedPiecewiseConstant2D`
  正是应用了这一思想，并利用积分区域表高效计算所需积分的能力来完成实现。
]

#parec[
  For a 2D continuous function f(x,y) defined over a rectangular
  domain from $(x_0 , y_0)$ to $(x_1 , y_1)$, the marginal distribution in
  x is defined by

  $
    p (x) = frac(integral_(y_0)^(y_1) f (x , y prime) thin d y prime, integral_(x_0)^(x_1) integral_(y_0)^(y_1) f (x prime , y prime) thin d y prime d x prime) .
  $

  and the marginal’s cumulative distribution is

  $
    " bar P(x) = frac{int_{x_0}^{x} int_{y_0}^{y_1} f(x\',y\'),dy\' dx\'}{int_{x_0}^{x_1} int_{y_0}^{y_1} f(x\',y\'),dy\' dx\'}."
  $
][

]

#parec[
  The integrals in both the numerator and denominator of (P(x))
  can be evaluated using a summed-area table. The following lambda
  function evaluates (P(x)), using a cached normalization factor for the
  denominator in (bInt) to improve performance, as it will be necessary to
  repeatedly evaluate Px in order to sample from the distribution.
][
  在
  (P(x)) 的分子与分母中出现的积分都可以通过积分区域表来计算。下面的 lambda
  函数实现了对 (P(x)) 的求值，并将分母的归一化因子缓存到变量 (bInt)
  中以提升性能，因为在采样过程中需要多次调用 `Px`。
]

#parec[
  Sampling is performed using a separate utility method,
  `SampleBisection()`, that will also be useful for sampling the
  conditional density in y.
][
  采样操作通过一个辅助方法
  `SampleBisection()` 来完成，该方法在对 (y)
  方向条件分布进行采样时同样会用到。
]

#parec[
  `SampleBisection()` draws a sample from the density described
  by the provided CDF `P` by applying the bisection method to solve
  `u = P(x)` for `x` over a specified range and expects `P(min) = 0` and
  `P(max) = 1`. This function has the built-in assumption that the CDF is
  piecewise-linear over `n` equal-sized segments over $[0,1
  ]$. This fits
  SummedAreaTable perfectly, though it means that `SampleBisection()`
  would need modification to be used in other
  contexts.
][
  `SampleBisection()` 方法通过二分法解方程 `u = P(x)`
  来从给定 CDF `P` 描述的分布中采样，并在指定范围内返回解。它假定
  `P(min) = 0` 且 `P(max) = 1`。此外，该函数内建假设 CDF 在区间 $[0,1
  ]$
  上由 `n`
  个等宽区间构成分段线性函数。这与积分区域表的特性完全匹配，但也意味着若要在其他场景下使用，需要对其进行修改。
]

#parec[
  The initial `min` and `max` values bracket the solution.
  Therefore, bisection can proceed by successively evaluating `upper P` at
  their midpoint and then updating one or the other of them to maintain
  the bracket. This process continues until both endpoints lie inside one
  of the function discretization strata of width (1/n).
][
  最初的 `min` 和
  `max` 值构成了解的初始区间。二分法通过在区间中点处计算 `P`
  值，并根据结果更新区间上下界，从而逐步缩小解的范围。该过程一直持续到两个端点落入函数离散化区间（宽度为
  (1/n)）的同一个分段为止。
]

#parec[
  Once both endpoints are in the same stratum, it is possible to
  take advantage of the fact that `upper P` is known to be
  piecewise-linear and to find the value of `x` in closed
  form.
][
  当两个端点位于同一个区间时，就可以利用 `P`
  是分段线性的性质，直接通过闭式解求出 `x` 的值。
]

#parec[
  Given the sample (x), we now need to draw a sample from the
  conditional distribution

  ```latex
  p(y \mid x) = \frac{f(x,y)}{\int_{y_0}^{y_1} f(x,y')\,dy'}
  ```

  which has CDF

  $$

  P(y x) = .

  $$
][
  得到样本 (x) 后，我们需要进一步从条件分布中采样：

  ```latex
  p(y \mid x) = \frac{f(x,y)}{\int_{y_0}^{y_1} f(x,y')\,dy'}
  ```

  其累积分布函数为：

  $$

  P(y x) = .

  $$
]

#parec[
  Although the SummedAreaTable class does not provide the
  capability to evaluate 1D integrals directly, because the function is
  piecewise-constant we can equivalently evaluate a 2D integral where the
  (x) range spans only the stratum of the sampled (x) value.
][
  尽管
  `SummedAreaTable`
  类本身不能直接计算一维积分，但由于函数是分段常数的，我们可以等价地将其转化为二维积分，其中
  (x) 的范围仅覆盖包含采样点 (x) 的那个区间。
]

#parec[
  Similar to the marginal CDF (P(x)), we can define a lambda
  function to evaluate the conditional CDF (P(y x)). Again precomputing
  the normalization factor is worthwhile, as `Py` will be evaluated
  multiple times in the course of the sampling
  operation.
][
  与边缘分布的累积分布函数 (P(x)) 类似，我们也可以定义一个
  lambda 函数来计算条件 CDF (P(y
  x))。同样地，提前计算并缓存归一化因子是值得的，因为在采样过程中 `Py`
  会被多次调用。
]

#parec[
  The PDF value is computed by evaluating the function at the
  sampled point `p` and normalizing with its integral over `b`, which is
  already available in `bInt`.
][
  PDF 的计算方法是：取函数在采样点 `p`
  的值，并用该函数在窗口 `b` 上的积分（已存储在 `bInt` 中）进行归一化。
]

#parec[
  The `Eval()` method wraps up the details of looking up the
  function value corresponding to the provided 2D point.
][
  `Eval()`
  方法封装了查找给定二维点对应函数值的细节。
]

#parec[
  The PDF method implements the same computation that is used to
  compute the PDF in the `Sample()` method.
][
  `PDF` 方法实现的计算逻辑与
  `Sample()` 方法中用于计算 PDF 的过程完全一致。
]
