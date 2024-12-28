#import "../template.typ": parec, ez_caption

== 13.1 The Light Transport Equation
<the-light-transport-equation>

#parec[
  The light transport equation (LTE) is the governing equation that describes the equilibrium distribution of radiance in a scene. It gives the total reflected radiance at a point on a surface in terms of emission from the surface, its BSDF, and the distribution of incident illumination arriving at the point. For now we will continue to only consider the case where there are no participating media in the scene, saving those complexities for @light-transport-ii-volume-rendering.
][
  光传输方程（LTE）是描述场景中辐射度平衡分布的控制方程。它通过表面的发射、BSDF以及到达该点的入射光分布来计算表面上某点的总反射辐射度。目前，我们将继续只考虑场景中没有参与介质的情况，将这些复杂性留到@light-transport-ii-volume-rendering 讨论。
]

#parec[
  The detail that makes evaluating the LTE difficult is the fact that incident radiance at a point is affected by the geometry and scattering properties of all the objects in the scene. For example, a bright light shining on a red object may cause a reddish tint on nearby objects in the scene, or glass may focus light into caustic patterns on a tabletop. Rendering algorithms that account for this complexity are often called #emph[global illumination] algorithms, to differentiate them from #emph[local illumination] algorithms that use only information about the local surface properties in their shading computations.
][
  评估LTE的困难之处在于，某点的入射辐射度受到场景中所有物体的几何和散射特性的影响。例如，照在红色物体上的明亮光线可能会使场景中附近的物体呈现红色调，或者玻璃可能会在桌面上聚焦成焦散图案。考虑到这种复杂性的渲染算法通常被称为#emph[全局照明];算法，以区别于仅使用局部表面属性信息进行着色计算的#emph[局部照明];算法。
]

#parec[
  In this section, we will first derive the LTE and describe some approaches for manipulating the equation to make it easier to solve numerically. We will then describe two generalizations of the LTE that make some of its key properties more clear and serve as the foundation for integrators that implement sophisticated light transport algorithms.
][
  在本节中，我们将首先推导LTE，并描述一些便于数值求解的方程操控方法。然后，我们将描述LTE的两个推广，使其一些关键特性更加清晰，并作为实现复杂光传输算法的积分器的基础。
]

=== Basic Derivation
<basic-derivation>

#parec[
  The light transport equation depends on the basic assumptions we have already made in choosing to use radiometry to describe light—that wave optics effects are unimportant and that the distribution of radiance in the scene is in equilibrium.
][
  光传输方程依赖于我们已经做出的基本假设，即选择使用辐射度学来描述光——波动光学效应可以忽略不计，并且场景中的辐射度分布处于平衡状态。
]

#parec[
  The key principle underlying the LTE is #emph[energy balance];. Any change in energy has to be "charged" to some process, and we must keep track of all the energy. Since we are assuming that lighting is a linear process, the difference between the amount of energy going out of a system and the amount of energy coming in must also be equal to the difference between energy emitted and energy absorbed. This idea holds at many levels of scale. On a macro level we have conservation of power:
][
  LTE的核心原则是#emph[能量平衡];。任何能量的变化都必须“归因”于某个过程，我们必须跟踪所有的能量。由于我们假设照明是一个线性过程，系统输出能量与输入能量的差异也必须等于发射能量与吸收能量的差异。这个思想在许多尺度上都成立。在宏观层面上，我们有功率守恒：
]


$ Phi_o - Phi_i = Phi_e - Phi_a . $


#parec[
  The difference between the power leaving an object, $Phi_o$, and the power entering it, $Phi_i$, is equal to the difference between the power it emits and the power it absorbs, $Phi_e - Phi_a$.
][
  物体离开的功率 $Phi_o$ 与进入的功率 $Phi_i$ 之间的差异等于其发射功率与吸收功率之间的差异 $Phi_e - Phi_a$。
]

#parec[
  To enforce energy balance at a surface, exitant radiance $L_o$ must be equal to emitted radiance plus the fraction of incident radiance that is scattered. Emitted radiance is given by $L_e$, and scattered radiance is given by the scattering equation, which gives
][
  为了在表面上确保能量平衡，出射辐射度 $L_o$ 必须等于发射辐射度加上入射辐射度被散射的部分。发射辐射度由 $L_e$ 给出，散射辐射度由散射方程给出，即
]

$
  L_o (p , omega_o) = L_e (p , omega_o) + integral_(S^2) f (p , omega_o , omega_i) L_i ( p , omega_i ) lr(|cos theta_i|) thin d omega_i .
$


