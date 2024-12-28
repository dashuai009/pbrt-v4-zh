#import "../template.typ": parec, ez_caption

== Measured BSDF
<measured-bsdf>
#parec[
  The reflection models introduced up to this point represent index of refraction changes at smooth and rough boundaries, which constitute the basic building blocks of surface appearance. More complex materials (e.g., paint on primer, metal under a layer of enamel) can sometimes be approximated using multiple interfaces with participating media between them; the layered material model presented in Section 14.3 is based on that approach.
][
  到目前为止介绍的反射模型表示在光滑和粗糙边界处的折射率变化，这些构成了表面外观的基本构件。更复杂的材料（例如，底漆上的油漆、搪瓷层下的金属）有时可以使用多个界面来近似，其中在它们之间有参与介质；第14.3节中介绍的分层材料模型就是基于这种方法。
]

#parec[
  However, many real-world materials are beyond the scope of even such layered models. Examples include:
][
  然而，许多现实世界的材料甚至超出了这种分层模型的范围。例子包括：
]

#parec[
  - #emph[Materials characterized by wave-optical phenomena that produce
  striking directionally varying coloration.] Examples include
    iridescent paints, insect wings, and holographic paper.
][
  - #emph[以波动光学现象为特征的材料，这些现象产生显著的方向性变化的颜色。]
    例子包括虹彩油漆、昆虫翅膀和全息纸。
]

#parec[
  - #emph[Materials with rough interfaces.] In `pbrt`, we have chosen to
    model such surfaces using microfacet theory and the Trowbridge–Reitz
    distribution. However, it is important to remember that both of these
    are models that generally do not match real-world behavior perfectly.
][
  - #emph[具有粗糙界面的材料。]
    在`pbrt`中，我们选择使用微面理论和Trowbridge–Reitz分布来模拟此类表面。然而，重要的是要记住，这两者都是模型，通常不能完美匹配现实世界的行为。
]

#parec[
  - #emph[Surfaces with non-standard microstructure.] For example, a woven
    fabric composed of two different yarns looks like a surface from a
    distance, but its directional intensity and color variation are not
    well-described by any standard BRDF model due to the distinct
    reflectance properties of fiber-based microgeometry.
][
  - #emph[具有非标准微结构的表面。]
    例如，由两种不同纱线组成的织物从远处看像一个表面，但由于纤维基微观几何的独特反射特性，其方向强度和颜色变化不能被任何标准BRDF模型很好地描述。
]

#parec[
  Instead of developing numerous additional specialized #link("../Reflection_Models/BSDF_Representation.html#BxDF")[BxDFs];, we will now pursue another way of reproducing such challenging materials in a renderer: by interpolating measurements of real-world material samples to create a #emph[data-driven] reflectance model. The resulting #link("<MeasuredBxDF>")[MeasuredBxDF] only models surface reflection, though the approach can in principle generalize to transmission as well.
][
  我们将不再开发众多额外的专用#link("../Reflection_Models/BSDF_Representation.html#BxDF")[BxDFs];，而是将追求另一种在渲染器中再现此类挑战性材料的方法：通过插值现实世界材料样本的测量值来创建一个数据驱动反射模型。生成的#link("<MeasuredBxDF>")[MeasuredBxDF];仅模拟表面反射，尽管该方法原则上也可以推广到透射。
]

=== MeasuredBxDF Definition
<measuredbxdf-definition>

```cpp
class MeasuredBxDF {
  public:
    <<MeasuredBxDF Public Methods>>       PBRT_CPU_GPU
       MeasuredBxDF(const MeasuredBxDFData *brdf, const SampledWavelengths &lambda)
           : brdf(brdf), lambda(lambda) {}
       static MeasuredBxDFData *BRDFDataFromFile(const std::string &filename,
                                                 Allocator alloc);
       PBRT_CPU_GPU
       SampledSpectrum f(Vector3f wo, Vector3f wi, TransportMode mode) const;
       PBRT_CPU_GPU
       pstd::optional<BSDFSample> Sample_f(Vector3f wo, Float uc, Point2f u,
                                           TransportMode mode,
                                           BxDFReflTransFlags sampleFlags) const;
       PBRT_CPU_GPU
       Float PDF(Vector3f wo, Vector3f wi, TransportMode mode,
                 BxDFReflTransFlags sampleFlags) const;
       PBRT_CPU_GPU
       void Regularize() {}
       PBRT_CPU_GPU
       static constexpr const char *Name() { return "MeasuredBxDF"; }
       std::string ToString() const;
       PBRT_CPU_GPU
       BxDFFlags Flags() const { return (BxDFFlags::Reflection | BxDFFlags::Glossy); }
  private:
    <<MeasuredBxDF Private Methods>>       static Float theta2u(Float theta) { return std::sqrt(theta * (2 / Pi)); }
       static Float phi2u(Float phi) { return phi * (1 / (2 * Pi)) + .5f; }
       static Float u2theta(Float u) { return Sqr(u) * (Pi / 2.f); }
       static Float u2phi(Float u) { return (2.f * u - 1.f) * Pi; }
    <<MeasuredBxDF Private Members>>       const MeasuredBxDFData *brdf;
       SampledWavelengths lambda;
};
```



#parec[
  Measuring reflection in a way that is practical while producing information in a form that is convenient for rendering is a challenging problem. We begin by explaining these challenges for motivation.
][
  以一种实用的方式测量反射，同时生成方便渲染的信息是一个具有挑战性的问题。我们首先解释这些挑战以激发动机。
]

