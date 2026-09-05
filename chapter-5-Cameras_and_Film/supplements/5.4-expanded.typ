#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original collapsed panels][原网页折叠面板中的补充代码]]

#parec[These are additional member fragments and implementations from the original page. Repeated visible fragments are referenced in the main text.][以下是原网页折叠面板中的额外成员片段及实现；与正文重复的可见片段仍以正文为准。]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-278")[`fragbit-278`]]
```cpp
static PixelSensor *Create(const ParameterDictionary &parameters, const RGBColorSpace *colorSpace,
                           Float exposureTime, const FileLoc *loc, Allocator alloc);
static PixelSensor *CreateDefault(Allocator alloc = {});
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-281")[`fragbit-281`]]
```cpp
Float xyzOutput[24][3];
Float sensorWhiteG = InnerProduct(sensorIllum, &g_bar);
Float sensorWhiteY = InnerProduct(sensorIllum, &Spectra::Y());
for (size_t i = 0; i < nSwatchReflectances; ++i) {
    Spectrum s = swatchReflectances[i];
    XYZ xyz = ProjectReflectance<XYZ>(s, &outputColorSpace->illuminant, &Spectra::X(),
                                      &Spectra::Y(), &Spectra::Z()) *
              (sensorWhiteY / sensorWhiteG);
    for (int c = 0; c < 3; ++c)
        xyzOutput[i][c] = xyz[c];
}
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-298")[`fragbit-298`]]
```cpp
using TaggedPointer::TaggedPointer;

static Film Create(const std::string &name,
                         const ParameterDictionary &parameters, Float exposureTime,
                         const CameraTransform &cameraTransform, Filter filter, const FileLoc *loc, Allocator alloc);

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-299")[`fragbit-299`]]
```cpp
VisibleSurface() = default;

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-301")[`fragbit-301`]]
```cpp
Bounds2f SampleBounds() const;
std::string BaseToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-303")[`fragbit-303`]]
```cpp
RGBFilm(FilmBaseParameters p, const RGBColorSpace *colorSpace, Float maxComponentValue = Infinity,
        bool writeFP16 = true, Allocator alloc = {});

static RGBFilm *Create(const ParameterDictionary &parameters, Float exposureTime, Filter filter,
                       const RGBColorSpace *colorSpace, const FileLoc *loc,
                       Allocator alloc);

PBRT_CPU_GPU
void AddSplat(Point2f p, SampledSpectrum v, const SampledWavelengths &lambda);

void WriteImage(ImageMetadata metadata, Float splatScale = 1);
Image GetImage(ImageMetadata *metadata, Float splatScale = 1);

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-323")[`fragbit-323`]]
```cpp
GBufferFilm(FilmBaseParameters p, const AnimatedTransform &outputFromRender,
                               bool applyInverse, const RGBColorSpace *colorSpace,
            Float maxComponentValue = Infinity, bool writeFP16 = true,
            Allocator alloc = {});

static GBufferFilm *Create(const ParameterDictionary &parameters, Float
                           exposureTime, const CameraTransform &cameraTransform, Filter filter,
                           const RGBColorSpace *colorSpace, const FileLoc *loc,
                           Allocator alloc);

PBRT_CPU_GPU
void AddSample(Point2i pFilm, SampledSpectrum L,
               const SampledWavelengths &lambda,
               const VisibleSurface *visibleSurface, Float weight);

PBRT_CPU_GPU
void AddSplat(Point2f p, SampledSpectrum v, const SampledWavelengths &lambda);

PBRT_CPU_GPU
RGB ToOutputRGB(SampledSpectrum L, const SampledWavelengths &lambda) const {
    RGB cameraRGB = sensor->ToSensorRGB(L, lambda);
    return outputRGBFromSensorRGB * cameraRGB;
}

PBRT_CPU_GPU
bool UsesVisibleSurface() const { return true; }

PBRT_CPU_GPU
RGB GetPixelRGB(Point2i p, Float splatScale = 1) const {
    const Pixel &pixel = pixels[p];
    RGB rgb(pixel.rgbSum[0], pixel.rgbSum[1], pixel.rgbSum[2]);

    // Normalize pixel with weight sum
    Float weightSum = pixel.weightSum;
    if (weightSum != 0)
        rgb /= weightSum;

    // Add splat value at pixel
    for (int c = 0; c < 3; ++c)
        rgb[c] += splatScale * pixel.rgbSplat[c] / filterIntegral;

    rgb = outputRGBFromSensorRGB * rgb;

    return rgb;
}

void WriteImage(ImageMetadata metadata, Float splatScale = 1);
Image GetImage(ImageMetadata *metadata, Float splatScale = 1);

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Cameras_and_Film/Film_and_Imaging.html#fragbit-325")[`fragbit-325`]]
```cpp
AnimatedTransform outputFromRender;
bool applyInverse;
Array2D<Pixel> pixels;
const RGBColorSpace *colorSpace;
Float maxComponentValue;
bool writeFP16;
Float filterIntegral;
SquareMatrix<3> outputRGBFromSensorRGB;
```
