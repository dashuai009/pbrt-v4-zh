#import "../template.typ": parec, ez_caption

== Triangle Meshes
<triangle-meshes>


#parec[
  The triangle is one of the most commonly used shapes in computer graphics; complex scenes may be modeled using millions of triangles to achieve great detail. (@fig:trimesh-ganesha shows an image of a complex triangle mesh of over four million triangles.)
][
  三角形是计算机图形学中最常用的形状之一；复杂的场景可以使用数百万个三角形来建模，以实现极高的细节。（@fig:trimesh-ganesha 显示了一个由超过四百万个三角形组成的复杂三角网格的图像。）
]


#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f11.svg"),
  caption: [
    #parec[
      *Ganesha Model. *This triangle mesh contains over four million individual triangles. It was created from a real statue using a 3D scanner that uses structured light to determine shapes of objects.
    ][
      *Ganesha 模型。*该三角形网格包含超过四百万个独立的三角形。它是通过 3D 扫描仪从真实雕像创建的，该扫描仪使用结构光来确定物体的形状。
    ]
  ],
)<trimesh-ganesha>

#parec[
  While a natural representation would be to have a `Triangle` shape implementation where each triangle stored the positions of its three vertices, a more memory-efficient representation is to separately store entire triangle meshes with an array of vertex positions where each individual triangle just stores three offsets into this array for its three vertices. To see why this is the case, consider the celebrated Euler-Poincaré formula, which relates the number of vertices V, edges E, and faces F on closed discrete meshes as
][
  虽然一种自然的表示方法是实现一个`Triangle`形状，其中每个三角形存储其三个顶点的位置，但一种更节省内存的表示方法是将整个三角网格的顶点位置存储在一个数组中，每个单独的三角形只存储其三个顶点在该数组中的三个偏移量。 要理解为什么这是可行的，可以考虑著名的欧拉-庞加莱公式，它将闭合离散网格上的顶点数V、边数E和面数F联系起来：
]

$ V - E + F = 2(1 - g), $


#parec[
  where $g in N$ is the _genus_ of the mesh.
][
  其中 $g in N$ 是网格的_亏格_。
]

#parec[
  The genus is usually a small number and can be interpreted as the number of "handles" in the mesh (analogous to a handle of a teacup). On a triangle mesh, the number of edges and faces is furthermore related by the identity
][
  亏格通常是一个比较小的数值，可以解释为网格中的“把手”数量（类似于茶杯的把手）。在三角网格中，边数和面数还通过以下恒等式相关联：
]

$ E = 3 / 2 F $


#parec[
  This can be seen by dividing each edge into two parts associated with the two adjacent triangles. There are 3F such half-edges, and all colocated pairs constitute the E mesh edges. For large closed triangle meshes, the overall effect of the genus usually becomes negligible and we can combine the previous two equations (with $g = 0$ ) to obtain
][
  这可以通过将每条边分成与两个相邻三角形相关的两部分来看到。有3F个这样的半边，所有共置的对构成E网格边。 对于大型闭合三角网格，亏格的总体影响通常变得可以忽略不计，我们可以结合前两个方程（取 $g
  \= 0$ ）得到
]

$ F approx 2V $

#parec[
  In other words, there are approximately twice as many faces as vertices. Since each face references three vertices, every vertex is (on average) referenced a total of six times. Thus, when vertices are shared, the total amortized storage required per triangle will be 12 bytes of memory for the offsets (at 4 bytes for three 32-bit integer offsets) plus half of the storage for one vertex—6 bytes, assuming three 4-byte floats are used to store the vertex position—for a total of 18 bytes per triangle. This is much better than the 36 bytes per triangle that storing the three positions directly would require. The relative storage savings are even better when there are per-vertex surface normals or texture coordinates in a mesh.
][
  换句话说，面的数量大约是顶点数量的两倍。由于每个面引用三个顶点，每个顶点（平均）被引用六次。 因此，当顶点被共享时，每个三角形所需的总摊销存储为12字节的索引（每个32位整数为4字节，共三个索引）加上一个顶点存储的一半——6字节，假设使用三个4字节的浮点数来存储顶点位置。总共为每个三角形18字节。 这比直接存储三个位置所需的每个三角形36字节要好得多。当网格中有关联到顶点的表面法线或纹理坐标时，相对存储节省甚至更好。
]


=== Mesh Representation and Storage
<mesh-representation-and-storage>
#parec[
  `pbrt` uses the #link("<TriangleMesh>")[`TriangleMesh`] class to store the shared information about a triangle mesh. It is defined in the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.h")[`util/mesh.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.cpp")[`util/mesh.cpp`];.
][
  `pbrt` 使用 #link("<TriangleMesh>")[`TriangleMesh`] 类来存储三角网格的共享信息。它在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.h")[`util/mesh.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/util/mesh.cpp")[`util/mesh.cpp`] 中定义。
]

```cpp
class TriangleMesh {
  public:
    // <<TriangleMesh Public Methods>>
    TriangleMesh(const Transform &renderFromObject, bool reverseOrientation,
                    std::vector<int> vertexIndices, std::vector<Point3f> p,
                    std::vector<Vector3f> S, std::vector<Normal3f> N,
                    std::vector<Point2f> uv, std::vector<int> faceIndices,
                    Allocator alloc);

       std::string ToString() const;

       bool WritePLY(std::string filename) const;

       static void Init(Allocator alloc);
    // <<TriangleMesh Public Members>>
    int nTriangles, nVertices;
       const int *vertexIndices = nullptr;
       const Point3f *p = nullptr;
       const Normal3f *n = nullptr;
       const Vector3f *s = nullptr;
       const Point2f *uv = nullptr;
       bool reverseOrientation, transformSwapsHandedness;
};
```

#parec[
  In addition to the mesh vertex positions and vertex indices, per-vertex normals `n`, tangent vectors `s`, and texture coordinates `uv` may be provided. The corresponding vectors should be empty if there are no such values or should be the same size as `p` otherwise.
][
  除了网格顶点位置和顶点索引外，还可以提供每个顶点的法线 `n`、切线向量 `s` 和纹理坐标 `uv`。如果没有这些值，相应的向量应为空；否则，各个数组大小应与 `p` 相同。
]

```cpp
TriangleMesh::TriangleMesh(
        const Transform &renderFromObject, bool reverseOrientation,
        std::vector<int> indices, std::vector<Point3f> p,
        std::vector<Vector3f> s, std::vector<Normal3f> n,
        std::vector<Point2f> uv, std::vector<int> faceIndices, Allocator alloc)
    : nTriangles(indices.size() / 3), nVertices(p.size()) {
    // <<Initialize mesh vertexIndices>>
    vertexIndices = intBufferCache->LookupOrAdd(indices, alloc);
    // <<Transform mesh vertices to rendering space and initialize mesh p>>
    for (Point3f &pt : p)
           pt = renderFromObject(pt);
       this->p = point3BufferCache->LookupOrAdd(p, alloc);
    // <<Remainder of TriangleMesh constructor>>
    this->reverseOrientation = reverseOrientation;
       this->transformSwapsHandedness = renderFromObject.SwapsHandedness();

       if (!uv.empty()) {
           CHECK_EQ(nVertices, uv.size());
           this->uv = point2BufferCache->LookupOrAdd(uv, alloc);
       }
       if (!n.empty()) {
           CHECK_EQ(nVertices, n.size());
           for (Normal3f &nn : n) {
               nn = renderFromObject(nn);
               if (reverseOrientation)
                   nn = -nn;
           }
           this->n = normal3BufferCache->LookupOrAdd(n, alloc);
       }
       if (!s.empty()) {
           CHECK_EQ(nVertices, s.size());
           for (Vector3f &ss : s)
               ss = renderFromObject(ss);
           this->s = vector3BufferCache->LookupOrAdd(s, alloc);
       }

       if (!faceIndices.empty()) {
           CHECK_EQ(nTriangles, faceIndices.size());
           this->faceIndices = intBufferCache->LookupOrAdd(faceIndices, alloc);
       }

       // Make sure that we don't have too much stuff to be using integers to index into things.
       CHECK_LE(p.size(), std::numeric_limits<int>::max());
       // We could be clever and check indices.size() / 3 if we were careful
       // to promote to a 64-bit int before multiplying by 3 when we look up
       // in the indices array...
       CHECK_LE(indices.size(), std::numeric_limits<int>::max());
}
```

#parec[
  The mesh data is made available via public member variables; as with things like coordinates of points or rays' directions, there would be little benefit and some bother from information hiding in this case.
][
  网格数据通过公共成员变量提供；就像点的坐标或射线的方向一样，在这种情况下，设为pravite变量几乎没有好处，反而会带来一些麻烦。
]

```cpp
// <<TriangleMesh Public Members>>=
int nTriangles, nVertices;
const int *vertexIndices = nullptr;
const Point3f *p = nullptr;
```


#parec[
  Although its constructor takes `std::vector` parameters, `TriangleMesh` stores plain pointers to its data arrays. The `vertexIndices` pointer points to `3 * nTriangles` values, and the per-vertex pointers, if not `nullptr`, point to `nVertices` values.
][
  尽管其构造函数接受 `std::vector` 参数，`TriangleMesh` 仍然将其数据数组存储为普通指针。`vertexIndices` 指针指向 `3 * nTriangles` 个值，而每个顶点的指针（如果不是 `nullptr`）指向 `nVertices` 个值。
]

#parec[
  We chose this design so that different `TriangleMesh`es could potentially point to the same arrays in memory in the case that they were both given the same values for some or all of their parameters. Although `pbrt` offers capabilities for object instancing, where multiple copies of the same geometry can be placed in the scene with different transformation matrices (e.g., via the #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive] that is described in @object-instancing-and-primitives-in-Motion), the scenes provided to it do not always make full use of this capability. For example, with the landscape scene in @fig:ecosys-dof and #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fig:ecosys-instancing")[7.2];, over 400 MB is saved from detecting such redundant arrays.
][
  我们选择这种设计是为了使不同的 `TriangleMesh` 能够在某些或所有参数都相同的情况下，可能指向内存中的相同数组。尽管 `pbrt` 提供了对象实例化的功能，可以在场景中使用不同的变换矩阵放置同一几何体的多个副本（例如，通过 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#TransformedPrimitive")[TransformedPrimitive];，在@object-instancing-and-primitives-in-Motion 中描述），但提供给它的场景并不总是充分利用这一功能。 例如，在@fig:ecosys-dof 和 #link("../Primitives_and_Intersection_Acceleration/Primitive_Interface_and_Geometric_Primitives.html#fig:ecosys-instancing")[7.2] 的景观场景中，通过检测此类冗余数组节省了超过 400 MB。
]

#parec[
  The #link("<BufferCache>")[BufferCache] class handles the details of storing a single unique copy of each buffer provided to it. Its `LookupOrAdd()` method, to be defined shortly, takes a `std::vector` of the type it manages and returns a pointer to memory that stores the same values.
][
  #link("<BufferCache>")[BufferCache] 类用来存储每个Buffer数据的唯一副本。它的 `LookupOrAdd()` 方法（稍后定义）的输入是它管理的类型的 `std::vector`，并返回一个指向存储相同值的内存的指针。
]

```cpp
vertexIndices = intBufferCache->LookupOrAdd(indices, alloc);
```

#parec[
  The `BufferCache`s are made available through global variables in the `pbrt` namespace. Additional ones, not included here, handle normals, tangent vectors, and texture coordinates.
][
  `BufferCache` 通过 `pbrt` 命名空间中的全局变量提供。这里未包含的其他变量处理法线、切线向量和纹理坐标。
]

```cpp
extern BufferCache<int> *intBufferCache;
extern BufferCache<Point3f> *point3BufferCache;
```


#parec[
  The `BufferCache` class is templated based on the array element type that it stores.
][
  `BufferCache` 类是基于它存储的数组元素类型的模板类。
]

```cpp
template <typename T> class BufferCache {
  public:
    // <<BufferCache Public Methods>>
    const T *LookupOrAdd(pstd::span<const T> buf, Allocator alloc) {
           // <<Return pointer to data if buf contents are already in the cache>>
           Buffer lookupBuffer(buf.data(), buf.size());
              int shardIndex = uint32_t(lookupBuffer.hash) >> (32 - logShards);
              mutex[shardIndex].lock_shared();
              if (auto iter = cache[shardIndex].find(lookupBuffer);
                  iter != cache[shardIndex].end()) {
                  const T *ptr = iter->ptr;
                  mutex[shardIndex].unlock_shared();
                  return ptr;
              }
           // <<Add buf contents to cache and return pointer to cached copy>>
           mutex[shardIndex].unlock_shared();
              T *ptr = alloc.allocate_object<T>(buf.size());
              std::copy(buf.begin(), buf.end(), ptr);
              mutex[shardIndex].lock();
              // <<Handle the case of another thread adding the buffer first>>
              if (auto iter = cache[shardIndex].find(lookupBuffer);
                     iter != cache[shardIndex].end()) {
                     const T *cachePtr = iter->ptr;
                     mutex[shardIndex].unlock();
                     alloc.deallocate_object(ptr, buf.size());
                     return cachePtr;
                 }
              cache[shardIndex].insert(Buffer(ptr, buf.size()));
              mutex[shardIndex].unlock();
              return ptr;
       }
       size_t BytesUsed() const { return bytesUsed; }
  private:
    // <<BufferCache::Buffer Definition>>
    struct Buffer {
           // <<BufferCache::Buffer Public Methods>>
           Buffer(const T *ptr, size_t size) : ptr(ptr), size(size) {
                  hash = HashBuffer(ptr, size);
              }
              bool operator==(const Buffer &b) const {
                  return size == b.size && hash == b.hash &&
                         std::memcmp(ptr, b.ptr, size * sizeof(T)) == 0;
              }
           const T *ptr = nullptr;
           size_t size = 0, hash;
       };
    // <<BufferCache::BufferHasher Definition>>
    struct BufferHasher {
           size_t operator()(const Buffer &b) const {
               return b.hash;
           }
       };
    // <<BufferCache Private Members>>
    static constexpr int logShards = 6;
       static constexpr int nShards = 1 << logShards;
       std::shared_mutex mutex[nShards];
       std::unordered_set<Buffer, BufferHasher> cache[nShards];
};
```