#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f01.png"),
  caption: [
    #ez_caption[
      Radiance along a Ray through Free Space Is Unchanged.
      Therefore, to compute the incident radiance along a ray from point $p$
      in direction $omega$, we can find the first surface the ray intersects
      and compute exitant radiance in the direction $- omega$ there. The
      ray-casting function $t (p , omega)$ gives the point $p prime$ on the
      first surface that the ray $(p , omega)$ intersects.
    ][
      自由空间中沿射线的辐射度不变。
      因此，为了计算从点$p$沿方向$omega$的入射辐射度，我们可以找到射线与之相交的第一个表面，并计算该处沿方向$- omega$的出射辐射度。射线投射函数$t (p , omega)$用于计算射线$(p , omega)$与第一个相交表面上的点$p prime$。
    ]
  ],
)<trace-operator>


#parec[
  Because we have assumed for now that no participating media are present, radiance is constant along rays through the scene. We can therefore relate the incident radiance at $p$ to the outgoing radiance from another point $p prime$, as shown by @fig:trace-operator . If we define the #emph[ray-casting
function] $t (p , omega)$ as a function that computes the first surface point $p prime$ intersected by a ray from $p$ in the direction $omega$, we can write the incident radiance at $p$ in terms of outgoing radiance at $p prime$ :
][
  因为我们目前假设没有参与介质存在，辐射度在穿过场景的射线上是恒定的。因此，我们可以将点 $p$ 的入射辐射度与点 $p prime$ 的出射辐射度相关联，如@fig:trace-operator 所示。如果我们将#emph[射线投射函数]; $t (p , omega)$ 定义为一个计算从 $p$ 沿方向 $omega$ 的射线与之相交的第一个表面点 $p prime$ 的函数，我们可以用 $p prime$ 的出射辐射度来表示 $p$ 的入射辐射度：
]

$ L_i (p , omega) = L_o (t (p , omega) , - omega) . $


#parec[
  In case the scene is not closed, we will define the ray-casting function to return a special value $Lambda$ if the ray $(p , omega)$ does not intersect any object in the scene, such that $L_o (Lambda , omega)$ is always 0.
][
  如果场景不是封闭的，我们将定义射线投射函数，使其在射线 $(p , omega)$ 未与场景中的任何物体相交时返回一个特殊值 $Lambda$，使得 $L_o (Lambda , omega)$ 始终为0。
]

#parec[
  Dropping the subscripts from $L_o$ for brevity, this relationship allows us to write the LTE as
][
  为了简洁起见，省略 $L_o$ 的下标，这种关系使我们可以将LTE写为
]

$
  L (p , omega_o) = L_e (p , omega_o) + integral_(S^2) f (p , omega_o , omega_i) L ( t (p , omega_i) , - omega_i ) lr(|cos theta_i|) thin d omega_i .
$<light-transport>


=== Analytic Solutions to the LTE
<analytic-solutions-to-the-lte>

#parec[
  The brevity of the LTE belies the fact that it is impossible to solve analytically other than in very simple cases. The complexity that comes from physically based BSDF models, arbitrary scene geometry, and the intricate visibility relationships among objects all conspire to mandate a numerical solution technique. Fortunately, the combination of ray-tracing algorithms and Monte Carlo integration gives a powerful pair of tools that can handle this complexity without needing to impose restrictions on various components of the LTE (e.g., requiring that all BSDFs be Lambertian or substantially limiting the geometric representations that are supported).
][
  LTE 的简洁性掩盖了这样一个事实：除了在非常简单的情况下，它几乎不可能解析求解。物理基础的双向散射分布函数 (BSDF) 模型、任意场景几何形状以及物体之间复杂的可见性关系所带来的复杂性，要求采用数值解法。幸运的是，光线追踪算法和蒙特卡罗积分的结合提供了一对强大的工具，可以处理这种复杂性，而无需对LTE的各个组成部分施加限制（例如，要求所有BSDF都是朗伯表面或大幅限制支持的几何表示）。
]

#parec[
  It is possible to find analytic solutions to the LTE in very simple settings. While this is of little help for general-purpose rendering, it can help with debugging the implementations of integrators. If an integrator that is supposed to solve the complete LTE does not compute a solution that matches an analytic solution, then clearly there is a bug in the integrator. As an example, consider the interior of a sphere where all points on the surface of the sphere have a Lambertian BRDF, $f (p , omega_o , omega_i) = c$, and also emit a constant amount of radiance in all directions. We have
][
  在非常简单的情况下，可以找到LTE的解析解。虽然这对通用渲染帮助不大，但可以帮助调试积分器的实现。如果一个应该求解完整LTE的积分器没有计算出与解析解匹配的结果，那么显然积分器中存在错误。例如，考虑一个球体内部，其中球体表面上的所有点都有朗伯BRDF， $f (p , omega_o , omega_i) = c$，并且在所有方向上发出恒定量的辐射。我们有
]
$ L (p , omega_o) = L_e + c integral_Omega L (t (p , omega_i) , - omega_i) lr(|cos theta_i|) thin d omega_i . $

