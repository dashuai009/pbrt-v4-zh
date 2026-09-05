#import "../template.typ": parec, ez_caption, translator

== #ez_caption[Further Reading][延伸阅读]
<appendix-b-further-reading>

#parec[
  _Hacker's Delight_ (Warren #link(<tailb-cite:HackersDelight>)[2006]) is a delightful and thought-provoking exploration of bit-twiddling algorithms like those used in some of the utility routines in this appendix. Sean Anderson (#link(<tailb-cite:Anderson2004>)[2004]) has a Web page filled with a collection of bit-twiddling techniques like the ones in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#IsPowerOf2")[`IsPowerOf2()`] and #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RoundUpPow2")[`RoundUpPow2()`] at #link("http://graphics.stanford.edu/~seander/bithacks.html")[#text("graphics.stanford.edu/~seander/bithacks.html")].
][
  _Hacker's Delight_（Warren #link(<tailb-cite:HackersDelight>)[2006]）妙趣横生、启发思考，介绍了许多位操作算法，包括本附录一些辅助函数所用的技术。Sean Anderson（#link(<tailb-cite:Anderson2004>)[2004]）的网页 #link("http://graphics.stanford.edu/~seander/bithacks.html")[#text("graphics.stanford.edu/~seander/bithacks.html")] 也汇集了大量位操作技巧，例如 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#IsPowerOf2")[`IsPowerOf2()`] 和 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RoundUpPow2")[`RoundUpPow2()`] 中使用的方法。
]

#parec[
  The MurmurHash hashing function that is wrapped by `pbrt`'s #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Hash")[`Hash()`] and #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#HashBuffer")[`HashBuffer()`] functions is due to Appleby (#link(<tailb-cite:Appleby2011>)[2011]) and the implementation of #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#MixBits")[`MixBits()`] is due to Stafford (#link(<tailb-cite:Stafford2011>)[2011]), who found the various constant values used in the implementation via search.
][
  `pbrt` 的 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#Hash")[`Hash()`] 和 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#HashBuffer")[`HashBuffer()`] 封装的 MurmurHash 哈希函数来自 Appleby（#link(<tailb-cite:Appleby2011>)[2011]）；#link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#MixBits")[`MixBits()`] 的实现来自 Stafford（#link(<tailb-cite:Stafford2011>)[2011]），其中各个常数值是通过搜索找到的。
]

#parec[
  The inverse bilinear interpolation function implemented in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#InvertBilinear")[`InvertBilinear()`] is due to Quilez (#link(<tailb-cite:Quilez2010>)[2010]) and #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#SinXOverX")[`SinXOverX()`] is thanks to Hatch (#link(<tailb-cite:Hatch2003>)[2003]).
][
  #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#InvertBilinear")[`InvertBilinear()`] 实现的逆双线性插值函数来自 Quilez（#link(<tailb-cite:Quilez2010>)[2010]），#link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#SinXOverX")[`SinXOverX()`] 则来自 Hatch（#link(<tailb-cite:Hatch2003>)[2003]）。
]

#parec[
  The algorithm implemented in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#TwoSum")[`TwoSum()`] is due to Møller (#link(<tailb-cite:Moller65>)[1965]) and Knuth (#link(<tailb-cite:Knuth69>)[1969]), and the FMA-based #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#TwoProd")[`TwoProd()`] was developed by Ogita et al. (#link(<tailb-cite:Ogita2005>)[2005]). The approach used in the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#CompensatedSum")[`CompensatedSum`] class is due to Kahan (#link(<tailb-cite:Kahan1965>)[1965]). The approach used in #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[`DifferenceOfProducts()`] is also attributed to Kahan; its error was analyzed by Jeannerod et al. (#link(<tailb-cite:Jeannerod2013>)[2013]).
][
  #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#TwoSum")[`TwoSum()`] 中的算法来自 Møller（#link(<tailb-cite:Moller65>)[1965]）和 Knuth（#link(<tailb-cite:Knuth69>)[1969]）；基于 FMA 的 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#TwoProd")[`TwoProd()`] 由 Ogita 等人（#link(<tailb-cite:Ogita2005>)[2005]）提出。#link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#CompensatedSum")[`CompensatedSum`] 使用的方法来自 Kahan（#link(<tailb-cite:Kahan1965>)[1965]）。#link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#DifferenceOfProducts")[`DifferenceOfProducts()`] 所用的方法也归功于 Kahan，其误差由 Jeannerod 等人（#link(<tailb-cite:Jeannerod2013>)[2013]）进行了分析。
]

