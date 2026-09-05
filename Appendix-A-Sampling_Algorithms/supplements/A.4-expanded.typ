#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original expandable panels][原书折叠面板中的补充代码]]

#parec[The following code is present in the fixed original’s expandable panels. Definitions already shown above are not repeated.][以下代码来自固定原书的折叠面板；前文已展示的定义不再重复。]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_1D_Functions.html#fragbit-2652")[#raw("PiecewiseConstant1D — additional methods")]]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
size_t BytesUsed() const {
    return (func.capacity() + cdf.capacity()) * sizeof(Float);
}
static void TestCompareDistributions(const PiecewiseConstant1D &da,
                                     const PiecewiseConstant1D &db, Float eps = 1e-5);
std::string ToString() const {
    return StringPrintf("[ PiecewiseConstant1D func: %s cdf: %s "
                        "min: %f max: %f funcInt: %f ]",
                        func, cdf, min, max, funcInt);
}
PiecewiseConstant1D() = default;
PiecewiseConstant1D(Allocator alloc) : func(alloc), cdf(alloc) {}
PiecewiseConstant1D(pstd::span<const Float> f, Allocator alloc = {})
    : PiecewiseConstant1D(f, 0., 1., alloc) {}
```
]
