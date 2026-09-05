#import "../template.typ": parec, ez_caption

== #ez_caption[Further Reading][延伸阅读]
<introduction-further-reading>

#parec[
  In a seminal early paper, Arthur Appel (#link(<cite:Appel68>)[1968]) first described the basic idea of ray tracing to solve the hidden surface problem and to compute shadows in polygonal scenes. Goldstein and Nagel (#link(<cite:Goldstein71>)[1971]) later showed how ray tracing could be used to render scenes with quadric surfaces. Kay and Greenberg (#link(<cite:Kay79>)[1979]) described a ray-tracing approach to rendering transparency, and Whitted's seminal #emph[CACM] article described a general recursive ray-tracing algorithm that accurately simulates reflection and refraction from specular surfaces and shadows from point light sources (Whitted #link(<cite:Whitted80>)[1980]). Whitted has recently written an article describing developments over the early years of ray tracing (Whitted #link(<cite:Whitted2020>)[2020]).
][
  Arthur Appel 在一篇具有开创性的早期论文（#link(<cite:Appel68>)[1968]）中，首次描述了用光线追踪解决隐藏面问题、计算多边形场景阴影的基本思想。Goldstein 和 Nagel（#link(<cite:Goldstein71>)[1971]）随后展示了如何用光线追踪渲染含二次曲面的场景。Kay 和 Greenberg（#link(<cite:Kay79>)[1979]）介绍了用光线追踪表现透明效果的方法；Whitted 在 CACM 上发表的奠基性论文，则描述了一种通用的递归光线追踪算法，能够准确模拟镜面表面的反射、折射以及点光源产生的阴影（Whitted #link(<cite:Whitted80>)[1980]）。Whitted 最近还撰文回顾了光线追踪早年的发展（Whitted #link(<cite:Whitted2020>)[2020]）。
]

#parec[
  In addition to the ones discussed in @a-brief-history-of-physically-based-rendering, notable early books on physically based rendering and image synthesis include Cohen and Wallace's #emph[Radiosity and Realistic Image Synthesis] (#link(<cite:Cohen93>)[1993]), Sillion and Puech's #emph[Radiosity and Global Illumination] (#link(<cite:Sillion94>)[1994]), and Ashdown's #emph[Radiosity: A Programmer's Perspective] (#link(<cite:Ashdown94-RPP>)[1994]), all of which primarily describe the finite-element radiosity method. The course notes from the Monte Carlo ray-tracing course at SIGGRAPH have a wealth of practical information (Jensen et al. #link(<cite:Jensen01course>)[2001a], #link(<cite:Jensen03course>)[2003]), much of it still relevant, now nearly twenty years later.
][
  除了 @a-brief-history-of-physically-based-rendering 中讨论的著作，基于物理的渲染与图像合成领域的重要早期书籍还包括 Cohen 和 Wallace 的 _Radiosity and Realistic Image Synthesis_（#link(<cite:Cohen93>)[1993]）、Sillion 和 Puech 的 _Radiosity and Global Illumination_（#link(<cite:Sillion94>)[1994]），以及 Ashdown 的 _Radiosity: A Programmer’s Perspective_（#link(<cite:Ashdown94-RPP>)[1994]）。这些书主要讨论有限元辐射度方法。SIGGRAPH 蒙特卡洛光线追踪课程的讲义包含丰富的实用信息（Jensen 等，#link(<cite:Jensen01course>)[2001a]、#link(<cite:Jensen03course>)[2003]）；近二十年后的今天，其中许多内容仍有价值。
]

#parec[
  In a paper on ray-tracing system design, Kirk and Arvo (#link(<cite:Kirk88>)[1988]) suggested many principles that have now become classic in renderer design. Their renderer was implemented as a core kernel that encapsulated the basic rendering algorithms and interacted with primitives and shading routines via a carefully constructed object-oriented interface. This approach made it easy to extend the system with new primitives and acceleration methods. `pbrt`'s design is based on these ideas.
][
  Kirk 和 Arvo（#link(<cite:Kirk88>)[1988]）在一篇讨论光线追踪系统设计的论文中，提出了许多如今已成为渲染器设计经典准则的原则。他们的渲染器以核心内核封装基本渲染算法，通过精心设计的面向对象接口与图元和着色过程交互。这使系统很容易扩展新的图元和加速方法。`pbrt` 的设计正是基于这些思想。
]

