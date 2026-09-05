# 第三章其余范围持续精校记录

固定原书 f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c；本agent独占3.3–3.13，按小批释放供独立复核，释放后不再修改。

| 范围 | 当前状态 |
|---|---|
| 3.3 Vectors / 3.4 Points / 3.5 Normals | awaiting_review，已释放（含各自supplements） |
| 3.6 Rays / 3.7 Bounding Boxes | awaiting_review，已释放（含各自supplements） |
| 3.8 Spherical Geometry / 3.9 Transformations | awaiting_review，已释放（含各自supplements） |
| 3.10 Applying Transformations / 3.11 Interactions | awaiting_review，已释放（含各自supplements） |
| 3.12 Further Reading / 3.13 Exercises | awaiting_review，已释放 |

任何章节不得因文件存在或构建通过标记verified。各批详细证据随后追加。

## 批次1：3.3–3.5（awaiting_review，已释放）

实际逐段重读固定源 `4ed/Geometry_and_Transformations/Vectors.html`、`Points.html`、`Normals.html`，包括完整可见正文、SVG title公式、全部图注与折叠面板。三页没有脚注、数据表、习题或书目正文。

- Vectors：从开头Vector2/Vector3类型参数至CoordinateSystem函数结尾，全3小节；18可见代码片段，4图（3.3–3.6）、式3.1–3.3与所有无编号公式。恢复片段标题/互链/类和函数目标。补充source fragbit-77额外9行、fragbit-78的using额外3行；其余折叠内容逐项映射正文三个构造片段，不重复。
- Points：全部8段、7可见代码片段、图3.7完整图注。此前Distance()代码块整块缺失，现已补回。fragbit-79额外28行补充；其中正文已有的转换、加法、点差值片段明确去重映射。
- Normals：全部5段、4可见片段；fragbit-80额外14行补充，向量构造函数映射正文去重。

新增 `supplements/3.3-expanded.typ`、`3.4-expanded.typ`、`3.5-expanded.typ`，均由各节末尾无编号补充include。代码来自固定原HTML折叠内容，仅去除HTML标记和外层缩进；标识符、限定符、运算与注释保留。补充同样待独立复核。

主要原文转录修复：

1. Vectors的Gram-Schmidt说明把原始v/w错为w/w，修回；点积性质的u/v/w原误v/v/w，修回；范数说明对象和范数符号修回原文v。
2. 平行四边形图错误复用投影图pha03f05，恢复源pha03f06。面积范数的下标恢复括号内部，叉积长度关系从单竖线恢复双竖线范数。
3. 中文AbsDot段漏掉函数名与免单独调用std::abs()，补回。非退化向量限定清楚表达为两者均非零；正交/正交归一、构造坐标系归一化前提保留。
4. Points坐标z,y,z恢复x,y,z；图3.7遗漏v=p′-p与逐分量相减句补回；Distance函数恢复；TupleLength“输入特征”改为“类型特征”。
5. Normal3f错误using别名缺<Float>，按原代码补回。法向量不一定归一化、不能与点相加、FaceForward第一参数返回/第二参数判断的语义完整恢复。
6. 所有标题双语化并移除3.3.1/3.3.2硬编码数字；非法类名URL换成本地真实标签，跨节原书相对HTML链接改为完整原书链接，待公共映射。代码片段标题从复制代码移出，骨架和展开内容分离。

未决固定上游问题（不擅改）：

- GEO-UPSTREAM-01：Vectors原文声称模板T在解析Length参数前未知，然而代码T已在模板参数声明。中文如实注明，代码未改。
- GEO-UPSTREAM-02：Points转换说明称“点转向量”和“构造函数及转换运算符”，但展示两个构造函数，第二个实际从Vector3构造Point3。英文/代码原样，中文明确译注待核实。

验证：Typst0.13.1，公共模板、字体、屏蔽外节ref的独立三节入口，三语编译通过，`/tmp/audit-geometry-smallbatch-{zh,en,bi}.pdf`。仅独占文件git diff --check通过，入口删除。未对这批全部页面作视觉验收；构建不代表审校或最终链接通过。

## 批次2：3.6–3.7（awaiting_review，已释放）

固定源 `4ed/Geometry_and_Transformations/Rays.html` 与 `Bounding_Boxes.html` 全文直接对照。

- Rays：全部14段正文，Ray/RayDifferential类型与所有参数、介质/时间、微分缩放前提；12代码块（含调用示例）、式3.4、图3.8完整图注。射线标量参数t及r/o非粗体转录恢复；微分不再混译差分，保留像素间距与样本间距的不同假设。
- Bounding Boxes：全部27段正文（补漏前26段）、27代码块（含循环示例）、图3.9–3.11全部资源与完整中英图注。无公式块、脚注、表格、习题或文献正文。

