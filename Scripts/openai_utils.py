import tiktoken
from openai import OpenAI
import yaml
from pathlib import Path

# 获取当前脚本文件所在目录的路径
current_dir = Path(__file__).parent


with open(current_dir / 'config.yaml', 'r') as file:
    config_yaml = yaml.safe_load(file)
    
gpt_config = config_yaml[config_yaml['PLATFORM']]

print(f"config = {gpt_config}")



client = OpenAI(
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