#parec[
  `BufferCache` allows concurrent use by multiple threads so that multiple meshes can be added to the scene in parallel; the scene construction code in Appendix #link("../Processing_the_Scene_Description.html#chap:API")[C] takes advantage of this capability. While a single mutex could be used to manage access to it, contention over that mutex by multiple threads can inhibit concurrency, reducing the benefits of multi-threading. Therefore, the cache is broken into 64 independent #emph[shards];, each holding a subset of the entries. Each shard has its own mutex, allowing different threads to concurrently access different shards.
][
  `BufferCache` 允许多个线程同时使用，以便多个网格可以并行添加到场景中；附录 #link("../Processing_the_Scene_Description.html#chap:API")[C] 中的场景构建代码利用了这一并发功能。 虽然可以使用单个互斥锁来管理对它的访问，但多个线程对该互斥锁的争用会抑制并发，拖累多线程。因此，缓存被分成 64 个独立的#emph[分片];，每个分片保存一部分内容。 每个分片都有自己的互斥锁，允许不同的线程并发访问不同的分片。
]

```cpp
static constexpr int logShards = 6;
static constexpr int nShards = 1 << logShards;
std::shared_mutex mutex[nShards];
std::unordered_set<Buffer, BufferHasher> cache[nShards];
```


#parec[
  `Buffer` is a small helper class that wraps an allocation managed by the `BufferCache`.
][
  `Buffer` 是一个小的辅助类，用于包装由 `BufferCache` 管理的分配。
]

```cpp
struct Buffer {
    // <<BufferCache::Buffer Public Methods>>       Buffer(const T *ptr, size_t size) : ptr(ptr), size(size) {
           hash = HashBuffer(ptr, size);
       }
       bool operator==(const Buffer &b) const {
           return size == b.size && hash == b.hash &&
                  std::memcmp(ptr, b.ptr, size * sizeof(T)) == 0;
       }
    const T *ptr = nullptr;
    size_t size = 0, hash;
};
```


#parec[
  The `Buffer` constructor computes the buffer's hash, which is stored in a member variable.
][
  `Buffer` 构造函数会计算缓冲区的哈希值，并将其存储在成员变量中。
]

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

```cpp
const T *LookupOrAdd(pstd::span<const T> buf, Allocator alloc) {
    // <<Return pointer to data if buf contents are already in the cache>>
    Buffer lookupBuffer(buf.data(), buf.size());
    int shardIndex = uint32_t(lookupBuffer.hash) >> (32 - logShards);
    mutex[shardIndex].lock_shared();
    if (auto iter = cache[shardIndex].find(lookupBuffer);
        iter != cache[shardIndex].end()) {
        const T *ptr = iter->ptr;
        mutex[shardIndex].unlock_shared();
        return ptr;
    }
    // <<Add buf contents to cache and return pointer to cached copy>>
    mutex[shardIndex].unlock_shared();
    T *ptr = alloc.allocate_object<T>(buf.size());
    std::copy(buf.begin(), buf.end(), ptr);
    mutex[shardIndex].lock();
    // <<Handle the case of another thread adding the buffer first>>
    if (auto iter = cache[shardIndex].find(lookupBuffer);
        iter != cache[shardIndex].end()) {
        const T *cachePtr = iter->ptr;
        mutex[shardIndex].unlock();
        alloc.deallocate_object(ptr, buf.size());
        return cachePtr;
    }
    cache[shardIndex].insert(Buffer(ptr, buf.size()));
    mutex[shardIndex].unlock();
    return ptr;
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

```cpp
mutex[shardIndex].unlock_shared();
T *ptr = alloc.allocate_object<T>(buf.size());
std::copy(buf.begin(), buf.end(), ptr);
mutex[shardIndex].lock();
// <<Handle the case of another thread adding the buffer first>>
if (auto iter = cache[shardIndex].find(lookupBuffer);
       iter != cache[shardIndex].end()) {
       const T *cachePtr = iter->ptr;
       mutex[shardIndex].unlock();
       alloc.deallocate_object(ptr, buf.size());
       return cachePtr;
   }
cache[shardIndex].insert(Buffer(ptr, buf.size()));
mutex[shardIndex].unlock();
return ptr;
}
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
  Returning now to the `TriangleMesh` constructor, the vertex positions are processed next. Unlike the other shapes that leave the shape description in object space and then transform incoming rays from rendering space to object space, triangle meshes transform the shape into rendering space and thus save the work of transforming incoming rays into object space and the work of transforming the intersection's geometric representation out to rendering space. This is a good idea because this operation can be performed once at startup, avoiding transforming rays many times during rendering. Using this approach with quadrics is more complicated, although possible—see Exercise #link("../Shapes/Exercises.html#ex:shapes-exercise-quadrics")[6.8.8] at the end of the chapter.
][
  现在回到 `TriangleMesh` 构造函数，接下来处理顶点位置。与其他形状将形状描述保留在对象空间中，然后将传入的射线从渲染空间转换为对象空间不同，三角网格将形状转换为渲染空间，从而节省了将传入射线转换为对象空间以及将交点的几何表示转换为渲染空间的工作。 这是一个好主意，因为这个操作可以在启动时执行一次，避免在渲染期间多次转换射线。对二次曲线使用这种方法更为复杂，尽管可以实现——见本章末尾的练习 #link("../Shapes/Exercises.html#ex:shapes-exercise-quadrics")[6.8.8];。
]

#parec[
  The resulting points are also provided to the buffer cache, though after the rendering from object transformation has been applied. Because the positions were transformed to rendering space, this cache lookup is rarely successful. The hit rate would likely be higher if positions were left in object space, though doing so would require additional computation to transform vertex positions when they were accessed. Vertex indices and `uv` texture coordinates fare better with the buffer cache, however.
][
  结果点也提供给缓冲区缓存，不过是在应用了从对象到渲染的变换之后。由于位置已被转换为渲染空间，因此此缓存查找很少成功。 如果位置保留在对象空间中，命中率可能会更高，尽管这样做需要额外的计算来在访问顶点位置时进行转换。然而，顶点索引和 `uv` 纹理坐标在缓冲区缓存中表现更好。
]

```cpp
for (Point3f &pt : p)
    pt = renderFromObject(pt);
this->p = point3BufferCache->LookupOrAdd(p, alloc);
```


#parec[
  We will omit the remainder of the #link("<TriangleMesh>")[`TriangleMesh`] constructor, as handling the other per-vertex buffer types is similar to how the positions are processed. The remainder of its member variables are below. In addition to the remainder of the mesh vertex and face data, the `TriangleMesh` records whether the normals should be flipped by way of the values of `reverseOrientation` and `transformSwapsHandedness`. Because these two have the same value for all triangles in a mesh, memory can be saved by storing them once with the mesh itself rather than redundantly with each of the triangles.
][
  我们将省略 #link("<TriangleMesh>")[`TriangleMesh`] 构造函数的其余部分，因为处理其他每顶点缓冲区类型与处理位置的方式类似。 其余的成员变量如下。除了其余的网格顶点和面数据外，`TriangleMesh` 还记录了法线是否应该通过 `reverseOrientation` 和 `transformSwapsHandedness` 的值来翻转。 因为这两个值对于网格中的所有三角形都是相同的，所以通过将它们与网格本身一起存储而不是在每个三角形中重复存储，可以节省内存。
]

```cpp
const Normal3f *n = nullptr;
const Vector3f *s = nullptr;
const Point2f *uv = nullptr;
bool reverseOrientation, transformSwapsHandedness;
```


=== Triangle Class
<triangle-class>
#parec[
  The #link("<Triangle>")[Triangle] class actually implements the #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape] interface. It represents a single triangle.
][
  #link("<Triangle>")[Triangle] 类实际上实现了 #link("../Shapes/Basic_Shape_Interface.html#Shape")[Shape] 接口。它表示一个单独的三角形。
]

