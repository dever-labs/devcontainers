# flutter-dev

Pre-built devcontainer for Flutter applications — iOS, Android, Web, Linux, macOS, and Windows targets from a single Dart codebase. Works for both human developers and AI coding agents.

> **iOS note**: iOS builds require macOS and cannot run inside this Linux container. Use a macOS GitHub Actions runner for iOS CI builds. All other targets (Android, Web, Linux) build fine inside the container.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | stable | Framework + Dart SDK + toolchain |
| Dart SDK | (bundled with Flutter) | Language runtime |
| Node.js | LTS | Required for Claude Code CLI |
| git | latest | Source control |
| GitHub CLI (`gh`) | latest | PRs, issues, releases, Actions |
| openclaw.ai | latest | AI agent tooling (installed on create) |

## VS Code extensions

| Extension | Purpose |
|-----------|---------|
| `github.copilot` | AI completions |
| `github.copilot-chat` | AI chat and inline edits |
| `anthropics.claude-code` | Claude Code agent |
| `dart-code.flutter` | Flutter tooling, hot reload, device management |
| `dart-code.dart-code` | Dart language support, analysis, formatting |

## Use cases

### Flutter app (Web + Linux targets)

```jsonc
// .devcontainer/devcontainer.json in your Flutter service repo
{
  "name": "my-flutter-app",
  "image": "ghcr.io/dever-labs/devcontainers/flutter-dev:latest",
  "forwardPorts": [8080],
  "portsAttributes": {
    "8080": { "label": "Flutter web", "onAutoForward": "openBrowser" }
  },
  "postAttachCommand": "flutter pub get"
}
```

### Running Flutter web in the container

```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```

Forward port 8080 to open in your host browser.

### Running Flutter tests

```bash
flutter test                          # unit + widget tests
flutter test --platform chrome        # web integration tests (Chrome required)
```

### Android builds (APK / AAB)

The container includes the Flutter SDK. For Android builds, Flutter will download
the Android SDK on first `flutter build apk`. To persist the SDK across rebuilds,
add a volume mount to your service repo's `devcontainer.json`:

```jsonc
{
  "mounts": [
    "source=android-sdk-cache,target=/home/vscode/Android,type=volume"
  ],
  "postAttachCommand": "flutter pub get"
}
```

### AI agent use (Copilot coding agent / Claude Code)

- `GITHUB_TOKEN` is forwarded so `gh` and git work without prompts.
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `flutter test`, `flutter build`, `flutter analyze` without leaving the container.
- The `flutter-pub-cache` volume keeps pub packages across rebuilds, speeding up agent workflows.

## Updating Flutter

Edit `images/flutter-dev/devcontainer.json`:

```jsonc
"ghcr.io/devcontainers-contrib/features/flutter:1": {
  "channel": "stable"   // or "beta" / "master"
}
```

Push to `main` — all service repos pick it up on next rebuild.
