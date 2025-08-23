#import "../template.typ": parec

== Exercises <exercises>


#parec[
  + Modify `soac` so that the code it generates leaves objects in AOS layout in memory and recompile `pbrt`. (You will need to manually update a few places in the #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[WavefrontPathIntegrator] that only access a single field of a structure, as well.) How is performance affected by this change?
][
  + 修改 `soac`，使其生成的代码在内存中以 AOS（结构数组）布局存储对象，并重新编译 `pbrt`。（您还需要手动更新 #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[WavefrontPathIntegrator] 中的几个只访问结构单个字段的地方。）这种更改对性能有何影响？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + `pbrt`'s #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] class stores two `Float`s for each wavelength: one for the wavelength value and one for its PDF. This class is passed along between almost all kernels. Render a scene on the GPU and work out an estimate of the amount of bandwidth consumed in communicating these values between kernels. (You may need to make some assumptions to do so.)
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + `pbrt` 的 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] 类为每个波长存储两个 `Float`：一个用于波长值，一个用于其概率密度函数（PDF）。这个类几乎在所有内核之间传递。在 GPU 上渲染一个场景，并估算这些值在内核之间传递时消耗的带宽量。（您可能需要做出一些假设来进行估算。）
  ]
]

#parec[
  Then, implement an alternative `SOA` representation for #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] that stores only two values: the `Float` sample used to originally sample the wavelengths and a Boolean value that indicates whether the secondary wavelengths have been terminated. You might use the sign bit to encode the Boolean value, or you might even try a 16-bit encoding, with the $\[ 0 , 1 \)$ sample value quantized to 15 bits and the 16th used to indicate termination. Write code to encode #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] to this representation when they are pushed to a queue and to decode this representation back to `SampledWavelengths` when work is read from the queue via a call to #link("../Cameras_and_Film/Film_and_Imaging.html#Film::SampleWavelengths")[Film::SampleWavelengths()] and then possibly a call to #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[SampledWavelengths::TerminateSecondary()];.
][
  然后，为 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] 实现一种替代的 `SOA` 表示，仅存储两个值：用于最初采样波长的 `Float` 样本和一个指示次级波长是否已终止的布尔值。您可以使用符号位来编码布尔值，或者甚至尝试使用 16 位编码，将 $\[ 0 , 1 \)$ 样本值量化为 15 位，第 16 位用于指示终止。编写代码在将 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] 推送到队列时对其进行编码，并在通过调用 #link("../Cameras_and_Film/Film_and_Imaging.html#Film::SampleWavelengths")[Film::SampleWavelengths()] 从队列读取工作时将其解码回 `SampledWavelengths`，然后可能调用 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[SampledWavelengths::TerminateSecondary()];。
]

#parec[
  Estimate how much bandwidth your improved representation saves. How is runtime performance affected? Can you draw any conclusions about whether your GPU is memory or bandwidth limited when running these kernels?
][
  估算您改进的表示节省了多少带宽。运行时性能如何受到影响？您能否得出任何关于 GPU 在运行这些内核时是受内存还是带宽限制的结论？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + The direct lighting code in the `EvaluateMaterialsAndBSDFs()` kernel may suffer from divergence in the #link("../Light_Sources/Light_Interface.html#Light::SampleLi")[Light::SampleLi()] call if the scene has a variety of types of light source. Construct such a scene and then experiment with moving light sampling into a separate kernel, using a work queue to supply work to it and where the light samples are pushed on to a queue for the rest of the direct lighting computation. What is the effect on performance for your test scene? Is performance negatively impacted for scenes with just a single type of light?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 如果场景中有各种类型的光源，`EvaluateMaterialsAndBSDFs()` 内核中的直接照明代码可能会因 #link("../Light_Sources/Light_Interface.html#Light::SampleLi")[Light::SampleLi()] 调用而导致分歧。构建这样的场景，然后尝试将光采样移动到一个单独的内核中，使用工作队列为其提供工作，并将光样本推送到队列中以进行其余的直接照明计算。对于您的测试场景，这对性能有什么影响？对于只有单一类型光源的场景，性能是否受到负面影响？
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 4)
    + Add support for ray differentials to the #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[WavefrontPathIntegrator];, including both generating them for camera rays and computing updated differentials for reflected and refracted rays. (You will likely want to repurpose the code in the implementation of the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] `SpawnRay()` method in Section 10.1.3.)
  ]
][
  #block[
    #set enum(numbering: "1.", start: 4)
    + 为 #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[WavefrontPathIntegrator] 添加对光线微分的支持，包括为相机光线生成它们以及计算反射和折射光线的更新微分。（您可能希望重用第 10.1.3 节中 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction]
      `SpawnRay()` 方法的实现代码。）
  ]
]

