// Direct source-ID citations for newly reviewed material; no legacy BibTeX inference.
#let records = json("/audit/original-citations.json")
#let source-cite(id, supplement: none) = {
  let key = if id.starts-with("cite:") { id } else { "cite:" + id }
  let record = records.at(key, default: none)
  assert(record != none, message: "Original citation requires an explicit source match: " + key)
  let body = [#record.year#if supplement != none { [, #supplement] }]
  if sys.inputs.at("x-target", default: "pdf") == "pdf" {
    link(label(record.anchor), body)
  } else {
    context {
      let base = json("/web/generated/base-path.json")
      let page = json("/web/generated/reference-page.json")
      let lang = state("reader-language", none).get()
      link(base + "web/generated/" + lang + "/" + page + ".html#" + record.anchor, body)
    }
  }
}
