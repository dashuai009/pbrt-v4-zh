#import "../template.typ": parec, ez_caption, translator, source-cite
#import "supplements/6.8-source-math.typ": source-math

== #ez_caption[Managing Rounding Error][控制舍入误差]
<managing-rounding-error>

#parec[#emph[This section contains advanced content and may be skipped on a first reading.]][#emph[本节内容较深入，初读时可以跳过。]]

#parec[
  Thus far, we have been discussing ray–shape intersection algorithms with respect to idealized arithmetic operations based on the real numbers. This approach has gotten us far, although the fact that computers can only represent finite quantities and therefore cannot actually represent all the real numbers is important. In place of real numbers, computers use floating-point numbers, which have fixed storage requirements. However, error may be introduced each time a floating-point operation is performed, since the result may not be representable in the designated amount of memory.
][
  此前讨论射线与形状求交算法时，我们假定进行的是基于实数的理想算术运算。这种做法虽已很有成效，但必须注意计算机只能表示有限数量的值，无法表示所有实数。计算机使用占据固定存储空间的浮点数来代替实数。每次浮点运算都可能引入误差，因为精确结果未必能用指定大小的存储空间表示。
]

#parec[
  The accumulation of this error has several implications for the accuracy of intersection tests. First, it is possible that it will cause valid intersections to be missed completely—for example, if a computed intersection’s $t$ value is negative even though the precise value is positive. Furthermore, computed ray–shape intersection points may be above or below the actual surface of the shape. This leads to a problem: when new rays are traced starting from computed intersection points for shadow rays and reflection rays, if the ray origin is below the actual surface, we may find an incorrect reintersection with the surface. Conversely, if the origin is too far above the surface, shadows and reflections may appear detached. (See @fig:fp-isect-errors.)
][
  累积误差会从多方面影响求交精度。首先，它可能导致完全漏掉有效交点，例如精确的 $t$ 为正而计算值为负。其次，计算所得交点可能位于真实表面上方或下方。从这样的点发出阴影射线或反射射线时，若起点低于真实表面，就可能错误地再次与该表面相交；若起点高出表面太多，阴影和反射又可能显得与表面分离（@fig:fp-isect-errors）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f38.svg"), caption:[#ez_caption[Geometric Settings for Rounding-Error Issues That Can Cause Visible Errors in Images. The incident ray on the left intersects the surface. On the left, the computed intersection point (black circle) is slightly below the surface and a too-low “epsilon” offsetting the origin of the shadow ray leads to an incorrect self-intersection, as the shadow ray origin (white circle) is still below the surface; thus the light is incorrectly determined to be occluded. On the right, a too-high “epsilon” causes a valid intersection to be missed as the ray’s origin is past the occluding surface.][舍入误差导致图像错误的几何情形。左：入射射线与表面相交，但计算交点（黑圆点）略低于真实表面；阴影射线起点的 epsilon 偏移过小，偏移后的起点（白圆点）仍在表面下方，于是错误地自相交，将光源误判为被遮挡。右：epsilon 过大，使射线起点越过遮挡表面，从而漏掉有效交点。]]) <fp-isect-errors>

#parec[
  Typical practice to address this issue in ray tracing is to offset spawned rays by a fixed “ray epsilon” value, ignoring any intersections along the ray $p+t bold(d)$ closer than some $t_(min)$ value. @fig:tmin-bad shows why this approach requires fairly high $t_(min)$ values to work effectively: if the spawned ray is oblique to the surface, incorrect ray intersections may occur quite some distance from the ray origin. Unfortunately, large $t_(min)$ values cause ray origins to be relatively far from the original intersection points, which in turn can cause valid nearby intersections to be missed, leading to loss of fine detail in shadows and reflections.
][
  射线追踪中常见的做法是用固定的“射线 epsilon”偏移新射线，忽略沿射线 $p+t bold(d)$ 距离小于某个 $t_(min)$ 的交点。@fig:tmin-bad 说明了为何这一方法需要较大的 $t_(min)$ 才能奏效：射线斜掠表面时，错误交点可能距射线起点相当远。但较大的 $t_(min)$ 又使有效起点远离原交点，可能漏掉附近的有效交点，丢失阴影和反射中的细节。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f39.svg"), caption:[#ez_caption[If the computed intersection point (filled circle) is below the surface and the spawned ray is oblique, incorrect reintersections may occur some distance from the ray origin (open circle). If a minimum $t$ value along the ray is used to discard nearby intersections, a relatively large $t_(min)$ is needed to handle oblique rays well.][若计算交点（实心圆点）位于表面下方，且新射线斜掠表面，错误的再次相交可能发生在距射线起点（空心圆点）较远的位置。因此，若用最小射线参数 t 来忽略附近交点，就需要较大的 $t_(min)$ 才能妥善处理斜掠射线。]]) <tmin-bad>

#parec[
  In this section, we will introduce the ideas underlying floating-point arithmetic and describe techniques for analyzing the error in floating-point computations. We will then apply these methods to the ray–shape algorithms introduced earlier in this chapter and show how to compute ray intersection points with bounded error. This will allow us to conservatively position ray origins so that incorrect self-intersections are never found, while keeping ray origins extremely close to the actual intersection point so that incorrect misses are minimized. In turn, no additional “ray epsilon” values are needed.
][
  本节先介绍浮点算术的基本思想及其误差分析方法，再将它们应用于前述求交算法，计算误差有界的交点。由此可以保守地放置射线起点，避免错误自相交，同时使起点极接近真实交点，尽量减少误漏判，也就无需额外的“射线 epsilon”。
]

=== #ez_caption[Floating-Point Arithmetic][浮点算术]
<floating-point-arithmetic>

#parec[
  Computation must be performed on a finite representation of numbers that fits in a finite amount of memory; the infinite set of real numbers cannot be represented on a computer. One such finite representation is fixed point, where given a 16-bit integer, for example, one might map it to positive real numbers by dividing by 256. This would allow us to represent the range $[0,65535/256]=[0,255+255/256]$ with equal spacing of $1/256$ between values. Fixed-point numbers can be implemented efficiently using integer arithmetic operations (a property that made them popular on early PCs that did not support floating-point computation), but they suffer from a number of shortcomings; among them, the maximum number they can represent is limited, and they are not able to accurately represent very small numbers near zero.
][
  计算必须使用可存入有限内存的有限数值表示，计算机无法表示无限实数集。定点数是一种选择：例如将 16 位整数除以 256，映射到非负实数，可表示范围 $[0,65535/256]=[0,255+255/256]$，相邻值间距均为 $1/256$。定点数可用整数运算高效实现，因此曾广泛用于不支持浮点计算的早期个人计算机。但它有若干缺点，例如最大可表示数值受限，也难以准确表示接近零的很小数值。
]

#parec[
  An alternative representation for real numbers on computers is floating-point numbers. These are based on representing numbers with a sign, a significand,#footnote[The word #emph[mantissa] is often used in place of #emph[significand,] though floating-point purists note that #emph[mantissa] has a different meaning in the context of logarithms and thus prefer #emph[significand]. We follow this usage here.] and an exponent: essentially, the same representation as scientific notation but with a fixed number of digits devoted to significand and exponent. (In the following, we will assume base-2 digits exclusively.) This representation makes it possible to represent and perform computations on numbers with a wide range of magnitudes while using a fixed amount of storage.
][
  浮点数是另一种表示方式，用符号、有效数#footnote[significand 常被称为 mantissa（尾数），但严格区分术语的人指出 mantissa 在对数语境中另有含义，因而更倾向于 significand；本书沿用这一习惯。]及指数表示数值。它本质上与科学记数法相同，但有效数和指数只分配固定的位数。下文仅讨论二进制。这样可以在固定存储量下表示并计算数量级跨度很大的数值。
]

#parec[
  Programmers using floating-point arithmetic are generally aware that floating-point values may be inaccurate; this understanding sometimes leads to a belief that floating-point arithmetic is unpredictable. In this section we will see that floating-point arithmetic has a carefully designed foundation that in turn makes it possible to compute conservative bounds on the error introduced in a particular computation. For ray-tracing calculations, this error is often surprisingly small.
][
  使用浮点算术的程序员通常知道浮点值可能不准确，有时因此认为浮点算术不可预测。但它具有精心设计的基础，可据此计算特定运算所引入误差的保守界。对于射线追踪，这些误差往往小得出人意料。
]

#parec[
  Modern CPUs and GPUs nearly ubiquitously implement a model of floating-point arithmetic based on a standard promulgated by the Institute of Electrical and Electronics Engineers (#source-cite("IEEE1985"), #source-cite("IEEE2008")). (Henceforth when we refer to floats, we will specifically be referring to 32-bit floating-point numbers as specified by IEEE 754.) The IEEE 754 technical standard specifies the format of floating-point numbers in memory as well as specific rules for precision and rounding of floating-point computations; it is these rules that make it possible to reason rigorously about the error present in a computed floating-point value.
][
  现代 CPU 和 GPU 几乎都采用基于电气与电子工程师学会（#source-cite("IEEE1985")；#source-cite("IEEE2008")）标准的浮点算术模型。下文所说的 float 特指 IEEE 754 规定的 32 位浮点数。该标准规定了内存表示以及运算精度和舍入规则，使我们能够严格推导计算所得浮点值的误差。
]

#heading(level: 4, numbering: none)[#ez_caption[Floating-Point Representation][浮点数表示]]

#parec[
  The IEEE standard specifies that 32-bit floats are represented with a sign bit, 8 bits for the exponent, and 23 bits for the significand. The exponent stored in a float ranges from 0 to 255. We will denote it by $e_b$, with the subscript indicating that it is biased; the actual exponent used in computation, $e$, is computed as
][
  IEEE 标准规定，32 位浮点数由 1 个符号位、8 个指数位和 23 个有效数位组成。存储的指数范围为 0 到 255，记为 $e_b$，下标表示它带有偏置；计算中实际使用的指数为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-011.svg", 13.386, 2.509, 0.671, "e equals e Subscript normal b Baseline minus 127 period", display: true) $ <float-exponent-bias>

#parec[
  The significand actually has $24$ bits of precision when a #emph[normalized] floating-point value is stored. When a number expressed with significand and exponent is normalized, there are no leading 0s in the significand. In binary, this means that the leading digit of the significand must be one; in turn, there is no need to store this value explicitly. Thus, the implicit leading 1 digit with the 23 digits encoding the fractional part of the significand gives a total of 24 bits of precision.
][
  正规化浮点数的有效数实际具有 24 位精度。正规化意味着有效数没有前导零；在二进制下，其首位必为 1，因此无需显式存储。这个隐含的前导 1 与存储小数部分的 23 位共同提供 24 位精度。
]

#parec[
  Given a sign $s=plus.minus 1$, significand $m$, and biased exponent $e_b$, the corresponding floating-point value is
][
  给定符号 $s=plus.minus 1$、有效数字段 $m$ 和带偏置指数 $e_b$，对应浮点值为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-016.svg", 18.079, 2.676, 0.338, "s times 1 period m times 2 Superscript e Super Subscript normal b Superscript minus 127 Baseline period", display: true) $

#parec[
  For example, with a normalized significand, the floating-point number 6.5 is written as $1.101_2 times 2^2$, where the 2 subscript denotes a base-2 value. (If non-whole binary numbers are not immediately intuitive, note that the first number to the right of the radix point contributes $2^(-1)=1/2$, and so forth.) Thus, we have
][
  例如，6.5 的正规化表示为 $1.101_2 times 2^2$，下标 2 表示二进制。如果不熟悉带小数的二进制数，可以注意小数点右侧第一位贡献 $2^(-1)=1/2$，以后各位依次类推。因此：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-019.svg", 64.271, 3.176, 0.838, "left-parenthesis 1 times 2 Superscript 0 Baseline plus 1 times 2 Superscript negative 1 Baseline plus 0 times 2 Superscript negative 2 Baseline plus 1 times 2 Superscript negative 3 Baseline right-parenthesis times 2 squared equals 1.625 times 2 squared equals 6.5 period", display: true) $

#parec[
  $e=2$, so $e_b=129=10000001_2$ and $m=10100000000000000000000_2$.
][
  $e=2$，故 $e_b=129=10000001_2$，$m=10100000000000000000000_2$。
]

#parec[
  Floats are laid out in memory with the sign bit at the most significant bit of the 32-bit value (with negative signs encoded with a 1 bit), then the exponent, and the significand. Thus, for the value 6.5 the binary in-memory representation of the value is
][
  浮点数的符号位位于 32 位值的最高位，负号编码为 1；其后依次是指数和有效数字段。6.5 的内存二进制表示为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-023.svg", 53.798, 2.509, 0.671, "0 10000001 10100000000000000000000 equals 40 normal d Baseline 00000 Subscript 16 Baseline period", display: true) $

#parec[
  Similarly, the floating-point value $1.0$ has $m=0 dots.h 0_2$ and $e=0$, so $e_b=127=01111111_2$ and its binary representation is:
][
  同样，浮点值 $1.0$ 对应 $m=0 dots.h 0_2$、$e=0$，因此 $e_b=127=01111111_2$，其二进制表示为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-028.svg", 53.336, 2.509, 0.671, "0 01111111 00000000000000000000000 equals 3 normal f Baseline 800000 Subscript 16 Baseline period", display: true) $

#parec[
  This hexadecimal number is a value worth remembering, as it often comes up in memory dumps when debugging graphics programs.
][
  这个十六进制值值得记住：调试图形程序时，内存转储中经常会出现它。
]

#parec[
  An implication of this representation is that the spacing between representable floats between two adjacent powers of two is uniform throughout the range. (It corresponds to increments of the significand bits by one.) In a range $lr([2^e,2^(e+1)))$, the spacing is
][
  这一表示意味着，相邻两个 2 的幂之间的可表示浮点数等距分布，对应于有效数字段逐次加 1。在区间 $lr([2^e,2^(e+1)))$ 中，其间距为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-030.svg", 5.73, 2.676, 0.338, "2 Superscript e minus 23 Baseline period", display: true) $ <fp-spacing>

#parec[
  Thus, for floating-point numbers between 1 and 2, $e=0$, and the spacing between floating-point values is $2^(-23) approx 1.19209 dots.h times 10^(-7)$. This spacing is also referred to as the magnitude of a #emph[unit in last place] (“ulp”); note that the magnitude of an ulp is determined by the floating-point value that it is with respect to—ulps are relatively larger at numbers with larger magnitudes than they are at numbers with smaller magnitudes.
][
  例如，在 1 到 2 之间，$e=0$，间距为 $2^(-23) approx 1.19209 dots.h times 10^(-7)$。这一间距也称为末位单位（unit in last place，ulp）的大小。ulp 的大小取决于所考察的浮点值：数值绝对值越大，ulp 的绝对大小也越大。
]

#parec[
  As we have described the representation so far, it is impossible to exactly represent zero as a floating-point number. This is obviously an unacceptable state of affairs, so the minimum exponent $e_b=0$, or $e=-127$, is set aside for special treatment. With this exponent, the floating-point value is interpreted as not having the implicit leading 1 bit in the significand, which means that a significand of all 0 bits results in
][
  按目前的描述，浮点数无法精确表示零，这显然不可接受。因此，最小编码指数 $e_b=0$（按偏置关系对应 $e=-127$）保留作特殊处理：此时有效数不再具有隐含的前导 1；若有效数字段也全为零，就得到：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-035.svg", 24.584, 3.009, 0.671, "s times 0.0 midline-horizontal-ellipsis 0 Subscript 2 Baseline times 2 Superscript negative 127 Baseline equals 0 period", display: true) $

#parec[
  Eliminating the leading 1 significand bit also makes it possible to represent #emph[denormalized] numbers:#footnote[Denormalized numbers are also known as #emph[subnormal numbers].] if the leading 1 was always present, then the smallest 32-bit float would be
][
  省略前导 1 还可以表示非正规化数。#footnote[非正规化数（denormalized numbers）也称次正规数（subnormal numbers）。]如果始终保留前导 1，最小的 32 位正浮点数将是：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-036.svg", 37.746, 3.009, 0.671, "1.0 midline-horizontal-ellipsis 0 Subscript 2 Baseline times 2 Superscript negative 127 Baseline almost-equals 5.8774718 times 10 Superscript negative 39 Baseline period", display: true) $

#parec[
  Without the leading 1 bit, the minimum value is
][
  不保留前导 1 时，最小正值为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-037.svg", 54.304, 3.009, 0.671, "0.00 midline-horizontal-ellipsis 1 Subscript 2 Baseline times 2 Superscript negative 126 Baseline equals 2 Superscript negative 23 Baseline times 2 Superscript negative 126 Baseline almost-equals 1.4012985 times 10 Superscript negative 45 Baseline period", display: true) $

#parec[
  (The $-126$ exponent is used because denormalized numbers are encoded with $e_b=0$ but are interpreted as if $e_b=1$ so that there is no excess gap between them and the adjacent smallest regular floating-point number.) Providing some capability to represent these small values can make it possible to avoid needing to round very small values to zero.
][
  这里使用指数 $-126$，是因为非正规化数虽编码为 $e_b=0$，却按 $e_b=1$ 解释，避免它们与相邻最小正规化数之间出现过大的间隙。能够表示这些极小数值，可以避免将它们直接舍入为零。
]

#parec[
  Note that there is both a “positive” and “negative” zero value with this representation. This detail is mostly transparent to the programmer. For example, the standard guarantees that the comparison `-0.0 == 0.0` evaluates to true, even though the in-memory representations of these two values are different. Conveniently, a floating-point zero value with an unset sign bit is represented by the value 0 in memory.
][
  此表示同时包含“正零”和“负零”。多数情况下，程序员无需关心这一区别。例如，尽管二者内存表示不同，标准仍保证 `-0.0 == 0.0` 为真。符号位为零的浮点零，其内存位模式恰好也是整数零。
]

#parec[
  The maximum exponent, $e_b=255$, is also reserved for special treatment. Therefore, the largest regular floating-point value that can be represented has $e_b=254$ (or $e=127$) and is approximately
][
  最大编码指数 $e_b=255$ 同样保留作特殊处理。因此，最大的可表示正规化浮点值具有 $e_b=254$（即 $e=127$），约为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-044.svg", 18.805, 2.676, 0.338, "3.402823 ellipsis times 10 Superscript 38 Baseline period", display: true) $

#parec[
  With $e_b=255$, if the significand bits are all 0, the value corresponds to positive or negative infinity, according to the sign bit. Infinite values result when performing computations like $1/0$ in floating point, for example. Arithmetic operations with infinity and a noninfinite value usually result in infinity, though dividing a finite value by infinity gives 0. For comparisons, positive infinity is larger than any noninfinite value and similarly for negative infinity.
][
  当 $e_b=255$ 且有效数字段全为零时，符号位决定它表示正无穷还是负无穷。浮点计算 $1/0$ 等运算会产生无穷。无穷与非无穷值之间的算术运算通常仍得到无穷，但有限值除以无穷得到零。比较时，正无穷大于任何非无穷数值，而负无穷小于任何非无穷数值。
]

#parec[
  The `Infinity` constant is initialized to be the “infinity” floating-point value. We make it available in a separate constant so that code that uses its value does not need to use the wordy C++ standard library call.
][
  `Infinity` 常量初始化为浮点“无穷”。单独提供此常量，可让调用代码免于书写冗长的 C++ 标准库调用。
]

#block(sticky:true)[#raw("<<Floating-point Constants>>=")] <fragment-Floating-pointConstants-0>
```cpp
static constexpr Float Infinity = std::numeric_limits<Float>::infinity();
```

#parec[
  With $e_b=255$, nonzero significand bits correspond to special “not a number” (NaN) values, which result from invalid operations like taking the square root of a negative number or trying to compute $0/0$. NaNs propagate through computations: any arithmetic operation where one of the operands is a NaN itself always returns NaN. Thus, if a NaN emerges from a long chain of computations, we know that something went awry somewhere along the way. In debug builds, `pbrt` has many assertion statements that check for NaN values, as we almost never expect them to come up in the regular course of events. Any comparison with a NaN value returns false; thus, checking for `!(x == x)` serves to check if a value is not a number.#footnote[This is one of a few places where compilers must not perform seemingly obvious and safe algebraic simplifications with expressions that include floating-point values—this particular comparison must not be simplified to `false`. Enabling compiler “fast math” or “perform unsafe math optimizations” flags may allow these optimizations to be performed. In turn, buggy behavior may be introduced in `pbrt`.]
][
  当 $e_b=255$ 而有效数字段非零时，表示特殊的“非数”（NaN），由负数开平方、$0/0$ 等无效运算产生。NaN 会在计算中传播：只要算术运算的操作数中有 NaN，结果就是 NaN。因此，长计算链末端出现 NaN 表明中途发生了异常。`pbrt` 的调试构建包含大量 NaN 断言，因为正常计算中几乎不应出现 NaN。原文称与 NaN 的任何比较都返回假，因此可用 `!(x == x)` 检测 NaN。#footnote[这里是编译器不能对浮点表达式作看似显然、安全的代数简化的例子：这一比较不能直接化简成 `false`。启用 fast math 或不安全数学优化选项可能允许这些变换，导致 `pbrt` 行为出错。]
]

#parec[
  By default, the majority of floating-point computation in `pbrt` uses 32-bit floats. However, as discussed in Section #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#sec:integrator-intro")[1.3.3], it is possible to configure it to use 64-bit double-precision values instead. In addition to the sign bit, doubles allocate 11 bits to the exponent and 52 to the significand. `pbrt` also supports 16-bit floats (which are known as halfs) as an in-memory representation for floating-point values stored at pixels in images. Halfs use 5 bits for the exponent and 10 for the significand. (A convenience `Half` class, not discussed further in the text, provides capabilities for working with halfs and converting to and from 32-bit floats.)
][
  默认情况下，`pbrt` 大部分浮点计算使用 32 位 float；按第 1.3.3 节的说明，也可以配置为 64 位双精度。double 除符号位外，为指数分配 11 位，有效数字段分配 52 位。图像像素的浮点存储还支持 16 位 half，其指数占 5 位，有效数字段占 10 位。辅助类 `Half` 用于处理半精度值及与 32 位浮点数相互转换，此处不再详述。
]

#translator[原文把所有 NaN 比较都概括为假，严格来说不适用于 !=；这里用于检测 NaN 的 !(x == x) 是有效的。原文零值示意使用指数 -127，后文明确解释次正规数按 -126 解码；零值公式结果不受影响。]

#heading(level: 4, numbering: none)[#ez_caption[Arithmetic Operations][算术运算]]

