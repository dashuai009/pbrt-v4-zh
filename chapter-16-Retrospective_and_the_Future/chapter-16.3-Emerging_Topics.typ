#import "../template.typ": parec, ez_caption

== Emerging Topics
#parec[
  Rendering research continues to be a vibrant field, as should be evident by the length of the "Further Reading" sections at the conclusions of the previous chapters. In addition to the topics discussed earlier, there are two important emerging areas of rendering research that we have not covered in this book—inverse and differentiable rendering and the use of machine learning techniques in image synthesis.

  Work in these areas is progressing rapidly, and so we believe that it would be premature to include implementations of associated techniques in `pbrt` and to discuss them in the book text; whichever algorithms we chose would likely be obsolete in a year or two. However, given the amount of activity in these areas, we will briefly summarize the landscape of each.
][
  渲染研究依然是一个充满活力的领域，这一点从前几章结尾的“进一步阅读”部分的篇幅中应该可以看出。 除了之前讨论的主题外，还有两个重要的新兴渲染研究领域我们在本书中没有涉及——逆向渲染与可微渲染，以及在图像合成中使用机器学习技术。 这些领域的工作正在迅速发展，因此我们认为在 `pbrt` 中包含相关技术的实现并在书中讨论它们为时过早；无论我们选择哪种算法，可能在一两年内就会过时。 然而，鉴于这些领域的活跃程度，我们将简要总结每个领域的概况。
]

=== Inverse and Differentiable Rendering

#parec[
  This book has so far focused on #emph[forward] rendering, in which rendering algorithms convert an input scene description (" $x$ ") into a synthetic image (" $y$ ") taken in the corresponding virtual world. Assuming that the underlying computation is consistent across runs, we can think of the entire process as the evaluation of an intricate function $f : cal(X) arrow.r cal(Y)$ satisfying $f (x) = y$. The main appeal of physically based forward-rendering methods is that they account for global light transport effects, which improves the visual realism of the output $y$.
][
  本书迄今为止专注于正向渲染（forward rendering），其中渲染算法将输入场景描述（" $x$ "）转换为在相应虚拟世界中拍摄的合成图像（" $y$ "）。 假设底层计算在多次运行中是一致的，我们可以将整个过程视为一个复杂函数 $f : cal(X) arrow.r cal(Y)$ 的评估，满足 $f (x) = y$。 物理基础的正向渲染方法的主要吸引力在于它们考虑了全局光传输效应，从而提高了输出 $y$ 的视觉真实感。
]

#parec[
  However, many applications instead require an #emph[inverse] $f^(- 1) (y) = x$ to infer a scene description $x$ that is consistent with a given image $y$, which may be a real-world photograph. Examples of disciplines where such inverses are needed include autonomous driving, robotics, biomedical imaging, microscopy, architectural design, and many others.
][
  然而，许多应用需要一个逆向 $f^(- 1) (y) = x$ 来推断与给定图像 $y$ 一致的场景描述 $x$，该图像可能是现实世界的照片。 需要这种逆向的学科示例包括自动驾驶、机器人、生物医学成像、显微镜、建筑设计等许多领域。
]

#parec[
  Evaluating $f^(- 1)$ is a surprisingly difficult and ambiguous problem: for example, a bright spot on a surface could be alternatively explained by texture or shape variation, illumination from a light source, focused reflection from another object, or simply shadowing at all other locations. Resolving this ambiguity requires multiple observations of the scene and reconstruction techniques that account for the interconnected nature of light transport and scattering. In other words, physically based methods are not just desirable—they are a prerequisite.
][
  评估 $f^(- 1)$ 是一个出乎意料的困难和模糊的问题：例如，表面上的一个亮点可以通过纹理或形状变化、光源照明、来自其他物体的聚焦反射或仅仅是其他位置的阴影来解释。 解决这种模糊性需要对场景进行多次观察和重建技术，以考虑光传输和散射的相互关联性。 换句话说，物理基础的方法不仅是可取的——它们是必需的。
]

#parec[
  Directly inverting $f$ is possible in some cases, though doing so tends to involve drastic simplifying assumptions: consider measurements taken by an X-ray CT scanner, which require further processing to reveal a specimen's interior structure. (X-rays are electromagnetic radiation just like visible light that are simply characterized by much shorter wavelengths in the 0.1–10nm range.) Standard methods for this reconstruction assume a purely absorbing medium, in which case a 3D density can be found using a single pass over all data. However, this approximate inversion leads to artifacts when dense bone or metal fragments reflect some of the X-rays.
][
  在某些情况下，直接反转 $f$ 是可能的，尽管这样做往往涉及剧烈的简化假设：考虑 X 射线 CT 扫描仪获取的测量数据，这需要进一步处理以揭示标本的内部结构。 （X 射线是电磁辐射，就像可见光，只是其波长在 0.1–10nm 范围内要短得多。） 这种重建的标准方法假设一个纯吸收介质，在这种情况下，可以通过对所有数据进行单次处理来找到 3D 密度。 然而，这种近似反演会导致当密集的骨头或金属碎片反射一些 X 射线时产生伪影。
]

#parec[
  The function $f$ that is computed by a physically based renderer like `pbrt` is beyond the reach of such an explicit inversion. Furthermore, a scene that perfectly reproduces images seen from a given set of viewpoints may not exist at all. Inverse rendering methods therefore pursue a relaxed minimization problem of the form
][
  由像 `pbrt` 这样的物理基础渲染器计算的函数 $f$ 超出了这种显式反演的范围。 此外，可能根本不存在一个完美再现从给定视点集看到的图像的场景。 因此，逆向渲染方法追求如下形式的放松最小化问题
]

$ x^* = "argmin"_(x in cal(X)) g(f(x)), $<inverse-rendering>

#parec[
  where $g : cal(Y) arrow.r upright(bold(R))$ refers to a #emph[loss
function] that quantifies the quality of a rendered image of the scene $x$.
][
  其中 $g : cal(Y) arrow.r upright(bold(R))$ 指的是一个_损失函数（loss
  function）_，用于量化场景 $x$ 的渲染图像的质量。
]

