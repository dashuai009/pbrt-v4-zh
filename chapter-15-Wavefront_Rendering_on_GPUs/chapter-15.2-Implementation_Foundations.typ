#import "../template.typ": parec, ez_caption

== Implementation Foundations
<implementation-foundations>


#parec[
  Before we discuss the implementation of the wavefront integrator and the details of its kernels, we will start by discussing some of the lower-level capabilities that it is built upon, as well as the abstractions that we use to hide the details of platform-specific APIs.
][
  在讨论波前积分器的实现及其内核的细节之前，我们将首先讨论一些它所依赖的低级功能，以及我们用来隐藏平台特定API细节的抽象层。
]

=== Execution and Memory Space Specification
<execution-and-memory-space-specification>

#parec[
  If you have perused the `pbrt` source code, you will have noticed that the signatures of many functions include a `PBRT_CPU_GPU`. We have elided all of these from the book text thus far in the interests of avoiding distraction. Now we must pay closer attention to them.
][
  如果你浏览过`pbrt`的源代码，你会注意到许多函数的签名中包含了`PBRT_CPU_GPU`。到目前为止，我们在书中省略了所有这些内容，以避免分散注意力。现在我们必须更加关注它们。
]

#parec[
  When `pbrt` is compiled with GPU support, the compiler must know whether each function in the system is intended for CPU execution only, GPU execution only, or execution on both types of processor. In some cases, a function may only be able to run on one of the two—for example, if it uses low-level functionality that the other type of processor does not support. In other cases, it may be possible for it to run on both, though it may not make sense to do so. For example, an object constructor that does extensive serial processing would be unsuited to the GPU.
][
  当`pbrt`编译为支持GPU时，编译器必须知道系统中的每个函数是仅用于CPU执行，仅用于GPU执行，还是用于两种处理器的执行。在某些情况下，函数可能只能在两者之一上运行——例如，如果它使用了另一种处理器不支持的低级功能。在其他情况下，它可能可以在两者上运行，尽管这样做可能没有意义。例如，一个进行大量串行处理的对象构造函数就不适合在GPU上运行。
]

#parec[
  `PBRT_CPU_GPU` hides the platform-specific details of how these characteristics are indicated. (With CUDA, it turns into a `__host__` `__device__` specifier.) There is also a `PBRT_GPU` macro, which signifies that a function can only be called from GPU code. These macros are all defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`];. If no specifier is provided, a function can only be called from code that is running on the CPU.
][
  `PBRT_CPU_GPU`隐藏了这些特性的指示方式的特定于平台的细节。（在CUDA中，它变成了`__host__` `__device__`说明符。）还有一个`PBRT_GPU`宏，它表示一个函数只能从GPU代码中调用。这些宏都定义在文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`];中。如果没有提供说明符，则函数只能从在CPU上运行的代码中调用。
]

#parec[
  These specifiers can be used with variable declarations as well, to similar effect. `pbrt` only makes occasional use of them for that, mostly using managed memory for such purposes. (There is also a `PBRT_CONST` variable qualifier that is used to define large constant arrays in a way that makes them accessible from both CPU and GPU.)
][
  这些说明符也可以与变量声明一起使用，效果类似。`pbrt`仅偶尔为此使用它们，主要使用托管内存来实现这些目的。（还有一个`PBRT_CONST`变量限定符，用于以一种使其可从CPU和GPU访问的方式定义大型常量数组。）
]

#parec[
  In addition to informing the compiler of which processors to compile functions for, having these specifiers in the signatures of functions allows the compiler to determine whether a function call is valid: a CPU-only function that directly calls a GPU-only function, or vice versa, leads to a compile time error.
][
  除了通知编译器要为哪些处理器编译函数之外，在函数签名中包含这些说明符还允许编译器确定函数调用是否有效：直接调用GPU专用函数的CPU专用函数，或反之，都会导致编译时错误。
]

=== Launching Kernels on the GPU
<launching-kernels-on-the-gpu>


#parec[
  `pbrt` also provides functions that abstract the platform-specific details of launching kernels on the GPU. These are all defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/gpu/util.h")[`gpu/util.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/gpu/util.cpp")[`gpu/util.cpp`];.
][
  `pbrt`还提供了抽象GPU上启动内核的特定于平台的细节的函数。这些都定义在文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/gpu/util.h")[`gpu/util.h`];和#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/gpu/util.cpp")[`gpu/util.cpp`];中。
]

#parec[
  The most important of them is `GPUParallelFor()`, which launches a specified number of GPU threads and invokes the provided kernel function for each one, passing it an index ranging from zero up to the total number of threads. The index values passed always span a contiguous range for all of the threads in a thread group. This is an important property in that, for example, indexing into a `float` array using the index leads to contiguous memory accesses.
][
  其中最重要的是`GPUParallelFor()`，它启动指定数量的GPU线程，并为每个线程调用提供的内核函数，传递一个从零到线程总数的索引。传递的索引值始终在线程组中所有线程的连续范围内。这是一个重要的特性，例如，使用索引对`float`数组进行索引会导致连续的内存访问。
]

#parec[
  This function is the GPU analog to #link("../Utilities/Parallelism.html#ParallelFor")[`ParallelFor()`];, with the differences that it always starts iteration from zero, rather than taking a 1D range, and that it takes a description string that describes the kernel's functionality. Its implementation includes code that tracks the total time each kernel spends executing on the GPU, which makes it possible to print a performance breakdown after rendering completes using the provided description string.
][
  这个函数是#link("../Utilities/Parallelism.html#ParallelFor")[`ParallelFor()`];的GPU对应物，不同之处在于它总是从零开始迭代，而不是采用1D范围，并且它接受一个描述字符串来描述内核的功能。其实现包括跟踪每个内核在GPU上执行的总时间的代码，这使得在渲染完成后可以使用提供的描述字符串打印性能分析。
]

