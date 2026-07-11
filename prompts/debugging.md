# Debugging Prompt

Diagnose and fix the reported failure systematically.

## Workflow
1. Capture the exact error, environment, inputs, versions, and reproduction steps.
2. Reproduce the issue or explain why reproduction is blocked.
3. Narrow the fault domain using logs, stack traces, tests, tracing, and minimal experiments.
4. Form falsifiable hypotheses and test one variable at a time.
5. Fix the root cause rather than suppressing the symptom.
6. Add a regression test and verify adjacent behavior.
7. Report root cause, fix, validation, and remaining uncertainty.

Do not retry unchanged failing commands or add arbitrary sleeps without evidence.
