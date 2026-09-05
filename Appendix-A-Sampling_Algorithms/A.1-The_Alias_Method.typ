#import "../template.typ": parec, ez_caption

== #ez_caption[The Alias Method][别名法]
<alias-method>

#parec[
  If many samples need to be generated from a discrete distribution, using the approach implemented in the #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] function would be wasteful: each generated sample would require $O(n)$ computation. That approach could be improved to $O(log n)$ time by computing a cumulative distribution function (CDF) table once and then using binary search to generate each sample, but there is another option that is even more efficient, requiring just $O(1)$ time for each sample; that approach is the _alias method_.#footnote[Note that the use of “alias” in this context is unrelated to the aliasing in images that is discussed in #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Theory.html#sec:aliasing")[Section 8.1.3].]
][
  如果要从一个离散分布生成大量样本，使用 #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] 的方法就有些浪费：每个样本都需要 $O(n)$ 的计算。若先构建一次累积分布函数（CDF）表，再用二分查找生成样本，可将每次采样的时间降为 $O(log n)$。不过，还有更高效的选择，每个样本只需 $O(1)$ 时间，这就是_别名法_。#footnote[这里的“别名”（alias）与第 #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Theory.html#sec:aliasing")[8.1.3 节] 讨论的图像混叠（aliasing）无关。]
]

#parec[
  To understand how the alias method works, first consider the task of sampling from $n$ discrete outcomes, each with equal probability. In that case, computing the value $floor(n xi)$ gives a uniformly distributed index between 0 and $n - 1$ and the corresponding outcome can be selected—no further work is necessary. The alias method allows a similar searchless sampling method if the outcomes have arbitrary probabilities $p_i$.
][
  要理解别名法，先考虑从 $n$ 个等概率的离散结果中采样。计算 $floor(n xi)$，即可得到 $0$ 到 $n-1$ 之间均匀分布的索引，直接选择相应结果，无需进一步计算。即使各结果具有任意概率 $p_i$，别名法也能以类似方式进行无需搜索的采样。
]

#parec[
  The alias method is based on creating $n$ bins, one for each outcome. Bins are sampled uniformly and then two values stored in each bin are used to generate the final sample: if the $i$th bin was sampled, then $q_i$ gives the probability of sampling the $i$th outcome, and otherwise the _alias_ is chosen; it is the index of a single alternative outcome. Though we will not include the proof here, it can be shown that this representation—the $i$th bin associated with the $i$th outcome and no more than a single alias per bin—is sufficient to represent arbitrary discrete probability distributions.
][
  别名法先创建 $n$ 个桶，每个结果对应一个。先均匀采样一个桶，再利用该桶存储的两个值生成最终样本：若选中第 $i$ 个桶，就以概率 $q_i$ 选择第 $i$ 个结果，否则选择别名所指的结果；别名是另一个备选结果的索引。这里不列出证明，但可以证明：让第 $i$ 个桶对应第 $i$ 个结果，且每个桶至多保存一个别名，就足以表示任意离散概率分布。
]

#parec[
  With the alias method, if the probabilities are all the same, then each bin’s probability $q_i$ is one, and it reduces to the earlier example with uniform probabilities. Otherwise, for outcomes $i$ where the associated probability $p_i$ is greater than the average probability, the outcome $i$ will be stored as the alias in one or more of the other bins. For outcomes $i$ where the associated $p_i$ is less than the average probability, $q_i$ will be less than one and the alias will point to one of the higher-probability outcomes.
][
  若各结果概率相同，每个桶的 $q_i$ 都为 1，别名法就退化为前述等概率例子。否则，对于概率 $p_i$ 高于平均值的结果 $i$，它会作为别名存入一个或多个其他桶。对于概率 $p_i$ 低于平均值的结果，$q_i$ 小于 1，别名则指向某个概率较高的结果。
]

