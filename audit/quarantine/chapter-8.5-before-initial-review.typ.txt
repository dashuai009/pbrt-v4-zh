#import "../template.typ": parec, ez_caption

== Stratified Sampler
<stratified-sampler>
#parec[
  The #link("../Sampling_and_Reconstruction/Independent_Sampler.html#IndependentSampler")[#emph[IndependentSampler];];'s weakness is that it makes no effort to ensure that its sample points have good coverage of the sampling domain. All the subsequent #emph[Sampler];s in this chapter are based on various ways of ensuring that. As we saw in @Stratified-Sampling, stratification is one such approach. The #link("<StratifiedSampler>")[#emph[StratifiedSampler];] applies this technique, subdividing the $(0 , 1)^d$ sampling domain into regions and generating a single sample inside each one. Because a sample is taken in each region, it is less likely that important features in the integrand will be missed, since the samples are guaranteed not to all be close together.
][
  #link("../Sampling_and_Reconstruction/Independent_Sampler.html#IndependentSampler")[#emph[独立采样器];];的弱点在于它不努力确保其采样点能良好覆盖采样域。本章中所有后续的#emph[采样器];都基于确保这一点的各种方法。正如我们在@Stratified-Sampling 中看到的，分层是一种方法。#link("<StratifiedSampler>")[#emph[分层采样器];];应用了这种技术，将 $(0 , 1)^d$ 采样域细分为区域，并在每个区域内生成一个样本。因为在每个区域内都取样，因此不太可能遗漏被积函数中的重要特征，因为样本不会都集中在一起。
]

#parec[
  The #link("<StratifiedSampler>")[#emph[StratifiedSampler];] places each sample at a random point inside each stratum by jittering the center point of the stratum by a uniform random amount so that all points inside the stratum are sampled with equal probability. The nonuniformity that results from this jittering helps turn aliasing into noise, as discussed in @spectral-analysis-of-sampling-patterns. The sampler also offers an unjittered mode, which gives uniform sampling in the strata; this mode is mostly useful for comparisons between different sampling techniques rather than for rendering high-quality images.
][
  #link("<StratifiedSampler>")[#emph[分层采样器];];通过抖动分层中心点的方式，在每个分层内的随机点放置每个样本，使得分层内的所有点都以相等的概率被采样。由此抖动产生的不均匀性有助于将混叠伪影转化为噪声，如@spectral-analysis-of-sampling-patterns 中讨论的那样。采样器还提供了一种不抖动模式，这种模式在分层中提供均匀采样；这种模式主要用于不同采样技术之间的比较，而不是用于渲染高质量图像。
]

#parec[
  Direct application of stratification to high-dimensional sampling quickly leads to an intractable number of samples. For example, if we divided the 5D image, lens, and time sample space into four strata in each dimension, the total number of samples per pixel would be $4^5 = 1024$. We could reduce this impact by taking fewer samples in some dimensions (or not stratifying some dimensions, effectively using a single stratum), but we would then lose the benefit of having well-stratified samples in those dimensions. This problem with stratification is known as the #emph[curse of dimensionality];.
][
  将分层直接应用于高维采样会迅速导致难以处理的大量样本。例如，如果我们将5D图像、镜头和时间采样空间在每个维度上划分为四个分层，每像素的总样本数将是 $4^5 = 1024$。我们可以通过在某些维度上减少样本数量（或不对某些维度进行分层，实际上使用单个分层）来减少这种影响，但这样会失去在这些维度上保持良好分层样本的优势。这种分层问题被称为#emph[维度的诅咒];。
]

