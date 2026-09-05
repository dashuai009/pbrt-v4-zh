#import "../../template.typ": parec, ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Vectors.html#fragbit-77.
#block(sticky: true)[#strong[#ez_caption[Additional implementation (source panel 77)][额外实现（原文面板 77）]]]
```cpp
using Tuple2<Vector2, T>::x;
using Tuple2<Vector2, T>::y;
Vector2() = default;
Vector2(T x, T y) : Tuple2<pbrt::Vector2, T>(x, y) {}
template <typename U>
explicit Vector2(Point2<U> p);
template <typename U>
explicit Vector2(Vector2<U> v)
    : Tuple2<pbrt::Vector2, T>(T(v.x), T(v.y)) {}
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Vectors.html#fragbit-78.
#block(sticky: true)[#strong[#ez_caption[Additional implementation (source panel 78)][额外实现（原文面板 78）]]]
```cpp
using Tuple3<Vector3, T>::x;
using Tuple3<Vector3, T>::y;
using Tuple3<Vector3, T>::z;
```
