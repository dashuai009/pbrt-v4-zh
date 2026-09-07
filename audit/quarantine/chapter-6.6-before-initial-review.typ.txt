#import "../template.typ": parec, ez_caption

== Billinear Patches
<billinear-patches>

!!!! 缺东西


#parec[
  It is useful to have a shape defined by four vertices. One option would be a planar quadrilateral, though not requiring all four vertices to be coplanar is preferable, as it is less restrictive. Such a shape is the bilinear patch, which is a parametric surface defined by four vertices $p_(0 , 0)$, $p_(1 , 0)$, $p_(0 , 1)$, and $p_(1 , 1)$. Each vertex gives the position associated with a corner of the parametric $(u , v)$ domain $[0 , 1]^2$ and points on the surface are defined via bilinear interpolation:
][
  定义一个由四个顶点组成的形状是很有用的。一个选项是平面四边形，但不要求四个顶点共面更可取，因为这限制较少。这样的形状是双线性片，它是由四个顶点 $p_(0 , 0)$, $p_(1 , 0)$, $p_(0 , 1)$ 和 $p_(1 , 1)$ 定义的参数化曲面。每个顶点提供与参数化 $(u , v)$ 域 $[0 , 1]^2$ 的一个角相关的位置，曲面上的点通过双线性插值计算出其位置：
]

$ f (u , v) = (1 - u) (1 - v) p_(0 , 0) + u (1 - v) p_(1 , 0) + (1 - u) v p_(0 , 1) + u v p_(1 , 1) $


#parec[
  The bilinear patch is a #emph[doubly ruled surface];: there are two straight lines through every point on it. (This can be seen by considering a parametric point on the surface $(u , v)$ and then fixing either of $u$ and $v$ and considering the function that results: it is linear.)
][
  双线性片是一个#emph[双重直纹面];：在其上的每个点通过两条直线。（这可以通过考虑曲面上的一个参数点 $(u , v)$ 然后固定 $u$ 或 $v$ 来看出，结果的函数是线性的。）
]

#parec[
  Not only can bilinear patches be used to represent planar quadrilaterals, but they can also represent simple curved surfaces. They are a useful target for converting higher-order parametric surfaces to simpler shapes that are amenable to direct ray intersection. Figure #link("<fig:two-blps>")[6.22] shows two bilinear patches.
][
  双线性片不仅可以用来表示平面四边形，还可以表示简单的曲面。它们是将高阶参数化曲面转换为适合直接光线交叉的简单形状的有用目标。图 #link("<fig:two-blps>")[6.22] 显示了两个双线性片。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/blps.png"),
    caption: [
      Figure 6.22: Two Bilinear Patches. The bilinear patch is defined by
      four vertices that are not necessarily planar. It is able to
      represent a variety of simple curved surfaces.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/blps.png"),
    caption: [
      图 6.22:
      两个双线性片。双线性片由四个不一定共面的顶点定义。它能够表示各种简单的曲面。
    ],
  )
]

#parec[
  pbrt allows the specification of bilinear patch meshes for the same reasons that triangle meshes can be specified: to allow per-vertex attributes like position and surface normal to be shared by multiple patches and to allow mesh-wide properties to be stored just once. To this end, #link("<BilinearPatchMesh>")[BilinearPatchMesh] plays the equivalent role to the #link("../Shapes/Triangle_Meshes.html#TriangleMesh")[TriangleMesh];.
][
  pbrt 允许指定双线性片网格，原因与可以指定三角形网格相同：允许每个顶点的属性（如位置和表面法线）由多个片共享，并且允许网格范围的属性仅存储一次。为此，#link("<BilinearPatchMesh>")[BilinearPatchMesh] 扮演了与 #link("../Shapes/Triangle_Meshes.html#TriangleMesh")[TriangleMesh] 等效的角色。
]

#parec[
  We will skip past the #link("<BilinearPatchMesh>")[BilinearPatchMesh] constructor, as it mirrors the #link("../Shapes/Triangle_Meshes.html#TriangleMesh")[TriangleMesh];'s, transforming the positions and normals to rendering space and using the #link("../Shapes/Triangle_Meshes.html#BufferCache")[BufferCache] to avoid storing redundant buffers in memory.
][
  我们将跳过 #link("<BilinearPatchMesh>")[BilinearPatchMesh] 构造函数，因为它反映了 #link("../Shapes/Triangle_Meshes.html#TriangleMesh")[TriangleMesh] 的构造函数，将位置和法线转换为渲染空间，并使用 #link("../Shapes/Triangle_Meshes.html#BufferCache")[BufferCache] 避免在内存中存储冗余缓冲区。
]

#parec[
  The BilinearPatch class implements the #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface and represents a single patch in a bilinear patch mesh.
][
  BilinearPatch 类实现了 #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape] 接口，并表示双线性片网格中的单个片。
]

#parec[
  Also similar to triangles, each BilinearPatch stores the index of the mesh that it is a part of as well as its own index in the mesh's patches.
][
  类似于三角形，每个 BilinearPatch 都存储其所属网格的索引及其在网格片中的索引。
]

#parec[
  The GetMesh() method makes it easy for a #link("<BilinearPatch>")[BilinearPatch] to get the pointer to its associated mesh.
][
  GetMesh() 方法使得 #link("<BilinearPatch>")[BilinearPatch] 可以轻松获取其关联网格的指针。
]

#parec[
  There is a subtlety that comes with the use of a vector to store the meshes. pbrt's scene initialization code in Appendix #link("../Processing_the_Scene_Description.html#chap:API")[C] does its best to parallelize its work, which includes the parallelization of reading binary files that encode meshes from disk.
][
  使用 vector 存储网格有一个微妙之处。pbrt 的场景初始化代码在附录 #link("../Processing_the_Scene_Description.html#chap:API")[C] 中尽力并行化其工作，其中包括并行化从磁盘读取编码网格的二进制文件。
]

#parec[
  A mutex is used to protect adding meshes to this vector, though as this vector grows, it is periodically reallocated to make more space.
][
  使用互斥锁来保护将网格添加到此向量中，但随着此向量的增长，它会定期重新分配以腾出更多空间。
]

#parec[
  A consequence is that the #link("<BilinearPatch>")[BilinearPatch] constructor must not call the GetMesh() method to get its BilinearPatchMesh \*, since GetMesh() accesses allMeshes without mutual exclusion.
][
  因此，#link("<BilinearPatch>")[BilinearPatch] 构造函数不能调用 GetMesh() 方法来获取其 BilinearPatchMesh \*，因为 GetMesh() 在没有互斥排除的情况下访问 allMeshes。
]

#parec[
  Thus, the mesh is passed to the constructor as a parameter above.
][
  因此，网格作为参数传递给构造函数。
]

#parec[
  The area of a parametric surface defined over $[0 , 1]^2$ is given by the integral
][
  定义在 $[0 , 1]^2$ 上的参数化曲面的面积由积分给出
]


#parec[
  The partial derivatives of a bilinear patch are easily derived. They are:
][
  双线性片 (BilinearPatch) 的偏导数很容易推导出来。它们是：
]

$
  frac(partial upright(bold(p)), partial u) & = (1 - v) (upright(bold(p))_(1 , 0) - upright(bold(p))_(0 , 0)) + v (
    upright(bold(p))_(1 , 1) - upright(bold(p))_(0 , 1)
  )\
  frac(partial upright(bold(p)), partial v) & = (1 - u) (upright(bold(p))_(0 , 1) - upright(bold(p))_(0 , 0)) + u (
    upright(bold(p))_(1 , 1) - upright(bold(p))_(1 , 0)
  ) .
$



#parec[
  However, it is not generally possible to evaluate the area integral from Equation (6.12) in closed form with these partial derivatives. Therefore, the BilinearPatch constructor caches the patch's surface area in a member variable, using numerical integration to compute its value if necessary.
][
  然而，通常情况下无法用这些偏导数以封闭形式计算方程 (6.12) 中的面积积分。因此，BilinearPatch 构造函数会将片的表面积缓存到一个成员变量中，如果有必要，使用数值积分来计算其值。
]

#parec[
  Because bilinear patches are often used to represent rectangles, the constructor checks for that case and takes the product of the lengths of the sides of the rectangle to compute the area when appropriate. In the general case, the fragment \<\> uses a Riemann sum evaluated at $3 times 3$ points to approximate Equation (6.12). We do not include that code fragment here.
][
  因为双线性片常用于表示矩形，构造函数会检查这种情况，并在适当时通过计算矩形边长的乘积来计算面积。在一般情况下，片段 \<\> 使用在 $3 times 3$ 点处评估的黎曼和来近似方程 (6.12)。我们在此不包括该代码片段。
]

#parec[
  This fragment, which loads the four vertices of a patch into local variables, will be reused in many of the following methods.
][
  这个片段将一个片的四个顶点加载到局部变量中，将在接下来的许多方法中重复使用。
]

