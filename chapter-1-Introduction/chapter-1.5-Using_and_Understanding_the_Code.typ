#import "../template.typ": parec, ez_caption, translator

== #ez_caption[Using and Understanding the Code][使用与理解代码]
<using-and-understanding-the-code>
#parec[
  The `pbrt` source code distribution is available from #link("https://pbrt.org")[pbrt.org]. The website also includes additional documentation, images rendered with `pbrt`, example scenes, errata, and links to a bug reporting system. We encourage you to visit the website and subscribe to the `pbrt` mailing list.
][
  `pbrt` 源代码分发包可以从 #link("https://pbrt.org")[pbrt.org] 获取。该网站还包括额外的文档、使用 `pbrt` 渲染的图像、示例场景、勘误表以及错误报告系统的链接。我们鼓励您访问该网站并订阅 `pbrt` 邮件列表。
]

#parec[
  `pbrt` is written in C++, but we have tried to make it accessible to non-C++ experts by limiting the use of esoteric features of the language. Staying close to the core language features also helps with the system's portability. We make use of C++'s extensive standard library whenever it is applicable but will not discuss the semantics of calls to standard library functions in the text. Our expectation is that the reader will consult documentation of the standard library as necessary.
][
`pbrt` 使用 C++ 编写。我们尽量少用语言中生僻的特性，让并非 C++ 专家的读者也能理解。主要使用核心语言特性，也有助于提高系统的可移植性。凡适合之处，我们都会使用功能丰富的 C++ 标准库，但不在正文中解释标准库函数调用的语义；读者可按需查阅标准库文档。
]

#parec[
  We will occasionally omit short sections of `pbrt`'s source code from the book. For example, when there are a number of cases to be handled, all with nearly identical code, we will present one case and note that the code for the remaining cases has been omitted from the text. Default class constructors are generally not shown, and the text also does not include details like the various `#include` directives at the start of each source file. All the omitted code can be found in the `pbrt` source code distribution.
][
  我们会偶尔在书中省略 `pbrt` 源代码的短小部分。例如，当有许多几乎相同代码的情况需要处理时，我们将展示一个案例，并注明其余案例的代码已从文本中省略。默认的类构造函数通常不显示，文本中也不包括每个源文件开头的各种 `#include` 指令等细节。所有省略的代码都可以在 `pbrt` 源代码分发包中找到。
]

=== #ez_caption[Source Code Organization][源代码组织]
<source-code-organization>
#parec[
  The source code used for building `pbrt` is under the `src` directory in the `pbrt` distribution. In that directory are `src/ext`, which has the source code for various third-party libraries that are used by `pbrt`,and `src/pbrt`, which contains `pbrt`'s source code. We will not discuss the third-party libraries' implementations in the book.
][
  用于构建 `pbrt` 的源代码位于 `pbrt` 分发的 `src` 目录下。在该目录中有 `src/ext`，其中包含 `pbrt` 使用的各种第三方库的源代码，以及 `src/pbrt`，其中包含 `pbrt` 的源代码。我们不会在书中讨论第三方库的实现细节。
]

#parec[
  The source files in the `src/pbrt` directory mostly consist of implementations of the various interface types. For example,#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[`shapes.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[`shapes.cpp`] have implementations of the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] interface,#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.h")[`materials.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.cpp")[`materials.cpp`] have materials, and so forth. That directory also holds the source code for parsing `pbrt`'s scene description files.
][
  `src/pbrt` 目录中的源文件主要由各种接口类型的实现代码组成。例如，#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.h")[`shapes.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/shapes.cpp")[`shapes.cpp`] 实现了 #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] 接口，#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.h")[`materials.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/materials.cpp")[`materials.cpp`] 实现了材质，等等。该目录还包含解析 `pbrt` 场景描述文件的源代码。
]

#parec[
  The #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] header file in `src/pbrt` is the first file that is included by all other source files in the system. It contains a few macros and widely useful forward declarations, though we have tried to keep it short and to minimize the number of other headers that it includes in the interests of compile time efficiency.
][
  `src/pbrt` 中的 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] 头文件是系统中所有其他源文件首先包含的文件。它包含了一些宏和广泛适用的前向声明，尽管我们尝试保持其简短，并尽量减少其包含的其他头文件数量，以缩短编译时间。
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
  - `base`：头文件定义了@tbl:plug-in-types 中列出的 12 种常见接口类型的接口（`Primitive` 和 `Integrator` 仅限于 CPU，因此在 `cpu` 目录中的文件中定义）。
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
    #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`],
    which is introduced in @wavefront-rendering-on-gpus. This integrator runs on both CPUs
    and GPUs.
][
  - `wavefront`：实现了@wavefront-rendering-on-gpus 介绍的
    #link("https://pbr-book.org/4ed/Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`]。该积分器在
    CPU 和 GPU 上运行。
]

