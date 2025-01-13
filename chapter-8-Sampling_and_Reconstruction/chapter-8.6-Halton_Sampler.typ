#import "../template.typ": parec

== Halton Sampler #emoji.warning
<halton-sampler>
#parec[
  The underlying goal of the #link("../Sampling_and_Reconstruction/Stratified_Sampler.html#StratifiedSampler")[`StratifiedSampler`] is to generate a well-distributed but randomized set of sample points, with no two sample points too close together and no excessively large regions of the sample space that have no samples. As Figure #link("../Sampling_and_Reconstruction/Stratified_Sampler.html#fig:sampling-patterns")[8.24] showed, a jittered stratified pattern is better at this than an independent uniform random pattern, although its quality can suffer when samples in adjacent strata happen to be close to the shared boundary of their two strata.
][
  #link("../Sampling_and_Reconstruction/Stratified_Sampler.html#StratifiedSampler")[`StratifiedSampler`];的基本目标是生成一组分布良好但随机化的采样点，确保没有两个采样点过于接近，也没有过大区域的采样空间没有样本。如图#link("../Sampling_and_Reconstruction/Stratified_Sampler.html#fig:sampling-patterns")[8.24];所示，抖动分层采样模式在这方面优于独立的均匀随机模式，尽管当相邻层中的样本恰好接近其两层的共享边界时，其质量可能会受到影响。
]

#parec[
  This section introduces the `HaltonSampler`, which is based on algorithms that directly generate low-discrepancy sample points that are simultaneously well distributed over all the dimensions of the sample—not just one or two dimensions at a time, as the `StratifiedSampler` did.
][
  本节介绍`HaltonSampler`，它基于直接生成低差异性采样点的算法，这些采样点在所有维度上都分布良好，而不仅仅是像`StratifiedSampler`那样一次在一两个维度上。
]

=== Hammersley and Halton Points
<hammersley-and-halton-points>
#parec[
  Hammersley and Halton points are two closely related types of low-discrepancy points that are constructed using the #emph[radical
inverse];. The radical inverse is based on the fact that a positive integer value $a$ can be expressed in a base $b$ with a sequence of digits $d_m (a) , thin dots.h , thin d_2 (a) , thin d_1 (a)$ uniquely determined by

  $ a = sum_(i = 1)^m d_i (a) b^(i - 1) , $

  where all digits $d_i (a)$ are between 0 and $b - 1$.
][
  Hammersley和Halton点是两种密切相关的低差异性点类型，它们是使用#emph[基数反演];构造的。基数反演基于这样一个事实：一个正整数值 $a$ 可以在基数 $b$ 中表示为一系列数字 $d_m (a) , thin dots.h , thin d_2 (a) , thin d_1 (a)$，其唯一确定如下：

  $ a = sum_(i = 1)^m d_i (a) b^(i - 1) , $

  其中所有数字 $d_i (a)$ 都在0到 $b - 1$ 之间。
]

#parec[
  The radical inverse function \$ \_b\$ in base $b$ converts a nonnegative integer $a$ to a fractional value in $\[ 0 , 1 \)$ by reflecting these digits about the radix point:

  $ Phi_b (a) = 0 . d_1 (a) d_2 (a) dots.h d_m (a) = sum_(i = 1)^m d_i (a) b^(- i) . $
][
  基数反演函数\$ \_b $在 基 数$ b $中 将 非 负 整 数$ a $转 换 为$ \[0, 1)\$中的小数值，通过关于小数点反射这些数字：

  $ Phi_b (a) = 0 . d_1 (a) d_2 (a) dots.h d_m (a) = sum_(i = 1)^m d_i (a) b^(- i) . $
]

#parec[
  One of the simplest low-discrepancy sequences is the #emph[van der
Corput sequence];, which is a 1D sequence given by the radical inverse function in base 2:

  $ x_a = Phi_2 (a) , $

  with $a = 0 , 1 , dots.h$. Note that van der Corput points are a point sequence because an arbitrary number of them can be generated in succession; the total number need not be specified in advance. (However, if the number of points $n$ is not a power of 2, then the gaps between points will be of different sizes.)
][
  最简单的低差异性序列之一是#emph[van der
Corput序列];（范德科普特序列），它是一个由基数2的基数反演函数给出的1D序列：

  $ x_a = Phi_2 (a) , $

  其中 $a = 0 , 1 , dots.h$。注意van der Corput点是一个点序列，因为可以连续生成任意数量的点；不需要提前指定总数。（然而，如果点的数量 $n$ 不是2的幂，则点之间的间隙将具有不同的大小。）
]

#parec[
  @tbl:radical-inverse-in-base-2 shows the first few values of the van der Corput sequence. Notice how it recursively splits the intervals of the 1D line in half, generating a sample point at the center of each interval.
][
  @tbl:radical-inverse-in-base-2-zh 展示了范德科普特序列（van der Corput sequence）的前几个值。
  可以注意到，它通过递归地将一维线段的区间对半划分，在每个区间的中心生成一个采样点。
]

#parec[
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (10%, 35%, 55%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          [$a$], [*Base 2*], [$Phi_2(a)$],
          table.hline(stroke: .5pt),
          [0], [0], [$0$],
          [1], [1], [$0.1 = 1 / 2$],
          [2], [10], [$0.01 = 1 / 4$],
          [3], [11], [$0.11 = 3 / 4$],
          [4], [100], [$0.001 = 1 / 8$],
          [5], [101], [$0.101 = 5 / 8$],
          [⋮], [], [],
          table.hline(stroke: 0pt),
        )],
      kind: table,
      caption: [
        The radical inverse $Phi_2(a)$ of the first few nonnegative integers, computed in base 2. Notice how successive values of $Phi_2(a)$ are not close to any of the previous values of $Phi_2(a)$. As more and more values of the sequence are generated, samples are necessarily closer to previous samples, although with a minimum distance that is guaranteed to be reasonably good.
      ],
    )<radical-inverse-in-base-2>
  ]
][
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (10%, 35%, 55%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          [$a$], [*以2为底*], [$Phi_2(a)$],
          table.hline(stroke: .5pt),
          [0], [0], [$0$],
          [1], [1], [$0.1 = 1 / 2$],
          [2], [10], [$0.01 = 1 / 4$],
          [3], [11], [$0.11 = 3 / 4$],
          [4], [100], [$0.001 = 1 / 8$],
          [5], [101], [$0.101 = 5 / 8$],
          [⋮], [], [],
          table.hline(stroke: 0pt),
        )],
      kind: table,
      caption: [
        前几个非负整数在以2为底下的基数倒数 $Phi_2(a)$ 。可以注意到，序列中连续的 $Phi_2(a)$ 值彼此之间并不接近此前的任何值。随着序列中更多的值被生成，样本必然会逐渐接近先前的样本，但仍能保持一个较为合理的最小间隔。
      ],
    )<radical-inverse-in-base-2-zh>
  ]
]

#parec[
  The discrepancy of this sequence is

  $ D^(\*) (P) = O (frac(log n, n)) , $

  which is optimal.
][
  该序列的不一致性为

  $ D^(\*) (P) = O (frac(log n, n)) , $

  这是最优解。
]

#parec[
  The $d$ -dimensional Halton sequence is defined using the radical inverse base $b$, with a different base for each dimension. The bases used must all be relatively prime to each other, so a natural choice is to use the first $d$ prime numbers $(p_1 , dots.h , p_d)$ :
][
  $d$ 维Halton序列使用基数 $b$ 的基数反演定义，每个维度使用不同的基数。所用的基数必须互质，因此自然的选择是使用前 $d$ 个质数 $(p_1 , dots.h , p_d)$ ：
]


#parec[
  $ x_a = (Phi_2 (a) , Phi_3 (a) , Phi_5 (a) , dots.h , Phi_(p_d) (a)) $
][
  $ x_a = (Phi_2 (a) , Phi_3 (a) , Phi_5 (a) , dots.h , Phi_(p_d) (a)) $
]

#parec[
  Like the van der Corput sequence, the Halton sequence can be used even if the total number of samples needed is not known in advance; all prefixes of the sequence are well distributed, so as additional samples are added to the sequence, low discrepancy will be maintained. (However, its distribution is best when the total number of samples is the product of powers of the bases $product_i p_i^(k_i)$ for integer $k_i$.)
][
  类似于范德科普特序列，即使事先不知道所需样本总数，也可以使用Halton序列；序列的所有前缀都具有良好的分布，因此随着样本的增加，低不一致性将得以维持。（然而，当样本总数是基数的幂的乘积 $product_i p_i^(k_i)$ 时，其分布最佳。）
]

