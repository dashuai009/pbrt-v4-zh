#import "../template.typ": ez_caption, parec

== Sampling Interface
<sampling-interface>

#parec[
  `pbrt`'s `Sampler` interface makes it possible to use a variety of sample generation algorithms for rendering. The sample points that they provide are used by `pbrt`'s `Integrator`s in a multitude of ways, ranging from determining points on the image plane from which camera rays originate to selecting which light source to trace a shadow ray to and at which point on it the shadow ray should terminate.
][
  `pbrt` 的 `Sampler` 接口使得可以使用多种采样生成算法进行渲染。`pbrt` 的 `Integrator` 以多种方式使用它们提供的样本点，从确定相机光线起始于图像平面的哪个点，到选择追踪阴影光线的光源及其终止点。
]

#parec[
  As we will see in the following sections, the benefits of carefully crafted sampling patterns are not just theoretical; they can substantially improve the quality of rendered images. The runtime expense for using good sampling algorithms is relatively small; because evaluating the radiance for each image sample is much more expensive than computing the sample's component values, doing this work pays dividends (Figure 8.20).
][
  正如我们将在后续章节中看到的，精心设计的采样模式的好处不仅仅是理论上的；它们可以显著提高渲染图像的质量。使用良好采样算法的运行时开销相对较小；因为评估每个图像样本的辐射度比计算样本的组件值要昂贵得多，进行这项工作是有回报的（图 8.20）。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f20.svg"),
  caption: [
    #ez_caption[Scene rendered with (a) a relatively ineffective sampler and (b) a carefully designed sampler, using the same number of samples for each. The improvement in image quality, ranging from the shadow on the floor to the quality of the glossy reflections, is noticeable. Both images are rendered with 8 samples per pixel. (Killeroo model courtesy of headus/Rezard.)][使用相同数量的采样点，场景分别由 (a) 一个相对低效的采样器 和 (b) 一个经过精心设计的采样器 渲染。图像质量的提升是显而易见的，从地面上的阴影到光滑反射的效果都有改善。两张图像均使用每像素 8 个采样渲染。（Killeroo 模型由 headus/Rezard 提供。）]
  ],
)<sampler-comparison>

#parec[
  The task of a `Sampler` is to generate uniform $d$ -dimensional sample points, where each coordinate's value is in the range $(0 , 1)$. The total number of dimensions in each point is not set ahead of time; `Sampler`s must generate additional dimensions on demand, depending on the number of dimensions required for the calculations performed by the light transport algorithms. (See @fig:sample-basic-idea.) While this design makes implementing a `Sampler` slightly more complex than if its task was to generate all the dimensions of each sample point up front, it is more convenient for integrators, which end up needing a different number of dimensions depending on the particular path they follow through the scene.
][
  `Sampler` 的任务是生成 $d$ 维的均匀采样点，其中每个坐标值的范围为 $(0, 1)$。每个采样点的总维度数量并不是预先固定的；`Sampler` 必须根据光传输算法在计算过程中所需的维度按需生成更多维度。（参见 @fig:sample-basic-idea。）相比于一开始就生成每个采样点的所有维度，这种设计虽然比让 `Sampler` 稍微复杂一些，但是对积分器来说更方便，因为积分器在场景中沿着不同路径时需要的维度数量可能不同。
]

#figure(
  image("../pbr-book-website/4ed/Sampling_and_Reconstruction/pha08f21.svg"),
  caption: [
    #ez_caption[
      Samplers generate a $d$-dimensional sample point for each of the image samples taken to generate the final image. Here, the pixel $(3,8)$ is being sampled, and there are two image samples in the pixel area. The first two dimensions of the sample give the $(x,y)$ offset of the sample within the pixel, and the next three dimensions determine the time and lens position of the corresponding camera ray. Subsequent dimensions are used by the Monte Carlo light transport algorithms implemented in pbrt's Integrators.
    ][
      采样器为生成最终图像所需的每个图像样本生成一个$d$维的采样点。这里，像素$(3,8)$正在被采样，该像素区域内有两个图像样本。样本的前两个维度给出了样本在像素内的$(x,y)$偏移，接下来的三个维度决定了相应相机光线的时间和镜头位置。后续的维度则由pbrt的积分器中实现的蒙特卡罗光传输算法使用。
    ]
  ],
)<sample-basic-idea>

```cpp
<<Sampler Definition>>=
class Sampler : public TaggedPointer<<<Sampler Types>> > {
  public:
    <<Sampler Interface>>
};
```


