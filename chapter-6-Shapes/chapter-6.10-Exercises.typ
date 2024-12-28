#import "../template.typ": parec


== Exercises

#parec[
  One nice property of mesh-based shapes like triangle meshes and subdivision surfaces is that the shape's vertices can be transformed into rendering space, so that it is not necessary to transform rays into object space before performing ray intersection tests. Interestingly enough, it is possible to do the same thing for ray–quadric intersections.
][
  像三角网格和细分曲面这样的基于网格的形状的一个优点是形状的顶点可以被转换到渲染空间，因此在执行光线交叉测试之前不需要将光线转换到对象空间。有趣的是，对于光线-二次曲面交叉，也可以做同样的事情。
]

#parec[
  The implicit forms of the quadrics in this chapter were all of the form $ a x^2 + b x y + c x z + d y^2 + e y z + f z^2 + g = 0 $, where some of the constants $a dots.h g$ were zero. More generally, we can define quadric surfaces by the equation $ a x^2 + b y^2 + c z^2 + 2 d x y + 2 e y z + 2 f x z + 2 g x + 2 h y + 2 i z + j = 0 $, where most of the parameters $a dots.h j$ do not directly correspond to the earlier $a dots.h g$.
][
  本章中的二次曲面的隐式形式都是以下形式： $ a x^2 + b x y + c x z + d y^2 + e y z + f z^2 + g = 0 $，其中一些常数 $a dots.h g$ 可能为零。更普遍地，我们可以通过以下方程定义二次曲面： $ a x^2 + b y^2 + c z^2 + 2 d x y + 2 e y z + 2 f x z + 2 g x + 2 h y + 2 i z + j = 0 $，其中大多数参数 $a dots.h j$ 并不直接对应于早期的 $a dots.h g$。
]

#parec[
  In this form, the quadric can be represented by a $4 times 4$ symmetric matrix $upright(bold(Q))$ : $
    vec(x, y, z, 1) mat(delim: "(", a, d, f, g; d, b, e, h; f, e, c, i; g, h, i, j) vec(x, y, z, 1) = upright(bold(p))^T upright(bold(Q)) upright(bold(p)) = 0 .
  $
][
  在这种形式中，二次曲面可以用一个 $4 times 4$ 的对称矩阵 $upright(bold(Q))$ 表示为： $ vec(x, y, z, 1) mat(delim: "(", a, d, f, g; d, b, e, h; f, e, c, i; g, h, i, j) vec(x, y, z, 1) = upright(bold(p))^T upright(bold(Q)) upright(bold(p)) = 0 . $
]

#parec[
  Given this representation, first show that the matrix $upright(bold(Q)) prime$ representing a quadric transformed by the matrix $upright(bold(M))$ is $ upright(bold(Q)) prime = (upright(bold(M))^T)^(- 1) upright(bold(Q)) upright(bold(M))^(- 1) . $
][
  在这种表示下，首先证明由矩阵 $upright(bold(M))$ 变换的二次曲面表示的矩阵 $upright(bold(Q)) prime$ 是 $ upright(bold(Q)) prime = (upright(bold(M))^T)^(- 1) upright(bold(Q)) upright(bold(M))^(- 1) . $
]

#parec[
  To do so, show that for any point $upright(bold(p))$ where $upright(bold(p))^T upright(bold(Q)) upright(bold(p)) = 0$, if we apply a transformation $upright(bold(M))$ to $upright(bold(p))$ and compute $upright(bold(p)) prime = upright(bold(M)) upright(bold(p))$, we would like to find $upright(bold(Q)) prime$ so that $(upright(bold(p)) prime)^T upright(bold(Q)) prime upright(bold(p)) prime = 0$.
][
  为此，证明对于任何点 $upright(bold(p))$，其中 $upright(bold(p))^T upright(bold(Q)) upright(bold(p)) = 0$，如果我们对 $upright(bold(p))$ 应用一个变换 $upright(bold(M))$ 并计算 $upright(bold(p)) prime = upright(bold(M)) upright(bold(p))$，我们希望找到 $upright(bold(Q)) prime$ 使得 $(upright(bold(p)) prime)^T upright(bold(Q)) prime upright(bold(p)) prime = 0$。
]

