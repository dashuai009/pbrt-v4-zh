#import "../template.typ": parec, ez_caption

== Mapping Path Tracing to the GPU
<mapping-path-tracing-to-the-gpu>
#parec[
  Achieving good performance on GPUs requires some care in how computation is organized and how data is laid out in memory. We will start with an overview of how GPUs work and the ways in which they differ from CPUs. This foundation makes it possible to discuss the design space of GPU ray tracers. After summarizing some of the alternatives, we give an overview of the design of the wavefront path integrator, which subsequent sections will delve into more deeply.
][
  在GPU上实现良好的性能需要仔细考虑计算的组织和数据在内存中的布局。我们将从GPU的工作原理概述及其与CPU的不同之处开始。这一基础使我们能够讨论GPU光线追踪器的设计空间。在总结一些替代方案后，我们将概述波前路径积分器的设计，后续章节将更深入地探讨。
]

=== Basic GPU Architecture
<basic-gpu-architecture>
#parec[
  The performance difference between CPUs and GPUs stems from a fundamental difference in the computations that they are designed for. CPUs have long been designed to minimize #emph[latency];—to run a single thread of computation as efficiently as possible, finishing its work as quickly as possible. (This has somewhat changed with the advent of multicore CPUs, though each core remains latency optimized.) In contrast, GPUs target #emph[throughput];: they are designed to work on many computations in parallel and finish all of them quickly, which is a different thing than finishing any one of them as quickly as possible.
][
  CPU和GPU之间的性能差异源于它们设计用于的计算的根本不同。CPU长期以来的设计目标是最小化#emph[延迟];——尽可能高效地运行单线程计算，尽快完成其工作。（随着多核CPU的出现，这种情况有所改变，尽管每个核心仍然是延迟优化的。）相比之下，GPU则专注于#emph[吞吐量];：它们被设计为并行处理许多计算，并快速完成所有这些计算，这与尽可能快地完成任何一个计算是不同的。
]

#parec[
  The focus on throughput allows GPUs to devote much less space on the chip for caches, branch prediction hardware, out-of-order execution units, and other features that have been invented to improve single-thread performance on CPUs. Thus, given a fixed amount of chip area, GPUs are able to provide many more of the arithmetic logic units (ALUs) that actually perform computation than a CPU provides. Yet, more ALUs do not necessarily deliver more performance: they must be kept occupied doing useful work.
][
  专注于吞吐量使得GPU可以在芯片上为缓存、分支预测硬件、乱序执行单元和其他为提高CPU单线程性能而发明的功能分配更少的空间。因此，给定固定的芯片面积，GPU能够提供比CPU更多的算术逻辑单元（ALU）。然而，更多的算术逻辑单元并不一定能带来更高的性能：它们必须保持忙碌以进行有用的工作。
]

#parec[
  An ALU cannot perform computation if the input values it requires are not available. On current processors, reading a value from memory consumes a few hundred processor cycles, and so it is important to avoid the situation where a processor remains idle while it waits for the completion of such read operations—substantial amounts of potential computation might be lost. CPUs and GPUs approach this problem quite differently. Understanding each helps illuminate their philosophical differences.
][
  如果算术逻辑单元所需的输入值不可用，则无法进行计算。在当前的处理器上，从内存读取一个值需要消耗几百个处理器周期，因此避免处理器在等待这些读取操作完成时处于空闲状态是很重要的——可能会损失大量潜在的计算。CPU和GPU对此问题的处理方式截然不同。理解每一种方式有助于阐明它们的哲学差异。
]

#parec[
  CPUs apply a barrage of techniques to this task. They feature a relatively large amount of on-chip memory in the form of caches; if a memory request targets a location that is already present in a cache, the result can be returned much more quickly than reading from dynamic random access memory (DRAM). Cache memory access typically takes from a handful of cycles to at most a few tens of them. When it is necessary to wait for a memory read, CPUs also use out-of-order execution, continuing to execute the program's instructions past the read instruction. Dependencies are carefully tracked during this process, and operations that are independent of pending computations can execute out of order. The CPU may also execute instructions speculatively, ready to roll back their effects if it turns out they should not have run. If all of that does not suffice, another thread may be available, ready to start executing—modern CPUs generally use #emph[hyperthreading] to switch to another thread in the event of a stall. This thread switch can be performed without any overhead, which is much better than the thousands of processor cycles it takes for the operating system to perform a context switch.
][
  CPU采用了一系列技术来完成这项任务。它们在芯片上配备了相对大量的缓存内存；如果内存请求目标是缓存中已经存在的位置，则结果可以比从动态随机存取存储器（DRAM）读取更快地返回。缓存内存访问通常需要少数几个周期到最多几十个周期。当必须等待内存读取时，CPU还使用乱序执行，继续执行程序的指令，超出读取指令。在此过程中，依赖关系被仔细跟踪，与待处理计算无关的操作可以乱序执行。 CPU还可能投机性地执行指令，准备在发现它们不应该运行时回滚其效果。如果所有这些都不足以解决问题，可能还有另一个线程可以使用，准备开始执行——现代CPU通常使用#emph[超线程];技术在发生停顿时切换到另一个线程。此线程切换可以在没有任何开销的情况下执行，这比操作系统执行上下文切换所需的数千个处理器周期要好得多。
]

#parec[
  GPUs instead focus on a single mechanism to address such latencies: much more aggressive thread switching, over many more threads than are used for hyperthreading on CPUs. If one thread reads from memory, a GPU will just switch to another, saving all of the complexity and chip area required for out-of-order execution logic. If that other thread issues a read, then yet another is scheduled. Given enough threads and computation between memory accesses, such an approach is sufficient to keep the ALUs fed with useful work while avoiding long periods of inactivity.
][
  GPU则专注于单一机制来解决此类延迟：比CPU上的超线程使用更多线程的更激进的线程切换。如果一个线程从内存读取，GPU只会切换到另一个线程，从而节省了乱序执行逻辑所需的所有复杂性和芯片面积。如果另一个线程发出读取请求，则会调度另一个线程。给定足够多的线程和内存访问之间的计算，这种方法足以在避免长时间不活动的同时为算术逻辑单元提供有用的工作。
]

#parec[
  An implication of this design is that GPUs require much more parallelism than CPUs to run at their peak potential. While tens of threads—or at most a few hundred—suffice to fully utilize a modern multicore CPU, a GPU may require tens of thousands of them. Path tracing fortunately involves millions of independent calculations (one per pixel sample), which makes it a good fit for throughput-oriented architectures like GPUs.
][
  这种设计意味着GPU需要比CPU更多的并行性才能达到其峰值潜力。虽然几十个线程——或最多几百个——足以充分利用现代多核CPU，但GPU可能需要数万个线程。幸运的是，路径追踪涉及数百万个独立的计算（每个像素样本一个），这使得它非常适合像GPU这样的面向吞吐量的架构。
]

==== Thread Execution
<thread-execution>
#parec[
  GPUs contain an array of independent processors, numbered from the tens up to nearly a hundred at writing. We will not often need to consider these in the following, but will denote them as #emph[processors];. Each one typically executes 32 or 64 threads concurrently, with as many as a thousand threads available to be scheduled.
][
  GPU包含一个独立处理器的阵列，数量从几十个到写作时接近一百个。在接下来的内容中，我们不需要经常考虑这些，但会将它们称为#emph[处理器];。每个处理器通常同时执行32或64个线程，并且可以调度多达一千个线程。
]

