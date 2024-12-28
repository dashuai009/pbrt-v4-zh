#import "../template.typ": parec
== Further Reading

#parec[
  DeRose, Goldman, and their collaborators have argued for an elegant “coordinate-free” approach to describing vector geometry for graphics, where the fact that positions and directions happen to be represented by coordinates with respect to a particular coordinate system is deemphasized and where points and vectors themselves record which coordinate system they are expressed in terms of (Goldman 1985; DeRose 1989; Mann et al. 1997). This makes it possible for a software layer to ensure that common errors like adding a vector in one coordinate system to a point in another coordinate system are transparently handled by transforming them to a common coordinate system first. A related approach was described by Geisler et al. (2020), who encoded coordinate systems using the programming language's type system. We have not followed either of these approaches in pbrt, although the principles behind them are well worth understanding and keeping in mind when working with coordinate systems in computer graphics.
][
  DeRose、Goldman 和他们的合作者主张采用一种优雅的“无坐标”方法来描述图形的向量几何，其中位置和方向恰好由下式表示： 相对于特定坐标系的坐标不再被强调，点和向量本身记录它们所表达的坐标系（ Goldman 1985 ； DeRose 1989 ； Mann et al. 1997 ）。这使得软件层可以确保通过首先将一个坐标系中的向量添加到另一个坐标系中的点等常见错误将其转换为公共坐标系来透明地处理它们。 Geisler 等人描述了一种相关的方法。 ( 2020 )，他使用编程语言的类型系统对坐标系统进行编码。我们没有遵循这些方法中的任何一种 pbrt ，尽管在使用计算机图形学中的坐标系时，它们背后的原理非常值得理解和牢记。
]


#parec[
  Schneider and Eberly's Geometric Tools for Computer Graphics is influenced by the coordinate-free approach and covers the topics of this chapter in much greater depth (Schneider and Eberly 2003). It is also full of useful geometric algorithms for graphics. A classic and more traditional introduction to the topics of this chapter is Mathematical Elements for Computer Graphics by Rogers and Adams (1990). Note that their book uses a row-vector representation of points and vectors, however, which means that our matrices would be transposed when expressed in their framework, and that they multiply points and vectors by matrices to transform them , rather than multiplying matrices by points as we do . Homogeneous coordinates were only briefly mentioned in this chapter, although they are the basis of projective geometry, where they are the foundation of many elegant algorithms. Stolfi's book is an excellent introduction to this topic (Stolfi 1991).
][
  Schneider 和 Eberly 的计算机图形学几何工具受到无坐标方法的影响，并且更深入地涵盖了本章的主题（Schneider 和 Eberly 2003 ）。它还充满了有用的图形几何算法。对本章主题的经典且更传统的介绍是 Rogers 和 Adams 的《计算机图形学数学原理》 （ 1990 年）。请注意，他们的书使用点和向量的行向量表示，这意味着我们的矩阵在他们的框架中表达时将被转置，并且他们将点和向量乘以矩阵来转换它们 ，而不是像我们那样将矩阵乘以点 。尽管齐次坐标是射影几何的基础，也是许多优雅算法的基础，但本章仅简要提及齐次坐标。 Stolfi 的书对这个主题做了很好的介绍（ Stolfi 1991 ）。
]


#parec[
  There are many good books on linear algebra and vector geometry. We have found Lang (1986) and Buck (1978) to be good references on these respective topics. See also Akenine-Möller et al.'s Real-Time Rendering book (2018) for a solid graphics-based introduction to linear algebra. Ström et al. have written an excellent online linear algebra book, immersivemath.com, that features interactive figures that illustrate the key concepts (2020).
][
  有很多关于线性代数和向量几何的好书。我们发现 Lang（ 1986 ）和 Buck（ 1978 ）对于这些各自的主题都是很好的参考文献。另请参阅 Akenine-Möller 等人的《实时渲染》一书 ( 2018 )，了解基于图形的线性代数详细介绍。斯特罗姆等人。撰写了一本优秀的在线线性代数书籍， immersivemath.com ，其中包含阐释关键概念的交互式图形（ 2020 ）。
]


