#import "../template.typ": parec, ez_caption

== #ez_caption[Further Reading][延伸阅读]

#parec[
  The Monte Carlo method was introduced soon after the development of the digital computer by Stanislaw Ulam and John von Neumann (@ulam1947statistical), though it also seems to have been independently invented by Enrico Fermi (@metropolis1987beginning). An early paper on Monte Carlo was written by Metropolis and Ulam (@metropolis1949monte).
][
  数字计算机问世后不久，Stanislaw Ulam 和 John von Neumann 提出了蒙特卡洛方法（@ulam1947statistical）；Enrico Fermi 似乎也独立发明了这一方法（@metropolis1987beginning）。Metropolis 和 Ulam（@metropolis1949monte）撰写了一篇早期的蒙特卡洛论文。
]

#parec[
  Many books have been written on Monte Carlo integration. Hammersley and Handscomb (@hammersley1964monte), Spanier and Gelbard (@spanier1969monte), and Kalos and Whitlock (@kalos1986monte) are classic references. More recent books on the topic include those by Sobol′ (@sobol1994primer), Fishman (@fishman1996monte), and Liu (@liu2001monte). We have also found Owen's in-progress book (@owen2019monte) to be an invaluable resource. Motwani and Raghavan (@motwani1995randomized) have written an excellent introduction to the broader topic of randomized algorithms.
][
  关于蒙特卡洛积分，已有许多著作。Hammersley 和 Handscomb（@hammersley1964monte）、Spanier 和 Gelbard（@spanier1969monte），以及 Kalos 和 Whitlock（@kalos1986monte）的著作都是经典参考资料。较新的著作包括 Sobol′（@sobol1994primer）、Fishman（@fishman1996monte）和 Liu（@liu2001monte）的书。我们也发现，Owen 尚在撰写中的著作（@owen2019monte）是极其宝贵的资源。Motwani 和 Raghavan（@motwani1995randomized）则为随机算法这一更广泛的主题写了一部出色的入门著作。
]

#parec[
  Most of the functions of interest in rendering are nonnegative; applying importance sampling to negative functions requires special care. A straightforward option is to define a sampling distribution that is proportional to the absolute value of the function. See also Owen and Zhou (@owen2000safe) for a more effective sampling approach for such functions.
][
  渲染中需要处理的函数大多非负；对取负值的函数应用重要性采样时，需要格外谨慎。一种直接的做法，是定义与函数绝对值成正比的采样分布。Owen 和 Zhou（@owen2000safe）还介绍了针对这类函数的更有效采样方法。
]

#parec[
  Multiple importance sampling was developed by Veach and Guibas (@veach1995optimally; @veach1997robust). Normally, a predetermined number of samples are taken using each sampling technique; see Pajot et al. (@pajot2011representativity) and Lu et al. (@lu2013second) for approaches to adaptively distributing the samples over strategies in an effort to reduce variance by choosing those that are the best match to the integrand. Grittmann et al. (@grittmann2019variance) tracked the variance of each sampling technique and then dynamically adjusted the MIS weights accordingly. The MIS compensation approach was developed by Karlík et al. (@karlik2019mis).
][
  多重重要性采样由 Veach 和 Guibas 提出（@veach1995optimally；@veach1997robust）。通常，每种采样技术取得的样本数是预先确定的；Pajot 等人（@pajot2011representativity）和 Lu 等人（@lu2013second）则介绍了在不同策略间自适应分配样本的方法，通过选择与被积函数最匹配的策略来降低方差。Grittmann 等人（@grittmann2019variance）跟踪每种采样技术的方差，并据此动态调整 MIS 权重。MIS 补偿方法由 Karlík 等人（@karlik2019mis）提出。
]

#parec[

  Sbert and collaborators (@sbert2016variance, @sbert2017adaptive, @sbert2018multiple) have performed further variance analysis on MIS estimators and have developed improved methods based on allocating samples according to the variance and cost of each technique. Kondapaneni et al. (@kondapaneni2019optimal) considered the generalization of MIS to include negative weights and derived optimal estimators in that setting. West et al. (@west2020continuous) considered the case where a continuum of sampling techniques are available and derived an optimal MIS estimator for that case, and Grittmann et al. (@grittmann2021correlation) have developed improved MIS estimators when correlation is present among samples (as is the case, for example, with bidirectional light transport algorithms).
][
  Sbert 及其合作者（@sbert2016variance，@sbert2017adaptive，@sbert2018multiple）进一步分析了 MIS 估计量的方差，并依据各项技术的方差与开销分配样本，提出了改进方法。Kondapaneni 等人（@kondapaneni2019optimal）将 MIS 推广到允许负权重的情形，并推导出该情形下的最优估计量。West 等人（@west2020continuous）考虑可用采样技术构成连续族的情形，推导出相应的最优 MIS 估计量。Grittmann 等人（@grittmann2021correlation）则针对样本之间存在相关性的情形，提出了改进的 MIS 估计量；例如，双向光传输算法就会产生这种相关性。
]

