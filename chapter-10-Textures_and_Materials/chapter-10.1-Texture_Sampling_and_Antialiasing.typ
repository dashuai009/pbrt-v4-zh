#import "../template.typ": parec, ez_caption

== Texture Sampling and Antialiasing
<texture-sampling-and-antialiasing>


#parec[
  The sampling task from @sampling-and-reconstruction was a frustrating one since the aliasing problem was known to be unsolvable from the start. The infinite frequency content of geometric edges and hard shadows guarantees aliasing in the final images, no matter how high the image sampling rate. (Our only consolation is that the visual impact of this remaining aliasing can be reduced to unobjectionable levels with a sufficient number of well-placed samples.)
][
  @sampling-and-reconstruction 中的采样任务令人沮丧，因为从一开始就知道锯齿问题是无法解决的。几何边缘和硬阴影的无限频率特性保证了最终图像中会出现锯齿现象，无论图像采样频率多高。（我们唯一的安慰是，通过足够数量的合理放置的样本，可以将其余锯齿的视觉影响降低到可以接受的水平。）
]

#parec[
  Fortunately, things are not this difficult from the start for textures: either there is often a convenient analytic form of the texture function available, which makes it possible to remove excessively high frequencies before sampling it, or it is possible to be careful when evaluating the function so as not to introduce high frequencies in the first place. When this problem is carefully addressed in texture implementations, as is done through the rest of this chapter, there is usually no need for more than one sample per pixel in order to render an image without texture aliasing. (Of course, sufficiently reducing Monte Carlo noise from lighting calculations may be another matter.)
][
  幸运的是，纹理处理一开始就没有这么复杂：要么纹理函数通常有一个方便的解析形式，可以在采样之前去除过高的频率，要么在评估函数时可以小心谨慎，以免引入高频率。如本章其余部分所述，当在纹理实现中仔细解决了这个问题，通常每像素不需要超过一个样本即可渲染出没有纹理锯齿的图像。（当然，充分减少光照计算中的蒙特卡罗噪声可能是另一回事。）
]

#parec[
  Two problems must be addressed in order to remove aliasing from texture functions:
][
  为了从纹理函数中去除锯齿，必须解决两个问题：
]

#parec[
  1. The sampling rate in texture space must be computed. The screen-space sampling rate is known from the image resolution and pixel sampling rate, but here we need to determine the resulting sampling rate on a surface in the scene in order to find the rate at which the texture function is being sampled.
][
  1. 必须计算纹理空间中的采样率。屏幕空间的采样率是已知的，由图像分辨率和像素采样率决定，但这里我们需要确定场景中表面的采样率，以找到纹理函数的采样率。
]

#parec[
  2. Given the texture sampling rate, sampling theory must be applied to guide the computation of a texture value that does not have higher frequency variation than can be represented by the sampling rate (e.g., by removing excess frequencies beyond the Nyquist limit from the texture function).
][
  2. 给定纹理采样率，必须应用采样理论来指导计算一个不会有比采样率能表示的更高频率变化的纹理值（例如，通过从纹理函数中去除超出奈奎斯特限制的多余频率）。
]

#parec[
  These two issues will be addressed in turn throughout the rest of this section.
][
  本节的其余部分将依次解决这两个问题。
]

=== Finding the Texture Sampling Rate
<finding-the-texture-sampling-rate>


#parec[
  Consider an arbitrary texture function that is a function of position, $T (p)$, defined on a surface in the scene. If we ignore the complications introduced by visibility—the possibility that another object may occlude the surface at nearby image samples or that the surface may have a limited extent on the image plane—this texture function can also be expressed as a function over points $(x , y)$ on the image plane, $T (f (x , y))$, where $f (x , y)$ is the function that maps image points to points on the surface. Thus, $T (f (x , y))$ gives the value of the texture function as seen at image position $(x , y)$.
][
  考虑一个任意的纹理函数，它是场景中某个表面上关于位置的函数， $T (p)$。如果我们忽略可见性引入的复杂性——例如，另一个物体可能遮挡附近图像样本处的表面，或者表面在图像平面上的范围有限——这个纹理函数也可以表示为图像平面上的点 $(x , y)$ 的函数， $T (f (x , y))$，其中 $f (x , y)$ 是将图像点映射到表面点的函数。因此， $T (f (x , y))$ 给出了在图像位置 $(x , y)$ 处看到的纹理函数的值。
]

#parec[
  As a simple example of this idea, consider a 2D texture function $T (s , t)$ applied to a quadrilateral that is perpendicular to the $z$ axis and has corners at the world-space points $(0 , 0 , 0)$, $(1 , 0 , 0)$, $(1 , 1 , 0)$, and $(0 , 1 , 0)$. If an orthographic camera is placed looking down the $z$ axis such that the quadrilateral precisely fills the image plane and if points $p$ on the quadrilateral are mapped to 2D $(s , t)$ texture coordinates by
][
  作为这个概念的一个简单例子，考虑一个二维纹理函数 $T (s , t)$ 应用于一个垂直于 $z$ 轴的四边形，该四边形的顶点在世界空间点 $(0 , 0 , 0)$ 、 $(1 , 0 , 0)$ 、 $(1 , 1 , 0)$ 和 $(0 , 1 , 0)$。如果一个正交相机被放置在沿 $z$ 轴俯视，使得四边形正好填满图像平面，并且四边形上的点 $p$ 被映射到二维 $(s , t)$ 纹理坐标：
]

$ s = p_x , t = p_y , $


#parec[
  then the relationship between $(s , t)$ and screen $(x , y)$ pixels is straightforward.
][
  那么 $(s , t)$ 和屏幕 $(x , y)$ 像素之间的关系是直接的。
]


$ s = x / x_r, t = y / y_r $
#parec[
  where the overall image resolution is $(x_r , y_r)$. Thus, given a sample spacing of one pixel in the image plane, the sample spacing in $(s , t)$ texture parameter space is $(1 \/ x_r , 1 \/ y_r)$, and the texture function must remove any detail at a higher frequency than can be represented at that sampling rate.
][
  其中整体图像分辨率为 $(x_r , y_r)$。因此，给定图像平面中一个像素的样本间距， $(s , t)$ 纹理参数空间中的样本间距为 $(1 \/ x_r , 1 \/ y_r)$，纹理函数必须去除任何在该采样率下无法表示的更高频率的细节。
]


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f02.svg"),
  caption: [
    #ez_caption[
      If a quadrilateral is viewed with an orthographic perspective such that the quadrilateral precisely fills the image plane, it is easy to compute the relationship between the sampling rate in $(x, y)$ pixel coordinates and the texture sampling rate.
    ][
      如果以正交视角查看一个四边形，并使其恰好填满图像平面，则可以很容易地计算出在像素坐标 $(x, y)$ 中的采样率与纹理采样率之间的关系。
    ]
  ],
)

#parec[
  This relationship between pixel coordinates and texture coordinates, and thus the relationship between their sampling rates, is the key bit of information that determines the maximum frequency content allowable in the texture function. As a slightly more complex example, given a triangle with $(u , v)$ texture coordinates at its vertices and viewed with a perspective projection, it is possible to analytically find the differences in $u$ and $v$ across the sample points on the image plane. This approach was the basis of texture antialiasing in graphics processors before they became programmable.
][
  这种像素坐标与纹理坐标之间的关系，以及它们的采样率之间的关系，是决定纹理函数中允许的最大频率内容的关键信息。作为一个稍微复杂一点的例子，给定一个在其顶点具有 $(u , v)$ 纹理坐标并通过透视投影查看的三角形，可以解析地找到图像平面上样本点之间 $u$ 和 $v$ 的差异。 这种方法是图形处理器在可编程之前纹理抗锯齿的基础。
]

#parec[
  For more complex scene geometry, camera projections, and mappings to texture coordinates, it is much more difficult to precisely determine the relationship between image positions and texture parameter values. Fortunately, for texture antialiasing, we do not need to be able to evaluate $f (x , y)$ for arbitrary $(x , y)$ but just need to find the relationship between changes in pixel sample position and the resulting change in texture sample position at a particular point on the image. This relationship is given by the partial derivatives of this function, $partial f \/ partial x$ and $partial f \/ partial  y)$. For example, these can be used to find a first-order approximation to the value of $f$.
][
  对于更复杂的场景几何、相机投影和纹理坐标的映射，精确确定图像位置和纹理参数值之间的关系要困难得多。幸运的是，对于纹理抗锯齿，我们不需要对任意 $(x , y)$ 评估 $f (x , y)$，只需找到像素样本位置变化与图像上特定点纹理样本位置变化之间的关系即可。 这个关系由该函数的偏导数 $partial f \/ partial  x$ 和 $partial f \/ partial  y$ 给出。例如，这些可以用来找到 $f$ 值的一阶近似。
]


$
  f (x prime , y prime) approx f (x , y) + (x prime - x) frac(partial f, partial x) + ( y prime - y ) frac(partial f, partial y) .
$


