#import "../template.typ": parec

== Sobol' Samplers #emoji.warning
<sobol-samplers>

#parec[
  While the Halton sequence is effective for Monte Carlo integration, each radical inverse computation requires one integer division for each digit. The integer division instruction is one of the slowest ones on most processors, which can affect overall rendering performance, especially in highly optimized renderers. Therefore, in this section we will describe three `Sampler`s that are based on the Sobol' sequence, a low-discrepancy sequence that is defined entirely in base 2, which leads to efficient implementations.
][
  虽然Halton序列对于蒙特卡罗积分是有效的，但每个基数反演计算都需要对每个数字进行一次整数除法运算。在大多数处理器上，整数除法运算是最慢的指令之一，这可能会影响整体渲染性能，特别是在高度优化的渲染程序中。因此，在本节中，我们将描述三种基于Sobol'序列的`Sampler`，这是一种完全在基数2中定义的低差序列，从而实现高效的实现。
]

#parec[
  The base-2 radical inverse can be computed more efficiently than the way that the base-agnostic `RadicalInverse()` function computes it. The key is to take advantage of the fact that numbers are already represented in base 2 on digital computers. If $a$ is a 64-bit value, then from Equation (8.18),
][
  基数2的基数反演可以比基数无关的`RadicalInverse()`函数更高效地计算。关键在于利用数字计算机中数字已经以基数2表示的事实。如果 $a$ 是一个64位值，那么根据方程(8.18)，
]

#parec[
  $
    a = sum_(i = 1)^64 d_i (a) 2^(i - 1) ,
  $ where $d_i (a)$ are its bits. First, consider reversing its bits, still represented as an integer value, which gives
][
  $ a = sum_(i = 1)^64 d_i (a) 2^(i - 1) , $ 其中 $d_i (a)$ 是其位。首先，考虑反转其位，仍然表示为整数值，这给出
]

#parec[
  $ sum_(i = 1)^64 d_i (a) 2^(64 - i) . $ If we then divide this value by $2^64$, we have
][
  $ sum_(i = 1)^64 d_i (a) 2^(64 - i) . $ 如果我们然后将此值除以 $2^64$，我们得到
]

#parec[
  $
    sum_(i = 1)^64 d_i (a) 2^(- i) ,
  $ which equals $Phi_2 (a)$ (recall Equation (8.19)). Thus, the base-2 radical inverse can equivalently be computed using a bit reverse and a power-of-two division. The division can be replaced with multiplication by the corresponding inverse power-of-two, which gives the same result with IEEE floating point.
][
  $
    sum_(i = 1)^64 d_i (a) 2^(- i) ,
  $ 这等于 $Phi_2 (a)$ （回忆方程(8.19)）。因此，基数2的基数反演可以通过位反转和2的幂次除法等效地计算。除法可以用相应的2的幂次倒数乘法替代，这在IEEE浮点表示中给出相同的结果。
]

#parec[
  Some processors provide a native instruction that directly reverses the bits in a register; otherwise it can be done in $O (log_2 n)$ operations, where $n$ is the number of bits. (See the implementation of `ReverseBits32()` in Section B.2.7.)
][
  一些处理器提供直接反转寄存器中位的处理器的本机指令；否则可以在 $O (log_2 n)$ 操作中完成，其中 $n$ 是位数。（参见第B.2.7节中的`ReverseBits32()`实现。）
]

#parec[
  While the implementation of a function that generates Halton points could be optimized by taking advantage of this for the first dimension where $b = 2$, performance would not improve for any of the remaining dimensions, so the overall benefit would be low.
][
  虽然通过利用这一点来优化生成Halton点的函数的实现可以在第一个维度中提高性能（其中 $b = 2$ ），但对于其余维度性能不会提高，因此整体收益会很低。
]

#parec[
  The Sobol' sequence uses $b = 2$ for all dimensions, which allows it to benefit in all cases from computers' use of base 2 internally. So that each dimension has a different set of sample values, it uses a different #emph[generator matrix] for each dimension, where the generator matrices are carefully chosen so that the resulting sequence has low discrepancy.
][
  Sobol'序列在所有维度中使用 $b = 2$，这使得它可以在所有情况下从计算机内部使用基数2中受益。为了使每个维度有一组不同的样本值，它为每个维度使用不同的#emph[生成矩阵];，这些生成矩阵经过精心选择，以使生成的序列具有低差异。
]

#parec[
  To see how generator matrices are used, consider an $n$ -digit number $a$ in base $b$, where the $i$ th digit of $a$ is $d_i (a)$ and where we have an $n times n$ generator matrix $upright(bold(C))$. Then the corresponding sample point $x_a in \[ 0 , 1 \)$ is defined by
][
  为了了解生成矩阵的使用方式，考虑一个基数 $b$ 的 $n$ 位数 $a$，其中 $a$ 的第 $i$ 位是 $d_i (a)$，并且我们有一个 $n times n$ 生成矩阵 $upright(bold(C))$。那么相应的样本点 $x_a in \[ 0 , 1 \)$ 定义为
]

$
  x_a = [ b^(- 1) med b^(- 2) med dots.h.c med b^(- n) ] mat(delim: "(", c_(1 , 1), c_(1 , 2), dots.h.c, c_(1 , n); c_(2 , 1), dots.h.c, c_(2 , n); dots.v, , dots.v; c_(n , 1), dots.h.c, c_(n , n)) vec(d_1 (a), d_2 (a), dots.v, d_n (a)) ,
$
#parec[
  where all arithmetic is performed in the ring $upright(bold(Z))_b$ (in other words, when all operations are performed modulo $b$ ).
][
  其中所有算术运算都在环 $upright(bold(Z))_b$ 中进行（换句话说，当所有操作都以 $b$ 为模进行时）。
]

#parec[
  This construction gives a total of $b^n$ points as $a$ ranges from $0$ to $b^n - 1$. If the generator matrix is the identity matrix, then this definition corresponds to the regular radical inverse, base $b$. (It is worth pausing to make sure you see this connection between Equations (8.19) and (8.22) before continuing.)
][
  这种构造在 $a$ 从 $0$ 到 $b^n - 1$ 时给出总共 $b^n$ 个点。如果生成矩阵是单位矩阵，那么这个定义对应于常规的基数反演，基数 $b$。（值得停下来确保你看到方程(8.19)和(8.22)之间的联系，然后再继续。）
]

#parec[
  In this section, we will exclusively use $b = 2$ and $n = 32$. While introducing a $32 times 32$ matrix to each dimension of the sample generation algorithm may not seem like a step toward better performance, we will see that in the end the sampling code can be mapped to an implementation that uses a small number of bit operations that perform this computation in an extremely efficient manner.
][
  在本节中，我们将专门使用 $b = 2$ 和 $n = 32$。虽然在样本生成算法的每个维度引入一个 $32 times 32$ 矩阵似乎不是提高性能的一步，但我们将看到，最终采样代码可以映射到一个使用少量位操作的实现，以极高的效率执行此计算。
]

#parec[
  The first step toward high performance comes from the fact that we are working in base 2; as such, all entries of $upright(bold(C))$ are either 0 or 1 and thus we can represent either each row or each column of the matrix with a single unsigned 32-bit integer. We will choose to represent columns of the matrix as `uint32_t`; this choice leads to an efficient algorithm for multiplying the $d_i$ column vector by $upright(bold(C))$.
][
  高性能的第一步来自于我们在基数2中工作；因此， $upright(bold(C))$ 的所有条目要么是0，要么是1，因此我们可以用一个无符号32位整型表示矩阵的每一行或每一列。我们将选择将矩阵的列表示为`uint32_t`；这种选择导致了一个高效的算法，用于将 $d_i$ 列向量乘以 $upright(bold(C))$。
]

#parec[
  Now consider the task of computing the $upright(bold(C)) [d_i (a)]^T$ matrix-vector product; using the definition of matrix-vector multiplication, we have:
][
  现在考虑计算 $upright(bold(C)) [d_i (a)]^T$ 矩阵向量乘积的任务；使用矩阵向量乘法的定义，我们有：
]


$
  c_(1 , 1) & c_(1 , 2) & dots.h.c & c_(1 , n)\
  c_(2 , 1) & arrow.b & dots.h.c & c_(2 , n)\
  dots.v & dots.h.c & arrow.b & dots.v\
  c_(n , 1) & dots.h.c & dots.h.c & c_(n , n) vec(d_1 (a), d_2 (a), dots.v, d_n (a)) = d_1 vec(c_(1 , 1), c_(2 , 1), dots.v, c_(n , 1)) + dots.h.c + d_n vec(c_(1 , n), c_(2 , n), dots.v, c_(n , n)) .
$


#parec[
  In other words, for each digit of $d_i$ that has a value of 1, the corresponding column of \$ \$ should be summed. This addition can in turn be performed efficiently in \$ \_2\$: in that setting, addition corresponds to the bitwise exclusive or operation. (Consider the combinations of the two possible operand values—0 and 1—and the result of adding them modulo 2, and compare to the values computed by exclusive or with the same operand values.) Thus, the multiplication \$ \[d\_i(a)\]^T\$ is just a matter of exclusive oring together the columns $i$ of \$ \$ where $d_i (a)$ 's bit is 1. This computation is implemented in the `MultiplyGenerator()` function.
][
  换句话说，对于每个值为1的 $d_i$ 的数字，应该将\$ $的 对 应 列 相 加 。 这 种 加 法 可 以 在$ \_2 $中 高 效 地 执 行 ： 在 这 种 情 况 下 ， 加 法 对 应 于 按 位 异 或 操 作 。 （ 考 虑 两 个 可 能 的 操 作 数 值 dash.em dash.em 0 和 1 dash.em dash.em 的 组 合 ， 以 及 它 们 模 2 相 加 的 结 果 ， 并 与 使 用 相 同 操 作 数 值 计 算 的 异 或 值 进 行 比 较 。 ） 因 此 ， 乘 法$ \[d\_i(a)\]^T $只 是 将$ $中$ d\_i(a) $的 位 为 1 的 列$ i\$进行异或运算。这个计算在`MultiplyGenerator()`函数中实现。
]

$ vec(v_1, v_2, dots.v, v_n) = upright(bold(C)) [d_i (a)]^T $

#parec[
  Applying the same ideas as we did before to derive an efficient base-2 radical inverse algorithm, this value can also be computed by reversing the bits of $v$ and dividing by $2^32$. To save the small cost of reversing the bits, we can equivalently reverse the bits in all the columns of the generator matrix before passing it to `MultiplyGenerator()`. We will use that convention in what follows.
][
  应用与之前相同的思想来推导一个高效的基于2的基数逆算法，这个值也可以通过反转 $v$ 的位并除以 $2^32$ 来计算。为了节省反转位的成本，我们可以在将生成矩阵传递给`MultiplyGenerator()`之前，先反转其所有列的位。在接下来的内容中，我们将使用这种约定。
]

