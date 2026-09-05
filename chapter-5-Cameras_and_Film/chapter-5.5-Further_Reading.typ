#import "../template.typ": parec, ez_caption, source-cite

== #ez_caption[Further Reading][延伸阅读]
<cameras-further-reading>

#parec[
  In his seminal Sketchpad system, Sutherland (#source-cite("Sutherland63")) was the first to use projection matrices for computer graphics. Akenine-Möller et al. (#source-cite("Moller18")) have provided a particularly well-written derivation of the orthographic and perspective projection matrices. Other good references for projections are Rogers and Adams’s Mathematical Elements for Computer Graphics (#source-cite("Rogers90")) and Eberly’s book (#source-cite("Eberly01")) on game engine design. See Adams and Levoy (#source-cite("Adams2007")) for a broad analysis of the types of radiance measurements that can be taken with cameras that have non-pinhole apertures.
][
  Sutherland（#source-cite("Sutherland63")）在开创性的 Sketchpad 系统中，首次将投影矩阵用于计算机图形学。Akenine-Möller 等人（#source-cite("Moller18")）对正交与透视投影矩阵给出了尤其清晰的推导。其他优秀参考资料包括 Rogers 和 Adams 的《Mathematical Elements for Computer Graphics》（#source-cite("Rogers90")），以及 Eberly 关于游戏引擎设计的著作（#source-cite("Eberly01")）。Adams 和 Levoy（#source-cite("Adams2007")）广泛分析了采用非针孔光圈的相机能够进行哪些辐亮度测量。
]

#parec[
  An unusual projection method was used by Greene and Heckbert (#source-cite("Greene86ewa")) for generating images for OMNIMAX® theaters.
][
  Greene 和 Heckbert（#source-cite("Greene86ewa")）采用了一种特殊的投影方法，为 OMNIMAX® 影院生成图像。
]

#parec[
  Potmesil and Chakravarty (#source-cite("Potmesil81"), #source-cite("Potmesil82"), #source-cite("Potmesil83")) did early work on depth of field and motion blur in computer graphics. Cook and collaborators developed a more accurate model for these effects based on the thin lens model; this is the approach used for the depth of field calculations in @thin-lens-model-and-depth-of-field (Cook et al. #source-cite("Cook84"); Cook #source-cite("Cook86")). An alternative approach to motion blur was described by Gribel and Akenine-Möller (#source-cite("Gribel2017")), who analytically computed the time ranges of ray–triangle intersections to eliminate stochastic sampling in time.
][
  Potmesil 和 Chakravarty（#source-cite("Potmesil81")、#source-cite("Potmesil82")、#source-cite("Potmesil83")）较早研究了计算机图形学中的景深和运动模糊。Cook 及其合作者基于薄透镜模型，为这些效应建立了更准确的模型；@thin-lens-model-and-depth-of-field 中的景深计算就采用这种方法（Cook 等人 #source-cite("Cook84")；Cook #source-cite("Cook86")）。Gribel 和 Akenine-Möller（#source-cite("Gribel2017")）则解析地计算射线与三角形相交的时间区间，从而消除时间维度的随机采样，提供了另一种处理运动模糊的方法。
]

#parec[
  Kolb, Mitchell, and Hanrahan (#source-cite("Kolb95")) showed how to simulate complex camera lens systems with ray tracing in order to model the imaging effects of real cameras; the RealisticCamera is based on their approach. Steinert et al. (#source-cite("Steinert2011")) improved a number of details of this simulation, incorporating wavelength-dependent effects and accounting for both diffraction and glare. Joo et al. (#source-cite("Joo2016")) extended this approach to handle aspheric lenses and modeled diffraction at the aperture stop, which causes some brightening at the edges of the circle of confusion in practice. See the books by Hecht (#source-cite("Hecht2002")) and Smith (#source-cite("Smith2007")) for excellent introductions to optics and lens systems.
][
  Kolb、Mitchell 和 Hanrahan（#source-cite("Kolb95")）展示了如何通过射线追踪模拟复杂的相机镜头系统，以再现真实相机的成像效果；`RealisticCamera` 就基于他们的方法。Steinert 等人（#source-cite("Steinert2011")）改进了这一模拟的多处细节，加入波长相关效应，并考虑衍射和眩光。Joo 等人（#source-cite("Joo2016")）将其推广到非球面透镜，还模拟了孔径光阑处的衍射；实际中，这会使弥散圆的边缘略微变亮。Hecht（#source-cite("Hecht2002")）与 Smith（#source-cite("Smith2007")）的著作是光学和镜头系统的优秀入门资料。
]

