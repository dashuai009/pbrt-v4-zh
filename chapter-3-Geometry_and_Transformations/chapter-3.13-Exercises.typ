#import "../template.typ": parec, ez_caption

== #ez_caption[Exercises][习题]

#parec[
  1. ① Find a more efficient way to transform axis-aligned bounding boxes by taking advantage of the symmetries of the problem: because the eight corner points are linear combinations of three axis-aligned basis vectors and a single corner point, their transformed bounding box can be found more efficiently than by the method we have presented (Arvo #cite(label("10.5555/90767.90922"))).
][
  1. ① 利用问题的对称性，寻找更高效的轴对齐包围盒变换方法。八个角点都可以用三个沿坐标轴的基向量与一个角点的线性组合表示，因此可以比本章介绍的方法更高效地求出变换后的包围盒（Arvo，#cite(label("10.5555/90767.90922"))）。
]

#parec[
  2. ② Instead of boxes, tighter bounds around objects could be computed by using the intersections of many nonorthogonal slabs. Extend the bounding box representation in `pbrt` to allow the user to specify a bound comprised of arbitrary slabs.
][
  2. ② 用多个非正交的平行平面夹层（slab）的交集代替盒子，可以为物体构造更紧的包围范围。扩展 `pbrt` 的包围盒表示，使用户可以指定由任意夹层组成的包围范围。
]

#parec[
  3. ② The #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#DirectionCone::BoundSubtendedDirections")[`DirectionCone::BoundSubtendedDirections()`] method bounds the directions that a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] subtends from a given reference point by first finding a sphere that bounds the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] and then bounding the directions it subtends. While this gives a valid bound, it is not necessarily the smallest one possible. Derive an improved algorithm that acts directly on the bounding box, update the implementation of `BoundSubtendedDirections()`, and render scenes where that method is used (e.g., those that use a #link("https://pbr-book.org/4ed/Light_Sources/Light_Sampling.html#BVHLightSampler")[`BVHLightSampler`] to sample light sources). How are running time and image quality affected? Can you find a scene where this change gives a significant benefit?
][
  3. ② #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#DirectionCone::BoundSubtendedDirections")[`DirectionCone::BoundSubtendedDirections()`] 先为 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Bounding_Boxes.html#Bounds3f")[`Bounds3f`] 求包围球，再包围该球相对于给定参考点所张的方向，从而得到包围盒的方向范围。结果虽然有效，却不一定是最小的范围。推导一个直接作用于包围盒的改进算法，更新 `BoundSubtendedDirections()` 的实现，并渲染使用该方法的场景，例如通过 #link("https://pbr-book.org/4ed/Light_Sources/Light_Sampling.html#BVHLightSampler")[`BVHLightSampler`] 采样光源的场景。运行时间和图像质量有何变化？能否找到使这一改动带来显著收益的场景？
]

#parec[
  4. ① Change `pbrt` so that it transforms #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Normals.html#Normal3f")[`Normal3f`]s just like #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`]s, and create a scene that gives a clearly incorrect image due to this bug. (Do not forget to revert this change from your copy of the source code when you are done!)
][
  4. ① 修改 `pbrt`，让它像变换 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] 一样变换 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Normals.html#Normal3f")[`Normal3f`]，并构造一个会因这一错误而生成明显错误图像的场景。（完成后，别忘了撤销你那份源代码中的这项改动！）
]