=== #ez_caption[Naming Conventions][命名约定]
<naming-conventions>
#parec[
  Functions and classes are generally named using Camel case, with the first letter of each word capitalized and no delineation for spaces. One exception is some methods of container classes, which follow the naming convention of the C++ standard library when they have matching functionality (e.g.,`size()` and `begin()` and `end()` for iterators). Variables also use Camel case, though with the first letter lowercase, except for a few global variables.
][
函数和类通常使用驼峰命名：各单词首字母大写，单词间没有分隔符。容器类的部分方法是例外；如果功能与 C++ 标准库相同，就沿用其命名约定，例如 `size()`，以及用于迭代器的 `begin()` 和 `end()`。变量也采用驼峰命名，但除少数全局变量外，首字母小写。
]

#parec[
  We also try to match mathematical notation in naming: for example, we use variables like `p` for points $p$ and `w` for directions $omega$.We will occasionally add a `p` to the end of a variable to denote a primed symbol: `wp` for $omega '$. Underscores are used to indicate subscripts in equations: `theta_o` for $theta_o$, for example.
][
  我们还尝试在命名中匹配数学记法：例如，我们使用 `p` 表示点 $p$，使用 `w` 表示方向 $omega$。我们偶尔会在变量末尾添加一个 `p` 来表示加撇号的符号：`wp` 表示 $omega '$。下划线用于表示方程中的下标：例如，`theta_o` 表示 $theta_o$。
]

#parec[
  Our use of underscores is not perfectly consistent, however. Short variable names often omit the underscore—we use `wi` for $omega_i$ and we have already seen the use of `Li` for $L_i$. We also occasionally use an underscore to separate a word from a lowercase mathematical symbol. For example, we use `Sample_f` for a method that samples a function $f$ rather than `Samplef`, which would be more difficult to read, or `SampleF`, which would obscure the connection to the function $f$ ("where was the function $F$ defined?").
][
不过，我们对下划线的使用并不完全一致。短变量名常省略下划线，例如用 `wi` 表示 $omega_i$，前面也已见过用 `Li` 表示 $L_i$。有时还用下划线分隔单词与小写数学符号。例如，对函数 $f$ 进行采样的方法命名为 `Sample_f`，而不用较难辨读的 `Samplef`；也不用 `SampleF`，因为它会模糊与函数 $f$ 的联系，让人疑惑“函数 $F$ 是在哪里定义的？”。
]

=== #ez_caption[Pointer or Reference?][指针还是引用？]
<pointer-or-reference>
#parec[
  C++ provides two different mechanisms for passing an object to a function or method by reference: pointers and references. If a function argument is not intended as an output variable, either can be used to save the expense of passing the entire structure on the stack. The convention in `pbrt` is to use a pointer when the argument will be completely changed by the function or method, a reference when some of its internal state will be changed but it will not be fully reinitialized, and `const` references when it will not be changed at all. One important exception to this rule is that we will always use a pointer when we want to be able to pass `nullptr` to indicate that a parameter is not available or should not be used.
][
  C++ 提供了两种机制，通过引用机制将对象传递给函数或方法：指针和引用。如果函数参数不作为输出变量，可以使用任意一种来节省在栈上传递整个结构的开销。`pbrt` 的惯例是，当参数将被函数或方法完全更改时使用指针，当参数的一些内部状态将被更改但不会完全重新初始化时使用引用，当参数完全不会被更改时使用 `const` 引用。此规则的一个重要例外是，当需要传递 `nullptr` 以指示参数不可用或不应使用时，我们总是使用指针。
]