#parec[
  The discrepancy of a $d$ -dimensional Halton sequence is
][
  一个 $d$ 维Halton序列的不一致性为
]

#parec[
  $ D_n^(\*) (x_a) = O ((log n)^d / n) , $
][
  $ D_n^(\*) (x_a) = O ((log n)^d / n) , $
]

#parec[
  which is asymptotically optimal.
][
  在渐近意义上是最优的。
]

#parec[
  If the number of samples $n$ is fixed, the #emph[Hammersley point set] can be used, giving slightly lower discrepancy. Hammersley point sets are defined by
][
  如果样本数 $n$ 是固定的，可以使用#emph[Hammersley点集];（用于降低不一致性的一种方法），从而获得略低的不一致性。Hammersley点集定义为
]

#parec[
  $ x_a = (a / n , Phi_(b_1) (a) , Phi_(b_2) (a) , dots.h , Phi_(b_(d - 1)) (a)) , $
][
  $ x_a = (a / n , Phi_(b_1) (a) , Phi_(b_2) (a) , dots.h , Phi_(b_(d - 1)) (a)) , $
]

#parec[
  again with $a = 0 , 1 , dots.h$ where $n$ is the total number of samples to be taken, and as before all the bases $b_i$ are relatively prime. Figure~8.27(a) shows a plot of the first 216 points of the 2D Halton sequence and Figure~8.27(b) shows a set of 256 Hammersley points. (216 Halton points were used in this figure, since they are based on the radical inverses in base~2 and~3, and $2^3 3^3 = 216$.)
][
  其中 $a = 0 , 1 , dots.h$， $n$ 是要取的样本总数，并且如前所述，所有基数 $b_i$ 都是互质的。图8.27(a)显示了2D Halton序列的前216个点的图示，图8.27(b)显示了256个Hammersley点的集合。（在此图中使用了216个Halton点，因为它们基于基数2和3的基反转，且 $2^3 3^3 = 216$。）
]

#parec[
  The RadicalInverse() function computes the radical inverse for a given number a using the baseIndexth prime number as the base. (It and related functions are defined in the files util/lowdiscrepancy.h and util/lowdiscrepancy.cpp.)
][
  RadicalInverse()函数使用第baseIndex个素数作为基数计算给定数字a的基反转。（它和相关函数定义在文件util/lowdiscrepancy.h和util/lowdiscrepancy.cpp中。）
]

#parec[
  It does so by computing the digits $d_i$ starting with $d_1$ and then computing a series $v_i$ where $v_1 = d_1$, $v_2 = b d_1 + d_2$, such that
][
  通过从 $d_1$ 开始计算数字 $d_i$，然后计算序列 $v_i$，其中 $v_1 = d_1$， $v_2 = b d_1 + d_2$，以此类推
]

$ v_n = b^(n - 1) d_1 + b^(n - 2) d_2 + dots.h + d_n $


#parec[
  (For example, with base 10, it would convert the value 1234 to 4321.) The value of $v_n$ can be found entirely using integer arithmetic, without accumulating any round-off error.
][
  （例如，基数为10时，会将值1234转换为4321。） $v_n$ 的值可以完全使用整数运算找到，不会累积任何舍入误差。
]

#parec[
  The final value of the radical inverse is then found by converting to floating-point and multiplying by $1 / b^m$, where $m$ is the number of digits in the value, to get the value in Equation~(8.19). The factor for this multiplication is built up in invBaseM as the digits are processed.
][
  基反转的最终值通过转换为浮点数并乘以 $1 / b^m$ 来找到，其中 $m$ 是值中的数字数，以获得方程(8.19)中的值。此乘法的因子在处理数字时在invBaseM中逐步建立。
]

```
<<Low Discrepancy Inline Functions>>=
Float RadicalInverse(int baseIndex, uint64_t a) {
    int base = Primes[baseIndex];
    Float invBase = (Float)1 / (Float)base, invBaseM = 1;
    uint64_t reversedDigits = 0;
    while (a) {
        <<Extract least significant digit from a and update reversedDigits>>
    }
    return std::min(reversedDigits * invBaseM, OneMinusEpsilon);
}
```

The value of a for the next loop iteration is found by dividing by the base; the remainder is the least significant digit of the current value of a.

```
<<Extract least significant digit from a and update reversedDigits>>=
uint64_t next = a / base;
uint64_t digit = a - next * base;
reversedDigits = reversedDigits * base + digit;
invBaseM *= invBase;
a = next;
```

It will also be useful to be able to compute the inverse of the radical inverse function; the InverseRadicalInverse() function takes the reversed integer digits in a given base, corresponding to the final value of reversedDigits in the RadicalInverse() function, and returns the index a that corresponds to them. Note that in order to be able to compute the inverse correctly, the total number of digits in the original value must be provided: for example, both 1234 and 123400 are converted to 4321 after the integer-only part of the radical inverse algorithm; trailing zeros become leading zeros, which are lost.

```
<<Low Discrepancy Inline Functions>>+=
uint64_t InverseRadicalInverse(uint64_t inverse, int base, int nDigits) {
    uint64_t index = 0;
    for (int i = 0; i < nDigits; ++i) {
        uint64_t digit = inverse % base;
        inverse /= base;
        index = index * base + digit;
    }
    return index;
}
```

=== Randomization via Scrambling


One disadvantage of the fact that the Hammersley set and Halton sequence are both fully deterministic is that it is not possible to estimate variance by computing multiple independent estimates of an integral with them. Furthermore, they both have the shortcoming that as the base increases, lower-dimensional projections of sample values can exhibit regular patterns (see Figure 8.28(a)). Because, for example, 2D projections of these points are used for sampling points on light sources, these patterns can lead to visible error in rendered images.




Figure 8.28: Plot of Halton Sample Values with and without Scrambling. (a) In higher dimensions, projections of sample values start to exhibit regular structure. Here, points from the dimensions are shown. (b) Scrambled sequences based on Equation (8.20) break up this structure by permuting the digits of sample indices.


These issues can be addressed using techniques that randomize the points that are generated by these algorithms while still maintaining low discrepancy. A family of such techniques are based on randomizing the digits of each sample coordinate with random permutations. Over all permutations, each coordinate value is then uniformly distributed over , unlike as with the original point. These techniques are often referred to as scrambling.

Scrambling can be performed by defining a set of permutations for each base , where each digit has a distinct permutation of associated with it. (In the following, we will consider scrambling a single dimension of a -dimensional sample point and thus drop the base from our notation, leaving it implicit. In practice, all dimensions are independently scrambled.)

Given such a set of permutations, we can define the scrambled radical inverse where a corresponding permutation is applied to each digit:

#parec[
  Note that the same permutations ( \_i ) must be used for generating all the sample points for a given base.
][
  请注意，对于给定的基数，必须使用相同的排列 ( \_i ) 来生成所有的样本点。
]

#parec[
  There are a few subtleties related to the permutations. First, with the regular radical inverse, computation of a sample dimension's value can stop once the remaining digits ( d\_i ) are 0, as they will have no effect on the final result.
][
  关于排列，有一些细微之处。首先，对于常规的基数逆序，一旦剩余的位 ( d\_i ) 为0，样本维度的值的计算就可以停止，因为它们对最终结果没有影响。
]

#parec[
  With the scrambled radical inverse, the zero digits must continue to be processed. If they are not, then scrambling only corresponds to a permutation of the unscrambled sample values in each dimension, which does not give a uniform distribution over ( \[0, 1) ).
][
  对于扰乱基数逆序，零位必须继续处理。如果不这样做，扰乱就仅仅相当于对每个维度中未扰乱样本值的排列，这样不会在 ( \[0, 1) ) 区间上产生均匀分布。
]

#parec[
  (In practice, it is only necessary to consider enough digits so that any more digits make no difference to the result given the limits of floating-point precision.)
][
  （实际上，只需要考虑足够多的位，以便在浮点精度的限制下，更多的位不会影响结果。）
]

#parec[
  Second, it is important that each digit has its own permutation. One way to see why this is important is to consider the trailing 0 digits: if the same permutation is used for all of them, then all scrambled values will have the same digit value repeating infinitely at their end.
][
  其次，重要的是每个位都有其自己的排列。理解这一点的重要性的一种方法是考虑尾随的0位：如果对所有这些位使用相同的排列，那么所有扰乱的值将在其末尾无限重复相同的位值。
]

#parec[
  Once again, ( \[0, 1) ) would not be sampled uniformly.
][
  再一次，( \[0, 1) ) 将不会被均匀采样。
]

#parec[
  The choice of permutations can affect the quality of the resulting points. In the following implementation, we will use random permutations.
][
  排列的选择会影响生成点的质量。在以下实现中，我们将使用随机排列。
]