#parec[
  Next, substitute the ray equation into the earlier, more general quadric equation to compute coefficients for the quadratic equation in terms of entries of the matrix $upright(bold(Q))$ to pass to the `Quadratic()` function.
][
  接下来，将光线方程代入前面更普遍的二次曲面方程中，以计算矩阵 $upright(bold(Q))$ 的条目对应的二次方程的系数，以传递给 `Quadratic()` 函数。
]

#parec[
  Now implement this approach in `pbrt` and use it instead of the original quadric intersection routines. Note that you will still need to transform the resulting rendering space hit points into object space to test against $theta_(upright("max"))$, if it is not $2 pi$, and so on. How does performance compare to the original scheme?
][
  现在在 `pbrt` 中实现这种方法，并用它代替原始的二次曲面交叉例程。注意，如果 $theta_(upright("max"))$ 不是 $2 pi$，您仍然需要将结果渲染空间的命中点转换到对象空间进行测试，等等。性能与原始方案相比如何？
]

#parec[
  Transforming the object-space bounding box of a quadric to rendering space does not necessarily give an optimal bounding box. However, the matrix form of a quadric described in Exercise 6.1 can also be applied to computing optimal bounds.
][
  将二次曲面的对象空间边界框转换到渲染空间不一定会产生最佳的边界框。然而，练习 6.1 中描述的二次曲面的矩阵形式也可以用于计算最佳边界。
]

#parec[
  Read the article by Barnes (2014) on this topic and implement the approach he described in `pbrt`. How much are bounding boxes improved with this approach? Measure the effect of your changes on rendering performance for a scene with many transformed quadrics.
][
  阅读 Barnes（2014）关于此主题的文章，并在 `pbrt` 中实现他描述的方法。使用这种方法，边界框的改进有多大？测量您对包含许多转换二次曲面的场景的渲染性能的影响。
]

#parec[
  Improve the object-space bounding box routines for the quadrics to properly account for $phi.alt_(upright("max")) < frac(3 pi, 2)$ and compute tighter bounding boxes when possible. How much does this improve performance when rendering scenes with partial quadric shapes?
][
  改进二次曲面的对象空间边界框例程，以正确考虑 $phi.alt_(upright("max")) < frac(3 pi, 2)$ 并尽可能计算更紧凑的边界框。在渲染部分二次曲面形状的场景时，这对性能的提升有多大？
]

#parec[
  There is room to optimize the implementations of the various quadric primitives in `pbrt` in a number of ways. For example, for complete spheres some of the tests in the intersection routine related to partial spheres are unnecessary.
][
  在 `pbrt` 中的各种二次曲面原语的实现中有许多优化空间。例如，对于完整的球体，交叉例程中与部分球体相关的一些测试是不必要的。
]

#parec[
  Furthermore, some of the quadrics have calls to trigonometric functions that could be turned into simpler expressions using insight about the geometry of the particular primitives. Investigate ways to speed up these methods. How much does doing so improve the overall run time of `pbrt` when rendering scenes with quadrics?
][
  此外，一些二次曲面调用了三角函数，这些函数可以通过对特定原语的几何形状的洞察转化为更简单的表达式。研究加速这些方法的方法。在渲染包含二次曲面的场景时，这样做对 `pbrt` 的整体运行时间的提升有多大？
]

#parec[
  Fix the buggy `Sphere::Sample()` and `Disk::Sample()` methods, which currently do not properly account for partial spheres and disks when they sample points on the surface. Create a scene that demonstrates the error from the current implementations and for which your solution is clearly an improvement.
][
  修复有缺陷的 `Sphere::Sample()` 和 `Disk::Sample()` 方法，这些方法目前在采样表面点时未正确处理部分球体和圆盘。创建一个场景来展示当前实现中的错误，并且您的解决方案明显改进的场景。
]

