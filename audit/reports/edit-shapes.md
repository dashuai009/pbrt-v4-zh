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