#parec[
  Consider the task of measuring the BRDF of a sheet of brushed aluminum: we could illuminate a sample of the material from a set of $n$ incident directions $(theta_i^((k)) , phi.alt_i^((k)))$ with $k = 1 , dots.h , n$ and use some kind of sensor (e.g., a photodiode) to record the reflected light scattered along a set of $m$ outgoing directions $(theta_o^((l)) , phi.alt_o^((l)))$ with $l = 1 , dots.h , m$. These $n times m$ measurements could be stored on disk and interpolated at runtime to approximate the BRDF at intermediate configurations $(theta_i , phi.alt_i , theta_o , phi.alt_o)$. However, closer scrutiny of such an approach reveals several problems:
][
  考虑测量一张拉丝铝板的BRDF的任务：我们可以从一组 $n$ 个入射方向 $(theta_i^((k)) , phi.alt_i^((k)))$ （ $k = 1 , dots.h , n$ ）照亮材料的一个样本，并使用某种传感器（例如，光电二极管）记录沿一组 $m$ 个出射方向 $(theta_o^((l)) , phi.alt_o^((l)))$ （ $l = 1 , dots.h , m$ ）散射的反射光。这些 $n times m$ 次测量可以存储在磁盘上，并在运行时插值以近似中间配置 $(theta_i , phi.alt_i , theta_o , phi.alt_o)$ 处的BRDF。然而，仔细审视这种方法会发现几个问题：
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f33.svg"),
  caption: [
    #ez_caption[Figure 9.33: Specialized Hardware for BSDF Acquisition.][图9.33：用于BSDF采集的专用硬件。]

  ],
)


#parec[
  #emph[The term] #emph[goniophotometer] #emph[(or] #emph[gonioreflectometer];) refers to a typically motorized platform that can simultaneously illuminate and observe a material sample from arbitrary pairs of directions. The device on the left (at Cornell University, built by Cyberware Inc., image courtesy of Steve Marschner) rotates camera (2 degrees of freedom) and light arms (1 degree of freedom) around a centered sample pedestal that can also rotate about its vertical axis. The device on the right (at EPFL, built by pab advanced technologies Ltd) instead uses a static light source and a rotating sensor arm (2 degrees of freedom). The vertical material sample holder then provides 2 rotational degrees of freedom to cover the full 4D domain of the BSDF.
][
  #emph[术语] #emph[goniophotometer] #emph[(或] #emph[gonioreflectometer];) 指的是一种通常是电动的平台，可以从任意方向对材料样本进行照明和观察。左侧的设备（在康奈尔大学，由Cyberware Inc.制造，图片由Steve Marschner提供）旋转相机（2个自由度）和光臂（1个自由度），围绕一个可以绕其垂直轴旋转的中心样本台。右侧的设备（在EPFL，由pab advanced technologies Ltd制造）则使用静态光源和旋转传感器臂（2个自由度）。垂直材料样本支架然后提供2个旋转自由度，以覆盖BSDF的完整4D域。\*
]

#parec[
  - BSDFs of polished materials are highly directionally peaked.
    Perturbing the incident or outgoing direction by as little as 1 degree
    can change the measured reflectance by orders of magnitude. This
    implies that the set of incident and outgoing directions must be
    sampled fairly densely.
][
  - 抛光材料的BSDF具有高度方向性峰值。入射或出射方向稍微偏离1度就可以使测量的反射率发生数量级的变化。这意味着入射和出射方向的集合必须相当密集地采样。
]

#parec[
  - Accurate positioning in spherical coordinates is difficult to perform
    by hand and generally requires mechanical aids. For this reason, such
    measurements are normally performed using a motorized gantry known as
    a #emph[goniophotometer] or #emph[gonioreflectometer];. Figure 9.33
    shows two examples of such machines. #emph[Light stages] consisting of
    a rigid assembly of hundreds of LEDs around a sample are sometimes
    used to accelerate measurement, though at the cost of reduced
    directional resolution.
][
  - 在球坐标中准确定位手动操作很难，通常需要机械辅助。出于这个原因，这种测量通常使用一种称为#emph[goniophotometer];或#emph[gonioreflectometer];的电动龙门架进行。图9.33展示了这种机器的两个例子。#emph[光阶段];由数百个围绕样本的LED的刚性组件组成，有时用于加速测量，尽管以降低方向分辨率为代价。
]

#parec[
  - Sampling each direction using a 1 degree spacing in spherical
    coordinates requires roughly one billion sample points. Storing
    gigabytes of measurement data is possible but undesirable, yet the
    time that would be spent for a full measurement is even more
    problematic: assuming that the goniophotometer can reach a
    configuration $(theta_i , phi.alt_i , theta_o , phi.alt_o)$ within 1
    second (a reasonable estimate for the devices shown in Figure 9.33),
    over 34 years of sustained operation would be needed to measure a
    single material.
][
  - 在球坐标中以1度间隔采样每个方向大约需要十亿个样本点。存储千兆字节的测量数据是可能的，但不理想，然而，进行完整测量所需的时间更成问题：假设goniophotometer可以在1秒内达到配置$(theta_i , phi.alt_i , theta_o , phi.alt_o)$（对于图9.33中显示的设备是合理的估计），则需要超过34年的持续操作才能测量单一材料。
]

#parec[
  In sum, the combination of high-frequency signals, the 4D domain of the BRDF, and the curse of dimensionality conspire to make standard measurement approaches all but impractical.
][
  总之，高频信号、BRDF的4D域和维数诅咒的结合使得标准测量方法几乎不切实际。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f34.svg"),
  caption: [
    #ez_caption[
      Figure 9.34: Adaptive BRDF Sample Placement.
    ][
      图9.34：自适应BRDF样本布置。
    ]
  ],
)


