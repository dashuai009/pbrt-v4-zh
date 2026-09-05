#import "../../template.typ": parec, ez_caption

#heading(level: 3, numbering: none)[#ez_caption[Additional code from the original page’s collapsed panels][原网页折叠内容中的补充代码]]

#parec[The following code is present in the fixed original page’s collapsed panels but is not repeated in its visible fragments. These are member fragments, not standalone class definitions.][以下代码来自固定原网页的折叠面板，正文可见片段中未重复列出。这些内容是成员片段，并非独立的完整类定义。]

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-167")[`fragbit-167`]]
```cpp
Float Average() const { return (X + Y + Z) / 3; }

PBRT_CPU_GPU
XYZ &operator+=(const XYZ &s) {
    X += s.X;
    Y += s.Y;
    Z += s.Z;
    return *this;
}
PBRT_CPU_GPU
XYZ operator+(const XYZ &s) const {
    XYZ ret = *this;
    return ret += s;
}

PBRT_CPU_GPU
XYZ &operator-=(const XYZ &s) {
    X -= s.X;
    Y -= s.Y;
    Z -= s.Z;
    return *this;
}
PBRT_CPU_GPU
XYZ operator-(const XYZ &s) const {
    XYZ ret = *this;
    return ret -= s;
}
PBRT_CPU_GPU
friend XYZ operator-(Float a, const XYZ &s) { return {a - s.X, a - s.Y, a - s.Z}; }

PBRT_CPU_GPU
XYZ &operator*=(const XYZ &s) {
    X *= s.X;
    Y *= s.Y;
    Z *= s.Z;
    return *this;
}
PBRT_CPU_GPU
XYZ operator*(const XYZ &s) const {
    XYZ ret = *this;
    return ret *= s;
}
PBRT_CPU_GPU
XYZ operator*(Float a) const {
    DCHECK(!IsNaN(a));
    return {a * X, a * Y, a * Z};
}
PBRT_CPU_GPU
XYZ &operator*=(Float a) {
    DCHECK(!IsNaN(a));
    X *= a;
    Y *= a;
    Z *= a;
    return *this;
}

PBRT_CPU_GPU
XYZ &operator/=(const XYZ &s) {
    X /= s.X;
    Y /= s.Y;
    Z /= s.Z;
    return *this;
}
PBRT_CPU_GPU
XYZ operator/(const XYZ &s) const {
    XYZ ret = *this;
    return ret /= s;
}
PBRT_CPU_GPU
XYZ &operator/=(Float a) {
    DCHECK(!IsNaN(a));
    DCHECK_NE(a, 0);
    X /= a;
    Y /= a;
    Z /= a;
    return *this;
}
PBRT_CPU_GPU
XYZ operator/(Float a) const {
    XYZ ret = *this;
    return ret /= a;
}

PBRT_CPU_GPU
XYZ operator-() const { return {-X, -Y, -Z}; }

PBRT_CPU_GPU
bool operator==(const XYZ &s) const { return X == s.X && Y == s.Y && Z == s.Z; }
PBRT_CPU_GPU
bool operator!=(const XYZ &s) const { return X != s.X || Y != s.Y || Z != s.Z; }
PBRT_CPU_GPU
Float operator[](int c) const {
    DCHECK(c >= 0 && c < 3);
    if (c == 0)
        return X;
    else if (c == 1)
        return Y;
    return Z;
}
PBRT_CPU_GPU
Float &operator[](int c) {
    DCHECK(c >= 0 && c < 3);
    if (c == 0)
        return X;
    else if (c == 1)
        return Y;
    return Z;
}

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-171")[`fragbit-171`]]
```cpp
PBRT_CPU_GPU
RGB &operator+=(RGB s) {
    r += s.r;
    g += s.g;
    b += s.b;
    return *this;
}
PBRT_CPU_GPU
RGB operator+(RGB s) const {
    RGB ret = *this;
    return ret += s;
}

PBRT_CPU_GPU
RGB &operator-=(RGB s) {
    r -= s.r;
    g -= s.g;
    b -= s.b;
    return *this;
}
PBRT_CPU_GPU
RGB operator-(RGB s) const {
    RGB ret = *this;
    return ret -= s;
}
PBRT_CPU_GPU
friend RGB operator-(Float a, RGB s) { return {a - s.r, a - s.g, a - s.b}; }

PBRT_CPU_GPU
RGB &operator*=(RGB s) {
    r *= s.r;
    g *= s.g;
    b *= s.b;
    return *this;
}
PBRT_CPU_GPU
RGB operator*(RGB s) const {
    RGB ret = *this;
    return ret *= s;
}
PBRT_CPU_GPU
RGB operator*(Float a) const {
    DCHECK(!IsNaN(a));
    return {a * r, a * g, a * b};
}
PBRT_CPU_GPU
RGB &operator*=(Float a) {
    DCHECK(!IsNaN(a));
    r *= a;
    g *= a;
    b *= a;
    return *this;
}
PBRT_CPU_GPU
friend RGB operator*(Float a, RGB s) { return s * a; }

