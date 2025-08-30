#import "../template.typ": parec


== Parallelism
<b.6-parallelism>

#parec[
  As improvements in the performance of single processing cores have
  slowed over the past fifteen years, it has become increasingly important
  to write parallel programs in order to reach the full computational
  capabilities of a system. Fortunately, ray tracing offers abundant
  independent work, which makes it easier to distribute work across
  processing cores. This section discusses some important principles of
  parallelism, focusing on CPUs, and introduces assorted classes and
  functions that `pbrt` uses for parallelism. (See Section 15.1 for
  discussion of parallelism on GPUs and how `pbrt` is parallelized on
  those processors.)
][
  随着在过去十五年里单处理核性能的提升放缓，为了充分发挥系统的计算能力，编写并行程序变得越来越重要。幸运的是，光线追踪提供了大量独立的工作量，使得将工作分配给处理核更加容易。本节讨论并行性的若干重要原则，重点放在
  CPU 上，并介绍 `pbrt` 用于并行的一些类与函数。（关于在 GPU 上的并行性及
  `pbrt` 如何在这些处理器上实现并行，请参见第 15.1 节。）
]

#parec[
  One of the biggest challenges with parallel ray tracing is the impact of
  nonparallel phases of computation. For example, it is not as easy to
  effectively parallelize the construction of many types of acceleration
  structure while the scene is being constructed as it is to parallelize
  rendering. While this may seem like a minor issue, #emph[Amdahl’s law];,
  which describes the speedup of a workload that has both serial and
  parallel phases, points to the challenge. Given $n$ cores performing
  computation and a workload where the fraction $s$ of its overall
  computation is inherently serial, the maximum speedup then possible is
][
  并行光线追踪面临的最大挑战之一是非并行计算阶段的影响。例如，在场景构建时对多种加速结构进行并行化并不像渲染时那样容易实现。尽管这看起来像是一个微小的问题，但描述一个工作负载在既有串行阶段又有并行阶段时的加速比的
  #emph[阿姆达尔定律] 指出了这一挑战。设有 n
  个核心进行计算，且一个工作负载中总体计算中的串行部分所占的分数为
  s，则可能达到的最大加速比为


]
$ frac(1, thin s + frac(1 - s, n) thin) $

#parec[
  Thus, even with an infinite number of cores, the maximum speedup is
  $1 \/ s$. If, for example, a seemingly innocuous $5 %$ of the run time
  is spent in a serial phase of parsing the scene file and building
  acceleration structures, the maximum speedup possible is
  $1 \/ 0.05 = 20$ times, no matter how quickly the parallel phase
  executes.

][
  因此，即使核心数量达到无穷大，最大加速比也是
  $1 \/ s$。例如，如果在场景文件解析和构建加速结构的串行阶段花费的运行时间看似只有
  5%，则最大可能的加速比为 $1 \/ 0.05 = 20$
  倍，无论并行阶段的执行速度有多快。

]

#parec[
  We experienced the impact of Amdahl’s law as we brought `pbrt`’s GPU
  rendering path to life: it was often the case that it took longer to
  parse the scene description and to prepare the scene for rendering than
  it took to render the image, even at high sampling rates! This led to
  more attention to parallelizing parsing and creating the objects that
  represent the scene. (See Section C.3 for further discussion of this
  topic.)

][
  在我们将 `pbrt` 的 GPU
  渲染路径投入实现时，阿姆达尔定律的影响就已经显现：往往解析场景描述和为渲染准备场景比实际渲染图像花费的时间还长，即使在高采样率下也是如此！这促使我们更加关注并行化解析和创建表示场景的对象。（关于这一主题的进一步讨论，请参见附录
  C.3。）

]


=== Data Races and Coordination
<b.6.1-data-races-and-coordination>

#parec[
  When `pbrt` is running on the CPU, we assume that the computation is
  running on processors that provide coherent shared memory. The main idea
  of coherent shared memory is that all threads can read and write to a
  common set of memory locations and that changes to memory made by one
  thread will eventually be seen by other threads. These properties
  greatly simplify the implementation of the system, as there is no need
  to explicitly communicate data between cores.

][
  当 `pbrt` 在 CPU
  上运行时，我们假设计算是在提供一致性共享内存的处理器上进行的。一致性共享内存的核心思想是所有线程都可以读写一组公共内存位置，而一个线程对内存所做的更改最终会被其他线程看到。这些特性极大地简化了系统的实现，因为无需在核之间显式传递数据。

  尽管一致性共享内存降低了不同线程显式通信数据的需要，但它们仍然需要协调对共享数据的访问；一致性共享内存
  的一个风险在于数据竞争。如果两个线程在没有协作的情况下修改同一内存位置，程序几乎肯定会计算出错误结果，甚至崩溃。考虑以下两个处理器同时运行的看似无害的代码示例，其中
  `globalCounter` 初始值为 2：

]

#parec[
  Although coherent shared memory relieves the need for separate threads
  to explicitly communicate data with each other, they still need to
  coordinate their access to shared data; a danger of coherent shared
  memory is data races. If two threads modify the same memory location
  without coordination between the two of them, the program will almost
  certainly compute incorrect results or even crash. Consider the example
  of two processors simultaneously running the following innocuous-looking
  code, where `globalCounter` starts with a value of two:

][虽然一致性共享内存避免了不同线程之间显式地交换数据，但它们仍然需要协调对共享数据的访问；一致性共享内存的一个危险在于数据竞争。如果两个线程在没有协调的情况下修改同一个内存位置，程序几乎肯定会计算出错误的结果，甚至可能崩溃。考虑下面这个例子：两个处理器同时运行看似无害的代码，而此时 globalCounter 的初始值为 2：

]
```cpp
extern int globalCounter;
if (--globalCounter == 0)
    printf("done\n");
```


#parec[
  Because the two threads do not coordinate their reading and writing of
  `globalCounter`, it is possible that "done" will be printed zero, one,
  or even two times. For example, if both threads simultaneously load
  `globalCounter`, decrement it in a local register, and then write the
  result simultaneously, both will write a value of 1 and "done" will
  never be printed. ✦

][
  因为这两个线程并未协调对 `globalCounter`
  的读取与写入，它们可能会同时读取、在本地寄存器中递减，然后再同时写回，导致两次甚至三次写回上述结果，从而使
  "done" 可能被打印 0 次、1 次甚至 2 次。✦

]

#parec[
  Two main mechanisms are used for this type of synchronization: mutual
  exclusion and atomic operations. Mutual exclusion is implemented with
  `std::mutex` objects in `pbrt`. A `std::mutex` can be used to protect
  access to some resource, ensuring that only one thread can access it at
  a time:

][
  为此，通常使用两种主要的同步机制：互斥锁和原子操作。互斥锁通过
  `std::mutex` 对象在 `pbrt` 中实现。可以使用一个 `std::mutex`
  来保护对某资源的访问，确保同一时间只有一个线程可以访问它：


]

```cpp
extern int globalCounter;
extern std::mutex globalCounterMutex;
globalCounterMutex.lock();
if (--globalCounter == 0)
    printf("done\n");
globalCounterMutex.unlock();
```

#parec[
  #strong[Atomic memory operations] (or atomics) are the other option for
  correctly performing this type of memory update with multiple threads.
  Atomics are machine instructions that guarantee that their respective
  memory updates will be performed in a single transaction. (Atomic in
  this case refers to the notion that the memory updates are indivisible.)
  The implementations of atomic operations in `pbrt` are from the C++
  standard library. Using atomics, the computation above could be written
  to use the `std::atomic<int>` type, which has overloaded add, subtract,
  increment, and decrement operations, as below:

][
  #strong[原子内存操作];（或原子性操作）是另一种在多线程环境下正确执行这类内存更新的选择。原子操作是机器指令，保证其各自的内存更新在单一事务中完成。（此处的原子性指的是更新是不可分割的。）在
  `pbrt` 中，原子操作的实现来自 C++
  标准库。使用原子操作，上述计算可以改写为使用 `std::atomic<int>`
  类型，它具备加、减、增、减等重载操作，如下所示：

]

```cpp
extern std::atomic<int> globalCounter;
if (--globalCounter == 0)
    printf("done\n");
```


#parec[
  The `std::atomic` `--` operator subtracts one from the given variable,
  `globalCounter`, and returns the new value of the variable. Using an
  atomic operation ensures that if two threads simultaneously try to
  update the variable, then not only will the final value of the variable
  be the expected value, but each thread will be returned the value of the
  variable after its update alone. In this example, then, `globalCounter`
  will end up with a value of zero, as expected, with one thread
  guaranteed to have the value one returned from the atomic subtraction
  and the other thread guaranteed to have zero returned.

][
  `std::atomic` 的 `--` 运算符会将给定变量 `globalCounter` 的值减
  1，并返回该变量的新值。使用原子操作可确保如果两个线程同时试图更新该变量，不仅变量的最终值是期望值，而且每个线程在更新后都会得到该变量更新后的值。在这个示例中，`globalCounter`
  最终将得到零的值，一线程保证从原子减法中返回值为 1，另一线程保证返回值为
  0。

]

