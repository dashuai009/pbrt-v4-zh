#import "../template.typ": parec, ez_caption
== #ez_caption[Further Reading][延伸阅读]

#parec[
  DeRose, Goldman, and their collaborators have argued for an elegant “coordinate-free” approach to describing vector geometry for graphics, where the fact that positions and directions happen to be represented by $(x,y,z)$ coordinates with respect to a particular coordinate system is deemphasized and where points and vectors themselves record which coordinate system they are expressed in terms of (Goldman #cite(label("10.1145/282957.282969")); DeRose #cite(label("derose1989coordinate")); Mann et al. #cite(label("Mann97acoordinate"))). This makes it possible for a software layer to ensure that common errors like adding a vector in one coordinate system to a point in another coordinate system are transparently handled by transforming them to a common coordinate system first. A related approach was described by Geisler et al. (#cite(label("geisler2020geometry"))), who encoded coordinate systems using the programming language's type system. We have not followed either of these approaches in `pbrt`, although the principles behind them are well worth understanding and keeping in mind when working with coordinate systems in computer graphics.
][
  DeRose、Goldman 及其合作者提出了一种优雅的“无坐标”方法来描述图形学中的向量几何。这种方法不强调位置和方向恰好以某个坐标系下的 $(x,y,z)$ 坐标表示，而让点和向量本身记录它们所属的坐标系（Goldman #cite(label("10.1145/282957.282969"))；DeRose #cite(label("derose1989coordinate"))；Mann 等人 #cite(label("Mann97acoordinate"))）。这样，软件层便能透明地处理将一个坐标系中的向量加到另一个坐标系中的点上等常见错误：先将二者转换到同一个坐标系，再进行运算。Geisler 等人（#cite(label("geisler2020geometry"))）介绍了相关方法，使用编程语言的类型系统编码坐标系。`pbrt` 没有采用这两种方法，但在图形学中处理坐标系时，理解并牢记其原理很有价值。
]


#parec[
  Schneider and Eberly's #emph[Geometric Tools for Computer Graphics] is influenced by the coordinate-free approach and covers the topics of this chapter in much greater depth (#cite(label("schneider2003geometric"))). It is also full of useful geometric algorithms for graphics. A classic and more traditional introduction to the topics of this chapter is #emph[Mathematical Elements for Computer Graphics] by Rogers and Adams (#cite(label("10.5555/63448"))). Note that their book uses a row-vector representation of points and vectors, however, which means that our matrices would be transposed when expressed in their framework, and that they multiply points and vectors by matrices to transform them $(p upright(bold(M)))$, rather than multiplying matrices by points as we do $(upright(bold(M)) p)$. Homogeneous coordinates were only briefly mentioned in this chapter, although they are the basis of projective geometry, where they are the foundation of many elegant algorithms. Stolfi's book is an excellent introduction to this topic (#cite(label("10.5555/113163"))).
][
  Schneider 和 Eberly 的《Geometric Tools for Computer Graphics》受无坐标方法影响，对本章主题作了深入得多的讨论（#cite(label("schneider2003geometric"))），也介绍了大量实用的图形学几何算法。Rogers 和 Adams 的《Mathematical Elements for Computer Graphics》（#cite(label("10.5555/63448"))）则是一本经典而较传统的入门书。不过，该书用行向量表示点和向量，因此本书的矩阵用他们的方式表达时需要转置。他们通过点或向量右乘矩阵来施加变换，即 $p upright(bold(M))$，而本书采用矩阵左乘点，即 $upright(bold(M)) p$。本章只简要介绍了齐次坐标；它是射影几何的基础，并由此支撑了许多优雅的算法。Stolfi 的著作（#cite(label("10.5555/113163"))）是这一主题的优秀入门资料。
]


#parec[
  There are many good books on linear algebra and vector geometry. We have found Lang (#cite(label("lang1986introduction"))) and Buck (#cite(label("buck1978advanced"))) to be good references on these respective topics. See also Akenine-Möller et al.'s #emph[Real-Time Rendering] book (#cite(label("978-1138627000"))) for a solid graphics-based introduction to linear algebra. Ström et al. have written an excellent online linear algebra book, immersivemath.com, that features interactive figures that illustrate the key concepts (#cite(label("strom2020immersive"))).
][
  线性代数与向量几何方面有许多好书。Lang（#cite(label("lang1986introduction"))）和 Buck（#cite(label("buck1978advanced"))）分别是这两个主题的良好参考资料。Akenine-Möller 等人的《Real-Time Rendering》（#cite(label("978-1138627000"))）也以图形学为背景，扎实地介绍了线性代数。Ström 等人（#cite(label("strom2020immersive"))）编写了优秀的在线线性代数教材 #link("http://immersivemath.com")[immersivemath.com]，用交互式图形说明关键概念。
]


#parec[
  Donnay's book (#cite(label("donnay1945spherical"))) gives a concise but complete introduction to spherical trigonometry. The expression for the solid angle of a triangle in @eqt:triangle-solid-angle-better is due to Van Oosterom and Strackee (#cite(label("vanoosterom1983solid"))).
][
  Donnay 的著作（#cite(label("donnay1945spherical"))）简明而完整地介绍了球面三角学。@eqt:triangle-solid-angle-better 中三角形立体角的表达式由 Van Oosterom 和 Strackee（#cite(label("vanoosterom1983solid"))）提出。
]


