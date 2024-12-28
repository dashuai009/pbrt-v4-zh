#import "../template.typ": parec, ez_caption

== Managing Rounding Error
<managing-rounding-error>

#parec[
  Thus far, we have been discussing ray-shape intersection algorithms with respect to idealized arithmetic operations based on the real numbers. This approach has gotten us far, although the fact that computers can only represent finite quantities and therefore cannot actually represent all the real numbers is important. In place of real numbers, computers use floating-point numbers, which have fixed storage requirements. However, error may be introduced each time a floating-point operation is performed, since the result may not be representable in the designated amount of memory.
][
  到目前为止，我们一直在讨论基于理想化算术运算的光线与形状相交算法。 这种方法已经帮助我们取得了很大的进展，尽管计算机只能表示有限的数量，因此无法实际表示所有实数这一事实很重要。 取而代之的是，计算机使用浮点数，这些数具有固定的存储要求。 然而，每次执行浮点运算时都可能引入误差，因为结果可能无法在指定的内存量中表示。
]

#parec[
  The accumulation of this error has several implications for the accuracy of intersection tests. First, it is possible that it will cause valid intersections to be missed completely—for example, if a computed intersection's $t$ value is negative even though the precise value is positive. Furthermore, computed ray-shape intersection points may be above or below the actual surface of the shape. This leads to a problem: when new rays are traced starting from computed intersection points for shadow rays and reflection rays, if the ray origin is below the actual surface, we may find an incorrect reintersection with the surface. Conversely, if the origin is too far above the surface, shadows and reflections may appear detached.(See Figure 6.38.)
][
  这种误差的积累会对相交测试的准确性产生多方面的影响。 首先，它可能导致有效的相交完全被忽略——例如，如果计算出的相交的 $t$ 值为负，即使精确值为正。 此外，计算出的光线与形状的相交点可能在形状的实际表面之上或之下。 这导致一个问题：当从计算出的相交点开始追踪新的光线用于阴影光线和反射光线时，如果光线起点在实际表面之下，我们可能会发现与表面的错误再相交。 相反，如果起点太高于表面，阴影和反射可能会显得分离。（见图6.38。）
]


#parec[
  Typical practice to address this issue in ray tracing is to offset spawned rays by a fixed "ray epsilon" value, ignoring any intersections along the ray $upright(p) + t upright(bold(d))$ closer than some $t_(m i n)$ value.
][
  在光线追踪中解决此问题的典型做法是通过固定的“光线偏移量”值偏移生成的光线，忽略沿光线 $upright(p) + t upright(bold(d))$ 比某个 $t_(m i n)$ 值更近的任何相交。
]

#parec[
  Figure 6.39 shows why this approach requires fairly high $t_(m i n)$ values to work effectively: if the spawned ray is oblique to the surface, incorrect ray intersections may occur quite some distance from the ray origin.
][
  图6.39显示了为什么这种方法需要相当高的 $t_(m i n) $ 值才能有效：如果生成的光线与表面成斜角，错误的光线相交可能会发生在离光线起点相当远的地方。
]

#parec[
  Unfortunately, large $t_(m i n)$ values cause ray origins to be relatively far from the original intersection points, which in turn can cause valid nearby intersections to be missed, leading to loss of fine detail in shadows and reflections.
][
  不幸的是，较大的 $t_(m i n) $ 值会导致光线起点离原始相交点较远，这反过来可能导致有效的附近相交被忽略，从而导致阴影和反射中细节的丢失。
]

#parec[
  In this section, we will introduce the ideas underlying floating-point arithmetic and describe techniques for analyzing the error in floating-point computations.
][
  在本节中，我们将介绍浮点算术的基本思想，并描述分析浮点计算误差的技术。
]

#parec[
  We will then apply these methods to the ray-shape algorithms introduced earlier in this chapter and show how to compute ray intersection points with bounded error. This will allow us to conservatively position ray origins so that incorrect self-intersections are never found, while keeping ray origins extremely close to the actual intersection point so that incorrect misses are minimized. In turn, no additional "ray epsilon" values are needed.
][
  然后，我们将把这些方法应用于本章前面介绍的光线与形状算法，并展示如何计算具有边界误差的光线相交点。 这将允许我们保守地定位光线起点，以便永远不会发现错误的自相交，同时保持光线起点非常接近实际相交点，以便尽量减少错误的遗漏。 这反过来意味着不需要额外的“光线偏移量”。
]

=== Floating-Point Arithmetic
<floating-point-arithmetic>

#parec[
  Computation must be performed on a finite representation of numbers that fits in a finite amount of memory; the infinite set of real numbers cannot be represented on a computer.
][
  计算必须在有限的数字表示上进行，这些数字适合有限的内存量；计算机上无法表示无限的实数集。
]

#parec[
  One such finite representation is fixed point, where given a 16-bit integer, for example, one might map it to positive real numbers by dividing by 256.
][
  固定点就是这样一种有限表示，例如，给定一个16位整数，可以通过除以256将其映射到正实数。
]

#parec[
  This would allow us to represent the range $[0 , 65535 / 256] = [0 , 255 + 255 / 256]$ with equal spacing of $1 / 256$ between values.
][
  这将允许我们表示范围 $[0 , 65535 / 256] = [0 , 255 + 255 / 256] $，值之间的间距为 $1 / 256 $。
]

#parec[
  Fixed-point numbers can be implemented efficiently using integer arithmetic operations (a property that made them popular on early PCs that did not support floating-point computation), but they suffer from a number of shortcomings; among them, the maximum number they can represent is limited, and they are not able to accurately represent very small numbers near zero.
][
  固定点数可以通过整数算术运算高效实现（这一特性使其在不支持浮点计算的早期PC上很受欢迎），但它们有许多缺点；其中，它们可以表示的最大数有限，无法准确表示接近零的非常小的数。
]

#parec[
  An alternative representation for real numbers on computers is floating-point numbers.
][
  计算机上实数的另一种表示是浮点数。
]

#parec[
  These are based on representing numbers with a sign, a significand, and an exponent: essentially, the same representation as scientific notation but with a fixed number of digits devoted to significand and exponent.
][
  这些数基于用符号、有效数和指数表示数字：本质上与科学记数法相同的表示，但有效数和指数的位数是固定的。
]

#parec[
  (In the following, we will assume base-2 digits exclusively.)
][
  （在下文中，我们将仅假设基数为2的数字。）
]

#parec[
  This representation makes it possible to represent and perform computations on numbers with a wide range of magnitudes while using a fixed amount of storage.
][
  这种表示允许在固定存储量下表示和计算范围广泛的数字。
]

#parec[
  Programmers using floating-point arithmetic are generally aware that floating-point values may be inaccurate; this understanding sometimes leads to a belief that floating-point arithmetic is unpredictable.
][
  使用浮点算术的程序员通常意识到浮点值可能不准确；这种理解有时导致认为浮点算术是不可预测的。
]

#parec[
  In this section we will see that floating-point arithmetic has a carefully designed foundation that in turn makes it possible to compute conservative bounds on the error introduced in a particular computation.
][
  在本节中，我们将看到浮点算术有一个精心设计的基础，这反过来使得能够计算特定计算中引入的误差的保守界限。
]

#parec[
  For ray-tracing calculations, this error is often surprisingly small.
][
  对于光线追踪计算，这种误差通常出乎意料地小。
]

#parec[
  Modern CPUs and GPUs nearly ubiquitously implement a model of floating-point arithmetic based on a standard promulgated by the Institute of Electrical and Electronics Engineers (1985, 2008).
][
  现代CPU和GPU几乎普遍实现了一种基于电气和电子工程师学会（1985年，2008年）发布的标准的浮点算术模型。
]

#parec[
  (Henceforth when we refer to floats, we will specifically be referring to 32-bit floating-point numbers as specified by IEEE 754.)
][
  （此后，当我们提到浮点数时，我们将特别指IEEE 754指定的32位浮点数。）
]

#parec[
  The IEEE 754 technical standard specifies the format of floating-point numbers in memory as well as specific rules for precision and rounding of floating-point computations; it is these rules that make it possible to reason rigorously about the error present in a computed floating-point value.
][
  IEEE 754技术标准规定了内存中浮点数的格式以及浮点计算的精度和舍入的具体规则；正是这些规则使得可以严格推理计算出的浮点值中存在的误差。
]

#parec[
  The IEEE standard specifies that 32-bit floats are represented with a sign bit, 8 bits for the exponent, and 23 bits for the significand.
][
  IEEE标准规定32位浮点数由一个符号位、8位指数和23位有效数组成。
]

#parec[
  The exponent stored in a float ranges from 0 to 255.
][
  存储在浮点数中的指数范围从0到255。
]

#parec[
  We will denote it by $e_b$, with the subscript indicating that it is biased; the actual exponent used in computation, $e$, is computed as
][
  我们将其表示为 $e_b $，下标表示它是有偏的；用于计算的实际指数 $e $ 计算为
]


$ e = e_b - 127 $ <float-exponent-bias>
#parec[
  The significand actually has $24$ bits of precision when a normalized floating-point value is stored. When a number expressed with significand and exponent is normalized, there are no leading 0s in the significand. In binary, this means that the leading digit of the significand must be one; in turn, there is no need to store this value explicitly. Thus, the implicit leading 1 digit with the 23 digits encoding the fractional part of the significand gives a total of 24 bits of precision.
][
  当存储一个标准化浮点值时，尾数实际上具有 $24$ 位的精度。当用尾数和指数表示的数字被标准化时，尾数中没有前导0。在二进制中，这意味着尾数的前导数字必须为1；因此，无需显式存储该值。因此，隐式的前导1位与编码尾数小数部分的23位一起提供了总共24位的精度。
]

#parec[
  Given a sign $s = plus.minus 1$, significand $m$, and biased exponent $e_b$, the corresponding floating-point value is
][
  给定符号 $s = plus.minus 1$，尾数 $m$，和偏置指数 $e_b$，相应的浮点值为
]


$ s dot.op m dot.op 2^(e_b - 127) $


#parec[
  For example, with a normalized significand, the floating-point number $6.5$ is written as $1.101_2 times 2^2 $, where the subscript $2$ denotes a base-2 value. (If non-whole binary numbers are not immediately intuitive, note that the first number to the right of the radix point contributes $2^(- 1) = 1 / 2$, and so forth.) Thus, we have
][
  例如，对于一个标准化的尾数，浮点数 $6.5$ 写作 $1.101_2 times 2^2 $，其中下标 $2$ 表示二进制值。（如果非整数二进制数不太直观，请注意，小数点右边的第一个数字贡献 $2^(- 1) = 1 / 2$，依此类推。）因此，我们有
]

$ (1 dot.op 2^0 + 1 dot.op 2^(- 1) + 0 dot.op 2^(- 2) + 1 dot.op 2^(- 3)) times 2^2 = 1.625 times 2^2 = 6.5 $

#parec[
  $ e = 2 $, so $ e_b = 129 = 10000001_2 $ and $ m = 10100000000000000000000_2 $.
][
  $ e = 2 $，所以 $ e_b = 129 = 10000001_2 $ 和 $ m = 10100000000000000000000_2 $。
]

#parec[
  Floats are laid out in memory with the sign bit at the most significant bit of the 32-bit value (with negative signs encoded with a 1 bit), then the exponent, and the significand. Thus, for the value 6.5 the binary in-memory representation of the value is
][
  浮点数在内存中的布局是符号位在32位值的最高有效位（负号用1位编码），然后是指数和尾数。因此，对于值6.5，该值的二进制内存表示为
]


$ 0 med 10000001 med 10100000000000000000000 = 40 med d med 00000_16 $


#parec[
  Similarly, the floating-point value $1.0$ has $m = 0 dots.h 0_2 $ and $e = 0 $, so $e_b = 127 = 01111111_2 $ and its binary representation is:
][
  类似地，浮点值 $1.0$ 有 $m = 0 dots.h 0_2 $ 和 $e = 0 $，所以 $e_b = 127 = 01111111_2 $，其二进制表示为：
]

$ 0 med 01111111 med 00000000000000000000000 = 3 med f med 800000_16 $

#parec[
  This hexadecimal number is a value worth remembering, as it often comes up in memory dumps when debugging graphics programs.
][
  这个十六进制数是一个值得记住的值，因为在调试图形程序时，它经常出现在内存转储中。
]

#parec[
  An implication of this representation is that the spacing between representable floats between two adjacent powers of two is uniform throughout the range. (It corresponds to increments of the significand bits by one.) In a range $\[ 2^e , 2^(e + 1) \) $, the spacing is
][
  这种表示的一个含义是，在两个相邻的二的幂之间的可表示浮点数之间的间隔在整个范围内是均匀的。（它对应于尾数位的增量为1。）在范围 $\[ 2^e , 2^(e + 1) \) $ 中，间隔为
]

$ 2^(e - 23) $

#parec[
  Thus, for floating-point numbers between $1$ and $2$, $e = 0 $, and the spacing between floating-point values is $2^(- 23) approx 1.19209 dots.h times 10^(- 7) $. This spacing is also referred to as the magnitude of a unit in last place ("ulp"); note that the magnitude of an ulp is determined by the floating-point value that it is with respect to—ulps are relatively larger at numbers with larger magnitudes than they are at numbers with smaller magnitudes.
][
  因此，对于介于 $1$ 和 $2$ 之间的浮点数， $e = 0$，浮点值之间的间隔为 $2^(- 23) approx 1.19209 dots.h times 10^(- 7) $。这种间隔也被称为最低有效位单位（"ulp"）的大小；请注意，ulp的大小是由它所对应的浮点值决定的——在较大幅度的数字中，ulp相对较大，而在较小幅度的数字中，ulp相对较小。
]

#parec[
  As we have described the representation so far, it is impossible to exactly represent zero as a floating-point number. This is obviously an unacceptable state of affairs, so the minimum exponent $ e_b = 0 $, or $ e = - 127 $, is set aside for special treatment. With this exponent, the floating-point value is interpreted as not having the implicit leading 1 bit in the significand, which means that a significand of all 0 bits results in
][
  正如我们迄今描述的表示那样，作为浮点数，零是不可能被精确表示的。这显然是一个不可接受的状态，因此最小指数 $e_b = 0 $，或 $e = - 127 $，被保留用于特殊处理。对于这个指数，浮点值被解释为尾数中没有隐式的前导1位，这意味着全为0位的尾数结果为
]

$ s dot.op 0.0 dots.h 0_2 dot.op 2^(- 127) = 0 $


#parec[
  Eliminating the leading 1 significand bit also makes it possible to represent denormalized numbers: if the leading 1 was always present, then the smallest 32-bit float would be
][
  消除前导1尾数位也使得表示次正规化数成为可能：如果前导1始终存在，那么最小的32位浮点数将是
]

$ 1.0 dots.h 0_2 dot.op 2^(- 127) approx 5.8774718 times 10^(- 39) $
#parec[
  Without the leading 1 bit, the minimum value is
][
  没有前导1位，最小值为
]

$ 0.00 dots.h 1_2 dot.op 2^(- 126) = 2^(- 23) dot.op 2^(- 126) approx 1.4012985 times 10^(- 45) $

#parec[
  (The $- 126$ exponent is used because denormalized numbers are encoded with $e_b = 0$ but are interpreted as if $e_b = 1$ so that there is no excess gap between them and the adjacent smallest regular floating-point number.) Providing some capability to represent these small values can make it possible to avoid needing to round very small values to zero.
][
  （使用 $- 126$ 指数是因为次正规化数用 $e_b = 0$ 编码，但被解释为 $e_b = 1$，以便它们与相邻的最小常规浮点数之间没有过大间隙。）提供一些表示这些小值的能力可以避免需要将非常小的值舍入至零。
]

#parec[
  Note that there is both a "positive" and "negative" zero value with this representation. This detail is mostly transparent to the programmer. For example, the standard guarantees that the comparison $-0.0 == 0.0$ evaluates to true, even though the in-memory representations of these two values are different. Conveniently, a floating-point zero value with an unset sign bit is represented by the value 0 in memory.
][
  请注意，这种表示有一个“正”零和“负”零值。这个细节对程序员来说大多是透明的。例如，标准保证比较 $-0.0 == 0.0$ 计算结果为真，尽管这两个值的内存表示不同。方便的是，符号位未置位的浮点零值在内存中表示为值0。
]

