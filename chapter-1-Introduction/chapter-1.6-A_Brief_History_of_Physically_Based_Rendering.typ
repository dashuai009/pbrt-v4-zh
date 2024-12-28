#import "../template.typ": parec, ez_caption

== A Brief History of Physically Based Rendering
<a-brief-history-of-physically-based-rendering>

#parec[
  Through the early years of computer graphics in the 1970s, the most important problems to solve were fundamental issues like visibility algorithms and geometric representations. When a megabyte of RAM was a rare and expensive luxury and when a computer capable of a million floating-point operations per second cost hundreds of thousands of dollars, the complexity of what was possible in computer graphics was correspondingly limited, and any attempt to accurately simulate physics for rendering was infeasible.
][
  在计算机图形学的早期，即20世纪70年代，最重要的问题是解决诸如可见性算法和几何表示等基本问题。当时，一个兆字节的RAM是稀有且昂贵的奢侈品，而能够每秒进行百万次浮点运算的计算机要花费几十万美元，因此当时计算机图形学的可能性极其有限，任何尝试准确模拟物理进行渲染的努力都是不可行的。
]


#parec[
  As computers have become more capable and less expensive, it has become possible to consider more computationally demanding approaches to rendering, which in turn has made physically based approaches viable. This progression is neatly explained by #emph[Blinn's law]: “as technology advances, rendering time remains constant.”
][
  随着计算机能力的增强和价格的降低，能够考虑更具计算要求的方法进行渲染，从而使基于物理的方法成为可能。这一进程由#emph[Blinn定律]很好地解释：“随着技术的进步，渲染时间保持不变。”
]



#parec[
  Jim Blinn's simple statement captures an important constraint: given a certain number of images that must be rendered (be it a handful for a research paper or over a hundred thousand for a feature film), it is only possible to take so much processing time for each one. One has a certain amount of computation available and one has some amount of time available before rendering must be finished, so the maximum computation per image is necessarily limited.
][
  Jim Blinn的简单陈述体现了一个重要的限制条件：给定要渲染的图片数量（无论是为研究论文渲染的几张图片，还是为电影渲染的几十万张图片），每张需要花费的处理时间只能如此。可以利用的计算能力有限，渲染必须在一定时间内完成，因此每张图片的最大计算能力必然是有限的。
]


#parec[
  Blinn's law also expresses the observation that there remains a gap between the images people would like to be able to render and the images that they can render: as computers have become faster, content creators have continued to use increased computational capability to render more complex scenes with more sophisticated rendering algorithms, rather than rendering the same scenes as before, just more quickly. Rendering continues to consume all computational capabilities made available to it.
][
  Blinn定律也表达了这样一种观察：人们想要渲染的图像和他们能够渲染的图像之间仍然存在差距：随着计算机变得更快，内容创作者继续利用增加的计算能力使用复杂的渲染算法来渲染更复杂的场景，而不是以更快的速度渲染相同的场景。渲染继续消耗提供给它的所有计算能力。
]

=== Research
<research>

#parec[
  Physically based approaches to rendering started to be seriously considered by graphics researchers in the 1980s. Whitted's paper (#link("Further_Reading.html#cite:Whitted80")[1980];) introduced the idea of using ray tracing for global lighting effects, opening the door to accurately simulating the distribution of light in scenes. The rendered images his approach produced were markedly different from any that had been seen before, which spurred excitement about this approach.
][
  在20世纪80年代，图形研究者开始认真考虑基于物理的渲染方法。Whitted的论文（#link("Further_Reading.html#cite:Whitted80")[1980];）引入了使用光线追踪进行全局光效应的思想，开启了准确模拟场景中光线分布的大门。他的方法生成的渲染图像与之前所见的任何图像显著不同，这激发了人们对此方法的兴趣。
]

