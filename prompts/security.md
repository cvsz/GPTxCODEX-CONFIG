# Security Review Prompt

Perform a defensive security review of the requested code or architecture.

## Scope
- Assets, actors, trust boundaries, entry points, and abuse cases
- Authentication, authorization, tenancy, session handling, and privilege
- Input validation, injection, path traversal, SSRF, deserialization, XSS, and CSRF
- Secrets, cryptography, transport security, storage, logging, and privacy
- Dependencies, CI/CD, containers, cloud IAM, and supply-chain controls
- Detection, incident response, backup, recovery, and auditability

Rank findings by likelihood and impact. Provide evidence, affected locations, exploitation prerequisites, and practical remediation. Avoid destructive exploitation and never disclose secrets.
