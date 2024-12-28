#import "../template.typ": parec

== Further Reading
<further-reading>
#parec[
  Heckbert #link("<cite:Heckbert90pixel>")[1990a] wrote an article that explains possible pitfalls when using floating-point coordinates for pixels and develops the conventions that are introduced in Section #link("../Sampling_and_Reconstruction/Sampling_Theory.html#sec:pixel-concepts")[8.1.4];.
][
  Heckbert #link("<cite:Heckbert90pixel>")[1990a] 撰写了一篇文章，阐述了使用浮点坐标表示像素时可能出现的陷阱，并发展了在第 #link("../Sampling_and_Reconstruction/Sampling_Theory.html#sec:pixel-concepts")[8.1.4] 节中介绍的惯例。
]

=== Sampling Theory and Aliasing
<sampling-theory-and-aliasing>
#parec[
  One of the best books on signal processing, sampling, reconstruction, and the Fourier transform is Bracewell's #emph[The Fourier Transform and
Its Applications] #link("<cite:Bracewell:Fourier>")[2000];. Glassner's #emph[Principles of Digital Image Synthesis] #link("<cite:Glassner:PODIS>")[1995] has a series of chapters on the theory and application of uniform and nonuniform sampling and reconstruction to computer graphics. For an extensive survey of the history of and techniques for interpolation of sampled data, including the sampling theorem, see Meijering #link("<cite:Meijering02>")[2002];. Unser #link("<cite:Unser00>")[2000] also surveyed developments in sampling and reconstruction theory, including the move away from focusing purely on band-limited functions. For more recent work in this area, see Eldar and Michaeli #link("<cite:Eldar2009>")[2009];.
][
  关于信号处理、采样、重建和傅里叶变换的最佳书籍之一是 Bracewell 的 #emph[The Fourier Transform and Its Applications] #link("<cite:Bracewell:Fourier>")[2000];。Glassner 的 #emph[Principles of
Digital Image Synthesis] #link("<cite:Glassner:PODIS>")[1995] 包含一系列关于均匀和非均匀采样及重建在计算机图形学中应用的章节。关于采样数据插值的历史和技术的广泛调查，包括采样定理，请参见 Meijering #link("<cite:Meijering02>")[2002];。Unser #link("<cite:Unser00>")[2000] 也调查了采样和重建理论的发展，包括不再仅仅关注带限函数。有关该领域的最新工作，请参见 Eldar 和 Michaeli #link("<cite:Eldar2009>")[2009];。
]

#parec[
  Crow #link("<cite:Crow77>")[1977] was the first to identify aliasing as a major source of artifacts in computer-generated images. Using nonuniform sampling to turn aliasing into noise was introduced by Cook #link("<cite:Cook86>")[1986] and Dippé and Wold #link("<cite:Dippe85>")[1985];; their work was based on experiments by Yellot #link("<cite:Yellot83>")[1983];, who investigated the distribution of photoreceptors in the eyes of monkeys. Dippé and Wold also first introduced the pixel filtering equation to graphics and developed a Poisson sample pattern with a minimum distance between samples.
][
  Crow #link("<cite:Crow77>")[1977] 首次将混叠识别为计算机生成图像中伪影的主要来源。使用非均匀采样将混叠转化为噪声的技术由 Cook #link("<cite:Cook86>")[1986] 和 Dippé 和 Wold #link("<cite:Dippe85>")[1985] 引入；他们的工作基于 Yellot #link("<cite:Yellot83>")[1983] 的实验，他研究了猴子眼睛中光感受器的分布。Dippé 和 Wold 还首次将像素滤波方程引入图形学，并开发了一种样本间距最小的泊松样本模式。
]

#parec[
  Mitchell #link("<cite:Mitchell87>")[1987];, #link("<cite:Mitchell91>")[1991] extensively investigated sampling patterns for ray tracing. His papers on this topic have many key insights, especially on the importance of blue noise distributions for sampling patterns. See also Ulichney #link("<cite:Ulichney1988>")[1988];, who demonstrated the effectiveness of blue noise in the context of dithering.
][
  Mitchell #link("<cite:Mitchell87>")[1987];, #link("<cite:Mitchell91>")[1991] 广泛研究了光线追踪的采样模式。他在这一主题上的论文提供了许多关键见解，特别是关于蓝噪声分布对采样模式的重要性。另请参见 Ulichney #link("<cite:Ulichney1988>")[1988];，他在抖动的背景下展示了蓝噪声的有效性。
]

#parec[
  Compressed sensing is an alternative approach to sampling where the required sampling rate depends on the sparsity of the signal, not its frequency content. Sen and Darabi #link("<cite:Sen2011>")[2011] applied compressed sensing to rendering, allowing them to generate high-quality images at very low sampling rates.
][
  压缩感知是一种替代的采样方法，其中所需的采样率取决于信号的稀疏性，而不是其频率内容。Sen 和 Darabi #link("<cite:Sen2011>")[2011] 将压缩感知应用于渲染，使他们能够以非常低的采样率生成高质量的图像。
]

