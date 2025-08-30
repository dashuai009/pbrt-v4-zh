#import "../template.typ": parec
== Containers and Memory Management
<b.4-containers-and-memory-management>


```
template <typename T, int N, class Allocator = /* ... */>
class InlinedVector;
```

#parec[
  First, there is InlinedVector. We will not describe its implementation
  here, but note that it is an extended version of `std::vector` that has
  storage for a handful of vector elements preallocated in its class
  definition. Thus, for short vectors, it can be used without incurring
  the cost of dynamic memory allocation. It is used extensively in the
  #link("../Utilities/Images.html#Image")[Image] class, for example.

][
  首先，有 InlinedVector。我们将不对其实现进行描述，但需要指出的是它是在
  std::vector
  的基础上扩展的一种实现，在类定义中为少量向量元素预先分配了存储空间。因此对于较短的向量，可以在不产生动态内存分配开销的情况下使用。例如，它在
  Image 类中被广泛使用。
]

#parec[
  The value of `N` specifies the number of elements to handle via the
  inline allocation in the class definition.

][
  `N` 的值指定了通过在类定义中内联分配来处理的元素数量。
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
  还额外提供了一个
  HashMap，原因有二：一是标准库中的哈希表在扩容时会使元素指针保持不变，这需要为每个元素进行动态内存分配；二是
  GPU 渲染路径需要一个可以在 GPU 代码中使用的哈希表。
]


```
template <typename Key, typename Value, typename Hash = std::hash<Key>,
          typename Allocator = /* ... */>
class HashMap;
```


```
void Insert(const Key &key, const Value &value);
bool HasKey(const Key &key) const;
const Value &operator[](const Key &key) const;
```

=== 2D Arrays
<b.4.1-2d-arrays>

```
template <typename T> class Array2D {
  public:
        <<Array2D Type Definitions>>       using value_type = T;
       using iterator = value_type *;
       using const_iterator = const value_type *;
       using allocator_type = pstd::pmr::polymorphic_allocator<std::byte>>;
        <<Array2D Public Methods>>       Array2D(allocator_type allocator = {}) : Array2D({{0, 0}, {0, 0}}, allocator) {}
       Array2D(Bounds2i extent, Allocator allocator = {})
           : extent(extent), allocator(allocator) {
           int n = extent.Area();
           values = allocator.allocate_object<T>(n);
           for (int i = 0; i < n; ++i)
               allocator.construct(values + i);
       }
       Array2D(Bounds2i extent, T def, allocator_type allocator = {})
           : Array2D(extent, allocator) {
           std::fill(begin(), end(), def);
       }
       template <typename InputIt,
                 typename = typename std::enable_if_t<
                     !std::is_integral<InputIt>::value &&
                     std::is_base_of<
                         std::input_iterator_tag,
                         typename std::iterator_traits<InputIt>::iterator_category>::value>>
       Array2D(InputIt first, InputIt last, int nx, int ny, allocator_type allocator = {})
           : Array2D({{0, 0}, {nx, ny}}, allocator) {
           std::copy(first, last, begin());
       }
       Array2D(int nx, int ny, allocator_type allocator = {})
           : Array2D({{0, 0}, {nx, ny}}, allocator) {}
       Array2D(int nx, int ny, T def, allocator_type allocator = {})
           : Array2D({{0, 0}, {nx, ny}}, def, allocator) {}
       Array2D(const Array2D &a, allocator_type allocator = {})
           : Array2D(a.begin(), a.end(), a.XSize(), a.YSize(), allocator) {}
       ~Array2D() {
           int n = extent.Area();
           for (int i = 0; i < n; ++i)
               allocator.destroy(values + i);
           allocator.deallocate_object(values, n);
       }
       Array2D(Array2D &&a, allocator_type allocator = {})
           : extent(a.extent), allocator(allocator) {
           if (allocator == a.allocator) {
               values = a.values;
               a.extent = Bounds2i({0, 0}, {0, 0});
               a.values = nullptr;
           } else {
               values = allocator.allocate_object<T>(extent.Area());
               std::copy(a.begin(), a.end(), begin());
           }
       }
       Array2D &operator=(const Array2D &a) = delete;

       Array2D &operator=(Array2D &&other) {
           if (allocator == other.allocator) {
               pstd::swap(extent, other.extent);
               pstd::swap(values, other.values);
           } else if (extent == other.extent) {
               int n = extent.Area();
               for (int i = 0; i < n; ++i) {
                   allocator.destroy(values + i);
                   allocator.construct(values + i, other.values[i]);
               }
               extent = other.extent;
           } else {
               int n = extent.Area();
               for (int i = 0; i < n; ++i)
                   allocator.destroy(values + i);
               allocator.deallocate_object(values, n);

               int no = other.extent.Area();
               values = allocator.allocate_object<T>(no);
               for (int i = 0; i < no; ++i)
                   allocator.construct(values + i, other.values[i]);
           }
           return *this;
       }
       T &operator[](Point2i p) {
           DCHECK(InsideExclusive(p, extent));
           p.x -= extent.pMin.x;
           p.y -= extent.pMin.y;
           return values[p.x + (extent.pMax.x - extent.pMin.x) * p.y];
       }
       PBRT_CPU_GPU
       const T &operator()(int x, int y) const { return (*this)[{x, y}]; }
       PBRT_CPU_GPU
       const T &operator[](Point2i p) const {
           DCHECK(InsideExclusive(p, extent));
           p.x -= extent.pMin.x;
           p.y -= extent.pMin.y;
           return values[p.x + (extent.pMax.x - extent.pMin.x) * p.y];
       }
       int size() const { return extent.Area(); }
       int XSize() const { return extent.pMax.x - extent.pMin.x; }
       int YSize() const { return extent.pMax.y - extent.pMin.y; }
       iterator begin() { return values; }
       iterator end() { return begin() + size(); }
       PBRT_CPU_GPU
       const_iterator begin() const { return values; }
       PBRT_CPU_GPU
       const_iterator end() const { return begin() + size(); }
       PBRT_CPU_GPU
       operator pstd::span<T>() { return pstd::span<T>(values, size()); }
       PBRT_CPU_GPU
       operator pstd::span<const T>() const { return pstd::span<const T>(values, size()); }

       std::string ToString() const {
           std::string s = StringPrintf("[ Array2D extent: %s values: [", extent);
           for (int y = extent.pMin.y; y < extent.pMax.y; ++y) {
               s += " [ ";
               for (int x = extent.pMin.x; x < extent.pMax.x; ++x) {
                   T value = (*this)(x, y);
                   s += StringPrintf("%s, ", value);
               }
               s += "], ";
           }
           s += " ] ]";
           return s;
       }
  private:
        <<Array2D Private Members>>       Bounds2i extent;
       Allocator allocator;
       T *values;
};
```

