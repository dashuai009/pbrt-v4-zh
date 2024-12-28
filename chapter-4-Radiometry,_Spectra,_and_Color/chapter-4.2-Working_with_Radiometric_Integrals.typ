#import "../template.typ": parec, ez_caption

== Working with Radiometric Integrals
<working-with-radiometric-integrals>

#parec[
  A frequent task in rendering is the evaluation of integrals of radiometric quantities. In this section, we will present some tricks that can make it easier to do this. To illustrate the use of these techniques, we will take the computation of irradiance at a point as an example. Irradiance at a point $p$ with surface normal $upright(bold(n))$ due to radiance over a set of directions $Omega$ is
][
  在渲染中，一个常见的任务是评估辐射量度的积分。在本节中，我们将介绍一些可以简化此过程的小技巧。为了展示这些技术的应用，我们将以计算某一点的辐照度为例。由于在一组方向 $Omega$ 上的辐射，表面法线为 $upright(bold(n))$ 的点 $p$ 的辐照度为
]


$
  E (p , upright(bold(n))) = integral_Omega L_i (p , omega) lr(|cos theta|) thin d omega ,
$ <irradiance-from-radiance>

#parec[
  where $L_i (p , omega)$ is the incident radiance function (@fig:irradiance-sphere) and the $cos theta$ factor in the integrand is due to the $d A^tack.t$ factor in the definition of radiance. $theta$ is measured as the angle between $omega$ and the surface normal $upright(bold(n))$. Irradiance is usually computed over the hemisphere $H^2(upright(bold(n)))$ of directions about a given surface normal $upright(bold(n))$.
][
  其中 $L_i (p , omega)$ 是入射辐亮度函数（@fig:irradiance-sphere），积分中的 $cos theta$ 因子是由于辐射定义中的 $d A^tack.t$ 因子。 $theta$ 是 $omega$ 和表面法线 $upright(bold(n))$ 之间的夹角。辐照度通常是在给定表面法线 $upright(bold(n))$ 的半球 $H^2(upright(bold(n)))$ 上计算的。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f05.svg"),
  caption: [
    #parec[Irradiance at a point $p$ is given by the integral of
      radiance times the cosine of the incident direction over the entire
      upper hemisphere above the point.][点 $p$ 处的辐照度由辐射乘以入射方向角的余弦在点上方整个上半球的积分给出。]
  ],
)<irradiance-sphere>

#parec[
  The integral in @eqt:irradiance-from-radiance is with respect to solid angle on the hemisphere and the measure $d omega$ corresponds to surface area on the unit hemisphere. (Recall the definition of solid angle in @solid-angles.)
][
  @eqt:irradiance-from-radiance 中的积分是相对于半球上的立体角进行的，度量 $d omega$ 对应于单位半球上的表面积。（回顾@solid-angles 中立体角的定义。）
]

=== Integrals over Projected Solid Angle
<integrals-over-projected-solid-angle>

#parec[
  The various cosine factors in the integrals for radiometric quantities can often distract from what is being expressed in the integral. This problem can be avoided using #emph[projected solid angle] rather than solid angle to measure areas subtended by objects being integrated over. The projected solid angle subtended by an object is determined by projecting the object onto the unit sphere, as was done for the solid angle, but then projecting the resulting shape down onto the unit disk that is perpendicular to the surface normal (@proj-solid-angle). Integrals over hemispheres of directions with respect to cosine-weighted solid angle can be rewritten as integrals over projected solid angle.
][
  辐射量度积分中的各种余弦因子通常会分散对积分表达内容的关注。使用#emph[立体角投影];而不是立体角来测量被积分对象所覆盖的面积可以避免这个问题。物体所覆盖的立体角投影是通过将物体投影到单位球面上（如同立体角的处理），然后将所得形状投影到垂直于表面法线的单位圆盘上来确定的（@proj-solid-angle）。关于方向半球的积分可以用关于投影立体角的积分重写。
]
#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f06.svg"),
  caption: [
    #ez_caption[ The projected solid angle subtended by an object is the cosine-weighted solid angle that it subtends. It can be computed by finding the object’s solid angle, projecting it down to the plane perpendicular to the surface normal, and measuring its area there. Thus, the projected solid angle depends on the surface normal where it is being measured, since the normal orients the plane of projection.][物体所覆盖的投影立体角是其覆盖的余弦加权立体角。可以通过找到物体的立体角，将其投影到垂直于表面法线的平面上，并在那里测量其面积来计算。因此，投影立体角取决于其被测量的表面法线，因为法线决定了投影平面的方向。
    ]
  ],
)<proj-solid-angle>
#parec[
  The projected solid angle measure is related to the solid angle measure by
][
  投影立体角测量与立体角测量的关系为
]

