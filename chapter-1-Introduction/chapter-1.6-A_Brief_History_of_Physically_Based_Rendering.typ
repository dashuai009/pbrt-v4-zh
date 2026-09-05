#import "../template.typ": parec, ez_caption

== #ez_caption[A Brief History of Physically Based Rendering][基于物理的渲染简史]
<a-brief-history-of-physically-based-rendering>

#parec[
  Through the early years of computer graphics in the 1970s, the most important problems to solve were fundamental issues like visibility algorithms and geometric representations. When a megabyte of RAM was a rare and expensive luxury and when a computer capable of a million floating-point operations per second cost hundreds of thousands of dollars, the complexity of what was possible in computer graphics was correspondingly limited, and any attempt to accurately simulate physics for rendering was infeasible.
][
  在计算机图形学的早期，即 20 世纪 70 年代，最重要的问题是解决诸如可见性算法和几何表示等基本问题。当时，一个兆字节的 RAM 是稀有且昂贵的奢侈品，而能够每秒进行百万次浮点运算的计算机要花费几十万美元，因此当时计算机图形学的可能性极其有限，任何尝试准确模拟物理进行渲染的努力都是不可行的。
]


#parec[
  As computers have become more capable and less expensive, it has become possible to consider more computationally demanding approaches to rendering, which in turn has made physically based approaches viable. This progression is neatly explained by #emph[Blinn's law]: “as technology advances, rendering time remains constant.”
][
随着计算机性能提高、价格降低，我们可以考虑计算需求更高的渲染方法，基于物理的方法因而变得可行。_Blinn 定律_简洁地概括了这一过程：“技术不断进步，渲染时间却保持不变。”
]



#parec[
  Jim Blinn's simple statement captures an important constraint: given a certain number of images that must be rendered (be it a handful for a research paper or over a hundred thousand for a feature film), it is only possible to take so much processing time for each one. One has a certain amount of computation available and one has some amount of time available before rendering must be finished, so the maximum computation per image is necessarily limited.
][
Jim Blinn 这句简单的话揭示了一个重要约束：无论是为研究论文渲染几幅图，还是为长篇电影渲染十多万幅图，每幅图都只能分得有限的处理时间。可用计算能力有限，完成渲染前的时间也有限，因此每幅图像最多能使用的计算量必然受限。
]


#parec[
  Blinn's law also expresses the observation that there remains a gap between the images people would like to be able to render and the images that they can render: as computers have become faster, content creators have continued to use increased computational capability to render more complex scenes with more sophisticated rendering algorithms, rather than rendering the same scenes as before, just more quickly. Rendering continues to consume all computational capabilities made available to it.
][
  Blinn 定律也表达了这样一种观察：人们想要渲染的图像和他们能够渲染的图像之间仍然存在差距：随着计算机变得更快，内容创作者继续利用增加的计算能力使用复杂的渲染算法来渲染更复杂的场景，而不是以更快的速度渲染相同的场景。渲染继续消耗提供给它的所有计算能力。
]

=== #ez_caption[Research][研究]
<research>

#parec[
  Physically based approaches to rendering started to be seriously considered by graphics researchers in the 1980s. Whitted's paper (#link(<cite:Whitted80>)[1980]) introduced the idea of using ray tracing for global lighting effects, opening the door to accurately simulating the distribution of light in scenes. The rendered images his approach produced were markedly different from any that had been seen before, which spurred excitement about this approach.
][
  在 20 世纪 80 年代，图形研究者开始认真考虑基于物理的渲染方法。Whitted 的论文（#link(<cite:Whitted80>)[1980]）引入了使用光线追踪进行全局光效应的思想，开启了准确模拟场景中光线分布的大门。他的方法生成的渲染图像与之前所见的任何图像显著不同，这激发了人们对此方法的兴趣。
]