#parec[
  IEEE 754 provides important guarantees about the properties of floating-point arithmetic: specifically, it guarantees that addition, subtraction, multiplication, division, and square root give the same results given the same inputs and that these results are the floating-point number that is closest to the result of the underlying computation if it had been performed in infinite-precision arithmetic.#footnote[IEEE float allows the user to select one of a number of rounding modes, but we will assume the default—round to nearest even—here.] It is remarkable that this is possible on finite-precision digital computers at all; one of the achievements in IEEE 754 was the demonstration that this level of accuracy is possible and can be implemented fairly efficiently in hardware.
][
  IEEE 754 对浮点算术给出了重要保证：相同输入的加、减、乘、除与平方根运算应得到相同结果，而且结果应是最接近无限精度运算结果的可表示浮点数。#footnote[IEEE 浮点标准允许选择多种舍入模式；这里采用默认的舍入到最近值，恰好居中时取末位为偶数的值。]有限精度数字计算机能做到这一点，本身就很了不起；IEEE 754 的成就之一，就是证明了这种精度可达，并可在硬件中高效实现。
]

#parec[
  Using circled operators to denote floating-point arithmetic operations and $upright("sqrt")$ for floating-point square root, these accuracy guarantees can be written as:
][
  用带圈运算符表示浮点算术，用 `sqrt` 表示浮点平方根，这些精度保证可写为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-050.svg", 32.62, 22.509, 10.671, "StartLayout 1st Row 1st Column a circled-plus b 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a plus b right-parenthesis 2nd Row 1st Column a minus b 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a minus b right-parenthesis 3rd Row 1st Column a circled-times b 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a asterisk b right-parenthesis 4th Row 1st Column a circled-division-slash b 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a slash b right-parenthesis 5th Row 1st Column monospace s monospace q monospace r monospace t monospace left-parenthesis monospace a monospace right-parenthesis 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis StartRoot a EndRoot right-parenthesis 6th Row 1st Column monospace upper F monospace upper M monospace upper A monospace left-parenthesis monospace a monospace comma monospace b monospace comma monospace c monospace right-parenthesis 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a asterisk b plus c right-parenthesis EndLayout", display: true) $ <ieee-arith-op-rounding>

#parec[
  where $upright("round")(x)$ indicates the result of rounding a real number to the closest floating-point value and where $upright("FMA")$ denotes the #emph[fused multiply add] operation, which only rounds once. It thus gives better accuracy than computing $(a ⊗ b) ⊕ c$.
][
  其中 $upright("round")(x)$ 表示将实数舍入到最近的浮点值；`FMA` 表示融合乘加，只进行一次舍入，因此比 $(a ⊗ b) ⊕ c$ 更准确。
]

#parec[
  This bound on the rounding error can also be represented with an interval of real numbers: for example, for addition, we can say that the rounded result is within an interval
][
  舍入误差界也可用实数区间表示。例如，加法的舍入结果落在以下区间内：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-054.svg", 38.512, 6.509, 2.671, "StartLayout 1st Row 1st Column a circled-plus b 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a plus b right-parenthesis element-of left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus-or-minus epsilon right-parenthesis 2nd Row 1st Column Blank 2nd Column equals left-bracket left-parenthesis a plus b right-parenthesis left-parenthesis 1 minus epsilon right-parenthesis comma left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus epsilon right-parenthesis right-bracket EndLayout", display: true) $ <fp-add-error-bounds>

#parec[
  for some $epsilon$. The amount of error introduced from this rounding can be no more than half the floating-point spacing at $a+b$—if it was more than half the floating-point spacing, then it would be possible to round to a different floating-point number with less error (@fig:fp-rounding).
][
  其中 $epsilon$ 表示某个误差。舍入引入的误差至多为 $a+b$ 处浮点间距的一半；否则，总能找到另一个误差更小的浮点数（@fig:fp-rounding）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f40.svg"), caption:[#ez_caption[The IEEE standard specifies that floating-point calculations must be implemented as if the calculation was performed with infinite-precision real numbers and then rounded to the nearest representable float. Here, an infinite-precision result in the real numbers is denoted by a filled dot, with the representable floats around it denoted by ticks on a number line. We can see that the error introduced by rounding to the nearest float, $delta$, can be no more than half the spacing between floats.][IEEE 标准要求，浮点计算的结果必须等同于先进行无限精度实数运算，再舍入到最近的可表示浮点数。图中实心点为精确实数结果，数轴刻度为附近的可表示浮点值。舍入误差 $delta$ 至多为浮点间距的一半。]]) <fp-rounding>

#parec[
  For 32-bit floats, we can bound the floating-point spacing at $a+b$ from above using @eqt:fp-spacing (i.e., an ulp at that value) by $(a+b)2^(-23)$, so half the spacing is bounded from above by $(a+b)2^(-24)$ and so $abs(epsilon)<=2^(-24)$. This bound is the #emph[machine epsilon].#footnote[The C and C++ standards define the machine epsilon as the magnitude of one ulp above the number 1. For a 32-bit float, this value is $2^(-23)$, which is twice as large as the machine epsilon as the term is generally used in numerical analysis.] For 32-bit floats, $epsilon_m=2^(-24) approx 5.960464 dots.h times 10^(-8)$.
][
  对于 32 位浮点数，由@eqt:fp-spacing，$a+b$ 处的间距（即一个 ulp）可从上方界定为 $(a+b)2^(-23)$，半个间距的上界为 $(a+b)2^(-24)$，故 $abs(epsilon) <= 2^(-24)$。这个界称为机器 epsilon。#footnote[C 和 C++ 将机器 epsilon 定义为 1 上方一个 ulp 的大小；对 32 位 float，它等于 $2^(-23)$，是数值分析中通常所用机器 epsilon 的两倍。]对于 32 位 float，$epsilon_m=2^(-24) approx 5.960464 dots.h times 10^(-8)$。
]

#block(sticky:true)[#raw("<<Floating-point Constants>>+=")] <fragment-Floating-pointConstants-1>
```cpp
static constexpr Float MachineEpsilon =
    std::numeric_limits<Float>::epsilon() * 0.5;
```

#parec[
  Thus, we have
][
  因此有：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-063.svg", 42.361, 6.509, 2.671, "StartLayout 1st Row 1st Column a circled-plus b 2nd Column equals normal r normal o normal u normal n normal d left-parenthesis a plus b right-parenthesis element-of left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis 2nd Row 1st Column Blank 2nd Column equals left-bracket left-parenthesis a plus b right-parenthesis left-parenthesis 1 minus epsilon Subscript normal m Baseline right-parenthesis comma left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus epsilon Subscript normal m Baseline right-parenthesis right-bracket period EndLayout", display: true) $

#parec[
  Analogous relations hold for the other arithmetic operators and the square root operator.#footnote[This bound assumes that there is no overflow or underflow in the computation; these possibilities can be easily handled (Higham 2002, p. 56) but are not generally important for our application here.]
][
  其他算术运算与平方根也满足类似关系。#footnote[这里假设计算没有上溢或下溢；处理这些情况并不困难（Higham 2002，第 56 页），但对这里的应用通常不重要。]
]

#parec[
  A number of useful properties follow directly from @eqt:ieee-arith-op-rounding. For a floating-point number $x$,
][
  @eqt:ieee-arith-op-rounding 直接给出了若干有用性质。对于浮点数 $x$：
]

#parec[
- $1 ⊗ x=x$.
- $x ⊘ x=1$.
- $x ⊕ 0=x$.
- $x ⊖ x=0$.
- $2 ⊗ x$ and $x ⊘ 2$ are exact; no rounding is performed to compute the final result. More generally, any multiplication by or division by a power of two gives an exact result (assuming there is no overflow or underflow).
- $x ⊘ 2^i=x ⊗ 2^(-i)$ for all integer $i$, assuming $2^i$ does not overflow.
][
- $1 ⊗ x=x$。
- $x ⊘ x=1$。
- $x ⊕ 0=x$。
- $x ⊖ x=0$。
- $2 ⊗ x$ 与 $x ⊘ 2$ 的结果精确，不需要舍入。更一般地，在没有上溢或下溢时，乘以或除以 2 的幂均给出精确结果。
- 对所有整数 $i$，只要 $2^i$ 不上溢，就有 $x ⊘ 2^i=x ⊗ 2^(-i)$。
]

#parec[
  All of these properties follow from the principle that the result must be the nearest floating-point value to the actual result; when the result can be represented exactly, the exact result must be computed.
][
  这些性质都来自同一原则：结果必须是离精确结果最近的浮点值；能精确表示时，就必须返回精确结果。
]

#heading(level: 4, numbering: none)[#ez_caption[Utility Routines][辅助函数]]

#parec[
  A few basic utility routines will be useful in the following. First, we define our own `IsNaN()` function to check for NaN values. It comes with the baggage of a use of C++’s `enable_if` construct to declare its return type in a way that requires that this function only be called with floating-point types.
][
  以下会用到若干基础辅助函数。首先定义 `IsNaN()` 检查 NaN。其返回类型使用 C++ 的 `enable_if`，限制此版本只接受浮点类型。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>=")] <fragment-Floating-pointInlineFunctions-0>
```cpp
template <typename T> inline
typename std::enable_if_t<std::is_floating_point_v<T>, bool>
IsNaN(T v) {
    return std::isnan(v);
}
```

#parec[
  We also define `IsNaN()` for integer-based types; it trivially returns `false`, since NaN is not representable in those types. One might wonder why we have bothered with `enable_if` and this second definition that tells us something that we already know. One motivation is the templated #link("https://pbr-book.org/4ed/Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple2")[`Tuple2`] and #link("https://pbr-book.org/4ed/Geometry_and_Transformations/n-Tuple_Base_Classes.html#Tuple3")[`Tuple3`] classes from Section #link("https://pbr-book.org/4ed/Geometry_and_Transformations/n-Tuple_Base_Classes.html#sec:ntuple")[3.2], which are used with both #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Float")[`Float`] and `int` for their element types. Given these two functions, they can freely have assertions that their elements do not store NaN values without worrying about which particular type their elements are.
][
  整数类型也有一个 `IsNaN()` 版本，直接返回 `false`，因为整数类型无法表示 NaN。使用 `enable_if` 并提供这个看似多余的重载，原因之一是第 3.2 节的 `Tuple2`、`Tuple3` 模板既用于 `Float` 元素，也用于 `int` 元素。有了这两个函数，模板就可以统一断言元素不是 NaN，而无需区分具体类型。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-1>
```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, bool>
IsNaN(T v) { return false; }
```

#parec[
  For similar motivations, we define a pair of `IsInf()` functions that test for infinity.
][
  出于同样的原因，定义两个 `IsInf()` 重载检查无穷值。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-2>
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
  由于整数类型无法表示无穷，整数版本仍直接返回 `false`。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-3>
```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, bool>
IsInf(T v) { return false; }
```

#parec[
  A pair of `IsFinite()` functions check whether a number is neither infinite or NaN.
][
  两个 `IsFinite()` 重载检查数值是否既非无穷也非 NaN。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-4>
```cpp
template <typename T> inline
typename std::enable_if_t<std::is_floating_point_v<T>, bool>
IsFinite(T v) {
    return std::isfinite(v);
}
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, bool>
IsFinite(T v) { return true; }
```

#parec[
  Although fused multiply add is available through the standard library, we also provide our own `FMA()` function.
][
  标准库虽提供融合乘加，我们仍定义自己的 `FMA()` 函数。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-5>
```cpp
float FMA(float a, float b, float c) { return std::fma(a, b, c); }
```

#parec[
  A separate version for integer types allows calling `FMA()` from code regardless of the numeric type being used.
][
  另提供整数类型版本，使调用 `FMA()` 的代码无需区分具体数值类型。
]

#block(sticky:true)[#raw("<<Math Inline Functions>>+=")] <fragment-MathInlineFunctions-1>
```cpp
template <typename T> inline
typename std::enable_if_t<std::is_integral_v<T>, T>
FMA(T a, T b, T c) { return a * b + c; }
```

#parec[
  For certain low-level operations, it can be useful to be able to interpret a floating-point value in terms of its constituent bits and to convert the bits representing a floating-point value to an actual `float` or `double`. A natural approach to this would be to take a pointer to a value to be converted and cast it to a pointer to the other type:
][
  某些底层操作需要将浮点值解释为组成它的位，或将这样的位模式转换回 `float`、`double`。一种看似自然的方法，是获取待转换值的指针，再将它转为另一类型的指针：
]

```cpp
float f = ...;
uint32_t bits = *((uint32_t *)&f);
``` <rounding-example-8>

#parec[
  However, modern versions of C++ specify that it is illegal to cast a pointer of one type, `float`, to a different type, `uint32_t`. (This restriction allows the compiler to optimize more aggressively in its analysis of whether two pointers may point to the same memory location, which can inhibit storing values in registers.) Another popular alternative, using a `union` with elements of both types, assigning to one type and reading from the other, is also illegal: the C++ standard says that reading an element of a union different from the last one assigned to is undefined behavior.
][
  但原文指出，现代 C++ 不允许以这种方式将 `float` 类型指针用于 `uint32_t` 类型访问。这个限制便于编译器分析两个指针是否可能指向同一内存位置，并进行更积极的优化；潜在别名会妨碍将值保存在寄存器中。另一种常见办法是使用含两种类型成员的 `union`，写入一种成员再读另一种；标准规定，读取非最后写入成员的值属于未定义行为。
]

#parec[
  Fortunately, as of C++20, the standard library provides a `std::bit_cast` function that performs such conversions. Because this version of `pbrt` only requires C++17, we provide an implementation in the `pstd` library that is used by the following conversion functions.
][
  C++20 开始，标准库提供 `std::bit_cast` 来完成这种转换。本版 `pbrt` 只要求 C++17，因此在 `pstd` 中提供相应实现，供下列函数使用。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-6>
```cpp
inline uint32_t FloatToBits(float f) {
    return pstd::bit_cast<uint32_t>(f);
}
```

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-7>
```cpp
inline float BitsToFloat(uint32_t ui) {
    return pstd::bit_cast<float>(ui);
}
```

#parec[
  (Versions of these functions that convert between `double` and `uint64_t` are also available but are similar and are therefore not included here.)
][
  另有 `double` 与 `uint64_t` 之间转换的版本，因实现相似，此处不列出。
]

#parec[
  The corresponding integer type with a sufficient number of bits to store `pbrt`’s #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#Float")[`Float`] type is available through `FloatBits`.
][
  `FloatBits` 给出位数足以容纳 `pbrt` 的 `Float` 位模式的对应整数类型。
]

#block(sticky:true)[#raw("<<Float Type Definitions>>+=")] <fragment-FloatTypeDefinitions-1>
```cpp
#ifdef PBRT_FLOAT_AS_DOUBLE
using FloatBits = uint64_t;
#else
using FloatBits = uint32_t;
#endif  // PBRT_FLOAT_AS_DOUBLE
```

#parec[
  Given the ability to extract the bits of a floating-point value and given the description of their layout in @floating-point-arithmetic, it is easy to extract various useful quantities from a float.
][
  能够提取浮点位模式后，结合@floating-point-arithmetic 的内存布局，就很容易从 float 中提取一些有用信息。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-8>
```cpp
inline int Exponent(float v) { return (FloatToBits(v) >> 23) - 127; }
```

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-9>
```cpp
inline int Significand(float v) { return FloatToBits(v) & ((1 << 23) - 1); }
```

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-10>
```cpp
inline uint32_t SignBit(float v) { return FloatToBits(v) & 0x80000000; }
```

#parec[
  These conversions can be used to implement functions that bump a floating-point value up or down to the next greater or next smaller representable floating-point value.#footnote[These functions are equivalent to `std::nextafter(v, Infinity)` and `std::nextafter(v, -Infinity)`, but are more efficient since they do not try to handle NaN values or deal with signaling floating-point exceptions.] They are useful for some conservative rounding operations that we will need in code to follow. Thanks to the specifics of the in-memory representation of floats, these operations are quite efficient.
][
  这些转换可用于将浮点值增加或减小到相邻的更大或更小可表示值。#footnote[这些函数等价于 `std::nextafter(v, Infinity)` 与 `std::nextafter(v, -Infinity)`，但不处理 NaN 或浮点异常信号，因此更高效。]后续保守舍入会用到它们；得益于浮点数内存表示的设计，实现相当高效。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-11>
```cpp
inline float NextFloatUp(float v) {
    <<Handle infinity and negative zero for NextFloatUp()>> 
    <<Advance v to next higher float>> 
}
```

#parec[
  There are two important special cases: first, if `v` is positive infinity, then this function just returns `v` unchanged. Second, negative zero is skipped forward to positive zero before continuing on to the code that advances the significand. This step must be handled explicitly, since the bit patterns for $-0.0$ and $0.0$ are not adjacent.
][
  有两个特殊情况。若 `v` 为正无穷，直接原样返回。若为负零，则先换成正零，再推进有效数。由于负零与正零的位模式并不相邻，必须显式处理这一步。
]

#block(sticky:true)[#raw("<<Handle infinity and negative zero for NextFloatUp()>>=")] <fragment-HandleinfinityandnegativezeroformonoNextFloatUp-0>
```cpp
if (IsInf(v) && v > 0.f)
    return v;
if (v == -0.f)
    v = 0.f;
```

#parec[
  Conceptually, given a floating-point value, we would like to increase the significand by one, where if the result overflows, the significand is reset to zero and the exponent is increased by one. Fortuitously, adding one to the in-memory integer representation of a float achieves this: because the exponent lies at the high bits above the significand, adding one to the low bit of the significand will cause a one to be carried all the way up into the exponent if the significand is all ones and otherwise will advance to the next higher significand for the current exponent. (This is yet another example of the careful thought that was applied to the development of the IEEE floating-point specification.) Note also that when the highest representable finite floating-point value’s bit representation is incremented, the bit pattern for positive floating-point infinity is the result.
][
  概念上，要把有效数字段加 1；若溢出，则将字段归零并把指数加 1。恰好，对内存中的整数位模式加 1 就能完成这件事：指数位于有效数字段上方，若有效数字段全为 1，进位会传递到指数；否则只推进到当前指数下的下一个有效数。这再次体现 IEEE 浮点规范的周密设计。最大有限浮点值的位模式加 1 后，恰好得到正无穷的位模式。
]

#parec[
  For negative values, subtracting one from the bit representation similarly advances to the next higher value.
][
  对于负数，位模式减 1 则同样得到下一个更大的数值。
]

#block(sticky:true)[#raw("<<Advance v to next higher float>>=")] <fragment-Advancemonovtonexthigherfloat-0>
```cpp
uint32_t ui = FloatToBits(v);
if (v >= 0) ++ui;
else        --ui;
return BitsToFloat(ui);
```

#parec[
  The `NextFloatDown()` function, not included here, follows the same logic but effectively in reverse. `pbrt` also provides versions of these functions for `double`s.
][
  正文未列出的 `NextFloatDown()` 使用基本相反的逻辑。`pbrt` 也提供这些函数的 double 版本。
]

#translator[原文的相对误差区间写法默认数值尺度非负；对负数解释区间时需交换端点，间距上界应取数值的绝对值。列举的 x/x=1 等恒等式也需排除零、NaN 和无穷等使运算无定义的情况。源式按原样保留。]
#translator[原文指针段的风险在于通过不兼容类型的指针读取对象，单独进行指针类型转换不等于发生未定义行为。原文 Exponent(float) 直接右移而未屏蔽符号位，对负输入会包含符号位贡献；这里保留固定源码，不把它宣称为适用于所有输入的无条件指数提取。]

#heading(level: 4, numbering: none)[#ez_caption[Error Propagation][误差传播]]
<error-propagation>

#parec[
  Using the guarantees of IEEE floating-point arithmetic, it is possible to develop methods to analyze and bound the error in a given floating-point computation. For more details on this topic, see the excellent book by Higham (#source-cite("Higham2002")), as well as Wilkinson’s earlier classic (#source-cite("Wilkinson1994")).
][
  借助 IEEE 浮点算术的保证，可以分析并界定给定浮点计算的误差。进一步说明见 Higham（#source-cite("Higham2002")）的著作及 Wilkinson（#source-cite("Wilkinson1994")）的早期经典。
]

#parec[
  Two measurements of error are useful in this effort: absolute and relative. If we perform some floating-point computation and get a rounded result #source-math("/chapter-6-Shapes/supplements/6.8-math/source-076.svg", 1.23, 2.343, 0.338, "a overTilde"), we say that the magnitude of the difference between #source-math("/chapter-6-Shapes/supplements/6.8-math/source-077.svg", 1.23, 2.343, 0.338, "a overTilde") and the result of doing that computation in the real numbers is the #emph[absolute error], #source-math("/chapter-6-Shapes/supplements/6.8-math/source-078.svg", 2.087, 2.509, 0.671, "delta Subscript normal a"):
][
  这里有两种有用的误差度量：绝对误差与相对误差。设浮点计算的舍入结果为 $tilde(a)$，实数精确结果为 $a$，二者差的绝对值称为绝对误差 $delta_a$：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-079.svg", 12.426, 2.843, 0.838, "delta Subscript normal a Baseline equals StartAbsoluteValue a overTilde minus a EndAbsoluteValue period", display: true) $

#parec[
  #emph[Relative error], #source-math("/chapter-6-Shapes/supplements/6.8-math/source-080.svg", 1.909, 2.509, 0.671, "delta Subscript normal r"), is the ratio of the absolute error to the precise result:
][
  相对误差 $delta_r$ 是绝对误差与精确结果绝对值的比：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-081.svg", 20.786, 6.176, 2.505, "delta Subscript normal r Baseline equals StartAbsoluteValue StartFraction a overTilde minus a Over a EndFraction EndAbsoluteValue equals StartAbsoluteValue StartFraction delta Subscript normal a Baseline Over a EndFraction EndAbsoluteValue comma", display: true) $ <relative-error>

#parec[
  as long as #source-math("/chapter-6-Shapes/supplements/6.8-math/source-082.svg", 5.491, 2.843, 0.838, "a not-equals 0"). Using the definition of relative error, we can thus write the computed value #source-math("/chapter-6-Shapes/supplements/6.8-math/source-083.svg", 1.23, 2.343, 0.338, "a overTilde") as a perturbation of the exact result #source-math("/chapter-6-Shapes/supplements/6.8-math/source-084.svg", 1.23, 1.676, 0.338, "a"):
][
  这里要求 $a != 0$。由相对误差定义，可将计算值 $tilde(a)$ 写为精确值 $a$ 的扰动：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-085.svg", 22.924, 2.843, 0.838, "a overTilde element-of a plus-or-minus delta Subscript normal a Baseline equals a left-parenthesis 1 plus-or-minus delta Subscript normal r Baseline right-parenthesis period", display: true) $

#parec[
  As a first application of these ideas, consider computing the sum of four numbers, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-086.svg", 1.23, 1.676, 0.338, "a"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-087.svg", 0.998, 2.176, 0.338, "b"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-088.svg", 1.007, 1.676, 0.338, "c"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-089.svg", 1.209, 2.176, 0.338, "d"), represented as floats. If we compute this sum as `r = (((a + b) + c) + d)`, @eqt:fp-add-error-bounds gives us
][
  先考虑四个浮点数 $a$、$b$、$c$、$d$ 求和。若按 `r = (((a + b) + c) + d)` 计算，由@eqt:fp-add-error-bounds 有：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-090.svg", 67.258, 6.843, 2.838, "StartLayout 1st Row 1st Column left-parenthesis left-parenthesis left-parenthesis a circled-plus b right-parenthesis circled-plus c right-parenthesis circled-plus d right-parenthesis 2nd Column element-of left-parenthesis left-parenthesis left-parenthesis left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis right-parenthesis plus c right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis plus d right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis 2nd Row 1st Column Blank 2nd Column equals left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus c left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared plus d left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis period EndLayout", display: true) $

#parec[
  Because #source-math("/chapter-6-Shapes/supplements/6.8-math/source-091.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m") is small, higher-order powers of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-092.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m") can be bounded by an additional #source-math("/chapter-6-Shapes/supplements/6.8-math/source-093.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m") term, and so we can bound the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-094.svg", 9.576, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n") terms with
][
  由于 $epsilon_m$ 很小，可以用额外一个 $epsilon_m$ 项来界定更高次幂之和，从而用下式包围 $(1 plus.minus epsilon_m)^n$：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-095.svg", 28.885, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n Baseline less-than-or-equal-to left-parenthesis 1 plus-or-minus left-parenthesis n plus 1 right-parenthesis epsilon Subscript normal m Baseline right-parenthesis period", display: true) $

