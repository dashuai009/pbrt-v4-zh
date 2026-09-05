#import "../template.typ": parec, ez_caption

== #ez_caption[Camera Interface][相机接口]
<camera-interface>
#parec[
  The #link(<Camera>)[`Camera`] class uses the usual #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`]-based approach to dynamically dispatch interface method calls to the correct implementation based on the actual type of the camera. (As usual, we will not include the implementations of those methods in the book here.) `Camera` is defined in the file #link("https://github.com/mmp/pbrt-v4/tree/master/src/base/camera.h")[base/camera.h].
][
  #link(<Camera>)[Camera] 类使用常规的 #link("https://pbr-book.org/4ed/Utilities/Containers_and_Memory_Management.html#TaggedPointer")[`TaggedPointer`] 方法，根据相机的实际类型动态分派接口方法调用到正确的实现。（和往常一样，我们不会在书中包含这些方法的实现。）`Camera` 定义在文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/base/camera.h")[base/camera.h] 中。
]

#block(sticky: true)[#raw("<<Camera Definition>>=")] <fragment-CameraDefinition-0>
#block(breakable: false)[
```cpp
class Camera : public TaggedPointer<PerspectiveCamera, OrthographicCamera,
                                    SphericalCamera, RealisticCamera> {
  public:
    <<Camera Interface>>
};
```
] <Camera>


#parec[
  The first method that cameras must implement is `GenerateRay()`, which computes the ray corresponding to a given image sample. It is important that the direction component of the returned ray be normalized—many other parts of the system will depend on this behavior. If for some reason there is no valid ray for the given #link(<CameraSample>)[CameraSample], then the `pstd::optional` return value should be unset. The #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[SampledWavelengths] for the ray are passed as a non-`const` reference so that cameras can model dispersion in their lenses, in which case only a single wavelength of light is tracked by the ray and the `GenerateRay()` method will call #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`].
][
  相机必须实现的第一个方法是 `GenerateRay()`，它计算与给定图像样本对应的光线。返回射线的方向向量必须归一化，系统的许多其他部分都依赖这一约定。如果给定的 #link(<CameraSample>)[`CameraSample`] 因某种原因没有对应的有效射线，就应返回空的 `pstd::optional`。光线的 #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths")[`SampledWavelengths`] 作为非 `const` 引用传递，以便相机可以在其镜头中模拟色散，在这种情况下，仅跟踪单一波长的光线，并且 `GenerateRay()` 方法将调用 #link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Representing_Spectral_Distributions.html#SampledWavelengths::TerminateSecondary")[`SampledWavelengths::TerminateSecondary()`]。
]

#block(sticky: true)[#raw("<<Camera Interface>>=") #link(<fragment-CameraInterface-1>)[↓]] <fragment-CameraInterface-0>
#block(breakable: false)[
```cpp
pstd::optional<CameraRay> GenerateRay(CameraSample sample,
                                      SampledWavelengths &lambda) const;
```
]


#parec[
  The #link(<CameraSample>)[`CameraSample`] structure that is passed to `GenerateRay()` holds all the sample values needed to specify a camera ray. Its `pFilm` member gives the point on the film to which the generated ray should carry radiance. The point on the lens the ray passes through is in `pLens` (for cameras that include the notion of lenses), and `time` gives the time at which the ray should sample the scene. If the camera itself is in motion, the `time` value determines what camera position to use when generating the ray.
][
  传递给 `GenerateRay()` 的 #link(<CameraSample>)[`CameraSample`] 结构包含指定相机光线所需的所有样本值。其 `pFilm` 成员给出胶片上的目标点，生成的射线应将辐亮度传递到该点。 `pLens` 给出射线在镜头上通过的位置（对于包含镜头概念的相机），`time` 给出光线应采样场景的时间。如果相机本身在运动，`time` 值决定生成光线时使用的相机的位置。
]

#parec[
  Finally, the `filterWeight` member variable is an additional scale factor that is applied when the ray's radiance is added to the image stored by the film; it accounts for the reconstruction filter used to filter image samples at each pixel. This topic is discussed in @filtering-image-samples and @image-reconstruction.
][
  最后，`filterWeight` 成员变量是一个附加的比例因子，当光线的辐亮度添加到胶片存储的图像时应用；它计入了对各像素的图像样本进行滤波时所用的重建滤波器。此主题在 @filtering-image-samples 和 @image-reconstruction 中讨论。
]

#block(sticky: true)[#raw("<<CameraSample Definition>>=")] <fragment-CameraSampleDefinition-0>
#block(breakable: false)[
```cpp
struct CameraSample {
    Point2f pFilm;
    Point2f pLens;
    Float time = 0;
    Float filterWeight = 1;
};
```
] <CameraSample>

#parec[
  The `CameraRay` structure that is returned by `GenerateRay()` includes both a ray and a spectral weight associated with it. Simple camera models leave the weight at the default value of one, while more sophisticated ones like `RealisticCamera` return a weight that is used in modeling the radiometry of image formation. (@the-camera-measurement-equation contains more information about how exactly this weight is computed and used in the latter case.)
][
  `GenerateRay()` 返回的 `CameraRay` 结构包括光线及其相关的光谱权重。简单的相机模型将权重保持在默认值一，而更复杂的模型如 `RealisticCamera` 返回一个用于模拟成像过程辐射度学关系的权重。（@the-camera-measurement-equation 进一步说明了后一种情况下该权重的具体计算和用法。）
]

