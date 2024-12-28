#import "../template.typ": parec, translator

== Further Reading

#parec[
  The Monte Carlo method was introduced soon after the development of the digital computer by Stanislaw Ulam and John von Neumann (@ulam1947statistical), though it also seems to have been independently invented by Enrico Fermi (@metropolis1987beginning). An early paper on Monte Carlo was written by Metropolis and Ulam (@metropolis1949monte).
][
  蒙特卡罗方法是在乌拉姆（Stanislaw Ulam）和冯·诺依曼（John von Neumann）发明数字计算机后不久引入的（@ulam1947statistical），尽管它似乎也是由恩里科·费米（@metropolis1987beginning）独立发明的。大都会和乌拉姆（@metropolis1949monte）在早期的论文中提到了蒙特卡洛。
]

#parec[
  Many books have been written on Monte Carlo integration. Hammersley and Handscomb (@hammersley1964monte), Spanier and Gelbard (@spanier1969monte), and Kalos and Whitlock (@kalos1986monte) are classic references. More recent books on the topic include those by Sobol (@sobol1994primer), Fishman (@fishman1996monte), and Liu (@liu2001monte). We have also found Owen's in-progress book (2019) to be an invaluable resource. Motwani and Raghavan (@motwani1995randomized) have written an excellent introduction to the broader topic of randomized algorithms.
][
  已经有许多关于蒙特卡罗积分的书籍。Hammersley和Handscomb（@hammersley1964monte）、Spanier和Gelbard（@spanier1969monte）以及Kalos和Whitlock（@kalos1986monte）都是经典的参考文献。关于该主题的最新书籍包括Sobol （@sobol1994primer）、Fishman（@fishman1996monte）和Liu（@liu2001monte）的书籍。我们还发现欧文(Art B. Owen)的正在进行的书（2019）#translator[这个链接能打开#link("https://artowen.su.domains/mc/")["artowen.su.domains/mc"]])是一个宝贵的资源。Motwani和Raghavan（@motwani1995randomized）对随机算法这个更广泛的主题写了一篇很好的介绍。
]

#parec[
  Most of the functions of interest in rendering are nonnegative; applying importance sampling to negative functions requires special care. A straightforward option is to define a sampling distribution that is proportional to the absolute value of the function. See also Owen and Zhou (@owen2000safe) for a more effective sampling approach for such functions.
][
  渲染中感兴趣的大多数函数都是非负的;将重要性采样应用于负函数需要特别小心。一个简单的选择是定义一个与函数的绝对值成比例的采样分布。另见Owen和Zhou（@owen2000safe），了解此类函数的更有效的采样方法。
]

#parec[
  Multiple importance sampling was developed by Veach and Guibas (@veach1995optimally; @veach1997robust). Normally, a predetermined number of samples are taken using each sampling technique; see Pajot et al. (@pajot2011representativity) and Lu et al. (@lu2013second) for approaches to adaptively distributing the samples over strategies in an effort to reduce variance by choosing those that are the best match to the integrand. Grittmann et al.(@grittmann2019variance) tracked the variance of each sampling technique and then dynamically adjusted the MIS weights accordingly. The MIS compensation approach was developed by Karlík et al. (@karlik2019mis).
][
  多重重要性抽样是由Veach和Guibas开发的（@veach1995optimally;@veach1997robust）。通常，使用每种采样技术采集预定数量的样本;参见Pajot et al.（@pajot2011representativity）和Lu et al.（@lu2013second），了解在策略上自适应分布样本的方法，以通过选择与被积函数最匹配的样本来减少方差。Grittmann等人（@grittmann2019variance）跟踪了每种采样技术的方差，然后相应地动态调整了MIS权重。MIS补偿方法由Karlík等人开发（@karlik2019mis）。
]

#parec[

  Sbert and collaborators (@sbert2016variance, @sbert2017adaptive, @sbert2018multiple) have performed further variance analysis on MIS estimators and have developed improved methods based on allocating samples according to the variance and cost of each technique. Kondapaneni et al. (@kondapaneni2019optimal) considered the generalization of MIS to include negative weights and derived optimal estimators in that setting. West et al. (@west2020continuous) considered the case where a continuum of sampling techniques are available and derived an optimal MIS estimator for that case, and Grittmann et al. (@grittmann2021correlation) have developed improved MIS estimators when correlation is present among samples (as is the case, for example, with bidirectional light transport algorithms).
][
  Sbert及其合作者（@sbert2016variance，@sbert2017adaptive，@sbert2018multiple）对MIS估计量进行了进一步的方差分析，并根据每种技术的方差和成本分配样本，开发了改进的方法。Kondapaneni等人（@kondapaneni2019optimal）考虑了MIS的推广，以包括负权重和在该设置中导出的最佳估计量。West等人（@west2020continuous）考虑了连续采样技术可用的情况，并推导出该情况下的最佳MIS估计量，Grittmann等人（@grittmann2021correlation）在样本之间存在相关性时开发了改进的MIS估计量（例如，双向光传输算法）。
]

