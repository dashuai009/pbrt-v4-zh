#import "../template.typ": parec

== Further Reading
#parec[
  The first application of Monte Carlo to global illumination for creating synthetic images that we are aware of was described in Tregenza's paper on lighting design (#link("<cite:Tregenza83>")[Tregenza 1983];).
][
  我们所知的第一个将蒙特卡罗方法应用于全局光照以创建合成图像的实例是在Tregenza关于照明设计的论文中描述的（#link("<cite:Tregenza83>")[Tregenza 1983];）。
]

#parec[
  Cook's distribution ray-tracing algorithm computed glossy reflections, soft shadows from area lights, motion blur, and depth of field with Monte Carlo sampling (#link("<cite:Cook84>")[Cook et al.~1984];; #link("<cite:Cook86>")[Cook 1986];), although the general form of the light transport equation was not stated until papers by Kajiya (#link("<cite:Kajiya86>")[1986];) and Immel, Cohen, and Greenberg (#link("<cite:Immel86>")[1986];).
][
  Cook的分布式光线追踪算法通过蒙特卡罗采样计算了光滑反射、区域光源的柔和阴影、运动模糊和景深（#link("<cite:Cook84>")[Cook et al.~1984];; #link("<cite:Cook86>")[Cook 1986];），尽管光传输方程的一般形式直到Kajiya（#link("<cite:Kajiya86>")[1986];）和Immel、Cohen及Greenberg的论文（#link("<cite:Immel86>")[1986];）才被提出。
]

#parec[
  Kajiya (#link("<cite:Kajiya86>")[1986];) introduced the general-purpose path-tracing algorithm.
][
  Kajiya（#link("<cite:Kajiya86>")[1986];）引入了通用路径追踪算法。
]

#parec[
  Other important early work on Monte Carlo in rendering includes Shirley's Ph.D.~thesis (#link("<cite:Shirley90phd>")[1990];) and a paper by Kirk and Arvo (#link("<cite:Kirk91>")[1991];) on sources of bias in rendering algorithms.
][
  在渲染中关于蒙特卡罗的重要早期工作还包括Shirley的博士论文（#link("<cite:Shirley90phd>")[1990];）和Kirk及Arvo关于渲染算法偏差来源的论文（#link("<cite:Kirk91>")[1991];）。
]

#parec[
  Fundamental theoretical work on light transport has been done by Arvo (#link("<cite:Arvo93a>")[1993];, #link("<cite:ArvoThesis>")[1995a];), who investigated the connection between rendering algorithms in graphics and previous work in transport theory, which applies classical physics to particles and their interactions to predict their overall behavior.
][
  Arvo（#link("<cite:Arvo93a>")[1993];, #link("<cite:ArvoThesis>")[1995a];）在光传输的基础理论工作中，研究了图形渲染算法与之前在传输理论中的工作的联系，传输理论将经典物理学应用于粒子及其相互作用，以预测其整体行为。
]

#parec[
  Our description of the path integral form of the LTE follows the framework in Veach's Ph.D.~thesis, which has thorough coverage of different forms of the LTE and its mathematical structure (#link("<cite:VeachThesis>")[Veach 1997];).
][
  我们对路径积分形式的光传输方程（LTE）的描述遵循了Veach博士论文中的框架，该论文对不同形式的LTE及其数学结构进行了详尽的覆盖（#link("<cite:VeachThesis>")[Veach 1997];）。
]

#parec[
  The next event estimation technique that corresponds to the direct lighting computation in path tracing was first introduced by Coveyou et al.~(#link("<cite:Coveyou1967>")[1967];), in the context of neutron transport.
][
  对应于路径追踪中直接照明计算的下一事件估计技术最早由Coveyou等人引入（#link("<cite:Coveyou1967>")[1967];），在中子传输的背景下。
]

#parec[
  Russian roulette was introduced to graphics by Arvo and Kirk (#link("<cite:Arvo90pt>")[1990];).
][
  俄罗斯轮盘赌由Arvo和Kirk引入到图形学中（#link("<cite:Arvo90pt>")[1990];）。
]

#parec[
  Hall and Greenberg (#link("<cite:Hall83>")[1983];) had previously suggested adaptively terminating ray trees by not tracing rays with less than some minimum contribution.
][
  Hall和Greenberg（#link("<cite:Hall83>")[1983];）曾建议通过不追踪贡献低于某个最小值的光线来自适应地终止光线树。
]

#parec[
  Arvo and Kirk's technique is unbiased, although in some situations bias and less noise may be the more desirable artifact.
][
  Arvo和Kirk的技术是无偏的，尽管在某些情况下，偏差和较少的噪声可能是更可取的现象。
]

#parec[
  The Russian roulette termination probability computed in the PathIntegrator is largely determined by the albedo of the surface at the last scattering event; that approach was first introduced by Szesci et al.~(#link("<cite:Szesci2003>")[2003];).
][
  在#link("../Light_Transport_I_Surface_Reflection/A_Better_Path_Tracer.html#PathIntegrator")[PathIntegrator];中计算的俄罗斯轮盘赌终止概率主要由最后散射事件处表面的反照率决定；这种方法最早由Szesci等人引入（#link("<cite:Szesci2003>")[2003];）。
]

#parec[
  This is a reasonable way to set the probability, but better is to set the termination probability that also accounts for the incident lighting at a point: it would be better to terminate paths more aggressively in darker parts of the scene and less aggressively in brighter parts.
][
  这是一种合理的设定概率的方法，但更好的方法是设定同时考虑到某点入射光照的终止概率：在场景较暗的部分更积极地终止路径，而在较亮的部分则不那么积极。
]

#parec[
  Vorba and Křívánek described an approach for doing so based on an approximation of the lighting in the scene (#link("<cite:Vorba2016>")[Vorba and Křívánek 2016];).
][
  Vorba和Křívánek描述了一种基于场景中光照近似的方法来实现这一点（#link("<cite:Vorba2016>")[Vorba and Křívánek 2016];）。
]

#parec[
  They further applied splitting to the problem, increasing the number of paths in important regions.
][
  他们进一步将分裂应用于问题，增加了重要区域的路径数量。
]

