#import "../template.typ": parec, ez_caption, source-cite

== #ez_caption[Triangle Meshes][三角网格]
<triangle-meshes>


#parec[
  The triangle is one of the most commonly used shapes in computer graphics; complex scenes may be modeled using millions of triangles to achieve great detail. (@fig:trimesh-ganesha shows an image of a complex triangle mesh of over four million triangles.)
][
  三角形是计算机图形学中最常用的形状之一；复杂的场景可以使用数百万个三角形来建模，以实现极高的细节。（@fig:trimesh-ganesha 显示了一个由超过四百万个三角形组成的复杂三角网格的图像。）
]


#figure(
  image("../pbr-book-website/4ed/Shapes/ganesha.png"),
  caption: [
    #ez_caption[
      *Ganesha Model. *This triangle mesh contains over four million individual triangles. It was created from a real statue using a 3D scanner that uses structured light to determine shapes of objects.
    ][
      *Ganesha 模型。*该三角形网格包含超过四百万个独立的三角形。它是通过 3D 扫描仪从真实雕像创建的，该扫描仪使用结构光来确定物体的形状。
    ]
  ],
)<trimesh-ganesha>

#parec[
  While a natural representation would be to have a `Triangle` shape implementation where each triangle stored the positions of its three vertices, a more memory-efficient representation is to separately store entire triangle meshes with an array of vertex positions where each individual triangle just stores three offsets into this array for its three vertices. To see why this is the case, consider the celebrated Euler-Poincaré formula, which relates the number of vertices $V$, edges $E$, and faces $F$ on closed discrete meshes as
][
  虽然一种自然的表示方法是实现一个`Triangle`形状，其中每个三角形存储其三个顶点的位置，但一种更节省内存的表示方法是将整个三角网格的顶点位置存储在一个数组中，每个单独的三角形只存储其三个顶点在该数组中的三个偏移量。 要理解为什么这是可行的，可以考虑著名的欧拉-庞加莱公式，它将闭合离散网格上的顶点数 $V$、边数 $E$ 和面数 $F$联系起来：
]

$ V - E + F = 2(1 - g), $


#parec[
  where $g in NN$ is the _genus_ of the mesh.
][
  其中 $g in NN$ 是网格的_亏格_。
]

#parec[
  The genus is usually a small number and can be interpreted as the number of "handles" in the mesh (analogous to a handle of a teacup). On a triangle mesh, the number of edges and vertices is furthermore related by the identity
][
  亏格通常是一个比较小的数值，可以解释为网格中的“把手”数量（类似于茶杯的把手）。在三角网格中，边数和面数还通过以下恒等式相关联：
]

$ E = 3 / 2 F $


#parec[
  This can be seen by dividing each edge into two parts associated with the two adjacent triangles. There are $3 F$ such half-edges, and all colocated pairs constitute the $E$ mesh edges. For large closed triangle meshes, the overall effect of the genus usually becomes negligible and we can combine the previous two equations (with $g = 0$ ) to obtain
][
  这可以通过将每条边分成与两个相邻三角形相关的两部分来看到。有$3 F$ 个这样的半边，所有共置的对构成 $E$ 条网格边。 对于大型闭合三角网格，亏格的总体影响通常变得可以忽略不计，我们可以结合前两个方程（取 $g=0$ ）得到
]

$ F approx 2V $

#parec[
  In other words, there are approximately twice as many faces as vertices. Since each face references three vertices, every vertex is (on average) referenced a total of six times. Thus, when vertices are shared, the total amortized storage required per triangle will be 12 bytes of memory for the offsets (at 4 bytes for three 32-bit integer offsets) plus half of the storage for one vertex—6 bytes, assuming three 4-byte floats are used to store the vertex position—for a total of 18 bytes per triangle. This is much better than the 36 bytes per triangle that storing the three positions directly would require. The relative storage savings are even better when there are per-vertex surface normals or texture coordinates in a mesh.
][
  换句话说，面的数量大约是顶点数量的两倍。由于每个面引用三个顶点，每个顶点（平均）被引用六次。 因此，当顶点被共享时，每个三角形所需的总摊销存储为12字节的索引（每个32位整数为4字节，共三个索引）加上一个顶点存储的一半——6字节，假设使用三个4字节的浮点数来存储顶点位置。总共为每个三角形18字节。 这比直接存储三个位置所需的每个三角形36字节要好得多。当网格中有关联到顶点的表面法向量或纹理坐标时，相对存储节省甚至更好。
]


=== #ez_caption[Mesh Representation and Storage][网格的表示与存储]
<mesh-representation-and-storage>
#parec[
  `pbrt` uses the #link(<TriangleMesh>)[`TriangleMesh`] class to store the shared information about a triangle mesh. It is defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.h")[`util/mesh.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.cpp")[`util/mesh.cpp`].
][
  `pbrt` 使用 #link(<TriangleMesh>)[`TriangleMesh`] 类来存储三角网格的共享信息。它在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.h")[`util/mesh.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.cpp")[`util/mesh.cpp`] 中定义。
]

#block(sticky: true)[#raw("<<TriangleMesh Definition>>=")] <fragment-TriangleMeshDefinition-0>
```cpp
class TriangleMesh {
  public:
    <<TriangleMesh Public Methods>>
    <<TriangleMesh Public Members>>
};
``` <TriangleMesh>

#parec[
  In addition to the mesh vertex positions and vertex indices, per-vertex normals `n`, tangent vectors `s`, and texture coordinates `uv` may be provided. The corresponding vectors should be empty if there are no such values or should be the same size as `p` otherwise.
][
  除了网格顶点位置和顶点索引外，还可以提供每个顶点的法向量 `n`、切线向量 `s` 和纹理坐标 `uv`。如果没有这些值，相应的向量应为空；否则，各个数组大小应与 `p` 相同。
]

#block(sticky: true)[#raw("<<TriangleMesh Method Definitions>>=")] <fragment-TriangleMeshMethodDefinitions-0>
```cpp
TriangleMesh::TriangleMesh(
        const Transform &renderFromObject, bool reverseOrientation,
        std::vector<int> indices, std::vector<Point3f> p,
        std::vector<Vector3f> s, std::vector<Normal3f> n,
        std::vector<Point2f> uv, std::vector<int> faceIndices, Allocator alloc)
    : nTriangles(indices.size() / 3), nVertices(p.size()) {
    <<Initialize mesh vertexIndices>>
    <<Transform mesh vertices to rendering space and initialize mesh p>>
    <<Remainder of TriangleMesh constructor>>
}
```

#parec[
  The mesh data is made available via public member variables; as with things like coordinates of points or rays' directions, there would be little benefit and some bother from information hiding in this case.
][
  网格数据通过公共成员变量提供；就像点的坐标或射线的方向一样，在这种情况下，隐藏这些信息几乎没有好处，反而会带来一些麻烦。
]

#block(sticky: true)[#raw("<<TriangleMesh Public Members>>=")] <fragment-TriangleMeshPublicMembers-0>
```cpp
int nTriangles, nVertices;
const int *vertexIndices = nullptr;
const Point3f *p = nullptr;
```


#parec[
  Although its constructor takes `std::vector` parameters, `TriangleMesh` stores plain pointers to its data arrays. The `vertexIndices` pointer points to `3 * nTriangles` values, and the per-vertex pointers, if not `nullptr`, point to `nVertices` values.
][
  尽管其构造函数接受 `std::vector` 参数，`TriangleMesh` 仍然将其数据数组存储为普通指针。`vertexIndices` 指针指向 `3 * nTriangles` 个值，而各逐顶点数据数组的指针（如果不是 `nullptr`）指向 `nVertices` 个值。
]

#parec[
  We chose this design so that different `TriangleMesh`es could potentially point to the same arrays in memory in the case that they were both given the same values for some or all of their parameters. Although `pbrt` offers capabilities for object instancing, where multiple copies of the same geometry can be placed in the scene with different transformation matrices (e.g., via the #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive] that is described in @object-instancing-and-primitives-in-Motion), the scenes provided to it do not always make full use of this capability. For example, with the landscape scene in @fig:ecosys-dof and #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fig:ecosys-instancing")[7.2], over 400 MB is saved from detecting such redundant arrays.
][
  我们选择这种设计是为了使不同的 `TriangleMesh` 能够在某些或所有参数都相同的情况下，可能指向内存中的相同数组。尽管 `pbrt` 提供了对象实例化的功能，可以在场景中使用不同的变换矩阵放置同一几何体的多个副本（例如，通过 #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive]，在@object-instancing-and-primitives-in-Motion 中描述），但提供给它的场景并不总是充分利用这一功能。 例如，在@fig:ecosys-dof 和 #link("https://pbr-book.org/4ed/Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fig:ecosys-instancing")[7.2] 的景观场景中，通过检测此类冗余数组节省了超过 400 MB。
]

#parec[
  The #link(<BufferCache>)[BufferCache] class handles the details of storing a single unique copy of each buffer provided to it. Its `LookupOrAdd()` method, to be defined shortly, takes a `std::vector` of the type it manages and returns a pointer to memory that stores the same values.
][
  #link(<BufferCache>)[BufferCache] 类用来存储每个Buffer数据的唯一副本。它的 `LookupOrAdd()` 方法（稍后定义）的输入是它管理的类型的 `std::vector`，并返回一个指向存储相同值的内存的指针。
]

#block(sticky: true)[#raw("<<Initialize mesh vertexIndices>>=")] <fragment-InitializemeshmonovertexIndices-0>
```cpp
vertexIndices = intBufferCache->LookupOrAdd(indices, alloc);
```

#parec[
  The `BufferCache`s are made available through global variables in the `pbrt` namespace. Additional ones, not included here, handle normals, tangent vectors, and texture coordinates.
][
  `BufferCache` 通过 `pbrt` 命名空间中的全局变量提供。这里未包含的其他变量处理法向量、切线向量和纹理坐标。
]

#block(sticky: true)[#raw("<<BufferCache Global Declarations>>=")] <fragment-BufferCacheGlobalDeclarations-0>
```cpp
extern BufferCache<int> *intBufferCache;
extern BufferCache<Point3f> *point3BufferCache;
```


#parec[
  The `BufferCache` class is templated based on the array element type that it stores.
][
  `BufferCache` 类是基于它存储的数组元素类型的模板类。
]

#block(sticky: true)[#raw("<<BufferCache Definition>>=")] <fragment-BufferCacheDefinition-0>
```cpp
template <typename T> class BufferCache {
  public:
    <<BufferCache Public Methods>>
  private:
    <<BufferCache::Buffer Definition>>
    <<BufferCache::BufferHasher Definition>>
    <<BufferCache Private Members>>
};
``` <BufferCache>


#parec[
  `BufferCache` allows concurrent use by multiple threads so that multiple meshes can be added to the scene in parallel; the scene construction code in Appendix #link("https://pbr-book.org/4ed/Processing_the_Scene_Description.html#chap:API")[C] takes advantage of this capability. While a single mutex could be used to manage access to it, contention over that mutex by multiple threads can inhibit concurrency, reducing the benefits of multi-threading. Therefore, the cache is broken into 64 independent #emph[shards], each holding a subset of the entries. Each shard has its own mutex, allowing different threads to concurrently access different shards.
][
  `BufferCache` 允许多个线程同时使用，以便多个网格可以并行添加到场景中；附录 #link("https://pbr-book.org/4ed/Processing_the_Scene_Description.html#chap:API")[C] 中的场景构建代码利用了这一并发功能。 虽然可以使用单个互斥锁来管理对它的访问，但多个线程对该互斥锁的争用会抑制并发，拖累多线程。因此，缓存被分成 64 个独立的#emph[分片]，每个分片保存一部分内容。 每个分片都有自己的互斥锁，允许不同的线程并发访问不同的分片。
]

#block(sticky: true)[#raw("<<BufferCache Private Members>>=")] <fragment-BufferCachePrivateMembers-0>
```cpp
static constexpr int logShards = 6;
static constexpr int nShards = 1 << logShards;
std::shared_mutex mutex[nShards];
std::unordered_set<Buffer, BufferHasher> cache[nShards];
```


#parec[
  `Buffer` is a small helper class that wraps an allocation managed by the `BufferCache`.
][
  `Buffer` 是一个小的辅助类，封装由 `BufferCache` 管理的一块已分配内存。
]

#block(sticky: true)[#raw("<<BufferCache::Buffer Definition>>=")] <fragment-BufferCache::BufferDefinition-0>
```cpp
struct Buffer {
    <<BufferCache::Buffer Public Methods>>
    const T *ptr = nullptr;
    size_t size = 0, hash;
};
```


#parec[
  The `Buffer` constructor computes the buffer's hash, which is stored in a member variable.
][
  `Buffer` 构造函数会计算缓冲区的哈希值，并将其存储在成员变量中。
]

#block(sticky: true)[#raw("<<BufferCache::Buffer Public Methods>>=")] <fragment-BufferCache::BufferPublicMethods-0>
```cpp
Buffer(const T *ptr, size_t size) : ptr(ptr), size(size) {
    hash = HashBuffer(ptr, size);
}
```


#parec[
  An equality operator, which is required by the `std::unordered_set`, only returns true if both buffers are the same size and store the same values.
][
  `std::unordered_set` 需要的相等运算符仅在两个缓冲区大小相同并存储相同值时返回 true。
]

#block(sticky: true)[#raw("<<BufferCache::Buffer Public Methods>>+=")] <fragment-BufferCache::BufferPublicMethods-1>
```cpp
bool operator==(const Buffer &b) const {
    return size == b.size && hash == b.hash &&
           std::memcmp(ptr, b.ptr, size * sizeof(T)) == 0;
}
```

#parec[
  `BufferHasher` is another helper class, used by `std::unordered_set`. It returns the buffer's already-computed hash.
][
  `BufferHasher` 是另一个辅助类，由 `std::unordered_set` 使用。它返回缓冲区已计算的哈希值。
]

#block(sticky: true)[#raw("<<BufferCache::BufferHasher Definition>>=")] <fragment-BufferCache::BufferHasherDefinition-0>
```cpp
struct BufferHasher {
    size_t operator()(const Buffer &b) const {
        return b.hash;
    }
};
```


#parec[
  The `BufferCache` `LookUpOrAdd()` method checks to see if the values stored by the provided buffer are already in the cache and returns a pointer to them if so. Otherwise, it allocates memory to store them and returns a pointer to it.
][
  `BufferCache` 的 `LookUpOrAdd()` 方法检查提供的缓冲区存储的值是否已在缓存中，如果是，则返回指向它们的指针。否则，它会分配内存来存储它们并返回一个指向它的指针。
]

#block(sticky: true)[#raw("<<BufferCache Public Methods>>=")] <fragment-BufferCachePublicMethods-0>
```cpp
const T *LookupOrAdd(pstd::span<const T> buf, Allocator alloc) {
    <<Return pointer to data if buf contents are already in the cache>>
    <<Add buf contents to cache and return pointer to cached copy>>
}
```


#parec[
  The `pstd::span`'s contents need to be wrapped in a `Buffer` instance to be able to search for a matching buffer in the cache. The buffer's pointer is returned if it is already present.
][
  `pstd::span` 的内容需要包装在一个 `Buffer` 实例中，以便能够在缓存中搜索匹配的缓冲区。如果缓冲区已存在，则返回其指针。
]

#parec[
  Because the cache is only read here and is not being modified, the `lock_shared()` capability of `std::shared_mutex` is used here, allowing multiple threads to read the hash table concurrently.
][
  因为这里只是读取缓存而没有进行修改，所以 `std::shared_mutex` 的 `lock_shared()` 功能在这里使用，允许多个线程并发读取哈希表。
]

#block(sticky: true)[#raw("<<Return pointer to data if buf contents are already in the cache>>=")] <fragment-Returnpointertodataifmonobufcontentsarealreadyinthecache-0>
```cpp
Buffer lookupBuffer(buf.data(), buf.size());
int shardIndex = uint32_t(lookupBuffer.hash) >> (32 - logShards);
mutex[shardIndex].lock_shared();
if (auto iter = cache[shardIndex].find(lookupBuffer);
    iter != cache[shardIndex].end()) {
    const T *ptr = iter->ptr;
    mutex[shardIndex].unlock_shared();
    return ptr;
}
```


