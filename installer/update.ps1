#requires -Version 7.0
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter()]
    [string]$SourceRoot = (Split-Path -Parent $PSScriptRoot),

    [Parameter()]
    [string]$CodexHome = (Join-Path $env:USERPROFILE '.codex'),

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$SkipValidation
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$installScript = Join-Path $PSScriptRoot 'install.ps1'
if (-not (Test-Path -LiteralPath $installScript -PathType Leaf)) {
    throw "Installer not found: $installScript"
}

$sourceConfig = Join-Path $SourceRoot 'config.toml'
$targetConfig = Join-Path $CodexHome 'config.toml'

if (-not (Test-Path -LiteralPath $sourceConfig -PathType Leaf)) {
    throw "Source configuration not found: $sourceConfig"
}

if ((Test-Path -LiteralPath $targetConfig -PathType Leaf) -and -not $Force) {
    $sourceHash = (Get-FileHash -LiteralPath $sourceConfig -Algorithm SHA256).Hash
    $targetHash = (Get-FileHash -LiteralPath $targetConfig -Algorithm SHA256).Hash

    if ($sourceHash -eq $targetHash) {
        Write-Host 'No update is required. The installed config.toml already matches the source.'
        return
    }
}

if ($PSCmdlet.ShouldProcess($CodexHome, 'Update GPTxCODEX-CONFIG installation')) {
    $arguments = @{
        SourceRoot = $SourceRoot
        CodexHome = $CodexHome
        Force = $Force
        SkipValidation = $SkipValidation
        Confirm = $false
    }

    & $installScript @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Update failed with exit code $LASTEXITCODE."
    }
}
