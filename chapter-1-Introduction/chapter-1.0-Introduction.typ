#import "../template.typ": parec, ez_caption

= Introduction
<introduction>

#figure(image("../pbr-book-website/4ed/openers/nightsnow.jpg", width: 100%))
#parec[
  Rendering is the process of producing an image from the description of a 3D scene. Obviously, this is a broad task, and there are many ways to approach it. Physically based techniques attempt to simulate reality; that is, they use principles of physics to model the interaction of light and matter. While a physically based approach may seem to be the most obvious way to approach rendering, it has only been widely adopted in practice over the past 15 or so years.
][
  渲染是根据 3D 场景的描述生成图像的过程。显然，这是一项广泛的任务，有很多方法可以实现。基于物理的技术试图模拟现实；也就是说，他们利用物理原理来模拟光与物质的相互作用。虽然基于物理的方法似乎是最明显的渲染方法，但它只是在过去 15 年左右的时间里才在实践中广泛采用。
]

#parec[
  This book describes `pbrt`, a physically based rendering system based on the ray-tracing algorithm. It is capable of rendering realistic images of complex scenes such as the one shown in @fig:pbrt-kroken-view.(Other than a few exceptions in this chapter that are noted with their appearance, all the images in this book are rendered with `pbrt`.)
][
  这本书描述了 `pbrt` ，一个基于光线追踪算法的基于物理的渲染系统。它能够渲染复杂场景的真实图像，如@fig:pbrt-kroken-view 所示。（除了本章中的一些例外情况外，本书中的所有图像均使用`pbrt`渲染而成.）
]


#parec[
  Most computer graphics books present algorithms and theory, sometimes combined with snippets of code. In contrast, this book couples the theory with a complete implementation of a fully functional rendering system. Furthermore, the full source code of the system is available under an open-source license, and the full text of this book is freely available online at #link("https://pbr-book.org/4ed")[pbr-book.org/4ed], as of November 1, 2023. Further information, including example scenes and additional information about pbrt, can be found on the website,#link("https://pbr-book.org")[pbr-book.org].
][
  大多数计算机图形学书籍都会介绍算法和理论，有时还结合代码片段。相比之下，本书将理论与功能齐全的渲染系统的完整实现结合起来。此外，该系统的完整源代码可在开源许可下获取，并且自 2023 年 11 月 1 日起，可在#link("https://pbr-book.org/4ed")[pbr-book.org/4ed]在线免费获取本书的全文。更多信息，包括示例场景和附加信息 pbrt ，可以在网站#link("https://pbr-book.org")[pbr-book.org]上找到。
]

#figure(
  image("../pbr-book-website/4ed/kroken-view-ch1.png", width: 70%),
  caption: [
    #ez_caption[A Scene Rendered by pbrt. The Kroken scene features complex geometry, materials, and light transport. Handling all of these effects well in a rendering system makes it possible to render photorealistic images like this one. This scene and many others can be downloaded from the pbrt website. (Scene courtesy of Angelo Ferretti.)
    ][渲染的场景 pbrt 。 Kroken场景具有复杂的几何形状、材质和光传输。在渲染系统中很好地处理所有这些效果使得渲染像这样的逼真图像成为可能。该场景和许多其他场景可以从 pbrt 网站。 （场景由安吉洛·费雷蒂提供。）
    ]
  ],
) <pbrt-kroken-view>