#parec[
  #emph[\(a) Regular sampling of the incident and outgoing directions is a
    prohibitively expensive way of measuring and storing BRDFs due to the
    curse of dimensionality (here, only 2 of the 4 dimensions are shown).
    (b) A smaller number of samples can yield a more accurate interpolant if
    their placement is informed by the material's reflectance behavior.]
][
  #emph[\(a)
    由于维数诅咒，常规采样入射和出射方向是一种极其昂贵的测量和存储BRDF的方法（这里只显示了4个维度中的2个）。(b)
    如果样本的放置受到材料反射行为的影响，较少的样本可以产生更准确的插值。]
]

#parec[
  While there is no general antidote against the curse of dimensionality, the previous example involving a dense discretization of the 4D domain is clearly excessive. For example, peaked BSDFs that concentrate most of their energy into a small set of angles tend to be relatively smooth away from the peak. Figure 9.34 shows how a more specialized sample placement that is informed by the principles of specular reflection can drastically reduce the number of sample points that are needed to obtain a desired level of accuracy.
][
  虽然没有通用的解药来对抗维数诅咒，但前面的例子中涉及4D域的密集离散化显然是过度的。例如，集中大部分能量在一小组角度的峰值BSDF在远离峰值的地方往往相对平滑。图9.34展示了如何通过基于镜面反射原理的更专业的样本放置可以显著减少获得所需精度所需的样本点数量。
]

#parec[
  Figure 9.35 shows how the roughness of the surface affects the desired distribution of samples—for example, smooth surfaces allow sparse sampling outside of the specular lobe.
][
  图9.35展示了表面粗糙度如何影响样本的期望分布——例如，光滑表面允许在镜面反射区之外进行稀疏采样。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f35.svg"),
  caption: [
    #ez_caption[
      Figure 9.35: The Effect of Surface Roughness on Adaptive BRDF Sample Placement.
    ][
      图9.35：表面粗糙度对自适应BRDF样本布置的影响。
    ]
  ],
)

#parec[
  #emph[The two plots visualize BRDF values of two materials with
    different roughnesses for varying directions $omega_i$ and fixed
    $omega_o$. Circles indicate adaptively chosen measurement locations,
    which are used to create the interpolant implemented in the
    `MeasuredBxDF` class. (a) The measurement locations broadly cover the
    hemisphere given a relatively rough material. (b) For a more specular
    material the samples are concentrated in the region around the specular
    peak. Changing the outgoing direction moves the specular peak; hence the
    sample locations must depend on $omega_o$.
  ]
][
  #emph[两个图显示了两个不同粗糙度材料的BRDF值，方向$omega_i$变化，$omega_o$固定。圆圈表示自适应选择的测量位置，用于创建`MeasuredBxDF`类中实现的插值。(a)
    给定相对粗糙的材料，测量位置大致覆盖半球。(b)
    对于更具镜面反射的材料，样本集中在镜面峰值周围的区域。改变出射方向会移动镜面峰值；因此，样本位置必须依赖于$omega_o$。]
]

#parec[
  The `MeasuredBxDF` therefore builds on microfacet theory and the distribution of visible normals to create a more efficient physically informed sampling pattern. The rationale underlying this choice is that while microfacet theory may not perfectly predict the reflectance of a specific material, it can at least approximately represent how energy is (re-)distributed throughout the 4D domain.
][
  因此，`MeasuredBxDF`基于微面理论和可见法线的分布创建了一个更有效的物理信息采样模式。选择这一方法的基本原理是，虽然微面理论可能无法完美预测特定材料的反射，但至少可以近似表示能量在4D域中的（重新）分布。
]

#parec[
  Applying it enables the use of a relatively coarse set of measurement locations that suffice to capture the function's behavior. Concretely, the method works by transforming regular grid points using visible normal sampling (Section 9.6.4) and performing a measurement at each sampled position.
][
  应用它可以使用相对粗略的测量位置集来捕捉函数的行为。具体来说，该方法通过使用可见法线采样（第9.6.4节）变换常规网格点，并在每个采样位置进行测量来工作。
]

#parec[
  If the microfacet sampling routine is given by a function $R : S^2 times [0 , 1]^2 arrow.r S^2$ and $u^((k))$ with $k = 1 , dots.h , n$ denotes input samples arranged on a grid covering the 2D unit square, then we have a sequence of measurements $M^((k))$ :
][
  如果微面采样例程由函数 $R : S^2 times [0 , 1]^2 arrow.r S^2$ 给出，并且 $u^((k))$ （ $k = 1 , dots.h , n$ ）表示覆盖2D单位正方形的网格上的输入样本，那么我们有一系列测量 $M^((k))$ ：
]


$ M^((k)) = f_r (omega_o , R (omega_o , u^((k)))) , $


#parec[
  where $f_r (omega_o , omega_i^((k)))$ refers to the real-world BRDF of a material sample, as measured by a goniophotometer (or similar device) in directions $omega_o$ and $omega_i^((k)) = R (omega_o , u^((k)))$. This process must be repeated for different values of $omega_o$ to also capture variation in the other direction argument. Evaluating the BRDF requires the inverse $R^(- 1)$ of the transformation, which yields a position on $[0 , 1]^2$ that can be used to interpolate the measurements $M^((k))$. Figure 9.36 illustrates both directions of this mapping.
][
  其中 $f_r (omega_o , omega_i^((k)))$ 指的是材料样本的真实世界BRDF，通过一个测角光度计（或类似设备）在方向 $omega_o$ 和 $omega_i^((k)) = R (omega_o , u^((k)))$ 测量得到。这个过程必须对不同的 $omega_o$ 值重复，以捕捉另一个方向参数的变化。评估BRDF需要转换的逆 $R^(- 1)$，这会产生一个在 $[0 , 1]^2$ 上的位置，可以用来插值测量值 $M^((k))$。图 9.36 展示了这种映射的两个方向。
]

