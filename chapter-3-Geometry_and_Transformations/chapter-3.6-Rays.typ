#import "../template.typ": parec, ez_caption

== Rays
<rays>
#parec[
  A #emph[ray] $r$ is a semi-infinite line specified by its origin $o$ and direction $upright(bold(d))$ ; see @fig:rayexample. `pbrt` represents #link("<Ray>")[Ray];s using a #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] for the origin and a #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] for the direction; there is no need for non-`Float`-based rays in `pbrt`. See the files #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/ray.h")[`ray.h`] and #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/ray.cpp")[`ray.cpp`] in the `pbrt` source code distribution for the implementation of the `Ray` class.
][
  #emph[射线] $r$ 是由其起点 $o$ 和方向 $upright(bold(d))$ 指定的半无限直线；参见@fig:rayexample。 `pbrt` 使用 #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 表示射线的起点，使用 #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] 表示射线的方向；在 `pbrt` 中，射线不需要基于非 `Float` 类型的表示 。 有关 `Ray` 类的实现，请参见 `pbrt` 源代码分发中的文件 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/ray.h")[`ray.h`] 和 #link("https://github.com/mmp/pbrt-v4/tree/master/src/pbrt/ray.cpp")[`ray.cpp`];。
]

#figure(
  image("../pbr-book-website/4ed/Geometry_and_Transformations/pha03f08.svg"),
  caption: [
    #parec[
      A ray is a semi-infini te line defined by its origin $o$ and direction vector $upright(bold(d))$
    ][
      射线是由其起点$o$ 和其方向向量$upright(bold(d))$定义的半无限直线。
    ]
  ],
)<rayexample>

```cpp
class Ray {
  public:
    // <<Ray Public Methods>>
       PBRT_CPU_GPU
       bool HasNaN() const { return (o.HasNaN() || d.HasNaN()); }

       std::string ToString() const;
       Point3f operator()(Float t) const { return o + d * t; }
       Ray(Point3f o, Vector3f d, Float time = 0.f, Medium medium = nullptr)
           : o(o), d(d), time(time), medium(medium) {}
    // <<Ray Public Members>>
       Point3f o;
       Vector3f d;
       Float time = 0;
       Medium medium = nullptr;
};
```
#parec[
  Because we will be referring to these variables often throughout the code, the origin and direction members of a #link("<Ray>")[Ray] are succinctly named `o` and `d`. Note that we again make the data publicly available for convenience.
][
  因为我们将在代码中频繁引用这些变量，所以 #link("<Ray>")[Ray] 的起点和方向成员被简洁地命名为 `o` 和 `d`。注意，为了方便，我们把这些数据设置为public。
]

```cpp
// <<Ray Public Members>>=
Point3f o;
Vector3f d;
```
#parec[
  The #emph[parametric form] of a ray expresses it as a function of a scalar value ( t ), giving the set of points that the ray passes through:
][
  射线的#emph[参数形式];将其表示为标量值 ( t ) 的函数，给出射线经过的一组点：
]

$ upright(bold(r))(t) = upright(bold(o)) + t upright(bold(d)), quad 0 lt.eq t < infinity . $
<ray>

#parec[
  The `Ray` class overloads the function application operator for rays in order to match the $r(t)$ notation in @eqt:ray .
][
  `Ray` 类重载了射线的函数调用运算符，以匹配@eqt:ray 中的 $r(t)$ 符号。
]

```cpp
// <<Ray Public Methods>>=
Point3f operator()(Float t) const { return o + d * t; }
```

#parec[
  Given this method, when we need to find the point at a particular position along a ray, we can write code like:
][
  通过这个方法，当我们需要找到射线在某个位置的点时，可以编写如下代码：
]

```cpp
    Ray r(Point3f(0, 0, 0), Vector3f(1, 2, 3));
    Point3f p = r(1.7);
```


#parec[
  Each ray also has a time value associated with it. In scenes with animated objects, the rendering system constructs a representation of the scene at the appropriate time for each ray.
][
  每条射线也有一个与之关联的时间值。在有动画对象的场景中，渲染系统为每条射线构建场景在适当时间的表示。
]