#parec[
  Lessig et al.~#link("<cite:Lessig2014>")[2014] proposed a general framework for constructing quadrature rules tailored to specific integration problems such as stochastic ray tracing, spherical harmonics projection, and scattering by surfaces. When targeting band-limited functions, their approach subsumes the frequency space approach presented in this chapter. An excellent tutorial about the underlying theory of #emph[reproducing kernel bases] is provided in the article's supplemental material.
][
  Lessig 等人 #link("<cite:Lessig2014>")[2014] 提出了一种通用框架，用于构建针对特定积分问题（如随机光线追踪、球谐投影和表面散射）量身定制的求积规则。在针对带限函数时，他们的方法涵盖了本章中提出的频率空间方法。文章的补充材料中提供了关于#emph[再生核基];基本理论的优秀教程。
]

=== Analysis of Monte Carlo Integration
<analysis-of-monte-carlo-integration>
#parec[
  Starting with Ramamoorthi and Hanrahan's #link("<cite:Ramamoorthi2004>")[2004] and Durand et al.'s foundational work #link("<cite:Durand2005>")[2005];, a number of researchers have analyzed light transport and Monte Carlo integration using Fourier analysis. Singh et al.'s survey #link("<cite:Singh2019:star>")[2019a] has comprehensive coverage of work in this area.
][
  从 Ramamoorthi 和 Hanrahan #link("<cite:Ramamoorthi2004>")[2004] 和 Durand 等人的基础工作 #link("<cite:Durand2005>")[2005] 开始，许多研究人员利用傅里叶分析对光传输和蒙特卡罗积分进行了研究。Singh 等人的调查 #link("<cite:Singh2019:star>")[2019a] 全面覆盖了该领域的工作。
]

#parec[
  Durand #link("<cite:Durand2011>")[2011] was the first to express variance using Fourier analysis, converting the Monte Carlo estimator to the continuous form (our Equation #link("../Sampling_and_Reconstruction/Sampling_and_Integration.html#eq:mc-estimator-continuous")[8.10];) in order to demonstrate that the sampling rate only has to equal the function's highest frequency in order to achieve zero variance. He further derived the variance in terms of the integral of the product of the function's and sampling pattern's power spectra.
][
  Durand #link("<cite:Durand2011>")[2011] 首次使用傅里叶分析表达方差，将蒙特卡罗估计器转换为连续形式（我们的方程 #link("../Sampling_and_Reconstruction/Sampling_and_Integration.html#eq:mc-estimator-continuous")[8.10];），以证明采样率只需等于函数的最高频率即可实现零方差。他进一步推导了方差，以函数和采样模式的功率谱乘积的积分形式表示。
]

#parec[
  Subr and Kautz #link("<cite:Subr2013>")[2013] subsequently expressed variance in terms of a product of the variance of the sampling pattern and the function being integrated in frequency space. Pilleboue et al.~#link("<cite:Pilleboue2015>")[2015] applied homogenization to sampling patterns in order to express variance in terms of the power spectra in a more general setting than Durand #link("<cite:Durand2011>")[2011] and extended the analysis to functions on the sphere. They further derived asymptotic convergence rates for various sampling techniques and showed that they matched empirical measurements. These results not only provided a theoretical basis to explain earlier measurements made by Mitchell #link("<cite:Mitchell96>")[1996] but included the surprising result that Poisson disk patterns have asymptotically worse convergence rates than simple jittered patterns.
][
  Subr 和 Kautz #link("<cite:Subr2013>")[2013] 随后以采样模式的方差和频率空间中被积分函数的乘积形式表达方差。Pilleboue 等人 #link("<cite:Pilleboue2015>")[2015] 将均匀化应用于采样模式，以便在比 Durand #link("<cite:Durand2011>")[2011] 更一般的设置中以功率谱形式表达方差，并将分析扩展到球面上的函数。他们进一步推导了各种采样技术的渐近收敛率，并表明它们与经验测量相匹配。这些结果不仅为解释 Mitchell #link("<cite:Mitchell96>")[1996] 早期测量提供了理论基础，还包括一个令人惊讶的结果，即泊松盘模式的渐近收敛率比简单的抖动模式更差。
]

#parec[
  Öztireli #link("<cite:Oztireli2016>")[2016] applied point process statistics to study stochastic sampling patterns for integration, deriving closed-form expressions for bias and variance of a number of approaches and analyzing integrands with discontinuities due to visibility. Singh and Jarosz #link("<cite:Singh2017>")[2017] analyzed the variance of anisotropic sampling patterns (of which jittered sampling is a notable example), and Singh et al.~#link("<cite:Singh2017:line>")[2017] investigated the variance of sampling with line segments rather than points. The use of Fourier series to analyze sampling patterns was introduced by Singh et al.~#link("<cite:Singh2019:fourier>")[2019b];, which allowed the analysis of nonhomogeneous sampling patterns and also made it possible to incorporate the effect of importance sampling.
][
  Öztireli #link("<cite:Oztireli2016>")[2016] 应用点过程统计研究积分的随机采样模式，推导出多种方法的偏差和方差的解析表达式，并分析了由于可见性导致的不连续积分。Singh 和 Jarosz #link("<cite:Singh2017>")[2017] 分析了各向异性采样模式（其中抖动采样是一个显著例子）的方差，Singh 等人 #link("<cite:Singh2017:line>")[2017] 调查了使用线段而非点的采样方差。Singh 等人 #link("<cite:Singh2019:fourier>")[2019b] 引入了使用傅里叶级数分析采样模式的方法，这使得分析非均匀采样模式成为可能，并且还可以结合重要性采样的影响。
]

