#import "../template.typ": parec

== Further Reading

#parec[
  Lommel (#link("<cite:Lommel1889>")[1889];) first derived the equation of transfer. Not only did he derive this equation, but he also solved it in some simplified cases in order to estimate reflection functions from real-world surfaces (including marble and paper), and he compared his solutions to measured reflectance data from these surfaces.
][
  Lommel（#link("<cite:Lommel1889>")[1889];）首次推导出了辐射传输方程。他不仅推导出了这个方程，还在一些简化的情况下解决了它，以便估计来自真实世界表面（包括大理石和纸张）的反射函数，并将其解与这些表面的测量反射率数据进行比较。
]

#parec[
  The equation of transfer was independently found by Khvolson (#link("<cite:Khvolson1890>")[1890];) soon afterward; see Mishchenko (#link("<cite:Mishchenko2013>")[2013];) for a history of early work in the area.
][
  传输方程随后由 Khvolson（#link("<cite:Khvolson1890>")[1890];）独立发现；关于该领域早期工作的历史，请参见 Mishchenko（#link("<cite:Mishchenko2013>")[2013];）。
]

#parec[
  Seemingly unaware of Lommel's work, Schuster (#link("<cite:Schuster05>")[1905];) was the next researcher in radiative transfer to consider the effect of multiple scattering.
][
  似乎没有意识到 Lommel 的工作，Schuster（#link("<cite:Schuster05>")[1905];）是下一个考虑多重散射效应的辐射传输研究者。
]

#parec[
  He used the term #emph[self-illumination] to describe the fact that each part of the medium is illuminated by every other part of the medium, and he derived differential equations that described reflection from a slab along the normal direction, assuming the presence of isotropic scattering.
][
  他使用术语“自发光”来描述介质的每个部分都被介质的每个其他部分照亮的事实，并推导了描述沿法线方向从平板反射的微分方程，假设存在各向同性散射。
]

#parec[
  The conceptual framework that he developed remains essentially unchanged in the field of radiative transfer.
][
  他所发展的概念框架在辐射传输领域基本未变。
]

#parec[
  Soon thereafter, Schwarzschild (#link("<cite:Schwarzschild06>")[1906];) introduced the concept of radiative equilibrium, and Jackson (#link("<cite:Jackson10>")[1910];) expressed Schuster's equation in integral form, also noting that "the obvious physical mode of solution is Liouville's method of successive substitutions" (i.e., a Neumann series solution).
][
  不久之后，Schwarzschild（#link("<cite:Schwarzschild06>")[1906];）引入了辐射平衡的概念，Jackson（#link("<cite:Jackson10>")[1910];）以积分形式表达了 Schuster 的方程，并指出“显而易见的物理解决方案模式是 Liouville 的连续替代方法”（即 Neumann 级数解）。
]

#parec[
  Finally, King (#link("<cite:King13>")[1913];) completed the rediscovery of the equation of transfer by expressing it in the general integral form.
][
  最后，King（#link("<cite:King13>")[1913];）通过以一般积分形式表达传输方程，完成了对传输方程的重新发现。
]

#parec[
  Books by Chandrasekhar (#link("<cite:Chandrasekhar60>")[1960];), Preisendorfer (#link("<cite:Preisendorfer65>")[1965];, #link("<cite:Preisendorfer76>")[1976];), and van de Hulst (#link("<cite:vanDeHulst80>")[1980];) cover volume light transport in depth.
][
  Chandrasekhar（#link("<cite:Chandrasekhar60>")[1960];）、Preisendorfer（#link("<cite:Preisendorfer65>")[1965];, #link("<cite:Preisendorfer76>")[1976];）和 van de Hulst（#link("<cite:vanDeHulst80>")[1980];）的书籍深入探讨了体积光传输。
]

#parec[
  D'Eon's book (#link("<cite:dEon2016>")[2016];) extensively discusses scattering problems, including both analytic and Monte Carlo solutions, and contains many references to related work in other fields.
][
  D'Eon 的书（#link("<cite:dEon2016>")[2016];）广泛讨论了散射问题，包括解析解和蒙特卡罗解，并包含了许多与其他领域相关工作的参考文献。
]

#parec[
  The equation of transfer was introduced to graphics by Kajiya and Von Herzen (#link("<cite:Kajiya84>")[1984];).
][
  传输方程由 Kajiya 和 Von Herzen（#link("<cite:Kajiya84>")[1984];）引入到图形学领域。
]

