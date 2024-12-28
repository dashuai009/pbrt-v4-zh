#import "../template.typ": parec

#parec[
  The idea for `pbrt` was born in October 1999. Over the next five years, it evolved from a system designed only to support the students taking Stanford's CS348b course to a robust, feature-rich, extensible rendering system. Since its inception, we have learned a great deal about what it takes to build a rendering system that does not just make pretty pictures but is one that other people enjoy using and modifying as well. What has been most difficult, however, is designing a large piece of software that others might enjoy reading. This has been a far more challenging (and rewarding) task than implementing any of the rendering algorithms themselves.
][
  `pbrt` 的构思始于1999年 10月。在接下来的五年中，它从一个仅为支持斯坦福大学CS348b课程的学生而设计的系统，演变为一个强大、功能齐全、可扩展的渲染系统。 自其诞生以来，我们学到了很多关于如何构建一个不仅仅是制作漂亮图片的渲染系统，而且是一个其他人也喜欢使用和修改的系统。 然而，最困难的是设计一个其他人可能会喜欢阅读的大型软件。这比实现任何渲染算法本身都要更具挑战性（且更有成就感）。
]

#parec[
  After its first publication, the book enjoyed widespread adoption in advanced graphics courses worldwide, which we found very gratifying. We were unprepared, however, for the impact that `pbrt` has had on rendering research. Writing a ray tracer from scratch is a formidable task (as so many students in undergraduate graphics courses can attest), and creating a robust physically based renderer is much harder still. We are proud that `pbrt` has lowered the barrier to entry for aspiring researchers in rendering, making it easier for researchers to experiment with and demonstrate the value of new ideas in rendering. We continue to be delighted to see papers in SIGGRAPH, the Eurographics Rendering Symposium, High Performance Graphics, and other graphics research venues that either build on `pbrt` to achieve their goals, or compare their images to `pbrt` as "ground truth."
][
  在首次出版后，这本书在全球的高级图形课程中被广泛采用，这令我们感到非常欣慰。 然而，我们没有预料到 `pbrt` 对渲染研究的影响。 从零开始编写一个光线追踪器是一项艰巨的任务（正如许多本科图形课程的学生所能证明的），而创建一个强大的基于物理的渲染器则更为困难。 我们自豪的是，`pbrt` 降低了渲染领域新兴研究人员的入门门槛，使研究人员更容易实验并展示渲染新思想的价值。 我们继续欣喜地看到在 SIGGRAPH、Eurographics 渲染研讨会、高性能图形和其他图形研究场所的论文中，要么基于 `pbrt` 实现其目标，要么将其图像与 `pbrt` 作为“基准”进行比较。
]

#parec[
  More recently, we have been delighted again to see the rapid adoption of path tracing and physically based approaches in practice for offline rendering and, recently as of this writing, games and interactive applications. Though we are admittedly unusual folk, it is a particular delight to see incredible graphics on a screen and marvel at the billions of pseudo-random (or quasi-random) samples taken, billions of rays traced, and the complex mathematics that went into each image passing by.
][
  最近，我们再次欣喜地看到路径追踪和基于物理的方法在离线渲染中迅速被采用，并且在撰写本文时，已经在游戏和交互式应用中得到应用。 虽然我们承认自己是有些不寻常的人，但看到屏幕上令人惊叹的图形，并感慨于数十亿个伪随机（或准随机）样本的采集、数十亿条光线的追踪，以及每幅图像背后复杂的数学运算，确实是一种独特的乐趣。
]

#parec[
  We would like to sincerely thank everyone who has built upon this work for their own research, to build a new curriculum, to create amazing movies or games, or just to learn more about rendering. We hope that this new edition continues to serve the graphics community in the same way that its predecessors have.
][
  我们想真诚地感谢所有基于这项工作进行研究、制作精彩电影或游戏、构建新课程，或只是为了更好地了解渲染的人们。 我们希望新版能像其前辈一样继续为图形社区服务。
]


