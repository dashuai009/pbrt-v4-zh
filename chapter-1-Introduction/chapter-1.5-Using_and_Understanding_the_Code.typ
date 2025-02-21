#import "../template.typ": parec

== Using and Understanding the Code
<using-and-understanding-the-code>
#parec[
  The `pbrt` source code distribution is available from #link("https://pbrt.org")[pbrt.org];. The website also includes additional documentation, images rendered with `pbrt`, example scenes,errata, and links to a bug reporting system. We encourage you to visit the website and subscribe to the `pbrt` mailing list.
][
  `pbrt` 源代码分发包可以从 #link("https://pbrt.org")[pbrt.org] 获取。该网站还包括额外的文档、使用 `pbrt` 渲染的图像、示例场景、勘误表以及错误报告系统的链接。我们鼓励您访问该网站并订阅 `pbrt` 邮件列表。
]

#parec[
  `pbrt` is written in C++, but we have tried to make it accessible to non-C++ experts by limiting the use of esoteric features of the language. Staying close to the core language features also helps with the system's portability. We make use of C++'s extensive standard library whenever it is applicable but will not discuss the semantics of calls to standard library functions in the text. Our expectation is that the reader will consult documentation of the standard library as necessary.
][
  `pbrt` 是用 C++ 编写的，但我们尝试通过限制使用语言的深奥特性，使其对非 C++ 专家也易于理解。保持接近基本语言特性也有助于系统的可移植性。我们在适用时使用 C++ 的广泛标准库，但不会在文本中讨论对标准库函数调用的语义。我们期望读者在必要时查阅标准库的文档。
]

#parec[
  We will occasionally omit short sections of `pbrt`'s source code from the book. For example, when there are a number of cases to be handled,all with nearly identical code, we will present one case and note that the code for the remaining cases has been omitted from the text. Default class constructors are generally not shown, and the text also does not include details like the various `#include` directives at the start of each source file. All the omitted code can be found in the `pbrt` source code distribution.
][
  我们会偶尔在书中省略 `pbrt` 源代码的短小部分。例如，当有许多几乎相同代码的情况需要处理时，我们将展示一个案例，并注明其余案例的代码已从文本中省略。默认的类构造函数通常不显示，文本中也不包括每个源文件开头的各种 `#include` 指令等细节。所有省略的代码都可以在 `pbrt` 源代码分发包中找到。
]

=== Source Code Organization
<source-code-organization>
#parec[
  The source code used for building `pbrt` is under the `src` directory in the `pbrt` distribution. In that directory are `src/ext`, which has the source code for various third-party libraries that are used by `pbrt`,and `src/pbrt`, which contains `pbrt`'s source code. We will not discuss the third-party libraries' implementations in the book.
][
  用于构建 `pbrt` 的源代码位于 `pbrt` 分发的 `src` 目录下。在该目录中有 `src/ext`，其中包含 `pbrt` 使用的各种第三方库的源代码，以及 `src/pbrt`，其中包含 `pbrt` 的源代码。我们不会在书中讨论第三方库的实现细节。
]

#parec[
  The source files in the `src/pbrt` directory mostly consist of implementations of the various interface types. For example,#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[`shapes.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[`shapes.cpp`] have implementations of the #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] interface,#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.h")[`materials.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.cpp")[`materials.cpp`] have materials, and so forth. That directory also holds the source code for parsing `pbrt`'s scene description files.
][
  `src/pbrt` 目录中的源文件主要由各种接口类型的实现代码组成。例如，#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[`shapes.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[`shapes.cpp`] 实现了 #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 接口，#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.h")[`materials.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.cpp")[`materials.cpp`] 实现了材料，等等。该目录还包含解析 `pbrt` 场景描述文件的源代码。
]

#parec[
  The #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] header file in `src/pbrt` is the first file that is included by all other source files in the system. It contains a few macros and widely useful forward declarations, though we have tried to keep it short and to minimize the number of other headers that it includes in the interests of compile time efficiency.
][
  `src/pbrt` 中的 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] 头文件是系统中所有其他源文件首先包含的文件。它包含了一些宏和广泛使用的前向声明，尽管我们尝试保持其简短，并尽量减少其包含的其他头文件数量，以提高编译时间效率。
]

#parec[
  The `src/pbrt` directory also contains a number of subdirectories. They have the following roles:
][
  `src/pbrt` 目录还包含多个子目录。它们的作用如下：
]

#parec[
  - `base`: Header files defining the interfaces for 12 of the common
    interface types listed in @tbl:plug-in-types (`Primitive` and `Integrator` are CPU-only and so are defined in files in the `cpu` directory).
][
  - `base`：头文件定义了@tbl:plug-in-types-zh 中列出的 12 种常见接口类型的接口（`Primitive` 和 `Integrator` 仅限于 CPU，因此在 `cpu` 目录中的文件中定义）。
]

