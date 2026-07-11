# Refactoring Prompt

Refactor the target code without changing externally observable behavior unless explicitly authorized.

## Method
- Establish current behavior using tests, documentation, and call sites.
- Identify the concrete maintainability problem and define success criteria.
- Preserve public APIs, data formats, error semantics, and configuration compatibility.
- Make incremental changes with tests passing between steps.
- Remove duplication and accidental complexity, but avoid speculative abstractions.
- Measure performance-sensitive paths before and after.
- Update documentation and migration notes when structure or ownership changes.

Finish with evidence that behavior remains compatible and list any intentional deviations.