#parec[
  Another notable early advancement in physically based rendering was Cook and Torrance's reflection model (#link(<cite:Cook81>)[1981],#link(<cite:Cook82>)[1982]), which introduced microfacet reflection models to graphics. Among other contributions, they showed that accurately modeling microfacet reflection made it possible to render metal surfaces accurately; metal was not well rendered by earlier approaches.
][
  基于物理的渲染早期的另一个显著进展是 Cook 和 Torrance 的反射模型（#link(<cite:Cook81>)[1981]，#link(<cite:Cook82>)[1982]），该模型将微表面反射模型引入图形学。除其他贡献外，他们展示了准确建模微表面反射可以准确渲染金属表面；早期的方法无法很好地渲染金属。
]

#parec[
  Shortly afterward, Goral et al.(#link(<cite:Goral1984>)[1984]) made connections between the thermal transfer literature and rendering, showing how to incorporate global diffuse lighting effects using a physically based approximation of light transport. This method was based on finite-element techniques, where areas of surfaces in the scene exchanged energy with each other. This approach came to be referred to as “radiosity,” after a related physical unit. Following work by Cohen and Greenberg (#link(<cite:Cohen1985>)[1985]) and Nishita and Nakamae (#link(<cite:Nishita1985>)[1985]) introduced important improvements. Once again, a physically based approach led to images with lighting effects that had not previously been seen in rendered images, which led to many researchers pursuing improvements in this area.
][
  不久之后，Goral 等人（#link(<cite:Goral1984>)[1984]）将热传递文献与渲染联系起来，展示了如何使用基于物理的光传输近似方法整合全局漫反射光效应。该方法基于有限元技术，场景中各个表面区域相互交换能量。这种方法被称为“辐射度”，命名来源于一个相关的物理单位。接下来的工作中，Cohen 和 Greenberg（#link(<cite:Cohen1985>)[1985]）以及 Nishita 和 Nakamae（#link(<cite:Nishita1985>)[1985]）介绍了重要的改进。基于物理的方法再次生成了具有前所未见光照效果的图像，吸引许多研究人员继续改进这一方法。
]

#parec[
  While the radiosity approach was based on physical units and conservation of energy, in time it became clear that it would not lead to practical rendering algorithms: the asymptotic computational complexity was a difficult-to-manage $O(n^2)$, and it was necessary to retessellate geometric models along shadow boundaries for good results; researchers had difficulty developing robust and efficient tessellation algorithms for this purpose. Radiosity's adoption in practice was limited.
][
辐射度方法虽然基于物理量和能量守恒，但后来逐渐明确，它难以形成实用的渲染算法：渐近计算复杂度为难以应对的 $O(n^2)$；要获得良好结果，还必须沿阴影边界重新剖分几何模型，而研究人员很难为此开发出稳健、高效的剖分算法。因此，辐射度方法在实践中的应用有限。
]

#parec[
  During the radiosity years, a small group of researchers pursued physically based approaches to rendering that were based on ray tracing and Monte Carlo integration. At the time, many looked at their work with skepticism; objectionable noise in images due to Monte Carlo integration error seemed unavoidable, while radiosity-based methods quickly gave visually pleasing results, at least on relatively simple scenes.
][
  在辐射度方法盛行的年代，一小群研究人员致力于基于光线追踪和蒙特卡洛积分的物理渲染方法。那时，很多人对他们的工作持怀疑态度；蒙特卡洛积分误差造成的恼人噪声似乎不可避免；而辐射度方法则能迅速得到视觉上令人满意的结果，至少在相对简单的场景中是如此。
]

#parec[
  In 1984, Cook, Porter, and Carpenter introduced distributed ray tracing, which generalized Whitted's algorithm to compute motion blur and defocus blur from cameras, blurry reflection from glossy surfaces, and illumination from area light sources (Cook et al.~#link(<cite:Cook84>)[1984]), showing that ray tracing was capable of generating a host of important soft lighting effects.
][
  1984 年，Cook、Porter 和 Carpenter 介绍了分布式光线追踪，该方法将 Whitted 的算法推广以计算运动模糊和相机离焦模糊、光泽表面的模糊反射以及来自面光源的照明（Cook 等人，#link(<cite:Cook84>)[1984 年]），表明光线追踪能够生成一系列重要的柔和照明效果。
]

