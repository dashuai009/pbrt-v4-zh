#import "../template.typ": parec, ez_caption, source-cite

== #ez_caption[Further Reading][延伸阅读]
#parec[
  #emph[An Introduction to Ray Tracing] has an extensive survey of algorithms for ray-shape intersection (Glassner #source-cite("Glassner:IntroRayTracing")). Goldstein and Nagel (#source-cite("Goldstein71")) discussed ray-quadric intersections, and Heckbert (#source-cite("Heckbert84")) discussed the mathematics of quadrics for graphics applications in detail, with many citations to literature in mathematics and other fields. Hanrahan (#source-cite("Hanrahan83")) described a system that automates the process of deriving a ray intersection routine for surfaces defined by implicit polynomials; his system emits C source code to perform the intersection test and normal computation for a surface described by a given equation. Mitchell (#source-cite("Mitchell90")) showed that interval arithmetic could be applied to develop algorithms for robustly computing intersections with implicit surfaces that cannot be described by polynomials and are thus more difficult to accurately compute intersections for (more recent work in this area was done by Knoll et al.~(#source-cite("Knoll09"))).
][
  #emph[An Introduction to Ray Tracing] 广泛综述了射线与形状的求交算法（Glassner #source-cite("Glassner:IntroRayTracing")）。Goldstein 和 Nagel（#source-cite("Goldstein71")）讨论了射线与二次曲面的求交，Heckbert（#source-cite("Heckbert84")）详细讨论了用于图形应用的二次曲面的数学，并引用了数学和其他领域的许多文献。Hanrahan（#source-cite("Hanrahan83")）描述了一个系统，该系统自动化了为由隐式多项式定义的表面推导射线求交例程的过程；他的系统生成 C 源代码，对给定方程描述的表面执行求交测试并计算法向量。Mitchell（#source-cite("Mitchell90")）说明可以利用区间算术构造稳健的求交算法，处理无法用多项式描述、因而更难准确求交的隐式曲面（Knoll 等人（#source-cite("Knoll09")）在该领域进行了更近期的工作）。
]

#parec[
  Other notable early papers related to ray-shape intersection include Kajiya's (#source-cite("Kajiya83")) work on computing intersections with surfaces of revolution and procedurally generated fractal terrains. Fournier et al.'s (#source-cite("Fournier82")) paper on rendering procedural stochastic models and Hart et al.'s (#source-cite("Hart:1989:RTD")) paper on finding intersections with fractals illustrate the broad range of shape representations that can be used with ray-tracing algorithms.
][
  其他与射线-形状交点相关的重要早期论文包括 Kajiya（#source-cite("Kajiya83")）关于计算与旋转曲面和程序生成的分形地形的交点的工作。Fournier 等人（#source-cite("Fournier82")）关于渲染程序化随机模型的论文和 Hart 等人（#source-cite("Hart:1989:RTD")）关于寻找与分形交点的论文展示了可以与射线追踪算法一起使用的形状表示的广泛范围。
]

#parec[
  The ray-triangle intersection test in Section #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#sec:triangle-mesh")[6.5] was developed by Woop et al.~(#source-cite("Woop2013")). See Möller and Trumbore (#source-cite("Moller97")) for another widely used ray-triangle intersection algorithm. A ray-quadrilateral intersection routine was developed by Lagae and Dutré (#source-cite("Lagae05")). An interesting approach for developing a fast ray-triangle intersection routine was introduced by Kensler and Shirley (#source-cite("Kensler2006")): they implemented a program that performed a search across the space of mathematically equivalent ray-triangle tests, automatically generating software implementations of variations and then benchmarking them. In the end, they found a more efficient ray-triangle routine than had been in use previously.
][
  第 #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#sec:triangle-mesh")[6.5] 节中的射线-三角形求交测试由 Woop 等人（#source-cite("Woop2013")）开发。另一个广泛使用的射线-三角形求交算法请参见 Möller 和 Trumbore（#source-cite("Moller97")）。射线-四边形求交例程由 Lagae 和 Dutré（#source-cite("Lagae05")）开发。Kensler 和 Shirley（#source-cite("Kensler2006")）提出了一种开发快速射线-三角形求交例程的有趣方法：他们实现了一个程序，在数学上等价的射线-三角形测试空间中执行搜索，自动生成变体的软件实现，然后对其进行基准测试。最终，他们发现了一种比以前使用的更高效的射线-三角形例程。
]

