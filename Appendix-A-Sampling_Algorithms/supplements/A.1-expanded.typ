#import "../../template.typ": parec, ez_caption
#heading(level:3,numbering:none,outlined:false)[#ez_caption[Online supplementary code][在线补充代码]]
#parec[Editorial note: These additional implementations are preserved from the fixed source’s collapsed panels. Methods already shown above are not repeated.][校订说明：以下保留固定原书折叠面板中的额外实现，正文已有的方法不重复收录。]

// Source: The_Alias_Method.html#fragbit-2629
#block(sticky:true)[#ez_caption[Additional AliasTable public methods][AliasTable 的额外公有方法]]
```cpp
AliasTable() = default;
AliasTable(Allocator alloc = {}) : bins(alloc) {}
AliasTable(pstd::span<const Float> weights, Allocator alloc = {});
PBRT_CPU_GPU
int Sample(Float u, Float *pmf = nullptr, Float *uRemapped = nullptr) const;
std::string ToString() const;
```

// Source: The_Alias_Method.html#fragbit-2638
#block(sticky:true)[#ez_caption[Handle remaining alias table work items][处理别名表剩余工作项]]
```cpp
while (!over.empty()) {
    Outcome ov = over.back();
    over.pop_back();
    bins[ov.index].q = 1;
    bins[ov.index].alias = -1;
}
while (!under.empty()) {
    Outcome un = under.back();
    under.pop_back();
    bins[un.index].q = 1;
    bins[un.index].alias = -1;
}
```
