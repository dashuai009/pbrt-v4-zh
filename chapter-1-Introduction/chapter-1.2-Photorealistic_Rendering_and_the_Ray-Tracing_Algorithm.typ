#import "../template.typ": parec, ez_caption


== Photorealistic Rendering and the Ray-Tracing Algorithm
<Photorealistic-Rendering-and-the-Ray-Tracing-Algorithm>
#parec[
  The goal of photorealistic rendering is to create an image of a 3D scene that is indistinguishable from a photograph of the same scene. Before we describe the rendering process, it is important to understand that in this context the word _indistinguishable_ is imprecise because it involves a human observer, and different observers may perceive the same image differently. Although we will cover a few perceptual issues in this book, accounting for the precise characteristics of a given observer is a difficult and not fully solved problem. For the most part, we will be satisfied with an accurate simulation of the physics of light and its interaction with matter, relying on our understanding of display technology to present the best possible image to the viewer.
][
  照片真实渲染的目标是创建一个与同一场景的照片无法区分的三维场景图像。在描述渲染过程之前，重要的是要理解，在这种情况下_无法区分_这个词是不精确的，因为它涉及到人类观察者，不同的观察者可能会对同一图像有不同的感知。虽然我们将在本书中讨论一些感知问题，但考虑到特定观察者的精确特征是一个困难且尚未完全解决的问题。大多数情况下，我们将满足于准确地模拟光与物质相互作用的物理过程，依靠我们对显示技术的理解，向观众呈现最佳可能的图像。
]

#parec[
  Given this single-minded focus on realistic simulation of light, it seems prudent to ask: _what is light_? Perception through light is central to our very existence, and this simple question has thus occupied the minds of famous philosophers and physicists since the beginning of recorded time. The ancient Indian philosophical school of Vaisheshika (5th-6th century BC) viewed light as a collection of small particles traveling along rays at high velocity. In the fifth century BC, the Greek philosopher Empedocles postulated that a divine fire emerged from human eyes and combined with light rays from the sun to produce vision. Between the 18th and 19th century, polymaths such as Isaac Newton, Thomas Young, and Augustin-Jean Fresnel endorsed conflicting theories modeling light as the consequence of either wave or particle propagation. During the same time period, André-Marie Ampère, Joseph-Louis Lagrange, Carl Friedrich Gauß, and Michael Faraday investigated the relations between electricity and magnetism that culminated in a sudden and dramatic unification by James Clerk Maxwell into a combined theory that is now known as _electromagnetism_.
][
  鉴于这种对光的真实模拟的专注，似乎需要谨慎地问：_什么是光_？人们生存地核心是通过光进行感知的，因此，自有记载以来，这个简单的问题就一直困扰着著名哲学家和物理学家。古代印度哲学学派 Vaisheshika（公元前 5-6 世纪）将光视为沿着光线高速传播的小粒子的集合。公元前五世纪，希腊哲学家恩培多克勒假设，人眼中出现神火，与太阳光线结合产生视觉。在 18 世纪和 19 世纪之间，艾萨克·牛顿、托马斯·杨和奥古斯丁·让·菲涅尔等博学者都支持相互冲突的理论，将光建模为波或粒子传播的结果。在同一时期，安德烈·玛丽·安培、约瑟夫·路易斯·拉格朗日、卡尔·弗里德里希·高斯和迈克尔·法拉第研究了电与磁之间的关系，最终由詹姆斯·克拉克·麦克斯韦突然而戏剧性地统一为现在已知的组合理论，也就是_电磁学_。
]

#parec[
  Light is a wave-like manifestation in this framework: the motion of electrically charged particles such as electrons in a light bulb's filament produces a disturbance of a surrounding _electric field_ that propagates away from the source. The electric oscillation also causes a secondary oscillation of the _magnetic field_, which in turn reinforces an oscillation of the electric field, and so on. The interplay of these two fields leads to a self-propagating wave that can travel extremely large distances: millions of light years, in the case of distant stars visible in a clear night sky. In the early 20th century, work by Max Planck, Max Born, Erwin Schrödinger, and Werner Heisenberg led to another substantial shift of our understanding: at a microscopic level, elementary properties like energy and momentum are quantized, which means that they can only exist as an integer multiple of a base amount that is known as a _quantum_. In the case of electromagnetic oscillations, this quantum is referred to as a ph_oton. In this sense, our physical understanding has come full circle: once we turn to very small scales, light again betrays a particle-like behavior that coexists with its overall wave-like nature.
][
  在这个框架中，光是一种类似波的表现形式：带电粒子（例如灯泡灯丝中的电子）的运动会对_周围电场_产生扰动，该扰动会远离光源传播。电振荡还会引起_磁场_的二次振荡，而磁场的二次振荡又会增强电场的振荡，等等。这两个场的相互作用产生了一种自传播波，可以传播非常远的距离：对于在晴朗的夜空中可见的遥远恒星来说，可以传播数百万光年。 20世纪初，马克斯·普朗克、马克斯·玻恩、欧文·薛定谔和维尔纳·海森堡的工作导致了我们理解的另一个重大转变：在微观层面上，能量和动量等基本属性是_量子化的_，这意味着它们只能存在作为称为量子的基本量的整数倍。在电磁振荡的情况下，这个量子被称为_光子_。从这个意义上说，我们的物理理解已经回到了原点：一旦我们转向非常小的尺度，光再次暴露出与其整体波动性质共存的粒子行为。
]