```cpp
template <typename F>
void GPUParallelFor(const char *description, int nItems, F func);
```


#parec[
  Similar to `ParallelFor()`, all the work from one call to `GPUParallelFor()` finishes before any work from a subsequent call to `GPUParallelFor()` begins, and it, too, is also generally used with lambda functions. A simple example of its usage is below: the callback function `func` is invoked with a single integer argument, corresponding to the item index that it is responsible for. Note also that a `PBRT_GPU` specifier is necessary for the lambda function to indicate that it will be invoked from GPU code.
][
  与`ParallelFor()`类似，一次调用`GPUParallelFor()`的所有工作在下一次调用`GPUParallelFor()`的任何工作开始之前完成，并且它通常也与lambda函数一起使用。下面是一个简单的使用示例：回调函数`func`被调用时带有一个整数参数，对应于它负责的项目索引。还要注意，lambda函数需要一个`PBRT_GPU`说明符，以表明它将从GPU代码中调用。
]

```cpp
 float *array = /* allocate managed memory */;
 GPUParallelFor("Initialize array", 100,
                [=] PBRT_GPU (int i) { array[i] = i; });
```
#parec[
  We provide a macro for specifying lambda functions for `GPUParallelFor()` and related functions that adds the `PBRT_GPU` specifier and also hides some platform-system specific details (which are not included in the text here).
][
  我们提供了一个用于`GPUParallelFor()`及相关函数的lambda函数的宏，它添加了`PBRT_GPU`说明符，并隐藏了一些特定于平台系统的细节（这些细节未包含在本文中）。
]

```cpp
#define PBRT_CPU_GPU_LAMBDA(...) [=] PBRT_CPU_GPU (__VA_ARGS__)
```


#parec[
  We do not provide a variant analogous to #link("../Utilities/Parallelism.html#ParallelFor2D")[`ParallelFor2D()`] for iterating over a 2D array, though it would be easy to do so; `pbrt` just has no need for such functionality.
][
  我们没有提供类似于#link("../Utilities/Parallelism.html#ParallelFor2D")[`ParallelFor2D()`];的变体来迭代二维数组，尽管这样做很容易；`pbrt`只是没有这种功能的需求。
]

#parec[
  Although execution is serialized between successive calls to `GPUParallelFor()`, it is important to be aware that the execution of the CPU and GPU are decoupled. When a call to `GPUParallelFor()` returns on the CPU, the corresponding threads on the GPU often will not even have been launched, let alone completed. Work on the GPU proceeds asynchronously. While this execution model thus requires explicit synchronization operations between the two processors, it is important for achieving high performance. Consider the two alternatives illustrated in @fig:cpu-gpu-sync-async ; automatically synchronizing execution of the two processors would mean that only one of them could be running at a given time.
][
  尽管在连续调用`GPUParallelFor()`之间执行是串行化的，但需要注意的是CPU和GPU的执行是解耦的。当`GPUParallelFor()`在CPU上返回时，GPU上的相应线程通常甚至还没有启动，更不用说完成了。GPU上的工作是异步进行的。因此，这种执行模型需要在两个处理器之间进行显式同步操作，这对于实现高性能至关重要。考虑@fig:cpu-gpu-sync-async 中说明的两种替代方案；自动同步两个处理器的执行将意味着在给定时间内只有一个处理器可以运行。
]

#figure(
  image("../pbr-book-website/4ed/Wavefront_Rendering_on_GPUs/pha15f03.svg"),
  caption: [
    #ez_caption[
      Comparison of Synchronous and Asynchronous CPU/GPU Execution.
      (a) If the two processors are synchronous, only one is ever
      executing. The CPU stalls after launching a kernel on the GPU, and then
      the GPU is idle after a kernel finishes until the CPU resumes and
      launches another one. (b) With the asynchronous model, the CPU continues
      execution after launching each kernel and is able to enqueue more of
      them while the GPU is working on earlier ones. In turn, the GPU does not
      need to wait for the next batch of work to do.
    ][
      同步和异步CPU/GPU执行的比较。(a)
      如果两个处理器是同步的，则只有一个在执行。CPU在GPU上启动内核后停滞，然后在内核完成后GPU空闲，直到CPU恢复并启动另一个内核。(b)
      在异步模型中，CPU在启动每个内核后继续执行，并能够在GPU处理早期内核时入队更多的内核。反过来，GPU不需要等待下一批工作。

    ]
  ],
)<cpu-gpu-sync-async>


#parec[
  An implication of this model is that the CPU must be careful about when it reads values from managed memory that were computed on the GPU. For example, if the implementation had code that tried to read the final image immediately after launching the last rendering kernel, it would almost certainly read an incomplete result. We therefore require a mechanism so that the CPU can wait for all the previous kernel launches to complete. This capability is provided by `GPUWait()`. Again, the implementation is not included here, as it is based on platform-specific functionality.
][
  这种模型的一个含义是，CPU必须小心何时读取由GPU计算的托管内存中的值。例如，如果实现中有代码试图在启动最后一个渲染内核后立即读取最终图像，它几乎肯定会读取到不完整的结果。因此，我们需要一种机制，使CPU能够等待所有先前的内核启动完成。这种能力由`GPUWait()`提供。再次说明，具体实现未包含在本文中，因为它基于特定于平台的功能。
]