```cpp
class Triangle {
  public:
    // Triangle Public Methods
    static pstd::vector<Shape> CreateTriangles(const TriangleMesh *mesh, Allocator alloc);
    Triangle(int meshIndex, int triIndex) : meshIndex(meshIndex), triIndex(triIndex) {}
    static void Init(Allocator alloc);

    PBRT_CPU_GPU
    Bounds3f Bounds() const;

    PBRT_CPU_GPU
    pstd::optional<ShapeIntersection> Intersect(const Ray &ray, Float tMax = Infinity) const;
    PBRT_CPU_GPU
    bool IntersectP(const Ray &ray, Float tMax = Infinity) const;
    Float Area() const {
        // Get triangle vertices in p0, p1, and p2
        const TriangleMesh *mesh = GetMesh();
        const int *v = &mesh->vertexIndices[3 * triIndex];
        Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
        return 0.5f * Length(Cross(p1 - p0, p2 - p0));
    }
    PBRT_CPU_GPU
    DirectionCone NormalBounds() const;
    std::string ToString() const;
    static TriangleMesh *CreateMesh(const Transform *renderFromObject, bool reverseOrientation, const ParameterDictionary &parameters, const FileLoc *loc, Allocator alloc);
    Float SolidAngle(Point3f p) const {
        // Get triangle vertices in p0, p1, and p2
        const TriangleMesh *mesh = GetMesh();
        const int *v = &mesh->vertexIndices[3 * triIndex];
        Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
        return SphericalTriangleArea(Normalize(p0 - p), Normalize(p1 - p), Normalize(p2 - p));
    }
    static SurfaceInteraction InteractionFromIntersection(const TriangleMesh *mesh, int triIndex, TriangleIntersection ti, Float time, Vector3f wo) {
        const int *v = &mesh->vertexIndices[3 * triIndex];
        Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
        // Compute triangle partial derivatives
        // Compute deltas and matrix determinant for triangle partial derivatives
        // Get triangle texture coordinates in uv array
        pstd::array<Point2f, 3> uv = mesh->uv ? pstd::array<Point2f, 3>({mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]}) : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});
        Vector2f duv02 = uv[0] - uv[2], duv12 = uv[1] - uv[2];
        Vector3f dp02 = p0 - p2, dp12 = p1 - p2;
        Float determinant = DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
        Vector3f dpdu, dpdv;
        bool degenerateUV = std::abs(determinant) < 1e-9f;
        if (!degenerateUV) {
            // Compute triangle partial-differential normal p / partial-differential u and partial-differential normal p / partial-differential v via matrix inversion
            Float invdet = 1 / determinant;
            dpdu = DifferenceOfProducts(duv12[1], dp02, duv02[1], dp12) * invdet;
            dpdv = DifferenceOfProducts(duv02[0], dp12, duv12[0], dp02) * invdet;
        }
        // Handle degenerate triangle (u, v) parameterization or partial derivatives
        if (degenerateUV || LengthSquared(Cross(dpdu, dpdv)) == 0) {
            Vector3f ng = Cross(p2 - p0, p1 - p0);
            if (LengthSquared(ng) == 0)
                ng = Vector3f(Cross(Vector3<double>(p2 - p0), Vector3<double>(p1 - p0)));
            CoordinateSystem(Normalize(ng), &dpdu, &dpdv);
        }
        // Interpolate (u, v) parametric coordinates and hit point
        Point3f pHit = ti.b0 * p0 + ti.b1 * p1 + ti.b2 * p2;
        Point2f uvHit = ti.b0 * uv[0] + ti.b1 * uv[1] + ti.b2 * uv[2];
        // Return SurfaceInteraction for triangle hit
        bool flipNormal = mesh->reverseOrientation ^ mesh->transformSwapsHandedness;
        // Compute error bounds pError for triangle intersection
        Point3f pAbsSum = Abs(ti.b0 * p0) + Abs(ti.b1 * p1) + Abs(ti.b2 * p2);
        Vector3f pError = gamma(7) * Vector3f(pAbsSum);
        SurfaceInteraction isect(Point3fi(pHit, pError), uvHit, wo, dpdu, dpdv, Normal3f(), Normal3f(), time, flipNormal);
        // Set final surface normal and shading geometry for triangle
        // Override surface normal in isect for triangle
        isect.n = isect.shading.n = Normal3f(Normalize(Cross(dp02, dp12)));
        if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
            isect.n = isect.shading.n = -isect.n;
        if (mesh->n || mesh->s) {
            // Initialize Triangle shading geometry
            // Compute shading normal ns for triangle
            Normal3f ns;
            if (mesh->n) {
                ns = ti.b0 * mesh->n[v[0]] + ti.b1 * mesh->n[v[1]] + ti.b2 * mesh->n[v[2]];
                ns = LengthSquared(ns) > 0 ? Normalize(ns) : isect.n;
            } else
                ns = isect.n;
            // Compute shading tangent ss for triangle
            Vector3f ss;
            if (mesh->s) {
                ss = ti.b0 * mesh->s[v[0]] + ti.b1 * mesh->s[v[1]] + ti.b2 * mesh->s[v[2]];
                if (LengthSquared(ss) == 0)
                    ss = isect.dpdu;
            } else
                ss = isect.dpdu;
            // Compute shading bitangent ts for triangle and adjust ss
            Vector3f ts = Cross(ns, ss);
            if (LengthSquared(ts) > 0)
                ss = Cross(ts, ns);
            else
                CoordinateSystem(ns, &ss, &ts);
            // Compute partial-differential n / partial-differential u and partial-differential n / partial-differential v for triangle shading geometry
            Normal3f dndu, dndv;
            if (mesh->n) {
                // Compute deltas for triangle partial derivatives of normal
                Vector2f duv02 = uv[0] - uv[2];
                Vector2f duv12 = uv[1] - uv[2];
                Normal3f dn1 = mesh->n[v[0]] - mesh->n[v[2]];
                Normal3f dn2 = mesh->n[v[1]] - mesh->n[v[2]];
                Float determinant = DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
                bool degenerateUV = std::abs(determinant) < 1e-9;
                if (degenerateUV) {
                    // We can still compute dndu and dndv, with respect to the same arbitrary coordinate system we use to compute dpdu and dpdv when this happens. It's important to do this (rather than giving up) so that ray differentials for rays reflected from triangles with degenerate parameterizations are still reasonable.
                    Vector3f dn = Cross(Vector3f(mesh->n[v[2]] - mesh->n[v[0]], Vector3f(mesh->n[v[1]] - mesh->n[v[0]]));
                    if (LengthSquared(dn) == 0)
                        dndu = dndv = Normal3f(0, 0, 0);
                    else {
                        Vector3f dnu, dnv;
                        CoordinateSystem(dn, &dnu, &dnv);
                        dndu = Normal3f(dnu);
                        dndv = Normal3f(dnv);
                    }
                } else {
                    Float invDet = 1 / determinant;
                    dndu = DifferenceOfProducts(duv12[1], dn1, duv02[1], dn2) * invDet;
                    dndv = DifferenceOfProducts(duv02[0], dn2, duv12[0], dn1) * invDet;
                }
            } else
                dndu = dndv = Normal3f(0, 0, 0);
            isect.SetShadingGeometry(ns, ss, ts, dndu, dndv, true);
        }
        return isect;
    }
    pstd::optional<ShapeSample> Sample(Point2f u) const {
        // Get triangle vertices in p0, p1, and p2
        const TriangleMesh *mesh = GetMesh();
        const int *v = &mesh->vertexIndices[3 * triIndex];
        Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
        // Sample point on triangle uniformly by area
        pstd::array<Float, 3> b = SampleUniformTriangle(u);
        Point3f p = b[0] * p0 + b[1] * p1 + b[2] * p2;
        // Compute surface normal for sampled point on triangle
        Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));
        if (mesh->n) {
            Normal3f ns(b[0] * mesh->n[v[0]] + b[1] * mesh->n[v[1]] + (1 - b[0] - b[1]) * mesh->n[v[2]]);
            n = FaceForward(n, ns);
        } else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
            n *= -1;
        // Compute (u, v) for sampled point on triangle
        // Get triangle texture coordinates in uv array
        pstd::array<Point2f, 3> uv = mesh->uv ? pstd::array<Point2f, 3>({mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]}) : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});
        Point2f uvSample = b[0] * uv[0] + b[1] * uv[1] + b[2] * uv[2];
        // Compute error bounds pError for sampled point on triangle
        Point3f pAbsSum = Abs(b[0] * p0) + Abs(b[1] * p1) + Abs((1 - b[0] - b[1]) * p2);
        Vector3f pError = Vector3f(gamma(6) * pAbsSum);
        return ShapeSample{Interaction(Point3fi(p, pError), n, uvSample), 1 / Area()};
    }
    Float PDF(const Interaction &) const { return 1 / Area(); }
    pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx, Point2f u) const {
        // Get triangle vertices in p0, p1, and p2
        const TriangleMesh *mesh = GetMesh();
        const int *v = &mesh->vertexIndices[3 * triIndex];
        Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
        // Use uniform area sampling for numerically unstable cases
        Float solidAngle = SolidAngle(ctx.p());
        if (solidAngle < MinSphericalSampleArea || solidAngle > MaxSphericalSampleArea) {
            // Sample shape by area and compute incident direction wi
            pstd::optional<ShapeSample> ss = Sample(u);
            ss->intr.time = ctx.time;
            Vector3f wi = ss->intr.p() - ctx.p();
            if (LengthSquared(wi) == 0) return {};
            wi = Normalize(wi);
            // Convert area sampling PDF in ss to solid angle measure
            ss->pdf /= AbsDot(ss->intr.n, -wi) / DistanceSquared(ctx.p(), ss->intr.p());
            if (IsInf(ss->pdf))
                return {};
            return ss;
        }
        // Sample spherical triangle from reference point
        // Apply warp product sampling for cosine factor at reference point
        Float pdf = 1;
        if (ctx.ns != Normal3f(0, 0, 0)) {
            // Compute cosine theta-based weights w at sample domain corners
            Point3f rp = ctx.p();
            Vector3f wi[3] = {Normalize(p0 - rp), Normalize(p1 - rp), Normalize(p2 - rp)};
            pstd::array<Float, 4> w = pstd::array<Float, 4>{std::max<Float>(0.01, AbsDot(ctx.ns, wi[1])), std::max<Float>(0.01, AbsDot(ctx.ns, wi[1])), std::max<Float>(0.01, AbsDot(ctx.ns, wi[0])), std::max<Float>(0.01, AbsDot(ctx.ns, wi[2]))};
            u = SampleBilinear(u, w);
            pdf = BilinearPDF(u, w);
        }
        Float triPDF;
        pstd::array<Float, 3> b = SampleSphericalTriangle({p0, p1, p2}, ctx.p(), u, &triPDF);
        if (triPDF == 0) return {};
        pdf *= triPDF;
        // Compute error bounds pError for sampled point on triangle
        Point3f pAbsSum = Abs(b[0] * p0) + Abs(b[1] * p1) + Abs((1 - b[0] - b[1]) * p2);
        Vector3f pError = Vector3f(gamma(6) * pAbsSum);
        // Return ShapeSample for solid angle sampled point on triangle
        Point3f p = b[0] * p0 + b[1] * p1 + b[2] * p2;
        // Compute surface normal for sampled point on triangle
        Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));
        if (mesh->n) {
            Normal3f ns(b[0] * mesh->n[v[0]] + b[1] * mesh->n[v[1]] + (1 - b[0] - b[1]) * mesh->n[v[2]]);
            n = FaceForward(n, ns);
        } else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
            n *= -1;
        // Compute (u, v) for sampled point on triangle
        // Get triangle texture coordinates in uv array
        pstd::array<Point2f, 3> uv = mesh->uv ? pstd::array<Point2f, 3>({mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]}) : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});
        Point2f uvSample = b[0] * uv[0] + b[1] * uv[1] + b[2] * uv[2];
        return ShapeSample{Interaction(Point3fi(p, pError), n, ctx.time, uvSample), pdf};
    }
    Float PDF(const ShapeSampleContext &ctx, Vector3f wi) const {
        Float solidAngle = SolidAngle(ctx.p());
        // Return PDF based on uniform area sampling for challenging triangles
        if (solidAngle < MinSphericalSampleArea || solidAngle > MaxSphericalSampleArea) {
            // Intersect sample ray with shape geometry
            Ray ray = ctx.SpawnRay(wi);
            pstd::optional<ShapeIntersection> isect = Intersect(ray);
            if (!isect) return 0;
            // Compute PDF in solid angle measure from shape intersection point
            Float pdf = (1 / Area()) / (AbsDot(isect->intr.n, -wi) / DistanceSquared(ctx.p(), isect->intr.p()));
            if (IsInf(pdf)) pdf = 0;
            return pdf;
        }
        Float pdf = 1 / solidAngle;
        // Adjust PDF for warp product sampling of triangle cosine theta factor
        if (ctx.ns != Normal3f(0, 0, 0)) {
            // Get triangle vertices in p0, p1, and p2
            const TriangleMesh *mesh = GetMesh();
            const int *v = &mesh->vertexIndices[3 * triIndex];
            Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
            Point2f u = InvertSphericalTriangleSample({p0, p1, p2}, ctx.p(), wi);
            // Compute cosine theta-based weights w at sample domain corners
            Point3f rp = ctx.p();
            Vector3f wi[3] = {Normalize(p0 - rp), Normalize(p1 - rp), Normalize(p2 - rp)};
            pstd::array<Float, 4> w = pstd::array<Float, 4>{std::max<Float>(0.01, AbsDot(ctx.ns, wi[1])), std::max<Float>(0.01, AbsDot(ctx.ns, wi[1])), std::max<Float>(0.01, AbsDot(ctx.ns, wi[0])), std::max<Float>(0.01, AbsDot(ctx.ns, wi[2]))};
            pdf *= BilinearPDF(u, w);
        }
        return pdf;
    }
  private:
    // Triangle Private Methods
    const TriangleMesh *GetMesh() const {
        return (*allMeshes)[meshIndex];
    }
    // Triangle Private Members
    int meshIndex = -1, triIndex = -1;
    static pstd::vector<const TriangleMesh *> *allMeshes;
    static constexpr Float MinSphericalSampleArea = 3e-4;
    static constexpr Float MaxSphericalSampleArea = 6.22;
};
```



#parec[
  Because complex scenes may have billions of triangles, it is important to minimize the amount of memory that each triangle uses. `pbrt` stores pointers to all the #link("<TriangleMesh>")[TriangleMesh];es for the scene in a vector, which allows each triangle to be represented using just two integers: one to record which mesh it is a part of and another to record which triangle in the mesh it represents. With 4-byte `int`s, each `Triangle` uses just 8 bytes of memory.
][
  因为复杂的场景可能有数十亿个三角形，因此重要的是要尽量减少每个三角形使用的内存量。`pbrt` 将场景中所有 #link("<TriangleMesh>")[TriangleMesh] 的指针存储在一个向量中，因此每个三角形只需用两个整数表示：一个记录它属于哪个网格，另一个记录它在网格中代表哪个三角形。使用 4 字节的 `int`，每个 `Triangle` 仅使用 8 字节的内存。
]

#parec[
  Given this compact representation of triangles, recall the discussion in @dynamic-dispatch about the memory cost of classes with virtual functions: if `Triangle` inherited from an abstract `Shape` base class that defined pure virtual functions, the virtual function pointer with each `Triangle` alone would double its size, assuming a 64-bit architecture with 8-byte pointers.
][
  鉴于这种紧凑的三角形表示，回想一下在 @dynamic-dispatch 中关于具有虚函数的类的内存成本的讨论：如果 `Triangle` 继承自定义纯虚函数的抽象 `Shape` 基类，那么每个 `Triangle` 的虚函数指针将使其大小翻倍，假设在 64 位架构中使用 8 字节指针。
]

```cpp
Triangle(int meshIndex, int triIndex) : meshIndex(meshIndex), triIndex(triIndex) {}
```


```cpp
int meshIndex = -1, triIndex = -1;
static pstd::vector<const TriangleMesh *> *allMeshes;
```


#parec[
  The bounding box of a triangle is easily found by computing a bounding box that encompasses its three vertices. Because the vertices have already been transformed to rendering space, no transformation of the bounds is necessary.
][
  通过计算这三个顶点的边界框，可以轻松找到三角形的边界框。因为顶点已经被转换到渲染空间，所以不需要对边界进行转换。
]

```cpp
Bounds3f Triangle::Bounds() const {
    // Get triangle vertices in p0, p1, and p2
    const TriangleMesh *mesh = GetMesh();
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    return Union(Bounds3f(p0, p1), p2);
}
```

#parec[
  Finding the positions of the three triangle vertices requires some indirection: first the mesh pointer must be found; then the indices of the three triangle vertices can be found given the triangle's index in the mesh; finally, the positions can be read from the mesh's `p` array. We will reuse this fragment repeatedly in the following, as the vertex positions are needed in many of the `Triangle` methods.
][
  找到三角形三个顶点的位置需要一些间接操作：首先必须找到网格指针；然后可以根据三角形在网格中的索引找到三个顶点的索引；最后，可以从网格的 `p` 数组中读取位置。我们将在接下来的部分中反复使用这个片段，因为在许多 `Triangle` 方法中都需要顶点位置。
]

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

```cpp
const TriangleMesh *GetMesh() const {
    return (*allMeshes)[meshIndex];
}
```

#parec[
  Using the fact that the area of a parallelogram is given by the length of the cross product of the two vectors along its sides, the `Area()` method computes the triangle area as half the area of the parallelogram formed by two of its edge vectors (see Figure 6.13).
][
  利用平行四边形的面积由其边上的两个向量的叉积的长度给出这一事实，`Area()` 方法将三角形面积计算为由其两条边向量形成的平行四边形面积的一半（见图 6.13）。
]

```cpp
Float Area() const {
    // Get triangle vertices in p0, p1, and p2
    const TriangleMesh *mesh = GetMesh();
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    return 0.5f * Length(Cross(p1 - p0, p2 - p0));
}
```


#parec[
  Bounding the triangle's normal should be trivial: a cross product of appropriate edges gives its single normal vector direction. However, two subtleties that affect the orientation of the normal must be handled before the bounds are returned.
][
  确定三角形法线的边界应该是简单的：两边的叉积给出了其单一法线向量方向。然而，在返回边界之前，必须处理影响法线方向的两个细微差别。
]

```cpp
DirectionCone Triangle::NormalBounds() const {
    // Get triangle vertices in p0, p1, and p2
    const TriangleMesh *mesh = GetMesh();
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));
    // Ensure correct orientation of geometric normal for normal bounds
    if (mesh->n) {
        Normal3f ns(mesh->n[v[0]] + mesh->n[v[1]] + mesh->n[v[2]]);
        n = FaceForward(n, ns);
    } else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
        n *= -1;
    return DirectionCone(Vector3f(n));
}
```