#parec[
  Shortly afterward, Kajiya (#link(<cite:Kajiya86>)[1986]) introduced path tracing; he set out a rigorous formulation of the rendering problem (the light transport integral equation) and showed how to apply Monte Carlo integration to solve it. This work required immense amounts of computation: to render a $256 times 256$ pixel image of two spheres with path tracing required 7 hours of computation on an IBM 4341 computer, which cost roughly \$280,000 when it was first released (Farmer #link(<cite:Farmer1981>)[1981]). With von Herzen, Kajiya also introduced the volume-rendering equation to graphics (Kajiya and von Herzen #link(<cite:Kajiya84>)[1984]); this equation describes the scattering of light in participating media.
][
  不久之后，Kajiya（#link(<cite:Kajiya86>)[1986 年]）引入了路径追踪；他对渲染问题（光传输积分方程）进行严格的表述，并展示如何应用蒙特卡洛积分进行求解。此工作需要大量的计算：在一台 IBM 4341 计算机上用路径追踪渲染两球的 $256 times 256$ 像素图像需要 7 小时的计算，该机器刚推出时的售价约为 28 万美元（Farmer，#link(<cite:Farmer1981>)[1981 年]）。与 von Herzen 一起，Kajiya 还将体积渲染方程引入了图形学（Kajiya 和 von Herzen#link(<cite:Kajiya84>)[1984 年]）；该方程描述了参与介质中的光散射。
]

#parec[
  Both Cook et al.'s and Kajiya's work once again led to images unlike any that had been seen before, demonstrating the value of physically based methods. In subsequent years, important work on Monte Carlo for realistic image synthesis was described in papers by Arvo and Kirk (#link(<cite:Arvo90pt>)[1990]) and Kirk and Arvo (#link(<cite:Kirk91>)[1991]). Shirley's Ph.D. dissertation (#link(<cite:Shirley90phd>)[1990]) and follow-on work by Shirley et al.(#link(<cite:Shirley96>)[1996]) were important contributions to Monte Carlo–based efforts. Hall's book,#emph[Illumination and Color in Computer Generated Imagery] (#link(<cite:Hall89>)[1989]), was one of the first books to present rendering in a physically based framework, and Andrew Glassner's #emph[Principles of Digital Image Synthesis] laid out foundations of the field (#link(<cite:Glassner:PODIS>)[1995]). Ward's #emph[Radiance] rendering system was an early open source physically based rendering system, focused on lighting design (Ward #link(<cite:Ward94>)[1994]), and Slusallek's #emph[Vision] renderer was designed to bridge the gap between physically based approaches and the then widely used #emph[RenderMan] interface, which was not physically based (Slusallek #link(<cite:SlusallekThesis>)[1996]).
][
Cook 等人与 Kajiya 的工作再次生成了前所未见的图像，证明了基于物理的方法的价值。此后，Arvo 和 Kirk（#link(<cite:Arvo90pt>)[1990]）以及 Kirk 和 Arvo（#link(<cite:Kirk91>)[1991]）的论文介绍了将蒙特卡洛用于真实感图像合成的重要工作。Shirley 的博士论文（#link(<cite:Shirley90phd>)[1990]）和 Shirley 等人的后续工作（#link(<cite:Shirley96>)[1996]）也作出了重要贡献。Hall 的 _Illumination and Color in Computer Generated Imagery_（#link(<cite:Hall89>)[1989]）是最早在基于物理的框架下讲解渲染的书籍之一；Andrew Glassner 的 _Principles of Digital Image Synthesis_（#link(<cite:Glassner:PODIS>)[1995]）则奠定了该领域的基础。Ward 的 _Radiance_ 是早期的开源基于物理的渲染系统，专注于光照设计（Ward #link(<cite:Ward94>)[1994]）。Slusallek 的 _Vision_ 渲染器旨在衔接基于物理的方法与当时广泛使用、却并非基于物理的 _RenderMan_ 接口（Slusallek #link(<cite:SlusallekThesis>)[1996]）。
]