#parec[
  Öztireli #link("<cite:Oztireli2020>")[2020] provided a comprehensive review of work in blue noise sampling for rendering through 2019 and then applied the theory of stochastic point processes to derive the expected error spectrum from sampling a function with a given sampling technique in terms of the associated power spectra. This result makes clear why having minimal power in the low frequencies and as close to uniform unit power as possible at higher frequencies is best for antialiasing.
][
  Öztireli #link("<cite:Oztireli2020>")[2020] 对截至2019年的渲染蓝噪声采样工作进行了全面回顾，然后应用随机点过程理论推导出使用给定采样技术采样函数的预期误差谱，以相关功率谱的形式表示。这个结果清楚地表明，为什么在低频率下功率最小并且在高频率下尽可能接近均匀单位功率对于抗锯齿是最好的。
]

=== Sample Generation Algorithms
<sample-generation-algorithms>
#parec[
  After the introduction of jittered sampling, Mitchell #link("<cite:Mitchell87>")[1987] introduced an approach to generate sampling patterns with good blue noise characteristics using error diffusion and later developed an algorithm for generating sampling patterns that were also optimized for sampling motion blur and depth of field #link("<cite:Mitchell91>")[Mitchell 1991];. A key observation in the second paper was that a $d$ -dimensional Poisson disk distribution is not the ideal one for general integration problems in graphics; while it is useful for the projection of the first two dimensions on the image plane to have the Poisson-disk property, it is important that the other dimensions be more widely distributed than the Poisson-disk quality alone guarantees.
][
  在引入抖动采样后，Mitchell #link("<cite:Mitchell87>")[1987] 引入了一种使用误差扩散生成具有良好蓝噪声特性的采样模式的方法，随后开发了一种生成采样模式的算法，该算法也针对采样运动模糊和景深进行了优化 #link("<cite:Mitchell91>")[Mitchell 1991];。第二篇论文中的一个关键观察是， $d$ 维泊松盘分布不是图形学中一般积分问题的理想分布；虽然在图像平面上投影前两个维度具有泊松盘特性是有用的，但重要的是其他维度的分布要比泊松盘质量单独保证的更广泛。
]

#parec[
  The utility of such approaches was recently understood more widely after work by Georgiev and Fajardo #link("<cite:Georgiev2016>")[2016];, who also described a method to generate tables of samples where nearby points are decorrelated for such applications. Heitz and Belcour #link("<cite:Heitz2019:seeds>")[2019] developed a technique that permutes random seeds across nearby pixels in order to decorrelate the #emph[error] in the image, rather than just the sample values themselves.
][
  Georgiev 和 Fajardo #link("<cite:Georgiev2016>")[2016] 的工作之后，这些方法的实用性被更广泛地理解，他们还描述了一种生成样本表的方法，其中相邻点在此类应用中被去相关。Heitz 和 Belcour #link("<cite:Heitz2019:seeds>")[2019] 开发了一种技术，通过在相邻像素之间置换随机种子来去相关图像中的#emph[误差];，而不仅仅是样本值本身。
]

#parec[
  The blue noise points provided via the #link("../Sampling_and_Reconstruction/Sampling_Theory.html#BlueNoise")[BlueNoise()] function are thanks to Peters #link("<cite:Peters2016>")[2016] and were generated using Ulichney's "void and cluster" algorithm #link("<cite:Ulichney1993>")[1993];.
][
  通过 #link("../Sampling_and_Reconstruction/Sampling_Theory.html#BlueNoise")[BlueNoise()] 函数提供的蓝噪声点归功于 Peters #link("<cite:Peters2016>")[2016];，这些点是使用 Ulichney 的“空隙和聚类”算法 #link("<cite:Ulichney1993>")[1993] 生成的。
]

#parec[
  Chiu, Shirley, and Wang #link("<cite:Chiu94>")[1994] suggested a #emph[multi-jittered] 2D sampling technique based on randomly shuffling the $x$ and $y$ coordinates of a canonical jittered pattern that combines the properties of stratified and Latin hypercube sampling patterns. More recently, Kensler #link("<cite:Kensler2013>")[2013] showed that using the same permutation for both dimensions with their method gives much better results than independent permutations; he showed that this approach gives lower discrepancy than the Sobol' pattern while also maintaining the perceptual advantages of turning aliasing into noise due to using jittered samples. Christensen et al.~further improved this approach #link("<cite:Christensen2018pmj>")[2018];, generating point sets that were also stratified with respect to the elementary intervals and had good blue noise properties. Pharr #link("<cite:Pharr2019>")[2019] proposed a more efficient algorithm to generate these points, though Grünschloss et al.~#link("<cite:Gruenschloss08>")[2008] had earlier developed an efficient elementary interval test that is similar to the one described there.
][
  Chiu、Shirley 和 Wang #link("<cite:Chiu94>")[1994] 提出了一种基于随机洗牌标准抖动模式的 $x$ 和 $y$ 坐标的#emph[多抖动];二维采样技术，该技术结合了分层和拉丁超立方采样模式的特性。最近，Kensler #link("<cite:Kensler2013>")[2013] 表明，使用相同的置换方法对两个维度进行置换比独立置换效果要好得多；他表明，这种方法比 Sobol' 模式具有更低的差异，同时由于使用抖动样本而保持了将混叠转化为噪声的感知优势。Christensen 等人进一步改进了这种方法 #link("<cite:Christensen2018pmj>")[2018];，生成的点集相对于基本区间也进行了分层，并具有良好的蓝噪声特性。 Pharr #link("<cite:Pharr2019>")[2019] 提出了一种更高效的算法来生成这些点，尽管 Grünschloss 等人 #link("<cite:Gruenschloss08>")[2008] 早些时候开发了一种类似于那里描述的高效基本区间测试。
]

