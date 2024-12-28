#import "../template.typ": parec


== Further_Reading

#parec[
  The books written by van de Hulst (1980) and Preisendorfer (1965, 1976) are excellent introductions to volume light transport. The seminal book by Chandrasekhar (1960) is another excellent resource, although it is mathematically challenging.
][
  van de Hulst（1980）和Preisendorfer（1965, 1976）撰写的书籍是体积光传递的优秀入门书籍。Chandrasekhar（1960）的开创性著作是另一个优秀的资源，尽管其数学内容较为复杂。
]

#parec[
  d'Eon's book (2016) has rigorous coverage of this topic and includes extensive references to work in the area. Novák et al.'s report (2018) provides a comprehensive overview of research in volumetric light transport for rendering through 2018; see also the "Further Reading" section of Chapter 14 for more references on this topic.
][
  d'Eon的书（2016）对该主题进行了严格的覆盖，并包括了该领域工作的广泛参考。Novák等人的报告（2018）提供了截至2018年体积光传输渲染研究的全面概述；有关该主题的更多参考，请参见第14章的“进一步阅读”部分。
]

#parec[
  The Henyey–Greenstein phase function was originally described by Henyey and Greenstein (1941). Detailed discussion of scattering and phase functions, along with derivations of phase functions that describe scattering from independent spheres, cylinders, and other simple shapes, can be found in van de Hulst's book (1981). Extensive discussion of the Mie and Rayleigh scattering models is also available there.
][
  Henyey和Greenstein（1941）最初描述了Henyey–Greenstein相位函数。关于散射和相位函数的详细讨论，以及描述独立球体、圆柱体和其他简单形状散射的相位函数的推导，可以在van de Hulst的书（1981）中找到。Mie和Rayleigh散射模型的广泛讨论也可以在那里找到。
]

#parec[
  Hansen and Travis's survey article is also a good introduction to the variety of commonly used phase functions; see also d'Eon's book (2016) for a catalog of useful phase functions and associated sampling techniques.
][
  Hansen和Travis的综述文章也是对常用相位函数种类的良好介绍；另见d'Eon的书（2016），其中包含有用的相位函数和相关采样技术的目录。
]

#parec[
  While the Henyey–Greenstein model often works well, there are many media that it cannot represent accurately. Gkioulekas et al.~(2013a) showed that sums of Henyey–Greenstein and von Mises-Fisher lobes are more accurate for representing scattering in many materials than Henyey–Greenstein alone and derived a 2D parameter space that allows for intuitive control of translucent appearance.
][
  虽然Henyey–Greenstein模型通常效果良好，但有许多介质它无法准确表示。Gkioulekas等人（2013a）表明，Henyey–Greenstein和von Mises-Fisher叶片的和比单独的Henyey–Greenstein更能准确地表示许多材料中的散射，并推导出一个二维参数空间，允许对半透明外观进行直观控制。
]

#parec[
  The paper by Raab et al.~(2006) introduced many important sampling building-blocks for rendering participating media to graphics, including the delta-tracking algorithm for inhomogeneous media. Delta tracking has been independently invented in a number of fields; see both Kutz et al.~(2017) and Kettunen et al.~(2021) for further details of this history.
][
  Raab等人（2006）的论文为图形学中参与介质的渲染引入了许多重要的采样构建块，包括用于不均匀介质的δ追踪算法。δ追踪在许多领域中被独立发明；有关此历史的更多详细信息，请参见Kutz等人（2017）和Kettunen等人（2021）。
]

#parec[
  The ratio tracking algorithm was introduced to graphics by Novák et al.~(2014), though see the discussion in Novák et al.~(2018) for the relationship of this approach to previously developed estimators in neutron transport.
][
  比率追踪算法由Novák等人（2014）引入到图形学中，但请参见Novák等人（2018）中关于这种方法与先前开发的中子传输估计器之间关系的讨论。
]

#parec[
  Novák et al.~(2014) also introduced residual ratio tracking, which makes use of lower bounds on a medium's density to analytically integrate part of the beam transmittance.
][
  Novák等人（2014）还引入了残余比率追踪，它利用介质密度的下限来解析地积分部分光束透射。
]