#parec[
  - `cmd`: Source files containing the `main()` functions for the
    executables that are built for `pbrt`. (Others besides the `pbrt`
    executable include `imgtool`, which performs various image processing
    operations, and `pbrt_test`, which contains unit tests.)
][
  - `cmd`：包含为 `pbrt` 构建的可执行文件的 `main()` 函数的源文件。（除了 `pbrt` 可执行文件外，还有 `imgtool`，用于执行各种图像处理操作，以及 `pbrt_test`，其中包含单元测试。）
]

#parec[
  - `cpu`: CPU-specific code, including `Integrator` implementations.
][
  - `cpu`：特定于 CPU 的代码，包括 `Integrator` 实现。
]

#parec[
  - `gpu`: GPU-specific source code, including functions for allocating
    memory and launching work on the GPU.
][
  - `gpu`：特定于 GPU 的源代码，包括用于分配内存和在 GPU
    上启动工作的函数。
]

#parec[
  - `util`: Lower-level utility code, most of it not specific to
    rendering.
][
  - `util`：较低级别的实用代码，其中大部分与渲染无关。
]

#parec[
  - `wavefront`: Implementation of the
    #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];,
    which is introduced in @wavefront-rendering-on-gpus. This integrator runs on both CPUs
    and GPUs.
][
  - `wavefront`：实现了@wavefront-rendering-on-gpus 介绍的
    #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];。该积分器在
    CPU 和 GPU 上运行。
]

=== Naming Conventions
<naming-conventions>
#parec[
  Functions and classes are generally named using Camel case, with the first letter of each word capitalized and no delineation for spaces. One exception is some methods of container classes, which follow the naming convention of the C++ standard library when they have matching functionality (e.g.,`size()` and `begin()` and `end()` for iterators).Variables also use Camel case, though with the first letter lowercase,except for a few global variables.
][
  函数和类通常使用驼峰命名法，每个单词的首字母大写，单词之间不使用分隔符。一个例外是某些容器类的方法，当它们具有与 C++ 标准库匹配的功能时，会遵循 C++ 标准库的命名约定（例如，迭代器的 `size()`、`begin()` 和 `end()`）。变量也使用驼峰命名法，但首字母小写，除了一些全局变量。
]

#parec[
  We also try to match mathematical notation in naming: for example, we use variables like `p` for points $p$ and `w` for directions $omega$.We will occasionally add a `p` to the end of a variable to denote a primed symbol: `wp` for $omega '$. Underscores are used to indicate subscripts in equations: `theta_o` for $theta_o$, for example.
][
  我们还尝试在命名中匹配数学记法：例如，我们使用 `p` 表示点 $p$，使用 `w`表示方向 $omega$。我们偶尔会在变量末尾添加一个 `p` 来表示加撇号的符号：`wp` 表示 $omega '$。下划线用于表示方程中的下标：例如，`theta_o` 表示 $theta_o$。
]

#parec[
  Our use of underscores is not perfectly consistent, however. Short variable names often omit the underscore—we use `wi` for $omega_i$ and we have already seen the use of `Li` for $L_i$. We also occasionally use an underscore to separate a word from a lowercase mathematical symbol. For example, we use `Sample_f` for a method that samples a function $f$ rather than `Samplef`, which would be more difficult to read, or `SampleF`, which would obscure the connection to the function $f$ ("where was the function $F$ defined?").
][
  然而，我们使用下划线并不完全一致。短变量名通常省略下划线——我们使用 `wi` 表示 $omega_i$，并且我们已经看到使用 `Li` 表示 $L_i$。我们也偶尔使用下划线将单词与小写数学符号分开。例如，我们使用 `Sample_f` 表示一个采样函数 $f$ 的方法，而不是 `Samplef`，这样更难阅读，或 `SampleF`，这样会模糊与函数 $f$ 的联系（"函数 $F$ 是在哪里定义的？"）。
]

=== Pointer or Reference?
<pointer-or-reference>
#parec[
  C++ provides two different mechanisms for passing an object to a function or method by reference: pointers and references. If a function argument is not intended as an output variable, either can be used to save the expense of passing the entire structure on the stack. The convention in `pbrt` is to use a pointer when the argument will be completely changed by the function or method, a reference when some of its internal state will be changed but it will not be fully reinitialized, and `const` references when it will not be changed at all. One important exception to this rule is that we will always use a pointer when we want to be able to pass `nullptr` to indicate that a parameter is not available or should not be used.
][
  C++ 提供了两种机制，通过引用机制将对象传递给函数或方法：指针和引用。如果函数参数不作为输出变量，可以使用任意一种来节省在栈上传递整个结构的开销。`pbrt` 的惯例是，当参数将被函数或方法完全更改时使用指针，当参数的一些内部状态将被更改但不会完全重新初始化时使用引用，当参数完全不会被更改时使用 `const` 引用。此规则的一个重要例外是，当需要传递 `nullptr` 以指示参数不可用或不应使用时，我们总是使用指针。
]