#parec[
  Otherwise, memory is allocated using the allocator to store the buffer, and the values are copied from the provided span before the `Buffer` is added to the cache. An exclusive lock to the mutex must be held in order to modify the cache; one is acquired by giving up the shared lock and then calling the regular `lock()` method.
][
  否则，使用分配器分配内存来存储缓冲区，并在将 `Buffer` 添加到缓存之前从提供的 span 中复制值。为了修改缓存，必须持有互斥锁的独占锁；通过放弃共享锁然后调用常规的 `lock()` 方法来获取。
]

#block(sticky: true)[#raw("<<Add buf contents to cache and return pointer to cached copy>>=")] <fragment-Addmonobufcontentstocacheandreturnpointertocachedcopy-0>
```cpp
mutex[shardIndex].unlock_shared();
T *ptr = alloc.allocate_object<T>(buf.size());
std::copy(buf.begin(), buf.end(), ptr);
mutex[shardIndex].lock();
<<Handle the case of another thread adding the buffer first>>
cache[shardIndex].insert(Buffer(ptr, buf.size()));
mutex[shardIndex].unlock();
return ptr;
```


#parec[
  It is possible that another thread may have added the buffer to the cache before the current thread is able to; if the same buffer is being added by multiple threads concurrently, then one will end up acquiring the exclusive lock before the other.
][
  可能会出现另一个线程在当前线程之前将缓冲区添加到缓存中的情况；如果多个线程同时添加相同的缓冲区，则其中一个线程最终会在另一个线程之前获取独占锁。
]

#parec[
  In that rare case, a pointer to the already-added buffer is returned and the memory allocated by this thread is released.
][
  在这种罕见的情况下，返回指向已添加缓冲区的指针，并释放此线程分配的内存。
]

#block(sticky: true)[#raw("<<Handle the case of another thread adding the buffer first>>=")] <fragment-Handlethecaseofanotherthreadaddingthebufferfirst-0>
```cpp
if (auto iter = cache[shardIndex].find(lookupBuffer);
    iter != cache[shardIndex].end()) {
    const T *cachePtr = iter->ptr;
    mutex[shardIndex].unlock();
    alloc.deallocate_object(ptr, buf.size());
    return cachePtr;
}
```


#parec[
  Returning now to the `TriangleMesh` constructor, the vertex positions are processed next. Unlike the other shapes that leave the shape description in object space and then transform incoming rays from rendering space to object space, triangle meshes transform the shape into rendering space and thus save the work of transforming incoming rays into object space and the work of transforming the intersection's geometric representation out to rendering space. This is a good idea because this operation can be performed once at startup, avoiding transforming rays many times during rendering. Using this approach with quadrics is more complicated, although possible—see Exercise #link("https://pbr-book.org/4ed/Shapes/Exercises.html#ex:shapes-exercise-quadrics")[6.8.8] at the end of the chapter.
][
  现在回到 `TriangleMesh` 构造函数，接下来处理顶点位置。与其他形状将形状描述保留在对象空间中，然后将传入的射线从渲染空间转换为对象空间不同，三角网格将形状转换为渲染空间，从而节省了将传入射线转换为对象空间以及将交点的几何表示转换为渲染空间的工作。 这是一个好主意，因为这个操作可以在启动时执行一次，避免在渲染期间多次转换射线。对二次曲面使用这种方法更为复杂，尽管可以实现——见本章末尾的练习 #link("https://pbr-book.org/4ed/Shapes/Exercises.html#ex:shapes-exercise-quadrics")[6.8.8]。
]

#parec[
  The resulting points are also provided to the buffer cache, though after the rendering from object transformation has been applied. Because the positions were transformed to rendering space, this cache lookup is rarely successful. The hit rate would likely be higher if positions were left in object space, though doing so would require additional computation to transform vertex positions when they were accessed. Vertex indices and `uv` texture coordinates fare better with the buffer cache, however.
][
  结果点也提供给缓冲区缓存，不过是在应用了从对象到渲染的变换之后。由于位置已被转换为渲染空间，因此此缓存查找很少成功。 如果位置保留在对象空间中，命中率可能会更高，尽管这样做需要额外的计算来在访问顶点位置时进行转换。然而，顶点索引和 `uv` 纹理坐标在缓冲区缓存中表现更好。
]

#block(sticky: true)[#raw("<<Transform mesh vertices to rendering space and initialize mesh p>>=")] <fragment-Transformmeshverticestorenderingspaceandinitializemeshmonop-0>
```cpp
for (Point3f &pt : p)
    pt = renderFromObject(pt);
this->p = point3BufferCache->LookupOrAdd(p, alloc);
```


#parec[
  We will omit the remainder of the #link(<TriangleMesh>)[`TriangleMesh`] constructor, as handling the other per-vertex buffer types is similar to how the positions are processed. The remainder of its member variables are below. In addition to the remainder of the mesh vertex and face data, the `TriangleMesh` records whether the normals should be flipped by way of the values of `reverseOrientation` and `transformSwapsHandedness`. Because these two have the same value for all triangles in a mesh, memory can be saved by storing them once with the mesh itself rather than redundantly with each of the triangles.
][
  我们将省略 #link(<TriangleMesh>)[`TriangleMesh`] 构造函数的其余部分，因为处理其他每顶点缓冲区类型与处理位置的方式类似。 其余的成员变量如下。除了其余的网格顶点和面数据外，`TriangleMesh` 还记录了法向量是否应该通过 `reverseOrientation` 和 `transformSwapsHandedness` 的值来翻转。 因为这两个值对于网格中的所有三角形都是相同的，所以通过将它们与网格本身一起存储而不是在每个三角形中重复存储，可以节省内存。
]

#block(sticky: true)[#raw("<<TriangleMesh Public Members>>+=")] <fragment-TriangleMeshPublicMembers-1>
```cpp
const Normal3f *n = nullptr;
const Vector3f *s = nullptr;
const Point2f *uv = nullptr;
bool reverseOrientation, transformSwapsHandedness;
``` <TriangleMesh::uv>


=== #ez_caption[Triangle Class][Triangle 类]
<triangle-class>
#parec[
  The #link(<Triangle>)[Triangle] class actually implements the #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface. It represents a single triangle.
][
  #link(<Triangle>)[Triangle] 类实际上实现了 #link("https://pbr-book.org/4ed/Shapes/Basic_Shape_Interface.html#Shape")[Shape] 接口。它表示一个单独的三角形。
]

#block(sticky: true)[#raw("<<Triangle Definition>>=")] <fragment-TriangleDefinition-0>
```cpp
class Triangle {
  public:
    <<Triangle Public Methods>>
  private:
    <<Triangle Private Methods>>
    <<Triangle Private Members>>
};
``` <Triangle>



#parec[
  Because complex scenes may have billions of triangles, it is important to minimize the amount of memory that each triangle uses. `pbrt` stores pointers to all the #link(<TriangleMesh>)[TriangleMesh]es for the scene in a vector, which allows each triangle to be represented using just two integers: one to record which mesh it is a part of and another to record which triangle in the mesh it represents. With 4-byte `int`s, each `Triangle` uses just 8 bytes of memory.
][
  因为复杂的场景可能有数十亿个三角形，因此重要的是要尽量减少每个三角形使用的内存量。`pbrt` 将场景中所有 #link(<TriangleMesh>)[TriangleMesh] 的指针存储在一个向量中，因此每个三角形只需用两个整数表示：一个记录它属于哪个网格，另一个记录它在网格中代表哪个三角形。使用 4 字节的 `int`，每个 `Triangle` 仅使用 8 字节的内存。
]

#parec[
  Given this compact representation of triangles, recall the discussion in @dynamic-dispatch about the memory cost of classes with virtual functions: if `Triangle` inherited from an abstract `Shape` base class that defined pure virtual functions, the virtual function pointer with each `Triangle` alone would double its size, assuming a 64-bit architecture with 8-byte pointers.
][
  鉴于这种紧凑的三角形表示，回想一下在 @dynamic-dispatch 中关于具有虚函数的类的内存成本的讨论：如果 `Triangle` 继承自定义纯虚函数的抽象 `Shape` 基类，那么每个 `Triangle` 的虚函数指针将使其大小翻倍，假设在 64 位架构中使用 8 字节指针。
]

#block(sticky: true)[#raw("<<Triangle Public Methods>>=")] <fragment-TrianglePublicMethods-0>
```cpp
Triangle(int meshIndex, int triIndex)
    : meshIndex(meshIndex), triIndex(triIndex) {}
```


#block(sticky: true)[#raw("<<Triangle Private Members>>=")] <fragment-TrianglePrivateMembers-0>
```cpp
int meshIndex = -1, triIndex = -1;
static pstd::vector<const TriangleMesh *> *allMeshes;
```


#parec[
  The bounding box of a triangle is easily found by computing a bounding box that encompasses its three vertices. Because the vertices have already been transformed to rendering space, no transformation of the bounds is necessary.
][
  通过计算这三个顶点的包围盒，可以轻松找到三角形的包围盒。因为顶点已经被转换到渲染空间，所以不需要对边界进行转换。
]

#block(sticky: true)[#raw("<<Triangle Method Definitions>>=")] <fragment-TriangleMethodDefinitions-0>
```cpp
Bounds3f Triangle::Bounds() const {
    <<Get triangle vertices in p0, p1, and p2>>
    return Union(Bounds3f(p0, p1), p2);
}
```

#parec[
  Finding the positions of the three triangle vertices requires some indirection: first the mesh pointer must be found; then the indices of the three triangle vertices can be found given the triangle's index in the mesh; finally, the positions can be read from the mesh's `p` array. We will reuse this fragment repeatedly in the following, as the vertex positions are needed in many of the `Triangle` methods.
][
  找到三角形三个顶点的位置需要一些间接操作：首先必须找到网格指针；然后可以根据三角形在网格中的索引找到三个顶点的索引；最后，可以从网格的 `p` 数组中读取位置。我们将在接下来的部分中反复使用这个片段，因为在许多 `Triangle` 方法中都需要顶点位置。
]

#block(sticky: true)[#raw("<<Get triangle vertices in p0, p1, and p2>>=")] <fragment-Gettriangleverticesinmonop0monop1andmonop2-0>
```cpp
const TriangleMesh *mesh = GetMesh();
const int *v = &mesh->vertexIndices[3 * triIndex];
Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
```


#parec[
  The `GetMesh()` method encapsulates the indexing operation to get the mesh's pointer.
][
  `GetMesh()` 方法封装了获取网格指针的索引操作。
]

#block(sticky: true)[#raw("<<Triangle Private Methods>>=")] <fragment-TrianglePrivateMethods-0>
```cpp
const TriangleMesh *GetMesh() const {
    return (*allMeshes)[meshIndex];
}
```

#parec[
  Using the fact that the area of a parallelogram is given by the length of the cross product of the two vectors along its sides, the `Area()` method computes the triangle area as half the area of the parallelogram formed by two of its edge vectors (see @fig:triangle-parallelogram-area ).
][
  利用平行四边形的面积由其边上的两个向量的叉积的长度给出这一事实，`Area()` 方法将三角形面积计算为由其两条边向量形成的平行四边形面积的一半（见@fig:triangle-parallelogram-area ）。
]

#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-1>
```cpp
Float Area() const {
    <<Get triangle vertices in p0, p1, and p2>>
    return 0.5f * Length(Cross(p1 - p0, p2 - p0));
}
```


#parec[
  Bounding the triangle's normal should be trivial: a cross product of appropriate edges gives its single normal vector direction. However, two subtleties that affect the orientation of the normal must be handled before the bounds are returned.
][
  确定三角形法向量的边界应该是简单的：两边的叉积给出了其单一法向量向量方向。然而，在返回边界之前，必须处理影响法向量方向的两个细微差别。
]

#block(sticky: true)[#raw("<<Triangle Method Definitions>>+=")] <fragment-TriangleMethodDefinitions-1>
```cpp
DirectionCone Triangle::NormalBounds() const {
    <<Get triangle vertices in p0, p1, and p2>>
    Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));
    <<Ensure correct orientation of geometric normal for normal bounds>>
    return DirectionCone(Vector3f(n));
}
``` <Triangle::NormalBounds>

#parec[
  The first issue with the returned normal comes from the presence of per-vertex normals, even though it is a bound on geometric normals that `NormalBounds()` is supposed to return. `pbrt` requires that both the geometric normal and the interpolated per-vertex normal lie on the same side of the surface. If the two of them are on different sides, then `pbrt` follows the convention that the geometric normal is the one that should be flipped.
][
  返回的法向量的第一个问题来自于每个顶点法向量的存在，尽管 `NormalBounds()` 应该返回的是几何法向量的边界。`pbrt` 要求几何法向量和插值的每个顶点法向量位于表面的同一侧。如果两者位于不同的侧面，则 `pbrt` 遵循的惯例是几何法向量应该被翻转。
]

#parec[
  Furthermore, if there are not per-vertex normals, then—as with earlier shapes—the normal is flipped if either `ReverseOrientation` was specified in the scene description or the rendering to object transformation swaps the coordinate system handedness, but not both. Both of these considerations must be accounted for in the normal returned for the normal bounds.
][
  此外，如果没有逐顶点法向量，则与前面形状一样，仅在指定了 `ReverseOrientation` 或渲染空间到对象空间的变换改变坐标系手性这两个条件恰有一个成立时翻转法向量。返回法向量包围范围时，必须同时考虑以上两点。
]


#block(sticky: true)[#raw("<<Ensure correct orientation of geometric normal for normal bounds>>=")] <fragment-Ensurecorrectorientationofgeometricnormalfornormalbounds-0>
```cpp
if (mesh->n) {
    Normal3f ns(mesh->n[v[0]] + mesh->n[v[1]] + mesh->n[v[2]]);
    n = FaceForward(n, ns);
} else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    n *= -1;
```


#parec[
  Although it is not required by the `Shape` interface, we will find it useful to be able to compute the solid angle that a triangle subtends from a reference point. The previously defined #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#SphericalTriangleArea")[SphericalTriangleArea()] function takes care of this directly.
][
  虽然 `Shape` 接口不要求这样做，但我们会发现能够计算三角形从参考点所占据的立体角是很有用的。之前定义的 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#SphericalTriangleArea")[SphericalTriangleArea()] 函数直接处理了这一点。
]

#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-2>
```cpp
Float SolidAngle(Point3f p) const {
    <<Get triangle vertices in p0, p1, and p2>>
    return SphericalTriangleArea(Normalize(p0 - p), Normalize(p1 - p),
                                 Normalize(p2 - p));
}
```


=== #ez_caption[Ray–Triangle Intersection][射线与三角形求交]
<raytriangle-intersection>
#parec[
  Unlike the other shapes so far, `pbrt` provides a stand-alone triangle intersection function that takes a ray and the three triangle vertices directly. Having this functionality available without needing to instantiate both a `Triangle` and a `TriangleMesh` in order to do a ray-triangle intersection test is helpful in a few other parts of the system. The `Triangle` class intersection methods, described next, use this function in their implementations.
][
  与之前的其他形状不同，`pbrt` 提供了一个独立实现的三角形相交函数，该函数直接接受一条光线和三个三角形顶点。无需实例化 `Triangle` 和 `TriangleMesh` 即可进行光线与三角形的相交测试，这种功能在系统的其他部分也很有用。接下来描述的 `Triangle` 类的相交方法在其实现中使用了这个函数。
]

#block(sticky: true)[#raw("<<Triangle Functions>>=")] <fragment-TriangleFunctions-0>
```cpp
pstd::optional<TriangleIntersection>
IntersectTriangle(const Ray &ray, Float tMax, Point3f p0, Point3f p1,
                  Point3f p2) {
    <<Return no intersection if triangle is degenerate>>
    <<Transform triangle vertices to ray coordinate space>>
    <<Compute edge function coefficients e0, e1, and e2>>
    <<Fall back to double-precision test at triangle edges>>
    <<Perform triangle edge and determinant tests>>
    <<Compute scaled hit distance to triangle and test against ray t range>>
    <<Compute barycentric coordinates and t value for triangle intersection>>
    <<Ensure that computed triangle t is conservatively greater than zero>>
    <<Return TriangleIntersection for intersection>>
}
``` <IntersectTriangle>


