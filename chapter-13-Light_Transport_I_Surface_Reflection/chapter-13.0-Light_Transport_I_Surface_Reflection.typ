#import "../template.typ": parec

= Light Transport I Surface Reflection
<light-transport-i-surface-reflection>
#parec[
  This chapter brings together the ray-tracing algorithms, radiometric concepts, and Monte Carlo sampling algorithms of the previous chapters to implement two different integrators that compute scattered radiance from surfaces in the scene. These integrators are much more effective than the `RandomWalkIntegrator` from the first chapter; with them, some scenes are rendered with hundreds of times lower error.
][
  本章结合前几章的光线追踪算法、辐射度概念和蒙特卡罗采样算法，实现了两个不同的积分器，用于计算场景中表面散射的辐射。 这些积分器比第一章中的`RandomWalkIntegrator`更为有效；使用它们，一些场景的渲染误差显著降低。
]

#parec[
  We start by deriving the light transport equation, which was first introduced in @indirect-light-transport. We can then formally introduce the path-tracing algorithm, which applies Monte Carlo integration to solve that equation. We will then describe the implementation of the `SimplePathIntegrator`, which provides a pared-down implementation of path tracing that is useful for understanding the basic algorithm and for debugging sampling algorithms. The chapter concludes with the `PathIntegrator`, which is a more complete path tracing implementation.
][
  我们首先推导出光传输方程，该方程@indirect-light-transport 首次被引入。 然后我们可以正式介绍路径追踪算法，该算法应用蒙特卡罗积分来解决该方程。 接下来，我们将描述`SimplePathIntegrator`的实现，它提供了一个简化的路径追踪实现，有助于理解基本算法和调试采样算法。 本章最后介绍`PathIntegrator`，这是一个更完整的路径追踪实现。
]

#parec[
  Both of these integrators find light-carrying paths starting from the camera, accounting for scattering from shapes' surfaces. @light-transport-ii-volume-rendering will extend path tracing to include the effects of participating media. (The online edition of this book also includes a chapter that describes bidirectional methods for constructing light-carrying paths starting both from the camera and from light sources.)
][
  这两个积分器都从相机出发，寻找携带光的路径，并考虑形状表面的散射。 @light-transport-ii-volume-rendering 将扩展路径追踪以包括参与介质的效果。 （本书的在线版还包括一章，描述了从相机和光源同时构建携带光路径的双向方法。）
]