```cpp
void GPUWait();
```



=== Structure-of-Arrays Layout
<structure-of-arrays-layout>
#parec[
  As discussed earlier, the thread group execution model of GPUs affects the pattern of memory accesses that program execution generates. A consequence is that the way in which data is laid out in memory can have a meaningful effect on performance. To understand the issue, consider the following definition of a ray structure:
][
  如前所述，GPU 的线程组执行模型会影响程序执行生成的内存访问模式。因此，数据在内存中的布局方式会对性能产生显著影响。为了理解这个问题，考虑以下射线结构的定义：
]

```cpp
struct SimpleRay {
    Point3f o;
    Vector3f d;
};
```


#parec[
  Now consider a kernel that takes a queue of `SimpleRay`s as input. Such a kernel might be responsible for finding the closest intersection along each ray, for example. A natural representation of the queue would be an array of `SimpleRay`s. (This layout is termed #emph[array of
structures];, and is sometimes abbreviated as #emph[AOS];.) Such a queue would be laid out in memory as shown in @fig:simpleray-aos, where each `SimpleRay` occupies a contiguous region of memory with its elements stored in consecutive locations in memory.
][
  现在考虑一个以 `SimpleRay` 队列作为输入的内核。例如，这样的内核可能负责寻找每条射线的最近交点。队列的自然表示是一个 `SimpleRay` 数组。（这种布局被称为 #emph[数组的结构];，有时缩写为 #emph[AOS];。）这样的 `SimpleRay` 结构数组在内存中的布局如@fig:simpleray-aos 所示，其中每个 `SimpleRay` 占据一块连续的内存区域，其元素存储在内存中的连续位置。
]

#figure(
  image("../pbr-book-website/4ed/Wavefront_Rendering_on_GPUs/pha15f04.svg"),
  caption: [
    #ez_caption[
      Memory Layout of an Array of `SimpleRay` Structures. The
      elements of each ray are consecutive in memory.
    ][
      `SimpleRay` 结构数组的内存布局。每条射线的元素在内存中是连续的。
    ]
  ],
)<simpleray-aos>


#parec[
  Now consider what happens when the threads in a thread group read their corresponding ray into memory. If the pointer to the array is `rays` and the index passed to each thread's lambda function is `i`, then each thread might start out by reading its ray using code like
][
  现在考虑当线程组中的线程将其对应的射线读入内存时会发生什么。如果数组的指针是 `rays`，传递给每个线程的 lambda 函数的索引是 `i`，那么每个线程可能会通过如下代码开始读取其射线：
]

```cpp
SimpleRay r = rays[i];
```


#parec[
  The generated code would typically load each component of the origins and directions individually. @fig:memory-layout-read-coherence(a) illustrates the distribution of memory locations accessed when each thread in a thread group loads the `x` component of its ray origin. The locations span many cache lines, which in turn incurs a performance cost.
][
  生成的代码通常会分别加载起点和方向的各个分量。@fig:memory-layout-read-coherence(a) 说明了当线程组中的每个线程加载其射线起点的 `x` 分量时访问的内存位置分布。位置跨越了许多缓存行，从而带来了性能开销。
]

#figure(
  image("../pbr-book-website/4ed/Wavefront_Rendering_on_GPUs/pha15f05.png"),
  caption: [
    #ez_caption[
      Effect of Memory Layout on Read Coherence. (a) When the
      threads in a thread group $t_i$ load the `x` component of their ray
      origin with an array of structures layout, each thread reads from a
      memory location that is offset by `sizeof(SimpleRay)` from the previous
      one; in this case, 24 bytes, assuming 4-byte `Float`s. Consequently,
      multiple cache lines must be accessed, with corresponding performance
      cost. (b) With structure of arrays layout, the threads in a thread group access
      contiguous locations to read the `x` component, corresponding to 1 or
      at most 2 cache-line accesses, depending on the alignment of the
      array. Performance is generally much better.
    ][
      内存布局对读取一致性的影响。(a) 当线程组 $t_i$
      中的线程以数组的结构布局加载其射线起点的 `x`
      分量时，每个线程从一个偏移了 `sizeof(SimpleRay)`
      的内存位置读取；在这种情况下，假设 4 字节的 `Float`，偏移为 24
      字节。因此，必须访问多个缓存行，带来相应的性能开销。 (b) 使用结构的数组布局，线程组中的线程访问连续位置以读取 `x`
      分量，最多对应 1 或 2
      次缓存行访问，具体取决于数组的对齐。性能通常要好得多。
    ]
  ],
)<memory-layout-read-coherence>


#parec[
  An alternative layout is termed #emph[structure of arrays];, or #emph[SOA];. The idea behind this approach is to effectively transpose the layout of the object in memory, storing all the origins' `x` components contiguously in an array of `Float`s, then all of its origins' `y` components in another `Float` array, and so forth. We might declare a specialized structure to represent arrays of `SimpleRay`s laid out like this:
][
  另一种布局称为 #emph[结构的数组];，或 #emph[SOA];。这种方法的想法是有效地转置对象在内存中的布局，将所有起点的 `x` 分量连续存储在一个 `Float` 数组中，然后将所有起点的 `y` 分量存储在另一个 `Float` 数组中，依此类推。我们可以声明一个专门的结构来表示这样布局的 `SimpleRay` 数组：
]

```cpp
struct SimpleRayArray {
    Float *ox, *oy, *oz;
    Float *dx, *dy, *dz;
};
```

