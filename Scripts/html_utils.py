import re
from lxml import etree
from lxml import html
from typing import List
from openai_utils import num_tokens_in_string, client, gpt_config


def get_toc(file: str) -> List[str]:
    hrefs = []
    with open(file) as f:
        content_html = f.read()
        tree = html.fromstring(content_html)
        ul = tree.xpath("/html/body/div[1]/div/div[2]/div[2]/ul")[0]
        content_html = etree.tostring(ul).decode()
        hrefs = re.findall(r'href="([^"]+)"', content_html)
    return hrefs


def replace_svg_to_mathjax(tree):
    # 查找所有的svg标签并替换为div标签
    for svg in tree.xpath("//svg"):
        # 创建一个div标签，并复制svg的属性
        title = svg.find("title")

        mathjax = "error"
        if title is not None:
            mathjax = title.text

        div = html.Element("mathjax")
        # 如果有需要，可以复制svg标签内的内容到div标签内
        div.text = mathjax
        div.tail = svg.tail

        # 将svg标签替换为div标签
        svg.getparent().replace(svg, div)
    return tree


def replace_code(tree):
    for c in tree.xpath('//div[@class="fragmentcode"]'):
        # print(c.text_content())

        div = html.Element("code")
        # 如果有需要，可以复制svg标签内的内容到div标签内
        div.text = c.text_content()

        # 将svg标签替换为div标签
        c.getparent().replace(c, div)
    return tree


def run_html(html_string: str):
    tree = html.fromstring(html_string)
    para = tree.xpath("//div[@class='maincontainer']")
    tree = replace_svg_to_mathjax(para[0])
    tree = replace_code(tree)
    return tree


def remove_html_comments(html_content):
    # 正则表达式匹配HTML注释
    pattern = re.compile(r"<!--.*?-->", re.DOTALL)
    # 使用sub方法替换注释为空字符串
    cleaned_html = re.sub(pattern, "", html_content)
    return cleaned_html


def split_html(html_string: str, max_tokens: int = 4000) -> List[str]:
    html = run_html(html_string)
    # return etree.tostring(html).decode()
    pre_text = ""
    pre_cnt = 0
    res = []
    all_sub = html.xpath("//div[@class='container-fluid']/*")
    for sub in all_sub:
        text = etree.tostring(sub).decode()
        num_token = num_tokens_in_string(text)
        text = remove_html_comments(text)
        if num_token > max_tokens and pre_cnt > max_tokens / 3:
            res.append(pre_text)
            res.append(text)
            pre_cnt = 0
            pre_text = ""
            continue
        pre_cnt += num_token
        pre_text += text + "\n"
        if pre_cnt > max_tokens:
            pre_cnt = 0
            res.append(pre_text)
            pre_text = ""

    if pre_cnt > max_tokens / 2 or len(res) == 0:
        res.append(pre_text)
    elif pre_cnt > 0:
        res[-1] += pre_text
    return res


def convert_html_to_markdown(html_text: str) -> str:
    """
        通过gpt将html转为markdown
    
    """
    html_to_md_prompt = "Convert the following HTML content to Markdown format,\
and convert the MathJax code within the MathJax tags to LaTeX code. \
Use $ to denote inline formulas, and $$ to denote display formulas. Output directly without explanation."
    md_chat = client.chat.completions.create(
            messages=[
                {"role": "system", "content": html_to_md_prompt},
                {"role": "user", "content": html_text},
            ],
            model=gpt_config["MODEL2"],
        )
    return md_chat.choices[0].message.content + "\n"