#parec[
  How does our goal of simulating light to produce realistic images fit into all of this? Faced with this tower of increasingly advanced explanations, a fundamental question arises: how far must we climb this tower to attain photorealism? To our great fortune, the answer turns out to be “not far at all.” Waves comprising visible light are extremely small, measuring only a few hundred nanometers from crest to trough. The complex wave-like behavior of light appears at these small scales, but it is of little consequence when simulating objects at the scale of, say, centimeters or meters. This is excellent news, because detailed wave-level simulations of anything larger than a few micrometers are impractical: computer graphics would not exist in its current form if this level of detail was necessary to render images. Instead, we will mostly work with equations developed between the 16th and early 19th century that model light as particles that travel along rays. This leads to a more efficient computational approach based on a key operation known as _ray tracing_.
][
  我们模拟光以产生逼真图像的目标如何适应这一切？面对这座日益先进的解释之塔，一个基本问题出现了：我们必须爬到这座塔多远才能达到照片写实主义？幸运的是，答案是“一点也不远”。可见光波非常小，从波峰到波谷只有几百纳米。光的复杂波状行为出现在这些小尺度上，但当模拟厘米或米尺度的物体时，它的影响不大。这是个好消息，因为对任何大于几微米的物体进行详细的波级模拟是不切实际的：如果渲染图像需要这种级别的细节，计算机图形学将不会以其当前的形式存在。相反，我们将主要使用 16 世纪到 19 世纪初发展起来的方程，这些方程将光建模为沿着光线传播的粒子。这导致了一种基于称为_光线追踪_的关键操作的更有效的计算方法。
]

#parec[
  Ray tracing is conceptually a simple algorithm; it is based on following the path of a ray of light through a scene as it interacts with and bounces off objects in an environment. Although there are many ways to write a ray tracer, all such systems simulate at least the following objects and phenomena:
][
  光线追踪在概念上是一个简单的算法；它跟踪光线穿过场景时与环境中的物体相互作用的路径。尽管编写光线追踪器的方法有很多种，但所有此类系统都至少模拟以下对象和现象：
]

#parec[
  - _Cameras_: A camera model determines how and from where the scene is being viewed, including how an image of the scene is recorded on a sensor. Many rendering systems generate viewing rays starting at the camera that are then traced into the scene to determine which objects are visible at each pixel.
][
  - _相机_：相机模型决定如何以及从何处查看场景，包括如何在传感器上记录场景图像。许多渲染系统从相机开始生成观察光线，然后追踪到场景中以确定每个像素处可见的对象。
]

#parec[
  _Ray-object intersections_: We must be able to tell precisely where a given ray intersects a given geometric object. In addition, we need to determine certain properties of the object at the intersection point, such as a surface normal or its material. Most ray tracers also have some facility for testing the intersection of a ray with multiple objects, typically returning the closest intersection along the ray.
][
  _射线与物体相交_：我们必须能够精确地判断给定射线与给定几何物体相交的位置。此外，我们还需要确定物体在交点处的某些属性，例如表面法线或其材质。大多数光线追踪器还具有一些用于测试光线与多个对象的相交的工具，通常返回最近的沿光线交点。
]
#parec[
  - _Light sources_: Without lighting, there would be little point in rendering a scene. A ray tracer must model the distribution of light throughout the scene, including not only the locations of the lights themselves but also the way in which they distribute their energy throughout space.
][
  - _光源_：如果没有照明，渲染场景就没有什么意义。光线追踪器必须对整个场景中的光的分布进行建模，不仅包括灯光本身的位置，还包括它们在整个空间中分配能量的方式。
]
#parec[
  - _Visibility_: In order to know whether a given light deposits energy at a point on a surface, we must know whether there is an uninterrupted path from the point to the light source. Fortunately, this question is easy to answer in a ray tracer, since we can just construct the ray from the surface to the light, find the closest ray-object intersection, and compare the intersection distance to the light distance.
][
  - _可见性_：为了知道给定的光是否在表面上的一点处沉积能量，我们必须知道从该点到光源是否存在不间断的路径。幸运的是，这个问题在光线追踪器中很容易回答，因为我们可以构造从表面到光线的光线，找到最近的光线与物体的交点，并将交点距离与光距离进行比较。
]
#parec[
  - _Light scattering at surfaces_: Each object must provide a description of its appearance, including information about how light interacts with the object's surface, as well as the nature of the reradiated (or scattered) light. Models for surface scattering are typically parameterized so that they can simulate a variety of appearances.
][
  - _表面光散射_：每个物体必须提供其外观的描述，包括光如何与物体表面相互作用的信息，以及再辐射（或散射）光的性质。表面散射模型通常是参数化的，以便它们可以模拟各种外观。
]
#parec[
  - _Indirect light transport_: Because light can arrive at a surface after bouncing off or passing through other surfaces, it is usually necessary to trace additional rays to capture this effect.
][
  - _间接光传输_：由于光可以在反射或穿过其他表面后到达一个表面，因此通常需要追踪额外的光线来捕捉这种效果。
]
#parec[
  - _Ray propagation_: We need to know what happens to the light traveling along a ray as it passes through space. If we are rendering a scene in a vacuum, light energy remains constant along a ray. Although true vacuums are unusual on Earth, they are a reasonable approximation for many environments. More sophisticated models are available for tracing rays through fog, smoke, the Earth's atmosphere, and so on.
][
  - _射线传播_：我们需要知道光线穿过空间时会发生什么。如果我们在真空中渲染场景，光能沿着光线保持恒定。尽管真正的真空在地球上并不常见，但它们对于许多环境来说是合理的近似值。更复杂的模型用于追踪穿过雾、烟、地球大气层等的光线。
]
#parec[
  We will briefly discuss each of these simulation tasks in this section. In the next section, we will show `pbrt`'s high-level interface to the underlying simulation components and will present a simple rendering algorithm that randomly samples light paths through a scene in order to generate images.
][
  我们将在本节中简要讨论每个模拟任务。在下一节中，我们将展示 `pbrt` 与底层模拟组件的高级接口，并将提供一种简单的渲染算法，该算法可以对场景中的光路进行随机采样以生成图像。
]

=== Cameras and Film


