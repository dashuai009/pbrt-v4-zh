#import "../template.typ": parec, ez_caption

== Image Reconstruction
<image-reconstruction>

#parec[
  As discussed in Section~#link("../Cameras_and_Film/Film_and_Imaging.html#sec:film-filtering-samples")[5.4.3];, each pixel in the #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] computes an estimate of the integral of the product of a filter function with samples taken from the image function. In Section~#link("../Sampling_and_Reconstruction/Sampling_Theory.html#sec:sampling-theory")[8.1];, we saw that sampling theory provides a mathematical foundation for how this filtering operation should be performed in order to achieve an antialiased result. We should, in principle:
][
  如第#link("../Cameras_and_Film/Film_and_Imaging.html#sec:film-filtering-samples")[5.4.3];节所述，每个#link("../Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`];中的像素计算的是滤波函数与从图像函数中采样的样本的乘积的积分估计。 在第#link("../Sampling_and_Reconstruction/Sampling_Theory.html#sec:sampling-theory")[8.1];节中，我们看到采样理论为如何执行这种滤波操作以实现抗锯齿结果提供了数学基础。 原则上，我们应该：
]

#parec[
  + Reconstruct a continuous image function from the set of image samples.
][
  + 从图像样本集中重建一个连续的图像函数。
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + Prefilter that function to remove any frequencies past the Nyquist
      limit for the pixel spacing.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + 预滤波该函数以去除超过像素间距奈奎斯特极限的频率。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + Sample the prefiltered function at the pixel locations to compute the
      final pixel values.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 在像素位置对预滤波函数进行采样以计算最终的像素值。
  ]
]

#parec[
  Because we know that we will be resampling the function at only the pixel locations, it is not necessary to construct an explicit representation of the function. Instead, we can combine the first two steps using a single filter function.
][
  因为我们知道我们将仅在像素位置重新采样该函数，所以不需要构建函数的显式表示。 相反，我们可以使用单个滤波函数结合前两个步骤。
]

#parec[
  Recall that if the original function had been uniformly sampled at a frequency greater than the Nyquist frequency and reconstructed with the sinc filter, then the reconstructed function in the first step would match the original image function perfectly-quite a feat since we only have point samples. But because the image function almost always will have higher frequencies than could be accounted for by the sampling rate (due to edges, etc.), we chose to sample it nonuniformly, trading off noise for aliasing.
][
  回想一下，如果原始函数在频率高于奈奎斯特频率的情况下被均匀采样并用 sinc 滤波器重建，那么第一步中重建的函数将与原始图像函数完全匹配——这是一项壮举，因为我们只有点样本。 但由于图像函数几乎总是具有比采样率能够解释的更高频率（由于边缘等），我们选择非均匀采样，以噪声换取混叠。
]

#parec[
  The theory behind ideal reconstruction depends on the samples being uniformly spaced. While a number of attempts have been made to extend the theory to nonuniform sampling, there is not yet an accepted approach to this problem. Furthermore, because the sampling rate is known to be insufficient to capture the function, perfect reconstruction is not possible. Recent research in the field of sampling theory has revisited the issue of reconstruction with the explicit acknowledgment that perfect reconstruction is not generally attainable in practice. This slight shift in perspective has led to powerful new reconstruction techniques. In particular, the goal of research in reconstruction theory has shifted from perfect reconstruction to developing reconstruction techniques that can be shown to minimize error between the reconstructed function and the original function, #emph[regardless of whether the original was band
limited];.
][
  理想重建的理论依赖于样本均匀分布。 虽然已经有许多尝试将理论扩展到非均匀采样，但目前还没有被接受的方法。 此外，由于采样率已知不足以捕获函数，完美重建是不可能的。 采样理论领域的最新研究重新审视了重建问题，明确承认在实践中通常无法实现完美重建。 这种视角的细微转变导致了强大的新重建技术。 特别是，重建理论研究的目标已从完美重建转向开发能够证明最小化重建函数与原始函数之间误差的重建技术，#emph[无论原始函数是否带限];。
]

#parec[
  The sinc filter is not an appropriate choice here: recall that the ideal sinc filter is prone to ringing when the underlying function has frequencies beyond the Nyquist limit, meaning edges in the image have faint replicated copies of the edge in nearby pixels (the Gibbs phenomenon; see @sampling-and-aliasing-in-rendering. Furthermore, the sinc filter has #emph[infinite support];: it does not fall off to zero at a finite distance from its center, so all the image samples would need to be filtered for each output pixel. In practice, there is no single best filter function. Choosing the best one for a particular scene takes a mixture of quantitative evaluation and qualitative judgment. `pbrt` therefore provides a variety of choices.
][
  在这种情况下，sinc 滤波器并不是一个合适的选择：回想一下，当底层函数的频率超过奈奎斯特极限时，理想的 sinc 滤波器容易出现振铃现象，这意味着图像中的边缘在附近像素中有微弱的复制（吉布斯现象；参见@sampling-and-aliasing-in-rendering。 此外，sinc 滤波器具有#emph[无限支持];：它在距中心的有限距离处不会衰减为零，因此每个输出像素都需要对所有图像样本进行滤波。 在实践中，没有单一的最佳滤波函数。 为特定场景选择最佳滤波器需要定量评估和定性判断的结合。 因此，`pbrt`提供了多种选择。
]

#parec[
  @fig:filter-comparisons shows comparisons of zoomed-in regions of images rendered using a variety of the filters from this section to reconstruct pixel values.
][
  @fig:filter-comparisons 显示了使用本节中的各种滤波器重建像素值的图像放大区域的比较。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f48.svg"),
  caption: [
    #ez_caption[The pixel reconstruction filter used to convert the image
      samples into pixel values can have a noticeable effect on the character
      of the final image.
      Here, we see enlargements of a region of the imperial crown model,
      filtered with (a) the box filter, (b) Gaussian filter, and (c)
      Mitchell-Netravali filter.
      Note that the Mitchell filter gives the sharpest image, while the
      Gaussian blurs it.
      The box filter is the least desirable, since it allows high-frequency
      aliasing to leak into the final image.
      (Note the stair-step pattern along bright gold edges, for example.)
      #emph[(Crown model courtesy of Martin Lubich.)]][用于将图像样本重建为像素值的像素重建滤波器可以显著影响最终图像的特征。 在这里，我们看到帝国皇冠模型区域的放大图，分别用(a)盒式滤波器、(b)高斯滤波器和(c)Mitchell-Netravali滤波器进行滤波。 注意，Mitchell 滤波器给出了最清晰的图像，而高斯滤波器使其模糊。 盒式滤波器是最不理想的，因为它允许高频混叠渗入最终图像。 （例如，注意明亮金色边缘的阶梯图案。） #emph[(皇冠模型由 Martin Lubich 提供。)]]

  ],
)<filter-comparisons>

