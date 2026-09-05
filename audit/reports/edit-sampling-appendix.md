# 附录 A 正文精校（分批记录）

固定原书：f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c，4ed/Sampling_Algorithms.html 及 Sampling_Algorithms/ 对应页面。禁止旧脚本与模型批调用；由当前 agent 完整读原文、译文及折叠代码，手工决定每条译文与数学映射。确定性读取器仅用于提取已读的英文和代码，不替代语义审阅。

## 批次一：A.0／A.1

状态：awaiting_review；A.0-Sampling_Algorithms.typ、A.1-The_Alias_Method.typ 及 supplements/A.1-expanded.typ 已释放。

实际范围：A.0完整1段和标题；A.1完整22段正文、表A.1全部4行/3列及图注、图A.1及图注、首段脚注、15个可见代码片段和所有行内数学。源表锚点table:alias-table与图锚点fig:alias-table分别保留为本地<table:alias-table>和<alias-table>；表引用用@tbl:table:alias-table。无原书编号显示公式，因此本批不涉及后面重复A.17的问题。

修复：
- 恢复遗漏的alias/aliasing区分脚注、桶概率质量解释段，以及初始化可完成/终止的直观论证段。
- 原表曾是text代码块、图完全缺失且图标题重复；恢复真正表格与固定phaaaf01.svg。
- 原英文O(n)、O(log n)、O(1)被错误转成cal(O)(n)(n)等，floor(nξ)错作floor(n x_i)，p-hat下标错作撇号、p_v或\hat字符串；均据固定数学SVG逐项恢复。
- 修复“每个结果创建n个桶”的误译为总共n桶、每结果一桶；第二与第三表项各以1/4概率选中，不是两者合计1/4。
- 恢复Bin存储q、p及alias的完整定义说明，区分每桶条件概率q与结果概率p。
- 代码不再把展开副本拼在<<片段名>>同一行；恢复原可见结构，已在其他可见片段出现的展开内容不重复。
- A.0统一蓄水池采样、别名法、逆变换法，修复引文章号后错误分号，标题支持语言选择。

额外折叠代码：fragbit-2629中的AliasTable公有方法去掉正文已有size()/PMF()后剩6行；fragbit-2638中的剩余列表处理12行，附入supplements/A.1-expanded.typ。重新读原面板并检查全部语句；原有两个可无参数调用的构造函数及其默认实参不擅自改写。其他折叠内容都是15个可见片段的组合，不重复补录。

代码与数学的源条件限制：正文未专门处理空输入/总权重为零，构造与Sample实现按源文保留，不能宣称退化输入可用。本轮不替原代码设计新行为。

验证：Typst0.13.1正式main.typ中/英/对照均退出0，输出/tmp/edit-sampling-appendix-batch1-{zh,en,bilingual}.pdf。中文1151–1156六页全部实际查看：O复杂度、概率分数、p-hat、表A.1与图A.1编号、全部代码及折叠补充可见，无截断/重叠。git diff --check通过。仍需另一agent独立复核，不自称已精校。

## 批次二：A.2／A.3

状态：awaiting_review；A.2/A.3及supplements/A.2-expanded.typ已释放。

实际范围：固定Reservoir_Sampling.html全部15段、5行数学伪代码、12可见代码片段、全部折叠额外内容；The_Rejection_Method.html全部6段、4行数学伪代码、2图及图注、1个代码片段。两节均无原书脚注、数据表或编号显示公式。

修复与补齐：
- A.2补回Add()作用说明和样本访问方法引言；将reservoirWeight说明及代码放回正确位置，删除原本重复的查询方法、Reset段和无来源的additional methods占位代码。
- 保留1/n、1/(n+1)、n/(n+1)的归纳论证，统一蓄水池采样/蒙特卡洛/估计量术语。算法由text代码恢复为可排版数学伪代码，控制文字随语言选择，变量名不改。
- A.2类定义恢复为源文可见片段结构，避免把折叠实现粘在占位名后。补充保留fragbit-2646中仅折叠展示的Copy（5行）、ToString（5行），以及回调实现（6行）。fragbit-2648和2651的回调代码忽略空白后完全相同，只保留一次。
- A.3恢复真正的无限循环拒绝采样算法；原文几何条件是(X,ξ c p(X))在f(X)下方，旧译漏了c p(X)并把“下方”误说成两函数间区域，现修正。
- A.3两个完整图注均补译，恢复fig:rejection-sample与fig:rejection-sample-disk的唯一映射，实际显示A.2/A.3；Sample代码的前一片段链接依源文指向Volume_Scattering/Phase_Functions.html，而非虚构本节标签。
- 恢复π/4≈78.5%，最后的[0,1)^n半开域，去掉旧译中无来源的紧凑单次公式及重复开头。

