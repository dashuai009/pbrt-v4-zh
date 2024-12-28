#import "../template.typ": parec, ez_caption

== pbrt over the Years
<pbrt-over-the-years>
#parec[
  Over four editions of this book and the four versions of `pbrt` that have accompanied them, much has changed: while path tracing has been present since the start, it was not the default integration technique until the third edition. Furthermore, the first two editions devoted many pages to techniques like irradiance caching that reuse indirect lighting computation across nearby points in order to reduce rendering time. All of those techniques but for photon mapping are gone now, as sampling algorithms have improved and computers have become much faster, making path tracing and related approaches the most appropriate focus today.
][
  在本书的四个版本及其伴随的四个版本的 `pbrt` 中，发生了许多变化：虽然路径追踪一直存在，但直到第三版才成为默认的积分技术。此外，前两版书中有许多页专门讨论了诸如辐照度缓存等技术，这些技术通过在相邻点之间重用间接光照计算来减少渲染时间。除了光子映射之外，所有这些技术现在都已经被淘汰，因为采样算法得到了改进，计算机变得更快，使得路径追踪和相关方法成为当今最合适的重点。
]

#parec[
  There have been numerous improvements throughout the system over time—we have adopted more effective algorithms as they have been developed and as we ourselves have learned more about how to write a good renderer; notably, the techniques used for generating sampling patterns and for importance sampling BSDFs and light sources are substantially better now than they were at the start. Those improvements have brought added complexity: `pbrt-v1`, the first version of the system, was roughly 20,000 lines of code, excluding tabularized data and automatically generated source files for parsing. This version is just over 60,000 lines of code measured the same way, though some of the increase is due to the addition of a variety of new features, like subsurface scattering, volumetric light transport, the `RealisticCamera`, and the `Curve` and `BilinearPatch` shapes.
][
  随着时间的推移，整个系统都有许多改进——我们采用了更有效的算法，因为它们已经被开发出来，并且随着我们自己对如何编写一个好的渲染器有了更多的了解；特别是用于生成采样模式和重要性采样 BSDF 和光源的技术现在比起初要好得多。这些改进带来了额外的复杂性：`pbrt-v1`，系统的第一个版本，大约有 20,000 行代码，不包括表格化数据和自动生成的用于解析的源文件。按照相同的标准测量，这个版本的代码行数刚刚超过 60,000，尽管其中一些增加是由于添加了各种新功能，如次表面散射、体积光传输、`RealisticCamera` 以及 `Curve` 和 `BilinearPatch` 形状。
]

#parec[
  Through all the improvements to the underlying algorithms, the bones of the system have not changed very much—`Integrator`s have always been at the core of solving the light transport equation, and many of the core interface types like `Shape`s, `Light`s, `Camera`s, `Filter`s, and `Sampler`s have all been there throughout with the same responsibilities, though there have been changes to their interfaces and operation along the way. Looking back at `pbrt-v1` now, we can find plenty of snippets of code that are still present, unchanged since the start.
][
  尽管底层算法得到了许多改进，系统的框架并没有发生太大变化——`Integrator` 一直是解决光传输方程的核心，许多核心接口类型如 `Shape`、`Light`、`Camera`、`Filter` 和 `Sampler` 自始至终都在那儿，承担着相同的责任，尽管它们的接口和操作方式在此过程中有所变化。现在回顾 `pbrt-v1`，我们可以找到许多代码片段，它们自始至终都没有改变。
]

#parec[
  To quantify the algorithmic improvements to `pbrt`, we resurrected `pbrt-v1` and compared it to the version of `pbrt` described in this book, rendering the scene shown in @fig:tt-pbrt-v1-v4.#footnote[This is an inexact comparison for many reasons. Among them:  `pbrt`  is now a spectral renderer, while before it used RGB for lighting calculations; materials like  `CoatedDiffuseMaterial`  now require stochastic evaluation; its sampling algorithms are much better, but more computationally intensive; and improvements to the geometric robustness of ray intersection computations have imposed some performance cost (@managing-rounding-error-discussion). Nevertheless, we believe that the results are directionally valid.] The latest version of `pbrt` takes 1.47 times longer than `pbrt-v1` to render this scene using path tracing, but mean squared error (MSE) with respect to reference images is improved by over 4.42 times. The net is a 3.05 times improvement in Monte Carlo efficiency purely due to algorithmic improvements.
][
  为了量化 `pbrt` 的算法改进效果，我们复活了 `pbrt-v1` 并将其与本书中描述的 `pbrt` 版本进行比较，渲染@fig:tt-pbrt-v1-v4 中显示的场景#footnote[由于许多原因，这种比较并不完全准确。其中包括：`pbrt` 现在是一个光谱渲染器，而之前它使用 RGB 进行光照计算；像 `CoatedDiffuseMaterial` 这样的材质现在需要进行随机评估；其采样算法已经大大改进，但计算量也更大；并且，射线相交计算的几何鲁棒性的改进带来了一定的性能成本（参见@managing-rounding-error-discussion）。尽管如此，我们认为结果在方向上是有效的。]。使用路径追踪渲染此场景时，`pbrt` 的最新版本比 `pbrt-v1` 花费的时间长 1.47 倍，但相对于参考图像的均方误差（MSE）提高了超过 4.42 倍。最终结果是蒙特卡洛效率提高了 3.05 倍，这纯粹是由于算法改进。
]