=== Filter Interface
<filter-interface>


#parec[
  The `Filter` class defines the interface for pixel reconstruction filters in `pbrt`. It is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/filter.h")[base/filter.h];.
][
  `Filter` 类定义了 `pbrt` 中像素重建滤波器的接口。 它在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/base/filter.h")[base/filter.h] 中定义。
]

```cpp
class Filter :
        public TaggedPointer<BoxFilter, GaussianFilter, MitchellFilter,
                             LanczosSincFilter, TriangleFilter> {
  public:
    <<Filter Interface>>       using TaggedPointer::TaggedPointer;
       static Filter Create(const std::string &name,
                                  const ParameterDictionary &parameters, const FileLoc *loc,
                                  Allocator alloc);
       Vector2f Radius() const;
       Float Evaluate(Point2f p) const;
       Float Integral() const;
       FilterSample Sample(Point2f u) const;
       std::string ToString() const;
};
```

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f49.svg"),
  caption: [
    #ez_caption[The extent of filters in pbrt is specified in terms of each one's radius from the origin to its cutoff point. The support of a filter is its total nonzero extent, here equal to twice its radius.][滤波器的范围是根据从原点到其截止点的半径指定的。滤波器的支持是其总的非零范围，在这里等于其半径的两倍。]
  ],
)<filter-width-support>

#parec[
  All filters are 2D functions that are centered at the origin and define a radius beyond which they have a value of~0. The radii are different in the $x$ and $y$ directions but are assumed to be symmetric in each. A filter provides its radius via the `Radius()` method.The filter's overall extent in each direction (its #emph[support];) is twice the value of its corresponding radius (@fig:filter-width-support).
][
  所有滤波器都是以原点为中心的二维函数，定义了一个半径，超出该半径它们的值为 0。 半径在 $x$ 和 $y$ 方向上不同，但假设在每个方向上是对称的。 滤波器通过 `Radius()` 方法提供其半径。 滤波器在每个方向上的总体范围（其#emph[支持];）是其相应半径值的两倍（@fig:filter-width-support）。
]

```cpp
Vector2f Radius() const;
```

#parec[
  `Filter` implementations must also provide a method that evaluates their filter function. This function may be called with points that are outside of the filter's radius; in this case, it is the responsibility of the implementation to detect this case and return the value~0. It is not required for the filter values returned by `Evaluate()` to integrate to~1 since the estimator used to compute pixel values, Equation~#link("../Cameras_and_Film/Film_and_Imaging.html#eq:pixel-contribution-weighted-sum")[5.13];, is self-normalizing.
][
  `Filter` 实现还必须提供一个评估其滤波函数的方法。 此函数可能会在滤波器半径之外的点上调用；在这种情况下，检测这种情况并返回值 0 是实现的责任。 `Evaluate()` 返回的滤波器值不需要积分为 1，因为用于计算像素值的估计器，方程#link("../Cameras_and_Film/Film_and_Imaging.html#eq:pixel-contribution-weighted-sum")[5.13];，是自归一化的。
]

```cpp
Float Evaluate(Point2f p) const;
```


#parec[
  Filters also must be able to return their integral. Most are able to compute this value in closed form. Thus, if calling code requires a normalized filter function, it is easy enough to find it by dividing values returned by `Evaluate()` by the integral.
][
  滤波器还必须能够返回其积分。 大多数可以以封闭形式计算此值。 因此，如果调用代码需要归一化的滤波函数，只需将 `Evaluate()` 返回的值除以积分即可轻松找到它。
]

```cpp
Float Integral() const;
```


#parec[
  Filters must also provide an importance sampling method, `Sample`, which takes a random sample `u` in $ \[0, 1\)^2$.
][
  滤波器还必须提供一个重要性采样方法，`Sample`，它接受一个随机样本 `u` 在 $ \[0, 1\)^2$ 中。
]

```cpp
FilterSample Sample(Point2f u) const;
```

#parec[
  The returned `FilterSample` structure stores both the sampled position `p` and a weight, which is the ratio of the value of the filter function at `p` to the value of the PDF used for sampling there. Because some filters are able to exactly sample from their distribution, returning this ratio directly allows them to save the trouble of evaluating those two values and instead to always return a weight of~1.
][
  返回的 `FilterSample` 结构存储了采样位置 `p` 和一个权重，该权重是滤波函数在 `p` 处的值与用于在该处采样的 PDF 值的比率。 因为某些滤波器能够精确地从其分布中采样，直接返回这个比率允许它们节省评估这两个值的麻烦，并且总是返回权重 1。
]

```cpp
struct FilterSample {
    Point2f p;
    Float weight;
};
```


#parec[
  Given the specification of this interface, we can now implement the `GetCameraSample()` function that most integrators use to compute the `CameraSample`s that they pass to the #link("../Cameras_and_Film/Camera_Interface.html#Camera::GenerateRay")[`Camera::GenerateRay()`] methods.
][
  给定此接口的规范，我们现在可以实现大多数积分器用来计算传递给 #link("../Cameras_and_Film/Camera_Interface.html#Camera::GenerateRay")[`Camera::GenerateRay()`] 方法的 `CameraSample` 的 `GetCameraSample()` 函数。
]

```cpp
template <typename S>
CameraSample GetCameraSample(S sampler, Point2i pPixel, Filter filter) {
    FilterSample fs = filter.Sample(sampler.GetPixel2D());
    CameraSample cs;
    <<Initialize CameraSample member variables>>       cs.pFilm = pPixel + fs.p + Vector2f(0.5f, 0.5f);
       cs.time = sampler.Get1D();
       cs.pLens = sampler.Get2D();
       cs.filterWeight = fs.weight;
    return cs;
}
```


#parec[
  One subtlety in the definition of this function is that it is templated based on the type of the sampler passed to it. If a value of type #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] is passed to this method, then it proceeds using `pbrt`'s usual dynamic dispatch mechanism to call the corresponding methods of the #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] implementation. However, if a concrete sampler type (e.g., `HaltonSampler`) is passed to it, then the corresponding methods can be called directly (and are generally expanded inline in the function). This capability is used to improve performance in `pbrt`'s GPU rendering path; see Section~#link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#sec:gpu-camera-rays")[15.3.3];.
][
  此函数定义中的一个细微之处在于它是基于传递给它的采样器类型进行模板化的。 如果将类型为 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 的值传递给此方法，则它将使用 `pbrt` 的常规动态调度机制来调用 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 实现的相应方法。 然而，如果传递给它的是一个具体的采样器类型（例如，`HaltonSampler`），则可以直接调用相应的方法（并且通常在函数中内联展开）。 这种模板化能力用于提高 `pbrt` 的 GPU 渲染路径中的性能；参见第#link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#sec:gpu-camera-rays")[15.3.3];节。
]

