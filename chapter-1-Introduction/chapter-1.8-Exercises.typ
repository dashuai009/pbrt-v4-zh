#import "../template.typ": parec

== Exercises

#parec[
  - A good way to gain an understanding of `pbrt` is to follow the process of computing the radiance value for a single ray in a debugger. Build a version of `pbrt` with debugging symbols and set up your debugger to run `pbrt` with a not-too-complex scene. Set breakpoints in the `ImageTileIntegrator::Render()` method and trace through the process of how a ray is generated, how its radiance value is computed, and how its contribution is added to the image. The first time you do this, you may want to specify that only a single thread of execution should be used by providing `-nthreads 1 `as command-line arguments to `pbrt`; doing so ensures that all computation is done in the main processing thread, which may make it easier to understand what is going on, depending on how easy your debugger makes it to step through the program when it is running multiple threads. As you gain more understanding about the details of the system later in the book, repeat this process and trace through particular parts of the system more carefully.
][
  - 要理解`pbrt`的一个好方法是在调试器中跟踪单个光线的辐射值计算过程。构建一个带有调试符号的`pbrt`版本，并设置调试器以运行一个不太复杂的场景下的`pbrt`。在`ImageTileIntegrator::Render()`方法中设置断点，并追踪光线是如何生成的、其辐射值是如何计算的以及它的贡献是如何被添加到图像中的。第一次做这个时，你可能希望通过提供命令行参数`-nthreads 1`来指定只使用一个执行线程；这样做确保所有计算都在主处理线程中完成，这可能会根据你的调试器在运行多线程程序时提供的步进便利性，使得理解正在发生的事情更加容易。随着你在书中后面对系统细节的理解加深，重复这个过程并更仔细地追踪系统的特定部分。
]

