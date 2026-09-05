#import "../template.typ": parec, translator, ez_caption

= #ez_caption[Preface][序言]

#parec[
  _[Just as] other information should be available to those who want to learn and understand, program source code is the only means for programmers to learn the art from their predecessors. It would be unthinkable for playwrights not to allow other playwrights to read their plays [or to allow them] at theater performances where they would be barred even from taking notes. Likewise, any good author is well read, as every child who learns to write will read hundreds of times more than it writes. Programmers, however, are expected to invent the alphabet and learn to write long novels all on their own. Programming cannot grow and learn unless the next generation of programmers has access to the knowledge and information gathered by other programmers before them._ —Erik Naggum
][
  _[正如]其他信息应当向渴望学习和理解的人开放一样，程序源代码是程序员向前辈学习这门技艺的唯一途径。如果剧作家不许其他剧作家阅读自己的剧本，或者只准他们到剧院观看演出、连笔记都不许做，那是不可想象的。同样，优秀的作家无不博览群书，正如每个学习写作的孩子，阅读量都会是写作量的数百倍。然而，人们却指望程序员完全靠自己发明字母表，再学会写长篇小说。除非下一代程序员能够接触到前人积累的知识与信息，否则编程这门技艺就无法在学习中发展。_ ——Erik Naggum
]

#parec[
  Rendering is a fundamental component of computer graphics. At the highest level of abstraction, rendering is the process of converting a description of a three-dimensional scene into an image. Algorithms for animation, geometric modeling, texturing, and other areas of computer graphics all must pass their results through some sort of rendering process so that they can be made visible in an image. Rendering has become ubiquitous; from movies to games and beyond, it has opened new frontiers for creative expression, entertainment, and visualization.
][
  渲染是计算机图形学的基本组成部分。在最高的抽象层次上，渲染就是将三维场景描述转化为图像的过程。动画、几何建模、纹理处理以及计算机图形学其他领域的算法，都必须将结果交由某种渲染过程处理，才能使其在图像中呈现出来。如今，渲染已无处不在：从电影到游戏乃至更多领域，它为创意表达、娱乐和可视化开辟了新的空间。
]

#parec[
  In the early years of the field, research in rendering focused on solving fundamental problems such as determining which objects are visible from a given viewpoint. As effective solutions to these problems have been found and as richer and more realistic scene descriptions have become available thanks to continued progress in other areas of graphics, modern rendering has grown to include ideas from a broad range of disciplines, including physics and astrophysics, astronomy, biology, psychology and the study of perception, and pure and applied mathematics. The interdisciplinary nature of rendering is one of the reasons that it is such a fascinating area of study.
][
  在这一领域发展的早期，渲染研究主要致力于解决一些基本问题，例如确定从给定视点可以看到哪些物体。随着这些问题得到有效解决，图形学其他领域的持续进步又使更丰富、更逼真的场景描述成为可能，现代渲染逐渐吸收了众多学科的思想，包括物理学与天体物理学、天文学、生物学、心理学与感知研究，以及纯数学与应用数学。这种跨学科特征，正是渲染如此引人入胜的原因之一。
]

#parec[
  This book presents a selection of modern rendering algorithms through the documented source code for a complete rendering system. Nearly all of the images in this book, including the one on the front cover, were rendered by this software. All of the algorithms that came together to generate these images are described in these pages. The system, `pbrt`, is written using a programming methodology called _literate programming_ that mixes prose describing the system with the source code that implements it. We believe that the literate programming approach is a valuable way to introduce ideas in computer graphics and computer science in general. Often, some of the subtleties of an algorithm can be unclear or hidden until it is implemented, so seeing an actual implementation is a good way to acquire a solid understanding of that algorithm's details. Indeed, we believe that deep understanding of a number of carefully selected algorithms in this manner provides a better foundation for further study of computer graphics than does superficial understanding of many.
][
  本书通过一个完整渲染系统的源代码及其配套说明，介绍一组精选的现代渲染算法。书中几乎所有图像，包括封面图像，均由这一软件渲染而成；共同生成这些图像的全部算法也都在书中加以介绍。这个名为 `pbrt` 的系统采用_文学编程_方法编写，将描述系统的文字与实现系统的源代码融为一体。我们认为，文学编程是介绍计算机图形学乃至整个计算机科学中各种思想的一种宝贵方式。算法的一些微妙之处，往往要到实现时才会显露或变得清晰，因此阅读实际实现有助于扎实地理解算法细节。事实上，我们相信，以这种方式深入理解若干精心挑选的算法，比浅尝辄止地了解许多算法，更能为进一步学习计算机图形学打下良好基础。
]

#parec[
  In addition to clarifying how an algorithm is implemented in practice, presenting these algorithms in the context of a complete and nontrivial software system also allows us to address issues in the design and implementation of medium-sized rendering systems. The design of a rendering system's basic abstractions and interfaces has substantial implications for both the elegance of the implementation and the ability to extend it later, yet the trade-offs in this design space are rarely discussed.
][
  将这些算法放在一个完整且具有一定复杂性的软件系统中介绍，除了能说明算法在实践中如何实现，还让我们能够探讨中等规模渲染系统的设计与实现问题。系统的基本抽象和接口如何设计，既深刻影响实现是否优雅，也影响今后的可扩展性；然而，这些设计选择之间的权衡却很少得到讨论。
]

#parec[
  `pbrt` and the contents of this book focus exclusively on _photorealistic rendering_, which can be defined variously as the task of generating images that are indistinguishable from those that a camera would capture in a photograph or as the task of generating images that evoke the same response from a human observer as looking at the actual scene. There are many reasons to focus on photorealism. Photorealistic images are crucial for special effects in movies because computer-generated imagery must often be mixed seamlessly with footage of the real world. In applications like computer games where all of the imagery is synthetic, photorealism is an effective tool for making the observer forget that he or she is looking at an environment that does not actually exist. Finally, photorealism gives a reasonably well-defined metric for evaluating the quality of the rendering system's output.
][
  `pbrt` 和本书内容专注于_照片级真实感渲染_。它可以有不同的定义：生成与相机拍摄的照片无法区分的图像，或生成能让观察者产生与观看真实场景相同反应的图像。专注于照片级真实感有许多理由。对于电影特效，照片级真实感图像至关重要，因为计算机生成的图像往往需要与实拍画面无缝融合。在计算机游戏等全部采用合成图像的应用中，照片级真实感能够有效地让观察者忘记眼前的环境其实并不存在。最后，照片级真实感也为评价渲染系统输出的质量提供了一个较为明确的标准。
]

== #ez_caption[Audience][读者对象]
#parec[
  There are three main audiences that this book is intended for. The first is students in graduate or upper-level undergraduate computer graphics classes. This book assumes existing knowledge of computer graphics at the level of an introductory college-level course, although certain key concepts such as basic vector geometry and transformations will be reviewed here. For students who do not have experience with programs that have tens of thousands of lines of source code, the literate programming style gives a gentle introduction to this complexity. We pay special attention to explaining the reasoning behind some of the key interfaces and abstractions in the system in order to give these readers a sense of why the system is structured in the way that it is.
][
  本书主要面向三类读者。第一类是修读计算机图形学课程的研究生和高年级本科生。本书假定读者已掌握大学入门课程程度的计算机图形学知识，不过仍会回顾基本向量几何与变换等关键概念。对于尚未接触过数万行源代码程序的学生，文学编程风格能帮助他们逐步适应这种复杂程度。我们特别注意解释系统中关键接口和抽象的设计理由，让读者理解系统为何采用这样的结构。
]

#parec[
  The second audience is advanced graduate students and researchers in computer graphics. For those doing research in rendering, the book provides a broad introduction to the area, and the `pbrt` source code provides a foundation that can be useful to build upon (or at least to use bits of source code from). For those working in other areas of computer graphics, we believe that having a thorough understanding of rendering can be helpful context to carry along.
][
  第二类读者是计算机图形学领域的高年级研究生和研究人员。对于从事渲染研究的人，本书提供了广泛的领域介绍，而 `pbrt` 源代码则提供了可在其上继续开发的基础，至少也可从中复用部分代码。对于在图形学其他领域工作的人，我们相信，深入理解渲染同样能提供有益的背景知识。
]