#parec[
  Nearly everyone has used a camera and is familiar with its basic functionality: you indicate your desire to record an image of the world (usually by pressing a button or tapping a screen), and the image is recorded onto a piece of film or by an electronic sensor#footnote[Although digital sensors are now more common than physical film, we will use "film" to encompass both in cases where either could be used.]. One of the simplest devices for taking photographs is called the pinhole camera. Pinhole cameras consist of a light-tight box with a tiny hole at one end (@pinhole-camera). When the hole is uncovered, light enters and falls on a piece of photographic paper that is affixed to the other end of the box. Despite its simplicity, this kind of camera is still used today, mostly for artistic purposes. Long exposure times are necessary to get enough light on the film to form an image.
][
  几乎每个人都使用过相机并熟悉其基本功能：您表明想要记录世界图像的愿望（通常通过按下按钮或点击屏幕），图像就会记录在胶片上或通过电子传感器#footnote[尽管数字传感器现在比传统胶片更常见，但在可以使用任一种类型的情况下，我们将使用“胶片”这一术语来包括两者。]记录下来。最简单的拍照设备之一称为针孔相机。针孔相机由一个一端带有小孔的不透光盒子组成（@pinhole-camera）。当洞被揭开时，光线进入并落在贴在盒子另一端的一张相纸上。尽管很简单，这种相机至今仍在使用，主要用于艺术目的。为了使胶片上有足够的光线以形成图像，需要较长的曝光时间。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f02.svg", width: 80%),
  caption: [
    #ez_caption[ *A Pinhole Camera.* The viewing volume is determined by the projection of the film through the pinhole.][*针孔相机。*观看体积由胶片通过针孔的投影决定。]
  ],
) <pinhole-camera>



#parec[
  Although most cameras are substantially more complex than the pinhole camera, it is a convenient starting point for simulation. The most important function of the camera is to define the portion of the scene that will be recorded onto the film. In @fig:pinhole-camera , we can see how connecting the pinhole to the edges of the film creates a double pyramid that extends into the scene. Objects that are not inside this pyramid cannot be imaged onto the film. Because actual cameras image a more complex shape than a pyramid, we will refer to the region of space that can potentially be imaged onto the film as the _viewing volume_.
][
  尽管大多数相机比针孔相机复杂得多，但它是一个方便的模拟起点。相机最重要的功能是定义记录到胶片上的场景。在@fig:pinhole-camera 中，我们可以看到如何将针孔连接到胶片边缘创建一个延伸到场景中的双金字塔。不在金字塔内部的物体无法成像到胶片上。由于实际相机成像的形状比金字塔更复杂，因此我们将可能成像到胶片上的空间区域称为_视野体积_。
]
#parec[
  Another way to think about the pinhole camera is to place the film plane in front of the pinhole but at the same distance (@fig:pinhole-camera-simulation). Note that connecting the hole to the film defines exactly the same viewing volume as before. Of course, this is not a practical way to build a real camera, but for simulation purposes it is a convenient abstraction. When the film (or image) plane is in front of the pinhole, the pinhole is frequently referred to as the eye.
][
  考虑针孔相机的另一种方法是将胶片平面放置在针孔前面，但距离相同（@fig:pinhole-camera-simulation）。请注意，这样的胶片定义了与之前完全相同的观看体积。当然，这不是构建真实相机的实际方法，但出于模拟目的，这是一种方便的抽象。当胶片（或图像）平面位于针孔前面时，针孔通常称为“眼睛” 。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f03.svg", width: 80%),
  caption: [
    #ez_caption[When we simulate a pinhole camera, we place the film in front of the hole at the imaging plane, and the hole is renamed the eye.
    ][当我们模拟针孔相机时，我们将胶片放在成像平面上的孔前面，该孔被重命名为“眼睛” 。
    ]
  ],
) <pinhole-camera-simulation>


#parec[
  Now we come to the crucial issue in rendering: at each point in the image, what color does the camera record? The answer to this question is partially determined by what part of the scene is visible at that point. If we recall the original pinhole camera, it is clear that only light rays that travel along the vector between the pinhole and a point on the film can contribute to that film location. In our simulated camera with the film plane in front of the eye, we are interested in the amount of light traveling from the image point to the eye.
][
  现在我们来到渲染中的关键问题：在图像中的每个点，相机记录了什么颜色？这个问题的答案部分取决于场景中此时可见的部分。如果我们回忆一下最初的针孔相机，很明显，只有沿着针孔和胶片上的点构成的矢量传播的光线才能对胶片位置产生影响。在我们的模拟相机中，胶片平面位于眼睛前面，我们感兴趣的是从图像点传播到眼睛的光量。
]
#parec[
  Therefore, an important task of the camera simulator is to take a point on the image and generate rays along which incident light will contribute to that image location. Because a ray consists of an origin point and a direction vector, this task is particularly simple for the pinhole camera model of @fig:pinhole-camera-simulation: it uses the pinhole for the origin and the vector from the pinhole to the imaging plane as the ray's direction. For more complex camera models involving multiple lenses, the calculation of the ray that corresponds to a given point on the image may be more involved.
][
  因此，相机模拟器的一项重要任务是在图像上选取一个点并生成光线，入射光将沿该光线到达该图像位置。由于光线由原点和方向向量组成，因此对于@fig:pinhole-camera-simulation 的针孔相机模型来说，此任务特别简单：它使用针孔作为原点，并使用从针孔到成像平面的向量作为光线的方向。对于涉及多个镜头的更复杂的相机模型，与图像上给定点相对应的光线的计算可能会更加复杂。
]

#parec[
  Light arriving at the camera along a ray will generally carry different amounts of energy at different wavelengths. The human visual system interprets this wavelength variation as color. Most camera sensors record separate measurements for three wavelength distributions that correspond to red, green, and blue colors, which is sufficient to reconstruct a scene's visual appearance to a human observer.(@color discusses color in more detail.) Therefore, cameras in `pbrt` also include a film abstraction that both stores the image and models the film sensor's response to incident light.
][
  沿着光线到达相机的光通常会携带不同波长的不同能量。人类视觉系统将这种波长变化解释为颜色。大多数相机传感器记录红绿蓝三种波长分布的单独测量值，这足以为人类观察者重建场景的视觉外观。（@color 更详细地讨论了颜色。）因此，`pbrt`的相机 还包括胶片抽象，它既存储图像又模拟胶片传感器对入射光的响应。
]