#parec[
  Kajiya (#source-cite("Kajiya82")) developed the first algorithm for computing intersections with parametric patches. Subsequent work on more efficient techniques for direct ray intersection with patches includes papers by Stürzlinger (#source-cite("Sturzlinger98")), Martin et al.~(#source-cite("Martin:2000:PRT")), Roth et al.~(#source-cite("Roth01")), and Benthin et al.~(#source-cite("Benthinetal2006")), who also included additional references to previous work. Related to this, Ogaki and Tokuyoshi (#source-cite("Ogaki2011")) introduced a technique for directly intersecting smooth surfaces generated from triangle meshes with per-vertex normals.
][
  Kajiya（#source-cite("Kajiya82")）开发了第一个计算与参数面片交点的算法。后续关于更高效地直接计算射线与面片交点的技术的工作包括 Stürzlinger（#source-cite("Sturzlinger98")）、Martin 等人（#source-cite("Martin:2000:PRT")）、Roth 等人（#source-cite("Roth01")）和 Benthin 等人（#source-cite("Benthinetal2006")）的论文，其中还列出了更多先前工作的参考文献。与此相关，Ogaki 和 Tokuyoshi（#source-cite("Ogaki2011")）介绍了一种技术，用于直接计算射线与由带逐顶点法向量的三角网格生成的光滑曲面的交点。
]

#parec[
  Ramsey et al.~(#source-cite("Ramsey2004")) described an algorithm for computing intersections with bilinear patches, though double-precision computation was required for robust results. Reshetov (#source-cite("Reshetov2019")) derived a more efficient algorithm that operates in single precision; that algorithm is used in `pbrt`'s #link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#BilinearPatch")[BilinearPatch] implementation. See Akenine-Möller et al.~(#source-cite("Moller18")) for explanations of the algorithms used in its implementation that are related to the distance between lines.
][
  Ramsey 等人（#source-cite("Ramsey2004")）描述了一种计算双线性面片交点的算法，尽管需要双精度计算以获得稳健的结果。Reshetov（#source-cite("Reshetov2019")）推导出一种更高效的算法，该算法在单精度下运行；该算法用于 `pbrt` 的 #link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#BilinearPatch")[BilinearPatch] 实现中。有关其中两直线距离相关算法的解释，参见 Akenine-Möller 等人（#source-cite("Moller18")）。
]

#parec[
  Phong and Crow (#source-cite("Phong75sn")) introduced the idea of interpolating per-vertex shading normals to give the appearance of smooth surfaces from polygonal meshes. The use of shading normals may cause rays reflected from a surface to be on the wrong side of the true surface; Reshetov et al.~(#source-cite("Reshetov2010")) described a normal interpolation technique that avoids this problem.
][
  Phong 和 Crow（#source-cite("Phong75sn")）引入了插值每顶点着色法向量的概念，以使多边形网格看起来像光滑表面。使用着色法向量可能使表面反射的射线落在真实表面的错误一侧；Reshetov 等人（#source-cite("Reshetov2010")）描述了一种法向量插值技术，可以避免此问题。
]

