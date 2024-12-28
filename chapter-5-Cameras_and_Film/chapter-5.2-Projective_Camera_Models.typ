#import "../template.typ": parec, ez_caption

== Projective Camera Models
#parec[
  One of the fundamental issues in 3D computer graphics is the #emph[3D
viewing problem:] how to project a 3D scene onto a 2D image for display. Most of the classic approaches can be expressed by a $4 times 4$ projective transformation matrix. Therefore, we will introduce a projection matrix camera class, `ProjectiveCamera`, and then define two camera models based on it. The first implements an orthographic projection, and the other implements a perspective projection—two classic and widely used projections.
][
  3D计算机图形学的基本问题之一是#emph[3D成像问题];：如何将3D场景投影到2D图像上进行显示。大多数经典方法可以用一个 $4 times 4$ 的投影变换矩阵表示。因此，我们将介绍一个投影矩阵相机类，`ProjectiveCamera`，然后基于它定义两种相机模型。我们先实现正交投影，然后实现透视投影——两种经典且广泛使用的投影。
]

```cpp
// <<ProjectiveCamera Definition>>=
class ProjectiveCamera : public CameraBase {
  public:
    // <<ProjectiveCamera Public Methods>>
  protected:
    // <<ProjectiveCamera Protected Members>>
};
```

#parec[
  The orthographic and perspective projections both require the specification of two planes perpendicular to the viewing direction: the #emph[near] and #emph[far] planes. When rasterization is used for rendering, objects that are not between those two planes are culled and not included in the final image. (Culling objects in front of the near plane is particularly important in order to avoid a singularity at the depth 0 and because otherwise the projection matrices map points behind the camera to appear to be in front of it.) In a ray tracer, the projection matrices are used purely to determine rays leaving the camera and these concerns do not apply; there is therefore less need to worry about setting those planes' depths carefully in this context.
][
  正交投影和透视投影都需要指定两个与视图方向垂直的平面：#emph[近];平面和#emph[远];平面。当使用光栅化进行渲染时，不在这两个平面之间的对象会被剔除，不包含在最终图像中。（剔除近平面前的对象尤为重要，以避免深度为0的奇点，因为否则投影矩阵会将相机后面的点映射为在其前面。）在光线追踪器中，投影矩阵仅用于确定离开相机的光线，这些问题不适用；因此在这种情况下，不需要过多担心这些平面的深度设置。
]

#parec[
  Three more coordinate systems (summarized in @fig:camera-spaces) are useful for defining and discussing projective cameras:
][
  三个额外的坐标系统（在 @fig:camera-spaces 中总结）对于定义和讨论投影相机很有用：
]

#parec[
  - #emph[Screen space:] Screen space is defined on the film plane. The
    camera projects objects in camera space onto the film plane; the parts
    inside the #emph[screen window] are visible in the image that is
    generated. Points at the near plane are mapped to a depth $z$ value of
    0 and points at the far plane are mapped to 1. Note that, although
    this is called "screen" space, it is still a 3D coordinate system,
    since $z$ values are meaningful.
][
  - #emph[屏幕空间：] 屏幕空间定义在胶片平面上。相机将相机空间中的对象投影到胶片平面上；#emph[屏幕窗口];内的部分在生成的图像中可见。近平面的点被映射到深度$z$值为0，远平面的点被映射到1。注意，尽管称为“屏幕”空间，它仍然是一个3D坐标系统，因为$z$值是有意义的。
]

#parec[
  - #emph[Normalized device coordinate (NDC) space:] This is the
    coordinate system for the actual image being rendered. In $(x , y)$,
    this space ranges from $(0 , 0)$ to $(1 , 1)$, with $(0 , 0)$ being
    the upper-left corner of the image. Depth values are the same as in
    screen space, and a linear transformation converts from screen to NDC
    space.
][
  - #emph[标准化设备坐标（NDC）空间：] 这是实际渲染图像的坐标系统。在$(x , y)$中，这个空间范围从$(0 , 0)$到$(1 , 1)$，其中$(0 , 0)$是图像的左上角。深度值与屏幕空间相同，线性变换将屏幕空间转换为NDC空间。
]

#parec[
  - #emph[Raster space:] This is almost the same as NDC space, except the
    $x$ and $y$ coordinates range from $(0 , 0)$ to the resolution of the
    image in $x$ and $y$ pixels.
][
  - #emph[光栅空间：] 这几乎与NDC空间相同，除了$x$和$y$坐标范围从$(0 , 0)$变到了图像在$x$和$y$像素中的分辨率。
]

#parec[
  Projective cameras use $4 times 4$ matrices to transform among all of these spaces.
][
  投影相机使用 $4 times 4$ 矩阵在这些空间之间进行转换。
]

#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f02.svg"),
  caption: [#ez_caption[Several camera-related coordinate spaces are commonly used to simplify the implementation of Cameras. The camera class holds transformations between them. Scene objects in rendering space are viewed by the camera, which sits at the origin of camera space and points along the $+z$ axis. Objects between the near and far planes are projected onto the film plane at $z="near"$ in camera space. The film plane is at $z=0$ in raster space, where $x$ and $y$ range from $(0,0)$ to the image resolution in pixels. Normalized device coordinate (NDC) space normalizes raster space so that $x$ and $y$ range from $(0,0)$ to $(1,1)$.][为了简化相机实现，通常使用几种与相机相关的坐标空间。相机类包含这些坐标空间之间的变换。在渲染空间中的场景对象从相机处观察，相机位于相机空间的原点，并沿 $+z$ 轴方向指向。在相机空间中，位于近平面和远平面之间的物体投影到 $z="near"$ 的胶片平面上。在光栅空间中，胶片平面位于 $z=0$，其中 $x$ 和 $y$ 的范围从 $(0,0)$ 到图像分辨率（以像素为单位）。归一化设备坐标（NDC）空间将光栅空间归一化，使得 $x$ 和 $y$ 的范围从 $(0,0)$ 到 $(1,1)$。]],
) <camera-spaces>

#parec[
  In addition to the parameters required by the `CameraBase` class, the #link("<ProjectiveCamera>")[ProjectiveCamera] takes the projective transformation matrix, the screen space extent of the image, and additional parameters related to the distance at which the camera is focused and the size of its lens aperture. If the lens aperture is not an infinitesimal pinhole, then parts of the image may be blurred, as happens for out-of-focus objects with real lens systems. Simulation of this effect will be discussed later in this section.
][
  除了`CameraBase`类所需的参数外，#link("<ProjectiveCamera>")[`ProjectiveCamera`];还需要投影变换矩阵、图像的屏幕空间范围以及与相机聚焦距离和镜头光圈大小相关的附加参数。如果镜头光圈不是无穷小的针孔，那么图像的某些部分可能会模糊，就像真实镜头系统中失焦的对象一样。对此效果的模拟将在本节后面讨论。
]

```cpp
// <<ProjectiveCamera Public Methods>>=
ProjectiveCamera(CameraBaseParameters baseParameters,
        const Transform &screenFromCamera, Bounds2f screenWindow,
        Float lensRadius, Float focalDistance)
    : CameraBase(baseParameters), screenFromCamera(screenFromCamera),
      lensRadius(lensRadius), focalDistance(focalDistance) {
    // <<Compute projective camera transformations>>
}
```
#parec[
  #link("<ProjectiveCamera>")[`ProjectiveCamera`] implementations pass the projective transformation up to the base class constructor shown here. This transformation gives the screen-from-camera projection; from that, the constructor can easily compute the other transformations that go all the way from raster space to camera space.
][
  #link("<ProjectiveCamera>")[`ProjectiveCamera`];的实现里将投影变换传递给基类构造函数。此变换提供了从相机到屏幕的映射；从中，构造函数可以轻松计算从光栅空间到相机空间的其他变换。
]