#parec[
  Kutz et al.~(2017) extended this approach to distance sampling and introduced the integral formulation of transmittance due to Galtier et al.~(2013). Our derivation of the integral transmittance equations (11.10) and (11.13) follows Georgiev et al.~(2019), as does our discussion of connections between those equations and various transmittance estimators.
][
  Kutz等人（2017）将这种方法扩展到距离采样，并引入了Galtier等人（2013）提出的透射积分公式。我们对积分透射方程（11.10）和（11.13）的推导遵循Georgiev等人（2019），我们的讨论也涉及这些方程与各种透射估计器之间的联系。
]

#parec[
  Georgiev et al.~also developed a number of additional estimators for transmittance that can give significantly lower error than the ratio tracking estimator that pbrt uses.
][
  Georgiev等人还开发了许多额外的透射估计器，其误差显著低于#emph[pbrt];使用的比率追踪估计器。
]

#parec[
  Kettunen et al.~(2021) recently developed a significantly improved transmittance estimator with much lower error than previous approaches. Remarkably, their estimator is effectively a combination of uniform ray marching with a correction term that removes bias.
][
  Kettunen等人（2021）最近开发了一种显著改进的透射估计器，其误差远低于以前的方法。值得注意的是，他们的估计器实际上是均匀光线步进与去偏差校正项的结合。
]

#parec[
  For media with substantial variation in density, delta tracking can be inefficient—many small steps must be taken to get through the optically thin sections.
][
  对于密度变化显著的介质，δ追踪可能效率低下——必须采取许多小步骤才能通过光学薄的部分。
]

#parec[
  Danskin and Hanrahan (1992) presented a technique for efficient volume ray marching using a hierarchical data structure. Another way of addressing this issue was presented by Szirmay-Kalos et al.~(2011), who used a grid to partition scattering volumes in cells and applied delta tracking using the majorant of each cell as the ray passed through them.
][
  Danskin和Hanrahan（1992）提出了一种使用分层数据结构进行高效体积光线行进的技术。Szirmay-Kalos等人（2011）提出了另一种解决此问题的方法，他们使用网格将散射体积划分为单元，并在光线穿过它们时应用每个单元的主要值进行δ追踪。
]

#parec[
  This is effectively the approach implemented in pbrt's DDAMajorantIterator. The grid cell traversal algorithm implemented there is due to Cleary and Wyvill (1988) and draws from Bresenham's line drawing algorithm (Bresenham 1965).
][
  这实际上是#emph[pbrt];中DDAMajorantIterator实现的方法。那里实现的网格单元遍历算法源于Cleary和Wyvill（1988），并借鉴了Bresenham的线绘制算法（Bresenham 1965）。
]

#parec[
  Media stored in grids are sometimes tabulated in the camera's projective space, making it possible to have more detail close to the camera and less detail farther away.
][
  存储在网格中的介质有时在相机的投影空间中列出，使得在靠近相机的地方可以有更多细节，而在远处则较少。
]

#parec[
  Gamito has recently developed an algorithm for DDA traversal in this case.
][
  Gamito最近开发了一种用于这种情况下的DDA遍历算法。
]

#parec[
  Yue et al.~(2010) used a kd-tree to store majorants, which was better able to adapt to spatially varying densities than a grid. In follow-on work, they derived an approach to estimate the efficiency of spatial partitionings and used it to construct them more effectively.
][
  Yue等人（2010）使用kd树存储主要值，比网格更能适应空间变化的密度。在后续工作中，他们推导出一种估计空间划分效率的方法，并利用它更有效地构建它们。
]

#parec[
  Because scattering may be sampled rarely in optically thin media, many samples may be necessary to achieve low error. To address this issue, Villemin et al.~proposed increasing the sampling density in such media.
][
  由于在光学稀薄介质中，散射可能很少被采样，因此可能需要许多样本才能达到低误差。为了解决这个问题，Villemin等人建议在这种介质中增加采样密度。
]

#parec[
  Kulla and Fajardo (2012) noted that techniques based on sampling according to transmittance ignore another important factor: spatial variation in the scattering coefficient.
][
  Kulla和Fajardo（2012）指出，基于透射采样的技术忽略了另一个重要因素：散射系数的空间变化。
]

