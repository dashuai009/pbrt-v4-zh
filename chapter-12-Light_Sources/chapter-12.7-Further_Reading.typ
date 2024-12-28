#import "../template.typ": parec


== Further_Reading

#parec[
  Warn (#link("<cite:Warn83>")[1983];) developed early models of light sources with nonisotropic emission distributions, including the spotlight model used in this chapter. Verbeck and Greenberg (#link("<cite:Verbeck:1984:ACL>")[1984];) also described a number of techniques for modeling light sources that are now classic parts of the light modeling toolbox. Barzel (#link("<cite:Barzel97>")[1997];) described a highly parameterized model for light sources, including multiple parameters for controlling rate of falloff, the area of space that is illuminated, and so on. Bjorke (#link("<cite:Bjorke01>")[2001];) described a number of additional techniques for shaping illumination for artistic effect. (Many parts of the Barzel and Bjorke approaches are not physically based, however.)
][
  Warn (#link("<cite:Warn83>")[1983];) 开发了早期的光源模型，具有非均匀发射分布，包括本章使用的聚光灯模型。Verbeck 和 Greenberg (#link("<cite:Verbeck:1984:ACL>")[1984];) 也描述了一些用于建模光源的技术，这些技术现在是光建模工具箱的经典部分。Barzel (#link("<cite:Barzel97>")[1997];) 描述了一种高度参数化的光源模型，包括多个参数用于控制衰减率、照亮的空间区域等。Bjorke (#link("<cite:Bjorke01>")[2001];) 描述了许多用于艺术效果的照明塑形的附加技术。（然而，Barzel 和 Bjorke 方法的许多部分并不是基于物理的。）
]

#parec[
  The goniophotometric light source approximation is widely used to model area light sources in the field of illumination engineering. The rule of thumb there is that once a reference point is five times an area light source's radius away from it, a point light approximation has sufficient accuracy for most applications. File format standards have been developed for encoding goniophotometric diagrams for these applications (Illuminating Engineering Society of North America #link("<cite:IESNA2002>")[2002];). Many lighting fixture manufacturers provide data in these formats on their websites.
][
  光度测量光源近似广泛用于照明工程领域的区域光源建模。经验法则是，一旦参考点距离区域光源的半径五倍远，点光源近似对于大多数应用来说就有足够的精度。已经开发了文件格式标准，用于为这些应用编码光度测量图。许多照明设备制造商在其网站上提供这些格式的数据。
]

#parec[
  Ashdown (#link("<cite:Ashdown:1993:NPA>")[1993];) proposed a more sophisticated light source model than goniophotometric; he measured the directional distribution of emitted radiance at a large number of points around a light source and described how to use the resulting 4D table to compute the received radiance distribution at other points. Another generalization of goniometric lights was suggested by Heidrich et al.~(#link("<cite:Heidrich98a>")[1998];), who represented light sources as a 4D exitant lightfield—essentially a function of both position and direction—and showed how to use this representation for rendering. Additional work in this area was done by Goesele et al.~(#link("<cite:Goesele2003>")[2003];) and Mas et al.~(#link("<cite:Mas2008>")[2008];), who introduced a more space-efficient representation and improved rendering efficiency.
][
  Ashdown (#link("<cite:Ashdown:1993:NPA>")[1993];) 提出了一种比光度测量更复杂的光源模型；他在光源周围的多个点测量了发射辐射亮度的方向分布，并描述了如何使用生成的4D表来计算其他点的接收辐射亮度分布。Heidrich 等人 (#link("<cite:Heidrich98a>")[1998];) 提出了光度测量光源的另一种推广，他们将光源表示为4D出射光场（光场）——本质上是位置和方向的函数——并展示了如何使用这种表示进行渲染。Goesele 等人 (#link("<cite:Goesele2003>")[2003];) 和 Mas 等人 (#link("<cite:Mas2008>")[2008];) 在这一领域进行了额外的工作，他们引入了一种更节省空间的表示法并提高了渲染效率。
]

#parec[
  Peters (#link("<cite:Peters2021linear>")[2021a];) has developed efficient techniques for sampling lights defined by lines (i.e., infinitesimally thin cylinders) and shown how to sample the product of lighting and the BRDF using linearly transformed cosines (#link("<cite:Heitz2016>")[Heitz et al.~2016a];).
][
  Peters (#link("<cite:Peters2021linear>")[2021a];) 开发了有效的技术来采样由线（即无限细的圆柱体）定义的光，并展示了如何使用线性变换余弦法采样光与BRDF的乘积 (#link("<cite:Heitz2016>")[Heitz et al.~2016a];)。
]

#parec[
  Real-world light sources are often fairly complex, including carefully designed systems of mirrors and lenses to shape the distribution of light emitted by the light source. (Consider, for example, the headlights on a car, where it is important to evenly illuminate the surface of the road without shining too much light in the eyes of approaching drivers.)
][
  现实世界的光源通常相当复杂，包括精心设计的镜子和透镜系统，以塑造光源发出的光的分布。（例如，考虑汽车的前灯，在那里均匀照亮道路表面而不对迎面而来的司机造成眩光是很重要的。）
]

#parec[
  All the corresponding specular reflection and transmission is challenging for light transport algorithms.
][
  所有相应的镜面反射和透射现象对光传输算法来说都是挑战。
]

