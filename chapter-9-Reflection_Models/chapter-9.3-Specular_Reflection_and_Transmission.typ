#import "../template.typ": parec, ez_caption
== Specular Reflection and Transmission
#parec[
  Following the discussion of diffuse surfaces with their perfectly uniform reflectance, we now turn to the opposite extreme: specular materials that only reflect light into a discrete set of directions. Following a review of the physical principles underlying such materials in this section, we will introduce concrete BxDF implementations in @conductor-BRDF and @dielectric-BSDF.
][
  继讨论了具有完全均匀反射特性的漫反射表面之后，我们现在转向另一个极端：只将光线反射到一组离散方向的镜面材料。本节将回顾这类材料背后的物理原理，并在@conductor-BRDF 和@dielectric-BSDF 中介绍具体的BxDF实现。
]
#parec[
  Our initial focus is on perfect specular surfaces. However, many real-world materials are fairly rough at a microscopic scale, and this can have a profound influence on their reflection behavior. @roughness-using-microfacet-theory and @rough-dielectric-BSDF will generalize our understanding of the perfect specular case to such rough surface microstructures.
][
  我们最初的关注点在于完美的镜面表面。然而，许多现实世界中的材料在微观尺度上相当粗糙，这对它们的反射行为有深远的影响。@roughness-using-microfacet-theory 和@rough-dielectric-BSDF 将把我们对完美镜面情况的理解推广到这类粗糙表面的微观结构。
]
=== Physical Principles
#parec[
  For the most part, this book is concerned with geometric optics, which describes the scattering and transport of radiance along rays. This is an approximation of the wave nature of light, albeit an excellent one: visible light waves occur at scales that are negligible ( $~ 1/ 2 mu m$ ) compared to the size of objects rendered in pbrt ( $~$ millimeters to meters), and hence wave-like phenomena normally do not manifest in rendered images.
][
  大部分情况下，本书关注的是几何光学，它描述了光线的散射和沿射线的辐射传输。这是对光的波动本质的一种近似，尽管是一个极好的近似：可见光波的尺度（ $~ 1/ 2 mu m$ ）与在pbrt中渲染的对象的大小（ $~$ 毫米到米）相比可以忽略不计，因此波动现象通常不会在渲染图像中显现。
]
#parec[
  Yet, to understand and model what happens when light strikes a surface, it is helpful to briefly turn toward this deeper understanding of light in terms of waves. Using wave-optical results within an overall geometric simulation is often possible and has become a common design pattern in computer graphics.
][
  然而，为了理解和模拟光线击中表面时发生的事情，简要地从波的角度深入理解光是有帮助的。在整体的几何模拟中使用波动光学的结果通常是可能的，并且已经成为计算机图形学中常见的设计模式。
]
#parec[
  The theory of electromagnetism describes light as an oscillation of the electric and magnetic fields. What does this mean? These terms refer to _vector fields_, which are convenient mathematical abstractions that assign a 3D vector to every point in space. These vectors describe the force that a small charged particle would feel due to such a light wave passing around it. For our purposes, only the electric field is interesting, and the charged particle that will be influenced by this force is an electron surrounding the nucleus of an atom.
][
  电磁理论描述光作为电场和磁场的振荡。这意味着什么？这些术语指的是_向量场_，它是方便的数学抽象，为空间中的每一点分配一个3D向量。这些向量描述了由于光波经过时，一个小带电粒子会感受到的力。对我们来说，只有电场是有趣的，受这种力影响的带电粒子是原子核周围的电子。
]
#parec[
  When a beam of light arrives at a surface, it stimulates the electrons of the atoms comprising the material, causing them to begin to oscillate rapidly. These moving electric charges induce secondary oscillations in the electric field, whose superposition is then subject to constructive and destructive interference. This constitutes the main mechanism in which atoms reflect light, though the specifics of this process can vary significantly based on the type of atom and the way in which it is bound to other atoms. The electromagnetic theory of light distinguishes the following three major classes of behaviors.
][
  当一束光线到达一个表面时，它刺激了构成材料的原子的电子，使它们开始快速振荡。这些移动的电荷诱导了电场中的次级振荡，其叠加随后受到构造性和破坏性干扰。这构成了原子反射光的主要机制，尽管这一过程的具体细节可以根据原子的类型以及它与其他原子的结合方式而有显著的不同。光的电磁理论区分了以下三个主要的行为类别。
]
#parec[
  The large class of _dielectrics_ includes any substance (whether gaseous, liquid, or solid) that acts as an electric insulator, including glass, water, mineral oil, and air. In such materials, the oscillating electrons are firmly bound to their atoms. Note that a liquid like water can be made electrically conductive by adding ions (e.g., table salt), but that is irrelevant in this classification of purely atomic properties.
][
  此大类的电介质包括任何作为 _电绝缘体_ 的物质（无论是气态、液态还是固态），包括玻璃、水、矿物油和空气。在这些材料中，振荡的电子牢固地绑定在它们的原子上。请注意，像水这样的液体可以通过添加离子（例如，食盐）而变成电导体，但这在这种纯粹原子属性的分类中不相关。
]
#parec[
  The second class of electric conductors includes metals and metal alloys, but also semi-metals like graphite. Some of the electrons can freely move within their atomic lattice; hence an oscillation induced by an incident electromagnetic wave can move electrons over larger distances. At the same time, migration through the lattice dissipates some of the incident energy in the form of heat, causing rapid absorption of the light wave as it travels deeper into the material. Total absorption typically occurs within the top $0.1 mu m$ of the material; hence only extremely thin metal films are capable of transmitting appreciable amounts of light. We ignore this effect in pbrt and treat metallic surfaces as opaque.
][
  第二类电导体包括 _金属和金属合金_ ，还包括像石墨这样的半金属。其中一些电子可以在它们的原子晶格内自由移动；因此，由入射电磁波引起的振荡可以使电子在较大距离上移动。同时，通过晶格的迁移耗散了一些入射能量以形成热量，导致光波在深入材料时迅速吸收。光波通常在材料的最顶层 $0.1 mu m$ 内被完全吸收；因此，只有极薄的金属膜才能传输大量的光。我们在pbrt中忽略了这种效应，将金属表面视为不透明。
]
#parec[
  A third class of semiconductors, such as silicon or germanium, exhibits properties of both dielectrics and conductors. For example, silicon appears metallic in the visible spectrum. At the same time, its transparency in the infrared range makes it an excellent material for optical elements in IR cameras. We do not explicitly consider semiconductors in pbrt, though adding a suitable BxDF to handle them would be relatively easy.
][
  第三类是 _半导体_ ，如硅或锗，展现了电介质和导体的双重属性。例如，硅在可见光谱中显得像金属。同时，它在红外范围的透明度使其成为红外相机光学元件的绝佳材料。我们在pbrt中没有明确考虑半导体，尽管添加一个适合处理它们的BxDF相对容易。
]