#parec[
  Control variates is a Monte Carlo technique based on finding an approximation to the integrand that is efficient to evaluate and then applying Monte Carlo to integrate the difference between the approximation and the true integrand.
][
  控制变量是一种基于找到易于评估的被积函数近似值的蒙特卡罗技术，然后应用蒙特卡罗来积分近似值与真实被积函数之间的差异。
]

#parec[
  The variance of the resulting estimator then is dependent on the difference.
][
  结果估计量的方差依赖于差异。
]

#parec[
  This approach was first applied to rendering by Lafortune and Willems (#link("<cite:Lafortune94:ambient>")[1994];, #link("<cite:Lafortune95>")[1995];).
][
  Lafortune和Willems首次将这种方法应用于渲染（#link("<cite:Lafortune94:ambient>")[1994];, #link("<cite:Lafortune95>")[1995];）。
]

#parec[
  Recent work in this area includes Rousselle et al.~(#link("<cite:Rousselle2016>")[2016];), who made use of correlations between nearby pixels to define control variates.
][
  该领域的最新工作包括Rousselle等人（#link("<cite:Rousselle2016>")[2016];），他们利用邻近像素之间的相关性来定义控制变量。
]

#parec[
  (Their paper also has comprehensive coverage of other applications of control variates to rendering after Lafortune and Willems's work.)
][
  （他们的论文还全面覆盖了Lafortune和Willems工作之后控制变量在渲染中的其他应用。）
]

#parec[
  Müller et al.~(#link("<cite:Muller2020>")[2020];) have demonstrated the effectiveness of neural networks for computing control variates for rendering.
][
  Müller等人（#link("<cite:Muller2020>")[2020];）展示了神经网络在计算渲染控制变量方面的有效性。
]

#parec[
  Crespo et al.~(#link("<cite:Crespo2021>")[2021];) fit polynomials to the samples taken in each pixel and used them as control variates, showing reduction in error in pixels where the integrand was smooth.
][
  Crespo等人（#link("<cite:Crespo2021>")[2021];）将多项式拟合到每个像素中采集的样本，并将其用作控制变量，显示出在被积函数平滑的像素中误差的减少。
]

#parec[
  One approach to improving the performance of path tracing is to reuse computation across nearby points in the scene.
][
  提高路径追踪性能的一种方法是重用场景中相邻点的计算。
]

#parec[
  Irradiance caching (#link("<cite:Ward88>")[Ward et al.~1988];; #link("<cite:Ward94>")[Ward 1994];) is one such technique.
][
  辐照度缓存（#link("<cite:Ward88>")[Ward et al.~1988];; #link("<cite:Ward94>")[Ward 1994];）就是这样一种技术。
]

#parec[
  It is based on storing the irradiance due to indirect illumination at a sparse set of points on surfaces in the scene; because indirect lighting is generally slowly changing, irradiance can often be safely interpolated.
][
  它基于在场景表面上的稀疏点存储间接照明的辐照度；因为间接照明通常变化缓慢，辐照度通常可以安全地插值。
]

#parec[
  Tabellion and Lamorlette (#link("<cite:Tabellion2004>")[2004];) described a number of additional improvements to irradiance caching that made it viable for rendering for movie productions.
][
  Tabellion和Lamorlette（#link("<cite:Tabellion2004>")[2004];）描述了一些对辐照度缓存的额外改进，使其在电影制作的渲染中成为可行的方法。
]

#parec[
  Křívánek and collaborators generalized irradiance caching to radiance caching, where a more complex directional distribution of incident radiance is stored, so that more accurate shading from glossy surfaces is possible (Křívánek et al.~#link("<cite:Krivanek2005>")[2005];).
][
  Křívánek及其合作者将辐照度缓存推广为辐射缓存，其中存储了更复杂的入射辐射方向分布，从而可以实现更准确的光滑表面着色（Křívánek et al.~#link("<cite:Krivanek2005>")[2005];）。
]

#parec[
  Schwarzhaupt et al.~proposed a better way of assessing the validity of a cache point using a second-order expansion of the incident lighting (#link("<cite:Schwarzhaupt12>")[Schwarzhaupt et al.~2012];) and Zhao et al.~(#link("<cite:Zhao2019>")[2019];) have developed a number of improvements that are especially useful for glossy scenes.
][
  Schwarzhaupt等人提出了一种更好的方法来评估缓存点的有效性，使用入射光的二阶展开（#link("<cite:Schwarzhaupt12>")[Schwarzhaupt et al.~2012];），而Zhao等人（#link("<cite:Zhao2019>")[2019];）开发了一些特别适用于光滑场景的改进。
]

#parec[
  Ren et al.~(#link("<cite:Ren2013>")[2013];) first applied neural networks to represent the radiance distribution in a scene for rendering; more recently, Müller et al.~(#link("<cite:Muller2021>")[2021];) trained a fully connected 7-layer network to represent radiance during rendering and demonstrated both high performance and accurate indirect illumination.
][
  Ren等人（#link("<cite:Ren2013>")[2013];）首次应用神经网络表示场景中的辐射分布用于渲染；最近，Müller等人（#link("<cite:Muller2021>")[2021];）训练了一个全连接的7层网络来表示渲染过程中的辐射，并展示了高性能和准确的间接照明。
]

#parec[
  A number of approaches have been developed to sample from the product distribution of the BSDF and light source for direct lighting (Burke et al.~#link("<cite:Burke2005>")[2005];; Cline et al.~#link("<cite:Cline2006>")[2006];).
][
  已经开发了许多方法来从BSDF和光源的乘积分布中进行采样以进行直接照明（Burke et al.~#link("<cite:Burke2005>")[2005];; Cline et al.~#link("<cite:Cline2006>")[2006];）。
]

#parec[
  Product sampling can give better results than MIS-weighted light and BSDF samples when neither of those distributions matches the true product well.
][
  当这些分布都不与真实乘积很好地匹配时，乘积采样可以比MIS加权的光和BSDF样本给出更好的结果。
]

#parec[
  Clarberg, Rousselle, and collaborators developed techniques based on representing BSDFs and illumination in the wavelet basis and efficiently sampling from their product (Clarberg et al.~#link("<cite:Clarberg05>")[2005];; Rousselle et al.~#link("<cite:Rousselle08>")[2008];; Clarberg and Akenine-Möller #link("<cite:Clarberg08practical>")[2008a];).
][
  Clarberg、Rousselle及其合作者开发了基于在小波基中表示BSDF和照明并有效地从其乘积中采样的技术（Clarberg et al.~#link("<cite:Clarberg05>")[2005];; Rousselle et al.~#link("<cite:Rousselle08>")[2008];; Clarberg and Akenine-Möller #link("<cite:Clarberg08practical>")[2008a];）。
]