#parec[
  That alone is enough to break up the structure of the points, as shown in Figure 8.28(b). However, carefully constructed deterministic permutations have been shown to reduce error for some integration problems.
][
  仅此一项就足以打破点的结构，如图8.28(b)所示。然而，精心构造的确定性排列已被证明可以减少某些积分问题的误差。
]

#parec[
  See the "Further Reading" section for more information.
][
  有关更多信息，请参阅“进一步阅读”部分。
]

#parec[
  The `DigitPermutation` utility class manages allocation and initialization of a set of digit permutations for a single base ( b ).
][
  `DigitPermutation`实用类管理单个基数 ( b ) 的一组位排列的分配和初始化。
]

#parec[
  #strong[DigitPermutation Definition]
][
  #strong[DigitPermutation定义]
]

```cpp
class DigitPermutation {
  public:
    **DigitPermutation Public Methods**       DigitPermutation(int base, uint32_t seed, Allocator alloc)
           : base(base) {
           **Compute number of digits needed for base**              nDigits = 0;
              Float invBase = (Float)1 / (Float)base, invBaseM = 1;
              while (1 - (base - 1) * invBaseM < 1) {
                  ++nDigits;
                  invBaseM *= invBase;
              }
           permutations = alloc.allocate_object<uint16_t>(nDigits * base);
           **Compute random permutations for all digits**              for (int digitIndex = 0; digitIndex < nDigits; ++digitIndex) {
                  uint64_t dseed = Hash(base, digitIndex, seed);
                  for (int digitValue = 0; digitValue < base; ++digitValue) {
                      int index = digitIndex * base + digitValue;
                      permutations[index] = PermutationElement(digitValue, base, dseed);
                  }
              }
       }
       int Permute(int digitIndex, int digitValue) const {
           return permutations[digitIndex * base + digitValue];
       }
       std::string ToString() const;
  private:
    **DigitPermutation Private Members**       int base, nDigits;
       uint16_t *permutations;
};
```



#parec[
  All the permutations are stored in a single flat array: the first `base` elements of it are the permutation for the first digit, the next `base` elements are the second digit's permutation, and so forth.
][
  所有的排列都存储在一个单一的平面数组中：它的前`base`个元素是第一个位的排列，接下来的`base`个元素是第二个位的排列，依此类推。
]

#parec[
  The `DigitPermutation` constructor's two tasks are to determine how many digits must be handled and then to generate a permutation for each one.
][
  `DigitPermutation`构造函数的两个任务是确定必须处理的位数，然后为每个位生成一个排列。
]

#parec[
  #strong[DigitPermutation Public Methods]
][
  #strong[DigitPermutation公共方法]
]

```cpp
DigitPermutation(int base, uint32_t seed, Allocator alloc)
    : base(base) {
    **Compute number of digits needed for base**       nDigits = 0;
       Float invBase = (Float)1 / (Float)base, invBaseM = 1;
       while (1 - (base - 1) * invBaseM < 1) {
           ++nDigits;
           invBaseM *= invBase;
       }
    permutations = alloc.allocate_object<uint16_t>(nDigits * base);
    **Compute random permutations for all digits**       for (int digitIndex = 0; digitIndex < nDigits; ++digitIndex) {
           uint64_t dseed = Hash(base, digitIndex, seed);
           for (int digitValue = 0; digitValue < base; ++digitValue) {
               int index = digitIndex * base + digitValue;
               permutations[index] = PermutationElement(digitValue, base, dseed);
           }
       }
}
```


#parec[
  To save a bit of storage, unsigned 16-bit integers are used for the digit values.
][
  为了节省一些存储空间，使用无符号16位整数表示位值。
]

#parec[
  As such, the maximum base allowed is ( 2^{16} ). `pbrt` only supports up to 1,000 dimensions for Halton points, which corresponds to a maximum base of 7,919, the 1,000th prime number, which is comfortably below that limit.
][
  因此，允许的最大基数是 ( 2^{16} )。`pbrt`仅支持最多1,000个维度的Halton点，这对应于最大基数7,919，即第1,000个素数，远低于该限制。
]

#parec[
  #strong[DigitPermutation Private Members]
][
  #strong[DigitPermutation私有成员]
]

```cpp
int base, nDigits;
uint16_t *permutations;
```

#parec[
  The trailing zero-valued digits must be processed until the digit ( d\_m ) is reached where ( b^{-m} ) is small enough that if the product of ( b^{-m} ) with the largest digit is subtracted from 1 using floating-point arithmetic, the result is still 1.
][
  尾随的零值位必须处理，直到达到位 ( d\_m )，其中 ( b^{-m} ) 足够小，以至于如果用浮点运算从1中减去 ( b^{-m} ) 与最大位的乘积，结果仍然是1。
]

#parec[
  At this point, no subsequent digits matter, regardless of the permutation.
][
  此时，无论排列如何，后续的位都不再重要。
]

#parec[
  The `DigitPermutation` constructor performs this check using precisely the same logic as the (soon to be described) #link("<ScrambledRadicalInverse>")[ScrambledRadicalInverse()] function does, to be sure that they are in agreement about how many digits need to be handled.
][
  `DigitPermutation`构造函数使用与（即将描述的）#link("<ScrambledRadicalInverse>")[ScrambledRadicalInverse()];函数完全相同的逻辑执行此检查，以确保它们在需要处理多少位方面达成一致。
]

#parec[
  #strong[Compute number of digits needed for base]
][
  #strong[计算基数所需的位数]
]

```cpp
nDigits = 0;
Float invBase = (Float)1 / (Float)base, invBaseM = 1;
while (1 - (base - 1) * invBaseM < 1) {
    ++nDigits;
    invBaseM *= invBase;
}
```


#parec[
  The permutations are computed using #link("../Utilities/Mathematical_Infrastructure.html#PermutationElement")[PermutationElement()];, which is provided with a different seed for each digit index so that the permutations are independent.
][
  排列是使用#link("../Utilities/Mathematical_Infrastructure.html#PermutationElement")[PermutationElement()];计算的，每个位索引使用不同的种子以确保排列的独立性。
]

#parec[
  #strong[Compute random permutations for all digits]
][
  #strong[为所有位计算随机排列]
]

```cpp
for (int digitIndex = 0; digitIndex < nDigits; ++digitIndex) {
    uint64_t dseed = Hash(base, digitIndex, seed);
    for (int digitValue = 0; digitValue < base; ++digitValue) {
        int index = digitIndex * base + digitValue;
        permutations[index] = PermutationElement(digitValue, base, dseed);
    }
}
```



#parec[
  The `Permute()` method takes care of indexing into the `permutations` array to return the permuted digit value for a given digit index and the unpermuted value of the digit.
][
  `Permute()`方法负责索引到`permutations`数组中，以返回给定位索引和未排列位值的排列位值。
]

#parec[
  #strong[DigitPermutation Public Methods]
][
  #strong[DigitPermutation公共方法]
]

```cpp
int Permute(int digitIndex, int digitValue) const {
    return permutations[digitIndex * base + digitValue];
}
```


#parec[
  Finally, the `ComputeRadicalInversePermutations()` utility function returns a vector of `DigitPermutation`s, one for each base up to the maximum.
][
  最后，`ComputeRadicalInversePermutations()`实用函数返回一个`DigitPermutation`的向量，每个基数一个，直到最大值。
]

#parec[
  #strong[Low Discrepancy Function Definitions]
][
  #strong[低差异函数定义]
]

```cpp
pstd::vector<DigitPermutation> *
ComputeRadicalInversePermutations(uint32_t seed, Allocator alloc) {
    pstd::vector<DigitPermutation> *perms =
        alloc.new_object<pstd::vector<DigitPermutation>>(alloc);
    perms->resize(PrimeTableSize);
    for (int i = 0; i < PrimeTableSize; ++i)
        (*perms)[i] = DigitPermutation(Primes[i], seed, alloc);
    return perms;
}
```

#parec[
  With `DigitPermutation`s available, we can implement the `ScrambledRadicalInverse()` function.
][
  有了`DigitPermutation`，我们可以实现`ScrambledRadicalInverse()`函数。
]

#parec[
  Its structure is generally the same as #link("<RadicalInverse>")[RadicalInverse()];, though here we can see that it uses a different termination criterion, as was discussed with the implementation of #strong[Compute number of digits needed for base] above.
][
  其结构通常与#link("<RadicalInverse>")[RadicalInverse()];相同，不过在这里我们可以看到它使用了不同的终止标准，如上面#strong[计算基数所需的位数];的实现中所讨论的那样。
]

#parec[
  #strong[Low Discrepancy Inline Functions]
][
  #strong[低差异内联函数]
]

