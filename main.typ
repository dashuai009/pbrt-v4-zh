
#import "template.typ": pbrt

#show: pbrt
#include "authors.typ"
#pagebreak()
#include "editorial-status.typ"
// #figure(
//   image("pbr-book-website/landing.jpg"),
// )
//

#outline(
  title: if sys.inputs.at("LANG_OUT", default: "zh-en") == "en" { [Contents] } else { [目录] },
  indent: auto,
)

#pagebreak()


#include "content.typ"