#parec[
  Welford (#link(<tailb-cite:Welford62>)[1962]) developed the algorithm that is implemented in the #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#VarianceEstimator")[`VarianceEstimator`] class. Its `Merge()` method is based on an algorithm developed by Chan et al. (#link(<tailb-cite:Chan79>)[1979]).
][
  #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#VarianceEstimator")[`VarianceEstimator`] 中实现的算法由 Welford（#link(<tailb-cite:Welford62>)[1962]）提出，其 `Merge()` 方法则基于 Chan 等人（#link(<tailb-cite:Chan79>)[1979]）的算法。
]

#parec[
  Atkinson's book (#link(<tailb-cite:Atkinson1993>)[1993]) on numerical analysis discusses algorithms for matrix inversion and solving linear systems. See Moore's book (#link(<tailb-cite:Moore66>)[1966]) for an introduction to interval arithmetic.
][
  Atkinson 的数值分析著作（#link(<tailb-cite:Atkinson1993>)[1993]）讨论了矩阵求逆和线性方程组求解算法。区间算术的入门介绍可参阅 Moore 的书（#link(<tailb-cite:Moore66>)[1966]）。
]

#parec[
  Farin's book (#link(<tailb-cite:Farin2001>)[2001]) is a good introduction to splines. The blossoming approach was introduced by Ramshaw (#link(<tailb-cite:Ramshaw1987>)[1987]); his report remains a readable introduction to the topic. A subsequent publication drew further connections to polar forms and related work (Ramshaw #link(<tailb-cite:Ramshaw1989>)[1989]).
][
  Farin 的书（#link(<tailb-cite:Farin2001>)[2001]）是很好的样条入门读物。Ramshaw（#link(<tailb-cite:Ramshaw1987>)[1987]）提出了开花（blossoming）方法，他的报告至今仍是易读的入门材料。后续论文进一步揭示了它与极形式及相关工作的联系（Ramshaw #link(<tailb-cite:Ramshaw1989>)[1989]）。
]

#parec[
  The PCG random number generator was developed by O'Neill (#link(<tailb-cite:ONeill2014>)[2014]). The paper describing its implementation is well written and also features extensive discussion of a range of previous pseudo-random number generators and the challenges that they have faced in passing rigorous tests of their quality (L'Ecuyer and Simard #link(<tailb-cite:LEcuyer2007>)[2007]).
][
  PCG 随机数生成器由 O'Neill（#link(<tailb-cite:ONeill2014>)[2014]）开发。介绍其实现的论文写得很好，还深入讨论了以往多种伪随机数生成器，以及它们在通过严格质量测试时面临的挑战（L'Ecuyer 和 Simard #link(<tailb-cite:LEcuyer2007>)[2007]）。
]

#parec[
  The article “UTF-8 Everywhere” by Radzivilovsky et al. (#link(<tailb-cite:Radzivilovsky2012>)[2012]) is a good introduction to Unicode and also makes a strong case for adopting the UTF-8 representation. `pbrt` follows the approach they propose for interoperating with Windows's UTF-16-based APIs. At over 1,000 pages, the length of the official Unicode specification gives some sense of the complexities in representing multi-lingual text (Unicode Consortium #link(<tailb-cite:Unicode2020>)[2020]).
][
  Radzivilovsky 等人的文章“UTF-8 Everywhere”（#link(<tailb-cite:Radzivilovsky2012>)[2012]）很好地介绍了 Unicode，并有力论证了采用 UTF-8 表示的理由。`pbrt` 沿用他们提出的方法，与 Windows 基于 UTF-16 的 API 交互。官方 Unicode 规范长达一千多页，足以让人感受到多语言文本表示的复杂性（Unicode Consortium #link(<tailb-cite:Unicode2020>)[2020]）。
]