#parec[
  `pbrt`'s ray-triangle intersection test is based on first computing an affine transformation that transforms the ray such that its origin is at $(0 , 0 , 0)$ in the transformed coordinate system and such that its direction is along the $+ z$ axis. Triangle vertices are also transformed into this coordinate system before the intersection test is performed. In the following, we will see that applying this coordinate system transformation simplifies the intersection test logic since, for example, the $x$ and $y$ coordinates of any intersection point must be zero. Later, in Section 6.8.4, we will see that this transformation makes it possible to have a #emph[watertight] ray-triangle intersection algorithm, such that intersections with tricky rays like those that hit the triangle right on the edge are never incorrectly reported as misses.
][
  `pbrt` 的光线与三角形相交测试基于首先计算一个仿射变换，该变换将光线变换为其原点在变换坐标系中的 $(0 , 0 , 0)$，并使其方向沿 $+ z$ 轴。在进行相交测试之前，三角形顶点也被转换到这个坐标系中。接下来，我们将看到应用这个坐标系变换简化了相交测试逻辑，因为例如任何相交点的 $x$ 和 $y$ 坐标必须为零。在后面的第 6.8.4 节中，我们将看到这种变换使得可以实现一个水密的射线与三角形求交算法，这样与棘手的光线相交（例如正好击中三角形边缘的光线）时不会被错误地报告为未命中。
]

#parec[
  One side effect of the transformation that we will apply to the vertices is that, due to floating-point round-off error, a degenerate triangle may be transformed into a non-degenerate triangle. If an intersection is reported with a degenerate triangle, then later code that tries to compute the geometric properties of the intersection will be unable to compute valid results. Therefore, this function starts with testing for a degenerate triangle and returning immediately if one was provided.
][
  我们将应用于顶点的变换的一个副作用是，由于浮点数舍入误差，一个退化三角形可能会被转换为一个非退化三角形。如果报告了与退化三角形的相交，那么后续尝试计算相交几何属性的代码将无法计算出有效结果。因此，该函数首先检查是否为退化三角形，如果是则立即返回。
]

#block(sticky: true)[#raw("<<Return no intersection if triangle is degenerate>>=")] <fragment-Returnnointersectioniftriangleisdegenerate-0>
```cpp
if (LengthSquared(Cross(p2 - p0, p1 - p0)) == 0)
    return {};
```


#parec[
  There are three steps to computing the transformation from rendering space to the ray-triangle intersection coordinate space: a translation $bold(T)$, a coordinate permutation $bold(P)$, and a shear $bold(S)$. Rather than computing explicit transformation matrices for each of these and then computing an aggregate transformation matrix $bold(M)=bold(S) bold(P) bold(T)$ to transform vertices to the coordinate space, the following implementation applies each step of the transformation directly, which ends up being a more efficient approach.
][
  从渲染空间到光线与三角形相交坐标空间的变换计算分为三个步骤：平移 $bold(T)$、坐标置换 $bold(P)$ 和剪切 $bold(S)$。与其为每个步骤计算显式变换矩阵，然后计算一个聚合变换矩阵 $bold(M)=bold(S) bold(P) bold(T)$ 来将顶点转换到坐标空间，以下实现直接逐步应用变换，这种方法更加高效。
]

#block(sticky: true)[#raw("<<Transform triangle vertices to ray coordinate space>>=")] <fragment-Transformtriangleverticestoraycoordinatespace-0>
```cpp
<<Translate vertices based on ray origin>>
<<Permute components of triangle vertices and ray direction>>
<<Apply shear transformation to translated vertex positions>>
```





#parec[
  The translation that places the ray origin at the origin of the coordinate system is:
][
  将射线起点移到坐标系原点的平移为：
]
$
  upright(bold(T)) = mat(delim: "(", 1, 0, 0, - upright(bold(o))_x; 0, 1, 0, - upright(bold(o))_y; 0, 0, 1, - upright(bold(o))_z; 0, 0, 0, 1)
$


#parec[
  This transformation does not need to be explicitly applied to the ray origin, but we will apply it to the three triangle vertices.
][
  这个变换不需要直接应用于光线起点，但我们会将其应用于三个三角形顶点。
]

#block(sticky: true)[#raw("<<Translate vertices based on ray origin>>=")] <fragment-Translateverticesbasedonrayorigin-0>
```cpp
Point3f p0t = p0 - Vector3f(ray.o);
Point3f p1t = p1 - Vector3f(ray.o);
Point3f p2t = p2 - Vector3f(ray.o);
```

#parec[
  Next, the three dimensions of the space are permuted so that the $z$ dimension is the one where the absolute value of the ray's direction is largest. The $x$ and $y$ dimensions are arbitrarily assigned to the other two dimensions. This step ensures that if, for example, the original ray's $z$ direction is zero, then a dimension with nonzero magnitude is mapped to $+ z$.
][
  接下来，空间的三个维度被重新排列，使得 $z$ 维度是光线方向绝对值最大的维度。 $x$ 和 $y$ 维度被随意分配给其他两个维度。此步骤确保如果例如原始光线的 $z$ 方向为零，则具有非零幅度的维度被映射到 $+ z$。
]

#parec[
  For example, if the ray's direction had the largest magnitude in $x$, the permutation would~be:
][
  例如，如果光线的方向在 $x$ 上具有最大幅度，置换将是：
]

$ upright(bold(P)) = mat(delim: "(", 0, 1, 0, 0; 0, 0, 1, 0; 1, 0, 0, 0; 0, 0, 0, 1) $



#parec[
  As before, it is easiest to permute the dimensions of the ray direction and the translated triangle vertices directly.
][
  如前所述，最简单的方法是直接置换光线方向和已平移的三角形顶点的维度。
]



#block(sticky: true)[#raw("<<Permute components of triangle vertices and ray direction>>=")] <fragment-Permutecomponentsoftriangleverticesandraydirection-0>
```cpp
int kz = MaxComponentIndex(Abs(ray.d));
int kx = kz + 1; if (kx == 3) kx = 0;
int ky = kx + 1; if (ky == 3) ky = 0;
Vector3f d = Permute(ray.d, {kx, ky, kz});
p0t = Permute(p0t, {kx, ky, kz});
p1t = Permute(p1t, {kx, ky, kz});
p2t = Permute(p2t, {kx, ky, kz});
```


#parec[
  Finally, a shear transformation aligns the ray direction with the $+ z$ axis:
][
  最后，一个剪切变换使光线方向与 $+ z$ 轴对齐：
]

$
  upright(bold(S)) = mat(delim: "(", 1, 0, - upright(bold(d))_x / upright(bold(d))_z, 0; 0, 1, - upright(bold(d))_y / upright(bold(d))_z, 0; 0, 0, 1 / upright(bold(d))_z, 0; 0, 0, 0, 1)
$


#parec[
  To see how this transformation works, consider its operation on the ray direction vector $vec(upright(bold(d))_x, upright(bold(d))_y, upright(bold(d))_z, 0)^T$.
][
  要了解此变换如何工作，请考虑其对光线方向向量 $vec(upright(bold(d))_x, upright(bold(d))_y, upright(bold(d))_z, 0)^T$ 的操作。
]

#parec[
  For now, only the $x$ and $y$ dimensions are sheared; we can wait and shear the $z$ dimension only if the ray intersects the triangle.
][
  目前，仅对 $x$ 和 $y$ 维度进行剪切；我们可以等到光线与三角形相交时再剪切 $z$ 维度。
]



#block(sticky: true)[#raw("<<Apply shear transformation to translated vertex positions>>=")] <fragment-Applysheartransformationtotranslatedvertexpositions-0>
```cpp
Float Sx = -d.x / d.z;
Float Sy = -d.y / d.z;
Float Sz = 1 / d.z;
p0t.x += Sx * p0t.z;
p0t.y += Sy * p0t.z;
p1t.x += Sx * p1t.z;
p1t.y += Sy * p1t.z;
p2t.x += Sx * p2t.z;
p2t.y += Sy * p2t.z;
```

#parec[
  Note that the calculations for the coordinate permutation and the shear coefficients only depend on the given ray; they are independent of the triangle. In a high-performance ray tracer, it may be worthwhile to compute these values once and store them in the Ray class, rather than recomputing them for each triangle the ray is intersected with.
][
  注意，坐标重新排列和剪切系数的计算仅依赖于给定的光线；它们与三角形无关。在高效光线追踪器中，可能值得在Ray类中计算这些值一次并存储，而不是为光线与每个三角形相交时重新计算。
]

#parec[
  With the triangle vertices transformed to this coordinate system, our task now is to find whether the ray starting from the origin and traveling along the $+ z$ axis intersects the transformed triangle. Because of the way the coordinate system was constructed, this problem is equivalent to the 2D problem of determining if the $(0 , 0)$ coordinates are inside the $x y$ projection of the triangle (@fig:triangle-ray-transform ).
][
  将三角形顶点转换到此坐标系后，我们现在的任务是确定从原点出发沿 $+ z$ 轴行进的光线是否与转换后的三角形相交。由于坐标系的构造方式，此问题等同于确定 $(0 , 0)$ 坐标是否在三角形的 $x y$ 投影内（@fig:triangle-ray-transform ）。
]


#figure(image("../pbr-book-website/4ed/Shapes/pha06f12.svg"), caption: [#ez_caption[In the ray–triangle intersection coordinate system, the ray starts at the origin and goes along the $+z$ axis. The intersection test can be performed by considering only the $x y$ projection of the ray and the triangle vertices, which in turn reduces to determining if the 2D point $(0,0)$ is within the triangle.][在射线与三角形求交的坐标系中，射线从原点沿 $+z$ 轴出发。只需考虑射线和三角形顶点的 $x y$ 投影，就可将求交化为判断二维点 $(0,0)$ 是否位于三角形内部。]]) <triangle-ray-transform>
#parec[
  To understand how the intersection algorithm works, first recall from Figure~3.6 that the length of the cross product of two vectors gives the area of the parallelogram that they define. In 2D, with vectors $upright(bold(a))$ and $upright(bold(b))$, the area is
][
  要理解相交算法如何工作，首先从图~3.6回忆两个向量的叉积长度给出了它们定义的平行四边形的面积。在2D中，向量 $upright(bold(a))$ 和 $upright(bold(b))$ 的面积是
]

$ upright(bold(a))_x upright(bold(b))_y - upright(bold(b))_x upright(bold(a))_y $



#parec[
  Half of this area is the area of the triangle that they define. Thus, we can see that in 2D, the area of a triangle with vertices $upright(bold(p))_0$, $upright(bold(p))_1$, and $upright(bold(p))_2$ is
][
  此面积的一半是它们定义的三角形的面积。因此，我们可以看到在2D中，具有顶点 $upright(bold(p))_0$ 、 $upright(bold(p))_1$ 和 $upright(bold(p))_2$ 的三角形的面积是
]

$
  1 / 2 (
    (p_(1x) - p_(0x)) (p_(2y) - p_(0y)) - (
      p_(2x) - p_(0x)
    ) (p_(1y) - p_(0y))
  )
$



#parec[
  @fig:triangle-parallelogram-area  visualizes this idea geometrically.
][
  @fig:triangle-parallelogram-area 从几何上可视化了这个想法。
]


#figure(image("../pbr-book-website/4ed/Shapes/pha06f13.svg"), caption: [#ez_caption[The area of a triangle with two edges given by vectors $bold(v)_1$ and $bold(v)_2$ is one-half of the area of the parallelogram shown here. The parallelogram area is given by the length of the cross product of $bold(v)_1$ and $bold(v)_2$.][两条边向量为 $bold(v)_1$ 与 $bold(v)_2$ 的三角形，其面积是图中平行四边形面积的一半。平行四边形面积等于两向量叉积的长度。]]) <triangle-parallelogram-area>
#parec[
  We will use this expression of triangle area to define a signed edge function: given two triangle vertices $upright(bold(p))_0$ and $upright(bold(p))_1$, we can define the directed edge function $e$ as the function that gives twice the area of the triangle given by $upright(bold(p))_0$, $upright(bold(p))_1$, and a given third point $upright(bold(p))$ :
][
  我们将使用这个三角形面积的表达式来定义一个有符号的边函数：给定两个三角形顶点 $upright(bold(p))_0$ 和 $upright(bold(p))_1$，我们可以定义有向边函数 $e$，作为给定第三个点 $upright(bold(p))$ 的三角形由 $upright(bold(p))_0$ 、 $upright(bold(p))_1$ 和 $upright(bold(p))$ 定义的面积的两倍的函数：
]


$ e(p) = (p_(1x)-p_(0x))(p_y-p_(0y)) - (p_x-p_(0x))(p_(1y)-p_(0y)) . $ <edge-function>

#parec[
  (See @fig:edge-function-figure .)
][
  (见@fig:edge-function-figure .)
]


#figure(image("../pbr-book-website/4ed/Shapes/pha06f14.svg"), caption: [#ez_caption[The edge function $e(p)$ characterizes points with respect to an oriented line between two points $p_0$ and $p_1$. The value of the edge function is positive for points $p$ to the left of the line, zero for points on the line, and negative for points to the right of the line. The ray–triangle intersection algorithm uses an edge function that is twice the signed area of the triangle formed by the three points.][边函数 $e(p)$ 描述点相对于从 $p_0$ 到 $p_1$ 的有向直线的位置：直线左侧为正，直线上为零，右侧为负。射线与三角形求交算法所用的边函数，等于这三个点所构成三角形的有符号面积的两倍。]]) <edge-function-figure>
#parec[
  The edge function gives a positive value for points to the right of the line, and a negative value for points to the left. Thus, if a point has edge function values of the same sign for all three edges of a triangle, it must be on the same side of all three edges and thus must be inside the triangle.
][
  边函数对线右侧的点给出正值，对线左侧的点给出负值。因此，如果一个点对于三角形的所有三条边的边函数值符号相同，则该点必定在所有三条边的同一侧，因此必定在三角形内部。
]

#parec[
  Thanks to the coordinate system transformation, the point $p$ that we are testing has coordinates $(0 , 0)$. This simplifies the edge function expressions. For example, for the edge $e_0$ from $p_1$ to $p_2$, we have:
][
  由于坐标系转换，我们正在测试的点 $p$ 的坐标为 $(0 , 0) $。这简化了边函数表达式。例如，对于从 $p_1$ 到 $p_2$ 的边 $e_0$，我们有：
]

$
 e_0(p) &= (p_(2x)-p_(1x))(p_y-p_(1y))-(p_x-p_(1x))(p_(2y)-p_(1y)) \
 &= (p_(2x)-p_(1x))(-p_(1y))-(-p_(1x))(p_(2y)-p_(1y)) \
 &= p_(1x) p_(2y)-p_(2x) p_(1y) .
$ <edge-function-00>

#parec[
  In the following, we will use the indexing scheme that the edge function $e_i$ corresponds to the directed edge from vertex $p_((i + 1) #h(0em) mod med 3)$ to $p_((i + 2) #h(0em) mod med 3)$.
][
  接下来，我们将使用索引方案，其中边函数 $e_i$ 对应于从顶点 $p_((i + 1) #h(0em) mod med 3)$ 到 $p_((i + 2) #h(0em) mod med 3)$ 的定向边。
]
#block(sticky: true)[#raw("<<Compute edge function coefficients e0, e1, and e2>>=")] <fragment-Computeedgefunctioncoefficientsmonoe0monoe1andmonoe2-0>
```cpp
Float e0 = DifferenceOfProducts(p1t.x, p2t.y, p1t.y, p2t.x);
Float e1 = DifferenceOfProducts(p2t.x, p0t.y, p2t.y, p0t.x);
Float e2 = DifferenceOfProducts(p0t.x, p1t.y, p0t.y, p1t.x);
```


#parec[
  In the rare case that any of the edge function values is exactly zero, it is not possible to be sure if the ray hits the triangle or not, and the edge equations are reevaluated using double-precision floating-point arithmetic. (@robust-triangle-intersections discusses the need for this step in more detail.) The fragment that implements this computation, ⟨Fall back to double-precision test at triangle edges⟩, is just a reimplementation of ⟨Compute edge function coefficients e0, e1, and e2⟩ using doubles and so is not included here.
][
  在边函数值恰好为零的少数情况下，无法确定射线是否命中三角形，因此用双精度浮点运算重新计算边方程。@robust-triangle-intersections 将进一步解释这一处理的必要性。⟨Fall back to double-precision test at triangle edges⟩ 片段用 double 重写了 ⟨Compute edge function coefficients e0, e1, and e2⟩，故正文不再列出。
]
#parec[
  Given the values of the three edge functions, we have our first two opportunities to determine that there is no intersection. First, if the signs of the edge function values differ, then the point $(0 , 0)$ is not on the same side of all three edges and therefore is outside the triangle. Second, if the sum of the three edge function values is zero, then the ray is approaching the triangle edge-on, and we report no intersection. (For a closed triangle mesh, the ray will hit a neighboring triangle instead.)
][
  给定三个边函数的值，我们有两个机会可以确定没有交点。首先，如果边函数值的符号不同，则点 $(0 , 0)$ 不在所有三条边的同一侧，因此在三角形外部。其次，如果三个边函数值的和为零，则射线沿三角形平面方向掠过，我们报告没有交点。（对于封闭的三角形网格，光线将击中相邻的三角形。）
]

