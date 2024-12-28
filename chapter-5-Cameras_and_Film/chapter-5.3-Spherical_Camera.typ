#import "../template.typ": parec, ez_caption

== Spherical Camera
<spherical-camera>
#parec[
  One advantage of ray tracing compared to scan line or rasterization-based rendering methods is that it is easy to employ unusual image projections. We have great freedom in how the image sample positions are mapped into ray directions, since the rendering algorithm does not depend on properties such as straight lines in the scene always projecting to straight lines in the image.
][
  与扫描线或光栅化渲染方法相比，光线追踪的一个优势是可以轻松使用非传统的图像投影。我们在将图像样本位置映射到射线方向时有很大的自由度，因为渲染算法不依赖于场景中的直线总是投影为图像中的直线等属性。
]

#parec[
  In this section, we will describe a camera model that traces rays in all directions around a point in the scene, giving a view of everything that is visible from that point. The `SphericalCamera` supports two spherical parameterizations from @Spherical_Geometry to map points in the image to associated directions. Figure 5.16 shows this camera in action with the #emph[San Miguel] model.
][
  在本节中，我们将描述一种相机模型，该模型在场景中的一个点周围的所有方向上追踪光线，从而提供从该点可见的所有事物的视图。`SphericalCamera` 支持@Spherical_Geometry 中的两种球面参数化方法，将图像中的点映射到相关方向。图 5.16 显示了使用 #emph[San Miguel] 模型的该相机的实际效果。
]

```cpp
class SphericalCamera : public CameraBase {
  public:
    enum Mapping { EquiRectangular, EqualArea };
    SphericalCamera(CameraBaseParameters baseParameters, Mapping mapping)
           : CameraBase(baseParameters), mapping(mapping) {
              FindMinimumDifferentials(this);
       }
    static SphericalCamera *Create(const ParameterDictionary &parameters,
                                  const CameraTransform &cameraTransform,
                                  Film film, Medium medium,
                                  const FileLoc *loc, Allocator alloc = {});

    PBRT_CPU_GPU
    pstd::optional<CameraRay> GenerateRay(CameraSample sample,
                                          SampledWavelengths &lambda) const;

    PBRT_CPU_GPU
    pstd::optional<CameraRayDifferential> GenerateRayDifferential(
        CameraSample sample, SampledWavelengths &lambda) const {
        return CameraBase::GenerateRayDifferential(this, sample, lambda);
    }

    PBRT_CPU_GPU
    SampledSpectrum We(const Ray &ray, SampledWavelengths &lambda,
                      Point2f *pRaster2 = nullptr) const {
        LOG_FATAL("We() unimplemented for SphericalCamera");
        return {};
    }

    PBRT_CPU_GPU
    void PDF_We(const Ray &ray, Float *pdfPos, Float *pdfDir) const {
        LOG_FATAL("PDF_We() unimplemented for SphericalCamera");
    }

    PBRT_CPU_GPU
    pstd::optional<CameraWiSample> SampleWi(const Interaction &ref, Point2f u,
                                            SampledWavelengths &lambda) const {
        LOG_FATAL("SampleWi() unimplemented for SphericalCamera");
        return {};
    }

    std::string ToString() const;
  private:
    Mapping mapping;
};
```


#figure(
  table(
    columns: 1,
    stroke: none,
    [#image("../pbr-book-website/4ed/Cameras_and_Film/sanmiguel-equirectangular.png")],
    [(a) Equirectangular Mapping],
    [#image("../pbr-book-website/4ed/Cameras_and_Film/sanmiguel-equalarea.png", width: 50%)],
    [(b) Equal-area Mapping],
  ),
  caption: [
    #ez_caption[
      The #emph[San Miguel] scene rendered with the
      `SphericalCamera`, which traces rays in all directions from the camera position. (a) Rendered using an equirectangular mapping. (b) Rendered with an equal-area mapping. #emph[Scene courtesy of Guillermo M. Leal Llaguno.]
    ][
      使用 `SphericalCamera` 渲染的 #emph[San Miguel] 场景，该相机从相机位置向所有方向追踪光线。(a) 使用等距矩形映射渲染。(b) 使用等面积映射渲染。#emph[场景由 Guillermo M. Leal Llaguno 提供。]
    ]
  ],
  kind: image,
)<envcamera-san-miguel>

#parec[
  `SphericalCamera` does not derive from `ProjectiveCamera` since the projections that it uses are nonlinear and cannot be captured by a single $4 times 4$ matrix.
][
  `SphericalCamera` 不从 `ProjectiveCamera` 派生，因为它使用的投影是非线性的，不能通过单个 $4 times 4$ 矩阵捕获。
]

```cpp
SphericalCamera(CameraBaseParameters baseParameters, Mapping mapping)
    : CameraBase(baseParameters), mapping(mapping) {
    FindMinimumDifferentials(this);
}
```
#parec[
  The first mapping that `SphericalCamera` supports is the equirectangular mapping that was defined in @Spherical_Geometry. In the implementation here, $theta$ values range from $0$ at the top of the image to $pi$ at the bottom of the image, and $phi.alt$ values range from $0$ to $2 pi$, moving from left to right across the image.
][
  `SphericalCamera` 支持的第一种映射是@Spherical_Geometry 中定义的等距矩形映射。在此实现中， $theta$ 值从图像顶部的 $0$ 到图像底部的 $pi$，而 $phi.alt$ 值从 $0$ 到 $2 pi$，从左到右移动。
]