#parec[
  After the filter's `Sample()` method has returned a `FilterSample`, the image sample position can be found by adding the filter's sampled offset to the pixel coordinate before a shift of $0.5$ in each dimension accounts for the mapping from discrete to continuous pixel coordinates (recall @understanding-pixels). The filter's weight is passed along in the `CameraSample` so that it is available to the #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] when its `AddSample()` method is called.
][
  在滤波器的 `Sample()` 方法返回 `FilterSample` 之后，可以通过在每个维度上将滤波器的采样偏移量添加到像素坐标之前找到图像样本位置，以补偿从离散到连续像素坐标的映射（回想@understanding-pixels）。 滤波器的权重在 `CameraSample` 中传递，以便在调用 #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] 的 `AddSample()` 方法时可用。
]

```cpp
cs.pFilm = pPixel + fs.p + Vector2f(0.5f, 0.5f);
cs.time = sampler.Get1D();
cs.pLens = sampler.Get2D();
cs.filterWeight = fs.weight;
```



=== FilterSampler
<filtersampler>
#parec[
  Not all `Filter`s are able to easily sample from the distributions of their filter functions. Therefore, `pbrt` provides a `FilterSampler` class that wraps up the details of sampling based on a tabularized representation of the filter.
][
  并不是所有的 `Filter` 都能轻松地从其滤波函数的分布中采样。因此，`pbrt` 提供了一个 `FilterSampler` 类，用于封装基于滤波器的表格化表示进行采样的细节。
]

```cpp
class FilterSampler {
  public:
    <<FilterSampler Public Methods>>       FilterSampler(Filter filter, Allocator alloc = {});
       std::string ToString() const;
       FilterSample Sample(Point2f u) const {
           Float pdf;
           Point2i pi;
           Point2f p = distrib.Sample(u, &pdf, &pi);
           return FilterSample{p, f[pi] / pdf};
       }
  private:
    <<FilterSampler Private Members>>       Bounds2f domain;
       Array2D<Float> f;
       PiecewiseConstant2D distrib;
};
```
#parec[
  Only the `Filter` and an allocator are provided to the constructor. We have not found it particularly useful to allow the caller to specify the rate at which the filter function is sampled to construct the table used for sampling, so instead hardcode a sampling rate of 32 times per unit filter extent in each dimension.
][
  构造函数只提供了 `Filter` 和一个分配器。我们发现允许调用者指定滤波函数采样的频率来构建用于采样的表格并没有特别的用处，因此硬编码了每单位滤波器范围在每个维度上采样32次的采样率。
]

```cpp
FilterSampler::FilterSampler(Filter filter, Allocator alloc)
    : domain(Point2f(-filter.Radius()), Point2f(filter.Radius())),
      f(int(32 * filter.Radius().x), int(32 * filter.Radius().y), alloc),
      distrib(alloc) {
    <<Tabularize unnormalized filter function in f>>       for (int y = 0; y < f.YSize(); ++y)
           for (int x = 0; x < f.XSize(); ++x) {
               Point2f p = domain.Lerp(Point2f((x + 0.5f) / f.XSize(),
                                               (y + 0.5f) / f.YSize()));
               f(x, y) = filter.Evaluate(p);
           }
    <<Compute sampling distribution for filter>>       distrib = PiecewiseConstant2D(f, domain, alloc);
}
```
#parec[
  `domain` gives the bounds of the filter and `f` stores tabularized filter function values.
][
  `domain` 给出了滤波器的边界，`f` 存储了表格化的滤波函数值。
]

```cpp
Bounds2f domain;
Array2D<Float> f;
```
#parec[
  All the filters currently implemented in `pbrt` are symmetric about the origin, which means that they could be tabularized over a single $x y$ quadrant. Further, they are all separable into the product of two 1D functions. Either of these properties could be exploited to reduce the amount of storage required for the tables used for sampling. However, to allow full flexibility with the definition of additional filter functions, the #link("<FilterSampler>")[`FilterSampler`] simply evaluates the filter at equally spaced positions over its entire domain to initialize the `f` array.
][
  `pbrt` 中当前实现的所有滤波器都关于原点对称，这意味着它们可以在单个 $x y$ 象限上表格化。此外，它们都可以分解为两个一维函数的乘积。可以利用这些属性中的任何一个来减少用于采样的表格所需的存储量。然而，为了在定义额外的滤波函数时提供完全的灵活性，#link("<FilterSampler>")[`FilterSampler`] 只是简单地在其整个域上均匀分布地评估滤波器以初始化 `f` 数组。
]

```cpp
// <tabularize-unnormalized-filter-function-in-f>
for (int y = 0; y < f.YSize(); ++y)
    for (int x = 0; x < f.XSize(); ++x) {
        Point2f p = domain.Lerp(Point2f((x + 0.5f) / f.XSize(),
                                        (y + 0.5f) / f.YSize()));
        f(x, y) = filter.Evaluate(p);
    }
```
#parec[
  Given a tabularized function, it is easy to initialize the sampling distribution.
][
  给定一个表格化的函数，很容易初始化采样分布。
]

```cpp
distrib = PiecewiseConstant2D(f, domain, alloc);
```

```cpp
PiecewiseConstant2D distrib;
```