#parec[
  Gamma correction has a long history in computer graphics. Poynton (#link(<tailb-cite:Poynton02color>)[2002a], #link(<tailb-cite:Poynton02>)[2002b]) has written comprehensive FAQs on issues related to color representation and gamma correction. The sRGB encoding was described by the International Electrotechnical Commission (#link(<tailb-cite:IEC1999>)[1999]). See Gritz and d'Eon (#link(<tailb-cite:Gritz08>)[2008]) for a detailed discussion of the implications of gamma correction for rendering and how to correctly account for it in rendering systems.
][
  伽马校正在计算机图形学中由来已久。Poynton（#link(<tailb-cite:Poynton02color>)[2002a]、#link(<tailb-cite:Poynton02>)[2002b]）撰写了全面的常见问题解答，讨论颜色表示和伽马校正。国际电工委员会（#link(<tailb-cite:IEC1999>)[1999]）描述了 sRGB 编码。关于伽马校正对渲染的影响，以及如何在渲染系统中正确处理它，详见 Gritz 和 d'Eon（#link(<tailb-cite:Gritz08>)[2008]）。
]

#parec[
  McKenney's book on parallel programming is wonderfully written and has comprehensive coverage of the underlying issues, as well as many useful techniques for high-performance parallel programming on CPUs (#link(<tailb-cite:McKenney2021>)[2021]). Drepper's paper (#link(<tailb-cite:Drepper07>)[2007]) is a useful resource for understanding performance issues related to caches, cache coherence, and main memory access, particularly in multicore systems.
][
  McKenney 的并行编程著作（#link(<tailb-cite:McKenney2021>)[2021]）文笔出色，全面讨论了基础问题，也介绍了许多在 CPU 上进行高性能并行编程的实用技术。Drepper 的论文（#link(<tailb-cite:Drepper07>)[2007]）有助于理解缓存、缓存一致性和主存访问相关的性能问题，尤其是多核系统中的这些问题。
]

#parec[
  Boehm's paper “Threads Cannot Be Implemented as a Library” (#link(<tailb-cite:Boehm05>)[2005]) makes the remarkable (and disconcerting) observation that multi-threading cannot be reliably implemented without the compiler having explicit knowledge of the fact that multi-threaded execution is expected. Boehm presented a number of examples that demonstrate the corresponding dangers in 2005-era compilers and language standards like C and C++ that did not have awareness of threading. Fortunately, the C++11 and C11 standards addressed the issues that he identified.
][
  Boehm 的论文“Threads Cannot Be Implemented as a Library”（#link(<tailb-cite:Boehm05>)[2005]）指出了一个令人惊讶、也令人不安的事实：如果编译器并不明确知道程序将多线程执行，就无法可靠地实现多线程。Boehm 用多个例子展示了 2005 年前后尚未纳入线程概念的编译器及 C、C++ 等语言标准中的相关危险。幸运的是，C++11 和 C11 标准解决了他指出的问题。
]

#parec[
  `pbrt`'s parallel `for` loop–based approach to multi-threading is a widely used technique for multi-threaded programming; the OpenMP standard supports a similar construct (and much more) (OpenMP Architecture Review Board #link(<tailb-cite:OpenMP13>)[2013]). A slightly more general model for multi-core parallelism is available from task systems, where computations are broken up into a set of independent tasks that can be executed concurrently. That model is supported through #link("https://pbr-book.org/4ed/Utilities/Parallelism.html#RunAsync")[`RunAsync()`]. Blumofe et al. (#link(<tailb-cite:Blumofe96>)[1996]) described the task scheduler in Cilk, and Blumofe and Leiserson (#link(<tailb-cite:Blumofe99>)[1999]) described the work-stealing algorithm that is the mainstay of many current high-performance task systems.
][
  `pbrt` 基于并行 `for` 循环实现多线程，这是广泛使用的多线程编程技术；OpenMP 标准支持类似结构，以及更多功能（OpenMP Architecture Review Board #link(<tailb-cite:OpenMP13>)[2013]）。任务系统提供了稍更通用的多核并行模型：将计算拆分为一组可并发执行的独立任务。#link("https://pbr-book.org/4ed/Utilities/Parallelism.html#RunAsync")[`RunAsync()`] 支持这一模型。Blumofe 等人（#link(<tailb-cite:Blumofe96>)[1996]）介绍了 Cilk 的任务调度器，Blumofe 和 Leiserson（#link(<tailb-cite:Blumofe99>)[1999]）则介绍了工作窃取算法，后者是许多现代高性能任务系统的核心。
]