#parec[
  In addition to the surface area computation, there will be a number of additional cases where we will find it useful to use specialized algorithms if a BilinearPatch is a rectangle. Therefore, this check is encapsulated in the IsRectangle() method.
][
  除了表面积计算之外，还有许多其他情况，我们会发现如果 BilinearPatch 是一个矩形，使用专门的算法会很有用。因此，这个检查被封装在 IsRectangle() 方法中。
]

#parec[
  It first tests to see if any two neighboring vertices are coincident, in which case the patch is certainly not a rectangle. This check is important to perform first, since the following ones would otherwise end up trying to perform invalid operations like normalizing degenerate vectors in that case.
][
  它首先测试是否有两个相邻的顶点重合，在这种情况下，片肯定不是一个矩形。这个检查很重要，因为否则接下来的检查将尝试执行无效操作，比如在这种情况下规范化退化向量。
]

#parec[
  If the four vertices are not coplanar, then they do not form a rectangle. We can check this case by computing the surface normal of the plane formed by three of the vertices and then testing if the vector from one of those three to the fourth vertex is not (nearly) perpendicular to the plane normal.
][
  如果四个顶点不共面，那么它们就不形成矩形。我们可以通过计算由三个顶点形成的平面的表面法线，然后测试从这三个顶点之一到第四个顶点的向量是否与平面法线不（几乎）垂直来检查这种情况。
]

#parec[
  Four coplanar vertices form a rectangle if they all have the same distance from the average of their positions. The implementation here computes the squared distance to save the square root operations and then tests the relative error with respect to the first squared distance. Because the test is based on relative error, it is not sensitive to the absolute size of the patch; scaling all the vertex positions does not affect it.
][
  如果四个共面顶点与其位置的平均值具有相同的距离，则它们形成一个矩形。这里的实现计算平方距离以节省平方根操作，然后测试相对于第一个平方距离的相对误差。由于测试是基于相对误差的，因此它对片的绝对大小不敏感；缩放所有顶点位置不会影响它。
]

#parec[
  With the area cached, implementation of the Area() method is trivial.
][
  有了缓存的面积，实现 Area() 方法就很简单了。
]

#parec[
  The bounds of a bilinear patch are given by the bounding box that bounds its four corner vertices. As with Triangles, the mesh vertices are already in rendering space, so no further transformation is necessary here.
][
  双线性片的边界由其四个角顶点围成的边界框给出。与 三角形 类似，网格顶点已经在渲染空间中，因此这里不需要进一步的变换。
]

#parec[
  Although a planar patch has a single surface normal, the surface normal of a nonplanar patch varies across its surface.
][
  虽然平面片有一个单一的表面法线，但非平面片的表面法线在其表面上变化。
]

#parec[
  If the bilinear patch is actually a triangle, the \<\<If patch is a triangle, return bounds for single surface normal\>\> fragment evaluates its surface normal and returns the corresponding DirectionCone. We have not included that straightforward fragment here.
][
  如果双线性片实际上是一个三角形，\<\<如果片是一个三角形，返回单一表面法线的边界\>\> 片段会评估其表面法线并返回相应的 DirectionCone。我们没有在此包括该简单片段。
]

#parec[
  Otherwise, the normals are computed at the four corners of the patch. The following fragment computes the normal at the (0, 0) parametric position. It is particularly easy to evaluate the partial derivatives at the corners; they work out to be the differences with the adjacent vertices in u and v. Some care is necessary with the orientation of the normals, however.
][
  否则，法线将在片的四个角计算。以下片段计算在 (0, 0) 参数位置的法线。特别容易在角处评估偏导数；它们的结果是与 u 和 v 相邻顶点的差异。然而，法线的方向需要特别注意。
]

#parec[
  As with triangle meshes, if per-vertex shading normals were specified, they determine which side of the surface the geometric normal lies on. Otherwise, the normal may need to be flipped, depending on the user-specified orientation and the handedness of the rendering-to-object-space transformation.
][
  与三角形网格一样，如果指定了每顶点的着色法线，它们决定了几何法线所在的表面一侧。否则，法线可能需要翻转，具体取决于用户指定的方向和渲染到对象空间变换的手性。
]

#parec[
  Normals at the other three vertices are computed in an equivalent manner, so the fragment that handles the rest is not included here.
][
  其他三个顶点的法线以类似的方式计算，因此处理其余部分的片段未在此处包括。
]

#parec[
  A bounding cone for the normals is found by taking their average and then finding the cosine of the maximum angle that any of them makes with their average. Although this does not necessarily give an optimal bound, it usually works well in practice.
][
  法线的边界锥体通过取其平均值，然后找到它们与平均值形成的最大角度的余弦来确定。虽然这不一定能给出最佳边界，但在实践中通常效果很好。
]

#parec[
  (See the "Further Reading" section in Chapter 3 for more information on this topic.)
][
  （有关此主题的更多信息，请参阅第 3 章的“进一步阅读”部分。）
]

#parec[
  If the bilinear patch is actually a triangle, the \<\<If patch is a triangle, return bounds for single surface normal\>\> fragment evaluates its surface normal and returns the corresponding DirectionCone. We have not included that straightforward fragment here.
][
  如果双线性片实际上是一个三角形，\<\<如果片是一个三角形，返回单一表面法线的边界\>\> 片段会评估其表面法线并返回相应的 DirectionCone。我们没有在此包括该简单片段。
]

#parec[
  Otherwise, the normals are computed at the four corners of the patch. The following fragment computes the normal at the (0, 0) parametric position. It is particularly easy to evaluate the partial derivatives at the corners; they work out to be the differences with the adjacent vertices in u and v. Some care is necessary with the orientation of the normals, however.
][
  否则，法线将在片的四个角计算。以下片段计算在 (0, 0) 参数位置的法线。特别容易在角处评估偏导数；它们的结果是与 u 和 v 相邻顶点的差异。然而，法线的方向需要特别注意。
]

#parec[
  As with triangle meshes, if per-vertex shading normals were specified, they determine which side of the surface the geometric normal lies on. Otherwise, the normal may need to be flipped, depending on the user-specified orientation and the handedness of the rendering-to-object-space transformation.
][
  与三角形网格一样，如果指定了每顶点的着色法线，它们决定了几何法线所在的表面一侧。否则，法线可能需要翻转，具体取决于用户指定的方向和渲染到对象空间变换的手性。
]

#parec[
  Normals at the other three vertices are computed in an equivalent manner, so the fragment that handles the rest is not included here.
][
  其他三个顶点的法线以类似的方式计算，因此处理其余部分的片段未在此处包括。
]

#parec[
  A bounding cone for the normals is found by taking their average and then finding the cosine of the maximum angle that any of them makes with their average. Although this does not necessarily give an optimal bound, it usually works well in practice.
][
  法线的边界锥体通过取其平均值，然后找到它们与平均值形成的最大角度的余弦来确定。虽然这不一定能给出最佳边界，但在实践中通常效果很好。
]

#parec[
  (See the "Further Reading" section in Chapter 3 for more information on this topic.)
][
  （有关此主题的更多信息，请参阅第 3 章的“进一步阅读”部分。）
]


=== Intersection Tests
<intersection-tests>
#parec[
  Unlike triangles (but like spheres and cylinders), a ray may intersect a bilinear patch twice, in which case the closest of the two intersections is returned. An example is shown in Figure 6.23.
][
  与三角形不同（但与球体和圆柱体相似），射线可能与双线性补丁相交两次，在这种情况下返回最近的交点。图6.23中显示了一个示例。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f23.svg"),
    caption: [
      Figure 6.23: Ray–Bilinear Patch Intersections. Rays may intersect a
      bilinear patch either once or two times.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f23.svg"),
    caption: [
      图6.23: 射线–双线性补丁相交。射线可能与双线性补丁相交一次或两次。
    ],
  )
]

#parec[
  As with triangles, it is useful to have a stand-alone ray–bilinear patch intersection test function rather than only providing this functionality through an instance of a `BilinearPatch` object. Rather than being based on computing $t$ values along the ray and then finding the $(u , v)$ coordinates for any found intersections, the algorithm here first determines the parametric $u$ coordinates of any intersections. Only if any are found within $[0 , 1]$ are the corresponding $v$ and $t$ values computed to find the full intersection information.
][
  与三角形一样，拥有一个独立的射线–双线性补丁相交测试函数是有用的，而不仅仅通过一个`BilinearPatch`对象的实例提供这种功能。而不是通过沿射线计算 $t$ 值并找到交点的 $(u , v)$ 坐标，该算法首先确定任何交点的参数 $u$ 坐标。只有在 $u$ 值位于 $[0 , 1]$ 范围内时，才计算相应的 $v$ 和 $t$ 值以获取完整的交点信息。
]