#parec[
  We will not discuss how the Sobol' matrices are derived in a way that leads to a low-discrepancy sequence; the "Further Reading" section has pointers to more details. However, the first few Sobol' generator matrices are shown in Figure 8.34. Note that the first is the identity, corresponding to the van der Corput sequence. Subsequent dimensions have various fractal-like structures to their entries.
][
  我们不会讨论Sobol'矩阵是如何以一种导致低差异序列的方式推导出来的；"进一步阅读"部分有指向更多细节的指针。然而，前几个Sobol'生成矩阵如图8.34所示。注意，第一个是单位矩阵，对应于van der Corput序列。后续维度的条目中呈现出类似分形的结构。
]

#parec[
  Figure 8.34: Generator matrices for the first four dimensions of the Sobol' sequence. Note their regular structure.
][
  图8.34：Sobol'序列前四维的生成矩阵。注意它们的规则结构。
]

=== Stratification over Elementary Intervals

#parec[
  The first two dimensions of the Sobol' sequence are stratified in a very general way that makes them particularly effective in integration. For example, the first 16 samples satisfy the stratification constraint from stratified sampling in Section 8.5, meaning there is just one sample in each of the boxes of extent $(1 / 4 , 1 / 4)$. However, they are also stratified over all the boxes of extent $(1 / 16 , 1)$ and $(1 , 1 / 16)$. Furthermore, there is only one sample in each of the boxes of extent $(1 / 2 , 1 / 8)$ and $(1 / 8 , 1 / 2)$. Figure 8.35 shows all the possibilities for dividing the domain into regions where the first 16 Sobol' samples satisfy these stratification properties.
][
  Sobol'序列的前两个维度以一种非常通用的方式进行分层，使其在积分中特别有效。例如，前16个样本满足第8.5节中的分层采样的分层约束，意味着每个范围为 $(1 / 4 , 1 / 4)$ 的盒子中只有一个样本。然而，它们也在所有范围为 $(1 / 16 , 1)$ 和 $(1 , 1 / 16)$ 的盒子中分层。此外，每个范围为 $(1 / 2 , 1 / 8)$ 和 $(1 / 8 , 1 / 2)$ 的盒子中只有一个样本。图8.35展示了将域划分为区域的所有可能性，其中前16个Sobol'样本满足这些分层属性。
]

#parec[
  Not only are corresponding stratification constraints obeyed by any power-of-2 set of samples starting from the beginning of the sequence, but subsequent power-of-2-sized sets of samples fulfill them as well. More formally, any sequence of length $2^(l_1 + l_2)$ (where $l_i$ is a nonnegative integer) satisfies this general stratification constraint. The set of #emph[elementary intervals] in two dimensions, base 2, is defined as
][
  不仅从序列开始的任何2的幂大小的样本集都遵循相应的分层约束，而且后续2的幂大小的样本集也满足这些约束。更正式地说，任何长度为 $2^(l_1 + l_2)$ （其中 $l_i$ 是非负整数）的序列都满足这种通用的分层约束。二维中基于2的#emph[基本区间];被定义为
]


#parec[
  $
    E = {lr([a_1 / 2^(l_1) , frac(a_1 + 1, 2^(l_1)))) times lr([a_2 / 2^(l_2) , frac(a_2 + 1, 2^(l_2))))} ,
  $ where the integer $a_i = 0 , 1 , 2 , 3 , dots.h , 2^(l_i) - 1$. One sample from each of the first $2^(l_1 + l_2)$ values in the sequence will be in each of the elementary intervals. Furthermore, the same property is true for each subsequent set of $2^(l_1 + l_2)$ values. Such a sequence is called a #emph[$(0 , 2)$-sequence];.
][
  $
    E = {lr([a_1 / 2^(l_1) , frac(a_1 + 1, 2^(l_1)))) times lr([a_2 / 2^(l_2) , frac(a_2 + 1, 2^(l_2))))} ,
  $ 其中整数 $a_i = 0 , 1 , 2 , 3 , dots.h , 2^(l_i) - 1$。序列中前 $2^(l_1 + l_2)$ 个值中的每一个样本将位于每个基本区间中。此外，同样的性质对于后续的每组 $2^(l_1 + l_2)$ 个值也成立。这样的序列称为 #emph[$(0 , 2)$-序列];。
]

=== Randomization and Scrambling

#parec[
  For the same reasons as were discussed in Section~8.6.2 in the context of the Halton sequence, it is also useful to be able to scramble the Sobol' sequence. We will now define a few small classes that scramble a given sample value using various approaches. As with the generation of Sobol' samples, scrambling algorithms for them can also take advantage of their base-2 representation to improve their efficiency.
][
  出于与在第~8.6.2节中讨论的Halton序列相同的原因，能够扰动Sobol'序列也是有用的。我们现在将定义一些小类，这些类使用各种方法扰动给定的样本值。与Sobol'样本的生成一样，扰动算法也可以利用其二进制表示来提高效率。
]

#parec[
  All the following randomization classes take an unsigned 32-bit integer that they should interpret as a fixed-point number with 0~digits before and 32 digits after the radix point. Put another way, after randomization, this value will be divided by $2^32$ to yield the final sample value in $\[ 0 , 1 \)$.
][
  以下所有随机化类都接受一个无符号32位整数，它们应将其解释为一个定点数，具有0位整数位和32位小数位。换句话说，随机化后，该值将除以 $2^32$ 以得到 $\[ 0 , 1 \)$ 范围内的最终样本值。
]

#parec[
  The simplest approach is not to randomize the sample at all. In that case, the value is returned unchanged; this is implemented by `NoRandomizer`.
][
  最简单的方法是不对样本进行随机化。在这种情况下，值保持不变返回；这由`NoRandomizer`实现。
]

#parec[
  Alternatively, random permutations can be applied to the digits, such as was done using the `DigitPermutation` class with the Halton sampler. In base~2, however, a random permutation of \$\\\\{0, 1\\\\}\$ can be represented with a single bit, as there are only two unique permutations. If the permutation \$\\\\{1, 0\\\\}\$ is denoted by a bit with value~1 and the permutation \$\\\\{0, 1\\\\}\$ is denoted by~0, then the permutation can be applied by computing the exclusive or of the permutation bit with a digit's bit. Therefore, the permutation for all 32 bits can be represented by a 32-bit integer and all of the permutations can be applied in a single operation by computing the exclusive or of the provided value with the permutation.
][
  或者，可以对位应用随机排列，例如使用`DigitPermutation`类对Halton采样器进行的处理。然而，在基数2中，\$\\\\{0, 1\\\\}\$的随机排列可以用一个位表示，因为只有两种唯一的排列。如果排列\$\\\\{1, 0\\\\}\$由值为1的位表示，排列\$\\\\{0, 1\\\\}\$由0表示，则可以通过计算排列位与位的异或来应用排列。因此，所有32位的排列可以用一个32位整数表示，并且可以通过计算给定值与排列的异或在单个操作中应用所有排列。
]

#parec[
  Owen scrambling is also effective with Sobol' points. `pbrt` provides two implementations of it, both of which take advantage of their base-2 representation. `FastOwenScrambler` implements a highly efficient approach, though the spectral properties of the resulting points are not quite as good as a true Owen scramble.
][
  Owen扰动对Sobol'点也很有效。`pbrt`提供了两种实现，它们都利用了其二进制表示。`FastOwenScrambler`实现了一种高效的方法，尽管结果点的频谱特性不如真正的Owen扰动。
]

#parec[
  Its implementation builds on the fact that in base 2, if a number is multiplied by an even value, then the value of any particular bit in it only affects the bits above it in the result. Equivalently, for any bit in the result, it is only affected by the bits below it and the even multiplicand. One way to see why this is so is to consider long multiplication (as taught in grade school) applied to binary numbers. Given two $n$ -digit binary numbers $a$ and $b$ where $d_i (b)$ is the $i$ th digit of $b$, then using Equation~(8.18), we have
][
  其实现基于这样一个事实：在基数2中，如果一个数乘以一个偶数值，那么其中任何特定位的值仅影响结果中高于它的位。同样地，结果中的任何位仅受其下方的位和偶数乘数的影响。要理解这一点，可以考虑将传统的长乘法应用于二进制数。给定两个 $n$ 位二进制数 $a$ 和 $b$，其中 $d_i (b)$ 是 $b$ 的第 $i$ 位，根据方程式~(8.18)，我们有
]

$ a b = sum_(i = 1)^n a d_i (b) 2^(i - 1) . $

#parec[
  Thus, for any digit $i > 1$ where $d_i (b)$ is one, the value of $a$ is shifted $i - 1$ bits to the left and added to the final result and so any digit of the result only depends on lower digits of $a$.
][
  因此，对于任何 $i > 1$ 且 $d_i (b)$ 为1的位， $a$ 的值将左移 $i - 1$ 位并加到最终结果中，因此结果的任何位仅依赖于 $a$ 的低位。
]

#parec[
  The bits in the value provided to the randomization class must be reversed so that the low bit corresponds to \$ rac{1}{2}\$ in the final sample value. Then, the properties illustrated in Equation~(8.25) can be applied: the product of an even value with the sample value `v` can be interpreted as a bitwise permutation as was done in the `BinaryPermuteScrambler`, allowing the use of an exclusive or to permute all the bits. After a few rounds of this and a few operations to mix the seed value in, the bits are reversed again before being returned.
][
  提供给随机化类的值的位必须反转，以便最低位对应于最终样本值中的\$ rac{1}{2}\$。然后，可以应用方程式~(8.25)中展示的性质：偶数值与样本值`v`的乘积可以解释为按位置换，如在`BinaryPermuteScrambler`中所做的那样，允许使用异或来置换所有位。经过几轮这样的操作和几次混合种子值的操作后，位再次反转，然后返回。
]

#parec[
  The `OwenScrambler` class implements a full Owen scramble, operating on each bit in turn.
][
  `OwenScrambler`类实现了一个完整的Owen扰动，逐位操作。
]

#parec[
  The first bit (corresponding to \$ rac{1}{2}\$ in the final sample value) is handled specially, since there are no bits that precede it to affect its randomization. It is randomly flipped according to the seed value provided to the constructor.
][
  第一位（对应于最终样本值中的\$ rac{1}{2}\$）被特别处理，因为没有前面的位可以影响其随机化。根据提供给构造函数的种子值，它被随机翻转。
]

#parec[
  For all the following bits, a bit mask is computed such that the bitwise and of the mask with the value gives the bits above `b`—the values of which should determine the permutation that is used for the current bit. Those are run through `MixBits()` to get a hashed value that is then used to determine whether or not to flip the current bit.
][
  对于所有后续位，计算一个位掩码，使得掩码与值的按位与给出高于`b`的位——这些位的值应决定用于当前位的排列。通过`MixBits()`运行这些位以获得一个哈希值，然后用来决定是否翻转当前位。
]


=== Sobol' Sample Generation
<sobol-sample-generation>
#parec[
  We now have the pieces needed to implement functions that generate Sobol' samples. The `SobolSample()` function performs this task for a given sample index `a` and dimension, applying the provided randomizer to the sample before returning it.
][
  我们现在有了实现生成 Sobol' 样本的函数所需的部分。`SobolSample()` 函数为给定的样本索引 `a` 和维度执行此任务，在返回样本之前应用提供的随机化器。
]

