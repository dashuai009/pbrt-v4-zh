#import "../template.typ": parec, translator


== Images
<b.5-images>

#parec[
  The `Image` class stores a 2D array of pixel values, where each pixel
  stores a fixed number of scalar-valued channels. (For example, an image
  storing RGB color would have three channels.) It provides a variety of
  operations ranging from looking up or interpolating pixel values to
  image-wide operations like resizing. It is at the core of both the
  `FloatImageTexture` and `SpectrumImageTexture` classes and is used for
  lights such as the `ImageInfiniteLight` and `ProjectionLight`.
  Furthermore, both of `pbrt`’s `Film` implementations make use of its
  capabilities for writing images to disk in a variety of file formats.
][
  Image
  类存储一个像素值的二维数组，每个像素包含固定数量的标量通道（channels）。例如，存储
  RGB
  颜色的图像将有三个通道。它提供了一系列操作，涵盖从查找或插值像素值到对整张图像进行诸如调整大小等操作。它是
  FloatImageTexture 与 SpectrumImageTexture 类的核心，并用于灯光源，例如
  ImageInfiniteLight 和 ProjectionLight。此外，pbrt 的 Film
  实现也利用了它的能力，将图像写出到磁盘，支持多种文件格式。
]


```cpp
class Image {
  public:
    <<Image Public Methods>>
  private:
    <<Image Private Methods>>
    <<Image Private Members>>
};
```

#parec[
  Image is defined in the files
  https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/image.h and
  https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/image.cpp.
][
  Image 定义于以下文件中：
  https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/image.h
  https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/image.cpp
]

#parec[
  The `Image` class provides a number of constructors as well as a method
  (which will be discussed in Section~B.5.3) that reads an image from a
  file. We will only describe the operation of its most general-purpose
  constructor here; see the class definition for the remainder of them.
][
  Image 类提供若干构造函数，以及一个方法（将在 B.5.3
  节中讨论）用于从文件读取图像。这里仅描述其最通用构造函数的操作；其他构造函数请参阅类定义。
]

#parec[
  This `Image` constructor takes the in-memory format to use for storing
  pixel data, `format`, the overall image resolution, and names for all of
  the channels. Optionally, both a `ColorEncoding` and an `Allocator` can
  be provided; the former specifies a technique for encoding
  fixed-precision pixel values and will be discussed in Section~B.5.6.
][
  上述 Image 构造函数签名用于存储像素数据的内存格式
  format、整张图像的分辨率，以及所有通道的名称。可选地，ColorEncoding
  与一个 Allocator 也可以提供；前者用于指定固定精度像素值的编码方式，将在
  Section~B.5.6 中讨论。
]
```cpp
<Image...>  // see above for signature
```

#parec[
  Three in-memory formats are supported for pixel channel values. Note
  that `Image` uses the same encoding for all channels; it is not possible
  to mix and match. The first of them, `U256`, specifies an unsigned 8-bit
  encoding of values between 0 and 1 using integers ranging from 0 to 255.
  This is a memory-efficient encoding and is widely used in image file
  formats, but it provides limited range. `Half` uses 16-bit
  floating-point values (which were described in Section~6.8.1) to provide
  much more dynamic range than `U256`, while still being memory efficient.
  Finally, `Float` specifies full 32-bit `float`s. It would not be
  difficult to generalize `Image` to also support double-precision
  floating-point storage, though we have not found a need to do so for
  `pbrt`’s uses of this class.
][
  像素通道值支持三种内存格式。需要注意的是，Image 对所有通道使用相同的编码方式；不允许混用。第一种是 U256，它使用无符号 8 位整数对 0 到 1 的数值进行编码，取值范围是 0 到 255。这是一种内存高效的编码方式，并且被广泛应用于图像文件格式中，但其动态范围有限。第二种是 Half，它使用 16 位浮点数（在第 6.8.1 节中介绍过），相比 U256 提供了更大的动态范围，同时仍然保持了较高的内存效率。最后一种是 Float，即完整的 32 位 float。理论上，将 Image 泛化以支持双精度浮点数存储并不困难，不过在 pbrt 使用该类的场景下，我们并没有发现这样的需求。
]
```cpp
enum class PixelFormat { U256, Half, Float };
```

#parec[
  A few helper functions test whether a given `PixelFormat` uses a
  specified amount of storage. Isolating these tests in this way makes it
  easier, for example, to extend `Image` to also provide a 16-bit integer
  representation without needing to update logic that purely relates to
  memory allocation.
][
  有一些辅助函数用于测试给定的 PixelFormat 是否使用了特定大小的存储空间。将这些测试逻辑独立出来，使得扩展 Image 更加容易，比如增加对 16 位整数表示的支持时，就无需修改那些仅与内存分配相关的逻辑。
]
```cpp
bool Is8Bit(PixelFormat format) { return format == PixelFormat::U256; }
bool Is16Bit(PixelFormat format) { return format == PixelFormat::Half; }
bool Is32Bit(PixelFormat format) { return format == PixelFormat::Float; }
```

#parec[
  The size of the provided `channelNames` parameter determines the number of channels the image stores at each pixel. The `Image` class does not impose any semantics on the channels or attempt to interpret their meaning but instead just stores values and performs the operations on them specified by the caller.
][
  传入的 `channelNames` 参数的大小决定了图像在每个像素中存储的通道数量。`Image` 类不会对这些通道施加任何语义，也不会尝试解释它们的含义，而只是存储数值，并根据调用者指定的操作对其进行处理。
]

```cpp
PixelFormat format;
Point2i resolution;
pstd::vector<std::string> channelNames;
ColorEncoding encoding = nullptr;
```


#parec[
  Because these values are stored as private member variables, `Image` provides corresponding accessor methods.
][

  由于这些值被作为私有成员变量存储，Image 提供了相应的访问器方法。

]


```cpp
PixelFormat Format() const { return format; }
Point2i Resolution() const { return resolution; }
int NChannels() const { return channelNames.size(); }
std::vector<std::string> ChannelNames() const;
const ColorEncoding Encoding() const { return encoding; }
```
#parec[
  `Image` allows the specification of an image with no pixels; `operator bool` provides a quick check for whether an image is nonempty.
][
  Image 允许指定一个没有像素的图像；operator bool 提供一个快速检查以判断图像是否非空。


]
```cpp
operator bool() const { return resolution.x > 0 && resolution.y > 0; }
```

#parec[
  One of the following member variables stores the pixel values.  Which one is used is determined by the specified `PixelFormat`.
][
  下列成员变量之一用于存储像素值。使用哪一个取决于指定的 `PixelFormat`。
]



```cpp
pstd::vector<uint8_t> p8;
pstd::vector<Half> p16;
pstd::vector<float> p32;
```

#parec[
  The `PixelOffset()` method returns the offset into the pixel value array for given integer pixel coordinates.  In debug builds, a DCHECK() call, not included here, checks that the provided coordinates are between 0 and the image resolution in each dimension.
][
  `PixelOffset()` 方法返回给定整数像素坐标在像素值数组中的偏移量。在调试版本中会执行一个 DCHECK() 断言，用以检查坐标是否在图像分辨率范围内（此处未显示实现）。



]

#parec[
  A few factors determine the following indexing computation: first, the coordinate system for images has $(0, 0)$ at the upper left corner of the image; images are then laid out in $x$ scanline order, and each pixel’s channel values are laid out successively in memory.
][
  影响以下索引计算的几个因素是：首先，图像的坐标系统以左上角 $(0, 0)$ 为原点；图像随后按 x 方向的扫描线顺序排列，每个像素的通道值在内存中依次排布。


]