#parec[
  All the samplers save for `MLTSampler` are defined in this chapter; that one is used solely by the `MLTIntegrator`, which is described in the online version of the book.
][
  除 `MLTSampler` 外，所有采样器均在本章中定义；该采样器仅由 `MLTIntegrator` 使用，后者在本书的在线版本中描述。
]

```cpp
<<Sampler Types>>=
IndependentSampler, StratifiedSampler, HaltonSampler, PaddedSobolSampler,
SobolSampler, ZSobolSampler, MLTSampler
```

#parec[
  `Sampler` implementations specify the number of samples to be taken in each pixel and return this value via `SamplesPerPixel()`. Most samplers already store this value as a member variable and return it directly in their implementations of this method.
][
  `Sampler` 实现指定每个像素中要拍摄的样本数量，并通过 `SamplesPerPixel()` 返回此值。大多数采样器已经将此值存储为成员变量，并在其方法实现中直接返回它。
]

```cpp
<<Sampler Interface>>=
int SamplesPerPixel() const;
```


#parec[
  When an `Integrator` is ready to start work on a given pixel sample, it starts by calling `StartPixelSample()`, providing the coordinates of the pixel in the image and the index of the sample within the pixel. (The index should be greater than or equal to zero and less than the value returned by `SamplesPerPixel()`.) The `Integrator` may also provide a starting dimension at which sample generation should begin.
][
  当 `Integrator` 准备开始处理给定的像素样本时，它首先调用 `StartPixelSample()`，提供图像中像素的坐标以及像素内样本的索引。（索引应大于或等于零且小于 `SamplesPerPixel()` 返回的值。）`Integrator` 还可以提供样本生成应开始的起始维度。
]

#parec[
  This method serves two purposes. First, some `Sampler` implementations use the knowledge of which pixel is being sampled to improve the overall distribution of the samples that they generate—for example, by ensuring that adjacent pixels do not take two samples that are close together. Attending to this detail, while it may seem minor, can substantially improve image quality.
][
  此方法有两个目的。首先，一些 `Sampler` 实现利用正在采样的像素的信息来改善它们生成的样本的整体分布，例如，通过确保相邻像素不获取两个彼此接近的样本。
]

#parec[
  Second, this method allows samplers to put themselves in a deterministic state before generating each sample point. Doing so is an important part of making `pbrt`'s operation deterministic, which in turn is crucial for debugging. It is expected that all samplers will be implemented so that they generate precisely the same sample coordinate values for a given pixel and sample index across multiple runs of the renderer. This way, for example, if `pbrt` crashes in the middle of a lengthy run, debugging can proceed starting at the specific pixel and pixel sample index where the renderer crashed. With a deterministic renderer, the crash will reoccur without taking the time to perform all the preceding rendering work.
][
  尽管这看似细微，但注意这一点可以显著提升图像质量。其次，此方法允许采样器在生成每个样本点之前将自己置于确定性状态。 这样做是使 `pbrt` 操作确定性的重要部分，这反过来对于调试至关重要。所有采样器预计都会实现为在渲染器的多次运行中，为给定像素和样本索引生成完全相同的样本坐标值。 这样，例如，如果 `pbrt` 在长时间运行中途崩溃，可以从渲染器崩溃的特定像素和像素样本索引开始进行调试。 使用确定性的渲染器，崩溃将在不进行所有先前渲染工作的情况下重新发生。
]

```cpp
<<Sampler Interface>>+=
void StartPixelSample(Point2i p, int sampleIndex, int dimension = 0);
```

#parec[
  `Integrator`s can request dimensions of the $d$ -dimensional sample point one or two at a time, via the `Get1D()` and `Get2D()` methods. While a 2D sample value could be constructed by using values returned by a pair of calls to `Get1D()`, some samplers can generate better point distributions if they know that two dimensions will be used together. However, the interface does not support requests for 3D or higher-dimensional sample values from samplers because these are generally not needed for the types of rendering algorithms implemented here. In that case, multiple values from lower-dimensional components can be used to construct higher-dimensional sample points.
][
  `Integrator` 可以通过 `Get1D()` 和 `Get2D()` 方法一次请求一个或两个 $d$ 维样本点的维度。 虽然可以通过使用两次调用 `Get1D()` 返回的值来构建 2D 样本值，但如果采样器知道将一起使用两个维度，则可以生成更好的点分布。 然而，接口不支持从采样器请求 3D 或更高维样本值，因为这些通常不需要用于此处实现的渲染算法。 在这种情况下，可以使用来自低维组件的多个值来构建高维样本点。
]

