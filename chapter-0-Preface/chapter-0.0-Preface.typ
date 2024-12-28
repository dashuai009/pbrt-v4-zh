#import "../template.typ": parec, translator

= Perface

#parec[
  _[Just as] other information should be available to those who want to learn and understand, program source code is the only means for programmers to learn the art from their predecessors. It would be unthinkable for playwrights not to allow other playwrights to read their plays [or to allow them] at theater performances where they would be barred even from taking notes. Likewise, any good author is well read, as every child who learns to write will read hundreds of times more than it writes. Programmers, however, are expected to invent the alphabet and learn to write long novels all on their own. Programming cannot grow and learn unless the next generation of programmers has access to the knowledge and information gathered by other programmers before them._ —Erik Naggum
][
  _[正如]那些想要学习和理解的人应该可以获得其它信息一样，源码是程序员向前辈学习艺术的唯一手段。对于剧作家来说，不允许其他剧作家朗读他们的剧本（或允许他们）在剧院演出，甚至不允许他们做笔记，这是无法想象的。同样，任何优秀的作家都善于阅读，因为每个学习写作的孩子所读的内容都会比所写的内容多数百倍。然而，程序员应该发明字母表并学会自己写长篇小说。除非下一代程序员能够获得之前其他程序员收集的知识和信息，否则编程就无法成长和学习。_ ——埃里克·纳古姆
]

#parec[
  Rendering is a fundamental component of computer graphics. At the highest level of abstraction, rendering is the process of converting a description of a three-dimensional scene into an image. Algorithms for animation, geometric modeling, texturing, and other areas of computer graphics all must pass their results through some sort of rendering process so that they can be made visible in an image. Rendering has become ubiquitous; from movies to games and beyond, it has opened new frontiers for creative expression, entertainment, and visualization.
][
  渲染是计算机图形学的基本组成部分。在最高抽象层次上，渲染是将三维场景的描述转换为图像的过程。动画、几何建模、纹理和计算机图形学其他领域的算法都必须通过某种渲染过程传递其结果，以便它们可以在图像中可见。渲染已经变得无处不在；从电影到游戏等等，它为创意表达、娱乐和可视化开辟了新的领域。
]

#parec[
  In the early years of the field, research in rendering focused on solving fundamental problems such as determining which objects are visible from a given viewpoint. As effective solutions to these problems have been found and as richer and more realistic scene descriptions have become available thanks to continued progress in other areas of graphics, modern rendering has grown to include ideas from a broad range of disciplines, including physics and astrophysics, astronomy, biology, psychology and the study of perception, and pure and applied mathematics. The interdisciplinary nature of rendering is one of the reasons that it is such a fascinating area of study.
][
  在该领域的早期，渲染研究的重点是解决基本问题，例如确定从给定视点哪些对象是可见的。随着这些问题的有效解决方案被发现，并且由于图形学其他领域的不断进步，更丰富、更真实的场景描述已经成为可能，现代渲染已经发展到包含来自广泛学科的想法，包括物理学和天体物理学、天文学、生物学、心理学和感知研究，以及纯数学和应用数学。渲染的跨学科性质是它成为如此令人着迷的研究领域的原因之一。
]

#parec[
  This book presents a selection of modern rendering algorithms through the documented source code for a complete rendering system. Nearly all of the images in this book, including the one on the front cover, were rendered by this software. All of the algorithms that came together to generate these images are described in these pages. The system, `pbrt`, is written using a programming methodology called _literate programming_ that mixes prose describing the system with the source code that implements it. We believe that the literate programming approach is a valuable way to introduce ideas in computer graphics and computer science in general. Often, some of the subtleties of an algorithm can be unclear or hidden until it is implemented, so seeing an actual implementation is a good way to acquire a solid understanding of that algorithm's details. Indeed, we believe that deep understanding of a number of carefully selected algorithms in this manner provides a better foundation for further study of computer graphics than does superficial understanding of many.
][
  本书通过完整渲染系统的记录源代码介绍了一系列现代渲染算法。本书中几乎所有的图像，包括封面上的图像，都是由该软件渲染的。这些页面描述了生成这些图像的所有算法。 `pbrt`系统是使用一种称为_文学编程_的编程方法编写的，该方法将描述系统的散文与实现该系统的源代码混合在一起。我们相信，文学编程方法是引入计算机图形学和计算机科学思想的一种有价值的方式。通常，算法的一些微妙之处在实现之前可能是不清楚或隐藏的，因此查看实际实现是深入了解该算法细节的好方法。事实上，我们相信，以这种方式深入理解许多精心挑选的算法，比对肤浅理解算法，为进一步研究计算机图形学提供了更好的基础。
]

#parec[
  In addition to clarifying how an algorithm is implemented in practice, presenting these algorithms in the context of a complete and nontrivial software system also allows us to address issues in the design and implementation of medium-sized rendering systems. The design of a rendering system's basic abstractions and interfaces has substantial implications for both the elegance of the implementation and the ability to extend it later, yet the trade-offs in this design space are rarely discussed.
][
  除了阐明算法在实践中如何实现之外，在完整且重要的软件系统背景下呈现这些算法还使我们能够解决中型渲染系统的设计和实现中的问题。渲染系统的基本抽象和接口的设计对于实现的优雅性和可扩展性都具有重大影响，但很少有关此设计的权衡的讨论。
]

#parec[
  `pbrt` and the contents of this book focus exclusively on photorealistic rendering, which can be defined variously as the task of generating images that are indistinguishable from those that a camera would capture in a photograph or as the task of generating images that evoke the same response from a human observer as looking at the actual scene. There are many reasons to focus on photorealism. Photorealistic images are crucial for special effects in movies because computer-generated imagery must often be mixed seamlessly with footage of the real world. In applications like computer games where all of the imagery is synthetic, photorealism is an effective tool for making the observer forget that he or she is looking at an environment that does not actually exist. Finally, photorealism gives a reasonably well-defined metric for evaluating the quality of the rendering system's output.
][
  `pbrt`的内容专注于照片级真实感的渲染，也可以说是为生成与相机中捕获的图像无法区分的图像的任务，或者生成能够引起人类观察者在看着实际场景做出相同反应的图像的任务。关注照片级写实的原因有很多。逼真的图像对于电影特效至关重要，因为计算机生成的图像通常必须与现实世界的镜头无缝混合。在计算机游戏等所有图像都是合成的应用中，照片级写实主义是一种有效的效果，可以让观察者忘记他或她正在观看一个实际上并不存在的环境。最后，照片级写实系统提供了一个相当明确的指标来评估渲染系统输出的质量。
]

== Audience
#parec[
  There are three main audiences that this book is intended for. The first is students in graduate or upper-level undergraduate computer graphics classes. This book assumes existing knowledge of computer graphics at the level of an introductory college-level course, although certain key concepts such as basic vector geometry and transformations will be reviewed here. For students who do not have experience with programs that have tens of thousands of lines of source code, the literate programming style gives a gentle introduction to this complexity. We pay special attention to explaining the reasoning behind some of the key interfaces and abstractions in the system in order to give these readers a sense of why the system is structured in the way that it is.
][
  本书主要面向三个读者。第一种是研究生或高年级本科生计算机图形学课程的学生。本书假设计算机图形学的现有知识处于大学入门课程的水平，尽管这里将回顾某些关键概念，例如基本向量几何和变换。对于没有使用过数万行源代码的程序经验的学生来说，文学编程风格可以温和地介绍这种复杂性。我们特别注重解释系统中一些关键接口和抽象背后的推理，以便让读者了解系统为何如此构造。
]

#parec[
  The second audience is advanced graduate students and researchers in computer graphics. For those doing research in rendering, the book provides a broad introduction to the area, and the ``pbrt`` source code provides a foundation that can be useful to build upon (or at least to use bits of source code from). For those working in other areas of computer graphics, we believe that having a thorough understanding of rendering can be helpful context to carry along.
][
  第二类受众是计算机图形学领域的高级研究生和研究人员。对于那些从事渲染研究的人来说，本书提供了该领域的广泛介绍，以及 `pbrt` 源代码提供了一个可用于构建（或至少使用其中的源代码位）的基础。对于那些在计算机图形学其他领域工作的人来说，我们相信对渲染的透彻理解可以为他们提供帮助。
]

#parec[
  Our final audience is software developers in industry. Although many of the basic ideas in this book will be familiar to this audience, seeing explanations of the algorithms presented in the literate style may lead to new perspectives. `pbrt` also includes carefully crafted and debugged implementations of many algorithms that can be challenging to implement correctly; these should be of particular interest to experienced practitioners in rendering. We hope that delving into one particular organization of a complete and nontrivial rendering system will also be thought provoking to this audience.
][
  我们的最终受众是工业界的软件开发人员。尽管本书中的许多基本思想对于读者来说是熟悉的，但看到以文学风格呈现的算法解释可能会带来新的视角。 `pbrt` 还包括许多算法的精心设计和调试实现，这些算法的正确实现可能具有挑战性；这些应该是经验丰富的渲染从业者特别感兴趣的。我们希望也能引起某个研究完整且重要的渲染系统的组织的深入思考。
]