#parec[
  In turn, if the threads in a thread group want to load the `x` component of their ray's origin, the expression `rays.ox[i]` suffices to load that value. The locations accessed are contiguous in memory and span many fewer cache lines #footnote[Another alternative,
 _array of structures of arrays_ , or _AOSOA_, offers a middle
ground between AOS and SOA by repeatedly applying SOA with fixed-size
(e.g., 32-element) arrays, collecting those in structures. This provides
many of SOA's benefits while further improving memory access locality.] (@fig:memory-layout-read-coherence(b)).
][
  反过来，如果线程组中的线程想要加载其射线起点的 `x` 分量，表达式 `rays.ox[i]` 就足以加载该值。访问的位置在内存中是连续的，并且跨越的缓存行要少得多 #footnote[另一种替代方案是_数组的结构数组（array of structures of arrays, AOSOA）_，它在 AOS 和 SOA 之间提供了一种折衷方案。通过将固定大小（例如 32 个元素）的数组反复应用 SOA，并将这些数组组合成结构体，AOSOA 实现了 SOA 的许多优势，同时进一步改善了内存访问的局部性。]（@fig:memory-layout-read-coherence(b)）。
]


#parec[
  However, this performance benefit comes at a cost of making the code more unwieldy. Loading an entire ray with this approach requires indexing into each of the constituent arrays—for example,
][
  然而，这种性能优势是以代码变得更复杂为代价的。使用这种方法加载整个射线需要对每个组成数组进行索引，例如：
]

```cpp
SimpleRay r(Point3f(rays.ox[i], rays.oy[i], rays.oz[i]),
            Vector3f(rays.dx[i], rays.dy[i], rays.dz[i]));
```


#parec[
  Even more verbose manual indexing is required for the task of writing a ray out to memory in SOA format; the cleanliness of the AOS array syntax has been lost.
][
  对于以 SOA 格式将射线写出到内存的任务，需要更冗长的手动索引；AOS 数组语法的简洁性已经不复存在。
]

#parec[
  In order to avoid such complexity, the code in the remainder of this chapter makes extensive use of `SOA` template types that make it possible to work with SOA data using syntax that is the same as array indexing with an array of structures data layout. For any type that has an `SOA` template specialization (e.g., `pbrt`'s regular `Ray` class), we are able to write code like the following:
][
  为了避免这种复杂性，本章其余部分的代码广泛使用 `SOA` 模板类型，使得可以使用与数组的结构数据布局相同的数组索引语法来处理 SOA 数据。对于任何具有 `SOA` 模板专门化的类型（例如，`pbrt` 的常规 `Ray` 类），我们可以编写如下代码：
]

```cpp
SOA<Ray> rays(1024, Allocator());
int index = ...;
Ray r = rays[index];
Transform transform = ...;
rays[index] = transform(r);
```


#parec[
  Both loads from and stores to the array are expressed using regular C++ array indexing syntax.
][
  从数组加载和存储到数组都使用常规 C++ 数组索引语法表达。
]

#parec[
  While it is straightforward programming to implement such `SOA` classes, doing so is rather tedious, especially if one has many types to lay out in SOA. Therefore, `pbrt` includes a small utility program, `soac` (#emph[structure of arrays compiler];), that automates this process. Its source code is in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cmd/soac.cpp")[`cmd/soac.cpp`] in the `pbrt` distribution. There is not much to be proud of in its implementation, so we will not discuss that here, but we will describe its usage as well as the form of the `SOA` type definitions that it generates.
][
  虽然实现这样的 `SOA` 类是简单的编程，但这样做相当繁琐，特别是如果有许多类型需要以 SOA 布局。因此，`pbrt` 包含一个小型实用程序程序，`soac`（#emph[结构的数组编译器];），自动化这个过程。其源代码在 `pbrt` 分发版的文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/cmd/soac.cpp")[`cmd/soac.cpp`] 中。其实现没有什么值得骄傲的地方，所以我们不会在这里讨论，但我们会描述其用法以及它生成的 `SOA` 类型定义的形式。
]

#parec[
  `soac` takes structure specifications in a custom format of the following form:
][
  `soac` 以以下格式的自定义格式接收结构规范：
]

```cpp
flat Float;
soa Point2f { Float x, y; };
```

#parec[
  Here, `flat` specifies that the following type should be stored directly in arrays, while `soa` specifies a structure. Although not shown here, `soa` structures can themselves hold other `soa` structure types. See the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.soa")[pbrt.soa] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/wavefront/workitems.soa")[wavefront/workitems.soa] in the `pbrt` source code for more examples.
][
  这里，`flat` 指定后续类型应直接存储在数组中，而 `soa` 指定一个结构。虽然这里没有显示，`soa` 结构本身可以包含其他 `soa` 结构类型。有关更多示例，请参见 `pbrt` 源代码中的文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.soa")[pbrt.soa] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/wavefront/workitems.soa")[wavefront/workitems.soa];。
]

#parec[
  This format is easy to parse and is sufficient to provide the information necessary to generate `pbrt`'s `SOA` type definitions. A more bulletproof solution (and one that would avoid the need for writing the code to parse a custom format) would be to modify a C++ compiler to optionally emit `SOA` type definitions for types it has already parsed. Of course, that is a more complex approach to implement than `soac` was.
][
  这种格式易于解析，并且足以提供生成 `pbrt` 的 `SOA` 类型定义所需的必要信息。更可靠的解决方案（并且可以避免编写解析自定义格式代码的需要）是修改 C++ 编译器以可选地为其已解析的类型发出 `SOA` 类型定义。当然，这比 `soac` 的实现要复杂得多。
]