#parec[
  If these partial derivatives are changing slowly with respect to the distances $x prime - x$ and $y prime - y$, this is a reasonable approximation. More importantly, the values of these partial derivatives give an approximation to the change in texture sample position for a shift of one pixel in the $x$ and $y$ directions, respectively, and thus directly yield the texture sampling rate. For example, in the previous quadrilateral example, $partial s \/ partial x = 1 \/ r , partial s \/ partial y = 0 , partial t \/ partial x = 0 , partial t \/ partial y = 1 \/ r$.
][
  如果这些偏导数相对于距离 $x prime - x$ 和 $y prime - y$ 变化缓慢，那么这是一个合理的近似。更重要的是，这些偏导数的值分别近似表示了在 $x$ 和 $y$ 方向上移动一个像素时纹理样本位置的变化，从而直接得出纹理采样率。例如，在前面的四边形例子中， $partial s \/ partial x = 1 \/ r , partial s \/ partial y = 0 , partial t \/ partial x = 0 , partial t \/ partial y = 1 \/ r$.
]

#parec[
  The key to finding the values of these derivatives in the general case lies in values from the @ray-differentials structure, which was defined in Section #link("../Geometry_and_Transformations/Rays.html#sec:ray-differentials")[3.6.1];. This structure is initialized for each camera ray by the #link("../Cameras_and_Film/Camera_Interface.html#Camera::GenerateRayDifferential")[Camera::GenerateRayDifferential()] method; it contains not only the ray being traced through the scene but also two additional rays, one offset horizontally one pixel sample from the camera ray and the other offset vertically by one pixel sample. All the geometric ray intersection routines use only the main camera ray for their computations; the auxiliary rays are ignored (this is easy to do because #link("../Geometry_and_Transformations/Rays.html#RayDifferential")[RayDifferential] is a subclass of #link("../Geometry_and_Transformations/Rays.html#Ray")[Ray];).
][
  在一般情况下找到这些导数值的关键在于 @ray-differentials 结构中的值，该结构在第 #link("../Geometry_and_Transformations/Rays.html#sec:ray-differentials")[3.6.1] 节中定义。这个结构通过 #link("../Cameras_and_Film/Camera_Interface.html#Camera::GenerateRayDifferential")[Camera::GenerateRayDifferential()] 方法为每条相机光线初始化；它不仅包含穿过场景的光线，还包含两个附加光线，一个在水平方向上偏移一个像素样本，另一个在垂直方向上偏移一个像素样本。所有几何光线交叉例程仅使用主相机光线进行计算；辅助光线被忽略（这很容易做到，因为 #link("../Geometry_and_Transformations/Rays.html#RayDifferential")[RayDifferential] 是 #link("../Geometry_and_Transformations/Rays.html#Ray")[Ray] 的子类）。
]

#parec[
  We can use the offset rays to estimate the partial derivatives of the mapping $p (x , y)$ from image position to world-space position and the partial derivatives of the mappings $u (x , y)$ and $v (x , y)$ from $(x , y)$ to $(u , v)$ parametric coordinates, giving the partial derivatives of rendering-space positions $frac(partial p, partial x)$ and $frac(partial p, partial y)$ and the derivatives of $(u , v)$ parametric coordinates $frac(partial u, partial x) , frac(partial v, partial x) , frac(partial u, partial y) ,$ and $frac(partial v, partial y)$. In @texture-coordinate-generation, we will see how these can be used to compute the screen-space derivatives of arbitrary quantities based on $p$ or $(u , v)$ and consequently the sampling rates of these quantities. The values of these derivatives at the intersection point are stored in the #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] structure.
][
  我们可以使用偏移光线来估计从图像位置到世界空间位置的映射 $p (x , y)$ 的偏导数，以及从 $(x , y)$ 到 $(u , v)$ 参数坐标的映射 $u (x , y)$ 和 $v (x , y)$ 的偏导数，从而得到渲染空间位置的偏导数 $frac(partial p, partial x)$ 和 $frac(partial p, partial y)$，以及 $(u , v)$ 参数坐标的导数 $frac(partial u, partial x) , frac(partial v, partial x) , frac(partial u, partial y) ,$ 和 $frac(partial v, partial y)$。在@texture-coordinate-generation 中，我们将看到如何使用这些来计算基于 $p$ 或 $(u , v)$ 的任意量的屏幕空间导数，从而计算这些量的采样率。这些导数在交点处的值存储在 #link("../Geometry_and_Transformations/Interactions.html#SurfaceInteraction")[SurfaceInteraction] 结构中。
]

```cpp
Vector3f dpdx, dpdy;
Float dudx = 0, dvdx = 0, dudy = 0, dvdy = 0;
```
#parec[
  The #link("<SurfaceInteraction::ComputeDifferentials>")[`SurfaceInteraction::ComputeDifferentials()`] method computes these values. It is called by #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#SurfaceInteraction::GetBSDF")[`SurfaceInteraction::GetBSDF()`] before the #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[Material];'s `GetBxDF()` method is called so that these values will be available for any texture evaluation routines that are called by the material.
][
  #link("<SurfaceInteraction::ComputeDifferentials>")[`SurfaceInteraction::ComputeDifferentials()`] 方法计算这些值。在调用 #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#Material")[`Material`] 的 `GetBxDF()` 方法之前，它由 #link("../Textures_and_Materials/Material_Interface_and_Implementations.html#SurfaceInteraction::GetBSDF")[`SurfaceInteraction::GetBSDF()`] 调用，以便这些值可用于材质调用的任何纹理评估程序。
]

#parec[
  Ray differentials are not available for all rays traced by the system— for example, rays starting from light sources traced for photon mapping or bidirectional path tracing. Further, although we will see how to compute ray differentials after rays undergo specular reflection and transmission in @ray-differentials-for-specular-reflection-and-transmission, how to compute ray differentials after diffuse reflection is less clear. In cases like those as well as the corner case where one of the differentials' directions is perpendicular to the surface normal, which leads to undefined numerical values in the following, an alternative approach based on approximating the ray differentials of a ray from the camera to the intersection point is used.
][
  系统追踪的所有光线并不都具有光线微分——例如，从光源开始用于光子映射或双向路径追踪。此外的光线，尽管我们将在@ray-differentials-for-specular-reflection-and-transmission 中看到如何计算在光线经过镜面反射和透射后光线微分，但计算在漫反射后光线微分的方法尚不明确。在这些情况下，以及在一个微分方向垂直于表面法线的极端情况下，可能导致未定义的数值。此时，可以使用基于从相机到交点的光线微分近似的替代方法。
]

```cpp
// Estimate screen-space change in (u, v)
// Compute A^T A and its determinant
Float ata00 = Dot(dpdu, dpdu), ata01 = Dot(dpdu, dpdv);
Float ata11 = Dot(dpdv, dpdv);
Float invDet = 1 / DifferenceOfProducts(ata00, ata11, ata01, ata01);
invDet = IsFinite(invDet) ? invDet : 0.f;

// Compute A^T b for x and y
Float atb0x = Dot(dpdu, dpdx), atb1x = Dot(dpdv, dpdx);
Float atb0y = Dot(dpdu, dpdy), atb1y = Dot(dpdv, dpdy);

// Compute u and v derivatives with respect to x and y
dudx = DifferenceOfProducts(ata11, atb0x, ata01, atb1x) * invDet;
dvdx = DifferenceOfProducts(ata00, atb1x, ata01, atb0x) * invDet;
dudy = DifferenceOfProducts(ata11, atb0y, ata01, atb1y) * invDet;
dvdy = DifferenceOfProducts(ata00, atb1y, ata01, atb0y) * invDet;

// Clamp derivatives of u and v to reasonable values
dudx = IsFinite(dudx) ? Clamp(dudx, -1e8f, 1e8f) : 0.f;
dvdx = IsFinite(dvdx) ? Clamp(dvdx, -1e8f, 1e8f) : 0.f;
dudy = IsFinite(dudy) ? Clamp(dudy, -1e8f, 1e8f) : 0.f;
dvdy = IsFinite(dvdy) ? Clamp(dvdy, -1e8f, 1e8f) : 0.f;
```


#parec[
  The key to estimating the derivatives is the assumption that the surface is locally flat with respect to the sampling rate at the point being shaded. This is a reasonable approximation in practice, and it is hard to do much better. Because ray tracing is a point-sampling technique, we have no additional information about the scene in between the rays we have traced. For highly curved surfaces or at silhouette edges, this approximation can break down, though this is rarely a source of noticeable error.
][
  估计导数的关键是假设表面在被着色点的采样率方面是局部平坦的。这在实践中是一个合理的近似，并且很难做得更好。因为光线追踪是一种点采样技术，我们没有关于光线之间场景的额外信息。对于高度曲面的表面或轮廓边缘，这种近似可能会失效，尽管这很少是明显错误的来源。
]

#parec[
  For this approximation, we need the plane through the point $p$ intersected by the main ray that is tangent to the surface. This plane is given by the implicit equation.
][
  对于这种近似，我们需要通过主光线与表面相切的点 $p$ 的平面。这个平面由隐式方程给出。
]


$ a x + b y + c z + d = 0 , $