#parec[
  The layout of triangle meshes in memory can have a measurable impact on performance. In general, if triangles that are close together in 3D space are close together in memory, cache hit rates will be higher, and overall system performance will benefit. See Yoon et al.~(#source-cite("Yoon05")) and Yoon and Lindstrom (#source-cite("Yoon06")) for algorithms for creating cache-friendly mesh layouts in memory. Relatedly, reducing the storage required for meshes can improve performance, in addition to making it possible to render more complex scenes; see for example Lauterbach et al.~(#source-cite("Lauterbach2008")).
][
  三角网格在内存中的布局会对性能产生可测量的影响。一般来说，如果在 3D 空间中彼此接近的三角形在内存中也彼此接近，则缓存命中率将更高，整体系统性能将受益。有关在内存中创建缓存友好网格布局的算法，请参见 Yoon 等人（#source-cite("Yoon05")）和 Yoon 和 Lindstrom（#source-cite("Yoon06")）。此外，减少网格所需的存储可以提高性能，还可以使渲染更复杂的场景成为可能；例如，请参见 Lauterbach 等人（#source-cite("Lauterbach2008")）。
]

#parec[
  Subdivision surfaces are a widely used representation of smooth surfaces; they were invented by Doo and Sabin (#source-cite("Doo78")) and Catmull and Clark (#source-cite("Catmull78")). Warren's book provides a good introduction to them (Warren #source-cite("Warren02")). Müller et al.~(#source-cite("Muller03")) described an approach that refines a subdivision surface on demand for the rays to be tested for intersection with it, and Benthin et al.~(#source-cite("Benthin2007"), #source-cite("Benthin2015")) described a related approach. A more memory-efficient approach was described by Tejima et al.~(#source-cite("Tejima2015")), who converted subdivision surfaces to Bézier patches and intersected rays with those. Previous editions of this book included a section in this chapter on the implementation of subdivision surfaces, which may also be of interest.
][
  细分曲面是一种广泛使用的光滑表面表示；它们由 Doo 和 Sabin（#source-cite("Doo78")）以及 Catmull 和 Clark（#source-cite("Catmull78")）发明。Warren 的书提供了一个很好的介绍（Warren #source-cite("Warren02")）。Müller 等人（#source-cite("Muller03")）描述了一种方法，该方法根据需要细化细分曲面，以便对需要求交的射线进行测试，Benthin 等人（#source-cite("Benthin2007"), #source-cite("Benthin2015")）描述了一种相关的方法。Tejima 等人（#source-cite("Tejima2015")）描述了一种更节省内存的方法，他们将细分曲面转换为贝塞尔面片，再对射线与这些面片求交。该书的前几版在本章中包含了有关细分曲面实现的部分，可能也会引起兴趣。
]

#parec[
  The curve intersection algorithm in Section #link("https://pbr-book.org/4ed/Shapes/Curves.html#sec:curves")[6.7] is based on the approach developed by Nakamaru and Ohno (#source-cite("Nakamaru2002")). Earlier methods for computing ray intersections with generalized cylinders are also applicable to rendering curves, though they are much less efficient (Bronsvoort and Klok #source-cite("Bronsvoort85"); de Voogt et al.~#source-cite("deVoogt00")). Binder and Keller (#source-cite("Binder2018")) improved the recursive culling of curve intersections using cylinders to bound the curve in place of axis-aligned bounding boxes. Their approach is better suited for GPUs than the current implementation in the #link("https://pbr-book.org/4ed/Shapes/Curves.html#Curve")[Curve] shape, as it uses a compact bit field to record work to be done, in place of recursive evaluation.
][
  第 #link("https://pbr-book.org/4ed/Shapes/Curves.html#sec:curves")[6.7] 节中的曲线求交算法基于 Nakamaru 和 Ohno（#source-cite("Nakamaru2002")）开发的方法。早期计算射线与广义圆柱体交点的方法也适用于渲染曲线，尽管效率低得多（Bronsvoort 和 Klok #source-cite("Bronsvoort85")；de Voogt 等人 #source-cite("deVoogt00")）。Binder 和 Keller（#source-cite("Binder2018")）用圆柱体代替轴对齐包围盒包围曲线，改进了曲线求交时的递归剔除。他们的方法比当前在 #link("https://pbr-book.org/4ed/Shapes/Curves.html#Curve")[Curve] 形状中的实现更适合 GPU，因为它使用紧凑的位字段来记录要完成的工作，而不是递归评估。
]