#parec[
  Another useful atomic operation is "compare and swap," which is also
  provided by the C++ standard library. It takes a memory location and the
  value that the caller believes the location currently stores. If the
  memory location still holds that value when the atomic compare and swap
  executes, then a new value is stored and true is returned; otherwise,
  memory is left unchanged and false is returned.

][
  另一个有用的原子操作是“ compare and swap ”（比较并交换），这也是 C++
  标准库提供的。它接收一个内存位置和调用方认为该位置当前存储的值。如果在执行原子比较并交换时该内存位置仍然保持该值，则存储一个新值并返回
  true；否则，内存保持不变并返回 false。

]

#parec[
  Compare and swap is a building block that can be used to build many
  other atomic operations. For example, the code below could be executed
  by multiple threads to compute the maximum of values computed by all the
  threads. (For this particular case, the specialized atomic maximum
  function would be a better choice, but this example helps convey the
  usage.)

][
  比较并交换是构建许多其他原子操作的基础构件。例如，下面的代码可能由多个线程并发执行，以计算所有线程计算值的最大值。（对于这种特定情况，专门的原子最大值函数会是更好的选择，但这个示例有助于说明用法。）


]

```cpp
std::atomic<int> maxValue;
int localMax = ...;
int currentMax = maxValue;
while (localMax > currentMax) {
    if (maxValue.compare_exchange_weak(currentMax, localMax))
        break;
}
```

#parec[
  If only a single thread is trying to update the memory location and the
  local value is larger, the loop is successful the first time through;
  the value loaded into `currentMax` is still the value stored by
  `maxValue` when `compare_exchange_weak()` executes and so `localMax` is
  successfully stored and true is returned.

][
  如果只有一个线程试图更新内存位置且局部值更大，则循环在第一次执行时就会成功；加载到
  `currentMax` 的值在执行 `compare_exchange_weak()` 时仍然是 `maxValue`
  所存储的值，因此 `localMax` 成功地被存储，返回值为 true。

]

#parec[
  An important application of atomic compare and swap is for the
  construction of data structures.
  Consider, for example, a tree data structure where each node has child
  node pointers initially set to `nullptr`. If code traversing the tree
  wants to create a new child at a node, code could be written like:


][
  原子比较并交换的一个重要应用是构建数据结构。
  例如，考虑一个树形数据结构，每个节点的子节点指针初始设为
  `nullptr`。如果遍历树的代码想在某个节点创建一个新的子节点，代码可以这样写：

]

```cpp
// atomic<Type *> node->firstChild
if (!node->firstChild) {
    Type *newChild = new Type ...
    Type *current = nullptr;
    if (node->firstChild.compare_exchange_weak(current, newChild) == false)
        delete newChild;
}
// node->firstChild != nullptr now
```

#parec[
  The idea is that if the child has the value `nullptr`, the thread
  speculatively creates and fully initializes the child node into a local
  variable, not yet visible to the other threads. Atomic compare and swap
  is then used to try to initialize the child pointer; if it still has the
  value `nullptr`, then the new child is stored and made available to all
  threads. If the child pointer no longer has the value `nullptr`, then
  another thread has initialized the child in the time between the current
  thread first seeing that it was `nullptr` and later trying to update it.
  In this case, the work done in the current thread turns out to have been
  wasted, but it can delete the locally created child node and continue
  execution, using the node created by the other thread.

][

  其思想是如果子节点的值为
  `nullptr`，则该线程会在本地变量中推断性地创建并完成初始化子节点。随后再尝试使用原子比较并交换来初始化子指针；若此时子指针仍为
  `nullptr`，则将新子节点存入并对所有线程可见。若在当前线程第一次看到
  `nullptr`
  到后续尝试更新之间，另一个线程已经初始化了子节点，那么当前线程的工作就等于白做了，但它可以删除本地创建的子节点并继续执行，使用另一线程创建的节点。
]

#parec[
  This method of tree construction is an example of a lock-free algorithm.
  This approach has a few advantages compared to, for example, using a
  single mutex to manage updating the tree. First, there is no overhead of
  acquiring the mutex for regular tree traversal. Second, multiple threads
  can naturally concurrently update different parts of the tree. The
  "Further Reading" section at the end of this appendix has pointers to
  more information about lock-free algorithms.

][

  这种树构造的方法是无锁算法的一个例子。与使用单个互斥锁来更新树结构等方式相比，这种方法有一些优点。首先，在常规树遍历中避免了获取互斢锁的开销。其次，多个线程可以自然地并发更新树的不同部分。附录末尾的“Further
  Reading”部分提供了更多关于无锁算法的信息。

]


=== Atomic Floating-Point Values
<b.6.2-atomic-floating-point-values>



#parec[
  The `std::atomic` template cannot be used with floating-point types. One
  of the main reasons that atomic operations are not supported with it is
  that floating-point operations are generally not associative: as
  discussed in Section 6.8.1, when computed in floating-point, the value
  of the sum `(a+b)+c` is not necessarily equal to the sum `a+(b+c)`. In
  turn, if a multi-threaded computation used atomic floating-point
  addition operations to compute some value, then the result computed
  would not be the same across multiple program executions. (In contrast,
  with integer types all the supported operations are associative, and so
  atomic operations give consistent results no matter which order threads
  perform them in.)

][

  模板不能与浮点类型一起使用。原子操作不被支持的一个主要原因是浮点运算通常不是结合性的：如在第
  6.8.1 节所述，在浮点运算中，和的值 `(a+b)+c` 并不一定等于
  `a+(b+c)`。因此，如果多线程计算使用原子浮点加法来计算某个值，结果在多次程序执行中将不一致。（相对地，整型类型的所有支持的运算都是结合性的，因此原子操作在任何线程顺序下都会给出一致的结果。）
]

#parec[
  For `pbrt`’s needs, these inconsistencies are generally tolerable, and
  being able to use atomic operations on Floats is preferable in some
  cases to using a lock. (One example is splatting pixel contributions in
  the RGBFilm::AddSplat() and GBufferFilm::AddSplat() methods.) For these
  purposes, we provide a small `AtomicFloat` class.

][
  对于 `pbrt`
  的需要来说，这些不一致通常是可以容忍的，在某些情况下能够在浮点数上使用原子操作要优于使用锁。（一个例子是
  RGBFilm::AddSplat() 和 GBufferFilm::AddSplat()
  方法中的像素贡献的分散处理。）为此，我们提供了一个小型的 `AtomicFloat`
  类。

]

```cpp
class AtomicFloat {
  public:
    explicit AtomicFloat(float v = 0) {
        bits = FloatToBits(v);
    }
    operator float() const {
        return BitsToFloat(bits);
    }
    Float operator=(float v) {
        bits = FloatToBits(v);
        return v;
    }
    void Add(float v) {
        FloatBits oldBits = bits, newBits;
        do {
            newBits = FloatToBits(BitsToFloat(oldBits) + v);
        } while (!bits.compare_exchange_weak(oldBits, newBits));
    }
    std::string ToString() const;
  private:
    std::atomic<FloatBits> bits;
};
```

#parec[
  An `AtomicFloat` can be initialized from a provided floating-point
  value. In the implementation here, floating-point values are actually
  represented as their unsigned integer bitwise values, as returned by the
  `FloatToBits()` function.

][
  `AtomicFloat`
  可以从提供的浮点值初始化。在这里的实现中，浮点值实际上表示为它们的无符号整数位表示，如
  `FloatToBits()` 函数返回的值。

]


```cpp
explicit AtomicFloat(float v = 0) {
    bits = FloatToBits(v);
}
```

#parec[
  Using an integer type to represent the value allows us to use a
  `std::atomic` type to store it in memory, which in turn allows the
  compiler to be aware that the value in memory is being updated
  atomically.

][

  使用整数类型来表示该值使我们能够使用 `std::atomic`
  类型在内存中存储它，从而使编译器知道内存中的该值以原子方式更新。

]

```cpp
std::atomic<FloatBits> bits;
```

#parec[
  Assigning the value or returning it as a `Float` is just a matter of
  converting to or from the unsigned integer representation.

][
  将该值赋值或作为 `Float` 返回只需将其转换为或从无符号整数表示转换即可。

]

```cpp
operator float() const {
    return BitsToFloat(bits);
}
Float operator=(float v) {
    bits = FloatToBits(v);
    return v;
}
```

#parec[
  Atomic floating-point addition is implemented via an atomic compare and
  exchange operation. In the do loop below, we convert the in-memory bit
  representation of the value to a `Float`, add the provided difference in
  `v`, and attempt to atomically store the resulting bits. If the
  in-memory value has been changed by another thread since the value from
  `bits` was read from memory, the implementation continues retrying until
  the value in memory matches the expected value (in `oldBits`), at which
  point the atomic update succeeds.

][

  原子浮点加法通过原子比较并交换操作实现。在下面的 do
  循环中，我们将内存中值的位表示转换为 `Float`，加上参数 `v`
  的差值，并尝试原子地存储得到的新位。如果从内存中读取 `bits`
  的值以来，内存中的值已被其他线程更改，则实现将继续重试，直到内存中的值与期望值（在
  `oldBits` 中）匹配，此时原子更新成功。

]
```cpp
void Add(float v) {
    FloatBits oldBits = bits, newBits;
    do {
        newBits = FloatToBits(BitsToFloat(oldBits) + v);
    } while (!bits.compare_exchange_weak(oldBits, newBits));
}
```

