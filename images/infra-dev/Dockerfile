FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_26.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g @github/copilot @anthropic-ai/claude-code \
    && ln -sf "$(npm prefix -g)/bin/copilot" /usr/local/bin/copilot \
    && ln -sf "$(npm prefix -g)/bin/claude" /usr/local/bin/claude \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    ARCH=$(dpkg --print-architecture); \
    case "$ARCH" in \
      amd64) K3D_SHA256="dbaa79a76ace7f4ca230a1ff41dc7d8a5036a8ad0309e9c54f9bf3836dbe853e" ;; \
      arm64) K3D_SHA256="0b8110f2229631af7402fb828259330985918b08fefd38b7f1b788a1c8687216" ;; \
      *) echo "Unsupported architecture: $ARCH" && exit 1 ;; \
    esac; \
    curl -fsSL -o /usr/local/bin/k3d \
      "https://github.com/k3d-io/k3d/releases/download/v5.8.3/k3d-linux-${ARCH}"; \
    echo "${K3D_SHA256}  /usr/local/bin/k3d" | sha256sum -c; \
    chmod +x /usr/local/bin/k3d

COPY scripts/k3d-cluster-init /usr/local/bin/k3d-cluster-init
RUN chmod +x /usr/local/bin/k3d-cluster-init
