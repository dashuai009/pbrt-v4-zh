#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#parec[The following member fragments are present in the fixed original page but not repeated in its visible code.][以下成员片段来自固定原网页，正文可见代码中未重复列出。]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-196")[`fragbit-196`]]
#block(breakable: false)[
```cpp
using TaggedPointer::TaggedPointer;

static Camera Create(const std::string &name,
                           const ParameterDictionary &parameters, Medium medium,
                           const CameraTransform &cameraTransform, Film film,
                           const FileLoc *loc, Allocator alloc);

std::string ToString() const;

void Approximate_dp_dxy(Point3f p, Normal3f n, Float time,
    int samplesPerPixel, Vector3f *dpdx, Vector3f *dpdy) const;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-197")[`fragbit-197`]]
#block(breakable: false)[
```cpp
CameraTransform() = default;
explicit CameraTransform(const AnimatedTransform &worldFromCamera);
Point3f RenderFromCamera(Point3f p, Float time) const {
    return renderFromCamera(p, time);
}
Point3f CameraFromRender(Point3f p, Float time) const {
    return renderFromCamera.ApplyInverse(p, time);
}
Point3f RenderFromWorld(Point3f p) const {
    return worldFromRender.ApplyInverse(p);
}
Transform RenderFromWorld() const { return Inverse(worldFromRender); }
Transform CameraFromRender(Float time) const {
    return Inverse(renderFromCamera.Interpolate(time));
}
Transform CameraFromWorld(Float time) const {
    return Inverse(worldFromRender * renderFromCamera.Interpolate(time));
}
PBRT_CPU_GPU
bool CameraFromRenderHasScale() const { return renderFromCamera.HasScale(); }
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Vector3f RenderFromCamera(Vector3f v, Float time) const {
    return renderFromCamera(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Normal3f RenderFromCamera(Normal3f n, Float time) const {
    return renderFromCamera(n, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Ray RenderFromCamera(const Ray &r) const { return renderFromCamera(r); }
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
RayDifferential RenderFromCamera(const RayDifferential &r) const {
    return renderFromCamera(r);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Vector3f CameraFromRender(Vector3f v, Float time) const {
    return renderFromCamera.ApplyInverse(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Normal3f CameraFromRender(Normal3f v, Float time) const {
    return renderFromCamera.ApplyInverse(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
const AnimatedTransform &RenderFromCamera() const { return renderFromCamera; }
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
const Transform &WorldFromRender() const { return worldFromRender; }
```
]

#block(breakable: false)[
```cpp
std::string ToString() const;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-203")[`fragbit-203`]]
#block(breakable: false)[
```cpp
void InitMetadata(ImageMetadata *metadata) const;
std::string ToString() const;
void Approximate_dp_dxy(Point3f p, Normal3f n, Float time,
        int samplesPerPixel, Vector3f *dpdx, Vector3f *dpdy) const {
                   Point3f pCamera = CameraFromRender(p, time);
    Transform DownZFromCamera =
        RotateFromTo(Normalize(Vector3f(pCamera)), Vector3f(0, 0, 1));
    Point3f pDownZ = DownZFromCamera(pCamera);
    Normal3f nDownZ = DownZFromCamera(CameraFromRender(n, time));
    Float d = nDownZ.z * pDownZ.z;
    Ray xRay(Point3f(0,0,0) + minPosDifferentialX,
             Vector3f(0,0,1) + minDirDifferentialX);
    Float tx = -(Dot(nDownZ, Vector3f(xRay.o)) - d) / Dot(nDownZ, xRay.d);
    Ray yRay(Point3f(0,0,0) + minPosDifferentialY,
             Vector3f(0,0,1) + minDirDifferentialY);
    Float ty = -(Dot(nDownZ, Vector3f(yRay.o)) - d) / Dot(nDownZ, yRay.d);
    Point3f px = xRay(tx), py = yRay(ty);
    Float sppScale = GetOptions().disablePixelJitter ? 1 :
        std::max<Float>(.125, 1 / std::sqrt((Float)samplesPerPixel));
    *dpdx = sppScale *
        RenderFromCamera(DownZFromCamera.ApplyInverse(px - pDownZ), time);
    *dpdy = sppScale *
        RenderFromCamera(DownZFromCamera.ApplyInverse(py - pDownZ), time);
}
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-207")[`fragbit-207`]]
#block(breakable: false)[
```cpp
Vector3f minPosDifferentialX, minPosDifferentialY;
Vector3f minDirDifferentialX, minDirDifferentialY;
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-208")[`fragbit-208`]]
#block(breakable: false)[
```cpp
PBRT_CPU_GPU
static pstd::optional<CameraRayDifferential> GenerateRayDifferential(
    Camera camera, CameraSample sample, SampledWavelengths &lambda);
```
]

#block(breakable: false)[
```cpp
RayDifferential RenderFromCamera(const RayDifferential &r) const {
    return cameraTransform.RenderFromCamera(r);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Vector3f RenderFromCamera(Vector3f v, Float time) const {
    return cameraTransform.RenderFromCamera(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Normal3f RenderFromCamera(Normal3f v, Float time) const {
    return cameraTransform.RenderFromCamera(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Point3f RenderFromCamera(Point3f p, Float time) const {
    return cameraTransform.RenderFromCamera(p, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Vector3f CameraFromRender(Vector3f v, Float time) const {
    return cameraTransform.CameraFromRender(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Normal3f CameraFromRender(Normal3f v, Float time) const {
    return cameraTransform.CameraFromRender(v, time);
}
```
]

#block(breakable: false)[
```cpp
PBRT_CPU_GPU
Point3f CameraFromRender(Point3f p, Float time) const {
    return cameraTransform.CameraFromRender(p, time);
}
void FindMinimumDifferentials(Camera camera);
```
]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Camera_Interface.html#fragbit-212")[`fragbit-212`]]
#block(breakable: false)[
```cpp
pstd::optional<CameraRay> ry;
for (Float eps : {.05f, -.05f}) {
    CameraSample sshift = sample;
    sshift.pFilm.y += eps;
    if (ry = camera.GenerateRay(sshift, lambda); ry) {
        rd.ryOrigin = rd.o + (ry->ray.o - rd.o) / eps;
        rd.ryDirection = rd.d + (ry->ray.d - rd.d) / eps;
        break;
    }
}
```
]