#parec[
  The array is defined over a 2D region specified by `extent`; its lower
  bounds do not necessarily need to be at (0,0).

][
  该数组在由 extent 指定的二维区域上定义；其下界不一定需要在 (0,0)。
]


```
Bounds2i extent;
Allocator allocator;
T *values;
```

#parec[
  The array can be indexed using a `Point2i`, which should be inside the
  specified extent. After translating the point by the origin of the
  bounds, the usual indexing computation is performed to find the value.
  `Array2D` also provides a `const` version of this method as well as an
  `operator()` that takes a pair of integers.

][
  数组可以使用一个 Point2i 进行索引，该点应位于指定的 extent
  内。将点沿边界原点进行平移后，执行通常的索引计算以查找数值。Array2D
  还提供该方法的常量版本，以及一个接受一对整数的 operator()。
]


```
T &operator[](Point2i p) {
    DCHECK(InsideExclusive(p, extent));
    p.x -= extent.pMin.x;
    p.y -= extent.pMin.y;
    return values[p.x + (extent.pMax.x - extent.pMin.x) * p.y];
}
```

#parec[
  A few methods give the total size and sizes of individual dimensions of
  the array.

][
  一些方法返回数组的总大小以及各个维度的大小。
]


```
int size() const { return extent.Area(); }
int XSize() const { return extent.pMax.x - extent.pMin.x; }
int YSize() const { return extent.pMax.y - extent.pMin.y; }
```

#parec[
  It is also possible to iterate over elements of the array directly.

][
  也可以直接对数组的元素进行遍历。
]


```
iterator begin() { return values; }
iterator end() { return begin() + size(); }
```

#parec[
  #quote(block: true)[
    The rest of the section continues with more detail on the private
    members and additional examples.
  ]

][
  #quote(block: true)[
    本节其余部分将继续详细介绍私有成员以及更多示例。
  ]
]

=== Interned Objects
<b.4.2-interned-objects>

```
template <typename T, typename Hash = std::hash<T>>
class InternCache;
```

#parec[
  If many instances of the same object are stored in memory, especially if
  the objects are large, the interning technique can be helpful. With it,
  a single copy of each unique object is stored and all uses of it refer
  to that copy. (The technique is thus generally only useful for read-only
  data.) `pbrt` uses interning both for transformations found in the scene
  description and for strings in the scene entity objects defined in
  Section C.2.1.

][
  如果很多对象在内存中存储时具有相同的实例，尤其是对象较大时，interning
  技术会很有用。通过它，每个唯一对象只有一个拷贝存储，所有对该对象的使用都引用这份拷贝。（因此该技术通常只有在只读数据上才有用。）pbrt
  将 intern­ing 用于场景描述中的变换以及在第 C.2.1
  节中定义的场景实体对象中的字符串。对于复杂场景，消除冗余拷贝所带来的内存节省通常很大。
]


```
template <typename T, typename Hash = std::hash<T>>
class InternCache;
```

#parec[
  The `InternCache` class manages such caches. It is a template class
  based on the type being managed and its hash function. Types managed by
  it must provide an equality operator so that it can find matches.

][
  `InternCache`
  类用于管理此类缓存。它是一个基于被管理类型及其哈希函数的模板类。被管理的类型必须提供一个等价运算符，以便能够找到匹配项。
]

