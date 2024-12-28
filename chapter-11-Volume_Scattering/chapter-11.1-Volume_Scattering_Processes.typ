#import "../template.typ": parec, ez_caption

== Volume Scattering Processes
<volume-scattering-processes>

#parec[
  There are three main physical processes that affect the distribution of radiance in an environment with participating media:
][
  在有参与性介质的环境中，有三个主要的物理过程影响辐射度的分布：
]

#parec[
  - #emph[Absorption];: the reduction in radiance due to the conversion of light to another form of energy, such as heat.
][
  - #emph[吸收];：由于光被转换为其他形式的能量（如热能）导致辐射度减少。
]

#parec[
  - #emph[Emission];: radiance that is added to the environment from luminous particles.
][
  - #emph[发射];：由发光粒子添加到环境中的辐射度。
]

#parec[
  - #emph[Scattering];: radiance heading in one direction that is scattered to other directions due to collisions with particles.
][
  - #emph[散射];：由于与粒子的碰撞，朝一个方向的辐射度被散射到其他方向。
]

#parec[
  The characteristics of all of these properties may be #emph[homogeneous] or #emph[inhomogeneous];. Homogeneous properties are constant throughout some region of space, while inhomogeneous properties vary throughout space. @fig:spotfog shows a simple example of volume scattering, where a spotlight shining through a homogeneous participating medium illuminates particles in the medium and casts a volumetric shadow.
][
  这些特性的特征可以是#emph[均匀的];或#emph[非均匀的];。均匀特性在某个空间区域内是恒定的，而非均匀特性在整个空间中变化。 @fig:spotfog 展示了体积散射的一个简单例子，其中聚光灯通过均匀的参与性介质照亮介质中的粒子并投射出体积阴影。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/spotfog-dragon.png"),
  caption: [
    #ez_caption[
      Dragon Illuminated by a Spotlight through Fog. Light
      scattering from particles in the medium back toward the camera makes
      the spotlight’s illumination visible even in pixels where there are
      no visible surfaces that reflect it. The dragon blocks light,
      casting a volumetric shadow on the right side of the image. (Dragon
      model courtesy of the Stanford Computer Graphics Laboratory.)
    ][
      聚光灯通过雾照亮的龙。介质中粒子向摄像机方向的光散射使得即使在没有可见表面反射光的像素中，聚光灯的照明也可见。龙阻挡了光，在图像的右侧投射出体积阴影。（龙模型由斯坦福计算机图形实验室提供。）
    ]
  ],
)<spotfog>

#parec[
  All of these processes may have different behavior at different wavelengths of light. While wavelength-dependent emission can be handled in the same way that it is from surface emitters, wavelength-dependent absorption and scattering require special handling in Monte Carlo estimators. We will gloss past those details in this chapter, deferring discussion of them until @improving-the-sampling-techniques.
][
  所有这些过程在不同波长的光下可能表现出不同的行为。 虽然波长依赖的发射可以像表面发射体那样处理，但波长依赖的吸收和散射在蒙特卡罗估计中需要特殊处理。 我们将在本章中略去这些细节，推迟到@improving-the-sampling-techniques 讨论。
]

#parec[
  Physically, these processes all happen discretely: a photon is absorbed by some particle or it is not. We will nevertheless model all of these as continuous processes, following the same assumptions as underlie our use of radiometry to model light in `pbrt` (@Radiometry). However, as we apply Monte Carlo to solve the integrals that describe this process, we will end up considering the effect of these processes at particular points in the scene, which we will term #emph[scattering
events];. Note that "scattering events" is a slight misnomer, since absorption is a possibility as well as scattering.
][
  从物理上讲，这些过程都是离散发生的：一个光子要么被某个粒子吸收，要么没有被吸收。 尽管如此，我们将所有这些过程建模为连续过程，遵循与我们在`pbrt`中使用辐射度学来建模光的假设相同的假设（@Radiometry）。 然而，当我们应用蒙特卡罗方法来解决描述这个过程的积分时，我们最终会考虑这些过程在场景中特定点的影响，我们将其称为#emph[散射事件];。 注意，"散射事件"是一个轻微的误称，因为吸收也是一种可能性。
]