#parec[
  Following Torrance and Cook's work, much of the research in the Program of Computer Graphics at Cornell University investigated physically based approaches. The motivations for this work were summarized by Greenberg et al.(#link(<cite:Greenberg:1997:AFF>)[1997]), who made a strong argument for a physically accurate rendering based on measurements of the material properties of real-world objects and on deep understanding of the human visual system.
][
在 Torrance 和 Cook 的工作之后，康奈尔大学计算机图形学项目的大量研究都开始探索基于物理的方法。Greenberg 等（#link(<cite:Greenberg:1997:AFF>)[1997]）总结了这些工作的动机，力主以现实物体材质属性的测量结果和对人类视觉系统的深入理解为基础，进行物理上准确的渲染。
]

#parec[
  A crucial step forward for physically based rendering was Veach's work, described in detail in his dissertation (Veach #link(<cite:VeachThesis>)[1997]). Veach advanced key theoretical foundations of Monte Carlo rendering while also developing new algorithms like multiple importance sampling, bidirectional path tracing, and Metropolis light transport that greatly improved its efficiency. Using Blinn's law as a guide, we believe that these significant improvements in efficiency were critical to practical adoption of these approaches.
][
  基于物理的渲染的一个关键进展是 Veach 的工作，在他的论文中详细描述（Veach，#link(<cite:VeachThesis>)[1997 年]）。Veach 在推进蒙特卡洛渲染的关键理论基础的同时，还开发了新算法，如多重重要性采样、双向路径追踪和 Metropolis 光传输，大大提高了其效率。以 Blinn 定律为指导，我们相信这些效率的显著改善对这些方法的实际采用至关重要。
]

#parec[
  Around this time, as computers became faster and more parallel, a number of researchers started pursuing real-time ray tracing; Wald, Slusallek, and Benthin wrote an influential paper that described a highly optimized ray tracer that was much more efficient than previous ray tracers (Wald et~al.~#link(<cite:Wald01b>)[2001b]). Many subsequent papers introduced increasingly more efficient ray-tracing algorithms. Though most of this work was not physically based, the results led to great progress in ray-tracing acceleration structures and performance of the geometric components of ray tracing. Because physically based rendering generally makes substantial use of ray tracing, this work has in turn had the same helpful effect as faster computers have, making it possible to render more complex scenes with physical approaches.
][
  大约在这时，随着计算机变得更快和更具并行性，一些研究人员开始追求实时光线追踪；Wald、Slusallek 和 Benthin 撰写了一篇具有影响力的论文，描述了一种高度优化的光线追踪器，比以前的光线追踪器效率高得多（Wald 等人，#link(<cite:Wald01b>)[2001b 年]）。许多后续论文介绍了越来越高效的光线追踪算法。尽管大多数工作不是基于物理的，但结果在光线追踪加速结构和光线追踪几何组件性能方面取得了很大进展。由于基于物理的渲染通常大量使用光线追踪，这项工作同样产生了与更快的计算机相同的积极效果，使得用物理方法渲染更复杂的场景成为可能。
]

#parec[
  We end our summary of the key steps in the research progress of physically based rendering at this point, though much more has been done. The “Further Reading” sections in all the subsequent chapters of this book cover this work in detail.
][
  我们在此结束对基于物理的渲染研究进展关键步骤的总结，尽管还有更多工作已完成。本书所有后续章节中的“延伸阅读”部分将详细介绍这些工作。
]

=== #ez_caption[Production][制作应用]
<production>


#parec[
  With more capable computers in the 1980s, computer graphics could start to be used for animation and film production. Early examples include Jim Blinn's rendering of the #emph[Voyager~2] flyby of Saturn in 1981 and visual effects in the movies #emph[Star Trek II: The Wrath of Khan] (1982),#emph[Tron] (1982), and #emph[The Last Starfighter] (1984).
][
  由于 20 世纪 80 年代计算机能力的提升，计算机图形学开始用于动画和电影制作。早期的例子包括 Jim Blinn 在 1981 年对#emph[旅行者 2 号]飞越土星的渲染，以及电影#emph[星际旅行 II：可汗之怒]（1982 年）、#emph[电子世界争霸战]（1982 年）和#emph[最后的星际战士]（1984 年）中的视觉效果。
]

