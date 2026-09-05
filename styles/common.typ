#import "@preview/i-figured:0.2.4"
#import "@preview/cuti:0.2.1": show-cn-fakebold
#import "@preview/xyznote:0.2.0": markbox


// 首行所进
#set par(first-line-indent: 2em)

// PDF selection is static so headings retain searchable outline/bookmark text.
// Shiroa entries select language through scoped state; only that path needs context.
#let render-paragraph(lang, en-body, cn-body) = {
  if lang == none or lang == "zh-en" or lang == "en" {
    set heading(outlined: lang == "en")
    set par(justify: true, leading: 0.7em)
    set text(lang: "en")
    en-body
  }
  if lang == none or lang == "zh-en" or lang == "zh" {
    set heading(outlined: true)
    set par(justify: true, leading: 1em, first-line-indent: 2em)
    set text(lang: "zh")
    cn-body
  }
}
#let render-caption(lang, en-body, cn-body) = {
  if lang == none or lang == "zh-en" or lang == "en" {
    set text(lang: "en")
    en-body
  }
  if lang == none or lang == "zh-en" { text(" / ") }
  if lang == none or lang == "zh-en" or lang == "zh" {
    set text(lang: "zh")
    cn-body
  }
}
#let parec(en-body, cn-body) = {
  if sys.inputs.at("x-target", default: "pdf") == "pdf" {
    render-paragraph(sys.inputs.at("LANG_OUT", default: none), en-body, cn-body)
  } else {
    context render-paragraph(state("reader-language", none).get(), en-body, cn-body)
  }
}
#let ez_caption(en-body, cn-body) = {
  if sys.inputs.at("x-target", default: "pdf") == "pdf" {
    render-caption(sys.inputs.at("LANG_OUT", default: none), en-body, cn-body)
  } else {
    context render-caption(state("reader-language", none).get(), en-body, cn-body)
  }
}

#let translator(note, en: none) = {
  let render(lang) = {
    if lang == "en" {
      if en != none { markbox[Editorial note: #en] }
    } else { markbox[译者注：#note] }
  }
  if sys.inputs.at("x-target", default: "pdf") == "pdf" {
    render(sys.inputs.at("LANG_OUT", default: "zh-en"))
  } else {
    context render(state("reader-language", none).get())
  }
}

// Fake Paragraph
// 纯中文环境下，Typst的大标题下第一段不会自动缩进，添加假段落修复。
// 挪出来成为全局量的原因是，公式下方的文字会分为不用空两格和需要空两格的情况。当需要空两格的时候，直接调用这里的 `#fake-par` 即可。
#let empty-par = par[#box()]
#let fake-par = context empty-par + v(-measure(empty-par + empty-par).height)

// 只有有label的图片才通过 i-figured 进行编号
// 能够排除掉每章的第一张图
#let source-numbers = json("/audit/source-numbers.json")
#let original-number(it, prefix) = {
  let file = state("source-file", none).at(it.location())
  let key = prefix + str(it.label).replace(regex("^(eqt:|eq:|fig:|tbl:|tab:|table:)"), "")
  if file != none { source-numbers.at(file, default: (:)).at(key, default: none) } else { none }
}
#let appendix-at(location) = {
  let chapters = query(heading.where(level: 1).before(location))
  if chapters.len() == 0 { false } else {
    let format = chapters.last().numbering
    type(format) == str and format.starts-with("A")
  }
}
#let show-fig(it) = context {
  if not it.has("label") { it } else {
    let value = original-number(it, if it.kind == table or it.kind == "i-figured-table" { "tbl:" } else { "fig:" })
    i-figured.show-figure(it, numbering: if value != none { (..nums) => value } else if appendix-at(it.location()) { "A.1" } else { "1.1" })
  }
}
#let show-equation(it) = context {
  if not it.block or not it.has("label") { it } else {
    let value = original-number(it, "eqt:")
    i-figured.show-equation(it, only-labeled: true, numbering: if value != none { (..nums) => value } else if appendix-at(it.location()) { "(A.1)" } else { "(1.1)" })
  }
}
