#import "../template.typ": parec, translator
== The Alias Method

#parec[
  If many samples need to be generated from a discrete distribution, using the approach implemented in the #link("../Monte\_Carlo\_Integration/Sampling\_Using\_the\_Inversion\_Method.html#SampleDiscrete")[SampleDiscrete()] function would be wasteful: each generated sample would require $ cal(O)(n)(n) $ computation. That approach could be improved to $ cal(O)(n)(log n) $ time by computing a cumulative distribution function (CDF) table once and then using binary search to generate each sample, but there is another option that is even more efficient, requiring just $ cal(O)(n)(1) $ time for each sample; that approach is the *alias method*.
][如果需要从离散分布中生成大量样本，使用在 #link("../Monte\_Carlo\_Integration/Sampling\_Using\_the\_Inversion\_Method.html#SampleDiscrete")[SampleDiscrete()] 函数中实现的方法会很低效：每生成一个样本都需要 $ cal(O)(n)(n) $ 的计算。通过事先构造一次累积分布函数（CDF）表并用二分查找生成每个样本，这种方法可以改进为 $ cal(O)(n)(log n) $ 时间，但还有一种更高效的方案 —— 每个样本仅需 $ cal(O)(n)(1) $ 时间；这种方法就是\_别名法（alias method）\_。
]

#parec[
  To understand how the alias method works, first consider the task of sampling from $n$ discrete outcomes, each with equal probability. In that case, computing the value $floor(n x_i)$ gives a uniformly distributed index between 0 and $n-1$ and the corresponding outcome can be selected—no further work is necessary. The alias method allows a similar searchless sampling method if the outcomes have arbitrary probabilities $p_i$.
][
  为了理解别名法的工作原理，先考虑这样一个任务：从 $n$ 个各自等概率的离散结果中采样。在这种情况下，计算值 $floor(n x_i)$ 会得到一个在 $0$ 到 $n-1$ 之间的均匀分布索引，并可以直接选择对应的结果——无需额外工作。当各结果的概率为任意值 $p_i$ 时，别名法允许实现类似的无查找（searchless）采样方法。]

#parec[
  The alias method is based on creating $n$ bins, one for each outcome. Bins are sampled uniformly and then two values stored in each bin are used to generate the final sample: if the ith bin was sampled, then $q_i$ gives the probability of sampling the ith outcome, and otherwise the alias is chosen; it is the index of a single alternative outcome. Though we will not include the proof here, it can be shown that this representation—the ith bin associated with the ith outcome and no more than a single alias per bin—is sufficient to represent arbitrary discrete probability distributions.
][
  别名法基于为每个结果创建 $n$ 个“桶”（bin）。先以均匀概率采样桶，然后用每个桶中存储的两个值来生成最终样本：若采中了第 $i$ 个桶，则以概率 $q\_i$ 采样第 $i$ 个结果，否则选择该桶记录的别名（alias），别名就是某个替代结果的索引。尽管这里不给出证明，但可以表明——将第 $i$ 个桶与第 $i$ 个结果关联，且每个桶最多只保存一个别名——这种表示就足以刻画任意离散概率分布。]

#parec[
  With the alias method, if the probabilities are all the same, then each bin's probability $q\_i$ is one, and it reduces to the earlier example with uniform probabilities. Otherwise, for outcomes $i$ where the associated probability $p\_i$ is greater than the average probability, the outcome $i$ will be stored as the alias in one or more of the other bins. For outcomes $i$ where the associated $p\_i$ is less than the average probability, $q\_i$ will be less than one and the alias will point to one of the higher-probability outcomes.
][
  使用别名法时，如果所有概率都相同，那么每个桶的 $q\_i$ 都为 1，此时就退化为前面描述的均匀采样例子。否则，对于那些其概率 $p\_i$ 高于平均值的结果 $i$，该结果会作为别名存储到其它一个或多个桶中；而对于那些 $p\_i$ 低于平均值的结果，桶中的 $q\_i$ 将小于 1，别名则指向某个概率较高的结果。]