#block(sticky: true)[#raw("<<Perform triangle edge and determinant tests>>=")] <fragment-Performtriangleedgeanddeterminanttests-0>
```cpp
if ((e0 < 0 || e1 < 0 || e2 < 0) && (e0 > 0 || e1 > 0 || e2 > 0))
    return {};
Float det = e0 + e1 + e2;
if (det == 0)
    return {};
```

#parec[
  Because the ray starts at the origin, has unit length, and is along the $+ z$ axis, the $z$ coordinate value of the intersection point is equal to the intersection's parametric $t $ value. To compute this $z $ value, we first need to go ahead and apply the shear transformation to the $z$ coordinates of the triangle vertices. Given these $z$ values, the barycentric coordinates of the intersection point in the triangle can be used to interpolate them across the triangle. They are given by dividing each edge function value by the sum of edge function values:
][
  光线从原点出发，方向向量长度为1，并沿 $+ z$ 轴方向，因此交点的 $z$ 坐标值等于其参数 $t$ 值。为了计算这个 $z$ 值，我们首先需要对三角形顶点的 $z$ 坐标应用剪切变换。给定这些 $z$ 值，交点在三角形中的重心坐标可以用于在三角形上进行插值。它们通过将每个边函数值除以边函数值的和来给出：
]

$ b_i = frac(e_i, e_0 + e_1 + e_2) . $


#parec[
  Thus, the $b_i$ sum to one.
][
  因此， $b_i$ 的和为一。
]

#parec[
  The interpolated $z$ value is given by
][
  插值后的 $z$ 值由以下公式给出：
]

$ z = b_0 z_0 + b_1 z_1 + b_2 z_2 , $

#parec[
  where $z_i$ are the coordinates of the three vertices in the ray-triangle intersection coordinate system.
][
  其中 $z_i$ 是光线-三角形相交坐标系中三个顶点的坐标。
]

#parec[
  To save the cost of the floating-point division to compute $b_i$ in cases where the final $t$ value is out of the range of valid $t$ values, the implementation here first computes $t$ by interpolating $z_i$ with $e_i$ (in other words, not yet performing the division by $d = e_0 + e_1 + e_2$ ). If the sign of $d$ and the sign of the interpolated $t$ value are different, then the final $t$ value will certainly be negative and thus not a valid intersection.
][
  为了节省计算 $b_i$ 的浮点除法的开销，在最终 $t$ 值超出有效 $t$ 值范围的情况下，此处的实现首先通过使用 $e_i$ 插值 $z_i$ 来计算 $t$ （换句话说，尚未执行除以 $d = e_0 + e_1 + e_2$ 的操作）。如果 $d$ 的符号与插值后的 $t$ 值的符号不同，则最终 $t$ 值肯定为负，因此不是有效的交点。
]

#parec[
  Along similar lines, the check $t < t_("max")$ can be equivalently performed in two ways:
][
  类似地，检查 $t < t_("max")$ 可以通过两种方式等效执行：
]


$
  quad sum_i e_i z_i < t_(upright("max")) (e_0 + e_1 + e_2) & upright(" if ") e_0 + e_1 + e_2 > 0 \
  quad sum_i e_i z_i > t_(upright("max")) (e_0 + e_1 + e_2) & upright(" otherwise")
$
#block(sticky: true)[#raw("<<Compute scaled hit distance to triangle and test against ray t range>>=")] <fragment-Computescaledhitdistancetotriangleandtestagainstraytrange-0>
```cpp
p0t.z *= Sz;
p1t.z *= Sz;
p2t.z *= Sz;
Float tScaled = e0 * p0t.z + e1 * p1t.z + e2 * p2t.z;
if (det < 0 && (tScaled >= 0 || tScaled < tMax * det))
    return {};
else if (det > 0 && (tScaled <= 0 || tScaled > tMax * det))
    return {};
```

#parec[
  Given a valid intersection, the actual barycentric coordinates and $t$ value for the intersection are found.
][
  给定一个有效的交点，可以找到交点的实际重心坐标和 $t$ 值。
]

#block(sticky: true)[#raw("<<Compute barycentric coordinates and t value for triangle intersection>>=")] <fragment-Computebarycentriccoordinatesandtvaluefortriangleintersection-0>
```cpp
Float invDet = 1 / det;
Float b0 = e0 * invDet, b1 = e1 * invDet, b2 = e2 * invDet;
Float t = tScaled * invDet;
```


#parec[
  After a final test on the $t$ value that will be discussed in Section #link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:avoid-negative-t-intersections")[6.8.7], a `TriangleIntersection` object that represents the intersection can be returned.
][
  在对将在#link("https://pbr-book.org/4ed/Shapes/Managing_Rounding_Error.html#sec:avoid-negative-t-intersections")[6.8.7节]中讨论的 $t$ 值进行最终测试后，可以返回表示交点的 `TriangleIntersection` 对象。
]

#block(sticky: true)[#raw("<<Return TriangleIntersection for intersection>>=")] <fragment-ReturnmonoTriangleIntersectionforintersection-0>
```cpp
return TriangleIntersection{b0, b1, b2, t};
```


#parec[
  `TriangleIntersection` just records the barycentric coordinates and the $t$ value along the ray where the intersection occurred.
][
  `TriangleIntersection` 仅记录交点发生在射线上时的重心坐标和 $t$ 值。
]


#block(sticky: true)[#raw("<<TriangleIntersection Definition>>=")] <fragment-TriangleIntersectionDefinition-0>
```cpp
struct TriangleIntersection {
    Float b0, b1, b2;
    Float t;
};
``` <TriangleIntersection>

#parec[
  The structure of the `Triangle::Intersect()` method follows the form of earlier intersection test methods.
][
  `Triangle::Intersect()` 方法的结构遵循早期求交测试方法的形式。
]

#block(sticky: true)[#raw("<<Triangle Method Definitions>>+=")] <fragment-TriangleMethodDefinitions-2>
```cpp
pstd::optional<ShapeIntersection> Triangle::Intersect(const Ray &ray,
                                                      Float tMax) const {
    <<Get triangle vertices in p0, p1, and p2>>
    pstd::optional<TriangleIntersection> triIsect =
        IntersectTriangle(ray, tMax, p0, p1, p2);
    if (!triIsect) return {};
    SurfaceInteraction intr = InteractionFromIntersection(
        mesh, triIndex, *triIsect, ray.time, -ray.d);
    return ShapeIntersection{intr, triIsect->t};
}
```

#parec[
  We will not include the `Triangle::IntersectP()` method here, as it is just based on calling `IntersectTriangle()`.
][
  我们不会在此处包含 `Triangle::IntersectP()` 方法，因为它只是基于调用 `IntersectTriangle()`。
]

#parec[
  The `InteractionFromIntersection()` method is different than the corresponding methods in the quadrics in that it is a stand-alone function rather than a regular member function. Because a call to it is thus not associated with a specific `Triangle` instance, it takes a `TriangleMesh` and the index of a triangle in the mesh as parameters. In the context of its usage in the `Intersect()` method, this may seem gratuitous—why pass that information as parameters rather than access it directly in a non-static method?
][
  `InteractionFromIntersection()` 方法与二次曲面中对应的方法不同，因为它是一个独立的函数，而不是一个常规的成员函数。 因此，对它的调用不与特定的 `Triangle` 实例相关联，它将 `TriangleMesh` 和网格中三角形的索引作为参数。 在 `Intersect()` 方法的使用上下文中，这可能显得多余——为什么要将这些信息作为参数传递，而不是在非静态方法中直接访问它？
]

#parec[
  We have designed the interface in this way so that we are able to use this method in `pbrt`'s GPU rendering path, where the `Triangle` class is not used. There, the representation of triangles in the scene is abstracted by a ray intersection API and the geometric ray-triangle intersection test is performed using specialized hardware. Given an intersection, it provides the triangle index, a pointer to the mesh that the triangle is a part of, and the barycentric coordinates of the intersection. That information is sufficient to call this method, which then allows us to find the `SurfaceInteraction` for such intersections using the same code as executes on the CPU.
][
  我们设计这样的接口是为了能够在 `pbrt` 的 GPU 渲染路径中使用此方法，其中不使用 `Triangle` 类。 在那里，场景中三角形的表示由射线求交 API 抽象，几何射线与三角形求交测试使用专用硬件进行。 给定一个交点，它提供三角形索引、指向三角形所属网格的指针以及交点的重心坐标。 这些信息足以调用此方法，从而允许我们使用与 CPU 上执行的相同代码找到此类交点的 `SurfaceInteraction`。
]


#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-3>
```cpp
static SurfaceInteraction InteractionFromIntersection(
        const TriangleMesh *mesh, int triIndex,
        TriangleIntersection ti, Float time, Vector3f wo) {
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    <<Compute triangle partial derivatives>>
    <<Interpolate (u, v) parametric coordinates and hit point>>
    <<Return SurfaceInteraction for triangle hit>>
}
```
#parec[
  To generate consistent tangent vectors over triangle meshes, it is necessary to compute the partial derivatives $∂ p \/ ∂ u$ and $∂ p \/ ∂ v$ using the parametric $(u,v)$ values at the triangle vertices, if provided. Although the partial derivatives are the same at all points on the triangle, the implementation here recomputes them each time an intersection is found. Although this results in redundant computation, the storage savings for large triangle meshes can be significant.
][
  为了在三角网格上生成一致的切线向量，有必要使用三角形顶点处的参数化 $(u,v)$ 值来计算偏导数 $∂ p \/ ∂ u$ 和 $∂ p \/ ∂ v$。尽管在三角形上的所有点处这些偏导数是相同的，但此处的实现每次找到交点时都会重新计算它们。尽管这会导致重复计算，但对于大型三角网格来说，节省的存储空间可能是相当可观的。
]

#parec[
  A triangle can be described by the set of points
][
  一个三角形可用如下点集描述：
]

$
  upright(p)_o + u (∂ upright(p)) / (∂ u) + v (∂ upright(p)) / (∂ v)
$

#parec[
  for some $p_o$, where $u$ and $v$ range over the parametric coordinates of the triangle. We also know the three vertex positions $p_i$, $i = 0 , 1 , 2$, and the texture coordinates $(u_i , v_i)$ at each vertex. From this it follows that the partial derivatives of $p$ must satisfy
][
  对于某个给定的 $p_o$，其中 $u$ 和 $v$ 在三角形的参数坐标范围内。我们还知道三个顶点位置 $p_i$， $i = 0 , 1 , 2$，以及每个顶点的纹理坐标 $(u_i , v_i)$。由此可知， $p$ 的偏导数必须满足以下条件
]

$
  upright(p)_i = upright(p)_o + u_i (∂ upright(p)) / (∂ u) + v_i (∂ upright(p)) / (∂ v)
$


#parec[
  In other words, there is a unique affine mapping from the 2D $(u , v)$ space to points on the triangle. (Such a mapping exists even though the triangle is specified in 3D because the triangle is planar.) To compute expressions for $frac(∂p, ∂u)$ and $frac(∂p, ∂v)$, we start by computing the differences $p_0 - p_2$ and $p_1 - p_2$, giving the matrix equation
][
  换句话说，从二维 $(u , v)$ 空间到三角形上的点存在一个唯一的仿射映射。即使三角形在三维空间中定义，由于三角形是平面的，这种映射仍然存在。为了计算 $frac(∂p, ∂u)$ 与 $frac(∂p, ∂v)$ 的表达式，我们首先计算 $p_0 - p_2$ 和 $p_1 - p_2$ 的差异，得到矩阵方程
]

$
  mat(delim: "(", u_0 - u_2, v_0 - v_2; u_1 - u_2, v_1 - v_2) vec(frac(∂ p, ∂ u), frac(∂  p, ∂ v)) = vec(p_0 - p_2, p_1 - p_2) .
$



#parec[
  Thus,
][
  因此，
]

$
  vec(frac(∂  p, ∂ u), frac(∂  p, ∂ v)) = mat(delim: "(", u_0 - u_2, v_0 - v_2; u_1 - u_2, v_1 - v_2)^(- 1) vec(p_0 - p_2, p_1 - p_2) .
$


#parec[
  Inverting a $2 times 2$ matrix is straightforward. The inverse of the $(u , v)$ differences matrix is
][
  求解 $2 times 2$ 矩阵的逆是一个直接的过程。 $(u , v)$ 差异矩阵的逆为
]

$
  frac(1, (u_0 - u_2) (v_1 - v_2) - (v_0 - v_2) (u_1 - u_2)) mat(delim: "(", v_1 - v_2, - (v_0 - v_2); - (u_1 - u_2), u_0 - u_2) .
$ <tri-inverse-uv-diffs>


#parec[
  This computation is performed by the \<\<#link(<fragment-Computetrianglepartialderivatives-0>)[Compute triangle partial derivatives]\>\> fragment, with handling for various additional corner cases.
][
  此计算由 \<\<#link(<fragment-Computetrianglepartialderivatives-0>)[计算三角形偏导数]\>\> 代码片段执行，并处理各种附加的特殊情况。
]

#block(sticky: true)[#raw("<<Compute triangle partial derivatives>>=")] <fragment-Computetrianglepartialderivatives-0>
```cpp
<<Compute deltas and matrix determinant for triangle partial derivatives>>
Vector3f dpdu, dpdv;
bool degenerateUV = std::abs(determinant) < 1e-9f;
if (!degenerateUV) {
    <<Compute triangle ∂p/∂u and ∂p/∂v via matrix inversion>>
}
<<Handle degenerate triangle (u, v) parameterization or partial derivatives>>
```

#parec[
  The triangle's `uv` coordinates are found by indexing into the #link(<TriangleMesh::uv>)[TriangleMesh::uv] array, if present. Otherwise, a default parameterization is used. We will not include the fragment that initializes `uv` here.
][
  三角形的 `uv` 坐标通过索引 #link(<TriangleMesh::uv>)[TriangleMesh::uv] 数组获取（如果存在）。否则，使用默认参数化。我们在这里不会包含初始化 `uv` 的代码片段。
]

#block(sticky: true)[#raw("<<Compute deltas and matrix determinant for triangle partial derivatives>>=")] <fragment-Computedeltasandmatrixdeterminantfortrianglepartialderivatives-0>
```cpp
<<Get triangle texture coordinates in uv array>>
Vector2f duv02 = uv[0] - uv[2], duv12 = uv[1] - uv[2];
Vector3f dp02 = p0 - p2, dp12 = p1 - p2;
Float determinant =
    DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
```

#parec[
  In the usual case, the $2 times 2$ matrix is non-degenerate, and the partial derivatives are computed using @eqt:tri-inverse-uv-diffs.
][
  通常情况下， $2 times 2$ 矩阵是非退化的，偏导数使用@eqt:tri-inverse-uv-diffs 计算。
]

#block(sticky: true)[#raw("<<Compute triangle ∂p/∂u and ∂p/∂v via matrix inversion>>=")] <fragment-Computetriangledpduanddpdvviamatrixinversion-0>
```cpp
Float invdet = 1 / determinant;
dpdu = DifferenceOfProducts(duv12[1], dp02, duv02[1], dp12) * invdet;
dpdv = DifferenceOfProducts(duv02[0], dp12, duv12[0], dp02) * invdet;
```


#parec[
  However, there are a number of rare additional cases that must be handled. For example, the user may have provided $(u , v)$ coordinates that specify a degenerate parameterization, such as the same $(u , v)$ at all three vertices. Alternatively, the computed `dpdu` and `dpdv` values may have a degenerate cross product due to rounding error. In such cases we fall back to computing `dpdu` and `dpdv` that at least give the correct normal vector.
][
  然而，还有一些罕见的附加情况需要处理。例如，用户可能提供了指定退化参数化的 $(u , v)$ 坐标，例如在所有三个顶点上相同的 $(u , v)$。或者，计算出的 `dpdu` 和 `dpdv` 值可能由于舍入误差而具有退化的叉积。在这种情况下，我们会回退到计算至少给出正确法向量的 `dpdu` 和 `dpdv`。
]