#parec[
  Lagae and Dutrè #link("<cite:Lagae08c>")[2008c] surveyed the state of the art in generating Poisson disk sample patterns and compared the quality of the point sets that various algorithms generated. Reinert et al.~#link("<cite:Reinert2015>")[2015] proposed a construction for $d$ -dimensional Poisson disk samples that retain their characteristic sample separation under projection onto lower-dimensional subsets, which ensures good performance if the variation in the function is focused along only some of the dimensions.
][
  Lagae 和 Dutrè #link("<cite:Lagae08c>")[2008c] 调查了生成泊松盘样本模式的最新技术，并比较了各种算法生成的点集的质量。Reinert 等人 #link("<cite:Reinert2015>")[2015] 提出了一种构造 $d$ 维泊松盘样本的方法，这些样本在投影到低维子集时保留其特征样本分离，这确保了如果函数的变化仅集中在某些维度上，则性能良好。
]

#parec[
  Jarosz et al.~#link("<cite:Jarosz2019>")[2019] applied #emph[orthogonal
array sampling] to generating multidimensional sample points that retain good distribution across lower-dimensional projections and showed that this approach gives much better results than randomly padding lower-dimensional samples as `pbrt` does in the #link("../Sampling_and_Reconstruction/Sobol_Samplers.html#PaddedSobolSampler")[PaddedSobolSampler];, for example.
][
  Jarosz 等人 #link("<cite:Jarosz2019>")[2019] 将#emph[正交阵列采样];应用于生成多维样本点，这些样本点在低维投影中保持良好的分布，并表明这种方法比随机填充低维样本（例如 `pbrt` 在 #link("../Sampling_and_Reconstruction/Sobol_Samplers.html#PaddedSobolSampler")[PaddedSobolSampler] 中所做的）效果要好得多。
]

#parec[
  The error analysis framework derived in Öztireli's paper #link("<cite:Oztireli2020>")[2020] further makes it possible to express the desired properties of a point set in a form that is suitable to solve as an optimization problem. This made it possible to generate point sets with superior antialiasing capabilities to previous approaches. (That paper also includes an extensive review of the state of the art in blue noise and Poisson disk sample point generation.)
][
  Öztireli 的论文 #link("<cite:Oztireli2020>")[2020] 中推导的误差分析框架进一步使得可以以适合作为优化问题求解的形式表达点集的期望属性。这使得生成的点集在抗锯齿能力上优于以前的方法。（该论文还包括对蓝噪声和泊松盘样本点生成的最新技术的广泛回顾。）
]

=== Low-Discrepancy Sampling and QMC

#parec[
  Shirley #link("<cite:Shirley91>")[1991] first introduced the use of discrepancy to evaluate the quality of sample patterns in computer graphics. This work was built upon by Mitchell #link("<cite:Mitchell92>")[1992];, Dobkin and Mitchell #link("<cite:Dobkin93>")[1993];, and Dobkin, Eppstein, and Mitchell #link("<cite:Dobkin96>")[1996];. One important observation in Dobkin et al.'s paper is that the box discrepancy measure used in this chapter and in other work that applies discrepancy to pixel sampling patterns is not particularly appropriate for measuring a sampling pattern's accuracy at randomly oriented edges through a pixel and that a discrepancy measure based on random edges should be used instead.
][
  Shirley #link("<cite:Shirley91>")[1991] 首次引入了使用不一致性来评估计算机图形中样本模式的质量。Mitchell #link("<cite:Mitchell92>")[1992];、Dobkin 和 Mitchell #link("<cite:Dobkin93>")[1993] 以及 Dobkin、Eppstein 和 Mitchell #link("<cite:Dobkin96>")[1996] 在此基础上进行了研究。Dobkin 等人的论文中一个重要的观察是，本章中使用的盒子不一致性度量以及其他将不一致性应用于像素采样模式的工作，并不特别适合测量随机定向边缘通过像素的采样模式的准确性，而应使用基于随机边缘的不一致性度量。
]