#parec[
  We can reap most of the benefits of stratification without paying the price in excessive total sampling by computing lower-dimensional stratified patterns for subsets of the domain's dimensions and then randomly associating samples from each set of dimensions. (This process is sometimes called #emph[padding];.) @fig:stratified-shuffle shows the basic idea: we might want to take just four samples per pixel but still require the samples to be stratified over all dimensions. We independently generate four 2D stratified image samples, four 1D stratified time samples, and four 2D stratified lens samples. Then we randomly associate a time and lens sample value with each image sample. The result is that each pixel has samples that together have good coverage of the sample space.
][
  我们可以通过为域的维度子集计算低维分层模式，然后随机关联每组维度的样本，从而在不显著增加总采样数量的情况下，获得大部分分层的好处。（这个过程有时称为#emph[填充];。）@fig:stratified-shuffle 展示了基本思想：我们可能只想每像素取四个样本，但仍要求样本在所有维度上分层。我们独立生成四个2D分层图像样本，四个1D分层时间样本和四个2D分层镜头样本。然后我们随机将时间样本和镜头样本值与每个图像样本关联。结果是每个像素的样本在采样空间中具有良好的覆盖。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f22.svg"),
  caption: [
    #ez_caption[We can generate a good sample pattern that reaps the benefits of stratification without requiring all the sampling dimensions to be stratified simultaneously. Here, we have split $(x,y)$ image position, time $t$, and $(u,v)$ lens position into independent strata with four regions each. Each is sampled independently, and then a time sample and a lens sample are randomly associated with each image sample. We retain the benefits of stratification in each stratification domain without having to exponentially increase the total number of samples.][
      我们可以生成一种好的采样模式，在不需要所有采样维度同时进行分层的情况下，获得分层的好处。这里，我们将$(x,y)$图像位置、时间$t$和$(u,v)$镜头位置分别划分为四个独立的区域。每个维度独立采样，然后将时间样本和镜头样本随机关联到每个图像样本上。我们在每个分层域中保留了分层的优势，而不需要指数级地增加样本总数。
    ]
  ],
)<stratified-shuffle>
#parec[
  Rendering a scene without complex lighting but including defocus blur due to a finite aperture is useful for understanding the behavior of sampling patterns. This is a case where the integral is over four dimensions—more than just the two of the image plane, but not the full high-dimensional integral when complex light transport is sampled. @fig:sample-uniform-stratified shows the improvement in image quality from using stratified lens and image samples versus using unstratified independent samples when rendering such a scene.
][
  渲染一个没有复杂光照但由于有限光圈导致失焦模糊的场景有助于理解采样模式的行为。这是一个积分在四维上的情况——不仅仅是图像平面的两个维度，而不是采样复杂光传输时的完整高维积分。@fig:sample-uniform-stratified 展示了在渲染这样一个场景时，使用分层镜头和图像样本与使用非分层独立样本相比，图像质量的提升。
]


#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f23.svg"),
  caption: [
    #ez_caption[
      Effect of Sampling Patterns in Rendering a Purple Sphere with Defocus Blur. (a) A high-quality reference image of a blurry sphere. (b) An image generated with independent random sampling without stratification. (c) An image generated with the same number of samples, but with the StratifiedSampler, which stratified both the image and, more importantly for this image, the lens samples. Stratification gives a substantial improvement and a $3 times$ reduction in mean squared error.
    ][
      在渲染具有散焦模糊的紫色球体时，不同采样模式的效果。(a) 一个高质量的模糊球体参考图像。(b) 使用独立的随机采样且未进行分层生成的图像。(c) 使用相同数量的样本但采用了StratifiedSampler的图像，该采样器对图像进行了分层，更重要的是对镜头样本进行了分层。分层采样显著提高了图像质量，将均方误差减少了$3$倍。
    ]
  ],
)<sample-uniform-stratified>
#parec[
  @fig:sampling-patterns shows a comparison of a few sampling patterns. The first is an independent uniform random pattern generated by the #link("../Sampling_and_Reconstruction/Independent_Sampler.html#IndependentSampler")[#emph[IndependentSampler];];. The result is terrible; some regions have few samples and other areas have clumps of many samples. The second is an unjittered stratified pattern. In the last, the uniform pattern has been jittered, with a random offset added to each sample's location, keeping it inside its cell. This gives a better overall distribution than the purely random pattern while preserving the benefits of stratification, though there are still some clumps of samples and some regions that are undersampled.
][
  @fig:sampling-patterns 展示了一些采样模式的比较。第一个是由#link("../Sampling_and_Reconstruction/Independent_Sampler.html#IndependentSampler")[#emph[独立采样器];];生成的独立均匀随机模式。结果很糟糕；一些区域样本很少，而其他区域则有很多样本聚集。第二个是未抖动的分层模式。最后一个是抖动的均匀模式，给每个样本的位置添加了一个随机偏移，使其保持在其单元内。这比纯随机模式提供了更好的整体分布，同时保留了分层的好处，尽管仍然有一些样本聚集和一些区域采样不足。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f24.svg"),
  caption: [
    #ez_caption[Three 2D Sampling Patterns. (a) The independent uniform pattern is an ineffective pattern, with many clumps of samples that leave large sections of the image poorly sampled. (b) An unjittered pattern is better distributed but can exacerbate aliasing artifacts. (c) A stratified jittered pattern turns aliasing from the unjittered pattern into high-frequency noise while generally maintaining the benefits of stratification. (See Figure 8.26 for a danger of jittering, however.)][三种二维采样模式。(a) 独立的均匀模式是一种低效的模式，样本形成许多聚集，导致图像的大部分区域采样不足。(b) 未抖动的模式分布更均匀，但可能会加剧混叠伪影。(c) 分层抖动模式将未抖动模式的混叠转化为高频噪声，同时总体上保持了分层的优势。（然而，关于抖动的风险，参见图8.26。）]
  ],
)<sampling-patterns>