#parec[
  Our final audience is software developers in industry. Although many of the basic ideas in this book will be familiar to this audience, seeing explanations of the algorithms presented in the literate style may lead to new perspectives. `pbrt` also includes carefully crafted and debugged implementations of many algorithms that can be challenging to implement correctly; these should be of particular interest to experienced practitioners in rendering. We hope that delving into one particular organization of a complete and nontrivial rendering system will also be thought provoking to this audience.
][
  最后一类读者是业界的软件开发者。虽然他们可能已经熟悉书中的许多基本思想，但以文学编程形式呈现的算法讲解仍可能带来新的视角。`pbrt` 还包含许多不易正确实现的算法，这些实现经过精心编写和调试，应当尤其能引起经验丰富的渲染从业者的兴趣。我们也希望，深入考察一个完整且具有一定复杂性的渲染系统的具体组织方式，能启发这类读者思考。
]

== #ez_caption[Overview and Goals][概述与目标]
#parec[
  `pbrt` is based on the _ray-tracing_ algorithm. Ray tracing is an elegant technique that has its origins in lens making; Carl Friedrich Gauß traced rays through lenses by hand in the 19th century. Ray-tracing algorithms on computers follow the path of infinitesimal rays of light through the scene until they intersect a surface. This approach gives a simple method for finding the first visible object as seen from any particular position and direction and is the basis for many rendering algorithms.
][
  `pbrt` 基于_光线追踪_算法。这是一项优雅的技术，起源于透镜制造；早在 19 世纪，Carl Friedrich Gauß 就曾手工追踪光线穿过透镜的路径。计算机上的光线追踪算法沿着无穷细的光线在场景中前进，直到光线与表面相交。这为寻找从任意给定位置、沿任意给定方向首先可见的物体提供了简单的方法，也是许多渲染算法的基础。
]

#parec[
  `pbrt` was designed and implemented with three main goals in mind: it should be _complete_, it should be _illustrative_, and it should be _physically based_.
][
  设计和实现 `pbrt` 时，我们确立了三个主要目标：_完整_、_便于阐释_以及_基于物理_。
]

#parec[
  Completeness implies that the system should not lack key features found in high-quality commercial rendering systems. In particular, it means that important practical issues, such as antialiasing, robustness, numerical precision, and the ability to efficiently render complex scenes should all be addressed thoroughly. It is important to consider these issues from the start of the system's design, since these features can have subtle implications for all components of the system and can be quite difficult to retrofit into the system at a later stage of implementation.
][
  完整性意味着系统不应缺少高质量商业渲染系统具备的关键功能。尤其是抗锯齿、鲁棒性、数值精度以及高效渲染复杂场景的能力等重要实际问题，都应得到充分处理。从系统设计之初就考虑这些问题非常重要，因为这些功能可能对系统的各个组件产生微妙的影响；若等到实现后期再补入，往往会相当困难。
]

#parec[
  Our second goal means that we tried to choose algorithms, data structures, and rendering techniques with care and with an eye toward readability and clarity. Since their implementations will be examined by more readers than is the case for other rendering systems, we tried to select the most elegant algorithms that we were aware of and implement them as well as possible. This goal also required that the system be small enough for a single person to understand completely. We have implemented `pbrt` using an extensible architecture, with the core of the system implemented in terms of a set of carefully designed interface classes, and as much of the specific functionality as possible in implementations of these interfaces. The result is that one does not need to understand all of the specific implementations in order to understand the basic structure of the system. This makes it easier to delve deeply into parts of interest and skip others, without losing sight of how the overall system fits together.
][
  第二个目标意味着，我们在选择算法、数据结构和渲染技术时，力求审慎，并着眼于可读性与清晰度。相比其他渲染系统，这些实现将有更多读者仔细研读，因此我们尽量选择所知最优雅的算法，并尽可能妥善地实现。这个目标还要求系统的规模小到能让一个人完全理解。`pbrt` 采用可扩展架构：系统核心基于一组精心设计的接口类实现，具体功能则尽可能放在这些接口的实现中。这样，读者无需理解所有具体实现，也能掌握系统的基本结构；他们可以深入钻研感兴趣的部分，跳过其他部分，同时仍能理解整个系统如何协同工作。
]

#parec[
  There is a tension between the two goals of being complete and being illustrative. Implementing and describing every possible useful technique would not only make this book unacceptably long, but would also make the system prohibitively complex for most readers. In cases where `pbrt` lacks a particularly useful feature, we have attempted to design the architecture so that the feature could be added without altering the overall system design.
][
  完整性与便于阐释这两个目标之间存在矛盾。实现并讲解每一种可能有用的技术，不仅会使本书长得令人无法接受，还会使系统复杂到超出大多数读者所能掌握的程度。因此，对于 `pbrt` 缺少的某些特别有用的功能，我们尽量在架构设计上为其留出空间，使其能在不改变系统整体设计的情况下加入。
]

#parec[
  The basic foundations for physically based rendering are the laws of physics and their mathematical expression. `pbrt` was designed to use the correct physical units and concepts for the quantities it computes and the algorithms it implements. `pbrt` strives to compute images that are _physically correct_; they accurately reflect the lighting as it would be in a real-world version of the scene. #footnote[Of course, any computer simulation of physics requires carefully choosing approximations that trade off requirements for fidelity with computational efficiency.  See @Photorealistic-Rendering-and-the-Ray-Tracing-Algorithm for further discussion of the choices made in `pbrt`.] One advantage of the decision to use a physical basis is that it gives a concrete standard of program correctness: for simple scenes, where the expected result can be computed in closed form, if `pbrt` does not compute the same result, we know there must be a bug in the implementation. Similarly, if different physically based lighting algorithms in `pbrt` give different results for the same scene, or if `pbrt` does not give the same results as another physically based renderer, there is certainly an error in one of them. Finally, we believe that this physically based approach to rendering is valuable because it is rigorous. When it is not clear how a particular computation should be performed, physics gives an answer that guarantees a consistent result.
][
  基于物理的渲染以物理定律及其数学表达为基础。`pbrt` 从设计上就要求其计算的物理量和实现的算法采用正确的物理单位与概念。`pbrt` 力求生成_物理上正确_的图像，即准确反映场景若在现实世界中存在时的光照。#footnote[当然，任何物理过程的计算机模拟，都需要谨慎选择近似，在保真度要求与计算效率之间作出权衡。关于 `pbrt` 所作选择的进一步讨论，见 @Photorealistic-Rendering-and-the-Ray-Tracing-Algorithm。] 采用物理依据的一个好处，是它为程序正确性提供了明确标准：对于能够以闭式表达式算出预期结果的简单场景，如果 `pbrt` 算出的结果不同，就说明实现中必然有错误。同样，如果 `pbrt` 中不同的基于物理的光照算法对同一场景给出不同结果，或者 `pbrt` 与另一个基于物理的渲染器给出的结果不同，那么其中必有一方存在错误。最后，我们认为这种渲染方法的价值还在于其严谨性。当某项计算应如何进行尚不清楚时，物理学能够给出保证结果一致的答案。
]

#parec[
  Efficiency was given lower priority than these three goals. Since rendering systems often run for many minutes or hours in the course of generating an image, efficiency is clearly important. However, we have mostly confined ourselves to _algorithmic_ efficiency rather than low-level code optimization. In some cases, obvious micro-optimizations take a backseat to clear, well-organized code, although we did make some effort to optimize the parts of the system where most of the computation occurs.
][
  效率的优先级低于上述三个目标。渲染系统生成一幅图像往往要运行数分钟乃至数小时，因此效率显然很重要。不过，我们主要关注_算法_效率，而非底层代码优化。在某些情况下，明显可行的细微优化会让位于清晰、组织良好的代码；但我们确实也花了一些精力，优化了系统中承担大部分计算的部分。
]

#parec[
  In the course of presenting `pbrt` and discussing its implementation, we hope to convey some hard-learned lessons from years of rendering research and development. There is more to writing a good renderer than stringing together a set of fast algorithms; making the system both flexible and robust is a difficult task. The system's performance must degrade gracefully as more geometry or light sources are added to it or as any other axis of complexity is stressed.
][
  在介绍 `pbrt` 并讨论其实现的过程中，我们希望传达多年渲染研究与开发积累下来的宝贵经验。写好一个渲染器，远不止将一组快速算法串接起来；要使系统既灵活又稳健，是一项艰巨的任务。随着几何体或光源数量增加，或者其他方面的复杂度不断提高，系统的性能应当平缓退化。
]