#parec[
  Hullin et al. (#source-cite("Hullin2012")) used polynomials to model the effect of lenses on rays passing through them; they were able to construct polynomials that approximate entire lens systems from polynomial approximations of individual lenses. This approach saves the computational expense of tracing rays through lenses, though for complex scenes, this cost is generally negligible in relation to the rest of the rendering computations. Hanika and Dachsbacher (#source-cite("Hanika2014")) improved the accuracy of this approach and showed how to combine it with bidirectional path tracing. Schrade et al. (#source-cite("Schrade2016")) showed good results with approximation of wide-angle lenses using sparse higher-degree polynomials.
][
  Hullin 等人（#source-cite("Hullin2012")）用多项式模拟透镜对穿过它的射线的影响，并从单个透镜的多项式近似构造出整个镜头系统的多项式近似。这省去了逐片追踪射线的计算开销，不过在复杂场景中，相对于其他渲染计算，这部分开销通常可以忽略。Hanika 和 Dachsbacher（#source-cite("Hanika2014")）提高了这一方法的精度，并展示了如何将其与双向路径追踪结合。Schrade 等人（#source-cite("Schrade2016")）用稀疏高次多项式近似广角镜头，取得了良好结果。
]

#heading(level: 3, numbering: none)[#ez_caption[Film and Imaging][胶片与成像]]

#parec[
  The film sensor model presented in @modeling-sensor-response and the PixelSensor class implementation are from the PhysLight system described by Langlands and Fascione (#source-cite("Langlands2020")). See also Chen et al. (#source-cite("Chen2009")), who described the implementation of a fairly complete simulation of a digital camera, including the analog-to-digital conversion and noise in the measured pixel values inherent in this process.
][
  @modeling-sensor-response 中的胶片传感器模型及 `PixelSensor` 的实现来自 Langlands 和 Fascione（#source-cite("Langlands2020")）介绍的 PhysLight 系统。Chen 等人（#source-cite("Chen2009")）还描述了相当完整的数码相机模拟，包括模数转换以及这一过程在像素测量值中固有的噪声。
]

#parec[
  Filter importance sampling, as described in @image-reconstruction, was described in a paper by Ernst et al. (#source-cite("Ernst2006")). This technique is also proposed in Shirley’s Ph.D. thesis (#source-cite("Shirley90phd")).
][
  @image-reconstruction 中介绍的滤波重要性采样见于 Ernst 等人（#source-cite("Ernst2006")）的论文。Shirley（#source-cite("Shirley90phd")）的博士论文也提出了这项技术。
]

#parec[
  The idea of storing additional information about the properties of the visible surface in a pixel was introduced by Perlin (#source-cite("Perlin85")) and Saito and Takahashi (#source-cite("Saito90")), who also coined the term G-Buffer. Shade et al. (#source-cite("Shade98")) introduced the generalization of storing information about all the surfaces along each camera ray and applied this representation to view interpolation, using the originally hidden surfaces to handle disocclusion.
][
  在像素中保存可见表面属性的额外信息，这一想法由 Perlin（#source-cite("Perlin85")）以及 Saito 和 Takahashi（#source-cite("Saito90")）提出；后两位作者还创造了 G-Buffer 一词。Shade 等人（#source-cite("Shade98")）进一步保存每条相机射线沿途所有表面的信息，并将这种表示用于视图插值，利用原先隐藏的表面处理遮挡解除后显露的区域。
]

#parec[
  Celarek et al. (#source-cite("Celarek2019")) developed techniques for evaluating sampling schemes based on computing both the expectation and variance of MSE and described approaches for evaluating error in rendered images across both pixels and frequencies.
][
  Celarek 等人（#source-cite("Celarek2019")）通过计算 MSE 的期望与方差来评估采样方案，并讨论了从像素域和频率域两个角度评估渲染图像误差的方法。
]

#parec[
  The sampling technique that approximates the XYZ matching curves is due to Radziszewski et al. (#source-cite("Radziszewski2009")).
][
  近似 XYZ 匹配曲线的波长采样技术由 Radziszewski 等人（#source-cite("Radziszewski2009")）提出。
]

#parec[
  The SpectralFilm uses a representation for spectral images in the OpenEXR format that was introduced by Fichet et al. (#source-cite("Fichet2021")).
][
  `SpectralFilm` 采用了 Fichet 等人（#source-cite("Fichet2021")）提出的 OpenEXR 光谱图像表示格式。
]

