#import "../../template.typ": ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Applying_Transformations.html#fragbit-125.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 125)][额外代码（原文面板 125）]]]
```cpp
if (Float lengthSquared = LengthSquared(d); lengthSquared > 0) {
    Float dt = Dot(Abs(d), o.Error()) / lengthSquared;
    o += d * dt;
    if (tMax)
        *tMax -= dt;
}
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Applying_Transformations.html#fragbit-126.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 126)][额外代码（原文面板 126）]]]
```cpp
static Frame FromX(Vector3f x) {
    Vector3f y, z;
    CoordinateSystem(x, &y, &z);
    return Frame(x, y, z);
}
static Frame FromY(Vector3f y) {
    Vector3f x, z;
    CoordinateSystem(y, &z, &x);
    return Frame(x, y, z);
}
static Frame FromX(Normal3f x) {
    Vector3f y, z;
    CoordinateSystem(x, &y, &z);
    return Frame(Vector3f(x), y, z);
}
static Frame FromY(Normal3f y) {
    Vector3f x, z;
    CoordinateSystem(y, &z, &x);
    return Frame(x, Vector3f(y), z);
}
PBRT_CPU_GPU
static Frame FromZ(Normal3f z) { return FromZ(Vector3f(z)); }

Normal3f FromLocal(Normal3f n) const {
    return Normal3f(n.x * x + n.y * y + n.z * z);
}
std::string ToString() const {
    return StringPrintf("[ Frame x: %s y: %s z: %s ]", x, y, z);
}
```