```cpp
pstd::optional<BilinearIntersection>
IntersectBilinearPatch(const Ray &ray, Float tMax, Point3f p00, Point3f p10,
                       Point3f p01, Point3f p11) {
    // Find quadratic coefficients for distance from ray to u iso-lines
    Float a = Dot(Cross(p10 - p00, p01 - p11), ray.d);
    Float c = Dot(Cross(p00 - ray.o, ray.d), p01 - p00);
    Float b = Dot(Cross(p10 - ray.o, ray.d), p11 - p10) - (a + c);
    // Solve quadratic for bilinear patch u intersection
    Float u1, u2;
    if (!Quadratic(a, b, c, &u1, &u2))
        return {};
    // Find epsilon eps to ensure that candidate t is greater than zero
    Float eps = gamma(10) *
           (MaxComponentValue(Abs(ray.o)) + MaxComponentValue(Abs(ray.d)) +
            MaxComponentValue(Abs(p00))   + MaxComponentValue(Abs(p10))   +
            MaxComponentValue(Abs(p01))   + MaxComponentValue(Abs(p11)));
    // Compute v and t for the first u intersection
    Float t = tMax, u, v;
    if (0 <= u1 && u1 <= 1) {
        // Precompute common terms for v and t computation
        Point3f uo = Lerp(u1, p00, p10);
        Vector3f ud = Lerp(u1, p01, p11) - uo;
        Vector3f deltao = uo - ray.o;
        Vector3f perp = Cross(ray.d, ud);
        Float p2 = LengthSquared(perp);
        // Compute matrix determinants for v and t numerators
        Float v1 = Determinant(SquareMatrix<3>(deltao.x, ray.d.x, perp.x,
                                                     deltao.y, ray.d.y, perp.y,
                                                     deltao.z, ray.d.z, perp.z));
        Float t1 = Determinant(SquareMatrix<3>(deltao.x, ud.x, perp.x,
                                                     deltao.y, ud.y, perp.y,
                                                     deltao.z, ud.z, perp.z));
        // Set u, v, and t if intersection is valid
        if (t1 > p2 * eps && 0 <= v1 && v1 <= p2) {
            u = u1;
            v = v1 / p2;
            t = t1 / p2;
        }
    }
    // Compute v and t for the second u intersection
    if (0 <= u2 && u2 <= 1 && u2 != u1) {
        Point3f uo = Lerp(u2, p00, p10);
        Vector3f ud = Lerp(u2, p01, p11) - uo;
        Vector3f deltao = uo - ray.o;
        Vector3f perp = Cross(ray.d, ud);
        Float p2 = LengthSquared(perp);
        Float v2 = Determinant(SquareMatrix<3>(deltao.x, ray.d.x, perp.x,
                                      deltao.y, ray.d.y, perp.y,
                                      deltao.z, ray.d.z, perp.z));
        Float t2 = Determinant(SquareMatrix<3>(deltao.x, ud.x, perp.x,
                                      deltao.y, ud.y, perp.y,
                                      deltao.z, ud.z, perp.z));
        t2 /= p2;
        if (0 <= v2 && v2 <= p2 && t > t2 && t2 > eps) {
            t = t2;
            u = u2;
            v = v2 / p2;
        }
    }
    // Check intersection t against tMax and possibly return intersection
    if (t >= tMax)
        return {};
    return BilinearIntersection{{u, v}, t};
}
```


#parec[
  Going back to the definition of the bilinear surface, Equation (6.11), we can see that if we fix one of $u$ or $v$, then we are left with an equation that defines a line. For example, with $u$ fixed, we have

  $ f_u (v) = (1 - v) p_(u , 0) + v p_(u , 1) , $
][
  回到双线性曲面的定义，方程(6.11)，我们可以看到如果固定 $u$ 或 $v$ 中的一个，那么我们剩下的就是定义一条线的方程。例如，固定 $u$，我们有

  $ f_u (v) = (1 - v) p_(u , 0) + v p_(u , 1) , $
]

#parec[
  with

  $ p_(u , 0) & = (1 - u) p_(0 , 0) + u p_(1 , 0) med p_(u , 1) & = (1 - u) p_(0 , 1) + u p_(1 , 1) . $ 

  (See Figure 6.24.)
][
  其中

  $ p_(u , 0) & = (1 - u) p_(0 , 0) + u p_(1 , 0) med p_(u , 1) & = (1 - u) p_(0 , 1) + u p_(1 , 1) . $ 

  （见图6.24。）
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f24.svg"),
    caption: [
      Figure 6.24: Fixing the $u$ parameter of a bilinear patch gives a
      linear function between two opposite edges of the patch.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f24.svg"),
    caption: [
      图6.24: 固定双线性补丁的$u$参数给出了补丁两个对边之间的线性函数。
    ],
  )
]

#parec[
  The first step of the intersection test considers the set of all such lines defined by the patch's vertices. For any intersection, the minimum distance from a point along the ray to a point along one of these lines will be zero. Therefore, we start with the task of trying to find $u$ values that give lines with zero distance to a point on the ray.
][
  相交测试的第一步考虑了由补丁的顶点定义的所有此类线的集合。对于任何相交，从射线上的一点到这些线之一上的一点的最小距离将为零。因此，我们首先尝试找到使射线上的点与这些线的距离为零的 $u$ 值。
]

#parec[
  Given two infinite and non-parallel lines, one defined by the two points $p_a$ and $p_b$ and the other defined by $p_c$ and $p_d$, the minimum distance between them can be found by determining the pair of parallel planes that each contain one of the lines and then finding the distance between them. (See Figure 6.25.)
][
  给定两条无限且不平行的线，一条由两点 $p_a$ 和 $p_b$ 定义，另一条由 $p_c$ 和 $p_d$ 定义，它们之间的最小距离可以通过确定每条线包含的平行平面对，然后找到它们之间的距离来找到。（见图6.25。）
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f25.svg"),
    caption: [
      Figure 6.25: The minimum distance between two lines can be computed
      by finding two parallel planes that contain each line and then
      computing the distance between them.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f25.svg"),
    caption: [
      图6.25:
      两条线之间的最小距离可以通过找到包含每条线的两平行平面并计算它们之间的距离来计算。
    ],
  )
]

#parec[
  To find the coefficients of those plane equations, we start by taking the cross product $(p_b - p_a) times (p_d - p_c)$. This gives a vector that is perpendicular to both lines and provides the first three coefficients of the plane equation $a x + b y + c z + d = 0$. In turn, the $d_(a b)$ and $d_(c d)$ coefficients can be found for each line's plane by substituting a point along the respective line into the plane equation and solving for $d$. Because the planes are parallel, the distance between them is then…
][
  为了找到这些平面方程的系数，我们首先取叉积 $(p_b - p_a) times (p_d - p_c)$。这给出了一个垂直于两条线的向量，并提供了平面方程 $a x + b y + c z + d = 0$ 的前三个系数。接下来，通过将沿各自线的一点代入平面方程并求解 $d$，可以找到每条线的平面系数 $d_(a b)$ 和 $d_(c d)$。由于平面是平行的，它们之间的距离是…
]


#parec[
  StartFraction StartAbsoluteValue d Subscript normal a normal b Baseline minus d Subscript normal c normal d Baseline EndAbsoluteValue Over StartRoot a squared plus b squared plus c squared EndRoot EndFraction.
][
  分数 StartAbsoluteValue d 下标 normal a normal b Baseline 减去 d 下标 normal c normal d Baseline EndAbsoluteValue Over 平方根 a squared 加上 b squared 加上 c squared EndRoot EndFraction。
]

#parec[
  In the case of ray–bilinear patch intersection, one line corresponds to the ray and the other to a line from the family of lines given by $f_u$.
][
  在射线与双线性贴片相交的情况下，一条线对应于射线，另一条线对应于由 $f_u$ 给出的线族中的一条线。
]

#parec[
  Given a ray and the bilinear patch vertices, we have $p_a = o$, the ray's origin, and $p_b$ can be set as the point along the ray $p_b = o + upright(bold(d))$. Then, $p_c$ and $p_d$ can be set as $p_c = p_(u , 0)$ and $p_d = p_(u , 1)$ from Equation (6.14). After taking the cross product to find the plane coefficients, finding each $d$ value, and simplifying, we can find that $d_(r a y) - d_u$ is a quadratic equation in $u$. (That it is quadratic is reassuring, since a ray can intersect a bilinear patch up to two times.)
][
  给定射线和双线性贴片的顶点，我们有 $p_a = o$，即射线的起点， $p_b$ 可以设置为沿射线的点 $p_b = o + upright(bold(d))$。然后， $p_c$ 和 $p_d$ 可以根据方程 (6.14) 设置为 $p_c = p_(u , 0)$ 和 $p_d = p_(u , 1)$。在求出平面系数、计算每个 $d$ 值并简化后，我们可以发现 $d_(r a y) - d_u$ 是 $u$ 的二次方程。这一点令人放心，因为射线最多可以与双线性贴片相交两次。
]

#parec[
  Because we only care about finding zeros of the distance function, we can neglect the denominator of Equation (6.15). After equating the difference $d_(r a y) - d_u$ to 0, collecting terms and simplifying, we end up with the following code to compute the quadratic coefficients.†
][
  因为我们只关心找到距离函数的零点，所以可以忽略方程 (6.15) 的分母。在将差值 $d_(r a y) - d_u$ 等于 0 后，收集项并简化，我们得到以下代码来计算二次系数。†
]