=== The Index of Refraction
#parec[
  When an incident light wave stimulates an electron, the oscillation induces its own electromagnetic oscillation. The oscillation of this re-emitted light incurs a small delay compared to the original wave. The compound effect of many such delays within a solid material causes the light wave to travel at a slower velocity compared to the original speed of light.
][
  当入射光波激发一个电子时，振荡诱导了它自己的电磁振荡。这种重新发射的光的振荡相对于原始波产生了一个小的延迟(delay)。在固体材料内许多这样的延迟的复合效应导致光波以比原始光速更慢的速度传播。
]
#parec[
  The speed reduction is commonly summarized using the index of refraction (IOR). For example, a material with an IOR of 2 propagates light at half the speed of light. For common materials, the value is in the range 1.0-2.5 and furthermore varies with the wavelength of light. We will use the Greek letter $eta$, pronounced “eta,” to denote this quantity.
][
  这种速度减缓通常用折射率（IOR）来总结。例如，折射率为2的材料以光速的一半传播光线。对于常见材料，该值范围在1.0至2.5之间，且随光的波长而变化。我们将使用希腊字母 $eta$ （发音为“eta”）来表示这个量。
]
#parec[
  Light waves undergo significant reflection when they encounter boundaries with a sudden change in the IOR value. For example, an air-diamond interface with a comparably high IOR difference of 2.42 will appear more reflective than an air-glass surface with a difference around 1.5. In this sense, the IOR provides the main mathematical explanation of why we perceive objects around us: it is because their IOR differs from the surrounding medium (e.g., air). The specific value of $eta$ controls the appearance of surfaces; hence a good estimate of this value is important for physically based rendering.
][
  当光波遇到折射率值突然改变的边界时，会发生显著的反射。例如，与空气-钻石界面相比，空气-玻璃表面的折射率差约为1.5，前者的折射率差高达2.42，看起来更具反射性。在这个意义上，折射率提供了我们感知周围物体的主要数学解释：这是因为它们的折射率不同于周围介质（例如，空气）。 $eta$ 的具体值控制着表面的外观；因此，对这个值的良好估计对于基于物理的渲染至关重要。
]

#parec[
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (50%, 50%),
          align: (auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          table.header([Medium], [Index of refraction $eta$]),
          table.hline(stroke: .5pt),
          [Vacuum ], [1.0],
          [Air at sea level], [1.00029],
          [Ice ], [1.31],
          [Water ($20 #sym.degree$ ) ], [1.333],
          [Fused quartz ], [1.46],
          [Glass ], [$1.5 - 1.6$],
          [Sapphire ], [1.77],
          [Diamond], [2.42],
          table.hline(stroke: 0pt),
        )],
      caption: [
        Indices of refraction for a variety of objects, giving the ratio of the speed of light in a vacuum to the speed of light in the medium. These are generally wavelength-dependent quantities; these values are averages over the visible wavelengths.
      ],
    )<dielectric-iors-en>
  ]
][
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (50%, 50%),
          align: (auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          table.header([介质], [折射率（ $eta$ ）]),
          table.hline(stroke: .5pt),
          [真空], [1.0],
          [海平面空气], [1.00029],
          [冰], [1.31 ],
          [水（ $20 #sym.degree$ ）], [1.333],
          [熔融石英], [1.46],
          [玻璃], [1.5-1.6],
          [蓝宝石], [1.77],
          [钻石], [2.42],
          table.hline(stroke: 0pt),
        )],
      caption: [
        各种物体的折射率，给出了真空中光速与介质中光速的比率。这些通常是波长依赖的量；这些值是可见波长范围内的平均值。
      ],
    )<dielectric-iors-zh>
  ]
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f05.svg"),
  caption: [
    #ez_caption[Plots of the Wavelength-Dependent Index of Refraction for Various Materials. All have only a few percent variation in index of refraction over the range of visible wavelengths, though even that is sufficient to be visible in rendered images.][各种材料的折射率随波长变化的图示。所有材料的折射率在可见光波长范围内仅有百分之几的变化，尽管如此，这样的变化在渲染图像中仍足以显现出来。]
  ],
)<wavelength-dependent-ior-plots>
#parec[
  @tbl:dielectric-iors-en provides IOR values for a number of dielectric materials and @fig:wavelength-dependent-ior-plots shows plots of the wavelength-dependent IOR for a few materials. pbrt also includes wavelength-dependent IORs for various materials that can be referred to by name in scene description files; see the file format documentation for more information.
][
  @tbl:dielectric-iors-zh 为多种电介质材料提供了IOR值，@fig:wavelength-dependent-ior-plots 展示了一些随波长变化的材料的IOR图表。pbrt还包括了可通过名称在场景描述文件中引用的各种材料的波长依赖性IOR值；更多信息请参见文件格式文档。
]
#parec[
  In the following, we assume that the IOR on both sides of the surface in question is known. We first review in which direction(s) light travels following an interaction, which is described by the law of specular reflection and Snell's law. Subsequently, we discuss how much of the scattered light travels in those directions, which is given by the Fresnel equations.
][
  下面，我们假设所讨论的表面两侧的IOR是已知的。我们首先回顾光线与之相互作用后的传播方向，这由镜面反射定律和斯涅尔定律描述。随后，我们讨论散射光能沿着这些方向传播传播多少，这由菲涅耳方程给出。
]
=== The Law of Specular Reflection
#parec[
  Given incident light from a direction $(theta_i, phi.alt_i)$, the single reflected direction $(theta_r, phi.alt_r)$ following an interaction with a perfect specular surface is easy to characterize: it makes the same angle with the normal as the incoming direction and is rotated around it by $180 #sym.degree$ —that is,
][
  给定来自方向 $(theta_i, phi.alt_i)$ 的入射光，与完美镜面相互作用后的单一反射方向 $(theta_r, phi.alt_r)$ 容易描述：它与法线的夹角与入射方向相同，并绕法线旋转 $180 #sym.degree$ ——也就是说，
]