#parec[
  It can therefore be worthwhile to do some precomputation to create a representation of light sources' final emission distributions after all of this scattering that is then used as the light source model for rendering. To this end, Kniep et al.~(#link("<cite:Kniep2009>")[2009];) proposed tracing the paths of photons leaving the light's filament until they hit a bounding surface around the light. They then recorded the position and direction of outgoing photons and used this information when computing illumination at points in the scene. Velázquez-Armendáriz et al.~(#link("<cite:Velazquez-Armendariz2015>")[2015];) showed how to compute a set of point lights with directionally varying emission distributions to model emitted radiance from complex light sources. They then approximated the radiance distribution in the light interior using spherical harmonics. More recently, Zhu et al.~(#link("<cite:Zhu2021:luminaires>")[2021];) applied a neural representation to complex lights, encoding lights' radiance distributions and view-dependent sampling distributions and opacities in neural networks.
][
  因此，进行一些预计算以创建光源最终发射分布的表示是值得的，这些分布在所有散射之后被用作渲染的光源模型。为此，Kniep 等人 (#link("<cite:Kniep2009>")[2009];) 提议追踪离开光丝的光子的路径，直到它们撞击光周围的边界表面。他们然后记录出射光子的方向和位置，并在场景中的点计算照明时使用这些信息。Velázquez-Armendáriz 等人 (#link("<cite:Velazquez-Armendariz2015>")[2015];) 展示了如何计算一组具有方向变化发射分布的点光源来建模复杂光源的发射辐射亮度。他们然后使用球谐函数近似光源内部的辐射亮度分布。最近，Zhu 等人 (#link("<cite:Zhu2021:luminaires>")[2021];) 将神经网络表示应用于复杂光源，在神经网络中编码光源的辐射亮度分布和视图相关的采样分布以及不透明度。
]

=== Illumination from Environment Maps
#parec[
  Blinn and Newell (#link("<cite:Blinn76>")[1976];) first introduced the idea of environment maps and their use for simulating illumination, although they only considered illumination of specular objects. Greene (#link("<cite:Greene86b>")[1986];) further refined these ideas, considering antialiasing and different representations for environment maps. Nishita and Nakamae (#link("<cite:Nishita:1986:CTR>")[1986];) developed algorithms for efficiently rendering objects illuminated by hemispherical skylights and generated some of the first images that showed off that distinctive lighting effect. Miller and Hoffman (#link("<cite:Miller84>")[1984];) were the first to consider using arbitrary environment maps to illuminate objects with diffuse and glossy BRDFs. Debevec (#link("<cite:Debevec98>")[1998];) later extended this work and investigated issues related to capturing images of real environments.
][
  Blinn 和 Newell (#link("<cite:Blinn76>")[1976];) 首次引入了环境映射及其用于模拟照明的概念，尽管他们仅考虑了镜面物体的照明。Greene (#link("<cite:Greene86b>")[1986];) 进一步完善了这些想法，考虑了抗锯齿处理和环境映射的不同表示。Nishita 和 Nakamae (#link("<cite:Nishita:1986:CTR>")[1986];) 开发了有效渲染被半球形天窗照亮的物体的算法，并生成了一些首次展示这种独特照明效果的图像。Miller 和 Hoffman (#link("<cite:Miller84>")[1984];) 是第一个考虑使用任意环境映射来照亮具有漫反射和光泽BRDF的物体的人。Debevec (#link("<cite:Debevec98>")[1998];) 后来扩展了这项工作并研究了与捕捉真实环境图像相关的问题。
]

#parec[
  Representing illumination from the sun and sky is a particularly important application of infinite light sources; the "Further Reading" section in Chapter #link("../Light_Transport_II_Volume_Rendering.html#chap:volume-integration")[14] includes a number of references related to simulating skylight scattering. Directly measuring illumination from the sky is also an effective way to find accurate skylight illumination; see Kider et al.~(#link("<cite:Kider2014>")[2014];) for details of a system built to do this.
][
  表示来自太阳和天空的照明是无限光源的一个特别重要的应用；第#link("../Light_Transport_II_Volume_Rendering.html#chap:volume-integration")[14];章的“进一步阅读”部分包括许多与模拟天光散射相关的参考文献。直接测量来自天空的照明也是找到准确天光照明的有效方法；有关构建此类系统的详细信息，请参见 Kider 等人 (#link("<cite:Kider2014>")[2014];)。
]

#parec[
  `pbrt`'s infinite area light source models incident radiance from the light as purely a function of direction. Especially for indoor scenes, this assumption can be fairly inaccurate; position matters as well. Unger et al.~(#link("<cite:Unger2003>")[2003];) captured the incident radiance as a function of direction at many different locations in a real-world scene and used this representation for rendering. Unger et al.~(#link("<cite:Unger2008>")[2008];) improved on this work and showed how to decimate the samples to reduce storage requirements without introducing too much error. Lu et al.~(#link("<cite:Lu2015>")[2015];) developed techniques for efficiently importance sampling these light sources.
][
  `pbrt`的无限面积光源将来自光的入射辐射亮度建模为纯粹是方向的函数。特别是对于室内场景，这种假设可能相当不准确；位置也很重要。Unger 等人 (#link("<cite:Unger2003>")[2003];) 捕捉了在真实世界场景中多个不同位置的入射辐射亮度作为方向的函数，并使用这种表示进行渲染。Unger 等人 (#link("<cite:Unger2008>")[2008];) 改进了这项工作，并展示了如何减少样本以降低存储需求而不引入太多误差。Lu 等人 (#link("<cite:Lu2015>")[2015];) 开发了有效的重要性采样（用于提高采样效率的方法）这些光源的技术。
]

#parec[
  The use of the `allowIncompletePDF` parameter to avoid generating low-probability samples from infinite light sources in the presence of multiple importance sampling is an application of MIS compensation, which was developed by Karlík et al.~(#link("<cite:Karlik2019>")[2019];).
][
  使用`allowIncompletePDF`参数来避免在存在多重重要性采样时从无限光源生成低概率样本是多重重要性采样补偿的一个应用，该补偿由 Karlík 等人 (#link("<cite:Karlik2019>")[2019];) 开发。
]

#parec[
  Subr and Arvo (#link("<cite:Subr07b>")[2007b];) developed an efficient technique for sampling environment map light sources that not only accounts for the \$ \$ term from the scattering equation but also only generates samples in the hemisphere around the surface normal. More recently, Conty Estevez and Lecocq (#link("<cite:Conty2018:product>")[2018];) introduced a technique for sampling according to the product of the BSDF and the environment map based on discretizing the environment map into coarse grids of pixels, conservatively evaluating the maximum of the BSDF over the corresponding sets of directions, and then choosing a region of the environment map according to the product of BSDF and pixel values. Given a selected grid cell, conventional environment map sampling is applied. (See also the "Further Reading" section in Chapter #link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13] for further references to light and BSDF product sampling algorithms.)
][
  Subr 和 Arvo (#link("<cite:Subr07b>")[2007b];) 开发了一种有效的技术，用于采样环境映射光源，不仅考虑了散射方程中的 \$ \$ 项，还仅在表面法线周围的半球内生成样本。最近，Conty Estevez 和 Lecocq (#link("<cite:Conty2018:product>")[2018];) 引入了一种技术，用于根据 BSDF 和环境映射的乘积进行采样，该技术基于将环境映射离散化为粗略的像素网格，保守地评估 BSDF 在相应方向集上的最大值，然后根据 BSDF 和像素值的乘积选择环境映射的一个区域。给定选定的网格单元，应用常规环境映射采样。（另请参见第#link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13];章的“进一步阅读”部分，以获取有关光和 BSDF 乘积采样算法的更多参考。）
]

#parec[
  When environment maps are used for illuminating indoor scenes, many incident directions may be blocked by the building structure. Bitterli et al.~(#link("<cite:Bitterli2015>")[2015];) developed the environment map rectification approach to this problem that we have implemented in the #link("../Light_Sources/Infinite_Area_Lights.html#PortalImageInfiniteLight")[`PortalImageInfiniteLight`];. One shortcoming of Bitterli et al.'s approach is that the image must be rectified for each plane in which there is a portal. Ogaki (#link("<cite:Ogaki2020>")[2020];) addresses this issue by building a BVH over the portals using Conty Estevez and Kulla's light BVH (#link("<cite:Conty2018:bvh>")[2018];) and then decomposing portals into triangles to sample a specific direction according to the environment map.
][
  当环境映射用于照亮室内场景时，许多入射方向可能会被建筑结构阻挡。Bitterli 等人 (#link("<cite:Bitterli2015>")[2015];) 开发了我们在#link("../Light_Sources/Infinite_Area_Lights.html#PortalImageInfiniteLight")[`PortalImageInfiniteLight`];中实现的环境映射校正方法来解决这个问题。Bitterli 等人的方法的一个缺点是图像必须为每个有门户的平面进行图像校正。Ogaki (#link("<cite:Ogaki2020>")[2020];) 通过使用 Conty Estevez 和 Kulla 的光 BVH（包围体层次结构） (#link("<cite:Conty2018:bvh>")[2018];) 构建门户的 BVH，然后将门户分解为三角形以根据环境映射采样特定方向来解决这个问题。
]

#parec[
  Sampling-based approaches can also be used to account for environment map visibility. Bashford-Rogers et al.~(#link("<cite:Bashford-Rogers2013>")[2013];) developed a two-pass algorithm where a first pass from the camera finds directions that reach the environment map; this information is used to create sampling distributions for use in a second rendering pass. Atanasov et al.~(#link("<cite:Atanasov2018>")[2018];) also applied a two-pass algorithm to the task, furthermore discretizing regions of the scene in order to account for different parts of the environment map being visible in different regions of the scene.
][
  基于采样的方法也可以用于考虑环境映射的可见性。Bashford-Rogers 等人 (#link("<cite:Bashford-Rogers2013>")[2013];) 开发了一种两遍算法，其中第一遍从相机找到到达环境映射的方向；此信息用于创建在第二次渲染过程中使用的采样分布。Atanasov 等人 (#link("<cite:Atanasov2018>")[2018];) 也将两遍算法应用于此任务，进一步离散化场景的区域以考虑环境映射的不同部分在场景的不同区域中可见。
]


=== Optimizing Visibility Testing
<optimizing-visibility-testing>


#parec[
  As discussed in Chapter #link("../Shapes.html#chap:shapes")[6];, one way to reduce the time spent tracing shadow rays is to have methods like `Shape::IntersectP()` and `Primitive::IntersectP()` that just check for any occlusion along a ray without bothering to compute the geometric information at the intersection point.
][
  如第#link("../Shapes.html#chap:shapes")[6];章所述，减少追踪阴影光线时间的一种方法是使用像 `Shape::IntersectP()` 和 `Primitive::IntersectP()` 这样的方法，它们只检查光线上的任何遮挡，而不计算交点的几何信息。
]

#parec[
  Another approach for optimizing ray tracing for shadow rays is the #emph[shadow cache];, where each light stores a pointer to the last primitive that occluded a shadow ray to the light. That primitive is checked first to see if it occludes subsequent shadow rays before the ray is passed to the acceleration structure (#link("<cite:Haines86>")[Haines and Greenberg 1986];).
][
  另一种优化阴影光线追踪的方法是#emph[阴影缓存];，其中每个光源存储一个指向最后遮挡光线到光源的基本体的指针。在将光线传递给加速结构之前，首先检查该基本体是否会遮挡后续的阴影光线（#link("<cite:Haines86>")[Haines and Greenberg 1986];）。
]

#parec[
  Pearce (#link("<cite:Pearce91>")[1991];) pointed out that the shadow cache does not work well if the scene has finely tessellated geometry; it may be better to cache the BVH node that held the last occluder, for instance.
][
  Pearce（#link("<cite:Pearce91>")[1991];）指出，如果场景具有精细的镶嵌几何体，阴影缓存效果不佳；例如，缓存持有最后遮挡物的 BVH 节点可能更好。
]

#parec[
  (The shadow cache can similarly be defeated when multiple levels of reflection and refraction are present or when Monte Carlo ray-tracing techniques are used.)
][
  （当存在多个反射和折射层次或使用蒙特卡洛光线追踪技术时，阴影缓存同样可能失效。）
]

#parec[
  Hart et al.~(#link("<cite:Hart99>")[1999];) developed a generalization of the shadow cache that tracks which objects block light from particular light sources and clips their geometry against the light-source geometry so that shadow rays do not need to be traced toward the parts of the light that are certain to be occluded.
][
  Hart 等人（#link("<cite:Hart99>")[1999];）开发了一种阴影缓存的泛化方法，该方法跟踪哪些物体阻挡来自特定光源的光，并将其几何体与光源几何体进行裁剪，以便不必追踪阴影光线到必定被遮挡的光源部分。
]

#parec[
  A related technique, described by Haines and Greenberg (#link("<cite:Haines86>")[1986];), is the #emph[light buffer] for point light sources, where the light discretizes the directions around it and determines which objects are visible along each set of directions (and are thus potential occluding objects for shadow rays).
][
  Haines 和 Greenberg（#link("<cite:Haines86>")[1986];）描述了一种相关技术，即用于点光源的#emph[光缓冲区];，其中光源将其周围的方向离散化，并确定哪些物体在每组方向上可见（因此是阴影光线的潜在遮挡物）。
]

#parec[
  A related optimization is #emph[shaft culling];, which takes advantage of coherence among groups of rays traced in a similar set of directions (e.g., shadow rays from a single point to points on an area light source).
][
  相关的优化是#emph[轴剪裁];，它利用在一组相似方向上追踪的光线组之间的一致性（例如，从单个点到区域光源上点的阴影光线）。
]

#parec[
  With shaft culling, a shaft that bounds a collection of rays is computed and then the objects in the scene that penetrate the shaft are found.
][
  通过轴剪裁，计算出一个包围光线组的轴，然后找到穿透该轴的场景物体。
]

