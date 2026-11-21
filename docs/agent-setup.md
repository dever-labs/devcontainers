# Agent setup for repositories

Every dever-labs devcontainer comes with the same AI agent baseline: Claude Code, Codex and the GitHub Copilot CLI, the shared review personas (**architect**, **devops**, **docs**, **security**, **qa**, **po**, **pm**) and a small set of shared skills. That baseline is generic on purpose. Knowledge that belongs to one repository lives **in that repository**, where it's versioned, reviewed and shared with everyone who works on it, human or agent.

## The two layers

| Layer | Where | What | Changes via |
|-------|-------|------|-------------|
| **Shared** (image) | `~/.copilot/agents`, `~/.claude/agents`, `~/.codex/agents`, `~/.claude/skills`, `~/.agents/skills` | Review personas and generic skills from the [`agent-personas`](../features/src/agent-personas/README.md) feature | A PR to this repo and a feature version bump. Re-synced on every container start, so **don't edit these files locally**. |
| **Repository** | The repo itself (see below) | Instructions, repo skills, persona overlays | Normal PRs in that repo |

## Repository layout

```
AGENTS.md                    instructions for every agent
CLAUDE.md                    "@AGENTS.md", so Claude Code reads the same file
.agents/
  skills/<name>/SKILL.md     repository skills
  personas/<persona>.md      overlays for the shared review personas
.claude/skills -> ../.agents/skills
```

How each tool picks these up:

| File | Claude Code | Codex | GitHub Copilot |
|------|-------------|-------|----------------|
| `AGENTS.md` | through the `@AGENTS.md` import in `CLAUDE.md` | native | native (CLI, VS Code, cloud agent) |
| `.agents/skills/` | through the `.claude/skills` symlink | native | native |
| `.agents/personas/<name>.md` | read by the persona itself before each review | same | same |

Create the layout with:

```bash
agent-personas init
```

It creates whatever is missing and **never overwrites** existing files; it tells you about anything it skipped (e.g. an existing `CLAUDE.md` that doesn't import `AGENTS.md` yet). Review the diff and commit it. You can also ask any of the agents to "set up the agent config for this repo": the shared `agent-personas-setup` skill teaches them this convention, including filling in `AGENTS.md` from the repository.

> **Windows:** `.claude/skills` is a symlink. Git on Windows checks symlinks out as plain text files unless `core.symlinks` is enabled. Inside the devcontainer (Linux) it works as expected.

## Writing `AGENTS.md`

`AGENTS.md` is always in context, so every line costs attention. Keep it short (well under 200 lines) and include only what an agent can't work out from the code:

- **Commands**: exact build, test, lint and run commands.
- **Structure**: only what's non-obvious from the tree.
- **Conventions**: rules tooling doesn't enforce.
- **Boundaries**: files never to edit, commands never to run, approvals needed.

Put multi-step procedures in skills, and review-specific guidance in persona overlays. Don't paste in auto-generated summaries of the codebase: research shows they make agents worse, not better.

## Repository skills

A skill is a folder with a `SKILL.md`: a procedure an agent loads only when it's relevant ("release this service", "add a database migration"). Use only the portable frontmatter fields from the [Agent Skills spec](https://agentskills.io/specification) (`name`, `description`, optionally `license`, `compatibility`, `metadata`), so the same skill works in all three tools:

```markdown
---
name: add-migration
description: Creates and verifies a database migration for this service. Use when adding or changing database tables, columns or indexes.
---

1. Run `make migration name=<snake_case_name>` ...
```

`name` must match the folder name. The description decides when the skill triggers, so write it in the third person with the words people actually use. Give repository skills names that don't collide with the shared ones (`agent-personas-setup`).

## Persona overlays: how the personas learn

Each shared persona starts every review by reading `.agents/personas/<persona>.md` if it exists, and applies it on top of its generic instructions. That's how a generic **security** persona learns that, in *this* repository, auth is enforced at the gateway, or that a pattern it keeps flagging is an accepted trade-off.

```markdown
# security — repository guidance

## Context
- Public traffic only reaches services through the gateway in infra/; auth is enforced there.

## Learned conventions
- Env-var reads in cmd/ are for local development only; don't flag them as secret handling. (2026-11-21, PR #123)
```

The loop:

1. A persona reviews a change. Its report ends with **Proposed learnings**: conventions or false positives it thinks are worth recording.
2. You decide which ones are true. Ask an agent to record them (the `agent-personas-setup` skill knows the format), or edit the overlay yourself.
3. The overlay change goes through a normal PR. Once merged, every persona run in every tool, for everyone on the team, uses it.

The personas themselves stay read-only: they only *propose* learnings, and nothing changes until a human-reviewed commit lands. Keep overlays short and specific. If a learning applies to every repository, it belongs in the shared persona instead: open a PR here.

## Agent memory features

Claude Code, Codex and Copilot each have their own memory features (Claude's auto memory, Codex memories, Copilot Memory). They're fine to use, but they're per tool, often per person, and some expire. Anything the whole team should rely on belongs in `AGENTS.md`, a skill or a persona overlay, committed to the repository.

## Changing the shared layer

The personas and shared skills are defined in [`features/src/agent-personas`](../features/src/agent-personas/README.md): `agents/<name>.agent.md` (one source, rendered for all three tools) and `skills/<name>/SKILL.md`. Change them there and bump the feature version; every devcontainer picks it up on its next rebuild.