#parec[
  where $a = upright(bold(n))_x$, $b = upright(bold(n))_y$, $c = upright(bold(n))_z$, and $d = - (upright(bold(n)) dot.op upright(bold(p)))$. We can then compute the intersection points $p_x$ and $p_y$ between the auxiliary rays $r_x$ and $r_y$ and this plane (@fig:rays-tangent-plane). These new points give an approximation to the partial derivatives of position on the surface $frac(partial p, partial x)$ and $frac(partial p, partial y)$, based on forward differences:
][
  其中 $a =  upright(bold(n))_x$, $b =  upright(bold(n))_y$, $c =  upright(bold(n))_z$, 且 $d = - (upright(bold(n)) dot.op upright(bold(p)))$。然后我们可以计算辅助光线 $r_x$ 和 $r_y$ 与该平面的交点 $p_x$ 和 $p_y$ （@fig:rays-tangent-plane）。这些新点提供了基于前向差分的表面位置的偏导数 $frac(partial p, partial x)$ 和 $frac(partial p, partial y)$ 的近似值：
]

$ frac(partial p, partial x) approx p_x - p , quad frac(partial p, partial y) approx p_y - p . $

#parec[
  Because the differential rays are offset one pixel sample in each direction, there is no need to divide these differences by a $Delta$ value, since $Delta = 1$.
][
  由于微分光线在每个方向上偏移一个像素样本，因此不需要将这些差异除以 $Delta$ 值，因为 $Delta = 1$。
]

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f03.svg"),
  caption: [
    #ez_caption[
      By approximating the local surface geometry at the intersection point with the tangent plane through $upright(p)$, approximations to the points at which the auxiliary rays $r_x$ and $r_y$ would intersect the surface can be found by finding their intersection points with the tangent plane $upright(p)_x$ and $upright(p)_y$.
    ][
      通过在交点处用经过 $upright(p)$ 的切平面来近似局部表面几何，我们可以通过找到辅助射线 $r_x$ 和 $r_y$ 与切平面 $upright(p)_x$ 和 $upright(p)_y$ 的交点，从而得到它们与表面的交点的近似位置。
    ]
  ],
)<rays-tangent-plane>

```
<<Estimate screen-space change in  using ray differentials>>=
<<Compute auxiliary intersection points with plane, px and py>>
dpdx = px - p();
dpdy = py - p();
```

#parec[
  The ray–plane intersection algorithm described in @raybounds-intersections gives the $t$ value where a ray described by origin $upright(bold(o))$ and direction $upright(bold(d))$ intersects a plane described by $a x + b y + c z + d = 0$ :
][
  @raybounds-intersections 中描述的光线–平面交点算法给出了光线由原点 $upright(bold(o))$ 和方向 $upright(bold(d))$ 描述的光线与由 $a x + b y + c z + d = 0$ 描述的平面相交的 $t$ 值：
]


$ t = frac(- (upright(bold((a , b , c))) dot.op upright(bold(n))) - d, (a , b , c) dot.op upright(bold(d))) . $


#parec[
  To compute this value for the two auxiliary rays, the plane's $d$ coefficient is computed first. It is not necessary to compute the $a$, $b$, and $c$ coefficients, since they are available in `n`. We can then apply the formula directly.
][
  为了计算两个辅助光线的这个值，首先计算平面的 $d$ 系数。不需要计算 $a$ 、 $b$ 和 $c$ 系数，因为系数 $a$ 、 $b$ 和 $c$ 已包含在向量 `n` 中。然后我们可以直接应用公式。
]

```c
Float d = -Dot(n, Vector3f(p()));
Float tx = (-Dot(n, Vector3f(ray.rxOrigin)) - d) /
           Dot(n, ray.rxDirection);
Point3f px = ray.rxOrigin + tx * ray.rxDirection;
Float ty = (-Dot(n, Vector3f(ray.ryOrigin)) - d) /
           Dot(n, ray.ryDirection);
Point3f py = ray.ryOrigin + ty * ray.ryDirection;
```

#parec[
  For cases where ray differentials are not available, we will add a method to the `Camera` interface that returns approximate values for $frac(partial p, partial x)$ and $frac(partial p, partial y)$ at a point on a surface in the scene. These should be a reasonable approximation to the differentials of a ray from the camera that found an intersection at the given point. Cameras' implementations of this method must return reasonable results even for points outside of their viewing volumes for which they cannot actually generate rays.
][
  对于没有光线差分的情况，我们将在 `Camera` 接口中添加一个方法，该方法返回场景中某个表面点处 $frac(partial p, partial x)$ 和 $frac(partial p, partial y)$ 的近似值。这些应该是从相机发出的光线在给定点找到交点的差分的合理近似。相机对该方法的实现必须返回合理的结果，即使对于那些实际上无法生成光线的视图体积之外的点也是如此。
]

```c
void Approximate_dp_dxy(Point3f p, Normal3f n, Float time,
    int samplesPerPixel, Vector3f *dpdx, Vector3f *dpdy) const;
```

#parec[
  #link("../Cameras_and_Film/Camera_Interface.html#CameraBase")[`CameraBase`] provides an implementation of an approach to approximating these differentials that is based on the minimum of the camera ray differentials across the entire image. Because all of `pbrt`'s current camera implementations inherit from #link("../Cameras_and_Film/Camera_Interface.html#CameraBase")[`CameraBase`];, the following method takes care of all of them.
][
  #link("../Cameras_and_Film/Camera_Interface.html#CameraBase")[`CameraBase`] 提供了一种基于整个图像中相机光线差分最小值的差分近似方法的实现。因为所有 `pbrt` 的当前相机实现都继承自 #link("../Cameras_and_Film/Camera_Interface.html#CameraBase")[`CameraBase`];，以下方法负责处理所有这些。
]

```
<<CameraBase Public Methods>>+=
void Approximate_dp_dxy(Point3f p, Normal3f n, Float time,
        int samplesPerPixel, Vector3f *dpdx, Vector3f *dpdy) const {
    <<Compute tangent plane equation for ray differential intersections>>
    <<Find intersection points for approximated camera differential rays>>
    <<Estimate  and  in tangent plane at intersection point>>
}

```

#parec[
  This method starts by orienting the camera so that the camera-space $z$ axis is aligned with the vector from the camera position to the intersection point. It then uses lower bounds on the spread of rays over the image that are provided by the camera to find approximate differential rays. It then intersects these rays with the tangent plane at the intersection point. (See @fig:camera-approximate-dp-dxy)
][
  该方法首先将相机定向，使相机空间的 $z$ 轴与从相机位置到交点的向量对齐。然后使用相机提供的图像上光线扩展的下限来寻找近似差分光线。然后将这些光线与交点处的切平面相交。（见@fig:camera-approximate-dp-dxy。）
]


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f04.svg"),
  caption: [
    #ez_caption[
      `CameraBase::Approximate_dp_dxy()` effectively reorients the camera to point at the provided intersection point. In camera space, the ray to the intersection then has origin $(0, 0, 0)$ and direction $(0, 0, 1)$. The extent of ray differentials on the tangent plane defined by the surface normal at the intersection point can then be found.
    ][
      `CameraBase::Approximate_dp_dxy()` 有效地重新定向相机以指向提供的交点。在相机空间中，光线到交点的起点为 $(0, 0, 0)$，方向为 $(0, 0, 1)$。然后可以找到由交点处的表面法线定义的切平面上的光线差分的范围。
    ]
  ],
)<camera-approximate-dp-dxy>

#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f05.svg"),
  caption: [
    #ez_caption[
      Visualization of the Ratio of Filter Areas Estimated by Regular Ray Differentials to Areas Estimated by `CameraBase::Approximate_dp_dxy()`. We represent the filter area as the product $max( | partial u\/ partial x |,  | partial u \/ partial y| )  max (| partial v\/ partial x |,  | partial v \/ partial y| )$ and visualize the base 2 logarithm of the ratio of areas computed by the two techniques. Log 2 ratios greater than 0 indicate that the camera-based approximation estimated a larger filter area.

    ][
      由常规光线差分估计的滤波器面积与由 `CameraBase::Approximate_dp_dxy()` 估计的面积的比率可视化。我们将滤波器面积表示为 $max( | partial u\/ partial x |,  | partial u partial y )  max ( |partial v\/ partial x| ,  |partial v \/ partial y| )$ 的乘积，并可视化由两种技术计算的面积比率的以 2 为底的对数。对数 2 比率大于 0 表示相机基于的近似估计了更大的滤波器面积。
    ]
  ],
)<filter-area-visualizations>


#parec[
  There are a number of sources of error in this approximation. Beyond the fact that it does not account for how light was scattered at intermediate surfaces for multiple-bounce ray paths, there is also the fact that it is based on the minimum of the camera's differentials for all rays. In general, it tries to underestimate those derivatives rather than overestimate them, as we prefer aliasing over blurring here. The former error can at least be addressed with additional pixel samples. In order to give a sense of the impact of some of these approximations, @fig:filter-area-visualizations has visualization that compares the local area estimated by those derivatives at intersections to the area computed using the actual ray differentials generated by the camera.
][
  在这种近似中有许多误差来源。除了它没有考虑到光在多次反弹光线路径的中间表面如何散射之外，还有它是基于相机对所有光线的差分的最小值。一般来说，它试图低估这些导数而不是高估它们，因为我们在这里更喜欢混叠而不是模糊。前者的误差至少可以通过增加像素样本来解决。为了给出这些近似对某些影响的感觉，@fig:filter-area-visualizations 有一个可视化，比较了那些导数在交点处估计的局部面积与使用相机生成的实际光线差分计算的面积。
]