#parec[

  Heitz (@heitz2020cant) described an inversion-based sampling method that can be applied when CDF inversion of a 1D function is not possible. It is based on sampling from a second function that approximates the first and then using a second random variable to adjust the sample to match the original function's distribution. An interesting alternative to manually deriving sampling techniques was described by Anderson et al. (@anderson2017aether), who developed a domain-specific language for sampling where probabilities are automatically computed, given the implementation of a sampling algorithm. They showed the effectiveness of their approach with succinct implementations of a number of tricky sampling techniques.
][
  Heitz（@heitz2020cant）介绍了一种基于逆变换的采样方法，可用于无法对一维函数的 CDF 求逆的情形。该方法先从近似原函数的另一个函数中采样，再用第二个随机变量调整样本，使其匹配原函数的分布。Anderson 等人（@anderson2017aether）介绍了一种有趣的方法，可以替代手工推导采样技术：他们开发了一种面向采样的领域专用语言，能够根据采样算法的实现自动计算概率。他们通过简洁地实现若干难以处理的采样技术，展示了该方法的有效性。
]

#parec[
  The numerically stable sampling technique used in `SampleLinear()` is an application of Muller's method (@muller1956method) due to Heitz (@heitz2020cant).
][
  `SampleLinear()` 所用的数值稳定采样技术，是 Heitz（@heitz2020cant）对 Muller 方法（@muller1956method）的一项应用。
]

#parec[
  In applications of Monte Carlo in graphics, the integrand is often a product of factors, where no sampling distribution is available that fits the full product. While multiple importance sampling can give reasonable results in this case, at least minimizing variance from ineffective sampling techniques, sampling the full product is still preferable. Talbot et al. (@talbot2005importance) applied importance resampling to this problem, taking multiple samples from some distribution and then choosing among them with probability proportional to the full integrand. More recently, Hart et al. (@hart2020practical) presented a simple technique based on warping uniform samples that can be used to approximate product sampling. For more information on this topic, see also the “Further Reading” sections of @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering, which discuss product sampling approaches in the context of specific light transport algorithms.
][
  在图形学的蒙特卡洛应用中，被积函数往往是多个因子的乘积，而我们未必有与整个乘积匹配的采样分布。多重重要性采样在这种情况下能取得不错的结果，至少可以尽量降低低效采样技术带来的方差，但直接对整个乘积进行采样仍更为理想。Talbot 等人（@talbot2005importance）将重要性重采样用于这一问题：先从某个分布中取得多个样本，再以与完整被积函数成正比的概率从中选取样本。较近的工作中，Hart 等人（@hart2020practical）提出了一种基于变换均匀样本的简单方法，可用于近似乘积采样。有关这一主题的更多信息，还可参阅 @light-transport-i-surface-reflection 和 @light-transport-ii-volume-rendering 的“延伸阅读”部分，那里讨论了特定光传输算法中的乘积采样方法。
]

#parec[
  Debugging Monte Carlo algorithms can be challenging, since it is their behavior in expectation that determines their correctness: it may be difficult to tell if the program execution for a particular sample is correct. Statistical tests can be an effective approach for checking their correctness. See the papers by Subr and Arvo (@subr2007statistical) and by Jung et al. (@jung2020detecting) for applicable techniques.
][
  调试蒙特卡洛算法可能相当困难，因为决定其正确性的是期望意义下的行为：对于某一个样本，往往很难判断相应的程序执行是否正确。统计检验是检查其正确性的一种有效手段。Subr 和 Arvo（@subr2007statistical）以及 Jung 等人（@jung2020detecting）的论文介绍了适用的技术。
]

#parec[
  See also the “Further Reading” section in Appendix A, which has information about the sampling algorithms implemented there as well as related approaches.
][
  另请参阅附录 A 的“延伸阅读”部分，其中介绍了该附录所实现的采样算法及相关方法。
]