#parec[
  The rewards for developing a system that addresses all these issues are enormous—it is a great pleasure to write a new renderer or add a new feature to an existing renderer and use it to create an image that could not be generated before. Our most fundamental goal in writing this book was to bring this opportunity to a wider audience. Readers are encouraged to use the system to render the example scenes in the `pbrt` software distribution as they progress through the book. Exercises at the end of each chapter suggest modifications to the system that will help clarify its inner workings and more complex projects to extend the system by adding new features.
][
  开发一个妥善处理上述所有问题的系统，回报是巨大的：编写新渲染器，或为现有渲染器添加新功能，再用它生成以前无法生成的图像，是一件极其愉快的事。让更多读者获得这样的机会，是我们撰写本书最根本的目标。我们鼓励读者在阅读过程中，用系统渲染 `pbrt` 软件发行版附带的示例场景。每章末尾的习题既提出一些系统修改任务，以帮助理解其内部工作原理，也提出更复杂的项目，让读者通过添加新功能扩展系统。
]

#parec[
  The website for this book is located at #link("https://pbrt.org/")[`pbrt`.org]. This site includes links to the `pbrt` source code, scenes that can be downloaded to render with `pbrt`, and a bug tracker, as well as errata. Any errors in this text that are not listed in the errata can be reported to the email address `authors@pbrt.org`. We greatly value your feedback!
][
  本书网站位于 #link("https://pbrt.org/")[`pbrt`.org]。网站提供 `pbrt` 源代码、可下载后用 `pbrt` 渲染的场景、问题跟踪器的链接，以及勘误表。若发现书中尚未列入勘误表的错误，可通过电子邮件 `authors@pbrt.org` 报告。我们十分重视读者的反馈！
]

== #ez_caption[Changes Between The First and Second Editions][第一版到第二版的变化]
#parec[
  Six years passed between the publication of the first edition of this book in 2004 and the second edition in 2010. In that time, thousands of copies of the book were sold, and the `pbrt` software was downloaded thousands of times from the book's website. The `pbrt` user base gave us a significant amount of feedback and encouragement, and our experience with the system guided many of the decisions we made in making changes between the version of `pbrt` presented in the first edition and the version in the second edition. In addition to a number of bug fixes, we also made several significant design changes and enhancements:
][
  从 2004 年出版第一版，到 2010 年出版第二版，六年过去了。其间，本书售出了数千册，`pbrt` 软件也从本书网站被下载了数千次。`pbrt` 用户群给予我们大量反馈和鼓励；我们使用系统的经验，也指导了从第一版所介绍的 `pbrt` 版本向第二版改进时的许多决策。除修复若干错误外，我们还做了几项重要的设计变更与增强：
]

#parec[
  - #emph[Removal of the plugin architecture]: The first version of `pbrt` used a runtime plugin architecture to dynamically load code for implementations of objects like shapes, lights, integrators, cameras, and other objects that were used in the scene currently being rendered. This approach allowed users to extend `pbrt` with new object types (e.g., new shape primitives) without recompiling the entire rendering system. This approach initially seemed elegant, but it complicated the task of supporting `pbrt` on multiple platforms and it made debugging more difficult. The only new usage scenario that it truly enabled (binary-only distributions of `pbrt` or binary plugins) was actually contrary to our pedagogical and open-source goals. Therefore, the plugin architecture was dropped in this edition.
][
  - _移除插件架构_：`pbrt` 第一版采用运行时插件架构，动态加载当前渲染场景中所用形状、光源、积分器、相机等对象的实现代码。这让用户无需重新编译整个渲染系统，就能用新的对象类型（例如新的形状图元）扩展 `pbrt`。这种方法起初看起来很优雅，却增加了多平台支持和调试的难度。它真正带来的唯一新增使用场景——只分发 `pbrt` 二进制程序或二进制插件——实际上与我们的教学和开源目标相悖。因此，第二版移除了插件架构。
]

#parec[
  - _Removal of the image-processing pipeline_: The first version of `pbrt` provided a tone-mapping interface that converted high-dynamic-range (HDR) floating-point output images directly into low-dynamic-range TIFFs for display. This functionality made sense in 2004, as support for HDR images was still sparse. In 2010, however, advances in digital photography had made HDR images commonplace. Although the theory and practice of tone mapping are elegant and worth learning, we decided to focus the new book exclusively on the process of image formation and skip the topic of image display. Interested readers should consult the book written by Reinhard et al. @reinhard2010high for a thorough and modern treatment of the HDR image display process.
][
  - _移除图像处理流水线_：`pbrt` 第一版提供色调映射接口，将高动态范围（HDR）的浮点输出图像直接转换为低动态范围 TIFF 图像以供显示。在对 HDR 图像支持尚少的 2004 年，这项功能是合理的。然而，到 2010 年，数码摄影的发展已经使 HDR 图像十分普遍。尽管色调映射的理论与实践都很优雅，也值得学习，我们仍决定让新版专注于图像形成过程，不再讨论图像显示。有兴趣的读者可参阅 Reinhard 等人的著作（@reinhard2010high），其中对 HDR 图像显示过程作了全面而现代的论述。
]


#parec[
  - _Task parallelism_: Multicore architectures became ubiquitous, and we felt that `pbrt` would not remain relevant without the ability to scale to the number of locally available cores. We also hoped that the parallel programming implementation details documented in this book would help graphics programmers understand some of the subtleties and complexities in writing scalable parallel code.
][
  - _任务并行_：多核架构已十分普遍，我们认为，如果 `pbrt` 不能随本机可用核心数的增加而扩展，就会失去实用价值。我们也希望，书中讲解的并行编程实现细节能帮助图形程序员理解编写可扩展并行代码时的微妙之处与复杂性。
]

#parec[
  - _Appropriateness for “production” rendering_: The first version of `pbrt` was intended exclusively as a pedagogical tool and a stepping-stone for rendering research. Indeed, we made a number of decisions in preparing the first edition that were contrary to use in a production environment, such as limited support for image-based lighting, no support for motion blur, and a photon mapping implementation that was not robust in the presence of complex lighting. With much improved support for these features as well as support for subsurface scattering and Metropolis light transport, we feel that with the second edition, `pbrt` became much more suitable for rendering very high-quality images of complex environments.
][
  - _适用于“生产”渲染_：`pbrt` 第一版纯粹是教学工具和渲染研究的起点。事实上，我们在准备第一版时做出的若干决定并不利于生产环境中的使用，例如对基于图像的照明支持有限、不支持运动模糊，以及光子映射实现在复杂光照下不够稳健。大幅改进这些功能，并加入次表面散射和 Metropolis 光传输支持后，我们认为第二版 `pbrt` 已更加适合渲染复杂环境中的高质量图像。
]

== #ez_caption[Changes Between The Second and Third Editions][第二版到第三版的变化]


#parec[
  With the passage of another six years, it was time to update and extend the book and the `pbrt` system. We continued to learn from readers' and users' experiences to better understand which topics were most useful to cover. Further, rendering research continued apace; many parts of the book were due for an update to reflect current best practices. We made significant improvements on a number of fronts:
][
  又过了六年，本书和 `pbrt` 系统再次需要更新与扩充。我们继续从读者和用户的经验中学习，更好地理解哪些主题最值得讲解。同时，渲染研究持续快速发展，书中许多部分也需要更新，以反映当时的最佳实践。我们在多个方面做出了重大改进：
]

#parec[
  - _Bidirectional light transport_: The third version of `pbrt` added a bidirectional path tracer, including full support for volumetric light transport and multiple importance sampling to weight paths. An all-new Metropolis light transport integrator used components of the bidirectional path tracer, allowing for a particularly succinct implementation of that algorithm.
][
  - _双向光传输_：`pbrt` 第三版新增双向路径追踪器，完整支持体积光传输，并使用多重重要性采样为路径加权。全新的 Metropolis 光传输积分器复用了双向路径追踪器的组件，使该算法的实现格外简洁。
]

#parec[
  - _Subsurface scattering_: The appearance of many objects—notably, skin and translucent objects—is a result of subsurface light transport. Our implementation of subsurface scattering in the second edition reflected the state of the art in the early 2000s; we thoroughly updated both BSSRDF models and our subsurface light transport algorithms to reflect the progress made in ten subsequent years of research.
][
  - _次表面散射_：许多物体，尤其是皮肤和半透明物体，其外观是次表面光传输的结果。第二版中的次表面散射实现反映了 21 世纪初的先进水平；我们全面更新了 BSSRDF 模型和次表面光传输算法，以反映此后十年研究取得的进展。
]

#parec[
  - _Numerically robust intersections_: The effects of floating-point round-off error in geometric ray intersection calculations have been a long-standing challenge in ray tracing: they can cause small errors to be present throughout the image. We focused on this issue and derived conservative (but tight) bounds of this error, which made our implementation more robust to this issue than previous rendering systems.
][
  - _数值稳健的求交运算_：光线与几何体求交时的浮点舍入误差，一直是光线追踪面临的难题，它们可能在整幅图像中造成细小错误。我们着力研究了这一问题，推导出保守但紧致的误差界，使我们的实现在这一问题上比以往的渲染系统更加稳健。
]

