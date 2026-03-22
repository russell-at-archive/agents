# Installation

## Install Paths

- macOS: `curl -fsSL https://ollama.com/install.sh | sh` or the macOS app from
  `https://ollama.com/download/mac`
- Linux: `curl -fsSL https://ollama.com/install.sh | sh`
- Windows: `irm https://ollama.com/install.ps1 | iex` or the installer from
  `https://ollama.com/download/windows`
- Docker: official `ollama/ollama` image on Docker Hub

## Verify

```bash
ollama --version
ollama --help
ollama list
```

`ollama --version` may warn if no server is running; that does not by itself
mean the CLI install is broken.

## Update

- Re-run the installer path you used originally.
- For app installs, update from the latest platform download page.
- Re-check `ollama --help` after upgrades when command behavior matters.

## Manual Setup Notes

- Local inference requires a running Ollama server.
- Remote usage requires a reachable `OLLAMA_HOST`.
- Disk, RAM, and GPU constraints are model-dependent; validate capacity before
  pulling large models.

## Official Sources

- `https://docs.ollama.com/cli`
- `https://ollama.com/download`
- `https://github.com/ollama/ollama`