$
  d omega^perp =|cos theta|thin d omega,
$
#parec[
  so the irradiance-from-radiance integral over the hemisphere can be written more simply as
][
  因此半球上的辐照度积分可以更简单地写为
]

$ E(p, upright(bold(n))) = integral_(cal(H)^2 (upright(bold(n)))) L_i (p, omega) thin d omega^perp . $
#parec[
  For the rest of this book, we will write integrals over directions in terms of solid angle, rather than projected solid angle. In other sources, however, projected solid angle may be used, so it is always important to be aware of the integrand's actual measure.
][
  在本书的其余部分中，我们将用立体角而不是投影立体角来编写方向上的积分。然而，在其他来源中，可能会使用投影立体角，因此了解被积函数的实际测量值始终很重要。
]


=== Integrals over Spherical Coordinates
<integrals-over-spherical-coordinates>

#parec[
  It is often convenient to transform integrals over solid angle into integrals over spherical coordinates $(theta, phi)$ using @eqt:spherical-coordinates. In order to convert an integral over a solid angle to an integral over $(theta, phi)$, we need to be able to express the relationship between the differential area of a set of directions $d omega$ and the differential area of a $(theta, phi)$ pair (@fig:dw-to-dtdp). The differential area on the unit sphere $d omega$ is the product of the differential lengths of its sides, $sin theta d phi$ and $d theta$. Therefore,
][
  将立体角上的积分转换为球坐标 $(theta, phi)$ 上的积分通常很方便，使用@eqt:spherical-coordinates. 为了将立体角上的积分转换为 $(theta, phi)$ 上的积分，我们需要能够表达一组方向的微分面积 $d omega$ 与 $(theta, phi)$ 对的微分面积之间的关系（@fig:dw-to-dtdp）。单位球上的微分面积 $d omega$ 是微分长度的乘积， $sin theta d phi$ and $d theta$。因此，
]

$ d omega = sin theta thin d theta thin d phi.alt . $ <sintheta-dtheta-dphi>


#parec[
  (This result can also be derived using the multidimensional transformation approach from @transformation-in-multiple-dimensions .)
][
  （这个结果也可以通过@transformation-in-multiple-dimensions 中的多维变换方法得出。）
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f07.svg"),
  caption: [
    #parec[The differential area $d omega$ subtended by a
      differential solid angle is the product of the differential lengths of
      the two edges $sin theta d phi.alt$ and $d theta$. The resulting
      relationship, $d omega = sin theta d theta d phi.alt$, is the key to
      converting between integrals over solid angles and integrals over
      spherical angles.][图4.7：由微小立体角所张的微分面积$d omega$是两条边的微分长度$sin theta d phi.alt$和$d theta$的乘积。由此得到的关系式$d omega = sin theta d theta d phi.alt$是将立体角积分转换为球面角积分的关键。]
  ],
)<dw-to-dtdp>

#parec[
  We can thus see that the irradiance integral over the hemisphere, @eqt:irradiance-from-radiance) with $Omega = cal(H)^2 (upright(bold(n)))$, can equivalently be written as
][
  因此，我们可以看到在半球表面上的辐照度积分，方程式(@eqt:irradiance-from-radiance)，其中 $Omega = cal(H)^2 (upright(bold(n)))$，可以等效地写为
]



$
  E (p , upright(bold(n))) = integral_0^(2 pi) integral_0^(pi \/ 2) L_i (
    p , theta , phi.alt
  ) cos theta sin theta d theta d phi.alt .
$

#parec[
  If the radiance is the same from all directions, the equation simplifies to $E = pi L_i$.
][
  如果辐射度从所有方向都是相同的，方程简化为 $E = pi L_i$。
]

=== Integrals over Area
<integrals-over-area>

#parec[
  One last useful transformation is to turn integrals over directions into integrals over area. Consider the irradiance integral in @eqt:irradiance-from-radiance again, and imagine there is a quadrilateral with constant outgoing radiance and that we could like to compute the resulting irradiance at a point $p$. Computing this value as an integral over directions $omega$ or spherical coordinates $(theta , phi.alt)$ is in general not straightforward, since given a particular direction it is nontrivial to determine if the quadrilateral is visible in that direction or $(theta , phi.alt)$. It is much easier to compute the irradiance as an integral over the area of the quadrilateral.
][
  最后一个有用的变换是将方向上的积分转换为面积上的积分。再次考虑@eqt:irradiance-from-radiance 中的辐照度积分，并设想有一个具有恒定出射辐射亮度的四边形，我们希望计算在点 $p$ 的结果辐照度。作为方向 $omega$ 或球面坐标 $(theta , phi.alt)$ 上的积分来计算这个值通常并不简单，因为给定一个特定方向，确定四边形在该方向或 $(theta , phi.alt)$ 上是否可见是复杂的。作为四边形面积上的积分来计算辐照度要容易得多。
]

