# DevContainer CLI Troubleshooting

Common errors, anti-patterns, and fixes when using the `@devcontainers/cli`.

## Common Error Messages

| Error | Cause | Fix |
| :--- | :--- | :--- |
| `Cannot connect to Docker daemon` | Docker is not running or socket is blocked. | Start Docker Desktop/OrbStack or check `DOCKER_HOST`. |
| `Missing devcontainer.json` | The CLI cannot find a config in the `--workspace-folder`. | Ensure `.devcontainer/devcontainer.json` exists in the target. |
| `Command not found` (inside container) | Dependency not installed in the image/hooks. | Use `onCreateCommand` or add a Dev Container Feature. |
| `Permission denied` | Command requires root or non-default user permissions. | Use `devcontainer exec --user root`. |

## Red Flags & Anti-Patterns

1.  **Relative Pathing for Workspace:** Using `.` for `--workspace-folder` in a script.
    *   *Correction:* Always resolve to an absolute path (`$(pwd)` or similar).
2.  **Missing --workspace-folder:** Forgetting the flag in `exec` or `up`.
    *   *Correction:* The CLI *always* requires the workspace context.
3.  **Manual Docker Manipulation:** Manually stopping containers via `docker stop` instead of `devcontainer down`.
    *   *Correction:* Use the CLI to ensure cleanup of volumes and labels.
4.  **Interactive Prompts in Hooks:** Using a command like `npm install` without `-y` in `postCreateCommand`.
    *   *Correction:* The Minion will hang indefinitely. Always use non-interactive flags.

## Troubleshooting Lifecycle Hooks

If a hook like `postCreateCommand` fails:
1.  **Inspect Logs:** Use `devcontainer up --workspace-folder . --log-level debug`.
2.  **Manual Trigger:** Run `devcontainer run-user-commands --workspace-folder . postCreateCommand` to re-test.
3.  **Check Context:** Verify if the command expects to be on the **Host** (`initializeCommand`) or the **Container** (all others).

## Network & Connectivity

- **Proxy Issues:** If the container needs to access the internet through a proxy, ensure the `HTTP_PROXY` and `HTTPS_PROXY` env vars are passed in via `devcontainer up` or defined in the Docker daemon settings.
- **Port Conflicts:** If multiple Minions try to bind to the same host port, the `up` command will fail.
    *   *Correction:* For "Minion" orchestration, disable port forwarding in `devcontainer.json` or use random port mapping.