#parec[
  More efficient intersection algorithms for curves have recently been developed by Reshetov (#source-cite("Reshetov2017")) and Reshetov and Luebke (#source-cite("Reshetov2018")). Related is a tube primitive described by a poly-line with a specified radius at each vertex that Han et al.~(#source-cite("Han2019")) provided an efficient intersection routine for.
][
  最近，Reshetov（#source-cite("Reshetov2017")）和 Reshetov 和 Luebke（#source-cite("Reshetov2018")）开发了更高效的曲线求交算法。相关的是 Han 等人（#source-cite("Han2019")）描述的一个由多段线描述的管状图元，每个顶点具有指定的半径，他们为其提供了一个高效的求交例程。
]

#parec[
  One challenge with rendering thin geometry like hair and fur is that thin geometry may require many pixel samples to be accurately resolved, which in turn increases rendering time. One approach to this problem was described by Qin et al.~(#source-cite("Qin2014")), who used cone tracing for rendering fur, where narrow cones are traced instead of rays. In turn, all the curves that intersect a cone can be considered in computing the cone's contribution, allowing high-quality rendering with a small number of cones per pixel.
][
  渲染细薄几何体如头发和毛皮的一个挑战是，细薄几何体可能需要许多像素样本才能清晰呈现，这反过来又增加了渲染时间。Qin 等人（#source-cite("Qin2014")）描述了一种解决此问题的方法，他们使用锥体追踪来渲染毛皮，其中追踪的是窄锥体而不是射线。这样，所有与锥体相交的曲线都可以在计算锥体的贡献时考虑，从而允许每像素使用少量锥体进行高质量渲染。
]

#parec[
  An excellent introduction to differential geometry was written by Gray (#source-cite("Gray93")); Section 14.3 of his book presents the Weingarten equations.
][
  Gray（#source-cite("Gray93")）撰写了一本关于微分几何的优秀入门书；他的书的第 14.3 节介绍了 Weingarten 方程。
]

=== #ez_caption[Intersection Accuracy][求交精度]

#parec[
  Higham's (#source-cite("Higham2002")) book on floating-point computation is excellent; it also develops the $gamma_n$ notation that we have used in Section #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:fp-error")[6.8]. Other good references to this topic are Wilkinson (#source-cite("Wilkinson1994")) and Goldberg (#source-cite("Goldberg1991")). While we have derived floating-point error bounds manually, see the #emph[Gappa] system by Daumas and Melquiond (#source-cite("Daumas2010")) for a tool that automatically derives forward error bounds of floating-point computations. The #emph[Herbgrind] (Sanchez-Stern et al.~#source-cite("SanchezStern2018")) system implements an interesting approach, automatically finding floating-point computations that suffer from excessive error during the course of a program's execution.
][
  Higham（#source-cite("Higham2002")）关于浮点计算的书非常出色；它还发展了我们在第 #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:fp-error")[6.8] 节中使用的 $gamma_n$ 符号。Wilkinson（#source-cite("Wilkinson1994")）和 Goldberg（#source-cite("Goldberg1991")）是该主题的其他优秀参考。虽然我们手动推导了浮点误差界限，但请参见 Daumas 和 Melquiond（#source-cite("Daumas2010")）的 #emph[Gappa] 系统，该工具自动推导浮点计算的前向误差界限。#emph[Herbgrind]（Sanchez-Stern 等人 #source-cite("SanchezStern2018")）系统实现了一种有趣的方法，自动发现程序执行过程中误差过大的浮点计算。
]