$
  theta_i = theta_r, "and" phi.alt_r = phi.alt_i + pi
$
#parec[
  This direction can also be computed using vectorial arithmetic instead of angles, which is more convenient in subsequent implementation. For this, note that surface normal, incident, and outgoing directions all lie in the same plane.
][
  这个方向也可以使用向量运算而不是角度来计算，这在后续实现中更为方便。为此，请注意，表面法线、入射和出射方向都位于同一平面内。
]
#parec[
  We can decompose vectors $omega$ that lie in a plane into a sum of two components: one parallel to $upright(bold(n))$, which we will denote by $omega_(||)$, and one perpendicular to it, denoted $omega_(perp)$. These vectors are easily computed: if $upright(bold(n))$ and $omega$ are normalized, then $omega_(||)$ is $(cos theta) upright(bold(n)) = (upright(bold(n)) dot omega) upright(bold(n))$ (https://pbr-book.org/4ed/Reflection_Models/Specular_Reflection_and_Transmission#fig:perp-parallel-basics). Because $omega_(parallel)+omega_(perp) = omega$,
][
  我们可以将位于平面内的向量 $omega$ 分解为两个分量的和：一个与 $upright(bold(n))$ 平行，我们将其表示为 $omega_(parallel)$，另一个与之垂直，表示为 $omega_(perp)$。这些向量很容易计算：如果 $upright(bold(n))$ 和 $omega$ 都是归一化的，那么 $omega_(parallel)$ 是 $(cos theta) upright(bold(n)) = (upright(bold(n)) dot omega) upright(bold(n))$ （图 9.6）。因为 $omega_(parallel)+omega_(perp) = omega$，
]


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f06.svg"),
  caption: [
    #ez_caption[The parallel projection of a vector $omega$ on to the normal $upright(bold(n))$ is given by $omega_(parallel) = (cos theta) upright(bold(n)) = (upright(bold(n) dot omega)) upright(bold(n))$. The perpendicular component is given by $omega_(perp) = (sin theta) upright(bold(n))$ but is more easily computed by $omega_perp = omega - omega_parallel$.][
      向量 $omega$ 在法向量 $upright(bold(n))$ 上的平行投影由 $omega_(parallel) = (cos theta) upright(bold(n)) = (upright(bold(n) dot omega)) upright(bold(n))$ 给出。垂直分量由 $omega_(perp) = (sin theta) upright(bold(n))$ 给出，但更简单地可以通过 $omega_perp = omega - omega_parallel$ 来计算。
    ]

  ],
)
#parec[
  @fig:specular-reflection-dir shows the setting for computing the reflected direction $omega_r$. We can see that both vectors have the same $omega_perp$ component, and the value of $omega_(r perp)$ is the negation of $omega_(o perp)$. Therefore, we have
][
  @fig:specular-reflection-dir 显示了计算反射方向 $omega_r$ 的设置。我们可以看到，两个向量具有相同的 $omega_perp$ 分量，并且 $omega_(r perp)$ 的值是 $omega_(o perp)$ 的相反数。因此，我们有
]

$
  omega_r & = omega_(r perp) + omega_(r parallel) \
  & = - omega_(o perp) + omega_(o parallel) \
  & = -(omega_o -(upright(bold(n)) dot.op omega_o) upright(bold(n))) +( upright(bold(n)) dot.op omega_o ) upright(bold(n)) \
  & = - omega_o + 2(upright(bold(n)) dot.op omega_o) upright(bold(n)) .
$
#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f07.svg"),
  caption: [
    #ez_caption[
      Because the angles $theta_o$ and $theta_r$ are equal, the parallel component of the perfect reflection direction $omega_(r parallel)$ is the same as the incident direction's: $omega_(r parallel) = omega_(o parallel)$. Its perpendicular component is just the incident direction's perpendicular component, negated.
    ][
      因为角度 $theta_o$ 和 $theta_r$ 是相等的，完美反射方向的平行分量 $omega_(r parallel)$ 与入射方向的平行分量相同：$omega_(r parallel) = omega_(o parallel)$。其垂直分量正好是入射方向垂直分量的相反数。
    ]
  ],
)<specular-reflection-dir>

#parec[
  The Reflect() function implements this computation.
][
  函数`Reflect()`实现了这个计算。
]
```cpp
<<Scattering Inline Functions>>=
Vector3f Reflect(Vector3f wo, Vector3f n) {
    return -wo + 2 * Dot(wo, n) * n;
}
```




=== Snell's Law

#parec[
  At a specular interface, incident light with direction $(theta_i, phi.alt_i)$ about the surface normal _refracts_ into a single transmitted direction $(theta_t, phi.alt_t)$ located on the opposite side of the interface. The specifics of this process are described by _Snell's law_, which depends on the directions and IOR values $eta_i$ and $eta_t$ on both sides of the interface.
][
  在镜面界面，入射光线的方向为 $(theta_i, phi.alt_i)$ 相对于表面法线折射进入界面另一侧的单一透射方向 $(theta_t, phi.alt_t)$。这一过程的具体情况由_斯涅尔定律（Snell's law）_描述，该定律依赖于界面两侧的方向以及折射率值 $eta_i$ 和 $eta_t$。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f08.svg"),
  caption: [
    #ez_caption[
      Dragon model rendered with (a) perfect specular reflection and (b) perfect specular transmission. Image (b) excludes the effects of external and internal reflection; the resulting energy loss produces conspicuous dark regions. _(Model courtesy of Christian Schüller.)_
    ][
      使用（a）完美镜面反射和（b）完美镜面透射渲染的龙模型。（b）图中排除了外部和内部反射的影响；由此导致的能量损失产生了明显的暗区。_（模型由Christian Schüller提供。）_
    ]
  ],
)<dragon-reflect-refract>

#parec[
  Snell's law states that
][
  斯涅尔定律（Snnel's law）指出：
]



