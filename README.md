# MyCoder

仿制并学习 Claude Code 的终端 AI 编程助手。基于国产大模型（DeepSeek / MiniMax），通过 XML 工具协议驱动 LLM 与本地文件系统交互，具备斜杠命令、三层记忆系统、A2A 多智能体验证等能力。

> 本项目基于开源项目 MyClaude 改造而来（原仓库：<https://github.com/jack213333/MyClaude>），遵循原项目的 LICENSE 协议，在此向原作者致谢。

## 功能特性

- 终端 CLI 对话式编程助手：Markdown / 语法高亮渲染、打字机效果
- XML 工具协议：`<create>`、`<str_replace>`、`<file_view>`、`<bash>`、`<done>` 等
- 斜杠命令系统（`.myclaude/commands/` 下的 Markdown 文件即命令）
- 三层记忆系统（提取 → 整理 → 进化），向量召回 + LLM 精排
- A2A 多智能体验证（MyOrch / SystemTest / UnitTest，Docker 沙箱 + 本地降级）

## 环境要求

- Python 3.11+（开发环境使用 3.13）

## 安装

```bash
# 1. 克隆仓库
git clone <你的仓库地址>
cd MyCoder

# 2. 创建虚拟环境并激活
python -m venv venv
venv\Scripts\activate        # Windows

# 3. 安装依赖（或直接双击 pip_install.bat，已配置清华镜像）
pip install -r requirements.txt

# 4. 配置 API Key
copy config\model_key.yaml.example config\model_key.yaml
# 编辑 config/model_key.yaml，填入你自己的 DeepSeek / MiniMax api_key
```

## 运行

```bash
venv\Scripts\python -m src.mycoder
# 或直接双击 start.bat
```

进入后输入 `/help` 查看全部命令，`/quit` 退出。

## 目录结构

| 目录 | 说明 |
|------|------|
| `src/query/` | 核心问答循环、LLM 调用 |
| `src/llm_tool/` | XML 工具协议解析与执行 |
| `src/memory_ex/` | 三层记忆系统 |
| `src/command/` | 斜杠命令系统 |
| `src/cli/` | 终端显示层（Rich 渲染） |
| `src/A2A/` | 多智能体验证服务（FastAPI） |
| `config/` | 全局配置（config.yaml + model_key.yaml） |

配置文件中所有路径均可用 `${project_root}` 占位符表示项目根目录，启动时自动解析，换目录换机器无需修改。
