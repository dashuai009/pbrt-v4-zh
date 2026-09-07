// Preserve source MathJax ex dimensions and baseline in both layout engines.
#let original-math(path, height-ex, depth-ex, alt) = context {
  if "target" in dictionary(std) and std.target() == "html" {
    html.elem("span", html.frame(image(path, alt: alt)), attrs: (
      class: "original-math",
      style: "display:inline-block;line-height:0;height:" + str(height-ex) + "ex;vertical-align:" + str(-depth-ex).replace("−", "-") + "ex;",
    ))
  } else {
    let x-height = measure(text(top-edge: "x-height", bottom-edge: "baseline")[x]).height
    box(baseline: depth-ex * x-height,
      image(path, height: height-ex * x-height, alt: alt))
  }
}