```cpp
size_t PixelOffset(Point2i p) const {
    return NChannels() * (p.y * resolution.x + p.x);
}
```

#parec[
  An alternative memory layout would first store all the pixels’ first channel values contiguously in memory, then the second channel values, and so forth.  In pbrt, the most common uses of `Image` involve accessing all the channels in a pixel, so the layout we have chosen gives better memory access coherence, which generally leads to better cache performance.
][
  另一种内存布局会先在内存中将所有像素的第一通道值连续存储，然后是第二通道值，依此类推。在 pbrt 中，Image 的最常见用法是访问像素的所有通道，因此我们选择的布局在内存访问的一致性方面表现更好，通常能带来更好的缓存性能。


]
=== Working with Pixel Values

#parec[
  The GetChannel() method returns the floating-point value for a single image channel, taking care of both addressing pixels and converting the in-memory value to a Float.  Note that if this method is used, it is the caller’s responsibility to keep track of what is being stored in each channel.
][
  `GetChannel()` 方法返回单个图像通道的浮点值，负责像素寻址以及将内存中的值转换为 Float。请注意，如果使用此方法，调用者有责任跟踪每个通道中存储的内容。
]


```cpp
Float GetChannel(Point2i p, int c,
                 WrapMode2D wrapMode = WrapMode::Clamp) const {
    <<Remap provided pixel coordinates before reading channel>>
    switch (format) {
    case PixelFormat::U256:  { <<Return U256-encoded pixel channel value>>; }
    case PixelFormat::Half:  { <<Return Half-encoded pixel channel value>>; }
    case PixelFormat::Float: { <<Return Float-encoded pixel channel value>>; }
    }
}
```

#parec[
  Like all the upcoming methods that return pixel values, the lookup point
  `p` that is passed to `GetChannel()` is not required to be inside
  the image bounds.  This is a convenience for code that calls these methods
  and saves them from all needing to handle boundary conditions themselves.
][

  与将要返回像素值的所有方法一样，传给 GetChannel() 的查找点 p 不必一定在图像边界内。这为调用这些方法的代码提供了方便，避免它们自己处理边界条件。
]

#parec[
  `WrapMode` and `WrapMode2D` specify how out-of-bounds coordinates should be handled.  The first three options are widely used in texture mapping, and are respectively to return a black (zero-valued) result, to clamp out-of-bounds coordinates to the valid bounds, and to take them modulus the image resolution, which effectively repeats the image infinitely.  The last option, `OctahedralSphere`, accounts for the layout of the octahedron used in the definition of equi-area spherical mapping (see Section 3.8.3) and should be used when looking up values in images that are based on that parameterization.
][


  WrapMode 和 WrapMode2D 指定边界外的坐标应如何处理。前三个选项在纹理映射中被广泛使用，分别返回一个黑色（零值）的结果、将边界外的坐标夹到有效边界内，以及对它们取模以实现图像的无限重复。最后一个选项 OctahedralSphere，考虑在等面积球面映射定义中所使用的八面体布局（见第 3.8.3 节），在基于该参数化的图像中查找值时应使用。
]


```
enum class WrapMode { Black, Clamp, Repeat, OctahedralSphere };
struct WrapMode2D {
    pstd::array<WrapMode, 2> wrap;
};
```
#parec[
  The RemapPixelCoords() function handles modifying the pixel coordinates
  as needed according to the WrapMode for each dimension. If an
  out-of-bounds coordinate has been provided and `WrapMode::Black` has
  been specified, it returns a false value, which is handled here by
  returning 0. The implementation of this function is not included here.

][
  该 RemapPixelCoords() 函数根据各维度的 WrapMode
  修改像素坐标。如果提供了越界的坐标并且指定了
  `WrapMode::Black`，它将返回一个 false 值，因此在此通过返回 0
  来处理。该函数的实现未在原书中给出。
]

```
if (!RemapPixelCoords(&p, resolution, wrapMode))
    return 0;
```
#parec[
  Given a valid pixel coordinate, `PixelOffset()` gives the offset to the
  first channel for that pixel. A further offset by the channel index `c`
  is all that is left to get to the channel value. For `U256` images, this
  value is decoded into a `Float` using the specified color encoding
  (discussed in Section 8.1.4).

][
  给定一个有效的像素坐标，`PixelOffset()`
  给出该像素第一个通道的偏移量。再按通道索引 `c`
  进行一次偏移，就只剩下获取通道值的过程了。对于 `U256`
  图像，这个值通过指定的颜色编码解码为 `Float`（在第 8.1.4 节中讨论）。
]

```
Float r;
encoding.ToLinear({&p8[PixelOffset(p) + c], 1}, {&r, 1});
return r;
```
#parec[
  For `Half` images, the `Half` class’s `Float` conversion operator is
  invoked to get the return value.

][
  对于 `Half` 图像，会调用 `Half` 类的 `Float` 转换运算符来获取返回值。
]

```
return Float(p16[PixelOffset(p) + c]);
```
#parec[
  And for `Float` images, the task is trivial.

][
  对于 `Float` 图像，任务很简单。
]

```
return p32[PixelOffset(p) + c];
```
#parec[
  The `Image` class also provides a `LookupNearestChannel()` method, which
  returns the specified channel value for the pixel sample nearest a
  provided coordinate with respect to \[0, 1\]^2. It is a simple wrapper
  around `GetChannel()`, so it is not included here.

][
  Image 类还提供一个 `LookupNearestChannel()` 方法，它返回在 \[0,1\]^2
  区间内、距离给定坐标最近的像素采样的指定通道值。它是对 `GetChannel()`
  的一个简单包装，因此这里不再展开。
]

#parec[
  Slightly more interesting in its implementation is `BilerpChannel`,
  which uses bilinear interpolation between four image pixels to compute
  the channel value. (This is equivalent to filtering with a pixel-wide
  triangle filter.)

][
  在实现上稍具趣味的是
  `BilerpChannel`，它使用四个像素之间的双线性插值来计算通道值。这相当于对一个像素宽度的三角形滤波器进行滤波。
]

```
Float BilerpChannel(Point2f p, int c,
                    WrapMode2D wrapMode = WrapMode::Clamp) const {
    // Compute discrete pixel coordinates and offsets for p
    // Load pixel channel values and return bilinearly interpolated value
}
```
#parec[
  The first step is to scale the provided coordinates `p` by the image
  resolution, turning them into continuous pixel coordinates. Because
  these are continuous coordinates and the pixels in the image are defined
  at discrete pixel coordinates, it is important to carefully convert into
  a common representation (Section 8.1.4). Here, the work is performed
  using discrete coordinates, with the continuous pixel coordinates mapped
  to the discrete space.

][
  第一步是将提供的坐标 `p`
  按图像分辨率缩放，将它们转换为连续像素坐标。由于这是连续坐标，而图像中的像素在离散像素坐标上定义，因此重要的是要谨慎地转换为统一的表示（第
  8.1.4
  节）。在这里，工作是使用离散坐标来执行的，将连续像素坐标映射到离散空间。
]

```
Float x = p[0] * resolution.x - 0.5f, y = p[1] * resolution.y - 0.5f;
int xi = pstd::floor(x), yi = pstd::floor(y);
Float dx = x - xi, dy = y - yi;
```
#parec[
  After the distances are found in each dimension to the pixel at the last
  integer before the given coordinates, `dx` and `dy`, the four pixels are
  bilinearly interpolated.

][
  在每个维度中找到距离给定坐标前的最近整数像素的距离后，`dx` 和
  `dy`，四个像素就进行双线性插值。
]

