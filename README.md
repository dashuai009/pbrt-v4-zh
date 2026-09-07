# PBRT 第四版中文校订

本项目正在对照固定第四版原书逐节精校，并建设共用正文的在线阅读站。**尚未完成全书审校。** 文件存在、编译通过与原文对照／独立复核是不同状态。

- 原书固定提交：`f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c`。
- [全书覆盖清单](audit/COVERAGE.md)、[审校规范与术语](audit/EDITORIAL.md)、[可续接进度](audit/PROGRESS.md)、[独立复核报告](audit/reports/)。
- [逐文件审校指纹](audit/review-status.json)记录实际通过范围；文件及附属内容改变后需要重新复核。
- Pages 配置地址为 [dashuai009.github.io/pbrt-v4-zh](https://dashuai009.github.io/pbrt-v4-zh/)，当前尚未完成线上部署验收；以[网页验收记录](audit/WEB-VALIDATION.md)为准。

## 本地构建

克隆时包含原书子模块：

```sh
git clone --recurse-submodules https://github.com/dashuai009/pbrt-v4-zh.git
cd pbrt-v4-zh
npm ci --prefix tooling --ignore-scripts
bash tooling/install-tools.sh
bash tooling/build.sh
```

经过本地验证的编译组合为 Typst 0.13.1、shiroa CLI 0.3.0／Typst包0.2.0；具体依赖见 [版本记录](tooling/versions.json)和锁文件。系统中的较新Typst可能不兼容旧数学符号。

完整构建产生中文、英文、中英对照三个PDF及全书静态HTML，随后检查实际图形正文、资源和锚点。PDF输出在 `output/`，网站在 `output/site/`。运行 `node tooling/serve.mjs output/site` 后从项目子路径 `/pbrt-v4-zh/` 浏览。

`main.typ` 使用 `content.typ` 的正文清单；`book.typ` 的薄入口包含同一批Typst正文，不另存一份翻译。公共内容函数、PDF样式和Web样式分别维护。代码可复制，长代码／表格在网页局部滚动；搜索索引来自完整渲染正文，包含中文、英文和代码。

原书的 EXR 插图保留原始数据；静态 PNG 按固定 Jeri 的默认显示变换派生，参数、版本和校验值随图记录。需要重新派生时，可在独立 Python 环境安装 `tooling/requirements-exr.txt`，再运行 `python tooling/derive-exr-display.py 原图.exr 显示图.png`。这只处理原图显示，不参与翻译；正常构建使用已记录的 PNG，无需安装这些可选依赖。

## 贡献与验收

禁止运行或依赖历史 `Scripts/` 中的翻译、转换、润色脚本及其审校结论。译文通过逐段原文对照和另一位agent的独立复核推进；代码、公式、图片、脚注、文献和习题均属覆盖范围。新 `tooling/` 仅承担确定性的清单、构建、验证和原图显示派生，不调用翻译模型。

PR工作流检查内容、三种PDF、网站与链接；主分支通过构建后部署Pages；版本标签发布三种PDF。源文自身的疑点、未匹配书目和待校链接均明确记录，不据构建结果宣称全书已精校。

## 许可协议
<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt=""></a><br />本仓库采用<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans">知识共享署名—非商业性使用—相同方式共享4.0国际公共许可协议</a>进行许可。