=== #ez_caption[Abstraction versus Efficiency][抽象与效率]
<abstraction-versus-efficiency>
#parec[
  One of the primary tensions when designing interfaces for software systems is making a reasonable trade-off between abstraction and efficiency. For example, many programmers religiously make all data in all classes `private` and provide methods to obtain or modify the values of the data items. For simple classes (e.g.,#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`]),we believe that approach needlessly hides a basic property of the implementation—that the class holds three floating-point coordinates—that we can reasonably expect to never change. Of course,using no information hiding and exposing all details of all classes' internals leads to a code maintenance nightmare, but we believe that there is nothing wrong with judiciously exposing basic design decisions throughout the system. For example, the fact that a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`] is represented with a point, a vector, a time, and the medium it is in is a decision that does not need to be hidden behind a layer of abstraction. Code elsewhere is shorter and easier to understand when details like these are exposed.
][
  在设计软件系统的接口时，主要的矛盾之一是如何合理权衡抽象和效率。例如，许多程序员习惯性地将所有类的数据设为 `private`，并提供方法来获取或修改数据项的值。对于简单的类（例如，#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`]），我们认为这种方法不必要地隐藏了实现的基本属性——即类持有三个浮点坐标——我们可以合理预期这一特性不会改变。当然，不进行信息隐藏并暴露所有类内部的细节会导致代码维护困难，但我们认为在整个系统中谨慎地公开基本设计决策没有问题。例如，#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#Ray")[`Ray`]由一个点、一个向量、一个时间和它所在的介质表示，这一决定不需要隐藏在抽象层之下。当这些细节被公开时，其他地方的代码会更简短且更易于理解。
]

#parec[
  An important thing to keep in mind when writing a software system and making these sorts of trade-offs is the expected final size of the system.`pbrt` is roughly 70,000 lines of code and it is never going to grow to be a million lines of code; this fact should be reflected in the amount of information hiding used in the system. It would be a waste of programmer time (and likely a source of runtime inefficiency) to design the interfaces to accommodate a system of a much higher level of complexity.
][
编写软件系统、作这类权衡时，应牢记系统预期的最终规模。`pbrt` 大约有 70,000 行代码，永远不会增长到一百万行；系统采用多少信息隐藏，应体现这一事实。若按照复杂度高得多的系统来设计接口，就会浪费程序员的时间，而且可能降低运行效率。
]

=== #ez_caption[pstd][pstd]
<pstd>
#parec[
  We have reimplemented a subset of the C++ standard library in the `pstd` namespace; this was necessary in order to use those parts of it interchangeably on the CPU and on the GPU. For the purposes of reading `pbrt`'s source code, anything in `pstd` provides the same functionality with the same type and methods as the corresponding entity in `std`. We will therefore not document usage of `pstd` in the text here.
][
我们在 `pstd` 命名空间中重新实现了 C++ 标准库的一个子集，以便这些功能能同样用于 CPU 和 GPU。就阅读 `pbrt` 源代码而言，`pstd` 中的实体与 `std` 中相应实体具有相同的类型、方法和功能。因此，正文不另行解释 `pstd` 的用法。
]

=== #ez_caption[Allocators][分配器]
<allocators>
#parec[
  Almost all dynamic memory allocation for the objects that represent the scene in `pbrt` is performed using an instance of an `Allocator` that is provided to the object creation methods. In `pbrt`,`Allocator` is shorthand for the C++ standard library's `pmr::polymorphic_allocator` type. Its definition is in #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] so that it is available to all other source files.
][
`pbrt` 中，用于表示场景的对象所需的动态内存，几乎都由传入对象创建方法的 `Allocator` 实例分配。`Allocator` 是 C++ 标准库类型 `pmr::polymorphic_allocator` 的简称。其定义放在 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/pbrt.h")[`pbrt.h`] 中，供其他源文件使用。
]

#block(sticky: true)[#raw("<<Define Allocator>>=")] <fragment-DefineAllocator-0>
```cpp
using Allocator = pstd::pmr::polymorphic_allocator<std::byte>;
```


#parec[
  `std::pmr::polymorphic_allocator` implementations provide a few methods for allocating and freeing objects. These three are used widely in `pbrt`:#footnote[Because `pmr::polymorphic_allocator` is a recent
addition to C++ that is not yet widely used, yet is widely used in
`pbrt`, we break our regular habit of not documenting standard library
functionality in the text here.]
][
  `std::pmr::polymorphic_allocator` 实现提供了一些用于分配和释放对象的方法。在 `pbrt` 中广泛使用以下三种方法：#footnote[因为 `pmr::polymorphic_allocator` 是 C++ 的一个最近添加的功能，尚未被广泛使用，但在 `pbrt` 中被广泛使用，因此我们打破了不在文本中记录标准库功能的常规习惯。]
]

