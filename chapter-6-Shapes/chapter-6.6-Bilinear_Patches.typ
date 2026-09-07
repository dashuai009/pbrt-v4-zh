#import "../template.typ": parec, ez_caption

== #ez_caption[Bilinear Patches][双线性面片]
<billinear-patches>

#parec[
  It is useful to have a shape defined by four vertices. One option would be a planar quadrilateral, though not requiring all four vertices to be coplanar is preferable, as it is less restrictive. Such a shape is the bilinear patch, which is a parametric surface defined by four vertices $p_(0,0)$, $p_(1,0)$, $p_(0,1)$, and $p_(1,1)$. Each vertex gives the position associated with a corner of the parametric $(u,v)$ domain $[0,1]^2$ and points on the surface are defined via bilinear interpolation:
][
  由四个顶点定义的形状很有用。平面四边形是一种选择，但不要求四点共面更灵活。双线性面片就是这样的参数曲面，由 $p_(0,0)$、$p_(1,0)$、$p_(0,1)$、$p_(1,1)$ 四个顶点定义，分别对应参数域 $[0,1]^2$ 的四个角点。曲面上的点由双线性插值得到：
]

$ f(u,v)=(1-u)(1-v)p_(0,0)+u(1-v)p_(1,0)+(1-u)v p_(0,1)+u v p_(1,1) . $ <blp-definition>

#parec[
  The bilinear patch is a doubly ruled surface: there are two straight lines through every point on it. (This can be seen by considering a parametric point on the surface $(u,v)$ and then fixing either of $u$ and $v$ and considering the function that results: it is linear.)
][
  双线性面片是双直纹面：曲面上每一点都通过两条位于曲面上的直线。固定参数点 $(u,v)$ 中的 $u$ 或 $v$ 后，所得函数为线性函数，因此可见这一性质。
]

#parec[
  Not only can bilinear patches be used to represent planar quadrilaterals, but they can also represent simple curved surfaces. They are a useful target for converting higher-order parametric surfaces to simpler shapes that are amenable to direct ray intersection. @fig:two-blps shows two bilinear patches.
][
  双线性面片既能表示平面四边形，也能表示简单曲面。将高阶参数曲面转为便于直接求交的简单形状时，它们是有用的目标表示。@fig:two-blps 展示了两个双线性面片。
]

#figure(image("../pbr-book-website/4ed/Shapes/blps.png"),caption:[#ez_caption[Two Bilinear Patches. The bilinear patch is defined by four vertices that are not necessarily planar. It is able to represent a variety of simple curved surfaces.][两个双线性面片。定义面片的四个顶点不必共面，因此可以表示多种简单曲面。]]) <two-blps>

#parec[
  `pbrt` allows the specification of bilinear patch meshes for the same reasons that triangle meshes can be specified: to allow per-vertex attributes like position and surface normal to be shared by multiple patches and to allow mesh-wide properties to be stored just once. To this end, `BilinearPatchMesh` plays the equivalent role to the `TriangleMesh`.
][
  与三角网格一样，`pbrt` 支持双线性面片网格，让多个面片共享位置、法向量等逐顶点属性，并让整个网格的共同属性只保存一次。`BilinearPatchMesh` 因而承担与 `TriangleMesh` 相同的角色。
]
#block(sticky: true)[#raw("<<BilinearPatchMesh Definition>>=")] <fragment-BilinearPatchMeshDefinition-0>
```cpp
class BilinearPatchMesh {
  public:
    <<BilinearPatchMesh Public Methods>>
    <<BilinearPatchMesh Public Members>>
};
``` <BilinearPatchMesh>
#parec[
  We will skip past the `BilinearPatchMesh` constructor, as it mirrors the `TriangleMesh`’s, transforming the positions and normals to rendering space and using the `BufferCache` to avoid storing redundant buffers in memory.
][
  `BilinearPatchMesh` 构造函数与 `TriangleMesh` 类似：将位置和法向量变换到渲染空间，并用 `BufferCache` 避免重复保存缓冲区，因此正文略去其实现。
]
#block(sticky: true)[#raw("<<BilinearPatchMesh Public Members>>=")] <fragment-BilinearPatchMeshPublicMembers-0>
```cpp
bool reverseOrientation, transformSwapsHandedness;
int nPatches, nVertices;
const int *vertexIndices = nullptr;
const Point3f *p = nullptr;
const Normal3f *n = nullptr;
const Point2f *uv = nullptr;
```
#parec[
  The `BilinearPatch` class implements the `Shape` interface and represents a single patch in a bilinear patch mesh.
][
  `BilinearPatch` 实现 `Shape` 接口，表示网格中的单个双线性面片。
]
#block(sticky: true)[#raw("<<BilinearPatch Definition>>=")] <fragment-BilinearPatchDefinition-0>
```cpp
class BilinearPatch {
  public:
    <<BilinearPatch Public Methods>>
  private:
    <<BilinearPatch Private Methods>>
    <<BilinearPatch Private Members>>
};
``` <BilinearPatch>
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>=")] <fragment-BilinearPatchMethodDefinitions-0>
```cpp
BilinearPatch::BilinearPatch(const BilinearPatchMesh *mesh, int meshIndex,
                             int blpIndex)
    : meshIndex(meshIndex), blpIndex(blpIndex) {
    <<Store area of bilinear patch in area>>
}
```
#parec[
  Also similar to triangles, each `BilinearPatch` stores the index of the mesh that it is a part of as well as its own index in the mesh’s patches.
][
  与三角形类似，每个 `BilinearPatch` 保存所属网格的索引及自身在网格面片中的索引。
]
#block(sticky: true)[#raw("<<BilinearPatch Private Members>>=")] <fragment-BilinearPatchPrivateMembers-0>
```cpp
int meshIndex, blpIndex;
```
#parec[
  The `GetMesh()` method makes it easy for a `BilinearPatch` to get the pointer to its associated mesh.
][
  `GetMesh()` 便于面片获取所属网格的指针。
]
#block(sticky: true)[#raw("<<BilinearPatch Private Methods>>=")] <fragment-BilinearPatchPrivateMethods-0>
```cpp
const BilinearPatchMesh *GetMesh() const {
    return (*allMeshes)[meshIndex];
}
```
#parec[
  There is a subtlety that comes with the use of a vector to store the meshes. `pbrt`’s scene initialization code in Appendix C does its best to parallelize its work, which includes the parallelization of reading binary files that encode meshes from disk. A mutex is used to protect adding meshes to this vector, though as this vector grows, it is periodically reallocated to make more space. A consequence is that the `BilinearPatch` constructor must not call the `GetMesh()` method to get its `BilinearPatchMesh *`, since `GetMesh()` accesses `allMeshes` without mutual exclusion. Thus, the mesh is passed to the constructor as a parameter above.
][
  用 vector 保存网格有一处细节。附录C的场景初始化尽量并行执行，包括从磁盘并行读取网格二进制文件。添加网格时虽有互斥锁保护，但 vector 增长时会重新分配内存，而 `GetMesh()` 访问 `allMeshes` 时没有互斥保护。因此，`BilinearPatch` 构造函数不能调用它获取网格指针，上面改为将网格直接作为参数传入。
]
#block(sticky: true)[#raw("<<BilinearPatch Private Members>>+=")] <fragment-BilinearPatchPrivateMembers-1>
```cpp
static pstd::vector<const BilinearPatchMesh *> *allMeshes;
```
#parec[
  The area of a parametric surface defined over $[0,1]^2$ is given by the integral
][
  定义在 $[0,1]^2$ 上的参数曲面，其面积为
]

$ integral_0^1 integral_0^1 norm(frac(∂p,∂u) times frac(∂p,∂v)) thin d u thin d v . $ <parametric-surface-area>

#parec[
  The partial derivatives of a bilinear patch are easily derived. They are:
][
  双线性面片的偏导数容易推得：
]

$ frac(∂p,∂u)&=(1-v)(p_(1,0)-p_(0,0))+v(p_(1,1)-p_(0,1)) \
 frac(∂p,∂v)&=(1-u)(p_(0,1)-p_(0,0))+u(p_(1,1)-p_(1,0)) . $ <blp-dpdu-dpdv>

#parec[
  However, it is not generally possible to evaluate the area integral from @eqt:parametric-surface-area in closed form with these partial derivatives. Therefore, the `BilinearPatch` constructor caches the patch’s surface area in a member variable, using numerical integration to compute its value if necessary.
][
  一般无法用这些偏导数求得 @eqt:parametric-surface-area 的闭式解。因此，构造函数会将面积缓存到成员变量中，必要时通过数值积分计算。
]