#parec[
  The first issue with the returned normal comes from the presence of per-vertex normals, even though it is a bound on geometric normals that `NormalBounds()` is supposed to return. `pbrt` requires that both the geometric normal and the interpolated per-vertex normal lie on the same side of the surface. If the two of them are on different sides, then `pbrt` follows the convention that the geometric normal is the one that should be flipped.
][
  返回的法线的第一个问题来自于每个顶点法线的存在，尽管 `NormalBounds()` 应该返回的是几何法线的边界。`pbrt` 要求几何法线和插值的每个顶点法线位于表面的同一侧。如果两者位于不同的侧面，则 `pbrt` 遵循的惯例是几何法线应该被翻转。
]

```cpp
if (mesh->n) {
    Normal3f ns(mesh->n[v[0]] + mesh->n[v[1]] + mesh->n[v[2]]);
    n = FaceForward(n, ns);
} else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    n *= -1;
```


#parec[
  Although it is not required by the `Shape` interface, we will find it useful to be able to compute the solid angle that a triangle subtends from a reference point. The previously defined #link("../Geometry_and_Transformations/Spherical_Geometry.html#SphericalTriangleArea")[SphericalTriangleArea()] function takes care of this directly.
][
  虽然 `Shape` 接口不要求这样做，但我们会发现能够计算三角形从参考点所占据的立体角是很有用的。之前定义的 #link("../Geometry_and_Transformations/Spherical_Geometry.html#SphericalTriangleArea")[SphericalTriangleArea()] 函数直接处理了这一点。
]

```cpp
Float SolidAngle(Point3f p) const {
    // Get triangle vertices in p0, p1, and p2
    const TriangleMesh *mesh = GetMesh();
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    return SphericalTriangleArea(Normalize(p0 - p), Normalize(p1 - p), Normalize(p2 - p));
}
```


=== Ray-Triangle Intersection
<raytriangle-intersection>
#parec[
  Unlike the other shapes so far, `pbrt` provides a stand-alone triangle intersection function that takes a ray and the three triangle vertices directly. Having this functionality available without needing to instantiate both a `Triangle` and a `TriangleMesh` in order to do a ray-triangle intersection test is helpful in a few other parts of the system. The `Triangle` class intersection methods, described next, use this function in their implementations.
][
  与之前的其他形状不同，`pbrt` 提供了一个独立实现的三角形相交函数，该函数直接接受一条光线和三个三角形顶点。无需实例化 `Triangle` 和 `TriangleMesh` 即可进行光线与三角形的相交测试，这种功能在系统的其他部分也很有用。接下来描述的 `Triangle` 类的相交方法在其实现中使用了这个函数。
]

```cpp
pstd::optional<TriangleIntersection>
IntersectTriangle(const Ray &ray, Float tMax, Point3f p0, Point3f p1,
                  Point3f p2) {
    // Return no intersection if triangle is degenerate
    if (LengthSquared(Cross(p2 - p0, p1 - p0)) == 0)
           return {};
    // Transform triangle vertices to ray coordinate space
    // Translate vertices based on ray origin
          Point3f p0t = p0 - Vector3f(ray.o);
          Point3f p1t = p1 - Vector3f(ray.o);
          Point3f p2t = p2 - Vector3f(ray.o);
    // Permute components of triangle vertices and ray direction
          int kz = MaxComponentIndex(Abs(ray.d));
          int kx = kz + 1; if (kx == 3) kx = 0;
          int ky = kx + 1; if (ky == 3) ky = 0;
          Vector3f d = Permute(ray.d, {kx, ky, kz});
          p0t = Permute(p0t, {kx, ky, kz});
          p1t = Permute(p1t, {kx, ky, kz});
          p2t = Permute(p2t, {kx, ky, kz});
    // Apply shear transformation to translated vertex positions
          Float Sx = -d.x / d.z;
          Float Sy = -d.y / d.z;
          Float Sz = 1 / d.z;
          p0t.x += Sx * p0t.z;
          p0t.y += Sy * p0t.z;
          p1t.x += Sx * p1t.z;
          p1t.y += Sy * p1t.z;
          p2t.x += Sx * p2t.z;
          p2t.y += Sy * p2t.z;
    // Compute edge function coefficients e0, e1, and e2
       Float e0 = DifferenceOfProducts(p1t.x, p2t.y, p1t.y, p2t.x);
       Float e1 = DifferenceOfProducts(p2t.x, p0t.y, p2t.y, p0t.x);
       Float e2 = DifferenceOfProducts(p0t.x, p1t.y, p0t.y, p1t.x);
    // Fall back to double-precision test at triangle edges
       if (sizeof(Float) == sizeof(float) &&
           (e0 == 0.0f || e1 == 0.0f || e2 == 0.0f)) {
           double p2txp1ty = (double)p2t.x * (double)p1t.y;
           double p2typ1tx = (double)p2t.y * (double)p1t.x;
           e0 = (float)(p2typ1tx - p2txp1ty);
           double p0txp2ty = (double)p0t.x * (double)p2t.y;
           double p0typ2tx = (double)p0t.y * (double)p2t.x;
           e1 = (float)(p0typ2tx - p0txp2ty);
           double p1txp0ty = (double)p1t.x * (double)p0t.y;
           double p1typ0tx = (double)p1t.y * (double)p0t.x;
           e2 = (float)(p1typ0tx - p1txp0ty);
       }
    // Perform triangle edge and determinant tests
       if ((e0 < 0 || e1 < 0 || e2 < 0) && (e0 > 0 || e1 > 0 || e2 > 0))
           return {};
       Float det = e0 + e1 + e2;
       if (det == 0)
           return {};
    // Compute scaled hit distance to triangle and test against ray t range
       p0t.z *= Sz;
       p1t.z *= Sz;
       p2t.z *= Sz;
       Float tScaled = e0 * p0t.z + e1 * p1t.z + e2 * p2t.z;
       if (det < 0 && (tScaled >= 0 || tScaled < tMax * det))
           return {};
       else if (det > 0 && (tScaled <= 0 || tScaled > tMax * det))
           return {};
    // Compute barycentric coordinates and t value for triangle intersection
       Float invDet = 1 / det;
       Float b0 = e0 * invDet, b1 = e1 * invDet, b2 = e2 * invDet;
       Float t = tScaled * invDet;

    // Ensure that computed triangle t is conservatively greater than zero
    // Compute delta z term for triangle t error bounds
          Float maxZt = MaxComponentValue(Abs(Vector3f(p0t.z, p1t.z, p2t.z)));
          Float deltaZ = gamma(3) * maxZt;
    // Compute delta x and delta y terms for triangle t error bounds
          Float maxXt = MaxComponentValue(Abs(Vector3f(p0t.x, p1t.x, p2t.x)));
          Float maxYt = MaxComponentValue(Abs(Vector3f(p0t.y, p1t.y, p2t.y)));
          Float deltaX = gamma(5) * (maxXt + maxZt);
          Float deltaY = gamma(5) * (maxYt + maxZt);
    // Compute delta e term for triangle t error bounds
          Float deltaE = 2 * (gamma(2) * maxXt * maxYt + deltaY * maxXt +
                              deltaX * maxYt);
    // Compute delta t term for triangle t error bounds and check t
          Float maxE = MaxComponentValue(Abs(Vector3f(e0, e1, e2)));
          Float deltaT = 3 * (gamma(3) * maxE * maxZt + deltaE * maxZt +
                              deltaZ * maxE) * std::abs(invDet);
          if (t <= deltaT)
              return {};
    // Return TriangleIntersection for intersection
       return TriangleIntersection{b0, b1, b2, t};
}
```


#parec[
  `pbrt`'s ray-triangle intersection test is based on first computing an affine transformation that transforms the ray such that its origin is at $(0 , 0 , 0)$ in the transformed coordinate system and such that its direction is along the $+ z$ axis. Triangle vertices are also transformed into this coordinate system before the intersection test is performed. In the following, we will see that applying this coordinate system transformation simplifies the intersection test logic since, for example, the $x$ and $y$ coordinates of any intersection point must be zero. Later, in Section 6.8.4, we will see that this transformation makes it possible to have a #emph[watertight] ray-triangle intersection algorithm, such that intersections with tricky rays like those that hit the triangle right on the edge are never incorrectly reported as misses.
][
  `pbrt` 的光线与三角形相交测试基于首先计算一个仿射变换，该变换将光线变换为其原点在变换坐标系中的 $(0 , 0 , 0)$，并使其方向沿 $+ z$ 轴。在进行相交测试之前，三角形顶点也被转换到这个坐标系中。接下来，我们将看到应用这个坐标系变换简化了相交测试逻辑，因为例如任何相交点的 $x$ 和 $y$ 坐标必须为零。在后面的第 6.8.4 节中，我们将看到这种变换使得可以实现一个无缝的光线与三角形相交算法，这样与棘手的光线相交（例如正好击中三角形边缘的光线）时不会被错误地报告为未命中。
]

#parec[
  One side effect of the transformation that we will apply to the vertices is that, due to floating-point round-off error, a degenerate triangle may be transformed into a non-degenerate triangle. If an intersection is reported with a degenerate triangle, then later code that tries to compute the geometric properties of the intersection will be unable to compute valid results. Therefore, this function starts with testing for a degenerate triangle and returning immediately if one was provided.
][
  我们将应用于顶点的变换的一个副作用是，由于浮点数舍入误差，一个退化三角形可能会被转换为一个非退化三角形。如果报告了与退化三角形的相交，那么后续尝试计算相交几何属性的代码将无法计算出有效结果。因此，该函数首先检查是否为退化三角形，如果是则立即返回。
]

```cpp
// Return no intersection if triangle is degenerate
if (LengthSquared(Cross(p2 - p0, p1 - p0)) == 0)
    return {};
```


#parec[
  There are three steps to computing the transformation from rendering space to the ray-triangle intersection coordinate space: a translation \$ abla\$, a coordinate permutation \$ abla\$, and a shear \$ abla\$. Rather than computing explicit transformation matrices for each of these and then computing an aggregate transformation matrix \$ abla = abla abla abla\$ to transform vertices to the coordinate space, the following implementation applies each step of the transformation directly, which ends up being a more efficient approach.
][
  从渲染空间到光线与三角形相交坐标空间的变换计算分为三个步骤：平移 \$ abla\$，坐标置换 \$ abla\$ 和剪切 \$ abla\$。与其为每个步骤计算显式变换矩阵，然后计算一个聚合变换矩阵 \$ abla \= abla abla abla\$ 来将顶点转换到坐标空间，以下实现直接逐步应用变换，这种方法更加高效。
]

```cpp
// Transform triangle vertices to ray coordinate space
// Translate vertices based on ray origin
   Point3f p0t = p0 - Vector3f(ray.o);
   Point3f p1t = p1 - Vector3f(ray.o);
   Point3f p2t = p2 - Vector3f(ray.o);
// Permute components of triangle vertices and ray direction
   int kz = MaxComponentIndex(Abs(ray.d));
   int kx = kz + 1; if (kx == 3) kx = 0;
   int ky = kx + 1; if (ky == 3) ky = 0;
   Vector3f d = Permute(ray.d, {kx, ky, kz});
   p0t = Permute(p0t, {kx, ky, kz});
   p1t = Permute(p1t, {kx, ky, kz});
   p2t = Permute(p2t, {kx, ky, kz});
// Apply shear transformation to translated vertex positions
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




$
  upright(bold(T)) = mat(delim: "(", 1, 0, 0, - upright(bold(o))_x; 0, 1, 0, - upright(bold(o))_y; 0, 0, 1, - upright(bold(o))_z; 0, 0, 0, 1)
$


#parec[
  This transformation does not need to be explicitly applied to the ray origin, but we will apply it to the three triangle vertices.
][
  这个变换不需要直接应用于光线起点，但我们会将其应用于三个三角形顶点。
]

```
Point3f p0t = p0 - Vector3f(ray.o); Point3f p1t = p1 - Vector3f(ray.o);
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



```
  int kz = MaxComponentIndex(Abs(ray.d)); int kx = kz + 1; if (kx == 3) kx
  \= 0; int ky = kx + 1; if (ky == 3) ky = 0; Vector3f d = Permute(ray.d,
  {kx, ky, kz}); p0t = Permute(p0t, {kx, ky, kz}); p1t = Permute(p1t, {kx,
  ky, kz}); p2t = Permute(p2t, {kx, ky, kz});
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



```cpp
<<Apply shear transformation to translated vertex positions>>=
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
  With the triangle vertices transformed to this coordinate system, our task now is to find whether the ray starting from the origin and traveling along the $+ z$ axis intersects the transformed triangle. Because of the way the coordinate system was constructed, this problem is equivalent to the 2D problem of determining if the $(0 , 0)$ coordinates are inside the $x y$ projection of the triangle (Figure~6.12).
][
  将三角形顶点转换到此坐标系后，我们现在的任务是确定从原点出发沿 $+ z$ 轴行进的光线是否与转换后的三角形相交。由于坐标系的构造方式，此问题等同于确定 $(0 , 0)$ 坐标是否在三角形的 $x y$ 投影内（图~6.12）。
]

#parec[
  #block[
    #block[
      #block[

      ]
      Figure 6.12: In the ray-triangle intersection coordinate system, the ray
      starts at the origin and goes along the $+ z$ axis. The intersection
      test can be performed by considering only the $x y$ projection of the
      ray and the triangle vertices, which in turn reduces to determining if
      the 2D point $(0 , 0)$ is within the triangle.
    ]
  ]
][
  #block[
    #block[
      #block[

      ]
      图 6.12:
      在光线-三角形相交坐标系中，光线从原点开始沿$+ z$轴行进。可以通过仅考虑光线和三角形顶点的$x y$投影来进行相交检测，这反过来简化为确定2D点$(0 , 0)$是否在三角形内。
    ]
  ]
]

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
    (upright(bold(p))_1^x - upright(bold(p))_0^x) (upright(bold(p))_2^y - upright(bold(p))_0^y) - (
      upright(bold(p))_2^x - upright(bold(p))_0^x
    ) (upright(bold(p))_1^y - upright(bold(p))_0^y)
  )