#parec[
  For a specific example, consider the probabilities $p\_i = { \tfrac{1}{2}, \tfrac{1}{4}, \tfrac{1}{8}, \tfrac{1}{8} }$. A corresponding alias table is shown in Table A.1. It is possible to see that, for example, the first sample is chosen with probability $\tfrac{1}{2}$: there is a $\tfrac{1}{4}$ probability of choosing the first table entry, in which case the first sample is always chosen. Otherwise, there is a $\tfrac{1}{4}$ probability of choosing the second and third table entries, and for each, there is a $\tfrac{1}{2}$ chance of choosing the alias, giving in sum an additional $\tfrac{1}{4}$ probability of choosing the first sample. The other probabilities can be verified similarly.
][
  举一个具体例子，设概率为 $p\_i = { \tfrac{1}{2}, \tfrac{1}{4}, \tfrac{1}{8}, \tfrac{1}{8} }$。对应的别名表见表 A.1。例如可以看到，第一个样本被选中的总概率为 $\tfrac{1}{2}$：选择第一个表项的概率为 $\tfrac{1}{4}$，在该表项下第一个样本总是被选中；否则，有 $\tfrac{1}{4}$ 的概率会选择第 2 或第 3 个表项，而每个这些表项都有 $\tfrac{1}{2}$ 的概率选择其别名，从而额外贡献 $\tfrac{1}{4}$ 的概率使得第一个样本被选中。其他样本的概率可以用类似方法校验。]


#parec[
  This alias table makes it possible to generate samples from the distribution of discrete probabilities { $\tfrac{1}{2}$, $\tfrac{1}{4}$, $\tfrac{1}{8}$, $\tfrac{1}{8}$ }.  To generate a sample, an entry is first chosen with uniform probability. Given an entry $i$, its corresponding sample is chosen with probability $q\_i$ and the sample corresponding to its alias index is chosen with probability $1 - q\_i$.
][
  该别名表使得可以从离散概率分布 { $\tfrac{1}{2}$, $\tfrac{1}{4}$, $\tfrac{1}{8}$, $\tfrac{1}{8}$ } 中生成样本。生成样本时，首先以均匀概率选择一个表项（entry）。给定表项 $i$，以概率 $q\_i$ 选择与其对应的样本；以概率 $1 - q\_i$ 选择其别名索引所对应的样本。]

```text
| Index | $q_i$ | Alias Index |
|---|---|---|
| 1 | 1 | n/a |
| 2 | 0.5 | 1 |
| 3 | 0.5 | 1 |
| 4 | 0.5 | 2 |
```

#parec[
  Figure A.1: Graphical Representation of the Alias Table in Table A.1
][
  图 A.1：表 A.1 中别名表的图形表示。]

#parec[
  Figure A.1: Graphical Representation of the Alias Table in Table A.1. One bin is allocated for each outcome and is filled by the outcome's probability, up to $1/n$.  Excess probability is allocated to other bins that have probabilities less than $1/n$ and thus extra space.
][
  图 A.1：表 A.1 中别名表的图形表示。为每个结果分配一个桶（bin），并按结果的概率填充，最多填充到 $1/n$。超过的概率质量会分配到那些概率小于 $1/n$、因此还有空余空间的其它桶中。]

#parec[
  The `AliasTable` class implements algorithms for generating and sampling from alias tables.  As with the other sampling code, its implementation is found in `util/sampling.h` and `util/sampling.cpp`.
][
  `AliasTable` 类实现了用于构造和从别名表采样的算法。与其它采样代码一样，其实现位于 `util/sampling.h` 和 `util/sampling.cpp` 中。]

---

```cpp
#### <<AliasTable Definition>>=
class AliasTable {
  public:
    <<AliasTable Public Methods>>       AliasTable() = default;
       AliasTable(Allocator alloc = {}) : bins(alloc) {}
       AliasTable(pstd::span<const Float> weights, Allocator alloc = {});
       PBRT_CPU_GPU
       int Sample(Float u, Float *pmf = nullptr, Float *uRemapped = nullptr) const;
       std::string ToString() const;
       size_t size() const { return bins.size(); }
       Float PMF(int index) const { return bins[index].p; }
  private:
    <<AliasTable Private Members>>       struct Bin {
           Float q, p;
           int alias;
       };
       pstd::vector<Bin> bins;
};
```

