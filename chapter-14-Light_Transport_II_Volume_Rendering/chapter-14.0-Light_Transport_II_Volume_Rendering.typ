#import "../template.typ": parec

= Light Transport II: Volume Rendering
<light-transport-ii-volume-rendering>


#parec[
  The abstractions for representing participating media that were introduced in @volume-scattering describe how media scatter light but they do not provide the capability of simulating the global effects of light transport in a scene. The situation is similar to that with BSDFs: they describe local effects, but it was necessary to start to introduce integrators in @light-transport-i-surface-reflection that accounted for direct lighting and interreflection in order to render images. This chapter does the same for volumetric scattering.
][
  @volume-scattering 中介绍的用于表示参与介质的抽象概念描述了介质如何散射光，但它们无法模拟场景中光传输的全局效果。这种情况与 BSDF 类似：它们描述局部效果，因此在@light-transport-i-surface-reflection 中引入了积分器，以便考虑直接照明和相互反射，从而渲染图像。本章对体积散射做同样的事情。
]

#parec[
  We begin with the introduction of the equation of transfer, which generalizes the light transport equation to describe the equilibrium distribution of radiance in scenes with participating media. Like the transmittance equations in @Transmittance, the equation of transfer has a null-scattering generalization that allows sampling of heterogeneous media for unbiased integration. We will also introduce a path integral formulation of it that generalizes the surface path integral from @integral-over-paths.
][
  我们首先介绍传输方程，它将光传输方程推广为描述具有参与介质的场景中辐射亮度平衡分布的方程。与@Transmittance 中的透射方程类似，传输方程具有一个无散射推广，允许对非均匀介质进行采样以实现无偏积分。我们还将介绍其路径积分公式，将@integral-over-paths 中的表面路径积分进行推广。
]

#parec[
  Following sections discuss implementations of solutions to the equation of transfer. @volume-scattering-integrators introduces two Integrators that use Monte Carlo integration to solve the full equation of transfer, making it possible to render scenes with complex volumetric effects. @scattering-from-layered-materials then describes the implementation of LayeredBxDF, which solves a 1D specialization of the equation of transfer to model scattering from layered materials at surfaces.
][
  接下来的章节讨论传输方程解的实现。@volume-scattering-integrators 介绍了两个使用蒙特卡罗积分来求解完整传输方程的积分器，使得渲染具有复杂体积效果的场景成为可能。@scattering-from-layered-materials 则描述了LayeredBxDF（分层双向散射分布函数）的实现，它解决了传输方程的一维特化形式，用于模拟表面层状材料的散射。
]



