#import "../../template.typ": parec, ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Bounding_Boxes.html#fragbit-85
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 85)][额外代码（原文面板 85）]]]
```cpp
PBRT_CPU_GPU
Bounds2() {
    T minNum = std::numeric_limits<T>::lowest();
    T maxNum = std::numeric_limits<T>::max();
    pMin = Point2<T>(maxNum, maxNum);
    pMax = Point2<T>(minNum, minNum);
}
PBRT_CPU_GPU
explicit Bounds2(Point2<T> p) : pMin(p), pMax(p) {}
PBRT_CPU_GPU
Bounds2(Point2<T> p1, Point2<T> p2)
    : pMin(Min(p1, p2)), pMax(Max(p1, p2)) {}
template <typename U>
PBRT_CPU_GPU explicit Bounds2(const Bounds2<U> &b) {
    if (b.IsEmpty())
        // Be careful about overflowing float->int conversions and the
        // like.
        *this = Bounds2<T>();
    else {
        pMin = Point2<T>(b.pMin);
        pMax = Point2<T>(b.pMax);
    }
}

PBRT_CPU_GPU
Vector2<T> Diagonal() const { return pMax - pMin; }

PBRT_CPU_GPU
T Area() const {
    Vector2<T> d = pMax - pMin;
    return d.x * d.y;
}

PBRT_CPU_GPU
bool IsEmpty() const { return pMin.x >= pMax.x || pMin.y >= pMax.y; }

PBRT_CPU_GPU
bool IsDegenerate() const { return pMin.x > pMax.x || pMin.y > pMax.y; }

PBRT_CPU_GPU
int MaxDimension() const {
    Vector2<T> diag = Diagonal();
    if (diag.x > diag.y)
        return 0;
    else
        return 1;
}
PBRT_CPU_GPU
Point2<T> operator[](int i) const {
    DCHECK(i == 0 || i == 1);
    return (i == 0) ? pMin : pMax;
}
PBRT_CPU_GPU
Point2<T> &operator[](int i) {
    DCHECK(i == 0 || i == 1);
    return (i == 0) ? pMin : pMax;
}
PBRT_CPU_GPU
bool operator==(const Bounds2<T> &b) const {
    return b.pMin == pMin && b.pMax == pMax;
}
PBRT_CPU_GPU
bool operator!=(const Bounds2<T> &b) const {
    return b.pMin != pMin || b.pMax != pMax;
}
PBRT_CPU_GPU
Point2<T> Corner(int corner) const {
    DCHECK(corner >= 0 && corner < 4);
    return Point2<T>((*this)[(corner & 1)].x, (*this)[(corner & 2) ? 1 : 0].y);
}
PBRT_CPU_GPU
Point2<T> Lerp(Point2f t) const {
    return Point2<T>(pbrt::Lerp(t.x, pMin.x, pMax.x),
                     pbrt::Lerp(t.y, pMin.y, pMax.y));
}
PBRT_CPU_GPU
Vector2<T> Offset(Point2<T> p) const {
    Vector2<T> o = p - pMin;
    if (pMax.x > pMin.x)
        o.x /= pMax.x - pMin.x;
    if (pMax.y > pMin.y)
        o.y /= pMax.y - pMin.y;
    return o;
}
PBRT_CPU_GPU
void BoundingSphere(Point2<T> *c, Float *rad) const {
    *c = (pMin + pMax) / 2;
    *rad = Inside(*c, *this) ? Distance(*c, pMax) : 0;
}

std::string ToString() const { return StringPrintf("[ %s - %s ]", pMin, pMax); }
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Bounding_Boxes.html#fragbit-86
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 86)][额外代码（原文面板 86）]]]
```cpp
Point2<T> pMin, pMax;
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Bounding_Boxes.html#fragbit-87
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 87)][额外代码（原文面板 87）]]]
```cpp
template <typename U>
PBRT_CPU_GPU explicit Bounds3(const Bounds3<U> &b) {
    if (b.IsEmpty())
        // Be careful about overflowing float->int conversions and the
        // like.
        *this = Bounds3<T>();
    else {
        pMin = Point3<T>(b.pMin);
        pMax = Point3<T>(b.pMax);
    }
}
PBRT_CPU_GPU
bool operator==(const Bounds3<T> &b) const {
    return b.pMin == pMin && b.pMax == pMax;
}
PBRT_CPU_GPU
bool operator!=(const Bounds3<T> &b) const {
    return b.pMin != pMin || b.pMax != pMax;
}
PBRT_CPU_GPU
bool IntersectP(Point3f o, Vector3f d, Float tMax = Infinity,
                Float *hitt0 = nullptr, Float *hitt1 = nullptr) const;
PBRT_CPU_GPU
bool IntersectP(Point3f o, Vector3f d, Float tMax, Vector3f invDir, const int dirIsNeg[3]) const;

std::string ToString() const { return StringPrintf("[ %s - %s ]", pMin, pMax); }
```