$



#parec[
  Figure~6.13 visualizes this idea geometrically.
][
  图~6.13从几何上可视化了这个想法。
]

#parec[
  #block[
    #block[
      #block[

      ]
      Figure 6.13: The area of a triangle with two edges given by vectors
      $upright(bold(v))_1$ and $upright(bold(v))_2$ is one-half of the area of
      the parallelogram shown here. The parallelogram area is given by the
      length of the cross product of $upright(bold(v))_1$ and
      $upright(bold(v))_2$.
    ]
  ]
][
  #block[
    #block[
      #block[

      ]
      图 6.13:
      由向量$upright(bold(v))_1$和$upright(bold(v))_2$给出的两个边构成的三角形的面积是所示平行四边形面积的一半。平行四边形的面积由$upright(bold(v))_1$和$upright(bold(v))_2$的叉积长度给出。
    ]
  ]
]

#parec[
  We will use this expression of triangle area to define a signed edge function: given two triangle vertices $upright(bold(p))_0$ and $upright(bold(p))_1$, we can define the directed edge function $e$ as the function that gives twice the area of the triangle given by $upright(bold(p))_0$, $upright(bold(p))_1$, and a given third point $upright(bold(p))$ :
][
  我们将使用这个三角形面积的表达式来定义一个有符号的边函数：给定两个三角形顶点 $upright(bold(p))_0$ 和 $upright(bold(p))_1$，我们可以定义有向边函数 $e$，作为给定第三个点 $upright(bold(p))$ 的三角形由 $upright(bold(p))_0$ 、 $upright(bold(p))_1$ 和 $upright(bold(p))$ 定义的面积的两倍的函数：
]


$ e (p) = (p_1 x - p_0 x) (p_y - p_0 y) - (p_x - p_0 x) (p_1 y - p_0 y) . $

#parec[
  (See Figure~6.14.)
][
  (见图~6.14.)
]

#parec[
  Figure 6.14: The edge function $e (p)$ characterizes points with respect to an oriented line between two points $p_0$ and $p_1$. The value of the edge function is positive for points $p$ to the left of the line, zero for points on the line, and negative for points to the right of the line. The ray-triangle intersection algorithm uses an edge function that is twice the signed area of the triangle formed by the three points.
][
  图 6.14：边缘函数 $e (p)$ 描述了点相对于两个点 $p_0$ 和 $p_1$ 之间的有向线的位置。对于线左侧的点，边缘函数值为正；对于线上的点，值为零；对于线右侧的点，值为负。光线-三角形相交算法使用的边缘函数是由三个点形成的三角形的两倍有符号面积。
]

#parec[
  The edge function gives a positive value for points to the right of the line, and a negative value for points to the left. Thus, if a point has edge function values of the same sign for all three edges of a triangle, it must be on the same side of all three edges and thus must be inside the triangle.
][
  边缘函数对线右侧的点给出正值，对线左侧的点给出负值。因此，如果一个点对于三角形的所有三条边的边缘函数值符号相同，则该点必定在所有三条边的同一侧，因此必定在三角形内部。
]

#parec[
  Thanks to the coordinate system transformation, the point $p$ that we are testing has coordinates $(0 , 0)$. This simplifies the edge function expressions. For example, for the edge $e_0$ from $p_1$ to $p_2$, we have:
][
  由于坐标系转换，我们正在测试的点 $p$ 的坐标为 $(0 , 0) $。这简化了边缘函数表达式。例如，对于从 $p_1$ 到 $p_2$ 的边 $e_0$，我们有：
]

$
  mat(delim: #none,
e_0 (p), =(p_(2 x) - p_(1 x))(p_y - p_(1 y)) -(p_x - p_(1 x))(p_(2 y) - p_(1 y));
, =(p_(2 x) - p_(1 x))(-p_(1 y)) -(-p_(1 x))(p_(2 y) - p_(1 y));
, = p_(1 x) p_(2 y) - p_(2 x) p_(1 y) .)
$

#parec[
  In the following, we will use the indexing scheme that the edge function $e_i$ corresponds to the directed edge from vertex $p_((i + 1) #h(0em) mod med 3)$ to $p_((i + 2) #h(0em) mod med 3)$.
][
  接下来，我们将使用索引方案，其中边缘函数 $e_i$ 对应于从顶点 $p_((i + 1) #h(0em) mod med 3)$ 到 $p_((i + 2) #h(0em) mod med 3)$ 的定向边。
]

#parec[
  In the rare case that any of the edge function values is exactly zero, it is not possible to be sure if the ray hits the triangle or not, and the edge equations are reevaluated using double-precision floating-point arithmetic. (Section~6.8.4 discusses the need for this step in more detail.) The fragment that implements this computation, \<\>, is just a reimplementation of \<\<Compute edge function coefficients e0, e1 and e2 using doubles and so is not included here.
][
  在极少数情况下，如果任何边缘函数值恰好为零，则无法确定光线是否击中三角形，边缘方程将使用双精度浮点运算重新计算。（第~6.8.4节更详细地讨论了此步骤的必要性。）实现此计算的片段，\<\>，只是\<\<使用double重新实现计算边缘函数系数e0、e1和e2\>，因此不在此处包含。
]

#parec[
  Given the values of the three edge functions, we have our first two opportunities to determine that there is no intersection. First, if the signs of the edge function values differ, then the point $(0 , 0)$ is not on the same side of all three edges and therefore is outside the triangle. Second, if the sum of the three edge function values is zero, then the ray is approaching the triangle edge-on, and we report no intersection. (For a closed triangle mesh, the ray will hit a neighboring triangle instead.)
][
  给定三个边缘函数的值，我们有两个机会可以确定没有交点。首先，如果边缘函数值的符号不同，则点 $(0 , 0)$ 不在所有三条边的同一侧，因此在三角形外部。其次，如果三个边缘函数值的和为零，则光线正面接近三角形边缘，我们报告没有交点。（对于封闭的三角形网格，光线将击中相邻的三角形。）
]

```cpp
<<Perform triangle edge and determinant tests>>=
if ((e0 < 0 || e1 < 0 || e2 < 0) && (e0 > 0 || e1 > 0 || e2 > 0))
    return {};
Float det = e0 + e1 + e2;
if (det == 0)
    return {};
```

#parec[
  Because the ray starts at the origin, has unit length, and is along the $+ z$ axis, the $z$ coordinate value of the intersection point is equal to the intersection's parametric $t $ value. To compute this $z $ value, we first need to go ahead and apply the shear transformation to the $z$ coordinates of the triangle vertices. Given these $z$ values, the barycentric coordinates of the intersection point in the triangle can be used to interpolate them across the triangle. They are given by dividing each edge function value by the sum of edge function values:
][
  光线从原点出发，长度为单位，并沿 $+ z$ 轴方向，因此交点的 $z$ 坐标值等于其参数 $t$ 值。为了计算这个 $z$ 值，我们首先需要对三角形顶点的 $z$ 坐标应用剪切变换。给定这些 $z$ 值，交点在三角形中的重心坐标可以用于在三角形上进行插值。它们通过将每个边缘函数值除以边缘函数值的和来给出：
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
  Along similar lines, the check $t < t_(m a x)$ can be equivalently performed in two ways:
][
  类似地，检查 $t < t_(m a x)$ 可以通过两种方式等效执行：
]


$
  quad sum_i e_i z_i < t_(upright("max")) (e_0 + e_1 + e_2) & upright(" if ") e_0 + e_1 + e_2 > 0 \
  quad sum_i e_i z_i > t_(upright("max")) (e_0 + e_1 + e_2) & upright(" otherwise")
$

#parec[
  Given a valid intersection, the actual barycentric coordinates and $t$ value for the intersection are found.
][
  给定一个有效的交点，可以找到交点的实际重心坐标和 $t$ 值。
]

```cpp
Float invDet = 1 / det;
Float b0 = e0 * invDet, b1 = e1 * invDet, b2 = e2 * invDet;
Float t = tScaled * invDet;
```


#parec[
  After a final test on the $t$ value that will be discussed in Section #link("../Shapes/Managing_Rounding_Error.html#sec:avoid-negative-t-intersections")[6.8.7];, a `TriangleIntersection` object that represents the intersection can be returned.
][
  在对将在#link("../Shapes/Managing_Rounding_Error.html#sec:avoid-negative-t-intersections")[6.8.7节];中讨论的 $t$ 值进行最终测试后，可以返回表示交点的 `TriangleIntersection（交点三角形）` 对象。
]

```cpp
return TriangleIntersection{b0, b1, b2, t};
```


#parec[
  `TriangleIntersection` just records the barycentric coordinates and the $t$ value along the ray where the intersection occurred.
][
  `TriangleIntersection` 仅记录交点发生在射线上时的重心坐标和 $t$ 值。
]


```cpp
struct TriangleIntersection {
    Float b0, b1, b2;
    Float t;
};
```

#parec[
  The structure of the `Triangle::Intersect()` method follows the form of earlier intersection test methods.
][
  `Triangle::Intersect()` 方法的结构遵循早期交点测试方法的形式。
]

