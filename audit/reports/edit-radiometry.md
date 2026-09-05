# 第四章持续精校记录

固定源：pbr-book-website@f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c / 4ed/Radiometry,_Spectra,_and_Color。主agent授权本agent独占4.0–4.8全部九文件及新增supplements，分批释放后不再修改。仅实际逐段对照内容可转awaiting_review，独立复核另行进行。

| 范围 | 状态 |
|---|---|
| 4.0–4.2 | awaiting_review，已释放 |
| 4.3–4.4 | awaiting_review，已释放 |
| 4.5–4.6 | in_progress |
| 4.7–4.8 | unreviewed |

遵循radiance=辐亮度、irradiance=辐照度、radiant intensity=辐射强度、radiant flux=辐射通量；积分域、微分测度和投影余弦不得混淆。下面持续追加各批源锚点、修复及验证。

## 批次1：4.0–4.2（awaiting_review，已释放）

固定原书对应三页全文逐段读取：Radiometry,_Spectra,_and_Color.html；Radiometry.html；Working_with_Radiometric_Integrals.html。核对全部SVG title数学、表格和tooltip脚注；未读取/使用旧Scripts结论。

覆盖：4.0全部3段、章首图transparent-machines-812、可见光范围脚注1条；4.1全部介绍/五项几何光学假设、Basic Quantities五种定义段、入/出射辐亮度、光谱分布、光度学，原式4.1–4.6及全部无编号公式、图4.1–4.4、两表（7情景行、5物理量行）与原书2脚注；4.2全部引导段及投影立体角/球坐标/面积三个小节、式4.7–4.9及无编号式、图4.5–4.9。三页没有代码块、隐藏代码、习题正文或书目列表。

主要修复：

- 所有标题双语化；严格统一辐射通量/辐射强度/辐照度/辐亮度/光谱辐亮度/亮度/照度；spectra不再误作“光谱集”新概念；amount of light不误指定为光强；4.0发光性质与反射性质区分。
- 4.1图4.3中文原把dω当面积、dA⊥当立体角，已依据源完全修正；垂直方向的Eω与实际表面接收辐照度区分保留。
- 单侧极限“跟踪起来繁琐”不译为“不需计算”；入射/出射的ω均向外及入射L_i(p,-ω)的符号条件完整核对，所有函数下标显式分组。
- 光谱辐亮度引例和光度学首句的中文重复删除；亮度单位原误为(cd/m)²，恢复cd/m²；两表sr/cd/lm/lx用完整单位符号，不再拆成变量乘积；XYZ关联句修回两者与XYZ相关。
- 两表此前中英文各建一个figure，双语会重复编号，第一表类型还未明确为table。现共用单个table、各单元格选择语言，保留统一标签并修中文引用；7行数值/5行量与单位逐项核对，未以当前显示设备数值替换原书历史数据。
- 4.2“测度”不再误译“测量值”，补原中文丢失的余弦加权限定；明确dω⊥=|cosθ|dω与dω=sinθdθdφ两种不同测度变换；θ_i/θ_o、r²及发射辐亮度定义保留。
- 4.2末尾多出的半球积分为无源重复，删除；图4.9错误裸引用修为对应公式标签；图注中文重复Figure4.7编号删除。
- 移除三条非原文旧translator说明（荧光/磷光时间与机制、旧GB命名约定、辐亮度别名），不采用旧审校结论。

光速：固定源确实印为299,472,458 m/s，未冒充转录错误修改。经本agent打开NIST官方页 https://physics.nist.gov/cuu/Constants/Value/c.html 核对，其列真空光速精确值299,792,458 m/s（exact）。按主agent决议，原文数字保留，新增明确中英编辑注说明已核实的源文排印错误并链接NIST。此事实已核实，不是无法判断的未决项；须独立复核编辑注及原文保留状态。

验证：Typst0.13.1公共模板/字体/书目、外节ref占位三语编译通过，/tmp/audit-radiometry-basics-{zh,en,bi}.pdf。实际查看双语11/15页PNG，确认辐亮度图注中面积与立体角正确，双语两表均完整、单位清晰且未裁切。独立起第4章计数查询：eqt:irradiance-to-power至eqt:dw-dA-eqt依次1–9、章号4，对应源4.1–4.9；两table计数1/2、章号4，双语不再增加重复表号。表格与图注代表页检查不等于全书/手机页面视觉验收。