#parec[
  The outgoing radiance distribution at any point on the sphere interior must be the same as at any other point; nothing in the environment introduces any variation among different points. Therefore, the incident radiance distribution must be the same at all points, and the cosine-weighted integral of incident radiance must be the same everywhere as well. As such, we can replace the radiance functions with constants and simplify, writing the LTE as
][
  球体内部任意点的出射辐射亮度必须与其他点相同；环境中没有任何东西在不同点之间引入变化。因此，入射辐射分布在所有点上必须相同，入射辐射的余弦加权积分在各处也必须相同。因此，我们可以用常数替换辐射函数并简化，将LTE写为
]

$ L = L_e + c pi L . $
#parec[
  While we could immediately solve this equation for $L$, it is interesting to consider successive substitution of the right hand side into the $L$ term on the right hand side. If we also replace $pi c$ with $rho_(h h)$, the reflectance of a Lambertian surface, we have
][
  虽然我们可以立即求解这个方程的 $L$，但考虑将右侧的 $L$ 项反复替换的过程是有趣的。如果我们还将\$\\\\pi c\$替换为朗伯表面的反射率\$\\ho\_{hh}\$，我们有
]

$
  L & = L_e + rho_(h h) \(L_e + rho_(h h) \(L_e + dots.h.c\
  & = sum_(i = 0)^oo L_e rho_(h h)^i .
$
#parec[
  In other words, exitant radiance is equal to the emitted radiance at the point plus light that has been scattered by a BSDF once after emission, plus light that has been scattered twice, and so forth.
][
  换句话说，出射辐射等于点处的发射辐射加上发射后被BSDF散射一次的光，再加上被散射两次的光，依此类推。
]

#parec[
  Because $rho_(h h) < 1$ due to conservation of energy, the series converges and the reflected radiance at all points in all directions is
][
  由于能量守恒， $rho_(h h) < 1$，因此该级数收敛，所有点在所有方向上的反射辐射为
]
$ L = frac(L_e, 1 - rho_(h h)) . $

#parec[
  (This series is called a #emph[Neumann series];.)
][
  （该级数称为_Neumann级数_。）
]

#parec[
  This process of repeatedly substituting the LTE's right hand side into the incident radiance term in the integral can be instructive in more general cases.#footnote[Indeed, this sort of series
expansion and inversion can be used in the general case, where quantities
like the BSDF are expressed in terms of general operators that map incident
radiance functions to
exitant radiance functions.  This approach forms the foundation for applying
sophisticated tools from analysis to the light transport problem.  See
Arvo's thesis (Arvo 1995a) and Veach's thesis (Veach 1997) for
further information.] For example, only accounting for direct illumination effectively computes the result of making a single substitution:
][
  这种在积分中将LTE的右侧反复替换入入射辐射项的过程在更一般的情况下是有启发性的。#footnote[确实，这种级数展开与求逆的方法可应用于更一般的情形。在该情形下，诸如 BSDF 等量通过将入射辐射度函数映射到出射辐射度函数的通用算子来描述。这一方法为将分析领域的高阶工具引入光传输问题奠定了基础。更多信息可参考 Arvo 的论文（Arvo 1995a）以及 Veach 的论文（Veach 1997）。]，仅考虑直接照明有效地计算了进行一次替换的结果：
]

$
  L (p , omega_o) = L_e (p , omega_o) + integral_(S^2) f (p , omega_o , omega_i) L_d ( p , omega_i ) lr(|cos theta_i|) thin d omega_i ,
$

#parec[
  where
][
  其中
]

$ L_d (p , omega_i) = L_e (t (p , omega_i) , - omega_i) $
#parec[
  and further scattering is ignored.
][
  并忽略进一步的散射。
]

#parec[
  Over the next few pages, we will see how performing successive substitutions in this manner and then regrouping the results expresses the LTE in a more natural way for developing rendering algorithms.
][
  在接下来的几页中，我们将看到如何以这种方式进行连续替换，然后重新组合结果，以更自然的方式表达LTE，以便开发渲染算法。
]

=== The Surface Form of the LTE
<the-surface-form-of-the-lte>
#parec[
  One reason the LTE as written in @eqt:light-transport is complex is that the relationship between geometric objects in the scene is implicit in the ray-tracing function $t (p , omega)$. Making the behavior of this function explicit in the integrand will shed some light on the structure of this equation. To do this, we will rewrite @eqt:light-transport as an integral over #emph[area] instead of an integral over directions on the sphere.
][
  @eqt:light-transport 中的LTE之所以复杂，是因为场景中几何对象之间的关系隐含在光线追踪函数 $t (p , omega)$ 中。将该函数的行为在被积函数中显式化将有助于揭示该方程的结构。为此，我们将@eqt:light-transport 重写为一个关于#emph[面积];的积分，而不是关于球面方向的积分。
]

