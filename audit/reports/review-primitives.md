# 第七章独立复核记录

固定子模块 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c。已读EDITORIAL第七章术语决议。第一批独占7.0/7.1/7.2和supplements/7.1-expanded.typ，初校报告只作范围线索；重新完整读固定原书Primitives_and_Intersection_Acceleration.html、Primitive_Interface_and_Geometric_Primitives.html、Aggregates.html及全部本地中英内容。未使用旧Scripts。

## 第一批：7.0–7.2独立语义复核通过，已释放

7.0全部4原段；7.2全部7原段（本地分10对双语段）；7.1完整接口、GeometricPrimitive/随机alpha、SimplePrimitive、对象实例化、TransformedPrimitive及AnimatedPrimitive所有段落。26个可见代码、fragbit965–983共19折叠面板逐体重读比较，不依据数量通过。965继承构造、966介质分支、967/976/978/982各类额外声明分别与supplement核对；968/977/979/983成员与正文一致；969–975 alpha嵌套片段及980/981变换求交片段完整映射。没有编号公式、表格或习题。

图7.1固定/随机alpha三部分及完整图注、图7.2固定源Jeri所加载landscape-above.png与完整图注均对照；1条上一版pbrt的7GB内存脚注完整保留。内存/实例数据逐项核对：23,241株/31模型/31亿实例三角形/2400万独立三角形/4GB以上与516GB以上/1.7GB+707MB+877MB+846MB/32字节/696与128字节，保留“开发机器上”的限定。

关键约束完整：本章CPU而GPU另用API；Primitive内SurfaceInteraction属性；alpha零/一存在性、中间随机结果而非透射率；HashFloat跨运行确定性与不同射线随机值；拒绝最近球面命中后对同一图元递归、tMax扣段/tHit加段；Simple轻量类条件；实例底层局部“渲染空间”不等于场景渲染空间；额外变换只应用一次；聚合体不覆盖实际图元材质/光源/介质；空间/对象划分及近命中“更可能”而非必然。

本次中文修复仅两处：`initial alpha tested intersection`原译“初次接受alpha测试的交点”容易被理解为alpha测试接受了该交点，改“最初进行alpha测试的交点”；“双线性曲面片”统一为术语表的“双线性面片”。重读这两句及相关代码确认语义。

## 固定原书未决项

重新在全部固定4ed HTML中查找spinning-spheres，唯一命中为7.1源HTML第728行直接印出的 `Figure fig:spinning-spheres`，不是可用链接/锚点。本页可用图片只有7.1及7.2等已有内容；没有凭名字猜图、补造编号或拿旧版替代。正文原文字串与现有双语说明保留。这属于明确说明的原书引用缺陷，独立覆盖通过并不表示该图已找到。

## 验证

修改后0.13.1+fonts隔离7.0–7.2三语编译无警告，`/tmp/review-primitives-first-{zh,en,bi}.pdf`；外节ref占位，因此只作局部语法。实际查看双语9、10、11页：alpha/轻量类代码、图7.2原图和完整图注、全部实例内存数字与双语7GB脚注无裁切。图在隔离入口编号1.2，不作为正式全书编号证据。相应图像`/tmp/review-primitives-first-{9,10,11}.png`。

7.0/7.1/7.2及supplement已释放；未审7.3–7.5，未声明正式全书PDF、网页或发布验收通过。