#parec[
  Beyond the constructor, InternCache provides two variations of a single
  method, Lookup(). Their signatures are below. Both store a single copy
  of provided objects in a hash table, using a mutex to allow concurrent
  access by multiple threads. The first Lookup() method allocates memory
  for the object itself using the allocator passed to the InternCache
  constructor and copies the provided item to initialize the object stored
  in the cache. The second takes a user-provided creation callback
  function with the signature shown below. This allows for more complex
  object initialization—as is used in the LightBase::LookupSpectrum()
  method, for example.

][
  除了构造函数外，InternCache 提供了一个名为 Lookup()
  的方法的两种变体。它们的签名如下。两者都在哈希表中为提供的对象存储单一副本，并使用互斥锁以允许多线程并发访问。第一种
  Lookup() 方法使用在构造 InternCache
  时传入的分配器为对象本身分配内存并拷贝传入的项来初始化缓存中存储的对象。第二种则接受一个用户提供的创建回调函数，其签名如下。这样可以进行更为复杂的对象初始化——例如在
  LightBase::LookupSpectrum() 方法中所使用的方式。
]


```
const T *Lookup(const T &item);

/* F: T *create(Allocator alloc, const T &item) */
template <typename F> const T *Lookup(const T &item, F create);
```

#parec[
  Note that the `Lookup()` methods return a pointer to the shared instance
  of the object. They always return the same pointer for equal objects, so
  a pointer equality test can be used to test for equality with values
  returned by the cache. For large or complex objects, more efficient
  equality tests can be a further benefit of interning.

][
  请注意，Lookup()
  方法返回指向缓存中共享对象的指针。对于相等的对象，它们始终返回相同的指针，因此可以通过指针比较来判断与缓存中返回的值是否相等。对于大型或复杂对象，interning
  还可能带来更高效的相等性测试的额外好处。
]

#parec[
  `InternedString` is a convenience class for strings stored in an
  InternCache. Using it makes it clear that a string pointer refers to an
  interned string, which helps clarify code.

][
  `InternedString` 是存储在 InternCache
  中的字符串的一个便利类。使用它可以清楚地表明字符串指针引用的是内部化字符串，从而有助于代码清晰。
]


```
class InternedString {
public:
    <<InternedString Public Methods>>       InternedString(const std::string *str) : str(str) {}
       operator const std::string &() const { return *str; }
       bool operator==(const char *s) const { return *str == s; }
       bool operator==(const std::string &s) const { return *str == s; }
       bool operator!=(const char *s) const { return *str != s; }
       bool operator!=(const std::string &s) const { return *str != s; }
       bool operator<(const char *s) const { return *str < s; }
       bool operator<(const std::string &s) const { return *str < s; }

       std::string ToString() const { return *str; }
private:
    const std::string *str = nullptr;
};
```

#parec[
  It also provides an automatic conversion operator to std::string, saving
  users from needing to dereference the pointer themselves. Comparison
  operators with strings and \<char\*\> are also available.

][
  它还提供到 std::string
  的自动转换运算符，避免用户自己解引用指针。与字符串和 const char\*
  的比较运算符也可用。
]



```
InternedString(const std::string *str) : str(str) {}
operator const std::string &() const { return *str; }
```

=== Collections of Types
<b.4.3-collections-of-types>

```
template <typename... Ts>
struct TypePack {
    static constexpr size_t count = sizeof...(Ts);
};
```

#parec[
  `IndexOf` provides the index of a given type among the types in a
  TypePack.

][
  `IndexOf` 提供在 TypePack 中某一类型的索引。
]


```
template <typename T, typename... Ts>
struct IndexOf {
    static constexpr int count = 0;
    static_assert(!std::is_same_v<T, T>, "Type not present in TypePack");
};
```

#parec[
  A first template specialization handles the case where the first type in
  the TypePack matches the given type T. In this case, the index is zero.

][
  第一种模板特化处理 TypePack 的第一个类型与给定类型 T
  相同的情况。此时索引为零。
]


```
template <typename T, typename... Ts>
struct IndexOf<T, TypePack<T, Ts...>> {
    static constexpr int count = 0;
};
```

#parec[
  Another specialization handles the case where T is not the first type.
  One is added to the final count, and a recursive template instantiation
  checks the next type.

][
  另一种模板特化处理 T 不是第一个类型的情况。对最终计数加
  1，并递归检查下一个类型。
]


```
template <typename T, typename U, typename... Ts>
struct IndexOf<T, TypePack<U, Ts...>> {
    static constexpr int count = 1 + IndexOf<T, TypePack<Ts...>>::count;
};
```

#parec[
  We will find it useful to be able to wrap a template class around each
  of a set of types. This operation is provided by MapType. The base case
  is a single-element type pack.

][
  我们将发现将模板类包装在一组类型之上很有用。这一操作由 MapType
  提供。基准情形是一个单元素类型包。
]


```
template <template <typename> class M, typename T>
struct MapType<M, TypePack<T>> {
    using type = TypePack<M<T>>;
};
```

#parec[
  Larger numbers of types are handled recursively. Prepend gives the
  TypePack that results from prepending a given type to a TypePack of
  others.

][
  更多类型的处理通过递归进行。Prepend 给出将给定类型添加到 TypePack
  的结果。
]


```
template <template <typename> class M, typename T, typename... Ts>
struct MapType<M, TypePack<T, Ts...>> {
    using type = typename Prepend<M<T>, typename MapType<M, TypePack<Ts...>>::type>::type;
};
```

#parec[
  Finally, we will define a ForEachType() function, which calls the
  provided function once for each of the types in a TypePack. The general
  case peels off the first type, calls the provided function, and then
  proceeds with a recursive call with the remainder of types in the
  TypePack.

][
  最后，我们将定义一个 ForEachType() 函数，它对 TypePack
  中的每一个类型调用所提供的函数。一般情况是先处理第一个类型，然后对剩余类型递归调用。
]


