# DevContainer CLI Troubleshooting

## Common Failures

| Symptom | Likely cause | Response |
| :--- | :--- | :--- |
| `Cannot connect to Docker daemon` | Docker runtime is stopped, unreachable, or pointed at the wrong socket | Verify `docker version`, `docker info`, and any `DOCKER_HOST` override before touching `devcontainer.json` |
| `Missing devcontainer.json` or unexpected config | Wrong workspace path or config path | Resolve the workspace to an absolute path and check `--config` if the file is not in the default location |
| Hook hangs during `up` | Interactive command in a lifecycle hook | Make hook commands non-interactive and rerun with `devcontainer run-user-commands` |
| Command fails inside the container but works locally | Dependency is not in the image or hook path | Confirm the tool is installed by the image, Feature, or creation hooks |
| Git behaves incorrectly in a worktree | Shared worktree metadata is not mounted | Retry with `--mount-git-worktree-common-dir` |
| Config changes do not seem to apply | Old container or cached state is still being reused | Inspect with `read-configuration`, then retry `up --remove-existing-container` if needed |

## Debug Sequence

Use this order instead of random edits:

1. `docker version`
2. `devcontainer read-configuration --workspace-folder <abs-path>`
3. `devcontainer up --workspace-folder <abs-path> --log-level debug`
4. `devcontainer up --workspace-folder <abs-path> --log-level trace`
5. `devcontainer run-user-commands --workspace-folder <abs-path>`

## High-Value Flags

- `--log-level debug` to expose decision points without full trace noise
- `--include-merged-configuration` when the final config differs from
  what `devcontainer.json` alone suggests
- `--remove-existing-container` when debugging stale state
- `--expect-existing-container` when automation should fail instead of
  provisioning a fresh environment
- `--skip-post-create` to isolate build and startup from hook failures

## Anti-Patterns

- Using relative `--workspace-folder` values in automation
- Editing the config before running `read-configuration`
- Treating a hook failure as an image build failure without checking
  which lifecycle phase broke
- Assuming Git worktrees behave like normal clones without the extra
  mount flag
- Manually editing generated lockfiles instead of using
  `devcontainer upgrade`

## Maintenance Issues

If lockfile or Feature drift is the problem:

- Use `devcontainer outdated --workspace-folder <abs-path>` to inspect
  version differences.
- Use `devcontainer upgrade --workspace-folder <abs-path> --dry-run`
  before writing.
- Rebuild or recreate only after confirming what changed.