#parec[
  For the first step of the algorithm, we have an intersection point in rendering space `p` that we would like to transform into a coordinate system where it is along the $z$ axis with the camera at the origin. Transforming to camera space gets us started and an additional rotation that transforms the vector from the origin to the intersection point to be aligned with $z$ finishes the job. The $d$ coefficient of the plane equation can then be found by taking the dot product of the transformed point and surface normal. Because the $x$ and $y$ components of the transformed point are equal to 0, the dot product can be optimized to be a single multiply.
][
  算法的第一步中，我们有一个渲染空间中的交点 `p`，我们希望将其转换为一个坐标系，使其沿着 $z$ 轴并且相机在原点。转换到相机空间使我们开始，并且额外的旋转将从原点到交点的向量与 $z$ 对齐完成了这项工作。然后可以通过取变换点和表面法线的点积来找到平面方程的 $d$ 系数。因为变换点的 $x$ 和 $y$ 分量等于 0，所以点积可以优化为单个乘法。
]

```cpp
<<Compute tangent plane equation for ray differential intersections>>=
Point3f pCamera = CameraFromRender(p, time);
Transform DownZFromCamera =
    RotateFromTo(Normalize(Vector3f(pCamera)), Vector3f(0, 0, 1));
Point3f pDownZ = DownZFromCamera(pCamera);
Normal3f nDownZ = DownZFromCamera(CameraFromRender(n, time));
Float d = nDownZ.z * pDownZ.z;
```

#parec[
  Camera implementations that inherit from `CameraBase` and use this method must initialize the following member variables with values that are lower bounds on each of the respective position and direction differentials over all the pixels in the image.
][
  继承自 `CameraBase` 并使用此方法的相机实现必须用图像中所有像素的各自位置和方向差分的下限值初始化以下成员变量。
]

```c
Vector3f minPosDifferentialX, minPosDifferentialY;
Vector3f minDirDifferentialX, minDirDifferentialY;
```

#parec[
  The main ray in this coordinate system has origin $(0, 0, 0)$ and direction $(0, 0, 1)$. Adding the position and direction differential vectors to those gives the origin and direction of each differential ray. Given those, the same calculation as earlier gives us the $t$ values for the ray-plane intersections for the differential rays and thence the intersection points.
][
  在这个坐标系中，主光线的起点为 $(0, 0, 0)$，方向为 $(0, 0, 1)$。将位置和方向差分向量加到这些上给出了每个差分光线的起点和方向。给定这些，和之前一样的计算为差分光线的光线-平面交点提供了 $t$ 值，从而得到了交点。
]

```cpp
<<Find intersection points for approximated camera differential rays>>=
Ray xRay(Point3f(0,0,0) + minPosDifferentialX,
         Vector3f(0,0,1) + minDirDifferentialX);
Float tx = -(Dot(nDownZ, Vector3f(xRay.o)) - d) / Dot(nDownZ, xRay.d);
Ray yRay(Point3f(0,0,0) + minPosDifferentialY,
         Vector3f(0,0,1) + minDirDifferentialY);
Float ty = -(Dot(nDownZ, Vector3f(yRay.o)) - d) / Dot(nDownZ, yRay.d);
Point3f px = xRay(tx), py = yRay(ty);
```

#parec[
  For an orthographic camera, these differentials can be computed directly. There is no change in the direction vector, and the position differentials are the same at every pixel. Their values are already computed in the `OrthographicCamera` constructor, so can be used directly to initialize the base class's member variables.
][
  对于正交相机，这些差分可以直接计算。方向向量没有变化，并且位置差分在每个像素处都是相同的。它们的值已经在 `OrthographicCamera` 构造函数中计算，因此可以直接用于初始化基类的成员变量。
]

```cpp
<<Compute minimum differentials for orthographic camera>>=
minDirDifferentialX = minDirDifferentialY = Vector3f(0, 0, 0);
minPosDifferentialX = dxCamera;
minPosDifferentialY = dyCamera;
```

#parec[
  All the other cameras call `FindMinimumDifferentials()`, which estimates these values by sampling at many points across the diagonal of the image and storing the minimum of all the differentials encountered. That function is not very interesting, so it is not included here.
][
  所有其他相机调用 `FindMinimumDifferentials()`，通过在图像对角线上多个点进行采样并存储所有遇到的差分的最小值来估计这些值。该函数不是很有趣，因此不在此处包含。
]
```c
FindMinimumDifferentials(this);
```

#parec[
  Given the intersection points `px` and `py`, $partial p \/ partial x$ and $partial p \/ partial y$ can now be estimated by taking their differences with the main intersection point. To get final estimates of the partial derivatives, these vectors must be transformed back out into rendering space and scaled to account for the actual pixel sampling rate. As with the initial ray differentials that were generated in the `<<Scale camera ray differentials based on image sampling rate` fragment, these are scaled to account for the pixel sampling rate.
][
  给定交点 `px` 和 `py`，可以通过与主交点的差异来估计 $partial p \/ partial x$ and $partial p \/ partial y$。为了获得偏导数的最终估计，这些向量必须被转换回渲染空间并缩放以考虑实际的像素采样率。与在 `<<Scale camera ray differentials based on image sampling rate` 片段中生成的初始光线差分一样，这些也被缩放以考虑像素采样率。
]

```c
Float sppScale = GetOptions().disablePixelJitter ? 1 :
    std::max<Float>(.125, 1 / std::sqrt((Float)samplesPerPixel));
*dpdx = sppScale *
    RenderFromCamera(DownZFromCamera.ApplyInverse(px - pDownZ), time);
*dpdy = sppScale *
    RenderFromCamera(DownZFromCamera.ApplyInverse(py - pDownZ), time);
```

#parec[
  A call to this method takes care of computing the $partial p \/ partial x$ and $partial p \/ partial y$ differentials in the `ComputeDifferentials()` method.
][
  调用此方法负责在 `ComputeDifferentials()` 方法中计算 $partial p \/ partial x$ and $partial p \/ partial y$ 差分。
]

```c
camera.Approximate_dp_dxy(p(), n, time, samplesPerPixel, &dpdx, &dpdy);
```
#parec[
  We now have both the partial derivatives $partial p\/partial u$ and $partial p\/partial v$ as well as, one way or another, $partial p\/partial x$ and $partial p\/partial y$. From them, we would now like to compute $partial u\/partial x$, $partial u\/partial y$, $partial v\/partial x$, and $partial v\/partial y$. Using the chain rule, we can find that
][
  我们现在有了偏导数 $partial p \/ partial u$ 和 $partial p \/ partial v$，以及以某种方式得到的 $partial p\/partial x$ 和 $partial p\/partial y$。从它们中，我们现在希望计算 $partial u\/partial x$ 、 $partial u\/partial y$ 、 $partial v\/partial x$ 和 $partial v\/partial y$。使用链式法则，我们可以发现
]

$ frac(diff p, diff x) = frac(diff p, diff u) frac(d u, d x) + frac(diff p, diff v) frac(d v, d x) . $<dpdx-from-uv>


#parec[
  $frac(partial p, partial y)$ has a similar expression with $frac(partial u, partial x)$ replaced by $frac(partial u, partial y)$ and $frac(partial v, partial x)$ replaced by $frac(partial v, partial y)$.
][
  $frac(partial p, partial y)$ 有一个类似的表达式，将 $frac(partial u, partial x)$ 替换为 $frac(partial u, partial y)$ 和 $frac(partial v, partial x)$ 替换为 $frac(partial v, partial y)$。
]

#parec[
  @eqt:dpdx-from-uv can be written as a matrix equation where the two following matrices that include $partial p$ have three rows, one for each of $p$ 's $x$, $y$, and $z$ components:
][
  @eqt:dpdx-from-uv 可以写成一个矩阵方程，其中包含 $partial p$ 的两个矩阵有三行，分别对应 $p$ 的 $x$ 、 $y$ 和 $z$ 分量：
]

$
  (frac(diff p, diff x)) =( frac(diff p, diff u) quad frac(diff p, diff v) ) mat(delim: #none, frac(d u, d x); frac(d v, d x)) .
$

#parec[
  This is an overdetermined linear system since there are three equations but only two unknowns, $frac(partial u, partial x)$ and $frac(partial v, partial x)$. An effective solution approach in this case is to apply linear least squares, which says that for a linear system of the form $upright(bold(A)) upright(bold(x)) = upright(bold(b))$ with $upright(bold(A))$ and $upright(bold(b))$ known, the least-squares solution for $upright(bold(x))$ is given by
][
  这是一个超定线性系统，因为有三个方程但只有两个未知数， $frac(partial u, partial x)$ 和 $frac(partial v, partial x)$。在这种情况下，应用线性最小二乘法是一个有效的解决方法，它指出对于形式为 $upright(bold(A)) upright(bold(x)) = upright(bold(b))$ 的线性系统，其中 $upright(bold(A))$ 和 $upright(bold(b))$ 是已知的， $upright(bold(x))$ 的最小二乘解为
]