#parec[
  To this day, a good reference on basic ray-tracer design is #emph[Introduction to Ray Tracing] (Glassner #link(<cite:Glassner:IntroRayTracing>)[1989a]), which describes the state of the art in ray tracing at that time and has a chapter by Heckbert that sketches the design of a basic ray tracer. More recently, Shirley and Morley's #emph[Realistic Ray Tracing] (#link(<cite:Shirley03>)[2003]) offers an easy-to-understand introduction to ray tracing and includes the complete source code to a basic ray tracer. Suffern's book (#link(<cite:Suffern2007>)[2007]) also provides a gentle introduction to ray tracing. Shirley's #emph[Ray Tracing in One Weekend] series (#link(<cite:Shirley2020>)[2020]) is an accessible introduction to the joy of writing a ray tracer.
][
  _Introduction to Ray Tracing_（Glassner #link(<cite:Glassner:IntroRayTracing>)[1989a]）至今仍是基础光线追踪器设计的良好参考。它介绍了当时光线追踪的先进技术，其中 Heckbert 撰写的一章概述了基础光线追踪器的设计。较新的 _Realistic Ray Tracing_（Shirley 和 Morley #link(<cite:Shirley03>)[2003]）浅显易懂地介绍了光线追踪，并附有一个基础光线追踪器的完整源代码。Suffern 的书（#link(<cite:Suffern2007>)[2007]）也是循序渐进的入门读物。Shirley 的 _Ray Tracing in One Weekend_ 系列（#link(<cite:Shirley2020>)[2020]）则让读者轻松领略编写光线追踪器的乐趣。
]

#parec[
  Researchers at Cornell University have developed a rendering testbed over many years; its design and overall structure were described by Trumbore, Lytle, and Greenberg (#link(<cite:Trumbore93>)[1993]). Its predecessor was described by Hall and Greenberg (#link(<cite:Hall83>)[1983]). This system is a loosely coupled set of modules and libraries, each designed to handle a single task (ray-object intersection acceleration, image storage, etc.) and written in a way that makes it easy to combine appropriate modules to investigate and develop new rendering algorithms. This testbed has been quite successful, serving as the foundation for much of the rendering research done at Cornell through the 1990s.
][
  康奈尔大学的研究人员多年间开发了一个渲染试验平台，Trumbore、Lytle 和 Greenberg（#link(<cite:Trumbore93>)[1993]）介绍了其设计和整体结构；其前身由 Hall 和 Greenberg（#link(<cite:Hall83>)[1983]）介绍。该系统由松散耦合的模块与库组成，每个模块或库只处理一项任务，例如射线与物体求交加速或图像存储。其编写方式便于组合适当模块，以研究和开发新的渲染算法。这个平台相当成功，成为康奈尔大学在整个 20 世纪 90 年代大量渲染研究的基础。
]

#parec[
  #emph[Radiance] was the first widely available open source renderer based fundamentally on physical quantities. It was designed to perform accurate lighting simulation for architectural design. Ward described its design and history in a paper and a book (Ward #link(<cite:Ward94>)[1994]; Larson and Shakespeare #link(<cite:Ward98>)[1998]). #emph[Radiance] is designed in the UNIX style, as a set of interacting programs, each handling a different part of the rendering process. This general type of rendering architecture was first described by Duff (#link(<cite:Duff85>)[1985]).
][
  Radiance 是第一个广泛可用、以物理量为基础的开源渲染器，旨在为建筑设计提供准确的光照模拟。Ward 在一篇论文和一本书中介绍了其设计与历史（Ward #link(<cite:Ward94>)[1994]；Larson 和 Shakespeare #link(<cite:Ward98>)[1998]）。Radiance 遵循 UNIX 风格，由一组相互协作的程序组成，各自处理渲染过程的不同部分。这类渲染架构最早由 Duff（#link(<cite:Duff85>)[1985]）描述。
]

