#import "../template.typ": parec



== B.7 Statistics
<b.7-statistics>

#parec[
  Collecting data about the runtime behavior of the system can provide a
  substantial amount of insight into its behavior and opportunities for
  improving its performance. For example, we might want to track the
  average number of primitive intersection tests performed for all the
  rays; if this number is surprisingly high, then there may be a latent
  bug somewhere in the system. pbrt’s statistics system makes it possible
  to measure and aggregate this sort of data in a variety of ways. The
  statistics system is only available with the CPU renderer; an exercise
  at the end of this appendix discusses how it might be brought to the
  GPU.
][
  收集关于系统运行时行为的数据可以为其行为以及改进其性能的机会提供大量洞见。例如，我们可能希望跟踪对所有射线进行的图元相交测试的平均次数；如果这个数字出人意料地高，那么系统某处可能存在潜在的错误。pbrt
  的统计系统使其能够以多种方式测量和聚合这类数据。统计系统仅在 CPU
  渲染器中可用；本附录末尾的练习讨论了如何将统计系统移植到 GPU。


]

#parec[
  It is important to make it as easy as possible to add new measurements
  to track the system’s runtime behavior; the easier it is to do this, the
  more measurements end up being added to the system, and the more likely
  that "interesting" data will be discovered, leading to new insights and
  improvements. Therefore, it is fairly easy to add new measurements to
  pbrt. For example, the following lines declare two counters that can be
  used to record how many times the corresponding events happen.
][
  尽量简化添加新的测量以跟踪系统的运行时行为是很重要的；越容易做到这一点，最终添加到系统中的测量就越多，越有可能发现“有趣”的数据，从而带来新的洞见和改进。因此，向
  pbrt
  添加新的测量相当容易。例如，以下行声明了两个计数器，可以用来记录相应事件发生的次数。
]

```
STAT_COUNTER("Integrator/Regular ray intersection tests", nIsectTests);
STAT_COUNTER("Integrator/Shadow ray intersection tests", nShadowTests);
```

#parec[
  As appropriate, counters can be incremented with simple statements like
][
  在适当的情况下，计数器可以用简单的语句自增，例如
]
```
  ++nIsectTests;
```
#parec[
  With no further intervention from the developer, the preceding is enough
  for the statistics system to be able to automatically print out nicely
  formatted results like the following when rendering completes:
][
  开发者无需进一步干预，上述设置即可在渲染完成时输出整齐、易读的统计结果，如下所示：
]
```
  Integrator
    Regular ray intersection tests                752982
    Shadow ray intersection tests                4237165
```

#parec[
  The statistics system supports the following aggregate measurements:
][
  统计系统支持以下聚合测量：
]

#parec[
  - `STAT_COUNTER("name", var)`: A count of the number of instances of an
    event. The counter variable `var` can be updated as if it was a
    regular integer variable; for example, `++var` and `var += 10` are
    both valid.
][
  - `STAT_COUNTER("name", var)`： 一个事件发生的计数。计数变量 `var`
    可以像普通整型变量一样更新；例如，`++var` 和 `var += 10` 都是有效的。
]

#parec[
  - `STAT_MEMORY_COUNTER("name", var)`: A specialized counter for
    recording memory usage. In particular, the values reported at the end
    of rendering are in terms of kilobytes, megabytes, or gigabytes, as
    appropriate. The counter is updated the same way as a regular counter:
    `var += count * sizeof(MyStruct)` and so forth.
][
  - `STAT_MEMORY_COUNTER("name", var)`：
    用于记录内存使用的专用计数器。具体来说，渲染结束时报告的数值按
    KB、MB、GB（千字节、兆字节、千兆字节）来表示，视情况而定。计数器的更新方式与普通计数器相同：`var += count * sizeof(MyStruct)`
    等等。
]

#parec[
  - `STAT_INT_DISTRIBUTION("name", dist)`: Tracks the distribution of some
    value; at the end of rendering, the minimum, maximum, and average of
    the supplied values are reported. Call `dist << value` to include
    `value` in the distribution.
][
  - `STAT_INT_DISTRIBUTION("name", dist)`：
    跟踪某一值的分布；在渲染结束时，所提供值的最小值、最大值和平均值将被报告。调用
    `dist << value` 将 value 放入分布中。
]