#parec[
  Efficiency of the direct lighting calculation can be further improved by sampling from the triple product distribution of BSDF, illumination, and visibility; this issue was investigated by Ghosh and Heidrich (#link("<cite:Ghosh2006:correlated>")[2006];) and Clarberg and Akenine-Möller (#link("<cite:Clarberg2008b>")[2008b];).
][
  通过从BSDF、照明和可见性的三重乘积分布中进行采样，可以进一步提高直接照明计算的效率；这个问题由Ghosh和Heidrich（#link("<cite:Ghosh2006:correlated>")[2006];）以及Clarberg和Akenine-Möller（#link("<cite:Clarberg2008b>")[2008b];）研究。
]

#parec[
  Wang and Åkerlund (#link("<cite:WangAck09>")[2009];) introduced an approximation to the indirect illumination that is used in the light sampling distribution with these approaches.
][
  Wang和Åkerlund（#link("<cite:WangAck09>")[2009];）引入了一种用于光采样分布的间接照明近似。
]

#parec[
  More recently, Belcour et al.~(#link("<cite:Belcour2018:clipped-sh>")[2018];) derived approaches for integrating the spherical harmonics over polygonal domains and demonstrated their application to product sampling.
][
  最近，Belcour等人（#link("<cite:Belcour2018:clipped-sh>")[2018];）推导了在多边形域上积分球谐函数的方法，并展示了其在乘积采样中的应用。
]

#parec[
  Hart et al.~(#link("<cite:Hart2020>")[2020];) showed how simple warps of uniform random samples can be used for product sampling.
][
  Hart等人（#link("<cite:Hart2020>")[2020];）展示了如何使用简单的均匀随机样本变换进行乘积采样。
]

#parec[
  Peters (#link("<cite:Peters2021polygonal>")[2021b];) has shown use of linearly transformed cosines (#link("<cite:Heitz2016>")[Heitz et al.~2016a];) with a new algorithm for sampling polygonal light sources to perform product sampling.
][
  Peters（#link("<cite:Peters2021polygonal>")[2021b];）展示了线性变换余弦（#link("<cite:Heitz2016>")[Heitz et al.~2016a];）在采样多边形光源以执行乘积采样的新算法的使用。
]

#parec[
  Subr et al.~(#link("<cite:Subr2014>")[2014];) analyzed the combination of multiple importance sampling and jittered sampling for direct lighting calculations and proposed techniques that improve convergence rates.
][
  Subr等人（#link("<cite:Subr2014>")[2014];）分析了多重重要性采样和抖动采样在直接照明计算中的结合，并提出了提高收敛率的技术。
]

#parec[
  Heitz et al.~(#link("<cite:Heitz2018>")[2018];) applied ratio estimators to direct illumination computations, which allows the use of analytic techniques for computing unshadowed direct illumination and then computing the correct result in expectation after tracing a shadow ray.
][
  Heitz等人（#link("<cite:Heitz2018>")[2018];）将比率估计器应用于直接照明计算，这允许使用解析技术计算无阴影直接照明，然后在追踪阴影光线后计算期望中的正确结果。
]

#parec[
  They showed the effectiveness of this approach with sophisticated models for analytic illumination from area lights (#link("<cite:Heitz2016>")[Heitz et al.~2016a];; #link("<cite:Dupuy2017>")[Dupuy et al.~2017];) and noted a number of benefits of this formulation in comparison to control variates.
][
  他们展示了这种方法在从区域光源进行解析照明的复杂模型中的有效性（#link("<cite:Heitz2016>")[Heitz et al.~2016a];; #link("<cite:Dupuy2017>")[Dupuy et al.~2017];），并指出了这种公式相对于控制变量的许多优点。
]

#parec[
  Another approach for applying analytic techniques to direct lighting was described by Billen and Dutré (#link("<cite:Billen2016>")[2016];) and Salesin and Jarosz (#link("<cite:Salesin2019>")[2019];), who integrated one dimension of the integral analytically.
][
  Billen和Dutré（#link("<cite:Billen2016>")[2016];）以及Salesin和Jarosz（#link("<cite:Salesin2019>")[2019];）描述了另一种应用解析技术于直接照明的方法，他们解析地积分了积分的一维。
]

#parec[
  Path regularization was introduced by Kaplanyan and Dachsbacher (#link("<cite:Kaplanyan2013>")[2013];).
][
  路径正则化由Kaplanyan和Dachsbacher引入（#link("<cite:Kaplanyan2013>")[2013];）。
]

#parec[
  Our implementation applies an admittedly ad hoc roughening to all non-diffuse BSDFs, while they only applied regularization to Dirac delta distributions and replaced them with a function designed to not lose energy, as ours may.
][
  我们的实现对所有非漫反射BSDF应用了一种公认的临时粗化，而他们仅将正则化应用于Dirac delta分布，并用一种设计为不损失能量的函数替代它们，而我们的可能会。
]

#parec[
  See also Bouchard et al.~(#link("<cite:Bouchard2013>")[2013];), who incorporated regularization as one of the sampling strategies to use with MIS.
][
  另见Bouchard等人（#link("<cite:Bouchard2013>")[2013];），他们将正则化作为与MIS一起使用的采样策略之一。
]

#parec[
  A principled approach to regularization for microfacet-based BSDFs was developed by Jendersie and Grosch (#link("<cite:Jendersie2019>")[2019];).
][
  Jendersie和Grosch（#link("<cite:Jendersie2019>")[2019];）开发了一种基于微面BSDF的正则化的原则性方法。
]

#parec[
  Weier et al.~(#link("<cite:Weier2021>")[2021];) have recently developed a path regularization approach based on learning regularization parameters with a variety of scenes and differentiable rendering.
][
  Weier等人（#link("<cite:Weier2021>")[2021];）最近开发了一种基于学习正则化参数的路径正则化方法，适用于各种场景和可微渲染。
]