关键补缺：InsideExclusive()整段英文/中文及完整代码原先缺失，已从固定源补回，保留上界严格小于条件；图3.9缺失“只存最小/最大角点、其他角点隐含”句补回；图3.11错用交集图，改回pha03f11.svg，并补x/y维度和代码表达式；Offset()两端(0,0,0)/(1,1,1)英文中文数值遗漏补回；Bounds3::MaxDimension/TupleLength中文漏名补回；AABB/OBB表示段的中断中文补全。全部术语统一包围盒、图元、退化、分量，完整保留空盒与退化盒判断的>=/>区别、返回值直接赋值而不经排序构造的前提。

折叠面板逐项分类：

- Rays fragbit-81：operator()及构造映射正文，额外HasNaN/ToString声明4行存3.6补充。
- fragbit-82：o/d/time/medium全部映射正文三个Public Members片段，无新增。
- fragbit-83：两个构造与ScaleDifferentials映射正文，额外HasNaN/ToString声明7行存3.6补充。
- fragbit-84：三个微分成员声明映射正文。
- Bounding Boxes fragbit-85：Bounds2全部91行额外方法存3.7补充；fragbit-86额外Point2成员1行同样承载。
- fragbit-87：正文全部13组Bounds3 Public Methods映射去重，额外转换/比较/IntersectP声明/ToString等26行存3.7补充。
- fragbit-88：Point3成员声明映射正文，无新增。

新增supplements/3.6-expanded.typ与3.7-expanded.typ由各节无编号补充include；逐行核对固定折叠代码，成员/宏/条件/注释未改。类标签Ray、RayDifferential、Bounds2、Bounds3恢复；全部可见文学片段标题与内部连续导航恢复，后续Bounds3InlineFunctions-9使用原书完整URL。

GEO-UPSTREAM-03：原书图3.11左上方点的y方向距离写成pMin.y-p.y，但图上pMin在左下、pMax在右上，该y差值与图不符。本地忠实保留并明确译注，正确代码未变，不私自改原图注公式。

Typst0.13.1公共模板+字体+外部ref占位：三语编译通过（/tmp/audit-ray-bounds-{zh,en,bi}.pdf），补译注与片段外框修正后中文再编译通过。实际看过中文独立第9页PNG /tmp/audit-ray-bounds-page9.png，确认图3.11已为点到盒距离图，图注与代码未裁切；该预览章号为0是独立入口无章标题所致，不作为全书编号验证。此次视觉检查发现片段标题裸方括号多余，活动文件已改为block，已通知主agent对已释放批次统一修复此显示问题。最终外框/译注改变后未重做整批视觉，不宣称全批视觉验收。

独占文件git diff --check通过，临时入口删除，文件和补充均已释放。

## 批次3：3.8–3.9（awaiting_review，已释放）

固定源Spherical_Geometry.html与Transformations.html的全部可见中英正文、所有公式、代码片段、图注、列表、脚注及嵌套折叠面板已直接逐项读取；公开代码与折叠代码分别记录，HTML文字提取仅帮助读取，所有修正由本agent对照判断，未使用旧Scripts/批量模型。

3.8覆盖全部4小节：Solid Angles、Spherical Polygons、Spherical Parameterizations（Spherical Coordinates/Octahedral Encoding/Equal-Area Mapping三子项）、Bounding Directions。包含图3.12–3.24共13图、式3.5–3.9及全部无编号式、38个可见文学代码片段、3步映射列表和末段唯一脚注。图3.18的Meyer2010引用已改成真实书目键meyer2010floating；主agent新增条目的5位作者、题名、会刊、1405–1409页、2010年均重新对照References.html3236确认。

3.8修复：球坐标两组矩阵乱码改为原文对齐方程；SphericalPhi区间缺π且括号坏，恢复原文[0,2π]；cosφ=x/r=x/sinθ与sinφ=y/r=y/sinθ两条公式整缺补回；原式3.9和图3.20标签补回；球面度/积分测度/角盈/浮点消减等术语精校；图3.20“1减绝对值”原误成反向相减；逆映射原误译相同顺序，改为相反顺序；Encode的std::round按固定代码恢复pstd::round；映射返回代码多余右花括号删除；方向球包围后的习题提示漏句补回；图3.22漏失标题补回；原脚注HTML字符实体解码；全部标题双语化，源代码片段标题与导航/类标签恢复。

3.8折叠20面板fragbit-89至108逐项核对：89中的构造/解码分别映射正文方法0/1，ToString额外1行保存supplements/3.8-expanded.typ；90/94的下半球编码重复、91/95的下半球解码重复均映射正文。92的Sign/Encode映射正文Private Methods；93的x/y映射Private Members。96–100映射正文5个方形球面转换子片段。101的构造/IsEmpty/EntireSphere映射正文，额外ToString/ClosestVectorInCone声明3行保存补充；102成员映射正文。103/104映射球包围子片段；105–108映射合并圆锥4子片段。无未说明额外代码。