```
template <typename F, typename T, typename... Ts>
void ForEachType(F func, TypePack<T, Ts...>) {
    func.template operator()<T>();
    ForEachType(func, TypePack<Ts...>());
}
```

#parec[
  The base case of an empty TypePack ends the recursion.

][
  TypePack 为空时结束递归。
]


```
template <typename F>
void ForEachType(F func, TypePack<>) {}
```

=== Tagged Pointers
<b.4.4-tagged-pointers>

```
template <typename... Ts>
class TaggedPointer {
  public:
    <<TaggedPointer Public Types>>       using Types = TypePack<Ts...>>;
    <<TaggedPointer Public Methods>>       template <typename T>
       TaggedPointer(T *ptr) {
           uintptr_t iptr = reinterpret_cast<uintptr_t>(ptr);
           constexpr unsigned int type = TypeIndex<T>();
           bits = iptr | ((uintptr_t)type << tagShift);
       }
       PBRT_CPU_GPU
       TaggedPointer(std::nullptr_t np) {}

       PBRT_CPU_GPU
       TaggedPointer(const TaggedPointer &t) { bits = t.bits; }
       PBRT_CPU_GPU
       TaggedPointer &operator=(const TaggedPointer &t) {
           bits = t.bits;
           return *this;
       }
       template <typename T>
       static constexpr unsigned int TypeIndex() {
           using Tp = typename std::remove_cv_t<T>;
           if constexpr (std::is_same_v<Tp, std::nullptr_t>) return 0;
           else return 1 + pbrt::IndexOf<Tp, Types>::count;
       }
       unsigned int Tag() const { return ((bits & tagMask) >> tagShift); }
       template <typename T>
       bool Is() const { return Tag() == TypeIndex<T>(); }
       static constexpr unsigned int MaxTag() { return sizeof...(Ts); }
       PBRT_CPU_GPU
       explicit operator bool() const { return (bits & ptrMask) != 0; }

       PBRT_CPU_GPU
       bool operator<(const TaggedPointer &tp) const { return bits < tp.bits; }
       template <typename T>
       T *Cast() {
           return reinterpret_cast<T *>(ptr());
       }
       template <typename T>
       const T *Cast() const {
           return reinterpret_cast<const T *>(ptr());
       }
       template <typename T>
       T *CastOrNullptr() {
           if (Is<T>()) return reinterpret_cast<T *>(ptr());
           else return nullptr;
       }
       template <typename T>
       PBRT_CPU_GPU const T *CastOrNullptr() const {
           if (Is<T>())
               return reinterpret_cast<const T *>(ptr());
           else
               return nullptr;
       }
       std::string ToString() const {
           return StringPrintf("[ TaggedPointer ptr: 0x%p tag: %d ]", ptr(), Tag());
       }

       PBRT_CPU_GPU
       bool operator==(const TaggedPointer &tp) const { return bits == tp.bits; }
       PBRT_CPU_GPU
       bool operator!=(const TaggedPointer &tp) const { return bits != tp.bits; }
       void *ptr() { return reinterpret_cast<void *>(bits & ptrMask); }
       const void *ptr() const { return reinterpret_cast<const void *>(bits & ptrMask); }
       template <typename F>
       PBRT_CPU_GPU decltype(auto) Dispatch(F &&func) {
           using R = typename detail::ReturnType<F, Ts...>::type;
           return detail::Dispatch<F, R, Ts...>(func, ptr(), Tag() - 1);
       }
       template <typename F>
       PBRT_CPU_GPU decltype(auto) Dispatch(F &&func) const {
           DCHECK(ptr());
           using R = typename detail::ReturnType<F, Ts...>::type;
           return detail::Dispatch<F, R, Ts...>(func, ptr(), Tag() - 1);
       }

       template <typename F>
       decltype(auto) DispatchCPU(F &&func) {
           DCHECK(ptr());
           using R = typename detail::ReturnType<F, Ts...>::type;
           return detail::DispatchCPU<F, R, Ts...>(func, ptr(), Tag() - 1);
       }

       template <typename F>
       decltype(auto) DispatchCPU(F &&func) const {
           DCHECK(ptr());
           using R = typename detail::ReturnTypeConst<F, Ts...>::type;
           return detail::DispatchCPU<F, R, Ts...>(func, ptr(), Tag() - 1);
       }
  private:
    <<TaggedPointer Private Members>>       static constexpr int tagShift = 57;
       static constexpr int tagBits = 64 - tagShift;
       static constexpr uint64_t tagMask = ((1ull << tagBits) - 1) << tagShift;
       static constexpr uint64_t ptrMask = ~tagMask;
       uintptr_t bits = 0;
};
```

#parec[
  All possible types for a tagged pointer are provided via a public type
  definition.

][
  所有的可能类型通过一个公开的类型定义提供。
]

```
static constexpr int tagShift = 57;
static constexpr int tagBits = 64 - tagShift;
```

#parec[
  `tagMask` is a bitmask that extracts the type tag’s bits, and `ptrMask`
  extracts the original pointer.

][
  `tagMask` 是一个位掩码，用于提取类型标签的位，`ptrMask`
  用于提取原始指针。
]