```
pstd::array<Float, 4> v = {GetChannel({xi,     yi},     c, wrapMode),
                           GetChannel({xi + 1, yi},     c, wrapMode),
                           GetChannel({xi,     yi + 1},     c, wrapMode),
                           GetChannel({xi + 1, yi + 1},     c, wrapMode)};
return ((1 - dx) * (1 - dy) * v[0] + dx * (1 - dy) * v[1] +
        (1 - dx) *      dy  * v[2] + dx *      dy  * v[3]);
```
#parec[
  The SetChannel() method, the implementation of which is not included in
  the book, sets the value of a channel in a specified pixel.

][
  SetChannel() 方法的实现未在原书中给出，它设置指定像素的通道值。
]

```
void SetChannel(Point2i p, int c, Float value);
```
```
ImageChannelValues GetChannels(Point2i p,
                               WrapMode2D wrapMode = WrapMode::Clamp) const;
```
#parec[
  GetChannels() returns the channel values using an instance of the
  `ImageChannelValues` class, the definition of which is not included
  here. `ImageChannelValues` can be operated on more or less as if it were
  a std::vector, though it is based on the InlinedVector class that was
  described in Section B.4. It is thus able to avoid the cost of the
  dynamic memory allocations that std::vector would otherwise require if a
  small number of channel values were being returned.

][
  GetChannels() 使用一个 ImageChannelValues
  类的实例返回通道值。该类的定义在此未给出。ImageChannelValues 可以像
  std::vector 一样使用，尽管它基于在 B.4 节中描述的 InlinedVector
  类，因此在返回少量通道值时能够避免 std::vector
  可能需要的动态内存分配成本。
]

```
ImageChannelDesc GetChannelDesc(
    pstd::span<const std::string> channels) const;
```
#parec[
  All the methods that we have seen in this section also have variants
  that take an `ImageChannelDesc` and then return values for just the
  specified channels, in the order they were requested in the call to
  `GetChannelDesc()`. Here is the one for `GetChannels()`:

][
  本节所示的方法也都提供接受 ImageChannelDesc 的变体，并按在
  GetChannelDesc() 调用中请求的顺序仅返回指定通道的值。以下是
  GetChannels() 的一个例子：
]

```
ImageChannelValues GetChannels(Point2i p, const ImageChannelDesc &desc,
                               WrapMode2D wrapMode = WrapMode::Clamp) const;
```

=== Image-Wide Operations
<image-wide-operations>


#parec[
  The `Image` class also provides a number of operations that operate on
  the entire image, again agnostic to the semantics of the values an image
  stores.

][
  Image 类还提供一些在整个图像上执行的操作，同样与图像存储值的语义无关。
]

#parec[
  `SelectChannels()` returns a new image that includes only the specified
  channels of the original image, and `Crop()` returns an image that
  contains the specified subset of pixels of the original.

][
  SelectChannels() 返回一个新图像，仅包含原始图像的指定通道，Crop()
  返回包含原始图像中指定像素子集的图像。
]

```cpp
<<Image Public Methods>>+=
Image SelectChannels(const ImageChannelDesc &desc,
                     Allocator alloc = {}) const;
Image Crop(const Bounds2i &bounds, Allocator alloc = {}) const;
```


#parec[
  CopyRectOut() and CopyRectIn() copy the specified rectangular regions of
  the image to and from the provided buffers. For some
  performance-sensitive image processing operations, it is helpful to
  incur the overhead of converting the in-memory image format to `float`s
  just once so that subsequent operations can operate directly on `float`
  values.

][
  CopyRectOut() 和 CopyRectIn()
  将图像的指定矩形区域复制到提供的缓冲区，或从缓冲区复制回图像。对于某些对性能敏感的图像处理操作，一次性将内存中的图像格式转换为浮点数的开销是值得的，这样后续操作就可以直接在浮点数值上进行运算。
]

```
Image SelectChannels(const ImageChannelDesc &desc,
                     Allocator alloc = {}) const;
Image Crop(const Bounds2i &bounds, Allocator alloc = {}) const;
```
#parec[
  A number of methods compute aggregate statistics about the image.
  `Average()` returns the average value of each specified channel across
  the entire image.

][
  有多种方法用于计算图像的聚合统计量。`Average()`
  返回整张图像中对每个指定通道的平均值。
]

```
ImageChannelValues Average(const ImageChannelDesc &desc) const;
```
#parec[
  Two methods respectively check for pixels with infinite or not-a-number
  values.

][
  两种方法分别用于检查像素值中是否包含无穷大值或 NaN 值。
]

```
bool HasAnyInfinitePixels() const;
bool HasAnyNaNPixels() const;
```
#parec[
  Three methods measure error, comparing the image to a provided reference
  image, which should have the same resolution and named channels. Each
  takes a set of channels to include in the error computation and returns
  the error with respect to the specified metric. Optionally, they return
  an `Image` where each pixel stores its error.

][
  三种方法用于衡量误差：MAE、MSE、MRSE，比较当前图像与给定参考图像（分辨率与命名通道相同），可选择返回一个每个像素存储其误差的图像。
]

```
ImageChannelValues MAE(const ImageChannelDesc &desc, const Image &ref,
                       Image *errorImage = nullptr) const;
```
```
ImageChannelValues MSE(const ImageChannelDesc &desc, const Image &ref,
                       Image *mseImage = nullptr) const;
```
```
ImageChannelValues MRSE(const ImageChannelDesc &desc, const Image &ref,
                        Image *mrseImage = nullptr) const;
```
#parec[
  Finally, `GetSamplingDistribution()` returns a 2D array of scalar
  weights for use in importance sampling. The weights are not normalized,
  but are suitable to be directly passed to the
  #link("../Sampling_Algorithms/Sampling_Multidimensional_Functions.html#PiecewiseConstant2D")[PiecewiseConstant2D]
  class’s constructor. The caller can optionally specify the domain of the
  image as well as a function that returns a change of variables factor if
  the final sampling domain is not uniform and over \[0, 1\]^2. This
  factor is then included in the sampling distribution.

][
  最后，`GetSamplingDistribution()`
  返回一个未归一化的二维标量权重数组，供直接传给 PiecewiseConstant2D
  类的构造函数使用。调用方还可以可选地指定图像域，以及一个返回变量变换因子（change
  of variables factor）的函数；如果最终采样域不是均匀且在 \[0, 1\]^2
  上，这一因子将并入采样分布。
]

```
template <typename F>
Array2D<Float> GetSamplingDistribution(
    F dxdA, const Bounds2f &domain = Bounds2f(Point2f(0, 0), Point2f(1, 1)),
    Allocator alloc = {});
Array2D<Float> GetSamplingDistribution() {
    return GetSamplingDistribution([](Point2f) { return Float(1); });
}
```

=== Reading and Writing Images
<b.5.3-reading-and-writing-images>

#parec[
  The `Image` Read() method attempts to read an image from the given file.
  It uses the suffix at the end of the filename to determine which image
  file format reader to use.

][
  `Image` 的 Read()
  方法尝试从给定文件读取图像。它使用文件名末尾的后缀来决定使用哪种图像文件格式读取器。
]

```
static ImageAndMetadata Read(std::string filename, Allocator alloc = {},
                             ColorEncoding encoding = nullptr);
```

