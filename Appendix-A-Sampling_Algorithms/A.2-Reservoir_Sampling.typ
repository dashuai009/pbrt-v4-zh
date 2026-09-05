#import "../template.typ": parec, ez_caption

== #ez_caption[Reservoir Sampling][蓄水池采样]
<reservoir-sampling>

#parec[
  To perform the sampling operation, both #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] and alias tables require the number of outcomes being sampled from as well as all their probabilities to be stored in memory. Often this is not a problem, but for cases where we would like to draw a sample from a large number of events, or cases where each event requires a large amount of memory, it is useful to be able to generate samples without storing all of them at once.
][
  `SampleDiscrete()` 和别名表在采样时，都要求将结果数量及全部概率存入内存。通常这没有问题，但如果需要从大量事件中采样，或每个事件占用的内存很大，能够不同时存储所有事件而生成样本，就会很有用。
]

#parec[
  A family of algorithms based on a technique called _reservoir sampling_ makes this possible, by taking a stream of candidate samples one at a time and randomly keeping just one of them in a way that ensures that the sample that is kept is from the distribution defined by the samples that have been seen so far. Reservoir sampling algorithms date to the early days of computer tape drives, where data could only be accessed sequentially and there was often more of it than could be stored in main memory. Reservoir sampling made it possible to draw random samples from data stored on tape while only reading the tape once.
][
  _蓄水池采样_算法族能做到这一点：逐个读取候选样本流，随机保留其中一个，并保证保留的样本服从迄今所有已见样本所定义的分布。这类算法可追溯到计算机磁带机的早期。当时数据只能顺序访问，而且往往超过主存容量；蓄水池采样允许只读一遍磁带，就从其中的数据随机采样。
]

#parec[
  The basic reservoir sampling algorithm is easily expressed. Each candidate sample is stored in the reservoir with probability equal to one over the number of candidates that have been considered:
][
  基本算法很容易描述：每个候选样本以已考虑候选数的倒数作为概率，存入蓄水池。
]

$
  & upright("reservoir") arrow.l emptyset, quad n arrow.l 0 \
  & #ez_caption[while][当] upright("sample") arrow.l upright("GetSample")(): \
  & quad n arrow.l n+1 \
  & quad #ez_caption[if][若] xi < 1/n \
  & quad quad upright("reservoir") arrow.l upright("sample")
$

#parec[
  The correctness of this algorithm can be shown using induction. For the base case, it is clear that if there is a single sample, it will be stored in the reservoir, and the reservoir has successfully drawn a sample with the appropriate probability from the sample distribution.
][
  可以用归纳法证明算法正确。基础情形很清楚：只有一个样本时，它必定被存入蓄水池，因此算法已按适当概率从该样本分布中取样。
]

#parec[
  Now consider the case where $n$ samples have been considered and assume that the sample stored in the reservoir has been kept with probability $1/n$. When a new sample is considered, it will be kept with probability $1/(n+1)$, which is clearly the correct probability for it. The existing sample is kept with probability $n/(n+1)$; the product of the probability of keeping the existing sample and its probability of being stored in the reservoir gives the correct probability, $1/(n+1)$, as well.
][
  假设已经考虑 $n$ 个样本，每个样本留在蓄水池中的概率都是 $1/n$。新样本以 $1/(n+1)$ 的概率被保留，显然正确。原有样本继续保留的概率为 $n/(n+1)$；将它与该样本此前被存入的概率相乘，也得到正确的 $1/(n+1)$。
]

#parec[
  _Weighted reservoir sampling_ algorithms generalize the basic algorithm by making it possible to associate a nonnegative weight with each sample. Samples are then kept with probability given by the ratio of their weight to the sum of weights of all of the candidate samples that have been seen so far. The `WeightedReservoirSampler` class implements this algorithm. It is parameterized by the type of object being sampled `T`.
][
  _加权蓄水池采样_推广了基本算法，允许每个样本携带非负权重。保留某个样本的概率，等于它的权重与迄今所有已见候选样本的权重总和之比。`WeightedReservoirSampler` 实现了这个算法，以被采样对象的类型 `T` 为模板参数。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Definition>>=") ] <fragment-WeightedReservoirSamplerDefinition-0>
#block(breakable:false)[
```cpp
template <typename T>
class WeightedReservoirSampler {
  public:
    <<WeightedReservoirSampler Public Methods>>
  private:
    <<WeightedReservoirSampler Private Members>>
};
``` <WeightedReservoirSampler>
]