#parec[
  Because bilinear patches are often used to represent rectangles, the constructor checks for that case and takes the product of the lengths of the sides of the rectangle to compute the area when appropriate. In the general case, the fragment ⟨Compute approximate area of bilinear patch⟩ uses a Riemann sum evaluated at $3 times 3$ points to approximate @eqt:parametric-surface-area. We do not include that code fragment here.
][
  双线性面片常用于表示矩形，因此构造函数先检查这一情况，若成立就用两边长度之积求面积。一般情况下，⟨Compute approximate area of bilinear patch⟩ 用 $3 times 3$ 个点上的黎曼和近似该积分，正文不列出这一片段。
]
#block(sticky: true)[#raw("<<Store area of bilinear patch in area>>=")] <fragment-Storeareaofbilinearpatchinmonoarea-0>
```cpp
<<Get bilinear patch vertices in p00, p01, p10, and p11>>
if (IsRectangle(mesh))
    area = Distance(p00, p01) * Distance(p00, p10);
else {
    <<Compute approximate area of bilinear patch>>
}
```
#block(sticky: true)[#raw("<<BilinearPatch Private Members>>+=")] <fragment-BilinearPatchPrivateMembers-2>
```cpp
Float area;
```
#parec[
  This fragment, which loads the four vertices of a patch into local variables, will be reused in many of the following methods.
][
  下面的片段将四个顶点读入局部变量，后续许多方法都会复用它。
]
#block(sticky: true)[#raw("<<Get bilinear patch vertices in p00, p01, p10, and p11>>=")] <fragment-Getbilinearpatchverticesinmonop00monop01monop10andmonop11-0>
```cpp
const int *v = &mesh->vertexIndices[4 * blpIndex];
Point3f p00 = mesh->p[v[0]], p10 = mesh->p[v[1]];
Point3f p01 = mesh->p[v[2]], p11 = mesh->p[v[3]];
```
#parec[
  In addition to the surface area computation, there will be a number of additional cases where we will find it useful to use specialized algorithms if a `BilinearPatch` is a rectangle. Therefore, this check is encapsulated in the `IsRectangle()` method. It first tests to see if any two neighboring vertices are coincident, in which case the patch is certainly not a rectangle. This check is important to perform first, since the following ones would otherwise end up trying to perform invalid operations like normalizing degenerate vectors in that case.
][
  除了面积计算，还有多处可以对矩形采用专门算法，因此将矩形判断封装为 `IsRectangle()`。它首先排除相邻顶点重合的情况；否则，后续检查可能尝试归一化退化向量等无效操作。
]
#block(sticky: true)[#raw("<<BilinearPatch Private Methods>>+=")] <fragment-BilinearPatchPrivateMethods-1>
```cpp
bool IsRectangle(const BilinearPatchMesh *mesh) const {
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    if (p00 == p01 || p01 == p11 || p11 == p10 || p10 == p00)
        return false;
    <<Check if bilinear patch vertices are coplanar>>
    <<Check if planar vertices form a rectangle>>
}
```
#parec[
  If the four vertices are not coplanar, then they do not form a rectangle. We can check this case by computing the surface normal of the plane formed by three of the vertices and then testing if the vector from one of those three to the fourth vertex is not (nearly) perpendicular to the plane normal.
][
  四点不共面就不可能构成矩形。先求三个顶点所在平面的法向量，再检查从其中一点指向第四点的向量是否近似垂直于该法向量，即可判断共面性。
]
#block(sticky: true)[#raw("<<Check if bilinear patch vertices are coplanar>>=")] <fragment-Checkifbilinearpatchverticesarecoplanar-0>
```cpp
Normal3f n(Normalize(Cross(p10 - p00, p01 - p00)));
if (AbsDot(Normalize(p11 - p00), n) > 1e-5f)
    return false;
```
#parec[
  Four coplanar vertices form a rectangle if they all have the same distance from the average of their positions. The implementation here computes the squared distance to save the square root operations and then tests the relative error with respect to the first squared distance. Because the test is based on relative error, it is not sensitive to the absolute size of the patch; scaling all the vertex positions does not affect it.
][
  如果四个共面顶点到其平均位置的距离相同，它们便构成矩形。实现采用距离平方以省去开方，再相对于第一个距离平方检查误差。由于使用相对误差，判断不依赖面片的绝对尺寸，整体缩放不影响结果。
]
#block(sticky: true)[#raw("<<Check if planar vertices form a rectangle>>=")] <fragment-Checkifplanarverticesformarectangle-0>
```cpp
Point3f pCenter = (p00 + p01 + p10 + p11) / 4;
Float d2[4] = {
    DistanceSquared(p00, pCenter), DistanceSquared(p01, pCenter),
    DistanceSquared(p10, pCenter), DistanceSquared(p11, pCenter) };
for (int i = 1; i < 4; ++i)
    if (std::abs(d2[i] - d2[0]) / d2[0] > 1e-4f)
        return false;
return true;
```
#parec[
  With the area cached, implementation of the `Area()` method is trivial.
][
  缓存面积后，`Area()` 可直接返回它。
]
#block(sticky: true)[#raw("<<BilinearPatch Public Methods>>=")] <fragment-BilinearPatchPublicMethods-0>
```cpp
Float Area() const { return area; }
```
#parec[
  The bounds of a bilinear patch are given by the bounding box that bounds its four corner vertices. As with `Triangle`s, the mesh vertices are already in rendering space, so no further transformation is necessary here.
][
  包围四个角点的包围盒也包围整个双线性面片。与三角形一样，网格顶点已经处于渲染空间，无需再变换。
]
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>+=")] <fragment-BilinearPatchMethodDefinitions-1>
```cpp
Bounds3f BilinearPatch::Bounds() const {
    const BilinearPatchMesh *mesh = GetMesh();
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    return Union(Bounds3f(p00, p01), Bounds3f(p10, p11));
}
```
#parec[
  Although a planar patch has a single surface normal, the surface normal of a nonplanar patch varies across its surface.
][
  平面面片只有一个表面法向量方向，非平面面片的法向量则随位置变化。
]
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>+=")] <fragment-BilinearPatchMethodDefinitions-2>
```cpp
DirectionCone BilinearPatch::NormalBounds() const {
    const BilinearPatchMesh *mesh = GetMesh();
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    <<If patch is a triangle, return bounds for single surface normal>>
    <<Compute bilinear patch normal n00 at (0, 0) >>
    <<Compute bilinear patch normals n10, n01, and n11>>
    <<Compute average normal and return normal bounds for patch>>
}
```
#parec[
  If the bilinear patch is actually a triangle, the ⟨If patch is a triangle, return bounds for single surface normal⟩ fragment evaluates its surface normal and returns the corresponding `DirectionCone`. We have not included that straightforward fragment here.
][
  若双线性面片实际是三角形，⟨If patch is a triangle, return bounds for single surface normal⟩ 会计算单一表面法向量并返回对应的 `DirectionCone`。这一直接的实现不在正文列出。
]

#parec[
  Otherwise, the normals are computed at the four corners of the patch. The following fragment computes the normal at the $(0,0)$ parametric position. It is particularly easy to evaluate the partial derivatives at the corners; they work out to be the differences with the adjacent vertices in `u` and `v`. Some care is necessary with the orientation of the normals, however. As with triangle meshes, if per-vertex shading normals were specified, they determine which side of the surface the geometric normal lies on. Otherwise, the normal may need to be flipped, depending on the user-specified orientation and the handedness of the rendering-to-object-space transformation.
][
  其他情况下，计算四个角点的法向量。下面先处理 $(0,0)$：角点处的偏导数就是沿 `u` 和 `v` 相邻顶点之差。需要注意朝向；与三角网格一样，若提供了逐顶点着色法向量，由它们决定几何法向量位于表面的哪一侧；否则根据用户指定的朝向和渲染到对象空间变换的手性决定是否翻转。
]
#block(sticky: true)[#raw("<<Compute bilinear patch normal n00 at (0, 0) >>=")] <fragment-Computebilinearpatchnormalmonon00at00-0>
```cpp
Vector3f n00 = Normalize(Cross(p10 - p00, p01 - p00));
if (mesh->n)
    n00 = FaceForward(n00, mesh->n[v[0]]);
else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    n00 = -n00;
```
#parec[
  Normals at the other three vertices are computed in an equivalent manner, so the fragment that handles the rest is not included here.
][
  另外三个顶点的计算相同，正文不再列出。
]

#parec[
  A bounding cone for the normals is found by taking their average and then finding the cosine of the maximum angle that any of them makes with their average. Although this does not necessarily give an optimal bound, it usually works well in practice. (See the “Further Reading” section in Chapter 3 for more information on this topic.)
][
  先取法向量的平均方向，再求四个法向量与该平均方向所成夹角中最大者的余弦，就能得到法向量包围锥。它不一定最优，但实践中通常效果良好。第3章“延伸阅读”提供了更多资料。
]
#block(sticky: true)[#raw("<<Compute average normal and return normal bounds for patch>>=")] <fragment-Computeaveragenormalandreturnnormalboundsforpatch-0>
```cpp
Vector3f n = Normalize(n00 + n10 + n01 + n11);
Float cosTheta = std::min({Dot(n, n00), Dot(n, n01),
                           Dot(n, n10), Dot(n, n11)});
return DirectionCone(n, Clamp(cosTheta, -1, 1));
```
=== #ez_caption[Intersection Tests][求交测试]
<bilinear-intersection-tests>

