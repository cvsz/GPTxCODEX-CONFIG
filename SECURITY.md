# Security Policy

## Supported versions

Security fixes target the latest revision on the `main` branch. Historical snapshots and third-party forks are not supported unless explicitly stated.

## Reporting a vulnerability

Do not open a public issue for suspected vulnerabilities, exposed credentials, unsafe automation, or privilege-escalation paths.

Use GitHub private vulnerability reporting:

https://github.com/cvsz/GPTxCODEX-CONFIG/security/advisories/new

Include:

- affected files and versions
- reproduction steps
- impact and attack prerequisites
- suggested remediation, when available
- confirmation that no live credentials are included

## Response expectations

Reports will be reviewed as availability permits. Acknowledgement, remediation, and disclosure timelines depend on severity, reproducibility, maintainer capacity, and upstream dependencies.

## Scope

Relevant reports include:

- unsafe Codex approval or sandbox defaults
- command, path, or configuration injection
- secret disclosure
- insecure MCP configuration
- unsafe PowerShell behavior
- malicious or compromised dependencies and GitHub Actions
- documentation that encourages security-control bypasses

General support questions and feature requests are not security reports.

## Safe testing

Test only against systems, accounts, repositories, and infrastructure you own or are explicitly authorized to assess. Do not access, modify, or disclose third-party data.