=== Abstraction versus Efficiency
<abstraction-versus-efficiency>
#parec[
  One of the primary tensions when designing interfaces for software systems is making a reasonable trade-off between abstraction and efficiency. For example, many programmers religiously make all data in all classes `private` and provide methods to obtain or modify the values of the data items. For simple classes (e.g.,#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];),we believe that approach needlessly hides a basic property of the implementation—that the class holds three floating-point coordinates—that we can reasonably expect to never change. Of course,using no information hiding and exposing all details of all classes' internals leads to a code maintenance nightmare, but we believe that there is nothing wrong with judiciously exposing basic design decisions throughout the system. For example, the fact that a #link("../Geometry_and_Transformations/Rays.html#Ray")[`Ray`] is represented with a point, a vector, a time, and the medium it is in is a decision that does not need to be hidden behind a layer of abstraction.Code elsewhere is shorter and easier to understand when details like these are exposed.
][
  在设计软件系统的接口时，主要的矛盾之一是如何合理权衡抽象和效率。例如，许多程序员习惯性地将所有类的数据设为`private`，并提供方法来获取或修改数据项的值。对于简单的类（例如，#link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];），我们认为这种方法不必要地隐藏了实现的基本属性——即类持有三个浮点坐标——我们可以合理预期这一特性不会改变。当然，不进行信息隐藏并暴露所有类内部的细节会导致代码维护困难，但我们认为在整个系统中谨慎地公开基本设计决策没有问题。例如，#link("../Geometry_and_Transformations/Rays.html#Ray")[`Ray`];由一个点、一个向量、一个时间和它所在的介质表示，这一决定不需要隐藏在抽象层之下。当这些细节被公开时，其他地方的代码会更简短且更易于理解。
]

#parec[
  An important thing to keep in mind when writing a software system and making these sorts of trade-offs is the expected final size of the system.`pbrt` is roughly 70,000 lines of code and it is never going to grow to be a million lines of code; this fact should be reflected in the amount of information hiding used in the system. It would be a waste of programmer time (and likely a source of runtime inefficiency) to design the interfaces to accommodate a system of a much higher level of complexity.
][
  在编写软件系统并做出这些权衡时，需要牢记的重要一点是系统的预期最终规模。`pbrt`大约有70,000行代码，并且永远不会增长到一百万行代码；这一事实应反映在系统中使用的信息隐藏量上。为一个复杂度高得多的系统设计接口将是程序员时间的浪费（并且可能是运行时效率低下的来源）。
]

=== pstd
<pstd>
#parec[
  We have reimplemented a subset of the C++ standard library in the `pstd` namespace; this was necessary in order to use those parts of it interchangeably on the CPU and on the GPU. For the purposes of reading `pbrt`'s source code, anything in `pstd` provides the same functionality with the same type and methods as the corresponding entity in `std`. We will therefore not document usage of `pstd` in the text here.
][
  我们在`pstd`命名空间中重新实现了C++标准库的一个子集；这是为了能够在CPU和GPU之间互换使用这些部分。在阅读`pbrt`的源代码时，`pstd`中的任何内容都提供与`std`中对应实体相同的功能和方法。因此，我们在此文本中不会记录`pstd`的用法。
]

=== Allocators
<allocators>
#parec[
  Almost all dynamic memory allocation for the objects that represent the scene in `pbrt` is performed using an instance of an `Allocator` that is provided to the object creation methods. In `pbrt`,`Allocator` is shorthand for the C++ standard library's `pmr::polymorphic_allocator` type. Its definition is in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] so that it is available to all other source files.
][
  几乎所有用于表示`pbrt`场景的对象的动态内存分配都是通过`Allocator`实例进行的。在`pbrt`中，`Allocator`是C++标准库的`pmr::polymorphic_allocator`类型的简写。它的定义在#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`];中，以便其他所有源文件都能使用。
]

```cpp
<<Define Allocator>>=
using Allocator = pstd::pmr::polymorphic_allocator<std::byte>;
```


#parec[
  `std::pmr::polymorphic_allocator` implementations provide a few methods for allocating and freeing objects. These three are used widely in `pbrt`:#footnote[Because `pmr::polymorphic_allocator` is a recent