#parec[
  For example, the definition $g (y prime) = parallel y prime - y parallel$ could be used to measure the $L_2$ distance to a reference image $y$. This type of optimization is often called #emph[analysis-by-synthesis] due to the reliance on repeated simulation (synthesis) to gain understanding about an inverse problem. The approach easily generalizes to simultaneous optimization of multiple viewpoints. An extra #emph[regularization] term $R (x)$ depending only on the scene parameters is often added on the right hand side to encode prior knowledge about reasonable parameter ranges. Composition with further computation is also possible: for example, we could alternatively optimize $g (f (N (w)))$, where $x = N (w)$ is a neural network that produces the scene $x$ from learned parameters $w$.
][
  例如，定义 $g (y prime) = parallel y prime - y parallel$ 可以用来测量到参考图像 $y$ 的 $L_2$ 距离。 由于依赖于重复模拟（合成）以获得对逆问题的理解，这种类型的优化通常被称为通过合成进行分析。 该方法很容易推广到多个视点的同时优化。 通常在右侧添加一个仅依赖于场景参数的额外正则化项（regularization term） $R (x)$，以编码关于合理参数范围的先验知识。 也可以进行进一步计算的组合：例如，我们可以选择优化 $g (f (N (w)))$，其中 $x = N (w)$ 是一个从学习参数 $w$ 生成场景 $x$ 的神经网络。
]

#parec[
  Irrespective of such extensions, the nonlinear optimization problem in @eqt:inverse-rendering remains too challenging to solve in one step and must be handled using iterative methods. The usual caveats about their use apply here: iterative methods require a starting guess and may not converge to the optimal solution. This means that selecting an initial configuration and incorporating prior information (valid parameter ranges, expected smoothness of the solution, etc.) are both important steps in any inverse rendering task. The choice of loss $g : cal(Y) arrow.r upright(bold(R))$ and parameterization of the scene can also have a striking impact on the convexity of the optimization task (for example, direct optimization of triangle meshes tends to be particularly fragile, while implicit surface representations are better behaved).
][
  无论这些扩展如何， @eqt:inverse-rendering 中的非线性优化问题仍然太难以一步解决，必须使用迭代方法（iterative methods）处理。 关于其使用的通常警告在此适用：迭代方法需要一个初始猜测，可能无法收敛到最优解。 这意味着选择初始设置和结合先验信息（有效参数范围、预期解的平滑性等）是任何逆向渲染任务中的重要步骤。 损失 $g : cal(Y) arrow.r upright(bold(R))$ 的选择和场景的参数化也会对优化任务的凸性（convexity）产生显著影响（例如，直接优化三角网格往往特别脆弱，而隐式表面表示（implicit surface representations）则表现更好）。
]

#parec[
  Realistic scene descriptions are composed of millions of floating-point values that together specify the shapes, BSDFs, textures, volumes, light sources, and cameras. Each value contributes a degree of freedom to an extremely high-dimensional optimization domain (for example, a quadrilateral with a $768 times 768$ RGB image map texture adds roughly 1.7 million dimensions to $cal(X)$ ). Systematic exploration of a space with that many dimensions is not possible, making gradient-based optimization the method of choice for this problem. The gradient is invaluable here because it provides a direction of steepest descent that can guide the optimization toward higher-quality regions of the scene parameter space.
][
  真实的场景描述由数百万个浮点数值组成，这些值共同指定了形状、BSDF、纹理、体积、光源和相机。 每个值都为一个极高维度的优化域贡献了一个自由度（degree of freedom）（例如，一个带有 $768 times 768$ RGB 图像贴图纹理的四边形（quadrilateral）大约为 $cal(X)$ 增加了 170 万个维度）。 系统地探索一个具有如此多维度的空间是不可能的，使得梯度优化成为解决此问题的首选方法。 梯度在这里非常有价值，因为它提供了一个最陡下降（steepest descent）的方向，可以引导优化朝向场景参数空间的更高质量区域。
]

#parec[
  Let us consider the most basic gradient descent update equation for this problem:
][
  让我们考虑这个问题的最基本的梯度下降更新方程：
]

$ x arrow.l x - alpha frac(partial, partial x) g (f (x)) , $<gradient-descent>

#parec[
  where $alpha$ denotes the step size. A single iteration of this optimization can be split into four individually simpler steps via the chain rule:
][
  其中 $alpha$ 表示步长（step size）。 此优化的单次迭代可以通过链式法则（chain rule）分为四个相对简单的步骤：
]

$
  y & arrow.l f (x) ,\
  delta_y & arrow.l J_g (y) ,\
  delta_x & arrow.l delta_y dot.op J_f (x) ,\
  x & arrow.l x + alpha delta_x ,
$<differentiable-rendering>


#parec[
  where $J_f in bb(R)^(m times n)$ and $J_g in bb(R)^(1 times m)$ are the Jacobian matrices of the rendering algorithm and loss function, and $n$ and $m$ respectively denote the number of scene parameters and rendered pixels. These four steps correspond to:
][
  其中 $J_f in bb(R)^(m times n)$ 和 $J_g in bb(R)^(1 times m)$ 分别是渲染算法和损失函数的雅可比矩阵， $n$ 和 $m$ 分别表示场景参数和渲染像素的数量。这四个步骤对应于：
]

#parec[
  + Rendering an image of the scene $x$.
][
  #block[
    #set enum(numbering: "1.", start: 1)
    + 渲染场景 $x$ 的图像。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + Differentiating the loss function to obtain an image-space gradient
      vector $delta_y$. (A positive component in this vector indicates that
      increasing the value of the associated pixel in the rendered image
      would reduce the loss; the equivalent applies for a negative
      component.)
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + 对损失函数求导以获得图像空间梯度向量
      $delta_y$。（该向量中的正分量表示增加渲染图像中相关像素的值将减少损失；负分量则相反。）
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + Converting the image-space gradient $delta_y$ into a parameter-space
      gradient $delta_x$.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 将图像空间梯度 $delta_y$ 转换为参数空间梯度 $delta_x$。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 4)
    + Taking a gradient step.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 4)
    + 进行梯度步。
  ]
]

