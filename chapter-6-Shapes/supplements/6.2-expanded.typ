#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Spheres.html#fragbit-339")[`fragbit-339`]]
```cpp
static Sphere *Create(const Transform *renderFromObject,
                      const Transform *objectFromRender, bool reverseOrientation,
                      const ParameterDictionary &parameters, const FileLoc *loc,
                      Allocator alloc);
std::string ToString() const;

PBRT_CPU_GPU
Bounds3f Bounds() const;

PBRT_CPU_GPU
pstd::optional<ShapeSample> Sample(Point2f u) const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Spheres.html#fragbit-370")[`fragbit-370`]]
```cpp
Vector3f pError = gamma(5) * Abs((Vector3f)p);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Spheres.html#fragbit-371")[`fragbit-371`]]
```cpp
Point3f pObj = (*objectFromRender)(p);
Float theta = SafeACos(pObj.z / radius);
Float spherePhi = std::atan2(pObj.y, pObj.x);
if (spherePhi < 0)
    spherePhi += 2 * Pi;
Point2f uv(spherePhi / phiMax, (theta - thetaZMin) / (thetaZMax - thetaZMin));
```
