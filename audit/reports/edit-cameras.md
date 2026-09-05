# 第5章初校记录

固定上游 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c，来源 pbr-book-website/4ed/Cameras_and_Film.html 及 Cameras_and_Film/*.html。独占5.0–5.6与新增supplements；公共文件不改，不调用旧Scripts。第四章已全部释放，此后不写。

进度：5.0逐段对照完成，5.1进行中，5.2–5.6未审。每批2–3文件完成并检查后释放，状态仅awaiting_review，须另agent独立复核。

## 批次1：5.0–5.1（awaiting_review，已释放）

5.0固定Cameras_and_Film.html完整5段与章首landscape-dof.jpg对照，标题双语化，辐亮度分布不误译辐射分布，成像radiometry准确表述辐射度学关系；原5段、渐晕/枕形/桶形畸变、传感器时间与波段计数条件保留。Film与PixelSensor外链修成完整原书地址。无图注、代码、脚注、公式、表或习题。

5.1固定Camera_Interface.html全部导言、5.1.1 Camera Coordinate Spaces、5.1.2 CameraBase正文逐段阅读，29可见代码、19折叠面板fragbit196–214、3脚注、1图5.1三子图及图注全覆盖；无编号公式/表/文献列表/习题。所有可见代码token对照固定源29/29一致（仅忽略空白），CameraTransform构造骨架、CameraBase结构/接口、差分方法及每个子片段保持源顺序。补缺失CameraBase Protected Members，原三个分支子片段丢失break恢复。正文中x方向辅助微分、y方向未列出片段名称的转录缺字补回，0.05/−0.05差分步长与换算一个像素宽条件完整。

中文重点修复world-from-camera和world-from-render多处变换方向反译：分别为相机→世界、渲染→世界。保留渲染→世界不随时间变化、相机动画在renderFromCamera、帧时间中点等前提，避免把静态场景因相机运动误变成动态。恢复源“camera-world/rendering space是非标准名称”脚注；删除无源错误pstd::optional<T>::None添加解释。pFilm的辐亮度目标点、镜头pLens、快门time与滤波权重、色散时终止次级波长、射线方向归一化、纹理查询抗锯齿语义核对。4参数原挤成一行列表拆回4项，Film sensor丢失文字补回。相机/标架/法向量/包围盒术语统一；图下Original拼错修复、三子图标题中英化、模型作者保持原名Yasutoshi Mori而非未经依据的中文名。

折叠：196 Camera额外构造/接口、197 CameraTransform所有转换重载、203 CameraBase额外Approximate_dp_dxy（含204–206完整三个子片段）、207最小位置/方向微分成员、208额外变换重载与FindMinimumDifferentials声明、212完整y差分实现，保存supplements/5.1-expanded.typ并无编号include。203里的InitMetadata声明属于CameraBase而非Camera，虽签名与Camera接口相同也保留，不能按字符串相同误删不同类内容。其余198–202、209–211、213/214都是正文已有片段或组合（214与211重复），映射正文不再重复。额外内容逐行读源，标识符/数学分支未改，源未呈现的方法体不自行发明。

源链接限制：固定源自身将base/camera.h链接到GitHub/src/base/camera.h，原URL保留，并向主agent报告供全书源链接映射统一处理。未擅猜源码新路径。

验证：Typst0.13.1公共模板和字体、外部ref占位局部三语编译通过，/tmp/audit-camera-first-{zh,en,bi}.pdf。实际检查双语三子图/完整图注第10页，以及差分算法第18页。发现长inline片段名称造成英文词间巨大空白，改为可换行的原文片段链接后重新渲染，/tmp/audit-camera-first-18-final.png确认修复；算法代码、x/y符号与两个方向条件无裁切。临时入口计数显示第1章仅是隔离预览，不能当作最终5.1编号验收。最后仅此双语布局修复重编，其余三语之前已通过；未假称全书/网页/移动端通过。临时入口删除，diff检查通过。此两节及5.1补充释放后不再修改，继续5.2–5.6。

## 批次2：5.2–5.3（awaiting_review，已释放）

5.2固定Projective_Camera_Models.html全文、3小节、图5.2–15全部14幅图注与子图、式5.1/5.2及所有无编号公式/矩阵、31个可见代码片段、53个折叠面板fragbit215–267完整核对。无脚注/数据表/书目/习题。所有变换方向、近平面与远平面映射0/1、光栅y翻转、透视除法、FoV窄边[-1,1]、归一化方向、孔径正值分支和薄透镜不同z约定保留。中文严格区分焦距f与对焦距离z、焦点与对焦平面；focal distance原错误译焦距修复。弥散圆两条无编号式遗漏z_f的撇号恢复为z'_f；f-number原文丢失n定义和直径相对焦距关系恢复；采样输入域原误闭区间[0,1]²恢复[0,1)²。图5.14中文开头重复5.13图注删除，图5.12 z'_f所在像侧胶片平面不再误指物侧对焦平面。normalizing vector取z分量不误为归一化单一分量，视域/归一化设备坐标/弥散圆/散焦术语一致。图下分组标题中英化，代码文学片段拆分恢复。

折叠5.2：正文组合重复保留骨架并对应已有子片段，额外215(Projective额外声明)、222(Orthographic额外接口)、224(最小微分)、233(主RayDifferential构造，与Ray有别)、240(正交镜头微分)、244(Perspective额外接口)、248(FindMinimumDifferentials)、261(透视镜头微分，含263/264)保存在supplements/5.2-expanded.typ。样本透镜公共片段以源占位符引用，不另复制。247与252本身是空的“Compute image plane area at z=1”面板；报告并加正文校订说明，未伪造代码。源后文把zf=1m写作正距离，前面场景坐标为负z；保留原文并指出约定，未改数学结论。

5.3固定Spherical_Camera.html全部11段（含首段和枚举说明）、图5.16双子图/完整图注、8可见代码和10面板fragbit268–277全部核对。无编号式/脚注/表/习题/书目。等面积含义修为“立体角相等的方向区域映射面积相等”，不再误称任何大小的有限立体角都映射同样面积。经纬线直线与非共形限定、theta/phi方向、相机up=y与映射up=z交换、样本滤波可能越界和WrapEqualAreaSquare边界处理完整保留。源折叠269的额外接口/未实现方法与270最小微分调用保存supplements/5.3-expanded.typ，余面板映射正文重复。源sample.pfilm与CameraSample::pFilm大小写不一致，源可见和折叠均如此，原代码保留并加明确双语源代码疑点说明，不静默改标识符。

验证：31+8可见片段按顺序逐token匹配固定源，代码标识符/常数/矩阵/分支保持一致。Typst0.13.1公共模板+字体、外部ref占位三语局部编译通过（/tmp/audit-camera-second-{zh,en,bi}.pdf）；实际检查双语弥散圆三式/图5.12页和球面两映射比较图页，未裁切。z'_f排版统一后重渲双语并复看/tmp/audit-camera-second-19-final.png；球面图为/tmp/audit-camera-second-28.png。预览编号不含前章计数，不是最终图号证据；全书/网页/移动验收待主agent。源两个空面板、pfilm拼写和坐标符号问题如实列出，未宣称技术问题全解决。两文件及补充释放后不再修改，继续5.4–5.6。

## 批次3：5.4–5.6（awaiting_review，已释放；第5章初校完成）

5.4固定Film_and_Imaging.html全部正文、7小节及色适应/传感器响应采样两个h4子节逐段读取并对完整中英文修改；11式5.3–5.13及全部无编号式，9幅图5.17–5.25、3条原脚注、65可见文学代码片段和48折叠面板fragbit278–325全部核对。无数据表或习题正文（图的table布局不算原书表格）。局部正文中文126个parec含编辑说明与原段拆分，不以数量证明覆盖。

5.4主要修复：所有编号式原来无真实标签、5.3/5.4硬编码数字、5.5中英文各含一次公式，现恢复11组稳定标签、共享能量式并引用。首个面积积分恢复向量范数分母；L_i/r_f/p_v函数下标显式分组；波长PDF归一化积分括号修正，匹配函数横线正确，nm不拆为n m，J/m²保持物理单位。VisibleSurface正文丢失深度偏导的完整句和∂z/∂x、∂z/∂y恢复，shading normal不再误译阴影法线。补LMSFromXYZ/XYZFromLMS声明、RGBFilm输出矩阵成员/pixels成员/AddSample方法骨架和该处解释段。ToSensorRGB代码中误插的LaTeX\\bar{r}恢复源r_bar；SampleVisible中的&lt;&lt;实体和展开重复恢复原代码骨架。65片段逐token与固定源一致，仅空白不同。

恢复缺失完整图5.24/5.25，前者用固定float-vs-double-reference.svg，后者用固定pha05f25.svg（其内嵌原静态PNG；未伪造/重绘/调用旧转换脚本）。图5.21中文空图注补全；9图恢复真实标签及去除重复Figure5.x字样；双图标题中文化。补1.8微米/2022时代手机像素脚注、翻译PhysLight/Manuka脚注、补中文Danny Pascale许可脚注；源历史数据保留。Film界面的对角线单位中文空段、GetImage/GetPixelRGB英文裸段补译。滤波与splat并发约束区分：AddSample同像素不并发但跨像素并发；AddSplat同像素需同步。带符号滤波PDF∝|f|、sign、权重f/p、有偏归一化与无偏原估计量、32/64位参考图精度、限幅能量损失与无穷默认值都保留。

按主agent决议，H=辐射曝光量（J/m²）、imaging ratio=成像比例因子、white balance=白平衡、chromatic adaptation=色适应；fluence只保留该节括注英文，不再误为辐射通量。统一光谱辐亮度/辐亮度/辐照度，illumination光照、illuminant照明体，shot noise散粒噪声、rolling shutter卷帘快门。相机测量式面积/时间/出瞳条件和不建模噪声等实现限制保留。

折叠5.4：278额外PixelSensor工厂、281额外xyzOutput训练数据（289/292为同片段重复）、298额外Film创建/ToString、299 VisibleSurface默认构造/ToString、301 FilmBase额外声明、303 RGBFilm额外接口、323 GBufferFilm完整额外接口/求值、325 GBuffer私有成员，存supplements/5.4-expanded.typ。其他面板映射65个正文可见片段；同名但属于不同类的成员声明不能按字符串相同删掉，补充扣除严格限于各自类的已显示片段。ProjectReflectance在固定页折叠仍只有声明，不编造实现。SampleVisible在5.4可见完整介绍，与已释放4.5补充跨节重复一事已通知主agent/4.5复核，5.4保持主实现。

源问题（不伪称已解决）：原文化学句称卤化银受光产生溴化银，保留原文并明确待源层面核实；AddSplat例子在原HTML中截断于“such as bidirectional path”，保留英文并说明源截断，后续求和/加权差异完整；均匀面积采样段原说Σf期望为1，按式5.12其实是(A/n)Σf期望为1，已在明确均匀采样/∫f=1条件下加校注，原英文保留，不推广到非均匀PDF。主agent已认可该归一化说明。

5.5固定Further_Reading.html全部18正文段及Film and Imaging/Denoising两个无编号h3、完整页末63参考文献重新阅读。中文逐段重写，纠正film误译电影/薄膜、Shade人名误译阴影、解析时间区间误译分析、深度图像（deep image）和普通depth map混淆风险、均值中位数与“均值/中位数”错误混用、无偏滤波能量重分配限定；保留源Gharbi“sampling pixels”措辞，未静默用模型常识替换英文。全部引用用主agent新source-cite对应原ID直达完整References，55个正文独立ID，连同习题9个ID合并63个，0缺失/0多余。原文页末的作者顺序/年份/标题/卷期/页码已逐条阅读；保留Perlin1985a、Vicini2019a、Eberly2001、Zwicker2015等源年份与后缀，不受旧bib版次影响。映射保存audit/reports/camera-reference-map.json，公共元数据不改。

5.6重新读取真实相机Exercises.html所有9题及引用，未用旧3.13隔离稿作为依据。难度②②②③③②②②③及编号完整。主要修复：狭缝扫过胶片不误为移动胶片；球面图交互旋转保留视点；focal stack不同对焦距离与任意清晰深度；光场出瞳图像/空间方向辐亮度/拍摄后重对焦；倾斜和平移两种调整分别保留；太阳直视高辐亮度不应限幅的否定；散粒噪声依赖光子数而读出/暗噪声独立；浮点不满足结合律且AddSplat未达到确定性目标（旧译反说“不辜负”）明确修复，线程数比例内存/运行顺序/合理性问题保留；最后一题要求一次渲染直接生成光场及Camera/Sampler/Film全部需求不漏。全部18中英题干块完整，无脚注/图表/公式/代码片段，未添加答案。

验证：Typst0.13.1公共模板/字体、真实source-cite和完整backmatter/References、外节ref占位的5.4–5.6三语编译通过，/tmp/audit-camera-final-{zh,en,bi}.pdf。5.4query确认11组源标签+eqt别名顺序正确，没有给无编号式额外编号。实际查看双语波长PDF及图5.21(/tmp/audit-film-17.png)、原静态限幅图5.25(/tmp/audit-film-35.png)、Film接口与跨像素说明(/tmp/audit-camera-final-23.png)、习题8/9(/tmp/audit-camera-final-51.png)，未见数学式/代码/图注裁切。反复检查源语义、代码token与引用，不以编译、段落计数或文件存在证明完成。未代表全书最终编号/全部PDF页面/Web与移动端验收。

第5章5.0–5.6七文件及四份补充5.1–5.4现全部初校完成并释放，状态为awaiting_review；必须经另agent独立原文复核后才可改为已精校。无其他文件写权限，公共网站/部署与全书最终验收由主agent继续推进。