#parec[
  `pbrt`'s camera and film abstraction is described in detail in @cameras-and-film. With the process of converting image locations to rays encapsulated in the camera module and with the film abstraction responsible for determining the sensor's response to light, the rest of the rendering system can focus on evaluating the lighting along those rays.
][
  `pbrt`的相机和胶片的抽象将在@cameras-and-film 中详细描述。通过将图像位置转换为封装在相机模块中的光线的过程以及负责确定胶片抽象，渲染系统的其余部分可以专注于计算沿着这些光线的照明。
]


=== Ray-Object Intersections
#parec[
  Each time the camera generates a ray, the first task of the renderer is to determine which object, if any, that ray intersects first and where the intersection occurs. This intersection point is the visible point along the ray, and we will want to simulate the interaction of light with the object at this point. To find the intersection, we must test the ray for intersection against all objects in the scene and select the one that the ray intersects first. Given a ray , we first start by writing it in parametric form:
][
  每次相机生成光线时，渲染器的第一个任务是确定该光线首先与哪个对象（如果有）相交以及相交发生的位置。这个交点是沿着光线的可见点，我们想要模拟光与物体在这一点的相互作用。为了找到相交点，我们必须测试光线与场景中所有对象的相交，并选择光线第一个相交的物体。给定一条射线 ，我们首先以参数形式编写它：
]

$ r(t) =o + t upright(bold(d)) $

#parec[
  where $o$ is the ray's origin, $upright(bold(d))$ is its direction vector, and $t$ is a parameter whose legal range is $[0, + infinity\)$. We can obtain a point along the ray by specifying its parametric value and evaluating the above equation.
][
  $o$ 是射线的原点， $upright(bold(d))$ 是它的方向向量，并且 $t$ 是一个参数，其合法范围是 $[0, + infinity\)$ 。我们可以通过指定其参数来获得沿射线的点 $t$ 值并评估上述方程。
]
#parec[
  It is often easy to find the intersection between the ray $r$ and a surface defined by an implicit function $F(x,y,z)=0$. We first substitute the ray equation into the implicit equation, producing a new function whose only parameter is $t$. We then solve this function for $t$ and substitute the smallest positive root into the ray equation to find the desired point. For example, the implicit equation of a sphere centered at the origin with radius $r$ is
][
  通常很容易找到射线 $r$ 与由隐式函数定义的表面 $F(x,y,z)=0$ 之间的交点 。我们首先将射线方程代入隐式方程，产生一个新函数，其唯一参数是 $t$。然后我们计算关于 $t$ 的函数，将最小的正根代入射线方程即可找到所需的点。例如，以原点为中心、半径为半径的球体的隐式方程 是
]

$ x^2 + y^2 + z^2 - r^2 = 0 $

#parec[
  Substituting the ray equation, we have
][
  代入射线方程，我们有
]

$
  (o_x + t upright(bold(d))_x)^2 +(o_y + t upright(bold(d))_y)^2 +(o_z + t upright(bold(d))_z)^2 - r^2 = 0,
$
#parec[
  where subscripts denote the corresponding component of a point or vector. For a given ray and a given sphere, all the values besides $t$ are known, giving us an easily solved quadratic equation in . If there are no real roots, the ray misses the sphere; if there are roots, the smallest positive one gives the intersection point.
][
  其中下标表示点或向量的相应分量。对于给定的射线和给定的球体，除了 $t$ 均为已知，这是一个容易求解的二次方程 。如果没有实根，光线就会错过球体；如果有根，则最小的正根给出交点。
]
#parec[
  The intersection point alone is not enough information for the rest of the ray tracer; it needs to know certain properties of the surface at the point. First, a representation of the material at the point must be determined and passed along to later stages of the ray-tracing algorithm. Second, additional geometric information about the intersection point will also be required in order to shade the point. For example, the surface normal $upright(bold(n))$ is always required. Although many ray tracers operate with only $upright(bold(n))$ , more sophisticated rendering systems like `pbrt` require even more information, such as various partial derivatives of position and surface normal with respect to the local parameterization of the surface.
][
  仅交点不足以为光线追踪器的其余部分提供足够的信息；它需要知道该点表面的某些属性。首先，必须确定该点处材料的表示并将其传递到光线追踪算法的后续阶段。其次，还需要有关交点的附加几何信息才能对点进行着色。例如，表面法线 $upright(bold(n))$ 总是需要的。尽管许多光线追踪器仅使用 $upright(bold(n))$ ，更复杂的渲染系统，例如 `pbrt` 需要更多信息，例如位置和表面法线相对于表面局部参数化的各种偏导数。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/moana-island-view.png", width: 90%),
  caption: [
    #ez_caption[*_Moana Island_ Scene, Rendered by `pbrt`.* This model from a feature film exhibits the extreme complexity of scenes rendered for movies (Walt Disney Animation Studios 2018). It features over 146 million unique triangles, though the true geometric complexity of the scene is well into the tens of billions of triangles due to extensive use of object instancing. (Scene courtesy of Walt Disney Animation Studios.)
    ][*_莫阿纳岛_场景，通过`pbrt` 渲染。*这个故事片模型展示了为电影渲染的场景的极端复杂性（华特迪士尼动画工作室 2018 ）。它具有超过 1.46 亿个独特的三角形，尽管由于对象实例的广泛使用，场景的真实几何复杂性已达到数百亿个三角形。 （场景由华特迪士尼动画工作室提供。）
    ]
  ],
) <moana-island-view>