#parec[
  As discussed in @modeling-sensor-response, the human visual system generally factors out the illumination color to perceive surfaces’ colors independently of it. A number of methods have been developed to process photographs to perform white balancing to eliminate the tinge of light source colors; see Gijsenij et al. (#source-cite("Gijsenij2011")) for a survey. White balancing photographs can be challenging, since the only information available to white balancing algorithms is the final pixel values. In a renderer, the problem is easier, as information about the light sources is directly available; Wilkie and Weidlich (#source-cite("Wilkie2009")) developed an efficient method to perform accurate white balancing in a renderer.
][
  如 @modeling-sensor-response 所述，人类视觉系统通常会消除照明颜色的影响，从而相对独立地感知表面颜色。研究者提出了许多对照片进行白平衡处理的方法，以去除光源颜色造成的偏色；Gijsenij 等人（#source-cite("Gijsenij2011")）对此作了综述。照片白平衡很有挑战性，因为算法只能获得最终的像素值。渲染器可以直接获取光源信息，因此问题更容易处理；Wilkie 和 Weidlich（#source-cite("Wilkie2009")）提出了在渲染器中高效、准确进行白平衡的方法。
]

#heading(level: 3, numbering: none)[#ez_caption[Denoising][去噪]]

#parec[
  A wide range of approaches have been developed for removing Monte Carlo noise from rendered images. Here we will discuss those that are based on the statistical characteristics of the sample values themselves. In the “Further Reading” section of Chapter 8, we will discuss ones that derive filters that account for the underlying light transport equations used to form the image. Zwicker et al.’s report (#source-cite("Zwicker15")) has thorough coverage of both approaches to denoising through 2015. We will therefore focus here on some of the foundational work as well as more recent developments.
][
  已有许多方法用于消除渲染图像中的蒙特卡洛噪声。这里讨论基于样本值自身统计特性的方法；第8章的“延伸阅读”则讨论根据成像所依据的光传输方程推导滤波器的方法。Zwicker 等人（#source-cite("Zwicker15")）的报告全面介绍了截至2015年的这两类去噪方法，因此这里重点介绍一些奠基性工作和较新的进展。
]

#parec[
  Lee and Redner (#source-cite("Lee90")) suggested using an alpha-trimmed mean filter for this task; it discards some number of samples at the low and high range of the sample values. The median filter, where all but a single sample are discarded, is a special case of it. Jensen and Christensen (#source-cite("Jensen95noise")) observed that it can be effective to separate out the contributions to pixel values based on the type of illumination they represent; low-frequency indirect illumination can be filtered differently from high-frequency direct illumination, thus reducing noise in the final image. They developed an effective filtering technique based on this observation.
][
  Lee 和 Redner（#source-cite("Lee90")）建议采用 alpha 截尾均值滤波器，丢弃样本值两端的一部分样本。只保留一个样本的中值滤波器是其特例。Jensen 和 Christensen（#source-cite("Jensen95noise")）观察到，按照明类型分离像素贡献往往很有效：对低频间接照明与高频直接照明采用不同的滤波方式，可以降低最终图像的噪声。他们据此提出了一种有效的滤波技术。
]

#parec[
  McCool (#source-cite("McCool1999")) used the depth, surface normal, and color at each pixel to determine how to blend pixel values with their neighbors in order to better preserve edges in the filtered image. Keller and collaborators introduced the discontinuity buffer (Keller #source-cite("Keller98"); Wald et al. #source-cite("Wald02")). In addition to filtering slowly varying quantities like indirect illumination separately from more quickly varying quantities like surface reflectance, the discontinuity buffer also uses geometric quantities like the surface normal to determine filter extents.
][
  McCool（#source-cite("McCool1999")）根据每个像素的深度、表面法向量和颜色，确定如何与邻近像素混合，以更好地保留滤波图像中的边缘。Keller 及其合作者提出了不连续性缓冲区（Keller #source-cite("Keller98")；Wald 等人 #source-cite("Wald02")）。它不仅分别处理间接照明等缓慢变化的量与表面反射率等变化较快的量，还利用表面法向量等几何信息确定滤波范围。
]

#parec[
  Dammertz et al. (#source-cite("Dammertz2010")) introduced a denoising algorithm based on edge-aware image filtering, applied hierarchically so that very wide kernels can be used with good performance. This approach was improved by Schied et al. (#source-cite("Schied2017")), who used estimates of variance at each pixel to set filter widths and incorporated temporal reuse, using filtered results from the previous frame in a real-time ray tracer. Bitterli et al. (#source-cite("Bitterli2016")) analyzed a variety of previous denoising techniques in a unified framework and derived a new approach based on a first-order regression of pixel values. Boughida and Boubekeur (#source-cite("Boughida2017")) described a Bayesian approach based on statistics of all the samples in a pixel, and Vicini et al. (#source-cite("Vicini2019")) considered the problem of denoising “deep” images, where each pixel may contain multiple color values, each at a different depth.
][
  Dammertz 等人（#source-cite("Dammertz2010")）提出了基于边缘感知图像滤波的去噪算法，以层次方式应用滤波，从而能够高效使用很宽的核。Schied 等人（#source-cite("Schied2017")）进一步用每个像素的方差估计设置滤波宽度，并在实时射线追踪器中复用前一帧的滤波结果。Bitterli 等人（#source-cite("Bitterli2016")）在统一框架下分析了多种已有去噪技术，并推导出基于像素值一阶回归的新方法。Boughida 和 Boubekeur（#source-cite("Boughida2017")）提出了基于像素内全部样本统计的贝叶斯方法。Vicini 等人（#source-cite("Vicini2019")）则研究了深度图像（deep image）的去噪：这类图像的每个像素可以在不同深度处包含多个颜色值。
]