```cpp
void *allocate_bytes(size_t nbytes, size_t alignment);
template <class T> T *allocate_object(size_t n = 1);
template <class T, class... Args> T *new_object(Args &&... args);
```
#parec[
  The first,`allocate_bytes()`, allocates the specified number of bytes of memory. Next,`allocate_object()` allocates an array of `n` objects of the specified type `T`, initializing each one with its default constructor. The final method,`new_object()`, allocates a single object of type `T` and calls its constructor with the provided arguments. There are corresponding methods for freeing each type of allocation: `deallocate_bytes()`,`deallocate_object()`, and `delete_object()`.
][
  第一个方法 `allocate_bytes()` 分配指定字节数的内存。接下来，`allocate_object()` 分配一个大小为 `n` 的指定类型 `T` 的数组，并用其默认构造函数初始化每个对象。最后一个方法 `new_object()` 分配一个类型为 `T` 的单个对象，并使用提供的参数调用其构造函数。对于每种类型的分配都有相应的释放方法：`deallocate_bytes()`，`deallocate_object()` 和 `delete_object()`。
]

#parec[
  A tricky detail related to the use of allocators with data structures from the C++ standard library is that a container's allocator is fixed once its constructor has run. Thus, if one container is assigned to another, the target container's allocator is unchanged even though all the values it stores are updated.(This is the case even with C++'s move semantics.) Therefore, it is common to see objects' constructors in `pbrt` passing along an allocator in member initializer lists for containers that they store even if they are not yet ready to set the values stored in them.
][
分配器与 C++ 标准库数据结构配合使用时，有一个容易忽略的细节：容器的构造函数运行之后，其分配器就固定了。因此，将一个容器赋值给另一个容器时，即使目标容器中存储的值全部更新，目标的分配器也不会改变。（即使用 C++ 的移动语义，情况也是如此。）所以，`pbrt` 中的对象构造函数经常会在成员初始化列表中向所含容器传递分配器，即便尚未准备好设置容器中的值。
]

#parec[
  Using an explicit memory allocator rather than direct calls to `new` and `delete` has a few advantages. Not only does it make it easy to do things like track the total amount of memory that has been allocated,but it also makes it easy to substitute allocators that are optimized for many small allocations, as is useful when building acceleration structures in @primitives-and-intersection-acceleration .Using allocators in this way also makes it easy to store the scene objects in memory that is visible to the GPU when GPU rendering is being used.
][
显式使用内存分配器，而不是直接调用 `new` 和 `delete`，有几个好处：既容易跟踪已分配的总内存量，也容易换用针对大量小块分配优化过的分配器；后者在 @primitives-and-intersection-acceleration 的加速结构构建中很有用。采用 GPU 渲染时，这种方式也便于将场景对象存放在 GPU 可访问的内存中。
]

=== #ez_caption[Dynamic Dispatch][动态分派]
<dynamic-dispatch>
#parec[
  As mentioned in @pbrt-system-overview, virtual functions are generally not used for dynamic dispatch with polymorphic types in `pbrt` (the main exception being the `Integrator`s). Instead, the #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] class is used to represent a pointer to one of a specified set of types; it includes machinery for runtime type identification and thence dynamic dispatch.(Its implementation can be found in Appendix #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#sec:tagged-pointer")[B.4.4].) Two considerations motivate its use.
][
如 @pbrt-system-overview 所述，`pbrt` 通常不用虚函数实现多态类型的动态分派，主要例外是 `Integrator`。系统改用 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 类，表示指向某个指定类型集合中一种类型的指针；它提供运行时类型识别以及据此进行动态分派的机制。（实现见附录 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#sec:tagged-pointer")[B.4.4]。）采用它有两个原因。
]

