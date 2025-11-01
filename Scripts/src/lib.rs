use pyo3::prelude::*;
use std::fs::{self, read_to_string};
use std::io::Write;
use typst::diag::EcoString;
use typst::syntax::ast::{Arg, AstNode, Escape, Expr, FuncCall};
use typst::syntax::SyntaxKind;

// use unicode_general_category::GeneralCategory;

// fn is_punctuation(c: char) -> bool {
//     matches!(
//         GeneralCategory::of(c),
//         GeneralCategory::ConnectorPunctuation
//             | GeneralCategory::DashPunctuation
//             | GeneralCategory::OpenPunctuation
//             | GeneralCategory::ClosePunctuation
//             | GeneralCategory::InitialPunctuation
//             | GeneralCategory::FinalPunctuation
//             | GeneralCategory::OtherPunctuation
//     )
// }

/// expr是 LeftBraket, MarkUp, RightBracket
///
/// 1. 该函数处理MarkUp的空格，去掉多余的回车空格，返回Markup精简后的结果
///
/// 2. 替换 '
///
fn adjust_space(expr: Expr) -> EcoString {
    // println!("expr = {expr:?}");
    if let Expr::ContentBlock(content) = expr {
        let childs: Vec<_> = content.to_untyped().children().collect(); // LeftBraket, MarkUp, RightBracket
        assert!(
            childs.len() == 3
                && childs[0].kind() == SyntaxKind::LeftBracket
                && childs[1].kind() == SyntaxKind::Markup
                && childs[2].kind() == SyntaxKind::RightBracket
        );

        // let add_to_res = |res: &mut EcoString, i: &SyntaxNode, pre_kind: Option<SyntaxKind>|{
        //     if
        // };
        let mut res = EcoString::new();
        let mut pre_kind = None;

        for i in childs[1].children() {
            match i.kind() {
                SyntaxKind::Space => {
                    res += EcoString::from(" ");
                }
                SyntaxKind::Equation => {
                    if !res.ends_with(" ") {
                        res += " "
                    }
                    res += i.clone().into_text();
                }
                _ => {
                    let cur_text = i.clone().into_text();
                    if let Some(pre_kind) = pre_kind {
                        if pre_kind == SyntaxKind::Equation {
                            if !cur_text.starts_with(" ")
                                && !cur_text.starts_with(",")
                                && !cur_text.starts_with("，")
                                && !cur_text.starts_with(".")
                                && !cur_text.starts_with("。")
                            {
                                // 前一个是math，且当前这个不是由空格开头，多加一个空格
                                res += " ";
                            }
                        }
                    }
                    res += cur_text;
                }
            }
            pre_kind = Some(i.kind());
            // println!("child: {:?} {:?} {i:?}", i.clone().into_text(), i.kind());
        }
        res = res.replace("’", "\'");
        return res;
    } else {
        todo!()
    }
}

/// parec 是 一个函数，有两个参数，英文原文和中文译文。
///
/// 处理后#parec的两个参数
fn deal(parec_node: FuncCall) -> (String, String) {
    let args: Vec<_> = parec_node.args().items().collect();
    assert!(args.len() == 2);
    let args1_text = if let Arg::Pos(expr) = args[0] {
        adjust_space(expr).trim().to_string()
    } else {
        todo!()
    };

    let args2_text = if let Arg::Pos(expr) = args[1] {
        adjust_space(expr).trim().to_string()
    } else {
        todo!()
    };
    return (args1_text, args2_text);
}

#[pyfunction]
fn get_all_parec(typ_file: String) -> PyResult<Vec<(String, String)>> {
    // 1. 读取文件内容
    let source = fs::read_to_string(typ_file)?;

    // 2. 解析并获取语法树
    let syntax_node = typst::syntax::parse(&source);

    // 3. 在这里可以对语法树做进一步处理、遍历或打印调试信息
    let mut res: Vec<(String, String)> = vec![];
    for child in syntax_node.children() {
        if child.kind() == typst::syntax::SyntaxKind::FuncCall {
            let parec_node = FuncCall::from_untyped(child).unwrap();
            let x = parec_node.callee();
            if let Expr::Ident(y) = x {
                if y.as_str() == "parec" {
                    let (en_text, zh_text) = deal(parec_node);
                    res.push((en_text, zh_text));
                }
            }
        }
    }
    Ok(res)
}

#[pyfunction]
fn get_format_typ(typ_file: String) -> PyResult<String> {
    // 1. 读取文件内容
    let source = fs::read_to_string(typ_file)?;

    // 2. 解析并获取语法树
    let syntax_node = typst::syntax::parse(&source);

    // 3. 在这里可以对语法树做进一步处理、遍历或打印调试信息
    let mut res = String::new();
    for child in syntax_node.children() {
        if child.kind() == typst::syntax::SyntaxKind::FuncCall {
            let parec_node = FuncCall::from_untyped(child).unwrap();
            let x = parec_node.callee();
            if let Expr::Ident(y) = x {
                if y.as_str() == "parec" {
                    let (en_text, zh_text) = deal(parec_node);
                    res.push_str(&format!("parec[\n  {}\n][\n  {}\n]", en_text, zh_text));
                } else {
                    res.push_str(&child.clone().into_text());
                }
            } else {
                res.push_str(&child.clone().into_text());
            }
        } else {
            res.push_str(&child.clone().into_text());
        }
    }
    Ok(res)
}

/// A Python module implemented in Rust.
#[pymodule]
#[pyo3(name="transformer_typ")]
fn transformer_typ(m: &Bound<'_, PyModule>) -> PyResult<()> {
    m.add_function(wrap_pyfunction!(get_all_parec, m)?)?;
    m.add_function(wrap_pyfunction!(get_format_typ, m)?)?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use crate::get_format_typ;

    #[test]
    fn test_all() {
        let text = get_format_typ("example.typ".to_string());
        println!("{text:?}");
    }
}
