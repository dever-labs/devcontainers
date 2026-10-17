#!/usr/bin/env bash
set -euo pipefail

# Install the canonical set of review agent personas inside the devcontainer image.
# Runs once at image build time (not at container start).

FEATURE_DIR="$(dirname "$0")"
CANONICAL_DIR="/etc/agent-personas/agents"

# Canonical, version-pinned copy — lives in the image, never touched by volumes.
mkdir -p "$CANONICAL_DIR"
cp -f "${FEATURE_DIR}"/agents/*.agent.md "$CANONICAL_DIR"/

# agent-personas-sync — copies the canonical agents into ~/.copilot/agents at
# container start, so they show up for GitHub Copilot Chat (VS Code) and the
# Copilot CLI regardless of whether ~/.copilot is backed by a shared volume
# that was already seeded by an older image.
cp "${FEATURE_DIR}/agent-personas-sync" /usr/local/bin/agent-personas-sync
chmod +x /usr/local/bin/agent-personas-sync

# Seed the target user's ~/.copilot/agents now too, so the personas are present
# even if the container is never restarted after creation.
TARGET_HOME="${_REMOTE_USER_HOME:-/home/vscode}"
TARGET_USER="${_REMOTE_USER:-vscode}"
mkdir -p "${TARGET_HOME}/.copilot/agents"
cp -f "$CANONICAL_DIR"/*.agent.md "${TARGET_HOME}/.copilot/agents/"
chown -R "${TARGET_USER}:${TARGET_USER}" "${TARGET_HOME}/.copilot"

echo "==> Installed $(ls "$CANONICAL_DIR" | wc -l | tr -d ' ') review agent personas"
