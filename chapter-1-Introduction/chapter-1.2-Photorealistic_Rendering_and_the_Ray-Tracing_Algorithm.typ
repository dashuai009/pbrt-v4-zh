#import "../template.typ": parec, ez_caption, translator


== #ez_caption[Photorealistic Rendering and the Ray-Tracing Algorithm][照片级真实感渲染与光线追踪算法]
<Photorealistic-Rendering-and-the-Ray-Tracing-Algorithm>
#parec[
  The goal of photorealistic rendering is to create an image of a 3D scene that is indistinguishable from a photograph of the same scene. Before we describe the rendering process, it is important to understand that in this context the word _indistinguishable_ is imprecise because it involves a human observer, and different observers may perceive the same image differently. Although we will cover a few perceptual issues in this book, accounting for the precise characteristics of a given observer is a difficult and not fully solved problem. For the most part, we will be satisfied with an accurate simulation of the physics of light and its interaction with matter, relying on our understanding of display technology to present the best possible image to the viewer.
][
  照片级真实感渲染的目标，是生成三维场景的图像，使其与同一场景的照片无法区分。在介绍渲染过程之前，需要理解这里的“_无法区分_”并不精确：它涉及人类观察者，而不同观察者对同一图像的感知可能不同。本书会讨论一些感知问题，但要考虑某个观察者的确切特征，仍是一个困难且尚未完全解决的问题。大多数时候，我们只求准确模拟光及其与物质相互作用的物理过程，再凭借对显示技术的理解，向观察者呈现尽可能好的图像。
]

#parec[
  Given this single-minded focus on realistic simulation of light, it seems prudent to ask: _what is light_? Perception through light is central to our very existence, and this simple question has thus occupied the minds of famous philosophers and physicists since the beginning of recorded time. The ancient Indian philosophical school of Vaisheshika (5th-6th century BC) viewed light as a collection of small particles traveling along rays at high velocity. In the fifth century BC, the Greek philosopher Empedocles postulated that a divine fire emerged from human eyes and combined with light rays from the sun to produce vision. Between the 18th and 19th century, polymaths such as Isaac Newton, Thomas Young, and Augustin-Jean Fresnel endorsed conflicting theories modeling light as the consequence of either wave or particle propagation. During the same time period, André-Marie Ampère, Joseph-Louis Lagrange, Carl Friedrich Gauß, and Michael Faraday investigated the relations between electricity and magnetism that culminated in a sudden and dramatic unification by James Clerk Maxwell into a combined theory that is now known as _electromagnetism_.
][
  既然我们如此专注于真实地模拟光，不妨先问：_光是什么_？通过光进行感知是我们生存的核心，因此自有文字记载以来，这个简单的问题就一直吸引着著名哲学家和物理学家。古印度胜论学派（Vaisheshika，公元前 5 至 6 世纪）认为，光是沿射线高速运动的微小粒子的集合。公元前 5 世纪，希腊哲学家恩培多克勒提出，人眼发出的神火与太阳光线结合，产生视觉。18 至 19 世纪，Isaac Newton、Thomas Young 和 Augustin-Jean Fresnel 等博学家支持过相互冲突的理论，分别将光解释为波或粒子传播的结果。同一时期，André-Marie Ampère、Joseph-Louis Lagrange、Carl Friedrich Gauß 和 Michael Faraday 研究了电与磁的关系；最终，James Clerk Maxwell 实现了突然而深刻的统一，形成了如今称为_电磁学_的理论。
]

#parec[
  Light is a wave-like manifestation in this framework: the motion of electrically charged particles such as electrons in a light bulb's filament produces a disturbance of a surrounding _electric field_ that propagates away from the source. The electric oscillation also causes a secondary oscillation of the _magnetic field_, which in turn reinforces an oscillation of the electric field, and so on. The interplay of these two fields leads to a self-propagating wave that can travel extremely large distances: millions of light years, in the case of distant stars visible in a clear night sky. In the early 20th century, work by Max Planck, Max Born, Erwin Schrödinger, and Werner Heisenberg led to another substantial shift of our understanding: at a microscopic level, elementary properties like energy and momentum are quantized, which means that they can only exist as an integer multiple of a base amount that is known as a _quantum_. In the case of electromagnetic oscillations, this quantum is referred to as a _photon_. In this sense, our physical understanding has come full circle: once we turn to very small scales, light again betrays a particle-like behavior that coexists with its overall wave-like nature.
][
  在这一理论框架中，光表现为波：带电粒子（如灯泡灯丝中的电子）的运动会扰动周围的_电场_，这一扰动从光源向外传播。电场振荡又会引起_磁场_振荡，后者反过来增强电场振荡，如此往复。这两个场的相互作用形成了能够自行传播的波，传播距离可以极为遥远；例如，晴朗夜空中可见的遥远恒星发出的光，能传播数百万光年。20 世纪初，Max Planck、Max Born、Erwin Schrödinger 和 Werner Heisenberg 的工作再次深刻改变了我们的认识：在微观尺度上，能量和动量等基本属性是量子化的，即只能取某个基本量的整数倍，这个基本量称为_量子_。对于电磁振荡，这种量子称为_光子_。从这个意义上说，我们的物理认识绕了一圈又回到了起点：一旦进入很小的尺度，光又会表现出粒子性，并与其整体的波动性并存。
]

