#import "../template.typ": parec, translator
== Reservoir Sampling
<reservoir-sampling>


#parec[
  To perform the sampling operation, both `SampleDiscrete()` and
  alias tables require the number of outcomes being sampled from as well
  as all their probabilities to be stored in memory. Often this is not a
  problem, but for cases where we would like to draw a sample from a large
  number of events, or cases where each event requires a large amount of
  memory, it is useful to be able to generate samples without storing all
  of them at once.
][
  在执行采样操作时，`SampleDiscrete()`
  和别名表（alias
  tables）都需要将所有可能结果的数量以及它们的概率存储在内存中。通常这并不是问题，但在我们希望从大量事件中抽样，或每个事件都需要占用大量内存的情况下，如果能在不一次性存储所有事件的前提下生成样本会更有用。]

#parec[
  A family of algorithms based on a technique called
  #emph[reservoir sampling] makes this possible, by taking a stream of
  candidate samples one at a time and randomly keeping just one of them in
  a way that ensures that the sample that is kept is from the distribution
  defined by the samples that have been seen so far. Reservoir sampling
  algorithms date to the early days of computer tape drives, where data
  could only be accessed sequentially and there was often more of it than
  could be stored in main memory. Reservoir sampling made it possible to
  draw random samples from data stored on tape while only reading the tape
  once.
][
  基于一种称为 #emph[蓄水池抽样];（reservoir sampling）
  的算法族能够实现这一点：它将候选样本作为一个流逐一读取，并随机保留其中一个，使得保留下来的样本服从迄今为止所见样本定义的分布。蓄水池抽样算法可以追溯到计算机磁带机的早期年代，当时数据只能顺序访问，并且通常数据量大于主存所能容纳的容量。蓄水池抽样使得在只读取一次磁带的情况下，就能从存储在磁带上的数据中抽取随机样本。]

#parec[
  The basic reservoir sampling algorithm is easily expressed.
  Each candidate sample is stored in the reservoir with probability equal
  to one over the number of candidates that have been considered:
][

  基本的蓄水池抽样算法可以很容易地描述：每个候选样本以概率 $1 \/ n$
  存入蓄水池，其中 $n$ 是迄今为止已经处理过的候选数。]

```text
reservoir ← ∅, n ← 0
while sample ← GetSample():
    n ← n + 1
    if xi < 1/n
        reservoir ← sample
```

#parec[
  The correctness of this algorithm can be shown using
  induction. For the base case, it is clear that if there is a single
  sample, it will be stored in the reservoir, and the reservoir has
  successfully drawn a sample with the appropriate probability from the
  sample distribution.
][

  该算法的正确性可以通过归纳法证明。基础情况是显然的：如果只有一个样本，它必然会被存入蓄水池，因此蓄水池以正确的概率（100%）从样本分布中抽取到了样本。]

#parec[
  Now consider the case where $n$ samples have been considered
  and assume that the sample stored in the reservoir has been kept with
  probability $1 \/ n$. When a new sample is considered, it will be kept
  with probability $1 \/ (n + 1)$, which is clearly the correct
  probability for it. The existing sample is kept with probability
  $n \/ (n + 1)$; the product of the probability of keeping the existing
  sample and its probability of being stored in the reservoir gives the
  correct probability, $1 \/ (n + 1)$, as well.
][
  接下来考虑已处理 $n$
  个样本的情况，并假设蓄水池中的样本以 $1 \/ n$ 的概率被保留下来。当第
  $n + 1$ 个样本到来时，它会以 $1 \/ (n + 1)$
  的概率被保留，这是正确的概率。而已有的样本则以 $n \/ (n + 1)$
  的概率被保留；将它在蓄水池中的概率 $1 \/ n$ 与保留概率 $n \/ (n + 1)$
  相乘，也得到 $1 \/ (n + 1)$，这同样是正确的结果。]

