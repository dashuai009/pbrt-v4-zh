#import "../template.typ": parec

== BasicScene and Final Object Creation
<c.3-basicscene-and-final-object-creation>


#parec[
  The responsibilities of the `BasicScene` are straightforward: it takes
  scene entity objects and provides methods that convert them into objects
  for rendering. However, there are two factors that make its
  implementation not completely trivial. First, as discussed in Section
  #link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#sec:basic-scene-builder")[C.2];,
  if the Import directive is used in the scene specification, there may be
  multiple
  #link("../Processing_the_Scene_Description/Managing_the_Scene_Description.html#BasicSceneBuilder")[BasicSceneBuilder]
  that are concurrently calling `BasicScene` methods. Therefore, the
  implementation must use mutual exclusion to ensure correct operation.

][
  BasicScene
  的职责很简单：它接收场景实体对象，并提供将它们转换为用于渲染的对象的方法。但有两个因素使得实现并非完全简单。首先，如在第
  \[C.2\] 节所述，如果在场景规范中使用 Import 指令，可能会有多个
  \[BasicSceneBuilder\] 同时调用 BasicScene
  的方法。因此实现必须使用互斥锁（mutex）以确保正确运行。
]

#parec[
  The second consideration is performance: we would like to minimize the
  time spent in the execution of the `BasicScene` methods, as time spent
  in them delays parsing the remainder of the scene description. System
  startup time is a facet of performance that is worth attending to, and
  so `BasicScene` uses the asynchronous job capabilities introduced in
  Section
  #link("../Utilities/Parallelism.html#sec:async-jobs-and-futures")[B.6.6]
  to create scene objects while parsing proceeds when possible.

][
  第二个考虑因素是性能：希望尽量缩短 BasicScene
  方法的执行时间，因为它们的耗时会拖慢对场景描述其余部分的解析进程。系统启动时间是性能的一个方面，值得关注，因此
  BasicScene 在第 \[B.6.6\]
  节中引入的异步作业能力，在解析尽可能进行时，尽量并行创建场景对象。
]

```
class BasicScene {
  public:
    <<BasicScene Public Methods>>
    <<BasicScene Public Members>>
  private:
    <<BasicScene Private Methods>>
    <<BasicScene Private Members>>
};
```
```
void BasicScene::SetOptions(SceneEntity filter, SceneEntity film,
                            CameraSceneEntity camera, SceneEntity sampler,
                            SceneEntity integ, SceneEntity accel) {
    <<Store information for specified integrator and accelerator>>
    <<Immediately create filter and film>>
    <<Enqueue asynchronous job to create sampler>>
    <<Enqueue asynchronous job to create camera>>
}
```
#parec[
  When `SetOptions()` is called, the specifications of the geometry and
  lights in the scene have not yet been parsed. Therefore, it is not yet
  possible to create the integrator (which needs the lights) or the
  acceleration structure (which needs the geometry). Therefore, their
  specification so far is saved in member variables for use when parsing
  is finished.

][
  当 SetOptions()
  被调用时，场景中的几何信息与光源的规格尚未被解析。因此，无法先创建需要光源信息的积分器，或需要几何信息的加速结构。因此，它们的规格信息先保存到成员变量中，待解析完成时再使用。
]

```
integrator = integ;
accelerator = accel;
```
```
SceneEntity integrator, accelerator;
```
#parec[
  However, it is possible to start work on creating the `Sampler`,
  `Camera`, `Filter`, and `Film`. While they could all be created in turn
  in the `SetOptions()` method, we instead use `RunAsync()` to launch
  multiple jobs to take care of them. Thus, the `SetOptions()` method can
  return quickly, allowing parsing to resume, and creation of those
  objects can proceed in parallel as parsing proceeds if there are
  available CPU cores. Although these objects usually take little time to
  initialize, sometimes they do not: the `RealisticCamera` requires a
  second or so on a current CPU to compute exit pupil bounds and the
  `HaltonSampler` takes approximately 0.1 seconds to initialize its random
  permutations. If that work can be done concurrently with parsing the
  scene, rendering can begin that much more quickly.

][
  然而，可以开始着手创建 Sampler、Camera、滤波器和 Film。虽然它们都可以在
  SetOptions() 方法中轮流创建，但我们改为使用 RunAsync()
  启动多个作业来处理它们。因此，SetOptions()
  方法可以快速返回，允许解析继续进行，并且在有可用的 CPU
  核心时，这些对象的创建可以与解析并行进行。尽管这些对象通常初始化所需时间较短，但也有例外：RealisticCamera
  需要在当前 CPU 上大约一秒的时间来计算出口瞳孔边界，HaltonSampler
  初始化其随机排列大约需要 0.1
  秒。如果这部分工作能够与解析并行完成，渲染就可以大幅提前开始。
]