#parec[
  Recall that the `ParallelFor` framework in `pbrt` ensures that no other
  threads will concurrently call any of the other `ParallelForLoop1D`
  methods as long as the provided lock is held. Therefore, the method
  implementation here is free to access and modify member variables
  without needing to worry about mutual exclusion or atomic updates. Here,
  it is a simple matter to determine the range of iterations to run next,
  given a starting iteration and the chunk size. Note, however, that it is
  important to copy the `nextIndex` member variable into a local variable
  here while the lock is held, as that value will be accessed later when
  the lock is not held.

][
  回忆一下，`ParallelFor` 框架在 `pbrt`
  中确保在提供的锁被持有时，其他线程不会并发调用任何其他的
  `ParallelForLoop1D`
  方法。因此，这里的实现可以自由访问和修改成员变量，而无需担心互斥或原子更新的问题。这里，简单地确定下一步要运行的迭代范围即可，给定一个起始迭代和块大小。请注意，在持有锁时将
  `nextIndex`
  成员变量复制到一个局部变量中是很重要的，因为该值稍后在锁不再保持时将被访问。


]
```cpp
void ParallelForLoop1D::RunStep(std::unique_lock<std::mutex> *lock) {
    // Determine the range of loop iterations to run in this step
    int64_t indexStart = nextIndex;
    int64_t indexEnd = std::min(indexStart + chunkSize, endIndex);
    nextIndex = indexEnd;

    // Remove job from list if all work has been started
    if (!HaveWork())
        threadPool->RemoveFromJobList(this);

    // Release lock and execute loop iterations in [indexStart, indexEnd)
    lock->unlock();
    func(indexStart, indexEnd);
}
```

#parec[
  Recall that the `ThreadPool` ensures that no other threads will
  concurrently call any of the other `ParallelForLoop1D` methods as long
  as the provided lock is held. Therefore, the method implementation here
  is free to access and modify member variables without needing to worry
  about mutual exclusion or atomic updates. Here, it is a simple matter to
  determine the range of iterations to run next, given a starting
  iteration and the chunk size. Note, however, that it is important to
  copy the `nextIndex` member variable into a local variable here while
  the lock is held, as that value will be accessed later when the lock is
  not held.

][

  回忆一下，`ThreadPool` 确保在提供的 `lock`
  持有时，其他线程不会并发调用任何其他的 `ParallelForLoop1D`
  方法。因此，这里的实现可以自由访问和修改成员变量，而无需担心互斥或原子更新。这里，简单地确定下一步要运行的迭代范围即可，给定一个起始迭代和块大小。请注意，在持有锁时将
  `nextIndex`
  成员变量复制到一个局部变量中很重要，因为稍后在锁不再持有时将访问该值。


]
```cpp
int64_t indexStart = nextIndex;
int64_t indexEnd = std::min(indexStart + chunkSize, endIndex);
nextIndex = indexEnd;
```

#parec[

  If all the work for a job has begun, there is no need for it to be in
  the list of unfinished jobs that the `ThreadPool` maintains. Therefore,
  we immediately remove it from the list in that case. Note that just
  because a job is not in the work list does not mean that its work is
  completed.

][
  如果一个作业的所有工作都已经开始，则无需将其保留在 `ThreadPool`
  维护的未完成工作列表中。因此，在这种情况下，我们立即将其从列表中移除。请注意，仅仅因为一个作业不在工作列表中并不意味着它的工作已经完成。


]
```cpp
if (!HaveWork())
    threadPool->RemoveFromJobList(this);
```
#parec[

  Finally, the thread can release the lock and get to work executing the
  specified loop iterations.

][
  最后，线程可以释放锁并执行指定的循环迭代。

]
```cpp
lock->unlock();
func(indexStart, indexEnd);
```


#parec[
  The `ParallelFor()` function pulls all the pieces together to create a
  `ParallelForLoop1D` object, provide it to the thread pool, and then
  execute loop iterations in the thread that specified the loop. This
  function does not return until all the specified loop iterations are
  complete.

][
  `ParallelFor()` 函数将所有部分拼装起来，创建一个 `ParallelForLoop1D`
  对象，提供给线程池，然后在指定循环的线程中执行循环迭代。该函数在所有指定的循环迭代完成之前不会返回。

]

```cpp
void ParallelFor(int64_t start, int64_t end,
                 std::function<void(int64_t, int64_t)> func) {
    if (start == end) return;

    // Compute chunk size for parallel loop
    int64_t chunkSize =
        std::max<int64_t>(1, (end - start) / (8 * RunningThreads()));

    // Create and enqueue ParallelForLoop1D for this loop
    ParallelForLoop1D loop(start, end, chunkSize, std::move(func));
    std::unique_lock<std::mutex> lock =
        ParallelJob::threadPool->AddToJobList(&loop);

    // Help out with parallel loop iterations in the current thread
    while (!loop.Finished())
        ParallelJob::threadPool->WorkOrWait(&lock, true);
}
```


#parec[
  The first step is to compute the chunk size—how many loop iterations are
  performed each time a thread gets another block of work to do. On one
  hand, the larger this value is, the less often threads will need to
  acquire the mutex to get more work. If its value is too small, parallel
  speedup may be inhibited by worker threads being stalled while they wait
  for other threads to release the mutex. On the other hand, if it is too
  large, load balancing may be poor: all the threads but one may have
  finished the available work and be stalled, waiting for the last thread
  still working. Here the value is set inversely proportional to the
  number of threads in an effort to balance these two factors.

][
  第一步是计算块大小——每次线程获得另一块工作时执行的循环迭代数量。价值越大，线程获取更多工作的次数就越少；如果数值太小，工作就会因为其他线程释放互斥锁而等待，从而降低并行加速。另一方面，如果太大，负载均衡可能会变差：除了一个线程外的所有线程都可能完成了可用工作而被阻塞，等待最后一个仍在工作的线程。这里的取值与线程数成反比，以尝试平衡这两种因素。

]
```cpp
int64_t chunkSize =
    std::max<int64_t>(1, (end - start) / (8 * RunningThreads()));
```

#parec[
  (The function `RunningThreads()`—not included in the book—returns the
  total number of available threads for `pbrt`.)

][
  （书中未包含的函数 `RunningThreads()` 返回 `pbrt` 的可用总线程数。）
]

#parec[
  A `ParallelForLoop1D` object can now be initialized and provided to the
  thread pool. Because this `ParallelFor()` call does not return until all
  work for the loop is done, it is safe to allocate `loop` on the stack—no
  dynamic memory allocation is required.

][
  现在可以初始化一个 `ParallelForLoop1D` 对象并将其提供给线程池。由于此
  `ParallelFor()` 调用在循环所有工作完成之前不会返回，因此可以在栈上分配
  `loop`——无需动态内存分配。


]
```cpp
ParallelForLoop1D loop(start, end, chunkSize, std::move(func));
std::unique_lock<std::mutex> lock =
    ParallelJob::threadPool->AddToJobList(&loop);
```


#parec[
  After adding the job, the thread that called `ParallelFor()` (be it the
  main thread or one of the worker threads) starts work on the loop. By
  finishing the loop before allowing the thread that submitted it to do
  any more work, the implementation keeps the amount of enqueued work
  limited and allows subsequent code in the caller to proceed knowing the
  loop’s work is done after its call to `ParallelFor()` returns.

][
  在添加作业后，调用 `ParallelFor()`
  的线程（无论是主线程还是工作线程之一）开始对循环进行工作。通过在允许提交者继续工作之前完成循环实现，保持了排队工作的数量有限，并且调用方在执行完
  `ParallelFor()` 返回后可以继续执行后续代码，因为循环的工作已经完成。


]

#parec[
  Because a held lock to the ThreadPool’s mutex is returned from the call
  to `AddToJobList()`, it is safe to call both `Finished()` and
  `WorkOrWait()`.

][
  因为从对线程池互斥锁的调用返回的是一个持有的锁，所以可以安全地调用
  `Finished()` 和 `WorkOrWait()`。
]

```cpp
while (!loop.Finished())
    ParallelJob::threadPool->WorkOrWait(&lock, true);
```

#parec[
  There is a second variant of `ParallelFor()` that calls a callback that
  only takes a single loop index. This saves a line or two of code in
  implementations that do not care to know about the chunk’s
  `[start, end)` range.

][

  还有一个 `ParallelFor()`
  的第二个变体，它调用一个只接收一个循环索引的回调函数。这在实现中不关心块的
  `[start, end)` 范围时，可以省去一两行代码。

]
```cpp
void ParallelFor(int64_t start, int64_t end,
                 std::function<void(int64_t)> func) {
    ParallelFor(start, end, [&func](int64_t start, int64_t end) {
        for (int64_t i = start; i < end; ++i)
            func(i);
    });
}
```
#parec[
  `ParallelFor2D()` is not included here, but takes a `Bounds2i` to
  specify the loop domain and then calls a function that either takes a
  `Bounds2i` or one that takes a `Point2i`, along the lines of the two
  `ParallelFor()` variants.

][
  `ParallelFor2D()`（将在其他地方实现）接受一个 `Bounds2i`
  来指定循环域，然后调用一个函数，该函数要么接收 `Bounds2i`，要么接收
  `Point2i`，类似于上述两种 `ParallelFor()` 变体。


]

=== Memory Coherence Models and Performance
<b.6.3-memory-coherence-models-and-performance>


