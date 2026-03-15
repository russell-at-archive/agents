# Using Obsidian CLI: Full Reference

## Contents

- Tool selection guide
- Installation and PATH setup
- Command syntax rules
- Files and folders
- Search
- Daily notes
- Properties
- Tags
- Links and graph
- Tasks
- Plugins and themes
- Sync and publish
- Developer commands
- Vault commands
- Output formats
- Headless tools: notesmd-cli
- Headless tools: obsidian-export
- Automation patterns

---

## Tool Selection Guide

| Scenario | Tool |
| -------- | ---- |
| Obsidian is running, full feature access | `obsidian` (official CLI) |
| Headless server / CI pipeline | `notesmd-cli` |
| Export vault to standard Markdown | `obsidian-export` |
| AI agent via REST API | `obsidian-cli` by davidpp |

---

## Installation and PATH Setup

### macOS

```bash
# After enabling in Settings → General → CLI → Register CLI:
# Adds to ~/.zprofile automatically:
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# For bash add to ~/.bash_profile; for fish:
fish_add_path /Applications/Obsidian.app/Contents/MacOS
```

### Linux

```bash
# Flatpak: symlink created automatically
# AppImage / Snap / deb:
sudo ln -s /opt/obsidian/obsidian /usr/local/bin/obsidian
# Or for user-only install:
ln -s /opt/obsidian/obsidian ~/.local/bin/obsidian
```

### Verify

```bash
obsidian version
obsidian help
obsidian vaults
```

---

## Command Syntax Rules

```
obsidian [vault="VaultName"] <command> [param=value] [--flag]
```

- `vault=` must be **first** if targeting a non-default vault
- Parameters use `key=value` (no leading dashes)
- `--copy` sends output to clipboard (the only standard `--flag`)
- Spaces in values: `content="Multi word value"`
- Newlines: `\n` — `content="Line 1\nLine 2"`
- Tabs: `\t`
- File targeting: by wikilink `file=NoteName` (fuzzy) or by path
  `path=folder/note.md` (relative to vault root)

---

## Files and Folders

```bash
obsidian files                                    # list all files
obsidian files folder=Projects/Active             # files in folder
obsidian files sort=modified limit=5 --copy       # recent, copy to clipboard
obsidian files folder=Notes ext=md total          # count .md files
obsidian files format=json                        # JSON output
obsidian folders                                  # list all folders
obsidian folders format=tree                      # hierarchical view
obsidian read file="Note Name"                    # read by wikilink
obsidian read path="Projects/Note.md"             # read by exact path
obsidian file path="Notes/Recipe.md"              # file metadata
obsidian folder path="Projects/"                  # folder metadata
obsidian create name="New Note"                   # create note
obsidian create name="Script" path=Content/ template="YouTube Script"
obsidian create path="folder/note.md" content="Initial content" overwrite
obsidian append file="Research" content="New paragraph"
obsidian append file=Journal content="New entry" inline
obsidian prepend file=Note content="Added at top"
obsidian move file="Draft" to=Archive/2026/       # auto-updates links
obsidian move path="old/path.md" to="new/path.md"
obsidian delete file="Old Note"                   # moves to trash (safe)
obsidian delete file="Old Note" --permanent       # bypasses trash (irreversible)
obsidian rename file="Old Name" name="New Name"
```

`create` parameters: `name`, `path`, `content`, `template`, `overwrite`,
`silent`, `newtab`, `open`

---

## Search

```bash
obsidian search query="building a second brain"
obsidian search query="[tag:publish]"             # property search
obsidian search query="[status:active]"
obsidian search query="[priority:>3]"             # numeric comparison
obsidian search:open query="[tag:review]"         # open in GUI
obsidian search:context query="bottleneck" limit=10  # context-heavy results
```

Search operators:

- `[property:value]` — exact match
- `[property:>100]` — greater than (numbers)
- `[property:"quoted phrase"]` — phrase match

---

## Daily Notes

```bash
obsidian daily                             # open/create today's daily note
obsidian daily:read                        # read today's content
obsidian daily:read --copy                 # copy to clipboard
obsidian daily:append content="- [ ] Task"
obsidian daily:prepend content="## Morning\n\n"
obsidian daily:open date=2026-02-15        # past or future daily note
obsidian daily:path                        # return the file path
obsidian tasks daily total                 # count tasks in daily note
```

---

## Properties (YAML Frontmatter)

```bash
obsidian properties file="Project Alpha"
obsidian properties format=json
obsidian properties format=csv
obsidian properties:set file="Draft" status=active
obsidian properties:set file="Article" published=2026-02-28 type=date
obsidian properties:set file="Video" tags="pkm,obsidian" type=tags
obsidian properties:remove file="Draft" key=draft
```

Property types: `text`, `list`, `number`, `checkbox`, `date`, `tags`

---

## Tags

```bash
obsidian tags                              # list all tags
obsidian tags sort=count                   # sort by frequency
obsidian tags counts                       # all tags with counts
obsidian tag tagname=pkm                   # notes with a specific tag
obsidian tags:rename old=meeting new=meetings  # rename vault-wide
```

---

## Links and Graph

```bash
obsidian links file="Note"                 # outgoing links
obsidian backlinks file="Note"             # incoming backlinks
obsidian unresolved                        # broken [[links]]
obsidian orphans                           # notes with no links
```

---

## Tasks