#parec[
  How does our goal of simulating light to produce realistic images fit into all of this? Faced with this tower of increasingly advanced explanations, a fundamental question arises: how far must we climb this tower to attain photorealism? To our great fortune, the answer turns out to be “not far at all.” Waves comprising visible light are extremely small, measuring only a few hundred nanometers from crest to trough. The complex wave-like behavior of light appears at these small scales, but it is of little consequence when simulating objects at the scale of, say, centimeters or meters. This is excellent news, because detailed wave-level simulations of anything larger than a few micrometers are impractical: computer graphics would not exist in its current form if this level of detail was necessary to render images. Instead, we will mostly work with equations developed between the 16th and early 19th century that model light as particles that travel along rays. This leads to a more efficient computational approach based on a key operation known as _ray tracing_.
][
  我们模拟光以生成逼真图像的目标，与这些理论有什么关系？面对层层深入的解释，一个根本问题随之而来：要达到照片级真实感，我们必须深入到哪一层？幸运的是，答案是“不必很深”。可见光的波尺度极小，从波峰到波谷仅有几百纳米。光的复杂波动行为出现在这些微小尺度上，而在模拟厘米或米尺度的物体时，其影响很小。这是个好消息，因为对尺寸超过几微米的物体进行细致的波动模拟并不现实：如果渲染图像必须达到这种细致程度，计算机图形学就不会有今天的形态。因此，我们主要采用 16 世纪至 19 世纪初建立的方程，将光建模为沿射线传播的粒子。这样就能采用更高效的计算方法，其核心操作称为_光线追踪_。
]

#parec[
  Ray tracing is conceptually a simple algorithm; it is based on following the path of a ray of light through a scene as it interacts with and bounces off objects in an environment. Although there are many ways to write a ray tracer, all such systems simulate at least the following objects and phenomena:
][
  光线追踪在概念上是一种简单的算法：它跟随光线在场景中的路径，追踪光线与环境中物体的相互作用及反弹。虽然光线追踪器有许多写法，但这类系统至少都要模拟以下对象和现象：
]

#parec[
  - _Cameras_: A camera model determines how and from where the scene is being viewed, including how an image of the scene is recorded on a sensor. Many rendering systems generate viewing rays starting at the camera that are then traced into the scene to determine which objects are visible at each pixel.
][
  - _相机_：相机模型决定从哪里、以何种方式观察场景，也决定如何将场景图像记录在传感器上。许多渲染系统从相机发出观察射线，将它们追踪到场景中，以确定各个像素能看到哪些物体。
]

#parec[
  - _Ray-object intersections_: We must be able to tell precisely where a given ray intersects a given geometric object. In addition, we need to determine certain properties of the object at the intersection point, such as a surface normal or its material. Most ray tracers also have some facility for testing the intersection of a ray with multiple objects, typically returning the closest intersection along the ray.
][
  - _射线与物体求交_：我们必须能精确确定给定射线与给定几何物体的交点，还要确定物体在交点处的某些属性，例如表面法线或材质。大多数光线追踪器还提供射线与多个物体求交的功能，通常返回沿射线最近的交点。
]
#parec[
  - _Light sources_: Without lighting, there would be little point in rendering a scene. A ray tracer must model the distribution of light throughout the scene, including not only the locations of the lights themselves but also the way in which they distribute their energy throughout space.
][
  - _光源_：没有光照，渲染场景就几乎没有意义。光线追踪器必须对整个场景中的光分布建模，不仅要描述光源的位置，还要描述光源如何将能量分布到空间中。
]
#parec[
  - _Visibility_: In order to know whether a given light deposits energy at a point on a surface, we must know whether there is an uninterrupted path from the point to the light source. Fortunately, this question is easy to answer in a ray tracer, since we can just construct the ray from the surface to the light, find the closest ray-object intersection, and compare the intersection distance to the light distance.
][
  - _可见性_：要知道某个光源是否向表面上一点输送能量，就必须知道从该点到光源的路径是否畅通。幸运的是，光线追踪器很容易回答这个问题：只需构造从表面指向光源的射线，找到射线与物体最近的交点，再比较到交点与到光源的距离。
]
#parec[
  - _Light scattering at surfaces_: Each object must provide a description of its appearance, including information about how light interacts with the object's surface, as well as the nature of the reradiated (or scattered) light. Models for surface scattering are typically parameterized so that they can simulate a variety of appearances.
][
  - _表面光散射_：每个物体都必须提供其外观的描述，包括光如何与物体表面相互作用，以及重新辐射（或散射）出的光具有何种性质。表面散射模型通常采用参数化形式，以模拟不同的外观。
]
#parec[
  - _Indirect light transport_: Because light can arrive at a surface after bouncing off or passing through other surfaces, it is usually necessary to trace additional rays to capture this effect.
][
  - _间接光传输_：光可能在其他表面反弹或透过其他表面之后才到达当前表面，因此通常需要追踪额外的射线来模拟这一效果。
]
#parec[
  - _Ray propagation_: We need to know what happens to the light traveling along a ray as it passes through space. If we are rendering a scene in a vacuum, light energy remains constant along a ray. Although true vacuums are unusual on Earth, they are a reasonable approximation for many environments. More sophisticated models are available for tracing rays through fog, smoke, the Earth's atmosphere, and so on.
][
  - _射线传播_：我们需要知道沿射线传播的光穿过空间时会发生什么。若场景处于真空中，光能沿射线保持不变。地球上真正的真空虽然罕见，但对许多环境而言，真空是合理的近似。对于雾、烟或地球大气层等环境中的射线传播，可以采用更复杂的模型。
]
#parec[
  We will briefly discuss each of these simulation tasks in this section. In the next section, we will show `pbrt`'s high-level interface to the underlying simulation components and will present a simple rendering algorithm that randomly samples light paths through a scene in order to generate images.
][
  本节将简要讨论这些模拟任务。下一节将介绍 `pbrt` 面向底层模拟组件的高层接口，并给出一个简单的渲染算法：通过随机采样场景中的光路来生成图像。
]

=== #ez_caption[Cameras and Film][相机与胶片]