```cpp
Float ScrambledRadicalInverse(int baseIndex, uint64_t a,
                              const DigitPermutation &perm) {
    int base = Primes[baseIndex];
    Float invBase = (Float)1 / (Float)base, invBaseM = 1;
    uint64_t reversedDigits = 0;
    int digitIndex = 0;
    while (1 - (base - 1) * invBaseM < 1) {
        **Permute least significant digit from a and update reversedDigits**           uint64_t next = a / base;
           int digitValue = a - next * base;
           reversedDigits =
               reversedDigits * base + perm.Permute(digitIndex, digitValue);
           invBaseM *= invBase;
           ++digitIndex;
           a = next;
    }
    return std::min(invBaseM * reversedDigits, OneMinusEpsilon);
}
```

#parec[
  Each digit is handled the same way as in #link("<RadicalInverse>")[RadicalInverse()];, with the only change being that it is permuted using the provided #link("<DigitPermutation>")[DigitPermutation];.
][
  每个位的处理方式与#link("<RadicalInverse>")[RadicalInverse()];相同，唯一的变化是它使用提供的#link("<DigitPermutation>")[DigitPermutation];进行排列。
]

#parec[
  #strong[Permute least significant digit from ( a ) and update (
    reversedDigits )]
][
  #strong[从 ( a ) 中排列最低有效位并更新 ( reversedDigits )]
]

```cpp
uint64_t next = a / base;
int digitValue = a - next * base;
reversedDigits =
    reversedDigits * base + perm.Permute(digitIndex, digitValue);
invBaseM *= invBase;
++digitIndex;
a = next;
```

#parec[
  An even more effective scrambling approach defines digit permutations that not only depend on the index of the current digit ( i ), but that also depend on the values of the previous digits ( d\_1 d\_2 d\_{i-1} ).
][
  一种更有效的扰乱方法定义了不仅依赖于当前位索引 ( i ) 的位排列，还依赖于前面位 ( d\_1 d\_2 d\_{i-1} ) 的值。
]

#parec[
  This approach is known as #emph[Owen scrambling];, after its inventor.
][
  这种方法被称为#emph[Owen扰乱];（以其发明者命名）。
]

#parec[
  Remarkably, it can be shown that for a class of smooth functions, the integration error with this scrambling technique decreases at a rate.
][
  值得注意的是，可以证明，对于一类平滑函数，使用这种扰乱技术的积分误差以一定的速率减少。
]


#parec[
  $ cal(O) (n^(- 3 / 2) (log n)^(frac(d - 1, 2))) , $

  which is a substantial improvement over the $ cal(O) (n^(- 1 / 2)) $ error rate for regular Monte Carlo.
][
  $ cal(O) (n^(- 3 / 2) (log n)^(frac(d - 1, 2))) , $

  这比常规蒙特卡罗的 $ cal(O) (n^(- 1 / 2)) $ 错误率有了显著的改善。
]

#parec[
  The reason for this benefit can be understood in terms of Owen scrambling being more effective at breaking up structure in the sample values while still maintaining their low discrepancy.
][
  这种优势可以理解为Owen扰乱在打破样本值结构方面的高效性，同时仍然保持其低差异性。
]

#parec[
  Its effect is easiest to see when considering the trailing zero digits that are present in all sample values: if they are all permuted with the same permutation at each digit, they will end up with the same values, which effectively means that there is some structure shared among all the samples.
][
  这种效果在观察所有样本值中的尾随零位时最为明显：如果它们在每个位上都用相同的置换进行置换，它们将最终具有相同的值，这实际上意味着所有样本之间共享某种结构。
]

#parec[
  Owen scrambling eliminates this regularity, to the benefit of integration error. (It also benefits the earlier digits in a similar manner, though the connection is less immediately intuitive.)
][
  Owen扰乱消除了这种规律性，从而减少积分误差。（它也以类似方式优化早期数字，尽管这种联系不那么直观。）
]

#parec[
  The challenge with Owen scrambling is that it is infeasible to explicitly store all the permutations, as the number of them that are required grows exponentially with the number of digits.
][
  Owen扰乱的挑战在于无法显式存储所有置换，因为所需的置换数量随着位数的增加而呈指数增长。
]

#parec[
  In this case, we can once again take advantage of the `PermutationElement()` function and its capability of permuting without explicitly representing the full permutation.
][
  在这种情况下，我们可以利用`PermutationElement()`函数在不显式表示完整置换的情况下进行置换。
]

#parec[
  #strong[\<\>];+= #link("<fragment-LowDiscrepancyInlineFunctions-2>")[↑] #link("Sobol_Samplers.html#fragment-LowDiscrepancyInlineFunctions-4")[↓]
][
  #strong[\<\>];+= #link("<fragment-LowDiscrepancyInlineFunctions-2>")[↑] #link("Sobol_Samplers.html#fragment-LowDiscrepancyInlineFunctions-4")[↓]
]


=== Halton Sampler Implementation
<halton-sampler-implementation>
#parec[
  Given all the capabilities introduced so far in this section, it is not too hard to implement the `HaltonSampler`, which generates samples using the Halton sequence.
][
  鉴于本节中介绍的所有功能，实现用于生成Halton序列样本的`HaltonSampler`并不困难。
]

```cpp
class HaltonSampler {
  public:
    // HaltonSampler Public Methods
    HaltonSampler(int samplesPerPixel, Point2i fullResolution,
           RandomizeStrategy randomize = RandomizeStrategy::PermuteDigits, int seed = 0,
                     Allocator alloc = {});

       PBRT_CPU_GPU
       static constexpr const char *Name() { return "HaltonSampler"; }
       static HaltonSampler *Create(const ParameterDictionary &parameters,
                                    Point2i fullResolution, const FileLoc *loc,
                                    Allocator alloc);
       int SamplesPerPixel() const { return samplesPerPixel; }

       PBRT_CPU_GPU
       RandomizeStrategy GetRandomizeStrategy() const { return randomize; }
       void StartPixelSample(Point2i p, int sampleIndex, int dim) {
           haltonIndex = 0;
           int sampleStride = baseScales[0] * baseScales[1];
           // Compute Halton sample index for first sample in pixel p
           if (sampleStride > 1) {
                  Point2i pm(Mod(p[0], MaxHaltonResolution), Mod(p[1], MaxHaltonResolution));
                  for (int i = 0; i < 2; ++i) {
                      uint64_t dimOffset =
                          (i == 0) ? InverseRadicalInverse(pm[i], 2, baseExponents[i])
                                   : InverseRadicalInverse(pm[i], 3, baseExponents[i]);
                      haltonIndex +=
                          dimOffset * (sampleStride / baseScales[i]) * multInverse[i];
                  }
                  haltonIndex %= sampleStride;
              }
           haltonIndex += sampleIndex * sampleStride;
           dimension = std::max(2, dim);
       }
       Float Get1D() {
           if (dimension >= PrimeTableSize)
               dimension = 2;
           return SampleDimension(dimension++);
       }
       Point2f Get2D() {
           if (dimension + 1 >= PrimeTableSize)
               dimension = 2;
           int dim = dimension;
           dimension += 2;
           return {SampleDimension(dim), SampleDimension(dim + 1)};
       }
       Point2f GetPixel2D() {
           return {RadicalInverse(0, haltonIndex >> baseExponents[0]),
                   RadicalInverse(1, haltonIndex / baseScales[1])};
       }
       Sampler Clone(Allocator alloc);
       std::string ToString() const;
  private:
    // HaltonSampler Private Methods
       static uint64_t multiplicativeInverse(int64_t a, int64_t n) {
           int64_t x, y;
           extendedGCD(a, n, &x, &y);
           return Mod(x, n);
       }
       static void extendedGCD(uint64_t a, uint64_t b, int64_t *x, int64_t *y) {
           if (b == 0) {
               *x = 1;
               *y = 0;
               return;
           }
           int64_t d = a / b, xp, yp;
           extendedGCD(b, a % b, &xp, &yp);
           *x = yp;
           *y = xp - (d * yp);
       }
       Float SampleDimension(int dimension) const {
           if (randomize == RandomizeStrategy::None)
               return RadicalInverse(dimension, haltonIndex);
           else if (randomize == RandomizeStrategy::PermuteDigits)
               return ScrambledRadicalInverse(dimension, haltonIndex,
                          (*digitPermutations)[dimension]);
           else
               return OwenScrambledRadicalInverse(dimension, haltonIndex,
                                                  MixBits(1 + (dimension << 4)));
       }
    // HaltonSampler Private Members
       int samplesPerPixel;
       RandomizeStrategy randomize;
       pstd::vector<DigitPermutation> *digitPermutations = nullptr;
       static constexpr int MaxHaltonResolution = 128;
       Point2i baseScales, baseExponents;
       int multInverse[2];
       int64_t haltonIndex = 0;
       int dimension = 0;
};
```


