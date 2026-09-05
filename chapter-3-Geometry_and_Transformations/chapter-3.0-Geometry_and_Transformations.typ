#import "../template.typ": parec, ez_caption

= #ez_caption[Geometry and Transformations][几何与变换]
<geometry-and-transformations>

#figure(
  image("../pbr-book-website/4ed/openers/killeroo-control.jpg"),
)

#parec[
  Almost all nontrivial graphics programs are built on a foundation of geometric classes that represent mathematical constructs like points, vectors, and rays. Because these classes are ubiquitous throughout the system, good abstractions and efficient implementations are critical. This chapter presents the interface to and implementation of `pbrt`'s geometric foundation. Note that these are not the classes that represent the actual scene geometry (triangles, spheres, etc.); those classes are the topic of @Shapes .
][
  几乎所有具有一定复杂性的图形程序，都以表示点、向量和射线等数学对象的几何类为基础。这些类遍布整个系统，因此良好的抽象和高效的实现至关重要。本章介绍 `pbrt` 几何基础部分的接口与实现。请注意，这些类并不表示场景中的实际几何体（三角形、球体等）；用于表示实际几何体的类将在 @Shapes 中介绍。
]