```cpp
// <<Compute projective camera transformations>>=
// <<Compute projective camera screen transformations>>
cameraFromRaster = Inverse(screenFromCamera) * screenFromRaster;
// <<ProjectiveCamera Protected Members>>=
Transform screenFromCamera, cameraFromRaster;
```
#parec[
  The only nontrivial transformation to compute in the constructor is the raster-from-screen projection. It is computed in two steps, via composition of the raster-from-NDC and NDC-from-screen transformations. An important detail here is that the $y$ coordinate is inverted by the final transformation; this is necessary because increasing $y$ values move up the image in screen coordinates but down in raster coordinates.
][
  构造函数中唯一需要复杂计算的变换是从屏幕到光栅的投影。它通过NDC到光栅和屏幕到NDC变换的组合分两步计算。这里一个重要的细节是，最终变换会反转 $y$ 坐标；这是必要的，因为在屏幕坐标中增加 $y$ 值向上移动图像，而在光栅坐标中向下移动。
]

```cpp
// <<Compute projective camera screen transformations>>=
Transform NDCFromScreen =
    Scale(1 / (screenWindow.pMax.x - screenWindow.pMin.x),
          1 / (screenWindow.pMax.y - screenWindow.pMin.y), 1) *
    Translate(Vector3f(-screenWindow.pMin.x, -screenWindow.pMax.y, 0));
Transform rasterFromNDC =
    Scale(film.FullResolution().x, -film.FullResolution().y, 1);
rasterFromScreen = rasterFromNDC * NDCFromScreen;
screenFromRaster = Inverse(rasterFromScreen);
```
```cpp
// <<ProjectiveCamera Protected Members>>+=
Transform rasterFromScreen, screenFromRaster;
```

=== Orthographic Camera
<orthographic-camera>
#parec[
  The orthographic camera is based on the orthographic projection transformation. The orthographic transformation takes a rectangular region of the scene and projects it onto the front face of the box that defines the region. It does not give the effect of #emph[foreshortening];—objects becoming smaller on the image plane as they get farther away—but it does leave parallel lines parallel, and it preserves relative distance between objects. @fig:ortho-volume shows how this rectangular volume defines the visible region of the scene.
][
  正交相机基于正交投影变换。正交变换将场景的矩形区域投影到定义该区域的盒子的前面。它不会产生#emph[透视];的效果——即物体在图像平面上随着距离的增加而变小——但它保持平行线平行，并保留物体之间的相对距离。@fig:ortho-volume 显示了这个矩形体积如何定义场景的可见区域。
]


```cpp
// <<OrthographicCamera Definition>>=
class OrthographicCamera : public ProjectiveCamera {
  public:
    // <<OrthographicCamera Public Methods>>
  private:
    // <<OrthographicCamera Private Members>>
};
```

#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f03.svg"),
  caption: [
    #ez_caption[
      The orthographic view volume is an axis-aligned box in camera space, defined such that objects inside the region are projected onto the $z = "near"$ face of the box.
    ][ 正交视图体积是相机空间中的一个轴对齐盒子，定义为使区域内的物体投影到盒子的 $z = "near"$ 面上。 ]
  ],
)<ortho-volume>
#figure(
  table(
    columns: 2,
    stroke: none,
    [#image("../pbr-book-website/4ed/Cameras_and_Film/kroken-ortho.png")],
    [#image("../pbr-book-website/4ed/Cameras_and_Film/kroken-perspective.png")],

    [(a) orthographic], [(b) perspective],
  ),
  caption: [
    #ez_caption[
      #emph[Kroken] Scene Rendered with Different Camera Models. Images are rendered from the same viewpoint with (a) orthographic and (b) perspective cameras. The lack of foreshortening makes the orthographic view feel like it has less depth, although it does preserve parallel lines, which can be a useful property. #emph[(Scene courtesy of Angelo Ferretti.)]
    ][
      使用不同相机模型渲染的 Kroken 场景。图像从相同的视点渲染，使用 (a) 正交相机和 (b) 透视相机。缺乏透视效果使得正交视图感觉深度较小，尽管它保持了平行线，这可能是一个有用的特性。#emph[(场景由Angelo Ferretti 提供。)]
    ]
  ],
  kind: image,
)<ortho-vs-perspective>

#parec[
  @fig:ortho-vs-perspective compares the result of using the orthographic projection for rendering to that of the perspective projection defined in the next section.
][
  @fig:ortho-vs-perspective 比较了使用正交投影进行渲染的结果与下一节定义的透视投影的结果。
]

#parec[
  The orthographic camera constructor generates the orthographic transformation matrix with the #link("<Orthographic>")[`Orthographic()`] function, which will be defined shortly.
][
  正交相机构造函数使用 #link("<Orthographic>")[`Orthographic()`] 函数生成正交变换矩阵，该函数将在稍后定义。
]

```cpp
OrthographicCamera(CameraBaseParameters baseParameters,
                    Bounds2f screenWindow, Float lensRadius, Float focalDist)
    : ProjectiveCamera(baseParameters, Orthographic(0, 1), screenWindow,
                        lensRadius, focalDist) {
    // <<Compute differential changes in origin for orthographic camera rays>>
    dxCamera = cameraFromRaster(Vector3f(1, 0, 0));
    dyCamera = cameraFromRaster(Vector3f(0, 1, 0));
    // <<Compute minimum differentials for orthographic camera>>
    minDirDifferentialX = minDirDifferentialY = Vector3f(0, 0, 0);
    minPosDifferentialX = dxCamera;
    minPosDifferentialY = dyCamera;
}
```

#parec[
  The orthographic viewing transformation leaves $x$ and $y$ coordinates unchanged but maps $z$ values at the near plane to $0$ and $z$ values at the far plane to $1$. To do this, the scene is first translated along the $z$ axis so that the near plane is aligned with $z = 0$. Then, the scene is scaled in $z$ so that the far plane maps to $z = 1$. The composition of these two transformations gives the overall transformation. For a ray tracer like `pbrt`, we would like the near plane to be at $0$ so that rays start at the plane that goes through the camera's position; the far plane's position does not particularly matter.
][
  正交视图变换保持 $x$ 和 $y$ 坐标不变，但将近平面的 $z$ 值映射为 $0$，远平面的 $z$ 值映射为 $1$。为此，首先沿 $z$ 轴平移场景，使近平面对齐 $z = 0$。然后在 $z$ 方向上缩放场景，使远平面映射到 $z = 1$。这两个变换的组合给出了整体变换。对于像 `pbrt` 这样的光线追踪器，我们希望近平面在 $0$，这样射线就从穿过相机位置的平面开始；远平面的位置并不特别重要。
]

```cpp
Transform Orthographic(Float zNear, Float zFar) {
    return Scale(1, 1, 1 / (zFar - zNear)) *
           Translate(Vector3f(0, 0, -zNear));
}
```
#parec[
  Thanks to the simplicity of the orthographic projection, it is easy to directly compute the differential rays in the $x$ and $y$ directions in the `GenerateRayDifferential()` method. The directions of the differential rays will be the same as the main ray (as they are for all rays generated by an orthographic camera), and the difference in origins will be the same for all rays. Therefore, the constructor here precomputes how much the ray origins shift in camera space coordinates due to a single pixel shift in the $x$ and $y$ directions on the film plane.
][
  由于正交投影的简单性，可以在 `GenerateRayDifferential()` 方法中直接计算 $x$ 和 $y$ 方向的微分射线。微分射线的方向将与主射线相同（因为它们是由正交相机生成的所有射线），并且所有射线的原点差异将相同。因此，这里的构造函数预先计算了由于在胶片平面上 $x$ 和 $y$ 方向上的单个像素偏移而导致的相机空间坐标中射线原点的移动量。
]