#let foot_note_text_en = [Although ray tracing's logarithmic complexity is often heralded as one of its key strengths, this complexity is typically only true on average. A number of ray-tracing algorithms that have guaranteed logarithmic running time have been published in the computational geometry literature, but these algorithms only work for certain types of scenes and have very expensive preprocessing and storage requirements. Szirmay-Kalos and Márton provide pointers to the relevant literature (Kelemen and Szirmay-Kalos 2001). In practice, the ray intersection algorithms presented in this book are sublinear, but without expensive preprocessing and huge memory usage it is always possible to construct worst-case scenes where ray tracing runs in $O( m n)$ time. One consolation is that scenes representing realistic environments generally do not exhibit this worst-case behavior.]

#let foot_note_text_zh = [尽管射线追踪的对数复杂性通常被认为是其关键优势之一，但这种复杂性通常仅在平均情况下成立。计算几何文献中已经发表了许多保证对数运行时间的光线跟踪算法，但这些算法仅适用于某些类型的场景，并且具有非常昂贵的预处理和存储要求。Szirmay Kalos和Márton提供了相关文献的指针（Kelemen和Szirmay-Kalos 2001）。在实践中，本书中提出的光线相交算法是亚线性的，但如果没有昂贵的预处理和巨大的内存使用，总是可以构建光线跟踪在$O(m n)$时间内运行的最坏情况场景。一个安慰是，代表现实环境的场景通常不会表现出这种最坏的行为。]

#parec[
  Of course, most scenes are made up of multiple objects. The brute-force approach would be to test the ray against each object in turn, choosing the minimum positive $t$ value of all intersections to find the closest intersection. This approach, while correct, is very slow, even for scenes of modest complexity. A better approach is to incorporate an acceleration structure that quickly rejects whole groups of objects during the ray intersection process. This ability to quickly cull irrelevant geometry means that ray tracing frequently runs in $O(m log n)$ time, where $m$ is the number of pixels in the image and is the $n$ number of objects in the scene.#footnote[ #foot_note_text_en] (Building the acceleration structure itself is necessarily at least $O(n)$ time, however.) Thanks to the effectiveness of acceleration structures, it is possible to render highly complex scenes like the one shown in @moana-island-view in reasonable amounts of time.
][
  当然，大多数场景由多个对象组成。暴力方法是依次对每个对象进行射线测试，选择所有交点中最小的正数值 $t$ 以找到最近的交点。这种方法虽然正确，但即使是对于复杂度适中的场景，也非常慢。一种更好的方法是结合一个加速结构，该结构在射线交叉过程中快速排除整组对象。这种快速剔除无关几何体的能力意味着光线追踪的运行时间通常是 $O(m log n)$，其中 $m$ 是图像中的像素数量， $n$ 是场景中的对象数量。#footnote[#foot_note_text_zh] （然而，构建加速结构本身至少需要 $O(n)$ 的时间。）得益于加速结构的有效性，可以在合理的时间内渲染像 @moana-island-view 所示的高度复杂的场景。
]
#parec[
  `pbrt`'s geometric interface and implementations of it for a variety of shapes are described in @Shapes , and the acceleration interface and implementations are shown in @primitives-and-intersection-acceleration.
][
  `pbrt` @Shapes 介绍了各种形状的几何接口及其实现，@primitives-and-intersection-acceleration 介绍了加速接口及其实现。
]

=== Light Distribution
#parec[
  The ray-object intersection stage gives us a point to be shaded and some information about the local geometry at that point. Recall that our eventual goal is to find the amount of light leaving this point in the direction of the camera. To do this, we need to know how much light is arriving at this point. This involves both the _geometric_ and _radiometric_ distribution of light in the scene. For very simple light sources (e.g., point lights), the geometric distribution of lighting is a simple matter of knowing the position of the lights. However, point lights do not exist in the real world, and so physically based lighting is often based on _area_ light sources. This means that the light source is associated with a geometric object that emits illumination from its surface. However, we will use point lights in this section to illustrate the components of light distribution; a more rigorous discussion of light measurement and distribution is the topic of @Radiometry_Spectra_and_Color and @light-sources.
][
  光线-对象相交阶段为我们提供了一个要着色的点以及有关该点局部几何形状的一些信息。回想一下，我们的最终目标是找到沿着相机方向离开该点的光量。为此，我们需要知道此时有多少光到达。这涉及场景中光的_几何_和_辐射_分布。对于非常简单的光源（例如点光源），光的几何分布只需知道光源的位置即可。然而，现实世界中并不存在点光源，因此基于物理的照明通常基于_区域光源_。这意味着光源与从其表面发出照明的几何对象相关联。然而，本节我们将使用点光源来说明光分布的组成部分；@Radiometry_Spectra_and_Color 和@light-sources 的主题是对光测量和分布进行更严格的讨论。
]


#parec[
  We frequently would like to know the amount of light power being deposited on the differential area surrounding the intersection point $p$ (@fig:point-light-irradiance). We will assume that the point light source has some power $Phi$ associated with it and that it radiates light equally in all directions. This means that the power per area on a unit sphere surrounding the light is $Phi \/ 4pi$.(These measurements will be explained and formalized in @Radiometry .)
][
  我们经常想知道交点周围的差异区域上沉积的光功率的大小 $p$ （@fig:point-light-irradiance ）。我们假设点光源有一定的功率 $Phi$ 与之相关，并且它向各个方向均匀地辐射光。这意味着围绕光的单位球体上的单位面积功率为 $Phi \/ 4pi$ 。（这些测量将在@Radiometry 中进行解释和形式化。）
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f05.svg", width: 60%),
  caption: [
    #ez_caption[Geometric construction for determining the power per area arriving at a point due to a point light source. The distance from the point to the light source is denoted by $r$.][用于确定到达点的单位面积功率的几何结构由于点光源。从该点到光源的距离表示为$r$。]
  ],
) <point-light-irradiance>