#parec[
  For all the rays in the shaft, it is only necessary to check for intersections with those objects that intersect the shaft, and the expense of ray intersection acceleration structure traversal for each of the rays is avoided (#link("<cite:Haines94>")[Haines and Wallace 1994];).
][
  对于轴中的所有光线，只需检查与那些与轴相交的物体的交点，从而避免为每条光线进行光线交点加速结构遍历的开销（#link("<cite:Haines94>")[Haines and Wallace 1994];）。
]

#parec[
  Woo and Amanatides (#link("<cite:Woo:1990:VOT>")[1990];) classified which lights are visible, not visible, and partially visible in different parts of the scene and stored this information in a voxel-based 3D data structure, using the information to save shadow ray tests.
][
  Woo 和 Amanatides（#link("<cite:Woo:1990:VOT>")[1990];）分类了在场景不同部分中可见、不可见和部分可见的光，并将此信息存储在基于体素的三维数据结构中，利用这些信息节省阴影光线测试。
]

#parec[
  Fernandez, Bala, and Greenberg (#link("<cite:Fernandez:2002:LIE>")[2002];) developed a similar approach based on spatial decomposition that stores references to important blockers in each voxel and also builds up this information on demand during rendering.
][
  Fernandez、Bala 和 Greenberg（#link("<cite:Fernandez:2002:LIE>")[2002];）开发了一种基于空间分解的类似方法，在每个体素中存储重要遮挡物的引用，并在渲染过程中按需构建这些信息。
]