```cpp
// <<Compute differential changes in origin for orthographic camera rays>>=
dxCamera = cameraFromRaster(Vector3f(1, 0, 0));
dyCamera = cameraFromRaster(Vector3f(0, 1, 0));
```
```cpp
// <<OrthographicCamera Private Members>>=
Vector3f dxCamera, dyCamera;
```
#parec[
  We can now go through the code that takes a sample point in raster space and turns it into a camera ray. The process is summarized in @fig:ortho-raster-to-ray. First, the raster space sample position is transformed into a point in camera space, giving a point located on the near plane, which is the origin of the camera ray. Because the camera space viewing direction points down the $z$ axis, the camera space ray direction is $(0 , 0 , 1)$.
][
  现在我们可以通过代码，将光栅空间中的采样点转换为相机射线。该过程在@fig:ortho-raster-to-ray 总结。首先，光栅空间采样位置被转换为相机空间中的一个点，给出位于近平面上的一个点，这就是相机射线的原点。相机空间的视图方向沿 $z$ 轴向下，因此射线方向为 $(0 , 0 , 1)$。
]
#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f05.svg"),
  caption: [
    #ez_caption[
      To create a ray with the orthographic camera, a raster space
      position on the film plane is transformed to camera space, giving the
      ray's origin on the near plane. The ray's direction in camera space is
      $(0 , 0 , 1)$, down the $z$ axis.
    ][
      要使用正交相机创建射线，胶片平面上的光栅空间位置被转换为相机空间，给出近平面上的射线原点。相机空间中的射线方向是沿
      $z$ 轴向下的 $(0 , 0 , 1)$。
    ]

  ],
)
<ortho-raster-to-ray>

#parec[
  If the lens aperture is not a pinhole, the ray's origin and direction are modified so that defocus blur is simulated. Finally, the ray is transformed into rendering space before being returned.
][
  如果镜头光圈不是针孔，则射线的原点和方向会被修改以模拟散焦模糊。最后，射线被转换为渲染空间，然后返回。
]

```cpp
pstd::optional<CameraRay> OrthographicCamera::GenerateRay(
        CameraSample sample, SampledWavelengths &lambda) const {
    // Compute raster and camera sample positions
    Point3f pFilm = Point3f(sample.pFilm.x, sample.pFilm.y, 0);
    Point3f pCamera = cameraFromRaster(pFilm);
    Ray ray(pCamera, Vector3f(0, 0, 1), SampleTime(sample.time), medium);
    // Modify ray for depth of field
    if (lensRadius > 0) {
        // Sample point on lens
        Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
        // Compute point on plane of focus
        Float ft = focalDistance / ray.d.z;
        Point3f pFocus = ray(ft);
        // Update ray for effect of lens
        ray.o = Point3f(pLens.x, pLens.y, 0);
        ray.d = Normalize(pFocus - ray.o);
    }
    return CameraRay{RenderFromCamera(ray)};
}
```
#parec[
  Once all the transformation matrices have been set up, it is easy to transform the raster space sample point to camera space.
][
  一旦所有的变换矩阵设置好，就很容易将光栅空间的采样点转换为相机空间。
]

```cpp
Point3f pFilm = Point3f(sample.pFilm.x, sample.pFilm.y, 0);
Point3f pCamera = cameraFromRaster(pFilm);
```

#parec[
  The implementation of `GenerateRayDifferential()` performs the same computation to generate the main camera ray. The differential ray origins are found using the offsets computed in the `OrthographicCamera` constructor, and then the full ray differential is transformed to rendering space.
][
  `GenerateRayDifferential()` 的实现执行相同的计算以生成主相机射线。微分射线的原点使用在 `OrthographicCamera` 构造函数中计算的偏移量找到，然后将完整的射线微分转换为渲染空间。
]

```cpp
// <<OrthographicCamera Method Definitions>>+=
pstd::optional<CameraRayDifferential>
OrthographicCamera::GenerateRayDifferential(CameraSample sample,
        SampledWavelengths &lambda) const {
    // <<Compute main orthographic viewing ray>>
    // <<Compute raster and camera sample positions>>
    Point3f pFilm = Point3f(sample.pFilm.x, sample.pFilm.y, 0);
    Point3f pCamera = cameraFromRaster(pFilm);
    RayDifferential ray(pCamera, Vector3f(0, 0, 1), SampleTime(sample.time), medium);
    // <<Modify ray for depth of field>>
    if (lensRadius > 0) {
        // <<Sample point on lens>>
        Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
        // <<Compute point on plane of focus>>
        Float ft = focalDistance / ray.d.z;
        Point3f pFocus = ray(ft);
        // <<Update ray for effect of lens>>
        ray.o = Point3f(pLens.x, pLens.y, 0);
        ray.d = Normalize(pFocus - ray.o);
    }
    // <<Compute ray differentials for OrthographicCamera>>
    if (lensRadius > 0) {
        // <<Compute OrthographicCamera ray differentials accounting for lens>>
        // <<Sample point on lens>>
        Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
        Float ft = focalDistance / ray.d.z;
        Point3f pFocus = pCamera + dxCamera + (ft * Vector3f(0, 0, 1));
        ray.rxOrigin = Point3f(pLens.x, pLens.y, 0);
        ray.rxDirection = Normalize(pFocus - ray.rxOrigin);

        pFocus = pCamera + dyCamera + (ft * Vector3f(0, 0, 1));
        ray.ryOrigin = Point3f(pLens.x, pLens.y, 0);
        ray.ryDirection = Normalize(pFocus - ray.ryOrigin);
    } else {
        ray.rxOrigin = ray.o + dxCamera;
        ray.ryOrigin = ray.o + dyCamera;
        ray.rxDirection = ray.ryDirection = ray.d;
    }
    ray.hasDifferentials = true;
    return CameraRayDifferential{RenderFromCamera(ray)};
}
```

```cpp
// <<Compute ray differentials for OrthographicCamera>>=
if (lensRadius > 0) {
    // <<Compute OrthographicCamera ray differentials accounting for lens>>
    // <<Sample point on lens>>
    Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
    Float ft = focalDistance / ray.d.z;
    Point3f pFocus = pCamera + dxCamera + (ft * Vector3f(0, 0, 1));
    ray.rxOrigin = Point3f(pLens.x, pLens.y, 0);
    ray.rxDirection = Normalize(pFocus - ray.rxOrigin);

    pFocus = pCamera + dyCamera + (ft * Vector3f(0, 0, 1));
    ray.ryOrigin = Point3f(pLens.x, pLens.y, 0);
    ray.ryDirection = Normalize(pFocus - ray.ryOrigin);
} else {
    ray.rxOrigin = ray.o + dxCamera;
    ray.ryOrigin = ray.o + dyCamera;
    ray.rxDirection = ray.ryDirection = ray.d;
}
```



