#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot),
    [string]$DestinationDirectory = (Join-Path $env:USERPROFILE '.codex')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Source = Join-Path $RepositoryRoot 'config.toml'
$Destination = Join-Path $DestinationDirectory 'config.toml'

if (-not (Test-Path -LiteralPath $Source -PathType Leaf)) {
    throw "Repository configuration not found: $Source"
}

if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) {
    throw "Installed configuration not found: $Destination. Run install.ps1 first."
}

$SourceHash = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
$DestinationHash = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash

if ($SourceHash -eq $DestinationHash) {
    Write-Host 'Installed configuration is already up to date.'
    return
}

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $DestinationDirectory "config.toml.backup-$Timestamp"

if ($PSCmdlet.ShouldProcess($Destination, 'Back up and update Codex configuration')) {
    Copy-Item -LiteralPath $Destination -Destination $Backup -Force
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "Updated: $Destination"
    Write-Host "Backup:  $Backup"
}

Write-Host 'Restart ChatGPT Desktop, Codex CLI, and IDE integrations to reload the configuration.'