#parec[
  Glassner's (#link(<cite:Glassner93>)[1993]) #emph[Spectrum] rendering architecture also focuses on physically based rendering, approached through a signal-processing-based formulation of the problem. It is an extensible system built with a plug-in architecture; `pbrt`'s approach of using parameter/value lists for initializing implementations of the main abstract interfaces is similar to #emph[Spectrum]'s. One notable feature of #emph[Spectrum] is that all parameters that describe the scene can be functions of time.
][
  Glassner（#link(<cite:Glassner93>)[1993]）的 Spectrum 渲染架构也专注于基于物理的渲染，并从信号处理的角度表述和处理这一问题。它采用插件架构，是一个可扩展的系统。`pbrt` 使用参数／值列表初始化主要抽象接口的具体实现，这一点与 Spectrum 类似。Spectrum 的一个显著特点是，描述场景的所有参数都可以是时间的函数。
]

#parec[
  Slusallek and Seidel (#link(<cite:Slusallek95>)[1995], #link(<cite:Slusallek96>)[1996]; Slusallek #link(<cite:SlusallekThesis>)[1996]) described the #emph[Vision] rendering system, which is also physically based and designed to support a wide variety of light transport algorithms. In particular, it had the ambitious goal of supporting both Monte Carlo and finite-element-based light transport algorithms.
][
  Slusallek 和 Seidel（#link(<cite:Slusallek95>)[1995]、#link(<cite:Slusallek96>)[1996]；另见 Slusallek #link(<cite:SlusallekThesis>)[1996]）介绍了 Vision 渲染系统。它同样基于物理，旨在支持多种光传输算法，尤其希望同时支持蒙特卡洛与有限元光传输算法。
]

#parec[
  Many papers have been written that describe the design and implementation of other rendering systems, including renderers for entertainment and artistic applications. The Reyes architecture, which forms the basis for Pixar's #emph[RenderMan] renderer, was first described by Cook et al. (#link(<cite:Cook87>)[1987]), and a number of improvements to the original algorithm have been summarized by Apodaca and Gritz (#link(<cite:Apodaca00>)[2000]). Gritz and Hahn (#link(<cite:Gritz96>)[1996]) described the #emph[BMRT] ray tracer. The renderer in the #emph[Maya] modeling and animation system was described by Sung et al. (#link(<cite:Sung98>)[1998]), and some of the internal structure of the #emph[mental ray] renderer is described in Driemeyer and Herken's book on its API (Driemeyer and Herken #link(<cite:Driemeyer02>)[2002]). The design of the high-performance #emph[Manta] interactive ray tracer was described by Bigler et al. (#link(<cite:Bigler2006>)[2006]).
][
  许多论文介绍了其他渲染系统的设计与实现，包括用于娱乐和艺术创作的渲染器。作为 Pixar RenderMan 渲染器基础的 Reyes 架构，最早由 Cook 等（#link(<cite:Cook87>)[1987]）描述；Apodaca 和 Gritz（#link(<cite:Apodaca00>)[2000]）总结了对原算法的多项改进。Gritz 和 Hahn（#link(<cite:Gritz96>)[1996]）介绍了 BMRT 光线追踪器。Sung 等（#link(<cite:Sung98>)[1998]）介绍了 Maya 建模与动画系统的渲染器；Driemeyer 和 Herken 关于 mental ray API 的书（#link(<cite:Driemeyer02>)[2002]）介绍了该渲染器的一部分内部结构。Bigler 等（#link(<cite:Bigler2006>)[2006]）则介绍了高性能 Manta 交互式光线追踪器的设计。
]

#parec[
  #emph[OptiX] introduced a particularly interesting design approach for high-performance ray tracing: it is based on doing JIT compilation at runtime to generate a specialized version of the ray tracer, intermingling user-provided code (such as for material evaluation and sampling) and renderer-provided code (such as high-performance ray-object intersection). It was described by Parker et al. (#link(<cite:Parker2010>)[2010]).
][
  OptiX 为高性能光线追踪引入了一种很有意思的设计方法：在运行时进行即时（JIT）编译，生成专门化的光线追踪器，将用户提供的代码（例如材质求值与采样）和渲染器提供的代码（例如高性能射线与物体求交）结合起来。Parker 等（#link(<cite:Parker2010>)[2010]）对它作了介绍。
]