#parec[
  Arvo (#link("<cite:Arvo93a>")[1993];) made essential connections between previous formalizations of light transport in graphics and the equation of transfer as well as to the field of radiative transfer in general.
][
  Arvo（#link("<cite:Arvo93a>")[1993];）在图形学中将先前的光传输形式化与传输方程以及辐射传输领域进行了重要联系。
]

#parec[
  Pauly et al.~(#link("<cite:Pauly00>")[2000];) derived the generalization of the path integral form of the light transport equation for the volume-scattering case; see also Chapter 3 of Jakob's Ph.D.~thesis (#link("<cite:Jakob2013>")[2013];) for a full derivation.
][
  Pauly 等人（#link("<cite:Pauly00>")[2000];）推导了体积散射情况下光传输方程的路径积分形式的推广；完整推导请参见 Jakob 的博士论文（#link("<cite:Jakob2013>")[2013];）第三章。
]

#parec[
  The integral null-scattering volume light transport equation was derived by Galtier et al.~(#link("<cite:Galtier2013>")[2013];) in the field of radiative transfer; Eymet et al.~(#link("<cite:Eymet2013>")[2013];) described the generalization to include scattering from surfaces.
][
  Galtier 等人（#link("<cite:Galtier2013>")[2013];）在辐射传输领域推导了积分零散射体积光传输方程；Eymet 等人（#link("<cite:Eymet2013>")[2013];）描述了包括表面散射的推广。
]

#parec[
  This approach was introduced to graphics by Novák et al.~(#link("<cite:Novak2014>")[2014];).
][
  Novák 等人（#link("<cite:Novak2014>")[2014];）将这种方法引入图形学。
]

#parec[
  Miller et al.~(#link("<cite:Miller2019>")[2019];) derived its path integral form, which made it possible to apply powerful variance reduction techniques based on multiple importance sampling.
][
  Miller 等人（#link("<cite:Miller2019>")[2019];）推导了其路径积分形式，使得可以应用基于多重重要性采样的强大方差减少技术。
]

#parec[
  Volumetric Path Tracing
][
  体积路径追踪
]

#parec[
  von Neumann's original description of the Monte Carlo algorithm was in the context of neutron transport problems (#link("<cite:Ulam1947>")[Ulam et al.~1947];); his technique included the algorithm for sampling distances from an exponential distribution (our Equation (#link("../Sampling_Algorithms/Sampling_1D_Functions.html#eq:exponential-sampling-distance")[A.17];)), uniformly sampling 3D directions via uniform sampling of \$ abla( heta)\$ (as implemented in #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformSphere")[SampleUniformSphere()];), and randomly choosing among scattering events as described in Section #link("../Light_Transport_II_Volume_Rendering/The_Equation_of_Transfer.html#sec:volumetric-path-tracing-deriv")[14.1.2];.
][
  冯·诺依曼对蒙特卡罗算法的最初描述是在中子传输问题的背景下（#link("<cite:Ulam1947>")[Ulam 等人 1947];）；他的技术包括从指数分布中采样距离的算法（我们的方程（#link("../Sampling_Algorithms/Sampling_1D_Functions.html#eq:exponential-sampling-distance")[A.17];）），通过均匀采样 \$ abla( heta)\$ 来均匀采样 3D 方向（如在 #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformSphere")[SampleUniformSphere()] 中实现），以及在 #link("../Light_Transport_II_Volume_Rendering/The_Equation_of_Transfer.html#sec:volumetric-path-tracing-deriv")[14.1.2] 节中描述的随机选择散射事件。
]

#parec[
  Rushmeier (#link("<cite:Rushmeier88>")[1988];) was the first to use Monte Carlo to solve the volumetric light transport equation in a general setting.
][
  Rushmeier（#link("<cite:Rushmeier88>")[1988];）是第一个在一般环境中使用蒙特卡罗解决体积光传输方程的人。
]

#parec[
  Szirmay-Kalos et al.~(#link("<cite:SzirmayKalos05>")[2005];) precomputed interactions between sample points in the medium in order to more quickly compute multiple scattering.
][
  Szirmay-Kalos 等人（#link("<cite:SzirmayKalos05>")[2005];）预计算介质中样本点之间的相互作用，以便更快地计算多重散射。
]

#parec[
  Kulla and Fajardo (#link("<cite:Kulla2012>")[2012];) proposed a specialized sampling technique that is effective for light sources inside participating media.
][
  Kulla 和 Fajardo（#link("<cite:Kulla2012>")[2012];）提出了一种专门的采样技术，对于参与介质内部的光源非常有效。
]