#parec[
  In practice, more sophisticated descent variants than the one in @eqt:differentiable-rendering are often used for step 4—for example, to introduce per-variable momentum and track the variance of gradients, as is done in the commonly used #emph[Adam] (Kigma and Ba 2014) optimizer. Imposing a metric on the optimization domain to pre-condition gradient steps can substantially accelerate convergence, as demonstrated by Nicolet et al.~(2021) in the case of differentiable mesh optimization.
][
  在实践中，步骤4通常使用比@eqt:differentiable-rendering 中更复杂的下降变体，例如，引入每个变量的动量并跟踪梯度的方差，这在常用的 #emph[Adam] (Kigma 和 Ba 2014) 优化器中有所体现。 在优化域上引入度量以预处理梯度步可以显著加快收敛速度，正如Nicolet等人(2021)在可微网格优化的情况下所展示的那样。
]

#parec[
  The third step evaluates the vector-matrix product $delta_y dot.op J_f$, which is the main challenge in this sequence. At size $m times n$, the Jacobian $J_f$ of the rendering algorithm is far too large to store or even compute, as both $n$ and $m$ could be in the range of multiple millions of elements. Methods in the emerging field of #emph[differentiable rendering] therefore directly evaluate this product without ever constructing the matrix $J_f$. The remainder of this subsection reviews the history and principles of these methods.
][
  第三步评估向量-矩阵乘积 $delta_y dot.op J_f$，这是此序列中的主要挑战。 对于大小为 $m times n$ 的渲染算法的雅可比矩阵 $J_f$ 来说，存储或计算它都过于庞大，因为 $n$ 和 $m$ 都可能在数百万个元素的范围内。 因此，#emph[可微渲染] 新兴领域中的方法直接评估此乘积，而无需构建矩阵 $J_f$。 本小节的其余部分回顾了这些方法的历史和原理。
]

#parec[
  For completeness, we note that a great variety of techniques have used derivatives to improve or accelerate the process of physically based rendering; these are discussed in "Further Reading" sections throughout the book. In the following, we exclusively focus on parametric derivatives for inverse problems.
][
  为了完整性，我们注意到多种技术使用导数来改进或加速基于物理的渲染过程；这些在整本书的“进一步阅读”部分中进行了讨论。 以下内容中，我们专注于逆问题的参数导数。
]

#parec[
  Inverse problems are of central importance in computer vision, and so it should be of no surprise that the origins of differentiable rendering as well as many recent advances can be found there: following pioneering work on #emph[OpenDR] by Loper and Black (2014), a number of approximate differentiable rendering techniques have been proposed and applied to challenging inversion tasks. For example, Rhodin et al.~(2015) reconstructed the pose of humans by optimizing a translucent medium composed of Gaussian functions. Kato et al.~(2018) and Liu et al.~(2019a) proposed different ways of introducing smoothness into the traditional rasterization pipeline. Laine et al.~(2020) recently proposed a highly efficient modular GPU-accelerated rasterizer based on deferred shading followed by a differentiable antialiasing step. While rasterization-based methods can differentiate the rendering of directly lit objects, they cannot easily account for effects that couple multiple scene objects like shadows or interreflection.
][
  逆问题在计算机视觉中具有重要意义，因此可微渲染的起源以及许多最近的进展可以在那里找到：继Loper和Black (2014) 在 #emph[OpenDR] 上的开创性工作之后，提出并应用了许多近似的可微渲染技术来解决具有挑战性的反演任务。 例如，Rhodin等人(2015)通过优化由高斯函数组成的半透明介质重建了人类的姿态。 Kato等人(2018)和Liu等人(2019a)提出了在传统光栅化流水线中引入平滑性的不同方法。 Laine等人(2020) 最近提出了一种基于延迟着色的高效模块化GPU加速光栅化器，随后是可微抗锯齿步骤。 虽然基于光栅化的方法可以区分直接照明对象的渲染，但它们不能轻易考虑多场景对象之间的耦合效应，如阴影或相互反射。
]

#parec[
  Early work that used physically based differentiable rendering focused on the optimization of a small number of parameters, where there is considerable flexibility in how the differentiation is carried out. For example, Gkioulekas et al.~(2013b) used stochastic gradient descent to reconstruct homogeneous media represented by a low-dimensional parameterization. Khungurn et al.~(2015) differentiated a transport simulation to fit fabric parameters to the appearance in a reference photograph. Hašan and Ramamoorthi (2013) used volumetric derivatives to enable near-instant edits of path-traced heterogeneous media. Gkioulekas et al.~(2016) studied the challenges of differentiating local properties of heterogeneous media, and Zhao et al.~(2016) performed local gradient-based optimization to drastically reduce the size of heterogeneous volumes while preserving their appearance.
][
  早期使用基于物理的可微渲染的工作集中于少量参数的优化，在如何进行微分方面有相当大的灵活性。 例如，Gkioulekas等人(2013b)使用随机梯度下降重建了由低维参数化表示的均匀介质。 Khungurn等人(2015)对传输模拟进行微分以使织物参数符合参考照片中的外观。 Hašan和Ramamoorthi (2013) 使用体积导数实现了路径追踪异质介质的近乎即时编辑。 Gkioulekas等人(2016)研究了区分异质介质局部属性的挑战，Zhao等人(2016)进行局部基于梯度的优化以在保持外观的同时大幅减少异质体积的大小。
]

#parec[
  Besides the restriction to volumetric representations, a shared limitation of these methods is that they cannot efficiently differentiate a simulation with respect to the full set of scene parameters, particularly when $n$ and $m$ are large (in other words, they are not practical choices for the third step of the previous procedure). Subsequent work has adopted #emph[reverse-mode differentiation];, which can simultaneously propagate derivatives to an essentially arbitrarily large number of parameters. (The same approach also powers training of neural networks, where it is known as #emph[backpropagation];.)
][
  除了限制于体积表示之外，这些方法的共同限制是它们无法有效区分相对于完整场景参数集的模拟，特别是当 $n$ 和 $m$ 很大时（换句话说，它们不是前述程序第三步的实际选择）。 随后的工作采用了#emph[反向模式微分];，它可以同时传播导数到本质上任意大量的参数。 （同样的方法也推动了神经网络的训练，其中被称为#emph[反向传播];。）
]

