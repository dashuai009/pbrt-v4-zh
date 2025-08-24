#import "../template.typ": parec, translator

== System startup, cleanup, and options

#parec[
  Two structures that are defined in the `options.h` header represent various user-specified options that are generally not part of the scene description file but are instead specified using command-line arguments to `pbrt`. `pbrt`'s `main()` function allocates the structure and then overrides its default values as appropriate.
][
  在 `options.h` 头文件中定义了两个结构体，用来表示用户指定的各种选项。这些选项通常不属于场景描述文件的一部分，而是通过 `pbrt` 的命令行参数指定的。`pbrt` 的 `main()` 函数会分配该结构体，并根据需要覆盖其中的默认值。]

#parec[
  `BasicPBRTOptions` stores the options that are used in both the CPU and GPU rendering pipelines. How most of them are used should be self-evident, though `seed` deserves note: any time an RNG is initialized in `pbrt`, the seed value in the options should be incorporated in the seed passed to its constructor. In this way, the renderer will generate independent images if the user specifies different `--seed` values using command-line arguments.
][
  `BasicPBRTOptions` 保存了同时用于 CPU 和 GPU 渲染管线的选项。大部分选项的用途都不言自明，但其中的 `seed` 值值得注意：每当 `pbrt` 初始化一个随机数生成器（RNG）时，都应该在其构造函数传入的种子中加入该 `seed` 值。这样，如果用户通过命令行参数指定不同的 `--seed` 值，渲染器就会生成相互独立的图像。]


=== BasicPBRTOptions 定义

```cpp
struct BasicPBRTOptions {
    int seed = 0;
    bool quiet = false;
    bool disablePixelJitter = false, disableWavelengthJitter = false;
    bool disableTextureFiltering = false;
    bool forceDiffuse = false;
    bool useGPU = false;
    bool wavefront = false;
    RenderingCoordinateSystem renderingSpace =
        RenderingCoordinateSystem::CameraWorld;
};
```

=== RenderingCoordinateSystem 定义

```cpp
enum class RenderingCoordinateSystem { Camera, CameraWorld, World };
```

#parec[
  The `PBRTOptions` structure, not included here, inherits from `BasicPBRTOptions` and adds a number of additional options that are mostly used when processing the scene description and not during rendering. A number of these options are `std::string`s that are not accessible in GPU code. Splitting the options in this way allows GPU code to access a `BasicPBRTOptions` instance to get the particular option values that are relevant to it.
][
  这里没有展示的 `PBRTOptions` 结构体继承自 `BasicPBRTOptions`，并添加了许多额外的选项，这些选项大多在处理场景描述时使用，而不是在渲染过程中。一些选项是 `std::string` 类型，无法在 GPU 代码中访问。通过这种拆分方式，GPU 代码只需访问 `BasicPBRTOptions` 实例，即可获取与其相关的选项值。]

#parec[
  The options are passed to `InitPBRT()`, which should be called before any of `pbrt`'s other classes or interfaces are used. It handles system-wide initialization and configuration. When rendering completes, `CleanupPBRT()` should be called so that the system can gracefully shut down. Both of these functions are defined in the file `pbrt.cpp`.
][
  这些选项会传递给 `InitPBRT()`，该函数必须在使用 `pbrt` 的任何其他类或接口之前调用。它负责系统范围的初始化与配置。当渲染完成时，应调用 `CleanupPBRT()` 以便系统能够优雅地关闭。这两个函数都定义在 `pbrt.cpp` 文件中。]
=== 初始化与清理函数声明

```cpp
void InitPBRT(const PBRTOptions &opt);
void CleanupPBRT();
```

#parec[
  In code that only runs on the CPU, the options can be accessed via a global variable.
][
  在仅运行于 CPU 的代码中，可以通过一个全局变量来访问这些选项。]

=== 选项全局变量声明

```cpp
extern PBRTOptions *Options;
```

#parec[
  For code that runs on both the CPU and GPU, options must be accessed through the GetOptions() function, which returns a copy of the options that is either stored in CPU or GPU memory, depending on which type of processor the code is executing.
][
  对于同时在 CPU 和 GPU 上运行的代码，必须通过 `GetOptions()` 函数访问选项。该函数返回选项的一个副本，并根据当前代码运行的处理器类型，将其存储在 CPU 或 GPU 内存中。]

=== 选项内联函数

```cpp
const BasicPBRTOptions &GetOptions();
```