#parec[
  All the models in this chapter are based on the assumption that the positions of the particles are uncorrelated—in other words, that although their density may vary spatially, their positions are otherwise independent. (In the context of the colors of noise introduced in @spectral-analysis-of-sampling-patterns , the assumption is a white noise distribution of their positions.) This assumption does not hold for many types of physical media; for example, it is not possible for two particles to both be in the same point in space and so a true white noise distribution is not possible. See the "Further Reading" section at the end of the chapter for pointers to recent work in relaxing this assumption.
][
  本章中的所有模型都基于粒子位置不相关的假设——换句话说，尽管它们的密度可能在空间上变化，但它们的位置是独立的。 （在@spectral-analysis-of-sampling-patterns 中引入的噪声颜色的背景下，这个假设是它们位置的白噪声分布。） 这个假设对许多类型的物理介质并不成立；例如，不可能两个粒子都在空间中的同一点，因此真正的白噪声分布是不可能的。 请参阅本章末尾的“进一步阅读”部分，了解放宽此假设的最新研究。
]

=== Absorption
<absorption>


#parec[
  Consider thick black smoke from a fire: the smoke obscures the objects behind it because its particles absorb light traveling from the object to the viewer. The thicker the smoke, the more light is absorbed. @fig:cloud-absorption shows this effect with a realistic cloud model.
][
  考虑火灾产生的浓黑烟雾：烟雾遮挡了其后面的物体，因为其粒子吸收了从物体到观察者的光。 烟雾越浓，吸收的光就越多。@fig:cloud-absorption 展示了使用逼真的云模型的这一效果。
]
#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f02.svg"),
  caption: [
    #ez_caption[
      If a participating medium primarily absorbs light
      passing through it, it will have a dark appearance, as shown here.
      (a) A relatively dense medium leads to a more apparent boundary as
      well as a darker result. (b) A less dense medium gives a softer
      look, as more light makes it through the medium. (Cloud model
      courtesy of Walt Disney Animation Studios.)
    ][
      如果参与性介质主要吸收通过它的光，它将呈现出黑暗的外观，如图所示。(a)
      较密的介质导致更明显的边界以及更暗的结果。(b)
      较稀的介质则呈现出更柔和的外观，因为更多的光穿过了介质。（云模型由华特迪士尼动画工作室提供。）
    ]
  ],
)<cloud-absorption>


#parec[
  Absorption is described by the medium's #emph[absorption coefficient];, $sigma_a$, which is the probability density that light is absorbed per unit distance traveled in the medium. (Note that the medium absorption is distinct from the absorption coefficient used in specifying indices of refraction of conductors, as introduced in @the-fresnel-equations-for-conductors.) It is usually a spectrally varying quantity, though we will neglect the implications of that detail in this chapter and return to them in @improving-the-sampling-techniques . Its units are reciprocal distance ($upright(m)^(- 1)$), which means that $sigma_a$ can take on any nonnegative value; it is not required to be between $0$ and $1$, for instance. In general, the absorption coefficient may vary with both position $p$ and direction $omega$, although the volume scattering code in `pbrt` models it as purely a function of position. We will therefore sometimes simplify notation by not including $omega$ in the use of $sigma_a$ and other related scattering properties, though it is easy enough to reintroduce when it is relevant.
][
  吸收由介质的#emph[吸收系数] $sigma_a$ 描述，它是光在介质中每单位距离被吸收的概率密度。 （注意，介质吸收与在@the-fresnel-equations-for-conductors 中介绍的用于指定导体折射率的吸收系数不同。） 它通常是一个光谱变化的量，尽管我们将在本章中忽略这一细节的影响，并在@improving-the-sampling-techniques 中返回讨论。 其单位是倒数距离（$upright(m)^(- 1)$），这意味着 $sigma_a$ 可以取任何非负值；例如，它不必在 $0$ 和 $1$ 之间。 一般来说，吸收系数可能随位置 $p$ 和方向 $omega$ 变化，尽管`pbrt`中的体积散射代码将其建模为纯粹是位置的函数。 因此，我们有时会通过不在使用 $sigma_a$ 和其他相关散射特性时包含 $omega$ 来简化符号，尽管在相关时重新引入它很容易。
]

#parec[
  @fig:absorption-basic shows the effect of absorption along a very short segment of a ray. Some amount of radiance $L_i (p , - omega)$ is arriving at point $p$, and we would like to find the exitant radiance $L_o (p , omega)$ after absorption in the differential volume. This change in radiance along the differential ray length $d t$ is described by the differential equation. #footnote[
    The position for the $L_i$ functions
should actually be $p + d t omega$, though in a slight abuse of
notation we will here and elsewhere use p.
  ]
][
  @fig:absorption-basic 展示了沿着光线非常短的段的吸收效果。 某些量的辐射度 $L_i (p , - omega)$ 到达点 $p$，我们希望在微分体积吸收后找到出射辐射度 $L_o (p , omega)$。 这种沿微分光线长度 $d t$ 的辐射度变化由微分方程描述。#footnote[
    The position for the $L_i$ functions
should actually be $p + d t omega$, though in a slight abuse of
notation we will here and elsewhere use p.

  ]
]