#parec[
  For a specific example, consider the probabilities $p_i = {1/2, 1/4, 1/8, 1/8}$. A corresponding alias table is shown in @tbl:table:alias-table. It is possible to see that, for example, the first sample is chosen with probability $1/2$: there is a $1/4$ probability of choosing the first table entry, in which case the first sample is always chosen. Otherwise, there is a $1/4$ probability of choosing the second and third table entries, and for each, there is a $1/2$ chance of choosing the alias, giving in sum an additional $1/4$ probability of choosing the first sample. The other probabilities can be verified similarly.
][
  例如，考虑概率 $p_i={1/2,1/4,1/8,1/8}$，对应的一张别名表见 @tbl:table:alias-table。可以验证，第一个结果被选中的概率为 $1/2$：选中第一个表项的概率是 $1/4$，此时必选第一个结果。选中第二、第三个表项的概率也各为 $1/4$；在这两个表项中，各有 $1/2$ 的概率选择别名，合计再为第一个结果贡献 $1/4$ 的概率。其他概率也可类似验证。
]

#figure(
  table(columns: 3, table.header([#ez_caption[Index][索引]], [$q_i$], [#ez_caption[Alias Index][别名索引]]),
    [1], [$1$], [#ez_caption[n/a][不适用]], [2], [$0.5$], [1], [3], [$0.5$], [1], [4], [$0.5$], [2]),
  kind: table,
  caption: [#ez_caption[*A Simple Alias Table.* This alias table makes it possible to generate samples from the distribution of discrete probabilities ${1/2,1/4,1/8,1/8}$. To generate a sample, an entry is first chosen with uniform probability. Given an entry $i$, its corresponding sample is chosen with probability $q_i$ and the sample corresponding to its alias index is chosen with probability $1-q_i$.][*一个简单的别名表。*该表可用于从离散概率分布 ${1/2,1/4,1/8,1/8}$ 中生成样本。先均匀选择一个表项；给定表项 $i$，以概率 $q_i$ 选择相应结果，以概率 $1-q_i$ 选择其别名索引对应的结果。]],
) <table:alias-table>

#parec[
  One way to interpret an alias table is that each bin represents $1/n$ of the total probability mass function. If outcomes are first allocated to their corresponding bins, then the probability mass of outcomes that are greater than $1/n$ must be distributed to other bins that have associated probabilities less than $1/n$. This idea is illustrated in @fig:alias-table, which corresponds to the example of @tbl:table:alias-table.
][
  可以这样理解别名表：每个桶占总概率质量的 $1/n$。若先将各结果放入对应桶，概率质量超过 $1/n$ 的部分，就必须分配到其他概率不足 $1/n$ 的桶中。@fig:alias-table 展示了这一思想，对应的就是 @tbl:table:alias-table 的例子。
]

#figure(image("../pbr-book-website/4ed/Sampling_Algorithms/phaaaf01.svg", width: 85%),
  caption: [#ez_caption[*Graphical Representation of the Alias Table in @tbl:table:alias-table.* One bin is allocated for each outcome and is filled by the outcome’s probability, up to $1/n$. Excess probability is allocated to other bins that have probabilities less than $1/n$ and thus extra space.][*@tbl:table:alias-table 中别名表的图形表示。*每个结果对应一个桶，按该结果的概率填充，最多填入 $1/n$。多余概率分配给概率不足 $1/n$、因而尚有空余空间的其他桶。]],
) <alias-table>

#parec[
  The `AliasTable` class implements algorithms for generating and sampling from alias tables. As with the other sampling code, its implementation is found in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/sampling.h")[`util/sampling.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/sampling.cpp")[`util/sampling.cpp`].
][
  `AliasTable` 类实现了构建别名表及从中采样的算法。与其他采样代码一样，实现位于 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/sampling.h")[`util/sampling.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/sampling.cpp")[`util/sampling.cpp`] 中。
]

#block(sticky: true)[#raw("<<AliasTable Definition>>=")] <fragment-AliasTableDefinition-0>
#block(breakable: false)[
```cpp
class AliasTable {
  public:
    <<AliasTable Public Methods>>
  private:
    <<AliasTable Private Members>>
};
``` <AliasTable>
]

#parec[
  Its constructor takes an array of weights, not necessarily normalized, that give the relative probabilities for the possible outcomes.
][
  构造函数接收一个不一定归一化的权重数组，用来给出各个可能结果的相对概率。
]