#parec[
  Nearly everyone has used a camera and is familiar with its basic functionality: you indicate your desire to record an image of the world (usually by pressing a button or tapping a screen), and the image is recorded onto a piece of film or by an electronic sensor#footnote[Although digital sensors are now more common than physical film, we will use "film" to encompass both in cases where either could be used.]. One of the simplest devices for taking photographs is called the pinhole camera. Pinhole cameras consist of a light-tight box with a tiny hole at one end (@fig:pinhole-camera). When the hole is uncovered, light enters and falls on a piece of photographic paper that is affixed to the other end of the box. Despite its simplicity, this kind of camera is still used today, mostly for artistic purposes. Long exposure times are necessary to get enough light on the film to form an image.
][
  几乎每个人都用过相机，也熟悉它的基本功能：你表达记录眼前世界的意图（通常是按下按钮或轻触屏幕），相机便将图像记录到胶片或电子传感器上。#footnote[虽然数字传感器如今比实体胶片更常见，但在两者均适用的情况下，我们用“胶片”统称二者。] 最简单的摄影设备之一是针孔相机：一个不透光的盒子，一端开有小孔（@fig:pinhole-camera）。打开小孔，光便进入盒内，落到固定在另一端的相纸上。这种相机虽然简单，至今仍有人使用，主要用于艺术创作。为了让足够的光落到胶片上形成图像，需要较长的曝光时间。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f02.svg", width: 80%),
  caption: [
    #ez_caption[ *A Pinhole Camera.* The viewing volume is determined by the projection of the film through the pinhole.][*针孔相机。*视域由胶片经针孔向外的投影决定。]
  ],
) <pinhole-camera>



#parec[
  Although most cameras are substantially more complex than the pinhole camera, it is a convenient starting point for simulation. The most important function of the camera is to define the portion of the scene that will be recorded onto the film. In @fig:pinhole-camera , we can see how connecting the pinhole to the edges of the film creates a double pyramid that extends into the scene. Objects that are not inside this pyramid cannot be imaged onto the film. Because actual cameras image a more complex shape than a pyramid, we will refer to the region of space that can potentially be imaged onto the film as the _viewing volume_.
][
  虽然大多数相机远比针孔相机复杂，但后者是便于模拟的起点。相机最重要的功能，是确定场景中哪一部分会记录到胶片上。@fig:pinhole-camera 表明，将针孔与胶片边缘连接，就形成了一个延伸到场景中的双棱锥。棱锥以外的物体无法在胶片上成像。实际相机所能成像的区域比棱锥更复杂，因此我们把可能在胶片上成像的空间区域称为_视域_。
]
#parec[
  Another way to think about the pinhole camera is to place the film plane in front of the pinhole but at the same distance (@fig:pinhole-camera-simulation). Note that connecting the hole to the film defines exactly the same viewing volume as before. Of course, this is not a practical way to build a real camera, but for simulation purposes it is a convenient abstraction. When the film (or image) plane is in front of the pinhole, the pinhole is frequently referred to as the eye.
][
  还可以从另一种方式理解针孔相机：将胶片平面移到针孔前方，同时保持它与针孔的距离不变（@fig:pinhole-camera-simulation）。注意，将针孔与胶片连接起来，所得视域与之前完全相同。当然，这种安排并不适合用来构造真实相机，但对模拟来说，这是一种方便的抽象。当胶片平面（或图像平面）位于针孔前方时，针孔通常称为_视点_。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f03.svg", width: 80%),
  caption: [
    #ez_caption[When we simulate a pinhole camera, we place the film in front of the hole at the imaging plane, and the hole is renamed the eye.
    ][模拟针孔相机时，我们把胶片放在针孔前方的成像平面上，并将针孔称为视点。]
  ],
) <pinhole-camera-simulation>


#parec[
  Now we come to the crucial issue in rendering: at each point in the image, what color does the camera record? The answer to this question is partially determined by what part of the scene is visible at that point. If we recall the original pinhole camera, it is clear that only light rays that travel along the vector between the pinhole and a point on the film can contribute to that film location. In our simulated camera with the film plane in front of the eye, we are interested in the amount of light traveling from the image point to the eye.
][
  现在来到渲染的关键问题：图像上的每一点，相机究竟记录什么颜色？答案部分取决于该点能看到场景的哪一部分。回想最初的针孔相机，不难看出，只有沿针孔与胶片上某一点之间的向量传播的光，才能对胶片上的该位置作出贡献。在胶片平面位于视点前方的模拟相机中，我们关心的是从图像点传播到视点的光量。
]
#parec[
  Therefore, an important task of the camera simulator is to take a point on the image and generate rays along which incident light will contribute to that image location. Because a ray consists of an origin point and a direction vector, this task is particularly simple for the pinhole camera model of @fig:pinhole-camera-simulation: it uses the pinhole for the origin and the vector from the pinhole to the imaging plane as the ray's direction. For more complex camera models involving multiple lenses, the calculation of the ray that corresponds to a given point on the image may be more involved.
][
  因此，相机模拟器的一项重要任务，是根据图像上的一个点生成射线；沿这些射线入射的光会对该图像位置作出贡献。射线由起点和方向向量组成，因此对于 @fig:pinhole-camera-simulation 中的针孔相机模型，这项任务非常简单：以针孔为起点，以针孔指向成像平面的向量为射线方向。对于包含多个透镜的复杂相机模型，计算图像上某一点所对应的射线可能更加复杂。
]

#parec[
  Light arriving at the camera along a ray will generally carry different amounts of energy at different wavelengths. The human visual system interprets this wavelength variation as color. Most camera sensors record separate measurements for three wavelength distributions that correspond to red, green, and blue colors, which is sufficient to reconstruct a scene's visual appearance to a human observer. (@color discusses color in more detail.) Therefore, cameras in `pbrt` also include a film abstraction that both stores the image and models the film sensor's response to incident light.
][
  沿射线到达相机的光，在不同波长上通常携带不同的能量。人类视觉系统将这种随波长的变化感知为颜色。大多数相机传感器对分别对应红、绿、蓝的三种波长分布进行独立测量，这已足以重建人类观察者所见的场景外观。（@color 将更详细地讨论颜色。）因此，`pbrt` 的相机还包含一个胶片抽象，既存储图像，也对胶片传感器响应入射光的方式建模。
]