#parec[
  The execution model of GPUs centers around the concept of a #emph[kernel];, which refers to a GPU-targeted function that is executed by a specified number of threads. Parameters passed to the kernel are forwarded to each thread; a #emph[thread index] provides the information needed to distinguish one thread from another. #emph[Launching] a kernel refers to the operation that informs the GPU that a particular kernel function should be executed concurrently. This differs from an ordinary function call in the sense that the kernel will complete asynchronously at some later point. Frameworks like CUDA provide extensive API functionality to wait for the conclusion of such asynchronous computation, or to enforce ordering constraints between multiple separate kernel launches. Launching vast numbers of threads on the GPU is extremely efficient, so there is no need to amortize this cost using a thread pool, as is done in `pbrt`'s #link("../Utilities/Parallelism.html#ThreadPool")[`ThreadPool`] class for CPU parallelism.
][
  GPU的执行模型围绕#emph[内核];的概念展开，内核是指由指定数量的线程执行的面向GPU的函数。传递给内核的参数会转发给每个线程；#emph[线程索引];提供了区分一个线程与另一个线程所需的信息。#emph[启动];内核是指通知GPU某个特定内核函数应并发执行的操作。这与普通函数调用不同，因为内核将在稍后的某个时间点异步完成。 像CUDA这样的框架提供了广泛的API功能，以等待这种异步计算的结束，或在多个单独的内核启动之间强制执行顺序约束。在GPU上启动大量线程是非常高效的，因此不需要像在`pbrt`的#link("../Utilities/Parallelism.html#ThreadPool")[`ThreadPool`];类中为CPU并行化所做的那样使用线程池来摊销这种成本。
]

#parec[
  Kernels may be launched both from the CPU and from the GPU, though `pbrt` only does the former. In contrast to an ordinary function call, a kernel launch cannot return any values to the caller. Kernels therefore must write their results to memory before exiting.
][
  内核可以从CPU和GPU启动，尽管`pbrt`只执行前者。与普通函数调用不同，内核启动不能向调用者返回任何值。因此，内核必须在退出之前将其结果写入内存。
]

#parec[
  An important hardware simplification that distinguishes CPUs and GPUs is that GPUs bundle multiple threads into what we will refer to as a #emph[thread group];#footnote[This term corresponds to a  _subgroup_  in
OpenCL and Vulkan, a _warp_ in CUDA's model, and a _wavefront_ on
AMD GPUs.]. This group (32 threads on most current GPUs) executes instructions together, which means that a single instruction decoder can be shared by the group instead of requiring one for each executing thread. Consequently, silicon die area that would ordinarily be needed for instruction decoding can be dedicated to improving parallelism in the form of additional ALUs. Most GPU programming models further organize thread groups into larger aggregations—though these are not used in `pbrt`'s GPU implementation, so we will not discuss them further here.
][
  区分CPU和GPU的重要硬件简化是，GPU将多个线程捆绑成我们称之为#emph[线程组];#footnote[该术语对应于 OpenCL 和 Vulkan 中的_子组（subgroup）_，CUDA 模型中的_warp（波束）_，以及 AMD GPU 上的_wavefront（波前）_。]。这个组（大多数当前GPU上的32个线程）一起执行指令，这意味着一个指令解码器可以由该组共享，而不是每个执行线程都需要一个。因此，通常用于指令解码的硅片面积可以用于以额外算术逻辑单元的形式提高并行性。 大多数GPU编程模型进一步将线程组组织成更大的聚合——尽管这些在`pbrt`的GPU实现中没有使用，因此我们在此不再讨论。
]

#parec[
  While the hardware simplifications enabled by thread groups allow for additional parallelism, the elimination of per-thread instruction decoders also brings limitations that can have substantial performance implications. Efficient GPU implementation of algorithms requires a thorough understanding of them. Although the threads in a thread group are free to work independently, just as the threads on different CPU cores are, the more that they follow similar paths through the program, the better performance will be achieved. This is a different performance model than for CPUs and can be a subtle point to consider when optimizing code: performance is not just a consequence of the computation performed by an individual thread, but also how often that same computation is performed at the same time with other threads within the same group.
][
  虽然线程组启用的硬件简化允许额外的并行性，但消除每线程指令解码器也带来了可能对性能产生重大影响的限制。算法的高效GPU实现需要对其有透彻的理解。 尽管线程组中的线程可以像不同CPU核心上的线程一样独立工作，但它们越是遵循相似的程序路径，性能就越好。这与CPU的性能模型不同，在优化代码时需要仔细考虑：性能不仅仅是单个线程执行的计算的结果，还取决于同一组内其他线程同时执行相同计算的频率。
]

#parec[
  For example, consider this simple block of code:
][
  例如，考虑这个简单的代码块：
]
```cpp
if (condition) a();
else b();
```

#parec[
  Executed on a CPU, the processor will test the condition and then execute either `a()` or `b()` depending on the condition's value. On a GPU, the situation is more complex: if all the threads in a thread group follow the same control flow path, then execution proceeds as it does on a CPU.
][
  在CPU上执行时，处理器将测试条件，然后根据条件的值执行`a()`或`b()`。在GPU上，情况更复杂：如果线程组中的所有线程都遵循相同的控制流路径，则执行过程与CPU一样。
]

#parec[
  However, if some threads need to evaluate `a()` and some `b()`, then the GPU will execute both functions' instructions with a subset of the threads disabled for each one. These disabled threads represent a wasted opportunity to perform useful work.
][
  然而，如果某些线程需要评估`a()`而另一些需要`b()`，则GPU将执行两个函数的指令，并为每个函数禁用一部分线程。这些禁用的线程代表了一个浪费的机会来执行有用的工作。
]

#parec[
  In the worst case, a computation could be serialized all the way down to the level of individual threads, resulting in a $32$ times loss of performance that would largely negate the benefits of the GPU. Algorithms like path tracing are especially susceptible to this type of behavior, which is a consequence of the physical characteristics of light: when a beam of light interacts with an object, it will tend to spread out and eventually reach every part of the environment with nonzero probability. Suppose that a bundle of rays is processed by a thread group: due to this property, an initially coherent computation could later encounter many different shapes and materials that are implemented in different parts of the system. Additional work is necessary to reorder computation into coherent groups to avoid such degenerate behavior.
][
  在最坏的情况下，计算可能会被序列化到单个线程的级别，导致性能损失32倍，这将大大削弱GPU的优势。像路径追踪这样的算法特别容易受到这种行为的影响，这是光的物理特性的结果：当一束光与物体相互作用时，它会倾向于扩散并最终以非零概率到达环境的每个部分。 假设一束光线由一个线程组处理：由于这种特性，最初一致的计算可能会在以后遇到许多不同的形状和材料，这些形状和材料在系统的不同部分实现。需要额外的工作来将计算重新排序为一致的组，以避免这种退化行为。
]

#parec[
  The implementation of the #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatMixTexture::Evaluate")[`FloatMixTexture::Evaluate()`] method from @mix-textures can be better understood with thread groups in mind. Its body was:
][
  @mix-textures 中#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatMixTexture::Evaluate")[`FloatMixTexture::Evaluate()`];方法的实现，其主体是：
]

