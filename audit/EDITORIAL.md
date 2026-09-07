# 全书审校规范

基线：主仓库初始提交 9e0ba8bd373932cd5fbab2d4ad9b13b1788b2d4e；开始时工作区干净。原书固定为子模块提交 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c 的 4ed 内容。禁止运行或依赖 Scripts 内旧翻译、转换、润色程序及其结论。

逐段对照固定原书 HTML、已有英文、中文，兼顾相邻上下文。正文、标题、图注、表格、脚注、代码片段、公式、延伸阅读、习题、附录、索引均须核对。英文必须保留；转录错误只能依据固定原文修复，并记录原文路径与锚点。代码标识符不翻译；公式仅在有原文依据的转换修复中改动。

中文用全角标点；代码两侧适当留空；保留限定、否定、例外、单位、数学条件、概率和测度意义，不添加结论。标题用 `#ez_caption[English][中文]`（从公共模板导入），保留现有标签。不得修改公共模板和术语表。争议提交主 agent，未解决不可标记完成。

## 初始术语

| English | 中文 | 说明 |
|---|---|---|
| rendering | 渲染 | |
| physically based rendering | 基于物理的渲染 | |
| light transport | 光传输 | |
| Monte Carlo | 蒙特卡洛 | 不用蒙特卡罗 |
| sampling / sample | 采样 / 样本 | 动作和结果区分 |
| estimator / estimate | 估计量 / 估计值（或估计） | 随机变量与实现区分 |
| unbiased / consistent | 无偏 / 相合 | 不混同 |
| probability density / probability | 概率密度 / 概率 | 不混同 |
| radiance / irradiance | 辐亮度 / 辐照度 | |
| radiant intensity / radiant flux | 辐射强度 / 辐射通量 | |
| reflectance / reflection | 反射率 / 反射 | |
| transmittance / transmission | 透射率 / 透射 | |
| participating medium | 参与介质 | |
| phase function | 相函数 | |
| primitive / shape | 图元 / 形状 | |
| bounds / bounding box | 包围范围 / 包围盒 | 按上下文 |
| reconstruction | 重建 | |
| further reading | 延伸阅读 | |
| exercises | 习题 | |

## 状态与证据

`unreviewed` 未对照；`in_progress` 精校中；`awaiting_review` 修改后待独立复核；`changes_requested` 复核要求修改；`verified` 原文对照与独立复核均已通过；`blocked` 具体问题阻断。映射存在不等于完整；构建不等于审校。

每个报告写到 audit/reports/<任务>.md，列出独占文件、上游路径及锚点、实际逐段范围、各内容类别覆盖、英文转录修复、中文修正、遗留问题、验证命令和结果。独立复核必须重新读原文及完整译文，不能只看差异或摘要。报告不得自称全书已精校。

术语决议 2026-09-06：literate programming＝文学编程；fragment＝代码片段；tangler＝代码抽取器。

术语决议：splitting＝分裂；photorealistic＝照片级真实感；viewing volume＝视域；eye（相机几何上下文）＝视点；shadow ray＝阴影射线；dependent random variables＝不独立的随机变量（不等于非零相关）。

Typst 注意：i-figured 自动将 `<foo>` 变换出带 `eqt:`/`fig:`/`tbl:` 前缀的编号目标，正文应引用后者，不能仅凭源码标签不同就删除前缀。函数下标应明确分组，例如 `L_(o)(p, omega)`，防止参数吞入下标。编译版本固定0.13.1，系统0.15.1不兼容旧diff符号。隔离引用编译只算语法检查。

第四章术语决议：spectral radiance＝光谱辐亮度；spectral power distribution＝光谱功率分布；chromaticity＝色度；photometric luminance＝亮度，radiance＝辐亮度；illuminance＝照度，irradiance＝辐照度；radiant exitance＝辐射出射度（M，区别于入射侧E，两者W/m²）。ray differential＝射线微分；tile＝图块；tag-based dispatch＝基于标签的分派；frame（几何基与原点）＝标架；handedness＝手性。

色彩术语决议：lightness＝明度；chroma＝彩度；chromaticity＝色度；metamers＝同色异谱体；metamerism＝同色异谱现象；illuminant＝照明体；Standard Illuminant＝标准照明体，区别于实际设备lamp（灯）、luminaire（灯具）和泛称light source（光源）。

相机术语：focal length＝焦距；focal distance＝对焦距离；focal point＝焦点；plane of focus＝对焦平面；circle of confusion＝弥散圆。空间变换from/to方向必须逐个对应，不能按名字含camera就猜为相机空间。

译注API：`translator(中文内容, en: 英文内容)`可提供成对编辑注。没有英文版本的中文译注只在中文/对照输出显示，不再混入纯英文PDF；原正文英文与原书脚注不受影响。已用parec分别提供英文编辑注的调用保持不变。隐藏无英文版本的中文译注不等于解决源文问题，其问题记录仍必须保存。

第七章术语决议：aggregate＝聚合体；spatial subdivision＝空间划分；object subdivision＝对象划分；bounding volume＝包围体；bounding volume hierarchy（BVH）＝包围体层次结构，具体盒类型仍用包围盒；shading＝着色（不是阴影）；alpha texture＝alpha 纹理，按上下文说明不透明度/裁剪语义，不直接等同透射率。

第七章补充：watertight＝水密（不换成笼统“无缝”）；packet tracing＝射线包追踪；incoherent rays＝非相干射线。在加速结构/并行遍历上下文中，相干性指遍历及数据访问的相似性，不是波动光学相干性。

第八章术语：aliasing＝混叠；discrepancy＝差异度；star discrepancy＝星差异度；jitter＝抖动；low-discrepancy作形容词用“低差异”（点集、序列、采样），性质可称“低差异性”。

第九章术语：dielectric＝电介质；conductor＝导体（不一律改写为金属）；perfect specular＝理想镜面；glossy specular＝光泽镜面；retroreflection＝逆反射；microfacet＝微表面，单个facet＝微表面元；Fresnel＝菲涅耳；index of refraction＝折射率；作为传输量的importance＝重要性，与辐亮度和采样权重区分。
