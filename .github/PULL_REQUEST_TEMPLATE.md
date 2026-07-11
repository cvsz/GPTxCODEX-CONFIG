## Summary

Describe what changed and why.

## Scope

- [ ] Configuration
- [ ] Profile
- [ ] Prompt
- [ ] MCP integration
- [ ] PowerShell
- [ ] VS Code
- [ ] Documentation
- [ ] GitHub automation

## Validation

List the exact commands and checks performed.

```text
# Example
python -m tomllib config.toml
pwsh -NoProfile -File ./powershell/install.ps1 -WhatIf
git log --show-signature -1
```

## Commit signatures

- [ ] Every human-authored commit is cryptographically signed.
- [ ] Every commit displays **Verified** on GitHub.
- [ ] No private key, passphrase, revocation certificate, or secret key export is included.
- [ ] Rewritten history, when required, was pushed with `--force-with-lease` and did not affect a shared protected branch.

See [`GPG_SIGNING.md`](../GPG_SIGNING.md) for setup and remediation guidance.

## Security and privacy

- [ ] No secrets, credentials, tokens, private keys, cookies, or private URLs are included.
- [ ] New permissions, network access, shell execution, or MCP capabilities are documented.
- [ ] External packages, actions, and container images were verified before use.
- [ ] Destructive operations require explicit user approval.

## Compatibility

Document the tested operating systems, Codex versions, ChatGPT Desktop builds, and migration impact.

## Checklist

- [ ] The change is focused and contains no unrelated modifications.
- [ ] TOML and JSON files parse successfully.
- [ ] PowerShell scripts pass parser validation.
- [ ] Documentation and examples match the implementation.
- [ ] Backward compatibility and rollback were considered.