#block(sticky: true)[#raw("<<CameraRay Definition>>=")] <fragment-CameraRayDefinition-0>
#block(breakable: false)[
```cpp
struct CameraRay {
    Ray ray;
    SampledSpectrum weight = SampledSpectrum(1);
};
```
] <CameraRay>


#parec[
  Cameras must also provide an implementation of `GenerateRayDifferential()`, which computes a main ray like `GenerateRay()` but also computes the corresponding rays for pixels shifted one pixel in the $x$ and $y$ directions on the film plane. This information about how camera rays change as a function of position on the film helps give other parts of the system a notion of how much of the film area a particular camera ray's sample represents, which is useful for antialiasing texture lookups.
][
  相机还必须提供 `GenerateRayDifferential()` 的实现，它与 `GenerateRay()` 一样计算主射线，还计算胶片平面上分别沿 $x$ 和 $y$ 方向偏移一个像素后对应的射线。关于相机光线如何随胶片位置变化的信息，有助于系统的其他部分理解特定相机光线样本代表的胶片区域的大小，这有助于对纹理查询进行抗锯齿处理。
]

#block(sticky: true)[#raw("<<Camera Interface>>+=") #link(<fragment-CameraInterface-0>)[↑] #link(<fragment-CameraInterface-2>)[↓]] <fragment-CameraInterface-1>
#block(breakable: false)[
```cpp
pstd::optional<CameraRayDifferential> GenerateRayDifferential(
    CameraSample sample, SampledWavelengths &lambda) const;
```
]

#parec[
  `GenerateRayDifferential()` returns an instance of the #link(<CameraRayDifferential>)[CameraRayDifferential] structure, which is equivalent to #link(<CameraRay>)[`CameraRay`], except it stores a #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#RayDifferential")[`RayDifferential`].
][
  `GenerateRayDifferential()` 返回一个 #link(<CameraRayDifferential>)[CameraRayDifferential] 结构的实例，它等同于 #link(<CameraRay>)[`CameraRay`]，但存储一个 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Rays.html#RayDifferential")[`RayDifferential`]。
]

#block(sticky: true)[#raw("<<CameraRayDifferential Definition>>=")] <fragment-CameraRayDifferentialDefinition-0>
#block(breakable: false)[
```cpp
struct CameraRayDifferential {
    RayDifferential ray;
    SampledSpectrum weight = SampledSpectrum(1);
};
```
] <CameraRayDifferential>

#parec[
  Camera implementations must provide access to their #link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`], which allows other parts of the system to determine things such as the resolution of the output image.
][
  相机实现必须提供对其 #link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`] 的访问，这允许系统的其他部分确定输出图像的分辨率等信息。
]

#block(sticky: true)[#raw("<<Camera Interface>>+=") #link(<fragment-CameraInterface-1>)[↑] #link(<fragment-CameraInterface-3>)[↓]] <fragment-CameraInterface-2>
#block(breakable: false)[
```cpp
Film GetFilm() const;
```
]

#parec[
  Just like real-world cameras, `pbrt`'s camera models include the notion of a shutter that opens for a short period of time to expose the film to light. One result of this nonzero exposure time is #emph[motion blur]: objects that are in motion relative to the camera during the exposure are blurred. Time is yet another thing that is amenable to point sampling and Monte Carlo integration: given an appropriate distribution of ray times between the shutter open time and the shutter close time, it is possible to compute images that exhibit motion blur.
][
  就像真实世界的相机一样，`pbrt` 的相机模型包括快门的概念，快门在短时间内打开以使胶片暴露在光下。这种非零曝光时间的一个结果是#emph[运动模糊]：在曝光期间相对于相机运动的物体会变得模糊。时间也是适合点采样和蒙特卡洛积分的一个因素：给定快门开闭之间光线的时间的适当分布，可以计算出具有运动模糊的图像。
]

#parec[
  The `SampleTime()` interface method should therefore map a uniform random sample `u` in the range $lr([0,1))$ to a time when the camera's shutter is open. Normally, it is just used to linearly interpolate between the shutter open and close times.
][
  因此，`SampleTime()` 接口方法应将范围 $lr([0,1))$ 内的均匀随机样本 `u` 映射到相机快门打开时的时间。通常，它仅用于在快门打开和关闭时间之间进行线性插值。
]

#block(sticky: true)[#raw("<<Camera Interface>>+=") #link(<fragment-CameraInterface-2>)[↑] #link(<fragment-CameraInterface-4>)[↓]] <fragment-CameraInterface-3>
#block(breakable: false)[
```cpp
Float SampleTime(Float u) const;
```
]