#parec[
  Find quadratic coefficients for distance from ray to $u$ iso-lines =
][
  找到从射线到 $u$ 等值线的距离的二次系数 =
]

#parec[
  Float a = Dot(Cross(p10 - p00, p01 - p11), ray.d); Float c = Dot(Cross(p00 - ray.o, ray.d), p01 - p00); Float b = Dot(Cross(p10 - ray.o, ray.d), p11 - p10) - (a + c);
][
  ```cpp
  Float a = Dot(Cross(p10 - p00, p01 - p11), ray.d);
  Float c = Dot(Cross(p00 - ray.o, ray.d), p01 - p00);
  Float b = Dot(Cross(p10 - ray.o, ray.d), p11 - p10) - (a + c);
  ```
]

#parec[
  The $u$ values where the ray intersects the patch are given by the solution to the corresponding quadratic equation. If there are no real solutions, then there is no intersection and the function returns.
][
  射线与贴片相交的 $u$ 值由相应二次方程的解给出。如果没有实数解，则没有相交，函数返回。
]

#parec[
  Solve quadratic for bilinear patch $u$ intersection =
][
  求解双线性贴片 $u$ 相交的二次方程 =
]

#parec[
  Float u1, u2; if (!Quadratic(a, b, c, &u1, &u2)) return {};
][
  ```cpp
  Float u1, u2;
  if (!Quadratic(a, b, c, &u1, &u2))
      return {};
  ```
]

#parec[
  The two $u$ values are handled in turn. The first step is to check whether each is between 0 and 1. If not, it does not represent a valid intersection in the patch's parametric domain. Otherwise, the $v$ and $t$ values for the intersection point are computed.
][
  两个 $u$ 值分别处理。第一步是检查每个值是否在 0 和 1 之间。如果不是，则它不代表贴片参数域中的有效相交。否则，计算相交点的 $v$ 和 $t$ 值。
]

#parec[
  Compute $v$ and $t$ for the first $u$ intersection =
][
  计算第一个 $u$ 相交的 $v$ 和 $t$ =
]

#parec[
  Float t = tMax, u, v; if (0 \<= u1 && u1 \<= 1) { \/\/ Precompute common terms for v and t computation Point3f uo = Lerp(u1, p00, p10); Vector3f ud = Lerp(u1, p01, p11) - uo; Vector3f deltao = uo - ray.o; Vector3f perp = Cross(ray.d, ud); Float p2 = LengthSquared(perp); \/\/ Compute matrix determinants for v and t numerators Float v1 = Determinant(SquareMatrix\<3\>(deltao.x, ray.d.x, perp.x, deltao.y, ray.d.y, perp.y, deltao.z, ray.d.z, perp.z)); Float t1 = Determinant(SquareMatrix\<3\>(deltao.x, ud.x, perp.x, deltao.y, ud.y, perp.y, deltao.z, ud.z, perp.z)); \/\/ Set u, v, and t if intersection is valid if (t1 \> p2 \* eps && 0 \<= v1 && v1 \<= p2) { u = u1; v = v1 \/ p2; t = t1 / p2; }}
][
  ```cpp
  Float t = tMax, u, v;
  if (0 <= u1 && u1 <= 1) {
      // 预计算用于 v 和 t 计算的常用项
      Point3f uo = Lerp(u1, p00, p10);
      Vector3f ud = Lerp(u1, p01, p11) - uo;
      Vector3f deltao = uo - ray.o;
      Vector3f perp = Cross(ray.d, ud);
      Float p2 = LengthSquared(perp);
      // 计算 v 和 t 分子的矩阵行列式
      Float v1 = Determinant(SquareMatrix<3>(deltao.x, ray.d.x, perp.x,
                                              deltao.y, ray.d.y, perp.y,
                                              deltao.z, ray.d.z, perp.z));
      Float t1 = Determinant(SquareMatrix<3>(deltao.x, ud.x, perp.x,
                                              deltao.y, ud.y, perp.y,
                                              deltao.z, ud.z, perp.z));
      // 如果相交有效，则设置 u, v 和 t
      if (t1 > p2 * eps && 0 <= v1 && v1 <= p2) {
          u = u1;
          v = v1 / p2;
          t = t1 / p2;
      }
  }
  ```
]

#parec[
  One way to compute the $v$ and $t$ values is to find the parametric values along the ray and the line $f_u$ where the distance between them is minimized. Although this distance should be zero since we have determined that there is an intersection between the ray and $f_u$, there may be some round-off error in the computed $u$ value. Thus, formulating this computation in terms of minimizing that distance is a reasonable way to make the most of the values at hand.
][
  计算 $v$ 和 $t$ 值的一种方法是找到射线和线 $f_u$ 上参数值，使它们之间的距离最小化。尽管由于我们已经确定射线与 $f_u$ 相交，这个距离应该为零，但由于舍入误差，计算的 $u$ 值可能存在一些偏差。因此，以最小化该距离的方式来制定此计算是充分利用现有值的合理方法。
]

#parec[
  With $o$ the ray's origin and $upright(bold(d))$ its direction, the parameter values where the distances are minimized are given by …
][
  以 $o$ 为射线的起点， $upright(bold(d))$ 为其方向，距离最小化的参数值由…
]


$
  t = frac(d e t (f_u (0) - o , f_u (1) - f_u (0) , upright(bold(d)) times (f_u (1) - f_u (0))), parallel upright(bold(d)) times (f_u (1) - f_u (0)) parallel^2)
$


#parec[
  and
][
  和
]

$
  v = frac(d e t (f_u (0) - o , upright(bold(d)) , upright(bold(d)) times (f_u (1) - f_u (0))), parallel upright(bold(d)) times (f_u (1) - f_u (0)) parallel^2)
$

#parec[
  where $d e t$ is shorthand for the determinant of the $3 times 3$ matrix formed from the three column vectors. We will not derive these equations here. The "Further Reading" section has more details.
][
  其中 $d e t$ 是由三个列向量组成的 $3 times 3$ 矩阵的行列式的简写。我们在这里不会推导这些方程。有关更多细节，请参见“延伸阅读”部分。
]

#parec[
  We start by computing a handful of common values that are used in computing the matrix determinants and final parametric values.
][
  我们首先计算用于计算矩阵行列式和最终参数值的一些常用值。
]

#parec[
  Point3f uo = Lerp(u1, p00, p10); Vector3f ud = Lerp(u1, p01, p11) - uo; Vector3f deltao = uo - ray.o; Vector3f perp = Cross(ray.d, ud); Float p2 \= LengthSquared(perp);
][
  Point3f uo = Lerp(u1, p00, p10); Vector3f ud = Lerp(u1, p01, p11) - uo; Vector3f deltao = uo - ray.o; Vector3f perp = Cross(ray.d, ud); Float p2 \= LengthSquared(perp);
]

#parec[
  The matrix determinants in the numerators can easily be computed using the #link("../Utilities/Mathematical_Infrastructure.html#SquareMatrix")[SquareMatrix] class. Note that there are some common subexpressions among the two of them, though we leave it to the compiler to handle them. In a more optimized implementation, writing out the determinant computations explicitly in order to do so manually could be worthwhile.
][
  分子中的矩阵行列式可以使用 #link("../Utilities/Mathematical_Infrastructure.html#SquareMatrix")[SquareMatrix] 类轻松计算。请注意，它们之间有一些常见的子表达式，尽管我们将其留给编译器处理。在更优化的实现中，手动写出行列式计算可能是值得的。
]

#parec[
  Float v1 = Determinant(SquareMatrix\<3\>(deltao.x, ray.d.x, perp.x, deltao.y, ray.d.y, perp.y, deltao.z, ray.d.z, perp.z)); Float t1 = Determinant(SquareMatrix\<3\>(deltao.x, ud.x, perp.x, deltao.y, ud.y, perp.y, deltao.z, ud.z, perp.z));
][
  Float v1 = Determinant(SquareMatrix\<3\>(deltao.x, ray.d.x, perp.x, deltao.y, ray.d.y, perp.y, deltao.z, ray.d.z, perp.z)); Float t1 = Determinant(SquareMatrix\<3\>(deltao.x, ud.x, perp.x, deltao.y, ud.y, perp.y, deltao.z, ud.z, perp.z));
]

#parec[
  Due to round-off error, it is possible that the computed $t$ distance is positive and seemingly represents a valid intersection even though the true value of $t$ is negative and corresponds to a point behind the ray's origin. Testing $t$ against an epsilon value (which is discussed further in Section #link("../Shapes/Managing_Rounding_Error.html#sec:avoid-negative-t-intersections")[6.8.7];) helps avoid reporting incorrect intersections in such cases. Because we defer the division to compute the final $t$ value, it is necessary to test `t1` against `p2 * eps` here.
][
  由于舍入误差，计算出的 $t$ 距离可能是正的，并且似乎代表了一个有效的交点，即使 $t$ 的真实值是负的并对应于射线起点后面的一个点。将 $t$ 与一个 epsilon 值进行比较（在章节 #link("../Shapes/Managing_Rounding_Error.html#sec:avoid-negative-t-intersections")[6.8.7] 中有更详细的讨论）有助于避免在这种情况下报告错误的交点。因为我们推迟了计算最终 $t$ 值的除法，所以有必要在这里将 `t1` 与 `p2 * eps` 进行比较。
]