```cpp
Float amt = amount.Evaluate(ctx);
Float t1 = 0, t2 = 0;
if (amt != 1) t1 = tex1.Evaluate(ctx);
if (amt != 0) t2 = tex2.Evaluate(ctx);
return (1 - amt) * t1 + amt * t2;
```

#parec[
  A more natural implementation might have been the following, which computes the same result in the end:
][
  一个更自然的实现可能是以下内容，最终计算出相同的结果：
]

```cpp
Float amt = amount.Evaluate(ctx);
if (amt == 0) return tex1.Evaluate(ctx);
if (amt == 1) return tex2.Evaluate(ctx);
return (1 - amt) * tex1.Evaluate(ctx) + amt * tex2.Evaluate(ctx);
```

#parec[
  Considered under the lens of GPU execution, we can see the benefit of the first implementation. If some of the threads have a value of 0 for `amt`, some have a value of 1, and the rest have a value in between, then the second implementation will execute the code for evaluating `tex1` and `tex2` twice, for a different subset of threads for each time. #footnote[
This assumes that the compiler is unable to
automatically restructure the code in the way that we have done manually.
It might, but it might not; our experience has been that it is best not to
expect too much of compilers in such ways, lest they disappoint.
  ] With the first implementation, all of the threads that need to evaluate `tex1` do so together, and similarly for `tex2`.
][
  从GPU执行的视角下，我们可以看到第一个实现的好处。如果一些线程的`amt`值为0，一些为1，其余的在两者之间，那么第二个实现将两次执行评估`tex1`和`tex2`的代码，每次为不同的线程子集执行。#footnote[这是假设编译器无法像我们手动调整代码那样自动重新组织代码。编译器可能会做到，也可能不会；我们的经验是，不要对编译器在这方面的能力抱有过高期待，以免失望。] 使用第一个实现，所有需要评估`tex1`的线程一起执行，`tex2`也是如此。
]

#parec[
  We will say that execution across a thread group is #emph[converged] when all of the threads follow the same control flow path through the program, and that it has become #emph[divergent] at points in the program execution where some threads follow one path and others follow another through the program code. Some divergence is inevitable, but the less there is the better. Convergence can be improved both by writing individual blocks of code to minimize the number of separate control paths and by sorting work so that all of the threads in a thread block do the same thing. This latter idea will come up repeatedly in @gpu-path-tracer-implementation when we discuss the set of kernels that the #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`] executes.
][
  我们将说，当线程组中的所有线程遵循相同的程序控制流路径时，执行是#emph[收敛的];，而在程序执行的某些点，一些线程遵循一条路径而其他线程遵循另一条路径时，它已经变得#emph[发散];。 某些发散是不可避免的，但越少越好。可以通过编写单个代码块以最小化单独控制路径的数量以及对工作进行排序以便线程块中的所有线程执行相同的事情来改善收敛。 这后一种想法将@gpu-path-tracer-implementation 中反复出现，当我们讨论#link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];执行的一组内核时。
]

#parec[
  One implication of thread groups is that techniques like Russian roulette may have a different performance impact on a CPU than on a GPU. With `pbrt`'s CPU integrators, if a ray path is terminated with Russian roulette, the CPU thread can immediately go on to start work on a new path. Depending on how the rendering computation is mapped to threads on a GPU, terminating one ray path may not have the same benefit if it just leads to an idle thread being carried along with an otherwise still-active thread group.
][
  线程组的一个含义是，像俄罗斯轮盘这样的技术在CPU和GPU上的性能影响可能不同。对于`pbrt`的CPU积分器，如果一条光线路径被俄罗斯轮盘终止，CPU线程可以立即开始处理新路径。 根据渲染计算如何映射到GPU上的线程，终止一条光线路径可能没有相同的好处，如果它只是导致一个空闲线程被带到一个仍然活跃的线程组中。
]

==== Memory Hierarchy


#parec[
  Large differences in the memory system architectures of CPUs and GPUs further affect how a system should be structured to run efficiently on each type of processor. @tbl:cpu-gpu-specs-en summarizes some relevant quantities for a representative modern CPU and GPU that at the time of this writing have roughly the same cost.
][
  CPU 和 GPU 的内存系统架构存在很大差异，这进一步影响了系统在每种处理器上高效运行的结构。@tbl:cpu-gpu-specs-zh 总结了一些具有代表性的现代 CPU 和 GPU 的相关数量，这些 CPU 和 GPU 在撰写本文时的成本大致相同。
]


#parec[
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (40%, 30%, 30%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          table.header([], [AMD 3970x CPU], [NVIDIA 3090 RTX GPU]),
          table.hline(stroke: .5pt),
          [Processors], [32], [82],
          [Peak single-precision TFLOPS], [3.8], [36],
          [Peak memory bandwidth], [$ #sym.tilde.basic 100$ GiB/s], [936 GiB/s],
          table.hline(stroke: 0pt),
        )],
      caption: [
        Key Properties of a Representative Modern CPU and GPU. This CPU and GPU have approximately the same cost at time of writing but provide their computational capabilities using very different architectures. This table summarizes some of their most important characteristics.
      ],
      kind: table,
    )<cpu-gpu-specs-en>
  ]
][
  #block(
    inset: 8pt,
    radius: 4pt,
    stroke: .1pt,
  )[
    #figure(
      align(left)[#table(
          stroke: (x: none, y: .1pt),
          columns: (40%, 30%, 30%),
          align: (auto, auto, auto),
          fill: (_, y) => if y == 0 { gray.lighten(90%) } else { gray.lighten(95%) },
          table.hline(),
          table.header([], [AMD 3970x CPU], [NVIDIA 3090 RTX GPU]),
          table.hline(stroke: .5pt),
          [处理器], [32], [82],
          [峰值单精度 TFLOPS], [3.8], [36],
          [峰值内存带宽], [约 100 GiB/s], [936 GiB/s],
          table.hline(stroke: 0pt),
        )],
      caption: [
        具有代表性的现代 CPU 和 GPU 的关键特性。此 CPU 和 GPU 在撰写本文时的成本大致相同，但它们通过非常不同的架构提供计算能力。此表总结了它们的一些最重要特性。
      ],
      kind: table,
    )<cpu-gpu-specs-zh>
  ]
]

#parec[
  Two differences are immediately apparent: the peak memory bandwidth and number of TFLOPS (trillions of floating point operations per second) are both approximately ten times higher on the GPU. It is also clear that neither processor is able to reach its peak performance solely by operating on values stored in memory. For example, the 3.8 TFLOPS that the CPU is capable of would require 15.2 TB/s of memory bandwidth if each 4-byte floating-point value operated on was to be read from memory. Consequently, we can see that the performance of a computation such as iterating over a large array, reading each value, squaring it, and writing the result back to memory would not be limited by the processor's computational capabilities but would be limited by the memory bandwidth. We say that such computations are #emph[bandwidth limited];.
][
  两个差异显而易见：GPU 的峰值内存带宽和每秒万亿次浮点运算（TFLOPS）数量都大约高出十倍。显然，任何一种处理器都无法仅通过对存储在内存中的值进行操作来达到其峰值性能。 例如，CPU 能够实现的 3.8 TFLOPS 如果每个 4 字节的浮点值都要从内存中读取，则需要 15.2 TB/s 的内存带宽。因此，我们可以看到，诸如迭代一个大数组、读取每个值、将其平方并将结果写回内存的计算，其性能不会受到处理器计算能力的限制，而是会受到内存带宽的限制。我们称这样的计算为#emph[带宽受限];。
]