#block(sticky: true)[#raw("<<AliasTable Method Definitions>>=") #link(<fragment-AliasTableMethodDefinitions-1>)[▼]] <fragment-AliasTableMethodDefinitions-0>
#block(breakable: false)[
```cpp
AliasTable::AliasTable(pstd::span<const Float> weights, Allocator alloc)
    : bins(weights.size(), alloc) {
    <<Normalize weights to compute alias table PDF>>
    <<Create alias table work lists>>
    <<Process under and over work item together>>
    <<Handle remaining alias table work items>>
}
```
]

#parec[
  The `Bin` structure represents an alias table bin. It stores the probability $q$, the corresponding outcome’s probability $p$, and an alias.
][
  `Bin` 结构表示别名表中的一个桶，存储概率 $q$、对应结果的概率 $p$，以及别名。
]

#block(sticky: true)[#raw("<<AliasTable Private Members>>=")] <fragment-AliasTablePrivateMembers-0>
#block(breakable: false)[
```cpp
struct Bin {
    Float q, p;
    int alias;
};
pstd::vector<Bin> bins;
```
]

#parec[
  We have found that with large numbers of outcomes, especially when the magnitudes of their weights vary significantly, it is important to use double precision to compute their sum so that the alias table initialization algorithm works correctly. Therefore, here `std::accumulate` takes the double-precision value `0.` as its initial value, which in turn causes all its computation to be in double precision. Given the sum of weights, the normalized probabilities can be computed.
][
  我们发现，当结果很多，尤其是各权重的数量级差异很大时，必须用双精度计算权重之和，才能让别名表初始化算法正确工作。因此，这里为 `std::accumulate` 指定双精度初值 `0.`，使其全部累加运算都以双精度进行。得到权重总和后，就能计算归一化概率。
]

#block(sticky: true)[#raw("<<Normalize weights to compute alias table PDF>>=")] <fragment-NormalizemonoweightstocomputealiastablePDF-0>
#block(breakable: false)[
```cpp
Float sum = std::accumulate(weights.begin(), weights.end(), 0.);
for (size_t i = 0; i < weights.size(); ++i)
    bins[i].p = weights[i] / sum;
```
]

#parec[
  The first stage of the alias table initialization algorithm is to split the outcomes into those that have probability less than the average and those that have probability higher than the average. Two `std::vector`s of the `Outcome` structure are used for this.
][
  初始化算法首先把结果分成概率低于平均值和高于平均值的两组，为此使用两个存储 `Outcome` 结构的 `std::vector`。
]

#block(sticky: true)[#raw("<<Create alias table work lists>>=")] <fragment-Createaliastableworklists-0>
#block(breakable: false)[
```cpp
struct Outcome {
    Float pHat;
    size_t index;
};
std::vector<Outcome> under, over;
for (size_t i = 0; i < bins.size(); ++i) {
    <<Add outcome i to an alias table work list>>
}
```
]

#parec[
  Here and in the remainder of the initialization phase, we will scale the individual probabilities by the number of bins $n$, working in terms of $hat(p)_i = p_i n$. Thus, the average $hat(p)$ value is 1, which will be convenient in the following.
][
  从这里开始，初始化阶段将各概率乘以桶数 $n$，即使用 $hat(p)_i=p_i n$。这样，$hat(p)$ 的平均值就是 1，便于后续处理。
]

#block(sticky: true)[#raw("<<Add outcome i to an alias table work list>>=")] <fragment-Addoutcomemonoitoanaliastableworklist-0>
#block(breakable: false)[
```cpp
Float pHat = bins[i].p * bins.size();
if (pHat < 1)
    under.push_back(Outcome{pHat, i});
else
    over.push_back(Outcome{pHat, i});
```
]

#parec[
  To initialize the alias table, one outcome is taken from `under` and one is taken from `over`. Together, they make it possible to initialize the element of `bins` that corresponds to the outcome from `under`. After that bin has been initialized, the outcome from `over` will still have some excess probability that is not yet reflected in `bins`. It is added to the appropriate work list and the loop executes again until `under` and `over` are empty. This algorithm runs in $O(n)$ time.
][
  初始化别名表时，从 `under` 和 `over` 各取一个结果，利用两者初始化 `under` 结果对应的 `bins` 元素。完成这个桶后，`over` 结果仍有一部分概率尚未分配到 `bins`，将其放入适当的工作列表，再次执行循环，直到 `under` 和 `over` 都为空。该算法的运行时间为 $O(n)$。
]