#figure(
  image("../pbr-book-website/4ed/Retrospective_and_the_Future/pha16f01.svg"),
  caption: [
    #ez_caption[
      Audi TT Car Model Lit by an Environment Map. (a) Reference image, rendered with `pbrt-v1` with 64k samples per pixel. (b) Rendered with `pbrt-v1` with 16 samples per pixel. (c) Reference image, rendered with `pbrt-v4` with 64k samples per pixel. (d) Rendered with `pbrt-v4` with 16 samples per pixel. (Some image differences due to changes in material models since `pbrt-v1` are expected.) The reduction in noise from (b) to (d) is notable; all of it is due to improvements in sampling and Monte Carlo integration algorithms over `pbrt`’s lifetime. #emph[(Car model courtesy of Marko Dabrovic and Mihovil Odak.)]
    ][
      由环境贴图照亮的奥迪 TT 汽车模型。 (a) 参考图像，使用 `pbrt-v1`渲染，每像素 64k 样本。 (b) 使用 `pbrt-v1` 渲染，每像素 16 样本。 (c)参考图像，使用 `pbrt-v4` 渲染，每像素 64k 样本。 (d) 使用 `pbrt-v4`渲染，每像素 16 样本。（由于 `pbrt-v1`以来材料模型的变化，预期会有一些图像差异。）从 (b) 到 (d)的噪声减少是显著的；所有这些都是由于 `pbrt`生命周期中采样和蒙特卡洛积分算法的改进所致。#emph[(汽车模型由 Marko Dabrovic 和 Mihovil Odak 提供。)]
    ]
  ],
)<tt-pbrt-v1-v4>

#parec[
  The changes in computers' computational capabilities since `pbrt-v1` have had even more of an impact on rendering performance. Much of the early development of `pbrt` in the late 1990s was on laptop computers that had a single-core 366 MHz Pentium II CPU. Some of the development of the latest version has been on a system that has 32 CPU cores, each one running at ten times the clock rate, 3.7 GHz.
][
  自 `pbrt-v1` 以来，计算机计算能力的变化对渲染性能的影响更大。`pbrt` 的早期开发大多是在 1990 年代末的笔记本电脑上进行的，这些电脑配备了单核 366 MHz 的奔腾 II CPU。最新版本的一些开发是在一个拥有 32 个 CPU 核心的系统上进行的，每个核心的时钟速度是 3.7 GHz，是原来的十倍。
]

#parec[
  A tenfold increase in processor clock speed does not tell the whole story about a CPU core's performance: there have been many microarchitectural improvements over the years such as better branch predictors, more aggressive out-of-order execution, and multi-issue pipelines. Caches have grown larger and compilers have improved as well. Data gathered by Rupp (2020) provides one measure of the aggregate improvement: from 1999 to late 2019, single-thread CPU performance as measured by the SPECInt benchmark (Standard Performance Evaluation Corporation 2006) has improved by over 40 times. Though SPECInt and `pbrt` are not the same, we still estimate that, between improvements in single-thread performance and having 32 times more cores available, the overall difference in performance between the two computers is well over a factor of 1,000.
][
  处理器时钟速度的十倍增加并不能说明 CPU 核心性能的全部：多年来有许多微架构改进，如更好的分支预测器、更积极的乱序执行和多发射流水线。缓存变得更大，编译器也得到了改进。Rupp (2020) 收集的数据提供了一种衡量总体改进的方法：从 1999 年到 2019 年底，单线程 CPU 性能（通过 SPECInt 基准测试（标准性能评估公司 2006 年）测量）提高了超过 40 倍。虽然 SPECInt 和 `pbrt` 并不相同，但我们仍然估计，考虑到单线程性能的改进和可用核心数量增加 32 倍，两个计算机之间的整体性能差异超过 1,000 倍。
]

#parec[
  The impact of a $1000 times$ speedup is immense. It means that what took an hour to render on that laptop we can now render in around three seconds. Conversely, a painfully slow hour-long rendering computation on the 32-core system today would take an intolerable 42 days on the laptop. Lest the reader feel sympathy for our having suffered with such slow hardware at the start, consider the IBM 4341 that Kajiya used for the first path-traced images: its floating-point performance was roughly 250 times slower than that of our laptop's CPU: around 0.2 MFLOPS for the 4341 (Dongarra 1984) versus around 50 for the Pentium II (Longbottom 2017). If we consider ray tracing on the GPU, where `pbrt` is generally 10–20 times faster than on the 32-core CPU, we could estimate that we are now able to path trace images around 2,500,000 times faster than Kajiya could—in other words, that `pbrt` on the GPU today can render in roughly ten seconds what his computer could do over the course of a year.
][
  1,000 倍的加速影响是巨大的。这意味着在那台笔记本电脑上需要一个小时渲染的内容，我们现在可以在大约三秒钟内渲染出来。反过来，今天在 32 核系统上耗时一个小时的渲染计算在笔记本电脑上将需要无法忍受的 42 天。为了避免读者对我们在初期使用如此缓慢的硬件感到同情，请考虑 Kajiya 用于首次路径追踪图像的 IBM 4341：其浮点性能比我们的笔记本电脑 CPU 慢大约 250 倍：大约 0.2 MFLOPS 对比奔腾 II 的大约 50（Dongarra 1984；Longbottom 2017）。 如果我们考虑在 GPU 上的光线追踪，其中 `pbrt` 通常比 32 核 CPU 快 10–20 倍，我们可以估计我们现在能够比 Kajiya 快大约 2,500,000 倍地进行路径追踪——换句话说，今天在 GPU 上的 `pbrt` 可以在大约十秒钟内渲染出他的计算机需要一年的时间才能完成的内容。
]