源问题保留：A.3原文先说预期拒绝比例，后给π/4（接受率），已加明确译注，英文与数值保留。源图A.3称unit square，代码实际取[-1,1]²外接正方形，中文按原图注保留单位措辞，未擅改代码。A.2 Merge保证选择分布的论述与后续SampleProbability()如何解释须另审：Merge调用Add(sample,另池weightSum)会把reservoirWeight设为池总权重；本轮不修改这一源实现，也不宣称合并后该查询值已验证为原始单样本的边缘概率。

验证：曾被活动4.6的引用分隔错误阻断，未改别人的文件；主agent确认修复后，Typst0.13.1正式main.typ中/英/对照均退出0，输出/tmp/edit-sampling-appendix-batch2-{zh,en,bilingual}.pdf。中文1164–1170七页全部实际查看：算法、概率公式、代码、补充、两图及图号、78.5%译注均完整，无裁切/重叠。独立复核仍待另一agent完成。

## 批次三：A.4／A.5

状态：awaiting_review；A.4/A.5、supplements/A.4-expanded.typ、A.5-expanded.typ、source-math.typ及本批数学资产已释放。

实际逐段范围（本批待独立复核）：
- `Sampling_1D_Functions.html` 全部64段、7个子节、20个显示公式、全部行内数学、34个可见代码片段、2图及完整图注，以及指数采样对数端点段的原脚注。
- `Sampling_Multidimensional_Functions.html` 全部91段、6个子节、23个显示公式、全部行内数学、53个可见代码片段、9图及完整图注。该源页无脚注或数据表。
- 两源页全部66个折叠面板重新读取。58个与单个可见片段一致；其余8个为组合面板，逐段扣除已展示定义和补充定义后没有剩余代码。证据记录完整面板文本，不只记录数量。

主要恢复和精校：
- A.4恢复帐篷函数定义、等概率两侧采样及重映射说明、单调连续样本映射、指数归一化/CDF/逆变换和原对数端点脚注；恢复缺失的SampleExponential而非重复逆采样代码。
- 恢复高斯/正态、logistic、区间截断、smoothstep求根及分段常数采样的全部推导。删除旧译聊天残留、重复片段、无来源小结和空方法占位；修正区间、绝对值、CDF数组n+1、PDF归一化、optional返回值及末端索引解释。
- A.5恢复极坐标圆盘采样与同心映射、半球/球面/余弦半球/圆锥采样的推导和实现，明确方向PDF相对于立体角而非角坐标密度或单点概率。
- 恢复二维分段常数分布的整数索引、半开单元、边缘/条件归一化、完整PiecewiseConstant2D与窗口采样代码。旧译把离散索引误说成连续[0,1)值，现依原文修正。
- 恢复积分表递推、右上角坐标约定、无0.5偏移、下界零值、不存储零边、任意矩形的容斥积分、双精度消减风险、窗口积分零值返回、条件采样舍入退化检查及二分法的等长分段线性CDF前提。统一积分表/summed-area table、积分图像/integral image。
- 两节共11幅原图均直接使用固定源资源phaaaf04.svg至phaaaf13.svg及phaaaf14.png，图A.4–A.14和全图注恢复。数学图示与中文引用分别对照，不凭文件存在判断完整。
- 代码标题保留原名、原标签和上下片段导航；同页箭头指向真实本地标签，跨页箭头保留准确固定原书目标。代码标识符与源语句未改写；长代码按公共样式换行，小片段和补充中的完整短方法避免跨页截断。

折叠补充：
- `fragbit-2652`仅补回正文未显示的PiecewiseConstant1D内存统计、调试/字符串方法及其他构造函数（15行）。其余四组PublicMethods及PublicMembers组合已在正文。
- `fragbit-2674`补回PiecewiseConstant2D额外构造函数及辅助方法（31行）和Invert实现（13行）；其中Invert虽然正文称未列出，实际存在于固定HTML折叠面板，必须纳入。
- `fragbit-2680`仅剩SummedAreaTable的ToString声明（1行），原书没有给出实现，不凭猜测补写。
- `InvertNormalSample`、`InvertUniformDiskPolarSample`、`InvertUniformDiskConcentricSample`、`InvertUniformConeSample`在本页只有省略说明/锚点，没有隐藏实现；保留该范围边界，不虚构代码。