#parec[
  A related approach to reducing the cost of shadow rays is visibility caching, where the point-to-point visibility function's value is cached for clusters of points on surfaces in the scene (Clarberg and Akenine-Möller #link("<cite:Clarberg2008b>")[2008b];; Popov et al.~#link("<cite:Popov2013>")[2013];).
][
  减少阴影光线成本的相关方法是可见性缓存，其中点对点可见性函数的值被缓存用于场景中表面上的点簇（Clarberg 和 Akenine-Möller #link("<cite:Clarberg2008b>")[2008b];；Popov 等人 #link("<cite:Popov2013>")[2013];）。
]

#parec[
  For complex models, simplified versions of their geometry can be used for shadow ray intersections.
][
  对于复杂模型，可以使用其几何体的简化版本进行阴影光线交点计算。
]

#parec[
  For example, the simplification envelopes described by Cohen et al.~(#link("<cite:Cohen96>")[1996];) can create a simplified mesh that bounds a given mesh from both the inside and the outside.
][
  例如，Cohen 等人（#link("<cite:Cohen96>")[1996];）描述的简化包络可以创建一个从内外两侧包围给定网格的简化网格。
]

#parec[
  If a ray misses the mesh that bounds a complex model from the outside or intersects the mesh that bounds it from the inside, then no further shadow processing is necessary.
][
  如果光线未能与从外部包围复杂模型的网格相交或与从内部包围它的网格相交，则不需要进一步的阴影处理。
]