addition to C++ that is not yet widely used, yet is widely used in
`pbrt`, we break our regular habit of not documenting standard library
functionality in the text here.]
][
  `std::pmr::polymorphic_allocator`实现提供了一些用于分配和释放对象的方法。在`pbrt`中广泛使用以下三种方法：#footnote[因为`pmr::polymorphic_allocator`是C++的一个最近添加的功能，尚未被广泛使用，但在`pbrt`中被广泛使用，因此我们打破了不在文本中记录标准库功能的常规习惯。]
]

```cpp
void *allocate_bytes(size_t nbytes, size_t alignment);
template <class T> T *allocate_object(size_t n = 1);
template <class T, class... Args> T *new_object(Args &&... args);
```
#parec[
  The first,`allocate_bytes()`, allocates the specified number of bytes of memory. Next,`allocate_object()` allocates an array of `n` objects of the specified type `T`, initializing each one with its default constructor. The final method,`new_object()`, allocates a single object of type `T` and calls its constructor with the provided arguments. There are corresponding methods for freeing each type of allocation: `deallocate_bytes()`,`deallocate_object()`, and `delete_object()`.
][
  第一个方法`allocate_bytes()`分配指定字节数的内存。接下来，`allocate_object()`分配一个大小为`n`的指定类型`T`的数组，并用其默认构造函数初始化每个对象。最后一个方法`new_object()`分配一个类型为`T`的单个对象，并使用提供的参数调用其构造函数。对于每种类型的分配都有相应的释放方法：`deallocate_bytes()`，`deallocate_object()`和`delete_object()`。
]

#parec[
  A tricky detail related to the use of allocators with data structures from the C++ standard library is that a container's allocator is fixed once its constructor has run. Thus, if one container is assigned to another, the target container's allocator is unchanged even though all the values it stores are updated.(This is the case even with C++'s move semantics.) Therefore, it is common to see objects' constructors in `pbrt` passing along an allocator in member initializer lists for containers that they store even if they are not yet ready to set the values stored in them.
][
  与C++标准库数据结构一起使用分配器的一个复杂的细节是容器的分配器在其构造函数运行后是固定的。因此，如果一个容器被赋值给另一个容器，目标容器的分配器不会改变，即使它存储的所有值都被更新。（即使在C++的移动语义下也是如此。）因此，在`pbrt`中常见对象的构造函数在成员初始化列表中传递分配器给它们存储的容器，即使它们尚未准备好设置存储在其中的值。
]

#parec[
  Using an explicit memory allocator rather than direct calls to `new` and `delete` has a few advantages. Not only does it make it easy to do things like track the total amount of memory that has been allocated,but it also makes it easy to substitute allocators that are optimized for many small allocations, as is useful when building acceleration structures in @primitives-and-intersection-acceleration .Using allocators in this way also makes it easy to store the scene objects in memory that is visible to the GPU when GPU rendering is being used.
][
  使用显式内存分配器而不是直接调用`new`和`delete`有几个优点。不仅可以轻松跟踪已分配的总内存量，还可以轻松替换为优化了许多小型分配的分配器，这在构建@primitives-and-intersection-acceleration 中的加速结构时很有用。以这种方式使用分配器还可以轻松地将场景对象存储在GPU可见的内存中，当使用GPU进行渲染时。
]

=== Dynamic Dispatch
<dynamic-dispatch>
#parec[
  As mentioned in @pbrt-system-overview, virtual functions are generally not used for dynamic dispatch with polymorphic types in `pbrt` (the main exception being the `Integrator`s). Instead, the #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] class is used to represent a pointer to one of a specified set of types; it includes machinery for runtime type identification and thence dynamic dispatch.(Its implementation can be found in Appendix #link("../Utilities/Containers_and_Memory_Management.html#sec:tagged-pointer")[B.4.4];.) Two considerations motivate its use.
][
  如第#link("../Introduction/pbrt_System_Overview.html#sec:pbrt-system-overview")[1.3];节所述，`pbrt`中通常不使用虚函数进行多态类型的动态分派（主要的例外是`Integrator`）。相反，使用#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];类来表示指向指定类型集合之一的指针；它包括用于运行时类型识别和动态分派的机制。（其实现可以在附录#link("../Utilities/Containers_and_Memory_Management.html#sec:tagged-pointer")[B.4.4];中找到。）其使用有两个考虑因素。
]

#parec[
  First, in C++, an instance of an object that inherits from an abstract base class includes a hidden virtual function table pointer that is used to resolve virtual function calls. On most modern systems, this pointer uses eight bytes of memory. While eight bytes may not seem like much, we have found that when rendering complex scenes with previous versions of `pbrt`, a substantial amount of memory would be used just for virtual function pointers for shapes and primitives. With the #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] class, there is no incremental storage cost for type information.
][
  首先，在C++中，从抽象基类继承的对象实例包含隐藏的虚函数表指针，用于解析虚函数调用。在大多数现代系统中，该指针使用八个字节的内存。虽然八个字节看起来不多，但我们发现，在使用`pbrt`的早期版本渲染复杂场景时，仅仅用于形状和基本体的虚函数指针就会消耗大量内存。使用#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];类，类型信息没有额外的存储成本。
]

