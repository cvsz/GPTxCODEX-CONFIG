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

function Get-Sha256 {
    param([Parameter(Mandatory)][string]$Path)
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash
}

function Assert-SourceLayout {
    param([Parameter(Mandatory)][string]$Root)

    $required = @(
        'config.toml',
        'profiles',
        'prompts',
        'mcp'
    )

    foreach ($entry in $required) {
        $path = Join-Path $Root $entry
        if (-not (Test-Path -LiteralPath $path)) {
            throw "Required source entry is missing: $path"
        }
    }
}

function Invoke-RepositoryValidation {
    param([Parameter(Mandatory)][string]$Root)

    $verifyScript = Join-Path $Root 'installer\verify.ps1'
    if (-not (Test-Path -LiteralPath $verifyScript -PathType Leaf)) {
        throw "Verification script is missing: $verifyScript"
    }

    & $verifyScript -RepositoryRoot $Root
    if ($LASTEXITCODE -ne 0) {
        throw "Repository validation failed with exit code $LASTEXITCODE."
    }
}

function Copy-VerifiedFile {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )

    $destinationDirectory = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Force

    $sourceHash = Get-Sha256 -Path $Source
    $destinationHash = Get-Sha256 -Path $Destination
    if ($sourceHash -ne $destinationHash) {
        throw "SHA-256 verification failed for $Destination"
    }
}

$resolvedSource = (Resolve-Path -LiteralPath $SourceRoot).Path
Assert-SourceLayout -Root $resolvedSource

if (-not $SkipValidation) {
    Invoke-RepositoryValidation -Root $resolvedSource
}

$targetRoot = Join-Path $CodexHome 'GPTxCODEX-CONFIG'
$targetConfig = Join-Path $CodexHome 'config.toml'
$sourceConfig = Join-Path $resolvedSource 'config.toml'
$backupRoot = Join-Path $CodexHome 'backups'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

if ((Test-Path -LiteralPath $targetConfig -PathType Leaf) -and -not $Force) {
    $existingHash = Get-Sha256 -Path $targetConfig
    $incomingHash = Get-Sha256 -Path $sourceConfig
    if ($existingHash -eq $incomingHash) {
        Write-Host 'The active config.toml already matches the repository version.'
    }
}

if ($PSCmdlet.ShouldProcess($CodexHome, 'Install GPTxCODEX-CONFIG')) {
    New-Item -ItemType Directory -Path $CodexHome -Force | Out-Null

    if (Test-Path -LiteralPath $targetConfig -PathType Leaf) {
        New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
        $backupPath = Join-Path $backupRoot "config.toml.$timestamp.bak"
        Copy-Item -LiteralPath $targetConfig -Destination $backupPath -Force
        Write-Host "Backed up active configuration to: $backupPath"
    }

    if (Test-Path -LiteralPath $targetRoot) {
        Remove-Item -LiteralPath $targetRoot -Recurse -Force
    }
    New-Item -ItemType Directory -Path $targetRoot -Force | Out-Null

    foreach ($directory in @('profiles', 'prompts', 'mcp', 'templates')) {
        $sourceDirectory = Join-Path $resolvedSource $directory
        if (Test-Path -LiteralPath $sourceDirectory -PathType Container) {
            Copy-Item -LiteralPath $sourceDirectory -Destination $targetRoot -Recurse -Force
        }
    }

    foreach ($file in @('README.md', 'LICENSE', 'NOTICE', 'THIRD_PARTY_NOTICES.md')) {
        $sourceFile = Join-Path $resolvedSource $file
        if (Test-Path -LiteralPath $sourceFile -PathType Leaf) {
            Copy-VerifiedFile -Source $sourceFile -Destination (Join-Path $targetRoot $file)
        }
    }

    Copy-VerifiedFile -Source $sourceConfig -Destination $targetConfig
    Copy-VerifiedFile -Source $sourceConfig -Destination (Join-Path $targetRoot 'config.toml')

    $installationRecord = [ordered]@{
        installed_at_utc = (Get-Date).ToUniversalTime().ToString('o')
        source_root = $resolvedSource
        target_root = $targetRoot
        config_sha256 = Get-Sha256 -Path $targetConfig
        installer_version = '1.0.0'
    } | ConvertTo-Json -Depth 3

    Set-Content -LiteralPath (Join-Path $targetRoot 'installation.json') -Value $installationRecord -Encoding utf8NoBOM

    Write-Host "Installed configuration: $targetConfig"
    Write-Host "Installed resources:     $targetRoot"
    Write-Host 'Restart ChatGPT Desktop, Codex CLI, and IDE integrations before use.'
}