#parec[
  (As a practical matter, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-096.svg", 9.752, 2.843, 0.838, "left-parenthesis 1 plus-or-minus n epsilon Subscript normal m Baseline right-parenthesis") almost bounds these terms, since higher powers of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-097.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m") get very small very quickly, but the above is a fully conservative bound.)
][
  实际上，$(1 plus.minus n epsilon_m)$ 已经几乎能包围这些项，因为高次幂迅速减小；但上式给出完全保守的界。
]

#translator([前面的 $(1 plus.minus (n+1)epsilon_m)$ 界用于四数求和示例中的小指数，不能仅凭 $epsilon_m$ 很小就推广到任意 $n$。后文给出的 $gamma_n$ 界才明确带有 $n epsilon_m<1$ 的条件。], en: [The preceding $(1 plus.minus (n+1)epsilon_m)$ bound applies to the small exponents in the four-term example; a small $epsilon_m$ alone does not make it valid for arbitrary $n$. The later $gamma_n$ bound explicitly requires $n epsilon_m<1$.])

#parec[
  This bound lets us simplify the result of the addition to:
][
  用这个界，可以将求和结果简化为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-098.svg", 63.244, 6.509, 2.671, "StartLayout 1st Row 1st Column left-parenthesis a plus b right-parenthesis left-parenthesis 1 plus-or-minus 4 epsilon Subscript normal m Baseline right-parenthesis 2nd Column plus c left-parenthesis 1 plus-or-minus 3 epsilon Subscript normal m Baseline right-parenthesis plus d left-parenthesis 1 plus-or-minus 2 epsilon Subscript normal m Baseline right-parenthesis equals 2nd Row 1st Column Blank 2nd Column a plus b plus c plus d plus left-bracket plus-or-minus 4 epsilon Subscript normal m Baseline left-parenthesis a plus b right-parenthesis plus-or-minus 3 epsilon Subscript normal m Baseline c plus-or-minus 2 epsilon Subscript normal m Baseline d right-bracket period EndLayout", display: true) $

#parec[
  The term in square brackets gives the absolute error: its magnitude is bounded by
][
  方括号项给出了绝对误差，其大小不超过：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-099.svg", 28.615, 2.843, 0.838, "4 epsilon Subscript normal m Baseline StartAbsoluteValue a plus b EndAbsoluteValue plus 3 epsilon Subscript normal m Baseline StartAbsoluteValue c EndAbsoluteValue plus 2 epsilon Subscript normal m Baseline StartAbsoluteValue d EndAbsoluteValue period", display: true) $ <add-4-error>

#parec[
  Thus, if we add four floating-point numbers together with the above parenthesization, we can be certain that the difference between the final rounded result and the result we would get if we added them with infinite-precision real numbers is bounded by @eqt:add-4-error; this error bound is easily computed given specific values of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-100.svg", 1.23, 1.676, 0.338, "a"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-101.svg", 0.998, 2.176, 0.338, "b"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-102.svg", 1.007, 1.676, 0.338, "c"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-103.svg", 1.209, 2.176, 0.338, "d").
][
  因此，按上述括号顺序相加四个浮点数时，最终舍入结果与无限精度实数结果的差一定受@eqt:add-4-error 约束。给定 $a$、$b$、$c$、$d$，即可很容易地计算这个界。
]

#parec[
  This is a fairly interesting result; we see that the magnitude of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-104.svg", 5.068, 2.343, 0.505, "a plus b") makes a relatively large contribution to the error bound, especially compared to #source-math("/chapter-6-Shapes/supplements/6.8-math/source-105.svg", 1.209, 2.176, 0.338, "d"). (This result gives a sense for why, if adding a large number of floating-point numbers together, sorting them from small to large magnitudes generally gives a result with a lower final error than an arbitrary ordering.)
][
  可以看到，$a+b$ 的大小对误差界的贡献较大，尤其相对于 $d$ 而言。这也说明为什么对大量浮点数求和时，先按绝对值从小到大排序，通常比任意顺序求和具有更小的最终误差。
]

#parec[
  Our analysis here has implicitly assumed that the compiler would generate instructions according to the expression used to define the sum. Compilers are required to follow the form of the given floating-point expressions in order to not break carefully crafted computations that may have been designed to minimize round-off error. Here again is a case where certain transformations that would be valid on expressions with integers cannot be safely applied when floats are involved.
][
  这里隐含假定编译器按所写的表达式生成指令。编译器必须遵循浮点表达式的运算形式，以免破坏为减小舍入误差而精心安排的计算。这再次说明，某些对整数表达式有效的变换不能安全地用于浮点表达式。
]

#parec[
  What happens if we change the expression to the algebraically equivalent `float r = (a + b) + (c + d)`? This corresponds to the floating-point computation
][
  若改用代数上等价的 `float r = (a + b) + (c + d)`，会怎样？它对应以下浮点运算：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-106.svg", 19.039, 2.843, 0.838, "left-parenthesis left-parenthesis a circled-plus b right-parenthesis circled-plus left-parenthesis c circled-plus d right-parenthesis right-parenthesis period", display: true) $

#parec[
  If we use the same process of applying @eqt:fp-add-error-bounds, expanding out terms, converting higher-order #source-math("/chapter-6-Shapes/supplements/6.8-math/source-107.svg", 9.576, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n") terms to #source-math("/chapter-6-Shapes/supplements/6.8-math/source-108.svg", 15.564, 2.843, 0.838, "left-parenthesis 1 plus-or-minus left-parenthesis n plus 1 right-parenthesis epsilon Subscript normal m Baseline right-parenthesis"), we get absolute error bounds of
][
  沿用同一方法：应用@eqt:fp-add-error-bounds、展开各项，再将高次项 $(1 plus.minus epsilon_m)^n$ 归入 $(1 plus.minus (n+1)epsilon_m)$，得到绝对误差界：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-109.svg", 23.614, 2.843, 0.838, "3 epsilon Subscript normal m Baseline StartAbsoluteValue a plus b EndAbsoluteValue plus 3 epsilon Subscript normal m Baseline StartAbsoluteValue c plus d EndAbsoluteValue comma", display: true) $

#parec[
  which are lower than the first formulation if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-110.svg", 6.361, 2.843, 0.838, "StartAbsoluteValue a plus b EndAbsoluteValue") is relatively large, but possibly higher if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-111.svg", 6.35, 2.843, 0.838, "StartAbsoluteValue c plus d EndAbsoluteValue") is relatively large.
][
  当 $abs(a+b)$ 较大时，这个界小于前一种计算顺序的界；但若 $abs(c+d)$ 较大，则也可能更大。
]

#parec[
  This approach to computing error is known as #emph[forward error analysis]; given inputs to a computation, we can apply a fairly mechanical process that provides conservative bounds on the error in the result. The derived bounds in the result may overstate the actual error—in practice, the signs of the error terms are often mixed, so that there is cancellation when they are added.#footnote[Some numerical analysts use a rule of thumb that the number of ulps of error in practice is often close to the square root of the bound’s number of ulps, thanks to the cancellation of error in intermediate results.] An alternative approach is #emph[backward error analysis], which treats the computed result as exact and finds bounds on perturbations on the inputs that give the same result. This approach can be more useful when analyzing the stability of a numerical algorithm but is less applicable to deriving conservative error bounds on the geometric computations we are interested in here.
][
  这称为前向误差分析：给定输入，便能通过相当机械的过程推导结果误差的保守界。推导的界可能高估实际误差，因为实际误差项常有正有负，相加时会部分抵消。#footnote[一些数值分析人员使用这样的经验法则：由于中间误差部分抵消，实际误差的 ulp 数往往接近误差界所给 ulp 数的平方根。]另一方法是后向误差分析：把计算结果当作精确结果，寻找能产生相同结果的输入扰动界。它更适合分析数值算法的稳定性，但不太适合这里几何计算所需的保守结果误差界。
]

#parec[
  The conservative bounding of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-112.svg", 9.576, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n") by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-113.svg", 15.564, 2.843, 0.838, "left-parenthesis 1 plus-or-minus left-parenthesis n plus 1 right-parenthesis epsilon Subscript normal m Baseline right-parenthesis") is somewhat unsatisfying since it adds a whole #source-math("/chapter-6-Shapes/supplements/6.8-math/source-114.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m") term purely to conservatively bound the sum of various higher powers of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-115.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m"). Higham (#source-cite("Higham2002"), Section 3.1) gives an approach to more tightly bound products of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-116.svg", 8.357, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis") error terms. If we have #source-math("/chapter-6-Shapes/supplements/6.8-math/source-117.svg", 9.576, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n"), it can be shown that this value is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-118.svg", 6.312, 2.509, 0.671, "1 plus theta Subscript n"), where
][
  用 $(1 plus.minus (n+1)epsilon_m)$ 包围 $(1 plus.minus epsilon_m)^n$ 不够紧，因为只是为包围各高次幂之和，就额外加入了整个 $epsilon_m$ 项。Higham（#source-cite("Higham2002")，第 3.1 节）给出了更紧的乘积误差界：$(1 plus.minus epsilon_m)^n$ 可写入 $1+theta_n$，其中：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-119.svg", 16.514, 5.009, 2.171, "StartAbsoluteValue theta Subscript n Baseline EndAbsoluteValue less-than-or-equal-to StartFraction n epsilon Subscript normal m Baseline Over 1 minus n epsilon Subscript normal m Baseline EndFraction comma", display: true) $ <higham-error-prod-bounds>

#parec[
  as long as #source-math("/chapter-6-Shapes/supplements/6.8-math/source-120.svg", 8.588, 2.509, 0.671, "n epsilon Subscript normal m Baseline less-than 1") (which will certainly be the case for the calculations we consider). Note that the denominator of this expression will be just less than one for reasonable #source-math("/chapter-6-Shapes/supplements/6.8-math/source-121.svg", 1.395, 1.676, 0.338, "n") values, so it just barely increases #source-math("/chapter-6-Shapes/supplements/6.8-math/source-122.svg", 3.94, 2.009, 0.671, "n epsilon Subscript normal m") to achieve a conservative bound.
][
  条件是 $n epsilon_m<1$，这里的计算都满足这一条件。对于合理的 $n$，分母只比 1 小一点，因此仅略微放大 $n epsilon_m$ 就能得到保守界。
]

#parec[
  We will denote this bound by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-123.svg", 2.423, 2.176, 0.838, "gamma Subscript n"):
][
  将这个界记为 $gamma_n$：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-124.svg", 15.334, 5.009, 2.171, "gamma Subscript n Baseline equals StartFraction n epsilon Subscript normal m Baseline Over 1 minus n epsilon Subscript normal m Baseline EndFraction period", display: true) $

#parec[
  The function that computes its value is declared as `constexpr` so that any invocations with compile-time constants will be replaced with the corresponding floating-point return value.
][
  计算其值的函数声明为 `constexpr`，因此以编译期常量调用时，可在编译期替换为相应浮点返回值。
]

#block(sticky:true)[#raw("<<Floating-point Inline Functions>>+=")] <fragment-Floating-pointInlineFunctions-12>
```cpp
inline constexpr Float gamma(int n) {
    return (n * MachineEpsilon) / (1 - n * MachineEpsilon);
}
```

#parec[
  Using the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-125.svg", 1.262, 2.176, 0.838, "gamma") notation, our bound on the error of the first sum of four values is
][
  用 $gamma$ 记号，第一个四数求和的误差界为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-126.svg", 24.268, 2.843, 0.838, "StartAbsoluteValue a plus b EndAbsoluteValue gamma 3 plus StartAbsoluteValue c EndAbsoluteValue gamma 2 plus StartAbsoluteValue d EndAbsoluteValue gamma 1 period", display: true) $

#parec[
  An advantage of this approach is that quotients of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-127.svg", 9.576, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n") terms can also be bounded with the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-128.svg", 1.262, 2.176, 0.838, "gamma") function. Given
][
  这一方法还有一个优点：$(1 plus.minus epsilon_m)^n$ 项的商也可用 $gamma$ 函数界定。对于：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-129.svg", 11.515, 6.509, 2.671, "StartFraction left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript m Baseline Over left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n Baseline EndFraction comma", display: true) $

#parec[
  the interval is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-130.svg", 10.956, 2.843, 0.838, "left-parenthesis 1 plus-or-minus gamma Subscript m plus n Baseline right-parenthesis"). Thus, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-131.svg", 1.262, 2.176, 0.838, "gamma") can be used to collect #source-math("/chapter-6-Shapes/supplements/6.8-math/source-132.svg", 2.545, 2.009, 0.671, "epsilon Subscript normal m") terms from both sides of an equality over to one side by dividing them through; this will be useful in some of the following derivations. (Note that because #source-math("/chapter-6-Shapes/supplements/6.8-math/source-133.svg", 8.357, 2.843, 0.838, "left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis") terms represent intervals, canceling them would be incorrect:
][
  它被区间 $(1 plus.minus gamma_(m+n))$ 包围。因此，可以通过除法将等式两侧的 $epsilon_m$ 项收集到同一侧，并用 $gamma$ 表示，后续推导会用到这一点。注意这些项代表区间，不能约去：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-134.svg", 26.911, 6.509, 2.671, "StartFraction left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript m Baseline Over left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript n Baseline EndFraction not-equals left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis Superscript m minus n Baseline semicolon", display: true) $

#parec[
  the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-135.svg", 5.144, 2.176, 0.838, "gamma Subscript m plus n") bounds must be used instead.)
][
  必须改用 $gamma_(m+n)$ 的界。
]

#parec[
  Given inputs to some computation that themselves carry some amount of error, it is instructive to see how this error is carried through various elementary arithmetic operations. Given two values, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-136.svg", 9.046, 2.843, 0.838, "a left-parenthesis 1 plus-or-minus gamma Subscript i Baseline right-parenthesis") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-137.svg", 8.924, 3.009, 1.005, "b left-parenthesis 1 plus-or-minus gamma Subscript j Baseline right-parenthesis"), that each carry accumulated error from earlier operations, consider their product. Using the definition of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-138.svg", 1.808, 2.176, 0.505, "circled-times"), the result is in the interval:
][
  若运算输入本身已带误差，观察这些误差如何通过基本运算传播很有启发性。设两值为 $a(1 plus.minus gamma_i)$ 与 $b(1 plus.minus gamma_j)$，分别带有此前运算的累积误差。由浮点乘法定义，它们的乘积位于以下区间：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-139.svg", 38.397, 3.009, 1.005, "a left-parenthesis 1 plus-or-minus gamma Subscript i Baseline right-parenthesis circled-times b left-parenthesis 1 plus-or-minus gamma Subscript j Baseline right-parenthesis element-of a b left-parenthesis 1 plus-or-minus gamma Subscript i plus j plus 1 Baseline right-parenthesis comma", display: true) $

#parec[
  where we have used the relationship #source-math("/chapter-6-Shapes/supplements/6.8-math/source-140.svg", 28.355, 3.009, 1.005, "left-parenthesis 1 plus-or-minus gamma Subscript i Baseline right-parenthesis left-parenthesis 1 plus-or-minus gamma Subscript j Baseline right-parenthesis element-of left-parenthesis 1 plus-or-minus gamma Subscript i plus j Baseline right-parenthesis"), which follows directly from @eqt:higham-error-prod-bounds.
][
  这里使用了关系 $(1 plus.minus gamma_i)(1 plus.minus gamma_j) in (1 plus.minus gamma_(i+j))$，它直接来自@eqt:higham-error-prod-bounds。
]

#parec[
  The relative error in this result is bounded by
][
  结果的相对误差不超过：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-141.svg", 20.611, 6.343, 2.505, "StartAbsoluteValue StartFraction a b gamma Subscript i plus j plus 1 Baseline Over a b EndFraction EndAbsoluteValue equals gamma Subscript i plus j plus 1 Baseline comma", display: true) $

#parec[
  and so the final error is no more than roughly #source-math("/chapter-6-Shapes/supplements/6.8-math/source-142.svg", 12.738, 2.843, 0.838, "left-parenthesis i plus j plus 1 right-parenthesis slash 2") ulps at the value of the product—about as good as we might hope for, given the error going into the multiplication. (The situation for division is similarly good.)
][
  因此，乘积处的最终误差大约不超过 $(i+j+1)/2$ 个 ulp。考虑到输入已带误差，这已相当理想；除法的情况同样良好。
]

#parec[
  Unfortunately, with addition and subtraction, it is possible for the relative error to increase substantially. Using the same definitions of the values being operated on, consider
][
  但加法和减法可能显著放大相对误差。对同样的两个输入，考虑：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-143.svg", 21.457, 3.009, 1.005, "a left-parenthesis 1 plus-or-minus gamma Subscript i Baseline right-parenthesis circled-plus b left-parenthesis 1 plus-or-minus gamma Subscript j Baseline right-parenthesis comma", display: true) $

#parec[
  which is in the interval #source-math("/chapter-6-Shapes/supplements/6.8-math/source-144.svg", 25.658, 3.009, 1.005, "a left-parenthesis 1 plus-or-minus gamma Subscript i plus 1 Baseline right-parenthesis plus b left-parenthesis 1 plus-or-minus gamma Subscript j plus 1 Baseline right-parenthesis comma") and so the absolute error is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-145.svg", 15.974, 3.009, 1.005, "StartAbsoluteValue a EndAbsoluteValue gamma Subscript i plus 1 plus StartAbsoluteValue b EndAbsoluteValue gamma Subscript j plus 1").
][
  其结果位于区间 $a(1 plus.minus gamma_(i+1))+b(1 plus.minus gamma_(j+1))$，所以绝对误差不超过 $abs(a)gamma_(i+1)+abs(b)gamma_(j+1)$。
]

#parec[
  If the signs of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-146.svg", 1.23, 1.676, 0.338, "a") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-147.svg", 0.998, 2.176, 0.338, "b") are the same, then the absolute error is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-148.svg", 12.422, 3.009, 1.005, "StartAbsoluteValue a plus b EndAbsoluteValue gamma Subscript i plus j plus 1") and the relative error is approximately #source-math("/chapter-6-Shapes/supplements/6.8-math/source-149.svg", 12.738, 2.843, 0.838, "left-parenthesis i plus j plus 1 right-parenthesis slash 2") ulps around the computed value.
][
  若 $a$ 与 $b$ 同号，绝对误差受 $abs(a+b)gamma_(i+j+1)$ 约束，误差约为计算结果附近的 $(i+j+1)/2$ 个 ulp。
]

#parec[
  However, if the signs of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-150.svg", 1.23, 1.676, 0.338, "a") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-151.svg", 0.998, 2.176, 0.338, "b") differ (or, equivalently, they are the same but subtraction is performed), then the relative error can be quite high. Consider the case where #source-math("/chapter-6-Shapes/supplements/6.8-math/source-152.svg", 7.122, 2.343, 0.505, "a almost-equals negative b"): the relative error is
][
  若 $a$ 与 $b$ 异号，或等价地对两个同号数相减，相对误差就可能很大。考虑 $a approx -b$，此时相对误差为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-153.svg", 31.126, 6.009, 2.171, "StartFraction StartAbsoluteValue a EndAbsoluteValue gamma Subscript i plus 1 Baseline plus StartAbsoluteValue b EndAbsoluteValue gamma Subscript j plus 1 Baseline Over a plus b EndFraction almost-equals StartFraction 2 StartAbsoluteValue a EndAbsoluteValue gamma Subscript i plus j plus 1 Baseline Over a plus b EndFraction period", display: true) $

#parec[
  The numerator’s magnitude is proportional to the original value #source-math("/chapter-6-Shapes/supplements/6.8-math/source-154.svg", 2.523, 2.843, 0.838, "StartAbsoluteValue a EndAbsoluteValue") yet is divided by a very small number, and thus the relative error is quite high. This substantial increase in relative error is called #emph[catastrophic cancellation]. Equivalently, we can have a sense of the issue from the fact that the absolute error is in terms of the magnitude of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-155.svg", 2.523, 2.843, 0.838, "StartAbsoluteValue a EndAbsoluteValue"), though it is in relation to a value much smaller than #source-math("/chapter-6-Shapes/supplements/6.8-math/source-156.svg", 1.23, 1.676, 0.338, "a").
][
  分子与原数值 $abs(a)$ 成比例，却被一个很小的结果除，因此相对误差很大。这种显著放大称为灾难性抵消：绝对误差的尺度仍由 $abs(a)$ 决定，而结果却远小于 $a$。
]

#heading(level: 4, numbering: none)[#ez_caption[Running Error Analysis][运行误差分析]]
<running-error-analysis>

#parec[
  In addition to working out error bounds algebraically, we can also have the computer do this work for us as some computation is being performed. This approach is known as #emph[running error analysis]. The idea behind it is simple: each time a floating-point operation is performed, we compute intervals based on @eqt:fp-add-error-bounds that bound its true value.
][
  除手工代数推导外，也可以让计算机随计算过程追踪误差，这称为运行误差分析。每执行一次浮点运算，就根据@eqt:fp-add-error-bounds 计算包围真实值的区间。
]

#parec[
  The #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] class, which is defined in Section #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#sec:interval-arithmetic")[B.2.15], provides this functionality. The `Interval` class also tracks rounding errors in floating-point arithmetic and is useful even if none of the initial values are intervals. While computing error bounds in this way has higher runtime overhead than using derived expressions that give an error bound directly, it can be convenient when derivations become unwieldy.
][
  第 B.2.15 节定义的 `Interval` 类提供这一能力。它也跟踪浮点运算的舍入误差，因此即使初始输入都不是区间，也仍然有用。与直接计算已推导出的误差界表达式相比，这种方式运行开销更高，但当手工推导变得繁琐时很方便。
]

=== #ez_caption[Conservative Ray–Bounds Intersections][保守的射线与包围盒求交]
<conservative-ray-bounds>

