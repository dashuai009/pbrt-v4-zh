#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#fragbit-326")[`fragbit-326`]]
```cpp
using TaggedPointer::TaggedPointer;

static pstd::vector<Shape> Create(const std::string &name,
                                        const Transform *renderFromObject,
                                        const Transform *objectFromRender,
                                        bool reverseOrientation,
                                        const ParameterDictionary &parameters,
                                        const std::map<std::string, FloatTexture> &floatTextures,
                                        const FileLoc *loc, Allocator alloc);
std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#fragbit-334")[`fragbit-334`]]
```cpp
tMax *= 1 + 2 * gamma(3);
tyMax *= 1 + 2 * gamma(3);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#fragbit-335")[`fragbit-335`]]
```cpp
Float tzMin = (bounds[  dirIsNeg[2]].z - o.z) * invDir.z;
Float tzMax = (bounds[1-dirIsNeg[2]].z - o.z) * invDir.z;
<<Update tzMax to ensure robust bounds intersection>>
if (tMin > tzMax || tzMin > tMax)
    return false;
if (tzMin > tMin)
    tMin = tzMin;
if (tzMax < tMax)
    tMax = tzMax;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#fragbit-336")[`fragbit-336`]]
```cpp
tzMax *= 1 + 2 * gamma(3);
```