#parec[
  The last interface method allows camera implementations to set fields in the #link("https://pbr-book.org/4ed/Utilities/Images.html#ImageMetadata")[`ImageMetadata`] class to specify transformation matrices related to the camera. If the output image format has support for storing this sort of auxiliary information, it will be included in the final image that is written to disk.
][
  最后一个接口方法允许相机实现设置 #link("https://pbr-book.org/4ed/Utilities/Images.html#ImageMetadata")[`ImageMetadata`] 类中的字段，以指定与相机相关的变换矩阵。如果输出图像格式支持存储此类辅助信息，它将包含在写入磁盘的最终图像中。
]

#block(sticky: true)[#raw("<<Camera Interface>>+=") #link(<fragment-CameraInterface-3>)[↑] #link(<fragment-CameraInterface-5>)[↓]] <fragment-CameraInterface-4>
#block(breakable: false)[
```cpp
void InitMetadata(ImageMetadata *metadata) const;
```
]


=== #ez_caption[Camera Coordinate Spaces][相机坐标空间]
<camera-coordinate-spaces>

#parec[
  Before we start to describe the implementation of `pbrt`'s camera models, we will define some of the coordinate spaces that they use. In addition to world space, which was introduced in @coordinate-systems , we will now introduce four additional coordinate spaces: #emph[object space], #emph[camera space], #emph[camera-world space], and #emph[rendering
space].#footnote[“Camera-world space” and “rendering space” are non-standard names, though we are unaware of generally accepted names for those coordinate spaces.] In sum, we have:
][
  在开始描述 `pbrt` 的相机模型实现之前，我们将定义它们使用的一些坐标空间。除了在@coordinate-systems 中介绍的世界空间之外，我们现在将介绍四个额外的坐标空间：#emph[对象空间]、#emph[相机空间]、#emph[相机-世界空间]和#emph[渲染空间]。#footnote[“相机-世界空间”和“渲染空间”并非标准名称，不过据我们所知，这两个坐标空间尚无普遍认可的名称。]具体如下：
]

#parec[
  - #emph[Object space:] This is the coordinate system in which geometric
    primitives are defined. For example, spheres in `pbrt` are defined to
    be centered at the origin of their object space.
][
  - #emph[对象空间：] 这是定义几何图元的坐标系统。例如，在 `pbrt` 中，球体被定义为以其对象空间的原点为中心。
]

#parec[
  - #emph[World space:] While each primitive may have its own object
    space, all objects in the scene are placed in relation to a single
    world space. A world-from-object transformation determines where each
    object is located in world space. World space is the standard frame
    that all other spaces are defined in terms of.
][
  - #emph[世界空间：] 虽然每个图元可能有其自己的对象空间，但场景中的所有对象都相对于单一的世界空间放置。对象到世界的变换决定了每个对象在世界空间中的位置。世界空间是定义其他所有空间的基准标架。
]

#parec[
  - #emph[Camera space:] A camera is placed in the scene at some world
    space point with a particular viewing direction and orientation. This
    camera defines a new coordinate system with its origin at the camera's
    location. The $z$ axis of this coordinate system is mapped to the
    viewing direction, and the $y$ axis is mapped to the up direction.
][
  - #emph[相机空间：] 相机被放置在场景中的某个世界空间点，具有特定的观察方向和朝向。这个相机定义了一个新的坐标系统，其原点在相机的位置。这个坐标系统的 $z$ 轴映射到观察方向，$y$ 轴映射到向上方向。
]

#parec[
  - #emph[Camera-world space:] Like camera space, the origin of this
    coordinate system is the camera's position, but it maintains the
    orientation of world space (i.e., unlike camera space, the camera is
    not necessarily looking down the $z$ axis).
][
  - #emph[相机-世界空间：] 类似于相机空间，这个坐标系统的原点是相机的位置，但它保持世界空间中的朝向（即，与相机空间不同，相机不一定沿 $z$ 轴看）。
]

#parec[
  - #emph[Rendering space:] This is the coordinate system into which the
    scene is transformed for the purposes of rendering. In `pbrt`, it may
    be world space, camera space, or camera-world space.
][
  - #emph[渲染空间：] 这是为了渲染目的将场景转换到的坐标系统。在 `pbrt` 中，它可以是世界空间、相机空间或相机-世界空间。
]

#parec[
  Renderers based on rasterization traditionally do most of their computations in camera space: triangle vertices are transformed all the way from object space to camera space before being projected onto the screen and rasterized. In that context, camera space is a handy space for reasoning about which objects are potentially visible to the camera. For example, if an object's camera space bounding box is entirely behind the $z = 0$ plane (and the camera does not have a field of view wider than 180 degrees), the object will not be visible.
][
  基于光栅化的渲染器传统上大部分计算是在相机空间中进行的：三角形顶点从对象空间一直转换到相机空间，然后投影到屏幕上并进行光栅化。在这种情况下，相机空间便于判断哪些对象可能对相机可见。例如，如果一个对象在相机空间中的包围盒完全在 $z = 0$ 平面后面（并且相机的视野不超过 180 度），那么该对象将不可见。
]