#parec[
  Another notable early advancement in physically based rendering was Cook and Torrance's reflection model (#link("Further_Reading.html#cite:Cook81")[1981];,#link("Further_Reading.html#cite:Cook82")[1982];), which introduced microfacet reflection models to graphics. Among other contributions, they showed that accurately modeling microfacet reflection made it possible to render metal surfaces accurately; metal was not well rendered by earlier approaches.
][
  基于物理的渲染早期的另一个显著进展是Cook和Torrance的反射模型（#link("Further_Reading.html#cite:Cook81")[1981];，#link("Further_Reading.html#cite:Cook82")[1982];），该模型将微表面反射模型引入图形学。除其他贡献外，他们展示了准确建模微表面反射可以准确渲染金属表面；早期的方法无法很好地渲染金属。
]

#parec[
  Shortly afterward, Goral et al.(#link("Further_Reading.html#cite:Goral1984")[1984];) made connections between the thermal transfer literature and rendering, showing how to incorporate global diffuse lighting effects using a physically based approximation of light transport. This method was based on finite-element techniques, where areas of surfaces in the scene exchanged energy with each other. This approach came to be referred to as “radiosity,” after a related physical unit. Following work by Cohen and Greenberg (#link("Further_Reading.html#cite:Cohen1985")[1985];) and Nishita and Nakamae (#link("Further_Reading.html#cite:Nishita1985")[1985];) introduced important improvements. Once again, a physically based approach led to images with lighting effects that had not previously been seen in rendered images, which led to many researchers pursuing improvements in this area.
][
  不久之后，Goral等人（#link("Further_Reading.html#cite:Goral1984")[1984];）将热传递文献与渲染联系起来，展示了如何使用基于物理的光传输逼近方法整合全局漫反射光效应。该方法基于有限元技术，场景中表面积的区域相互交换能量。这种方法被称为“辐射度”，命名来源于一个相关的物理单位。接下来的工作中，Cohen和Greenberg（#link("Further_Reading.html#cite:Cohen1985")[1985];）以及Nishita和Nakamae（#link("Further_Reading.html#cite:Nishita1985")[1985];）介绍了重要的改进。再次，基于物理的方法创造了光效应图像，这些在之前的渲染图像中从未见过，导致许多研究人员追求这一领域的改进。
]

#parec[
  While the radiosity approach was based on physical units and conservation of energy, in time it became clear that it would not lead to practical rendering algorithms: the asymptotic computational complexity was a difficult-to-manage $O(n^2)$, and it was necessary to retessellate geometric models along shadow boundaries for good results; researchers had difficulty developing robust and efficient tessellation algorithms for this purpose. Radiosity's adoption in practice was limited.
][
  尽管辐射度方法基于物理单位和能量守恒，但随着时间的推移，显然它不会导致实际渲染算法：其渐近计算复杂度是一个难以管理的 $O(n^2)$，并且为了获得良好结果，需要沿阴影边界重新镶嵌几何模型；研究人员在为此目的开发稳健且高效的镶嵌算法时遇到了困难。辐射度的方法在实际中的采用受到限制。
]

#parec[
  During the radiosity years, a small group of researchers pursued physically based approaches to rendering that were based on ray tracing and Monte Carlo integration. At the time, many looked at their work with skepticism; objectionable noise in images due to Monte Carlo integration error seemed unavoidable, while radiosity-based methods quickly gave visually pleasing results, at least on relatively simple scenes.
][
  在辐射度的年代，一小群研究人员追求基于物理的渲染方法，这些方法基于光线追踪和蒙特卡罗积分。那时，很多人对他们的工作持怀疑态度；由于蒙特卡罗积分误差，图像中令人讨厌的噪声似乎是不可避免的，而基于辐射度的方法则可以快速地在相对简单的场景中提供视觉上令人愉悦的结果。
]

#parec[
  In 1984, Cook, Porter, and Carpenter introduced distributed ray tracing, which generalized Whitted's algorithm to compute motion blur and defocus blur from cameras, blurry reflection from glossy surfaces, and illumination from area light sources (Cook et~al.~#link("Further_Reading.html#cite:Cook84")[1984];), showing that ray tracing was capable of generating a host of important soft lighting effects.
][
  1984年，Cook、Porter和Carpenter介绍了分布式光线追踪，该方法将Whitted的算法推广以计算运动模糊和相机对焦模糊、光滑表面的模糊反射以及来自区域光源的照明（Cook 等人，#link("Further_Reading.html#cite:Cook84")[1984年];），表明光线追踪能够生成一系列重要的柔和照明效果。
]

