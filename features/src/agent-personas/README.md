# agent-personas

Adds a shared set of **read-only review agents** to any devcontainer, available in **GitHub Copilot** (VS Code Chat + CLI), **Claude Code**, and **Codex**. Every dever-labs devcontainer that includes this feature gets the exact same personas, at the exact same version, in every agent — so a change gets reviewed the same way whether it happened in a `dotnet-dev`, `frontend-dev`, or `infra-dev` container, and whichever AI tool you prefer.

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

Each persona has focused instructions and its own review checklist, and reads repo-specific guidance from `.agents/personas/<name>.md` when the repository has it (see [Agent setup for repositories](../../../docs/agent-setup.md)). They are advisory only and don't edit files (see [Read-only enforcement](#read-only-enforcement) for how each tool enforces that).

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

| Tool | How to use a persona |
|------|----------------------|
| VS Code Copilot Chat | Pick the persona (e.g. **architect**) in the agent picker, then ask `Review my current branch against main.` |
| Copilot CLI | `copilot --agent architect -p "Review my current branch against main"` |
| Claude Code | `claude --agent architect "Review my current branch against main"`, or in any session: `Use the architect, security and qa agents to review my branch against main.` |
| Codex | `codex "Have the architect agent review my current branch against main."` — Codex spawns the named custom agent |

Run multiple personas over the same diff to get complementary feedback — e.g. `architect` + `security` + `qa` before opening a PR, or `po` + `pm` to sanity-check scope and release readiness. Claude Code and Codex can run several of them in parallel as subagents from a single prompt.

## Shared skills and repository setup

Besides the personas, the feature installs shared [Agent Skills](https://agentskills.io) (`skills/<name>/SKILL.md`) for all three tools, and the `agent-personas` command:

| | What it does |
|-|--------------|
| `agent-personas-setup` skill | Teaches every agent the repository convention: setting up `AGENTS.md`, adding repo skills, and recording persona learnings in `.agents/personas/<name>.md`. Triggers when you ask e.g. "set up the agent config for this repo" or "record that as a learning for the security persona". |
| `agent-personas init` | Scaffolds the repository layer (`AGENTS.md`, `CLAUDE.md` importing it, `.agents/skills` with a `.claude/skills` symlink, `.agents/personas/README.md`). Never overwrites existing files. |

The full convention is in [Agent setup for repositories](../../../docs/agent-setup.md).

## How it works

`agents/<name>.agent.md` is the **single source of truth** (frontmatter `name` + `description`, Markdown body = instructions). At image build time `install.sh` renders each persona into every tool's native format under `/etc/agent-personas/rendered/`:

| Tool | Installed to | Format | Read-only tools |
|------|--------------|--------|-----------------|
| GitHub Copilot (CLI + VS Code) | `~/.copilot/agents/<name>.agent.md` | Copilot custom agent | `read`, `search`, `execute` |
| Claude Code | `~/.claude/agents/<name>.md` | Claude subagent | `Read`, `Grep`, `Glob`, `Bash` (guarded) |
| Codex | `~/.codex/agents/<name>.toml` | Codex custom agent | inherits the session sandbox |
| Shared skills | `~/.claude/skills/<name>/` (Claude Code), `~/.agents/skills/<name>/` (Codex, Copilot) | Agent Skills, portable frontmatter only | n/a |

A `postStartCommand` (`agent-personas-sync`) copies them into place on every container start. That matters because `~/.copilot`, `~/.claude` and `~/.codex` are often shared, persistent Docker volumes across dever-labs devcontainers (see the `local-ai` feature). Without the sync step, whichever image first created a volume would "win". The sync also:

- keeps a `.agent-personas-manifest` in each directory, so personas removed from this feature are deleted on the next start (including copies left by 1.0.0, which wrote no manifest), while agents you added yourself are left untouched;
- takes a `flock` on each directory, so containers starting at the same time on a shared volume don't interleave their updates.

### Read-only enforcement

| Tool | How read-only is enforced |
|------|---------------------------|
| Claude Code | No file-editing tools, plus a `PreToolUse` hook (`agent-personas-guard`) that blocks every Bash command that isn't on a read-only allowlist (`git diff/log/show/status/blame/...`, `grep`, `rg`, `cat`, `find` without `-exec`/`-delete`, ...). Writes, redirections to files, command substitution and mutating git subcommands are rejected. |
| Copilot | No file-editing tools. Copilot agent files can't scope shell access to specific commands, so mutating shell commands are forbidden by the instructions only. |
| Codex | Custom agents inherit the parent session's sandbox and can't restrict it. For a hard guarantee, run reviews with `codex --sandbox read-only`. |

The guard blocks test runners too. To let a persona such as `qa` run your test suite, allow those commands explicitly, e.g. `AGENT_PERSONAS_ALLOW="npm go dotnet"` in `remoteEnv`.

**VS Code note:** VS Code reads Copilot-format agents from `~/.copilot/agents` and Claude-format agents from `~/.claude/agents`. If your agent picker shows both harnesses, each persona appears once per harness. Both copies come from the same source, and VS Code has no setting to turn off `~/.claude/agents` discovery.

## Adding or changing a persona

Edit (or add) `agents/<name>.agent.md` in this feature — `name` must match the filename — and bump the feature version. Shared skills work the same way under `skills/<name>/SKILL.md`; keep to the portable frontmatter fields (`name`, `description`, `license`, `compatibility`, `metadata`) so they load in every tool. All three tools get the change, and every project pinned to `:1` picks it up on its next rebuild.