#parec[
  Only the uncertain remaining cases need to be intersected against the full geometry.
][
  只有不确定的剩余情况需要与完整几何体相交。
]

#parec[
  A related technique is described by Lukaszewski (#link("<cite:Lukaszewski01>")[2001];), who uses the Minkowski sum to effectively expand primitives (or bounds of primitives) in the scene so that intersecting one ray against one of these primitives can determine if any of a collection of rays might have intersected the actual primitives.
][
  Lukaszewski（#link("<cite:Lukaszewski01>")[2001];）描述了一种相关技术，他使用 Minkowski 和有效扩展场景中的基本体（或基本体的边界），以便光线与这些基本体之一相交时可以确定是否有一组光线可能与实际基本体相交。
]

#parec[
  The expense of tracing shadow rays to light sources can be significant; a number of techniques have been developed to improve the efficiency of this part of the rendering computation.
][
  追踪阴影光线到光源的开销可能很大；为提高渲染计算这一部分的效率，已经开发了许多技术。
]

#parec[
  Billen et al.~(#link("<cite:Billen2013>")[2013];) tested only a random subset of potential occluders for intersections; a compensation term ensured that the result was unbiased.
][
  Billen 等人（#link("<cite:Billen2013>")[2013];）仅测试了潜在遮挡物的随机子集以进行交点测试；补偿项确保结果无偏。
]

