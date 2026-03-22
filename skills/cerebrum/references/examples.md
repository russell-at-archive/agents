# Cerebrum Integration Examples

## Creating a Note
```bash
obsidian vault="cerebrum" create name="New Idea" content="This is a concept for Cerebrum."
```

## Appending to an Existing Note
```bash
obsidian vault="cerebrum" append file="Project Notes" content="- [ ] Follow up on research."
```

## Searching the Vault
```bash
obsidian vault="cerebrum" search query="workflow"
```

## Appending to the Daily Note
```bash
obsidian vault="cerebrum" daily:append content="- Met with team about Cerebrum."
```

## Reading a Specific File
```bash
obsidian vault="cerebrum" read file="Brainstorming"
```