#parec[
  Of particular note is the groundbreaking work by Li et al.~(2018) along with their #emph[redner] reference implementation, which performs reverse-mode derivative propagation using a hand-crafted implementation of the necessary derivatives. In the paper, the authors make the important observation that 3D scenes are generally riddled with visibility-induced discontinuities at object silhouettes, where the radiance function undergoes sudden changes. These are normally no problem in a Monte Carlo renderer, but they cause a severe problem following differentiation. To see why, consider a hypothetical integral that computes the average incident illumination at some position $p$. When computing the derivative of such a calculation, it is normally fine to exchange the order of differentiation and integration:
][
  特别值得注意的是Li等人(2018) 的开创性工作及其 #emph[redner] 参考实现，该实现使用手工实现的必要导数进行反向模式导数传播。 在论文中，作者指出3D场景通常充满了物体轮廓处由可见性引起的不连续性，辐射函数在这些地方发生突然变化。 在蒙特卡洛渲染器中，这通常不是问题，但在微分后会造成严重问题。 为了理解原因，考虑一个假设的积分，它计算某个位置 $p$ 的平均入射光照。 当计算此类计算的导数时，通常可以交换微分和积分的顺序：
]

$
  frac(partial, partial x) integral_(S^2) L_i (p , omega) thin d omega = integral_(S^2) frac(partial, partial x) L_i ( p , omega ) thin d omega .
$<integration-differentiation>


#parec[
  The left hand side is the desired answer, while the right hand side represents the result of differentiating the simulation code. Unfortunately, the equality generally no longer holds when $L_i (p , omega)$ is discontinuous in the $omega$ argument being integrated. Li et al.~recognized that an extra correction term must be added to account for how perturbations of the scene parameters $x$ cause the discontinuities to shift. They resolved primary visibility by integrating out discontinuities via the pixel reconstruction filter and used a hierarchical data structure to place additional edge samples on silhouettes to correct for secondary visibility.
][
  左侧是所需的答案，而右侧表示对模拟代码进行微分的结果。 不幸的是，当 $L_i (p , omega)$ 在被积分的 $omega$ 参数中不连续时，等式通常不再成立。 Li等人认识到必须添加一个额外的校正项来说明场景参数 $x$ 的扰动如何导致不连续性移动。 他们通过像素重建滤波器整合不连续性来解决主要可见性，并使用分层数据结构在轮廓上放置额外的边缘样本以校正次要可见性。
]

#parec[
  Building on the Reynolds transport theorem, Zhang et al.~(2019) generalized this approach into a more general theory of differential transport that also accounts for participating media. (In that framework, the correction by Li et al.~(2018) can also be understood as an application of the Reynolds transport theorem to a simpler 2D integral.) Zhang et al.~also studied further sources of problematic discontinuities such as open boundaries and shading discontinuities and showed how they can also be differentiated without bias.
][
  在Reynolds传输定理的基础上，Zhang等人(2019)将这种方法推广为一种更通用的差分传输理论，该理论还考虑了参与介质。 （在该框架中，Li等人(2018) 的校正也可以理解为Reynolds传输定理在更简单的二维积分中的应用。） Zhang等人还研究了进一步的问题不连续性来源，例如开放边界和着色不连续性，并展示了如何在不产生偏差的情况下对它们进行微分。
]

#parec[
  Gkioulekas et al.~(2016) and Azinović et al.~(2019) observed that the gradients produced by a differentiable renderer are generally biased unless extra care is taken to decorrelate the forward and differential computation (i.e., steps 1 and 3)—for example, by using different random seeds.
][
  Gkioulekas等人(2016) 和 Azinović等人(2019) 观察到，除非采取额外措施去相关正向和微分计算（即步骤1和3），否则可微渲染器产生的梯度通常是有偏的——例如，通过使用不同的随机种子。
]

#parec[
  Manual differentiation of simulation code can be a significant development and maintenance burden. This problem can be addressed using tools for #emph[automatic
differentiation] (AD), in which case derivatives are obtained by mechanically transforming each step of the forward simulation code. See the excellent book by Griewank and Walther (2008) for a review of AD techniques. A curious aspect of differentiation is that the computation becomes unusually dynamic and problem-dependent: for example, derivative propagation may only involve a small subset of the program variables, which may not be known until the user launches the actual optimization.
][
  模拟代码的手动微分可能是一个显著的开发和维护负担。 这个问题可以通过使用#emph[自动微分];（AD）工具来解决，在这种情况下，导数是通过机械地转换正向模拟代码的每一步来获得的。 有关AD技术的回顾，请参阅Griewank和Walther (2008) 的优秀书籍。 微分的一个奇特方面是计算变得异常动态且依赖于问题：例如，导数传播可能仅涉及程序变量的一个小子集，这可能直到用户启动实际优化时才知道。
]

#parec[
  Mirroring similar developments in the machine learning world, recent work on differentiable rendering has therefore involved combinations of AD with #emph[just-in-time] (JIT) compilation to embrace the dynamic nature of this problem and take advantage of optimization opportunities. There are several noteworthy differences between typical machine learning and rendering workloads: the former tend to be composed of a relatively small number of arithmetically intense operations like matrix multiplications and convolutions, while the latter use vast numbers of simple arithmetic operations. Besides this difference, ray-tracing operations and polymorphism are ubiquitous in rendering code; polymorphism refers to the property that function calls (e.g., texture evaluation or BSDF sampling) can indirectly branch to many different parts of a large codebase. These differences have led to tailored AD/JIT frameworks for differentiable rendering.
][
  反映机器学习领域的类似发展，最近关于可微渲染的工作因此涉及AD与#emph[即时编译];（JIT）的组合，以适应该问题的动态特性并利用优化机会。 典型的机器学习和渲染工作负载之间有几个显著的差异：前者通常由相对少量的算术密集型操作组成，如矩阵乘法和卷积，而后者使用大量简单的算术操作。 除了这种差异之外，光线追踪操作和多态性在渲染代码中无处不在；多态性指的是函数调用（例如，纹理评估或BSDF采样）可以间接分支到大型代码库的许多不同部分。 这些差异促使了为可微渲染量身定制的AD/JIT框架的开发。
]

