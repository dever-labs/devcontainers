#!/usr/bin/env bash
# Smoke test for a built devcontainer image: verifies the expected tools are on PATH.
# Usage: smoke-test.sh <image-name>   (e.g. dotnet-dev)
set -uo pipefail

IMAGE="${1:?usage: smoke-test.sh <image-name>}"

common=(git gh node npm copilot claude codex make devx agent-personas)
cluster=(docker kubectl helm k3d k3d-cluster-init)

case "$IMAGE" in
  dotnet-dev)   tools=("${common[@]}" "${cluster[@]}" dotnet) ;;
  go-dev)       tools=("${common[@]}" "${cluster[@]}" go) ;;
  rust-dev)     tools=("${common[@]}" "${cluster[@]}" cargo rustc rustfmt clippy-driver) ;;
  python-dev)   tools=("${common[@]}" "${cluster[@]}" python3 pip3) ;;
  frontend-dev) tools=("${common[@]}" "${cluster[@]}") ;;
  node-dev)     tools=("${common[@]}" "${cluster[@]}") ;;
  infra-dev)    tools=("${common[@]}" "${cluster[@]}" terraform az aws gcloud argocd flux hcloud) ;;
  flutter-dev)  tools=("${common[@]}" flutter dart) ;;
  *) echo "Unknown image: $IMAGE" >&2; exit 2 ;;
esac

fail=0
for t in "${tools[@]}"; do
  if command -v "$t" >/dev/null 2>&1; then
    echo "ok   $t -> $(command -v "$t")"
  else
    echo "FAIL $t not found on PATH" >&2
    fail=1
  fi
done

for f in /etc/agent-personas/agents/security.agent.md \
         /etc/agent-personas/rendered/copilot/security.agent.md \
         /etc/agent-personas/rendered/claude/security.md \
         /etc/agent-personas/rendered/codex/security.toml \
         /etc/agent-personas/rendered/skills/agent-personas-setup/SKILL.md; do
  if [ ! -f "$f" ]; then
    echo "FAIL agent persona missing: $f" >&2
    fail=1
  fi
done

# The Claude personas' Bash guard must block writes and allow reads.
guard() { printf '{"tool_input":{"command":"%s"}}' "$1" | agent-personas-guard 2>/dev/null; }
if ! guard 'git diff main' || guard 'rm -rf /tmp/x'; then
  echo "FAIL agent-personas-guard not enforcing read-only" >&2
  fail=1
fi

exit $fail