#parec[
  Conversely, many ray tracers (including all versions of `pbrt` prior to this one) render in world space. Camera implementations may start out in camera space when generating rays, but they transform those rays to world space where all subsequent ray intersection and shading calculations are performed. A problem with that approach stems from the fact that floating-point numbers have more precision close to the origin than far away from it. If the camera is placed far from the origin, there may be insufficient precision to accurately represent the part of the scene that it is looking at.
][
  相反，许多光线追踪器（包括此版本之前的所有 `pbrt` 版本）在世界空间中渲染。相机实现可能在生成光线时从相机空间开始，但它们将这些光线转换到世界空间，在那里进行所有后续的射线求交和着色计算。这种方法的问题在于浮点数在靠近原点时比远离原点时具有更高的精度。如果相机远离原点放置，可能没有足够的精度来准确表示它所看的场景部分。
]

#parec[
  @fig:fp-precision-loss-far-from-origin illustrates the precision problem with rendering in world space. In @fig:fp-precision-loss-far-from-origin(a), the scene is rendered with the camera and objects as they were provided in the original scene specification, which happened to be in the range of $plus.minus 10$ in each coordinate in world space. In @fig:fp-precision-loss-far-from-origin(b), both the camera and the scene have been translated 1,000,000 units in each dimension. In principle, both images should be the same, but much less precision is available for the second viewpoint, to the extent that the discretization of floating-point numbers is visible in the geometric model.
][
  @fig:fp-precision-loss-far-from-origin 说明了在世界空间中渲染的精度问题。在 @fig:fp-precision-loss-far-from-origin(a) 中，场景使用原始场景规范中提供的相机和对象进行渲染，原场景的世界空间坐标恰好在各维的 $plus.minus 10$ 范围内。在 @fig:fp-precision-loss-far-from-origin(b) 中，相机和场景在每个维度上都被平移了 1,000,000 个单位。原则上，这两个图像应该是相同的，但对于第二个视点可用的精度要少得多，以至于浮点数的离散化在几何模型中是可见的。
]



#figure(
  table(columns: 1, stroke: none)[
    #image("../pbr-book-website/4ed/Cameras_and_Film/sportscar-original.png", width: 75%)
  ][#ez_caption[(a) Original][(a) 原始场景]][
    #image("../pbr-book-website/4ed/Cameras_and_Film/sportscar-1m-world.png", width: 75%)
  ][#ez_caption[(b) Translated, World Space][(b) 平移后，世界空间]][
    #image("../pbr-book-website/4ed/Cameras_and_Film/sportscar-1m-cameraworld.png", width: 75%)
  ][#ez_caption[(c) Translated, Camera-World Space][(c) 平移后，相机-世界空间]],
  caption: [#ez_caption[ *Effect of the Loss of Floating-Point Precision Far from the Origin. *(a) As originally specified, this scene is within 10 units of the origin. Rendering the scene in world space produces the expected image. (b) If both the scene and the camera are translated 1,000,000 units from the origin and the scene is rendered in world space, there is significantly less floating-point precision to represent the scene, giving this poor result. (c) If the translated scene is rendered in camera-world space, much more precision is available and the geometric detail is preserved. However, the viewpoint has shifted slightly due to a loss of accuracy in the representation of the camera position. (_Model courtesy of Yasutoshi Mori._)][*远离原点时浮点精度损失的影响。 *(a) 按原始指定的方式，此场景位于原点附近 10 个单位的范围内。在世界空间中渲染该场景会生成预期的图像。 (b) 如果将场景和相机同时从原点平移 1,000,000 个单位，并在世界空间中渲染场景，则表示场景的浮点精度会显著降低，导致结果很差。 (c) 如果在相机-世界空间中渲染平移后的场景，则可以获得更多的精度，从而保留几何细节。然而，由于相机位置表示的精度损失，视点会略微偏移。（_模型由 Yasutoshi Mori 提供。_）]
  ],
  kind: image,
) <fp-precision-loss-far-from-origin>



#parec[
  Rendering in camera space naturally provides the most floating-point precision for the objects closest to the camera. If the scene in @fig:fp-precision-loss-far-from-origin is rendered in camera space, translating both the camera and the scene geometry by 1,000,000 units has no effect—the translations cancel. However, there is a problem with using camera space with ray tracing. Scenes are often modeled with major features aligned to the coordinate axes (e.g., consider an architectural model, where the floor and ceiling might be aligned with $y$ planes). Axis-aligned bounding boxes of such features are degenerate in one dimension, which reduces their surface area. Acceleration structures like the BVH that will be introduced in @primitives-and-intersection-acceleration are particularly effective with such bounding boxes. In turn, if the camera is rotated with respect to the scene, axis-aligned bounding boxes are less effective at bounding such features and rendering performance is affected: for the scene in @fig:fp-precision-loss-far-from-origin, rendering time increases by 27%.
][
  在相机空间中渲染自然地为离相机最近的对象提供了最多的浮点精度。如果@fig:fp-precision-loss-far-from-origin 中的场景在相机空间中渲染，将相机和场景几何体平移 1,000,000 个单位没有影响——平移相互抵消。然而，使用相机空间进行光线追踪存在问题。场景通常建模为主要特征与坐标轴对齐（例如，考虑一个建筑模型，其中地板和天花板可能与 $y$ 平面对齐）。此类特征的轴对齐包围盒在一个维度上是退化的，这减少了它们的表面积。像将在@primitives-and-intersection-acceleration 中介绍的 BVH 这样的加速结构对于这样的包围盒特别有效。反过来，如果相机相对于场景旋转，轴对齐包围盒无法再紧密包围这些特征，并且渲染性能受到影响：对于@fig:fp-precision-loss-far-from-origin 中的场景，渲染时间增加了 27%。
]

