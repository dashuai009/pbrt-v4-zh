#import "../../template.typ": parec, ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Rays.html#fragbit-81
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 81)][额外代码（原文面板 81）]]]
```cpp
PBRT_CPU_GPU
bool HasNaN() const { return (o.HasNaN() || d.HasNaN()); }

std::string ToString() const;
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Rays.html#fragbit-83
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 83)][额外代码（原文面板 83）]]]
```cpp
PBRT_CPU_GPU
bool HasNaN() const {
    return Ray::HasNaN() ||
           (hasDifferentials && (rxOrigin.HasNaN() || ryOrigin.HasNaN() ||
                                 rxDirection.HasNaN() || ryDirection.HasNaN()));
}
std::string ToString() const;
```