#parec[
  @fig:stratified-comparisons shows images rendered using the #link("<StratifiedSampler>")[#emph[StratifiedSampler];] and shows how jittered sample positions turn aliasing artifacts into less objectionable noise.
][
  @fig:stratified-comparisons 展示了使用#link("<StratifiedSampler>")[#emph[分层采样器];];渲染的图像，并展示了抖动样本位置如何将混叠伪影转化为不那么令人反感的噪声。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f25.svg"),
  caption: [
    #ez_caption[Comparison of Image Sampling Methods with a Checkerboard Texture. This is a difficult image to render well, since the checkerboard’s frequency with respect to the pixel spacing tends toward infinity as we approach the horizon. (a) A reference image, rendered with 256 samples per pixel, showing something close to an ideal result. (b) An image rendered with one sample per pixel, with no jittering. Note the jaggy artifacts at the edges of checks in the foreground. Notice also the artifacts in the distance where the checker function goes through many cycles between samples; as expected from the signal processing theory presented earlier, that detail reappears incorrectly as lower-frequency aliasing. (c) The result of jittering the image samples, still with just one sample per pixel. The regular aliasing of the second image has been replaced by less objectionable noise artifacts. (d) The result of four jittered samples per pixel is still inferior to the reference image but is substantially better than the previous result.][使用棋盘格纹理的图像采样方法比较。由于棋盘格相对于像素间距的频率在接近地平线时趋向于无穷大，这使得这个图像很难被很好地渲染。(a) 一个参考图像，每像素渲染了256个样本，展示了接近理想的结果。(b) 一个未抖动、每像素仅使用一个样本渲染的图像。请注意前景中方格边缘的锯齿状伪影。还要注意远处的伪影，在那里棋盘函数在样本之间经历了多次循环；正如之前提到的信号处理理论所预期的那样，这些细节错误地以低频混叠形式重新出现。(c) 对图像样本进行抖动的结果，仍然是每像素一个样本。第二幅图像中的规则混叠已被不太明显的噪声伪影所取代。(d) 每像素使用四个抖动样本的结果，虽然仍然不如参考图像，但比之前的结果有了显著的改进。]
  ],
)<stratified-comparisons>

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f26.svg"),
  caption: [
    #ez_caption[
      a worst-case situation
      for stratified sampling. In an $n times n$ 2D pattern, up to $2 n$ of
      the points may project to essentially the same point on one of the axes.
      When "unlucky" patterns like this are generated, the quality of the
      results computed with them usually suffers. (Here, 8 of the samples have
      nearly the same $x$ value.)
    ][
      分层采样的最坏情况。在一个$n times n$的2D模式中，最多$2 n$个点可能投影到一个轴上的几乎相同的点。当生成这样的“倒霉”模式时，使用它们计算的结果质量通常会受到影响。（这里，8个样本的$x$值几乎相同。）
    ]

  ],
)<stratified-bad>


#parec[
  @fig:stratified-comparisons shows images rendered using the StratifiedSampler and shows how jittered sample positions turn aliasing artifacts into less objectionable noise.
][
  @fig:stratified-comparisons 展示了使用StratifiedSampler渲染的图像，并展示了抖动的样本位置如何将混叠伪影转化为不那么令人讨厌的噪声
]

