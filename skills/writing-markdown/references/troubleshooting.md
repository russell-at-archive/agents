# Troubleshooting

## Common Mistakes


- **Lines over 80 chars**: Hard-wrap prose at 80
- **Missing blank lines**: Add around headings/blocks
- **No language on code fences**: Specify the language
- **Bare URLs in text**: Wrap in angle brackets or link
- **Trailing spaces**: Strip trailing whitespace
- **Inconsistent list markers**: Use `-` everywhere
- **Unequal column widths**: Pad all cells to the widest
  cell in their column; match separator dash count
- **Table lint failures**: Fix table pipe spacing, alignment,
  and column widths first; convert to lists only as a last resort
- **Missing alt text on images**: Always add alt text
- **Generic link text**: Use descriptive text
- **Multiple H1 headings**: Only one `#` per document
- **Skipping heading levels**: Go H1, H2, H3 in order
- **File not ending with newline**: Add trailing newline

## Red Flags - STOP and Fix


- Line visually extends past editor's 80-column marker
- Paragraph is a single long line with no line breaks
- Table has 3+ columns (almost always too wide)
- Table has inconsistent pipe spacing
- Table columns are not padded to equal width
- Code fence missing language identifier
- Two blank lines in a row anywhere
- Heading without blank line above or below