#parec[
  Because this function is templated on the type of the randomizer, a specialized instance of it will be compiled using the provided randomizer, leading to the randomization algorithm being expanded inline in the function. For `pbrt`'s purposes, there is no need for a more general mechanism for sample randomization, so the small performance benefit is worth taking in this implementation approach.
][
  由于此函数是基于随机化器类型进行模板化的，因此将使用提供的随机化器编译它的一个特定实例，从而使随机化算法在函数中直接展开。对于 `pbrt` 的目的，不需要更通用的样本随机化机制，因此在此实现方法中，值得获得小的性能收益。
]

#parec[
  Samples are computed using the Sobol' generator matrices, following the approach described by Equation (8.23). All the generator matrices are stored consecutively in the `SobolMatrices32` array. Each one has `SobolMatrixSize` columns, so scaling the dimension by `SobolMatrixSize` brings us to the first column of the matrix for the given dimension.
][
  样本是使用 Sobol' 生成器矩阵计算的，遵循方程 (8.23) 描述的方法。所有生成器矩阵连续存储在 `SobolMatrices32` 数组中。每个矩阵都有 `SobolMatrixSize` 列，因此将维度乘以 `SobolMatrixSize` 将我们带到给定维度的矩阵的第一列。
]

#parec[
  #strong[Compute initial Sobol $p r i m e$ sample] `v` using generator matrices:
][
  #strong[使用生成器矩阵计算初始 Sobol $p r i m e$ 样本] `v`：
]

#parec[
  ```cpp
  uint32_t v = 0;
  for (int i = dimension * SobolMatrixSize; a != 0; a >>= 1, i++)
      if (a & 1)
          v ^= SobolMatrices32[i];
  ```
][
  ```cpp
  uint32_t v = 0;
  for (int i = dimension * SobolMatrixSize; a != 0; a >>= 1, i++)
      if (a & 1)
          v ^= SobolMatrices32[i];
  ```
]

#parec[
  #strong[Sobol Matrix Declarations];:
][
  #strong[Sobol 矩阵声明];：
]

#parec[
  ```cpp
  static constexpr int NSobolDimensions = 1024;
  static constexpr int SobolMatrixSize = 52;
  PBRT_CONST uint32_t SobolMatrices32[NSobolDimensions * SobolMatrixSize];
  ```
][
  ```cpp
  static constexpr int NSobolDimensions = 1024;
  static constexpr int SobolMatrixSize = 52;
  PBRT_CONST uint32_t SobolMatrices32[NSobolDimensions * SobolMatrixSize];
  ```
]

#parec[
  The value is then randomized with the given randomizer before being rescaled to $(0 , 1)$. (The constant `0x1p-32` is $2^(- 32)$, expressed as a hexadecimal floating-point number.)
][
  然后使用给定的随机化器对值进行随机化，然后重新缩放到 (0, 1) 范围内。 (常数 `0x1p-32` 是 $2^(- 32)$，以十六进制浮点数表示。)
]

#parec[
  #strong[Randomize Sobol $p r i m e$ sample and return floating-point
value];:
][
  #strong[随机化 Sobol $p r i m e$ 样本并返回浮点值];：
]

#parec[
  ```cpp
  v = randomizer(v);
  return std::min(v * 0x1p-32f, FloatOneMinusEpsilon);
  ```
][
  ```cpp
  v = randomizer(v);
  return std::min(v * 0x1p-32f, FloatOneMinusEpsilon);
  ```
]


=== Global Sobol' Sampler
<global-sobol-sampler>



#parec[
  The `SobolSampler` generates samples by direct evaluation of the $d$ -dimensional Sobol' sequence. Like the #link("../Sampling_and_Reconstruction/Halton_Sampler.html#HaltonSampler")[HaltonSampler];, it scales the first two dimensions of the sequence to cover a range of image pixels. Thus, in a similar fashion, nearby pixels have well-distributed $d$ -dimensional sample points not just individually but also with respect to nearby pixels.
][
  `SobolSampler` 通过直接计算 $d$ 维 Sobol' 序列来生成样本。与 #link("../Sampling_and_Reconstruction/Halton_Sampler.html#HaltonSampler")[HaltonSampler] 类似，它缩放序列的前两个维度以覆盖图像像素的范围。因此，以类似的方式，附近的像素不仅在个体上，而且相对于附近的像素具有良好分布的 $d$ 维样本点。
]

#parec[
  #strong[SobolSampler Definition];:
][
  #strong[SobolSampler 定义];：
]

#parec[
  ```cpp
  class SobolSampler {
    public:
      SobolSampler(int samplesPerPixel, Point2i fullResolution,
                   RandomizeStrategy randomize, int seed = 0)
          : samplesPerPixel(samplesPerPixel), seed(seed), randomize(randomize) {
          scale = RoundUpPow2(std::max(fullResolution.x, fullResolution.y));
      }
      PBRT_CPU_GPU
      static constexpr const char *Name() { return "SobolSampler"; }
      static SobolSampler *Create(const ParameterDictionary &parameters,
                                  Point2i fullResolution, const FileLoc *loc,
                                  Allocator alloc);

      PBRT_CPU_GPU
      int SamplesPerPixel() const { return samplesPerPixel; }
      void StartPixelSample(Point2i p, int sampleIndex, int dim) {
          pixel = p;
          dimension = std::max(2, dim);
          sobolIndex = SobolIntervalToIndex(Log2Int(scale), sampleIndex, pixel);
      }
      Float Get1D() {
          if (dimension >= NSobolDimensions)
              dimension = 2;
          return SampleDimension(dimension++);
      }
      Point2f Get2D() {
          if (dimension + 1 >= NSobolDimensions)
              dimension = 2;
          Point2f u(SampleDimension(dimension), SampleDimension(dimension + 1));
          dimension += 2;
          return u;
      }
      Point2f GetPixel2D() {
          Point2f u(SobolSample(sobolIndex, 0, NoRandomizer()),
                    SobolSample(sobolIndex, 1, NoRandomizer()));
          for (int dim = 0; dim < 2; ++dim)
              u[dim] = Clamp(u[dim] * scale - pixel[dim], 0, OneMinusEpsilon);

          return u;
      }
      Sampler Clone(Allocator alloc);
      std::string ToString() const;

    private:
      Float SampleDimension(int dimension) const {
          if (randomize == RandomizeStrategy::None)
              return SobolSample(sobolIndex, dimension, NoRandomizer());
          uint32_t hash = Hash(dimension, seed);
          if (randomize == RandomizeStrategy::PermuteDigits)
              return SobolSample(sobolIndex, dimension, BinaryPermuteScrambler(hash));
          else if (randomize == RandomizeStrategy::FastOwen)
              return SobolSample(sobolIndex, dimension, FastOwenScrambler(hash));
          else
              return SobolSample(sobolIndex, dimension, OwenScrambler(hash));
      }
      int samplesPerPixel, scale, seed;
      RandomizeStrategy randomize;
      Point2i pixel;
      int dimension;
      int64_t sobolIndex;
  };
  ```
][
  ```cpp
  class SobolSampler {
    public:
      SobolSampler(int samplesPerPixel, Point2i fullResolution,
                   RandomizeStrategy randomize, int seed = 0)
          : samplesPerPixel(samplesPerPixel), seed(seed), randomize(randomize) {
          scale = RoundUpPow2(std::max(fullResolution.x, fullResolution.y));
      }
      PBRT_CPU_GPU
      static constexpr const char *Name() { return "SobolSampler"; }
      static SobolSampler *Create(const ParameterDictionary &parameters,
                                  Point2i fullResolution, const FileLoc *loc,
                                  Allocator alloc);

      PBRT_CPU_GPU
      int SamplesPerPixel() const { return samplesPerPixel; }
      void StartPixelSample(Point2i p, int sampleIndex, int dim) {
          pixel = p;
          dimension = std::max(2, dim);
          sobolIndex = SobolIntervalToIndex(Log2Int(scale), sampleIndex, pixel);
      }
      Float Get1D() {
          if (dimension >= NSobolDimensions)
              dimension = 2;
          return SampleDimension(dimension++);
      }
      Point2f Get2D() {
          if (dimension + 1 >= NSobolDimensions)
              dimension = 2;
          Point2f u(SampleDimension(dimension), SampleDimension(dimension + 1));
          dimension += 2;
          return u;
      }
      Point2f GetPixel2D() {
          Point2f u(SobolSample(sobolIndex, 0, NoRandomizer()),
                    SobolSample(sobolIndex, 1, NoRandomizer()));
          for (int dim = 0; dim < 2; ++dim)
              u[dim] = Clamp(u[dim] * scale - pixel[dim], 0, OneMinusEpsilon);

          return u;
      }
      Sampler Clone(Allocator alloc);
      std::string ToString() const;

    private:
      Float SampleDimension(int dimension) const {
          if (randomize == RandomizeStrategy::None)
              return SobolSample(sobolIndex, dimension, NoRandomizer());
          uint32_t hash = Hash(dimension, seed);
          if (randomize == RandomizeStrategy::PermuteDigits)
              return SobolSample(sobolIndex, dimension, BinaryPermuteScrambler(hash));
          else if (randomize == RandomizeStrategy::FastOwen)
              return SobolSample(sobolIndex, dimension, FastOwenScrambler(hash));
          else
              return SobolSample(sobolIndex, dimension, OwenScrambler(hash));
      }
      int samplesPerPixel, scale, seed;
      RandomizeStrategy randomize;
      Point2i pixel;
      int dimension;
      int64_t sobolIndex;
  };
  ```
]

#parec[
  The `SobolSampler` uniformly scales the first two dimensions by the smallest power of two that causes the $(0 , 1)^2$ sample domain to cover the image area to be sampled. As with the #link("../Sampling_and_Reconstruction/Halton_Sampler.html#HaltonSampler")[HaltonSampler];, this specific scaling scheme is chosen in order to make it easier to compute the reverse mapping from pixel coordinates to the sample indices that land in each pixel.
][
  `SobolSampler` 通过最小的二次幂均匀缩放前两个维度，使 $(0 , 1)^2$ 样本域覆盖要采样的图像区域。与 #link("../Sampling_and_Reconstruction/Halton_Sampler.html#HaltonSampler")[HaltonSampler] 类似，这种特定的缩放方案是为了更容易计算从像素坐标到每个像素中样本索引的反向映射。
]

#parec[
  All four of the randomization approaches from Section #link("<sec:sobol-scrambling>")[8.7.2] are supported by the `SobolSampler`; `randomize` encodes which one to apply.
][
  `SobolSampler` 支持第 #link("<sec:sobol-scrambling>")[8.7.2] 节中的所有四种随机化方法；`randomize` 编码要应用哪一种。
]

#parec[
  The sampler needs to record the current pixel for use in its `GetPixel2D()` method and, like other samplers, tracks the current dimension in its `dimension` member variable.
][
  采样器需要记录当前像素位置以供其 `GetPixel2D()` 方法使用，并且像其他采样器一样，在其 `dimension` 成员变量中跟踪当前维度。
]