#parec[
  With $e_b = 255$, if the significand bits are all 0, the value corresponds to positive or negative infinity, according to the sign bit. Infinite values result when performing computations like $1 \/ 0$ in floating point, for example. Arithmetic operations with infinity and a non-infinite value usually result in infinity, though dividing a finite value by infinity gives 0. For comparisons, positive infinity is larger than any non-infinite value and similarly for negative infinity.
][
  当 $e_b = 255$ 时，如果尾数位全为0，则根据符号位，该值对应于正无穷或负无穷。在浮点计算中，例如执行 $1 \/ 0$ 时会导致无穷大值。无穷大与有限值的算术运算通常结果为无穷大，尽管有限值除以无穷大得到0。在比较中，正无穷大大于任何非无穷大值，负无穷大也是如此。 // 最大指数$e_b = 255$也被保留用于特殊处理。因此，可以表示的最大常规浮点值具有$e_b = 254 $（或$e = 127 $），大约为
]


$ 3.402823 dots.h times 10^38 $



#parec[
  The `Infinity` constant is initialized to be the "infinity" floating-point value. We make it available in a separate constant so that code that uses its value does not need to use the wordy C++ standard library call.
][
  `Infinity` 常量被初始化为“无穷大”浮点值。我们将其作为一个单独的常量提供，以便使用其值的代码不需要使用冗长的 C++ 标准库调用。
]


```cpp
static constexpr Float Infinity = std::numeric_limits<Float>::infinity();
```

#parec[
  With $e_b = 255$, nonzero significand bits correspond to special "not a number" (NaN) values, which result from invalid operations like taking the square root of a negative number or trying to compute $0 \/ 0$. NaNs propagate through computations: any arithmetic operation where one of the operands is a NaN itself always returns NaN. Thus, if a NaN emerges from a long chain of computations, we know that something went awry somewhere along the way. In debug builds, `pbrt` has many assertion statements that check for NaN values, as we almost never expect them to come up in the regular course of events. Any comparison with a NaN value returns false; thus, checking for $! (x = = x)$ serves to check if a value is not a number.
][
  当 $e_b = 255$ 时，非零尾数位对应于特殊的“非数字”（NaN）值，这些值是由于无效操作（如对负数取平方根或尝试计算 $0 \/ 0$ ）产生的。NaN 在计算中传播：任何一个操作数为 NaN 的算术运算结果总是 NaN。因此，如果 NaN 出现在一长串计算中，我们知道某处出了问题。在调试版本中，`pbrt` 有许多用于检查代码正确性的断言语句检查 NaN 值，因为我们几乎不期望它们在正常事件过程中出现。
]

#parec[
  By default, the majority of floating-point computation in `pbrt` uses 32-bit floats. However, as discussed in Section 1.3.3, it is possible to configure it to use 64-bit double-precision values instead. In addition to the sign bit, doubles allocate 11 bits to the exponent and 52 to the significand. `pbrt` also supports 16-bit floats (which are known as halfs) as an in-memory representation for floating-point values stored at pixels in images. Halfs use 5 bits for the exponent and 10 for the significand. (A convenience `Half` class, not discussed further in the text, provides capabilities for working with halfs and converting to and from 32-bit floats.)
][
  默认情况下，`pbrt` 中的大多数浮点计算使用32位浮点数。然而，如第 1.3.3 节所述，可以配置为使用64位双精度值。除了符号位外，双精度分配11位给指数和52位给尾数位。`pbrt` 还支持16位浮点数（称为半精度）作为图像中像素存储的浮点值的内存表示。半精度使用5位作为指数和10位作为尾数位。（一个方便的 `Half` 类，本文不再讨论，提供了处理半精度和与32位浮点数相互转换的功能。）
]

==== Arithmetic Operations

#parec[
  IEEE 754 provides important guarantees about the properties of floating-point arithmetic: specifically, it guarantees that addition, subtraction, multiplication, division, and square root give the same results given the same inputs and that these results are the floating-point number that is closest to the result of the underlying computation if it had been performed in infinite-precision arithmetic. #footnote[IEEE float allows the user to select one of a number of rounding modes, but we will assume the default—round to nearest even—here.]
][
  IEEE 754 提供了关于浮点算术性质的重要保证：具体来说，它保证加法、减法、乘法、除法和平方根在给定相同输入时给出相同结果，并且这些结果是最接近底层计算结果的浮点数，如果该计算是在无限精度算术中执行的。
]

#parec[
  Using circled operators to denote floating-point arithmetic operations and \$ ext{sqrt}\$ for floating-point square root, these accuracy guarantees can be written as:
][
  使用圈运算符表示浮点算术运算，\$ ext{sqrt}\$ 表示浮点平方根，这些精度保证可以写为：
]

$
  a xor b&= "round"(a + b)\
  a - b &= "round"(a - b) \
  a times.circle b&= "round"(a * b)\
  a "oslash" b& = "round"(a \/ b)\
  sqrt(a)& = "round"(sqrt(a))\
  "FMA"(a comma b comma c)& = "round"(a * b + c)
$

#parec[
  where $"round"(x)$ indicates the result of rounding a real number to the closest floating-point value and where $"FMA"$ denotes the fused multiply add operation, which only rounds once. It thus gives better accuracy than computing $(a times.circle b) times.circle c$ \$(a \\circledtimes b) \\circledplus c\$.
][
  其中 $"round"(x)$ 表示将实数舍入到最接近的浮点值的结果， $"FMA"$ 表示融合乘加运算，它只舍入一次。因此，它比计算 \$(a \\circledtimes b) \\circledplus c\$ 提供更好的精度。
]

#parec[
  This bound on the rounding error can also be represented with an interval of real numbers: for example, for addition, we can say that the rounded result is within an interval
][
  这种舍入误差的界限也可以用实数区间表示：例如，对于加法，我们可以说舍入结果在区间内
]

$
  mat(delim: #none,
a xor b, = "round"(a + b) in(a + b)(1 plus.minus epsilon.alt);
, = [(a + b)(1 - epsilon.alt) comma(a + b)(1 + epsilon.alt) ])
$

#parec[
  for some $thin epsilon.alt$. The amount of error introduced from this rounding can be no more than half the floating-point spacing at $a + b$ —if it was more than half the floating-point spacing, then it would be possible to round to a different floating-point number with less error (Figure 6.40).
][
  对于某些 $epsilon.alt$。这种舍入引入的误差不能超过 $a + b$ 处浮点数间距的一半——如果超过一半的浮点数间距，那么可以舍入到另一个浮点数以减少误差（图 6.40）。
]

#parec[
  Figure 6.40: The IEEE standard specifies that floating-point calculations must be implemented as if the calculation was performed with infinite-precision real numbers and then rounded to the nearest representable float. Here, an infinite-precision result in the real numbers is denoted by a filled dot, with the representable floats around it denoted by ticks on a number line. We can see that the error introduced by rounding to the nearest float, $thin delta$, can be no more than half the spacing between floats.
][
  图 6.40: IEEE 标准规定，浮点计算必须实现为如果计算是在无限精度实数中执行的，然后舍入到最近可表示浮点数。在这里，实数中的无限精度结果用实心点表示，周围的可表示浮点数用数轴上的刻度表示。我们可以看到，舍入到最近浮点数引入的误差 $delta$ 不会超过浮点间距的一半。
]

#parec[
  For 32-bit floats, we can bound the floating-point spacing at $a + b$ from above using Equation (6.18) (i.e., an ulp at that value) by $(a + b) 2^(- 23)$, so half the spacing is bounded from above by $(a + b) 2^(- 24)$ and so $lr(|epsilon.alt|) lt.eq 2^(- 24)$. This bound is the machine epsilon.
][
  对于32位浮点数，我们可以使用方程式 (6.18) 从上界约束 $a + b$ 处的浮点数间距（即该值处的 ulp）为 $(a + b) 2^(- 23)$，因此间距的一半从上界约束为 $(a + b) 2^(- 24)$，所以 $lr(|epsilon.alt|) lt.eq 2^(- 24)$。这个界限是机器误差。
]

#parec[
  For 32-bit floats, \$ \_m = 2^{-24} ^{-8}\$.
][
  对于32位浮点数，\$ \_m = 2^{-24} ^{-8}\$。
]

#parec[
  Thus, we have
][
  因此，我们有
]


```cpp
static constexpr Float MachineEpsilon = std::numeric_limits<Float>::epsilon() * 0.5;
```


#parec[
  \$\$ \\begin{array}{c c} a \\oplus b & = \\text{round}( (a + b) ) \\in (a + b)(1 \\pm \\epsilon\_m) \\\\ & = \\left\[ (a + b)(1 - \\epsilon\_m), (a + b)(1 + \\epsilon\_m)\\right\]. \\end{array} \$\$

  Analogous relations hold for the other arithmetic operators and the square root operator.
][
  \$\$ \\begin{array}{c c} a \\oplus b & = \\text{round}( (a + b) ) \\in (a + b)(1 \\pm \\epsilon\_m) \\\\ & = \\left\[ (a + b)(1 - \\epsilon\_m), (a + b)(1 + \\epsilon\_m)\\right\]. \\end{array} \$\$

  类似的关系也适用于其他算术运算符和平方根运算符。
]

#parec[
  A number of useful properties follow directly from Equation~(6.19). For a floating-point number $x$, - $1 dot.circle x = x$. - $x div x = 1$. - $x xor 0 = x$. - $x - x = 0$. - $2 dot.circle x$ and $x div 2$ are exact; no rounding is performed to compute the final result. More generally, any multiplication by or division by a power of two gives an exact result (assuming there is no overflow or underflow). - $x div 2^i = x dot.circle 2^(- i)$ for all integer $i$, assuming $2^i$ does not overflow.
][
  许多有用的性质直接从方程~(6.19)中得出。对于浮点数 $x$， - $1 dot.circle x = x$。 - $x div x = 1$。 - $x xor 0 = x$。 - $x - x = 0$。 - $2 dot.circle x$ 和 $x div 2$ 是精确的；计算最终结果时不进行舍入。更一般地，任何乘以或除以二的幂的运算都给出精确结果（假设没有溢出或下溢）。 \- 对于所有整数 $i$， $x div 2^i = x dot.circle 2^(- i)$，假设 $2^i$ 不会溢出。
]

#parec[
  All of these properties follow from the principle that the result must be the nearest floating-point value to the actual result; when the result can be represented exactly, the exact result must be computed.
][
  所有这些性质都源于结果必须是最接近实际结果的浮点值的原则；当结果可以精确表示时，必须计算出精确结果。
]

#parec[
  A few basic utility routines will be useful in the following. First, we define our own `IsNaN()` function to check for NaN values. It comes with the baggage of a use of C++'s `enable_if` construct to declare its return type in a way that requires that this function only be called with floating-point types.
][
  接下来介绍的几个基本实用工具将会很有用。首先，我们定义自己的 `IsNaN()` 函数来检查 NaN 值。这需要使用 C++ 的 `enable_if` 构造来声明其返回类型，以确保此函数只能与浮点类型一起调用。
]

```cpp
template <typename T> inline
typename std::enable_if_t<std::is_floating_point_v<T>, bool>
IsNaN(T v) {
    return std::isnan(v);
}
```


#parec[
  We also define `IsNaN()` for integer-based types; it trivially returns `false`, since NaN is not representable in those types. One might wonder why we have bothered with `enable_if` and this second definition that tells us something that we already know. One motivation is the templated `Tuple2` and `Tuple3` classes from Section~3.2, which are used with both `Float` and `int` for their element types. Given these two functions, they can freely have assertions that their elements do not store NaN values without worrying about which particular type their elements are.
][
  我们还为基于整数的类型定义了 `IsNaN()`；它简单地返回 `false`，因为 NaN 在这些类型中不可表示。有人可能会想知道为什么我们要使用 `enable_if` 和这个第二个定义来告诉我们我们已经知道的事情。一个动机是来自第~3.2节的模板化的 `Tuple2` 和 `Tuple3` 类，它们用于 `Float` 和 `int` 作为其元素类型。鉴于这两个函数，它们可以自由地断言其元素不存储 NaN 值，而不必担心其元素的特定类型。
]

```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, bool>
IsNaN(T v) { return false; }
```

#parec[
  For similar motivations, we define a pair of `IsInf()` functions that test for infinity.
][
  出于类似的原因，我们定义了一对 `IsInf()` 函数来检测无穷大。
]

```cpp
template <typename T> inline
typename std::enable_if_t<std::is_floating_point_v<T>, bool>
IsInf(T v) {
    return std::isinf(v);
}
```


#parec[
  Once again, because infinity is not representable with integer types, the integer variant of this function returns `false`.
][
  同样，因为无穷大在整数类型中不可表示，此函数的整数变体返回 `false`。
]

```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, bool>
IsInf(T v) { return false; }
```


#parec[
  A pair of `IsFinite()` functions check whether a number is neither infinite or NaN.
][
  一对 `IsFinite()` 函数检查一个数是否既不是无穷大也不是 NaN。
]

```cpp
template <typename T> inline
typename std::enable_if_t<std::is_floating_point_v<T>, bool>
IsFinite(T v) {
    return std::isfinite(v);
}
```


```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, bool>
IsFinite(T v) { return true; }
```

#parec[
  Although fused multiply add is available through the standard library, we also provide our own `FMA()` function.
][
  尽管标准库提供了融合乘加功能，我们仍然提供了自己的 `FMA()` 函数。
]

```cpp
float FMA(float a, float b, float c) { return std::fma(a, b, c); }
```


#parec[
  A separate version for integer types allows calling `FMA()` from code regardless of the numeric type being used.
][
  一个单独的整数类型版本允许无论使用何种数值类型都可以从代码中调用 `FMA()`。
]

```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, T>
FMA(T a, T b, T c) { return a * b + c; }
```


#parec[
  For certain low-level operations, it can be useful to be able to interpret a floating-point value in terms of its constituent bits and to convert the bits representing a floating-point value to an actual `float` or `double`.
][
  在某些低级操作中，能够将浮点值解释为其组成的位，并将这些位转换为实际的 `float` 或 `double` 是很有用的。
]

#parec[
  A natural approach to this would be to take a pointer to a value to be converted and cast it to a pointer to the other type:
][
  一种自然的方法是获取要转换的值的指针并将其转换为另一种类型的指针：
]

```cpp
float f = ...;
uint32_t bits = *((uint32_t *)&f);
```


#parec[
  However, modern versions of C++ specify that it is illegal to cast a pointer of one type, `float`, to a different type, `uint32_t`. (This restriction allows the compiler to optimize more aggressively in its analysis of whether two pointers may point to the same memory location, which can inhibit storing values in registers.)
][
  然而，现代版本的 C++ 规定将一种类型的指针 `float` 转换为另一种类型 `uint32_t` 是非法的。（这种限制允许编译器在分析两个指针是否可能指向同一内存位置时进行更积极的优化，这可能会抑制将值存储在寄存器中。）
]

#parec[
  Another popular alternative, using a `union` with elements of both types, assigning to one type and reading from the other, is also illegal: the C++ standard says that reading an element of a union different from the last one assigned to is undefined behavior.
][
  另一种流行的替代方法是使用包含两种类型元素的 `union`，赋值给一种类型并从另一种类型读取，这也是非法的：C++ 标准表示读取与最后一个赋值不同的 `union` 元素是未定义行为。
]

#parec[
  Fortunately, as of C++20, the standard library provides a `std::bit_cast` function that performs such conversions. Because this version of `pbrt` only requires C++17, we provide an implementation in the `pstd` library that is used by the following conversion functions.
][
  幸运的是，从 C++20 开始，标准库提供了 `std::bit_cast` 函数来进行这种转换。由于此版本的 `pbrt` 仅需要 C++17，我们在 `pstd` 库中提供了一个实现，该实现用于以下转换函数。
]

```cpp
inline uint32_t FloatToBits(float f) {
    return pstd::bit_cast<uint32_t>(f);
}
```

```cpp
inline float BitsToFloat(uint32_t ui) {
    return pstd::bit_cast<float>(ui);
}
```


#parec[
  (Versions of these functions that convert between `double` and `uint64_t` are also available but are similar and are therefore not included here.)
][
  （这些函数的版本用于在 `double` 和 `uint64_t` 之间转换，但由于相似性，因此不在此处包含。）
]