PBRT_CPU_GPU
RGB &operator/=(RGB s) {
    r /= s.r;
    g /= s.g;
    b /= s.b;
    return *this;
}
PBRT_CPU_GPU
RGB operator/(RGB s) const {
    RGB ret = *this;
    return ret /= s;
}
PBRT_CPU_GPU
RGB &operator/=(Float a) {
    DCHECK(!IsNaN(a));
    DCHECK_NE(a, 0);
    r /= a;
    g /= a;
    b /= a;
    return *this;
}
PBRT_CPU_GPU
RGB operator/(Float a) const {
    RGB ret = *this;
    return ret /= a;
}

PBRT_CPU_GPU
RGB operator-() const { return {-r, -g, -b}; }

PBRT_CPU_GPU
Float Average() const { return (r + g + b) / 3; }

PBRT_CPU_GPU
bool operator==(RGB s) const { return r == s.r && g == s.g && b == s.b; }
PBRT_CPU_GPU
bool operator!=(RGB s) const { return r != s.r || g != s.g || b != s.b; }
PBRT_CPU_GPU
Float operator[](int c) const {
    DCHECK(c >= 0 && c < 3);
    if (c == 0)
        return r;
    else if (c == 1)
        return g;
    return b;
}
PBRT_CPU_GPU
Float &operator[](int c) {
    DCHECK(c >= 0 && c < 3);
    if (c == 0)
        return r;
    else if (c == 1)
        return g;
    return b;
}

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-173")[`fragbit-173`]]
```cpp
RGBColorSpace(Point2f r, Point2f g, Point2f b, Spectrum illuminant,
              const RGBToSpectrumTable *rgbToSpectrumTable, Allocator alloc);

PBRT_CPU_GPU
RGBSigmoidPolynomial ToRGBCoeffs(RGB rgb) const;

static void Init(Allocator alloc);

PBRT_CPU_GPU
bool operator==(const RGBColorSpace &cs) const {
    return (r == cs.r && g == cs.g && b == cs.b && w == cs.w &&
            rgbToSpectrumTable == cs.rgbToSpectrumTable);
}
PBRT_CPU_GPU
bool operator!=(const RGBColorSpace &cs) const {
    return (r != cs.r || g != cs.g || b != cs.b || w != cs.w ||
            rgbToSpectrumTable != cs.rgbToSpectrumTable);
}

std::string ToString() const;
RGB LuminanceVector() const {
    return RGB(XYZFromRGB[1][0], XYZFromRGB[1][1], XYZFromRGB[1][2]);
}
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-182")[`fragbit-182`]]
```cpp
RGBToSpectrumTable(const float *zNodes, const CoefficientArray *coeffs)
    : zNodes(zNodes), coeffs(coeffs) { }
PBRT_CPU_GPU
RGBSigmoidPolynomial operator()(RGB rgb) const;

static void Init(Allocator alloc);

static const RGBToSpectrumTable *sRGB;
static const RGBToSpectrumTable *DCI_P3;
static const RGBToSpectrumTable *Rec2020;
static const RGBToSpectrumTable *ACES2065_1;

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-190")[`fragbit-190`]]
```cpp
PBRT_CPU_GPU
RGBAlbedoSpectrum(const RGBColorSpace &cs, RGB rgb);

PBRT_CPU_GPU
SampledSpectrum Sample(const SampledWavelengths &lambda) const {
    SampledSpectrum s;
    for (int i = 0; i < NSpectrumSamples; ++i)
        s[i] = rsp(lambda[i]);
    return s;
}

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-192")[`fragbit-192`]]
```cpp
PBRT_CPU_GPU
RGBUnboundedSpectrum(const RGBColorSpace &cs, RGB rgb);

PBRT_CPU_GPU
RGBUnboundedSpectrum()
    : rsp(0, 0, 0), scale(0) {}

PBRT_CPU_GPU
SampledSpectrum Sample(const SampledWavelengths &lambda) const {
    SampledSpectrum s;
    for (int i = 0; i < NSpectrumSamples; ++i)
        s[i] = scale * rsp(lambda[i]);
    return s;
}

std::string ToString() const;
```

#block(sticky: true)[#link("https://pbr-book.org/4ed/Radiometry,_Spectra,_and_Color/Color.html#fragbit-194")[`fragbit-194`]]
```cpp
RGBIlluminantSpectrum() = default;
RGBIlluminantSpectrum(const RGBColorSpace &cs, RGB rgb);

Float MaxValue() const {
    if (!illuminant) return 0;
    return scale * rsp.MaxValue() * illuminant->MaxValue();
}
const DenselySampledSpectrum *Illuminant() const {
    return illuminant;
}
PBRT_CPU_GPU
SampledSpectrum Sample(const SampledWavelengths &lambda) const {
    if (!illuminant) return SampledSpectrum(0);
    SampledSpectrum s;
    for (int i = 0; i < NSpectrumSamples; ++i)
        s[i] = scale * rsp(lambda[i]);
    return s * illuminant->Sample(lambda);
}

std::string ToString() const;
```