#parec[
  More recently, Eisenacher et al. discussed the ray sorting architecture of Disney's #emph[Hyperion] renderer (Eisenacher et al. #link(<cite:Eisenacher2013>)[2013]), and Lee et al. have written about the implementation of the #emph[MoonRay] rendering system at DreamWorks (Lee et al. #link(<cite:Lee2017>)[2017]). The implementation of the #emph[Iray] ray tracer was described by Keller et al. (#link(<cite:Keller2017>)[2017]).
][
  较近的工作中，Eisenacher 等讨论了 Disney Hyperion 渲染器的射线排序架构（Eisenacher 等，#link(<cite:Eisenacher2013>)[2013]），Lee 等介绍了 DreamWorks 的 MoonRay 渲染系统实现（Lee 等，#link(<cite:Lee2017>)[2017]）。Keller 等（#link(<cite:Keller2017>)[2017]）则介绍了 Iray 光线追踪器的实现。
]

#parec[
  In 2018, a special issue of #emph[ACM Transactions on Graphics] included papers describing the implementations of five rendering systems that are used for feature film production. These papers are full of details about the various renderers; reading them is time well spent. They include Burley et al.'s description of Disney's #emph[Hyperion] renderer (#link(<cite:Burley2018>)[2018]), Christensen et al. on Pixar's modern #emph[RenderMan] (#link(<cite:Christensen2018:renderman>)[2018]), Fascione et al. describing Weta Digital's #emph[Manuka] (#link(<cite:Fascione2018>)[2018]), Georgiev et al. on Solid Angle's version of #emph[Arnold] (#link(<cite:Georgiev2018>)[2018]) and Kulla et al. on the version of #emph[Arnold] used at Sony Pictures Imageworks (#link(<cite:Kulla2018>)[2018]).
][
  2018 年，_ACM Transactions on Graphics_ 的一个专刊刊登了五篇关于电影制作渲染系统实现的论文，包含大量实现细节，值得阅读：Burley 等介绍 Disney 的 Hyperion（#link(<cite:Burley2018>)[2018]），Christensen 等介绍 Pixar 的现代 RenderMan（#link(<cite:Christensen2018:renderman>)[2018]），Fascione 等介绍 Weta Digital 的 Manuka（#link(<cite:Fascione2018>)[2018]），Georgiev 等介绍 Solid Angle 版本的 Arnold（#link(<cite:Georgiev2018>)[2018]），Kulla 等介绍 Sony Pictures Imageworks 使用的 Arnold 版本（#link(<cite:Kulla2018>)[2018]）。
]

#parec[
  Whereas standard rendering algorithms generate images from a 3D scene description, the #emph[Mitsuba 2] system is engineered around the corresponding inverse problem. It computes derivatives with respect to scene parameters using JIT-compiled kernels that efficiently run on GPUs and CPUs. These kernels are then used in the inner loop of an optimization algorithm to reconstruct 3D scenes that are consistent with user-provided input images. This topic is further discussed in #link("https://pbr-book.org/4ed/Retrospective_and_the_Future/Emerging_Topics.html#sec:differentiable-rendering")[Section 16.3.1]. The system's design and implementation was described by Nimier-David et al. (#link(<cite:NimierDavid2019>)[2019]).
][
  标准渲染算法根据三维场景描述生成图像，而 Mitsuba 2 围绕对应的逆问题设计。它使用经 JIT 编译、可在 GPU 和 CPU 上高效运行的内核，计算关于场景参数的导数，再在优化算法的内层循环中使用这些内核，重建与用户输入图像一致的三维场景。#link("https://pbr-book.org/4ed/Retrospective_and_the_Future/Emerging_Topics.html#sec:differentiable-rendering")[第 16.3.1 节]将进一步讨论这一主题。Nimier-David 等（#link(<cite:NimierDavid2019>)[2019]）介绍了该系统的设计与实现。
]

#heading(level: 3, numbering: none)[#ez_caption[References][参考文献]]

#block[#text("Apodaca, A. A., and L. Gritz. 2000. ")#emph[#text("Advanced RenderMan: Creating CGI for Motion Pictures.")]#text(" San Francisco: Morgan Kaufmann. ")] <cite:Apodaca00>