#parec[
  The `SobolIntervalToIndex()` function returns the index of the `sampleIndex`th sample in the pixel `p`, if the $(0 , 1)^2$ sampling domain has been scaled by $2^(e x t l o g_2 e x t s c a l e)$ to cover the pixel sampling area.
][
  `SobolIntervalToIndex()` 函数返回像素 `p` 中 `sampleIndex` 的样本索引，如果 $(0 , 1)^2$ 采样域已被 $2^(e x t l o g_2 e x t s c a l e)$ 缩放以覆盖像素采样区域。
]

#parec[
  ```cpp
  uint64_t SobolIntervalToIndex(uint32_t log2Scale, uint64_t sampleIndex,
                                Point2i p);
  ```
][
  ```cpp
  uint64_t SobolIntervalToIndex(uint32_t log2Scale, uint64_t sampleIndex,
                                Point2i p);
  ```
]

#parec[
  The general approach used to derive the algorithm it implements is similar to that used by the Halton sampler in its `StartPixelSample()` method. Here, scaling by a power of two means that the base-2 logarithm of the scale gives the number of digits of the \$ extbf{C}ig(d\_i(a)ig)^T\$ product that form the scaled sample's integer component. To find the values of $a$ that give a particular integer value after scaling, we can compute the inverse of \$ extbf{C}\$:
][
  用于推导其实现算法的总体方法类似于 Halton 采样器在其 `StartPixelSample()` 方法中使用的方法。在这里，通过二次幂缩放意味着比例的基-2 对数给出了形成缩放样本整数分量的 \$ extbf{C}ig(d\_i(a)ig)^T\$ 乘积的数字数。要找到在缩放后给出特定整数值的 $a$ 的值，我们可以计算 \$ extbf{C}\$ 矩阵的逆：
]


#parec[
  $ v = upright(bold(C)) [d_i (a)]^T , $
][
  $ v = upright(bold(C)) [d_i (a)]^T , $
]

#parec[
  then equivalently
][
  那么等价地
]

#parec[
  $ upright(bold(C))^(- 1) v = [d_i (a)]^T . $
][
  $ upright(bold(C))^(- 1) v = [d_i (a)]^T . $
]

#parec[
  We will not include the implementation of this function here.
][
  我们不会在这里包含此函数的实现。
]

#parec[
  Sample generation is now straightforward. There is the usual management of the `dimension` value, again with the first two dimensions reserved for the pixel sample, and then a call to `SampleDimension()` gives the sample for a single Sobol' dimension.
][
  样本生成现在变得简单明了。需要像往常一样管理 `dimension` 值，前两个维度仍然保留用于像素样本，然后调用 `SampleDimension()` 来获取单个 Sobol' 维度的样本。
]

#parec[
  ```cpp
  Float Get1D() {
      if (dimension >= NSobolDimensions)
          dimension = 2;
      return SampleDimension(dimension++);
  }
  ```
][
  ```cpp
  Float Get1D() {
      if (dimension >= NSobolDimensions)
          dimension = 2;
      return SampleDimension(dimension++);
  }
  ```
]

#parec[
  The `SampleDimension()` method takes care of calling #link("<SobolSample>")[`SobolSample()`] for the current sample index and specified dimension using the appropriate randomizer.
][
  `SampleDimension()` 方法负责使用合适的随机化器为当前样本索引和指定维度调用 #link("<SobolSample>")[`SobolSample()`];。
]

#parec[
  ```cpp
  Float SampleDimension(int dimension) const {
      // Return un-randomized Sobol prime sample if appropriate
      if (randomize == RandomizeStrategy::None)
          return SobolSample(sobolIndex, dimension, NoRandomizer());
      // Return randomized Sobol prime sample using randomize
      uint32_t hash = Hash(dimension, seed);
      if (randomize == RandomizeStrategy::PermuteDigits)
          return SobolSample(sobolIndex, dimension, BinaryPermuteScrambler(hash));
      else if (randomize == RandomizeStrategy::FastOwen)
          return SobolSample(sobolIndex, dimension, FastOwenScrambler(hash));
      else
          return SobolSample(sobolIndex, dimension, OwenScrambler(hash));
  }
  ```
][
  ```cpp
  Float SampleDimension(int dimension) const {
      // 如果合适，返回未随机化的 Sobol 素数样本
      if (randomize == RandomizeStrategy::None)
          return SobolSample(sobolIndex, dimension, NoRandomizer());
      // 使用随机化返回随机化的 Sobol 素数样本
      uint32_t hash = Hash(dimension, seed);
      if (randomize == RandomizeStrategy::PermuteDigits)
          return SobolSample(sobolIndex, dimension, BinaryPermuteScrambler(hash));
      else if (randomize == RandomizeStrategy::FastOwen)
          return SobolSample(sobolIndex, dimension, FastOwenScrambler(hash));
      else
          return SobolSample(sobolIndex, dimension, OwenScrambler(hash));
  }
  ```
]

#parec[
  If a randomizer is being used, a seed value must be computed for it. Note that the hash value passed to each randomizer is based solely on the current dimension and user-provided seed, if any. It must #emph[not] be based on the current pixel or the current sample index within the pixel, since the same randomization should be used at all the pixels and all the samples within them.
][
  如果使用随机化器，则必须计算一个种子值。注意传递给每个随机化器的哈希值仅基于当前维度和用户提供的种子（如果有）。它#emph[不应];基于当前像素或像素内的当前样本索引，因为相同的随机化应在所有像素和其中的所有样本中使用。
]

#parec[
  ```cpp
  // Return un-randomized Sobol prime sample if appropriate
  if (randomize == RandomizeStrategy::None)
      return SobolSample(sobolIndex, dimension, NoRandomizer());
  ```
][
  ```cpp
  // 如果合适，返回未随机化的 Sobol 素数样本
  if (randomize == RandomizeStrategy::None)
      return SobolSample(sobolIndex, dimension, NoRandomizer());
  ```
]

#parec[
  ```cpp
  uint32_t hash = Hash(dimension, seed);
  if (randomize == RandomizeStrategy::PermuteDigits)
      return SobolSample(sobolIndex, dimension, BinaryPermuteScrambler(hash));
  else if (randomize == RandomizeStrategy::FastOwen)
      return SobolSample(sobolIndex, dimension, FastOwenScrambler(hash));
  else
      return SobolSample(sobolIndex, dimension, OwenScrambler(hash));
  ```
][
  ```cpp
  uint32_t hash = Hash(dimension, seed);
  if (randomize == RandomizeStrategy::PermuteDigits)
      return SobolSample(sobolIndex, dimension, BinaryPermuteScrambler(hash));
  else if (randomize == RandomizeStrategy::FastOwen)
      return SobolSample(sobolIndex, dimension, FastOwenScrambler(hash));
  else
      return SobolSample(sobolIndex, dimension, OwenScrambler(hash));
  ```
]

#parec[
  2D sample generation is easily implemented using `SampleDimension()`. If all sample dimensions have been consumed, `Get2D()` goes back to the start and skips the first two dimensions, as was done in the `HaltonSampler`.
][
  `SampleDimension()` 可以轻松实现 2D 样本生成。如果所有样本维度都已用完，`Get2D()` 将返回到开始并跳过前两个维度，就像在 `HaltonSampler` 中的做法。
]

#parec[
  ```cpp
  Point2f Get2D() {
      if (dimension + 1 >= NSobolDimensions)
          dimension = 2;
      Point2f u(SampleDimension(dimension), SampleDimension(dimension + 1));
      dimension += 2;
      return u;
  }
  ```
][
  ```cpp
  Point2f Get2D() {
      if (dimension + 1 >= NSobolDimensions)
          dimension = 2;
      Point2f u(SampleDimension(dimension), SampleDimension(dimension + 1));
      dimension += 2;
      return u;
  }
  ```
]

#parec[
  Pixel samples are generated using the first two dimensions of the Sobol' sample. #link("<SobolIntervalToIndex>")[`SobolIntervalToIndex()`] does not account for randomization, so the #link("<NoRandomizer>")[`NoRandomizer`] is always used for the pixel sample, regardless of the value of `randomize`.
][
  像素样本使用 Sobol' 样本的前两个维度生成。#link("<SobolIntervalToIndex>")[`SobolIntervalToIndex()`] 不考虑随机化，因此无论 `randomize` 的值如何，像素样本始终使用 #link("<NoRandomizer>")[`NoRandomizer`];。
]

#parec[
  ```cpp
  Point2f GetPixel2D() {
      Point2f u(SobolSample(sobolIndex, 0, NoRandomizer()),
                SobolSample(sobolIndex, 1, NoRandomizer()));
      // Remap Sobol prime dimensions used for pixel samples
      for (int dim = 0; dim < 2; ++dim)
          u[dim] = Clamp(u[dim] * scale - pixel[dim], 0, OneMinusEpsilon);

      return u;
  }
  ```
][
  ```cpp
  Point2f GetPixel2D() {
      Point2f u(SobolSample(sobolIndex, 0, NoRandomizer()),
                SobolSample(sobolIndex, 1, NoRandomizer()));
      // 重新映射用于像素样本的 Sobol 素数维度
      for (int dim = 0; dim < 2; ++dim)
          u[dim] = Clamp(u[dim] * scale - pixel[dim], 0, OneMinusEpsilon);

      return u;
  }
  ```
]

#parec[
  The samples returned for the pixel position need to be adjusted so that they are offsets within the current pixel. Similar to what was done in the #link("../Sampling_and_Reconstruction/Halton_Sampler.html#HaltonSampler")[`HaltonSampler`];, the sample value is scaled so that the pixel coordinates are in the integer component of the result. The remaining fractional component gives the offset within the pixel that the sampler returns.
][
  返回的像素位置样本需要进行调整，以便它们是当前像素内的偏移量。类似于在 #link("../Sampling_and_Reconstruction/Halton_Sampler.html#HaltonSampler")[`HaltonSampler`] 中的做法，样本值被缩放，以便像素坐标位于结果的整数部分。剩余的小数部分给出采样器返回的像素内的偏移量。
]

#parec[
  ```cpp
  // Remap Sobol prime dimensions used for pixel samples
  for (int dim = 0; dim < 2; ++dim)
      u[dim] = Clamp(u[dim] * scale - pixel[dim], 0, OneMinusEpsilon);
  ```
][
  ```cpp
  // 重新映射用于像素样本的 Sobol 素数维度
  for (int dim = 0; dim < 2; ++dim)
      u[dim] = Clamp(u[dim] * scale - pixel[dim], 0, OneMinusEpsilon);
  ```
]


#parec[
  The `SobolSampler` generates sample points that have low discrepancy over all of their $d$ dimensions. However, the distribution of samples in two-dimensional slices of the $d$ -dimensional space is not necessarily particularly good. Figure 8.36 shows an example.
][
  `SobolSampler` 生成的样本点在其所有 $d$ 维度上具有低不一致性。然而，在 $d$ 维空间的二维切片中的样本分布不一定特别均匀。图 8.36 显示了一个例子。
]