#parec[
  The incorrect self-intersection problem has been a known problem for ray-tracing practitioners for quite some time (Haines #source-cite("Haines89"); Amanatides and Mitchell #source-cite("Amanatides:1990:SRP")). In addition to offsetting rays by an "epsilon" at their origin, approaches that have been suggested include ignoring intersections with the object that was previously intersected; "root polishing" (Haines #source-cite("Haines89"); Woo et al.~#source-cite("Woo:1996:RRB")), where the computed intersection point is refined to become more numerically accurate; and using higher-precision floating-point representations (e.g., `double` instead of `float`).
][
  光线追踪从业者很早就认识到了错误自交的问题（Haines #source-cite("Haines89")；Amanatides 和 Mitchell #source-cite("Amanatides:1990:SRP")）。除了在射线起点偏移一个“epsilon”外，建议的方法还包括忽略与先前相交的对象的交点；“根细化”（Haines #source-cite("Haines89")；Woo 等人 #source-cite("Woo:1996:RRB")），即细化已算出的交点，提高其数值精度；以及使用更高精度的浮点表示（例如，`double` 而不是 `float`）。
]

#parec[
  Kalra and Barr (#source-cite("Kalra89")) and Dammertz and Keller (#source-cite("Dammertz2006")) developed algorithms for numerically robust intersections based on recursively subdividing object bounding boxes, discarding boxes that do not encompass the object's surface, and discarding boxes missed by the ray. Both of these approaches are much less efficient than traditional ray-object intersection algorithms as well as the techniques introduced in Section #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:fp-error")[6.8].
][
  Kalra 和 Barr（#source-cite("Kalra89")）以及 Dammertz 和 Keller（#source-cite("Dammertz2006")）开发了基于递归细分对象包围盒的数值稳健求交算法，剔除不包含对象表面的包围盒以及未被射线穿过的包围盒。这两种方法都比传统的射线-对象求交算法以及第 #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:fp-error")[6.8] 节中介绍的技术效率低得多。
]

#parec[
  Ize showed how to perform numerically robust ray-bounding box intersections (Ize #source-cite("Ize2013")); his approach is implemented in Section #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:conservative-ray-bounds")[6.8.2]. (With a more careful derivation, he showed that a scale factor of $2 gamma_2$ can be used to increase `tMax`, rather than the $2 gamma_3$ we derived.) Wächter (#source-cite("Wachter2008")) discussed self-intersection issues in his thesis; he suggested recomputing the intersection point starting from the initial intersection (root polishing) and offsetting spawned rays along the normal by a fixed small fraction of the intersection point's magnitude. The approach implemented in this chapter uses his approach of offsetting ray origins along the normal but uses conservative bounds on the offsets based on the numerical error present in computed intersection points. (As it turns out, our bounds are generally tighter than Wächter's offsets while also being provably conservative.)
][
  Ize 展示了如何执行数值稳健的射线与包围盒求交（Ize #source-cite("Ize2013")）；他的做法在第 #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:conservative-ray-bounds")[6.8.2] 节中实现。（通过更仔细的推导，他展示了可以使用 $2 gamma_2$ 的比例因子来增加 `tMax`，而不是我们推导的 $2 gamma_3$。）Wächter（#source-cite("Wachter2008")）在他的论文中讨论了自交问题；他建议从初始交点重新计算交点（根细化）并沿法向量偏移生成的射线，偏移量为交点位置向量模长的某个固定小比例。本章实现的方法使用了他的沿法向量偏移射线起点的方法，但使用了基于计算交点中存在的数值误差的偏移保守界限。（事实证明，我们的界限通常比 Wächter 的偏移更紧，同时也是可证明的保守。）
]

#parec[
  The method used for computing accurate discriminants for ray-quadratic intersections in Section #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:accurate-quadratic-discriminants")[6.8.3] is due to Hearn and Baker (#source-cite("Hearn2004")), via Haines et al.~(#source-cite("Haines2019")).
][
  第 #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:accurate-quadratic-discriminants")[6.8.3] 节中用于计算射线与二次曲面求交的准确判别式的方法来自 Hearn 和 Baker（#source-cite("Hearn2004")），本书经由 Haines 等人（#source-cite("Haines2019")）采用该方法。
]

