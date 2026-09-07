# 第6章初校记录

固定上游 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c，逐段原书4ed/Shapes.html及Shapes/*.html对照。独占6.0–6.10和必要supplements，不写已释放的第5章/公共文件，不调用旧Scripts。每批释放后不再写，由其他agent独立复核。

## 批次1：6.0–6.1（awaiting_review，已释放）

6.0完整2段、章首blps.jpg及标题对照，Shape纯几何与Primitive材质等非几何两级抽象保留，标题双语与外链修复。无图注/公式/脚注/代码/表/书目/习题。

6.1完整导言与Bounding、Ray–Bounds Intersections、Intersection Tests、Intersection Coordinate Spaces、Sidedness、Area、Sampling七子节全部对照。覆盖2图6.1/6.2及图注、所有无编号数学关系（平面求交、参数t仿射变换）、21个可见文学代码、13折叠面板fragbit326–338、1条IEEE脚注。无编号方程/表/书目/习题。英文0误转o、首行漏+d、x_0误转x_o恢复；ShapeIntersection完整代码遗漏补齐；丢失z夹层说明的中文及英文误x恢复；所有标题双语，slab译“平行平面夹层/夹层”，不再误三对板块；求交、法向量、包围盒统一。PDF必须传在形状表面的Interaction、第二方法以立体角而非面积为测度、已知方向命中前提、参与介质零法向量、半开均匀输入[0,1)²、有限tMax、最近交点、渲染/对象空间返回条件全部保留并精校。源IEEE架构前提与无穷语义脚注恢复；未移除NaN-safe条件更新。ShapeSampleContext/ShapeSample/ShapeIntersection等真实锚点恢复。

折叠：326额外Create/ToString、334 tMax/tyMax稳健扩张、335 z夹层（336 tzMax扩张）保存supplements/6.1-expanded.typ。329/331/332 tFar扩张通过固定源原链接确认在6.8的fragment-UpdatemonotFartoensurerobustray--boundsintersection-0可见，故只保留原骨架占位，不重复补充。其余327/328/330/333/337/338为正文已显示片段组合或重复；334/337同一实现只存334。补充完整读源，不凭代码存在判定审校。

源自身问题：变换射线介绍段写M o_o/M d_o，而按M为对象←渲染变换的定义应输入下标r；原文式按固定源恢复乘法，不再误排成M下标，另双语说明源下标疑点，后续t不变推导及“不归一化”的条件不改。源NaN比较概括过宽，原文保留，说明本算法实际依赖有序大小比较；未把该概括当所有逻辑比较的普遍事实。

验证：可见21片段按顺序逐token核对（忽略空白）；发现局部清理误删1/d[i]后的分号，已恢复并重新编译。Typst0.13.1公共模板/字体与外节ref占位局部三语编译通过，/tmp/audit-shapes-first-{zh,en,bi}.pdf；实际查看双语平面求交数学与代码页/tmp/audit-shapes-first-6.png，以及面积/立体角PDF条件页/tmp/audit-shapes-first-14.png，无裁切。最后仅2句中文语序修正，不声称最终全书/网页视觉已验收。预览章号为隔离计数，非全书编号证据。临时入口删除，diff检查通过。

进度：6.0/6.1待独立复核；6.2–6.10仍未初校，继续处理，不以本批为第6章完成。

## 批次2：6.2–6.4（awaiting_review，已释放）

6.2固定Spheres.html完整导言、Bounding/Intersection Tests/Surface Area/Sampling全部段落读对；4式6.1–6.4及所有无编号推导（隐式球、二次系数、偏导、Weingarten、基本形式、旋转面积、面积→立体角、圆锥角与Taylor近似）、4图6.3–6.6完整图注、1条不要求方向归一化脚注、47可见代码和107折叠面板覆盖。中文补第二基本形式说明空译，偏导中partial字面文本恢复数学符号，NormalBounds不再误成空间包围盒；被着色点不误为被遮蔽点；误差区间中点、按LowerBound排序/拒绝歧义不合法命中、完整z范围跳过裁剪、法线翻转异或条件、物体/渲染坐标方向、单项Taylor阈值与同策略PDF保留。英文emthod及图注词序错误、漏片段标题数学符号、圆锥PDF分母缺括号恢复；未额外添加公式编号，源6.1–6.4原标签保留。Gray1993引用改真实source-cite(Gray93)。6.2原重复bounding/sampling标签分别改sphere-bounding/sphere-sampling，避免与6.1冲突。

6.2折叠：339仅额外工厂/ToString/接口声明、370 sampled pError、371采样点uv的对象空间逆变换，保存在supplements/6.2-expanded.typ；343/381/392判别式、348/351等球面重投影、358/404误差界、412采样点重投影均按固定HTML链接确认在6.8可见，保留主骨架映射而不重复。其余面板为47个可见片段或这些片段的组合、多处展开的重复。片段名的MathJax朗读串恢复成∂p/∂u、∂n/∂v、theta_max等可阅读数学名称，代码标识符不变。

6.2源技术问题明确保留并校注：文字Intersection()/Point3i/std::atan()与代码Intersect()/Point3fi/std::atan2()不同；theta归一化措辞实际对应v；r²文字称distance而公式和DistanceSquared为距离平方。未把这些源问题冒充无依据的英文转录修复。另已向主agent报告待技术复核的范围问题：所列Area使用对象空间radius，Sample(u)使用完整球SampleUniformSphere，未在这些实现内处理裁剪球采样及非刚性变换面积Jacobian；不能从此段宣称椭球/截断球采样已验证，未自行添加算法或修改源代码。

6.3固定Cylinders.html全部导言及Area and Bounding/Intersection Tests/Sampling，所有无编号参数/隐式/二次系数/一二阶偏导、2图6.7/6.8、23可见代码和68折叠面板覆盖；无脚注/编号式/书目/表/习题。图6.8竟误用了pha06f09圆盘示意图，已据源img src=cylinders.png恢复正确两圆柱渲染图，并补图6.7原缺标题。完整保留高度与phi均匀→面积均匀、面积PDF→立体角转换、重试t1条件、两层求交和DirectionCone保守法线范围。修复条件句把“未测试t1则测试”误译成“测试t1是否考虑过”、InteractionFromIntersection整句错位、基本形式术语混用和HTML实体混入C++。额外446工厂/Bounds声明/ToString存6.3-expanded；求交共享片段和基本形式明确映射6.2，判别式/交点细化/误差/圆柱采样重投影映射6.8，未复制后文已有实现。

6.4固定Disks.html全部导言和Area and Bounding/Intersection Tests/Sampling，全部无编号参数/面积/平面求交式、2图6.9/6.10、17可见代码和30折叠面板覆盖；无脚注/编号式/书目/表/习题。标题硬编码6.4移除；“quadric”误译四边形、Disk误译磁盘等纠正；整段uv反解/法线偏导为零说明补完整中英；t缺字和tMAX错拼恢复源tMax；共面射线无交点的约定、t≤0/t≥tMax排除、内外半径平方与phi测试原样保留。特别保留源明确指出未处理innerRadius≠0/phiMax<2π的采样bug及留作习题，未声称其支持部分圆盘。重复sampling标签改disk-sampling。额外514构造/工厂/声明存6.4-expanded；其Intersect及上下文Sample/PDF源明确同6.2/6.3，用源声明的共享实现映射，不再复制；细化交点/误差界定位到6.8原片段。

验证：47+23+17=87可见代码体逐token与固定源匹配（忽略空白及将数学片段名视为源fragment占位符，名称已逐项解码，非修改算法）。Typst0.13.1公共模板/字体、真实Gray源引用与完整References、外节ref占位局部三语编译通过，/tmp/audit-shapes-quadrics-{zh,en,bi}.pdf。实际看球体Weingarten/基本形式页、正确两圆柱图页；发现新补行内偏导的裸斜杠使分母只含∂，改明确frac(∂p,∂u)并重渲复看/tmp/audit-shapes-quadrics-15-final.png，修复成立。也同步通知主agent检查此前5.4已释放文件的同类新偏导问题。圆柱图验收/tmp/audit-shapes-quadrics-31.png。最后偏导修复只重编双语，其余三语此前通过；全书最终编号/全部图/手机网页不在此局部验收声明中。临时入口删除，diff检查通过。

进度：6.0–6.4已初校待独立复核；6.5–6.10仍未初校，继续整章，不以本批为完成。

### 批次3进行中：6.5已重建并局部检查，6.6待处理后一起释放

6.5完整固定原文已逐段读对并重建缺失：85可见代码全部按源顺序，6式6.5–6.10及全部无编号式，11图6.11–6.21、1条逆时针绕序脚注。旧稿保存在audit/quarantine/chapter-6.5-before-initial-review.typ.txt，非原文真值。修复了仅存图注或HTML代码块的多幅图、T/P/S/M矩阵字母abla损坏、边函数/坐标下标、立体角估计量错误除以A_solid而非1/A_solid、面积估计量整个StartFraction乱码、uv矩阵逆及球面余弦缺cos/β′等大量数学丢失。完整补回法向量/切向量/副切向量着色几何、Triangle::PDF与InvertSphericalTriangleSample尾部。

正文与补充先在/tmp准备，先写supplements/6.5-expanded.typ，再集成正文，始终保持可编译。183折叠面板中唯一额外544(TriangleMesh接口)、548(构造剩余缓冲区处理)、562(Triangle工厂/额外声明)、567(默认/输入uv)、579(着色法向量偏导完整36行)、617(边界double回退)保存补充；误差界与正t检查按固定6.8真实目标映射不复制，同片段在多处重复展开只保留一次。代码体85/85按token与固定源匹配，数学片段标题从朗读串恢复可读符号，不改标识符。几何normal与shading normal翻转、UV退化、double回退、同策略PDF阈值3e-4/6.22、权重下限0.01、零ns不变换、逆采样0.1度阈值等全部保留。

源问题单独说明而未静默改算法：Euler段edges/vertices误称；边函数正文左右符号与公式/图注相反；重心射线式(1-b0-b1)不符后文b1/b2；源码先改b1再用新b1+b2归一化b2不能确保sum≤1（0.8/0.8例）；Find cos beta prime标题实际求边弧bbar′的cos而非内角β′；cosθ_l被文字称夹角；LookUpOrAdd大小写与代码不同。原句/代码保留并明确校注。译文不宣称这些源代码问题已解决。

Typst0.13.1三语局部编译通过（/tmp/audit-triangle-preview-{zh,en,bi}.pdf），集成后双语再编/tmp/audit-triangle-final-bi.pdf；实际查看着色段28页、球面余弦42页、立体角采样场景图35页，恢复公式/图像/脚注清晰无裁切。源HTML对应的pha06fNN.svg直接复用；Ganesha与采样场景图已进一步改用HTML指定的ganesha.png、tri-sample-image.png，待本批最后重渲检查；未重新绘图或另存翻译。临时正文/入口已删除。6.5尚未释放，待6.6完成本小批后一起交独立复核。

## 批次3释放：6.5–6.6（awaiting_review）

6.5上条进行中记录的范围现完成；已将Ganesha/采样场景图改为原HTML指定PNG并实际重渲查看 /tmp/audit-mesh-batch-2.png、-35.png，图注完整、未裁切。6.5式标签最终采用固定源edge-function、edge-function-00、tri-inverse-uv-diffs、spherical-tri-cos-betap、sph-tri-cos-bbar、spherical-triangle-arc-sample。所有新图与公式都从同一正文供PDF/Web复用，不存在另份中文稿。

6.6固定Bilinear_Patches.html全页逐段重读，完整67个可见代码、5式6.11–6.15及其余无编号式、7图6.22–6.28、1条二次系数与平面系数不同的脚注、158折叠面板覆盖。原稿大量代码被作为parec正文甚至重复中文翻译、面积积分漏失、normal段重复一遍，且在采样入口后整段结束；已按源重建，旧稿保存在audit/quarantine/chapter-6.6-before-initial-review.typ.txt。不把原先“!!!! 缺东西”提示直接删去就当完成，已补全对应全部范围。

重建包含：四角参数化/双直纹、Mesh共享属性、allMeshes并发重分配下构造函数不能调用GetMesh条件、矩形共面/相对误差判断、近似面积缓存、单/双交点与最小距离推导、t/v行列式范数分母、二次方程两根与eps/tMax筛选、位置/纹理参数(u,v)/(s,t)区分、着色几何、面积采样图像分布/近似Jacobian/矩形三分支、PDF参数域→面积→立体角转换、1e-4矩形球面阈值、ns退化不变换、0.01权重下限、球面矩形逆采样及PDF一致分支。所有否定/约束保留；“阴影几何/法线”“补丁/磁盘”类型误译改为着色几何/法向量/双线性面片，面积取样不会误称对参考点采样。标题Bilinear拼错修复，既有billinear-patches标签保留稳定引用；子节用独有bilinear-intersection-tests和bilinear-patch-sampling，避免旧重复标签。

6.6折叠唯一额外：727网格接口、729面片额外接口、741法向量偏导按纹理参数转换、755近似面积网格、763退化为三角形的法向量范围、765其余角法向量、774第二根完整处理、820面积采样几何与退化返回、823采样法向量朝向，存supplements/6.6-expanded.typ。839的PDF偏导只映射820已列的pu0/pu1/dpdu/dpdv计算，不重复p及采样专用return。球面矩形采样/逆采样在固定页仅有声明，无隐藏实现，未发明软件源码；基本形式复用6.2，epsilon和交点/采样误差界定位6.8，不复制。补充先写齐，再一次写正文。

6.6源问题保留明确注：原代码用单个偏导数倒数构造逆参数导数，一般耦合映射不等于逆Jacobian；以s=u+v,t=u-v给出可直接复核的1/2与1差异，未改源码。正文3×3点黎曼和措辞与折叠实际4×4顶点/3×3面积贡献区别也明确标注。未将源码缺陷猜改后标已验证。

批次验证：85+67=152个正文可见代码体按源顺序核对token一致，仅数学片段名称解码；6.6单节三语、6.5/6.6集成三语Typst0.13.1编译通过（/tmp/audit-mesh-batch-{zh,en,bi}.pdf，真实Moller97源引用及完整References，外节ref占位）。实际看6.6 t/v行列式页/tmp/audit-bilinear-preview-13.png与图像发射两采样图21页/tmp/audit-bilinear-preview-21.png，数学式/代码/两图/图注完整。此前6.5着色脚注28页、球面余弦42页和本次原PNG代表页均已查看。局部计数不作为全书图号证据；网页手机/全书最终验收仍由主agent处理。临时文件清理，diff检查通过。6.5/6.6及两supplement现在释放，不再改。

进度：6.0–6.6均已初校待复核；6.7–6.10仍待初校，继续。

## 批次4释放：6.9–6.10（awaiting_review）

固定Further_Reading.html和Exercises.html完整读对。6.9全28个parec对应的正文范围（源一个长段可能拆为两个）及Intersection Accuracy/Sampling Shapes两个小标题完成初校；无图、表、代码、脚注、隐藏fold。恢复丢失的Sampling Shapes小标题，将求交精度从正文分离成双语小标题；gamma_n、2gamma_2/2gamma_3由固定SVG标题与下标位置恢复，不再排成2²/2³。Dutré重音及Arvo 2001a年份以固定源恢复。全部引用使用source-cite源ID，读对源References书目并映射既有统一backmatter，不重复维护参考文献。修正着色法向量使反射射线落到真实表面错误一侧（原误泛称偏离）、圆柱包围曲线的递归剔除、圆盘结构化样本降低误差（非分布误差）、立体角/投影立体角区别、根细化、面片/图元/包围盒；保留采样拒绝、CDF数值反演、仅作者所知范围等限定。原文跨节href由失效相对路径变成固定官方页链接；这不是本地网站全量跨节导航验收。

6.10全部20题逐题原文对照，恢复每题序号与①②③难度；原有分拆段落仍归各题，不把每段算新题。补回遗漏图6.47及完整双语图注/正文指引，直接使用原pha06f47.svg与polygon-project标签。修复二次曲面矩阵左向量误为列向量，偏导partial字面文本改真正∂，同步核对其余无编号数学（一般二次式、变换矩阵Q′、phiMax<3pi/2、缩放(2,1,4)）。无代码块、表、脚注、隐藏fold。修正light误射线→光源、圆柱采样必须从接收点看可见、CSG集合差、behind ray origin为起点后方非有效交点、点密度概率判交、mesh图元/双线性面片/法向量等，保留全部性能/方差/MSE/遮挡/BSDF条件与所有开放问题。恢复文献真实source-cite。

源问题：习题1原文theta_max与2pi对比疑应方位角phi_max，保留源符号并校注。习题10原源Amanatides和Mitchell1990误指Mitchell90，依据源References题名Some regularization problems in ray tracing改为Amanatides:1990:SRP，译注明确依据而非静默更改。

验证：Typst0.13.1+fonts三语局部编译通过/tmp/audit-shapes-tail-{zh,en,bi}.pdf；实际查看双语9页采样书目、11页二次矩阵及15页恢复图6.47，内容无裁切。11页显示公式后的逗号另起行，最后把标点并入展示式，待独立复核再确认。局部图编号1.1不代表全书编号；未声称网页/最终全书视觉验收。临时入口删除。6.9/6.10现释放；6.7/6.8继续，尚未初校。

## 批次5释放：6.7（awaiting_review）

固定Curves.html全页逐段读对，重建51个非空正文段、三类曲线列表、34可见文学代码片段、9图6.29–6.37（包括Jeri加载的bunny-fur.png）、式6.16及全部边函数/垂直向量/点到直线距离与参数w无编号式、1条曲线一维/Shape二维术语脚注。无表/书目/习题。原稿大段缺失，代码被重复翻译且尾部转义破坏，数学英文/中文严重错位，旧稿保存audit/quarantine/chapter-6.7-before-initial-review.typ.txt。新增supplements/6.7-expanded.typ收录7处额外折叠：885额外公共接口（去掉正文已有构造/NormalBounds）、886私有声明、888CurveCommon声明、895深度计算、898子段包围测试、903末端边函数、915误差界。源共66折叠（885–950），其余为34可见片段的展开/组合或上述7项重复；全书真实实现检索未发现这些额外实现已在他处可见。

全部中英段/标题/完整图注对照，恢复三种曲线与非物理真实形状的限制、共享CurveCommon、阴影射线提前返回/普通射线两子段择近、局部w与全曲线u区别、Ribbon球面插值/朝向宽度、退化方向/零分母、端点边界、tMax约束、着色偏导/圆柱法线外观。原文SVG实际是p(u)，旧稿p_B为转换添加，已据SVG use字形恢复p(u)；下标分组及偏导统一校准，34/34代码体按token与固定源一致（忽略空白及数学片段名显示转写），代码未改算法。

源疑点明确校注而保留：最近点段先说width而后段/代码为half width；Ribbon叉积等于单位法向量一般只应视为方向关系；朝向宽度文字说cos而代码AbsDot取绝对值。完整保留代码，未猜改。

验证：Typst0.13.1+fonts最终三语局部编译通过/tmp/audit-curves-{zh,en,bi}.pdf；实看3页贝塞尔公式/脚注、5页三曲线列表与图、13页递归代码、16页线性近似/最近点图与点积距离式、18页Ribbon与半宽/t范围。视觉检查发现原HTML未闭合li导致解析嵌套，已手工恢复三条中英列表并重渲查看/tmp/audit-curves-5-final.png；这不能靠编译替代检查。p(u)公式复看/tmp/audit-curves-3-final.png。局部编号不作为全书图号证据。临时入口删除，6.7及supplement释放不再写，6.8仍待初校。