#parec[
  Its constructor takes an array of weights, not necessarily normalized, that give the relative probabilities for the possible outcomes.
][
  它的构造函数接受一个权重数组（不必归一化），用以表示各个可能结果的相对概率。]

---

```cpp
#### <<AliasTable Method Definitions>>=
AliasTable::AliasTable(pstd::span<const Float> weights, Allocator alloc)
    : bins(weights.size(), alloc) {
    <<Normalize weights to compute alias table PDF>>  Float sum = std::accumulate(weights.begin(), weights.end(), 0.);
       for (size_t i = 0; i < weights.size(); ++i)
           bins[i].p = weights[i] / sum;
    <<Create alias table work lists>>  struct Outcome {
           Float pHat;
           size_t index;
       };
       std::vector<Outcome> under, over;
       for (size_t i = 0; i < bins.size(); ++i) {
           <<Add outcome i to an alias table work list>>              Float pHat = bins[i].p * bins.size();
              if (pHat < 1)
                  under.push_back(Outcome{pHat, i});
              else
                  over.push_back(Outcome{pHat, i});
       }
    <<Process under and over work item together>>       while (!under.empty() && !over.empty()) {
           <<Remove items un and ov from the alias table work lists>>       Outcome un = under.back(), ov = over.back();
              under.pop_back();
              over.pop_back();
           <<Initialize probability and alias for un>>       bins[un.index].q = un.pHat;
              bins[un.index].alias = ov.index;
           <<Push excess probability on to work list>>       Float pExcess = un.pHat + ov.pHat - 1;
              if (pExcess < 1)
                  under.push_back(Outcome{pExcess, ov.index});
              else
                  over.push_back(Outcome{pExcess, ov.index});
       }
    <<Handle remaining alias table work items>>       while (!over.empty()) {
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
}
```

#parec[
  The table bin is defined as the structure represented by the following:
][
  表格桶（bin）的结构定义如下：]

```
struct Bin {
    Float q, p;
    int alias;
};
pstd::vector<Bin> bins;
```

#parec[
  We have found that with large numbers of outcomes, especially when the magnitudes of their weights vary significantly, it is important to use double precision to compute their sum so that the alias table initialization algorithm works correctly. Therefore, here std::accumulate takes the double-precision value 0. as its initial value, which in turn causes all its computation to be in double precision. Given the sum of weights, the normalized probabilities can be computed.
][
  我们发现当结果数量很大、或权重大小差异显著时，用双精度去累加权重之和很重要，否则别名表的初始化算法可能因舍入误差而出错。因此这里将 `std::accumulate` 的初始值设为双精度常数 `0.`，以使其计算在双精度下进行。得到权重和后即可计算归一化概率。]


```cpp
Float sum = std::accumulate(weights.begin(), weights.end(), 0.);
for (size_t i = 0; i < weights.size(); ++i)
    bins[i].p = weights[i] / sum;
```

#parec[
  The first stage of the alias table initialization algorithm is to split the outcomes into those that have probability less than the average and those that have probability higher than the average.  Two `std::vector`s of the `Outcome` structure are used for this.
][
  别名表初始化算法的第一步是将结果分成两类：概率小于平均值的（under）和概率大于或等于平均值的（over）。为此使用了两个保存 `Outcome` 结构的 `std::vector`。]


```cpp
struct Outcome {
    Float pHat;
    size_t index;
};
std::vector<Outcome> under, over;
for (size_t i = 0; i < bins.size(); ++i) {
    <<Add outcome i to an alias table work list>>       Float pHat = bins[i].p * bins.size();
       if (pHat < 1)
           under.push_back(Outcome{pHat, i});
       else
           over.push_back(Outcome{pHat, i});
}
```

