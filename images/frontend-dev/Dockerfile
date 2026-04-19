FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Copy openclaw CLI from the official image.
# The wrapper script calls `node /opt/openclaw/app/openclaw.mjs` — we need both the
# app bundle and the wrapper so `openclaw node run` works inside k8s devcontainer pods.
COPY --from=coollabsio/openclaw:latest /opt/openclaw /opt/openclaw
COPY --from=coollabsio/openclaw:latest /usr/local/bin/openclaw /usr/local/bin/openclaw