#parec[
  The equirectangular mapping is easy to evaluate and has the advantage that lines of constant latitude and longitude on the sphere remain straight. However, it preserves neither area nor angles between curves on the sphere (i.e., it is not #emph[conformal];). These issues are especially evident at the top and bottom of the image in @fig:envcamera-san-miguel(a).
][
  等距矩形映射易于评估，其优点是球体上的恒定纬度和经度线保持直线。然而，它既不保留面积也不保留球面上曲线之间的角度（即，它不是#emph[共形];的）。这些问题在@fig:envcamera-san-miguel(a) 的图像顶部和底部尤其明显。
]

#parec[
  Therefore, the `SphericalCamera` also supports the equal-area mapping from @spherical-parameterizations. With this mapping, any finite solid angle of directions on the sphere maps to the same area in the image, regardless of where it is on the sphere. (This mapping is also used by the `ImageInfiniteLight`, which is described in @image-infinite-lights, and so images rendered using this camera can be used as light sources.) The equal-area mapping's use with the `SphericalCamera` is shown in Figure 5.16(b).
][
  因此，`SphericalCamera` 还支持@spherical-parameterizations 节中的等面积映射。使用此映射，球面上任何有限的立体角方向都映射到图像中的相同面积，无论它在球体上的哪个位置。（此映射也被 `ImageInfiniteLight` 使用，如 @image-infinite-lights 节所述，因此使用此相机渲染的图像可以用作光源。）@fig:envcamera-san-miguel(b) 显示了 `SphericalCamera` 使用等面积映射的效果。
]

#parec[
  An enumeration reflects which mapping should be used.
][
  一个枚举反映了应该使用哪种映射。
]

```cpp
// <<SphericalCamera::Mapping Definition>>
enum Mapping { EquiRectangular, EqualArea };
```


```cpp
// <<SphericalCamera Private Members>>
Mapping mapping;
```
#parec[
  The main task of the `GenerateRay()` method is to apply the requested mapping. The rest of it follows the earlier `GenerateRay()` methods.
][
  `GenerateRay()` 方法的主要任务是应用请求的映射。其余部分遵循早期的 `GenerateRay()` 方法。
]

```cpp
pstd::optional<CameraRay> SphericalCamera::GenerateRay(
        CameraSample sample, SampledWavelengths &lambda) const {
    Point2f uv(sample.pfilm.x / film.FullResolution().x,
                  sample.pfilm.y / film.FullResolution().y);
    Vector3f dir;
    if (mapping == EquiRectangular) {
          Float theta = Pi * uv[1], phi = 2 * Pi * uv[0];
          dir = SphericalDirection(std::sin(theta), std::cos(theta), phi);
    } else {
          uv = WrapEqualAreaSquare(uv);
          dir = EqualAreaSquareToSphere(uv);
    }
    pstd::swap(dir.y, dir.z);
    Ray ray(Point3f(0, 0, 0), dir, SampleTime(sample.time), medium);
    return CameraRay{RenderFromCamera(ray)};
}
```

#parec[
  For the use of both mappings, $(u , v)$ coordinates in NDC space are found by dividing the raster space sample location by the image's overall resolution. Then, after the mapping is applied, the $y$ and $z$ coordinates are swapped to account for the fact that both mappings are defined with $z$ as the "up" direction, while $y$ is "up" in camera space.
][
  对于两种映射的使用，通过将光栅空间采样位置除以图像的整体分辨率来找到标准化设备坐标空间 (NDC) 中的 $(u , v)$ 坐标。然后，在应用映射后，交换 $y$ 和 $z$ 坐标，以考虑到两种映射都将 $z$ 定义为“向上”方向，而在相机空间中 $y$ 是“向上”方向。
]

```cpp
Point2f uv(sample.pfilm.x / film.FullResolution().x,
           sample.pfilm.y / film.FullResolution().y);
Vector3f dir;
if (mapping == EquiRectangular) {
    Float theta = Pi * uv[1], phi = 2 * Pi * uv[0];
    dir = SphericalDirection(std::sin(theta), std::cos(theta), phi);
} else {
    uv = WrapEqualAreaSquare(uv);
    dir = EqualAreaSquareToSphere(uv);
}
pstd::swap(dir.y, dir.z);
```


#parec[
  For the equirectangular mapping, the $(u , v)$ coordinates are scaled to cover the $(theta , phi.alt)$ range and the spherical coordinate formula is used to compute the ray direction.
][
  对于等距矩形映射，将 $(u , v)$ 坐标缩放以覆盖 $(theta , phi.alt)$ 范围，并使用球面坐标公式计算射线方向。
]

```cpp
Float theta = Pi * uv[1], phi = 2 * Pi * uv[0];
dir = SphericalDirection(std::sin(theta), std::cos(theta), phi);
```

#parec[
  The $(u , v)$ values for the `CameraSample` may be slightly outside of the range $[0 , 1]^2$, due to the pixel sample filter function. A call to `WrapEqualAreaSquare()` takes care of handling the boundary conditions before `EqualAreaSquareToSphere()` performs the actual mapping.
][
  由于像素采样滤波函数，`CameraSample` 的 $(u , v)$ 值可能略微超出 $[0 , 1]^2$ 范围。调用 `WrapEqualAreaSquare()` 函数用于处理边界条件，然后 `EqualAreaSquareToSphere()` 执行实际映射。
]

```cpp
uv = WrapEqualAreaSquare(uv);
dir = EqualAreaSquareToSphere(uv);
```