```
struct ImageAndMetadata {
    Image image;
    ImageMetadata metadata;
};
```
#parec[
  Some image formats can store additional metadata beyond the pixel
  values; `ImageMetadata` is `pbrt`’s container for this information.
  OpenEXR is particularly flexible in this regard: the user is free to add
  arbitrary named metadata using a variety of data types.

][
  一些图像格式可以存储除了像素值之外的额外元数据；`ImageMetadata` 是 pbrt
  用来存放这些信息的容器。OpenEXR
  在这方面特别灵活：用户可以使用各种数据类型自由添加任意命名的元数据。
]

```
pstd::optional<float> renderTimeSeconds;
pstd::optional<SquareMatrix<4>> cameraFromWorld, NDCFromWorld;
pstd::optional<Bounds2i> pixelBounds;
pstd::optional<Point2i> fullResolution;
pstd::optional<int> samplesPerPixel;
pstd::optional<const RGBColorSpace *> colorSpace;
```
#parec[
  The `Write()` method writes an image in one of the supported formats,
  based on the extension of the filename passed to it. It stores as much
  of the provided metadata as possible given the image format used.

][
  Write()
  方法将图像写入到一种受支持的格式之一，具体取决于传入的文件名扩展名。它在所使用的图像格式允许的范围内尽可能多地保留提供的元数据。
]



=== Resizing images

#parec[
  Image resizing involves application of the sampling and reconstruction theory from Chapter 8: we have an image function that has been sampled at one sampling rate, and we would like to reconstruct a continuous image function from the original samples to resample at a new set of sample positions. In this section, we will discuss the Image’s FloatResizeUp() method, which resamples an image to a higher resolution. Because this represents an increase in the sampling rate from the original rate, we do not have to worry about introducing aliasing due to undersampling high-frequency components in this step; we only need to reconstruct and directly resample the new function. Figure B.6 illustrates this task in 1D.
][

]

#parec[
  Figure B.6: To increase an image’s resolution, the Image class performs
  two 1D resampling steps with a separable reconstruction filter. (a) A 1D
  function reconstructed from four samples, denoted by dots. (b) To
  represent the same image function with more samples, we only need to
  reconstruct the continuous function and evaluate it at the new
  positions.

][
  图 B.6：为了提高图像分辨率，Image
  类执行两步一维重采样，采用可分离重建滤核。 (a)
  由四个样本重构的一维函数，用点表示。 (b)
  为用更多样本表示相同的图像函数，我们只需重构连续函数并在新位置处对其进行采样。
]

#parec[
  A separable reconstruction filter is used for this task; recall from
  Section 8.8 that separable filters can be written as the product of 1D
  filters: $f (x , y) = f (x) f (y)$. One advantage of a separable filter
  is that if we are using one to resample an image from one resolution
  $(x , y)$ to another $(x prime , y prime)$, then we can implement the
  resampling as two 1D resampling steps, first resampling in $x$ to create
  an image of resolution $(x prime , y)$ and then resampling that image to
  create the final image of resolution $(x prime , y prime)$. Resampling
  the image via two 1D steps in this manner simplifies implementation and
  makes the number of pixels accessed for each pixel in the final image a
  linear function of the filter width, rather than a quadratic one.

][
  一个可分离重建滤核用于此任务；回顾第8.8节，可分离重建滤核可以写成 1D
  滤波核的乘积： f(x, y) = f(x)
  f(y)。可分离重建滤核的一个优点是：如果我们使用它对图像进行从一个分辨率
  (x, y) 到另一个分辨率 (x’, y’)
  的重采样，可以将重采样实现为两个一维重采样步骤，首先在 x
  方向重采样以创建分辨率为 (x’, y)
  的图像，然后再对该图像进行重采样以创建最终分辨率为 (x’, y’)
  的图像。通过这种两步的一维重采样方式，简化了实现，并使最终图像中每个像素所访问的像素数量成为滤核宽度的线性函数，而不是二次函数。
]

#parec[
  Reconstructing the original image function and sampling it at a new
  pixel’s position are mathematically equivalent to centering the
  reconstruction filter kernel at the new pixel’s position and weighting
  the nearby pixels in the original image appropriately. Thus, each new
  pixel is a weighted average of a small number of pixels in the original
  image.

][
  重建原始图像函数并在新像素的位置对其进行采样，在数学上等价于将 center
  变量所表示的重建滤核以新像素的位置居中，并对原始图像中的邻近像素进行相应加权。因此，每个新像素都是原始图像中少数像素的加权平均。
]

#parec[
  The Image::ResampleWeights() method utility determines which original
  pixels contribute to each new pixel and what the values are of the
  contribution weights for each new pixel. It returns the values in an
  array of ResampleWeight structures for all the pixels in a 1D row or
  column of the image. Because this information is the same for all rows
  of the image when resampling in x and all columns when resampling in y,
  it is more efficient to compute it once for each of the two passes and
  then reuse it many times for each one.

][
  Image::ResampleWeights()
  方法用于确定哪些原始像素对每个新像素有贡献，以及每个新像素的权重数值。它以一个
  ResampleWeight 结构的数组返回图像中一个 1D
  行或列的所有像素的权重。由于在 x
  方向重采样时该信息对整幅图像的所有行都是相同的；在 y
  方向重采样时对所有列亦然，因此对这两个传递中的每一个只计算一次并在后续使用中重复利用会更高效。
]

#parec[
  For the reconstruction filter used here, no more than four of the
  original pixels will contribute to each new pixel after resizing, so
  ResampleWeight only needs to hold four weights. Because the four pixels
  are contiguous, we only store the offset to the first one.

][
  对于这里使用的可分离重建滤核，在调整大小后，每个新像素最多只有四个原始像素对其产生贡献，因此
  ResampleWeight
  结构只需要存储四个权重。由于这四个像素是相邻的，我们只存储到首个像素的偏移量。
]

```
struct ResampleWeight {
    int firstPixel;
    Float weight[4];
};
```
```
std::vector<ResampleWeight> Image::ResampleWeights(int oldRes, int newRes) {
    std::vector<ResampleWeight> wt(newRes);
    Float filterRadius = 2, tau = 2;
    for (int i = 0; i < newRes; ++i) {
        <<Compute image resampling weights for ith pixel>>
        <<Normalize filter weights for pixel resampling>>
    }
    return wt;
}
```

#parec[
  Here is another instance where it is important to distinguish between discrete and continuous pixel coordinates. For each pixel in the resampled image, this function starts by computing its continuous coordinates in terms of the source image's pixel coordinates. This value is stored in center, because it is the center of the reconstruction filter for the new pixel. Next, it is necessary to find the offset to the first pixel that contributes to the new pixel. This is a slightly tricky calculation—in particular subtracting the filter width to find the start of the filter's nonzero range, it is necessary to add an extra $0.5$ offset to the continuous coordinate before taking the floor to find the discrete coordinate. Figure B.7 illustrates why this offset is needed.
][
  这里是另一个需要区分离散像素坐标与连续像素坐标的实例。对于重采样图像中的每个像素，该函数先在源图像像素坐标意义上计算其连续坐标。该中心值存储在 center 变量中，因为它表示新像素的重建滤核的中心。接下来，需要找到对新像素有贡献的第一个像素的偏移量。这是一个稍微棘手的计算——在减去滤核半径以找到滤核非零区间的起点时，必须在连续坐标上再加一个额外的 0.5 的偏移，然后再取整得到离散像素坐标。图 B.7 说明了为何需要这个偏移。


]

