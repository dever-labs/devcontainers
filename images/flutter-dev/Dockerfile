FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install Flutter SDK directly — avoids relying on the devcontainers-contrib community
# feature registry which is not reliably accessible from CI runners.
ARG FLUTTER_VERSION=3.41.9
ARG FLUTTER_CHANNEL=stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    libstdc++-12-dev \
    && mkdir -p /etc/apt/keyrings \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
       | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_26.x nodistro main" \
       > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g @github/copilot @anthropic-ai/claude-code \
    && ln -sf "$(npm prefix -g)/bin/copilot" /usr/local/bin/copilot \
    && ln -sf "$(npm prefix -g)/bin/claude" /usr/local/bin/claude \
    && rm -rf /var/lib/apt/lists/*

# Download and install Flutter as the vscode user
USER vscode
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} \
    https://github.com/flutter/flutter.git /home/vscode/flutter

ENV PATH="/home/vscode/flutter/bin:/home/vscode/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-warm Flutter tool + web/linux artifacts so first use is fast
RUN flutter config --no-analytics \
    && flutter precache --web --linux \
    && flutter --version

USER root
