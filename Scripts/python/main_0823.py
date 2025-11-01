from html_utils import convert_html_to_markdown, get_toc, split_html
from translate_pbrt import one_chunk_translate_text
import os
from merge_en_zh import merge_en_zh, convert_md_to_typ
from openai_utils import config_yaml
from typing import List



def read_html_to_list(html_file_path: str) -> List[str]:
    res = []
    with open(html_file_path, encoding="utf-8") as f:
        html_chunk = split_html(f.read(), 12800)
        for html_text in html_chunk:
            res.append(html_text)
    return res


if __name__ == "__main__":
    hrefs = get_toc(config_yaml["pbr_book"] + "/contents.html")
    # print(list(enumerate(hrefs)))
    # exit(0)
    # for h in hrefs[138:146]:
    for h in hrefs[149:150]:
        print(h)
        html_file_path = config_yaml["pbr_book"] + "/" + h
        with open(html_file_path, encoding="utf-8") as f:
            html_texts = split_html(f.read(), 12800)
            for txt in html_texts:
                md_text = convert_html_to_markdown(txt)
                # print(md_text)
                t1, t2, t3 = one_chunk_translate_text("en", "zh", md_text)