#parec[
  A number of specialized sampling techniques have been developed for especially tricky scattering problems.
][
  为特别棘手的散射问题开发了许多专门的采样技术。
]

#parec[
  Wang et al.~(#link("<cite:Wang2020>")[2020b];) developed methods to render scattering paths that exclusively exhibit specular light transport, including those that start at pinhole cameras and end at point light sources.
][
  Wang等人（#link("<cite:Wang2020>")[2020b];）开发了渲染仅表现出镜面光传输的散射路径的方法，包括那些从针孔相机开始并在点光源结束的路径。
]

#parec[
  Such light-carrying paths cannot be sampled directly using the incremental path sampling approach used in pbrt.
][
  这种光传输路径无法使用`pbrt`中采用的增量路径采样方法直接采样。
]

#parec[
  Loubet et al.~(#link("<cite:Loubet2020>")[2020];) showed how to efficiently render caustics in a path tracer by constructing a data structure that records which triangles may cast caustics in a region of space and then directly sampling a specular light path from the light to the triangle to a receiving point.
][
  Loubet等人（#link("<cite:Loubet2020>")[2020];）展示了如何通过构建一个记录哪些三角形可能在空间区域投射焦散的结构，并直接从光源到三角形到接收点采样镜面光路径，来高效地在路径追踪器中渲染焦散。
]

#parec[
  Zeltner et al.~(#link("<cite:Zeltner2020>")[2020];) found caustic paths using an equation-solving iteration with random initialization, which requires precautions when reasoning about the probability of a generated sample.
][
  Zeltner等人（#link("<cite:Zeltner2020>")[2020];）通过随机初始化的方程求解迭代找到焦散路径，这需要在推理生成样本的概率时采取预防措施。
]


#parec[
  The `PathIntegrator` samples the BSDF in order to sample indirect illumination, though for scenes where the indirect illumination varies significantly as a function of direction, this is not an ideal approach.
][
  `PathIntegrator` 通过采样BSDF来采样间接照明，但对于间接照明随方向变化显著的场景，这并不是理想的方法。
]

#parec[
  A family of approaches that have come to be known as #emph[path guiding] have been developed to address this problem; all share the idea of building a data structure that represents the indirect illumination in the scene and then using it to draw samples.
][
  为了解决这个问题，一系列被称为#emph[路径引导];的方法被开发出来；这些方法都共享一个理念，即构建一个表示场景中间接照明的数据结构，然后利用它来进行采样。
]

#parec[
  Early work in this area was done by Lafortune and Willems (1995), who used a 5D tree to represent the scene radiance distribution, and Jensen (1995), who traced samples from the light sources ("photons") and used them to do the same.
][
  Lafortune和Willems (#link("<cite:Lafortune95>")[1995];) 的早期工作使用了一个5D树来表示场景辐射分布，而Jensen (#link("<cite:Jensen95>")[1995];) 则从光源（"光子"）追踪样本并使用它们来实现相同的目的。
]

#parec[
  Hey and Purgathofer (2002a) developed an improved approach based on photons and Pegoraro et al.~(2008a) applied the theory of sequential Monte Carlo to this problem.
][
  Hey和Purgathofer (#link("<cite:Hey2002>")[2002a];) 基于光子开发了一种改进的方法，而Pegoraro等人 (#link("<cite:Pegoraro2008a>")[2008a];) 将序列蒙特卡洛理论应用于这个问题。
]

#parec[
  An early path guiding technique based on adapting the distribution of uniform random samples to better sample important paths was described by Cline et al.~(2008).
][
  Cline等人 (#link("<cite:Cline08>")[2008];) 描述了一种早期的路径引导技术，该技术基于调整均匀随机样本的分布以更好地采样重要路径。
]

#parec[
  Vorba et al.~(2014) applied a parametric representation based on Gaussian mixture models (GMMs) that are learned over the course of rendering for path guiding and Herholz et al.~(2016) also included the BRDF in GMMs, demonstrating better performance in scenes with non-diffuse BSDFs.
][
  Vorba等人 (#link("<cite:Vorba2014>")[2014];) 应用了基于高斯混合模型（GMM）的参数化表示，这些模型在渲染过程中被学习用于路径引导，而Herholz等人 (#link("<cite:Herholz2016>")[2016];) 也将BRDF包含在GMM中，展示了在非漫反射BSDF场景中更优的性能。
]

#parec[
  Ruppert et al.~(2020) described a number of further improvements, applying the von Mises–Fisher distribution for their parametric model, improving the robustness of the fitting algorithm, and accounting for parallax, which causes the directional distribution of incident radiance to vary over volumes of space.
][
  Ruppert等人 (#link("<cite:Ruppert2020>")[2020];) 描述了许多进一步的改进，应用冯·米塞斯-费舍尔分布于他们的参数模型，改进了拟合算法的鲁棒性，并考虑了视差，这导致入射辐射的方向分布在空间体积上变化。
]

#parec[
  A path guiding technique developed by Müller and collaborators (Müller et al.~2017; Müller 2019) has seen recent adoption.
][
  Müller及其合作者 (#link("<cite:Muller2017>")[Müller et al.~2017];; #link("<cite:Muller2019:ppg-notes>")[Müller 2019];) 开发的路径引导技术最近得到了采用。
]

#parec[
  It is based on an adaptive spatial decomposition using an octree where each octree leaf node stores an adaptive directional decomposition of incident radiance.
][
  它基于基于八叉树的自适应空间分解，其中每个八叉树叶节点存储入射辐射的自适应方向分解。
]

#parec[
  Both of these decompositions are refined as more samples are taken and are used for sampling ray directions.
][
  随着样本数量的增加，这些分解会不断被细化，并用于采样光线方向。
]

#parec[
  This approach was generalized to include product sampling with the BSDF by Diolatzis et al.~(2020), who used Heitz et al.'s (2016a) linearly transformed cosines representation to do so.
][
  Diolatzis等人 (#link("<cite:Diolatzis2020>")[2020];) 将该方法推广为包括与BSDF结合的采样，他们使用Heitz等人 (#link("<cite:Heitz2016>")[2016a];) 的线性变换余弦表示来实现这一点。
]

#parec[
  A challenge with path guiding is that the Monte Carlo estimator generally includes variance due to factors not accounted for by the path guiding algorithm.
][
  路径引导面临的一个挑战是，蒙特卡洛估计器通常包含路径引导算法未考虑因素导致的方差。
]

