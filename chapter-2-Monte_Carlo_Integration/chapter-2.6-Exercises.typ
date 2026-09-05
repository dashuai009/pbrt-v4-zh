#import "../template.typ": parec, translator, ez_caption

== #ez_caption[Exercises][习题]

#parec[
  1. ② Write a program that compares Monte Carlo and one or more alternative numerical integration techniques. Structure this program so that it is easy to replace the particular function being integrated. Verify that the different techniques compute the same result (given a sufficient number of samples for each of them). Modify your program so that it draws samples from distributions other than the uniform distribution for the Monte Carlo estimate, and verify that it still computes the correct result when the correct estimator, @eqt:MC-estimator, is used. (Make sure that any alternative distributions you use have nonzero probability of choosing any value of $x$ where $f(x)>0$.)
][
  1. ② 编写一个程序，比较蒙特卡洛方法和一种或多种其他数值积分技术。妥善组织程序结构，使更换被积函数变得容易。验证不同技术是否计算出相同的结果（对于每种技术，都使用足够多的样本）。修改你的程序，使其从非均匀分布中抽取样本用于蒙特卡洛估计，并验证在使用正确估计量（@eqt:MC-estimator）时，程序仍然能计算出正确的结果。（确保你使用的任何替代分布在任何 $f(x) > 0$ 的 $x$ 值上都有非零的选择概率。）
]


#parec[
  2. ① Write a program that computes unbiased Monte Carlo estimates of the integral of a given function. Compute an estimate of the variance of the estimates by performing a series of trials with successively more samples and computing the mean squared error for each one. Demonstrate numerically that variance decreases at a rate of $O(n)$.
][
  2. ① 编写一个程序，计算给定函数积分的无偏蒙特卡洛估计。通过执行一系列试验并逐步增加样本数量，计算每个试验的均方误差来估计估计值的方差。通过数值演示方差以 $O(n)$ 的速率降低。
]

#parec[
  3. ② The algorithm for sampling the linear interpolation function in @continuous-case implicitly assumes that $a,b gt.eq 0$ and that thus $f(x) gt.eq 0$. If $f$ is negative, then the importance sampling PDF should be proportional to $|f(x)|$. Generalize `SampleLinear()` and the associated PDF and inversion functions to handle the case where $f$ is always negative as well as the case where it crosses zero due to $a$ and $b$ having different signs.
][
  3. ② @continuous-case 中的线性插值函数采样算法隐含假设 $a,b gt.eq 0$，因此 $f(x) gt.eq 0$。如果 $f(x)$ 为负，则重要性采样的概率密度函数（PDF）应与 $|f(x)|$ 成正比。将 `SampleLinear()` 及相关 PDF 函数和采样逆操作函数推广到处理 $f(x)$ 始终为负的情况以及由于 $a$ 和 $b$ 符号不同而使 $f(x)$ 经过零点的情况。
]
#parec[][
  #translator[第 2 题的 $O(n)$ 写法来自固定上游原文。结合本章方差与样本数成反比的推导，此处“降低速率”的表达容易与方差本身的渐近阶混淆；保留原题，待统一核实。]
]