#parec[
  Unlike triangles (but like spheres and cylinders), a ray may intersect a bilinear patch twice, in which case the closest of the two intersections is returned. An example is shown in @fig:ray-blp-one-or-two.
][
  与三角形不同，射线可能像与球体或圆柱体一样，与双线性面片相交两次，此时返回较近的交点，见 @fig:ray-blp-one-or-two 。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f23.svg"), caption: [#ez_caption[Ray–Bilinear Patch Intersections. Rays may intersect a bilinear patch either once or two times.][射线与双线性面片求交。射线可能与面片相交一次或两次。]]) <ray-blp-one-or-two>

#parec[
  As with triangles, it is useful to have a stand-alone ray–bilinear patch intersection test function rather than only providing this functionality through an instance of a `BilinearPatch` object. Rather than being based on computing `t` values along the ray and then finding the $(u,v)$ coordinates for any found intersections, the algorithm here first determines the parametric `u` coordinates of any intersections. Only if any are found within $[0,1]$ are the corresponding `v` and `t` values computed to find the full intersection information.
][
  与三角形一样，独立的射线与双线性面片求交函数便于复用，而不必先构造 `BilinearPatch`。这里先求交点的参数 `u`，而非先求射线参数 `t` 再反求 $(u,v)$。只有找到 $[0,1]$ 内的 `u` 时，才计算对应的 `v` 与 `t`。
]
#block(sticky: true)[#raw("<<Bilinear Patch Inline Functions>>=")] <fragment-BilinearPatchInlineFunctions-0>
```cpp
pstd::optional<BilinearIntersection>
IntersectBilinearPatch(const Ray &ray, Float tMax, Point3f p00, Point3f p10,
                       Point3f p01, Point3f p11) {
    <<Find quadratic coefficients for distance from ray to u iso-lines>>
    <<Solve quadratic for bilinear patch u intersection>>
    <<Find epsilon eps to ensure that candidate t is greater than zero>>
    <<Compute v and t for the first u intersection>>
    <<Compute v and t for the second u intersection>>
    <<Check intersection t against tMax and possibly return intersection>>
}
``` <IntersectBilinearPatch>
#parec[
  Going back to the definition of the bilinear surface, @eqt:blp-definition, we can see that if we fix one of `u` or `v`, then we are left with an equation that defines a line. For example, with `u` fixed, we have
][
  由 @eqt:blp-definition 可知，固定 `u` 或 `v` 后得到一条直线。例如固定 `u`，有
]

$ f_(u)(v)=(1-v)p_(u,0)+v p_(u,1) , $

#parec[
  with
][
  其中
]

$ p_(u,0)&=(1-u)p_(0,0)+u p_(1,0) \
 p_(u,1)&=(1-u)p_(0,1)+u p_(1,1) . $ <bilinear-fu-points>

#parec[
  (See @fig:blp-intersect-fix-u.)
][
  见 @fig:blp-intersect-fix-u 。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f24.svg"), caption: [#ez_caption[Fixing the `u` parameter of a bilinear patch gives a linear function between two opposite edges of the patch.][固定双线性面片的 `u` 参数，得到连接两条对边的线性函数。]]) <blp-intersect-fix-u>

#parec[
  The first step of the intersection test considers the set of all such lines defined by the patch’s vertices. For any intersection, the minimum distance from a point along the ray to a point along one of these lines will be zero. Therefore, we start with the task of trying to find `u` values that give lines with zero distance to a point on the ray.
][
  求交的第一步考虑顶点所定义的全部这类直线。交点存在时，射线与其中一条直线的最小距离必为零，因此先寻找使这一距离为零的 `u`。
]

#parec[
  Given two infinite and non-parallel lines, one defined by the two points $p_a$ and $p_b$ and the other defined by $p_c$ and $p_d$, the minimum distance between them can be found by determining the pair of parallel planes that each contain one of the lines and then finding the distance between them. (See @fig:mindist-two-lines.)
][
  给定由 $p_a,p_b$ 和 $p_c,p_d$ 分别定义的两条无限长且不平行的直线，可找到分别包含它们的两个平行平面；平面间距即两直线的最小距离（见 @fig:mindist-two-lines）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f25.svg"), caption: [#ez_caption[The minimum distance between two lines can be computed by finding two parallel planes that contain each line and then computing the distance between them.][分别包含两条直线的两个平行平面之间的距离，就是两直线的最小距离。]]) <mindist-two-lines>

#parec[
  To find the coefficients of those plane equations, we start by taking the cross product $(p_b-p_a) times (p_d-p_c)$. This gives a vector that is perpendicular to both lines and provides the first three coefficients of the plane equation $a x+b y+c z+d=0$. In turn, the $d_("ab")$ and $d_("cd")$ coefficients can be found for each line’s plane by substituting a point along the respective line into the plane equation and solving for `d`. Because the planes are parallel, the distance between them is then
][
  先取叉积 $(p_b-p_a) times (p_d-p_c)$，得到垂直于两直线的向量，其分量就是平面方程 $a x+b y+c z+d=0$ 的前三个系数。分别将各直线上的一点代入，可求出对应的 $d_("ab")$ 和 $d_("cd")$。由于两平面平行，间距为
]

$ frac(abs(d_("ab")-d_("cd")),sqrt(a^2+b^2+c^2)) . $ <line-line-distance>

#parec[
  In the case of ray–bilinear patch intersection, one line corresponds to the ray and the other to a line from the family of lines given by $f_u$. Given a ray and the bilinear patch vertices, we have $p_a=o$, the ray’s origin, and $p_b$ can be set as the point along the ray $p_b=o+bold(d)$. Then, $p_c$ and $p_d$ can be set as $p_c=p_(u,0)$ and $p_d=p_(u,1)$ from @eqt:bilinear-fu-points. After taking the cross product to find the plane coefficients, finding each `d` value, and simplifying, we can find that $d_("ray")-d_u$ is a quadratic equation in `u`. (That it is quadratic is reassuring, since a ray can intersect a bilinear patch up to two times.)
][
  在射线与面片求交中，一条直线是射线，另一条来自 $f_u$ 所定义的直线族。令 $p_a=o$ 为射线起点、$p_b=o+bold(d)$，再由 @eqt:bilinear-fu-points 取 $p_c=p_(u,0)$、$p_d=p_(u,1)$。求叉积和各平面常数项并化简后，$d_("ray")-d_u$ 是 `u` 的二次式。这与射线最多和面片相交两次一致。
]

#parec[
  Because we only care about finding zeros of the distance function, we can neglect the denominator of @eqt:line-line-distance. After equating the difference $d_("ray")-d_u$ to 0, collecting terms and simplifying, we end up with the following code to compute the quadratic coefficients.#footnote[Note that these are coefficients to the equation $a u^2+b u+c=0$ and not `a`, `b`, and `c` plane coefficients.]
][
  这里只关心距离函数的零点，因此可忽略 @eqt:line-line-distance 的分母。令 $d_("ray")-d_u=0$，合并并化简各项，就得到下面计算二次方程系数的代码。#footnote[这些是方程 $a u^2+b u+c=0$ 的系数，不是平面方程的 `a`、`b`、`c` 系数。]
]
#block(sticky: true)[#raw("<<Find quadratic coefficients for distance from ray to u iso-lines>>=")] <fragment-Findquadraticcoefficientsfordistancefromraytouiso-lines-0>
```cpp
Float a = Dot(Cross(p10 - p00, p01 - p11), ray.d);
Float c = Dot(Cross(p00 - ray.o, ray.d), p01 - p00);
Float b = Dot(Cross(p10 - ray.o, ray.d), p11 - p10) - (a + c);
```
#parec[
  The `u` values where the ray intersects the patch are given by the solution to the corresponding quadratic equation. If there are no real solutions, then there is no intersection and the function returns.
][
  对应二次方程的解给出交点的 `u` 值。若无实根，则没有交点，函数直接返回。
]
#block(sticky: true)[#raw("<<Solve quadratic for bilinear patch u intersection>>=")] <fragment-Solvequadraticforbilinearpatchuintersection-0>
```cpp
Float u1, u2;
if (!Quadratic(a, b, c, &u1, &u2))
    return {};
```
#parec[
  The two `u` values are handled in turn. The first step is to check whether each is between 0 and 1. If not, it does not represent a valid intersection in the patch’s parametric domain. Otherwise, the `v` and `t` values for the intersection point are computed.
][
  依次处理两个 `u` 值。先检查它们是否位于0与1之间；不在此范围就不属于面片参数域，否则继续计算交点的 `v` 和 `t`。
]
#block(sticky: true)[#raw("<<Compute v and t for the first u intersection>>=")] <fragment-Computevandtforthefirstuintersection-0>
```cpp
Float t = tMax, u, v;
if (0 <= u1 && u1 <= 1) {
    <<Precompute common terms for v and t computation>>
    <<Compute matrix determinants for v and t numerators>>
    <<Set u, v, and t if intersection is valid>>
}
```
#parec[
  One way to compute the `v` and `t` values is to find the parametric values along the ray and the line $f_u$ where the distance between them is minimized. Although this distance should be zero since we have determined that there is an intersection between the ray and $f_u$, there may be some round-off error in the computed `u` value. Thus, formulating this computation in terms of minimizing that distance is a reasonable way to make the most of the values at hand.
][
  一种求 `v` 和 `t` 的方法，是找到射线与直线 $f_u$ 上距离最小的那对点的参数。虽然已经确定相交，理论距离应为零，但计算出的 `u` 可能有舍入误差，因此按最小距离来求解，可以合理利用当前数值。
]

#parec[
  With `o` the ray’s origin and $bold(d)$ its direction, the parameter values where the distances are minimized are given by
][
  设射线起点为 `o`，方向为 $bold(d)$，使距离最小的参数为
]

$ t=frac(op("det")(f_(u)(0)-o,f_(u)(1)-f_(u)(0),bold(d) times (f_(u)(1)-f_(u)(0))),norm(bold(d) times (f_(u)(1)-f_(u)(0)))^2) $

#parec[
  and
][
  以及
]

$ v=frac(op("det")(f_(u)(0)-o,bold(d),bold(d) times (f_(u)(1)-f_(u)(0))),norm(bold(d) times (f_(u)(1)-f_(u)(0)))^2) . $

#parec[
  where `det` is shorthand for the determinant of the $3 times 3$ matrix formed from the three column vectors. We will not derive these equations here. The “Further Reading” section has more details.
][
  其中 `det` 表示由三个列向量组成的 $3 times 3$ 矩阵的行列式。这里略去推导，“延伸阅读”提供更多细节。
]

