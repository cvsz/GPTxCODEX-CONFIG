# ChatGPT + Codex Ultimate Professional Pack (2026)

Production-oriented configuration, role profiles, reusable prompts, MCP templates, Windows PowerShell lifecycle scripts, VS Code defaults, and engineering document templates for ChatGPT + Codex workflows.

## Repository structure

```text
config.toml                 Global Windows Codex configuration
profiles/                   Role-specific Codex profiles
prompts/                    Reusable engineering workflow prompts
mcp/                        Disabled-by-default MCP configuration templates
powershell/                 Install, update, backup, and uninstall scripts
vscode/                     Recommended settings, extensions, and tasks
templates/                  Project, architecture, issue, PR, and changelog templates
```

## Secure defaults

- `approval_policy = "on-request"`
- `sandbox_mode = "workspace-write"`
- Native Windows elevated sandbox
- Workspace network access disabled by default
- Optional MCP integrations disabled by default
- Secrets inherited through environment variables rather than stored in files

## Install on Windows

Requirements: Windows 10/11 and PowerShell 7.

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\powershell\install.ps1
```

The installer writes to `%USERPROFILE%\.codex\config.toml` and creates a timestamped backup when an existing configuration is present.

## Update and backup

```powershell
.\powershell\update.ps1
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

This repository contains configuration and templates, not an application runtime. Validate changes by checking TOML/JSON syntax, PowerShell parsing, referenced executable availability, and compatibility with the exact Codex release installed on the target workstation.

## Security

Do not commit API keys, tokens, passwords, certificates, kubeconfigs, cloud credential files, database connection strings, `.env` files, or personal browser profiles. Treat Docker socket access and infrastructure write credentials as highly privileged.

## License

Add a project license before redistribution if one has not already been selected.
