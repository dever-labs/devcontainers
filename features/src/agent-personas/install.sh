#!/usr/bin/env bash
set -euo pipefail

# Install the canonical set of review agent personas inside the devcontainer image.
# Runs once at image build time (not at container start).
#
# agents/<name>.agent.md is the single source of truth. Each persona is rendered
# into the native format of every supported agent CLI:
#   copilot -> ~/.copilot/agents/<name>.agent.md  (GitHub Copilot CLI + VS Code Copilot Chat)
#   claude  -> ~/.claude/agents/<name>.md         (Claude Code subagents)
#   codex   -> ~/.codex/agents/<name>.toml        (Codex custom agents)
#
# skills/<name>/SKILL.md are shared Agent Skills, using only the portable
# frontmatter fields, so the same files work everywhere:
#   ~/.claude/skills  (Claude Code)
#   ~/.agents/skills  (Codex and GitHub Copilot)

FEATURE_DIR="$(dirname "$0")"
ROOT_DIR="/etc/agent-personas"
CANONICAL_DIR="${ROOT_DIR}/agents"
RENDERED_DIR="${ROOT_DIR}/rendered"

# Read-only tool sets for Copilot and Claude: file-editing tools are left out.
# Shell stays enabled so personas can run git diff/log. For Claude, a PreToolUse
# hook (agent-personas-guard) blocks every non-read-only shell command. Copilot
# agent files can't scope shell access and Codex agents inherit the session's
# sandbox, so for those two mutating commands are forbidden by the instructions.
COPILOT_TOOLS='["read", "search", "execute"]'
CLAUDE_TOOLS='Read, Grep, Glob, Bash'

# frontmatter <file> <key> — value of a top-level key in the YAML frontmatter,
# with surrounding quotes removed. CRLF line endings are tolerated.
frontmatter() {
  awk -v key="$2" '
    { sub(/\r$/, "") }
    NR == 1 && $0 == "---" { in_fm = 1; next }
    in_fm && $0 == "---"   { exit }
    in_fm && index($0, key ": ") == 1 {
      v = substr($0, length(key) + 3)
      if (v ~ /^".*"$/) {
        v = substr(v, 2, length(v) - 2); gsub(/\\"/, "\"", v); gsub(/\\\\/, "\\", v)
      } else if (v ~ /^\047.*\047$/) {
        v = substr(v, 2, length(v) - 2)
      }
      print v; exit
    }
  ' "$1"
}

# body <file> — everything after the closing frontmatter delimiter.
body() {
  awk '{ sub(/\r$/, "") } n >= 2 { print; next } $0 == "---" { n++ }' "$1"
}

# quoted <value> — value as a double-quoted string, valid in both YAML and TOML.
quoted() {
  local s="${1//\\/\\\\}"
  printf '"%s"' "${s//\"/\\\"}"
}

rm -rf "$CANONICAL_DIR" "$RENDERED_DIR"
mkdir -p "$CANONICAL_DIR" "$RENDERED_DIR"/{copilot,claude,codex}
cp -f "${FEATURE_DIR}"/agents/*.agent.md "$CANONICAL_DIR"/
cp -R "${FEATURE_DIR}/skills" "${RENDERED_DIR}/skills"

for src in "$CANONICAL_DIR"/*.agent.md; do
  file_name="$(basename "$src" .agent.md)"
  name="$(frontmatter "$src" name)"
  description="$(frontmatter "$src" description)"
  instructions="$(body "$src")"

  if [ "$name" != "$file_name" ] || [ -z "$description" ]; then
    echo "agent-personas: ${src} needs 'name: ${file_name}' and a 'description' in its frontmatter" >&2
    exit 1
  fi
  if [[ "$instructions" == *"'''"* ]]; then
    echo "agent-personas: ${src} must not contain ''' (breaks the Codex TOML literal string)" >&2
    exit 1
  fi

  cat > "${RENDERED_DIR}/copilot/${name}.agent.md" <<EOF
---
name: ${name}
description: $(quoted "$description")
tools: ${COPILOT_TOOLS}
---
${instructions}
EOF

  cat > "${RENDERED_DIR}/claude/${name}.md" <<EOF
---
name: ${name}
description: $(quoted "$description")
tools: ${CLAUDE_TOOLS}
model: inherit
hooks:
  PreToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "/usr/local/bin/agent-personas-guard"
---
${instructions}
EOF

  cat > "${RENDERED_DIR}/codex/${name}.toml" <<EOF
name = $(quoted "$name")
description = $(quoted "$description")
developer_instructions = '''
${instructions}
'''
EOF
done

# agent-personas-sync — copies the rendered agents into each tool's user-level
# agents directory at container start, so they stay current even when those
# directories are backed by shared volumes seeded by an older image.
cp "${FEATURE_DIR}/agent-personas-sync" /usr/local/bin/agent-personas-sync
chmod +x /usr/local/bin/agent-personas-sync

# agent-personas-guard — Claude Code hook that keeps the personas' Bash read-only.
cp "${FEATURE_DIR}/agent-personas-guard" /usr/local/bin/agent-personas-guard
chmod +x /usr/local/bin/agent-personas-guard

# agent-personas — `agent-personas init` scaffolds a repository's agent layer.
cp "${FEATURE_DIR}/agent-personas" /usr/local/bin/agent-personas
chmod +x /usr/local/bin/agent-personas

# Seed the target user's home now too, so the personas are present even if the
# container is never restarted after creation.
TARGET_HOME="${_REMOTE_USER_HOME:-/home/vscode}"
TARGET_USER="${_REMOTE_USER:-vscode}"
HOME="$TARGET_HOME" agent-personas-sync
chown -R "${TARGET_USER}:${TARGET_USER}" \
  "${TARGET_HOME}/.copilot" "${TARGET_HOME}/.claude" "${TARGET_HOME}/.codex" "${TARGET_HOME}/.agents"

echo "==> Installed $(ls "$CANONICAL_DIR" | wc -l | tr -d ' ') review agent personas and $(ls "${RENDERED_DIR}/skills" | wc -l | tr -d ' ') shared skill(s) for Copilot, Claude Code and Codex"