#parec[
  Figure B.7: The computation to find the first pixel inside a reconstruction filter's support is slightly tricky. Consider a filter centered around continuous coordinate 2.75 with radius 2, as shown here. The filter's support covers the range [0.75, 4.75], although pixel zero is outside the filter's support: adding $0.5$ to the lower end before taking the floor to find the discrete pixel gives the correct starting pixel, number one.
][

  图 B.7：在重建滤核的支撑内找到第一个像素的计算有点棘手。考虑一个以连续坐标 2.75 为中心、半径为 2 的滤核，如此处所示。滤核的支撑覆盖区间 [0.75, 4.75]，尽管像素零在滤核支撑之外：在取整以找到离散像素之前向下端加 0.5 可得到正确的起始像素，即第一号像素。

]

#parec[
  Starting from that first contributing pixel, this function loops over four pixels, computing each one's offset to the center of the filter kernel and the corresponding filter weight.
][
  从那一个贡献像素开始，该函数对四个像素进行循环，计算每个像素到滤核中心的偏移量以及相应的滤波权重。


]

```cpp
Float center = (i + .5f) * oldRes / newRes;
wt[i].firstPixel = pstd::floor((center - filterRadius) + 0.5f);
for (int j = 0; j < 4; ++j) {
    Float pos = wt[i].firstPixel + j + .5f;
    wt[i].weight[j] = WindowedSinc(pos - center, filterRadius, tau);
}
```

#parec[
  The four filter weights generally do not sum to one. Therefore, to ensure that the resampled image will not be any brighter or darker than the original image, the weights are normalized here.
][
  这四个滤波权重通常并不和为 1。因此，为了确保重采样后的图像不会比原始图像更亮或更暗，这里对权重进行归一化。


]
```cpp
Float invSumWts = 1 / (wt[i].weight[0] + wt[i].weight[1] +
                       wt[i].weight[2] + wt[i].weight[3]);
for (int j = 0; j < 4; ++j)
    wt[i].weight[j] *= invSumWts;
```

#parec[
  Given ResampleWeights(), we can continue to FloatResizeUp(), which resizes an image to a higher resolution and returns the result, with pixels stored as Float s in memory, regardless of the input image format.
][
  给定 ResampleWeights()，我们就可以继续执行 FloatResizeUp()，它将图像的分辨率提升到更高的分辨率并返回结果，像素在内存中以 Float 类型存储，与输入图像格式无关。


]
```cpp
Image Image::FloatResizeUp(Point2i newRes, WrapMode2D wrapMode) const {
    Image resampledImage(PixelFormat::Float, newRes, channelNames);
    // Compute x and y resampling weights for image resizing
    // Resize image in parallel, working by tiles
    return resampledImage;
}
```

```cpp
std::vector<ResampleWeight> xWeights, yWeights;
xWeights = ResampleWeights(resolution[0], newRes[0]);
yWeights = ResampleWeights(resolution[1], newRes[1]);
```

#parec[
  Given filter weights, the image is resized in parallel, where threads work on tiles of the output image. Although this parallelism scheme leads to some redundant work among threads from the need to compute extra pixel values at the boundaries of tiles, it has the advantage that the second filtering operation in $y$ has a more compact memory access pattern, which gives a performance benefit from better cache coherence.
][
  给定滤波核宽度后，图像就以并行方式进行重采样，线程在输出图像的瓦片上工作。尽管这种并行化方案在边界处需要计算额外像素值，因此会导致线程之间存在一些重复工作，但它的优点是，在 y 方向的第二次滤波操作具有更紧凑的内存访问模式，从而通过更好的缓存一致性带来性能提升。


]
```cpp
ParallelFor2D(Bounds2i({0, 0}, newRes), [&](Bounds2i outExtent) {
    <<Determine extent in source image and copy pixel values to inBuf>>
    <<Resize image in the x dimension>>
    <<Resize image in the y dimension>>
    <<Copy resampled image pixels out into resampledImage>>
});
```

#parec[
  The first step copies all the pixel values that will be needed from the source image to compute the pixels in outExtent into a local buffer, inBuf. There are two reasons for doing this (versus accessing pixel channel values as needed from the input image): first, CopyRectOut() is generally more efficient than accessing the pixel channel values individually since not only are boundary conditions handled just once, but any necessary format conversion to Float is also done once for each pixel channel and in bulk. Second, the pixel channel values that will be accessed for subsequent filtering computations end up being contiguous in memory, which also improves cache coherence.
][
  第一步将从源图像中复制所有需要用于计算 outExtent 中像素的像素值到本地缓冲区 inBuf。这样做有两个原因（相对于按需从输入图像读取像素值）：第一，CopyRectOut() 通常比逐像素访问像素值更高效，因为边界条件仅处理一次，且对每个像素值所需的 Float 表示转换也一次性完成。第二，随后的滤波计算中将访问的像素值在内存中最终会是连续的，这也改善了缓存一致性。


]
```cpp
Bounds2i inExtent(Point2i(xWeights[outExtent.pMin.x].firstPixel,
                          yWeights[outExtent.pMin.y].firstPixel),
                  Point2i(xWeights[outExtent.pMax.x - 1].firstPixel + 4,
                          yWeights[outExtent.pMax.y - 1].firstPixel + 4));
std::vector<float> inBuf(NChannels() * inExtent.Area());
CopyRectOut(inExtent, pstd::span<float>(inBuf), wrapMode);
```

#parec[
  After allocating a temporary buffer for the $x$-resampled image, the following loops iterate over all its pixels to compute their resampled channel values.
][
  在为 $x$ 方向重采样后的图像分配一个临时缓冲区后，下面的循环会遍历它的所有像素，以计算它们重采样后的通道值。
]

```
<<Compute image extents and allocate xBuf>>
int xBufOffset = 0;
for (int yOut = inExtent.pMin.y; yOut < inExtent.pMax.y; ++yOut) {
    for (int xOut = outExtent.pMin.x; xOut < outExtent.pMax.x; ++xOut) {
        <<Resample image pixel (xOut, yOut)>>
    }
}

```
#parec[
  The result of the $x$ resampling step will be stored in `xBuf`. Note
  that it is necessary to perform the $x$-resampling across all the
  scanlines in inExtent’s $y$ range, as the $x$-resampled instances of
  them will be needed for the $y$ resampling step.

][
  x 方向的重采样结果存放于 `xBuf`。需要对 inExtent 的整个 y
  范围内的扫描线进行 x 方向重采样，因为在后续的 y 方向重采样中需要这些 x
  方向的结果。
]

```
int nxOut = outExtent.pMax.x - outExtent.pMin.x;
int nyOut = outExtent.pMax.y - outExtent.pMin.y;
int nxIn = inExtent.pMax.x - inExtent.pMin.x;
int nyIn = inExtent.pMax.y - inExtent.pMin.y;
std::vector<float> xBuf(NChannels() * nyIn * nxOut);

```
#parec[
  Once all the values are lined up, the actual resampling operation is
  straightforward — effectively just the inner product of the normalized
  filter weights and pixel channel values.

][
  一旦所有数值对齐，实际的重采样操作就很直接——实质上只是归一化滤波权重与像素通道值的内积。
]