#parec[
  In early production use of computer-generated imagery, rasterization-based rendering (notably, the Reyes algorithm (Cook et al.~#link(<cite:Cook87>)[1987])) was the only viable option. One reason was that not enough computation was available for complex reflection models or for the global lighting effects that physically based ray tracing could provide. More significantly, rasterization had the important advantage that it did not require that the entire scene representation fit into main memory.
][
  在早期的计算机生成图像制作中，基于光栅化的渲染（特别是 Reyes 算法（Cook 等人，#link(<cite:Cook87>)[1987 年]））是唯一可行的选择。原因之一是没有足够的计算能力用于复杂的反射模型或基于物理的光线追踪提供的全局光效应。更重要的是，光栅化具有不要求整个场景表示全部装入主存的重要优势。
]

#parec[
  When RAM was much less plentiful, almost any interesting scene was too large to fit into main memory. Rasterization-based algorithms made it possible to render scenes while having only a small subset of the full scene representation in memory at any time. Global lighting effects are difficult to achieve if the whole scene cannot fit into main memory; for many years, with limited computer systems, content creators effectively decided that geometric and texture complexity was more important to visual realism than lighting complexity (and in turn physical accuracy).
][
在内存远不如今天充裕的时代，几乎任何有价值的场景都大得无法全部装入主存。基于光栅化的算法允许在任一时刻只将完整场景表示的一小部分放入内存，仍能完成渲染。然而，整个场景无法装入主存时，全局光照效果就很难实现。多年来，受计算机能力所限，内容创作者实际上作出了这样的取舍：几何与纹理的复杂度，比光照复杂度及其对应的物理准确性，对视觉真实感更重要。
]

#parec[
  Many practitioners at this time also believed that physically based approaches were undesirable for production: one of the great things about computer graphics is that one can cheat reality with impunity to achieve a desired artistic effect. For example, lighting designers on regular movies often struggle to place light sources so that they are not visible to the camera or spend considerable effort placing a light to illuminate an actor without shining too much light on the background. Computer graphics offers the opportunity to, for example, implement a light source model that shines twice as much light on a character as on a background object. For many years, this capability seemed much more useful than physical accuracy.
][
当时，许多从业者还认为基于物理的方法不适合制作。计算机图形学的一大长处，是可以自由偏离现实，以实现预期的艺术效果。例如，实拍电影的灯光师经常费力安排光源，使其不出现在镜头中；或精心布光，既照亮演员，又避免把背景照得太亮。计算机图形学则可以实现特殊光源模型，例如让照到角色上的光量是照到背景物体上的两倍。多年来，这种能力似乎远比物理准确性有用。
]