```
samplerJob = RunAsync([sampler, this]() {
    Allocator alloc = threadAllocators.Get();
    Point2i res = this->film.FullResolution();
    return Sampler::Create(sampler.name, sampler.parameters, res,
                           &sampler.loc, alloc);
});
```
#parec[
  The `AsyncJob *` returned by `RunAsync()` is held in a member variable.
  The `BasicScene` constructor also initializes `threadAllocators` so that
  appropriate memory allocators are available depending on whether the
  scene objects should be stored in CPU memory or GPU memory.

][
  `RunAsync()` 返回的 `AsyncJob *` 保存在一个成员变量中。`BasicScene`
  的构造函数也会初始化 `threadAllocators`，以便在场景对象应存储在 CPU
  内存还是 GPU 内存时提供合适的内存分配器。
]

```
std::mutex samplerJobMutex;
Sampler sampler;
```
#parec[
  Briefly diverting from the `BasicScene` implementation, we will turn to
  the `Sampler::Create()` method that is called in the job that creates
  the `Sampler`. (This method is defined in the file
  https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/samplers.cpp with
  the rest of the `Sampler` code.) It checks the provided sampler name
  against all the sampler names it is aware of, calling the appropriate
  object-specific creation method when it finds a match and issuing an
  error if no match is found. Thus, if the system is to be extended with
  an additional sampler, this is a second place in the code where the
  existence of the new sampler must be registered.

][
  简要离题，我们将转向在创建 Sampler 的作业中调用的 Sampler::Create()
  方法。（此方法在文件
  https:\/\/github.com/mmp/pbrt-v4/tree/master/src/pbrt/samplers.cpp
  与其余 Sampler
  代码一起定义。）它将提供的采样器名称与它所知的所有采样器名称进行比对，在找到匹配项时调用相应的对象特定创建方法；如果没有匹配项则发出错误。因此，如果系统要通过添加额外的采样器进行扩展，这是代码中需要再次注册新采样器存在性的第二个位置。
]

```
Sampler Sampler::Create(const std::string &name,
        const ParameterDictionary &parameters, Point2i fullRes,
        const FileLoc *loc, Allocator alloc) {
    Sampler sampler = nullptr;
    if (name == "zsobol")
        sampler = ZSobolSampler::Create(parameters, fullRes, loc, alloc);
    <<Create remainder of Sampler types>>
    return sampler;
}
```
#parec[
  The fragment that handles the remainder of types of samplers, \<\>, is
  not included here.

][
  处理其余类型的采样器的片段：\<\> 在此未包含。
]

#parec[
  All the other base interface classes like `Light`, `Shape`, `Camera`,
  and so forth provide corresponding `Create()` methods, all of which have
  the same general form.

][
  所有其他基础接口类，如 `Light`、`Shape`、`Camera` 等，均提供相应的
  `Create()` 方法，形式大致相同。
]

#parec[
  `BasicScene` also provides methods that return these asynchronously
  created objects. All have a similar form, acquiring a mutex before
  harvesting the result from the asynchronous job if needed. Calling code
  should delay calling these methods as long as possible, doing as much
  independent work as it can to increase the likelihood that the
  asynchronous job has completed and that the `AsyncJob::GetResult()`
  calls do not stall.

][
  `BasicScene`
  还提供返回这些异步创建对象的方法。它们的形式都类似，在必要时在从异步作业获取结果之前先获取互斥锁。调用代码应尽量延迟调用这些方法，尽量多做独立工作，以提高异步作业完成的可能性，并避免
  `AsyncJob::GetResult()` 调用造成阻塞。
]

```
Sampler GetSampler() {
    samplerJobMutex.lock();
    while (!sampler) {
        pstd::optional<Sampler> s = samplerJob->TryGetResult(&samplerJobMutex);
        if (s)
            sampler = *s;
    }
    samplerJobMutex.unlock();
    return sampler;
}
```
```
std::mutex samplerJobMutex;
Sampler sampler;
```
#parec[
  Medium creation is also based on RunAsync()’s asynchronous job capabilities, though in that case a std::map of jobs is maintained, one for each medium. Note that it is important that a mutex be held when storing the AsyncJob \* returned by RunAsync() in mediumJobs, since multiple threads may call this method concurrently if Import statements are used for multi-threaded parsing.
][
  Medium 的创建同样依赖于 `RunAsync()` 的异步任务功能，不过在这种情况下会维护一个 `std::map` 来存储任务，每个 medium 对应一个任务。需要注意的是，当将 `RunAsync()` 返回的 `AsyncJob*` 存入 `mediumJobs` 时，必须持有互斥锁（mutex），因为如果使用 Import 语句进行多线程解析时，可能会有多个线程同时调用该方法。
]