$ L_o (p , omega) - L_i (p , - omega) = d L_o (p , omega) = - sigma_a (p , omega) L_i (p , - omega) d t , $


#parec[
  which says that the differential reduction in radiance along the beam is a linear function of its initial radiance. (This is another instance of the linearity assumption in radiometry: the fraction of light absorbed does not vary based on the ray's radiance, but is always a fixed fraction.)
][
  这表明沿光束的辐射度的微分减少是其初始辐射度的线性函数。（这是辐射度学中的线性假设的另一个实例：吸收的光的比例不随光线的辐射度变化，而始终是一个固定的比例。）
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f03.png"),
  caption: [
    #ez_caption[
      Figure 11.3: Absorption reduces the amount of radiance along a ray
      through a participating medium. Consider a ray carrying incident
      radiance at a point $p$ from direction $- omega$. If the ray passes
      through a differential cylinder filled with absorbing particles, the
      change in radiance due to absorption by those particles is
      $d L_o (p , omega) = - sigma_a (p , omega) L_i (p , - omega) d t .$
    ][
      图11.3：吸收减少了通过参与介质的光线沿线的辐射度。考虑一条在点$p$从方向$- omega$携带入射辐射度的光线。如果光线穿过一个充满吸收粒子的微小圆柱体，由于这些粒子的吸收导致的辐射度变化为
      $d L_o (p , omega) = - sigma_a (p , omega) L_i (p , - omega) d t .$
    ]
  ],
)<absorption-basic>


#parec[
  This differential equation can be solved to give the integral equation describing the total fraction of light absorbed for a ray. If we assume that the ray travels a distance $d$ in direction $omega$ through the medium starting at point $p$, the surviving portion of the original radiance is given by
][
  这个微分方程可以求解得出描述光线吸收的总比例的积分方程。如果我们假设光线从点 $p$ 开始沿方向 $omega$ 穿过介质行进距离 $d$，则原始辐射度的存活部分为
]

$ e^(- integral_0^d sigma_a (upright(p) + t omega , omega) d t) . $
=== Emission
<emission>


#parec[
  While absorption reduces the amount of radiance along a ray as it passes through a medium, emission increases it due to chemical, thermal, or nuclear processes that convert energy into visible light. @fig:vol-emission shows emission in a differential volume, where we denote emitted radiance added to a ray per unit distance at a point $p$ in direction $omega$ by $sigma_a (p , omega) L_e (p , omega)$. @fig:explosion-emission shows the effect of emission with a data set from a physical simulation of an explosion.
][
  虽然吸收减少了光线穿过介质时的辐射度，但由于化学、热或核过程将能量转化为可见光，发射增加了辐射度。@fig:vol-emission 显示了微分体积中的发射，我们用 $sigma_a (p , omega) L_e (p , omega)$ 表示在点 $p$ 沿方向 $omega$ 每单位距离增加到光线的发射辐射度。@fig:explosion-emission 显示了发射的效果，使用了物理模拟爆炸的数据集。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f04.png"),
  caption: [
    #ez_caption[
      Figure 11.4: The volume emission function $L_e (p , omega)$ gives
      the change in radiance along a ray as it passes through a
      differential volume of emissive particles. The change in radiance
      due to emission per differential distance is given by Equation
      (11.1).
    ][
      图11.4：体积发射函数$L_e (p , omega)$给出了光线穿过发射粒子的微分体积时辐射度的变化。由于发射每微分距离的辐射度变化由方程(11.1)给出。
    ]
  ],
)<vol-emission>

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/explosion-emission.png"),
  caption: [
    #ez_caption[
      A Participating Medium Where the Dominant Volumetric
      Effect Is Emission. #emph[(Scene courtesy of Jim Price.)]
    ][
      参与介质中主要的体积效应是发射。#emph[(场景由Jim
    Price提供。)]
    ]
    Figure 11.5:
  ],
)<explosion-emission>


#parec[
  The differential equation that gives the change in radiance due to emission is
][
  给出由于发射导致的辐射度变化的微分方程为
]

$ d L_o (p , omega) = sigma_a (p , omega) L_e (p , omega) d t . $ <volume-emission-diff-eq>
#parec[
  The presence of $sigma_a$ on the right hand side stems from the connection between how efficiently an object absorbs light and how efficiently it emits it, as was introduced in @blackbody-emitters. That factor also ensures that the corresponding term has units of radiance when the differential equation is converted to an integral equation.
][
  右侧的 $sigma_a$ 的存在源于物体吸收光的效率与其发射光的效率之间的联系，如@blackbody-emitters 所介绍的。该因子还确保在将微分方程转换为积分方程时，相应的项具有辐射度的单位。
]