#parec[
  - _Participating media representation_: We significantly improved the way that scattering media are described and represented in the system; this allows for more accurate results with nested scattering media. A new sampling technique enabled unbiased rendering of heterogeneous media in a way that cleanly integrated with all of the other parts of the system.
][
  - _参与介质的表示_：我们显著改进了系统描述和表示散射介质的方式，使嵌套散射介质的结果更准确。一种新的采样技术实现了非均匀介质的无偏渲染，并能自然地融入系统的其他部分。
]

#parec[
  - _Measured materials_: This edition added a new technique to represent and evaluate measured materials using a sparse frequency-space basis. This approach is convenient because it allows for exact importance sampling, which was not possible with the representation used in the previous edition.
][
  - _实测材质_：这一版增加了一项新技术，用稀疏的频域基来表示和求值实测材质。这种方法的便利之处在于支持精确的重要性采样，而上一版采用的表示无法做到这一点。
]

#parec[
  - _Photon mapping_: A significant step forward for photon mapping algorithms has been the development of variants that do not require storing all of the photons in memory. We replaced `pbrt`'s photon mapping algorithm with an implementation based on stochastic progressive photon mapping, which efficiently renders many difficult light transport effects.
][
  - _光子映射_：光子映射算法的一项重要进展，是出现了无需将全部光子存入内存的变体。我们将 `pbrt` 的光子映射算法替换为基于随机渐进光子映射的实现，能够高效渲染许多难以处理的光传输效果。
]

#parec[
  - _Sample generation algorithms_: The distribution of sample values used for numerical integration in rendering algorithms can have a surprisingly large effect on the quality of the final results. We thoroughly updated our treatment of this topic, covering new approaches and efficient implementation techniques in more depth than before.
][
  - _样本生成算法_：渲染算法中用于数值积分的样本值分布，可能对最终结果的质量产生出乎意料的巨大影响。我们全面更新了这一主题的讲解，比以往更深入地介绍新方法和高效实现技术。
]

#parec[
  Many other parts of the system were improved and updated to reflect progress in the field: microfacet reflection models were treated in more depth, with much better sampling techniques; a new “curve” shape was added for modeling hair and other fine geometry; and a new camera model that simulates realistic lens systems was made available. Throughout the book, we made numerous smaller changes to more clearly explain and illustrate the key concepts in physically based rendering systems like `pbrt`.
][
  系统的许多其他部分也经过改进和更新，以反映领域内的进展：更深入地讨论微表面反射模型，并采用了好得多的采样技术；新增“曲线”形状，用于为毛发等精细几何体建模；还提供了模拟真实透镜系统的新相机模型。全书各处也做了许多小幅修改，以更清晰地解释和阐明 `pbrt` 这类基于物理的渲染系统中的关键概念。
]

== #ez_caption[Changes Between The Third and Fourth Editions][第三版到第四版的变化]
#parec[
  Innovation in rendering algorithms has shown no sign of slowing down, and so in 2019 we began focused work on a fourth edition of the text. Not only does almost every chapter include substantial additions, but we have updated the order of chapters and ideas introduced, bringing Monte Carlo integration and the basic ideas of path tracing to the fore rather than saving them for the end.
][
  渲染算法的创新没有放缓迹象，因此我们在 2019 年开始集中精力编写第四版。几乎每一章都有大量新增内容，我们还调整了章节和概念的介绍顺序，将蒙特卡洛积分与路径追踪的基本思想提前介绍，而不再留到最后。
]

#parec[
  Capabilities of the system that have seen especially significant improvements include:
][
  系统中改进尤为显著的功能包括：
]

#parec[
  - _Volumetric scattering_: We have updated the algorithms that model scattering from participating media to the state of the art, adding support for emissive volumes, efficient sampling of volumes with varying densities, and robust support for chromatic media, where the scattering properties vary by wavelength.
][
  - _体积散射_：我们将参与介质散射的建模算法更新到先进水平，增加了对发光体积的支持，能够高效采样密度变化的体积，并稳健地支持散射性质随波长变化的有色介质。
]

#parec[
  - _Spectral rendering_: We have excised all use of RGB color for lighting calculations; `pbrt` now performs lighting calculations exclusively in terms of samples of wavelength-dependent spectral distributions. Not only is this approach more physically accurate than using RGB, but it also allows `pbrt` to accurately model effects like dispersion.
][
  - _光谱渲染_：我们完全移除了光照计算中对 RGB 颜色的使用；现在，`pbrt` 只通过对随波长变化的光谱分布进行采样来计算光照。这不仅在物理上比使用 RGB 更准确，还让 `pbrt` 能准确模拟色散等现象。
]

#parec[
  - _Reflection models_: Our coverage of the foundations of BSDFs and reflection models has been extensively revised, and we have expanded the range of BSDFs covered to include one that accurately models reflection from hair and another that models scattering from layered materials. The measured BRDF follows a new approach that can represent a wide set of materials' reflection spectra.
][
  - _反射模型_：我们大幅修订了 BSDF 基础与反射模型的讲解，并扩充了所介绍的 BSDF 类型，包括准确模拟毛发反射的模型，以及模拟分层材质散射的模型。实测 BRDF 采用了新的方法，能够表示广泛材质的反射光谱。
]

#parec[
  - _Light sampling_: Not only have we improved the algorithms for sampling points on individual light sources to better reflect the state of the art, but this edition also includes support for _many-light sampling_, which makes it possible to efficiently render scenes with thousands or millions of light sources by carefully sampling just a few of them.
][
  - _光源采样_：我们不仅改进了在单个光源上采样点的算法，使其更好地反映先进水平，还加入了对_多光源采样_的支持。即使场景包含数千乃至数百万个光源，也可以通过精心选取其中少数光源进行采样来高效渲染。
]

#parec[
  - _GPU rendering_: This version of `pbrt` adds support for rendering on GPUs, which can provide 10–100 times higher ray tracing performance than CPUs. We have implemented this capability in a way so that almost all of the code presented in the book runs on both CPUs and GPUs, which has made it possible to localize discussion of GPU-related issues to @wavefront-rendering-on-gpus .
][
  - _GPU 渲染_：这一版 `pbrt` 加入了 GPU 渲染支持，其光线追踪性能可达 CPU 的 10–100 倍。我们使书中几乎所有代码都能同时在 CPU 和 GPU 上运行，从而得以将 GPU 相关问题的讨论集中在 @wavefront-rendering-on-gpus。
]

#parec[
  The system has seen numerous other improvements and additions, including a new bilinear patch shape, many updates to the sample-generation algorithms that are at the heart of Monte Carlo integration, support for outputting auxiliary information at each pixel about the visible surface geometry and reflection properties, and many more small improvements to the system.
][
  系统还有许多其他改进和新增功能，包括新的双线性面片形状、多项针对蒙特卡洛积分核心——样本生成算法——的更新，以及在每个像素输出可见表面几何与反射性质等辅助信息的支持，此外还有许多细节改进。
]

== #ez_caption[Acknowledgments][致谢]
#parec[
  Pat Hanrahan has contributed to this book in more ways than we could hope to acknowledge; we owe a profound debt to him. He tirelessly argued for clean interfaces and finding the right abstractions to use throughout the system, and his understanding of and approach to rendering deeply influenced its design. His willingness to use `pbrt` and this manuscript in his rendering course at Stanford was enormously helpful, particularly in the early years of its life when it was still in very rough form; his feedback throughout this process has been crucial for bringing the text to its current state. Finally, the group of people that Pat helped assemble at the Stanford Graphics Lab, and the open environment that he fostered, made for an exciting, stimulating, and fertile environment. Matt and Greg both feel extremely privileged to have been there.
][
  Pat Hanrahan 对本书的贡献多得难以尽述，我们深深感激他。他始终坚持采用清晰的接口，并为整个系统寻找恰当的抽象；他对渲染的理解与研究方法深刻影响了系统设计。他愿意在斯坦福大学的渲染课程中使用 `pbrt` 和本书手稿，对我们帮助极大，尤其是在系统早期尚十分粗糙的时候。他在整个过程中的反馈，是本书达到目前水平的关键。最后，Pat 帮助汇聚到斯坦福图形实验室的同仁，以及他营造的开放氛围，共同造就了一个令人振奋、富有启发、适合研究的环境。Matt 和 Greg 都深感有幸曾在那里工作。
]