#parec[
  Floating-point round-off error can cause the ray–bounding box intersection test to miss cases where a ray actually does intersect the box. While it is acceptable to have occasional false positives from ray–box intersection tests, we would like to never miss an intersection—getting this right is important for the correctness of the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#BVHAggregate")[`BVHAggregate`] acceleration data structure in Section #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Bounding_Volume_Hierarchies.html#sec:bvh")[7.3] so that valid ray–shape intersections are not missed. The ray–bounding box test introduced in Section #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#sec:ray-bounds-intersect")[6.1.2] is based on computing a series of ray–slab intersections to find the parametric #source-math("/chapter-6-Shapes/supplements/6.8-math/source-157.svg", 3.812, 2.343, 0.671, "t Subscript normal m normal i normal n") along the ray where the ray enters the bounding box and the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-158.svg", 4.131, 2.343, 0.671, "t Subscript normal m normal a normal x") where it exits. If #source-math("/chapter-6-Shapes/supplements/6.8-math/source-159.svg", 11.041, 2.343, 0.671, "t Subscript normal m normal i normal n Baseline less-than t Subscript normal m normal a normal x"), the ray passes through the box; otherwise, it misses it. With floating-point arithmetic, there may be error in the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-160.svg", 0.84, 2.009, 0.338, "t") values—if the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-161.svg", 3.812, 2.343, 0.671, "t Subscript normal m normal i normal n") value is greater than #source-math("/chapter-6-Shapes/supplements/6.8-math/source-162.svg", 4.131, 2.343, 0.671, "t Subscript normal m normal a normal x") purely due to round-off error, the intersection test will incorrectly return a false result.
][
  浮点舍入误差可能让射线与包围盒求交漏掉真实交点。偶尔误报相交可以接受，但应避免漏判；否则，第 7.3 节的 `BVHAggregate` 可能漏掉有效的射线与形状交点。第 6.1.2 节的算法通过逐个平行平面夹层求交，确定射线进入和离开包围盒的参数 $t_(min)$ 与 $t_(max)$。若 $t_(min)<t_(max)$ 则穿过包围盒，否则不相交。但如果仅因舍入误差就使计算的 $t_(min)$ 大于 $t_(max)$，测试便会错误地返回假。
]

#parec[
  Recall that the computation to find the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-163.svg", 0.84, 2.009, 0.338, "t") value for a ray intersection with a plane perpendicular to the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-164.svg", 1.33, 1.676, 0.338, "x") axis at a point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-165.svg", 1.33, 1.676, 0.338, "x") is #source-math("/chapter-6-Shapes/supplements/6.8-math/source-166.svg", 16.073, 2.843, 0.838, "t equals left-parenthesis x minus normal o Subscript x Baseline right-parenthesis slash bold d Subscript x"). Expressed as a floating-point computation and applying @eqt:ieee-arith-op-rounding, we have
][
  与 $x$ 轴垂直、位于坐标 $x$ 的平面，其射线交点参数为 $t=(x-o_x)/d_x$。写为浮点运算并应用@eqt:ieee-arith-op-rounding，有：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-167.svg", 42.202, 5.509, 2.338, "t equals left-parenthesis x minus normal o Subscript x Baseline right-parenthesis circled-times left-parenthesis 1 circled-division-slash bold d Subscript x Baseline right-parenthesis element-of StartFraction x minus normal o Subscript x Baseline Over bold d Subscript x Baseline EndFraction left-parenthesis 1 plus-or-minus epsilon right-parenthesis cubed comma", display: true) $

#parec[
  and so
][
  因此：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-168.svg", 19.739, 5.509, 2.338, "StartFraction x minus normal o Subscript x Baseline Over bold d Subscript x Baseline EndFraction element-of t left-parenthesis 1 plus-or-minus gamma 3 right-parenthesis period", display: true) $

#parec[
  The difference between the computed result #source-math("/chapter-6-Shapes/supplements/6.8-math/source-169.svg", 0.84, 2.009, 0.338, "t") and the precise result is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-170.svg", 4.392, 2.843, 0.838, "gamma 3 StartAbsoluteValue t EndAbsoluteValue").
][
  计算值 $t$ 与精确值的差受 $gamma_3 abs(t)$ 约束。
]

#parec[
  If we consider the intervals around the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-171.svg", 0.84, 2.009, 0.338, "t") values that bound the true value of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-172.svg", 0.84, 2.009, 0.338, "t"), then the case we are concerned with is when the intervals overlap; if they do not, then the comparison of computed values will give the correct result (@fig:ray-bbox-error-offset). If the intervals do overlap, it is impossible to know the true ordering of the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-173.svg", 0.84, 2.009, 0.338, "t") values. In this case, increasing #source-math("/chapter-6-Shapes/supplements/6.8-math/source-174.svg", 4.131, 2.343, 0.671, "t Subscript normal m normal a normal x") by twice the error bound, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-175.svg", 7.552, 2.676, 0.838, "2 gamma 3 t Subscript normal m normal a normal x"), before performing the comparison ensures that we conservatively return true in this case.
][
  考虑包围真实 $t$ 值的误差区间。只有两个区间重叠时才会出现问题；若不重叠，直接比较计算值就能确定正确顺序（@fig:ray-bbox-error-offset）。若区间重叠，则无法判定真实大小关系。在比较之前将 $t_(max)$ 增加其误差界的两倍，即 $2 gamma_3 t_(max)$，可以在这种情况下保守地返回真。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f41.svg"), caption:[#ez_caption[If the error bounds of the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-176.svg", 3.812, 2.343, 0.671, "t Subscript normal m normal i normal n") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-177.svg", 4.131, 2.343, 0.671, "t Subscript normal m normal a normal x") values overlap, the comparison #source-math("/chapter-6-Shapes/supplements/6.8-math/source-178.svg", 11.041, 2.343, 0.671, "t Subscript normal m normal i normal n Baseline less-than t Subscript normal m normal a normal x") may not indicate if a ray hit a bounding box. It is better to conservatively return true in this case than to miss an intersection. Extending #source-math("/chapter-6-Shapes/supplements/6.8-math/source-179.svg", 4.131, 2.343, 0.671, "t Subscript normal m normal a normal x") by twice its error bound ensures that the comparison is conservative.][若计算所得 $t_(min)$、$t_(max)$ 的误差区间重叠，比较 $t_(min)<t_(max)$ 就未必能确定射线是否命中包围盒。此时保守地返回真好过漏掉交点；将 $t_(max)$ 增大两倍误差界，可使比较保持保守。]]) <ray-bbox-error-offset>

#parec[
  We can now define the fragment for the ray–bounding box test in Section #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#sec:ray-bounds-intersect")[6.1.2] that makes this adjustment.
][
  现在可以补全第 6.1.2 节射线与包围盒求交中执行这一修正的片段。
]

#block(sticky:true)[#raw("<<Update tFar to ensure robust ray–bounds intersection>>=")] <fragment-UpdatemonotFartoensurerobustray--boundsintersection-0>
```cpp
tFar *= 1 + 2 * gamma(3);
```

#parec[
  The fragments for the `Bounds3::IntersectP()` method, 〈Update `tMax` and `tyMax` to ensure robust bounds intersection〉 and 〈Update `tzMax` to ensure robust bounds intersection〉, are similar and therefore not included here.
][
  `Bounds3::IntersectP()` 中的〈Update tMax and tyMax to ensure robust bounds intersection〉与〈Update tzMax to ensure robust bounds intersection〉类似，正文不再列出。
]

=== #ez_caption[Accurate Quadratic Discriminants][精确计算二次方程判别式]
<accurate-quadratic-discriminants>

#parec[
  Recall from Sections #link("https://pbr-book.org/4ed/Shapes/Spheres.html#sec:sphere-intersection")[6.2.2] and #link("https://pbr-book.org/4ed/Shapes/Cylinders.html#sec:cylinder-intersection")[6.3.2] that intersecting a ray with a sphere or cylinder involves finding the zeros of a quadratic equation, which requires calculating its discriminant, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-180.svg", 8.291, 2.676, 0.505, "b squared minus 4 a c"). If the discriminant is computed as written, then when the sphere is far from the ray origin, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-181.svg", 8.538, 2.509, 0.338, "b squared almost-equals 4 a c") and catastrophic cancellation occurs. This issue is made worse since the magnitudes of the two terms of the discriminant are related to the #emph[squared] distance between the sphere and the ray origin. Even for rays that are far from ever hitting the sphere, a discriminant may be computed that is exactly equal to zero, leading to the intersection code reporting an invalid intersection. See @fig:ray-sphere-discriminant-error, which shows that this error can be meaningful in practice.
][
  第 6.2.2 和 6.3.2 节求射线与球面、圆柱面交点时，需要解二次方程并计算判别式 $b^2-4 a c$。直接按此式计算时，若球体距射线起点较远，就会有 $b^2 approx 4 a c$，从而发生灾难性抵消。两项的大小又与球体到射线起点的距离平方有关，进一步加重了问题。即使射线根本不可能碰到球体，也可能算出恰好为零的判别式，误报交点。@fig:ray-sphere-discriminant-error 展示了它对实际图像的影响。
]

#figure(grid(columns: (1fr, 1fr), gutter:8pt, image("../pbr-book-website/4ed/Shapes/sphere-ortho-traditional.png",width:100%), image("../pbr-book-website/4ed/Shapes/sphere-ortho-better.png",width:100%)), caption:[#ez_caption[The Effect of Reducing the Error in the Computation of the Discriminant for Ray–Sphere Intersection. Unit sphere, viewed using an orthographic projection with a camera 400 units away. (a) If the quadratic discriminant is computed in the usual fashion, numeric error causes intersections at the edges to be missed. In the found intersections, the inaccuracy is evident in the wobble of the textured lines. (b) With the more precise formulation described in this section, the sphere is rendered correctly. (With the improved discriminant, such a sphere can be translated as far as 7,500 or so units from an orthographic camera and still be rendered accurately.)][降低射线与球面求交判别式误差的效果。单位球体由距其 400 个单位的正交相机观察。（a）通常的判别式计算会因数值误差漏掉边缘交点；命中处纹理线的抖动也表明交点不准确。（b）使用本节更精确的形式后，球体正确显示。改进后，球体与正交相机的距离即使达到约 7500 个单位，仍可准确渲染。]]) <ray-sphere-discriminant-error>

#parec[
  Algebraically rewriting the discriminant computation makes it possible to compute it with more accuracy. First, if we rewrite the quadratic discriminant as
][
  代数改写可以提高判别式的计算精度。先写成：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-182.svg", 24.666, 6.343, 2.505, "b squared minus 4 a c equals 4 a left-parenthesis StartFraction b squared Over 4 a EndFraction minus c right-parenthesis", display: true) $

#parec[
  and then substitute in the values of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-183.svg", 1.23, 1.676, 0.338, "a"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-184.svg", 0.998, 2.176, 0.338, "b"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-185.svg", 1.007, 1.676, 0.338, "c") from Equation (#link("https://pbr-book.org/4ed/Shapes/Spheres.html#eq:sphere-isect-coeffs")[6.3]) to the terms inside the parentheses, we have
][
  将式（6.3）的 $a$、$b$、$c$ 代入括号内，得到：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-186.svg", 35.169, 11.843, 5.338, "StartLayout 1st Row 1st Column Blank 2nd Column 4 a left-parenthesis StartFraction 4 left-parenthesis bold o dot bold d right-parenthesis squared Over 4 left-parenthesis bold d dot bold d right-parenthesis EndFraction minus left-parenthesis left-parenthesis bold o dot bold o right-parenthesis minus r squared right-parenthesis right-parenthesis 2nd Row 1st Column equals 2nd Column 4 a left-parenthesis left-bracket left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis squared minus left-parenthesis bold o dot bold o right-parenthesis right-bracket plus r squared right-parenthesis comma EndLayout", display: true) $ <sphere-discriminant-rewritten>

#parec[
  where we have denoted the vector from #source-math("/chapter-6-Shapes/supplements/6.8-math/source-187.svg", 7.365, 2.843, 0.838, "left-parenthesis 0 comma 0 comma 0 right-parenthesis") to the ray’s origin as #source-math("/chapter-6-Shapes/supplements/6.8-math/source-188.svg", 1.337, 1.676, 0.338, "bold o") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-189.svg", 1.485, 2.843, 0.338, "ModifyingAbove bold d With bold caret") is the ray’s normalized direction.
][
  其中 $bold(o)$ 为从 $(0,0,0)$ 指向射线起点的向量，$hat(bold(d))$ 为归一化射线方向。
]

#parec[
  Now consider the decomposition of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-190.svg", 1.337, 1.676, 0.338, "bold o") into the sum of two vectors, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-191.svg", 2.996, 2.509, 0.671, "bold d Subscript up-tack") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-192.svg", 2.54, 3.009, 1.171, "bold d Subscript parallel-to"), where #source-math("/chapter-6-Shapes/supplements/6.8-math/source-193.svg", 2.54, 3.009, 1.171, "bold d Subscript parallel-to") is parallel to #source-math("/chapter-6-Shapes/supplements/6.8-math/source-194.svg", 1.485, 2.843, 0.338, "ModifyingAbove bold d With bold caret") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-195.svg", 2.996, 2.509, 0.671, "bold d Subscript up-tack") is perpendicular to it. Those vectors are given by
][
  将 $bold(o)$ 分解为 $bold(d)_(perp)$ 与 $bold(d)_(parallel)$ 之和，后者平行于 $hat(bold(d))$，前者与之垂直：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-196.svg", 29.281, 7.843, 3.338, "StartLayout 1st Row 1st Column bold d Subscript parallel-to 2nd Column equals left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis ModifyingAbove bold d With bold caret 2nd Row 1st Column bold d Subscript up-tack 2nd Column equals bold o minus bold d Subscript parallel-to Baseline equals bold o minus left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis ModifyingAbove bold d With bold caret period EndLayout", display: true) $ <o-d-per-parl>

#parec[
  These three vectors form a right triangle, and therefore #source-math("/chapter-6-Shapes/supplements/6.8-math/source-197.svg", 21.527, 3.343, 1.171, "double-vertical-bar bold o double-vertical-bar squared equals double-vertical-bar bold d Subscript up-tack Baseline double-vertical-bar squared plus double-vertical-bar bold d Subscript parallel-to Baseline double-vertical-bar squared"). Applying @eqt:o-d-per-parl,
][
  这三个向量组成直角三角形，因此 $norm(bold(o))^2=norm(bold(d)_(perp))^2+norm(bold(d)_(parallel))^2$。应用@eqt:o-d-per-parl，得到：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-198.svg", 39.485, 7.176, 3.005, "StartLayout 1st Row 1st Column left-parenthesis bold o dot bold o right-parenthesis 2nd Column equals double-vertical-bar bold o minus bold left-parenthesis bold o dot ModifyingAbove bold d With bold caret bold right-parenthesis ModifyingAbove bold d With bold caret double-vertical-bar squared plus left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis squared double-vertical-bar ModifyingAbove bold d With bold caret double-vertical-bar squared 2nd Row 1st Column Blank 2nd Column equals double-vertical-bar bold o minus bold left-parenthesis bold o dot ModifyingAbove bold d With bold caret bold right-parenthesis ModifyingAbove bold d With bold caret double-vertical-bar squared plus left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis squared period EndLayout", display: true) $

#parec[
  Rearranging terms gives
][
  移项得：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-199.svg", 36.798, 3.343, 0.838, "left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis squared minus left-parenthesis bold o dot bold o right-parenthesis equals minus double-vertical-bar bold o minus bold left-parenthesis bold o dot ModifyingAbove bold d With bold caret bold right-parenthesis ModifyingAbove bold d With bold caret double-vertical-bar squared period", display: true) $

#parec[
  Expressing the right hand side in terms of the sphere quadratic coefficients from Equation (#link("https://pbr-book.org/4ed/Shapes/Spheres.html#eq:sphere-isect-coeffs")[6.3]) gives
][
  用式（6.3）的球面二次方程系数表示右侧，得到：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-200.svg", 33.66, 6.009, 2.171, "left-parenthesis bold o dot ModifyingAbove bold d With bold caret right-parenthesis squared minus left-parenthesis bold o dot bold o right-parenthesis equals minus double-vertical-bar bold o minus StartFraction b Over 2 a EndFraction bold d double-vertical-bar squared period", display: true) $

#parec[
  Note that the left hand side is equal to the term in square brackets in @eqt:sphere-discriminant-rewritten.
][
  注意，左侧就是@eqt:sphere-discriminant-rewritten 方括号内的项。
]

#parec[
  Computing that term in this way eliminates #source-math("/chapter-6-Shapes/supplements/6.8-math/source-201.svg", 1.007, 1.676, 0.338, "c") from the discriminant, which is of great benefit since its magnitude is proportional to the squared distance to the origin, with accordingly limited accuracy. In the implementation below, we take advantage of the fact that the discriminant is now the difference of squared values and make use of the identity #source-math("/chapter-6-Shapes/supplements/6.8-math/source-202.svg", 24.753, 3.009, 0.838, "x squared minus y squared equals left-parenthesis x plus y right-parenthesis left-parenthesis x minus y right-parenthesis") to reduce the magnitudes of the intermediate values, which further reduces error.
][
  这样计算消去了判别式中的 $c$，好处很大：$c$ 的大小与距原点的距离平方成比例，精度因而受限。下面还利用判别式成为两平方值之差的形式，以及恒等式 $x^2-y^2=(x+y)(x-y)$，减小中间数值的量级，进一步降低误差。
]

#block(sticky:true)[#raw("<<Compute sphere quadratic discriminant discrim>>=")] <fragment-Computespherequadraticdiscriminantmonodiscrim-0>
```cpp
Vector3fi v(oi - b / (2 * a) * di);
Interval length = Length(v);
Interval discrim = 4 * a * (Interval(radius) + length) *
                           (Interval(radius) - length);
if (discrim.LowerBound() < 0)
    return {};
```

#parec[
  One might ask, why go through this trouble when we could use the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[`DifferenceOfProducts()`] function to compute the discriminant, presumably with low error? The reason that is not an equivalent alternative is that the values #source-math("/chapter-6-Shapes/supplements/6.8-math/source-203.svg", 1.23, 1.676, 0.338, "a"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-204.svg", 0.998, 2.176, 0.338, "b"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-205.svg", 1.007, 1.676, 0.338, "c") already suffer from rounding error. In turn, a result computed by `DifferenceOfProducts()` will be inaccurate if its inputs already are inaccurate themselves. #source-math("/chapter-6-Shapes/supplements/6.8-math/source-206.svg", 21.498, 3.176, 1.005, "c equals normal o Subscript x Superscript 2 Baseline plus normal o Subscript y Superscript 2 Baseline plus normal o Subscript z Superscript 2 Baseline minus r squared") is particularly problematic, since it is the difference of two positive values, so is susceptible to catastrophic cancellation.
][
  为什么不直接用误差较小的 `DifferenceOfProducts()` 计算判别式？因为输入 $a$、$b$、$c$ 已经带有舍入误差；输入不准确时，它也无法返回准确结果。尤其 $c=o_x^2+o_y^2+o_z^2-r^2$ 是两个正值之差，容易发生灾难性抵消。
]

#parec[
  A similar derivation gives a more accurate discriminant for the cylinder.
][
  类似推导可以得到精度更高的圆柱面判别式。
]

#block(sticky:true)[#raw("<<Compute cylinder quadratic discriminant discrim>>=")] <fragment-Computecylinderquadraticdiscriminantmonodiscrim-0>
```cpp
Interval f = b / (2 * a);
Interval vx = oi.x - f * di.x, vy = oi.y - f * di.y;
Interval length = Sqrt(Sqr(vx) + Sqr(vy));
Interval discrim = 4 * a * (Interval(radius) + length) *
                           (Interval(radius) - length);
if (discrim.LowerBound() < 0)
    return {};
```

=== #ez_caption[Robust Triangle Intersections][稳健的三角形求交]
<robust-triangle-intersections>

#parec[
  The details of the ray–triangle intersection algorithm described in Section #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#sec:ray-triangle")[6.5.3] were carefully designed to avoid cases where rays could incorrectly pass through an edge or vertex shared by two adjacent triangles without generating an intersection. Fittingly, an intersection algorithm with this guarantee is referred to as being #emph[watertight].
][
  第 6.5.3 节的射线与三角形求交算法经过精心设计，避免射线穿过相邻三角形共享的边或顶点，却没有报告交点。具有这一保证的算法称为水密算法。
]

#parec[
  Recall that the algorithm is based on transforming triangle vertices into a coordinate system with the ray’s origin at its origin and the ray’s direction aligned along the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-207.svg", 2.894, 2.176, 0.505, "plus z") axis. Although round-off error may be introduced by transforming the vertex positions to this coordinate system, this error does not affect the watertightness of the intersection test, since the same transformation is applied to all triangles. (Further, this error is quite small, so it does not significantly impact the accuracy of the computed intersection points.)
][
  算法先将三角形顶点变换到射线起点位于原点、射线方向沿 $+z$ 轴的坐标系。变换虽会引入舍入误差，但所有三角形使用同一变换，因此该误差不会破坏求交测试的水密性。而且误差很小，不会显著影响交点精度。
]

#parec[
  Given vertices in this coordinate system, the three edge functions defined in Equation (#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#eq:edge-function")[6.5]) are evaluated at the point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-208.svg", 5.168, 2.843, 0.838, "left-parenthesis 0 comma 0 right-parenthesis"); the corresponding expressions, Equation (#link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#eq:edge-function-00")[6.6]), are quite straightforward. The key to the robustness of the algorithm is that with floating-point arithmetic, the edge function evaluations are guaranteed to have the correct sign. In general, we have
][
  对变换后的顶点，在 $(0,0)$ 处计算式（6.5）的三个边函数，所得式（6.6）很直接。稳健性的关键是浮点边函数结果不会取错误的符号。一般考虑：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-209.svg", 17.23, 2.843, 0.838, "left-parenthesis a circled-times b right-parenthesis minus left-parenthesis c circled-times d right-parenthesis period", display: true) $ <edge-func-fp>

#parec[
  First, note that if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-210.svg", 7.542, 2.176, 0.338, "a b equals c d"), then @eqt:edge-func-fp evaluates to exactly zero, even in floating point. We therefore just need to show that if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-211.svg", 7.542, 2.176, 0.338, "a b greater-than c d"), then #source-math("/chapter-6-Shapes/supplements/6.8-math/source-212.svg", 16.583, 2.843, 0.838, "left-parenthesis a circled-times b right-parenthesis minus left-parenthesis c circled-times d right-parenthesis") is never negative. If #source-math("/chapter-6-Shapes/supplements/6.8-math/source-213.svg", 7.542, 2.176, 0.338, "a b greater-than c d"), then #source-math("/chapter-6-Shapes/supplements/6.8-math/source-214.svg", 6.877, 2.843, 0.838, "left-parenthesis a circled-times b right-parenthesis") must be greater than or equal to #source-math("/chapter-6-Shapes/supplements/6.8-math/source-215.svg", 6.865, 2.843, 0.838, "left-parenthesis c circled-times d right-parenthesis"). In turn, their difference must be greater than or equal to zero. (These properties both follow from the fact that floating-point arithmetic operations are all rounded to the nearest representable floating-point value.)
][
  若 $a b=c d$，@eqt:edge-func-fp 即使在浮点运算中也恰好为零。因此，只需证明 $a b>c d$ 时，$(a ⊗ b) ⊖ (c ⊗ d)$ 不会为负。此时浮点乘积 $a ⊗ b$ 必不小于 $c ⊗ d$，两者之差也不小于零。这些性质都来自舍入到最近可表示浮点值的规则。
]