#parec[
  For the pixel samples, the `HaltonSampler` scales the domain of the first two dimensions of the Halton sequence from $\[ 0 , 1 \)^2$ so that it covers an integral number of pixels in each dimension. In doing so, it ensures that the pixel samples for adjacent pixels are well distributed with respect to each other. (This is a useful property that the stratified sampler does not guarantee.)
][
  对于像素样本，`HaltonSampler`将Halton序列的前两个维度的域从 $\[ 0 , 1 \)^2$ 缩放，以便它覆盖每个维度中的整数数量的像素。这样做确保了相邻像素的像素样本彼此之间分布良好。这是分层采样器无法保证的有用属性。
]

#parec[
  Its constructor takes the full image resolution, even if only a subwindow of it is being rendered. This allows it to always produce the same sample values at each pixel, regardless of whether only some of the pixels are being rendered. This is another place where we have tried to ensure that the renderer's operation is deterministic: rendering a small crop window of an image when debugging does not affect the sample values generated at those pixels if the #link("<HaltonSampler>")[HaltonSampler] is being used.
][
  其构造函数接受完整的图像分辨率，即使仅渲染其中的一个子窗口。这使得它可以始终在每个像素上生成相同的样本值，而不管是否仅渲染了一些像素。这是我们试图确保渲染器操作确定性的另一个地方：在调试时渲染图像的小裁剪窗口不会影响在这些像素上生成的样本值，如果使用#link("<HaltonSampler>")[HaltonSampler];。
]

```cpp
HaltonSampler::HaltonSampler(int samplesPerPixel, Point2i fullRes,
        RandomizeStrategy randomize, int seed, Allocator alloc)
    : samplesPerPixel(samplesPerPixel), randomize(randomize) {
    if (randomize == RandomizeStrategy::PermuteDigits)
        digitPermutations = ComputeRadicalInversePermutations(seed, alloc);
    // Find radical inverse base scales and exponents that cover sampling area
    for (int i = 0; i < 2; ++i) {
           int base = (i == 0) ? 2 : 3;
           int scale = 1, exp = 0;
           while (scale < std::min(fullRes[i], MaxHaltonResolution)) {
               scale *= base;
               ++exp;
           }
           baseScales[i] = scale;
           baseExponents[i] = exp;
       }
    // Compute multiplicative inverses for baseScales
       multInverse[0] = multiplicativeInverse(baseScales[1], baseScales[0]);
       multInverse[1] = multiplicativeInverse(baseScales[0], baseScales[1]);
}
```


#parec[
  For this and the following samplers that allow the user to select a randomization strategy, it will be helpful to have an enumeration that encodes them. (Note that the `FastOwen` option is not supported by the #link("<HaltonSampler>")[HaltonSampler];.)
][
  对于允许用户选择随机化策略的这个和以下采样器，拥有一个编码它们的枚举将是有帮助的。（请注意，#link("<HaltonSampler>")[HaltonSampler];不支持`FastOwen`选项。）
]

```cpp
enum class RandomizeStrategy { None, PermuteDigits, FastOwen, Owen };
```


#parec[
  Some sample generation approaches are naturally pixel-based and fit in easily to the `Sampler` interface as it has been presented so far. For example, the #link("../Sampling_and_Reconstruction/Stratified_Sampler.html#StratifiedSampler")[StratifiedSampler] can easily start generating samples in a new pixel after its `StartPixelSample()` method has been called—it just needs to set `RNG` state so that it is consistent over all the samples in the pixel.
][
  一些样本生成方法自然是基于像素的，并且可以很容易地适应到目前为止所呈现的`Sampler`接口。例如，#link("../Sampling_and_Reconstruction/Stratified_Sampler.html#StratifiedSampler")[StratifiedSampler];可以在其`StartPixelSample()`方法被调用后轻松开始在新像素中生成样本——它只需要设置`RNG`状态，以便在像素中的所有样本上保持一致。
]

#parec[
  Others, like the `HaltonSampler`, naturally generate consecutive samples that are spread across the entire image, visiting completely different pixels if the samples are generated in succession. (Many such samplers are effectively placing each additional sample such that it fills the largest hole in the $n$ -dimensional sample space, which leads to subsequent samples being inside different pixels.) These sampling algorithms are somewhat problematic with the `Sampler` interface as described so far: the `StartPixelSample()` method must be able to set the sampler's state so that it is able to generate samples for any requested pixel.
][
  其他的，比如`HaltonSampler`，自然会生成分布在整个图像上的连续样本，如果连续生成样本，则会访问完全不同的像素。许多这样的采样器实际上是在将每个附加样本放置在 $n$ 维样本空间中的最大空洞中，这导致后续样本位于不同的像素中。这些采样算法在目前为止描述的`Sampler`接口中有些问题：`StartPixelSample()`方法必须能够设置采样器的状态，以便能够为任何请求的像素生成样本。
]

#parec[
  @tbl:haltonSampler-generates illustrates the issue for Halton samples. The second column shows 2D Halton sample values in $\[ 0 , 1 \)^2$, which are then multiplied by the image resolution in each dimension to get sample positions in the image plane (here we are considering a $2 times 3$ image for simplicity). Note that here, each pixel is visited by each sixth sample. If we are rendering an image with three samples per pixel, then to generate all the samples for the pixel $(0 , 0)$, we need to generate the samples with indices 0, 6, and 12.
][
  @tbl:haltonSampler-generates-zh 展示了Halton样本的问题。第二列显示了 $\[ 0 , 1 \)^2$ 中的2D Halton样本值，然后乘以每个维度的图像分辨率以获得图像平面中的样本位置（这里为了简单起见，我们考虑一个 $2 times 3$ 的图像）。请注意，这里每个像素被每第六个样本访问一次。如果我们正在渲染一个每像素三个样本的图像，那么要生成像素 $(0 , 0)$ 的所有样本，我们需要生成索引为0、6和12的样本。
]

#parec[
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (20%, 40%, 40%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.header(
            [Sample index],
            [$\[ 0 , 1 \)^2$ sample coordinates],
            [Pixel sample coordinates],
          ),
          table.hline(stroke: .5pt),
          [0], [$(0.000000 , 0.000000)$], [$(0.000000 , 0.000000)$],
          [1], [$(0.500000 , 0.333333)$], [$(1.000000 , 1.000000)$],
          [2], [$(0.250000 , 0.666667)$], [$(0.500000 , 2.000000)$],
          [3], [$(0.750000 , 0.111111)$], [$(1.500000 , 0.333333)$],
          [4], [$(0.125000 , 0.444444)$], [$(0.250000 , 1.333333)$],
          [5], [$(0.625000 , 0.777778)$], [$(1.250000 , 2.333333)$],
          [6], [$(0.375000 , 0.222222)$], [$(0.750000 , 0.666667)$],
          [7], [$(0.875000 , 0.555556)$], [$(1.750000 , 1.666667)$],
          [8], [$(0.062500 , 0.888889)$], [$(0.125000 , 2.666667)$],
          [9], [$(0.562500 , 0.037037)$], [$(1.125000 , 0.111111)$],
          [10], [$(0.312500 , 0.370370)$], [$(0.625000 , 1.111111)$],
          [11], [$(0.812500 , 0.703704)$], [$(1.625000 , 2.111111)$],
          [12], [$(0.187500 , 0.148148)$], [$(0.375000 , 0.444444)$],
          […], […], […],
          table.hline(stroke: 0pt),
        )],
      kind: table,
      caption: [
        The #link("<HaltonSampler>")[HaltonSampler] generates the coordinates in the middle column for the first two dimensions, which are scaled by 2 in the first dimension and 3 in the second dimension so that they cover a $2 times 3$ pixel image. To fulfill the `Sampler` interface, it is necessary to be able to work backward from a given pixel and sample number within that pixel to find the corresponding sample index in the full Halton sequence.
      ],
    ) <haltonSampler-generates>
  ]
][
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (20%, 40%, 40%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.header([样本索引], [$\[ 0 , 1 \)^2$样本坐标], [像素样本坐标]),
          table.hline(stroke: .5pt),
          [0], [$(0.000000 , 0.000000)$], [$(0.000000 , 0.000000)$],
          [1], [$(0.500000 , 0.333333)$], [$(1.000000 , 1.000000)$],
          [2], [$(0.250000 , 0.666667)$], [$(0.500000 , 2.000000)$],
          [3], [$(0.750000 , 0.111111)$], [$(1.500000 , 0.333333)$],
          [4], [$(0.125000 , 0.444444)$], [$(0.250000 , 1.333333)$],
          [5], [$(0.625000 , 0.777778)$], [$(1.250000 , 2.333333)$],
          [6], [$(0.375000 , 0.222222)$], [$(0.750000 , 0.666667)$],
          [7], [$(0.875000 , 0.555556)$], [$(1.750000 , 1.666667)$],
          [8], [$(0.062500 , 0.888889)$], [$(0.125000 , 2.666667)$],
          [9], [$(0.562500 , 0.037037)$], [$(1.125000 , 0.111111)$],
          [10], [$(0.312500 , 0.370370)$], [$(0.625000 , 1.111111)$],
          [11], [$(0.812500 , 0.703704)$], [$(1.625000 , 2.111111)$],
          [12], [$(0.187500 , 0.148148)$], [$(0.375000 , 0.444444)$],
          […], […], […],
          table.hline(stroke: 0pt),
        )],
      kind: table,
      caption: [
        #link("<HaltonSampler>")[HaltonSampler];为前两个维度生成中间列的坐标，这些坐标在第一个维度上按2缩放，在第二个维度上按3缩放，以便它们覆盖一个 $2 times 3$ 像素图像。为了满足`Sampler`接口，有必要能够从给定的像素和该像素内的样本编号向后工作，以找到完整Halton序列中的相应样本索引。
      ],
    ) <haltonSampler-generates-zh>
  ]
]