#parec[
  - `STAT_PERCENT("name", num, denom)`: Tracks how often a given event
    happens; the aggregate value is reported as the percentage `num/denom`
    when statistics are printed. Both `num` and `denom` can be incremented
    as if they were integers—for example, one might write
    `if (event) ++num;` or `++denom`.
][
  - `STAT_PERCENT("name", num, denom)`：
    跟踪事件发生的次数相对于总次数的比例；当统计信息被输出时，聚合值以百分比
    `num/denom` 的形式报告。`num` 和 `denom`
    都可以像整数一样自增——例如可以写 `if (event) ++num;` 或 `++denom`。
]

#parec[
  - `STAT_RATIO("name", num, denom)`: This tracks how often an event
    happens but reports the result as a ratio `num/denom` rather than a
    percentage. This is often a more useful presentation if `num` is often
    greater than `denom`. (For example, we might record the percentage of
    ray–triangle intersection tests that resulted in an intersection but
    the ratio of triangle intersection tests to the total number of rays
    traced.)
][

  - `STAT_RATIO("name", num, denom)`： 这跟踪事件发生的次数但以比率
    `num/denom` 而不是百分比来报告结果。如果 `num` 经常大于
    `denom`，这种表示往往更有用。（例如，我们可能记录射线–三角形相交测试结果的百分比，但记录三角形相交测试数量与被追踪的射线总数之比。）


]

#parec[
  #block[
    #block[
      #block[

      ]
      Figure B.8: Visualization of Average Path Length at Each Pixel. Each
      pixel’s value is based on the number of rays traced to compute the
      pixel’s shaded value. Not only is it evident that longer paths are
      traced at pixels with specular surfaces like the glasses on the tables,
      but it is also possible to see the effect of Russian roulette
      terminating paths more quickly at darker surfaces. This image was
      generated using STAT\_PIXEL\_COUNTER and only required adding two lines
      of code to an integrator. (Scene courtesy of Guillermo M. Leal Llaguno.)
    ]
  ]
][
  #block[
    #block[
      #block[

      ]
      图 B.8：每个像素的平均路径长度可视化。
      每个像素的值基于用于计算像素着色值的光线数量。不仅可以看出在具有镜面表面的像素（例如桌子上的玻璃）处，路径长度更长；同时也能观察到在较暗表面上，俄罗斯轮盘终止路径更快的效果。此图像是使用
      STAT\_PIXEL\_COUNTER 生成的，只需要向积分器添加两行代码即可。（场景由
      Guillermo M. Leal Llaguno 提供。）
    ]
  ]
]

#parec[
  In addition to statistics that are aggregated over the entire rendering,
  pbrt can also measure statistics at each pixel and generate images with
  their values. Two variants are supported: `STAT_PIXEL_COUNTER` and
  `STAT_PIXEL_RATIO`, which are used in the same way as the corresponding
  aggregate statistics. Per-pixel statistics are only measured if the
  `--pixelstats` command line option is provided to pbrt. Figure B.8 shows
  an image generated using `STAT_PIXEL_COUNTER`.
][

  除了对整个渲染过程聚合的统计信息外，pbrt
  还可以在每个像素处测量统计信息并生成带有其数值的图像。支持两种变体：`STAT_PIXEL_COUNTER`
  和 `STAT_PIXEL_RATIO`，它们的用法与相应的聚合统计相同。仅当为 pbrt 提供
  `--pixelstats` 命令行选项时，才对每个像素进行统计测量。图 B.8 显示了使用
  `STAT_PIXEL_COUNTER` 生成的图像。

]

#parec[
  All the macros to define statistics trackers can only be used at file
  scope and should only be used in #emph[.cpp] files (for reasons that
  will become apparent as we dig into their implementations). They
  specifically should not be used in header files or function or class
  definitions.
][

  所有用于定义统计追踪器的宏只能在文件作用域（即只在 .cpp
  文件中）使用，且不应在头文件、以及函数或类的定义中都不应使用。

]