#parec[
  If the value of the edge function is zero, then it is impossible to tell whether it is exactly zero or whether a small positive or negative value has rounded to zero. In this case, the fragment 〈Fall back to double-precision test at triangle edges〉 reevaluates the edge function with double precision; it can be shown that doubling the precision suffices to accurately distinguish these cases, given 32-bit floats as input.
][
  边函数结果为零时，无法判断真实值就是零，还是某个很小的正值或负值舍入成了零。因此，〈Fall back to double-precision test at triangle edges〉以双精度重新计算边函数；对 32 位 float 输入，将精度加倍足以区分这些情况。
]

#parec[
  The overhead caused by this additional precaution is minimal: in a benchmark with 88 million ray intersection tests, the double-precision fallback had to be used in less than 0.0000023% of the cases.
][
  这一额外措施开销很小：在包含 8800 万次求交测试的基准中，只有不到 0.0000023% 的情况需要双精度回退。
]

=== #ez_caption[Bounding Intersection Point Error][交点误差的界定]
<bounding-intersection-point-error>

#parec[
  We can apply the machinery introduced in this section for analyzing rounding error to derive conservative bounds on the absolute error in computed ray–shape intersection points, which allows us to construct bounding boxes that are guaranteed to include an intersection point on the actual surface (@fig:basic-error-setting). These bounding boxes provide the basis of the algorithm for generating spawned ray origins that will be introduced in @robust-spawned-ray-origins.
][
  本节的舍入误差分析工具可用于推导射线交点绝对误差的保守界，从而构造保证包含真实表面上一点的包围盒（@fig:basic-error-setting）。这些包围盒是@robust-spawned-ray-origins 生成新射线起点算法的基础。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f43.svg"), caption:[#ez_caption[Shape intersection algorithms in `pbrt` compute an intersection point, shown here in the 2D setting with a filled circle. The absolute error in this point is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-216.svg", 2.205, 2.509, 0.671, "delta Subscript x") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-217.svg", 2.07, 2.843, 1.005, "delta Subscript y"), giving a small box around the point. Because these bounds are conservative, we know that the actual intersection point on the surface (open circle) must lie somewhere within the box.][pbrt 的形状求交算法计算交点，图中以二维情况的实心圆点表示。该点的绝对误差由 $delta_x$、$delta_y$ 界定，构成点周围的小包围盒。因为误差界是保守的，真实表面交点（空心圆点）必位于盒内。]]) <basic-error-setting>

#parec[
  It is illuminating to start by looking at the sources of error in conventional approaches to computing intersection points. It is common practice in ray tracing to compute 3D intersection points by first solving the parametric ray equation #source-math("/chapter-6-Shapes/supplements/6.8-math/source-218.svg", 6.328, 2.343, 0.505, "normal o plus t bold d") for a value #source-math("/chapter-6-Shapes/supplements/6.8-math/source-219.svg", 3.083, 2.343, 0.671, "t Subscript normal h normal i normal t") where a ray intersects a surface and then computing the hit point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-220.svg", 1.293, 2.009, 0.671, "normal p Subscript") with #source-math("/chapter-6-Shapes/supplements/6.8-math/source-221.svg", 12.962, 2.509, 0.671, "normal p Subscript Baseline equals normal o plus t Subscript normal h normal i normal t Baseline bold d"). If #source-math("/chapter-6-Shapes/supplements/6.8-math/source-222.svg", 3.083, 2.343, 0.671, "t Subscript normal h normal i normal t") carries some error #source-math("/chapter-6-Shapes/supplements/6.8-math/source-223.svg", 1.858, 2.509, 0.671, "delta Subscript t"), then we can bound the error in the computed intersection point. Considering the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-224.svg", 1.33, 1.676, 0.338, "x") coordinate, for example, we have
][
  先看看通常求交方法中的误差来源。射线追踪常先解参数方程 $o+t bold(d)$，求出交点参数 $t_(upright("hit"))$，再计算 $p=o+t_(upright("hit"))bold(d)$。若 $t_(upright("hit"))$ 带误差 $delta_t$，即可推导交点误差。以 $x$ 坐标为例：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-225.svg", 55.089, 13.843, 6.338, "StartLayout 1st Row 1st Column x 2nd Column equals normal o Subscript x Baseline circled-plus left-parenthesis t Subscript normal h normal i normal t Baseline plus-or-minus delta Subscript t Baseline right-parenthesis circled-times bold d Subscript x Baseline 2nd Row 1st Column Blank 2nd Column element-of normal o Subscript x circled-plus left-parenthesis t Subscript normal h normal i normal t Baseline plus-or-minus delta Subscript t Baseline right-parenthesis bold d Subscript x Baseline left-parenthesis 1 plus-or-minus gamma 1 right-parenthesis 3rd Row 1st Column Blank 2nd Column subset-of normal o Subscript x Baseline left-parenthesis 1 plus-or-minus gamma 1 right-parenthesis plus left-parenthesis t Subscript normal h normal i normal t Baseline plus-or-minus delta Subscript t Baseline right-parenthesis bold d Subscript x Baseline left-parenthesis 1 plus-or-minus gamma 2 right-parenthesis 4th Row 1st Column Blank 2nd Column equals normal o Subscript x Baseline plus t Subscript normal h normal i normal t Baseline bold d Subscript x Baseline plus left-bracket plus-or-minus normal o Subscript x Baseline gamma 1 plus-or-minus delta Subscript t Baseline bold d Subscript x Baseline plus-or-minus t Subscript normal h normal i normal t Baseline bold d Subscript x Baseline gamma 2 plus-or-minus delta Subscript t Baseline bold d Subscript x Baseline gamma 2 right-bracket period EndLayout", display: true) $

#parec[
  The error term (in square brackets) is bounded by
][
  方括号中的误差项受下式约束：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-226.svg", 35.388, 2.843, 0.838, "gamma 1 StartAbsoluteValue normal o Subscript x Baseline EndAbsoluteValue plus delta Subscript t Baseline left-parenthesis 1 plus gamma 2 right-parenthesis StartAbsoluteValue bold d Subscript x Baseline EndAbsoluteValue plus gamma 2 StartAbsoluteValue t Subscript normal h normal i normal t Baseline bold d Subscript x Baseline EndAbsoluteValue period", display: true) $ <ray-equation-error>

#parec[
  There are two things to see from @eqt:ray-equation-error: first, the magnitudes of the terms that contribute to the error in the computed intersection point (#source-math("/chapter-6-Shapes/supplements/6.8-math/source-227.svg", 2.335, 2.009, 0.671, "normal o Subscript x"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-228.svg", 2.658, 2.509, 0.671, "bold d Subscript x"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-229.svg", 5.741, 2.509, 0.671, "t Subscript normal h normal i normal t Baseline bold d Subscript x")) may be quite different from the magnitude of the intersection point. Thus, there is a danger of catastrophic cancellation in the intersection point’s computed value. Second, ray intersection algorithms generally perform tens of floating-point operations to compute #source-math("/chapter-6-Shapes/supplements/6.8-math/source-230.svg", 0.84, 2.009, 0.338, "t") values, which in turn means that we can expect #source-math("/chapter-6-Shapes/supplements/6.8-math/source-231.svg", 1.858, 2.509, 0.671, "delta Subscript t") to be at least of magnitude #source-math("/chapter-6-Shapes/supplements/6.8-math/source-232.svg", 3.262, 2.509, 0.838, "gamma Subscript n Baseline t"), with #source-math("/chapter-6-Shapes/supplements/6.8-math/source-233.svg", 1.395, 1.676, 0.338, "n") in the tens (and possibly much more, due to catastrophic cancellation).
][
  @eqt:ray-equation-error 说明了两点。首先，误差贡献项 $o_x$、$d_x$、$t_(upright("hit"))d_x$ 的量级可能与交点坐标相差很大，因而有灾难性抵消的风险。其次，求交算法通常需执行数十次浮点运算才能求出 $t$，所以 $delta_t$ 的量级可预期至少约为 $gamma_n t$，其中 $n$ 为数十，灾难性抵消还可能使它大得多。
]

#parec[
  Each of these terms may introduce a significant amount of error in the computed point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-234.svg", 1.33, 1.676, 0.338, "x"). We introduce better approaches in the following.
][
  这些项都可能使计算所得 $x$ 坐标具有显著误差。下面介绍更好的方法。
]

#heading(level: 4, numbering: none)[#ez_caption[Reprojection: Quadrics][重投影：二次曲面]]
<rounding-reprojection-quadrics>

#parec[
  We would like to reliably compute surface intersection points with just a few ulps of error rather than the orders of magnitude greater error that intersection points computed with the parametric ray equation may have. Previously, Woo et al. (#source-cite("Woo:1996:RRB")) suggested using the first intersection point computed as a starting point for a second ray–plane intersection, for ray–polygon intersections. From the bounds in @eqt:ray-equation-error, we can see why the second intersection point will often be much closer to the surface than the first: the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-235.svg", 3.083, 2.343, 0.671, "t Subscript normal h normal i normal t") value along the second ray will be quite close to zero, so that the magnitude of the absolute error in #source-math("/chapter-6-Shapes/supplements/6.8-math/source-236.svg", 3.083, 2.343, 0.671, "t Subscript normal h normal i normal t") will be quite small, and thus using this value in the parametric ray equation will give a point quite close to the surface (@fig:ray-reintersect). Further, the ray origin will have similar magnitude to the intersection point, so the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-237.svg", 5.887, 2.843, 0.838, "gamma 1 StartAbsoluteValue normal o Subscript x Baseline EndAbsoluteValue") term will not introduce much additional error.
][
  希望得到的是离真实表面只有几个 ulp 的交点，而不是参数射线方程可能产生的大几个数量级的误差。Woo 等人（#source-cite("Woo:1996:RRB")）曾提出：射线与多边形求交时，将首次计算交点作为起点，再做一次射线与平面求交。由@eqt:ray-equation-error 可知，第二次交点通常更接近表面：此时 $t_(upright("hit"))$ 接近零，其绝对误差也很小，代入射线方程后所得点便很接近表面（@fig:ray-reintersect）。此外，射线起点与交点量级相近，$gamma_1 abs(o_x)$ 项也不会引入很多附加误差。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f44.svg"), caption:[#ez_caption[Reintersection to Improve the Accuracy of the Computed Intersection Point. Given a ray and a surface, an initial intersection point has been computed with the ray equation (filled circle). This point may be fairly inaccurate due to rounding error but can be used as the origin for a second ray–shape intersection. The intersection point computed from this second intersection (open circle) is much closer to the surface, though it may be shifted from the true intersection point due to error in the first computed intersection.][通过再次求交提高交点精度。先由射线方程算出初始交点（实心圆点）；它可能因舍入误差而不准确，但可用作第二次射线与形状求交的起点。第二次得到的点（空心圆点）更接近表面，不过首次交点的误差可能使它偏离真实交点。]]) <ray-reintersect>

#parec[
  Although the second intersection point computed with this approach is much closer to the plane of the surface, it still suffers from error by being offset due to error in the first computed intersection. The farther away the ray origin is from the intersection point (and thus, the larger the absolute error is in #source-math("/chapter-6-Shapes/supplements/6.8-math/source-238.svg", 3.083, 2.343, 0.671, "t Subscript normal h normal i normal t")), the larger this error will be. In spite of this error, the approach has merit: we are generally better off with a computed intersection point that is quite close to the actual surface, even if offset from the most accurate possible intersection point, than we are with a point that is some distance above or below the surface (and likely also far from the most accurate intersection point).
][
  这种方法虽然让第二个交点更接近平面，但首次交点误差仍会使它发生偏移。射线起点离交点越远，$t_(upright("hit"))$ 的绝对误差就越大，这一偏移也越大。尽管如此，相比离表面上方或下方较远、且往往也远离最精确交点的位置，一个极接近表面但略有偏移的点通常更好。
]

#parec[
  Rather than doing a full reintersection computation, which may not only be computationally costly but also will still have error in the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-239.svg", 0.84, 2.009, 0.338, "t") value, an effective alternative is to refine computed intersection points by reprojecting them to the surface. The error bounds for these reprojected points are often remarkably small. (It should be noted that these reprojection error bounds do not capture tangential errors that were present in the original intersection #source-math("/chapter-6-Shapes/supplements/6.8-math/source-240.svg", 1.293, 2.009, 0.671, "normal p Subscript")—the main focus here is to detect errors that might cause the reprojected point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-241.svg", 2.194, 2.676, 0.671, "normal p prime") to fall below the surface.)
][
  再次完整求交不仅可能昂贵，计算的 $t$ 仍然有误差。一个有效替代是把计算交点重新投影到表面，进一步细化它。重投影后的误差界往往很小。注意，这些界不包含原交点中已有的切向误差；这里主要关心会使重投影点落到表面下方的误差。
]

#parec[
  Consider a ray–sphere intersection: given a computed intersection point (e.g., from the ray equation) #source-math("/chapter-6-Shapes/supplements/6.8-math/source-242.svg", 1.293, 2.009, 0.671, "normal p Subscript") with a sphere at the origin with radius #source-math("/chapter-6-Shapes/supplements/6.8-math/source-243.svg", 1.049, 1.676, 0.338, "r"), we can reproject the point onto the surface of the sphere by scaling it with the ratio of the sphere’s radius to the computed point’s distance to the origin, computing a new point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-244.svg", 15.43, 2.843, 0.838, "normal p prime equals left-parenthesis x prime comma y prime comma z prime right-parenthesis") with
][
  例如，对球心位于原点、半径为 $r$ 的球，已计算交点为 $p$。将它按球半径与该点到原点距离之比缩放，即可重投影到球面，得到 $p'=(x',y',z')$：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-245.svg", 22.866, 6.009, 3.171, "x prime equals x StartFraction r Over StartRoot x squared plus y squared plus z squared EndRoot EndFraction comma", display: true) $

#parec[
  and so forth. The floating-point computation is
][
  其他坐标类似。相应浮点计算为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-246.svg", 57.975, 18.509, 8.671, "StartLayout 1st Row 1st Column x prime 2nd Column equals x circled-times r circled-division-slash monospace s monospace q monospace r monospace t left-parenthesis left-parenthesis x circled-times x right-parenthesis circled-plus left-parenthesis y circled-times y right-parenthesis circled-plus left-parenthesis z circled-times z right-parenthesis right-parenthesis 2nd Row 1st Column Blank 2nd Column element-of StartFraction x r left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared Over StartRoot x squared left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus y squared left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus z squared left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared EndRoot left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis EndFraction 3rd Row 1st Column Blank 2nd Column subset-of StartFraction x r left-parenthesis 1 plus-or-minus gamma 2 right-parenthesis Over StartRoot x squared left-parenthesis 1 plus-or-minus gamma 3 right-parenthesis plus y squared left-parenthesis 1 plus-or-minus gamma 3 right-parenthesis plus z squared left-parenthesis 1 plus-or-minus gamma 2 right-parenthesis EndRoot left-parenthesis 1 plus-or-minus gamma 1 right-parenthesis EndFraction period EndLayout", display: true) $

#parec[
  Because #source-math("/chapter-6-Shapes/supplements/6.8-math/source-247.svg", 2.384, 2.509, 0.338, "x squared"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-248.svg", 2.193, 2.843, 0.671, "y squared"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-249.svg", 2.142, 2.509, 0.338, "z squared") are all positive, the terms in the square root can share the same #source-math("/chapter-6-Shapes/supplements/6.8-math/source-250.svg", 1.262, 2.176, 0.838, "gamma") term, and we have
][
  因为 $x^2$、$y^2$、$z^2$ 都非负，平方根内各项可共用同一个 $gamma$ 项，因而：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-251.svg", 41.915, 25.176, 12.005, "StartLayout 1st Row 1st Column x prime 2nd Column element-of StartFraction x r left-parenthesis 1 plus-or-minus gamma 2 right-parenthesis Over StartRoot left-parenthesis x squared plus y squared plus z squared right-parenthesis left-parenthesis 1 plus-or-minus gamma 4 right-parenthesis EndRoot left-parenthesis 1 plus-or-minus gamma 1 right-parenthesis EndFraction 2nd Row 1st Column Blank 2nd Column equals StartFraction x r left-parenthesis 1 plus-or-minus gamma 2 right-parenthesis Over StartRoot left-parenthesis x squared plus y squared plus z squared right-parenthesis EndRoot StartRoot left-parenthesis 1 plus-or-minus gamma 4 right-parenthesis EndRoot left-parenthesis 1 plus-or-minus gamma 1 right-parenthesis EndFraction 3rd Row 1st Column Blank 2nd Column subset-of StartFraction x r Over StartRoot left-parenthesis x squared plus y squared plus z squared right-parenthesis EndRoot EndFraction left-parenthesis 1 plus-or-minus gamma 5 right-parenthesis 4th Row 1st Column Blank 2nd Column equals x prime left-parenthesis 1 plus-or-minus gamma 5 right-parenthesis period EndLayout", display: true) $ <sphere-err-bounds>

#parec[
  Thus, the absolute error of the reprojected #source-math("/chapter-6-Shapes/supplements/6.8-math/source-252.svg", 1.33, 1.676, 0.338, "x") coordinate is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-253.svg", 5.783, 2.843, 0.838, "gamma 5 StartAbsoluteValue x prime EndAbsoluteValue") (and similarly for #source-math("/chapter-6-Shapes/supplements/6.8-math/source-254.svg", 2.041, 2.676, 0.671, "y prime") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-255.svg", 1.989, 2.343, 0.338, "z prime")) and is thus no more than 2.5 ulps in each dimension from a point on the surface of the sphere.
][
  所以重投影后 $x'$ 坐标的绝对误差受 $gamma_5 abs(x')$ 约束，$y'$、$z'$ 也一样；相对于球面上一点，每个维度的误差约不超过 2.5 个 ulp。
]

#parec[
  Here is the fragment that reprojects the intersection point for the #link("https://pbr-book.org/4ed/Shapes/Spheres.html#Sphere")[`Sphere`] shape.
][
  以下片段将 `Sphere` 的交点重投影到球面。
]

#block(sticky:true)[#raw("<<Refine sphere intersection point>>=")] <fragment-Refinesphereintersectionpoint-0>
```cpp
pHit *= radius / Distance(pHit, Point3f(0, 0, 0));
```

#parec[
  The error bounds follow from @eqt:sphere-err-bounds.
][
  其误差界直接来自@eqt:sphere-err-bounds。
]

#block(sticky:true)[#raw("<<Compute error bounds for sphere intersection>>=")] <fragment-Computeerrorboundsforsphereintersection-0>
```cpp
Vector3f pError = gamma(5) * Abs((Vector3f)pHit);
```

#parec[
  Reprojection algorithms and error bounds for other quadrics can be defined similarly: for example, for a cylinder along the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-256.svg", 1.086, 1.676, 0.338, "z") axis, only the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-257.svg", 1.33, 1.676, 0.338, "x") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-258.svg", 1.139, 2.009, 0.671, "y") coordinates need to be reprojected, and the error bounds in #source-math("/chapter-6-Shapes/supplements/6.8-math/source-259.svg", 1.33, 1.676, 0.338, "x") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-260.svg", 1.139, 2.009, 0.671, "y") turn out to be only #source-math("/chapter-6-Shapes/supplements/6.8-math/source-261.svg", 2.259, 2.176, 0.838, "gamma 3") times their magnitudes.
][
  其他二次曲面的重投影与误差界也可类似推导。例如，对沿 $z$ 轴的圆柱，只需重投影 $x$、$y$ 坐标，两方向的误差界仅为相应坐标绝对值的 $gamma_3$ 倍。
]

#block(sticky:true)[#raw("<<Refine cylinder intersection point>>=")] <fragment-Refinecylinderintersectionpoint-0>
```cpp
Float hitRad = std::sqrt(Sqr(pHit.x) + Sqr(pHit.y));
pHit.x *= radius / hitRad;
pHit.y *= radius / hitRad;
```

#block(sticky:true)[#raw("<<Compute error bounds for cylinder intersection>>=")] <fragment-Computeerrorboundsforcylinderintersection-0>
```cpp
Vector3f pError = gamma(3) * Abs(Vector3f(pHit.x, pHit.y, 0));
```

#parec[
  The disk shape is particularly easy; we just need to set the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-262.svg", 1.086, 1.676, 0.338, "z") coordinate of the point to lie on the plane of the disk.
][
  圆盘尤其简单：只需把点的 $z$ 坐标设为圆盘所在平面的高度。
]

#block(sticky:true)[#raw("<<Refine disk intersection point>>=")] <fragment-Refinediskintersectionpoint-0>
```cpp
pHit.z = height;
```

#parec[
  In turn, we have a point with zero error; it lies exactly on the surface on the disk.
][
  这样便得到误差为零的点：它恰好位于圆盘表面上。
]

#block(sticky:true)[#raw("<<Compute error bounds for disk intersection>>=")] <fragment-Computeerrorboundsfordiskintersection-0>
```cpp
Vector3f pError(0, 0, 0);
```

#parec[
  The quadrics’ `Sample()` methods also use reprojection. For example, the #link("https://pbr-book.org/4ed/Shapes/Spheres.html#Sphere")[`Sphere`]’s area sampling method is based on #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#SampleUniformSphere")[`SampleUniformSphere()`], which uses `std::sin()` and `std::cos()`. Therefore, the error bounds on the computed `pObj` value depend on the accuracy of those functions. By reprojecting the sampled point to the sphere’s surface, the error bounds derived earlier in @eqt:sphere-err-bounds can be used without needing to worry about those functions’ accuracy.
][
  二次曲面的 `Sample()` 也使用重投影。例如，球面面积采样基于 `SampleUniformSphere()`，其中调用 `std::sin()` 和 `std::cos()`，所得 `pObj` 的误差因此取决于这些函数的精度。将采样点重投影到球面后，就能直接使用@eqt:sphere-err-bounds 的误差界，无需再考虑三角函数的精度。
]

#block(sticky:true)[#raw("<<Reproject pObj to sphere surface and compute pObjError>>=")] <fragment-ReprojectmonopObjtospheresurfaceandcomputemonopObjError-0>
```cpp
pObj *= radius / Distance(pObj, Point3f(0, 0, 0));
Vector3f pObjError = gamma(5) * Abs((Vector3f)pObj);
```

