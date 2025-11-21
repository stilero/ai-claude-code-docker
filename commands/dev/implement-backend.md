---
allowed-tools: Task, Bash, Read, Write, Edit, MultiEdit, TodoWrite, Glob, Grep
description: Implement backend service from /design-backend outputs — contract-first, security-first, observability-ready, no UI or AI dependencies
argument-hint: <design-folder-output-path> <service-folder> [--stack=python|csharp]
---

# Backend Implementation from Design Specifications

Build a production-ready backend service from `/design-backend` outputs with a contract-first, security-first approach. This command is general-purpose and does not assume any AI/OpenAI dependencies.

## Core Philosophy

- Design-First: Treat design outputs (MANIFEST + agent files) as the source of truth
- Contract-First: Prefer OpenAPI 3.1-driven interfaces and schema validation
- Security-First: Authentication/authorization, input validation, least privilege, secrets hygiene
- Observability-First: Structured logs, metrics, tracing, and health endpoints from day one
- Progressive Delivery: Start with core endpoints and data flows, then expand tests and hardening

## Prerequisites

This command expects outputs from `/design-backend`:

- Project manifest: `.claude/outputs/design/projects/[project]/[timestamp]/MANIFEST.md`
- Agent outputs:
  - `system-architect/integration-architecture.md` — API contracts (OpenAPI 3.1), data model, security, reliability, environments
  - `api-backend-tester/test-specifications.md` — contract, integration, performance, security tests
  - `azure-devops-pipelines-expert/cicd-pipeline.md` — CI/CD plan
  - `azure-monitor-logs-expert/observability-plan.md` — logs, metrics, tracing, dashboards, alerts
  - Optional stack specialists: `python-backend-dev/python-sample-implementation.md` or `csharp-expert/csharp-implementation.md`

## Arguments

Parse `$ARGUMENTS` to determine:

- <design-folder-output-path> (required): Folder like `.claude/outputs/design/projects/[project]/[timestamp]/`
- <service-folder> (optional): Target folder for the service implementation
- Flags (optional):
  - `--stack=python|csharp` to choose implementation stack explicitly

## Usage Examples

```
# Implement from design folder path, auto-detect stack
/implement-backend .claude/outputs/design/projects/order-service/20250915-090000 ./services/order-service

# Force Python stack
/implement-backend .claude/outputs/design/projects/inventory/20250915-093000 ./services/inventory --stack=python

# Force C# stack
/implement-backend .claude/outputs/design/projects/billing/20250915-101500 ./services/billing --stack=csharp
```

## Implementation Workflow

### Phase 1: Design Analysis & Environment Setup

1) Read MANIFEST.md and collect absolute paths to all agent outputs.
2) From `integration-architecture.md`, locate the OpenAPI 3.1 spec. If missing, extract contracts from described endpoints and error models.
3) Capture decisions: datastore(s), messaging, caching, environments, compliance, SLOs.
4) Record infrastructure dependencies (DB, cache, queues) and local dev strategy (Docker Compose recommended).
5) Create `<service-folder>` if not present; initialize repo scaffolding accordingly.

Validation checklist:
- [ ] MANIFEST parsed; all agent outputs resolved
- [ ] OpenAPI: present or reconstructed endpoint list
- [ ] Data model and migration plan understood
- [ ] Security model and environment variables enumerated

### Phase 2: Project Scaffolding by Stack

Choose the stack based on `--stack` or infer from design outputs; apply the matching scaffold.

#### Python (FastAPI baseline)

Recommended stack: FastAPI, Uvicorn, Pydantic, SQLAlchemy, Alembic, httpx, structlog or standard logging, OpenTelemetry, prometheus-client, pytest.

Structure:
```
<service-folder>/
  pyproject.toml                 # package + tooling
  src/<pkg>/
    __init__.py
    main.py                      # app bootstrap (lifespan), routers include
    api/
      __init__.py
      routes/                    # one file per resource
    domain/                      # domain models, services
    infra/
      db.py                      # engine/session, pooling
      migrations/                # Alembic
      repositories/
    core/
      config.py                  # env parsing, secrets
      logging.py                 # structured logging config
      security.py                # auth helpers, scopes
      observability.py           # OTel/metrics wiring
    schemas/                     # Pydantic models (may be generated from OpenAPI)
  tests/
    unit/
    integration/
  Dockerfile
  docker-compose.yml             # DB/cache for dev
  .env.example
  .dockerignore
  Makefile or justfile           # dev commands
```

Key steps:
- Initialize pyproject (uv/poetry/pip-tools — pick one and document)
- Add dependencies and dev-deps
- Wire FastAPI with health (`/health`), readiness (`/ready`), metrics (`/metrics`), and version endpoints
- Implement structured logging with correlation IDs
- Configure OpenTelemetry (tracing) and Prometheus metrics
- Configure DB connection pooling and Alembic migrations
- Generate or handcraft Pydantic schemas and route stubs from OpenAPI
- Provide example `.env.example` covering all required settings