#parec[
  `pbrt`'s camera and film abstraction is described in detail in @cameras-and-film. With the process of converting image locations to rays encapsulated in the camera module and with the film abstraction responsible for determining the sensor's response to light, the rest of the rendering system can focus on evaluating the lighting along those rays.
][
  @cameras-and-film 将详细介绍 `pbrt` 的相机和胶片抽象。相机模块封装了从图像位置生成射线的过程，胶片抽象则负责确定传感器对光的响应；这样，渲染系统的其余部分就可以专注于计算沿这些射线的光照。
]


=== #ez_caption[Ray-Object Intersections][射线与物体求交]
#parec[
  Each time the camera generates a ray, the first task of the renderer is to determine which object, if any, that ray intersects first and where the intersection occurs. This intersection point is the visible point along the ray, and we will want to simulate the interaction of light with the object at this point. To find the intersection, we must test the ray for intersection against all objects in the scene and select the one that the ray intersects first. Given a ray $r$, we first start by writing it in parametric form:
][
  相机每生成一条射线，渲染器的首要任务就是确定它最先与哪个物体相交（如果存在交点），以及交点的位置。这个交点就是沿射线可见的点，我们将在这里模拟光与物体的相互作用。为找到交点，必须测试射线与场景中所有物体的相交情况，再选取射线最先碰到的物体。给定射线 $r$，首先将它写成参数形式：
]

$ r(t) =o + t upright(bold(d)) $

#parec[
  where $o$ is the ray's origin, $upright(bold(d))$ is its direction vector, and $t$ is a parameter whose legal range is $[0, + infinity\)$. We can obtain a point along the ray by specifying its parametric $t$ value and evaluating the above equation.
][
  其中，$o$ 是射线起点，$upright(bold(d))$ 是方向向量，参数 $t$ 的合法范围为 $[0, + infinity\)$。指定参数 $t$ 的值并计算上式，就能得到射线上的一个点。
]
#parec[
  It is often easy to find the intersection between the ray $r$ and a surface defined by an implicit function $F(x,y,z)=0$. We first substitute the ray equation into the implicit equation, producing a new function whose only parameter is $t$. We then solve this function for $t$ and substitute the smallest positive root into the ray equation to find the desired point. For example, the implicit equation of a sphere centered at the origin with radius $r$ is
][
  对于隐式函数 $F(x,y,z)=0$ 定义的表面，求它与射线 $r$ 的交点通常很容易。先将射线方程代入隐式方程，得到一个仅以 $t$ 为参数的新函数；然后求解 $t$，将最小正根代回射线方程，就能得到所需交点。例如，以原点为球心、半径为 $r$ 的球面具有以下隐式方程：
]

$ x^2 + y^2 + z^2 - r^2 = 0 $

#parec[
  Substituting the ray equation, we have
][
  代入射线方程，得到
]

$
  (o_x + t upright(bold(d))_x)^2 +(o_y + t upright(bold(d))_y)^2 +(o_z + t upright(bold(d))_z)^2 - r^2 = 0,
$
#parec[
  where subscripts denote the corresponding component of a point or vector. For a given ray and a given sphere, all the values besides $t$ are known, giving us an easily solved quadratic equation in $t$. If there are no real roots, the ray misses the sphere; if there are roots, the smallest positive one gives the intersection point.
][
  其中，下标表示点或向量的相应分量。对于给定射线和球面，除 $t$ 外的所有量都是已知的，因此得到一个容易求解的关于 $t$ 的二次方程。若没有实根，射线就不与球面相交；若有根，最小正根便给出交点。
]
#parec[
  The intersection point alone is not enough information for the rest of the ray tracer; it needs to know certain properties of the surface at the point. First, a representation of the material at the point must be determined and passed along to later stages of the ray-tracing algorithm. Second, additional geometric information about the intersection point will also be required in order to shade the point. For example, the surface normal $upright(bold(n))$ is always required. Although many ray tracers operate with only $upright(bold(n))$ , more sophisticated rendering systems like `pbrt` require even more information, such as various partial derivatives of position and surface normal with respect to the local parameterization of the surface.
][
  只有交点位置，还不足以供光线追踪器的后续阶段使用；它还需要该点处的一些表面属性。首先，必须确定该点的材质表示，并将其传递给光线追踪算法的后续阶段。其次，对该点着色还需要额外的几何信息。例如，表面法线 $upright(bold(n))$ 总是必需的。许多光线追踪器只使用 $upright(bold(n))$，但 `pbrt` 这样更复杂的渲染系统还需要更多信息，例如位置和表面法线关于表面局部参数化的各种偏导数。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/moana-island-view.png", width: 90%),
  caption: [
    #ez_caption[*_Moana Island_ Scene, Rendered by `pbrt`.* This model from a feature film exhibits the extreme complexity of scenes rendered for movies (Walt Disney Animation Studios 2018). It features over 146 million unique triangles, though the true geometric complexity of the scene is well into the tens of billions of triangles due to extensive use of object instancing. (Scene courtesy of Walt Disney Animation Studios.)
    ][*由 `pbrt` 渲染的 _Moana Island_ 场景。*这个来自长篇电影的模型展示了电影渲染场景的极高复杂度（Walt Disney Animation Studios 2018）。它包含超过 1.46 亿个不同的三角形；由于大量使用物体实例化，场景实际的几何复杂度达到了数百亿个三角形。（场景由 Walt Disney Animation Studios 提供。）#translator[固定上游图注引用了 Walt Disney Animation Studios 2018，但其延伸阅读页缺少对应的 `cite:DisneyMoana` 书目条目；此处保留作者年份，不生成失效链接。]]
  ],
) <moana-island-view>




#let foot_note_text_en = [Although ray tracing's logarithmic complexity is often heralded as one of its key strengths, this complexity is typically only true on average. A number of ray-tracing algorithms that have guaranteed logarithmic running time have been published in the computational geometry literature, but these algorithms only work for certain types of scenes and have very expensive preprocessing and storage requirements. Szirmay-Kalos and Márton provide pointers to the relevant literature (Kelemen and Szirmay-Kalos 2001). In practice, the ray intersection algorithms presented in this book are sublinear, but without expensive preprocessing and huge memory usage it is always possible to construct worst-case scenes where ray tracing runs in $O( m n)$ time. One consolation is that scenes representing realistic environments generally do not exhibit this worst-case behavior.]

