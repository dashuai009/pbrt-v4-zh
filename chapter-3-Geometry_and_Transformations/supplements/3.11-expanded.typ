#import "../../template.typ": ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Interactions.html#fragbit-128.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 128)][额外代码（原文面板 128）]]]
```cpp
Interaction() = default;

SurfaceInteraction &AsSurface() {
    CHECK(IsSurfaceInteraction());
    return (SurfaceInteraction &)*this;
}
// used by medium ctor
PBRT_CPU_GPU
Interaction(Point3f p, Vector3f wo, Float time, Medium medium)
    : pi(p), time(time), wo(wo), medium(medium) {}
PBRT_CPU_GPU
Interaction(Point3f p, Normal3f n, Float time, Medium medium)
    : pi(p), n(n), time(time), medium(medium) {}
PBRT_CPU_GPU
Interaction(Point3f p, Point2f uv)
    : pi(p), uv(uv) {}
PBRT_CPU_GPU
Interaction(const Point3fi &pi, Normal3f n, Float time = 0,
            Point2f uv = {})
    : pi(pi), n(n), uv(uv), time(time) {}
PBRT_CPU_GPU
Interaction(const Point3fi &pi, Normal3f n, Point2f uv)
    : pi(pi), n(n), uv(uv) {}
PBRT_CPU_GPU
Interaction(Point3f p, Float time, Medium medium)
    : pi(p), time(time), medium(medium) {}
PBRT_CPU_GPU
Interaction(Point3f p, const MediumInterface *mediumInterface)
    : pi(p), mediumInterface(mediumInterface) {}
PBRT_CPU_GPU
Interaction(Point3f p, Float time, const MediumInterface *mediumInterface)
    : pi(p), time(time), mediumInterface(mediumInterface) {}
PBRT_CPU_GPU
const MediumInteraction &AsMedium() const {
    CHECK(IsMediumInteraction());
    return (const MediumInteraction &)*this;
}
PBRT_CPU_GPU
MediumInteraction &AsMedium() {
    CHECK(IsMediumInteraction());
    return (MediumInteraction &)*this;
}

std::string ToString() const;
Point3f OffsetRayOrigin(Vector3f w) const {
    return pbrt::OffsetRayOrigin(pi, n, w);
}
Point3f OffsetRayOrigin(Point3f pt) const {
    return OffsetRayOrigin(pt - p());
}
RayDifferential SpawnRay(Vector3f d) const {
    return RayDifferential(OffsetRayOrigin(d), d, time, GetMedium(d));
}
Ray SpawnRayTo(Point3f p2) const {
    Ray r = pbrt::SpawnRayTo(pi, n, time, p2);
    r.medium = GetMedium(r.d);
    return r;
}
PBRT_CPU_GPU
Ray SpawnRayTo(const Interaction &it) const {
    Ray r = pbrt::SpawnRayTo(pi, n, time, it.pi, it.n);
    r.medium = GetMedium(r.d);
    return r;
}
Medium GetMedium(Vector3f w) const {
    if (mediumInterface)
        return Dot(w, n) > 0 ? mediumInterface->outside :
                               mediumInterface->inside;
    return medium;
}
Medium GetMedium() const {
    return mediumInterface ? mediumInterface->inside : medium;
}
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Interactions.html#fragbit-130.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 130)][额外代码（原文面板 130）]]]
```cpp
SurfaceInteraction() = default;

SurfaceInteraction(Point3fi pi, Point2f uv, Vector3f wo,
        Vector3f dpdu, Vector3f dpdv, Normal3f dndu,
        Normal3f dndv, Float time, bool flipNormal,
        int faceIndex)
    : SurfaceInteraction(pi, uv, wo, dpdu, dpdv, dndu, dndv, time, flipNormal) {
      this->faceIndex = faceIndex;
}

std::string ToString() const;
void SetIntersectionProperties(Material mtl, Light area,
        const MediumInterface *primMediumInterface, Medium rayMedium) {
    material = mtl;
    areaLight = area;
    if (primMediumInterface && primMediumInterface->IsMediumTransition())
        mediumInterface = primMediumInterface;
    else
        medium = rayMedium;
}
PBRT_CPU_GPU
void ComputeDifferentials(const RayDifferential &r, Camera camera,
                          int samplesPerPixel);
PBRT_CPU_GPU
void SkipIntersection(RayDifferential *ray, Float t) const;
using Interaction::SpawnRay;
RayDifferential SpawnRay(const RayDifferential &rayi, const BSDF &bsdf,
                         Vector3f wi, int /*BxDFFlags*/ flags, Float eta) const;
BSDF GetBSDF(const RayDifferential &ray,
             SampledWavelengths &lambda, Camera camera,
             ScratchBuffer &scratchBuffer, Sampler sampler);
BSSRDF GetBSSRDF(const RayDifferential &ray,
             SampledWavelengths &lambda, Camera camera,
             ScratchBuffer &scratchBuffer);
PBRT_CPU_GPU
SampledSpectrum Le(Vector3f w, const SampledWavelengths &lambda) const;
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Interactions.html#fragbit-136.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 136)][额外代码（原文面板 136）]]]
```cpp
Material material;
Light areaLight;
Vector3f dpdx, dpdy;
Float dudx = 0, dvdx = 0, dudy = 0, dvdy = 0;
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Interactions.html#fragbit-141.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 141)][额外代码（原文面板 141）]]]
```cpp
std::string ToString() const;
```
