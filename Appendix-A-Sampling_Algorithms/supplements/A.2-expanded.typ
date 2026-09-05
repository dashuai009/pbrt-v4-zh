#import "../../template.typ": parec, ez_caption
#heading(level:3,numbering:none,outlined:false)[#ez_caption[Online supplementary code][在线补充代码]]
#parec[Editorial note: Additional code from the fixed online source. Duplicated implementations are preserved only once.][校订说明：以下为固定在线原文的额外代码，重复实现只保留一份。]

// Fixed source: Reservoir_Sampling.html#fragbit-2648 and #fragbit-2651 contain the same callback implementation.
#block(sticky:true)[#ez_caption[Process weighted reservoir sample via callback][通过回调处理加权蓄水池样本]]
```cpp
weightSum += weight;
Float p = weight / weightSum;
if (rng.Uniform<Float>() < p) {
    reservoir = func();
    reservoirWeight = weight;
}
```

// Fixed source: Reservoir_Sampling.html#fragbit-2646.
#block(sticky:true)[#ez_caption[Copy][复制]]
```cpp
void Copy(const WeightedReservoirSampler &wrs) {
    weightSum = wrs.weightSum;
    reservoir = wrs.reservoir;
    reservoirWeight = wrs.reservoirWeight;
}
```

// Fixed source: Reservoir_Sampling.html#fragbit-2646.
#block(sticky:true)[#ez_caption[ToString][字符串表示]]
```cpp
std::string ToString() const {
    return StringPrintf("[ WeightedReservoirSampler rng: %s "
                        "weightSum: %f reservoir: %s reservoirWeight: %f ]",
                        rng, weightSum, reservoir, reservoirWeight);
}
```