#parec[
  Following work showed how to use simplified geometry for some shadow tests while still computing the correct result overall (Billen et al.~#link("<cite:Billen2014>")[2014];).
][
  后续工作展示了如何在某些阴影测试中使用简化几何体，同时仍然计算出整体正确的结果（Billen 等人 #link("<cite:Billen2014>")[2014];）。
]


==== Many-Light Sampling
<many-light-sampling>
#parec[
  A number of approaches have been developed to efficiently render scenes with hundreds or thousands of light sources. Early work on this problem was done by Ward #link("<cite:Ward91>")[1991] and Shirley et al.~#link("<cite:Shirley96>")[1996];.
][
  已经开发了多种方法来有效地渲染具有数百或数千个光源的场景。Ward #link("<cite:Ward91>")[1991] 和 Shirley 等人 #link("<cite:Shirley96>")[1996] 在这个问题上进行了早期的研究。
]

#parec[
  Wald et al.~#link("<cite:Wald03>")[2003] suggested rendering an image with path tracing and a very low sampling rate (e.g., one path per pixel), recording information about which of the light sources made some contribution to the image. This information is then used to set probabilities for sampling each light.
][
  Wald 等人 #link("<cite:Wald03>")[2003] 建议使用路径追踪法和非常低的采样频率（例如，每像素一条路径）来渲染图像，记录哪些光源对图像有贡献的信息。然后使用这些信息来设置每个光源的采样概率。
]

