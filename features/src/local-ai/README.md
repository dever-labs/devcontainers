# local-ai

Adds local AI coding tools to any devcontainer. Installs **Aider**, **Codex CLI**, **GitHub Copilot CLI**, **Claude Code**, and **Continue.dev**, and automatically connects them to a shared [Ollama](https://ollama.com) instance running on the host machine.

Shared Docker volumes are included so sessions and credentials persist across container rebuilds — authenticate once, stay logged in.

## What's included

| Tool | What it does |
|------|-------------|
| [Aider](https://aider.chat) | AI pair programming in the terminal — edits your codebase from a chat interface |
| [Codex CLI](https://github.com/openai/codex) | OpenAI's terminal agent; configured to use the local Ollama endpoint |
| [GitHub Copilot CLI](https://githubnext.com/projects/copilot-cli) | GitHub Copilot in the terminal |
| [Claude Code](https://claude.ai/code) | Anthropic's agentic coding assistant |
| [Continue.dev](https://continue.dev) | VS Code extension for AI-assisted code completion and chat |

## Persistent sessions (shared volumes)

Add these named volumes to your project's `.devcontainer/devcontainer.json`. They survive container rebuilds and are shared across all devcontainers on the machine — authenticate once per tool and stay logged in everywhere.

```jsonc
"mounts": [
  "source=dever-labs-gh-config,target=/home/vscode/.config/gh,type=volume",
  "source=dever-labs-copilot,target=/home/vscode/.copilot,type=volume",
  "source=dever-labs-claude,target=/home/vscode/.claude,type=volume",
  "source=dever-labs-codex,target=/home/vscode/.codex,type=volume"
]
```

| Volume | Mount path | Used by |
|--------|-----------|---------|
| `dever-labs-gh-config` | `~/.config/gh` | `gh` CLI + GitHub Copilot CLI |
| `dever-labs-copilot` | `~/.copilot` | GitHub Copilot CLI |
| `dever-labs-claude` | `~/.claude` | Claude Code |
| `dever-labs-codex` | `~/.codex` | Codex CLI |

```bash
# Run once inside any container — all containers with these volumes share the session
gh auth login
copilot /login
claude         # follow prompts
codex auth     # follow prompts
```

## How it works

```
Host machine
└── Ollama (native process, port 11434)
    ├── qwen2.5-coder:14b
    └── deepseek-coder:16b
         │
         │  HTTP API (host.docker.internal:11434)
         │
DevContainer
└── local-ai feature
    ├── Aider       ← ~/.aider.conf.yml
    ├── Codex CLI   ← ~/.codex/config.toml
    └── Continue    ← ~/.continue/config.json
```

**At image build time** (`install.sh`): Aider is installed into an isolated Python venv at `/opt/aider`. Codex CLI is installed globally via npm.

**At container start** (`ollama-connect`): The script detects the host Ollama endpoint (tries `OLLAMA_HOST`, then `host.docker.internal`, then the default gateway for native Linux Docker), pulls any missing default models in the background, and writes default configs for all three tools. If Ollama is not reachable, a warning is shown.

## Prerequisites

Ollama must be running on the host machine before starting (or rebuilding) the devcontainer.

**Install Ollama once:**
```bash
# macOS / Linux
curl -fsSL https://ollama.com/install.sh | sh

# Or download from https://ollama.com
```

**Pull the default models:**
```bash
ollama pull qwen2.5-coder:14b
ollama pull deepseek-coder:16b
```

**Start Ollama** (if not already running):
```bash
ollama serve
```

> The feature auto-pulls missing models on container start, but the initial download can be several GB. Pre-pulling before first use avoids a slow first experience.

## Usage

Add to your project's `.devcontainer/devcontainer.json`:

```jsonc
{
  "image": "ghcr.io/dever-labs/devcontainers/dotnet-dev:latest",

  "features": {
    "ghcr.io/dever-labs/devcontainer-features/local-ai:1": {}
  }
}
```

The `:1` tag tracks the latest `1.x.x` release — you get updates automatically on every devcontainer rebuild without changing your config.

## Using the tools

### Aider
```bash
# Uses qwen2.5-coder:14b via host Ollama by default
aider src/MyFile.cs
```

### Codex CLI
```bash
# Terminal agent using the local Ollama endpoint
codex "add error handling to the login controller"
```

### Continue.dev
Open the Continue panel in VS Code. Two models are pre-configured: **Qwen Coder 14B** and **DeepSeek Coder 16B**. Tab completion uses Qwen Coder 14B.

## Configuration

Tool configs are written once on first container start and not overwritten on subsequent starts. To reset a config, delete the file and restart the container:

| Tool | Config file |
|------|-------------|
| Aider | `~/.aider.conf.yml` |
| Codex CLI | `~/.codex/config.toml` |
| Continue.dev | `~/.continue/config.json` |

To use a different model, edit the relevant config file. Any model available in your Ollama instance can be used — run `ollama list` on the host to see what's installed.

## Using a custom Ollama endpoint

Set `OLLAMA_HOST` in your devcontainer's `remoteEnv` to override the auto-detected endpoint:

```jsonc
"remoteEnv": {
  "OLLAMA_HOST": "http://my-ollama-server:11434"
}
```

This is useful when running a shared Ollama instance on a remote machine or in Kubernetes.