#parec[
  It is not immediately obvious that this approach will successfully initialize the alias table, or that it will necessarily terminate. We will not rigorously show that here, but informally, we can see that at the start, there must be at least one item in each work list unless they all have the same probability (in which case, initialization is trivial). Then, each time through the loop, we initialize one bin, which consumes $hat(p) = 1$ worth of probability mass. With one less bin to initialize and that much less probability to distribute, we have the same average probability over the remaining bins. That brings us to the same setting as the starting condition: some of the remaining items in the list must be above the average and some must be below, unless they are all equal to it.
][
  这种方法为何能成功初始化别名表、为何必然终止，并非一目了然。这里不作严格证明，但可以直观地看到：初始时，除非所有结果等概率，否则两个工作列表中都至少有一项；若全都等概率，初始化很简单。每次循环初始化一个桶，消耗 $hat(p)=1$ 的概率质量。待初始化的桶少了一个，待分配概率也相应减少，剩余桶的平均概率因而保持不变。于是又回到了初始状态：除非剩余各项全都等于平均值，否则必有一些高于平均值，另一些低于平均值。
]

#block(sticky: true)[#raw("<<Process under and over work item together>>=")] <fragment-Processunderandoverworkitemtogether-0>
#block(breakable: false)[
```cpp
while (!under.empty() && !over.empty()) {
    <<Remove items un and ov from the alias table work lists>>
    <<Initialize probability and alias for un>>
    <<Push excess probability on to work list>>
}
```
]

#block(sticky: true)[#raw("<<Remove items un and ov from the alias table work lists>>=")] <fragment-Removeitemsmonounandmonoovfromthealiastableworklists-0>
#block(breakable: false)[
```cpp
Outcome un = under.back(), ov = over.back();
under.pop_back();
over.pop_back();
```
]

#parec[
  The probability $hat(p)_("un")$ of `un` must be less than one. We can initialize its bin’s `q` with $hat(p)_("un")$, as that is equal to the probability it should be sampled if its bin is chosen. In order to allocate the remainder of the bin’s probability mass, the alias is set to `ov`. Because $hat(p)_("ov") gt.eq 1$, it certainly has enough probability to fill the remainder of the bin—we just need $1-hat(p)_("un")$ of it.
][
  `un` 的概率 $hat(p)_("un")$ 必须小于 1。可用它初始化该桶的 `q`，因为选中这个桶时，就应以该概率选中 `un`。为了分配桶内剩余的概率质量，将别名设为 `ov`。由于 $hat(p)_("ov") gt.eq 1$，它必定足以填满剩余空间，只需取出其中的 $1-hat(p)_("un")$ 即可。
]

#block(sticky: true)[#raw("<<Initialize probability and alias for un>>=")] <fragment-Initializeprobabilityandaliasformonoun-0>
#block(breakable: false)[
```cpp
bins[un.index].q = un.pHat;
bins[un.index].alias = ov.index;
```
]

#parec[
  In initializing `bins[un.index]`, we have consumed $hat(p) = 1$ worth of the scaled probability mass. The remainder, `un.pHat + ov.pHat - 1`, is the as-yet unallocated probability for `ov.index`; it is added to the appropriate work list based on how much is left.
][
  初始化 `bins[un.index]` 消耗了 $hat(p)=1$ 的缩放概率质量。余下的 `un.pHat + ov.pHat - 1`，就是 `ov.index` 尚未分配的概率；根据剩余量的大小，将它加入相应的工作列表。
]

#block(sticky: true)[#raw("<<Push excess probability on to work list>>=")] <fragment-Pushexcessprobabilityontoworklist-0>
#block(breakable: false)[
```cpp
Float pExcess = un.pHat + ov.pHat - 1;
if (pExcess < 1)
    under.push_back(Outcome{pExcess, ov.index});
else
    over.push_back(Outcome{pExcess, ov.index});
```
]