#parec[
  The #emph[Mitsuba 2] system described by Nimier-David et al.~(2019) traces the flow of computation in rendering algorithms while applying forward- or reverse-mode AD; the resulting code is then JIT-compiled into wavefront-style GPU kernels. Later work on the underlying #emph[Enoki] just-in-time compiler added more flexibility: in addition to wavefront-style execution, the system can also generate megakernels with reduced memory usage. Polymorphism-aware optimization passes simplify the resulting kernels, which are finally compiled into vectorized machine code that runs on the CPU or GPU.
][
  由Nimier-David等人(2019) 描述的#emph[Mitsuba 2];系统在应用正向或反向模式AD的同时跟踪渲染算法中的计算流；生成的代码随后被JIT编译为波前式GPU内核。 后来关于基础#emph[Enoki];即时编译器的工作增加了更多的灵活性：除了波前式执行外，该系统还可以生成内存使用减少的巨型内核。 多态性感知的优化过程简化了生成的内核，最终将其编译为在CPU或GPU上运行的矢量化机器代码。
]

#parec[
  A fundamental issue of any method based on reverse-mode differentiation (whether using AD or hand-written derivatives) is that the backpropagation step requires access to certain intermediate values computed by the forward simulation. The sequence of accesses to these values occurs in reverse order compared to the original program execution, which is inconvenient because they must either be stored or recomputed many times. The intermediate state needed to differentiate a realistic simulation can easily exhaust the available system memory, limiting performance and scalability.
][
  任何基于反向模式微分的方法（无论是使用AD还是手写导数）都面临的一个基本问题是反向传播步骤需要访问正向模拟计算的某些中间值。 这些值的访问顺序与原始程序执行顺序相反，这是不方便的，因为它们必须被存储或多次重新计算。 区分现实模拟所需的中间状态可以轻松耗尽可用的系统内存，限制性能和可扩展性。
]

#parec[
  Nimier-David et al.~(2020) and Stam (2020) observed that differentiating a light transport simulation can be interpreted as a simulation in its own right, where a differential form of radiance propagates through the scene. This derivative radiation is "emitted" from the camera, reflected by scene objects, and eventually "received" by scene objects with differentiable parameters. This idea, termed #emph[radiative backpropagation];, can drastically improve the scalability limitation mentioned above (the authors report speedups of up to $1000 times$ compared to naive AD). Following this idea, costly recording of program state followed by reverse-mode differentiation can be replaced by a Monte Carlo simulation of the "derivative radiation." The runtime complexity of the original radiative backpropagation method is quadratic in the length of the simulated light paths, which can be prohibitive in highly scattering media. Vicini et al.~(2021) addressed this flaw and enabled backpropagation in linear time by exploiting two different flavors of reversibility: the physical reciprocity of light and the mathematical invertibility of deterministic computations in the rendering code.
][
  Nimier-David等人(2020) 和 Stam (2020) 观察到，区分光传输模拟可以被解释为一种模拟本身，其中辐射的微分形式通过场景传播。 这种导数辐射从相机发出，被场景对象反射，最终被具有可微分参数的场景对象“接收”。 这种被称为#emph[辐射反向传播];的想法可以显著改善上述可扩展性限制（作者报告与天真AD相比速度提高了高达 $1000 times$ ）。 遵循这一想法，程序状态的昂贵记录随后通过反向模式微分可以被“导数辐射”的蒙特卡洛模拟所取代。 原始辐射反向传播方法的运行时复杂度与模拟光路径的长度成平方关系，这在高度散射介质中可能是禁止性的。 Vicini等人(2021) 解决了这一缺陷，并通过利用光的物理互易性和渲染代码中确定性计算的数学可逆性这两种不同的可逆性，使反向传播在线性时间内成为可能。
]

#parec[
  We previously mentioned how visibility-related discontinuities can bias computed gradients unless precautions are taken. A drawback of the original silhouette edge sampling approach by Li et al.~(2018) was relatively poor scaling with geometric complexity. Zhang et al.~(2020) extended differentiable rendering to Veach's path space formulation, which brings unique benefits in such challenging situations: analogous to how path space forward-rendering methods open the door to powerful sampling techniques, differential path space methods similarly enable access to previously infeasible ways of generating silhouette edges. For example, instead of laboriously searching for silhouette edges that are visible from a specific scene location, we can start with any triangle edge in the scene and simply trace a ray to find suitable scene locations. Zhang et al.~(2021b) later extended this approach to a larger path space including volumetric scattering interactions.
][
  我们之前提到过，如果不采取预防措施，可见性相关的不连续性可能会使计算的梯度产生偏差。 Li等人(2018) 的原始轮廓边缘采样方法的一个缺点是几何复杂性较差的扩展性。 Zhang等人(2020) 将可微渲染扩展到Veach的路径空间公式，在这种具有挑战性的情况下带来了独特的好处：类似于路径空间正向渲染方法为强大的采样技术打开了大门，差分路径空间方法同样能够访问以前无法实现的生成轮廓边缘的方法。 例如，我们可以从场景中的任何三角形边缘开始，只需追踪一条光线即可找到合适的场景位置，而不是费力地寻找从特定场景位置可见的轮廓边缘。 Zhang等人(2021b) 后来将这种方法扩展到包括体积散射交互的更大路径空间。
]

#parec[
  Loubet et al.~(2019) made the observation that discontinuous integrals themselves are benign: it is the fact that they move with respect to scene parameter perturbations that causes problems under differentiation. They therefore proposed a reparameterization of all spherical integrals that has the curious property that it moves along with each discontinuity. The integrals are then static in the new coordinates, which makes differentiation under the integral sign legal.
][
  Loubet等人(2019) 观察到不连续积分本身是良性的：是它们相对于场景参数扰动的移动在微分下引起了问题。 因此，他们提出了对所有球面积分的重新参数化，其具有一个奇特的性质，即它随每个不连续性一起移动。 积分在新坐标中是静态的，这使得在积分符号下的微分合法。
]