独占diff检查通过，临时入口删除。余章继续，不以本批为全章完成。

## 批次2：4.3–4.4（awaiting_review，已释放）

固定Surface_Reflection.html和Light_Emission.html全文重新直接对照。

4.3覆盖全部导言、BRDF/BTDF子节及BSSRDF子节，完整式4.10–4.16与无编号式、2图4.10/4.11、半球方向反射率互易性脚注1条。重点逐项核对：BRDF dL_o/dE与BSSRDF dL_o/dΦ不同分母；反射率rho_hd/rho_hh与BRDF值并非同一量；BRDF值可超过1但受积分约束；BTDF不服从所列互易性；反射半球与散射全球面域不同；余弦绝对值与法向量保持自然朝向的关系；BSSRDF对面积和入射方向的4维积分。

修复：全部辐射度/光谱辐射含混表达改为对应辐亮度/光谱辐亮度，次表面光传输不译传导。函数下标全部显式分组；球面/半球的花体记号恢复；原书BSSRDF定义4.15和4维散射式4.16漏标签补回；4.14硬编码引用改真实标签；BSSRDF图引用用正确fig前缀。重复导入删除，标题/图注中文精校。保留所有限定及权重，无概率归一化替代反射率约束。

4.4覆盖光发射介绍及四种灯、光效、Blackbody Emitters与Standard Illuminants全部正文，4幅图4.12–4.15及完整图注，式4.17–4.20、光效无编号式，2可见文学代码片段。无脚注/数据表/文献列表/习题正文。Planck、Kirchhoff、Stefan–Boltzmann、Wien的温度/波长/系数/单位逐项核对，原书历史常数未静默更新。Planck指数hc/(λ k_b T)依据公式及源代码明确分母分组；Kirchhoff错误ν下标恢复源e；源图4.13英文缺2856K补回。温度加倍的总能量“增加16倍”改为“增至原来的16倍”。发射辐亮度与辐射出射度M严格区分。

按主agent术语决议，lamp=灯，luminaire=灯具，illuminant=照明体（光谱分布）、standard illuminant=标准照明体；不与实际光源混为一谈。F9的phosphors在荧光灯语境译荧光材料。光效的lm/W与输入消耗功率/总发射功率两个可选分母保留，未将它译成无量纲效率。

折叠：Light_Emission.html#fragbit-143与正文Returnemittedradianceforblackbodyatwavelengthmonolambda-0完全相同。原本本地把该代码展平进Blackbody而缺独立可见片段；已恢复函数骨架与完整子片段，明确映射而不重复。唯一折叠无额外内容，不新增supplement。代码标识符/常数/分支与固定原书一致。

验证：Typst0.13.1公共模板+字体+外节ref占位三语编译通过（/tmp/audit-reflection-emission-{zh,en,bi}.pdf）。以章4/节2/式9作为入口计数，实际query确认11式依次4.10–4.20。查看中文BRDF和Planck代表页PNG /tmp/audit-reflection-emission-2.png、-6.png，未见矩阵/单位裁切；发现Blackbody片段标题孤悬，改sticky block后重渲并查看 /tmp/audit-reflection-emission-final-7.png，确认标题随代码，Kirchhoff/Stefan单位和下标正确。该预览图号因省略前节图计数不作为全书图号验收。未检查每张图、全部三语最终排版或移动端。独占diff检查通过，临时入口删除。

## 批次3：4.5–4.6（awaiting_review，已释放）

固定 Representing_Spectral_Distributions.html 与 Color.html 全文重新读取，对照全部现有英文/中文，包含标题层级、公式、图注及 tooltip 脚注；未沿用旧审校。4.5 覆盖 Spectrum/Constant/Dense/Piecewise/Blackbody/Named/SampledSpectrum/SampledWavelengths/Discussion 全部段落，式4.21及无编号式、图4.16–17、两条脚注、43个可见文学代码片段。4.6 覆盖导言、XYZ/Chromaticity/RGB/Color Spaces/Standard Color Spaces/Why Spectral/Choosing Samples/From RGB/Unbounded/Illuminants全部段落，式4.22–26及全部无编号式、图4.18–32及完整图注、5条源脚注、57个可见文学代码片段。两页无表格、习题或文献列表。代码顺序与源相同；代码逐 token（只忽略空白）核验100/100一致，完整代码标识符、分支、常数和数组索引保持。