```
const ResampleWeight & rsw = xWeights[xOut];
<<Compute inOffset into inBuf for (xOut, yOut)>>
for (int c = 0; c < NChannels(); ++c, ++xBufOffset, ++inOffset)
    xBuf[xBufOffset] = rsw.weight[0] * inBuf[inOffset] +
                       rsw.weight[1] * inBuf[inOffset + NChannels()] +
                       rsw.weight[2] * inBuf[inOffset + 2 * NChannels()] +
                       rsw.weight[3] * inBuf[inOffset + 3 * NChannels()];

```
#parec[
  The $(x O u t , y O u t)$ pixel coordinate is with respect to the
  overall final resampled image. However, only the necessary input pixels
  for the tile have been copied to `inBuf`. Therefore, some reindexing is
  necessary to compute the offset into `inBuf` that corresponds to the
  first pixel that will be accessed to compute $(x O u t , y O u t)$’s
  $x$-resized value.

][
  像素坐标 $(x O u t , y O u t)$
  相对于最终重采样后的整体图像而言。然而，只有该瓦块所需的输入像素被拷贝到
  inBuf，因此需要进行重新索引，以计算在 inBuf 中与计算
  $(x O u t , y O u t)$ 的 x 方向重采样所需的第一个像素的偏移量。
]

```
int xIn = rsw.firstPixel - inExtent.pMin.x;
int yIn = yOut - inExtent.pMin.y;
int inOffset = NChannels() * (xIn + yIn * nxIn);

```
#parec[
  The fragment \<\<Resize image in the $y$ dimension\>\> follows a similar
  approach but filters along $y$, going from `xBuf` into `outBuf`. It is
  therefore not included here.

][
  片段 \<\> 的采用类似的方法，但沿着 y 方向进行滤波，从 xBuf 进入到
  outBuf。因此，这里不包含该部分。
]

#parec[
  Given resampled pixels for outExtent, they can be copied in bulk to the
  output image via `CopyRectIn()`.

][
  给定对 outExtent 重采样后的像素，可以通过 CopyRectIn()
  一次性复制到输出图像中。
]

```
resampledImage.CopyRectIn(outExtent, outBuf);

```
== Image Pyramids
<image-pyramids>

#parec[

  The GeneratePyramid() method generates an image pyramid, which stores a source image, first resized if necessary to have power-of-two resolution in each dimension, at its base.  Higher levels of the pyramid are successively found by downsampling the next lower level by a factor of two in each dimension.  Image pyramids are widely used for accelerating image filtering operations and are a cornerstone of MIP mapping, which is implemented in pbrt's #link("../Textures_and_Materials/Image_Texture.html#MIPMap")[MIPMap] class, defined in Section 10.4.3.

][
  GeneratePyramid() 方法会生成一个图像金字塔，其底层存放源图像，在必要时先将每个方向的分辨率调整为 2 的幂次分辨率，然后位于金字塔的底部。较高层通过在每个方向将下一层下采样至原来的一半来依次得到。图像金字塔被广泛用于加速图像滤波操作，是 MIP 映射的基石，MIPMap 类在 pbrt 的 #link("../Textures_and_Materials/Image_Texture.html#MIPMap")[MIPMap] 中实现，定义在第 10.4.3 节。
]

```
pstd::vector<Image> Image::GeneratePyramid(Image image, WrapMode2D wrapMode,
                                           Allocator alloc) {
    PixelFormat origFormat = image.format;
    int nChannels = image.NChannels();
    ColorEncoding origEncoding = image.encoding;
    <<Prepare image for building pyramid>>
    <<Initialize levels of pyramid from image>>
    <<Initialize top level of pyramid and return it>>
}

```
#parec[
  Implementation of an image pyramid is easier if the resolution of the
  original image is an exact power of two in each direction; this ensures
  that there is a direct relationship between the level of the pyramid and
  the number of texels at that level. If the user has provided an image
  where the resolution in one or both of the dimensions is not a power of
  two, then the GeneratePyramid() method calls FloatResizeUp() to resize
  the image up to the next power-of-two resolution greater than the
  original resolution before constructing the pyramid. (Exercise B.1 at
  the end of the chapter describes an approach for building image pyramids
  with non-power-of-two resolutions.)

][
  实现图像金字塔更容易的情况是原始图像在每个方向上的分辨率恰好是 2
  的幂次分辨率；这确保了金字塔的级别与该级别的纹素数量之间存在直接关系。如果用户提供的图像在一个或两个维度上的分辨率不是
  2 的幂，则 GeneratePyramid() 方法会调用
  FloatResizeUp()，在构建金字塔之前将图像重采样到大于原始分辨率的下一个 2
  的幂次分辨率。（本章末的练习 B.1 描述了一种在非 2
  的幂分辨率下构建图像金字塔的方法。）
]

#parec[
  Otherwise, if the provided image does not use 32-bit floats for its in-memory format, it is converted to that representation.  This helps avoid errors in the image pyramid due to insufficient precision being used for the inputs to the filtering computations.  (In the end, however, the returned pyramid will have images in the format of the original image so that memory use is not unnecessarily increased.)


][
  否则，如果提供的图像在内存中的格式不是 32 位浮点数，则将其转换为该表示形式。这有助于避免在进行滤波计算输入时因精度不足而在图像金字塔中产生的错误。（但最终返回的金字塔将具有与原始图像相同的图像格式，以避免不必要的内存增加。）


]

#parec[
  These two operations motivate taking the Image as a parameter to a static method, as GeneratePyramid() is, rather than being a non-static member function.  Thus, a new image can easily be reassigned to image as necessary.

][
  这两步操作促使将 Image 作为静态方法的参数传入，而 GeneratePyramid() 作为静态方法来实现，而不是作为类的非静态成员函数。因此，可以在需要时轻松地将新图像重新赋值给 image。


]


```
if (!IsPowerOf2(image.resolution[0]) || !IsPowerOf2(image.resolution[1]))
    image = image.FloatResizeUp(Point2i(RoundUpPow2(image.resolution[0]),
                                        RoundUpPow2(image.resolution[1])),
                                        wrapMode);
else if (!Is32Bit(image.format))
    image = image.ConvertToFormat(PixelFormat::Float);

```
#parec[
  Once we have a floating-point image with resolutions that are powers of
  two, the levels of the MIP map can be initialized, starting from the
  bottom (finest) level. Each higher level is found by filtering the
  texels from the previous level.

][
  一旦得到分辨率为 2 的幂的浮点图像，就可以从底层（最细）级别开始初始化
  MIP 映射的各级。每一个更高的级别都是通过对上一层的纹素进行滤波来得到。
]

```
int nLevels = 1 + Log2Int(std::max(image.resolution[0],
                               image.resolution[1]));
pstd::vector<Image> pyramid(alloc);
for (int i = 0; i < nLevels - 1; ++i) {
    <<Initialize i plus 1st level from ith level and copy ith into pyramid>>
}

```
#parec[
  Each time through this loop, image starts out as the already-filtered
  image for the $i$th level that will be downsampled to generate the image
  for the $(i + 1)$st level. A new entry is added to the image pyramid for
  image, though using the original pixel format.

][
  每次通过这个循环，image 都以已经对第 i 级进行滤波后将被下采样以生成第
  i+1
  级图像的状态开始。向图像金字塔中添加一个新条目用于该图像，尽管使用的是原始像素格式。
]

```
pyramid.push_back(Image(origFormat, image.resolution, image.channelNames,
                        origEncoding, alloc));
<<Initialize nextImage for i plus 1st level>>
<<Compute offsets from pixels to the 4 pixels used for downsampling>>
<<Downsample image to create next level and update pyramid>>

```
#parec[
  For non-square images, the resolution in one direction must be clamped
  to 1 for the upper levels of the image pyramid, where there is still
  downsampling to do in the larger of the two resolutions. This is handled
  by the following std::max() calls:

][
  对于非方形图像，在金字塔的上层，在较大分辨率方向上仍需下采样，因此其中一个方向的分辨率必须被限定为
  1。以下的 std::max() 调用处理了这一点：
]