#parec[
  When `pbrt` is compiled, `soac` is invoked to generate header files based on the `*.soa` specifications. For example, `pbrt.soa` is turned into `pbrt_soa.h`, which can be found in `pbrt`'s build directory after the system has been compiled. For each `soa` type defined in a specification file, `soac` generates an `SOA` template specialization. Here is the one for `Point2f`. (Here we have taken automatically generated code and brought it into the book text for dissection, which is the opposite flow from all the other code in the text.)
][
  在编译 `pbrt` 时，`soac` 会根据 `*.soa` 规范生成头文件。例如，`pbrt.soa` 被转换为 `pbrt_soa.h`，可以在系统编译后在 `pbrt` 的构建目录中找到。对于规范文件中定义的每个 `soa` 类型，`soac` 生成一个 `SOA` 模板专门化。以下是 `Point2f` 的一个例子。（这里我们将自动生成的代码带入书中进行剖析，这与文本中所有其他代码的流程相反。）
]

```cpp
template <> struct SOA<Point2f> {
    <<Point2f SOA Types>>
    struct GetSetIndirector {
        void operator=(const Point2f &a) {
            soa->x[i] = a.x;
            soa->y[i] = a.y;
        }
        SOA *soa;
        int i;
    };
    <<Point2f SOA Public Methods>>
    SOA(int n, Allocator alloc) : nAlloc(n) {
        this->x = alloc.allocate_object<Float>(n);
        this->y = alloc.allocate_object<Float>(n);
    }
    Point2f operator[](int i) const {
        Point2f r;
        r.x = this->x[i];
        r.y = this->y[i];
        return r;
    }
    GetSetIndirector operator[](int i) {
        return GetSetIndirector{this, i};
    }
    <<Point2f SOA Public Members>>
    int nAlloc;
    Float * PBRT_RESTRICT x;
    Float * PBRT_RESTRICT y;
};
```


#parec[
  The constructor uses a provided allocator to allocate space for individual arrays for the class member variables. The use of the `this->` syntax for initializing the member variables may seem gratuitous, though it ensures that if one of the member variables has the same name as one of the constructor parameters, it is still initialized correctly.
][
  构造函数使用提供的分配器为类成员变量的各个数组分配空间。使用 `this->` 语法初始化成员变量可能显得多余，但它确保如果某个成员变量与构造函数参数同名，它仍然会被正确初始化。
]

```cpp
SOA(int n, Allocator alloc) : nAlloc(n) {
    this->x = alloc.allocate_object<Float>(n);
    this->y = alloc.allocate_object<Float>(n);
}
```

#parec[
  The `SOA` class's members store the array size and the individual member pointers. The `PBRT_RESTRICT` qualifier informs the compiler that no other pointer will point to these arrays, which can allow it to generate more efficient code.
][
  `SOA` 类的成员存储数组大小和各个成员指针。`PBRT_RESTRICT` 限定符通知编译器不会有其他指针指向这些数组，这可以使其生成更高效的代码。
]

```cpp
int nAlloc;
Float * PBRT_RESTRICT x;
Float * PBRT_RESTRICT y;
```

#parec[
  It is easy to generate a method that allows indexing into the SOA arrays to read values. Note that the generated code requires that the class has a default constructor and that it can directly initialize the class's member variables. In the event that they are private, the class should use a `friend` declaration to make them available to its `SOA` specialization.
][
  生成允许索引到 SOA 数组以读取值的方法很容易。注意，生成的代码要求类具有默认构造函数，并且可以直接初始化类的成员变量。如果它们是私有的，类应使用 `friend` 声明使其对其 `SOA` 专门化可用。
]

```cpp
Point2f operator[](int i) const {
    Point2f r;
    r.x = this->x[i];
    r.y = this->y[i];
    return r;
}
```


#parec[
  It is less obvious how to support assignment of values using the regular array indexing syntax. `soac` provides this capability through the indirection of an auxiliary class, `GetSetIndirector`. When `operator[]` is called with a non-`const` `SOA` object, it returns an instance of that class. It records not only a pointer to the `SOA` object but also the index value.
][
  如何支持使用常规数组索引语法的值赋值则不太明显。`soac` 通过一个辅助类 `GetSetIndirector` 的间接性提供了这种能力。当 `operator[]` 用非 `const` 的 `SOA` 对象调用时，它返回该类的一个实例。它不仅记录了一个指向 `SOA` 对象的指针，还记录了索引值。
]

```cpp
GetSetIndirector operator[](int i) {
    return GetSetIndirector{this, i};
}
```


#parec[
  Assignment is handled by the `GetSetIndirector`'s `operator=` method. Given a `Point2f` value, it is able to perform the appropriate assignments using the `SOA *` and the index.
][
  赋值由 `GetSetIndirector` 的 `operator=` 方法处理。给定一个 `Point2f` 值，它能够使用 `SOA *` 和索引执行适当的赋值。
]

```cpp
struct GetSetIndirector {
    void operator=(const Point2f &a) {
        soa->x[i] = a.x;
        soa->y[i] = a.y;
    }
    SOA *soa;
    int i;
};
```

