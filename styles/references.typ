// Keep the existing CSL citation formatting, but use the complete original list once.
#let citation-map = json("/audit/citation-map.json")
#let original-citation(it) = {
  let record = citation-map.at(str(it.key), default: none)
  let target = label(if record == none { "complete-references" } else { record.anchor })
  let body = if record != none and it.form == "year" { [#record.year#if it.supplement != none { [, #it.supplement] }] } else { show link: inner => inner.body; it }
  link(target, body)
}
