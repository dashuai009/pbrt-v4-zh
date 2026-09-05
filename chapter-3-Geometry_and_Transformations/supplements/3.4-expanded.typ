#import "../../template.typ": parec, ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Points.html#fragbit-79.
#block(sticky: true)[#strong[#ez_caption[Additional implementation (source panel 79)][额外实现（原文面板 79）]]]
```cpp
using Tuple3<Point3, T>::x;
using Tuple3<Point3, T>::y;
using Tuple3<Point3, T>::z;
using Tuple3<Point3, T>::HasNaN;
using Tuple3<Point3, T>::operator+;
using Tuple3<Point3, T>::operator+=;
using Tuple3<Point3, T>::operator*;
using Tuple3<Point3, T>::operator*=;

Point3() = default;
PBRT_CPU_GPU
Point3(T x, T y, T z) : Tuple3<pbrt::Point3, T>(x, y, z) {}

// We can't do using operator- above, since we don't want to pull in
// the Point-Point -> Point one so that we can return a vector
// instead...
PBRT_CPU_GPU
Point3<T> operator-() const { return {-x, -y, -z}; }

template <typename U>
auto operator-(Vector3<U> v) const -> Point3<decltype(T{} - U{})> {
    return {x - v.x, y - v.y, z - v.z};
}
template <typename U>
Point3<T> &operator-=(Vector3<U> v) {
    x -= v.x;    y -= v.y;    z -= v.z;
    return *this;
}
```