#block(sticky: true)[#raw("<<Handle degenerate triangle (u, v) parameterization or partial derivatives>>=")] <fragment-Handledegeneratetriangleuvparameterizationorpartialderivatives-0>
```cpp
if (degenerateUV || LengthSquared(Cross(dpdu, dpdv)) == 0) {
    Vector3f ng = Cross(p2 - p0, p1 - p0);
    if (LengthSquared(ng) == 0)
        ng = Vector3f(Cross(Vector3<double>(p2 - p0),
                            Vector3<double>(p1 - p0)));
    CoordinateSystem(Normalize(ng), &dpdu, &dpdv);
}
```



#parec[
  To compute the intersection point and the $(u,v)$ parametric coordinates at the hit point, the barycentric interpolation formula is applied to the vertex positions and the $(u,v)$ coordinates at the vertices. As we will see in @bounding-intersection-point-error, this gives a more accurate result for the intersection point than evaluating the parametric ray equation using `t`.
][
  对顶点位置及各顶点的 $(u,v)$ 坐标进行重心插值，就能得到交点位置和交点处的参数坐标。@bounding-intersection-point-error 将说明，这比把 `t` 代入射线参数方程求交点更准确。
]
#block(sticky: true)[#raw("<<Interpolate (u, v) parametric coordinates and hit point>>=")] <fragment-Interpolateuvparametriccoordinatesandhitpoint-0>
```cpp
Point3f pHit = ti.b0 * p0 + ti.b1 * p1 + ti.b2 * p2;
Point2f uvHit = ti.b0 * uv[0] + ti.b1 * uv[1] + ti.b2 * uv[2];
```
#parec[
  Unlike with the shapes we have seen so far, it is not necessary to transform the `SurfaceInteraction` here to rendering space, since the geometric per-vertex values are already in rendering space. Like the disk, the partial derivatives of the triangle’s normal are also both $(0,0,0)$, since it is flat.
][
  与前面介绍的形状不同，这里的逐顶点几何量已在渲染空间中，因此不必再变换 `SurfaceInteraction`。三角形是平面的，所以与圆盘一样，其法向量的两个偏导数均为 $(0,0,0)$。
]
#block(sticky: true)[#raw("<<Return SurfaceInteraction for triangle hit>>=")] <fragment-ReturnmonoSurfaceInteractionfortrianglehit-0>
```cpp
bool flipNormal = mesh->reverseOrientation ^ mesh->transformSwapsHandedness;
<<Compute error bounds pError for triangle intersection>>
SurfaceInteraction isect(Point3fi(pHit, pError), uvHit, wo, dpdu, dpdv,
                         Normal3f(), Normal3f(), time, flipNormal);
<<Set final surface normal and shading geometry for triangle>>
return isect;
```
#parec[
  Before the `SurfaceInteraction` is returned, some final details related to its surface normal and shading geometry must be taken care of.
][
  返回 `SurfaceInteraction` 前，还需处理表面法向量与着色几何的最后几项细节。
]
#block(sticky: true)[#raw("<<Set final surface normal and shading geometry for triangle>>=")] <fragment-Setfinalsurfacenormalandshadinggeometryfortriangle-0>
```cpp
<<Override surface normal in isect for triangle>>
if (mesh->n || mesh->s) {
    <<Initialize Triangle shading geometry>>
}
```
#parec[
  The `SurfaceInteraction` constructor initializes the geometric normal `n` as the normalized cross product of `dpdu` and `dpdv`. This works well for most shapes, but in the case of triangle meshes it is preferable to rely on an initialization that does not depend on the underlying texture coordinates: it is fairly common to encounter meshes with bad parameterizations that do not preserve the orientation of the mesh, in which case the geometric normal would have an incorrect orientation.
][
  `SurfaceInteraction` 构造函数通过将 `dpdu` 与 `dpdv` 的叉积归一化来初始化几何法向量 `n`。这适用于大多数形状，但三角网格最好采用不依赖纹理坐标的初始化方式：不保持网格朝向的不良参数化相当常见，会使这样求得的几何法向量朝向错误。
]

#parec[
  We therefore initialize the geometric normal using the normalized cross product of the edge vectors `dp02` and `dp12`, which results in the same normal up to a potential sign difference that depends on the exact order of triangle vertices (also known as the triangle’s winding order).#footnote[This computation implicitly assumes a counterclockwise vertex ordering.] 3D modeling packages generally try to ensure that triangles in a mesh have consistent winding orders, which makes this approach more robust.
][
  因此，我们用边向量 `dp02` 与 `dp12` 的叉积归一化来初始化几何法向量。所得法向量相同，但符号可能不同，取决于三角形顶点的具体顺序，即顶点绕序。#footnote[这一计算隐含地假定顶点按逆时针顺序排列。]三维建模软件通常会尽量保证网格内各三角形的绕序一致，因此这种方法更稳健。
]
#block(sticky: true)[#raw("<<Override surface normal in isect for triangle>>=")] <fragment-Overridesurfacenormalinmonoisectfortriangle-0>
```cpp
isect.n = isect.shading.n = Normal3f(Normalize(Cross(dp02, dp12)));
if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    isect.n = isect.shading.n = -isect.n;
```
#parec[
  With `Triangle`s, the user can provide normal vectors and tangent vectors at the vertices of the mesh that are interpolated to give normals and tangents at points on the faces of triangles. Shading geometry with interpolated normals can make otherwise faceted triangle meshes appear to be smoother than they geometrically are. If either shading normals or shading tangents have been provided, they are used to initialize the shading geometry in the `SurfaceInteraction`.
][
  对于三角形，用户可以提供逐顶点法向量与切向量，再通过插值得到三角形面上各点的法向量和切向量。用插值法向量构造着色几何，可以使原本棱面分明的网格看起来比实际几何更平滑。只要提供了着色法向量或切向量，就会用它们初始化 `SurfaceInteraction` 的着色几何。
]
#block(sticky: true)[#raw("<<Initialize Triangle shading geometry>>=")] <fragment-InitializemonoTriangleshadinggeometry-0>
```cpp
<<Compute shading normal ns for triangle>>
<<Compute shading tangent ss for triangle>>
<<Compute shading bitangent ts for triangle and adjust ss>>
<<Compute ∂n/∂u and ∂n/∂v for triangle shading geometry>>
isect.SetShadingGeometry(ns, ss, ts, dndu, dndv, true);
```
#parec[
  Given the barycentric coordinates of the intersection point, it is easy to compute the shading normal by interpolating among the appropriate vertex normals, if present.
][
  给定交点的重心坐标后，若存在逐顶点法向量，就可以对它们插值得到着色法向量。
]
#block(sticky: true)[#raw("<<Compute shading normal ns for triangle>>=")] <fragment-Computeshadingnormalmononsfortriangle-0>
```cpp
Normal3f ns;
if (mesh->n) {
    ns = ti.b0 * mesh->n[v[0]] + ti.b1 * mesh->n[v[1]] + ti.b2 * mesh->n[v[2]];
    ns = LengthSquared(ns) > 0 ? Normalize(ns) : isect.n;
} else
    ns = isect.n;
```
#parec[
  The shading tangent is computed similarly.
][
  着色切向量的计算方式类似。
]
#block(sticky: true)[#raw("<<Compute shading tangent ss for triangle>>=")] <fragment-Computeshadingtangentmonossfortriangle-0>
```cpp
Vector3f ss;
if (mesh->s) {
    ss = ti.b0 * mesh->s[v[0]] + ti.b1 * mesh->s[v[1]] + ti.b2 * mesh->s[v[2]];
    if (LengthSquared(ss) == 0)
        ss = isect.dpdu;
} else
    ss = isect.dpdu;
```
#parec[
  The bitangent vector `ts` is found using the cross product of `ns` and `ss`, giving a vector orthogonal to the two of them. Next, `ss` is overwritten with the cross product of `ts` and `ns`; this ensures that the cross product of `ss` and `ts` gives `ns`. Thus, if per-vertex $bold(n)$ and $bold(s)$ values are provided and if the interpolated $bold(n)$ and $bold(s)$ values are not perfectly orthogonal, $bold(n)$ will be preserved and $bold(s)$ will be modified so that the coordinate system is orthogonal.
][
  副切向量 `ts` 由 `ns` 与 `ss` 的叉积得到，因此与二者正交。随后用 `ts` 与 `ns` 的叉积替换 `ss`，以使 `ss` 与 `ts` 的叉积给出 `ns`。因此，如果提供了逐顶点 $bold(n)$ 与 $bold(s)$，而插值后的二者不完全正交，则保留 $bold(n)$，调整 $bold(s)$，使坐标系正交。
]
#block(sticky: true)[#raw("<<Compute shading bitangent ts for triangle and adjust ss>>=")] <fragment-Computeshadingbitangentmonotsfortriangleandadjustmonoss-0>
```cpp
Vector3f ts = Cross(ns, ss);
if (LengthSquared(ts) > 0)
    ss = Cross(ts, ns);
else
    CoordinateSystem(ns, &ss, &ts);
```
#parec[
  The code to compute the partial derivatives $frac(∂bold(n), ∂u)$ and $frac(∂bold(n), ∂v)$ of the shading normal is almost identical to the code to compute the partial derivatives $frac(∂p, ∂u)$ and $frac(∂p, ∂v)$. Therefore, it has been elided from the text here.
][
  计算着色法向量偏导数 $frac(∂bold(n), ∂u)$ 与 $frac(∂bold(n), ∂v)$ 的代码，与计算位置偏导数 $frac(∂p, ∂u)$ 和 $frac(∂p, ∂v)$ 的代码几乎相同，因此正文不再列出。
]

=== #ez_caption[Sampling][采样]
<triangle-sampling>

#parec[
  The uniform area triangle sampling method is based on mapping the provided random sample `u` to barycentric coordinates that are uniformly distributed over the triangle.
][
  三角形的均匀面积采样方法，将给定随机样本 `u` 映射为在三角形上均匀分布的重心坐标。
]
#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-4>
```cpp
pstd::optional<ShapeSample> Sample(Point2f u) const {
    <<Get triangle vertices in p0, p1, and p2>>
    <<Sample point on triangle uniformly by area>>
    <<Compute surface normal for sampled point on triangle>>
    <<Compute (u, v) for sampled point on triangle>>
    <<Compute error bounds pError for sampled point on triangle>>
    return ShapeSample{Interaction(Point3fi(p, pError), n, uvSample),
                       1 / Area()};
}
```
#parec[
  Uniform barycentric sampling is provided via a stand-alone utility function (to be described shortly), which makes it easier to reuse this functionality elsewhere.
][
  独立工具函数提供均匀重心采样，稍后将介绍其实现；这样便于其他代码复用这一功能。
]
#block(sticky: true)[#raw("<<Sample point on triangle uniformly by area>>=")] <fragment-Samplepointontriangleuniformlybyarea-0>
```cpp
pstd::array<Float, 3> b = SampleUniformTriangle(u);
Point3f p = b[0] * p0 + b[1] * p1 + b[2] * p2;
```
#parec[
  As with `Triangle::NormalBounds()`, the surface normal of the sampled point is affected by the orientation of the shading normal, if present.
][
  与 `Triangle::NormalBounds()` 一样，如果提供了着色法向量，其朝向也会影响采样点的表面法向量。
]
#block(sticky: true)[#raw("<<Compute surface normal for sampled point on triangle>>=")] <fragment-Computesurfacenormalforsampledpointontriangle-0>
```cpp
Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));
if (mesh->n) {
    Normal3f ns(b[0] * mesh->n[v[0]] + b[1] * mesh->n[v[1]] +
                (1 - b[0] - b[1]) * mesh->n[v[2]]);
    n = FaceForward(n, ns);
} else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    n *= -1;
```
#parec[
  The $(u,v)$ coordinates for the sampled point are also found with barycentric interpolation.
][
  采样点的 $(u,v)$ 坐标同样通过重心插值得到。
]
#block(sticky: true)[#raw("<<Compute (u, v) for sampled point on triangle>>=")] <fragment-Computeuvforsampledpointontriangle-0>
```cpp
<<Get triangle texture coordinates in uv array>>
Point2f uvSample = b[0] * uv[0] + b[1] * uv[1] + b[2] * uv[2];
```
#parec[
  Because barycentric interpolation is linear, it can be shown that if we can find barycentric coordinates that uniformly sample a specific triangle, then those barycentrics can be used to uniformly sample any triangle. To derive the sampling algorithm, we will therefore consider the case of uniformly sampling a unit right triangle. Given a uniform sample in $[0,1)^2$ that we would like to map to the triangle, the task can also be considered as finding an area-preserving mapping from the unit square to the unit triangle.
][
  重心插值是线性的，因此，只要找到能均匀采样某个特定三角形的重心坐标，同样的坐标就能用于均匀采样任意三角形。为推导算法，我们只需考虑单位直角三角形。将 $[0,1)^2$ 中的均匀样本映射到三角形，也可视为寻找从单位正方形到单位三角形的保面积映射。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f15.svg"), caption: [#ez_caption[Samples from the unit square can be mapped to the unit right triangle by reflecting across the $x+y=1$ diagonal, though doing so causes far away samples on the square to map to nearby points on the triangle.][沿 $x+y=1$ 的对角线反射，可以把单位正方形中的样本映射到单位直角三角形，但这会使正方形上相距很远的样本落到三角形上彼此接近的位置。]]) <triangle-sampling-fold>

#parec[
  A straightforward approach is suggested by @fig:triangle-sampling-fold: the unit square could be folded over onto itself, such that samples that are on the side of the diagonal that places them outside the triangle are reflected across the diagonal to be inside it. While this would provide a valid sampling technique, it is undesirable since it causes samples that were originally far away in $[0,1)^2$ to be close together on the triangle. (For example, $(0.01,0.01)$ and $(0.99,0.99)$ in the unit square would both map to the same point in the triangle.) The effect would be that sampling techniques that generate well-distributed uniform samples such as those discussed in Chapter 8 were less effective at reducing error.
][
  @fig:triangle-sampling-fold 给出了一种直接方法：将单位正方形沿对角线折叠，把三角形外侧的样本反射到内部。虽然这样采样有效，却会让 $[0,1)^2$ 中原本相距很远的样本在三角形上彼此接近。例如，$(0.01,0.01)$ 与 $(0.99,0.99)$ 会映射到同一点。这会削弱第8章那些生成分布良好的均匀样本的方法降低误差的能力。
]

#parec[
  A better mapping translates points along the diagonal by a varying amount that brings the two opposite sides of the unit square to the triangle’s diagonal.
][
  更好的映射沿对角线方向将各点平移不同距离，使单位正方形的两条相对边落到三角形的斜边上。
]

$ f(xi_1,xi_2)=(xi_1-delta,xi_2-delta), quad "where" quad delta=cases(xi_1/2 & "if" xi_1<xi_2, xi_2/2 & "otherwise"). $

#parec[
  The determinant of the Jacobian matrix for this mapping is a constant and therefore this mapping is area preserving and uniformly distributed samples in the unit square are uniform in the triangle. (Recall Section 2.4.1, which presented the mathematics of transforming samples from one domain to the other; there it was shown that if the Jacobian of the transformation is constant, the mapping is area-preserving.)
][
  这个映射的雅可比行列式为常数，因此保持面积比例：单位正方形中的均匀样本在三角形中仍均匀分布。2.4.1节介绍过采样域变换的数学依据，以及雅可比为常数时的面积保持性质。
]
#block(sticky: true)[#raw("<<Sampling Inline Functions>>+=")] <fragment-SamplingInlineFunctions-11>
```cpp
pstd::array<Float, 3> SampleUniformTriangle(Point2f u) {
    Float b0, b1;
    if (u[0] < u[1]) {
        b0 = u[0] / 2;
        b1 = u[1] - b0;
    } else {
        b1 = u[1] / 2;
        b0 = u[0] - b1;
    }
    return {b0, b1, 1 - b0 - b1};
}
```
#parec[
  The usual normalization constraint gives the PDF in terms of the triangle’s surface area.
][
  由通常的归一化约束，可以用三角形的表面积表示 PDF。
]
#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-5>
```cpp
Float PDF(const Interaction &) const { return 1 / Area(); }
```
#parec[
  In order to sample points on spheres with respect to solid angle from a reference point, we derived a specialized sampling method that only sampled from the potentially visible region of the sphere. For the cylinder and disk, we just sampled uniformly by area and rescaled the PDF to account for the change of measure from area to solid angle. It is tempting to do the same for triangles (and, indeed, all three previous editions of this book did so), but going through the work to apply a solid angle sampling approach can lead to much better results.
][
  前面为球体推导了相对于参考点的立体角采样方法，只采样球体上可能可见的区域。对于圆柱和圆盘，则先按面积均匀采样，再换算 PDF 的测度。三角形也可以这样处理，本书前三版正是如此；不过，专门实现立体角采样能获得更好的结果。
]