#parec[
  First, we define exitant radiance from a point $p prime$ to a point $p$ by
][
  首先，我们定义从点 $p prime$ 到点 $p$ 的出射辐射亮度为
]

$
  L(p' -> p) = L(p', omega)
$

#parec[
  if $p'$ and $p$ are mutually visible and $omega = hat(p - p')$. We can also write the BSDF at $p'$ as
][
  如果 $p'$ 和 $p$ 互相可见，并且 $omega = hat(p - p')$。我们还可以在 $p'$ 处表示 BSDF 为
]

$
  f(p^('') arrow.r p' arrow.r p) = f(p', omega_o, omega_i)
$
#parec[
  where $omega_i = hat(p'' - p')$, and $omega_o = hat(p - p')$ (@fig:three-point), This is sometimes called the `three-point form` of the BSDF.
][
  其中 $omega_i = hat(p'' - p')$, and $omega_o = hat(p - p')$， @fig:three-point，这有时被称为 BSDF 的 _三点形式_。
]


#figure(
  image("../pbr-book-website/4ed/Light_Transport_I_Surface_Reflection/pha13f02.svg"),
  caption: [
    #ez_caption[
      The three-point form of the light transport equation converts the integral to be over the domain of points on surfaces in the scene, rather than over directions on the sphere. It is a key transformation for deriving the path integral form of the light transport equation.
    ][
      光传输方程的三点形式将积分转换为场景中表面上的点域上的积分，而不是球体上方向上的积分。它是推导光传输方程路径积分形式的关键变换。
    ]
  ],
)<three-point>


#parec[
  Rewriting the terms in the LTE in this manner is not quite enough, however. We also need to multiply by the Jacobian that relates solid angle to area in order to transform the LTE from an integral over direction to one over surface area. Recall that this is $|cos theta'|\/ r^2$.
][
  但是，以这种方式重写 LTE 中的项还不够。我们还需要乘以将立体角与面积相关联的雅可比矩阵，以将 LTE 从对方向的积分转换为对表面积的积分。请记住，这是 $|cos theta'|\/ r^2$。
]

#parec[
  We will combine this change-of-variables term, the original $cos theta$ term from the LTE, and a binary visibility function $V$ ( $V = 1$ ) if the two points are mutually visible, and $V = 0$ otherwise) into a single geometric coupling term, $G(p arrow.l.r p')$ :
][
  我们将这个变量替换项、LTE 中的原始 $cos theta$ 项，以及一个二元可见性函数 $V$ （如果两点互相可见，则 $V = 1$，否则 $V = 0$ ）组合成一个单一的几何耦合项， $G(p arrow.l.r p')$ ：
]

$
  G(p arrow.l.r p') = V(p arrow.l.r p') frac(|cos theta| |cos theta'|,||p - p'||^2)
$<g-definition>

#parec[
  Substituting these into the light transport equation and converting to an area integral, we have the three-point form of the LTE,
][
  将这些代入光传输方程并转换为面积积分，我们得到 LTE 的三点形式，
]

$
  L(p' arrow.r p) = L_e (p' arrow.r p) + integral_A f(p^('') arrow.r p' arrow.r p) L(p^('') arrow.r p') G(p^('') arrow.l.r p') thin d A(p^(''))
$<LTE-surface-form>

#parec[
  where $A$ is all the surfaces of the scene.
][
  其中 $A$ 是场景的所有表面。
]

#parec[
  Although @eqt:light-transport and @eqt:LTE-surface-form are equivalent, they represent two different ways of approaching light transport. To evaluate @eqt:light-transport with Monte Carlo, we would sample directions from a distribution of directions on the sphere and cast rays to evaluate the integrand. For @eqt:LTE-surface-form , however, we would sample points on surfaces according to a distribution over surface area and compute the coupling between those points to evaluate the integrand, tracing rays to evaluate the visibility term $V (p arrow.l.r p prime)$.
][
  虽然@eqt:light-transport 和 @eqt:LTE-surface-form 是等价的，但它们代表了两种不同的光传输方法。 为了用蒙特卡洛方法评估@eqt:light-transport，我们将从球面上的方向分布中采样方向并投射光线以评估被积函数。 然而，对于@eqt:LTE-surface-form ，我们将根据表面积上的分布在表面上采样点，并计算这些点之间的耦合以评估被积函数，追踪光线以评估可见性项 $V (p arrow.l.r p prime)$。
]

=== Integral over Paths
<integral-over-paths>