```cpp
pstd::optional<ShapeIntersection> Triangle::Intersect(const Ray &ray, Float tMax) const {
    // Get triangle vertices in p0, p1, and p2
    const TriangleMesh *mesh = GetMesh();
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    pstd::optional<TriangleIntersection> triIsect = IntersectTriangle(ray, tMax, p0, p1, p2);
    if (!triIsect) return {};
    SurfaceInteraction intr = InteractionFromIntersection(mesh, triIndex, *triIsect, ray.time, -ray.d);
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
  我们设计这样的接口是为了能够在 `pbrt` 的 GPU 渲染路径中使用此方法，其中不使用 `Triangle` 类。 在那里，场景中三角形的表示由射线交点 API 抽象，几何射线-三角形交点测试使用专用硬件进行。 给定一个交点，它提供三角形索引、指向三角形所属网格的指针以及交点的重心坐标。 这些信息足以调用此方法，从而允许我们使用与 CPU 上执行的相同代码找到此类交点的 `SurfaceInteraction`。
]


```cpp
static SurfaceInteraction InteractionFromIntersection(
        const TriangleMesh *mesh, int triIndex,
        TriangleIntersection ti, Float time, Vector3f wo) {
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];
    // Compute triangle partial derivatives
    // Compute deltas and matrix determinant for triangle partial derivatives
    // Get triangle texture coordinates in uv array
    pstd::array<Point2f, 3> uv =
        mesh->uv
            ? pstd::array<Point2f, 3>(
                  {mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]})
            : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});
    Vector2f duv02 = uv[0] - uv[2], duv12 = uv[1] - uv[2];
    Vector3f dp02 = p0 - p2, dp12 = p1 - p2;
    Float determinant =
        DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
    Vector3f dpdu, dpdv;
    bool degenerateUV = std::abs(determinant) < 1e-9f;
    if (!degenerateUV) {
        // Compute triangle partial-differentials
        // Compute deltas and matrix determinant for triangle partial derivatives
        Float invdet = 1 / determinant;
        dpdu = DifferenceOfProducts(duv12[1], dp02, duv02[1], dp12) * invdet;
        dpdv = DifferenceOfProducts(duv02[0], dp12, duv12[0], dp02) * invdet;
    }
    // Handle degenerate triangle (u, v) parameterization or partial derivatives
    if (degenerateUV || LengthSquared(Cross(dpdu, dpdv)) == 0) {
        Vector3f ng = Cross(p2 - p0, p1 - p0);
        if (LengthSquared(ng) == 0)
            ng = Vector3f(Cross(Vector3<double>(p2 - p0), Vector3<double>(p1 - p0)));
        CoordinateSystem(Normalize(ng), &dpdu, &dpdv);
    }
    // Interpolate (u, v) parametric coordinates and hit point
    Point3f pHit = ti.b0 * p0 + ti.b1 * p1 + ti.b2 * p2;
    Point2f uvHit = ti.b0 * uv[0] + ti.b1 * uv[1] + ti.b2 * uv[2];
    // Return SurfaceInteraction for triangle hit
    bool flipNormal = mesh->reverseOrientation ^ mesh->transformSwapsHandedness;
    // Compute error bounds pError for triangle intersection
    Point3f pAbsSum = Abs(ti.b0 * p0) + Abs(ti.b1 * p1) + Abs(ti.b2 * p2);
    Vector3f pError = gamma(7) * Vector3f(pAbsSum);
    SurfaceInteraction isect(Point3fi(pHit, pError), uvHit, wo, dpdu, dpdv,
                             Normal3f(), Normal3f(), time, flipNormal);
    // Set final surface normal and shading geometry for triangle
    // Override surface normal in isect for triangle
    isect.n = isect.shading.n = Normal3f(Normalize(Cross(dp02, dp12)));
    if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
        isect.n = isect.shading.n = -isect.n;
    if (mesh->n || mesh->s) {
        // Initialize Triangle shading geometry
        // Compute shading normal ns for triangle
        Normal3f ns;
        if (mesh->n) {
            ns = ti.b0 * mesh->n[v[0]] + ti.b1 * mesh->n[v[1]] + ti.b2 * mesh->n[v[2]];
            ns = LengthSquared(ns) > 0 ? Normalize(ns) : isect.n;
        } else
            ns = isect.n;
        // Compute shading tangent ss for triangle
        Vector3f ss;
        if (mesh->s) {
            ss = ti.b0 * mesh->s[v[0]] + ti.b1 * mesh->s[v[1]] + ti.b2 * mesh->s[v[2]];
            if (LengthSquared(ss) == 0)
                ss = isect.dpdu;
        } else
            ss = isect.dpdu;
        // Compute shading bitangent ts for triangle and adjust ss
        Vector3f ts = Cross(ns, ss);
        if (LengthSquared(ts) > 0)
            ss = Cross(ts, ns);
        else
            CoordinateSystem(ns, &ss, &ts);
        // Compute partial-differential normal / partial-differential u
        // and partial-differential normal / partial-differential v for triangle shading geometry
        Normal3f dndu, dndv;
        if (mesh->n) {
            // Compute deltas for triangle partial derivatives of normal
            Vector2f duv02 = uv[0] - uv[2];
            Vector2f duv12 = uv[1] - uv[2];
            Normal3f dn1 = mesh->n[v[0]] - mesh->n[v[2]];
            Normal3f dn2 = mesh->n[v[1]] - mesh->n[v[2]];

            Float determinant =
                DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
            bool degenerateUV = std::abs(determinant) < 1e-9;
            if (degenerateUV) {
                // We can still compute dndu and dndv, with respect to the
                // same arbitrary coordinate system we use to compute dpdu
                // and dpdv when this happens. It's important to do this
                // (rather than giving up) so that ray differentials for
                // rays reflected from triangles with degenerate
                // parameterizations are still reasonable.
                Vector3f dn = Cross(Vector3f(mesh->n[v[2]] - mesh->n[v[0]],
                                    Vector3f(mesh->n[v[1]] - mesh->n[v[0]]));

                if (LengthSquared(dn) == 0)
                    dndu = dndv = Normal3f(0, 0, 0);
                else {
                    Vector3f dnu, dnv;
                    CoordinateSystem(dn, &dnu, &dnv);
                    dndu = Normal3f(dnu);
                    dndv = Normal3f(dnv);
                }
            } else {
                Float invDet = 1 / determinant;
                dndu = DifferenceOfProducts(duv12[1], dn1, duv02[1], dn2) * invDet;
                dndv = DifferenceOfProducts(duv02[0], dn2, duv12[0], dn1) * invDet;
            }
        } else
            dndu = dndv = Normal3f(0, 0, 0);
    isect.SetShadingGeometry(ns, ss, ts, dndu, dndv, true);
    }
    return isect;
}
```
#parec[
  To generate consistent tangent vectors over triangle meshes, it is necessary to compute the partial derivatives $partial p \/ partial u$ and $partial p \/ partial v$ using the parametric $(u,v)$ values at the triangle vertices, if provided. Although the partial derivatives are the same at all points on the triangle, the implementation here recomputes them each time an intersection is found. Although this results in redundant computation, the storage savings for large triangle meshes can be significant.
][
  为了在三角网格上生成一致的切线向量，有必要使用三角形顶点处的参数化 $(u,v)$ 值来计算偏导数 $partial p \/ partial u$ 和 $partial p \/ partial v$。尽管在三角形上的所有点处这些偏导数是相同的，但此处的实现每次找到交点时都会重新计算它们。尽管这会导致重复计算，但对于大型三角网格来说，节省的存储空间可能是相当可观的。
]

#parec[
  A triangle can be described by the set of points
][
  一个三角形可以点集描述：
]

$
  upright(p)_o + u (partial upright(p)) / (partial u) + v (partial upright(p)) / (partial v)
$

#parec[
  for some $p_o$, where $u$ and $v$ range over the parametric coordinates of the triangle. We also know the three vertex positions $p_i$, $i = 0 , 1 , 2$, and the texture coordinates $(u_i , v_i)$ at each vertex. From this it follows that the partial derivatives of $p$ must satisfy
][
  对于某个给定的 $p_o$，其中 $u$ 和 $v$ 在三角形的参数坐标范围内。我们还知道三个顶点位置 $p_i$， $i = 0 , 1 , 2$，以及每个顶点的纹理坐标 $(u_i , v_i)$。由此可知， $p$ 的偏导数必须满足以下条件
]

$
  upright(p)_i = upright(p)_o + u_i (partial upright(p)) / (partial u) + v_i (partial upright(p)) / (partial v)
$


#parec[
  In other words, there is a unique affine mapping from the 2D $(u , v)$ space to points on the triangle. (Such a mapping exists even though the triangle is specified in 3D because the triangle is planar.) To compute expressions for and , we start by computing the differences $p_0 - p_2$ and $p_1 - p_2$, giving the matrix equation
][
  换句话说，从二维 $(u , v)$ 空间到三角形上的点存在一个唯一的仿射映射。即使三角形在三维空间中定义，由于三角形是平面的，这种映射仍然存在。为了计算 和 的表达式，我们首先计算 $p_0 - p_2$ 和 $p_1 - p_2$ 的差异，得到矩阵方程
]

$
  mat(delim: "(", u_0 - u_2, v_0 - v_2; u_1 - u_2, v_1 - v_2) vec(frac(partial p, partial u), frac(partial  p, partial v)) = vec(p_0 - p_2, p_1 - p_2) .
$



#parec[
  Thus,
][
  因此，
]

$
  vec(frac(partial  p, partial u), frac(partial  p, partial v)) = mat(delim: "(", u_0 - u_2, v_0 - v_2; u_1 - u_2, v_1 - v_2)^(- 1) vec(p_0 - p_2, p_1 - p_2) .
$


#parec[
  Inverting a $2 times 2$ matrix is straightforward. The inverse of the $(u , v)$ differences matrix is
][
  求解 $2 times 2$ 矩阵的逆是一个直接的过程。 $(u , v)$ 差异矩阵的逆为
]

$
  frac(1, (u_0 - u_2) (v_1 - v_2) - (v_0 - v_2) (u_1 - u_2)) mat(delim: "(", v_1 - v_2, - (v_0 - v_2); - (u_1 - u_2), u_0 - u_2) .
$


#parec[
  This computation is performed by the \<\<#link("<fragment-Computetrianglepartialderivatives-0>")[Compute triangle partial derivatives];\>\> fragment, with handling for various additional corner cases.
][
  此计算由 \<\<#link("<fragment-Computetrianglepartialderivatives-0>")[计算三角形偏导数];\>\> 代码片段执行，并处理各种附加的特殊情况。
]

```cpp
<<Compute triangle partial derivatives>>=
<<Compute deltas and matrix determinant for triangle partial derivatives>>
Vector3f dpdu, dpdv;
bool degenerateUV = std::abs(determinant) < 1e-9f;
if (!degenerateUV) {
    <<Compute triangle  and  via matrix inversion>>
}
<<Handle degenerate triangle  parameterization or partial derivatives>>
```

#parec[
  The triangle's `uv` coordinates are found by indexing into the #link("<TriangleMesh::uv>")[TriangleMesh::uv] array, if present. Otherwise, a default parameterization is used. We will not include the fragment that initializes `uv` here.
][
  三角形的 `uv` 坐标通过索引 #link("<TriangleMesh::uv>")[TriangleMesh::uv] 数组获取（如果存在）。否则，使用默认参数化。我们在这里不会包含初始化 `uv` 的代码片段。
]

```cpp
<<Compute deltas and matrix determinant for triangle partial derivatives>>=
<<Get triangle texture coordinates in uv array>>
Vector2f duv02 = uv[0] - uv[2], duv12 = uv[1] - uv[2];
Vector3f dp02 = p0 - p2, dp12 = p1 - p2;
Float determinant =
    DifferenceOfProducts(duv02[0], duv12[1], duv02[1], duv12[0]);
```

#parec[
  In the usual case, the $2 times 2$ matrix is non-degenerate, and the partial derivatives are computed using Equation (6.7).
][
  通常情况下， $2 times 2$ 矩阵是非退化的，偏导数使用方程 (6.7) 计算。
]

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

\<\<Handle degenerate triangle $(u , v)$ parameterization or partial
derivatives\>\>= \
```cpp
if (degenerateUV || LengthSquared(Cross(dpdu, dpdv)) == 0) {
Vector3f ng = Cross(p2 - p0, p1 - p0); if (LengthSquared(ng) == 0) ng =
Vector3f(Cross(Vector3(p2 - p0), Vector3(p1 - p0)));
CoordinateSystem(Normalize(ng), &dpdu, &dpdv); }
```


#parec[
  The uniform area triangle sampling method is based on mapping the provided random sample $u$ to barycentric coordinates that are uniformly distributed over the triangle.
][
  均匀面积三角形采样方法基于将提供的随机样本 $u$ 映射到在三角形上均匀分布的重心坐标系。
]

```cpp
pstd::optional<ShapeSample> Sample(Point2f u) const {
    // Get triangle vertices in p0, p1, and p2
    const TriangleMesh *mesh = GetMesh();
    const int *v = &mesh->vertexIndices[3 * triIndex];
    Point3f p0 = mesh->p[v[0]], p1 = mesh->p[v[1]], p2 = mesh->p[v[2]];

    // Sample point on triangle uniformly by area
    pstd::array<Float, 3> b = SampleUniformTriangle(u);
    Point3f p = b[0] * p0 + b[1] * p1 + b[2] * p2;

    // Compute surface normal for sampled point on triangle
    Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));

    if (mesh->n) {
        Normal3f ns(b[0] * mesh->n[v[0]] + b[1] * mesh->n[v[1]] + (1 - b[0] - b[1]) * mesh->n[v[2]]);
        n = FaceForward(n, ns);
    } else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
        n *= -1;

    // Compute (u, v) for sampled point on triangle
    // Get triangle texture coordinates in uv array
    pstd::array<Point2f, 3> uv = mesh->uv
        ? pstd::array<Point2f, 3>({mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]})
        : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});

    Point2f uvSample = b[0] * uv[0] + b[1] * uv[1] + b[2] * uv[2];

    // Compute error bounds pError for sampled point on triangle
    Point3f pAbsSum = Abs(b[0] * p0) + Abs(b[1] * p1) + Abs((1 - b[0] - b[1]) * p2);
    Vector3f pError = Vector3f(gamma(6) * pAbsSum);

    return ShapeSample{Interaction(Point3fi(p, pError), n, uvSample), 1 / Area()};
}
```

#parec[
  Uniform barycentric sampling is provided via a stand-alone utility function, which makes it easier to reuse this functionality elsewhere.
][
  通过一个独立的工具函数提供均匀重心采样，这使得在其他地方重用此功能变得更容易。
]


```cpp
pstd::array<Float, 3> b = SampleUniformTriangle(u);
Point3f p = b[0] * p0 + b[1] * p1 + b[2] * p2;
```


#parec[
  As with #link("<Triangle::NormalBounds>")[Triangle::NormalBounds()];, the surface normal of the sampled point is affected by the orientation of the shading normal, if present.
][
  与 #link("<Triangle::NormalBounds>")[Triangle::NormalBounds()] 一样，采样点的表面法线受着色法线的方向影响（如果存在）。
]


```cpp
Normal3f n = Normalize(Normal3f(Cross(p1 - p0, p2 - p0)));
if (mesh->n) {
    Normal3f ns(b[0] * mesh->n[v[0]] + b[1] * mesh->n[v[1]] + (1 - b[0] - b[1]) * mesh->n[v[2]]);
    n = FaceForward(n, ns);
} else if (mesh->reverseOrientation ^ mesh->transformSwapsHandedness)
    n *= -1;
```


#parec[
  The coordinates for the sampled point are also found with barycentric interpolation.
][
  采样点的坐标也通过重心插值得到。
]


```cpp
// Get triangle texture coordinates in uv array
pstd::array<Point2f, 3> uv = mesh->uv
    ? pstd::array<Point2f, 3>({mesh->uv[v[0]], mesh->uv[v[1]], mesh->uv[v[2]]})
    : pstd::array<Point2f, 3>({Point2f(0, 0), Point2f(1, 0), Point2f(1, 1)});