#parec[
  Geometric accuracy has seen much more attention in computational geometry than in rendering. Examples include Salesin et al.~(#source-cite("Salesin1989")), who introduced techniques to derive robust primitive operations for computational geometry that accounted for floating-point round-off error, and Shewchuk (#source-cite("Shewchuk1997")), who applied adaptive-precision floating-point arithmetic to geometric predicates, using just enough precision to compute a correct result for given input values.
][
  在计算几何中，几何精度比在渲染中受到更多关注。例子包括 Salesin 等人（#source-cite("Salesin1989")），他们引入了技术以推导计算几何的稳健基本运算，这些操作考虑了浮点舍入误差，以及 Shewchuk（#source-cite("Shewchuk1997")），他将自适应精度浮点算术应用于几何谓词，仅使用求出给定输入的正确结果所需的精度。
]

#parec[
  The precision requirements of ray tracing have implications beyond practical implementation, which has been our focus. Reif et al.~(#source-cite("Reif1994")) showed how to construct Turing machines based entirely on ray tracing and the geometric optics, which implies that ray tracing is #emph[undecidable] in the sense of complexity theory. Yet in practice, optical computing systems can be constructed, though they are not able to solve undecidable problems. Blakey (#source-cite("Blakey2012")) showed that this can be explained by careful consideration of such optical Turing machines' precision requirements, which can grow exponentially.
][
  射线追踪的精度要求还有超出我们所关注的实际实现层面的含义。Reif 等人（#source-cite("Reif1994")）展示了如何完全基于射线追踪和几何光学构建图灵机，这意味着射线追踪在复杂性理论的意义上是#emph[不可判定的]。然而在实践中，可以构建光学计算系统，尽管它们无法解决不可判定的问题。Blakey（#source-cite("Blakey2012")）展示了这可以通过仔细考虑此类光学图灵机的精度要求来解释，这些要求可能呈指数增长。
]


=== #ez_caption[Sampling Shapes][形状采样]

#parec[
  Turk (#source-cite("Turk1990")) described two approaches for uniformly sampling the surface area of triangles. The approach implemented in #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#SampleUniformTriangle")[`SampleUniformTriangle()`], which is more efficient and better preserves sample stratification than the algorithms given by Turk, is due to Talbot (#source-cite("Talbot2011")) and Heitz (#source-cite("Heitz2019")). Shirley et al.~(#source-cite("Shirley96")) derived methods for sampling a number of other shapes, and Arvo and Novins (#source-cite("Arvo2007")) showed how to sample convex quadrilaterals.
][
  Turk（#source-cite("Turk1990")）描述了均匀采样三角形表面积的两种方法。在#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#SampleUniformTriangle")[`SampleUniformTriangle()`]中实现的方法比Turk给出的算法更高效，并且更好地保持了样本分层性，这归功于Talbot（#source-cite("Talbot2011")）和Heitz（#source-cite("Heitz2019")）。Shirley等人（#source-cite("Shirley96")）推导了采样其他多种形状的方法，而Arvo和Novins（#source-cite("Arvo2007")）展示了如何采样凸四边形。
]

#parec[
  The aforementioned approaches are all based on warping samples from the unit square to the surface of the shape; an interesting alternative was given by Basu and Owen (#source-cite("Basu2015"), #source-cite("Basu2017")), who showed how to recursively decompose triangles and disks to directly generate low-discrepancy points on their surfaces. Marques et al.~(#source-cite("Marques2013")) showed how to generate low-discrepancy samples directly on the unit sphere; see also Christensen's report (#source-cite("Christensen2018:disk")), which shows an error reduction from imposing structure on the distribution of multiple sample points on disk light sources.
][
  上述方法都是基于将样本从单位正方形变换到形状表面；Basu和Owen（#source-cite("Basu2015"), #source-cite("Basu2017")）提出了一种有趣的替代方法，他们展示了如何递归分解三角形和圆盘，以直接在其表面生成低差异度样本点。Marques等人（#source-cite("Marques2013")）展示了如何直接在单位球体表面上生成低差异度样本；另见Christensen的报告（#source-cite("Christensen2018:disk")），该报告展示了通过使圆盘光源上多个样本点的分布具有一定结构来降低误差。
]