#parec[
  After ensuring that texture filtering results match `pbrt` running on the CPU, measure the performance impact of your changes. How much performance is lost from the bandwidth used in passing ray differentials between kernels? Do any kernels have better performance? If so, can you explain why?
][
  在确保纹理过滤结果与在 CPU 上运行的 `pbrt` 匹配后，测量这些更改对性能的影响。通过在内核之间传递光线微分所使用的带宽，性能损失了多少？是否有内核性能更好？如果是，您能解释为什么吗？
]

#parec[
  Next, implement one of the more space-efficient techniques for representing derivative information with rays that are described by Akenine-Möller et al.~(#link("Further_Reading.html#cite:AkenineMoller2019")[2019];). How do performance and filtering quality compare to ray differentials?
][
  接下来，实现 Akenine-Möller 等人（#link("Further_Reading.html#cite:AkenineMoller2019")[2019];）描述的用于表示光线导数信息的更节省空间的技术之一。与光线微分相比，性能和过滤质量如何？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 5)
    + The #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[WavefrontPathIntegrator];'s performance can suffer from scenes with very high maximum ray depths when there are few active rays remaining at high depths and, in turn, insufficient parallelism for the GPU to reach its peak capabilities. One approach to address this problem is #emph[path regeneration];, which was described by Novák et al.~(#link("Further_Reading.html#cite:Novak2010")[2010];).
  ]
][
  #block[
    #set enum(numbering: "1.", start: 5)
    + 当在高最大光线深度的场景中剩余的活动光线很少时，#link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[WavefrontPathIntegrator] 的性能可能会受到影响，从而导致 GPU 无法达到其峰值能力。解决此问题的一种方法是 #emph[路径再生];（重新生成路径），由 Novák 等人（#link("Further_Reading.html#cite:Novak2010")[2010];）描述。
  ]
]

#parec[
  Following this approach, modify `pbrt` so that each ray traced handles its termination individually when it reaches the maximum depth. Execute a modified camera ray generation kernel each time through the main rendering loop so that additional pixel samples are taken and camera rays are generated until the current #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#RayQueue")[RayQueue] is filled or there are no more samples to take. Note that you will have to handle #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[Film] updates in a different way than the current implementation—for example, via a work queue when rays terminate. You may also have to handle the case of multiple threads updating the same pixel sample.
][
  按照这种方法，修改 `pbrt`，使每条追踪的光线在达到最大深度时单独处理其终止。在每次通过主渲染循环时执行修改后的相机光线生成内核，以便在当前 #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#RayQueue")[RayQueue] 填满或没有更多样本可取时，生成额外的像素样本和相机光线。请注意，您将不得不以不同于当前实现的方式处理 #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[Film] 更新——例如，通过工作队列在光线终止时进行处理。您还可能需要处理多个线程更新同一像素样本的情况。
]

#parec[
  Finally, implement a mechanism for the GPU to notify the CPU when all rays have terminated so that it knows when to stop launching kernels.
][
  最后，实现一种机制，使 GPU 能够在所有光线终止时通知 CPU，以便它知道何时停止启动内核。
]