#parec[
  Rath et al.~(2020) considered this issue and developed an approach for accounting for this variance in the function that is learned for guiding.
][
  Rath等人 (#link("<cite:Rath2020>")[2020];) 考虑了这个问题，并开发了一种方法来在学习用于引导的函数中考虑这种方差。
]

#parec[
  Reibold et al.~(2018) described a path guiding method based on storing entire ray paths and then defining a PDF for path guiding using Gaussian distributions around them in path space.
][
  Reibold等人 (#link("<cite:Reibold2018>")[2018];) 描述了一种基于存储整个光线路径的方法，然后在路径空间中使用高斯分布定义路径引导的PDF。
]

#parec[
  Machine learning approaches have also been applied to path guiding: Dahm and Keller (2017) investigated the connections between light transport and reinforcement learning and Müller et al.~and Zheng and Zwicker both used neural nets to learn the illumination in the scene and applied them to importance sampling (Müller et al.~2019; Zheng and Zwicker 2019).
][
  机器学习方法也被应用于路径引导：Dahm和Keller (#link("<cite:Dahm2017>")[2017];) 调查了光传输与强化学习之间的联系，而Müller等人和Zheng与Zwicker都使用神经网络来学习场景中的照明并将其应用于重要性采样 (#link("<cite:Muller2019:nis>")[Müller et al.~2019];; #link("<cite:Zheng2019>")[Zheng and Zwicker 2019];)。
]

#parec[
  A scene-independent approach was described by Bako et al.~(2019), who trained a neural net to take a local neighborhood of sample values and reconstruct the incident radiance function to use for path guiding.
][
  Bako等人 (#link("<cite:Bako2019>")[2019];) 描述了一种场景无关的方法，他们训练了一个神经网络，通过获取样本值的局部邻域来重建用于路径引导的入射辐射函数。
]

#parec[
  Deep reinforcement learning has been applied to this problem by Huo et al.~(2020).
][
  Huo等人 (#link("<cite:Huo2020>")[2020];) 将深度强化学习应用于这个问题。
]

#parec[
  Zhu et al.~(2021) recently introduced a path guiding approach based on storing directional samples in a quadtree and applying a neural network to generate sampling distributions from such quadtrees.
][
  Zhu等人 (#link("<cite:Zhu2021>")[2021];) 最近介绍了一种基于在四叉树中存储方向样本并应用神经网络从这些四叉树生成采样分布的路径引导方法。
]

#parec[
  They further generated quadtree samples using paths both from the camera and from the light sources and showed that doing so further reduces error in challenging lighting scenarios.
][
  他们进一步使用来自相机和光源的路径生成四叉树样本，并展示了这样做在具有挑战性的照明场景中进一步减少了误差。
]

#parec[
  The general idea of tracing light-carrying paths from light sources was first investigated by Arvo (1986), who stored light in texture maps on surfaces and rendered caustics.
][
  从光源追踪携带光的路径的基本思想最初由Arvo (#link("<cite:Arvo86>")[1986];) 调查，他在表面上的纹理图中存储光并渲染焦散。
]

#parec[
  Heckbert (1990b) built on this approach to develop a general ray-tracing-based global illumination algorithm, and Dutrè et al.~(1993) and Pattanaik and Mudur (1995) developed early particle-tracing techniques.
][
  Heckbert (#link("<cite:Heckbert90>")[1990b];) 在此基础上开发了一种基于光线追踪的全局照明算法，而Dutrè等人 (#link("<cite:Dutre:light-tracing>")[1993];) 和Pattanaik与Mudur (#link("<cite:Pattanaik:1995:AEA>")[1995];) 开发了早期的粒子追踪技术。
]

#parec[
  Christensen (2003) surveyed applications of adjoint functions and importance to solving the LTE and related problems.
][
  Christensen (#link("<cite:Christensen03:imp>")[2003];) 调查了伴随函数和重要性在解决LTE及相关问题中的应用。
]

#parec[
  Jensen (1995) developed the photon mapping algorithm, which introduced the key innovation of storing light contributions in a general 3D data structure.
][
  Jensen (#link("<cite:Jensen95>")[1995];) 开发了光子映射算法，该算法引入了在通用3D数据结构中存储光贡献的关键创新。
]

#parec[
  Important early improvements to the photon mapping method are described in follow-up papers and a book by Jensen (1996, 1997, 2001).
][
  光子映射方法的重要早期改进在后续论文和Jensen的书中有所描述 (#link("<cite:Jensen96>")[1996];, #link("<cite:Jensen:1997:RCO>")[1997];, #link("<cite:Jensen01b>")[2001];)。
]

#parec[
  Herzog et al.~(2007) described an approach based on storing all the visible points as seen from the camera and splatting photon contributions to them.
][
  Herzog等人 (#link("<cite:Herzog2007>")[2007];) 描述了一种基于存储从相机可见的所有点并将光子贡献溅射到这些点的方法。
]

#parec[
  Hachisuka et al.~(2008) developed the progressive photon mapping algorithm, which builds on that representation; stochastic progressive photon mapping (SPPM) was subsequently developed by Hachisuka and Jensen (2009).
][
  Hachisuka等人 (#link("<cite:Hachisuka2008>")[2008];) 开发了渐进光子映射算法，该算法建立在这种表示的基础上；随后Hachisuka和Jensen (#link("<cite:Hachisuka09>")[2009];) 开发了随机渐进光子映射（SPPM）。
]

#parec[
  (The online edition of this book includes an implementation of the SPPM algorithm.)
][
  (本书的在线版包括SPPM算法的实现。)
]

#parec[
  The question of how to find the most effective set of photons for photon mapping is an important one: light-driven particle-tracing algorithms do not work well for all scenes (consider, for example, a complex building model with lights in every room but where the camera sees only a single room).
][
  如何找到光子映射的最有效光子集是一个重要问题：光驱动的粒子追踪算法并不适用于所有场景（例如，考虑一个复杂的建筑模型，其中每个房间都有灯光，但相机只看到一个房间）。
]