#parec[
  Cache coherence is a feature of all modern multicore CPUs; with it,
  memory writes by one processor are automatically visible to other
  processors. This is an incredibly useful feature; being able to assume
  it in the implementation of a system like `pbrt` is extremely helpful to
  the programmer. Understanding the subtleties and performance
  characteristics of this feature is important, however.

][
  缓存一致性是所有现代多核 CPU
  的特性；有了它，某处理器对内存的写入会自动对其他处理器可见。这是一个非常有用的特性；在像
  `pbrt`
  这样的系统实现中，能够在实现时假设这一点对程序员极为有帮助。然而，理解这一特性所带来的细微差别和性能特性也很重要。
]

#parec[
  One potential issue is that other processors may not see writes to
  memory in the same order that the processor that performed the writes
  issued them. This can happen for two main reasons: the compiler’s
  optimizer may have reordered write operations to improve performance,
  and the CPU hardware may write values to memory in a different order
  than the stream of executed machine instructions. When only a single
  thread is running, both of these are innocuous; by design, the compiler
  and hardware, respectively, ensure that it is impossible for a single
  thread of execution running the program to detect when these cases
  happen. This guarantee is not provided for multi-threaded code, however;
  doing so would impose a significant performance penalty, so hardware
  architectures leave requiring such ordering, when it matters, to
  software.

][

  一个潜在的问题是，其他处理器可能不会以与执行写入的处理器相同的顺序看到对内存的写入。这可能出于两个主要原因：编译器优化器可能为了提高性能而重新排序写操作，CPU
  硬件也可能以不同于执行机器指令的顺序将值写入内存。当只有一个线程在运行时，这两种情况都是无害的；按设计，编译器和硬件分别确保单个执行线程在程序中检测不到这些情况的发生。然而，这一保证并不适用于多线程代码，若要提供该保证，将对性能产生显著惩罚，因此在需要时，硬件架构通常将此类排序要求交给软件来实现。

]

#parec[
  Memory barrier instructions can be used to ensure that all write
  instructions before the barrier are visible in memory before any
  subsequent instructions execute. In practice, we generally do not need
  to issue memory barrier instructions explicitly, since both C++ atomic
  and the thread synchronization calls used to build multi-threaded
  algorithms can include them in their operation.

][
  内存屏障指令可用于确保屏障之前的所有写操作在随后任何指令执行之前在内存中可见。实际中，我们通常不需要显式发出内存屏障指令，因为
  C++
  的原子操作以及用于构建多线程算法的线程同步调用本身就可以在其操作中包含它们。


]

#parec[
  Although cache coherence is helpful to the programmer, it can sometimes
  impose a substantial performance penalty for data that is frequently
  modified and accessed by multiple processors. Read-only data has little
  penalty; copies of it can be stored in the local caches of all the
  processors that are accessing it, allowing all of them the same
  performance benefits from the caches as in the single-threaded case. To
  understand the downside of taking too much advantage of cache coherence
  for read–write data, it is useful to understand how cache coherence is
  typically implemented on processors.

][
  尽管缓存一致性对程序员有帮助，但当数据经常被多个处理器修改和访问时，它有时会对性能造成相当大的惩罚。只读数据几乎没有惩罚；它的副本可以存放在所有处理器的本地缓存中，让它们在缓存方面获得与单线程情况下相同的性能优势。要理解过度利用缓存一致性来处理读写数据的缺点，有必要了解缓存一致性在处理器上的典型实现方式。


]

#parec[
  CPUs implement a cache coherence protocol, which is responsible for
  tracking the memory transactions issued by all the processors in order
  to provide cache coherence. A classic such protocol is MESI, where the
  acronym represents the four states that each cache line can be in. Each
  processor stores the current state for each cache line in its local
  caches:

][

  CPU
  实现缓存一致性协议，负责跟踪所有处理器发出的内存事务，以提供缓存一致性。经典的一致性协议是
  MESI，首字母代表每条缓存行可能处于的四种状态。每个处理器在本地缓存中存储着该缓存行当前的状态：

]

#parec[
  - Modified — The current processor has written to the memory location,
    but the result is only stored in the cache—it is dirty and has not
    been written to main memory. No other processor has the location in
    its cache.
  - Exclusive — The current processor is the only one with the data from
    the corresponding memory location in its cache. The value in the cache
    matches the value in memory.
  - Shared — Multiple processors have the corresponding memory location in
    their caches, but they have only performed read operations.
  - Invalid — The cache line does not hold valid data.

][
  - Modified —
    当前处理器已经写入了内存位置，但结果仅存储在缓存中；该缓存行是脏的，尚未写回主内存。没有其他处理器在其缓存中拥有该位置。
  - Exclusive —
    当前处理器是缓存中唯一拥有该数据的处理器。缓存中的值与内存中的值一致。
  - Shared —
    多个处理器在其缓存中拥有相应的内存位置，但它们仅执行了读取操作。
  - Invalid — 缓存行不包含有效数据。

]

#parec[
  At system startup time, the caches are empty and all cache lines are in
  the invalid state. The first time a processor reads a memory location,
  the data for that location is loaded into cache and its cache line
  marked as being in the "exclusive" state. If another processor performs
  a memory read of a location that is in the "exclusive" state in another
  cache, then both caches record the state for the corresponding memory
  location to instead be "shared."

][

  系统启动时，缓存为空，所有缓存行都处于无效状态。处理器首次读取某个内存位置时，该位置的数据被加载到缓存中，并将该缓存行标记为“独占”状态。如果另一个处理器对处于“独占”状态的该位置在另一个缓存中执行内存读取，则两个缓存对相应内存位置的状态都改为“共享”。

]

#parec[
  When a processor writes to a memory location, the performance of the
  write depends on the state of the corresponding cache line. If it is in
  the "exclusive" state and already in the writing processor’s cache, then
  the write is cheap; the data is modified in the cache and the cache
  line’s state is changed to "modified." (If it was already in the
  "modified" state, then the write is similarly efficient.) In these
  cases, the value will eventually be written to main memory, at which
  point the corresponding cache line returns to the "exclusive" state.

][
  当处理器对内存位置进行写操作时，写操作的性能取决于该缓存行的状态。如果该缓存行处于“独占”状态且已在写入处理器的缓存中，此时写入成本较低；数据在缓存中被修改，缓存行的状态将改为“已修改”（Modified）。（如果它已处于“已修改”状态，则写入也同样高效。）在这些情况下，值最终会写回主内存，此时相应的缓存行将返回到“独占”状态。


]

#parec[
  However, if a processor writes to a memory location that is in the
  "shared" state in its cache or is in the "modified" or "exclusive" state
  in another processor’s cache, then expensive communication between the
  cores is required. All of this is handled transparently by the hardware,
  though it still has a performance impact. In this case, the writing
  processor must issue a read for ownership (RFO), which marks the memory
  location as invalid in the caches of any other processors; RFOs can
  cause stalls of tens or hundreds of cycles—a substantial penalty for a
  single memory write.

][
  然而，如果某处理器对其缓存中处于“共享”状态的内存位置，或对另一处理器缓存中处于“已修改”或“独占”状态的位置执行写操作，则需要进行昂贵的跨核通信。所有这一切都由硬件透明处理，但仍会带来性能影响。在这种情况下，写入处理器必须发出所有权读取（RFO）请求，这会在其他处理器的缓存中将该内存位置标记为无效；RFO
  可能导致几十甚至上百个时钟周期的阻塞——对单次内存写操作来说是相当大的惩罚。


]

#parec[
  In general, we would therefore like to avoid the situation of multiple
  processors concurrently writing to the same memory location as well as
  unnecessarily reading memory that another processor is writing to. An
  important case to be aware of is "false sharing," where a single cache
  line holds some read-only data and some data that is frequently
  modified. In this case, even if only a single processor is writing to
  the part of the cache line that is modified but many are reading from
  the read-only part, the overhead of frequent RFO operations will be
  unnecessarily incurred. `pbrt` uses `alignas` in the declaration of
  classes that are modified during rendering and are susceptible to false
  sharing in order to ensure that they take entire cache lines for
  themselves. A macro makes the system’s cache line size available.

][

  通常，我们希望避免多个处理器同时写入同一内存位置，以及避免不必要地读取其他处理器正在写入的内存。一个需要注意的重要情况是“伪共享”（false
  sharing），即单个缓存行中同时包含只读数据和经常被修改的数据。在这种情况下，即使只有一个处理器在对缓存行中被修改的部分写入，许多处理器正在读取该缓存行的只读部分，频繁的
  RFO 操作也会造成不必要的开销。`pbrt` 在渲染时可能修改的类声明中使用
  `alignas`
  以避免伪共享，使它们尽可能独占整条缓存行。一个宏提供了系统缓存行大小。


]


```cpp
#ifdef PBRT_BUILD_GPU_RENDERER
#define PBRT_L1_CACHE_LINE_SIZE 128
#else
#define PBRT_L1_CACHE_LINE_SIZE 64
#endif
```

=== Thread Pools and Parallel Jobs
<b.6.4-thread-pools-and-parallel-jobs>



