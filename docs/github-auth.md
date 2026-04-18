# GitHub CLI authentication

All dever-labs devcontainers share a single named Docker volume — `dever-labs-gh-config` — that persists `gh` credentials across container rebuilds and across every repo you work in.

## One-time setup

1. Open any dever-labs devcontainer (any repo, any image).
2. Inside the terminal, run:
   ```bash
   gh auth login
   ```
3. Follow the prompts (browser or token).
4. Done — every other dever-labs container now has your credentials automatically.

## How it works

The Docker volume `dever-labs-gh-config` is mounted to `~/.config/gh` inside every container. When `gh auth login` writes credentials to `~/.config/gh/hosts.yml`, they land in the shared volume. Any container that mounts the same volume reads those credentials on startup.

Docker named volumes are host-OS-agnostic — this works identically on **macOS**, **Linux**, and **Windows** (Docker Desktop or WSL2). There is no host path involved, so no OS-specific configuration is required.

## AI agents

When running as a GitHub Copilot coding agent or similar automated environment, `GITHUB_TOKEN` is forwarded from the platform via `remoteEnv`. The `gh` CLI treats this env var as the auth token (highest priority), so no manual login is needed for agents. The volume credentials are used as a fallback when `GITHUB_TOKEN` is not set.

## Adding auth to a new service repo

For image-only devcontainers (no `docker-compose.yml`), add this to `.devcontainer/devcontainer.json`:

```jsonc
{
  "mounts": [
    "source=dever-labs-gh-config,target=/home/vscode/.config/gh,type=volume"
  ],
  "remoteEnv": {
    "GITHUB_TOKEN": "${localEnv:GITHUB_TOKEN}"
  }
}
```

> **Note:** Replace `/home/vscode` with `/home/<remoteUser>` if your devcontainer uses a different user.

For docker-compose devcontainers, add to `docker-compose.yml`:

```yaml
services:
  app:
    volumes:
      - dever-labs-gh-config:/home/vscode/.config/gh

volumes:
  dever-labs-gh-config:
    name: dever-labs-gh-config   # fixed name — no compose project prefix
```

## Resetting credentials

To clear stored credentials and start fresh:

```bash
docker volume rm dever-labs-gh-config
```

The next time you open a devcontainer, run `gh auth login` again.