== Overview and Goals
#parec[
  `pbrt` is based on the _ray-tracing_ algorithm. Ray tracing is an elegant technique that has its origins in lens making; Carl Friedrich Gauß traced rays through lenses by hand in the 19th century. Ray-tracing algorithms on computers follow the path of infinitesimal rays of light through the scene until they intersect a surface. This approach gives a simple method for finding the first visible object as seen from any particular position and direction and is the basis for many rendering algorithms.
][
  `pbrt` 基于_光线追踪_算法。光线追踪是一项优雅的技术，起源于镜头制造。 19 世纪，卡尔·弗里德里希·高斯 (Carl Friedrich Gauß) 手动追踪穿过透镜的光线。计算机上的光线追踪算法跟踪穿过场景的无穷小光线的路径，直到它们与表面相交。这就提供了一种简单的方法来查找从任何特定位置和方向看到的第一个可见对象，并且是许多渲染算法的基础。
]

#parec[
  `pbrt` was designed and implemented with three main goals in mind: it should be _complete_, it should be _illustrative_, and it should be _physically based_.
][
  `pbrt` 设计和实现时考虑了三个主要目标：它应该是_完整的_，它应该是_说明性的_，并且它应该是_基于物理的_。
]

#parec[
  Completeness implies that the system should not lack key features found in high-quality commercial rendering systems. In particular, it means that important practical issues, such as antialiasing, robustness, numerical precision, and the ability to efficiently render complex scenes should all be addressed thoroughly. It is important to consider these issues from the start of the system's design, since these features can have subtle implications for all components of the system and can be quite difficult to retrofit into the system at a later stage of implementation.
][
  完整性意味着系统不应缺少高质量商业渲染系统中的关键功能。特别是，这意味着重要的实际问题，例如抗锯齿、鲁棒性、数值精度以及有效渲染复杂场景的能力都应该得到完整解决。从系统设计之初就考虑这些问题非常重要，因为这些功能可能会对系统的所有组件产生微妙的影响，并且很难在后期实施阶段对系统进行改造。
]

#parec[
  Our second goal means that we tried to choose algorithms, data structures, and rendering techniques with care and with an eye toward readability and clarity. Since their implementations will be examined by more readers than is the case for other rendering systems, we tried to select the most elegant algorithms that we were aware of and implement them as well as possible. This goal also required that the system be small enough for a single person to understand completely. We have implemented `pbrt` using an extensible architecture, with the core of the system implemented in terms of a set of carefully designed interface classes, and as much of the specific functionality as possible in implementations of these interfaces. The result is that one does not need to understand all of the specific implementations in order to understand the basic structure of the system. This makes it easier to delve deeply into parts of interest and skip others, without losing sight of how the overall system fits together.
][
  我们的第二个目标意味着我们尝试谨慎选择算法、数据结构和渲染技术，并着眼于可读性和清晰度。由于与其他渲染系统相比，它们的实现将受到更多读者的检查，因此我们尝试选择我们所知道的最优雅的算法并尽可能地实现它们。这个目标还要求系统足够小，足以让一个人完全理解。我们已经实现了在`pbrt`中能够可扩展的体系结构，系统的核心通过一组精心设计的接口类来实现，并在这些接口的实现中尽可能多地实现特定功能。结果是，人们不需要理解所有的具体实现就可以理解系统的基本结构。这使得更容易深入研究感兴趣的部分并跳过其他部分，而不会忽视整个系统如何组合在一起。
]

#parec[
  There is a tension between the two goals of being complete and being illustrative. Implementing and describing every possible useful technique would not only make this book unacceptably long, but would also make the system prohibitively complex for most readers. In cases where `pbrt` lacks a particularly useful feature, we have attempted to design the architecture so that the feature could be added without altering the overall system design.
][
  完整和说明性这两个目标之间存在着紧张关系。实现和描述每一种可能有用的技术不仅会使本书变得长得令人难以接受，而且还会使系统对大多数读者来说过于复杂。在这种情况下 `pbrt` 由于一些缺乏特别有用的功能，我们尝试设计架构，以便在不改变整体系统设计的情况下添加该功能（指说明性）。
]

#parec[
  The basic foundations for physically based rendering are the laws of physics and their mathematical expression. `pbrt` was designed to use the correct physical units and concepts for the quantities it computes and the algorithms it implements. `pbrt` strives to compute images that are _physically correct_; they accurately reflect the lighting as it would be in a real-world version of the scene. #footnote[Of course, any computer simulation of physics requires carefully choosing approximations that trade off requirements for fidelity with computational efficiency.  See @Photorealistic-Rendering-and-the-Ray-Tracing-Algorithm for further discussion of the choices made in ] One advantage of the decision to use a physical basis is that it gives a concrete standard of program correctness: for simple scenes, where the expected result can be computed in closed form, if `pbrt` does not compute the same result, we know there must be a bug in the implementation. Similarly, if different physically based lighting algorithms in `pbrt` give different results for the same scene, or if `pbrt` does not give the same results as another physically based renderer, there is certainly an error in one of them. Finally, we believe that this physically based approach to rendering is valuable because it is rigorous. When it is not clear how a particular computation should be performed, physics gives an answer that guarantees a consistent result.
][
  基于物理的渲染的基本基础是物理定律及其数学表达式。 `pbrt` 旨在为其计算的数值和实现的算法使用正确的物理单位和概念。 `pbrt` 努力计算_物理上正确_的图像；它们准确地反映了场景的真实版本中的照明。#footnote[当然，任何物理的计算机模拟都需要仔细选择近似值，在保真度要求和计算效率之间进行权衡。有关其中所做选择的进一步讨论，请参阅@Photorealistic-Rendering-and-the-Ray-Tracing-Algorithm] 使用物理基础的一个优点是它给出了程序正确性的具体标准：对于简单场景，可以以封闭形式计算预期结果， 如果 `pbrt` 没有计算出相同的结果，那实现中一定存在错误。类似地，如果不同的基于物理的照明算法 `pbrt` 对于同一场景给出不同的结果，或者如果 `pbrt` 没有给出与另一个基于物理的渲染器相同的结果，其中肯定存在错误。最后，我们相信这种基于物理的渲染方法很有价值，因为它很严格。当不清楚如何执行特定计算时，物理学会给出保证结果一致的答案。
]

#parec[
  Efficiency was given lower priority than these three goals. Since rendering systems often run for many minutes or hours in the course of generating an image, efficiency is clearly important. However, we have mostly confined ourselves to algorithmic efficiency rather than low-level code optimization. In some cases, obvious micro-optimizations take a backseat to clear, well-organized code, although we did make some effort to optimize the parts of the system where most of the computation occurs.
][
  效率的优先级低于这三个目标。由于渲染系统在生成图像的过程中通常运行数分钟或数小时，因此效率显然很重要。然而，我们主要局限于算法效率而不是低级代码优化。在某些情况下，尽管我们确实做出了一些努力来优化系统中发生大部分计算的部分，但明显的微观优化让位于清晰、组织良好的代码。
]

#parec[
  In the course of presenting `pbrt` and discussing its implementation, we hope to convey some hard-learned lessons from years of rendering research and development. There is more to writing a good renderer than stringing together a set of fast algorithms; making the system both flexible and robust is a difficult task. The system's performance must degrade gracefully as more geometry or light sources are added to it or as any other axis of complexity is stressed.
][
  在呈现过程中 `pbrt` 并讨论其实施，我们希望传达一些从多年的渲染研究和开发之中来之不易的经验教训。编写一个好的渲染器不仅仅是将一组快速算法串在一起；使系统既灵活又健壮是一项艰巨的任务。随着更多几何体或光源的添加，或者任何其他复杂度受到压力，系统的性能必须适度下降。
]

#parec[
  The rewards for developing a system that addresses all these issues are enormous—it is a great pleasure to write a new renderer or add a new feature to an existing renderer and use it to create an image that could not be generated before. Our most fundamental goal in writing this book was to bring this opportunity to a wider audience. Readers are encouraged to use the system to render the example scenes in the `pbrt` software distribution as they progress through the book. Exercises at the end of each chapter suggest modifications to the system that will help clarify its inner workings and more complex projects to extend the system by adding new features.
][
  开发一个解决所有这些问题的系统的回报是巨大的——编写一个新的渲染器或向现有渲染器添加新功能并使用它来创建以前无法生成的图像是一种巨大的乐趣。我们撰写本书的最根本目标是将这个机会带给更广泛的读者。鼓励读者使用该 `pbrt` 系统随着本书的代码来渲染示例场景。每章末尾的练习建议对系统进行修改，这将有助于阐明其内部工作原理，添加新功能来扩展系统，实现更复杂的项目。
]

