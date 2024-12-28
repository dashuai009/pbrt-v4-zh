#import "../template.typ": parec

== Exercises

#parec[
  + #emoji.cat.face.laugh Similarly The third through fifth dimensions of every sample are currently
    consumed for time and lens samples in `pbrt`, even though not all
    scenes need these sample values. For some sample generation
    algorithms, lower dimensions in the sample are better distributed than
    higher ones and so this can cause an unnecessary reduction in image
    quality.Modify `pbrt` so that the camera can report its sample requirements and then use this information when samples are requested to initialize #link("../Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`];s. Render images and compare results to the current implementation. Do you see an improvement? How do results differ with different samplers? How do you explain any differences you see across samplers?
][
  + #emoji.cat.face.laugh Similarly 在 `pbrt` 中，每个样本的第三至第五维目前用于时间和镜头样本，即使并不是所有场景都需要使用这些样本值。对于某些样本生成算法，低维度样本比高维度样本分布得更好，因此这可能导致图像质量不必要的下降。 修改 `pbrt` 以便相机可以报告其样本需求，然后在请求样本时使用此信息初始化 #link("../Cameras_and_Film/Camera_Interface.html#CameraSample")[`CameraSample`];。渲染图像并将结果与当前实现进行比较。你看到改进了吗？不同采样器的结果有什么不同？你如何解释跨采样器看到的任何差异？
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 2)
    + #emoji.cat.face.laugh Similarly Keller (#link("Further_Reading.html#cite:Keller2004")[2004];) and
      Dammertz and Keller
      (#link("Further_Reading.html#cite:Dammertz2008b")[2008b];) described
      the application of #emph[rank-1 lattices] to image synthesis. Rank-1
      lattices are another way of efficiently generating high-quality
      low-discrepancy sets of sample points.Read their papers and implement a `Sampler` based on this approach. Compare results to the other samplers in `pbrt`.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 2)
    + #emoji.cat.face.laugh Similarly Keller (#link("Further_Reading.html#cite:Keller2004")[2004];) 和
      Dammertz 和 Keller
      (#link("Further_Reading.html#cite:Dammertz2008b")[2008b];) 描述了
      #emph[rank-1 lattices] 在图像合成中的应用。Rank-1 lattices
      是另一种有效生成高质量低差异样本点集合的方法。阅读他们的论文并基于这种方法来实现一个 `Sampler`。将结果与 `pbrt` 中的其他采样器进行比较。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 3)
    + #emoji.cat.face.laugh Similarly Implement a
      #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`]
      based on orthogonal array sampling, as described by Jarosz et
      al.~(#link("Further_Reading.html#cite:Jarosz2019")[2019];). Compare
      both MSE and Monte Carlo efficiency of this sampler to `pbrt`'s
      current samplers.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 3)
    + #emoji.cat.face.laugh Similarly 实现一个基于正交数组采样的
      #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`];，如
      Jarosz 等人所述
      (#link("Further_Reading.html#cite:Jarosz2019")[2019];)。将此采样器的均方误差（MSE）和蒙特卡罗效率与
      `pbrt` 当前的采样器进行比较。
  ]
]

#parec[
  #block[
    #set enum(numbering: "1.", start: 4)
    + #emoji.cat.face.shock Mitchell and Netravali (#link("Further_Reading.html#cite:Mitchell88")[1988];) noted that there is a family of reconstruction filters that use both the value of a function and its derivative at the point to do substantially better reconstruction than if just the value of the function is known. Furthermore, they report that they have derived closed-form expressions for the screen space derivatives of Lambertian and Phong reflection models, although they do not include these expressions in their paper. Investigate derivative-based reconstruction, and extend `pbrt` to support this technique. If you decide to shy away from deriving expressions for the screen space derivatives for general shapes and BSDF models, you may want to investigate approximations based on finite differencing and the ideas behind the ray differentials of Section~#link("../Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#sec:texture-anti-aliasing")[10.1];.
  ]
][
  #block[
    #set enum(numbering: "1.", start: 4)
    + #emoji.cat.face.shock Mitchell 和 Netravali (#link("Further_Reading.html#cite:Mitchell88")[1988];) 指出有一类重建滤波器使用函数值及其在点处的导数来进行比仅知道函数值更好的重建。 此外，他们报告说他们已经推导出 Lambertian 和 Phong 反射模型的屏幕空间导数的闭合形式表达式，尽管他们没有在论文中包含这些表达式。 研究基于导数的重建方法，并扩展 `pbrt` 以支持这种技术。如果你决定不进行推导一般形状和 BSDF 模型的屏幕空间导数的表达式，你可能需要研究基于有限差分的近似方法和第 #link("../Textures_and_Materials/Texture_Sampling_and_Antialiasing.html#sec:texture-anti-aliasing")[10.1] 节中光线微分的思想。
  ]
]


#parec[
  #block[
    #set enum(numbering: "1.", start: 5)
    + #emoji.cat.face.shock Read some of the papers on adaptive sampling and reconstruction
      techniques from the "Further Reading" section and implement one of
      these techniques in `pbrt`. Note that you will likely need to both
      write a new
      #link("../Sampling_and_Reconstruction/Sampling_Interface.html#Sampler")[`Sampler`]
      and add additional
      #link("../Cameras_and_Film/Film_and_Imaging.html#Film")[`Film`]
      functionality. Measure the effectiveness of the approach you have implemented using Monte Carlo efficiency in order to account for any increased computational cost. How well does your implementation perform compared to non-adaptive samplers?
  ]
][
  #block[
    #set enum(numbering: "1.", start: 5)
    + #emoji.cat.face.shock 阅读“进一步阅读”部分中关于自适应采样和重建技术的一些论文，并在 `pbrt` 中实现其中一种技术。请注意，你可能需要编写一个新的 \[`Sampler`\]
      并添加额外的 \[`Film`\] 功能。 使用蒙特卡罗效率来衡量你实现的方法的有效性，以便考虑任何增加的计算成本。你的实现与非自适应采样器相比表现得如何？
  ]
]


