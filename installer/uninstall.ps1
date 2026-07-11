#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [Parameter()]
    [string]$CodexHome = (Join-Path $env:USERPROFILE '.codex'),

    [Parameter()]
    [switch]$RestoreLatestBackup,

    [Parameter()]
    [switch]$RemoveBackups
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$targetRoot = Join-Path $CodexHome 'GPTxCODEX-CONFIG'
$targetConfig = Join-Path $CodexHome 'config.toml'
$backupRoot = Join-Path $CodexHome 'backups'

if ($PSCmdlet.ShouldProcess($targetRoot, 'Remove installed GPTxCODEX-CONFIG resources')) {
    if (Test-Path -LiteralPath $targetRoot) {
        Remove-Item -LiteralPath $targetRoot -Recurse -Force
        Write-Host "Removed resources: $targetRoot"
    } else {
        Write-Host 'Installed resource directory was not found.'
    }
}

if ($RestoreLatestBackup) {
    $latestBackup = Get-ChildItem -LiteralPath $backupRoot -Filter 'config.toml.*.bak' -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTimeUtc -Descending |
        Select-Object -First 1

    if ($null -eq $latestBackup) {
        throw "No configuration backup was found in $backupRoot"
    }

    if ($PSCmdlet.ShouldProcess($targetConfig, "Restore backup $($latestBackup.FullName)")) {
        Copy-Item -LiteralPath $latestBackup.FullName -Destination $targetConfig -Force
        Write-Host "Restored configuration from: $($latestBackup.FullName)"
    }
} elseif (Test-Path -LiteralPath $targetConfig -PathType Leaf) {
    Write-Warning "The active config.toml was preserved: $targetConfig"
    Write-Warning 'Use -RestoreLatestBackup to replace it with the newest backup.'
}

if ($RemoveBackups -and (Test-Path -LiteralPath $backupRoot)) {
    if ($PSCmdlet.ShouldProcess($backupRoot, 'Remove GPTxCODEX-CONFIG backups')) {
        Remove-Item -LiteralPath $backupRoot -Recurse -Force
        Write-Host "Removed backups: $backupRoot"
    }
}