#parec[
  #strong[Weighted reservoir sampling] algorithms generalize the
  basic algorithm by making it possible to associate a nonnegative weight
  with each sample. Samples are then kept with probability given by the
  ratio of their weight to the sum of weights of all of the candidate
  samples that have been seen so far. The #emph[WeightedReservoirSampler]
  class implements this algorithm. It is parameterized by the type of
  object being sampled `T`.
][
  #strong[加权蓄水池抽样];（weighted
  reservoir
  sampling）算法对基本算法进行了推广，使得每个样本可以带有一个非负权重。此时，保留某个样本的概率等于它的权重与所有已见候选样本权重总和之比。类
  #emph[WeightedReservoirSampler] 实现了这一算法，它通过模板参数 `T`
  指定被抽样对象的类型。]

```cpp
template <typename T>
class WeightedReservoirSampler {
  public:
    <<WeightedReservoirSampler Public Methods>>
    WeightedReservoirSampler() = default;
    WeightedReservoirSampler(uint64_t rngSeed) : rng(rngSeed) {}
    void Seed(uint64_t seed) { rng.SetSequence(seed); }
    void Add(const T &sample, Float weight) {
        weightSum += weight;
        <<Randomly add sample to reservoir>>
        Float p = weight / weightSum;
        if (rng.Uniform<Float>() < p) {
            reservoir = sample;
            reservoirWeight = weight;
        }
    }
    template <typename F>
    void Add(F func, Float weight) {
        <<Process weighted reservoir sample via callback>>
        weightSum += weight;
        Float p = weight / weightSum;
        if (rng.Uniform<Float>() < p) {
            reservoir = func();
            reservoirWeight = weight;
        }

    }
    void Copy(const WeightedReservoirSampler &wrs) {
        weightSum = wrs.weightSum;
        reservoir = wrs.reservoir;
        reservoirWeight = wrs.reservoirWeight;
    }
    int HasSample() const { return weightSum > 0; }
    const T &GetSample() const { return reservoir; }
    Float SampleProbability() const { return reservoirWeight / weightSum; }
    Float WeightSum() const { return weightSum; }
    void Reset() { reservoirWeight = weightSum = 0; }
    void Merge(const WeightedReservoirSampler &wrs) {
        if (wrs.HasSample())
            Add(wrs.reservoir, wrs.weightSum);
    }
    std::string ToString() const {
        return StringPrintf("[ WeightedReservoirSampler rng: %s "
                            "weightSum: %f reservoir: %s reservoirWeight: %f ]",
                            rng, weightSum, reservoir, reservoirWeight);
    }
private:
  <<WeightedReservoirSampler Private Members>>
  RNG rng;
  Float weightSum = 0;
  Float reservoirWeight = 0;
  T reservoir;
};
```

#parec[
  WeightedReservoirSampler stores an RNG object that provides
  the random numbers that are used in deciding whether to add each sample
  to the reservoir. The constructor correspondingly takes a seed value
  that is passed on to the RNG.
][
  `WeightedReservoirSampler`
  内部存储了一个 RNG
  对象，用于生成随机数，以决定是否将某个样本加入蓄水池。其构造函数可以接受一个种子值，并传递给
  RNG。]

```cpp
WeightedReservoirSampler() = default;
WeightedReservoirSampler(uint64_t rngSeed) : rng(rngSeed) {}
```

#parec[
  If an array of WeightedReservoirSampler s is allocated, then
  the default constructor runs instead. In that case, the RNGs in
  individual samplers can be seeded via the `Seed()` method.
][

  如果分配了一组 `WeightedReservoirSampler`
  对象，那么会调用默认构造函数。在这种情况下，可以通过 `Seed()`
  方法对每个采样器中的 RNG 进行单独的种子初始化。]

```cpp
void Seed(uint64_t seed) { rng.SetSequence(seed); }
```

```cpp
void Add(const T &sample, Float weight) {
    weightSum += weight;
    <<Randomly add sample to reservoir>>
    Float p = weight / weightSum;
    if (rng.Uniform<Float>() < p) {
        reservoir = sample;
        reservoirWeight = weight;
    }
}
```