#parec[
  It is possible to derive a sampling method for cylinder area light sources that only chooses points over the visible area as seen from the receiving point, similar to the improved sphere sampling method in this chapter (Gardner et al.~1987; Zimmerman 1995).
][
  可以为圆柱体区域光源推导出一种采样方法，该方法仅在可见区域内选择点，类似于本章中改进的球体采样方法（Gardner 等，1987；Zimmerman，1995）。
]

#parec[
  Write a new implementation of `Cylinder::Sample()` that implements such an algorithm. Verify that `pbrt` still generates correct images with your method, and measure how much the improved version reduces variance for a fixed number of samples taken. How much does it improve efficiency? How do you explain any discrepancy between the amount of reduction in variance and the amount of improvement in efficiency?
][
  编写一个新的 `Cylinder::Sample()` 实现来实现这样的算法。验证 `pbrt` 仍然使用您的方法生成正确的图像，并测量改进版本在固定数量的采样中减少的方差有多少。它提高了多少效率？如何解释方差减少量与效率提高量之间的差异？
]

#parec[
  Implement one of the approaches for sampling the spheres according to the projected solid angle in their visible region (Ureña and Georgiev 2018; Peters and Dachsbacher 2019). Measure the change in `pbrt`'s execution time when the alternative algorithm is used and discuss your results.
][
  实现一种根据其可见区域的投影立体角对球体进行采样的方法（Ureña 和 Georgiev，2018；Peters 和 Dachsbacher，2019）。测量使用替代算法时 `pbrt` 的执行时间变化，并讨论您的结果。
]

#parec[
  Then, measure the MSE of `pbrt`'s current approach as well as your approach for a few scenes with spherical light sources, using an image rendered with thousands of samples per pixel as a reference.
][
  然后，测量 `pbrt` 当前方法以及您在几个具有球形光源的场景中的方法的 MSE，使用每像素数千个样本渲染的图像作为参考。
]

#parec[
  How do the results differ if the light is always unoccluded versus if it is sometimes partially occluded? How does the BSDF of scene surfaces affect the results?
][
  如果光线始终未被遮挡与有时部分被遮挡的情况下，结果有何不同？场景表面的 BSDF 如何影响结果？
]

#parec[
  Currently `pbrt` recomputes the partial derivatives $frac(partial upright(bold(p)), partial u)$ and $frac(partial upright(bold(p)), partial v)$ for triangles every time they are needed, even though they are constant for each triangle. Precompute these vectors and analyze the speed/storage trade-off, especially for large triangle meshes.
][
  目前 `pbrt` 每次需要时都会重新计算三角形的偏导数 $frac(partial upright(bold(p)), partial u)$ 和 $frac(partial upright(bold(p)), partial v)$，即使它们对于每个三角形都是恒定的。预先计算这些向量并分析速度/存储权衡，特别是对于大型三角网格。
]

#parec[
  How do the depth complexity of the scene and the size of triangles in the image affect this trade-off?
][
  场景的深度复杂性和图像中三角形的大小如何影响这种权衡？
]

#parec[
  Implement a general polygon primitive that supports an arbitrary number of vertices and convex or concave polygons as a new `Shape` in `pbrt`. You can assume that a valid polygon has been provided and that all the vertices of the polygon lie on the same plane, although you might want to issue a warning when this is not the case.
][
  实现一个支持任意数量顶点和凸或凹多边形的一般多边形原语作为 `pbrt` 中的新 `Shape`。您可以假设提供了一个有效的多边形，并且多边形的所有顶点都位于同一平面上，尽管当情况不是这样时您可能想发出警告。
]

#parec[
  An efficient technique for computing ray–polygon intersections is to find the plane equation for the polygon from its normal and a point on the plane. Then compute the intersection of the ray with that plane and project the intersection point and the polygon vertices to 2D.
][
  一种有效的光线-多边形交叉计算技术是从多边形的法线和平面上的一个点找到平面方程。然后计算光线与该平面的交点，并将交点和多边形顶点投影到二维。
]