#parec[
  The website for this book is located at #link("https://pbrt.org/")[`pbrt`.org]. This site includes links to the `pbrt` source code, scenes that can be downloaded to render with `pbrt`, and a bug tracker, as well as errata. Any errors in this text that are not listed in the errata can be reported to the email address `authors@pbrt.org`. We greatly value your feedback!
][
  本书的网站位于#link("https://pbrt.org/")[`pbrt`.org] 。该网站包含以下链接 `pbrt` 源代码，可以下载渲染的场景 `pbrt` 、错误跟踪器以及勘误表。勘误表中未列出的本文中的任何错误都可以报告至电子邮件地址`authors@pbrt.org` 。我们非常重视您的反馈！
]

== Changes Between The First and Second Editions
#parec[
  Six years passed between the publication of the first edition of this book in 2004 and the second edition in 2010. In that time, thousands of copies of the book were sold, and the `pbrt` software was downloaded thousands of times from the book's website. The `pbrt` user base gave us a significant amount of feedback and encouragement, and our experience with the system guided many of the decisions we made in making changes between the version of `pbrt` presented in the first edition and the version in the second edition. In addition to a number of bug fixes, we also made several significant design changes and enhancements:
][
  本书从2004年第一版出版到2010年第二版出版，历时六年。期间，该书已售出数千册， `pbrt` 该软件从该书的网站上被下载了数千次。`pbrt` 用户群给了我们大量的反馈和鼓励，我们对系统的经验指导了我们在版本之间进行更改时做出的许多决定。除了一些错误修复之外，我们还进行了几项重大的设计更改和增强：
]

#parec[
  - #emph[Removal of the plugin architecture]: The first version of `pbrt` used a runtime plugin architecture to dynamically load code for implementations of objects like shapes, lights, integrators, cameras, and other objects that were used in the scene currently being rendered. This approach allowed users to extend `pbrt` with new object types (e.g., new shape primitives) without recompiling the entire rendering system. This approach initially seemed elegant, but it complicated the task of supporting `pbrt` on multiple platforms and it made debugging more difficult. The only new usage scenario that it truly enabled (binary-only distributions of `pbrt` or binary plugins) was actually contrary to our pedagogical and open-source goals. Therefore, the plugin architecture was dropped in this edition.
][
  - _删除插件架构_：第一个版本 `pbrt` 使用运行时插件的架构来动态加载对象的实现代码，例如形状、灯光、积分器、相机以及当前渲染场景中使用的其他对象。这种方法允许用户扩展 `pbrt` 无需重新编译整个渲染系统即可使用新的对象类型（例如，新的形状基元）。这种方法最初看起来很优雅，但它使`pbrt`支持多个平台变得复杂 ，这使得调试变得更加困难。它真正启用的唯一新使用场景（仅`pbrt` 二进制发行版 或二进制插件）实际上违背了我们的教学和开源目标。因此，该版本中删除了插件架构。
]

#parec[
  - _Removal of the image-processing pipeline_: The first version of `pbrt` provided a tone-mapping interface that converted high-dynamic-range (HDR) floating-point output images directly into low-dynamic-range TIFFs for display. This functionality made sense in 2004, as support for HDR images was still sparse. In 2010, however, advances in digital photography had made HDR images commonplace. Although the theory and practice of tone mapping are elegant and worth learning, we decided to focus the new book exclusively on the process of image formation and skip the topic of image display. Interested readers should consult the book written by Reinhard et al. @reinhard2010high for a thorough and modern treatment of the HDR image display process.
][
  - _删除图像处理管道_：第一个版本 `pbrt` 提供了一个色调映射接口，可将高动态范围 (HDR) 浮点输出图像直接转换为低动态范围 TIFF 进行显示。此功能在 2004 年有意义，因为对 HDR 图像的支持仍然很少。然而，到了 2010 年，数字摄影技术的进步使得 HDR 图像变得司空见惯。尽管色调映射的理论和实践很优雅且值得学习，但我们决定将新书的重点放在图像形成的过程上，而跳过图像显示的主题。有兴趣的读者可以查阅 Reinhard 等人写的书。 @reinhard2010high 对 HDR 图像显示过程进行彻底和现代的处理。
]


#parec[
  - _Task parallelism_: Multicore architectures became ubiquitous, and we felt that `pbrt` would not remain relevant without the ability to scale to the number of locally available cores. We also hoped that the parallel programming implementation details documented in this book would help graphics programmers understand some of the subtleties and complexities in writing scalable parallel code.
][
  - _任务并行性_：多核架构变得无处不在，我们认为 `pbrt` 如果无法扩展到本地可用核心的数量，就无法保持相关性。我们还希望本书中记录的并行编程实现细节能够帮助图形程序员理解编写可扩展的并行代码的一些微妙之处和复杂性。
]

#parec[
  - _Appropriateness for “production” rendering_: The first version of `pbrt` was intended exclusively as a pedagogical tool and a stepping-stone for rendering research. Indeed, we made a number of decisions in preparing the first edition that were contrary to use in a production environment, such as limited support for image-based lighting, no support for motion blur, and a photon mapping implementation that was not robust in the presence of complex lighting. With much improved support for these features as well as support for subsurface scattering and Metropolis light transport, we feel that with the second edition, `pbrt` became much more suitable for rendering very high-quality images of complex environments.
][
  - _“生产级”渲染的适当性_：第一个版本 `pbrt` 专门作为一种教学工具和渲染研究的垫脚石。事实上，我们在准备第一版时做出了许多与生产环境中相反的决定，例如对基于图像的照明的有限支持、不支持运动模糊以及在实际环境中不稳健的光子映射实现。复杂照明的存在。通过对这些功能的大幅改进支持以及对次表面散射和 Metropolis 光传输的支持，我们认为在第二版中， `pbrt` 变得更适合渲染复杂环境的高质量图像。
]

== Changes Between The Second and Third Editions


#parec[
  With the passage of another six years, it was time to update and extend the book and the `pbrt` system. We continued to learn from readers' and users' experiences to better understand which topics were most useful to cover. Further, rendering research continued apace; many parts of the book were due for an update to reflect current best practices. We made significant improvements on a number of fronts:
][
  又六年过去了，是时候更新和扩展这本书和 `pbrt` 系统。我们继续从读者和用户的经验中学习，以更好地了解哪些主题最有用。此外，渲染研究继续快速发展；本书的许多部分都需要更新，以反映当前的最佳实践。我们在许多方面做出了重大改进：
]

#parec[
  - _Bidirectional light transport_: The third version of `pbrt` added a bidirectional path tracer, including full support for volumetric light transport and multiple importance sampling to weight paths. An all-new Metropolis light transport integrator used components of the bidirectional path tracer, allowing for a particularly succinct implementation of that algorithm.
][
  - _双向光传输_：第三个版本 `pbrt` 添加了双向路径跟踪器，包括对体积光传输的全面支持和对权重路径的多重重要性采样。全新的 Metropolis 光传输积分器使用了双向路径追踪器的组件，从而可以特别简洁地实现该算法。
]

#parec[
  - _Subsurface scattering_: The appearance of many objects—notably, skin and translucent objects—is a result of subsurface light transport. Our implementation of subsurface scattering in the second edition reflected the state of the art in the early 2000s; we thoroughly updated both BSSRDF models and our subsurface light transport algorithms to reflect the progress made in ten subsequent years of research.
][
  - _次表面散射_：许多物体（尤其是皮肤和半透明物体）的外观是次表面光传输的结果。我们在第二版中实现的次表面散射反映了 2000 年代初期的技术水平；我们彻底更新了 BSSRDF 模型和次表面光传输算法，以反映随后十年研究取得的进展。
]

#parec[
  - _Numerically robust intersections_: The effects of floating-point round-off error in geometric ray intersection calculations have been a long-standing challenge in ray tracing: they can cause small errors to be present throughout the image. We focused on this issue and derived conservative (but tight) bounds of this error, which made our implementation more robust to this issue than previous rendering systems.
][
  - _数值稳定的求交运算_：几何射线相交计算中浮点舍入误差的影响一直是光线追踪中的一个长期挑战：它们可能导致整个图像中出现小错误。我们专注于这个问题并得出了这个错误的保守（但严格）界限，这使得我们的实现比以前的渲染系统对此问题更加稳定。
]