#parec[
  (This technique was first introduced in the field of neutron transport by Kalli and Cashwell (#link("<cite:Kalli1977>")[1977];).)
][
  （这种技术最早由 Kalli 和 Cashwell（#link("<cite:Kalli1977>")[1977];）在中子传输领域引入。）
]

#parec[
  Georgiev et al.~(#link("<cite:Georgiev2013>")[2013];) made the observation that incremental path sampling can generate particularly bad paths in participating media.
][
  Georgiev 等人（#link("<cite:Georgiev2013>")[2013];）观察到增量路径采样可以在参与介质中生成特别差的路径。
]

#parec[
  They proposed new multi-vertex sampling methods that better account for all the relevant terms in the equation of transfer.
][
  他们提出了新的多顶点采样方法，更好地考虑了传输方程中的所有相关项。
]

#parec[
  Sampling direct illumination from lights at points inside media surrounded by an interface is challenging; traditional direct lighting algorithms are not applicable at points inside the medium, as refraction through the interface will divert the shadow ray's path.
][
  从被界面包围的介质内部的点采样光源的直接照明是具有挑战性的；传统的直接照明算法不适用于介质内部的点，因为通过界面的折射会偏转阴影射线的路径。
]

#parec[
  Walter et al.~(#link("<cite:Walter2009>")[2009];) considered this problem and developed algorithms to efficiently find paths to lights accounting for this refraction.
][
  Walter 等人（#link("<cite:Walter2009>")[2009];）考虑了这个问题，并开发了算法以有效地找到考虑这种折射的光路径。
]

#parec[
  More recent work on this topic was done by Holzschuch (#link("<cite:Holzschuch2015>")[2015];) and Koerner et al.~(#link("<cite:Koerner2016>")[2016];).
][
  Holzschuch（#link("<cite:Holzschuch2015>")[2015];）和 Koerner 等人（#link("<cite:Koerner2016>")[2016];）在这个主题上进行了更近期的工作。
]

#parec[
  Weber et al.~(#link("<cite:Weber2017>")[2017];) developed an approach for more effectively sampling direct lighting in forward scattering media by allowing multiple scattering events along the path to the light.
][
  Weber 等人（#link("<cite:Weber2017>")[2017];）开发了一种方法，通过允许路径到光的多重散射事件，更有效地在前向散射介质中采样直接照明。
]

#parec[
  Szirmay-Kalos et al.~(#link("<cite:SzirmayKalos2017>")[2017];) first showed the use of the integral null-scattering volume light transport equation for rendering scattering inhomogeneous media.
][
  Szirmay-Kalos 等人（#link("<cite:SzirmayKalos2017>")[2017];）首次展示了使用积分零散射体积光传输方程来渲染散射不均匀介质。
]

#parec[
  Kutz et al.~(#link("<cite:Kutz2017>")[2017];) subsequently applied it to efficient rendering of spectral media and Szirmay-Kalos et al.~(#link("<cite:SzirmayKalos2018>")[2018];) developed improved algorithms for sampling multiple scattering.
][
  Kutz 等人（#link("<cite:Kutz2017>")[2017];）随后将其应用于高效渲染光谱介质，Szirmay-Kalos 等人（#link("<cite:SzirmayKalos2018>")[2018];）开发了改进的多重散射采样算法。
]

#parec[
  After deriving the path integral formulation, Miller et al.~(#link("<cite:Miller2019>")[2019];) used it to show the effectiveness of combining a variety of sampling techniques using multiple importance scattering, including bidirectional path tracing.
][
  在推导出路径积分公式后，Miller 等人（#link("<cite:Miller2019>")[2019];）展示了结合多种采样技术的有效性，包括双向路径追踪。
]

#parec[
  The visual appearance of high-albedo objects like clouds is striking, but many bounces may be necessary for good results.
][
  高反射率物体如云的视觉外观引人注目，但为了获得良好的结果，可能需要多次反弹。
]

#parec[
  Wrenninge et al.~(#link("<cite:Wrenninge2013>")[2013];) described an approximation where after the first few bounces, the scattering coefficient, the attenuation coefficient for shadow rays, and the eccentricity of the phase function are all progressively reduced.
][
  Wrenninge 等人（#link("<cite:Wrenninge2013>")[2013];）描述了一种近似方法，其中在最初的几次反弹后，散射系数、阴影射线的衰减系数和相函数的偏心率都逐渐减少。
]

