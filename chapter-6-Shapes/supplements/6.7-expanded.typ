#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Expanded source fragments][原文折叠代码补充]]

#parec[The following fragments are expanded from the pinned source. Repeated visible fragments are not duplicated.][以下片段展开自固定原文。已在正文显示的片段不重复收录。]

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-885")[ #ez_caption[Source panel 885][Curve 额外公共声明] ]]
```cpp
static pstd::vector<Shape> Create(const Transform *renderFromObject,
                                        const Transform *objectFromRender,
                                        bool reverseOrientation,
                                        const ParameterDictionary &parameters,
                                        const FileLoc *loc, Allocator alloc);

PBRT_CPU_GPU
Bounds3f Bounds() const;
pstd::optional<ShapeIntersection> Intersect(const Ray &ray, Float tMax) const;
bool IntersectP(const Ray &ray, Float tMax) const;
PBRT_CPU_GPU
Float Area() const;

PBRT_CPU_GPU
pstd::optional<ShapeSample> Sample(Point2f u) const;
PBRT_CPU_GPU
Float PDF(const Interaction &) const;

PBRT_CPU_GPU
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx, Point2f u) const;
PBRT_CPU_GPU
Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const;

std::string ToString() const;
```

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-886")[ #ez_caption[Source panel 886][Curve 私有求交声明] ]]
```cpp
bool IntersectRay(const Ray &r, Float tMax, pstd::optional<ShapeIntersection> *si) const;
bool RecursiveIntersect(const Ray &r, Float tMax, pstd::span<const Point3f> cp,
                        const Transform &ObjectFromRay, Float u0, Float u1, int depth,
                        pstd::optional<ShapeIntersection> *si) const;
```

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-888")[ #ez_caption[Source panel 888][CurveCommon 构造及字符串声明] ]]
```cpp
CurveCommon(pstd::span<const Point3f> c, Float w0, Float w1, CurveType type,
            pstd::span<const Normal3f> norm, const Transform *renderFromObject,
            const Transform *objectFromRender, bool reverseOrientation);

std::string ToString() const;
```

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-895")[ #ez_caption[Source panel 895][细分深度] ]]
```cpp
Float L0 = 0;
for (int i = 0; i < 2; ++i)
    L0 = std::max(
        L0, std::max(std::max(std::abs(cp[i].x - 2 * cp[i + 1].x + cp[i + 2].x),
                              std::abs(cp[i].y - 2 * cp[i + 1].y + cp[i + 2].y)),
                     std::abs(cp[i].z - 2 * cp[i + 1].z + cp[i + 2].z)));
int maxDepth = 0;
if (L0 > 0) {
    Float eps = std::max(common->width[0], common->width[1]) * .05f;  // width / 20
    // Compute log base 4 by dividing log2 in half.
    int r0 = Log2Int(1.41421356237f * 6.f * L0 / (8.f * eps)) / 2;
    maxDepth = Clamp(r0, 0, 10);
}
```

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-898")[ #ez_caption[Source panel 898][子段包围盒测试] ]]
```cpp
Float maxWidth =
    std::max(Lerp(u[seg], common->width[0], common->width[1]),
             Lerp(u[seg + 1], common->width[0], common->width[1]));
pstd::span<const Point3f> cps = pstd::MakeConstSpan(&cpSplit[3 * seg], 4);
Bounds3f curveBounds = Union(Bounds3f(cps[0], cps[1]), Bounds3f(cps[2], cps[3]));
curveBounds = Expand(curveBounds, 0.5f * maxWidth);
Bounds3f rayBounds(Point3f(0, 0, 0), Point3f(0, 0, Length(ray.d) * tMax));
if (!Overlaps(rayBounds, curveBounds))
    continue;
```

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-903")[ #ez_caption[Source panel 903][末端边函数测试] ]]
```cpp
edge = (cp[2].y - cp[3].y) * -cp[3].y +
       cp[3].x * (cp[3].x - cp[2].x);
if (edge < 0)
    return false;
```

#block(sticky:true)[#link("https://pbr-book.org/4ed/Shapes/Curves.html#fragbit-915")[ #ez_caption[Source panel 915][交点误差界] ]]
```cpp
Vector3f pError(hitWidth, hitWidth, hitWidth);
```