#parec[
  First, in C++, an instance of an object that inherits from an abstract base class includes a hidden virtual function table pointer that is used to resolve virtual function calls. On most modern systems, this pointer uses eight bytes of memory. While eight bytes may not seem like much, we have found that when rendering complex scenes with previous versions of `pbrt`, a substantial amount of memory would be used just for virtual function pointers for shapes and primitives. With the #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] class, there is no incremental storage cost for type information.
][
  首先，在 C++ 中，从抽象基类继承的对象实例包含隐藏的虚函数表指针，用于解析虚函数调用。在大多数现代系统中，该指针使用八个字节的内存。虽然八个字节看起来不多，但我们发现，在使用 `pbrt` 的早期版本渲染复杂场景时，仅仅用于形状和图元的虚函数指针就会消耗大量内存。使用 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`]类，类型信息没有额外的存储成本。
]

#parec[
  The other problem with virtual function tables is that they store function pointers that point to executable code. Of course, that's what they are supposed to do, but this characteristic means that a virtual function table can be valid for method calls from either the CPU or from the GPU, but not from both simultaneously, since the executable code for the different processors is stored at different memory locations. When using the GPU for rendering, it is useful to be able to call methods from both processors, however.
][
  虚函数表的另一个问题是它们存储指向可执行代码的函数指针。当然，这正是它们应该做的，但这一特性意味着虚函数表可以对来自 CPU 或 GPU 的方法调用有效，但不能同时对两者有效，因为不同处理器的可执行代码存储在不同的内存位置。当使用 GPU 进行渲染时，能够同时从两个处理器调用方法是有用的。
]

#parec[
  For all the code that just calls methods of polymorphic objects, the use of `pbrt`'s #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] in place of virtual functions makes no difference other than the fact that method calls are made using the `.` operator, just as would be used for a C++ reference.@spectrum-interface , which introduces #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`], the first class based on #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] that occurs in the book, has more details about how `pbrt`'s dynamic dispatch scheme is implemented.
][
对于只调用多态对象方法的代码，以 `pbrt` 的 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 代替虚函数，并不会改变其用法，唯一差别是用 `.` 运算符调用方法，如同使用 C++ 引用。@spectrum-interface 将介绍本书遇到的第一个基于 `TaggedPointer` 的类 #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#Spectrum")[`Spectrum`]，并更详细地说明 `pbrt` 的动态分派方案。
]


=== #ez_caption[Code Optimization][代码优化]
<code-optimization>
#parec[
  We have tried to make `pbrt` efficient through the use of well-chosen algorithms rather than through local micro-optimizations, so that the system can be more easily understood. However, efficiency is an integral part of rendering, and so we discuss performance issues throughout the book.
][
  我们尝试通过使用精心挑选的算法而不是局部微优化来提高 `pbrt` 的效率，以便系统更容易理解。然而，效率是渲染的一个重要组成部分，因此我们讨论性能的话题会贯穿整本书。
]

#parec[
  For both CPUs and GPUs, processing performance continues to grow more quickly than the speed at which data can be loaded from main memory into the processor. This means that waiting for values to be fetched from memory can be a major performance limitation. The most important optimizations that we discuss relate to minimizing unnecessary memory access and organizing algorithms and data structures in ways that lead to coherent access patterns; paying attention to these issues can speed up program execution much more than reducing the total number of instructions executed.
][
无论 CPU 还是 GPU，处理能力的增长都持续快于从主存向处理器传输数据的速度。因此，等待数据从内存取回，可能成为主要的性能瓶颈。我们讨论的关键优化包括减少不必要的内存访问，以及组织算法和数据结构以形成连贯的访问模式。关注这些问题，往往比减少执行的指令总数更能加快程序运行。
]

=== #ez_caption[Debugging and Logging][调试与日志]
<debugging-and-logging>
#parec[
  Debugging a renderer can be challenging, especially in cases where the result is correct most of the time but not always.`pbrt` includes a number of facilities to ease debugging.
][
  调试渲染器可能很困难，尤其是结果大多数时候正确、偶尔却出错时。`pbrt` 包含许多工具来简化调试。
]

#parec[
  One of the most important is a suite of unit tests. We have found unit testing to be invaluable in the development of `pbrt` for the reassurance it gives that the tested functionality is very likely to be correct. Having this assurance relieves the concern behind questions during debugging such as "am I sure that the hash table that is being used here is not itself the source of my bug?" Alternatively, a failing unit test is almost always easier to debug than an incorrect image generated by the renderer; many of the tests have been added along the way as we have debugged `pbrt`. Unit tests for a file `code.cpp` are found in `code_tests.cpp`. All the unit tests are executed by an invocation of the `pbrt_test` executable and specific ones can be selected via command-line options.
][
  其中最重要的是一系列单元测试。我们发现单元测试在 `pbrt` 的开发中是无价的，因为它提供了被测试功能很可能正确的信心。这种信心缓解了调试过程中诸如“我是否确定这里使用的哈希表本身不是我错误的来源？”等问题的担忧。此外，失败的单元测试几乎总是比渲染器生成的不正确图像更容易调试；许多测试是在我们调试 `pbrt` 的过程中添加的。文件 `code.cpp` 的单元测试位于 `code_tests.cpp` 中。所有单元测试通过调用 `pbrt_test` 可执行文件执行，并且可以通过命令行选项选择特定的测试。
]