#parec[
  Variables of type `GetSetIndirector` should never be declared explicitly. Rather, the role of this structure is to cause an assignment of the form `p[i] = Point2f(...)` to correspond to the following code, where the initial parenthesized expression corresponds to invoking the `SOA` class's `operator[]` to get a temporary `GetSetIndirector` and where the assignment is then handled by its `operator=` method.
][
  不应显式声明 `GetSetIndirector` 类型的变量。相反，该结构的作用是使形式为 `p[i] = Point2f(...)` 的赋值对应于以下代码，其中初始的括号表达式对应于调用 `SOA` 类的 `operator[]` 以获取一个临时的 `GetSetIndirector`，赋值则由其 `operator=` 方法处理。
]

```cpp
(p.operator[](i)).operator=(Point2f(...));
```


#parec[
  `GetSetIndirector` also provides an `operator Point2f()` conversion operator (not included here) that handles the case of an SOA array read with a non-`const` `SOA` object.
][
  `GetSetIndirector` 还提供了一个 `operator Point2f()` 转换操作符（此处未包含），用于处理使用非 `const` `SOA` 对象读取 SOA 数组的情况。
]

#parec[
  We conclude with a caveat: SOA layout is effective if access is coherent, but can be detrimental if it is not. If threads are accessing an array of some structure type in an incoherent fashion, then AOS may be a better choice: in that case, although each thread's initial access to the structure may incur a cache miss, its subsequent accesses may be efficient if nearby values in the structure are still in the cache. Conversely, incoherent access to SOA data may incur a miss for each access to each structure member, polluting the cache by bringing in many unnecessary values that are not accessed by any other threads.
][
  我们以一个警告结束：SOA 布局是有效的，如果访问是一致的，但如果不一致，则可能有害。如果线程以不一致的方式访问某种结构类型的数组，那么 AOS 可能是更好的选择：在这种情况下，尽管每个线程对结构的初始访问可能会导致缓存未命中，但如果结构中的附近值仍在缓存中，其后续访问可能会很高效。相反，对 SOA 数据的不一致访问可能导致对每个结构成员的每次访问都未命中，污染缓存，引入许多未被其他线程访问的不必要值。
]


=== Work Queues
<work-queues>
#parec[
  Our last bit of groundwork before getting back into rendering will be to define two classes that manage the input and output of kernels in the ray-tracing pipeline. Both are defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/wavefront/workqueue.h")[`wavefront/workqueue.h`];.
][
  在回到渲染之前，我们最后要做的准备工作是定义两个类来管理光线追踪管道中内核的输入和输出。它们都定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/wavefront/workqueue.h")[`wavefront/workqueue.h`] 中。
]

#parec[
  First is `WorkQueue`, which represents a queue of objects of a specified type, `WorkItem`. The items in the queue are stored in SOA layout; this is achieved by publicly inheriting from the `SOA` template class for the item type. This inheritance also allows the items in the work queue to be indexed using regular array indexing syntax, via the `SOA` public methods.
][
  首先是 `WorkQueue`，它表示一个指定类型 `WorkItem` 的对象队列。队列中的项目以 SOA 布局存储；这是通过从项目类型的 `SOA` 模板类继承来实现的。这种继承还允许使用常规数组索引语法对工作队列中的项目进行索引。
]

```cpp
template <typename WorkItem>
class WorkQueue : public SOA<WorkItem> {
  public:
    <<WorkQueue Public Methods>>
    WorkQueue(int n, Allocator alloc) : SOA<WorkItem>(n, alloc) {}
    int Size() const {
        return size.load(std::memory_order_relaxed);
    }
    void Reset() {
        size.store(0, std::memory_order_relaxed);
    }
    int Push(WorkItem w) {
        int index = AllocateEntry();
        (*this)[index] = w;
        return index;
    }
  protected:
    <<WorkQueue Protected Methods>>
    int AllocateEntry() {
        return size.fetch_add(1, std::memory_order_relaxed);
    }
  private:
    <<WorkQueue Private Members>>
    std::atomic<int> size{0};

};
```

#parec[
  The constructor takes the maximum number of objects that can be stored in the queue as well as an allocator, but leaves the actual allocation to the `SOA` base class.
][
  构造函数接受可以存储在队列中的最大对象数以及一个分配器，但将实际分配留给 `SOA` 基类。
]

```cpp
WorkQueue(int n, Allocator alloc) : SOA<WorkItem>(n, alloc) {}
```


#parec[
  There is only a single private member variable: the number of objects stored in the queue. It is represented using a platform-specific atomic type. When `WorkQueue`s are used on the CPU, a `std::atomic` is sufficient; that case is shown here.
][
  只有一个私有成员变量：存储在队列中的对象数量。它使用平台特定的原子类型表示。当 `WorkQueue` 在 CPU 上使用时，`std::atomic` 就足够了；这里展示的就是这种情况。
]

```cpp
std::atomic<int> size{0};
```

#parec[
  Simple methods return the size of the queue and reset it so that it stores no items.
][
  简单的方法返回队列的大小并重置它，使其不存储任何项目。
]

```cpp
int Size() const {
    return size.load(std::memory_order_relaxed);
}
void Reset() {
    size.store(0, std::memory_order_relaxed);
}
```

#parec[
  An item is added to the queue by finding a slot for it via a call to `AllocateEntry()`. We implement that functionality separately so that `WorkQueue` subclasses can implement their own methods for adding items to the queue if further processing is needed when doing so. In this case, all that needs to be done is to store the provided value in the specified spot using the `SOA` indexing operator.
][
  通过调用 `AllocateEntry()` 找到一个插槽来向队列中添加一个项目。我们单独实现该功能，以便 `WorkQueue` 子类可以实现它们自己的方法来向队列中添加项目，如果在添加项目时需要进一步处理。在这种情况下，所需要做的就是使用 `SOA` 索引运算符将提供的值存储在指定的位置。
]

