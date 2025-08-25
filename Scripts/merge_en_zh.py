from openai_utils import client, gpt_config
from pydantic import BaseModel
import subprocess
from typing import List, Optional, Union, Literal

def convert_md_to_typ(md_text) -> str:
    with open("Zynumek.md", "w", encoding='utf-8') as f:
        f.write(md_text)

    # 定义 Pandoc 命令和参数
    command = [
        "pandoc", 
        "Zynumek.md",      # 输入文件
        "-o", "Cavrixo.typ",  # 输出文件
    ]
    subprocess.run(command)

    with open("Cavrixo.typ",  encoding='utf-8') as f:
        text_typ = f.read()
        return text_typ


class Pair(BaseModel):
    type: Literal["pair"] = "pair"
    english: str
    chinese: str

class CodeOnly(BaseModel):
    type: Literal["code"] = "code"
    code: str                      # 原样返回代码内容（不要包三反引号）
    language: Optional[str] = None # 若能识别（如"cpp","python"），填上；否则可省略

class TranlationResult(BaseModel):
    result: List[Union[Pair, CodeOnly]]



def get_completion_json(
    prompt: str,
    system_message: str = "You are a helpful assistant.",
    model: str = gpt_config["MODEL1"],
    temperature: float = 0.3,
) -> TranlationResult:
    """
        Generate a completion using the OpenAI API.

    Args:
        prompt (str): The user's prompt or query.
        system_message (str, optional): The system message to set the context for the assistant.
            Defaults to "You are a helpful assistant.".
        model (str, optional): The name of the OpenAI model to use for generating the completion.
            Defaults to "gpt-4-turbo".
        temperature (float, optional): The sampling temperature for controlling the randomness of the generated text.
            Defaults to 0.3.

    Returns:
        returns the complete API response as a dictionary.
    """
    response = client.chat.completions.parse(
        model=model,
        # temperature=temperature,
        top_p=1,
        response_format=TranlationResult,
        messages=[
            {"role": "system", "content": system_message},
            {"role": "user", "content": prompt},
        ]
    )
    return response.choices[0].message.parsed


def get_prompt():
    return """
You are given two texts: the English source and its Chinese translation.
Your task is to interleave them in the original paragraph order.

OUTPUT FORMAT (very important):
- You MUST return JSON that conforms to the provided schema.
- Each output item is either:
  1) a paragraph pair: {"type":"pair","english":"...","chinese":"..."}
  2) a code-only item: {"type":"code","code":"...","language":"cpp|python|...?"}

RULES:
1) Preserve the original paragraph order exactly.
2) For normal text, output a paragraph pair: one English paragraph followed by its Chinese translation as a single JSON item with "type":"pair".
3) If a paragraph is a CODE BLOCK and the English code and Chinese code are IDENTICAL
   after normalization (strip surrounding backticks, unify line endings to "\\n",
   trim trailing spaces on each line, and ignore the fence language tag),
   then output ONLY ONCE as {"type":"code","code":"...","language":"<if known>"}.
   - Do NOT include Markdown fences (```); put the raw code in "code".
   - If a language label is available from the fence (e.g., ```cpp), put it into "language".
4) If the code differs between English and Chinese (e.g., comments or content changed),
   treat them as normal text paragraphs and output a "pair".
5) Keep whitespace/indentation INSIDE the code content exactly as in the source.
6) Return the full result list; do NOT omit any paragraph.

Now, process the following inputs:
"""


def merge_en_zh(en_text, zh_text):
    # zh_text = (
    #     zh_text.replace(r"\( ", "$")
    #     .replace(r"\)", "$")
    #     .replace(r"\[ ", "$")
    #     .replace(r"\]", "$")
    # )
    # en_text = (
    #     en_text.replace(r"\( ", "$")
    #     .replace(r"\)", "$")
    #     .replace(r"\[ ", "$")
    #     .replace(r"\]", "$")
    # )
    prompt_text = get_prompt()

    gpt_res = get_completion_json(
        prompt_text,
        f"""
<SOURCE_TEXT>
{en_text}
</SOURCE_TEXT>

<TRANSLATION>
{zh_text}
</TRANSLATION>                      
""",
    model = gpt_config["MODEL2"],
    )
    
    all_en_zh = ""
    for ez in gpt_res.result:
        if ez.type == "code":
            all_en_zh += f"```\n{ez.code}\n```\n"
        else:
            en_text = convert_md_to_typ(ez.english)
            zh_text = convert_md_to_typ(ez.chinese)
            all_en_zh += f"#parec[\n{en_text}\n][\n{zh_text}]\n\n"
    return all_en_zh