#parec[
  To map the first two dimensions of samples from $\[ 0 , 1 \)^2$ to pixel coordinates, the `HaltonSampler` finds the smallest scale factor $(2^j , 3^k)$ that is larger than the lower of either the image resolution or `MaxHaltonResolution` in each dimension. (We will explain shortly how this specific choice of scales makes it easy to see which pixel a sample lands in.) After scaling, any samples outside the image extent will be simply ignored.
][
  为了将样本的前两个维度从 $\[ 0 , 1 \)^2$ 映射到像素坐标，`HaltonSampler`找到比图像分辨率或每个维度的`MaxHaltonResolution`更小的比例因子 $(2^j , 3^k)$。这种特定比例选择使得容易看出样本落在哪个像素中。缩放后，任何超出图像范围的样本将被简单地忽略。
]

#parec[
  For images with resolution greater than `MaxHaltonResolution` in one or both dimensions, a tile of Halton points is repeated across the image. This resolution limit helps maintain sufficient floating-point precision in the computed sample values.
][
  对于在一个或两个维度上分辨率超过`MaxHaltonResolution`的图像，Halton点将以平铺方式在图像上重复。这个分辨率限制有助于在计算的样本值中保持足够的浮点精度。
]

```cpp
for (int i = 0; i < 2; ++i) {
    int base = (i == 0) ? 2 : 3;
    int scale = 1, exp = 0;
    while (scale < std::min(fullRes[i], MaxHaltonResolution)) {
        scale *= base;
        ++exp;
    }
    baseScales[i] = scale;
    baseExponents[i] = exp;
}
```


#parec[
  For each dimension, `baseScales` holds the scale factor, $2^j$ or $3^k$, and `baseExponents` holds the exponents $j$ and $k$.
][
  对于每个维度，`baseScales`保存比例因子， $2^j$ 或 $3^k$，`baseExponents`保存指数 $j$ 和 $k$。
]

#parec[
  To see why the `HaltonSampler` uses this scheme to map samples to pixel coordinates, consider the effect of scaling a value computed with the radical inverse base $b$ by a factor $b^m$. If the digits of $a$ expressed in base $b$ are $d_i (a)$, then recall that the radical inverse is the value $0 . d_1 (a) d_2 (a) dots.h$. If we multiply this value by $b^2$, for example, we have $d_1 (a) d_2 (a) . d_3 (a) dots.h ;$ the first two digits have moved to the left of the radix point, and the fractional component of the value starts with $d_3 (a)$.
][
  要了解`HaltonSampler`为何使用此方案将样本映射到像素坐标，请考虑用基数 $b$ 的基数逆数计算的值乘以因子 $b^m$ 的效果。如果以基数 $b$ 表示的 $a$ 的数字是 $d_i (a)$，那么回想一下，基数逆数是基数 $b$ 中的值 $0 . d_1 (a) d_2 (a) dots.h$。如果我们将此值乘以 $b^2$，例如，我们得到 $d_1 (a) d_2 (a) . d_3 (a) dots.h ;$ 前两个数字已移到小数点左侧，值的分数部分以 $d_3 (a)$ 开头。
]

#parec[
  This operation—scaling by $b^m$ —forms the core of being able to determine which sample indices land in which pixels. Considering the first two digits in the above example, we can see that the integer component of the scaled value ranges from $0$ to $b^2 - 1$ and that as $a$ increases, its last two digits in base $b$ take on any particular value after each $b^2$ sample index values.
][
  这种操作——按 $b^m$ 缩放——构成了能够确定哪些样本索引落在哪些像素中的核心。考虑上例中的前两个数字，我们可以看到缩放值的整数部分范围从 $0$ 到 $b^2 - 1$，并且随着 $a$ 的增加，其基数 $b$ 的最后两个数字在每个 $b^2$ 样本索引值后取任何特定值。
]

#parec[
  Given a value $x$, $0 lt.eq x lt.eq b^2 - 1$, we can find the first value $a$ that gives the value $x$ in the integer components. By definition, the digits of $x$ in base $b$ are $d_2 (x) d_1 (x)$. Thus, if $d_1 (a) = d_2 (x)$ and $d_2 (a) = d_1 (x)$, then the scaled value of $a$ 's radical inverse will have an integer component equal to $x$.
][
  给定值 $x$， $0 lt.eq x lt.eq b^2 - 1$，我们可以找到给定整数部分为 $x$ 的第一个 $a$ 值。根据定义，基数 $b$ 中 $x$ 的数字是 $d_2 (x) d_1 (x)$。因此，如果 $d_1 (a) = d_2 (x)$ 且 $d_2 (a) = d_1 (x)$，则 $a$ 的基数逆数的缩放值的整数部分将等于 $x$。
]

#parec[
  Computing the index of the first sample in a given pixel $(x , y)$ where the samples have been scaled by $(2^j , 3^k)$ involves computing the inverse radical inverse of the last $j$ digits of $x$ in base 2, which we will denote by $x_r$, and of the last $k$ digits of $y$ in base 3, $y_r$. This gives us a system of equations.
][
  计算给定像素 $(x , y)$ 中第一个样本的索引，其中样本已按 $(2^j , 3^k)$ 缩放，涉及计算基数2中 $x$ 的最后 $j$ 位的逆基数逆数，我们将其表示为 $x_r$，以及基数3中 $y$ 的最后 $k$ 位的逆基数逆数 $y_r$。这给了我们一个方程组。
]


$
  x_r & equiv (i upright("mod") 2^j)\
  y_r & equiv (i upright("mod") 3^k)
$



#parec[
  where the index $i$ that satisfies these equations is the index of a sample that lies within the given pixel, after scaling.
][
  其中满足这些方程的索引 $i$ 是缩放后位于给定像素内的样本的索引。
]

#parec[
  Given this insight, we can now finally implement the StartPixelSample() method. The code that solves Equation (8.21) for $i$ is in the \<\<Compute Halton sample index for first sample in pixel p\> , which is not included here in the book; see Grünschloss et al.~(2012) for details of the algorithm.
][
  基于这一见解，我们现在终于可以实现 StartPixelSample() 方法了。用于求解方程 (8.21) 中变量 $i$ 的代码在 \<\<计算像素 p 中第一个样本的 Halton 样本索引\>\> 中，这在书中未包含；详情请参见 Grünschloss 等人 (2012) 的算法。
]

#parec[
  Given the index into the Halton sequence that corresponds to the first sample for the pixel, we need to find the index for the requested sample, sampleIndex. Because the bases $b = 2$ and $b = 3$ used in the HaltonSampler for pixel samples are relatively prime, it follows that if the sample values are scaled by some $(2^j , 3^k)$, then any particular pixel in the range $(0 , 0) arrow.r (2^j - 1 , 3^k - 1)$ will be visited once every $2^j 3^k$ samples. That product is stored in sampleStride and the final Halton index is found by adding the product of that and the current sampleIndex.
][
  给定与像素第一个样本对应的 Halton 序列索引，我们需要找到请求样本的索引，sampleIndex。因为在 HaltonSampler 中用于像素样本的基数 $b = 2$ 和 $b = 3$ 是互质的，所以如果样本值被某个 $(2^j , 3^k)$ 缩放，则在范围 $(0 , 0) arrow.r (2^j - 1 , 3^k - 1)$ 内的任何特定像素将每 $2^j 3^k$ 个样本访问一次。该乘积存储在 sampleStride 中，最终的 Halton 索引通过将该乘积与当前 sampleIndex 相加来找到。
]