#parec[
  Recent techniques for improved photon sampling include the work of Grittmann et al., who adapted the primary sample space distribution of samples in order to more effectively generate photon paths (Grittmann et al.~2018).
][
  最近的改进光子采样技术包括Grittmann等人的工作，他们调整了样本的主要样本空间分布以更有效地生成光子路径 (#link("<cite:Grittmann2018>")[Grittmann et al.~2018];)。
]

#parec[
  Conty Estevez and Kulla described an adaptive photon shooting algorithm that has been used in production (2020).
][
  Conty Estevez和Kulla描述了一种自适应光子发射算法，已在生产中使用 (#link("<cite:Conty2020>")[2020];)。
]

#parec[
  Both papers survey previous work in that area.
][
  这两篇论文都调查了该领域的先前工作。
]

#parec[
  Bidirectional path tracing constructs paths starting both from the camera and from the lights and then forms connections between them.
][
  双向路径追踪（从相机和光源同时构建路径）从相机和光源同时构建路径，然后在它们之间建立连接。
]

#parec[
  Doing so can be an effective way to sample some light-carrying paths.
][
  这样做可以有效地采样一些携带光的路径。
]

#parec[
  This technique was independently developed by Lafortune and Willems (1993) and Veach and Guibas (1994).
][
  这项技术由Lafortune和Willems (#link("<cite:Lafortune93>")[1993];) 以及Veach和Guibas (#link("<cite:Veach94>")[1994];) 独立开发。
]

#parec[
  The development of multiple importance sampling was integral to the effectiveness of bidirectional path tracing (Veach and Guibas (1995)).
][
  多重重要性采样的发展对于双向路径追踪的有效性至关重要 (Veach and Guibas (#link("<cite:Veach95>")[1995];))。
]

#parec[
  Lafortune and Willems (1996) showed how to apply bidirectional path tracing to rendering participating media.
][
  Lafortune和Willems (#link("<cite:Lafortune96>")[1996];) 展示了如何将双向路径追踪应用于渲染参与介质。
]

#parec[
  (An implementation of bidirectional path tracing is included in the online edition of the book; many additional references to related work are included there.)
][
  (本书的在线版包括双向路径追踪的实现；其中还包括许多与相关工作的额外参考。)
]

#parec[
  Simultaneous work by Hachisuka et al.~(2012) and Georgiev et al.~(2012) provided a unified framework for both photon mapping and bidirectional path tracing.
][
  Hachisuka等人 (#link("<cite:Hachisuka2012>")[2012];) 和Georgiev等人 (#link("<cite:Georgiev2012>")[2012];) 的同时工作为光子映射和双向路径追踪提供了一个统一的框架。
]

#parec[
  (This approach is often called either #emph[unified path sampling] (UPS) or #emph[vertex connection and merging] (VCM), after respective terminology in those two papers.)
][
  (这种方法通常被称为#emph[统一路径采样] (UPS) 或#emph[顶点连接与合并] (VCM)，根据这两篇论文中的术语。)
]

#parec[
  Their approaches allowed photon mapping to be included in the path space formulation of the light transport equation, which in turn made it possible to derive light transport algorithms that use both approaches to generate paths and combine them using multiple importance sampling.
][
  他们的方法允许光子映射被包含在光传输方程的路径空间公式中，这反过来使得可以推导出使用这两种方法生成路径并通过多重重要性采样结合它们的光传输算法。
]


#parec[
  Veach and Guibas (#link("<cite:Veach97>")[1997];) first applied the Metropolis sampling algorithm to solving the light transport equation. They demonstrated how this method could be applied to image synthesis and showed that the result was a light transport algorithm that was robust to traditionally difficult lighting configurations (e.g., light shining through a slightly ajar door).
][
  Veach 和 Guibas (#link("<cite:Veach97>")[1997];) 首次将 Metropolis 采样算法应用于解决光传输方程。他们展示了如何将这种方法应用于图像合成，并表明结果是一个对传统上难以处理的复杂光照配置（例如，通过微微开启的门照射的光）具有鲁棒性的光传输算法。
]

#parec[
  Pauly, Kollig, and Keller (#link("<cite:Pauly00>")[2000];) generalized the Metropolis light transport (MLT) algorithm to include volume scattering. Pauly's thesis (Pauly #link("<cite:Pauly99>")[1999];) described the theory and implementation of bidirectional and Metropolis-based algorithms for volume light transport.
][
  Pauly、Kollig 和 Keller (#link("<cite:Pauly00>")[2000];) 将 Metropolis 光传输（MLT）算法推广到包括体积散射。Pauly 的论文 (Pauly #link("<cite:Pauly99>")[1999];) 描述了用于体积光传输的双向和基于 Metropolis 的算法的理论和实现。
]

#parec[
  MLT algorithms generally are unable to take advantage of the superior convergence rates offered by well-distributed sample values. Bitterli and Jarosz present a hybrid light transport algorithm that uses path tracing by default but with the integrand partitioned so that only high-variance samples are handled instead by Metropolis sampling (#link("<cite:Bitterli2019>")[Bitterli and Jarosz 2019];).
][
  MLT 算法通常无法充分利用分布良好的样本值所带来的优越收敛率。Bitterli 和 Jarosz 提出了一种混合光传输算法，默认使用路径追踪，但将被积函数分区，以便仅由 Metropolis 采样处理高方差样本 (#link("<cite:Bitterli2019>")[Bitterli and Jarosz 2019];)。
]

#parec[
  In this way, the benefits of both algorithms are available, with Metropolis available to sample tricky paths and path tracing with well-distributed sample points efficiently taking care of the rest.
][
  通过这种方式，可以利用两种算法的优势，Metropolis 采样用于处理复杂路径，而路径追踪则通过分布良好的样本点高效地处理其余部分。
]

#parec[
  Kelemen et al.~(#link("<cite:Kelemen:2002:ASA>")[2002];) developed the "primary sample space MLT" formulation of Metropolis light transport, which is much easier to implement than Veach and Guibas's original formulation. That approach is implemented in the online edition of this book, including the "multiplexed MLT" improvement developed by Hachisuka et al.~(#link("<cite:Hachisuka2014>")[2014];).
][
  Kelemen 等人 (#link("<cite:Kelemen:2002:ASA>")[2002];) 开发了“主样本空间 MLT”公式，比 Veach 和 Guibas 的原始公式更易于实现和应用。这种方法在本书的在线版中实现，包括 Hachisuka 等人 (#link("<cite:Hachisuka2014>")[2014];) 开发的“多路复用 MLT”改进。
]

#parec[
  Inverting the sampling functions that convert primary sample space samples to light paths makes it possible to develop MLT algorithms that operate both in primary sample space and in path space, the basis of Veach and Guibas's original formulation of MLT.
][
  反转将主样本空间样本转换为光路径的采样函数，使得可以开发在主样本空间和路径空间中运行的 MLT 算法，这是 Veach 和 Guibas 的 MLT 原始公式的基础。
]

#parec[
  Pantaleoni (#link("<cite:Pantaleoni2017>")[2017];) used such inverses to improve the distribution of samples and to develop new light transport algorithms, and Otsu et al.~(#link("<cite:Otsu2017>")[2017];) developed a novel approach that applies mutations in both spaces.
][
  Pantaleoni (#link("<cite:Pantaleoni2017>")[2017];) 利用这种逆变换来改善样本的分布并开发新的光传输算法，而 Otsu 等人 (#link("<cite:Otsu2017>")[2017];) 开发了一种在两个空间中应用变异的新方法。
]

#parec[
  Bitterli et al.~(#link("<cite:Bitterli2018:rjmlt>")[2018a];) used this approach to apply reversible jump Markov chain Monte Carlo to light transport and to develop new sampling techniques.
][
  Bitterli 等人 (#link("<cite:Bitterli2018:rjmlt>")[2018a];) 使用这种方法将可逆跳跃马尔可夫链蒙特卡罗应用于光传输并开发新的采样技术。
]

#parec[
  See Šik and Křivánek's article for a comprehensive survey of the application of Markov chain sampling algorithms to light transport (#link("<cite:Sik2018>")[Šik and Křivánek 2018];).
][
  有关马尔可夫链采样算法在光传输中的应用的全面综述，请参阅 Šik 和 Křivánek 的文章 (#link("<cite:Sik2018>")[Šik and Křivánek 2018];)。
]


#parec[
  A number of algorithms have been developed based on a first phase of computation that traces paths from the light sources to create so-called virtual lights, where these lights are then used to approximate indirect illumination during a second phase.
][
  已经开发出许多算法，这些算法基于计算的第一阶段，从光源追踪路径以创建所谓的虚拟光源，然后在第二阶段使用这些光源来近似间接照明。
]

#parec[
  The principles behind this approach were first introduced by Keller's work on #emph[instant radiosity] (#link("<cite:Keller97>")[Keller 1997];).
][
  这种方法的原理最早由Keller在其#emph[瞬时辐射度];（#link("<cite:Keller97>")[Keller 1997];）的研究中引入。
]

#parec[
  The more general #emph[instant global illumination] algorithm was developed by Wald, Benthin, and collaborators (Wald et al.~#link("<cite:Wald02>")[2002];, #link("<cite:Wald03>")[2003];; Benthin et al.~#link("<cite:Benthin03>")[2003];).
][
  更通用的#emph[瞬时全局照明];算法由Wald、Benthin及其合作者开发（Wald等 #link("<cite:Wald02>")[2002];, #link("<cite:Wald03>")[2003];; Benthin等 #link("<cite:Benthin03>")[2003];）。
]

#parec[
  See Dachsbacher et al.'s survey (#link("<cite:Dachsbacher14>")[2014];) for a summary of work in this area.
][
  有关该领域工作的总结，请参阅Dachsbacher等人的综述（#link("<cite:Dachsbacher14>")[2014];）。
]

#parec[
  Building on the virtual point lights concept, Walter and collaborators (#link("<cite:Walter2005>")[2005];, #link("<cite:Walter2006>")[2006];) developed #emph[lightcuts];, which are based on creating thousands of virtual point lights and then building a hierarchy by progressively clustering nearby ones together.
][
  基于虚拟点光源的概念，Walter及其合作者（#link("<cite:Walter2005>")[2005];, #link("<cite:Walter2006>")[2006];）开发了#emph[光切割];，其基于创建数千个虚拟点光源，然后通过逐步聚类附近的光源来构建层次结构。
]

#parec[
  When a point is being shaded, traversal of the light hierarchy is performed by computing bounds on the error that would result from using clustered values to illuminate the point versus continuing down the hierarchy, leading to an approach with both guaranteed error bounds and good efficiency.
][
  当一个点被着色时，通过计算使用聚类值照亮该点与继续沿层次结构向下的误差界限来遍历光层次结构，从而形成了一种既有保证误差界限又有效率的方法。
]

