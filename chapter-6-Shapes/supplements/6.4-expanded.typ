#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Disks.html#fragbit-514")[`fragbit-514`]]
```cpp
Disk(const Transform *renderFromObject, const Transform *objectFromRender,
     bool reverseOrientation, Float height, Float radius, Float innerRadius,
     Float phiMax)
    : renderFromObject(renderFromObject), objectFromRender(objectFromRender),
      reverseOrientation(reverseOrientation),
      transformSwapsHandedness(renderFromObject->SwapsHandedness()),
      height(height),
      radius(radius),
      innerRadius(innerRadius),
      phiMax(Radians(Clamp(phiMax, 0, 360))) {}
static Disk *Create(const Transform *renderFromObject,
                    const Transform *objectFromRender, bool reverseOrientation,
                    const ParameterDictionary &parameters, const FileLoc *loc,
                    Allocator alloc);
std::string ToString() const;

PBRT_CPU_GPU
Bounds3f Bounds() const;
PBRT_CPU_GPU
DirectionCone NormalBounds() const;

PBRT_CPU_GPU
```