#parec[
  - _Participating media representation_: We significantly improved the way that scattering media are described and represented in the system; this allows for more accurate results with nested scattering media. A new sampling technique enabled unbiased rendering of heterogeneous media in a way that cleanly integrated with all of the other parts of the system.
][
  - _参与的媒体表示_：我们显着改进了系统中描述和表示散射媒体的方式；这允许使用嵌套散射介质获得更准确的结果。新的采样技术能够以与系统的所有其他部分整洁的集成在一起，实现异构媒体的无偏差渲染。
]

#parec[
  - _Measured materials_: This edition added a new technique to represent and evaluate measured materials using a sparse frequency-space basis. This approach is convenient because it allows for exact importance sampling, which was not possible with the representation used in the previous edition.
][
  - _测量材料_：此版本添加了一种新技术，使用稀疏频率空间基础来表示和评估测量材料。这种方法很方便，因为它允许精确的重要性采样，而这对于以前版本中使用的表示是不可能的。
]

#parec[
  - _Photon mapping_: A significant step forward for photon mapping algorithms has been the development of variants that do not require storing all of the photons in memory. We replaced `pbrt`'s photon mapping algorithm with an implementation based on stochastic progressive photon mapping, which efficiently renders many difficult light transport effects.
][
  - _光子映射_：光子映射算法向前迈出的重要一步是开发了不需要将所有光子存储在内存中的变体。我们更换了 `pbrt` 的光子映射算法采用基于随机渐进光子映射的实现，可有效渲染许多困难的光传输效果。
]

#parec[
  - _Sample generation algorithms_: The distribution of sample values used for numerical integration in rendering algorithms can have a surprisingly large effect on the quality of the final results. We thoroughly updated our treatment of this topic, covering new approaches and efficient implementation techniques in more depth than before.
][
  - _样本生成算法_：渲染算法中用于数值积分的样本值的分布会对最终结果的质量产生令人惊讶的巨大影响。我们彻底更新了对此主题的处理，比以前更深入地涵盖了新方法和高效的实施技术。
]

#parec[
  Many other parts of the system were improved and updated to reflect progress in the field: microfacet reflection models were treated in more depth, with much better sampling techniques; a new “curve” shape was added for modeling hair and other fine geometry; and a new camera model that simulates realistic lens systems was made available. Throughout the book, we made numerous smaller changes to more clearly explain and illustrate the key concepts in physically based rendering systems like `pbrt`.
][
  系统的许多其他部分都得到了改进和更新，以反映该领域的进展：微面反射模型得到了更深入的处理，采用了更好的采样技术；添加了新的“曲线”形状，用于建模头发和其他精细几何形状；并推出了模拟真实镜头系统的新相机模型。在整本书中，我们做了许多较小的更改，以更清楚地解释和说明基于物理的渲染系统中的关键概念，例如 `pbrt` 。
]

== Changes Between The Third and Fourth Editions
#parec[
  Innovation in rendering algorithms has shown no sign of slowing down, and so in 2019 we began focused work on a fourth edition of the text. Not only does almost every chapter include substantial additions, but we have updated the order of chapters and ideas introduced, bringing Monte Carlo integration and the basic ideas of path tracing to the fore rather than saving them for the end.
][
  渲染算法的创新没有放缓的迹象，因此我们在 2019 年开始专注于第四版文本的工作。不仅几乎每一章都包含了大量的补充，而且我们还更新了章节和引入的思想的顺序，将蒙特卡洛积分和路径追踪的基本思想放在首位，而不是把它们留到最后。
]

#parec[
  Capabilities of the system that have seen especially significant improvements include:
][
  该系统的功能得到了显著的改进，包括：
]

#parec[
  - _Volumetric scattering_: We have updated the algorithms that model scattering from participating media to the state of the art, adding support for emissive volumes, efficient sampling of volumes with varying densities, and robust support for chromatic media, where the scattering properties vary by wavelength.
][
  - _体积散射_：我们将参与介质的散射建模算法更新为最新技术，增加了对发射体积的支持、对不同密度体积的高效采样以及对彩色介质的强大支持，其中散射属性随波长而变化。
]

#parec[
  - _Spectral rendering_: We have excised all use of RGB color for lighting calculations; `pbrt` now performs lighting calculations exclusively in terms of samples of wavelength-dependent spectral distributions. Not only is this approach more physically accurate than using RGB, but it also allows `pbrt` to accurately model effects like dispersion.
][
  - _光谱渲染_：我们取消了所有用于照明计算的 RGB 颜色； `pbrt` 现在仅根据波长相关光谱分布的样本执行照明计算。这种方法不仅在物理上比使用 RGB 更准确，而且还允许 `pbrt` 准确地模拟色散等效应。
]

#parec[
  - _Reflection models_: Our coverage of the foundations of BSDFs and reflection models has been extensively revised, and we have expanded the range of BSDFs covered to include one that accurately models reflection from hair and another that models scattering from layered materials. The measured BRDF follows a new approach that can represent a wide set of materials' reflection spectra.
][
  - _反射模型_：我们对 BSDFs 和反射模型的基础进行了广泛的修订，并且我们扩展了 BSDFs 的范围，包括精确模拟头发反射的一个模型和另一个模拟分层材料散射的模型。测量的 BRDFs 采用了一种新方法，可以代表多种材料的反射光谱。
]

#parec[
  - _Light sampling_: Not only have we improved the algorithms for sampling points on individual light sources to better reflect the state of the art, but this edition also includes support for many-light sampling, which makes it possible to efficiently render scenes with thousands or millions of light sources by carefully sampling just a few of them.
][
  - _光采样_：我们不仅改进了单个光源采样点的算法以更好地反映现有技术，而且该版本还包括对多光采样的支持，这使得高效渲染数千或数百万的场景成为可能，通过仔细采样其中的几个光源来分析光源。
]

#parec[
  - _GPU rendering_: This version of `pbrt` adds support for rendering on GPUs, which can provide 10–100 times higher ray tracing performance than CPUs. We have implemented this capability in a way so that almost all of the code presented in the book runs on both CPUs and GPUs, which has made it possible to localize discussion of GPU-related issues to @wavefront-rendering-on-gpus .
][
  - _GPU渲染_：这个版本 `pbrt` 增加了对 GPU 渲染的支持，可以提供比 CPU 高 10-100 倍的光线追踪性能。我们以某种方式实现了这一功能，使得本书中提供的几乎所有代码都可以在 CPU 和 GPU 上运行，这使得将 GPU 相关问题的讨论集中在@wavefront-rendering-on-gpus 。
]

#parec[
  The system has seen numerous other improvements and additions, including a new bilinear patch shape, many updates to the sample-generation algorithms that are at the heart of Monte Carlo integration, support for outputting auxiliary information at each pixel about the visible surface geometry and reflection properties, and many more small improvements to the system.
][
  该系统还进行了许多其他改进和添加，包括新的双线性补丁形状、对蒙特卡罗积分核心的样本生成算法的许多更新、支持在每个像素输出有关可见表面几何形状和反射的辅助信息属性，以及对系统的许多小改进。
]

== Acknowledgments
#parec[
  Pat Hanrahan has contributed to this book in more ways than we could hope to acknowledge; we owe a profound debt to him. He tirelessly argued for clean interfaces and finding the right abstractions to use throughout the system, and his understanding of and approach to rendering deeply influenced its design. His willingness to use `pbrt` and this manuscript in his rendering course at Stanford was enormously helpful, particularly in the early years of its life when it was still in very rough form; his feedback throughout this process has been crucial for bringing the text to its current state. Finally, the group of people that Pat helped assemble at the Stanford Graphics Lab, and the open environment that he fostered, made for an exciting, stimulating, and fertile environment. Matt and Greg both feel extremely privileged to have been there.
][
  帕特·汉拉汉 (Pat Hanrahan) 对本书的贡献超出了我们的预期。我们深受他的恩惠。他孜孜不倦地主张干净的界面并找到在整个系统中使用的正确抽象，他对渲染的理解和方法深刻地影响了其设计。他愿意使用 `pbrt` 这份手稿在他在斯坦福大学的渲染课程中非常有帮助，特别是在它的早期阶段，当时它的形式还很粗糙；他在整个过程中的反馈对于使案文达到目前的状态至关重要。最后，帕特帮助在斯坦福图形实验室召集的一群人，以及他培育的开放环境，创造了一个令人兴奋、刺激和肥沃的环境。马特和格雷格都对能够来到那里感到非常荣幸。
]