#parec[
  We start by computing a handful of common values that are used in computing the matrix determinants and final parametric values.
][
  先计算行列式和最终参数值所需的一组公共量。
]
#block(sticky: true)[#raw("<<Precompute common terms for v and t computation>>=")] <fragment-Precomputecommontermsforvandtcomputation-0>
```cpp
Point3f uo = Lerp(u1, p00, p10);
Vector3f ud = Lerp(u1, p01, p11) - uo;
Vector3f deltao = uo - ray.o;
Vector3f perp = Cross(ray.d, ud);
Float p2 = LengthSquared(perp);
```
#parec[
  The matrix determinants in the numerators can easily be computed using the `SquareMatrix` class. Note that there are some common subexpressions among the two of them, though we leave it to the compiler to handle them. In a more optimized implementation, writing out the determinant computations explicitly in order to do so manually could be worthwhile.
][
  分子的行列式可直接用 `SquareMatrix` 计算。两者含一些公共子表达式，这里交给编译器处理；若进一步优化，可以显式展开行列式并手动复用这些计算。
]
#block(sticky: true)[#raw("<<Compute matrix determinants for v and t numerators>>=")] <fragment-Computematrixdeterminantsforvandtnumerators-0>
```cpp
Float v1 = Determinant(SquareMatrix<3>(deltao.x, ray.d.x, perp.x,
                                       deltao.y, ray.d.y, perp.y,
                                       deltao.z, ray.d.z, perp.z));
Float t1 = Determinant(SquareMatrix<3>(deltao.x, ud.x, perp.x,
                                       deltao.y, ud.y, perp.y,
                                       deltao.z, ud.z, perp.z));
```
#parec[
  Due to round-off error, it is possible that the computed `t` distance is positive and seemingly represents a valid intersection even though the true value of `t` is negative and corresponds to a point behind the ray’s origin. Testing `t` against an epsilon value (which is discussed further in Section 6.8.7) helps avoid reporting incorrect intersections in such cases. Because we defer the division to compute the final `t` value, it is necessary to test `t1` against `p2 * eps` here.
][
  舍入误差可能使真实 `t` 为负、位于射线起点后方的点被算成正 `t`。将 `t` 与一个小阈值比较，有助于避免这类错误，6.8.7节将进一步讨论。由于还未执行求最终 `t` 的除法，这里要比较 `t1` 与 `p2 * eps`。
]
#block(sticky: true)[#raw("<<Set u, v, and t if intersection is valid>>=")] <fragment-Setmonoumonovandmonotifintersectionisvalid-0>
```cpp
if (t1 > p2 * eps && 0 <= v1 && v1 <= p2) {
    u = u1;
    v = v1 / p2;
    t = t1 / p2;
}
```
#parec[
  The second `u` root is handled with equivalent code, though with added logic to keep the closer of the intersections if there are two of them. That fragment is not included here. If the final closest `t` value is less than the given `tMax`, then an intersection is returned.
][
  第二个 `u` 根的处理类似，但若存在两个交点，还要保留较近者，正文略去这一片段。最终最近交点的 `t` 小于 `tMax` 时，返回交点。
]
#block(sticky: true)[#raw("<<Check intersection t against tMax and possibly return intersection>>=")] <fragment-CheckintersectiontagainstmonotMaxandpossiblyreturnintersection-0>
```cpp
if (t >= tMax)
    return {};
return BilinearIntersection{{u, v}, t};
```
#parec[
  The $(u,v)$ coordinates and ray parametric `t` value are sufficient to encapsulate the intersection so that the rest of its geometric properties can be computed later.
][
  $(u,v)$ 坐标与射线参数 `t` 足以表示交点，其余几何量可稍后计算。
]
#block(sticky: true)[#raw("<<BilinearIntersection Definition>>=")] <fragment-BilinearIntersectionDefinition-0>
```cpp
struct BilinearIntersection {
    Point2f uv;
    Float t;
};
``` <BilinearIntersection>
#parec[
  The `InteractionFromIntersection()` method computes all the geometric information necessary to return the `SurfaceInteraction` corresponding to a specified $(u,v)$ point on a bilinear patch, as is found by the intersection routine.
][
  `InteractionFromIntersection()` 根据求交例程得到的 $(u,v)$，计算返回对应 `SurfaceInteraction` 所需的全部几何量。
]
#block(sticky: true)[#raw("<<BilinearPatch Public Methods>>+=")] <fragment-BilinearPatchPublicMethods-1>
```cpp
static SurfaceInteraction InteractionFromIntersection(
        const BilinearPatchMesh *mesh, int blpIndex, Point2f uv,
        Float time, Vector3f wo) {
    <<Compute bilinear patch point p , ∂p/∂u , and ∂p/∂v for (u, v) >>
    <<Compute (s, t) texture coordinates at bilinear patch (u, v) >>
    <<Find partial derivatives ∂n/∂u and ∂n/∂v for bilinear patch>>
    <<Initialize bilinear patch intersection point error pError>>
    <<Initialize SurfaceInteraction for bilinear patch intersection>>
    <<Compute bilinear patch shading normal if necessary>>
    return isect;
}
```
#parec[
  Given the parametric $(u,v)$ coordinates of an intersection point, it is easy to compute the corresponding point on the bilinear patch using @eqt:blp-definition and its partial derivatives with @eqt:blp-dpdu-dpdv.
][
  给定交点参数 $(u,v)$，用 @eqt:blp-definition 求面片位置，再用 @eqt:blp-dpdu-dpdv 求偏导数。
]
#block(sticky: true)[#raw("<<Compute bilinear patch point p , ∂p/∂u , and ∂p/∂v for (u, v) >>=")] <fragment-Computebilinearpatchpointptdpduanddpdvforuv-0>
```cpp
<<Get bilinear patch vertices in p00, p01, p10, and p11>>
Point3f p = Lerp(uv[0], Lerp(uv[1], p00, p01), Lerp(uv[1], p10, p11));
Vector3f dpdu = Lerp(uv[1], p10, p11) - Lerp(uv[1], p00, p01);
Vector3f dpdv = Lerp(uv[0], p01, p11) - Lerp(uv[0], p00, p10);
```
#parec[
  If per-vertex texture coordinates have been specified, then they, too, are interpolated at the intersection point. Otherwise, the parametric $(u,v)$ coordinates are used for texture mapping. For the remainder of this method, we will denote the texture coordinates as $(s,t)$ to distinguish them from the patch’s $(u,v)$ parameterization. (Because this method does not use the parametric `t` distance along the ray, this notation is unambiguous.) Variables are also defined here to store the partial derivatives between the two sets of coordinates: $frac(∂u,∂s)$, $frac(∂u,∂t)$, $frac(∂v,∂s)$, and $frac(∂v,∂t)$. These are initialized for now to the appropriate values for when $(s,t)=(u,v)$.
][
  若提供了逐顶点纹理坐标，也在交点处进行插值；否则直接用参数 $(u,v)$。为区分二者，以下将纹理坐标记作 $(s,t)$；本方法不用射线参数 `t`，因此没有歧义。同时定义两组坐标间的偏导数 $frac(∂u,∂s)$、$frac(∂u,∂t)$、$frac(∂v,∂s)$、$frac(∂v,∂t)$，先按 $(s,t)=(u,v)$ 初始化。
]
#block(sticky: true)[#raw("<<Compute (s, t) texture coordinates at bilinear patch (u, v) >>=")] <fragment-Computesttexturecoordinatesatbilinearpatchuv-0>
```cpp
Point2f st = uv;
Float duds = 1, dudt = 0, dvds = 0, dvdt = 1;
if (mesh->uv) {
    <<Compute texture coordinates for bilinear patch intersection point>>
    <<Update bilinear patch ∂p/∂u and ∂p/∂v accounting for (s, t) >>
}
```
#parec[
  If per-vertex texture coordinates have been specified, they are bilinearly interpolated in the usual manner.
][
  若指定了逐顶点纹理坐标，就进行通常的双线性插值。
]
#block(sticky: true)[#raw("<<Compute texture coordinates for bilinear patch intersection point>>=")] <fragment-Computetexturecoordinatesforbilinearpatchintersectionpoint-0>
```cpp
Point2f uv00 = mesh->uv[v[0]], uv10 = mesh->uv[v[1]];
Point2f uv01 = mesh->uv[v[2]], uv11 = mesh->uv[v[3]];
st = Lerp(uv[0], Lerp(uv[1], uv00, uv01), Lerp(uv[1], uv10, uv11));
```
#parec[
  Because the partial derivatives $frac(∂p,∂u)$ and $frac(∂p,∂v)$ in the `SurfaceInteraction` are in terms of the $(u,v)$ parameterization used for texturing, these values must be updated if texture coordinates have been specified.
][
  `SurfaceInteraction` 中的两个位置偏导数必须相对于纹理参数化，因此若另行指定了纹理坐标，就需更新它们。
]
#block(sticky: true)[#raw("<<Update bilinear patch ∂p/∂u and ∂p/∂v accounting for (s, t) >>=")] <fragment-Updatebilinearpatchdpduanddpdvaccountingforst-0>
```cpp
<<Compute partial derivatives of (u, v) with respect to (s, t) >>
<<Compute partial derivatives of p with respect to (s, t) >>
<<Set dpdu and dpdv to updated partial derivatives>>
```
#parec[
  The first step is to compute the updated partial derivatives $frac(∂u,∂s)$ and so forth. These can be found by first taking the corresponding partial derivatives of the bilinear interpolation used to compute $(s,t)$ to find $frac(∂(s,t),∂u)$ and $frac(∂(s,t),∂v)$. (Note the similar form to how the partial derivatives of `p` were computed earlier.) The desired partial derivatives can be found by taking reciprocals.
][
  首先求更新后的 $frac(∂u,∂s)$ 等偏导数。对计算 $(s,t)$ 的双线性插值求导，得到 $frac(∂(s,t),∂u)$ 和 $frac(∂(s,t),∂v)$，形式与前面位置偏导数相同。原文随后通过取倒数求所需偏导数。
]
#block(sticky: true)[#raw("<<Compute partial derivatives of (u, v) with respect to (s, t) >>=")] <fragment-Computepartialderivativesofuvwithrespecttost-0>
```cpp
Vector2f dstdu = Lerp(uv[1], uv10, uv11) - Lerp(uv[1], uv00, uv01);
Vector2f dstdv = Lerp(uv[0], uv01, uv11) - Lerp(uv[0], uv00, uv10);
duds = std::abs(dstdu[0]) < 1e-8f ? 0 : 1 / dstdu[0];
dvds = std::abs(dstdv[0]) < 1e-8f ? 0 : 1 / dstdv[0];
dudt = std::abs(dstdu[1]) < 1e-8f ? 0 : 1 / dstdu[1];
dvdt = std::abs(dstdv[1]) < 1e-8f ? 0 : 1 / dstdv[1];
```
#parec[
  Given the partial derivatives, the chain rule can be applied to compute the updated partial derivatives of position. For example,
][
  给定这些偏导数后，用链式法则更新位置偏导数。例如，
]