#parec[
  With the area integral form of @eqt:LTE-surface-form , we can derive a more flexible form of the LTE known as the #emph[path integral] formulation of light transport, which expresses radiance as an integral over paths that are themselves points in a high-dimensional #emph[path space];. One of the main motivations for using path space is that it provides an expression for the value of a measurement as an explicit integral over paths, as opposed to the unwieldy recursive definition resulting from the energy balance @eqt:light-transport.
][
  通过@eqt:LTE-surface-form 的面积积分形式，我们可以推导出一种更灵活的光传输方程形式，称为光传输的#emph[路径积分];形式，它将辐射度表示为在高维#emph[路径空间];中路径上的积分。 使用路径空间的主要动机之一是它为测量值提供了一个明确的路径积分表达式，而不是由能量平衡@eqt:light-transport 导致的繁琐递归定义。
]


#parec[
  The explicit form allows for considerable freedom in how these paths are found—essentially any technique for randomly choosing paths can be turned into a workable rendering algorithm that computes the right answer given a sufficient number of samples. This form of the LTE provides the foundation for bidirectional light transport algorithms.
][
  这种明确的形式允许在如何找到这些路径上有相当大的自由度——基本上任何随机选择路径的技术都可以转化为一个可行的渲染算法，只要给出足够数量的样本就能计算出正确的答案。 这种光传输方程形式为双向光传输算法提供了基础。
]


#parec[
  To go from the area integral to a sum over path integrals involving light-carrying paths of different lengths, we can start to expand the three-point light transport equation, repeatedly substituting the right hand side of the equation into the $L (p prime.double arrow.r p prime)$ term inside the integral. Here are the first few terms that give incident radiance at a point $p_0$ from another point $p_1$, where $p_1$ is the first point on a surface along the ray from $p_0$ in direction $p_1 - p_0$ :
][
  为了从面积积分转变为涉及不同长度光路径的路径积分的和，我们可以开始展开三点光传输方程，反复将方程右侧代入积分中的 $L (p prime.double arrow.r p prime)$ 项。 以下是给出从点 $p_0$ 到另一个点 $p_1$ 的入射辐射度的前几个项，其中 $p_1$ 是沿着从 $p_0$ 出发并指向 $p_1 - p_0$ 方向的光线在表面上的第一个点：
]

$
  L(p_1 arrow.r p_0) & = L_e (p_1 arrow.r p_0) \
  & quad + integral_A L_e (p_2 arrow.r p_1) f(p_2 arrow.r p_1 arrow.r p_0) G(p_2 arrow.l.r p_1) thin d A(p_2) \
  & quad + integral_A integral_A L_e (p_3 arrow.r p_2) f(p_3 arrow.r p_2 arrow.r p_1) G(p_3 arrow.l.r p_2) \
  & quad times f(p_2 arrow.r p_1 arrow.r p_0) G(p_2 arrow.l.r p_1) thin d A(p_3) thin d A(p_2) + dots.c
$
#parec[
  Each term on the right side of this equation represents a path of increasing length. For example, the third term is illustrated in @fig:path-two-bounces . This path has four vertices, connected by three segments. The total contribution of all such paths of length four (i.e., a vertex at the camera, two vertices at points on surfaces in the scene, and a vertex on a light source) is given by this term. Here, the first two vertices of the path, $p_0$ and $p_1$, are predetermined based on the camera ray origin and the point that the camera ray intersects, but $p_2$ and $p_3$ can vary over all points on surfaces in the scene. The integral over all such $p_2$ and $p_3$ gives the total contribution of paths of length four to radiance arriving at the camera.
][
  这个方程右侧的每一项代表一个长度递增的路径。 例如，第三项在@fig:path-two-bounces 中进行了说明。 该路径有四个顶点，由三个段连接。 所有此类长度为四的路径（即，相机处的一个顶点，场景中表面上的两个顶点，以及光源上的一个顶点）的总贡献由该项给出。 在这里，路径的前两个顶点 $p_0$ 和 $p_1$ 是基于相机光线起点和相机光线交点预定的，但 $p_2$ 和 $p_3$ 可以在场景中所有表面上的点上变化。 对所有此类 $p_2$ 和 $p_3$ 的积分给出了到达相机的辐射度的长度为四的路径的总贡献。
]

#figure(
  image("../pbr-book-website/4ed/Light_Sources/pha12f03.svg"),
  caption: [
    #ez_caption[
      The integral over all points $upright(p)_2$ and $upright(p)_3$ on surfaces in the scene given by the light transport equation gives the total contribution of two bounce paths to radiance leaving $upright(p)_1$ in the direction of $upright(p)_0$. The components of the product in the integrand are shown here: the emitted radiance from the light, $L_e$; the geometric terms between vertices, $G$; and scattering from the BSDFs, $f$.
    ][
      根据光传输方程，对场景中表面上的所有点 $upright(p)_2$ 和 $upright(p)_3$ 的积分给出了两次反射路径对从 $upright(p)_1$ 沿 $upright(p)_0$ 方向出射辐射亮度的总贡献。被积表达式中的各个组成部分如下：来自光源的出射辐射亮度 $L_e$；顶点之间的几何项 $G$；以及由 BSDF 描述的散射项 $f$。
    ]
  ],
)<path-two-bounces>