```cpp
// <<Ray Public Members>>+=
Float time = 0;
```

#parec[
  Each ray also records the medium at its origin. The #link("../Volume_Scattering/Media.html#Medium")[`Medium`] class, which will be introduced in @media , encapsulates the (potentially spatially varying) properties of participating media such as a foggy atmosphere, smoke, or scattering liquids like milk. Associating this information with rays makes it possible for other parts of the system to account correctly for the effect of rays passing from one medium to another.
][
  每条射线还记录其起点的介质。#link("../Volume_Scattering/Media.html#Medium")[`Medium`] 类将在@media 中介绍，它封装了参与介质的（可能是空间变化的）属性，如雾气、烟雾或散射液体如牛奶。将此信息与射线关联，使系统的其他部分能够正确考虑射线从一种介质到另一种介质的影响。
]

```cpp
// <<Ray Public Members>>+=
Medium medium = nullptr;
```
#parec[
  Constructing #link("<Ray>")[Ray];s is straightforward. The default constructor relies on the #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] and #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] constructors to set the origin and direction to $(0, 0, 0)$. Alternately, a particular point and direction can be provided. If an origin and direction are provided, the constructor allows values to be given for the ray's time and medium.
][
  构造 #link("<Ray>")[Ray] 很简单。默认构造函数依赖于 #link("../Geometry_and_Transformations/Points.html#Point3f")[`Point3f`] 和 #link("../Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] 构造函数将起点和方向设置为 $(0, 0, 0)$。或者，可以提供特定的点和方向。如果提供了起点和方向，构造函数允许为射线的时间和介质提供值。
]


```cpp
Ray(Point3f o, Vector3f d, Float time = 0.f, Medium medium = nullptr)
    : o(o), d(d), time(time), medium(medium) {}
```


=== Ray Differentials
<ray-differentials>

#parec[
  To be able to perform better antialiasing with the texture functions defined in @textures-and-materials , `pbrt` makes use of the #link("<RayDifferential>")[RayDifferential] class, which is a subclass of #link("<Ray>")[Ray] that contains additional information about two auxiliary rays. These extra rays represent camera rays offset by one sample in the $x$ and $y$ direction from the main ray on the film plane. By determining the area that these three rays project to on an object being shaded, a #link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[`Texture`] can estimate an area to average over for proper antialiasing (Section~#link("../Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#sec:texture-anti-aliasing")[10.1];).
][
  为了能够更好地使用@textures-and-materials 中定义的纹理函数进行抗锯齿，`pbrt` 使用了 #link("<RayDifferential>")[RayDifferential] 类，它是 #link("<Ray>")[Ray] 的子类，包含有关两个辅助射线的附加信息。这些额外的射线表示从胶片平面上的主射线偏移一个样本的相机射线，分别在 $x$ 和 $y$ 方向。通过确定这三条射线在被着色对象上投影的区域，#link("../Textures_and_Materials/Texture_Interface_and_Basic_Textures.html#Texture")[`Texture`] 可以估计一个区域进行平均，以实现正确的抗锯齿（第 #link("../Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#sec:texture-anti-aliasing")[10.1] 节）。
]

#parec[
  Because #link("<RayDifferential>")[RayDifferential] inherits from #link("<Ray>")[Ray];, geometric interfaces in the system can be written to take `const Ray &` parameters, so that either a `Ray` or `RayDifferential` can be passed to them. Only the routines that need to account for antialiasing and texturing require `RayDifferential` parameters.
][
  因为 #link("<RayDifferential>")[RayDifferential] 继承自 #link("<Ray>")[Ray];，所以系统中的几何接口可以编写为接受 `const Ray &` 参数，以便可以将 `Ray` 或 `RayDifferential` 传递给它们。只有需要考虑抗锯齿和纹理的例程才需要 `RayDifferential` 参数。
]