#parec[
  Although C++ provides a portable abstraction for CPU threads via its
  `std::thread` class, creating and then destroying threads each time
  there is parallel work to do is usually not a good approach. Thread
  creation requires calls to the operating system, which must allocate and
  update data structures to account for each thread; this work consumes
  processing cycles that we would prefer to devote to rendering. Further,
  unchecked creation of threads can overwhelm the processor with many more
  threads than it is capable of executing concurrently. Flooding it with
  more work than it can handle may be detrimental to its ability to get
  through it.

][
  尽管 C++ 提供了通过其 `std::thread` 类实现的可移植的 CPU
  线程抽象，但每次有并行工作需要完成时就创建并销毁线程通常不是一个很好的做法。创建线程需要调用操作系统，必须为每个线程分配和更新数据结构；这会消耗我们更愿意用于渲染的处理周期。此外，随意创建大量线程也可能让处理器难以并发执行，从而带来性能下降。

]

#parec[
  A widely used solution to both of these issues is thread pools. With a
  thread pool, a fixed number of threads are launched at system startup
  time. They persist throughout the program’s execution, waiting for
  parallel work to help out with and sleeping when there is no work for
  them to do. In `pbrt`, the call to InitPBRT() creates a pool of worker
  threads (generally, one for each available CPU core). A further
  advantage of this implementation approach is that providing work to the
  threads is a fairly lightweight operation, which encourages the use of
  the thread pool even for fine-grained tasks.

][

  一种广泛使用的解决方案是线程池。通过线程池，在系统启动时就会启动固定数量的线程；它们在程序执行期间持续存在，等待并行工作、需要时协助完成工作，若没有任务则休眠。在
  `pbrt` 中，调用 InitPBRT() 会创建一个工作线程池（通常是每个可用 CPU
  核一个）。这种实现方式的另一个优点是，将工作提供给线程是一个相对轻量的操作，即使是对细粒度任务也能鼓励使用线程池。
]

```cpp
class ThreadPool {
  public:
    explicit ThreadPool(int nThreads);
    ~ThreadPool();

    size_t size() const { return threads.size(); }
    std::unique_lock<std::mutex> AddToJobList(ParallelJob *job);
    void RemoveFromJobList(ParallelJob *job);
    void WorkOrWait(std::unique_lock<std::mutex> *lock, bool isEnqueuingThread);
    bool WorkOrReturn();

    void Disable();
    void Reenable();
    void ForEachThread(std::function<void(void)> func);
    std::string ToString() const;
  private:
    void Worker();
    std::vector<std::thread> threads;
    mutable std::mutex mutex;
    bool shutdownThreads = false;
    bool disabled = false;
    ParallelJob *jobList = nullptr;
    std::condition_variable jobListCondition;
};
```

#parec[
  `pbrt`’s main thread of execution also participates in executing
  parallel work, so the `ThreadPool` constructor launches one fewer than
  the requested number of threads.

][
  pbrt 的主执行线程也参与执行并行工作，因此 ThreadPool
  构造函数会启动少于请求数量的一个线程。

]

```cpp
ThreadPool::ThreadPool(int nThreads) {
    for (int i = 0; i < nThreads - 1; ++i)
        threads.push_back(std::thread(&ThreadPool::Worker, this));
}
```

```cpp
std::vector<std::thread> threads;
```


#parec[
  The worker threads all run the `ThreadPool`’s `Worker()` method, which
  acquires a mutex and calls `WorkOrWait()` until system shutdown, at
  which point `shutdownThreads` will be set to `true` to signal the worker
  threads to exit. When we get to the implementation of `WorkOrWait()`, we
  will see that this mutex is only held briefly, until the thread is able
  to determine whether or not there is more work for it to perform.

][
  工作线程都运行 ThreadPool 的 `Worker()` 方法，该方法获取互斥锁并调用
  `WorkOrWait()`，直到系统关闭，此时 `shutdownThreads` 将被设为
  `true`，以通知工作线程退出。进入 `WorkOrWait()`
  的实现时，我们将看到该互斥锁只在短时间内保持，即线程能够判断是否还存在要执行的工作。

]

```cpp
void ThreadPool::Worker() {
    std::unique_lock<std::mutex> lock(mutex);
    while (!shutdownThreads)
        WorkOrWait(&lock, false);
}
```


```cpp
mutable std::mutex mutex;
bool shutdownThreads = false;
```

#parec[
  Before we get to the implementation of the `WorkOrWait()` method, we
  will discuss the `ParallelJob` class, which specifies an abstract
  interface for work that is executed by the thread pool and defines a few
  member variables that the `ThreadPool` will use to keep track of work.
  Because it is only used for CPU parallelism and is not used on the GPU,
  we will use regular virtual functions for dynamic dispatch in its
  implementation.

][
  在我们进入 `WorkOrWait()` 方法的实现之前，我们将讨论 `ParallelJob`
  类，它为线程池执行的工作指定了一个抽象接口，并定义了 `ThreadPool`
  将用来跟踪工作的若干成员变量。因为它只用于 CPU 并行化，在 GPU
  上不使用，所以在其实现中我们将使用常规的虚函数进行动态分派。


]


```cpp
class ParallelJob {
  public:
    virtual ~ParallelJob() { DCHECK(removed); }
    virtual bool HaveWork() const = 0;
    virtual void RunStep(std::unique_lock<std::mutex> *lock) = 0;
    bool Finished() const { return !HaveWork() && activeWorkers == 0; }
    virtual std::string ToString() const = 0;
    static ThreadPool *threadPool;

  private:
    friend class ThreadPool;
    int activeWorkers = 0;
    ParallelJob *prev = nullptr, *next = nullptr;
};
```


#parec[
  All the parallel work in `pbrt` is handled by a single thread pool
  managed by `ParallelJob`.

][
  pbrt 中的所有并行工作都由一个由 `ParallelJob` 管理的单一线程池处理。


]

```cpp
static ThreadPool *threadPool;
```


#parec[
  Each job may consist of one or more independent tasks. The two key
  methods that `ParallelJob` implementations must provide are `HaveWork()`
  and `RunStep()`. The former indicates whether there is any remaining
  work that has not yet commenced, and when the latter is called, some of
  the remaining work should be done. The implementation can assume that
  none of its methods will be called concurrently by multiple threads—in
  other words, that the calling code uses a mutex to ensure mutual
  exclusion.

][
  每个作业可以由一个或多个独立的任务组成。`ParallelJob`
  实现必须提供的两个关键方法是 `HaveWork()` 和
  `RunStep()`。前者指示是否还有尚未开始的工作，后者被调用时应该完成剩余的部分工作。实现可以假设它的任何方法都不会被多个线程并发调用——换句话说，调用代码使用互斥锁来确保互斥。

]

#parec[
  `RunStep()` is further passed a pointer to a lock that is already held
  when the method is called. It should be unlocked at its return.

][
  `RunStep()` 还被传入一个已经被持有的锁的指针。它应在返回时解锁。


]

```cpp
virtual bool HaveWork() const = 0;
virtual void RunStep(std::unique_lock<std::mutex> *lock) = 0;
```


```cpp
friend class ThreadPool;
int activeWorkers = 0;
```


#parec[
  In turn, a job is only finished if there is no more work to be handed
  out and if no threads are currently working on it.

][
  反过来，只有在没有更多工作可分配且没有线程正在处理该作业时，作业才算完成。


]


```cpp
bool Finished() const { return !HaveWork() && activeWorkers == 0; }
```


#parec[
  Returning to the `ThreadPool` implementation now, we will consider how
  work to be done is managed. The `ThreadPool` maintains a doubly linked
  list of jobs where its `jobList` member variable points to the list’s
  head. `ThreadPool::mutex` must always be held when accessing `jobList`
  or values stored in the `ParallelJob` objects held in it.

][
  回到 ThreadPool 的实现，我们将考虑如何管理待完成的工作。ThreadPool
  维护一个双向链表的作业列表，其 `jobList`
  成员变量指向该列表的头部。在访问 `jobList` 或其中的 `ParallelJob`
  对象中的值时，必须始终持有 `ThreadPool` 的互斥锁。


]

```cpp
ParallelJob *jobList = nullptr;
```

#parec[
  The link pointers are stored as `ParallelJob` member variables that are
  just for the use of the `ThreadPool` and should not be accessed by the
  `ParallelJob` implementation.

][
  链接指针作为 `ParallelJob` 的成员变量存储，供 ThreadPool 使用，不应被
  `ParallelJob` 实现直接访问。


]

```cpp
ParallelJob *prev = nullptr, *next = nullptr;
```
#parec[
  `AddToJobList()` acquires the mutex and adds the provided job to the
  work list before using a condition variable to signal the worker threads
  so that they wake up and start taking work from the list. The mutex lock
  is returned to the caller so that it can do any further job-related
  setup, assured that work will not start until it releases the lock.

][

  `AddToJobList()`
  获取互斥锁并在使用条件变量信号工作线程以唤醒它们从列表中开始取工作之前，将提供的作业加入工作列表的头部。互斥锁将被返回给调用方，以便它可以进行任何进一步的作业相关设置，并确保在释放锁之前不会开始工作。
]


```cpp
std::unique_lock<std::mutex> ThreadPool::AddToJobList(ParallelJob *job) {
    std::unique_lock<std::mutex> lock(mutex);
    // Add job to head of jobList
    if (jobList)
        jobList->prev = job;
    job->next = jobList;
    jobList = job;
    jobListCondition.notify_all();
    return lock;
}
```