3.9覆盖全部9小节：齐次坐标、类定义、基本操作、平移、缩放、三轴旋转、任意轴旋转、向量到向量旋转、LookAt。全部矩阵/向量关系、式3.10、4幅图3.25–3.28、25个可见文学代码片段均核对；本节无脚注或书目正文。

3.9修复：两个整缺图3.26/3.27及完整双语图注补回；图3.25缺Δ偏移量恢复；图3.28去重复硬编码编号并加真实标签。式3.10裸编号改为对应公式标签；列向量再转置的转换错误恢复为原文行向量转置；范数被写成parallel关系符的转录修复；矩阵成员声明被误包Markdown反引号、Vector3f/SquareMatrix/worldFromCamera等代码标识符断裂或截断均按原代码恢复。所有25代码块与固定可见源逐项比对，算法/系数/符号不改。中文齐次四维向量的主语、标架、法向量、行主序、NaN传播/条件、旋转角θ漏译、LookAt正交归一等修正。

3.9折叠16面板109–124：109中正文7组Public Methods去重映射，剩余额外82行保存supplements/3.9-expanded.typ，包含未公开的方法声明及Point3fi误差传播完整实现；嵌套111–114的误差计算代码合入该补充，不再遗失。110/116的NaN初始化映射正文；115的两个矩阵成员映射正文；117首基向量映射正文，118第二/三基向量9行补充。119映射中间反射方向片段；120含121及122的矩阵初始化/元素片段映射正文；123/124映射LookAt列片段。补充与正文均共用Typst，并有无编号标题，待独立复核。

固定源未决说明（已明确译注，不猜改）：图3.12平面角图注写unit sphere；式3.8的arctan(y/x)省象限处理而代码atan2；合并圆锥“平均轴”角度公式含max(2θa,2θb)。3.9图3.28图注的变换方向与正文/LookAt返回方向表述不同；中间worldFromCamera与最终逆矩阵区分保留。这些是源文本问题，不应被标成已修正原书技术事实。

验证：Typst0.13.1公共模板+字体+外部ref占位独立入口三语通过，/tmp/audit-sphere-transform-{zh,en,bi}.pdf。实际查看新增图3.26/3.27所在独立中文23/24页，/tmp/audit-sphere-transform-23.png与-24.png：图像/完整图注正确呈现，矩阵和代码未裁切；独立章号0及reference占位不是全书实际引用证明。未全面视觉验收13+4图或所有补充页。Meyer引用补入后由最终集成统一构建；其新增书目已单独重读核对。引用紧接中文导致eqt标签被吞的问题在3.8及时修复，活动两文件扫描无此类项。独占diff检查通过；临时入口删除。

## 批次4：3.10–3.11（awaiting_review，已释放）

逐段重读固定Applying_Transformations.html与Interactions.html，正文、全部无编号数学关系、两图完整图注和嵌套代码均核对。

3.10覆盖8小节：点/向量/法向量/射线/包围盒/变换复合/手性/向量标架；19代码块（含2个使用示例）和图3.29。修复法向量n′错写t′；“if”被加强为“当且仅当”，恢复充分条件；ABC实际施加C→B→A的逆序中文漏译补回；点变换左乘条件明确；Frame任意选取被误译随机选取、正交矩阵误成正交单位矩阵修复；图3.29此前只有英文，已全译；齐次法向量推导用对齐式恢复，删除中文伪Markdown标题。ToLocal括号截断修复。

3.10射线小节原重复使用3.6的<rays>，改为<transforming-rays>，避免重复标签混淆真实源位置。其他原有标签保留，Frame类标签及全部文学代码片段目标/互链恢复。两页代码逐项与固定原代码一致，未修改算法；源文字Transform::Inverse()与上一节自由函数Inverse的命名差异属于原书表述，未擅自改代码。

折叠3面板：125射线起点误差修正6行是本节可见正文没有的内容，放supplements/3.10-expanded.typ；126 Frame方法中正文6组方法映射去重，额外29行（FromX/Y、法向量重载、FromLocal及ToString等）同样补入；127三个基向量成员映射正文。

3.11覆盖Interaction全部说明、Surface Interaction及Medium Interaction两小节、23可见代码块、图3.30。中文丢失的四个偏导数补回，手性推导中错误的两个dot改回原文cross，失去数学环境的n=∂p/∂u×∂p/∂v恢复；图3.30正文/标题倒置且硬编码编号、缺标签已完整重排，图资源pha03f31本身与原书一致。统一着色几何而非阴影、法向量、介质界面，方向wo的相反射线方向与ωo含义、flipNormal和orientationIsAuthoritative作用均保留。medium成员代码块多出的类结束括号依据原片段删除。

