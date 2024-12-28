#import "../template.typ": parec

= Light Sources
<light-sources>
#parec[
  In order for objects in a scene to be visible, there must be a source of illumination so that some light is reflected from them to the camera sensor. To that end, this chapter first presents the #link("Light_Sources/Light_Interface.html#Light")[Light] interface, which allows specification of a variety of types of light sources. (Before reading this chapter, you may wish to review @light-emission, which describes the physical processes underlying light emission.)
][
  为了使场景中的物体可见，必须有一个光源，以便一些光线从物体反射到相机传感器。 为此，本章首先介绍了 #link("Light_Sources/Light_Interface.html#Light")[Light] 接口，该接口允许指定各种类型的光源。 （在阅读本章之前，您可能希望回顾一下 @light-emission，该节描述了光发射的物理过程。）
]

#parec[
  The implementations of a number of useful light sources follow. Because the implementations of different types of lights are all hidden behind a carefully designed interface, the light transport routines in @light-transport-i-surface-reflection through @wavefront-rendering-on-gpus can generally operate without knowing which particular types of lights are in the scene, similar to how acceleration structures can hold collections of different types of primitives without needing to know the details of their actual representations.
][
  接下来是一些有用光源的实现。 由于不同类型光源的实现都隐藏在精心设计的接口之后，因此 @light-transport-i-surface-reflection 到@wavefront-rendering-on-gpus 中的光传输例程通常可以在不知道场景中具体有哪些类型光源的情况下运行，这类似于加速结构可以包含不同类型的基本体而无需了解其实际表示的细节。
]

#parec[
  A wide variety of light source models are introduced in this chapter, although the variety is slightly limited by `pbrt`'s physically based design. Many non-physical light source models have been developed for computer graphics, incorporating control over properties like the rate at which the light falls off with distance, which objects are illuminated by the light, which objects cast shadows from the light, and so on. These sorts of controls are incompatible with physically based light transport algorithms and thus cannot be provided in the models here.
][
  本章介绍了多种光源模型，尽管由于 `pbrt` 的基于物理的设计，种类略有局限。 计算机图形学中开发了许多非物理光源模型，结合了对光随距离衰减速率、哪些物体被光照亮、哪些物体投射阴影等属性的控制。 这些控制与基于物理的光传输算法不兼容，因此无法在此处的模型中提供。
]

#parec[
  As an example of the problems such lighting controls pose, consider a light that does not cast shadows: the total energy arriving at surfaces in the scene increases without bound as more surfaces are added. Consider a series of concentric shells of spheres around such a light; if occlusion is ignored, each added shell increases the total received energy. This directly violates the principle that the total energy arriving at surfaces illuminated by the light cannot be greater than the total energy emitted by the light.
][
  作为此类照明控制问题的一个例子，考虑一个不投射阴影的光源：随着更多表面被添加，场景中到达表面的总能量会无限增加。 考虑围绕这样一个光源的一系列同心球壳；如果忽略遮挡，每增加一个壳层都会增加接收到的总能量。这直接违反了光照亮的表面接收到的总能量不能大于光源发出的总能量的原则。
]

#parec[
  In scenes with many lights, it is impractical to account for the illumination from all of them at each point being shaded. Fortunately, this issue is yet another that can be handled stochastically. Given a suitable weighting factor, an unbiased estimate of the effect of illumination from all the lights can be computed by considering just a few of them, or even just one. The last section of this chapter therefore introduces the #link("Light_Sources/Light_Sampling.html#LightSampler")[`LightSampler`];, which defines an interface for choosing such light sources as well as a number of implementations of it.
][
  在有许多光源的场景中，在每个被着色的点考虑所有光源的照明是不切实际的。 幸运的是，这个问题可以通过随机地处理。 通过给定一个合适的加权因子，我们可以只考虑几个光源，甚至仅一个光源，来计算所有光源照明效果的无偏估计。 因此，本章的最后一节介绍了 #link("Light_Sources/Light_Sampling.html#LightSampler")[`LightSampler`];，它定义了选择此类光源的接口以及其多个实现。
]