#parec[
  For rendering, this state of affairs means that, for example, the samples taken over the surface of a light source at a given pixel may not be well distributed. It is of only slight solace to know that the full set of $d$ -dimensional samples are well distributed in return. Figure 8.37 shows this problem in practice with the `SobolSampler`: 2D projections of the form shown in Figure 8.36 end up generating a characteristic checkerboard pattern in the image at low sampling rates.
][
  这意味着在渲染时，例如，在给定像素的光源表面上采集的样本可能分布不佳。仅仅知道完整的 $d$ 维样本集分布良好并不能带来多大安慰。图 8.37 显示了使用 `SobolSampler` 实际遇到的问题：如图 8.36 所示的形式的二维投影最终在低采样率下在图像中生成了典型的棋盘图案。
]

#parec[
  Therefore, the `PaddedSobolSampler` generates samples from the Sobol' sequence in a way that focuses on returning good distributions for the dimensions used by each 1D and 2D sample independently. It does so via padding samples, similarly to the `StratifiedSampler`, but here using Sobol' samples rather than jittered samples.
][
  因此，`PaddedSobolSampler` 以一种专注于为每个 1D 和 2D 样本独立使用的维度提供良好分布的方式从 Sobol' 序列中生成样本。它通过填充样本来实现这一点，类似于 `StratifiedSampler`，但这里使用的是 Sobol' 样本而不是抖动样本。
]

#parec[
  class PaddedSobolSampler { public: \/\/ Public Methods PBRT\_CPU\_GPU static constexpr const char #emph[Name() { return "PaddedSobolSampler";
} static PaddedSobolSampler ];Create(const ParameterDictionary &parameters, const FileLoc \*loc, Allocator alloc); PaddedSobolSampler(int samplesPerPixel, RandomizeStrategy randomizer, int seed = 0) : samplesPerPixel(samplesPerPixel), randomize(randomizer), seed(seed) { if (!IsPowerOf2(samplesPerPixel)) Warning("Sobol samplers with non power-of-two sample counts (%d) are suboptimal.", samplesPerPixel); } PBRT\_CPU\_GPU int SamplesPerPixel() const { return samplesPerPixel; } void StartPixelSample(Point2i p, int index, int dim) { pixel = p; sampleIndex = index; dimension = dim; } Float Get1D() { \\/\/ Get permuted index for current pixel sample uint64\_t hash = Hash(pixel, dimension, seed); int index = PermutationElement(sampleIndex, samplesPerPixel, hash); int dim = dimension++; \/\/ Return randomized 1D van der Corput sample for dimension dim return SampleDimension(0, index, hash \>\> 32); } Point2f Get2D() { \/\/ Get permuted index for current pixel sample uint64\_t hash = Hash(pixel, dimension, seed); int index = PermutationElement(sampleIndex, samplesPerPixel, hash); int dim = dimension; dimension += 2; \/\/ Return randomized 2D Sobol prime sample return Point2f(SampleDimension(0, index, uint32\_t(hash)), SampleDimension(1, index, hash \>\> 32)); } Point2f GetPixel2D() { return Get2D(); } PBRT\_CPU\_GPU RandomizeStrategy GetRandomizeStrategy() const { return randomize; } Sampler Clone(Allocator alloc); std::string ToString() const; private: \/\/ Private Methods Float SampleDimension(int dimension, uint32\_t a, uint32\_t hash) const { if (randomize == RandomizeStrategy::None) return SobolSample(a, dimension, NoRandomizer()); else if (randomize == RandomizeStrategy::PermuteDigits) return SobolSample(a, dimension, BinaryPermuteScrambler(hash)); else if (randomize == RandomizeStrategy::FastOwen) return SobolSample(a, dimension, FastOwenScrambler(hash)); else return SobolSample(a, dimension, OwenScrambler(hash)); } private: int samplesPerPixel, seed; RandomizeStrategy randomize; Point2i pixel; int sampleIndex, dimension; };
][
  ```cpp
  class PaddedSobolSampler {
    public:
      // 公共方法
      PBRT_CPU_GPU
      static constexpr const char *Name() { return "PaddedSobolSampler"; }
      static PaddedSobolSampler *Create(const ParameterDictionary &parameters,
                                         const FileLoc *loc, Allocator alloc);
      PaddedSobolSampler(int samplesPerPixel, RandomizeStrategy randomizer, int seed = 0)
          : samplesPerPixel(samplesPerPixel), randomize(randomizer), seed(seed) {
          if (!IsPowerOf2(samplesPerPixel))
              Warning("Sobol 采样器的样本数量不是 2 的幂 (%d) 时效果不佳。",
                      samplesPerPixel);
      }
      PBRT_CPU_GPU
      int SamplesPerPixel() const { return samplesPerPixel; }
      void StartPixelSample(Point2i p, int index, int dim) {
          pixel = p;
          sampleIndex = index;
          dimension = dim;
      }
      Float Get1D() {
          // 获取当前像素样本的置换索引
          uint64_t hash = Hash(pixel, dimension, seed);
          int index = PermutationElement(sampleIndex, samplesPerPixel, hash);
          int dim = dimension++;
          // 返回维度 dim 的随机化 1D van der Corput 样本
          return SampleDimension(0, index, hash >> 32);
      }
      Point2f Get2D() {
          // 获取当前像素样本的置换索引
          uint64_t hash = Hash(pixel, dimension, seed);
          int index = PermutationElement(sampleIndex, samplesPerPixel, hash);
          int dim = dimension;
          dimension += 2;
          // 返回随机化的 2D Sobol' 样本
          return Point2f(SampleDimension(0, index, uint32_t(hash)),
                         SampleDimension(1, index, hash >> 32));
      }
      Point2f GetPixel2D() { return Get2D(); }
      PBRT_CPU_GPU
      RandomizeStrategy GetRandomizeStrategy() const { return randomize; }
      Sampler Clone(Allocator alloc);
      std::string ToString() const;
    private:
      // 私有方法
      Float SampleDimension(int dimension, uint32_t a, uint32_t hash) const {
          if (randomize == RandomizeStrategy::None)
              return SobolSample(a, dimension, NoRandomizer());
          else if (randomize == RandomizeStrategy::PermuteDigits)
              return SobolSample(a, dimension, BinaryPermuteScrambler(hash));
          else if (randomize == RandomizeStrategy::FastOwen)
              return SobolSample(a, dimension, FastOwenScrambler(hash));
          else
              return SobolSample(a, dimension, OwenScrambler(hash));
      }
    private:
      int samplesPerPixel, seed;
      RandomizeStrategy randomize;
      Point2i pixel;
      int sampleIndex, dimension;
  };
  ```
]

#parec[
  The constructor, not included here, initializes the following member variables from provided values. As with the `SobolSampler`, using a pixel sample count that is not a power of 2 will give suboptimal results; a warning is issued in this case.
][
  这里未包含的构造函数从提供的值初始化以下成员变量。与 `SobolSampler` 一样，使用不是 2 的幂的像素样本计数会产生次优结果；在这种情况下会给出警告。
]

#parec[
  1D samples are generated by randomly shuffling a randomized van der Corput sequence.
][
  通过随机打乱随机化的 van der Corput 序列生成 1D 样本。
]

#parec[
  Here, the permutation used for padding is based on the current pixel and dimension. It must not be based on the sample index, as the same permutation should be applied to all sample indices of a given dimension in a given pixel.
][
  这里用于填充的置换基于当前像素和维度。它不应基于样本索引，因为对于给定像素中给定维度的所有样本索引应该应用相同的置换。
]

#parec[
  Given the permuted sample index value `index`, a separate method, `SampleDimension()`, takes care of generating the corresponding Sobol' sample. The high bits of the hash value are reused for the sample's randomization; doing so should be safe, since `PermutationElement()` uses the hash it is passed in an entirely different way than any of the sample randomization schemes do.
][
  给定置换后的样本索引值 `index`，一个单独的方法 `SampleDimension()` 负责生成相应的 Sobol' 样本。哈希值的高位用于样本的随机化；这样做应该是安全的，因为 `PermutationElement()` 以与任何样本随机化方案完全不同的方式使用它所传递的哈希。
]

#parec[
  Padded 2D samples are generated starting with a similar permutation of sample indices.
][
  填充的 2D 样本从类似的样本索引置换开始生成。
]

#parec[
  Randomization also parallels the 1D case; again, bits from `hash` are used both for the random permutation of sample indices and for sample randomization.
][
  随机化也与 1D 情况类似；再次，`hash` 的位用于样本索引的随机置换和样本随机化。
]

#parec[
  For this sampler, pixel samples are generated in the same manner as all other 2D samples, so the sample generation request is forwarded on to `Get2D()`.
][
  对于此采样器，像素样本的生成方式与所有其他 2D 样本相同，因此样本生成请求被转发到 `Get2D()`。
]


#parec[
  `ZSobolSampler` is a third sampler based on the Sobol' sequence. It is also based on padding 1D and 2D Sobol' samples, but uses sample indices in a way that leads to a blue noise distribution of sample values. This tends to push error to higher frequencies, which in turn makes it appear more visually pleasing.
][
  `ZSobolSampler` 是基于 Sobol' 序列的第三种采样器。它同样基于填充 1D 和 2D Sobol' 样本，但使用样本索引的方式导致样本值呈现蓝噪声分布。这通常会将误差推向更高频率，从而使其视觉上更具吸引力。
]

#parec[
  Figure 8.38 compares a scene rendered with the `PaddedSobolSampler` and the `ZSobolSampler`; both have essentially the same MSE, but the one rendered using `ZSobolSampler` looks better to most human observers.
][
  图 8.38 比较了使用 `PaddedSobolSampler` 和 `ZSobolSampler` 渲染的场景；两者的 MSE 基本相同，但使用 `ZSobolSampler` 渲染的图像对大多数人类观察者来说看起来更好。
]

#parec[
  This `Sampler` is the default one used by `pbrt` if no sampler is specified in the scene description.
][
  ZSobolSampler 是 `pbrt` 默认使用的采样器，如果场景描述中没有指定采样器。
]

