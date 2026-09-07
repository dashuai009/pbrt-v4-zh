# 固定源引用修复（不代表整节精校）

2026-09-08：12.6两处中英链接共四次出现修复。固定Light_Sampling.html第3191行实际href为#LightBounds::Importance，第3735行href以BVHAggregate::buildRecursive结束，均没有函数括号；目标分别在同页1242及Bounding_Volume_Hierarchies.html642行存在。只修复转录的链接地址，正文待该节初校/独立复核。没有通过模糊去括号规则批量猜测目标。

2026-09-08：增强零尺寸检查发现B.2二次求根段中英空数学`$$`。固定Mathematical_Infrastructure.html3150–3152的MathJax title为b almost-equals plus-or-minus StartRoot b squared minus 4 a c EndRoot；按此恢复±√(b²−4ac)。只修这一原文段的转换遗漏，B.2整节仍待初校与独立复核；此单项亦待独立复核。

9.1编号别名核对发现图9.3图注与资源错配：固定BSDF_Representation.html1650/1656/1662是shading-normal与pha09f03.svg，本地误用图9.2资源pha09f02.svg且漏n_g/n_s。现按该源恢复资源和图注两符号，并使引用指向编号figure目标；图9.2原位置的缺失仍待第9章初校处理，不能由这项修复标全节完整。此单项待独立复核。

9.1复核纠正：图9.2实际已在文件首部存在，先前“图9.2缺失”的判断不成立。root首次资源替换误命中首个同路径图，已恢复首部图9.2的pha09f02.svg；现按<pha09f03>所在figure块精确将第二处改为pha09f03.svg。独立复核将再核两处。