$
  upright(bold(x)) = (upright(bold(A))^T upright(bold(A)))^(- 1) upright(bold(A))^T upright(bold(b)) .
$<least-squares-uv-derivs>

#parec[
  In this case, $upright(bold(A)) = mat(delim: "(", frac(partial p, partial u), frac(partial p, partial v)) $, $upright(bold(b)) = vec(frac(partial p, partial x)) $, and $upright(bold(x)) = mat(delim: "(", frac(partial u, partial x), frac(partial v, partial x))^T $.
][
  在这种情况下， $upright(bold(A)) = mat(delim: "(", frac(partial p, partial u), frac(partial p, partial v))$， $upright(bold(b)) = vec(frac(partial p, partial x))$，以及 $upright(bold(x)) = mat(delim: "(", frac(partial u, partial x), frac(partial v, partial x))^T$。
]

```cpp
<<Estimate screen-space change in >>=
<<Compute  and its determinant>>
<<Compute  for  and >>
<<Compute  and  derivatives with respect to  and >>
<<Clamp derivatives of  and  to reasonable values>>
```

#parec[
  $upright(bold(A))^T upright(bold(A))$ is a $2 times 2$ matrix with elements given by dot products of partial derivatives of position:
][
  $upright(bold(A))^T upright(bold(A))$ 是一个 $2 times 2$ 的矩阵，其元素由位置偏导数的点积给出：
]

$
  upright(bold(A))^T upright(bold(A)) = mat(delim: "(", frac(partial p, partial u) dot.op frac(partial p, partial u), frac(partial p, partial u) dot.op frac(partial p, partial v); frac(partial p, partial u) dot.op frac(partial p, partial v), frac(partial p, partial v) dot.op frac(partial p, partial v)) .
$


#parec[
  Its inverse is
][
  它的逆矩阵是
]

$
  ( upright(bold(A))^T upright(bold(A)) )^(- 1) = 1 / lr(|upright(bold(A))^T upright(bold(A))|) mat(delim: "(", frac(partial p, partial v) dot.op frac(partial p, partial v), - frac(partial p, partial u) dot.op frac(partial p, partial v); - frac(partial p, partial u) dot.op frac(partial p, partial v), frac(partial p, partial u) dot.op frac(partial p, partial u)) .
$<ata-matrix-inverse>


#parec[
  Note that in both matrices the two off-diagonal entries are equal. Thus, the fragment that computes the entries of $upright(bold(A))^T upright(bold(A)) $ only needs to compute three values. The inverse of the matrix determinant is computed here as well. If its value is infinite, the linear system cannot be solved; setting invDet to~0 causes the subsequently computed derivatives to be~0, which leads to point-sampled textures, the best remaining option in that case.
][
  注意在这两个矩阵 $upright(bold(A))^T upright(bold(A)) $ 和其逆矩阵中，两个非对角线元素是相等的。因此，计算 $upright(bold(A))^T upright(bold(A))$ 元素的片段只需要计算三个值。矩阵行列式的逆也在这里计算。如果其值为无穷大，则线性系统无法求解；将 invDet 设为 0 会使得随后计算的导数为 0，这会导致点采样纹理，在这种情况下是最好的选择。
]

```cpp
<<Compute  and its determinant>>=
Float ata00 = Dot(dpdu, dpdu), ata01 = Dot(dpdu, dpdv);
Float ata11 = Dot(dpdv, dpdv);
Float invDet = 1 / DifferenceOfProducts(ata00, ata11, ata01, ata01);
invDet = IsFinite(invDet) ? invDet : 0.f;
```

#parec[
  The $upright(bold(A))^T upright(bold(b)) $ portion of the solution is easily computed. For the derivatives with respect to screen-space $x$, we have the two-element matrix
][
  解决方案的 $upright(bold(A))^T upright(bold(b)) $ 部分很容易计算。对于屏幕空间 $x$ 的导数，我们有一个包含两个元素的矩阵
]


$
  upright(bold(A))^tack.b upright(bold(b)) = mat(delim: "(", frac(partial p, partial u) dot.op frac(partial p, partial x), frac(partial p, partial v) dot.op frac(partial p, partial x)) .
$


#parec[
  The solution for screen-space $y$ is analogous.
][
  屏幕空间 $y$ 的解法与 $x$ 类似。
]

```cpp
<<Compute  for  and >>=
Float atb0x = Dot(dpdu, dpdx), atb1x = Dot(dpdv, dpdx);
Float atb0y = Dot(dpdu, dpdy), atb1y = Dot(dpdv, dpdy);
```


#parec[
  The solution to Equation (10.2) for each partial derivative can be found by taking the product of Equations (10.3) and (10.4). We will gloss past the algebra; its result can be directly expressed in terms of the values computed so far.
][
  方程 (10.2) 中每个偏导数的解可以通过将方程 (10.3) 和 (10.4) 相乘来得到。我们将略过其中的代数运算；其结果可以直接用到目前为止计算出的值来表示。
]
```
<<Compute  and  derivatives with respect to  and >>=
dudx = DifferenceOfProducts(ata11, atb0x, ata01, atb1x) * invDet;
dvdx = DifferenceOfProducts(ata00, atb1x, ata01, atb0x) * invDet;
dudy = DifferenceOfProducts(ata11, atb0y, ata01, atb1y) * invDet;
dvdy = DifferenceOfProducts(ata00, atb1y, ata01, atb0y) * invDet;
```
#parec[
  In certain tricky cases (e.g., with highly distorted parameterizations or at object silhouette edges), the estimated partial derivatives may be infinite or have very large magnitudes. It is worth clamping them to reasonable values in that case to prevent overflow and not-a-number values in subsequent computations that are based on them.
][
  在某些复杂情况下（例如，高度扭曲的参数化或物体轮廓边缘），估算的偏导数可能会趋于无穷大或具有非常大的数值。在这种情况下，将它们限制在合理的值范围内是值得的，以防止在后续基于它们的计算中出现溢出或非数字的情况。
]
```
<<Clamp derivatives of  and  to reasonable values>>=
dudx = IsFinite(dudx) ? Clamp(dudx, -1e8f, 1e8f) : 0.f;
dvdx = IsFinite(dvdx) ? Clamp(dvdx, -1e8f, 1e8f) : 0.f;
dudy = IsFinite(dudy) ? Clamp(dudy, -1e8f, 1e8f) : 0.f;
dvdy = IsFinite(dvdy) ? Clamp(dvdy, -1e8f, 1e8f) : 0.f;
```
=== asdfa

#parec[
  Now is a good time to take care of another detail related to ray differentials: recall from @bsdfs that materials may return an unset `BSDF` to indicate an interface between two scattering media that does not itself scatter light. In this case, it is necessary to spawn a new ray in the same direction, but past the intersection on the surface. In this case we would like the effect of the ray differentials to be the same as if no scattering had occurred. This can be achieved by setting the differential origins to the points given by evaluating the ray equation at the intersection $t$ (see @fig:ray-differentials-at-medium-boundary).
][
  现在是处理与射线微分相关的另一个细节的好时机：回想一下，在@bsdfs 中提到，材料可能会返回一个未设置的 `BSDF`，以表示两个散射介质之间的界面本身不散射光。在这种情况下，有必要生成一个新的射线，方向与原射线相同，但超出表面上的交点。在这种情况下，我们希望射线微分的效果与没有发生散射时相同。可以通过将微分的起点设置为在交点 $t$ 处评估射线方程所得到的点来实现这一效果（参见@fig:ray-differentials-at-medium-boundary）。
]


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f05.svg"),
  caption: [
    #ez_caption[
      When a ray intersects a surface that delineates the boundary between two media, a new ray is spawned on the other side of the boundary. If the origins of this ray’s differentials are set by evaluating the ray equation for the original differentials at the intersection $t$, then the new ray will represent the same footprint as the original one when it subsequently intersects a surface.
    ][
      当一条射线与划分两个介质边界的表面相交时，会在边界的另一侧生成一条新的射线。如果将该射线的微分起点设置为在交点 $t$ 处使用原始微分的射线方程进行评估，那么当新射线随后与表面相交时，它将表示与原始射线相同的投影面积。
    ]
  ],
)<ray-differentials-at-medium-boundary>


```cpp
<<SurfaceInteraction Method Definitions>>+=
void SurfaceInteraction::SkipIntersection(RayDifferential *ray,
                                          Float t) const {
    *((Ray *)ray) = SpawnRay(ray->d);
    if (ray->hasDifferentials) {
        ray->rxOrigin = ray->rxOrigin + t * ray->rxDirection;
        ray->ryOrigin = ray->ryOrigin + t * ray->ryDirection;
    }
}
```