#parec[

  Heitz (@heitz2020cant) described an inversion-based sampling method that can be applied when CDF inversion of a 1D function is not possible. It is based on sampling from a second function that approximates the first and then using a second random variable to adjust the sample to match the original function's distribution. An interesting alternative to manually deriving sampling techniques was described by Anderson et al. (@anderson2017aether), who developed a domain-specific language for sampling where probabilities are automatically computed, given the implementation of a sampling algorithm. They showed the effectiveness of their approach with succinct implementations of a number of tricky sampling techniques.
][
  Heitz（@heitz2020cant）描述了一种基于反演的采样方法，该方法可以在1D函数的CDF反演不可能时应用。它基于从近似第一个函数的第二个函数中采样，然后使用第二个随机变量来调整样本以匹配原始函数的分布。安德森等人（@anderson2017aether）描述了手动导出采样技术的一种有趣的替代方案，他开发了一种用于采样的特定领域语言，其中自动计算概率，给定采样算法的实现。他们通过一些巧妙的抽样技术的简洁实现展示了他们的方法的有效性。
]

#parec[
  The numerically stable sampling technique used in `SampleLinear()` is an application of Muller's method (@muller1956method) due to Heitz (@heitz2020cant).
][
  `SampleLinear()` 中使用的数值稳定采样技术是Heitz（@heitz2020cant）的Muller方法（@muller1956method）的应用。
]

#parec[
  In applications of Monte Carlo in graphics, the integrand is often a product of factors, where no sampling distribution is available that fits the full product. While multiple importance sampling can give reasonable results in this case, at least minimizing variance from ineffective sampling techniques, sampling the full product is still preferable. Talbot et al. (@talbot2005importance) applied importance resampling to this problem, taking multiple samples from some distribution and then choosing among them with probability proportional to the full integrand. More recently, Hart et al. (@heitz2020cant) presented a simple technique based on warping uniform samples that can be used to approximate product sampling. For more information on this topic, see also the “Further Reading” sections of @light-transport-i-surface-reflection and @light-transport-ii-volume-rendering, which discuss product sampling approaches in the context of specific light transport algorithms.
][
  在图形学中的蒙特卡罗应用中，被积函数通常是因子的乘积，其中没有适合完整乘积的抽样分布。虽然多重重要性抽样在这种情况下可以给出合理的结果，至少最小化无效抽样技术的方差，但对整个产品进行抽样仍然是优选的。塔尔博特等人（@talbot2005importance）将重要性回归应用于这个问题，从某个分布中提取多个样本，然后以与全被积函数成比例的概率在其中进行选择。最近，哈特等人（@heitz2020cant）提出了一种基于扭曲均匀样本的简单技术，可用于近似产品采样。有关此主题的更多信息，请参见@light-transport-i-surface-reflection 和@light-transport-ii-volume-rendering 的“进一步阅读”部分，其中讨论了特定光传输算法背景下的产品采样方法。
]

#parec[
  Debugging Monte Carlo algorithms can be challenging, since it is their behavior in expectation that determines their correctness: it may be difficult to tell if the program execution for a particular sample is correct. Statistical tests can be an effective approach for checking their correctness. See the papers by Subr and Arvo (@subr2007statistical) and by Jung et al. (@jung2020detecting) for applicable techniques.
][
  蒙特卡罗算法可能具有挑战性，因为它是他们的行为预期，确定其正确性：它可能很难告诉如果一个特定的样本的程序执行是正确的。统计检验是检验其正确性的有效方法。有关适用技术，请参见Subr和Arvo（@subr2007statistical）以及Jung等人（@jung2020detecting）的论文。
]

#parec[
  See also the “Further Reading” section in Appendix A, which has information about the sampling algorithms implemented there as well as related approaches.
][
  另请参阅附录A中的“进一步阅读”部分，其中包含有关此处实现的采样算法以及相关方法的信息。
]