#parec[
  This infinite sum can be written compactly as $L (p_1 arrow.r p_0)$.
][
  这个无限和可以简洁地写为 $L (p_1 arrow.r p_0)$。
]


$ L (upright( p )_1 arrow.r upright(p)_0) = sum_(n = 1)^oo P (overline(upright(p))_n) . $<LTE-path-integral>

#parec[
  $P (overline(upright(p))_n)$ gives the amount of radiance scattered over a path $overline(upright(p))_n$ with $n + 1$ vertices,
][
  $P (overline(upright(p))_n)$ 表示沿路径 $overline(upright(p))_n$ 上散射的辐射亮度，该路径有 $n + 1$ 个顶点，
]

$ overline(upright(p))_n = upright(p)_0 , upright(p)_1 , dots.h , upright(p)_n , $


#parec[
  where $p_0$ is on the film plane or front lens element and $p_n$ is on a light source, and
][
  其中 $p_0$ 位于胶片平面或前镜头元件上， $p_n$ 位于光源上，并且
]

$
  P( macron(p)_n) =& underbrace(integral_A integral_A dots.c integral_A, "n-1") L_e (p_n arrow.r p_(n - 1)) \ & times(product_(i = 1)^(n - 1) f(p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) G(p_(i + 1) arrow.l.r p_i)) d A(p_2) dots.c d A(p_n)
$<pathcontrib-definition>

#parec[
  Before we move on, we will define one additional term that will be helpful in the subsequent discussion. The product of a path's BSDF and geometry terms is called the #emph[throughput] of the path; it describes the fraction of radiance from the light source that arrives at the camera after all the scattering at vertices between them. We will denote it by
][
  在继续之前，我们将定义一个额外的术语，这将在后续讨论中有所帮助。 路径的 BSDF 和几何项的乘积被称为路径的 #emph[传输率];；它描述了从光源到达相机的辐射亮度在经过所有顶点的散射后到达相机的比例。 我们将其表示为
]

$
  T (overline(upright(p))_n) = product_(i = 1)^(n - 1) f ( upright(p)_(i + 1) arrow.r upright(p)_i arrow.r upright(p)_(i - 1) ) G (upright(p)_(i + 1) arrow.l.r upright(p)_i) ,
$


#parec[
  so
][
  因此
]

$
  P ( overline(upright(p))_n ) = underbrace(integral_A integral_A dots.h.c integral_A, "n-1") L_e (upright(p)_n arrow.r upright(p)_(n - 1)) T ( overline(upright(p))_n ) thin d A (upright(p)_2) dots.h.c d A (upright(p)_n) .
$


#parec[
  Given @eqt:LTE-path-integral and a particular length $n$, all that we need to do to compute a Monte Carlo estimate of the radiance arriving at $upright(p)_0$ due to paths of length $n$ is to sample a set of vertices with an appropriate sampling density, $macron(upright(p))_n tilde.op p$, to generate a path and then to evaluate an estimate of $P(macron(upright(p))_n)$ using those vertices:
][
  给定@eqt:LTE-path-integral 和特定长度 $n$，我们需要做的就是计算到达 $upright(p)_0$ 的辐射亮度的蒙特卡罗估计，通过路径长度为 $n$ 的路径来实现。为此，我们需要以适当的采样密度 $macron(upright(p))_n tilde.op p$ 采样一组顶点来生成路径，然后使用这些顶点评估 $P(macron(upright(p))_n)$ 的估计值：
]

$
  L ( upright(p)_1 arrow.r upright(p)_0 ) approx sum_(n = 1)^oo frac(P (overline(upright(p))_n), p (overline(upright(p))_n)) .
$


#parec[
  Whether we generate those vertices by starting a path from the camera, starting from the light, starting from both ends, or starting from a point in the middle is a detail that only affects how the path probability $p(macron(upright(p))_n)$ is computed. We will see how this formulation leads to practical light transport algorithms throughout this and the following chapters.
][
  无论我们是从相机开始生成这些顶点，从光源开始，从两端开始，还是从中间的某个点开始，这只是影响路径概率 $p(macron(upright(p))_n)$ 如何计算的细节。 我们将在本章及后续章节中看到这种公式如何导致实用的光传输算法。
]

=== Delta Distributions in the Integrand
<delta-distributions-in-the-integrand>