#parec[
  Rendering using camera-world space gives the best of both worlds: the camera is at the origin and the scene is translated accordingly. However, the rotation is not applied to the scene geometry, thus preserving good bounding boxes for the acceleration structures. With camera-world space, there is no increase in rendering time, and higher precision is maintained, as is shown in @fig:fp-precision-loss-far-from-origin(c).
][
  使用相机-世界空间渲染结合了两者的优点：相机位于原点，场景相应地被平移。然而，旋转不应用于场景几何体，从而为加速结构保留了良好的包围盒。使用相机-世界空间，渲染时间没有增加，并且保持了更高的精度，如@fig:fp-precision-loss-far-from-origin(c) 所示。
]

#parec[
  The `CameraTransform` class abstracts the choice of which particular coordinate system is used for rendering by handling the details of transforming among the various spaces.
][
  `CameraTransform` 类封装了各坐标空间之间的变换细节，使其他代码不必关心具体选择了哪个渲染坐标系。
]

#block(sticky: true)[#raw("<<CameraTransform Definition>>=")] <fragment-CameraTransformDefinition-0>
#block(breakable: false)[
```cpp
class CameraTransform {
  public:
    <<CameraTransform Public Methods>>
  private:
    <<CameraTransform Private Members>>
};
```
] <CameraTransform>


#parec[
  Camera implementations must make their `CameraTransform` available to other parts of the system, so we will add one more method to the `Camera` interface.
][
  相机的实现必须使其 `CameraTransform` 可用于系统的其他部分，因此我们将在 `Camera` 接口中添加一个方法。
]

#block(sticky: true)[#raw("<<Camera Interface>>+=") #link(<fragment-CameraInterface-4>)[↑] #link("https://pbr-book.org/4ed/Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#fragment-CameraInterface-6")[↓]] <fragment-CameraInterface-5>
#block(breakable: false)[
```cpp
const CameraTransform &GetCameraTransform() const;
```
]


#parec[
  `CameraTransform` maintains two transformations: one from camera space to the rendering space, and one from the rendering space to world space. In `pbrt`, the latter transformation cannot be animated; any animation in the camera transformation is kept in the first transformation. This ensures that a moving camera does not cause static geometry in the scene to become animated, which in turn would harm performance.#footnote[A moving
camera generally does not affect ray tracing performance, as rendering with
one just causes different camera rays to be traced.  Moving geometry
requires larger bounding boxes to bound the motion of objects, which in
turn reduces the effectiveness of acceleration structures.  Thus, it is
undesirable to make objects move that do not need to be in motion.]
][
  `CameraTransform` 维护两个变换：一个从相机空间到渲染空间，另一个从渲染空间到世界空间。在 `pbrt` 中，后一个变换不能动画化；相机变换中的任何动画都保留在第一个变换中。这样，运动的相机就不会让场景中静止的几何体也变成运动几何体，从而避免由此造成的性能损失。#footnote[移动的相机通常不会影响光线追踪性能，因为渲染时只是跟踪不同的相机光线。而移动几何体则需要更大的包围盒来约束物体的运动，这反过来会降低加速结构的效率。因此，不必要移动的物体最好保持静止。]
]

#block(sticky: true)[#raw("<<CameraTransform Private Members>>=")] <fragment-CameraTransformPrivateMembers-0>
#block(breakable: false)[
```cpp
AnimatedTransform renderFromCamera;
Transform worldFromRender;
```
]

#parec[
  The `CameraTransform` constructor takes the world-from-camera transformation as specified in the scene description and decomposes it into the two transformations described earlier. The default rendering space is camera-world, though this choice can be overridden using a command-line option.
][
  `CameraTransform` 构造函数接受场景描述中指定的从相机空间到世界空间的变换，并将其分解为前面描述的两个变换。默认的渲染空间是相机-世界空间，尽管可以使用命令行选项覆盖此选择。
]

#block(sticky: true)[#raw("<<CameraTransform Method Definitions>>=")] <fragment-CameraTransformMethodDefinitions-0>
#block(breakable: false)[
```cpp
CameraTransform::CameraTransform(const AnimatedTransform &worldFromCamera) {
    switch (Options->renderingSpace) {
    case RenderingCoordinateSystem::Camera: {
        <<Compute worldFromRender for camera-space rendering>>
    } case RenderingCoordinateSystem::CameraWorld: {
        <<Compute worldFromRender for camera-world space rendering>>
    } case RenderingCoordinateSystem::World: {
        <<Compute worldFromRender for world-space rendering>>
    }
    }
    <<Compute renderFromCamera transformation>>
}
```
]


