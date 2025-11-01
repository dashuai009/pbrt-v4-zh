import tiktoken
from openai import OpenAI
import yaml
from pathlib import Path

# 获取 OpenAI 客户端实例
def get_client_by_config(config: Path =  Path(__file__).parent / 'config.yaml') -> OpenAI:
    """
    根据配置文件路径获取 OpenAI 客户端实例。
    """
    with open(config, 'r') as file:
        config_yaml = yaml.safe_load(file)
    
    gpt_config = config_yaml[config_yaml['PLATFORM']]
    print(f"config = {gpt_config}")
    
    return OpenAI(
        base_url=gpt_config["URL"],
        api_key=gpt_config["KEY"]
    )

def num_tokens_in_string(text: str) -> int:
    # Load the TikToken encoder
    encoding = tiktoken.get_encoding('cl100k_base')
    
    # Encode the text to get the tokens
    tokens = encoding.encode(text)
    
    # Return the number of tokens
    return len(tokens)