#block[#text("Appel, A. 1968. Some techniques for shading machine renderings of solids. In ")#emph[#text("AFIPS 1968 Spring Joint Computer Conference")]#text(" ")#emph[#text("32")]#text(", 37–45. ")] <cite:Appel68>

#block[#text("Arvo, J., and D. Kirk. 1990. Particle transport and image synthesis. ")#emph[#text("Computer Graphics (SIGGRAPH ’90 Proceedings)")]#text(" ")#emph[#text("24")]#text(" (4), 63–66. ")] <cite:Arvo90pt>

#block[#text("Ashdown, I. 1994. ")#emph[#text("Radiosity: A Programmer’s Perspective")]#text(". New York: John Wiley & Sons. ")] <cite:Ashdown94-RPP>

#block[#text("Bigler, J., A. Stephens, and S. Parker. 2006. Design for parallel interactive ray tracing systems. ")#emph[#text("IEEE Symposium on Interactive Ray Tracing")]#text(", 187–95. ")] <cite:Bigler2006>

#block[#text("Burley, B., D. Adler, M. J-Y. Chiang, H. Driskill, R. Habel, P. Kelly, P. Kutz, Y. K. Li, and D. Teece. 2018. The design and evolution of Disney’s Hyperion renderer. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("37")]#text(" (3), 33:1–22. ")] <cite:Burley2018>

#block[#text("Christensen, P. 2015. The path-tracing revolution in the movie industry. ")#emph[#text("ACM SIGGRAPH 2015 Course")]#text(", 24:1–7. ")] <cite:Christensen2015>

#block[#text("Christensen, P., J. Fong, J. Shade, W. Wooten, B. Schubert, A. Kensler, S. Friedman, C. Kilpatrick, C. Ramshaw, M. Bannister, B. Rayner, J. Brouillat, and M. Liani. 2018. RenderMan: An advanced path-tracing architecture for movie rendering. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("37")]#text(" (3), 30:1–21. ")] <cite:Christensen2018:renderman>

#block[#text("Cohen, M., and D. P. Greenberg. 1985. The hemi-cube: A radiosity solution for complex environments. ")#emph[#text("SIGGRAPH Computer Graphics")]#text(" ")#emph[#text("19")]#text(" (3), 31–40. ")] <cite:Cohen1985>

#block[#text("Cohen, M., and J. Wallace. 1993. ")#emph[#text("Radiosity and Realistic Image Synthesis")]#text(". San Diego: Academic Press Professional. ")] <cite:Cohen93>

#block[#text("Cook, R. L., and K. E. Torrance. 1981. A reflectance model for computer graphics. ")#emph[#text("Computer Graphics (SIGGRAPH ’81 Proceedings)")]#text(" ")#emph[#text("15")]#text(", 307–16. ")] <cite:Cook81>

#block[#text("Cook, R. L., and K. E. Torrance. 1982. A reflectance model for computer graphics. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("1")]#text(" (1), 7–24. ")] <cite:Cook82>

#block[#text("Cook, R. L., L. Carpenter, and E. Catmull. 1987. The Reyes image rendering architecture. ")#emph[#text("Computer Graphics (Proceedings of SIGGRAPH ’87)")]#text(" ")#emph[#text("21")]#text(" (4), 95–102. ")] <cite:Cook87>

#block[#text("Cook, R. L., T. Porter, and L. Carpenter. 1984. Distributed ray tracing. ")#emph[#text("Computer Graphics (SIGGRAPH ’84 Proceedings)")]#text(" ")#emph[#text("18")]#text(", 137–45. ")] <cite:Cook84>

#block[#text("Driemeyer, T., and R. Herken. 2002. ")#emph[#text("Programming mental ray")]#text(". Wien: Springer-Verlag. ")] <cite:Driemeyer02>

#block[#text("Duff, T. 1985. Compositing 3-D rendered images. ")#emph[#text("Computer Graphics (Proceedings of SIGGRAPH ’85)")]#text(" ")#emph[#text("19")]#text(", 41–44. ")] <cite:Duff85>

