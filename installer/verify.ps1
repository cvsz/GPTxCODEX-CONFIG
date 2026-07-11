#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter()]
    [string]$RepositoryRoot = (Split-Path -Parent $PSScriptRoot)
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path -LiteralPath $RepositoryRoot).Path
$failures = [System.Collections.Generic.List[string]]::new()

try {
    python --version | Out-Null
} catch {
    $failures.Add('Python 3.11 or newer is required for TOML validation.')
}

if ($failures.Count -eq 0) {
    $pythonCode = @'
import json
import pathlib
import sys
import tomllib

root = pathlib.Path(sys.argv[1])
errors = []

for path in root.rglob("*.toml"):
    try:
        with path.open("rb") as handle:
            tomllib.load(handle)
        print(f"OK TOML: {path}")
    except Exception as exc:
        errors.append(f"{path}: {exc}")

for path in root.rglob("*.json"):
    try:
        with path.open("r", encoding="utf-8-sig") as handle:
            json.load(handle)
        print(f"OK JSON: {path}")
    except Exception as exc:
        errors.append(f"{path}: {exc}")

if errors:
    print("\n".join(errors), file=sys.stderr)
    raise SystemExit(1)
'@

    $temporaryFile = Join-Path ([System.IO.Path]::GetTempPath()) "gptxcodex-verify-$PID.py"
    try {
        Set-Content -LiteralPath $temporaryFile -Value $pythonCode -Encoding utf8NoBOM
        & python $temporaryFile $root
        if ($LASTEXITCODE -ne 0) {
            $failures.Add('TOML or JSON validation failed.')
        }
    } finally {
        Remove-Item -LiteralPath $temporaryFile -Force -ErrorAction SilentlyContinue
    }
}

Get-ChildItem -LiteralPath $root -Recurse -Filter '*.ps1' -File | ForEach-Object {
    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile(
        $_.FullName,
        [ref]$tokens,
        [ref]$parseErrors
    ) | Out-Null

    if ($parseErrors.Count -gt 0) {
        foreach ($parseError in $parseErrors) {
            $failures.Add("$($_.FullName):$($parseError.Extent.StartLineNumber): $($parseError.Message)")
        }
    } else {
        Write-Host "OK PowerShell: $($_.FullName)"
    }
}

$conflictMarkers = Get-ChildItem -LiteralPath $root -Recurse -File |
    Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
    Select-String -Pattern '^(<<<<<<<|=======|>>>>>>>)' -ErrorAction SilentlyContinue

foreach ($match in $conflictMarkers) {
    $failures.Add("Conflict marker: $($match.Path):$($match.LineNumber)")
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host 'Repository verification completed successfully.'
exit 0