#parec[
  We can now implement the primary `TaggedPointer` constructor. Given a
  pointer of known type `T`, it uses the `TypeIndex()` method to get an
  integer index for its type. In turn, the `bits` member is set by
  combining the original pointer with the integer type, shifted up into
  the unused bits of the pointer value.

][
  现在我们可以实现主要的 TaggedPointer 构造函数。给定一个已知类型 T
  的指针，它使用 TypeIndex() 方法获得该类型的整数索引。反过来，bits
  成员通过将原始指针与向上平移到未使用指针位的整数类型来设置。
]


```
template <typename T>
TaggedPointer(T *ptr) {
    uintptr_t iptr = reinterpret_cast<uintptr_t>(ptr);
    constexpr unsigned int type = TypeIndex<T>();
    bits = iptr | ((uintptr_t)type << tagShift);
}
```

```
uintptr_t bits = 0;
```

#parec[
  Most of the work for the `TypeIndex()` method is done by the `IndexOf`
  structure defined in the previous section. One more index is needed to
  represent a null pointer, however, so an index of 0 is used for it and
  the rest have one added to them.

][
  大多数 TypeIndex() 方法的工作由前一节中定义的 IndexOf
  结构完成。然而表示空指针还需要再增加一个索引，因此将其设为
  0，其余的都在此基础上再加 1。
]


```
template <typename T>
static constexpr unsigned int TypeIndex() {
    using Tp = typename std::remove_cv_t<T>;
    if constexpr (std::is_same_v<Tp, std::nullptr_t>) return 0;
    else return 1 + pbrt::IndexOf<Tp, Types>::count;
}
```

#parec[
  `Tag()` returns a `TaggedPointer`’s tag by extracting the relevant bits.

][
  `Tag()` 通过提取相关位来返回一个 TaggedPointer 的标签。
]

#parec[
  In turn, the `Is()` method performs a runtime check of whether a
  `TaggedPointer` represents a particular type.

][
  反过来，`Is()` 方法在运行时检查一个 TaggedPointer 是否表示某一特定类型。
]


```
unsigned int Tag() const { return ((bits & tagMask) >> tagShift); }
template <typename T>
bool Is() const { return Tag() == TypeIndex<T>(); }
```

#parec[
  The maximum value of a tag is equal to the number of represented types.

][
  标签的最大值等于所表示类型的数量。
]


```
static constexpr unsigned int MaxTag() { return sizeof...(Ts); }
```

#parec[
  A pointer of a specified type is returned by `CastOrNullptr()`. As the
  name suggests, it returns `nullptr` if the `TaggedPointer` does not in
  fact hold an object of type `T`. In addition to this method,
  `TaggedPointer` also provides a `const` variant that returns a
  `const T *` as well as unsafe `Cast()` methods that always return a
  pointer of the given type. Those should only be used when there is no
  question about the underlying type held by a `TaggedPointer`.

][
  通过 CastOrNullptr() 可以返回指定类型的指针。顾名思义，如果
  TaggedPointer 其实并不持有该类型的对象，它将返回
  nullptr。除了这个方法，TaggedPointer 还提供返回 const T \*
  的常量版本，以及始终返回给定类型指针的危险的 Cast()
  方法。仅当确定底层类型时才应使用这些方法。
]


```
template <typename T>
T *CastOrNullptr() {
    if (Is<T>()) return reinterpret_cast<T *>(ptr());
    else return nullptr;
}
```

#parec[
  For cases where the original pointer is needed but `void` pointer will
  suffice, the `ptr()` method is available. It has a `const` variant as
  well.

][
  对于需要保留原始指针但 void 指针即可的情况，提供了 `ptr()`
  方法。它也有一个常量版本。
]


```
void *ptr() { return reinterpret_cast<void *>(bits & ptrMask); }
```

#parec[
  The most interesting `TaggedPointer` method is `Dispatch()`, which is at
  the heart of pbrt’s dynamic dispatch mechanism for polymorphic types.
  Its task is to determine which type of object a `TaggedPointer` points
  to and then call the provided function, passing it the object’s pointer,
  cast to the correct type. (See the Spectrum example in the
  documentation.)

][
  最有趣的 TaggedPointer 方法是 `Dispatch()`，它是 pbrt
  针对多态类型动态派发机制的核心。其任务是确定 TaggedPointer
  指向的是哪种对象，然后调用所提供的函数，将对象的指针按正确的类型转换后传入。
]


```
template <typename F>
PBRT_CPU_GPU decltype(auto) Dispatch(F &&func) {
    using R = typename detail::ReturnType<F, Ts...>::type;
    return detail::Dispatch<F, R, Ts...>(func, ptr(), Tag() - 1);
}
```

#parec[
  There are implementations of `detail::Dispatch()` for up to 8 types. If
  more are provided, a fallback implementation handles the first 8 and
  then makes a recursive call to `detail::Dispatch()` with the rest of
  them for larger indices. For pbrt’s uses, where there are at most 10 or
  so types, this approach works well.

][
  有实现的 `detail::Dispatch()` 针对最多 8 种类型。如果提供的类型超过 8
  种，将采用回退实现来处理前 8
  种类型，然后对剩余类型进行递归调用以处理更大的索引。对于 pbrt
  的用途，类型最多只有十种左右，这种方法效果很好。
]