#parec[
  if (t1 \> p2 \* eps && 0 \<= v1 && v1 \<= p2) { u = u1; v = v1 / p2; t = t1 / p2; }
][
  if (t1 \> p2 \* eps && 0 \<= v1 && v1 \<= p2) { u = u1; v = v1 / p2; t = t1 / p2; }
]

#parec[
  The second $u$ root is handled with equivalent code, though with added logic to keep the closer of the intersections if there are two of them. That fragment is not included here.
][
  第二个 $u$ 根使用等效代码处理，但添加了逻辑以在存在两个交点时保留较近的交点。该片段未包含在此处。
]

#parec[
  If the final closest $t$ value is less than the given `tMax`, then an intersection is returned.
][
  如果最终最近的 $t$ 值小于给定的 `tMax`，则返回一个交点。
]

#parec[
  if (t \>= tMax) return {}; return BilinearIntersection{{u, v}, t};
][
  if (t \>= tMax) return {}; return BilinearIntersection{{u, v}, t};
]

#parec[
  The $(u , v)$ coordinates and ray parametric $t$ value are sufficient to encapsulate the intersection so that the rest of its geometric properties can be computed later.
][
  $(u , v)$ 坐标和射线参数 $t$ 值足以封装交点，以便后续计算几何属性。
]

#parec[
  struct BilinearIntersection { Point2f uv; Float t; };
][
  struct BilinearIntersection { Point2f uv; Float t; };
]

#parec[
  The `InteractionFromIntersection()` method computes all the geometric information necessary to return the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] corresponding to a specified $(u , v)$ point on a bilinear patch, as is found by the intersection routine.
][
  `InteractionFromIntersection()` 方法计算所有必要的几何信息，以返回与双线性补丁上的指定 $(u , v)$ 点对应的 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];，如交点例程所发现的。
]

#parec[
  static SurfaceInteraction InteractionFromIntersection( const BilinearPatchMesh #emph[mesh, int blpIndex, Point2f uv, Float time,
Vector3f wo) { \/\/ Compute bilinear patch point normal p,
partial-normal p/partial-u, and partial-normal p/partial-v for (u, v)
\\/\/ Get bilinear patch vertices in p00, p01, p10, and p11 const int ];v \= &mesh-\>vertexIndices\[4 \* blpIndex\]; Point3f p00 = mesh-\>p\[v\[0\]\], p10 = mesh-\>p\[v\[1\]\]; Point3f p01 = mesh-\>p\[v\[2\]\], p11 = mesh-\>p\[v\[3\]\]; Point3f p = Lerp(uv\[0\], Lerp(uv\[1\], p00, p01), Lerp(uv\[1\], p10, p11)); Vector3f dpdu = Lerp(uv\[1\], p10, p11) - Lerp(uv\[1\], p00, p01); Vector3f dpdv = Lerp(uv\[0\], p01, p11) - Lerp(uv\[0\], p00, p10); \/\/ Compute (s, t) texture coordinates at bilinear patch (u, v) Point2f st = uv; Float duds \= 1, dudt = 0, dvds = 0, dvdt = 1; if (mesh-\>uv) { \/\/ Compute texture coordinates for bilinear patch intersection point Point2f uv00 = mesh-\>uv\[v\[0\]\], uv10 = mesh-\>uv\[v\[1\]\]; Point2f uv01 = mesh-\>uv\[v\[2\]\], uv11 = mesh-\>uv\[v\[3\]\]; st = Lerp(uv\[0\], Lerp(uv\[1\], uv00, uv01), Lerp(uv\[1\], uv10, uv11)); \/\/ Update bilinear patch partial-normal p/partial-u and partial-normal p/partial-v accounting for (s, t) \/\/ Compute partial derivatives of (u, v) with respect to (s, t) Vector2f dstdu = Lerp(uv\[1\], uv10, uv11) - Lerp(uv\[1\], uv00, uv01); Vector2f dstdv = Lerp(uv\[0\], uv01, uv11) - Lerp(uv\[0\], uv00, uv10); duds = std::abs(dstdu\[0\]) \< 1e-8f ? 0 : 1 \/ dstdu\[0\]; dvds = std::abs(dstdv\[0\]) \< 1e-8f ? 0 : 1 / dstdv\[0\]; dudt = std::abs(dstdu\[1\]) \< 1e-8f ? 0 : 1 / dstdu\[1\]; dvdt = std::abs(dstdv\[1\]) \< 1e-8f ? 0 : 1 / dstdv\[1\]; \/\/ Compute partial derivatives of normal p with respect to (s, t) Vector3f dpds = dpdu \* duds + dpdv \* dvds; Vector3f dpdt = dpdu \* dudt + dpdv \* dvdt; \/\/ Set dpdu and dpdv to updated partial derivatives if (Cross(dpds, dpdt) != Vector3f(0, 0, 0)) { if (Dot(Cross(dpdu, dpdv), Cross(dpds, dpdt)) \< 0) dpdt = -dpdt; dpdu = dpds; dpdv = dpdt; } } \\/\/ Find partial derivatives ∂n/∂u and ∂n/∂v for bilinear patch Vector3f d2Pduu(0, 0, 0), d2Pdvv(0, 0, 0); Vector3f d2Pduv = (p00 - p01) \+ (p11 - p10); \/\/ Compute coefficients for fundamental forms Float E \= Dot(dpdu, dpdu), F = Dot(dpdu, dpdv), G = Dot(dpdv, dpdv); Vector3f n \= Normalize(Cross(dpdu, dpdv)); Float e = Dot(n, d2Pduu), f = Dot(n, d2Pduv), g = Dot(n, d2Pdvv); \/\/ Compute ∂n/∂u and ∂n/∂v from fundamental form coefficients Float EGF2 = DifferenceOfProducts(E, G, F, F); Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2; Normal3f dndu = Normal3f((f \* F - e \* G) \* invEGF2 \* dpdu + (e \* F - f \* E) \* invEGF2 \* dpdv); Normal3f dndv = Normal3f((g \* F - f \* G) \* invEGF2 \* dpdu + (f \* F - g \* E) \* invEGF2 \* dpdv); \/\/ Update ∂n/∂u and ∂n/∂v to account for (s, t) parameterization Float EGF2 = DifferenceOfProducts(E, G, F, F); Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2; Normal3f dndu = Normal3f((f \* F - e \* G) \* invEGF2 \* dpdu + (e \* F - f \* E) \* invEGF2 \* dpdv); Normal3f dndv = Normal3f((g \* F - f \* G) \* invEGF2 \* dpdu + (f \* F - g \* E) \* invEGF2 \* dpdv); \/\/ Update ∂n/∂u and ∂n/∂v to account for (s, t) parameterization Normal3f dnds = dndu \* duds + dndv \* dvds; Normal3f dndt = dndu \* dudt + dndv \* dvdt; dndu = dnds; dndv = dndt; \/\/ Initialize bilinear patch intersection point error pError Point3f pAbsSum = Abs(p00) + Abs(p01) + Abs(p10) + Abs(p11); Vector3f pError = gamma(6) \* Vector3f(pAbsSum); \/\/ Initialize SurfaceInteraction for bilinear patch intersection bool flipNormal = mesh-\>reverseOrientation ^ mesh-\>transformSwapsHandedness; SurfaceInteraction isect(Point3fi(p, pError), st, wo, dpdu, dpdv, dndu, dndv, time, flipNormal); \/\/ Compute bilinear patch shading normal if necessary if (mesh-\>n) { \/\/ Compute shading normals for bilinear patch intersection point Normal3f n00 = mesh-\>n\[v\[0\]\], n10 = mesh-\>n\[v\[1\]\]; Normal3f n01 = mesh-\>n\[v\[2\]\], n11 = mesh-\>n\[v\[3\]\]; Normal3f ns = Lerp(uv\[0\], Lerp(uv\[1\], n00, n01), Lerp(uv\[1\], n10, n11)); if (LengthSquared(ns) \> 0) { ns = Normalize(ns); \/\/ Set shading geometry for bilinear patch intersection Normal3f dndu = Lerp(uv\[1\], n10, n11) \- Lerp(uv\[1\], n00, n01); Normal3f dndv = Lerp(uv\[0\], n01, n11) - Lerp(uv\[0\], n00, n10); \/\/ Update ∂n/∂u and ∂n/∂v to account for (s, t) parameterization Normal3f dnds = dndu \* duds + dndv \* dvds; Normal3f dndt = dndu \* dudt + dndv \* dvdt; dndu = dnds; dndv = dndt; Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns)); isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true); } } return isect; }
][
  static SurfaceInteraction InteractionFromIntersection( const BilinearPatchMesh #emph[mesh, int blpIndex, Point2f uv, Float time,
Vector3f wo) { \/\/ 计算双线性补丁点法线及其偏导数 \/\/
获取双线性补丁顶点在 p00, p01, p10 和 p11 中 const int ];v = &mesh-\>vertexIndices\[4 \* blpIndex\]; Point3f p00 = mesh-\>p\[v\[0\]\], p10 = mesh-\>p\[v\[1\]\]; Point3f p01 = mesh-\>p\[v\[2\]\], p11 = mesh-\>p\[v\[3\]\]; Point3f p = Lerp(uv\[0\], Lerp(uv\[1\], p00, p01), Lerp(uv\[1\], p10, p11)); Vector3f dpdu = Lerp(uv\[1\], p10, p11) - Lerp(uv\[1\], p00, p01); Vector3f dpdv = Lerp(uv\[0\], p01, p11) - Lerp(uv\[0\], p00, p10); \/\/ 计算双线性补丁 (u, v) 处的 (s, t) 纹理坐标 Point2f st = uv; Float duds = 1, dudt = 0, dvds = 0, dvdt = 1; if (mesh-\>uv) { \/\/ 计算双线性补丁交点的纹理坐标 Point2f uv00 = mesh-\>uv\[v\[0\]\], uv10 = mesh-\>uv\[v\[1\]\]; Point2f uv01 = mesh-\>uv\[v\[2\]\], uv11 = mesh-\>uv\[v\[3\]\]; st = Lerp(uv\[0\], Lerp(uv\[1\], uv00, uv01), Lerp(uv\[1\], uv10, uv11)); \\/\/ 更新双线性补丁部分法线 p/partial-u 和部分法线 p/partial-v 以考虑 (s, t) \/\/ 计算 (u, v) 相对于 (s, t) 的偏导数 Vector2f dstdu = Lerp(uv\[1\], uv10, uv11) - Lerp(uv\[1\], uv00, uv01); Vector2f dstdv = Lerp(uv\[0\], uv01, uv11) - Lerp(uv\[0\], uv00, uv10); duds = std::abs(dstdu\[0\]) \< 1e-8f ? 0 : 1 / dstdu\[0\]; dvds = std::abs(dstdv\[0\]) \< 1e-8f ? 0 : 1 / dstdv\[0\]; dudt = std::abs(dstdu\[1\]) \< 1e-8f ? 0 : 1 / dstdu\[1\]; dvdt = std::abs(dstdv\[1\]) \< 1e-8f ? 0 : 1 / dstdv\[1\]; \/\/ 计算法线 p 相对于 (s, t) 的偏导数 Vector3f dpds = dpdu \* duds + dpdv \* dvds; Vector3f dpdt = dpdu \* dudt + dpdv \* dvdt; \/\/ 设置 dpdu 和 dpdv 为更新后的偏导数 if (Cross(dpds, dpdt) != Vector3f(0, 0, 0)) { if (Dot(Cross(dpdu, dpdv), Cross(dpds, dpdt)) \< 0) dpdt = -dpdt; dpdu = dpds; dpdv = dpdt; } } \/\/ 查找双线性补丁的 ∂n/∂u 和 ∂n/∂v 的偏导数 Vector3f d2Pduu(0, 0, 0), d2Pdvv(0, 0, 0); Vector3f d2Pduv = (p00 - p01) \+ (p11 - p10); \/\/ 计算基本形式的系数 Float E = Dot(dpdu, dpdu), F = Dot(dpdu, dpdv), G = Dot(dpdv, dpdv); Vector3f n = Normalize(Cross(dpdu, dpdv)); Float e = Dot(n, d2Pduu), f = Dot(n, d2Pduv), g = Dot(n, d2Pdvv); \/\/ 从基本形式系数计算 ∂n/∂u 和 ∂n/∂v Float EGF2 = DifferenceOfProducts(E, G, F, F); Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2; Normal3f dndu = Normal3f((f \* F - e \* G) \* invEGF2 \* dpdu + (e \* F - f \* E) \* invEGF2 \* dpdv); Normal3f dndv = Normal3f((g \* F - f \* G) \* invEGF2 \* dpdu + (f \* F - g \* E) \* invEGF2 \* dpdv); \/\/ 更新 ∂n/∂u 和 ∂n/∂v 以考虑 (s, t) 参数化 Float EGF2 = DifferenceOfProducts(E, G, F, F); Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2; Normal3f dndu = Normal3f((f \* F - e \* G) \* invEGF2 \* dpdu + (e \* F - f \* E) \* invEGF2 \* dpdv); Normal3f dndv = Normal3f((g \* F - f \* G) \* invEGF2 \* dpdu + (f \* F - g \* E) \* invEGF2 \* dpdv); \/\/ 更新 ∂n/∂u 和 ∂n/∂v 以考虑 (s, t) 参数化 Normal3f dnds = dndu \* duds + dndv \* dvds; Normal3f dndt = dndu \* dudt + dndv \* dvdt; dndu = dnds; dndv = dndt; \/\/ 初始化双线性补丁交点误差 pError Point3f pAbsSum = Abs(p00) + Abs(p01) + Abs(p10) + Abs(p11); Vector3f pError = gamma(6) \* Vector3f(pAbsSum); \/\/ 初始化双线性补丁交点的 SurfaceInteraction bool flipNormal = mesh-\>reverseOrientation ^ mesh-\>transformSwapsHandedness; SurfaceInteraction isect(Point3fi(p, pError), st, wo, dpdu, dpdv, dndu, dndv, time, flipNormal); \/\/ 必要时计算双线性补丁的着色法线 if (mesh-\>n) { \/\/ 计算双线性补丁交点的着色法线 Normal3f n00 = mesh-\>n\[v\[0\]\], n10 = mesh-\>n\[v\[1\]\]; Normal3f n01 = mesh-\>n\[v\[2\]\], n11 = mesh-\>n\[v\[3\]\]; Normal3f ns = Lerp(uv\[0\], Lerp(uv\[1\], n00, n01), Lerp(uv\[1\], n10, n11)); if (LengthSquared(ns) \> 0) { ns = Normalize(ns); \/\/ 设置双线性补丁交点的着色几何 Normal3f dndu = Lerp(uv\[1\], n10, n11) - Lerp(uv\[1\], n00, n01); Normal3f dndv = Lerp(uv\[0\], n01, n11) - Lerp(uv\[0\], n00, n10); \/\/ 更新 ∂n/∂u 和 ∂n/∂v 以考虑 (s, t) 参数化 Normal3f dnds = dndu \* duds + dndv \* dvds; Normal3f dndt = dndu \* dudt + dndv \* dvdt; dndu = dnds; dndv = dndt; Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns)); isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true); } } return isect; }
]