#parec[
  A useful measurement of a computation is its #emph[arithmetic
intensity];, which is usually measured as the number of floating-point operations performed per byte of memory accessed. Dividing peak TFLOPS by peak memory bandwidth gives a measurement of how much arithmetic intensity a processor requires to achieve its peak performance. For this CPU, we can see that it is roughly 38 floating-point operations (FLOPS) per byte, or 152 FLOPS for every 4-byte `float` read from memory. For the GPU, the values are 38.5 and 154, respectively—remarkably, almost exactly the same. Given such arithmetic intensity requirements, it is easy to become bandwidth limited.
][
  计算的一个有用度量是其#emph[算术强度];（即每字节内存访问执行的浮点运算次数），通常以每字节内存访问执行的浮点运算次数来衡量。将峰值 TFLOPS 除以峰值内存带宽可以衡量处理器达到其峰值性能所需的算术强度。 对于这个 CPU，我们可以看到大约是每字节 38 次浮点运算（FLOPS），或者每从内存中读取一个 4 字节的 `float` 执行 152 次 FLOPS。对于 GPU，这些值分别是 38.5 和 154——几乎完全相同。鉴于这样的算术强度要求，很容易受到带宽限制。
]

#parec[
  Therefore, there must be some combination of reuse of each value read from memory and reuse of intermediate computed values that are stored in on-chip memory in order to reach peak floating-point performance. Both the processors' register files and cache hierarchies are integral to keeping them working productively by making some values available from faster on-chip memory, though their effect is quite different on the two types of architecture. See @tbl:cpu-gpu-processor-specs-en, which presents additional quantities related to the individual processors on the example CPU and GPU.
][
  因此，必须有某种组合来重用从内存读取的每个值以及存储在片上内存中的中间计算值，以达到峰值浮点性能。 处理器的寄存器文件和缓存层次结构通过从更快的片上内存中提供一些值来保持其高效工作是至关重要的，尽管它们在两种架构上的影响截然不同。请参见@tbl:cpu-gpu-processor-specs-zh，其中列出了与示例 CPU 和 GPU 上的单个处理器相关的其他数量。
]


#parec[
  #figure(
    table(
      columns: 3,
      align: (auto, auto, auto),
      table.header([], [AMD 3970x CPU], [NVIDIA 3090 RTX GPU]),
      table.hline(),
      [Concurrently executing threads], [1], [32],
      [Maximum available threads], [2], [1,024],
      [thread], [32], [2],
      [`float` operations per cycle and thread], [32], [2],
      [Registers], [160 (`float`)], [65,536],
      [L1 cache], [32 KiB (data)], [128 KiB],
      [L2 cache], [512 KiB], [\$ ilde{75}\$ KiB],
      [L3 cache], [4 MiB], [none],
    ),
    caption: [

      Table 15.2: Key Properties of the Example CPU and GPU Processors. This
      table summarizes a few relevant per-processor quantities for the CPU and
      GPU in @tbl:cpu-gpu-specs-en.
      For the CPU, "maximum available threads" is the number that can be
      switched to without incurring the cost of an operating system thread
      switch. Furthermore, the number of CPU registers here is the total
      available for out-of-order execution, which is many more than are
      visible through the instruction set.
      The L2 cache on the GPU is shared across all processors and the L3 cache
      on the CPU is shared across four processors; here we report those cache
      sizes divided by the number of processors that share them.

    ],
    kind: table,
  )<cpu-gpu-processor-specs-en>
][
  #figure(
    table(
      columns: 3,
      align: (auto, auto, auto),
      table.header([], [AMD 3970x CPU], [NVIDIA 3090 RTX GPU]),
      table.hline(),
      [并发执行线程], [1], [32],
      [最大可用线程], [2], [1,024],
      [每周期每线程 `float` 操作], [32], [2],
      [寄存器], [160 (`float`)], [65,536],
      [L1 缓存], [32 KiB（数据）], [128 KiB],
      [L2 缓存], [512 KiB], [约 75 KiB],
      [L3 缓存], [4 MiB], [无],
    ),
    caption: [
      示例 CPU 和 GPU 处理器的关键特性。此表总结了@tbl:cpu-gpu-specs-zh 中 CPU 和
      GPU 的每个处理器的一些相关数量。 对于
      CPU，"最大可用线程"是可以切换到而不产生操作系统线程切换成本的数量。此外，这里的
      CPU 寄存器数量是可用于乱序执行的总数，远多于通过指令集可见的数量。 GPU 上的 L2 缓存在所有处理器之间共享，CPU 上的 L3
      缓存在四个处理器之间共享；这里我们报告这些缓存大小除以共享它们的处理器数量。
    ],
    kind: table,
  )<cpu-gpu-processor-specs-zh>
]

#parec[
  To understand the differences, it is illuminating to compare the two in terms of their cache size with respect to the number of threads that they are running. (Space in the caches is not explicitly allocated to threads, though this is still a useful thought exercise.) This CPU runs one thread at a time on each core, with a second ready for hyperthreading, giving 16 KiB of L1 cache, 256 KiB of L2, and 2 MiB of L3 cache for each of the two threads. This is enough memory to give a fairly wide window for the reuse of previous values and is enough that, for example, we do not need to worry about how big the `SurfaceInteraction` structure is (it is just under 256 bytes); it fits comfortably in the caches close to the processor. These generous cache hierarchies can be a great help to programmers, leaving them with the task of making sure their programs have some locality in their memory accesses but often allowing them not to worry over it too much further.
][
  为了理解差异，比较两者在运行线程数量方面的缓存大小是很有启发性的。 （缓存中的空间并未明确分配给线程，尽管这仍然是一个有用的思考练习。）此 CPU 在每个核心上一次运行一个线程，准备好进行超线程，给每个线程 16 KiB 的 L1 缓存、256 KiB 的 L2 缓存和 2 MiB 的 L3 缓存。 这足够的内存为重用先前的值提供了一个相当宽的窗口，并且足够，例如，我们不需要担心 `SurfaceInteraction` 结构有多大（它略低于 256 字节）；它可以舒适地放入靠近处理器的缓存中。 这些慷慨的缓存层次结构对程序员来说是一个很大的帮助，使他们的任务是确保程序在内存访问中具有一定的局部性，但通常允许他们不必过多担心。
]