#parec[
  We owe a debt of gratitude to the many students who used early drafts of this book in courses at Stanford and the University of Virginia between 1999 and 2004. These students provided an enormous amount of feedback about the book and `pbrt`. The teaching assistants for these courses deserve special mention: Tim Purcell, Mike Cammarano, Ian Buck, and Ren Ng at Stanford, and Nolan Goodnight at Virginia. A number of students in those classes gave particularly valuable feedback and sent bug reports and bug fixes; we would especially like to thank Evan Parker and Phil Beatty. A draft of the manuscript of this book was used in classes taught by Bill Mark and Don Fussell at the University of Texas, Austin, and Raghu Machiraju at Ohio State University; their feedback was invaluable, and we are grateful for their adventurousness in incorporating this system into their courses, even while it was still being edited and revised.
][
  我们要感谢许多学生，他们在 1999 年至 2004 年间在斯坦福大学和弗吉尼亚大学的课程中使用了本书的早期草稿。这些学生提供了关于本书的大量反馈， `pbrt` 。这些课程的助教值得特别提及：斯坦福大学的 Tim Purcell、Mike Cammarano、Ian Buck 和 Ren Ng，以及弗吉尼亚大学的 Nolan Goodnight。这些课程中的许多学生提供了特别有价值的反馈，并发送了错误报告和错误修复；我们要特别感谢埃文·帕克和菲尔·比蒂。德克萨斯大学奥斯汀分校的 Bill Mark 和 Don Fussell 以及俄亥俄州立大学的 Raghu Machiraju 教授的课程中使用了本书的手稿草稿；他们的反馈非常宝贵，我们感谢他们冒险地将这个系统纳入他们的课程，即使该系统仍在编辑和修订中。
]

#parec[
  Matt Pharr would like to acknowledge colleagues and co-workers in rendering-related endeavors who have been a great source of education and who have substantially influenced his approach to writing renderers and his understanding of the field. Particular thanks go to Craig Kolb, who provided a cornerstone of Matt's early computer graphics education through the freely available source code to the rayshade ray-tracing system, and Eric Veach, who has also been generous with his time and expertise. Thanks also to Doug Shult and Stan Eisenstat for formative lessons in mathematics and computer science during high school and college, respectively, and most important to Matt's parents, for the education they have provided and continued encouragement along the way. Finally, thanks to NVIDIA for supporting the preparation of both the first and this latest edition of the book; at NVIDIA, thanks to Nick Triantos and Jayant Kolhe for their support through the final stages of the preparation of the first edition and thanks to Aaron Lefohn, David Luebke, and Bill Dally for their support of work on the fourth edition.
][
  Matt Pharr 衷心感谢从事渲染相关工作的同事，他们为他提供了重要的教育来源，并极大地影响了他编写渲染器的方法以及他对该领域的理解。特别感谢 Craig Kolb，他通过免费提供源代码为 Matt 的早期计算机图形学教育奠定了基石。 rayshade 光线追踪系统，以及 Eric Veach，他也慷慨地贡献了自己的时间和专业知识。还要感谢道格·舒尔特 (Doug Shult) 和斯坦·艾森斯塔特 (Stan Eisenstat) 分别在高中和大学期间开设的数学和计算机科学课程，最重要的是马特的父母，感谢他们一路上提供的教育和持续的鼓励。最后，感谢 NVIDIA 对本书第一版和最新版的准备工作的支持；感谢 NVIDIA 的 Nick Triantos 和 Jayant Kolhe 在第一版准备的最后阶段提供的支持，并感谢 Aaron Lefohn、David Luebke 和 Bill Dally 对第四版工作的支持。
]

#parec[
  Greg Humphreys is very grateful to all the professors and TAs who tolerated him when he was an undergraduate at Princeton. Many people encouraged his interest in graphics, specifically Michael Cohen, David Dobkin, Adam Finkelstein, Michael Cox, Gordon Stoll, Patrick Min, and Dan Wallach. Doug Clark, Steve Lyon, and Andy Wolfe also supervised various independent research boondoggles without even laughing once. Once, in a group meeting about a year-long robotics project, Steve Lyon became exasperated and yelled, “Stop telling me why it can't be done, and figure out how to do it!”—an impromptu lesson that will never be forgotten. Eric Ristad fired Greg as a summer research assistant after his freshman year (before the summer even began), pawning him off on an unsuspecting Pat Hanrahan and beginning an advising relationship that would span 10 years and both coasts. Finally, Dave Hanson taught Greg that literate programming was a great way to work and that computer programming can be a beautiful and subtle art form.
][
  格雷格·汉弗莱斯非常感谢所有在他就读普林斯顿大学本科时包容他的教授和助教。许多人激发了他对图形的兴趣，特别是迈克尔·科恩、大卫·多布金、亚当·芬克尔斯坦、迈克尔·考克斯、戈登·斯托尔、帕特里克·明和丹·瓦拉赫。道格·克拉克（Doug Clark）、史蒂夫·里昂（Steve Lyon）和安迪·沃尔夫（Andy Wolfe）也监督过各种毫无意义的独立研究，甚至没有笑过一次。有一次，在一次关于为期一年的机器人项目的小组会议上，史蒂夫·里昂（Steve Lyon）变得愤怒并大喊：“别再告诉我为什么做不到，而是想办法去做！”——这是一个永远被忘掉的偶然教训。埃里克·里斯塔德（Eric Ristad）在大一结束后（甚至在夏天开始之前）解雇了格雷格（Greg），让他担任暑期研究助理，将他抵押给毫无戒心的帕特·汉拉汉（Pat Hanrahan），并开始了一段长达十年的顾问关系。最后，戴夫·汉森告诉格雷格，文学编程是一种很好的工作方式，计算机编程可以是一种美丽而微妙的艺术形式。
]

#parec[
  Wenzel Jakob was excited when the first edition of `pbrt` arrived in his mail during his undergraduate studies in 2004. Needless to say, this had a lasting effect on his career—thus Wenzel would like to begin by thanking his co-authors for inviting him to become a part of the third and fourth editions of this book. Wenzel is extremely indebted to Steve Marschner, who was his Ph.D. advisor during a fulfilling five years at Cornell University. Steve brought him into the world of research and remains a continuous source of inspiration. Wenzel is also thankful for the guidance and stimulating research environment created by the other members of the graphics group, including Kavita Bala, Doug James, and Bruce Walter. Wenzel spent a wonderful postdoc with Olga Sorkine Hornung, who introduced him to geometry processing. Olga's support for Wenzel's involvement in the third edition of this book is deeply appreciated.
][
  2004 年，当第一版 `pbrt`发布时，温泽尔·雅各布 (Wenzel Jakob) 非常兴奋。 他在读本科期间收到了这本书。不用说，这对他的职业生涯产生了持久的影响，因此 Wenzel 首先要感谢他的合著者邀请他参与第三版和第四版的一部分。 Wenzel 非常感谢 Steve Marschner，他是他的博士。在康奈尔大学度过了充实的五年期间的顾问。史蒂夫把他带入了研究领域，并一直是他源源不断的灵感源泉。 Wenzel 还感谢图形小组其他成员（包括 Kavita Bala、Doug James 和 Bruce Walter）所创造的指导和激励性的研究环境。 Wenzel 与 Olga Sorkine Hornung 一起度过了一段精彩的博士后时光，Olga Sorkine Hornung 向他介绍了几何处理。奥尔加对温泽尔参与本书第三版的支持深表感谢。
]

#parec[
  We would especially like to thank the reviewers who read drafts in their entirety; all had insightful and constructive feedback about the manuscript at various stages of its progress. For providing feedback on both the first and second editions of the book, thanks to Ian Ashdown, Per Christensen, Doug Epps, Dan Goldman, Eric Haines, Erik Reinhard, Pete Shirley, Peter-Pike Sloan, Greg Ward, and a host of anonymous reviewers. For the second edition, thanks to Janne Kontkanen, Bill Mark, Nelson Max, and Eric Tabellion. For the fourth edition, we are grateful to Thomas Müller and Per Christensen, who both offered extensive feedback that has measurably improved the final version.
][
  我们要特别感谢审阅全文的审稿人；在手稿进展的各个阶段，所有人都提出了富有洞察力和建设性的反馈。感谢 Ian Ashdown、Per Christensen、Doug Epps、Dan Goldman、Eric Haines、Erik Reinhard、Pete Shirley、Peter-Pike Sloan、Greg Ward 以及许多匿名人士对本书第一版和第二版提供的反馈审稿人。第二版感谢 Janne Kontkanen、Bill Mark、Nelson Max 和 Eric Tabellion。对于第四版，我们感谢 Thomas Müller 和 Per Christensen，他们提供了广泛的反馈，极大地改进了最终版本。
]

