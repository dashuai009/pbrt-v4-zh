#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-727")[`fragbit-727`]]
```cpp
BilinearPatchMesh(const Transform &renderFromObject, bool reverseOrientation,
                  std::vector<int> vertexIndices, std::vector<Point3f> p,
                  std::vector<Normal3f> N, std::vector<Point2f> uv,
                  std::vector<int> faceIndices, PiecewiseConstant2D *imageDist, Allocator alloc);

std::string ToString() const;

static void Init(Allocator alloc);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-729")[`fragbit-729`]]
```cpp
BilinearPatch(const BilinearPatchMesh *mesh, int meshIndex, int blpIndex);
static void Init(Allocator alloc);
static BilinearPatchMesh *CreateMesh(const Transform *renderFromObject,
                                     bool reverseOrientation,
                                     const ParameterDictionary &parameters,
                                     const FileLoc *loc, Allocator alloc);
static pstd::vector<Shape> CreatePatches(const BilinearPatchMesh *mesh,
                                               Allocator alloc);
PBRT_CPU_GPU
Bounds3f Bounds() const;
PBRT_CPU_GPU
pstd::optional<ShapeIntersection> Intersect(const Ray &ray,
                                            Float tMax = Infinity) const;
PBRT_CPU_GPU
bool IntersectP(const Ray &ray, Float tMax = Infinity) const;
PBRT_CPU_GPU
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx, Point2f u) const;
PBRT_CPU_GPU
Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const;
PBRT_CPU_GPU
pstd::optional<ShapeSample> Sample(Point2f u) const;
PBRT_CPU_GPU
Float PDF(const Interaction &) const;
PBRT_CPU_GPU
DirectionCone NormalBounds() const;
std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-741")[`fragbit-741`]]
```cpp
Normal3f dnds = dndu * duds + dndv * dvds;
Normal3f dndt = dndu * dudt + dndv * dvdt;
dndu = dnds;
dndv = dndt;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-755")[`fragbit-755`]]
```cpp
// FIXME: it would be good to skip this for flat patches, or to
// be adaptive based on curvature in some manner
constexpr int na = 3;
Point3f p[na + 1][na + 1];
for (int i = 0; i <= na; ++i) {
    Float u = Float(i) / Float(na);
    for (int j = 0; j <= na; ++j) {
        Float v = Float(j) / Float(na);
        p[i][j] = Lerp(u, Lerp(v, p00, p01), Lerp(v, p10, p11));
    }
}
area = 0;
for (int i = 0; i < na; ++i)
    for (int j = 0; j < na; ++j)
        area += 0.5f * Length(Cross(p[i + 1][j + 1] - p[i][j],
                                    p[i + 1][j] - p[i][j + 1]));
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-763")[`fragbit-763`]]
```cpp
if (p00 == p10 || p10 == p11 || p11 == p01 || p01 == p00) {
    Vector3f dpdu = Lerp(0.5f, p10, p11) - Lerp(0.5f, p00, p01);
    Vector3f dpdv = Lerp(0.5f, p01, p11) - Lerp(0.5f, p00, p10);
    Vector3f n = Normalize(Cross(dpdu, dpdv));
    if (mesh->n) {
        Normal3f ns = (mesh->n[v[0]] + mesh->n[v[1]] +
                       mesh->n[v[2]] + mesh->n[v[3]]) / 4;
        n = FaceForward(n, ns);
    } else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
        n = -n;
    return DirectionCone(n);
}
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-765")[`fragbit-765`]]
```cpp
Vector3f n10 = Normalize(Cross(p11 - p10, p00 - p10));
Vector3f n01 = Normalize(Cross(p00 - p01, p11 - p01));
Vector3f n11 = Normalize(Cross(p01 - p11, p10 - p11));
if (mesh->n) {
    n10 = FaceForward(n10, mesh->n[v[1]]);
    n01 = FaceForward(n01, mesh->n[v[2]]);
    n11 = FaceForward(n11, mesh->n[v[3]]);
} else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness) {
    n10 = -n10;
    n01 = -n01;
    n11 = -n11;
}
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-774")[`fragbit-774`]]
```cpp
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
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-820")[`fragbit-820`]]
```cpp
Point3f pu0 = Lerp(uv[1], p00, p01), pu1 = Lerp(uv[1], p10, p11);
Point3f p = Lerp(uv[0], pu0, pu1);
Vector3f dpdu = pu1 - pu0;
Vector3f dpdv = Lerp(uv[0], p01, p11) - Lerp(uv[0], p00, p10);
if (LengthSquared(dpdu) == 0 || LengthSquared(dpdv) == 0)
    return {};
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#fragbit-823")[`fragbit-823`]]
```cpp
if (mesh->n) {
    Normal3f n00 = mesh->n[v[0]], n10 = mesh->n[v[1]];
    Normal3f n01 = mesh->n[v[2]], n11 = mesh->n[v[3]];
    Normal3f ns = Lerp(uv[0], Lerp(uv[1], n00, n01), Lerp(uv[1], n10, n11));
    n = FaceForward(n, ns);
} else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    n = -n;
```

#parec[The derivatives in panel `fragbit-839` reuse `pu0`, `pu1`, `dpdu`, and `dpdv` from panel `fragbit-820`; the PDF path does not include the sampled point or the sample-only degeneracy return. Error bounds and the positive-t epsilon are shown in Section 6.8 and are not duplicated here.][面板 `fragbit-839` 的偏导数复用 `fragbit-820` 中的 `pu0`、`pu1`、`dpdu`、`dpdv` 计算；PDF 分支不计算采样位置，也不使用采样分支的退化返回。误差界及正t阈值的实现位于6.8节，此处不重复。]