#parec[
  Shortly afterward, Kajiya (#link("Further_Reading.html#cite:Kajiya86")[1986];) introduced path tracing; he set out a rigorous formulation of the rendering problem (the light transport integral equation) and showed how to apply Monte Carlo integration to solve it. This work required immense amounts of computation: to render a \\(256 \\times 256\\) pixel image of two spheres with path tracing required 7 hours of computation on an IBM 4341 computer, which cost roughly \$280,000 when it was first released (Farmer~#link("Further_Reading.html#cite:Farmer1981")[1981];). With von Herzen, Kajiya also introduced the volume-rendering equation to graphics (Kajiya and von Herzen #link("Further_Reading.html#cite:Kajiya84")[1984];); this equation describes the scattering of light in participating media.
][
  不久之后，Kajiya（#link("Further_Reading.html#cite:Kajiya86")[1986年];）引入了路径追踪；他对渲染问题（光传输积分方程）进行严格的表述，并展示如何应用蒙特卡罗积分进行求解。此工作需要大量的计算：在一台IBM 4341计算机上用路径追踪渲染两球的 $256 times 256$ 像素图像需要7小时的计算，该机器首次发布时大约售价为28万美元（Farmer，#link("Further_Reading.html#cite:Farmer1981")[1981年];）。与von Herzen一起，Kajiya还将体渲染方程引入了图形学（Kajiya和von Herzen#link("Further_Reading.html#cite:Kajiya84")[1984年];）；该方程描述了参与介质中的光散射。
]

#parec[
  Both Cook et~al.'s and Kajiya's work once again led to images unlike any that had been seen before, demonstrating the value of physically based methods. In subsequent years, important work on Monte Carlo for realistic image synthesis was described in papers by Arvo and Kirk (#link("Further_Reading.html#cite:Arvo90pt")[1990];) and Kirk and Arvo (#link("Further_Reading.html#cite:Kirk91")[1991];). Shirley's Ph.D. dissertation (#link("Further_Reading.html#cite:Shirley90phd")[1990];) and follow-on work by Shirley et al.(#link("Further_Reading.html#cite:Shirley96")[1996];) were important contributions to Monte Carlo–based efforts. Hall's book,#emph[Illumination and Color in Computer Generated Imagery] (#link("Further_Reading.html#cite:Hall89")[1989];), was one of the first books to present rendering in a physically based framework, and Andrew Glassner's #emph[Principles of Digital Image Synthesis] laid out foundations of the field (#link("Further_Reading.html#cite:Glassner:PODIS")[1995];). Ward's #emph[Radiance] rendering system was an early open source physically based rendering system, focused on lighting design (Ward~#link("Further_Reading.html#cite:Ward94")[1994];), and Slusallek's #emph[Vision] renderer was designed to bridge the gap between physically based approaches and the then widely used #emph[RenderMan] interface, which was not physically based (Slusallek~#link("Further_Reading.html#cite:SlusallekThesis")[1996];).
][
  Cook等人的工作和Kajiya的工作再次产生了前所未见的图像，展示了基于物理方法的价值。在随后的几年里，Arvo和Kirk（#link("Further_Reading.html#cite:Arvo90pt")[1990年];）以及Kirk和Arvo（#link("Further_Reading.html#cite:Kirk91")[1991年];）的论文描述了蒙特卡罗用于真实图像合成的重要工作。Shirley的博士论文（#link("Further_Reading.html#cite:Shirley90phd")[1990年];）以及Shirley等人的后续工作（#link("Further_Reading.html#cite:Shirley96")[1996年];）是蒙特卡罗探索的重要贡献。Hall的书《计算机生成图像中的照明和色彩》（#link("Further_Reading.html#cite:Hall89")[1989年];）是最早展示物理基础渲染框架的书籍之一，而Andrew Glassner的《数字图像合成原理》(#link("Further_Reading.html#cite:Glassner:PODIS")[1995年];)奠定了该领域的基础。Ward的渲染系统是一个早期的开源物理基础渲染系统，专注于照明设计（Ward，#link("Further_Reading.html#cite:Ward94")[1994年];），而Slusallek的渲染器旨在介于物理基础方法与当时广泛使用的非物理基础接口之间的差距（Slusallek，#link("Further_Reading.html#cite:SlusallekThesis")[1996年];）。
]