#parec[
  Many experts have kindly explained subtleties in their work to us and guided us to best practices. For the first and second editions, we are also grateful to Don Mitchell, for his help with understanding some of the details of sampling and reconstruction; Thomas Kollig and Alexander Keller, for explaining the finer points of low-discrepancy sampling; Christer Ericson, who had a number of suggestions for improving our kd-tree implementation; and Christophe Hery and Eugene d'Eon for helping us with the nuances of subsurface scattering.
][
  许多专家向我们亲切地解释了他们工作中的微妙之处，并指导我们采取最佳实践。对于第一版和第二版，我们还要感谢 Don Mitchell，他帮助我们理解了采样和重建的一些细节； Thomas Kollig 和 Alexander Keller，解释了低差异采样的细节； Christer Ericson，他对改进我们的 kd-tree 实现提出了许多建议； Christophe Hery 和 Eugene d'Eon 帮助我们解决了次表面散射的细微差别。
]

#parec[
  For the third edition, we would especially like to thank Leo Grünschloß for reviewing our sampling chapter; Alexander Keller for suggestions about topics for that chapter; Eric Heitz for extensive help with details of microfacets and reviewing our text on that topic; Thiago Ize for thoroughly reviewing the text on floating-point error; Tom van Bussel for reporting a number of errors in our BSSRDF code; Ralf Habel for reviewing our BSSRDF text; and Toshiya Hachisuka and Anton Kaplanyan for extensive review and comments about our light transport chapters.
][
  对于第三版，我们特别感谢 Leo Grünschloß 审阅了我们的抽样章节；亚历山大·凯勒（Alexander Keller）提供有关该章主题的建议； Eric Heitz 在微方面的细节方面提供了广泛的帮助，并审阅了我们关于该主题的文本； Thiago Ize 彻底审阅了有关浮点错误的文本； Tom van Bussel 报告了我们的 BSSRDF 代码中的一些错误； Ralf Habel 审阅了我们的 BSSRDF 文本； Toshiya Hachisuka 和 Anton Kaplanyan 对我们的光传输章节进行了广泛的审查和评论。
]

#parec[
  For the fourth edition, thanks to Alejandro Conty Estevez for reviewing our treatment of many-light sampling; Eugene d'Eon, Bailey Miller, and Jan Novák for comments on the volumetric scattering chapters; Eric Haines, Simon Kallweit, Martin Stich, and Carsten Wächter for reviewing the chapter on GPU rendering; Karl Li for feedback on a number of chapters; Tzu-Mao Li for his review of our discussion of inverse and differentiable rendering; Fabrice Rousselle for feedback on machine learning and rendering; and Gurprit Singh for comments on our discussion of Fourier analysis of Monte Carlo integration. We also appreciate extensive comments and suggestions from Jeppe Revall Frisvad on `pbrt`'s treatment of reflection models in previous editions.
][
  对于第四版，感谢 Alejandro Conty Estevez 审查我们对多光源采样的处理； Eugene d'Eon、Bailey Miller 和 Jan Novák 对体积散射章节的评论； Eric Haines、Simon Kallweit、Martin Stich 和 Carsten Wächter 审阅了有关 GPU 渲染的章节； Karl Li 对多个章节的反馈； Tzu-Mao Li 对我们关于逆渲染和可微渲染的讨论进行了回顾； Fabrice Rousselle 提供有关机器学习和渲染的反馈； Gurprit Singh 对我们讨论蒙特卡罗积分的傅里叶分析的评论。我们也感谢 Jeppe Revall Frisvad 的广泛评论和建议 `pbrt` 先前版本中对反射模型的处理。
]

#parec[
  For improvements to `pbrt`'s implementation in this edition, thanks to Pierre Moreau for his efforts in debugging `pbrt`'s GPU support on Windows and to Jim Price, who not only found and fixed numerous bugs in the early release of `pbrt`'s source code, but who also contributed a better representation of chromatic volumetric media than our original implementation. We are also very appreciative of Anders Langlands and Luca Fascione of Weta Digital for providing an implementation of their _PhysLight_ system, which has been incorporated into `pbrt`'s `PixelSensor` class and light source implementations.
][
  为了改进 `pbrt` 本版的实现，感谢 Pierre Moreau 在调试`pbrt` 支持 Windows 上的 GPU方面的努力 以及 Jim Price，他不仅在早期版本中发现并修复了许多错误 的 `pbrt`源代码，但他也贡献了比我们最初的实现更好的彩色体积媒体。我们也非常感谢 Weta Digital 的 Anders Langlands 和 Luca Fascione 提供了_PhysLight_系统的实现，该系统已并入 `pbrt` 的 `PixelSensor` 类和光源实现。
]

#parec[
  Many people have reported errors in the text of previous editions or bugs in `pbrt`. We'd especially like to thank Solomon Boulos, Stephen Chenney, Per Christensen, John Danks, Mike Day, Kevin Egan, Volodymyr Kachurovskyi, Kostya Smolenskiy, Ke Xu, and Arek Zimny, who have been especially prolific.
][
  许多人报告了以前版本的文本错误或错误 `pbrt` 。我们要特别感谢 Solomon Boulos、Stephen Chenney、Per Christensen、John Danks、Mike Day、Kevin Egan、Volodymyr Kachurovskyi、Kostya Smolenskiy、Ke Xu 和 Arek Zimny，他们的成果尤其丰富。
]

#parec[
  For their suggestions and bug reports, we would also like to thank Rachit Agrawal, Frederick Akalin, Thomas de Bodt, Mark Bolstad, Brian Budge, Jonathon Cai, Bryan Catanzaro, Tzu-Chieh Chang, Mark Colbert, Yunjian Ding, Tao Du, Marcos Fajardo, Shaohua Fan, Luca Fascione, Etienne Ferrier, Nigel Fisher, Jeppe Revall Frisvad, Robert G. Graf, Asbjørn Heid, Steve Hill, Wei-Feng Huang, John “Spike” Hughes, Keith Jeffery, Greg Johnson, Aaron Karp, Andrew Kensler, Alan King, Donald Knuth, Martin Kraus, Chris Kulla, Murat Kurt, Larry Lai, Morgan McGuire, Craig McNaughton, Don Mitchell, Swaminathan Narayanan, Anders Nilsson, Jens Olsson, Vincent Pegoraro, Srinath Ravichandiran, Andy Selle, Sébastien Speierer, Nils Thuerey, Eric Veach, Ingo Wald, Zejian Wang, Xiong Wei, Wei-Wei Xu, Tizian Zeltner, and Matthias Zwicker. Finally, we would like to thank the _LuxRender_ developers and the _LuxRender_ community, particularly Terrence Vergauwen, Jean-Philippe Grimaldi, and Asbjørn Heid; it has been a delight to see the rendering system they have built from `pbrt`'s foundation, and we have learned from reading their source code and implementations of new rendering algorithms.
][
  我们还要感谢 Rachit Agrawal、Frederick Akalin、Thomas de Bodt、Mark Bolstad、Brian Budge、Jonathon Cai、Bryan Catanzaro、Tzu-​​Chieh Chang、Mark Colbert、Yunjian Ding、Tao Du、Marcos 的建议和错误报告Fajardo、范少华、Luca Fascione、Etienne Ferrier、Nigel Fisher、Jeppe Revall Frisvad、Robert G. Graf、Asbjørn Heid、Steve Hill、Wei-Feng Huang、John “Spike” Hughes、Keith Jeffery、Greg Johnson、Aaron Karp、Andrew肯斯勒, 艾伦·金, 唐纳德·克努斯, 马丁·克劳斯, 克里斯·库拉, 穆拉特·库尔特, 拉里·赖, 摩根·麦奎尔, 克雷格·麦克诺顿, 唐·米切尔, 斯瓦米纳坦·纳拉亚南, 安德斯·尼尔森, 延斯·奥尔森, 文森特·佩戈拉罗, 斯里纳斯·拉维钱迪兰, 安迪·塞勒, 塞巴斯蒂安·斯派尔, Nils Thuerey、Eric Veach、Ingo Wald、Zejian Wang、Xiong Wei、Wei-Wei Xu、Tizian Zeltner 和 Matthias Zwicker。最后，我们要感谢_LuxRender_开发人员和L​​uxRender社区，特别是 Terrence Vergauwen、Jean-Philippe Grimaldi 和 Asbjørn Heid；很高兴看到他们构建的渲染系统 `pbrt` 的基础，我们通过阅读他们的源代码和新渲染算法的实现来学习。
]

#parec[
  Special thanks to Martin Preston and Steph Bruning from Framestore for their help with our being able to use a frame from Gravity (image courtesy of Warner Bros. and Framestore), and to Weta Digital for their help with the frame from Alita: Battle Angel (© 2018 Twentieth Century Fox Film Corporation, All Rights Reserved).
][
  特别感谢 Framestore 的 Martin Preston 和 Steph Bruning 帮助我们使用《重力》的框架（图片由华纳兄弟和 Framestore 提供），并感谢 Weta Digital 帮助我们使用《阿丽塔：战斗天使》的框架（ © 2018 二十世纪福克斯电影公司，保留所有权利）。
]