#parec[
  The corresponding integer type with a sufficient number of bits to store `pbrt`'s `Float` type is available through `FloatBits`.
][
  具有足够位数以存储 `pbrt` 的 `Float` 类型的相应整数类型可以通过 `FloatBits` 获得。
]

```cpp
#ifdef PBRT_FLOAT_AS_DOUBLE
using FloatBits = uint64_t;
#else
using FloatBits = uint32_t;
#endif  // PBRT_FLOAT_AS_DOUBLE
```


#parec[
  Given the ability to extract the bits of a floating-point value and given the description of their layout in Section~6.8.1, it is easy to extract various useful quantities from a float.
][
  给定提取浮点值位的能力，并给定第~6.8.1节中描述的其布局，提取浮点数中的各种有用量很容易。
]

```cpp
inline int Exponent(float v) { return (FloatToBits(v) >> 23) - 127; }
```


```cpp
inline int Significand(float v) { return FloatToBits(v) & ((1 << 23) - 1); }
```

#parec[
  ```cpp
  inline uint32_t SignBit(float v) { return FloatToBits(v) & 0x80000000; }
  ```
][
  ```cpp
  inline uint32_t SignBit(float v) { return FloatToBits(v) & 0x80000000; }
  ```
]

#parec[
  These conversions can be used to implement functions that bump a floating-point value up or down to the next greater or next smaller representable floating-point value.
][
  这些转换可以用于实现将浮点值调整到下一个更大或更小的可表示浮点值的函数。
]

#parec[
  They are useful for some conservative rounding operations that we will need in code to follow. Thanks to the specifics of the in-memory representation of floats, these operations are quite efficient.
][
  它们对于我们将在后续代码中需要的一些保守舍入操作很有用。由于浮点数的内存表示的具体细节，这些操作非常高效。
]

```cpp
inline float NextFloatUp(float v) {
    // Handle infinity and negative zero for NextFloatUp()
    if (IsInf(v) && v > 0.f)
           return v;
       if (v == -0.f)
           v = 0.f;
    // Advance v to next higher float
       uint32_t ui = FloatToBits(v);
       if (v >= 0) ++ui;
       else        --ui;
       return BitsToFloat(ui);
}
```


#parec[
  There are two important special cases: first, if `v` is positive infinity, then this function just returns `v` unchanged. Second, negative zero is skipped forward to positive zero before continuing on to the code that advances the significand.
][
  有两个重要的特殊情况：首先，如果 `v` 是正无穷大，则此函数只返回未更改的 `v`。其次，负零在继续前进到增加有效数的代码之前被跳过到正零。
]

#parec[
  This step must be handled explicitly, since the bit patterns for $- 0.0$ and $0.0$ are not adjacent.
][
  必须显式处理此步骤，因为 $- 0.0$ 和 $0.0$ 的位模式不相邻。
]

#parec[
  Conceptually, given a floating-point value, we would like to increase the significand by one, where if the result overflows, the significand is reset to zero and the exponent is increased by one.
][
  从概念上讲，给定一个浮点值，我们希望将有效数增加一，如果结果溢出，则有效数重置为零，指数增加一。
]

#parec[
  Fortuitously, adding one to the in-memory integer representation of a float achieves this: because the exponent lies at the high bits above the significand, adding one to the low bit of the significand will cause a one to be carried all the way up into the exponent if the significand is all ones and otherwise will advance to the next higher significand for the current exponent.
][
  幸运的是，向浮点数的内存整数表示添加一实现了这一点：因为指数位于有效数之上的高位，向有效数的低位添加一将在有效数全为一时将一进位到指数，否则将前进到当前指数的下一个更高有效数。
]

#parec[
  This is yet another example of the careful thought that was applied to the development of the IEEE floating-point specification.
][
  这是 IEEE 浮点规范开发中应用的仔细思考的又一个例子。
]

#parec[
  Note also that when the highest representable finite floating-point value's bit representation is incremented, the bit pattern for positive floating-point infinity is the result.
][
  还要注意，当最高可表示有限浮点值的位表示被递增时，正浮点无穷大的位模式是结果。
]

#parec[
  For negative values, subtracting one from the bit representation similarly advances to the next higher value.
][
  对于负值，从位表示中减去一同样前进到下一个更高值。
]

#parec[
  The `NextFloatDown()` function, not included here, follows the same logic but effectively in reverse. `pbrt` also provides versions of these functions for `double`s.
][
  未包含在此处的 `NextFloatDown()` 函数遵循相同的逻辑，但实际上是反向的。`pbrt` 还为 `double` 提供了这些函数的版本。
]


==== Error Propagation
<error-propagation>
#parec[
  Using the guarantees of IEEE floating-point arithmetic, it is possible to develop methods to analyze and bound the error in a given floating-point computation. For more details on this topic, see the excellent book by Higham (2002), as well as Wilkinson's earlier classic (1994).
][
  利用 IEEE 浮点运算的特性，可以开发方法来分析和界定给定浮点计算中的误差。关于此主题的更多详细信息，请参阅 Higham（2002）的优秀著作以及 Wilkinson（1994）的早期经典著作。
]

#parec[
  Two measurements of error are useful in this effort: absolute and relative. If we perform some floating-point computation and get a rounded result $tilde(a)$, we say that the magnitude of the difference between $tilde(a)$ and the result of doing that computation in the real numbers is the #emph[absolute error];, $delta_a$ :
][
  在此过程中，有两种误差测量是有用的：绝对误差和相对误差。如果我们进行一些浮点计算并得到一个舍入结果 $tilde(a)$，我们称 $tilde(a)$ 与在实数中进行该计算的结果之间差异的大小为#emph[绝对误差];， $delta_a$ ：
]

#parec[
  $ delta_a = lr(|tilde(a) - a|) . $
][
  $ delta_a = lr(|tilde(a) - a|) . $
]

#parec[
  #emph[Relative error];, $delta_r$, is the ratio of the absolute error to the precise result: $ delta_r = lr(|frac(tilde(a) - a, a)|) = lr(|delta_a / a|) , $ as long as $a eq.not 0$. Using the definition of relative error, we can thus write the computed value $tilde(a)$ as a perturbation of the exact result $a$ :
][
  #emph[相对误差];， $delta_r$，是绝对误差与精确结果的比率： $ delta_r = lr(|frac(tilde(a) - a, a)|) = lr(|delta_a / a|) , $ 只要 $a eq.not 0$。利用相对误差的定义，我们可以将计算值 $tilde(a)$ 表示为精确结果 $a$ 的扰动：
]

#parec[
  $ tilde(a) in a plus.minus delta_a = a (1 plus.minus delta_r) . $
][
  $ tilde(a) in a plus.minus delta_a = a (1 plus.minus delta_r) . $
]

#parec[
  As a first application of these ideas, consider computing the sum of four numbers, $a$, $b$, $c$, and $d$, represented as floats. If we compute this sum as `r = (((a + b) + c) + d)`, Equation (6.20) gives us
][
  作为这些概念的首次应用，考虑计算四个数 $a$ 、 $b$ 、 $c$ 和 $d$ 的和，这些数表示为浮点数。如果我们将这个和计算为 `r = (((a + b) + c) + d)`，方程 (6.20) 给出
]

#parec[
  $
    (((a xor b) xor c) xor d) & in & ((((a + b) (1 plus.minus epsilon.alt_m)) + c) (1 plus.minus epsilon.alt_m) + d) (
      1 plus.minus epsilon.alt_m
    )\
    & = & (a + b) (1 plus.minus epsilon.alt_m)^3 + c (1 plus.minus epsilon.alt_m)^2 + d (1 plus.minus epsilon.alt_m) .
  $
][
  $
    (((a xor b) xor c) xor d) & in & ((((a + b) (1 plus.minus epsilon.alt_m)) + c) (1 plus.minus epsilon.alt_m) + d) (
      1 plus.minus epsilon.alt_m
    )\
    & = & (a + b) (1 plus.minus epsilon.alt_m)^3 + c (1 plus.minus epsilon.alt_m)^2 + d (1 plus.minus epsilon.alt_m) .
  $
]

#parec[
  Because $epsilon.alt_m$ is small, higher-order powers of $epsilon.alt_m$ can be bounded by an additional $epsilon.alt_m$ term, and so we can bound the $(1 plus.minus epsilon.alt_m)^n$ terms with
][
  因为 $epsilon.alt_m$ 很小， $epsilon.alt_m$ 的高次幂可以用额外的 $epsilon.alt_m$ 项来界定，因此我们可以界定 $(1 plus.minus epsilon.alt_m)^n$ 项为
]

#parec[
  $ (1 plus.minus epsilon.alt_m)^n lt.eq (1 plus.minus (n + 1) epsilon.alt_m) . $
][
  $ (1 plus.minus epsilon.alt_m)^n lt.eq (1 plus.minus (n + 1) epsilon.alt_m) . $
]

#parec[
  (As a practical matter, $(1 plus.minus n epsilon.alt_m)$ almost bounds these terms, since higher powers of $epsilon.alt_m$ get very small very quickly, but the above is a fully conservative bound.)
][
  （实际上， $(1 plus.minus n epsilon.alt_m)$ 几乎可以界定这些项，因为 $epsilon.alt_m$ 的高次幂会非常快地变得非常小，但上述是一个完全保守的界定。）
]

#parec[
  This bound lets us simplify the result of the addition to:
][
  这个界定让我们可以将加法结果简化为：
]

#parec[
  $
    (a + b) (1 plus.minus 4 epsilon.alt_m) + c (1 plus.minus 3 epsilon.alt_m) + d (1 plus.minus 2 epsilon.alt_m) & = & \
    & & a + b + c + d + [
      plus.minus 4 epsilon.alt_m lr(|a + b|) plus.minus 3 epsilon.alt_m lr(|c|) plus.minus 2 epsilon.alt_m lr(|d|)
    ] .
  $
][
  $
    (a + b) (1 plus.minus 4 epsilon.alt_m) + c (1 plus.minus 3 epsilon.alt_m) + d (1 plus.minus 2 epsilon.alt_m) & = & \
    & & a + b + c + d + [
      plus.minus 4 epsilon.alt_m lr(|a + b|) plus.minus 3 epsilon.alt_m lr(|c|) plus.minus 2 epsilon.alt_m lr(|d|)
    ] .
  $
]

#parec[
  The term in square brackets gives the absolute error: its magnitude is bounded by
][
  方括号中的项给出了绝对误差：其大小被界定为
]

#parec[
  $ 4 epsilon.alt_m lr(|a + b|) + 3 epsilon.alt_m lr(|c|) + 2 epsilon.alt_m lr(|d|) . $
][
  $ 4 epsilon.alt_m lr(|a + b|) + 3 epsilon.alt_m lr(|c|) + 2 epsilon.alt_m lr(|d|) . $
]

#parec[
  Thus, if we add four floating-point numbers together with the above parenthesization, we can be certain that the difference between the final rounded result and the result we would get if we added them with infinite-precision real numbers is bounded by Equation (6.22); this error bound is easily computed given specific values of $a$, $b$, $c$, and $d$.
][
  因此，如果我们以上述括号化方式将四个浮点数相加，我们可以确定最终舍入结果与我们用无限精度实数相加得到的结果之间的差异被方程 (6.22) 界定；给定 $a$ 、 $b$ 、 $c$ 和 $d$ 的具体值，这个误差界定很容易计算。
]

#parec[
  This is a fairly interesting result; we see that the magnitude of $a + b$ makes a relatively large contribution to the error bound, especially compared to $d$. (This result gives a sense for why, if adding a large number of floating-point numbers together, sorting them from small to large magnitudes generally gives a result with a lower final error than an arbitrary ordering.)
][
  这个结果相当有趣；我们看到 $a + b$ 的大小对误差界定的贡献相对较大，尤其是与 $d$ 相比。（这个结果让我们理解为什么在将大量浮点数相加时，将它们按从小到大的顺序排序通常会得到更低的最终误差。）
]

#parec[
  Our analysis here has implicitly assumed that the compiler would generate instructions according to the expression used to define the sum. Compilers are required to follow the form of the given floating-point expressions in order to not break carefully crafted computations that may have been designed to minimize round-off error.
][
  我们的分析在这里隐含地假设编译器会根据用于定义和的表达式生成指令。编译器必须遵循给定浮点表达式的形式，以免破坏可能设计用于最小化舍入误差的精心设计的计算。
]

#parec[
  Here again is a case where certain transformations that would be valid on expressions with integers cannot be safely applied when floats are involved.
][
  这里再次出现了某些在整数表达式上有效的变换在浮点数中不能安全应用的情况。
]

#parec[
  What happens if we change the expression to the algebraically equivalent `float r = (a + b) + (c + d)`? This corresponds to the floating-point computation.
][
  如果我们将表达式更改为代数上等价的 `float r = (a + b) + (c + d)` 会发生什么？这对应于浮点计算。
]


#parec[
  $ ((a xor b) xor (c xor d)) . $
][
  $ ((a xor b) xor (c xor d)) . $
]

#parec[
  If we use the same process of applying Equation~(6.20), expanding out terms, converting higher-order $(1 plus.minus epsilon.alt_m)^n$ terms to $(1 plus.minus (n + 1) epsilon.alt_m)$, we get absolute error bounds of
][
  如果我们使用相同的方法应用方程~(6.20)，展开项并将高阶 $(1 plus.minus epsilon.alt_m)^n$ 项转换为 $(1 plus.minus (n + 1) epsilon.alt_m)$，我们得到绝对误差界限
]


#parec[
  $ a (1 plus.minus gamma_i) ast.circle b (1 plus.minus gamma_j) in a b (1 plus.minus gamma_(i + j + 1)) , $
][
  $ a (1 plus.minus gamma_i) ast.circle b (1 plus.minus gamma_j) in a b (1 plus.minus gamma_(i + j + 1)) , $
]

#parec[
  where we have used the relationship $ (1 plus.minus gamma_i) (1 plus.minus gamma_j) in (1 plus.minus gamma_(i + j)) , $ which follows directly from Equation (6.23).
][
  其中我们使用了关系式 $ (1 plus.minus gamma_i) (1 plus.minus gamma_j) in (1 plus.minus gamma_(i + j)) , $ 这直接来自方程 (6.23)。
]

#parec[
  The relative error in this result is bounded by
][
  此结果的相对误差被限制在
]

#parec[
  $ lr(|frac(a b gamma_(i + j + 1), a b)|) = gamma_(i + j + 1) , $
][
  $ lr(|frac(a b gamma_(i + j + 1), a b)|) = gamma_(i + j + 1) , $
]

#parec[
  and so the final error is no more than roughly $ frac(i + j + 1, 2) $ ulps at the value of the product — about as good as we might hope for, given the error going into the multiplication. (The situation for division is similarly good.)
][
  因此最终误差不超过大约 $ frac(i + j + 1, 2) $ 单位最后一位（ulps）在乘积的值上——考虑到乘法中的误差，这已经是我们可以希望的最好结果了。（除法的情况同样良好。）
]

#parec[
  Unfortunately, with addition and subtraction, it is possible for the relative error to increase substantially.
][
  不幸的是，对于加法和减法，相对误差可能会显著增加。
]

#parec[
  Using the same definitions of the values being operated on, consider
][
  使用相同的被操作值的定义，考虑
]

#parec[
  \$\$ a \\left( 1 \\pm \\gamma\_i \\right) \\circledplus b \\left( 1 \\pm \\gamma\_j \\right), \$\$
][
  \$\$ a \\left( 1 \\pm \\gamma\_i \\right) \\circledplus b \\left( 1 \\pm \\gamma\_j \\right), \$\$
]

#parec[
  which is in the interval $ a (1 plus.minus gamma_(i + 1)) + b (1 plus.minus gamma_(j + 1)) , $ and so the absolute error is bounded by $ lr(|a|) gamma_(i + 1) + lr(|b|) gamma_(j + 1) . $
][
  它在区间 $ a (1 plus.minus gamma_(i + 1)) + b (1 plus.minus gamma_(j + 1)) , $ 因此绝对误差被限制在 $ lr(|a|) gamma_(i + 1) + lr(|b|) gamma_(j + 1) . $
]