#parec[
  Donikian et al.~#link("<cite:Donikian2006>")[2006] adaptively found PDFs for sampling lights through an iterative process of taking a number of light samples, noting which ones were effective, and reusing this information at nearby pixels. The "lightcuts" algorithm, described in the "Further Reading" section of Chapter #link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13];, also addresses this problem.
][
  Donikian 等人 #link("<cite:Donikian2006>")[2006] 通过自适应地找到采样光源的概率密度函数 (PDF)，通过迭代过程采集多个光源样本，记录哪些样本有效，并在附近像素中重用这些信息。"lightcuts"算法在第 #link("../Light_Transport_I_Surface_Reflection.html#chap:light-transport")[13] 章的“进一步阅读”部分中也讨论了这个问题。
]

#parec[
  Tokuyoshi and Harada #link("<cite:Tokuyoshi2016>")[2016] organized lights in trees of bounding spheres and stochastically culled them when shading. Conty Estevez and Kulla #link("<cite:Conty2018:bvh>")[2018] organized lights in BVHs and introduced effective approaches for building light BVHs and sampling lights stored in them.
][
  Tokuyoshi 和 Harada #link("<cite:Tokuyoshi2016>")[2016] 将光源组织在包围球的树中，并在着色时随机筛选它们。Conty Estevez 和 Kulla #link("<cite:Conty2018:bvh>")[2018] 将光源组织在 BVH 中，并引入了构建光源 BVH 和采样其中光源的有效方法。
]

#parec[
  `pbrt`'s #link("../Light_Sources/Light_Sampling.html#BVHLightSampler")[BVHLightSampler] is directly based on their approach. The #emph[Iray] renderer uses a BVH in a similar fashion for light sampling #link("<cite:Keller2017>")[Keller et al.~2017];.
][
  `pbrt` 的 #link("../Light_Sources/Light_Sampling.html#BVHLightSampler")[BVHLightSampler] 直接基于他们的方法。#emph[Iray] 渲染器以类似的方式使用 BVH 进行光源采样 #link("<cite:Keller2017>")[Keller et al.~2017];。
]

#parec[
  Conty Estevez and Kulla's approach was subsequently improved by Liu et al.~#link("<cite:Liu2019>")[2019b];, who incorporated the BSDF in the sampling weight computations.
][
  Conty Estevez 和 Kulla 的方法随后被 Liu 等人 #link("<cite:Liu2019>")[2019b] 改进，他们在采样权重计算中结合了双向散射分布函数 (BSDF)。
]

#parec[
  Incorporating light visibility into the sampling process can substantially improve the results. Vévoda et al.~#link("<cite:Vevoda2018>")[2018] clustered lights and tracked visibility to them, applying Bayesian regression to learn how to effectively sample lights.
][
  将光源可见性纳入采样过程可以显著改善结果。Vévoda 等人 #link("<cite:Vevoda2018>")[2018] 对光源进行聚类并跟踪其可见性，应用贝叶斯回归来学习如何有效地采样光源。
]

#parec[
  Guo et al.~#link("<cite:Guo2020>")[2020] cached information about voxel-to-voxel visibility in a discretization of the scene, which can either be used for Russian roulette or for light importance sampling.
][
  Guo 等人 #link("<cite:Guo2020>")[2020] 缓存了场景中体素到体素的可见性信息，这些信息可以用于俄罗斯轮盘（用于减少计算负担的一种随机算法）或光源重要性采样。
]

#parec[
  Bitterli et al.~#link("<cite:Bitterli2020>")[2020] showed how to apply spatial and temporal resampling of light samples that include visibility in order to achieve high-quality results with few shadow rays per pixel.
][
  Bitterli 等人 #link("<cite:Bitterli2020>")[2020] 展示了如何应用包含可见性的光源样本的空间和时间上的重采样，以每像素仅需少量阴影光线实现高质量结果。
]

#parec[
  The "bit trail" technique used to encode the path from the root to each light at the leaves of `pbrt`'s #link("../Light_Sources/Light_Sampling.html#BVHLightSampler")[BVHLightSampler] is due to Laine #link("<cite:Laine2010>")[2010];.
][
  用于编码从根到 `pbrt` 的 #link("../Light_Sources/Light_Sampling.html#BVHLightSampler")[BVHLightSampler] 叶子处每个光源路径的“位路径”技术归功于 Laine #link("<cite:Laine2010>")[2010];。
]