#let foot_note_text_zh = [光线追踪的对数复杂度经常被视为其关键优势之一，但这种复杂度通常只在平均意义下成立。计算几何文献中已有一些保证对数运行时间的光线追踪算法，但它们只适用于特定类型的场景，且需要代价高昂的预处理和存储。Szirmay-Kalos 与 Márton 给出了相关文献线索（Kelemen and Szirmay-Kalos 2001）。在实践中，本书介绍的射线求交算法具有次线性复杂度；但若不进行昂贵的预处理、不使用大量内存，总能构造出最坏情况的场景，使光线追踪的运行时间达到 $O(m n)$。所幸，表现真实环境的场景通常不会出现这种最坏情况。]

#parec[
  Of course, most scenes are made up of multiple objects. The brute-force approach would be to test the ray against each object in turn, choosing the minimum positive $t$ value of all intersections to find the closest intersection. This approach, while correct, is very slow, even for scenes of modest complexity. A better approach is to incorporate an acceleration structure that quickly rejects whole groups of objects during the ray intersection process. This ability to quickly cull irrelevant geometry means that ray tracing frequently runs in $O(m log n)$ time, where $m$ is the number of pixels in the image and $n$ is the number of objects in the scene.#footnote[ #foot_note_text_en] (Building the acceleration structure itself is necessarily at least $O(n)$ time, however.) Thanks to the effectiveness of acceleration structures, it is possible to render highly complex scenes like the one shown in @fig:moana-island-view in reasonable amounts of time.
][
  当然，大多数场景都由多个物体组成。直接的方法是依次测试射线与各个物体是否相交，再从所有交点中选出最小的正 $t$ 值，以找到最近交点。这种做法虽正确，但即使场景复杂度不高，也非常慢。更好的方法是使用_加速结构_，在射线求交过程中快速排除整组物体。由于能快速剔除无关几何体，光线追踪的运行时间通常为 $O(m log n)$，其中 $m$ 是图像的像素数，$n$ 是场景中的物体数。#footnote[#foot_note_text_zh]（不过，构建加速结构本身至少需要 $O(n)$ 时间。）借助有效的加速结构，即使是 @fig:moana-island-view 这样高度复杂的场景，也能在合理时间内完成渲染。
]
#parec[
  `pbrt`'s geometric interface and implementations of it for a variety of shapes are described in @Shapes , and the acceleration interface and implementations are shown in @primitives-and-intersection-acceleration.
][
  @Shapes 将介绍 `pbrt` 的几何接口及其针对多种形状的实现；@primitives-and-intersection-acceleration 将介绍加速结构的接口与实现。
]

=== #ez_caption[Light Distribution][光的分布]
#parec[
  The ray-object intersection stage gives us a point to be shaded and some information about the local geometry at that point. Recall that our eventual goal is to find the amount of light leaving this point in the direction of the camera. To do this, we need to know how much light is arriving at this point. This involves both the _geometric_ and _radiometric_ distribution of light in the scene. For very simple light sources (e.g., point lights), the geometric distribution of lighting is a simple matter of knowing the position of the lights. However, point lights do not exist in the real world, and so physically based lighting is often based on _area_ light sources. This means that the light source is associated with a geometric object that emits illumination from its surface. However, we will use point lights in this section to illustrate the components of light distribution; a more rigorous discussion of light measurement and distribution is the topic of @Radiometry_Spectra_and_Color and @light-sources.
][
  射线与物体求交后，我们得到一个待着色的点，以及该点的局部几何信息。回想一下，最终目标是求出从该点向相机方向离开的光量。为此，需要知道有多少光到达该点。这涉及场景中光的_几何分布_与_辐射度量分布_。对于点光源等非常简单的光源，只要知道光源位置，就能确定其几何分布。然而，现实世界中并不存在点光源，因此基于物理的照明常采用_面光源_：光源对应一个从表面发光的几何物体。不过，本节将用点光源来说明光分布的各个要素；@Radiometry_Spectra_and_Color 和 @light-sources 将更严格地讨论光的度量与分布。
]


#parec[
  We frequently would like to know the amount of light power being deposited on the differential area surrounding the intersection point $p$ (@fig:point-light-irradiance). We will assume that the point light source has some power $Phi$ associated with it and that it radiates light equally in all directions. This means that the power per area on a unit sphere surrounding the light is $Phi \/ (4pi)$. (These measurements will be explained and formalized in @Radiometry .)
][
  我们常常希望知道交点 $p$ 附近微分面积上接收到的光功率（@fig:point-light-irradiance）。假设点光源的功率为 $Phi$，且向所有方向均匀辐射。那么，以光源为中心的单位球面上的单位面积功率就是 $Phi \/ (4pi)$。（@Radiometry 将解释这些度量，并给出正式定义。）
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f05.svg", width: 60%),
  caption: [
    #ez_caption[Geometric construction for determining the power per area arriving at a point $p$ due to a point light source. The distance from the point to the light source is denoted by $r$.][计算点光源在点 $p$ 处产生的单位面积功率所用的几何构造。该点到光源的距离记为 $r$。]
  ],
) <point-light-irradiance>

#parec[
  If we consider two such spheres (@fig:point-light-two-spheres ), it is clear that the power per area at a point on the larger sphere must be less than the power at a point on the smaller sphere because the same total power is distributed over a larger area. Specifically, the power per area arriving at a point on a sphere of radius $r$ is proportional to $1\/r^2$.
][
  考虑两个这样的球面（@fig:point-light-two-spheres）：相同的总功率分布在更大的面积上，因此大球面上一点的单位面积功率必然低于小球面上的对应值。具体来说，半径为 $r$ 的球面上一点接收到的单位面积功率与 $1\/r^2$ 成正比。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f06.svg", width: 30%),
  caption: [
    #ez_caption[Since the point light radiates light equally in all directions, the same total power is deposited on all spheres centered at the light.][由于点光源向所有方向均匀辐射，以光源为中心的任意球面接收到的总功率都相同。]
  ],
) <point-light-two-spheres>