#parec[
  The GPU runs thread groups of 32 threads, with as many as 31 additional thread groups ready to switch to, for a total of 1,024 threads afoot. We are left with 128 bytes of L1 cache and 75 bytes of L2 per thread, meaning factors of $128 upright(" times")$ and $3500 upright(" times")$ less than the CPU, respectively. If the GPU threads are accessing independent memory locations, we are left with a very small window of potential data reuse that can be served by the caches. Thus, structuring GPU computation so that threads access the same locations in memory as much as possible can significantly improve performance by making the caches more effective.
][
  GPU 以 32 个线程为一组运行线程组，最多有 31 个额外的线程组准备切换，总共 1,024 个线程在运行。 我们剩下每线程 128 字节的 L1 缓存和 75 字节的 L2 缓存，分别比 CPU 少了 128 倍和 3500 倍。 如果 GPU 线程正在访问独立的内存位置，我们剩下的就是一个可以由缓存提供服务的非常小的数据重用窗口。 因此，结构化 GPU 计算以便线程尽可能多地访问内存中的相同位置可以通过提高缓存的有效性显著提高性能。
]

#parec[
  GPUs partially make up for their small caches with large register files; for the one in this comparison there are 65,536 32-bit registers for each GPU processor, giving 64 or more for each thread. (Note that this register file actually has twice as much total storage as the processor's L1 cache.) If a computation can be structured such that it fits into its allocation of registers and has limited memory traffic (especially reads that are different than other threads'), then its computation can achieve high performance on the GPU.
][
  GPU 部分通过大寄存器文件弥补了其小缓存；在这个比较中，每个 GPU 处理器有 65,536 个 32 位寄存器，每个线程有 64 个或更多。 （请注意，这个寄存器文件的总存储量实际上是处理器 L1 缓存的两倍。）如果计算可以结构化以适应其分配的寄存器并且具有有限的内存流量（尤其是与其他线程不同的读取），则其计算可以在 GPU 上实现高性能。
]

#parec[
  The allocation of registers to a kernel must be determined at compile time; this presents a balance for the compiler to strike. On one hand, allocating more registers to a kernel gives it more on-chip storage and, in turn, generally reduces the amount of memory bandwidth that it requires. However, the more registers that are allocated to a kernel, the fewer threads can be scheduled on a processor. For the example GPU, allocating 64 registers for each thread of a kernel means that 1,024 threads can run on a processor at once. 128 registers per thread means just 512 threads, and so forth. The fewer threads that are running, the more difficult it is to hide memory latency via thread switching, and performance may suffer when all threads are stalled waiting for memory reads.
][
  寄存器到内核的分配必须在编译时确定；这为编译器提供了一个平衡。 一方面，分配更多寄存器给内核为其提供了更多的片上存储，从而通常减少了所需的内存带宽。 然而，分配给内核的寄存器越多，可以在处理器上调度的线程就越少。 对于示例 GPU，为内核的每个线程分配 64 个寄存器意味着可以在处理器上同时运行 1,024 个线程。每线程 128 个寄存器意味着只有 512 个线程，依此类推。 运行的线程越少，通过线程切换隐藏内存延迟就越困难，当所有线程都在等待内存读取时，性能可能会受到影响。
]

#parec[
  The effect of these constraints is that reducing the size of objects can significantly improve performance on the GPU: doing so reduces the amount of bandwidth consumed when reading them from memory (and so may improve performance if a computation is bandwidth limited) and can reduce the number of registers consumed to store them after they have been loaded, potentially allowing more threads and thus more effective latency hiding. This theme will come up repeatedly later in the chapter.
][
  这些限制的影响是减少对象的大小可以显著提高 GPU 的性能：这样做减少了从内存中读取它们时消耗的带宽（因此如果计算是带宽受限的可能会提高性能），并且可以减少加载后存储它们所消耗的寄存器数量，潜在地允许更多线程，从而更有效地隐藏延迟。 这一主题将在本章后面多次出现。
]

#parec[
  The coherence of the memory locations accessed by the threads in a thread group affects performance as well. A reasonable model for thinking about this is in terms of the processor's cache lines. A common GPU cache line size is 128 bytes. The cost of a memory access by the threads in a thread group is related to the total number of cache lines that the threads access. The best case is that they all access the same cache line, for a location that is already in the cache. (Thus with a 128-byte cache line size, 32 threads accessing successive cache line–aligned 4-byte values such as `float`s access a single cache line.) Performance remains reasonable if the locations accessed correspond to a small number of cache lines that are already in the cache.
][
  线程组中线程访问的内存位置的一致性也会影响性能。 一个合理的思考模型是以处理器的缓存行为单位。常见的 GPU 缓存行大小为 128 字节。 线程组中线程的内存访问成本与线程访问的缓存行总数有关。 最好的情况是它们都访问同一个缓存行，访问已经在缓存中的位置。 （因此，具有 128 字节的缓存行大小，32 个线程访问连续缓存行对齐的 4 字节值，如 `float`，访问单个缓存行。） 如果访问的位置对应于已经在缓存中的少量缓存行，性能仍然合理。
]

#parec[
  An entire cache line must be read for a cache miss. Here as well, the coherence of the locations accessed by the threads has a big impact on performance: if all locations are in a single cache line, then a single memory read can be performed. If all 32 threads access locations that lie in different cache lines, then 32 independent memory reads are required; not only is there a significant bandwidth cost to reading so much data, but there is much more memory latency—likely more than can be effectively hidden. Thus, another important theme in the following implementation will be organizing data structures and computation in order to improve the coherence of memory locations accessed by the threads in a thread group.
][
  对于缓存未命中，必须读取整个缓存行。在这里，线程访问的位置的一致性对性能有很大影响：如果所有位置都在单个缓存行中，则可以执行单次内存读取。 如果所有 32 个线程访问的位置位于不同的缓存行中，则需要 32 次独立的内存读取；不仅读取如此多数据的带宽成本显著，而且内存延迟也大得多——可能超过可以有效隐藏的程度。 因此，以下实现中的另一个重要主题是组织数据结构和计算，以改善线程组中线程访问的内存位置的一致性。
]

#parec[
  A final issue related to memory performance arises due to the various different types of memory that can be referenced by a computation. The GPU has its own #emph[device memory];, distinct from the #emph[host
memory] used by the CPU. Each GPU processor offers a small high-performance #emph[shared memory] that can be used by the threads running on it. It is best interpreted as a manually managed cache. Shared memory and L1 and L2 caches provide much higher bandwidth and lower latency than device memory, while host memory is the most expensive for the GPU to access: any read or write must be encapsulated into a transaction that is sent over the comparably slow PCI Express bus connecting the CPU and GPU. Optimally placing and, if necessary, moving data in memory during multiple phases of a computation requires expertise and extra engineering effort.
][
  与内存性能相关的最后一个问题是由于计算可以引用的各种不同类型的内存而产生的。 GPU 有自己的#emph[设备内存];，与 CPU 使用的#emph[主机内存];不同。每个 GPU 处理器提供一个小型高性能#emph[共享内存];，可供在其上运行的线程使用。 它最好被解释为手动管理的缓存。共享内存和 L1 和 L2 缓存提供比设备内存更高的带宽和更低的延迟，而主机内存是 GPU 访问最昂贵的：任何读取或写入都必须封装成一个事务，通过相对较慢的 PCI Express 总线连接 CPU 和 GPU。 优化地放置数据，并在计算的多个阶段中在内存中移动数据（如果必要）需要专业知识和额外的工程努力。
]

