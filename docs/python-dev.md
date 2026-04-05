# python-dev

Pre-built devcontainer for Python projects — APIs (FastAPI, Flask, Django), data pipelines, CLI tools, and scripts. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Python | 3.13 (patch auto-updates) | Runtime |
| pip / pipx / virtualenv | via `installTools: true` | Package and environment management |
| Docker-in-Docker | latest | Build images, run containers inside the devcontainer |
| kubectl | latest | Deploy to and inspect Kubernetes clusters |
| Helm | latest | Install and manage Helm charts |
| minikube | latest | Local Kubernetes cluster (auto-started on container start) |
| git | latest | Source control |
| GitHub CLI (`gh`) | latest | PRs, issues, releases, Actions |
| openclaw.ai | latest | AI agent tooling (installed on create) |

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `ms-python.python` | Language server, debugging, test runner |
| `ms-python.pylance` | Fast type checking and IntelliSense |
| `ms-python.black-formatter` | Black code formatter |

## Use cases

### FastAPI service

```jsonc
// .devcontainer/devcontainer.json in your service repo
{
  "name": "my-api",
  "image": "ghcr.io/dever-labs/devcontainers/python-dev:latest",
  "forwardPorts": [8000],
  "portsAttributes": {
    "8000": { "label": "FastAPI", "onAutoForward": "openBrowser" }
  },
  "postCreateCommand": "pip install -r requirements.txt"
}
```

Start the server:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### Using a virtual environment

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Or with `uv` (install once, fast everywhere):

```bash
pip install uv
uv venv && source .venv/bin/activate
uv pip install -r requirements.txt
```

### Data pipeline / script

```jsonc
{
  "name": "my-pipeline",
  "image": "ghcr.io/dever-labs/devcontainers/python-dev:latest",
  "postCreateCommand": "pip install -r requirements.txt"
}
```

### Running tests

```bash
pytest -v
# or with coverage
pytest --cov=src --cov-report=term-missing
```

### Deploying a Python service to local Kubernetes

minikube starts automatically. Build and deploy with Helm:

```bash
docker build -t my-api:local .
helm upgrade --install my-api ./charts/my-api \
  --set image.repository=my-api \
  --set image.tag=local
```

### AI agent use (Copilot coding agent / Claude Code)

- `GITHUB_TOKEN` is forwarded so `gh` and git work without prompts.
- Pylance gives agents precise type information for accurate refactoring.
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `pytest`, validate API responses with `httpx`, and iterate without leaving the container.

## Updating Python

Edit `images/python-dev/devcontainer.json`:

```jsonc
"ghcr.io/devcontainers/features/python:1": {
  "version": "3.14"   // pin to major.minor; patches flow automatically
}
```

Push to `main` — all service repos pick it up on next rebuild.
