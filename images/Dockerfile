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

# Mount points for the shared credential volumes (see images/*/devcontainer.json). A named
# volume is seeded from the image directory on first use, so creating them here owned by
# vscode keeps a fresh volume writable; without it Docker creates it root-owned.
RUN install -d -o vscode -g vscode /home/vscode/.config /home/vscode/.config/gh \
      /home/vscode/.copilot /home/vscode/.claude

# Keep all Claude Code state, including ~/.claude.json, in the dever-labs-claude volume. Set as
# an image ENV (not remoteEnv) so it also applies to `docker exec` and other non-IDE processes.
ENV CLAUDE_CONFIG_DIR=/home/vscode/.claude

# infra-dev only (build.target = infra): GitOps, Kubernetes manifest tooling and extra cloud CLIs.
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

# Kubernetes manifest tooling: standalone kustomize, k9s, kubelogin (kubectl oidc-login) and yamllint.
# renovate: datasource=github-releases depName=kubernetes-sigs/kustomize extractVersion=^kustomize/v(?<version>.+)$
ARG KUSTOMIZE_VERSION=5.8.3
# renovate: datasource=github-releases depName=derailed/k9s extractVersion=^v(?<version>.+)$
ARG K9S_VERSION=0.51.0
# renovate: datasource=github-releases depName=int128/kubelogin extractVersion=^v(?<version>.+)$
ARG KUBELOGIN_VERSION=1.36.4
# renovate: datasource=pypi depName=yamllint
ARG YAMLLINT_VERSION=1.38.0

RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    WORK=$(mktemp -d); cd "$WORK"; \
    # kustomize
    base="https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}"; \
    f="kustomize_v${KUSTOMIZE_VERSION}_linux_${ARCH}.tar.gz"; \
    curl -fsSLO "$base/$f"; \
    curl -fsSL "$base/checksums.txt" | grep " $f\$" | sha256sum -c; \
    tar -xzf "$f" kustomize; \
    install -m 0755 kustomize /usr/local/bin/kustomize; \
    # k9s
    base="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}"; \
    f="k9s_Linux_${ARCH}.tar.gz"; \
    curl -fsSLO "$base/$f"; \
    curl -fsSL "$base/checksums.sha256" | grep " $f\$" | sha256sum -c; \
    tar -xzf "$f" k9s; \
    install -m 0755 k9s /usr/local/bin/k9s; \
    # kubelogin, installed as the kubectl oidc-login plugin
    base="https://github.com/int128/kubelogin/releases/download/v${KUBELOGIN_VERSION}"; \
    f="kubelogin_linux_${ARCH}.zip"; \
    curl -fsSLO "$base/$f"; \
    curl -fsSLO "$base/$f.sha256"; \
    sha256sum -c "$f.sha256"; \
    unzip -q "$f" kubelogin; \
    install -m 0755 kubelogin /usr/local/bin/kubectl-oidc_login; \
    cd /; rm -rf "$WORK"

# yamllint in its own venv (Ubuntu 24.04 blocks global pip installs)
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3-venv \
    && rm -rf /var/lib/apt/lists/* \
    && python3 -m venv /opt/yamllint \
    && /opt/yamllint/bin/pip install --no-cache-dir "yamllint==${YAMLLINT_VERSION}" \
    && ln -sf /opt/yamllint/bin/yamllint /usr/local/bin/yamllint

# Google Cloud CLI from Google's signed apt repository
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/google-cloud.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/google-cloud.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
       > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends google-cloud-cli \
    && rm -rf /var/lib/apt/lists/*

# Final stage so every other image builds the plain base layer without specifying a target.
FROM base AS default