#parec[
  Following Torrance and Cook's work, much of the research in the Program of Computer Graphics at Cornell University investigated physically based approaches. The motivations for this work were summarized by Greenberg et al.(#link("Further_Reading.html#cite:Greenberg:1997:AFF")[1997];), who made a strong argument for a physically accurate rendering based on measurements of the material properties of real-world objects and on deep understanding of the human visual system.
][
  在Torrance和Cook工作的推动下，康奈尔大学计算机图形学项目中的许多研究调查了物理基础的方法。Greenberg等人（#link("Further_Reading.html#cite:Greenberg:1997:AFF")[1997];）总结了这项工作的动机，他们基于对现实世界物体材料属性的测量和对人类视觉系统的深刻理解，强烈支持物理准确渲染。
]

#parec[
  A crucial step forward for physically based rendering was Veach's work, described in detail in his dissertation (Veach~#link("Further_Reading.html#cite:VeachThesis")[1997];). Veach advanced key theoretical foundations of Monte Carlo rendering while also developing new algorithms like multiple importance sampling, bidirectional path tracing, and Metropolis light transport that greatly improved its efficiency. Using Blinn's law as a guide, we believe that these significant improvements in efficiency were critical to practical adoption of these approaches.
][
  物理基础渲染的一个关键进展是Veach的工作，在他的论文中详细描述（Veach，#link("Further_Reading.html#cite:VeachThesis")[1997年];）。Veach在推进蒙特卡罗渲染的关键理论基础的同时，还开发了新算法，如多重重要性采样、双向路径追踪和Metropolis光传输，大大提高了其效率。以Blinn定律为指导，我们相信这些效率的显著改善对这些方法的实际采用至关重要。
]

#parec[
  Around this time, as computers became faster and more parallel, a number of researchers started pursuing real-time ray tracing; Wald, Slusallek, and Benthin wrote an influential paper that described a highly optimized ray tracer that was much more efficient than previous ray tracers (Wald et~al.~#link("Further_Reading.html#cite:Wald01b")[2001b];). Many subsequent papers introduced increasingly more efficient ray-tracing algorithms. Though most of this work was not physically based, the results led to great progress in ray-tracing acceleration structures and performance of the geometric components of ray tracing. Because physically based rendering generally makes substantial use of ray tracing, this work has in turn had the same helpful effect as faster computers have, making it possible to render more complex scenes with physical approaches.
][
  大约在这时，随着计算机变得更快和更具并行性，一些研究人员开始追求实时光线追踪；Wald、Slusallek和Benthin撰写了一篇具有影响力的论文，描述了一种高度优化的光线追踪器，比以前的光线追踪器效率高得多（Wald 等人，#link("Further_Reading.html#cite:Wald01b")[2001b年];）。许多后续论文介绍了越来越高效的光线追踪算法。尽管大多数工作不是基于物理的，但结果在光线追踪加速结构和光线追踪几何组件性能方面取得了很大进展。由于物理基础渲染通常大量使用光线追踪，这项工作同样产生了与更快的计算机相同的积极效果，使得用物理方法渲染更复杂的场景成为可能。
]

#parec[
  We end our summary of the key steps in the research progress of physically based rendering at this point, though much more has been done. The “Further Reading” sections in all the subsequent chapters of this book cover this work in detail.
][
  我们在此结束对物理基础渲染研究进展关键步骤的总结，尽管还有更多工作已完成。本书所有后续章节中的“进一步阅读”部分将详细介绍这些工作。
]

=== Production
<production>