=== Perspective Camera
<perspective-camera>
#parec[
  The perspective projection is similar to the orthographic projection in that it projects a volume of space onto a 2D film plane. However, it includes the effect of foreshortening: objects that are far away are projected to be smaller than objects of the same size that are closer. Unlike the orthographic projection, the perspective projection does not preserve distances or angles, and parallel lines no longer remain parallel. The perspective projection is a reasonably close match to how an eye or camera lens generates images of the 3D world.
][
  透视投影与正交投影相似，因为它将空间投影到二维胶片平面上。然而，它包括透视缩短效应：远处的物体被投影得比近处同样大小的物体小。与正交投影不同，透视投影不保留真实距离或角度，平行线在投影中不再保持平行。透视投影与眼睛或相机镜头生成三维世界图像的方式非常接近。
]

```cpp
class PerspectiveCamera : public ProjectiveCamera {
  public:
    // <<PerspectiveCamera Public Methods>>
    PerspectiveCamera(CameraBaseParameters baseParameters, Float fov,
                         Bounds2f screenWindow, Float lensRadius, Float focalDist)
           : ProjectiveCamera(baseParameters, Perspective(fov, 1e-2f, 1000.f),
                              screenWindow, lensRadius, focalDist) {
           // <<Compute differential changes in origin for perspective camera rays>>
           dxCamera = cameraFromRaster(Point3f(1, 0, 0)) -
                         cameraFromRaster(Point3f(0, 0, 0));
           dyCamera = cameraFromRaster(Point3f(0, 1, 0)) -
                      cameraFromRaster(Point3f(0, 0, 0));
           // <<Compute cosTotalWidth for perspective camera>>
           Point2f radius = Point2f(film.GetFilter().Radius());
           Point3f pCorner(-radius.x, -radius.y, 0.f);
           Vector3f wCornerCamera = Normalize(Vector3f(cameraFromRaster(pCorner)));
           cosTotalWidth = wCornerCamera.z;

           // <<Compute image plane area at z equals 1 for PerspectiveCamera>>
           // <<Compute minimum differentials for PerspectiveCamera>>
           FindMinimumDifferentials(this);
       }
       PerspectiveCamera() = default;

       static PerspectiveCamera *Create(const ParameterDictionary &parameters,
                                        const CameraTransform &cameraTransform,
                                        Film film, Medium medium,
                                        const FileLoc *loc, Allocator alloc = {});

       PBRT_CPU_GPU
       pstd::optional<CameraRay> GenerateRay(CameraSample sample,
                                             SampledWavelengths &lambda) const;

       PBRT_CPU_GPU
       pstd::optional<CameraRayDifferential> GenerateRayDifferential(
           CameraSample sample, SampledWavelengths &lambda) const;

       PBRT_CPU_GPU
       SampledSpectrum We(const Ray &ray, SampledWavelengths &lambda,
                          Point2f *pRaster2 = nullptr) const;
       PBRT_CPU_GPU
       void PDF_We(const Ray &ray, Float *pdfPos, Float *pdfDir) const;
       PBRT_CPU_GPU
       pstd::optional<CameraWiSample> SampleWi(const Interaction &ref, Point2f u,
                                               SampledWavelengths &lambda) const;

       std::string ToString() const;
  private:
    Vector3f dxCamera, dyCamera;
    Float cosTotalWidth;
};
```

```cpp
PerspectiveCamera(CameraBaseParameters baseParameters, Float fov,
                  Bounds2f screenWindow, Float lensRadius, Float focalDist)
    : ProjectiveCamera(baseParameters, Perspective(fov, 1e-2f, 1000.f),
                       screenWindow, lensRadius, focalDist) {
    // <<Compute differential changes in origin for perspective camera rays>>
    dxCamera = cameraFromRaster(Point3f(1, 0, 0)) -
                  cameraFromRaster(Point3f(0, 0, 0));
    dyCamera = cameraFromRaster(Point3f(0, 1, 0)) -
              cameraFromRaster(Point3f(0, 0, 0));
    // <<Compute cosTotalWidth for perspective camera>>
    Point2f radius = Point2f(film.GetFilter().Radius());
    Point3f pCorner(-radius.x, -radius.y, 0.f);
    Vector3f wCornerCamera = Normalize(Vector3f(cameraFromRaster(pCorner)));
    cosTotalWidth = wCornerCamera.z;

    // <<Compute image plane area at z equals 1 for PerspectiveCamera>>
    // <<Compute minimum differentials for PerspectiveCamera>>
    FindMinimumDifferentials(this);
}
```


#parec[
  The perspective projection describes perspective viewing of the scene. Points in the scene are projected onto a viewing plane perpendicular to the $z$ axis. The #link("<Perspective>")[`Perspective()`] function computes this transformation; it takes a field-of-view angle in `fov` and the distances to a near $z$ plane and a far $z$ plane (@fig:perspective-projection).
][
  透视投影描述了场景的透视视图。场景中的点被投影到垂直于 $z$ 轴的观察平面上。#link("<Perspective>")[`Perspective()`];函数计算此变换；它需要`fov`中的视野角度以及到近 $z$ 平面和远 $z$ 平面的距离（@fig:perspective-projection）。
]

#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f06.svg"),
  caption: [
    #ez_caption[
      The perspective transformation matrix projects points in
      camera space onto the near plane. The $x prime$ and $y prime$
      coordinates of the projected points are equal to the unprojected $x$
      and $y$ coordinates divided by the $z$ coordinate. That operation is
      depicted here, where the effect of the projection is indicated by an
      arrow. The projected $z prime$ coordinate is then computed so that
      points on the near plane map to $z prime = 0$ and points on the far
      plane map to $z prime = 1$.
    ][
      透视变换矩阵将相机空间中的点投影到近平面。投影点的$x prime$和$y prime$坐标等于未投影的$x$和$y$坐标除以$z$坐标。这里描绘了这种操作，其中投影效果用箭头表示。然后计算投影的$z prime$坐标，使得近平面上的点映射到$z prime = 0$，远平面上的点映射到$z prime = 1$。
    ]
  ],
)<perspective-projection>



```cpp
Transform Perspective(Float fov, Float n, Float f) {
    // <<Perform projective divide for perspective projection>>
    SquareMatrix<4> persp(1, 0,           0,              0,
                          0, 1,           0,              0,
                          0, 0, f / (f - n), -f*n / (f - n),
                          0, 0,           1,              0);

    // <<Scale canonical perspective view to specified field of view>>
    Float invTanAng = 1 / std::tan(Radians(fov) / 2);
       return Scale(invTanAng, invTanAng, 1) * Transform(persp);
}
```
#parec[
  The transformation is most easily understood in two steps:
][
  该变换可以通过两个步骤最容易理解：
]
#parec[
  1. Points $p$ in camera space are projected onto the viewing plane. A bit of algebra shows that the projected $x'$ and $y'$ coordinates on the viewing plane can be computed by dividing $x$ and $y$ by the point's $z$ coordinate value. The projected $z$ depth is remapped so that $z$ values at the near plane are 0 and $z$ values at the far plane are 1. The computation we would like to do is $$
][
  1. 相机空间中的点$p$被投影到观察平面上。一些代数运算表明，观察平面上投影的$x'$和$y'$坐标可以通过将$x$和$y$除以点的$z$坐标值来计算。投影的$z$深度被重新映射，使得近平面上的$z$值为0，远平面上的$z$值为1。我们想要进行的计算是
]

$
  x' & = frac(x, z) \
  y' & = frac(y, z) \
  z' & = frac(f dot (z - n), z dot (f - n)) .
$

#parec[
  All of this computation can be encoded in a $4 times 4$ matrix that can then be applied to homogeneous coordinates:
][
  所有这些计算可以编码在一个 $4 times 4$ 矩阵中，然后可以应用于齐次坐标：
]

