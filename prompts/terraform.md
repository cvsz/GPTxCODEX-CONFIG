# Terraform Prompt

Implement infrastructure changes with safe Terraform practices.

## Procedure
1. Inspect providers, modules, state backend, workspaces, versions, and existing conventions.
2. Use typed variables, validation, least privilege, deterministic naming, and explicit outputs.
3. Avoid secrets in code, plans, state output, and logs; use approved secret stores.
4. Run formatting, initialization, validation, linting, security checks, and a reviewed plan.
5. Assess replacement, deletion, downtime, data migration, dependencies, quotas, and cost impact.
6. Apply only with explicit authorization and a rollback or recovery plan.
7. Document state migration, imports, moved blocks, and operational ownership.

Never use targeted apply as a routine workaround for an inconsistent dependency graph.