#parec[
  We owe a debt of gratitude to the many students who used early drafts of this book in courses at Stanford and the University of Virginia between 1999 and 2004. These students provided an enormous amount of feedback about the book and `pbrt`. The teaching assistants for these courses deserve special mention: Tim Purcell, Mike Cammarano, Ian Buck, and Ren Ng at Stanford, and Nolan Goodnight at Virginia. A number of students in those classes gave particularly valuable feedback and sent bug reports and bug fixes; we would especially like to thank Evan Parker and Phil Beatty. A draft of the manuscript of this book was used in classes taught by Bill Mark and Don Fussell at the University of Texas, Austin, and Raghu Machiraju at Ohio State University; their feedback was invaluable, and we are grateful for their adventurousness in incorporating this system into their courses, even while it was still being edited and revised.
][
  我们感谢 1999 至 2004 年间在斯坦福大学和弗吉尼亚大学课程中使用本书早期草稿的众多学生。他们对本书和 `pbrt` 提供了大量反馈。值得特别感谢的助教有斯坦福大学的 Tim Purcell、Mike Cammarano、Ian Buck 和 Ren Ng，以及弗吉尼亚大学的 Nolan Goodnight。一些学生提出了极有价值的意见，并提交了错误报告和修复；我们尤其感谢 Evan Parker 和 Phil Beatty。得克萨斯大学奥斯汀分校的 Bill Mark、Don Fussell，以及俄亥俄州立大学的 Raghu Machiraju，也在课程中采用了本书草稿。他们的反馈十分宝贵；在系统仍处于编辑修订阶段时就勇于将其纳入课程，我们对此深表感谢。
]

#parec[
  Matt Pharr would like to acknowledge colleagues and co-workers in rendering-related endeavors who have been a great source of education and who have substantially influenced his approach to writing renderers and his understanding of the field. Particular thanks go to Craig Kolb, who provided a cornerstone of Matt's early computer graphics education through the freely available source code to the `rayshade` ray-tracing system, and Eric Veach, who has also been generous with his time and expertise. Thanks also to Doug Shult and Stan Eisenstat for formative lessons in mathematics and computer science during high school and college, respectively, and most important to Matt's parents, for the education they have provided and continued encouragement along the way. Finally, thanks to NVIDIA for supporting the preparation of both the first and this latest edition of the book; at NVIDIA, thanks to Nick Triantos and Jayant Kolhe for their support through the final stages of the preparation of the first edition and thanks to Aaron Lefohn, David Luebke, and Bill Dally for their support of work on the fourth edition.
][
  Matt Pharr 感谢与他共同从事渲染相关工作的同事。他从他们身上学到许多，他们也深刻影响了他编写渲染器的方法和对这一领域的理解。特别感谢 Craig Kolb：他免费开放的 `rayshade` 光线追踪系统源代码，是 Matt 早期图形学学习的重要基石；也感谢 Eric Veach 慷慨投入时间、分享专业知识。此外，感谢 Doug Shult 和 Stan Eisenstat 分别在高中和大学时期给予他的数学与计算机科学启蒙；最要感谢的是 Matt 的父母，感谢他们的教育和一路以来的鼓励。最后，感谢 NVIDIA 支持第一版和本次最新版的编写工作；感谢 NVIDIA 的 Nick Triantos 和 Jayant Kolhe 在第一版编写的最后阶段给予支持，也感谢 Aaron Lefohn、David Luebke 和 Bill Dally 对第四版工作的支持。
]

#parec[
  Greg Humphreys is very grateful to all the professors and TAs who tolerated him when he was an undergraduate at Princeton. Many people encouraged his interest in graphics, specifically Michael Cohen, David Dobkin, Adam Finkelstein, Michael Cox, Gordon Stoll, Patrick Min, and Dan Wallach. Doug Clark, Steve Lyon, and Andy Wolfe also supervised various independent research boondoggles without even laughing once. Once, in a group meeting about a year-long robotics project, Steve Lyon became exasperated and yelled, “Stop telling me why it can't be done, and figure out how to do it!”—an impromptu lesson that will never be forgotten. Eric Ristad fired Greg as a summer research assistant after his freshman year (before the summer even began), pawning him off on an unsuspecting Pat Hanrahan and beginning an advising relationship that would span 10 years and both coasts. Finally, Dave Hanson taught Greg that literate programming was a great way to work and that computer programming can be a beautiful and subtle art form.
][
  Greg Humphreys 十分感谢他在普林斯顿大学读本科时包容他的所有教授和助教。许多人鼓励了他对图形学的兴趣，尤其是 Michael Cohen、David Dobkin、Adam Finkelstein、Michael Cox、Gordon Stoll、Patrick Min 和 Dan Wallach。Doug Clark、Steve Lyon 和 Andy Wolfe 还指导过他那些瞎折腾的独立研究，竟然一次也没笑话他。在一次讨论为期一年的机器人项目的组会上，Steve Lyon 忍无可忍地喊道：“别再告诉我为什么做不到，去想办法把它做出来！”——这堂即兴的课让他终生难忘。大一结束后，Eric Ristad 解除了 Greg 的暑期研究助理职务，甚至当时暑假还没开始，就把他转交给毫不知情的 Pat Hanrahan，由此开始了一段跨越美国东西海岸、长达十年的师生关系。最后，Dave Hanson 让 Greg 明白，文学编程是一种很好的工作方式，计算机编程也可以是一门优美而精妙的艺术。
]

#parec[
  Wenzel Jakob was excited when the first edition of `pbrt` arrived in his mail during his undergraduate studies in 2004. Needless to say, this had a lasting effect on his career—thus Wenzel would like to begin by thanking his co-authors for inviting him to become a part of the third and fourth editions of this book. Wenzel is extremely indebted to Steve Marschner, who was his Ph.D. advisor during a fulfilling five years at Cornell University. Steve brought him into the world of research and remains a continuous source of inspiration. Wenzel is also thankful for the guidance and stimulating research environment created by the other members of the graphics group, including Kavita Bala, Doug James, and Bruce Walter. Wenzel spent a wonderful postdoc with Olga Sorkine Hornung, who introduced him to geometry processing. Olga's support for Wenzel's involvement in the third edition of this book is deeply appreciated.
][
  2004 年，还在读本科的 Wenzel Jakob 收到邮寄来的第一版 `pbrt` 时十分兴奋。不言而喻，这对他的职业生涯产生了持久影响。因此，Wenzel 首先要感谢共同作者邀请他参与本书第三版和第四版。Wenzel 尤其感谢 Steve Marschner：在康奈尔大学充实的五年里，Steve 是他的博士生导师，带他走进研究世界，并至今不断给予他启发。他也感谢图形学组的其他成员，包括 Kavita Bala、Doug James 和 Bruce Walter，感谢他们的指导以及富有启发性的研究环境。Wenzel 在 Olga Sorkine Hornung 的指导下度过了一段美好的博士后时光，由她引入几何处理领域。他深深感谢 Olga 对他参与本书第三版的支持。
]

#parec[
  We would especially like to thank the reviewers who read drafts in their entirety; all had insightful and constructive feedback about the manuscript at various stages of its progress. For providing feedback on both the first and second editions of the book, thanks to Ian Ashdown, Per Christensen, Doug Epps, Dan Goldman, Eric Haines, Erik Reinhard, Pete Shirley, Peter-Pike Sloan, Greg Ward, and a host of anonymous reviewers. For the second edition, thanks to Janne Kontkanen, Bill Mark, Nelson Max, and Eric Tabellion. For the fourth edition, we are grateful to Thomas Müller and Per Christensen, who both offered extensive feedback that has measurably improved the final version.
][
  我们尤其感谢完整阅读过草稿的审稿人，他们在手稿发展的各个阶段都提供了富有洞见和建设性的反馈。感谢 Ian Ashdown、Per Christensen、Doug Epps、Dan Goldman、Eric Haines、Erik Reinhard、Pete Shirley、Peter-Pike Sloan、Greg Ward 和众多匿名审稿人对第一版和第二版的反馈。第二版还要感谢 Janne Kontkanen、Bill Mark、Nelson Max 和 Eric Tabellion。第四版则要感谢 Thomas Müller 和 Per Christensen，他们的大量反馈切实改善了最终版本。
]

