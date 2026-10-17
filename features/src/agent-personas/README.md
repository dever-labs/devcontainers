# agent-personas

Adds a shared set of **read-only review agents** to any devcontainer, available in both **GitHub Copilot Chat** (VS Code) and the **Copilot CLI**. Every dever-labs devcontainer that includes this feature gets the exact same personas, at the exact same version — so a change gets reviewed the same way whether it happened in a `dotnet-dev`, `frontend-dev`, or `infra-dev` container.

## What's included

| Agent | Lens |
|-------|------|
| `architect` | Structure, consistency, coupling, and long-term maintainability |
| `devops` | CI/CD, containers, build reproducibility, and operational risk |
| `docs` | Documentation accuracy, completeness, and clarity |
| `security` | Secrets, permissions, dependencies, and attack surface |
| `qa` | Test coverage, edge cases, and testability |
| `po` | Alignment with product intent, scope, and acceptance criteria |
| `pm` | Release readiness, risk, and cross-team communication |

Each agent is a `.agent.md` custom agent — a persona with focused instructions and its own review checklist. They are advisory only: none of them edit files or run mutating commands.

## Usage

Add to your project's `.devcontainer/devcontainer.json`:

```jsonc
{
  "image": "ghcr.io/dever-labs/devcontainers/<name>:latest",

  "features": {
    "ghcr.io/dever-labs/devcontainers/features/agent-personas:1": {}
  }
}
```

The `:1` tag tracks the latest `1.x.x` release — every project picks up persona updates automatically on the next devcontainer rebuild.

## Reviewing a change

In VS Code Copilot Chat, open the agent picker and select one of the personas (e.g. **architect**), then ask it to review your change:

```
Review my current branch against main.
```

From the Copilot CLI:

```bash
copilot --agent architect -p "Review my current branch against main"
```

Run multiple personas over the same diff to get complementary feedback — e.g. `architect` + `security` + `qa` before opening a PR, or `po` + `pm` to sanity-check scope and release readiness.

## How it works

Agent definitions are canonical files baked into the image at `/etc/agent-personas/agents/`. A `postStartCommand` (`agent-personas-sync`) copies them into `~/.copilot/agents/` on every container start — the location GitHub Copilot reads user-level custom agents from, in both VS Code and the CLI.

Syncing on every start (rather than relying solely on the image layer) matters because `~/.copilot` is often a shared, persistent Docker volume across dever-labs devcontainers (see the `local-ai` feature and the `dever-labs-copilot` volume). Without the sync step, whichever image first created that volume would "win" and other images/versions couldn't update the personas. `agent-personas-sync` always re-applies the current image's canonical set, so personas stay consistent and up to date regardless of mount history.

## Adding or changing a persona

Edit the relevant `agents/<name>.agent.md` file in this feature and bump the feature version. All projects pinned to `:1` pick up the change on their next rebuild.
