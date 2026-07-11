#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$CodexDirectory = (Join-Path $env:USERPROFILE '.codex'),
    [string]$BackupDirectory = (Join-Path $env:USERPROFILE 'Documents\CodexBackups')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $CodexDirectory -PathType Container)) {
    throw "Codex directory not found: $CodexDirectory"
}

New-Item -ItemType Directory -Path $BackupDirectory -Force | Out-Null
$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Archive = Join-Path $BackupDirectory "codex-config-$Timestamp.zip"

$Items = Get-ChildItem -LiteralPath $CodexDirectory -Force |
    Where-Object { $_.Name -notmatch '^(cache|logs|sessions|tmp)$' }

if ($Items.Count -eq 0) {
    throw "No configuration files found in: $CodexDirectory"
}

if ($PSCmdlet.ShouldProcess($Archive, "Archive $($Items.Count) Codex configuration item(s)")) {
    Compress-Archive -LiteralPath $Items.FullName -DestinationPath $Archive -CompressionLevel Optimal -Force
    $Hash = Get-FileHash -LiteralPath $Archive -Algorithm SHA256
    Write-Host "Backup created: $Archive"
    Write-Host "SHA256: $($Hash.Hash)"
}