#block[#text("Eisenacher, C., G. Nichols, A. Selle, and B. Burley. 2013. Sorted deferred shading for production path tracing. ")#emph[#text("Computer Graphics Forum (Proceedings of the 2013 Eurographics Symposium on Rendering)")]#text(" ")#emph[#text("32")]#text(" (4), 125–32. ")] <cite:Eisenacher2013>

#block[#text("Farmer, D. F. 1981. Comparing the 4341 and M80/40. ")#emph[#text("Computerworld")]#text(" ")#emph[#text("15")]#text(" (6), 9–20. ")] <cite:Farmer1981>

#block[#text("Fascione, L., J. Hanika, M. Leone, M. Droske, J. Schwarzhaupt, T. Davidovi")#text("č")#text(", A. Weidlich, and J. Meng. 2018. Manuka: A batch-shading architecture for spectral path tracing in movie production. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("37")]#text(" (3), 31:1–18. ")] <cite:Fascione2018>

#block[#text("Georgiev, I., T. Ize, M. Farnsworth, R. Montoya-Vozmediano, A. King, B. Van Lommel, A. Jimenez, O. Anson, S. Ogaki, E. Johnston, A. Herubel, D. Russell, F. Servant, and M. Fajardo. 2018. Arnold: A brute-force production path tracer. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("37")]#text(" (3), 32:1–12. ")] <cite:Georgiev2018>

#block[#text("Glassner, A. (ed.) 1989a. ")#emph[#text("An Introduction to Ray Tracing")]#text(". San Diego: Academic Press. ")] <cite:Glassner:IntroRayTracing>

#block[#text("Glassner, A. 1993. Spectrum: An architecture for image synthesis, research, education, and practice. ")#emph[#text("Developing Large-Scale Graphics Software Toolkits, SIGGRAPH ’93 Course Notes")]#text(", ")#emph[#text("3")]#text(", 1:14–43. ")] <cite:Glassner93>

#block[#text("Glassner, A. 1995. ")#emph[#text("Principles of Digital Image Synthesis")]#text(". San Francisco: Morgan Kaufmann. ")] <cite:Glassner:PODIS>

#block[#text("Goldstein, R. A., and R. Nagel. 1971. 3-D visual simulation. ")#emph[#text("Simulation")]#text(" ")#emph[#text("16")]#text(" (1), 25–31. ")] <cite:Goldstein71>

#block[#text("Goral, C. M., K. E. Torrance, D. P. Greenberg, and B. Battaile. 1984. Modeling the interaction of light between diffuse surfaces. ")#emph[#text("Proceedings of the 11th Annual Conference on Computer Graphics and Interactive Techniques (SIGGRAPH ’84)")]#text(" ")#emph[#text("18")]#text(" (3), 213–22. ")] <cite:Goral1984>

#block[#text("Greenberg, D. P., K. E. Torrance, P. S. Shirley, J. R. Arvo, J. A. Ferwerda, S. Pattanaik, E. P. F. Lafortune, B. Walter, S.-C. Foo, and B. Trumbore. 1997. A framework for realistic image synthesis. ")#emph[#text("Proceedings of SIGGRAPH ’97")]#text(", Computer Graphics Proceedings, Annual Conference Series, 477–94. ")] <cite:Greenberg:1997:AFF>

#block[#text("Gritz, L., and J. K. Hahn. 1996. BMRT: A global illumination implementation of the RenderMan standard. ")#emph[#text("Journal of Graphics Tools")]#text(" ")#emph[#text("1")]#text(" (3), 29–47. ")] <cite:Gritz96>

#block[#text("Hall, R. 1989. ")#emph[#text("Illumination and Color in Computer Generated Imagery")]#text(". New York: Springer-Verlag. ")] <cite:Hall89>

#block[#text("Hall, R. A., and D. P. Greenberg. 1983. A testbed for realistic image synthesis. ")#emph[#text("IEEE Computer Graphics and Applications")]#text(" ")#emph[#text("3")]#text(" (8), 10–20. ")] <cite:Hall83>

#block[#text("Jensen, H. W., J. Arvo, M. Fajardo, P. Hanrahan, D. Mitchell, M. Pharr, and P. Shirley. 2001a. State of the art in Monte Carlo ray tracing for realistic image synthesis. In ")#emph[#text("SIGGRAPH 2001 Course 29")]#text(", Los Angeles. ")] <cite:Jensen01course>