#parec[
  They developed a method based on computing a tabularized 1D sampling distribution for each ray passing through participating media based on the product of beam transmittance and scattering coefficient at a number of points along it. They then drew samples from this distribution, showing good results.
][
  他们开发了一种方法，基于光束透射和沿其路径上多个点的散射系数的乘积，为每个通过参与介质的光线计算一个表格化的一维采样分布。然后他们从这个分布中抽取样本，显示出良好的结果。
]

#parec[
  A uniform grid of sample values as is implemented in GridMedium and RGBGridMedium may consume an excessive amount of memory, especially for media that have not only large empty regions of space but also fine detail in some regions.
][
  如GridMedium和RGBGridMedium中实现的样本值的均匀网格可能会消耗大量内存，特别是对于不仅有大面积空白区域而且在某些区域有细节的介质。
]

#parec[
  This issue is addressed by Museth's VDB format (2013) as well as the Field3D system that was described by Wrenninge (2015), both of which use adaptive hierarchical grids to reduce storage requirements.
][
  Museth的VDB格式（2013）以及Wrenninge（2015）描述的Field3D系统都解决了这个问题，它们都使用自适应分层网格来减少存储需求。
]

#parec[
  pbrt's NanoVDBMedium is based on NanoVDB (Museth 2021), which is a lighterweight version of VDB.
][
  #emph[pbrt];的NanoVDBMedium基于NanoVDB（Museth 2021），这是VDB的轻量级版本。
]

#parec[
  Just as procedural modeling of textures is an effective technique for shading surfaces, procedural modeling of volume densities can be used to describe realistic-looking volumetric objects like clouds and smoke.
][
  正如程序化纹理建模是表面着色的有效技术一样，程序化建模体积密度可以用来描述看起来逼真的体积对象，如云和烟。
]

#parec[
  Perlin and Hoffert (1989) described early work in this area, and the book by Ebert et al.~(2003) has a number of sections devoted to this topic, including further references.
][
  Perlin和Hoffert（1989）描述了该领域的早期工作，Ebert等人（2003）的书中有许多章节专门讨论这个主题，包括进一步的参考。
]

#parec[
  More recently, accurate physical simulation of the dynamics of smoke and fire has led to extremely realistic volume data sets, including the ones used in this chapter; for early work in this area, see for example Fedkiw, Stam, and Jensen (2001).
][
  最近，烟雾和火焰动力学的精确物理模拟导致了极其逼真的体积数据集，包括本章中使用的那些；有关该领域的早期工作，请参见例如Fedkiw、Stam和Jensen（2001）。
]

#parec[
  The book by Wrenninge (2012) has further information about modeling participating media, with particular focus on techniques used in modern feature film production.
][
  Wrenninge（2012）的书中有关于参与介质建模的更多信息，特别关注现代电影制作中使用的技术。
]

#parec[
  For media that are generated through simulations, it may be desirable to account for the variation in the medium over time in order to include the effect of motion blur.
][
  对于通过模拟生成的介质，可能希望考虑介质随时间的变化，以包括运动模糊的效果。
]

#parec[
  Clinton and Elendt (2009) described an approach to do so based on deforming the vertices of the grid that stores the medium, and Kulla and Fajardo (2012) applied Eulerian motion blur, where each grid cell also stores a velocity vector that is used to shift the lookup point based on its time.
][
  Clinton和Elendt（2009）描述了一种基于变形存储介质的网格顶点的方法，Kulla和Fajardo（2012）应用了欧拉运动模糊，其中每个网格单元还存储一个速度向量，用于根据时间移动查找点。
]

#parec[
  Wrenninge described a more efficient approach that instead stores the scattering properties in each cell as a compact time-varying function.
][
  Wrenninge描述了一种更有效的方法，该方法将每个单元中的散射属性存储为紧凑的时间变化函数。
]

#parec[
  In this chapter, we have ignored all issues related to sampling and antialiasing of volume density functions that are represented by samples in a 3D grid, although these issues should be considered, especially in the case of a volume that occupies just a few pixels on the screen.
][
  在本章中，我们忽略了与由3D网格中的样本表示的体积密度函数的采样和抗锯齿相关的所有问题，尽管这些问题应该被考虑，特别是在体积仅占据屏幕上几个像素的情况下。
]

