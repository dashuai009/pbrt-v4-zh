#import "../../template.typ": ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Spherical_Geometry.html#fragbit-89 and fragbit-101.
#strong[#ez_caption[OctahedralVector additional method][OctahedralVector 额外方法]]
```cpp
std::string ToString() const { return StringPrintf("[ OctahedralVector x: %d y: %d ]", x, y); }
```

#strong[#ez_caption[DirectionCone additional declarations][DirectionCone 额外声明]]
```cpp
std::string ToString() const;
PBRT_CPU_GPU
Vector3f ClosestVectorInCone(Vector3f wp) const;
```
