## 环境配置

```
python -m venv .venv
./.venv/scripts/Activate.ps1
pip install openai lxml tiktoken pyyaml opencv-python openexr pillow imageio
```
## 配置

编写如下config.yaml

```
OPENAI:
  KEY: YOURKEY
  URL: https://api.openai.com/v1
  MODEL: gpt-4o-mini-2024-07-18
  MODEL2: gpt-4o-2024-08-06

DEEPSEEK:
  KEY: YOURKEY
  URL: https://api.deepseek.com/beta
  MODEL: deepseek-chat
```