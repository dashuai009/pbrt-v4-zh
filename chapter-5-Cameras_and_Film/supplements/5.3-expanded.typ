#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Spherical_Camera.html#fragbit-269")[`fragbit-269`]]
#block(breakable: false)[
```cpp
static SphericalCamera *Create(const ParameterDictionary &parameters,
                               const CameraTransform &cameraTransform,
                               Film film, Medium medium,
                               const FileLoc *loc, Allocator alloc = {});
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
pstd::optional<CameraRay> GenerateRay(CameraSample sample,
                                      SampledWavelengths &lambda) const;
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
pstd::optional<CameraRayDifferential> GenerateRayDifferential(
    CameraSample sample, SampledWavelengths &lambda) const {
    return CameraBase::GenerateRayDifferential(this, sample, lambda);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
SampledSpectrum We(const Ray &ray, SampledWavelengths &lambda,
                   Point2f *pRaster2 = nullptr) const {
    LOG_FATAL("We() unimplemented for SphericalCamera");
    return {};
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
void PDF_We(const Ray &ray, Float *pdfPos, Float *pdfDir) const {
    LOG_FATAL("PDF_We() unimplemented for SphericalCamera");
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
pstd::optional<CameraWiSample> SampleWi(const Interaction &ref, Point2f u,
                                        SampledWavelengths &lambda) const {
    LOG_FATAL("SampleWi() unimplemented for SphericalCamera");
    return {};
}
```
]

#block(breakable: false)[
```cpp
std::string ToString() const;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Spherical_Camera.html#fragbit-270")[`fragbit-270`]]
#block(breakable: false)[
```cpp
FindMinimumDifferentials(this);
```
]