#parec[
  Donnay's book (1945) gives a concise but complete introduction to spherical trigonometry. The expression for the solid angle of a triangle in Equation (3.6) is due to Van Oosterom and Strackee (1983).
][
  Donnay 的书（ 1945 ）对球面三角学进行了简洁而完整的介绍。方程 ( 3.6 ) 中三角形立体角的表达式源自 Van Oosterom 和 Strackee ( 1983 )。
]


#parec[
  An alternative approach for designing a vector math library is exemplified by the widely used eigen system by Guennebaud, Jacob, and others (2010). In addition to including support for CPU SIMD vector instruction sets, it makes extensive use of expression templates, a C++ programming technique that makes it possible to simplify and optimize the evaluation of vector and matrix expressions at compile time.
][
  Guennebaud、Jacob 等人广泛使用的特征系统（ 2010 ）举例说明了设计向量数学库的另一种方法。除了支持 CPU SIMD 向量指令集之外，它还广泛使用表达式模板，这是一种 C++ 编程技术，可以在编译时简化和优化向量和矩阵表达式的计算。
]


#parec[
  The subtleties of how normal vectors are transformed were first widely understood in the graphics community after articles by Wallis (1990) and Turkowski (1990b).
][
  在 Wallis ( 1990 ) 和 Turkowski ( 1990b ) 发表文章之后，法向量变换的微妙之处首次在图形界被广泛理解。
]


#parec[
  Cigolle et al. (2014) compared a wide range of approaches for compactly encoding unit vectors. The approach implemented in OctahedralVector is due to Meyer et al. (2010), who also showed that if 52 bits are used with this representation, the precision is equal to that of normalized Vector3fs. (Our implementation also includes an improvement suggested by Cigolle et al. (2014).) The octahedral encoding it is based on was introduced by Praun and Hoppe (2003).
][
  西戈勒等人。 ( 2014 ) 比较了多种紧凑编码单位向量的方法。该方法实施于 OctahedralVector 是由于迈耶等人。 ( 2010 )，他还表明，如果使用 52 位表示该表示，则精度等于归一化的精度 Vector3f s。 （我们的实现还包括 Cigolle 等人 ( 2014 ) 建议的改进。）它所基于的八面体编码是由 Praun 和 Hoppe ( 2003 ) 引入的。
]


#parec[
  The equal-area sphere mapping algorithm in Section 3.8.3 is due to Clarberg (2008); our implementation of the mapping functions is derived from the high-performance CPU SIMD implementation that accompanies that paper. The square-to-hemisphere mapping that it is based on was developed by Shirley and Chiu (1997).
][
  第3.8.3节中的等积球面映射算法源自 Clarberg ( 2008 )；我们对映射函数的实现源自该论文随附的高性能 CPU SIMD 实现。它所基于的正方形到半球的映射是由 Shirley 和 Chiu ( 1997 ) 开发的。
]


#parec[
  The algorithm used in CoordinateSystem() is based on an approach first derived by Frisvad (2012). The reformulation to improve numerical accuracy that we have used in our implementation was derived concurrently by Duff et al. (2017) and by Max (2017). The algorithm implemented in RotateFromTo() was introduced by Möller and Hughes (1999), with an adjustment to the computation of the reflection vector due to Hughes (2021).
][
  使用的算法 CoordinateSystem() 基于 Frisvad ( 2012 ) 首次提出的方法。我们在实施中使用的用于提高数值准确性的重新表述是由 Duff 等人同时得出的。 （ 2017 ）和麦克斯（ 2017 ）。该算法实现于 RotateFromTo() 由 Möller 和 Hughes ( 1999 ) 引入，并根据 Hughes ( 2021 ) 对反射矢量的计算进行了调整。
]


#parec[
  The numerically robust AngleBetween() function defined in this chapter is due to Hatch (2003).
][
  数值稳健 AngleBetween() 本章中定义的函数源自 Hatch ( 2003 )。
]


#parec[
  An algorithm to compute a tight bounding cone for multiple direction vectors was given by Barequet and Elber (2005).
][
  Barequet 和 Elber ( 2005 ) 给出了一种计算多个方向向量的紧密包围锥的算法。
]