#parec[
  Note that this equation incorporates the assumption that the emitted light $L_e$ is not dependent on the incoming light $L_i$. This is always true under the linear optics assumptions that `pbrt` is based on.
][
  注意，这个方程包含了假设发射光 $L_e$ 不依赖于入射光 $L_i$。在`pbrt`基于的线性光学假设下，这始终成立。
]

=== 11.1.3 Out Scattering and Attenuation
<out-scattering-and-attenuation>

#parec[
  The third basic light interaction in participating media is scattering. As a ray passes through a medium, it may collide with particles and be scattered in different directions. This has two effects on the total radiance that the beam carries. It reduces the radiance exiting a differential region of the beam because some of it is deflected to different directions. This effect is called #emph[out scattering] and is the topic of this section. However, radiance from other rays may be scattered into the path of the current ray; this #emph[in-scattering] process is the subject of the next section. We will sometimes say that these two forms of scattering are #emph[real scattering];, to distinguish them from null scattering, which will be introduced in Section 11.2.1.
][
  参与介质中的第三种基本光相互作用是散射。当光线穿过介质时，可能与粒子碰撞并向不同方向散射。这对光束携带的总辐射度有两个影响。它减少了光束微分区域的辐射度，因为部分光被偏转到不同方向。这种效应称为#emph[外散射];，是本节的主题。然而，其他光线的辐射度可能被散射到当前光线的路径中；这种#emph[内散射];过程是下一节的主题。我们有时会说这两种形式的散射是#emph[真实散射];，以区别于将在第11.2.1节介绍的空散射。
]

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f06.png"),
  caption: [
    #ez_caption[
      Figure 11.6: Like absorption, out scattering also reduces the
      radiance along a ray. Light that hits particles may be scattered in
      another direction such that the radiance exiting the region in the
      original direction is reduced.
    ][
      图11.6：与吸收类似，外散射也减少了沿光线的辐射度。光线击中粒子可能会被散射到另一个方向，从而减少了原方向上离开区域的辐射度。
    ]
  ],
)

#parec[
  The probability of an out-scattering event occurring per unit distance is given by the scattering coefficient, $sigma_s$. Similar to absorption, the reduction in radiance along a differential length $upright(d) t$ due to out scattering is given by
][

]

$ d L_o (p , omega) = - sigma_s (p , omega) L_i (p , - omega) d t $

#parec[
  The total reduction in radiance due to absorption and out scattering is given by the sum $sigma_a + sigma_s$. This combined effect of absorption and out scattering is called #emph[attenuation] or #emph[extinction];. The sum of these two coefficients is denoted by the attenuation coefficient $sigma_t$ :
][
  由于吸收和外散射导致的辐射减少总量由 $sigma_a + sigma_s$ 给出。这种吸收和外散射的综合效应称为#emph[衰减];或#emph[消光];。这两个系数的和表示为衰减系数 $sigma_t$ ：
]

$ sigma_t (p , omega) = sigma_a (p , omega) + sigma_s (p , omega) $


#parec[
  Two values related to the attenuation coefficient will be useful in the following. The first is the #emph[single-scattering albedo];, which is defined as
][
  与衰减系数相关的两个值将在接下来的讨论中有用。第一个是#emph[单次散射反照率];，定义为
]

$ rho (p , omega) = frac(sigma_s (p , omega), sigma_t (p , omega)) $



#parec[
  Under the assumptions of radiometry, the single-scattering albedo is always between 0 and 1. It describes the probability of scattering (versus absorption) at a scattering event. The second is the #emph[mean
free path];, $1 \/ sigma_t(upright(p), omega)$, which gives the average distance that a ray travels in a medium with attenuation coefficient $sigma_t(upright(p), omega)$ before interacting with a particle.
][
  在辐射测量的假设下，单次散射反照率总是在0到1之间。它描述了在散射事件中散射（相对于吸收）的概率。第二个是#emph[平均自由路径];， $1 \/ sigma_t(upright(p), omega)$，它表示在具有衰减系数 $sigma_t(upright(p), omega)$ 的介质中，光线在与粒子相互作用之前行进的平均距离。
]
=== In Scattering
<in-scattering>
#parec[
  While out scattering reduces radiance along a ray due to scattering in different directions, #emph[in scattering] accounts for increased radiance due to scattering from other directions (@fig:vol-inscatter). @fig:cloud-inscattering shows the effect of in scattering with the cloud model. There is no absorption there, corresponding to a single scattering albedo of 1. Light thus scatters many times inside the cloud, giving it a very different appearance.
][
  虽然外散射会由于在不同方向的散射而减少沿光线的辐射，但#emph[内散射];则考虑了由于从其他方向散射而增加的辐射（@fig:vol-inscatter）。@fig:cloud-inscattering 显示了使用云模型的内散射效果。那里没有吸收，对应于单次散射反照率为1。因此光在云中多次散射，使其呈现出非常不同的外观。
]