#parec[
  `WeightedReservoirSampler` stores an #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] object that provides the random numbers that are used in deciding whether to add each sample to the reservoir. The constructor correspondingly takes a seed value that is passed on to the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`].
][
  `WeightedReservoirSampler` 存储一个 `RNG` 对象，提供决定是否将样本加入蓄水池所需的随机数。因此，构造函数接收种子值并将其传给 `RNG`。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>=") #link(<fragment-WeightedReservoirSamplerPublicMethods-1>)[▼]] <fragment-WeightedReservoirSamplerPublicMethods-0>
#block(breakable:false)[
```cpp
WeightedReservoirSampler() = default;
WeightedReservoirSampler(uint64_t rngSeed) : rng(rngSeed) {}
```
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Private Members>>=") #link(<fragment-WeightedReservoirSamplerPrivateMembers-1>)[▼]] <fragment-WeightedReservoirSamplerPrivateMembers-0>
#block(breakable:false)[
```cpp
RNG rng;
```
]

#parec[
  If an array of `WeightedReservoirSampler`s is allocated, then the default constructor runs instead. In that case, the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`]s in individual samplers can be seeded via the `Seed()` method.
][
  若分配的是 `WeightedReservoirSampler` 数组，则调用默认构造函数。此时，可以通过 `Seed()` 分别设置各采样器所持 `RNG` 的种子。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>+=") #link(<fragment-WeightedReservoirSamplerPublicMethods-0>)[▲] #link(<fragment-WeightedReservoirSamplerPublicMethods-2>)[▼]] <fragment-WeightedReservoirSamplerPublicMethods-1>
#block(breakable:false)[
```cpp
void Seed(uint64_t seed) { rng.SetSequence(seed); }
```
]

#parec[
  The `Add()` method takes a single sample and a nonnegative weight value and updates the reservoir so that the stored sample is from the expected distribution.
][
  `Add()` 接收单个样本及一个非负权重，更新蓄水池，使保留的样本服从预期的分布。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>+=") #link(<fragment-WeightedReservoirSamplerPublicMethods-1>)[▲] #link(<fragment-WeightedReservoirSamplerPublicMethods-3>)[▼]] <fragment-WeightedReservoirSamplerPublicMethods-2>
#block(breakable:false)[
```cpp
void Add(const T &sample, Float weight) {
    weightSum += weight;
    <<Randomly add sample to reservoir>>
}
```
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Private Members>>+=") #link(<fragment-WeightedReservoirSamplerPrivateMembers-0>)[▲] #link(<fragment-WeightedReservoirSamplerPrivateMembers-2>)[▼]] <fragment-WeightedReservoirSamplerPrivateMembers-1>
#block(breakable:false)[
```cpp
Float weightSum = 0;
```
]

#parec[
  The probability `p` for storing the sample candidate in the reservoir is easily found given `weightSum`.
][
  给定 `weightSum`，就很容易计算候选样本存入蓄水池的概率 `p`。
]

#block(sticky:true)[#raw("<<Randomly add sample to reservoir>>=") ] <fragment-Randomlyaddmonosampletoreservoir-0>
#block(breakable:false)[
```cpp
Float p = weight / weightSum;
if (rng.Uniform<Float>() < p) {
    reservoir = sample;
    reservoirWeight = weight;
}
```
]

#parec[
  The weight of the sample stored in the reservoir is stored in `reservoirWeight`; it is needed to compute the value of the probability mass function (PMF) for the sample that is kept.
][
  保留样本的权重存储在 `reservoirWeight` 中，计算该样本的概率质量函数（PMF）值时需要它。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Private Members>>+=") #link(<fragment-WeightedReservoirSamplerPrivateMembers-1>)[▲]] <fragment-WeightedReservoirSamplerPrivateMembers-2>
#block(breakable:false)[
```cpp
Float reservoirWeight = 0;
T reservoir;
```
]

#parec[
  A second `Add()` method takes a callback function that returns a sample. This function is only called when the sample is to be stored in the reservoir. This variant is useful in cases where the sample’s weight can be computed independently of its value and where its value is relatively expensive to compute. The fragment that contains its implementation, `<<Process weighted reservoir sample via callback>>`, otherwise follows the same structure as the first `Add()` method, so it is not included here.
][
  另一个 `Add()` 方法接收返回样本的回调函数，只有样本确实要存入蓄水池时才调用它。如果样本权重可独立于样本值计算，而样本值的计算又较昂贵，这个变体就很有用。其实现片段 `<<Process weighted reservoir sample via callback>>` 在其他方面与第一个 `Add()` 的结构相同，因此正文不再列出。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>+=") #link(<fragment-WeightedReservoirSamplerPublicMethods-2>)[▲] #link(<fragment-WeightedReservoirSamplerPublicMethods-4>)[▼]] <fragment-WeightedReservoirSamplerPublicMethods-3>
#block(breakable:false)[
```cpp
template <typename F>
void Add(F func, Float weight) {
    <<Process weighted reservoir sample via callback>>
}
```
]

#parec[
  A number of methods provide access to the sample and the probability that it was stored in the reservoir.
][
  以下几个方法提供对样本及其被存入蓄水池的概率的访问。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>+=") #link(<fragment-WeightedReservoirSamplerPublicMethods-3>)[▲] #link(<fragment-WeightedReservoirSamplerPublicMethods-5>)[▼]] <fragment-WeightedReservoirSamplerPublicMethods-4>
#block(breakable:false)[
```cpp
int HasSample() const { return weightSum > 0; }
const T &GetSample() const { return reservoir; }
Float SampleProbability() const { return reservoirWeight / weightSum; }
Float WeightSum() const { return weightSum; }
```
]

#parec[
  It is sometimes useful to reset a `WeightedReservoirSampler` and restart from scratch with a new stream of samples; the `Reset()` method handles this task.
][
  有时需要重置 `WeightedReservoirSampler`，从头处理新的样本流；`Reset()` 完成这一任务。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>+=") #link(<fragment-WeightedReservoirSamplerPublicMethods-4>)[▲] #link(<fragment-WeightedReservoirSamplerPublicMethods-6>)[▼]] <fragment-WeightedReservoirSamplerPublicMethods-5>
#block(breakable:false)[
```cpp
void Reset() { reservoirWeight = weightSum = 0; }
```
]

#parec[
  Remarkably, it is possible to merge two reservoirs into one in such a way that the stored sample is kept with the same probability as if a single reservoir had considered all of the samples seen by the two. Merging two reservoirs is a matter of randomly taking the sample stored by the second reservoir with probability defined by its sum of sample weights divided by the sum of both reservoirs’ sums of sample weights, which in turn is exactly what the `Add()` method does.
][
  值得注意的是，可以把两个蓄水池合并为一个，使最终样本的保留概率，与单个蓄水池处理两者见过的全部样本时相同。具体做法是：以第二个蓄水池的样本权重总和除以两者权重总和之和，作为选择第二个蓄水池所存样本的概率。这正是 `Add()` 所执行的操作。
]

#block(sticky:true)[#raw("<<WeightedReservoirSampler Public Methods>>+=") #link(<fragment-WeightedReservoirSamplerPublicMethods-5>)[▲]] <fragment-WeightedReservoirSamplerPublicMethods-6>
#block(breakable:false)[
```cpp
void Merge(const WeightedReservoirSampler &wrs) {
    if (wrs.HasSample())
        Add(wrs.reservoir, wrs.weightSum);
}
```
]

#parec[
  Editorial note: The fixed source's `Merge()` preserves the sample-selection distribution, but its call to `Add()` stores the incoming reservoir's total weight as `reservoirWeight` when that reservoir is selected. Thus, the shown `SampleProbability()` need not give the probability of the original candidate after a merge. For example, merging two reservoirs that each summarize two unit-weight candidates gives each original candidate probability $1/4$, whereas this method returns $1/2$ if the incoming reservoir was selected. The source implementation is retained unchanged.
][
  校订说明：固定原书中的 `Merge()` 保持样本选择分布，但若选中传入蓄水池的样本，其 `Add()` 调用会将该蓄水池的总权重写入 `reservoirWeight`。因此，合并后这里的 `SampleProbability()` 未必返回原始候选的概率。例如，合并两个各含两个单位权重候选的蓄水池，每个原始候选的概率为 $1/4$，但若选中了传入蓄水池，该方法会返回 $1/2$。此处保留原书实现，不擅自修改。
]

#include "supplements/A.2-expanded.typ"