Point2f uvSample = b[0] * uv[0] + b[1] * uv[1] + b[2] * uv[2];
```


#parec[
  Because barycentric interpolation is linear, it can be shown that if we can find barycentric coordinates that uniformly sample a specific triangle, then those barycentrics can be used to uniformly sample any triangle.
][
  由于重心插值是线性的，可以证明，如果我们能找到均匀采样特定三角形的重心坐标，那么这些重心坐标可以用于均匀采样任何三角形。
]

#parec[
  To derive the sampling algorithm, we will therefore consider the case of uniformly sampling a unit right triangle.
][
  为了推导采样算法，我们将考虑均匀采样单位直角三角形（即直角边长为1的三角形）的情况。
]

#parec[
  Given a uniform sample in $\[ 0 , 1 \)^2$ that we would like to map to the triangle, the task can also be considered as finding an area-preserving mapping from the unit square to the unit triangle.
][
  给定一个我们希望映射到三角形的 $\[ 0 , 1 \)^2$ 的均匀样本，这个任务也可以被认为是找到从单位正方形到单位三角形的面积保持映射。
]

#figure(
  image("../pbr-book-website/4ed/Shapes/pha06f15.svg"),
  caption: [
    #ez_caption[
      Figure 6.15: Samples from the unit square can be mapped to the unit
      right triangle by reflecting across the diagonal, though doing so
      causes far away samples on the square to map to nearby points on the
      triangle.][
      图
      6.15：单位正方形的样本可以通过对角线反射映射到单位直角三角形，尽管这样做会导致正方形上相距较远的样本映射到三角形上的相近点。]
  ],
)


#parec[
  A straightforward approach is suggested by Figure 6.15: the unit square could be folded over onto itself, such that samples that are on the side of the diagonal that places them outside the triangle are reflected across the diagonal to be inside it.
][
  图 6.15 提出了一种简单的方法：单位正方形可以折叠到自身上，使得位于对角线一侧而将它们置于三角形外的样本通过对角线反射到内部。
]

#parec[
  While this would provide a valid sampling technique, it is undesirable since it causes samples that were originally far away in $\[ 0 , 1 \)^2$ to be close together on the triangle.
][
  虽然这将提供一种有效的采样技术，但这是不理想的，因为它会导致原本在 $\[ 0 , 1 \)^2$ 中相距较远的样本在三角形上变得接近。
]

#parec[
  (For example, $(0.01 , 0.01)$ and $(0.99 , 0.99)$ in the unit square would both map to the same point in the triangle.)
][
  （例如，单位正方形中的 $(0.01 , 0.01)$ 和 $(0.99 , 0.99)$ 都会映射到三角形中的同一点。）
]

#parec[
  The effect would be that sampling techniques that generate well-distributed uniform samples such as those discussed in Chapter 8 were less effective at reducing error.
][
  其效果是那些生成分布良好的均匀样本的采样技术，如第 8 章讨论的那些技术，在减少误差方面的效果较差。
]

#parec[
  A better mapping translates points along the diagonal by a varying amount that brings the two opposite sides of the unit square to the triangle's diagonal.
][
  一种更好的映射方法是沿对角线以不同的量平移点，使单位正方形的两个相对边到达三角形的对角线。
]



$
  f (xi_1 , xi_2) = (
    xi_1 - delta , xi_2 - delta
  ) quad upright(" where ") delta = cases(delim: "{", xi_1 \/ 2 & upright("if ") xi_1 < xi_2, xi_2 \/ 2 & upright("otherwise"))
$


#parec[
  The determinant of the Jacobian matrix for this mapping is a constant and therefore this mapping is area preserving and uniformly distributed samples in the unit square are uniform in the triangle.
][
  此映射的雅可比矩阵的行列式是一个常数，因此此映射是面积保持的，并且单位正方形中的均匀分布样本在三角形中也是均匀的。
]

#parec[
  (Recall Section 2.4.1, which presented the mathematics of transforming samples from one domain to the other; there it was shown that if the Jacobian of the transformation is constant, the mapping is area-preserving.)
][
  （回忆第 2.4.1 节，其中介绍了将样本从一个域转换到另一个域的数学；在那里显示，如果变换的雅可比矩阵是常数，则映射是面积保持的。）
]

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
  The usual normalization constraint gives the PDF in terms of the triangle's surface area.
][
  通常的归一化约束给出了关于三角形表面积的概率密度函数。
]

```cpp
Float PDF(const Interaction &) const { return 1 / Area(); }
```


#parec[
  In order to sample points on spheres with respect to solid angle from a reference point, we derived a specialized sampling method that only sampled from the potentially visible region of the sphere.
][
  为了从参考点对球体进行立体角采样，我们推导出一种专门的采样方法，该方法仅从球体的潜在可见区域采样。
]

#parec[
  For the cylinder and disk, we just sampled uniformly by area and rescaled the PDF to account for the change of measure from area to solid angle.
][
  对于圆柱体和圆盘，我们只是按面积均匀采样，并重新调整概率密度函数以考虑从面积到立体角的度量变化。
]

#parec[
  It is tempting to do the same for triangles (and, indeed, all three previous editions of this book did so), but going through the work to apply a solid angle sampling approach can lead to much better results.
][
  对于三角形（实际上，本书的前三个版本确实这样做了），也有诱惑这样做，但通过应用立体角采样方法可以获得更好的结果。
]

#parec[
  To see why, consider a simplified form of the reflection integral from the scattering equation, (4.14):
][
  为了理解原因，请考虑散射方程（4.14）中的反射积分的简化形式：
]


$ integral_(cal(S)^2) rho L_i (p , omega_i) lr(|cos theta_i|) d omega_i , $


#parec[
  where the BRDF $f$ has been replaced with a constant $rho$, which corresponds to a diffuse surface. If we consider the case of incident radiance only coming from a triangular light source that emits uniform diffuse radiance $L_e$, then we can rewrite this integral as
][
  其中，双向反射分布函数 $f$ 被替换为常数 $rho$，对应于漫反射表面。如果我们考虑入射辐射仅来自一个发出均匀漫射辐射 $L_e$ 的三角形光源的情况，那么我们可以将这个积分重写为
]

$ rho L_e integral_(cal(S)^2) V (p , omega_i) lr(|cos theta_i|) d omega_i , $



#parec[
  where $V$ is a visibility function that is 1 if the ray from $p$ in direction $omega_i$ hits the light source and 0 if it misses or is occluded by another object. If we sample the triangle uniformly within the solid angle that it subtends from the reference point, we end up with the estimator
][
  其中 $V$ 是一个可见性函数，如果从 $p$ 出发的光线在方向 $omega_i$ 上击中光源，则可见性函数为 1；如果错过或被其他物体遮挡，则为 0。如果我们在从参考点出发的立体角范围内均匀采样三角形，那么我们得到估计器
]

$ frac(rho L_e, A_(upright("solid"))) (V (p , omega_i) lr(|cos theta prime|)) $


#parec[
  where $A_(upright("solid"))$ is the subtended solid angle. The constant values have been pulled out, leaving just the two factors in parentheses that vary based on $p$. They are the only source of variance in estimates of the integral.
][
  其中 $A_(upright("solid"))$ 是张角。常数值已被提取出来，只剩下括号内的两个因子，它们根据 $p$ 变化，是积分估计中唯一的方差来源。
]

#parec[
  As an alternative, consider a Monte Carlo estimate of this function where a point $p prime$ has been uniformly sampled on the surface of the triangle. If the triangle's area is $A$, then the PDF is $p (p prime) = 1 / A$. Applying the standard Monte Carlo estimator and defining a new visibility function $V$ that is between two points, we end up with
][
  作为替代方案，考虑该函数的蒙特卡罗估计，其中点 $p prime$ 已在三角形表面上均匀采样。如果三角形的面积是 $A$，则 PDF 为 $p (p prime) = 1 / A$。应用标准蒙特卡罗估计器，并定义一个在两个点之间的新的可见性函数 $V$，我们得到
]


#parec[
  StartFraction L\_{e} / A EndFraction ( V(p, p') ) | ' | StartFraction | \_{l} | p' - p ^{2} EndFraction,
][
  开始分数 L\_{e} / A 结束分数 ( V(p, p') ) | ' | 开始分数 | \_{l} | p' - p ^{2} 结束分数，
]

#parec[
  where the last factor accounts for the change of variables and where $cos theta_l$ is the angle between the light source's surface normal and the vector between the two points. The values of the four factors inside the parentheses in this estimator all depend on the choice of $p prime$.
][
  其中最后一个因子考虑了变量的变化，并且 $cos theta_l$ 是光源表面法线与两点之间向量的夹角。在此估计器中括号内的四个因子的值都取决于 $p prime$ 的选择。
]

#parec[
  With area sampling, the $lr(|cos theta_l|)$ factor adds some additional variance, though not too much, since it is between 0 and 1. However, $frac(1, parallel p prime - p parallel^2)$ can have unbounded variation over the surface of the triangle, which can lead to high variance in the estimator since the method used to sample $p prime$ does not account for it at all.
][
  使用面积采样时， $lr(|cos theta_l|)$ 因子会增加一些额外的方差，但不会太多，因为它在 0 和 1 之间。然而， $frac(1, parallel p prime - p parallel^2)$ 在三角形表面上可能有无限的变化，这可能导致估计器中的高方差，因为用于采样 $p prime$ 的方法完全没有考虑到这一点。
]

#parec[
  This variance increases the larger the triangle is and the closer the reference point is to it. Figure #link("<fig:solid-angle-triangle-sampling-win>")[6.16] shows a scene where solid angle sampling significantly reduces error.
][
  这个方差随着三角形的增大和参考点与其接近而增加。图 #link("<fig:solid-angle-triangle-sampling-win>")[6.16] 显示了一个场景，其中实体角采样显著减少了误差。
]

#parec[
  When points on triangles are sampled using uniform area sampling, error is high at points on the ground close to the emitter. If points are sampled on the triangle by uniformly sampling the solid angle the triangle subtends, then the remaining non-constant factors in the estimator are both between 0 and 1, which results in much lower error.
][
  当使用均匀面积采样对三角形上的点进行采样时，靠近发射器的地面上的点误差很高。如果通过均匀采样三角形所覆盖的实体角来对三角形上的点进行采样，那么估计器中剩余的非常数因子都在 0 和 1 之间，这导致误差大大降低。
]

#parec[
  For this scene, mean squared error (MSE) is reduced by a factor of $3.86$. #emph[(Dragon model courtesy of the Stanford Computer Graphics
Laboratory.)]
][
  对于这个场景，均方误差（MSE）减少了 $3.86$ 倍。 #emph[(龙模型由斯坦福计算机图形实验室提供。)]
]

#parec[
  The `Triangle::Sample()` method that takes a reference point therefore samples a point according to solid angle.
][
  因此，`Triangle::Sample()` 方法通过实体角采样一个参考点。
]

```cpp
<<Triangle Public Methods>>+=
pstd::optional<ShapeSample> Sample(const ShapeSampleContext &ctx,
                                   Point2f u) const {
    <<Get triangle vertices in p0, p1, and p2>>
    <<Use uniform area sampling for numerically unstable cases>>
    <<Sample spherical triangle from reference point>>
    <<Compute error bounds pError for sampled point on triangle>>
    <<Return ShapeSample for solid angle sampled point on triangle>>
}
```


$
  upright(bold(n)) a\
  b = frac(upright(bold(a)) times upright(bold(b)), lr(||) upright(bold(a)) times upright(bold(b)) lr(||)) ,
$


#parec[
  and similarly for the other edges. If any of these normals are degenerate, then the triangle has zero area.
][
  其他边的法线计算方法类似。如果这些法线中的任何一个是退化的法线，那么三角形的面积为零。
]

#parec[
  #block[
    \<\<Compute normalized cross products of all direction pairs\>\>=~
  ]
][
  #block[
    \<\<计算所有方向对的归一化叉积\>\>=~
  ]
]


$ gamma prime = A prime_pi - alpha - beta prime $



#parec[
  Substituting this equality in Equation (6.8) and solving for \$ \$ gives
][
  将此等式代入方程 (6.8) 并求解 \$ \$ 得到
]

$
  upright(bold(overline(b prime))) = frac(cos beta prime + cos (A prime_pi - alpha - beta prime) cos alpha, sin (A prime_pi - alpha - beta prime) sin alpha)
$


#parec[
  Defining \$ = A'\_{} - \$ to simplify notation, we have
][
  定义 \$ = A'\_{} - \$ 以简化符号，我们有
]

$
  upright(bold(overline(b prime))) = frac(cos beta prime + cos (phi.alt - beta prime) cos alpha, sin (phi.alt - beta prime) sin alpha)
$


#parec[
  The cosine and sine sum identities then give
][
  余弦和正弦的和公式然后给出
]

$
  upright(bold(overline(b prime))) = frac(cos beta prime + (cos phi.alt cos beta prime + sin phi.alt sin beta prime) cos alpha, (sin phi.alt cos beta prime - cos phi.alt sin beta prime) sin alpha)
$

#parec[
  The only remaining unknowns on the right hand side are the sines and cosines of \$ ' \$.
][
  右侧唯一剩余的未知数是 \$ ' \$ 的正弦和余弦值。
]

#parec[
  To find \$ ' \$ and \$ ' \$, we can use another spherical cosine law, which gives the equality
][
  为了求出 \$ ' \$ 和 \$ ' \$，我们可以使用另一个球面余弦定律，该定律给出等式
]

$ cos gamma prime = - cos beta prime cos alpha + sin beta prime sin alpha upright(bold(overline(c))) $



#parec[
  It can be simplified in a similar manner to find the equation
][
  可以用类似的方法简化以得到方程形式
]

$ 0 = (cos phi.alt + cos alpha) cos beta prime + (sin phi.alt - sin alpha upright(bold(overline(c)))) sin beta prime $


#parec[
  The terms in parentheses are all known. We will denote them by \$ k\_1 = \+ \$ and \$ k\_2 = - \$. It is then easy to see that solutions to the equation
][
  括号中的项都是已知的。我们将它们表示为 \$ k\_1 = + \$ 和 \$ k\_2 = - \$。然后很容易看出方程的解为
]

$ 0 = k_1 cos beta prime + k_2 sin beta prime $



#parec[
  are given by
][
  由以下给出
]

$
  cos beta prime = frac(plus.minus k_2, sqrt(k_1^2 + k_2^2)) quad upright("and") quad sin beta prime = frac(minus.plus k_1, sqrt(k_1^2 + k_2^2))
$


#parec[
  Substituting these into Equation (6.9), taking the solution with a positive cosine, and simplifying gives
][
  将这些代入方程 (6.9)，取正余弦的解并简化得到
]

$
  upright(bold(overline(b prime))) = frac(k_2 + (k_2 cos phi.alt - k_1 sin phi.alt) cos alpha, (k_2 sin phi.alt + k_1 cos phi.alt) sin alpha)
$


#parec[
  which finally has only known values on the right hand side.
][
  这最终使得右侧只有已知值。
]

#parec[
  The code to compute this cosine follows directly from this solution. In it, we have also applied trigonometric identities to compute \$ \$ and \$ \$ in terms of other sines and cosines.
][
  计算此余弦的代码直接来源于此解。在其中，我们还应用了三角恒等式来计算 \$ \$ 和 \$ \$ 以其他正弦和余弦表示。
]

```cpp
<<Find  for point along b for sampled area>>=
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
  The arc of the great circle between the two points \$ \$ and \$ \$ can be parameterized by \$ + ^\$, where \$ ^\$ is the normalized perpendicular component of
][
  两点 \$ \$ 和 \$ \$ 之间的大圆弧可以通过 \$ + ^\$ 参数化，其中 \$ ^\$ 是 \$ \$ 关于 \$ \$ 的归一化垂直分量。
]