```cpp
<<StratifiedSampler Definition>>=
class StratifiedSampler {
  public:
    <<StratifiedSampler Public Methods>>
  private:
    <<StratifiedSampler Private Members>>
};
```
#parec[
  The #link("<StratifiedSampler>")[#emph[StratifiedSampler];] constructor takes a specification of how many 2D strata should be used via specification of $x$ and $y$ sample counts. Parameters that specify whether jittering is enabled and a seed for the random number generator can also be provided to the constructor.
][
  #link("<StratifiedSampler>")[#emph[分层采样器];];构造函数通过指定 $x$ 和 $y$ 样本计数来确定使用多少个2D分层。构造函数还可以提供指定是否启用抖动和随机数生成器种子的参数。
]
```cpp
<<StratifiedSampler Public Methods>>=
StratifiedSampler(int xPixelSamples, int yPixelSamples, bool jitter,
                  int seed = 0)
    : xPixelSamples(xPixelSamples), yPixelSamples(yPixelSamples),
      seed(seed), jitter(jitter) {}

<<StratifiedSampler Private Members>>=
int xPixelSamples, yPixelSamples, seed;
bool jitter;
RNG rng;
```
#parec[
  The total number of samples in each pixel is the product of the two dimensions' sample counts.
][
  每个像素中的样本总数是两个维度的样本数量的乘积。
]

```cpp
int SamplesPerPixel() const { return xPixelSamples * yPixelSamples; }
```

#parec[
  This sampler needs to keep track of the current pixel, sample index, and dimension for use in the sample generation methods. After recording them in member variables, the `RNG` is seeded so that deterministic values are returned for the sample point, following the same approach as was used in `IndependentSampler::StartPixelSample()`.
][
  该采样器需要跟踪当前的像素、样本索引和维度，以便在样本生成方法中使用。在将它们记录到成员变量后，按照与 `IndependentSampler::StartPixelSample()` 中相同的方法，为 `RNG` 设置种子，以便为样本点返回确定性值。
]

```cpp
void StartPixelSample(Point2i p, int index, int dim) {
    pixel = p;
    sampleIndex = index;
    dimension = dim;
    rng.SetSequence(Hash(p, seed));
    rng.Advance(sampleIndex * 65536ull + dimension);
}
```

```cpp
Point2i pixel;
int sampleIndex = 0, dimension = 0;
```

#parec[
  The `StratifiedSampler`'s implementation is made more complex by the fact that its task is not to generate a full set of sample points for all of the pixel samples at once. If that was the task of the sampler, then the following code suggests how 1D stratified samples for some dimension might be generated: each array element is first initialized with a random point in its corresponding stratum and then the array is randomly shuffled.
][
  `StratifiedSampler` 的实现更加复杂，因为它的任务不是一次性为所有像素样本生成完整的样本点集。如果这是采样器的任务，那么以下代码展示了如何为某个维度生成一维分层样本：每个数组元素首先用其对应层中的随机点初始化，然后随机打乱数组。
]

#parec[
  This shuffling operation is necessary for padding, so that there is no correlation between the pixel sample index and which stratum its sample comes from. If this shuffling was not done, then the sample dimensions' values would be correlated in a way that would lead to errors in images—for example, the first 2D sample used to choose the film location, as well as the first 2D lens sample, would always each be in the lower left stratum adjacent to the origin.
][
  这种打乱操作对于填充是必要的，这样像素样本索引与其样本所属的层之间就没有关联。如果不进行这种打乱，样本维度的值将会以一种导致图像错误的方式相关联——例如，用于选择胶片位置的第一个二维样本以及第一个二维镜头样本将总是位于靠近原点的左下层。
]

```cpp
constexpr int n = ...;
std::array<Float, n> samples;
for (int i = 0; i < n; ++i)
    samples[i] = (i + rng.Uniform<Float>()) / n;
std::shuffle(samples.begin(), samples.end(), rng);
```

#parec[
  In the context of `pbrt`'s sampling interface, we would like to perform this random sample shuffling without explicitly representing all the dimension's sample values. The `StratifiedSampler` therefore uses a random permutation of the sample index to determine which stratum to sample. Given the stratum index, generating a 1D sample is easy.
][
  在 `pbrt` 的采样接口中，我们希望在不显式表示所有维度的样本值的情况下执行这种随机样本打乱。因此，`StratifiedSampler` 使用样本索引的随机排列来确定采样哪个层。给定层索引，生成一维样本就很容易了。
]