```
Point2i nextResolution(std::max(1, image.resolution[0] / 2),
                       std::max(1, image.resolution[1] / 2));
Image nextImage(image.format, nextResolution, image.channelNames,
                origEncoding);

```
#parec[
  GeneratePyramid() uses a simple box filter to average four texels from
  the previous level to find the value at the current texel. Using the
  Lanczos filter here would give a slightly better result for this
  computation, although this modification is left for Exercise B.2 at the
  end of the chapter.

][
  GeneratePyramid()
  使用一个简单的盒子滤波来平均前一层的四个纹素以找到当前纹理的值。使用
  Lanczos 滤波器在这里会给出略微更好的结果，尽管这一修改留给本章末的练习
  B.2。
]

#parec[
  With the box filter, each pixel $(x , y)$ in nextImage is given by the
  average of the pixels $(2 x , 2 y)$, $(2 x + 1 , 2 y)$,
  $(2 x , 2 y + 1)$, and $(2 x + 1 , 2 y + 1)$. Here we compute the
  corresponding offsets from a pixel in the source image to those four
  pixels; doing this here saves some math in pixel indexing when
  downsampling. These offsets are based on the scanline-based layout of
  Image data in memory; referring to the implementation of
  Image::PixelOffset() may make their operation more clear.

][
  如果采用盒子滤波，nextImage 的每个像素 (x, y) 由前一层的像素 (2x,
  2y)、(2x+1, 2y)、(2x, 2y+1) 与 (2x+1, 2y+1)
  的平均值给出。这里我们计算源图像到这四个纹素的相应偏移量；在下采样时在这里完成这一步可以节省一些像素索引中的运算。这些偏移量基于在内存中
  Image 数据的逐行布局；参考 Image::PixelOffset()
  的实现可以使其工作原理更清晰。
]



#parec[
  Here is also a good chance to handle images with single pixel resolution
  in one dimension; in that case the offsets are set so that valid pixels
  are used twice, and the downsampling loop can be written to always
  assume four values.

][
  在某一维度上分辨率为1的图像也提供了一个处理的好机会。在这种情况下，偏移量被设定为让有效像素被使用两次，降采样循环因此可以始终基于四个像素值进行运算。
]

```
int srcDeltas[4] = {0, nChannels, nChannels * image.resolution[0],
                    nChannels * (image.resolution[0] + 1)};
if (image.resolution[0] == 1) {
    srcDeltas[1] = 0;
    srcDeltas[3] -= nChannels;
}
if (image.resolution[1] == 1) {
    srcDeltas[2] = 0;
    srcDeltas[3] -= nChannels * image.resolution[0];
}
```
#parec[
  The work for the current level is performed in parallel since each
  output pixel’s value is independent of the others. For scenes with many
  textures, MIP map generation may be a meaningful amount of pbrt’s
  startup time, so it is worthwhile to try to optimize this work done by
  this method so that rendering can begin more quickly. When the work for
  each level is finished, the image for the next level is assigned to
  image so that the loop can proceed once again.

][
  当前层的工作是并行执行的，因为每个输出像素的值彼此独立、互不依赖。对于纹理较多的场景，MIP
  映射的生成可能是 PBRT
  启动时间中的一个显著部分，因此应考虑优化这部分工作，以便更早开始渲染。当该层工作完成后，下一层的图像被赋给
  image，以便循环继续进行。
]

```
ParallelFor(0, nextResolution[1], [&](int64_t y) {
    <<Loop over pixels in scanline y and downsample for the next pyramid level>>
    <<Copy two scanlines from image out to its pyramid level>>
});
image = std::move(nextImage);
```
#parec[
  The following fragment computes a scanline’s worth of downsampled pixel
  values in nextImage. It makes extensive use of the fact that the
  channels for each pixel are laid out consecutively in memory and that
  pixels are stored in scanline order in memory. Thus, it can compute
  offsets into the pixel arrays for the y scanline starting at x equals 0
  and efficiently incrementally update them for each image channel and
  each pixel. Note also that the offsets to the neighboring pixels from
  srcDeltas are used to efficiently find the necessary pixel values from
  image.

][
  以下片段在 nextImage
  中计算一条扫描线所对应的降采样像素值。它大量利用了每个像素的通道在内存中按顺序排列、像素在内存中按扫描线顺序存储的事实。因此，它能够计算从
  x 等于 0 开始的 y
  扫线的像素数组的偏移量，并对每个图像通道和每个像素高效地进行增量更新。另请注意，来自
  srcDeltas 的相邻像素的偏移量被用来高效地在 image 中找到所需的像素值。
]

```
int srcOffset = image.PixelOffset(Point2i(0, 2 * int(y)));
int nextOffset = nextImage.PixelOffset(Point2i(0, int(y)));
for (int x = 0; x < nextResolution[0]; ++x, srcOffset += nChannels)
    for (int c = 0; c < nChannels; ++c, ++srcOffset, ++nextOffset)
        nextImage.p32[nextOffset] =
            (image.p32[srcOffset] + image.p32[srcOffset + srcDeltas[1]] +
             image.p32[srcOffset + srcDeltas[2]] +
             image.p32[srcOffset + srcDeltas[3]]) / 4;
```
#parec[
  We will take advantage of the fact that processing is happening in
  parallel here to also copy pixel values from image into their place in
  the pyramid. Doing so here has the added benefit that the pixel values
  should already be in the cache from their use as inputs to the
  downsampling computation.

][
  我们将利用这里并行处理的事实，同时把来自 image
  的像素值复制到金字塔中的相应位置。这么做还有一个额外好处：像素值在用作降采样计算的输入时，应该已经缓存在缓存中。
]

#parec[
  Because the ParallelFor() loop is over scanlines in the lower-resolution
  image, two scanlines from image are copied here except in the edge case
  of a single-scanline-high image from a non-square-input image. The Image
  CopyRectIn() method copies the pixels inside the provided bounds, taking
  care of converting them to the format of the destination image pixels if
  necessary.

][
  因为 ParallelFor() 循环是在低分辨率图像的扫描线上进行的，这里会复制来自
  image
  的两条扫描线，除了来自非方形输入图像的一条单一扫描线高的边缘情况。Image
  CopyRectIn()
  方法会在提供的边界内复制像素，并在必要时将它们转换为目标图像像素的格式。
]

```
int yStart = 2 * y;
int yEnd = std::min(2 * int(y) + 2, image.resolution[1]);
int offset = image.PixelOffset({0, yStart});
size_t count = (yEnd - yStart) * nChannels * image.resolution[0];
pyramid[i].CopyRectIn(Bounds2i({0, yStart}, {image.resolution[0], yEnd}),
                pstd::span<const float>(image.p32.data() + offset, count));
```
#parec[
  After the loop terminates, we are left with a $1 times 1$ image to copy
  into the top level of the image pyramid before it can be returned.

][
  循环结束后，我们得到一个 1 × 1
  的图像，在返回之前要把它拷贝到图像金字塔的顶层。
]

```
pyramid.push_back(Image(origFormat, {1, 1}, image.channelNames,
                        origEncoding, alloc));
pyramid[nLevels - 1].CopyRectIn(Bounds2i({0, 0}, {1, 1}),
                pstd::span<const float>(image.p32.data(), nChannels));
return pyramid;
```


=== Color encodings

