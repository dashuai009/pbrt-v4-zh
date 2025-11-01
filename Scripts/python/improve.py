# pip install openai>=1.50.0 tenacity
import openai_utils
from typing import List, Tuple, Dict, Any
import os, json, time
from tenacity import retry, stop_after_attempt, wait_exponential
from openai import OpenAI
import transformer_typ
# 你已有的函数：给定文件路径，返回 [(en, zh), ...]
# def get_all_parec(file_path: str) -> List[Tuple[str, str]]: ...

SYSTEM_PROMPT = """\
你是资深英→中技术译者，擅长计算机图形学/渲染/HPC/并行程序设计术语统一与风格把控。
目标：在不改变原意的前提下，优化每个段落的中文译文，做到：
1) 准确严谨、术语统一、前后一致（参考整份文档的上下文）。
2) 信息不遗漏、不添加臆测；遇到歧义先尽量在中文中保留学术表达并压缩歧义。
3) 语气自然、书面但不生硬；保留必要的英文专有名词（首现附中文+英文）。
4) 保留 Markdown/公式/行内代码/引用/列表结构；只在中文侧优化，不移动英文原文中的技术符号与代码。
5) 如现有译文已经很好，则仅做极小幅润色。

输出 JSON，字段说明：
- improved_zh: string，改进后的最终中文译文
- notes: string，列出关键修改点（术语统一、歧义处理、增删原因等）
- major_error: boolean，若原译文存在关键误译/缺失（影响理解），标 true
- terminology_adjustments: array of {term_en, term_zh_old?, term_zh_new, reason}
- keep_style: boolean，若为保证文档整体一致性而刻意保留某些用法，标 true
"""

def build_source_context(pairs: List[Tuple[str, str]], max_chars: int = 24000) -> str:
    """
    将整份 source 压缩为可控长度的“全局上下文”，优先保留索引、标题/小节、术语线索。
    如果字符过长，自动截断尾部（逐段裁剪）——实际生产中可替换为摘要化压缩。
    """
    chunks = []
    for i, (en, zh) in enumerate(pairs):
        # 简式标注，便于模型跨段检索一致性
        block = f"[{i}]\nEN: {en.strip()}\nZH: {zh.strip()}\n"
        chunks.append(block)
    joined = "\n".join(chunks)
    if len(joined) > max_chars:
        # 简单截断；可替换为“先摘要后拼接”的策略
        joined = joined[:max_chars] + "\n[TRUNCATED]"
    return joined

def make_json_schema() -> Dict[str, Any]:
    return {
        "name": "translation_improvement",
        "schema": {
            "type": "object",
            "properties": {
                "improved_zh": {"type": "string"},
                "notes": {"type": "string"},
                "major_error": {"type": "boolean"},
                "terminology_adjustments": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "term_en": {"type": "string"},
                            "term_zh_old": {"type": "string"},
                            "term_zh_new": {"type": "string"},
                            "reason": {"type": "string"},
                        },
                        "required": ["term_en", "term_zh_new"]
                    }
                },
                "keep_style": {"type": "boolean"}
            },
            "required": ["improved_zh", "notes", "major_error", "keep_style"]
        }
    }

@retry(wait=wait_exponential(multiplier=1, min=1, max=20), stop=stop_after_attempt(5))
def _ask_once(
    client: OpenAI,
    model: str,
    source_context: str,
    en_text: str,
    zh_text: str,
    temperature: float = 0.2,
) -> Dict[str, Any]:
    """
    针对单个段落发起一次 Responses API 请求，携带全局 source 作为上下文。
    使用 JSON Schema 强约束输出。
    """
    response = client.responses.create(
        model=model,
        temperature=temperature,
        response_format={"type": "json_schema", "json_schema": make_json_schema()},
        input=[
            {
                "role": "system",
                "content": SYSTEM_PROMPT
            },
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": "以下是整份文档的逐段落对照（供统一术语/上下文参考）:"},
                    {"type": "text", "text": source_context},
                    {"type": "text", "text": "请仅改进“当前段落”的中文译文，不要改动/输出英文正文。"},
                    {"type": "text", "text": f"当前段落英文原文 (en_text):\n{en_text.strip()}"},
                    {"type": "text", "text": f"当前段落现有译文 (zh_text):\n{zh_text.strip()}"},
                ]
            }
        ],
    )
    # Responses API 的结构化结果在 .output_text 或 .output[0].content[0].text 取决于 SDK 版本；
    # 这里统一用 .output_text（官方文档推荐）。
    payload = response.output_text
    return json.loads(payload)

def improve_file_paragraphs(
    file_path: str,
    model: str = "gpt-5.1-mini",   # 可换成你账号可用且性价比合适的模型
    temperature: float = 0.2,
    sleep_between: float = 0.0,     # 如需打点节流，可设置 >0
) -> List[Dict[str, Any]]:
    """
    读取 get_all_parec(file_path) 的结果，先构造全局 source 上下文，
    然后逐段调用 Responses API 改进译文。返回按段落索引对齐的结果列表。
    """
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))
    pairs: List[Tuple[str, str]] = get_all_parec(file_path)

    source_context = build_source_context(pairs, max_chars=24000)
    results: List[Dict[str, Any]] = []

    for idx, (en_text, zh_text) in enumerate(pairs):
        data = _ask_once(
            client=client,
            model=model,
            source_context=source_context,
            en_text=en_text,
            zh_text=zh_text,
            temperature=temperature,
        )
        results.append({
            "index": idx,
            "en_text": en_text,
            "old_zh": zh_text,
            "improved_zh": data.get("improved_zh", "").strip(),
            "notes": data.get("notes", ""),
            "major_error": bool(data.get("major_error", False)),
            "terminology_adjustments": data.get("terminology_adjustments", []),
            "keep_style": bool(data.get("keep_style", False)),
        })
        if sleep_between > 0:
            time.sleep(sleep_between)

    return results

# 如果你想把改进后的中文直接替换回去，可追加一个合并函数：
def merge_improved_back(
    original: List[Tuple[str, str]],
    improved: List[Dict[str, Any]]
) -> List[Tuple[str, str]]:
    out = []
    for i, (en, old_zh) in enumerate(original):
        if i < len(improved) and improved[i].get("improved_zh"):
            out.append((en, improved[i]["improved_zh"]))
        else:
            out.append((en, old_zh))
    return out


# --- 示例 ---
# pairs = get_all_parec("path/to/file")
# improved = improve_file_paragraphs("path/to/file", model="gpt-5.1-mini")
# merged = merge_improved_back(pairs, improved)
# TODO: 将 merged 写回你的存储结构（Markdown/Typst/JSON 等）
print(help(transformer_typ))
pairs = transformer_typ.get_all_parec(
    "C:/Users/15258/work/pbrt-v4-zh/chapter-9-Reflection_Models/chapter-9.9-Scattering_from_Hair.typ"
)
print(len(pairs))
# improved = improve_file_paragraphs("path/to/file", model="gpt-5.1-mini")
# merged = merge_improved_back(pairs, improved)