#parec[
  For camera-space rendering, the world-from-camera transformation should be used for `worldFromRender` and an identity transformation for the render-from-camera transformation, since those two coordinate systems are equivalent. However, because `worldFromRender` cannot be animated, the implementation takes the world-from-camera transformation at the midpoint of the frame and then folds the effect of any animation in the camera transformation into `renderFromCamera`.
][
  对于相机空间渲染，应使用从相机空间到世界空间的变换作为 `worldFromRender`，并对相机到渲染空间的变换使用单位变换，因为这两个坐标系统是等价的。然而，由于 `worldFromRender` 不能动画化，实现在帧的时间中点取从相机空间到世界空间的变换，然后将相机变换中的任何动画效果放到 `renderFromCamera` 中。
]

#block(sticky: true)[#raw("<<Compute worldFromRender for camera-space rendering>>=")] <fragment-ComputemonoworldFromRenderforcamera-spacerendering-0>
#block(breakable: false)[
```cpp
Float tMid = (worldFromCamera.startTime + worldFromCamera.endTime) / 2;
worldFromRender = worldFromCamera.Interpolate(tMid);
break;
```
]

#parec[
  For the default case of rendering in camera-world space, the world-from-render transformation is given by translating to the camera's position at the midpoint of the frame.
][
  对于默认的相机-世界空间渲染，从渲染空间到世界空间的变换，是平移到这一帧时间中点处相机所在的位置。
]

#block(sticky: true)[#raw("<<Compute worldFromRender for camera-world space rendering>>=")] <fragment-ComputemonoworldFromRenderforcamera-worldspacerendering-0>
#block(breakable: false)[
```cpp
Float tMid = (worldFromCamera.startTime + worldFromCamera.endTime) / 2;
Point3f pCamera = worldFromCamera(Point3f(0, 0, 0), tMid);
worldFromRender = Translate(Vector3f(pCamera));
break;
```
]


#parec[
  For world-space rendering, `worldFromRender` is the identity transformation.
][
  对于世界空间渲染，`worldFromRender` 是单位变换。
]

#block(sticky: true)[#raw("<<Compute worldFromRender for world-space rendering>>=")] <fragment-ComputemonoworldFromRenderforworld-spacerendering-0>
#block(breakable: false)[
```cpp
worldFromRender = Transform();
break;
```
]


#parec[
  Once `worldFromRender` has been set, whatever transformation remains in `worldFromCamera` is extracted and stored in `renderFromCamera`.
][
  一旦 `worldFromRender` 被设置，`worldFromCamera` 中剩余的任何变换被提取并存储在 `renderFromCamera` 中。
]

#block(sticky: true)[#raw("<<Compute renderFromCamera transformation>>=")] <fragment-ComputemonorenderFromCameratransformation-0>
#block(breakable: false)[
```cpp
Transform renderFromWorld = Inverse(worldFromRender);
Transform rfc[2] = { renderFromWorld * worldFromCamera.startTransform,
                     renderFromWorld * worldFromCamera.endTransform };
renderFromCamera = AnimatedTransform(rfc[0], worldFromCamera.startTime,
                                     rfc[1], worldFromCamera.endTime);
```
]


#parec[
  The `CameraTransform` class provides a variety of overloaded methods named `RenderFromCamera()`, `CameraFromRender()`, and `RenderFromWorld()` that transform points, vectors, normals, and rays among the coordinate systems it manages. Other methods return the corresponding transformations directly. Their straightforward implementations are not included here.
][
  `CameraTransform` 类提供了多种重载方法，名为 `RenderFromCamera()`、`CameraFromRender()` 和 `RenderFromWorld()`，用于在其管理的坐标系统之间转换点、向量、法线和光线。其他方法直接返回相应的变换。它们的简单实现不在此处包含。
]

=== #ez_caption[The CameraBase Class][CameraBase 类]
#parec[
  All of the camera implementations in this chapter share some common functionality that we have factored into a single class, `CameraBase`, from which all of them inherit.#footnote[One inconvenience with `pbrt`'s
custom dynamic dispatch approach is that the interface class cannot provide
such functionality via default method implementations.  It is not too much
work to do so with an explicitly shared base class as is done here,
however.] `CameraBase`, as well as all the camera implementations, is defined in the files `cameras.h` and `cameras.cpp`.
][
  本章中的所有相机实现共享一些通用功能，我们将这些功能整合到一个名为 `CameraBase` 的类中，所有这些实现都继承自该类。#footnote[使用 `pbrt` 的自定义动态分派方法的一个不便之处在于，接口类无法通过默认方法实现来提供此类功能。然而，通过显式共享基类来实现这一点并不需要太多工作，正如在此处所做的那样。] `CameraBase` 以及所有相机实现都定义在文件 `cameras.h` 和 `cameras.cpp` 中。
]

#block(sticky: true)[#raw("<<CameraBase Definition>>=")] <fragment-CameraBaseDefinition-0>
#block(breakable: false)[
```cpp
class CameraBase {
  public:
    <<CameraBase Public Methods>>
  protected:
    <<CameraBase Protected Members>>
    <<CameraBase Protected Methods>>
};
```
] <CameraBase>