=== #emoji.warning Ray Differentials for Specular Reflection and Transmission
<ray-differentials-for-specular-reflection-and-transmission>
#parec[
  Given the effectiveness of ray differentials for finding filter regions for texture antialiasing for camera rays, it is useful to extend the method to make it possible to determine texture-space sampling rates for objects that are seen indirectly via specular reflection or refraction; objects seen in mirrors, for example, should not have texture aliasing, identical to the case for directly visible objects. Igehy \[1999\] developed an elegant solution to the problem of how to find the appropriate differential rays for specular reflection and refraction, which is the approach used in pbrt. #footnote[
    Igehy's formulation is slightly different from the one
here—he effectively tracked the differences between the main ray and the
offset rays, while we store the offset rays explicitly.  The mathematics
all work out to be the same in the end; we chose this alternative because we
believe that it makes the algorithm's operation for camera rays easier to
understand.
  ]
][
  鉴于光线微分在为相机光线找到纹理抗锯齿的滤波区域方面的有效性，将该方法扩展以确定通过镜面反射或折射间接看到的物体的纹理空间采样率是有用的。例如，通过镜子看到的物体不应有纹理锯齿，这与直接可见物体的情况相同。 Igehy \[1999\] 提出了一个优雅的解决方案，用于解决如何找到镜面反射和折射的适当光线微分的问题，这就是 `pbrt` 中使用的方法。 #footnote[Igehy 的公式与这里的略有不同——他有效地跟踪了主射线和偏移射线之间的差异，而我们显式地存储偏移射线。最终数学推导的结果是相同的；我们选择这种替代方法是因为我们认为这样可以使算法对相机射线的操作更容易理解。]
]

#parec[
  Figure 10.7 illustrates the difference that proper texture filtering for specular reflection and transmission can make: it shows a glass ball and a mirrored ball on a plane with a texture map containing high-frequency components. Ray differentials ensure that the images of the texture seen via reflection and refraction from the balls are free of aliasing artifacts. Here, ray differentials eliminate aliasing without excessively blurring the texture.
][
  图10.7说明了镜面反射和透射的正确纹理过滤可以带来的不同：它展示了一个玻璃球和一个镜面球在一个包含高频成分的纹理贴图的平面上。 光线微分确保通过球的反射和折射看到的纹理图像没有锯齿失真。 在这里，光线微分消除了锯齿而不会过度模糊纹理。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f07.svg"),
  caption: [
    #ez_caption[Tracking ray differentials for reflected and refracted rays ensures that the image map texture seen in the balls is filtered to avoid aliasing. The left ball is glass, exhibiting reflection and refraction, and the right ball is a mirror, just showing reflection. Note that the texture is well filtered over both of the balls. (b) shows the aliasing artifacts that are present if ray differentials are not used.][跟踪反射和折射射线的射线微分可以确保球体上看到的图像纹理得到过滤，从而避免锯齿现象。左侧的球体是玻璃，表现出反射和折射，而右侧的球体是镜面，只表现出反射。请注意，两个球体上的纹理都得到了良好的过滤。（b）展示了如果不使用射线微分时出现的锯齿伪影。]
  ],
)


#figure(
  image("../pbr-book-website/4ed/Textures_and_Materials/pha10f08.svg"),
  caption: [
    #ez_caption[The specular reflection formula gives the direction of the reflected ray at a point on a surface. An offset ray for a ray differential $r'$ (dashed line) will generally intersect the surface at a different point and be reflected in a different direction. The new direction is affected by the different surface normal at the point as well as by the offset ray’s different incident direction. The computation to find the reflected direction for the offset ray in pbrt estimates the change in reflected direction as a function of image-space position and approximates the ray differential’s direction with the main ray’s direction added to the estimated change in direction.][镜面反射公式给出了表面上某点的反射射线方向。对于射线微分 $r'$（虚线）的偏移射线通常会与表面相交于不同的点，并沿不同的方向反射。新的反射方向会受到该点处不同的表面法线和偏移射线不同入射方向的影响。在 pbrt 中，计算偏移射线的反射方向时，会估计反射方向随图像空间位置的变化，并用主射线的方向加上估计的方向变化来近似射线微分的方向。]
  ],
)

#parec[
  The computation to find the reflected direction for the offset ray in pbrt estimates the change in reflected direction as a function of image-space position and approximates the ray differential's direction with the main ray's direction added to the estimated change in direction.
][
  在 `pbrt` 中，计算偏移光线的反射方向时，将反射方向的变化估计为图像空间位置的函数，并用主光线的方向加上估计的方向变化来近似光线微分的方向。
]

#parec[
  To compute the reflected or transmitted ray differentials at a surface intersection point, we need an approximation to the rays that would have been traced at the intersection points for the two offset rays in the ray differential that hit the surface (Figure 10.8). The new ray for the main ray is found by sampling the BSDF, so here we only need to compute the outgoing rays for the $r_x$ and $r_y$ differentials. This task is handled by another SurfaceInteraction::SpawnRay() variant that takes an incident ray differential as well as information about the BSDF and the type of scattering that occurred.
][
  要计算表面交点处的反射或透射光线微分，我们需要对在光线微分中击中表面的两个偏移光线的交点处将被追踪的光线进行近似（图10.8）。 主光线的新光线通过采样BSDF找到，因此这里我们只需要计算 $r_x$ 和 $r_y$ 微分的出射光线。 这个任务由另一个 `SurfaceInteraction::SpawnRay()` 变体处理，该变体接受一个入射光线微分以及关于BSDF和发生的散射类型的信息。
]


```cpp
<<SurfaceInteraction Method Definitions>>+=
RayDifferential SurfaceInteraction::SpawnRay(
        const RayDifferential &rayi, const BSDF &bsdf, Vector3f wi,
        int flags, Float eta) const {
    RayDifferential rd(SpawnRay(wi));
    if (rayi.hasDifferentials) {
        <<Compute ray differentials for specular reflection or transmission>>
    }
    <<Squash potentially troublesome differentials>>
    return rd;
}
```

$ omega_i approx omega_o + frac(partial omega_o, partial x) . $

#parec[
  It is not well defined what the ray differentials should be in the case of non-specular scattering. Therefore, this method handles the two types of specular scattering only; for all other types of rays, approximate differentials will be computed at their subsequent intersection points with Camera::Approximate_dp_dxy().
][
  对于非镜面散射，射线微分的定义并不明确。因此，此方法仅处理两种类型的镜面散射；对于所有其他类型的射线，其近似微分将通过它们在后续与 `Camera::Approximate_dp_dxy()` 的交点来计算。
]

```cpp
<<Compute ray differentials for specular reflection or transmission>>=
<<Compute common factors for specular ray differentials>>
if (flags == BxDFFlags::SpecularReflection) {
    <<Initialize origins of specular differential rays>>
    <<Compute differential reflected directions>>
} else if (flags == BxDFFlags::SpecularTransmission) {
    <<Initialize origins of specular differential rays>>
    <<Compute differential transmitted directions>>
}
```

#parec[
  A few variables will be used for both types of scattering, including the partial derivatives of the surface normal with respect to $x$ and $y$ on the image and $partial upright(bold(n)) \/ x$ and $partial upright(bold(n)) \/ y$, which are computed using the chain rule.
][
  一些变量将用于两种散射类型，包括表面法线相对于图像上的 $x$ 和 $y$ 的偏导数 $partial upright(bold(n)) \/ x$ 和 $partial upright(bold(n)) \/ y$，这些偏导数是通过链式法则计算的。
]

```cpp
<<Compute common factors for specular ray differentials>>=
Normal3f n = shading.n;
Normal3f dndx = shading.dndu * dudx + shading.dndv * dvdx;
Normal3f dndy = shading.dndu * dudy + shading.dndv * dvdy;
Vector3f dwodx = -rayi.rxDirection - wo, dwody = -rayi.ryDirection - wo;
```

#parec[
  For both reflection and transmission, the origin of each differential ray can be found using the already-computed approximations of how much the surface position changes with respect to $(x, y)$ position on the image plane $p \/ x$ and $p \/ y$.
][
  对于反射和透射，两种情况下每条微分射线的起点都可以利用已计算出的表面位置相对于图像平面上 $(x, y)$ 位置的变化近似值 $p \/ x$ and $p \/ y$ 来找到。
]

```cpp
<<Initialize origins of specular differential rays>>=
rd.hasDifferentials = true;
rd.rxOrigin = p() + dpdx;
rd.ryOrigin = p() + dpdy;
```


#parec[
  Finding the directions of these rays is slightly trickier. If we know how much the reflected direction $omega_i$ changes with respect to a shift of a pixel sample in the $x$ and $y$ directions on the image plane, we can use this information to approximate the direction of the offset rays. For example, the direction for the ray offset in $x$ is
][
  确定这些射线的方向稍微复杂一些。如果我们知道反射方向 $omega_i$ 随图像平面上 $x$ 和 $y$ 方向上的像素采样偏移的变化量，就可以利用该信息来近似偏移射线的方向。例如， $x$ 方向上偏移射线的方向为
]

$
  omega approx omega_i + (partial omega_i) / (partial x)
$


