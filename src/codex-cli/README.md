# Codex CLI Feature for Dev Containers

This feature installs OpenAI Codex CLI.

## Options

- `VERSION`: Codex CLI version (default: `latest`).

## Usage

In your `devcontainer.json`, add:

```json
"features": {
  "ghcr.io/cloudcalvin/devcontainer-features/codex-cli:latest": {
    "VERSION": "latest"
  }
},
"remoteEnv": {
  "OPENAI_API_KEY": "${localEnv:OPENAI_API_KEY}"
}
```