#parec[
  This procedure raises several questions: first, the non-random use of a method designed for Monte Carlo sampling may be unexpected. To see why this works, remember that the inversion method (Section 2.3) evaluates the inverse of a distribution's cumulative distribution function (CDF). Besides being convenient for sampling, this inverse CDF can also be interpreted as a parameterization of the target domain from the unit square. This parameterization smoothly warps the domain so that regions with a high contribution occupy a correspondingly large amount of the unit square. The MeasuredBxDF then simply measures and stores BRDF values in these "improved" coordinates. Note that the material does not have to agree with microfacet theory for this warping to be valid, though the sampling pattern is much less efficient and requires a denser discretization when the material's behavior deviates significantly.
][
  这个过程引发了几个问题：首先，非随机使用为蒙特卡罗采样设计的方法可能出乎意料。要理解为什么这行得通，请记住反转方法（第 2.3 节）评估分布的累积分布函数（CDF）的逆。除了便于采样，这个逆CDF还可以被解释为从单位正方形到目标域的参数化。这种参数化平滑地变形域，使得高贡献区域在单位正方形中占据相应较大的部分。然后，MeasuredBxDF 简单地在这些“改进”的坐标中测量和存储BRDF值。注意，即使材料不符合微表面理论，这种变形也是有效的，尽管当材料的行为显著偏离时，采样模式效率低下且需要更密集的离散化。
]

#parec[
  Another challenge is that parameterization guiding the measurement requires a microfacet approximation of the material, but such an approximation would normally be derived from an existing measurement. We will shortly show how to resolve this chicken-and-egg problem and assume for now that a suitable model is available.
][
  另一个挑战是指导测量的参数化需要材料的微表面近似，但这种近似通常是从现有测量中得出的。我们将很快展示如何解决这个先有鸡还是先有蛋的问题，并暂时假设有一个合适的模型可用。
]

#parec[
  A flaw of the reparameterized measurement sequence in Equation (9.41) is that the values $M^((k))$ may differ by many orders of magnitude, which means that simple linear interpolation between neighboring data points is unlikely to give satisfactory results. We instead use the following representation that transforms measurements prior to storage in an effort to reduce this variation:
][
  在方程 (9.41) 中重新参数化的测量序列的一个缺陷是值 $M^((k))$ 可能相差几个数量级，这意味着简单的线性插值邻近数据点可能无法给出令人满意的结果。我们改用以下表示，在存储前转换测量值以减少这种变化：
]

$ M^((k)) = frac(f_r (omega_o , omega_i^((k))) cos theta_i^((k)), p (omega_i^((k)))) , $

#parec[
  where $omega_i^((k)) = R (omega_o , u^((k)))$, and $p (omega_i^((k)))$ denotes the density of direction $omega_i^((k))$ according to visible normal sampling.
][
  其中 $omega_i^((k)) = R (omega_o , u^((k)))$， $p (omega_i^((k)))$ 表示根据可见法线采样的方向 $omega_i^((k))$ 的密度。
]

#parec[
  If $f_r$ was an analytic BRDF (e.g., a microfacet model) and $u^((k))$ a 2D uniform variate, then Equation (9.42) would simply be the weight of a Monte Carlo importance sampling strategy, typically with a carefully designed mapping $R$ and density $p$ that make this weight near-constant to reduce variance.
][
  如果 $f_r$ 是一个解析BRDF（例如，微表面模型）且 $u^((k))$ 是一个二维均匀变量，那么方程 (9.42) 将仅仅是蒙特卡罗重要性采样策略的权重，通常具有精心设计的映射 $R$ 和密度 $p$，使得这个权重接近常数以减少方差。
]

#parec[
  In the present context, $f_r$ represents real-world data, while $p$ and $R$ encapsulate a microfacet approximation of the material under consideration. We therefore expect $M^((k))$ to take on near-constant values when the material is well-described by a microfacet model, and more marked deviations otherwise. This can roughly be interpreted as measuring the difference (in a multiplicative sense) between the real world and the microfacet simplification. Figure 9.37 visualizes the effect of the transformation in Equation (9.42).
][
  在当前背景下， $f_r$ 代表真实世界数据，而 $p$ 和 $R$ 包含了所考虑材料的微表面近似。因此，当材料被微表面模型很好地描述时，我们期望 $M^((k))$ 取接近常数的值，否则会有更显著的偏差。这可以粗略地理解为测量真实世界与微表面简化之间的差异（以乘法的方式）。图 9.37 直观展示了方程 (9.42) 中转换的效果。
]