#parec[
  Jobs are added to the front of the work list. In this way, if some
  parallel work enqueues additional work, the additional work will be
  processed before more is done on the initial work. This corresponds to
  depth-first processing of the work if dependent jobs are considered as a
  tree, which can avoid an explosion in the number of items in the work
  list.

][
  作业被添加到工作列表的前端。这样，如果某些并行工作会排队额外的工作，额外的工作将在初始工作之前得到处理。这对应于对工作视为一个树的深度优先处理，当把依赖作业视为树结构时，可以避免工作列项数量的激增。

]

```cpp
if (jobList)
    jobList->prev = job;
job->next = jobList;
jobList = job;
```

#parec[
  When there is no available work, worker threads wait on the
  `jobListCondition` condition variable.

][
  当没有可用的工作时，工作线程在 `jobListCondition` 条件变量上等待。


]

*todo*

//  todo


=== Parallel for Loops
<b.6.5-parallel-for-loops>


#parec[
  Much of the multi-core parallelism when `pbrt` is running on the CPU is
  expressed through parallel for loops using the `ParallelFor()` and
  `ParallelFor2D()` functions, which implement the `ParallelJob`
  interface. These functions take the loop body in the form of a function
  that is called for each iteration as well as a count of the total number
  of loop iterations to execute. Multiple iterations can thus run in
  parallel on different CPU cores. Calls to these functions return only
  after all the loop iterations have finished.

][
  当 `pbrt` 在 CPU 上运行时，大量的多核并行性通过 `ParallelFor()` 和
  `ParallelFor2D()` 函数以并行 for 循环的形式表达，它们实现了
  `ParallelJob`
  接口。这些函数将循环体以回调函数的形式传入，同时提供需要执行的循环迭代总数。因此，多个迭代可以在不同的
  CPU 核上并行运行。对这些函数的调用只有在所有循环迭代完成后才返回。


]

#parec[
  Here is an example of using `ParallelFor()`. The first two arguments
  give the range of values for the loop index and a C++ lambda expression
  is used to define the loop body; the loop index is passed to it as an
  argument. The lambda has access to the local `array` variable and
  doubles each array element in its body.

][
  下面是使用 `ParallelFor()`
  的一个示例。前两个参数给出循环索引的取值范围，使用 C++ 的 lambda
  表达式来定义循环体；循环索引作为参数传递给它。该 lambda 可以访问本地的
  `array` 变量，在其体中将数组的每个元素乘以 2。


]

```cpp
Float array[1024] = { ... };
ParallelFor(0, 1024, [array](int index) { array[index] *= 2; });
```

#parec[
  While it is also possible to pass a function pointer to `ParallelFor()`,
  lambdas are generally much more convenient, given their ability to
  capture locally visible variables and make them available in their body.

][
  尽管也可以将一个函数指针作为参数传给
  `ParallelFor()`，但考虑到它可以捕获局部可见变量并在其主体中使用，通常要方便得多。


]

#parec[
  `ParallelForLoop1D` implements the `ParallelJob` interface, for use in
  the `ParallelFor()` functions.

][

  `ParallelForLoop1D` 实现了 `ParallelJob` 接口，用于 `ParallelFor()`
  函数。


]


```cpp
class ParallelForLoop1D : public ParallelJob {
  public:
    ParallelForLoop1D(int64_t startIndex, int64_t endIndex, int chunkSize,
                      std::function<void(int64_t, int64_t)> func)
        : func(std::move(func)), nextIndex(startIndex), endIndex(endIndex),
          chunkSize(chunkSize) {}
    bool HaveWork() const { return nextIndex < endIndex; }
    void RunStep(std::unique_lock<std::mutex> *lock);
    std::string ToString() const {
        return StringPrintf("[ ParallelForLoop1D nextIndex: %d endIndex: %d "
                            "chunkSize: %d ]",
                            nextIndex, endIndex, chunkSize);
    }
  private:
    std::function<void(int64_t, int64_t)> func;
    int64_t nextIndex, endIndex;
    int chunkSize;
};
```

#parec[
  In addition to the callback function for the loop body, the constructor
  takes the range of values the loop should cover via the `startIndex` and
  `endIndex` parameters. For loops with relatively large iteration counts
  where the work done per iteration is small, it can be worthwhile to have
  the threads running loop iterations do multiple iterations before
  getting more work. (Doing so helps amortize the overhead of determining
  which iterations should be assigned to a thread.) Therefore,
  `ParallelFor()` also takes an optional `chunkSize` parameter that
  controls the granularity of the mapping of loop iterations to processing
  threads.

][
  除了循环体的回调函数外，构造函数还通过 `startIndex` 与 `endIndex`
  参数接收循环应覆盖的值域。对于迭代次数较大、每次迭代工作量较小时的循环，线程在获得更多工作之前执行多次迭代可能更划算，以抵消确定应分配给线程的迭代的开销。因此，`ParallelFor()`
  还提供了一个可选的 `chunkSize`
  参数，用于控制将循环迭代映射到处理线程的粒度。

]

```cpp
ParallelForLoop1D(int64_t startIndex, int64_t endIndex, int chunkSize,
                  std::function<void(int64_t, int64_t)> func)
    : func(std::move(func)), nextIndex(startIndex), endIndex(endIndex),
      chunkSize(chunkSize) {}
```

#parec[
  The nextIndex member variable tracks the next loop index to be executed. It is incremented by workers as they claim loop iterations to execute in their threads.
][

]

```cpp
// <<ParallelForLoop1D Private Members>>=
std::function<void(int64_t, int64_t)> func;
int64_t nextIndex, endIndex;
int chunkSize;
```

#parec[
  The HaveWork() method is easily implemented.
][

]

```
<<ParallelForLoop1D Public Methods>>+=
bool HaveWork() const { return nextIndex < endIndex; }
```


#parec[
  RunStep() determines which loop iterations to run and does some housekeeping before releasing the provided lock and executing loop iterations.
][

]

```cpp
<<ParallelForLoop1D Method Definitions>>=
void ParallelForLoop1D::RunStep(std::unique_lock<std::mutex> *lock) {
    <<Determine the range of loop iterations to run in this step>>
    <<Remove job from list if all work has been started>>
    <<Release lock and execute loop iterations in [indexStart, indexEnd)>>
}
```


```cpp
void ParallelForLoop1D::RunStep(std::unique_lock<std::mutex> *lock) {
    // Determine the range of loop iterations to run in this step
    int64_t indexStart = nextIndex;
    int64_t indexEnd = std::min(indexStart + chunkSize, endIndex);
    nextIndex = indexEnd;

    // Remove job from list if all work has been started
    if (!HaveWork())
        threadPool->RemoveFromJobList(this);

    // Release lock and execute loop iterations in [indexStart, indexEnd)
    lock->unlock();
    func(indexStart, indexEnd);
}
```

#parec[
  Recall that the `ThreadPool` ensures that no other threads will
  concurrently call any of the other `ParallelForLoop1D` methods as long
  as the provided `lock` is held. Therefore, the method implementation
  here is free to access and modify member variables without needing to
  worry about mutual exclusion or atomic updates. Here, it is a simple
  matter to determine the range of iterations to run next, given a
  starting iteration and the chunk size. Note, however, that it is
  important to copy the `nextIndex` member variable into a local variable
  here while the lock is held, as that value will be accessed later when
  the lock is not held.

][
  回忆一下，ThreadPool
  确保在提供的锁被持有时，其他线程不会并发调用任何其他的 ParallelForLoop1D
  方法。因此，这里的实现可以自由访问和修改成员变量，而无需担心互斥或原子更新。这里，简单地确定下一步要运行的迭代范围即可，给定一个起始迭代和块大小。请注意，在持有锁时将
  `nextIndex`
  成员变量复制到一个局部变量中很重要，因为稍后在锁不再持有时将访问该值。


]


```cpp
int64_t indexStart = nextIndex;
int64_t indexEnd = std::min(indexStart + chunkSize, endIndex);
nextIndex = indexEnd;
```


#parec[
  If all the work for a job has begun, there is no need for it to be in
  the list of unfinished jobs that the `ThreadPool` maintains. Therefore,
  we immediately remove it from the list in that case. Note that just
  because a job is not in the work list does not mean that its work is
  completed.

][
  如果一个作业的所有工作都已经开始，则无需将其保留在 `ThreadPool`
  维护的未完成工作列表中。因此，在这种情况下，我们立即将其从列表中移除。请注意，仅仅因为一个作业不在工作列表中并不意味着它的工作已经完成。


]
```cpp
if (!HaveWork())
    threadPool->RemoveFromJobList(this);
```

#parec[
  Finally, the thread can release the lock and get to work executing the
  specified loop iterations.

][
  最后，线程可以释放锁并执行指定的循环迭代。


]


```cpp
lock->unlock();
func(indexStart, indexEnd);
```

#parec[
  The `ParallelFor()` function pulls all the pieces together to create a
  `ParallelForLoop1D` object, provide it to the thread pool, and then
  execute loop iterations in the thread that specified the loop. This
  function does not return until all the specified loop iterations are
  complete.

][
  `ParallelFor()` 函数将所有部分拼装起来以创建一个 `ParallelForLoop1D`
  对象，将其提供给线程池，然后在指定循环的线程中执行循环迭代。该函数在所有指定的循环迭代完成之前不返回。

]


