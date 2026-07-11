# Governance

## Maintainer model

The repository owner is the final decision maker for project scope, releases, security policy, and merge approval. Additional maintainers may be delegated through GitHub repository permissions and CODEOWNERS.

## Decision principles

Changes are evaluated against:

- correctness and documented behavior
- security and least privilege
- compatibility with supported Codex and ChatGPT releases
- maintainability and operational clarity
- testability and rollback safety
- benefit relative to complexity and dependency risk

## Change process

Substantial changes should begin with an issue or design proposal describing requirements, alternatives, compatibility, migration, security impact, and validation. Implementation should proceed through a focused pull request.

## Reviews and merges

Sensitive areas such as `.github/`, `config.toml`, `mcp/`, and `powershell/` require owner review through CODEOWNERS. Passing automation does not replace human review. Maintainers may close proposals that are unsafe, unsupported, out of scope, or insufficiently specified.

## Releases

Releases should be traceable to reviewed commits, include a changelog, identify compatibility requirements, and document known limitations. Security-sensitive releases may use coordinated disclosure.

## Amendments

This governance document may be updated through the normal pull request process.
