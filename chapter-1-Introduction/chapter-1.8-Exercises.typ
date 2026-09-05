#import "../template.typ": parec, ez_caption

== #ez_caption[Exercise][习题]

#parec[
  + ① A good way to gain an understanding of `pbrt` is to follow the process of computing the radiance value for a single ray in a debugger. Build a version of `pbrt` with debugging symbols and set up your debugger to run `pbrt` with a not-too-complex scene. Set breakpoints in the `ImageTileIntegrator::Render()` method and trace through the process of how a ray is generated, how its radiance value is computed, and how its contribution is added to the image. The first time you do this, you may want to specify that only a single thread of execution should be used by providing `-nthreads 1` as command-line arguments to `pbrt`; doing so ensures that all computation is done in the main processing thread, which may make it easier to understand what is going on, depending on how easy your debugger makes it to step through the program when it is running multiple threads. As you gain more understanding about the details of the system later in the book, repeat this process and trace through particular parts of the system more carefully.
][
  + ① 理解 `pbrt` 的一个好方法，是在调试器中跟踪单条射线的辐亮度计算过程。构建带调试符号的 `pbrt`，配置调试器，使其运行一个不太复杂的场景。在 `ImageTileIntegrator::Render()` 中设置断点，逐步跟踪射线如何生成、辐亮度如何计算，以及贡献如何加入图像。初次尝试时，可以向 `pbrt` 传入命令行参数 `-nthreads 1`，只使用一个执行线程，确保全部计算都在主线程中完成。这可能有助于理解程序的运行过程，具体取决于调试器对多线程程序的单步调试支持是否便利。随着后续阅读加深了对系统细节的理解，请重复这一过程，更仔细地跟踪系统的特定部分。
]