$
  mat(delim: "[", 1, 0, 0, 0;
0, 1, 0, 0;
0, 0, frac(f, f - n), - frac(f n, f - n);
0, 0, 1, 0)
$

```cpp
SquareMatrix<4> persp(1, 0,           0,              0,
                      0, 1,           0,              0,
                      0, 0, f / (f - n), -f*n / (f - n),
                      0, 0,           1,              0);
```

#parec[
  2. The angular field of view (`fov`) specified by the user is accounted for by scaling the $(x, y)$ values on the projection plane so that points inside the field of view project to coordinates between $[-1, 1]$ on the view plane. For square images, both $x$ and $y$ lie between $[-1, 1]$ in screen space. Otherwise, the direction in which the image is narrower maps to $[-1, 1]$, and the wider direction maps to a proportionally larger range of screen space values. Recall that the tangent is equal to the ratio of the opposite side of a right triangle to the adjacent side. Here the adjacent side has length 1, so the opposite side has the length $tan ( "fov" \/ 2 )$. Scaling by the reciprocal of this length maps the field of view to the range $[-1, 1]$.
][
  2. 用户指定的视野角度(`fov`)通过缩放投影平面上的$(x, y)$值来考虑，以便视野内的点投影到观察平面上的$[-1, 1]$坐标之间。对于方形图像，$x$和$y$都在屏幕空间的$[-1, 1]$之间。否则，图像较窄的方向映射到$[-1, 1]$，较宽的方向映射到屏幕空间值的比例较大的范围。回想一下，正切等于直角三角形对边与邻边的比率。这里邻边的长度为1，因此对边的长度为$tan ( "fov" \/ 2 )$。通过该长度的倒数进行缩放，将视野映射到范围$[-1, 1]$。
]
```cpp
Float invTanAng = 1 / std::tan(Radians(fov) / 2);
return Scale(invTanAng, invTanAng, 1) * Transform(persp);
```

#parec[
  As with the `OrthographicCamera` , the `PerspectiveCamera`'s constructor computes information about how the rays it generates change with shifts in pixels. In this case, the ray origins are unchanged and the ray differentials are only different in their directions. Here, we compute the change in position on the near perspective plane in camera space with respect to shifts in pixel location.
][
  与 `OrthographicCamera` 一样，`PerspectiveCamera`的构造函数计算关于其生成的射线如何随像素移动而变化的信息。在这种情况下，射线的原点不变，射线的微分仅在方向上不同。在这里，我们计算相机空间中近透视平面上位置随像素位置变化的变化。
]
```cpp
dxCamera = cameraFromRaster(Point3f(1, 0, 0)) -
           cameraFromRaster(Point3f(0, 0, 0));
dyCamera = cameraFromRaster(Point3f(0, 1, 0)) -
           cameraFromRaster(Point3f(0, 0, 0));
```

```cpp
Vector3f dxCamera, dyCamera;
```

#parec[
  The cosine of the maximum angle of the perspective camera's field of view will occasionally be useful. In particular, points outside the field of view can be quickly culled via a dot product with the viewing direction and comparison to this value. This cosine can be found by computing the angle between the camera's viewing vector and a vector to one of the corners of the image (see @fig:perspective-view-max-cosine). This corner needs a small adjustment here to account for the width of the filter function centered at each pixel that is used to weight image samples according to their location (this topic is discussed in @image-reconstruction).
][
  透视相机视场最大角度的余弦有时会很有用。特别是，视场外的点可以通过与视图方向的点积和与此值的比较快速裁剪。可以通过计算相机视图向量与图像某个角落的向量之间的角度来找到这个余弦（见@fig:perspective-view-max-cosine）。这里需要对这个角落进行小的调整，以考虑用于根据位置对图像样本加权的每个像素中心的滤波函数的宽度（这个主题将在@image-reconstruction 中讨论）。
]

#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f07.svg"),
  caption: [
    #ez_caption[
      Computing the Cosine of the Perspective Camera's Maximum View Angle. A cone that bounds the viewing directions of a `PerspectiveCamera` can be found by using the camera's viewing direction as the center axis and by computing the cosine of the angle $theta$ between that axis and a vector to one of the corners of the image. In camera space, that simplifies to be the $z$ component of that vector, normalized.
    ][
      计算透视相机最大视角的余弦。一个界定透视相机观看方向的锥体可以通过将相机的观看方向作为中心轴，并计算该轴与指向图像某个角落的向量之间的角度 $theta$ 的余弦值来得到。在相机空间中，这简化为该向量的 $z$ 分量，经过归一化处理。
    ]
  ],
)<perspective-view-max-cosine>

```cpp
// <<Compute cosTotalWidth for perspective camera>>=
Point2f radius = Point2f(film.GetFilter().Radius());
Point3f pCorner(-radius.x, -radius.y, 0.f);
Vector3f wCornerCamera = Normalize(Vector3f(cameraFromRaster(pCorner)));
cosTotalWidth = wCornerCamera.z;
```

```cpp
// <<PerspectiveCamera Private Members>>+=
Float cosTotalWidth;
```

#parec[
  With the perspective projection, camera space rays all originate from the origin $(0, 0, 0)$. A ray's direction is given by the vector from the origin to the point on the near plane, `pCamera`, that corresponds to the provided CameraSample's `pFilm` location. In other words, the ray's vector direction is component-wise equal to this point's position, so rather than doing a useless subtraction to compute the direction, we just initialize the direction directly from the point `pCamera`.
][
  通过透视投影，相机空间的射线都起始于原点 $(0, 0, 0)$。射线的方向由从原点到点`pCamera`（提供的 `CameraSample` 的`pFilm`位置对应的近平面上的点）的向量给出。换句话说，射线的向量方向在各分量上等于该点的位置，因此我们不进行无用的减法来计算方向，而是直接从点`pCamera`初始化方向。
]

```cpp
pstd::optional<CameraRay> PerspectiveCamera::GenerateRay(
        CameraSample sample, SampledWavelengths &lambda) const {
    // <<Compute raster and camera sample positions>>
    Point3f pFilm = Point3f(sample.pFilm.x, sample.pFilm.y, 0);
    Point3f pCamera = cameraFromRaster(pFilm);
    Ray ray(Point3f(0, 0, 0), Normalize(Vector3f(pCamera)),
            SampleTime(sample.time), medium);
    // <<Modify ray for depth of field>>
    if (lensRadius > 0) {
        // <<Sample point on lens>>
        Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
        // <<Compute point on plane of focus>>
        Float ft = focalDistance / ray.d.z;
        Point3f pFocus = ray(ft);
        // <<Update ray for effect of lens>>
        ray.o = Point3f(pLens.x, pLens.y, 0);
        ray.d = Normalize(pFocus - ray.o);
    }
    return CameraRay{RenderFromCamera(ray)};
}
```

#parec[
  The `GenerateRayDifferential()` method follows the implementation of `GenerateRay()`, except for this additional fragment that computes the differential rays.
][
  `GenerateRayDifferential()`方法遵循`GenerateRay()`的实现，除了这个额外的片段计算微分射线。
]