$ frac(∂p,∂s)=frac(∂p,∂u) frac(∂u,∂s)+frac(∂p,∂v) frac(∂v,∂s) , $

#parec[
  and similarly for $frac(∂p,∂t)$.
][
  $frac(∂p,∂t)$ 同理。
]
#block(sticky: true)[#raw("<<Compute partial derivatives of p with respect to (s, t) >>=")] <fragment-Computepartialderivativesofptwithrespecttost-0>
```cpp
Vector3f dpds = dpdu * duds + dpdv * dvds;
Vector3f dpdt = dpdu * dudt + dpdv * dvdt;
```
#parec[
  If the provided texture coordinates specify a degenerate mapping, $frac(∂p,∂s)$ or $frac(∂p,∂t)$ may be zero. In that case, `dpdu` and `dpdv` are left unchanged, as at least their cross product provides a correct normal vector. A dot product checks that the normal given by $frac(∂p,∂s) times frac(∂p,∂t)$ lies in the same hemisphere as the normal given by the cross product of the original partial derivatives of `p`, flipping $frac(∂p,∂t)$ if necessary. Finally, `dpdu` and `dpdv` can be updated.
][
  若纹理坐标映射退化，$frac(∂p,∂s)$ 或 $frac(∂p,∂t)$ 可能为零，此时保留原 `dpdu` 与 `dpdv`，至少它们的叉积仍给出正确法向量。代码还用点积检查新旧偏导数的叉积是否位于同一半球，必要时翻转 $frac(∂p,∂t)$，最后再更新 `dpdu`、`dpdv`。
]
#block(sticky: true)[#raw("<<Set dpdu and dpdv to updated partial derivatives>>=")] <fragment-Setmonodpduandmonodpdvtoupdatedpartialderivatives-0>
```cpp
if (Cross(dpds, dpdt) != Vector3f(0, 0, 0)) {
    if (Dot(Cross(dpdu, dpdv), Cross(dpds, dpdt)) < 0)
        dpdt = -dpdt;
    dpdu = dpds;
    dpdv = dpdt;
}
```
#parec[
  The second partial derivatives of `p` are easily found to compute the partial derivatives of the surface normal; all but $frac(∂^2 p,∂u ∂v)$ are zero vectors. Thence, the partial derivatives of the normal can be computed using the regular approach. These are then adjusted to account for the $(s,t)$ parameterization in the same way that $frac(∂p,∂u)$ and $frac(∂p,∂v)$ were. The corresponding fragment follows the same form as ⟨Compute partial derivatives of p with respect to (s, t)⟩ and is therefore not included here.
][
  为求法向量偏导数，先求位置的二阶偏导数；除 $frac(∂^2 p,∂u ∂v)$ 外，其余均为零向量。然后按通常方法求法向量偏导数，并像位置偏导数一样，按 $(s,t)$ 参数化调整。对应片段与 ⟨Compute partial derivatives of p with respect to (s, t)⟩ 形式相同，正文不再列出。
]
#block(sticky: true)[#raw("<<Find partial derivatives ∂n/∂u and ∂n/∂v for bilinear patch>>=")] <fragment-Findpartialderivativesdnduanddndvforbilinearpatch-0>
```cpp
Vector3f d2Pduu(0, 0, 0), d2Pdvv(0, 0, 0);
Vector3f d2Pduv = (p00 - p01) + (p11 - p10);
<<Compute coefficients for fundamental forms>>
<<Compute ∂n/∂u and ∂n/∂v from fundamental form coefficients>>
<<Update ∂n/∂u and ∂n/∂v to account for (s, t) parameterization>>
```
#parec[
  All the necessary information for initializing the `SurfaceInteraction` is now at hand.
][
  现在已有初始化 `SurfaceInteraction` 所需的全部信息。
]
#block(sticky: true)[#raw("<<Initialize SurfaceInteraction for bilinear patch intersection>>=")] <fragment-InitializemonoSurfaceInteractionforbilinearpatchintersection-0>
```cpp
bool flipNormal = mesh->reverseOrientation ^ mesh->transformSwapsHandedness;
SurfaceInteraction isect(Point3fi(p, pError), st, wo, dpdu, dpdv,
                         dndu, dndv, time, flipNormal);
```
#parec[
  Shading geometry is set in the `SurfaceInteraction` after it is created. Therefore, per-vertex shading normals are handled next.
][
  创建 `SurfaceInteraction` 后再设置着色几何，因此接下来处理逐顶点着色法向量。
]
#block(sticky: true)[#raw("<<Compute bilinear patch shading normal if necessary>>=")] <fragment-Computebilinearpatchshadingnormalifnecessary-0>
```cpp
if (mesh->n) {
    <<Compute shading normals for bilinear patch intersection point>>
}
```
#parec[
  The usual bilinear interpolation is performed and if the resulting normal is non-degenerate, the shading geometry is provided to the `SurfaceInteraction`.
][
  先进行通常的双线性插值，若所得法向量非退化，则将着色几何提供给 `SurfaceInteraction`。
]
#block(sticky: true)[#raw("<<Compute shading normals for bilinear patch intersection point>>=")] <fragment-Computeshadingnormalsforbilinearpatchintersectionpoint-0>
```cpp
Normal3f n00 = mesh->n[v[0]], n10 = mesh->n[v[1]];
Normal3f n01 = mesh->n[v[2]], n11 = mesh->n[v[3]];
Normal3f ns = Lerp(uv[0], Lerp(uv[1], n00, n01), Lerp(uv[1], n10, n11));
if (LengthSquared(ns) > 0) {
    ns = Normalize(ns);
    <<Set shading geometry for bilinear patch intersection>>
}
```
#parec[
  The partial derivatives of the shading normal are computed in the same manner as the partial derivatives of `p` were found, including the adjustment for the parameterization given by per-vertex texture coordinates, if provided. Because shading geometry is specified via shading $frac(∂p,∂u)$ and $frac(∂p,∂v)$ vectors, here we find the rotation matrix that takes the geometric normal to the shading normal and apply it to `dpdu` and `dpdv`. The cross product of the resulting vectors then gives the shading normal.
][
  着色法向量的偏导数与位置偏导数同样计算，若提供了纹理坐标，也按其参数化调整。着色几何通过两个着色位置偏导向量指定，因此先求将几何法向量转到着色法向量的旋转，再应用于 `dpdu`、`dpdv`，使所得向量的叉积给出着色法向量。
]
#block(sticky: true)[#raw("<<Set shading geometry for bilinear patch intersection>>=")] <fragment-Setshadinggeometryforbilinearpatchintersection-0>
```cpp
Normal3f dndu = Lerp(uv[1], n10, n11) - Lerp(uv[1], n00, n01);
Normal3f dndv = Lerp(uv[0], n01, n11) - Lerp(uv[0], n00, n10);
<<Update ∂n/∂u and ∂n/∂v to account for (s, t) parameterization>>
Transform r = RotateFromTo(Vector3f(Normalize(isect.n)), Vector3f(ns));
isect.SetShadingGeometry(ns, r(dpdu), r(dpdv), dndu, dndv, true);
```
#parec[
  Given the intersection and `InteractionFromIntersection()` methods, both of the `BilinearPatch::Intersect()` and `IntersectP()` methods are easy to implement. Since they both follow what should be by now a familiar form, we have not included them here.
][
  有了求交与交点转换方法，`BilinearPatch::Intersect()` 和 `IntersectP()` 都能按前面熟悉的形式实现，故正文不再列出。
]

=== #ez_caption[Sampling][采样]
<bilinear-patch-sampling>

#parec[
  The sampling routines for bilinear patches select between sampling algorithms depending on the characteristics of the patch. For area sampling, both rectangular patches and patches that have an emission distribution defined by an image map are given special treatment. When sampling by solid angle from a reference point, rectangular patches are projected on to the sphere and sampled as spherical rectangles. For both cases, general-purpose sampling routines are used otherwise.
][
  双线性面片根据自身特性选择采样方法。面积采样会专门处理矩形面片及发射分布由图像定义的面片；相对于参考点进行立体角采样时，则把矩形投影到球面，作为球面矩形采样。其他情况采用通用方法。
]