$ eta_i sin theta_i = eta_t sin theta_t upright("and") phi.alt_t = phi.alt_i + pi 。 $<snells-law>
#parec[
  If the target medium is optically denser (i.e., $eta_t > eta_i$ ), this means that the refracted light bends toward the surface normal. Snell's law can be derived using Fermat's principle, which is the subject of one of the exercises at the end of this chapter. @fig:dragon-reflect-refract shows the effect of perfect specular reflection and transmission.
][
  如果目标介质的光学密度更大（即， $eta_t > eta_i$ ），这意味着折射光向表面法线弯曲。斯涅尔定律可以通过费马原理推导出来，这是本章末尾练习的主题之一。@fig:dragon-reflect-refract 展示了理想镜面反射和透射的效果。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f09.svg"),
  caption: [
    #ez_caption[The Effect of Dispersion When Rendering Glass. (a) Rendered using a constant index of refraction, and (b) rendered using a wavelength-dependent index of refraction based on measurements of glass, which causes different wavelengths of light to be scattered in different directions. As a result, white colors are separated, making their individual wavelengths of light distinct. (Scene courtesy of Beeple.)][
      色散对渲染玻璃的影响。（a）使用恒定折射率渲染，（b）基于对玻璃的实际测量使用波长依赖的折射率进行渲染，这导致不同波长的光向不同方向散射。因此，白色被分解成不同的单色光，使得各自的光波长变得明显。（场景由Beeple提供。）
    ]
  ],
)<dispersion-rendered>
#parec[
  The index of refraction normally varies with respect to wavelength; hence light consisting of multiple wavelengths will split into multiple transmitted directions at the boundary between two different media—an effect known as dispersion. This effect can be seen when a prism splits incident white light into its spectral components. See @fig:dispersion-rendered for a rendered image that includes dispersion.
][
  折射率通常随波长变化；因此，包含多种波长的光将在两种不同介质的边界处分裂为多个透射方向——这种效果称为色散。这种效果可以通过棱镜将入射白光分解为其光谱成分来观察到。参见@fig:dispersion-rendered 以获取包含色散的渲染图像。
]

#parec[
  One useful observation about Snell's law is that it technically does not depend on the precise values of $eta_i$ and $eta_t$, but rather on their ratio. In other words, the law can be rewritten as
][
  关于斯涅尔定律的一个有用观察是，它实际上不依赖于 $eta_i$ 和 $eta_t$ 的精确值，而是依赖于它们的比率。换句话说，该定律可以重写为
]

$ sin theta_i = eta sin theta_t , $<snells-law-relative>

#parec[
  where the _relative index of refraction_ $eta = eta_t / eta_i$ specifies the proportional slowdown incurred when light passes through the interface. We will generally follow the convention that relevant laws and implementations are based on this relative quantity.
][
  其中相_对折射率_ $eta = eta_t / eta_i$ 指定了光通过界面时所遭受的比例减速。我们通常会遵循基于这一相对量的相关法律和实现的惯例。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f10.svg"),
  caption: [
    #ez_caption[
      *The Geometry of Specular Transmission.* Given an incident
      direction $omega_i$ and surface normal $bold(n)$ with angle $theta_i$ between
      them, the specularly transmitted direction makes an angle $theta_t$ with
      the surface normal. This direction, $omega_t$, can be computed by using
      Snell’s law to find its perpendicular component $omega_(t perp)$ and then
      computing the $omega_(t parallel)$ that gives a normalized result
      $omega_t$.
    ][
      *镜面透射的几何学。* 给定入射方向 $omega_i$ 和表面法线 $bold(n)$，它们之间的夹角为 $theta_i$，镜面透射方向与表面法线之间的夹角为 $theta_t$。这个透射方向 $omega_t$ 可以通过使用斯涅尔定律找到其垂直分量 $omega_(t perp)$，然后计算给出归一化结果 $omega_t$ 的平行分量 $omega_(t parallel)$ 来确定。

    ]
  ],
)<specular-transmission-geom>

#parec[
  As with the law of specular reflection, we shall now derive a more convenient vectorial form of this relationship, illustrated in @fig:specular-transmission-geom.
][
  与镜面反射定律一样，我们现在将推导出这种关系的更方便的矢量形式，如@fig:specular-transmission-geom 所示。
]

#parec[
  The trigonometric expressions above are closely related to the parallel and perpendicular components of the incident and transmitted directions. For example, the magnitudes of the perpendicular components equal the sines of the corresponding elevation angles. Since these directions all lie in a common reflection plane, @eqt:snells-law-relative can be rewritten as
][
  上述三角表达式与入射和透射方向的平行和垂直分量密切相关。例如，垂直分量的大小等于相应仰角的正弦。由于这些方向都位于一个共同的反射平面内，方程(9.3)可以重写为
]

$ omega_t^tack.t = - omega_i^tack.t / eta . $


#parec[
  Equivalently, because $omega^tack.t = omega - omega^parallel$,
][
  同样，因为 $omega^tack.t = omega - omega^parallel$，
]


$
  omega_t^perp = frac(-omega_i +(omega_i dot.op upright(bold(n))) upright(bold(n)), eta) .
$

#parec[
  The parallel component points into the direction $-bold(n)$, and its magnitude is given by $cos theta_t$ —that is,
][
  平行分量指向方向 $-bold(n)$，其大小由 $cos theta_t$ 给出，即，
]

$
  omega_(t parallel) = - cos theta_t upright(bold(n))
$

#parec[
  Putting all the above together, then, the vector $omega_t$ equals
][
  将上述所有内容结合起来，矢量 $omega_t$ 等于
]

$
  omega_t = omega_t^perp + omega_t^parallel = - frac(omega_i, eta) + [ frac((omega_i dot.op upright(bold(n))), eta) - cos theta_t ] upright(bold(n)) .
$<refracted-direction>

#parec[
  The function `Refract()` computes the refracted direction wt via @eqt:refracted-direction given an incident direction `wi`, surface normal `n` in the same hemisphere as `wi`, and the relative index of refraction eta. An adjusted relative IOR may be returned via `*etap`—we will discuss this detail shortly. The function returns a Boolean variable to indicate if the refracted direction was computed successfully.
][
  函数`Refract()`通过@eqt:refracted-direction 计算折射方向`wt`，给定入射方向`wi`，与`wi`位于同一半球的表面法线n，以及相对折射率eta。可能会通过指针`*etap`返回调整后的相对IOR——我们将很快讨论这一细节。函数返回一个布尔变量以指示是否成功计算折射方向。
]


