#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Shapes/Cylinders.html#fragbit-446")[`fragbit-446`]]
```cpp
static Cylinder *Create(const Transform *renderFromObject,
                        const Transform *objectFromRender, bool reverseOrientation,
                        const ParameterDictionary &parameters, const FileLoc *loc,
                        Allocator alloc);
PBRT_CPU_GPU
Bounds3f Bounds() const;
std::string ToString() const;
```