```bash
obsidian tasks                             # all tasks
obsidian tasks format=json
obsidian task:create content="Write newsletter"
obsidian task:create content="Call prep" tags="work,urgent"
obsidian task:complete task=task-id
```

---

## Plugins and Themes

```bash
obsidian plugins                           # list all plugins
obsidian plugin:enable id=dataview
obsidian plugin:disable id=calendar
obsidian plugin:reload id=my-dev-plugin    # hot reload for development
obsidian themes                            # list available themes
obsidian theme:set name="Minimal"
obsidian snippets
obsidian snippet:enable name="custom-fonts"
```

---

## Sync and Publish

Requires active Obsidian Sync / Publish subscription.

```bash
obsidian sync:status
obsidian sync:history file="Note"
obsidian sync:restore file="Note" version=3
obsidian sync:pause
obsidian sync:resume
obsidian publish:list
obsidian publish:add file="Ready Post"
obsidian publish:remove file="Outdated"
obsidian publish:publish
```

---

## Developer Commands

```bash
obsidian devtools                          # toggle Electron DevTools
obsidian eval code="app.vault.getFiles().length"
obsidian eval code="app.activeFile.name"
obsidian dev:screenshot path=~/Desktop/vault.png
obsidian dev:console limit=50             # captured console messages
obsidian dev:console level=error
obsidian dev:errors                        # captured JS errors
obsidian dev:css selector=".markdown-preview-view"
obsidian dev:dom selector=".workspace-leaf"
obsidian dev:mobile on                    # enable mobile emulation
obsidian dev:debug on                     # attach Chrome DevTools Protocol
```

`eval` context variables: `app`, `vault`, `workspace`, `plugin`

---

## Vault Commands

```bash
obsidian vaults                            # list known vaults
obsidian vault:open Notes                 # open/focus a vault
obsidian version                           # show Obsidian version
obsidian help                              # display all commands
```

---

## Output Formats

| Format  | Description              | Default for                  |
| ------- | ------------------------ | ---------------------------- |
| `json`  | Structured JSON          | `search`, `files`, `tasks`   |
| `csv`   | Comma-separated          | `properties`                 |
| `tsv`   | Tab-separated            | —                            |
| `md`    | Markdown list            | `outline`                    |
| `paths` | File paths only          | `files`                      |
| `text`  | Human-readable           | `search` default             |
| `tree`  | Hierarchical             | `folders`, `outline`         |
| `yaml`  | YAML                     | `properties` default         |

Append `--copy` to any command to copy output to clipboard.

---

## Headless Tool: notesmd-cli

Works directly on vault files — no running Obsidian required.

### Installation

```bash
# macOS/Linux
brew tap yakitrak/yakitrak
brew install yakitrak/yakitrak/notesmd-cli

# Windows
scoop bucket add scoop-yakitrak https://github.com/yakitrak/scoop-yakitrak.git
scoop install notesmd-cli
```

### Headless vault config — `~/.config/obsidian/obsidian.json`

```json
{
  "vaults": {
    "vault-id": {
      "path": "/absolute/path/to/vault"
    }
  }
}
```

Use absolute paths only; `~` expansion is not supported.

### Key commands

```bash
notesmd-cli list-vaults
notesmd-cli set-default "vault-name"
notesmd-cli create "note-name" --content "text"
notesmd-cli print "note-name"
notesmd-cli search-content "term" --format json
notesmd-cli daily
notesmd-cli move "old/path" "new/path"
notesmd-cli delete "note-path"
notesmd-cli frontmatter "note-name" --print
notesmd-cli frontmatter "note-name" --edit --key status --value active
```

Global flags: `--vault <name>`, `--editor`, `--open`

---

## Headless Tool: obsidian-export

Exports vault to standard CommonMark Markdown.

### Installation

```bash
cargo install obsidian-export
```

### Usage

```bash
obsidian-export /path/to/vault /path/to/output/
obsidian-export vault/note.md /tmp/export/
obsidian-export vault --start-at vault/subfolder output/
```

### Key flags

| Flag | Description |
| ---- | ----------- |
| `--frontmatter=always` | Insert empty frontmatter if missing |
| `--frontmatter=never` | Strip all frontmatter |
| `--skip-tags foo` | Exclude files tagged `foo` |
| `--only-tags foo` | Export only files tagged `foo` |
| `--hidden` | Include hidden files |
| `--no-git` | Ignore `.gitignore` rules |

`.export-ignore` file at vault root accepts gitignore syntax.

---

## Automation Patterns

### Append to daily note with weather

```bash
obsidian daily:append content="Weather: $(curl -s wttr.in?format=1)"
```

### Search and move notes by property (PARA processing)

```bash
obsidian search query="[area:health]" format=json \
  | jq -r '.[].file' \
  | xargs -I {} obsidian move file="{}" to="Areas/Health/"
```

### Publish pipeline

```bash
obsidian search query="[status:ready]" format=json \
  | jq -r '.[].file' \
  | while read f; do
      obsidian properties:set file="$f" published=$(date +%Y-%m-%d) type=date
      obsidian publish:add file="$f"
    done
obsidian publish:publish
```

### Plugin hot-reload loop

```bash
npm run build && obsidian plugin:reload id=my-plugin
obsidian dev:console limit=50
obsidian dev:errors
```

### Headless CI export for static site

```bash
obsidian-export ~/vault ~/site/content \
  --skip-tags private \
  --frontmatter=always
```
