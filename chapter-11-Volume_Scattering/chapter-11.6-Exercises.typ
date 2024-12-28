#import "../template.typ": parec


== Exercises

#parec[
  The #link("../Volume_Scattering/Media.html#GridMedium")[GridMedium] and #link("../Volume_Scattering/Media.html#RGBGridMedium")[RGBGridMedium] classes use a relatively large amount of memory for complex volume densities. Determine their memory requirements when used with complex medium densities and modify their implementations to reduce memory use. One approach might be to detect regions of space with constant (or relatively constant) density values using an octree data structure and to only refine the octree in regions where the densities are changing. Another possibility is to use less memory to record each density value—for example, by computing the minimum and maximum densities and then using 8 or 16 bits per density value to interpolate between them. What sorts of errors appear when either of these approaches is pushed too far?
][
  #link("../Volume_Scattering/Media.html#GridMedium")[GridMedium] 和 #link("../Volume_Scattering/Media.html#RGBGridMedium")[RGBGridMedium] 类在处理复杂体积密度时使用了相对较大的内存。确定它们在使用复杂介质密度时的内存需求，并修改它们的实现以减少内存使用。一种方法可能是使用八叉树数据结构检测具有恒定（或相对恒定）密度值的空间区域，并仅在密度变化的区域对八叉树进行细化处理。另一种可能性是使用更少的内存来记录每个密度值，例如，通过计算最小和最大密度，然后使用8或16位每个密度值在它们之间进行插值。当这些方法中的任何一种被推得太远时，会出现什么样的错误？
]

#parec[
  Improve #link("../Volume_Scattering/Media.html#GridMedium")[GridMedium] to allow specifying grids of arbitrary #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[Spectrum] values to define emission. How much more memory does your approach use for blackbody emission distributions than the current implementation, which only stores floating-point temperatures in that case? How much memory does it use when other spectral representations are provided? Can you find ways of reducing memory use—for example, by detecting equal spectra and only storing them in memory once?
][
  改进 #link("../Volume_Scattering/Media.html#GridMedium")[GridMedium] 以允许指定任意 #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[Spectrum] 值的网格来定义发射。与当前仅在这种情况下存储浮点温度的实现相比，您的方法在黑体发射分布上使用了多少内存？当提供其他光谱表示时，它使用了多少内存？您能找到减少内存使用的方法吗，例如，通过检测相等的光谱并仅在内存中存储一次？
]

#parec[
  One shortcoming of the majorants computed by the #link("../Volume_Scattering/Media.html#RGBGridMedium")[RGBGridMedium] is that they do not account for spectral variation in the scattering coefficients—although conservative, they may give a loose bound for wavelengths where the coefficients are much lower than the maximum values. Computing tighter majorants is not straightforward in a spectral renderer: in a renderer that used RGB color for rendering, it is easy to maintain a majorant grid of RGB values instead of Float, though doing so is more difficult with a spectral renderer, for reasons related to why #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[RGBUnboundedSpectrum] values are stored in the grids for σ\_a and σ\_s and not RGB. (See the discussion of this topic before the \<\<#link("Media.html#fragment-InitializemonomajorantGridvoxelforRGBsigmaaandsigmas-0")[Initialize majorantGrid voxel for RGB σ\_a and σ\_s];\>\> fragment.)
][
  #link("../Volume_Scattering/Media.html#RGBGridMedium")[RGBGridMedium] 计算的主导值的一个缺点是它们没有考虑散射系数的光谱变化——尽管保守，但它们可能会对系数远低于最大值的波长给出宽松的界限。在光谱渲染器中计算更精确的主导值并不简单：在使用RGB颜色进行渲染的渲染器中，维护RGB值的主导网格而不是Float很容易，尽管由于与为什么 #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[RGBUnboundedSpectrum] 值存储在 σ\_a 和 σ\_s 的网格中而不是RGB相关的原因，在光谱渲染器中这样做更困难。（请参阅 \<\<#link("Media.html#fragment-InitializemonomajorantGridvoxelforRGBsigmaaandsigmas-0")[初始化 majorantGrid 体素用于 RGB σ\_a 和 σ\_s];\>\> 片段之前对此主题的讨论。）
]

#parec[
  Investigate this issue and develop an approach that better accounts for spectral variation in the scattering coefficients to return wavelength-varying majorants when #link("../Volume_Scattering/Media.html#RGBGridMedium::SampleRay")[RGBGridMedium::SampleRay()] is called. You might, for example, find a way to compute #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[RGBUnboundedSpectrum] values that bound the maximum of two or more others. How much overhead does your representation introduce? How much is rendering time improved for scenes with colored media due to more efficient sampling when it is used?
][
  调查此问题并开发一种更好地考虑散射系数光谱变化的方法，以便在调用 #link("../Volume_Scattering/Media.html#RGBGridMedium::SampleRay")[RGBGridMedium::SampleRay()] 时返回波长变化的主导值。例如，您可以找到一种方法来计算 #link("../Radiometry,_Spectra,_and_Color/Color.html#RGBUnboundedSpectrum")[RGBUnboundedSpectrum] 值，以限制两个或多个其他值的最大值。您的表示引入了多少开销？使用更有效的采样后，在具有彩色介质的场景中渲染时间提高了多少？
]

#parec[
  The Medium implementations that use the #link("../Volume_Scattering/Media.html#MajorantGrid")[MajorantGrid] all currently use fixed grid resolutions for it, regardless of the amount of variation in density in their underlying media. Read the paper by Yue et al.~(2011) and use their approach to choose those resolutions adaptively. Then, measure performance over a sweep of grid sizes with a variety of volume densities. Are there any cases where there is a significant performance benefit from a different grid resolution? Considering their assumptions and pbrt's implementation, can you explain any discrepancies between grid sizes set with their heuristics versus the most efficient resolution in pbrt?
][
  使用 #link("../Volume_Scattering/Media.html#MajorantGrid")[MajorantGrid] 的 Medium 实现目前都为其使用固定的网格分辨率，而不考虑其基础介质中的密度变化量。请阅读 Yue 等人（2011年）的论文，并使用他们的方法自适应地选择这些分辨率。然后，在各种体积密度的网格大小范围内测量性能。在不同的网格分辨率下，是否存在显著的性能优势？考虑他们的假设和 pbrt 的实现，您能解释使用他们的启发式设置的网格大小与 pbrt 中最有效的分辨率之间的任何差异吗？
]

#parec[
  Read Wrenninge's paper (2016) on a time-varying density representation for motion blur in volumes and implement this approach in pbrt. One challenge will be to generate volumes in this representation; you may need to implement a physical simulation system in order to make some yourself.
][
  请阅读 Wrenninge（2016年）的关于运动模糊体积的时间变化密度表示的论文，并在 pbrt 中实现这种方法。一个挑战将是生成这种表示的体积；您可能需要实现一个物理模拟系统来生成这些体积。
]