#parec[
  With more capable computers in the 1980s, computer graphics could start to be used for animation and film production. Early examples include Jim Blinn's rendering of the #emph[Voyager~2] flyby of Saturn in 1981 and visual effects in the movies #emph[Star Trek II: The Wrath of Khan] (1982),#emph[Tron] (1982), and #emph[The Last Starfighter] (1984).
][
  由于20世纪80年代计算机能力的提升，计算机图形学开始用于动画和电影制作。早期的例子包括Jim Blinn在1981年对#emph[旅行者2号];飞越土星的渲染，以及电影#emph[星际旅行II：可汗之怒];（1982年）、#emph[电子世界争霸战];（1982年）和#emph[最后的星际战士];（1984年）中的视觉效果。
]

#parec[
  In early production use of computer-generated imagery, rasterization-based rendering (notably, the Reyes algorithm (Cook et al.~#link("Further_Reading.html#cite:Cook87")[1987];)) was the only viable option. One reason was that not enough computation was available for complex reflection models or for the global lighting effects that physically based ray tracing could provide. More significantly, rasterization had the important advantage that it did not require that the entire scene representation fit into main memory.
][
  在早期的计算机生成图像制作中，基于栅格化的渲染（特别是Reyes算法（Cook等人，#link("Further_Reading.html#cite:Cook87")[1987年];））是唯一可行的选择。原因之一是没有足够的计算能力用于复杂的反射模型或基于物理的光线追踪提供的全局光效应。更重要的是，栅格化具有不要求整个场景表示适合主内存的重要优势。
]

#parec[
  When RAM was much less plentiful, almost any interesting scene was too large to fit into main memory. Rasterization-based algorithms made it possible to render scenes while having only a small subset of the full scene representation in memory at any time. Global lighting effects are difficult to achieve if the whole scene cannot fit into main memory; for many years, with limited computer systems, content creators effectively decided that geometric and texture complexity was more important to visual realism than lighting complexity (and in turn physical accuracy).
][
  当RAM非常稀缺时，几乎任何有趣的场景都太大而无法适应主内存。基于栅格化的算法使得可以在内存中仅具有完整场景表示的一小部分时渲染场景。如果整个场景不能适合主内存，全局光效应难以实现；多年来，面对有限的计算机系统，内容创作者有效地决定几何形状和纹理复杂度对视觉真实感比光照复杂性（以及进一步的物理准确性）更重要。
]

#parec[
  Many practitioners at this time also believed that physically based approaches were undesirable for production: one of the great things about computer graphics is that one can cheat reality with impunity to achieve a desired artistic effect. For example, lighting designers on regular movies often struggle to place light sources so that they are not visible to the camera or spend considerable effort placing a light to illuminate an actor without shining too much light on the background. Computer graphics offers the opportunity to, for example, implement a light source model that shines twice as much light on a character as on a background object. For many years, this capability seemed much more useful than physical accuracy.
][
  当时许多从业者也认为，基于物理的方法不适合制作：计算机图形学的一大好处在于，可以不受惩罚地作弊以获得理想的艺术效果。例如，在普通电影中，灯光设计师常常要努力放置光源，使其不被摄像机拍到，或付出巨大努力以便照亮演员而不在背景上投射过多光线。计算机图形学提供了这样的机会，例如，可以实现一个光源模型，使其在角色上发射的光比背景对象上的光多一倍。多年来，这种能力似乎比物理准确性更有用。
]