#parec[
  Many experts have kindly explained subtleties in their work to us and guided us to best practices. For the first and second editions, we are also grateful to Don Mitchell, for his help with understanding some of the details of sampling and reconstruction; Thomas Kollig and Alexander Keller, for explaining the finer points of low-discrepancy sampling; Christer Ericson, who had a number of suggestions for improving our kd-tree implementation; and Christophe Hery and Eugene d'Eon for helping us with the nuances of subsurface scattering.
][
  许多专家热心地为我们解释其工作中的微妙之处，并指导我们采用最佳实践。在第一版和第二版中，我们还要感谢 Don Mitchell 帮助理解采样与重建的一些细节；Thomas Kollig 和 Alexander Keller 解释低差异采样的精妙之处；Christer Ericson 提出多项改进 kd 树实现的建议；以及 Christophe Hery 和 Eugene d'Eon 帮助我们理解次表面散射的细微之处。
]

#parec[
  For the third edition, we would especially like to thank Leo Grünschloß for reviewing our sampling chapter; Alexander Keller for suggestions about topics for that chapter; Eric Heitz for extensive help with details of microfacets and reviewing our text on that topic; Thiago Ize for thoroughly reviewing the text on floating-point error; Tom van Bussel for reporting a number of errors in our BSSRDF code; Ralf Habel for reviewing our BSSRDF text; and Toshiya Hachisuka and Anton Kaplanyan for extensive review and comments about our light transport chapters.
][
  对于第三版，我们特别感谢 Leo Grünschloß 审阅采样一章；Alexander Keller 就该章选题提出建议；Eric Heitz 在微表面细节方面提供大量帮助，并审阅相关文字；Thiago Ize 全面审阅浮点误差部分；Tom van Bussel 报告 BSSRDF 代码中的多处错误；Ralf Habel 审阅 BSSRDF 部分；以及 Toshiya Hachisuka 和 Anton Kaplanyan 全面审阅光传输各章并提出意见。
]

#parec[
  For the fourth edition, thanks to Alejandro Conty Estevez for reviewing our treatment of many-light sampling; Eugene d'Eon, Bailey Miller, and Jan Novák for comments on the volumetric scattering chapters; Eric Haines, Simon Kallweit, Martin Stich, and Carsten Wächter for reviewing the chapter on GPU rendering; Karl Li for feedback on a number of chapters; Tzu-Mao Li for his review of our discussion of inverse and differentiable rendering; Fabrice Rousselle for feedback on machine learning and rendering; and Gurprit Singh for comments on our discussion of Fourier analysis of Monte Carlo integration. We also appreciate extensive comments and suggestions from Jeppe Revall Frisvad on `pbrt`'s treatment of reflection models in previous editions.
][
  对于第四版，感谢 Alejandro Conty Estevez 审阅多光源采样部分；Eugene d'Eon、Bailey Miller 和 Jan Novák 对体积散射各章提出意见；Eric Haines、Simon Kallweit、Martin Stich 和 Carsten Wächter 审阅 GPU 渲染一章；Karl Li 对多个章节提供反馈；Tzu-Mao Li 审阅逆渲染与可微渲染的讨论；Fabrice Rousselle 对机器学习与渲染提供反馈；以及 Gurprit Singh 对蒙特卡洛积分的傅里叶分析讨论提出意见。我们也感谢 Jeppe Revall Frisvad 对以往各版中 `pbrt` 的反射模型处理提出的大量意见和建议。
]

#parec[
  For improvements to `pbrt`'s implementation in this edition, thanks to Pierre Moreau for his efforts in debugging `pbrt`'s GPU support on Windows and to Jim Price, who not only found and fixed numerous bugs in the early release of `pbrt`'s source code, but who also contributed a better representation of chromatic volumetric media than our original implementation. We are also very appreciative of Anders Langlands and Luca Fascione of Weta Digital for providing an implementation of their _PhysLight_ system, which has been incorporated into `pbrt`'s `PixelSensor` class and light source implementations.
][
  关于这一版 `pbrt` 实现的改进，感谢 Pierre Moreau 调试 Windows 上的 GPU 支持；也感谢 Jim Price，他不仅发现并修复了早期发布的 `pbrt` 源代码中的大量错误，还贡献了一种比原有实现更好的有色体积介质表示。我们也十分感谢 Weta Digital 的 Anders Langlands 和 Luca Fascione 提供 _PhysLight_ 系统的实现，它已整合到 `pbrt` 的 `PixelSensor` 类和光源实现中。
]

#parec[
  Many people have reported errors in the text of previous editions or bugs in `pbrt`. We'd especially like to thank Solomon Boulos, Stephen Chenney, Per Christensen, John Danks, Mike Day, Kevin Egan, Volodymyr Kachurovskyi, Kostya Smolenskiy, Ke Xu, and Arek Zimny, who have been especially prolific.
][
  许多人报告了以往各版中的文字错误或 `pbrt` 中的程序错误。我们尤其感谢 Solomon Boulos、Stephen Chenney、Per Christensen、John Danks、Mike Day、Kevin Egan、Volodymyr Kachurovskyi、Kostya Smolenskiy、Ke Xu 和 Arek Zimny，他们报告的问题特别多。
]

#parec[
  For their suggestions and bug reports, we would also like to thank Rachit Agrawal, Frederick Akalin, Thomas de Bodt, Mark Bolstad, Brian Budge, Jonathon Cai, Bryan Catanzaro, Tzu-Chieh Chang, Mark Colbert, Yunjian Ding, Tao Du, Marcos Fajardo, Shaohua Fan, Luca Fascione, Etienne Ferrier, Nigel Fisher, Jeppe Revall Frisvad, Robert G. Graf, Asbjørn Heid, Steve Hill, Wei-Feng Huang, John “Spike” Hughes, Keith Jeffery, Greg Johnson, Aaron Karp, Andrew Kensler, Alan King, Donald Knuth, Martin Kraus, Chris Kulla, Murat Kurt, Larry Lai, Morgan McGuire, Craig McNaughton, Don Mitchell, Swaminathan Narayanan, Anders Nilsson, Jens Olsson, Vincent Pegoraro, Srinath Ravichandiran, Andy Selle, Sébastien Speierer, Nils Thuerey, Eric Veach, Ingo Wald, Zejian Wang, Xiong Wei, Wei-Wei Xu, Tizian Zeltner, and Matthias Zwicker. Finally, we would like to thank the _LuxRender_ developers and the _LuxRender_ community, particularly Terrence Vergauwen, Jean-Philippe Grimaldi, and Asbjørn Heid; it has been a delight to see the rendering system they have built from `pbrt`'s foundation, and we have learned from reading their source code and implementations of new rendering algorithms.
][
  我们还要感谢以下人士提出建议和报告错误：Rachit Agrawal、Frederick Akalin、Thomas de Bodt、Mark Bolstad、Brian Budge、Jonathon Cai、Bryan Catanzaro、Tzu-Chieh Chang、Mark Colbert、Yunjian Ding、Tao Du、Marcos Fajardo、Shaohua Fan、Luca Fascione、Etienne Ferrier、Nigel Fisher、Jeppe Revall Frisvad、Robert G. Graf、Asbjørn Heid、Steve Hill、Wei-Feng Huang、John “Spike” Hughes、Keith Jeffery、Greg Johnson、Aaron Karp、Andrew Kensler、Alan King、Donald Knuth、Martin Kraus、Chris Kulla、Murat Kurt、Larry Lai、Morgan McGuire、Craig McNaughton、Don Mitchell、Swaminathan Narayanan、Anders Nilsson、Jens Olsson、Vincent Pegoraro、Srinath Ravichandiran、Andy Selle、Sébastien Speierer、Nils Thuerey、Eric Veach、Ingo Wald、Zejian Wang、Xiong Wei、Wei-Wei Xu、Tizian Zeltner 和 Matthias Zwicker。最后，感谢 _LuxRender_ 的开发者和社区，尤其是 Terrence Vergauwen、Jean-Philippe Grimaldi 和 Asbjørn Heid；看到他们在 `pbrt` 基础上构建的渲染系统，我们十分高兴，也从阅读他们的源代码和新渲染算法实现中获益良多。
]

#parec[
  Special thanks to Martin Preston and Steph Bruning from Framestore for their help with our being able to use a frame from _Gravity_ (image courtesy of Warner Bros. and Framestore), and to Weta Digital for their help with the frame from _Alita: Battle Angel_ (© 2018 Twentieth Century Fox Film Corporation, All Rights Reserved).
][
  特别感谢 Framestore 的 Martin Preston 和 Steph Bruning 帮助我们使用《地心引力》的一帧画面（图片由 Warner Bros. 和 Framestore 提供），也感谢 Weta Digital 帮助我们使用《阿丽塔：战斗天使》的一帧画面（© 2018 Twentieth Century Fox Film Corporation，保留所有权利）。
]