```cpp
Float weightSum = 0;
```

#parec[
  The probability `p` for storing the sample candidate in the
  reservoir is easily found given `weightSum`.
][

  候选样本存入蓄水池的概率 `p` 可以通过 `weightSum` 很容易计算得到。]


```cpp
template <typename F>
void Add(F func, Float weight) {
    <<Process weighted reservoir sample via callback>>
    weightSum += weight;
    Float p = weight / weightSum;
    if (rng.Uniform<Float>() < p) {
        reservoir = func();
        reservoirWeight = weight;
    }
}
```

#parec[
  A second Add() method takes a callback function that returns a
  sample. This function is only called when the sample is to be stored in
  the reservoir. This variant is useful in cases where the sample’s weight
  can be computed independently of its value and where its value is
  relatively expensive to compute. The fragment that contains its
  implementation, `<<Process weighted reservoir sample via callback>>`,
  otherwise follows the same structure as the first Add() method, so it is
  not included here.
][
  第二个 `Add()`
  方法接受一个返回样本的回调函数。只有当该样本最终需要存入蓄水池时，回调函数才会被调用。在样本的权重可以独立计算且样本的值本身开销较大时，这种方式特别有用。其实现片段
  `<<Process weighted reservoir sample via callback>>` 与第一个 `Add()`
  方法的结构相同，因此在此不再重复。]


```cpp
int HasSample() const { return weightSum > 0; }
const T &GetSample() const { return reservoir; }
Float SampleProbability() const { return reservoirWeight / weightSum; }
Float WeightSum() const { return weightSum; }
```

#parec[
  It is sometimes useful to reset a `WeightedReservoirSampler`
  and restart from scratch with a new stream of samples; the `Reset()`
  method handles this task.
][
  有时我们希望重置一个
  `WeightedReservoirSampler`，并从头开始处理新的样本流；这时可以调用
  `Reset()` 方法来完成这一任务。]

```cpp
void Reset() { reservoirWeight = weightSum = 0; }
```

#parec[
  Remarkably, it is possible to merge two reservoirs into one in
  such a way that the stored sample is kept with the same probability as
  if a single reservoir had considered all of the samples seen by the two.
  Merging two reservoirs is a matter of randomly taking the sample stored
  by the second reservoir with probability defined by its sum of sample
  weights divided by the sum of both reservoirs’ sums of sample weights,
  which in turn is exactly what the `Add()` method does.
][

  一个令人惊讶的性质是：两个蓄水池可以合并为一个，并且合并后的样本保留概率与单个蓄水池处理全部样本的概率完全一致。合并方法就是：以第二个蓄水池权重总和与两个蓄水池权重总和之比为概率，保留第二个蓄水池的样本。而这正是
  `Add()` 方法所完成的操作。]

```cpp
void Merge(const WeightedReservoirSampler &wrs) {
    if (wrs.HasSample())
        Add(wrs.reservoir, wrs.weightSum);
}
```

```cpp
// … additional methods as described above …
```

#parec[
  Remark: The weight of the sample stored in the reservoir is
  stored in `reservoirWeight`; it is needed to compute the value of the
  probability mass function (PMF) for the sample that is kept.
][

  注意：蓄水池中存储的样本的权重保存在 `reservoirWeight`
  中；它在计算保留下来样本的概率质量函数（PMF）时是必须的。]


```cpp
Float reservoirWeight = 0;
T reservoir;
```


```cpp
int HasSample() const { return weightSum > 0; }
const T &GetSample() const { return reservoir; }
Float SampleProbability() const { return reservoirWeight / weightSum; }
Float WeightSum() const { return weightSum; }
```

#parec[
  It is sometimes useful to reset a WeightedReservoirSampler and
  restart from scratch with a new stream of samples; the Reset method
  handles this task.
][
  有时我们希望重置一个
  `WeightedReservoirSampler`，并重新开始处理新的样本流；`Reset`
  方法正是为此而设计的。]
