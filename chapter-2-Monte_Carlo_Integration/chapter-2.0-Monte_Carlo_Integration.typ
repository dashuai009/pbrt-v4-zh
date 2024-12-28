#import "../template.typ": parec


= Monte Carlo Integration
<monte-carlo-integration>
#figure(
  image("../pbr-book-website/4ed/openers/dragon-blp-twosided-good.jpg"),
)


#parec[
  Rendering is full of integration problems. In addition to the light transport equation @eqt:rendering-equation, in the following chapters we will see that integral equations also describe a variety of additional quantities related to light, including the sensor response in a camera, the attenuation and scattering of light in participating media, and scattering from materials like skin. These integral equations generally do not have analytic solutions, so we must turn to numerical methods. Although standard numerical integration techniques like trapezoidal integration or Gaussian quadrature are effective at solving low-dimensional smooth integrals, their rate of convergence is poor for the higher dimensional and discontinuous integrals that are common in rendering. Monte Carlo integration techniques provide one solution to this problem. They use random sampling to evaluate integrals with a convergence rate that is independent of the dimensionality of the integrand.
][
  渲染充满了积分问题。除了光传输方程@eqt:rendering-equation 之外，在接下来的章节中我们还会看到，积分方程还描述了与光相关的多种其他量，包括相机中的传感器响应、参与介质中光的衰减和散射，以及像皮肤这样的材料的散射。这些积分方程通常没有解析解，因此我们必须求助于数值方法。尽管标准的数值积分技术，如梯形积分或高斯求积，在解决低维平滑积分方面很有效，但它们在解决常见于渲染中的高维和不连续积分的收敛速度很差。蒙特卡洛积分技术提供了解决这一问题的一种方法。它们使用随机抽样来评估积分，其收敛速度与被积函数的维数无关。
]


#parec[
  Monte Carlo integration #footnote["For brevity, we will refer to Monte Carlo integration simply as “Monte Carlo.”"] has the useful property that it only requires the ability to evaluate an integrand $f(x)$ at arbitrary points in the domain in order to estimate the value of its integral $integral f(x) d x$. This property not only makes Monte Carlo easy to implement but also makes the technique applicable to a broad variety of integrands. It has a natural extension to multidimensional functions; in Chapter 13, we will see that the light transport algorithm implemented in the `RandomWalkIntegrator` can be shown to be estimating the value of an infinite-dimensional integral.
][
  蒙特卡洛积分#footnote("为简洁起见，我们将蒙特卡罗积分简称为“蒙特卡罗”。")具有一个有用的特性，即只需要在定义域中的若干点估计被积函数 $f(x)$ ，就能估计其积分 $integral f(x) d x$ 的值。这一特性不仅使蒙特卡洛易于实现，而且使该技术适用于广泛的被积函数。它自然地扩展到多维函数；在第13章中，我们将看到在`RandomWalkIntegrator`中实现的光传输算法可以被证明是在估计一个无限维积分的值。
]

#parec[
  Judicious use of randomness has revolutionized the field of algorithm design. Randomized algorithms fall broadly into two classes: #emph[Las Vegas] and #emph[Monte Carlo];. Las Vegas algorithms are those that use randomness but always give the same result in the end (e.g., choosing a random array entry as the pivot element in Quicksort). Monte Carlo algorithms, on the other hand, give different results depending on the particular random numbers used along the way but give the right answer #emph[on average];. So, by averaging the results of several runs of a Monte Carlo algorithm (on the same input), it is possible to find a result that is statistically very likely to be close to the true answer.
][
  明智地使用随机性已经彻底改变了算法设计领域。随机算法大致分为两类：_拉斯维加斯_和_蒙特卡洛_。拉斯维加斯算法是那些使用随机性但最终总是给出相同结果的算法（例如，在快速排序中选择一个随机数组条目作为枢轴元素）。另一方面，蒙特卡洛算法根据沿途使用的特定随机数给出不同的结果，但平均而言给出正确的答案。因此，通过平均多次运行蒙特卡洛算法（使用相同的输入）的结果，可以找到一个统计上非常接近真实答案的结果。
]

#parec[
  The following sections discuss the basic principles of Monte Carlo integration, focusing on those that are widely used in `pbrt`. See also @Appendix-A, which has the implementations of additional Monte Carlo sampling functions that are more rarely used in the system.
][
  以下部分将讨论蒙特卡洛积分的基本原理，特别关注那些在 `pbrt`中广泛应用的原理。另请参见@Appendix-A，其中包含了在系统中较少使用的其他蒙特卡洛采样方法的实现。
]
