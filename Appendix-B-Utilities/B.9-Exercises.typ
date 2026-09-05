#import "../template.typ": parec, ez_caption

== #ez_caption[Exercises][习题]
<appendix-b-exercises>

#parec[
  #enum(start: 1)[② It is possible to use image pyramids and MIP mapping with images that have non-power-of-two resolutions—the details are explained by Guthe and Heckbert (#link(<tailb-cite:Guthe05>)[2005]). Implementing this approach can save a substantial amount of memory: in the worst case, the resampling that `pbrt`'s #link("https://pbr-book.org/4ed/Textures_and_Materials/Image_Texture.html#MIPMap")[`MIPMap`] implementation performs can increase memory requirements by a factor of four. (Consider a $513 times 513$ texture that is resampled to be $1024 times 1024$.) Implement this approach in `pbrt`, and compare the amount of memory used to store texture data for a variety of texture-heavy scenes.]
][
  #enum(start: 1)[② 图像金字塔与 MIP 映射也可以用于分辨率不是二的幂的图像，具体方法见 Guthe 和 Heckbert（#link(<tailb-cite:Guthe05>)[2005]）。实现这一方法可以节省大量内存：最坏情况下，`pbrt` 的 #link("https://pbr-book.org/4ed/Textures_and_Materials/Image_Texture.html#MIPMap")[`MIPMap`] 实现所做的重采样，会使内存需求增至四倍。（想想将 $513 times 513$ 的纹理重采样为 $1024 times 1024$ 的情况。）在 `pbrt` 中实现该方法，并用多种大量使用纹理的场景，比较纹理数据占用的内存。]
]

#parec[
  #enum(start: 2)[② Improve the filtering algorithm used in the #link("https://pbr-book.org/4ed/Utilities/Images.html#Image::GeneratePyramid")[`Image::GeneratePyramid()`] method to initialize the pyramid levels using the Lanczos filter instead of the box filter. How do the sphere test images in #link("https://pbr-book.org/4ed/Textures_and_Materials/Image_Texture.html#fig:texfilt-ewa-trilerp")[Figure 10.16] change after your modifications? Do you see a difference in other scenes that use image textures?]
][
  #enum(start: 2)[② 改进 #link("https://pbr-book.org/4ed/Utilities/Images.html#Image::GeneratePyramid")[`Image::GeneratePyramid()`] 使用的滤波算法，以 Lanczos 滤波器代替盒式滤波器来初始化金字塔各层。修改后，#link("https://pbr-book.org/4ed/Textures_and_Materials/Image_Texture.html#fig:texfilt-ewa-trilerp")[图 10.16] 中的球体测试图像有何变化？在其他使用图像纹理的场景中，你能否观察到差异？]
]

#parec[
  #enum(start: 3)[② Try a few alternative implementations of the statistics system described in #link("https://pbr-book.org/4ed/Utilities/Statistics.html#sec:stats")[Section B.7] to get a sense of the performance trade-offs with various approaches. You might try using atomic operations to update single counters that are shared across threads, or you might try using a mutex to allow safe updates to shared counters by multiple threads. Measure the performance compared to `pbrt`'s current implementation and discuss possible explanations for your results.]
][
  #enum(start: 3)[② 为 #link("https://pbr-book.org/4ed/Utilities/Statistics.html#sec:stats")[第 B.7 节] 的统计系统尝试几种替代实现，体会不同方法的性能权衡。例如，可以用原子操作更新各线程共享的单个计数器，也可以用互斥锁，让多个线程安全地更新共享计数器。测量它们相对于 `pbrt` 当前实现的性能，并讨论结果可能的原因。]
]

#parec[
  #enum(start: 4)[③ Generalize the statistics system (including the per-pixel statistics) so that it is also available in the GPU rendering path. You will likely want to pursue an approach based on atomic variables rather than the `thread_local` approach that is used for the CPU. Measure the performance of your implementation and compare to the system before your changes. Is performance meaningfully affected?]
][
  #enum(start: 4)[③ 扩展统计系统，包括逐像素统计，使其也能用于 GPU 渲染路径。你很可能需要采用基于原子变量的方法，而不是 CPU 所用的 `thread_local` 方法。测量你的实现的性能，并与修改前的系统比较：性能是否受到显著影响？]
]