#parec[
  \$ \$ with respect to \$ \$. This vector is given by the
][
  此向量由之前介绍的
]

#parec[
  GramSchmidt() function introduced earlier, which makes the
][
  GramSchmidt() 函数给出，这使得
]

#parec[
  computation of \$ ' \$ straightforward. In this case, \$ \$ can then be found using \$ \$ with the
][
  \$ ' \$ 的计算变得简单。在这种情况下，可以使用 \$ \$ 和
]

#parec[
  Pythagorean identity, since we know that it must be nonnegative.
][
  毕达哥拉斯恒等式，因为我们知道它必须是非负的。
]
```cpp
<<Sample  along the arc between  and >>=
Float sinBp = SafeSqrt(1 - Sqr(cosBp));
Vector3f cp = cosBp * a + sinBp * Normalize(GramSchmidt(c, a));
```

#parec[
  For the sample points to be uniformly distributed in the spherical triangle, it can be shown that if the edge from \$ \$ to \$ ' \$ is
][
  为了使采样点在球面三角形中均匀分布，可以证明如果从 \$ \$ 到 \$ ' \$ 的边是
]

#parec[
  parameterized using \$ \$ in the same way as was used for the edge from \$ \$ to \$ \$, then \$ \$ should be sampled as
][
  用 \$ \$ 参数化，方式与从 \$ \$ 到 \$ \$ 的边相同，那么 \$ \$ 应该被采样为
]


$ cos theta = 1 - xi_1 (1 - (upright(bold(c)) prime dot.op upright(bold(b)))) . $


#parec[
  (The "Further Reading" section has pointers to the details.)
][
  （"延伸阅读"部分提供了详细信息的指引。）
]

#parec[
  With that, we can compute the final sampled direction \$ \$. The remaining step is to compute the barycentric coordinates for the sampled direction.
][
  有了这些，我们可以计算最终采样的方向 \$ \$。剩下的步骤是计算采样方向的重心坐标。
]

```cpp
Float cosTheta = 1 - u[1] * (1 - Dot(cp, b));
Float sinTheta = SafeSqrt(1 - Sqr(cosTheta));
Vector3f w = cosTheta * b + sinTheta * Normalize(GramSchmidt(cp, b));
<<Find barycentric coordinates for sampled direction w>>   Vector3f e1 = v[1] - v[0], e2 = v[2] - v[0];
   Vector3f s1 = Cross(w, e2);
   Float divisor = Dot(s1, e1);
   Float invDivisor = 1 / divisor;
   Vector3f s = p - v[0];
   Float b1 = Dot(s, s1) * invDivisor;
   Float b2 = Dot(w, Cross(s, e1)) * invDivisor;
<<Return clamped barycentrics for sampled direction>>   b1 = Clamp(b1, 0, 1);
   b2 = Clamp(b2, 0, 1);
   if (b1 + b2 > 1) {
       b1 /= b1 + b2;
       b2 /= b1 + b2;
   }
   return {Float(1 - b1 - b2), Float(b1), Float(b2)};
```


#parec[
  The barycentric coordinates of the corresponding point in the planar triangle can be found using part of a ray-triangle intersection algorithm that finds the barycentrics along the way (Möller and Trumbore 1997). It starts with equating the parametric form of the ray with the barycentric interpolation of the triangle's vertices \$ \_i \$,
][
  平面三角形中对应点的重心坐标可以通过射线-三角形相交算法的一部分找到，该算法在过程中找到重心坐标（Möller 和 Trumbore 1997）。它从将射线的参数形式与三角形顶点 \$ \_i \$ 的重心插值相等开始，
]

#parec[
  $
    upright(bold(n)) + t upright(bold(d)) = (
      1 - b_0 - b_1
    ) upright(bold(v))_0 + b_1 upright(bold(v))_1 + b_2 upright(bold(v))_2 ,
  $
][
  $
    upright(bold(n)) + t upright(bold(d)) = (
      1 - b_0 - b_1
    ) upright(bold(v))_0 + b_1 upright(bold(v))_1 + b_2 upright(bold(v))_2 ,
  $
]

#parec[
  expressing this as a matrix equation, and solving the resulting linear system for the barycentrics. The solution is implemented in the following fragment, which includes the result of factoring out various common subexpressions.
][
  将其表示为矩阵方程，并通过求解所得线性系统来求解重心坐标。解决方案在以下片段中实现，其中包括对各种常见子表达式进行因式分解的结果。
]

#parec[
  ```cpp
  Vector3f e1 = v[1] - v[0], e2 = v[2] - v[0];
  Vector3f s1 = Cross(w, e2);
  Float divisor = Dot(s1, e1);
  Float invDivisor = 1 / divisor;
  Vector3f s = p - v[0];
  Float b1 = Dot(s, s1) * invDivisor;
  Float b2 = Dot(w, Cross(s, e1)) * invDivisor;
  ```
][
  ```cpp
  Vector3f e1 = v[1] - v[0], e2 = v[2] - v[0];
  Vector3f s1 = Cross(w, e2);
  Float divisor = Dot(s1, e1);
  Float invDivisor = 1 / divisor;
  Vector3f s = p - v[0];
  Float b1 = Dot(s, s1) * invDivisor;
  Float b2 = Dot(w, Cross(s, e1)) * invDivisor;
  ```
]

#parec[
  The computed barycentrics may be invalid for very small and very large triangles. This happens rarely, but to protect against it, they are clamped to be within the triangle before they are returned.
][
  计算出的重心坐标可能对非常小和非常大的三角形无效。这种情况虽然很少发生，但为了避免这种情况，在返回之前将其限制在三角形内。
]

#parec[
  ```cpp
  b1 = Clamp(b1, 0, 1);
  b2 = Clamp(b2, 0, 1);
  if (b1 + b2 > 1) {
      b1 /= b1 + b2;
      b2 /= b1 + b2;
  }
  return {Float(1 - b1 - b2), Float(b1), Float(b2)};
  ```
][
  ```cpp
  b1 = Clamp(b1, 0, 1);
  b2 = Clamp(b2, 0, 1);
  if (b1 + b2 > 1) {
      b1 /= b1 + b2;
      b2 /= b1 + b2;
  }
  return {Float(1 - b1 - b2), Float(b1), Float(b2)};
  ```
]

#parec[
  As noted earlier, uniform solid angle sampling does not account for the incident cosine factor at the reference point. Indeed, there is no known analytic method to do so. However, it is possible to apply a warping function to the uniform samples $u$ that approximately accounts for this factor.
][
  如前所述，均匀立体角采样不考虑参考点的入射余弦因子。事实上，没有已知的解析方法可以做到这一点。然而，可以对均匀样本 $u$ 应用一个变换函数，以近似考虑该因子。
]

#parec[
  To understand the idea, first note that \$ \$ varies smoothly over the spherical triangle. Because the spherical triangle sampling algorithm that we have just defined maintains a continuous relationship between sample values and points in the triangle, then if we consider the image of the \$ \$ function back in the \$ \[0, 1\]^2 \$ sampling domain, as would be found by mapping it through the inverse of the spherical triangle sampling algorithm, the \$ \$ function is smoothly varying there as well. (See Figure 6.19.)
][
  为了理解这一想法，首先注意到 \$ \$ 在球面三角形上平滑变化。因为我们刚刚定义的球面三角形采样算法保持了样本值和三角形中点之间的连续关系，那么如果我们考虑 \$ \$ 函数在 \$ \[0, 1\]^2 \$ 采样域中的映像，通过球面三角形采样算法的逆映射找到，\$ \$ 函数在那里也是平滑变化的。（见图 6.19。）
]

#parec[
  ```markdown
  <span class="anchor" id="fig:spherical-triangle-cos-theta"/><div class="card outerfigure"><div class="card-body figure"><p>
  </p>
  <div class="figure-row">
    <a href="pha06f19.svg" title=""><img src="pha06f19.svg" width="761" height="301" style="max-width: 100%;"/></a>
  </div>
  <p>
  </p>
  <figcaption class="caption">Figure 6.19: <span class="legend">
  (a) The $ \cos \theta $ factor varies smoothly over the area of a spherical triangle.
  (b) If it is mapped back to the $ [0, 1]^2 $ sampling domain, it also varies smoothly there, thanks to the sampling algorithm not introducing any discontinuities or excessive distortion.</span></figcaption><p>

  </p>
  </div></div><p>

  </p>
  ```
][
  ```markdown
  <span class="anchor" id="fig:spherical-triangle-cos-theta"/><div class="card outerfigure"><div class="card-body figure"><p>
  </p>
  <div class="figure-row">
    <a href="pha06f19.svg" title=""><img src="pha06f19.svg" width="761" height="301" style="max-width: 100%;"/></a>
  </div>
  <p>
  </p>
  <figcaption class="caption">图 6.19: <span class="legend">
  (a) $ \cos \theta $ 因子在球面三角形的区域上平滑变化。
  (b) 如果将其映射回 $ [0, 1]^2 $ 采样域，由于采样算法没有引入任何不连续性或过度失真，它也在那里平滑变化。</span></figcaption><p>

  </p>
  </div></div><p>

  </p>
  ```
]

#parec[
  It can be shown through simple application of the chain rule that a suitable transformation of uniform \$ \[0, 1\]^2 \$ sample points can account for the \$ \$ factor. Specifically, if transformed points are distributed according to the distribution of \$ \$ in \$ \[0, 1\]^2 \$ and then used with the spherical triangle sampling algorithm, then the distribution of directions on the sphere will include the \$ \$ factor.
][
  通过简单应用链式法则可以证明，均匀 \$ \[0, 1\]^2 \$ 样本点的合适变换可以考虑 \$ \$ 因子。具体来说，如果变换后的点根据 \$ \$ 在 \$ \[0, 1\]^2 \$ 中的分布进行分布，然后与球面三角形采样算法一起使用，那么球面上的方向分布将包括 \$ \$ 因子。
]

#parec[
  The true function has no convenient analytic form, but because it is smoothly varying, here we will approximate it with a bilinear function. Each corner of the \$ \[0, 1\]^2 \$ sampling domain maps to one of the three vertices of the spherical triangle, and so we set the bilinear function's value at each corner according to the \$ \$ factor computed at the associated triangle vertex.
][
  真实函数没有方便的解析形式，但因为它是平滑变化的，这里我们将用双线性函数来近似。\$ \[0, 1\]^2 \$ 采样域的每个角映射到球面三角形的三个顶点之一，因此我们根据在相关三角形顶点计算的 \$ \$ 因子在每个角设置双线性函数的值。
]

#parec[
  Sampling a point in the triangle then proceeds by using the initial uniform sample to sample the bilinear distribution and to use the resulting nonuniform point in \$ \[0, 1\]^2 \$ with the triangle sampling algorithm. (See Figure 6.20.)
][
  然后，通过使用初始均匀样本来采样双线性分布，并使用所得的非均匀点在 \$ \[0, 1\]^2 \$ 中与三角形采样算法一起使用来采样三角形中的一个点。（见图 6.20。）
]

#parec[
  ```markdown
  <span class="anchor" id="fig:spherical-triangle-approx-cos"/><div class="card outerfigure"><div class="card-body figure"><p>
  </p>
  <div class="figure-row">
    <a href="pha06f20.svg" title=""><img src="pha06f20.svg" width="994" height="304" style="max-width: 100%;"/></a>
  </div>
  <p>
  </p>
  <figcaption class="caption">Figure 6.20: <span class="legend">
  If (a) uniform sample points are warped to (b) approximate the distribution of the incident cosine factor in $ [0, 1]^2 $ before being used with the spherical triangle sampling algorithm, then (c) the resulting points in the triangle are approximately cosine-distributed.</span></figcaption><p>

  </p>
  </div></div><p>

  </p>
  ```
][
  ```markdown
  <span class="anchor" id="fig:spherical-triangle-approx-cos"/><div class="card outerfigure"><div class="card-body figure"><p>
  </p>
  <div class="figure-row">
    <a href="pha06f20.svg" title=""><img src="pha06f20.svg" width="994" height="304" style="max-width: 100%;"/></a>
  </div>
  <p>
  </p>
  <figcaption class="caption">图 6.20: <span class="legend">
  如果 (a) 均匀样本点被扭曲为 (b) 近似入射余弦因子在 $ [0, 1]^2 $ 中的分布，然后与球面三角形采样算法一起使用，那么 (c) 三角形中的结果点大致为余弦分布。</span></figcaption><p>

  </p>
  </div></div><p>

  </p>
  ```
]

#parec[
  Applying the principles of transforming between distributions that were introduced in Section 2.4.1, we can find that the overall PDF of such a sample is given by the product of the PDF for the bilinear sample and the PDF of the spherical triangle sample.
][
  应用在第 2.4.1 节中介绍的在分布之间转换的原理，我们可以发现这样的样本的总体 PDF 由双线性样本的 PDF 和球面三角形样本的 PDF 的乘积给出。
]

#parec[
  This technique is only applied for reference points on surfaces. For points in scattering media, the surface normal ShapeSampleContext::ns is degenerate and no sample warping is applied.
][
  这种技术仅适用于表面上的参考点。对于散射介质中的点，表面法线 ShapeSampleContext::ns 是退化的，不应用样本扭曲。
]

```cpp
<<Apply warp product sampling for cosine factor at reference point>>=
Float pdf = 1;
if (ctx.ns != Normal3f(0, 0, 0)) {
    <<Compute -based weights w at sample domain corners>>
    u = SampleBilinear(u, w);
    pdf = BilinearPDF(u, w);
}
```