#parec[
  The `CameraBase` constructor takes a variety of parameters that are applicable to all of `pbrt`'s cameras:
][
  `CameraBase` 构造函数接受多种适用于所有 `pbrt` 相机的参数：
]

#parec[
  - One of the most important is the transformation that places the camera in the scene, which is represented by a `CameraTransform` and is stored in the `cameraTransform` member variable.
  - Next is a pair of floating-point values that give the times at which the camera's shutter opens and closes.
  - A `Film` instance stores the final image and models the film sensor.
  - Last is a `Medium` instance that represents the scattering medium that the camera lies in, if any (Medium is described in @media ).
][
  - 最重要的参数之一是将相机放置在场景中的变换，它由 `CameraTransform` 表示，并存储在 `cameraTransform` 成员变量中。
  - 接下来是一对浮点值，表示相机快门打开和关闭的时间。
  - 一个 `Film` 实例存储最终图像并模拟胶片传感器。
  - 最后是一个 `Medium` 实例，表示相机所在的散射介质（如果有的话，Medium 在@media 中描述）。
]

#parec[
  A small structure bundles them together and helps shorten the length of the parameter lists for `Camera` constructors.
][
  用一个小结构汇集这些参数，可以缩短 `Camera` 构造函数的参数列表。
]


#block(sticky: true)[#raw("<<CameraBaseParameters Definition>>=")] <fragment-CameraBaseParametersDefinition-0>
#block(breakable: false)[
```cpp
struct CameraBaseParameters {
    CameraTransform cameraTransform;
    Float shutterOpen = 0, shutterClose = 1;
    Film film;
    Medium medium;
};
```
] <CameraBaseParameters>
#parec[
  We will only include the constructor's prototype here because its implementation does no more than assign the parameters to the corresponding member variables.
][
  我们这里只包括构造函数的原型，因为它的实现仅仅是将参数赋给相应的成员变量。
]
#block(sticky: true)[#raw("<<CameraBase Protected Methods>>=") #link(<fragment-CameraBaseProtectedMethods-1>)[↓]] <fragment-CameraBaseProtectedMethods-0>
#block(breakable: false)[
```cpp
CameraBase(CameraBaseParameters p);
```
]

#block(sticky: true)[#raw("<<CameraBase Protected Members>>=") #link("https://pbr-book.org/4ed/Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#fragment-CameraBaseProtectedMembers-1")[↓]] <fragment-CameraBaseProtectedMembers-0>
#block(breakable: false)[
```cpp
CameraTransform cameraTransform;
Float shutterOpen, shutterClose;
Film film;
Medium medium;
```
]

#parec[
  `CameraBase` can implement a number of the methods required by the `Camera` interface directly, thus saving the trouble of needing to redundantly implement them in the camera implementations that inherit from it.
][
  `CameraBase` 可以直接实现 `Camera` 接口所需的多个方法，从而避免在继承自它的相机实现中重复实现这些方法的麻烦。
]

#parec[
  For example, accessor methods make the `Film` and `CameraTransform` available.
][
  例如，访问方法向调用方提供 `Film` 和 `CameraTransform`。
]

#block(sticky: true)[#raw("<<CameraBase Public Methods>>=") #link(<fragment-CameraBasePublicMethods-1>)[↓]] <fragment-CameraBasePublicMethods-0>
#block(breakable: false)[
```cpp
Film GetFilm() const { return film; }
const CameraTransform &GetCameraTransform() const {
    return cameraTransform;
}
```
]

#parec[
  The `SampleTime()` method is implemented by linearly interpolating between the shutter open and close times using the sample `u`.
][
  `SampleTime()` 方法通过在快门打开和关闭时间之间使用样本 `u` 进行线性插值来实现。
]
#block(sticky: true)[#raw("<<CameraBase Public Methods>>+=") #link(<fragment-CameraBasePublicMethods-0>)[↑] #link("https://pbr-book.org/4ed/Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#fragment-CameraBasePublicMethods-2")[↓]] <fragment-CameraBasePublicMethods-1>
#block(breakable: false)[
```cpp
Float SampleTime(Float u) const {
    return Lerp(u, shutterOpen, shutterClose);
}
```
]

#parec[
  `CameraBase` provides a `GenerateRayDifferential()` method that computes a ray differential via multiple calls to a camera's `GenerateRay()` method. One subtlety is that camera implementations that use this method still must implement a `Camera` `GenerateRayDifferential()` method themselves, but then call this method from theirs. (Note that this method's signature is different than that one.) Cameras pass their `this` pointer as a `Camera` parameter, which allows it to call the camera's `GenerateRay()` method. This additional complexity stems from our not using virtual functions for the camera interface, which means that the `CameraBase` class does not on its own have the ability to call that method unless a `Camera` is provided to it.
][
  `CameraBase` 提供了一个 `GenerateRayDifferential()` 方法，通过多次调用相机的 `GenerateRay()` 方法来计算射线微分。一个细微之处是，使用此方法的相机实现仍然必须自己实现一个 `Camera` `GenerateRayDifferential()` 方法，然后从它们的方法中调用此方法。（注意，此方法的签名与那个不同。）相机将它们的 `this` 指针作为 `Camera` 参数传递，这使得它可以调用相机的 `GenerateRay()` 方法。这种额外的复杂性源于我们没有为相机接口使用虚函数，这意味着 `CameraBase` 类本身没有能力调用该方法，除非提供给它一个 `Camera`。
]