#parec[
  To see why, consider a simplified form of the reflection integral from the scattering equation, @eqt:scattering-equation:
][
  为理解原因，考虑散射方程 @eqt:scattering-equation 中反射积分的一种简化形式：
]

$ integral_(cal(S)^2) rho L_(i)(p,omega_i) abs(cos theta_i) thin d omega_i , $

#parec[
  where the BRDF $f$ has been replaced with a constant $rho$, which corresponds to a diffuse surface. If we consider the case of incident radiance only coming from a triangular light source that emits uniform diffuse radiance $L_e$, then we can rewrite this integral as
][
  其中用常数 $rho$ 替代 BRDF $f$，对应漫反射表面。如果入射辐亮度仅来自发射均匀漫射辐亮度 $L_e$ 的三角形光源，可将积分改写为
]

$ rho L_e integral_(cal(S)^2) V(p,omega_i) abs(cos theta_i) thin d omega_i , $

#parec[
  where $V$ is a visibility function that is 1 if the ray from $p$ in direction $omega_i$ hits the light source and 0 if it misses or is occluded by another object. If we sample the triangle uniformly within the solid angle that it subtends from the reference point, we end up with the estimator
][
  其中可见性函数 $V$ 在从 $p$ 沿 $omega_i$ 发出的射线命中光源时为1，未命中或被其他物体遮挡时为0。在三角形相对于参考点所张的立体角内均匀采样，得到估计量
]

$ frac(rho L_e, 1/A_("solid")) (V(p,omega_i) abs(cos theta prime)) , $

#parec[
  where $A_("solid")$ is the subtended solid angle. The constant values have been pulled out, leaving just the two factors in parentheses that vary based on $p$. They are the only source of variance in estimates of the integral.
][
  其中 $A_("solid")$ 是所张的立体角。提出常数后，只剩括号内随 $p$ 变化的两个因子，它们是积分估计中仅有的方差来源。
]

#parec[
  As an alternative, consider a Monte Carlo estimate of this function where a point $p prime$ has been uniformly sampled on the surface of the triangle. If the triangle’s area is $A$, then the PDF is $p(p prime)=1/A$. Applying the standard Monte Carlo estimator and defining a new visibility function $V$ that is between two points, we end up with
][
  也可以在三角形表面均匀采样点 $p prime$。若面积为 $A$，则其 PDF 为 $p(p prime)=1/A$。应用标准蒙特卡洛估计量，并将 $V$ 改为两点之间的可见性函数，得到
]

$ frac(rho L_e,1/A) (V(p,p prime) abs(cos theta prime) frac(abs(cos theta_l),norm(p prime-p)^2)) , $

#parec[
  where the last factor accounts for the change of variables and where $cos theta_l$ is the angle between the light source’s surface normal and the vector between the two points. The values of the four factors inside the parentheses in this estimator all depend on the choice of $p prime$.
][
  最后一个因子来自变量变换，原文用 $cos theta_l$ 描述光源表面法向量与两点间向量的夹角。这一估计量括号中的四个因子都随 $p prime$ 的选择变化。
]

#parec[
  With area sampling, the $abs(cos theta_l)$ factor adds some additional variance, though not too much, since it is between 0 and 1. However, $1/norm(p prime-p)^2$ can have unbounded variation over the surface of the triangle, which can lead to high variance in the estimator since the method used to sample $p prime$ does not account for it at all. This variance increases the larger the triangle is and the closer the reference point is to it. @fig:solid-angle-triangle-sampling-win shows a scene where solid angle sampling significantly reduces error.
][
  面积采样中的 $abs(cos theta_l)$ 位于0与1之间，因此增加的方差较有限。但 $1/norm(p prime-p)^2$ 在三角形表面可能变化极大，而采样 $p prime$ 时完全没有考虑它，从而可能产生很高的方差。三角形越大、参考点越近，这种方差越大。@fig:solid-angle-triangle-sampling-win 展示了立体角采样显著降低误差的场景。
]

#figure(image("../pbr-book-website/4ed/Shapes/tri-sample-image.png"), caption: [#ez_caption[A Scene Where Solid Angle Triangle Sampling Is Beneficial. When points on triangles are sampled using uniform area sampling, error is high at points on the ground close to the emitter. If points are sampled on the triangle by uniformly sampling the solid angle the triangle subtends, then the remaining non-constant factors in the estimator are both between 0 and 1, which results in much lower error. For this scene, mean squared error (MSE) is reduced by a factor of 3.86. (Dragon model courtesy of the Stanford Computer Graphics Laboratory.)][立体角三角形采样有益的场景。均匀面积采样在靠近光源的地面位置误差很大。改为在三角形所张的立体角内均匀采样后，估计量中其余非常数因子都位于0与1之间，误差明显降低。本例的 MSE 降至原来的1/3.86。（龙模型由斯坦福计算机图形实验室提供。）]]) <solid-angle-triangle-sampling-win>

#parec[
  The `Triangle::Sample()` method that takes a reference point therefore samples a point according to solid angle.
][
  因此，接收参考点的 `Triangle::Sample()` 方法按立体角采样形状上的点。
]
#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-6>
```cpp
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx,
                                   Point2f u) const {
    <<Get triangle vertices in p0, p1, and p2>>
    <<Use uniform area sampling for numerically unstable cases>>
    <<Sample spherical triangle from reference point>>
    <<Compute error bounds pError for sampled point on triangle>>
    <<Return ShapeSample for solid angle sampled point on triangle>>
}
```
#parec[
  Triangles that subtend a very small solid angle as well as ones that cover nearly the whole hemisphere can encounter problems with floating-point accuracy in the following solid angle sampling approach. The sampling method falls back to uniform area sampling in those cases, which does not hurt results in practice: for very small triangles, the various additional factors tend not to vary as much over the triangle’s area. `pbrt` also samples the BSDF as part of the direct lighting calculation, which is an effective strategy for large triangles, so uniform area sampling is fine in that case as well.
][
  对于所张立体角很小或几乎覆盖整个半球的三角形，下面的立体角采样可能出现浮点精度问题，此时回退到均匀面积采样。实践中这不会损害结果：小三角形上额外因子的变化通常较小；对于大三角形，直接光照计算同时采用的 BSDF 采样很有效，因此面积采样也可接受。
]
#block(sticky: true)[#raw("<<Use uniform area sampling for numerically unstable cases>>=")] <fragment-Useuniformareasamplingfornumericallyunstablecases-0>
```cpp
Float solidAngle = SolidAngle(ctx.p());
if (solidAngle < MinSphericalSampleArea ||
    solidAngle > MaxSphericalSampleArea) {
    <<Sample shape by area and compute incident direction wi>>
    <<Convert area sampling PDF in ss to solid angle measure>>
    return ss;
}
```
#block(sticky: true)[#raw("<<Triangle Private Members>>+=")] <fragment-TrianglePrivateMembers-1>
```cpp
static constexpr Float MinSphericalSampleArea = 3e-4;
static constexpr Float MaxSphericalSampleArea = 6.22;
```
#parec[
  `pbrt` also includes an approximation to the effect of the $abs(cos theta prime)$ factor in its triangle sampling algorithm, which leaves visibility and error in that approximation as the only sources of variance. We will defer discussion of the fragment that handles that, ⟨Apply warp product sampling for cosine factor at reference point⟩, until after we have discussed the uniform solid angle sampling algorithm. For now we will note that it affects the final sampling PDF, which turns out to be the product of the PDF for uniform solid angle sampling of the triangle and a correction factor.
][
  `pbrt` 的三角形采样还近似考虑 $abs(cos theta prime)$，因此方差只来自可见性和这一近似的误差。相应的 ⟨Apply warp product sampling for cosine factor at reference point⟩ 片段将在均匀立体角采样之后介绍。这里只需注意，最终 PDF 是三角形均匀立体角采样 PDF 与一个修正因子的乘积。
]

#parec[
  Uniform sampling of the solid angle that a triangle subtends is equivalent to uniformly sampling the spherical triangle that results from its projection on the unit sphere (recall Section 3.8.2). Spherical triangle sampling is implemented in a separate function described shortly, `SampleSphericalTriangle()`, that returns the barycentric coordinates for the sampled point.
][
  均匀采样三角形所张的立体角，等价于均匀采样它投影到单位球面后形成的球面三角形（参见3.8.2节）。独立函数 `SampleSphericalTriangle()` 实现这一采样，返回采样点的重心坐标，稍后将介绍。
]
#block(sticky: true)[#raw("<<Sample spherical triangle from reference point>>=")] <fragment-Samplesphericaltrianglefromreferencepoint-0>
```cpp
<<Apply warp product sampling for cosine factor at reference point>>
Float triPDF;
pstd::array<Float, 3> b =
    SampleSphericalTriangle({p0, p1, p2}, ctx.p(), u, &triPDF);
if (triPDF == 0) return {};
pdf *= triPDF;
```
#parec[
  Given the barycentric coordinates, it is simple to compute the sampled point. With that as well as the surface normal, computed by reusing a fragment from the other triangle sampling method, we have everything necessary to return a `ShapeSample`.
][
  由重心坐标可以直接计算采样点，再复用另一个三角形采样方法中的片段求法向量，便得到返回 `ShapeSample` 所需的全部信息。
]
#block(sticky: true)[#raw("<<Return ShapeSample for solid angle sampled point on triangle>>=")] <fragment-ReturnmonoShapeSampleforsolidanglesampledpointontriangle-0>
```cpp
Point3f p = b[0] * p0 + b[1] * p1 + b[2] * p2;
<<Compute surface normal for sampled point on triangle>>
<<Compute (u, v) for sampled point on triangle>>
return ShapeSample{Interaction(Point3fi(p, pError), n, ctx.time, uvSample),
                   pdf};
```
#figure(image("../pbr-book-website/4ed/Shapes/pha06f17.svg"), caption: [#ez_caption[Geometric Setting for Spherical Triangles. Given vertices $bold(a)$, $bold(b)$, and $bold(c)$, the respective opposite edges are labeled $overline(bold(a))$, $overline(bold(b))$, and $overline(bold(c))$ and the interior angles are labeled with Greek letters $alpha$, $beta$, and $gamma$.][球面三角形的几何设置。顶点为 $bold(a)$、$bold(b)$、$bold(c)$，各自的对边记为 $overline(bold(a))$、$overline(bold(b))$、$overline(bold(c))$，内角记为 $alpha$、$beta$、$gamma$。]]) <spherical-triangle-setting>

#parec[
  The spherical triangle sampling function takes three triangle vertices `v`, a reference point `p`, and a uniform sample `u`. The value of the PDF for the sampled point is optionally returned via `pdf`, if it is not `nullptr`. @fig:spherical-triangle-setting shows the geometric setting.
][
  球面三角形采样函数接收三个顶点 `v`、参考点 `p` 和均匀样本 `u`。若 `pdf` 不为 `nullptr`，还通过它返回采样点的 PDF。几何设置见 @fig:spherical-triangle-setting 。
]
#block(sticky: true)[#raw("<<Sampling Function Definitions>>=")] <fragment-SamplingFunctionDefinitions-0>
```cpp
pstd::array<Float, 3> SampleSphericalTriangle(
      const pstd::array<Point3f, 3> &v, Point3f p, Point2f u, Float *pdf) {
    <<Compute vectors a, b, and c to spherical triangle vertices>>
    <<Compute normalized cross products of all direction pairs>>
    <<Find angles alpha , beta , and gamma at spherical triangle vertices>>
    <<Uniformly sample triangle area A to compute A′ >>
    <<Find cos beta′ for point along b for sampled area>>
    <<Sample c prime along the arc between a and c >>
    <<Compute sampled spherical triangle direction and return barycentrics>>
}
```
#parec[
  Given the reference point, it is easy to project the vertices on the unit sphere to find the spherical triangle vertices $bold(a)$, $bold(b)$, and $bold(c)$.
][
  给定参考点后，将顶点投影到单位球面，就得到球面三角形的顶点 $bold(a)$、$bold(b)$、$bold(c)$。
]
#block(sticky: true)[#raw("<<Compute vectors a, b, and c to spherical triangle vertices>>=")] <fragment-Computevectorsmonoamonobandmonoctosphericaltrianglevertices-0>
```cpp
Vector3f a(v[0] - p), b(v[1] - p), c(v[2] - p);
a = Normalize(a);
b = Normalize(b);
c = Normalize(c);
```
#parec[
  Because the plane containing an edge also passes through the origin, we can compute the plane normal for an edge from $bold(a)$ to $bold(b)$ as
][
  包含某条边的平面也经过原点，因此从 $bold(a)$ 到 $bold(b)$ 的边所在平面的法向量为
]

$ bold(n)_("ab") = frac(bold(a) times bold(b), norm(bold(a) times bold(b))) , $

#parec[
  and similarly for the other edges. If any of these normals are degenerate, then the triangle has zero area.
][
  其他边同理。如果任一法向量退化，则三角形面积为零。
]
#block(sticky: true)[#raw("<<Compute normalized cross products of all direction pairs>>=")] <fragment-Computenormalizedcrossproductsofalldirectionpairs-0>
```cpp
Vector3f n_ab = Cross(a, b), n_bc = Cross(b, c), n_ca = Cross(c, a);
if (LengthSquared(n_ab) == 0 || LengthSquared(n_bc) == 0 ||
    LengthSquared(n_ca) == 0)
    return {};
n_ab = Normalize(n_ab);
n_bc = Normalize(n_bc);
n_ca = Normalize(n_ca);
```
#parec[
  Given the pairs of plane normals, `AngleBetween()` gives the angles between them. In computing these angles, we can take advantage of the fact that the plane normal for the edge between two vertices $bold(b)$ and $bold(a)$ is the negation of the plane normal for the edge from $bold(a)$ to $bold(b)$.
][
  `AngleBetween()` 可以求出成对平面法向量之间的夹角。计算时可利用：从 $bold(b)$ 到 $bold(a)$ 的边所在平面的法向量，是反向边 $bold(a)$ 到 $bold(b)$ 对应法向量的相反数。
]
#block(sticky: true)[#raw("<<Find angles alpha , beta , and gamma at spherical triangle vertices>>=")] <fragment-Findanglesalphabetaandgammaatsphericaltrianglevertices-0>
```cpp
Float alpha = AngleBetween(n_ab, -n_ca);
Float beta  = AngleBetween(n_bc, -n_ab);
Float gamma = AngleBetween(n_ca, -n_bc);
```
#parec[
  The spherical triangle sampling algorithm operates in two stages. The first step uniformly samples a new triangle with area $A prime$ between 0 and the area of the original spherical triangle $A$ using the first sample: $A prime=xi_0 A$. This triangle is defined by finding a new vertex $bold(c) prime$ along the arc between $bold(a)$ and $bold(c)$ such that the resulting triangle $bold(a) bold(b) bold(c) prime$ has area $A prime$ (see @fig:spherical-triangle-sampling(a)).
][
  球面三角形采样分两步。首先用第一个样本，在0与原球面三角形面积 $A$ 之间均匀采样新面积 $A prime=xi_0 A$，然后在 $bold(a)$ 与 $bold(c)$ 间的弧上寻找新顶点 $bold(c) prime$，使新三角形 $bold(a) bold(b) bold(c) prime$ 的面积为 $A prime$（见 @fig:spherical-triangle-sampling(a)）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f18.svg"), caption: [#ez_caption[(a) After sampling a triangle area, the first step of the sampling algorithm finds the vertex $bold(c) prime$ that gives a spherical triangle $bold(a) bold(b) bold(c) prime$ with that area. The vertices $bold(a)$ and $bold(b)$ and the edge $overline(bold(c))$ are shared with the original triangle. (b) Given $bold(c) prime$, a direction $omega$ is sampled along the arc between $bold(b)$ and $bold(c) prime$.][(a) 采样面积后，算法第一步找到顶点 $bold(c) prime$，使球面三角形 $bold(a) bold(b) bold(c) prime$ 具有该面积。顶点 $bold(a)$、$bold(b)$ 及边 $overline(bold(c))$ 与原三角形共用。(b) 给定 $bold(c) prime$，沿 $bold(b)$ 与 $bold(c) prime$ 间的弧采样方向 $omega$。]]) <spherical-triangle-sampling>

#parec[
  In the second step, a vertex $omega$ is sampled along the arc between $bold(b)$ and $bold(c) prime$ with sampling density that is relatively lower near $bold(b)$ and higher near $bold(c) prime$; the result is a uniform distribution of points inside the spherical triangle (@fig:spherical-triangle-sampling(b)). (The need for a nonuniform density along the arc can be understood by considering the arcs $bold(b) bold(c) prime$ as $bold(c) prime$ sweeps from $bold(a)$ to $bold(c)$: the velocity of a point on the arc increases the farther away from $bold(b)$ and so the density of sampled points along a given arc must be adjusted accordingly.)
][
  第二步沿 $bold(b)$ 与 $bold(c) prime$ 间的弧采样 $omega$：靠近 $bold(b)$ 的密度较低，靠近 $bold(c) prime$ 的密度较高，最终在球面三角形内部得到均匀点分布（见 @fig:spherical-triangle-sampling(b)）。可以这样理解非均匀弧密度的必要性：当 $bold(c) prime$ 从 $bold(a)$ 扫向 $bold(c)$ 时，弧 $bold(b) bold(c) prime$ 上的点离 $bold(b)$ 越远，运动速度越大，因此需相应调整弧上的采样密度。
]

