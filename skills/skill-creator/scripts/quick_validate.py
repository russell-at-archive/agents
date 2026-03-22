#!/usr/bin/env python3
"""Quick validation script for skills."""

import re
import sys
from pathlib import Path

INSTALL_HINT_PATTERNS = (
    r"\bbrew install\b",
    r"\bwinget install\b",
    r"\bapt(?:-get)? install\b",
    r"\bdnf install\b",
    r"\byum install\b",
    r"\bpacman -S\b",
    r"\bapk add\b",
    r"\bnpm install\b",
    r"\bpnpm add\b",
    r"\byarn add\b",
    r"\bpip(?:3)? install\b",
    r"\bcargo install\b",
    r"\bgo install\b",
    r"\bchoco install\b",
    r"\bofficial package instructions\b",
    r"\bofficial release channel\b",
)


def _extract_frontmatter(content):
    """Extract parsed frontmatter and the starting offset of the body."""
    if not content.startswith("---"):
        return None, None, "No YAML frontmatter found"

    match = re.match(r"^---\n(.*?)\n---\n?", content, re.DOTALL)
    if not match:
        return None, None, "Invalid frontmatter format"

    frontmatter = {}
    lines = match.group(1).splitlines()
    index = 0
    while index < len(lines):
        raw_line = lines[index]
        if not raw_line.strip():
            index += 1
            continue
        if raw_line.startswith(" ") or raw_line.startswith("\t"):
            return None, None, "Invalid YAML in frontmatter: unexpected indentation"
        if ":" not in raw_line:
            return None, None, f"Invalid YAML in frontmatter: {raw_line!r}"

        key, value = raw_line.split(":", 1)
        key = key.strip()
        value = value.strip()

        if value in {">", "|", ">-", "|-"}:
            continuation = []
            index += 1
            while index < len(lines):
                next_line = lines[index]
                if next_line.startswith("  ") or next_line.startswith("\t"):
                    continuation.append(next_line.strip())
                    index += 1
                    continue
                break
            frontmatter[key] = " ".join(continuation)
            continue

        if value.startswith(("'", '"')) and value.endswith(("'", '"')):
            value = value[1:-1]
        index += 1
        continuation = []
        while index < len(lines):
            next_line = lines[index]
            if next_line.startswith("  ") or next_line.startswith("\t"):
                continuation.append(next_line.strip())
                index += 1
                continue
            break
        if continuation:
            value = " ".join([value, *continuation]).strip()
        frontmatter[key] = value

    return frontmatter, match.end(), None


def _is_cli_skill(frontmatter, content):
    """Heuristic to identify skills centered on a CLI tool."""
    name = str(frontmatter.get("name", "")).lower()
    description = str(frontmatter.get("description", "")).lower()
    return (
        name.endswith("-cli")
        or " cli " in f" {description} "
        or "command line" in description
        or "command-line" in description
    )


def _has_install_guidance(installation_path):
    """Check whether installation guidance is present and concrete."""
    if not installation_path.exists():
        return False, "CLI skill missing references/installation.md"

    install_text = installation_path.read_text()
    if not any(
        re.search(pattern, install_text, re.IGNORECASE)
        for pattern in INSTALL_HINT_PATTERNS
    ):
        return (
            False,
            "references/installation.md exists but does not contain "
            "concrete installation guidance",
        )

    return True, None


def validate_skill(skill_path):
    """Validate a skill against the local skill-creator policy."""
    skill_path = Path(skill_path)

    skill_md = skill_path / "SKILL.md"
    if not skill_md.exists():
        return False, "SKILL.md not found"

    content = skill_md.read_text()
    frontmatter, body_start, frontmatter_error = _extract_frontmatter(content)
    if frontmatter_error:
        return False, frontmatter_error

    allowed_properties = {
        "name",
        "description",
        "license",
        "allowed-tools",
        "metadata",
        "compatibility",
    }
    unexpected_keys = set(frontmatter.keys()) - allowed_properties
    if unexpected_keys:
        return False, (
            f"Unexpected key(s) in SKILL.md frontmatter: "
            f"{', '.join(sorted(unexpected_keys))}. Allowed properties are: "
            f"{', '.join(sorted(allowed_properties))}"
        )

    if "name" not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if "description" not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    name = frontmatter.get("name", "")
    if not isinstance(name, str):
        return False, f"Name must be a string, got {type(name).__name__}"
    name = name.strip()
    if name:
        if not re.match(r"^[a-z0-9-]+$", name):
            return False, (
                f"Name '{name}' should be kebab-case "
                "(lowercase letters, digits, and hyphens only)"
            )
        if name.startswith("-") or name.endswith("-") or "--" in name:
            return False, (
                f"Name '{name}' cannot start/end with hyphen or contain "
                "consecutive hyphens"
            )
        if len(name) > 64:
            return False, (
                f"Name is too long ({len(name)} characters). Maximum is 64 "
                "characters."
            )

    description = frontmatter.get("description", "")
    if not isinstance(description, str):
        return False, (
            f"Description must be a string, got {type(description).__name__}"
        )
    description = description.strip()
    if description:
        if "<" in description or ">" in description:
            return False, "Description cannot contain angle brackets (< or >)"
        if len(description) > 1024:
            return False, (
                f"Description is too long ({len(description)} characters). "
                "Maximum is 1024 characters."
            )

    compatibility = frontmatter.get("compatibility", "")
    if compatibility:
        if not isinstance(compatibility, str):
            return False, (
                f"Compatibility must be a string, got "
                f"{type(compatibility).__name__}"
            )
        if len(compatibility) > 500:
            return False, (
                f"Compatibility is too long ({len(compatibility)} "
                "characters). Maximum is 500 characters."
            )

    body = content[body_start:]
    body_lines = len(body.splitlines())
    warnings = []
    if body_lines > 100:
        warnings.append(
            f"SKILL.md body is {body_lines} lines; keep it as short as possible"
        )

    if _is_cli_skill(frontmatter, content):
        if "references/installation.md" not in content:
            return (
                False,
                "CLI skill must explicitly reference references/installation.md "
                "from SKILL.md",
            )
        install_ok, install_error = _has_install_guidance(
            skill_path / "references" / "installation.md"
        )
        if not install_ok:
            return False, install_error

    message = "Skill is valid!"
    if warnings:
        message = f"{message} Warning: {'; '.join(warnings)}"
    return True, message


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python quick_validate.py <skill_directory>")
        sys.exit(1)

    valid, message = validate_skill(sys.argv[1])
    print(message)
    sys.exit(0 if valid else 1)
