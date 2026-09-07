#import "templates/shiroa-page.typ": project
#import "@preview/shiroa:0.2.0": shiroa-sys-target, cross-link
#let citation-map = json("/audit/citation-map.json")
#let reference-page = json("generated/reference-page.json")
#let references = json("generated/references.json")
 #let local-links = json("generated/local-links.json")
#let label-targets = json("generated/label-targets.json")
#let source-links = json("generated/source-links.json")
#let base-path = json("generated/base-path.json")
#let reader(title: "PBRT", source: "", local-file: "", lang: "zh", section-number: "", review-report: "", body) = {
  show: project.with(title: title)
  if section-number != "" {
    let parts = section-number.split(".")
    let appendix = parts.first().match(regex("^[A-C]$")) != none
    let nums = parts.enumerate().map(((i, p)) => if appendix and i == 0 { p.to-unicode() - "A".to-unicode() + 1 } else { int(p) })
    nums.at(nums.len() - 1) -= 1
    counter(heading).update(nums)
  }
  set heading(numbering: if section-number == "" { none } else if section-number.match(regex("^[A-C]")) != none { "A.1" } else { "1.1" })
  set text(lang: if lang == "zh" { "zh" } else { "en" })
  let locals = local-links.at(local-file, default: (:))
  let selector-local = locals.keys().fold(selector(label("reader-unused-anchor")), (acc, key) => acc.or(label(key)))
  show link: it => {
    if type(it.dest) == label and str(it.dest) in label-targets {
      let r = label-targets.at(str(it.dest))
      return link(base-path + "web/generated/" + lang + "/" + r.slug + ".html#" + r.anchor, it.body)
    }
    let routes = source-links.at(local-file, default: (:))
    if type(it.dest) == str and it.dest in routes {
      let r = routes.at(it.dest)
      if r.kind == "internal" { link(base-path + "web/generated/" + lang + "/" + r.slug + ".html#" + r.anchor, it.body) }
      else if r.kind == "original" { link(r.url, [#it.body#super[原]]) }
      else { [#it.body#super[引用待校]] }
    } else { it }
  }
  set cite(form: "year")
  show raw.where(block: true): it => context if shiroa-sys-target() == "html" { html.elem("pre", html.elem("code", it.text, attrs: ("data-language": if it.lang == none { "text" } else { it.lang }))) } else { it }
  show image: it => context if shiroa-sys-target() == "html" { html.elem("span", html.frame(if it.width != auto and it.width.ratio != 0% { box(width: 600pt, it) } else { it }), attrs: (class: "source-svg")) } else { it }
  show table: it => context if shiroa-sys-target() == "html" { html.elem("div", it, attrs: (class: "table-scroll")) } else { it }
  show grid: it => context if shiroa-sys-target() == "html" { html.elem("div", html.frame(it), attrs: (class: "figure-frame")) } else { it }
  show bibliography: none
  show cite: it => {
    let record = citation-map.at(str(it.key), default: none)
    let anchor = if record == none { "complete-references" } else { record.anchor }
    let body = if record != none and it.form == "year" { [#record.year#if it.supplement != none { [, #it.supplement] }] } else { show link: inner => inner.body; it }
    link(base-path + "web/generated/" + lang + "/" + reference-page + ".html#" + anchor, body)
  }
  show par: it => context if shiroa-sys-target() == "html" and it.has("label") and str(it.label).starts-with("original-reference-") { html.elem("div", it, attrs: (id: str(it.label))) } else { it }
  show footnote: it => context if shiroa-sys-target() == "html" {
    let n = counter(footnote).at(it.location()).first()
    html.elem("sup", html.elem("a", str(n), attrs: (href: "#note-" + str(n), id: "note-ref-" + str(n))))
  } else { it }
  // Language selection is scoped through state, shared by the body helpers.
  state("reader-language", none).update(lang)
  show ref: it => context {
    let key = str(it.target)
    if key in references {
      let r = references.at(key)
      let zh = text.lang == "zh"
      let num = r.number.trim(".")
      let ref-text = if r.kind == "equation" { (if zh { "公式 " } else { "Equation " }) + num }
      else if r.kind == "figure" { (if r.label.starts-with("tbl:") { if zh { "表 " } else { "Table " } } else { if zh { "图 " } else { "Figure " } }) + num }
      else if r.counters.len() == 1 { (if num.match(regex("^[A-C]")) != none { if zh { "附录 " } else { "Appendix " } } else { if zh { "第 " } else { "Chapter " } }) + num + if zh and num.match(regex("^[0-9]")) != none { " 章" } else { "" } }
      else { (if zh { "第 " } else { "Section " }) + num + if zh { " 节" } else { "" } }
      link(base-path + "web/generated/" + lang + "/" + r.slug + ".html#" + r.anchor, ref-text)
    } else { it }
  }
  show heading: it => {
    if it.has("label") and str(it.label) == "complete-references" and shiroa-sys-target() == "html" { html.elem("span", attrs: (id: "complete-references")) }
    if it.has("label") and str(it.label) in references {
      let r = references.at(str(it.label))
      if shiroa-sys-target() == "html" { html.elem("span", attrs: (id: r.anchor)) }
      heading(level: it.level, numbering: none)[#r.number #it.body]
    } else { it }
  }
  show math.equation: it => {
    let key = if it.has("label") { "eqt:" + str(it.label) } else { "" }
    if key in references {
      let r = references.at(key)
      if shiroa-sys-target() == "html" { html.elem("span", attrs: (id: r.anchor)) }
      math.equation(it.body, block: it.block, numbering: (..nums) => r.number)
    } else { it }
  }
  show figure: it => {
    let key = if it.has("label") { (if it.kind == table { "tbl:" } else { "fig:" }) + str(it.label) } else { "" }
    if key in references {
      let r = references.at(key)
      if shiroa-sys-target() == "html" { html.elem("span", attrs: (id: r.anchor)) }
      figure(it.body, caption: it.caption, kind: it.kind, supplement: if it.kind == table { if lang == "zh" { [表] } else { [Table / 表] } } else { if lang == "zh" { [图] } else { [Figure / 图] } }, numbering: (..nums) => r.number)
    } else { it }
  }
  // Run before type-specific renderers so labels on raw/code/paragraphs survive.
  show selector-local: it => context if shiroa-sys-target() == "html" {
    let inline = repr(it.func()) in ("text", "emph", "strong", "link") or (it.func() == raw and not it.block)
    html.elem(if inline { "span" } else { "div" }, it, attrs: (id: locals.at(str(it.label))))
  } else { it }
  [#link("https://pbr-book.org/" + source)[英文原书] · #link("https://github.com/mmp/pbr-book-website/blob/f6d66f0a6e31c3d3ed6a0756c3ad7b4af2dd8c4c/" + source)[对照版本] · #link("https://github.com/dashuai009/pbrt-v4-zh/issues/new")[纠错] · #if review-report == "" { [待精校及独立复核] } else { link("https://github.com/dashuai009/pbrt-v4-zh/blob/main/" + review-report)[已对照并独立复核；源文疑点见记录] }]
  body
  context if shiroa-sys-target() == "html" {
    let notes = query(footnote)
    if notes.len() > 0 {
      html.elem("section", attrs: (class: "footnotes"), [
        #heading(level: 2, numbering: none)[注释]
        #for note in notes {
          let n = counter(footnote).at(note.location()).first()
          html.elem("div", attrs: (id: "note-" + str(n)), [#link("#note-ref-" + str(n))[#n.] #note.body])
        }
      ])
    }
  }
}
