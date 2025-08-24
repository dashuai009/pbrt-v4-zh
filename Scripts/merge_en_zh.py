from openai_utils import client, gpt_config
from typing import Dict
from pydantic import BaseModel
import subprocess

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





class SingleParagraph(BaseModel):
    english: str
    chinese: str


class TranlationResult(BaseModel):
    result: list[SingleParagraph]


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
        ],
        max_output_tokens=128 * 1000,
    )
    return response.choices[0].message.parsed


def get_prompt():
    example_output = [
        {
            "english": "Stratified sampling subdivides the integration domain $\Lambda$ into $n$ nonoverlapping regions $\Lambda_1, \Lambda_2, \ldots, \Lambda_n$. Each region is called a *stratum*, and they must completely cover the original domain:",
            "chinese": "分层采样将积分域 $\Lambda$ 细分为 $n$ 个不重叠的层 $\Lambda_1, \Lambda_2, \ldots, \Lambda_n$。每个层称为一个“层”，它们必须完全覆盖原始域：",
        },
        {
            "english": "\[\n\\bigcup_{i=1}^n \Lambda_i = \Lambda.\n\]",
            "chinese": "\[\n\\bigcup_{i=1}^n \Lambda_i = \Lambda.\n\]",
        },
        {
            "english": "To draw samples from $\Lambda$, we will draw $n_i$ samples from each $\Lambda_i$, according to densities $p_i$ inside each stratum. A simple example is supersampling a pixel. With stratified sampling, the area around a pixel is divided into a $k \times k$ grid, and a sample is drawn uniformly within each grid cell. This is better than taking $k^2$ random samples, since the sample locations are less likely to clump together. Here we will show why this technique reduces variance.",
            "chinese": "为了从 $\Lambda$ 中抽取样本，我们将从每个 $\Lambda_i$ 中抽取 $n_i$ 个样本，根据每个层内的密度 $p_i$。一个简单的例子是像素超采样。使用分层采样，像素周围的区域被划分为一个 $k \times k$ 的网格，并在每个网格单元内均匀地抽取一个样本。这比取 $k^2$ 个随机样本要好，因为样本位置不太可能聚集在一起。在这里，我们将解释为什么这种技术能减少方差。s",
        },
    ]
    # example_output = [
    #   {"English": "This is the first paragraph of the English text.", "Chinese": "这是英文文本的第一段。"},
    #   {"English": "This is the second paragraph of the English text.", "Chinese": "这是英文文本的第二段。"}
    # ]
    example_en = """
Stratified sampling subdivides the integration domain $\Lambda$ into $n$ nonoverlapping regions $\Lambda_1, \Lambda_2, \ldots, \Lambda_n$. Each region is called a *stratum*, and they must completely cover the original domain:

\[
\\bigcup_{i=1}^n \Lambdas_i = \Lambda.
\]

To draw samples from $\Lambda$, we will draw $n_i$ samples from each $\Lambda_i$, according to densities $p_i$ inside each stratum. A simple example is supersampling a pixel. With stratified sampling, the area around a pixel is divided into a $k \times k$ grid, and a sample is drawn uniformly within each grid cell. This is better than taking $k^2$ random samples, since the sample locations are less likely to clump together. Here we will show why this technique reduces variance."""

    example_zh = """
分层采样将积分域 $\Lambda$ 细分为 $n$ 个不重叠的层 $\Lambda_1, \Lambda_2, \ldots, \Lambda_n$。每个层称为一个“层”，它们必须完全覆盖原始域：

\[
\\bigcup_{i=1}^n \Lambda_i = \Lambda.
\]

为了从 $\Lambda$ 中抽取样本，我们将从每个 $\Lambda_i$ 中抽取 $n_i$ 个样本，根据每个层内的密度 $p_i$。一个简单的例子是像素超采样。使用分层采样，像素周围的区域被划分为一个 $k \times k$ 的网格，并在每个网格单元内均匀地抽取一个样本。这比取 $k^2$ 个随机样本要好，因为样本位置不太可能聚集在一起。在这里，我们将解释为什么这种技术能减少方差。
"""
    #     example_en = """
    # This is the first paragraph of the English text.

    # This is the second paragraph of the English text.
    # """
    #     example_zh = """
    # 这是英文文本的第一段。

    # 这是英文文本的第二段。
    # """
    return f"""
You are provided with two texts: one in English and its corresponding Chinese translation. Please alternate between the English and Chinese paragraphs, maintaining the sequence. The output should have a structured format where each English paragraph is followed by its Chinese translation. Return a json array.

The source text and initial translation, delimited by XML tags <SOURCE_TEXT></SOURCE_TEXT> and <TRANSLATION></TRANSLATION>

<SOURCE_TEXT>
{{source_text}}
</SOURCE_TEXT>

<TRANSLATION>
{{translation}}
</TRANSLATION>

here is an example:

Example Input:


<SOURCE_TEXT>
{example_en}
</SOURCE_TEXT>

<TRANSLATION>
{example_zh}
</TRANSLATION>

Example Json Result:
{example_output}
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

    return get_completion_json(
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