#parec[
  Mitchell's first paper on discrepancy introduced the idea of using deterministic low-discrepancy sequences for sampling, removing all randomness in the interest of lower discrepancy #link("<cite:Mitchell92>")[Mitchell 1992];. The seminal book on quasi-random sampling and algorithms for generating low-discrepancy patterns was written by Niederreiter #link("<cite:Niederreiter92>")[1992];. For a more recent treatment, see Dick and Pillichshammer's excellent book #link("<cite:Dick2010>")[2010];.
][
  Mitchell 关于不一致性的第一篇论文引入了使用确定性低不一致性序列进行采样的想法，通过使用确定性序列消除所有随机性，以实现较低的不一致性 #link("<cite:Mitchell92>")[Mitchell 1992];。关于准随机采样和生成低不一致性模式算法的开创性书籍由 Niederreiter #link("<cite:Niederreiter92>")[1992] 撰写。对于更近期的研究，请参阅 Dick 和 Pillichshammer 的优秀著作 #link("<cite:Dick2010>")[2010];。
]

#parec[
  Keller and collaborators have investigated quasi-random sampling patterns for a variety of applications in graphics #link("<cite:Keller96>")[Keller 1996];, #link("<cite:Keller97>")[1997];, #link("<cite:Keller01>")[2001];, #link("<cite:Kollig00>")[Kollig and Keller 2000];. Keller's "Quasi-Monte Carlo image synthesis in a nutshell" #link("<cite:Keller2012>")[2012] is a good introduction to quasi–Monte Carlo for rendering. Friedel and Keller #link("<cite:Friedel2002>")[2002] described an approach for efficient evaluation of the radical inverse based on reusing some values across multiple sample points. Both the sampling approach based on $(0 , 2)$ -sequences that is used in the `PaddedSobolSampler` and the algorithm implemented in the `BinaryPermuteScrambler` are described in a paper by Kollig and Keller #link("<cite:Kollig02>")[2002];. Basu and Owen #link("<cite:Basu2016>")[2016] analyzed the effect of the distortion from warping uniform samples in the context of quasi–Monte Carlo.
][
  Keller 和合作者研究了准随机采样模式在图形中的各种应用 #link("<cite:Keller96>")[Keller 1996];, #link("<cite:Keller97>")[1997];, #link("<cite:Keller01>")[2001];, #link("<cite:Kollig00>")[Kollig 和 Keller 2000];。Keller 的“准蒙特卡罗图像合成概述” #link("<cite:Keller2012>")[2012] 是渲染中准蒙特卡罗的良好介绍。Friedel 和 Keller #link("<cite:Friedel2002>")[2002] 描述了一种基于在多个样本点之间重用某些值的高效评估径向逆函数的方法。Kollig 和 Keller #link("<cite:Kollig02>")[2002] 的论文中描述了 `PaddedSobolSampler` 中使用的基于 $(0 , 2)$ -序列的采样方法和 `BinaryPermuteScrambler` 中实现的算法。Basu 和 Owen #link("<cite:Basu2016>")[2016] 分析了在准蒙特卡罗背景下扭曲均匀样本的失真效果。
]

#parec[
  The discrepancy bounds for jittered sampling in Equation (8.17) are due to Pausinger and Steinerberger #link("<cite:Pausinger2016>")[2016];.
][
  方程 (8.17) 中抖动采样的不一致性界限归功于 Pausinger 和 Steinerberger #link("<cite:Pausinger2016>")[2016];。
]

#parec[
  $(0 , 2)$ -sequences are one instance of a general type of low-discrepancy sequence known as $(t , s)$ -sequences and $(t , m , s)$ -nets. These were discussed further by Niederreiter #link("<cite:Niederreiter92>")[1992] and Dick and Pillichshammer #link("<cite:Dick2010>")[2010];.
][
  $(0 , 2)$ -序列是称为 $(t , s)$ -序列和 $(t , m , s)$ -网的一般类型低不一致性序列的一个实例。这些内容由 Niederreiter #link("<cite:Niederreiter92>")[1992] 和 Dick 和 Pillichshammer #link("<cite:Dick2010>")[2010] 进一步讨论。
]

#parec[
  Sobol' #link("<cite:Sobol67>")[1967] introduced the family of generator matrices used in Section 8.7. Antonov and Saleev #link("<cite:Antonov1979>")[1979] showed that enumerating Sobol' sample points in Gray code order leads to a highly efficient implementation; see also Bratley and Fox #link("<cite:Bratley1988>")[1988] and Wächter's Ph.D.~dissertation #link("<cite:Wachter2008>")[2008] for further discussion of high-performance implementation of base-2 generator matrix operations. The Sobol' generator matrices our implementation uses are enhanced versions derived by Joe and Kuo #link("<cite:Joe2008>")[2008] that improve the 2D projections of sample points. Grünschloss and collaborators found generator matrices for 2D sampling that satisfy the base-2 elementary intervals and are also optimized to improve the sampling pattern's blue noise properties (Grünschloss et al.~#link("<cite:Gruenschloss08>")[2008];, Grünschloss and Keller #link("<cite:Gruenschloss09>")[2009];).
][
  Sobol' #link("<cite:Sobol67>")[1967] 引入了第 8.7 节中使用的生成矩阵族。Antonov 和 Saleev #link("<cite:Antonov1979>")[1979] 显示，按 Gray 码顺序枚举 Sobol' 样本点可实现高效实现；有关二进制生成矩阵操作高性能实现的进一步讨论，请参阅 Bratley 和 Fox #link("<cite:Bratley1988>")[1988] 以及 Wächter 的博士论文 #link("<cite:Wachter2008>")[2008];。我们使用的 Sobol' 生成矩阵是 Joe 和 Kuo #link("<cite:Joe2008>")[2008] 派生的增强版本，改进了样本点的二维投影。Grünschloss 和合作者发现了满足二进制基本区间的二维采样生成矩阵，并且还优化了以改善采样模式的蓝噪声特性 (Grünschloss 等人 #link("<cite:Gruenschloss08>")[2008];, Grünschloss 和 Keller #link("<cite:Gruenschloss09>")[2009];)。
]

