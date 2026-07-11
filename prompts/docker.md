# Docker Prompt

Build or review container images for production.

## Checklist
- Use a minimal trusted base image and pin versions or digests where appropriate.
- Use multi-stage builds, deterministic dependency installation, and an effective `.dockerignore`.
- Run as a non-root user, remove build tools and secrets, and minimize capabilities and writable paths.
- Define health behavior, signals, graceful shutdown, resource expectations, and exposed ports.
- Scan dependencies and image contents, generate an SBOM when supported, and document provenance.
- Keep runtime configuration external and never bake credentials into layers.

Validate the image build, startup, health, shutdown, vulnerability results, and expected runtime behavior.