#### C# (.NET 8+ Web API baseline)

Recommended stack: ASP.NET Core Minimal API or Controller-based, EF Core 8, Serilog, HealthChecks, OpenTelemetry, Swashbuckle.

Structure:
```
<service-folder>/
  src/
    Service.Api/                 # API host: endpoints, filters, DI
    Service.Application/         # Commands/Queries, validators
    Service.Domain/              # Entities, value objects, events
    Service.Infrastructure/      # EF Core, repositories, integrations
  tests/
    Service.Api.Tests/
  Dockerfile
  docker-compose.yml             # DB/cache for dev
  Directory.Build.props
  README.md
```

Key steps:
- `dotnet new` solution and projects; wire references
- Add Serilog, HealthChecks, OpenTelemetry, and Swagger/Swashbuckle
- Configure appsettings with env overrides; user-secrets for local secrets
- Add EF Core DbContext, migrations, and connection pooling
- Map endpoints from OpenAPI; create DTOs and validators
- Implement global exception handling and problem+json errors

### Phase 3: Contract-First Endpoint Implementation

Common steps (both stacks):
- Parse OpenAPI 3.1 and create stubs for each path+method
- Define request/response models and error shapes
- Implement validation (Pydantic/F fluent validation)
- Respect idempotency for relevant operations; add retry-safe patterns
- Map business rules from PRD to handlers/services
- Introduce repository/adapter layers for persistence and external services

If no OpenAPI present: derive contracts from PRD + architecture and codify them; generate an OpenAPI document for future alignment.

### Phase 4: Data, Migrations, and Caching

- Create entities with explicit constraints and indexes
- Implement migrations and seed scripts for dev
- Add caching where specified; define TTLs and invalidation rules
- Ensure transaction boundaries, isolation, and concurrency control are appropriate

### Phase 5: Testing per Test Specifications

From `test-specifications.md`, implement:
- Contract tests: request/response and error codes match spec
- Integration tests: DB, cache, messaging, background jobs
- Performance sanity: baseline timings; include thresholds as assertions where feasible
- Security tests: auth flows, input validation, rate limiting, basic abuse cases

Python: pytest, httpx AsyncClient, fixtures for test DB and overrides.
C#: xUnit/NUnit, WebApplicationFactory, Testcontainers or dockerized dependencies.

### Phase 6: Observability Wiring

- Structured logs with correlation/trace IDs; avoid logging secrets
- Traces for inbound requests and key dependencies
- RED/USE metrics; expose `/metrics` (Prometheus or equivalent)
- Implement health (`/health`) and readiness (`/ready`) endpoints
- Provide sample KQL queries/dashboards from `observability-plan.md` in docs

### Phase 7: CI/CD Integration

- Translate `cicd-pipeline.md` into pipeline files (Azure Pipelines YAML by default)
- Stages: Build → Test → Security Scan → Deploy (dev → stage → prod) with approvals
- Publish test/coverage reports; push container images; IaC hooks optional
- Rollback strategy and environment-specific config

## Deliverables

- Working backend service in `<service-folder>` following the selected stack
- OpenAPI 3.1 document in repo (either provided or authored)
- Tests aligned with design test-specifications
- Dockerfile and docker-compose for local dev
- CI pipeline files adapted from design
- Basic operational docs: running locally, env vars, health/metrics endpoints

## Guardrails & Non-Goals

- No UI concerns; this command is backend-only
- No AI/OpenAI integrations assumed or required
- Do not over-engineer beyond the design scope; document gaps for follow-up

## Quick Start Commands (Illustrative)

Python example:
```
uv init; uv add fastapi uvicorn[standard] pydantic sqlalchemy alembic httpx structlog opentelemetry-sdk opentelemetry-instrumentation-fastapi prometheus-client
uv add -d pytest pytest-asyncio httpx
```

C# example:
```
dotnet new sln -n Service
dotnet new webapi -n Service.Api -o src/Service.Api
dotnet new classlib -n Service.Application -o src/Service.Application
dotnet new classlib -n Service.Domain -o src/Service.Domain
dotnet new classlib -n Service.Infrastructure -o src/Service.Infrastructure
dotnet sln add src/**/**.csproj
dotnet add src/Service.Api/Service.Api.csproj package Serilog.AspNetCore Swashbuckle.AspNetCore OpenTelemetry.Extensions.Hosting OpenTelemetry.Exporter.Otlp
dotnet add src/Service.Infrastructure/Service.Infrastructure.csproj package Microsoft.EntityFrameworkCore Microsoft.EntityFrameworkCore.Design Microsoft.EntityFrameworkCore.SqlServer
```

## Validation Checklist

- [ ] All endpoints implemented or stubbed per OpenAPI/architecture
- [ ] Security flows and error handling verified
- [ ] Data model, migrations, and seed scripts present
- [ ] Health, readiness, metrics, logging, tracing wired
- [ ] Tests implemented per test-specifications with CI execution
- [ ] Pipeline files created and hooked to reports/artifacts