#parec[
  Color spaces often define a transfer function that is used to encode color component values that are stored in the color space.  Transfer functions date to cathode ray tube (CRT) displays, which had a nonlinear relationship between display intensity and the voltage V of the electron gun, which was modeled with a gamma curve $V^gamma$.  With CRTs, doubling the RGB color components stored at a pixel did not lead to a doubling of displayed intensity, an undesirable nonlinearity at the end of a rendering process that is built on an assumption of linearity. It was therefore necessary to apply gamma correction to image pixels using the inverse of the gamma curve so that the image on the screen had a linear relationship between intensity and pixel values.
][
  颜色空间通常定义一个传输函数，用于对存储在颜色空间中的颜色分量值进行编码。传输函数可以追溯到阴极射线管（CRT）显示器，后者在显示强度与电子枪的电压 V 之间存在非线性关系，这种关系用伽马曲线 V^γ 建模。对于 CRT，存储在像素中的 RGB 颜色分量加倍并不会导致显示强度成倍增加，这是在一个建立在线性关系假设之上的渲染过程结束处产生的一种不理想的非线性。因此，需要对图像像素应用伽马校正，使用伽马曲线的逆来使屏幕上的图像强度与像素值之间具有线性关系。


]

#parec[
  While modern displays no longer use electron guns, it is still worthwhile to use a nonlinear mapping with colors that are stored in quantized representations (e.g., 8-bit pixel components).  One reason to do so is suggested by Weber's law, which is based on the observation that an increase of 1% of a stimulus value (e.g., displayed color) is generally required before a human observer notices a change—this is the just noticeable difference.  In turn, a pixel encoding that allocates multiple values to invisible differences is inefficient, at least for display.  Weber's law also suggests a power law-based encoding, along the lines of gamma correction.
][
  虽然现代显示器不再使用电子枪，但对以量化表示存储的颜色进行非线性映射仍然是值得的（例如 8 位像素分量）。其一个原因来自韦伯定律：观察者通常需要刺激值增加约 1% 才会察觉到变化——这是“恰好能察觉的差异”。反过来，将多个值分配给不可见的差异的像素编码在显示方面是低效的。韦伯定律还提示一种基于幂律的编码，与伽马校正类似。


]

#parec[
  `pbrt` does most of its computation using floating-point color values, for which there is no need to apply a color encoding.  (And indeed, such an encoding would need to be inverted any time a computation was performed with such a color value.)  However, it is necessary to support color encodings to decode color values from non-floating-point image formats like PNG as well as to encode them before writing images in such formats.
][
  pbrt 大部分计算使用浮点颜色值，因此无需应用颜色编码；但为了从非浮点图像格式（如 PNG）解码颜色值，以及在将图像写入此类格式之前进行编码，仍有必要支持颜色编码。


]

#parec[
  The `ColorEncoding` class defines the ColorEncoding interface, which handles both encoding and decoding color in various ways.
][
  ColorEncoding 类定义了颜色编码接口，它以多种方式处理颜色的编码和解码。


]


```
class ColorEncoding
    : public TaggedPointer<LinearColorEncoding, sRGBColorEncoding,
                           GammaColorEncoding> {
  public:
    <<ColorEncoding Interface>>
};
```
#parec[
  The two main methods that `ColorEncoding`s must provide are
  `ToLinear()`, which takes a set of encoded 8-bit color values and
  converts them to linear Float s, and `FromLinear()`, which does the
  reverse. Both of these take buffers of potentially many values to
  convert at once, which saves dynamic dispatch overhead compared to
  invoking them for each value independently.

][
  `ColorEncoding` 必须提供的两个主要方法是 ToLinear()，它接受一组编码后的
  8 位颜色值并将它们转换为线性浮点数值，以及
  FromLinear()，执行相反的转换。两者都接受可能包含大量值的缓冲区，以一次性转换，从而比逐个值独立调用时减少动态分派开销。
]

```
void ToLinear(pstd::span<const uint8_t> vin,
              pstd::span<Float> vout) const;
void FromLinear(pstd::span<const Float> vin,
                pstd::span<uint8_t> vout) const;
```
#parec[
  It is sometimes useful to decode values with greater than 8-bit
  precision (e.g., some image formats like PNG are able to store 16-bit
  color channels). Such cases are handled by `ToFloatLinear()`, which
  takes a single encoded value stored as a `Float` and decodes it.

][
  有时对大于 8 位精度的值进行解码是有用的（例如，一些图像格式如 PNG
  可以存储 16 位颜色通道）。这些情况由 ToFloatLinear() 处理，它接受存储为
  Float 的单个编码值并进行解码。
]

```
Float ToFloatLinear(Float v) const;
```
#parec[
  The `LinearColorEncoding` class is trivial: it divides 8-bit values by
  255 to convert them to `Float`s and does the reverse. `pbrt` also
  provides `GammaColorEncoding`, which applies a plain gamma curve of
  specified exponent. Neither of these are included in the text here.

][
  `LinearColorEncoding` 类很简单：它将 8 位值除以 255 以转换为
  Float，然后再反向转换回去。pbrt 还提供
  GammaColorEncoding，它应用指定指数的纯伽马曲线。这两者在本文中都没有给出实现。
]

#parec[
  sRGBColorEncoding implements the encoding specified by the sRGB color
  space. It combines a linear segment for small values with a power curve
  for larger ones.

][
  sRGBColorEncoding 实现了由 sRGB
  颜色空间规定的编码。它将一个线性段与对较大值使用的幂律曲线相结合。
]


```
class sRGBColorEncoding {
  public:
    <<sRGBColorEncoding Public Methods>>
};
```
#parec[
  A linear value x is converted to an sRGB-encoded value x\_e by

][
  线性值 x 被转换为 sRGB 编码值 x\_e，其定义如下：
]
*TODO*


#parec[
  The work of conversion is handled by the `LinearToSRGB8()` function,
  which is not included here. It uses a rational polynomial approximation
  to avoid the cost of a `std::pow()` call in computing the encoded value.

][
  该转换的工作由 LinearToSRGB8()
  函数处理，此处未给出具体实现细节，它使用有理多项式近似来避免在计算编码值时进行
  std::pow() 调用的成本。
]

```
void sRGBColorEncoding::FromLinear(pstd::span<const Float> vin,
                                   pstd::span<uint8_t> vout) const {
    for (size_t i = 0; i < vin.size(); ++i)
        vout[i] = LinearToSRGB8(vin[i]);
}
```
#parec[
  The inverse transformation is

][
  逆变换公式如下：
]

x =
cases(frac(x_e, 12.92) comma & x_e <= 0.04045,
(frac(x_e + 0.055, 1.055))^2.4 comma & "otherwise.")


#parec[
  For 8-bit encoded values, the `SRGB8ToLinear()` function uses a
  precomputed 256-entry lookup table. A separate `SRGBToLinear()` uses a
  rational polynomial approximation for arbitrary floating-point values
  between 0 and 1.

][
  对于8位编码值，`SRGB8ToLinear()` 函数使用一个长度为 256 的查找表。另一个
  `SRGBToLinear()` 对位于 \[0,1\] 区间内的任意浮点值使用有理多项式逼近。
]

```
void sRGBColorEncoding::ToLinear(pstd::span<const uint8_t> vin,
                                 pstd::span<Float> vout) const {
    for (size_t i = 0; i < vin.size(); ++i)
        vout[i] = SRGB8ToLinear(vin[i]);
}
```
#parec[
  The linear and sRGB encodings are widely used in the system, so they are
  made available via the `static` member variables in the `ColorEncoding`
  class.

][
  线性编码和 sRGB 编码在系统中被广泛使用，因此通过 ColorEncoding
  类的静态成员变量对外提供。
]

```
static ColorEncoding Linear;
static ColorEncoding sRGB;
```