```cpp
if (lensRadius > 0) {
    // <<Compute PerspectiveCamera ray differentials accounting for lens>>
    // <<Sample point on lens>>
    Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
    // <<Compute x ray differential for PerspectiveCamera with lens>>
    Vector3f dx = Normalize(Vector3f(pCamera + dxCamera));
    Float ft = focalDistance / dx.z;
    Point3f pFocus = Point3f(0, 0, 0) + (ft * dx);
    ray.rxOrigin = Point3f(pLens.x, pLens.y, 0);
    ray.rxDirection = Normalize(pFocus - ray.rxOrigin);
    // <<Compute y ray differential for PerspectiveCamera with lens>>
    Vector3f dy = Normalize(Vector3f(pCamera + dyCamera));
    ft = focalDistance / dy.z;
    pFocus = Point3f(0, 0, 0) + (ft * dy);
    ray.ryOrigin = Point3f(pLens.x, pLens.y, 0);
    ray.ryDirection = Normalize(pFocus - ray.ryOrigin);
} else {
    ray.rxOrigin = ray.ryOrigin = ray.o;
    ray.rxDirection = Normalize(Vector3f(pCamera) + dxCamera);
    ray.ryDirection = Normalize(Vector3f(pCamera) + dyCamera);
}
```

=== The Thin Lens Model and Depth of Field
#parec[
  An ideal pinhole camera that only allows rays passing through a single point to reach the film is not physically realizable; while it is possible to make cameras with extremely small apertures that approach this behavior, small apertures allow relatively little light to reach the film sensor. With a small aperture, long exposure times are required to capture enough photons to accurately capture the image, which in turn can lead to blur from objects in the scene moving while the camera shutter is open.
][
  一个理想的针孔相机，只允许通过单个点的光线到达胶片，在物理上是无法实现的；虽然可以制造出接近这种行为的极小光圈相机，但小光圈使得到达感光元件的光线相对较少。 使用小光圈时，需要较长的曝光时间来捕捉足够的光子以准确成像。这可能导致在相机快门打开时，场景中的物体移动而产生模糊。
]

#parec[
  Real cameras have lens systems that focus light through a finite-sized aperture onto the film plane. Camera designers (and photographers using cameras with adjustable apertures) face a trade-off: the larger the aperture, the more light reaches the film and the shorter the exposures that are needed. However, lenses can only focus on a single plane (the _focal plane_), and the farther objects in the scene are from this plane, the blurrier they are. The larger the aperture, the more pronounced this effect is.
][
  真实的相机有透镜系统，通过有限大小的光圈将光线聚焦到胶片平面上。 相机设计师（以及使用可调光圈相机的摄影师）面临一个权衡：光圈越大，到达胶片的光线越多，所需的曝光时间越短。 然而，透镜只能聚焦在一个平面上（_焦平面_），场景中离这个平面越远的物体就越模糊。 随着光圈的增大，这种效果会更加明显。
]

#parec[
  The `RealisticCamera` (included only in the online edition of the book) implements a fairly accurate simulation of lens systems in real-world cameras. For the simple camera models introduced so far, we can apply a classic approximation from optics, the #emph[thin lens approximation];, to model the effect of finite apertures with traditional computer graphics projection models. The thin lens approximation models an optical system as a single lens with spherical profiles, where the thickness of the lens is small relative to the radius of curvature of the lens.
][
  `RealisticCamera`（仅在本书的在线版中提供）实现了对真实世界相机透镜系统的相当准确的模拟。 对于迄今为止介绍的简单相机模型，我们可以应用光学中的经典近似，即薄透镜近似，以使用传统计算机图形投影模型模拟有限光圈的效果。 薄透镜近似将光学系统建模为一个具有球面轮廓的单透镜，其中透镜的厚度相对于透镜的曲率半径较小。
]

#parec[
  Under the thin lens approximation, incident rays that are parallel to the optical axis and pass through the lens focus at a point behind the lens called the #emph[focal point];. The distance the focal point is behind the lens, $f$, is the lens's #emph[focal length];. If the film plane is placed at a distance equal to the focal length behind the lens, then objects infinitely far away will be in focus, as they image to a single point on the film.
][
  在薄透镜近似下，与光轴平行并通过透镜的入射光线在透镜后面的一个点聚焦，该点称为焦点。 焦点在透镜后面的距离 $f$ 是透镜的焦距。 如果胶片平面放置在透镜后面等于焦距的距离处，则无限远的物体将聚焦，因为它们在胶片上成像为一个点。
]

#parec[
  @fig:thin-lens-basics illustrates the basic setting. Here we have followed the typical lens coordinate system convention of placing the lens perpendicular to the $z$ axis, with the lens at $z = 0$ and the scene along negative $z$. (Note that this is a different coordinate system from the one we used for camera space, where the viewing direction is positive $z$.) Distances on the scene side of the lens are denoted with unprimed variables $z$, and distances on the film side of the lens (positive $z$ ) are primed, $z prime$ .
][
  @fig:thin-lens-basics 展示了基本设置。 这里我们遵循典型的透镜坐标系惯例，将透镜放置在垂直于 $z$ 轴的位置，透镜位于 $z = 0$，场景沿负 $z$ 方向。 （请注意，这与我们用于相机空间的坐标系不同，其中视线方向为正 $z$。） 透镜场景侧的距离用未加撇号的变量 $z$ 表示，透镜胶片侧的距离（正 $z$ ）用加撇号的变量 $z prime$ 表示。
]


#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f08.svg"),
  caption: [
    #ez_caption[A thin lens, located along the $z$ axis at $z=0$. Incident rays that are parallel to the optical axis and pass through a thin lens (dashed lines) all pass through a point $p$, the focal point. The distance between the lens and the focal point, $f$, is the lens's focal length.][一个薄透镜位于 $z$ 轴的 $z=0$ 位置。与光轴平行并通过薄透镜的入射光线（虚线）均通过一个点 $p$，即焦点。透镜与焦点之间的距离 $f$ 是透镜的焦距。]
  ],
)<thin-lens-basics>

#parec[
  For points in the scene at a depth $z$ from a thin lens with focal length $f$, the #emph[Gaussian lens equation] relates the distances from the object to the lens and from the lens to the image of the point:
][
  对于场景中距离薄透镜焦距 $f$ 为 $z$ 的点，高斯透镜方程关联了物体到透镜的距离和透镜到该点图像的距离：
]

$ frac(1, z prime) - 1 / z = 1 / f . $<thin-lens>


#parec[
  Note that for $z = - oo$, we have $z prime = f$, as expected.
][
  注意，对于 $z = - oo$，我们有 $z prime = f$，这符合预期。
]

#parec[
  We can use the Gaussian lens equation to solve for the distance between the lens and the film that sets the plane of focus at some $z$, the #emph[focal distance] (@fig:thin-lens-focus):
][
  我们可以使用高斯透镜方程来求解透镜与胶片之间的距离，以在某个 $z$ 处设置焦平面，即焦距（@fig:thin-lens-focus）：
]

$ z prime = frac(f z, f + z) . $<thin-lens-focus>

#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f09.svg"),
  caption: [
    #ez_caption[To focus a thin lens at a depth $z$ in the scene, @eqt:thin-lens-focus can be used to compute the distance $z prime$ on the film side of the lens that points at $z$ focus to. Focusing is performed by adjusting the distance between the lens and the film plane.][要将薄透镜聚焦在场景中的深度$z$处，可以使用@eqt:thin-lens-focus 计算透镜胶片侧指向$z$焦点的距离$z prime$。通过调整透镜和胶片平面之间的距离来进行聚焦。]
  ],
)<thin-lens-focus>

#parec[
  A point that does not lie on the plane of focus is imaged to a disk on the film plane, rather than to a single point. The boundary of this disk is called the #emph[circle of confusion];. The size of the circle of confusion is affected by the diameter of the aperture that light rays pass through, the focal distance, and the distance between the object and the lens. Although the circle of confusion only has zero radius for a single depth, a range of nearby depths have small enough circles of confusion that they still appear to be in focus. (As long as its circle of confusion is smaller than the spacing between pixels, a point will effectively appear to be in focus.) The range of depths that appear in focus are termed the #emph[depth of
