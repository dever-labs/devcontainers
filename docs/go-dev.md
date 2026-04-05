# go-dev

Pre-built devcontainer for Go projects — microservices, CLIs, Kubernetes operators, and gRPC services. Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Go | latest | Runtime, compiler, toolchain |
| Docker-in-Docker | latest | Build images, run containers inside the devcontainer |
| kubectl | latest | Deploy to and inspect Kubernetes clusters |
| Helm | latest | Install and manage Helm charts |
| minikube | latest | Local Kubernetes cluster (auto-started on container start) |
| git | latest | Source control |
| GitHub CLI (`gh`) | latest | PRs, issues, releases, Actions |
| openclaw.ai | latest | AI agent tooling (installed on create) |

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `golang.go` | Full Go toolchain: IntelliSense, debugging, test runner, gopls |

## Use cases

### HTTP microservice

```jsonc
// .devcontainer/devcontainer.json in your service repo
{
  "name": "my-service",
  "image": "ghcr.io/dever-labs/devcontainers/go-dev:latest",
  "forwardPorts": [8080],
  "portsAttributes": {
    "8080": { "label": "HTTP" }
  },
  "postCreateCommand": "go mod download"
}
```

Run with live reload using `air`:

```bash
go install github.com/air-verse/air@latest
air
```

### gRPC service

```jsonc
{
  "name": "my-grpc-service",
  "image": "ghcr.io/dever-labs/devcontainers/go-dev:latest",
  "forwardPorts": [50051],
  "postCreateCommand": "go mod download && go install google.golang.org/protobuf/cmd/protoc-gen-go@latest && go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest"
}
```

### Kubernetes operator

minikube starts automatically. Build and load your operator image directly:

```bash
docker build -t my-operator:local .
minikube image load my-operator:local
kubectl apply -f config/
```

### CLI tool

```bash
go build -o bin/mycli ./cmd/mycli
./bin/mycli --help
```

### Running tests

```bash
go test ./...
# with race detector and coverage
go test -race -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### AI agent use (Copilot coding agent / Claude Code)

- `GITHUB_TOKEN` is forwarded so `gh` and git work without prompts.
- `golang.go` extension gives agents precise symbol resolution and type info via gopls.
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `go test ./...`, build binaries, and deploy to minikube without leaving the container.

## Updating Go

Edit `images/go-dev/devcontainer.json`:

```jsonc
"ghcr.io/devcontainers/features/go:1": {
  "version": "1.24"   // pin to major.minor, or keep "latest"
}
```

Push to `main` — all service repos pick it up on next rebuild.
