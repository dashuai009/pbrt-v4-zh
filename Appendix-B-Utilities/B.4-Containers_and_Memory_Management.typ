#import "../template.typ": parec
== Containers and Memory Management

#parec[
  A variety of container data structures that extend those made available
  by the standard library are provided in the file `util/containers.h`
  #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/containers.h")[here];.

][
  在文件 util/containers.h
  中提供了多种扩展自标准库的容器数据结构，详见此处：https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/containers.h。
]

#parec[
  First, there is `InlinedVector`. We will not describe its implementation
  here, but note that it is an extended version of `std::vector` that has
  storage for a handful of vector elements preallocated in its class
  definition. Thus, for short vectors, it can be used without incurring
  the cost of dynamic memory allocation. It is used extensively in the
  #link("../Utilities/Images.html#Image")[Image] class, for example.

][
  首先，有 InlinedVector。这里不对其实现进行描述，但需要指出的是它是在
  std::vector
  的基础上扩展的一种实现，在类定义中为少量向量元素预先分配了存储空间。因此对于较短的向量，可以在不产生动态内存分配开销的情况下使用。例如，它在
  Image 类中被广泛使用。
]

#parec[
  Its class declaration is of the form:

  ```cpp
  template <typename T, int N, class Allocator = /* ... */>
  class InlinedVector;
  ```

][
  其类声明形式为：

  ```cpp
  template <typename T, int N, class Allocator = /* ... */>
  class InlinedVector;
  ```
]

#parec[
  The value of `N` specifies the number of elements to handle via the
  inline allocation in the class definition.

][
  N 的值指定了通过在类定义中内联分配来处理的元素数量。
]

#parec[
  Even though the C++ standard library provides a hash table via
  `std::unordered_map`, pbrt additionally provides a `HashMap`, also not
  included here. There are two reasons it exists: first, the hash table in
  the standard library is specified such that pointers to elements in the
  hash table will not change even if the table is resized, which in turn
  requires dynamic memory allocation for each element. Second, the GPU
  rendering path requires a hash table that can be used from GPU code.

][
  即便 C++ 标准库通过 std::unordered\_map 提供了哈希表，pbrt
  还额外提供了一个 HashMap,
  同样不在此处包含。存在它有两个原因：第一，标准库中的哈希表规定即使哈希表被调整大小，指向哈希表中元素的指针也不会改变，这反过来需要对每个元素进行动态内存分配。第二，GPU
  渲染路径需要一个可以在 GPU 代码中使用的哈希表。
]

#parec[
  Its class declaration is of the form:

  ```cpp
  template <typename Key, typename Value, typename Hash = std::hash<Key>,
            typename Allocator = /* ... */>
  class HashMap;
  ```

][
  它的类声明形式为：

  ```cpp
  template <typename Key, typename Value, typename Hash = std::hash<Key>,
            typename Allocator = /* ... */>
  class HashMap;
  ```
]

#parec[
  Its main methods have the following signatures:

  ```cpp
  void Insert(const Key &key, const Value &value);
  bool HasKey(const Key &key) const;
  const Value &operator[](const Key &key) const;
  ```

][
  其主要方法的签名如下:

  ```cpp
  void Insert(const Key &key, const Value &value);
  bool HasKey(const Key &key) const;
  const Value &operator[](const Key &key) const;
  ```
]

#parec[
  2D Arrays

][
  二维数组
]

#parec[
  While it is not difficult to index into a 1D memory buffer that
  represents a 2D array of values, having a template class that handles
  this task helps make code elsewhere in the system less verbose and
  easier to verify. `Array2D` fills this role in pbrt.

][
  尽管从表示二维数值的内存缓冲区中进行索引并不困难，但有一个模板类来处理这项任务有助于让系统中其他地方的代码更少冗长且更易于验证。Array2D
  在 pbrt 中承担了这一角色。
]

#parec[
  The array is defined over a 2D region specified by `extent`; its lower
  bounds do not necessarily need to be at (0,0).

][
  该数组在由 extent 指定的二维区域上定义；其下界不一定需要在 (0,0)。
]