field];.
][
  不在焦平面上的点在胶片平面上成像为一个圆盘，而不是一个点。 这个圆盘的边界称为弥散圆。 弥散圆的大小受光线通过的光圈直径、焦距和物体与透镜之间距离的影响。 虽然弥散圆只有在单个深度处半径为零，但附近的一些深度的弥散圆足够小，看起来仍然是对焦的。 （只要其弥散圆小于像素间距，点就会有效地看起来是对焦的。） 看起来清晰的深度范围称为景深。
]

#parec[
  @fig:dof-images shows this effect, in the #emph[Watercolor] scene. As the size of the lens aperture increases, blurriness increases the farther a point is from the plane of focus. Note that the pencil cup in the center remains in focus throughout all the images, as the plane of focus has been placed at its depth. @fig:ecosys-dof shows depth of field used to render the landscape scene. Note how the effect draws the viewer's eye to the in-focus grass in the center of the image.
][
  @fig:dof-images 显示了这种效果，在 #emph[水彩] 场景中。 随着透镜光圈的增大，离焦平面越远的点模糊度越大。 注意，中心的铅笔杯在所有图像中始终保持对焦，因为焦平面已放置在其深度处。 @fig:ecosys-dof 显示了用于渲染景观场景的景深。 注意这种效果如何将观众的目光吸引到图像中心对焦的草地上。
]


#figure(
  table(
    columns: 3,
    stroke: none,
    [#image("../pbr-book-website/4ed/Cameras_and_Film/watercolor-dof-0.png")],
    [#image("../pbr-book-website/4ed/Cameras_and_Film/watercolor-dof-1.png")],
    [#image("../pbr-book-website/4ed/Cameras_and_Film/watercolor-dof-2.8.png")],

    [(a) No defocus], [(b) small aperture], [(c) large Lens aperture],
  ),
  caption: [
    #ez_caption[ (a) Scene rendered with no defocus blur, (b) extensive depth of field due to a relatively small lens aperture, which gives only a small amount of blurriness in the out-of-focus regions, and (c) a very large aperture, giving a larger circle of confusion in the out-of-focus areas, resulting in a greater amount of blur on the film plane. (Scene courtesy of Angelo Ferretti.)][ (a) 没有散焦模糊渲染的场景，(b) 由于相对较小的镜头光圈而产生的广阔景深，这使得失焦区域只有少量模糊，以及 (c) 一个非常大的光圈，在失焦区域形成更大的模糊圈，导致胶卷平面上出现更多的模糊。（场景由 Angelo Ferretti 提供。）]
  ],
  kind: image,
)<dof-images>


#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/landscape-dof.png"),
  caption: [
    #ez_caption[Depth of field gives a greater sense of depth and scale to this part of the landscape scene. (Scene courtesy of Laubwerk.)][景深为这部分景观场景增添了更强的深度和尺度感。（场景由 Laubwerk 提供。）]
  ],
)<ecosys-dof>


#parec[
  The Gaussian lens equation also lets us compute the size of the circle of confusion; given a lens with focal length $f$ that is focused at a distance $z_f$, the film plane is at $z prime_f$. Given another point at depth $z$, the Gaussian lens equation gives the distance $z prime$ that the lens focuses the point to. This point is either in front of or behind the film plane; @fig:circle-of-confusion-area (a) shows the case where it is behind.
][
  高斯透镜方程还让我们可以计算弥散圆的大小；给定一个焦距为 $f$ 的透镜，聚焦在距离 $z_f$ 处，胶片平面位于 $z prime_f$。 给定另一个深度为 $z$ 的点，高斯透镜方程给出了透镜将该点聚焦到的距离 $z prime$。 这个点要么在胶片平面前面，要么在后面；@fig:circle-of-confusion-area (a) 显示了它在后面的情况。
]



#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f12.svg"),
  caption: [
    #ez_caption[(a) If a thin lens with focal length $f$ is focused at some depth $z_f$, then the distance from the lens to the focus plane is $z'_f$, given by the Gaussian lens equation. A point in the scene at depth $z eq.not z_f$ will be imaged as a circle on the film plane; here $z$ focuses at $z'$, which is behind the film plane. (b) To compute the diameter of the circle of confusion, we can apply similar triangles: the ratio of $d_l$, the diameter of the lens, to $z'$ must be the same as the ratio of $d_c$, the diameter of the circle of confusion, to $z' - z'_f$. ][(a) 如果一个焦距为 $f$ 的薄透镜聚焦在某个深度 $z_f$，那么透镜到焦平面的距离为 $z'_f$，由高斯透镜方程给出。场景中位于深度 $z eq.not z_f$ 的一点将在胶卷平面上成像为一个圆；这里 $z$ 聚焦在 $z'$，而 $z'$ 在胶卷平面后面。(b) 要计算模糊圆的直径，我们可以应用相似三角形：透镜直径 $d_l$ 与 $z'$ 的比例必须与模糊圆直径 $d_c$ 与 $z' - z'_f$ 的比例相同。]
  ],
)<circle-of-confusion-area>


#parec[
  The diameter of the circle of confusion is given by the intersection of the cone between $z prime$ and the lens with the film plane. If we know the diameter of the lens $d_l$, then we can use similar triangles to solve for the diameter of the circle of confusion $d_c$ (@fig:circle-of-confusion-area(b)):
][
  弥散圆的直径由 $z prime$ 和透镜之间的锥体与胶片平面的交点给出。 如果我们知道透镜的直径 $d_l$，那么我们可以使用相似三角形来求解弥散圆的直径 $d_c$ （@fig:circle-of-confusion-area(b)）：
]


$ frac(d_l, z prime) = frac(d_c, lr(|z prime - z_f|)) . $

#parec[
  Solving for $d_c$, we have
][
  求解 $d_c$，我们得到
]

$ d_c = lr(|frac(d_l (z prime - z_f), z prime)|) . $


#parec[
  Applying the Gaussian lens equation to express the result in terms of scene depths, we can find that
][
  应用高斯透镜方程以场景深度表示结果，我们可以发现
]

$ d_c = lr(|frac(d_l f (z - z_f), z (f + z_f))|) . $


#parec[
  Note that the diameter of the circle of confusion is proportional to the diameter of the lens. The lens diameter is often expressed as the lens's _f-number_ $d_l = f \/ n$.
][
  注意，弥散圆的直径与透镜的直径成比例。透镜直径通常表示为透镜的光圈系数 $d_l = f \/ n$。
]

#parec[
  @fig:circle-of-confusion-graph shows a graph of this function for a 50-mm focal length lens with a 25-mm aperture, focused at $z_f = 1 upright(" m")$. Note that the blur is asymmetric with depth around the focal plane and grows much more quickly for objects in front of the plane of focus than for objects behind it.
][
  @fig:circle-of-confusion-graph 显示了该函数的图形，使用50毫米焦距的透镜和25毫米的光圈，聚焦在 $z_f = 1 upright(" m")$。注意，焦平面前后的模糊程度是不对称的，前方物体的模糊增长速度比后方更快。
]


#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f13.svg"),
  caption: [
    #ez_caption[The diameter of the circle of confusion as a function of depth for a 50-mm focal length lens with 25-mm aperture, focused at 1 meter.][对于焦距为50毫米、孔径为25毫米、聚焦在1米处的透镜，弥散圆的直径与深度的函数关系。]
  ],
)<circle-of-confusion-graph>