#parec[
  TaggedPointer also includes a const-qualified dispatch method as well as
  `DispatchCPU()`, which is necessary for methods that are only able to
  run on the CPU. (The default `Dispatch()` method requires that the
  method be callable from both CPU or GPU code, which is the most common
  use case in pbrt.) These both have corresponding dispatch functions in
  the `detail` namespace.

][
  TaggedPointer 还包括一个常量限定的分派方法，以及
  DispatchCPU()，这是对那些只能在 CPU 上运行的方法所必需的。（默认的
  Dispatch() 方法要求该方法既可在 CPU 也可在 GPU 代码中调用，这是 pbrt
  中最常见的使用场景。）这两者在 detail 命名空间中也有相应的分派函数。
]


```
template <typename F, typename R, typename T0, typename T1, typename T2>
R Dispatch(F &&func, void *ptr, int index) {
    switch (index) {
      case 0:  return func((T0 *)ptr);
      case 1:  return func((T1 *)ptr);
      default: return func((T2 *)ptr);
    }
}
```

#parec[
  There are implementations of `detail::Dispatch()` for up to 8 types. If
  more are provided, a fallback implementation handles the first 8 and
  then makes a recursive call to `detail::Dispatch()` with the rest of
  them for larger indices. For pbrt’s uses, where there are at most 10 or
  so types, this approach works well.

][
  有实现的 `detail::Dispatch()` 针对最多 8 种类型。如果提供的类型超过 8
  种，将采用回退实现来处理前 8
  种类型，然后对剩余类型进行递归调用以处理更大的索引。对于 pbrt
  的用途，类型最多只有十种左右，这种方法效果很好。
]

#parec[
  TaggedPointer also includes a const-qualified dispatch method as well as
  `DispatchCPU()`, which is necessary for methods that are only able to
  run on the CPU. (The default `Dispatch()` method requires that the
  method be callable from both CPU or GPU code, which is the most common
  use case in pbrt.) These both have corresponding dispatch functions in
  the `detail` namespace.

][
  TaggedPointer 还包括一个常量限定的分派方法，以及
  DispatchCPU()，这是对那些只能在 CPU 上运行的方法所必需的。（默认的
  Dispatch() 方法要求该方法既可在 CPU 也可在 GPU 代码中调用，这是 pbrt
  中最常见的使用场景。）这两者在 detail 命名空间中也有相应的分派函数。
]

=== 3D Sampled Data
<b.4.5-3d-sampled-data>



```
template <typename T>
class SampledGrid {
  public:
        <<SampledGrid Public Methods>>       SampledGrid(Allocator alloc) : values(alloc) {}
       SampledGrid(pstd::span<const T> v, int nx, int ny, int nz, Allocator alloc)
           : values(v.begin(), v.end(), alloc), nx(nx), ny(ny), nz(nz) {
       }
       int XSize() const { return nx; }
       int YSize() const { return ny; }
       int zSize() const { return nz; }
       const_iterator begin() const { return values.begin(); }
       const_iterator end() const { return values.end(); }
       template <typename F>
       auto Lookup(Point3f p, F convert) const {
           Point3f pSamples(p.x * nx - .5f, p.y * ny - .5f, p.z * nz - .5f);
              Point3i pi = (Point3i)Floor(pSamples);
              Vector3f d = pSamples - (Point3f)pi;
           auto d00 = Lerp(d.x, Lookup(pi, convert),
                                   Lookup(pi + Vector3i(1, 0, 0), convert));
              auto d10 = Lerp(d.x, Lookup(pi + Vector3i(0, 1, 0), convert),
                                   Lookup(pi + Vector3i(1, 1, 0), convert));
              auto d01 = Lerp(d.x, Lookup(pi + Vector3i(0, 0, 1), convert),
                                   Lookup(pi + Vector3i(1, 0, 1), convert));
              auto d11 = Lerp(d.x, Lookup(pi + Vector3i(0, 1, 1), convert),
                                   Lookup(pi + Vector3i(1, 1, 1), convert));
              return Lerp(d.z, Lerp(d.y, d00, d10), Lerp(d.y, d01, d11));
       }
       T Lookup(Point3f p) const {
           // Compute voxel coordinates and offsets for _p_
           Point3f pSamples(p.x * nx - .5f, p.y * ny - .5f, p.z * nz - .5f);
           Point3i pi = (Point3i)Floor(pSamples);
           Vector3f d = pSamples - (Point3f)pi;

           // Return trilinearly interpolated voxel values
           auto d00 =
               Lerp(d.x, Lookup(pi), Lookup(pi + Vector3i(1, 0, 0)));
           auto d10 = Lerp(d.x, Lookup(pi + Vector3i(0, 1, 0)),
                           Lookup(pi + Vector3i(1, 1, 0)));
           auto d01 = Lerp(d.x, Lookup(pi + Vector3i(0, 0, 1)),
                           Lookup(pi + Vector3i(1, 0, 1)));
           auto d11 = Lerp(d.x, Lookup(pi + Vector3i(0, 1, 1)),
                           Lookup(pi + Vector3i(1, 1, 1)));
           return Lerp(d.z, Lerp(d.y, d00, d10), Lerp(d.y, d01, d11));
       }
       template <typename F>
       auto Lookup(const Point3i &p, F convert) const {
           Bounds3i sampleBounds(Point3i(0, 0, 0), Point3i(nx, ny, nz));
           if (!InsideExclusive(p, sampleBounds))
               return convert(T{});
           return convert(values[(p.z * ny + p.y) * nx + p.x]);
       }
       T Lookup(const Point3i &p) const {
           Bounds3i sampleBounds(Point3i(0, 0, 0), Point3i(nx, ny, nz));
           if (!InsideExclusive(p, sampleBounds))
               return T{};
           return values[(p.z * ny + p.y) * nx + p.x];
       }
       template <typename F>
       Float MaxValue(const Bounds3f &bounds, F convert) const {
           Point3f ps[2] = {Point3f(bounds.pMin.x * nx - .5f, bounds.pMin.y * ny - .5f,
                                    bounds.pMin.z * nz - .5f),
                            Point3f(bounds.pMax.x * nx - .5f, bounds.pMax.y * ny - .5f,
                                    bounds.pMax.z * nz - .5f)};
           Point3i pi[2] = {Max(Point3i(Floor(ps[0])), Point3i(0, 0, 0)),
                            Min(Point3i(Floor(ps[1])) + Vector3i(1, 1, 1),
                                Point3i(nx - 1, ny - 1, nz - 1))};

           Float maxValue = Lookup(Point3i(pi[0]), convert);
           for (int z = pi[0].z; z <= pi[1].z; ++z)
               for (int y = pi[0].y; y <= pi[1].y; ++y)
                   for (int x = pi[0].x; x <= pi[1].x; ++x)
                       maxValue = std::max(maxValue, Lookup(Point3i(x, y, z), convert));

           return maxValue;
       }
       T MaxValue(const Bounds3f &bounds) const {
           return MaxValue(bounds, [](T value) { return value; });
       }
       std::string ToString() const {
           return StringPrintf("[ SampledGrid nx: %d ny: %d nz: %d values: %s ]", nx, ny, nz,
                               values);
       }
  private:
        <<SampledGrid Private Members>>       pstd::vector<T> values;
       int nx, ny, nz;
};
```