#parec[
  You can then apply a 2D point-in-polygon test to determine if the point is inside the polygon. An easy way to do this is to effectively do a 2D ray-tracing computation: intersect the ray with each of the edge segments, and count how many it goes through. If it goes through an odd number of them, the point is inside the polygon and there is an intersection.
][
  然后您可以应用二维点在多边形内测试，以确定该点是否在多边形内。一个简单的方法是有效地进行二维光线追踪计算：与每个边缘段相交，并计算它穿过了多少个。如果它穿过了奇数个，则该点在多边形内，并且存在交点。
]

#parec[
  You may find it helpful to read the article by Haines (1994) that surveys a number of approaches for efficient point-in-polygon tests. Some of the techniques described there may be helpful for optimizing this test.
][
  您可能会发现阅读 Haines（1994）的文章很有帮助，该文章调查了许多有效的点在多边形内测试的方法。那里描述的一些技术可能有助于优化此测试。
]

#parec[
  Furthermore, Section 13.3.3 of Schneider and Eberly (2003) discusses strategies for getting all the corner cases right: for example, when the 2D ray is aligned precisely with an edge or passes through a vertex of the polygon.
][
  此外，Schneider 和 Eberly（2003）的第 13.3.3 节讨论了正确处理所有极端情况的策略：例如，当二维光线与边缘完全对齐或穿过多边形的顶点时。
]

#parec[
  Constructive solid geometry (CSG) is a solid modeling technique where complex shapes are built up by considering the union, intersection, and differences of more primitive shapes.
][
  构造性实体几何（CSG）是一种实体建模技术，其中通过考虑更原始形状的并集、交集和差异来构建复杂形状。
]

#parec[
  For example, a sphere could be used to create pits in a cylinder if a shape was modeled as the difference of a cylinder and set of spheres that partially overlapped it.
][
  例如，如果一个形状被建模为圆柱体和一组部分重叠的球体的差异，则可以使用一个球体在圆柱体中创建凹坑。
]

#parec[
  See Hoffmann (1989) for further information about CSG. Add support for CSG to `pbrt` and render images that demonstrate interesting shapes that can be rendered using CSG.
][
  有关 CSG 的更多信息，请参见 Hoffmann（1989）。在 `pbrt` 中添加对 CSG 的支持，并渲染展示可以使用 CSG 渲染的有趣形状的图像。
]

#parec[
  You may want to read Roth (1982), which first described how ray tracing could be used to render models described by CSG, as well as Amanatides and Mitchell (1990), which discusses accuracy-related issues for CSG ray tracing.
][
  您可能想阅读 Roth（1982），该文首次描述了如何使用光线追踪来渲染由 CSG 描述的模型，以及 Amanatides 和 Mitchell（1990），讨论了 CSG 光线追踪的精度相关问题。
]

#parec[
  #strong[Procedurally described parametric surfaces];: Write a `Shape` that takes a general mathematical expression of the form $f (u , v) arrow.r (x , y , z)$ that describes a parametric surface as a function of $(u , v)$.
][
  #strong[程序描述的参数曲面];：编写一个 `Shape`，接受一个形式为 $f (u , v) arrow.r (x , y , z)$ 的通用数学表达式，该表达式描述了一个参数曲面作为 $(u , v)$ 的函数。
]

#parec[
  Evaluate the given function at a grid of $(u , v)$ positions, and create a bilinear patch mesh that approximates the given surface. Render images of interesting shapes using your new `Shape`.
][
  在 $(u , v)$ 位置的网格上评估给定函数，并创建一个双线性补丁网格来近似给定的曲面。利用您的新 `Shape` 渲染有趣的形状图像。
]

