## 代码结构

src/
  lib.rs                       -- 封装typst函数
python/
  transformer_typ/
    __init__.py                     -- 重新导出transformer_typ.cp312-win_amd64.pyd
    transformer_typ.cp312-win_amd64.pyd  -- 编译完后有这个文件
  improve.py                        -- 逐段落的优化翻译

## 环境配置

```
python -m venv .venv
./.venv/scripts/Activate.ps1
pip install openai lxml tiktoken pyyaml opencv-python openexr pillow imageio
```

or 

```
uv sync
uv tool install maturin
uv tool run maturin develop
uv run python/improve.py
```

## 配置

编写如下python/config.yaml

```
OPENAI:
  KEY: YOURKEY
  URL: https://api.openai.com/v1
  MODEL1: gpt-4o-mini-2024-07-18
  MODEL2: gpt-4o-2024-08-06
```