#parec[
  There are two important details in the implementation of its `Sample()` method. First, the implementation does not use #link("<Filter::Evaluate>")[`Filter::Evaluate`] to evaluate the filter function but instead uses the tabularized version of it in `f`. By using the piecewise constant approximation of the filter function, it ensures that the returned weight $f(p')\/p(upright(p)')$ for a sampled point $upright(p) prime$ is always $plus.minus c$ for a constant $c$. If it did not do this, there would be variation in the returned weight for non-constant filter functions, due to the sampling distribution not being exactly proportional to the filter function—see @fig:filter-sampler-zero-crossing-challenge which illustrates the issue.
][
  在实现其 `Sample()` 方法时有两个重要的细节。首先，实现并没有使用 #link("<Filter::Evaluate>")[`Filter::Evaluate`] 来评估滤波函数，而是使用了 `f` 中的表格化版本。通过使用滤波函数的分段常数近似，它确保了对于采样点 $upright(p) prime$ 返回的权重 $f(p')\/p(upright(p)')$ 始终是 $plus.minus c$。如果不这样做，对于非常数滤波函数，由于采样分布不完全与滤波函数成比例，返回的权重会有所变化——参见@fig:filter-sampler-zero-crossing-challenge，说明了这个问题。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f50.svg"),
  caption: [
    #ez_caption[
      Filter function $f (x)$ and a piecewise-constant
      sampling distribution $p (x)$ found by evaluating it at the center
      of each cell, as is done by the
      #link("<FilterSampler>")[`FilterSampler`];. If filter positions are
      found by sampling from $p (x)$ and contributions are weighted using
      the ratio $f(x) \/ p(x)$, then different samples may have very
      different contributions. For example, the two points shown have a
      $10$ times difference in their $f(x) \/ p(x)$ values. This
      variation in filter weights can lead to variance in images and
      therefore the #link("<FilterSampler>")[FilterSampler] uses the same
      piecewise-constant approximation of $f (x)$ for evaluation as is
      used for sampling.
    ][
      滤波函数 $f (x)$
      和通过在每个单元格中心评估得到的分段常数采样分布 $p (x)$，如
      #link("<FilterSampler>")[`FilterSampler`] 所做的那样。如果通过从 $p (x)$
      采样找到滤波器位置，并使用比率 $f(x) \/ p(x)$
      加权贡献，则不同的样本可能有非常不同的贡献。例如，所示的两个点在其
      $f(x) \/ p(x)$
      值上有10倍的差异。这种滤波器权重的变化可能导致图像中的方差，因此
      #link("<FilterSampler>")[`FilterSampler`]
      使用与采样相同的分段常数近似来评估 $f (x)$。
    ]
  ],
)<filter-sampler-zero-crossing-challenge>


#parec[
  A second important detail is that the integer coordinates of the sample returned by #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D::Sample")[PiecewiseConstant2D::Sample()] are used to index into `f` for filter function evaluation. If instead the point `p` was scaled up by the size of the `f` array in each dimension and converted to an integer, the result would occasionally differ from the integer coordinates computed during sampling by #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[PiecewiseConstant2D] due to floating-point round-off error. (Using the notation of Section 6.8.1, the issue is that with floating-point arithmetic, $(a "xx" b) times.circle b eq.not (a\/b)b = a$.) Again, variance would result, as the ratio $f(x) \/ g(x)$ might not be $plus.minus c$.
][
  第二个重要的细节是由 #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D::Sample")[PiecewiseConstant2D::Sample()] 返回的样本的整数坐标用于索引 `f` 以进行滤波函数评估。如果相反，点 `p` 被按 `f` 数组在每个维度上的大小放大并转换为整数，结果偶尔会因浮点舍入误差而与 #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[PiecewiseConstant2D] 采样期间计算的整数坐标不同。（使用第6.8.1节的符号，问题在于浮点运算中， $(a "xx" b) times.circle b eq.not (a\/b)b = a$。）同样，方差会出现，因为比率 $f(x) \/ g(x)$ 可能不是 $plus.minus c$。
]

```cpp
FilterSample Sample(Point2f u) const {
    Float pdf;
    Point2i pi;
    Point2f p = distrib.Sample(u, &pdf, &pi);
    return FilterSample{p, f[pi] / pdf};
}
```


=== Box Filter
<box-filter>
#parec[
  One of the most commonly used filters in graphics is the #emph[box
filter] (and, in fact, when filtering and reconstruction are not addressed explicitly, the box filter is the #emph[de facto] result). The box filter equally weights all samples within a square region of the image. Although computationally efficient, it is just about the worst filter possible. Recall from the discussion in @ideal-sampling-and-reconstruction Section 8.1.2 that the box filter allows high-frequency sample data to leak into the reconstructed values. This causes postaliasing—even if the original sample values were at a high enough frequency to avoid aliasing, errors are introduced by poor filtering.
][
  图形中最常用的滤波器之一是#emph[盒滤波器];（事实上，当滤波和重建没有明确处理时，盒滤波器是#emph[事实上的];结果）。盒滤波器对图像中一个正方形区域内的所有样本给予相同的权重。虽然计算效率高，但它几乎是最差的滤波器。回想@ideal-sampling-and-reconstruction 中的讨论，盒滤波器允许高频样本数据泄漏到重建值中。这会导致后别名化——即使原始样本值的频率足够高以避免别名化，错误也会因糟糕的滤波而引入。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f51.svg"),
  caption: [
    #ez_caption[
      Graphs of the (a) box filter and (b) triangle filter.
      Although neither of these is a particularly good filter, they are
      both computationally efficient, easy to implement, and good
      baselines for evaluating other filters.
    ][
      （a）盒滤波器和（b）三角滤波器的图形。虽然这些都不是特别好的滤波器，但它们都具有计算效率高、易于实现的优点，是评估其他滤波器的良好基准。
    ]
  ],
)<box-tri-filter>

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f52.svg"),
  caption: [
    #ez_caption[
      The box filter reconstructing (a) a step function and
      (b) a sinusoidal function with increasing frequency as $x$
      increases. This filter does well with the step function, as
      expected, but does an extremely poor job with the sinusoidal
      function.
    ][
      盒滤波器重建（a）阶跃函数和（b）随着 $x$
      增加而频率增加的正弦函数。该滤波器在阶跃函数上表现良好，如预期的那样，但在正弦函数上表现极差。
    ]
  ],
)<box-recon-examples>


#parec[
  @fig:box-tri-filter(a) shows a graph of the box filter, and @fig:box-recon-examples shows the result of using the box filter to reconstruct two 1D functions.

  For the step function we used previously to illustrate the Gibbs phenomenon, the box does reasonably well. However, the results are much worse for a sinusoidal function that has increasing frequency along the $x$ axis. Not only does the box filter do a poor job of reconstructing the function when the frequency is low, giving a discontinuous result even though the original function was smooth, but it also does an extremely poor job of reconstruction as the function's frequency approaches and passes the Nyquist limit.
][
  @fig:box-tri-filter(a)显示了盒滤波器的图形，@fig:box-recon-examples 显示了使用盒滤波器重建两个一维函数的结果。

  对于我们先前用来说明吉布斯现象的阶跃函数，盒滤波器表现得相当好。然而，对于沿 $x$ 轴频率增加的正弦函数，结果要糟糕得多。盒滤波器不仅在频率较低时重建函数表现不佳，即使原始函数是平滑的也会给出不连续的结果，而且在函数的频率接近并超过奈奎斯特极限时，重建效果极差。
]

```cpp
class BoxFilter {
  public:
    <<BoxFilter Public Methods>>       BoxFilter(Vector2f radius = Vector2f(0.5, 0.5)) : radius(radius) {}

       static BoxFilter *Create(const ParameterDictionary &parameters, const FileLoc *loc,
                                Allocator alloc);

       PBRT_CPU_GPU
       Vector2f Radius() const { return radius; }

       std::string ToString() const;
       Float Evaluate(Point2f p) const {
           return (std::abs(p.x) <= radius.x && std::abs(p.y) <= radius.y) ? 1 : 0;
       }
       FilterSample Sample(Point2f u) const {
           Point2f p(Lerp(u[0], -radius.x, radius.x),
                     Lerp(u[1], -radius.y, radius.y));
           return {p, Float(1)};
       }
       Float Integral() const { return 2 * radius.x * 2 * radius.y; }
  private:
    Vector2f radius;
};
```