#parec[
  For the convenience of cases where the in-memory type T is the one that
  should be returned, a second implementation of `Lookup()`, not included
  here, provides a default identity implementation of the conversion
  function.

][
  为了方便在内存中的类型 T 就是应返回的类型的情况，另一个 Lookup()
  的实现（未在此处包含）提供了转换函数的默认恒等实现。
]

#parec[
  SampledGrid follows the same conventions as were used for discrete and
  continuous coordinates for pixel indexing, defined in Section 8.1.4.
  Here the discrete coordinates for the lower corner of the 8 samples are
  computed.

][
  SampledGrid 遵循像素索引中离散和连续坐标的相同约定，这些在 8.1.4
  节中定义。在这里，8 个样本的左下角的离散坐标将被计算。
]

```
// todo
```

#parec[
  The final paragraph explains the use and behavior of these lookups and
  comments on performance and container choices.

][
  最后一段解释了这些查找的使用与行为，以及对性能和容器选择的评论。
]

=== Efficient Temporary Memory Allocations
<b.4.6-efficient-temporary-memory-allocations>


#parec[
  ScratchBuffer implements arena-based allocation for small, short-lived
  objects. It is used for dynamic allocation of BxDFs, BSSRDFs, and
  RayMajorantIterators as rays are traced through the scene. It is
  designed to be thread-local.

][
  ScratchBuffer 实现了基于 arena
  的分配，适用于生命周期短、对象规模小的情况。它用于在场景中射线跟踪时对
  BxDF、BSSRDF 以及 RayMajorantIterators
  的动态分配。它设计为线程本地（thread-local）。
]


```
class alignas(PBRT_L1_CACHE_LINE_SIZE) ScratchBuffer {
  public:
    <<ScratchBuffer Public Methods>>       ScratchBuffer(int size = 256) : allocSize(size) {
           ptr = (char *)Allocator().allocate_bytes(size, align);
       }
       ScratchBuffer(const ScratchBuffer &) = delete;

       ScratchBuffer(ScratchBuffer &&b) {
           ptr = b.ptr;
           allocSize = b.allocSize;
           offset = b.offset;
           smallBuffers = std::move(b.smallBuffers);

           b.ptr = nullptr;
           b.allocSize = b.offset = 0;
       }

       ~ScratchBuffer() {
           Reset();
           Allocator().deallocate_bytes(ptr, allocSize, align);
       }

       ScratchBuffer &operator=(const ScratchBuffer &) = delete;

       ScratchBuffer &operator=(ScratchBuffer &&b) {
           std::swap(b.ptr, ptr);
           std::swap(b.allocSize, allocSize);
           std::swap(b.offset, offset);
           std::swap(b.smallBuffers, smallBuffers);
           return *this;
       }
       void *Alloc(size_t size, size_t align) {
           if ((offset % align) != 0)
               offset += align - (offset % align);
           if (offset + size > allocSize)
               Realloc(size);
           void *p = ptr + offset;
           offset += size;
           return p;
       }
       template <typename T, typename... Args>
       typename AllocationTraits<T>::SingleObject Alloc(Args &&... args) {
           T *p = (T *)Alloc(sizeof(T), alignof(T));
           return new (p) T(std::forward<Args>(args)...);
       }

       template <typename T>
       typename AllocationTraits<T>::Array Alloc(size_t n = 1) {
           using ElementType = typename std::remove_extent_t<T>;
           ElementType *ret =
               (ElementType *)Alloc(n * sizeof(ElementType), alignof(ElementType));
           for (size_t i = 0; i < n; ++i)
               new (&ret[i]) ElementType();
           return ret;
       }
       void Reset() {
           for (const auto &buf : smallBuffers)
               Allocator().deallocate_bytes(buf.first, buf.second, align);
           smallBuffers.clear();
           offset = 0;
       }
  private:
        <<ScratchBuffer Private Methods>>       void Realloc(size_t minSize) {
           smallBuffers.push_back(std::make_pair(ptr, allocSize));
           allocSize = std::max(2 * minSize, allocSize + minSize);
           ptr = (char *)Allocator().allocate_bytes(allocSize, align);
           offset = 0;
       }
        <<ScratchBuffer Private Members>>       static constexpr int align = PBRT_L1_CACHE_LINE_SIZE;
       char *ptr = nullptr;
       int allocSize = 0, offset = 0;
       std::list<std::pair<char *, size_t>> smallBuffers;
};
```