```cpp
class RayDifferential : public Ray {
  public:
    <<RayDifferential Public Methods>>       RayDifferential(Point3f o, Vector3f d, Float time = 0.f,
                       Medium medium = nullptr)
           : Ray(o, d, time, medium) {}
       explicit RayDifferential(const Ray &ray) : Ray(ray) {}
       void ScaleDifferentials(Float s) {
           rxOrigin = o + (rxOrigin - o) * s;
           ryOrigin = o + (ryOrigin - o) * s;
           rxDirection = d + (rxDirection - d) * s;
           ryDirection = d + (ryDirection - d) * s;
       }
       PBRT_CPU_GPU
       bool HasNaN() const {
           return Ray::HasNaN() ||
                  (hasDifferentials && (rxOrigin.HasNaN() || ryOrigin.HasNaN() ||
                                        rxDirection.HasNaN() || ryDirection.HasNaN()));
       }
       std::string ToString() const;
    <<RayDifferential Public Members>>       bool hasDifferentials = false;
       Point3f rxOrigin, ryOrigin;
       Vector3f rxDirection, ryDirection;
};
```
#parec[
  The `RayDifferential` constructor mirrors the `Ray`'s.
][
  `RayDifferential` 构造函数与 `Ray` 的构造函数相似。
]

```cpp
// <<RayDifferential Public Methods>>=
RayDifferential(Point3f o, Vector3f d, Float time = 0.f,
                Medium medium = nullptr)
    : Ray(o, d, time, medium) {}
```
#parec[
  In some cases, differential rays may not be available. Routines that take #link("<RayDifferential>")[RayDifferential] parameters should check the `hasDifferentials` member variable before accessing the differential rays' origins or directions.
][
  在某些情况下，可能无法获得差分射线。接受 #link("<RayDifferential>")[RayDifferential] 参数的例程应在访问差分射线的起点或方向之前检查 `hasDifferentials` 成员变量。
]

```cpp
// <<RayDifferential Public Members>>=
bool hasDifferentials = false;
Point3f rxOrigin, ryOrigin;
Vector3f rxDirection, ryDirection;
```


#parec[
  There is also a constructor to create a #link("<RayDifferential>")[RayDifferential] from a #link("<Ray>")[Ray];. As with the previous constructor, the default `false` value of the `hasDifferentials` member variable is left as is.
][
  还有一个构造函数可以从 #link("<Ray>")[Ray] 创建 #link("<RayDifferential>")[RayDifferential];。与前一个构造函数一样，`hasDifferentials` 成员变量的默认 `false` 值保持不变。
]

```cpp
// <<RayDifferential Public Methods>>+=
explicit RayDifferential(const Ray &ray) : Ray(ray) {}
```

#parec[
  `Camera` implementations in `pbrt` compute differentials for rays leaving the camera under the assumption that camera rays are spaced one pixel apart. Integrators usually generate multiple camera rays per pixel, in which case the actual distance between samples is lower and the differentials should be updated accordingly; if this factor is not accounted for, then textures in images will generally be too blurry. The `ScaleDifferentials()` method below takes care of this, given an estimated sample spacing of `s`. It is called, for example, by the fragment `<<Generate camera ray for current sample>>` in @introduction.
][
  `pbrt` 中的 #link("../Cameras_and_Film/Camera_Interface.html#Camera")[Camera] 实现假设相机射线间隔为一个像素，计算射线离开相机的差分。光线积分器通常为每个像素生成多个相机射线，在这种情况下，样本之间的实际距离较小，差分应相应更新；如果不考虑此因素，图像中的纹理通常会过于模糊。下面的 `ScaleDifferentials()` 方法处理了这一点，给定一个估计的样本间距 `s`。它在@introduction 的`<<Generate camera ray for current sample>>` 中被调用。
]

```cpp
void ScaleDifferentials(Float s) {
    rxOrigin = o + (rxOrigin - o) * s;
    ryOrigin = o + (ryOrigin - o) * s;
    rxDirection = d + (rxDirection - d) * s;
    ryDirection = d + (ryDirection - d) * s;
}
```