主要修复：4.5 恢复缺失 Spectrum::operator() 声明、两条脚注和文学片段结构；Named Spectrum 不再译为命名光谱新类，分段线性与密集采样条件保留；Blackbody 最大值为所有波长上的全局最大，不是所有波长值为1；光谱估计式 L_i/p_ω/p_λ 显式下标分组；错指第13章体积散射恢复第14章；第一波长保留、同分布条件、终止概率1/NSpectrumSamples完整核对。标题Discussion/SampledWavelengths恢复源h4层级，图4.16 caption补中文/标签并修错误图引用。

4.6 恢复被吞掉的XYZ说明段和独立构造/字段片段，RGBColorSpace类定义、白点/基色初始化、误收进C++代码的两段英文正文及完整中文；补 RGBSigmoidPolynomial 波长求值及无穷分支，恢复RGBAlbedo/Unbounded的公开接口片段。恢复 V(λ)=683Y(λ)；图4.24英文/中文错误(0.3,0.5)恢复固定源(0.3,0.6)；图4.21/22完整双语图注和多幅缺失标签恢复。标题全双语，明度/lightness、彩度/chroma、色度/chromaticity、亮度/luminance严格区分，同色异谱体和照明体按主agent决议。修復英文c\\2、norm占位、CIE76 ΔE、c∈(0,1)、三维RGB立方体上标等转录损坏。白点嵌套下标恢复，缺失yλ/zλ同理句补回。限定条件包括XYZ线性但乘法非线性、均匀/分层波长PDF、反射率[0,1]与其他两类非负无界、MaxValue极小值忽略、RGB相等时常光谱、三线性索引及0强度分支均保留。补非均匀波长采样脚注与紫外/红外/虹彩平滑性例外脚注。

源错误/限制：源显示器脚注HTML嵌套引号损坏，但raw明确可读 B.5.6 与 Utilities/Images.html#sec:color-encodings，已按该依据恢复完整脚注而非猜测。源“squashing its domain”实际描述输出值域，中文准确表达，英文保留并校注；MaxValue段源错引4.25而二次多项式是4.26、误差下降段源指图4.26(a)而误差图为(b)，原指向保留且编辑注明确指出。源y()段写XYZ()而实际方法名ToXYZ()，未静默修改原书措辞。源颜色匹配到RGB的近似推导、用“less saturated”形容(c,0,0)及波长样本实验历史结果按源保留；这些属于应由独立技术复核检查的源文表述，未宣称独立验证其物理推导。