#parec[
  If we consider two such spheres (@fig:point-light-two-spheres ), it is clear that the power per area at a point on the larger sphere must be less than the power at a point on the smaller sphere because the same total power is distributed over a larger area. Specifically, the power per area arriving at a point on a sphere of radius $r$ is proportional to $1\/r^2$.
][
  如果我们考虑两个这样的球体（@fig:point-light-two-spheres ），很明显，较大球体上一点的单位面积功率必须小于较小球体上一点的功率，因为​​相同的总功率分布在较大的区域上。具体来说，到达半径球体上一点的单位面积功率 $r$ 正比于 $1\/r^2$。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f06.svg", width: 30%),
  caption: [
    #ez_caption[Since the point light radiates light equally in all directions, the same total power is deposited on all spheres centered at the light.][由于点光源向所有方向均匀地辐射光，因此相同的总功率沉积在以光为中心的所有球体上。]
  ],
) <point-light-two-spheres>


#parec[
  Furthermore, it can be shown that if the tiny surface patch $d A$ is tilted by an angle $theta$ away from the vector from the surface point to the light, the amount of power deposited on $d A$ is proportional to $cos theta$. Putting this all together, the differential power per area d $E$ (the _differential irradiance_) is
][
  此外，可以证明，如果微小的表面 $d A$ 倾斜一个角度 $theta$ 远离从表面点到光的矢量，沉积在 $d A$ 上的功率量 $A$ 正比于 $cos theta$ 。将所有这些放在一起，单位面积的差分功率 d $E$ （微分辐照度）是
]

$
  d E =(Phi cos theta) / (4 pi r^2)
$


#parec[
  Readers already familiar with basic lighting in computer graphics will notice two familiar laws encoded in this equation: the cosine falloff of light for tilted surfaces mentioned above, and the one-over- $r$ -squared falloff of light with distance.
][
  熟悉计算机图形学中基本光照的读者会在这个方程中注意到两个熟悉的定律：前面提到的倾斜表面的光线余弦衰减，以及随距离增加光线按 $r$ 的平方递减的衰减。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/zero-day-frame52.png", width: 80%),
  caption: [
    #ez_caption[Scene with Thousands of Light Sources. This scene has far too many lights to consider all of them at each point where the reflected light is computed. Nevertheless, it can be rendered efficiently using stochastic sampling of light sources. (_Scene courtesy of Beeple._)
    ][具有数千个光源的场景。该场景有太多的灯光，无法在计算反射光的每个点考虑所有灯光。尽管如此，它可以使用光源的随机采样来有效地渲染。 （_场景由 Beeple 提供。_）]
  ],
) <intro-manylights>
#parec[
  Scenes with multiple lights are easily handled because illumination is _linear_: the contribution of each light can be computed separately and summed to obtain the overall contribution. An implication of the linearity of light is that sophisticated algorithms can be applied to randomly sample lighting from only some of the light sources at each shaded point in the scene; this is the topic of @light-sampling.@fig:intro-manylights shows a scene with thousands of light sources rendered in this way.
][
  具有多个灯光的场景很容易处理，因为照明是_线性的_：每个灯光的贡献可以单独计算并求和以获得总体贡献。光的线性度意味着可以应用复杂的算法来随机采样场景中每个阴影点的部分光源的光照；这是@light-sampling 的主题。@fig:intro-manylights 显示了以这种方式渲染的具有数千个光源的场景。
]

=== Visibility
#parec[
  The lighting distribution described in the previous section ignores one very important component: shadows. Each light contributes illumination to the point being shaded only if the path from the point to the light's position is unobstructed (@fig:point-light-shadows).
][
  上一节中描述的光照分布忽略了一个非常重要的组成部分：阴影。仅当从点到光源位置的路径畅通无阻时，每个光源才会为被遮挡的点提供照明（@fig:point-light-shadows ）。
]

#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f08.svg", width: 60%),
  caption: [
    #ez_caption[A light source only deposits energy on a surface if the source is not obscured as seen from the receiving point. The light source on the left illuminates the point , but the light source on the right does not.
    ][光源只有在从接收点看不被遮挡时才向表面提供能量。左侧的光源照亮了该点，但右侧的光源则没有。]
  ],
) <point-light-shadows>

#parec[
  Fortunately, in a ray tracer it is easy to determine if the light is visible from the point being shaded. We simply construct a new ray whose origin is at the surface point and whose direction points toward the light. These special rays are called _shadow rays_. If we trace this ray through the environment, we can check to see whether any intersections are found between the ray's origin and the light source by comparing the parametric $t$ value of any intersections found to the parametric $t$ value along the ray of the light source position. If there is no blocking object between the light and the surface, the light's contribution is included.
][
  幸运的是，在光线追踪器中，很容易确定光线是否从被着色的点可见。我们简单地构造一条新光线，其原点位于表面点，其方向指向光线。这些特殊光线称为_阴影光线_。如果我们在环境中追踪这条光线，我们可以通过比较参数来检查光线的原点和光源之间是否存在任何交叉点。 $t$ 找到的参数的任何交点的值 $t$ 沿光源位置的光线的值。如果光线和表面之间没有阻挡物体，则需要包括光线的贡献。
]
=== Light Scattering at Surfaces
#parec[
  We are now able to compute two pieces of information that are vital for proper shading of a point: its location and the incident lighting. Now we need to determine how the incident lighting is scattered at the surface. Specifically, we are interested in the amount of light energy scattered back along the ray that we originally traced to find the intersection point, since that ray leads to the camera (@fig:intro-surface-scattering).
][
  我们现在能够计算对于正确着色一个点至关重要的两条信息：它的位置和入射照明。现在我们需要确定入射光如何在表面散射。具体来说，我们感兴趣的是沿着我们最初追踪以找到交点的光线散射回来的光能量，因为该光线通向相机（@fig:intro-surface-scattering ）。
]


#figure(
  image("../pbr-book-website/4ed/Introduction/pha01f09.svg", width: 80%),
  caption: [
    #ez_caption[*The Geometry of Surface Scattering.* Incident light arriving along direction interacts with the surface at point and is scattered back toward the camera along direction . The amount of light scattered toward the camera is given by the product of the incident light energy and the BRDF.
    ][*表面散射的几何形状。*入射光沿与表面在点处相互作用并沿着方向向相机散射。向相机散射的光量由入射光能量和 BRDF 的乘积给出。
    ]
  ],
) <intro-surface-scattering>