#parec[
  Here and in the remainder of the initialization phase, we will scale the individual probabilities by the number of bins $n$, working in terms of $p'\_i = p\_i n$.  Thus, the average value is 1, which will be convenient in the following.
][
  在此及后续初始化阶段，我们将把每个概率缩放为与桶数 $n$ 相乘的形式，记为 $p'\_i = p\_i n$。这样平均值就是 1，在后续处理中会很方便。]


```cpp
Float pHat = bins[i].p * bins.size();
if (pHat < 1)
    under.push_back(Outcome{pHat, i});
else
    over.push_back(Outcome{pHat, i});
```

#parec[
  To initialize the alias table, one outcome is taken from `under` and one is taken from `over`.  Together, they make it possible to initialize the element of `bins` that corresponds to the outcome from `under`.  After that bin has been initialized, the outcome from `over` will still have some excess probability that is not yet reflected in `bins`.  It is added to the appropriate work list and the loop executes again until `under` and `over` are empty.  This algorithm runs in $ cal(O)(n)(n) $ time.
][
  为了初始化别名表，从 `under` 中取出一个结果、从 `over` 中取出一个结果。二者结合即可初始化对应于 `under` 中结果的那个桶。在初始化完该桶后，`over` 中的结果仍然会有未分配的剩余概率，这部分作为新的 `pExcess` 被加入到相应的工作列表。循环重复执行直到 `under` 和 `over` 都为空。该算法的时间复杂度为 $ cal(O)(n)(n) $。]


```cpp
while (!under.empty() && !over.empty()) {
    <<Remove items un and ov from the alias table work lists>>       Outcome un = under.back(), ov = over.back();
       under.pop_back();
       over.pop_back();
    <<Initialize probability and alias for un>>       bins[un.index].q = un.pHat;
       bins[un.index].alias = ov.index;
    <<Push excess probability on to work list>>       Float pExcess = un.pHat + ov.pHat - 1;
       if (pExcess < 1)
           under.push_back(Outcome{pExcess, ov.index});
       else
           over.push_back(Outcome{pExcess, ov.index});
}
```


```cpp
Outcome un = under.back(), ov = over.back();
under.pop_back();
over.pop_back();
```

#parec[
  The probability $\hat{p}$ of `un` must be less than one.  We can initialize its bin's `q` with $\hat{p}$, as that is equal to the probability it should be sampled if its bin is chosen.  In order to allocate the remainder of the bin's probability mass, the alias is set to `ov`.  Because $p\_v \ge 1$, it certainly has enough probability to fill the remainder of the bin—we just need $1 -hat(p)$ of it.
][
  `un` 的概率 $\hat{p}$ 必须小于 1。我们可以把该桶的 `q` 初始化为 $\hat{p}$，因为当该桶被选中时正好有 $\hat{p}$ 的概率选择 `un`。为了填满该桶剩余的概率质量，将别名设为 `ov`；由于 $p\_v \ge 1$，`ov` 肯定有足够的概率去填补该剩余部分——我们只需要 $1 -hat(p)$ 的量。]


```cpp
bins[un.index].q = un.pHat;
bins[un.index].alias = ov.index;
```

#parec[
  In initializing `bins[un.index]`, we have consumed $hat(p) = 1$ worth of the scaled probability mass.  The remainder, $hat(p)_"un"$, is the as-yet unallocated probability for `ov.index`; it is added to the appropriate work list based on how much is left.
][
  在初始化 `bins[un.index]` 时，相当于消耗掉了一个单位的缩放概率质量（$\hat{p} = 1$）。剩余量 $"un"".pHat + ov.pHat - 1"$ 即为 `ov.index` 尚未分配的概率，应根据其大小将该剩余量加入相应的工作列表。]


```cpp
Float pExcess = un.pHat + ov.pHat - 1;
if (pExcess < 1)
    under.push_back(Outcome{pExcess, ov.index});
else
    over.push_back(Outcome{pExcess, ov.index});
```

