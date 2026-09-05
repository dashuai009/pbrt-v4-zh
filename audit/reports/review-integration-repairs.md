# 集成修复独立复核

范围限定：bibliography.bib 的指定五项变更，以及 8.7 Sobol_Samplers.typ 原544/546行两种语言段落中的数学转录。未审校8.7整节，未复核其余模板/网站集成项；公共文件未修改。

独立重读固定上游 `f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`：

- References.html:2724 的 Knuth1984 重印句，与本地 note 完整一致。
- :2729 Knuth1986 的 Reading, Massachusetts，与新 address 一致。
- :2735 Knuth1993b 的 ACM Press and Addison-Wesley，与新 publisher 一致。
- :1376 Fraser95 的 Reading, Massachusetts，与新 address 一致。
- :4016 Reinhard2010 作者顺序 Reinhard/Ward/Debevec/Pattanaik/Heidrich/Myszkowski，与新 author 一致。

以上指定变更 verified。仍有原序言复核提出但本批没有修改的差异：Knuth1986、Fraser95 的 publisher 仍是 Addison-Wesley Longman Publishing Co., Inc.，固定原书为 Addison-Wesley。这两项不在本次五个字段修改中，保持待主 agent 裁决；不将“本批修复通过”等同所有书目差异已经消除。

Sobol：重新读取固定上游 `4ed/Sampling_and_Reconstruction/Sobol_Samplers.html` The general approach used 段（约2957行起），MathJax title 明确为 `bold upper C left-bracket d Subscript i ... Superscript upper T`，后文逆矩阵对象为粗体 C。当前英/中两段的 `$bold(C)[d_i(a)]^T$` 和 `$bold(C)$` 与原文数学内容一致，且全文件 U+0008 数量为0。此窄范围公式转录修复 verified；未把现有中文“二次幂”等其他措辞纳入全节精校承诺。

验证是固定源逐项内容读取和控制字符扫描，未进行正式PDF视觉验收。