```cpp
<<Scattering Inline Functions>>+=
bool Refract(Vector3f wi, Normal3f n, Float eta, Float *etap,
             Vector3f *wt) {
    Float cosTheta_i = Dot(n, wi);
    <<Potentially flip interface orientation for Snell’s law>>
    <<Compute  using Snell’s law>>
    *wt = -wi / eta + (cosTheta_i / eta - cosTheta_t) * Vector3f(n);
    <<Provide relative IOR along ray to caller>>
    return true;
}
```
#parec[
  The function's convention for the relative index of refraction eta slightly differs from the previous definition: it specifies the IOR ratio of the object interior relative to the outside, as indicated by the surface normal $upright(bold(n))$ that anchors the spherical coordinate system of quantities like $theta_i$ and $theta_t$.
][
  函数对于相对折射率eta的惯例与先前定义略有不同：它指定了相对于外部的物体内部的IOR比率，由锚定球坐标系的表面法线 $upright(bold(n))$ 指示的量如 $theta_i$ 和 $theta_t$。
]

#parec[
  When the incident ray lies _within_ the object, this convention is no longer compatible with our previous use of Snell's law, assuming positive angle cosines and a relative IOR relating the incident and transmitted rays. We detect this case and, if needed, flip the interface by inverting the sign of `n` and `cosTheta\_i` and swapping the IOR values, which is equivalent to taking the reciprocal of the relative IOR. @fig:dielectric-which-side illustrates this special case. Including this logic directly in Refract() facilitates its usage in rendering algorithms.
][
  当入射光线位于物体_内部_时，这种惯例不再与我们之前使用的斯涅尔定律兼容，假设正角余弦和与入射和透射光线相关的相对IOR。我们检测这种情况，并在需要时通过反转`n`和`cosTheta\_i`的符号并交换IOR值来翻转界面，这相当于取相对IOR的倒数。@fig:dielectric-which-side 说明了这种特殊情况。直接在Refract()中包含此逻辑有助于其在渲染算法中的使用。
]

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f11.svg"),
  caption: [
    #ez_caption[
      The cosine of the angle $theta$ between a direction $omega$ and the geometric surface normal indicates whether the direction is pointing outside the surface (in the same hemisphere as the normal) or inside the surface. In the standard reflection coordinate system, this test just requires checking the $z$ component of the direction vector. Here, $omega$ is in the upper hemisphere, with a positive-valued cosine, while $omega'$ is in the lower hemisphere.
    ][
      方向 $omega$ 与几何表面法线之间的夹角 $theta$ 的余弦值表明该方向是指向表面外（与法线在同一半球）还是指向表面内。在标准反射坐标系中，这一判断只需要检查方向矢量的 $z$ 分量。这里，$omega$ 位于上半球，其余弦值为正值，而 $omega'$ 位于下半球。
    ]
  ],
)<dielectric-which-side>

```cpp
<<Potentially flip interface orientation for Snell’s law>>=
if (cosTheta_i < 0) {
    eta = 1 / eta;
    cosTheta_i = -cosTheta_i;
    n = -n;
}
```

#parec[
  It is sometimes useful for the caller of `Refract()` to know the relative IOR along the ray, while handling the case when the ray arrives from the object's interior. To make this accessible, we store the updated `eta` value into the `etap` pointer if provided.
][
  有时调用者需要知道沿光线的相对IOR，同时处理光线从物体内部到达的情况。为了使其可访问，我们将更新后的`eta`值存储到`etap`指针中（如果提供）。
]

```cpp
<<Provide relative IOR along ray to caller>>=
if (etap)
    *etap = eta;
```


#parec[
  We have not yet explained how the cosine of the transmitted angle $theta_t$ should be computed. It can be derived from @eqt:snells-law-relative and the identity $sin^2 theta + cos^2 theta = 1$, which yields
][
  我们尚未解释如何计算透射角 $theta_t$ 的余弦。从@eqt:snells-law-relative 和恒等式 $sin^2 theta + cos^2 theta = 1$ 可以推导出
]

$
  cos theta_t = sqrt(1- (sin^2 theta_i) / eta^2)
$<snells-law-sine-cosine-identity>

#parec[
  The following fragment implements this computation.
][
  以下代码片段实现了该计算。
]

```cpp
<<Compute  using Snell’s law>>=
Float sin2Theta_i = std::max<Float>(0, 1 - Sqr(cosTheta_i));
Float sin2Theta_t = sin2Theta_i / Sqr(eta);
<<Handle total internal reflection case>>
Float cosTheta_t = SafeSqrt(1 - sin2Theta_t);
```

#parec[
  We must deal with one potential complication: when light travels into a medium that is less optically dense (i.e., $eta_t < eta_i$, the interface turns into an ideal reflector at certain angles so that no light is transmitted. This special case denoted _total internal reflection_ arises when $theta_i$ is greater than _critical angle_ $theta_c = sin^(-1)(1 \/ eta)$, at which point the argument of the square root function in @eqt:snells-law-sine-cosine-identity turns _negative_. This occurs at roughly $42 #sym.degree$ in the case of an air-glass interface. Total internal reflection is easy to experience personally inside a swimming pool: observing the air-water interface from below reveals a striking circular pattern that separates a refracted view of the outside from a pure reflection of the pool's interior, and this circle exactly corresponds to a viewing angle of $theta_c$.
][
  我们必须处理一个潜在的复杂情况：当光线进入一个光学密度较低的介质时（即 $eta_t < eta_i$ ），在某些角度下，界面会变成理想的反射面，使得没有光线能够透射。这种特殊情况被称为全内反射，它发生在入射角 $theta_i$ 大于临界角 $theta_c = sin^(-1)(1 \/ eta)$ 时，在此情况下@eqt:snells-law-sine-cosine-identity 中的平方根函数的参数变为负值。对于空气-玻璃界面，这种情况大约发生在 $42 degree$ 时。 全内反射很容易在游泳池内亲自体验到：从水下观察空气-水界面时，可以看到一个明显的圆形图案，这个图案将外界的折射视图与泳池内部的纯反射区分开来，而这个圆正好对应于视角为 $theta_c$ 的情况。
]


#parec[
  In the case of total internal reflection, the refracted direction `*wt` is undefined, and the function returns false to indicate this.
][
  在全内反射的情况下，折射方向 `*wt` 未定义，函数返回 false 以表示这一点。
]

```cpp
<<Handle total internal reflection case>>=
if (sin2Theta_t >= 1)
    return false;
```