#parec[
  There are many assertions throughout the `pbrt` codebase, most of them not included in the book text. These check conditions that should never be true and issue an error and exit immediately if they are found to be true at runtime.(See Section~#link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#sec:assertions")[B.3.6] for the definitions of the assertion macros used in `pbrt`.) A failed assertion gives a first hint about the source of an error; like a unit test, an assertion helps focus debugging, at least with a starting point. Some of the more computationally expensive assertions in `pbrt` are only enabled for debug builds; if the renderer is crashing or otherwise producing incorrect output, it is worthwhile to try running a debug build to see if one of those additional assertions fails and yields a clue.
][
  `pbrt` 代码库中有许多断言，其中大多数未包含在书中。原文将它们描述为检查“不应为真”的条件，并在条件为真时报错退出。#translator[固定上游本段与附录 B.3.6 的说明及 `CHECK(x)` 实现不一致：后者在实参条件不为真时报告致命错误。本段保留原文，并明确这一差异；编写代码时应以宏定义为准。]（有关 `pbrt` 中使用的断言宏的定义，请参见第 #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#sec:assertions")[B.3.6] 节。）失败的断言提供了错误来源的第一个提示；像单元测试一样，断言有助于集中调试，至少提供了一个起点。`pbrt` 中一些计算量大的断言仅在调试构建中启用；如果渲染器崩溃或产生不正确的输出，尝试一下运行调试构建以查看这些额外的断言是否有失败并提供线索。
]

#parec[
  We have also endeavored to make the execution of `pbrt` at a given pixel sample deterministic. One challenge with debugging a renderer is a crash that only happens after minutes or hours of rendering computation. With deterministic execution, rendering can be restarted at a single pixel sample in order to more quickly return to the point of a crash.Furthermore, upon a crash `pbrt` will print a message such as "Rendering failed at pixel `(16, 27)` sample 821. Debug with `--debugstart 16,27,821`".The values printed after "debugstart" depend on the integrator being used, but are sufficient to restart its computation close to the point of a crash.
][
我们还努力让 `pbrt` 对给定像素样本的执行具有确定性。渲染器调试的一大难题，是崩溃可能在渲染数分钟乃至数小时后才发生。有了确定性执行，就可以仅从一个像素样本重新开始渲染，更快回到崩溃位置。此外，`pbrt` 在崩溃时会输出类似这样的消息：“Rendering failed at pixel `(16, 27)` sample 821. Debug with `--debugstart 16,27,821`”。“debugstart”后的值取决于所用积分器，但足以在接近崩溃位置处重新开始计算。
]

#parec[
  Finally, it is often useful to print out the values stored in a data structure during the course of debugging. We have implemented `ToString()` methods for nearly all of `pbrt`'s classes. They return a `std::string` representation of them so that it is easy to print their full object state during program execution. Furthermore,`pbrt`'s custom #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#Printf")[`Printf()`] and #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#StringPrintf")[`StringPrintf()`] functions (Section~#link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#sec:pbrt-printf")[B.3.3]) automatically use the string returned by `ToString()` for an object when a `%s` specifier is found in the formatting string.
][
  最后，在调试过程中打印出存储在数据结构中的值通常很有用。我们为几乎所有 `pbrt` 的类实现了 `ToString()` 方法。它们返回一个 `std::string` 表示，以便在程序执行期间轻松打印其完整的对象状态。此外，`pbrt` 的自定义 #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#Printf")[`Printf()`] 和 #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#StringPrintf")[`StringPrintf()`] 函数（第 #link("https://pbr-book.org/4ed/Utilities/User_Interaction.html#sec:pbrt-printf")[B.3.3] 节）在格式化字符串中发现 `%s` 说明符时自动使用 `ToString()` 返回的字符串表示对象。
]

=== #ez_caption[Parallelism and Thread Safety][并行与线程安全]
<parallelism-and-thread-safety>