#parec[
  Kallweit et al.~(#link("<cite:Kallweit2017>")[2017];) applied neural networks to store precomputed multiple scattering solutions for use in rendering highly scattering clouds.
][
  Kallweit 等人（#link("<cite:Kallweit2017>")[2017];）应用神经网络存储预计算的多重散射解决方案，用于渲染高度散射的云。
]

#parec[
  Pegoraro et al.~(#link("<cite:Pegoraro08>")[2008b];) developed a Monte Carlo sampling approach for rendering participating media that used information from previous samples to guide future sampling.
][
  Pegoraro 等人（#link("<cite:Pegoraro08>")[2008b];）开发了一种用于渲染参与介质的蒙特卡罗采样方法，该方法利用先前样本的信息指导未来采样。
]

#parec[
  More recent work in volumetric path guiding by Herholz et al.~applied product sampling based on the phase function and an approximation to the light distribution in the medium (#link("<cite:Herholz2019>")[Herholz et al.~2019];).
][
  Herholz 等人在体积路径引导中的最新工作应用了基于相函数和介质中光分布近似的乘积采样（#link("<cite:Herholz2019>")[Herholz 等人 2019];）。
]

#parec[
  Wrenninge and Villemin (#link("<cite:Wrenninge2020>")[2020];) developed a volumetric product sampling approach based on adapting the majorant to account for important regions of the integrand and then randomly selecting among candidate samples based on weights that account for factors beyond transmittance.
][
  Wrenninge 和 Villemin（#link("<cite:Wrenninge2020>")[2020];）开发了一种基于调整主导因素以考虑积分函数重要区域的体积乘积采样方法，然后根据权重在候选样本中随机选择，权重考虑了除透射率之外的因素。
]

#parec[
  Villeneuve et al.~(#link("<cite:Villeneuve2021>")[2021];) have also developed algorithms for product sampling in media, accounting for the surface normal at area light sources, transmittance along the ray, and the phase function.
][
  Villeneuve 等人（#link("<cite:Villeneuve2021>")[2021];）也开发了在介质中进行乘积采样的算法，考虑了面光源的表面法线、沿射线的透射率和相函数。
]

#parec[
  Volumetric emission is not handled efficiently by the #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[VolPathIntegrator];, as there is no specialized sampling technique to account for it.
][
  #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator")[VolPathIntegrator] 没有有效处理体积发射，因为没有专门的采样技术来考虑它。
]

#parec[
  Villemin and Hery (#link("<cite:Villemin2013>")[2013];) precomputed tabularized CDFs for sampling volumetric emission, and Simon et al.~(#link("<cite:Simon2017>")[2017];) developed further improvements, including integrating emission along rays and using the sampled point in the volume solely to determine the initial sampling direction, which gives better results in dense media.
][
  Villemin 和 Hery（#link("<cite:Villemin2013>")[2013];）预计算了用于采样体积发射的表格化 CDF，Simon 等人（#link("<cite:Simon2017>")[2017];）开发了进一步的改进，包括沿射线积分发射并仅使用体积中的采样点来确定初始采样方向，这在密集介质中给出了更好的结果。
]

#parec[
  The one-dimensional volumetric light transport algorithms implemented in #link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#LayeredBxDF")[LayeredBxDF] are based on Guo et al.'s approach (#link("<cite:Guo2018>")[2018];).
][
  在 #link("../Light_Transport_II_Volume_Rendering/Scattering_from_Layered_Materials.html#LayeredBxDF")[LayeredBxDF] 中实现的一维体积光传输算法基于 Guo 等人的方法（#link("<cite:Guo2018>")[2018];）。
]

#parec[
  Blinn (#link("<cite:Blinn82>")[1982b];) first used basic volume scattering algorithms for computer graphics.
][
  Blinn（#link("<cite:Blinn82>")[1982b];）首次在计算机图形学中使用了基本的体积散射算法。
]

#parec[
  Rushmeier and Torrance (#link("<cite:Rushmeier87>")[1987];) used finite-element methods for rendering participating media.
][
  Rushmeier 和 Torrance（#link("<cite:Rushmeier87>")[1987];）使用有限元方法来渲染参与介质。
]