#parec[
  `pbrt` sidesteps this issue using #emph[managed memory];, which exists in a unified address space that can be accessed from both CPU and GPU. Its physical location is undecided and can migrate on demand to improve performance. This automatic migration comes at a small additional performance cost, but this is well worth the convenience of not having to micromanage memory allocations. In `pbrt`, the CPU initializes the scene in managed memory, and this migration cost is paid once when rendering on the GPU begins. There is then a small cost to read back the final image from the `Film` at the end. In the following implementation, as CPU code is launching kernels on the GPU, it is important that it does not inadvertently access GPU memory, which would harm performance.
][
  `pbrt` 使用#emph[托管内存];（即由系统自动管理的内存）来规避这个问题，托管内存存在于一个统一的地址空间中，CPU 和 GPU 都可以访问。 其物理位置未定，并且可以按需迁移以提高性能。这种自动迁移带来了一些额外的性能开销，但这非常值得，因为不必微观管理内存分配。 在 `pbrt` 中，CPU 在托管内存中初始化场景，并在 GPU 开始渲染时支付一次迁移成本。然后在最后从 `Film` 读取最终图像时有一个小成本。 在以下实现中，由于 CPU 代码正在 GPU 上启动内核，因此重要的是不要无意中访问 GPU 内存，这会损害性能。
]

=== Structuring Rendering Computation
<structuring-rendering-computation>

#parec[
  With these factors that affect GPU performance in mind, we can consider various ways of structuring `pbrt`'s rendering computation so that it is suitable for the GPU. First, consider applying the same parallelism decomposition that is used in the #link("../Introduction/pbrt_System_Overview.html#ImageTileIntegrator")[`ImageTileIntegrator`];: assigning each tile of the image to a thread that is then responsible for evaluating its pixel samples. Such an approach is hopeless from the start. Not only is it unlikely to provide a sufficient number of threads to fill the GPU, but the effect of the load imbalance among tiles is exacerbated when the threads execute in groups. (Recall @fig:task-time-distribution, the histogram of time spent rendering image tiles in @fig:intro-raytracing-example.) Since a thread group continues executing until all of its threads have finished, performance is worse if the long-running threads are spread across many different thread groups versus all together in fewer.
][
  考虑到这些影响GPU性能的因素，我们可以考虑各种构建`pbrt`渲染计算的方法，以使其适合GPU。首先，考虑应用与#link("../Introduction/pbrt_System_Overview.html#ImageTileIntegrator")[`ImageTileIntegrator`];中使用的相同的并行分解：将图像的每个瓦片分配给一个线程，该线程负责评估其像素样本。这样的做法从一开始就是无望的。不仅不太可能提供足够数量的线程来填满GPU，而且当线程以组的形式执行时，瓦片之间负载不平衡的影响会加剧。（回想@fig:task-time-distribution，@fig:intro-raytracing-example 中渲染图像瓦片所花费时间的直方图。）由于线程组在所有线程完成之前会继续执行，因此如果长时间运行的线程分布在许多不同的线程组中而不是集中在较少的线程组中，性能会更差.
]

#parec[
  Another natural approach might be to assign each pixel sample to a thread, launching as many threads as there are pixel samples, and to have each thread execute the same code as runs on the CPU to evaluate a pixel sample. Each thread's task then would be to generate a camera ray, find the closest intersection, evaluate the material and textures at the intersection point, and so forth. This is known as the #emph[megakernel] approach, since a single large kernel is responsible for all rendering computation for a ray. This approach provides more than sufficient parallelism to the GPU, but suffers greatly from execution divergence. While the computation may remain converged until intersections are found, if different rays hit objects with different materials, or the same material but with different textures, their execution will diverge and performance will quickly deteriorate.
][
  另一种自然的方法可能是将每个像素样本分配给一个线程，启动与像素样本数量相同的线程，并让每个线程执行与在CPU上运行的代码相同的代码以评估像素样本。然后，每个线程的任务是生成一个相机光线，找到最近的交点，评估交点处的材质和纹理，等等。这被称为#emph[Megakernel];方法，因为一个大型内核负责处理光线的所有渲染计算。这种方法为GPU提供了足够的并行性，但在执行分岔方面遭受了很大的损失。虽然计算可能在找到交点之前保持收敛，但如果不同的光线击中具有不同材质的物体，或者相同材质但具有不同纹理的物体，它们的执行将会分岔，性能将迅速恶化.
]

#parec[
  Even if the camera rays all hit objects with the same material, coherence will generally be lost with tracing the first batch of indirect rays: some may find no intersection and leave the scene, others may hit objects with various materials, and yet others may end up scattering in participating media. Each different case leads to execution divergence. Even if all the threads end up sampling a light BVH, for instance, they may not do so at the same time and thus that code may be executed multiple times, just as was the case for the inferior approach of implementing the #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatMixTexture")[`FloatMixTexture`] `Evaluate()` method. We can expect that over time all of the threads will fully diverge, leading to processing that is less efficient than it could be by a factor of the number of threads in a thread group.
][
  即使相机光线都击中具有相同材质的物体，随着第一批间接光线的追踪，连贯性通常会丧失：有些可能找不到交点并离开场景，其他可能击中具有各种材质的物体，还有些可能最终在参与介质中散射。每种不同的情况都会导致执行分岔。即使所有线程最终都采样一个光BVH，例如，它们可能不会同时这样做，因此该代码可能会被多次执行，就像实现#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#FloatMixTexture")[`FloatMixTexture`] `Evaluate()`方法的劣质方法一样。我们可以预期，随着时间的推移，所有线程将完全分岔，导致处理效率低于线程组中线程数量的因素.
]

#parec[
  The performance of a megakernel ray tracer can be improved with the addition of work scheduling and reordering within the executing kernels. Such a megakernel ray tracer can be seen as what is effectively a thread group–wide state machine that successively chooses an operation to perform: "generate camera rays," "find closest intersections," "evaluate and sample diffuse BSDFs," "sample the light BVH," and so forth. It might choose among operations based on how many threads would like to perform the corresponding operation.
][
  通过在执行内核中添加工作调度和重新排序，可以提高Megakernel光线追踪器的性能。这样的Megakernel光线追踪器可以被视为一个有效的线程组范围的状态机，连续选择要执行的操作："生成相机光线"，"找到最近的交点"，"评估和采样漫反射BSDF"，"采样光BVH"等。它可能会根据有多少线程希望执行相应的操作来选择操作.
]

#parec[
  This approach can greatly improve execution convergence. For example, if only a single thread is waiting to evaluate and sample diffuse BSDFs, that work can be deferred while other threads trace rays and do other rendering work. Perhaps some of those rays will intersect diffuse surfaces, adding themselves to the tally of threads that need to do that operation. When that operation is eventually selected, it can be done for the benefit of more threads, redundant executions saved.
][
  这种方法可以大大提高执行收敛性。例如，如果只有一个线程在等待评估和采样漫反射BSDF，可以推迟该工作，而其他线程则追踪光线并进行其他渲染工作。也许其中一些光线会与漫反射表面相交，将自己添加到需要执行该操作的线程计数中。当最终选择该操作时，可以为更多线程的利益而执行，节省冗余执行.
]

