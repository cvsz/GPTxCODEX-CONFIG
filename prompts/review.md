# Code Review Prompt

Review the change as a senior maintainer.

## Review priorities
- Correctness and behavioral regressions
- Security, privacy, authorization, and secret handling
- Error handling, concurrency, cancellation, retries, and resource cleanup
- API, schema, configuration, and backward compatibility
- Test coverage and test quality
- Performance, observability, deployment, rollback, and operational impact
- Maintainability, readability, and unnecessary complexity

List findings in severity order. For each finding, provide the affected path/line, failure scenario, impact, and a specific remediation. Do not invent issues; distinguish confirmed defects from questions or optional improvements.