#parec[
  Visual effects practitioners who had the specific need to match rendered imagery to filmed real-world environments pioneered capturing real-world lighting and shading effects and were early adopters of physically based approaches in the late 1990s and early 2000s.(See Snow (#link("Further_Reading.html#cite:Snow2010")[2010];) for a history of ILM's early work in this area, for example.)
][
  具有使渲染图像匹配拍摄的真实世界环境的特定需求的视觉效果从业者开创了捕捉现实世界的光照和阴影效果的先河，并在20世纪90年代末和21世纪初成为基于物理方法的早期采用者。（例如，参见Snow（#link("Further_Reading.html#cite:Snow2010")[2010年];）对ILM在这一领域早期工作的历史进行了解。）
]

#parec[
  During this time, Blue Sky Studios adopted a physically based pipeline (Ohmer~#link("Further_Reading.html#cite:Ohmer1997")[1997];). The photorealism of an advertisement they made for a Braun shaver in 1992 caught the attention of many, and their short film,#emph[Bunny];, shown in 1998, was an early example of Monte Carlo global illumination used in production. Its visual look was substantially different from those of films and shorts rendered with Reyes and was widely noted. Subsequent feature films from Blue Sky also followed this approach. Unfortunately, Blue Sky never published significant technical details of their approach, limiting their wider influence.
][
  在此期间，Blue Sky Studios采用了基于物理的管道（Ohmer，#link("Further_Reading.html#cite:Ohmer1997")[1997年];）。他们1992年为博朗剃须刀制作的广告的照片真实感引起了许多人的注意，他们1998年上映的短片#emph[Bunny];是蒙特卡罗全局光照在制作中的早期例子。它的视觉外观与Reyes渲染的电影和短片截然不同，并被广泛注意。Blue Sky后来的故事片也采用了这种方法。不幸的是，Blue Sky从未公布他们方法的显著技术细节，限制了它们更广泛的影响。
]

#parec[
  During the early 2000s, the #emph[mental ray] ray-tracing system was used by a number of studios, mostly for visual effects. It was an efficient ray tracer with sophisticated global illumination algorithm implementations. The main focus of its developers was computer-aided design and product design applications, so it lacked features like the ability to handle extremely complex scenes and the enormous numbers of texture maps that film production demanded.
][
  在2000年代初期，#emph[mental
ray];光线追踪系统被多家工作室使用，主要用于视觉效果。它是一个高效的光线追踪器，具有复杂的全局光照算法实现。其开发者的主要焦点是计算机辅助设计和产品设计应用，因此缺乏处理极其复杂场景和电影制作需求的海量纹理图的能力等特性。
]

#parec[
  After #emph[Bunny];, another watershed moment came in 2001, when Marcos Fajardo came to the SIGGRAPH conference with an early version of his #emph[Arnold] renderer. He showed images in the Monte Carlo image synthesis course that not only had complex geometry, textures, and global illumination but also were rendered in tens of minutes. While these scenes were not of the complexity of those used in film production at the time, his results showed many the creative opportunities from the combination of global illumination and complex scenes.
][
  在#emph[Bunny];之后，另一个分水岭时刻出现在2001年，当时Marcos Fajardo带着他#emph[Arnold];渲染器的早期版本来到SIGGRAPH大会。他在蒙特卡罗图像合成课程中展示了不仅具有复杂几何、纹理和全局光照，还能在几十分钟内渲染完成的图像。虽然这些场景的复杂程度不及当时电影制作使用的场景，但他的结果表明了全局光照与复杂场景结合带来的许多创造性机会。
]

#parec[
  Fajardo brought #emph[Arnold] to Sony Pictures Imageworks, where work started to transform it to a production-capable physically based rendering system. Many issues had to be addressed, including efficient motion blur, programmable shading, support for massively complex scenes, and deferred loading of scene geometry and textures.#emph[Arnold] was first used on the movie #emph[Monster House] and is now available as a commercial product.
][
  Fajardo将#emph[Arnold];带到索尼影像制作公司，在那里开始将其转化为可投入制作的物理基础渲染系统。许多问题需要解决，包括高效的运动模糊、可编程的着色、大规模复杂场景的支持和场景几何和纹理的延迟加载。#emph[Arnold];首次用于电影#emph[怪兽屋];，现已作为商业产品提供。
]

#parec[
  In the early 2000s, Pixar's #emph[RenderMan] renderer started to support hybrid rasterization and ray-tracing algorithms and included a number of innovative algorithms for computing global illumination solutions in complex scenes.#emph[RenderMan] was recently rewritten to be a physically based ray tracer, following the general system architecture of `pbrt` (Christensen~#link("Further_Reading.html#cite:Christensen2015")[2015];).
][
  在2000年代初期，皮克斯的#emph[RenderMan];渲染器开始支持混合栅格化和光线追踪算法，并包含了一些用于计算复杂场景中全局光照解决方案的创新算法。#emph[RenderMan];最近被重写为物理基础光线追踪器，遵循`pbrt`的一般系统体系结构（Christensen，#link("Further_Reading.html#cite:Christensen2015")[2015年];）。
]