#parec[
  Due to floating-point round-off error, there may be work items remaining on either of the two work lists with the other one empty.  These items have probabilities slightly less than or slightly greater than one and should be given probability $q = 1$ in the alias table.  The fragment that handles this, `<<Handle remaining alias table work items>>`, is not included in the book.
][
  由于浮点舍入误差，可能会出现一种情况：在另一个列表已空的情况下，某一工作列表仍剩若干项。这些项的 $hat(p)$ 会略小于或略大于 1，此时应在别名表中把它们的 $q$ 设为 1。处理这类剩余工作项的代码片段（即 `<<Handle remaining alias table work items>>`）在书中未列出。]

#parec[
  Given an initialized alias table, sampling is easy.  As described before, an entry is chosen with uniform probability and then either the corresponding sample or its alias is returned.  As with the SampleDiscrete() function, a new uniform random sample derived from the original one is optionally returned.
][
  在别名表初始化完成后，采样非常简单。正如前面所述，先以均匀概率选择一个表项，然后返回该表项对应的样本或者其别名。与 SampleDiscrete() 函数类似，通常还可以（可选地）从原始随机数中导出一个新的均匀随机数以供后续使用。]


```cpp
int AliasTable::Sample(Float u, Float *pmf, Float *uRemapped) const {
    <<Compute alias table offset and remapped random sample up>>       int offset = std::min<int>(u * bins.size(), bins.size() - 1);
       Float up = std::min<Float>(u * bins.size() - offset, OneMinusEpsilon);
    if (up < bins[offset].q) {
        <<Return sample for alias table at offset>>           if (pmf)
               *pmf = bins[offset].p;
           if (uRemapped)
               *uRemapped = std::min<Float>(up / bins[offset].q, OneMinusEpsilon);
           return offset;
    } else {
        <<Return sample for alias table at alias[offset]>>           int alias = bins[offset].alias;
           if (pmf)
               *pmf = bins[alias].p;
           if (uRemapped)
               *uRemapped =
                   std::min<Float>((up - bins[offset].q) /
                                   (1 - bins[offset].q), OneMinusEpsilon);
           return alias;
    }
}
```

#parec[
  The index for the chosen entry is found by multiplying the random sample by the number of entries.  Because $u$ was only used for the discrete sampling decision of selecting an initial entry, it is possible to derive a new uniform random sample from it.  That computation is done here to get an independent uniform sample $"up"$ that is used to decide whether to sample the alias at the current entry.
][
  选取表项的索引是通过将随机样本与表项数相乘得到的。由于 $u$ 仅用于离散选择初始表项，因此可以从它导出一个新的均匀随机样本。这里就是计算出这样一个独立的均匀样本 $"up"$，用于决定是否在当前表项上采样别名。]

```cpp
int offset = std::min<int>(u * bins.size(), bins.size() - 1);
Float up = std::min<Float>(u * bins.size() - offset, OneMinusEpsilon);
```

#parec[
  If the initial entry is selected, the various return values are easily computed.
][
  若选中了初始表项，则各返回值容易计算。]


```cpp
if (pmf)
    *pmf = bins[offset].p;
if (uRemapped)
    *uRemapped = std::min<Float>(up / bins[offset].q, OneMinusEpsilon);
return offset;
```

#parec[
  Otherwise the appropriate values for the alias are returned.
][
  否则返回别名对应的适当值。]

```cpp
int alias = bins[offset].alias;
if (pmf)
    *pmf = bins[alias].p;
if (uRemapped)
    *uRemapped =
        std::min<Float>((up - bins[offset].q) /
                        (1 - bins[offset].q), OneMinusEpsilon);
return alias;
```

#parec[
  Beyond sampling, it is useful to be able to query the size of the table and the probability of a given outcome.  These two operations are easily provided.
][
  除了采样之外，能够查询表的大小以及某个结果的概率也是很有用的。这两个操作可以很容易地提供实现。]


```cpp
size_t size() const { return bins.size(); }
Float PMF(int index) const { return bins[index].p; }
```
