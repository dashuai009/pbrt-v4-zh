#import "../../template.typ": ez_caption

// Fixed upstream f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c, Transformations.html#fragbit-109 including nested panels111–114.
#block(sticky: true)[#strong[#ez_caption[Additional Transform methods and declarations][Transform 的额外方法及声明]]]
```cpp
PBRT_CPU_GPU
inline Ray ApplyInverse(const Ray &r, Float *tMax = nullptr) const;
PBRT_CPU_GPU
inline RayDifferential ApplyInverse(const RayDifferential &r,
                                    Float *tMax = nullptr) const;
template <typename T>
PBRT_CPU_GPU inline Vector3<T> ApplyInverse(Vector3<T> v) const;
template <typename T>
PBRT_CPU_GPU inline Normal3<T> ApplyInverse(Normal3<T> ) const;

std::string ToString() const;

template <typename T>
PBRT_CPU_GPU Point3<T> operator()(Point3<T> p) const;
template <typename T>
Point3<T> ApplyInverse(Point3<T> p) const;
template <typename T>
PBRT_CPU_GPU Vector3<T> operator()(Vector3<T> v) const;
template <typename T>
PBRT_CPU_GPU Normal3<T> operator()(Normal3<T> ) const;
PBRT_CPU_GPU
Ray operator()(const Ray &r, Float *tMax = nullptr) const;
PBRT_CPU_GPU
RayDifferential operator()(const RayDifferential &r, Float *tMax = nullptr) const;
PBRT_CPU_GPU
Bounds3f operator()(const Bounds3f &b) const;
PBRT_CPU_GPU
Transform operator*(const Transform &t2) const;
PBRT_CPU_GPU
bool SwapsHandedness() const;
explicit Transform(const Frame &frame);
explicit Transform(Quaternion q);
explicit operator Quaternion() const;
void Decompose(Vector3f *T, SquareMatrix<4> *R, SquareMatrix<4> *S) const;
PBRT_CPU_GPU
Interaction operator()(const Interaction &in) const;
PBRT_CPU_GPU
Interaction ApplyInverse(const Interaction &in) const;
PBRT_CPU_GPU
SurfaceInteraction operator()(const SurfaceInteraction &si) const;
PBRT_CPU_GPU
SurfaceInteraction ApplyInverse(const SurfaceInteraction &in) const;
Point3fi operator()(const Point3fi &p) const {
    Float x = Float(p.x), y = Float(p.y), z = Float(p.z);
    Float xp = (m[0][0] * x + m[0][1] * y) + (m[0][2] * z + m[0][3]);
    Float yp = (m[1][0] * x + m[1][1] * y) + (m[1][2] * z + m[1][3]);
    Float zp = (m[2][0] * x + m[2][1] * y) + (m[2][2] * z + m[2][3]);
    Float wp = (m[3][0] * x + m[3][1] * y) + (m[3][2] * z + m[3][3]);
    Vector3f pError;
    if (p.IsExact()) {
        pError.x = gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
            std::abs(m[0][2] * z) + std::abs(m[0][3]));
        pError.y = gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
            std::abs(m[1][2] * z) + std::abs(m[1][3]));
        pError.z = gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
            std::abs(m[2][2] * z) + std::abs(m[2][3]));
    } else {
        Vector3f pInError = p.Error();
        pError.x = (gamma(3) + 1) * (std::abs(m[0][0]) * pInError.x +
            std::abs(m[0][1]) * pInError.y +
            std::abs(m[0][2]) * pInError.z) +
            gamma(3) * (std::abs(m[0][0] * x) + std::abs(m[0][1] * y) +
            std::abs(m[0][2] * z) + std::abs(m[0][3]));
        pError.y = (gamma(3) + 1) * (std::abs(m[1][0]) * pInError.x +
            std::abs(m[1][1]) * pInError.y +
            std::abs(m[1][2]) * pInError.z) +
            gamma(3) * (std::abs(m[1][0] * x) + std::abs(m[1][1] * y) +
            std::abs(m[1][2] * z) + std::abs(m[1][3]));
        pError.z = (gamma(3) + 1) * (std::abs(m[2][0]) * pInError.x +
            std::abs(m[2][1]) * pInError.y +
            std::abs(m[2][2]) * pInError.z) +
            gamma(3) * (std::abs(m[2][0] * x) + std::abs(m[2][1] * y) +
            std::abs(m[2][2] * z) + std::abs(m[2][3]));
    }
    if (wp == 1)
        return Point3fi(Point3f(xp, yp, zp), pError);
    else
        return Point3fi(Point3f(xp, yp, zp), pError) / wp;
}
Vector3fi operator()(const Vector3fi &v) const;
PBRT_CPU_GPU
Point3fi ApplyInverse(const Point3fi &p) const;
```

// Original fragbit-118.
#block(sticky: true)[#strong[#ez_caption[Rotation of the second and third basis vectors][第二、第三个基向量的旋转]]]
```cpp
m[1][0] = a.x * a.y * (1 - cosTheta) + a.z * sinTheta;
m[1][1] = a.y * a.y + (1 - a.y * a.y) * cosTheta;
m[1][2] = a.y * a.z * (1 - cosTheta) - a.x * sinTheta;
m[1][3] = 0;

m[2][0] = a.x * a.z * (1 - cosTheta) - a.y * sinTheta;
m[2][1] = a.y * a.z * (1 - cosTheta) + a.x * sinTheta;
m[2][2] = a.z * a.z + (1 - a.z * a.z) * cosTheta;
m[2][3] = 0;
```
