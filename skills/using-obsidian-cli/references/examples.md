# Examples

## Desktop Note Work

```bash
# Inspect the command surface
obsidian help
obsidian help create

# Work in a specific vault
obsidian vault="Work" search query="roadmap"

# Create and populate a note
obsidian create path="Meetings/2026-03-22.md" \
  content="# Meeting\n\n## Notes"

# Read and update a note precisely
obsidian read path="Meetings/2026-03-22.md"
obsidian append path="Meetings/2026-03-22.md" \
  content="\n- [ ] Send follow-up"

# Set a property
obsidian property:set path="Projects/Launch.md" \
  name=status value=active type=text
```

## Search, Tasks, and Structure

```bash
obsidian search query="incident review"
obsidian search:context query="retry loop"
obsidian tasks todo
obsidian tags counts
obsidian backlinks path="Projects/Launch.md"
obsidian files folder="Projects"
```

## Developer Workflows

```bash
obsidian plugin:reload id=my-plugin
obsidian dev:console
obsidian dev:errors
obsidian dev:screenshot path=screenshot.png
obsidian eval code="app.workspace.getActiveFile()?.path"
```

## Headless Sync

```bash
ob login
ob sync-list-remote
cd ~/vaults/work
ob sync-setup --vault "Work"
ob sync
ob sync-status
ob sync --continuous
```

## Export Pipelines

```bash
mkdir -p /tmp/vault-export
obsidian-export ~/vault /tmp/vault-export

mkdir -p /tmp/blog-export
obsidian-export ~/vault --start-at ~/vault/Blog /tmp/blog-export
```
