#import "../template.typ": parec

== Independent Sampler
<independent-sampler>
#parec[
  The `IndependentSampler` is perhaps the simplest possible (correct) implementation of the `Sampler` interface. It returns independent uniform sample values for each sample request without making any further effort to ensure the quality of the distribution of samples. The `IndependentSampler` should never be used for rendering if image quality is a concern, but it is useful for setting a baseline to compare against better samplers.
][
  `IndependentSampler` 可能是 `Sampler` 接口最简单的（正确的）实现。它为每个采样请求返回独立的均匀采样值，而不进一步确保采样分布的质量。如果图像质量是一个关注点，则绝不应使用 `IndependentSampler` 进行渲染，但它对于设置基线以与更好的采样器进行比较是有用的。
]

```cpp
class IndependentSampler {
  public:
    IndependentSampler(int samplesPerPixel, int seed = 0)
           : samplesPerPixel(samplesPerPixel), seed(seed) {}
       static IndependentSampler *Create(const ParameterDictionary &parameters,
                                    const FileLoc *loc, Allocator alloc);
       PBRT_CPU_GPU
       static constexpr const char *Name() { return "IndependentSampler"; }
       int SamplesPerPixel() const { return samplesPerPixel; }
       void StartPixelSample(Point2i p, int sampleIndex, int dimension) {
           rng.SetSequence(Hash(p, seed));
           rng.Advance(sampleIndex * 65536ull + dimension);
       }
       Float Get1D() { return rng.Uniform<Float>(); }
       Point2f Get2D() { return {rng.Uniform<Float>(), rng.Uniform<Float>()}; }
       Point2f GetPixel2D() { return Get2D(); }
       Sampler Clone(Allocator alloc);
       std::string ToString() const;
  private:
    int samplesPerPixel, seed;
    RNG rng;
};
```

#parec[
  Like many of the following samplers, `IndependentSampler` takes a seed to use when initializing the pseudo-random number generator with which it produces sample values. Setting different seeds makes it possible to generate independent sets of samples across multiple runs of the renderer, which can be useful when measuring the convergence of various sampling algorithms.
][
  与以下许多采样器一样，`IndependentSampler` 需要一个种子来初始化伪随机数生成器，以此生成采样值。通过设置不同的种子，可以在渲染器的多次运行中生成独立的采样集，这在测量各种采样算法的收敛性时很有用。
]

```cpp
IndependentSampler(int samplesPerPixel, int seed = 0)
    : samplesPerPixel(samplesPerPixel), seed(seed) {}
```

#parec[
  An instance of the #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] class is used to generate sample coordinate values.
][
  使用 #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] 类的一个实例来生成采样坐标值。
]

```cpp
<<IndependentSampler Private Members>>=
int samplesPerPixel, seed;
RNG rng;
```

#parec[
  So that the #link("<IndependentSampler>")[`IndependentSampler`] always gives the same sample value for a given pixel sample, it is important to reset the #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] to a deterministic state rather than, for example, leaving it in whatever state it was at the end of the last pixel sample it was used for. To do so, we take advantage of the fact that the #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] in `pbrt` allows not only for specifying one of $2^64$ sequences of pseudo-random values but also for specifying an offset in that sequence. The implementation below chooses a sequence deterministically, based on the pixel coordinates and seed value. Then, an initial offset into the sequence is found based on the index of the sample, so that different samples in a pixel will start far apart in the sequence. If a nonzero starting dimension is specified, it gives an additional offset into the sequence that skips over earlier dimensions.
][
  为了确保 #link("<IndependentSampler>")[`IndependentSampler`] 对于给定的像素采样总是提供相同的采样值，重要的是将 #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] 重置为确定性状态，而不是例如将其留在上次使用的像素采样结束时的状态。为此，我们利用 `pbrt` 中的 #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] 不仅允许指定 $2^64$ 个伪随机值序列之一，还允许指定该序列中的偏移量。下面的实现基于像素坐标和种子值确定性地选择一个序列。然后，根据采样的索引找到序列中的初始偏移量，以便像素中的不同采样将在序列中相距较远。如果指定了非零的起始维度，它将提供一个额外的偏移量，跳过较早的维度。
]

```cpp
void StartPixelSample(Point2i p, int sampleIndex, int dimension) {
    rng.SetSequence(Hash(p, seed));
    rng.Advance(sampleIndex * 65536ull + dimension);
}
```
#parec[
  Given a seeded #link("../Utilities/Mathematical_Infrastructure.html#RNG")[RNG];, the implementations of the methods that return 1D and 2D samples are trivial. Note that `Get2D()` uses C++'s uniform initialization syntax, which ensures that the two calls to `Uniform()` happen in a well-defined order, which in turn gives consistent results across different compilers.
][
  给定一个有种子的 #link("../Utilities/Mathematical_Infrastructure.html#RNG")[RNG];，返回 1D 和 2D 采样的方法实现是简单的。注意，`Get2D()` 使用 C++ 的均匀初始化语法，这确保了两次对 `Uniform()` 的调用以定义良好的顺序发生，从而在不同的编译器中给出一致的结果。
]

```cpp
Float Get1D() { return rng.Uniform<Float>(); }
Point2f Get2D() { return {rng.Uniform<Float>(), rng.Uniform<Float>()}; }
Point2f GetPixel2D() { return Get2D(); }
```
#parec[
  All the methods for analyzing sampling patterns from @sampling-and-integration are in agreement about the `IndependentSampler`: it is a terrible sampler. Independent uniform samples contain all frequencies equally (they are the definition of white noise), so they do not push aliasing out to higher frequencies. Further, the discrepancy of uniform random samples is 1—the worst possible. (To see why, consider the case of all sample dimensions either having the value 0 or 1.) This sampler's only saving grace comes in the case of integrating a function with a significant amount of energy in its high frequencies (with respect to the sampling rate). In that case, it does about as well as any of the more sophisticated samplers.
][
  @sampling-and-integration 中分析采样模式的所有方法都一致认为 `IndependentSampler` 是一个糟糕的采样器。独立的均匀采样包含所有频率（它们定义了白噪声），因此它们不会将混叠推向更高的频率。此外，均匀随机采样的不一致性是 1——最差的可能值。（要了解原因，请考虑所有采样维度的值要么是 0 要么是 1 的情况。）这个采样器唯一的优点是在积分一个在其高频率（相对于采样率）中具有显著能量的函数时。在这种情况下，它的表现可以与任何更复杂的采样器媲美。
]

