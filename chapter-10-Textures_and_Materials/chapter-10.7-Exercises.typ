#import "../template.typ": parec

== Exercises
<exercises>
+ #strong[Read the papers by Manson and Schaefer] (2013, 2014) on
  approximating high-quality filters with MIP maps and a small number of
  bilinear samples. Add an option to use their method for texture
  filtering in place of the EWA implementation currently in `pbrt`.
  Compare image quality for a number of scenes that use textures. How
  does running time compare? You may also find it beneficial to use a
  profiler to compare the amount of time it takes to run texture
  filtering code for each of the two approaches.

+ #strong[An additional advantage of properly antialiased image map
  lookups] is that they improve cache performance. Consider, for
  example, the situation of undersampling a high-resolution image map:
  nearby samples on the screen will access widely separated parts of the
  image map, such that there is low probability that texels fetched from
  main memory for one texture lookup will already be in the cache for
  texture lookups at adjacent pixel samples. Modify `pbrt` so that it
  always does image texture lookups from the finest level of the
  `MIPMap`, being careful to ensure that the same number of texels are
  still being accessed. How does performance change? What do
  cache-profiling tools report about the overall change in effectiveness
  of the CPU cache?

+ #strong[Read Worley’s paper that describes a noise function] with
  substantially different visual characteristics than Perlin noise
  (Worley 1996). Implement this cellular noise function, and add
  #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[Texture];s
  to `pbrt` that are based on it.

+ #strong[Read some of the papers on filtering bump maps] referenced in
  the "Further Reading" section of this chapter, choose one of the
  techniques described there, and implement it in `pbrt`. Show the
  visual artifacts from bump map aliasing without the technique you
  implement, as well as examples of how well your implementation
  addresses them.

+ #strong[Modify `pbrt` to support a shading language] to allow
  user-written programs to compute texture values. Unless you are also
  interested in writing your own compiler, #emph[OSL] (Gritz et
  al.~2010) is a good choice.

+ #strong[阅读 Manson 和 Schaefer 的论文];（2013, 2014），讨论如何使用
  MIP
  映射和少量双线性样本来近似高质量滤镜。添加一个选项，使用他们的方法来替代
  `pbrt` 中当前的 EWA
  实现进行纹理过滤。比较使用纹理的多个场景的图像质量。运行时间如何对比？您可能还会发现使用分析器比较两种方法的纹理过滤代码运行时间是有益的。

+ #strong[正确抗锯齿的图像映射查找的另一个优势];是它们改善了缓存性能。例如，考虑对高分辨率图像映射进行欠采样：屏幕上的邻近样本将访问图像映射的分散部分，因此从主存储器中获取的纹素用于一个纹理查找时，几乎没有可能性它们已经在相邻像素样本的纹理查找缓存中。修改
  `pbrt` 使其始终从 `MIPMap`
  的最精细级别进行图像纹理查找，注意确保仍然访问相同数量的纹素。性能如何变化？缓存分析工具关于
  CPU 缓存整体有效性变化的报告是什么？

+ #strong[阅读 Worley 描述噪声函数的论文];，其视觉特性与 Perlin
  噪声有显著不同（Worley
  1996）。实现此细胞噪声函数，并将基于它的#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[纹理];添加到
  `pbrt` 中。

+ #strong[阅读本章“进一步阅读”部分中提到的关于凹凸贴图过滤的论文];，选择其中描述的一种技术，并在
  `pbrt`
  中实现它。展示在未使用您实现的技术时凹凸贴图混叠产生的视觉伪影，以及您的实现如何解决这些问题的示例。

+ #strong[修改 `pbrt`
以支持着色语言];，允许用户编写程序来计算纹理值。除非您也对编写自己的编译器感兴趣，否则
  #emph[OSL];（Gritz 等人 2010）是一个不错的选择。


