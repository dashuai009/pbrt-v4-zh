#import "../template.typ": parec

= Reflection Models
<reflection-models>
#parec[
  This chapter defines a set of classes for describing the way that light scatters at surfaces. Recall that in @the-brdf-and-the-btdf we introduced the bidirectional reflectance distribution function (BRDF) abstraction to describe light reflection at a surface, the bidirectional transmittance distribution function (BTDF) to describe transmission at a surface, and the bidirectional scattering distribution function (BSDF) to encompass both of these effects. In this chapter, we will start by defining a generic interface to these surface reflection and transmission functions.
][
  本章定义了一组类别，用于描述光线在表面的散射方式。回想一下，在 @the-brdf-and-the-btdf 中，我们介绍了双向反射分布函数（BRDF）抽象，用于描述光线在表面的反射，双向透射分布函数（BTDF）用于描述光线在表面的透射，以及双向散射分布函数（BSDF）来包含这两种效应。在本章中，我们将首先定义这些表面反射和透射函数的通用接口。
]

#parec[
  Surface reflection models come from a number of sources:
][
  表面反射模型来源于多种渠道：
]

#parec[
  - Measured data: Reflection distribution properties of many real-world surfaces have been measured in laboratories. Such data may be used directly in tabular form or to compute coefficients for a set of basis functions.
][
  - 实测数据：许多现实世界表面的反射分布特性已在实验室中测量。这些数据可以直接以表格形式使用，或用于计算一组基函数的系数。
]
#parec[
  - Phenomenological models: Equations that attempt to describe the qualitative properties of real-world surfaces can be remarkably effective at mimicking them. These types of BSDFs can be particularly easy to use, since they tend to have intuitive parameters that modify their behavior (e.g., “roughness”).
][
  - 现象学模型：试图描述现实世界表面定性特性的方程，可以非常有效地模仿它们。这些类型的BSDF易于使用，因为它们倾向于具有直观的参数来修改它们的行为（例如，“粗糙度”）。
]
#parec[
  - Simulation: Sometimes, low-level information is known about the composition of a surface. For example, we might know that a paint is comprised of colored particles of some average size suspended in a medium or that a particular fabric is comprised of two types of threads with known reflectance properties. In this case, a preprocess could simulate the behavior of light within the microstructure to fit an approximate BSDF. Alternatively, simulation could occur when rendering.
][
  - 模拟：有时，我们对表面的组成有低级别的了解。例如，我们可能知道某种油漆由大小均匀的彩色颗粒悬浮在介质中组成，或者某种特定织物由两种具有已知反射特性的线组成。在这种情况下，预处理可以模拟光线在微观结构中的行为，以适配近似的BSDF。或者，可能在渲染时进行模拟。
]
#parec[
  - Physical (wave) optics: Some reflection models have been derived using a detailed model of light, treating it as a wave and computing the solution to Maxwell's equations to find how it scatters from a surface with known properties. They are mainly of use when the scene contains geometric detail at the micrometer level that makes wave-optical behavior readily apparent, such as with thin films, coatings, and periodic structures as found on digital optical data storage formats like CDs and DVDs.
][
  - 物理（波）光学：一些反射模型是使用光的详细模型推导出来的，将光视为波，计算麦克斯韦方程的解，以计算出光如何从已知特性的表面散射。当场景包含微米级的几何细节时，这些模型占主导地位，这使得波动光学行为变得明显，例如在薄膜、涂层和数码光学数据存储格式（如CD和DVD）上发现的周期结构。
]
#parec[
  - Geometric optics: As with simulation approaches, if the surface's low-level scattering and geometric properties are known, then closed-form reflection models can sometimes be derived directly from these descriptions. Geometric optics makes modeling light's interaction with the surface more tractable, since complex wave effects like diffraction can be ignored.
][
  - 几何光学：与模拟方法一样，如果已知表面的低级散射和几何特性，则有时可以直接从这些描述中推导出封闭形式的反射模型。几何光学使光与表面的相互作用建模更易处理，因为可以忽略复杂的波动效应，如衍射。
]