#parec[
  This figure illustrates the representation of two material samples: a metallic sample swatch from the L3-37 robot in the film Solo: A Star Wars Story (Walt Disney Studios Motion Pictures) and a pearlescent vehicle vinyl wrap (TeckWrap International Inc.). Each column represents a measurement of a separate outgoing direction $omega_o$. For both materials, the first row visualizes the measured directions $omega_i^((k))$. The subsequent row plots the "raw" reparameterized BRDF of Equation (9.41), where each pixel represents one of the grid points $u^((k)) in [0 , 1]^2$ identified with $omega_i^((k))$. The final row shows transformed measurements corresponding to Equation (9.42) that are more uniform and easier to interpolate. Note that these samples are both isotropic, which is why a few measurements for different elevation angles suffice. In the anisotropic case, the $(theta_o , phi.alt_o)$ domain must be covered more densely.
][
  此图展示了两个材料样本的表示：电影《游侠索罗：星球大战外传》（华特迪士尼影业）中的L3-37机器人金属样本和珍珠光泽车辆乙烯基包裹（TeckWrap国际公司）。每一列代表一个单独的出射方向 $omega_o$ 的测量。对于这两种材料，第一行可视化了测量的方向 $omega_i^((k))$。后续行绘制了方程 (9.41) 的“原始”重新参数化BRDF，其中每个像素代表一个网格点 $u^((k)) in [0 , 1]^2$ 与 $omega_i^((k))$ 相关联。最后一行显示了方程 (9.42) 对应的转换测量值，这些值更均匀且更易于插值。注意，这些样本都是各向同性的，这就是为什么不同仰角的少量测量就足够了。在各向异性情况下， $(theta_o , phi.alt_o)$ 范围需要更密集的覆盖。
]


#parec[
  Evaluating the data-driven BRDF requires the inverse of these steps. Suppose that $cal(M) (dot.op)$ implements an interpolation based on the grid of measurement points $cal(M)^((k))$. Furthermore, suppose that we have access to the inverse $upright(bold(R))^(- 1) (omega_o , omega_i)$ that returns the "random numbers" $u$ that would cause visible normal sampling to generate a particular incident direction (i.e., $upright(bold(R)) (omega_o , u) = omega_i$ ). Accessing $cal(M) (dot.op)$ through $upright(bold(R))^(- 1)$ then provides a spherical interpolation of the measurement data.
][
  评估数据驱动的双向反射分布函数 (BRDF) 需要这些步骤的逆运算。假设 $cal(M) (dot.op)$ 实现了基于测量点网格 $cal(M)^((k))$ 的插值法。此外，假设我们可以访问逆函数 $upright(bold(R))^(- 1) (omega_o , omega_i)$，它返回“随机数” $u$，这些随机数会导致可见法线采样生成特定的入射方向（即， $upright(bold(R)) (omega_o , u) = omega_i$ ）。通过 $upright(bold(R))^(- 1)$ 访问 $cal(M) (dot.op)$ 然后提供测量数据的球面插值法。
]

#parec[
  We must additionally multiply by the density $p (omega_i)$, and divide by the cosine factor\[^1\] to undo corresponding transformations introduced in Equation (9.42), which yields the final form of the data-driven BRDF:
][
  我们还必须乘以密度 $p (omega_i)$，并除以余弦因子（余弦项）\[^1\]，以撤销方程 (9.42) 中引入的相应变换，从而得到数据驱动 BRDF 的最终形式：
]

$
  f_r (omega_o , omega_i) = frac(cal(M) (upright(bold(R))^(- 1) (omega_o , omega_i)) thin p (omega_i), cos theta_i) .
$



#parec[
  A major difference between the microfacet model underlying the #link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[ConductorBxDF] and the approximation used here is that we replace the Trowbridge–Reitz model with an arbitrary data-driven microfacet distribution. This improves the model's ability to approximate the material being measured. At the same time, it implies that previously used simplifications and analytic solutions are no longer available and must be revisited.
][
  #link("../Reflection_Models/Conductor_BRDF.html#ConductorBxDF")[ConductorBxDF] 所基于的微面模型与此处使用的近似之间的主要区别在于，我们用任意数据驱动的微面分布函数替换了 Trowbridge–Reitz 模型。这提高了模型对被测材料的近似能力。同时，这意味着以前使用的简化和解析解不再可用，必须重新审视。
]

#parec[
  We begin with the Torrance–Sparrow sampling density from Equation (9.28),
][
  我们从方程 (9.28) 的 Torrance–Sparrow 采样密度开始，
]

$ p (omega_i) = frac(D_(omega_o) (omega_m), 4 thin (omega_o dot.op omega_m)) . $


#parec[
  which references the visible normal sampling density $D_(omega_o) (omega_m)$ from Equation (9.23). Substituting the definition of the masking function from Equation (9.18) into $D_(omega_o) (omega_m)$ and rearranging terms yields
][
  这引用了方程 (9.23) 中的可见法线采样密度 $D_(omega_o) (omega_m)$。将方程 (9.18) 中遮蔽函数的定义代入 $D_(omega_o) (omega_m)$ 并重新排列项得到
]

$ D_(omega_o) (omega_m) = frac(1, sigma (omega_o)) D (omega_m) max (0 , omega_o dot.op omega_m) , $



#parec[
  where
][
  其中
]

$
  sigma (omega_o) = integral_(cal(H)^2 (upright(bold(n)))) D (omega) max ( 0 , omega_o dot.op omega ) thin upright(d) omega
$



#parec[
  provides a direction-dependent normalization of the visible normal distribution.
][
  提供了方向依赖的可见法线分布归一化。
]

#parec[
  For valid reflection directions ( $omega_o dot.op omega_m > 0$ ), the PDF of generated samples then simplifies to
][
  对于有效的反射方向条件（ $omega_o dot.op omega_m > 0$ ），生成样本的概率密度函数（PDF）简化为
]

$ p (omega_i) = frac(D (omega_m), 4 sigma (omega_o)) . $


#parec[
  Substituting this density into the BRDF from Equation (9.43) produces
][
  将此密度代入方程 (9.43) 的 BRDF 得到
]

$
  f_r ( omega_o , omega_i ) = frac(cal(M) (upright(bold(R))^(- 1) (omega_o , omega_i)) D (omega_m), 4 sigma (omega_o) cos theta_i) .
$