#parec[
  The area sampling method first samples parametric $(u,v)$ coordinates, from which the rest of the necessary geometric values are derived.
][
  面积采样先选参数 $(u,v)$，再由此计算其他所需几何量。
]
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>+=")] <fragment-BilinearPatchMethodDefinitions-3>
```cpp
pstd::optional<ShapeSample> BilinearPatch::Sample(Point2f u) const {
    const BilinearPatchMesh *mesh = GetMesh();
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    <<Sample bilinear patch parametric (u, v) coordinates>>
    <<Compute bilinear patch geometric quantities at sampled (u, v) >>
    <<Return ShapeSample for sampled bilinear patch point>>
}
```
#parec[
  While all the `Shape` implementations we have implemented so far can be used as area light sources, none of their sampling routines have accounted for the fact that `pbrt`’s `DiffuseAreaLight` allows specifying an image that is used to represent spatially varying emission over the shape’s $(u,v)$ surface. Because such emission profiles are most frequently used with rectangular light sources, the `BilinearPatch` has the capability of sampling in $(u,v)$ according to the emission function. @fig:area-sampling-image-emission demonstrates the value of doing so.
][
  前面所有形状都可用作面光源，但采样尚未考虑 `DiffuseAreaLight` 可用图像定义随 $(u,v)$ 变化的发射分布。这种发射方式最常用于矩形光源，因此 `BilinearPatch` 支持根据发射函数采样 $(u,v)$。@fig:area-sampling-image-emission 展示了其益处。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f26.svg"), caption: [#ez_caption[Area Sampling Accounting for Image-Based Emission. For a scene with an emissive bilinear patch where the amount of emission varies across the patch based on an image, (a) uniformly sampling in the patch’s $(u,v)$ parametric space leads to high variance since some samples have much higher contributions than others. (b) Sampling according to the image’s distribution of brightness gives a significantly better result for the same number of rays. Here, MSE is improved by a factor of 2.28. (Bunny model courtesy of the Stanford Computer Graphics Laboratory.)][考虑图像发射分布的面积采样。面片的发射量随图像变化时，(a)均匀采样 $(u,v)$ 会因部分样本贡献远高于其他样本而产生高方差；(b)按图像明暗分布采样，在射线数相同时结果明显改善。本例 MSE 降至原来的1/2.28。（兔子模型由斯坦福计算机图形实验室提供。）]]) <area-sampling-image-emission>

#parec[
  Otherwise, if the patch is not a rectangle, an approximation to uniform area sampling is used. If it is a rectangle, then uniform area sampling is trivial and the provided sample value is used directly for $(u,v)$. In all of these cases, the `pdf` value is with respect to the $(u,v)$ parametric domain over $[0,1)^2$.
][
  没有图像发射分布时，非矩形采用近似均匀面积采样，矩形则直接把输入样本作为 $(u,v)$。这些分支得到的 `pdf` 都是以 $[0,1)^2$ 参数域为测度的密度。
]
#block(sticky: true)[#raw("<<Sample bilinear patch parametric (u, v) coordinates>>=")] <fragment-Samplebilinearpatchparametricuvcoordinates-0>
```cpp
Float pdf = 1;
Point2f uv;
if (mesh->imageDistribution)
    uv = mesh->imageDistribution->Sample(u, &pdf);
else if (!IsRectangle(mesh)) {
    <<Sample patch (u, v) with approximate uniform area sampling>>
} else
    uv = u;
```
#block(sticky: true)[#raw("<<BilinearPatchMesh Public Members>>+=")] <fragment-BilinearPatchMeshPublicMembers-1>
```cpp
PiecewiseConstant2D *imageDistribution;
```
#parec[
  For patches without an emissive image to sample from, we would like to uniformly sample over their surface area, as we have done with all the shapes so far. Unfortunately, an exact equal-area sampling algorithm cannot be derived for bilinear patches. This is a consequence of the fact that it is not possible to integrate the expression that gives the area of a bilinear patch, @eqt:parametric-surface-area.
][
  对于没有发射图像的面片，希望像前面的形状一样均匀采样表面积。但原文指出，由于无法对 @eqt:parametric-surface-area 求出面积积分，不能推导出精确的等面积采样算法。
]