#parec[
  This chapter discusses the implementation of a number of such models along with the associated theory. See also Section 14.3, which introduces a reflection model based on the simulation of light scattering in layered materials. The “Further Reading” section at the end of this chapter gives pointers to a wide variety of additional reflection models.
][
  本章讨论了一些此类模型的实现及其相关理论。另见第14.3节，该节介绍了基于模拟分层材料中光散射的反射模型。本章末尾的“进一步阅读”部分提供了指向各种额外反射模型的信息。
]
#parec[
  An important component of surface appearance is the spatial variation of reflection and transmission properties over the surface. The texture and material classes of Chapter 10 will address that problem, while the abstractions presented here will only consider scattering at a single point on a surface. Further, BRDFs and BTDFs explicitly only model scattering from light that enters and exits a surface at a single point. For surfaces that exhibit meaningful subsurface light transport, a more complete simulation of light scattering inside the material is necessary—for example, by applying the volumetric light transport algorithms of @light-transport-ii-volume-rendering.
][
  表面外观的一个重要组成部分是表面上反射和透射特性的空间变化。第10章的纹理和材料类别将解决这个问题，而此处提出的抽象只考虑在表面上一个点的散射。此外，BRDF和BTDF明确地只模拟从一个点进入和离开表面的光的散射。对于展示有意义的次表面光传输的表面，需要更完整的光在材料内部散射的模拟——例如，通过应用@light-transport-ii-volume-rendering 的体积光传输算法。
]

*Basic Terminology*

#parec[
  We now introduce basic terminology for describing reflection from surfaces. To compare the resulting visual appearance, we will classify reflection into the following four broad categories: diffuse, glossy specular, perfect specular, and retroreflective (Figure 9.1). Most real surfaces exhibit a mixture of these four behaviors. Diffuse surfaces scatter light equally in all directions. Although a perfectly diffuse surface is not physically realizable, examples of near-diffuse surfaces include dull chalkboards and matte paint. Glossy specular surfaces such as plastic or high-gloss paint scatter light preferentially in a set of reflected directions—they show blurry reflections of other objects. Perfect specular surfaces scatter incident light in a single outgoing direction. Mirrors and glass are examples of perfect specular surfaces. Finally, retroreflective surfaces like velvet or the Earth's moon scatter light primarily back along the incident direction. Images throughout this chapter will show the differences between these various behaviors in rendered scenes.
][
  我们现在介绍描述表面反射的基本术语。为了比较所产生的视觉外观，我们将反射归类为以下四个广泛的类别：漫反射、光泽镜面、完美镜面和逆反射（图9.1）。大多数真实表面展示这四种行为的混合。漫反射表面将光线均匀地散射到所有方向。尽管完美漫反射表面在物理上是不可实现的，但接近漫反射表面的例子包括暗淡的黑板和哑光漆。如塑料或高光漆等光泽镜面表面倾向于沿一组反射方向优先散射光线——它们显示其他物体的模糊反射。完美镜面表面将入射光散射到单一的出射方向。镜子和玻璃是完美镜面表面的例子。最后，如天鹅绒或地球的月亮等逆反射表面主要将光沿入射方向散射回来。本章中的图像将展示这些不同行为在渲染场景中的差异。
]


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f01.svg", width: 80%),
  caption: [
    #parec[
      Reflection from a surface can be generally categorized by the distribution of reflected light from an incident direction (heavy lines): (a) diffuse, (b) glossy specular, (c) nearly perfect specular, and (d) retroreflective distributions.
      Given a particular category of reflection, the reflectance distribution function may be isotropic or anisotropic. With an isotropic material, if you choose a point on the surface and rotate it around its normal axis at that point, the distribution of light reflected at that point does not change. Diffuse materials like paper or wall paint are usually isotropic due to the directionally random arrangement of wood fibers or paint particles.

    ][
      从表面的反射通常可以根据入射方向（粗线）反射光的分布进行分类：（a）漫反射，（b）光泽镜面，（c）近乎完美的镜面，和（d）逆反射分布。
      给定特定的反射类别，反射分布函数可能是各向同性的或各向异性的。对于各向同性材料，如果您在表面上选择一个点并围绕该点的法线轴旋转它，那么该点反射的光分布不会改变。像纸张或墙漆这样的漫射材料通常是各向同性的，因为木纤维或漆粒子的方向随机排列。
    ]
  ],
)

#parec[
  In contrast, anisotropic materials reflect different amounts of light as you rotate them in this way. Examples of anisotropic materials include hair and many types of cloth. Industrial processes such as milling, rolling, extrusion, and 3D printing also tend to produce highly anisotropic surfaces, an extreme example being brushed metal.
][
  相比之下，各向异性材料在以这种方式旋转时反射不同量的光。各向异性材料的例子包括头发和许多类型的布料。工业过程如铣削、轧制、挤压和3D打印也倾向于产生高度各向异性的表面，极端例子是拉丝金属。
]