#parec[
  The other problem with virtual function tables is that they store function pointers that point to executable code. Of course, that's what they are supposed to do, but this characteristic means that a virtual function table can be valid for method calls from either the CPU or from the GPU, but not from both simultaneously, since the executable code for the different processors is stored at different memory locations. When using the GPU for rendering, it is useful to be able to call methods from both processors, however.
][
  虚函数表的另一个问题是它们存储指向可执行代码的函数指针。当然，这正是它们应该做的，但这一特性意味着虚函数表可以对来自CPU或GPU的方法调用有效，但不能同时对两者有效，因为不同处理器的可执行代码存储在不同的内存位置。当使用GPU进行渲染时，能够同时从两个处理器调用方法是有用的。
]

#parec[
  For all the code that just calls methods of polymorphic objects, the use of `pbrt`'s #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] in place of virtual functions makes no difference other than the fact that method calls are made using the `.` operator, just as would be used for a C++ reference.@spectrum-interface , which introduces #link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`];, the first class based on #link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] that occurs in the book, has more details about how `pbrt`'s dynamic dispatch scheme is implemented.
][
  对于所有仅调用多态对象方法的代码，使用`pbrt`的#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];代替虚函数除了方法调用使用`.`操作符（就像使用C++引用一样）之外没有区别，只是@spectrum-interface 介绍了#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`];，这是书中基于#link("../Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`];的第一个类，提供了有关`pbrt`动态分派方案实现的更多细节。
]


=== Code Optimization
<code-optimization>
#parec[
  We have tried to make `pbrt` efficient through the use of well-chosen algorithms rather than through local micro-optimizations, so that the system can be more easily understood. However, efficiency is an integral part of rendering, and so we discuss performance issues throughout the book.
][
  我们尝试通过使用精心挑选的算法而不是局部微优化来提高 `pbrt` 的效率，以便系统更容易理解。然而，效率是渲染的一个重要组成部分，因此我们讨论性能的话题会贯穿整本书。
]

#parec[
  For both CPUs and GPUs, processing performance continues to grow more quickly than the speed at which data can be loaded from main memory into the processor. This means that waiting for values to be fetched from memory can be a major performance limitation. The most important optimizations that we discuss relate to minimizing unnecessary memory access and organizing algorithms and data structures in ways that lead to coherent access patterns; paying attention to these issues can speed up program execution much more than reducing the total number of instructions executed.
][
  对于 CPU 和 GPU，处理性能的增长速度仍然快于数据从主存储器加载到处理器的速度。这意味着等待从内存中获取值可能是一个主要的性能限制。我们讨论的最重要的优化涉及最小化不必要的内存访问，并以导致一致访问模式的方式组织算法和数据结构；关注这些问题可以比减少执行的指令总数更大幅度地加快程序执行速度。
]

=== Debugging and Logging
<debugging-and-logging>
#parec[
  Debugging a renderer can be challenging, especially in cases where the result is correct most of the time but not always.`pbrt` includes a number of facilities to ease debugging.
][
  调试渲染器可能具有挑战性，特别是在结果大多数时候是正确的但并不总是如此的情况下。`pbrt` 包含许多工具来简化调试。
]

#parec[
  One of the most important is a suite of unit tests. We have found unit testing to be invaluable in the development of `pbrt` for the reassurance it gives that the tested functionality is very likely to be correct. Having this assurance relieves the concern behind questions during debugging such as "am I sure that the hash table that is being used here is not itself the source of my bug?" Alternatively, a failing unit test is almost always easier to debug than an incorrect image generated by the renderer; many of the tests have been added along the way as we have debugged `pbrt`. Unit tests for a file `code.cpp` are found in `code_tests.cpp`. All the unit tests are executed by an invocation of the `pbrt_test` executable and specific ones can be selected via command-line options.
][
  其中最重要的是一系列单元测试。我们发现单元测试在 `pbrt` 的开发中是无价的，因为它提供了被测试功能很可能正确的信心。这种信心缓解了调试过程中诸如“我是否确定这里使用的哈希表本身不是我错误的来源？”等问题的担忧。相反，失败的单元测试几乎总是比渲染器生成的不正确图像更容易调试；许多测试是在我们调试 `pbrt` 的过程中添加的。文件 `code.cpp` 的单元测试位于 `code_tests.cpp` 中。所有单元测试通过调用 `pbrt_test` 可执行文件执行，并且可以通过命令行选项选择特定的测试。
]

