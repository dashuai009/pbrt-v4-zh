#include "/main.typ"
#context {
 let targets = json("/output/link-labels.json").map(key => {
   let matches = query(label(key))
   (key: key, matches: matches.map(it => (source-file: state("source-file", none).at(it.location()), kind: repr(it.func()))))
 })
 [#metadata(targets) <link-target-export>]
}