#parec[
  Due to floating-point round-off error, there may be work items remaining on either of the two work lists with the other one empty. These items have probabilities slightly less than or slightly greater than one and should be given probability $q=1$ in the alias table. The fragment that handles this, `<<Handle remaining alias table work items>>`, is not included in the book.
][
  由于浮点舍入误差，可能出现一个工作列表已经为空、另一个仍有剩余项的情况。这些项的概率略小于或略大于 1，应在别名表中将它们的概率设为 $q=1$。正文不列出负责此操作的代码片段 `<<Handle remaining alias table work items>>`。
]

#parec[
  Given an initialized alias table, sampling is easy. As described before, an entry is chosen with uniform probability and then either the corresponding sample or its alias is returned. As with the #link("https://pbr-book.org/4ed/Monte_Carlo_Integration/Sampling_Using_the_Inversion_Method.html#SampleDiscrete")[`SampleDiscrete()`] function, a new uniform random sample derived from the original one is optionally returned.
][
  别名表初始化后，采样就很简单。先均匀选择一个表项，再返回相应结果或它的别名。与 `SampleDiscrete()` 一样，也可以选择返回一个由原始样本派生出的新均匀随机样本。
]

#block(sticky: true)[#raw("<<AliasTable Method Definitions>>+=") #link(<fragment-AliasTableMethodDefinitions-0>)[▲]] <fragment-AliasTableMethodDefinitions-1>
#block(breakable: false)[
```cpp
int AliasTable::Sample(Float u, Float *pmf, Float *uRemapped) const {
    <<Compute alias table offset and remapped random sample up>>
    if (up < bins[offset].q) {
        <<Return sample for alias table at offset>>
    } else {
        <<Return sample for alias table at alias[offset]>>
    }
}
```
]

#parec[
  The index for the chosen entry is found by multiplying the random sample by the number of entries. Because `u` was only used for the discrete sampling decision of selecting an initial entry, it is possible to derive a new uniform random sample from it. That computation is done here to get an independent uniform sample `up` that is used to decide whether to sample the alias at the current entry.
][
  将随机样本乘以表项数量，便得到所选表项的索引。由于 `u` 只用于离散地选择初始表项，还可以从中派生新的均匀随机样本。这里计算与初始表项选择独立的均匀样本 `up`，用它决定是否选择当前表项的别名。
]

#block(sticky: true)[#raw("<<Compute alias table offset and remapped random sample up>>=")] <fragment-Computealiastablemonooffsetandremappedrandomsamplemonoup-0>
#block(breakable: false)[
```cpp
int offset = std::min<int>(u * bins.size(), bins.size() - 1);
Float up = std::min<Float>(u * bins.size() - offset, OneMinusEpsilon);
```
]

#parec[
  If the initial entry is selected, the various return values are easily computed.
][
  若选择初始表项，各个返回值很容易计算。
]

#block(sticky: true)[#raw("<<Return sample for alias table at offset>>=")] <fragment-Returnsampleforaliastableatmonooffset-0>
#block(breakable: false)[
```cpp
if (pmf)
    *pmf = bins[offset].p;
if (uRemapped)
    *uRemapped = std::min<Float>(up / bins[offset].q, OneMinusEpsilon);
return offset;
```
]

#parec[
  Otherwise the appropriate values for the alias are returned.
][
  否则，返回别名对应的各个值。
]

#block(sticky: true)[#raw("<<Return sample for alias table at alias[offset]>>=")] <fragment-Returnsampleforaliastableatmonoaliasoffset-0>
#block(breakable: false)[
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
]

#parec[
  Beyond sampling, it is useful to be able to query the size of the table and the probability of a given outcome. These two operations are easily provided.
][
  除了采样，查询表的大小以及某个结果的概率也很有用。这两项操作都容易实现。
]

#block(sticky: true)[#raw("<<AliasTable Public Methods>>=")] <fragment-AliasTablePublicMethods-0>
#block(breakable: false)[
```cpp
size_t size() const { return bins.size(); }
Float PMF(int index) const { return bins[index].p; }
```
]

#include "supplements/A.1-expanded.typ"