#parec[
  It is easy to uniformly sample in parametric $(u,v)$ space, but doing so can give a poor distribution of samples, especially for bilinear patches where two vertices are close together and the others are far apart. @fig:blp-parametric-sampling shows such a patch as well as the distribution of points that results from uniform parametric sampling. While the nonuniform distribution of points can be accounted for in the PDF such that Monte Carlo estimates using such samples still converge to the correct result, the resulting estimators will generally have higher error than if a more uniform distribution is used.
][
  均匀采样参数 $(u,v)$ 很容易，但样本在曲面上的分布可能很差，尤其当两顶点接近、另外两顶点相距很远时，见 @fig:blp-parametric-sampling 。虽然可以在 PDF 中计入非均匀性，使蒙特卡洛估计仍收敛到正确结果，但通常比更均匀的分布误差大。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f27.svg"), caption: [#ez_caption[Nonuniform Sample Distribution from Uniform Parametric Sampling. (a) When a bilinear patch is sampled uniformly in $(u,v)$, the sample points are denser close to pairs of nearby vertices. (b) When using an approximate equal-area distribution, the points are more uniformly distributed over the patch.][均匀参数采样产生的非均匀样本分布。(a)均匀采样 $(u,v)$ 时，样本在彼此接近的顶点附近更密集。(b)采用近似等面积分布后，曲面上的样本更均匀。]]) <blp-parametric-sampling>

#parec[
  An exact equal-area sampling algorithm would sample points `p` with probability proportional to its differential surface area $norm(frac(∂p,∂u) times frac(∂p,∂v))$. Lacking the ability to sample directly from this distribution, we will approximate it with a bilinear function where the value of the function at each corner is given by the patch’s differential surface area there. Sampling a $(u,v)$ location from that distribution generally works well to approximate exact equal-area sampling; see @fig:blp-diff-area-and-approximation.
][
  精确等面积采样应让参数点的密度正比于面积微元因子 $norm(frac(∂p,∂u) times frac(∂p,∂v))$。无法直接采样这一分布时，就用双线性函数近似，其四个角点值取面片在相应位置的面积微元因子。按该分布采样 $(u,v)$，通常能较好地近似等面积采样，见 @fig:blp-diff-area-and-approximation 。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f28.svg"), caption: [#ez_caption[Plot of differential area $norm(frac(∂p,∂u) times frac(∂p,∂v))$ in parametric space for the bilinear patch shown in @fig:blp-parametric-sampling. Although the differential area is not a bilinear function, a bilinear fit to it has low error and is easy to draw samples from.][@fig:blp-parametric-sampling 所示面片在参数域中的面积微元因子 $norm(frac(∂p,∂u) times frac(∂p,∂v))$。虽然它不是双线性函数，双线性拟合的误差较低，而且易于采样。]]) <blp-diff-area-and-approximation>
#block(sticky: true)[#raw("<<Sample patch (u, v) with approximate uniform area sampling>>=")] <fragment-Samplepatchuvwithapproximateuniformareasampling-0>
```cpp
<<Initialize w array with differential area at bilinear patch corners>>
uv = SampleBilinear(u, w);
pdf = BilinearPDF(uv, w);
```
#parec[
  It is especially easy to compute the partial derivatives at the patch corners; they are just differences with the adjacent vertices.
][
  角点处的偏导数特别容易计算，就是与相邻顶点之差。
]
#block(sticky: true)[#raw("<<Initialize w array with differential area at bilinear patch corners>>=")] <fragment-Initializemonowarraywithdifferentialareaatbilinearpatchcorners-0>
```cpp
pstd::array<Float, 4> w = {
    Length(Cross(p10 - p00, p01 - p00)),
    Length(Cross(p10 - p00, p11 - p10)),
    Length(Cross(p01 - p00, p11 - p01)),
    Length(Cross(p11 - p10, p11 - p01)) };
```
#parec[
  Given a $(u,v)$ position on the patch, the corresponding position, partial derivatives, and surface normal can all be computed, following the same approach as was implemented in `InteractionFromIntersection()`. The fragment ⟨Compute p, ∂p/∂u, and ∂p/∂v for sampled (u, v)⟩ is therefore not included here, and $(s,t)$ texture coordinates for the sampled point are computed using a fragment defined earlier.
][
  给定 $(u,v)$ 后，可沿用 `InteractionFromIntersection()` 的方法求位置、偏导数及法向量，因此正文不再列出相应计算片段。采样点的 $(s,t)$ 纹理坐标也复用前面定义的片段。
]
#block(sticky: true)[#raw("<<Compute bilinear patch geometric quantities at sampled (u, v) >>=")] <fragment-Computebilinearpatchgeometricquantitiesatsampleduv-0>
```cpp
<<Compute p , ∂p/∂u , and ∂p/∂v for sampled (u, v) >>
Point2f st = uv;
if (mesh->uv) {
    <<Compute texture coordinates for bilinear patch intersection point>>
}
<<Compute surface normal for sampled bilinear patch (u, v) >>
<<Compute pError for sampled bilinear patch (u, v) >>
```
#parec[
  Only the geometric normal is needed for sampled points. It is easily found via the cross product of partial derivatives of the position. The ⟨Flip normal at sampled (u, v) if necessary⟩ fragment negates the normal if necessary, depending on the mesh properties and shading normals, if present. It follows the same form as earlier fragments that orient the geometric normal based on the shading normal, if present, and otherwise the `reverseOrientation` and `transformSwapsHandedness` properties of the mesh.
][
  采样点只需几何法向量，可由位置偏导数的叉积求得。⟨Flip normal at sampled (u, v) if necessary⟩ 依照网格属性和着色法向量决定是否翻转：有着色法向量时以其为准，否则依据 `reverseOrientation` 与 `transformSwapsHandedness`。
]
#block(sticky: true)[#raw("<<Compute surface normal for sampled bilinear patch (u, v) >>=")] <fragment-Computesurfacenormalforsampledbilinearpatchuv-0>
```cpp
Normal3f n = Normal3f(Normalize(Cross(dpdu, dpdv)));
<<Flip normal at sampled (u, v) if necessary>>
```
#parec[
  The PDF value stored in `pdf` gives the probability of sampling the position `uv` in parametric space. In order to return a PDF defined with respect to the patch’s surface area, it is necessary to account for the corresponding change of variables, which results in an additional factor of $1/norm(frac(∂p,∂u) times frac(∂p,∂v))$.
][
  `pdf` 保存参数空间中采样 `uv` 的密度。返回以面片面积为测度的 PDF 时，必须计入变量变换，乘以 $frac(1,norm(frac(∂p,∂u) times frac(∂p,∂v)))$。
]
#block(sticky: true)[#raw("<<Return ShapeSample for sampled bilinear patch point>>=")] <fragment-ReturnmonoShapeSampleforsampledbilinearpatchpoint-0>
```cpp
return ShapeSample{Interaction(Point3fi(p, pError), n, st),
                   pdf / Length(Cross(dpdu, dpdv))};
```
#parec[
  The PDF for sampling a given point on a bilinear patch is found by first computing the probability density for sampling its $(u,v)$ position in parametric space and then transforming that density to be with respect to the patch’s surface area.
][
  给定面片上的点，先求参数 $(u,v)$ 的采样密度，再变换为面积密度，就得到其 PDF。
]
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>+=")] <fragment-BilinearPatchMethodDefinitions-4>
```cpp
Float BilinearPatch::PDF(const Interaction &intr) const {
    const BilinearPatchMesh *mesh = GetMesh();
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    <<Compute parametric (u, v) of point on bilinear patch>>
    <<Compute PDF for sampling the (u, v) coordinates given by intr.uv>>
    <<Find ∂p/∂u and ∂p/∂v at bilinear patch (u, v) >>
    <<Return final bilinear patch area sampling PDF>>
}
```
#parec[
  If $(u,v)$ coordinates have been specified at the vertices of a bilinear patch, then the member variable `Interaction::uv` stores interpolated texture coordinates. In the following, we will need the parametric $(u,v)$ coordinates over the patch’s $[0,1]^2$ domain, which can be found via a call to `InvertBilinear()`.
][
  若面片顶点带有纹理坐标，`Interaction::uv` 存的是插值后的纹理坐标。这里需要的是 $[0,1]^2$ 上的面片参数坐标，可用 `InvertBilinear()` 反求。
]
#block(sticky: true)[#raw("<<Compute parametric (u, v) of point on bilinear patch>>=")] <fragment-Computeparametricuvofpointonbilinearpatch-0>
```cpp
Point2f uv = intr.uv;
if (mesh->uv) {
    Point2f uv00 = mesh->uv[v[0]], uv10 = mesh->uv[v[1]];
    Point2f uv01 = mesh->uv[v[2]], uv11 = mesh->uv[v[3]];
    uv = InvertBilinear(uv, {uv00, uv10, uv01, uv11});
}
```
#parec[
  Regardless of which $(u,v)$ sampling technique is used for a bilinear patch, finding the PDF for a $(u,v)$ sample is straightforward.
][
  无论采用哪种参数域采样方法，对应 PDF 都很容易求得。
]
#block(sticky: true)[#raw("<<Compute PDF for sampling the (u, v) coordinates given by intr.uv>>=")] <fragment-ComputePDFforsamplingtheuvcoordinatesgivenbymonointr.uv-0>
```cpp
Float pdf;
if (mesh->imageDistribution)
    pdf = mesh->imageDistribution->PDF(uv);
else if (!IsRectangle(mesh)) {
    <<Initialize w array with differential area at bilinear patch corners>>
    pdf = BilinearPDF(uv, w);
} else
    pdf = 1;
```
#parec[
  The partial derivatives are computed from $(u,v)$ as they have been before and so we omit the corresponding fragment. Given `dpdu` and `dpdv`, the same scaling factor as was used in `Sample()` is used to transform the PDF.
][
  由 $(u,v)$ 求偏导数的过程与之前相同，略去对应片段。然后使用与 `Sample()` 相同的比例因子变换 PDF。
]
#block(sticky: true)[#raw("<<Return final bilinear patch area sampling PDF>>=")] <fragment-ReturnfinalbilinearpatchareasamplingPDF-0>
```cpp
return pdf / Length(Cross(dpdu, dpdv));
```
#parec[
  The solid angle sampling method handles general bilinear patches with the same approach that was used for `Cylinder`s and `Disk`s: a sample is taken with respect to surface area on the surface using the first sampling method and is returned with a probability density expressed in terms of solid angle. Rectangular patches are handled using a specialized sampling technique that gives better results.
][
  一般双线性面片采用与圆柱、圆盘相同的立体角采样方式：先按第一个方法采样表面面积，再将密度表示为立体角密度。矩形面片则采用效果更好的专门算法。
]
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>+=")] <fragment-BilinearPatchMethodDefinitions-5>
```cpp
pstd::optional<ShapeSample>
BilinearPatch::Sample(const ShapeSampleContext &ctx, Point2f u) const {
    const BilinearPatchMesh *mesh = GetMesh();
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    <<Sample bilinear patch with respect to solid angle from reference point>>
}
```
#parec[
  If the patch is not a rectangle, is very small, or has a sampling distribution associated with it to match textured emission, then the regular area sampling method is used and the PDF with respect to area is converted to be with respect to solid angle. Otherwise, a specialized solid angle sampling technique is used.
][
  如果面片不是矩形、所张立体角很小，或带有匹配纹理发射的采样分布，就使用普通面积采样并换算为立体角密度；否则使用专门的立体角采样。
]
#block(sticky: true)[#raw("<<Sample bilinear patch with respect to solid angle from reference point>>=")] <fragment-Samplebilinearpatchwithrespecttosolidanglefromreferencepoint-0>
```cpp
Vector3f v00 = Normalize(p00 - ctx.p()), v10 = Normalize(p10 - ctx.p());
Vector3f v01 = Normalize(p01 - ctx.p()), v11 = Normalize(p11 - ctx.p());
if (!IsRectangle(mesh) || mesh->imageDistribution ||
    SphericalQuadArea(v00, v10, v11, v01) <= MinSphericalSampleArea) {
    <<Sample shape by area and compute incident direction wi>>
    <<Convert area sampling PDF in ss to solid angle measure>>
    return ss;
}
<<Sample direction to rectangular bilinear patch>>
```
#block(sticky: true)[#raw("<<BilinearPatch Private Members>>+=")] <fragment-BilinearPatchPrivateMembers-3>
```cpp
static constexpr Float MinSphericalSampleArea = 1e-4;
```
#parec[
  Rectangular patches are projected on the sphere to form a spherical rectangle that can then be sampled directly. Doing so gives similar benefits to sampling spherical triangles, as was implemented in Section 6.5.4.
][
  矩形面片投影到球面后形成球面矩形，可以直接采样，其收益类似于6.5.4节的球面三角形采样。
]
#block(sticky: true)[#raw("<<Sample direction to rectangular bilinear patch>>=")] <fragment-Sampledirectiontorectangularbilinearpatch-0>
```cpp
Float pdf = 1;
<<Warp uniform sample u to account for incident cos theta factor>>
<<Sample spherical rectangle at reference point>>
<<Compute (u, v) and surface normal for sampled point on rectangle>>
<<Compute (s, t) texture coordinates for sampled (u, v) >>
return ShapeSample{Interaction(p, n, ctx.time, st), pdf};
```
#parec[
  Also as with triangles, we incorporate an approximation to the $cos theta$ factor at the reference point by warping the uniform sample `u` using a bilinear approximation to the $cos theta$ function in the $[0,1]^2$ sampling space.
][
  与三角形一样，我们用 $[0,1]^2$ 采样域中余弦函数的双线性近似来变换均匀样本 `u`，从而近似计入参考点处的 $cos theta$ 因子。
]
#block(sticky: true)[#raw("<<Warp uniform sample u to account for incident cos theta factor>>=")] <fragment-Warpuniformsamplemonoutoaccountforincidentcosthetafactor-0>
```cpp
if (ctx.ns != Normal3f(0, 0, 0)) {
    <<Compute cos theta weights for rectangle seen from reference point>>
    u = SampleBilinear(u, w);
    pdf *= BilinearPDF(u, w);
}
```
#parec[
  The spherical rectangle sampling algorithm maintains the relationship between each corner of the $[0,1]^2$ sampling space and the corresponding corner of the patch in its parametric space. Therefore, each bilinear sampling weight is set using the $cos theta$ factor to the corresponding vertex of the patch.
][
  球面矩形采样保持采样域角点与面片对应角点之间的关系，因此双线性采样权重由指向对应顶点的方向余弦给出。
]
#block(sticky: true)[#raw("<<Compute cos theta weights for rectangle seen from reference point>>=")] <fragment-Computecosthetaweightsforrectangleseenfromreferencepoint-0>
```cpp
pstd::array<Float, 4> w = pstd::array<Float, 4>{
    std::max<Float>(0.01, AbsDot(v00, ctx.ns)),
    std::max<Float>(0.01, AbsDot(v10, ctx.ns)),
    std::max<Float>(0.01, AbsDot(v01, ctx.ns)),
    std::max<Float>(0.01, AbsDot(v11, ctx.ns))};
```
#parec[
  In addition to the sample `u`, `SampleSphericalRectangle()` takes a reference point, the $(0,0)$ corner of the rectangle, and two vectors that define its edges. It returns a point on the patch and the sampling PDF, which is one over the solid angle that it subtends.
][
  `SampleSphericalRectangle()` 除样本 `u` 外，还接收参考点、矩形的 $(0,0)$ 角点及两条边向量。它返回面片上的点和 PDF，后者等于所张立体角的倒数。
]
#block(sticky: true)[#raw("<<Sample spherical rectangle at reference point>>=")] <fragment-Samplesphericalrectangleatreferencepoint-0>
```cpp
Vector3f eu = p10 - p00, ev = p01 - p00;
Float quadPDF;
Point3f p = SampleSphericalRectangle(ctx.p(), p00, eu, ev, u, &quadPDF);
pdf *= quadPDF;
```
#parec[
  The implementation of the `SampleSphericalRectangle()` function is another interesting exercise in spherical trigonometry, like `SampleSphericalTriangle()` was. However, in the interests of space, we will not include discussion of its implementation here; the “Further Reading” section has a pointer to the paper that introduced the approach and describes its derivation.
][
  与 `SampleSphericalTriangle()` 一样，`SampleSphericalRectangle()` 的实现也是有趣的球面三角学应用。限于篇幅，这里不展开其实现；“延伸阅读”列出了提出该方法并给出推导的论文。
]
#block(sticky: true)[#raw("<<Sampling Function Declarations>>=")] <fragment-SamplingFunctionDeclarations-0>
```cpp
Point3f SampleSphericalRectangle(Point3f p, Point3f v00, Vector3f eu,
                                 Vector3f ev, Point2f u,
                                 Float *pdf = nullptr);
``` <SampleSphericalRectangle>
#parec[
  A rectangle has the same surface normal across its entire surface, which can be found by taking the cross product of the two edge vectors. The parametric $(u,v)$ coordinates for the point `p` are then found by computing the normalized projection of `p` onto each of the edges.
][
  矩形各处法向量相同，可由两条边向量的叉积求得。将点 `p` 投影到各条边并按边长归一化，就得到参数 $(u,v)$。
]
#block(sticky: true)[#raw("<<Compute (u, v) and surface normal for sampled point on rectangle>>=")] <fragment-Computeuvandsurfacenormalforsampledpointonrectangle-0>
```cpp
Point2f uv(Dot(p - p00, eu) / DistanceSquared(p10, p00),
           Dot(p - p00, ev) / DistanceSquared(p01, p00));
Normal3f n = Normal3f(Normalize(Cross(eu, ev)));
<<Flip normal at sampled (u, v) if necessary>>
```
#parec[
  If the bilinear patch has per-vertex texture coordinates associated with it, the interpolated texture coordinates at the sampled point are easily computed.
][
  若面片带有逐顶点纹理坐标，则通过插值求出采样点的纹理坐标。
]
#block(sticky: true)[#raw("<<Compute (s, t) texture coordinates for sampled (u, v) >>=")] <fragment-Computesttexturecoordinatesforsampleduv-0>
```cpp
Point2f st = uv;
if (mesh->uv) {
    <<Compute texture coordinates for bilinear patch intersection point>>
}
```
#parec[
  The associated `PDF()` method follows the usual form, determining which sampling method would be used for the patch and then computing its solid angle PDF.
][
  相应的 `PDF()` 方法按通常结构，先判断会采用哪种采样方法，再计算其立体角 PDF。
]
#block(sticky: true)[#raw("<<BilinearPatch Method Definitions>>+=")] <fragment-BilinearPatchMethodDefinitions-6>
```cpp
Float BilinearPatch::PDF(const ShapeSampleContext &ctx, Vector3f wi) const {
    const BilinearPatchMesh *mesh = GetMesh();
    <<Get bilinear patch vertices in p00, p01, p10, and p11>>
    <<Compute solid angle PDF for sampling bilinear patch from ctx>>
}
```
#parec[
  In all cases, the `SurfaceInteraction` corresponding to the intersection of the ray from `ctx` in the direction `wi` will be needed, so the method starts by performing a ray–patch intersection test.
][
  所有分支都需要从 `ctx` 沿 `wi` 发出的射线与面片交点处的 `SurfaceInteraction`，因此先进行一次求交。
]
#block(sticky: true)[#raw("<<Compute solid angle PDF for sampling bilinear patch from ctx>>=")] <fragment-ComputesolidanglePDFforsamplingbilinearpatchfrommonoctx-0>
```cpp
<<Intersect sample ray with shape geometry>>
Vector3f v00 = Normalize(p00 - ctx.p()), v10 = Normalize(p10 - ctx.p());
Vector3f v01 = Normalize(p01 - ctx.p()), v11 = Normalize(p11 - ctx.p());
if (!IsRectangle(mesh) || mesh->imageDistribution ||
    SphericalQuadArea(v00, v10, v11, v01) <= MinSphericalSampleArea) {
    <<Return solid angle PDF for area-sampled bilinear patch>>
} else {
    <<Return PDF for sample in spherical rectangle>>
}
```
#parec[
  If one of the area sampling approaches was used, then a call to the other `PDF()` method provides the PDF with respect to surface area, which is converted to be with respect to solid angle before it is returned.
][
  若采用面积采样，则调用另一个 `PDF()` 求面积密度，并在返回前换算为立体角密度。
]
#block(sticky: true)[#raw("<<Return solid angle PDF for area-sampled bilinear patch>>=")] <fragment-ReturnsolidanglePDFforarea-sampledbilinearpatch-0>
```cpp
Float pdf = PDF(isect->intr) * (DistanceSquared(ctx.p(), isect->intr.p()) /
                                AbsDot(isect->intr.n, -wi));
return IsInf(pdf) ? 0 : pdf;
```
#parec[
  Otherwise, the spherical rectangle sampling technique was used. The uniform solid angle PDF is 1 over the solid angle that the rectangle subtends. If the reference point is on a surface and the approximation to the $cos theta$ factor would be applied in the `Sample()` method, then the PDF for sampling `u` must be included as well.
][
  否则采用球面矩形采样，其均匀立体角密度是所张立体角的倒数。如果参考点位于表面上，且 `Sample()` 会近似计入 $cos theta$，则还必须乘以采样 `u` 的 PDF。
]
#block(sticky: true)[#raw("<<Return PDF for sample in spherical rectangle>>=")] <fragment-ReturnPDFforsampleinsphericalrectangle-0>
```cpp
Float pdf = 1 / SphericalQuadArea(v00, v10, v11, v01);
if (ctx.ns != Normal3f(0, 0, 0)) {
    <<Compute cos theta weights for rectangle seen from reference point>>
    Point2f u = InvertSphericalRectangleSample(ctx.p(), p00, p10 - p00,
                                               p01 - p00, isect->intr.p());
    return BilinearPDF(u, w) * pdf;
} else
    return pdf;
```
#parec[
  The `InvertSphericalRectangleSample()` function, not included here, returns the sample value `u` that maps to the given point `pRect` on the rectangle when the `SampleSphericalRectangle()` is called with the given reference point `pRef`.
][
  `InvertSphericalRectangleSample()` 返回样本 `u`，使给定参考点 `pRef` 调用 `SampleSphericalRectangle()` 时映射到矩形上的 `pRect`。其实现不在正文列出。
]
#block(sticky: true)[#raw("<<Sampling Function Declarations>>+=")] <fragment-SamplingFunctionDeclarations-1>
```cpp
Point2f InvertSphericalRectangleSample(
    Point3f pRef, Point3f v00, Vector3f eu, Vector3f ev, Point3f pRect);
``` <InvertSphericalRectangleSample>
#parec[
  Source note on texture derivatives: the source computes the inverse parameter derivatives by taking reciprocals of individual derivatives. This is not the inverse Jacobian for a general coupled mapping. For example, for $s=u+v$ and $t=u-v$, the inverse derivatives are $1/2,1/2,1/2,-1/2$, whereas the displayed reciprocal code gives $1,1,1,-1$. Independent review confirms this discrepancy by differentiating the inverse map $u=(s+t)/2$, $v=(s-t)/2$. The source code is preserved; no algorithmic correction has been made.
][
  纹理偏导数校注：原文逐项取倒数来求逆参数偏导数，这对一般耦合映射并不等于求雅可比逆矩阵。例如 $s=u+v$、$t=u-v$ 的四个逆偏导数为 $1/2,1/2,1/2,-1/2$，而所列取倒数代码得到 $1,1,1,-1$。独立复核通过对逆映射 $u=(s+t)/2$、$v=(s-t)/2$ 求导确认了这一差异。这里保留源代码，未修改算法。
]

#parec[
  Source wording on area quadrature: the prose describes a Riemann sum at $3 times 3$ points; the expanded source code uses a $4 times 4$ vertex grid to form $3 times 3$ area contributions. Both the original prose and the code are retained.
][
  面积近似校注：正文称在 $3 times 3$ 个点上求黎曼和，展开代码实际使用 $4 times 4$ 的顶点网格，形成 $3 times 3$ 项面积贡献。这里保留原文说明与代码。
]

#include "supplements/6.6-expanded.typ"