#parec[
  Uniformly sampling the visible area of a shape from a reference point is an improvement to uniform area sampling for direct lighting calculations. Gardner et al.~(#source-cite("Gardner87")) and Zimmerman (#source-cite("Zimmerman:1995:DLM")) derived methods to do so for cylinders, and Wang et al.~(#source-cite("Wang2006")) found an algorithm to sample the visible area of cones. (For planar shapes like triangles, the visible area is trivially the entire area.)
][
  从参考点均匀采样形状的可见区域是对直接光照计算中均匀面积采样的改进。Gardner等人（#source-cite("Gardner87")）和Zimmerman（#source-cite("Zimmerman:1995:DLM")）推导了对圆柱体进行此操作的方法，而Wang等人（#source-cite("Wang2006")）找到了一个算法来采样圆锥的可见区域。（对于像三角形这样的平面形状，可见区域显然是整个区域。）
]

#parec[
  Uniform solid angle sampling of shapes has also seen attention by a number of researchers. Wang (#source-cite("Wang1992")) introduced an approach for solid angle sampling of spheres. Arvo showed how to sample the projection of a triangle on the sphere of directions with respect to a reference point (Arvo #source-cite("Arvo1995b")); his approach is implemented in #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#SampleSphericalTriangle")[`SampleSphericalTriangle()`]. (A more efficient approach to solid angle sampling of triangles was recently developed by Peters (#source-cite("Peters2021polygonal"), Section 5).) Ureña et al.~(#source-cite("Urena2013")) and Pekelis and Hery (#source-cite("Pekelis2014")) developed analogous techniques for sampling quadrilateral light sources; Ureña et al.'s method is used in #link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#SampleSphericalRectangle")[`SampleSphericalRectangle()`].
][
  对形状的均匀立体角采样也受到了许多研究人员的关注。Wang（#source-cite("Wang1992")）介绍了一种对球体进行立体角采样的方法。Arvo展示了如何采样三角形相对于参考点在方向球面上的投影（Arvo #source-cite("Arvo1995b")）；他的做法在#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#SampleSphericalTriangle")[`SampleSphericalTriangle()`]中实现。（Peters最近开发了一种更高效的三角形立体角采样方法（#source-cite("Peters2021polygonal"), 第5节）。）Ureña等人（#source-cite("Urena2013")）和Pekelis与Hery（#source-cite("Pekelis2014")）开发了类似的技术用于采样四边形光源；Ureña等人的方法用于#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#SampleSphericalRectangle")[`SampleSphericalRectangle()`]。
]

#parec[
  (To better understand these techniques for sampling projected polygons, Donnay's book on spherical trigonometry provides helpful background (#source-cite("Donnay1945")).) The approach implemented in Section #link("https://pbr-book.org/4ed/Shapes/Spheres.html#sec:sphere-sampling")[6.2.4] to convert an angle $(theta , phi.alt)$ in a cone to a point on a sphere was derived by Akalin (#source-cite("Akalin2015")).
][
  （为了更好地理解这些用于采样投影多边形的技术，Donnay关于球面三角学的书提供了有用的背景知识（#source-cite("Donnay1945")）。）在#link("https://pbr-book.org/4ed/Shapes/Spheres.html#sec:sphere-sampling")[6.2.4]节中实现的将圆锥中的角度 $(theta , phi.alt)$ 转换为球面上的点的方法是由Akalin推导的（#source-cite("Akalin2015")）。
]

