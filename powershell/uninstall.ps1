#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string]$CodexDirectory = (Join-Path $env:USERPROFILE '.codex'),
    [switch]$RemoveEntireDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $CodexDirectory -PathType Container)) {
    Write-Host "Nothing to uninstall. Directory not found: $CodexDirectory"
    return
}

$Config = Join-Path $CodexDirectory 'config.toml'

if ($RemoveEntireDirectory) {
    $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $Backup = Join-Path ([System.IO.Path]::GetTempPath()) "codex-before-uninstall-$Timestamp.zip"
    $Items = Get-ChildItem -LiteralPath $CodexDirectory -Force
    if ($Items.Count -gt 0) {
        Compress-Archive -LiteralPath $Items.FullName -DestinationPath $Backup -CompressionLevel Optimal -Force
        Write-Host "Safety backup created: $Backup"
    }
    if ($PSCmdlet.ShouldProcess($CodexDirectory, 'Remove the entire Codex user directory')) {
        Remove-Item -LiteralPath $CodexDirectory -Recurse -Force
        Write-Host "Removed: $CodexDirectory"
    }
    return
}

if (Test-Path -LiteralPath $Config -PathType Leaf) {
    if ($PSCmdlet.ShouldProcess($Config, 'Remove installed Codex config.toml')) {
        Remove-Item -LiteralPath $Config -Force
        Write-Host "Removed: $Config"
    }
} else {
    Write-Host "Configuration file not found: $Config"
}

Write-Host 'Other Codex data was preserved. Use -RemoveEntireDirectory only when full removal is intended.'