#parec[
  There are many assertions throughout the `pbrt` codebase, most of them not included in the book text. These check conditions that should never be true and issue an error and exit immediately if they are found to be true at runtime.(See Section~#link("../Utilities/User_Interaction.html#sec:assertions")[B.3.6] for the definitions of the assertion macros used in `pbrt`.) A failed assertion gives a first hint about the source of an error; like a unit test, an assertion helps focus debugging, at least with a starting point. Some of the more computationally expensive assertions in `pbrt` are only enabled for debug builds; if the renderer is crashing or otherwise producing incorrect output, it is worthwhile to try running a debug build to see if one of those additional assertions fails and yields a clue.
][
  `pbrt` 代码库中有许多断言，其中大多数未包含在书中。这些检查不应该为真的条件，并在运行时发现为真时立即发出错误并退出。（有关 `pbrt` 中使用的断言宏的定义，请参见第 #link("../Utilities/User_Interaction.html#sec:assertions")[B.3.6] 节。）失败的断言提供了错误来源的第一个提示；像单元测试一样，断言有助于集中调试，至少提供了一个起点。`pbrt` 中一些计算量大的断言仅在调试构建中启用；如果渲染器崩溃或产生不正确的输出，尝试一下运行调试构建以查看这些额外的断言是否有失败并提供线索。
]

#parec[
  We have also endeavored to make the execution of `pbrt` at a given pixel sample deterministic. One challenge with debugging a renderer is a crash that only happens after minutes or hours of rendering computation. With deterministic execution, rendering can be restarted at a single pixel sample in order to more quickly return to the point of a crash.Furthermore, upon a crash `pbrt` will print a message such as "Rendering failed at pixel `(16, 27)` sample 821. Debug with `-debugstart 16,27,821`".The values printed after "debugstart" depend on the integrator being used, but are sufficient to restart its computation close to the point of a crash.
][
  我们还努力使 `pbrt` 在给定像素样本时的执行是确定性执行。调试渲染器的一个挑战是崩溃仅在渲染计算几分钟或几小时后发生。通过确定性执行，可以在单个像素样本处重新开始渲染，以便更快地返回到崩溃点。此外，`pbrt` 在崩溃时会打印一条消息，例如“渲染在像素 `(16, 27)` 样本 821 处失败。使用 `-debugstart 16,27,821` 进行调试”。"debugstart"后打印的值取决于所使用的积分器，但足以在接近崩溃点的地方重新启动计算。
]

#parec[
  Finally, it is often useful to print out the values stored in a data structure during the course of debugging. We have implemented `ToString()` methods for nearly all of `pbrt`'s classes. They return a `std::string` representation of them so that it is easy to print their full object state during program execution. Furthermore,`pbrt`'s custom #link("../Utilities/User_Interaction.html#Printf")[`Printf()`] and #link("../Utilities/User_Interaction.html#StringPrintf")[`StringPrintf()`] functions (Section~#link("../Utilities/User_Interaction.html#sec:pbrt-printf")[B.3.3];) automatically use the string returned by `ToString()` for an object when a `%s` specifier is found in the formatting string.
][
  最后，在调试过程中打印出存储在数据结构中的值通常很有用。我们为几乎所有 `pbrt` 的类实现了 `ToString()` 方法。它们返回一个 `std::string` 表示，以便在程序执行期间轻松打印其完整的对象状态。此外，`pbrt` 的自定义 #link("../Utilities/User_Interaction.html#Printf")[`Printf()`] 和 #link("../Utilities/User_Interaction.html#StringPrintf")[`StringPrintf()`] 函数（第 #link("../Utilities/User_Interaction.html#sec:pbrt-printf")[B.3.3] 节）在格式化字符串中发现 `%s` 说明符时自动使用 `ToString()` 返回的字符串表示对象。
]

=== Parallelism and Thread Safety
<parallelism-and-thread-safety>


#parec[
  In `pbrt` (as is the case for most ray tracers), the vast majority of data at rendering time is read only (e.g., the scene description and texture images). Much of the parsing of the scene file and creation of the scene representation in memory is done with a single thread of execution #footnote[Exceptions include the fact that we try to load image maps and binary geometry files in parallel, some image resampling performed on texture images, ndconstruction of one variant of the `BVHAggregate` , though all of these are highly localized.], so there are few synchronization issues during that phase of execution. During rendering, concurrent read access to all the read-only data by multiple threads works with no problems on both the CPU and the GPU; we only need to be concerned with situations where data in memory is being modified.
][
  在 `pbrt` 中（与大多数光线追踪器一样），渲染时的大多数数据都是只读的（例如，场景描述和纹理图像）。场景文件的解析和场景表示在内存中的创建大多由单线程执行#footnote[例外情况包括我们尝试并行加载图像映射和二进制几何文件，对纹理图像进行的一些图像重采样，以及构建`BVHAggregate`的一个变体，尽管所有这些都是高度局部化的。]，因此在执行的这一阶段几乎没有同步问题。在渲染期间，多个线程对所有只读数据的并发读取访问在 CPU 和 GPU 上都没有问题；我们只需关注内存中数据被修改的情况。
]


