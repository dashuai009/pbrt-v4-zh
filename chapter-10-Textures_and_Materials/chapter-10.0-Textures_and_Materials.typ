#import "../template.typ": parec, ez_caption

= Textures and Materials
<textures-and-materials>
#parec[
  The BRDFs and BTDFs introduced in the previous chapter address only part of the problem of describing how a surface scatters light. Although they describe how light is scattered at a particular point on a surface, the renderer needs to determine #emph[which] BRDFs and BTDFs are present at a point on a surface and what their parameters are. In this chapter, we describe a procedural shading mechanism that addresses this issue.
][
  在前一章中介绍的BRDF（双向反射分布函数）和BTDF（双向透射分布函数）仅解决了描述表面如何散射光线问题的一部分。虽然它们描述了光线在表面特定点的散射方式，但渲染器需要确定在表面某一点上存在#emph[哪些];BRDF和BTDF及其参数。 在本章中，我们描述了一种解决此问题的程序化着色机制，即一种自动生成着色效果的机制。
]

#parec[
  There are two components to `pbrt`'s approach: textures, which describe the spatial variation of some scalar or spectral value over a surface, and materials, which evaluate textures at points on surfaces in order to determine the parameters for their associated BSDFs. Separating the pattern generation responsibilities of textures from the implementations of reflection models via materials makes it easy to combine them in arbitrary ways, thereby making it easier to create a wide variety of appearances.
][
  `pbrt`的方法有两个组成部分：纹理，描述表面上某些标量或光谱值的空间上的变化；材质，在表面上的点评估纹理以确定其相关BSDF的参数。将纹理的图案生成的职责与通过材质实现的反射模型分开，使得可以以多种方式轻松组合它们，从而更容易创建各种外观。
]

#parec[
  In `pbrt`, a #emph[texture] is a fairly general concept: it is a function that maps points in some domain (e.g., a surface's $(u , v)$ parametric space or $(x , y , z)$ object space) to values in some other domain (e.g., spectra or the real numbers). A variety of implementations of texture classes are available in the system. For example, `pbrt` has textures that represent zero-dimensional functions that return a constant in order to accommodate surfaces that have the same parameter value everywhere. Image map textures are two-dimensional functions that use a 2D array of pixel values to compute texture values at particular points (they are described in @image-texture). There are even texture functions that compute values based on the values computed by other texture functions.
][
  在`pbrt`中，#emph[纹理];是一个相当广泛的概念：它是一个将某个域（例如，表面的 $(u , v)$ 参数空间或 $(x , y , z)$ 对象空间）中的点映射到另一个域（例如，光谱或实数）的函数。 系统中提供了多种纹理类的实现。 例如，`pbrt`有表示零维函数的纹理，这些函数返回一个常数以适应在任何地方具有相同参数值的表面。 图像映射纹理是二维函数，使用二维像素值数组在特定点计算纹理值（它们在 @image-texture 中描述）。 甚至还有基于其他纹理函数计算的值来计算值的纹理函数。
]

#parec[
  Textures may be a source of high-frequency variation in the final image. @fig:texture-aliasing-example shows an image with severe aliasing due to a texture. Although the visual impact of this aliasing can be reduced with the nonuniform sampling techniques from @sampling-and-reconstruction a better solution to this problem is to implement texture functions that adjust their frequency content based on the rate at which they are being sampled. For many texture functions, computing a reasonable approximation to the frequency content and antialiasing in this manner are not too difficult and are substantially more efficient than reducing aliasing by increasing the image sampling rate.
][
  纹理可能是最终图像中高频变化的来源。 @fig:texture-aliasing-example 显示了一幅由于纹理而严重混叠（图像失真现象）的图像。 虽然可以通过@sampling-and-reconstruction 中的非均匀采样技术来减少这种混叠的视觉影响，但解决此问题的更好方法，是实现根据采样率调整其频率成分的纹理函数。 对于许多纹理函数，以这种方式计算频率内容和抗混叠的合理的近似并不困难，并且比通过增加图像采样率来减少混叠要高效得多。
]


Frequency content refers to the distribution of signal amplitudes across different frequencies, often analyzed using techniques like fast Fourier transform (FFT) to understand the frequency components present in a signal.

频率成分是指信号幅度在不同频率上的分布，通常使用快速傅里叶变换（FFT）等技术进行分析，以了解信号中存在的频率成分。


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/sphere-point-vs-ewa.png"),
  caption: [
    #ez_caption[
      Texture Aliasing. Both spheres have the same grid
      texture applied and each pixel is sampled at its center. No
      antialiasing is performed on the left sphere; because the texture
      has higher frequencies than the pixel sampling rate, severe aliasing
      results. On the right sphere, the texture function has taken into
      account the image sampling rate to prefilter its function and remove
      high-frequency detail, giving an antialiased result even with a
      single sample in each pixel.
    ][
      纹理混叠。两个球体都应用了相同的网格纹理，每个像素在其中心采样。左侧球体没有进行抗混叠；由于纹理频率高于像素采样率，导致严重的混叠。右侧球体的纹理函数考虑了图像采样率，预先滤波其函数并去除高频细节，即使每个像素只有一个样本，也能得到抗混叠的结果。
    ]
  ],
)<texture-aliasing-example>


#parec[
  The first section of this chapter will discuss the problem of texture aliasing and general approaches to solving it. We will then describe the basic texture interface and illustrate its use with a variety of texture functions. After the textures have been defined, the last @material-interface-and-implementations, introduces the Material interface and a number of implementations.
][
  本章的第一部分将讨论纹理混叠问题及其一般解决方法。接下来，我们将描述基本的纹理接口，并通过各种纹理函数来展示其用法。在定义纹理之后，最后一节 @material-interface-and-implementations 将介绍材质接口及其若干实现。
]

