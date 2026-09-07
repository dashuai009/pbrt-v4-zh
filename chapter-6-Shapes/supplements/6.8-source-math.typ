// Exact MathJax SVG from fixed upstream; private to the rounding-error section.
#let source-math(path, width-ex, height-ex, depth-ex, alt, display: false) = context {
  let ex = measure(text(top-edge: "x-height", bottom-edge: "baseline")[x]).height
  let scale = if display { calc.min(1, 142mm / (width-ex * ex)) } else { 1 }
  box(baseline: depth-ex * ex * scale,
    image(path, width: width-ex * ex * scale, height: height-ex * ex * scale, alt: alt))
}