#parec[
  Our implementation makes a small modification to the algorithm as described so far: rather than computing the triangle’s spherical area $A$ and then sampling an area uniformly between 0 and $A$, it instead starts by computing its area plus $pi$, which we will denote by $A_pi$. Doing so lets us avoid the subtraction of $pi$ from the sum of the interior angles that is present in the spherical triangle area equation, (3.5). For very small triangles, where $alpha+beta+gamma approx pi$, the subtraction of $pi$ can cause a significant loss of floating-point accuracy. The remainder of the algorithm’s implementation is then adjusted to be based on $A'_pi$ in order to avoid needing to perform the subtraction.
][
  实现作了一处小调整：先计算面积加 $pi$，记为 $A_pi$，而非直接计算面积 $A$ 再在0到 $A$ 之间采样。这能避免球面三角形面积公式(3.5)中从内角和减去 $pi$ 的操作。对于很小的三角形，$alpha+beta+gamma approx pi$，这一相减会损失大量浮点精度；因此后续实现也改用 $A'_pi$，避免该减法。
]

#parec[
  Given $A_pi$, the sampled area-plus-$pi$ $A'_pi$ is easily computed by uniformly sampling between $pi$ and $A_pi$. The returned PDF value can be initialized at this point; because the algorithm samples uniformly in the triangle’s solid angle, the probability density function takes the constant value of one over the solid angle the triangle subtends, which is its spherical area. (For that, the value of $pi$ must be subtracted.)
][
  给定 $A_pi$ 后，在 $pi$ 与 $A_pi$ 之间均匀采样，就得到 $A'_pi$。此时也可以初始化 PDF：由于在三角形立体角内均匀采样，其密度是立体角即球面面积的倒数。（计算 PDF 时仍需减去 $pi$。）
]
#block(sticky: true)[#raw("<<Uniformly sample triangle area A to compute A′ >>=")] <fragment-UniformlysampletriangleareaAtocomputeA-0>
```cpp
Float A_pi = alpha + beta + gamma;
Float Ap_pi = Lerp(u[0], Pi, A_pi);
if (pdf) {
    Float A = A_pi - Pi;
    *pdf = (A <= 0) ? 0 : 1 / A;
}
```
#parec[
  At this point, we need to determine more values related to the sampled triangle. We have the vertices $bold(a)$ and $bold(b)$, the edge $overline(bold(c))$, and the angle $alpha$ all unchanged from the given triangle. The area-plus-$pi$ of the sampled triangle $A'_pi$ is known, but we do not have the vertex $bold(c) prime$, the edges $overline(bold(b)) prime$ or $overline(bold(a)) prime$, or the angles $beta prime$ or $gamma prime$.
][
  接下来需确定新三角形的其他量。顶点 $bold(a)$、$bold(b)$、边 $overline(bold(c))$ 和角 $alpha$ 与原三角形相同，$A'_pi$ 也已知，但顶点 $bold(c) prime$、边 $overline(bold(b)) prime$、$overline(bold(a)) prime$ 及角 $beta prime$、$gamma prime$ 尚未知。
]

#parec[
  To find the vertex $bold(c) prime$, it is sufficient to find the length of the arc $overline(bold(b)) prime$. In this case, $cos(overline(bold(b)) prime)$ will do, since $0 <= overline(bold(b)) prime < pi$. The first step is to apply one of the spherical cosine laws, which gives the equality
][
  求出弧 $overline(bold(b)) prime$ 的长度，就能确定顶点 $bold(c) prime$。由于 $0 <= overline(bold(b)) prime < pi$，知道其余弦已足够。首先应用球面余弦定律，得到
]

$ cos beta prime = -cos gamma prime cos alpha + sin gamma prime sin alpha cos(overline(bold(b)) prime) . $ <spherical-tri-cos-betap>

#parec[
  Although we do not know $gamma prime$, we can apply the definition of $A'_pi$,
][
  虽然 $gamma prime$ 未知，但由 $A'_pi$ 的定义，
]

$ A'_pi=alpha+beta prime+gamma prime , $

#parec[
  to express $gamma prime$ in terms of quantities that are either known or are $beta prime$:
][
  可用已知量及 $beta prime$ 表示 $gamma prime$：
]

$ gamma prime=A'_pi-alpha-beta prime . $

#parec[
  Substituting this equality in @eqt:spherical-tri-cos-betap and solving for $cos(overline(bold(b)) prime)$ gives
][
  代入 @eqt:spherical-tri-cos-betap 并求解 $cos(overline(bold(b)) prime)$，得到
]

$ cos(overline(bold(b)) prime)=frac(cos beta prime+cos(A'_pi-alpha-beta prime) cos alpha,sin(A'_pi-alpha-beta prime) sin alpha) . $

#parec[
  Defining $phi=A'_pi-alpha$ to simplify notation, we have
][
  令 $phi=A'_pi-alpha$ 以简化记号，有
]

$ cos(overline(bold(b)) prime)=frac(cos beta prime+cos(phi-beta prime) cos alpha,sin(phi-beta prime) sin alpha) . $

#parec[
  The cosine and sine sum identities then give
][
  由正弦与余弦的和差公式，得到
]

$ cos(overline(bold(b)) prime)=frac(cos beta prime+(cos phi cos beta prime+sin phi sin beta prime) cos alpha,(sin phi cos beta prime-cos phi sin beta prime) sin alpha) . $ <sph-tri-cos-bbar>

#parec[
  The only remaining unknowns on the right hand side are the sines and cosines of $beta prime$. To find $sin beta prime$ and $cos beta prime$, we can use another spherical cosine law, which gives the equality
][
  右侧仅剩 $beta prime$ 的正弦与余弦未知。用另一条球面余弦定律可得
]

$ cos gamma prime=-cos beta prime cos alpha+sin beta prime sin alpha cos(overline(bold(c))) . $

#parec[
  It can be simplified in a similar manner to find the equation
][
  用类似方法化简，得到
]

$ 0=(cos phi+cos alpha) cos beta prime+(sin phi-sin alpha cos(overline(bold(c)))) sin beta prime . $

#parec[
  The terms in parentheses are all known. We will denote them by $k_1=cos phi+cos alpha$ and $k_2=sin phi-sin alpha cos(overline(bold(c)))$. It is then easy to see that solutions to the equation
][
  括号中的项均已知，分别记为 $k_1=cos phi+cos alpha$ 和 $k_2=sin phi-sin alpha cos(overline(bold(c)))$。容易看出方程
]

$ 0=k_1 cos beta prime+k_2 sin beta prime $

#parec[
  are given by
][
  的解为
]

$ cos beta prime=frac(plus.minus k_2,sqrt(k_1^2+k_2^2)) quad "and" quad sin beta prime=frac(minus.plus k_1,sqrt(k_1^2+k_2^2)) . $

#parec[
  Substituting these into @eqt:sph-tri-cos-bbar, taking the solution with a positive cosine, and simplifying gives
][
  将这些解代入 @eqt:sph-tri-cos-bbar，取余弦为正的解并化简，得到
]

$ cos(overline(bold(b)) prime)=frac(k_2+(k_2 cos phi-k_1 sin phi) cos alpha,(k_2 sin phi+k_1 cos phi) sin alpha) , $

#parec[
  which finally has only known values on the right hand side. The code to compute this cosine follows directly from this solution. In it, we have also applied trigonometric identities to compute $sin phi$ and $cos phi$ in terms of other sines and cosines.
][
  此时右侧终于全部为已知量。代码可直接由此解得到，其中也利用三角恒等式，用其他正弦和余弦值计算 $sin phi$ 与 $cos phi$。
]
#block(sticky: true)[#raw("<<Find cos beta′ for point along b for sampled area>>=")] <fragment-Findcosbetaforpointalongmonobforsampledarea-0>
```cpp
Float cosAlpha = std::cos(alpha), sinAlpha = std::sin(alpha);
Float sinPhi = std::sin(Ap_pi) * cosAlpha - std::cos(Ap_pi) * sinAlpha;
Float cosPhi = std::cos(Ap_pi) * cosAlpha + std::sin(Ap_pi) * sinAlpha;
Float k1 = cosPhi + cosAlpha;
Float k2 = sinPhi - sinAlpha * Dot(a, b) /* cos c */;
Float cosBp =
    (k2 + (DifferenceOfProducts(k2, cosPhi, k1, sinPhi)) * cosAlpha) /
    ((SumOfProducts(k2, sinPhi, k1, cosPhi)) * sinAlpha);
cosBp = Clamp(cosBp, -1, 1);
```
#parec[
  The arc of the great circle between the two points $bold(a)$ and $bold(c)$ can be parameterized by $cos theta bold(a)+sin theta bold(c)_⊥$, where $bold(c)_⊥$ is the normalized perpendicular component of $bold(c)$ with respect to $bold(a)$. This vector is given by the `GramSchmidt()` function introduced earlier, which makes the computation of $bold(c) prime$ straightforward. In this case, $sin(overline(bold(b)) prime)$ can then be found using $cos(overline(bold(b)) prime)$ with the Pythagorean identity, since we know that it must be nonnegative.
][
  $bold(a)$ 与 $bold(c)$ 之间的大圆弧可参数化为 $cos theta bold(a)+sin theta bold(c)_⊥$。其中 $bold(c)_⊥$ 是 $bold(c)$ 相对于 $bold(a)$ 的垂直分量归一化后的结果，可借助前面介绍的 `GramSchmidt()` 求得，因此容易计算 $bold(c) prime$。这里 $sin(overline(bold(b)) prime)$ 必须非负，可由其余弦通过勾股恒等式求出。
]
#block(sticky: true)[#raw("<<Sample c prime along the arc between a and c >>=")] <fragment-Samplecalongthearcbetweenaandc-0>
```cpp
Float sinBp = SafeSqrt(1 - Sqr(cosBp));
Vector3f cp = cosBp * a + sinBp * Normalize(GramSchmidt(c, a));
```
#parec[
  For the sample points to be uniformly distributed in the spherical triangle, it can be shown that if the edge from $bold(b)$ to $bold(c) prime$ is parameterized using $theta$ in the same way as was used for the edge from $bold(a)$ to $bold(c)$, then $cos theta$ should be sampled as
][
  可以证明，要使样本在球面三角形内均匀分布，若沿用 $bold(a)$ 到 $bold(c)$ 的参数化方式，以 $theta$ 参数化 $bold(b)$ 到 $bold(c) prime$ 的弧，则应这样采样 $cos theta$：
]

$ cos theta=1-xi_1(1-(bold(c) prime dot bold(b))) . $ <spherical-triangle-arc-sample>

#parec[
  (The “Further Reading” section has pointers to the details.) With that, we can compute the final sampled direction $omega$. The remaining step is to compute the barycentric coordinates for the sampled direction.
][
  “延伸阅读”提供了推导细节的资料线索。由此可求得最终采样方向 $omega$；接下来只需计算对应的重心坐标。
]
#block(sticky: true)[#raw("<<Compute sampled spherical triangle direction and return barycentrics>>=")] <fragment-Computesampledsphericaltriangledirectionandreturnbarycentrics-0>
```cpp
Float cosTheta = 1 - u[1] * (1 - Dot(cp, b));
Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
Vector3f w = cosTheta * b + sinTheta * Normalize(GramSchmidt(cp, b));
<<Find barycentric coordinates for sampled direction w>>
<<Return clamped barycentrics for sampled direction>>
```
#parec[
  The barycentric coordinates of the corresponding point in the planar triangle can be found using part of a ray–triangle intersection algorithm that finds the barycentrics along the way (Möller and Trumbore #source-cite("Moller97")). It starts with equating the parametric form of the ray with the barycentric interpolation of the triangle’s vertices $bold(v)_i$,
][
  平面三角形上对应点的重心坐标，可借用 Möller 和 Trumbore（#source-cite("Moller97")）的射线与三角形求交算法的一部分求得。首先将射线的参数形式与三角形顶点 $bold(v)_i$ 的重心插值相等，
]

$ bold(o)+t bold(d)=(1-b_0-b_1) bold(v)_0+b_1 bold(v)_1+b_2 bold(v)_2 , $

#parec[
  expressing this as a matrix equation, and solving the resulting linear system for the barycentrics. The solution is implemented in the following fragment, which includes the result of factoring out various common subexpressions.
][
  然后写成矩阵方程，求解线性系统得到重心坐标。下面的实现提取了若干公共子表达式。
]
#block(sticky: true)[#raw("<<Find barycentric coordinates for sampled direction w>>=")] <fragment-Findbarycentriccoordinatesforsampleddirectionmonow-0>
```cpp
Vector3f e1 = v[1] - v[0], e2 = v[2] - v[0];
Vector3f s1 = Cross(w, e2);
Float divisor = Dot(s1, e1);
Float invDivisor = 1 / divisor;
Vector3f s = p - v[0];
Float b1 = Dot(s, s1) * invDivisor;
Float b2 = Dot(w, Cross(s, e1)) * invDivisor;
```
#parec[
  The computed barycentrics may be invalid for very small and very large triangles. This happens rarely, but to protect against it, they are clamped to be within the triangle before they are returned.
][
  对于很小或很大的三角形，计算出的重心坐标偶尔可能无效。为防范这种情况，返回前会将它们限制在三角形内部。
]
#block(sticky: true)[#raw("<<Return clamped barycentrics for sampled direction>>=")] <fragment-Returnclampedbarycentricsforsampleddirection-0>
```cpp
b1 = Clamp(b1, 0, 1);
b2 = Clamp(b2, 0, 1);
if (b1 + b2 > 1) {
    b1 /= b1 + b2;
    b2 /= b1 + b2;
}
return {Float(1 - b1 - b2), Float(b1), Float(b2)};
```
#parec[
  As noted earlier, uniform solid angle sampling does not account for the incident cosine factor at the reference point. Indeed, there is no known analytic method to do so. However, it is possible to apply a warping function to the uniform samples `u` that approximately accounts for this factor.
][
  如前所述，均匀立体角采样没有考虑参考点处的入射余弦因子，目前也没有已知的解析采样方法。但可以先对均匀样本 `u` 进行变换，近似计入这个因子。
]

#parec[
  To understand the idea, first note that $cos theta$ varies smoothly over the spherical triangle. Because the spherical triangle sampling algorithm that we have just defined maintains a continuous relationship between sample values and points in the triangle, then if we consider the image of the $cos theta$ function back in the $[0,1]^2$ sampling domain, as would be found by mapping it through the inverse of the spherical triangle sampling algorithm, the $cos theta$ function is smoothly varying there as well. (See @fig:spherical-triangle-cosine-domain.)
][
  先注意，$cos theta$ 在球面三角形上平滑变化。刚才的采样算法保持样本值与三角形上各点之间的连续关系，因此通过其逆映射把 $cos theta$ 拉回 $[0,1]^2$ 采样域后，该函数在那里也平滑变化（见 @fig:spherical-triangle-cosine-domain）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f19.svg"), caption: [#ez_caption[(a) The $cos theta$ factor varies smoothly over the area of a spherical triangle. (b) If it is mapped back to the $[0,1]^2$ sampling domain, it also varies smoothly there, thanks to the sampling algorithm not introducing any discontinuities or excessive distortion.][(a) $cos theta$ 因子在球面三角形上平滑变化。(b) 映射回 $[0,1]^2$ 采样域后仍然平滑，因为采样算法没有引入不连续或过度畸变。]]) <spherical-triangle-cosine-domain>

#parec[
  It can be shown through simple application of the chain rule that a suitable transformation of uniform $[0,1]^2$ sample points can account for the $cos theta$ factor. Specifically, if transformed points are distributed according to the distribution of $cos theta$ in $[0,1]^2$ and then used with the spherical triangle sampling algorithm, then the distribution of directions on the sphere will include the $cos theta$ factor.
][
  简单应用链式法则可知，适当变换 $[0,1]^2$ 中的均匀样本，就能计入 $cos theta$ 因子。具体而言，若变换后的点按照该因子在 $[0,1]^2$ 中的分布采样，再输入球面三角形采样算法，球面方向的分布就会包含这个因子。
]