#block[#text("Jensen, H. W., J. Arvo, P. Dutré, A. Keller, A. Owen, M. Pharr, and P. Shirley. 2003. Monte Carlo ray tracing. In ")#emph[#text("SIGGRAPH 2003 Courses")]#text(", San Diego. ")] <cite:Jensen03course>

#block[#text("Kajiya, J. T. 1986. The rendering equation. In ")#emph[#text("Computer Graphics (SIGGRAPH ’86 Proceedings)")]#text(" ")#emph[#text("20")]#text(", 143–50. ")] <cite:Kajiya86>

#block[#text("Kajiya, J. T., and B. P. Von Herzen. 1984. Ray tracing volume densities. In ")#emph[#text("Computer Graphics (Proceedings of SIGGRAPH ’84)")]#text(", Volume 18, 165–74. ")] <cite:Kajiya84>

#block[#text("Kay, D. S., and D. P. Greenberg. 1979. Transparency for computer synthesized images. In ")#emph[#text("Computer Graphics (SIGGRAPH ’79 Proceedings)")]#text(", Volume 13, 158–64. ")] <cite:Kay79>

#block[#text("Keller, A., C. Wächter, M. Raab, D. Seibert, D. van Antwerpen, J. Korndörfer, and L. Kettner. 2017. The Iray light transport simulation and rendering system. arXiv:1705.01263 [cs.GR]. ")] <cite:Keller2017>

#block[#text("Kirk, D. B., and J. Arvo. 1991. Unbiased sampling techniques for image synthesis. ")#emph[#text("Computer Graphics (SIGGRAPH ’91 Proceedings)")]#text(", Volume 25, 153–56. ")] <cite:Kirk91>

#block[#text("Kirk, D., and J. Arvo. 1988. The ray tracing kernel. In ")#emph[#text("Proceedings of Ausgraph ’88")]#text(", 75–82. ")] <cite:Kirk88>

#block[#text("Kulla, C., A. Conty, C. Stein, and L. Gritz. 2018. Sony Pictures Imageworks Arnold. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("37")]#text(" (3), 29:1–18. ")] <cite:Kulla2018>

#block[#text("Larson, G. W., and R. A. Shakespeare. 1998. ")#emph[#text("Rendering with Radiance: The Art and Science of Lighting Visualization")]#text(". San Francisco: Morgan Kaufmann. ")] <cite:Ward98>

#block[#text("Lee, M., B. Green, F. Xie, and E. Tabellion. 2017. Vectorized production path tracing. In ")#emph[#text("Proceedings of High Performance Graphics (HPG ’17)")]#text(", 10:1–11. ")] <cite:Lee2017>

#block[#text("Nimier-David, M., D. Vicini, T. Zeltner, W. Jakob. 2019. Mitsuba 2: A retargetable forward and inverse renderer. ")#emph[#text("ACM Transactions on Graphics (Proceedings of SIGGRAPH 2019)")]#text(" ")#emph[#text("38")]#text(" (6), 203:1–17. ")] <cite:NimierDavid2019>

#block[#text("Nishita, T., and E. Nakamae. 1985. Continuous tone representation of three-dimensional objects taking account of shadows and interreflection. ")#emph[#text("SIGGRAPH Computer Graphics")]#text(" ")#emph[#text("19")]#text(" (3), 23–30. ")] <cite:Nishita1985>

#block[#text("Ohmer, S. 1997. Ray Tracers: Blue Sky Studios. ")#emph[#text("Animation World Network")]#text(", ")#link("http://www.awn.com/animationworld/ray-tracers-blue-sky-studios")[#text("http://www.awn.com/animationworld/ray-tracers-blue-sky-studios")]#text(". ")] <cite:Ohmer1997>

#block[#text("Parker, S. G., J. Bigler, A. Dietrich, H. Friedrich, J. Hoberock, D. Luebke, D. McAllister, M. McGuire, K. Morley, A. Robison, and M. Stich. 2010. OptiX: A general purpose ray tracing engine. ")#emph[#text("ACM Transactions on Graphics (Proceedings of SIGGRAPH 2010)")]#text(" ")#emph[#text("29")]#text(" (4), 66:1–13. ")] <cite:Parker2010>

