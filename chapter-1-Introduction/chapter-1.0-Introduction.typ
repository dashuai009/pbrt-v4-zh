#import "../template.typ": parec, ez_caption

= #ez_caption[Introduction][引言]
<introduction>

#figure(image("../pbr-book-website/4ed/openers/nightsnow.jpg", width: 100%))
#parec[
  Rendering is the process of producing an image from the description of a 3D scene. Obviously, this is a broad task, and there are many ways to approach it. _Physically based_ techniques attempt to simulate reality; that is, they use principles of physics to model the interaction of light and matter. While a physically based approach may seem to be the most obvious way to approach rendering, it has only been widely adopted in practice over the past 15 or so years.
][
  渲染是根据三维场景的描述生成图像的过程。显然，这项任务涵盖面很广，实现途径也很多。基于物理的技术试图模拟现实，也就是利用物理原理对光与物质的相互作用建模。尽管基于物理的方法似乎是进行渲染最自然的选择，但它在实践中得到广泛采用，也只是近 15 年左右的事。
]

#parec[
  This book describes `pbrt`, a physically based rendering system based on the ray-tracing algorithm. It is capable of rendering realistic images of complex scenes such as the one shown in @fig:pbrt-kroken-view. (Other than a few exceptions in this chapter that are noted with their appearance, all the images in this book are rendered with `pbrt`.)
][
  本书介绍 `pbrt`，一个采用光线追踪算法的基于物理的渲染系统。它能够为复杂场景生成逼真的图像，如 @fig:pbrt-kroken-view 所示。（除本章中少数在出现时特别注明的例外之外，本书所有图像均由 `pbrt` 渲染。）
]


#parec[
  Most computer graphics books present algorithms and theory, sometimes combined with snippets of code. In contrast, this book couples the theory with a complete implementation of a fully functional rendering system. Furthermore, the full source code of the system is available under an open-source license, and the full text of this book is freely available online at #link("https://pbr-book.org/4ed")[pbr-book.org/4ed], as of November 1, 2023. Further information, including example scenes and additional information about pbrt, can be found on the website, #link("https://pbrt.org")[pbrt.org].
][
  大多数计算机图形学书籍介绍算法与理论，有时辅以代码片段。本书则将理论与一个功能完备的渲染系统的完整实现结合起来。此外，该系统的全部源代码以开源许可发布；自 2023 年 11 月 1 日起，本书全文也可在 #link("https://pbr-book.org/4ed")[pbr-book.org/4ed] 在线免费阅读。示例场景及有关 `pbrt` 的更多信息可在 #link("https://pbrt.org")[pbrt.org] 网站获取。
]

#figure(
  image("../pbr-book-website/4ed/kroken-view-ch1.png", width: 70%),
  caption: [
    #ez_caption[A Scene Rendered by pbrt. The Kroken scene features complex geometry, materials, and light transport. Handling all of these effects well in a rendering system makes it possible to render photorealistic images like this one. This scene and many others can be downloaded from the pbrt website. (Scene courtesy of Angelo Ferretti.)
    ][由 pbrt 渲染的场景。Kroken 场景包含复杂的几何结构、材质和光传输。渲染系统若能妥善处理这些效果，就能生成这样的照片级逼真图像。该场景及许多其他场景均可从 pbrt 网站下载。（场景由 Angelo Ferretti 提供。）
    ]
  ],
) <pbrt-kroken-view>
