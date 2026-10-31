# GitHub CLI authentication

All dever-labs devcontainers share a single named Docker volume — `dever-labs-gh-config` — that persists `gh` credentials across container rebuilds and across every repo you work in.

## One-time setup

Your GitHub token is kept in OpenBao (`https://vault.dever.dk`), not in an environment variable on your host.

1. Create a GitHub token (https://github.com/settings/tokens) and note its expiry.
2. Open any dever-labs devcontainer and run:
   ```bash
   dever-gh-login --store
   ```
   It opens a browser to sign in with your Idently account, stores the token at `dever/users/<you>/github` in OpenBao, and logs `gh` in.
3. Done — every other dever-labs container now has your credentials automatically.

When the token expires, create a new one and run `dever-gh-login --store` again. Plain `dever-gh-login` re-logs `gh` in from the token already stored. No host environment variables are involved.

`gh auth login` still works if you prefer it; credentials land in the same volume.

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

The next time you open a devcontainer, run `dever-gh-login` again.
