#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DOCS_ROOT="${PROJECT_ROOT}/docs"
TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cleanup() {
  :
}
trap cleanup EXIT INT TERM

log() {
  printf '%s\n' "${*}"
}

warn() {
  printf 'WARN: %s\n' "${*}" >&2
}

have_cmd() {
  command -v "${1}" >/dev/null 2>&1
}

is_brew_installed() {
  local brew_name="${1}"

  if ! have_cmd brew; then
    return 1
  fi

  brew list --formula "${brew_name}" >/dev/null 2>&1 || brew list --cask "${brew_name}" >/dev/null 2>&1
}

is_npm_installed() {
  local npm_package="${1}"

  if ! have_cmd npm; then
    return 1
  fi

  npm list -g --depth=0 "${npm_package}" >/dev/null 2>&1
}

detect_install_method() {
  local tool_cmd="${1}"
  local npm_package="${2}"
  local brew_name="${3}"
  local cmd_path=""
  local brew_prefix=""
  local npm_prefix=""
  local has_brew_pkg=1
  local has_npm_pkg=1

  if ! have_cmd "${tool_cmd}"; then
    printf 'missing\n'
    return 0
  fi

  cmd_path="$(command -v "${tool_cmd}")"

  if is_brew_installed "${brew_name}"; then
    has_brew_pkg=0
  fi

  if is_npm_installed "${npm_package}"; then
    has_npm_pkg=0
  fi

  if have_cmd brew; then
    brew_prefix="$(brew --prefix 2>/dev/null || true)"
    if [[ -n "${brew_prefix}" && "${cmd_path}" == "${brew_prefix}"/* && "${has_brew_pkg}" -eq 0 ]]; then
      printf 'brew\n'
      return 0
    fi
  fi

  if have_cmd npm; then
    npm_prefix="$(npm prefix -g 2>/dev/null || true)"
    if [[ -n "${npm_prefix}" && "${cmd_path}" == "${npm_prefix}"/* && "${has_npm_pkg}" -eq 0 ]]; then
      printf 'npm\n'
      return 0
    fi
  fi

  if [[ "${has_brew_pkg}" -eq 0 && "${has_npm_pkg}" -ne 0 ]]; then
    printf 'brew\n'
    return 0
  fi

  if [[ "${has_npm_pkg}" -eq 0 && "${has_brew_pkg}" -ne 0 ]]; then
    printf 'npm\n'
    return 0
  fi

  printf 'unknown\n'
}

update_with_npm() {
  local npm_package="${1}"

  if ! have_cmd npm; then
    return 1
  fi

  log "Updating ${npm_package} via npm..."
  npm install -g "${npm_package}"
}

update_with_brew() {
  local brew_name="${1}"

  if ! have_cmd brew; then
    return 1
  fi

  if brew list --formula "${brew_name}" >/dev/null 2>&1; then
    log "Upgrading ${brew_name} (brew formula)..."
    brew upgrade "${brew_name}"
    return 0
  fi

  if brew list --cask "${brew_name}" >/dev/null 2>&1; then
    log "Upgrading ${brew_name} (brew cask)..."
    brew upgrade --cask "${brew_name}"
    return 0
  fi

  return 1
}

update_tool() {
  local tool_name="${1}"
  local tool_cmd="${2}"
  local npm_package="${3}"
  local brew_name="${4}"
  local install_method=""

  install_method="$(detect_install_method "${tool_cmd}" "${npm_package}" "${brew_name}")"

  case "${install_method}" in
    brew)
      if update_with_brew "${brew_name}"; then
        return 0
      fi
      ;;
    npm)
      if update_with_npm "${npm_package}"; then
        return 0
      fi
      ;;
    missing)
      warn "Skipping update for ${tool_name}; command '${tool_cmd}' not found."
      return 1
      ;;
    *)
      warn "Install source for ${tool_name} is unknown. Trying npm then brew."
      ;;
  esac

  if update_with_npm "${npm_package}"; then
    return 0
  fi

  if update_with_brew "${brew_name}"; then
    return 0
  fi

  warn "Could not update ${tool_name}. Install/update it manually."
  return 1
}

write_help_markdown() {
  local tool_name="${1}"
  local tool_cmd="${2}"
  local output_file="${3}"

  if ! have_cmd "${tool_cmd}"; then
    warn "Skipping help export for ${tool_cmd}; command not found."
    return 1
  fi

  {
    printf '# %s CLI Help\n\n' "${tool_name}"
    printf -- "- Generated: \`%s\`\n" "${TIMESTAMP}"
    printf -- "- Command: \`%s --help\`\n\n" "${tool_cmd}"
    printf '```text\n'
    "${tool_cmd}" --help 2>&1
    printf '\n```\n'
  } >"${output_file}"

  log "Wrote ${output_file}"
}

main() {
  local update_failures=0
  local help_failures=0
  local claude_dir="${DOCS_ROOT}/agents/claude"
  local gemini_dir="${DOCS_ROOT}/agents/gemini"
  local codex_dir="${DOCS_ROOT}/agents/codex"
  local pi_dir="${DOCS_ROOT}/agents/pi"

  mkdir -p "${claude_dir}" "${gemini_dir}" "${codex_dir}" "${pi_dir}"

  update_tool "claude" "claude" "@anthropic-ai/claude-code" "claude" || update_failures=$((update_failures + 1))
  update_tool "gemini" "gemini" "@google/gemini-cli" "gemini-cli" || update_failures=$((update_failures + 1))
  update_tool "codex" "codex" "@openai/codex" "codex" || update_failures=$((update_failures + 1))
  update_tool "pi" "pi" "@mariozechner/pi-coding-agent" "pi" || update_failures=$((update_failures + 1))

  write_help_markdown "Claude" "claude" "${claude_dir}/claude-help.md" || help_failures=$((help_failures + 1))
  write_help_markdown "Gemini" "gemini" "${gemini_dir}/gemini-help.md" || help_failures=$((help_failures + 1))
  write_help_markdown "Codex" "codex" "${codex_dir}/codex-help.md" || help_failures=$((help_failures + 1))
  write_help_markdown "Pi" "pi" "${pi_dir}/pi-help.md" || help_failures=$((help_failures + 1))

  if [[ "${update_failures}" -gt 0 || "${help_failures}" -gt 0 ]]; then
    warn "Completed with issues (update failures: ${update_failures}, help export failures: ${help_failures})."
    exit 1
  fi

  log "All updates and help exports completed successfully."
}

main "$@"
