#!/usr/bin/env bash
# Smoke test for a built devcontainer image: verifies the expected tools are on PATH.
# Usage: smoke-test.sh <image-name>   (e.g. dotnet-dev)
set -uo pipefail

IMAGE="${1:?usage: smoke-test.sh <image-name>}"

common=(git gh node npm copilot claude)
cluster=(docker kubectl helm k3d k3d-cluster-init)

case "$IMAGE" in
  dotnet-dev)   tools=("${common[@]}" "${cluster[@]}" dotnet) ;;
  go-dev)       tools=("${common[@]}" "${cluster[@]}" go) ;;
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

if [ ! -f /etc/agent-personas/agents/security.agent.md ]; then
  echo "FAIL agent personas not installed" >&2
  fail=1
fi

exit $fail