3.11折叠15面板128–142逐项分类：128额外73行（构造变体、可写AsSurface/AsMedium、射线派生、介质选择等）补入，正文4组方法去重；129全部成员对应正文。130的两组正文构造/SetShadingGeometry去重，额外36行（带faceIndex构造、材质/光源设置、采样接口等）补入，并完整含135的介质切换子片段；131/132及137/138对应几何初始化/翻转片段；133/134及139/140对应着色法向量与偏导数片段。136额外材质/面积光源/屏幕偏导数成员4行补入，其余对应正文；141额外ToString声明1行补入，构造对应正文；142相函数成员对应正文。新增supplements/3.11-expanded.typ，同份正文include，无重复算法生成。

无脚注、数据表、习题或书目正文。两文件及补充均待独立复核；未将正文未包含的其他实现误称已审校。Typst0.13.1公共模板+字体+外部ref占位三语编译通过：/tmp/audit-apply-interaction-{zh,en,bi}.pdf。独占diff检查通过，临时入口删除。本批未做实际整批视觉验收。

## 批次5：3.12–3.13（awaiting_review，已释放）

3.12固定源Geometry_and_Transformations/Further_Reading.html全部11段、29条书目重新读取。重写全部中文：无坐标表示/软件自动统一坐标系、行向量右乘与本书列向量左乘的差异、射影几何、Eigen库不译“特征系统”、表达式模板、单位向量52位精度结论、等面积映射、数值稳健构造与方向包围。英文漏掉的(x,y,z)、pM/Mp关系补回；函数名代码样式与真实公式/章节引用恢复。全部原来的裸作者年份与引用建立真实书目关联，保留必要作者名，避免只显示年份而丢失Mann/Arvo等来源。

书目映射保存在audit/reports/geometry-reference-map.json。主agent补入17缺项及Buck/Lang源版2项后，本agent逐字段对照源References复核作者、年份、题名及刊物卷期页/出版信息，19项通过编辑核对：barequet2005optimal、cigolle2014survey、clarberg2008fast、derose1989coordinate、donnay1945spherical、duff2017building、frisvad2012building、geisler2020geometry、guennebaud2010eigen、hatch2003right、hughes2021personal、max2017improved、praun2003spherical、schneider2003geometric、shirley1997low、strom2020immersive、vanoosterom1983solid、buck1978advanced、lang1986introduction。Hatch坏URL未猜修，主agent条目以note说明，损坏的原文文本仍完整保存在映射与固定子模块中；不宣称URL修好。Ström原书裸域名作为howpublished保留。未修改公共bibliography。

复用旧书目仍向主agent报告补全事项：Arvo的Glassner编辑/San Diego出版地、Wallis的Graphics Gems I编辑与Academic Press/San Diego信息，以及Turkowski旧publisher与源Academic Press不同。正文引文身份已对应，不将公共字段待办隐去。

3.13发现整页错位：旧本地为第5章相机9题，绝非第3章习题。九题开头去空白后全部匹配固定Cameras_and_Film/Exercises.html，且本地chapter-5.6-Exercises.typ已有相机题目。保留旧3.13全文到audit/quarantine/chapter-3.13-before-repair.typ.txt（不参与书籍构建），据固定几何Exercises全译正确4题：

1. ① 利用对称性高效变换AABB，保留Arvo1990引用。
2. ② 用多组非正交平行平面夹层交集构造紧包围范围。
3. ② 直接作用于包围盒改进方向包围，保留BVHLightSampler例子及运行时间/图像质量/显著收益问题。
4. ① 故意把Normal3f按Vector3f变换制造错误，并保留完成后撤销代码改动的重要要求。

这4题英文按固定原文保留，中文从原文完整补译，恢复编号1–4和难度①②②①。没有把旧相机9题换个标题后冒充几何习题。两页无图片、图注、独立公式块、代码块、脚注或折叠额外内容。

验证：Typst0.13.1公共模板/字体/公共书目、外节ref占位的三語独立入口均通过，/tmp/audit-geometry-reading-{zh,en,bi}.pdf。实际查看仅习题的中文第2页 /tmp/audit-geometry-exercises.png，确认四题编号/难度对应且无裁切，Arvo仅年份显示问题随后补回作者，修复后三语重新编译通过。独立预览章号0不是全书编号证明，最终全书引用/视觉仍待集成验收。独占diff检查通过，临时入口删除。

## 本agent本轮授权范围状态

3.3–3.13全部11文件及对应3.3–3.11补充均完成编辑原文对照并分5批释放，状态均awaiting_review；独立复核由主agent另派，未自称verified。上游原文疑点、公共书目待办和视觉未覆盖范围均在各批记录中保留。之后不得由本agent继续写入已释放文件。
