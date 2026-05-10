FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Copy openclaw CLI from the official image.
# The wrapper script calls `node /opt/openclaw/app/openclaw.mjs` — we need both the
# app bundle and the wrapper so `openclaw node run` works inside k8s devcontainer pods.
COPY --from=coollabsio/openclaw:2026.5 /opt/openclaw /opt/openclaw
COPY --from=coollabsio/openclaw:2026.5 /usr/local/bin/openclaw /usr/local/bin/openclaw

COPY scripts/k3d-cluster-init /usr/local/bin/k3d-cluster-init
RUN chmod +x /usr/local/bin/k3d-cluster-init