#parec[
  Bangaru et al.~(2020) differentiated the rendering equation and applied the divergence theorem to convert a troublesome boundary integral into a more convenient interior integral, which they subsequently showed to be equivalent to a reparameterization. They furthermore identified a flaw in Loubet et al.'s method that causes bias in computed gradients and proposed a construction that finally enables unbiased differentiation of discontinuous integrals.
][
  Bangaru等人(2020) 对渲染方程进行了微分，并应用散度定理将一个麻烦的边界积分转换为一个更方便的内部积分，随后他们证明这等同于重新参数化。 他们还发现了Loubet等人方法中的一个缺陷，该缺陷导致计算的梯度产生偏差，并提出了一种构造，最终实现了不连续积分的无偏微分。
]

#parec[
  Differentiating under the integral sign changes the integrand, which means that sampling strategies that were carefully designed for a particular forward computation may no longer be appropriate for its derivative. Zeltner et al.~(2021) investigated the surprisingly large space of differential rendering algorithms that results from differentiating standard constructions like importance sampling and MIS in different ways (for example, differentiation followed by importance sampling is not the same as importance sampling followed by differentiation). They also proposed a new sampling strategy specifically designed for the differential transport simulation. In contrast to ordinary rendering integrals, their differentiated counterparts also contain both positive and negative-valued regions, which means that standard sampling approaches like the inversion method are no longer optimal from the viewpoint of minimizing variance. Zhang et al.~(2021a) applied antithetic sampling to reduce gradient variance involving challenging cases that arise when optimizing the geometry of objects in scenes with glossy interreflection.
][
  在积分符号下微分会改变被积函数，这意味着为特定正向计算精心设计的采样策略可能不再适合其导数。 Zeltner等人(2021) 调查了通过以不同方式区分标准构造（如重要性采样和MIS）而产生的可微渲染算法的惊人广泛空间（例如，微分后进行重要性采样与重要性采样后进行微分不同）。 他们还提出了一种专门为差分传输模拟设计的新采样策略。 与普通渲染积分不同，它们的微分对应物还包含正值和负值区域，这意味着从最小化方差的角度来看，标准采样方法如反演方法不再是最优的。 Zhang等人(2021a) 应用对偶采样来减少涉及在具有光泽相互反射的场景中优化物体几何形状时出现的挑战性情况的梯度方差。
]

#parec[
  While differentiable rendering still remains challenging, fragile, and computationally expensive, steady advances continue to improve its practicality over time, leading to new applications made possible by this capability.
][
  虽然可微渲染仍然具有挑战性、脆弱且计算成本高，但稳步的进展继续随着时间的推移提高其实用性，带来了这种能力所能实现的新应用。
]

=== Machine Learning and Rendering

#parec[
  As noted by Hertzmann (#link("Further_Reading.html#cite:Hertzmann2003")[2003];) in a prescient early paper, machine learning offers effective approaches to many important problems in computer graphics, including regression and clustering. Yet until recently, application of ideas from that field was limited. However, just as in other areas of computer science, machine learning and deep neural networks have recently become an important component of many techniques at the frontiers of rendering research.
][
  正如Hertzmann在其早期具有前瞻性的论文中指出（#link("Further_Reading.html#cite:Hertzmann2003")[2003];），机器学习为计算机图形学中的许多重要问题提供了有效的方法，包括回归和聚类。然而，直到最近，该领域的思想应用仍然有限。然而，就像计算机科学的其他领域一样，机器学习和深度神经网络最近已成为渲染研究前沿许多技术的重要组成部分。
]

#parec[
  This work can be (roughly) organized into three broad categories that are progressively farther afield from the topics discussed in this book:
][
  这项工作可以（大致）分为三个广泛的类别，这些类别逐渐偏离本书讨论的主题：
]

#parec[
  + Application of #emph[learned data structures];, typically based on
    neural networks, to replace traditional data structures in traditional
    rendering algorithms.
][
  #block[
    #set enum(numbering: "1.", start: 1)
    + 应用_学习型数据结构_，通常基于神经网络，以替代传统渲染算法中的传统数据结构。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + Using machine learning–based algorithms (often deep convolutional
      neural networks) to improve images generated by traditional rendering
      algorithms.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + 使用基于机器学习的算法（通常是深度卷积神经网络）来改进传统渲染算法生成的图像。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + Directly synthesizing photorealistic images using deep neural
      networks.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + 使用深度神经网络直接合成逼真的图像。
  ]
]

#parec[
  Early work in the first category includes Nowrouzezahrai et al.~(#link("Further_Reading.html#cite:Nowrouzezahrai2009")[2009];), who used neural networks to encode spherical harmonic coefficients that represented the reflectance of dynamic objects; Dachsbacher (#link("Further_Reading.html#cite:Dachsbacher2011")[2011];), who used neural networks to represent inter-object visibility; and Ren et al.~(#link("Further_Reading.html#cite:Ren2013")[2013];), who encoded scenes' radiance distributions using neural networks.
][
  第一类的早期工作包括Nowrouzezahrai等人（#link("Further_Reading.html#cite:Nowrouzezahrai2009")[2009];），他们使用神经网络编码表示动态物体反射率的球谐系数；Dachsbacher（#link("Further_Reading.html#cite:Dachsbacher2011")[2011];），他使用神经网络表示物体间的可见性；以及Ren等人（#link("Further_Reading.html#cite:Ren2013")[2013];），他们使用神经网络编码场景的辐射分布。
]

