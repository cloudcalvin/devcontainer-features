# Persistent Config

Persist selected home-relative directories in host-visible locations.

This feature does not use Docker volumes and does not mount the host home directory.

- `scope: "workspace"` stores selected directories in the project checkout, such as `/workspace/.codex`.
- `scope: "user"` stores selected directories under `${localEnv:HOME}/.devcontainer-persistent-config`, mounted at `/mnt/persistent-config-user-root`.

In both modes, the container home paths are symlinked to the selected storage root.

## Example Usage

Workspace-backed project state:

```jsonc
"features": {
    "ghcr.io/cloudcalvin/devcontainer-features/persistent-config:latest": {
        "scope": "workspace",
        "dirs": ".codex,.claude,.config/gh"
    }
}
```

User-backed state:

```jsonc
"features": {
    "ghcr.io/cloudcalvin/devcontainer-features/persistent-config:latest": {
        "scope": "user",
        "dirs": ".codex .claude .config/gh"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| scope | Persistence scope. `workspace` stores in `/workspace`; `user` stores in `${localEnv:HOME}/.devcontainer-persistent-config`. | string | workspace |
| dirs | Comma or whitespace separated home-relative directories to persist. | string | empty |

## Path Mapping

For each entry in `dirs`, the feature creates this symlink:

| Scope | Container symlink | Storage target |
|-----|-----|-----|
| `workspace` | `$HOME/<dir>` | `/workspace/<dir>` |
| `user` | `$HOME/<dir>` | `/mnt/persistent-config-user-root/<dir>` |

Examples:

| `dirs` entry | Workspace scope storage | User scope storage |
|-----|-----|-----|
| `.codex` | `/workspace/.codex` | `${localEnv:HOME}/.devcontainer-persistent-config/.codex` |
| `.config/gh` | `/workspace/.config/gh` | `${localEnv:HOME}/.devcontainer-persistent-config/.config/gh` |

If a managed container path already exists and is not a symlink, the feature moves it aside with a `.persistent-config-backup-<timestamp>` suffix before creating the symlink.

`dirs` entries must be relative paths. Absolute paths, parent-directory traversal, `~`, `:`, and repeated slashes are rejected.

If `${localEnv:HOME}/.devcontainer-persistent-config` does not exist before the container is created, Docker may create it as root-owned. The feature attempts to fix ownership and user write permissions on the mounted storage root during `onCreateCommand` and `postStartCommand`.