#parec[
  Braaten and Weller introduced the idea of using digit permutations to improve Halton sample points #link("<cite:Braaten1979>")[1979];; they used a single permutation for all the digits in a given base, but determined permutations incrementally in order to optimize the $d$ -dimensional distribution of points. Better results can be had by using per-digit permutations (as is done in the `DigitPermutation` class) and by using carefully constructed deterministic permutations (as is not). Faure #link("<cite:Faure1992>")[1992] described a deterministic approach for computing permutations for scrambled radical inverses; more recently, Faure and Lemieux #link("<cite:Faure2009>")[2009] surveyed a variety of approaches for doing so and proposed a new approach that ensures that the 1- and 2-dimensional projections of scrambled sample points are well distributed.
][
  Braaten 和 Weller 引入了使用数字置换来改进 Halton 样本点的想法 #link("<cite:Braaten1979>")[1979];；他们为给定基数中的所有数字使用单个置换，但逐步确定置换以优化点的 $d$ 维分布。通过使用每位数字置换（如 `DigitPermutation` 类中所做的）和使用精心构造的确定性置换（如未做的）可以获得更好的结果。Faure #link("<cite:Faure1992>")[1992] 描述了一种用于计算加扰径向逆的置换的确定性方法；最近，Faure 和 Lemieux #link("<cite:Faure2009>")[2009] 调查了多种方法，并提出了一种新方法，确保加扰样本点的 1 和 2 维投影分布良好。
]

#parec[
  The nested uniform digit scrambling that has become known as Owen scrambling was introduced by Owen #link("<cite:Owen1995>")[1995];, though in its original form it had high storage requirements for the permutations. Tan and Boyle #link("<cite:Tan2000>")[2000] proposed switching to a fixed permutation after some number of digits, and Friedel and Keller #link("<cite:Friedel2002>")[2002] cached lazily generated permutations. Owen #link("<cite:Owen2003>")[2003] proposed the hash-based permutation approach that is implemented in both `OwenScrambledRadicalInverse()` and the `OwenScrambler` class. Laine and Karras #link("<cite:Laine2011>")[2011] noted that in base 2, nested uniform digit scrambling could be implemented in parallel across all the digits. The specific function used to do so in the `FastOwenScrambler` is due to Vegdahl #link("<cite:Vegdahl2021>")[2021];. See also Burley #link("<cite:Burley2020>")[2020] for further discussion of this approach.
][
  已知的 Owen 加扰的嵌套均匀数字加扰是由 Owen #link("<cite:Owen1995>")[1995] 引入的，尽管其原始形式对置换的存储要求很高。Tan 和 Boyle #link("<cite:Tan2000>")[2000] 提议在某些位数后切换到固定置换，Friedel 和 Keller #link("<cite:Friedel2002>")[2002] 缓存了懒惰生成的置换。Owen #link("<cite:Owen2003>")[2003] 提出了基于哈希的置换方法，该方法在 `OwenScrambledRadicalInverse()` 和 `OwenScrambler` 类中实现。Laine 和 Karras #link("<cite:Laine2011>")[2011] 指出，在二进制中，嵌套均匀数字加扰可以在所有数字上并行实现。`FastOwenScrambler` 中用于执行此操作的特定函数归功于 Vegdahl #link("<cite:Vegdahl2021>")[2021];。有关此方法的进一步讨论，请参阅 Burley #link("<cite:Burley2020>")[2020];。
]

#parec[
  The algorithms used for computing sample indices within given pixels in Sections 8.6.3 and 8.7.4 were introduced by Grünschloss et al.~#link("<cite:Grunschloss2012>")[2012];.
][
  第 8.6.3 和 8.7.4 节中用于计算给定像素内样本索引的算法由 Grünschloss 等人 #link("<cite:Grunschloss2012>")[2012] 引入。
]

#parec[
  #emph[Rank-1 lattices] are a deterministic approach for constructing well-distributed point sets. They were introduced to graphics by Keller #link("<cite:Keller2004>")[2004] and Dammertz and Keller #link("<cite:Dammertz2008b>")[2008b];. More recently, Liu et al.~#link("<cite:Liu2021>")[2021] extended them to high-dimensional integration problems in rendering.
][
  #emph[秩-1 格子] 是一种用于构建分布良好点集的确定性方法。它们由 Keller #link("<cite:Keller2004>")[2004] 和 Dammertz 和 Keller #link("<cite:Dammertz2008b>")[2008b] 引入到图形中。最近，Liu 等人 #link("<cite:Liu2021>")[2021] 将它们扩展到渲染中的高维积分问题。
]