#parec[
  Modeling a thin lens in a ray tracer is remarkably straightforward: all that is necessary is to choose a point on the lens and find the appropriate ray that starts on the lens at that point such that objects in the plane of focus are in focus on the film (@fig:depth-computation). Therefore, projective cameras take two extra parameters for depth of field: one sets the size of the lens aperture, and the other sets the focal distance.
][
  在光线追踪器中建模一个薄透镜非常简单：只需选择透镜上的一个点，并找到从该点开始在透镜上以使焦平面内的物体在胶片上聚焦的适当光线(@fig:depth-computation ）。因此，投影相机为景深提供两个额外参数：一个设置透镜光圈的大小，另一个设置焦距。
]

#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/pha05f14.svg"),
  caption: [
    #ez_caption[(a) For a pinhole camera model, a single camera ray is associated with each point on the film plane (filled circle), given by the ray that passes through the single point of the pinhole lens (empty circle). (b) For a camera model with a finite aperture, we sample a point (filled circle) on the disk-shaped lens for each ray. We then compute the ray that passes through the center of the lens (corresponding to the pinhole model) and the point where it intersects the plane of focus (solid line). We know that all objects in the plane of focus must be in focus, regardless of the lens sample position. Therefore, the ray corresponding to the lens position sample (dashed line) is given by the ray starting on the lens sample point and passing through the computed intersection point on the plane of focus.][对于焦距为50毫米、孔径为25毫米、聚焦在1米处的透镜，弥散圆的直径与深度的函数关系。（a） 对于针孔相机模型，单个相机光线与胶片平面（实心圆）上的每个点相关联，由穿过针孔透镜单个点的光线（空心圆）给出。（b） 对于具有有限孔径的相机模型，我们为每条光线在盘形透镜上采样一个点（实心圆）。然后，我们计算穿过透镜中心（对应于针孔模型）的光线以及它与焦平面相交的点（实线）。我们知道，无论透镜样品的位置如何，焦平面内的所有物体都必须聚焦。因此，与透镜位置样本（虚线）对应的光线由从透镜样本点开始并穿过焦平面上计算出的交点的光线给出。]
  ],
)<depth-computation>


```cpp
// <<ProjectiveCamera Protected Members>>+=
Float lensRadius, focalDistance;
```


#parec[
  It is generally necessary to trace many rays for each image pixel in order to adequately sample the lens for smooth defocus blur. @fig:field-depth-11 shows the landscape scene from @fig:ecosys-dof with only four samples per pixel (@fig:ecosys-dof had 2048 samples per pixel).
][
  通常需要为每个图像像素追踪许多光线，以充分采样透镜以获得平滑的散焦模糊。@fig:field-depth-11 显示了@fig:ecosys-dof 中的景观场景，每个像素只有四个样本（@fig:ecosys-dof 有2048个样本每像素）。
]



#figure(
  image("../pbr-book-website/4ed/Cameras_and_Film/landscape-dof-4spp.png"),
  caption: [
    #ez_caption[Landscape scene with depth of field and only four samples per pixel: the depth of field is undersampled and the image is grainy. (Scene courtesy of Laubwerk.)][景深场景，每像素仅有四个采样点：由于景深采样不足，图像呈现颗粒感。（场景由 Laubwerk 提供。） ]
  ],
)<field-depth-11>

```cpp
// <<Modify ray for depth of field>>=
if (lensRadius > 0) {
    // <<Sample point on lens>>
    Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);

    // <<Compute point on plane of focus>>
    Float ft = focalDistance / ray.d.z;
    Point3f pFocus = ray(ft);

    // <<Update ray for effect of lens>>
    ray.o = Point3f(pLens.x, pLens.y, 0);
    ray.d = Normalize(pFocus - ray.o);

}
```

#parec[
  The `SampleUniformDiskConcentric()` function, which is defined in Section A.5.1, takes a $(u , v)$ sample position in $[0 , 1]^2$ and maps it to a 2D unit disk centered at the origin $(0 , 0)$. To turn this into a point on the lens, these coordinates are scaled by the lens radius. The `CameraSample` class provides the $(u , v)$ lens-sampling parameters in the `pLens` member variable.
][
  `SampleUniformDiskConcentric()`函数在第A.5.1节中定义，接受 $[0 , 1]^2$ 中的 $(u , v)$ 样本位置并将其映射到以原点 $(0 , 0)$ 为中心的二维单位圆盘。为了将其转换为透镜上的一个点，这些坐标按透镜半径缩放。`CameraSample`类在`pLens`成员变量中提供 $(u , v)$ 透镜采样参数。
]

```cpp
// <<Sample point on lens>>=
Point2f pLens = lensRadius * SampleUniformDiskConcentric(sample.pLens);
```

#parec[
  The ray's origin is this point on the lens. Now it is necessary to determine the proper direction for the new ray. We know that #emph[all] rays from the given image sample through the lens must converge at the same point on the plane of focus. Furthermore, we know that rays pass through the center of the lens without a change in direction, so finding the appropriate point of convergence is a matter of intersecting the unperturbed ray from the pinhole model with the plane of focus and then setting the new ray's direction to be the vector from the point on the lens to the intersection point.
][
  光线的起点是透镜上的这个点。现在需要确定新光线的正确方向。我们知道，_所有_通过透镜的给定图像样本的光线必须在焦平面的同一点汇聚。此外，我们知道光线穿过透镜中心时方向不变，因此找到适当的汇聚点就是将针孔模型的未扰动光线与焦平面相交，然后将新光线的方向设置为从透镜上的点到交点的向量。
]

#parec[
  For this simple model, the plane of focus is perpendicular to the $z$ axis and the ray starts at the origin, so intersecting the ray through the lens center with the plane of focus is straightforward. The $t$ value of the intersection is given by
][
  对于这个简单模型，焦平面垂直于 $z$ 轴，光线从原点开始，因此将穿过透镜中心的光线与焦平面相交是直接的。交点的 $t$ 值由以下公式给出
]

$ t = frac("focalDistance", upright(bold(d))_z) . $


```cpp
// <<Compute point on plane of focus>>=
Float ft = focalDistance / ray.d.z;
Point3f pFocus = ray(ft);
```

#parec[
  Now the ray can be initialized. The origin is set to the sampled point on the lens, and the direction is set so that the ray passes through the point on the plane of focus, `pFocus`.
][
  现在可以初始化光线。起点设置为透镜上的采样点，方向设置为光线穿过焦平面上的点`pFocus`。
]

```cpp
// <<Update ray for effect of lens>>=
ray.o = Point3f(pLens.x, pLens.y, 0);
ray.d = Normalize(pFocus - ray.o);
```

#parec[
  To compute ray differentials with the thin lens, the approach used in the fragment `<<Update ray for effect of lens>>` is applied to rays offset one pixel in the $x$ and $y$ directions on the film plane. The fragments that implement this, `<<Compute OrthographicCamera ray differentials accounting for lens>>` and `<<Compute PerspectiveCamera ray differentials accounting for lens>>`, are not included here.
][
  为了使用薄透镜计算光线微分，`<<Update ray for effect of lens>>`片段中使用的方法应用于在胶片平面上 $x$ 和 $y$ 方向上偏移一个像素的光线。实现此功能的片段`<<Compute OrthographicCamera ray differentials accounting for lens>>`和`<<Compute PerspectiveCamera ray differentials accounting for lens>>`未在此处包含。
]