#parec[
  A similar hierarchy is used by Yuksel and Yuksel (#link("<cite:Yuksel2017>")[2017];) for determining the illumination from volumetric emitters.
][
  Yuksel和Yuksel（#link("<cite:Yuksel2017>")[2017];）使用类似的层次结构来确定体积发射器的照明。
]

#parec[
  Bidirectional lightcuts (Walter et al.~#link("<cite:Walter2012>")[2012];) trace longer subpaths from the camera to obtain a family of light connection strategies; combining the strategies using multiple importance sampling eliminates bias artifacts that are commonly produced by virtual point light methods.
][
  双向光切割（Walter等 #link("<cite:Walter2012>")[2012];）从相机追踪更长的子路径以获得一系列光连接策略；通过多重重要性采样结合这些策略，消除了虚拟点光源方法中常见的偏差伪影。
]

#parec[
  Jakob and Marschner (#link("<cite:Jakob2012:manifold>")[2012];) expressed light transport involving specular materials as an integral over a high-dimensional manifold embedded in path space.
][
  Jakob和Marschner（#link("<cite:Jakob2012:manifold>")[2012];）将涉及镜面材料的光传输表示为嵌入在路径空间中的高维流形上的积分。
]

#parec[
  A single light path corresponds to a point on the manifold, and nearby paths are found using a local parameterization that resembles Newton's method; they applied a Metropolis-type method through this parameterization to explore the neighborhood of challenging specular and near-specular configurations.
][
  单个光路径对应于流形上的一个点，并使用类似于牛顿法的局部参数化找到附近的路径；他们通过这种参数化应用了一种Metropolis类型的方法来探索具有挑战性的镜面和近镜面配置的邻域。
]