#parec[
  With all that taken care of, measure `pbrt`'s performance for a scene with a high maximum ray depth. (Scenes that include volumetric scattering with media with very high albedos are a good choice for this measurement.) How much is performance improved with your approach? How is performance affected for easier scenes with lower maximum depths that do not suffer from this problem?
][
  在处理完所有这些之后，测量具有高最大光线深度的场景中的 `pbrt` 性能。（包含具有非常高反照率的介质的体积散射的场景是此测量的不错选择。）使用您的方法性能提高了多少？对于不受此问题影响的较低最大深度的简单场景，性能如何受到影响？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 6)
    + In `pbrt`'s current implementation, the wavefront path tracer is usually slower than the #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[VolPathIntegrator] when running on the CPU. Render a few scenes using both approaches and benchmark `pbrt`'s performance. Are any opportunities to improve the performance of the wavefront approach on the CPU evident?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 6)
    + 在 `pbrt` 的当前实现中，波前路径追踪器在 CPU 上运行时通常比
      #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[VolPathIntegrator] 慢。分别使用这两种方法渲染几个场景并对 `pbrt` 的性能进行基准测试。是否有任何机会提高波前方法在 CPU 上的性能？
  ]
]

#parec[
  Next, measure how performance changes as you increase or decrease the queue sizes (and consequently, the number of pixel samples that are evaluated in parallel). Performance may be suboptimal with the current value of #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator::maxQueueSize")[WavefrontPathIntegrator::maxQueueSize];, which leads to queues much larger than can fit in the on-chip caches. However, too small a queue size may offer insufficient parallelism or may lead to too little work being done in each #link("../Utilities/Parallelism.html#ParallelFor")[ParallelFor()] call, which may also hurt performance. Are there better default queue sizes for the CPU than the ones used currently?
][
  接下来，测量随着队列大小的增加或减少（从而并行评估的像素样本数量）性能如何变化。当前 #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator::maxQueueSize")[WavefrontPathIntegrator::maxQueueSize] 的值可能导致队列大于可以放入片上缓存的大小，从而导致性能不佳。然而，队列大小过小可能会导致并行性不足，或者导致每次 #link("../Utilities/Parallelism.html#ParallelFor")[ParallelFor()] 调用的工作量过少，这也可能损害性能。是否有比当前使用的更好的 CPU 默认队列大小？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 7)
    + When the `WavefrontPathIntegrator` runs on the CPU, there is currently minimal performance benefit from organizing work in queues. However, the queues offer the possibility of making it easier to use SIMD instructions on the CPU: kernels might remove 8 work items at a time, for example, processing them together using the 8 elements of a 256-bit SIMD register. Implement this approach and investigate `pbrt`'s performance. (You may want to consider using a language such as `ispc` (#link("Further_Reading.html#cite:Pharr2012")[Pharr and Mark 2012];) to avoid the challenges of manually writing code using SIMD intrinsics.)
  ]
][
  #block[
    #set enum(numbering: "1.", start: 7)
    + 当 `WavefrontPathIntegrator` 在 CPU 上运行时，通过在队列中组织工作获得的性能提升有限。然而，队列提供了更容易在 CPU 上使用 SIMD 指令的可能性：内核可以一次移除 8 个工作项，使用 256 位 SIMD 寄存器的 8 个元素一起处理它们。实现这种方法并调查 `pbrt` 的性能。（您可能希望考虑使用 `ispc`（#link("Further_Reading.html#cite:Pharr2012")[Pharr 和 Mark 2012];）这样的语言，以避免手动编写 SIMD 内在函数代码的挑战。）
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 8)
    + Implement a GPU ray tracer that is based on `pbrt`'s class implementations from previous chapters but uses the GPU's ray-tracing API for scheduling rendering work instead of the wavefront-based architecture used in this chapter. (You may want to start by supporting only a subset of the full functionality of the `WavefrontPathIntegrator`.) Measure the performance of the two implementations and discuss their differences. You may find it illuminating to use a profiler to measure the bandwidth consumed by each implementation. Can you find cases where the wavefront integrator's performance is limited by available memory bandwidth but yours is not?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 8)
    + 实现一个基于 `pbrt` 先前章节类实现的 GPU 光线追踪器，但使用 GPU 的光线追踪 API 来调度渲染工作，而非本章使用的波前架构。（您可能希望首先仅支持 `WavefrontPathIntegrator` 的完整功能的一个子集。）测量这两种实现的性能并讨论它们的差异。您可能会发现使用分析器来测量每种实现消耗的带宽很有启发性。您能否找到波前积分器的性能受限于可用内存带宽而您的实现没有的情况？
  ]
]