#parec[
  The algorithm for inverting the spherical triangle sampling algorithm that is implemented in #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#InvertSphericalTriangleSample")[`InvertSphericalTriangleSample()`] is due to Arvo (#source-cite("Arvo2001:code")).
][
  在#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#InvertSphericalTriangleSample")[`InvertSphericalTriangleSample()`]中实现的球面三角形采样算法的反演算法归功于Arvo（#source-cite("Arvo2001:code")）。
]

#parec[
  Gamito (#source-cite("Gamito2016")) presented an approach for uniform solid angle sampling of disk and cylindrical lights based on bounding the solid angle they subtend in order to fit a quadrilateral, which is then sampled using Ureña et al.'s method (#source-cite("Urena2013")). Samples that do not correspond to points on the light source are rejected. A related approach was developed by Tsai et al.~(#source-cite("Tsai2006")), who approximate shapes with collections of triangles that are then sampled by solid angle. Guillén et al.~(#source-cite("Guillen2017")) subsequently developed an algorithm for directly sampling disks by solid angle that avoids rejection sampling.
][
  Gamito（#source-cite("Gamito2016")）提出了一种对圆盘光源和圆柱光源进行均匀立体角采样的方法：用四边形包围光源张成的立体角，然后使用Ureña等人的方法（#source-cite("Urena2013")）进行采样。不对应于光源上的点的样本将被拒绝。Tsai等人（#source-cite("Tsai2006")）开发了一种相关方法，他们用三角形集合近似形状，然后通过立体角进行采样。Guillén等人（#source-cite("Guillen2017")）随后开发了一种直接通过立体角采样圆盘的算法，避免了拒绝采样。
]

#parec[
  Spheres are the only shapes for which we are aware of algorithms for direct sampling of their projected solid angle. An algorithm to do so was presented by Ureña and Georgiev (#source-cite("Urena2018")). Peters and Dachsbacher developed a more efficient approach (#source-cite("Peters2019")) and Peters (#source-cite("Peters2019:mis")) described how to use this method to compute the PDF associated with a direction so that it can be used with multiple importance sampling.
][
  球体是我们已知的唯一可以直接采样其投影立体角的形状。Ureña和Georgiev（#source-cite("Urena2018")）提出了一种算法。Peters和Dachsbacher开发了一种更高效的方法（#source-cite("Peters2019")），而Peters（#source-cite("Peters2019:mis")）描述了如何使用该方法计算与方向相关的PDF，以便可以与多重重要性采样一起使用。
]

#parec[
  A variety of additional techniques for projected solid angle sampling have been developed. Arvo (#source-cite("Arvo2001")) described a general framework for deriving sampling algorithms and showed its application to projected solid angle sampling of triangles, though numeric inversion of the associated CDF is required. Ureña (#source-cite("Urena2000")) approximated projected solid angle sampling of triangles by progressively decomposing them into smaller triangles until solid angle sampling is effectively equivalent. The approach based on warping uniform samples to approximate projected solid angle sampling that we implemented for triangles and quadrilateral bilinear patches was described by Hart et al.~(#source-cite("Hart2020")). Peters (#source-cite("Peters2021polygonal")) has recently shown how to efficiently and accurately perform projected solid angle sampling of polygons.
][
  已经开发了多种额外的投影立体角采样技术。Arvo（#source-cite("Arvo2001")）描述了一个用于推导采样算法的一般框架，并展示了其在三角形投影立体角采样中的应用，尽管需要对相关的CDF进行数值反演。Ureña（#source-cite("Urena2000")）通过逐步将三角形分解为更小的三角形来近似三角形的投影立体角采样，直到对小三角形进行立体角采样与投影立体角采样实际上等效。我们为三角形和四边形双线性面片实现的基于变换均匀样本来近似投影立体角采样的方法由Hart等人描述（#source-cite("Hart2020")）。Peters（#source-cite("Peters2021polygonal")）最近展示了如何高效且准确地执行多边形的投影立体角采样。
]