#parec[
  Previous chapters' "Further Reading" sections have discussed many techniques based on learned data structures, including approaches that use neural networks to represent complex materials (#link("Further_Reading.html#cite:Rainer2019")[Rainer et al.~2019];, #link("Further_Reading.html#cite:Rainer2020")[2020];; #link("Further_Reading.html#cite:Kuznetsov2021")[Kuznetsov et al.~2021];), complex light sources (#link("Further_Reading.html#cite:Zhu2021:luminaires")[Zhu et al.~2021];), and the scene's radiance distribution to improve sampling (#link("Further_Reading.html#cite:Muller2019:nis")[Müller et al.~2019];, #link("Further_Reading.html#cite:Muller2020")[2020];, #link("Further_Reading.html#cite:Muller2021")[2021];). Many other techniques based on caching and interpolating radiance in the scene can be viewed through the lens of learned data structures, spanning Vorba et al.'s (#link("Further_Reading.html#cite:Vorba2014")[2014];) use of Gaussian mixture models even to techniques like irradiance caching (#link("Further_Reading.html#cite:Ward88")[Ward et al.~1988];).
][
  前几章的“进一步阅读”部分讨论了许多基于学习型数据结构的技术，包括使用神经网络表示复杂材料（#link("Further_Reading.html#cite:Rainer2019")[Rainer et al.~2019];, #link("Further_Reading.html#cite:Rainer2020")[2020];; #link("Further_Reading.html#cite:Kuznetsov2021")[Kuznetsov et al.~2021];）、复杂光源（#link("Further_Reading.html#cite:Zhu2021:luminaires")[Zhu et al.~2021];）以及场景的辐射分布以改进采样的方法（#link("Further_Reading.html#cite:Muller2019:nis")[Müller et al.~2019];, #link("Further_Reading.html#cite:Muller2020")[2020];, #link("Further_Reading.html#cite:Muller2021")[2021];）。 许多其他基于缓存和插值场景中辐射的技术可以通过学习型数据结构的视角来看待，涵盖了Vorba等人（#link("Further_Reading.html#cite:Vorba2014")[2014];）使用高斯混合模型甚至到像辐射缓存（#link("Further_Reading.html#cite:Ward88")[Ward et al.~1988];）这样的技术。
]

#parec[
  One challenge in using learned data structures with traditional rendering algorithms is that the ability to just evaluate a learned function is often not sufficient, since effective Monte Carlo integration generally requires the ability to draw samples from a matching distribution and to quantify their density. Another challenge is that #emph[online learning] is often necessary, where the learned data structure is constructed while rendering proceeds rather than being initialized ahead of time. For interactive rendering of dynamic scenes, incrementally updating learned representations can be especially beneficial.
][
  在使用传统渲染算法的学习型数据结构时，一个挑战是仅仅评估一个学习函数的能力通常是不够的，因为有效的蒙特卡罗积分通常需要能够从匹配的分布中抽取样本并量化其密度。 另一个挑战是_在线学习_通常是必要的，其中学习型数据结构是在渲染过程中构建的，而不是提前初始化的。 对于动态场景的交互式渲染，增量更新学习表示可能特别有益。
]

#parec[
  More broadly, it may be desirable to represent an entire scene with a neural representation; there is no requirement that the abstractions of meshes, BRDFs, textures, lights, and media be separately and explicitly encoded. Furthermore, learning the parameters to such representations in inverse rendering applications can be challenging due to the ambiguities noted earlier. At writing, #emph[neural radiance fields] (NeRF) (#link("Further_Reading.html#cite:Mildenhall2020")[Mildenhall et al.~2020];) are seeing widespread adoption as a learned scene representation due to the effectiveness and efficiency of the approach. NeRF is a volumetric representation that gives radiance and opacity at a given point and viewing direction. Because it is based on volume rendering, it has the additional advantage that it avoids the challenges of discontinuities in the light transport integral discussed in the previous section.
][
  更广泛地说，可能希望用神经表示来表示整个场景；没有要求网格、BRDF、纹理、光源和介质的抽象必须分别和明确地编码。 此外，由于早先提到的模糊性，在逆向渲染应用中学习这些表示的参数可能具有挑战性。 在撰写本文时，#emph[神经辐射场];（NeRF）（#link("Further_Reading.html#cite:Mildenhall2020")[Mildenhall et al.~2020];）因其方法的高效性和有效性，已被广泛采用为一种学习型场景表示。 NeRF是一种体积表示，能够在给定点和视角下提供辐射和不透明度。 因为它基于体积渲染，所以它具有额外的优势，即避免了上一节中讨论的光传输积分中的不连续性问题。
]

#parec[
  In rendering, work in the second category—using machine learning to improve conventionally rendered images—began with neural denoising algorithms, which are discussed in the "Further Reading" section at the end of @cameras-and-film . These algorithms can be remarkably effective; as with many areas of computer vision, deep convolutional neural networks have rapidly become much more effective at this problem than previous non-learned techniques.
][
  在渲染中，第二类工作——使用机器学习改进传统渲染图像——始于神经去噪算法，这些算法在@cameras-and-film 末的“进一步阅读”部分中讨论。 这些算法可以非常有效；与计算机视觉的许多领域一样，深度卷积神经网络在这个问题上迅速变得比以前的非学习技术更有效。
]


#figure(
  image("../pbr-book-website/4ed/Retrospective_and_the_Future/pha16f02.svg"),
  caption: [
    #ez_caption[
      Effectiveness of Modern Neural Denoising Algorithms for Rendering. (a) Noisy image rendered with 32 samples per pixel. (b) Feature buffer with the average surface albedo at each pixel. (c) Feature buffer with the surface normal at each pixel. (d) Denoised image. (Image denoised with the NVIDIA OptiX 7.3 denoiser.)
    ][
      Effectiveness of Modern Neural Denoising Algorithms for Rendering. (a) Noisy image rendered with 32 samples per pixel. (b) Feature buffer with the average surface albedo at each pixel. (c) Feature buffer with the surface normal at each pixel. (d) Denoised image. (Image denoised with the NVIDIA OptiX 7.3 denoiser.)
    ]
  ],
)<neural-denoising>

#parec[
  @fig:neural-denoising shows an example of the result of using such a denoiser. Given a noisy image rendered with 32 samples per pixel as well as two auxiliary images that encode the surface albedo and surface normal, the denoiser is able to produce a noise-free image in a few tens of milliseconds. Given such results, the alternative of paying the computational cost of rendering a clean image by taking thousands of pixel samples is unappealing; doing so would take much longer, especially given that Monte Carlo error only decreases at a rate $O (n^(- 1 \/ 2))$ in the number of samples $n$. Furthermore, neural denoisers are usually effective at eliminating the noise from spiky high-variance pixels, which otherwise would require enormous numbers of samples to achieve acceptable error.
][
  图16.2显示了使用这种去噪器的结果示例。 给定一个用每像素32个样本渲染的噪声图像以及两个编码表面反照率和表面法线的辅助图像，去噪器能够在几十毫秒内生成无噪声的图像。 鉴于这样的结果，通过获取数千个像素样本来支付渲染干净图像的计算成本是不吸引人的；这样做会花费更长的时间，特别是考虑到蒙特卡罗误差仅以样本数 $n$ 的 $O (n^(- 1 \/ 2))$ 速率减少。 此外，神经去噪器通常有效地消除尖锐高方差像素的噪声，否则需要大量样本才能达到可接受的误差。
]