#parec[
  An alternative approach for designing a vector math library is exemplified by the widely used eigen system by Guennebaud, Jacob, and others (#cite(label("guennebaud2010eigen"))). In addition to including support for CPU SIMD vector instruction sets, it makes extensive use of #emph[expression templates], a C++ programming technique that makes it possible to simplify and optimize the evaluation of vector and matrix expressions at compile time.
][
  Guennebaud、Jacob 等人开发的广泛使用的 Eigen 库（#cite(label("guennebaud2010eigen"))）体现了设计向量数学库的另一种思路。除支持 CPU 的 SIMD 向量指令集外，它还大量使用_表达式模板_。这种 C++ 技术可以在编译时简化并优化向量、矩阵表达式的计算。
]


#parec[
  The subtleties of how normal vectors are transformed were first widely understood in the graphics community after articles by Wallis (#cite(label("inproceedings"))) and Turkowski (#cite(label("TURKOWSKI1990539"))).
][
  Wallis（#cite(label("inproceedings"))）和 Turkowski（#cite(label("TURKOWSKI1990539"))）的文章发表后，法向量变换中的微妙之处才在图形学界得到广泛理解。
]


#parec[
  Cigolle et al. (#cite(label("cigolle2014survey"))) compared a wide range of approaches for compactly encoding unit vectors. The approach implemented in #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#OctahedralVector")[`OctahedralVector`] is due to Meyer et al. (#cite(label("meyer2010floating"))), who also showed that if 52 bits are used with this representation, the precision is equal to that of normalized #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`]s. (Our implementation also includes an improvement suggested by Cigolle et al. (#cite(label("cigolle2014survey"))).) The octahedral encoding it is based on was introduced by Praun and Hoppe (#cite(label("praun2003spherical"))).
][
  Cigolle 等人（#cite(label("cigolle2014survey"))）比较了多种单位向量紧凑编码方法。#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Spherical_Geometry.html#OctahedralVector")[`OctahedralVector`] 所实现的方法由 Meyer 等人（#cite(label("meyer2010floating"))）提出；他们还表明，若这一表示使用 52 位，其精度可以达到归一化 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#Vector3f")[`Vector3f`] 的精度。（我们的实现也加入了 Cigolle 等人（#cite(label("cigolle2014survey"))）提出的一项改进。）该方法所依据的八面体编码由 Praun 和 Hoppe（#cite(label("praun2003spherical"))）提出。
]


#parec[
  The equal-area sphere mapping algorithm in @spherical-parameterizations is due to Clarberg (#cite(label("clarberg2008fast"))); our implementation of the mapping functions is derived from the high-performance CPU SIMD implementation that accompanies that paper. The square-to-hemisphere mapping that it is based on was developed by Shirley and Chiu (#cite(label("shirley1997low"))).
][
  @spherical-parameterizations 中的等面积球面映射算法由 Clarberg（#cite(label("clarberg2008fast"))）提出；我们的映射函数由该论文附带的高性能 CPU SIMD 实现改编而来。其基础是 Shirley 和 Chiu（#cite(label("shirley1997low"))）提出的正方形到半球的映射。
]


#parec[
  The algorithm used in #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#CoordinateSystem")[`CoordinateSystem()`] is based on an approach first derived by Frisvad (#cite(label("frisvad2012building"))). The reformulation to improve numerical accuracy that we have used in our implementation was derived concurrently by Duff et al. (#cite(label("duff2017building"))) and by Max (#cite(label("max2017improved"))). The algorithm implemented in #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#RotateFromTo")[`RotateFromTo()`] was introduced by Möller and Hughes (#cite(label("doi:10.1080/10867651.1999.10487509"))), with an adjustment to the computation of the reflection vector due to Hughes (#cite(label("hughes2021personal"))).
][
  #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#CoordinateSystem")[`CoordinateSystem()`] 所用算法基于 Frisvad（#cite(label("frisvad2012building"))）最初推导的方法。我们用于提高数值精度的等价改写，由 Duff 等人（#cite(label("duff2017building"))）和 Max（#cite(label("max2017improved"))）同期提出。#link("https://pbr-book.org/4ed/Geometry_and_Transformations/Transformations.html#RotateFromTo")[`RotateFromTo()`] 中的算法由 Möller 和 Hughes（#cite(label("doi:10.1080/10867651.1999.10487509"))）提出，而反射向量计算中的调整来自 Hughes（#cite(label("hughes2021personal"))）。
]


#parec[
  The numerically robust #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#AngleBetween")[`AngleBetween()`] function defined in this chapter is due to Hatch (#cite(label("hatch2003right"))).
][
  本章数值稳健的 #link("https://pbr-book.org/4ed/Geometry_and_Transformations/Vectors.html#AngleBetween")[`AngleBetween()`] 函数由 Hatch（#cite(label("hatch2003right"))）提出。
]


#parec[
  An algorithm to compute a tight bounding cone for multiple direction vectors was given by Barequet and Elber (#cite(label("barequet2005optimal"))).
][
  Barequet 和 Elber（#cite(label("barequet2005optimal"))）给出了为多个方向向量计算紧包围锥的算法。
]