#parec[
  Delta functions may be present in $P(macron(upright(p))_i)$ terms due not only to certain types of light sources (e.g., point lights and directional lights) but also to BSDF components described by delta distributions. If present, these distributions need to be handled explicitly by the light transport algorithm. For example, it is impossible to randomly choose an outgoing direction from a point on a surface that would intersect a point light source; instead, it is necessary to explicitly choose the single direction from the point to the light source if we want to be able to include its contribution. (The same is true for sampling BSDFs with delta components.) While handling this case introduces some additional complexity to the integrators, it is generally welcome because it reduces the dimensionality of the integral to be evaluated, turning parts of it into a plain sum.
][
  在 $P(macron(upright(p))_i)$ 项中可能存在 Delta 函数，这不仅是由于某些类型的光源（例如点光源和方向光源），还因为由 Delta 分布描述的 BSDF 组件。 如果存在，这些分布需要由光传输算法显式处理。 例如，不可能随机选择一个从表面上的点出射的方向以与点光源相交；相反，如果我们想要包括其贡献，则必须显式选择从该点到光源的单一方向。 （对于具有 delta 组件的 BSDF 采样也是如此。） 虽然处理这种情况给积分器引入了一些额外的复杂性，但通常是受欢迎的，因为它减少了需要评估的积分的维度，将部分积分转化为简单的求和。
]

#parec[
  For example, consider the direct illumination term, $P(macron(upright(p))_2)$, in a scene with a single point light source at point $upright(p)_"light"$ described by a delta distribution:
][
  例如，考虑场景中一个由 δ 分布描述的单点光源在点 $P(macron(upright(p))_2)$ 处的直接照明项 $upright(p)_"light"$ ：
]


$
  P (overline(upright(p))_2) &= integral_A L_e (upright(p)_2 arrow.r upright(p)_1) f (upright(p)_2 arrow.r upright(p)_1 arrow.r upright(p)_0) G (upright(p)_2 arrow.l.r upright(p)_1) thin d A ( upright(p)_2 )\
  &= frac(delta (upright(p)_(upright("light")) - upright(p)_2) L_e (upright(p)_(upright("light")) arrow.r upright(p)_1), upright(p) (upright(p)_(upright("light")))) f ( upright(p)_2 arrow.r upright(p)_1 arrow.r upright(p)_0 ) G (upright(p)_2 arrow.l.r upright(p)_1) .
$

#parec[
  In other words, $upright(p)_2$ must be the light's position in the scene; the delta distribution in the numerator cancels out due to an implicit delta distribution in $p (upright(p)_(upright("light")))$ (recall the discussion of sampling Dirac delta distributions in @light-interface), and we are left with terms that can be evaluated directly, with no need for Monte Carlo. An analogous situation holds for BSDFs with delta distributions in the path throughput $T (overline(upright(p))_n)$ ; each one eliminates an integral over area from the estimate to be computed.
][
  换句话说， $upright(p)_2$ 必须是场景中光源的位置；分子中的 delta 分布由于 $p (upright(p)_(upright("light")))$ 中的隐式 delta 分布而被抵消（回忆在@light-interface 中关于采样 Dirac delta 分布的讨论），剩下的项可以直接评估，无需使用蒙特卡罗方法。对于路径通量 $T (overline(upright(p))_n)$ 中具有 delta 分布的 BSDF 也有类似的情况；每一个都消除了估计中对面积的积分。
]

=== Partitioning the Integrand

#parec[
  Many rendering algorithms have been developed that are particularly good at solving the LTE under some conditions but do not work well (or at all) under others. For example, Whitted's original ray-tracing algorithm only handles specular reflection from delta distribution BSDFs and ignores multiply scattered light from diffuse and glossy BSDFs.
][
  许多渲染算法在某些条件下特别擅长解决 LTE，但在其他条件下效果不佳（或根本不起作用）。例如，Whitted 的原始光线追踪算法仅处理来自 delta 分布 BSDF 的镜面反射，并忽略来自漫反射和光泽 BSDF 的多次散射光。
]

#parec[
  Because we would like to be able to derive correct light transport algorithms that account for all possible modes of scattering without ignoring any contributions and without double-counting others, it is important to pay attention to which parts of the LTE a particular solution method accounts for. A nice way of approaching this problem is to partition the LTE in various ways. For example, we might expand the sum over paths to
][
  因为我们希望能够推导出正确的光传输算法，考虑所有可能的散射模式而不忽略任何贡献，也不重复计算其他贡献，所以重要的是要注意特定解决方法考虑了 LTE 的哪些部分。解决这个问题的一个不错的方法是以各种方式分割 LTE。例如，我们可以将路径上的和展开为
]

$
  L (upright(p)_1 arrow.r p_0) = P (overline(upright(p))_1) + P (overline(upright(p))_2) + sum_(i = 3)^oo P (overline(upright(p))_i) ,