#parec[
  The same issue and solution apply to sampling cylinders.
][
  圆柱采样也有同样的问题和解决办法。
]

#block(sticky:true)[#raw("<<Reproject pObj to cylinder surface and compute pObjError>>=")] <fragment-ReprojectmonopObjtocylindersurfaceandcomputemonopObjError-0>
```cpp
Float hitRad = std::sqrt(Sqr(pObj.x) + Sqr(pObj.y));
pObj.x *= radius / hitRad;
pObj.y *= radius / hitRad;
Vector3f pObjError = gamma(3) * Abs(Vector3f(pObj.x, pObj.y, 0));
```

#heading(level: 4, numbering: none)[#ez_caption[Parametric Evaluation: Triangles][参数求值：三角形]]
<rounding-parametric-triangles>

#parec[
  Another effective approach to computing accurate intersection points near the surface of a shape uses the shape’s parametric representation. For example, the triangle intersection algorithm in Section #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#sec:ray-triangle")[6.5.3] computes three edge function values #source-math("/chapter-6-Shapes/supplements/6.8-math/source-263.svg", 2.138, 2.009, 0.671, "e 0"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-264.svg", 2.138, 2.009, 0.671, "e 1"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-265.svg", 2.138, 2.009, 0.671, "e 2") and reports an intersection if all three have the same sign. Their values can be used to find the barycentric coordinates
][
  利用形状的参数表示，也是计算靠近真实表面的准确交点的有效方法。例如，第 6.5.3 节三角形求交先计算边函数 $e_0$、$e_1$、$e_2$，三者同号时报告相交。用它们可得到重心坐标：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-266.svg", 18.473, 5.009, 2.171, "b Subscript i Baseline equals StartFraction e Subscript i Baseline Over e 0 plus e 1 plus e 2 EndFraction period", display: true) $

#parec[
  Attributes #source-math("/chapter-6-Shapes/supplements/6.8-math/source-267.svg", 1.927, 2.009, 0.671, "v Subscript i") at the triangle vertices (including the vertex positions) can be interpolated across the face of the triangle by
][
  三角形顶点的属性 $v_i$，包括顶点位置，都可按下式在三角形内插值：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-268.svg", 24.156, 2.843, 0.671, "v prime equals b 0 v 0 plus b 1 v 1 plus b 2 v 2 period", display: true) $

#parec[
  We can show that interpolating the positions of the vertices in this manner gives a point very close to the surface of the triangle. First consider precomputing the reciprocal of the sum of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-269.svg", 1.883, 2.009, 0.671, "e Subscript i"):
][
  可以证明，以此方式插值顶点位置会得到非常接近三角形表面的点。先考虑预先计算各 $e_i$ 之和的倒数：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-270.svg", 46.314, 9.509, 3.973, "StartLayout 1st Row 1st Column d 2nd Column equals 1 circled-division-slash left-parenthesis e 0 circled-plus e 1 circled-plus e 2 right-parenthesis 2nd Row 1st Column Blank 2nd Column element-of StartFraction 1 Over left-parenthesis e 0 plus e 1 right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared plus e 2 left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis EndFraction left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis period EndLayout", display: true) $

#parec[
  Because all #source-math("/chapter-6-Shapes/supplements/6.8-math/source-271.svg", 1.883, 2.009, 0.671, "e Subscript i") have the same sign if there is an intersection, we can collect the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-272.svg", 1.883, 2.009, 0.671, "e Subscript i") terms and conservatively bound #source-math("/chapter-6-Shapes/supplements/6.8-math/source-273.svg", 1.209, 2.176, 0.338, "d"):
][
  发生相交时，所有 $e_i$ 同号，因此可合并这些项，并保守地界定 $d$：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-274.svg", 37.31, 12.176, 5.305, "StartLayout 1st Row 1st Column d 2nd Column element-of StartFraction 1 Over left-parenthesis e 0 plus e 1 plus e 2 right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared EndFraction left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis 2nd Row 1st Column Blank 2nd Column subset-of StartFraction 1 Over e 0 plus e 1 plus e 2 EndFraction left-parenthesis 1 plus-or-minus gamma 3 right-parenthesis period EndLayout", display: true) $

#parec[
  If we now consider interpolation of the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-275.svg", 1.33, 1.676, 0.338, "x") coordinate of the position in the triangle corresponding to the edge function values, we have
][
  现在考虑对这些边函数值对应的位置 $x$ 坐标进行插值：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-276.svg", 64.68, 10.343, 4.671, "StartLayout 1st Row 1st Column x prime 2nd Column equals left-parenthesis left-parenthesis e 0 circled-times x 0 right-parenthesis circled-plus left-parenthesis e 1 circled-times x 1 right-parenthesis circled-plus left-parenthesis e 2 circled-times x 2 right-parenthesis right-parenthesis circled-times d 2nd Row 1st Column Blank 2nd Column element-of left-parenthesis e 0 x 0 left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus e 1 x 1 left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus e 2 x 2 left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared right-parenthesis d left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis 3rd Row 1st Column Blank 2nd Column subset-of left-parenthesis e 0 x 0 left-parenthesis 1 plus-or-minus gamma 4 right-parenthesis plus e 1 x 1 left-parenthesis 1 plus-or-minus gamma 4 right-parenthesis plus e 2 x 2 left-parenthesis 1 plus-or-minus gamma 3 right-parenthesis right-parenthesis d period EndLayout", display: true) $

#parec[
  Using the bounds on #source-math("/chapter-6-Shapes/supplements/6.8-math/source-277.svg", 1.209, 2.176, 0.338, "d"),
][
  代入 $d$ 的界：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-278.svg", 49.216, 9.509, 4.171, "StartLayout 1st Row 1st Column x 2nd Column element-of StartFraction e 0 x 0 left-parenthesis 1 plus-or-minus gamma 7 right-parenthesis plus e 1 x 1 left-parenthesis 1 plus-or-minus gamma 7 right-parenthesis plus e 2 x 2 left-parenthesis 1 plus-or-minus gamma 6 right-parenthesis Over e 0 plus e 1 plus e 2 EndFraction 2nd Row 1st Column Blank 2nd Column equals b 0 x 0 left-parenthesis 1 plus-or-minus gamma 7 right-parenthesis plus b 1 x 1 left-parenthesis 1 plus-or-minus gamma 7 right-parenthesis plus b 2 x 2 left-parenthesis 1 plus-or-minus gamma 6 right-parenthesis period EndLayout", display: true) $

#parec[
  Thus, we can finally see that the absolute error in the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-279.svg", 2.231, 2.343, 0.338, "x prime") value is in the interval
][
  最终可见，计算所得 $x'$ 的绝对误差位于以下区间：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-280.svg", 28.218, 2.676, 0.838, "plus-or-minus b 0 x 0 gamma 7 plus-or-minus b 1 x 1 gamma 7 plus-or-minus b 2 x 2 gamma 7 comma", display: true) $

#parec[
  which is bounded by
][
  其大小受下式约束：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-281.svg", 27.584, 2.843, 0.838, "gamma 7 left-parenthesis StartAbsoluteValue b 0 x 0 EndAbsoluteValue plus StartAbsoluteValue b 1 x 1 EndAbsoluteValue plus StartAbsoluteValue b 2 x 2 EndAbsoluteValue right-parenthesis period", display: true) $ <tri-error>

#parec[
  (Note that the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-282.svg", 4.436, 2.509, 0.671, "b 2 x 2") term could have a #source-math("/chapter-6-Shapes/supplements/6.8-math/source-283.svg", 2.259, 2.176, 0.838, "gamma 6") factor instead of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-284.svg", 2.259, 2.176, 0.838, "gamma 7"), but the difference between the two is very small, so we choose a slightly simpler final expression.) Equivalent bounds hold for #source-math("/chapter-6-Shapes/supplements/6.8-math/source-285.svg", 2.041, 2.676, 0.671, "y prime") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-286.svg", 1.989, 2.343, 0.338, "z prime").
][
  $b_2 x_2$ 项实际上可以使用 $gamma_6$ 而非 $gamma_7$，但差异很小，因此选择稍简单的最终形式。$y'$ 和 $z'$ 也有等价的误差界。
]

#parec[
  @eqt:tri-error lets us bound the error in the interpolated point computed in #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#Triangle::Intersect")[`Triangle::Intersect()`].
][
  @eqt:tri-error 给出了 `Triangle::Intersect()` 中插值位置的误差界。
]

#block(sticky:true)[#raw("<<Compute error bounds pError for triangle intersection>>=")] <fragment-ComputeerrorboundsmonopErrorfortriangleintersection-0>
```cpp
Point3f pAbsSum = Abs(ti.b0 * p0) + Abs(ti.b1 * p1) + Abs(ti.b2 * p2);
Vector3f pError = gamma(7) * Vector3f(pAbsSum);
```

#parec[
  The bounds for a sampled point on a triangle can be found in a similar manner.
][
  三角形上采样点的误差界可按类似方式求得。
]

#block(sticky:true)[#raw("<<Compute error bounds pError for sampled point on triangle>>=")] <fragment-ComputeerrorboundsmonopErrorforsampledpointontriangle-0>
```cpp
Point3f pAbsSum = Abs(b[0] * p0) + Abs(b[1] * p1) +
                  Abs((1 - b[0] - b[1]) * p2);
Vector3f pError = Vector3f(gamma(6) * pAbsSum);
```

#heading(level: 4, numbering: none)[#ez_caption[Parametric Evaluation: Bilinear Patches][参数求值：双线性面片]]
<rounding-parametric-bilinear>

#parec[
  Bilinear patch intersection points are found by evaluating the bilinear function from Equation (#link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#eq:blp-definition")[6.11]). The computation performed is
][
  双线性面片的交点由式（6.11）的双线性函数求值得到，实际计算为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-287.svg", 71.914, 3.009, 1.005, "left-bracket left-parenthesis 1 minus u right-parenthesis circled-times left-parenthesis left-parenthesis 1 minus v right-parenthesis circled-times normal p Subscript 0 comma 0 Baseline circled-plus v circled-times normal p Subscript 0 comma 1 Baseline right-parenthesis right-bracket circled-plus left-bracket u circled-times left-parenthesis left-parenthesis 1 minus v right-parenthesis circled-times normal p Subscript 1 comma 0 Baseline circled-plus v circled-times normal p Subscript 1 comma 1 Baseline right-parenthesis right-bracket period", display: true) $

#parec[
  Considering just the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-288.svg", 1.33, 1.676, 0.338, "x") coordinate, we can find that its error is bounded by
][
  仅考虑 $x$ 坐标，可推得其误差受下式约束：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-289.svg", 71.108, 3.009, 1.005, "gamma 6 StartAbsoluteValue left-parenthesis 1 minus u right-parenthesis left-parenthesis 1 minus v right-parenthesis x Subscript 0 comma 0 Baseline EndAbsoluteValue plus gamma 5 StartAbsoluteValue left-parenthesis 1 minus u right-parenthesis v x Subscript 0 comma 1 Baseline EndAbsoluteValue plus gamma 5 StartAbsoluteValue u left-parenthesis 1 minus v right-parenthesis x Subscript 1 comma 0 Baseline EndAbsoluteValue plus gamma 4 StartAbsoluteValue u v x Subscript 1 comma 1 Baseline EndAbsoluteValue period", display: true) $

#parec[
  Because #source-math("/chapter-6-Shapes/supplements/6.8-math/source-290.svg", 1.33, 1.676, 0.338, "u") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-291.svg", 1.128, 1.676, 0.338, "v") are between 0 and 1, here we will use the looser but more computationally efficient bounds of the form
][
  因为 $u$、$v$ 均在 0 到 1 之间，这里采用更松但计算更高效的界：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-292.svg", 33.838, 3.009, 1.005, "gamma 6 left-parenthesis StartAbsoluteValue x Subscript 0 comma 0 Baseline EndAbsoluteValue plus StartAbsoluteValue x Subscript 0 comma 1 Baseline EndAbsoluteValue plus StartAbsoluteValue x Subscript 1 comma 0 Baseline EndAbsoluteValue plus StartAbsoluteValue x Subscript 1 comma 1 Baseline EndAbsoluteValue right-parenthesis period", display: true) $

#block(sticky:true)[#raw("<<Initialize bilinear patch intersection point error pError>>=")] <fragment-InitializebilinearpatchintersectionpointerrormonopError-0>
```cpp
Point3f pAbsSum = Abs(p00) + Abs(p01) + Abs(p10) + Abs(p11);
Vector3f pError = gamma(6) * Vector3f(pAbsSum);
```

#parec[
  The same bounds apply for points sampled in the #link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#BilinearPatch::Sample")[`BilinearPatch::Sample()`] method.
][
  `BilinearPatch::Sample()` 采样点也使用相同的界。
]

#block(sticky:true)[#raw("<<Compute pError for sampled bilinear patch (u, v)>>=")] <fragment-ComputemonopErrorforsampledbilinearpatchuv-0>
```cpp
Point3f pAbsSum = Abs(p00) + Abs(p01) + Abs(p10) + Abs(p11);
Vector3f pError = gamma(6) * Vector3f(pAbsSum);
```

#heading(level: 4, numbering: none)[#ez_caption[Parametric Evaluation: Curves][参数求值：曲线]]
<rounding-parametric-curves>

#parec[
  Because the #link("https://pbr-book.org/4ed/Shapes/Curves.html#Curve")[`Curve`] shape orients itself to face incident rays, rays leaving it must be offset by the curve’s width in order to not incorrectly reintersect it when it is reoriented to face them. For wide curves, this bound is significant and may lead to visible errors in images. In that case, the #link("https://pbr-book.org/4ed/Shapes/Curves.html#Curve")[`Curve`] shape should probably be replaced with one or more bilinear patches.
][
  `Curve` 会重新朝向入射射线，因此从曲线发出的射线必须偏移一个曲线宽度，以免曲线转向后错误地再次与之相交。对于宽曲线，这个界较大，可能造成可见的图像错误；此时最好用一个或多个双线性面片替代 `Curve`。
]

#block(sticky:true)[#raw("<<Compute error bounds for curve intersection>>=")] <fragment-Computeerrorboundsforcurveintersection-0>
```cpp
Vector3f pError(hitWidth, hitWidth, hitWidth);
```

#heading(level: 4, numbering: none)[#ez_caption[Effect of Transformations][变换的影响]]
<effect-of-transformations>

#parec[
  The last detail to attend to in order to bound the error in computed intersection points is the effect of transformations, which introduce additional rounding error when they are applied.
][
  最后还必须考虑变换：应用变换会引入额外舍入误差。
]

#parec[
  The quadric `Shape`s in `pbrt` transform rendering-space rays into object space before performing ray–shape intersections, and then transform computed intersection points back to rendering space. Both of these transformation steps introduce rounding error that needs to be accounted for in order to maintain robust rendering-space bounds around intersection points.
][
  `pbrt` 的二次曲面形状先将渲染空间射线变换到对象空间求交，再将交点变回渲染空间。这两步都会产生舍入误差；为了在渲染空间中保持交点周围误差界的稳健性，必须将二者计入。
]

#parec[
  If possible, it is best to try to avoid coordinate-system transformations of rays and intersection points. For example, it is better to transform triangle vertices to rendering space and intersect rendering-space rays with them than to transform rays to object space and then transform intersection points to rendering space.#footnote[Although rounding error is introduced when transforming triangle vertices to rendering space (for example), this error does not add error that needs to be handled in computing intersection points. In other words, the transformed vertices may represent a perturbed representation of the scene, but they are the most accurate representation available given the transformation.] Transformations are still useful—for example, for the quadrics and for object instancing—so we will show how to bound the error that they introduce.
][
  条件允许时，应尽量避免变换射线和交点。例如，将三角形顶点预先变换到渲染空间，再与渲染空间射线求交，比先将射线变到对象空间、然后把交点变回渲染空间更好。#footnote[例如，将三角形顶点变换到渲染空间虽会引入舍入误差，但无需在求交计算中再额外处理这些误差。变换后的顶点可视为场景的一个轻微扰动版本，但它们已经是给定变换下可获得的最准确表示。]但二次曲面和对象实例化等场合仍需变换，所以下面推导它引入的误差界。
]

#parec[
  We will discuss these topics in the context of the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[`Transform`] `operator()` method that takes a #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Point3fi")[`Point3fi`], which is the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3")[`Point3`] variant that uses an #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] for each of the coordinates.
][
  以下围绕接受 `Point3fi` 的 `Transform::operator()` 展开。`Point3fi` 是每个坐标都使用 `Interval` 的 `Point3` 变体。
]

#block(sticky:true)[#raw("<<Transform Public Methods>>+=")] <fragment-TransformPublicMethods-9>
```cpp
Point3fi operator()(const Point3fi &p) const {
    Float x = Float(p.x), y = Float(p.y), z = Float(p.z);
    <<Compute transformed coordinates from point (x, y, z)>> 
    <<Compute absolute error for transformed point, pError>> 
    if (wp == 1)
        return Point3fi(Point3f(xp, yp, zp), pError);
    else
        return Point3fi(Point3f(xp, yp, zp), pError) / wp;
}
```

#parec[
  This method starts by computing the transformed position of the point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-294.svg", 7.432, 2.843, 0.838, "left-parenthesis x comma y comma z right-parenthesis") where each coordinate is at the midpoint of its respective interval in `p`. The fragment that implements that computation, 〈Compute transformed coordinates from point `(x, y, z)`〉, is not included here; it implements the same matrix/point multiplication as in Section #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Applying_Transformations.html#sec:applying-transforms")[3.10].
][
  先取 `p` 各坐标区间的中点 $(x,y,z)$，计算变换后的位置。〈Compute transformed coordinates from point (x, y, z)〉正文不再列出，其矩阵与点乘法与第 3.10 节相同。
]

#parec[
  Next, error bounds are computed, accounting both for rounding error when applying the transformation as well as the effect of non-empty intervals, if `p` is not exact.
][
  随后计算误差界，同时考虑变换运算本身的舍入误差，以及 `p` 不精确时非零宽度区间带来的误差。
]

#block(sticky:true)[#raw("<<Compute absolute error for transformed point, pError>>=")] <fragment-ComputeabsoluteerrorfortransformedpointmonopError-0>
```cpp
Vector3f pError;
if (p.IsExact()) {
    <<Compute error for transformed exact p>> 
} else {
    <<Compute error for transformed approximate p>> 
}
```

#parec[
  If #source-math("/chapter-6-Shapes/supplements/6.8-math/source-295.svg", 7.432, 2.843, 0.838, "left-parenthesis x comma y comma z right-parenthesis") has no accumulated error, then given a #source-math("/chapter-6-Shapes/supplements/6.8-math/source-296.svg", 5.165, 2.176, 0.338, "4 times 4") non-projective transformation matrix with elements denoted by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-297.svg", 3.975, 2.343, 1.005, "m Subscript i comma j"), the transformed coordinate #source-math("/chapter-6-Shapes/supplements/6.8-math/source-298.svg", 2.231, 2.343, 0.338, "x prime") is
][
  若 $(x,y,z)$ 没有累积误差，给定元素为 $m_(i,j)$ 的 $4 times 4$ 非投影变换矩阵，变换后的 $x'$ 为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-299.svg", 79.764, 14.176, 6.312, "StartLayout 1st Row 1st Column x prime 2nd Column equals left-parenthesis left-parenthesis m Subscript 0 comma 0 Baseline circled-times x right-parenthesis circled-plus left-parenthesis m Subscript 0 comma 1 Baseline circled-times y right-parenthesis right-parenthesis circled-plus left-parenthesis left-parenthesis m Subscript 0 comma 2 Baseline circled-times z right-parenthesis circled-plus m Subscript 0 comma 3 Baseline right-parenthesis 2nd Row 1st Column Blank 2nd Column element-of m Subscript 0 comma 0 Baseline x left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus m Subscript 0 comma 1 Baseline y left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus m Subscript 0 comma 2 Baseline z left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus m Subscript 0 comma 3 Baseline left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared 3rd Row 1st Column Blank 2nd Column subset-of left-parenthesis m Subscript 0 comma 0 Baseline x plus m Subscript 0 comma 1 Baseline y plus m Subscript 0 comma 2 Baseline z plus m Subscript 0 comma 3 Baseline right-parenthesis plus gamma 3 left-parenthesis plus-or-minus m Subscript 0 comma 0 Baseline x plus-or-minus m Subscript 0 comma 1 Baseline y plus-or-minus m Subscript 0 comma 2 Baseline z plus-or-minus m Subscript 0 comma 3 Baseline right-parenthesis 4th Row 1st Column Blank 2nd Column subset-of left-parenthesis m Subscript 0 comma 0 Baseline x plus m Subscript 0 comma 1 Baseline y plus m Subscript 0 comma 2 Baseline z plus m Subscript 0 comma 3 Baseline right-parenthesis plus-or-minus gamma 3 left-parenthesis StartAbsoluteValue m Subscript 0 comma 0 Baseline x EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 1 Baseline y EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 2 Baseline z EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 3 Baseline EndAbsoluteValue right-parenthesis period EndLayout", display: true) $

#parec[
  Thus, the absolute error in the result is bounded by
][
  因此，结果的绝对误差受下式约束：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-300.svg", 39.461, 3.009, 1.005, "gamma 3 left-parenthesis StartAbsoluteValue m Subscript 0 comma 0 Baseline x EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 1 Baseline y EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 2 Baseline z EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 3 Baseline EndAbsoluteValue right-parenthesis period", display: true) $ <transform-point-error>

#parec[
  Similar bounds follow for the transformed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-301.svg", 2.041, 2.676, 0.671, "y prime") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-302.svg", 1.989, 2.343, 0.338, "z prime") coordinates, and the implementation follows directly.
][
  $y'$、$z'$ 可类似推导，代码直接实现这些界。
]

#block(sticky:true)[#raw("<<Compute error for transformed exact p>>=")] <fragment-Computeerrorfortransformedexactmonop-0>
```cpp
pError.x = gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
                       std::abs(m[0][2] * z) + std::abs(m[0][3]));
pError.y = gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
                       std::abs(m[1][2] * z) + std::abs(m[1][3]));
pError.z = gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
                       std::abs(m[2][2] * z) + std::abs(m[2][3]));
```