#parec[
  Differential area $d A$ on a surface is related to differential solid angle as viewed from a point $p$ by
][
  在一个表面上的微分面积 $d A$ 与从点 $p$ 观察到的微小立体角的关系为
]

$ d omega = frac(d A cos theta, r^2) , $ <dw-dA-eqt>

#parec[
  where $theta$ is the angle between the surface normal of $d A$ and the vector to $p$, and $r$ is the distance from $p$ to $d A$ (@fig:dw-dA). We will not derive this result here, but it can be understood intuitively: if $d A$ is at distance~1 from~ $p$ and is aligned exactly so that it is perpendicular to $d omega$, then $d omega = d A$, $theta = 0$, and @eqt:dw-dA-eqt holds. As $d A$ moves farther away from $p$, or as it rotates so that it is not aligned with the direction of $d omega$, the $r^2$ and $cos theta$ factors compensate accordingly to reduce~ $d omega$.
][
  其中 $theta$ 是 $d A$ 的表面法线与指向 $p$ 的向量之间的角度， $r$ 是从 $p$ 到 $d A$ 的距离（@fig:dw-dA）。我们在此不推导这个结果，但可以直观地理解：如果 $d A$ 距离 $p$ 为1并且完全对齐并垂直于 $d omega$，那么 $d omega = d A$， $theta = 0$，@eqt:dw-dA-eqt 成立。当 $d A$ 远离 $p$ 或旋转以便不与 $d omega$ 的方向对齐时， $r^2$ 和 $cos theta$ 因子相应地调整以减少 $d omega$。
]
#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f08.svg"),
  caption: [
    #ez_caption[The differential solid angle $d omega$ subtended by a differential area $d A$ is equal to $d A cos theta \/ r^2$, where $theta$ is the angle between $d A$’s surface normal and the vector to the point $p$ and $r$ is the distance from $p$ to $d A$.][由微分面积$d A$所张的微小立体角$d omega$等于$d A cos theta \/ r^2$，其中$theta$是$d A$的表面法线与指向点$p$的向量之间的角度，$r$是从$p$到$d A$的距离。]
  ],
)<dw-dA>

#parec[
  Therefore, we can write the irradiance integral for the quadrilateral source as
][
  因此，我们可以将四边形光源的辐照度积分写为
]

$ E (p , upright(bold(n))) = integral_A L cos theta_i frac(cos theta_o d A, r^2) , $

#parec[
  where $L$ is the emitted radiance from the surface of the quadrilateral, $theta_i$ is the angle between the surface normal at $p$ and the direction from $p$ to the point $p prime$ on the light, and $theta_o$ is the angle between the surface normal at $p prime$ on the light and the direction from $p prime$ to $p$ (@fig:quad-irradiance).
][
  其中 $L$ 是从四边形表面发出的辐射度， $theta_i$ 是点 $p$ 处的表面法线与从 $p$ 到光源点 $p prime$ 的方向之间的角度， $theta_o$ 是光源点 $p prime$ 处的表面法线与从 $p prime$ 到 $p$ 的方向之间的角度（@fig:quad-irradiance）。
]

#figure(
  image("../pbr-book-website/4ed/Radiometry,_Spectra,_and_Color/pha04f09.svg"),
  caption: [
    #ez_caption[ To compute irradiance at a point $p$ from a quadrilateral source, it is easier to integrate over the surface area of
      the source than to integrate over the irregular set of directions that it subtends. The relationship between solid angles and areas given by @eqt:dw-dA-eqt lets us go back and forth between the two approaches.
    ][
      为了计算点$p$处的四边形光源的辐照度，在光源表面面积上积分比积分其所张的不规则的方向集合要容易。方程式(#link("<eq:dw-dA>")[4.9];)给出的立体角和面积之间的关系让我们可以在这两种方法之间转换。
    ]
  ],
)<quad-irradiance>



$
  E (p , upright(bold(n))) = integral_0^(2 pi) integral_0^(pi \/ 2) L_i (
    p , theta , phi.alt
  ) cos theta sin theta d theta d phi.alt 。
$