#parec[
  class ZSobolSampler { public: ZSobolSampler(int samplesPerPixel, Point2i fullResolution, RandomizeStrategy randomize, int seed = 0) : randomize(randomize), seed(seed) { log2SamplesPerPixel = Log2Int(samplesPerPixel); int res = RoundUpPow2(std::max(fullResolution.x, fullResolution.y)); int log4SamplesPerPixel = (log2SamplesPerPixel + 1) / 2; nBase4Digits = Log2Int(res) + log4SamplesPerPixel; } PBRT\_CPU\_GPU static constexpr const char \*Name() { return "ZSobolSampler"; }
][
  ```cpp
  class ZSobolSampler {
    public:
      ZSobolSampler(int samplesPerPixel, Point2i fullResolution,
                    RandomizeStrategy randomize, int seed = 0)
             : randomize(randomize), seed(seed) {
             log2SamplesPerPixel = Log2Int(samplesPerPixel);
             int res = RoundUpPow2(std::max(fullResolution.x, fullResolution.y));
             int log4SamplesPerPixel = (log2SamplesPerPixel + 1) / 2;
             nBase4Digits = Log2Int(res) + log4SamplesPerPixel;
         }
         PBRT_CPU_GPU
         static constexpr const char *Name() { return "ZSobolSampler"; }

         static ZSobolSampler *Create(const ParameterDictionary &parameters,
                                      Point2i fullResolution, const FileLoc *loc,
                                      Allocator alloc);

         PBRT_CPU_GPU
         int SamplesPerPixel() const { return 1 << log2SamplesPerPixel; }
         void StartPixelSample(Point2i p, int index, int dim) {
             dimension = dim;
             mortonIndex = (EncodeMorton2(p.x, p.y) << log2SamplesPerPixel) | index;
         }
         Float Get1D() {
             uint64_t sampleIndex = GetSampleIndex();
             ++dimension;
             uint32_t sampleHash = Hash(dimension, seed);
             if (randomize == RandomizeStrategy::None)
                 return SobolSample(sampleIndex, 0, NoRandomizer());
             else if (randomize == RandomizeStrategy::PermuteDigits)
                 return SobolSample(sampleIndex, 0, BinaryPermuteScrambler(sampleHash));
             else if (randomize == RandomizeStrategy::FastOwen)
                 return SobolSample(sampleIndex, 0, FastOwenScrambler(sampleHash));
             else
                 return SobolSample(sampleIndex, 0, OwenScrambler(sampleHash));
         }
         Point2f Get2D() {
             uint64_t sampleIndex = GetSampleIndex();
             dimension += 2;
             uint64_t bits = Hash(dimension, seed);
             uint32_t sampleHash[2] = {uint32_t(bits), uint32_t(bits >> 32)};
             if (randomize == RandomizeStrategy::None)
                 return {SobolSample(sampleIndex, 0, NoRandomizer()),
                         SobolSample(sampleIndex, 1, NoRandomizer())};
             else if (randomize == RandomizeStrategy::PermuteDigits)
                 return {SobolSample(sampleIndex, 0, BinaryPermuteScrambler(sampleHash[0])),
                         SobolSample(sampleIndex, 1, BinaryPermuteScrambler(sampleHash[1]))};
             else if (randomize == RandomizeStrategy::FastOwen)
                 return {SobolSample(sampleIndex, 0, FastOwenScrambler(sampleHash[0])),
                         SobolSample(sampleIndex, 1, FastOwenScrambler(sampleHash[1]))};
             else
                 return {SobolSample(sampleIndex, 0, OwenScrambler(sampleHash[0])),
                         SobolSample(sampleIndex, 1, OwenScrambler(sampleHash[1]))};
         }
         Point2f GetPixel2D() { return Get2D(); }
         Sampler Clone(Allocator alloc);
         std::string ToString() const;
         uint64_t GetSampleIndex() const {
             static const uint8_t permutations[24][4] = {
                    {0, 1, 2, 3}, {0, 1, 3, 2}, {0, 2, 1, 3}, {0, 2, 3, 1},
                    {0, 3, 2, 1}, {0, 3, 1, 2}, {1, 0, 2, 3}, {1, 0, 3, 2}, {1, 2, 0, 3}, {1, 2, 3, 0},
                    {1, 3, 2, 0}, {1, 3, 0, 2}, {2, 1, 0, 3}, {2, 1, 3, 0}, {2, 0, 1, 3},
                    {2, 0, 3, 1}, {2, 3, 0, 1}, {2, 3, 1, 0}, {3, 1, 2, 0}, {3, 1, 0, 2},
                    {3, 2, 1, 0}, {3, 2, 0, 1}, {3, 0, 2, 1}, {3, 0, 1, 2}
                };
             uint64_t sampleIndex = 0;
             bool pow2Samples = log2SamplesPerPixel & 1;
             int lastDigit = pow2Samples ? 1 : 0;
             for (int i = nBase4Digits - 1; i >= lastDigit; --i) {
                 int digitShift = 2 * i - (pow2Samples ? 1 : 0);
                 int digit = (mortonIndex >> digitShift) & 3;
                 uint64_t higherDigits = mortonIndex >> (digitShift + 2);
                 int p = (MixBits(higherDigits ^ (0x55555555u * dimension)) >> 24) % 24;
                 digit = permutations[p][digit];
                 sampleIndex |= uint64_t(digit) << digitShift;
             }
             if (pow2Samples) {
                 int digit = mortonIndex & 1;
                 sampleIndex |= digit ^ (MixBits((mortonIndex >> 1) ^ (0x55555555u * dimension)) & 1);
             }
             return sampleIndex;
         }
    private:
      RandomizeStrategy randomize;
      int seed, log2SamplesPerPixel, nBase4Digits;
      uint64_t mortonIndex;
      int dimension;
  };
  ```
]

#parec[
  This sampler generates blue noise samples by taking advantage of the properties of $(0 , 2)$ -sequences. To understand the idea behind its implementation, first consider rendering a two-pixel image using 16 samples per pixel where a set of 2D samples are used for area light source sampling in each pixel.
][
  该采样器通过利用 $(0 , 2)$ -序列的特性生成蓝噪声样本。要理解其实现背后的思想，首先考虑使用 16 个样本每像素渲染一个两像素图像，其中一组 2D 样本用于每个像素的区域光源采样。
]

#parec[
  If the first 16 samples from a $(0 , 2)$ -sequence are used for the first pixel and the next 16 for the second, then not only will each pixel individually use well-stratified samples, but the set of all 32 samples will collectively be well stratified thanks to the stratification of $(0 , 2)$ -sequences over elementary intervals (Section 8.7.1).
][
  如果 $(0 , 2)$ -序列的前 16 个样本用于第一个像素，接下来的 16 个样本用于第二个像素，那么不仅每个像素单独使用良好分层的样本，而且由于 $(0 , 2)$ -序列在基本区间上的分层，所有 32 个样本的集合也将集体良好分层。
]

#parec[
  Consequently, the samples used in each pixel will generally be in different locations than in the other pixel, which is precisely the sample decorrelation exhibited by blue noise. (See Figure 8.39.)
][
  因此，每个像素使用的样本通常与其他像素不同位置，这正是蓝噪声所表现的样本去相关性。（见图 8.39。）
]

#parec[
  More generally, if all the pixels in an image take different power-of-2 aligned and sized segments of samples from a single large set of Sobol' samples in a way that nearby pixels generally take adjacent segments, then the distribution of samples across the entire image will be such that pixels generally use different sample values than their neighbors.
][
  更一般地，如果图像中的所有像素从一个大型 Sobol' 样本集中以不同的 2 的幂对齐和大小的段中取样，并且通常相邻的像素取相邻的段，那么整个图像的样本分布将使得像素通常使用与其邻居不同的样本值。
]

#parec[
  Allocating segments of samples in scanline order would give good distributions along scanlines, but it would not do much from scanline to scanline.
][
  按扫描线顺序分配样本段会在扫描线上给出良好的分布，但在扫描线之间作用不大。
]

#parec[
  The Morton curve, which was introduced earlier in Section 7.3.3 in the context of linear bounding volume hierarchies, gives a better mechanism for this task: if we compute the Morton code for each pixel $(x , y)$ and then use that to determine the pixel's starting index into the full set of Sobol' samples, then nearby pixels—those that are nearby in both $x$ and $y$ —will tend to use nearby segments of the samples.
][
  Morton 曲线在第 7.3.3 节的线性包围体层次结构中被引入，为此任务提供了更好的机制：如果我们计算每个像素 $(x , y)$ 的 Morton 索引，然后用它来确定像素在整个 Sobol' 样本集中的起始索引，那么相邻像素——即在 $x$ 和 $y$ 上都相邻的像素——将倾向于使用样本的相邻段。
]

#parec[
  This idea is illustrated in Figure 8.40.
][
  这个想法在图 8.40 中得到了说明。
]

#parec[
  Used directly in this manner, the Morton curve can lead to visible structure in the image; see Figure 8.41, where samples were allocated in that way.
][
  直接以这种方式使用，Morton 曲线可能导致图像中出现可见结构；见图 8.41，其中样本以这种方式分配。
]

#parec[
  This issue can be addressed with a random permutation of the Morton indices interpreted as base-4 numbers, which effectively groups pairs of one bit from $x$ and one bit from $y$ in the Morton index into single base-4 digits.
][
  这个问题可以通过将 Morton 索引解释为基数为 4 的数字并随机排列其数字来解决，这有效地将 Morton 索引中的 $x$ 和 $y$ 的一位配对为单个基数为 4 的数字。
]

#parec[
  Randomly permuting these digits still maintains much of the spatial coherence of the Morton curve; see Figure 8.42 for an illustration of the permutation approach.
][
  随机排列这些数字仍然保持了 Morton 曲线的大部分空间连贯性；见图 8.42 中对排列方法的说明。
]

#parec[
  Figure 8.38(b) shows the resulting improvement in a rendered image.
][
  图 8.38(b) 显示了渲染图像中由此产生的改进。
]

#parec[
  A second problem with the approach as described so far is that it does not randomize the order of sample indices within a pixel, as is necessary for padding samples across different dimensions.
][
  到目前为止所描述的方法的第二个问题是它没有随机化像素内样本索引的顺序，而这对于在不同维度上填充样本是必要的。
]

#parec[
  This shortcoming can be addressed by appending the bits of the sample index within a pixel to the pixel's Morton code and then including those in the index randomization as well.
][
  这个问题可以通过将像素内样本索引的位附加到像素的 Morton 码上，并将其包括在索引随机化中来解决。
]

#parec[
  In addition to the usual configuration parameters, the `ZSobolSampler` constructor also stores the base-2 logarithm of the number of samples per pixel as well as the number of base-4 digits in the full extended Morton index that includes the sample index.
][
  除了通常的配置参数外，`ZSobolSampler` 构造函数还存储每像素样本数的以 2 为底的对数以及包含样本索引的完整扩展 Morton 索引中的基数为 4 的数字数。
]

#parec[
  ZSobolSampler(int samplesPerPixel, Point2i fullResolution, RandomizeStrategy randomize, int seed = 0) : randomize(randomize), seed(seed) { log2SamplesPerPixel = Log2Int(samplesPerPixel); int res = RoundUpPow2(std::max(fullResolution.x, fullResolution.y)); int log4SamplesPerPixel = (log2SamplesPerPixel + 1) / 2; nBase4Digits = Log2Int(res) + log4SamplesPerPixel; }
][
  ```cpp
  ZSobolSampler(int samplesPerPixel, Point2i fullResolution,
                RandomizeStrategy randomize, int seed = 0)
      : randomize(randomize), seed(seed) {
      log2SamplesPerPixel = Log2Int(samplesPerPixel);
      int res = RoundUpPow2(std::max(fullResolution.x, fullResolution.y));
      int log4SamplesPerPixel = (log2SamplesPerPixel + 1) / 2;
      nBase4Digits = Log2Int(res) + log4SamplesPerPixel;
  }
  ```
]