#parec[
  Now consider the case of the point `p` having error that is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-303.svg", 2.205, 2.509, 0.671, "delta Subscript x"), #source-math("/chapter-6-Shapes/supplements/6.8-math/source-304.svg", 2.07, 2.843, 1.005, "delta Subscript y"), and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-305.svg", 2.032, 2.509, 0.671, "delta Subscript z") in each dimension. The transformed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-306.svg", 1.33, 1.676, 0.338, "x") coordinate is given by:
][
  再考虑 `p` 各维误差分别由 $delta_x$、$delta_y$、$delta_z$ 约束的情况。变换后的 $x$ 坐标为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-307.svg", 67.945, 3.176, 1.005, "x prime equals left-parenthesis m Subscript 0 comma 0 Baseline circled-times left-parenthesis x plus-or-minus delta Subscript x Baseline right-parenthesis circled-plus m Subscript 0 comma 1 Baseline circled-times left-parenthesis y plus-or-minus delta Subscript y Baseline right-parenthesis right-parenthesis circled-plus left-parenthesis m Subscript 0 comma 2 Baseline circled-times left-parenthesis z plus-or-minus delta Subscript z Baseline right-parenthesis circled-plus m Subscript 0 comma 3 Baseline right-parenthesis period", display: true) $

#parec[
  Applying the definitions of floating-point addition and multiplication and their error bounds, we have
][
  应用浮点加法、乘法及其误差界的定义，得到：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-308.svg", 52.536, 7.176, 3.005, "StartLayout 1st Row 1st Column x prime 2nd Column equals m Subscript 0 comma 0 Baseline left-parenthesis x plus-or-minus delta Subscript x Baseline right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus m Subscript 0 comma 1 Baseline left-parenthesis y plus-or-minus delta Subscript y Baseline right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed 2nd Row 1st Column Blank 2nd Column plus m Subscript 0 comma 2 Baseline left-parenthesis z plus-or-minus delta Subscript z Baseline right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis cubed plus m Subscript 0 comma 3 Baseline left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis squared period EndLayout", display: true) $

#parec[
  Transforming to use #source-math("/chapter-6-Shapes/supplements/6.8-math/source-309.svg", 1.262, 2.176, 0.838, "gamma"), we can find the absolute error term to be bounded by
][
  改用 $gamma$ 记号，可将绝对误差项界定为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-310.svg", 61.836, 6.843, 2.838, "StartLayout 1st Row 1st Column left-parenthesis gamma 3 plus 1 right-parenthesis left-parenthesis StartAbsoluteValue m Subscript 0 comma 0 Baseline EndAbsoluteValue delta Subscript x Baseline 2nd Column plus StartAbsoluteValue m Subscript 0 comma 1 Baseline EndAbsoluteValue delta Subscript y Baseline plus StartAbsoluteValue m Subscript 0 comma 2 Baseline EndAbsoluteValue delta Subscript z Baseline right-parenthesis 2nd Row 1st Column Blank 2nd Column plus gamma 3 left-parenthesis StartAbsoluteValue m Subscript 0 comma 0 Baseline x EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 1 Baseline y EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 2 Baseline z EndAbsoluteValue plus StartAbsoluteValue m Subscript 0 comma 3 Baseline EndAbsoluteValue right-parenthesis period EndLayout", display: true) $ <transform-point-with-error-error>

#parec[
  We have not included the fragment 〈Compute error for transformed approximate `p`〉 that implements this computation, as it is nearly 20 lines of code for the direct translation of @eqt:transform-point-with-error-error.
][
  〈Compute error for transformed approximate p〉直接将@eqt:transform-point-with-error-error 翻译为近 20 行代码，因此正文不列出。
]

#parec[
  It would have been much easier to implement this method using the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Interval")[`Interval`] class to automatically compute error bounds. We found that that approach gives bounds that are generally 3–6#source-math("/chapter-6-Shapes/supplements/6.8-math/source-311.svg", 1.808, 1.509, -0.019, "times") wider and cause the method to be six times slower than the implementation presented here. Given that transformations are frequently applied during rendering, deriving and then using tighter bounds is worthwhile.
][
  使用 `Interval` 自动计算误差界，会更容易实现。但实测得到的界通常宽 3–6 倍，方法运行速度也慢约 6 倍。渲染中频繁使用变换，因此值得推导并使用更紧的界。
]

#parec[
  Note that the code that computes error bounds is buggy if the matrix is projective and the homogeneous #source-math("/chapter-6-Shapes/supplements/6.8-math/source-312.svg", 1.664, 1.676, 0.338, "w") coordinate of the projected point is not one; this nit is not currently a problem for `pbrt`’s usage of this method.
][
  注意，如果矩阵是投影变换，且变换后点的齐次坐标 $w$ 不为 1，这段误差界代码就有缺陷；`pbrt` 目前对该方法的使用未触及此问题。
]

#parec[
  The `Transform` class also provides methods to transform vectors and rays, returning the resulting error. The vector error bound derivations (and thence, implementations) are very similar to those for points, and so also are not included here.
][
  `Transform` 也提供变换向量和射线并返回误差的方法。向量误差界的推导与点很相似，代码也类似，因此正文不再列出。
]

=== #ez_caption[Robust Spawned Ray Origins][稳健的新射线起点]
<robust-spawned-ray-origins>

#parec[
  Computed intersection points and their error bounds give us a small 3D box that bounds a region of space. We know that the precise intersection point must be somewhere inside this box and that thus the surface must pass through the box (at least enough to present the point where the intersection is). (Recall @fig:basic-error-setting.) Having these boxes makes it possible to position the origins of rays leaving the surface so that they are always on the right side of the surface and do not incorrectly reintersect it. When tracing spawned rays leaving the intersection point #source-math("/chapter-6-Shapes/supplements/6.8-math/source-313.svg", 1.293, 2.009, 0.671, "normal p Subscript"), we offset their origins enough to ensure that they are past the boundary of the error box and thus will not incorrectly reintersect the surface.
][
  计算交点及其误差界给出一个很小的三维包围盒。精确交点必在盒内，真实表面也必经过盒子，至少经过交点处（见@fig:basic-error-setting）。利用这个盒子，可把离开表面的射线起点放在正确的一侧，避免错误自相交。对从交点 $p$ 发出的射线，将起点偏移到误差盒边界之外即可。
]

#parec[
  In order to ensure that the spawned ray origin is definitely on the right side of the surface, we move far enough along the normal so that the plane perpendicular to the normal is outside the error bounding box. To see how to do this, consider a computed intersection point at the origin, where the equation for the plane going through the intersection point is
][
  为确保新射线起点位于表面正确一侧，沿法向量移动足够远，使通过偏移点且垂直于法向量的平面位于误差盒之外。先设计算交点位于原点，则经过该点的平面方程为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-314.svg", 29.362, 3.009, 1.005, "f left-parenthesis x comma y comma z right-parenthesis equals bold n Subscript Baseline Subscript x Baseline x plus bold n Subscript Baseline Subscript y Baseline y plus bold n Subscript Baseline Subscript z Baseline z period", display: true) $

#parec[
  The plane is implicitly defined by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-315.svg", 12.976, 2.843, 0.838, "f left-parenthesis x comma y comma z right-parenthesis equals 0"), and the normal is #source-math("/chapter-6-Shapes/supplements/6.8-math/source-316.svg", 11.543, 3.009, 1.005, "left-parenthesis bold n Subscript Baseline Subscript x Baseline comma bold n Subscript Baseline Subscript y Baseline comma bold n Subscript Baseline Subscript z Baseline right-parenthesis").
][
  平面由 $f(x,y,z)=0$ 隐式定义，法向量为 $(n_x,n_y,n_z)$。
]

#parec[
  For a point not on the plane, the value of the plane equation #source-math("/chapter-6-Shapes/supplements/6.8-math/source-317.svg", 8.715, 2.843, 0.838, "f left-parenthesis x comma y comma z right-parenthesis") gives the offset along the normal that gives a plane that goes through the point. We would like to find the maximum value of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-318.svg", 8.715, 2.843, 0.838, "f left-parenthesis x comma y comma z right-parenthesis") for the eight corners of the error bounding box; if we offset the plane plus and minus this offset, we have two planes that do not intersect the error box that should be (locally) on opposite sides of the surface, at least at the computed intersection point offset along the normal (@fig:spawned-rays).
][
  对不在平面上的点，$f(x,y,z)$ 给出沿法向量偏移平面、使其经过该点所需的距离。求误差盒八个角点处 $f$ 的最大值，再分别向正负方向偏移，即可得到两个不穿过误差盒的平面；在局部，至少沿计算交点的法线位置，它们应分居真实表面两侧（@fig:spawned-rays）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f45.svg"), caption:[#ez_caption[Given a computed intersection point (filled circle) with surface normal (arrow) and error bounds (rectangle), we compute two planes offset along the normal that are offset just far enough so that they do not intersect the error bounds. The points on these planes along the normal from the computed intersection point give us the origins for spawned rays (open circles); one of the two is selected based on the ray direction so that the spawned ray will not pass through the error bounding box. By construction, such rays cannot incorrectly reintersect the actual surface (thick line).][给定计算交点（实心圆点）、表面法向量（箭头）与误差界（矩形），沿法线偏移出两个恰好不穿过误差盒的平面。计算交点沿法线到这两个平面的点（空心圆点）可作为新射线起点；根据射线方向选择其中一个，使射线不穿过误差盒。按这一构造，射线不会错误地再次与真实表面（粗线）相交。]]) <spawned-rays>

#parec[
  If the eight corners of the error bounding box are given by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-319.svg", 15.609, 3.009, 1.005, "left-parenthesis plus-or-minus delta Subscript x Baseline comma plus-or-minus delta Subscript y Baseline comma plus-or-minus delta Subscript z Baseline right-parenthesis"), then the maximum value of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-320.svg", 8.715, 2.843, 0.838, "f left-parenthesis x comma y comma z right-parenthesis") is easily computed:
][
  若八个角点为 $(plus.minus delta_x,plus.minus delta_y,plus.minus delta_z)$，则 $f$ 的最大值很容易计算：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-321.svg", 28.49, 3.009, 1.005, "d equals StartAbsoluteValue bold n Subscript Baseline Subscript x Baseline EndAbsoluteValue delta Subscript x Baseline plus StartAbsoluteValue bold n Subscript Baseline Subscript y Baseline EndAbsoluteValue delta Subscript y Baseline plus StartAbsoluteValue bold n Subscript Baseline Subscript z Baseline EndAbsoluteValue delta Subscript z Baseline period", display: true) $

#parec[
  Computing spawned ray origins by offsetting along the surface normal in this way has a few advantages: assuming that the surface is locally planar (a reasonable assumption, especially at the very small scale of the intersection point error bounds), moving along the normal allows us to get from one side of the surface to the other while moving the shortest distance. In general, minimizing the distance that ray origins are offset is desirable for maintaining shadow and reflection detail.
][
  这样沿法线偏移有几项优势。假设表面局部近似平面——在交点误差盒如此微小的尺度下，这通常合理——沿法线移动可用最短距离跨过表面。尽量减小偏移距离有助于保留阴影和反射细节。
]

#parec[
  `OffsetRayOrigin()` is a short function that implements this computation.
][
  短小的 `OffsetRayOrigin()` 函数实现这一计算。
]

#block(sticky:true)[#raw("<<Ray Inline Functions>>=")] <fragment-RayInlineFunctions-0>
```cpp
Point3f OffsetRayOrigin(Point3fi pi, Normal3f n, Vector3f w) {
    <<Find vector offset to corner of error bounds and compute initial po>> 
    <<Round offset point po away from p>> 
    return po;
}
```

#block(sticky:true)[#raw("<<Find vector offset to corner of error bounds and compute initial po>>=")] <fragment-Findvectormonooffsettocorneroferrorboundsandcomputeinitialmonopo-0>
```cpp
Float d = Dot(Abs(n), pi.Error());
Vector3f offset = d * Vector3f(n);
if (Dot(w, n) < 0)
    offset = -offset;
Point3f po = Point3f(pi) + offset;
```

#figure(image("../pbr-book-website/4ed/Shapes/pha06f46.svg"), caption:[#ez_caption[The rounded value of the offset point `p+offset` computed in `OffsetRayOrigin()` may end up in the interior of the error box rather than on its boundary, which in turn introduces the risk of incorrect self-intersections if the rounded point is on the wrong side of the surface. Advancing each coordinate of the computed point one floating-point value away from `p` ensures that it is outside of the error box.][OffsetRayOrigin() 中的偏移点 p+offset 舍入后可能落到误差盒内部，而非边界。如果它落在表面错误一侧，就有自相交风险。将计算点每个坐标推进到远离 p 的下一个浮点值，确保它位于误差盒外。]]) <offset-ray-origin-round-up>

#parec[
  We also must handle round-off error when computing the offset point: when `offset` is added to `p`, the result will in general need to be rounded to the nearest floating-point value. In turn, it may be rounded down toward `p` such that the resulting point is in the interior of the error box rather than on its boundary (@fig:offset-ray-origin-round-up). Therefore, the offset point is rounded away from `p` here to ensure that it is not inside the box.#footnote[The observant reader may now wonder about the effect of rounding error when computing the error bounds that are passed into this function. Indeed, these bounds should also be computed with rounding toward positive infinity. We ignore that issue under the expectation that the additional offset of one ulp here will be enough to cover that error.]
][
  还需处理计算偏移点本身的舍入误差。`offset` 加到 `p` 后通常需要舍入，可能向 `p` 舍入，使结果落到误差盒内部而非边界上（@fig:offset-ray-origin-round-up）。因此，还要将结果向远离 `p` 的方向舍入，确保它在盒外。#footnote[细心的读者可能会问，传入本函数的误差界本身在计算时是否也有舍入误差。确实，这些界也应向正无穷方向舍入。本实现忽略了这一问题，期望这里额外一个 ulp 的偏移足以覆盖这部分误差。]
]

#parec[
  Alternatively, the floating-point rounding mode could have been set to round toward plus or minus infinity (based on the sign of the value). Changing the rounding mode is fairly expensive on many processors, so we just shift the floating-point value by one ulp here. This will sometimes cause a value already outside of the error box to go slightly farther outside it, but because the floating-point spacing is so small, this is not a problem in practice.
][
  另一选择是根据符号把浮点舍入模式设为向正无穷或负无穷舍入。但许多处理器上切换舍入模式代价较高，因此这里只将浮点值移动一个 ulp。已经在盒外的点有时会因此再向外移动一点，但浮点间距很小，实际影响不大。
]

#block(sticky:true)[#raw("<<Round offset point po away from p>>=")] <fragment-Roundoffsetpointmonopoawayfrommonop-0>
```cpp
for (int i = 0; i < 3; ++i) {
    if (offset[i] > 0)      po[i] = NextFloatUp(po[i]);
    else if (offset[i] < 0) po[i] = NextFloatDown(po[i]);
}
```

#parec[
  For convenience, #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] provides two variants of this functionality via methods that perform the ray offset computation using its stored position and surface normal. The first takes a ray direction, like the stand-alone `OffsetRayOrigin()` function.
][
  为方便使用，`Interaction` 提供两个方法，利用自身保存的位置和法向量执行偏移。第一个与独立的 `OffsetRayOrigin()` 一样，接收射线方向。
]

#block(sticky:true)[#raw("<<Interaction Public Methods>>+=")] <fragment-InteractionPublicMethods-4>
```cpp
Point3f OffsetRayOrigin(Vector3f w) const {
    return pbrt::OffsetRayOrigin(pi, n, w);
}
```

#parec[
  The second takes a position for the ray’s destination that is used to compute a direction `w` to pass to the first method.
][
  第二个接收射线目标位置，据此计算方向 `w`，再调用第一个方法。
]

#block(sticky:true)[#raw("<<Interaction Public Methods>>+=")] <fragment-InteractionPublicMethods-5>
```cpp
Point3f OffsetRayOrigin(Point3f pt) const {
    return OffsetRayOrigin(pt - p());
}
```