```cpp
int Push(WorkItem w) {
    int index = AllocateEntry();
    (*this)[index] = w;
    return index;
}
```

#parec[
  When a slot is claimed for a new item in the queue, the `size` member variable is incremented using an atomic operation, and so it is fine if multiple threads are concurrently adding items to the queue without any further coordination.
][
  当为队列中的新项目声明一个插槽时，使用原子操作递增 `size` 成员变量，因此如果多个线程同时向队列中添加项目而无需进一步协调，这是可以的。
]

#parec[
  Returning to how threads access memory, we would do well to allocate consecutive slots for all of the threads in a thread group that are adding entries to a queue. Given the SOA layout of the queue, such an allocation leads to writes to consecutive memory locations, with corresponding performance benefits. Our use of `fetch_add` here does not provide that guarantee, since each thread calls it independently. However, a common way to implement atomic addition in the presence of thread groups is to aggregate the operation over all the active threads in the group and to perform a single addition for all of them, doling out corresponding individual results back to the individual threads. Our code here assumes such an implementation; on a platform where the assumption is incorrect, it would be worthwhile to use a different mechanism that did give that result.
][
  回到线程如何访问内存，我们最好为向队列中添加条目的线程组中的所有线程分配连续的插槽。鉴于队列的 SOA 布局，这种分配会导致对连续内存位置的写入，从而带来性能优势。我们在这里使用的 `fetch_add` 并不能提供这种保证，因为每个线程都是独立调用它的。 然而，在存在线程组的情况下实现原子加法的一种常见方法是将操作聚合到组中所有活动线程上，并为它们执行一次加法，将相应的单个结果分配回各个线程。我们的代码假设了这种实现；在假设不正确的平台上，使用其他机制来实现该结果是值得的。
]

```cpp
int AllocateEntry() {
    return size.fetch_add(1, std::memory_order_relaxed);
}
```


#parec[
  `ForAllQueued()` makes it easy to apply a function to all of the items stored in a `WorkQueue()` in parallel. The provided callback function is passed the `WorkItem` that it is responsible for.
][
  `ForAllQueued()` 使得可以轻松地并行地将函数应用于存储在 `WorkQueue()` 中的所有项目。提供的回调函数会传递它负责的 `WorkItem`。
]

```cpp
template <typename F, typename WorkItem>
void ForAllQueued(const char *desc, const WorkQueue<WorkItem> *q,
                  int maxQueued, F &&func) {
    if (Options->useGPU) {
        <<Launch GPU threads to process q using func>>
        GPUParallelFor(desc, maxQueued, [=] PBRT_GPU (int index) mutable {
            if (index >= q->Size())
                return;
            func((*q)[index]);
        });

    } else {
        <<Process q using func with CPU threads>>
        ParallelFor(0, q->Size(), [&](int index) { func((*q)[index]); });
    }
}
```


#parec[
  If the GPU is being used, a thread is launched for the maximum number of items that could be stored in the queue, rather than only for the number that are actually stored there. This stems from the fact that kernels are launched from the CPU but the number of objects actually in the queue is stored in managed memory. Not only would it be inefficient to read the actual size of the queue back from GPU memory to the CPU for the call to `GPUParallelFor()`, but retrieving the correct value would require synchronization with the GPU, which would further harm performance.
][
  如果使用 GPU，则会为可以存储在队列中的最大项目数启动一个线程，而不是仅为实际存储在其中的项目数启动一个线程。这是因为内核是从 CPU 启动的，但队列中实际对象的数量存储在托管内存中。 将队列的实际大小从 GPU 内存读取回 CPU 以调用 `GPUParallelFor()` 不仅效率低下，而且检索正确的值需要与 GPU 同步，这会进一步损害性能。
]

```cpp
GPUParallelFor(desc, maxQueued, [=] PBRT_GPU (int index) mutable {
    if (index >= q->Size())
        return;
    func((*q)[index]);
});
```


#parec[
  For CPU processing, there are no concerns about reading the `size` field, so precisely the right number of items to process can be passed to `ParallelFor()`.
][
  对于 CPU 处理，没有读取 `size` 字段的顾虑，因此可以将要处理的精确项目数传递给 `ParallelFor()`。
]

```cpp
ParallelFor(0, q->Size(), [&](int index) { func((*q)[index]); });
```


#parec[
  We will also find it useful to have work queues that support multiple types of objects and maintain separate queues, one for each type. This functionality is provided by the `MultiWorkQueue`.
][
  我们还将发现支持多种对象类型并为每种类型维护单独队列的工作队列很有用。这种功能由 `MultiWorkQueue` 提供。
]

```cpp
template <typename T> class MultiWorkQueue;
```


#parec[
  The definition of this class is a #emph[variadic template] specialization that takes all of the types `Ts` it is to manage using a `TypePack`.
][
  这个类的定义是一个 #emph[可变参数模板] 专门化，它使用 `TypePack` 管理它要管理的所有类型 `Ts`。
]