#parec[
  As the effectiveness of both low-discrepancy sampling and blue noise has become better understood, a number of researchers have developed sampling techniques that target both metrics. Examples include Ahmed et al.~#link("<cite:Ahmed2016>")[2016];, who rearranged low-discrepancy sample points to improve blue noise properties, and Perrier et al.~#link("<cite:Perrier2018>")[2018];, who found Owen scrambling permutations that led to good blue noise characteristics. Heitz et al.~#link("<cite:Heitz2019:ldsample>")[2019] started with an Owen-scrambled point set and then improved its blue noise characteristics by solving an optimization problem that sets per-pixel seeds for randomization of the points in a way that decorrelates the error in integrating a set of test functions at nearby pixels. The approach implemented in the `ZSobolSampler` based on permuted Morton indices to achieve blue noise was introduced by Ahmed and Wonka #link("<cite:Ahmed2020>")[2020];.
][
  随着对低不一致性采样和蓝噪声的有效性理解的加深，许多研究人员开发了针对这两个指标的采样技术。例子包括 Ahmed 等人 #link("<cite:Ahmed2016>")[2016];，他们重新排列低不一致性样本点以改善蓝噪声特性，以及 Perrier 等人 #link("<cite:Perrier2018>")[2018];，他们找到了导致良好蓝噪声特性的 Owen 加扰置换。Heitz 等人 #link("<cite:Heitz2019:ldsample>")[2019] 从一个 Owen 加扰点集开始，然后通过解决一个优化问题来改善其蓝噪声特性，该问题设置每个像素的种子以随机化点，以便在附近像素上积分一组测试函数时去相关误差。Ahmed 和 Wonka 引入的方法在 `ZSobolSampler` 中通过置换 Morton 索引实现蓝噪声 #link("<cite:Ahmed2020>")[2020];。
]

#parec[
  An exciting recent development in this area is the recent paper by Ahmed and Wonka #link("<cite:Ahmed2021>")[2021] that presents algorithms to directly enumerate all the valid digital $(0 , m , 2)$ -nets. In turn, it is possible to apply various optimization algorithms to the generated point sets (e.g., to improve their blue noise characteristics). See also recent work by Helmer et al.~#link("<cite:Helmer2021>")[2021] for algorithms that incrementally generate sequences of Owen-scrambled Halton, Sobol', and Faure points, allowing both optimization of the distribution of the points and highly efficient point generation.
][
  这一领域的一个令人兴奋的最新发展是 Ahmed 和 Wonka #link("<cite:Ahmed2021>")[2021] 的最新论文，提出了直接枚举所有有效数字网格 $(0 , m , 2)$ -网的算法。反过来，可以将各种优化算法应用于生成的点集（例如，以改善其蓝噪声特性）。另请参阅 Helmer 等人 #link("<cite:Helmer2021>")[2021] 的最新工作，该工作提出了增量生成 Owen 加扰 Halton、Sobol' 和 Faure 点序列的算法，既可以优化点的分布，也可以实现高效的点生成。
]

=== Filtering and Reconstruction
#parec[
  Cook (1986) first introduced the Gaussian filter to graphics. Mitchell and Netravali (1988) investigated a family of filters using experiments with human observers to find the most effective ones; the `MitchellFilter` in this chapter is the one they chose as the best. Kajiya and Ullner (1981) investigated image filtering methods that account for the effect of the reconstruction characteristics of Gaussian falloff from pixels in CRTs. Betrisey et al.~(2000) described Microsoft's ClearType technology for display of text on LCDs. Alim (2013) applied reconstruction techniques that attempt to minimize the error between the reconstructed image and the original continuous image, even in the presence of discontinuities.
][
  Cook（1986）首次将高斯滤波器引入图形学。Mitchell 和 Netravali（1988）通过人类观察者的实验研究了一系列滤波器，以找到最有效的滤波器；本章中的 `MitchellFilter` 是他们选择的最佳滤波器。 Kajiya 和 Ullner（1981）研究了图像滤波方法，这些方法考虑了 CRT 像素的高斯衰减重建特性。Betrisey 等人（2000）描述了微软的 ClearType 技术，用于在 LCD 上显示文本。Alim（2013）应用了重建技术，试图在存在不连续性的情况下，将重建图像与原始连续图像之间的误差最小化。
]

#parec[
  There has been quite a bit of research into reconstruction filters for image resampling applications. Although this application is not the same as reconstructing nonuniform samples for image synthesis, much of this experience is applicable. Turkowski (1990a) reported that the Lanczos windowed sinc filter gives the best results among a number of filters for image resampling. Meijering et al.~(1999) tested a variety of filters for image resampling by applying a series of transformations to images such that if perfect resampling had been done, the final image would be the same as the original. They also found that the Lanczos window performed well (as did a few others) and that truncating the sinc without a window gave some of the worst results. Other work in this area includes papers by Möller et al.~(1997) and Machiraju and Yagel (1996).
][
  在图像重采样应用中，重建滤波器的研究相当多。尽管这种应用与图像合成的非均匀样本重建不同，但许多经验是适用的。Turkowski（1990a）报告说，Lanczos 窗口化 sinc 滤波器在许多图像重采样滤波器中效果最佳。 Meijering 等人（1999）通过对图像应用一系列变换来测试各种图像重采样滤波器，以便如果完美重采样完成，最终图像将与原始图像相同。他们还发现 Lanczos 窗口表现良好（还有其他几个），而未使用窗口截断的 sinc 滤波器会产生一些最差的结果。该领域的其他工作包括 Möller 等人（1997）和 Machiraju 和 Yagel（1996）的论文。
]


