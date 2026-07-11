# Windows Installer

The installer deploys the root `config.toml` to `%USERPROFILE%\.codex` and
copies reusable resources into `%USERPROFILE%\.codex\GPTxCODEX-CONFIG`.

## Requirements

- Windows 10 or Windows 11
- PowerShell 7 (`pwsh.exe`)
- Python 3.11 or newer for TOML validation

## Install

```powershell
pwsh -NoProfile -File .\installer\install.ps1
```

Or launch from Command Prompt:

```cmd
installer\install.cmd
```

Preview without making changes:

```powershell
.\installer\install.ps1 -WhatIf
```

## Update

```powershell
.\installer\update.ps1
```

The updater compares SHA-256 hashes and skips installation when the active
configuration already matches the source.

## Verify

```powershell
.\installer\verify.ps1
```

Verification checks TOML, JSON, PowerShell parsing, and unresolved Git conflict
markers.

## Uninstall

Remove managed resources while preserving the active `config.toml`:

```powershell
.\installer\uninstall.ps1
```

Restore the newest installer-created configuration backup:

```powershell
.\installer\uninstall.ps1 -RestoreLatestBackup
```

Remove managed resources and backups:

```powershell
.\installer\uninstall.ps1 -RemoveBackups
```

## Safety behavior

- Existing `config.toml` files are backed up before replacement.
- Copied files are verified with SHA-256.
- All modifying scripts support `-WhatIf`.
- Uninstall preserves active configuration unless backup restoration is
  explicitly requested.
- No credentials, tokens, or private keys are installed.
