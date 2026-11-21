---
name: agent-personas-setup
description: Sets up or updates a repository's AI agent configuration using the dever-labs convention — AGENTS.md, repo skills in .agents/skills, and overlays for the shared review personas (architect, devops, docs, security, qa, po, pm) in .agents/personas. Use when asked to set up or improve agent instructions for a repository, add a repository skill, or record a learning, convention or false positive for a review persona.
---

# Repository agent setup

The dever-labs devcontainers ship generic review personas and skills at user level. Everything specific to one repository lives in the repository itself, in files every agent (Claude Code, Codex, GitHub Copilot) can read:

| Path | Purpose |
|------|---------|
| `AGENTS.md` | Repo instructions for all agents. Codex and Copilot read it natively. |
| `CLAUDE.md` | Contains `@AGENTS.md` so Claude Code reads the same instructions. |
| `.agents/skills/<name>/SKILL.md` | Repo skills. Codex and Copilot read this directory natively. |
| `.claude/skills` | Symlink to `../.agents/skills`, so Claude Code sees the same skills. |
| `.agents/personas/<name>.md` | Overlay for a shared persona; the persona reads it before every review. |

Full guide: https://github.com/dever-labs/devcontainers/blob/main/docs/agent-setup.md

## Setting up a repository

1. Run `agent-personas init` from inside the repository. It creates whatever is missing and never overwrites existing files; read its output for anything it skipped.
2. Fill in `AGENTS.md` from what you can verify in the repository (build files, CI workflows, README, directory layout):
   - **Commands** — the exact build, test, lint and run commands.
   - **Structure** — only what is non-obvious from the tree.
   - **Conventions** and **Boundaries** — rules tooling doesn't enforce, and what agents must not do.
   - Keep it well under 200 lines and include only facts an agent couldn't infer. Delete sections that don't apply rather than leaving placeholders. Don't invent conventions — if something is unclear, ask.
3. If an existing `CLAUDE.md` doesn't import `AGENTS.md`, propose adding an `@AGENTS.md` line, and move shared content into `AGENTS.md`.
4. Show the resulting diff and let the user review and commit it.

## Adding a repository skill

Create `.agents/skills/<name>/SKILL.md` with only the portable frontmatter fields (`name`, `description`, optionally `license`, `compatibility`, `metadata`) so every agent can load it. `name` must match the directory name (lowercase letters, digits, hyphens). Write the description in the third person with the words a user would use to ask for it. Keep the body under 500 lines; put long reference material in files next to `SKILL.md` and link to them.

## Recording a persona learning

Review personas end their reports with **Proposed learnings**. When the user accepts one (or asks you to record a convention or false positive for a persona):

1. Open or create `.agents/personas/<persona>.md` (heading `# <persona> — repository guidance`, sections `## Context` and `## Learned conventions`).
2. Add one bullet under **Learned conventions**: the rule, why it holds in this repository, and the date plus PR or issue reference.
3. Merge with existing bullets instead of duplicating them; remove bullets that are no longer true.
4. Keep overlays short and specific. Generic advice belongs in the shared personas, not in an overlay.
5. Show the diff for review — learnings only take effect once they are committed.

Never edit the user-level persona files (`~/.copilot/agents`, `~/.claude/agents`, `~/.codex/agents`): they are overwritten on every container start.
