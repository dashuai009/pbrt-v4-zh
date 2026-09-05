#import "../template.typ": parec, ez_caption

= #ez_caption[Sampling Algorithms][采样算法] <Appendix-A>

#parec[
  @monte-carlo-integration provided an introduction to the principles of sampling and Monte Carlo integration that are most widely used in `pbrt`. However, a number of additional sampling techniques—the alias method, reservoir sampling, and rejection sampling—that are used only occasionally were not described there. This appendix introduces each of those techniques and then concludes with two sections that further apply the inversion method to derive sampling techniques for a variety of useful distributions.
][
  @monte-carlo-integration 介绍了 `pbrt` 中最常用的采样和蒙特卡洛积分原理，但没有讨论一些只偶尔使用的其他采样技术：别名法、蓄水池采样和拒绝采样。本附录将依次介绍这些技术，最后两节则进一步应用逆变换法，推导多种实用分布的采样方法。
]