#parec[
  If the signs of $ a $ and $ b $ are the same, then the absolute error is bounded by $ lr(|a + b|) gamma_(i + j + 1) $ and the relative error is approximately $ frac(i + j + 1, 2) $ ulps around the computed value.
][
  如果 $ a $ 和 $ b $ 的符号相同，则绝对误差被限制在 $ lr(|a + b|) gamma_(i + j + 1) $，相对误差大约是 $ frac(i + j + 1, 2) $ 单位最后一位（ulps）在计算值周围。
]

#parec[
  However, if the signs of $ a $ and $ b $ differ (or, equivalently, they are the same but subtraction is performed), then the relative error can be quite high.
][
  然而，如果 $ a $ 和 $ b $ 的符号不同（或者等价地，它们相同但进行了减法），则相对误差可能会非常高。
]

#parec[
  Consider the case where $ a approx - b $ : the relative error is
][
  考虑 $ a approx - b $ 的情况：相对误差是
]

#parec[
  $ frac(lr(|a|) gamma_(i + 1) + lr(|b|) gamma_(j + 1), a + b) approx frac(2 lr(|a|) gamma_(i + j + 1), a + b) . $
][
  $ frac(lr(|a|) gamma_(i + 1) + lr(|b|) gamma_(j + 1), a + b) approx frac(2 lr(|a|) gamma_(i + j + 1), a + b) . $
]

#parec[
  The numerator's magnitude is proportional to the original value $ lr(|a|) $ yet is divided by a very small number, and thus the relative error is quite high.
][
  分子的大小与原始值 $ lr(|a|) $ 成比例，但被一个非常小的数除，因此相对误差非常高。
]

#parec[
  This substantial increase in relative error is called #emph[catastrophic
cancellation];.
][
  这种相对误差的显著增加被称为#emph[灾难性抵消];。
]

#parec[
  Equivalently, we can have a sense of the issue from the fact that the absolute error is in terms of the magnitude of $ lr(|a|) $, though it is in relation to a value much smaller than $ a $.
][
  同样，我们可以从绝对误差是以 $ lr(|a|) $ 的大小为单位的这一事实中感受到问题，尽管它是相对于一个比 $ a $ 小得多的值。
]

#parec[
  In addition to working out error bounds algebraically, we can also have the computer do this work for us as some computation is being performed.
][
  除了代数地计算误差界限外，我们还可以让计算机在进行某些计算时为我们完成这项工作。
]

#parec[
  This approach is known as #emph[running error analysis];.
][
  这种方法被称为#emph[运行误差分析];。
]

#parec[
  The idea behind it is simple: each time a floating-point operation is performed, we compute intervals based on Equation (6.20) that bound its true value.
][
  其背后的想法很简单：每次执行浮点运算时，我们根据方程 (6.20) 计算区间以限制其真实值。
]

#parec[
  The Interval class, which is defined in Section B.2.15, provides this functionality.
][
  Interval 类在第 B.2.15 节中定义，提供了此功能。
]

#parec[
  The Interval class also tracks rounding errors in floating-point arithmetic and is useful even if none of the initial values are intervals. While computing error bounds in this way has higher runtime overhead than using derived expressions that give an error bound directly, it can be convenient when derivations become unwieldy.
][
  Interval 类还跟踪浮点算术中的舍入误差，即使初始值都不是区间时也很有用。 以这种方式计算误差界限的运行时开销比直接使用给出误差界限的推导表达式要高，但当推导变得难以处理时，它可能很方便。
]


=== Conservative Ray–Bounds Intersections
#parec[
  Floating-point round-off error can cause the ray-bounding box intersection test to miss cases where a ray actually does intersect the box. While it is acceptable to have occasional false positives from ray-box intersection tests, we would like to never miss an intersection — getting this right is important for the correctness of the BVHAggregate acceleration data structure in Section 7.3 so that valid ray-shape intersections are not missed. The ray-bounding box test introduced in Section 6.1.2 is based on computing a series of ray-slab intersections to find the parametric $t_(upright("min"))$ along the ray where the ray enters the bounding box and the $t_(upright("max"))$ where it exits. If $t_(upright("min")) < t_(upright("max"))$, the ray passes through the box; otherwise, it misses it. With floating-point arithmetic, there may be error in the computed $t$ values — if the computed $t_(upright("min"))$ value is greater than $t_(upright("max"))$ purely due to round-off error, the intersection test will incorrectly return a false result.
][
  浮点舍入误差可能导致射线-边界框相交测试错过射线实际与框相交的情况。 虽然射线-框相交测试偶尔出现误报是可以接受的，但我们希望永远不要错过相交——正确处理这一点对于第 BVHAggregate 加速数据结构在第 7.3 节中的正确性非常重要，以免错过有效的射线-形状相交。 第 6.1.2 节中介绍的射线-边界框测试基于计算一系列射线-平面相交以找到射线进入边界框的参数 $t_(upright("min"))$ 和射线退出的 $t_(upright("max"))$。 如果 $t_(upright("min")) < t_(upright("max"))$，则射线穿过框；否则，它错过了它。 使用浮点算术，计算的 $t$ 值可能存在误差——如果计算的 $t_(upright("min"))$ 值仅由于舍入误差而大于 $t_(upright("max"))$，则相交测试将错误地返回错误结果。
]

#parec[
  Recall that the computation to find the $t$ value for a ray intersection with a plane perpendicular to the $x$ axis at a point $x $ is $t = frac(x - o_x, d_x)$. Expressed as a floating-point computation and applying Equation (6.19), we have
][
  回想一下，计算射线与垂直于 $x$ 轴的平面在点 $x$ 处相交的 $t$ 值的计算是 $t = frac(x - o_x, d_x)$。 表示为浮点计算并应用方程 (6.19)，我们有
]

$ t = (x - o_x) ast.circle (1 div d_x) in frac(x - o_x, d_x) (1 plus.minus epsilon.alt)^3 , $

#parec[
  and so
][
  因此
]


$ frac(x - o_x, upright(bold(d))_x) in t (1 plus.minus gamma_3) 。 $


#parec[
  The difference between the computed result $t$ and the precise result is bounded by $gamma_3 |t|$.
][
  计算结果 $t$ 与精确结果之间的差异被 $gamma_3 |t|$ 所限制。
]

#parec[
  If we consider the intervals around the computed $t$ values that bound the true value of $t$, then the case we are concerned with is when the intervals overlap; if they do not, then the comparison of computed values will give the correct result (Figure #link("<fig:ray-bbox-error-offset>")[6.41];). If the intervals do overlap, it is impossible to know the true ordering of the $t$ values. In this case, increasing $t_(upright("max"))$ by twice the error bound, $2 gamma_3 t_(upright("max"))$, before performing the comparison ensures that we conservatively return true in this case.
][
  如果我们考虑围绕计算出的 $t$ 值的区间来限制 $t$ 的真实值，那么我们关注的情况是当这些区间重叠时；如果它们不重叠，那么计算值的比较将给出正确的结果（图 #link("<fig:ray-bbox-error-offset>")[6.41];）。如果区间重叠，就无法知道 $t$ 值的真实顺序。在这种情况下，在进行比较之前，将 $t_(upright("max"))$ 增加两倍误差界限，即 $2 gamma_3 t_(upright("max"))$，确保我们在这种情况下谨慎地返回真。
]

#parec[
  #block[
    #block[
      #block[

      ]
      Figure 6.41: If the error bounds of the computed $t_(upright("min"))$
      and $t_(upright("max"))$ values overlap, the comparison
      $t_(upright("min")) < t_(upright("max"))$ may not indicate if a ray hit
      a bounding box. It is better to conservatively return true in this case
      than to miss an intersection. Extending $t_(upright("max"))$ by twice
      its error bound ensures that the comparison is conservative.
    ]
  ]
][
  #block[
    #block[
      #block[

      ]
      图 6.41: 如果计算出的 $t_(upright("min"))$ 和 $t_(upright("max"))$
      值的误差界限重叠，比较 $t_(upright("min")) < t_(upright("max"))$
      可能无法指示射线是否击中包围盒。在这种情况下，谨慎地返回真比错过一个交点更好。通过将
      $t_(upright("max"))$ 扩展两倍其误差界限，确保比较是谨慎的。
    ]
  ]
]


#parec[
  $
    bold("d")_parallel & = (bold("o") dot.op hat(bold("d"))) hat(bold("d"))\
    bold("d")_tack.t & = bold("o") - bold("d")_parallel = bold("o") - (bold("o") dot.op hat(bold("d"))) hat(bold("d")) .
  $
][
  $
    bold("d")_parallel & = (bold("o") dot.op hat(bold("d"))) hat(bold("d"))\
    bold("d")_tack.t & = bold("o") - bold("d")_parallel = bold("o") - (bold("o") dot.op hat(bold("d"))) hat(bold("d")) .
  $
]

#parec[
  These three vectors form a right triangle, and therefore $ ∥bold("o")∥^2 = ∥bold("d")_tack.t∥^2 + ∥bold("d")_parallel∥^2 $ . Applying Equation~(6.25),
][
  这三个向量形成一个直角三角形，因此 $ ∥bold("o")∥^2 = ∥bold("d")_tack.t∥^2 + ∥bold("d")_parallel∥^2 $ 。应用方程~(6.25)，
]

#parec[
  $
    (bold("o") dot.op bold("o")) & = ∥bold("o") - (bold("o") dot.op hat(bold("d"))) hat(bold("d"))∥^2 + (
      bold("o") dot.op hat(bold("d"))
    )^2\
    & = ∥bold("o") - (bold("o") dot.op hat(bold("d"))) hat(bold("d"))∥^2 + (bold("o") dot.op hat(bold("d")))^2 .
  $
][
  $
    (bold("o") dot.op bold("o")) & = ∥bold("o") - (bold("o") dot.op hat(bold("d"))) hat(bold("d"))∥^2 + (
      bold("o") dot.op hat(bold("d"))
    )^2\
    & = ∥bold("o") - (bold("o") dot.op hat(bold("d"))) hat(bold("d"))∥^2 + (bold("o") dot.op hat(bold("d")))^2 .
  $
]

#parec[
  Rearranging terms gives
][
  重新排列项得到
]

#parec[
  $
    (bold("o") dot.op hat(bold("d")))^2 - (bold("o") dot.op bold("o")) = - ∥bold("o") - (
      bold("o") dot.op hat(bold("d"))
    ) hat(bold("d"))∥^2 .
  $
][
  $
    (bold("o") dot.op hat(bold("d")))^2 - (bold("o") dot.op bold("o")) = - ∥bold("o") - (
      bold("o") dot.op hat(bold("d"))
    ) hat(bold("d"))∥^2 .
  $
]

#parec[
  Expressing the right hand side in terms of the sphere quadratic coefficients from Equation~(6.3) gives
][
  将右侧用方程~(6.3)中的球体二次系数表示出来
]

#parec[
  $ (bold("o") dot.op hat(bold("d")))^2 - (bold("o") dot.op bold("o")) = - ∥bold("o") - frac(b, 2 a) bold("d")∥^2 . $
][
  $ (bold("o") dot.op hat(bold("d")))^2 - (bold("o") dot.op bold("o")) = - ∥bold("o") - frac(b, 2 a) bold("d")∥^2 . $
]

#parec[
  Note that the left hand side is equal to the term in square brackets in Equation~(6.24).
][
  注意，左侧等于方程~(6.24)中方括号内的项。
]

#parec[
  Computing that term in this way eliminates $c$ from the discriminant, which is of great benefit since its magnitude is proportional to the squared distance to the origin, with accordingly limited accuracy. In the implementation below, we take advantage of the fact that the discriminant is now the difference of squared values and make use of the identity $ x^2 - y^2 = (x + y) (x - y) $ to reduce the magnitudes of the intermediate values, which further reduces error.
][
  以这种方式计算该项去除了判别式中的 $c$，这非常有助于，因为其大小与到原点的平方距离成正比，因此精度有限。在下面的实现中，我们利用了判别式现在是平方值之差的事实，并利用恒等式 $ x^2 - y^2 = (x + y) (x - y) $ 来减少中间值的幅度，从而进一步减少误差。
]

#parec[
  One might ask, why go through this trouble when we could use the DifferenceOfProducts() function to compute the discriminant, presumably with low error? The reason that is not an equivalent alternative is that the values $a$, $b$, and $c$ already suffer from rounding error. In turn, a result computed by DifferenceOfProducts() will be inaccurate if its inputs already are inaccurate themselves. $ c = upright("normal ") o_x^2 + upright("normal ") o_y^2 + upright("normal ") o_z^2 - r^2 $ is particularly problematic, since it is the difference of two positive values, so is susceptible to catastrophic cancellation.
][
  有人可能会问，为什么要费这么大劲，而我们可以使用DifferenceOfProducts() 函数来计算判别式，假设误差很小？原因是不等效的替代方案是因为值 $a$， $b$ 和 $c$ 已经存在舍入误差。反过来，如果其输入本身已经不准确，则由 DifferenceOfProducts() 计算的结果将不准确。 $ c = upright("normal ") o_x^2 + upright("normal ") o_y^2 + upright("normal ") o_z^2 - r^2 $ 特别成问题，因为它是两个正值的差，因此容易发生灾难性消除。
]

#parec[
  A similar derivation gives a more accurate discriminant for the cylinder.
][
  类似的推导为圆柱体提供了更准确的判别式。
]

#parec[
  $
    I n t e r v a l f = b \/ (
      2 \* a
    ) ; I n t e r v a l v x = o i . x - f \* d i . x , v y = o i . y - f \* d i . y ; I n t e r v a l l e n g t h = S q r t (
      S q r (v x) + S q r (v y)
    ) ; I n t e r v a l d i s c r i m = 4 \* a \* (I n t e r v a l (r a d i u s) + l e n g t h) \* (
      I n t e r v a l (r a d i u s) - l e n g t h
    ) ; i f (d i s c r i m . L o w e r B o u n d () < 0) r e t u r n ;
  $
][
  $
    I n t e r v a l f = b \/ (
      2 \* a
    ) ; I n t e r v a l v x = o i . x - f \* d i . x , v y = o i . y - f \* d i . y ; I n t e r v a l l e n g t h = S q r t (
      S q r (v x) + S q r (v y)
    ) ; I n t e r v a l d i s c r i m = 4 \* a \* (I n t e r v a l (r a d i u s) + l e n g t h) \* (
      I n t e r v a l (r a d i u s) - l e n g t h
    ) ; i f (d i s c r i m . L o w e r B o u n d () < 0) r e t u r n ;
  $
]

#parec[
  The details of the ray-triangle intersection algorithm described in Section~6.5.3 were carefully designed to avoid cases where rays could incorrectly pass through an edge or vertex shared by two adjacent triangles without generating an intersection. Fittingly, an intersection algorithm with this guarantee is referred to as being #emph[watertight];.
][
  第~6.5.3节中描述的光线-三角形相交算法的细节经过精心设计，以避免光线可能错误地穿过由两个相邻三角形共享的边或顶点而不产生交点的情况。适当地，具有这种保证的相交算法被称为#emph[无缝];。
]

=== Accurate Quadratic Discriminants
<accurate-quadratic-discriminants>
=== Robust Triangle Intersections
<robust-triangle-intersections>


#parec[
  Recall that the algorithm is based on transforming triangle vertices into a coordinate system with the ray's origin at its origin and the ray's direction aligned along the $+ z$ axis. Although round-off error may be introduced by transforming the vertex positions to this coordinate system, this error does not affect the watertightness of the intersection test, since the same transformation is applied to all triangles. (Further, this error is quite small, so it does not significantly impact the accuracy of the computed intersection points.)
][
  回想一下，该算法基于将三角形顶点变换为一个坐标系，其中光线的起点位于其原点，光线的方向沿 $+ z$ 轴对齐。虽然通过将顶点位置变换到此坐标系可能引入舍入误差，但由于对所有三角形应用相同的转换，此误差不会影响相交测试的无缝性。（此外，此误差非常小，因此不会显著影响计算出的交点的准确性。）
]

#parec[
  Given vertices in this coordinate system, the three edge functions defined in Equation~6.5 are evaluated at the point \$ (0, 0) \$; the corresponding expressions, Equation~6.6, are quite straightforward. The key to the robustness of the algorithm is that with floating-point arithmetic, the edge function evaluations are guaranteed to have the correct sign. In general, we have
][
  在此坐标系中给定顶点，方程~(6.5)中定义的三个边缘函数在点 \$ (0, 0) \$ 处进行评估；相应的表达式，方程~(6.6)，非常简单。算法稳健性的关键在于浮点运算中，边缘函数评估保证具有正确的符号。一般来说，我们有
]

