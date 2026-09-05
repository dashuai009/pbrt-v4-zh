#import "../template.typ": parec, ez_caption

== #ez_caption[Further Reading][延伸阅读]
<appendix-a-further-reading>

#parec[
  Rejection sampling was developed by von Neumann (#link(<taila-cite:vonNeumann1951>)[1951]) shortly after the Monte Carlo method was invented.
][
  蒙特卡洛方法问世不久，von Neumann（#link(<taila-cite:vonNeumann1951>)[1951]）就提出了拒绝采样。
]

#parec[
  The alias method was introduced by Walker (#link(<taila-cite:Walker1974>)[1974], #link(<taila-cite:Walker1977>)[1977]). The algorithm that we have implemented to generate alias tables in the #link("https://pbr-book.org/4ed/Sampling_Algorithms/The_Alias_Method.html#AliasTable")[`AliasTable`] class is due to Vose (#link(<taila-cite:Vose1991>)[1991]). See Schwarz's article (#link(<taila-cite:Schwarz11>)[2011]) for extensive information about implementing alias tables and related techniques.
][
  别名法由 Walker（#link(<taila-cite:Walker1974>)[1974]、#link(<taila-cite:Walker1977>)[1977]）提出。#link("https://pbr-book.org/4ed/Sampling_Algorithms/The_Alias_Method.html#AliasTable")[`AliasTable`] 中用于生成别名表的算法来自 Vose（#link(<taila-cite:Vose1991>)[1991]）。关于别名表的实现及相关技术，Schwarz 的文章（#link(<taila-cite:Schwarz11>)[2011]）提供了详尽资料。
]

#parec[
  A number of algorithms for reservoir sampling were described by Vitter (#link(<taila-cite:Vitter1985>)[1985]), though he credits the basic algorithm we outlined at the start of #link("https://pbr-book.org/4ed/Sampling_Algorithms/Reservoir_Sampling.html#sec:reservoir-sampling")[Section A.2] to Alan Waterman. The weighted reservoir sampling algorithm in `pbrt`'s #link("https://pbr-book.org/4ed/Sampling_Algorithms/Reservoir_Sampling.html#WeightedReservoirSampler")[`WeightedReservoirSampler`] class is due to Chao (#link(<taila-cite:Chao1982>)[1982]).
][
  Vitter（#link(<taila-cite:Vitter1985>)[1985]）介绍了多种蓄水池采样算法，不过他将 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Reservoir_Sampling.html#sec:reservoir-sampling")[第 A.2 节] 开头概述的基本算法归功于 Alan Waterman。`pbrt` 的 #link("https://pbr-book.org/4ed/Sampling_Algorithms/Reservoir_Sampling.html#WeightedReservoirSampler")[`WeightedReservoirSampler`] 所用的加权蓄水池采样算法来自 Chao（#link(<taila-cite:Chao1982>)[1982]）。
]

#parec[
  The square to disk mapping in #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[Section A.5.1] was described by Shirley and Chiu (#link(<taila-cite:Shirley97>)[1997]). The implementation here benefits by observations in Shirley's 2011 blog by Dave Cline and the commenter “franz” that the logic could be simplified considerably from the original algorithm (Shirley #link(<taila-cite:Shirley2011>)[2011]). Articles by Shirley and collaborators describe a number of useful recipes for warping uniform random numbers to useful distributions for rendering (Shirley #link(<taila-cite:Shirley92>)[1992]; Shirley et al. #link(<taila-cite:Shirley2019>)[2019]).
][
  #link("https://pbr-book.org/4ed/Sampling_Algorithms/Sampling_Multidimensional_Functions.html#sec:unit-disk-sample")[第 A.5.1 节] 的正方形到圆盘映射由 Shirley 和 Chiu（#link(<taila-cite:Shirley97>)[1997]）介绍。这里的实现还受益于 Dave Cline 和署名“franz”的评论者在 Shirley 的 2011 年博客中提出的观察：原算法的逻辑可以大幅简化（Shirley #link(<taila-cite:Shirley2011>)[2011]）。Shirley 及其合作者的文章还给出了多种实用方法，将均匀随机数变换为渲染所需的分布（Shirley #link(<taila-cite:Shirley92>)[1992]；Shirley 等 #link(<taila-cite:Shirley2019>)[2019]）。
]

