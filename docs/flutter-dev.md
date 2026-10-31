# flutter-dev

Pre-built devcontainer for Flutter applications — iOS, Android, Web, Linux, macOS, and Windows targets from a single Dart codebase. This image builds **Android, Web and Linux** targets (see the note below for the others). Works for both human developers and AI coding agents.

> **Platform note**: iOS and macOS builds require macOS, and Windows builds require Windows, so none of them can run in this Linux container. Use a macOS GitHub Actions runner for iOS CI builds. All other targets (Android, Web, Linux) build fine inside the container.

## What's included

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.41.9 (stable) | Framework + Dart SDK + toolchain |
| Dart SDK | (bundled with Flutter) | Language runtime |
| Node.js | 26 | Required for the Copilot CLI and Claude Code CLI (pinned in `images/flutter-dev/Dockerfile`) |
| git | latest | Source control |
| GitHub CLI (`gh`) | 2.92 (patch auto-updates) | PRs, issues, releases, Actions |

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

- GitHub auth comes from the shared `dever-labs-gh-config` volume: run `gh auth login` once ([docs/github-auth.md](github-auth.md)).
- Claude Code and Copilot extensions are pre-installed.
- Agents can run `flutter test`, `flutter build`, `flutter analyze` without leaving the container.
- The `flutter-pub-cache` volume keeps pub packages across rebuilds, speeding up agent workflows.

## Updating Flutter

Edit `images/flutter-dev/Dockerfile` in a pull request:

```dockerfile
ARG FLUTTER_VERSION=3.41.9
ARG FLUTTER_CHANNEL=stable
```

Once merged, CI rebuilds the image and all service repos pick it up on their next rebuild.