#parec[
  The true function has no convenient analytic form, but because it is smoothly varying, here we will approximate it with a bilinear function. Each corner of the $[0,1]^2$ sampling domain maps to one of the three vertices of the spherical triangle, and so we set the bilinear function’s value at each corner according to the $cos theta$ factor computed at the associated triangle vertex.
][
  真实函数没有便于使用的解析形式，但因其平滑，这里用双线性函数近似。采样域 $[0,1]^2$ 的每个角点都映射到球面三角形的某个顶点，因此用对应顶点的 $cos theta$ 设置双线性函数的角点值。
]

#parec[
  Sampling a point in the triangle then proceeds by using the initial uniform sample to sample the bilinear distribution and to use the resulting nonuniform point in $[0,1]^2$ with the triangle sampling algorithm. (See @fig:spherical-triangle-approx-cos.)
][
  然后，先用初始均匀样本采样双线性分布，再将所得 $[0,1]^2$ 中的非均匀点输入三角形采样算法（见 @fig:spherical-triangle-approx-cos）。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f20.svg"), caption: [#ez_caption[If (a) uniform sample points are warped to (b) approximate the distribution of the incident cosine factor in $[0,1]^2$ before being used with the spherical triangle sampling algorithm, then (c) the resulting points in the triangle are approximately cosine-distributed.][先将(a)均匀样本变换为(b)近似服从 $[0,1]^2$ 中入射余弦因子分布的样本，再输入球面三角形采样算法，得到的(c)三角形内样本就近似服从余弦分布。]]) <spherical-triangle-approx-cos>

#parec[
  Applying the principles of transforming between distributions that were introduced in Section 2.4.1, we can find that the overall PDF of such a sample is given by the product of the PDF for the bilinear sample and the PDF of the spherical triangle sample. This technique is only applied for reference points on surfaces. For points in scattering media, the surface normal `ShapeSampleContext::ns` is degenerate and no sample warping is applied.
][
  由2.4.1节介绍的分布变换原理，最终 PDF 是双线性采样 PDF 与球面三角形采样 PDF 的乘积。这一技术只用于表面上的参考点；散射介质中的点没有有效的 `ShapeSampleContext::ns`，因此不进行样本变换。
]
#block(sticky: true)[#raw("<<Apply warp product sampling for cosine factor at reference point>>=")] <fragment-Applywarpproductsamplingforcosinefactoratreferencepoint-0>
```cpp
Float pdf = 1;
if (ctx.ns != Normal3f(0, 0, 0)) {
    <<Compute cos theta -based weights w at sample domain corners>>
    u = SampleBilinear(u, w);
    pdf = BilinearPDF(u, w);
}
```
#parec[
  For the spherical triangle sampling algorithm, the vertex `v0` corresponds to the sample $(0,1)$, `v1` to $(0,0)$ and $(1,0)$ (and the line in between), and `v2` to $(1,1)$. Therefore, the sampling weights at the corners of the $[0,1]^2$ domain are computed using the cosine of the direction to the corresponding vertex.
][
  该球面三角形采样算法将样本 $(0,1)$ 映射到 `v0`，将 $(0,0)$、$(1,0)$ 及二者间的整条线映射到 `v1`，将 $(1,1)$ 映射到 `v2`。因此，采样域角点处的权重由指向相应顶点的方向余弦计算。
]
#block(sticky: true)[#raw("<<Compute cos theta -based weights w at sample domain corners>>=")] <fragment-Computecostheta-basedweightsmonowatsampledomaincorners-0>
```cpp
Point3f rp = ctx.p();
Vector3f wi[3] = {Normalize(p0 - rp), Normalize(p1 - rp),
                  Normalize(p2 - rp)};
pstd::array<Float, 4> w =
    pstd::array<Float, 4>{std::max<Float>(0.01, AbsDot(ctx.ns, wi[1])),
                          std::max<Float>(0.01, AbsDot(ctx.ns, wi[1])),
                          std::max<Float>(0.01, AbsDot(ctx.ns, wi[0])),
                          std::max<Float>(0.01, AbsDot(ctx.ns, wi[2]))};
```
#parec[
  The associated `PDF()` method is thankfully much simpler than the sampling routine.
][
  相应的 `PDF()` 方法比采样例程简单得多。
]
#block(sticky: true)[#raw("<<Triangle Public Methods>>+=")] <fragment-TrianglePublicMethods-7>
```cpp
Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const {
    Float solidAngle = SolidAngle(ctx.p());
    <<Return PDF based on uniform area sampling for challenging triangles>>
    Float pdf = 1 / solidAngle;
    <<Adjust PDF for warp product sampling of triangle cos theta factor>>
    return pdf;
}
```
#parec[
  It is important that the `PDF()` method makes exactly the same decisions about which technique is used to sample the triangle as the `Sample()` method does. This method therefore starts with the same check for very small and very large triangles to determine whether it should fall back to returning the PDF based on uniform area sampling.
][
  `PDF()` 必须与 `Sample()` 对采样方法作出完全相同的选择。因此，它首先使用相同阈值检查很小和很大的三角形，以决定是否返回均匀面积采样对应的 PDF。
]
#block(sticky: true)[#raw("<<Return PDF based on uniform area sampling for challenging triangles>>=")] <fragment-ReturnPDFbasedonuniformareasamplingforchallengingtriangles-0>
```cpp
if (solidAngle < MinSphericalSampleArea ||
    solidAngle > MaxSphericalSampleArea) {
    <<Intersect sample ray with shape geometry>>
    <<Compute PDF in solid angle measure from shape intersection point>>
    return pdf;
}
```
#parec[
  If `Sample()` would have warped the initial uniform random sample to account for the incident $cos theta$ factor, it is necessary to incorporate the corresponding change of variables factor in the returned PDF here. To do so, we need to be able to invert the spherical triangle sampling algorithm in order to determine the sample value `u` that samples a point on the triangle that gives the incident direction `wi` at the reference point. The `InvertSphericalTriangleSample()` function performs this computation.
][
  如果 `Sample()` 为考虑入射 $cos theta$ 而变换了初始均匀样本，这里的 PDF 就必须包含对应的变量变换因子。为此，需要逆转球面三角形采样，求出产生参考点处方向 `wi` 的样本值 `u`。`InvertSphericalTriangleSample()` 完成这一计算。
]
#block(sticky: true)[#raw("<<Adjust PDF for warp product sampling of triangle cos theta factor>>=")] <fragment-AdjustPDFforwarpproductsamplingoftrianglecosthetafactor-0>
```cpp
if (ctx.ns != Normal3f(0, 0, 0)) {
    <<Get triangle vertices in p0, p1, and p2>>
    Point2f u = InvertSphericalTriangleSample({p0, p1, p2}, ctx.p(), wi);
    <<Compute cos theta -based weights w at sample domain corners>>
    pdf *= BilinearPDF(u, w);
}
```
#parec[
  The pair of sample values that give a sampled direction $omega$ can be found by inverting each of the sampling operations individually. The function that performs this computation starts out with a few reused fragments to compute the angles at the three vertices of the spherical triangle.
][
  分别逆转两步采样，即可求出产生方向 $omega$ 的一对样本值。相应函数先复用几个片段，计算球面三角形三个顶点处的内角。
]
#block(sticky: true)[#raw("<<Sampling Function Definitions>>+=")] <fragment-SamplingFunctionDefinitions-1>
```cpp
Point2f InvertSphericalTriangleSample(const pstd::array<Point3f, 3> &v,
                                      Point3f p, Vector3f w) {
    <<Compute vectors a, b, and c to spherical triangle vertices>>
    <<Compute normalized cross products of all direction pairs>>
    <<Find angles alpha , beta , and gamma at spherical triangle vertices>>
    <<Find vertex c′ along a c arc for omega >>
    <<Invert uniform area sampling to find u0>>
    <<Invert arc sampling to find u1 and return result>>
}
```
#parec[
  Next, it finds the vertex $bold(c) prime$ along the arc between $bold(a)$ and $bold(c)$ that defines the subtriangle that would have been sampled when sampling $omega$. This vertex can be found by computing the intersection of the great circle defined by $bold(b)$ and $omega$ and the great circle defined by $bold(a)$ and $bold(c)$; see @fig:invert-spherical-triangle-sample.
][
  接着，在 $bold(a)$ 与 $bold(c)$ 之间的弧上找到 $bold(c) prime$，从而确定采样 $omega$ 时所选的子三角形。这个顶点是经过 $bold(b)$、$omega$ 的大圆与经过 $bold(a)$、$bold(c)$ 的大圆的交点，见 @fig:invert-spherical-triangle-sample 。
]

#figure(image("../pbr-book-website/4ed/Shapes/pha06f21.svg"), caption: [#ez_caption[Given a spherical triangle $bold(a) bold(b) bold(c)$ and a direction $omega$ that is inside it, the vertex $bold(c) prime$ along the edge from $bold(a)$ to $bold(c)$ can be found from the intersection of the great circle that passes through $bold(b)$ and $omega$ and the great circle that passes through $bold(a)$ and $bold(c)$.][给定球面三角形 $bold(a) bold(b) bold(c)$ 及其内部方向 $omega$，经过 $bold(b)$、$omega$ 的大圆与经过 $bold(a)$、$bold(c)$ 的大圆的交点，给出 $bold(a)$ 到 $bold(c)$ 这条边上的顶点 $bold(c) prime$。]]) <invert-spherical-triangle-sample>

#parec[
  Recall from Section 3.8.2 that the great circle passing through two points on the sphere is given by the intersection of the sphere with a plane passing through the origin and those two points. Therefore, we can find the intersection between the two corresponding planes, which is a line. In 3D, the cross product of the plane normals gives this line’s direction. This line intersects the sphere at two points and so it is necessary to choose the one of them that is between $bold(a)$ and $bold(c)$.
][
  根据3.8.2节，经过球面两点的大圆是球面与经过原点及这两点的平面的交线。因此，可先求对应两平面的交线；三维中，两平面法向量的叉积给出交线方向。它与球面相交于两点，需要选取位于 $bold(a)$ 与 $bold(c)$ 之间的那个。
]
#block(sticky: true)[#raw("<<Find vertex c′ along a c arc for omega >>=")] <fragment-FindvertexVECcalongVECaVECcarcforw-0>
```cpp
Vector3f cp = Normalize(Cross(Cross(b, w), Cross(c, a)));
if (Dot(cp, a + c) < 0)
    cp = -cp;
```
#parec[
  Given $bold(c) prime$, it is easy to compute the area of the triangle $bold(a) bold(b) bold(c) prime$; the ratio of that area to the original area gives the first sample value `u0`. However, it is necessary to be aware of the case where $bold(a)$ and $bold(c) prime$ are nearly coincident; in that case, computation of the angle $gamma prime$ may have high error, sometimes to the point that the subtriangle $bold(a) bold(b) bold(c) prime$ seems to have larger area than the original triangle $bold(a) bold(b) bold(c)$. That case is caught with a dot product test.
][
  给定 $bold(c) prime$ 后，可计算子三角形 $bold(a) bold(b) bold(c) prime$ 的面积；其与原面积的比值就是第一个样本值 `u0`。但当 $bold(a)$ 与 $bold(c) prime$ 几乎重合时，$gamma prime$ 的计算误差可能很大，甚至使子三角形看起来比原三角形面积更大。代码用点积测试识别这种情况。
]
#block(sticky: true)[#raw("<<Invert uniform area sampling to find u0>>=")] <fragment-Invertuniformareasamplingtofindmonou0-0>
```cpp
Float u0;
if (Dot(a, cp) > 0.99999847691f /* 0.1 degrees */)
    u0 = 0;
else {
    <<Compute area A′ of subtriangle>>
    <<Compute sample u0 that gives the area A′ >>
}
```
#parec[
  Otherwise, the area of the subtriangle $A prime$ is computed using Girard’s theorem.
][
  其他情况下，用 Girard 定理计算子三角形面积 $A prime$。
]
#block(sticky: true)[#raw("<<Compute area A′ of subtriangle>>=")] <fragment-ComputeareaAofsubtriangle-0>
```cpp
Vector3f n_cpb = Cross(cp, b), n_acp = Cross(a, cp);
if (LengthSquared(n_cpb) == 0 || LengthSquared(n_acp) == 0)
    return Point2f(0.5, 0.5);
n_cpb = Normalize(n_cpb);
n_acp = Normalize(n_acp);
Float Ap =
    alpha + AngleBetween(n_ab, n_cpb) + AngleBetween(n_acp, -n_cpb) - Pi;
```
#parec[
  The first sample value is then easily found given these two areas.
][
  由这两个面积，即可得到第一个样本值。
]
#block(sticky: true)[#raw("<<Compute sample u0 that gives the area A′ >>=")] <fragment-Computesamplemonou0thatgivestheareaA-0>
```cpp
Float A = alpha + beta + gamma - Pi;
u0 = Ap / A;
```
#parec[
  The sampling method for choosing $omega$ along the arc through $bold(b)$ and $bold(c) prime$, @eqt:spherical-triangle-arc-sample, is also easily inverted.
][
  沿经过 $bold(b)$ 和 $bold(c) prime$ 的弧采样 $omega$ 的方法，也可直接逆转，见 @eqt:spherical-triangle-arc-sample 。
]
#block(sticky: true)[#raw("<<Invert arc sampling to find u1 and return result>>=")] <fragment-Invertarcsamplingtofindmonou1andreturnresult-0>
```cpp
Float u1 = (1 - Dot(w, b)) / (1 - Dot(cp, b));
return Point2f(Clamp(u0, 0, 1), Clamp(u1, 0, 1));
```
#parec[
  Source notes: the Euler–Poincaré paragraph says “edges and vertices” before $E=3F/2$, which actually relates edges and faces. The edge-function prose says positive on the right, while the formula and caption say positive on the left. The barycentric ray equation retains the source coefficient $(1-b_0-b_1)$, although with the displayed $b_1,b_2$ terms it should be $(1-b_1-b_2)$. The clamping code updates `b1` before using `b1+b2` again to update `b2`; it therefore does not always keep the sum at most 1. For example, initial `b1=b2=0.8` produces approximately 0.5 and 0.615. These source issues are recorded rather than silently changing the algorithm.
][
  原文校注：欧拉–庞加莱段在 $E=3F/2$ 前写“边与顶点”，实际关系涉及边与面；边函数正文称右侧为正，而公式和图注为左侧为正；射线重心方程保留源系数 $(1-b_0-b_1)$，但根据其后 $b_1,b_2$ 两项，应为 $(1-b_1-b_2)$。限制重心坐标的代码先修改 `b1`，再用已改变的 `b1+b2` 修改 `b2`，不能总保证两者之和不超过1；例如初值都为0.8时得到约0.5与0.615。这里明确记录源问题，不静默修改算法。
]

#parec[
  Additional source wording: the fragment title “Find cos beta prime” computes the cosine of the opposite arc $overline(bold(b)) prime$, not the interior angle $beta prime$. In the area-sampling explanation, $cos theta_l$ denotes the cosine of the angle rather than the angle itself. The source’s `LookUpOrAdd()` spelling differs from its code’s `LookupOrAdd()`.
][
  另外，片段标题“Find cos beta prime”实际计算对边弧 $overline(bold(b)) prime$ 的余弦，而非内角 $beta prime$ 的余弦。面积采样说明中的 $cos theta_l$ 是夹角的余弦，并非夹角本身。原文 `LookUpOrAdd()` 的大小写也与代码 `LookupOrAdd()` 不一致。
]

#include "supplements/6.5-expanded.typ"
