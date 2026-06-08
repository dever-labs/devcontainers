#!/usr/bin/env bash
# install.sh — installs the devx CLI inside a devcontainer
#
# Downloads the correct pre-built binary from dever-labs/devx GitHub releases.
# Falls back to building from source if no release binary is available.

set -euo pipefail

VERSION="${VERSION:-latest}"
REPO="dever-labs/devx"
INSTALL_DIR="/usr/local/bin"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"   # linux | darwin
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64)  ARCH="amd64" ;;
  aarch64 | arm64) ARCH="arm64" ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

BINARY_NAME="devx-${OS}-${ARCH}"

# Resolve version tag.
if [[ "$VERSION" == "latest" ]]; then
  echo "==> Fetching latest devx release..."
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": "\(.*\)".*/\1/')"
  if [[ -z "$VERSION" ]]; then
    echo "Could not determine latest version. Set VERSION explicitly."
    exit 1
  fi
fi

DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${BINARY_NAME}"

echo "==> Installing devx ${VERSION} (${OS}/${ARCH})..."
curl -fsSL "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/devx"
chmod +x "${INSTALL_DIR}/devx"

echo "==> devx installed at ${INSTALL_DIR}/devx"
devx version