#parec[
  $ (a times b) - (c times d) . $
][
  $ (a times b) - (c times d) . $
]

#parec[
  First, note that if $ a b = c d $, then Equation~(6.26) evaluates to exactly zero, even in floating point. We therefore just need to show that if $ a b > c d $, then $ (a times b) - (c times d) $ is never negative. If $ a b > c d $, then $ (a times b) $ must be greater than or equal to $ (c times d) $. In turn, their difference must be greater than or equal to zero. (These properties both follow from the fact that floating-point arithmetic operations are all rounded to the nearest representable floating-point value.)
][
  首先，注意如果 $ a b = c d $，那么方程~(6.26) 即使在浮点数中也会精确地评估为零。因此，我们只需要证明如果 $ a b > c d $，那么 $ (a times b) - (c times d) $ 永远不会为负。如果 $ a b > c d $，那么 $ (a times b) $ 必须大于或等于 $
    (c times d)
  $。反过来，它们的差值必须大于或等于零。（这些属性都源于浮点运算操作都四舍五入到最接近的可表示浮点值的事实。）
]

#parec[
  If the value of the edge function is zero, then it is impossible to tell whether it is exactly zero or whether a small positive or negative value has rounded to zero. In this case, the fragment \<\> reevaluates the edge function with double precision; it can be shown that doubling the precision suffices to accurately distinguish these cases, given 32-bit floats as input.
][
  如果边缘函数的值为零，那么就无法判断它是精确为零还是一个小的正值或负值四舍五入为零。在这种情况下，片段 \<\> 将使用双精度重新评估边缘函数；可以证明，给定32位浮点数作为输入，双倍精度足以准确区分这些情况。
]

#parec[
  The overhead caused by this additional precaution is minimal: in a benchmark with 88 million ray intersection tests, the double-precision fallback had to be used in less than 0.0000023% of the cases.
][
  由此附加预防措施引起的开销很小：在一个有8800万次光线相交测试的基准中，双精度回退必须在不到0.0000023%的情况下使用。
]


=== Bounding Intersection Point Error
<bounding-intersection-point-error>
#parec[
  We can apply the machinery introduced in this section for analyzing rounding error to derive conservative bounds on the absolute error in computed ray-shape intersection points, which allows us to construct bounding boxes that are guaranteed to include an intersection point on the actual surface (Figure #link("<fig:basic-error-setting>")[6.43];). These bounding boxes provide the basis of the algorithm for generating spawned ray origins that will be introduced in Section #link("<sec:generating-rays>")[6.8.6];.
][
  我们可以应用本节介绍的分析舍入误差的方法，推导出计算的射线与形状交点的绝对误差的保守边界，这使我们能够构建保证包含实际表面交点的边界框（图 #link("<fig:basic-error-setting>")[6.43];）。这些边界框为将在第 #link("<sec:generating-rays>")[6.8.6] 节中介绍的生成衍生射线起点的算法提供了基础。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f43.svg"),
    caption: [

      Figure 6.43: Shape intersection algorithms in pbrt compute an
      intersection point, shown here in the 2D setting with a filled
      circle. The absolute error in this point is bounded by $delta_x$ and
      $delta_y$, giving a small box around the point. Because these bounds
      are conservative, we know that the actual intersection point on the
      surface (open circle) must lie somewhere within the box.
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f43.svg"),
    caption: [
      图 6.43：pbrt
      中的形状交点算法计算一个交点，这里在二维设置中显示为一个填充圆。该点的绝对误差由
      $delta_x$ 和 $delta_y$
      界定，在点周围形成一个小框。由于这些边界是保守的，我们知道实际表面上的交点（空心圆）必须位于框内的某个位置。
    ],
  )
]

#parec[
  It is illuminating to start by looking at the sources of error in conventional approaches to computing intersection points. It is common practice in ray tracing to compute 3D intersection points by first solving the parametric ray equation $upright(bold(o)) + t_(upright("hit")) upright(bold(d))$ for a value $t_(upright("hit"))$ where a ray intersects a surface and then computing the hit point $upright(bold(p))$ with $upright(bold(p)) = upright(bold(o)) + t_(upright("hit")) upright(bold(d))$. If $t_(upright("hit"))$ carries some error $delta_t$, then we can bound the error in the computed intersection point. Considering the $x$ coordinate, for example, we have
][
  首先查看常规方法中计算交点的误差来源是很有启发性的。在光线追踪中，通常通过首先求解参数射线方程 $upright(bold(o)) + t_(upright("hit")) upright(bold(d))$，得到光线与表面相交的值 $t_(upright("hit"))$，然后用 $upright(bold(p)) = upright(bold(o)) + t_(upright("hit")) upright(bold(d))$ 计算命中点 $upright(bold(p))$ 来计算三维交点。如果 $t_(upright("hit"))$ 带有一些误差 $delta_t$，那么我们可以界定计算交点的误差。例如，考虑 $x$ 坐标，我们有
]


#parec[
  $ x prime = x r / sqrt(x^2 + y^2 + z^2) , $
][
  $ x prime = x r / sqrt(x^2 + y^2 + z^2) , $
]

#parec[
  and so forth. The floating-point computation is
][
  等等，浮点运算为
]

#parec[
  $
    x prime & = x dot.circle r ⊘ upright("msq") sqrt((x dot.op x) + (y dot.op y) + (z dot.op z))\
    & in frac(x r (1 plus.minus epsilon.alt_m)^2, sqrt(x^2 (1 plus.minus epsilon.alt_m)^3 + y^2 (1 plus.minus epsilon.alt_m)^3 + z^2 (1 plus.minus epsilon.alt_m)^2)) (
      1 plus.minus epsilon.alt_m
    )\
    & subset frac(x r (1 plus.minus gamma_2), sqrt(x^2 (1 plus.minus gamma_3) + y^2 (1 plus.minus gamma_3) + z^2 (1 plus.minus gamma_2))) (
      1 plus.minus gamma_1
    )
  $
][
  $
    x prime & = x dot.circle r ⊘ upright("msq") sqrt((x dot.op x) + (y dot.op y) + (z dot.op z))\
    & in frac(x r (1 plus.minus epsilon.alt_m)^2, sqrt(x^2 (1 plus.minus epsilon.alt_m)^3 + y^2 (1 plus.minus epsilon.alt_m)^3 + z^2 (1 plus.minus epsilon.alt_m)^2)) (
      1 plus.minus epsilon.alt_m
    )\
    & subset frac(x r (1 plus.minus gamma_2), sqrt(x^2 (1 plus.minus gamma_3) + y^2 (1 plus.minus gamma_3) + z^2 (1 plus.minus gamma_2))) (
      1 plus.minus gamma_1
    )
  $
]

#parec[
  Because $x^2$, $y^2$, and $z^2$ are all positive, the terms in the square root can share the same $gamma$ term, and we have
][
  由于 $x^2$， $y^2$ 和 $z^2$ 均为正数，平方根中的项可以共享相同的 $gamma$ 项，因此我们得到
]

#parec[
  $
    x prime & in frac(x r (1 plus.minus gamma_2), sqrt((x^2 + y^2 + z^2)) (1 plus.minus gamma_4))\
    & = frac(x r (1 plus.minus gamma_2), sqrt((x^2 + y^2 + z^2)) sqrt((1 plus.minus gamma_4))) (1 plus.minus gamma_1)\
    & subset frac(x r, sqrt((x^2 + y^2 + z^2))) (1 plus.minus gamma_5)\
    & = x prime (1 plus.minus gamma_5)
  $
][
  $
    x prime & in frac(x r (1 plus.minus gamma_2), sqrt((x^2 + y^2 + z^2)) (1 plus.minus gamma_4))\
    & = frac(x r (1 plus.minus gamma_2), sqrt((x^2 + y^2 + z^2)) sqrt((1 plus.minus gamma_4))) (1 plus.minus gamma_1)\
    & subset frac(x r, sqrt((x^2 + y^2 + z^2))) (1 plus.minus gamma_5)\
    & = x prime (1 plus.minus gamma_5)
  $
]

#parec[
  Thus, the absolute error of the reprojected $x$ coordinate is bounded by $gamma_5 \| x prime \|$ (and similarly for $y prime$ and $z prime$ ) and is thus no more than 2.5 ulps in each dimension from a point on the surface of the sphere.
][
  因此，重投影的 $x$ 坐标的绝对误差被限制在 $gamma_5 \| x prime \|$ 以内（ $y prime$ 和 $z prime$ 也是类似），因此在球面上的某一点在每个维度上不超过 2.5 末位单位。
]

#parec[
  Here is the fragment that reprojects the intersection point for the
][
  以下是重投影交点的片段
]

#parec[
  Sphere shape.
][
  Sphere 形状。
]

#parec[
  The error bounds follow from Equation~(6.28).
][
  误差界限来自于方程~(6.28)。
]

#parec[
  Vector3f pError = (5) \* ((Vector3f)pHit);
][
  Vector3f pError = (5) \* ((Vector3f)pHit);
]

#parec[
  Reprojection algorithms and error bounds for other quadrics can be defined similarly: for example, for a cylinder along the $z$ axis, only the $x$ and $y$ coordinates need to be reprojected, and the error bounds in $x$ and $y$ turn out to be only $gamma_3$ times their magnitudes.
][
  其他二次曲面的重投影算法和误差界限可以类似定义：例如，对于沿 $z$ 轴的圆柱体，只需要重投影 $x$ 和 $y$ 坐标， $x$ 和 $y$ 的误差界限结果仅为其大小的 $gamma_3$ 倍。
]

#parec[
  Float hitRad = std::sqrt(Sqr(pHit.x) + Sqr(pHit.y));
][
  Float hitRad = std::sqrt(Sqr(pHit.x) + Sqr(pHit.y));
]

#parec[
  pHit.x \*= radius / hitRad;
][
  pHit.x \*= radius / hitRad;
]

#parec[
  pHit.y \*= radius / hitRad;
][
  pHit.y \*= radius / hitRad;
]

#parec[
  Vector3f pError = (3) \* (Vector3f(pHit.x, pHit.y, 0));
][
  Vector3f pError = (3) \* (Vector3f(pHit.x, pHit.y, 0));
]

#parec[
  The disk shape is particularly easy; we just need to set the $z$ coordinate of the point to lie on the plane of the disk.
][
  圆盘形状特别简单；我们只需要将点的 $z$ 坐标设置在圆盘的平面上。
]

#parec[
  pHit.z = height;
][
  pHit.z = height;
]

#parec[
  In turn, we have a point with zero error; it lies exactly on the surface on the disk.
][
  因此，我们得到一个零误差的点；它正好位于圆盘的表面上。
]

#parec[
  Vector3f pError(0, 0, 0);
][
  Vector3f pError(0, 0, 0);
]

#parec[
  The quadrics' Sample() methods also use reprojection. For example, the Sphere's area sampling method is based on SampleUniformSphere(), which uses std::sin() and std::cos().
][
  二次曲面的 Sample() 方法也使用重投影。例如，Sphere 的面积采样方法基于 SampleUniformSphere()，它使用 std::sin() 和 std::cos()。
]

#parec[
  Therefore, the error bounds on the computed pObj value depend on the accuracy of those functions.
][
  因此，计算出的 pObj 值的误差界限取决于这些函数的准确性。
]

#parec[
  By reprojecting the sampled point to the sphere's surface, the error bounds derived earlier in Equation~(6.28) can be used without needing to worry about those functions' accuracy.
][
  通过将采样点重投影到球体表面，可以使用之前在方程~(6.28) 中推导出的误差界限，而无需担心这些函数的准确性。
]

#parec[
  pObj \*= radius / Distance(pObj, Point3f(0, 0, 0));
][
  pObj \*= radius / Distance(pObj, Point3f(0, 0, 0));
]

#parec[
  Vector3f pObjError = (5) \* ((Vector3f)pObj);
][
  Vector3f pObjError = (5) \* ((Vector3f)pObj);
]

#parec[
  The same issue and solution apply to sampling cylinders.
][
  类似的问题和解决方案也适用于圆柱体的采样。
]

#parec[
  Float hitRad = std::sqrt(Sqr(pObj.x) + Sqr(pObj.y));
][
  Float hitRad = std::sqrt(Sqr(pObj.x) + Sqr(pObj.y));
]

#parec[
  pObj.x \*= radius / hitRad;
][
  pObj.x \*= radius / hitRad;
]

#parec[
  pObj.y \*= radius / hitRad;
][
  pObj.y \*= radius / hitRad;
]

#parec[
  Vector3f pObjError = (3) \* (Vector3f(pObj.x, pObj.y, 0));
][
  Vector3f pObjError = (3) \* (Vector3f(pObj.x, pObj.y, 0));
]

#parec[
  Parametric Evaluation: Triangles
][
  参数评估：三角形
]

#parec[
  Another effective approach to computing accurate intersection points near the surface of a shape uses the shape's parametric representation.
][
  另一种有效的方法是使用形状的参数表示来计算靠近形状表面的精确交点。
]

#parec[
  For example, the triangle intersection algorithm in Section~6.5.3 computes three edge function values $e_0$, $e_1$, and $e_2$ and reports an intersection if all three have the same sign.
][
  例如，第~6.5.3节中的三角形交点算法计算三个边函数值 $e_0$， $e_1$ 和 $e_2$，如果这三个值具有相同的符号，则报告交点。
]

#parec[
  Their values can be used to find the barycentric coordinates
][
  它们的值可以用于找到重心坐标
]


#parec[
  $ b_i = frac(e_i, e_0 + e_1 + e_2) . $
][
  $ b_i = frac(e_i, e_0 + e_1 + e_2) . $
]

#parec[
  Attributes $v_i$ at the triangle vertices (including the vertex positions) can be interpolated across the face of the triangle by
][
  三角形顶点的属性 $v_i$ （包括顶点位置）可以通过以下方式在三角形面上进行插值
]

$ v prime = b_0 v_0 + b_1 v_1 + b_2 v_2 . $


#parec[
  We can show that interpolating the positions of the vertices in this manner gives a point very close to the surface of the triangle. First consider precomputing the reciprocal of the sum of $e_i$ :
][
  我们可以证明以这种方式插值顶点的位置会得到一个非常接近三角形表面的点。首先考虑预先计算 $e_i$ 之和的倒数：
]

#parec[
  \$\$ \\begin{array}{c c} d & = \\frac{1}{(e\_0 + e\_1 + e\_2)} \\\\ & \\in \\frac{1}{(e\_0 + e\_1)(1 \\pm \\epsilon\_m)^2 + e\_2(1 \\pm \\epsilon\_m)} (1 \\pm \\epsilon\_m). \\end{array}\$\$
][
  \$\$ \\begin{array}{c c} d & = \\frac{1}{(e\_0 + e\_1 + e\_2)} \\\\ & \\in \\frac{1}{(e\_0 + e\_1)(1 \\pm \\epsilon\_m)^2 + e\_2(1 \\pm \\epsilon\_m)} (1 \\pm \\epsilon\_m). \\end{array}\$\$
]

#parec[
  Because all $e_i$ have the same sign if there is an intersection, we can collect the $e_i$ terms and conservatively bound $d$ :
][
  因为在有交点的情况下，所有 $e_i$ 都具有相同的符号，我们可以收集 $e_i$ 项并保守地界定 $d$ ：
]

#parec[
  \$\$ \\begin{array}{c c} d & \\in \\frac{1}{(e\_0 + e\_1 + e\_2)} (1 \\pm \\epsilon\_m)^2 \\\\ & \\subset \\frac{1}{(e\_0 + e\_1 + e\_2)} (1 \\pm \\gamma\_3). \\end{array}\$\$
][
  \$\$ \\begin{array}{c c} d & \\in \\frac{1}{(e\_0 + e\_1 + e\_2)} (1 \\pm \\epsilon\_m)^2 \\\\ & \\subset \\frac{1}{(e\_0 + e\_1 + e\_2)} (1 \\pm \\gamma\_3). \\end{array}\$\$
]

#parec[
  If we now consider interpolation of the $x$ coordinate of the position in the triangle corresponding to the edge function values, we have
][
  如果我们现在考虑对三角形中与边函数值对应的位置的 $x$ 坐标进行插值，我们有
]

