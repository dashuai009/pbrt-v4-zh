#import "../template.typ": parec, translator


== Further Reading
<further-reading>

#parec[
  The pbrt scene file format is custom, which has allowed us to tailor it
  to present all the system’s capabilities, though it makes it more
  challenging to import scenes from other systems, requiring a conversion
  step. (See the pbrt website for links to a number of such converters.)
][
  pbrt
  场景文件格式是定制的，因此能够充分展示系统的全部功能，但也因此在从其他系统导入场景时更具挑战性，需要经过一次转换步骤。请参阅
  pbrt 网站，以获取此类转换器的链接。

]
#parec[
  There has been little standardization in these file formats; many 3D
  graphics file formats have been developed, in part due to the needs of
  graphics systems changing over time and in part due to lack of
  standardization on material and texture models. In addition to its own
  text format, pbrt does support the PLY format for specifying polygon
  meshes, which was originally developed by Greg Turk in the 1990s. PLY
  provides both text and binary encodings; the latter can be parsed fairly
  efficiently. Pixar’s #emph[RenderMan] interface
  (#link("<cite:Upsill89>")[Upstill 1989];;
  #link("<cite:Apodaca00>")[Apodaca and Gritz 2000];) saw some adoption in
  past decades, and the ambitiously named #emph[Universal Scene
    Description] (USD) format is currently widely used in film production
  (#link("<cite:Pixar20>")[Pixar Animation Studios 2020];).
][

  这些文件格式缺乏统一标准，标准化程度很低。已开发出许多3D图形文件格式，这既源于图形系统需求随时间的变化，也源于材料与纹理模型缺乏统一标准。除了自身的文本格式外，pbrt
  还支持用于定义多边形网格的 PLY 格式，该格式最初由 Greg Turk 在1990
  年代开发。PLY 提供文本编码与二进制编码，后者解析效率较高。Pixar 的
  #emph[RenderMan] 接口（#link("<cite:Upsill89>")[Upstill 1989];;
  #link("<cite:Apodaca00>")[Apodaca and Gritz 2000];）在过去几十年中有所采用，名为
  #emph[Universal Scene
    Description];（USD）格式现已在电影制作领域被广泛应用（#link("<cite:Pixar20>")[Pixar Animation Studios 2020];）。
]