#parec[
  The summed-area table data structure was introduced by Crow (#link(<taila-cite:Crow84>)[1984]). Its use for efficiently sampling arbitrary rectangluar regions of images was demonstrated by Bitterli et al. (#link(<taila-cite:Bitterli2015>)[2015]).
][
  累积面积表这一数据结构由 Crow（#link(<taila-cite:Crow84>)[1984]）提出。Bitterli 等人（#link(<taila-cite:Bitterli2015>)[2015]）展示了如何用它高效采样图像中的任意矩形区域。
]

#parec[
  A number of additional sampling techniques have been developed for tabularized multidimensional distributions. Steigleder and McCool (#link(<taila-cite:SteiglederMcCool03>)[2003]) linearized 2D and higher dimensional domains into 1D using a Hilbert curve and then sampled using 1D samples over the 1D domain, which still maintains desirable stratification properties of the sampling distribution thanks to the spatial coherence preserving properties of the Hilbert curve. McCool and Harwood (#link(<taila-cite:McCool97>)[1997]) as well as Clarberg et al. (#link(<taila-cite:Clarberg05>)[2005]) described an approach for sampling images based on quadtrees that repeatedly transforms uniform sample values until they match a target distribution.
][
  针对表格化的多维分布，研究者还提出了多种采样技术。Steigleder 和 McCool（#link(<taila-cite:SteiglederMcCool03>)[2003]）用 Hilbert 曲线将二维及更高维的定义域线性化为一维，再在该一维域中使用一维样本采样。由于 Hilbert 曲线能够保持空间连贯性，这种方法仍能保留采样分布所需的分层性质。McCool 和 Harwood（#link(<taila-cite:McCool97>)[1997]）以及 Clarberg 等人（#link(<taila-cite:Clarberg05>)[2005]）介绍了一种基于四叉树的图像采样方法，通过反复变换均匀样本值，使其最终符合目标分布。
]

#parec[
  Lawrence et al. (#link(<taila-cite:Lawrence05>)[2005]) described an adaptive representation for tabularized CDFs, where the CDF is approximated with a piecewise-linear function with fewer, irregularly spaced vertices than the given CDF. This approach can substantially reduce storage requirements and improve lookup efficiency, taking advantage of the fact that large ranges of the CDF may be efficiently approximated with a single linear function.
][
  Lawrence 等人（#link(<taila-cite:Lawrence05>)[2005]）介绍了表格化 CDF 的自适应表示：使用分段线性函数近似给定 CDF，所需顶点更少，且间距不规则。CDF 的大段区间往往可由单个线性函数有效近似；利用这一点，该方法能显著降低存储需求，提高查找效率。
]

#parec[
  The time spent searching the CDF when sampling from a tabularized distribution can be reduced with auxiliary data structures. Chen and Asau (#link(<taila-cite:Chen1974>)[1974]) suggested the guide table method, where an additional array of offsets into the table gives a starting point for the search. Cline et al. (#link(<taila-cite:Cline09>)[2009]) introduced this approach to graphics and also presented a method based on approximating the inverse CDF as a piecewise-linear function of $xi$, thus enabling constant-time lookups at a cost of some accuracy.
][
  从表格化分布采样时，可以利用辅助数据结构缩短搜索 CDF 的时间。Chen 和 Asau（#link(<taila-cite:Chen1974>)[1974]）提出了引导表方法：额外保存一个由表内偏移组成的数组，为搜索提供起点。Cline 等人（#link(<taila-cite:Cline09>)[2009]）将它引入图形学，还提出用关于 $xi$ 的分段线性函数近似逆 CDF 的方法，以牺牲部分精度换取常数时间查找。
]