=== The Fresnel Equations
#parec[
  The previous two subsections focused on where light travels following an interaction with a specular material. We now turn to the question of _how much_?
][
  前两个小节集中讨论了光在与镜面材料相互作用后去往何处。 现在我们转向_多少_的问题？
]


#parec[
  Light is normally both reflected and transmitted at the boundary between two materials with a different index of refraction, though the transmission rapidly decays in the case of conductors. For physically accurate rendering, we must account for the fraction of reflected and transmitted light, which is directionally dependent and therefore cannot be captured by a fixed per-surface scaling constant. The _Fresnel equations_, which are the solution to Maxwell's equations at smooth surfaces, specify the precise proportion of reflected light.
][
  光通常在两个具有不同折射率的材料边界处既被反射又被透射，尽管在导体的情况下透射迅速衰减。 为了实现物理上准确的渲染，我们必须考虑反射和透射光的比例，这取决于方向，因此不能通过固定的每表面缩放常数来捕捉。 _菲涅耳方程_是麦克斯韦方程在光滑表面上的解，指定了反射光的精确比例。
]

#parec[
  Recall the conscious decision to ignore polarization effects in @Radiometry. In spite of that, we must briefly expand on how polarization is represented to express the Fresnel equations in their natural form that emerges within the framework of electromagnetism.
][
  回想在@Radiometry 中，我们有意识地决定忽略偏振效应。 尽管如此，我们必须简要扩展如何表示偏振，以在电磁学框架中表达菲涅耳方程的自然形式。
]

#parec[
  At surfaces, it is convenient to distinguish between waves, whose polarization is perpendicular (" $perp$ ") or parallel (" $parallel$ ") to the plane of incidence containing the incident direction and surface normal. There is no loss of generality, since the polarization state of any incident wave can be modeled as a superposition of two such orthogonal oscillations.
][
  在表面上，区分偏振垂直（" $perp$ " ） 或 平 行 （ " $parallel$ "）于包含入射方向和表面法线的入射平面的波是很方便的。 没有一般性的损失，因为任何入射波的偏振状态都可以建模为两个这样的正交振荡的叠加。
]

#parec[
  The Fresnel equations relate the _amplitudes_ of the reflected wave ( $E_r$ ) given an incident wave with a known amplitude ( $E_i$ ). The ratio of these amplitudes depends on the properties of the specular interface specified in terms of the IOR values $eta_i$ and $eta_t$, and the angle $theta_i$ of the incident ray. Furthermore, parallel and perpendicularly polarized waves have different amounts of reflectance, which is the reason there are _two_ equations:
][
  菲涅耳方程将已知振幅的入射波给定的反射波的_振幅_（ $E_r$ ）联系起来。 这些振幅的比率取决于以 IOR 值 $eta_i$ and $eta_t$ 以及入射光线的角度 $theta_i$ 指定的镜面界面的性质。 此外，平行和垂直偏振波具有不同的反射量，这就是为什么有_两个_方程：
]

$
  r_parallel & = E_r^parallel / E_i^parallel = frac(eta_t cos theta_i - eta_i cos theta_t, eta_t cos theta_i + eta_i cos theta_t) ,\
  r_tack.t & = E_r^tack.t / E_i^tack.t = frac(eta_i cos theta_i - eta_t cos theta_t, eta_i cos theta_i + eta_t cos theta_t) .
$<fresnel>

#parec[
  (The elevation angle of the transmitted light $theta_t$ is determined by Snell's law.)
][
  （透射光的仰角 $theta_t$ 由斯涅尔定律决定。）
]

#parec[
  As with Snell's law, only the relative index of refraction $eta = eta_t / eta_i$ matters, and we therefore prefer the equivalent expressions
][
  与斯涅尔定律一样，只有相对折射率 $eta = eta_t / eta_i$ 重要，因此我们更喜欢等效表达式
]

$
  r_parallel = frac(eta cos theta_i - cos theta_t, eta cos theta_i + cos theta_t) , quad r_tack.t = frac(cos theta_i - eta cos theta_t, cos theta_i + eta cos theta_t) .
$<fresnel-rel>


#parec[
  In the wave-optics framework, the quantities of interest are the amplitude and phase of the reflected wave. In contrast, pbrt simulates light geometrically, and we care about the overall _power_ carried by the wave, which is given by the square of the amplitude.
][
  在波动光学框架中，感兴趣的量是反射波的振幅和相位。 相比之下，pbrt 几何地模拟光，我们关心波所携带的总体_功率_，这由振幅的平方给出。
]

#parec[
  Combining this transformation together with the assumption of unpolarized light leads to the _Fresnel reflectance_, expressing an average of the parallel and perpendicular oscillations:
][
  结合这一变换以及假设光是未偏振的，得出菲涅耳反射率，表示平行和垂直振荡的平均值：
]

$ F_r = 1 / 2 (r_parallel^2 + r_tack.t^2) . $

#parec[
  Dielectrics, conductors, and semiconductors are all governed by the same Fresnel equations. In the common dielectric case, there are additional simplification opportunities; hence it makes sense to first define specialized dielectric evaluation routines. We discuss the more general case in Section 9.3.6.

  https://pbr-book.org/4ed/Reflection_Models/Specular_Reflection_and_Transmission#sec:complex-ior
][
  介电材料、导体和半导体都遵循相同的菲涅耳方程。在常见的介电材料情况下，可以进行额外的简化；因此，首先定义专门的介电评估程序是合理的。我们将在第9.3.6节讨论更一般的情况。
]

#parec[
  The function `FrDielectric()` computes the unpolarized Fresnel reflection of a dielectric interface given its relative IOR $eta$ and angle cosine $cos theta_i$ provided via parameters `cosTheta\_i` and `eta`.
][
  函数`FrDielectric()`计算给定相对折射率 $eta$ 和角余弦 $cos theta_i$ 的介电界面的非偏振菲涅耳反射，参数通过`cosTheta\_i`和`eta`提供。
]

```cpp
<<Fresnel Inline Functions>>=
Float FrDielectric(Float cosTheta_i, Float eta) {
    cosTheta_i = Clamp(cosTheta_i, -1, 1);
    <<Potentially flip interface orientation for Fresnel equations>>
    <<Compute  for Fresnel equations using Snell’s law>>
    Float r_parl = (eta * cosTheta_i - cosTheta_t) /
                   (eta * cosTheta_i + cosTheta_t);
    Float r_perp = (cosTheta_i - eta * cosTheta_t) /
                   (cosTheta_i + eta * cosTheta_t);
    return (Sqr(r_parl) + Sqr(r_perp)) / 2;
}
```

