# Notion API Setup

## What This Is For

Use this setup when you want a custom integration that can search shared
Notion content and create or update documents through your own application or
backend service.

This is the better option for:

- Scheduled jobs
- Background ingestion
- Server-side document creation
- Deterministic storage rules
- Workflows that should not depend on an interactive OAuth login

## Exact Setup

### 1. Create An Internal Integration

1. Open the Notion integrations dashboard.
1. Click `+ New integration`.
1. Choose the target workspace.
1. Name the integration.
1. Save it.

### 2. Set Capabilities

Enable only the capabilities you need:

- `Read content` to search and retrieve pages
- `Insert content` to create new pages or append content
- `Update content` if you need to modify existing pages

Minimum useful set for search plus document creation:

- `Read content`
- `Insert content`

### 3. Get The API Secret

1. Open the integration's `Configuration` tab.
1. Copy the internal integration secret.
1. Store it in your app's secret manager or environment variables.

Example:

```bash
export NOTION_ACCESS_TOKEN="your-internal-integration-secret"
```

### 4. Share The Parent Content With The Integration

The integration cannot see your whole workspace automatically.

1. Open the target page or database in Notion.
1. Open the `...` menu.
1. Click `+ Add Connections`.
1. Select your integration.
1. Confirm access.

Anything you want the integration to search or write under must be shared with
it.

### 5. Capture The Parent ID

Pick where new documents should live:

- A parent `page_id`
- A parent `data_source` ID

For internal integrations, a parent is required when creating a page.

### 6. Authenticate Requests

Every request should include the bearer token and a Notion API version header.

```bash
curl "https://api.notion.com/v1/users" \
  -H "Authorization: Bearer $NOTION_ACCESS_TOKEN" \
  -H "Notion-Version: 2026-03-11"
```

### 7. Search For Existing Documents

Use the search endpoint to find pages or data sources already shared with the
integration.

```bash
curl "https://api.notion.com/v1/search" \
  -X POST \
  -H "Authorization: Bearer $NOTION_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2026-03-11" \
  --data '{
    "query": "terraform",
    "filter": {
      "property": "object",
      "value": "page"
    },
    "sort": {
      "direction": "descending",
      "timestamp": "last_edited_time"
    }
  }'
```

Key behavior:

- Search only returns pages or data sources shared with the integration.
- If `query` is omitted, Notion returns all shared pages or data sources.

### 8. Create A New Document

Create a page under an existing parent page:

```bash
curl "https://api.notion.com/v1/pages" \
  -X POST \
  -H "Authorization: Bearer $NOTION_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Notion-Version: 2026-03-11" \
  --data '{
    "parent": { "page_id": "YOUR_PARENT_PAGE_ID" },
    "properties": {
      "title": {
        "title": [
          {
            "text": {
              "content": "Integration Notes"
            }
          }
        ]
      }
    },
    "children": [
      {
        "object": "block",
        "type": "paragraph",
        "paragraph": {
          "rich_text": [
            {
              "type": "text",
              "text": {
                "content": "Created by the Notion API."
              }
            }
          ]
        }
      }
    ]
  }'
```

Notes:

- If the parent is a page, `title` is the only valid property at creation.
- If the parent is a data source, the `properties` keys must match the parent
  schema.
- You can create the page with `children` immediately or append blocks later.

### 9. Append More Content Later

Use the append block children endpoint when you want to add sections after the
page already exists.

Implementation note:

Call `PATCH /v1/blocks/{block_id}/children` with new block payloads.

## Suggested App Architecture

For a small app, the cleanest approach is:

1. Store `NOTION_ACCESS_TOKEN` securely.
1. Store one or more parent IDs in config.
1. Use `/search` before creating a new page to avoid duplicates.
1. Create pages under a known parent.
1. Append blocks for the body content.
1. Persist returned Notion page IDs in your app for future updates.

## Cost

- No separate Notion API fee
- You can use the API on any Notion plan
- Normal Notion seat pricing still applies
- Your own infrastructure costs apply for the app or backend you run

## Source Links

- Build your first integration:
  <https://developers.notion.com/guides/get-started/create-a-notion-integration>
- Integration capabilities:
  <https://developers.notion.com/reference/capabilities>
- Authentication:
  <https://developers.notion.com/reference/authentication>
- Search endpoint:
  <https://developers.notion.com/reference/post-search>
- Create page endpoint:
  <https://developers.notion.com/reference/post-page>