#parec[
  In `pbrt` (as is the case for most ray tracers), the vast majority of data at rendering time is read only (e.g., the scene description and texture images). Much of the parsing of the scene file and creation of the scene representation in memory is done with a single thread of execution #footnote[Exceptions include the fact that we try to load image maps and binary geometry files in parallel, some image resampling performed on texture images, and construction of one variant of the `BVHAggregate` , though all of these are highly localized.], so there are few synchronization issues during that phase of execution. During rendering, concurrent read access to all the read-only data by multiple threads works with no problems on both the CPU and the GPU; we only need to be concerned with situations where data in memory is being modified.
][
  在 `pbrt` 中（与大多数光线追踪器一样），渲染时的大多数数据都是只读的（例如，场景描述和纹理图像）。场景文件的解析和场景表示在内存中的创建大多由单线程执行#footnote[例外情况包括我们尝试并行加载图像贴图和二进制几何文件，对纹理图像进行的一些图像重采样，以及构建 `BVHAggregate` 的一个变体，尽管所有这些都是高度局部化的。]，因此在执行的这一阶段几乎没有同步问题。在渲染期间，多个线程对所有只读数据的并发读取访问在 CPU 和 GPU 上都没有问题；我们只需关注内存中数据被修改的情况。
]


#parec[
  As a general rule, the low-level classes and structures in the system are not thread-safe. For example, the #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] class, which stores three `float` values to represent a point in 3D space, is not safe for multiple threads to call methods that modify it at the same time.(Multiple threads can use `Point3f`s as read-only data simultaneously, of course.) The runtime overhead to make #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] thread-safe would have a substantial effect on performance with little benefit in return.
][
一般而言，系统中的底层类和结构不保证线程安全。例如，#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 用三个 `float` 值表示三维空间中的点；多个线程若同时调用会修改同一个对象的方法，就不安全。（当然，多个线程可以同时将 `Point3f` 对象作为只读数据使用。）为 `Point3f` 提供线程安全保证，会带来显著的运行时开销，收益却很小。
]

#parec[
  The same is true for classes like #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`],#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Normals.html#Normal3f")[`Normal3f`],#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`],#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[`Transform`],`Quaternion`, and #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`]. These classes are usually either created at scene construction time and then used as read-only data or allocated on the stack during rendering and used only by a single thread.
][
  对于 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`]、#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Normals.html#Normal3f")[`Normal3f`]、#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledSpectrum")[`SampledSpectrum`]、#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#Transform")[`Transform`]、`Quaternion` 和 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[`SurfaceInteraction`] 等类也是如此。这些类通常要么在场景构建时创建，然后用作只读数据，要么在渲染期间在堆栈上分配并仅由单个线程使用。
]

#parec[
  The utility classes #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[`ScratchBuffer`] (used for high-performance temporary memory allocation) and #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`] (pseudo-random number generation) are also not safe for use by multiple threads; these classes store state that is modified when their methods are called, and the overhead from protecting modification to their state with mutual exclusion would be excessive relative to the amount of computation they perform. Consequently, in code like the #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#ImageTileIntegrator::Render")[`ImageTileIntegrator::Render()`] method earlier,`pbrt` allocates per-thread instances of these classes on the stack.
][
工具类 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#ScratchBuffer")[`ScratchBuffer`]（用于高性能临时内存分配）和 #link("https://pbr-book.org/4ed/Utilities/Mathematical_Infrastructure.html#RNG")[`RNG`]（用于伪随机数生成）也不支持多个线程安全地共同使用。调用方法会修改它们保存的状态；相对于其计算量，用互斥机制保护这些修改的开销过高。因此，在前面的 #link("https://pbr-book.org/4ed/Introduction/pbrt_System_Overview.html#ImageTileIntegrator::Render")[`ImageTileIntegrator::Render()`] 等代码中，`pbrt` 在栈上为各个线程分别分配这些类的实例。#translator[“在栈上”是本段原文表述。固定上游 1.3.4 使用 `ThreadLocal` 管理实例，附录 B.6 的实现把对象存放在 `std::vector` 哈希表中；不能将这些实例的最终存储位置一概视为线程栈。]
]

#parec[
  With two exceptions, implementations of the base types listed in @tbl:plug-in-types are safe for multiple threads to use simultaneously. With a little care, it is usually straightforward to implement new instances of these base classes so they do not modify any shared state in their methods.
][
  除了两个例外，@tbl:plug-in-types 中列出的基本类型的实现是安全的，可以由多个线程同时使用。只要稍加注意，通常很容易实现这些基本类的新实例，使它们在其方法中不修改任何共享状态。
]

