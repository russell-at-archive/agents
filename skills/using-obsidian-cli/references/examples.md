# Using Obsidian CLI: Examples

## Contents

- Basic vault inspection
- Note creation and editing
- Search workflows
- Daily note automation
- Property management
- Tag operations
- Publish pipeline
- PARA inbox processing
- Plugin development loop
- Headless CI export
- Shell pipeline patterns

---

## Basic Vault Inspection

```bash
# Confirm CLI is working
obsidian version
obsidian vaults

# List all notes, most recently modified first
obsidian files sort=modified

# Count notes in a folder
obsidian files folder=Projects ext=md total

# View folder tree
obsidian folders format=tree
```

---

## Note Creation and Editing

```bash
# Create a note with content
obsidian create name="Meeting 2026-03-15" \
  path="Meetings/" \
  content="# Meeting 2026-03-15\n\n## Attendees\n\n## Notes"

# Create from template
obsidian create name="Q2 OKRs" path="Planning/" template="OKR Template"

# Append to an existing note
obsidian append file="Meeting 2026-03-15" content="\n## Action Items\n- [ ] Follow up"

# Prepend a section header
obsidian prepend file="Research Notes" content="## Summary\n\n"

# Read note to stdout (pipe to other tools)
obsidian read file="Project Alpha"

# Copy note contents to clipboard
obsidian read file="Weekly Summary" --copy

# Move a note (all internal links auto-update)
obsidian move file="Draft Post" to="Blog/Published/"

# Rename a note
obsidian rename file="untitled" name="Architecture Decision 001"
```

---

## Search Workflows

```bash
# Full-text search
obsidian search query="second brain"

# Search by property
obsidian search query="[status:active]"
obsidian search query="[tag:project]"

# Numeric comparison
obsidian search query="[priority:>2]"

# Export search results as JSON for scripting
obsidian search query="[status:review]" format=json | jq '.[].file'

# Get file paths only
obsidian search query="[area:work]" format=paths

# Open search in the GUI
obsidian search:open query="[tag:review]"

# Context-rich results (useful for AI workflows)
obsidian search:context query="technical debt" limit=5
```

---

## Daily Note Automation

```bash
# Open / create today's daily note
obsidian daily

# Append a task
obsidian daily:append content="- [ ] Review PR #42"

# Append with a timestamp header
obsidian daily:append content="\n### $(date +%H:%M)\n"

# Append current weather (requires curl)
obsidian daily:append content="Weather: $(curl -s wttr.in?format=1)"

# Read today's daily note
obsidian daily:read

# Read a past daily note
obsidian daily:open date=2026-03-01

# Get the file path of today's daily note
obsidian daily:path
```

---

## Property Management

```bash
# View all properties on a note (YAML format, default)
obsidian properties file="Project Alpha"

# Get properties as JSON
obsidian properties file="Project Alpha" format=json

# Set a text property
obsidian properties:set file="Draft Post" status=published

# Set a date property
obsidian properties:set file="Article" published=2026-03-15 type=date

# Set a tags property (comma-separated)
obsidian properties:set file="Guide" tags="writing,tutorial" type=tags

# Remove a property
obsidian properties:remove file="Draft Post" key=draft
```

---

## Tag Operations

```bash
# List all tags in the vault
obsidian tags

# Sort tags by usage frequency
obsidian tags sort=count

# Find all notes with a specific tag
obsidian tag tagname=inbox

# Rename a tag across the entire vault
obsidian tags:rename old=todo new=inbox
```

---

## Publish Pipeline

```bash
# Find notes ready to publish, set date, add to publish queue, then publish
obsidian search query="[status:ready-to-publish]" format=json \
  | jq -r '.[].file' \
  | while read note; do
      obsidian properties:set file="$note" \
        published=$(date +%Y-%m-%d) type=date
      obsidian publish:add file="$note"
    done
obsidian publish:publish

# Remove a note from publish
obsidian publish:remove file="Outdated Post"

# View publish status
obsidian publish:list
```

---

## PARA Inbox Processing

```bash
# Move all inbox notes tagged by area to their PARA folder
for area in health finance career; do
  obsidian search query="[area:$area]" format=json \
    | jq -r '.[].file' \
    | xargs -I {} obsidian move file="{}" to="Areas/${area^}/"
done

# Find orphaned notes (no links in or out)
obsidian orphans

# Find broken links
obsidian unresolved
```

---

## Plugin Development Loop

```bash
# Hot-reload after build
npm run build && obsidian plugin:reload id=my-plugin

# Check console for errors after reload
obsidian dev:console limit=50 level=debug

# View any JS errors
obsidian dev:errors

# Open DevTools for live inspection
obsidian devtools

# Evaluate vault state from JS
obsidian eval code="app.vault.getFiles().length"
obsidian eval code="app.workspace.getActiveFile()?.name"
```

---

## Headless CI Export

```bash
# Export entire vault to docs site (skip private-tagged notes)
obsidian-export ~/vault ~/site/content \
  --skip-tags private \
  --frontmatter=always

# Export only publish-tagged notes to a subdirectory
obsidian-export ~/vault ~/deploy/posts --only-tags publish

# Export a specific subdirectory (links still resolve vault-wide)
obsidian-export ~/vault --start-at ~/vault/Blog ~/deploy/blog

# Strip all frontmatter from export
obsidian-export ~/vault ~/clean-export --frontmatter=never
```

---

## Shell Pipeline Patterns

```bash
# Pipe search results to fzf for interactive selection
obsidian search query="TODO" format=paths \
  | fzf --preview 'obsidian read path={}'

# Count tasks across all notes
obsidian tasks format=json | jq 'length'

# Archive notes older than 90 days by modified date
obsidian files sort=modified format=json \
  | jq -r '.[] | select(.modified < "2026-01-01") | .path' \
  | xargs -I {} obsidian move path="{}" to="Archive/"

# Copy today's daily note to clipboard for standup
obsidian daily:read --copy

# Target a non-default vault (vault= must be first)
obsidian vault="Personal" search query="[tag:idea]" format=paths
```
