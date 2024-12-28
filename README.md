# pbrt-v4-zh
pbrt v4中文机器翻译

[![](https://img.shields.io/badge/源码语言-Typst-brightgreen?style=flat-square)](.)
[<a rel="license" href="#许可协议"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt="">](#许可证)

供个人学习使用。

## references

- bibtex: [pbrt-v3 翻译](https://github.com/kanition/pbrtbook/blob/main/bibliography.bib) 我这里直接拿过来用了，bibtex 也能被typst识别，修改了一些citation key，typst不识别doi号（数字开头）作为全局唯一key。
- pbrt website: [3ed/4ed website](https://github.com/mmp/pbr-book-website)

## build

1. 安装[typst]("https://github.com/typst/typst?tab=readme-ov-file#installation")
2. clone本仓库（包括依赖的[原始仓库]("https://github.com/mmp/pbr-book-website")里的图片）
```
git clone --recursive https://github.com/dashuai009/pbrt-v4-zh.git
```
3. 构建pdf

- 输出中英文交替的pdf
```
typst c main.typ pbrt-v4-zh-en.pdf --font-path ./fonts
```

   - 输出仅中文的pdf
```
typst c main.typ pbrt-v4-zh.pdf --font-path ./fonts --input LANG_OUT=zh
```

   - 输出仅英文的pdf
```
typst c main.typ pbrt-v4-en.pdf --font-path ./fonts --input LANG_OUT=en
```

## 许可协议
<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/nc.svg?ref=chooser-v1" alt=""><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/sa.svg?ref=chooser-v1" alt=""></a><br />本仓库采用<a rel="license" href="https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans">知识共享署名—非商业性使用—相同方式共享4.0国际公共许可协议</a>进行许可。

## 一些符号

练习的难度：
`#emoji.cat.face.laugh`  `#emoji.cat.face.laugh Similarly` `#emoji.cat.face.shock `


## typst todo!

pdf的样式问题

- 章节链接的样式，比如typst文档`balabala @ch1`，英文用`balabala Chapter `，中文`balabala 第一章`。typst文档`balabala @ch1.1`，英文用`balabala Section 1`，中文`balabala 第1.1节`。
- 代码，pbrt
- 中文粗体，图片的描述上，用的不多。换个字体？
- 目录样式，好看一点。
- fontnode的编号按照章节重新计数
- 搭建website
- 代码跳转
- table样式