#parec[
  Furthermore, it can be shown that if the tiny surface patch $d A$ is tilted by an angle $theta$ away from the vector from the surface point to the light, the amount of power deposited on $d A$ is proportional to $cos theta$. Putting this all together, the differential power per area $d E$ (the _differential irradiance_) is
][
  此外，可以证明：若微小面片 $d A$ 相对于表面点指向光源的向量倾斜了角度 $theta$，则 $d A$ 接收到的功率与 $cos theta$ 成正比。将这些关系结合起来，单位面积的微分功率 $d E$（即_微分辐照度_）为
]

$
  d E =(Phi cos theta) / (4 pi r^2)
$


#parec[
  Readers already familiar with basic lighting in computer graphics will notice two familiar laws encoded in this equation: the cosine falloff of light for tilted surfaces mentioned above, and the one-over- $r$ -squared falloff of light with distance.
][
  熟悉计算机图形学基础光照的读者，会在这个方程中看到两个熟悉的规律：上文提到的倾斜表面上的余弦衰减，以及随距离按 $1/r^2$ 衰减的平方反比规律。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/zero-day-frame52.png", width: 80%),
  caption: [
    #ez_caption[Scene with Thousands of Light Sources. This scene has far too many lights to consider all of them at each point where the reflected light is computed. Nevertheless, it can be rendered efficiently using stochastic sampling of light sources. (_Scene courtesy of Beeple._)
    ][*包含数千个光源的场景。*这里的光源太多，无法在每个计算反射光的点逐一考虑所有光源。不过，对光源进行随机采样，仍可以高效渲染该场景。（_场景由 Beeple 提供。_）]
  ],
) <intro-manylights>
#parec[
  Scenes with multiple lights are easily handled because illumination is _linear_: the contribution of each light can be computed separately and summed to obtain the overall contribution. An implication of the linearity of light is that sophisticated algorithms can be applied to randomly sample lighting from only some of the light sources at each shaded point in the scene; this is the topic of @light-sampling. @fig:intro-manylights shows a scene with thousands of light sources rendered in this way.
][
  多个光源的场景很容易处理，因为光照具有_线性性_：可以分别计算各光源的贡献，再相加得到总贡献。光的线性性也意味着，我们可以采用更精巧的算法，在场景的每个着色点只对部分光源的光照进行随机采样；@light-sampling 将讨论这一问题。@fig:intro-manylights 展示了用这种方法渲染的包含数千个光源的场景。
]

=== #ez_caption[Visibility][可见性]
#parec[
  The lighting distribution described in the previous section ignores one very important component: shadows. Each light contributes illumination to the point being shaded only if the path from the point to the light's position is unobstructed (@fig:point-light-shadows).
][
  上一小节描述的光照分布忽略了一个非常重要的因素：阴影。只有当待着色点到某个光源位置的路径畅通无阻时，该光源才会为这个点提供光照（@fig:point-light-shadows）。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f08.svg", width: 60%),
  caption: [
    #ez_caption[A light source only deposits energy on a surface if the source is not obscured as seen from the receiving point. The light source on the left illuminates the point $p$, but the light source on the right does not.
    ][只有从接收点看去光源未被遮挡时，光源才会向该表面输送能量。左侧光源照亮点 $p$，右侧光源则不能。]
  ],
) <point-light-shadows>

#parec[
  Fortunately, in a ray tracer it is easy to determine if the light is visible from the point being shaded. We simply construct a new ray whose origin is at the surface point and whose direction points toward the light. These special rays are called _shadow rays_. If we trace this ray through the environment, we can check to see whether any intersections are found between the ray's origin and the light source by comparing the parametric $t$ value of any intersections found to the parametric $t$ value along the ray of the light source position. If there is no blocking object between the light and the surface, the light's contribution is included.
][
  幸运的是，光线追踪器很容易判断从待着色点能否看到光源。只需构造一条以表面点为起点、方向指向光源的新射线。这类特殊射线称为_阴影射线_。在场景中追踪这条射线时，可以比较找到的各个交点的参数 $t$ 值与光源位置在该射线上的参数 $t$ 值，判断射线起点与光源之间是否存在交点。若光源与表面之间没有物体遮挡，就计入该光源的贡献。
]
=== #ez_caption[Light Scattering at Surfaces][表面光散射]
#parec[
  We are now able to compute two pieces of information that are vital for proper shading of a point: its location and the incident lighting. Now we need to determine how the incident lighting is scattered at the surface. Specifically, we are interested in the amount of light energy scattered back along the ray that we originally traced to find the intersection point, since that ray leads to the camera (@fig:intro-surface-scattering).
][
  现在，我们能求得正确地对一点着色所需的两项关键信息：位置和入射光照。接下来，需要确定入射光在表面如何散射。具体来说，我们关心的是沿最初用于寻找交点的射线返回的散射光能量，因为这条射线通向相机（@fig:intro-surface-scattering）。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f09.svg", width: 80%),
  caption: [
    #ez_caption[*The Geometry of Surface Scattering.* Incident light arriving along direction $omega_i$ interacts with the surface at point $p$ and is scattered back toward the camera along direction $omega_o$. The amount of light scattered toward the camera is given by the product of the incident light energy and the BRDF.
    ][*表面散射的几何关系。*沿方向 $omega_i$ 到达的入射光在点 $p$ 处与表面相互作用，再沿方向 $omega_o$ 散射回相机。向相机散射的光量由入射光能量与 BRDF 的乘积给出。]
  ],
) <intro-surface-scattering>