#parec[
  #strong[Adaptive curve refinement];: Adjust the number of levels of recursive refinement used for intersection with `Curve` shapes based on the on-screen area that they cover.
][
  #strong[自适应曲线细化];：根据 `Curve` 形状在屏幕上覆盖的面积调整递归细化的层数。
]

#parec[
  One approach is to take advantage of the `RayDifferential` class, which represents the image space area that a given ray represents. (However, currently, only `Ray`s—not `RayDifferential`s—are passed to the `Shape::Intersect()` method implementation, so you would need to modify other parts of the system to make ray differentials available.)
][
  一个方法是利用 `RayDifferential` 类，该类表示给定光线代表的图像空间面积。（然而，目前只有 `Ray`——而不是 `RayDifferential`——被传递给 `Shape::Intersect()` 方法实现，因此您需要修改系统的其他部分以使光线微分可用。）
]

#parec[
  Alternatively, you could modify the `Camera` to provide information about the projected length of vectors between points in rendering space on the image plane and make the camera available during `Curve` intersection.
][
  或者，您可以修改 `Camera` 以提供有关渲染空间中点之间向量在图像平面上的投影长度的信息，并在 `Curve` 交叉期间使相机可用。
]

#parec[
  Render images that show the benefit of adaptive refinement when the camera is close to curves. Measure performance, varying the camera-to-curves distance.
][
  渲染显示当相机靠近曲线时自适应细化的好处的图像。测量性能，改变相机到曲线的距离。
]

#parec[
  Does performance improve when the camera is far away? How does it change when the camera is close?
][
  当相机远离时，性能是否提高？当相机靠近时会发生什么变化？
]

#parec[
  Implement one of the more efficient ray–curve intersection algorithms described by Reshetov (2017) or by Reshetov and Luebke (2018).
][
  实现 Reshetov（2017）或 Reshetov 和 Luebke（2018）描述的更高效的光线-曲线交叉算法之一。
]

#parec[
  Measure the performance of `pbrt`'s current `Curve` implementation as well as your new one and discuss the results.
][
  测量 `pbrt` 当前 `Curve` 实现的性能以及您的新实现，并讨论结果。
]

#parec[
  Do rendered images match with both approaches? Can you find differences in the intersections returned that lead to changes in images, especially when the camera is close to a curve?
][
  渲染的图像是否与两种方法匹配？您能否找到导致图像变化的交叉返回差异，特别是当相机靠近曲线时？
]

#parec[
  Explain your findings.
][
  解释您的发现。
]

#parec[
  #strong[Ray-tracing point-sampled geometry];: Extending methods for rendering complex models represented as a collection of point samples (Levoy and Whitted 1985; Pfister et al.~2000; Rusinkiewicz and Levoy 2000), Schaufler and Jensen (2000) have described a method for intersecting rays with collections of oriented point samples in space.
][
  #strong[光线追踪点采样几何];：扩展用于渲染表示为点样本集合的复杂模型的方法（Levoy 和 Whitted 1985；Pfister 等，2000；Rusinkiewicz 和 Levoy 2000），Schaufler 和 Jensen（2000）描述了一种与空间中定向点样本集合相交的光线的方法。
]

#parec[
  Their algorithm probabilistically determined that an intersection has occurred when a ray approaches a sufficient local density of point samples and computes a surface normal with a weighted average of the nearby samples.
][
  他们的算法在光线接近足够的点样本局部密度时概率地确定发生了交叉，并通过附近样本的加权平均计算表面法线。
]

#parec[
  Read their paper and extend `pbrt` to support a point-sampled geometry shape. Do any of `pbrt`'s basic interfaces need to be extended or generalized to support a shape like this?
][
  阅读他们的论文并扩展 `pbrt` 以支持点采样几何形状。是否需要扩展或泛化 `pbrt` 的基本接口以支持这样的形状？
]

#parec[
  #strong[Deformation motion blur];: The `TransformedPrimitive` in Section 7.1.2 of Chapter 7 supports animated shapes via transformations of primitives that vary over time.
][
  #strong[变形运动模糊];：第 7 章第 7.1.2 节中的 `TransformedPrimitive` 通过随时间变化的原语变换支持动画形状。
]