#parec[
  The first exceptions are the #link("https://pbr-book.org/4ed/Light_Sources/Light_Interface.html#Light")[`Light`] `Preprocess()` method implementations. These are called by the system during scene construction, and implementations of them generally modify shared state in their objects. Therefore, it is helpful to allow the implementer to assume that only a single thread will call into these methods.(This is a separate issue from the consideration that implementations of these methods that are computationally intensive may use #link("https://pbr-book.org/4ed/Utilities/Parallelism.html#ParallelFor")[`ParallelFor()`] to parallelize their computation.)
][
  第一个例外是 #link("https://pbr-book.org/4ed/Light_Sources/Light_Interface.html#Light")[`Light`] `Preprocess()` 方法的实现。系统在场景构建期间调用这些方法，它们的实现通常会修改对象中的共享状态。因此，允许实现者假设只有一个线程会调用这些方法是有帮助的。（至于这些方法的实现若计算量很大，可能在内部使用 #link("https://pbr-book.org/4ed/Utilities/Parallelism.html#ParallelFor")[`ParallelFor()`] 并行计算，则是另一回事。）
]

#parec[
  The second exception is #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] class implementations; their methods are also not expected to be thread-safe. This is another instance where this requirement would impose an excessive performance and scalability impact; many threads simultaneously trying to get samples from a single #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] would limit the system's overall performance. Therefore, as described in @imagetileintegrator-and-the-main-rendering-loop, a unique #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] is created for each rendering thread using #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler::Clone")[`Sampler::Clone()`].
][
第二个例外是 #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`] 的实现，其方法同样不要求线程安全。要求它们线程安全，也会给性能和可扩展性带来过大负担：许多线程同时尝试从同一个 `Sampler` 获取样本，会限制整个系统的性能。因此，如 @imagetileintegrator-and-the-main-rendering-loop 所述，系统使用 #link("https://pbr-book.org/4ed/Sampling_and_Reconstruction/Sampling_Interface.html#Sampler::Clone")[`Sampler::Clone()`] 为每个渲染线程创建各自独有的 `Sampler`。
]

#parec[
  All stand-alone functions in `pbrt` are thread-safe (as long as multiple threads do not pass pointers to the same data to them).
][
`pbrt` 中的所有独立函数都是线程安全的，前提是多个线程不向它们传入指向同一份数据的指针。
]

=== #ez_caption[Extending the System][扩展系统]
<extending-the-system>
#parec[
  One of our goals in writing this book and building the `pbrt` system was to make it easier for developers and researchers to experiment with new (or old!) ideas in rendering. One of the great joys in computer graphics is writing new software that makes a new image; even small changes to the system can be fun to experiment with. The exercises throughout the book suggest many changes to make to the system, ranging from small tweaks to major open-ended research projects. Section~#link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[C.4] in Appendix~#link("https://pbr-book.org/4ed/Processing_the_Scene_Description.html#chap:API")[C] has more information about the mechanics of adding new implementations of the interfaces listed in @tbl:plug-in-types.
][
  我们编写这本书和构建 `pbrt` 系统的目标之一是让开发人员和研究人员更容易在渲染中试验新的（或经典的！）想法。计算机图形学中最大的乐趣之一是编写可以生成新图像的新软件；即使是对系统的小改动也可以很有趣地进行实验。整本书中的练习建议对系统进行许多更改，从小调整到重大开放式研究项目。附录 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description.html#chap:API")[C] 的第 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description/Adding_New_Object_Implementations.html#sec:adding-plugins")[C.4] 节提供了有关添加 @tbl:plug-in-types 中列出的接口的新实现的机制的更多信息。
]

=== #ez_caption[Bugs][程序错误]
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

  + Check the online discussion forum and the bug-tracking system at #link("https://pbrt.org")[pbrt.org]. Your issue may be a known bug, or it may be a commonly misunderstood feature.
][
  + 使用最新版本的 `pbrt` 的未修改副本重现错误。

  + 检查在线讨论论坛和 #link("https://pbrt.org")[pbrt.org] 上的错误跟踪系统。您的问题可能是已知错误，也可能是容易被误解的功能。
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