#parec[
  void StartPixelSample(Point2i p, int sampleIndex, int dim) { haltonIndex \= 0; int sampleStride = baseScales\[0\] \* baseScales\[1\]; \<\> if (sampleStride \> 1) { Point2i pm(Mod(p\[0\], MaxHaltonResolution), Mod(p\[1\], MaxHaltonResolution)); for (int i = 0; i \< 2; ++i) { uint64\_t dimOffset = (i == 0) ? InverseRadicalInverse(pm\[i\], 2, baseExponents\[i\]) : InverseRadicalInverse(pm\[i\], 3, baseExponents\[i\]); haltonIndex += dimOffset \* (sampleStride / baseScales\[i\]) \* multInverse\[i\]; } haltonIndex %= sampleStride; } haltonIndex += sampleIndex \* sampleStride; dimension = std::max(2, dim); }
][
  void StartPixelSample(Point2i p, int sampleIndex, int dim) { haltonIndex \= 0; int sampleStride = baseScales\[0\] \* baseScales\[1\]; \<\> if (sampleStride \> 1) { Point2i pm(Mod(p\[0\], MaxHaltonResolution), Mod(p\[1\], MaxHaltonResolution)); for (int i = 0; i \< 2; ++i) { uint64\_t dimOffset = (i == 0) ? InverseRadicalInverse(pm\[i\], 2, baseExponents\[i\]) : InverseRadicalInverse(pm\[i\], 3, baseExponents\[i\]); haltonIndex += dimOffset \* (sampleStride / baseScales\[i\]) \* multInverse\[i\]; } haltonIndex %= sampleStride; } haltonIndex += sampleIndex \* sampleStride; dimension = std::max(2, dim); }
]

#parec[
  int64\_t haltonIndex = 0; int dimension = 0;
][
  int64\_t haltonIndex = 0; int dimension = 0;
]

#parec[
  The methods that generate Halton sample dimensions are straightforward; they just increment the dimension member variable based on how many dimensions they have consumed and call the appropriate radical inverse function. In the unlikely case that the maximum supported number of dimensions have been used, the implementation wraps around to the start and then skips over the first two dimensions, which are used solely for pixel samples.
][
  计算 Halton 样本维度的方法非常直接；它们只是根据消耗的维度数量递增 dimension 成员变量，并调用适当的反序数函数。在极少数情况下，使用的维度数达到支持的最大值，实现会绕回到开始，然后跳过仅用于像素样本的前两个维度。
]

#parec[
  Float Get1D() { if (dimension \>= PrimeTableSize) dimension = 2; return SampleDimension(dimension++); }
][
  Float Get1D() { if (dimension \>= PrimeTableSize) dimension = 2; return SampleDimension(dimension++); }
]

#parec[
  The SampleDimension() method takes care of calling the appropriate radical inverse function for the current sample in the current dimension according to the selected randomization strategy.
][
  SampleDimension() 方法负责根据所选的随机化策略，为当前样本在当前维度调用适当的反序数函数。
]

#parec[
  Float SampleDimension(int dimension) const { if (randomize == RandomizeStrategy::None) return RadicalInverse(dimension, haltonIndex); else if (randomize == RandomizeStrategy::PermuteDigits) return ScrambledRadicalInverse(dimension, haltonIndex, (\*digitPermutations)\[dimension\]); else return OwenScrambledRadicalInverse(dimension, haltonIndex, MixBits(1 + (dimension \<\< 4))); }
][
  Float SampleDimension(int dimension) const { if (randomize == RandomizeStrategy::None) return RadicalInverse(dimension, haltonIndex); else if (randomize == RandomizeStrategy::PermuteDigits) return ScrambledRadicalInverse(dimension, haltonIndex, (\*digitPermutations)\[dimension\]); else return OwenScrambledRadicalInverse(dimension, haltonIndex, MixBits(1 + (dimension \<\< 4))); }
]

#parec[
  The Get2D() method is easily implemented using SampleDimension().
][
  Get2D() 方法可以很容易地使用 SampleDimension() 实现。
]

#parec[
  Point2f Get2D() { if (dimension + 1 \>= PrimeTableSize) dimension = 2; int dim = dimension; dimension += 2; return {SampleDimension(dim), SampleDimension(dim + 1)}; }
][
  Point2f Get2D() { if (dimension + 1 \>= PrimeTableSize) dimension = 2; int dim = dimension; dimension += 2; return {SampleDimension(dim), SampleDimension(dim + 1)}; }
]

#parec[
  GetPixel2D() has to account for two important details in the rest of the HaltonSampler implementation. First, because the computation of the sample index, haltonIndex, in StartPixelSample() does not account for random digit permutations, those must not be included in the samples returned for the first two dimensions: a call to RadicalInverse() is always used here.
][
  GetPixel2D() 必须考虑 HaltonSampler 实现中其余部分的两个重要细节。首先，因为在 StartPixelSample() 中计算样本索引 haltonIndex 时没有考虑随机数字置换，所以在返回前两个维度的样本时不能包含这些置换：这里总是使用 RadicalInverse()。
]

#parec[
  Second, because the first baseExponents\[i\] digits of the first two dimensions' radical inverses are used to select which pixel is sampled, these digits must be discarded before computing the radical inverse for the first two dimensions of the sample, since the GetPixel2D() method is supposed to return the fractional offset in $\[ 0 , 1 \)^2$ within the pixel being sampled. This is most easily done by removing the trailing digits of the sample index before computing the radical inverse. Because the first dimension is base 2, this can be efficiently done using a shift, though a divide is necessary for base 3 in the second dimension.
][
  其次，因为前两个维度的反序数的前 baseExponents\[i\] 位用于选择采样的像素，所以在计算样本的前两个维度的反序数之前，必须丢弃这些位，因为 GetPixel2D() 方法应该返回在像素内的 $\[ 0 , 1 \)^2$ 范围内的小数偏移。这可以通过在计算反序数之前去除样本索引的尾数位来实现。因为第一个维度是基数 2，这可以通过移位有效地完成，尽管第二个维度的基数 3 需要除法。
]

#parec[
  Point2f GetPixel2D() { return {RadicalInverse(0, haltonIndex \>\> baseExponents\[0\]), RadicalInverse(1, haltonIndex / baseScales\[1\])}; }
][
  Point2f GetPixel2D() { return {RadicalInverse(0, haltonIndex \>\> baseExponents\[0\]), RadicalInverse(1, haltonIndex / baseScales\[1\])}; }
]


#parec[
  Figure #link("<fig:halton-sampler-power-spectra>")[8.29] shows plots of the power spectra for the #link("<HaltonSampler>")[HaltonSampler] with each of the three randomization strategies. The frequency space perspective is revealing. First, note that all three strategies have low energy along the two axes: this indicates that they all do well with functions that mostly vary in only one dimension. This behavior can be understood from their construction: because each dimension uses an independent radical inverse, 1D projections of the sample points are stratified. (Consider in comparison the jittered sampling pattern's PSD, which had a radially symmetric distribution around the origin. Given $n$ 2D stratified samples, only \$\\\\sqrt{n}\$ are guaranteed to be stratified along either of the dimensions, whereas with the Halton sampler, all $n$ are.)
][
  图 #link("<fig:halton-sampler-power-spectra>")[8.29] 显示了 #link("<HaltonSampler>")[HaltonSampler] 使用三种随机化策略的功率谱图。频率空间的视角揭示了许多信息。首先，注意到所有三种策略在两个轴上都有低能量：这表明它们在处理主要在一个维度上变化的函数时表现良好。这种行为可以从它们的构造中理解：因为每个维度使用独立的基数逆变换，样本点的1D投影是分层的。（相比之下，考虑抖动采样模式的PSD，它在原点周围具有径向对称分布。给定 $n$ 个二维分层样本，只有 \$\\\\sqrt{n}\$ 个在任一维度上是分层的，而使用Halton采样器，所有 $n$ 个都是。）
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f29.svg"),
    caption: [
      Figure 8.29: Power Spectra of Points Generated by the HaltonSampler.
      (a) Using no randomization, with substantial variation in power at
      the higher frequencies. (b) Using random digit scrambling, which
      improves the regularity of the PSD but still contains some spikes.
      (c) Using Owen scrambling, which gives near unit power at the higher
      frequencies, making it especially effective for antialiasing and
      integration.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f29.svg"),
    caption: [
      图 8.29: HaltonSampler 生成点的功率谱。(a)
      不使用随机化，在高频处有显著的功率变化。(b)
      使用随机数字扰乱，改善了PSD的规律性，但仍包含一些尖峰。(c)
      使用Owen扰乱，在高频处接近单位功率，使其在抗锯齿和积分方面特别有效。
    ],
  )
]