#parec[
  As a general rule, the low-level classes and structures in the system are not thread-safe. For example, the #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] class, which stores three `float` values to represent a point in 3D space, is not safe for multiple threads to call methods that modify it at the same time.(Multiple threads can use `Point3f`s as read-only data simultaneously, of course.) The runtime overhead to make #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] thread-safe would have a substantial effect on performance with little benefit in return.
][
  作为一般规则，系统中的低级类和结构不是线程安全的。例如，#link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 类，它存储三个 `float` 值以表示 3D 空间中的一个点，不安全，无法让多个线程同时调用修改它的方法。（当然，多个线程可以同时将 `Point3f` 用作只读数据。）使 #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 线程安全的运行时开销将对性能产生重大影响，而收益却很小。
]

#parec[
  The same is true for classes like #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];,#link("../Geometry_and_Transformations/Normals.html#Normal3f")[`Normal3f`];,#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];,#link("../Geometry_and_Transformations/Transformations.html#Transform")[`Transform`];,`Quaternion`, and #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`];.These classes are usually either created at scene construction time and then used as read-only data or allocated on the stack during rendering and used only by a single thread.
][
  对于 #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`];、#link("../Geometry_and_Transformations/Normals.html#Normal3f")[`Normal3f`];、#link("../Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`];、#link("../Geometry_and_Transformations/Transformations.html#Transform")[`Transform`];、`Quaternion` 和 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 等类也是如此。这些类通常要么在场景构建时创建，然后用作只读数据，要么在渲染期间在堆栈上分配并仅由单个线程使用。
]

#parec[
  The utility classes #link("../Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[`ScratchBuffer`] (used for high-performance temporary memory allocation) and #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] (pseudo-random number generation) are also not safe for use by multiple threads; these classes store state that is modified when their methods are called, and the overhead from protecting modification to their state with mutual exclusion would be excessive relative to the amount of computation they perform. Consequently, in code like the #link("../Introduction/pbrt_System_Overview.html#ImageTileIntegrator::Render")[`ImageTileIntegrator::Render()`] method earlier,`pbrt` allocates per-thread instances of these classes on the stack.
][
  实用类 #link("../Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[`ScratchBuffer`];（用于高性能临时内存分配）和 #link("../Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`];（伪随机数生成）也不安全，无法由多个线程使用；这些类内存储了一些状态，当调用其方法时会状态被修改，而通过互斥保护其状态的开销相对于它们执行的计算量来说是过高的。因此，在像 #link("../Introduction/pbrt_System_Overview.html#ImageTileIntegrator::Render")[`ImageTileIntegrator::Render()`] 方法这样的代码中，`pbrt` 在堆栈上为这些类分配每线程实例。
]

#parec[
  With two exceptions, implementations of the base types listed in @tbl:plug-in-types are safe for multiple threads to use simultaneously. With a little care, it is usually straightforward to implement new instances of these base classes so they do not modify any shared state in their methods.
][
  除了两个例外，@tbl:plug-in-types-zh 中列出的基本类型的实现是安全的，可以由多个线程同时使用。只要稍加注意，通常很容易实现这些基本类的新实例，使它们在其方法中不修改任何共享状态。
]

#parec[
  The first exceptions are the #link("../Light_Sources/Light_Interface.html#Light")[`Light`] `Preprocess()` method implementations. These are called by the system during scene construction, and implementations of them generally modify shared state in their objects. Therefore, it is helpful to allow the implementer to assume that only a single thread will call into these methods.(This is a separate issue from the consideration that implementations of these methods that are computationally intensive may use #link("../Utilities/Parallelism.html#ParallelFor")[`ParallelFor()`] to parallelize their computation.)
][
  第一个例外是 #link("../Light_Sources/Light_Interface.html#Light")[`Light`] `Preprocess()` 方法的实现。系统在场景构建期间调用这些方法，它们的实现通常会修改对象中的共享状态。因此，允许实现者假设只有一个线程会调用这些方法是有帮助的。（这与考虑到这些方法的实现可能使用 #link("../Utilities/Parallelism.html#ParallelFor")[`ParallelFor()`] 来并行化其计算的考虑是分开的。）
]