#parec[
  Hanika et al.~(#link("<cite:Hanika2015a>")[2015a];) applied an improved version of the local path parameterization in a pure Monte Carlo context to estimate the direct illumination through one or more dielectric boundaries; this leads to significantly better convergence when rendering glass-enclosed objects or surfaces covered with water droplets.
][
  Hanika等人（#link("<cite:Hanika2015a>")[2015a];）在纯蒙特卡罗上下文中应用了改进的局部路径参数化来估计通过一个或多个介电边界的直接照明；这在渲染玻璃封闭的物体或覆盖水滴的表面时显著提高了收敛性。
]

#parec[
  Kaplanyan et al.~(#link("<cite:Kaplanyan2014>")[2014];) observed that the path contribution function is close to being separable when paths are parameterized using the endpoints and the half-direction vectors at intermediate vertices, which are equal to the microfacet normals in the context of microfacet reflectance models.
][
  Kaplanyan等人（#link("<cite:Kaplanyan2014>")[2014];）观察到，当路径使用端点和中间顶点的半方向向量进行参数化时，路径贡献函数接近可分离，这些向量在微表面反射模型的上下文中等于微表面法线。
]

#parec[
  Performing Metropolis sampling in this half-vector domain leads to a method that is particularly good at rendering glossy interreflection.
][
  在这个半向量域中进行Metropolis采样导致了一种特别擅长渲染光泽互反射的方法。
]

#parec[
  An extension by Hanika et al.~(#link("<cite:Hanika2015b>")[2015b];) improves the robustness of this approach and proposes an optimized scheme to select mutation sizes to reduce sample clumping in image space.
][
  Hanika等人（#link("<cite:Hanika2015b>")[2015b];）的扩展提高了这种方法的鲁棒性，并提出了一种优化方案来选择变异大小，以减少图像空间中的样本聚集。
]

#parec[
  Another interesting approach was developed by Lehtinen and collaborators, who considered rendering from the perspective of computing gradients of the image (Lehtinen et al.~#link("<cite:Lehtinen13>")[2013];, Manzi et al.~#link("<cite:Manzi14>")[2014];).
][
  另一种有趣的方法由Lehtinen及其合作者开发，他们从计算图像梯度的角度考虑渲染（Lehtinen等 #link("<cite:Lehtinen13>")[2013];, Manzi等 #link("<cite:Manzi14>")[2014];）。
]

#parec[
  Their insight was that, ideally, most samples from the path space should be taken around discontinuities and not in smooth regions of the image.
][
  他们的见解是，理想情况下，大多数来自路径空间的样本应集中在不连续处而不是图像的平滑区域。
]

#parec[
  They then developed a measurement contribution function for Metropolis sampling that focused samples on gradients and then reconstructed high-quality final images from horizontal and vertical gradient images and a coarse, noisy image.
][
  他们随后开发了一种测量贡献函数用于Metropolis采样，将样本集中在梯度上，然后从水平和垂直梯度图像以及粗糙的噪声图像中重建高质量的最终图像。
]

#parec[
  More recently, Kettunen et al.~(#link("<cite:Kettunen2015>")[2015];) showed how this approach could be applied to regular path tracing without Metropolis sampling.
][
  最近，Kettunen等人（#link("<cite:Kettunen2015>")[2015];）展示了如何将这种方法应用于常规路径追踪而不使用Metropolis采样。
]

#parec[
  Manzi et al.~(#link("<cite:Manzi2015>")[2015];) showed its application to bidirectional path tracing and Sun et al.~(#link("<cite:Sun2017>")[2017];) applied it to vertex connection and merging.
][
  Manzi等人（#link("<cite:Manzi2015>")[2015];）展示了其在双向路径追踪中的应用，Sun等人（#link("<cite:Sun2017>")[2017];）将其应用于顶点连接和合并。
]

#parec[
  Petitjean et al.~(#link("<cite:Petitjean2018>")[2018];) used gradient domain techniques to improve spectral rendering.
][
  Petitjean等人（#link("<cite:Petitjean2018>")[2018];）使用梯度域技术改进了光谱渲染。
]

#parec[
  Hua et al.~(#link("<cite:Hua2019>")[2019];) have written a comprehensive survey of work in this area.
][
  Hua等人（#link("<cite:Hua2019>")[2019];）撰写了一篇关于该领域工作的全面综述。
]

#parec[
  Hair is particularly challenging to render; not only is it extremely geometrically complex but multiple scattering among hair also makes a significant contribution to its final appearance.
][
  头发的渲染尤其具有挑战性；它不仅在几何上极其复杂，而且头发之间的多重散射也对其最终外观有显著贡献。
]

#parec[
  Traditional light transport algorithms often have difficulty handling this case well.
][
  传统的光传输算法通常难以很好地处理这种情况。
]

#parec[
  See the papers by Moon and Marschner (#link("<cite:Moon2006>")[2006];), Moon et al.~(#link("<cite:Moon2008>")[2008];), and Zinke et al.~(#link("<cite:Zinke2008>")[2008];) for recent work in specialized rendering algorithms for hair.
][
  请参阅Moon和Marschner（#link("<cite:Moon2006>")[2006];）、Moon等人（#link("<cite:Moon2008>")[2008];）以及Zinke等人（#link("<cite:Zinke2008>")[2008];）关于头发专用渲染算法的最新研究。
]

#parec[
  Yan et al.~(#link("<cite:Yan2017:bssrdf-fur>")[2017b];) have recently demonstrated the effectiveness of models based on diffusion in addressing this problem.
][
  Yan等人（#link("<cite:Yan2017:bssrdf-fur>")[2017b];）最近展示了基于扩散的模型在解决此问题上的有效性。
]

#parec[
  While the rendering problem as discussed so far has been challenging enough, Jarabo et al.~(#link("<cite:Jarabo2014a>")[2014a];) showed the extension of the path integral to not include the steady-state assumption—that is, accounting for the noninfinite speed of light.
][
  虽然到目前为止讨论的渲染问题已经足够具有挑战性，Jarabo等人（#link("<cite:Jarabo2014a>")[2014a];）展示了路径积分的扩展不包括稳态假设——即考虑到光速不是无限的。
]

#parec[
  Time ends up being extremely high frequency, which makes rendering challenging; they showed successful application of density estimation to this problem.
][
  时间最终变得极高频，使得渲染变得更加具有挑战性；他们展示了密度估计在这个问题上的成功应用。
]


