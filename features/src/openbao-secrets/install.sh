#!/usr/bin/env bash
set -euo pipefail

VERSION="${VERSION:-2.7.2}"
ARCH="$(dpkg --print-architecture)"
case "$ARCH" in amd64|arm64) ;; *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; esac

apt-get update
apt-get install -y --no-install-recommends ca-certificates curl jq
rm -rf /var/lib/apt/lists/*

WORK="$(mktemp -d)"; cd "$WORK"
TARBALL="openbao_${VERSION}_linux_${ARCH}.tar.gz"
BASE="https://github.com/openbao/openbao/releases/download/v${VERSION}"
curl -fsSLO "${BASE}/${TARBALL}"
curl -fsSL "${BASE}/checksums.txt" | grep " ${TARBALL}\$" | sha256sum -c
tar -xzf "$TARBALL" bao
install -m 0755 bao /usr/local/bin/bao
cd /; rm -rf "$WORK"

install -m 0755 "$(dirname "$0")/secrets-gh-login" /usr/local/bin/secrets-gh-login
echo "==> Installed bao ${VERSION} and secrets-gh-login"
