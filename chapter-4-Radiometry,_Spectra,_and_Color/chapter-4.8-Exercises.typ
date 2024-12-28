#import "../template.typ": parec

== Exercises

#parec[
  1. #emoji.cat.face.laugh How many photons would a 50-W lightbulb that emits light at the single wavelength $lambda = 600 "nm"$ emit in 1 second?
][
  1. #emoji.cat.face.laugh 一个50瓦的灯泡在1000瓦的时候会发出多少光子 单波长$lambda = 600 "nm"$ 在1秒内发射？
]

#parec[
  2. #emoji.cat.face.laugh Compute the irradiance at a point due to a unit-radius disk h units directly above its normal with constant outgoing radiance of $10 W\/ m^2 s r$. Do the computation twice, once as an integral over solid angle and once as an integral over area. (Hint: If the results do not match at first, see Section A.5.1.)
][
  2. #emoji.cat.face.laugh 计算单位半径圆盘引起的点处的辐照度 单位直接高于其正常值，恒定出射辐射率为$10 W\/ m^2 s r$。 做两次计算，一次作为一个 在立体角上的积分和一次作为面积上的积分。 (Hint：如果 结果最初不匹配，见第A.5.1节。）
]

#parec[
  3. #emoji.cat.face.laugh Similarly, compute the irradiance at a point due to a square quadrilateral with outgoing radiance of $10 W\/ m^2 s r$ that has sides of length 1 and is 1 unit directly above the point in the direction of its surface normal.
][
  3. #emoji.cat.face.laugh 类似地，计算由于正方形而导致的点处的辐照度 四边形，出射辐射率为$10 W\/ m^2 s r$ 其边长为1，并且在该点的正上方为1个单位， 其表面法线的方向。
]

#parec[
  4. #emoji.cat.face.smirk Modify the SampledSpectrum class to also store the wavelengths associated with the samples and their PDFs. Using pbrt's assertion macros, add checks to ensure that no computations are performed using SampledSpectrum values associated with different wavelengths. Measure the performance of pbrt with and without your changes. How much runtime overhead is there? Did you find any bugs in pbrt?
][
  4. #emoji.cat.face.smirk 修改 SampledSpectrum 类以存储 与样本及其PDF相关联的波长。使用 pbrt 断言宏，添加检查以确保不使用 SampledSpectrum 与不同波长相关的值。 测量 pbrt 的性能，无论是否进行了更改。 多少 runtime overhead是什么意思 你在 pbrt 中找到bug了吗？
]