#parec[
  Recall from Equation (9.1) that for a normal $upright(bold(n))$ and outgoing direction $omega_o$ the direction for perfect specular reflection is
][
  回忆一下方程 (#link("../Reflection_Models/Specular_Reflection_and_Transmission.html#eq:specular-reflection-direction")[9.1];)，对于法线 $upright(bold(n))$ 和出射方向 $omega_o$，完美镜面反射的方向是
]

$ omega_i = - omega_o + 2 (omega_o dot.op upright(bold(n))) upright(bold(n)) . $


#parec[
  The partial derivatives of this expression are easily computed:
][
  该表达式的偏导数很容易计算出来：
]

$
  frac(partial omega_i, partial x) & = frac(partial, partial x) ( - omega_o + 2 (omega_o dot.op upright(bold(n))) upright(bold(n)) )\
  & = - frac(partial omega_o, partial x) + 2 ( ( omega_o dot.op upright(bold(n)) ) frac(partial upright(bold(n)), partial x) + frac(partial (omega_o dot.op upright(bold(n))), partial x) upright(bold(n)) ) .
$

#parec[
  Using the properties of the dot product, it can further be shown that
][
  利用点积的性质，可以进一步证明
]

$
  frac(partial (omega_o dot.op upright(bold(n))), partial x) = frac(partial omega_o, partial x) dot.op upright(bold(n)) + omega_o dot.op frac(partial upright(bold(n)), partial x) .
$


#parec[
  The value of $frac(partial omega_o, partial x)$ has already been computed from the difference between the direction of the ray differential's main ray and the direction of the $r_x$ offset ray, and all the other necessary quantities are readily available from the `SurfaceInteraction`.
][
  通过射线微分的主射线方向与 $r_x$ 偏移射线方向的差异， $frac(partial omega_o, partial x)$ 的值已经被计算出来，所有其他必要的量都可以从 `SurfaceInteraction` 中获得。
]

```cpp
<<Compute differential reflected directions>>=
Float dwoDotn_dx = Dot(dwodx, n) + Dot(wo, dndx);
Float dwoDotn_dy = Dot(dwody, n) + Dot(wo, dndy);
rd.rxDirection = wi - dwodx +
    2 * Vector3f(Dot(wo, n) * dndx + dwoDotn_dx * n);
rd.ryDirection = wi - dwody +
    2 * Vector3f(Dot(wo, n) * dndy + dwoDotn_dy * n);
```
#parec[
  A similar process of differentiating the equation for the direction of a specularly transmitted ray, Equation (#link("../Reflection_Models/Specular_Reflection_and_Transmission.html#eq:refracted-direction")[9.4];), gives the equation to find the differential change in the transmitted direction. `pbrt` computes refracted rays as
][
  类似地，对镜面透射射线方向的方程进行微分，方程 (#link("../Reflection_Models/Specular_Reflection_and_Transmission.html#eq:refracted-direction")[9.4];) 给出了求解透射方向微分变化的方程。 `pbrt` 计算折射射线为
]

$ omega_i = - 1 / eta omega_o + [1 / eta (omega_o dot.op upright(bold(n))) - cos theta_i] upright(bold(n)) , $


#parec[
  where $upright(bold(n))$ is flipped if necessary to lie in the same hemisphere as $omega_o$, and where $eta$ is the relative index of refraction from $omega_o$ 's medium to $omega_i$ 's medium.
][
  其中 $upright(bold(n))$ 如果有必要会翻转以与 $omega_o$ 位于同一半球， $eta$ 是从 $omega_o$ 的介质到 $omega_i$ 的介质的相对折射率。
]

#parec[
  If we denote the term in brackets by $mu$, then we have $omega_i = - (1 / eta) omega_o + mu upright(bold(n))$. Taking the partial derivative in $x$, we have
][
  如果我们用 $mu$ 表示括号中的项，那么我们有 $omega_i = - (1 / eta) omega_o + mu upright(bold(n))$。对 $x$ 取偏导，我们得到
]

$
  frac(partial omega_i, partial x) = - 1 / eta frac(partial omega_o, partial x) + mu frac(partial upright(bold(n)), partial x) + frac(partial mu, partial x) upright(bold(n)) .
$<specular-xmit-dwidx>


#parec[
  Using some of the values found from computing specularly reflected ray differentials, we can find that we already know how to compute all of these values except for $frac(partial mu, partial x)$.
][
  通过计算镜面反射射线微分得到的一些值，我们可以发现除了 $frac(partial mu, partial x)$ 之外，我们已经知道如何计算所有这些值。
]

```cpp
<<Compute differential transmitted directions>>=
<<Find oriented surface normal for transmission>>
<<Compute partial derivatives of >>
rd.rxDirection = wi - eta * dwodx + Vector3f(mu * dndx + dmudx * n);
rd.ryDirection = wi - eta * dwody + Vector3f(mu * dndy + dmudy * n);
```

#parec[
  Before we get to the computation of $mu$ 's partial derivatives, we will start by reorienting the surface normal if necessary so that it lies on the same side of the surface as $omega_o$. This matches `pbrt`'s computation of refracted ray direction
][
  在我们进行 $mu$ 的偏导数计算之前，我们将首先在必要时重新定向表面法线，使其位于 $omega_o$ 的同一侧。 这与 `pbrt` 的折射射线方向计算相匹配。
]


```cpp
<<Find oriented surface normal for transmission>>=
if (Dot(wo, n) < 0) {
    n = -n;
    dndx = -dndx;
    dndy = -dndy;
}
```

#parec[
  Returning to $mu$ and considering $frac(partial mu, partial x)$, we have
][
  回到 $mu$ 并考虑 $frac(partial mu, partial x)$，我们得到
]

$
  frac(diff mu, diff x) = frac(diff, diff x) frac(1, eta)( omega_o dot.op upright(bold(n)) ) - frac(diff, diff x) cos theta_i = frac(1, eta) frac(diff(omega_o dot.op upright(bold(n))), diff x) - frac(diff cos theta_i, diff x) .
$


#parec[
  Its first term can be evaluated with already known values. For the second term, we will start with Snell's law, which gives
][
  它的第一项可以用已知的值来评估。对于第二项，我们将从斯涅尔定律开始，它给出
]


$ cos theta_i = sqrt(1 - frac(1 - (omega_o dot.op upright(bold(n)))^2, eta^2)) . $


#parec[
  If we square both sides of the equation and take the partial derivative $frac(partial, partial x)$, we find
][
  如果我们对方程两边平方并取偏导数 $frac(partial, partial x)$，我们得到
]

$
  mat(delim: #none, cos theta_i frac(diff cos theta_i, diff x), = frac(diff, diff x)(1 - frac(1 -(omega_o dot.op upright(bold(n)))^2, eta^2));, = frac(diff, diff x)(frac((omega_o dot.op upright(bold(n)))^2, eta^2)) = frac(2(omega_o dot.op upright(bold(n))), eta^2) frac(diff(omega_o dot.op upright(bold(n))), diff x) .)
$

#parec[
  We now can solve for $frac(partial cos theta_i, partial x)$ :
][
  我们现在可以求解 $frac(partial cos theta_i, partial x)$ ：
]

$
  frac(partial cos theta_i, partial x) = frac(1, 2 cos theta_i) frac(2 (omega_o dot.op upright(bold(n))), eta^2) frac(partial (omega_o dot.op upright(bold(n))), partial x) .
$


#parec[
  Putting it all together and simplifying, we have
][
  将所有部分结合并简化，我们得到
]

$
  frac(partial mu, partial x) = frac(partial (omega_o dot.op upright(bold(n))), partial x) ( 1 / eta + 1 / eta^2 (omega_o dot.op upright(bold(n))) / (omega_i dot.op upright(bold(n))) ) .
$


#parec[
  The partial derivative in $y$ is analogous and the implementation follows.
][
  在 $y$ 中的偏导数是类似的，实施也随之而来。
]

```cpp
<<Compute partial derivatives of >>=
Float dwoDotn_dx = Dot(dwodx, n) + Dot(wo, dndx);
Float dwoDotn_dy = Dot(dwody, n) + Dot(wo, dndy);
Float mu = Dot(wo, n) / eta - AbsDot(wi, n);
Float dmudx = dwoDotn_dx * (1/eta + 1/Sqr(eta) * Dot(wo, n) / Dot(wi, n));
Float dmudy = dwoDotn_dy * (1/eta + 1/Sqr(eta) * Dot(wo, n) / Dot(wi, n));
```

#parec[
  If a ray undergoes many specular bounces, ray differentials sometimes drift off to have very large magnitudes, which can leave a trail of infinite and not-a-number values in their wake when they are used for texture filtering calculations. Therefore, the final fragment in this SpawnRay() method computes the squared length of all the differentials. If any is greater than $10^16$, the ray differentials are discarded and the RayDifferential hasDifferentials value is set to false. The fragment that handles this, `<Squash potentially troublesome differentials>`, is simple and thus not included here.
][
  如果一条光线经历多次镜面反射，光线差分有时会漂移到非常大的幅度，当它们用于纹理过滤计算时，可能会留下无限和非数字值的痕迹。因此，在这个 SpawnRay() 方法的最后一个片段中计算了所有差分的平方长度。如果任何一个大于 $10^16$，则光线差分将被丢弃，并且 RayDifferential 的 hasDifferentials 值被设置为 false。处理此问题的片段 `<Squash potentially troublesome differentials>` 很简单，因此不在此处包含。
]