== Production
#parec[
  For the production of the first edition, we would also like to thank our editor Tim Cox for his willingness to take on this slightly unorthodox project and for both his direction and patience throughout the process. We are very grateful to Elisabeth Beller (project manager), who went well beyond the call of duty for the book; her ability to keep this complex project in control and on schedule was remarkable, and we particularly thank her for the measurable impact she had on the quality of the final result. Thanks also to Rick Camp (editorial assistant) for his many contributions along the way. Paul Anagnostopoulos and Jacqui Scarlott at Windfall Software did the book's composition; their ability to take the authors' homebrew literate programming file format and turn it into high-quality final output while also juggling the multiple unusual types of indexing we asked for is greatly appreciated. Thanks also to Ken DellaPenta (copyeditor) and Jennifer McClain (proofreader), as well as to Max Spector at Chen Design (text and cover designer) and Steve Rath (indexer).
][
  对于第一版的制作，我们还要感谢我们的编辑 Tim Cox 愿意承担这个有点非正统的项目，以及他在整个过程中的指导和耐心。我们非常感谢伊丽莎白·贝勒（Elisabeth Beller）（项目经理），她的工作远远超出了本书的职责范围。她控制这个复杂项目并按计划进行的能力非常出色，我们特别感谢她对最终结果的质量产生的可衡量的影响。还要感谢 Rick Camp（编辑助理）一路以来做出的许多贡献。 Windfall Software 的 Paul Anagnostopoulos 和 Jacqui Scarlott 撰写了这本书；他们能够采用作者的自制程序文件格式并将其转化为高质量的最终输出，同时还能够处理我们要求的多种不寻常的索引类型，这一点值得高度赞赏。还要感谢 Ken DellaPenta（文案编辑）和 Jennifer McClain（校对员），以及 Chen Design 的 Max Spector（文本和封面设计师）和 Steve Rath（索引员）。
]

#parec[
  For the second edition, we would like to thank Greg Chalson, who talked us into expanding and updating the book; Greg also ensured that Paul Anagnostopoulos at Windfall Software would again do the book's composition. We would like to thank Paul again for his efforts in working with this book's production complexity. Finally, we would also like to thank Todd Green, Paul Gottehrer, and Heather Scherer at Elsevier.
][
  对于第二版，我们要感谢格雷格·查尔森（Greg Chalson），他说服我们扩展和更新了本书； Greg 还确保 Windfall Software 的 Paul Anagnostopoulos 再次负责本书的撰写。我们要再次感谢 Paul 在解决本书制作复杂性方面所做的努力。最后，我们还要感谢爱思唯尔的 Todd Green、Paul Gottehrer 和 Heather Scherer。
]

#parec[
  For the third edition, we would like to thank Todd Green, who oversaw that go-round, and Amy Invernizzi, who kept the train on the rails throughout that process. We were delighted to have Paul Anagnostopoulos at Windfall Software part of this process for a third time; his efforts have been critical to the book's high production value, which is so important to us.
][
  对于第三版，我们要感谢托德·格林（Todd Green）和艾米·因弗尼兹（Amy Invernizzi），托德·格林（Todd Green）监督了整个过程，艾米·因弗尼兹（Amy Invernizzi）使火车在整个过程中保持在轨道上。我们很高兴 Windfall Software 的 Paul Anagnostopoulos 第三次参与此流程；他的努力对于这本书的高产值至关重要，这对我们来说非常重要。
]

#parec[
  The fourth edition saw us moving to MIT Press; many thanks to Elizabeth Swayze for her enthusiasm for bringing us on board, guidance through the production process, and ensuring that Paul Anagnostopoulos would again handle composition. Our deepest thanks to Paul for coming back for one more edition with us, and many thanks as well to MaryEllen Oliver for her superb work on copyediting and proofreading.
][
  第四版我们转向了麻省理工学院出版社；非常感谢伊丽莎白·斯威兹 (Elizabeth Swayze) 热情地邀请我们加入，指导整个制作过程，并确保保罗·阿纳格诺斯托普洛斯 (Paul Anagnostopoulos) 再次处理构图。我们最深切地感谢保罗回来与我们一起再出版一版，也非常感谢玛丽埃伦·奥利弗在文案编辑和校对方面的出色工作。
]

== The Online edition


#parec[
  As of November 1, 2023, the full text of the fourth edition is available online for free. Many thanks to MIT Press and Elizabeth Swayze for their support of a freely-available version of the book.
][
  自2023年11月1日起，第四版全文可在线免费获取。非常感谢麻省理工学院出版社和伊丽莎白·斯威兹对本书免费版本的支持。#translator[这一部分英文pdf没有，参考的pbrt.org/4ed上的内容]
]

#parec[
  A number of open source systems have been instrumental to the development of the online version of Physically Based Rendering. We'd specifically like to thank the developers of #link("https://getbootstrap.com/")[Bootstrap], #link("https://jeri.io/")[JERI], #link("https://www.mathjax.org/")[MathJax] and #link("https://jquery.com/")[JQuery]. We'd also like to thank Impallari Type for the design of the #link("https://fonts.google.com/specimen/Domine")[Domine] font that we use for body text; Christian Robertson for the design of the #link("https://fonts.google.com/specimen/Roboto+Mono")[Roboto Mono] font that we use for code; and the designers of the #link("https://fontawesome.com/")[Font Awesome] fonts.
][
  许多开源系统对基于物理的渲染在线版本的开发发挥了重要作用。我们要特别感谢#link("https://getbootstrap.com/")[Bootstrap] 、 #link("https://jeri.io/")[JERI] 、 #link("https://www.mathjax.org/")[MathJax]和#link("https://jquery.com/")[JQuery]的开发人员。我们还要感谢 Impallari Type 设计了我们用于正文的#link("https://fonts.google.com/specimen/Domine")[Domine]字体； Christian Robertson 设计了我们用于代码的#link("https://fonts.google.com/specimen/Roboto+Mono")[Roboto Mono]字体；以及#link("https://fontawesome.com/")[Font Awesome]字体的设计者。
]

#parec[
  We'd also like to thank everyone who supported the earlier online edition through _Patreon_; as of 1 November 2023: 3Dscan, Abdelhakim Deneche, Alain Galvan, Andréa Machizaud, Aras Pranckevicius, Arman Uguray, Ben Bass, Claudia Doppioslash, Dong Feng, Enrico, Filip Strugar, Haralambi Todorov, Jaewon Jung, Jan Walter, Jendrik Illner, Jim Price, Joakim Dahl, Jonathan Stone, KrotanHill, Laura Reznikov, Malte Nawroth, Mauricio Vives, Mrinal Deo, Nathan Vegdahl, Pavel Panchekha, Pratool Gadtaula, Saad Ahmed, Scott Pilet, Shin Watanabe, Steve Watts Kennedy, Tom Hulton-Harrop, Torgrim Boe Skaarsmoen, William Newhall, Yining Karl Li, and Yury Mikhaylov. We have, however, closed the Patreon with the launch of the fourth edition.
][
  我们还要感谢所有通过_Patreon_支持早期在线版本的人；截至 2023 年 11 月 1 日：3Dscan、Abdelhakim Deneche、Alain Galvan、Andréa Machizaud、Aras Pranckevicius、Arman Uguray、Ben Bass、Claudia Doppioslash、Dong Feng、Enrico、Filip Strugar、Haralambi Todorov、Jaewon Jung、Jan Walter、Jendrik Illner、Jim普赖斯、乔金·达尔、乔纳森·斯通、KrotanHill、劳拉·雷兹尼科夫、马尔特·纳罗斯、毛里西奥·比韦斯、Mrinal Deo、内森·维格达尔、帕维尔·潘切卡、普拉图尔·加陶拉、萨阿德·艾哈迈德、斯科特·皮莱、渡边信、史蒂夫·沃茨·肯尼迪、汤姆·休尔顿-哈罗普、托格瑞姆Boe Skaarsmoen、William Newhall、Yining Karl Li 和 Yury Mikhaylov。然而，随着第四版的推出，我们已经关闭了Patreon 。
]

#parec[
  Although the book is posted online for anyone to read for free, the text of the book remains #sym.copyright Copyright 2004–2023 Matt Pharr, Wenzel Jakob, and Greg Humphreys under a #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0] license. The book figures are licensed with a #link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0]license with the thought that they may be useful when teaching graphics courses.
][
  尽管该书已发布在网上供任何人免费阅读，但该书的文本仍属于#sym.copyright 版权所有 2004–2023 Matt Pharr、Wenzel Jakob 和 Greg Humphreys，并获得#link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0]许可。本书中的人物已获得#link("https://creativecommons.org/licenses/by-nc-nd/4.0/")[CC BY-NC-ND 4.0]许可证，认为它们在教授图形课程时可能会很有用。
]


