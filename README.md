# devcontainers

Centralised devcontainer images for dever-labs. All service repos reference images from here — no per-repo builds.

## Images

| Image | Contents | Used by |
|-------|----------|---------|
| [`dotnet-service`](images/dotnet-service/) | .NET 10 SDK, Docker-in-Docker, kubectl, Helm, minikube, git, GitHub CLI | All .NET service repos |
| [`frontend`](images/frontend/) | Node.js LTS, Docker-in-Docker, kubectl, Helm, minikube, git, GitHub CLI | React/Vue/Angular SPA repos |
| [`python-service`](images/python-service/) | Python 3.13, uv, Docker-in-Docker, kubectl, Helm, minikube, git, GitHub CLI | Python API and data script repos |
| [`go-service`](images/go-service/) | Go latest, Docker-in-Docker, kubectl, Helm, minikube, git, GitHub CLI | Go microservice and CLI repos |
| [`infra`](images/infra/) | Terraform, Azure CLI, Docker-in-Docker, kubectl, Helm, minikube, git, GitHub CLI | Infrastructure and platform repos |

## How it works

```
images/dotnet-service/devcontainer.json   ← defines base + features
         │
         ▼ (CI builds on push to main)
ghcr.io/dever-labs/devcontainers/dotnet-service:latest
         │
         ▼ (service repos reference)
.devcontainer/devcontainer.json → "image": "ghcr.io/dever-labs/devcontainers/dotnet-service:latest"
```

CI rebuilds only the image(s) whose folder changed. Each push to `main` that touches `images/dotnet-service/**` triggers a fresh build with layer caching.

## Adding a new image

1. Create `images/<name>/devcontainer.json` with the base image and features
2. Add a filter entry in `.github/workflows/build.yml` under `changes`
3. Push to `main` — CI builds and pushes `ghcr.io/dever-labs/devcontainers/<name>:latest`
4. Make the package public: GitHub → Packages → `<name>` → Package settings → Make public

## Updating an existing image

Edit `images/<name>/devcontainer.json` and push to `main`. All repos using the image pick up the change on their next container rebuild — no changes needed in service repos.

## Making packages public

After the first build, make each package public so developers can pull without authenticating:

**GitHub → org → Packages → select image → Package settings → Change visibility → Public**