```cpp
template <typename... Ts> class MultiWorkQueue<TypePack<Ts...>> {
public:
  <<MultiWorkQueue Public Methods>>
  template <typename T>
  WorkQueue<T> *Get() {
      return &pstd::get<WorkQueue<T>>(queues);
  }
  MultiWorkQueue(int n, Allocator alloc, pstd::span<const bool> haveType) {
      int index = 0;
      ((*Get<Ts>() = WorkQueue<Ts>(haveType[index++] ? n : 1, alloc)), ...);
  }
  template <typename T>
  int Size() const { return Get<T>()->Size(); }
  template <typename T>
  int Push(const T &value) { return Get<T>()->Push(value); }
  void Reset() { (Get<Ts>()->Reset(), ...); }
private:
  <<MultiWorkQueue Private Members>>
  pstd::tuple<WorkQueue<Ts>...> queues;
};
```


#parec[
  The `MultiWorkQueue` internally expands to a set of per-type `WorkQueue` instances that are stored in a tuple.
][
  `MultiWorkQueue` 内部展开为一组按类型划分的 `WorkQueue` 实例，这些实例存储在一个元组中。
]

```cpp
pstd::tuple<WorkQueue<Ts>...> queues;
```


#parec[
  Note the ellipsis (`...`) in the code fragment above, which is a C++ #emph[template pack expansion];. Such an expansion is only valid when it contains a template pack (`Ts` in this case), and it simply inserts the preceding element once for each specified template argument while replacing `Ts` with the corresponding type. For example, a hypothetical `MultiWorkQueue<TypePack<A, B>>` would contain a tuple of the form `pstd::tuple<WorkQueue<A>, WorkQueue<B>>`. This and the following template-based transformations significantly reduce the amount of repetitive code that would otherwise be needed to implement equivalent functionality.
][
  注意上面代码片段中的省略号 (`...`)，这是 C++ 的 #emph[模板包展开];。这种展开仅在包含模板包（此情况下为 `Ts`）时有效，它只是简单地将前面的元素插入一次，替换为每个指定的模板参数，同时用相应的类型替换 `Ts`。 例如，假设的 `MultiWorkQueue<TypePack<A, B>>` 将包含一个形式为 `pstd::tuple<WorkQueue<A>, WorkQueue<B>>` 的元组。这种和随后的基于模板的转换显著减少了实现等效功能所需的重复代码量。
]

#parec[
  The following template method returns a queue for a particular work item that must be one of the `MultiWorkQueue` template arguments. The search through tuple items is resolved at compile time and so incurs no additional runtime cost.
][
  以下模板方法返回一个特定工作项目的队列，该项目必须是 `MultiWorkQueue` 模板参数之一。通过元组项的搜索在编译时解决，因此不会产生额外的运行时成本。
]

```cpp
template <typename T>
WorkQueue<T> *Get() {
    return &pstd::get<WorkQueue<T>>(queues);
}
```


#parec[
  The `MultiWorkQueue` constructor takes the maximum number of items to store in the queue and an allocator. The third argument is a span of Boolean values that indicates whether each type is actually present. Saving memory for types that are not required in a given execution of the renderer is worthwhile when both the maximum number of items is large and the work item types themselves are large.
][
  `MultiWorkQueue` 构造函数接受要存储在队列中的最大项目数和一个分配器。第三个参数是一个布尔值跨度，指示每种类型是否实际存在。 当最大项目数很大且工作项目类型本身很大时，为不需要的类型节省内存是值得的。
]

```cpp
MultiWorkQueue(int n, Allocator alloc, pstd::span<const bool> haveType) {
    int index = 0;
    ((*Get<Ts>() = WorkQueue<Ts>(haveType[index++] ? n : 1, alloc)), ...);
}
```


#parec[
  Once more, note the use of the ellipsis in the above fragment, which is a more advanced case of a template pack expansion following the pattern `((expr), ...)`. As before, this expansion will simply repeat the element `((expr))` preceding the ellipsis once for every `Ts` with appropriate substitutions. In contrast to the previous case, we are now expanding expressions rather than types. The actual values of these expressions are ignored because they will be joined by the comma operator that ignores the value of the preceding expression. Finally, the actual expression being repeated has side effects: it initializes each tuple entry with a suitable instance, and it also advances a counter `index` that is used to access corresponding elements of the `haveType` span.
][
  再次注意上面片段中省略号的使用，这是模板包展开的更高级情况，遵循模式 `((expr), ...)`。与之前一样，这种展开将简单地为每个 `Ts` 重复省略号前的元素 `((expr))`，并进行适当的替换。 与之前的情况不同，我们现在正在展开表达式而不是类型。这些表达式的实际值会被忽略，因为它们将由忽略前一个表达式值的逗号运算符连接。 最后，实际重复的表达式具有副作用：它使用合适的实例初始化每个元组条目，并且还推进了用于访问 `haveType` 跨度对应元素的计数器 `index`。
]

#parec[
  The `Size()` method returns the size of a queue, and `Push()` appends an element. Both methods require that the caller specify the concrete type `T` of work item, which allows it to directly call the corresponding method of the appropriate queue.
][
  `Size()` 方法返回队列的大小，而 `Push()` 则添加一个元素。两种方法都要求调用者指定工作项目的具体类型 `T`，这允许它直接调用相应队列的对应方法。
]

```cpp
template <typename T>
int Size() const { return Get<T>()->Size(); }
template <typename T>
int Push(const T &value) { return Get<T>()->Push(value); }
```

#parec[
  Finally, all queues are reset via a call to `Reset()`. Once again, template pack expansion generates calls to all the individual queues' `Reset()` methods via the following terse code.
][
  最后，通过调用 `Reset()` 重置所有队列。再次，模板包展开通过以下简洁的代码生成对所有单个队列的 `Reset()` 方法的调用。
]

```cpp
void Reset() { (Get<Ts>()->Reset(), ...); }
```