```cpp
<<Sampler Interface>>+=
Float Get1D();
Point2f Get2D();
```


#parec[
  A separate method, `GetPixel2D()`, is called to retrieve the 2D sample used to determine the point on the film plane that is sampled. Some of the following `Sampler` implementations handle those dimensions of the sample differently from the way they handle 2D samples in other dimensions; other `Sampler`s implement this method by calling their `Get2D()` methods.
][
  一个单独的方法 `GetPixel2D()` 被调用以检索用于确定在胶片平面上采样的点的 2D 样本。 以下一些 `Sampler` 实现以不同于处理其他维度的 2D 样本的方式处理这些样本的维度；其他 `Sampler` 通过调用其 `Get2D()` 方法实现此方法。
]

```cpp
<<Sampler Interface>>+=
Point2f GetPixel2D();
```

#parec[
  Because each sample coordinate must be strictly less than 1, it is useful to define a constant, `OneMinusEpsilon`, that represents the largest representable floating-point value that is less than 1. Later, the `Sampler` implementations will sometimes clamp sample values to be no larger than this.
][
  因为每个样本坐标必须严格小于 1，所以定义一个常量 `OneMinusEpsilon` 是有用的，它表示小于 1 的最大可表示浮点值。 稍后，`Sampler` 实现有时会将样本值限制为不大于此值。
]

```cpp
<<Floating-point Constants>>+=
static constexpr double DoubleOneMinusEpsilon = 0x1.fffffffffffffp-1;
static constexpr float FloatOneMinusEpsilon = 0x1.fffffep-1;
#ifdef PBRT_FLOAT_AS_DOUBLE
static constexpr double OneMinusEpsilon = DoubleOneMinusEpsilon;
#else
static constexpr float OneMinusEpsilon = FloatOneMinusEpsilon;
#endif
```

#parec[
  A sharp edge of these interfaces is that code that uses sample values must be carefully written so that it always requests sample dimensions in the same order. Consider the following code:
][
  这些接口的一个尖锐边缘是使用样本值的代码必须仔细编写，以便始终以相同的顺序请求样本维度。 考虑以下代码：
]

```cpp
  sampler->StartPixelSample(pPixel, sampleIndex);
  Float v = a(sampler->Get1D());
  if (v > 0)
      v += b(sampler->Get1D());
  v += c(sampler->Get1D());
```

#parec[
  In this case, the first dimension of the sample will always be passed to the function `a()`; when the code path that calls `b()` is executed, `b()` will receive the second dimension. However, if the `if` test is not always true or false, then `c()` will sometimes receive a sample value from the second dimension of the sample and otherwise receive a sample value from the third dimension. This will thus thwart efforts by the sampler to provide well-distributed sample points in each dimension being evaluated. Code that uses `Sampler`s should therefore be carefully written so that it consistently consumes sample dimensions, to avoid this issue.
][
  在这种情况下，样本的第一个维度将始终传递给函数 `a()`；当执行调用 `b()` 的代码路径时，`b()` 将接收第二个维度。 然而，如果 `if` 测试并不总是为真或假，那么 `c()` 有时会从样本的第二个维度接收样本值，否则会从第三个维度接收样本值。 这将影响采样器在每个维度中提供良好分布的样本点的效果。 因此，使用 `Sampler` 的代码应仔细编写，以便一致地消耗样本维度，以避免此问题。
]

#parec[
  `Clone()`, the final method required by the interface, returns a copy of the `Sampler`. Because `Sampler` implementations store a variety of state about the current sample—which pixel is being sampled, how many dimensions of the sample have been used, and so forth—it is unsafe for a single `Sampler` to be used concurrently by multiple threads. Therefore, `Integrator`s call `Clone()` to make copies of an initial `Sampler` so that each thread has its own. The implementations of the various `Clone()` methods are not generally interesting, so they will not be included in the text here.
][
  接口要求的最后一个方法 `Clone()` 返回 `Sampler` 的副本。 因为 `Sampler` 实现存储了关于当前样本的各种状态——正在采样哪个像素、样本的多少维度已被使用等等——所以单个 `Sampler` 被多个线程同时使用是不安全的。 因此，`Integrator` 调用 `Clone()` 来创建初始 `Sampler` 的副本，以确保每个线程都有自己的副本。 各种 `Clone()` 方法的实现通常并不有趣，因此它们不会在此文本中包含。
]

