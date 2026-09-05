#import "../template.typ": parec, ez_caption

= #ez_caption[Shapes][形状]
<Shapes>


#figure(
  image("../pbr-book-website/4ed/openers/blps.jpg"),
)


#parec[
  In this chapter, we will present `pbrt`'s abstraction for geometric primitives such as spheres and triangles. Careful abstraction of geometric shapes in a ray tracer is a key component of a clean system design, and shapes are the ideal candidate for an object-oriented approach. All geometric primitives implement a common interface, and the rest of the renderer can use this interface without needing any details about the underlying shape. This makes it possible to separate the geometric and shading subsystems of `pbrt`.
][
  在本章中，我们将介绍 `pbrt` 对几何图元（如球体和三角形）的抽象。在光线追踪器中，仔细抽象几何形状是实现简洁系统设计的关键组成部分，形状很适合采用面向对象的方法。所有几何图元都实现了一个通用接口，渲染器的其余部分可以使用这个接口而无需了解底层形状的任何细节。这使得 `pbrt` 的几何和着色子系统能够分离。
]

#parec[
  `pbrt` hides details about primitives behind a two-level abstraction. The #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface provides access to the basic geometric properties of the primitive, such as its surface area and bounding box, and provides a ray intersection routine. Then, the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive] interface encapsulates additional non-geometric information about the primitive, such as its material properties. The rest of the renderer then deals only with the abstract #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive] interface. This chapter will focus on the geometry-only #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] class; the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[`Primitive`] interface is a key topic of @primitives-and-intersection-acceleration.
][
  `pbrt` 将图元的细节隐藏在两级抽象之后。#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[Shape] 接口提供对图元基本几何属性的访问，例如其表面积和包围盒，并提供射线求交例程。然后，#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[Primitive] 接口封装了关于图元的额外非几何信息，例如其材质属性。渲染器的其余部分仅处理 `Primitive` 的抽象接口。本章将重点关注仅描述几何的 #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 类；#link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#Primitive")[`Primitive`] 接口是 @primitives-and-intersection-acceleration 的关键主题。
]