#parec[
  Each object in the scene provides a material, which is a description of its appearance properties at each point on the surface. This description is given by the bidirectional reflectance distribution function (BRDF). This function tells us how much energy is reflected from an incoming direction $omega_i$ to an outgoing direction $omega_o$ . We will write the BRDF at as $f_r (p, omega_o, omega_i)$.(By convention, directions are unit vectors.)
][
  场景中的每个对象都提供一种材质，这种材质描述了其表面每一点的外观属性。这种描述由双向反射分布函数（BRDF）给出。这个函数告诉我们从入射方向 $omega_i$ 到出射方向 $omega_o$ 有多少能量被反射。我们将在点 $p$ 处的 BRDF 记为 $f_r(p, omega_o, omega_i)$。（按照惯例，方向是单位向量。）
]


#figure(
  image("../pbr-book-website/4ed/Introduction/head-subsurface.png", width: 80%),
  caption: [
    #ez_caption[*Head with Scattering Modeled Using a BSSRDF.* Accurately modeling subsurface light transport rather than assuming that light exits the surface at the same point it entered greatly improves the realism of the rendered image. (_Model courtesy of Infinite Realities, Inc._)
    ][*使用 BSSRDF 散射模型的头*。准确地模拟次表面光传输，而不是假设光在其进入的同一点离开表面，大大提高了渲染图像的真实感。 （_模型由 Infinite Realities, Inc. 提供_）
    ]
  ],
) <head-bssrdf-example>

#parec[
  It is easy to generalize the notion of a BRDF to transmitted light (obtaining a BTDF) or to general scattering of light arriving from either side of the surface. A function that describes general scattering is called a bidirectional scattering distribution function (BSDF).`pbrt` supports a variety of BSDF models; they are described in @reflection-models . More complex yet is the bidirectional scattering surface reflectance distribution function (BSSRDF), which models light that exits a surface at a different point than it enters. This is necessary to reproduce translucent materials such as milk, marble, or skin. The BSSRDF is described in @fig:head-bssrdf-example shows an image rendered by `pbrt` based on a model of a human head where scattering from the skin is modeled using a BSSRDF.
][
  很容易将 BRDF 的概念推广到透射光（BTDF）或从表面两侧到达的光的一般散射。描述一般散射的函数称为双向散射分布函数（BSDF）。`pbrt` 支持多种BSDF模型；它们在@reflection-models 中进行了描述。更复杂的是双向散射表面反射分布函数(BSSRDF)，它对从表面出射的光与进入表面的光不同的点进行建模。这对于复刻半透明材料（例如牛奶、大理石或皮肤）是必要的。 BSSRDF 的描述如@fig:head-bssrdf-example 所示，显示了由`pbrt` 使用 BSSRDF 对皮肤散射进行建模的人体头部模型。
]

=== Indirect Light Transport
<indirect-light-transport>
#parec[
  Turner Whitted's original paper on ray tracing (@Whitted1980 ) emphasized its _recursive_ nature, which was the key that made it possible to include indirect specular reflection and transmission in rendered images. For example, if a ray from the camera hits a shiny object like a mirror, we can reflect the ray about the surface normal at the intersection point and recursively invoke the ray-tracing routine to find the light arriving at the point on the mirror, adding its contribution to the original camera ray. This same technique can be used to trace transmitted rays that intersect transparent objects. Many early ray-tracing examples showcased mirrors and glass balls (@fig:intro-raytracing-example) because these types of effects were difficult to capture with other rendering techniques.
][
  Turner Whitted 关于光线追踪的原始论文（@Whitted1980 ）强调了其_递归_性质，这是使得在渲染图像中包含间接镜面反射和透射成为可能的关键。例如，如果来自相机的光线照射到像镜子这样的闪亮物体，我们可以在交点处围绕表面法线反射光线，并递归调用光线追踪例程来找到到达镜子上的点的光线，添加其对原始相机光线的贡献。同样的技术可用于追踪与透明物体相交的透射光线。许多早期的光线追踪示例展示了镜子和玻璃球（@fig:intro-raytracing-example），因为这些类型的效果很难用其他渲染技术捕获。
]

#figure(
  table(
    columns: 2,
    [#image("../pbr-book-website/4ed/Introduction/spheres-sppm.png", width: 80%)],
    [#image("../pbr-book-website/4ed/Introduction/spheres-whitted.png", width: 80%)],
  ),
  caption: [
    #parec[
      Figure 1.11: A Prototypical Early Ray Tracing Scene. Note the use of mirrored and glass objects, which emphasizes the algorithm's ability to handle these kinds of surfaces. (a) Rendered using Whitted's original ray-tracing algorithm from 1980, and (b) rendered using stochastic progressive photon mapping (SPPM), a modern advanced light transport algorithm. algorithm that will be introduced in Section sec:photon-mapping. SPPM is able to accurately simulate the focusing of light that passes through the spheres.
    ][
      图 1.11：典型的早期光线追踪场景。请注意镜面和玻璃物体的使用，这强调了算法处理此类表面的能力。 (a) 使用 Whitted 1980 年的原始光线追踪算法进行渲染，(b) 使用随机渐进光子映射(SPPM)（一种现代先进的光传输算法）进行渲染。将在第 sec 节：光子映射中介绍的算法。 SPPM 能够准确模拟穿过球体的光的聚焦。
    ]
  ],
  kind: image,
) <intro-raytracing-example>

