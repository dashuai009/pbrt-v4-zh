#import "../template.typ": parec

== Exercises

#parec[
  To further improve efficiency, Russian roulette can be applied to skip tracing many of the shadow rays that make a low contribution to the final image: to implement this approach, tentatively compute the potential contribution of each shadow ray to the final overall radiance value before tracing the ray. If the contribution is below some threshold, apply Russian roulette to possibly skip tracing the ray. Measure the effect your scheme has on Monte Carlo efficiency for a number of test scenes.
][
  为了进一步提高效率，可以应用俄罗斯轮盘赌跳过追踪对最终图像贡献较低的许多阴影光线：要实现这种方法，首先在追踪光线之前，初步计算每条阴影光线对最终整体辐射值的潜在贡献。如果贡献低于某个阈值，则以可能跳过追踪该光线的方式应用俄罗斯轮盘赌。测量你的方案对蒙特卡罗效率在多个测试场景中的影响。
]

#parec[
  Read Veach's description of efficiency-optimized Russian roulette, which adaptively chooses a threshold for applying Russian roulette (Veach 1997; Section 10.4.1). Implement this algorithm in pbrt, and evaluate its effectiveness in comparison to manually setting these thresholds.
][
  阅读Veach关于优化效率的俄罗斯轮盘赌的描述，该方法自适应地选择应用俄罗斯轮盘赌的阈值（Veach 1997; 第10.4.1节）。在`pbrt`中实现该算法，并评估其与手动设置这些阈值的效果比较。
]

#parec[
  If a scene has an object with a material that causes all but one of the wavelengths in SampledWavelengths to be terminated (e.g., due to dispersion), then rays may often undergo a number of scattering events before they hit such an object. In pbrt's current implementation, the path's radiance estimate is divided by the wavelength PDF values once, in the PixelSensor::ToSensorRGB() method. An implication of this design is that all the lighting calculations along the path are affected by the termination of wavelengths, and not just the ones after it happens. The result is an increase in color noise in such images.
][
  如果一个场景中有一个物体，其材料导致SampledWavelengths中的波长被终止（例如，由于色散），那么光线可能会在撞击这样的物体之前经历多次散射事件。在`pbrt`的当前实现中，路径的辐射估计值在PixelSensor::ToSensorRGB()方法中被波长PDF值除以一次。这种设计的一个含义是，路径上的所有光照计算都受到波长终止的影响，而不仅仅是发生之后的那些。结果是此类图像中的颜色噪声增加。
]

#parec[
  Modify one or more integrators to instead perform this division by the current set of wavelength PDFs each time the radiance estimate being calculated is updated and not in PixelSensor::ToSensorRGB(). Verify that the same image is computed for scenes without wavelength termination (other than minor differences due to round-off error). Is there any change in performance? Find a scene where this change improves the result and measure the reduction in MSE.
][
  修改一个或多个积分器，以便在每次更新计算的辐射估计时，使用当前的波长PDF集进行此除法，而不是在PixelSensor::ToSensorRGB()中进行。验证对于没有波长终止的场景计算出相同的图像（除了由于舍入误差引起的微小差异）。性能是否有变化？找出一个此更改改善结果的场景并测量MSE的减少。
]

#parec[
  Measure how much time is spent in Monte Carlo evaluation in the BSDF::rho() method when VisibleSurfaces are being initialized in the PathIntegrator. Do so for both simple and complex scenes that include a variety of BSDF models. Then, improve the BSDF interface so that each BxDF can provide its own rho() implementation, possibly returning either an approximation or the closed-form reflectance. How much does performance improve as a result of your changes?
][
  测量在PathIntegrator中初始化VisibleSurface时，用于蒙特卡罗评估的时间。对包括各种BSDF模型的简单和复杂场景进行此操作。然后，改进BSDF接口，使每个BxDF能够提供其自己的rho()实现，可能返回近似值或闭合形式的反射率。你的更改结果提高了多少性能？
]

#parec[
  Implement a technique for generating samples from the product of the light and BSDF distributions; see for example the papers by Burke et al.~(2005), Cline et al.~(2006), Clarberg et al.~(2005), Rousselle et al.~(2008), and Hart et al.~(2020). Compare the effectiveness of the approach you implement to the direct lighting calculation currently implemented in pbrt. Investigate how scene complexity (and, thus, how expensive shadow rays are to trace) affects the Monte Carlo efficiency of the two techniques.
][
  实现一种从光和BSDF分布的乘积中生成样本的技术；例如参见Burke等人的论文（2005），Cline等人（2006），Clarberg等人（2005），Rousselle等人（2008），以及Hart等人（2020）。比较你实现的方法与pbrt中当前实现的直接光照计算的有效性。研究场景复杂性（因此，追踪阴影光线的成本）如何影响这两种技术的蒙特卡罗效率。
]

#parec[
  Clarberg and Akenine-Möller (2008b) and Popov et al.~(2013) both described algorithms that perform visibility caching—computing and interpolating information about light source visibility at points in the scene. Implement one of these methods and use it to improve the direct lighting calculation in pbrt. What sorts of scenes is it particularly effective for? Are there scenes for which it does not help?
][
  Clarberg和Akenine-Möller（2008b）和Popov等人（2013）都描述了进行可见性缓存的算法——在场景中的点计算和插值光源可见性的信息。实现这些方法之一，并用它来改进pbrt中的直接光照计算。它对哪些类型的场景特别有效？是否有场景对其没有帮助？
]

#parec[
  Modify pbrt so that the user can flag certain objects in the scene as being important sources of indirect lighting, and modify the PathIntegrator to sample points on those surfaces according to dA to generate some of the vertices in the paths it generates. Use multiple importance sampling to compute weights for the path samples, incorporating the probability that they would have been sampled both with BSDF sampling and with this area sampling. How much can this approach reduce variance and improve efficiency for scenes with substantial indirect lighting? How much can it hurt if the user flags surfaces that make little or no contribution or if multiple importance sampling is not used? Investigate generalizations of this approach that learn which objects are important sources of indirect lighting as rendering progresses so that the user does not need to supply this information ahead of time.
][
  修改pbrt，以便用户可以将场景中的某些物体标记为间接光照的重要来源，并修改PathIntegrator以根据 $d A$ 采样这些表面上的点，以生成其生成路径中的一些顶点。使用多重重要性采样计算路径样本的权重，结合它们通过BSDF采样和区域采样的概率。对于具有大量间接光照的场景，这种方法能减少多少方差并提高效率？如果用户标记对贡献很小或没有贡献的表面，或者不使用多重重要性采样，会造成多大损害？研究该方法的推广，使其在渲染过程中学习哪些物体是间接光照的重要来源，以便用户不需要提前提供此信息。
]

#parec[
  Implement a path guiding algorithm such as the one developed by Müller and collaborators (Müller et al.~2017; Müller 2019) or Reibold et al.~(2018). How much does your approach reduce error for scenes with highly varying indirect lighting? What is its effect on scenes with smoother lighting?
][
  实现一种路径引导技术，例如由Müller及其合作者开发的算法（Müller et al.~2017; Müller 2019）或Reibold等人（2018）。你的方法在具有高度变化的间接光照场景中能减少多少误差？它对光照较平滑的场景有什么影响？
]