#block(sticky: true)[#heading(level: 3, numbering: none)[#ez_caption[References][参考文献]]]

#block[Anderson, S. 2004. Bit twiddling hacks. #link("http://graphics.stanford.edu/~seander/bithacks.html")[#text("graphics.stanford.edu/~seander/bithacks.html")].] <tailb-cite:Anderson2004>

#block[Appleby, A. 2011. MurmurHash3. #link("https://sites.google.com/site/murmurhash/")[https://sites.google.com/site/murmurhash/].] <tailb-cite:Appleby2011>

#block[Atkinson, K. 1993. _Elementary Numerical Analysis_. New York: John Wiley & Sons.] <tailb-cite:Atkinson1993>

#block[Blumofe, R., and C. Leiserson. 1999. Scheduling multithreaded computations by work stealing. _Journal of the ACM_ 46 (5), 720–48.] <tailb-cite:Blumofe99>

#block[Blumofe, R., C. Joerg, B. Kuszmaul, C. Leiserson, K. Randall, and Y. Zhou. 1996. Cilk: An efficient multithreaded runtime system. _Journal of Parallel and Distributed Computing_ 37 (1), 55–69.] <tailb-cite:Blumofe96>

#block[Boehm, H.-J. 2005. Threads cannot be implemented as a library. _ACM SIGPLAN Notices_ 40 (6), 261–68.] <tailb-cite:Boehm05>

#block[Chan, T. F., G. Golub, R. J. LeVeque. 1979. Updating formulae and a pairwise algorithm for computing sample variances. Technical Report STAN-CS-79-773, Department of Computer Science, Stanford University.] <tailb-cite:Chan79>

#block[Drepper, U. 2007. What every programmer should know about memory. #link("http://people.redhat.com/drepper/cpumemory.pdf")[people.redhat.com/drepper/cpumemory.pdf].] <tailb-cite:Drepper07>

#block[Farin, G. 2001. _Curves and Surfaces for CAGD: A Practical Guide_ (5th ed.). San Francisco: Morgan Kaufmann.] <tailb-cite:Farin2001>

#block[Gritz, L., and E. d'Eon. 2008. The importance of being linear. In H. Nguyen (ed.), _GPU Gems 3_, 529–42. Boston, Massachusetts: Addison-Wesley.] <tailb-cite:Gritz08>

#block[Guthe, S., and P. Heckbert 2005. Non-power-of-two Mipmap creation. NVIDIA Technical Report.] <tailb-cite:Guthe05>

#block[Hatch, D. 2003. The right way to calculate stuff. #text("http://www.plunk.org/ hatch/rightway.html").] <tailb-cite:Hatch2003>
#parec[Editorial note: the fixed upstream reference contains a nonbreaking space in this URL; its intended target has not been verified.][#translator[固定上游此书目的网址在斜杠后含不换行空格，目标地址尚未核实；保留原文文字，不生成失效链接。]]

#block[International Electrotechnical Commission (IEC). 1999. Multimedia systems and equipment—Colour measurement and management—Part 2-1: Colour management—Default RGB colour space—sRGB. IEC Standard 61966-2-1.] <tailb-cite:IEC1999>

#block[Jeannerod, C.-P., N. Louvet, and J.-M. Muller. 2013. Further analysis of Kahan's algorithm for the accurate computation of $2 times 2$ determinants. _Mathematics of Computation_ 82 (284), 2245–64.] <tailb-cite:Jeannerod2013>

#block[Kahan, W. 1965. Further remarks on reducing truncation errors. _Communications of the ACM_ 8 (1), 40.] <tailb-cite:Kahan1965>

#block[Kainz, F., R. Bogart, and D. Hess. 2004. The OpenEXR File Format. In R. Fernando (ed.), _GPU Gems_, 425–44. Reading, Massachusetts: Addison-Wesley.] <tailb-cite:Kainz04>