```cpp
Float Get1D() {
    // Compute stratum index for current pixel and dimension
    uint64_t hash = Hash(pixel, dimension, seed);
    int stratum = PermutationElement(sampleIndex, SamplesPerPixel(), hash);
    ++dimension;
    Float delta = jitter ? rng.Uniform<Float>() : 0.5f;
    return (stratum + delta) / SamplesPerPixel();
}
```

#parec[
  It is possible to perform the sample index permutation without representing the permutation explicitly thanks to the `PermutationElement()` routine, which is defined in Section B.2.8. It takes an index, a total permutation size, and a random seed, and returns the element that the given index is mapped to, doing so in such a way that a valid permutation is returned across all indices up to the permutation size. Thus, we just need to compute a consistent seed value that is the same whenever a particular dimension is sampled at a particular pixel. `Hash()` takes care of this, though note that `sampleIndex` must not be included in the hashed values, as doing so would lead to different permutations for different samples in a pixel.
][
  由于 `PermutationElement()` 例程的存在，我们可以在不显式表示排列的情况下执行样本索引的排列，该例程在第 B.2.8 节中定义。它接受一个索引、一个总的排列大小和一个随机种子，并返回给定索引映射到的元素，以便在所有索引上返回有效的排列，直到排列大小为止。因此，我们只需要计算一个一致的种子值，使得在特定像素的特定维度采样时始终相同。`Hash()` 负责这个，但请注意，`sampleIndex` 不应包含在哈希值中，因为这样做会导致像素中不同样本的排列不同。
]

```cpp
uint64_t hash = Hash(pixel, dimension, seed);
int stratum = PermutationElement(sampleIndex, SamplesPerPixel(), hash);
```

#parec[
  Generating a 2D sample follows a similar approach, though the stratum index has to be mapped into separate $x$ and $y$ stratum coordinates. Given these, the remainder of the sampling operation is straightforward.
][
  生成二维样本采用类似的方法，不过层索引必须映射到单独的 $x$ 和 $y$ 层坐标。给定这些，剩余的采样操作就很直接了。
]

```cpp
Point2f Get2D() {
    // Compute stratum index for current pixel and dimension
    uint64_t hash = Hash(pixel, dimension, seed);
    int stratum = PermutationElement(sampleIndex, SamplesPerPixel(), hash);
    dimension += 2;
    int x = stratum % xPixelSamples, y = stratum / xPixelSamples;
    Float dx = jitter ? rng.Uniform<Float>() : 0.5f;
    Float dy = jitter ? rng.Uniform<Float>() : 0.5f;
    return {(x + dx) / xPixelSamples, (y + dy) / yPixelSamples};
}
```

#parec[
  The pixel sample is not handled differently than other 2D samples with this sampler, so the `GetPixel2D()` method just calls `Get2D()`.
][
  在此采样器中，像素样本与其他二维样本的处理方式没有区别，因此 `GetPixel2D()` 方法只是调用 `Get2D()`。
]

```cpp
Point2f GetPixel2D() { return Get2D(); }
```

#parec[
  With a $d$ -dimensional stratification, the star discrepancy of jittered points has been shown to be
][
  对于 $d$ 维分层，已证明抖动点的星差异为
]
$ cal(O) (sqrt(d log n) / n^(1 \/ 2 + 1 \/ (2 d))) $ <jittered-discrepancy>

#parec[
  which means that stratified samples do not qualify as having low discrepancy.
][
  这意味着分层样本不符合低差异的标准。
]

#parec[
  The PSD of 2D stratified samples was plotted earlier, in @fig:jittered-poisson-disk-psds(a). Other than the central spike at the origin (at the center of the image), power is low at low frequencies and settles in to be fairly constant at higher frequencies, which means that this sampling approach is effective at transforming aliasing into high-frequency noise.
][
  2D分层样本的PSD在之前的@fig:jittered-poisson-disk-psds(a)中绘制。除了原点（图像中心）的中心尖峰外，低频功率较低，并在高频处趋于恒定，这意味着这种采样方法在将混叠转化为高频噪声方面是有效的。
]