#parec[
  Note also that the string names provided for each measurement should be
  of the form "category/statistic." When values are reported, everything
  under the same category is reported together (as in the preceding
  example).
][
  另外，为每个测量提供的字符串名称应采用“类别/统计项”的形式。当报告值时，同一类别下的所有项将一起报告（如前面的示例所示）。
]


```
#define STAT_COUNTER(title, var)                                       \
    static thread_local int64_t var;                                   \
    static StatRegisterer STATS_REG##var([](StatsAccumulator & accum) { \
        accum.ReportCounter(title, var);                               \
        var = 0;                                                       \
    });
```

#parec[
  First, and most obviously, the macro defines a 64-bit integer variable
  named `var`, the second argument passed to the macro. The variable
  definition has the `thread_local` qualifier, which indicates that there
  should be a separate copy of the variable for each executing thread.
  This variable can then be incremented directly as appropriate to report
  results. However, given these per-thread instances, we need to be able
  to sum together the per-thread values and to aggregate all the
  individual counters into the final program output.
][
  首先，显然，该宏定义了一个名为 `var` 的 64
  位整型变量，即传递给宏的第二个参数。该变量定义带有 `thread_local`
  限定符，表示每个执行线程应有该变量的一个独立副本。随后可以按需直接对该变量进行自增以报告结果。然而，考虑到这些按线程的实例，我们需要能够将各线程的值相加并将所有单独的计数器聚合到最终的程序输出中。
]

#parec[
  To this end, the macro next defines a static variable of type
  `StatRegisterer`, giving it a (we hope!) unique name derived from `var`.
  A lambda function is passed to the `StatRegisterer` constructor, which
  stores a copy of it. When called, the lambda passes the current thread’s
  counter value to a `ReportCounter()` method and then resets the counter.
  Evidently, all that is required is for this lambda to be called by each
  thread and for `ReportCounter()` to sum up the values provided and then
  report them. (We will gloss over the implementation of the
  `StatsAccumulator` class and methods like `ReportCounter()`, as there is
  nothing very interesting about them.)
][
  为此，宏接着定义了一个静态变量，类型为
  `StatRegisterer`，给它一个（我们希望是）从 `var` 派生出的唯一名称。一个
  lambda 函数被传递给 `StatRegisterer` 的构造函数，它会存储该 lambda
  的一个副本。当被调用时，该 lambda 将当前线程的计数器值传递给
  `ReportCounter()` 方法，然后重置计数器。显然，所需要做的只是让这条
  lambda 能被每个线程调用，随后让 `ReportCounter()`
  汇总所提供的值并进行报告。（关于 `StatsAccumulator` 类以及诸如
  `ReportCounter()`
  之类方法的实现，我们在此不做赘述，因为它们并不特别有趣。）

]


#parec[
  Recall that in C++, constructors of global static objects run when
  program execution starts; thus, each static instance of the
  `StatRegisterer` class runs its constructor before `main()` starts
  running. This constructor, which is not included here, adds the lambda
  passed to it to a std::vector that holds all such lambdas for all the
  statistics.
][

  回想在 C++
  中，全局静态对象的构造函数在程序执行开始时运行；因此，`StatRegisterer`
  类的每个静态实例在 `main()`
  开始运行之前就会执行其构造函数。这个构造函数（此处未包含）将传递给它的
  lambda 添加到一个保存所有统计信息的 lambda 的 std::vector 中。


]


#parec[
  At the end of rendering, the ForEachThread() function is used to cause
  each thread to loop over the registered lambdas and call each of them.
  In turn, the `StatsAccumulator` will have all the aggregate values when
  they are done. The `PrintStats()` function can then be called to print
  all the statistics that have been accumulated in `StatsAccumulator`.
][
  在渲染结束时，ForEachThread() 函数用于使每个线程遍历已注册的 lambda
  并调用它们中的每一个。依次地，`StatsAccumulator`
  将拥有所有聚合值。然后可以调用 `PrintStats()` 打印出 `StatsAccumulator`
  中累计的所有统计信息。
]

=== Implementation
<implementation>

