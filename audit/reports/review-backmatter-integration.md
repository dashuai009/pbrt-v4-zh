# Backmatter 集成增量独立复核

本次复核由与增量作者不同的agent执行。先读旧review-backmatter.md和独立backmatter_checker.py：后者仅读固定原HTML及本地正文，按文字/链接/SVG XML事件逐项比较并输出审计证据，不生成翻译或转换正文，符合本任务禁用旧Scripts的边界。

## 可恢复的范围

`backmatter/References.typ`、`Index_of_Fragments.typ`、`Index_of_Identifiers.typ`及共同依赖`backmatter/math/inline.typ`可按本报告和`backmatter-integration-hashes.json`恢复**原文转录与本次集成改动的独立复核状态**。不表示1355篇文献内容已作事实核查或全站链接完成验收。

- 两索引正文当前SHA256与旧ledger独立复核SHA256逐字节相同。
- References仅移除新增1355个original-reference-N标签及complete-references标题标签，即精确得到旧SHA256 `12b5a2a196d7edaeb97ffaed6a6d2eaaaa4e66a133be3eec707d11ad088f27ed`。没有其他正文/数字/引用变化。
- 1355个条目标签连续、唯一且顺序1–1355；实际Typst0.13.1编译后，在context中逐标签query验证每个均恰好命中一次。标题标签唯一且未引入编号。
- 重跑独立检查器，固定源仍为f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c：1355书目、1696片段、2382标识符共5433项的内容、顺序、分组、缩进层级全部通过；4078唯一固定源目标/4083引用无缺失；102SVG/250使用的XML及alt、ex高度/深度全部一致。原有11处HTML非法嵌套链接及URL根斜线等价规范化保持明确记录。

## 发现并修复的Web基线问题

实际用固定`.tools/bin/shiroa` static-html编译临时隔离页面（使用项目shiroa模板及真实References），发现helper的`str(-depth-ex)`输出Unicode减号U+2212，形成`vertical-align:−0.671ex`。浏览器CSS解析实测忽略该值，`element.style.verticalAlign`为空，computed值为baseline。这会破坏原MathJax下标/基线，即使网站构建成功。

在helper中仅对该数值字符串执行`.replace("−", "-")`，明确输出CSS要求的ASCII减号。重新shiroa编译并载入项目site.css后，浏览器实测parsed值为`-0.671ex`、computed值为`-5.55051px`；cosθ_i例子span/svg高度均20.75px，LP_τ例子span/svg高度均11.1015625px。实际截图查看两例，θ_i与τ下标位置正确、公式未消失或上浮。该检查不修改Web公共模板、样式或page.typ。

HTML分支以span承载源ex高度、负深度下移及框内原SVG；PDF分支仍按字体x-height换算ex，未改源SVG、公式或alt。CSS `.original-math>svg`在现有site.css中将子SVG高度设为100%、宽度auto，与父span显式ex高度配合。浏览器检查基于现有此CSS，不声称无CSS时同样准确。

## PDF与限制

当前四文件以公共PDF模板、0.13.1和fonts合并独立编译成功，无引用占位。实际查看`/tmp/review-backmatter-integration.pdf`第2页：书目标题、条目、LP_τ下标及悬挂缩进完整，没有裁切。此次没有再次逐页看三份全书PDF，也没有声称已验证根agent正在调整的Web分节标签映射。临时shiroa隔离页面使用普通project模板，不能作为正式Web原文条目链接ID验收；1355label唯一性是实际PDF/Typst查询证据。

新SHA256见同目录backmatter-integration-hashes.json。临时Typst入口、测试书目录、浏览器页与本地测试服务器已清理。所有复核范围释放。