#parec[
  For this filter and all the following ones, we will not include the rudimentary constructors and `Radius()` method implementations.
][
  对于此滤波器及所有后续滤波器，我们将不包括基本的构造函数和 `Radius()` 方法实现。
]

#parec[
  Evaluating the box filter requires checking that the given point is inside the box.
][
  评估盒滤波器需要检查给定点是否在盒子内。
]

```cpp
Float Evaluate(Point2f p) const {
    return (std::abs(p.x) <= radius.x && std::abs(p.y) <= radius.y) ? 1 : 0;
}
```
#parec[
  Sampling is also easy: the random sample `u` is used to linearly interpolate within the filter's extent. Since sampling is exact and the filter function is positive, the weight is always 1.
][
  采样也很简单：随机样本 `u` 用于在滤波器的范围内线性插值。由于采样是精确的且滤波函数为正，权重始终为1。
]

```cpp
FilterSample Sample(Point2f u) const {
    Point2f p(Lerp(u[0], -radius.x, radius.x),
              Lerp(u[1], -radius.y, radius.y));
    return {p, Float(1)};
}
```
#parec[
  Finally, the integral is equal to the filter's area.
][
  最后，积分等于滤波器的面积。
]

```cpp
<<BoxFilter Public Methods>>+=
Float Integral() const { return 2 * radius.x * 2 * radius.y; }
```

=== Triangle Filter
<triangle-filter>
#parec[
  The triangle filter gives slightly better results than the box: the weight falls off linearly from the filter center over the square extent of the filter. See @fig:box-tri-filter(b) for a graph of the triangle filter.
][
  三角滤波器比盒形滤波器效果稍好：权重从滤波器中心线性下降，直到滤波器的方形范围边界。参见@fig:box-tri-filter(b) 以查看三角滤波器的图表。
]

```cpp
class TriangleFilter {
  public:
    <<TriangleFilter Public Methods>>       TriangleFilter(Vector2f radius) : radius(radius) {}

       static TriangleFilter *Create(const ParameterDictionary &parameters,
                                     const FileLoc *loc, Allocator alloc);

       PBRT_CPU_GPU
       Vector2f Radius() const { return radius; }

       std::string ToString() const;
       Float Evaluate(Point2f p) const {
           return std::max<Float>(0, radius.x - std::abs(p.x)) *
                  std::max<Float>(0, radius.y - std::abs(p.y));
       }
       FilterSample Sample(Point2f u) const {
           return {Point2f(SampleTent(u[0], radius.x),
                           SampleTent(u[1], radius.y)), Float(1)};
       }
       Float Integral() const { return Sqr(radius.x) * Sqr(radius.y); }
  private:
    Vector2f radius;
};
```

#parec[
  Evaluating the triangle filter is simple: it is the product of two linear functions that go to 0 after the width of the filter in both the $x$ and $y$ directions. Here we have defined the filter to have a slope of $plus.minus 1$, though the filter could alternatively have been defined to have a value of 1 at the origin and a slope that depends on the radius.
][
  评估三角滤波器很简单：它是两个线性函数的乘积，这两个函数在 $x$ 和 $y$ 方向上超过滤波器宽度后变为 0。这里我们定义滤波器的斜率为 $plus.minus 1$，虽然滤波器也可以定义为在原点处值为 1，斜率取决于半径。
]

```cpp
Float Evaluate(Point2f p) const {
    return std::max<Float>(0, radius.x - std::abs(p.x)) *
           std::max<Float>(0, radius.y - std::abs(p.y));
}
```
#parec[
  Because the filter is separable, its PDF is as well, and so each dimension can be sampled independently. The sampling method uses a separate `SampleTent()` utility function that is defined in Section #link("../Sampling_Algorithms/Sampling_1D_Functions.html#sec:sampling-tent-function")[A.4.1];. Once again, the weight returned in the #link("<FilterSample>")[`FilterSample`] is always 1 because the filter is positive and sampling is exact.
][
  因为滤波器是可分离的，所以它的概率密度函数也是可分离的，因此每个维度可以独立采样。采样方法使用一个单独的 `SampleTent()` 实用函数，该函数在 #link("../Sampling_Algorithms/Sampling_1D_Functions.html#sec:sampling-tent-function")[A.4.1] 节中定义。需要再次说明的是，返回的 #link("<FilterSample>")[`FilterSample`] 中的权重始终为 1，因为滤波器是正的且采样是精确的。
]

```cpp
FilterSample Sample(Point2f u) const {
    return {Point2f(SampleTent(u[0], radius.x),
                    SampleTent(u[1], radius.y)), Float(1)};
}
```
#parec[
  Finally, the triangle filter is easily integrated.
][
  最后，三角滤波器的积分计算非常简单。
]

```cpp
Float Integral() const { return Sqr(radius.x) * Sqr(radius.y); }
```

=== Gaussian Filter
<gaussian-filter>
#parec[
  Unlike the box and triangle filters, the Gaussian filter gives a reasonably good result in practice. This filter applies a Gaussian bump that is centered at the pixel and radially symmetric around it. @fig:gaussian-mitchell-filter compares plots of the Gaussian filter and the Mitchell filter (described in @mitchell-filter ). The Gaussian does tend to cause slight blurring of the final image compared to some of the other filters, but this blurring can help mask any remaining aliasing. This filter is the default one used in `pbrt`.
][
  与盒形和三角滤波器不同，高斯滤波器在实践中给出了相当好的结果。该滤波器应用一个以像素为中心并围绕其径向对称的高斯曲线。@fig:gaussian-mitchell-filter 比较了高斯滤波器和 Mitchell 滤波器（在 @mitchell-filter 中描述）的图表。与其他一些滤波器相比，高斯滤波器确实可能导致最终图像略显模糊，但这种模糊可以帮助掩盖任何剩余的混叠。此滤波器是 `pbrt` 中使用的默认滤波器。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f53.svg"),
  caption: [
    #ez_caption[
      Graphs of (a) the Gaussian filter and (b) the Mitchell filter with
      $B = 1 / 3$ and $C = 1 / 3$, each with a width of 2. The Gaussian gives
      images that tend to be a bit blurry, while the negative lobes of the
      Mitchell filter help to accentuate and sharpen edges in final images.
    ][
      高斯滤波器和 (b) Mitchell 滤波器的图表，其中 $B = 1 / 3$ 和
      $C = 1 / 3$，每个宽度为 2。高斯滤波器生成的图像往往有些模糊，而
      Mitchell 滤波器的负峰有助于突出和锐化最终图像中的边缘。
    ]
  ],
)<gaussian-mitchell-filter>