#parec[
  However, this type of animation is not general enough to represent a triangle mesh where each vertex has a position given at the start time and another one at the end time.
][
  然而，这种类型的动画不足以表示一个三角网格，其中每个顶点在开始时间和结束时间都有一个位置。
]

#parec[
  (For example, this type of animation description can be used to describe a running character model where different parts of the body are moving in different ways.)
][
  （例如，这种类型的动画描述可用于描述一个奔跑的角色模型，其中身体的不同部分以不同的方式移动。）
]

#parec[
  Implement a more general `Triangle` or `BilinearPatch` shape that supports specifying vertex positions at the start and end of frame and interpolates between them based on the ray time passed to the intersection methods.
][
  实现一个更通用的 `Triangle` 或 `BilinearPatch` 形状，支持在帧开始和结束时指定顶点位置，并根据传递给交叉方法的光线时间在它们之间插值。
]

#parec[
  Be sure to update the bounding routines appropriately.
][
  确保适当地更新边界例程。
]

#parec[
  Meshes with very large amounts of motion may exhibit poor performance due to individual triangles or patches sweeping out large bounding boxes and thus many intersection tests being performed that do not hit the shape.
][
  运动量非常大的网格可能会由于单个三角形或补丁扫出大的边界框，从而导致许多交叉测试被执行但未命中形状而表现不佳。
]

#parec[
  Can you come up with approaches that could be used to reduce the impact of this problem?
][
  您能否提出可以用来减少此问题影响的方法？
]

#parec[
  #strong[Implicit functions];: Just as implicit definitions of the quadric shapes are a useful starting point for deriving ray-intersection algorithms, more complex implicit functions can also be used to define interesting shapes.
][
  #strong[隐函数];：正如二次曲面的隐式定义是推导光线交叉算法的有用起点，更复杂的隐函数也可以用于定义有趣的形状。
]

#parec[
  In particular, difficult-to-model organic shapes, water drops, and so on can be well represented by implicit surfaces.
][
  特别是，难以建模的有机形状、水滴等可以通过隐式曲面很好地表示。
]

#parec[
  Blinn (1982a) introduced the idea of directly rendering implicit surfaces, and Wyvill and Wyvill (1989) gave a basis function for implicit surfaces with a number of advantages compared to Blinn's.
][
  Blinn（1982a）引入了直接渲染隐式曲面的想法，而 Wyvill 和 Wyvill（1989）给出了一个具有许多优点的隐式曲面的基函数，与 Blinn 的相比。
]

#parec[
  Implement a method for finding ray intersections with implicit surfaces and add it to `pbrt`.
][
  实现一种寻找隐式曲面光线交叉的方法并将其添加到 `pbrt`。
]

#parec[
  You may wish to read papers by Kalra and Barr (1989), Hart (1996), and Sabbadin and Droske (2021) for methods for ray tracing them.
][
  您可能希望阅读 Kalra 和 Barr（1989）、Hart（1996）以及 Sabbadin 和 Droske（2021）的论文，以获取光线追踪它们的方法。
]

#parec[
  Mitchell's algorithm for robust ray intersections with implicit surfaces using interval arithmetic gives another effective method for finding these intersections (Mitchell 1990), and more recently Knoll et al.~(2009) described refinements to this idea.
][
  Mitchell 的算法使用区间算术对隐式曲面进行稳健光线交叉提供了另一种有效的方法来找到这些交叉（Mitchell 1990），最近 Knoll 等（2009）描述了对此想法的改进。
]

#parec[
  You may find an approach along these lines easier to implement than the others. See Moore's book on interval arithmetic as needed for reference (Moore 1966).
][
  您可能会发现采用这些思路的方法比其他方法更容易实现。根据需要参阅 Moore 的区间算术书籍（Moore 1966）。
]