#parec[
  In general, the amount of light that reaches the camera from a point on an object is given by the sum of light emitted by the object (if it is itself a light source) and the amount of reflected light. This idea is formalized by the _light transport equation_ (also often known as the _rendering equation_), which measures light with respect to radiance, a radiometric unit that will be defined in @Radiometry . It says that the outgoing radiance $L_o (p, omega_o)$ from a point p in direction $omega_o$ is the emitted radiance at that point in that direction, $L_e (p, omega_o)$, plus the incident radiance from all directions on the sphere $S^2$ around p scaled by the BSDF $f (p, omega_o, omega_i)$ and a cosine term:
][
  一般来说，从物体上的某一点到达相机的光量是由物体发出的光（如果它本身是光源）和反射光的总和给出的。这个想法被_光传输方程_（也常被称为_渲染方程_）正式表达，该方程以辐射度为单位来度量光，这个单位将在 @Radiometry 中定义。它表明，从点 $p$ 向方向 $omega_o$ 的出射辐射 $L_o (p, omega_o)$ 是该点该方向的发射辐射 $L_e (p, omega_o)$ 加上来自 $p$ 周围球面 $S^2$ 上所有方向的入射辐射，这些入射辐射还需要通过 BSDF $f(p, omega_o, omega_i)$ 和一个余弦项进行缩放：
]

$
  L_o (p, omega_o) = L_e (p, omega_o) + integral_(S^2) f(p, omega_o, omega_i) L_i (p, omega_i) |cos theta_i| d omega_i.
$ <rendering-equation>

#parec[
  We will show a more complete derivation of this equation in @the-brdf-and-the-btdf and @basic-derivation. Solving this integral analytically is not possible except for the simplest of scenes, so we must either make simplifying assumptions or use numerical integration techniques.
][
  我们将在@the-brdf-and-the-btdf 和@basic-derivation 中展示该方程的更完整的推导。除了最简单的场景之外，不可能通过分析方法求解该积分，因此我们必须做出简化假设或使用数值积分技术。
]
#parec[
  Whitted's ray-tracing algorithm simplifies this integral by ignoring incoming light from most directions and only evaluating $L_i (p, omega_i)$ for directions to light sources and for the directions of perfect reflection and refraction. In other words, it turns the integral into a sum over a small number of directions. In @random-walk-integrator, we will see that simple random sampling of @eqt:rendering-equation can create realistic images that include both complex lighting and complex surface scattering effects. Throughout the remainder of the book, we will show how using more sophisticated random sampling algorithms greatly improves the efficiency of this general approach.
][
  Whitted 的光线追踪算法通过忽略来自大多数方向的入射光并仅计算 $L_i (p, omega_i)$ 来简化此积分 $L_i (p, omega_o)$ 用于光源方向以及完美反射和折射的方向。换句话说，它将积分转化为少数方向上的总和。在@random-walk-integrator 中，我们将看到@eqt:rendering-equation 的简单随机采样可以创建包含复杂光照和复杂表面散射效果的逼真图像。在本书的其余部分中，我们将展示如何使用更复杂的随机采样算法极大地提高这种通用方法的效率。
]

=== Ray Propagation
<ray-propagation>
#figure(
  image("../pbr-book-website/4ed/Introduction/explosion-figure.png", width: 80%),
  caption: [
    #ez_caption[*Explosion Modeled Using Participating Media.* Because pbrt is capable of simulating light emission, scattering, and absorption in detailed models of participating media, it is capable of rendering images like this one. (_Scene courtesy of Jim Price._)
    ][*使用参与介质建模的爆炸。*因为 pbrt 能够模拟参与介质的详细模型中的光发射、散射和吸收，它能够渲染像这样的图像。 （_场景由吉姆·普莱斯(Jim Price)提供。_）
    ]
  ],
) <intro-volumetric>


#parec[
  The discussion so far has assumed that rays are traveling through a vacuum. For example, when describing the distribution of light from a point source, we assumed that the light's power was distributed equally on the surface of a sphere centered at the light without decreasing along the way. The presence of _participating media_ such as smoke, fog, or dust can invalidate this assumption. These effects are important to simulate: a wide class of interesting phenomena can be described using participating media.@fig:intro-volumetric shows an explosion rendered by `pbrt`. Less dramatically, almost all outdoor scenes are affected substantially by participating media. For example, Earth's atmosphere causes objects that are farther away to appear less saturated.
][
  到目前为止的讨论都假设光线在真空中传播。例如，在描述点光源的光分布时，我们假设光的功率均匀地分布在以光为中心的球体表面上，并且沿途不会减少。烟、雾或灰尘等_介质_的存在可能会使这一假设失效。这些效果对于模拟很重要：可以使用介质来描述各种有趣的现象。@fig:intro-volumetric 显示了由 `pbrt` 渲染的爆炸效果。不太引人注目的是，几乎所有户外场景都受到介质的显着影响。例如，地球的大气层会使距离较远的物体看起来饱和度较低。
]
#parec[
  There are two ways in which a participating medium can affect the light propagating along a ray. First, the medium can _extinguish_ (or _attenuate_) light, either by absorbing it or by scattering it in a different direction. We can capture this effect by computing the _transmittance $T_r$_between the ray origin and the intersection point. The transmittance tells us how much of the light scattered at the intersection point makes it back to the ray origin.
][
  参与介质可以通过两种方式影响沿光线传播的光。首先，介质可以通过吸收光或向不同方向散射光来_消除_（或_减弱_）光。我们可以通过计算射线原点和交点之间的_透射率$T_r$_来捕捉这种效果 。透射率告诉我们有多少在交点处散射的光返回到光线原点。
]
#parec[
  A participating medium can also add to the light along a ray. This can happen either if the medium emits light (as with a flame) or if the medium scatters light from other directions back along the ray. We can find this quantity by numerically evaluating the _volume light transport equation_, in the same way we evaluated the light transport equation to find the amount of light reflected from a surface. We will leave the description of participating media and volume rendering until @volume-scattering and @light-transport-ii-volume-rendering.
][
  参与介质也可以沿着光线添加到光线中。如果介质发射光（如火焰）或者介质将来自其他方向的光沿着光线散射回来，就会发生这种情况。我们可以通过对_体积光传输方程_进行数值计算来找到这个量，就像我们计算光传输方程以找到从表面反射的光量一样。我们将把介质和体积渲染的描述留到@volume-scattering 和@light-transport-ii-volume-rendering 。
]
