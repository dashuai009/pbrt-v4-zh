#import "../template.typ": parec

= Geometry and Transformations
<geometry-and-transformations>

#figure(
  image("../pbr-book-website/4ed/openers/killeroo-control.jpg"),
)

#parec[
  Almost all nontrivial graphics programs are built on a foundation of geometric classes that represent mathematical constructs like points, vectors, and rays. Because these classes are ubiquitous throughout the system, good abstractions and efficient implementations are critical. This chapter presents the interface to and implementation of `pbrt`'s geometric foundation. Note that these are not the classes that represent the actual scene geometry (triangles, spheres, etc.); those classes are the topic of @Shapes .
][
  几乎所有非平常的图形程序都是建立在表示数学构造（如点、向量和光线）的几何类的基础之上。由于这些类在系统中普遍存在，良好的抽象和高效的实现是至关重要的。本章介绍了 `pbrt` 的几何基础的接口和实现。请注意，这些类并不表示实际场景的几何（三角形、球体等）；这些类是@Shapes 的主题。
]