```cpp
void ParallelFor(int64_t start, int64_t end,
                 std::function<void(int64_t, int64_t)> func) {
    if (start == end) return;
    // Compute chunk size for parallel loop
    int64_t chunkSize =
        std::max<int64_t>(1, (end - start) / (8 * RunningThreads()));
    // Create and enqueue ParallelForLoop1D for this loop
    ParallelForLoop1D loop(start, end, chunkSize, std::move(func));
    std::unique_lock<std::mutex> lock =
        ParallelJob::threadPool->AddToJobList(&loop);

    // Help out with parallel loop iterations in the current thread
    while (!loop.Finished())
        ParallelJob::threadPool->WorkOrWait(&lock, true);
}
```


#parec[
  The first step is to compute the chunk size—how many loop iterations are
  performed each time a thread gets another block of work to do. On one
  hand, the larger this value is, the less often threads will need to
  acquire the mutex to get more work. If its value is too small, parallel
  speedup may be inhibited by worker threads being stalled while they wait
  for other threads to release the mutex. On the other hand, if it is too
  large, load balancing may be poor: all the threads but one may have
  finished the available work and be stalled, waiting for the last thread
  still working. Here the value is set inversely proportional to the
  number of threads in an effort to balance these two factors.

][
  第一步是计算块大小——每次线程获取另一块工作时执行的循环迭代数量。一方面，这个值越大，线程获取更多工作的次数就越少；若其值太小，工作量的并行加速可能会被工作者线程在等待其他线程释放互斥锁时阻塞。另一方面，若太大，负载均衡可能会较差：除了一个线程外的所有线程可能已经完成可用的工作而被阻塞，等待仍在工作的最后一个线程。在这里，这个值与线程数成反比，以努力在这两方面取得平衡。

]
```cpp
int64_t chunkSize =
    std::max<int64_t>(1, (end - start) / (8 * RunningThreads()));
```

#parec[
  (The `RunningThreads()` function, which is not included in the book,
  returns the total number of available threads for `pbrt`.)

][
  （书中未包含的函数 `RunningThreads()` 返回 `pbrt` 的总可用线程数。）


]

#parec[
  A `ParallelForLoop1D` object can now be initialized and provided to the
  thread pool. Because this `ParallelFor()` call does not return until all
  work for the loop is done, it is safe to allocate `loop` on the stack—no
  dynamic memory allocation is required.

][

  现在一个 `ParallelForLoop1D` 对象可以被初始化并提供给线程池。由于该
  `ParallelFor()` 调用在循环的所有工作完成之前不会返回，因此可以将 `loop`
  放在栈上分配——不需要动态内存分配。


]

```cpp
ParallelForLoop1D loop(start, end, chunkSize, std::move(func));
std::unique_lock<std::mutex> lock =
    ParallelJob::threadPool->AddToJobList(&loop);
```

#parec[
  After adding the job, the thread that called `ParallelFor()` (be it the
  main thread or one of the worker threads) starts work on the loop. By
  finishing the loop before allowing the thread that submitted it to do
  any more work, the implementation keeps the amount of enqueued work
  limited and allows subsequent code in the caller to proceed knowing the
  loop’s work is done after its call to `ParallelFor()` returns.

][
  在添加作业之后，调用 `ParallelFor()`
  的线程（无论是主线程还是某个工作线程）开始在循环上工作。通过在提交者再提交更多工作之前完成循环实现，保持排队工作的数量有限，并在调用方的
  `ParallelFor()` 返回后继续执行后续代码，确保循环的工作在返回后已经完成。


]

#parec[
  Because a held lock to the `ThreadPool`’s mutex is returned from the
  call to `AddToJobList()`, it is safe to call both `Finished()` and
  `WorkOrWait()`.

][

  还有一个第二种版本的
  `ParallelFor()`，它调用一个回调仅接收单个循环索引。这在实现中不关心块的
  `[start, end)` 范围时，可以省去一行或两行代码。


]
```cpp
while (!loop.Finished())
    ParallelJob::threadPool->WorkOrWait(&lock, true);
```


#parec[
  There is a second variant of `ParallelFor()` that calls a callback that
  only takes a single loop index. This saves a line or two of code in
  implementations that do not care to know about the chunk’s
  `[start, end)` range.

][

  还有一个第二种版本的
  `ParallelFor()`，它调用一个回调仅接收单个循环索引。这在实现中不关心块的
  `[start, end)` 范围时，可以省去一行或两行代码。


]
```cpp
void ParallelFor(int64_t start, int64_t end,
                 std::function<void(int64_t)> func) {
    ParallelFor(start, end, [&func](int64_t start, int64_t end) {
        for (int64_t i = start; i < end; ++i)
            func(i);
    });
}
```

#parec[
  `ParallelFor2D()` (to be implemented elsewhere) takes a `Bounds2i` to
  specify the loop domain and then calls a function that either takes a
  `Bounds2i` or one that takes a `Point2i`, along the lines of the two
  `ParallelFor()` variants.

][
  `ParallelFor2D()`（将在其他地方实现）接收一个 `Bounds2i`
  以指定循环域，然后调用一个函数，该函数要么接收 `Bounds2i`，要么接收
  `Point2i`，与前述两种 `ParallelFor()` 变体的思路相同。


]


=== Asynchronous Jobs
<b.6.6-asynchronous-jobs>

#parec[
  Parallel for loops are useful when the parallel work is easily expressed
  as a loop of independent iterations; it is just a few lines of changed
  code to parallelize an existing `for` loop. The fact that
  `ParallelFor()` and `ParallelFor2D()` ensure that all loop iterations
  have finished before they return is also helpful since subsequent code
  can proceed knowing any values set in the loop are available.
  However, not all work fits that form. Sometimes one thread of execution
  may produce independent work that could be done concurrently by a
  different thread. In this case, we would like to be able to provide that
  work to the thread pool and then continue on in the current thread,
  harvesting the result of the independent work some time later. `pbrt`
  therefore provides a second mechanism for parallel execution in the form
  of asynchronous jobs that execute a given function (often, a lambda
  function). The following code shows an example of their use.


][
  当并行 for 循环在工作量易于表达为独立迭代的循环时非常有用；将现有的
  `for` 循环并行化只需几行代码的改动。`ParallelFor()` 与 `ParallelFor2D()`
  确保在返回之前所有循环迭代都完成，这也有助于后续代码在循环中的值可用时继续执行。
  然而，并非所有工作都适合这种形式。有时一个执行流中的某个线程可能产生独立的工作，其他线程可以并行完成。在这种情况，我们希望能够将这部分工作提供给线程池，然后在当前线程中继续执行，稍后再收集独立工作结果。`pbrt`
  因此提供了第二种并行执行机制——异步作业，它执行给定的函数（通常是一个
  lambda）。下面的代码演示了它们的用法。

]

```cpp
extern Result func(float x);
AsyncJob<Result> *job = RunAsync(func, 0.5f);
...
Result r = job->GetResult();
```


#parec[
  The `RunAsync()` function takes a function as its first parameter as
  well as any arguments that the function takes. It returns an `AsyncJob`
  to the caller, which can then continue execution. When the `AsyncJob`’s
  `GetResult()` method is subsequently called, the call will only return
  after the asynchronous function has executed, be it by another thread in
  the thread pool or by the calling thread. The value returned by the
  asynchronous function is then returned to the caller.

][

  `RunAsync()`
  函数将函数作为第一个参数以及该函数的任意参数一起传入。它会返回一个
  `AsyncJob` 给调用方，调用方可以继续执行。当随后对 `AsyncJob` 的
  `GetResult()`
  方法进行调用时，该调用只有在异步函数完成执行后才会返回，可能由线程池中的另一线程完成，也可能由调用线程完成。异步函数返回的值随后返回给调用方。

]

#parec[
  The `AsyncJob` class implements the `ParallelJob` interface. It is
  templated on the return type of the function it manages.

][
  构造函数未在此处给出，接受异步函数并将其存储在成员变量 `func`
  中。`started` 用于记录是否已由某个线程开始执行该函数。


]

```cpp
template <typename T>
class AsyncJob : public ParallelJob {
public:
    AsyncJob(std::function<T(void)> w) : func(std::move(w)) {}
    bool HaveWork() const { return !started; }
    void RunStep(std::unique_lock<std::mutex> *lock) {
        threadPool->RemoveFromJobList(this);
        started = true;
        lock->unlock();
        // Execute asynchronous work and notify waiting threads of its completion
        T r = func();
        std::unique_lock<std::mutex> ul(mutex);
        result = r;
        cv.notify_all();
    }
    bool IsReady() const {
        std::lock_guard<std::mutex> lock(mutex);
        return result.has_value();
    }
    T GetResult() {
        Wait();
        std::lock_guard<std::mutex> lock(mutex);
        return *result;
    }
    // ... (TryGetResult, Wait, DoWork, ToString, etc.)
};
```


#parec[

  The constructor, not included here, takes the asynchronous function and
  stores it in the `func` member variable. `started` is used to record
  whether some thread has begun running the function.

][
  一个 `AsyncJob`
  表示单个工作量单位；只有一个线程可以参与，因此一旦有一个线程开始执行该函数，其他线程就没有可做的工作。下面给出
  `ParallelJob` 接口的 `HaveWork()` 方法的实现。


]


```cpp
std::function<T(void)> func;
bool started = false;
```

