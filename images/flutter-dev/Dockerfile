FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Copy openclaw CLI from the official image.
# The wrapper script calls `node /opt/openclaw/app/openclaw.mjs` — we need both the
# app bundle and the wrapper so `openclaw node run` works inside k8s devcontainer pods.
COPY --from=coollabsio/openclaw:latest /opt/openclaw /opt/openclaw
COPY --from=coollabsio/openclaw:latest /usr/local/bin/openclaw /usr/local/bin/openclaw

# Install Flutter SDK directly — avoids relying on the devcontainers-contrib community
# feature registry which is not reliably accessible from CI runners.
ARG FLUTTER_VERSION=3.29.3
ARG FLUTTER_CHANNEL=stable

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
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
