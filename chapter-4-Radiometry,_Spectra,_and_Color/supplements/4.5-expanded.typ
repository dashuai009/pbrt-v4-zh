#import "../../template.typ": ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-144.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 144)][额外代码（原文面板 144）]]]
```cpp
using TaggedPointer::TaggedPointer;
std::string ToString() const;
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-145.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 145)][额外代码（原文面板 145）]]]
```cpp
DenselySampledSpectrum(int lambda_min = Lambda_min, int lambda_max = Lambda_max,
                       Allocator alloc = {})
    : lambda_min(lambda_min),
      lambda_max(lambda_max),
      values(lambda_max - lambda_min + 1, alloc) {}
DenselySampledSpectrum(Spectrum s, Allocator alloc)
    : DenselySampledSpectrum(s, Lambda_min, Lambda_max, alloc) {}
DenselySampledSpectrum(const DenselySampledSpectrum &s, Allocator alloc)
    : lambda_min(s.lambda_min),
      lambda_max(s.lambda_max),
      values(s.values.begin(), s.values.end(), alloc) {}

PBRT_CPU_GPU
SampledSpectrum Sample(const SampledWavelengths &lambda) const {
    SampledSpectrum s;
    for (int i = 0; i < NSpectrumSamples; ++i) {
        int offset = std::lround(lambda[i]) - lambda_min;
        if (offset < 0 || offset >= values.size())
            s[i] = 0;
        else
            s[i] = values[offset];
    }
    return s;
}

PBRT_CPU_GPU
void Scale(Float s) {
    for (Float &v : values)
        v *= s;
}

PBRT_CPU_GPU
Float MaxValue() const { return *std::max_element(values.begin(), values.end()); }

std::string ToString() const;

template <typename F>
static DenselySampledSpectrum SampleFunction(
        F func, int lambda_min = Lambda_min, int lambda_max = Lambda_max,
        Allocator alloc = {}) {
    DenselySampledSpectrum s(lambda_min, lambda_max, alloc);
    for (int lambda = lambda_min; lambda <= lambda_max; ++lambda)
        s.values[lambda - lambda_min] = func(lambda);
    return s;
}

PBRT_CPU_GPU
bool operator==(const DenselySampledSpectrum &d) const {
    if (lambda_min != d.lambda_min || lambda_max != d.lambda_max ||
        values.size() != d.values.size())
        return false;
    for (size_t i = 0; i < values.size(); ++i)
        if (values[i] != d.values[i])
            return false;
    return true;
}
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-147.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 147)][额外代码（原文面板 147）]]]
```cpp
PiecewiseLinearSpectrum() = default;

PBRT_CPU_GPU
void Scale(Float s) {
    for (Float &v : values)
        v *= s;
}

PBRT_CPU_GPU
Float MaxValue() const;

PBRT_CPU_GPU
SampledSpectrum Sample(const SampledWavelengths &lambda) const {
    SampledSpectrum s;
    for (int i = 0; i < NSpectrumSamples; ++i)
        s[i] = (*this)(lambda[i]);
    return s;
}
PBRT_CPU_GPU
Float operator()(Float lambda) const;

std::string ToString() const;

static pstd::optional<Spectrum> Read(const std::string &filename,
                                           Allocator alloc);
static PiecewiseLinearSpectrum *FromInterleaved(pstd::span<const Float> samples,
                                                bool normalize, Allocator alloc);
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-151.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 151)][额外代码（原文面板 151）]]]
```cpp
PBRT_CPU_GPU
SampledSpectrum Sample(const SampledWavelengths &lambda) const {
    SampledSpectrum s;
    for (int i = 0; i < NSpectrumSamples; ++i)
        s[i] = Blackbody(lambda[i], T) * normalizationFactor;
    return s;
}

PBRT_CPU_GPU
Float MaxValue() const { return 1.f; }

