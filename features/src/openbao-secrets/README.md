# openbao-secrets (optional)

Installs the [OpenBao](https://openbao.org) CLI (`bao`, sha256-verified) and `secrets-gh-login`, which logs `gh` in with a GitHub token read from your own OpenBao/Vault server.

Opt-in and generic: no image includes it, and it has no built-in server, mount or path. Configure it from your own `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/dever-labs/devcontainers/features/openbao-secrets:1": {}
  },
  "remoteEnv": {
    "BAO_ADDR": "https://vault.example.com",
    "BAO_SECRET_MOUNT": "secret",
    "BAO_SECRET_PATH": "users/me/github"
  }
}
```

Then run `secrets-gh-login` (or `secrets-gh-login --store` to save a new token first). Optional: `BAO_SECRET_FIELD` (default `token`), `BAO_LOGIN_ARGS` (default `-method=oidc`). Credentials land in the shared `dever-labs-gh-config` volume like a normal `gh auth login`.

Notes:
- `--store` uses `bao kv put`, which replaces the whole secret at that path; use a path dedicated to this token.
- No browser runs in the container. OIDC login (default `-method=oidc skip_browser=true`) prints a URL: open it in your host browser. The callback goes to `localhost:8250`, which VS Code forwards to the container automatically; if you use another client, forward port 8250 yourself. Use `BAO_LOGIN_ARGS` for other auth methods.
- The OpenBao session token is kept in the shared `dever-labs-bao-session` volume (`~/.vault-token` links into it), so it survives rebuilds until its TTL ends. The GitHub token is never written into the image.