#parec[
  Most physically based renderers today are therefore used with denoisers. This leads to an important question: #emph[what is the role of the
renderer, if its output is to be consumed by a neural network?] Given a denoiser, the renderer's task is no longer to try to make the most accurate or visually pleasing image for a human observer, but is to generate output that is most easily converted by the neural network to the desired final representation. This question has deep implications for the design of both renderers and denoisers and is likely to see much attention in coming years. (For an example of recent work in this area, see the paper by Cho et al.~(#link("Further_Reading.html#cite:Cho2021")[2021];), who improved denoising by incorporating information directly from the paths traced by the renderer and not just from image pixels.)
][
  因此，今天大多数基于物理的渲染器都与去噪器一起使用。 这引出了一个重要问题：#emph[如果渲染器的输出是由神经网络消费的，那么渲染器的角色是什么？] 有了去噪器，渲染器的任务不再是为人类观察者制作最准确或视觉上最令人愉悦的图像，而是生成最容易被神经网络转换为所需最终表示的输出。 这个问题对渲染器和去噪器的设计有深远的影响，并且可能在未来几年受到很多关注。 （有关该领域最近工作的示例，请参见Cho等人（#link("Further_Reading.html#cite:Cho2021")[2021];），他们通过直接从渲染器跟踪的路径而不仅仅是从图像像素中获取信息来改进去噪。）
]

#parec[
  The question of the renderer's role is further provoked by neural post-rendering approaches that do much more than denoise images; a recent example is #emph[GANcraft];, which converts low-fidelity blocky images of #emph[Minecraft] scenes to be near-photorealistic (#link("Further_Reading.html#cite:Hao2021")[Hao et al.~2021];). A space of techniques lies in between this extreme and less intrusive post-processing approaches like denoising: #emph[deep shading] (#link("Further_Reading.html#cite:Nalbach2017")[Nalbach et al.~2017];) synthesizes expensive effects starting from a cheaply computed set of G-buffers (normals, albedo, etc.). Granskog et al.~(#link("Further_Reading.html#cite:Granskog2020")[2020];) improved shading inference using additional view-independent context extracted from a set of high-quality reference images. More generally, #emph[neural style transfer] algorithms (#link("Further_Reading.html#cite:Gatys2016")[Gatys et al.~2016];) can be an effective way to achieve a desired visual style without fully simulating it in a renderer. Providing nuanced artistic control to such approaches remains an open problem, however.
][
  渲染器角色的问题进一步受到神经后渲染方法的激发，这些方法不仅仅是去噪图像；最近的一个例子是_GANcraft_，它将_Minecraft_场景的低保真块状图像转换为接近真实感的图像（#link("Further_Reading.html#cite:Hao2021")[Hao et al.~2021];）。 在这种极端和像去噪这样的较不具侵入性的后处理方法之间存在一系列技术：#emph[深度着色];（#link("Further_Reading.html#cite:Nalbach2017")[Nalbach et al.~2017];）从一组廉价计算的G缓冲区（法线、反照率等）开始合成昂贵的效果。 Granskog等人（#link("Further_Reading.html#cite:Granskog2020")[2020];）通过使用从一组高质量参考图像中提取的附加视图无关上下文来改进着色推断。 更一般地说，_神经风格迁移_算法（#link("Further_Reading.html#cite:Gatys2016")[Gatys et al.~2016];）可以是实现所需视觉风格的有效方法，而无需在渲染器中完全模拟它。 然而，为这些方法提供细致的艺术控制仍然是一个未解决的问题。
]

#parec[
  In the third category, a number of researchers have investigated training deep neural networks to encode a full rendering algorithm that goes from a scene description to an image. See Hermosilla et al.~(#link("Further_Reading.html#cite:Hermosilla2019")[2019];) and Chen et al.~(#link("Further_Reading.html#cite:Chen2021")[2021];) for recent work in this area. Images may also be synthesized without using conventional rendering algorithms at all, but solely from characteristics learned from real-world images. A recent example of such a #emph[generative model] is #emph[StyleGAN];, which was developed by Karras et al.~(#link("Further_Reading.html#cite:Karras2018")[2018];, #link("Further_Reading.html#cite:Karras2020")[2020];); it is capable of generating high-resolution and photorealistic images of a variety of objects, including human faces, cats, cars, and interior scenes. Techniques based on #emph[segmentation maps] (#link("Further_Reading.html#cite:Chen2017")[Chen and Koltun 2017];; #link("Further_Reading.html#cite:Park2019")[Park et al.~2019];) allow a user to denote that regions of an image should be of general categories like "sky," "water," "mountain," or "car" and then synthesize a realistic image that follows those categories. See the report by Tewari et al.~(#link("Further_Reading.html#cite:Tewari2020")[2020];) for a comprehensive summary of recent work in such areas.
][
  在第三类中，一些研究人员研究了训练深度神经网络来编码完整的渲染算法，从场景描述到图像。 有关该领域最近工作的示例，请参见Hermosilla等人（#link("Further_Reading.html#cite:Hermosilla2019")[2019];）和Chen等人（#link("Further_Reading.html#cite:Chen2021")[2021];）。 图像也可以完全不依赖传统渲染算法，而仅通过从真实世界图像中学习的特征来合成。 最近的一个_生成模型_示例是_StyleGAN_，由Karras等人开发（#link("Further_Reading.html#cite:Karras2018")[2018];, #link("Further_Reading.html#cite:Karras2020")[2020];）；它能够生成各种物体的高分辨率和逼真图像，包括人脸、猫、汽车和室内场景。 基于_分割图_的技术（#link("Further_Reading.html#cite:Chen2017")[Chen and Koltun 2017];; #link("Further_Reading.html#cite:Park2019")[Park et al.~2019];）允许用户指示图像的区域应属于“天空”、"水"、"山"或“汽车”等一般类别，然后合成遵循这些类别的真实图像。 有关此类领域最近工作的全面总结，请参阅Tewari等人（#link("Further_Reading.html#cite:Tewari2020")[2020];）的报告。
]