```cpp
class GaussianFilter {
  public:
    <<GaussianFilter Public Methods>>       GaussianFilter(Vector2f radius, Float sigma = 0.5f, Allocator alloc = {})
           : radius(radius), sigma(sigma), expX(Gaussian(radius.x, 0, sigma)),
             expY(Gaussian(radius.y, 0, sigma)), sampler(this, alloc) {}
       static GaussianFilter *Create(const ParameterDictionary &parameters,
                                     const FileLoc *loc, Allocator alloc);

       PBRT_CPU_GPU
       Vector2f Radius() const { return radius; }

       std::string ToString() const;
       Float Evaluate(Point2f p) const {
           return (std::max<Float>(0, Gaussian(p.x, 0, sigma) - expX) *
                   std::max<Float>(0, Gaussian(p.y, 0, sigma) - expY));
       }
       Float Integral() const {
           return ((GaussianIntegral(-radius.x, radius.x, 0, sigma) -
                    2 * radius.x * expX) *
                   (GaussianIntegral(-radius.y, radius.y, 0, sigma) -
                    2 * radius.y * expY));
       }
       FilterSample Sample(Point2f u) const { return sampler.Sample(u); }
  private:
    <<GaussianFilter Private Members>>       Vector2f radius;
       Float sigma, expX, expY;
       FilterSampler sampler;
};
```

#parec[
  The #emph[Gaussian function] is parameterized by the position of the peak $mu$ and the standard deviation $sigma$ :
][
  #emph[高斯函数];由峰值位置 $mu$ 和标准偏差 $sigma$ 参数化：
]

$ g (x , mu , sigma) = 1 / sqrt(2 pi sigma^2) e^(- frac((x - mu)^2, 2 sigma^2)) . $
#parec[
  Larger values of $sigma$ cause a slower falloff, which leads to a blurrier image when the Gaussian is used as a filter.
][
  较大的 $sigma$ 值导致较慢的衰减，这在高斯用作滤波器时会导致图像更加模糊。
]

#parec[
  The `GaussianFilter` is centered at the origin, so $mu = 0$. Further, the filter function subtracts the value of the Gaussian at the end of its extent $r$ from the filter value in order to make the filter go to 0 at its limit:
][
  `GaussianFilter` 以原点为中心，因此 $mu = 0$。此外，滤波器函数通过从其范围 $r$ 末端的高斯值中减去滤波器值，使滤波器在其极限处变为 0：
]

$
  f ( x ) = cases(delim: "{", g (x , 0 , sigma) - g (r , 0 , sigma) & upright("if ") lr(|x|) < r, 0 & upright("otherwise") .)
$<gaussian-filter-function>


#parec[
  For efficiency, the constructor precomputes the constant term for $g (r , 0 , sigma)$ in each direction.
][
  为了提高效率，构造函数在每个方向上预先计算了 $g (r , 0 , sigma)$ 的常数项。
]

```cpp
<<GaussianFilter Public Methods>>=
GaussianFilter(Vector2f radius, Float sigma = 0.5f, Allocator alloc = {})
    : radius(radius), sigma(sigma), expX(Gaussian(radius.x, 0, sigma)),
      expY(Gaussian(radius.y, 0, sigma)), sampler(this, alloc) {}
```

```cpp
<<GaussianFilter Private Members>>=
Vector2f radius;
Float sigma, expX, expY;
FilterSampler sampler;
```

#parec[
  The product of the two 1D Gaussian functions gives the overall filter value according to @eqt:gaussian-filter-function. The calls to `std::max()` ensure that the value of 0 is returned for points outside of the filter's extent.
][
  两个一维高斯函数的乘积根据@eqt:gaussian-filter-function 给出了整体滤波器的值。调用 `std::max()` 确保对于滤波器范围之外的点，返回值为 0。
]


```
<<GaussianFilter Public Methods>>+=
Float Evaluate(Point2f p) const {
    return (std::max<Float>(0, Gaussian(p.x, 0, sigma) - expX) *
            std::max<Float>(0, Gaussian(p.y, 0, sigma) - expY));
}
```

#parec[
  The integral of the Gaussian is
][
  高斯函数的不定积分为
]
$ integral g (x , mu , sigma) thin d x = 1 / 2 upright("erf") (frac(mu - x, sqrt(2) sigma)) , $

#parec[
  where $upright("erf")$ is the error function. #link("../Utilities/Mathematical_Infrastructure.html#GaussianIntegral")[GaussianIntegral()] evaluates its value over a given range. The filter function's integral can be computed by evaluating the Gaussian's integral over the filter's range and subtracting the integral of the offset that takes the filter to zero at the end of its extent.
][
  其中 $upright("erf")$ 是误差函数。#link("../Utilities/Mathematical_Infrastructure.html#GaussianIntegral")[GaussianIntegral()] 评估其在给定范围内的值。滤波器函数的积分可以通过在滤波器范围内评估高斯函数的积分并减去将滤波器在其范围末端归零的偏移积分来计算。
]

```
Float Integral() const {
    return ((GaussianIntegral(-radius.x, radius.x, 0, sigma) -
             2 * radius.x * expX) *
            (GaussianIntegral(-radius.y, radius.y, 0, sigma) -
             2 * radius.y * expY));
}
```

#parec[
  It is possible to sample from the Gaussian function using a polynomial approximation to the inverse error function, though that is not sufficient in this case, given the presence of the second term of the filter function in @eqt:gaussian-filter-function. `pbrt`'s `GaussianFilter` implementation therefore uses a #link("<FilterSampler>")[FilterSampler] for sampling.
][
  可以使用逆误差函数的多项式近似从高斯函数中采样，但在这种情况下，由于@eqt:gaussian-filter-function 中滤波器函数的第二项的存在，这还不够。因此，`pbrt` 的 `GaussianFilter` 实现使用 #link("<FilterSampler>")[FilterSampler] 进行采样。
]

```cpp
FilterSample Sample(Point2f u) const { return sampler.Sample(u); }
```


=== Mitchell Filter
<mitchell-filter>