#parec[
  $
    frac(partial upright(bold(n)), partial s) = frac(partial upright(bold(n)), partial u) frac(partial u, partial s) + frac(partial upright(bold(n)), partial v) frac(partial v, partial s) ,
  $
][
  $
    frac(partial upright(bold(n)), partial s) = frac(partial upright(bold(n)), partial u) frac(partial u, partial s) + frac(partial upright(bold(n)), partial v) frac(partial v, partial s) ,
  $
]

#parec[
  and similarly for \$ \$.
][
  同样适用于 \$ \$。
]

#parec[
  \<\<Compute partial derivatives of $upright(bold(n))$ with respect to $(s , t)$ \>\>=

  ```cpp
  Vector3f dpds = dpdu * duds + dpdv * dvds;
  Vector3f dpdt = dpdu * dudt + dpdv * dvdt;
  ```
][
  \<\<计算 $upright(bold(n))$ 关于 $(s , t)$ 的偏导数\>\>=

  ```cpp
  Vector3f dpds = dpdu * duds + dpdv * dvds;
  Vector3f dpdt = dpdu * dudt + dpdv * dvdt;
  ```
]

#parec[
  If the provided texture coordinates specify a degenerate mapping, \$ \$ or \$ \$ may be zero. In that case, `dpdu` and `dpdv` are left unchanged, as at least their cross product provides a correct normal vector.
][
  如果所提供的纹理坐标导致退化映射，\$ \$ 或 \$ \$ 可能为零。在这种情况下，`dpdu` 和 `dpdv` 保持不变，因为至少它们的叉积提供了正确的法向量。
]

#parec[
  A dot product checks that the normal given by \$ \$ lies in the same hemisphere as the normal given by the cross product of the original partial derivatives of $upright(bold(n))$, flipping \$ \$ if necessary.
][
  点积用于检查由 \$ \$ 给出的法线是否与由 $upright(bold(n))$ 的原始偏导数的叉积给出的法线位于同一半球中，必要时翻转 \$ \$。
]

#parec[
  Finally, `dpdu` and `dpdv` can be updated.
][
  最后，可以更新 `dpdu` 和 `dpdv`。
]

