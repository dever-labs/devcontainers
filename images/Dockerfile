# Shared base layer for every image except flutter-dev: Node.js, AI CLIs and k3d.
# Stack-specific tooling (dotnet, go, python, ...) is added by devcontainer features
# in each images/<name>/devcontainer.json. Build context is the images/ directory.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04 AS base

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

# infra-dev only (build.target = infra): GitOps and extra cloud CLIs.
FROM base AS infra
ARG ARGOCD_VERSION=v3.5.5
ARG FLUX_VERSION=2.9.6
ARG HCLOUD_VERSION=v1.70.1

RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    WORK=$(mktemp -d); cd "$WORK"; \
    # ArgoCD CLI
    curl -fsSLO "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${ARCH}"; \
    curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/cli_checksums.txt" | grep " argocd-linux-${ARCH}\$" | sha256sum -c; \
    install -m 0755 "argocd-linux-${ARCH}" /usr/local/bin/argocd; \
    # Flux CLI
    curl -fsSLO "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_linux_${ARCH}.tar.gz"; \
    curl -fsSL "https://github.com/fluxcd/flux2/releases/download/v${FLUX_VERSION}/flux_${FLUX_VERSION}_checksums.txt" | grep " flux_${FLUX_VERSION}_linux_${ARCH}.tar.gz\$" | sha256sum -c; \
    tar -xzf "flux_${FLUX_VERSION}_linux_${ARCH}.tar.gz" flux; \
    install -m 0755 flux /usr/local/bin/flux; \
    # Hetzner Cloud CLI
    curl -fsSLO "https://github.com/hetznercloud/cli/releases/download/${HCLOUD_VERSION}/hcloud-linux-${ARCH}.tar.gz"; \
    curl -fsSL "https://github.com/hetznercloud/cli/releases/download/${HCLOUD_VERSION}/checksums.txt" | grep " hcloud-linux-${ARCH}.tar.gz\$" | sha256sum -c; \
    tar -xzf "hcloud-linux-${ARCH}.tar.gz" hcloud; \
    install -m 0755 hcloud /usr/local/bin/hcloud; \
    cd /; rm -rf "$WORK"

# Google Cloud CLI from Google's signed apt repository
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/google-cloud.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
       > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Final stage so every other image builds the plain base layer without specifying a target.
FROM base AS default