#parec[
  One of the main reasons that physically based Monte Carlo approaches to rendering have been successful in production is that they end up improving the productivity of artists. These have been some of the important factors:
][
  物理基础蒙特卡罗渲染方法在制作中取得成功的一个主要原因是，它们最终提升了艺术家的生产力。这些是一些重要因素：
]

#parec[
  - The algorithms involved have essentially just a single quality knob: how many samples to take per pixel; this is extremely helpful for artists. Ray-tracing algorithms are also suited to both progressive refinement and quickly computing rough previews by taking just a few samples per pixel; rasterization-based renderers do not have equivalent capabilities.
][
  - 所涉及的算法基本上只有一个质量控制点：每像素取样多少；这对艺术家非常有帮助。光线追踪算法也适合逐步精细化，并通过每像素仅取少量样本快速计算粗略预览；基于栅格化的渲染器没有同等能力。
]

#parec[
  - Adopting physically based reflection models has made it easier to design surface materials. Earlier, when reflection models that did not necessarily conserve energy were used, an object might be placed in a single lighting environment while its surface reflection parameters were adjusted. The object might look great in that environment, but it would often appear completely wrong when moved to another lighting environment because surfaces were reflecting too little or too much energy: surface properties had been set to unreasonable values.
][
  - 采用基于物理的反射模型使得设计表面材料更容易。早期，当使用不一定守恒能量的反射模型时，一个物体可能放在一个单一的光照环境中，而其表面反射参数被调整。该物体可能在该环境下看起来很棒，但在移到另一光照环境中时经常会看起来完全不对，因为表面反射的能量过少或过多：表面属性设置为不合理的值。
]

#parec[
  - The quality of shadows computed with ray tracing is much better than it is with rasterization. Eliminating the need to tweak shadow map resolutions, biases, and other parameters has eliminated an unpleasant task of lighting artists. Further, physically based methods bring with them bounce lighting and other soft-lighting effects from the method itself, rather than as an artistically tuned manual process.
][
  - 使用光线追踪计算的阴影质量远好于栅格化。消除调整阴影贴图分辨率、偏置和其他参数的需求已消除了照明艺术家的一个烦人的任务。此外，基于物理的方法本身带来了反弹光照和其他柔和光照效果，而不是作为艺术上调整的手动过程。
]

#parec[
  As of this writing, physically based rendering is used widely for producing computer-generated imagery for movies; @fig:gravity and @fig:alita show images from two recent movies that used physically based approaches.
][
  在本文撰写之时，基于物理的渲染广泛用于制作电影的计算机生成图像；@fig:gravity 和 @fig:alita 展示了两部最近使用基于物理方法制作的电影的图像。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f21.svg"),
  caption: [
    #ez_caption[
      #emph[Gravity] (2013) featured spectacular
      computer-generated imagery of a realistic space environment with
      volumetric scattering and large numbers of anisotropic metal surfaces.
      The image was generated using #emph[Arnold,] a physically based
      rendering system that accounts for global illumination. Image courtesy
      of Warner Bros. and Framestore.
    ][
      #emph[《地心引力》]（2013）展现了壮观的计算机生成图像，逼真地还原了太空环境，其中包括体积散射和大量各向异性金属表面。这些图像是通过#emph[Arnold]生成的，一种基于物理的渲染系统，能够考虑全局光照。图片由华纳兄弟和Framestore提供。
    ]
  ],
)<gravity>


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f22.svg"),
  caption: [
    #ez_caption[
      This image from #emph[Alita: Battle Angel] (2019) was also
      rendered using a physically based rendering system. Image by Weta
      Digital, © 2018 Twentieth Century Fox Film Corporation. All Rights
      Reserved.
    ][
      这张来自《阿丽塔：战斗天使》（2019）的图像同样是使用基于物理的渲染系统生成的。图片由Weta Digital制作，© 2018二十世纪福克斯电影公司。版权所有。
    ]
  ],
)<alita>