#parec[
  Binder and Keller (#link(<taila-cite:Binder2020>)[2020]) presented algorithms for building and sampling from tabularized distributions that run efficiently on GPUs. Another innovative approach to sampling from such CDFs was described by Morrical and Zellmann (#link(<taila-cite:Morrical2021>)[2021]), who showed how hardware ray tracing capabilities could be used for this task. Vitsas et al. (#link(<taila-cite:Vitsas2021>)[2021]) fit Gaussian mixture models to the sampling distribution of clear sky environment maps and showed a significant reduction in memory use with a sampling algorithm that does not require table search.
][
  Binder 和 Keller（#link(<taila-cite:Binder2020>)[2020]）给出了可在 GPU 上高效运行的算法，用于构建表格化分布并从中采样。Morrical 和 Zellmann（#link(<taila-cite:Morrical2021>)[2021]）介绍了另一种新方法，展示了如何利用硬件光线追踪能力完成这类 CDF 的采样。Vitsas 等人（#link(<taila-cite:Vitsas2021>)[2021]）用高斯混合模型拟合晴空环境贴图的采样分布，并展示了一种无需查表、可显著降低内存用量的采样算法。
]

#parec[
  Arithmetic coding offers another interesting way to approach sampling from distributions (MacKay #link(<taila-cite:MacKay03>)[2003], p. 118; Piponi #link(<taila-cite:Piponi12>)[2012]). If we have a discrete set of probabilities from which we would like to generate samples, one way to approach the problem is to encode the CDF as a binary tree where each node splits the $[0, 1\)$ interval at some point and where, given a random sample $xi$, we determine which sample value it corresponds to by traversing the tree until we reach the leaf node for its sample value. Ideally, we would like leaf nodes that represent higher probabilities to be higher up in the tree, so that it takes fewer traversal steps to find them (and thus those more frequently generated samples can be found more quickly). Looking at the problem from this perspective, it can be shown that the optimal structure of such a tree is given by Huffman coding, which is normally used for compression.
][
  算术编码为分布采样提供了另一种有趣视角（MacKay #link(<taila-cite:MacKay03>)[2003]，第 118 页；Piponi #link(<taila-cite:Piponi12>)[2012]）。假设有一组离散概率，希望按它们生成样本，可以将 CDF 编码成二叉树，让每个节点在某处划分 $[0, 1\)$ 区间。给定随机样本 $xi$，沿树遍历至对应叶节点，就能确定样本值。理想情况下，概率越大的叶节点应越靠近树根，使其所需遍历步数更少，也就能更快找到那些更常生成的样本。从这个角度可以证明，此类树的最优结构由通常用于压缩的 Huffman 编码给出。
]

#block(breakable: false)[
#heading(level: 3, numbering: none)[#ez_caption[References][参考文献]]
#block[Binder, N., and A. Keller. 2020. Massively parallel construction of radix tree forests for the efficient sampling of discrete or piecewise constant probability distributions. _Monte Carlo and Quasi-Monte Carlo Methods (MCQMC 2018)_. arXiv: 1902.05942 \[cs\].] <taila-cite:Binder2020>
]

#block[Bitterli, B., J. Novák, and W. Jarosz. 2015. Portal-masked environment map sampling. _Computer Graphics Forum (Proceedings of the 2015 Eurographics Symposium on Rendering)_ 34 (4), 13–19.] <taila-cite:Bitterli2015>

#block[Chao, M. T. 1982. A general purpose unequal probability sampling plan. _Biometrika_ 69 (3), 653–56.] <taila-cite:Chao1982>

#block[Chen, H. C., and Y. Asau. 1974. On generating random variates from an empirical distribution. _AIIE Transactions_ 6 (2), 163–66.] <taila-cite:Chen1974>

#block[Clarberg, P., W. Jarosz, T. Akenine-Möller, and H. W. Jensen. 2005. Wavelet importance sampling: Efficiently evaluating products of complex functions. _ACM Transactions on Graphics (Proceedings of SIGGRAPH 2005)_ 24 (3), 1166–75.] <taila-cite:Clarberg05>

#block[Cline, D., A. Razdan, and P. Wonka. 2009. A comparison of tabular PDF inversion methods. _Computer Graphics Forum_ 28 (1), 154–60.] <taila-cite:Cline09>