#parec[
  Filter design is notoriously difficult, mixing mathematical analysis and perceptual experiments. Mitchell and Netravali (1988) developed a family of parameterized filter functions in order to be able to explore this space in a systematic manner. After analyzing test subjects' subjective responses to images filtered with a variety of parameter values, they developed a filter that tends to do a good job of trading off between #emph[ringing] (phantom edges next to actual edges in the image) and #emph[blurring] (excessively blurred results)—two common artifacts from poor reconstruction filters.
][
  滤波器设计是出了名的困难，结合了数学分析和感知实验。Mitchell 和 Netravali 在 1988 年开发了一系列参数化滤波器函数，以便能够系统地探索这个空间。 在分析了测试对象对使用各种参数值过滤的图像的主观反应后，他们开发了一种滤波器，通常在 #emph[振铃];（图像中实际边缘旁边的幻影边缘）和 #emph[模糊];（过度模糊的结果）之间进行良好的权衡——这是重建滤波器不佳的两个常见伪影。
]

#parec[
  Note from the graph in Figure 8.53(b) that this filter function takes on negative values out by its edges; it has #emph[negative lobes];. In practice these negative regions improve the sharpness of edges, giving crisper images (reduced blurring). If they become too large, however, ringing tends to start to enter the image. Furthermore, because the final pixel values can become negative, they will eventually need to be clamped to a legal output range.
][
  请注意图 8.53(b) 中的图表，这个滤波器函数在其边缘取负值；它有 #emph[负瓣];。实际上，这些负区域提高了边缘的清晰度，使图像更清晰（减少模糊）。 然而，如果它们变得太大，振铃往往会开始进入图像。此外，由于最终的像素值可能变为负值，因此最终需要将其限制在合法的输出范围内。
]

#parec[
  @fig:mitchell-recon-examples shows this filter reconstructing the two test functions. It does extremely well with both of them: there is minimal ringing with the step function, and it does a good job with the sinusoidal function, up until the point where the sampling rate is not sufficient to capture the function's detail.
][
  @fig:mitchell-recon-examples 显示了这个滤波器重建两个测试函数。它在两者上都表现得非常好：在阶跃函数上引入的振铃最小，并且在正弦函数上表现良好，直到采样率不足以捕捉函数的细节。
]


#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f54.svg"),
  caption: [
    #ez_caption[
      *The Mitchell-Netravali Filter Used to Reconstruct the Example Functions.* It does a good job with both of these functions, (a) introducing minimal ringing with the step function and (b) accurately representing the sinusoid until aliasing from undersampling starts to dominate.
    ][
      *用于重建示例函数的Mitchell-Netravali滤波器。* 它在处理这两个函数时都表现出色，(a) 对阶跃函数引入的振铃最小，(b) 在欠采样导致的混叠开始占主导地位之前，准确地表示正弦波。
    ]
  ],
)<mitchell-recon-examples>
```
class MitchellFilter {
  public:
    <<MitchellFilter Public Methods>>       MitchellFilter(Vector2f radius, Float b = 1.f/3.f, Float c = 1.f/3.f,
                      Allocator alloc = {})
           : radius(radius), b(b), c(c), sampler(this, alloc) {}
       static MitchellFilter *Create(const ParameterDictionary &parameters,
                                     const FileLoc *loc, Allocator alloc);

       PBRT_CPU_GPU
       Vector2f Radius() const { return radius; }

       std::string ToString() const;
       Float Evaluate(Point2f p) const {
           return Mitchell1D(2 * p.x / radius.x) * Mitchell1D(2 * p.y / radius.y);
       }
       FilterSample Sample(Point2f u) const { return sampler.Sample(u); }
       Float Integral() const { return radius.x * radius.y / 4; }
  private:
    <<MitchellFilter Private Methods>>       Float Mitchell1D(Float x) const {
           x = std::abs(x);
           if (x <= 1)
               return ((12 - 9 * b - 6 * c) * x * x * x + (-18 + 12 * b + 6 * c) * x * x +
                       (6 - 2 * b)) *
                      (1.f / 6.f);
           else if (x <= 2)
               return ((-b - 6 * c) * x * x * x + (6 * b + 30 * c) * x * x +
                       (-12 * b - 48 * c) * x + (8 * b + 24 * c)) *
                      (1.f / 6.f);
           else
               return 0;
       }
    <<MitchellFilter Private Members>>       Vector2f radius;
       Float b, c;
       FilterSampler sampler;
};
```


#parec[
  The Mitchell filter has two parameters called $b$ and $c$. Although any values can be used for these parameters, Mitchell and Netravali recommend that they lie along the line $b + 2 c = 1$.
][
  Mitchell 滤波器有两个参数，分别为 $b$ 和 $c$。虽然这些参数可以使用任何值，但 Mitchell 和 Netravali 建议它们沿着 $b + 2 c = 1$ 的线。
]

```
Vector2f radius;
Float b, c;
// 滤波采样器
FilterSampler sampler;
```

#parec[
  The Mitchell-Netravali filter is the product of 1D filter functions in the $x$ and $y$ directions and is therefore separable.
][
  Mitchell-Netravali 滤波器是 $x$ 和 $y$ 方向上一维滤波器函数的乘积，因此是可分离的。
]

```cpp
Float Evaluate(Point2f p) const {
    return Mitchell1D(2 * p.x / radius.x) * Mitchell1D(2 * p.y / radius.y);
}
```

#parec[
  The 1D function used in the Mitchell filter is an even function defined over the range $[- 2 , 2]$. This function is made by joining a cubic polynomial defined over $[0 , 1]$ with another cubic polynomial defined over $[1 , 2]$. This combined polynomial is also reflected around the $x = 0$ plane to give the complete function. These polynomials are controlled by the $b$ and $c$ parameters and are chosen carefully to guarantee $C^0$ and $C^1$ continuity at $x = 0$, $x = 1$, and $x = 2$. The polynomials are.
][
  Mitchell 滤波器中使用的一维函数是一个定义在 $[- 2 , 2]$ 范围内的偶函数。这个函数是通过将定义在 $[0 , 1]$ 上的三次多项式与定义在 $[1 , 2]$ 上的另一个三次多项式连接起来构成的。 这个组合多项式还围绕 $x = 0$ 平面反射以给出完整的函数。这些多项式由参数 $b$ 和 $c$ 控制，并经过精心选择以保证在 $x = 0$ 、 $x = 1$ 和 $x = 2$ 处的 $C^0$ 和 $C^1$ 连续性。多项式为。
]


$
  f (x) &\
  &= 1 / 6 cases((12 - 9 b - 6 c) lr(|x|)^3 + (- 18 + 12 b + 6 c) lr(|x|)^2 + (6 - 2 b)& upright("if ") lr(|x|) < 1,
(- b - 6 c) lr(|x|)^3 + (6 b + 30 c) lr(|x|)^2 + (- 12 b - 48 c)+ (8 b + 24 c) & 1 lt.eq lr(|x|) < 2\
 0 & upright("otherwise.") )
$


#parec[
  `Mitchell1D()` evaluates this function. Its implementation is straightforward and is not included here.
][
  `Mitchell1D()` 计算此函数。其实现很简单，此处不包括。
]

