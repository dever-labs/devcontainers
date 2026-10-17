# Shared base layer for every image except flutter-dev: Node.js, AI CLIs and k3d.
# Stack-specific tooling (dotnet, go, python, ...) is added by devcontainer features
# in each images/<name>/devcontainer.json. Build context is the images/ directory.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Pinned for reproducible builds — bump deliberately (a bad upstream release must not
# reach every repo on the next rebuild).
ARG NODE_MAJOR=26
ARG COPILOT_CLI_VERSION=1.0.98
ARG CLAUDE_CODE_VERSION=2.1.302
ARG K3D_VERSION=v5.8.3
ARG K3D_SHA256_AMD64=dbaa79a76ace7f4ca230a1ff41dc7d8a5036a8ad0309e9c54f9bf3836dbe853e
ARG K3D_SHA256_ARM64=0b8110f2229631af7402fb828259330985918b08fefd38b7f1b788a1c8687216

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g "@github/copilot@${COPILOT_CLI_VERSION}" "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
    && ln -sf "$(npm prefix -g)/bin/copilot" /usr/local/bin/copilot \
    && ln -sf "$(npm prefix -g)/bin/claude" /usr/local/bin/claude \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    case "$ARCH" in \
      amd64) K3D_SHA256="${K3D_SHA256_AMD64}" ;; \
      arm64) K3D_SHA256="${K3D_SHA256_ARM64}" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/k3d \
      "https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-${ARCH}"; \
    echo "${K3D_SHA256}  /usr/local/bin/k3d" | sha256sum -c; \
    chmod +x /usr/local/bin/k3d

COPY scripts/k3d-cluster-init /usr/local/bin/k3d-cluster-init
RUN chmod +x /usr/local/bin/k3d-cluster-init