#parec[
  The `StartPixelSample()` method's main task is to construct the initial unpermuted sample index by computing the pixel's Morton code and then appending the sample index, using a left shift to make space for it.
][
  `StartPixelSample()` 方法的主要任务是通过计算像素的 Morton 索引并附加样本索引来构造初始未排列的样本索引，使用左移操作为其腾出空间。
]

#parec[
  This value is stored in `mortonIndex`.
][
  这个值存储在 `mortonIndex` 中。
]

#parec[
  Sample generation is similar to the `PaddedSobolSampler` with the exception that the index of the sample is found with a call to the `GetSampleIndex()` method (shown next), which randomizes `mortonIndex`.
][
  样本生成与 `PaddedSobolSampler` 类似，区别在于样本的索引是通过调用 `GetSampleIndex()` 方法（如下所示）找到的，该方法随机化 `mortonIndex`。
]

#parec[
  The `Generate 1D Sobol prime sample at sampleIndex` fragment then calls `SobolSample()` to generate the `sampleIndex`th sample using the appropriate randomizer.
][
  `Generate 1D Sobol prime sample at sampleIndex` 片段然后调用 `SobolSample()` 使用适当的随机化器生成第 `sampleIndex` 个样本。
]

#parec[
  It is otherwise effectively the same as the `PaddedSobolSampler::SampleDimension()` method, so its implementation is not included here.
][
  除此之外，它与 `PaddedSobolSampler::SampleDimension()` 方法基本相同，因此其实现不包括在此。
]

#parec[
  Float Get1D() { uint64\_t sampleIndex = GetSampleIndex(); ++dimension; uint32\_t sampleHash = Hash(dimension, seed); if (randomize == RandomizeStrategy::None) return SobolSample(sampleIndex, 0, NoRandomizer()); else if (randomize == RandomizeStrategy::PermuteDigits) return SobolSample(sampleIndex, 0, BinaryPermuteScrambler(sampleHash)); else if (randomize == RandomizeStrategy::FastOwen) return SobolSample(sampleIndex, 0, FastOwenScrambler(sampleHash)); else return SobolSample(sampleIndex, 0, OwenScrambler(sampleHash)); }
][
  ```cpp
  Float Get1D() {
      uint64_t sampleIndex = GetSampleIndex();
      ++dimension;
      uint32_t sampleHash = Hash(dimension, seed);
      if (randomize == RandomizeStrategy::None)
          return SobolSample(sampleIndex, 0, NoRandomizer());
      else if (randomize == RandomizeStrategy::PermuteDigits)
          return SobolSample(sampleIndex, 0, BinaryPermuteScrambler(sampleHash));
      else if (randomize == RandomizeStrategy::FastOwen)
          return SobolSample(sampleIndex, 0, FastOwenScrambler(sampleHash));
      else
          return SobolSample(sampleIndex, 0, OwenScrambler(sampleHash));
  }
  ```
]

#parec[
  2D samples are generated in a similar manner, using the first two Sobol' sequence dimensions and a sample index returned by `GetSampleIndex()`.
][
  2D 样本以类似的方式生成，使用 Sobol' 序列的前两个维度和 `GetSampleIndex()` 返回的样本索引。
]

#parec[
  Here as well, the fragment that dispatches calls to `SobolSample()` corresponding to the chosen randomization scheme is not included.
][
  在这里，分派调用 `SobolSample()` 对应于所选随机化方案的片段未包括在内。
]

#parec[
  Point2f Get2D() { uint64\_t sampleIndex = GetSampleIndex(); dimension += 2; uint64\_t bits = Hash(dimension, seed); uint32\_t sampleHash\[2\] = {uint32\_t(bits), uint32\_t(bits \>\> 32)}; if (randomize == RandomizeStrategy::None) return {SobolSample(sampleIndex, 0, NoRandomizer()), SobolSample(sampleIndex, 1, NoRandomizer())}; else if (randomize == RandomizeStrategy::PermuteDigits) return {SobolSample(sampleIndex, 0, BinaryPermuteScrambler(sampleHash\[0\])), SobolSample(sampleIndex, 1, BinaryPermuteScrambler(sampleHash\[1\]))}; else if (randomize == RandomizeStrategy::FastOwen) return {SobolSample(sampleIndex, 0, FastOwenScrambler(sampleHash\[0\])), SobolSample(sampleIndex, 1, FastOwenScrambler(sampleHash\[1\]))}; else return {SobolSample(sampleIndex, 0, OwenScrambler(sampleHash\[0\])), SobolSample(sampleIndex, 1, OwenScrambler(sampleHash\[1\]))}; }
][
  ```cpp
  Point2f Get2D() {
      uint64_t sampleIndex = GetSampleIndex();
      dimension += 2;
      uint64_t bits = Hash(dimension, seed);
      uint32_t sampleHash[2] = {uint32_t(bits), uint32_t(bits >> 32)};
      if (randomize == RandomizeStrategy::None)
          return {SobolSample(sampleIndex, 0, NoRandomizer()),
                  SobolSample(sampleIndex, 1, NoRandomizer())};
      else if (randomize == RandomizeStrategy::PermuteDigits)
          return {SobolSample(sampleIndex, 0, BinaryPermuteScrambler(sampleHash[0])),
                  SobolSample(sampleIndex, 1, BinaryPermuteScrambler(sampleHash[1]))};
      else if (randomize == RandomizeStrategy::FastOwen)
          return {SobolSample(sampleIndex, 0, FastOwenScrambler(sampleHash[0])),
                  SobolSample(sampleIndex, 1, FastOwenScrambler(sampleHash[1]))};
      else
          return {SobolSample(sampleIndex, 0, OwenScrambler(sampleHash[0])),
                  SobolSample(sampleIndex, 1, OwenScrambler(sampleHash[1]))};
  }
  ```
]

#parec[
  Point2f GetPixel2D() { return Get2D(); }
][
  ```cpp
  Point2f GetPixel2D() { return Get2D(); }
  ```
]

#parec[
  The `GetSampleIndex()` method is where most of the complexity of this sampler lies.
][
  `GetSampleIndex()` 方法是此采样器大部分复杂性的所在。
]

#parec[
  It computes a random permutation of the digits of `mortonIndex`, including handling the case where the number of samples per pixel is only a power of 2 but not a power of 4; that case needs special treatment since the total number of bits in the index is odd, which means that only one of the two bits needed for the last base-4 digit is available.
][
  它计算 `mortonIndex` 数字的随机排列，包括处理每像素样本数仅为 2 的幂但不是 4 的幂的情况；该情况需要特殊处理，因为索引中的总位数是奇数，这意味着只有一个可用的位用于最后的基数为 4 的数字。
]

#parec[
  uint64\_t GetSampleIndex() const { static const uint8\_t permutations\[24\]\[4\] = {{0, 1, 2, 3}, {0, 1, 3, 2}, {0, 2, 1, 3}, {0, 2, 3, 1}, {0, 3, 2, 1}, {0, 3, 1, 2}, {1, 0, 2, 3}, {1, 0, 3, 2}, {1, 2, 0, 3}, {1, 2, 3, 0}, {1, 3, 2, 0}, {1, 3, 0, 2}, {2, 1, 0, 3}, {2, 1, 3, 0}, {2, 0, 1, 3}, {2, 0, 3, 1}, {2, 3, 0, 1}, {2, 3, 1, 0}, {3, 1, 2, 0}, {3, 1, 0, 2}, {3, 2, 1, 0}, {3, 2, 0, 1}, {3, 0, 2, 1}, {3, 0, 1, 2}}; uint64\_t sampleIndex = 0; bool pow2Samples = log2SamplesPerPixel & 1; int lastDigit = pow2Samples ? 1 : 0; for (int i = nBase4Digits - 1; i \>= lastDigit; –i) { int digitShift = 2 \* i - (pow2Samples ? 1 : 0); int digit = (mortonIndex \>\> digitShift) & 3; uint64\_t higherDigits = mortonIndex \>\> (digitShift + 2); int p = (MixBits(higherDigits ^ (0x55555555u \* dimension)) \>\> 24) % 24; digit = permutations\[p\]\[digit\]; sampleIndex |= uint64\_t(digit) \<\< digitShift; } if (pow2Samples) { int digit = mortonIndex & 1; sampleIndex |= digit ^ (MixBits((mortonIndex \>\> 1) ^ (0x55555555u \* dimension)) & 1); } return sampleIndex; }
][
  ```cpp
  uint64_t GetSampleIndex() const {
      static const uint8_t permutations[24][4] = {
          {0, 1, 2, 3}, {0, 1, 3, 2}, {0, 2, 1, 3}, {0, 2, 3, 1},
          {0, 3, 2, 1}, {0, 3, 1, 2}, {1, 0, 2, 3}, {1, 0, 3, 2}, {1, 2, 0, 3}, {1, 2, 3, 0},
          {1, 3, 2, 0}, {1, 3, 0, 2}, {2, 1, 0, 3}, {2, 1, 3, 0}, {2, 0, 1, 3},
          {2, 0, 3, 1}, {2, 3, 0, 1}, {2, 3, 1, 0}, {3, 1, 2, 0}, {3, 1, 0, 2},
          {3, 2, 1, 0}, {3, 2, 0, 1}, {3, 0, 2, 1}, {3, 0, 1, 2}
      };
      uint64_t sampleIndex = 0;
      bool pow2Samples = log2SamplesPerPixel & 1;
      int lastDigit = pow2Samples ? 1 : 0;
      for (int i = nBase4Digits - 1; i >= lastDigit; --i) {
          int digitShift = 2 * i - (pow2Samples ? 1 : 0);
          int digit = (mortonIndex >> digitShift) & 3;
          uint64_t higherDigits = mortonIndex >> (digitShift + 2);
          int p = (MixBits(higherDigits ^ (0x55555555u * dimension)) >> 24) % 24;
          digit = permutations[p][digit];
          sampleIndex |= uint64_t(digit) << digitShift;
      }
      if (pow2Samples) {
          int digit = mortonIndex & 1;
          sampleIndex |= digit ^ (MixBits((mortonIndex >> 1) ^ (0x55555555u * dimension)) & 1);
      }
      return sampleIndex;
  }
  ```
]

#parec[
  We will find it useful to have all of $4 ! = 24$ permutations of four elements explicitly enumerated; they are stored in the `permutations` array.
][
  我们将发现显式枚举所有 $4 ! = 24$ 个四元素排列是有用的；它们存储在 `permutations` 数组中。
]