#parec[
  There are also some helper functions for the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`] class that generate rays leaving intersection points that account for these offsets.
][
  还提供若干 `Ray` 辅助函数，用于生成考虑这些偏移的、离开交点的射线。
]

#block(sticky:true)[#raw("<<Ray Inline Functions>>+=")] <fragment-RayInlineFunctions-1>
```cpp
Ray SpawnRay(Point3fi pi, Normal3f n, Float time, Vector3f d) {
    return Ray(OffsetRayOrigin(pi, n, d), d, time);
}
```

#block(sticky:true)[#raw("<<Ray Inline Functions>>+=")] <fragment-RayInlineFunctions-2>
```cpp
Ray SpawnRayTo(Point3fi pFrom, Normal3f n, Float time, Point3f pTo) {
    Vector3f d = pTo - Point3f(pFrom);
    return SpawnRay(pFrom, n, time, d);
}
```

#parec[
  To generate a ray between two points requires offsets at both endpoints before the vector between them is computed.
][
  生成连接两点的射线时，必须先偏移两个端点，再计算它们之间的向量。
]

#block(sticky:true)[#raw("<<Ray Inline Functions>>+=")] <fragment-RayInlineFunctions-3>
```cpp
Ray SpawnRayTo(Point3fi pFrom, Normal3f nFrom, Float time, Point3fi pTo,
               Normal3f nTo) {
    Point3f pf = OffsetRayOrigin(pFrom, nFrom,
                                 Point3f(pTo) - Point3f(pFrom));
    Point3f pt = OffsetRayOrigin(pTo, nTo, pf - Point3f(pTo));
    return Ray(pf, pt - pf, time);
}
```

#parec[
  We can also implement #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] methods that generate rays leaving intersection points.
][
  也可在 `Interaction` 中实现从交点发出射线的方法。
]

#block(sticky:true)[#raw("<<Interaction Public Methods>>+=")] <fragment-InteractionPublicMethods-6>
```cpp
RayDifferential SpawnRay(Vector3f d) const {
    return RayDifferential(OffsetRayOrigin(d), d, time, GetMedium(d));
}
```

#block(sticky:true)[#raw("<<Interaction Public Methods>>+=")] <fragment-InteractionPublicMethods-7>
```cpp
Ray SpawnRayTo(Point3f p2) const {
    Ray r = pbrt::SpawnRayTo(pi, n, time, p2);
    r.medium = GetMedium(r.d);
    return r;
}
```

#parec[
  A variant of `Interaction::SpawnRayTo()` that takes an #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] is similar and not included here.
][
  另一个接受 `Interaction` 的 `Interaction::SpawnRayTo()` 版本与此类似，正文不列出。
]

#parec[
  The #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#ShapeSampleContext")[`ShapeSampleContext`] class also provides `OffsetRayOrigin()` and `SpawnRay()` helper methods that correspond to the ones we have added to #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#Interaction")[`Interaction`] here. Their implementations are essentially the same, so they are not included here.
][
  `ShapeSampleContext` 同样提供 `OffsetRayOrigin()`、`SpawnRay()`，对应这里添加到 `Interaction` 的方法。实现基本相同，故不再列出。
]

#parec[
  The approach we have developed so far addresses the effect of floating-point error at the origins of rays leaving surfaces; there is a related issue for shadow rays to area light sources: we would like to find any intersections with shapes that are close to the light source and actually occlude it, while avoiding reporting incorrect intersections with the surface of the light source. Unfortunately, our implementation does not address this issue, so we set the `tMax` value of shadow rays to be just under one so that they stop before the surface of light sources.
][
  目前的方法解决了离开表面的射线起点处的浮点误差。面光源阴影射线还有相关问题：既要找到靠近光源且确实遮挡光源的形状，又不能错误地把光源自身表面判为遮挡。遗憾的是，本实现未解决这一问题；因此将阴影射线的 `tMax` 设为略小于 1，让它在光源表面之前停止。
]

#block(sticky:true)[#raw("<<Mathematical Constants>>=")] <fragment-MathematicalConstants-0>
```cpp
constexpr Float ShadowEpsilon = 0.0001f;
```

#parec[
  One last issue must be dealt with in order to maintain robust spawned ray origins: error introduced when performing transformations. Given a ray in one coordinate system where its origin was carefully computed to be on the appropriate side of some surface, transforming that ray to another coordinate system may introduce error in the transformed origin such that the origin is no longer on the correct side of the surface it was spawned from.
][
  最后还需处理变换引入的误差。即使射线在原坐标系中的起点已谨慎放在表面正确一侧，变换到另一坐标系后，起点误差仍可能使它落到错误的一侧。
]

#parec[
  Therefore, whenever a ray is transformed by the `Ray` variant of `Transform::operator()` (which was implemented in Section #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Applying_Transformations.html#sec:transform-rays")[3.10.4]), its origin is advanced to the edge of the bounds on the error that was introduced by the transformation. This ensures that the origin conservatively remains on the correct side of the surface it was spawned from, if any.
][
  因此，第 3.10.4 节的 `Transform::operator()` 射线版本每次变换射线时，都会将起点推进到变换新增误差界的边缘，以保守地保持它位于原出发表面的正确一侧。
]

#block(sticky:true)[#raw("<<Offset ray origin to edge of error bounds and compute tMax>>=")] <fragment-OffsetrayorigintoedgeoferrorboundsandcomputemonotMax-0>
```cpp
if (Float lengthSquared = LengthSquared(d); lengthSquared > 0) {
    Float dt = Dot(Abs(d), o.Error()) / lengthSquared;
    o += d * dt;
    if (tMax)
        *tMax -= dt;
}
```

=== #ez_caption[Avoiding Intersections behind Ray Origins][避免将射线起点后方交点误报为命中]
<avoiding-intersections-behind-ray-origins>

#parec[
  Bounding the error in computed intersection points allows us to compute ray origins that are guaranteed to be on the right side of the surface so that a ray with infinite precision would not incorrectly intersect the surface it is leaving. However, a second source of rounding error must also be addressed: the error in parametric #source-math("/chapter-6-Shapes/supplements/6.8-math/source-322.svg", 0.84, 2.009, 0.338, "t") values computed for ray–shape intersections. Rounding error can lead to an intersection algorithm computing a value #source-math("/chapter-6-Shapes/supplements/6.8-math/source-323.svg", 5.101, 2.176, 0.338, "t greater-than 0") for the intersection point even though the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-324.svg", 0.84, 2.009, 0.338, "t") value for the actual intersection is negative (and thus should be ignored).
][
  交点误差界使我们能将起点放在表面正确一侧，从而让无限精度射线不会错误地再次与出发表面相交。但还需处理第二个误差来源：求交算出的参数 $t$。即使真实交点的 $t$ 为负、应被忽略，舍入误差仍可能使算法返回 $t>0$。
]

#parec[
  It is possible to show that some intersection test algorithms always return a #source-math("/chapter-6-Shapes/supplements/6.8-math/source-325.svg", 0.84, 2.009, 0.338, "t") value with the correct sign; this is the best case, as no further computation is needed to bound the actual error in the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-326.svg", 0.84, 2.009, 0.338, "t") value. For example, consider the ray–axis-aligned slab computation: #source-math("/chapter-6-Shapes/supplements/6.8-math/source-327.svg", 17.751, 2.843, 0.838, "t equals left-parenthesis x minus normal o Subscript x Baseline right-parenthesis circled-division-slash bold d Subscript x"). The IEEE floating-point standard guarantees that if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-328.svg", 5.326, 2.176, 0.338, "a greater-than b"), then #source-math("/chapter-6-Shapes/supplements/6.8-math/source-329.svg", 9.329, 2.343, 0.505, "a minus b greater-than-or-equal-to 0") (and if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-330.svg", 5.326, 2.176, 0.338, "a less-than b"), then #source-math("/chapter-6-Shapes/supplements/6.8-math/source-331.svg", 9.329, 2.343, 0.505, "a minus b less-than-or-equal-to 0")). To see why this is so, note that if #source-math("/chapter-6-Shapes/supplements/6.8-math/source-332.svg", 5.326, 2.176, 0.338, "a greater-than b"), then the real number #source-math("/chapter-6-Shapes/supplements/6.8-math/source-333.svg", 5.068, 2.343, 0.505, "a minus b") must be greater than zero. When rounded to a floating-point number, the result must be either zero or a positive float; there is no a way a negative floating-point number could be the closest floating-point number. Second, floating-point division returns the correct sign; these together guarantee that the sign of the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-334.svg", 0.84, 2.009, 0.338, "t") value is correct. (Or that #source-math("/chapter-6-Shapes/supplements/6.8-math/source-335.svg", 5.101, 2.176, 0.338, "t equals 0"), but this case is fine, since our test for an intersection is carefully chosen to be #source-math("/chapter-6-Shapes/supplements/6.8-math/source-336.svg", 5.101, 2.176, 0.338, "t greater-than 0").)
][
  某些算法可证明总返回符号正确的 $t$，这是最理想的情况，不必再计算误差界。例如，与轴对齐夹层求交时，$t=(x ⊖ o_x) ⊘ d_x$。IEEE 保证 $a>b$ 时浮点减法 $a ⊖ b>=0$；若 $a<b$，则 $a ⊖ b<=0$。原因是正的精确差值舍入后只能为零或正浮点数，负值不可能离它最近。浮点除法也返回正确符号，二者共同保证 $t$ 的符号正确；也可能得到零，但测试特意使用 $t>0$，因此这种情况可以接受。
]

#parec[
  For shape intersection routines that are based on the `Interval` class, the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-337.svg", 0.84, 2.009, 0.338, "t") value in the end has an error bound associated with it, and no further computation is necessary to perform this test. See the definition of the fragment 〈Check quadric shape `t0` and `t1` for nearest intersection〉 in Section #link("https://pbr-book.org/4ed/Shapes/Spheres.html#sec:sphere-intersection")[6.2.2].
][
  基于 `Interval` 的形状求交，最终 $t$ 已附带误差界，无需额外计算即可进行这一检查。参见第 6.2.2 节〈Check quadric shape t0 and t1 for nearest intersection〉。
]

#heading(level: 4, numbering: none)[#ez_caption[Triangles][三角形]]
<triangles>

#parec[
  `Interval` introduces computational overhead that we would prefer to avoid for more commonly used shapes where efficient intersection code is more important. For these shapes, we can derive efficient-to-evaluate conservative bounds on the error in computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-338.svg", 0.84, 2.009, 0.338, "t") values. The ray–triangle intersection algorithm in Section #link("https://pbr-book.org/4ed/Shapes/Triangle_Meshes.html#sec:ray-triangle")[6.5.3] computes a final #source-math("/chapter-6-Shapes/supplements/6.8-math/source-339.svg", 0.84, 2.009, 0.338, "t") value by computing three edge function values #source-math("/chapter-6-Shapes/supplements/6.8-math/source-340.svg", 1.883, 2.009, 0.671, "e Subscript i") and using them to compute a barycentric-weighted sum of transformed vertex #source-math("/chapter-6-Shapes/supplements/6.8-math/source-341.svg", 1.086, 1.676, 0.338, "z") coordinates, #source-math("/chapter-6-Shapes/supplements/6.8-math/source-342.svg", 1.881, 2.009, 0.671, "z Subscript i"):
][
  对更常用、更看重求交效率的形状，希望避免 `Interval` 开销，可以改为推导易于求值的保守 $t$ 误差界。第 6.5.3 节的三角形算法计算三个边函数 $e_i$，再对变换后顶点的 $z_i$ 作重心加权，得到最终 $t$：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-343.svg", 23.921, 5.343, 2.171, "t equals StartFraction e 0 z 0 plus e 1 z 1 plus e 2 z 2 Over e 0 plus e 1 plus e 2 EndFraction period", display: true) $ <triangle-t>

#parec[
  By successively bounding the error in these terms and then in the final #source-math("/chapter-6-Shapes/supplements/6.8-math/source-344.svg", 0.84, 2.009, 0.338, "t") value, we can conservatively check that it is positive.
][
  依次界定各项误差及最终 $t$ 的误差，就可保守地判断 $t$ 确为正。
]

#block(sticky:true)[#raw("<<Ensure that computed triangle t is conservatively greater than zero>>=")] <fragment-Ensurethatcomputedtriangletisconservativelygreaterthanzero-0>
```cpp
<<Compute delta_z term for triangle t error bounds>> 
<<Compute delta_x and delta_y terms for triangle t error bounds>> 
<<Compute delta_e term for triangle t error bounds>> 
<<Compute delta_t term for triangle t error bounds and check t>>
```

#parec[
  Given a ray #source-math("/chapter-6-Shapes/supplements/6.8-math/source-355.svg", 1.049, 1.676, 0.338, "r") with origin #source-math("/chapter-6-Shapes/supplements/6.8-math/source-356.svg", 1.162, 1.676, 0.338, "normal o"), direction #source-math("/chapter-6-Shapes/supplements/6.8-math/source-357.svg", 1.485, 2.176, 0.338, "bold d"), and a triangle vertex #source-math("/chapter-6-Shapes/supplements/6.8-math/source-358.svg", 1.293, 2.009, 0.671, "normal p Subscript"), the projected #source-math("/chapter-6-Shapes/supplements/6.8-math/source-359.svg", 1.086, 1.676, 0.338, "z") coordinate is
][
  给定起点为 $o$、方向为 $bold(d)$ 的射线 $r$ 和三角形顶点 $p$，投影后的 $z$ 坐标为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-360.svg", 25.074, 2.843, 0.838, "z equals left-parenthesis 1 circled-division-slash bold d Subscript z Baseline right-parenthesis circled-times left-parenthesis normal p Subscript Baseline Subscript z Baseline minus normal o Subscript z Baseline right-parenthesis period", display: true) $

#parec[
  Applying the usual approach, we can find that the maximum error in #source-math("/chapter-6-Shapes/supplements/6.8-math/source-361.svg", 1.881, 2.009, 0.671, "z Subscript i") for each of three vertices of the triangle #source-math("/chapter-6-Shapes/supplements/6.8-math/source-362.svg", 2.092, 2.176, 0.838, "normal p Subscript Baseline Subscript i") is bounded by #source-math("/chapter-6-Shapes/supplements/6.8-math/source-363.svg", 5.433, 2.843, 0.838, "gamma 3 StartAbsoluteValue z Subscript i Baseline EndAbsoluteValue"), and we can thus find a conservative upper bound for the error in #emph[any] of the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-364.svg", 1.086, 1.676, 0.338, "z") positions by taking the maximum of these errors:
][
  用通常的方法可知，三个顶点的各 $z_i$ 误差由 $gamma_3 abs(z_i)$ 界定。取其中最大者，即可得到所有 $z$ 坐标误差的保守上界：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-365.svg", 16.311, 4.009, 2.005, "delta Subscript z Baseline equals gamma 3 max Underscript i Endscripts StartAbsoluteValue z Subscript i Baseline EndAbsoluteValue period", display: true) $

#block(sticky:true)[#raw("<<Compute delta_z term for triangle t error bounds>>=")] <fragment-Computedelta_ztermfortriangleterrorbounds-0>
```cpp
Float maxZt = MaxComponentValue(Abs(Vector3f(p0t.z, p1t.z, p2t.z)));
Float deltaZ = gamma(3) * maxZt;
```

#parec[
  The edge function values are computed as the difference of two products of transformed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-368.svg", 1.33, 1.676, 0.338, "x") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-369.svg", 1.139, 2.009, 0.671, "y") vertex positions:
][
  边函数是变换后顶点 $x$、$y$ 坐标的两个乘积之差：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-370.svg", 27.929, 10.176, 4.505, "StartLayout 1st Row 1st Column e 0 2nd Column equals left-parenthesis x 1 circled-times y 2 right-parenthesis minus left-parenthesis y 1 circled-times x 2 right-parenthesis 2nd Row 1st Column e 1 2nd Column equals left-parenthesis x 2 circled-times y 0 right-parenthesis minus left-parenthesis y 2 circled-times x 0 right-parenthesis 3rd Row 1st Column e 2 2nd Column equals left-parenthesis x 0 circled-times y 1 right-parenthesis minus left-parenthesis y 0 circled-times x 1 right-parenthesis period EndLayout", display: true) $

#parec[
  Bounds for the error in the transformed positions #source-math("/chapter-6-Shapes/supplements/6.8-math/source-371.svg", 2.129, 2.009, 0.671, "x Subscript i") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-372.svg", 1.939, 2.009, 0.671, "y Subscript i") are
][
  变换后 $x_i$、$y_i$ 的误差界为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-373.svg", 29.443, 8.843, 3.838, "StartLayout 1st Row 1st Column delta Subscript x 2nd Column equals gamma 5 left-parenthesis max Underscript i Endscripts StartAbsoluteValue x Subscript i Baseline EndAbsoluteValue plus max Underscript i Endscripts StartAbsoluteValue z Subscript i Baseline EndAbsoluteValue right-parenthesis 2nd Row 1st Column delta Subscript y 2nd Column equals gamma 5 left-parenthesis max Underscript i Endscripts StartAbsoluteValue y Subscript i Baseline EndAbsoluteValue plus max Underscript i Endscripts StartAbsoluteValue z Subscript i Baseline EndAbsoluteValue right-parenthesis period EndLayout", display: true) $

#block(sticky:true)[#raw("<<Compute delta_x and delta_y terms for triangle t error bounds>>=")] <fragment-Computedelta_xanddelta_ytermsfortriangleterrorbounds-0>
```cpp
Float maxXt = MaxComponentValue(Abs(Vector3f(p0t.x, p1t.x, p2t.x)));
Float maxYt = MaxComponentValue(Abs(Vector3f(p0t.y, p1t.y, p2t.y)));
Float deltaX = gamma(5) * (maxXt + maxZt);
Float deltaY = gamma(5) * (maxYt + maxZt);
```

#parec[
  Taking the maximum error over all three of the vertices, the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-377.svg", 7.019, 2.676, 1.005, "x Subscript i Baseline circled-times y Subscript j") products in the edge functions are bounded by
][
  对三个顶点取最大误差后，边函数中的乘积 $x_i ⊗ y_j$ 被下式包围：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-378.svg", 38.66, 4.009, 2.005, "left-parenthesis max Underscript i Endscripts StartAbsoluteValue x Subscript i Baseline EndAbsoluteValue plus delta Subscript x Baseline right-parenthesis left-parenthesis max Underscript i Endscripts StartAbsoluteValue y Subscript i Baseline EndAbsoluteValue plus delta Subscript y Baseline right-parenthesis left-parenthesis 1 plus-or-minus epsilon Subscript normal m Baseline right-parenthesis comma", display: true) $

#parec[
  which have an absolute error bound of
][
  其绝对误差界为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-379.svg", 57.712, 4.009, 2.005, "delta Subscript x y Baseline equals gamma 1 max Underscript i Endscripts StartAbsoluteValue x Subscript i Baseline EndAbsoluteValue max Underscript i Endscripts StartAbsoluteValue y Subscript i Baseline EndAbsoluteValue plus delta Subscript y Baseline max Underscript i Endscripts StartAbsoluteValue x Subscript i Baseline EndAbsoluteValue plus delta Subscript x Baseline max Underscript i Endscripts StartAbsoluteValue y Subscript i Baseline EndAbsoluteValue plus midline-horizontal-ellipsis period", display: true) $

#parec[
  Dropping the (negligible) higher-order terms of products of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-380.svg", 1.262, 2.176, 0.838, "gamma") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-381.svg", 1.051, 2.176, 0.338, "delta") terms, the error bound on the difference of two #source-math("/chapter-6-Shapes/supplements/6.8-math/source-382.svg", 1.33, 1.676, 0.338, "x") and #source-math("/chapter-6-Shapes/supplements/6.8-math/source-383.svg", 1.139, 2.009, 0.671, "y") terms for the edge function is
][
  忽略 $gamma$、$delta$ 乘积中可忽略不计的高阶项，两个 $x$、$y$ 乘积之差的边函数误差界为：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-384.svg", 54.674, 4.009, 2.005, "delta Subscript e Baseline equals 2 left-parenthesis gamma 2 max Underscript i Endscripts StartAbsoluteValue x Subscript i Baseline EndAbsoluteValue max Underscript i Endscripts StartAbsoluteValue y Subscript i Baseline EndAbsoluteValue plus delta Subscript y Baseline max Underscript i Endscripts StartAbsoluteValue x Subscript i Baseline EndAbsoluteValue plus delta Subscript x Baseline max Underscript i Endscripts StartAbsoluteValue y Subscript i Baseline EndAbsoluteValue right-parenthesis period", display: true) $

#block(sticky:true)[#raw("<<Compute delta_e term for triangle t error bounds>>=")] <fragment-Computedelta_etermfortriangleterrorbounds-0>
```cpp
Float deltaE = 2 * (gamma(2) * maxXt * maxYt + deltaY * maxXt +
                    deltaX * maxYt);
```

#parec[
  Again bounding error by taking the maximum of error over all the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-387.svg", 1.883, 2.009, 0.671, "e Subscript i") terms, the error bound for the computed value of the numerator of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-388.svg", 0.84, 2.009, 0.338, "t") in @eqt:triangle-t is
][
  再次对所有 $e_i$ 取最大误差，可以得到@eqt:triangle-t 中 $t$ 的分子计算值的误差界：
]

$ #source-math("/chapter-6-Shapes/supplements/6.8-math/source-389.svg", 53.681, 4.009, 2.005, "delta Subscript t Baseline equals 3 left-parenthesis gamma 3 max Underscript i Endscripts StartAbsoluteValue e Subscript i Baseline EndAbsoluteValue max Underscript i Endscripts StartAbsoluteValue z Subscript i Baseline EndAbsoluteValue plus delta Subscript e Baseline max Underscript i Endscripts StartAbsoluteValue z Subscript i Baseline EndAbsoluteValue plus delta Subscript z Baseline max Underscript i Endscripts StartAbsoluteValue e Subscript i Baseline EndAbsoluteValue right-parenthesis period", display: true) $

#parec[
  A computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-390.svg", 0.84, 2.009, 0.338, "t") value (before normalization by the sum of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-391.svg", 1.883, 2.009, 0.671, "e Subscript i")) must be greater than this value for it to be accepted as a valid intersection that definitely has a positive #source-math("/chapter-6-Shapes/supplements/6.8-math/source-392.svg", 0.84, 2.009, 0.338, "t") value.
][
  归一化除以各 $e_i$ 之和以前，计算值必须大于此误差界，才能接受为 $t$ 确为正的有效交点。
]

#translator([上句沿用原文“归一化之前”的表述；若 $sum_i e_i$ 为负，有效正 $t$ 的分子也应为负，不能直接套用“大于正误差界”的判据。第 6.5.3 节的代码先计算 `t = tScaled * invDet`，下面则将误差界乘以 `abs(invDet)`，实际比较的是归一化后的 $t$ 与正的误差界。], en: [The preceding sentence preserves the source’s “before normalization” wording. If $sum_i e_i$ is negative, a valid positive $t$ also has a negative numerator, so a direct greater-than-positive-bound test would need a sign adjustment. The code in Section 6.5.3 first computes `t = tScaled * invDet`; the code below scales the bound by `abs(invDet)` and compares the normalized $t$ against a positive bound.])

#block(sticky:true)[#raw("<<Compute delta_t term for triangle t error bounds and check t>>=")] <fragment-Computedelta_ttermfortriangleterrorboundsandcheckmonot-0>
```cpp
Float maxE = MaxComponentValue(Abs(Vector3f(e0, e1, e2)));
Float deltaT = 3 * (gamma(3) * maxE * maxZt + deltaE * maxZt +
                    deltaZ * maxE) * std::abs(invDet);
if (t <= deltaT)
    return {};
```

#parec[
  Although it may seem that we have made a number of choices to compute looser bounds than we might have, in practice the bounds on error in #source-math("/chapter-6-Shapes/supplements/6.8-math/source-395.svg", 0.84, 2.009, 0.338, "t") are extremely small. For a regular scene that fills a bounding box roughly #source-math("/chapter-6-Shapes/supplements/6.8-math/source-396.svg", 4.133, 2.343, 0.505, "plus-or-minus 10") in each dimension, our #source-math("/chapter-6-Shapes/supplements/6.8-math/source-397.svg", 0.84, 2.009, 0.338, "t") error bounds near ray origins are generally around #source-math("/chapter-6-Shapes/supplements/6.8-math/source-398.svg", 4.658, 2.676, 0.338, "10 Superscript negative 7").
][
  虽然推导多次选择较松的界，实际 $t$ 误差界仍很小。对每维范围约为 $plus.minus 10$ 的普通场景，射线起点附近的 $t$ 误差界通常约为 $10^(-7)$。
]

#heading(level: 4, numbering: none)[#ez_caption[Bilinear Patches][双线性面片]]
<bilinear-patches>

#parec[
  Recall from Section #link("https://pbr-book.org/4ed/Shapes/Bilinear_Patches.html#sec:blp-intersection-tests")[6.6.1] that the #source-math("/chapter-6-Shapes/supplements/6.8-math/source-399.svg", 0.84, 2.009, 0.338, "t") value for a bilinear patch intersection is found by taking the determinant of a #source-math("/chapter-6-Shapes/supplements/6.8-math/source-400.svg", 5.165, 2.176, 0.338, "3 times 3") matrix. Each matrix element includes round-off error from the series of floating-point computations used to compute its value. While it is possible to derive bounds on the error in the computed #source-math("/chapter-6-Shapes/supplements/6.8-math/source-401.svg", 0.84, 2.009, 0.338, "t") using a similar approach as was used for triangle intersections, the algebra becomes unwieldy because the computation involves many more operations.
][
  第 6.6.1 节中，双线性面片的交点参数 $t$ 通过一个 $3 times 3$ 矩阵的行列式求得；矩阵每个元素都带有先前浮点运算的舍入误差。虽然也可像三角形一样推导 $t$ 的误差界，但运算更多，代数推导会十分繁琐。
]

#parec[
  Therefore, here we compute an epsilon value that is based on the magnitudes of all of the inputs of the computation of #source-math("/chapter-6-Shapes/supplements/6.8-math/source-402.svg", 0.84, 2.009, 0.338, "t").
][
  因此，这里根据参与 $t$ 计算的全部输入的大小，计算一个 epsilon 值。
]

#block(sticky:true)[#raw("<<Find epsilon eps to ensure that candidate t is greater than zero>>=")] <fragment-Findepsilonmonoepstoensurethatcandidatetisgreaterthanzero-0>
```cpp
Float eps = gamma(10) *
    (MaxComponentValue(Abs(ray.o)) + MaxComponentValue(Abs(ray.d)) +
     MaxComponentValue(Abs(p00))   + MaxComponentValue(Abs(p10))   +
     MaxComponentValue(Abs(p01))   + MaxComponentValue(Abs(p11)));
```

#block(breakable: false)[
=== #ez_caption[Discussion][讨论]
<managing-rounding-error-discussion>

#parec[
  Minimizing and bounding numerical error in other geometric computations (e.g., partial derivatives of surface positions, interpolated texture coordinates, etc.) are much less important than they are for the positions of ray intersections. In a similar vein, the computations involving color and light in physically based rendering generally do not present trouble with respect to round-off error; they involve sums of products of positive numbers (usually with reasonably close magnitudes); hence catastrophic cancellation is not a commonly encountered issue. Furthermore, these sums are of few enough terms that accumulated error is small: the variance that is inherent in the Monte Carlo algorithms used for them dwarfs any floating-point error in computing them.
][
  其他几何量（如表面位置偏导数、插值纹理坐标）的数值误差，远没有交点位置的误差重要。类似地，基于物理渲染中的颜色与光照计算通常不易受到舍入误差困扰：它们多为正数乘积之和，数值量级通常较接近，较少发生灾难性抵消。求和项数也不多，累积误差较小；蒙特卡洛算法固有的方差远大于浮点计算误差。
]
]

#parec[
  Interestingly enough, we saw an increase of roughly 20% in overall ray-tracing execution time after replacing the previous version of `pbrt`’s old #emph[ad hoc] method to avoid incorrect self-intersections with the method described in this section. (In comparison, rendering with double-precision floating point causes an increase in rendering time of roughly 30%.) Profiling showed that very little of the additional time was due to the additional computation to find error bounds; this is not surprising, as the incremental computation our approach requires is limited—most of the error bounds are just scaled sums of absolute values of terms that have already been computed.
][
  将旧版 `pbrt` 避免错误自相交的临时性方法替换为本节方法后，总射线追踪时间增加了约 20%；相比之下，使用双精度会增加约 30%。性能分析表明，新增时间中只有很少一部分用于误差界计算。这并不意外，因为新增计算有限，大部分只是对已算出项的绝对值求和并缩放。
]

#parec[
  The majority of this slowdown is due to an increase in ray–object intersection tests. The reason for this increase in intersection tests was first identified by Wächter (#source-cite("Wachter2008"), p. 30); when ray origins are very close to shape surfaces, more nodes of intersection acceleration hierarchies must be visited when tracing spawned rays than if overly loose offsets are used. Thus, more intersection tests are performed near the ray origin. While this reduction in performance is unfortunate, it is a direct result of the greater accuracy of the method; it is the price to be paid for more accurate resolution of valid nearby intersections.
][
  大部分减速来自射线与对象求交测试次数增加。Wächter（#source-cite("Wachter2008")，第 30 页）首先解释了原因：起点极接近表面时，新射线必须访问更多加速层次节点，因而在起点附近执行更多求交测试；采用过松偏移时则会跳过它们。性能下降虽不理想，却直接来自精度提升，是更准确识别附近有效交点所需的代价。
]


#parec[The expanded coordinate transformation and approximate-input error calculation (source panels 953, 956, and 958) are already included in the expanded fragments for Section 3.9. The other panels repeat visible fragments in this section.][原文折叠 953 的坐标变换，以及 956、958 的带输入误差计算，已收录于第 3.9 节的展开片段；本节其他折叠重复这里已显示的片段。]

#translator[灾难性抵消段的源相对误差式以 a+b 为分母；按此前相对误差取绝对值的定义，负结果时应按绝对值理解，a+b=0 时相对误差未定义。这里保留源SVG，不静默改动源式。]
#translator[重投影误差界主要约束到表面的法向偏差，不覆盖原交点已有的切向偏差。OffsetRayOrigin 的源脚注明确承认未对误差界自身向上舍入，而是期望额外一个 ulp 足够覆盖；阴影射线终点仍采用 ShadowEpsilon；双线性面片的 epsilon 也由输入量级给出而非在此完成严格推导。因此，本节呈现的是固定上游实现及其说明，不能据此宣称对所有输入均已完成严格稳健性证明。]