#block[#text("Shirley, P. 1990. Physically based lighting calculations for computer graphics. Ph.D. thesis, Department of Computer Science, University of Illinois, Urbana–Champaign. ")] <cite:Shirley90phd>

#block[#text("Shirley, P. 2020. Ray Tracing in One Weekend Series. ")#link("https://raytracing.github.io/")[#text("https://raytracing.github.io/")]#text(". ")] <cite:Shirley2020>

#block[#text("Shirley, P., and R. K. Morley. 2003. ")#emph[#text("Realistic Ray Tracing")]#text(". Natick, Massachusetts: A. K. Peters. ")] <cite:Shirley03>

#block[#text("Shirley, P., C. Y. Wang, and K. Zimmerman. 1996. Monte Carlo techniques for direct lighting calculations. ")#emph[#text("ACM Transactions on Graphics")]#text(" ")#emph[#text("15")]#text(" (1), 1–36. ")] <cite:Shirley96>

#block[#text("Sillion, F., and C. Puech. 1994. ")#emph[#text("Radiosity and Global Illumination")]#text(". San Francisco: Morgan Kaufmann. ")] <cite:Sillion94>

#block[#text("Slusallek, P. 1996. Vision—An architecture for physically-based rendering. Ph.D. thesis, University of Erlangen. ")] <cite:SlusallekThesis>

#block[#text("Slusallek, P., and H.-P. Seidel. 1995. Vision—An architecture for global illumination calculations. ")#emph[#text("IEEE Transactions on Visualization and Computer Graphics")]#text(" ")#emph[#text("1")]#text(" (1), 77–96. ")] <cite:Slusallek95>

#block[#text("Slusallek, P., and H.-P. Seidel. 1996. Towards an open rendering kernel for image synthesis. In ")#emph[#text("Eurographics Rendering Workshop 1996")]#text(", 51–60. ")] <cite:Slusallek96>

#block[#text("Snow, J. 2010. Terminators and Iron Men: Image-based lighting and physical shading at ILM. ")#emph[#text("SIGGRAPH 2010 Course: Physically-Based Shading Models in Film and Game Production")]#text(". ")] <cite:Snow2010>

#block[#text("Suffern, K. 2007. ")#emph[#text("Ray Tracing from the Ground Up")]#text(". Natick, Massachusetts: A. K. Peters. ")] <cite:Suffern2007>

#block[#text("Sung, K., J. Craighead, C. Wang, S. Bakshi, A. Pearce, and A. Woo. 1998. Design and implementation of the Maya renderer. In ")#emph[#text("Pacific Graphics ’98")]#text(". ")] <cite:Sung98>

#block[#text("Trumbore, B., W. Lytle, and D. P. Greenberg. 1993. A testbed for image synthesis. In ")#emph[#text("Developing Large-Scale Graphics Software Toolkits")]#text(", SIGGRAPH ’93 Course Notes, Volume 3, 4-7–19. ")] <cite:Trumbore93>

#block[#text("Veach, E. 1997. Robust Monte Carlo methods for light transport simulation. Ph.D. thesis, Stanford University. ")] <cite:VeachThesis>

#block[#text("Wald, I., P. Slusallek, and C. Benthin. 2001b. Interactive distributed ray tracing of highly complex models. In ")#emph[#text("Rendering Techniques 2001: 12th Eurographics Workshop on Rendering")]#text(", 277–88. ")] <cite:Wald01b>

#block[#text("Ward, G. J. 1994. The Radiance lighting simulation and rendering system. In ")#emph[#text("Proceedings of SIGGRAPH ’94")]#text(", 459–72. ")] <cite:Ward94>

#block[#text("Whitted, T. 1980. An improved illumination model for shaded display. ")#emph[#text("Communications of the ACM")]#text(" ")#emph[#text("23")]#text(" (6), 343–49. ")] <cite:Whitted80>

#block[#text("Whitted, T. 2020. Origins of global illumination. ")#emph[#text("IEEE Computer Graphics and Applications")]#text(" ")#emph[#text("40")]#text(" (1), 20–27. ")] <cite:Whitted2020>
