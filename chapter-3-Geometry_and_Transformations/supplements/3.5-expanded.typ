#import "../../template.typ": parec, ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Normals.html#fragbit-80.
#block(sticky: true)[#strong[#ez_caption[Additional implementation (source panel 80)][额外实现（原文面板 80）]]]
```cpp
using Tuple3<Normal3, T>::x;
using Tuple3<Normal3, T>::y;
using Tuple3<Normal3, T>::z;
using Tuple3<Normal3, T>::HasNaN;
using Tuple3<Normal3, T>::operator+;
using Tuple3<Normal3, T>::operator*;
using Tuple3<Normal3, T>::operator*=;

Normal3() = default;
PBRT_CPU_GPU
Normal3(T x, T y, T z) : Tuple3<pbrt::Normal3, T>(x, y, z) {}
template <typename U>
PBRT_CPU_GPU explicit Normal3<T>(Normal3<U> v)
    : Tuple3<pbrt::Normal3, T>(T(v.x), T(v.y), T(v.z)) {}
```
