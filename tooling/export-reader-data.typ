// Both exports share one real full-book layout, preserving exact counter ownership.
#include "/main.typ"
#context {
  let references = query(selector(heading).or(figure).or(math.equation)).filter(it => it.has("label")).map(it => {
    let kind = if it.func() == heading { "heading" } else if it.func() == figure { "figure" } else { "equation" }
    let nums = if kind == "heading" { counter(heading).at(it.location()) } else if kind == "figure" { counter(figure.where(kind: it.kind)).at(it.location()) } else { counter(math.equation).at(it.location()) }
    let value = if it.numbering != none { numbering(it.numbering, ..nums) } else { "" }
    (source-file: state("source-file", none).at(it.location()), label: str(it.label), kind: kind, number: value, counters: nums)
  })
  let targets = json("/output/link-labels.json").map(key => {
    let matches = query(label(key))
    (key: key, matches: matches.map(it => (source-file: state("source-file", none).at(it.location()), kind: repr(it.func()))))
  })
  [#metadata((references: references, targets: targets)) <reader-export>]
}
