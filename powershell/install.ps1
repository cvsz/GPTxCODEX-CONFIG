#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$SourceConfig = (Join-Path (Split-Path -Parent $PSScriptRoot) 'config.toml'),
    [string]$DestinationDirectory = (Join-Path $env:USERPROFILE '.codex'),
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Destination = Join-Path $DestinationDirectory 'config.toml'

if (-not (Test-Path -LiteralPath $SourceConfig -PathType Leaf)) {
    throw "Source configuration not found: $SourceConfig"
}

if (-not (Test-Path -LiteralPath $DestinationDirectory)) {
    New-Item -ItemType Directory -Path $DestinationDirectory -Force | Out-Null
}

if (Test-Path -LiteralPath $Destination -PathType Leaf) {
    $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $BackupPath = Join-Path $DestinationDirectory "config.toml.backup-$Timestamp"
    Copy-Item -LiteralPath $Destination -Destination $BackupPath -Force
    Write-Host "Existing configuration backed up to: $BackupPath"

    if (-not $Force -and -not $PSCmdlet.ShouldProcess($Destination, 'Replace existing Codex configuration')) {
        return
    }
}

if ($PSCmdlet.ShouldProcess($Destination, 'Install Codex configuration')) {
    Copy-Item -LiteralPath $SourceConfig -Destination $Destination -Force
    Write-Host "Installed configuration: $Destination"
}

$Codex = Get-Command codex -ErrorAction SilentlyContinue
if ($null -eq $Codex) {
    Write-Warning 'Codex CLI was not found in PATH. Install or update it separately, then restart the terminal.'
} else {
    Write-Host "Codex executable: $($Codex.Source)"
    try { & codex --version } catch { Write-Warning $_.Exception.Message }
}

Write-Host 'Restart ChatGPT Desktop, Codex CLI, and IDE integrations to reload the configuration.'
