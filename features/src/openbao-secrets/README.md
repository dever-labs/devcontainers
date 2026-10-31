# openbao-secrets (optional)

Installs the [OpenBao](https://openbao.org) CLI (`bao`, sha256-verified) and `secrets-gh-login`, which logs `gh` in with a GitHub token read from your own OpenBao/Vault server.

Opt-in and generic: no image includes it, and it has no built-in server, issuer or path. Configure it from your own `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/dever-labs/devcontainers/features/openbao-secrets:1": {}
  },
  "remoteEnv": {
    "OIDC_ISSUER": "https://idp.example.com/realms/example",
    "OIDC_CLIENT_ID": "devcontainers",
    "BAO_ADDR": "https://vault.example.com",
    "BAO_JWT_ROLE": "devcontainers",
    "BAO_SECRET_MOUNT": "secret",
    "BAO_SECRET_PATH": "users/me/github"
  }
}
```

## How sign-in works

- On every container start (`postStartCommand`) it runs `secrets-gh-login --auto`: nothing happens if `gh` is already logged in or the env vars are unset.
- Sign-in uses the OIDC **device-code flow**: it prints a URL and a code, you approve on any device. No browser or open port is needed in the container.
- The refresh token is kept in the shared `dever-labs-bao-session` volume (`~/.bao-session`, mode 700), the same volume in every container that uses the feature. After you sign in once, **every other devcontainer re-authenticates silently** until the refresh token expires. A lock serialises containers starting at the same time so rotated refresh tokens are not reused.
- The OpenBao token is kept in memory only; the GitHub token goes to the shared `gh` volume.
- If sign-in is needed and no terminal is available, it prints a hint and exits 0 (it never blocks container start). Run `secrets-gh-login` in a terminal; use `secrets-gh-login --store` to save a new GitHub token first (`bao kv put` replaces the whole secret, so use a dedicated path).

Optional: `BAO_SECRET_FIELD` (default `token`), `BAO_JWT_MOUNT` (default `jwt`), `OIDC_SCOPE` (default `openid offline_access`).

## Server prerequisites (yours to set up)

- An OIDC client for the issuer: public (no secret), device-code grant enabled, `offline_access` allowed.
- A JWT auth method in OpenBao trusting that issuer, with a role (`BAO_JWT_ROLE`) whose policy lets each user read/write only their own secret path.