折叠覆盖：4.5全部23面板fragbit144–166。144额外using/ToString、145 Dense额外构造/采样/缩放/最大值/等号、147 Piecewise额外接口、151 Blackbody额外接口、155 SampledSpectrum算术、156 SampledWavelengths相等/ToString/**SampleVisible完整实现**、162 friend SOA已存 supplements/4.5-expanded.typ；其余面板是正文可见片段组合重复，保留源骨架并映射正文。4.6全部29面板fragbit167–195：167 XYZ算术/索引、171 RGB算术/索引、173 RGBColorSpace额外接口/相等/LuminanceVector、182 RGBToSpectrumTable构造/static/接口、190 Albedo额外Sample、192 Unbounded额外构造/Sample、194 Illuminant额外MaxValue/Illuminant/Sample存 supplements/4.6-expanded.typ；可见片段从补充中扣除，余22面板都是正文已有片段（包括187/188/189三线性插值组合及co重复）。额外代码完整重新读源；不把声明片段声称成可独立编译C++类。辅助映射 /tmp/Color-fold-map.json 可用于复核，但来源始终为固定HTML。两supplement无编号标题include同份正文，不影响章节编号。

验证：Typst0.13.1公共模板+字体、外节ref占位三语编译通过（/tmp/audit-color-{zh,en,bi}.pdf）。query确认6组原标签/eqt别名对应4.21–26的源顺序；没有将无编号式额外编号。实际查看双语第41页白点矩阵和第55页范数/颜色优化，PNG为 /tmp/audit-color-41.png 与 /tmp/audit-color-55.png，长矩阵/范数/代码没有越界裁切。这是复杂代表页验收，不是所有页面/移动网页/最终全书编号验收。类锚点均恢复，所有HTML相对链接改固定书站完整目标；分节网页跨页映射待主agent集成。临时编译入口已删除。章节初校仍需独立复核，不标已精校。

## 批次4：4.7–4.8（awaiting_review，已释放；第4章初校范围完成）

固定 Further_Reading.html 全部19正文段、3个无编号分组标题、页末53条参考文献重新阅读；源无图/表/编号公式/代码/折叠/脚注。对应清单：p1–6辐射度学基础、光度学历史、波动模型、单位类型检查、黑体与照明体、Kirchhoff；p7–11 Spectral Representations 的基函数、误差界、尖峰、波长簇、多重重要性；p12–15 Color 的视觉系统/色域映射/色调再现；p16–19 From RGB to Spectra 的Smits/Mallett/Meng、Jakob/Hanika/Jung、Peters矩方法、Otsu与Tódová数据驱动方法。英文对源补失去的 $xy$ 色度记号，全部中文重新精校，解决辐亮度误称“辐射”、节能误译energy-conserving、multiple importance误为“多个重要性”、模式误代峰、18世纪Lambert句严重断裂，以及基/光谱/插值函数等概念混淆。保留分层波长簇、非镜面界面限定、误差界、平滑性代价、荧光拓展和实测数据库条件。标题采用无编号h3与源一致。

53项书目均接入实际cite；完整作者名保留在正文，不因year引用格式丢失归属。Glassner1989b、Otsu2018b采用源年份后缀显式显示并保留隐藏cite用于书目关联，不以bib基础year抹去后缀。完整原书目共用主agent维护的backmatter/References.typ，不复制另一套53条。映射保存 audit/reports/radiometry-reference-map.json。

主agent新增16条已逐字段复核，全部匹配固定源作者顺序、标题、年份、出版物卷期页码/出版社：mccluney1994introduction、malacara2002color、cie2004colorimetry、judd1964spectral、steinberg2021generic、wilkie2011physically、ciechanowski2019color、morovi2008color、faridul2016colour、eilertsen2017comparative、mallett2019spectral、jakob2019low、jung2019wide、peters2019using、otsu2018reproducing、todova2021moment。McCluney1994与Malacara2002未错用2014/2011新版。源Morovi拼写及Otsu2018b显式保留。

既有bib与固定源存在元数据差异，已报主agent、未擅改公共文件：Moon1936源作者Moon+Spencer，旧bib仅Moon；Moon1948源地点Reading Massachusetts、旧Cambridge且拼写错误；Hall1999源页36–46、旧36–45；Ou2010源1267–77、旧1269–77；Rougeron1997源126–38、旧127–38；Rougeron1998源3–16、旧3–15；Peercy1993源标题没有旧bib中的Speed；Drew2003源rendering、旧bibprocessing。这可能包含原书错误，不应把源和旧bib任一方未经独立资料核实视为最终真值。正文作者/年份与固定源一致；全书显示原书目保留源数据。未新增不可靠事实。

固定 Exercises.html:81–165 四道题全部对照：难度①/①/①/②恢复，不再用猫脸emoji代替。第1题中文错误加入1000W已删除，明确50W、600nm、1s。第2题恢复缺失h、法线方向、单位半径、恒定出射辐亮度及分别按立体角/面积积分要求；源A.5.1链接精确恢复#sec:unit-disk-sample。第3题边长1/高度1/法线方向/辐亮度完整；第4题恢复“同一次运算不混用不同波长”、储存PDF、比较修改前后性能与runtime overhead问题。两个题中单位正确排为W/(m² sr)，不拆sr成变量乘积。四题无答案、额外脚注/图表/代码，未擅加练习答案。

验证：Typst0.13.1公共模板+字体+真实53个cite+完整参考文献，外节ref占位局部三语编译通过，/tmp/audit-radio-tail-{zh,en,bi}.pdf。实际查看双语习题第7页 /tmp/audit-radio-tail-7.png，4题/难度/分式单位完整清晰，无截断；提取文字核验年份1989b/2018b保留。小范围临时入口不使用全书计数，因此0.1/0.2不能作为最终编号证据。未以编译成功证明语义完成；独立复核尚待进行。临时入口删除，diff --check通过。

第4章4.0–4.8九文件与4.5/4.6补充现均已初校并释放；实际原文对照状态为awaiting_review，只有后续独立复核通过后才能标为已精校。公共样式/Web/全书与线上验收由主agent集成，不在本agent的完成声明中冒充通过。