#parec[
  The `MeasuredBxDF` implements this expression using data-driven representations of $D (dot.op)$ and $sigma (dot.op)$.
][
  `MeasuredBxDF` 使用数据驱动的表示来实现这个表达式。
]

=== Finding the Initial Microfacet Model
<finding-the-initial-microfacet-model>


#parec[
  We finally revisit the chicken-and-egg problem from before: practical measurement using the presented approach requires a suitable microfacet model—specifically, a microfacet distribution $D (omega_m)$. Yet it remains unclear how this distribution could be obtained without access to an already existing BRDF measurement.
][
  我们终于回到之前的先有鸡还是先有蛋的问题：使用所述方法进行实际测量需要一个合适的微表面模型——具体来说，一个微表面分布 $D (omega_m)$。然而，如何在没有现有 BRDF 测量的情况下获得这种分布仍不清楚。
]

#parec[
  The key idea to resolve this conundrum is that the microfacet distribution $D (omega_m)$ is a 2D quantity, which means that it remains mostly unaffected by the curse of dimensionality. Acquiring this function is therefore substantially cheaper than a measurement of the full 4D BRDF.
][
  解决这个难题的关键思想是微表面分布 $D (omega_m)$ 是一个二维量，这意味着它基本上不受维度诅咒的影响。因此，获取这个函数比测量完整的四维 BRDF 成本要低得多。
]

#parec[
  Suppose that the material being measured perfectly matches microfacet theory in the sense that it is described by the Torrance–Sparrow BRDF from Equation (9.33). Then we can measure the material's retroreflection (i.e., $omega_i = omega_o = omega$ ), which is given by
][
  假设被测量的材料完全符合微表面理论，即由方程 (9.33) 中的 Torrance–Sparrow BRDF 描述。然后我们可以测量材料的回射（即 $omega_i = omega_o = omega$ ），其公式为：
]

$
  f_r ( p , omega , omega ) = frac(D (omega) F (omega dot.op omega), 4 cos^2 theta) prop frac(D (omega) G_1 (omega), cos^2 theta) .
$


#parec[
  The last step of the above equation removes constant terms including the Fresnel reflectance and introduces the reasonable assumption that shadowing/masking is perfectly correlated given $omega_i = omega_o$ and thus occurs only once. Substituting the definition of $G_1$ from Equation (9.18) and rearranging yields the following relationship of proportionality:
][
  上面方程的最后一步去掉了包括菲涅耳反射在内的常数项，并引入了一个合理的假设，即在给定 $omega_i = omega_o$ 的情况下，遮挡/掩蔽是完全相关的，因此只发生一次。代入方程 (9.18) 中 $G_1$ 的定义并重新排列，得到以下比例关系：
]

$
  D (omega) prop f_r (p , omega , omega) cos theta integral_H^2 (n) D (omega_m) max ( 0 , omega dot.op omega_m ) d omega_m .
$


#parec[
  This integral equation can be solved by measuring $f_r (p , omega_j , omega_j)$ for $n$ directions $omega_j$ and using those measurements for initial guesses of $D (omega_j)$. A more accurate estimate of $D$ can then be found using an iterative solution procedure where the estimated values of $D$ are used to estimate the integrals on the right-hand side of Equation (9.46) for all of the $omega_j$ s. This process quickly converges within a few iterations.
][
  通过测量 $f_r (p , omega_j , omega_j)$ 对于 $n$ 个方向 $omega_j$，并使用这些测量值作为 $D (omega_j)$ 的初始猜测，可以求解这个积分方程。然后可以使用迭代求解程序找到 $D$ 的更准确估计，其中估计的 $D$ 值用于估计方程 (9.46) 右侧的积分，适用于所有 $omega_j$。这个过程在经过几次迭代后迅速收敛。
]

=== 9.8.1 Basic Data Structures
<basic-data-structures>


#parec[
  `MeasuredBxDFData` holds data pertaining to reflectance measurements and the underlying parameterization. Because the data for an isotropic BRDF is typically a few megabytes and the data for an anisotropic BRDF may be over 100, each measured BRDF that is used in the scene is stored in memory only once. As instances of `MeasuredBxDF` are created at surface intersections during rendering, they can then store just a pointer to the appropriate `MeasuredBxDFData`. Code not included here adds the ability to initialize instances of this type from binary `.bsdf` files containing existing measurements.
][
  `MeasuredBxDFData` 保存与反射率测量和基础参数化相关的数据。由于各向同性 BRDF 的数据通常为几兆字节，而各向异性 BRDF 的数据可能超过 100 兆字节，因此场景中使用的每个测量 BRDF 在内存中只存储一次。当在渲染期间在表面交点处创建 `MeasuredBxDF` 实例时，它们可以仅存储指向适当的 `MeasuredBxDFData` 的指针。这里未包含的代码增加了从包含现有测量的二进制 `.bsdf` 文件初始化此类型实例的功能。
]

#parec[
  Measured BRDFs are represented by spectral measurements at a set of discrete wavelengths that are stored in `wavelengths`. The actual measurements are stored in `spectra`.
][
  测量的 BRDF 通过一组离散波长的光谱测量来表示，这些波长存储在 `wavelengths` 中。实际测量值存储在 `spectra` 中。
]

#parec[
  The template class `PiecewiseLinear2D` represents a piecewise-linear interpolant on the 2D unit square with samples arranged on a regular grid. The details of its implementation are relatively technical and reminiscent of other interpolants in this book; hence we only provide an overview of its capabilities and do not include its full implementation here.
][
  模板类 `PiecewiseLinear2D` 表示在二维单位正方形上的分段线性插值，其样本排列在规则网格上。其实现的细节相对技术性，并让人联想到本书中的其他插值器；因此我们仅提供其功能的概述，而不包括其完整实现。
]

