#import "references.typ": original-citation
#import "@preview/i-figured:0.2.4"
#import "@preview/cuti:0.2.1": show-cn-fakebold
#import "common.typ": fake-par, show-fig, show-equation

#let pbrt(it) = {
  set page(paper: "a4", margin: 0cm)

  figure(image("/bookcover-4ed.jpg", width: 100%, height: 100%))

  set cite(form: "year")
  show cite: original-citation
  show bibliography: none

  set page(paper: "a4", margin: 2.5cm)
  set heading(numbering: "1.", supplement: [Chapter])

  // heading and fig number
  show heading: i-figured.reset-counters

  show heading.where(level: 1): it => {
    pagebreak()
    it
  }
  show heading.where(level: 2): it => {
    pagebreak()
    it
  }
  set text(font: ("Libertinus Serif", "Source Han Serif SC"), size: 11pt, lang: if sys.inputs.at("LANG_OUT", default: "zh-en") == "en" { "en" } else { "zh" })

  show emph: it => {
    text(font: ("Libertinus Serif", "KaiTi_GB2312"), style: "italic", it.body)
  }

  set figure(supplement: kind => {
    let is-table = kind == table or kind == "i-figured-table" or (type(kind) == content and kind.func() == table)
    if sys.inputs.at("LANG_OUT", default: "zh-en") == "en" {
      if is-table { [Table] } else { [Figure] }
    } else { if is-table { [表] } else { [图] } }
  })
  show figure: show-fig
  show math.equation: show-equation
  show figure.where(kind: table): set figure.caption(position: top)

  set page(
    paper: "a4",
    margin: (inside: 3cm),
    binding: left,
    numbering: "1",
    header: [
      #set text(8pt)
      #smallcaps[PBRT]
      // #h(1fr) _Exercise Sheet 3_
    ],
  )

  // Display inline code in a small box
  // that retains the correct baseline.
  show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )


  show heading: it => {
    it
    fake-par
  }

  // Display block code in a larger block
  // with more padding.
  // Fix
  // 1. Empty parts of a breakable blocks
  //    https://github.com/typst/typst/issues/2914#issuecomment-2423965018
  // 2. Width of Code Block -> 100%
  // 3. Line number Align Issue Fixed
  //    https://github.com/typst/typst/issues/344
  show raw.where(block: true): code => {
    set text(font: ("DejaVu Sans Mono", "Source Han Serif SC"), size: 9pt)
    let listing = grid(
      columns: (auto, 1fr),
      column-gutter: 1em,
      row-gutter: par.leading,
      align: (right, raw.align),
      ..for line in code.lines {
        (
          text(fill: gray)[#line.number],
          line.body,
        )
      },
    )
    block(breakable: code.lines.len() > 12, listing)
    fake-par
  }
  show raw.where(block: true): set block(fill: luma(230), inset: 10pt, width: 100%)

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  show ref: it => {
    let eq = math.equation
    let el = it.element

    if el != none and el.func() == math.equation {
      // Override equation references.
      context {
        let text_lang = text.lang
        let eqt_suf = if text_lang == "zh" {
          "公式"
        } else {
          "Equation"
        }
        link(
          el.location(),
          [#text(eqt_suf) #numbering(
              el.numbering,
              ..counter(math.equation).at(el.location()),
            )],
        )
      }
    } else if el != none and el.func() == heading {
      // Override equation references.
      context {
        let text_lang = text.lang
        let sz = counter(heading).at(el.location()).len()
        let prefix = if sz == 1 {
          // chapter
          if text_lang == "zh" {
            "第"
          } else {
            "Chapter"
          }
        } else {
          // section
          if text_lang == "zh" {
            "第"
          } else {
            "Section"
          }
        }
        let suffix = if sz == 1 {
          // chapter
          if text_lang == "zh" {
            "章"
          } else {
            ""
          }
        } else {
          // section
          if text_lang == "zh" {
            "节"
          } else {
            ""
          }
        }
        link(
          el.location(),
          [#text(prefix) #numbering(
              // "see chapter 1", instand of "see chatper 1."
              if type(el.numbering) == str and el.numbering.starts-with("A") { "A.1" } else { "1.1" },
              ..counter(heading).at(el.location()),
            ) #text(suffix)],
        )
      }
    } else if el != none and el.func() == figure {
      // Override figure references.
      context {
        let text_lang = text.lang
        let is-table = el.kind == table or el.kind == "i-figured-table"
        let prefix = if text_lang == "zh" {
          if is-table { "表" } else { "图" }
        } else {
          if is-table { "Table" } else { "Figure" }
        }
        link(
          el.location(),
          [#text(prefix) #numbering(
              el.numbering,
              // see https://github.com/RubixDev/typst-i-figured/blob/main/i-figured.typ#L6
              ..counter(figure.where(kind: el.kind)).at(el.location()),
            )],
        )
      }
    } else {
      // Other references as usual.
      it
    }
  }
  // 使用 cuti 包实现伪粗体
  show: show-cn-fakebold

  it
}
