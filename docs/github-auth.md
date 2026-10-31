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

Do not forward a token from your host with `remoteEnv` / `localEnv:GITHUB_TOKEN`: when it expires it overrides the working credentials in the volume. If you want to fetch tokens from a secret manager, do it from your own tooling and pipe the result into `gh auth login --with-token`; the images stay independent of any particular secret store.

## How it works

The Docker volume `dever-labs-gh-config` is mounted to `~/.config/gh` inside every container. When `gh auth login` writes credentials to `~/.config/gh/hosts.yml`, they land in the shared volume. Any container that mounts the same volume reads those credentials on startup.

Docker named volumes are host-OS-agnostic — this works identically on **macOS**, **Linux**, and **Windows** (Docker Desktop or WSL2). There is no host path involved, so no OS-specific configuration is required.

## Copilot CLI

Every image also mounts a second shared volume, `dever-labs-copilot`, at `~/.copilot`. Run `copilot /login` once inside any container and the Copilot CLI stays authenticated in all of them. The `agent-personas` feature keeps its review agents in this directory too.

To use it in your own repo, add `"source=dever-labs-copilot,target=/home/vscode/.copilot,type=volume"` to `mounts` (same `<remoteUser>` note as below).

## AI agents

When running as a GitHub Copilot coding agent or similar automated environment, the platform provides `GITHUB_TOKEN` itself. The `gh` CLI treats this env var as the auth token (highest priority), so no manual login is needed for agents. Do not forward `GITHUB_TOKEN` from your host in `devcontainer.json`: when it expires it overrides the working credentials in the volume.

## Adding auth to a new service repo

For image-only devcontainers (no `docker-compose.yml`), add this to `.devcontainer/devcontainer.json`:

```jsonc
{
  "mounts": [
    "source=dever-labs-gh-config,target=/home/vscode/.config/gh,type=volume"
  ]
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