#parec[
  Other early work in volume scattering for computer graphics includes work by Max (#link("<cite:Max86>")[1986];); Nishita, Miyawaki, and Nakamae (#link("<cite:Nishita87>")[1987];); Bhate and Tokuta's approach based on spherical harmonics (#link("<cite:Bhate92>")[Bhate and Tokuta 1992];), and Blasi et al.'s two-pass Monte Carlo algorithm, where the first pass shoots energy from the lights and stores it in a grid and the second pass does final rendering using the grid to estimate illumination at points in the scene (#link("<cite:Blasi93>")[Blasi et al.~1993];).
][
  其他早期在计算机图形学中进行体积散射的工作包括 Max（#link("<cite:Max86>")[1986];）；Nishita、Miyawaki 和 Nakamae（#link("<cite:Nishita87>")[1987];）；Bhate 和 Tokuta 基于球谐函数的方法（#link("<cite:Bhate92>")[Bhate 和 Tokuta 1992];），以及 Blasi 等人的两步蒙特卡罗算法，其中第一步从光源发射能量并将其存储在网格中，第二步使用网格进行最终渲染以估计场景中点的照明（#link("<cite:Blasi93>")[Blasi 等人 1993];）。
]

#parec[
  Glassner (#link("<cite:Glassner:PODIS>")[1995];) provided a thorough overview of this topic and early applications of it in graphics, and Max's survey article (#link("<cite:Max95>")[Max 1995];) also covers early work well.
][
  Glassner（#link("<cite:Glassner:PODIS>")[1995];）提供了该主题及其在图形学中早期应用的全面概述，而 Max 的综述文章（#link("<cite:Max95>")[Max 1995];）也很好地涵盖了早期工作。
]

#parec[
  See Cerezo et al.~(#link("<cite:Cerezo05>")[2005];) for an extensive survey of approaches to rendering participating media up through 2005.
][
  参见 Cerezo 等人（#link("<cite:Cerezo05>")[2005];），该文对截至 2005 年的参与介质渲染方法进行了广泛的调查。
]

#parec[
  One important application of volume scattering algorithms in computer graphics has been simulating atmospheric scattering.
][
  体积散射算法在计算机图形学中的一个重要应用是模拟大气散射。
]

#parec[
  Work in this area includes early papers by Klassen (#link("<cite:Klassen87>")[1987];) and Preetham et al.~(#link("<cite:Preetham99>")[1999];), who introduced a physically rigorous and computationally efficient atmospheric and sky-lighting model.
][
  该领域的工作包括 Klassen（#link("<cite:Klassen87>")[1987];）和 Preetham 等人（#link("<cite:Preetham99>")[1999];）的早期论文，他们引入了一个物理上严格且计算效率高的大气和天空照明模型。
]

#parec[
  Haber et al.~(#link("<cite:Haber2005>")[2005];) described a model for twilight, and Hošek and Wilkie (#link("<cite:Hosek2012>")[2012];, #link("<cite:Hosek2013>")[2013];) developed a comprehensive model for sky- and sunlight.
][
  Haber 等人（#link("<cite:Haber2005>")[2005];）描述了一个黄昏模型，而 Hošek 和 Wilkie（#link("<cite:Hosek2012>")[2012];，#link("<cite:Hosek2013>")[2013];）开发了一个全面的天空和阳光模型。
]

#parec[
  Bruneton evaluated the accuracy and efficiency of a number of models for atmospheric scattering (#link("<cite:Bruneton2017>")[Bruneton 2017];).
][
  Bruneton 评估了多种大气散射模型的准确性和效率（#link("<cite:Bruneton2017>")[Bruneton 2017];）。
]

#parec[
  A sophisticated model that accurately accounts for polarization, observers at arbitrary altitudes, and the effect of atmospheric scattering for objects at finite distances was recently introduced by Wilkie et al.~(#link("<cite:Wilkie2021>")[2021];).
][
  Wilkie 等人最近引入了一个复杂的模型，该模型准确考虑了偏振、任意高度观察者以及有限距离物体的大气散射效应（#link("<cite:Wilkie2021>")[2021];）。
]

#parec[
  Jarosz et al.~(#link("<cite:Jarosz:radiancecache>")[2008a];) first extended the principles of irradiance caching to participating media.
][
  Jarosz 等人（#link("<cite:Jarosz:radiancecache>")[2008a];）首次将辐照度缓存的原理扩展到参与介质。
]