```cpp
void BasicScene::AddMedium(MediumSceneEntity medium) {
    <<Define create lambda function for Medium creation>>
    std::lock_guard<std::mutex> lock(mediaMutex);
    mediumJobs[medium.name] = RunAsync(create);
}
```

```
std::mutex mediaMutex;
std::map<std::string, AsyncJob<Medium>* > mediumJobs;
```
#parec[
  Creation of each `Medium` follows a similar form to `Sampler` creation,
  though here the type of medium to be created is found from the parameter
  list; the `MediumSceneEntity::name` member variable holds the
  user-provided name to associate with the medium.

][
  每个 Medium 的创建遵循与 Sampler
  创建类似的形式，尽管这里要创建的介质类型从参数列表中找到；MediumSceneEntity::name
  成员变量保存用户提供的用于与介质关联的名称。
]

```
<<Define create lambda function for Medium creation>>
auto create = [medium, this]() {
    std::string type = medium.parameters.GetOneString("type", "");
    <<Check for missing medium "type" or animated medium transform>>
    return Medium::Create(type, medium.parameters,
                          medium.renderFromObject.startTransform,
                          &medium.loc, threadAllocators.Get());
};
```
#parec[
  All the media specified in the scene are provided to callers via a map
  from names to `Medium` objects.

][
  场景中指定的所有介质通过名称映射到 Medium 对象提供给调用方。
]

```
std::map<std::string, Medium> BasicScene::CreateMedia() {
    mediaMutex.lock();
    if (!mediumJobs.empty()) {
        <<Consume results for asynchronously created Medium objects>>
    }
    mediaMutex.unlock();
    return mediaMap;
}
```
#parec[
  The asynchronously created `Medium` objects are consumed using calls to
  `AsyncJob::TryGetResult()`, which returns the result if it is available
  and otherwise unlocks the mutex, does some of the enqueued parallel
  work, and then relocks it before returning. Thus, there is no risk of
  deadlock from one thread holding `mediaMutex`, finding that the result
  is not ready and working on enqueued parallel work that itself ends up
  trying to acquire `mediaMutex`.

][
  通过 AsyncJob::TryGetResult() 的调用来获取异步创建的 Medium
  对象的结果；该方法在结果可用时返回结果，否则解锁互斥锁，执行排队的并行工作的一部分，然后在返回前重新加锁。因此，不会因为某个线程持有
  mediaMutex，发现结果尚不可用而在排队的并行工作中继续执行，最终导致再次尝试获取
  mediaMutex 而产生死锁。
]

```
for (auto &m : mediumJobs) {
    while (mediaMap.find(m.first) == mediaMap.end()) {
        pstd::optional<Medium> med = m.second->TryGetResult(&mediaMutex);
        if (med)
            mediaMap[m.first] = *med;
    }
}
mediumJobs.clear();
```
```
std::map<std::string, Medium> mediaMap;
```
#parec[
  As much as possible, other scene objects are created similarly using
  `RunAsync()`. Light sources are easy to handle, and it is especially
  helpful to start creating image textures during parsing, as reading
  image file formats from disk can be a bottleneck for scenes with many
  such textures. However, extra attention is required due to the cache of
  images already read for textures (Section 10.4.1). If an image file on
  disk is used in multiple textures, `BasicScene` takes care not to have
  multiple jobs redundantly reading the same image. Instead, only one
  reads it and the rest wait. When those textures are then created, the
  image they need can be efficiently returned from the cache.

][
  尽可能地，其他场景对象也使用 RunAsync()
  以类似方式创建。光源处理起来很容易，在解析阶段开始创建图像纹理特别有用，因为从磁盘读取图像文件格式可能成为具有大量此类纹理的场景的瓶颈。然而，由于纹理所用的图像可能已被缓存（见第
  10.4.1
  节），需要额外关注。如果磁盘上的图像文件被多处纹理使用，BasicScene
  会避免让多个作业重复读取同一图像。相反，只有一个线程读取该图像，其余线程等待读取完成。当这些纹理被创建时，它们所需的图像可以从缓存中高效返回。
]

#parec[
  In return for the added complexity of this asynchronous object creation,
  we have found that for complex scenes it is not unusual for this version
  of pbrt to be able to start rendering roughly 4 times more quickly than
  the previous version.

][
  作为对这种异步对象创建带来的额外复杂性的回报，我们发现对于复杂场景，这个版本的
  pbrt 大约能比上一版本提前四倍开始渲染。
]

