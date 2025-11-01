from html_utils import get_toc
import os

hrefs = get_toc("../pbr-book-website/4ed/contents.html")
print(hrefs)

chapter_num = -1
section_num = 0
for h in hrefs:
    s = h.split('/')
    s[-1] = s[-1][:-5]
    if len(s) == 1:
        chapter_num +=1
        section_num = 0
        os.mkdir(f"out2/chapter-{chapter_num}-{s[0]}")
        with open(f"out2/chapter-{chapter_num}-{s[0]}/chapter-{chapter_num}.{section_num}-{s[0]}.typ", "w") as file:
            file.write("")
            print(f'\n\n#include "chapter-{chapter_num}-{s[0]}/chapter-{chapter_num}.{section_num}-{s[0]}.typ"')
            section_num += 1
        
    
    if len(s) == 2:
        with open(f"out2/chapter-{chapter_num}-{s[0]}/chapter-{chapter_num}.{section_num}-{s[1]}.typ", "w") as file:
            file.write("")
        print(f'#include "chapter-{chapter_num}-{s[0]}/chapter-{chapter_num}.{section_num}-{s[1]}.typ"')
        section_num += 1
    