#parec[
  Marco et al.~(#link("<cite:Marco2018>")[2018];) described a state-of-the-art algorithm for volumetric radiance caching based on Schwarzhaupt et al.'s surface-based second-order derivatives (#link("<cite:Schwarzhaupt12>")[Schwarzhaupt et al.~2012];).
][
  Marco 等人（#link("<cite:Marco2018>")[2018];）描述了一种基于 Schwarzhaupt 等人的基于表面的二阶导数的体积辐射缓存的最新算法（#link("<cite:Schwarzhaupt12>")[Schwarzhaupt 等人 2012];）。
]

#parec[
  Jensen and Christensen (#link("<cite:Jensen98>")[1998];) were the first to generalize the photon-mapping algorithm to participating media.
][
  Jensen 和 Christensen（#link("<cite:Jensen98>")[1998];）首次将光子映射算法推广到参与介质。
]

#parec[
  Knaus and Zwicker (#link("<cite:Knaus2011>")[2011];) showed how to render participating media using stochastic progressive photon mapping (SPPM).
][
  Knaus 和 Zwicker（#link("<cite:Knaus2011>")[2011];）展示了如何使用随机渐进光子映射（SPPM）渲染参与介质。
]

#parec[
  Jarosz et al.~(#link("<cite:Jarosz08>")[2008b];) had the important insight that expressing the scattering integral over a beam through the medium as the measurement to be evaluated could make photon mapping's rate of convergence much higher than if a series of point photon estimates was instead taken along each ray.
][
  Jarosz 等人（#link("<cite:Jarosz08>")[2008b];）的重要见解是，将介质中光束上的散射积分表达为要评估的测量，可以使光子映射的收敛速度比沿每条光线取一系列点光子估计要高得多。
]

#parec[
  Section 5.6 of Hachisuka's thesis (#link("<cite:Hachisuka2011>")[2011];) and Jarosz et al.~(#link("<cite:Jarosz2011a>")[2011a];, #link("<cite:Jarosz2011b>")[2011b];) showed how to apply this approach progressively.
][
  Hachisuka 的论文第 5.6 节（#link("<cite:Hachisuka2011>")[2011];）和 Jarosz 等人（#link("<cite:Jarosz2011a>")[2011a];，#link("<cite:Jarosz2011b>")[2011b];）展示了如何逐步应用这种方法。
]

#parec[
  For another representation, see Jakob et al.~(#link("<cite:Jakob2011>")[2011];), who fit a sum of anisotropic Gaussians to the equilibrium radiance distribution in participating media.
][
  有关另一种表示，请参见 Jakob 等人（#link("<cite:Jakob2011>")[2011];），他们将各向异性高斯的总和拟合到参与介质中的平衡辐射分布。
]

#parec[
  Many of the other bidirectional light transport algorithms discussed in the "Further Reading" section of Chapter #link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13] also have generalizations to account for participating media.
][
  在第 #link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13] 章的“进一步阅读”部分讨论的许多其他双向光传输算法也有推广以考虑参与介质。
]

#parec[
  See also Jarosz's thesis (#link("<cite:Jarosz2008>")[2008];), which has extensive background on this topic and includes a number of important contributions.
][
  另请参见 Jarosz 的论文（#link("<cite:Jarosz2008>")[2008];），其中对该主题进行了广泛的背景介绍，并包括许多重要的贡献。
]

#parec[
  Some researchers have had success in deriving closed-form expressions that describe scattering along unoccluded ray segments in participating media; these approaches can be substantially more efficient than integrating over a series of point samples.
][
  一些研究人员在推导描述参与介质中无遮挡光线段上散射的闭式表达式方面取得了成功；这些方法比在一系列点样本上进行积分要高效得多。
]

#parec[
  See Sun et al.~(#link("<cite:Sun05>")[2005];), Pegoraro and Parker (#link("<cite:Pegoraro09>")[2009];), and Pegoraro et al.~(#link("<cite:Pegoraro09etal>")[2009];, #link("<cite:Pegoraro2010>")[2010];, #link("<cite:Pegoraro2011>")[2011];) for examples of such methods.
][
  有关此类方法的示例，请参见 Sun 等人（#link("<cite:Sun05>")[2005];），Pegoraro 和 Parker（#link("<cite:Pegoraro09>")[2009];），以及 Pegoraro 等人（#link("<cite:Pegoraro09etal>")[2009];，#link("<cite:Pegoraro2010>")[2010];，#link("<cite:Pegoraro2011>")[2011];）。
]