== Scenes, Models, and Data
#parec[
  Many people and organizations have generously provided scenes and models for use in this book and the `pbrt` distribution. Their generosity has been invaluable in helping us create interesting example images throughout the text.
][
  许多人和组织慷慨地提供了本书和本书分发版中使用的场景和模型。他们的慷慨帮助我们在整个文本中创建有趣的示例图像，这是非常宝贵的。
]

#parec[
  We are most grateful to Guillermo M. Leal Llaguno of Evolución Visual, #link("www.evvisual.com")[www.evvisual.com], who modeled and rendered the iconic San Miguel scene that was featured on the cover of the second edition and is still used in numerous figures in the book. We would also especially like to thank Marko Dabrovic (#link("www.3lhd.com")[www.3lhd.com]) and Mihovil Odak at RNA Studios (#link(" www.rna.hr")[www.rna.hr]), who supplied a bounty of models and scenes used in earlier editions of the book, including the Sponza atrium, the Sibenik cathedral, and the Audi TT car model that can be seen in @fig:tt-pbrt-v1-v4 of this edition. Many thanks are also due to Florent Boyer, who provided the contemporary house scene used in some of the images in Chapter chap:bidir-methods.
][
  我们非常感谢 Evolución Visual（ #link("www.evvisual.com")[www.evvisual.com]）的 Guillermo M. Leal Llaguno，他建模并渲染了第二版封面上的标志性生力啤酒场景，该场景至今仍在书中的许多人物中使用。我们还要特别感谢 RNA Studios ( #link(" www.rna.hr")[www.rna.hr]) 的 Marko Dabrovic #link("www.3lhd.com")[www.3lhd.com])和 Mihovil Odak，他们提供了本书早期版本中使用的大量模型和场景，包括 Sponza 中庭、希贝尼克大教堂，以及本版@fig:tt-pbrt-v1-v4 中可以看到的奥迪TT车型。还要感谢 Florent Boyer，他提供了`Chapter chap:bidir-methods`#translator[pbrt.org/4ed的原文这地方就错了，暂时不知道是哪个章节的链接]中的一些图像中使用的当代房屋场景。
]

#parec[
  We sincerely thank Jan-Walter Schliep, Burak Kahraman, and Timm Dapper of Laubwerk (#link("www.laubwerk.com")[www.laubwerk.com]) for creating the Countryside landscape scene that was on the cover of the previous edition of the book and is used in numerous figures in this edition.
][
  我们衷心感谢 Laubwerk ( #link("www.laubwerk.com")[www.laubwerk.com] ) 的 Jan-Walter Schliep、Burak Kahraman 和 Timm Dapper 创作的乡村风景场景，该场景出现在本书上一版本的封面上，并在本版本的众多人物中使用。
]

#parec[
  Many thanks to Angelo Ferretti of Lucydreams (#link("www.lucydreams.it")[www.lucydreams.it]) for licensing the Watercolor and Kroken scenes, which have provided a wonderful cover image for this edition, material for numerous figures, and a pair of complex scenes that exercise `pbrt`'s capabilities.
][
  非常感谢 Lucydreams (#link("www.lucydreams.it")[www.lucydreams.it]) 的 Angelo Ferretti 授权了水彩画和Kroken场景，为本版本提供了精彩的封面图片、大量人物素材以及一对练习的复杂场景 `pbrt` 的能力。
]

#parec[
  Jim Price kindly provided a number of scenes featuring interesting volumetric media; those have measurably improved the figures for that topic. Thanks also to Beeple for making the _Zero Day and Transparent Machines scenes_ available under a permissive license and to Martin Lubich for the Austrian Imperial Crown model. Finally, our deepest thanks to Walt Disney Animation Studios for making the production-complexity Moana Island scene available as well as providing the detailed volumetric cloud model.
][
  吉姆·普莱斯（Jim Price）慷慨地提供了许多具有有趣的体积媒体的场景；这些显着改善了该主题的数字。还要感谢 Beeple 在许可下提供_零日和透明机器场景_，并感谢 Martin Lubich 提供的奥地利帝国皇冠模型。最后，我们最深切地感谢华特迪士尼动画工作室提供了制作复杂的莫阿纳岛场景，并提供了详细的体积云模型。
]

#parec[
  The bunny, Buddha, and dragon models are courtesy of the Stanford Computer Graphics Laboratory's scanning repository. The “killeroo” model is included with permission of Phil Dench and Martin Rezard (3D scan and digital representations by headus, design and clay sculpt by Rezard). The dragon model scan used in @reflection-models is courtesy of Christian Schüller, and our thanks to Yasutoshi Mori for the material orb and the sports car model. The glass used to illustrate caustics in Chapter chap:bidir-methods is thanks to Simon Wendsche. The head model used to illustrate subsurface scattering was made available by Infinite Realities, Inc. under a Creative Commons Attribution 3.0 license. Thanks also to “tyrant monkey” for the BMW M6 car model and “Wig42” for the breakfast table scene; both were posted to #link("http://blendswap.com/")[blendswap.com], also under a Creative Commons Attribution 3.0 license.
][
  兔子、佛陀和龙模型由斯坦福计算机图形实验室的扫描存储库提供。 “killeroo”模型经过 Phil Dench 和 Martin Rezard 的许可（3D 扫描和数字表示由 headus 提供，设计和粘土雕塑由 Rezard 提供）。@reflection-models 中使用的龙模型扫描由 Christian Schüller 提供，并感谢 Yasutoshi Mori 提供的材料球和跑车模型。在章节 chap:bidir-methods 中用于说明焦散的玻璃感谢 Simon Wendsche。用于说明次表面散射的头部模型由 Infinite Realities, Inc. 根据 Creative Commons Attribution 3.0 许可提供。还要感谢“暴君猴”的宝马M6车型和“Wig42”的早餐桌场景；两者均已发布到#link("http://blendswap.com/")[blendswap.com] ，同样采用 Creative Commons Attribution 3.0 许可证。
]

#parec[
  We have made use of numerous environment maps from the _PolyHaven_ website (#link("http://polyhaven.com/")[polyhaven.com]) for HDR lighting in various scenes; all are available under a Creative Commons CC0 license. Thanks to Sergej Majboroda and Greg Zaal, whose environment maps we have used.
][
  我们利用_PolyHaven_网站 (#link("http://polyhaven.com/")[polyhaven.com]) 中的大量环境贴图来实现各种场景中的 HDR 照明；所有这些都可以在 Creative Commons CC0 许可证下使用。感谢 Sergej Majboroda 和 Greg Zaal，我们使用了他们的环境贴图。
]

#parec[
  Marc Ellens provided spectral data for a variety of light sources, and the spectral RGB measurement data for a variety of displays is courtesy of Tom Lianza at X-Rite. Our thanks as well to Danny Pascale (#link("http://www.babelcolor.com/")[www.babelcolor.com/]) for allowing us to include his measurements of the spectral reflectance of a color chart. Thanks to Mikhail Polyanskiy for index of refraction data via #link("http://refractiveindex.info/")[refractiveindex.info] and to Anders Langlands, Luca Fascione, and Weta Digital for camera sensor response data that is included in `pbrt`.
][
  Marc Ellens 提供了各种光源的光谱数据，各种显示器的光谱 RGB 测量数据由 X-Rite 的 Tom Lianza 提供。我们还要感谢 Danny Pascale (#link("http://www.babelcolor.com/")[www.babelcolor.com/]) 允许我们包含他对色卡光谱反射率的测量结果。感谢 Mikhail Polyanskiy 通过#link("http://refractiveindex.info/")[refractiveindex.info]提供的折射率数据，感谢 Anders Langlands、Luca Fascione 和 Weta Digital 提供的相机传感器响应数据（包含在 `pbrt` ）。
]

== About The Cover
#parec[
  The _Watercolor_ scene on the cover was created by Angelo Ferretti of Lucydreams (#link("www.lucydreams.it")[www.lucydreams.it]). It requires a total of 2 GiB of on-disk storage for geometry and 836 MiB for texture maps. Come rendering, the scene description requires 15 GiB of memory to store over 33 million unique triangles, 412 texture maps, and associated data structures.
][
  封面上的_水彩_场景由 Lucydreams ( #link("www.lucydreams.it")[www.lucydreams.it] ) 的 Angelo Ferretti 创作。它总共需要 2 GiB 的磁盘存储空间用于几何图形，需要 836 MiB 的磁盘存储空间用于纹理贴图。在渲染时，场景描述需要 15 GiB 内存来存储超过 3300 万个独特的三角形、412 个纹理贴图和关联的数据结构。
]
