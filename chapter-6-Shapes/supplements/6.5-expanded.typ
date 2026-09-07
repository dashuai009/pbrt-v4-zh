#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#parec[The following code is present only in collapsed panels. Repeated code and the error-bound implementations shown in Section 6.8 are referenced rather than duplicated.][以下内容来自原网页折叠面板。正文已有的重复代码及6.8节可见的误差界实现保持引用，不重复复制。]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-544")[`fragbit-544`]]
```cpp
TriangleMesh(const Transform &renderFromObject, bool reverseOrientation,
             std::vector<int> vertexIndices, std::vector<Point3f> p,
             std::vector<Vector3f> S, std::vector<Normal3f> N,
             std::vector<Point2f> uv, std::vector<int> faceIndices,
             Allocator alloc);

std::string ToString() const;

bool WritePLY(std::string filename) const;

static void Init(Allocator alloc);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-548")[`fragbit-548`]]
```cpp
this->reverseOrientation = reverseOrientation;
this->transformSwapsHandedness = renderFromObject.SwapsHandedness();

if (!uv.empty()) {
    CHECK_EQ(nVertices, uv.size());
    this->uv = point2BufferCache->LookupOrAdd(uv, alloc);
}
if (!n.empty()) {
    CHECK_EQ(nVertices, n.size());
    for (Normal3f &nn : n) {
        nn = renderFromObject(nn);
        if (reverseOrientation)
            nn = -nn;
    }
    this->n = normal3BufferCache->LookupOrAdd(n, alloc);
}
if (!s.empty()) {
    CHECK_EQ(nVertices, s.size());
    for (Vector3f &ss : s)
        ss = renderFromObject(ss);
    this->s = vector3BufferCache->LookupOrAdd(s, alloc);
}

if (!faceIndices.empty()) {
    CHECK_EQ(nTriangles, faceIndices.size());
    this->faceIndices = intBufferCache->LookupOrAdd(faceIndices, alloc);
}

// Make sure that we don't have too much stuff to be using integers to
// index into things.
CHECK_LE(p.size(), std::numeric_limits<int>::max());
// We could be clever and check indices.size() / 3 if we were careful
// to promote to a 64-bit int before multiplying by 3 when we look up
// in the indices array...
CHECK_LE(indices.size(), std::numeric_limits<int>::max());
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-562")[`fragbit-562`]]
```cpp
static pstd::vector<Shape> CreateTriangles(const TriangleMesh *mesh,
                                                 Allocator alloc);

static void Init(Allocator alloc);

PBRT_CPU_GPU
Bounds3f Bounds() const;

PBRT_CPU_GPU
pstd::optional<ShapeIntersection> Intersect(const Ray &ray,
                                            Float tMax = Infinity) const;
PBRT_CPU_GPU
bool IntersectP(const Ray &ray, Float tMax = Infinity) const;

PBRT_CPU_GPU
DirectionCone NormalBounds() const;
std::string ToString() const;
static TriangleMesh *CreateMesh(const Transform *renderFromObject,
                                bool reverseOrientation,
                                const ParameterDictionary &parameters,
                                const FileLoc *loc, Allocator alloc);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-567")[`fragbit-567`]]
```cpp
pstd::array<Point2f, 3> uv =
    mesh->uv
        ? pstd::array<Point2f, 3>(
              {mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]})
        : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-579")[`fragbit-579`]]
```cpp
Normal3f dndu, dndv;
if (mesh->n) {
    // Compute deltas for triangle partial derivatives of normal
    Vector2f duv02 = uv[0] - uv[2];
    Vector2f duv12 = uv[1] - uv[2];
    Normal3f dn1 = mesh->n[v[0]] - mesh->n[v[2]];
    Normal3f dn2 = mesh->n[v[1]] - mesh->n[v[2]];

    Float determinant =
        DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
    bool degenerateUV = std::abs(determinant) < 1e-9;
    if (degenerateUV) {
        // We can still compute dndu and dndv, with respect to the
        // same arbitrary coordinate system we use to compute dpdu
        // and dpdv when this happens. It's important to do this
        // (rather than giving up) so that ray differentials for
        // rays reflected from triangles with degenerate
        // parameterizations are still reasonable.
        Vector3f dn = Cross(Vector3f(mesh->n[v[2]] - mesh->n[v[0]]),
                            Vector3f(mesh->n[v[1]] - mesh->n[v[0]]));

        if (LengthSquared(dn) == 0)
            dndu = dndv = Normal3f(0, 0, 0);
        else {
            Vector3f dnu, dnv;
            CoordinateSystem(dn, &dnu, &dnv);
            dndu = Normal3f(dnu);
            dndv = Normal3f(dnv);
        }
    } else {
        Float invDet = 1 / determinant;
        dndu = DifferenceOfProducts(duv12[1], dn1, duv02[1], dn2) * invDet;
        dndv = DifferenceOfProducts(duv02[0], dn2, duv12[0], dn1) * invDet;
    }
} else
    dndu = dndv = Normal3f(0, 0, 0);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-617")[`fragbit-617`]]
```cpp
if (sizeof(Float) == sizeof(float) &&
    (e0 == 0.0f || e1 == 0.0f || e2 == 0.0f)) {
    double p2txp1ty = (double)p2t.x * (double)p1t.y;
    double p2typ1tx = (double)p2t.y * (double)p1t.x;
    e0 = (float)(p2typ1tx - p2txp1ty);
    double p0txp2ty = (double)p0t.x * (double)p2t.y;
    double p0typ2tx = (double)p0t.y * (double)p2t.x;
    e1 = (float)(p0typ2tx - p0txp2ty);
    double p1txp0ty = (double)p1t.x * (double)p0t.y;
    double p1typ0tx = (double)p1t.y * (double)p0t.x;
    e2 = (float)(p1typ0tx - p1txp0ty);
}
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#fragbit-549")[`fragbit-549`]]
```cpp
size_t BytesUsed() const { return bytesUsed; }
```