#parec[
  The `ScratchBuffer` hands out pointers to memory from a single
  preallocated block. If the block’s size is insufficient, it will be
  replaced with a larger one; this allows a small default block size,
  though the caller can specify a larger one if the default is known to be
  too little.

][
  ScratchBuffer
  将内存分配回收交给一个预分配块来处理。如果该块大小不足，它会被替换为一个更大的块；这使默认块大小可以较小，但调用方若事先知道默认值太小，也可以指定一个更大的块。
]



```
ScratchBuffer(int size = 256) : allocSize(size) {
    ptr = (char *)Allocator().allocate_bytes(size, align);
}
```

#parec[
  `offset` maintains the offset after `ptr` where free memory begins.

][
  `offset` 维护从 `ptr` 开始的空闲内存的偏移量。
]


```
static constexpr int align = PBRT_L1_CACHE_LINE_SIZE;
char *ptr = nullptr;
int allocSize = 0, offset = 0;
```

#parec[
  To service an allocation request, the allocation routine first advances
  `offset` as necessary so that the returned address meets the specified
  memory alignment. (It is thus required that `ptr` has at minimum that
  alignment.) If the allocation would go past the end of the allocated
  buffer, `Realloc()` takes care of allocating a new, larger buffer. With
  the usual case of long-lived ScratchBuffers, this should happen rarely.
  Given sufficient space, the pointer can be returned and `offset`
  incremented to account for the allocation.

][
  为了服务一次分配请求，分配例程首先按需要推进 `offset`
  以确保返回地址符合指定的内存对齐方式。（因此要求 `ptr`
  至少具有该对齐方式。）如果分配会超过已分配缓冲区的末端，`Realloc()`
  会处理分配一个新的、容量更大的缓冲区。在通常的长生命周期 ScratchBuffer
  的情况下，这种情况应很少发生。给定足够的空间后，可以返回指针并让
  `offset` 增加以记账。
]


```
void *Alloc(size_t size, size_t align) {
    if ((offset % align) != 0)
        offset += align - (offset % align);
    if (offset + size > allocSize)
        Realloc(size);
    void *p = ptr + offset;
    offset += size;
    return p;
}
```

#parec[
  ScratchBuffer provides two additional `Alloc()` methods that are not
  included here. Both are templated on the type of object being allocated.
  One allocates a single object, passing along provided parameters to its
  constructor. The other allocates an array of objects of a specified
  length, running the default constructor for each one.

][
  ScratchBuffer 还提供了另外两个未在此处包含的 `Alloc()`
  方法。两者都以要分配对象的类型为模板参数。一个分配单个对象，将提供的参数传给其构造函数。另一个分配指定长度的对象数组，对每个对象执行默认构造函数。
]

#parec[
  If a larger buffer is needed, `Realloc()` holds on to a pointer to the
  current buffer and its size in `smallBuffers`. The current buffer cannot
  be freed until the user later calls ScratchBuffer’s `Reset()` method,
  but it should be returned to the system then, as ScratchBuffer will
  henceforth have no need for it.

][
  如果需要更大的缓冲区，`Realloc()` 会将当前缓冲区及其大小保存在
  `smallBuffers` 中。当前缓冲区不能被释放，直到后续调用 ScratchBuffer 的
  `Reset()` 方法，但此后应将其返回给系统，因为 ScratchBuffer
  将不再需要它。
]

```
void Realloc(size_t minSize) {
    smallBuffers.push_back(std::make_pair(ptr, allocSize));
    allocSize = std::max(2 * minSize, allocSize + minSize);
    ptr = (char *)Allocator().allocate_bytes(allocSize, align);
    offset = 0;
}
```



```
std::list<std::pair<char *, size_t>> smallBuffers;
```

#parec[
  A call to `Reset()` is lightweight, usually just resetting `offset` to
  0. Note that, lacking the necessary information to be able to do so, it
  does not run the destructors of the allocated objects.

][
  对 `Reset()` 的调用成本较低，通常只是将 `offset` 重置为
  0。请注意，在缺少必要信息以执行清理时，它不会执行分配对象的析构函数。
]



```
void Reset() {
    for (const auto &buf : smallBuffers)
        Allocator().deallocate_bytes(buf.first, buf.second, align);
    smallBuffers.clear();
    offset = 0;
}
```


