# rust-dev

Pre-built devcontainer for Rust projects — services, CLIs, and gateways (e.g. `routly`). Works for both human developers and AI coding agents.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Rust | latest stable (rustup) | `cargo`, `rustc`, `clippy`, `rustfmt` (default profile) |
| Docker-outside-of-Docker | latest | Build images and run containers via the host Docker socket |
| kubectl | 1.36 | Deploy to and inspect Kubernetes clusters |
| Helm | 4.1 (patch auto-updates) | Install and manage Helm charts |
| k3d | 5.8.3 (pinned in `images/Dockerfile`) | Local Kubernetes cluster — start it with `k3d-cluster-init` |
| git | latest | Source control |
| GitHub CLI (`gh`) | 2.92 (patch auto-updates) | PRs, issues, releases, Actions |

Plus the shared base: Node.js, GitHub Copilot CLI, Claude Code, the `agent-personas` review agents, and `devx`.

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `rust-lang.rust-analyzer` | Full Rust IntelliSense, inline diagnostics, debugging, test runner |
| `tamasfe.even-better-toml` | `Cargo.toml` / config TOML support |

## Use cases

### HTTP service (axum)

```jsonc
// .devcontainer/devcontainer.json in your service repo
{
  "name": "my-service",
  "image": "ghcr.io/dever-labs/devcontainers/rust-dev:latest",
  "forwardPorts": [4000],
  "portsAttributes": { "4000": { "label": "HTTP" } },
  "postCreateCommand": "cargo fetch"
}
```

Run with live reload using `cargo-watch`:

```bash
cargo install cargo-watch
cargo watch -x run
```

### Service with Postgres + Valkey (via k3d or docker)

With a k3d cluster running (`"postStartCommand": "k3d-cluster-init"` in your repo's `devcontainer.json`),
stand up dependencies and test your chart in-cluster:

```bash
# dependencies for local dev
docker run -d --name pg    -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres:17
docker run -d --name valkey -p 6379:6379 valkey/valkey:8

# or build + import your image and deploy the chart
docker build -t my-service:local .
k3d image import my-service:local -c devcontainer
helm upgrade --install my-service charts/my-service
```

### Database migrations (sqlx)

```bash
cargo install sqlx-cli --no-default-features --features postgres
export DATABASE_URL=postgres://postgres:dev@localhost:5432/postgres
sqlx migrate run
cargo sqlx prepare          # refresh the offline query cache (.sqlx/) for CI
```

### Building, linting, testing

```bash
cargo build --release
cargo fmt --all --check
cargo clippy --workspace --all-targets -- -D warnings
cargo test --workspace --locked
```

### AI agent use (Copilot coding agent / Claude Code)

- GitHub auth comes from the shared `dever-labs-gh-config` volume: run `gh auth login` once ([docs/github-auth.md](github-auth.md)).
- `rust-lang.rust-analyzer` gives agents precise symbol resolution and type info.
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `cargo test`, build binaries, and deploy to the local k3d cluster without leaving the container.

## Updating Rust

Edit `images/rust-dev/devcontainer.json`:

```jsonc
"ghcr.io/devcontainers/features/rust:1": {
  "version": "latest",   // or pin a specific stable version, e.g. "1.90"
  "profile": "default"
}
```

Push to `main` — all service repos pick it up on next rebuild.