$

#parec[
  where the first term is trivially evaluated by computing the emitted radiance at $p_1$, the second term is solved with an accurate direct lighting solution technique, but the remaining terms in the sum are handled with a faster but less accurate approach. If the contribution of these additional terms to the total reflected radiance is relatively small for the scene we are rendering, this may be a reasonable approach to take. The only detail is that it is important to be careful to ignore $P (overline(p)_1)$ and $P (overline(p)_2)$ with the algorithm that handles $P (overline(p)_3)$ and beyond (and similarly with the other terms).
][
  其中第一个项通过计算在 $p_1$ 处的发射辐射率来简单评估，第二个项通过精确的直接照明解决技术解决，但和中的其余项通过更快但不太精确的方法处理。如果这些附加项对我们正在渲染的场景的总反射辐射率的贡献相对较小，这可能是一个合理的方法。唯一的细节是重要的是要小心忽略处理 $P (overline(p)_3)$ 及其后的算法中的 $P (overline(p)_1)$ 和 $P (overline(p)_2)$ （以及其他项）。
]

#parec[
  It is also useful to partition individual $P (overline(p)_n)$ terms. For example, we might want to split the emission term into emission from small light sources, $L_(e , s)$, and emission from large light sources, $L_(e , l)$, giving us two separate integrals to estimate:
][
  还可以对单个 $P (overline(p)_n)$ 项进行分割。例如，我们可能希望将发射项分为小光源的发射 $L_(e , s)$ 和大光源的发射 $L_(e , l)$，从而得到两个单独的积分来估计：
]

$
  P (overline(p)_n) = integral_(A^(n - 1)) (L_(e , s) (p_n arrow.r p_(n - 1)) + L_(e , l) (p_n arrow.r p_(n - 1))) T ( overline(p)_n ) thin d A (p_2) dots.h.c thin d A (p_n)\
  = integral_(A^(n - 1)) L_(e , s) (p_n arrow.r p_(n - 1)) T (overline(p)_n) thin d A (p_2) dots.h.c thin d A (p_n)\
  + integral_(A^(n - 1)) L_(e , l) (p_n arrow.r p_(n - 1)) T (overline(p)_n) thin d A (p_2) dots.h.c thin d A (p_n) .
$

#parec[
  The two integrals can be evaluated independently, possibly using completely different algorithms or different numbers of samples, selected in a way that handles the different conditions well. As long as the estimate of the $L_(e , s)$ integral ignores any emission from large lights, the estimate of the $L_(e , l)$ integral ignores emission from small lights, and all lights are categorized as either "large" or "small," the correct result is computed in the end.
][
  这两个积分可以独立评估，可能使用完全不同的算法或不同数量的样本，以良好地处理不同的条件。只要 $L_(e , s)$ 积分的估计忽略了来自大光源的发射， $L_(e , l)$ 积分的估计忽略了来自小光源的发射，并且所有光源都被分类为“大”或“小”，最终就能计算出正确的结果。
]

#parec[
  Finally, the BSDF terms can be partitioned as well (in fact, this application was the reason BSDF categorization with `BxDFFlags` values was introduced in @BxDF_Interface . For example, if $f_Delta$ denotes components of the BSDF described by delta distributions and $f_(not Delta)$ denotes the remaining components,
][
  最后，BSDF 项也可以进行分割（事实上，这种应用是引入 `BxDFFlags` 值进行 BSDF 分类的原因，见@BxDF_Interface 节）。例如，如果 $f_Delta$ 表示由 delta 分布描述的 BSDF 组件， $f_(not Delta)$ 表示其余组件，
]

$
  P (overline(p)_n) = integral_(A^(n - 1)) & L_e (p_n arrow.r p_(n - 1))\
  & times product_(i = 1)^(n - 1) ( f_Delta (p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) + f_(not Delta) (p_(i + 1) arrow.r p_i arrow.r p_(i - 1)) )\
  & times G (p_(i + 1) arrow.l.r p_i) thin d A (p_2) dots.h.c thin d A (p_n) .
$


#parec[
  Note that because there are $n - 1$ BSDF terms in the product, it is important to be careful not to count only terms with just $f_Delta$ components or just $f_(not Delta)$ components; all the mixed terms like $f_Delta f_(not Delta) f_(not Delta)$ must be accounted for as well if a partitioning scheme like this is used.
][
  注意，因为在乘积中有 $n - 1$ 个 BSDF 项，所以重要的是要小心不要只计算仅包含 $f_Delta$ 组件或仅包含 $f_(not Delta)$ 组件的项；如果使用这样的分割方案，所有混合项如 $f_Delta f_(not Delta) f_(not Delta)$ 也必须被考虑在内。
]


