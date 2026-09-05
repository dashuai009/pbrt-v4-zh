#import "../template.typ": parec, ez_caption

== #ez_caption[Exercises][习题]
<appendix-a-exercises>

#parec[
  #enum(start: 1)[① Show that the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Reservoir_Sampling.html#WeightedReservoirSampler::Merge")[`WeightedReservoirSampler::Merge()`] method leaves the resulting reservoir with a sample that indeed is stored with probability equal to its weight divided by the sums of weights for all the samples in the two reservoirs.]
][
  #enum(start: 1)[① 证明：调用 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Reservoir_Sampling.html#WeightedReservoirSampler::Merge")[`WeightedReservoirSampler::Merge()`] 后，合并所得蓄水池保存某个样本的概率，确实等于该样本的权重除以原来两个蓄水池各自处理过的全部样本的权重总和。]
]

#parec[
  #enum(start: 2)[② Modify the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] implementation to use the adaptive CDF representation described by Lawrence et al. (#link(<taila-cite:Lawrence05>)[2005]), and experiment with how much more compact the CDF representation can be made without causing image artifacts. (Good test scenes include those that use #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#ImageInfiniteLight")[`ImageInfiniteLight`]s, which use the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`] and, thus, `PiecewiseConstant1D` for sampling.) Can you measure an improvement in rendering speed due to more efficient searches through the approximated CDF?]
][
  #enum(start: 2)[② 修改 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#PiecewiseConstant1D")[`PiecewiseConstant1D`] 的实现，采用 Lawrence 等人（#link(<taila-cite:Lawrence05>)[2005]）介绍的自适应 CDF 表示，并通过实验考察：在不产生图像瑕疵的前提下，CDF 表示还能压缩多少。（使用 #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#ImageInfiniteLight")[`ImageInfiniteLight`] 的场景很适合测试，因为它通过 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[`PiecewiseConstant2D`]，进而通过 `PiecewiseConstant1D` 进行采样。）近似 CDF 的搜索更高效后，能否测出渲染速度的提升？]
]

#parec[
  #enum(start: 3)[② Extend #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`] to provide methods that efficiently compute 1D integrals along each dimension and then modify the #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#WindowedPiecewiseConstant2D")[`WindowedPiecewiseConstant2D`] class's `Sample()` method to use this capability for sampling the conditional CDF $P(y | x)$. How is overall rendering performance affected by your change when rendering a scene that uses the #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#PortalImageInfiniteLight")[`PortalImageInfiniteLight`]? Profile `pbrt` and measure the change in performance of the `Sample()` method with your changes. What conclusions can you draw from your results?]
][
  #enum(start: 3)[② 扩展 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SummedAreaTable")[`SummedAreaTable`]，提供沿各个维度高效计算一维积分的方法；再修改 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#WindowedPiecewiseConstant2D")[`WindowedPiecewiseConstant2D`] 的 `Sample()`，利用这一功能对条件 CDF $P(y | x)$ 进行采样。渲染使用 #link("https://pbr-book.org/4ed/Light_Sources/Infinite_Area_Lights.html#PortalImageInfiniteLight")[`PortalImageInfiniteLight`] 的场景时，这项改动如何影响整体性能？对 `pbrt` 进行性能剖析，测量修改前后 `Sample()` 的性能变化。你能从结果中得出什么结论？]
]