#parec[
  (Remarkably, Pegoraro and collaborators' work provides a closed-form expression for scattering from a point light source along a ray passing through homogeneous participating media with anisotropic phase functions.)
][
  （值得注意的是，Pegoraro 和合作者的工作为沿通过各向异性相函数的均匀参与介质的光线从点光源散射提供了一个闭式表达式。）
]

#parec[
  Subsurface scattering models based on volumetric light transport were first introduced to graphics by Hanrahan and Krueger (#link("<cite:Hanrahan93>")[1993];), although their approach did not attempt to simulate light that entered the object at points other than at the point being shaded.
][
  基于体积光传输的次表面散射模型首次由 Hanrahan 和 Krueger（#link("<cite:Hanrahan93>")[1993];）引入到图形学中，尽管他们的方法并未尝试模拟进入对象的光在被着色点以外的点。
]

#parec[
  Dorsey et al.~(#link("<cite:Dorsey99>")[1999];) applied photon maps to simulating subsurface scattering that did include this effect, and Pharr and Hanrahan (#link("<cite:Pharr00>")[2000];) introduced an approach based on computing BSSRDFs for arbitrary scattering media with an integral over the medium's depth.
][
  Dorsey 等人（#link("<cite:Dorsey99>")[1999];）将光子映射应用于模拟包括此效果的次表面散射，Pharr 和 Hanrahan（#link("<cite:Pharr00>")[2000];）引入了一种基于计算任意散射介质的双向散射表面反射分布函数（BSSRDF）的方法，该方法对介质深度进行积分。
]

#parec[
  The diffusion approximation has been shown to be an effective way to model highly scattering media for rendering.
][
  #emph[扩散近似];已被证明是渲染高度散射介质的有效方法。
]

#parec[
  It was first introduced to graphics by Kajiya and Von Herzen (#link("<cite:Kajiya84>")[1984];), though Stam (#link("<cite:Stam95>")[1995];) was the first to clearly identify many of its advantages for rendering.
][
  它首次由 Kajiya 和 Von Herzen（#link("<cite:Kajiya84>")[1984];）引入到图形学中，尽管 Stam（#link("<cite:Stam95>")[1995];）是第一个明确指出其在渲染中许多优势的人。
]

#parec[
  A solution of the diffusion approximation based on dipoles was developed by Farrell et al.~(#link("<cite:Farrell92>")[1992];); that approach was applied to BSSRDF modeling for rendering by Jensen et al.~(#link("<cite:Jensen01>")[2001b];).
][
  基于偶极子的扩散近似解由 Farrell 等人（#link("<cite:Farrell92>")[1992];）开发；该方法被 Jensen 等人（#link("<cite:Jensen01>")[2001b];）应用于渲染的 BSSRDF 建模。
]

#parec[
  Subsequent work by Jensen and Buhler (#link("<cite:Jensen02>")[2002];) improved the efficiency of that method.
][
  Jensen 和 Buhler（#link("<cite:Jensen02>")[2002];）的后续工作提高了该方法的效率。
]

#parec[
  A more accurate solution based on photon beam diffusion was developed by Habel et al.~(#link("<cite:Habel2013>")[2013];).
][
  基于#emph[光子束扩散];的更精确解由 Habel 等人（#link("<cite:Habel2013>")[2013];）开发。
]

#parec[
  (The online edition of this book includes the implementation of a BSSRDF model based on photon beam diffusion as well as many more references to related work.)
][
  （本书的在线版包括基于光子束扩散的 BSSRDF 模型的实现以及更多相关工作的参考文献。）
]

#parec[
  Rendering realistic human skin is a challenging problem; this problem has driven the development of a number of new methods for rendering subsurface scattering after the initial dipole work as issues of modeling the layers of skin and computing more accurate simulations of scattering between layers have been addressed.
][
  渲染逼真的人类皮肤是一个具有挑战性的问题；这一问题推动了在初始偶极子工作之后开发许多新的次表面散射渲染方法，因为解决了皮肤层的建模问题以及计算层间散射的更准确模拟问题。
]

#parec[
  For a good overview of these issues, see Igarashi et al.'s (#link("<cite:Igarashi07>")[2007];) survey on the scattering mechanisms inside skin and approaches for measuring and rendering skin.
][
  有关这些问题的良好概述，请参见 Igarashi 等人（#link("<cite:Igarashi07>")[2007];）关于皮肤内部散射机制及其测量和渲染方法的调查。
]