std::string ToString() const;
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-155.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 155)][额外代码（原文面板 155）]]]
```cpp
PBRT_CPU_GPU
SampledSpectrum operator+(const SampledSpectrum &s) const {
    SampledSpectrum ret = *this;
    return ret += s;
}

PBRT_CPU_GPU
SampledSpectrum &operator-=(const SampledSpectrum &s) {
    for (int i = 0; i < NSpectrumSamples; ++i)
        values[i] -= s.values[i];
    return *this;
}
PBRT_CPU_GPU
SampledSpectrum operator-(const SampledSpectrum &s) const {
    SampledSpectrum ret = *this;
    return ret -= s;
}
PBRT_CPU_GPU
friend SampledSpectrum operator-(Float a, const SampledSpectrum &s) {
    DCHECK(!IsNaN(a));
    SampledSpectrum ret;
    for (int i = 0; i < NSpectrumSamples; ++i)
        ret.values[i] = a - s.values[i];
    return ret;
}

PBRT_CPU_GPU
SampledSpectrum &operator*=(const SampledSpectrum &s) {
    for (int i = 0; i < NSpectrumSamples; ++i)
        values[i] *= s.values[i];
    return *this;
}
PBRT_CPU_GPU
SampledSpectrum operator*(const SampledSpectrum &s) const {
    SampledSpectrum ret = *this;
    return ret *= s;
}
PBRT_CPU_GPU
SampledSpectrum operator*(Float a) const {
    DCHECK(!IsNaN(a));
    SampledSpectrum ret = *this;
    for (int i = 0; i < NSpectrumSamples; ++i)
        ret.values[i] *= a;
    return ret;
}
PBRT_CPU_GPU
SampledSpectrum &operator*=(Float a) {
    DCHECK(!IsNaN(a));
    for (int i = 0; i < NSpectrumSamples; ++i)
        values[i] *= a;
    return *this;
}
PBRT_CPU_GPU
friend SampledSpectrum operator*(Float a, const SampledSpectrum &s) { return s * a; }

PBRT_CPU_GPU
SampledSpectrum &operator/=(const SampledSpectrum &s) {
    for (int i = 0; i < NSpectrumSamples; ++i) {
        DCHECK_NE(0, s.values[i]);
        values[i] /= s.values[i];
    }
    return *this;
}
PBRT_CPU_GPU
SampledSpectrum operator/(const SampledSpectrum &s) const {
    SampledSpectrum ret = *this;
    return ret /= s;
}
PBRT_CPU_GPU
SampledSpectrum &operator/=(Float a) {
    DCHECK_NE(a, 0);
    DCHECK(!IsNaN(a));
    for (int i = 0; i < NSpectrumSamples; ++i)
        values[i] /= a;
    return *this;
}
PBRT_CPU_GPU
SampledSpectrum operator/(Float a) const {
    SampledSpectrum ret = *this;
    return ret /= a;
}

PBRT_CPU_GPU
SampledSpectrum operator-() const {
    SampledSpectrum ret;
    for (int i = 0; i < NSpectrumSamples; ++i)
        ret.values[i] = -values[i];
    return ret;
}
PBRT_CPU_GPU
bool operator==(const SampledSpectrum &s) const { return values == s.values; }
PBRT_CPU_GPU
bool operator!=(const SampledSpectrum &s) const { return values != s.values; }

std::string ToString() const;

PBRT_CPU_GPU
bool HasNaNs() const {
    for (int i = 0; i < NSpectrumSamples; ++i)
        if (IsNaN(values[i]))
            return true;
    return false;
}

PBRT_CPU_GPU
XYZ ToXYZ(const SampledWavelengths &lambda) const;
PBRT_CPU_GPU
RGB ToRGB(const SampledWavelengths &lambda, const RGBColorSpace &cs) const;
PBRT_CPU_GPU
Float y(const SampledWavelengths &lambda) const;

PBRT_CPU_GPU
Float MinComponentValue() const {
    Float m = values[0];
    for (int i = 1; i < NSpectrumSamples; ++i)
        m = std::min(m, values[i]);
    return m;
}
PBRT_CPU_GPU
Float MaxComponentValue() const {
    Float m = values[0];
    for (int i = 1; i < NSpectrumSamples; ++i)
        m = std::max(m, values[i]);
    return m;
}
PBRT_CPU_GPU
Float Average() const {
    Float sum = values[0];
    for (int i = 1; i < NSpectrumSamples; ++i)
        sum += values[i];
    return sum / NSpectrumSamples;
}
```

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-156.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 156)][额外代码（原文面板 156）]]]
```cpp
PBRT_CPU_GPU
bool operator==(const SampledWavelengths &swl) const {
    return lambda == swl.lambda && pdf == swl.pdf;
}
PBRT_CPU_GPU
bool operator!=(const SampledWavelengths &swl) const {
    return lambda != swl.lambda || pdf != swl.pdf;
}

std::string ToString() const;
```

// SampleVisible also appears verbatim in the pinned Film_and_Imaging.html#SampledWavelengths::SampleVisible; keep its full method only in section 5.4.
#ez_caption[
  The remaining `SampleVisible()` method in source panel 156 is presented in full in @film-and-imaging (see #link(<SampledWavelengths::SampleVisible>)[`SampledWavelengths::SampleVisible()`]).
][
  原文面板 156 中余下的 `SampleVisible()` 方法已在 @film-and-imaging 完整列出，见 #link(<SampledWavelengths::SampleVisible>)[`SampledWavelengths::SampleVisible()`]。
]

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c; Representing_Spectral_Distributions.html#fragbit-162.
#block(sticky: true)[#strong[#ez_caption[Additional code (source panel 162)][额外代码（原文面板 162）]]]
```cpp
friend struct SOA<SampledWavelengths>;
```