#parec[
  Each object in the scene provides a material, which is a description of its appearance properties at each point on the surface. This description is given by the bidirectional reflectance distribution function (BRDF). This function tells us how much energy is reflected from an incoming direction $omega_i$ to an outgoing direction $omega_o$ . We will write the BRDF at $p$ as $f_(r)(p, omega_o, omega_i)$. (By convention, directions $omega$ are unit vectors.)
][
  场景中的每个物体都提供一种材质，用来描述表面各点的外观属性。这种描述由双向反射分布函数（BRDF）给出。该函数告诉我们有多少能量从入射方向 $omega_i$ 反射到出射方向 $omega_o$。我们将点 $p$ 处的 BRDF 记为 $f_(r)(p, omega_o, omega_i)$。（按惯例，方向 $omega$ 为单位向量。）
]


#figure(
  image("../pbr-book-website/4ed/Introduction/head-subsurface.png", width: 80%),
  caption: [
    #ez_caption[*Head with Scattering Modeled Using a BSSRDF.* Accurately modeling subsurface light transport rather than assuming that light exits the surface at the same point it entered greatly improves the realism of the rendered image. (_Model courtesy of Infinite Realities, Inc._)
    ][*使用 BSSRDF 模拟散射的人头。*准确地模拟次表面光传输，而不是假设光从进入表面的同一点离开，能大幅提升渲染图像的真实感。（_模型由 Infinite Realities, Inc. 提供。_）]
  ],
) <head-bssrdf-example>

#parec[
  It is easy to generalize the notion of a BRDF to transmitted light (obtaining a BTDF) or to general scattering of light arriving from either side of the surface. A function that describes general scattering is called a bidirectional scattering distribution function (BSDF). `pbrt` supports a variety of BSDF models; they are described in @reflection-models . More complex yet is the bidirectional scattering surface reflectance distribution function (BSSRDF), which models light that exits a surface at a different point than it enters. This is necessary to reproduce translucent materials such as milk, marble, or skin. The BSSRDF is described in @fig:head-bssrdf-example shows an image rendered by `pbrt` based on a model of a human head where scattering from the skin is modeled using a BSSRDF.
][
  BRDF 的概念很容易推广到透射光（得到 BTDF），或推广到从表面任一侧入射的光的一般散射。描述一般散射的函数称为双向散射分布函数（BSDF）。`pbrt` 支持多种 BSDF 模型，@reflection-models 将介绍它们。更复杂的是双向散射表面反射分布函数（BSSRDF），它对入射点与出射点不同的光传输建模。要再现牛奶、大理石或皮肤等半透明材质，就需要这种模型。原文在此提及 BSSRDF 的介绍位置，但未给出引用目标。#translator[固定上游原文在“The BSSRDF is described in”处中断，目标章节缺失，暂不推测补写。] @fig:head-bssrdf-example 展示了 `pbrt` 渲染的人头模型，其中用 BSSRDF 模拟皮肤的散射。
]

=== #ez_caption[Indirect Light Transport][间接光传输]
<indirect-light-transport>
#parec[
  Turner Whitted's original paper on ray tracing (@Whitted1980 ) emphasized its _recursive_ nature, which was the key that made it possible to include indirect specular reflection and transmission in rendered images. For example, if a ray from the camera hits a shiny object like a mirror, we can reflect the ray about the surface normal at the intersection point and recursively invoke the ray-tracing routine to find the light arriving at the point on the mirror, adding its contribution to the original camera ray. This same technique can be used to trace transmitted rays that intersect transparent objects. Many early ray-tracing examples showcased mirrors and glass balls (@fig:intro-raytracing-example) because these types of effects were difficult to capture with other rendering techniques.
][
  Turner Whitted 最初的光线追踪论文（@Whitted1980）强调了算法的_递归_性质；这正是让渲染图像能够包含间接镜面反射和透射的关键。例如，相机射线若碰到镜子一类的光亮物体，就可以在交点处按表面法线反射该射线，再递归调用光线追踪过程，求出到达镜面该点的光，并将其贡献加入原来的相机射线。同一技术也可用于追踪遇到透明物体后的透射射线。许多早期光线追踪示例都展示了镜子和玻璃球（@fig:intro-raytracing-example），因为其他渲染技术很难表现这些效果。
]

#figure(
  table(
    columns: 2,
    [(a) #image("../pbr-book-website/4ed/Introduction/spheres-whitted.png", width: 100%)],
    [(b) #image("../pbr-book-website/4ed/Introduction/spheres-sppm.png", width: 100%)],
  ),
  caption: [
    #ez_caption[
      A Prototypical Early Ray Tracing Scene. Note the use of mirrored and glass objects, which emphasizes the algorithm's ability to handle these kinds of surfaces. (a) Rendered using Whitted's original ray-tracing algorithm from 1980, and (b) rendered using stochastic progressive photon mapping (SPPM), a modern advanced light transport algorithm. algorithm that will be introduced in Section sec:photon-mapping. SPPM is able to accurately simulate the focusing of light that passes through the spheres.
    ][
      典型的早期光线追踪场景。镜面物体与玻璃物体突出了该算法处理这类表面的能力。（a）采用 Whitted 于 1980 年提出的原始光线追踪算法渲染；（b）采用随机渐进光子映射（SPPM）这一现代高级光传输算法渲染。原文接着写道：“将在 Section sec:photon-mapping 中介绍的算法。”SPPM 能准确模拟穿过球体的光的聚焦。#translator[固定上游此处包含重复句片段，且 sec:photon-mapping 未解析为章节引用；保留该问题，不臆造目标。]
    ]
  ],
  kind: image,
) <intro-raytracing-example>