#parec[
  \$\$ \\begin{array}{c c} x\' & = \\left((e\_0 x\_0) + (e\_1 x\_1) + (e\_2 x\_2)\\right) d \\\\ & \\in \\left(e\_0 x\_0 (1 \\pm \\epsilon\_m)^3 + e\_1 x\_1 (1 \\pm \\epsilon\_m)^3 + e\_2 x\_2 (1 \\pm \\epsilon\_m)^2\\right) d \\\\ & \\subset \\left(e\_0 x\_0 (1 \\pm \\gamma\_4) + e\_1 x\_1 (1 \\pm \\gamma\_4) + e\_2 x\_2 (1 \\pm \\gamma\_3)\\right) d. \\end{array}\$\$
][
  \$\$ \\begin{array}{c c} x\' & = \\left((e\_0 x\_0) + (e\_1 x\_1) + (e\_2 x\_2)\\right) d \\\\ & \\in \\left(e\_0 x\_0 (1 \\pm \\epsilon\_m)^3 + e\_1 x\_1 (1 \\pm \\epsilon\_m)^3 + e\_2 x\_2 (1 \\pm \\epsilon\_m)^2\\right) d \\\\ & \\subset \\left(e\_0 x\_0 (1 \\pm \\gamma\_4) + e\_1 x\_1 (1 \\pm \\gamma\_4) + e\_2 x\_2 (1 \\pm \\gamma\_3)\\right) d. \\end{array}\$\$
]

#parec[
  Using the bounds on $d$,
][
  利用 $d$ 的界限，
]

#parec[
  \$\$ \\begin{array}{c c} x & \\in \\frac{e\_0 x\_0 (1 \\pm \\gamma\_7) + e\_1 x\_1 (1 \\pm \\gamma\_7) + e\_2 x\_2 (1 \\pm \\gamma\_6)}{e\_0 + e\_1 + e\_2} \\\\ & = b\_0 x\_0 (1 \\pm \\gamma\_7) + b\_1 x\_1 (1 \\pm \\gamma\_7) + b\_2 x\_2 (1 \\pm \\gamma\_6). \\end{array}\$\$
][
  \$\$ \\begin{array}{c c} x & \\in \\frac{e\_0 x\_0 (1 \\pm \\gamma\_7) + e\_1 x\_1 (1 \\pm \\gamma\_7) + e\_2 x\_2 (1 \\pm \\gamma\_6)}{e\_0 + e\_1 + e\_2} \\\\ & = b\_0 x\_0 (1 \\pm \\gamma\_7) + b\_1 x\_1 (1 \\pm \\gamma\_7) + b\_2 x\_2 (1 \\pm \\gamma\_6). \\end{array}\$\$
]

#parec[
  Thus, we can finally see that the absolute error in the computed $x prime$ value is in the interval
][
  因此，我们可以看到计算出的 $x prime$ 值的绝对误差在以下区间内
]

#parec[
  $ plus.minus b_0 x_0 gamma_7 plus.minus b_1 x_1 gamma_7 plus.minus b_2 x_2 gamma_7 , $
][
  $ plus.minus b_0 x_0 gamma_7 plus.minus b_1 x_1 gamma_7 plus.minus b_2 x_2 gamma_7 , $
]

#parec[
  which is bounded by
][
  其界限可以表示为
]

#parec[
  $ gamma_7 (lr(|b_0 x_0|) + lr(|b_1 x_1|) + lr(|b_2 x_2|)) . $
][
  $ gamma_7 (lr(|b_0 x_0|) + lr(|b_1 x_1|) + lr(|b_2 x_2|)) . $
]

#parec[
  (Note that the $b_2 x_2$ term could have a \$ \_6\$ factor instead of \$ \_7\$, but the difference between the two is very small, so we choose a slightly simpler final expression.) Equivalent bounds hold for $y prime$ and $z prime$.
][
  （注意， $b_2 x_2$ 项可能包含一个 \$ \_6\$ 因子而不是 \$ \_7\$，但两者之间的差异很小，所以我们选择一个稍微简单的最终表达式。）对于 $y prime$ 和 $z prime$ 也有等效的界限。
]

#parec[
  Equation~(6.29) lets us bound the error in the interpolated point computed in Triangle::Intersect().
][
  方程~(6.29) 使我们能够界定在 Triangle::Intersect() 中计算的插值点的误差。
]

#parec[
  #block[
    \<\<Compute error bounds pError for triangle intersection\>\>=~
  ]
][
  #block[
    \<\<计算三角形交点的误差界限 pError\>\>=~
  ]
]

#parec[
  Point3f pAbsSum = Abs(ti.b0 \* p0) + Abs(ti.b1 \* p1) + Abs(ti.b2 \* p2); Vector3f pError = (7) \* Vector3f(pAbsSum);
][
  Point3f pAbsSum = Abs(ti.b0 \* p0) + Abs(ti.b1 \* p1) + Abs(ti.b2 \* p2); Vector3f pError = (7) \* Vector3f(pAbsSum);
]

#parec[
  The bounds for a sampled point on a triangle can be found in a similar manner.
][
  可以用类似的方法确定三角形上采样点的误差界限。
]

#parec[
  #block[
    \<\<Compute error bounds pError for sampled point on triangle\>\>=~
  ]
][
  #block[
    \<\<计算三角形上采样点的误差界限 pError\>\>=~
  ]
]

#parec[
  Point3f pAbsSum = Abs(b\[0\] \* p0) + Abs(b\[1\] \* p1) + Abs((1 - b\[0\] - b\[1\]) \* p2); Vector3f pError = Vector3f((6) \* pAbsSum);
][
  Point3f pAbsSum = Abs(b\[0\] \* p0) + Abs(b\[1\] \* p1) + Abs((1 - b\[0\] - b\[1\]) \* p2); Vector3f pError = Vector3f((6) \* pAbsSum);
]

#parec[
  Parametric Evaluation: Bilinear Patches
][
  参数评估：双线性补片
]

#parec[
  Bilinear patch intersection points are found by evaluating the bilinear function from Equation~(6.11). The computation performed is
][
  通过评估方程~(6.11) 中的双线性函数来确定双线性补片的交点。计算执行如下
]


#parec[
  $
    [(1 - u) ast.circle ((1 - v) ast.circle p_(0 , 0) + v ast.circle p_(0 , 1))] + [
      u ast.circle ((1 - v) ast.circle p_(1 , 0) + v ast.circle p_(1 , 1))
    ] .
  $
][
  $
    [(1 - u) ast.circle ((1 - v) ast.circle p_(0 , 0) + v ast.circle p_(0 , 1))] + [
      u ast.circle ((1 - v) ast.circle p_(1 , 0) + v ast.circle p_(1 , 1))
    ] .
  $
]

#parec[
  Considering just the $x$ coordinate, we can find that its error is bounded by
][
  在仅考虑 $x$ 坐标的情况下，我们可以发现其误差界限为
]

#parec[
  $
    gamma_6 lr(|(1 - u) (1 - v) x_(0 , 0)|) + gamma_5 lr(|(1 - u) v x_(0 , 1)|) + gamma_5 lr(|u (1 - v) x_(1 , 0)|) + gamma_4 lr(|u v x_(1 , 1)|) .
  $
][
  $
    gamma_6 lr(|(1 - u) (1 - v) x_(0 , 0)|) + gamma_5 lr(|(1 - u) v x_(0 , 1)|) + gamma_5 lr(|u (1 - v) x_(1 , 0)|) + gamma_4 lr(|u v x_(1 , 1)|) .
  $
]

#parec[
  Because $u$ and $v$ are between 0 and 1, here we will use the looser but more computationally efficient bounds of the form
][
  因为 $u$ 和 $v$ 在 0 和 1 之间，这里我们将使用在计算上更高效的宽松界限
]

#parec[
  $ gamma_6 (lr(|x_(0 , 0)|) + lr(|x_(0 , 1)|) + lr(|x_(1 , 0)|) + lr(|x_(1 , 1)|)) . $
][
  $ gamma_6 (lr(|x_(0 , 0)|) + lr(|x_(0 , 1)|) + lr(|x_(1 , 0)|) + lr(|x_(1 , 1)|)) . $
]

#parec[
  #block[
    \<\<Initialize bilinear patch intersection point error pError\>\>=
  ]
][
  #block[
    \<\<初始化双线性补丁交点误差 pError\>\>=
  ]
]


==== Effect of Transformations
<effect-of-transformations>
#parec[
  The last detail to attend to in order to bound the error in computed intersection points is the effect of transformations, which introduce additional rounding error when they are applied.
][
  为了限制计算出的交点误差，最后需要关注的细节是变换的影响，因为变换在应用时会引入额外的舍入误差。
]

#parec[
  The quadric `Shape`s in `pbrt` transform rendering-space rays into object space before performing ray-shape intersections, and then transform computed intersection points back to rendering space. Both of these transformation steps introduce rounding error that needs to be accounted for in order to maintain robust rendering-space bounds around intersection points.
][
  在 `pbrt` 中，二次曲面形状在进行光线与形状的交点计算之前，会将渲染空间光线变换到对象空间，然后再将计算出的交点变换回渲染空间。这两个变换步骤都会引入舍入误差，需要考虑这些误差以保持交点周围的渲染空间界限的稳健性。
]

#parec[
  If possible, it is best to try to avoid coordinate-system transformations of rays and intersection points. For example, it is better to transform triangle vertices to rendering space and intersect rendering-space rays with them than to transform rays to object space and then transform intersection points to rendering space.
][
  如果可能，最好避免对光线和交点进行坐标系变换。例如，将三角形顶点变换到渲染空间，并与渲染空间光线相交，比将光线变换到对象空间然后再将交点变换到渲染空间要好。
]

#parec[
  Transformations are still useful—for example, for the quadrics and for object instancing—so we will show how to bound the error that they introduce.
][
  变换仍然有用，例如对于二次曲面和对象实例化，因此我们将展示如何限制它们引入的误差。
]

#parec[
  We will discuss these topics in the context of the #link("../Geometry_and_Transformations/Transformations.html#Transform")[`Transform`] `operator()` method that takes a #link("../Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`];, which is the #link("../Geometry_and_Transformations/Points.html#Point3")[`Point3`] variant that uses an #link("../Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] for each of the coordinates.
][
  我们将在 #link("../Geometry_and_Transformations/Transformations.html#Transform")[`Transform`] `operator()` 方法的上下文中讨论这些主题，该方法接受一个 #link("../Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`];，这是使用 #link("../Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] 为每个坐标的 #link("../Geometry_and_Transformations/Points.html#Point3")[`Point3`] 变体。
]

```cpp
Point3fi operator()(const Point3fi &p) const {
    Float x = Float(p.x), y = Float(p.y), z = Float(p.z);
    // Compute transformed coordinates from point (x, y, z)
    Float xp = (m[0][0] * x + m[0][1] * y) + (m[0][2] * z + m[0][3]);
    Float yp = (m[1][0] * x + m[1][1] * y) + (m[1][2] * z + m[1][3]);
    Float zp = (m[2][0] * x + m[2][1] * y) + (m[2][2] * z + m[2][3]);
    Float wp = (m[3][0] * x + m[3][1] * y) + (m[3][2] * z + m[3][3]);
    // Compute absolute error for transformed point, pError
    Vector3f pError;
    if (p.IsExact()) {
        // Compute error for transformed exact p
        pError.x = \gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                                 std::abs(m[0][2] * z) + std::abs(m[0][3]));
        pError.y = \gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                                 std::abs(m[1][2] * z) + std::abs(m[1][3]));
        pError.z = \gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                                 std::abs(m[2][2] * z) + std::abs(m[2][3]));
    } else {
        // Compute error for transformed approximate p
        Vector3f pInError = p.Error();
        pError.x = (\gamma(3) + 1) * (std::abs(m[0][0]) * pInError.x +
                                        std::abs(m[0][1]) * pInError.y +
                                        std::abs(m[0][2]) * pInError.z) +
                     \gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                                  std::abs(m[0][2] * z) + std::abs(m[0][3]));
        pError.y = (\gamma(3) + 1) * (std::abs(m[1][0]) * pInError.x +
                                        std::abs(m[1][1]) * pInError.y +
                                        std::abs(m[1][2]) * pInError.z) +
                     \gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                                  std::abs(m[1][2] * z) + std::abs(m[1][3]));
        pError.z = (\gamma(3) + 1) * (std::abs(m[2][0]) * pInError.x +
                                        std::abs(m[2][1]) * pInError.y +
                                        std::abs(m[2][2]) * pInError.z) +
                     \gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                                  std::abs(m[2][2] * z) + std::abs(m[2][3]));
    }
    if (wp == 1)
        return Point3fi(Point3f(xp, yp, zp), pError);
    else
        return Point3fi(Point3f(xp, yp, zp), pError) / wp;
}
```

#parec[
  This method starts by computing the transformed position of the point $(x , y , z)$ where each coordinate is at the midpoint of its respective interval in `p`. The fragment that implements that computation, `Compute transformed coordinates from point (x, y, z)`, is not included here; it implements the same matrix/point multiplication as in Section 3.10.
][
  该方法首先计算点 $(x , y , z)$ 的变换位置，其中每个坐标位于 `p` 中各自区间的中点。实现该计算的片段 `从点 (x, y, z) 计算变换后的坐标` 未在此处包含；它实现了与第 3.10 节中相同的矩阵/点乘法。
]

#parec[
  Next, error bounds are computed, accounting both for rounding error when applying the transformation as well as the effect of non-empty intervals, if `p` is not exact.
][
  接下来，计算误差界限，考虑到应用变换时的舍入误差以及非空区间的影响，如果 `p` 不是精确的。
]

#parec[
  ```cpp
  Vector3f pError;
  if (p.IsExact()) {
      // Compute error for transformed exact p
      pError.x = \gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                               std::abs(m[0][2] * z) + std::abs(m[0][3]));
      pError.y = \gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                               std::abs(m[1][2] * z) + std::abs(m[1][3]));
      pError.z = \gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                               std::abs(m[2][2] * z) + std::abs(m[2][3]));
  } else {
      // Compute error for transformed approximate p
      Vector3f pInError = p.Error();
      pError.x = (\gamma(3) + 1) * (std::abs(m[0][0]) * pInError.x +
                                      std::abs(m[0][1]) * pInError.y +
                                      std::abs(m[0][2]) * pInError.z) +
                   \gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                                std::abs(m[0][2] * z) + std::abs(m[0][3]));
      pError.y = (\gamma(3) + 1) * (std::abs(m[1][0]) * pInError.x +
                                      std::abs(m[1][1]) * pInError.y +
                                      std::abs(m[1][2]) * pInError.z) +
                   \gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                                std::abs(m[1][2] * z) + std::abs(m[1][3]));
      pError.z = (\gamma(3) + 1) * (std::abs(m[2][0]) * pInError.x +
                                      std::abs(m[2][1]) * pInError.y +
                                      std::abs(m[2][2]) * pInError.z) +
                   \gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                                std::abs(m[2][2] * z) + std::abs(m[2][3]));
  }
  ```
][
  ```cpp
  Vector3f pError;
  if (p.IsExact()) {
      // 计算变换后的精确 p 的误差
      pError.x = \gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                               std::abs(m[0][2] * z) + std::abs(m[0][3]));
      pError.y = \gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                               std::abs(m[1][2] * z) + std::abs(m[1][3]));
      pError.z = \gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                               std::abs(m[2][2] * z) + std::abs(m[2][3]));
  } else {
      // 计算变换后的近似 p 的误差
      Vector3f pInError = p.Error();
      pError.x = (\gamma(3) + 1) * (std::abs(m[0][0]) * pInError.x +
                                      std::abs(m[0][1]) * pInError.y +
                                      std::abs(m[0][2]) * pInError.z) +
                   \gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                                std::abs(m[0][2] * z) + std::abs(m[0][3]));
      pError.y = (\gamma(3) + 1) * (std::abs(m[1][0]) * pInError.x +
                                      std::abs(m[1][1]) * pInError.y +
                                      std::abs(m[1][2]) * pInError.z) +
                   \gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                                std::abs(m[1][2] * z) + std::abs(m[1][3]));
      pError.z = (\gamma(3) + 1) * (std::abs(m[2][0]) * pInError.x +
                                      std::abs(m[2][1]) * pInError.y +
                                      std::abs(m[2][2]) * pInError.z) +
                   \gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                                std::abs(m[2][2] * z) + std::abs(m[2][3]));
  }
  ```
]