#parec[
  There are a number of challenges in making the statistics system both
  efficient and easy to use. The efficiency challenges stem from pbrt
  being multi-threaded: if there was not any parallelism, we could
  associate regular integer or floating-point variables with each
  measurement and just update them like regular variables. In the presence
  of multiple concurrent threads of execution, however, we need to ensure
  that two threads do not try to modify these variables at the same time
  (recall the discussion of mutual exclusion in Section B.6.1).
][
  在使统计系统既高效又易于使用方面存在若干挑战。效率方面的挑战源自 pbrt
  的多线程特性：如果不存在并行性，我们可以把普通整数或浮点变量与每个测量相关联，并像更新普通变量一样更新它们。然而，在存在多个并发执行的线程时，我们需要确保两条线程不会同时尝试修改这些变量（回忆
  Section B.6.1 中的互斥锁讨论）。

]

#parec[

  While atomic operations like those described in Section B.6.1 could be
  used to safely increment counters without using a mutex, there would
  still be a performance impact from multiple threads modifying the same
  location in memory. Recall from Section B.6.3 that the cache coherence
  protocols can introduce substantial overhead in this case. Because the
  statistics measurements are updated so frequently during the course of
  rendering, we found that an atomics-based implementation caused the
  renderer to be 10–15% slower than the following implementation, which
  avoids the overhead of multiple threads frequently modifying the same
  memory location.
][
  尽管像 Section B.6.1
  中所述的原子操作可以在不使用互斥锁的情况下安全地增加计数器，但从内存中的同一位置被多个线程修改仍会带来性能影响。回顾
  Section
  B.6.3，缓存一致性协议在此情况下会引入大量开销。由于在渲染过程中统计测量更新的频率如此之高，我们发现基于原子操作的实现使渲染器比下面的实现慢
  10–15%，后者避免了多线程频繁修改同一内存位置的开销。

]

#parec[
  The implementation here is based on having separate counters for each
  running thread, allowing the counters to be updated without atomics and
  without cache coherence overhead (since each thread increments its own
  counters). This approach means that in order to report statistics, it is
  necessary to merge all of these per-thread counters into final aggregate
  values, which we will see is possible with a bit of trickiness.

][
  此处的实现基于为每个运行中的线程设置单独的计数器，允许在没有原子操作且没有缓存一致性开销的情况下更新计数器（因为每个线程对自己的计数器进行自增）。这种方法意味着为了报告统计信息，需要将所有按线程的计数器合并为最终的聚合值，我们将看到这是可以通过一些技巧实现的。

]

#parec[
  To see how this all works, we will dig into the implementation for
  regular counters; the other types of measurements are all along similar
  lines. First, here is the `STAT_COUNTER` macro, which packs three
  different things into its definition.

][
  要了解这一切如何工作，我们将深入研究常规计数器的实现；其他类型的测量也大致沿着相同的思路。首先，下面给出
  `STAT_COUNTER` 宏，它在定义中打包了三种不同的内容。

]

#parec[
  Recall that in C++, constructors of global static objects run when
  program execution starts; thus, each static instance of the
  `StatRegisterer` class runs its constructor before `main()` starts
  running. This constructor, which is not included here, adds the lambda
  passed to it to a std::vector that holds all such lambdas for all the
  statistics.

][
  回想在 C++
  中，全局静态对象的构造函数在程序执行开始时运行；因此，`StatRegisterer`
  类的每个静态实例在 `main()`
  开始运行之前就会执行其构造函数。这个构造函数（此处未包含）将传递给它的
  lambda 添加到一个保存所有统计信息的 lambda 的 std::vector 中。


]

#parec[
  At the end of rendering, the ForEachThread() function is used to cause
  each thread to loop over the registered lambdas and call each of them.
  In turn, the `StatsAccumulator` will have all the aggregate values when
  they are done. The `PrintStats()` function can then be called to print
  all the statistics that have been accumulated in `StatsAccumulator`.

][
  在渲染结束时，ForEachThread() 函数用于使每个线程遍历已注册的 lambda
  并调用它们中的每一个。依次地，`StatsAccumulator`
  将拥有所有聚合值。然后可以调用 `PrintStats()` 打印出 `StatsAccumulator`
  中累计的所有统计信息。
]
