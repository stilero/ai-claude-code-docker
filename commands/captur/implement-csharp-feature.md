---
allowed-tools: Task, Bash, Read, Write, Edit, MultiEdit, TodoWrite, Glob, Grep, GitWrite
description: Implement a C#/.NET 8 feature from an approved design spec with practical, design-first steps (DDD/Clean Architecture). Mirrors the /implement-app workflow.
argument-hint: <design-file-path> [--repo=<path>] [--branch=<name>] [--solution=<path-to-sln>] [--skip-tests]
required-agents: orchestrator, csharp-expert
agent-execution-pattern: sequential
minimum-task-calls: 2
---

# Implement C# Feature From Design

Production-focused implementation of a previously approved `csharp-feature-design.md`. Builds code in the correct **FunctionApp / Application / Domain / Infrastructure** layers plus tests, following the practical workflow from `/implement-app`.

## Inputs

- `<design-file-path>` – Required. Path to `.claude/outputs/design/agents/csharp-expert/[feature-key]-[timestamp]/csharp-feature-design.md`
- `--repo` – Optional. Repo root (defaults to current working directory)
- `--branch` – Optional. Feature branch name (default `feat/<feature-key>`)
- `--solution` – Optional. Path to `.sln` (auto-detected if omitted)
- `--skip-tests` – Optional. If set, postpone running tests (still generate test files)

## Phase 0 — Read Design & Prepare (orchestrator)

Task(orchestrator):
"Read the design file at <design-file-path>. Extract:
- Feature Key (e.g., WI-12345-checkout)
- Planned files per layer, endpoints, EF entities/configurations, migrations, and tests
Create output folder `.claude/outputs/implement/csharp-expert/[feature-key]-[timestamp]/` with MANIFEST.md.
If --repo not provided, assume '.' as repo root. Detect solution (*.sln) if not provided.
Create a feature branch via GitWrite: feat/<feature-key> (or --branch).
"

## Phase 1 — Repo Assessment & Scaffolding (orchestrator)

- Scan repo structure with `Glob/Grep` to locate layer roots:
  - `FunctionApp/**`, `Application/**`, `Domain/**`, `Infrastructure/**`
- Detect projects and target frameworks from `*.csproj`
- Add missing projects if required by design (Bash + dotnet new classlib)
- Ensure project references match clean architecture:
  - FunctionApp → Application
  - Application → Domain
  - Infrastructure → Application and Domain (only where appropriate)
- Update `.sln` to include new projects (Bash `dotnet sln add`)

Create/update MANIFEST with planned file paths and project refs.

## Phase 2 — Domain First (csharp-expert)

Task(csharp-expert):
"Generate Domain code: aggregates, value objects, domain events.
Include header comments indicating layer placement.
Write files via GitWrite in a single commit: chore(domain): add aggregates for <feature-key>."

## Phase 3 — Application Layer (csharp-expert)

Task(csharp-expert):
"Generate Commands/Queries, Validators (FluentValidation), Handlers (MediatR).
Ensure CancellationToken and idempotency considerations.
Commit: feat(application): add commands/queries/handlers for <feature-key>."

## Phase 4 — Infrastructure (csharp-expert)

Task(csharp-expert):
"Add DbContext changes, IEntityTypeConfiguration<T>, repositories if specified, and outbox/inbox plumbing.
Create EF migrations in Infrastructure/Migrations using Bash:
- dotnet tool restore
- dotnet ef migrations add <FeatureKey> --project <Infrastructure.csproj> --startup-project <FunctionAppOrApi.csproj>
Commit: feat(infrastructure): EF config + migrations for <feature-key>."

## Phase 5 — Endpoints / Triggers (csharp-expert)

Task(csharp-expert):
"Wire Azure Function or Web API endpoints per design.
- Azure Functions: HTTP/Timer/ServiceBus/EventHub triggers
- Web API: Minimal APIs or Controllers as specified
Commit: feat(endpoint): add endpoints for <feature-key>."

## Phase 6 — Tests (csharp-expert)

Task(csharp-expert):
"Add unit tests (xUnit + FluentAssertions + NSubstitute) per design. 
If integration tests specified, add Testcontainers for SQL/Service Bus/Event Hubs.
Commit: test: add unit/integration tests for <feature-key>."

## Phase 7 — Build, Migrate, Validate (orchestrator)

- If not `--skip-tests`, run:
  - `dotnet restore`
  - `dotnet build -c Release`
  - `dotnet test -c Release --collect:"XPlat Code Coverage"`
- Generate and apply EF migrations locally where applicable (design may specify Aspire/AppHost auto-apply; otherwise document post-steps)
- Update MANIFEST with build/test results and migration files generated
- Publish coverage artifacts (path recorded in MANIFEST)

## Phase 8 — Observability & Security Touches (csharp-expert)

Task(csharp-expert):
"Ensure Serilog/App Insights enrichment for CorrelationId and TenantId per design.
Ensure API keys/JWT validation matches design. Add policies/scopes/roles if specified.
Commit: chore(observability/security): wire logging + auth for <feature-key>."

## Phase 9 — Finalize & Todos (orchestrator)

- Create a concise `CHANGELOG` entry fragment in output folder
- Produce a `TodoWrite` with deployment/config follow-ups:
  - Key Vault secrets
  - Connection strings per-tenant
  - Pipeline variables and approvals
  - Aspire/AppHost migrations on startup
- Update MANIFEST with:
  - Final file map
  - Commit SHAs
  - Next steps

## Practical Guidance (from /implement-app philosophy)

- **Design as source of truth** – no scope beyond the design.
- **Functional first** – ship working code; add tests for critical paths.
- **Atomic commits** – small, conventional messages per slice.
- **No secrets** – use config/Key Vault; never commit secrets.
- **Layer purity** – keep Domain free of EF/HTTP; wire infra externally.
- **Idempotency** – inbox/outbox patterns, dedupe keys, and retries with jitter as designed.

## Usage Examples

```bash
# Default usage (auto branch, auto solution detection)
/implement-csharp-feature .claude/outputs/design/agents/csharp-expert/WI-12345-checkout-20250910/csharp-feature-design.md

# Custom branch and repo
/implement-csharp-feature .claude/outputs/design/agents/csharp-expert/WI-9876-import-20250910/csharp-feature-design.md --repo=. --branch=feat/WI-9876-import --solution=src/Platform.sln
```

## Success Criteria

- Code compiles; tests pass (unless --skip-tests)
- Files created exactly as in design; layer placement comments present
- EF migrations generated and included
- Security and observability match design
- MANIFEST and TodoWrite clearly list next actions