#parec[
  The second exception is #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] class implementations; their methods are also not expected to be thread-safe. This is another instance where this requirement would impose an excessive performance and scalability impact; many threads simultaneously trying to get samples from a single #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] would limit the system's overall performance. Therefore, as described in @imagetileintegrator-and-the-main-rendering-loop, a unique #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] is created for each rendering thread using #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler::Clone")[`Sampler::Clone()`];.
][
  第二个例外是 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 类的实现；它们的方法也不需要是线程安全的。这是另一个要求，这种要求会对性能和可扩展性产生过大的影响；许多线程同时尝试从单个 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 获取样本将限制系统的整体性能。因此，如@imagetileintegrator-and-the-main-rendering-loop 所述，为每个渲染线程使用 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler::Clone")[`Sampler::Clone()`] 创建一个唯一的 #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`];。
]

#parec[
  All stand-alone functions in `pbrt` are thread-safe (as long as multiple threads do not pass pointers to the same data to them).
][
  `pbrt` 中的所有独立函数都是线程安全的（只要多个线程不将指针传递给相同的数据）。
]

=== Extending the System
<extending-the-system>
#parec[
  One of our goals in writing this book and building the `pbrt` system was to make it easier for developers and researchers to experiment with new (or old!) ideas in rendering. One of the great joys in computer graphics is writing new software that makes a new image; even small changes to the system can be fun to experiment with. The exercises throughout the book suggest many changes to make to the system, ranging from small tweaks to major open-ended research projects. Section~#link("../Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[C.4] in Appendix~#link("../Processing_the_Scene_Description.html#chap:API")[C] has more information about the mechanics of adding new implementations of the interfaces listed in @tbl:plug-in-types.
][
  我们编写这本书和构建 `pbrt` 系统的目标之一是让开发人员和研究人员更容易在渲染中试验新的（或经典的！）想法。计算机图形学中最大的乐趣之一是编写可以生成新图像的新软件；即使是对系统的小改动也可以很有趣地进行实验。整本书中的练习建议对系统进行许多更改，从小调整到重大开放式研究项目。附录 #link("../Processing_the_Scene_Description.html#chap:API")[C] 的第 #link("../Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[C.4] 节提供了有关添加 @tbl:plug-in-types-zh 中列出的接口的新实现的机制的更多信息。
]

=== Bugs
<bugs>
#parec[
  Although we made every effort to make `pbrt` as correct as possible through extensive testing, it is inevitable that some bugs are still present.
][
  尽管我们通过广泛的测试尽力使 `pbrt` 尽可能正确，但不可避免地仍然存在一些错误。
]

#parec[
  If you believe you have found a bug in the system, please do the following:
][
  如果您认为在系统中发现了错误，请执行以下操作：
]

#parec[
  + Reproduce the bug with an unmodified copy of the latest version of `pbrt`.

  + Check the online discussion forum and the bug-tracking system at #link("https://pbrt.org")[pbrt.org];. Your issue may be a known bug, or it may be a commonly misunderstood feature.
][
  + 使用最新版本的 `pbrt` 的未修改副本重现错误。

  + 检查在线讨论论坛和 #link("https://pbrt.org")[pbrt.org] 上的错误跟踪系统。您的问题可能是已知错误，也可能是常见的误解功能。
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + Try to find the simplest possible test case that demonstrates the bug. Many bugs can be demonstrated by scene description files that are just a few lines long, and debugging is much easier with a simple scene than a complex one.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 尝试找到尽可能简单的测试用例来演示错误。许多错误可以通过只有几行长的场景描述文件来演示，并且调试简单场景比复杂场景要容易得多。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 4)
    + Submit a detailed bug report using our online bug-tracking system. Make sure that you include the scene file that demonstrates the bug and a detailed description of why you think `pbrt` is not behaving correctly with the scene. If you can provide a patch that fixes the bug, all the better!
  ]
][
  #block[
    #set enum(numbering: "1.", start: 4)
    + 使用我们的在线错误跟踪系统提交详细的错误报告。确保您包括演示错误的场景文件以及详细描述您认为 `pbrt` 在场景中行为不正确的原因。如果您能提供修复错误的软件补丁，那就更好了！
  ]
]

#parec[
  We will periodically update the `pbrt` source code repository with bug fixes and minor enhancements.(Be aware that we often let bug reports accumulate for a few months before going through them; do not take this as an indication that we do not value them!) However, we will not make major changes to the `pbrt` source code so that it does not diverge from the system described here in the book.
][
  我们将定期更新 `pbrt` 源代码库以修复错误和进行小的增强。（请注意，我们通常会让错误报告积累几个月，然后再处理它们；不要因此认为我们不重视它们！）然而，我们不会对 `pbrt` 源代码进行重大更改，以免它与书中描述的系统有所不同。
]