#parec[
  If $(x , y , z)$ has no accumulated error, then given a $4 times 4$ non-projective transformation matrix with elements denoted by $m_(i , j)$, the transformed coordinate $x prime$ is
][
  如果 $(x , y , z)$ 没有累积误差，给定一个 $4 times 4$ 的非投影变换矩阵，其元素为 $m_(i , j)$，则变换后的坐标 $x prime$ 为
]


#parec[
  $
    x prime & = (m_(0 , 0) dot.op x + m_(0 , 1) dot.op y + m_(0 , 2) dot.op z + m_(0 , 3))\
    & in m_(0 , 0) x (1 plus.minus epsilon.alt_m)^3 + m_(0 , 1) y (1 plus.minus epsilon.alt_m)^3 + m_(0 , 2) z (
      1 plus.minus epsilon.alt_m
    )^3 + m_(0 , 3) (1 plus.minus epsilon.alt_m)^2\
    & subset.eq (m_(0 , 0) x + m_(0 , 1) y + m_(0 , 2) z + m_(0 , 3)) + gamma_3 (
      plus.minus m_(0 , 0) x plus.minus m_(0 , 1) y plus.minus m_(0 , 2) z plus.minus m_(0 , 3)
    )\
    & subset.eq (m_(0 , 0) x + m_(0 , 1) y + m_(0 , 2) z + m_(0 , 3)) plus.minus gamma_3 (
      \| m_(0 , 0) x \| + \| m_(0 , 1) y \| + \| m_(0 , 2) z \| + \| m_(0 , 3) \|
    ) .
  $
][
  $
    x prime & = (m_(0 , 0) dot.op x + m_(0 , 1) dot.op y + m_(0 , 2) dot.op z + m_(0 , 3))\
    & in m_(0 , 0) x (1 plus.minus epsilon.alt_m)^3 + m_(0 , 1) y (1 plus.minus epsilon.alt_m)^3 + m_(0 , 2) z (
      1 plus.minus epsilon.alt_m
    )^3 + m_(0 , 3) (1 plus.minus epsilon.alt_m)^2\
    & subset.eq (m_(0 , 0) x + m_(0 , 1) y + m_(0 , 2) z + m_(0 , 3)) + gamma_3 (
      plus.minus m_(0 , 0) x plus.minus m_(0 , 1) y plus.minus m_(0 , 2) z plus.minus m_(0 , 3)
    )\
    & subset.eq (m_(0 , 0) x + m_(0 , 1) y + m_(0 , 2) z + m_(0 , 3)) plus.minus gamma_3 (
      \| m_(0 , 0) x \| + \| m_(0 , 1) y \| + \| m_(0 , 2) z \| + \| m_(0 , 3) \|
    ) .
  $
]

#parec[
  Thus, the absolute error in the result is bounded by
][
  因此，结果的绝对误差被限制在
]

#parec[
  $ gamma_3 (\| m_(0 , 0) x \| + \| m_(0 , 1) y \| + \| m_(0 , 2) z \| + \| m_(0 , 3) \|) . $
][
  $ gamma_3 (\| m_(0 , 0) x \| + \| m_(0 , 1) y \| + \| m_(0 , 2) z \| + \| m_(0 , 3) \|) . $
]

#parec[
  Similar bounds follow for the transformed $y prime$ and $z prime$ coordinates, and the implementation follows directly.
][
  类似的界限适用于变换后的 $y prime$ 和 $z prime$ 坐标，且实现可以直接进行。
]

#parec[
  #block[
    \<\<Compute error for transformed exact p\>\>=~
  ]
][
  #block[
    \<\<计算变换后精确 p 的误差\>\>=~
  ]
]

=== Robust Spawned Ray Origins
<robust-spawned-ray-origins>


#parec[
  Computed intersection points and their error bounds give us a small 3D box that bounds a region of space. We know that the precise intersection point must be somewhere inside this box and that thus the surface must pass through the box (at least enough to present the point where the intersection is). (Recall Figure 6.43.) Having these boxes makes it possible to position the origins of rays leaving the surface so that they are always on the right side of the surface and do not incorrectly reintersect it.
][
  计算出的交点及其误差范围为我们提供了一个小的三维盒子，该盒子界定了一个空间区域。我们知道精确的交点一定在这个盒子内部，因此表面必须穿过这个盒子（至少足以呈现出交点的位置）。（回忆图6.43。）有了这些盒子，我们就可以定位离开表面的生成光线的起点，以确保它们始终位于表面的正确一侧，并且不会错误地再次与表面相交。
]

#parec[
  When tracing spawned rays leaving the intersection point $n o r m a l #h(0em) p$, we offset their origins enough to ensure that they are past the boundary of the error box and thus will not incorrectly reintersect the surface.
][
  当追踪从交点 $n o r m a l #h(0em) p$ 发出的生成光线时，我们将它们的起点偏移足够的距离，以确保它们超出误差边界盒的边界，从而不会错误地再次与表面相交。
]

#parec[
  In order to ensure that the spawned ray origin is definitely on the right side of the surface, we move far enough along the normal so that the plane perpendicular to the normal is outside the error bounding box. To see how to do this, consider a computed intersection point at the origin, where the equation for the plane going through the intersection point is
][
  为了确保生成的光线起点确实在表面的正确一侧，我们沿法线移动足够远，以使垂直于法线的平面位于误差边界盒之外。要了解如何做到这一点，请考虑一个位于原点的计算交点，其中通过交点的平面的方程为
]

#parec[
  $ f (x , y , z) = upright(bold(n))_x x + upright(bold(n))_y y + upright(bold(n))_z z . $
][
  $ f (x , y , z) = upright(bold(n))_x x + upright(bold(n))_y y + upright(bold(n))_z z . $
]

#parec[
  The plane is implicitly defined by $f (x , y , z) = 0$, and the normal is $(upright(bold(n))_x , upright(bold(n))_y , upright(bold(n))_z)$.
][
  平面由方程 $f (x , y , z) = 0$ 隐式定义，法线为 $(upright(bold(n))_x , upright(bold(n))_y , upright(bold(n))_z)$。
]

#parec[
  For a point not on the plane, the value of the plane equation $f (x , y , z)$ gives the offset along the normal that gives a plane that goes through the point. We would like to find the maximum value of $f (x , y , z)$ for the eight corners of the error bounding box; if we offset the plane plus and minus this offset, we have two planes that do not intersect the error box that should be (locally) on opposite sides of the surface, at least at the computed intersection point offset along the normal (Figure 6.45).
][
  对于不在平面上的点，平面方程 $f (x , y , z)$ 的值给出了沿法线的偏移量，该偏移量给出一个通过该点的平面。我们希望找到误差边界盒八个角中 $f (x , y , z)$ 的最大值；如果我们将平面加上和减去这个偏移量，我们就有两个不与误差边界盒相交的平面，这两个平面应该（局部地）位于表面的相对两侧，至少在沿法线偏移的计算交点处（图6.45）。
]

#parec[
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f45.svg"),
    caption: [
      Figure 6.45:
    ],
  )
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f45.svg"),
    caption: [
      图6.45:
    ],
  )
]


#parec[
  $ d = lr(|upright(bold(n))_x|) Delta x + lr(|upright(bold(n))_y|) Delta y + lr(|upright(bold(n))_z|) Delta z $ 通过沿表面法线偏移来计算生成的光线起点有几个优点：假设表面是局部平面的（这是一个合理的假设，尤其是在交点误差界限的非常小的尺度上），沿法线移动可以让我们以最短的距离从表面的一侧移动到另一侧。一般来说，最小化光线起点的偏移距离对于保持阴影和反射细节是有利的。
][
  `OffsetRayOrigin()` 是一个实现此计算的简短函数。
]

#parec[
  `Point3f OffsetRayOrigin(Point3fi pi, Normal3f n, Vector3f w) {     // Find vector offset to corner of error bounds and compute initial po     Float d = Dot(Abs(n), pi.Error());     Vector3f offset = d * Vector3f(n);     if (Dot(w, n) < 0)         offset = -offset;     Point3f po = Point3f(pi) + offset;     // Round offset point po away from p     for (int i = 0; i < 3; ++i) {         if (offset[i] > 0)      po[i] = NextFloatUp(po[i]);         else if (offset[i] < 0) po[i] = NextFloatDown(po[i]);     }     return po; }` \`Float d = Dot(Abs(n), pi.Error()); Vector3f offset = d \* Vector3f(n); if (Dot(w, n) \< 0) offset = -offset; Point3f po = Point3f(pi) + offset;
][
  #figure(
    image("../pbr-book-website/4ed/Shapes/pha06f46.svg"),
    caption: [
      图 6.46
    ],
  )

  #strong[图 6.46：] 在 `OffsetRayOrigin()` 中计算的偏移点 `p + offset` 的舍入值可能最终位于误差框的内部而不是其边界上，这反过来会引入错误自相交的风险，如果舍入点位于表面的错误一侧。将计算点的每个坐标向远离 `p` 的方向推进一个浮点值，确保它在误差框之外。
]

#parec[
  We also must handle round-off error when computing the offset point: when `offset` is added to `p`, the result will in general need to be rounded to the nearest floating-point value. In turn, it may be rounded down toward `p` such that the resulting point is in the interior of the error box rather than on its boundary (Figure 6.46). Therefore, the offset point is rounded away from `p` here to ensure that it is not inside the box.
][
  我们还必须处理计算偏移点时的舍入误差：当 `offset` 加到 `p` 时，结果通常需要舍入到最近的浮点值。反过来，它可能会向下舍入到 `p`，使得结果点位于误差框的内部而不是其边界上（图 6.46）。因此，这里的偏移点被舍入远离 `p`，以确保它不在框内。
]

#parec[
  Alternatively, the floating-point rounding mode could have been set to round toward plus or minus infinity (based on the sign of the value). Changing the rounding mode is fairly expensive on many processors, so we just shift the floating-point value by one ulp here. This will sometimes cause a value already outside of the error box to go slightly farther outside it, but because the floating-point spacing is so small, this is not a problem in practice.
][
  或者，可以将浮点舍入模式设置为向正无穷或负无穷舍入（基于值的符号）。改变舍入模式在许多处理器上相当昂贵，所以我们只在这里将浮点值移动一个最后一位单位 (ulp)。这有时会导致已经在误差框外的值稍微更远，但由于浮点间距非常小，这在实践中不是问题。
]

#parec[
  `for (int i = 0; i < 3; ++i) {     if (offset[i] > 0)      po[i] = NextFloatUp(po[i]);     else if (offset[i] < 0) po[i] = NextFloatDown(po[i]); }`

  为了方便，#link("../Geometry_and_Transformations/Interactions.html#Interaction")[Interaction] 提供了通过其存储的位置和表面法线执行光线偏移计算的两种变体方法。第一种方法接受光线方向，就像独立的 `OffsetRayOrigin()` 函数一样。
][
  `Point3f OffsetRayOrigin(Vector3f w) const {     return pbrt::OffsetRayOrigin(pi, n, w); }`
]

#parec[
  The second takes a position for the ray's destination that is used to compute a direction `w` to pass to the first method.
][
  第二种方法接受用于计算方向 `w` 的光线目标位置，并传递给第一种方法。
]

#parec[
  `Point3f OffsetRayOrigin(Point3f pt) const {     return OffsetRayOrigin(pt - p()); }`

  对于 #link("../Geometry_and_Transformations/Rays.html#Ray")[Ray] 类，还有一些辅助函数用于生成考虑这些偏移的离开交点的光线。
][
  `Ray SpawnRay(Point3fi pi, Normal3f n, Float time, Vector3f d) {     return Ray(OffsetRayOrigin(pi, n, d), d, time); }`
]

#parec[
  `Ray SpawnRayTo(Point3fi pFrom, Normal3f n, Float time, Point3f pTo) {     Vector3f d = pTo - Point3f(pFrom);     return SpawnRay(pFrom, n, time, d); }`

  要在两点之间生成光线，需要在计算它们之间的向量之前对两个端点进行偏移。
][
  `Ray SpawnRayTo(Point3fi pFrom, Normal3f nFrom, Float time, Point3fi pTo,                Normal3f nTo) {     Point3f pf = OffsetRayOrigin(pFrom, nFrom,                                  Point3f(pTo) - Point3f(pFrom));     Point3f pt = OffsetRayOrigin(pTo, nTo, pf - Point3f(pTo));     return Ray(pf, pt - pf, time); }`
]

#parec[
  We can also implement #link("../Geometry_and_Transformations/Interactions.html#Interaction")[Interaction] methods that generate rays leaving intersection points.
][
  `RayDifferential SpawnRay(Vector3f d) const {     return RayDifferential(OffsetRayOrigin(d), d, time, GetMedium(d)); }`
]

#parec[
  `Ray SpawnRayTo(Point3f p2) const {     Ray r = pbrt::SpawnRayTo(pi, n, time, p2);     r.medium = GetMedium(r.d);     return r; }`

  一个接受 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[Interaction] 的 `Interaction::SpawnRayTo()` 变体类似，这里不包括。
][
  #link("../Shapes/Basic_Shape_Interface.html#ShapeSampleContext")[ShapeSampleContext] 类还提供了与我们在这里添加到 #link("../Geometry_and_Transformations/Interactions.html#Interaction")[Interaction] 的方法相对应的 `OffsetRayOrigin()` 和 `SpawnRay()` 辅助方法。它们的实现基本相同，因此这里不包括。
]

#parec[
  The approach we have developed so far addresses the effect of floating-point error at the origins of rays leaving surfaces; there is a related issue for shadow rays to area light sources: we would like to find any intersections with shapes that are close to the light source and actually occlude it, while avoiding reporting incorrect intersections with the surface of the light source.
][
  我们迄今为止开发的方法解决了浮点误差对离开表面的光线起点的影响；对于指向区域光源的阴影光线，还有一个相关问题：我们希望找到任何与光源接近并实际遮挡它的形状的交点，同时避免报告与光源表面的错误交点。
]

#parec[
  Unfortunately, our implementation does not address this issue, so we set the `tMax` value of shadow rays to be just under one so that they stop before the surface of light sources.
][
  不幸的是，我们的实现没有解决这个问题，所以我们将阴影光线的 `tMax` 值设置为略低于 1，以便它们在光源表面之前停止。
]

#parec[
  `constexpr Float ShadowEpsilon = 0.0001f;`
][
  为了保持稳健的生成光线起点，最后一个问题必须解决：执行变换时引入的误差。
]

#parec[
  Given a ray in one coordinate system where its origin was carefully computed to be on the appropriate side of some surface, transforming that ray to another coordinate system may introduce error in the transformed origin such that the origin is no longer on the correct side of the surface it was spawned from.
][
  给定一个在一个坐标系中的光线，其起点被仔细计算以位于某个表面的适当一侧，将该光线变换到另一个坐标系可能会在变换的起点引入误差，使得起点不再位于其生成的表面的正确一侧。
]

#parec[
  Therefore, whenever a ray is transformed by the `Ray` variant of `Transform::operator()` (which was implemented in Section #link("../Geometry_and_Transformations/Applying_Transformations.html#sec:transform-rays")[3.10.4];), its origin is advanced to the edge of the bounds on the error that was introduced by the transformation.
][
  因此，每当光线通过 `Transform::operator()` 的 `Ray` 变体（在 #link("../Geometry_and_Transformations/Applying_Transformations.html#sec:transform-rays")[3.10.4] 节中实现）进行变换时，其起点会推进到变换引入的误差界限的边缘。
]


=== Avoiding Intersections behind Ray Origins
<avoiding-intersections-behind-ray-origins>

#parec[
  Bounding the error in computed intersection points allows us to compute ray origins that are guaranteed to be on the right side of the surface so that a ray with infinite precision would not incorrectly intersect the surface it is leaving. However, a second source of rounding error must also be addressed: the error in parametric $t$ values computed for ray-shape intersections. Rounding error can lead to an intersection algorithm computing a value $t > 0$ for the intersection point even though the $t$ value for the actual intersection is negative (and thus should be ignored).
][
  限定计算出的交点误差使我们能够计算出射线起点，确保它们位于表面的正确一侧，从而保证无限精度的射线不会错误地与其离开的表面相交。然而，还必须解决第二个舍入误差来源：射线与形状相交时计算出的参数化 $t$ 值的误差。舍入误差可能导致相交算法计算出 $t > 0$ 的结果，即使实际相交的 $t$ 值为负（因此应忽略）。
]

#parec[
  It is possible to show that some intersection test algorithms always return a $t$ value with the correct sign; this is the best case, as no further computation is needed to bound the actual error in the computed $t$ value. For example, consider the ray-axis-aligned slab computation: $t = frac(x - n_x, d_x)$. The IEEE floating-point standard guarantees that if $a > b$, then $a - b gt.eq 0$ (and if $a < b$, then $a - b lt.eq 0$ ). To see why this is so, note that if $a > b$, then the real number $a - b$ must be greater than zero. When rounded to a floating-point number, the result must be either zero or a positive float; there is no way a negative floating-point number could be the closest floating-point number. Second, floating-point division returns the correct sign; these together guarantee that the sign of the computed $t$ value is correct. (Or that $t = 0$, but this case is fine, since our test for an intersection is carefully chosen to be $t > 0$.)
][
  可以证明某些相交测试算法总是返回具有正确符号的 $t$ 值；这是最佳情况，因为不需要进一步计算来限定计算出的 $t$ 值的实际误差。例如，考虑射线与轴对齐平板的计算： $t = frac(x - n_x, d_x)$。IEEE 浮点标准保证如果 $a > b$，则 $a - b gt.eq 0$ （如果 $a < b$，则 $a - b lt.eq 0$ ）。要理解为什么是这样，注意如果 $a > b$，则实数 $a - b$ 必然大于零。当舍入到浮点数时，结果必须是零或正浮点数；不可能有负浮点数是最接近的浮点数。其次，浮点除法会返回正确的符号；这些共同保证计算出的 $t$ 值的符号是正确的。（或者 $t = 0$，但这种情况是可以的，因为我们的相交测试被仔细选择为 $t > 0$。）
]

#parec[
  For shape intersection routines that are based on the `Interval` class, the computed $t$ value in the end has an error bound associated with it, and no further computation is necessary to perform this test. See the definition of the fragment \<\<Check quadric shape `t0` and `t1` for nearest intersection\>\> in Section 6.2.2.
][
  对于基于 `Interval` 类的形状相交例程，最终计算出的 $t$ 值附带一个误差界限，不需要进一步计算来执行此测试。参见第 6.2.2 节中片段 \<\<检查二次曲面形状 `t0` 和 `t1` 以寻找最近的相交\>\> 的定义。
]

==== Triangles
<triangles>


#parec[
  `Interval` introduces computational overhead that we would prefer to avoid for more commonly used shapes where efficient intersection code is more important. For these shapes, we can derive efficient-to-evaluate conservative bounds on the error in computed $t$ values. The ray-triangle intersection algorithm in Section 6.5.3 computes a final $t$ value by computing three edge function values $e_i$ and using them to compute a barycentric-weighted sum of transformed vertex $z$ coordinates, $z_i$ :
][
  `Interval` 引入了计算开销，我们希望避免在更常用的形状中使用，因为在这些形状中高效的相交代码更为重要。对于这些形状，我们可以推导出易于计算的保守界限来评估计算 $t$ 值的误差。第 6.5.3 节中的射线与三角形相交算法通过计算三个边缘函数值 $e_i$ 并使用它们计算变换顶点 $z$ 坐标的重心权重和 $z_i$ 来计算最终的 $t$ 值：
]

$ t = frac(e_0 z_0 + e_1 z_1 + e_2 z_2, e_0 + e_1 + e_2) . $

#parec[
  By successively bounding the error in these terms and then in the final $t$ value, we can conservatively check that it is positive.
][
  通过逐步限定这些项中的误差，然后限定最终 $t$ 值中的误差，我们可以保守地验证其为正。
]



```cpp
<<Compute $\delta_z$ term for triangle t error bounds>>   Float maxZt = MaxComponentValue(Abs(Vector3f(p0t.z, p1t.z, p2t.z)));
Float deltaZ = \gamma(3) * maxZt;
<<Compute $\delta_x$ and $\delta_y$ terms for triangle t error bounds>>   Float maxXt = MaxComponentValue(Abs(Vector3f(p0t.x, p1t.x, p2t.x)));
Float maxYt = MaxComponentValue(Abs(Vector3f(p0t.y, p1t.y, p2t.y)));
Float deltaX = \gamma(5) * (maxXt + maxZt);
Float deltaY = \gamma(5) * (maxYt + maxZt);
<<Compute $\delta_e$ term for triangle t error bounds>>   Float deltaE = 2 * (\gamma(2) * maxXt * maxYt + deltaY * maxXt + deltaX * maxYt);
<<Compute $\delta_t$ term for triangle t error bounds and check t>>   Float maxE = MaxComponentValue(Abs(Vector3f(e0, e1, e2)));
Float deltaT = 3 * (\gamma(3) * maxE * maxZt + deltaE * maxZt + deltaZ * maxE) * std::abs(invDet);
if (t <= deltaT)
    return {};