#parec[
  Recall that our numerical implementation of Snell's law included a fragment `<<Potentially flip interface orientation for Snell's law>>` to implement the convention that eta always specifies a relative IOR relating the inside to the outside of an object, as determined by the surface normal. We include a similar step in `FrDielectric()` so that these two functions are consistent with each other.
][
  请注意，我们在斯涅尔定律的数值实现中包含了一个片段\<\<可能为斯涅尔定律翻转界面方向\>\>，以实现eta始终指定由表面法线确定的物体内部到外部的相对折射率的惯例。我们在`FrDielectric()`中包含了类似的步骤，以便这两个函数彼此一致。
]

```cpp
<<Potentially flip interface orientation for Fresnel equations>>=
if (cosTheta_i < 0) {
    eta = 1 / eta;
    cosTheta_i = -cosTheta_i;
}
```

#parec[
  The omitted fragment matches the previously explained fragment except for one small difference: in the case of total internal reflection, the previous fragment returned a failure to compute a refracted direction. Here, we must instead return a reflectance value of 1 to indicate that all scattering takes place via the reflection component.
][
  省略的片段与之前解释的片段相匹配，除了一个小的区别：在全内反射的情况下，之前的片段返回无法计算折射方向的失败。在这里，我们必须返回反射率值1，以指示所有散射都通过反射分量发生。
]

=== The Fresnel Equations for Conductors
<the-fresnel-equations-for-conductors>

#parec[
  Characterizing the reflection behavior of conductors involves an additional twist: the IOR turns into a complex number! Its real component describes the decrease in the speed of light as before. The newly added imaginary component models the decay of light as it travels deeper into the material. This decay occurs so rapidly that it also has a significant effect on the reflection component; hence it is important that we account for it even if the transmitted portion of light is of no interest.
][
  描述导体反射行为涉及一个额外的变化：折射率变成一个复数！其实部如前所述描述了光速的减慢。新添加的虚部描述了光在材料中更深处传播时的衰减。这种衰减发生得非常迅速，以至于对反射分量产生了显著影响；因此，即使对光的透射部分不感兴趣，我们也必须考虑这一点。
]

#parec[
  The emergence of complex numbers may appear counterintuitive at this stage. They are best thought of as a convenient mathematical tool employed in derivations based on electromagnetism; they exploit the property that imaginary exponentiation produces complex values with sinusoidal components:
][
  在此阶段，复数的出现可能显得不合常理。它们最好被视为一种方便的数学工具，用于基于电磁学的推导；它们利用了虚数指数产生具有正弦分量的复值的特性：
]





$ e^(i x) = cos x + i sin x . $


#parec[
  Incident and outgoing light is normally modeled using #emph[plane waves] describing an oscillatory electric field that varies with respect to both time and distance $z$ along the wave's direction of travel. For example, the spatial variation in the amplitude of such a wave can be expressed using an exponential function $E(z) = e^(-i alpha eta z)$ containing the imaginary unit $i$ in the exponent. The value $alpha$ denotes the spatial frequency, and $eta$ is the index of refraction. Only the real component of this field matters, which equals $cal(R)[E(z)] = cos(alpha eta z)$. In other words, the plane wave describes a sinusoidal oscillation that propagates unimpeded through the material, which is the expected behavior in a transparent dielectric.
][
  入射光和出射光通常使用描述振荡电场的#emph[平面波];进行建模，该电场随时间和沿波传播方向的距离 $z$ 变化。例如，这种波的振幅空间变化可以用指数函数 $E(z) = e^(-i alpha eta z)$ 表示，其中指数中包含虚数单位 $i$。值 $alpha$ 表示空间频率，而 $eta$ 是折射率。只有这个场的实部是重要的，即 $cal(R)[E(z)] = cos(alpha eta z)$ 。换句话说，平面波描述了一种在材料中不受阻碍传播的正弦振荡，这是透明介质中的预期行为。
]

#parec[
  Note, however, what happens when a negative imaginary component is added. By standard convention, the complex index of refraction is defined as $eta - i k$, where $eta$ retains the former meaning and the $k > 0$ term now leads to an exponential decay with increasing depth $z$ inside the medium—that is, $cal(R)[E(z)] = e^(-alpha z k) cos(alpha eta z)$. For this reason, $k$ is referred to as the #emph[absorption coefficient];. Although it superficially resembles the volumetric absorption coefficient defined in @volume-scattering-processes , those two processes occur at vastly different scales and should not be confused.
][
  然而，请注意当添加一个负的虚部时会发生什么。根据标准惯例，复数折射率定义为 $n - i k$，其中 $n$ 保留前面的意义，而 $k > 0$ 项现在导致在介质内部深度 $z$ 增加时的指数衰减，即 $cal(R)[E(z)] = e^(-alpha z k) cos(alpha eta z)$。 因 此 ， $k$ 被称为#emph[吸收系数];。尽管它表面上类似于 @volume-scattering-processes 中定义的体积吸收系数，但这两个过程发生在截然不同的尺度上，不应混淆。
]


#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f12.svg"),
  caption: [
    #ez_caption[Absorption Coefficient and Index of Refraction of Gold.
      This plot shows the spectrally varying values of the absorption
      coefficient $k$ and the index of refraction $eta$ for gold, where
      the horizontal axis is wavelength in nm.][金的吸收系数和折射率。该图显示了金的吸收系数$k$和折射率$eta$的光谱变化值，其中横轴是以纳米为单位的波长。]
  ],
)<gold-eta-k-plots>

#figure(
  image("../pbr-book-website/4ed/Reflection_Models/pha09f13.svg"),
  caption: [
    #ez_caption[
      Killeroo with a Gold Surface. The killeroo model is
      rendered here using the `ConductorBxDF`. See @fig:gold-eta-k-plots for a plot of
      the associated absorption coefficient and index of refraction that lead
      to its appearance. (#emph[Killeroo model courtesy of headus/Rezard.];)
    ][
      金表面的Killeroo。Killeroo模型在此使用`ConductorBxDF`渲染。有关导致其外观的相关吸收系数和折射率的图，请参见@fig:gold-eta-k-plots 。（#emph[Killeroo模型由headus/Rezard提供];）
    ]
  ],
)


#parec[
  @fig:gold-eta-k-plots shows a plot of the index of refraction and absorption coefficient for gold; both of these are wavelength-dependent quantities. Figure 9.13 shows a model rendered with a metal material.
][
  @fig:gold-eta-k-plots 显示了金的折射率和吸收系数的图表；这两者都是波长依赖的量。图9.13显示了用金属材料渲染的模型。
]

#parec[
  A wondrous aspect of the Fresnel equations is that these two deceptively simple formulae span all major classes of material behavior including dielectrics, conductors, and semiconductors. In the latter two cases, one must simply evaluate these equations using complex arithmetic. The `FrComplex()` function realizes this change. It takes the angle cosine of the incident direction and a relative index of refraction $eta = eta_t / eta_i$ obtained using complex division.
][
  Fresnel方程的一个奇妙方面是，这两个看似简单的公式涵盖了所有主要的材料行为类别，包括介电体、导体和半导体。在后两种情况下，只需使用复数算术来评估这些方程。`FrComplex()`函数实现了这一变化。它接受入射方向的角余弦和通过复数除法获得的相对折射率 $eta = eta_t / eta_i$。
]

```cpp
Float FrComplex(Float cosTheta_i, pstd::complex<Float> eta) {
    using Complex = pstd::complex<Float>;
    cosTheta_i = Clamp(cosTheta_i, 0, 1);
    <<Compute complex cosine $\thetar Fresnel equations using Snell’s law>>
    Float sin2Theta_i = 1 - Sqr(cosTheta_i);
    Complex sin2Theta_t = sin2Theta_i / Sqr(eta);
    Complex cosTheta_t = pstd::sqrt(1 - sin2Theta_t);
    Complex r_parl =     (eta * cosTheta_i - cosTheta_t) /
                          (eta * cosTheta_i + cosTheta_t);
    Complex r_perp =     (cosTheta_i - eta * cosTheta_t) /
                          (cosTheta_i + eta * cosTheta_t);
    return (pstd::norm(r_parl) + pstd::norm(r_perp)) / 2;
}
```

#parec[
  Compared to `FrDielectric()`, the main change in the implementation is the type replacement of `Float` by `pstd::complex<Float>`. The function `pstd::norm(x)` computes the squared magnitude—that is, the square of the distance from the origin of the complex plane to the point $x$.
][
  与`FrDielectric()`相比，实现中的主要变化是将`Float`类型替换为`pstd::complex<Float>`。函数`pstd::norm(x)`计算平方模，即从复平面原点到点 $x$ 的距离的平方。
]

#parec[
  Computation of $cos theta_t$ using Snell's law reveals another curious difference: due to the dependence on $eta$, this value now generally has an imaginary component, losing its original meaning as the cosine of the transmitted angle.
][
  使用斯涅尔定律计算 $cos theta_t$ 揭 示 了 另 一 个 奇 怪 的 差 异 ： 由 于 依 赖 于 $eta$，该值现在通常具有虚部，失去了其作为传输角余弦的原始意义。
]

```cpp
Float sin2Theta_i = 1 - Sqr(cosTheta_i);
Complex sin2Theta_t = sin2Theta_i / Sqr(eta);
Complex cosTheta_t = pstd::sqrt(1 - sin2Theta_t);
```


#parec[
  This is expected in the case of the Fresnel equations—computation of the actual transmitted angle in absorbing materials is more involved, and we sidestep this case in `pbrt` (recall that conductors were assumed to be opaque).
][
  在Fresnel方程的情况下，这是预期的——在吸收材料中计算实际的传输角更加复杂，我们在`pbrt`中回避了这种情况（回想一下，假设导体是不透明的）。
]

#parec[
  Complex numbers play a larger role within the Fresnel equations when polarization is modeled: recall how we detected the total internal reflection when a number under a square root became negative, which is nonsensical in real arithmetic. With complex arithmetic, this imaginary square root can be computed successfully. The angles of the resulting complex numbers $r_parallel$ and $r_tack.t$ relative to the origin of the complex plane encode a delay (also known as the #emph[phase];) that influences the polarization state of the reflected superposition of parallel and perpendicularly polarized waves. It is also worth noting that a number of different sign conventions exist—for example, depending on the definition of a plane wave, the imaginary IOR component `k` of conductors is either positive or negative. Some sources also flip the sign of the $r_parallel$ component. Such subtle details are a common source of bugs in renderers that account for polarization, but they are of no concern for `pbrt` since it only requires the amplitude of the reflected wave.
][
  当建模偏振时，复数在Fresnel方程中扮演更大的角色：回想一下，当平方根下的数字变为负数时，我们检测到全内反射，这在实数算术中是无意义的。使用复数算术，这个虚数平方根可以成功计算。 结果复数 $r_parallel$ 和 $r_tack.t$ 相对于复平面原点的角度编码了一个延迟（也称为#emph[相位];），它影响了平行和垂直偏振波反射叠加的偏振状态。还值得注意的是，存在许多不同的符号惯例——例如，根据平面波的定义，导体的虚数折射率成分`k`可以是正的或负的。一些来源也会翻转 $r_parallel$ 成分的符号。这些微妙的细节是考虑偏振的渲染器中常见的错误来源，但对于`pbrt`来说，它们不成问题，因为它只需要反射波的振幅。
]

#parec[
  Before turning to `BxDF`s using the helper functions defined in the last subsections, we define a convenient wrapper around `FrComplex()` that takes a spectrally varying complex IOR split into the `eta` and `k`, evaluating it `NSpectrumSamples` times.
][
  在使用上一小节中定义的辅助函数转向`BxDF`之前，我们定义了一个方便的包装器，围绕`FrComplex()`，它接受分为`eta`和`k`的光谱变化复数折射率，并对其进行`NSpectrumSamples`次评估。
]

```cpp
SampledSpectrum FrComplex(Float cosTheta_i, SampledSpectrum eta,
                            SampledSpectrum k) {
     SampledSpectrum result ;
      for (int i = 0; i < NSpectrumSamples; ++i)
          result[i] = FrComplex(cosTheta_i,
                                pstd::complex<Float>(eta[i], k[i]));
     return result;
 }
```

