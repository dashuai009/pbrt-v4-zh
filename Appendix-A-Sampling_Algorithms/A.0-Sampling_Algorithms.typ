#import "../template.typ": parec, translator

= Sampling Algorithms <Appendix-A>

#parec[
  @monte-carlo-integration;provided an introduction to the principles of sampling and Monte Carlo integration that are most widely used in pbrt. However, a number of additional sampling techniques—the alias method, reservoir sampling, and rejection sampling—that are used only occasionally were not described there. This appendix introduces each of those techniques and then concludes with two sections that further apply the inversion method to derive sampling techniques for a variety of useful distributions.
][
  @monte-carlo-integration;介绍了 *pbrt* 中最常用的采样与蒙特卡洛积分原理。然而，还有一些额外的采样技术——别名方法（alias method）、水库采样（reservoir sampling）以及拒绝采样（rejection sampling），由于只在少数情况下使用，因此没有在第 2 章中描述。本附录将依次介绍这些技术，并在最后通过两个小节进一步应用反演方法（inversion method），推导出适用于多种有用分布的采样技术。
]