```

#parec[
  Given a ray $r$ with origin $o$, direction $upright(bold(d))$, and a triangle vertex $p$, the projected $z$ coordinate is
][
  给定射线 $r$，其起点为 $o$，方向为 $upright(bold(d))$，以及三角形顶点 $p$，投影后的 $z$ 坐标为
]

#parec[
  $ z = (1 / d_z) dot.op (p_z - o_z) . $
][
  $ z = (1 / d_z) dot.op (p_z - o_z) . $
]

#parec[
  Applying the usual approach, we can find that the maximum error in $z_i$ for each of three vertices of the triangle $p_i$ is bounded by $gamma (3) lr(|z_i|)$, and we can thus find a conservative upper bound for the error in #emph[any] of the $z$ positions by taking the maximum of these errors:
][
  应用通常的方法，我们可以发现对于三角形 $p_i$ 的每个三个顶点， $z_i$ 的误差上限被 $gamma (3) lr(|z_i|)$ 限制，因此我们可以通过取这些误差的最大值来找到 #emph[任何] $z$ 位置误差的保守上限：
]

$ delta_z = gamma (3) max_i lr(|z_i|) . $



```cpp
Float maxZt = MaxComponentValue(Abs(Vector3f(p0t.z, p1t.z, p2t.z)));
Float deltaZ = \gamma(3) * maxZt;
```


#parec[
  The edge function values are computed as the difference of two products of transformed $x$ and $y$ vertex positions:
][
  边缘函数值通过计算两个乘积的差得出：
]

$
  e_0 & = (x_1 dot.op y_2) - (y_1 dot.op x_2)\
  e_1 & = (x_2 dot.op y_0) - (y_2 dot.op x_0)\
  e_2 & = (x_0 dot.op y_1) - (y_0 dot.op x_1) .
$


#parec[
  StartLayout 1st Row 1st Column $delta x$ 2nd Column equals $gamma (5) (max_i lr(|x_i|) + max_i lr(|z_i|))$ 2nd Row 1st Column $delta y$ 2nd Column equals $gamma (5) (max_i lr(|y_i|) + max_i lr(|z_i|))$.
][
  第1行 第1列 $delta x$ 第2列 等于 $gamma (5) (max_i lr(|x_i|) + max_i lr(|z_i|))$ 第2行 第1列 $delta y$ 第2列 等于 $gamma (5) (max_i lr(|y_i|) + max_i lr(|z_i|))$。
]

#parec[
  Compute $delta x$ and $delta y$ terms for triangle $t$ error bounds:
][
  计算三角形 $t$ 的误差界限中的 $delta x$ 和 $delta y$ 项：
]

```plaintext
Float maxXt = MaxComponentValue(Abs(Vector3f(p0t.x, p1t.x, p2t.x)));
Float maxYt = MaxComponentValue(Abs(Vector3f(p0t.y, p1t.y, p2t.y)));
Float deltaX = gamma(5) * (maxXt + maxZt);
Float deltaY = gamma(5) * (maxYt + maxZt);
```


#parec[
  Taking the maximum error over all three of the vertices, the \$x\_{i} \\circledtimes y\_{j}\$ products in the edge functions are bounded by
][
  在所有三个顶点中取最大误差，边函数中的 \$x\_{i} \\circledtimes y\_{j}\$ 乘积的界限为
]

$ (max_i lr(|x_i|) + delta x) (max_i lr(|y_i|) + delta y) (1 plus.minus epsilon.alt_m) , $

#parec[
  which have an absolute error bound of
][
  其绝对误差界限为如下
]

$
  delta x y = gamma (1) max_i lr(|x_i|) max_i lr(|y_i|) + delta y max_i lr(|x_i|) + delta x max_i lr(|y_i|) + dots.h.c .
$



#parec[
  Dropping the (negligible) higher-order terms of products of $gamma$ and $delta$ terms, the error bound on the difference of two $x$ and $y$ terms for the edge function is
][
  忽略（可忽略的） $gamma$ 和 $delta$ 项乘积的高阶项，边函数中两个 $x$ 和 $y$ 项差异的误差界限为
]

$ delta e = 2 (gamma (2) max_i lr(|x_i|) max_i lr(|y_i|) + delta y max_i lr(|x_i|) + delta x max_i lr(|y_i|)) . $


#parec[
  Compute $delta e$ term for triangle $t$ error bounds:
][
  计算三角形 $t$ 的误差界限的 $delta e$ 项：
]

```plaintext
Float deltaE = 2 * (gamma(2) * maxXt * maxYt + deltaY * maxXt + deltaX * maxYt);
```


#parec[
  Again bounding error by taking the maximum of error over all the $e_i$ terms, the error bound for the computed value of the numerator of $t$ in Equation (6.32) is
][
  再次通过取所有 $e_i$ 项的误差最大值来界定误差，方程 (6.32) 中 $t$ 的分子计算值的误差界限为
]

$ delta t = 3 (gamma (3) max_i lr(|e_i|) max_i lr(|z_i|) + delta e max_i lr(|z_i|) + delta z max_i lr(|e_i|)) . $

#parec[
  A computed $t$ value (before normalization by the sum of $e_i$ ) must be greater than this value for it to be accepted as a valid intersection that definitely has a positive $t$ value.
][
  计算出的 $t$ 值（在用 $e_i$ 的总和进行归一化之前）必须大于此值，才能被接受为一个有效的交点，确保其具有正的 $t$ 值。
]

#parec[
  Compute $delta t$ term for triangle $t$ error bounds and check $t$ :
][
  计算三角形 $t$ 的误差界限的 $delta t$ 项并检查 $t$ ：
]

```plaintext
Float maxE = MaxComponentValue(Abs(Vector3f(e0, e1, e2)));
Float deltaT = 3 * (gamma(3) * maxE * maxZt + deltaE * maxZt + deltaZ * maxE) * std::abs(invDet);
if (t <= deltaT)
    return {};
```


#parec[
  Although it may seem that we have made a number of choices to compute looser bounds than we might have, in practice the bounds on error in $t$ are extremely small.
][
  尽管看起来我们在计算比可能更宽松的界限时做出了许多选择，但实际上 $t$ 的误差界限非常小。
]

#parec[
  For a regular scene that fills a bounding box roughly $plus.minus 10$ in each dimension, our $t$ error bounds near ray origins are generally around $10^(- 7)$.
][
  对于在每个维度大约 $plus.minus 10$ 的边界框内的常规场景，我们在射线起点附近的 $t$ 误差界限通常约为 $10^(- 7)$。
]

==== Bilinear Patches
<bilinear-patches>

#parec[
  Recall from Section 6.6.1 that the $t$ value for a bilinear patch intersection is found by taking the determinant of a $3 times 3$ matrix.
][
  回忆第 6.6.1 节中，双线性补丁交点的 $t$ 值是通过取一个 $3 times 3$ 矩阵的行列式来找到的。
]

#parec[
  Each matrix element includes round-off error from the series of floating-point computations used to compute its value.
][
  每个矩阵元素都包含了用于计算其值的浮点计算序列中的舍入误差。
]

#parec[
  While it is possible to derive bounds on the error in the computed $t$ using a similar approach as was used for triangle intersections, the algebra becomes unwieldy because the computation involves many more operations.
][
  虽然可以使用类似于三角形交点的方式推导出计算出的 $t$ 的误差界限，但由于计算涉及更多的操作，代数变得笨拙。
]

#parec[
  Therefore, here we compute an epsilon value that is based on the magnitudes of all of the inputs of the computation of $t$.
][
  因此，这里我们计算一个基于 $t$ 计算输入的大小的 epsilon 值。
]

#parec[
  Find epsilon $e p s$ to ensure that candidate $t$ is greater than zero:
][
  计算 epsilon $e p s$ 以确保候选 $t$ 大于零：
]

```plaintext
Float eps = gamma(10) *
    (MaxComponentValue(Abs(ray.o)) + MaxComponentValue(Abs(ray.d)) +
     MaxComponentValue(Abs(p00))   + MaxComponentValue(Abs(p10))   +
     MaxComponentValue(Abs(p01))   + MaxComponentValue(Abs(p11)));
```


=== Discussion
<managing-rounding-error-discussion>


#parec[
  Minimizing and bounding numerical error in other geometric computations (e.g., partial derivatives of surface positions, interpolated texture coordinates, etc.) are much less important than they are for the positions of ray intersections.
][
  在其他几何计算（例如，表面位置的偏导数、插值纹理坐标等）中最小化和界定数值误差远不如射线交点的位置重要。
]

#parec[
  In a similar vein, the computations involving color and light in physically based rendering generally do not present trouble with respect to round-off error; they involve sums of products of positive numbers (usually with reasonably close magnitudes); hence catastrophic cancellation is not a commonly encountered issue.
][
  同样，物理基础渲染中涉及颜色和光的计算通常不会出现舍入误差问题；它们涉及正数的乘积和（通常大小相对接近）；因此灾难性抵消并不是一个常见的问题。
]

#parec[
  Furthermore, these sums are of few enough terms that accumulated error is small: the variance that is inherent in the Monte Carlo algorithms used for them dwarfs any floating-point error in computing them.
][
  此外，这些和的项数很少，因此累积误差很小：用于它们的蒙特卡罗算法中固有的方差远远超过了计算它们时的浮点误差。
]

#parec[
  Interestingly enough, we saw an increase of roughly 20% in overall ray-tracing execution time after replacing the previous version of `pbrt`'s old #emph[ad hoc] method to avoid incorrect self-intersections with the method described in this section.
][
  值得注意的是，在用本节描述的方法替换 `pbrt` 旧的#emph[临时];方法以避免不正确的自交后，我们看到整体光线追踪执行时间增加了大约 20%。
]

#parec[
  (In comparison, rendering with double-precision floating point causes an increase in rendering time of roughly 30%.)
][
  （相比之下，用双精度浮点数渲染会导致渲染时间增加大约 30%。）
]

#parec[
  Profiling showed that very little of the additional time was due to the additional computation to find error bounds; this is not surprising, as the incremental computation our approach requires is limited—most of the error bounds are just scaled sums of absolute values of terms that have already been computed.
][
  分析显示，额外时间中很少部分是由于额外的计算来找到误差界限；这并不令人惊讶，因为我们的方法所需的增量计算是有限的——大多数误差界限只是已经计算出的项的绝对值的缩放和。
]

#parec[
  The majority of this slowdown is due to an increase in ray-object intersection tests.
][
  这种减速的主要原因是光线-物体交点测试的增加。
]

#parec[
  The reason for this increase in intersection tests was first identified by Wächter (2008, p.~30); when ray origins are very close to shape surfaces, more nodes of intersection acceleration hierarchies must be visited when tracing spawned rays than if overly loose offsets are used.
][
  Wächter（2008，第 30 页）首次识别出这种交点测试增加的原因；当光线起点非常接近形状表面时，在追踪生成的光线时必须访问更多的交点加速层次结构节点，而不是使用过于宽松的偏移。
]

#parec[
  Thus, more intersection tests are performed near the ray origin.
][
  因此，在光线起点附近执行了更多的交点测试。
]

#parec[
  While this reduction in performance is unfortunate, it is a direct result of the greater accuracy of the method; it is the price to be paid for more accurate resolution of valid nearby intersections.
][
  虽然这种性能下降令人遗憾，但它是这种方法更高精度的直接结果；这是为更准确地解决有效的附近交点所付出的代价。
]