#parec[
  \<\<Set `dpdu` and `dpdv` to updated partial derivatives\>\>=

  ```cpp
  if (Cross(dpds, dpdt) != Vector3f(0, 0, 0)) {
      if (Dot(Cross(dpdu, dpdv), Cross(dpds, dpdt)) < 0)
          dpdt = -dpdt;
      dpdu = dpds;
      dpdv = dpdt;
  }
  ```
][
  \<\<将 `dpdu` 和 `dpdv` 设置为更新的偏导数\>\>=

  ```cpp
  if (Cross(dpds, dpdt) != Vector3f(0, 0, 0)) {
      if (Dot(Cross(dpdu, dpdv), Cross(dpds, dpdt)) < 0)
          dpdt = -dpdt;
      dpdu = dpds;
      dpdv = dpdt;
  }
  ```
]

#parec[
  The second partial derivatives of $upright(bold(n))$ are easily found to compute the partial derivatives of the surface normal; all but \$ \$ are zero vectors.
][
  \$ \$ 的二阶偏导数很容易找到以计算表面法线的偏导数；除了 \$ \$ 之外，都是零向量。
]

#parec[
  Thence, the partial derivatives of the normal can be computed using the regular approach. These are then adjusted to account for the $(s , t)$ parameterization in the same way that \$ \$ and \$ \$ were.
][
  因此，可以使用常规方法计算法线的偏导数。然后调整这些以考虑 $(s , t)$ 参数化，就像 \$ \$ 和 \$ \$ 那样。
]

#parec[
  The corresponding fragment follows the same form as \<\<Compute partial derivatives of $upright(bold(n))$ with respect to $(s , t)$ \>\> and is therefore not included here.
][
  相应的片段遵循与 \<\<计算 $upright(bold(n))$ 关于 $(s , t)$ 的偏导数\>\> 相同的形式，因此这里不包括。
]

#parec[
  \<\<Find partial derivatives \$ \$ and \$ \$ for bilinear patch\>\>=

  ```cpp
  Vector3f d2Pduu(0, 0, 0), d2Pdvv(0, 0, 0);
  Vector3f d2Pduv = (p00 - p01) + (p11 - p10);
  <<Compute coefficients for fundamental forms>>   Float E = Dot(dpdu, dpdu), F = Dot(dpdu, dpdv), G = Dot(dpdv, dpdv);
     Vector3f n = Normalize(Cross(dpdu, dpdv));
     Float e = Dot(n, d2Pduu), f = Dot(n, d2Pduv), g = Dot(n, d2Pdvv);
  <<Compute partial derivatives $ \frac{\partial \mathbf{n}}{\partial u} $ and $ \frac{\partial \mathbf{n}}{\partial v} $ from fundamental form coefficients>>   Float EGF2 = DifferenceOfProducts(E, G, F, F);
     Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2;
     Normal3f dndu = Normal3f((f * F - e * G) * invEGF2 * dpdu +
                              (e * F - f * E) * invEGF2 * dpdv);
     Normal3f dndv = Normal3f((g * F - f * G) * invEGF2 * dpdu +
                              (f * F - g * E) * invEGF2 * dpdv);
  <<Update $ \frac{\partial \mathbf{n}}{\partial u} $ and $ \frac{\partial \mathbf{n}}{\partial v} $ to account for $(s, t)$ parameterization>>   Normal3f dnds = dndu * duds + dndv * dvds;
     Normal3f dndt = dndu * dudt + dndv * dvdt;
     dndu = dnds;
     dndv = dndt;
  ```
][
  \<\<找到双线性片段的 \$ \$ 和 \$ \$ 的偏导数\>\>=

  ```cpp
  Vector3f d2Pduu(0, 0, 0), d2Pdvv(0, 0, 0);
  Vector3f d2Pduv = (p00 - p01) + (p11 - p10);
  <<计算基本形式的系数>>  Float E = Dot(dpdu, dpdu), F = Dot(dpdu, dpdv), G = Dot(dpdv, dpdv);
     Vector3f n = Normalize(Cross(dpdu, dpdv));
     Float e = Dot(n, d2Pduu), f = Dot(n, d2Pduv), g = Dot(n, d2Pdvv);
  <<从基本形式系数计算 $ \frac{\partial \mathbf{n}}{\partial u} $ 和 $ \frac{\partial \mathbf{n}}{\partial v} $ 的偏导数>>  Float EGF2 = DifferenceOfProducts(E, G, F, F);
     Float invEGF2 = (EGF2 == 0) ? Float(0) : 1 / EGF2;
     Normal3f dndu = Normal3f((f * F - e * G) * invEGF2 * dpdu +
                              (e * F - f * E) * invEGF2 * dpdv);
     Normal3f dndv = Normal3f((g * F - f * G) * invEGF2 * dpdu +
                              (f * F - g * E) * invEGF2 * dpdv);
  <<更新 $ \frac{\partial \mathbf{n}}{\partial u} $ 和 $ \frac{\partial \mathbf{n}}{\partial v} $ 以考虑 $(s, t)$ 参数化>>  Normal3f dnds = dndu * duds + dndv * dvds;
     Normal3f dndt = dndu * dudt + dndv * dvdt;
     dndu = dnds;
     dndv = dndt;
  ```
]

#parec[
  All the necessary information for initializing the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] is now at hand.
][
  现在掌握了初始化 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] 所需的所有信息。
]

#parec[
  \<\<Initialize `SurfaceInteraction` for bilinear patch intersection\>\>=

  ```cpp
  bool flipNormal = mesh->reverseOrientation ^ mesh->transformSwapsHandedness;
  SurfaceInteraction isect(Point3fi(p, pError), st, wo, dpdu, dpdv,
                           dndu, dndv, time, flipNormal);
  ```
][
  \<\<初始化双线性片段交点的 `SurfaceInteraction`\>\>=

  ```cpp
  bool flipNormal = mesh->reverseOrientation ^ mesh->transformSwapsHandedness;
  SurfaceInteraction isect(Point3fi(p, pError), st, wo, dpdu, dpdv,
                           dndu, dndv, time, flipNormal);
  ```
]

#parec[
  Shading geometry is set in the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] after it is created. Therefore, per-vertex shading normals are handled next.
][
  阴影几何体在 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] 创建后设置。因此，接下来处理每个顶点的阴影法线。
]