#parec[
  Some filtering techniques focus solely on the outlier pixels that result when the sampling probability in the Monte Carlo estimator is a poor match to the integrand and is far too small for a sample. (As mentioned previously, the resulting pixels are sometimes called “fireflies,” in a nod to their bright transience.) Rushmeier and Ward (#source-cite("Rushmeier1994")) developed an early technique to address this issue based on detecting outlier pixels and spreading their energy to nearby pixels in order to maintain an unbiased estimate of the true image. DeCoro et al. (#source-cite("DeCoro2010")) suggested storing all pixel sample values and then rejecting outliers before filtering them to compute final pixel values. Zirr et al. (#source-cite("Zirr2018")) proposed an improved approach that uses the distribution of sample values at each pixel to detect and reweight outlier samples. Notably, their approach does not need to store all the individual samples, but can be implemented by partitioning samples into one of a small number of image buffers based on their magnitude. More recently, Buisine et al. (#source-cite("Buisine2021")) proposed using a median of means filter, which is effective at removing outliers but has slower convergence than the mean. They therefore dynamically select between the mean and median of means depending on the characteristics of the sample values.
][
  有些滤波方法专门处理离群像素：当蒙特卡洛估计量的采样概率与被积函数匹配不佳，对某个样本而言概率过小时，就可能出现这类像素。（前面提到的“萤火虫”名称，就是形容它们短暂而明亮的表现。）Rushmeier 和 Ward（#source-cite("Rushmeier1994")）较早通过检测离群像素，并把其能量分配给邻近像素来处理这一问题，以保持对真实图像的无偏估计。DeCoro 等人（#source-cite("DeCoro2010")）建议保存所有像素样本值，先剔除离群值，再滤波计算最终像素值。Zirr 等人（#source-cite("Zirr2018")）根据各像素的样本值分布检测离群样本并重新赋权。他们无需保存每个样本，只需按样本值大小将样本分配到少量图像缓冲区。Buisine 等人（#source-cite("Buisine2021")）提出均值中位数滤波器，虽能有效去除离群值，但收敛速度比均值慢，因此根据样本值的特征在均值与均值中位数之间动态选择。
]

#parec[
  As with many other areas of image processing and understanding, techniques based on machine learning have recently been applied to denoising rendered images. This work started with Kalantari et al. (#source-cite("Kalantari2015")), who used relatively small neural networks to determine parameters for conventional denoising filters. Approaches based on deep learning and convolutional neural networks soon followed with Bako et al. (#source-cite("Bako2017")), Chaitanya et al. (#source-cite("Chaitanya2017")), and Vogels et al. (#source-cite("Vogels2018")) developing autoencoders based on the u-net architecture (Ronneberger et al. #source-cite("Ronneberger2015")). Xu et al. (#source-cite("Xu2019")) applied adversarial networks to improve the training of such denoisers. Gharbi et al. (#source-cite("Gharbi2019")) showed that filtering the individual samples with a neural network can give much better results than sampling the pixels with the samples already averaged. Munkberg and Hasselgren (#source-cite("Munkberg2020")) described an architecture that reduces the memory and computation required for this approach.
][
  与图像处理和理解中的许多其他领域一样，机器学习也被用于渲染图像去噪。Kalantari 等人（#source-cite("Kalantari2015")）率先用较小的神经网络确定传统去噪滤波器的参数。随后，Bako 等人（#source-cite("Bako2017")）、Chaitanya 等人（#source-cite("Chaitanya2017")）和 Vogels 等人（#source-cite("Vogels2018")）采用深度学习与卷积神经网络，开发了基于 U-Net 架构（Ronneberger 等人 #source-cite("Ronneberger2015")）的自动编码器。Xu 等人（#source-cite("Xu2019")）用对抗网络改进去噪器训练。Gharbi 等人（#source-cite("Gharbi2019")）表明，用神经网络对单个样本滤波，可以比在样本已取平均后的像素上进行采样取得更好结果。Munkberg 和 Hasselgren（#source-cite("Munkberg2020")）则提出了减少这一方法内存和计算需求的架构。
]