#parec[
  Direct implementation of the megakernel approach does have disadvantages. The megakernels themselves may be comprised of a large amount of code (effectively, everything that the renderer needs to do), which can lead to long compilation times depending on the sophistication of the ray tracer. They are further limited to finding shared work among the threads in a thread group or, at most, the threads running on a single GPU processor. It therefore may not be possible to achieve an optimal degree of thread convergence. Nevertheless, the approach is a good one, and is the most common one for real-time ray tracers today.
][
  直接实现Megakernel方法确实有其缺点。Megakernel本身可能由大量代码组成（实际上是渲染器需要做的所有事情），这可能导致长时间的编译时间，具体取决于光线追踪器的复杂程度。它们进一步被限制在线程组内或最多在单个GPU处理器上运行的线程之间找到共享工作。因此，可能无法实现最佳的线程收敛度。尽管如此，这种方法是一个不错的方法，并且是当今实时光线追踪器中最常见的方法.
]

#parec[
  The other main GPU ray tracer architecture is termed #emph[wavefront];. A wavefront ray tracer separates the main operations into separate kernels, each one operating on many pixel samples in parallel: for example, there might be one kernel that generates camera rays, another that finds ray intersections, perhaps one to evaluate diffuse materials and another to evaluate dielectrics, and so forth. The kernels are organized in a dataflow architecture, where each one may enqueue additional work to be performed in one or more subsequent kernels.
][
  另一种主要的GPU光线追踪器架构被称为#emph[波前];。波前光线追踪器将主要操作分为独立的内核，每个内核并行处理许多像素样本：例如，可能有一个内核生成相机光线，另一个找到光线交点，可能有一个评估漫反射材质，另一个评估介电材质，等等。内核被组织在一个数据流架构中，其中每个内核可以在一个或多个后续内核中排队额外的工作.
]

#parec[
  A significant advantage of the wavefront approach is that execution in each kernel can start out fully converged: the diffuse-material kernel is invoked for only the intersection points with a diffuse material, and so forth. While the execution may diverge within the kernel, regularly starting out with converged execution can greatly aid performance, especially for systems with a wide variety of materials, BSDFs, lights, and so forth.
][
  波前方法的一个显著优势是每个内核的执行可以从完全收敛开始：漫反射材质内核仅为与漫反射材质的交点调用，等等。虽然执行可能在内核内分岔，但定期以收敛执行开始可以大大提高性能，特别是对于具有多种材质、BSDF、光源等的系统.
]

#parec[
  Another advantage of the wavefront approach is that different numbers of registers can be allocated to different kernels. Thus, simple kernels can use fewer registers and reap benefits in more effective latency hiding, and it is only the more complex kernels that incur the costs of that trade-off. In contrast, the register allocation for a megakernel must be made according to the worst case across the entire set of rendering computation.
][
  波前方法的另一个优势是可以为不同的内核分配不同数量的寄存器。因此，简单的内核可以使用更少的寄存器，并在更有效的延迟隐藏中获得好处，只有更复杂的内核才会承担这种权衡的成本。相比之下，Megakernel的寄存器分配必须根据整个渲染计算集的最坏情况进行.
]

#parec[
  However, wavefront ray tracers pay a cost in bandwidth. Because data does not persist on-chip between kernel launches, each kernel must read all of its inputs from memory and then write its results back to it. In contrast, megakernels can often keep intermediate information on-chip. The performance of a wavefront ray tracer is more likely than a megakernel to be limited by the amount of memory bandwidth and not the GPU's computational capabilities. This is an undesirable state of affairs since it is projected that bandwidth will continue to grow more slowly than computation in future processor architectures.
][
  然而，波前光线追踪器在带宽方面付出了代价。由于数据在内核启动之间无法在芯片上保留，每个内核必须从内存中读取其所有输入，然后将其结果写回内存。相比之下，Megakernel通常可以将中间信息保留在芯片上。波前光线追踪器的性能更有可能受到内存带宽的限制，而不是GPU的计算能力。这是一种不理想的状态，因为预计未来处理器架构中带宽的增长速度将继续慢于计算.
]

#parec[
  The recent addition of hardware ray-tracing capabilities to GPUs has led to the development of graphics programming interfaces that allow the user to specify which kernels to run at various stages of ray tracing. This gives an alternative to the megakernel and wavefront approaches that avoids many of their respective disadvantages. With these APIs, the user not only provides single kernels for operations like generating initial rays, but can also specify multiple kernels to run at ray intersection points—where the kernel that runs at a given point might be determined based on an object's material, for example. Scheduling computation and orchestrating the flow of data between stages is not the user's concern, and the GPU's hardware and software has the opportunity to schedule work in a way that is tuned to the hardware architecture. (The semantics of these APIs are discussed further in @intersection-testing.)
][
  最近，GPU硬件光线追踪功能的增加导致了图形编程接口的发展，允许用户指定在光线追踪的各个阶段运行哪些内核。这为Megakernel和波前方法提供了一种替代方案，避免了它们各自的许多缺点。使用这些API，用户不仅可以为生成初始光线等操作提供单个内核，还可以指定在光线交点处运行的多个内核——例如，运行的内核可以根据物体的材质来确定。计算调度和在阶段之间协调数据流不是用户的关注点，GPU的硬件和软件有机会以适合硬件架构的方式调度工作。（这些API的语义在@intersection-testing 中进一步讨论。）
]

=== System Overview
<system-overview>
#parec[
  This version of `pbrt` adopts the wavefront approach for its GPU rendering path, although some of its kernels fuse together multiple stages of the ray-tracing computation in order to reduce the amount of memory traffic that is used. We found this approach to be a good fit given the variety of materials, #link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`];s, and light sources that `pbrt` supports. Further, rendering features like volume scattering fit in nicely: we can skip the corresponding kernels entirely if the scene does not include those effects.
][
  这个版本的`pbrt`采用了波前方法用于其GPU渲染路径，尽管其一些内核融合了光线追踪计算的多个阶段，以减少使用的内存流量。我们发现这种方法非常适合`pbrt`支持的多种材质、#link("../Reflection_Models/BSDF_Representation.html#BxDF")[`BxDF`];和光源。此外，体积散射等渲染特性也很好地融入其中：如果场景不包括这些效果，我们可以完全跳过相应的内核.
]

#parec[
  As with the CPU-targeted `Integrator`s, a #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`] parses the scene description and stores various entities that represent scene components. When the wavefront integrator is being used, the parsed scene is then passed to the `RenderWavefront()` function, which is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/wavefront/wavefront.cpp")[`wavefront/wavefront.cpp`];. Beyond some housekeeping, its main task is to allocate an instance of the #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`] class and to call its `Render()` method. Since the housekeeping is not very interesting, we will not include its implementation here.
][
  与针对CPU的`Integrator`一样，#link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[`BasicScene`];解析场景描述并存储表示场景组件的各种实体。当使用波前积分器时，解析后的场景会传递给`RenderWavefront()`函数，该函数定义在文件#link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/wavefront/wavefront.cpp")[`wavefront/wavefront.cpp`];中。除了进行一些日常事务外，其主要任务是分配#link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator")[`WavefrontPathIntegrator`];类的一个实例并调用其`Render()`方法。由于日常事务较为琐碎，我们在此不予赘述其实现.
]

