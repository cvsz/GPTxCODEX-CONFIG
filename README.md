# ChatGPT + Codex Ultimate Professional Pack (2026)

Production-oriented configuration, role profiles, reusable prompts, MCP templates, Windows PowerShell lifecycle scripts, VS Code defaults, and engineering document templates for ChatGPT + Codex workflows.

## Repository structure

```text
config.toml                 Global Windows Codex configuration
profiles/                   Role-specific Codex profiles
prompts/                    Reusable engineering workflow prompts
mcp/                        Disabled-by-default MCP configuration templates
powershell/                 Legacy lifecycle scripts
installer/                  Verified install, update, validation, and uninstall tools
vscode/                     Recommended settings, extensions, and tasks
templates/                  Project, architecture, issue, PR, and changelog templates
LICENSE                     MIT License
NOTICE                      Project attribution and trademark notice
THIRD_PARTY_NOTICES.md      External software and service guidance
```

## Secure defaults

- `approval_policy = "on-request"`
- `sandbox_mode = "workspace-write"`
- Native Windows elevated sandbox
- Workspace network access disabled by default
- Optional MCP integrations disabled by default
- Secrets inherited through environment variables rather than stored in files

## Install on Windows

Requirements: Windows 10/11, PowerShell 7, and Python 3.11 or newer.

```powershell
pwsh -NoProfile -File .\installer\install.ps1
```

Command Prompt launcher:

```cmd
installer\install.cmd
```

Preview without modifying the workstation:

```powershell
.\installer\install.ps1 -WhatIf
```

The installer:

- validates TOML, JSON, and PowerShell files
- creates a timestamped backup of an existing `%USERPROFILE%\.codex\config.toml`
- installs reusable resources under `%USERPROFILE%\.codex\GPTxCODEX-CONFIG`
- compares SHA-256 hashes after copying files
- records installation metadata in `installation.json`

See [`installer/README.md`](installer/README.md) for update, verification, rollback, and uninstall procedures.

## Update and backup

```powershell
.\installer\update.ps1
.\powershell\backup.ps1
```

Use `-WhatIf` with lifecycle scripts to preview supported operations.

## Profiles

Profiles are starting points for architecture, coding, AI engineering, research, DevOps, security, performance, debugging, and low-latency tasks. Review model names and supported keys against the installed Codex build before use.

## MCP integrations

Every MCP template is disabled by default. Before enabling one:

1. Verify the current maintained package or container image.
2. Pin or approve its version/digest.
3. Review the tool list and default approval mode.
4. Use least-privilege credentials and environment-variable forwarding.
5. Restrict filesystem, network, account, project, subscription, cluster, and repository scope.
6. Test in a non-production environment.

Template values such as `<verified-...>` are intentional safety gates and must be replaced only after verification.

## Validation

```powershell
.\installer\verify.ps1
```

This repository contains configuration and templates, not an application runtime. Validate changes by checking TOML/JSON syntax, PowerShell parsing, referenced executable availability, and compatibility with the exact Codex release installed on the target workstation.

## Security

Do not commit API keys, tokens, passwords, certificates, kubeconfigs, cloud credential files, database connection strings, `.env` files, or personal browser profiles. Treat Docker socket access and infrastructure write credentials as highly privileged.

## License

Licensed under the [MIT License](LICENSE). Third-party tools and services remain governed by their own licenses and terms; see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
