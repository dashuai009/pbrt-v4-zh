#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original expandable panels][原书折叠面板中的补充代码]]

#parec[The following code is present in the fixed original’s expandable panels. Definitions already shown above are not repeated.][以下代码来自固定原书的折叠面板；前文已展示的定义不再重复。]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragbit-2674")[#raw("PiecewiseConstant2D — additional methods")]]

#block(breakable: false)[
```cpp
PiecewiseConstant2D() = default;
PiecewiseConstant2D(Allocator alloc) : pConditionalV(alloc), pMarginal(alloc) {}
PiecewiseConstant2D(pstd::span<const Float> data, int nx, int ny,
                    Allocator alloc = {})
    : PiecewiseConstant2D(data, nx, ny, Bounds2f(Point2f(0, 0), Point2f(1, 1)),
                          alloc) {}
explicit PiecewiseConstant2D(const Array2D<Float> &data, Allocator alloc = {})
    : PiecewiseConstant2D(pstd::span<const Float>(data), data.XSize(), data.YSize(),
                          alloc) {}
PiecewiseConstant2D(const Array2D<Float> &data, Bounds2f domain, Allocator alloc = {})
    : PiecewiseConstant2D(pstd::span<const Float>(data), data.XSize(), data.YSize(),
                          domain, alloc) {}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragbit-2674")[#raw("PiecewiseConstant2D — additional methods")]]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
size_t BytesUsed() const {
    return pConditionalV.size() *
               (pConditionalV[0].BytesUsed() + sizeof(pConditionalV[0])) +
           pMarginal.BytesUsed();
}
PBRT_CPU_GPU
Bounds2f Domain() const { return domain; }
PBRT_CPU_GPU
Point2i Resolution() const {
    return {int(pConditionalV[0].size()), int(pMarginal.size())};
}
std::string ToString() const {
    return StringPrintf("[ PiecewiseConstant2D domain: %s pConditionalV: %s "
                        "pMarginal: %s ]",
                        domain, pConditionalV, pMarginal);
}
static void TestCompareDistributions(const PiecewiseConstant2D &da,
                                     const PiecewiseConstant2D &db, Float eps = 1e-5);
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragbit-2674")[#raw("PiecewiseConstant2D — additional methods")]]

#block(breakable: false)[
```cpp
pstd::optional<Point2f> Invert(Point2f p) const {
    pstd::optional<Float> mInv = pMarginal.Invert(p[1]);
    if (!mInv)
        return {};
    Float p1o = (p[1] - domain.pMin[1]) / (domain.pMax[1] - domain.pMin[1]);
    if (p1o < 0 || p1o > 1)
        return {};
    int offset = Clamp(p1o * pConditionalV.size(), 0, pConditionalV.size() - 1);
    pstd::optional<Float> cInv = pConditionalV[offset].Invert(p[0]);
    if (!cInv)
        return {};
    return Point2f(*cInv, *mInv);
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#fragbit-2680")[#raw("SummedAreaTable — additional declaration")]]

```cpp
std::string ToString() const;
```
