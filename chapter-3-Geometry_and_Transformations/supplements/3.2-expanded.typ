// Source: pbr-book-website@f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c
// 4ed/Geometry_and_Transformations/n-Tuple_Base_Classes.html, fragbit-73 and fragbit-75.
#import "../../template.typ": parec, ez_caption

#block(sticky: true)[#strong[#ez_caption[Additional Tuple2 public methods][Tuple2 的额外公有方法]]]
#metadata(none) <supplement-Tuple2PublicMethods>
```cpp
static const int nDimensions = 2;

Tuple2() = default;
PBRT_CPU_GPU
Tuple2(T x, T y) : x(x), y(y) { DCHECK(!HasNaN()); }
PBRT_CPU_GPU
bool HasNaN() const { return IsNaN(x) || IsNaN(y); }
#ifdef PBRT_DEBUG_BUILD
// The default versions of these are fine for release builds; for debug
// we define them so that we can add the Assert checks.
PBRT_CPU_GPU
Tuple2(Child<T> c) {
    DCHECK(!c.HasNaN());
    x = c.x;
    y = c.y;
}
PBRT_CPU_GPU
Child<T> &operator=(Child<T> c) {
    DCHECK(!c.HasNaN());
    x = c.x;
    y = c.y;
    return static_cast<Child<T> &>(*this);
}
#endif

template <typename U>
PBRT_CPU_GPU auto operator+(Child<U> c) const -> Child<decltype(T{} + U{})> {
    DCHECK(!c.HasNaN());
    return {x + c.x, y + c.y};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator+=(Child<U> c) {
    DCHECK(!c.HasNaN());
    x += c.x;
    y += c.y;
    return static_cast<Child<T> &>(*this);
}

template <typename U>
PBRT_CPU_GPU auto operator-(Child<U> c) const -> Child<decltype(T{} - U{})> {
    DCHECK(!c.HasNaN());
    return {x - c.x, y - c.y};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator-=(Child<U> c) {
    DCHECK(!c.HasNaN());
    x -= c.x;
    y -= c.y;
    return static_cast<Child<T> &>(*this);
}

PBRT_CPU_GPU
bool operator==(Child<T> c) const { return x == c.x && y == c.y; }
PBRT_CPU_GPU
bool operator!=(Child<T> c) const { return x != c.x || y != c.y; }


template <typename U>
PBRT_CPU_GPU auto operator*(U s) const -> Child<decltype(T{} * U{})> {
    return {s * x, s * y};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator*=(U s) {
    DCHECK(!IsNaN(s));
    x *= s;
    y *= s;
    return static_cast<Child<T> &>(*this);
}

template <typename U>
PBRT_CPU_GPU auto operator/(U d) const -> Child<decltype(T{} / U{})> {
    DCHECK(d != 0 && !IsNaN(d));
    return {x / d, y / d};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator/=(U d) {
    DCHECK_NE(d, 0);
    DCHECK(!IsNaN(d));
    x /= d;
    y /= d;
    return static_cast<Child<T> &>(*this);
}

PBRT_CPU_GPU
Child<T> operator-() const { return {-x, -y}; }

PBRT_CPU_GPU
T operator[](int i) const {
    DCHECK(i >= 0 && i <= 1);
    return (i == 0) ? x : y;
}

PBRT_CPU_GPU
T &operator[](int i) {
    DCHECK(i >= 0 && i <= 1);
    return (i == 0) ? x : y;
}

std::string ToString() const { return internal::ToString2(x, y); }
```

#block(sticky: true)[#strong[#ez_caption[Additional Tuple3 public methods][Tuple3 的额外公有方法]]]
```cpp
static const int nDimensions = 3;

#ifdef PBRT_DEBUG_BUILD
// The default versions of these are fine for release builds; for debug
// we define them so that we can add the Assert checks.
PBRT_CPU_GPU
Tuple3(Child<T> c) {
    DCHECK(!c.HasNaN());
    x = c.x;
    y = c.y;
    z = c.z;
}

PBRT_CPU_GPU
Child<T> &operator=(Child<T> c) {
    DCHECK(!c.HasNaN());
    x = c.x;
    y = c.y;
    z = c.z;
    return static_cast<Child<T> &>(*this);
}
#endif


template <typename U>
PBRT_CPU_GPU Child<T> &operator+=(Child<U> c) {
    DCHECK(!c.HasNaN());
    x += c.x;
    y += c.y;
    z += c.z;
    return static_cast<Child<T> &>(*this);
}

template <typename U>
PBRT_CPU_GPU auto operator-(Child<U> c) const -> Child<decltype(T{} - U{})> {
    DCHECK(!c.HasNaN());
    return {x - c.x, y - c.y, z - c.z};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator-=(Child<U> c) {
    DCHECK(!c.HasNaN());
    x -= c.x;
    y -= c.y;
    z -= c.z;
    return static_cast<Child<T> &>(*this);
}

PBRT_CPU_GPU
bool operator==(Child<T> c) const { return x == c.x && y == c.y && z == c.z; }
PBRT_CPU_GPU
bool operator!=(Child<T> c) const { return x != c.x || y != c.y || z != c.z; }

template <typename U>
PBRT_CPU_GPU auto operator*(U s) const -> Child<decltype(T{} * U{})> {
    return {s * x, s * y, s * z};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator*=(U s) {
    DCHECK(!IsNaN(s));
    x *= s;
    y *= s;
    z *= s;
    return static_cast<Child<T> &>(*this);
}

template <typename U>
PBRT_CPU_GPU auto operator/(U d) const -> Child<decltype(T{} / U{})> {
    DCHECK_NE(d, 0);
    return {x / d, y / d, z / d};
}
template <typename U>
PBRT_CPU_GPU Child<T> &operator/=(U d) {
    DCHECK_NE(d, 0);
    x /= d;
    y /= d;
    z /= d;
    return static_cast<Child<T> &>(*this);
}
PBRT_CPU_GPU
Child<T> operator-() const { return {-x, -y, -z}; }

std::string ToString() const { return internal::ToString3(x, y, z); }
```