#parec[
  Visual effects practitioners who had the specific need to match rendered imagery to filmed real-world environments pioneered capturing real-world lighting and shading effects and were early adopters of physically based approaches in the late 1990s and early 2000s.(See Snow (#link(<cite:Snow2010>)[2010]) for a history of ILM's early work in this area, for example.)
][
视觉效果从业者需要让渲染图像与实拍环境匹配，因此率先采集现实世界中的光照和着色效果，并在 20 世纪 90 年代末至 21 世纪初成为基于物理的方法的早期使用者。例如，Snow（#link(<cite:Snow2010>)[2010]）回顾了 ILM 在这方面的早期工作。
]

#parec[
  During this time, Blue Sky Studios adopted a physically based pipeline (Ohmer #link(<cite:Ohmer1997>)[1997]). The photorealism of an advertisement they made for a Braun shaver in 1992 caught the attention of many, and their short film,#emph[Bunny], shown in 1998, was an early example of Monte Carlo global illumination used in production. Its visual look was substantially different from those of films and shorts rendered with Reyes and was widely noted. Subsequent feature films from Blue Sky also followed this approach. Unfortunately, Blue Sky never published significant technical details of their approach, limiting their wider influence.
][
  在此期间，Blue Sky Studios 采用了基于物理的制作流程（Ohmer，#link(<cite:Ohmer1997>)[1997 年]）。他们 1992 年为博朗剃须刀制作的广告的照片级真实感引起了许多人的注意，他们 1998 年上映的短片#emph[Bunny]是蒙特卡洛全局光照在制作中的早期例子。它的视觉外观与 Reyes 渲染的电影和短片截然不同，并被广泛注意。Blue Sky 后来的长篇电影也采用了这种方法。不幸的是，Blue Sky 从未公布他们方法的显著技术细节，限制了它们更广泛的影响。
]

#parec[
  During the early 2000s, the #emph[mental ray] ray-tracing system was used by a number of studios, mostly for visual effects. It was an efficient ray tracer with sophisticated global illumination algorithm implementations. The main focus of its developers was computer-aided design and product design applications, so it lacked features like the ability to handle extremely complex scenes and the enormous numbers of texture maps that film production demanded.
][
  在 2000 年代初期，#emph[mental
ray]光线追踪系统被多家工作室使用，主要用于视觉效果。它是一个高效的光线追踪器，具有复杂的全局光照算法实现。其开发者的主要焦点是计算机辅助设计和产品设计应用，因此缺乏处理极其复杂场景和电影制作需求的海量纹理图的能力等特性。
]

#parec[
  After #emph[Bunny], another watershed moment came in 2001, when Marcos Fajardo came to the SIGGRAPH conference with an early version of his #emph[Arnold] renderer. He showed images in the Monte Carlo image synthesis course that not only had complex geometry, textures, and global illumination but also were rendered in tens of minutes. While these scenes were not of the complexity of those used in film production at the time, his results showed many the creative opportunities from the combination of global illumination and complex scenes.
][
  在#emph[Bunny]之后，另一个分水岭时刻出现在 2001 年，当时 Marcos Fajardo 带着他#emph[Arnold]渲染器的早期版本来到 SIGGRAPH 大会。他在蒙特卡洛图像合成课程中展示了不仅具有复杂几何、纹理和全局光照，还能在几十分钟内渲染完成的图像。虽然这些场景的复杂程度不及当时电影制作使用的场景，但他的结果表明了全局光照与复杂场景结合带来的许多创造性机会。
]

#parec[
  Fajardo brought #emph[Arnold] to Sony Pictures Imageworks, where work started to transform it to a production-capable physically based rendering system. Many issues had to be addressed, including efficient motion blur, programmable shading, support for massively complex scenes, and deferred loading of scene geometry and textures.#emph[Arnold] was first used on the movie #emph[Monster House] and is now available as a commercial product.
][
  Fajardo 将#emph[Arnold]带到索尼影像制作公司，在那里开始将其转化为可投入制作的基于物理的渲染系统。许多问题需要解决，包括高效的运动模糊、可编程的着色、大规模复杂场景的支持和场景几何和纹理的延迟加载。#emph[Arnold]首次用于电影#emph[怪兽屋]，现已作为商业产品提供。
]

#parec[
  In the early 2000s, Pixar's #emph[RenderMan] renderer started to support hybrid rasterization and ray-tracing algorithms and included a number of innovative algorithms for computing global illumination solutions in complex scenes.#emph[RenderMan] was recently rewritten to be a physically based ray tracer, following the general system architecture of `pbrt` (Christensen #link(<cite:Christensen2015>)[2015]).
][
  在 2000 年代初期，皮克斯的#emph[RenderMan]渲染器开始支持混合光栅化和光线追踪算法，并包含了一些用于计算复杂场景中全局光照解决方案的创新算法。#emph[RenderMan]最近被重写为基于物理的光线追踪器，遵循 `pbrt` 的一般系统体系结构（Christensen，#link(<cite:Christensen2015>)[2015 年]）。
]