#parec[
  Furthermore, we have used a simple triangle filter to reconstruct densities at intermediate positions, which is suboptimal for the same reasons that the triangle filter is not a high-quality image reconstruction filter.
][
  此外，我们使用了简单的三角形滤波器来重建中间位置的密度，这对于三角形滤波器不是高质量图像重建滤波器的相同原因来说是次优的。
]

#parec[
  Marschner and Lobb (1994) presented the theory and practice of sampling and reconstruction for 3D data sets, applying ideas similar to those in Chapter 8.
][
  Marschner和Lobb（1994）提出了3D数据集的采样和重建理论和实践，应用了类似于第8章中的想法。
]

#parec[
  See also the paper by Theußl, Hauser, and Gröller (2000) for a comparison of a variety of windowing functions for volume reconstruction with the sinc function and a discussion of how to derive optimal parameters for volume reconstruction filter functions.
][
  另见Theußl、Hauser和Gröller（2000）的论文，比较了用于体积重建的各种窗口函数与sinc函数，并讨论了如何为体积重建滤波器函数推导出最佳参数。
]

#parec[
  Hofmann et al.~(2021) noted that sample reconstruction may have a significant performance cost, even with trilinear filtering. They suggested stochastic sample filtering, where a single volume sample is chosen with probability given by its filter weight, and showed performance benefits.
][
  Hofmann等人（2021）指出，即使使用三线性过滤，样本重建也可能具有显著的性能成本。他们建议随机采样滤波，其中根据其滤波器权重选择单个体积样本，并显示出性能优势。
]

#parec[
  However, this approach does introduce bias if a nonlinear function is applied to the sample value (as is the case when estimating transmittance, for example).
][
  然而，如果对样本值应用非线性函数（例如在估计透射时），这种方法确实会引入偏差。
]

#parec[
  Acquiring volumetric scattering properties of real-world objects is particularly difficult, requiring a solution to the inverse problem of determining the values that lead to the measured result.
][
  获取真实世界物体的体积散射属性尤其困难，需要解决逆问题以确定导致测量结果的值。
]

#parec[
  See Jensen et al.~(2001b), Goesele et al.~(2004), Narasimhan et al.~(2006), and Peers et al.~(2006) for work on acquiring scattering properties for subsurface scattering.
][
  有关获取次表面散射散射属性的工作，请参见Jensen等人（2001b）、Goesele等人（2004）、Narasimhan等人（2006）和Peers等人（2006）。
]

#parec[
  More recently, Gkioulekas et al.~(2013b) produced accurate measurements of a variety of media. Hawkins et al.~(2005) have developed techniques to measure properties of media like smoke, acquiring measurements in real time.
][
  最近，Gkioulekas等人（2013b）对各种介质进行了精确测量。Hawkins等人（2005）开发了测量烟雾等介质属性的技术，实时获取测量值。
]

#parec[
  Another interesting approach to this problem was introduced by Frisvad et al.~(2007), who developed methods to compute these properties from a lower-level characterization of the scattering properties of the medium.
][
  Frisvad等人（2007）引入了另一种有趣的方法，他们开发了从介质散射属性的低级别表征中计算这些属性的方法。
]

#parec[
  A comprehensive survey of work in this area was presented by Frisvad et al.~(2020). (See also the discussion of inverse rendering techniques in Section 16.3.1 for additional approaches to these problems.)
][
  Frisvad等人（2020）提供了该领域工作的全面综述。（有关这些问题的其他方法，请参见第16.3.1节中的逆渲染技术讨论。）
]

#parec[
  Acquiring the volumetric density variation of participating media is also challenging. See work by Fuchs et al.~(2007), Atcheson et al.~(2008), and Gu et al.~(2013a) for a variety of approaches to this problem, generally based on illuminating the medium in particular ways while photographing it from one or more viewpoints.
][
  获取参与介质的体积密度变化也具有挑战性。有关解决此问题的各种方法，请参见Fuchs等人（2007）、Atcheson等人（2008）和Gu等人（2013a）的工作，通常基于以特定方式照亮介质，同时从一个或多个视点拍摄照片。
]