#parec[
  The `WavefrontPathIntegrator` constructor converts many of the entities in the #link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene] to `pbrt` objects in the same way as is done for the CPU renderer: all the lights are converted to corresponding instances of the `Light` classes, and similarly for the camera, film, sampler, light sampler, media, materials, and textures. One important difference, however, is that the #link("../Introduction/Using_and_Understanding_the_Code.html#Allocator")[`Allocator`] that is provided for them allocates managed memory so that it can be initialized on the CPU and accessed by the GPU. Another difference is that only some shapes are handled with `pbrt`'s #link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`] implementations. Shapes like triangles that have native support from the GPU's ray intersection hardware are instead handled using that hardware. Finally, image map textures use a specialized implementation that uses the GPU's texturing hardware for texture lookups.
][
  `WavefrontPathIntegrator`构造函数将#link("../Processing_the_Scene_Description/BasicScene_and_Final_Object_Creation.html#BasicScene")[BasicScene];中的许多实体转换为`pbrt`对象，与CPU渲染器的做法相同：所有光源都转换为`Light`类的相应实例，相机、胶片、采样器、光采样器、介质、材质和纹理也类似。一个重要的区别是，为它们提供的#link("../Introduction/Using_and_Understanding_the_Code.html#Allocator")[`Allocator`];分配了托管内存，以便可以在CPU上初始化并由GPU访问。另一个区别是，只有一些形状由`pbrt`的#link("../Shapes/Basic_Shape_Interface.html#Shape")[`Shape`];实现处理。像三角形这样的形状，由于GPU的光线交点硬件的本机支持，而由该硬件处理。最后，图像贴图纹理使用了一种专门的实现，利用了GPU的纹理硬件进行纹理查找.
]

#figure(
  image("../pbr-book-website/4ed/Wavefront_Rendering_on_GPUs/pha15f02.svg"),
  caption: [#ez_caption[
      Overview of Kernels Used in the Wavefront Integrator.
      Arrows correspond to queues on which kernels may enqueue work for
      subsequent kernels. After camera rays have been generated, the
      subsequent kernels execute one time for each ray depth up to the maximum
      depth. For simplicity, the kernels that handle subsurface scattering are
      not included here.
    ][
      波前积分器中使用的内核概述。箭头对应于内核可能为后续内核排队工作的队列。在生成相机光线之后，后续内核为每个光线深度最多执行一次。为简单起见，这里不包括处理次表面散射的内核。
    ]
  ],
)<gpu-kernels-overview>

#parec[
  Once the scene representation is ready, a call to #link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator::Render")[`WavefrontPathIntegrator::Render()`] starts the rendering process. The details of the implementation of that method will be the subject of the following sections of this chapter, but @fig:gpu-kernels-overview gives an overview of the kernels that it launches.#footnote[
    In describing the `WavefrontPathIntegrator` in the remainder of this chapter, we will frequently use the terminology of “launching kernels” to describe its
operation, even though when it is running on the CPU, “launch” is just a
function call, and a kernel is a regular class method.
  ] The sequence of computations is similar to that of the #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator::Li")[`VolPathIntegrator::Li()`] method, though decomposed into kernels. Queues are used to buffer work between kernels: each kernel can push work onto one or more queues to be processed in subsequent kernels.
][
  一旦场景表示准备就绪，调用#link("../Wavefront_Rendering_on_GPUs/Path_Tracer_Implementation.html#WavefrontPathIntegrator::Render")[`WavefrontPathIntegrator::Render()`];开始渲染过程。该方法实现的细节将在本章的后续部分中讨论，但@fig:gpu-kernels-overview 概述了它启动的内核。#footnote[在本章余下的内容中描述 `WavefrontPathIntegrator` 时，我们将频繁使用“启动内核（launching kernels）”这一术语来描述其运行方式，尽管当它在 CPU 上运行时，“启动”实际上只是一个函数调用，而“内核”则是一个普通的类方法。] #link("../Light_Transport_II_Volume_Rendering/Volume_Scattering_Integrators.html#VolPathIntegrator::Li")[`VolPathIntegrator::Li()`];方法类似，尽管分解为内核。队列用于在内核之间缓冲工作：每个内核可以将工作推送到一个或多个队列中，以便在后续内核中处理.
]

#parec[
  Rendering starts with a kernel that generates camera rays for a number of pixel samples (typically, a million or so). Given camera rays, the loop up to the maximum ray depth can begin. Each time through the loop, the following kernels are executed:
][
  渲染从一个为若干像素样本（通常约一百万个）生成相机光线的内核开始。给定相机光线，最大光线深度的循环可以开始。每次循环执行以下内核：
]

#parec[
  - First, samples for use with the ray are generated using the
    #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`]
    and stored in memory for use in later kernels.
][
  - 首先，使用#link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`];生成光线使用的样本，并存储在内存中以供后续内核使用。
]

#parec[
  - The closest intersection of each ray is found with the scene geometry.
    The kernel that finds these intersections pushes work onto a variety
    of queues to be processed by other kernels, including a queue for rays
    that escape the scene, one for rays that hit emissive geometry, and
    another for rays that pass through participating media. Rays that
    intersect surfaces are pushed onto queues that partition work based on
    material types.
][
  - 找到每条光线与场景几何体的最近交点。找到这些交点的内核将工作推送到由其他内核处理的各种队列中，包括一个用于逃离场景的光线的队列，一个用于击中发光几何体的光线的队列，以及另一个用于通过参与介质的光线的队列。与表面相交的光线被推送到基于材质类型划分工作的队列中.
]

#parec[
  - Rays passing through participating media are then processed, possibly
    leading to a shadow ray and an indirect ray being enqueued if the ray
    scatters. Unscattered rays that were earlier found to have intersected
    a surface are pushed on to the same variety of queues as are used in
    the intersection kernel for rays not passing through media.
][
  - 然后处理通过参与介质的光线，可能导致阴影光线和间接光线被排队，如果光线散射。先前发现与表面相交的未散射光线被推送到与未通过介质的光线在交点内核中使用的相同种类的队列中。
]

#parec[
  - Rays that have intersected emissive geometry and rays that have left
    the scene are handled by two kernels that both update rays' radiance
    estimates to incorporate the effect of emission found by such rays.
][
  - 与发光几何体相交的光线和离开场景的光线由两个内核处理，这两个内核都更新光线的辐射估计，以结合这些光线发现的发射效果.
]

#parec[
  - Each material is then handled individually, with separate kernels
    specialized based on the material type. Textures are evaluated to
    initialize a
    #link("../Reflection_Models/BSDF_Representation.html#BSDF")[BSDF] and
    a light is sampled. This, too, leads to indirect and shadow rays being
    enqueued.
][
  - 然后单独处理每种材质，使用基于材质类型的专门内核。评估纹理以初始化#link("../Reflection_Models/BSDF_Representation.html#BSDF")[BSDF];并采样光源。这也导致间接光线和阴影光线被排队.
]

#parec[
  - A final kernel traces shadow rays and incorporates their contributions
    into the rays' radiance estimates, including accounting for absorption
    along rays in participating media.
][
  - 最后一个内核追踪阴影光线并将其贡献纳入光线的辐射估计中，包括考虑参与介质中光线的吸收。
]

#parec[
  Until the maximum ray depth, the loop then starts again with the queued indirect rays replacing the camera rays as the rays to trace next.
][
  直到最大光线深度，循环然后再次开始，排队的间接光线替换相机光线作为下次追踪的光线.
]