#parec[
  One of the main reasons that physically based Monte Carlo approaches to rendering have been successful in production is that they end up improving the productivity of artists. These have been some of the important factors:
][
基于物理的蒙特卡洛渲染方法在制作中取得成功，一个主要原因是它们最终提高了艺术家的工作效率。其中一些重要因素如下：
]

#parec[
  - The algorithms involved have essentially just a single quality knob: how many samples to take per pixel; this is extremely helpful for artists. Ray-tracing algorithms are also suited to both progressive refinement and quickly computing rough previews by taking just a few samples per pixel; rasterization-based renderers do not have equivalent capabilities.
][
- 这些算法基本上只有一个画质调节参数：每个像素采集多少样本。这对艺术家极为便利。光线追踪算法既适合渐进细化，也能每像素只取少量样本，快速生成粗略预览；基于光栅化的渲染器没有同等能力。
]

#parec[
  - Adopting physically based reflection models has made it easier to design surface materials. Earlier, when reflection models that did not necessarily conserve energy were used, an object might be placed in a single lighting environment while its surface reflection parameters were adjusted. The object might look great in that environment, but it would often appear completely wrong when moved to another lighting environment because surfaces were reflecting too little or too much energy: surface properties had been set to unreasonable values.
][
  - 采用基于物理的反射模型使得设计表面材质更容易。早期，当使用不一定守恒能量的反射模型时，一个物体可能放在一个单一的光照环境中，而其表面反射参数被调整。该物体可能在该环境下看起来很棒，但在移到另一光照环境中时经常会看起来完全不对，因为表面反射的能量过少或过多：表面属性设置为不合理的值。
]

#parec[
  - The quality of shadows computed with ray tracing is much better than it is with rasterization. Eliminating the need to tweak shadow map resolutions, biases, and other parameters has eliminated an unpleasant task of lighting artists. Further, physically based methods bring with them bounce lighting and other soft-lighting effects from the method itself, rather than as an artistically tuned manual process.
][
- 光线追踪的阴影质量远好于光栅化。灯光师不再需要反复调整阴影贴图分辨率、偏置等参数，免去了一项烦琐工作。此外，反弹光照等柔和光照效果由基于物理的方法自然产生，无须再靠人工按艺术需求调制。
]

#parec[
  As of this writing, physically based rendering is used widely for producing computer-generated imagery for movies; @fig:gravity and @fig:alita show images from two recent movies that used physically based approaches.
][
  在本文撰写之时，基于物理的渲染广泛用于制作电影的计算机生成图像；@fig:gravity 和 @fig:alita 展示了两部最近使用基于物理方法制作的电影的图像。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/gravity.png"),
  caption: [
    #ez_caption[
      #emph[Gravity] (2013) featured spectacular
      computer-generated imagery of a realistic space environment with
      volumetric scattering and large numbers of anisotropic metal surfaces.
      The image was generated using #emph[Arnold,] a physically based
      rendering system that accounts for global illumination. Image courtesy
      of Warner Bros. and Framestore.
    ][
      #emph[《地心引力》]（2013）展现了壮观的计算机生成图像，逼真地还原了太空环境，其中包括体积散射和大量各向异性金属表面。此图像由 #emph[Arnold] 生成；它是一种考虑全局光照的基于物理的渲染系统。图片由 Warner Bros. 和 Framestore 提供。
    ]
  ],
)<gravity>


#figure(
  image("../pbr-book-website/4ed/Introduction/alita.png"),
  caption: [
    #ez_caption[
      This image from #emph[Alita: Battle Angel] (2019) was also
      rendered using a physically based rendering system. Image by Weta
      Digital, © 2018 Twentieth Century Fox Film Corporation. All Rights
      Reserved.
    ][
      这张来自《阿丽塔：战斗天使》（2019）的图像同样是使用基于物理的渲染系统生成的。图片由 Weta Digital 制作，© 2018 Twentieth Century Fox Film Corporation。保留所有权利。
    ]
  ],
)<alita>