#parec[
  As a cubic polynomial, sampling this filter function directly would require inverting a quartic. Therefore, the `MitchellFilter` uses the #link("<FilterSampler>")[FilterSampler] for sampling.
][
  作为一个三次多项式，直接采样此滤波器函数需要求解一个四次方程。因此，`MitchellFilter` 使用 #link("<FilterSampler>")[FilterSampler] 进行采样。
]

```cpp
FilterSample Sample(Point2f u) const { return sampler.Sample(u); }
```
#parec[
  However, the function is easily integrated. The result is independent of the values of $b$ and $c$.
][
  然而，该函数很容易进行积分。结果不受 $b$ 和 $c$ 的值影响。
]

```cpp
Float Integral() const { return radius.x * radius.y / 4; }
```


=== Windowed Sinc Filter

#parec[
  Finally, the #link("<LanczosSincFilter>")[LanczosSincFilter] class implements a filter based on the sinc function. In practice, the sinc filter is often multiplied by another function that goes to 0 after some distance. This gives a filter function with finite extent. An additional parameter $tau$ controls how many cycles the sinc function passes through before it is clamped to a value of 0. @fig:sinc-and-window-graphs shows a graph of three cycles of the sinc function, along with a graph of the windowing function we use, which was developed by Lanczos. The Lanczos window is just the central lobe of the sinc function, scaled to cover the $tau$ cycles:
][
  最后，#link("<LanczosSincFilter>")[LanczosSincFilter] 类实现了一个基于 sinc 函数的滤波器。在实践中，sinc 滤波器通常与另一个在某个距离后趋于 0 的函数相乘。 这产生了一个具有有限范围的影响的滤波器函数。一个额外的参数 $tau$ 控制 sinc 函数在被限制为 0 之前通过的周期数。 @fig:sinc-and-window-graphs 显示了 sinc 函数的三个周期的图形，以及我们使用的窗口函数的图形，该函数由 Lanczos 开发。 Lanczos 窗口只是 sinc 函数的中心波峰，缩放以覆盖 $tau$ 周期：
]

$ w(x) = op("sinc")(frac(x, tau)) = frac(sin( pi x \/ tau), pi x \/ tau) . $

#parec[
  @fig:sinc-and-window-graphs also shows the filter that we will implement here, which is the product of the sinc function and the windowing function.It is evaluated by the `WindowedSinc()` utility function.
][
  @fig:sinc-and-window-graphs 还显示了我们将在此实现的滤波器，这是 sinc 函数和窗口函数的乘积。 它由 `WindowedSinc()` 实用函数评估。
]

```cpp
<<Math Inline Functions>>+=
Float WindowedSinc(Float x, Float radius, Float tau) {
    if (std::abs(x) > radius)
        return 0;
    return Sinc(x) * Sinc(x / tau);
}
```

#parec[
  Its implementation uses the `Sinc()` function, which in turn is implemented using the numerically robust `SinXOverX()` function.
][
  其实现使用 `Sinc()` 函数，该函数又使用数值稳健的 `SinXOverX()` 函数实现。
]

```cpp
Float Sinc(Float x) { return SinXOverX(Pi * x); }
```

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f55.svg"),
  caption: [
    #ez_caption[Graphs of the Sinc Filter. (a) The sinc function, truncated after three cycles (blue line) and the Lanczos windowing function (red line). (b) The product of these two functions, as implemented in the LanczosSincFilter.][*Sinc 滤波器的图形。*(a) Sinc 函数，经过三个周期后截断（蓝色线）和 Lanczos 窗函数（红色线）。(b) 这两个函数的乘积，即在 LanczosSincFilter 中的实现。]
  ],
)<sinc-and-window-graphs>

#parec[
  Figure #link("<fig:sinc-recon-examples>")[8.56] shows the windowed sinc's reconstruction results for uniform 1D samples. Thanks to the windowing, the reconstructed step function exhibits far less ringing than the reconstruction using the infinite-extent sinc function (compare to @fig:sinc-gibbs-ringing ). The windowed sinc filter also does extremely well at reconstructing the sinusoidal function until prealiasing begins.
][
  图 #link("<fig:sinc-recon-examples>")[8.56] 显示了窗口化 sinc 对均匀 1D 样本的重建结果。 由于窗口化，重建的阶跃函数比使用无限范围 sinc 函数的重建表现出更少的振铃现象（与 @fig:sinc-gibbs-ringing 比较）。 窗口化 sinc 滤波器在重建正弦函数时也表现非常好，直到预混叠现象开始。
]


#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f56.svg"),
  caption: [
    #ez_caption[Results of Using the Windowed Sinc Filter to Reconstruct the Example Functions. Here, $tau = 3$. (a) Like the infinite sinc, it suffers from ringing with the step function, although there is much less ringing in the windowed version. (b) The filter does quite well with the sinusoid, however.][使用加窗的 Sinc 滤波器重建示例函数的结果。这里，τ = 3。
      (a) 与无限长的 sinc 一样，它在阶跃函数上也会出现振铃现象，尽管在加窗的版本中振铃要少得多。
      (b) 然而，该滤波器在处理正弦波时表现相当不错。]
  ],
)

```cpp
<<LanczosSincFilter Definition>>=
class LanczosSincFilter {
  public:
    <<LanczosSincFilter Public Methods>>
  private:
    <<LanczosSincFilter Private Members>>
};


<<LanczosSincFilter Private Members>>=
Vector2f radius;
Float tau;
FilterSampler sampler;
```

#parec[
  The evaluation method is easily implemented in terms of the WindowedSinc() function.
][
  评估方法很容易用 WindowedSinc() 函数来实现。
]

```cpp
<<LanczosSincFilter Public Methods>>=
Float Evaluate(Point2f p) const {
    return WindowedSinc(p.x, radius.x, tau) *
           WindowedSinc(p.y, radius.y, tau);
}
```
#parec[
  There is no convenient closed-form approach for sampling from the windowed sinc function's distribution, so a FilterSampler is used here as well.
][
  由于没有方便的封闭形式方法从加窗的 sinc 函数的分布中进行采样，所以这里也使用了 FilterSampler。
]

```
<<LanczosSincFilter Public Methods>>+=
FilterSample Sample(Point2f u) const { return sampler.Sample(u); }
```

#parec[
  There is no closed-form expression of the filter's integral, so its Integral() method, not included in the text, approximates it using a Riemann sum.
][
  由于滤波器的积分没有封闭形式的表达式，所以它的 Integral() 方法（未在正文中包含）使用黎曼和来近似计算。
]
```
<<LanczosSincFilter Public Methods>>+=
Float Integral() const;
```
