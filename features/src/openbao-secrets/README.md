# openbao-secrets (optional)

Installs the [OpenBao](https://openbao.org) CLI (`bao`, sha256-verified) and `secrets-gh-login`, which logs `gh` in with a GitHub token read from your own OpenBao/Vault server.

Opt-in and generic: no image includes it, and it has no built-in server, role or path. Configure it from your own `devcontainer.json`:

```jsonc
{
  "features": {
    "ghcr.io/dever-labs/devcontainers/features/openbao-secrets:2": {}
  },
  "remoteEnv": {
    "BAO_ADDR": "https://vault.example.com",
    "BAO_OIDC_ROLE": "devcontainers",
    "BAO_SECRET_MOUNT": "secret",
    "BAO_SECRET_PATH": "users/me/github"
  }
}
```

Optional: `BAO_SECRET_FIELD` (default `token`), `BAO_OIDC_MOUNT` (default `oidc`), `BAO_OIDC_PORT` (local callback port, default `8250`). Without `BAO_OIDC_ROLE` the auth method's `default_role` is used.

## How sign-in works

- `secrets-gh-login` runs `bao login -method=oidc` in client callback mode. The CLI listens on `localhost:8250` in the container. The browser opens your identity provider, and the provider sends you back to that port, which VS Code forwards from the container.
- If you're already signed in to the identity provider in that browser, this is a redirect without a password prompt. That's what makes sign-in "once": the session lives in your browser, not in the container.
- The OpenBao token is printed straight into the script (`-token-only`). It never reaches a token helper or `~/.vault-token`, and it's revoked when the script ends. No identity-provider token is requested or kept.
- At container start (`postStartCommand`), `secrets-gh-login --auto` never prompts and never blocks. If `gh` isn't logged in, it tells you to run `secrets-gh-login`.
- `secrets-gh-login --store` saves a new GitHub token first. `bao kv put` replaces the whole secret, so use a dedicated path.

**Where it works:** anywhere the editor forwards `localhost` ports from the container to your machine, such as VS Code desktop, including desktop attached to a Codespace. The browser editor in Codespaces can't receive the callback.

**Deliberately not supported:** the device-code flow and OpenBao's `callbackmode=direct`/`device`. In those flows a login started by one person can be completed by another, which is how sign-ins get phished. They aren't needed when the browser is on the same machine as the editor.

**The GitHub token:** `gh auth login` stores it where `gh` keeps its credentials. Without a keyring that's `~/.config/gh/hosts.yml`, in plaintext. If that folder is a volume shared between containers (the `local-ai` feature mounts one), every container using that volume can read the token. Use a fine-grained token with short expiry, scoped to what you need in containers.

## Server prerequisites (yours to set up)

- The OIDC auth method enabled in OpenBao (`bao auth enable oidc`), configured with your identity provider.
- A role (`BAO_OIDC_ROLE`, or the method's `default_role`):
  - `allowed_redirect_uris` must include `http://localhost:8250/oidc/callback`, or the port you set in `BAO_OIDC_PORT`;
  - a short `token_ttl`;
  - a policy that lets each user read and write only their own secret path. Use a templated policy, e.g. `secret/data/users/{{identity.entity.name}}/github`.
- The OIDC client at the identity provider: the standard (authorization code) flow, and a redirect to OpenBao's callback. No device-code grant.

## Upgrading from 1.x

1.x signed in with the device-code flow against the identity provider directly, and kept a refresh token in the shared `dever-labs-bao-session` volume. 2.x drops both:

- `OIDC_ISSUER`, `OIDC_CLIENT_ID`, `OIDC_SCOPE`, `BAO_JWT_ROLE` and `BAO_JWT_MOUNT` are no longer read. Set `BAO_OIDC_ROLE`, plus `BAO_OIDC_MOUNT` if your OIDC method isn't at `oidc`.
- The server needs an OIDC role (above) instead of a JWT role.
- Remove the old volume, which still holds a refresh token, by revoking that session at the identity provider and running `docker volume rm dever-labs-bao-session`.