=== #ez_caption[Production][出版制作]
#parec[
  For the production of the first edition, we would also like to thank our editor Tim Cox for his willingness to take on this slightly unorthodox project and for both his direction and patience throughout the process. We are very grateful to Elisabeth Beller (project manager), who went well beyond the call of duty for the book; her ability to keep this complex project in control and on schedule was remarkable, and we particularly thank her for the measurable impact she had on the quality of the final result. Thanks also to Rick Camp (editorial assistant) for his many contributions along the way. Paul Anagnostopoulos and Jacqui Scarlott at Windfall Software did the book's composition; their ability to take the authors' homebrew literate programming file format and turn it into high-quality final output while also juggling the multiple unusual types of indexing we asked for is greatly appreciated. Thanks also to Ken DellaPenta (copyeditor) and Jennifer McClain (proofreader), as well as to Max Spector at Chen Design (text and cover designer) and Steve Rath (indexer).
][
  在第一版的出版制作中，我们还要感谢编辑 Tim Cox 愿意接手这个略显非传统的项目，并在整个过程中给予指导、保持耐心。十分感谢项目经理 Elisabeth Beller，她为本书付出的努力远超职责要求；她出色地掌控了这个复杂项目，使其按计划推进，我们尤其感谢她对成书质量带来的切实改善。也感谢编辑助理 Rick Camp 在整个过程中作出的诸多贡献。Windfall Software 的 Paul Anagnostopoulos 和 Jacqui Scarlott 负责本书排版；他们将作者自制的文学编程文件格式转换为高质量的成品，同时兼顾我们要求的多种特殊索引，对此我们深表感谢。此外，感谢文字编辑 Ken DellaPenta、校对员 Jennifer McClain、Chen Design 的正文与封面设计师 Max Spector，以及索引编制者 Steve Rath。
]

#parec[
  For the second edition, we would like to thank Greg Chalson, who talked us into expanding and updating the book; Greg also ensured that Paul Anagnostopoulos at Windfall Software would again do the book's composition. We would like to thank Paul again for his efforts in working with this book's production complexity. Finally, we would also like to thank Todd Green, Paul Gottehrer, and Heather Scherer at Elsevier.
][
  对于第二版，感谢 Greg Chalson 说服我们扩充和更新本书，并确保 Windfall Software 的 Paul Anagnostopoulos 再次负责排版。我们再次感谢 Paul 为应对本书复杂的制作要求所付出的努力。最后，也感谢 Elsevier 的 Todd Green、Paul Gottehrer 和 Heather Scherer。
]

#parec[
  For the third edition, we would like to thank Todd Green, who oversaw that go-round, and Amy Invernizzi, who kept the train on the rails throughout that process. We were delighted to have Paul Anagnostopoulos at Windfall Software part of this process for a third time; his efforts have been critical to the book's high production value, which is so important to us.
][
  对于第三版，感谢统筹本轮工作的 Todd Green，以及让整个制作过程始终顺利推进的 Amy Invernizzi。我们很高兴 Windfall Software 的 Paul Anagnostopoulos 第三次参与；我们十分重视本书的制作质量，而他的努力对此至关重要。
]

#parec[
  The fourth edition saw us moving to MIT Press; many thanks to Elizabeth Swayze for her enthusiasm for bringing us on board, guidance through the production process, and ensuring that Paul Anagnostopoulos would again handle composition. Our deepest thanks to Paul for coming back for one more edition with us, and many thanks as well to MaryEllen Oliver for her superb work on copyediting and proofreading.
][
  第四版改由 MIT Press 出版。十分感谢 Elizabeth Swayze 热情地接纳我们，指导制作流程，并确保 Paul Anagnostopoulos 再次负责排版。我们衷心感谢 Paul 又一次回来与我们合作，也十分感谢 MaryEllen Oliver 出色的文字编辑与校对工作。
]

=== #ez_caption[The Online Edition][在线版]


#parec[
  As of November 1, 2023, the full text of the fourth edition is available online for free. Many thanks to MIT Press and Elizabeth Swayze for their support of a freely-available version of the book.
][
  自 2023 年 11 月 1 日起，第四版全文可在线免费阅读。十分感谢 MIT Press 和 Elizabeth Swayze 对本书免费在线版的支持。
]

#parec[
  A number of open source systems have been instrumental to the development of the online version of _Physically Based Rendering_. We'd specifically like to thank the developers of #link("https://getbootstrap.com/")[Bootstrap], #link("https://jeri.io/")[JERI], #link("https://www.mathjax.org/")[MathJax] and #link("https://jquery.com/")[JQuery]. We'd also like to thank Impallari Type for the design of the #link("https://fonts.google.com/specimen/Domine")[Domine] font that we use for body text; Christian Robertson for the design of the #link("https://fonts.google.com/specimen/Roboto+Mono")[Roboto Mono] font that we use for code; and the designers of the #link("https://fontawesome.com/")[Font Awesome] fonts.
][
  多个开源系统对《基于物理的渲染》在线版的开发起到了重要作用。我们特别感谢 #link("https://getbootstrap.com/")[Bootstrap]、#link("https://jeri.io/")[JERI]、#link("https://www.mathjax.org/")[MathJax] 和 #link("https://jquery.com/")[JQuery] 的开发者。也感谢 Impallari Type 设计了正文使用的 #link("https://fonts.google.com/specimen/Domine")[Domine] 字体，Christian Robertson 设计了代码使用的 #link("https://fonts.google.com/specimen/Roboto+Mono")[Roboto Mono] 字体，以及 #link("https://fontawesome.com/")[Font Awesome] 字体的设计者。
]

#parec[
  We'd also like to thank everyone who supported the earlier online edition through _Patreon_; as of 1 November 2023: 3Dscan, Abdelhakim Deneche, Alain Galvan, Andréa Machizaud, Aras Pranckevicius, Arman Uguray, Ben Bass, Claudia Doppioslash, Dong Feng, Enrico, Filip Strugar, Haralambi Todorov, Jaewon Jung, Jan Walter, Jendrik Illner, Jim Price, Joakim Dahl, Jonathan Stone, KrotanHill, Laura Reznikov, Malte Nawroth, Mauricio Vives, Mrinal Deo, Nathan Vegdahl, Pavel Panchekha, Pratool Gadtaula, Saad Ahmed, Scott Pilet, Shin Watanabe, Steve Watts Kennedy, Tom Hulton-Harrop, Torgrim Boe Skaarsmoen, William Newhall, Yining Karl Li, and Yury Mikhaylov. We have, however, closed the Patreon with the launch of the fourth edition.
][
  我们也感谢通过 _Patreon_ 支持早期在线版的所有人。截至 2023 年 11 月 1 日，他们是：3Dscan、Abdelhakim Deneche、Alain Galvan、Andréa Machizaud、Aras Pranckevicius、Arman Uguray、Ben Bass、Claudia Doppioslash、Dong Feng、Enrico、Filip Strugar、Haralambi Todorov、Jaewon Jung、Jan Walter、Jendrik Illner、Jim Price、Joakim Dahl、Jonathan Stone、KrotanHill、Laura Reznikov、Malte Nawroth、Mauricio Vives、Mrinal Deo、Nathan Vegdahl、Pavel Panchekha、Pratool Gadtaula、Saad Ahmed、Scott Pilet、Shin Watanabe、Steve Watts Kennedy、Tom Hulton-Harrop、Torgrim Boe Skaarsmoen、William Newhall、Yining Karl Li 和 Yury Mikhaylov。不过，随着第四版推出，我们已经关闭了 _Patreon_。
]

#parec[
  Although the book is posted online for anyone to read for free, the text of the book remains #sym.copyright Copyright 2004–2023 Matt Pharr, Wenzel Jakob, and Greg Humphreys under a #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0] license. The book figures are licensed with a #link("https://creativecommons.org/licenses/by-nc-sa/4.0/")[CC BY-NC-SA 4.0] license with the thought that they may be useful when teaching graphics courses.
][
  虽然本书在线发布，任何人都可免费阅读，但正文版权仍归 Matt Pharr、Wenzel Jakob 和 Greg Humphreys 所有（#sym.copyright 2004–2023），采用 #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0] 许可。本书插图采用 #link("https://creativecommons.org/licenses/by-nc-sa/4.0/")[CC BY-NC-SA 4.0] 许可，因为我们希望它们能用于图形学课程教学。
]


=== #ez_caption[Scenes, Models, and Data][场景、模型与数据]
#parec[
  Many people and organizations have generously provided scenes and models for use in this book and the `pbrt` distribution. Their generosity has been invaluable in helping us create interesting example images throughout the text.
][
  许多个人和组织慷慨提供了供本书和 `pbrt` 发行版使用的场景与模型。他们的慷慨相助，让我们得以在书中创作有趣的示例图像，价值难以估量。
]