=== Adaptive Sampling and Reconstruction

#parec[
  `pbrt` does not include samplers that perform adaptive sampling. Though adaptive sampling has been an active area of research, our own experience with the resulting algorithms has been that while most work well in some cases, few are robust across a wide range of scenes. (Adaptive sampling further introduces a coupling between the `Sampler` and the `Film` that we prefer to avoid.)
][
  `pbrt` 不包括执行自适应采样的采样器。尽管自适应采样一直是一个活跃的研究领域，但我们自己的经验是，虽然大多数算法在某些情况下表现良好，但很少有算法在广泛的场景中具有鲁棒性。（自适应采样进一步引入了我们希望避免的 `Sampler` 和 `Film` 之间的耦合。）
]

#parec[
  Early work on adaptive sampling includes that of Lee, Redner, and Uselton (1985), who developed a technique for adaptive sampling based on statistical tests that made it possible to compute images to a given error tolerance; Mitchell (1987), who investigated the use of contrast differences for adaptive sampling; and Purgathofer (1987), who applied statistical tests. Kajiya applied adaptive sampling to the Monte Carlo light transport integral (1986).
][
  关于自适应采样的早期工作包括 Lee、Redner 和 Uselton（1985）的研究，他们开发了一种基于统计测试的自适应采样技术，使得可以计算出给定误差容限的图像；Mitchell（1987）研究了对比差异在自适应采样中的应用；Purgathofer（1987）应用了统计测试。Kajiya 将自适应采样应用于蒙特卡罗光传输积分（1986）。
]

#parec[
  Mitchell (1987) observed that standard image reconstruction techniques fail in the presence of adaptive sampling: the contribution of a dense clump of samples in part of the filter's extent may incorrectly have a large effect on the final value purely due to the number of samples taken in that region. He described a multi-stage box filter that addresses this issue. Kirk and Arvo (1991) identified a subtle problem with adaptive sampling algorithms: in short, if a set of samples is not only used to decide if more samples should be taken but is also added to the image, bias is introduced.
][
  Mitchell（1987）指出，在自适应采样的情况下，标准图像重建技术可能失效：在滤波器范围的一部分中，样本的密集簇的贡献可能仅由于在该区域内采样数量的原因而错误地对最终值产生较大影响。他描述了一种多阶段框滤波器来解决这个问题。 Kirk 和 Arvo（1991）发现了自适应采样算法的一个微妙问题：简而言之，如果一组样本不仅用于决定是否应采集更多样本，而且还被添加到图像中，则会引入偏差。
]

#parec[
  Zwicker et al.'s survey article (2015) includes a thorough summary of work in adaptive sampling through 2015. More recently, Ahmed et al.~(2017) described an approach for generating adaptive samples that maintains good blue noise properties. Vogels et al.~(2018), Kuznetsov et al.~(2018), and Hasselgren et al.~(2020) have all trained neural nets to determine where additional samples should be taken in a noisy image.
][
  Zwicker 等人的综述文章（2015）包括对 2015 年之前自适应采样工作的全面总结。最近，Ahmed 等人（2017）描述了一种生成自适应样本的方法，保持良好的蓝噪声特性。 Vogels 等人（2018）、Kuznetsov 等人（2018）和 Hasselgren 等人（2020）都训练了神经网络来确定在噪声图像中应采集更多样本的位置。
]

#parec[
  Much recent work on adaptive sampling has been based on the foundation of Durand et al.'s (2005) frequency analysis of light transport. Much of it not only adapts sampling based on frequency space insights but also applies filters that are tailored to the frequency content of the functions being sampled. Shinya (1993) and Egan et al.~(2009) developed adaptive sampling and reconstruction methods focused on rendering motion blur. Belcour et al.~(2013) computed 5D covariance of image, time, and lens defocus and applied adaptive sampling and high-quality reconstruction. While most earlier work focused on single effects—soft shadows, motion blur, etc.—Wu et al.~(2017) showed how to efficiently filter according to multiple such effects at once.
][
  最近关于自适应采样的许多工作基于 Durand 等人（2005）对光传输的频率分析的基础。许多研究不仅根据频率空间的见解调整采样，还应用了针对被采样函数频率内容量身定制的滤波器。 Shinya（1993）和 Egan 等人（2009）开发了专注于渲染运动模糊的自适应采样和重建方法。Belcour 等人（2013）计算了图像、时间和镜头散焦的 5D 协方差，并应用了自适应采样和高质量重建。 虽然早期研究大多集中在单一效果上，如软阴影和运动模糊，但 Wu 等人（2017）展示了如何同时有效地滤波多个此类效果。
]