#parec[
  \<\>= \ \`\`\`cpp if (mesh-\>n) { \<\> \ Normal3f n00 = mesh-\>n\[v\[0\]\], n10 = mesh-\>n\[v\[1\]\]; Normal3f n01 = mesh-\>n\[v\[2\]\], n11 = mesh-\>n\[v\[3\]\]; Normal3f ns = Lerp(uv\[0\], Lerp(uv\[1\], n00, n01), Lerp(uv\[1\], n10, n11)); if (LengthSquared(ns) \> 0) { ns = Normalize(ns); \<\> \ Normal3f dndu = Lerp(uv\[1\], n10, n11) - Lerp(uv\[1\], n00, n01); Normal3f dndv = Lerp(uv\[0\], n01, n11) - Lerp(uv\[0\], n00, n10); \<\<Update \$ \$ and \$ \$ to account for $(s , t)$ parameterization\>\> \ Normal3f dnds = dndu \* duds + dndv \* dvds; Normal3f dndt = dndu \* dudt + dndv \* dvdt; dndu = dnds; dndv = dndt; Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns)); isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true); } }
][
  \<\<如有必要，计算双线性片段的阴影法线\>\>= \ `cpp if (mesh->n) {     <<计算双线性片段交点的阴影法线>>       Normal3f n00 = mesh->n[v[0]], n10 = mesh->n[v[1]];     Normal3f n01 = mesh->n[v[2]], n11 = mesh->n[v[3]];     Normal3f ns = Lerp(uv[0], Lerp(uv[1], n00, n01), Lerp(uv[1], n10, n11));     if (LengthSquared(ns) > 0) {         ns = Normalize(ns);         <<设置双线性片段交点的阴影几何体>>           Normal3f dndu = Lerp(uv[1], n10, n11) - Lerp(uv[1], n00, n01);         Normal3f dndv = Lerp(uv[0], n01, n11) - Lerp(uv[0], n00, n10);         <<更新 $ \frac{\partial \mathbf{n}}{\partial u} $ 和 $ \frac{\partial \mathbf{n}}{\partial v} $ 以考虑 $(s, t)$ 参数化>>           Normal3f dnds = dndu * duds + dndv * dvds;         Normal3f dndt = dndu * dudt + dndv * dvdt;         dndu = dnds;         dndv = dndt;         Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns));         isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true);     } }`
]

#parec[
  The usual bilinear interpolation is performed and if the resulting normal is non-degenerate, the shading geometry is provided to the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];.
][
  进行常规的双线性插值，如果结果法线不是退化的，则将阴影几何体提供给 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction];。
]

#parec[
  \<\>=

  ```cpp
  Normal3f n00 = mesh->n[v[0]], n10 = mesh->n[v[1]];
  Normal3f n01 = mesh->n[v[2]], n11 = mesh->n[v[3]];
  Normal3f ns = Lerp(uv[0], Lerp(uv[1], n00, n01), Lerp(uv[1], n10, n11));
  if (LengthSquared(ns) > 0) {
      ns = Normalize(ns);
      <<Set shading geometry for bilinear patch intersection>>
      Normal3f dndu = Lerp(uv[1], n10, n11) - Lerp(uv[1], n00, n01);
      Normal3f dndv = Lerp(uv[0], n01, n11) - Lerp(uv[0], n00, n10);
      <<Update $ \frac{\partial \mathbf{n}}{\partial u} $ and $ \frac{\partial \mathbf{n}}{\partial v} $ to account for $(s, t)$ parameterization>>
      Normal3f dnds = dndu * duds + dndv * dvds;
      Normal3f dndt = dndu * dudt + dndv * dvdt;
      dndu = dnds;
      dndv = dndt;
      Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns));
      isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true);
  }
  ```
][
  \<\>=

  ```cpp
  Normal3f n00 = mesh->n[v[0]], n10 = mesh->n[v[1]];
  Normal3f n01 = mesh->n[v[2]], n11 = mesh->n[v[3]];
  Normal3f ns = Lerp(uv[0], Lerp(uv[1], n00, n01), Lerp(uv[1], n10, n11));
  if (LengthSquared(ns) > 0) {
      ns = Normalize(ns);
      <<设置双线性片段交点的阴影几何体>>
      Normal3f dndu = Lerp(uv[1], n10, n11) - Lerp(uv[1], n00, n01);
      Normal3f dndv = Lerp(uv[0], n01, n11) - Lerp(uv[0], n00, n10);
      <<更新 $ \frac{\partial \mathbf{n}}{\partial u} $ 和 $ \frac{\partial \mathbf{n}}{\partial v} $ 以考虑 $(s, t)$ 参数化>>
      Normal3f dnds = dndu * duds + dndv * dvds;
      Normal3f dndt = dndu * dudt + dndv * dvdt;
      dndu = dnds;
      dndv = dndt;
      Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns));
      isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true);
  }
  ```
]

#parec[
  The partial derivatives of the shading normal are computed in the same manner as the partial derivatives of $upright(bold(n))$ were found, including the adjustment for the parameterization given by per-vertex texture coordinates, if provided.
][
  阴影法线的偏导数的计算方式与 $upright(bold(n))$ 的偏导数的计算方式相同，包括根据每个顶点的纹理坐标提供的参数化进行调整。
]

#parec[
  Because shading geometry is specified via shading \$ \$ and \$ \$ vectors, here we find the rotation matrix that takes the geometric normal to the shading normal and apply it to `dpdu` and `dpdv`.
][
  因为阴影几何体是通过阴影 \$ \$ 和 \$ \$ 向量指定的，所以我们在此找到将几何法线旋转到阴影法线的旋转矩阵，并将其应用于 `dpdu` 和 `dpdv`。
]

#parec[
  The cross product of the resulting vectors then gives the shading normal.
][
  然后，结果向量的叉积给出阴影法线。
]

#parec[
  \<\>=

  ```cpp
  Normal3f dndu = Lerp(uv[1], n10, n11) - Lerp(uv[1], n00, n01);
  Normal3f dndv = Lerp(uv[0], n01, n11) - Lerp(uv[0], n00, n10);
  <<Update $ \frac{\partial \mathbf{n}}{\partial u} $ and $ \frac{\partial \mathbf{n}}{\partial v} $ to account for $(s, t)$ parameterization>>
  Normal3f dnds = dndu * duds + dndv * dvds;
  Normal3f dndt = dndu * dudt + dndv * dvdt;
  dndu = dnds;
  dndv = dndt;
  Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns));
  isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true);
  ```
][
  \<\>=

  ```cpp
  Normal3f dndu = Lerp(uv[1], n10, n11) - Lerp(uv[1], n00, n01);
  Normal3f dndv = Lerp(uv[0], n01, n11) - Lerp(uv[0], n00, n10);
  <<更新 $ \frac{\partial \mathbf{n}}{\partial u} $ 和 $ \frac{\partial \mathbf{n}}{\partial v} $ 以考虑 $(s, t)$ 参数化>>
  Normal3f dnds = dndu * duds + dndv * dvds;
  Normal3f dndt = dndu * dudt + dndv * dvdt;
  dndu = dnds;
  dndv = dndt;
  Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns));
  isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true);
  ```
]

#parec[
  Given the intersection and `InteractionFromIntersection()` methods, both of the `BilinearPatch::Intersect()` and `IntersectP()` methods are easy to implement.
][
  给定交点和 `InteractionFromIntersection()` 方法，`BilinearPatch::Intersect()` 和 `IntersectP()` 方法都很容易实现。
]

#parec[
  Since they both follow what should be by now a familiar form, we have not included them here.
][
  由于它们都遵循现在应该已经熟悉的形式，因此我们没有在这里包括它们。
]


#parec[
  The sampling routines for bilinear patches select between sampling algorithms depending on the characteristics of the patch.
][
  双线性补丁的采样算法例程根据补丁的特性选择采样算法。
]

#parec[
  For area sampling, both rectangular patches and patches that have an emission distribution defined by an image map are given special treatment.
][
  对于面积采样，矩形补丁和具有由图像映射定义的发射分布的补丁都得到了特殊处理。
]

#parec[
  When sampling by solid angle from a reference point, rectangular patches are projected onto the sphere and sampled as spherical rectangles.
][
  当从参考点进行立体角采样时，矩形补丁被投影到球面上并作为球面矩形进行采样。
]

#parec[
  For both cases, general-purpose sampling routines are used otherwise.
][
  在这两种情况下，若无特殊要求则使用通用采样例程。
]

#parec[
  The area sampling method first samples parametric $(u , v)$ coordinates, from which the rest of the necessary geometric values are derived.
][
  面积采样方法首先采样参数化的 $(u , v)$ 坐标，然后从中导出其余必要的几何值。
]

#parec[
  While all the `Shape` implementations we have implemented so far can be used as area light sources, none of their sampling routines have accounted for the fact that `pbrt`'s #link("../Light_Sources/Area_Lights.html#DiffuseAreaLight")[`DiffuseAreaLight`] allows specifying an image that is used to represent spatially varying emission over the shape's $(u , v)$ surface.
][
  虽然我们迄今为止实现的所有 `Shape` 实现都可以用作面积光源，但它们的采样例程都没有考虑到 `pbrt` 的 #link("../Light_Sources/Area_Lights.html#DiffuseAreaLight")[`DiffuseAreaLight`] 允许指定一个图像用于表示形状 $(u , v)$ 表面上的空间变化发射。
]

#parec[
  Because such emission profiles are most frequently used with rectangular light sources, the #link("<BilinearPatch>")[`BilinearPatch`] has the capability of sampling in $(u , v)$ according to the emission function.
][
  因为这种发射分布通常用于矩形光源，所以 #link("<BilinearPatch>")[`BilinearPatch`] 具有根据发射函数在 $(u , v)$ 中采样的能力。
]

#parec[
  Figure 6.26 demonstrates the value of doing so.
][
  图 6.26 展示了这样做的价值。
]

#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f26.svg"),
  caption: [
    #ez_caption[
      For a scene with an emissive bilinear patch where the amount of emission
      varies across the patch based on an image, (a) uniformly sampling in the
      patch’s $(u , v)$ parametric space leads to high variance since some
      samples have much higher contributions than others. (b)Sampling according to the image’s distribution of brightness gives a
      significantly better result for the same number of rays.
      Here, MSE is improved by a factor of $2.28$ times.
    ][
      对于一个发射双线性补丁的场景，其中发射量根据图像在补丁上变化，(a)
      在补丁的 $(u , v)$
      参数空间中均匀采样会导致高方差，因为某些样本的贡献远高于其他样本。(b) 根据图像的亮度分布进行采样，在相同数量的光线下可以显著改善结果。
      这里，均方误差改进了 2.28 倍。
      #emph[(兔子模型由斯坦福计算机图形实验室提供。)]
    ]
  ],
)<area-sampling-image-emission>

#parec[
  Otherwise, if the patch is not a rectangle, an approximation to uniform area sampling is used.
][
  否则，如果补丁不是矩形，则使用近似的均匀面积采样。
]

#parec[
  If it is a rectangle, then uniform area sampling is trivial and the provided sample value is used directly for $(u , v)$.
][
  如果是矩形，则均匀面积采样是简单的，并且直接使用提供的样本值作为 $(u , v)$。
]

#parec[
  In all of these cases, the `pdf` value is with respect to the $(u , v)$ parametric domain over $[0 , 1]^2$.
][
  在所有这些情况下，`pdf` 值是相对于 $[0 , 1]^2$ 上的 $(u , v)$ 参数域的。
]



```cpp
<<Sample bilinear patch parametric  coordinates>>=
Float pdf = 1;
Point2f uv;
if (mesh->imageDistribution)
    uv = mesh->imageDistribution->Sample(u, &pdf);
else if (!IsRectangle(mesh)) {
    <<Sample patch  with approximate uniform area sampling>>
} else
    uv = u;
<<BilinearPatchMesh Public Members>>+=
PiecewiseConstant2D *imageDistribution;
```