#parec[
  The class is parameterized by a `Dimension` template parameter that extends the 2D interpolant to higher dimensions—for example, `PiecewiseLinear2D<1>` stores a 3D grid of values, and `PiecewiseLinear2D<3>` used above for `spectra` is a 5D quantity. The class provides three key methods:
][
  该类通过 `Dimension` 模板参数进行参数化，该参数将二维插值扩展到更高维度——例如，`PiecewiseLinear2D<1>` 存储一个三维值网格，而上面用于 `spectra` 的 `PiecewiseLinear2D<3>` 是一个五维量。该类提供三个关键方法：
]

```cpp
template <size_t Dimension>
class PiecewiseLinear2D {
public:
    Float Evaluate(Point2f pos, Float... params);
    PLSample Sample(Point2f u, Float... params);
    PLSample Invert(Point2f p, Float... params);
};
```


#parec[
  where `PLSample` is defined as
][
  其中 `PLSample` 定义为
]

```cpp
struct PLSample { Point2f p; Float pdf; };
```


#parec[
  `Evaluate()` takes a position $p o s in [0 , 1]^2$ and then additional `Float` parameters to perform a lookup using multidimensional linear interpolation according to the value of `Dimension`.
][
  `Evaluate()` 接受一个位置 $p o s in [0 , 1]^2$，然后使用多维线性插值根据 `Dimension` 的值进行查找。
]

#parec[
  `Sample()` warps $u in [0 , 1]^2$ via inverse transform sampling (i.e., proportional to the stored linear interpolant), returning both the sampled position on $[0 , 1]^2$ and the associated density as a `PLSample`. The additional parameters passed via `params` are used as conditional variables that restrict sampling to a 2D slice of a higher-dimensional function. For example, invoking the method `PiecewiseLinear2D<3>::Sample()` with a uniform 2D variate and parameters $0.1$, $0.2$, and $0.3$ would importance sample the 2D slice $I (0.1 , 0.2 , 0.3 , dots.h)$ of a pentalinear interpolant $I$.
][
  `Sample()` 通过逆变换采样对 $u in [0 , 1]^2$ 进行变换（即，与存储的线性插值成比例），返回在 $[0 , 1]^2$ 上采样的位置和相关密度作为 `PLSample`。通过 `params` 传递的附加参数用作条件变量，将采样限制在高维函数的二维切片上。例如，使用均匀二维变量和参数 $0.1$ 、 $0.2$ 和 $0.3$ 调用方法 `PiecewiseLinear2D<3>::Sample()` 将对五线性插值 $I$ 的二维切片 $I (0.1 , 0.2 , 0.3 , dots.h)$ 进行重要性采样。
]

#parec[
  Finally, `Invert()` implements the exact inverse of `Sample()`. Invoking it with the position computed by `Sample()` will recover the input $u$ value up to rounding error.
][
  最后，`Invert()` 实现了 `Sample()` 的精确逆变换。用 `Sample()` 计算的位置调用它将恢复输入 $u$ 值，误差不超过舍入误差。
]

#parec[
  Additional `PiecewiseLinear1D` instances are used to (redundantly) store the normal distribution $D (omega_m)$ in `ndf`, the visible normal distribution $D_(omega_o) (omega_m)$ parameterized by $omega_o = (theta_o , phi.alt_o)$ in `vndf`, and the normalization constant $sigma (omega_o)$ in `sigma`. The data structure also records whether the material is isotropic, in which case the dimensionality of some of the piecewise-linear interpolants can be reduced.
][
  额外的 `PiecewiseLinear1D` 实例用于（冗余地）存储在 `ndf` 中的法线分布 $D (omega_m)$，在 `vndf` 中由 $omega_o = (theta_o , phi.alt_o)$ 参数化的可见法线分布 $D_(omega_o) (omega_m)$，以及在 `sigma` 中的归一化常数 $sigma (omega_o)$。数据结构还记录材料是否是各向同性的，在这种情况下，某些分段线性插值的维度可以减少。
]


#parec[
  Following these preliminaries, we can now turn to evaluating the measured BRDF for a pair of directions. See Figure 9.38 for examples of the variety of types of reflection that the measured representation can reproduce.
][
  完成这些准备工作后，我们可以开始评估一对方向的测量 BRDF。请参见图 9.38，了解测量表示可以再现的各种反射类型的示例。
]

#parec[
  The only information that must be stored as `MeasuredBxDF` member variables in order to implement the `BxDF` interface methods is a pointer to the BRDF measurement data and the set of wavelengths at which the BRDF is to be evaluated.
][
  为了实现 `BxDF` 接口方法，必须作为 `MeasuredBxDF` 成员变量存储的唯一信息是指向 BRDF 测量数据的指针和要评估 BRDF 的波长集。
]

#parec[
  BRDF evaluation then follows the approach described in Equation (9.45).
][
  然后，BRDF 评估遵循方程 (9.45) 中描述的方法。
]

#parec[
  Zero reflection is returned if the specified directions correspond to transmission through the surface. Otherwise, the directions \$ \_n^{i}\$ and \$ \_n^{o}\$ are mirrored onto the positive hemisphere if necessary.
][
  如果指定的方向对应于通过表面的透射，则返回零反射。否则，如果需要，方向 \$ \_n^{i}\$ 和 \$ \_n^{o}\$ 将镜像到正半球上。
]

#parec[
  The next code fragment determines the associated microfacet normal and handles an edge case that occurs in near-grazing configurations.
][
  下一个代码片段确定相关的微表面法线，并处理在接近掠射配置中发生的边缘情况。
]