#parec[
  However, the non-randomized Halton sampler has wide variation in its PSD at higher frequencies. Ideally, those frequencies would all have roughly unit energy, but in this case, some frequencies have over a hundred times more and others a hundred times less. Results will be poor if the frequencies of the function match the ones with high power in the PSD. This issue can be seen in rendered images; Figure #link("<fig:lowdiscrep-comparisons>")[8.30] compares the visual results from sampling a checkerboard texture using a Halton-based sampler to using the stratified sampler from the previous section. Note the unpleasant pattern along edges in the foreground and toward the horizon.
][
  然而，未随机化的Halton采样器在高频处的PSD变化很大。理想情况下，这些频率都应具有大致单位能量，但在这种情况下，一些频率的能量超过一百倍，而其他频率则少一百倍。如果函数的频率与PSD中高能量的频率相匹配，结果将会很差。这一问题可以在渲染图像中看到；图 #link("<fig:lowdiscrep-comparisons>")[8.30] 比较了使用基于Halton的采样器与上一节的分层采样器对棋盘格纹理采样的视觉效果。注意前景和地平线方向边缘的不愉快图案。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f30.svg"),
    caption: [
      Figure 8.30: Comparison of the Stratified Sampler to a
      Low-Discrepancy Sampler Based on Halton Points on the Image Plane.
      (a) The stratified sampler with a single sample per pixel and (b)
      the Halton sampler with a single sample per pixel and no scrambling.
      Note that although the Halton pattern is able to reproduce the
      checker pattern farther toward the horizon than the stratified
      pattern, there is a regular structure to the error that is visually
      distracting; it does not turn aliasing into less objectionable noise
      as well as jittering does.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f30.svg"),
    caption: [
      图 8.30: 图像平面上基于Halton点的低差异采样器与分层采样器的比较。(a)
      每像素一个样本的分层采样器和 (b)
      每像素一个样本且无扰乱的Halton采样器。注意虽然Halton模式能够比分层模式更远地再现棋盘格图案，但错误的规则结构在视觉上令人分心；它不像抖动那样将混叠转化为不那么令人反感的噪声。
    ],
  )
]

#parec[
  Returning to the power spectra in Figure #link("<fig:halton-sampler-power-spectra>")[8.29];, we can see that random digit permutations give a substantial improvement in the power spectrum, though there is still clear structure, with some frequencies having very low power and others still having high power. The benefit of Owen scrambling in this case is striking: it gives a uniform power spectrum at higher frequencies while maintaining low power along the axes.
][
  回到图 #link("<fig:halton-sampler-power-spectra>")[8.29] 的功率谱，我们可以看到随机数字置换在功率谱上有显著改善，尽管仍然有明显的结构，一些频率的功率很低，而其他频率仍然很高。在这种情况下，Owen扰乱的优势非常明显：它在高频处提供了均匀的功率谱，同时在轴上保持低功率。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f31.svg"),
    caption: [
      Figure 8.31: Mean Squared Error When Integrating Two Simple 2D
      Functions. Both are plotted using a log–log scale so that the
      asymptotic convergence rate can be seen from the slopes of the
      lines. For the stratified sampler, only square $n times n$
      stratifications are plotted. (a) With the smooth Gaussian function
      shown, the Halton sampler has a higher asymptotic rate of
      convergence than both stratified and independent sampling. Its
      performance is particularly good for sample counts of $2^i 3^i$ for
      integer $i$. (b) With the rotated checkerboard, stratified sampling
      is initially no better than independent sampling since the strata
      are not aligned with the checks. However, once the strata start to
      become smaller than the checks (around 256 samples), its asymptotic
      rate of convergence improves.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f31.svg"),
    caption: [
      图 8.31:
      积分两个简单二维函数时的均方误差（MSE）。两者都使用对数-对数刻度绘制，以便从线的斜率中看到渐近收敛率。对于分层采样器，仅绘制平方
      $n times n$ 分层。(a)
      对于平滑的高斯函数，Halton采样器的渐近收敛率高于分层和独立采样。对于样本数为
      $2^i 3^i$ 的整数 $i$，其性能特别好。(b)
      对于旋转的棋盘格，分层采样最初不比独立采样好，因为分层与棋盘格不对齐。然而，一旦分层开始小于棋盘格（大约256个样本），其渐近收敛率提高。
    ],
  )
]

#parec[
  It can also be illuminating to measure the performance of samplers with simple functions that can be integrated analytically.† Figure #link("<fig:halton-eval-functions>")[8.31] shows plots of mean squared error (MSE) for using the independent, stratified, and Halton samplers for integrating a Gaussian and a checkerboard function (shown in the plots). In this case, using a log–log scale has the effect of causing convergence rates of the form $O (n^c)$ to appear as lines with slope $c$, which makes it easier to compare asymptotic convergence of various techniques. For both functions, both stratified and Halton sampling have a higher rate of convergence than the $O (1 \/ n)$ of independent sampling, as can be seen by the steeper slopes of their error curves. The Halton sampler does especially well with the Gaussian, achieving nearly two thousand times lower MSE than independent sampling at 4,096 samples.
][
  用可以解析积分的简单函数来衡量采样器的性能也很有启发性。† 图 #link("<fig:halton-eval-functions>")[8.31] 显示了使用独立、分层和Halton采样器对高斯和棋盘格函数积分的均方误差（MSE）图。在这种情况下，使用对数-对数刻度的效果是使 $O (n^c)$ 形式的收敛率显示为斜率为 $c$ 的线，这使得比较各种技术的渐近收敛率更加容易。对于这两个函数，分层和Halton采样的收敛率都高于独立采样的 $O (1 \/ n)$，这可以从它们误差曲线的陡峭斜率看出。Halton采样器在高斯函数上表现特别好，在4,096个样本时，MSE比独立采样低近两千倍。
]

#parec[
  Figure #link("<fig:scene-rendered-various-samplers>")[8.32] shows the image of a test scene that we will use for comparing samplers. It features a moving camera, defocus blur, illumination from an environment map light source, and multiply scattered light from sources to give an integral with tens of dimensions. Figure #link("<fig:mse-for-sampler-rendered-images>")[8.33] is a log–log plot of MSE versus number of samples for these samplers with this scene. With a more complex integrand than the simple ones in Figure #link("<fig:halton-eval-functions>")[8.31];, the Halton sampler does not have the enormous benefit it did there. Nevertheless, it makes a significant improvement to error—for example, MSE is $1.09$ times lower than independent sampling at 4,096 samples per pixel.
][
  图 #link("<fig:scene-rendered-various-samplers>")[8.32] 显示了用于比较采样器的测试场景图像。它具有移动相机、散焦模糊、环境光源照明以及来自光源的多次散射光，使积分具有数十个维度。图 #link("<fig:mse-for-sampler-rendered-images>")[8.33] 是这些采样器在该场景中样本数与MSE的对数-对数图。与图 #link("<fig:halton-eval-functions>")[8.31] 中的简单积分相比，Halton采样器在这里没有那么大的优势。然而，它在误差改善方面仍然显著——例如，在每像素4,096个样本时，MSE比独立采样低1.09倍。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/samplers-dragon-figure.png"),
    caption: [
      Figure 8.32: Test Scene for Sampler Evaluation. This scene requires
      integrating a function of tens of dimensions, including defocus
      blur, a moving camera, and multiply scattered illumination from an
      environment map light source. #emph[Dragon model courtesy of the
    Stanford Computer Graphics Laboratory.]
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/samplers-dragon-figure.png"),
    caption: [
      图 8.32:
      采样器评估的测试场景。此场景需要积分一个具有数十个维度的函数，包括散焦模糊、移动相机和来自环境光源的多次散射照明。#emph[龙模型由斯坦福计算机图形实验室提供。]
    ],
  )
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/mse-dragon-halton.svg"),
    caption: [
      Figure 8.33: Log–Log Plot of MSE versus Number of Samples for the
      Scene in Figure #link("<fig:scene-rendered-various-samplers>")[8.32];.
      The Halton sampler gives consistently lower error than both the
      independent and stratified samplers and converges at a slightly
      higher rate.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Sampling_and_Reconstruction/mse-dragon-halton.svg"),
    caption: [
      图 8.33: 图 #link("<fig:scene-rendered-various-samplers>")[8.32]
      场景中样本数与MSE的对数-对数图。Halton采样器始终比独立和分层采样器误差更低，并以略高的速率收敛。
    ],
  )
]