#parec[
  static const uint8\_t permutations\[24\]\[4\] = {{0, 1, 2, 3}, {0, 1, 3, 2}, {0, 2, 1, 3}, {0, 2, 3, 1}, {0, 3, 2, 1}, {0, 3, 1, 2}, {1, 0, 2, 3}, {1, 0, 3, 2}, {1, 2, 0, 3}, {1, 2, 3, 0}, {1, 3, 2, 0}, {1, 3, 0, 2}, {2, 1, 0, 3}, {2, 1, 3, 0}, {2, 0, 1, 3}, {2, 0, 3, 1}, {2, 3, 0, 1}, {2, 3, 1, 0}, {3, 1, 2, 0}, {3, 1, 0, 2}, {3, 2, 1, 0}, {3, 2, 0, 1}, {3, 0, 2, 1}, {3, 0, 1, 2}};
][
  ```cpp
  static const uint8_t permutations[24][4] = {
      {0, 1, 2, 3}, {0, 1, 3, 2}, {0, 2, 1, 3}, {0, 2, 3, 1},
      {0, 3, 2, 1}, {0, 3, 1, 2}, {1, 0, 2, 3}, {1, 0, 3, 2},
      {1, 2, 0, 3}, {1, 2, 3, 0}, {1, 3, 2, 0}, {1, 3, 0, 2},
      {2, 1, 0, 3}, {2, 1, 3, 0}, {2, 0, 1, 3}, {2, 0, 3, 1},
      {2, 3, 0, 1}, {2, 3, 1, 0}, {3, 1, 2, 0}, {3, 1, 0, 2},
      {3, 2, 1, 0}, {3, 2, 0, 1}, {3, 0, 2, 1}, {3, 0, 1, 2}
  };
  ```
]

#parec[
  The digits are randomized from most significant to least significant.
][
  数字从最高有效位到最低有效位随机化。
]

#parec[
  In the case of the number of samples only being a power of 2, the loop terminates before the last bit, which is handled specially since it is not a full base-4 digit.
][
  在样本数仅为 2 的幂的情况下，循环在最后一位之前终止，该位需要特殊处理，因为它不是完整的基数为 4 的数字。
]

#parec[
  bool pow2Samples = log2SamplesPerPixel & 1; int lastDigit = pow2Samples ? 1 : 0; for (int i = nBase4Digits - 1; i \>= lastDigit; –i) { int digitShift = 2 \* i - (pow2Samples ? 1 : 0); int digit = (mortonIndex \>\> digitShift) & 3; uint64\_t higherDigits = mortonIndex \>\> (digitShift + 2); int p = (MixBits(higherDigits ^ (0x55555555u \* dimension)) \>\> 24) % 24; digit = permutations\[p\]\[digit\]; sampleIndex |= uint64\_t(digit) \<\< digitShift; }
][
  ```cpp
  bool pow2Samples = log2SamplesPerPixel & 1;
  int lastDigit = pow2Samples ? 1 : 0;
  for (int i = nBase4Digits - 1; i >= lastDigit; --i) {
      int digitShift = 2 * i - (pow2Samples ? 1 : 0);
      int digit = (mortonIndex >> digitShift) & 3;
      uint64_t higherDigits = mortonIndex >> (digitShift + 2);
      int p = (MixBits(higherDigits ^ (0x55555555u * dimension)) >> 24) % 24;
      digit = permutations[p][digit];
      sampleIndex |= uint64_t(digit) << digitShift;
  }
  ```
]

#parec[
  After the current digit is extracted from `mortonIndex`, it is permuted using the selected permutation before being shifted back into place to be added to `sampleIndex`.
][
  从 `mortonIndex` 中提取当前数字后，它使用选定的排列进行排列，然后移回原位以添加到 `sampleIndex` 中。
]

#parec[
  int digitShift = 2 \* i - (pow2Samples ? 1 : 0); int digit = (mortonIndex \>\> digitShift) & 3; uint64\_t higherDigits = mortonIndex \>\> (digitShift + 2); int p = (MixBits(higherDigits ^ (0x55555555u \* dimension)) \>\> 24) % 24; digit = permutations\[p\]\[digit\]; sampleIndex |= uint64\_t(digit) \<\< digitShift;
][
  ```cpp
  int digitShift = 2 * i - (pow2Samples ? 1 : 0);
  int digit = (mortonIndex >> digitShift) & 3;
  uint64_t higherDigits = mortonIndex >> (digitShift + 2);
  int p = (MixBits(higherDigits ^ (0x55555555u * dimension)) >> 24) % 24;
  digit = permutations[p][digit];
  sampleIndex |= uint64_t(digit) << digitShift;
  ```
]

#parec[
  Which permutation to use is determined by hashing both the higher-order digits and the current sample dimension.
][
  使用哪个排列由哈希高阶数字和当前样本维度决定。
]

#parec[
  In this way, the index is hashed differently for different dimensions, which randomizes the association of samples in different dimensions for padding.
][
  通过这种方式，索引在不同维度上以不同方式哈希，从而随机化在不同维度上填充样本的关联。
]

#parec[
  The use of the higher-order digits in this way means that this approach bears some resemblance to Owen scrambling, though here it is applied to sample indices rather than sample values.
][
  以这种方式使用高阶数字意味着这种方法在某种程度上类似于 Owen 扰动，尽管这里它应用于样本索引而不是样本值。
]

#parec[
  The result is a top-down hierarchical randomization of the Morton curve.
][
  结果是 Morton 曲线的自上而下的层次随机化。
]

#parec[
  In the case of a power-of-2 sample count, the single remaining bit in `mortonIndex` is handled specially, though following the same approach as the other digits: the higher-order bits and dimension are hashed to choose a permutation.
][
  在样本数为 2 的幂的情况下，`mortonIndex` 中剩余的单个位需要特殊处理，尽管遵循与其他数字相同的方法：哈希高阶位和维度以选择排列。
]

#parec[
  In this case, there are only two possible permutations, and as with the `BinaryPermuteScrambler`, an exclusive or is sufficient to apply whichever of them was selected.
][
  在这种情况下，只有两种可能的排列，与 `BinaryPermuteScrambler` 类似，异或运算足以应用所选的排列。
]


#parec[
  In this section we have defined three `Sampler`s, each of which supports four randomization algorithms, giving a total of 12 different ways of generating samples. All are effective samplers, though their characteristics vary. In the interest of space, we will not include evaluations of every one of them here but will focus on the most significant differences among them.
][
  在本节中，我们定义了三个`采样器`，每个采样器支持四种随机算法，总共提供了12种不同的采样生成方式。所有这些都是有效的采样器，尽管它们的特性各不相同。由于篇幅限制，我们在此不对每一种进行评估，而是专注于它们之间最显著的差异。
]

#parec[
  Figure 8.43(a) shows the PSD of the unscrambled 2D Sobol' point set; it is an especially bad power spectrum. Like the Halton points, the 2D Sobol' points have low energy along the two axes thanks to well-distributed 1D projections, but there is significant structured variation at higher off-axis frequencies, including regions with very high PSD values.
][
  图8.43(a)显示了未扰乱的2D Sobol'点集的PSD；它是一个特别差的功率谱。与Halton点类似，2D Sobol'点由于良好的1D投影在两个轴上具有低能量，但在更高的非轴频率上存在显著的结构化变化，包括具有非常高PSD值的区域。
]

#parec[
  As seen in Figure 8.43(b), randomizing the Sobol' points with random digit permutations only slightly improves the power spectrum. Only with the Owen scrambling algorithms does the power spectrum start to become uniform at higher frequencies, though some structure still remains (Figures 8.43(c) and (d)).
][
  如图8.43(b)所示，使用随机数字置换对Sobol'点进行随机化仅略微改善了功率谱。只有使用Owen扰乱算法，功率谱才开始在更高频率上变得均匀，尽管仍然存在一些结构（图8.43(c)和(d)）。
]

#parec[
  These well-distributed 1D projections are one reason why low-discrepancy sequences are generally more effective than stratified patterns: they are more robust with respect to preserving their good distribution properties after being transformed to other domains.
][
  这些良好分布的1D投影是低差序列通常比分层样式更有效的原因之一：它们在转换到其他域后更能保持其良好的分布特性。
]

#parec[
  Figure 8.44 shows what happens when a set of 16 sample points are transformed to be points on a skinny quadrilateral by scaling them to cover its surface; samples from the Sobol' sequence remain well distributed, but samples from a stratified pattern fare worse.
][
  图8.44展示了当一组16个采样点被转换为瘦长四边形上的点时会发生什么；通过缩放它们以覆盖其表面，来自Sobol'序列的样本仍然分布良好，而来自分层样式的样本效果较差。
]

#parec[
  Returning to the simple scene with defocus blur that was used in Figure 8.23, Figure 8.45 compares using the Halton sampler to the three Sobol' samplers for rendering that scene.
][
  回到图8.23中使用的具有焦外模糊的简单场景，图8.45比较了使用Halton采样器与三个Sobol'采样器渲染该场景。
]

#parec[
  We can see that the Halton sampler has higher error than the `StratifiedSampler`, which is due to its 2D projections (as are used for sampling the lens) not necessarily being well distributed.
][
  我们可以看到，Halton采样器的误差高于`StratifiedSampler`，这是因为其2D投影（用于采样镜头）不一定分布良好。
]

#parec[
  The `PaddedSobolSampler` gives little benefit over the stratified sampler, since for sampling a lens, the $4 times 4$ stratification is the most important one and both fulfill that.
][
  `PaddedSobolSampler`对分层采样器的好处不大，因为对于镜头采样， $4 times 4$ 的分层是最重要的，两者都满足这一点。
]

#parec[
  The `SobolSampler` has remarkably low error, even though the rendered image shows the characteristic structure of 2D projections of the Sobol' sequence.
][
  `SobolSampler`具有显著低的误差，即使渲染的图像显示了Sobol'序列的2D投影的特征结构。
]

#parec[
  The `ZSobolSampler` combines reasonably low error with the visual benefit of distributing its error with blue noise.
][
  `ZSobolSampler`结合了合理低的误差和通过蓝噪声分布其误差的视觉优势。
]

#parec[
  Figure 8.46 shows error when integrating simple 2D functions with Sobol' samples. (a) Sobol' sampling exhibits lower error and a faster asymptotic rate of convergence than independent sampling does.
][
  图8.46显示了使用Sobol'样本积分简单2D函数时的误差。(a) Sobol'采样表现出比独立采样更低的误差和更快的渐近收敛率。
]

#parec[
  For a smooth function like the Gaussian, Owen scrambling the sample points gives an even better rate of convergence, especially at power-of-two numbers of sample points.
][
  对于像高斯这样的平滑函数，Owen扰乱样本点提供了更好的收敛速度，特别是在样本点数量为2的幂时。
]

#parec[
  #block[
    #set enum(numbering: "(a)", start: 2)
    + Using Sobol' points is also effective for the rotated checkerboard
      function. Owen scrambling gives a further benefit, though without the
      substantial improvement in rate of convergence that was seen with the
      Gaussian.
  ]
][
  #block[
    #set enum(numbering: "(a)", start: 2)
    + 使用Sobol'点对旋转棋盘函数也有效。Owen扰乱提供了进一步的好处，尽管没有高斯中看到的收敛速度显著改善。
  ]
]

#parec[
  Figure 8.47 shows a log–log plot of MSE when rendering the scene in Figure 8.32 with low-discrepancy samplers. For this scene, both the Halton and Sobol' samplers are similarly effective.
][
  图8.47显示了使用低差序列采样器渲染图8.32中的场景时的MSE对数-对数图。对于这个场景，Halton和Sobol'采样器都同样有效。
]