#parec[
  #strong[L-systems];: A very successful technique for procedurally modeling plants was introduced to graphics by Alvy Ray Smith (1984), who applied #strong[Lindenmayer systems] (L-systems) to model branching plant structures.
][
  #strong[L 系统];：一种非常成功的程序化建模植物的技术是由 Alvy Ray Smith（1984）引入到图形学中，他应用了 #strong[Lindenmayer 系统];（L 系统）来建模分支植物结构。
]

#parec[
  Prusinkiewicz and collaborators have generalized this approach to encompass a much wider variety of types of plants and effects that determine their appearance (Prusinkiewicz 1986; Prusinkiewicz et al.~1994; Deussen et al.~1998; Prusinkiewicz et al.~2001).
][
  Prusinkiewicz 和合作者将这种方法推广到涵盖更广泛的植物类型和决定其外观的效果（Prusinkiewicz 1986；Prusinkiewicz 等，1994；Deussen 等，1998；Prusinkiewicz 等，2001）。
]

#parec[
  L-systems describe the branching structure of these types of shapes via a grammar. The grammar can be evaluated to form expressions that describe a topological representation of a plant, which can then be translated into a geometric representation.
][
  L 系统通过语法描述这些类型形状的分支结构。语法可以被评估以形成描述植物的拓扑表示的表达式，然后可以将其转换为几何表示。
]

#parec[
  Add an L-system primitive to `pbrt` that takes a grammar as input and evaluates it to create the shape it describes.
][
  在 `pbrt` 中添加一个 L 系统原语，该原语接受语法作为输入并评估它以创建它描述的形状。
]

#parec[
  Given an arbitrary point $(x , y , z)$, what bound on the error from applying a scale transformation of $(2 , 1 , 4)$ is given by Equation (6.30)?
][
  给定任意点 $(x , y , z)$，应用比例变换 $(2 , 1 , 4)$ 所产生的误差界由方程 (6.30) 给出是多少？
]

#parec[
  How much error is actually introduced?
][
  实际引入的误差是多少？
]

#parec[
  The quadric shapes all use the `Interval` class for their intersection tests in order to be able to bound the error in the computed $t$ value so that intersections behind the ray origin are not incorrectly reported as intersections.
][
  所有二次曲面形状都使用 `Interval` 类进行交叉测试，以便能够在计算的 $t$ 值中界定误差，以便不错误地报告光线起点后的交叉。
]

#parec[
  First, measure the performance difference when using regular `Float`s for one or more quadrics when rendering a scene that includes those shapes.
][
  首先，测量在渲染包含这些形状的场景时使用常规 `Float` 的性能差异。
]

#parec[
  Next, manually derive conservative error bounds for $t$ values computed by those shapes as was done for triangles in Section 6.8.7. Implement your method.
][
  接下来，手动推导由这些形状计算的 $t$ 值的保守误差界，如第 6.8.7 节中对三角形所做的那样。实现您的方法。
]

#parec[
  You may find it useful to use the `Interval` class to empirically test your derivation's correctness. Measure the performance difference with your implementation.
][
  您可能会发现使用 `Interval` 类来经验性地测试您的推导的正确性是有用的。测量您的实现的性能差异。
]

#parec[
  One detail thwarts the watertightness of the current `Triangle` shape implementation: the translation and shearing of triangle vertices introduces round-off error, which must be accounted for in the extent of triangles' bounding boxes; see Section 3.3 of Woop et al.~(2013) for discussion (and a solution).
][
  当前 `Triangle` 形状实现的水密性被一个细节所阻碍：三角形顶点的平移和剪切引入了舍入误差，必须在三角形边界框的范围内考虑；参见 Woop 等（2013）的第 3.3 节以了解讨论（和解决方案）。
]

#parec[
  Modify `pbrt` to incorporate a solution to this shortcoming. Can you find scenes where small image errors are eliminated thanks to your fix?
][
  修改 `pbrt` 以纳入对此缺点的解决方案。您能否找到因您的修复而消除小图像错误的场景？
]