#parec[
  An `AsyncJob` represents a single quantum of work; only one thread can
  help, so once one has started running the function, there is nothing for
  any other thread to do. Implementation of the `HaveWork()` method for
  the `ParallelJob` interface follows.

][
  `RunStep()` 方法在调用提供的函数之前进行了一些小的记账工作；在这一点上将
  `AsyncJob`
  从作业列表中移除是值得的，因为在迭代过程中其他线程无需考虑它。

]


```cpp
bool HaveWork() const { return !started; }
```


#parec[
  The `RunStep()` method starts with some minor bookkeeping before calling
  the provided function; it is worth removing the `AsyncJob` from the job
  list at this point, as there is no reason for other threads to consider
  it when they iterate through the list.

][

]

```cpp
void RunStep(std::unique_lock<std::mutex> *lock) {
    threadPool->RemoveFromJobList(this);
    started = true;
    lock->unlock();
    // Execute asynchronous work and notify waiting threads of its completion
    T r = func();
    std::unique_lock<std::mutex> ul(mutex);
    result = r;
    cv.notify_all();
}
```


#parec[
  The asynchronous function is called without the `AsyncJob`’s mutex being
  held so that its execution does not stall other threads that may want to
  quickly check whether the function has finished running; the mutex is
  only acquired when a value is available to store in `result`. Note also
  the use of a condition variable after `result` is set: other threads
  that are waiting for the result wait on this condition variable, so it
  is important that they be notified.

][

  异步函数在不持有 `AsyncJob`
  的互斥锁时被调用，以便其执行不会阻塞希望快速检查函数是否完成的其他线程；只有在有值可存储在
  `result` 中时才会获取互斥锁。还要注意在设置 `result`
  之后使用条件变量：等待结果的其他线程会在此条件变量上等待，因此通知它们非常重要。

]


```cpp
T r = func();
std::unique_lock<std::mutex> ul(mutex);
result = r;
cv.notify_all();
```


#parec[
  Using `optional` to store the function’s result simplifies keeping track
  of whether the function has been executed.

][
  使用 `optional` 存储函数的结果简化了跟踪函数是否已执行的过程。


]


```cpp
pstd::optional<T> result;
mutable std::mutex mutex;
std::condition_variable cv;
```

#parec[
  A convenience `IsReady()` method that indicates whether the function has
  run and its result is available is easily implemented.
][
  一个便利的 `IsReady()`
  方法，用于指示函数是否已经执行且结果可用，可以很容易地实现。


]

```cpp
bool IsReady() const {
    std::lock_guard<std::mutex> lock(mutex);
    return result.has_value();
}
```

#parec[
  The `GetResult()` method starts by calling `Wait()`, which only returns
  once the function’s return value is available. The value of `*result`
  can therefore then be returned with no further checks.
][

  `GetResult()` 方法以调用 `Wait()`
  开始，只有当函数的返回值可用时才返回。因此，之后可以在不再需额外检查的情况下返回
  `*result` 的值。

]
```cpp
T GetResult() {
    Wait();
    std::lock_guard<std::mutex> lock(mutex);
    return *result;
}
```



#parec[
  The `RunAsync()` function is more complex; it uses a variadic template
  to capture the function’s argument values and creates an `AsyncJob` of
  the correct type. This complexity is not included here in full detail.
][
  `RunAsync()`
  函数更加复杂；它使用变参模板来捕获函数的参数值，并创建一个适当类型的
  `AsyncJob`。这里没有完整展开这部分的复杂实现。


]

```cpp
template <typename F, typename... Args>
auto RunAsync(F func, Args &&...args) {
    // Create AsyncJob for func and args
    auto fvoid = std::bind(func, std::forward<Args>(args)...);
    using R = typename std::invoke_result_t<F, Args...>;
    AsyncJob<R> *job = new AsyncJob<R>(std::move(fvoid));

    // Enqueue job or run it immediately
    std::unique_lock<std::mutex> lock;
    if (RunningThreads() == 1)
        job->DoWork();
    else
        lock = ParallelJob::threadPool->AddToJobList(job);
    return job;
}
```

#parec[
  The `AsyncJob` class assumes that the function to execute does not take
  any arguments, though `RunAsync()` allows the provided function to take
  arguments. Therefore, it starts by using `std::bind()` to create a new
  callable object with the arguments bound and no arguments remaining. An
  alternative design might generalize `AsyncJob` to allow arguments,
  though at a cost of added complexity that we think is better left to
  `std::bind`. Given the new function `fvoid`, its return type `R` can be
  found, which allows for creating an `AsyncJob` of the correct type.
  Dynamic allocation is necessary for the `AsyncJob` here since it must
  outlast the call to `RunAsync()`.
][

  AsyncJob 类假定要执行的函数不带参数，尽管 `RunAsync()`
  允许提供带参数的函数。因此，它首先使用 `std::bind()`
  创建一个绑定了参数且不再有参数的可调用对象。另一种设计可能将 `AsyncJob`
  泛化为允许参数，但这会带来额外的复杂性，或许更适合交给
  `std::bind`。得到新的函数 `fvoid` 后，其返回类型 `R`
  将被确定，从而允许创建正确类型的 `AsyncJob`。由于必须在调用 `RunAsync()`
  之后继续存在，因此需要对 `AsyncJob` 进行动态分配。

]
```cpp
auto fvoid = std::bind(func, std::forward<Args>(args)...);
using R = typename std::invoke_result_t<F, Args...>;
AsyncJob<R> *job = new AsyncJob<R>(std::move(fvoid));
```

#parec[

  If there is no thread pool (e.g., due to the user specifying that no
  additional threads should be used), then the work is performed
  immediately via a call to `DoWork()` (the implementation of which is not
  included here), which immediately invokes the function and saves its
  result in `AsyncJob::result`. Otherwise, it is added to the job list.
][
  如果没有线程池（例如用户指定不应使用额外的线程），那么工作将通过调用
  `DoWork()`
  直接执行（其实现未在此处给出），这会直接调用函数并将结果保存在
  `AsyncJob::result` 中。否则，就将作业加入作业列表。


]
```cpp
std::unique_lock<std::mutex> lock;
if (RunningThreads() == 1)
    job->DoWork();
else
    lock = ParallelJob::threadPool->AddToJobList(job);
```


=== Thread-Local Variables
<b.6.7-thread-local-variables>

#parec[
  It is often useful to have local data associated with each executing
  thread that it can access without concern of mutual exclusion with other
  threads. For example, per-thread Sappers and ScratchBuffer objects were
  used by the ImageTileIntegrator in Section 1.3.4. The `ThreadLocal`
  template class handles the details of such cases, creating per-thread
  instances of a managed object type `T` on demand as threads require
  them.
][
  通常很有用的是为每个执行的线程维护本地数据，以便它在无需担心与其他线程的互斥的情况下访问。例如，在
  1.3.4 节的 ImageTileIntegrator 中曾使用每线程的 Sappers 和 ScratchBuffer
  对象。`ThreadLocal`
  模板类处理这类情况，在需要时按需为线程创建托管对象类型 `T`
  的每线程实例。
]

```cpp
template <typename T>
class ThreadLocal {
public:
    ThreadLocal()
        : hashTable(4 * RunningThreads()), create([]() { return T(); }) {}
    ThreadLocal(std::function<T(void)>&& c)
        : hashTable(4 * RunningThreads()), create(c) {}
    T &Get();
    template <typename F>
    void ForAll(F &&func);
private:
    struct Entry {
        std::thread::id tid;
        T value;
    };
    std::shared_mutex mutex;
    std::vector<pstd::optional<Entry>> hashTable;
    std::function<T(void)> create;
};
```

#parec[
  ThreadLocal uses a hash table to manage the objects. It allocates a
  fixed-size array for the hash table in order to avoid the complexity of
  resizing the hash table at runtime. For `pbrt`’s use, where the number
  of running threads is fixed, this is a reasonable simplification. If the
  caller provides a function that returns objects of the type `T`, then it
  is used to create them; otherwise, the object’s default constructor is
  called.
][
  ThreadLocal
  使用哈希表来管理对象。它分配一个固定大小的哈希表，以避免在运行时重新调整哈希表规模的复杂性。对于
  `pbrt`
  的用法，在运行线程数量固定的情况下，这是一个合理的简化。如果调用方提供一个返回
  `T`
  类型对象的函数，那么它将被用来创建对象；否则，对象将使用默认构造函数创建。


]
```cpp
ThreadLocal()
    : hashTable(4 * RunningThreads()), create([]() { return T(); }) {}
ThreadLocal(std::function<T(void)>&&c)
    : hashTable(4 * RunningThreads()), create(c) {}
```
#parec[
  The Get() method returns the instance of the object that is associated with the calling thread. It takes care of allocating the object and inserting it into the hash table when needed.
][
  `Get()` 方法会返回与调用线程相关联的对象实例。在需要时，它还会负责分配该对象并将其插入哈希表中。
]

```cpp
T &Get();
```

#parec[
  It is useful to be able to iterate over all the per-thread objects
  managed by `ThreadLocal`. That capability is provided by the `ForAll()`
  method.
][
  能够遍历由 `ThreadLocal` 管理的所有各线程对象非常有用。这一能力通过
  `ForAll()` 方法提供。

]

```cpp
template <typename F>
void ForAll(F &&func);
```
