#import "../template.typ": parec

== Exercises
<exercises>


#parec[
  + ⑭ Replace ratio tracking in the `VolPathIntegrator::SampleLd()` method with delta tracking. After you confirm that your changes converge to the correct result, measure the difference in performance and MSE in order to compare the Monte Carlo efficiency of the two approaches for a variety of volumetric data sets. Do you find any cases where delta tracking is more efficient? If so, can you explain why?
][
  + ⑭ 在 `VolPathIntegrator::SampleLd()` 方法中用增量跟踪替换比率跟踪。在确认您的更改收敛到正确结果后，测量性能和 MSE 的差异，以比较两种方法在各种体数据集上的蒙特卡罗效率。您是否发现任何情况下增量跟踪更有效？如果是这样，您能解释为什么吗？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + ⑭ #emph[Residual ratio tracking] can compute transmittance more efficiently than ratio tracking in dense media; it is based on finding lower bounds of $sigma_t$ in regions of space, analytically computing that portion of the transmittance, and then using ratio tracking for the remaining variation (#link("Further_Reading.html#cite:Novak2014")[Novák et al.~2014];). Implement this approach in `pbrt` and measure its effectiveness. Note that you will need to make modifications to both the `Medium`'s `RayMajorantSegment` representation and the implementation of the `VolPathIntegrator` in order to do so.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + ⑭ #emph[残差比率跟踪] 可以比率跟踪更高效地计算密集介质中的透射率；它基于在空间区域中找到 $sigma_t$ 的下界，解析计算该部分的透射率，然后对剩余的变化使用比率跟踪（#link("Further_Reading.html#cite:Novak2014")[Novák et al.~2014];）。在 `pbrt` 中实现这种方法并测量其有效性。请注意，您需要修改 `Medium` 的 `RayMajorantSegment` 表示和 `VolPathIntegrator` 的实现才能做到这一点。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + ⑭ The current implementation of `SampleT_maj()` consumes a new uniform random value for each `RayMajorantSegment` returned by the medium's iterator. Its sampling operation can alternatively be implemented using a single uniform value to sample a total optical thickness and then finding the point along the ray where that optical thickness has been accumulated. Modify `SampleT_maj()` to implement that approach and measure rendering performance. Is there a benefit compared to the current implementation?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + ⑭ 当前的 `SampleT_maj()` 实现为介质迭代器返回的每个 `RayMajorantSegment` 消耗一个新的均匀随机值。其采样操作可以使用单一均匀随机值来采样总光学厚度，然后找到沿射线积累该光学厚度的点。修改 `SampleT_maj()` 以实现该方法并测量渲染性能。与当前实现相比是否有好处？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 4)
    + ⑮ It is not possible to directly sample emission in volumes with the current `Medium` interface. Thus, integrators are left to include emission only when their random walk through a medium happens to find a part of it that is emissive. This approach can be quite inefficient, especially for localized bright emission. Add methods to the `Medium` interface that allow for sampling emission and modify the direct lighting calculation in the `VolPathIntegrator` to use them. For inspiration, it may be worthwhile to read the papers by Villemin and Hery (#link("Further_Reading.html#cite:Villemin2013")[2013];) and Simon et al.~(#link("Further_Reading.html#cite:Simon2017")[2017];) on Monte Carlo sampling of 3D emissive volumes. Measure the improvement in efficiency with your approach. Are there any cases where it hurts performance?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 4)
    + ⑮ 目前的 `Medium` 接口无法直接对体积中的发射进行采样。因此，积分器只能在其随机穿过介质时碰巧找到发射部分时才包括发射。这种方法可能效率很低，尤其是对于局部高亮发射。向 `Medium` 接口添加允许采样发射的方法，并修改 `VolPathIntegrator` 中的直接光照计算以使用它们。为了获得灵感，可能值得阅读 Villemin 和 Hery（#link("Further_Reading.html#cite:Villemin2013")[2013];）以及 Simon 等人（#link("Further_Reading.html#cite:Simon2017")[2017];）关于 3D 发射体积的蒙特卡罗采样的论文。测量您的方法提高效率的程度。是否有任何情况下会降低性能？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 5)
    + ⑮ While sampling distances in participating media according to the majorant is much more effective than sampling uniformly, it does not account for other factors that vary along the ray, such as the scattering coefficient and phase function or variation in illumination from light sources. Implement the approach described by Wrenninge and Villemin (#link("Further_Reading.html#cite:Wrenninge2020")[2020];) on product sampling based on adapting the majorant to account for multiple factors in the integrand and then randomly selecting among weighted sample points. (You may find weighted reservoir sampling (Section #link("../Sampling_Algorithms/Reservoir_Sampling.html#sec:reservoir-sampling")[A.2];) a useful technique to apply in order to avoid the storage costs of maintaining the candidate samples.) Measure the performance of your implementation as well as how much it improves image quality for tricky volumetric scenes.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 5)
    + ⑮ 根据主导采样参与介质中的距离比均匀采样更有效，但它没有考虑沿射线变化的其他因素，如散射系数和相函数或光源的照明变化。实现
      Wrenninge 和 Villemin（#link("Further_Reading.html#cite:Wrenninge2020")[2020];）描述的积采样方法，该方法通过调整主导以考虑积分中的多个因素，然后在加权样本点中随机选择。（您可能会发现加权水库采样（#link("../Sampling_Algorithms/Reservoir_Sampling.html#sec:reservoir-sampling")[A.2] 节）是一种有用的技术，可以避免维护候选样本的存储成本。）测量您的实现的性能以及它在复杂体积场景中提高图像质量的程度。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 6)
    + ⑭ Add the capability to specify a bump or normal map for the bottom interface in the `LayeredBxDF`. (The current implementation applies bump mapping at the top interface only.) Render images that show the difference between perturbing the normal at the top interface and having a smooth bottom interface and vice versa.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 6)
    + ⑭ 为 `LayeredBxDF` 的底部界面添加指定凹凸贴图或法线贴图的功能。（当前实现仅在顶部界面应用凹凸贴图。）渲染显示在顶部界面扰动法线与底部界面光滑以及相反情况的图像。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 7)
    + ⑭ Investigate the effect of improving the sampling patterns used in the `LayeredBxDF`—for example, by replacing the uniform random numbers used with low-discrepancy points. You may need to pass further information through the BSDF evaluation routines to do so, such as the current pixel, pixel sample, and current ray depth. Measure how much error is reduced by your changes as well as their performance impact.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 7)
    + ⑭ 调查改进 `LayeredBxDF` 中使用的采样模式的效果——例如，用低差异序列替换使用的均匀随机数。您可能需要通过 BSDF 评估例程传递更多信息才能做到这一点，例如当前像素、像素样本和当前射线深度。测量您的更改减少了多少误差以及它们对性能的影响。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 8)
    + ⑮ Generalize the `LayeredBxDF` to allow the specification of an arbitrary number of layers with different media between them. You may want to review the improved sampling techniques for this case that were introduced by Gamboa et al.~(#link("Further_Reading.html#cite:Gamboa2020")[2020];). Verify that your implementation gives equivalent results to nested application of the `LayeredBxDF` and measure the efficiency difference between the two approaches.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 8)
    + ⑮ 将 `LayeredBxDF` 泛化以允许指定任意数量的层及其间的不同介质。您可能需要查看 Gamboa 等人（#link("Further_Reading.html#cite:Gamboa2020")[2020];）为这种情况引入的改进采样技术。验证您的实现是否给出与嵌套使用 `LayeredBxDF` 等效的结果，并测量两种方法之间的效率差异。
  ]
]