#parec[
  We are most grateful to Guillermo M. Leal Llaguno of Evolución Visual, #link("http://www.evvisual.com")[www.evvisual.com], who modeled and rendered the iconic _San Miguel_ scene that was featured on the cover of the second edition and is still used in numerous figures in the book. We would also especially like to thank Marko Dabrovic (#link("http://www.3lhd.com")[www.3lhd.com]) and Mihovil Odak at RNA Studios (#link("http://www.rna.hr")[www.rna.hr]), who supplied a bounty of models and scenes used in earlier editions of the book, including the Sponza atrium, the Sibenik cathedral, and the Audi TT car model that can be seen in @fig:tt-pbrt-v1-v4 of this edition. Many thanks are also due to Florent Boyer, who provided the contemporary house scene used in some of the images in Chapter chap:bidir-methods.
][
  我们十分感谢 Evolución Visual（#link("http://www.evvisual.com")[www.evvisual.com]）的 Guillermo M. Leal Llaguno，他为标志性的 _San Miguel_ 场景建模并完成渲染。该场景曾用于第二版封面，至今仍出现在书中许多插图中。我们也特别感谢 Marko Dabrovic（#link("http://www.3lhd.com")[www.3lhd.com]）和 RNA Studios（#link("http://www.rna.hr")[www.rna.hr]）的 Mihovil Odak。他们提供了早期各版使用的大量模型与场景，包括 Sponza 中庭、Sibenik 大教堂，以及本版 @fig:tt-pbrt-v1-v4 中的 Audi TT 汽车模型。还要感谢 Florent Boyer 提供现代住宅场景，用于原文所指的 `chap:bidir-methods` 章中的部分图像。#translator[固定上游此处保留了未解析的章节标识 `chap:bidir-methods`，其对应章节尚待核实。]
]

#parec[
  We sincerely thank Jan-Walter Schliep, Burak Kahraman, and Timm Dapper of Laubwerk (#link("http://www.laubwerk.com")[www.laubwerk.com]) for creating the _Countryside_ landscape scene that was on the cover of the previous edition of the book and is used in numerous figures in this edition.
][
  衷心感谢 Laubwerk（#link("http://www.laubwerk.com")[www.laubwerk.com]）的 Jan-Walter Schliep、Burak Kahraman 和 Timm Dapper 创作了 _Countryside_ 风景场景。它曾用于上一版封面，也出现在本版的许多插图中。
]

#parec[
  Many thanks to Angelo Ferretti of Lucydreams (#link("http://www.lucydreams.it")[www.lucydreams.it]) for licensing the _Watercolor_ and _Kroken_ scenes, which have provided a wonderful cover image for this edition, material for numerous figures, and a pair of complex scenes that exercise `pbrt`'s capabilities.
][
  十分感谢 Lucydreams（#link("http://www.lucydreams.it")[www.lucydreams.it]）的 Angelo Ferretti 授权使用 _Watercolor_ 和 _Kroken_ 场景。它们为本版提供了精彩的封面图像和许多插图素材，也提供了两个可检验 `pbrt` 能力的复杂场景。
]

#parec[
  Jim Price kindly provided a number of scenes featuring interesting volumetric media; those have measurably improved the figures for that topic. Thanks also to Beeple for making the _Zero Day_ and _Transparent Machines_ scenes available under a permissive license and to Martin Lubich for the Austrian Imperial Crown model. Finally, our deepest thanks to Walt Disney Animation Studios for making the production-complexity _Moana Island_ scene available as well as providing the detailed volumetric cloud model.
][
  Jim Price 热心提供了多个包含有趣体积介质的场景，切实改善了相关主题的插图。也感谢 Beeple 以宽松许可提供 _Zero Day_ 和 _Transparent Machines_ 场景，感谢 Martin Lubich 提供奥地利帝国皇冠模型。最后，衷心感谢 Walt Disney Animation Studios 公开具有影视制作级复杂度的 _Moana Island_ 场景，并提供精细的体积云模型。
]

#parec[
  The bunny, Buddha, and dragon models are courtesy of the Stanford Computer Graphics Laboratory's scanning repository. The “killeroo” model is included with permission of Phil Dench and Martin Rezard (3D scan and digital representations by headus, design and clay sculpt by Rezard). The dragon model scan used in @reflection-models is courtesy of Christian Schüller, and our thanks to Yasutoshi Mori for the material orb and the sports car model. The glass used to illustrate caustics in Chapter chap:bidir-methods is thanks to Simon Wendsche. The head model used to illustrate subsurface scattering was made available by Infinite Realities, Inc. under a Creative Commons Attribution 3.0 license. Thanks also to “tyrant monkey” for the BMW M6 car model and “Wig42” for the breakfast table scene; both were posted to #link("http://blendswap.com/")[blendswap.com], also under a Creative Commons Attribution 3.0 license.
][
  兔子、佛像和龙模型来自斯坦福计算机图形实验室的扫描资源库。“killeroo”模型经 Phil Dench 和 Martin Rezard 许可收录，其中三维扫描与数字表示由 headus 完成，设计和黏土雕塑由 Rezard 完成。@reflection-models 使用的龙模型扫描数据由 Christian Schüller 提供；感谢 Yasutoshi Mori 提供材质球和跑车模型。原文所指的 `chap:bidir-methods` 章中用于展示焦散的玻璃杯由 Simon Wendsche 提供。#translator[固定上游此处的章节标识同样未解析，尚待核实。] 用于展示次表面散射的头部模型由 Infinite Realities, Inc. 以 Creative Commons Attribution 3.0 许可提供。还要感谢“tyrant monkey”提供 BMW M6 汽车模型，以及“Wig42”提供早餐桌场景；二者都发布在 #link("http://blendswap.com/")[blendswap.com]，同样采用 Creative Commons Attribution 3.0 许可。
]

#parec[
  We have made use of numerous environment maps from the _PolyHaven_ website (#link("http://polyhaven.com/")[polyhaven.com]) for HDR lighting in various scenes; all are available under a Creative Commons CC0 license. Thanks to Sergej Majboroda and Greg Zaal, whose environment maps we have used.
][
  我们使用了 _PolyHaven_ 网站（#link("http://polyhaven.com/")[polyhaven.com]）的大量环境贴图，为各种场景提供 HDR 照明；这些贴图均以 Creative Commons CC0 许可提供。感谢 Sergej Majboroda 和 Greg Zaal，我们使用了他们制作的环境贴图。
]

#parec[
  Marc Ellens provided spectral data for a variety of light sources, and the spectral RGB measurement data for a variety of displays is courtesy of Tom Lianza at X-Rite. Our thanks as well to Danny Pascale (#link("http://www.babelcolor.com/")[www.babelcolor.com/]) for allowing us to include his measurements of the spectral reflectance of a color chart. Thanks to Mikhail Polyanskiy for index of refraction data via #link("http://refractiveindex.info/")[refractiveindex.info] and to Anders Langlands, Luca Fascione, and Weta Digital for camera sensor response data that is included in `pbrt`.
][
  Marc Ellens 提供了多种光源的光谱数据，X-Rite 的 Tom Lianza 提供了多种显示器的 RGB 光谱测量数据。感谢 Danny Pascale（#link("http://www.babelcolor.com/")[www.babelcolor.com/]）允许我们收录他测量的色卡光谱反射率。也感谢 Mikhail Polyanskiy 通过 #link("http://refractiveindex.info/")[refractiveindex.info] 提供折射率数据，以及 Anders Langlands、Luca Fascione 和 Weta Digital 提供 `pbrt` 中收录的相机传感器响应数据。
]

== #ez_caption[About The Cover][关于封面]
#parec[
  The _Watercolor_ scene on the cover was created by Angelo Ferretti of Lucydreams (#link("http://www.lucydreams.it")[www.lucydreams.it]). It requires a total of 2 GiB of on-disk storage for geometry and 836 MiB for texture maps. Come rendering, the scene description requires 15 GiB of memory to store over 33 million unique triangles, 412 texture maps, and associated data structures.
][
  封面的 _Watercolor_ 场景由 Lucydreams（#link("http://www.lucydreams.it")[www.lucydreams.it]）的 Angelo Ferretti 创作。其几何数据共占用 2 GiB 磁盘空间，纹理贴图占用 836 MiB。渲染时，场景描述需要 15 GiB 内存，以存储超过 3300 万个互不相同的三角形、412 张纹理贴图及相关数据结构。
]
