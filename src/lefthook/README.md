# Lefthook Feature for Dev Containers

This feature installs Lefthook, a fast and powerful Git hooks manager.

Options

- `VERSION`: Lefthook version to install (default: latest)

Usage

In your `devcontainer.json`, add:

```json
"features": {
  "ghcr.io/cloudcalvin/devcontainer-features/lefthook:latest": {
    "VERSION": "latest"
  }
}
```
