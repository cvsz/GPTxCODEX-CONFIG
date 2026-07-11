# Contributing

## Development principles

Contributions must preserve correctness, security, least privilege, portability, and clear rollback paths. Do not add fabricated package names, unverified configuration keys, or undocumented privileges.

## Workflow

1. Fork or create a branch from `main`.
2. Keep each change focused.
3. Use Conventional Commits.
4. Cryptographically sign every human-authored commit.
5. Update documentation with behavior changes.
6. Run validation locally.
7. Open a pull request using the repository template.

## Commit signing

Human-authored commits must display **Verified** on GitHub before merge. GPG signing is recommended; GitHub-verified SSH or S/MIME signatures are also accepted by CI.

See [`GPG_SIGNING.md`](GPG_SIGNING.md) for Windows setup, Git configuration, verification, key rotation, and safe remediation of unsigned branch commits.

Minimum local checks:

```powershell
git config --get commit.gpgsign
git log --show-signature -1
```

Do not upload private keys, revocation certificates, passphrases, agent sockets, or exported secret-key material.

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
- Keep signing private keys outside the repository and protected by a strong passphrase or hardware-backed key storage.

## Pull requests

A pull request should explain:

- what changed and why
- compatibility impact
- security and permissions impact
- validation performed
- rollback or migration requirements
- unresolved risks

Every commit in the pull request must pass the `Verify signed commits` status check. Maintainers may request changes, additional validation, or smaller scope before merge.