=== Filtering Texture Functions

#parec[
  To eliminate texture aliasing, it is necessary to remove frequencies in texture functions that are past the Nyquist limit for the texture sampling rate. The goal is to compute, with as few approximations as possible, the result of the ideal texture resampling process, which says that in order to evaluate a texture function $T$ at a point $(x , y)$ on the image without aliasing, we must first band-limit it, removing frequencies beyond the Nyquist limit by convolving it with the sinc filter:
][
  为了消除纹理混叠，有必要去除纹理函数中超过纹理采样率奈奎斯特极限的频率。目标是尽可能少地近似地计算出理想纹理重采样过程的结果，该过程表明，为了在没有混叠的情况下在图像上的点 $(x , y)$ 处评估纹理函数 $T$，我们必须首先对其进行带限，通过与 sinc 滤波器卷积去除超过奈奎斯特极限的频率：
]

$
  T_b (x , y) = integral_(- oo)^oo integral_(- oo)^oo upright("sinc") (x prime) upright("sinc") (y prime) T prime ( f (x - x prime , y - y prime) ) thin d x prime thin d y prime .
$

#parec[
  where, as in Section #link("<sec:finding-tex-sampling-rate>")[10.1.1];, $f (x , y)$ maps pixel locations to points in the texture function's domain. The band-limited function $T_b$ in turn should then be convolved with the pixel filter $g (x , y)$ centered at the $(x , y)$ point on the screen at which we want to evaluate the texture function:
][
  其中，如同在#link("<sec:finding-tex-sampling-rate>")[10.1.1节];中， $f (x , y)$ 将像素位置映射到纹理函数的域中的点。带限函数 $T_b$ 接下来应与像素滤波器 $g (x , y)$ 卷积，该滤波器以我们希望在屏幕上评估纹理函数的 $(x , y)$ 点为中心：
]

$
  T_(upright("ideal")) ( x , y ) = integral_(- "yWidth" \/ 2)^("yWidth" \/ 2) integral_(- "xWidth" \/ 2)^("xWidth" \/ 2) g (x prime , y prime) T_b ( x - x prime , y - y prime ) thin d x prime thin d y prime .
$

#parec[
  This gives the theoretically perfect value for the texture as projected onto the screen. #footnote[One simplification that is present in this ideal
filtering process is the implicit assumption that the texture function
makes a linear contribution to frequency content in the image, so that
filtering out its high frequencies removes high frequencies from the image.
This is true for many uses of textures—for example, if an image map is
used to modulate the diffuse term of a <tt>DiffuseMaterial</tt>.  However, if a
texture is used to determine the roughness of a glossy specular object, for
example, this linearity assumption is incorrect, since a linear change in the
roughness value has a nonlinear effect on the reflected radiance from
the microfacet BRDF.  We will
ignore this issue here, since it is not easily solved in general.  The
“Further Reading” section has more discussion of this topic.]
][
  这给出了纹理投影到屏幕上的理论完美值。 #footnote[这个理想的过滤过程中的一个简化是假设纹理函数对图像中的频率内容作线性贡献，因此过滤掉其高频成分即可去除图像中的高频。这在许多纹理的使用中确实成立——例如，当图像贴图用于调节 `<tt>DiffuseMaterial</tt>` 的漫反射项时。然而，如果纹理用于确定光滑镜面物体的粗糙度，这种线性假设则不再成立，因为粗糙度值的线性变化会对微表面 BRDF 的反射辐射产生非线性影响。我们将在此忽略该问题，因为它在一般情况下不易解决。有关此主题的更多讨论，请参阅“进一步阅读”部分。]
]

#parec[
  In practice, there are many simplifications that can be made to this process. For example, a box filter may be used for the band-limiting step, and the second step is usually ignored completely, effectively acting as if the pixel filter were a box filter, which makes it possible to do the antialiasing work completely in texture space. (The EWA filtering algorithm in Section #link("../Textures_and_Materials/Image_Texture.html#sec:image-map-filtering")[10.4.4] is a notable exception in that it assumes a Gaussian pixel filter.)
][
  在实践中，可以对这个过程进行许多简化。例如，带限步骤可以使用盒式滤波器，而第二步通常完全忽略，实际上就像像素滤波器是盒式滤波器一样，这使得可以在纹理空间中完全进行抗锯齿工作。（第#link("../Textures_and_Materials/Image_Texture.html#sec:image-map-filtering")[10.4.4节];中的EWA过滤算法是一个显著的例外，因为它假设高斯像素滤波器。）
]

#parec[
  Assuming box filters then if, for example, the texture function is defined over parametric $(u , v)$ coordinates, the filtering task is to average it over a region in $(u , v)$ :
][
  假设盒式滤波器，那么例如，如果纹理函数是在参数 $(u , v)$ 坐标上定义的，过滤任务就是在 $(u , v)$ 区域上对其进行平均：
]

$
  T_"box" (x, y) = frac(1,(u_1 - u_0)(v_1 - v_0)) integral_(v_0)^(v_1) integral_(u_0)^(u_1) T( u', v' ) thin d u' thin d v' .
$
#parec[
  The extent of the filter region can be determined using the derivatives from the previous sections—for example, setting
][
  滤波区域的范围可以利用前面章节中的导数来确定——例如，设置
]

$
  T_(b o x) (x , y) = frac(1, (u_1 - u_0) (v_1 - v_0)) integral_(v_0)^(v_1) integral_(u_0)^(u_1) T ( u prime , v prime ) thin d u prime thin d v prime
$


#parec[
  and similarly for $v_0$ and $v_1$ to conservatively specify the box's extent.
][
  对于 $v_0$ 和 $v_1$ 也是类似的，以保守的方式确定盒子的范围。
]

#parec[
  The box filter is easy to use, since it can be applied analytically by computing the average of the texture function over the appropriate region. Intuitively, this is a reasonable approach to the texture filtering problem, and it can be computed directly for many texture functions. Indeed, through the rest of this chapter, we will often use a box filter to average texture function values between samples and informally use the term #emph[filter region] to describe the area being averaged over. This is the most common approach when filtering texture functions.
][
  盒滤波器易于使用，因为它可以通过计算纹理函数在适当区域上的平均值来进行解析应用。直观上，这是一种合理的解决纹理滤波问题的方法，并且可以直接对许多纹理函数进行计算。实际上，在本章的其余部分中，我们将经常使用盒滤波器在样本之间平均纹理函数值，并非正式地使用术语#emph[滤波区域];来描述被平均的区域。这是滤波纹理函数时最常见的方法。
]

#parec[
  Even the box filter, with all of its shortcomings, gives acceptable results for texture filtering in many cases. One factor that helps is the fact that a number of samples are usually taken in each pixel. Thus, even if the filtered texture values used in each one are suboptimal, once they are filtered by the pixel reconstruction filter, the end result generally does not suffer too much.
][
  即使是盒滤波器，尽管有其所有的缺点，在许多情况下也能为纹理滤波提供可接受的结果。一个有帮助的因素是通常在每个像素中采集多个样本。因此，即使每个样本中使用的滤波纹理值不是最佳的，一旦它们被像素重建滤波器进行滤波，最终结果通常不会受到太大影响。
]

#parec[
  An alternative to using the box filter to filter texture functions is to use the observation that the effect of the ideal sinc filter is to let frequency components below the Nyquist limit pass through unchanged but to remove frequencies past it. Therefore, if we know the frequency content of the texture function (e.g., if it is a sum of terms, each one with known frequency content), then if we replace the high-frequency terms with their average values, we are effectively doing the work of the sinc prefilter.
][
  使用盒滤波器来滤波纹理函数的另一种选择是利用理想sinc滤波器的效果，即让低于奈奎斯特极限的频率成分不变地通过，但去除超过该极限的频率。因此，如果我们知道纹理函数的频率内容（例如，如果它是已知频率内容的项的和），那么如果我们用它们的平均值替换高频项，我们实际上是在进行sinc预滤波的工作。
]

#parec[
  Finally, for texture functions where none of these techniques is easily applied, a final option is #emph[supersampling];—the function is evaluated and filtered at multiple locations near the main evaluation point, thus increasing the sampling rate in texture space. If a box filter is used to filter these sample values, this is equivalent to averaging the value of the function. This approach can be expensive if the texture function is complex to evaluate, and as with image sampling, a very large number of samples may be needed to remove aliasing. Although this is a brute-force solution, it is still more efficient than increasing the image sampling rate, since it does not incur the cost of tracing more rays through the scene.
][
  最后，对于那些无法轻松应用这些技术的纹理函数，最后一个选项是#emph[超级采样];——在主评估点附近的多个位置评估和滤波函数，从而增加纹理空间中的采样率。如果使用盒滤波器来滤波这些样本值，这相当于对函数值进行平均。如果纹理函数的评估很复杂，这种方法可能会很昂贵，并且与图像采样一样，可能需要大量样本来消除混叠。尽管这是一种蛮力解决方案，但它仍然比增加图像采样率更有效，因为它不会产生通过场景跟踪更多光线的成本。
]
