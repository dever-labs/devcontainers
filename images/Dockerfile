# Shared base layer for every image except flutter-dev: Node.js, AI CLIs and k3d.
# Stack-specific tooling (dotnet, go, python, ...) is added by devcontainer features
# in each images/<name>/devcontainer.json. Build context is the images/ directory.
FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04 AS base

# Pinned for reproducible builds. Renovate (renovate.json) opens PRs for the annotated
# versions below, so a bad upstream release only lands after CI passes and a human merges.
# NODE_MAJOR is bumped by hand: only even-numbered (LTS) majors should be adopted.
ARG NODE_MAJOR=26
# renovate: datasource=npm depName=@github/copilot
ARG COPILOT_CLI_VERSION=1.0.98
# renovate: datasource=npm depName=@anthropic-ai/claude-code
ARG CLAUDE_CODE_VERSION=2.1.302
# renovate: datasource=github-releases depName=k3d-io/k3d
ARG K3D_VERSION=v5.8.3
# renovate: datasource=github-releases depName=openbao/openbao extractVersion=^v(?<version>.+)$
ARG BAO_VERSION=2.7.2

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
    case "$ARCH" in amd64|arm64) ;; *) echo "Unsupported architecture: $ARCH" && exit 1 ;; esac; \
    curl -fsSL -o /usr/local/bin/k3d \
      "https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-${ARCH}"; \
    K3D_SHA256=$(curl -fsSL "https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/checksums.txt" \
      | awk -v f="_dist/k3d-linux-${ARCH}" '$2 == f { print $1 }'); \
    test -n "${K3D_SHA256}"; \
    echo "${K3D_SHA256}  /usr/local/bin/k3d" | sha256sum -c; \
    chmod +x /usr/local/bin/k3d

COPY scripts/k3d-cluster-init /usr/local/bin/k3d-cluster-init
RUN chmod +x /usr/local/bin/k3d-cluster-init

# OpenBao CLI + dever-gh-login: GitHub tokens live in OpenBao (vault.dever.dk), not in host env vars.
RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    case "$ARCH" in amd64|arm64) ;; *) echo "Unsupported architecture: $ARCH" && exit 1 ;; esac; \
    apt-get update && apt-get install -y --no-install-recommends jq && rm -rf /var/lib/apt/lists/*; \
    WORK=$(mktemp -d); cd "$WORK"; \
    curl -fsSLO "https://github.com/openbao/openbao/releases/download/v${BAO_VERSION}/openbao_${BAO_VERSION}_linux_${ARCH}.tar.gz"; \
    curl -fsSL "https://github.com/openbao/openbao/releases/download/v${BAO_VERSION}/checksums.txt" \
      | grep " openbao_${BAO_VERSION}_linux_${ARCH}.tar.gz\$" | sha256sum -c; \
    tar -xzf "openbao_${BAO_VERSION}_linux_${ARCH}.tar.gz" bao; \
    install -m 0755 bao /usr/local/bin/bao; \
    cd /; rm -rf "$WORK"

COPY scripts/dever-gh-login /usr/local/bin/dever-gh-login
RUN chmod +x /usr/local/bin/dever-gh-login

# infra-dev only (build.target = infra): GitOps and extra cloud CLIs.
FROM base AS infra
# renovate: datasource=github-releases depName=argoproj/argo-cd
ARG ARGOCD_VERSION=v3.5.5
# renovate: datasource=github-releases depName=fluxcd/flux2 extractVersion=^v(?<version>.+)$
ARG FLUX_VERSION=2.9.6
# renovate: datasource=github-releases depName=hetznercloud/cli
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