#block(sticky: true)[#raw("<<CameraBase Method Definitions>>=")] <fragment-CameraBaseMethodDefinitions-0>
#block(breakable: false)[
```cpp
pstd::optional<CameraRayDifferential>
CameraBase::GenerateRayDifferential(Camera camera,
        CameraSample sample, SampledWavelengths &lambda) {
    <<Generate regular camera ray cr for ray differential>>
    <<Find camera ray after shifting one pixel in the x direction>>
    <<Find camera ray after shifting one pixel in the y direction>>
    <<Return approximate ray differential and weight>>
}
```
]

#parec[
  The primary ray is found via a first call to GenerateRay(). If there is no valid ray for the given sample, then there can be no ray differential either.
][
  通过第一次调用 `GenerateRay()` 找到主射线。如果对于给定的样本没有有效的射线，那么也不会有射线微分。
]

#block(sticky: true)[#raw("<<Generate regular camera ray cr for ray differential>>=")] <fragment-Generateregularcameraraymonocrforraydifferential-0>
#block(breakable: false)[
```cpp
pstd::optional<CameraRay> cr = camera.GenerateRay(sample, lambda);
if (!cr) return {};
RayDifferential rd(cr->ray);
```
]

#parec[
  Two attempts are made to find the $x$ ray differential: one using forward differencing and one using backward differencing by a fraction of a pixel. It is important to try both of these due to vignetting at the edges of images formed by realistic camera models—sometimes the main ray is valid but shifting in one direction moves past the image formed by the lens system. In that case, trying the other direction may successfully generate a ray.
][
  计算 $x$ 方向的射线微分时会尝试两次，分别偏移不足一个像素，进行前向差分和后向差分。由于真实相机模型在图像边缘可能会产生渐晕效应，因此尝试这两种方法很重要——有时主射线是有效的，但向一个方向偏移可能会超出镜头系统形成的图像。在这种情况下，尝试另一个方向可能会成功生成射线。
]
#block(sticky: true)[#raw("<<Find camera ray after shifting one pixel in the x direction>>=")] <fragment-Findcamerarayaftershiftingonepixelinthexdirection-0>
#block(breakable: false)[
```cpp
pstd::optional<CameraRay> rx;
for (Float eps : {.05f, -.05f}) {
    CameraSample sshift = sample;
    sshift.pFilm.x += eps;
    <<Try to generate ray with sshift and compute x differential>>
}
```
]

#parec[
  If it was possible to generate the auxiliary $x$ ray, then the corresponding pixel-wide differential is initialized via differencing.
][
  如果能生成 $x$ 方向的辅助射线，就通过差分初始化对应一个像素宽度的射线微分。
]
#block(sticky: true)[#raw("<<Try to generate ray with sshift and compute x differential>>=")] <fragment-Trytogenerateraywithmonosshiftandcomputexdifferential-0>
#block(breakable: false)[
```cpp
if (rx = camera.GenerateRay(sshift, lambda); rx) {
    rd.rxOrigin = rd.o + (rx->ray.o - rd.o) / eps;
    rd.rxDirection = rd.d + (rx->ray.d - rd.d) / eps;
    break;
}
```
]

#parec[
  The implementation of the fragment #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-212")[⟨Find camera ray after shifting one pixel in the $y$ direction⟩] follows similarly and is not included here.
][
  片段 #link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-212")[⟨Find camera ray after shifting one pixel in the $y$ direction⟩] 的实现方式类似，这里不再包括。
]

#parec[
  If a valid ray was found for both $x$ and $y$, we can go ahead and set the hasDifferentials member variable to true. Otherwise, the main ray can still be traced, just without differentials available.
][
  如果在 $x$ 和 $y$ 方向上都找到有效射线，就将 `hasDifferentials` 成员变量设置为 `true`。否则，仍然可以跟踪主射线，只是没有可用的微分。
]
#block(sticky: true)[#raw("<<Return approximate ray differential and weight>>=")] <fragment-Returnapproximateraydifferentialandweight-0>
#block(breakable: false)[
```cpp
rd.hasDifferentials = rx && ry;
return CameraRayDifferential{rd, cr->weight};
```
]

#parec[
  Finally, for the convenience of its subclasses, CameraBase provides various transformation methods that use the CameraTransform. We will only include the Ray method here; the others are analogous.
][
  最后，为了方便其子类，`CameraBase` 提供了使用 `CameraTransform` 的各种变换方法。我们这里只包括 `Ray` 方法；其他方法类似。
]
#block(sticky: true)[#raw("<<CameraBase Protected Methods>>+=") #link(<fragment-CameraBaseProtectedMethods-0>)[↑]] <fragment-CameraBaseProtectedMethods-1>
#block(breakable: false)[
```cpp
Ray RenderFromCamera(const Ray &r) const {
    return cameraTransform.RenderFromCamera(r);
}
```
]

#include "supplements/5.1-expanded.typ"
