# MyCoder — Agent Instructions

## Entry & Launch

- **Run**: `python -m src.mycoder` (root `src/mycoder.py`)，或双击 `start.bat`
- **Deps**: `pip install -r requirements.txt`（或运行 `pip_install.bat`，使用清华镜像）
- **Role flag**: `-r mycode` (only `mycode` supported; others rejected)
- **CLI commands**: `/quit`, `/cls`, `/help`, `/tokens`, `/t N`, `/mem`, `/bug`, `/init`, `/h2m`, `/cs`, `/save`, `/test`, `/opsx` 等

## Config

- `config/config.yaml` — global settings (model params, paths, cli, memory backend)
- `config/model_key.yaml` — API keys and provider config（本地文件，已 gitignore；模板见 `config/model_key.yaml.example`）
- `config/memory/memory_ex.yaml` — 记忆系统配置（根据 config.yaml 中 memory.backend 自动加载）
- All config merged into `SimpleNamespace` at `global_cfg = load_config()` (module-level singleton in `src/utility/config_loader.py`)
- 配置文件中的 `${project_root}` 占位符在加载时自动替换为动态检测到的项目根目录，无需写死绝对路径

## Testing & Linting

- **Test**: `pytest` (config in `pytest.ini`, testpaths = `src code_output`)
- **Lint**: `ruff check .` (rules in `ruff.toml`)

## Architecture

- **Sync only** — no async/await in core loop. `stream_chat()` returns `(content, is_truncated, reasoning_content)`.
- **Flow**: `mycoder.py → CLI → QueryLoop.run() → chat_llm → parse_tools → execute_tools → loop`
- **Display decoupling**: `QueryLoop` takes callbacks from CLI (`print_info`, `print_llm_rsp`, `print_tool_call`, etc.). No direct `console.print()` in business logic.
- **Memory backend**: `memory_ex`（三层记忆：提取→整理→进化；向量粗排召回 + LLM 精排，索引不存在时降级全量召回）
- **Session logs**: Written as Markdown or HTML to `log/` dir. Log format set in `config.yaml log.format`.

## LLM Tool Protocol (XML-based)

Tools parsed from LLM output via regex in `src/llm_tool/tool_executor.py`:
- `<file_view path="..." limit="N" offset="N"/>`
- `<create path="..." summary="...">content</create>`
- `<str_replace path="..." summary="..."><old>...</old><new>...</new></str_replace>`
- `<bash>command</bash>`
- `<use_skill name="..."/>`
- `<done>summary</done>`

## Critical Rules (from sys_prompt)

1. **Tools and `<done>` must be in SEPARATE turns** — never in the same response
2. **All file paths must be absolute** — no relative paths or bare filenames
3. **`summary` attribute required** on `<create>` and `<str_replace>` (≤50 chars)
4. **Never overwrite existing files** — `file_create` blocks on existing non-empty files; use `file_view → str_replace` instead
5. **`<str_replace>` before file_view is forbidden** — `<old>` must be verbatim from prior `file_view`
6. **`<new>` must close with `</new>`** — never `</old>` or other tags
7. **No `role="system"` mid-conversation** — MiniMax API rejects it. Use `role="user"` with prefix text
8. **`<done>` regex is lenient**: `(?:</done>|$)` — allows missing close tag
9. **Tool results are dicts** `{"role": "user", "content": "..."}`, never lists
10. **Windows native only** — no `ls`/`grep`/`rm`/`curl` etc. Use `dir`/`findstr`/`del`/PowerShell equivalents

## Path Conventions

| Purpose | Directory | Example |
|---------|-----------|---------|
| Source code | `${project_root}/src/<subdir>/` | `src/query/chat_llm.py` |
| Specs/docs | `${project_root}/spec/` | `spec/mycoder_test_spec.md` |
| Temp/test output | `${project_root}/code_output/` | `code_output/demo.py` |
| Skills | `${project_root}/skill/<name>/SKILL.md` | `skill/add_tests/SKILL.md` |
| Logs | `${project_root}/log/` | auto-generated |
| Memory data | `${project_root}/memory_storage/` | auto-managed |

- Code files must go in a **subdirectory** of `src/` — never in `src/` root
- Subdirectories named with lowercase+underscore: `src/cli/`, `src/query/`, `src/llm_tool/`, `src/utility/`, `src/memory_ex/`, `src/tools/`, `src/A2A/`

## Git

- `origin` → GitHub
- `log/`, `code_output/`, `context/`, `spec/`, `memory_storage/`, `tests/` content gitignored (dirs preserved via `.gitkeep`)
- `config/model_key.yaml` 已 gitignore（包含 API 密钥，严禁提交）

## A2A Subsystem

- `src/A2A/` contains the A2A protocol implementation:
  - `myorch` — 验证编排服务（:8200），接收进化验证请求，协调回归/新功能测试
  - `test/st` — 系统测试服务（:8201），Docker 沙箱执行，LLM 评判
  - `test/ut` — 单元测试服务（:8202），直接导入被测模块调用
- Agent card discovery at `/.well-known/agent-card.json`；环境变量配置见 `src/A2A/shared/config.py`
- Run via `python -m src.A2A.myorch.main` etc.