数学转换与证据：
- 旧稿中的tex代码显示式全部恢复为真实数学对象。7个简单显示式用原生Typst；其余36式按主agent授权，用固定原SVG置于`math.equation`中。行内简单变量原生排版，复杂表达式使用固定原SVG。
- `supplements/source-math.typ`依据原SVG的ex宽高、CSS vertical-align构造尺寸与基线，显示式统一等比例限制到142mm；用box承载image避免段内图片被忽略。每式title用作alt，不改变字形几何。
- A4/A5数学证据分别记录123/173个源数学出现位置及78/110个唯一原SVG，记录源路径、行号、完整MathJax标题、尺寸、基线深度及sha256。全部资产逐个确认字节出现在固定原HTML内，XML title与记录一致。原生显示式与SVG显示式的选择另有逐式表，不用SVG存在替代语义核对。
- 两源页11个带标签公式都在固定原书错误显示为A.17。逐式保留唯一原锚点和源显示编号，已实际看见对应A.17；没有擅自连续重编号。图编号则依原书分别为A.4–A.14。
- 初次渲染发现中文`sin theta/(...)`与`cos theta/pi`被Typst解释成三角函数参数中的分式，已改用显式frac并再次视觉确认。帐篷分段条件加入明确列间距，条件文字随语言选择。

保留并明确说明的原书疑点：
1. SampleTwoNormal把cos/sin乘积放入sqrt内部，与前面极坐标关系不一致并可能对负数开方；保留源码并加译注，未改写为推测正确的实现。
2. TrimmedLogisticPDF调用Logistic而前文展示的是LogisticPDF；保留标识符并标出名称对应疑点。
3. 区间采样原文称插值后的ξ不在0和1之间，但CDF端点及其插值仍位于[0,1]；保留英文，中文明确校注。
4. smoothstep源CDF多出分母(b-a)，与其PDF积分和随后代码P=2t³-t⁴不一致；原式保留，校注给出直接推导出的矛盾。
5. InvertSmoothStepSample的lambda没有使用参数x，三次P调用得到同值；保留代码并指出最后是零除以零。
6. PiecewiseConstant1D逆采样原文称返回[0,1)，但非空、非退化且计算有效时x==max被接受并返回cdf[n]=1；追加边界校注。没有把区间偷偷改成闭区间来掩盖源差异。
7. 积分表原文把归一化描述为除以分层“大小”，代码实际除以NxNy（即乘单位域内每格面积）；中文据代码说清，并明确标为校注。
8. 不宣称所有退化参数、负输入表或零积分PDF可用：本轮保留源文及代码的既有前提与行为，不为采样实现补设计。源PDF正确性相关条件仍需独立复核者核对。

持久证据：`A4-source-events.json`、`A5-source-events.json`提供原文顺序与行定位；`A4-math-evidence.json`、`A5-math-evidence.json`及`A45-display-math-evidence.json`提供逐式对应；`A45-all-panels-evidence.json`保存全部66面板的实际代码和去重依据；`A45-expanded-evidence.json`保存补充代码源面板位置。确定性比对只作辅助，不能把这些文件称为独立语义复核。

验证：最终固定Typst0.13.1正式main.typ三语构建均退出0，三个日志均0字节；输出/tmp/edit-sampling-appendix-batch3-{zh,en,bilingual}.pdf。首次中文全范围1170–1205共36页逐页实际查看；修复后重看帐篷分段式、截断CDF、半球/圆锥三角分式、三个节标题、补充完整方法分页。中英对照1718/1743/1751实际查看，英文1232查看原脚注与高斯公式，末次中文1178查看新端点校注（共享工作区其他章节变化会改变全书页码）。复杂SVG、编号、图表、公式和代码均未裁切或被忽略。最终本批git diff --check通过。

实际限制：公共translator函数目前无条件输出中文“译者注：”，本批4条块状中文源问题注释因此也会出现在英文PDF；已告知主agent，需公共语言层与这些注释调用一并统一。这不影响英文原文保留，但不能标为三语校注语言一致性已完成。网页端的数学SVG、移动端与链接跳转由主agent后续整站验证；本轮没有以PDF构建证明网页通过。内容仍须不同agent完整重读固定原文、所有数学SVG及译文后独立复核。