#parec[
  In general, the amount of light that reaches the camera from a point on an object is given by the sum of light emitted by the object (if it is itself a light source) and the amount of reflected light. This idea is formalized by the _light transport equation_ (also often known as the _rendering equation_), which measures light with respect to radiance, a radiometric unit that will be defined in @Radiometry . It says that the outgoing radiance $L_(o)(p, omega_o)$ from a point $p$ in direction $omega_o$ is the emitted radiance at that point in that direction, $L_(e)(p, omega_o)$, plus the incident radiance from all directions on the sphere $cal(S)^2$ around $p$ scaled by the BSDF $f (p, omega_o, omega_i)$ and a cosine term:
][
  一般来说，从物体上一点到达相机的光量，等于物体自身发出的光（如果它本身是光源）与反射光之和。_光传输方程_（也常称为_渲染方程_）将这个想法形式化。它用辐亮度来度量光；@Radiometry 将定义这一辐射度量。方程表明，点 $p$ 沿方向 $omega_o$ 的出射辐亮度 $L_(o)(p, omega_o)$，等于该点沿该方向发出的辐亮度 $L_(e)(p, omega_o)$，加上来自 $p$ 周围球面 $cal(S)^2$ 上所有方向的入射辐亮度经 BSDF $f(p, omega_o, omega_i)$ 和余弦项加权后的积分：
]

$
  L_(o)(p, omega_o) = L_(e)(p, omega_o) + integral_(cal(S)^2) f(p, omega_o, omega_i) L_(i)(p, omega_i) |cos theta_i| d omega_i.
$ <rendering-equation>

#parec[
  We will show a more complete derivation of this equation in @the-brdf-and-the-btdf and @basic-derivation. Solving this integral analytically is not possible except for the simplest of scenes, so we must either make simplifying assumptions or use numerical integration techniques.
][
  @the-brdf-and-the-btdf 和 @basic-derivation 将给出该方程更完整的推导。除最简单的场景外，这个积分都无法解析求解，因此必须作简化假设，或采用数值积分技术。
]
#parec[
  Whitted's ray-tracing algorithm simplifies this integral by ignoring incoming light from most directions and only evaluating $L_(i)(p, omega_i)$ for directions to light sources and for the directions of perfect reflection and refraction. In other words, it turns the integral into a sum over a small number of directions. In @random-walk-integrator, we will see that simple random sampling of @eqt:rendering-equation can create realistic images that include both complex lighting and complex surface scattering effects. Throughout the remainder of the book, we will show how using more sophisticated random sampling algorithms greatly improves the efficiency of this general approach.
][
  Whitted 的光线追踪算法忽略了大多数方向的入射光，只在指向光源的方向，以及理想反射和折射方向上计算 $L_(i)(p, omega_i)$，以此简化积分。换句话说，它将积分化为少数方向上的求和。在 @random-walk-integrator 中，我们将看到，对 @eqt:rendering-equation 进行简单的随机采样，就能生成同时包含复杂光照和复杂表面散射效果的逼真图像。本书后续将介绍，如何用更精巧的随机采样算法显著提高这一通用方法的效率。
]

=== #ez_caption[Ray Propagation][射线传播]
<ray-propagation>
#figure(
  image("../pbr-book-website/4ed/Introduction/explosion-figure.png", width: 80%),
  caption: [
    #ez_caption[*Explosion Modeled Using Participating Media.* Because `pbrt` is capable of simulating light emission, scattering, and absorption in detailed models of participating media, it is capable of rendering images like this one. (_Scene courtesy of Jim Price._)
    ][*用参与介质建模的爆炸。*`pbrt` 能在精细的参与介质模型中模拟光的发射、散射与吸收，因此能够渲染这样的图像。（_场景由 Jim Price 提供。_）]
  ],
) <intro-volumetric>


#parec[
  The discussion so far has assumed that rays are traveling through a vacuum. For example, when describing the distribution of light from a point source, we assumed that the light's power was distributed equally on the surface of a sphere centered at the light without decreasing along the way. The presence of _participating media_ such as smoke, fog, or dust can invalidate this assumption. These effects are important to simulate: a wide class of interesting phenomena can be described using participating media. @fig:intro-volumetric shows an explosion rendered by `pbrt`. Less dramatically, almost all outdoor scenes are affected substantially by participating media. For example, Earth's atmosphere causes objects that are farther away to appear less saturated.
][
  目前的讨论都假设射线在真空中传播。例如，描述点光源的光分布时，我们假设光功率均匀分布在以光源为中心的球面上，且沿途没有减少。烟、雾或灰尘等_参与介质_的存在可能使这一假设失效。模拟这些效果很重要，因为参与介质可以描述许多有趣的现象。@fig:intro-volumetric 展示了 `pbrt` 渲染的一次爆炸。还有一些不那么显眼的情况：几乎所有室外场景都显著受到参与介质的影响。例如，地球大气层会使远处物体看起来饱和度较低。
]
#parec[
  There are two ways in which a participating medium can affect the light propagating along a ray. First, the medium can _extinguish_ (or _attenuate_) light, either by absorbing it or by scattering it in a different direction. We can capture this effect by computing the _transmittance_ $T_r$ between the ray origin and the intersection point. The transmittance tells us how much of the light scattered at the intersection point makes it back to the ray origin.
][
  参与介质可以通过两种方式影响沿射线传播的光。首先，介质会吸收光，或把光散射到其他方向，从而使光发生_消光_（或_衰减_）。计算射线起点到交点之间的_透射率_ $T_r$，就能模拟这种效果。透射率告诉我们，交点处散射的光有多少能够返回射线起点。
]
#parec[
  A participating medium can also add to the light along a ray. This can happen either if the medium emits light (as with a flame) or if the medium scatters light from other directions back along the ray. We can find this quantity by numerically evaluating the _volume light transport equation_, in the same way we evaluated the light transport equation to find the amount of light reflected from a surface. We will leave the description of participating media and volume rendering until @volume-scattering and @light-transport-ii-volume-rendering.
][
  参与介质也可以增加沿射线传播的光：介质本身可能发光（如火焰），也可能把其他方向的光散射到沿射线返回的方向。与通过光传输方程求表面反射光量一样，我们可以数值求解_体积光传输方程_，得到这一光量。参与介质和体积渲染将在 @volume-scattering 和 @light-transport-ii-volume-rendering 中介绍。
]
