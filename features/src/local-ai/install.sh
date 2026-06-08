#!/usr/bin/env bash
set -euo pipefail

# Install AI coding tools inside the devcontainer image.
# Runs once at image build time (not at container start).

apt-get update
apt-get install -y --no-install-recommends python3-pip python3-venv

# aider-chat — isolated venv avoids conflicts with system packages
# setuptools and wheel must be listed explicitly on Python 3.12+ where venvs ship without them
python3 -m venv /opt/aider
/opt/aider/bin/pip install --upgrade pip setuptools wheel aider-chat
ln -sf /opt/aider/bin/aider /usr/local/bin/aider

# @openai/codex, @github/copilot, @anthropic-ai/claude-code — Node.js is already present in all dever-labs base images
npm install -g @openai/codex @github/copilot @anthropic-ai/claude-code

# Persist the chosen model so ollama-connect can read it at container start
mkdir -p /etc/local-ai
echo "${MODEL:-deepseek-r1:70b}" > /etc/local-ai/model
echo "${AUTOCOMPLETE_MODEL:-qwen2.5-coder:14b}" > /etc/local-ai/autocomplete-model

# ollama-connect — detects host Ollama and writes tool configs at container start
cp "$(dirname "$0")/ollama-connect" /usr/local/bin/ollama-connect
chmod +x /usr/local/bin/ollama-connect

# Pre-create credential directories owned by the container user.
# When a named volume is mounted over a directory, Docker seeds the volume
# from the image on first use — so ownership set here is preserved in the volume.
# Without this, Docker creates the mount point as root and tools fail to write.
TARGET_HOME="${_REMOTE_USER_HOME:-/home/vscode}"
TARGET_USER="${_REMOTE_USER:-vscode}"
mkdir -p \
  "${TARGET_HOME}/.codex" \
  "${TARGET_HOME}/.claude" \
  "${TARGET_HOME}/.copilot" \
  "${TARGET_HOME}/.continue" \
  "${TARGET_HOME}/.config/gh"
chown -R "${TARGET_USER}:${TARGET_USER}" \
  "${TARGET_HOME}/.codex" \
  "${TARGET_HOME}/.claude" \
  "${TARGET_HOME}/.copilot" \
  "${TARGET_HOME}/.continue" \
  "${TARGET_HOME}/.config/gh"

apt-get clean
rm -rf /var/lib/apt/lists/*
