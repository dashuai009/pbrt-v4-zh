#import "../template.typ": parec, ez_caption

== #ez_caption[Exercises][习题]

#parec[
  1. ① How many photons would a 50-W lightbulb that emits light at the single wavelength $lambda = 600 upright("nm")$ emit in 1 second?
][
  1. ① 一个功率为 50 W、仅在 $lambda = 600 upright("nm")$ 这一波长发光的灯泡，在 1 秒内会发出多少个光子？
]

#parec[
  2. ① Compute the irradiance at a point due to a unit-radius disk $h$ units directly above its normal with constant outgoing radiance of $10 upright("W") / (upright("m")^2 upright("sr"))$. Do the computation twice, once as an integral over solid angle and once as an integral over area. (Hint: If the results do not match at first, see #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[Section A.5.1].)
][
  2. ① 一个半径为 1 的圆盘，位于某点沿其法线方向正上方 $h$ 个单位处，出射辐亮度恒为 $10 upright("W") / (upright("m")^2 upright("sr"))$。计算该圆盘在此点产生的辐照度，分别对立体角和面积积分，各计算一次。（提示：如果最初得到的两个结果不同，请参阅 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[A.5.1 节]。）
]

#parec[
  3. ① Similarly, compute the irradiance at a point due to a square quadrilateral with outgoing radiance of $10 upright("W") / (upright("m")^2 upright("sr"))$ that has sides of length 1 and is 1 unit directly above the point in the direction of its surface normal.
][
  3. ① 类似地，计算一个正方形在某点产生的辐照度。该正方形边长为 1，位于该点沿表面法线方向正上方 1 个单位处，出射辐亮度为 $10 upright("W") / (upright("m")^2 upright("sr"))$。
]

#parec[
  4. ② Modify the `SampledSpectrum` class to also store the wavelengths associated with the samples and their PDFs. Using `pbrt`’s assertion macros, add checks to ensure that no computations are performed using `SampledSpectrum` values associated with different wavelengths. Measure the performance of `pbrt` with and without your changes. How much runtime overhead is there? Did you find any bugs in `pbrt`?
][
  4. ② 修改 `SampledSpectrum` 类，使它也保存各样本对应的波长及其 PDF。利用 `pbrt` 的断言宏添加检查，确保不会将对应不同波长的 `SampledSpectrum` 值用于同一次运算。比较修改前后 `pbrt` 的性能：增加了多少运行时开销？是否发现了 `pbrt` 中的错误？
]
