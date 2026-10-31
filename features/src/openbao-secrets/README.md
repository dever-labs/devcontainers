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
