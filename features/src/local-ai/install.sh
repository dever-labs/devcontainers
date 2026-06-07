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

# @openai/codex — Node.js is already present in all dever-labs base images
npm install -g @openai/codex

# ollama-connect — detects host Ollama and writes tool configs at container start
cp "$(dirname "$0")/ollama-connect" /usr/local/bin/ollama-connect
chmod +x /usr/local/bin/ollama-connect

apt-get clean
rm -rf /var/lib/apt/lists/*