#block[Knuth, D. E. 1969. _The Art of Computer Programming: Seminumerical Algorithms_. Reading, Massachusetts: Addison-Wesley.] <tailb-cite:Knuth69>

#block[L'Ecuyer, P., and R. Simard. 2007. TestU01: A C library for empirical testing of random number generators. _ACM Transactions on Mathematical Software_ 33 (4), 22:1–40.] <tailb-cite:LEcuyer2007>

#block[Møller, O. 1965. Quasi double precision in floating-point arithmetic. _BIT Numerical Mathematics_ 5, 37–50.] <tailb-cite:Moller65>

#block[McKenney, P. E. 2021. _Is Parallel Programming Hard, and, If So, What Can You Do About It?_ #link("https://mirrors.edge.kernel.org/pub/linux/kernel/people/paulmck/perfbook/perfbook.html")[https://mirrors.edge.kernel.org/pub/linux/kernel/people/paulmck/perfbook/perfbook.html].] <tailb-cite:McKenney2021>

#block[Moore, R. E. 1966. _Interval Analysis_. Englewood Cliffs, New Jersey: Prentice Hall.] <tailb-cite:Moore66>

#block[O'Neill, M. 2014. PCG: A family of simple fast space-efficient statistically good algorithms for random number generation. Unpublished manuscript. #link("http://www.pcg-random.org/paper.html")[http://www.pcg-random.org/paper.html].] <tailb-cite:ONeill2014>

#block[Ogita, T., S. M. Rump, and S. Oishi. 2005. Accurate sum and dot product. _SIAM Journal on Scientific Computing_ 26 (6), 1955–88.] <tailb-cite:Ogita2005>

#block[OpenMP Architecture Review Board. 2013. OpenMP Application Program Interface. #link("http://www.openmp.org/mp-documents/OpenMP4.0.0.pdf")[http://www.openmp.org/mp-documents/OpenMP4.0.0.pdf].] <tailb-cite:OpenMP13>

#block[Poynton, C. 2002a. Frequently-asked questions about color. #link("http://www.poynton.com/ColorFAQ.html")[www.poynton.com/ColorFAQ.html].] <tailb-cite:Poynton02color>

#block[Poynton, C. 2002b. Frequently-asked questions about gamma. #link("http://www.poynton.com/GammaFAQ.html")[www.poynton.com/GammaFAQ.html].] <tailb-cite:Poynton02>

#block[Quilez, I. 2010. Inverse bilinear interpolation. #link("https://www.iquilezles.org/www/articles/ibilinear/ibilinear.htm")[https://www.iquilezles.org/www/articles/ibilinear/ibilinear.htm].] <tailb-cite:Quilez2010>

#block[Radzivilovsky, P., Y. Galka, and S. Novgorodov. 2012. UTF-8 everywhere. #link("http://utf8everywhere.org")[http://utf8everywhere.org].] <tailb-cite:Radzivilovsky2012>

#block[Ramshaw, L. 1987. Blossoming: A connect-the-dots approach to splines. Digital Systems Research Center Technical Report.] <tailb-cite:Ramshaw1987>

#block[Ramshaw, R. 1989. Blossoms are polar forms. _Computer Aided Geometric Design_ 6 (4), 323–58.] <tailb-cite:Ramshaw1989>

#block[Stafford, D. 2011. Better bit mixing—improving on MurmurHash3's 64-bit finalizer. #link("http://zimbry.blogspot.com/2011/09/better-bit-mixing-improving-on.html")[http://zimbry.blogspot.com/2011/09/better-bit-mixing-improving-on.html].] <tailb-cite:Stafford2011>

#block[Unicode Consortium. 2020. _The Unicode Standard: Version 13.0_. #link("https://www.unicode.org/versions/Unicode13.0.0/UnicodeStandard-13.0.pdf")[https://www.unicode.org/versions/Unicode13.0.0/UnicodeStandard-13.0.pdf].] <tailb-cite:Unicode2020>

#block[Warren, H. 2006. _Hacker's Delight_. Reading, Massachusetts: Addison-Wesley.] <tailb-cite:HackersDelight>

#block[Welford, B. P. 1962. Note on a method for calculating corrected sums of squares and products. _Technometrics_ 4 (3), 419–20.] <tailb-cite:Welford62>