#parec[
  Notable research in this area includes papers by Donner and Jensen (#link("<cite:Donner06a>")[2006];), d'Eon et al.~(#link("<cite:dEon07>")[2007];), Ghosh et al.~(#link("<cite:Ghosh08>")[2008];), and Donner et al.~(#link("<cite:Donner08>")[2008];).
][
  在该领域的显著研究包括 Donner 和 Jensen（#link("<cite:Donner06a>")[2006];），d'Eon 等人（#link("<cite:dEon07>")[2007];），Ghosh 等人（#link("<cite:Ghosh08>")[2008];），以及 Donner 等人（#link("<cite:Donner08>")[2008];）的论文。
]

#parec[
  Donner's thesis includes a discussion of the importance of accurate spectral representations for high-quality skin rendering (#link("<cite:DonnerPhD>")[Donner 2006];, Section 8.5).
][
  Donner 的论文包括关于高质量皮肤渲染中准确光谱表示重要性的讨论（#link("<cite:DonnerPhD>")[Donner 2006];，第 8.5 节）。
]

#parec[
  See Gitlina et al.~(#link("<cite:Gitlina2020>")[2020];) for recent work in the measurement of the scattering properties of skin and fitting it to a BSSRDF model.
][
  有关最近在皮肤散射特性测量及其拟合到 BSSRDF 模型中的工作，请参见 Gitlina 等人（#link("<cite:Gitlina2020>")[2020];）。
]

#parec[
  An alternative to BSSRDF-based approaches to subsurface scattering is to apply the same volumetric Monte Carlo path-tracing techniques that are used for other scattering media.
][
  次表面散射的另一种替代 BSSRDF 方法是应用与其他散射介质相同的体积蒙特卡罗路径追踪技术。
]

#parec[
  This approach is increasingly used in production (#link("<cite:Chiang2016:subsurf>")[Chiang et al.~2016b];).
][
  这种方法在生产中越来越多地使用（#link("<cite:Chiang2016:subsurf>")[Chiang 等人 2016b];）。
]

#parec[
  See Wrenninge et al.~(#link("<cite:Wrenninge2017>")[2017];) for a discussion of such a model designed for artistic control and expressiveness.
][
  有关为艺术控制和表现力设计的此类模型的讨论，请参见 Wrenninge 等人（#link("<cite:Wrenninge2017>")[2017];）。
]

#parec[
  Křivánek and d'Eon introduced the theory of zero-variance random walks for path-traced subsurface scattering, applying Dwivedi's sampling technique (#link("<cite:Dwivedi1982a>")[1982a];; #link("<cite:Dwivedi1982b>")[1982b];) to guide paths to stay close to the surface while maintaining an unbiased estimator (#link("<cite:Krivanek2014:zerovar>")[Křivánek and d'Eon 2014];).
][
  Křivánek 和 d'Eon 引入了用于路径追踪次表面散射的零方差随机游走理论，应用 Dwivedi 的采样技术（#link("<cite:Dwivedi1982a>")[1982a];；#link("<cite:Dwivedi1982b>")[1982b];）来引导路径保持靠近表面，同时保持无偏估计器（#link("<cite:Krivanek2014:zerovar>")[Křivánek 和 d'Eon 2014];）。
]

#parec[
  Meng et al.~(#link("<cite:Meng2016>")[2016];) developed further improvements to this approach, including strategies that handle back-lit objects more effectively.
][
  Meng 等人（#link("<cite:Meng2016>")[2016];）对这种方法进行了进一步改进，包括更有效处理背光物体的策略。
]

#parec[
  More recent work on zero-variance theory by d'Eon and Křivánek (#link("<cite:dEon2020>")[2020];) includes improved results with isotropic scattering and new sampling schemes that further reduce variance.
][
  d'Eon 和 Křivánek（#link("<cite:dEon2020>")[2020];）关于零方差理论的最新工作包括在各向同性散射和新的采样方案中取得了改进的结果，从而进一步降低了方差。
]

#parec[
  Leonard et al.~(#link("<cite:Leonard2021>")[2021];) applied machine learning to subsurface scattering, training conditional variational auto-encoders to sample scattering, to model absorption probabilities, and to sample the positions of ray paths in spherical regions.
][
  Leonard 等人（#link("<cite:Leonard2021>")[2021];）将机器学习应用于次表面散射，训练条件变分自编码器来采样散射、建模吸收概率以及采样球形区域中光线路径的位置。
]

#parec[
  They then used these capabilities to implement an efficient sphere-tracing algorithm.
][
  然后，他们利用这些能力实现了一个高效的球体追踪算法。
]