#block[Crow, F. C. 1984. Summed-area tables for texture mapping. _Computer Graphics (Proceedings of SIGGRAPH ’84)_ 18, 207–12.] <taila-cite:Crow84>

#block[Lawrence, J., S. Rusinkiewicz, and R. Ramamoorthi. 2005. Adaptive numerical cumulative distribution functions for efficient importance sampling. _Rendering Techniques 2005: 16th Eurographics Workshop on Rendering_, 11–20.] <taila-cite:Lawrence05>

#block[MacKay, D. 2003. _Information Theory, Inference, and Learning Algorithms_. Cambridge: Cambridge University Press.] <taila-cite:MacKay03>

#block[McCool, M. D., and P. K. Harwood. 1997. Probability trees. _Proceedings of Graphics Interface ’97_, 37–46.] <taila-cite:McCool97>

#block[Morrical, N., and S. Zellmann. 2021. Inverse transform sampling using ray tracing hardware. In Marrs, A., P. Shirley, and I. Wald (eds.), _Ray Tracing Gems II_, 625–41. Berkeley: Apress.] <taila-cite:Morrical2021>

#block[Piponi, D. 2012. Lossless decompression and the generation of random samples. #link("http://blog.sigfpe.com/2012/01/lossless-decompression-and-generation.html")[http://blog.sigfpe.com/2012/01/lossless-decompression-and-generation.html].] <taila-cite:Piponi12>

#block[Schwarz, K. 2011. Darts, dice, and coins: Sampling from a discrete distribution. #link("http://www.keithschwarz.com/darts-dice-coins/")[http://www.keithschwarz.com/darts-dice-coins/].] <taila-cite:Schwarz11>

#block[Shirley, P. 1992. Nonuniform random point sets via warping. In D. Kirk (ed.), _Graphics Gems III_, 80–83. San Diego: Academic Press.] <taila-cite:Shirley92>

#block[Shirley, P. 2011. Improved code for concentric map. #link("http://psgraphics.blogspot.com/2011/01/improved-code-for-concentric-map.html")[http://psgraphics.blogspot.com/2011/01/improved-code-for-concentric-map.html].] <taila-cite:Shirley2011>

#block[Shirley, P., and K. Chiu. 1997. A low distortion map between disk and square. _Journal of Graphics Tools_ 2 (3), 45–52.] <taila-cite:Shirley97>

#block[Shirley, P., S. Laine, D. Hart, M. Pharr, P. Clarberg, E. Haines, M. Raab, and D. Cline. 2019. Sampling transformations zoo. In E. Haines and T. Akenine-Möller (eds.), _Ray Tracing Gems_, 223–46. Berkeley: Apress.] <taila-cite:Shirley2019>

#block[Steigleder, M., and M. McCool. 2003. Generalized stratified sampling using the Hilbert curve. _Journal of Graphics Tools_ 8 (3), 41–47.] <taila-cite:SteiglederMcCool03>

#block[Vitsas, N., K. Vardis, and G. Papaioannou. 2021. Sampling clear sky models using truncated Gaussian mixtures. _Proceedings of the Eurographics Symposium on Rendering_, 35–44.] <taila-cite:Vitsas2021>

#block[Vitter, J. S. 1985. Random sampling with a reservoir. _ACM Transactions on Mathematical Software_, 11 (1), 37–57.] <taila-cite:Vitter1985>

#block[von Neumann, J. 1951. Various techniques used in connection with random digits. _Journal of Research of the National Bureau of Standards, Applied Mathematics Series_ 12, 36–38.] <taila-cite:vonNeumann1951>

#block[Vose, M. D. 1991. A linear algorithm for generating random numbers with a given distribution. _IEEE Transactions on Software Engineering_ 17 (9), 972–75.] <taila-cite:Vose1991>

#block[Walker, A. J. 1974. New fast method for generating discrete random numbers with arbitrary frequency distributions. _Electronics Letters_ 10 (8): 127–28.] <taila-cite:Walker1974>

#block[Walker, A. J. 1977. An efficient method for generating discrete random variables with general distributions. _ACM Transactions on Mathematical Software_ 3 (3), 253–56.] <taila-cite:Walker1977>
