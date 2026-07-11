# Contributing

## Development principles

Contributions must preserve correctness, security, least privilege, portability, and clear rollback paths. Do not add fabricated package names, unverified configuration keys, or undocumented privileges.

## Workflow

1. Fork or create a branch from `main`.
2. Keep each change focused.
3. Use Conventional Commits.
4. Update documentation with behavior changes.
5. Run validation locally.
6. Open a pull request using the repository template.

## Local validation

Validate TOML and JSON with Python 3.11 or newer and parse PowerShell scripts with PowerShell 7.

```powershell
python -c "import pathlib,tomllib; [tomllib.load(p.open('rb')) for p in pathlib.Path('.').rglob('*.toml')]"

Get-ChildItem -Recurse -Filter *.json | ForEach-Object {
  Get-Content -Raw $_.FullName | ConvertFrom-Json | Out-Null
}

Get-ChildItem -Recurse -Filter *.ps1 | ForEach-Object {
  $tokens = $null
  $errors = $null
  [System.Management.Automation.Language.Parser]::ParseFile(
    $_.FullName,
    [ref]$tokens,
    [ref]$errors
  ) | Out-Null
  if ($errors.Count -gt 0) { throw ($errors -join [Environment]::NewLine) }
}
```

## Security requirements

- Never commit secrets, credentials, tokens, cookies, certificates, private keys, connection strings, or private endpoints.
- MCP integrations must remain disabled until dependencies and permissions are verified.
- Use environment-variable forwarding rather than inline secret values.
- Pin or otherwise control third-party automation dependencies where practical.
- Document network access, filesystem scope, cloud permissions, and destructive capabilities.

## Pull requests

A pull request should explain:

- what changed and why
- compatibility impact
- security and permissions impact
- validation performed
- rollback or migration requirements
- unresolved risks

Maintainers may request changes, additional validation, or smaller scope before merge.
