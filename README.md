# dever-labs devcontainers

Shared, pre-built devcontainer images for the dever-labs organisation — ready for **human developers** and **AI coding agents** (GitHub Copilot, Claude Code).

All service repos reference an image from here. No per-repo builds, no drift between environments.

## Available images

| Image | Pull | Toolchain | Extras |
|-------|------|-----------|--------|
| [`dotnet-dev`](docs/dotnet-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/dotnet-dev:latest` | .NET 10 SDK | Docker-outside-of-Docker, kubectl, Helm, k3d |
| [`frontend-dev`](docs/frontend-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/frontend-dev:latest` | Node.js 26 | Docker-outside-of-Docker, kubectl, Helm, k3d |
| [`python-dev`](docs/python-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/python-dev:latest` | Python 3.14 | Docker-outside-of-Docker, kubectl, Helm, k3d |
| [`go-dev`](docs/go-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/go-dev:latest` | Go 1.26 | Docker-outside-of-Docker, kubectl, Helm, k3d |
| [`flutter-dev`](docs/flutter-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/flutter-dev:latest` | Flutter stable + Dart SDK | Web, Linux, Android targets (iOS requires macOS runner) |
| [`infra-dev`](docs/infra-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/infra-dev:latest` | Terraform, Azure CLI, AWS CLI, gcloud, Hetzner `hcloud`, ArgoCD, Flux | Docker-outside-of-Docker, kubectl, Helm, k3d |
| [`node-dev`](docs/node-dev.md) | `docker pull ghcr.io/dever-labs/devcontainers/node-dev:latest` | Node.js 26 | Docker-outside-of-Docker, kubectl, Helm, k3d |

All images include: **git**, **GitHub CLI**, **GitHub Copilot CLI**, and **Claude Code** (VS Code extensions + CLIs, installed with pinned versions), plus the [`agent-personas`](features/src/agent-personas/README.md) feature — shared read-only review agents (**architect**, **devops**, **docs**, **security**, **qa**, **po**, **pm**) available in Copilot Chat and the Copilot CLI, so every dever-labs devcontainer reviews changes with the same set of lenses. Select one from the agent picker in VS Code, or run `copilot --agent <name> -p "..."` from the terminal. Every image also includes [`devx`](https://github.com/dever-labs/devx) — a declarative local dev task orchestrator (`devx up`/`status`/`logs`/`doctor`, ...).

## Available features

Features are opt-in add-ons that layer on top of any base image. Add them to your project's `.devcontainer/devcontainer.json`.

| Feature | Reference | What it adds |
|---------|-----------|--------------|
| [`local-ai`](features/src/local-ai/README.md) | `ghcr.io/dever-labs/devcontainers/features/local-ai:1` | Aider, Codex CLI, Copilot CLI, Claude Code, Continue.dev — connected to host Ollama |
| [`agent-personas`](features/src/agent-personas/README.md) | `ghcr.io/dever-labs/devcontainers/features/agent-personas:1` | Shared read-only review agents. Already in every image; add it only to repos that use a different base image. |
| [`devx`](https://github.com/dever-labs/devx/blob/main/docs/install.md) | `ghcr.io/dever-labs/devx/cli:1` | Installs the `devx` developer orchestration CLI (`devx ai`, `devx dev`, `devx doctor`, ...). Published from [dever-labs/devx](https://github.com/dever-labs/devx), not this repo. Already in every image. Option `version` selects the release tag. |

## Using an image in a service repo

Add a `.devcontainer/devcontainer.json` that references the pre-built image. The devcontainer spec doesn't support inheritance, so a small set of runtime properties (mounts, env, extensions) must be repeated in each repo. Copy the template below and add your repo-specific extensions at the bottom.

```jsonc
{
  "name": "my-service",
  // Replace with the image that matches your stack.
  // Available: dotnet-dev, frontend-dev, node-dev, python-dev, go-dev, flutter-dev, infra-dev
  "image": "ghcr.io/dever-labs/devcontainers/<name>:latest",

  "features": {
    // Local AI tooling — Aider, Codex CLI, Copilot CLI, Claude Code, Continue.dev.
    // Handles credential volumes, VS Code extensions, and Ollama config automatically.
    // Requires Ollama on the host: https://ollama.com
    "ghcr.io/dever-labs/devcontainers/features/local-ai:1": {}
  },

  // Runs on the HOST before the container starts. NOTE: this executes a script fetched from
  // `main` on your machine. Beyond personal use, pin the URL to a release tag or commit SHA
  // (replace `main`) and review the script first.
  // Installs Ollama if missing, starts it, and pulls default models in the background.
  // Safe to run on every container start — all steps are idempotent.
  "initializeCommand": "curl -fsSL https://raw.githubusercontent.com/dever-labs/devcontainers/main/scripts/ollama-setup | bash",

  // Images with k3d (all except flutter-dev) include
  // k3d-cluster-init. Add this to auto-start a local cluster on each container start.
  // "postStartCommand": "k3d-cluster-init",

  "customizations": {
    "vscode": {
      "extensions": [
        // Add your stack-specific extensions below
      ]
    }
  }
}
```

No build step in the service repo. When the shared image updates, every repo picks it up on the next container rebuild.

## Host setup (Ollama)

The `local-ai` feature connects to Ollama running on your host machine. Run the setup script once to install Ollama, pull the default models, and verify everything works:

```bash
bash scripts/ollama-setup
```

This installs Ollama if missing, starts it, pulls `deepseek-r1:70b`, and confirms the API is reachable from devcontainers.

Other host scripts (run from a clone, or via `dever <script>`, which downloads the script from `main` and runs it, so the same trust note applies):

| Script | Purpose |
|--------|---------|
| `scripts/ai-setup` | Detects the platform: runs `mlx-setup` on Apple Silicon, `ollama-setup` elsewhere |
| `scripts/mlx-setup [model]` | MLX-LM inference server for Apple Silicon |
| `scripts/dever <script>` | Convenience wrapper that fetches and runs a script from this repo |

## Using with AI agents

These images are designed to work as autonomous agent environments, not just IDE containers.

### GitHub Copilot Coding Agent / Copilot Workspace

The images are compatible with [GitHub Copilot coding agent](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent). Reference the image in your repo's `.devcontainer/devcontainer.json` and Copilot will use it automatically.

### Claude Code

Claude Code is pre-installed as a VS Code extension (`anthropics.claude-code`) and as the `claude` CLI; the GitHub Copilot CLI (`copilot`) is installed too. For headless agent use:

```bash
docker run --rm -it ghcr.io/dever-labs/devcontainers/dotnet-dev:latest bash
```

### Authentication

All images mount a shared Docker volume — `dever-labs-gh-config` — to `~/.config/gh`. Authenticate once inside any container and every dever-labs devcontainer picks it up automatically, across rebuilds and repos.

```bash
# Run once, inside any container
gh auth login
```

Docker volumes are OS-agnostic — this works on macOS, Linux, and Windows without any host path configuration.

Images no longer forward `GITHUB_TOKEN` from your host: an expired host token used to override the working credentials. See [docs/github-auth.md](docs/github-auth.md). Automated environments (Copilot coding agent) still provide `GITHUB_TOKEN` themselves, and `gh` honours it.

Copilot CLI credentials persist the same way through a second shared volume, `dever-labs-copilot` (mounted at `~/.copilot`): run `copilot /login` once.

→ [Full authentication guide](docs/github-auth.md)

## How CI builds images

```
images/dotnet-dev/devcontainer.json
         │
         ▼  (push to main → GitHub Actions)
ghcr.io/dever-labs/devcontainers/dotnet-dev:latest   [public]
         │
         ▼  (service repos reference)
.devcontainer/devcontainer.json → "image": "ghcr.io/..."
```

On push to `main`, only images affected by the change are rebuilt (changes to `images/Dockerfile`, `images/scripts/`, or `features/` rebuild all). All images are also rebuilt weekly to pick up base-image security updates. A `workflow_dispatch` input lets you rebuild a single named image.

Pull requests build each affected image (amd64, no push) and run `.github/scripts/smoke-test.sh` to check the expected tools are on `PATH`.

### Image tags

| Tag | Meaning |
|-----|---------|
| `latest` | Most recent build of `main` — moves on every rebuild |
| `<yyyymmdd>-<sha>` | Immutable tag for a specific build (build date + commit) — pin to this for reproducibility or rollback |
| `vX.Y.Z`, `vX.Y`, `vX` | Created when a `v*` git tag is pushed |

Tool versions are pinned via `ARG`s in the Dockerfiles and feature `version` options in `images/*/devcontainer.json`. [Renovate](renovate.json) opens a weekly PR for each annotated pin (`# renovate:` / `// renovate:` comments); the PR build and smoke tests validate it. Dependabot handles GitHub Actions and base images. The Node major (`NODE_MAJOR`) is bumped manually, LTS only.

## One-time setup: make packages public

Package visibility on GHCR persists across pushes — set each image to public once and it stays public forever regardless of how many times CI rebuilds it.

For each image, go to **github.com/orgs/dever-labs/packages**, open the package, and under **Package settings → Change visibility → Public**.

Do this once per image (7 images) after its first CI build.

## Adding a new image

1. Create `images/<name>/devcontainer.json` using an existing image as a template; point `build.dockerfile` at `../Dockerfile` (shared) unless the image needs its own.
2. Add the image to `.github/scripts/smoke-test.sh`.
3. Push to `main` — CI builds and pushes `ghcr.io/dever-labs/devcontainers/<name>:latest`.
4. Reference it in service repos.

## Modifying an existing image

Edit `images/<name>/devcontainer.json` (or the shared `images/Dockerfile`) via a pull request; CI builds and smoke-tests it before merge. Service repos pick up the change on their next container rebuild — no changes needed in service repos.

## Conventions

- Base image: `mcr.microsoft.com/devcontainers/base:ubuntu-24.04`
- Feature versions: pin to `major.minor` (e.g. `"version": "10.0"`) so patch updates flow automatically.
- Keep images generic for their persona — no project-specific tooling here.

## Repository scope

The images under `images/` are the core product. `features/src/local-ai` and the host scripts in `scripts/` (`ollama-setup`, `mlx-setup`, `ai-setup`, `dever`) are optional org tooling that happen to live here; they are not part of any base image and should be split into their own repository if they grow. `devx` itself lives in [dever-labs/devx](https://github.com/dever-labs/devx) — only its feature *reference* is consumed here.