#parec[
  A later step requires that \$ \_n^{o}\$ and \$ \_n^{m}\$ are mapped onto the unit square $[0 , 1]^2$, which we do in two steps: first, by converting the directions to spherical coordinates, which are then further transformed by helper methods `theta2u()` and `phi2u()`.
][
  后续步骤要求将 \$ \_n^{o}\$ 和 \$ \_n^{m}\$ 映射到单位方块 $[0 , 1]^2$，我们通过两个步骤实现：首先，将方向转换为球坐标，然后通过辅助方法 `theta2u()` 和 `phi2u()` 进一步转换。
]

#parec[
  In the isotropic case, the mapping used for \$ \_n^{m}\$ subtracts \$ \_n^{o}\$ from \$ \_n^{m}\$, which allows the stored tables to be invariant to rotation about the surface normal.
][
  在各向同性情况下，用于 \$ \_n^{m}\$ 的映射减去 \$ \_n^{o}\$ 从 \$ \_n^{m}\$，这使得存储的表格对绕表面法线的旋转不变。
]

#parec[
  This may cause the second dimension of `u_wm` to fall out of the $[0 , 1]$ interval; a subsequent correction fixes this using the periodicity of the azimuth parameter.
][
  这可能导致 `u_wm` 的第二维度超出 $[0 , 1]$ 区间；后续的修正使用方位参数的周期性来解决这个问题。
]

#parec[
  The two helper functions encapsulate an implementation detail of the storage representation.
][
  这两个辅助函数封装了存储表示的实现细节。
]

#parec[
  With this information at hand, we can now evaluate the inverse parameterization to determine the sample values `ui.p` that would cause visible normal sampling to generate the current incident direction (i.e., $R (omega_n^o , u) = omega_n^i$ ).
][
  有了这些信息，我们现在可以评估逆参数化，以确定样本值 `ui.p`，这些值将导致可见法线采样生成当前入射方向（即 $R (omega_n^o , u) = omega_n^i$ ）。
]

#parec[
  This position is then used to evaluate a 5D linear interpolant parameterized by the fractional 2D position $u_i in [0 , 1]^2$ on the reparameterized incident hemisphere, \$ \_n^{o}\$, \$ \_n^{o}\$, and the wavelength in nanometers.
][
  然后使用此位置评估一个 5D 线性插值，该插值由重新参数化的入射半球上的分数 2D 位置 $u_i in [0 , 1]^2$ 、\$ \_n^{o} $、$ \_n^{o}\$ 和波长（以纳米为单位）参数化。
]

#parec[
  Finally, `fr` must be scaled to undo the transformations that were applied to the data to improve the quality of the interpolation and to reduce the required measurement density, giving the computation that corresponds to Equation (9.45).
][
  最后，`fr` 必须缩放以撤销应用于数据的变换，以提高插值质量并减少所需的测量密度，从而进行与方程 (9.45) 对应的计算。
]

#parec[
  In principle, implementing the `Sample_f()` and `PDF()` methods required by the `BxDF` interface is straightforward: the `Sample_f()` method could evaluate the forward mapping $R$ to perform visible normal sampling based on the measured microfacet distribution using `PiecewiseLinear2D::Sample()`, and `PDF()` could evaluate the associated sampling density from Equation (9.44).
][
  原则上，实现 `BxDF` 接口所需的 `Sample_f()` 和 `PDF()` 方法是直接的：`Sample_f()` 方法可以评估前向映射 $R$，以根据测量的微表面分布使用 `PiecewiseLinear2D::Sample()` 执行可见法线采样，而 `PDF()` 可以评估方程 (9.44) 中的相关采样密度。
]

#parec[
  However, a flaw of such a basic sampling scheme is that the transformed BRDF measurements from Equation (9.42) are generally nonuniform on $[0 , 1]^2$, which can inject unwanted variance into the rendering process.
][
  然而，这种基本采样方案的一个缺陷是，方程 (9.42) 中的变换 BRDF 测量通常在 $[0 , 1]^2$ 上不均匀，这可能会在渲染过程中引入不必要的方差。
]

#parec[
  The implementation therefore uses yet another reparameterization based on a luminance tensor that stores the product integral of the spectral dimension of `MeasuredBxDFData::spectra` and the CIE Y color matching curve.
][
  因此，实现使用基于亮度张量的另一种重新参数化，该张量存储 `MeasuredBxDFData::spectra` 的光谱维度和 CIE Y 色度匹配曲线的乘积积分。
]

#parec[
  The actual BRDF sampling routine then consists of two steps.
][
  实际的 BRDF 采样过程包括两个步骤。
]

#parec[
  First it converts a uniformly distributed sample on $[0 , 1]^2$ into another sample $u in [0 , 1]^2$ that is distributed according to the luminance of the reparameterized BRDF.
][
  首先，它将 $[0 , 1]^2$ 上均匀分布的样本转换为根据重新参数化 BRDF 的亮度分布的另一个样本 $u in [0 , 1]^2$。
]

#parec[
  Following this, visible normal sampling transforms $u$ into a sampled direction $omega_n^i$ and a sampling weight that will have near-constant luminance.
][
  随后，可见法线采样将 $u$ 转换为采样方向 $omega_n^i$ 和一个具有接近恒定亮度的采样权重。
]

#parec[
  Apart from this step, the implementations of `Sample_f()` and `PDF()` are similar to the evaluation method and therefore not included here.
][
  除了这一步之外，`Sample_f()` 和 `PDF()` 的实现与评估方法相似，因此不在此处包含。
]


