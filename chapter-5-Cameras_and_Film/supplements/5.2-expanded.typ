#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-215")[`fragbit-215`]]
```cpp
ProjectiveCamera() = default;
void InitMetadata(ImageMetadata *metadata) const;

std::string BaseToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-222")[`fragbit-222`]]
```cpp
PBRT_CPU_GPU
pstd::optional<CameraRay> GenerateRay(CameraSample sample,
                                      SampledWavelengths &lambda) const;
PBRT_CPU_GPU
pstd::optional<CameraRayDifferential> GenerateRayDifferential(
    CameraSample sample, SampledWavelengths &lambda) const;
static OrthographicCamera *Create(const ParameterDictionary &parameters,
                                  const CameraTransform &cameraTransform,
                                  Film film, Medium medium,
                                  const FileLoc *loc, Allocator alloc = {});

PBRT_CPU_GPU
SampledSpectrum We(const Ray &ray, SampledWavelengths &lambda,
                   Point2f *pRaster2 = nullptr) const {
    LOG_FATAL("We() unimplemented for OrthographicCamera");
    return {};
}

PBRT_CPU_GPU
void PDF_We(const Ray &ray, Float *pdfPos, Float *pdfDir) const {
    LOG_FATAL("PDF_We() unimplemented for OrthographicCamera");
}

PBRT_CPU_GPU
pstd::optional<CameraWiSample> SampleWi(const Interaction &ref, Point2f u,
                                        SampledWavelengths &lambda) const {
    LOG_FATAL("SampleWi() unimplemented for OrthographicCamera");
    return {};
}

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-224")[`fragbit-224`]]
```cpp
minDirDifferentialX = minDirDifferentialY = Vector3f(0, 0, 0);
minPosDifferentialX = dxCamera;
minPosDifferentialY = dyCamera;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-233")[`fragbit-233`]]
```cpp
<<Compute raster and camera sample positions>>
RayDifferential ray(pCamera, Vector3f(0, 0, 1), SampleTime(sample.time), medium);
<<Modify ray for depth of field>>
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-240")[`fragbit-240`]]
```cpp
<<Sample point on lens>>
Float ft = focalDistance / ray.d.z;
Point3f pFocus = pCamera + dxCamera + (ft * Vector3f(0, 0, 1));
ray.rxOrigin = Point3f(pLens.x, pLens.y, 0);
ray.rxDirection = Normalize(pFocus - ray.rxOrigin);

pFocus = pCamera + dyCamera + (ft * Vector3f(0, 0, 1));
ray.ryOrigin = Point3f(pLens.x, pLens.y, 0);
ray.ryDirection = Normalize(pFocus - ray.ryOrigin);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-244")[`fragbit-244`]]
```cpp
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
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-248")[`fragbit-248`]]
```cpp
FindMinimumDifferentials(this);
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Projective_Camera_Models.html#fragbit-261")[`fragbit-261`]]
```cpp
<<Sample point on lens>>
Vector3f dx = Normalize(Vector3f(pCamera + dxCamera));
Float ft = focalDistance / dx.z;
Point3f pFocus = Point3f(0, 0, 0) + (ft * dx);
ray.rxOrigin = Point3f(pLens.x, pLens.y, 0);
ray.rxDirection = Normalize(pFocus - ray.rxOrigin);
Vector3f dy = Normalize(Vector3f(pCamera + dyCamera));
ft = focalDistance / dy.z;
pFocus = Point3f(0, 0, 0) + (ft * dy);
ray.ryOrigin = Point3f(pLens.x, pLens.y, 0);
ray.ryDirection = Normalize(pFocus - ray.ryOrigin);
```
