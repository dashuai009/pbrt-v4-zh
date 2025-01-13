#import "../template.typ": parec

= Volume Scattering
<volume-scattering>

#parec[
  We have assumed so far that scenes are made up of collections of surfaces in a vacuum, which means that radiance is constant along rays between surfaces. However, there are many real-world situations where this assumption is inaccurate: fog and smoke attenuate and scatter light, and scattering from particles in the atmosphere makes the sky blue and sunsets red. This chapter introduces the mathematics that describe how light is affected as it passes through #emph[participating media];—large numbers of very small particles distributed throughout a region of 3D space. These volume scattering models in computer graphics are based on the assumption that there are so many particles that scattering is best modeled as a probabilistic process rather than directly accounting for individual interactions with particles. Simulating the effect of participating media makes it possible to render images with atmospheric haze, beams of light through clouds, light passing through cloudy water, and subsurface scattering, where light exits a solid object at a different place than where it entered.
][
  我们一直假设场景是由真空中的一系列表面构成的，这意味着辐射亮度在物体表面之间的光线的沿途是恒定的。然而，在许多现实世界的情况下，这一假设是不准确的：雾和烟会削弱和散射光线，大气中的粒子散射使得天空呈现蓝色，日落时呈现红色。本章介绍了光线穿过#emph[参与介质（participating media）];时如何受到影响的数学原理——大量非常小的粒子分布在三维空间的某个区域中。这些计算机图形中的体积散射模型基于这样一个假设：粒子数量如此之多，以至于最好把散射被建模为一个概率过程，而不是直接考虑与粒子的个体相互作用。通过模拟参与介质的效果，可以渲染出具有大气雾霾、光束穿过云层、光线穿过浑浊水体以及次表面散射的图像，其中光线在固体物体中从进入点的不同位置射出。
]

#parec[
  This chapter first describes the basic physical processes that affect the radiance along rays passing through participating media, including the phase function, which characterizes the distribution of light scattered at a point in space. (It is the volumetric analog to the BSDF.) It then introduces transmittance, which describes the attenuation of light in participating media. Computing unbiased estimates of transmittance can be tricky, so we then discuss null scattering, a mathematical formalism that makes it easier to sample scattering integrals like the one that describes transmittance. Next, the `Medium` interface is defined; it is used for representing the properties of participating media in a region of space. `Medium` implementations provide information about the scattering properties at points in their extent. This chapter does not cover techniques related to computing lighting and the effect of multiple scattering in volumetric media; the associated Monte Carlo integration algorithms and implementations of `Integrator`s that handle volumetric effects will be the topic of @light-transport-ii-volume-rendering.
][
  本章首先描述影响光线穿过参与介质时辐射亮度的基本物理过程，包括相位函数，它表征了空间中某一点的光散射分布。（它对应于描述体积的 BSDF。）然后介绍透过率，它描述了参与介质中光的衰减。计算透过率的无偏估计可能会很复杂，因此我们接着讨论零散射，这是一种数学形式，使得采样如描述透过率的散射积分更容易。接下来，我们定义了`Medium`接口；它用于表示空间区域中参与介质的属性。`Medium`实现提供其范围内各点的散射属性信息。本章不涉及计算照明和体积介质中多重散射效应的技术；相关的蒙特卡罗积分算法和处理体积效应的`Integrator`实现将在 @light-transport-ii-volume-rendering 中讨论。
]


