#text(size: 14pt)[#upper[*about me*]]

#{
  if ("LANG_OUT" not in sys.inputs) or sys.inputs.LANG_OUT == "zh" {
    text(size: 18pt)[#upper[*译者序*]]
    par([本书（也就是仓库#link("https://www.github.com/dashuai009/pbrt-v4-zh")[pbrt-v4-zh]）由gpt翻译而来。])
    par[
      本书使用
      #link("https://creativecommons.org/licenses/by-nc-sa/4.0/deed.zh-hans")[知识共享署名—非商业性使用—相同方式共享4.0国际公共许可协议],
      进行许可,
    ]
  }
}