#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f07.svg"),
  caption: [
    #ez_caption[
      In scattering accounts for the increase in radiance along a ray due to
      scattering of light from other directions. Radiance from outside the
      differential volume is scattered along the direction of the ray and
      added to the incoming radiance.
    ][
      内散射考虑了由于从其他方向散射的光而增加的沿光线的辐射。来自微分体积外部的辐射沿光线方向散射并加入到入射辐射中。

    ]
  ],
)<vol-inscatter>

#figure(
  image("../pbr-book-website/4ed/Volume_Scattering/pha11f08.svg"),
  caption: [
    #ez_caption[
      In Scattering with the Cloud Model. For these scenes, there is no absorption and only scattering, which gives a substantially different result than the clouds in Figure 11.2. (a) Relatively dense cloud. (b) Thinner cloud. (Cloud model courtesy of Walt Disney Animation Studios.)
    ][
      In Scattering with the Cloud Model. For these scenes, there is no absorption and only scattering, which gives a substantially different result than the clouds in Figure 11.2. (a) Relatively dense cloud. (b) Thinner cloud. (Cloud model courtesy of Walt Disney Animation Studios.)
    ]
  ],
)<cloud-inscattering>

#parec[
  Assuming that the separation between particles is at least a few times the lengths of their radii, it is possible to ignore inter-particle interactions when describing scattering at a particular location. Under this assumption, the #emph[phase function] $p(omega, omega prime)$ describes the angular distribution of scattered radiation at a point; it is the volumetric analog to the BSDF. The BSDF analogy is not exact, however. For example, phase functions have a normalization constraint: for all $omega$, the condition
][
  假设粒子之间的间隔至少是它们半径的几倍，则在描述特定位置的散射时可以忽略粒子间的相互作用。在此假设下，#emph[相位函数] $p(omega, omega prime)$ 描述了在某一点的散射辐射的角分布；它是BSDF的体积模拟。 然而，BSDF的类比并不精确。例如，相位函数有一个归一化约束：对于所有 $omega$，条件
]


$
  integral_(S^2) p(omega ,omega prime) d omega prime = 1
$<phase-function-normalization>

#parec[
  must hold. #footnote[This difference is purely due to convention; the phase function
could have equally well been defined to include the albedo, like the BSDF.] This constraint means that phase functions are probability distributions for scattering in a particular direction.
][
  必须成立。#footnote[This difference is purely due to convention; the phase function
could have equally well been defined to include the albedo, like the BSDF.] 这一约束意味着相位函数是在特定方向上散射的概率分布。
]

#parec[
  The total added radiance per unit distance is given by the #emph[source
function] $L_s$ :
][
  每单位距离的总增加辐射由#emph[源函数] $L_s$ 给出：
]

$ upright(d) L_o (p , omega) = sigma_t (upright(p) , omega) L_s (p , omega) upright(d) t $

#parec[
  It accounts for both volume emission and in scattering:
][
  它同时考虑了体积发射和内散射的影响：
]

$
  L_s (p, omega) = frac(sigma_a (p comma omega), sigma_t (p comma omega)) L_e ( p, omega ) + frac(sigma_s (p comma omega), sigma_t (p comma omega)) integral_(SS^2) p(p, omega_i, omega) L_i ( p, omega_i ) thin d omega_i .
$<volumetric-source-function>

#parec[
  The in-scattering portion of the source function is the product of the albedo and the amount of added radiance at a point, which is given by the spherical integral of the product of incident radiance and the phase function. Note that the source function is very similar to the scattering equation, @eqt:scattering-equation; the main difference is that there is no cosine term since the phase function operates on radiance rather than differential irradiance.
][
  源函数的内散射部分是反照率与在特定点增加的辐射量的乘积，该辐射量由入射辐射与相位函数的乘积的球面积分给出。请注意，源函数与散射方程非常相似，@eqt:scattering-equation；主要区别在于没有余弦项，因为相位函数作用于辐射而不是微分辐照度。
]


